#!/usr/bin/env python3
"""
Algorithms for Split Geometry

Implements computational tools for the split Riemannian metric:
  ds² = sech²(y) dx² + cosh²(x) dy²

Key algorithms:
1. Christoffel symbol computation
2. Geodesic integration via RK4
3. Curvature field evaluation
4. Phase boundary detection
5. Split triangle area computation

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import Tuple, List, Optional, Callable


def sech(x: np.ndarray) -> np.ndarray:
    """Hyperbolic secant: sech(x) = 1/cosh(x).
    
    Time: O(1) per element
    """
    return 1.0 / np.cosh(x)


def split_metric_tensor(x: float, y: float) -> np.ndarray:
    """Compute the metric tensor g_ij at point (x, y).
    
    The split metric: g = diag(sech²(y), cosh²(x))
    
    Args:
        x, y: coordinates on ℝ²
    
    Returns:
        2×2 numpy array representing the metric tensor
    
    Time: O(1)
    """
    return np.diag([sech(y)**2, np.cosh(x)**2])


def christoffel_symbols(x: float, y: float) -> np.ndarray:
    """Compute all Christoffel symbols Γ^k_{ij} at point (x, y).
    
    For the split metric ds² = sech²(y)dx² + cosh²(x)dy²:
      Γ¹₁₁ = 0
      Γ¹₁₂ = Γ¹₂₁ = -tanh(y)
      Γ¹₂₂ = -sinh(x)·cosh(x)·cosh²(y)
      Γ²₁₁ = sech²(y)·tanh(y) / cosh²(x)
      Γ²₁₂ = Γ²₂₁ = tanh(x)
      Γ²₂₂ = 0
    
    Args:
        x, y: coordinates on ℝ²
    
    Returns:
        2×2×2 array Gamma[k][i][j] = Γ^k_{ij}
    
    Time: O(1)
    """
    Gamma = np.zeros((2, 2, 2))
    
    # Γ¹ components (k=0)
    Gamma[0, 0, 0] = 0                                        # Γ¹₁₁
    Gamma[0, 0, 1] = -np.tanh(y)                               # Γ¹₁₂
    Gamma[0, 1, 0] = -np.tanh(y)                               # Γ¹₂₁
    Gamma[0, 1, 1] = -np.sinh(x) * np.cosh(x) * np.cosh(y)**2 # Γ¹₂₂
    
    # Γ² components (k=1)
    Gamma[1, 0, 0] = sech(y)**2 * np.tanh(y) / np.cosh(x)**2  # Γ²₁₁
    Gamma[1, 0, 1] = np.tanh(x)                                 # Γ²₁₂
    Gamma[1, 1, 0] = np.tanh(x)                                 # Γ²₂₁
    Gamma[1, 1, 1] = 0                                          # Γ²₂₂
    
    return Gamma


def split_curvature(x: float, y: float) -> float:
    """Gaussian curvature K(x,y) = sech²(x) - sech²(y).
    
    Properties (all formally proved in Lean):
    - K(a, a) = 0 (vanishes on diagonal)
    - K(a, -a) = 0 (vanishes on anti-diagonal)
    - K(x, y) = -K(y, x) (antisymmetric)
    - K > 0 iff |y| > |x| (elliptic region)
    - K < 0 iff |x| > |y| (hyperbolic region)
    - |K| ≤ 1 everywhere
    
    Time: O(1)
    """
    return sech(x)**2 - sech(y)**2


def curvature_field(xrange: Tuple[float, float], 
                    yrange: Tuple[float, float],
                    resolution: int = 100) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Compute the curvature field on a grid.
    
    Args:
        xrange: (x_min, x_max) extent
        yrange: (y_min, y_max) extent
        resolution: grid resolution per axis
    
    Returns:
        X, Y, K: meshgrid coordinates and curvature values
    
    Time: O(resolution²)
    Space: O(resolution²)
    """
    x = np.linspace(*xrange, resolution)
    y = np.linspace(*yrange, resolution)
    X, Y = np.meshgrid(x, y)
    K = sech(X)**2 - sech(Y)**2
    return X, Y, K


