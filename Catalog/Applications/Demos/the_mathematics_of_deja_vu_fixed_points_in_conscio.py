#!/usr/bin/env python3
"""
Recurrence Spectrum Demo: Visualizing Periodic Orbits in the Logistic Map

This script demonstrates the key mathematical results about periodic orbits
and fixed points in the logistic map f(x) = r*x*(1-x), showing how the
recurrence spectrum changes as the parameter r varies.
"""

import numpy as np

def logistic_map(r: float, x: float) -> float:
    """The logistic map f(x) = r*x*(1-x)."""
    return r * x * (1 - x)

def iterate_map(f, x: float, n: int) -> float:
    """Compute f^n(x) by iterating f n times."""
    for _ in range(n):
        x = f(x)
    return x

def find_fixed_points(r: float, tol: float = 1e-10) -> list:
    """Find fixed points of the logistic map: solutions of r*x*(1-x) = x."""
    # x = 0 is always a fixed point
    # r*x*(1-x) = x => r*(1-x) = 1 => x = 1 - 1/r (for r != 0)
    fps = [0.0]
    if abs(r) > tol:
        fp = 1 - 1/r
        if 0 <= fp <= 1:
            fps.append(fp)
    return fps

def find_periodic_points(r: float, period: int, n_samples: int = 1000,
                         n_transient: int = 500, tol: float = 1e-8) -> list:
    """Find approximate periodic points of the logistic map with given period."""
    f = lambda x: logistic_map(r, x)
    periodic = []
    
    for x0 in np.linspace(0.01, 0.99, n_samples):
        # Iterate to remove transients
        x = x0
        for _ in range(n_transient):
            x = f(x)
        
        # Check if x has the given period
        y = x
        for _ in range(period):
            y = f(y)
        
        if abs(y - x) < tol:
            # Verify it's not a divisor period
            is_shorter = False
            for d in range(1, period):
                if period % d == 0:
                    z = x
                    for _ in range(d):
                        z = f(z)
                    if abs(z - x) < tol:
                        is_shorter = True
                        break
            
            if not is_shorter:
                # Check if already found
                if not any(abs(x - p) < tol for p in periodic):
                    periodic.append(x)
    
    return sorted(periodic)

def compute_recurrence_spectrum(r: float, max_period: int = 20) -> dict:
    """Compute the recurrence spectrum for the logistic map at parameter r."""
    spectrum = {}
    for p in range(1, max_period + 1):
        pts = find_periodic_points(r, p)
        if pts:
            spectrum[p] = pts
    return spectrum

def demo_fixed_point_theorem():
    """Demonstrate the Interval Fixed Point Theorem."""
    print("=" * 60)
    print("INTERVAL FIXED POINT THEOREM")
    print("Any continuous f: [0,1] → [0,1] has a fixed point")
    print("=" * 60)
    
    for r in [0.5, 1.0, 2.0, 3.0, 3.5, 3.83, 4.0]:
        fps = find_fixed_points(r)
        print(f"\nr = {r}:")
        print(f"  Fixed points: {[f'{x:.6f}' for x in fps]}")
        for x in fps:
            fx = logistic_map(r, x)
            print(f"  f({x:.6f}) = {fx:.6f} (error: {abs(fx - x):.2e})")

def demo_recurrence_spectrum():
    """Demonstrate the Recurrence Spectrum at different r values."""
    print("\n" + "=" * 60)
    print("RECURRENCE SPECTRUM OF THE LOGISTIC MAP")
    print("=" * 60)
    
    test_params = [
        (2.0, "Stable fixed point"),
        (3.2, "Period-2 cycle"),
        (3.5, "Period-4 cycle"),
        (3.83, "Period-3 window (chaos!)"),
        (4.0, "Full chaos"),
    ]
    
    for r, desc in test_params:
        print(f"\nr = {r} ({desc}):")
        spectrum = compute_recurrence_spectrum(r, max_period=8)
        if spectrum:
            for period, pts in sorted(spectrum.items()):
                print(f"  Period {period}: {len(pts)} point(s)")
                for x in pts[:3]:  # Show at most 3
                    print(f"    x = {x:.8f}")
        else:
            print("  No periodic points found (transient behavior)")

def demo_sharkovsky_ordering():
    """Demonstrate the Sharkovsky ordering implications."""
    print("\n" + "=" * 60)
    print("SHARKOVSKY'S THEOREM: PERIOD 3 IMPLIES ALL PERIODS")
    print("=" * 60)
    
    r = 3.83  # Period-3 window
    print(f"\nAt r = {r} (period-3 window):")
    print("Checking which periods exist...")
    
    for p in range(1, 13):
        pts = find_periodic_points(r, p, n_samples=2000)
        status = f"FOUND ({len(pts)} points)" if pts else "not found"
        print(f"  Period {p:2d}: {status}")

