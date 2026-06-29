#!/usr/bin/env python3
"""
demo.py — Numerical exploration of EML transcendence and Schanuel's conjecture.

Demonstrates the key quantities studied in this research cycle:
1. The EML function eml(x,y) = exp(x) - log(y)
2. Algebraic independence of {e, e^e}
3. The transcendence cascade: e, e^e, e^(e^e), ...
4. The number exp(exp(1)) + log(2) ≈ 16.045
"""

import math

def eml(x: float, y: float) -> float:
    """EML function: eml(x,y) = exp(x) - log(y)"""
    return math.exp(x) - math.log(y)

def schanuel_tuple(z: list[float]) -> list[float]:
    """Compute the Schanuel combined tuple (z₁,...,zₙ,e^z₁,...,e^zₙ)."""
    return z + [math.exp(zi) for zi in z]

def exp_tower(n: int) -> float:
    """Compute the n-th element of the exponential tower: 1, e, e^e, e^(e^e), ..."""
    result = 1.0
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result

def main():
    e = math.e
    
    print("=" * 70)
    print("EML NUMBER TRANSCENDENCE — NUMERICAL DEMONSTRATIONS")
    print("=" * 70)
    
    # 1. The key numbers
    print("\n📊 KEY NUMBERS STUDIED:")
    print(f"  e = exp(1)         = {e:.15f}")
    print(f"  e^e = exp(exp(1))  = {e**e:.15f}")
    print(f"  log(2)             = {math.log(2):.15f}")
    print(f"  e^e + log(2)       = {e**e + math.log(2):.15f}")
    print(f"  e^e + e            = {e**e + e:.15f}")
    
    # 2. Schanuel's conjecture applied to z = [1, e]
    print("\n🔬 SCHANUEL'S CONJECTURE FOR z = [1, e]:")
    z = [1.0, e]
    st = schanuel_tuple(z)
    print(f"  z = {z}")
    print(f"  Combined tuple: {[f'{x:.6f}' for x in st]}")
    print(f"  Slots: inl(0)={st[0]:.6f}, inl(1)={st[1]:.6f}, "
          f"inr(0)={st[2]:.6f}, inr(1)={st[3]:.6f}")
    print(f"  Note: inl(1) = inr(0) = e (both ≈ {e:.6f})")
    print(f"  → Embedding MUST select {{e, e^e}} = {{{e:.6f}, {e**e:.6f}}}")
    print(f"  → {e:.6f} and {e**e:.6f} are algebraically independent over ℚ")
    
    # 3. The EML function at key points
    print("\n📐 EML FUNCTION VALUES:")
    test_points = [
        (1, 1, "eml(1,1) = e - 0 = e"),
        (e, 1, "eml(e,1) = e^e"),
        (1, e, "eml(1,e) = e - 1"),
        (0, 1, "eml(0,1) = 1"),
        (e, math.exp(-e), "eml(e, exp(-e)) = e^e + e"),
    ]
    for x, y, desc in test_points:
        val = eml(x, y)
        print(f"  {desc:40s} ≈ {val:.10f}")
    
    # 4. The exponential tower
    print("\n🗼 EXPONENTIAL TOWER (all transcendental under Schanuel):")
    for n in range(6):
        val = exp_tower(n)
        if val < 1e300:
            print(f"  exp^{n}(1) = {val:.10f}")
        else:
            print(f"  exp^{n}(1) = (too large, > 10^300)")
    
    # 5. Algebraic independence test
    print("\n🧪 ALGEBRAIC INDEPENDENCE ILLUSTRATION:")
    print("  If e and e^e were algebraically dependent, there would exist")
    print("  a polynomial P(X,Y) ∈ ℚ[X,Y] with P(e, e^e) = 0.")
    print()
    print("  Testing low-degree polynomial relations P(e, e^e):")
    for (a, b, c, d) in [(1, -1, 0, 0), (0, 1, -1, 0), (1, 0, 0, -1),
                          (1, 1, -1, 0), (2, -1, 0, 1)]:
        val = a + b * e + c * e**e + d * e * e**e
        desc = f"{a} + {b}·e + {c}·e^e + {d}·e·e^e"
        print(f"  {desc:35s} = {val:+.10f}")
    print("  → None vanish: consistent with algebraic independence")
    
    # 6. Schanuel for z = [1, e, log(2)]
    print("\n🔬 SCHANUEL FOR z = [1, e, log(2)]:")
    z3 = [1.0, e, math.log(2)]
    st3 = schanuel_tuple(z3)
    print(f"  z = [1, e, log(2)]")
    print(f"  Combined 6-tuple:")
    labels = ["1", "e", "log(2)", "exp(1)=e", "exp(e)=e^e", "exp(log(2))=2"]
    for i, (label, val) in enumerate(zip(labels, st3)):
        print(f"    slot {i}: {label:20s} = {val:.10f}")
    print(f"  Distinct values: {{1, e, log(2), e^e, 2}}")
    print(f"  Must select 3 algebraically independent from 6 slots")
    print(f"  → Only option: {{e, log(2), e^e}}")
    print(f"  → e^e + log(2) = {e**e + math.log(2):.10f} is transcendental")
    
    print("\n" + "=" * 70)
    print("ALL RESULTS CONDITIONAL ON SCHANUEL'S CONJECTURE")
    print("=" * 70)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Exponential Transcendence Cascade.