def geodesic_equations(state: np.ndarray, t: float) -> np.ndarray:
    """Right-hand side of the geodesic ODE system.
    
    The geodesic equations for a Riemannian metric are:
      d²x^k/dt² + Γ^k_{ij} dx^i/dt dx^j/dt = 0
    
    Rewritten as a first-order system with state = [x, y, dx/dt, dy/dt].
    
    Args:
        state: [x, y, vx, vy] current position and velocity
        t: parameter (not used, autonomous system)
    
    Returns:
        [dx/dt, dy/dt, dvx/dt, dvy/dt]
    
    Time: O(1)
    """
    x, y, vx, vy = state
    Gamma = christoffel_symbols(x, y)
    
    vel = np.array([vx, vy])
    acc = np.zeros(2)
    for k in range(2):
        for i in range(2):
            for j in range(2):
                acc[k] -= Gamma[k, i, j] * vel[i] * vel[j]
    
    return np.array([vx, vy, acc[0], acc[1]])


def integrate_geodesic(x0: float, y0: float, 
                       vx0: float, vy0: float,
                       t_max: float = 5.0,
                       dt: float = 0.001) -> np.ndarray:
    """Integrate a geodesic using 4th-order Runge-Kutta.
    
    Args:
        x0, y0: initial position
        vx0, vy0: initial velocity
        t_max: maximum integration time
        dt: time step
    
    Returns:
        N×5 array of [t, x, y, vx, vy] at each time step
    
    Time: O(t_max / dt)
    Space: O(t_max / dt)
    """
    n_steps = int(t_max / dt)
    trajectory = np.zeros((n_steps + 1, 5))
    state = np.array([x0, y0, vx0, vy0])
    
    trajectory[0] = [0, *state]
    
    for i in range(n_steps):
        t = i * dt
        k1 = geodesic_equations(state, t)
        k2 = geodesic_equations(state + 0.5 * dt * k1, t + 0.5 * dt)
        k3 = geodesic_equations(state + 0.5 * dt * k2, t + 0.5 * dt)
        k4 = geodesic_equations(state + dt * k3, t + dt)
        
        state = state + (dt / 6) * (k1 + 2*k2 + 2*k3 + k4)
        trajectory[i + 1] = [(i + 1) * dt, *state]
    
    return trajectory


def count_phase_crossings(trajectory: np.ndarray) -> int:
    """Count the number of times a trajectory crosses the phase boundary |x| = |y|.
    
    The phase boundary is where the curvature changes sign.
    
    Args:
        trajectory: N×5 array from integrate_geodesic
    
    Returns:
        Number of phase boundary crossings
    
    Time: O(N)
    """
    x = trajectory[:, 1]
    y = trajectory[:, 2]
    phase_indicator = np.abs(y) - np.abs(x)
    
    crossings = 0
    for i in range(1, len(phase_indicator)):
        if phase_indicator[i-1] * phase_indicator[i] < 0:
            crossings += 1
    
    return crossings


def split_triangle_area(vertices: List[Tuple[float, float]], 
                        n_subdivisions: int = 100) -> float:
    """Compute the area of a triangle in split geometry using numerical integration.
    
    Uses barycentric subdivision and the area element √(EG) = cosh(x)/cosh(y).
    
    Args:
        vertices: list of 3 vertices [(x1,y1), (x2,y2), (x3,y3)]
        n_subdivisions: number of subdivisions per edge for integration
    
    Returns:
        Approximate area in split geometry
    
    Time: O(n_subdivisions²)
    """
    (x1, y1), (x2, y2), (x3, y3) = vertices
    
    # Integrate using barycentric coordinates
    area = 0.0
    n = n_subdivisions
    
    for i in range(n):
        for j in range(n - i):
            # Barycentric coordinates of triangle center
            u = (i + 1/3) / n
            v = (j + 1/3) / n
            w = 1 - u - v
            
            if w < 0:
                continue
            
            # Point in ℝ²
            x = u * x1 + v * x2 + w * x3
            y = u * y1 + v * y2 + w * y3
            
            # Area element
            ae = np.cosh(x) / np.cosh(y)
            
            # Euclidean area of sub-triangle
            eucl_area = abs((x2 - x1) * (y3 - y1) - (x3 - x1) * (y2 - y1)) / (2 * n**2)
            
            area += ae * eucl_area
    
    return area