def demo_spectral_entropy():
    """Demonstrate spectral entropy concepts."""
    print("\n" + "=" * 60)
    print("SPECTRAL ENTROPY: PERIODIC POINT GROWTH")
    print("=" * 60)
    
    for r in [3.0, 3.5, 3.83, 4.0]:
        print(f"\nr = {r}:")
        counts = []
        for n in range(1, 11):
            # Count period-n points (points with f^n(x) = x)
            f = lambda x, r=r: logistic_map(r, x)
            count = 0
            for x0 in np.linspace(0.01, 0.99, 500):
                x = x0
                for _ in range(200):
                    x = f(x)
                y = x
                for _ in range(n):
                    y = f(y)
                if abs(y - x) < 1e-8:
                    count += 1
            counts.append(count)
            print(f"  |Fix(f^{n:2d})| ≈ {count:4d}")
        
        if counts[-1] > 0 and counts[0] > 0:
            growth = np.log(counts[-1] / max(counts[0], 1)) / 9
            print(f"  Estimated spectral entropy ≈ {growth:.4f}")

if __name__ == "__main__":
    demo_fixed_point_theorem()
    demo_recurrence_spectrum()
    demo_sharkovsky_ordering()
    demo_spectral_entropy()
    
    print("\n" + "=" * 60)
    print("CONCLUSION: Déjà vu is mathematically inevitable")
    print("Any continuous self-map of a bounded interval MUST have")
    print("at least one fixed point — a state that recurs identically.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Bifurcation Diagram and Recurrence Spectrum Visualization

Standalone visualization script showing:
1. The bifurcation diagram of the logistic map
2. The recurrence spectrum at selected parameter values
3. The Sharkovsky ordering structure
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def logistic_map(r, x):
    return r * x * (1.0 - x)


def iterate_map(r, x, n):
    for _ in range(n):
        x = logistic_map(r, x)
    return x


def compute_bifurcation(r_min=2.5, r_max=4.0, n_r=2000, n_trans=500, n_plot=300):
    rs = np.linspace(r_min, r_max, n_r)
    r_vals, x_vals = [], []
    for r in rs:
        x = 0.5
        for _ in range(n_trans):
            x = logistic_map(r, x)
        for _ in range(n_plot):
            x = logistic_map(r, x)
            r_vals.append(r)
            x_vals.append(x)
    return np.array(r_vals), np.array(x_vals)


def detect_period(r, x0=0.5, max_p=50, tol=1e-8):
    x = x0
    for _ in range(1000):
        x = logistic_map(r, x)
    for p in range(1, max_p + 1):
        y = x
        for _ in range(p):
            y = logistic_map(r, y)
        if abs(y - x) < tol:
            return p
    return None


def cobweb_diagram(ax, r, x0=0.2, n_steps=50):
    xs = np.linspace(0, 1, 500)
    ys = r * xs * (1 - xs)
    ax.plot(xs, ys, 'b-', linewidth=2, label=f'$f(x) = {r}x(1-x)$')
    ax.plot(xs, xs, 'k--', linewidth=1, label='$y = x$')
    
    x = x0
    for _ in range(n_steps):
        fx = logistic_map(r, x)
        ax.plot([x, x], [x, fx], 'r-', linewidth=0.5, alpha=0.7)
        ax.plot([x, fx], [fx, fx], 'r-', linewidth=0.5, alpha=0.7)
        x = fx
    
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_xlabel('$x$')
    ax.set_ylabel('$f(x)$')
    ax.set_title(f'Cobweb: $r = {r}$')
    ax.legend(fontsize=8)


fig = plt.figure(figsize=(16, 12))
gs = GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)

# Panel 1: Bifurcation diagram
ax1 = fig.add_subplot(gs[0, :])
r_vals, x_vals = compute_bifurcation()
ax1.scatter(r_vals, x_vals, s=0.01, c='black', alpha=0.3)
ax1.axvline(x=3.83, color='red', linestyle='--', alpha=0.7, label='$r = 3.83$ (period-3)')
ax1.axvline(x=3.0, color='blue', linestyle='--', alpha=0.5, label='$r = 3.0$ (onset)')
ax1.set_xlabel('$r$ (bifurcation parameter)', fontsize=12)
ax1.set_ylabel('$x$ (attractor)', fontsize=12)
ax1.set_title('Bifurcation Diagram of the Logistic Map', fontsize=14)
ax1.legend()

# Panel 2-4: Cobweb diagrams at three r values
for idx, (r, title) in enumerate([(2.8, 'Fixed Point'), (3.5, 'Period-4'), (3.83, 'Period-3 (Chaos)')]):
    ax = fig.add_subplot(gs[1, idx])
    cobweb_diagram(ax, r)
    ax.set_title(f'{title}: $r = {r}$', fontsize=11)

plt.suptitle('Recurrence Spectrum of the Logistic Map: Déjà Vu in Dynamical Systems',
             fontsize=15, fontweight='bold', y=1.02)
plt.savefig('/workspace/request-project/bifurcation_diagram.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved bifurcation_diagram.png")
