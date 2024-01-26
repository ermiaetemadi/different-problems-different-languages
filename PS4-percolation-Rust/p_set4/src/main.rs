// This is our main file

mod my_modules;     // We import our modules

use my_modules::grid::Grid;
use my_modules::plot_utils;
use std::time::Instant;
use std::io;

fn main() {

    
    
    // First we take inputs from user for L and p
    
    println!("Please enter L: ");
    let mut user_input = String::new();
    io::stdin().read_line(&mut user_input).unwrap();
    let size: usize = user_input.trim().parse().unwrap();
    
    println!("Please enter p: ");
    let mut user_input = String::new();
    io::stdin().read_line(&mut user_input).unwrap();
    let p: f64 = user_input.trim().parse().unwrap();
    

    // ----------------- Problem 1

    // p1_run(size, p, true);

    // ----------------- Problem 2

    // p2_run(size, p, true);

    // ----------------- Problem 3

    p3_run(size, p, true);




}

pub fn p1_run(size:usize, p:f64, bench: bool){    // Problem 1 function

    let now_time = Instant::now();      // Current time for benchmarking

    let mut my_grid = Grid::new_grid(size);
    // my_grid.set_seed(25);   // You can set custom seed here
    my_grid.randomize_grid(p);

    let elapsed_time = now_time.elapsed();
    if bench {println!("Program (p1) calculations run time: {} milliseconds", elapsed_time.as_millis())};
    let now_time = Instant::now();
    
    let title = String::from("Random grid with L=") + &size.to_string() + &String::from("  and p=") + &p.to_string();
    plot_utils::show_grid(&my_grid.space, my_grid.size, &title, 0);     // Ploting the grid

    let elapsed_time = now_time.elapsed();
    if bench {println!("Program (p1) ploting run time: {} milliseconds", elapsed_time.as_millis())};



}

pub fn p2_run(size:usize, p:f64, bench: bool){

    let now_time = Instant::now();      // Current time for benchmarking

    let mut my_grid = Grid::new_grid(size);
    my_grid.randomize_grid(p);

    // Now we color our grid and check for percolation
    my_grid.coloring();
    my_grid.is_percolated();

    let elapsed_time = now_time.elapsed();
    if bench {println!("Program (p2) calculations run time: {} milliseconds", elapsed_time.as_millis())};
    let now_time = Instant::now();
    
    let title = String::from("Random colored grid with L=") + &size.to_string() + &String::from("  and p=") + &p.to_string();
    plot_utils::show_grid(&my_grid.colors, my_grid.size, &title, 0);     // Ploting the grid
    plot_utils::show_grid(&my_grid.colors, my_grid.size, &(title + &String::from(" (highlighted)")), 1);     // Ploting the grid (highlighted!)
    
    let elapsed_time = now_time.elapsed();   
    if bench {println!("Program (p2) ploting run time: {} milliseconds", elapsed_time.as_millis())};

    match my_grid.percolated {

        Some(a) => println!("your grid precolation result: {}", a),
        None => println!("you haven't checked the percolation yet, idiot!")
        
    }

}


pub fn p3_run(size:usize, p:f64, bench: bool){

    let now_time = Instant::now();      // Current time for benchmarking

    let mut my_grid = Grid::new_grid(size);
    my_grid.randomize_grid(p);

    // Now we color our grid and check for percolation
    my_grid.hk_coloring(true);
    my_grid.is_percolated();

    let h_color = my_grid.colors[(0,0)];    // The color we need to highlight

    let elapsed_time = now_time.elapsed();
    if bench {println!("Program (p3) calculations run time: {} milliseconds", elapsed_time.as_millis())};
    let now_time = Instant::now();
    
    let title = String::from("Random colored grid (Hoshen-Keoplman) with L=") + &size.to_string() + &String::from("  and p=") + &p.to_string();
    plot_utils::show_grid(&my_grid.colors, my_grid.size, &title, 0);     // Ploting the grid
    plot_utils::show_grid(&my_grid.colors, my_grid.size, &(title + &String::from(" (h)")), h_color);     // Ploting the grid (highlighted!)
    
    let elapsed_time = now_time.elapsed();   
    if bench {println!("Program (p3) ploting run time: {} milliseconds", elapsed_time.as_millis())};

    match my_grid.percolated {

        Some(a) => println!("your grid precolation result: {}", a),
        None => println!("you haven't checked the percolation yet, idiot!")
        
    }

    // println!("Grid l_array: {:?}", my_grid.l_array);

    // println!("Grid s_array: {:?}", my_grid.s_array);

    

}