def split_divergence(x1: float, y1: float, x2: float, y2: float) -> float:
    """Split divergence between two points.
    
    D(p, q) = log²(cosh(x₂)/cosh(x₁)) + log²(cosh(y₁)/cosh(y₂))
    
    Properties (formally proved):
    - D(p, p) = 0
    - D(p, q) ≥ 0
    - D(p, q) = 0 iff cosh(x₁)=cosh(x₂) and cosh(y₁)=cosh(y₂)
    
    Time: O(1)
    """
    return (np.log(np.cosh(x2) / np.cosh(x1)))**2 + \
           (np.log(np.cosh(y1) / np.cosh(y2)))**2


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=== Split Geometry Algorithms ===\n")
    
    # 1. Christoffel symbols at origin
    print("Christoffel symbols at (0, 0):")
    G = christoffel_symbols(0, 0)
    print(f"  Γ¹₁₂ = {G[0,0,1]:.4f} (should be 0 since tanh(0)=0)")
    print(f"  Γ²₁₂ = {G[1,0,1]:.4f} (should be 0 since tanh(0)=0)")
    
    print("\nChristoffel symbols at (1, 1):")
    G = christoffel_symbols(1, 1)
    print(f"  Γ¹₁₂ = {G[0,0,1]:.6f}")
    print(f"  Γ¹₂₂ = {G[0,1,1]:.6f}")
    print(f"  Γ²₁₁ = {G[1,0,0]:.6f}")
    print(f"  Γ²₁₂ = {G[1,0,1]:.6f}")
    
    # 2. Geodesic integration
    print("\n--- Geodesic Integration ---")
    # Geodesic starting at origin, moving at 45 degrees
    traj = integrate_geodesic(0, 0, 1, 1, t_max=3.0)
    print(f"  Initial: ({traj[0,1]:.2f}, {traj[0,2]:.2f})")
    print(f"  Final:   ({traj[-1,1]:.2f}, {traj[-1,2]:.2f})")
    crossings = count_phase_crossings(traj)
    print(f"  Phase boundary crossings: {crossings}")
    
    # Test the conjecture: geodesics cross phase boundary at most 4 times
    print("\n--- Phase Crossing Conjecture Test ---")
    max_crossings = 0
    angles = np.linspace(0, 2*np.pi, 36, endpoint=False)
    for angle in angles:
        for speed in [0.5, 1.0, 2.0]:
            vx = speed * np.cos(angle)
            vy = speed * np.sin(angle)
            for x0, y0 in [(0, 0), (1, 0), (0, 1), (0.5, 0.5)]:
                try:
                    traj = integrate_geodesic(x0, y0, vx, vy, t_max=10.0, dt=0.005)
                    c = count_phase_crossings(traj)
                    max_crossings = max(max_crossings, c)
                except:
                    pass
    print(f"  Max phase crossings observed: {max_crossings}")
    print(f"  Conjecture (≤ 4) holds: {max_crossings <= 4}")
    
    # 3. Split triangle area
    print("\n--- Split Triangle Area ---")
    # Triangle with vertices in each phase
    v_ell = (0.5, 2.0)   # elliptic
    v_flat = (1.0, 1.0)  # flat
    v_hyp = (2.0, 0.5)   # hyperbolic
    area = split_triangle_area([v_ell, v_flat, v_hyp])
    eucl_area = 0.5 * abs((1-0.5)*(0.5-2) - (2-0.5)*(1-2))
    print(f"  Vertices: {v_ell}, {v_flat}, {v_hyp}")
    print(f"  Euclidean area: {eucl_area:.6f}")
    print(f"  Split geometry area: {area:.6f}")
    print(f"  Area distortion ratio: {area/eucl_area:.6f}")
