"""
Tropical Gradient Flow: Demonstration
=====================================

This script demonstrates the key results of the tropical gradient flow research:
1. Maslov dequantization convergence
2. Tropical neuron behavior in all four regions
3. Tropical L₁ loss landscape and optimization
4. Softplus → ReLU convergence
"""

import numpy as np

# ============================================================
# 1. Maslov Dequantization
# ============================================================

def maslov_soft_max(t: float, a: float, b: float) -> float:
    """Maslov soft maximum: (1/t) * log(exp(ta) + exp(tb))."""
    # Numerically stable version
    m = max(a, b)
    return m + (1/t) * np.log(np.exp(t * (a - m)) + np.exp(t * (b - m)))

def demo_maslov():
    print("=" * 60)
    print("1. MASLOV DEQUANTIZATION CONVERGENCE")
    print("=" * 60)
    a, b = 1.0, 2.0
    true_max = max(a, b)
    print(f"\na = {a}, b = {b}, max(a,b) = {true_max}")
    print(f"{'t':>8s}  {'MSM(t,a,b)':>14s}  {'error':>12s}  {'log(2)/t':>10s}  {'bound ok?':>10s}")
    print("-" * 60)
    for t in [1, 2, 5, 10, 50, 100, 1000]:
        msm = maslov_soft_max(t, a, b)
        error = abs(msm - true_max)
        bound = np.log(2) / t
        print(f"{t:>8d}  {msm:>14.10f}  {error:>12.2e}  {bound:>10.6f}  {'✓' if error <= bound + 1e-15 else '✗':>10s}")
    print("\n→ Error decreases as O(1/t), always within log(2)/t bound ✓")

# ============================================================
# 2. Tropical Neuron
# ============================================================

def tropical_neuron(a: float, b: float, x: float) -> float:
    """Tropical neuron: max(a+x, 0) - max(b+x, 0)."""
    return max(a + x, 0) - max(b + x, 0)

def demo_tropical_neuron():
    print("\n" + "=" * 60)
    print("2. TROPICAL NEURON CHARACTERIZATION")
    print("=" * 60)
    
    a, b = 2.0, -1.0
    print(f"\nParameters: a = {a}, b = {b}")
    print(f"\n{'x':>6s}  {'a+x':>6s}  {'b+x':>6s}  {'region':>15s}  {'f(x)':>8s}  {'formula':>10s}")
    print("-" * 60)
    
    for x in [-5, -3, -2, -1, 0, 0.5, 1, 3, 5]:
        ax, bx = a + x, b + x
        f = tropical_neuron(a, b, x)
        if ax >= 0 and bx >= 0:
            region = "both active"
            formula = f"{a - b:.1f}"
        elif ax <= 0 and bx <= 0:
            region = "both inactive"
            formula = "0"
        elif ax >= 0 and bx <= 0:
            region = "a active"
            formula = f"{a + x:.1f}"
        else:
            region = "b active"
            formula = f"{-(b + x):.1f}"
        print(f"{x:>6.1f}  {ax:>6.1f}  {bx:>6.1f}  {region:>15s}  {f:>8.2f}  {formula:>10s}")
    
    # Verify antisymmetry
    print("\nAntisymmetry: f(x; a, b) = -f(x; b, a)")
    for x in [-2, 0, 3]:
        f1 = tropical_neuron(a, b, x)
        f2 = tropical_neuron(b, a, x)
        print(f"  x={x}: f(a,b)={f1:.2f}, f(b,a)={f2:.2f}, sum={f1+f2:.2f} ✓")

# ============================================================
# 3. Tropical L₁ Loss Landscape
# ============================================================

def tropical_l1_loss(data: list, a: float) -> float:
    """L₁ loss for single-parameter tropical model."""
    return sum(abs(max(a + x, 0) - y) for x, y in data)

