#include <cmath>
#include <cstddef>
#include <cstdint>
#include <iostream>
#include <memory>
#include <tuple>
#include <vector>
#include <string>
#include <math.h>
#include "boost/tuple/tuple.hpp"
#include "gnuplot-iostream.h"


// Calling our lovely friend, std
using namespace std;


// Transformation functions
vector<tuple<double, double>> func1(vector<tuple<double, double>> points);
vector<tuple<double, double>> func2(vector<tuple<double, double>> points);
vector<tuple<double, double>> func3(vector<tuple<double, double>> points);

int main(){

    // GUN PLOT POG!
    Gnuplot gp;
    string title, output, plot_command;
    string tri_command = " '-' with filledcurves fillstyle solid fillcolor black title \"\" ";

    int N, triangles; // Number of steps 
    int counter; // Some counter!
    // Comfy space for our outputs
    vector<tuple<double, double>> points, slice;
    vector<tuple<double, double>> output_points_1;
    vector<tuple<double, double>> output_points_2;
    vector<tuple<double, double>> output_points_3;

    // Initial points
    points.push_back(make_tuple(0.0, 0.0));
    points.push_back(make_tuple(1.0/2.0, sqrt(3) / 2.0));
    points.push_back(make_tuple(1.0, 0.0));
    points.push_back(make_tuple(0.0, 0.0));
    
    
    cout<<"Enter the order (N): \n";
    cin>>N;

    title = " \" Sierpiński Fractal N = " + to_string(N) + "\" ";
    output = " \" P3-Sierpiński-N=" + to_string(N) + ".png\" ";
    plot_command = tri_command;
    
    triangles = pow(3,N);
    for(int i=2; i<=triangles; i++){                        // We use an ugly syntax of gnuplot to draw filled triangles
        plot_command = plot_command + "," + tri_command ;
    }

    // Making a fractal with N steps
    for (int i = 1; i<=N; i++){

    output_points_1 = func1(points);
    output_points_2 = func2(points);
    output_points_3 = func3(points);

    points = output_points_1;
    points.insert(end(points), begin(output_points_2), end(output_points_2));
    points.insert(end(points), begin(output_points_3), end(output_points_3));
    }

    // Ploting and exportnig
    gp << "set xrange[-0.125:1.125] \n set yrange[-0.25:1] \n";
    gp << "set size square \n";
    gp << "set title" << title <<"\n";
    gp << "set output" << output << "\n"; // Comment this line and the next for plot only mode
    gp << "set terminal pngcairo size 5000, 5000 fontscale 10 linewidth 1.8 pointscale 1\n";
    gp << "plot" << plot_command<<"\n";
    for (int i=1; i<=triangles; i++ ){
        counter = 4*(i-1);
        slice = vector<tuple<double, double>>(points.begin()+counter, points.begin()+counter+3);  // Making every slice and sending it into gnuplot
        gp.send1d(slice);
    }
    return 0;
}
 
vector<tuple<double, double>> func1(vector<tuple<double, double>> points){

    vector<tuple<double, double>> new_points;
    double x,y;

    for (int i = 0; i<points.size(); i++){
        x = get<0>(points[i]) / 2.0 ;
        y = get<1>(points[i]) / 2.0 ;
        new_points.push_back(make_tuple(x, y));
        
    }

    return new_points;
}

vector<tuple<double, double>> func2(vector<tuple<double, double>> points){

    vector<tuple<double, double>> new_points;
    double x,y;

    for (int i = 0; i<points.size(); i++){
        x = get<0>(points[i]) / 2.0 + 1.0/4.0  ;
        y = get<1>(points[i]) / 2.0 + sqrt(3) / 4.0 ;
        new_points.push_back(make_tuple(x, y));
        
    }

    return new_points;
}

vector<tuple<double, double>> func3(vector<tuple<double, double>> points){

    vector<tuple<double, double>> new_points;
    double x,y;

    for (int i = 0; i<points.size(); i++){
        x = get<0>(points[i]) / 2.0 + 1.0/2.0;
        y = get<1>(points[i]) / 2.0 ;
        new_points.push_back(make_tuple(x, y));
        
    }

    return new_points;
}
