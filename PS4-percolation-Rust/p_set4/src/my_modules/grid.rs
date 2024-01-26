// This file defines Grid structs and some usefull methods for it. 



use array2d::Array2D;       // For fast 2D arrays
use rand::{Rng, SeedableRng};
use rand::rngs::SmallRng;   // Fast seedable rng
use std::cmp;
// use rayon::prelude::*;      // Rayon parallelization crate


// Grid struct
pub struct Grid {
    pub size: usize,
    pub space: Array2D<u64>,
    pub colors: Array2D<u64>,
    pub s_array: Vec<usize>, 
    pub l_array: Vec<usize>,
    pub percolated: Option<bool>,
    seed: u64,
    pub grid_rng: SmallRng      // We save our rng in the struct
}


// Grid methods
impl Grid {
    
    // Creates an empty grid
    pub fn new_grid(grid_size: usize) -> Grid {

        let seed = SmallRng::from_entropy().gen();   // Using random seed for new instances
        let rng = SmallRng::seed_from_u64(seed);
        let empty_space = Array2D::filled_with(0, grid_size, grid_size);
        let empty_colors =  Array2D::filled_with(0, grid_size, grid_size);

        Grid { size: grid_size, space: empty_space
                , colors: empty_colors
                , s_array: Vec::new(), l_array: Vec::new(), percolated: None, seed
                , grid_rng: rng}
    }

    // Sets a custom seed
    pub fn set_seed(&mut self, seed: u64){

        self.seed = seed;
        self.grid_rng = SmallRng::seed_from_u64(seed);
    }

    pub fn get_seed(&self) -> u64 {

        self.seed
    }

    // Makes the grid randomized with probability p
    pub fn randomize_grid(&mut self, p: f64){

        for i in 0..self.size {
            for j in 0..self.size {
                let random_num: f64 = self.grid_rng.gen();
                self.space[(i, j)] = if random_num <= p {1} else {0};
            }
        }
    }

    pub fn coloring(&mut self){     // Coloring algorithm
        
        for i in 0..self.size {
            
            self.colors[(i, 0)] = 1;
        }

        let mut m_color = 2;    // The greatest color index

        for j in 1..self.size {
            for i in 0..self.size {
                if self.space[(i, j)] == 1 {
                    self.colors[(i, j)] = m_color;
                    if self.check_around(i, j) {} else {m_color = m_color + 1}; 
                }
            }
        }
    }

    pub fn check_around(&mut self, i:usize, j:usize) -> bool{     // Looks around in the coloring algorithm and changes colors, returns true if did

        let left_nigh = self.colors[(i, j - 1)];
        let up_nigh = if i != 0 {self.colors[(i - 1, j)]} else {0};
        let mut changed = false;

        if up_nigh !=0 {

            if left_nigh !=0 {

                if left_nigh < up_nigh {

                    self.colors[(i, j)] = left_nigh;
                    self.color_hunter(up_nigh, left_nigh, j);
                }
                else if up_nigh < left_nigh {

                    self.colors[(i, j)] = up_nigh;
                    self.color_hunter(left_nigh, up_nigh, j);
                } 
                else {
                    self.colors[(i, j)] = up_nigh;
                }

            }
            else{

                self.colors[(i, j)] = up_nigh;
            }
            
            changed = true;

        } 
        else if left_nigh !=0 {

            self.colors[(i, j)] = left_nigh;
            changed = true;
        }

        changed

    }


    pub fn color_hunter(&mut self, old_c: u64, new_c:u64,last_j:usize) {     // Hunts spaces with (old_c) color and replaces them with (new_c)            
        
            for i in 0..self.size {
                for j in 0..last_j + 1 {
                    
                    if  self.colors[(i, j)] == old_c {

                        self.colors[(i, j)] = new_c;
                    } 
                }
            }            
    }

    pub fn is_percolated(&mut self){

        let mut is_percolated = false;
        for i in 0..self.size {

            if self.colors[(i, self.size-1)] == 1 {
                is_percolated = true;
                break;
            }
        }

        self.percolated = Some(is_percolated);
    }

    pub fn hk_coloring(&mut self, full_coloring:bool){     // HK Coloring algorithm
        
        for i in 0..self.size {
            
            self.colors[(i, 0)] = 1;
        }

        self.l_array.push(0);   // Label 0 for 0
        self.s_array.push(0);
        self.l_array.push(1);   // Label 1 for 1
        self.s_array.push(self.size);    // Label 1 has size of L
        let mut m_color = 2;    // The greatest color index

        for j in 1..self.size {
            for i in 0..self.size {
                if self.space[(i, j)] == 1 {
                    self.colors[(i, j)] = m_color;
                    if self.hk_check_around(i, j, m_color) {} else {m_color = m_color + 1}; 
                }
            }
        }


        if full_coloring {

            for i in 0..self.size {
                for j in 0..self.size {
                    
                    self.colors[(i, j)] =  self.hk_find(self.colors[(i, j)] as usize) as u64;
                }
            }
        }
    }

    pub fn hk_check_around(&mut self, i:usize, j:usize, m_color: u64) -> bool{     // Looks around in the coloring algorithm and changes colors, returns true if did

        // We associate labels and root labels instead of colors 
        let left_nigh = self.l_array[self.colors[(i, j - 1)] as usize];
        let up_nigh = self.l_array[if i != 0 {self.colors[(i - 1, j)]} else {0} as usize];
        let left_nigh_label = self.hk_find(left_nigh);
        let up_nigh_label = self.hk_find(up_nigh);
        let mut changed = false;

        if up_nigh_label !=0 {

            if left_nigh_label !=0 && left_nigh_label != up_nigh_label {

                let root_label = cmp::min(left_nigh_label, up_nigh_label);
                let sub_label = cmp::max(left_nigh_label, up_nigh_label);
                self.colors[(i, j)] = root_label as u64;

                // Let's destroy the sub one!
                self.hk_union(root_label, sub_label);
                self.s_array[root_label] += self.s_array[sub_label] + 1;
                self.s_array[sub_label] = 0;
                
            }
            else{

                self.colors[(i, j)] = up_nigh_label as u64;
                self.s_array[up_nigh_label] += 1;
            }
            
            changed = true;

        } 
        else if left_nigh_label !=0 {

            self.colors[(i, j)] = left_nigh_label as u64;
            self.s_array[left_nigh_label] += 1;
            changed = true;
        }
        else {

            self.l_array.push(m_color as usize);
            self.s_array.push(1);
        }

        changed

    }

    fn hk_find(&mut self, label:usize) -> usize{

        let mut new_label =  label;

        while self.l_array[new_label] != new_label {
            new_label = self.l_array[new_label];
        }

        return new_label;
    }
    
    fn hk_union(&mut self, root_label:usize, sub_label:usize){

        self.l_array[sub_label] = root_label;
    }

}