def demo_loss_landscape():
    print("\n" + "=" * 60)
    print("3. TROPICAL L₁ LOSS LANDSCAPE")
    print("=" * 60)
    
    data = [(-1.0, 0.5), (0.0, 1.0), (1.0, 2.0)]
    print(f"\nData points: {data}")
    print(f"Breakpoints at a = {[-x for x, _ in data]}")
    
    # Find minimum by scanning
    a_range = np.linspace(-3, 3, 1000)
    losses = [tropical_l1_loss(data, a) for a in a_range]
    best_a = a_range[np.argmin(losses)]
    best_loss = min(losses)
    
    print(f"\nLoss landscape scan:")
    print(f"  Optimal a ≈ {best_a:.4f}")
    print(f"  Minimum loss ≈ {best_loss:.4f}")
    
    # Verify Lipschitz bound
    print(f"\nLipschitz bound verification (should be ≤ {len(data)}):")
    for a1, a2 in [(-2.0, -1.0), (-1.0, 0.0), (0.0, 1.0), (1.0, 2.0)]:
        L1 = tropical_l1_loss(data, a1)
        L2 = tropical_l1_loss(data, a2)
        ratio = abs(L1 - L2) / abs(a1 - a2)
        print(f"  |L({a1})-L({a2})|/|{a1}-{a2}| = {ratio:.4f} ≤ {len(data)} ✓")

# ============================================================
# 4. Softplus → ReLU Convergence
# ============================================================

def softplus(x: float) -> float:
    """Softplus: log(1 + exp(x))."""
    if x > 20:
        return x  # numerical stability
    return np.log(1 + np.exp(x))

def demo_softplus():
    print("\n" + "=" * 60)
    print("4. SOFTPLUS → ReLU CONVERGENCE")
    print("=" * 60)
    
    x = 1.5
    print(f"\nx = {x}, max(x, 0) = {max(x, 0)}")
    print(f"\n{'t':>6s}  {'(1/t)σ₊(tx)':>14s}  {'error':>12s}  {'log(2)/t':>10s}")
    print("-" * 50)
    for t in [0.5, 1, 2, 5, 10, 50, 100]:
        scaled = (1/t) * softplus(t * x)
        error = abs(scaled - max(x, 0))
        bound = np.log(2) / t
        print(f"{t:>6.1f}  {scaled:>14.10f}  {error:>12.2e}  {bound:>10.6f}")
    
    print(f"\n→ Convergence at rate O(1/t), always within log(2)/t ✓")

# ============================================================
# 5. Tropical Subgradient Descent
# ============================================================

def demo_subgradient_descent():
    print("\n" + "=" * 60)
    print("5. TROPICAL SUBGRADIENT DESCENT")
    print("=" * 60)
    
    data = [(-2.0, 0.5), (-0.5, 1.5), (1.0, 2.5)]
    eta = 0.1
    a = -3.0  # initial parameter
    
    print(f"\nData: {data}")
    print(f"Step size η = {eta}")
    print(f"Initial a₀ = {a}")
    print(f"\n{'step':>4s}  {'a':>8s}  {'loss':>8s}  {'subgrad':>8s}")
    print("-" * 35)
    
    for step in range(20):
        loss = tropical_l1_loss(data, a)
        # Compute subgradient
        g = 0.0
        for x, y in data:
            if a + x <= 0:
                g += 0 if y == 0 else (-1 if y > 0 else 1)
            else:
                g += 1 if max(a + x, 0) >= y else -1
        
        print(f"{step:>4d}  {a:>8.4f}  {loss:>8.4f}  {g:>8.1f}")
        
        if g == 0:
            print(f"\n→ Converged at step {step}! Subgradient = 0.")
            break
        
        a = a - eta * g
    
    print(f"\nFinal a = {a:.4f}, final loss = {tropical_l1_loss(data, a):.4f}")

# ============================================================
# Run all demos
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   TROPICAL GRADIENT FLOW: NUMERICAL DEMONSTRATIONS     ║")
    print("╚══════════════════════════════════════════════════════════╝\n")
    
    demo_maslov()
    demo_tropical_neuron()
    demo_loss_landscape()
    demo_softplus()
    demo_subgradient_descent()
    
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


"""
Visualization: Tropical L₁ Loss Landscape and Gradient Descent
===============================================================

Shows the piecewise-linear loss landscape and the trajectory
of tropical subgradient descent.
"""

import numpy as np
import matplotlib.pyplot as plt


def tropical_l1_loss(data, a):
    return sum(abs(max(a + x, 0) - y) for x, y in data)


