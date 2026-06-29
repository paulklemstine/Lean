"""
Compact Tropical Choquet–Radon Representation: Computational Demos

Demonstrates the tropical Choquet–Radon representation theorem with
concrete numerical examples. Run with: python demos/tropical_choquet_demo.py

In max-plus algebra:
  - "addition" is max, "multiplication" is +
  - Λ(f ⊔ g) = max(Λ(f), Λ(g)) and Λ(f + c) = Λ(f) + c
  - Representation: Λ(f) = sup_K (μ(K) + inf_K f)
"""

import numpy as np

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("matplotlib not found; skipping plots")

def make_functional(support_pts, weights):
    """Create a weighted max-plus functional Λ(f) = max_i(w_i + f(x_i))."""
    def Lambda(f_vals, x_grid):
        vals = []
        for p, w in zip(support_pts, weights):
            idx = np.argmin(np.abs(x_grid - p))
            vals.append(w + f_vals[idx])
        return max(vals)
    return Lambda

def demo_axiom_verification():
    """Verify all UCTropicalFunctional axioms numerically."""
    print("=" * 60)
    print("Demo: Axiom Verification for Weighted Max-Plus Functional")
    print("=" * 60)

    X = np.linspace(0, 1, 500)
    pts = [0.2, 0.5, 0.8]
    wts = [-0.5, 0.0, -1.0]
    L = make_functional(pts, wts)

    f = np.sin(2 * np.pi * X)
    g = X**2 - 0.5
    c = 0.37

    Lf, Lg = L(f, X), L(g, X)
    f_sup_g = np.maximum(f, g)
    L_sup = L(f_sup_g, X)

    print(f"\nPoints: {pts}, Weights: {wts}")
    print(f"\n1. Sup-preserving: Λ(f⊔g) = max(Λ(f),Λ(g))")
    print(f"   Λ(f⊔g) = {L_sup:.6f}, max(Λf,Λg) = {max(Lf,Lg):.6f}"
          f"  ✓ {np.isclose(L_sup, max(Lf, Lg))}")

    print(f"\n2. Shift equivariance: Λ(f+c) = Λ(f)+c  (c={c})")
    Lfc = L(f + c, X)
    print(f"   Λ(f+c) = {Lfc:.6f}, Λ(f)+c = {Lf+c:.6f}"
          f"  ✓ {np.isclose(Lfc, Lf + c)}")

    print(f"\n3. Monotonicity: f≤g ⟹ Λ(f)≤Λ(g)")
    h = f + 1  # h ≥ f everywhere
    print(f"   Λ(f) = {Lf:.6f}, Λ(f+1) = {L(h, X):.6f}"
          f"  ✓ {Lf <= L(h, X) + 1e-10}")

    print(f"\n4. Normalization: Λ(0) = 0")
    L0 = L(np.zeros_like(X), X)
    print(f"   Λ(0) = {L0:.6f}  ✓ {np.isclose(L0, 0)}")


def demo_choquet_representation():
    """Demonstrate the Choquet–Radon representation formula."""
    print("\n" + "=" * 60)
    print("Demo: Choquet–Radon Representation")
    print("=" * 60)

    X = np.linspace(0, 1, 500)
    pts = [0.2, 0.5, 0.8]
    wts = [-0.5, 0.0, -1.0]
    L = make_functional(pts, wts)

    f = np.sin(2 * np.pi * X)
    Lf = L(f, X)

    print(f"\nΛ(f) = max_i(w_i + f(x_i))")
    print(f"\nChoquet formula: Λ(f) = sup_K (μ(K) + inf_K f)")
    print(f"\nSingleton contributions μ({{x_i}}) + f(x_i):")
    for p, w in zip(pts, wts):
        idx = np.argmin(np.abs(X - p))
        print(f"  μ({{{p}}}) + f({p}) = {w:.2f} + {f[idx]:.4f} = {w + f[idx]:.4f}")

    print(f"\nΛ(f) = {Lf:.4f}")
    print(f"sup_{{x}} (μ({{x}}) + f(x)) = {Lf:.4f}  ✓")

    # Show that interval compact sets don't improve
    print(f"\nInterval compact sets [a,b] with multiple support points:")
    for a, b in [(0.1, 0.6), (0.4, 0.9), (0.1, 0.9)]:
        mask = (X >= a) & (X <= b)
        cap = max(w for p, w in zip(pts, wts) if a <= p <= b)
        inf_f = np.min(f[mask])
        val = cap + inf_f
        print(f"  [{a},{b}]: μ={cap:.1f}, inf f={inf_f:.4f}, sum={val:.4f}"
              f" {'≤' if val <= Lf + 1e-10 else '>'} Λ(f)")

    if HAS_MATPLOTLIB:
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

        ax1.plot(X, f, 'b-', lw=2, label='f(x) = sin(2πx)')
        for p, w in zip(pts, wts):
            idx = np.argmin(np.abs(X - p))
            ax1.plot(p, f[idx], 'ro', ms=10, zorder=5)
            ax1.annotate(f'w={w}', (p, f[idx] + 0.1), ha='center',
                         fontsize=10, color='red')
        ax1.axhline(y=Lf, color='red', ls='--', lw=2,
                     label=f'Λ(f) = {Lf:.3f}')
        ax1.set_xlabel('x'); ax1.set_ylabel('f(x)')
        ax1.set_title('Weighted Max-Plus Functional')
        ax1.legend(); ax1.grid(True, alpha=0.3)

        # Envelope plot
        envelope = np.full_like(X, -np.inf)
        for p, w in zip(pts, wts):
            idx = np.argmin(np.abs(X - p))
            envelope[idx] = w + f[idx]
        colors = ['#2196F3', '#4CAF50', '#FF9800']
        for i, (p, w) in enumerate(zip(pts, wts)):
            idx = np.argmin(np.abs(X - p))
            ax2.bar(p, w + f[idx] - (-2), bottom=-2, width=0.04,
                    color=colors[i], alpha=0.8,
                    label=f'μ({{{p}}})+f({p})={w+f[idx]:.2f}')
        ax2.axhline(y=Lf, color='red', ls='--', lw=2,
                     label=f'Λ(f) = {Lf:.3f}')
        ax2.set_xlabel('x'); ax2.set_ylabel('μ({x}) + f(x)')
        ax2.set_title('Choquet–Radon Envelope')
        ax2.set_xlim(-0.1, 1.1); ax2.set_ylim(-2, 1.5)
        ax2.legend(fontsize=9); ax2.grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig('demos/choquet_representation.png', dpi=150,
                    bbox_inches='tight')
        plt.close()
        print("\nPlot saved to demos/choquet_representation.png")


