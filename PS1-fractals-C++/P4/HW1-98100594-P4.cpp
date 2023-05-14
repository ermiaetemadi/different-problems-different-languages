#include <cstddef>
#include <iostream>
#include <iterator>
#include <tuple>
#include <vector>
#include <string>
#include <math.h>
#include "boost/tuple/tuple.hpp"
#include "gnuplot-iostream.h"

// Calling our lovely friend, std
using namespace std;

// Combination function r of P
int combination_calc(int r, int P);

// Converts r and P to cordinates 
tuple<double, double> rn_to_cord(int N, int r, int P);

// Drawing an square
vector<tuple<double, double>> make_square(tuple<double, double> center, double L);

// Creates the whole Khayyam-Pascal Triangle
vector<tuple<double, double>> make_KPT(int N);


int main(){

    // GUN PLOT POG!
    Gnuplot gp;
    string title, output, plot_command;

    int N; // Size
    int counter; // Some counter!

    // Comfy space for our outputs
    vector<tuple<double, double>> points, slice;

    
    cout<<"Enter the order (N): \n";
    cin>>N;
    
    title = " \" Khayyam-Pascal Triangle N = " + to_string(N) + "\" ";
    output = " \" P4-Khayyam-Pascal-Triangle-N=" + to_string(N) + ".png\" ";
    string sqr_command = " '-' with filledcurves fillstyle solid fillcolor black title \"\" "; // ugly gnuplot syntax again
    plot_command = sqr_command;

    points = make_KPT(N);
    int sqr_num = points.size() / 5;

    for(int i=2; i<=sqr_num; i++){                        // We use an ugly syntax of gnuplot to draw filled squares
        plot_command = plot_command + "," + sqr_command ;
    }


    // Ploting and exportnig
    gp << "set xrange[-0.75:0.75] \n set yrange[-0.75:0.75] \n";
    gp << "set size ratio 1 \n";
    gp << "set title" << title <<"\n";
    gp << "set output" << output << "\n"; // Comment this line and the next for plot only mode
    gp << "set terminal pngcairo size 5000, 5000 fontscale 10 linewidth 1.8 pointscale 1\n";
    gp << "plot" << plot_command<<"\n";

    for (int i=1; i<=sqr_num; i++ ){
        counter = 5*(i-1);
        slice = vector<tuple<double, double>>(points.begin()+counter, points.begin()+counter+4);  // Making every slice and sending it into gnuplot
        gp.send1d(slice);
    }
    return 0;
}
 


int combination_calc(int r, int N){     // We calculate combinations in a recursive fashion
    
    if (r > N /2){
        r = N - r;
    }
    
    if (r > N){
        return 0;
    }

    if (r == 0){
        return 1;
        
    }


    return combination_calc(r, N - 1) + combination_calc(r - 1, N -1);

}

tuple<double, double> rn_to_cord(int N, int r, int P){

    double x, y;
    double a = 1.0 / N;     // Unit length
    x = (r - (double)P / 2) * a;
    y = ((double)N /2 - P) * a;

    return make_tuple(x, y);
}

vector<tuple<double, double>> make_square(tuple<double, double> center, double L){

    double a = L/2.0;                // a = half of the square edge length
    double cx = get<0>(center);     // Center x and y components
    double cy = get<1>(center);
    vector<tuple<double, double>> square_points;    // Square points!
    
    square_points.push_back(make_tuple(cx - a, cy - a));
    square_points.push_back(make_tuple(cx + a, cy - a));
    square_points.push_back(make_tuple(cx + a, cy + a));
    square_points.push_back(make_tuple(cx - a, cy + a));
    square_points.push_back(make_tuple(cx - a, cy - a));

    return square_points;
}

vector<tuple<double, double>> make_KPT(int N){

    vector<tuple<double, double>> points, new_square;

    double a = 1.0 / N;     // Unit length
    int rCP;        //Combination r of P

    for (int P = 0; P <= N; P++){
        for (int r = 0; r<=P; r++){
            rCP = combination_calc(r, P);

            if (rCP % 2 == 1){                                      // Checking if the rCP is odd
                new_square = make_square(rn_to_cord(N, r, P), a);   // making square points
                points.insert(end(points), begin(new_square), end(new_square));     // Adding it to points
            }
        }
    }

    return points;
}