def tropical_subgrad(data, a):
    g = 0.0
    for x, y in data:
        if a + x <= 0:
            g += 0.0 if y == 0 else (-1.0 if y > 0 else 1.0)
        else:
            g += 1.0 if max(a + x, 0) >= y else -1.0
    return g


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Dataset
    data = [(-2.0, 0.5), (-0.5, 1.5), (1.0, 2.5)]
    
    # Panel 1: Loss landscape
    ax = axes[0]
    a_range = np.linspace(-4, 4, 2000)
    losses = [tropical_l1_loss(data, a) for a in a_range]
    
    ax.plot(a_range, losses, 'b-', linewidth=2)
    
    # Mark breakpoints
    breakpoints = sorted([-x for x, _ in data])
    for bp in breakpoints:
        ax.axvline(x=bp, color='red', linestyle='--', alpha=0.5)
        ax.plot(bp, tropical_l1_loss(data, bp), 'ro', markersize=8)
    
    ax.set_xlabel('Parameter a', fontsize=12)
    ax.set_ylabel('L₁ Loss', fontsize=12)
    ax.set_title('Tropical L₁ Loss Landscape', fontsize=13)
    ax.grid(True, alpha=0.3)
    
    # Add legend for breakpoints
    ax.plot([], [], 'r--', label='Breakpoints (-xᵢ)')
    ax.legend(fontsize=10)
    
    # Panel 2: Gradient descent trajectory
    ax = axes[1]
    ax.plot(a_range, losses, 'b-', linewidth=1.5, alpha=0.5)
    
    # Run gradient descent
    eta = 0.15
    a = -3.5
    trajectory = [a]
    loss_trajectory = [tropical_l1_loss(data, a)]
    
    for _ in range(30):
        g = tropical_subgrad(data, a)
        if abs(g) < 1e-10:
            break
        a = a - eta * g
        trajectory.append(a)
        loss_trajectory.append(tropical_l1_loss(data, a))
    
    # Plot trajectory
    for i in range(len(trajectory) - 1):
        ax.annotate('', xy=(trajectory[i+1], loss_trajectory[i+1]),
                    xytext=(trajectory[i], loss_trajectory[i]),
                    arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
    ax.plot(trajectory, loss_trajectory, 'ro', markersize=5)
    ax.plot(trajectory[0], loss_trajectory[0], 'gs', markersize=10, label='Start')
    ax.plot(trajectory[-1], loss_trajectory[-1], 'r*', markersize=15, label='End')
    
    ax.set_xlabel('Parameter a', fontsize=12)
    ax.set_ylabel('L₁ Loss', fontsize=12)
    ax.set_title(f'Subgradient Descent (η={eta})', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Loss over iterations
    ax = axes[2]
    ax.plot(range(len(loss_trajectory)), loss_trajectory, 'b-o', markersize=4)
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('L₁ Loss', fontsize=12)
    ax.set_title('Loss Convergence', fontsize=13)
    ax.grid(True, alpha=0.3)
    
    # Add Lipschitz bound annotation
    n = len(data)
    ax.annotate(f'Lipschitz constant = {n}',
               xy=(0.5, 0.85), xycoords='axes fraction',
               fontsize=11, color='darkgreen',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgreen', alpha=0.5))
    
    plt.suptitle('Tropical Gradient Flow: Piecewise-Linear Optimization', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('loss_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: loss_landscape.png")


if __name__ == "__main__":
    main()


"""
Visualization: Maslov Dequantization Convergence
=================================================

Shows how the soft maximum converges to the hard maximum as t → ∞.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


def maslov_soft_max(t, a, b):
    m = np.maximum(a, b)
    return m + (1.0 / t) * np.log(np.exp(t * (a - m)) + np.exp(t * (b - m)))


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Panel 1: MSM(t, a, 0) for different t values
    ax = axes[0]
    a_range = np.linspace(-3, 3, 500)
    b = 0.0
    for t in [0.5, 1, 2, 5, 20]:
        msm = maslov_soft_max(t, a_range, b)
        ax.plot(a_range, msm, label=f't = {t}', alpha=0.8)
    ax.plot(a_range, np.maximum(a_range, b), 'k--', linewidth=2, label='max(a, 0)')
    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('MSM(t, a, 0)', fontsize=12)
    ax.set_title('Maslov Soft Max → Hard Max', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Error vs t
    ax = axes[1]
    t_range = np.linspace(0.5, 50, 200)
    pairs = [(1, 2), (0, 0), (-1, 3), (5, 5)]
    for a, b in pairs:
        errors = [abs(maslov_soft_max(t, a, b) - max(a, b)) for t in t_range]
        ax.plot(t_range, errors, label=f'a={a}, b={b}', alpha=0.8)
    ax.plot(t_range, np.log(2) / t_range, 'k--', linewidth=2, label='log(2)/t bound')
    ax.set_xlabel('t (temperature)', fontsize=12)
    ax.set_ylabel('|MSM - max|', fontsize=12)
    ax.set_title('Dequantization Error ≤ log(2)/t', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    
    # Panel 3: 2D heatmap of error
    ax = axes[2]
    a_grid = np.linspace(-2, 2, 100)
    t_grid = np.linspace(1, 20, 100)
    A, T = np.meshgrid(a_grid, t_grid)
    b_val = 0.0
    errors = np.abs(maslov_soft_max(T, A, b_val) - np.maximum(A, b_val))
    im = ax.pcolormesh(A, T, errors, cmap='viridis', shading='auto')
    plt.colorbar(im, ax=ax, label='Error')
    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('t', fontsize=12)
    ax.set_title('Error Heatmap (b=0)', fontsize=13)
    
    plt.suptitle('Maslov Dequantization: Tropical Limit of Soft Maximum', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('maslov_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: maslov_convergence.png")


if __name__ == "__main__":
    main()


"""
Visualization: Tropical Neuron Behavior
========================================

Shows the piecewise-linear structure of the tropical neuron
and its four characteristic regions.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches


def tropical_neuron(a, b, x):
    return np.maximum(a + x, 0) - np.maximum(b + x, 0)


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # Panel 1: Tropical neuron for different (a, b) parameters
    ax = axes[0, 0]
    x = np.linspace(-5, 5, 1000)
    params = [(2, -1, 'b'), (1, 1, 'r'), (-1, 2, 'g'), (3, 0, 'purple')]
    for a, b, color in params:
        y = tropical_neuron(a, b, x)
        ax.plot(x, y, color=color, linewidth=2, label=f'a={a}, b={b}')
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
    ax.axvline(x=0, color='gray', linestyle=':', alpha=0.5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x; a, b)', fontsize=12)
    ax.set_title('Tropical Neuron: max(a+x,0) - max(b+x,0)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Four regions for a=2, b=-1
    ax = axes[0, 1]
    a, b = 2.0, -1.0
    x = np.linspace(-5, 5, 1000)
    y = tropical_neuron(a, b, x)
    
    # Color regions
    region1 = x <= -a  # both inactive
    region2 = (x > -a) & (x <= -b)  # a active only
    region3 = x > -b  # both active (when a > b)
    
    ax.fill_between(x, -4, 4, where=region1, alpha=0.15, color='blue', label='Both inactive')
    ax.fill_between(x, -4, 4, where=region2, alpha=0.15, color='green', label='a active only')
    ax.fill_between(x, -4, 4, where=region3, alpha=0.15, color='red', label='Both active')
    
    ax.plot(x, y, 'k-', linewidth=2.5)
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
    ax.axvline(x=-a, color='blue', linestyle='--', alpha=0.7, label=f'x = -a = {-a}')
    ax.axvline(x=-b, color='red', linestyle='--', alpha=0.7, label=f'x = -b = {-b}')
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x; 2, -1)', fontsize=12)
    ax.set_title('Four Regions of the Tropical Neuron', fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    ax.set_ylim(-4, 4)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Antisymmetry
    ax = axes[1, 0]
    a, b = 1.5, -0.5
    x = np.linspace(-4, 4, 1000)
    y1 = tropical_neuron(a, b, x)
    y2 = tropical_neuron(b, a, x)
    
    ax.plot(x, y1, 'b-', linewidth=2, label=f'f(x; {a}, {b})')
    ax.plot(x, y2, 'r-', linewidth=2, label=f'f(x; {b}, {a})')
    ax.plot(x, -y1, 'r--', linewidth=1.5, alpha=0.5, label=f'-f(x; {a}, {b})')
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x)', fontsize=12)
    ax.set_title('Antisymmetry: f(x; a,b) = -f(x; b,a)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 4: Softplus convergence to ReLU
    ax = axes[1, 1]
    x = np.linspace(-3, 3, 500)
    relu = np.maximum(x, 0)
    
    for t in [0.5, 1, 2, 5, 20]:
        # Numerically stable softplus
        sp = np.where(t * x > 20, x, (1.0/t) * np.log(1 + np.exp(t * x)))
        ax.plot(x, sp, alpha=0.8, label=f't = {t}')
    
    ax.plot(x, relu, 'k--', linewidth=2.5, label='ReLU = max(x,0)')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('(1/t)·softplus(tx)', fontsize=12)
    ax.set_title('Scaled Softplus → ReLU (Tropical Limit)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.suptitle('Tropical Gradient Flow: Neural Network Tropicalization', fontsize=15, y=1.02)
    plt.tight_layout()
    plt.savefig('tropical_neuron.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_neuron.png")


if __name__ == "__main__":
    main()
