// Here we defined our runners, which test percolation on a random grids with size L for many times 

use crate::Grid;

pub fn loop_random_grids(size:usize, p:f64, try_num:usize) -> f64{

    let mut prec_num = 0;   // Times percolation happened

    for _ in 0..try_num  {

        let mut my_grid = Grid::new_grid(size);
        my_grid.randomize_grid(p);

        // Now we color our grid and check for percolation
        my_grid.coloring();
        my_grid.is_percolated();

        match my_grid.percolated {

            Some(a) => prec_num = prec_num + if a {1} else {0},
            None => panic!("you haven't checked the percolation yet, idiot!")
            
        }
    }

    (prec_num as f64) / (try_num as f64)
}