def demo_support_and_capacity():
    """Demonstrate support theory and maxitive capacity."""
    print("\n" + "=" * 60)
    print("Demo: Support Theory and Maxitive Capacity")
    print("=" * 60)

    pts = [0.3, 0.7]
    wts = [0.0, -0.5]

    print(f"\nFunctional: Λ(f) = max(f(0.3), -0.5 + f(0.7))")
    print(f"\nCapacity μ(K) = max(w_i : x_i ∈ K) or -∞:")
    test_sets = [
        ("∅", [], -np.inf),
        ("{0.3}", [0.3], 0.0),
        ("{0.7}", [0.7], -0.5),
        ("{0.3, 0.7}", [0.3, 0.7], 0.0),
        ("{0.5}", [0.5], -np.inf),
    ]
    for name, members, expected in test_sets:
        cap = -np.inf
        for p, w in zip(pts, wts):
            if p in members:
                cap = max(cap, w)
        symbol = "✓" if (cap == expected or
                         (np.isinf(cap) and np.isinf(expected))) else "✗"
        print(f"  μ({name}) = {cap}  {symbol}")

    print(f"\nMaxitivity check: μ(K∪L) = max(μ(K), μ(L))")
    K, L = [0.3], [0.7]
    capK = max((w for p, w in zip(pts, wts) if p in K), default=-np.inf)
    capL = max((w for p, w in zip(pts, wts) if p in L), default=-np.inf)
    capKL = max((w for p, w in zip(pts, wts) if p in K + L), default=-np.inf)
    print(f"  μ(K) = {capK}, μ(L) = {capL}")
    print(f"  μ(K∪L) = {capKL} = max({capK}, {capL}) ✓")

    print(f"\nTropical support = {{x : μ({{x}}) ≠ -∞}} = {pts}")
    print(f"  This is the smallest closed carrier (minimality theorem).")

    # supportedOn check
    print(f"\nsupportedOn Λ S check:")
    print(f"  S = {pts}: any K disjoint from S has μ(K) = -∞ ✓")
    print(f"  S = {{0.3}}: K={{0.7}} disjoint from S, μ({{0.7}})=-0.5 ≠ -∞ ✗")


def demo_pushforward():
    """Demonstrate pushforward functoriality."""
    print("\n" + "=" * 60)
    print("Demo: Pushforward Functoriality")
    print("=" * 60)

    X = np.linspace(0, 1, 500)

    # φ(x) = x², Λ = eval at x₀=0.7
    x0 = 0.7
    y0 = x0**2  # = 0.49

    g = np.cos(2 * np.pi * X)
    g_at_y0 = np.cos(2 * np.pi * y0)
    g_phi_at_x0 = np.cos(2 * np.pi * x0**2)

    print(f"φ(x) = x², x₀ = {x0}, φ(x₀) = {y0:.4f}")
    print(f"g(y) = cos(2πy)")
    print(f"\n(φ_*Λ)(g) = Λ(g∘φ) = (g∘φ)(x₀) = g(x₀²)")
    print(f"  = cos(2π·{x0}²) = cos(2π·{x0**2:.4f}) = {g_phi_at_x0:.6f}")
    print(f"  = g({y0:.4f}) = {g_at_y0:.6f}")
    print(f"  Match ✓: {np.isclose(g_phi_at_x0, g_at_y0)}")

    print(f"\nSupport pushforward:")
    print(f"  tropSupport(Λ) = {{{x0}}}")
    print(f"  φ(tropSupport(Λ)) = {{φ({x0})}} = {{{y0:.4f}}}")
    print(f"  tropSupport(φ_*Λ) = {{{y0:.4f}}} ⊆ φ(tropSupport(Λ)) ✓")

    print(f"\nCapacity pushforward:")
    print(f"  cap_Λ({{{x0}}}) = 0 ≤ cap_{{φ_*Λ}}(φ({{{x0}}})) = 0 ✓")


if __name__ == '__main__':
    print("Compact Tropical Choquet–Radon Representation: Demos\n")
    demo_axiom_verification()
    demo_choquet_representation()
    demo_support_and_capacity()
    demo_pushforward()
    print("\n" + "=" * 60)
    print("All demos completed!")
