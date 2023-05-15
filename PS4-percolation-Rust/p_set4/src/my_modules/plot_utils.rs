// This file is from github.com/plotters-rs/plotters/blob/master/plotters/examples, I added some helpful functions


use plotters::prelude::*;
use array2d::Array2D;


pub fn imgshow(array_in: &Array2D<u64>,x_range:(i32, i32), y_range:(i32, i32), title:&String, out_file:&String, color_gen: &dyn Fn(u64) -> HSLColor) -> Result<(), Box<dyn std::error::Error>> {

    let out_file_path = String::from("outputs/img/") + out_file + &String::from(".png");

    let root = BitMapBackend::new(&out_file_path, (1800, 1800)).into_drawing_area();

    root.fill(&WHITE)?;

    let mut chart = ChartBuilder::on(&root)
        .caption(title, ("New Roman Times", 70))
        .margin(5)
        .top_x_label_area_size(40)
        .y_label_area_size(40)
        .build_cartesian_2d(x_range.0..x_range.1, y_range.0..y_range.1)?;

    chart
        .configure_mesh()
        .x_labels(15)
        .y_labels(15)
        .max_light_lines(4)
        .x_label_offset(35)
        .y_label_offset(25)
        .disable_x_mesh()
        .disable_y_mesh()
        .disable_x_axis()
        .disable_y_axis()
        .label_style(("New Roman Times", 15))
        .draw()?;

    let matrix = array_in.as_rows();

    chart.draw_series(
        matrix
            .iter()
            .zip(0..)
            .map(|(l, y)| l.iter().zip(0..).map(move |(v, x)| (x as i32, y as i32, v)))
            .flatten()
            .map(|(x, y, v)| {
                Rectangle::new(
                    [(x, y), (x + 1, y + 1)],
                    color_gen(*v)
                    .filled(),
                )
            }),
    )?;

    // To avoid the IO failure being ignored silently, we manually call the present function
    root.present().expect("Unable to write result to file, please make sure 'plotters-doc-data' dir exists under current dir");
    println!("Result has been saved to {}", out_file_path);

    Ok(())
}

pub fn show_grid(array_in: &Array2D<u64>, grid_size: usize, name: &String, highlight: u64){       // I wrote this one!

    let isize: i32 = grid_size.try_into().unwrap();
    let h_diff = if highlight != 0 {1.0} else {0.0};          // We can highlight the percolation if highlight = true

    let color_gen = |x:u64| -> HSLColor { HSLColor(     // We can control our coloring system
        (1.0 / 20.0) * (((7*x + 13)%20) as f64),        // This numbers are just for tunning the colors
        0.8,
        0.0 + 0.4 * if x >= 1  {1.0} else {0.0} + 0.5 * if x == highlight {h_diff} else {-h_diff / 2.0}) };

    imgshow(&array_in, (0, isize), (0, isize), &name, &name, &color_gen).unwrap();
}