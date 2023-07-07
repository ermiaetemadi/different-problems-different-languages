# Helper functions for Makie plots


module CMplot

using CairoMakie, GLMakie
using Makie.GeometryBasics
GLMakie.activate!()

export *

function ShowSystem(Space, res)
    
    L = Space.L
    f = Figure(resolution = (res, res))
    ms = 1*res/(1.2L)
    axi = Axis(f[1, 1]; aspect = 1.0)
    xlims!(axi, [-0.1L, 1.1L])
    ylims!(axi, [-0.1L, 1.1L])
    x_array = Space.pos[1, :]
    y_array = Space.pos[2, :]
    
    scatter!(axi, x_array, y_array, markersize = ms, marker = Circle)
    
    border = Polygon(
        Point2f[(-1.11, -1.11), (L+1.11, -1.11), (L+1.11, L+1.11), (-1.11, L+1.11)],
        [Point2f[(-0.9, -0.9), (L+0.9, -0.9), (L+0.9, L+0.9), (-0.9, L+0.9)]]
    )
    poly!(border, color = :black)
    f

end

function AnimateSystem(Space, pos_list, name::String; fps = 30, show_trace = false)

    L = Space.L
    steps = size(pos_list)[3]
    res = 800
    f = Figure(resolution = (res, res))
    ms = 1*res/(1.2L)

    axi = Axis(f[1, 1]; aspect = 1.0)
    xlims!(axi, [-0.1L, 1.1L])
    ylims!(axi, [-0.1L, 1.1L])

    points = Observable(Point2f[(0, 0)])
    traces = Observable(Point2f[(0, 0)])

    scatter!(axi, points, markersize = ms, marker = Circle)
    if show_trace 
        scatter!(axi, traces, markersize = ms/20, marker = Circle)
    end

    
    border = Polygon(
        Point2f[(-1.11, -1.11), (L+1.11, -1.11), (L+1.11, L+1.11), (-1.11, L+1.11)],
        [Point2f[(-0.9, -0.9), (L+0.9, -0.9), (L+0.9, L+0.9), (-0.9, L+0.9)]]
    )
    poly!(border, color = :black)
    

    record(f, "results/anim/" * name * ".mp4", 1:steps; framerate = fps) do k
        points[] = Point2f.(pos_list[1, :, k], pos_list[2, :, k])
        if show_trace
            traces[] = append!(traces[], Point2f.(pos_list[1, :, k], pos_list[2, :, k]))
        end
    end
    
end
end