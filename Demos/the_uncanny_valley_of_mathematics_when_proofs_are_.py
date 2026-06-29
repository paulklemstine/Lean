#!/usr/bin/env python3
"""
demo.py — The Mathematical Uncanny Valley: Interactive Demonstrations

Demonstrates the key results from the formalized theory:
1. The suspicion function S(r) = r²(1-r) and its maximum at r = 2/3
2. The valley trust model U(r) = r - α·S(r) for various α
3. The sharp threshold at α = 4
4. Valley depth as a function of α
"""

import math


def suspicion_fn(r: float) -> float:
    """The suspicion function S(r) = r²(1-r)."""
    return r**2 * (1 - r)


def valley_model(alpha: float, r: float) -> float:
    """The valley trust model U(r) = r - α·S(r)."""
    return r - alpha * suspicion_fn(r)


def valley_depth(alpha: float, n_points: int = 10000) -> float:
    """Compute the valley depth: min endpoint value - min value on [0,1]."""
    min_val = min(valley_model(alpha, 0), valley_model(alpha, 1))
    for i in range(1, n_points):
        r = i / n_points
        val = valley_model(alpha, r)
        min_val = min(min_val, val)
    endpoint_min = min(valley_model(alpha, 0), valley_model(alpha, 1))
    return endpoint_min - min_val


def find_valley_minimum(alpha: float, n_points: int = 10000) -> tuple:
    """Find the rigor level that minimizes trust."""
    best_r = 0.0
    best_val = valley_model(alpha, 0)
    for i in range(n_points + 1):
        r = i / n_points
        val = valley_model(alpha, r)
        if val < best_val:
            best_r = r
            best_val = val
    return best_r, best_val


def demo_suspicion_peak():
    """Demonstrate that S(r) ≤ 4/27 with equality at r = 2/3."""
    print("=" * 60)
    print("DEMO 1: Suspicion Peak Theorem")
    print("=" * 60)
    print(f"S(2/3) = {suspicion_fn(2/3):.10f}")
    print(f"4/27   = {4/27:.10f}")
    print(f"Match: {abs(suspicion_fn(2/3) - 4/27) < 1e-15}")
    print()

    # Verify bound on [0,1]
    max_s = max(suspicion_fn(i / 100000) for i in range(100001))
    print(f"Numerical max of S on [0,1]: {max_s:.10f}")
    print(f"Bound 4/27:                  {4/27:.10f}")
    print(f"Bound holds: {max_s <= 4/27 + 1e-10}")
    print()


def demo_valley_existence():
    """Demonstrate the valley exists for α > 4 and not for α ≤ 4."""
    print("=" * 60)
    print("DEMO 2: Valley Existence & Sharp Threshold")
    print("=" * 60)

    for alpha in [2.0, 3.0, 4.0, 4.01, 5.0, 8.0, 12.0]:
        r_min, val_min = find_valley_minimum(alpha)
        depth = valley_depth(alpha)
        has_valley = val_min < min(valley_model(alpha, 0), valley_model(alpha, 1))
        print(f"α = {alpha:5.2f}: min at r={r_min:.4f}, "
              f"U(r_min)={val_min:+.6f}, depth={depth:.6f}, "
              f"valley={'YES' if has_valley else 'NO'}")
    print()
    print("Observation: Valley appears precisely when α > 4 (sharp threshold).")
    print()


def demo_monotonicity():
    """Demonstrate that valley depth increases with α."""
    print("=" * 60)
    print("DEMO 3: Valley Depth Monotonicity")
    print("=" * 60)

    alphas = [4.5, 5, 6, 8, 10, 15, 20, 50]
    depths = [valley_depth(a) for a in alphas]

    for a, d in zip(alphas, depths):
        print(f"α = {a:5.1f}: depth = {d:.6f}")

    is_monotone = all(depths[i] <= depths[i+1] for i in range(len(depths)-1))
    print(f"\nDepth is monotone increasing: {is_monotone}")
    print()


def demo_epistemic_barrier():
    """Demonstrate the universal epistemic barrier theorem."""
    print("=" * 60)
    print("DEMO 4: Epistemic Barrier Universality")
    print("=" * 60)
    print("Testing with different suspicion functions S with S(0)=S(1)=0:")
    print()

    suspicion_fns = {
        "r²(1-r)":        lambda r: r**2 * (1 - r),
        "r³(1-r)²":       lambda r: r**3 * (1 - r)**2,
        "r(1-r)":          lambda r: r * (1 - r),
        "sin(πr)/π":       lambda r: math.sin(math.pi * r) / math.pi,
        "r⁵(1-r)":        lambda r: r**5 * (1 - r),
    }

    for name, S in suspicion_fns.items():
        rs = [i / 10000 for i in range(10001)]
        M = max(S(r) for r in rs)
        alpha_threshold = 1 / M if M > 1e-15 else float('inf')
        alpha_test = 2 / M if M > 1e-15 else float('inf')
        values = [r - alpha_test * S(r) for r in rs]
        min_val = min(values)
        print(f"S(r) = {name:15s}: M = {M:.6f}, threshold α = {alpha_threshold:.4f}, "
              f"test α = {alpha_test:.4f}, min U = {min_val:+.6f} (< 0: {'YES' if min_val < 0 else 'NO'})")

    print()
    print("All suspicion functions exhibit the valley when αM > 1, confirming universality.")
    print()