Shows the growth of the iterated exponential tower and
the Schanuel tuple structure for z = [1, e].
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math


def exp_tower(n: int) -> float:
    """Compute exp^n(1)."""
    result = 1.0
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


def plot_schanuel_tuple():
    """Visualize the Schanuel tuple for z = [1, e] and the embedding constraints."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Schanuel tuple slots
    ax = axes[0]
    e = math.e
    slots = {
        'inl(0)': 1.0,
        'inl(1)': e,
        'inr(0)': e,
        'inr(1)': e**e,
    }
    
    colors_map = {
        'inl(0)': '#ff6b6b',  # red - algebraic (excluded)
        'inl(1)': '#4ecdc4',  # teal - exp(1) = e
        'inr(0)': '#4ecdc4',  # teal - same value as inl(1)
        'inr(1)': '#45b7d1',  # blue - exp(exp(1)) = e^e
    }
    
    x_positions = [0, 1, 2, 3]
    bars = ax.bar(x_positions, list(slots.values()), 
                  color=[colors_map[k] for k in slots.keys()],
                  edgecolor='black', linewidth=1.5, width=0.6)
    
    ax.set_xticks(x_positions)
    ax.set_xticklabels(list(slots.keys()), fontsize=11)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Schanuel Tuple for z = [1, e]', fontsize=14, fontweight='bold')
    
    # Annotate values
    for i, (k, v) in enumerate(slots.items()):
        label = '1\n(algebraic)' if k == 'inl(0)' else f'{v:.4f}'
        ax.annotate(label, (i, v), textcoords="offset points",
                    xytext=(0, 10), ha='center', fontsize=10)
    
    # Cross out inl(0)
    ax.plot([0], [0.5], 'rx', markersize=20, markeredgewidth=3)
    
    # Draw connection between inl(1) and inr(0)
    ax.annotate('', xy=(2, e + 0.3), xytext=(1, e + 0.3),
                arrowprops=dict(arrowstyle='<->', color='orange', lw=2))
    ax.text(1.5, e + 0.6, 'same value!', ha='center', fontsize=10, 
            color='orange', fontweight='bold')
    
    # Legend
    patches = [
        mpatches.Patch(color='#ff6b6b', label='Excluded (algebraic)'),
        mpatches.Patch(color='#4ecdc4', label='Value = e ≈ 2.718'),
        mpatches.Patch(color='#45b7d1', label='Value = e^e ≈ 15.154'),
    ]
    ax.legend(handles=patches, loc='upper left', fontsize=9)
    
    # Right: Tower growth (log scale)
    ax2 = axes[1]
    tower_values = []
    tower_labels = []
    for n in range(1, 5):
        val = exp_tower(n)
        if val < 1e300:
            tower_values.append(val)
            tower_labels.append(f'exp^{n}(1)')
    
    bars2 = ax2.bar(range(len(tower_values)), tower_values,
                    color=['#4ecdc4', '#45b7d1', '#f7dc6f', '#e74c3c'],
                    edgecolor='black', linewidth=1.5, width=0.6)
    
    ax2.set_xticks(range(len(tower_values)))
    ax2.set_xticklabels(tower_labels, fontsize=11)
    ax2.set_ylabel('Value (log scale)', fontsize=12)
    ax2.set_yscale('log')
    ax2.set_title('Exponential Tower Growth\n(All transcendental under Schanuel)',
                   fontsize=14, fontweight='bold')
    
    for i, v in enumerate(tower_values):
        ax2.annotate(f'{v:.2f}', (i, v), textcoords="offset points",
                     xytext=(0, 10), ha='center', fontsize=10)
    
    plt.tight_layout()
    plt.savefig('transcendence_cascade.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: transcendence_cascade.png")


def plot_eml_surface():
    """Plot the EML function eml(x,y) = exp(x) - log(y)."""
    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111, projection='3d')
    
    x = np.linspace(-2, 3, 100)
    y = np.linspace(0.1, 5, 100)
    X, Y = np.meshgrid(x, y)
    Z = np.exp(X) - np.log(Y)
    
    surf = ax.plot_surface(X, Y, Z, cmap='viridis', alpha=0.8,
                           linewidth=0, antialiased=True)
    
    # Mark key transcendental points
    e = math.e
    points = [
        (1, 1, e, 'eml(1,1)=e'),
        (e, 1, e**e, 'eml(e,1)=e^e'),
    ]
    for px, py, pz, label in points:
        ax.scatter([px], [py], [pz], color='red', s=100, zorder=5)
        ax.text(px, py, pz + 1, label, fontsize=9, color='red')
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_zlabel('eml(x,y)', fontsize=12)
    ax.set_title('EML Function: eml(x,y) = exp(x) - log(y)\nRed dots: transcendental values',
                 fontsize=13, fontweight='bold')
    
    fig.colorbar(surf, shrink=0.5, aspect=5)
    plt.savefig('eml_surface.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_surface.png")


if __name__ == "__main__":
    plot_schanuel_tuple()
    plot_eml_surface()
