# Molecular Dynamics simulations module

module  MDSim

export MDSpace, Init

using LinearAlgebra, Random, Distributions, .Threads, Statistics

mutable struct MDSpace

    N::Int64            # Number of particles
    L::Float64          # Box size
    pos::Matrix{Float64}
    vel::Matrix{Float64}
    acc::Matrix{Float64} # Accelerations
    h::Float64          # Step size
end
    
function Init(N, L, h, v₀max)
    
    pos = zeros(Float64,(2, N))
    vel = rand(2, N) * v₀max
    vel[1, :] = vel[1, :] .- mean(vel[1, :])     # We don't want any center of mass velocity
    vel[2, :] = vel[2, :] .- mean(vel[2, :])

    # We make and A*B grid for initial positions
    A = Int(ceil(√(N/2))) 
    ΔL = L / (2*A)        # Initial grid spacing      
    for i in 1:N
        pos[:, i] = ΔL * [mod(i-1, A) (i-1)÷A]
    end

    return MDSpace(N, L, pos, vel, zeros(Float64,(2, N)), h)
end


function evolve_step!(Space::MDSpace, force_func!)::Float64       # Evolve the system one step in time with velocity-verlet 
    h = Space.h
    Space.vel += 0.5 * h * Space.acc
    Space.pos += h * Space.vel
    
    
    Uₜ = force_func!(Space)        # Calculate new accelerations  
    
    Space.vel += 0.5 * h * Space.acc 

    return Uₜ
end

function nsteps!(Space::MDSpace, force_func!, steps::Int64)
    pos_list = zeros(Float64, (2, Space.N, steps))
    vel_list = zeros(Float64, (2, Space.N, steps))

    L_num = zeros(steps)

    Uₜ = 0.0
    KU_list = zeros(2, steps)
    PT_list = zeros(2, steps)

    for k in 1:steps
        pos_list[:, :, k] = Space.pos[:, :]
        vel_list[:, :, k] = Space.vel[:, :] 
        L_num[k] = count_side(Space)
        Uₜ = evolve_step!(Space, force_func!)
        K = calc_K(Space)
        KU_list[:, k] = [K, Uₜ]
        PT_list[:, k] = calc_PT(Space, K)

    end
    
    return pos_list, vel_list, L_num, KU_list, PT_list
end

@inline function apply_boundray(pos::Vector{Float64}, L)
    
    pos_inside = pos
    if pos[1] > L
        pos_inside[1] -= L
    elseif pos[1] < 0
        pos_inside[1] += L
    end

    if pos[2] > L
        pos_inside[2] -= L
    elseif pos[2] < 0
        pos_inside[2] += L
    end

    return pos_inside
end

function force_brownian_repulsive(Space::MDSpace, η, γ, μ)::Float64   # Brownian motion with inelastic collision
    
    N = Space.N
    L = Space.L
    h = Space.h
    Space.acc = zeros(2, N)
    for i in 1:N

        Space.pos[:, i] = apply_boundray(Space.pos[:, i], L)

        rand_vec = rand(Normal(0, 2),2) / 2
        Space.acc[:, i] += (rand_vec / norm(rand_vec)) * γ / h      # Random force
        Space.acc[:, i] += -μ * Space.vel[:,i] / h                  # Drag force (Drag deez nuts on your face) 

        for j in 1:i-1
            if norm(Space.pos[:, i] - Space.pos[:, j]) <= 1.0
                Δv = Space.vel[:, j] - Space.vel[:, i]
               Space.acc[:, i] += Δv * η / Space.h
               Space.acc[:, j] += -Δv * η/ Space.h
            end
        end
    end

    return 0.0
end

function force_lenard_jones(Space::MDSpace, cutoff::Float64)::Float64
    
    N = Space.N
    L = Space.L
    h = Space.h
    Space.acc = zeros(2, N)
    Uₜ = 0.0        # Total Potential

    for i in 1:N

        Space.pos[:, i] = apply_boundray(Space.pos[:, i], L)    # Perodic boundray condition in positions
        subspace = [2, 2].*(Space.pos[:, i].< [L/2, L/2]) - [1, 1]      # The quarter the ith particle is

        for j in 1:i-1
            
            Δr = Space.pos[:, j] - Space.pos[:, i]
            
            f = 0.0

            # Perodic boundray condition in forces
            if norm(Δr) < cutoff
                f, u = calc_lg_fxy(Δr)
                Uₜ += u    

            elseif (Δr = Space.pos[:, j] - Space.pos[:, i] - subspace.*[0, L]; norm(Δr)) < cutoff
                f, u = calc_lg_fxy(Δr)
                Uₜ += u

            elseif (Δr = Space.pos[:, j] - Space.pos[:, i] - subspace.*[L, 0]; norm(Δr)) < cutoff
                f, u = calc_lg_fxy(Δr)
                Uₜ += u

            elseif (Δr = Space.pos[:, j] - Space.pos[:, i] - subspace.*[L, L]; norm(Δr)) < cutoff
                f, u = calc_lg_fxy(Δr)
                Uₜ += u

                end

            Space.acc[:, i] += f*Δr
            Space.acc[:, j] += -f*Δr
        end
    end

    return Uₜ
end

function calc_lg_fxy(Δr)::Tuple{Float64, Float64}        # (Force)/|Δr| for particles with distance vector Δr
    r2 = 1/dot(Δr, Δr)
    r6 = r2^3
    r8 = r2 * r6
    r12 = r6 * r6
    r14 = r2 * r12
    return 4*(6*(r8) - 12*(r14)), 4*(1*(r12) - 1*(r6)) 
end

function count_side(Space::MDSpace)   # Counting how many of them are in the left side
    
    L = Space.L

    L_num = count(x -> x<=L/2, Space.pos[1, :])
    return L_num
end

@inline function calc_K(Space::MDSpace)    # Calculates Kinetic and Potential energy 
    
    return sum(Space.vel .^2) / 2 
end

function calc_PT(Space, K)
    
    T = K / Space.N
    Area = Space.L^2
    P = K / Area + (sum(Space.pos.*Space.acc)) / (3*Area)

    return [P, T]
end

function calc_auto_cor(vel_list, lag::Int64)
    
    N = size(vel_list)[2]
    steps = size(vel_list)[3]

    vel = vel_list[1, :, :].^2 + vel_list[2, :, :].^2
    vel_shift = circshift(vel, (0, lag))

    v_mean  = [mean(vel[i, :]) for i in 1:N]
    v_var = [varm(vel[i, :], v_mean[i]) for i in 1:N]

    cor_num = [sum((vel[i, :] .- v_mean[i]).*(vel_shift[i, :] .- v_mean[i])) for i in 1:N]

    return mean(cor_num ./ (steps*v_var))

end

end