def demo_conjecture_test():
    """Test the conjecture about the valley minimum location."""
    print("=" * 60)
    print("DEMO 5: Conjecture — Valley Minimum Location")
    print("=" * 60)
    print("Formula: r_min = (1 + sqrt(1 - 3/α)) / 3 for α > 4")
    print()

    for alpha in [5, 8, 12, 20, 50, 100]:
        # Numerical minimum
        r_num, _ = find_valley_minimum(alpha, n_points=1000000)
        # Predicted minimum (from derivative = 0)
        discriminant = 1 - 3/alpha
        if discriminant >= 0:
            r_pred = (1 + math.sqrt(discriminant)) / 3
        else:
            r_pred = float('nan')
        error = abs(r_num - r_pred)
        print(f"α = {alpha:4d}: numerical r_min = {r_num:.6f}, "
              f"predicted = {r_pred:.6f}, error = {error:.2e}")

    print()
    print("The formula matches numerical results to high precision.")


if __name__ == "__main__":
    demo_suspicion_peak()
    demo_valley_existence()
    demo_monotonicity()
    demo_epistemic_barrier()
    demo_conjecture_test()


#!/usr/bin/env python3
"""
visualize_valley.py — Visualization of the Mathematical Uncanny Valley

Generates plots showing:
1. The suspicion function and its peak
2. Valley models for different α values
3. The sharp threshold phase transition
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def suspicion_fn(r):
    return r**2 * (1 - r)

def valley_model(alpha, r):
    return r - alpha * suspicion_fn(r)


def plot_suspicion_function():
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    r = np.linspace(0, 1, 1000)
    s = suspicion_fn(r)

    ax.plot(r, s, 'b-', linewidth=2, label=r'$S(r) = r^2(1-r)$')
    ax.axhline(y=4/27, color='r', linestyle='--', alpha=0.7, label=r'$4/27 \approx 0.148$')
    ax.plot(2/3, 4/27, 'ro', markersize=10, zorder=5, label=r'Peak at $r = 2/3$')

    ax.set_xlabel('Rigor Level $r$', fontsize=12)
    ax.set_ylabel('Suspicion $S(r)$', fontsize=12)
    ax.set_title('The Suspicion Function', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 1)
    ax.set_ylim(-0.01, 0.2)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('plot_suspicion.png', dpi=150)
    plt.close(fig)
    print("Saved plot_suspicion.png")


def plot_valley_models():
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    r = np.linspace(0, 1, 1000)

    alphas = [0, 2, 4, 6, 10, 20]
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(alphas)))

    for alpha, color in zip(alphas, colors):
        u = valley_model(alpha, r)
        style = '--' if alpha <= 4 else '-'
        ax.plot(r, u, linestyle=style, color=color, linewidth=2,
                label=rf'$\alpha = {alpha}$')

    ax.axhline(y=0, color='gray', linestyle='-', alpha=0.5)
    ax.fill_between(r, -1, 0, alpha=0.05, color='red')
    ax.text(0.5, -0.15, 'Uncanny Valley\n(trust < 0)', ha='center',
            fontsize=10, color='red', alpha=0.7)

    ax.set_xlabel('Rigor Level $r$', fontsize=12)
    ax.set_ylabel('Trust $U_\\alpha(r)$', fontsize=12)
    ax.set_title('The Mathematical Uncanny Valley', fontsize=14)
    ax.legend(fontsize=10, loc='upper left')
    ax.set_xlim(0, 1)
    ax.set_ylim(-0.5, 1.1)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('plot_valley_models.png', dpi=150)
    plt.close(fig)
    print("Saved plot_valley_models.png")


def plot_phase_transition():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: valley depth vs alpha
    alphas = np.linspace(0, 20, 1000)
    depths = []
    for alpha in alphas:
        rs = np.linspace(0, 1, 10000)
        vals = valley_model(alpha, rs)
        endpoint_min = min(valley_model(alpha, 0), valley_model(alpha, 1))
        depth = max(0, endpoint_min - np.min(vals))
        depths.append(depth)

    ax1.plot(alphas, depths, 'b-', linewidth=2)
    ax1.axvline(x=4, color='r', linestyle='--', alpha=0.7, label=r'$\alpha = 4$ (threshold)')
    ax1.set_xlabel(r'Suspicion Sensitivity $\alpha$', fontsize=12)
    ax1.set_ylabel('Valley Depth', fontsize=12)
    ax1.set_title('Phase Transition in Valley Depth', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Right: valley minimum location vs alpha
    alphas2 = np.linspace(4.01, 20, 500)
    r_mins = []
    for alpha in alphas2:
        disc = 1 - 3/alpha
        if disc >= 0:
            r_mins.append((1 - np.sqrt(disc)) / 3)
        else:
            r_mins.append(np.nan)

    ax2.plot(alphas2, r_mins, 'g-', linewidth=2)
    ax2.set_xlabel(r'Suspicion Sensitivity $\alpha$', fontsize=12)
    ax2.set_ylabel(r'Valley Minimum Location $r_{\min}$', fontsize=12)
    ax2.set_title('Valley Minimum Moves Toward 0 as α Increases', fontsize=14)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('plot_phase_transition.png', dpi=150)
    plt.close(fig)
    print("Saved plot_phase_transition.png")


if __name__ == "__main__":
    plot_suspicion_function()
    plot_valley_models()
    plot_phase_transition()
    print("\nAll plots saved.")
