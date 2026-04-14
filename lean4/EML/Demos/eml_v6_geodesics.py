#!/usr/bin/env python3
"""
EML Geodesics and Gradient Flow Explorer
==========================================
Computes geodesics under the EML-induced Riemannian metric
ds² = exp(x) dx² + (1/y²) dy²

This metric arises from the Hessian of the EML operator,
making it a natural geometry for EML optimization.
"""

import math

def eml_metric_coefficients(x, y):
    """Return the Riemannian metric coefficients g_xx, g_yy."""
    return math.exp(x), 1.0 / y**2

def eml_christoffel(x, y):
    """Compute Christoffel symbols for the EML metric.

    For diagonal metric g = diag(e^x, 1/y²):
    Γ^x_xx = (1/2) g^xx ∂g_xx/∂x = 1/2
    Γ^x_yy = -(1/2) g^xx ∂g_yy/∂x = 0
    Γ^y_yy = (1/2) g^yy ∂g_yy/∂y = -1/y
    Γ^y_xx = -(1/2) g^yy ∂g_xx/∂y = 0
    Γ^x_xy = (1/2) g^xx ∂g_xx/∂y = 0
    Γ^y_xy = (1/2) g^yy ∂g_yy/∂x = 0
    """
    return {
        'x_xx': 0.5,
        'x_yy': 0.0,
        'y_yy': -1.0 / y,
        'y_xx': 0.0,
        'x_xy': 0.0,
        'y_xy': 0.0,
    }

def geodesic_step(x, y, vx, vy, dt):
    """One step of geodesic integration using Christoffel symbols."""
    G = eml_christoffel(x, y)

    # Geodesic equations: d²x^i/dt² + Γ^i_jk dx^j/dt dx^k/dt = 0
    ax = -(G['x_xx'] * vx * vx + 2 * G['x_xy'] * vx * vy + G['x_yy'] * vy * vy)
    ay = -(G['y_xx'] * vx * vx + 2 * G['y_xy'] * vx * vy + G['y_yy'] * vy * vy)

    # Euler step
    x_new = x + vx * dt
    y_new = y + vy * dt
    vx_new = vx + ax * dt
    vy_new = vy + ay * dt

    return x_new, y_new, vx_new, vy_new

def compute_geodesic(x0, y0, vx0, vy0, steps=200, dt=0.01):
    """Compute a geodesic path."""
    path = [(x0, y0)]
    x, y, vx, vy = x0, y0, vx0, vy0

    for _ in range(steps):
        if y <= 0.01:  # Stay in y > 0
            break
        x, y, vx, vy = geodesic_step(x, y, vx, vy, dt)
        path.append((x, y))

    return path

def eml_distance(x1, y1, x2, y2, n_steps=1000):
    """Approximate geodesic distance between two points."""
    total = 0.0
    for i in range(n_steps):
        t = i / n_steps
        x = x1 + t * (x2 - x1)
        y = y1 + t * (y2 - y1)
        dx = (x2 - x1) / n_steps
        dy = (y2 - y1) / n_steps
        gxx, gyy = eml_metric_coefficients(x, y)
        ds = math.sqrt(gxx * dx**2 + gyy * dy**2)
        total += ds
    return total

def gradient_descent_eml(f, grad_f, x0, y0, lr=0.01, steps=100):
    """Gradient descent under the EML Riemannian metric (natural gradient)."""
    path = [(x0, y0)]
    x, y = x0, y0

    for _ in range(steps):
        gx, gy = grad_f(x, y)
        gxx, gyy = eml_metric_coefficients(x, y)

        # Natural gradient: g^{-1} ∇f
        nat_gx = gx / gxx
        nat_gy = gy / gyy

        x -= lr * nat_gx
        y -= lr * nat_gy
        if y < 0.01:
            y = 0.01
        path.append((x, y))

    return path

def main():
    print()
    print("╔" + "═" * 58 + "╗")
    print("║" + " EML RIEMANNIAN GEODESICS & GRADIENT FLOW ".center(58) + "║")
    print("╚" + "═" * 58 + "╝")
    print()

    # 1. Geodesics from different starting points
    print("1. GEODESIC PATHS under ds² = exp(x) dx² + (1/y²) dy²")
    print()

    configs = [
        ((0, 1), (1, 0), "Horizontal from (0,1)"),
        ((0, 1), (0, 1), "Vertical from (0,1)"),
        ((0, 1), (1, 1), "Diagonal from (0,1)"),
        ((-1, 2), (0.5, -0.3), "From (-1,2) angled"),
    ]

    for (x0, y0), (vx0, vy0), desc in configs:
        path = compute_geodesic(x0, y0, vx0, vy0, steps=100, dt=0.05)
        end = path[-1]
        print(f"  {desc}:")
        print(f"    Start: ({x0:.1f}, {y0:.1f}), End: ({end[0]:.4f}, {end[1]:.4f})")
        arc_length = sum(
            math.sqrt(
                math.exp(path[i][0]) * (path[i+1][0] - path[i][0])**2 +
                (1/max(path[i][1], 0.01)**2) * (path[i+1][1] - path[i][1])**2
            )
            for i in range(len(path)-1)
        )
        print(f"    Arc length: {arc_length:.6f}")

    # 2. Distance comparisons
    print()
    print("2. EML-METRIC DISTANCES vs EUCLIDEAN")
    print()

    pairs = [
        ((0, 1), (1, 1)),
        ((0, 1), (0, 2)),
        ((-1, 1), (1, 1)),
        ((0, 0.1), (0, 10)),
    ]

    print(f"  {'Point A':>15} | {'Point B':>15} | {'Euclidean':>10} | {'EML-metric':>10}")
    print(f"  {'-'*15}-+-{'-'*15}-+-{'-'*10}-+-{'-'*10}")

    for (x1, y1), (x2, y2) in pairs:
        euc = math.sqrt((x2-x1)**2 + (y2-y1)**2)
        eml_d = eml_distance(x1, y1, x2, y2)
        print(f"  ({x1:5.1f},{y1:5.1f}) | ({x2:5.1f},{y2:5.1f}) | {euc:10.4f} | {eml_d:10.4f}")

    # 3. Natural gradient descent
    print()
    print("3. NATURAL GRADIENT DESCENT (EML metric)")
    print()

    # Minimize f(x,y) = (x-1)² + (y-2)²
    f = lambda x, y: (x-1)**2 + (y-2)**2
    grad_f = lambda x, y: (2*(x-1), 2*(y-2))

    path_nat = gradient_descent_eml(f, grad_f, 0, 1, lr=0.1, steps=50)

    print(f"  Minimizing f(x,y) = (x-1)² + (y-2)²")
    print(f"  Start: ({path_nat[0][0]:.2f}, {path_nat[0][1]:.2f})")
    print(f"  End:   ({path_nat[-1][0]:.4f}, {path_nat[-1][1]:.4f})")
    print(f"  Target: (1.0, 2.0)")
    print(f"  Final f: {f(*path_nat[-1]):.6e}")

    print()
    print("KEY INSIGHT: The EML metric compresses the x-direction for large x")
    print("(exp(x) is large) and stretches the y-direction near y=0 (1/y² is large).")
    print("This creates a natural geometry for optimization in exp-log space.")
    print()

if __name__ == "__main__":
    main()
