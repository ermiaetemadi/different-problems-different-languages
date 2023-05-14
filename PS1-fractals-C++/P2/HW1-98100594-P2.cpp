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

int main(){

    // GUN PLOT POG!
    Gnuplot gp;
    string title, output;

    int N,points_n;      // Number of steps 
    int index_0 = 0;    // An index shift only for N=0

    // Comfy space for our outputs
    vector<tuple<double, double>> points, slice;
    vector<tuple<double, double>> output_points_1;
    vector<tuple<double, double>> output_points_2;

    // Initial points
    points.push_back(make_tuple(0.0, 0.0));
    points.push_back(make_tuple(1.0/2.0, 1.0/2.0));
    points.push_back(make_tuple(1.0, 0.0));
    
    cout<<"Enter the order (N): \n";
    cin>>N;
    points_n = 3*pow(2, N);
    if (N == 0){
        index_0 = 1;
    }
    title = " \" Dragon Fractal N = " + to_string(N) + "\" ";
    output = " \" P2-Dragon-N=" + to_string(N) + ".png\" ";

    // Making a fractal with N steps
    for (int i = 1; i<=N; i++){

    output_points_1 = func1(points, 1.0/2.0);
    output_points_2 = func2(points, 1.0/2.0);

    points = output_points_1;
    points.insert(end(points), begin(output_points_2), end(output_points_2));
    }

    // Ploting and exportnig
    gp << "set xrange[-0.5:1.5] \n set yrange[-1:1] \n";
    gp << "set size ratio 1.0 \n";
    gp << "set title" << title <<"\n";
    gp << "set palette defined ( 0 \'blue\', 0.5 \'white\', 1 \'red\' ) \n";
    gp << "set output" << output << "\n"; // Comment this line and the next for plot only mode
    gp << "set terminal pngcairo size 5000, 5000 fontscale 10 linewidth 2.1 pointscale 1\n"; 

    // Now we draw two color parts seprately
    gp << "plot '-' with lines linecolor 1 title \"\" , '-' with lines linecolor 0 title \"\" \n";
    slice = vector<tuple<double, double>>(points.begin(), points.begin()+points_n/2+index_0);
    gp.send1d(slice);
    slice = vector<tuple<double, double>>(points.begin()+points_n/2, points.end());
    gp.send1d(slice);
    return 0;
}
 
vector<tuple<double, double>> func1(vector<tuple<double, double>> points, double L){

    vector<tuple<double, double>> new_points;
    double x,y;

    for (int i = 0; i<points.size(); i++){
        x = (sqrt(2) / 2.0) * (get<0>(points[i]) / sqrt(2))  - (sqrt(2) / 2.0) * (get<1>(points[i]) / sqrt(2));
        y = (sqrt(2) / 2.0) * (get<0>(points[i]) / sqrt(2))  + (sqrt(2) / 2.0) * (get<1>(points[i]) / sqrt(2));
        new_points.push_back(make_tuple(x, y));
        
    }

    return new_points;
}

vector<tuple<double, double>> func2(vector<tuple<double, double>> points, double L){

    vector<tuple<double, double>> new_points;
    double x,y;

    int i;
    for (int j = 0; j<points.size(); j++){
        i = points.size() - j -1;
        x = -(sqrt(2) / 2.0) * (get<0>(points[i]) / sqrt(2))  - (sqrt(2) / 2.0) * (get<1>(points[i]) / sqrt(2)) + 2*L;
        y = (sqrt(2) / 2.0) * (get<0>(points[i]) / sqrt(2))  - (sqrt(2) / 2.0) * (get<1>(points[i]) / sqrt(2));
        new_points.push_back(make_tuple(x, y));
        
    }

    return new_points;
}
