#include <cstddef>
#include <iostream>
#include <tuple>
#include <vector>
#include <string>
#include <math.h>
#include "boost/tuple/tuple.hpp"
#include "gnuplot-iostream.h"

// Calling our lovely friend, std
using namespace std;


// Transformation functions
vector<tuple<double, double>> func1(vector<tuple<double, double>> points, double L);
vector<tuple<double, double>> func2(vector<tuple<double, double>> points, double L);
vector<tuple<double, double>> func3(vector<tuple<double, double>> points, double L);
vector<tuple<double, double>> func4(vector<tuple<double, double>> points, double L);

int main(){

    // GUN PLOT POG!
    Gnuplot gp;
    string title, output;

    int N; // Number of steps 

    // Comfy space for our outputs
    vector<tuple<double, double>> points;
    vector<tuple<double, double>> output_points_1;
    vector<tuple<double, double>> output_points_2;
    vector<tuple<double, double>> output_points_3;
    vector<tuple<double, double>> output_points_4;

    // Initial points
    points.push_back(make_tuple(0.0, 0.0));
    points.push_back(make_tuple(1.0, 0.0));
    
    cout<<"Enter the order (N): \n";
    cin>>N;
    title = " \" Koch Fractal N = " + to_string(N) + "\" ";
    output = " \" P1-Koch-N=" + to_string(N) + ".png\" ";

    // Making a fractal with N steps
    for (int i = 1; i<=N; i++){

    output_points_1 = func1(points, 1.0/3.0);
    output_points_2 = func2(points, 1.0/3.0);
    output_points_3 = func3(points, 1.0/3.0);
    output_points_4 = func4(points, 1.0/3.0);

    points = output_points_1;
    points.insert(end(points), begin(output_points_2), end(output_points_2));
    points.insert(end(points), begin(output_points_3), end(output_points_3));
    points.insert(end(points), begin(output_points_4), end(output_points_4));
    }

    // Ploting and exportnig
    gp << "set xrange[-0.125:1.125] \n set yrange[-0.25:1] \n";
    gp << "set size square \n";
    gp << "set title" << title <<"\n";
    gp << "set output" << output << "\n"; // Comment this line and the next for plot only mode
    gp << "set terminal pngcairo size 5000, 5000 fontscale 10 linewidth 1.8 pointscale 1\n";
    gp << "plot '-' with lines title \"\" \n";
    gp.send1d(points);
    return 0;
}
 
vector<tuple<double, double>> func1(vector<tuple<double, double>> points, double L){

    vector<tuple<double, double>> new_points;
    double x,y;

    for (int i = 0; i<points.size(); i++){
        x = get<0>(points[i]) / 3.0 ;
        y = get<1>(points[i]) / 3.0 ;
        new_points.push_back(make_tuple(x, y));
        
    }

    return new_points;
}

vector<tuple<double, double>> func2(vector<tuple<double, double>> points, double L){

    vector<tuple<double, double>> new_points;
    double x,y;

    for (int i = 0; i<points.size(); i++){
        x = (1.0 / 2.0) * (get<0>(points[i]) / 3.0)  - (sqrt(3) / 2.0) * (get<1>(points[i]) / 3.0) + L;
        y = (sqrt(3) / 2.0) * (get<0>(points[i]) / 3.0)  + (1.0 / 2.0) * (get<1>(points[i]) / 3.0);
        new_points.push_back(make_tuple(x, y));
        
    }

    return new_points;
}

vector<tuple<double, double>> func3(vector<tuple<double, double>> points, double L){

    vector<tuple<double, double>> new_points;
    double x,y;

    for (int i = 0; i<points.size(); i++){
        x = (1.0 / 2.0) * (get<0>(points[i]) / 3.0)  + (sqrt(3) / 2.0) * (get<1>(points[i]) / 3.0) + 3*L/2;
        y = -(sqrt(3) / 2.0) * (get<0>(points[i]) / 3.0)  + (1.0 / 2.0) * (get<1>(points[i]) / 3.0) + (sqrt(3) / 2.0) *L;
        new_points.push_back(make_tuple(x, y));
        
    }

    return new_points;
}

vector<tuple<double, double>> func4(vector<tuple<double, double>> points, double L){

    vector<tuple<double, double>> new_points;
    double x,y;

    for (int i = 0; i<points.size(); i++){
        x = get<0>(points[i]) / 3.0 + 2*L;
        y = get<1>(points[i]) / 3.0 ;
        new_points.push_back(make_tuple(x, y));
        
    }

    return new_points;
}