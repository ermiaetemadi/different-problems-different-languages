(declaim (sb-ext:muffle-conditions cl:warning))     ; We don't want the messy warnings

(load "~/.quicklisp/setup.lisp")                     ; Loading quicklisp library manager
(ql:quickload :lisp-stat)                            ; Loading lisp-stat
(ql:quickload :distributions)                    ; Loading Distributions
(ql:quickload :plot/vega)
(in-package :ls-user)                               ; Access to Lisp-Stat functions

(setf *random-state* (make-random-state t))         ; New seed for random generators
(defparameter normal-dist (distributions:r-normal 0 1))

(write-line "PS7 program starts")

(defun metropolice (dist-pdf delta step-num)       ; Metropolice algorithm function

    (setq pos 0.0)                                  ; Initial Position
    (setq new-pos 0.0)                              ; New pos
    (setq counter 1)                                ; Number of accepted walks
    (setq pos-seq (make-list 1 :initial-element 0.0))    ; zeros(step-num)

    (loop for i from 2 to step-num
    do

       (setq new-pos (+ pos (* delta (- (random 2.0) 1))))

       (if (< (random 1.0) (/ (funcall dist-pdf new-pos) (funcall dist-pdf pos)))      ; We check the acceptence based on pdf

            ; New pos accpeted
            (progn (setq pos new-pos)
            (push pos pos-seq)
            (setq counter (+ counter 1)))
       
       )

    )

    (return-from metropolice (list pos-seq counter))    ; Returns the sequence and the counter
    )

(defun auto-cor (data data-len lag)     ; This function calculates the auto correlation
    (setq data-mean (mean data))  
    (setq data-var (variance data))
    (setq num 0.0)
  
    (loop for i from 0 below (- data-len lag) do
        (setq num (+ num (* (nth i data) (nth (+ i lag) data))))
    
    )

    (setq ac (/ num (* data-len data-var)))

    (return-from auto-cor ac)
)

(setq output-list (metropolice (lambda (x) (distributions:pdf normal-dist x)) 1 10000)) ; We metropolice

(setq data-metro-list (nth 0 output-list))

(setq data-metro-df (make-df '(:data-ser) (list (coerce data-metro-list 'vector) )))



(plot:plot
 (vega:defplot relative-frequency-histogram
   `(:title "Metropolice Algorithm for Normal Distribution"
     :data ,data-metro-df
     :transform #((:bin (:maxbins 80)
	               :field :data-ser
		           :as #(:bin-horsepower :bin-horsepower-end)) ; There is no horses don't worry
                  (:aggregate #((:op :count
				                 :as "Count"))
                   :groupby   #(:bin-horsepower :bin-horsepower-end))
		          (:joinaggregate #((:op :sum
				                     :field "Count"
				                     :as "TotalCount")))
		          (:calculate "datum.Count/datum.TotalCount "
		                      :as :percent-of-total))
     :mark (:type :bar :tooltip t)
     :encoding (:x (:field :bin-horsepower
	                :title "x"
		            :bin (:binned t))
		        :x2 (:field :bin-horsepower-end)
	            :y (:field :percent-of-total
		            :type "quantitative"
		            :title "Density"
		            :axis (:format ".1~%"))))))


(setq step-list '())
(setq accept-list '())



(loop for step-size from 0.1 to 30.0 by 0.1 ; Testing every step length for finding diffrent acceptence rates 
  do
    (push step-size step-list)
    (setq temp-data (metropolice (lambda (x) (distributions:pdf normal-dist x)) step-size 10000))
    (setq acc (/ (nth 1 temp-data) 10000))
    (push acc accept-list)
    (if (>= (abs (rem acc 0.1)) 0.1) then

        (progn (write step-size)
          (format t "~a" ":")
          (format t "~f" acc)
          (terpri)
          (format t "~a" "----------")
          (terpri)
        )
    )
)               


(setq acc-df (make-df '(:step-size :acceptance) (list (coerce step-list 'vector) (coerce accept-list 'vector))))


(plot:plot
 (vega:defplot acc-plot
   `(:title "Acceptance rate over step size"
     :data ,acc-df
     :mark :line
     :encoding (:x (:field :step-size
		            :type  :quantitative)
		        :y (:field :acceptance
		            :type  :quantitative)))))

(setq output-list (metropolice (lambda (x) (distributions:pdf normal-dist x)) 0.5 10000))

(setq data-metro-list (nth 0 output-list))
(setq data-len (nth 1 output-list))

(setq ac-list (make-list 1 :initial-element 1.0))
(setq lag-list (make-list 1 :initial-element 0.0))

(loop for lag from 2 to 100 do

  (push (auto-cor data-metro-list data-len lag) ac-list)
  (push lag lag-list)

)


(setq auto-df (make-df '(:lag :auto) (list (coerce lag-list 'vector) (coerce ac-list 'vector))))

(plot:plot
 (vega:defplot acc-plot
   `(:title "Autocorrlation for alpha = 0.907"
     :data ,auto-df
     :mark :line
     :encoding (:x (:field :lag
		            :type  :quantitative)
		        :y (:field :auto
		            :type  :quantitative)))))


(setq step-len-ac '(0.5 1.0 1.6 2.2 2.89 3.79 4.9 7.89 16.20))
(setq cor-len '())

(loop for step-l in step-len-ac do

    (setq output-list (metropolice (lambda (x) (distributions:pdf normal-dist x)) step-l 10000))
    (setq data-metro-list (nth 0 output-list))
    (setq data-len (nth 1 output-list))
    (loop for lag from 2 to 100 do
        (if (> (auto-cor data-metro-list data-len lag) 0.367879) then

          (progn (push lag cor-len)
                  (return)
          )
        )
    )
)

(write cor-len)

