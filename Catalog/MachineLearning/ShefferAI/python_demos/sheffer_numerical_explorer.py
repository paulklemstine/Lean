"""
Sheffer Algebra Numerical Explorer
===================================

Interactive numerical experiments exploring open questions in the Sheffer algebra.
Tests conjectures, searches for patterns, and computes key quantities.

Usage:
    python sheffer_numerical_explorer.py
"""

import numpy as np
from itertools import product as cartesian

# ─── Core Functions ───

def softplus(x):
    return np.where(x > 20, x, np.log1p(np.exp(np.clip(x, -500, 20))))

def sigmoid(x):
    return np.where(x > 0, 1 / (1 + np.exp(-x)), np.exp(x) / (1 + np.exp(x)))

def softplus_iter_exact(n, x):
    """σⁿ(x) = log(n + eˣ)"""
    return np.log(n + np.exp(x))


# ─── Experiment 1: Orbit Merging Rate ───

def experiment_orbit_merging():
    """Verify |σⁿ(x) - σⁿ(y)| = O(1/n) orbit merging."""
    print("\n" + "=" * 60)
    print("Experiment 1: Orbit Merging Rate")
    print("=" * 60)

    x, y = 3.0, -2.0
    print(f"\nOrbit merging for x={x}, y={y}:")
    print(f"{'n':>6} | {'|σⁿ(x)-σⁿ(y)|':>16} | {'|eˣ-eʸ|/n':>16} | {'ratio':>10}")
    print("-" * 56)

    exp_diff = abs(np.exp(x) - np.exp(y))
    for n in [1, 2, 5, 10, 20, 50, 100, 500, 1000]:
        diff = abs(softplus_iter_exact(n, x) - softplus_iter_exact(n, y))
        bound = exp_diff / n
        ratio = diff / bound if bound > 0 else 0
        print(f"{n:>6} | {diff:>16.10f} | {bound:>16.10f} | {ratio:>10.6f}")

    print("\n→ Ratio ≤ 1 confirms |σⁿ(x) - σⁿ(y)| ≤ |eˣ - eʸ|/n")


# ─── Experiment 2: Derivative Limit Pair Search ───

def experiment_derivative_limits():
    """Verify that all (L₊, L₋) pairs are achievable."""
    print("\n" + "=" * 60)
    print("Experiment 2: Derivative Limit Pairs")
    print("=" * 60)

    print("\nFor f(x) = (a-b)·σ(x) + b·x, we get f'→a at +∞, f'→b at -∞:")
    h1, h2 = "f'(100)", "f'(-100)"
    print(f"{'(a,b)':>10} | {h1:>12} | {h2:>12} | {'Match?':>8}")
    print("-" * 50)

    test_pairs = [(2, -1), (0.5, 0.5), (0, 0), (-3, 2), (10, -10), (0, 1)]
    for a, b in test_pairs:
        fp_pos = (a - b) * sigmoid(100.0) + b
        fp_neg = (a - b) * sigmoid(-100.0) + b
        match = abs(fp_pos - a) < 1e-6 and abs(fp_neg - b) < 1e-6
        print(f"{'(' + str(a) + ',' + str(b) + ')':>10} | {fp_pos:>12.8f} | {fp_neg:>12.8f} | {'✓' if match else '✗':>8}")


# ─── Experiment 3: Sigmoid Approximation by Sheffer Expressions ───

def experiment_sigmoid_approximation():
    """How well can we approximate S(x) using Sheffer expressions?"""
    print("\n" + "=" * 60)
    print("Experiment 3: Sigmoid Approximation")
    print("=" * 60)

    x = np.linspace(-10, 10, 10000)
    target = sigmoid(x)

    # Strategy 1: (σ(x) - σ(x+c)) / (-c) for various c
    print("\nApproximation: (σ(x) - σ(x+c)) / (-c)")
    print(f"{'c':>8} | {'max error':>12} | {'L2 error':>12}")
    print("-" * 38)
    for c in [0.1, 0.5, 1, 2, 5, 10, 20, 50]:
        approx = (softplus(x) - softplus(x + c)) / (-c)
        max_err = np.max(np.abs(approx - target))
        l2_err = np.sqrt(np.mean((approx - target)**2))
        print(f"{c:>8.1f} | {max_err:>12.8f} | {l2_err:>12.8f}")

    # Strategy 2: Affine combination of shifted softplus
    print("\nAffine combination: Σ aᵢ σ(x + bᵢ) + c")
    # Simple 2-term: a₁σ(x+b₁) + a₂σ(x+b₂) + c
    # Best fit for sigmoid: S(x) ≈ σ(x) - σ(0) ≈ ... nah
    # The fundamental limit: σ(x) - x = σ(-x) → 0, so σ compositions stay "big"

    # Try fitting with gradient-free optimization
    best_err = float('inf')
    best_params = None
    np.random.seed(42)
    for _ in range(10000):
        a1, a2 = np.random.uniform(-2, 2, 2)
        b1, b2 = np.random.uniform(-5, 5, 2)
        c0 = np.random.uniform(-2, 2)
        approx = a1 * softplus(x + b1) + a2 * softplus(x + b2) + c0
        err = np.max(np.abs(approx - target))
        if err < best_err:
            best_err = err
            best_params = (a1, a2, b1, b2, c0)

    a1, a2, b1, b2, c0 = best_params
    print(f"\nBest 2-term fit: {a1:.4f}·σ(x+{b1:.4f}) + {a2:.4f}·σ(x+{b2:.4f}) + {c0:.4f}")
    print(f"Max error: {best_err:.6f}")


# ─── Experiment 4: Exponential Decay of Corrections ───

def experiment_exponential_decay():
    """Verify that f(x) - L₊x → c₊ exponentially at +∞."""
    print("\n" + "=" * 60)
    print("Experiment 4: Exponential Decay of Corrections")
    print("=" * 60)

    print("\nFor σ(x): σ(x) - x = log(1 + e⁻ˣ)")
    print(f"{'x':>6} | {'σ(x)-x':>16} | {'e⁻ˣ':>16} | {'ratio':>10}")
    print("-" * 56)
    for xv in [1, 2, 5, 10, 20, 50]:
        correction = softplus(xv) - xv
        exp_val = np.exp(-xv)
        ratio = correction / exp_val if exp_val > 1e-20 else float('nan')
        print(f"{xv:>6} | {correction:>16.12f} | {exp_val:>16.12f} | {ratio:>10.6f}")

    print("\n→ Ratio → 1 confirms σ(x) - x ≈ e⁻ˣ (exponential decay)")

    print("\nFor σ(σ(x)): σ(σ(x)) - x at +∞:")
    print(f"{'x':>6} | {'σ(σ(x))-x':>16} | {'log(2)+e⁻ˣ':>16}")
    print("-" * 44)
    for xv in [1, 2, 5, 10, 20]:
        val = softplus(softplus(xv)) - xv
        approx = np.log(2) + np.exp(-xv)
        print(f"{xv:>6} | {val:>16.10f} | {approx:>16.10f}")


# ─── Experiment 5: Q36 Investigation ───

def experiment_q36_tanh():
    """Numerical investigation of whether tanh ∈ ShefferAlg."""
    print("\n" + "=" * 60)
    print("Experiment 5: Q36 - Is tanh in ShefferAlg?")
    print("=" * 60)

    x = np.linspace(-5, 5, 1000)
    target = np.tanh(x)

    # tanh(x) = 2S(2x) - 1
    verify = 2 * sigmoid(2*x) - 1
    print(f"\nVerification: max|tanh(x) - (2S(2x)-1)| = {np.max(np.abs(target - verify)):.2e}")

    # Key properties of tanh:
    print("\ntanh properties (all barriers satisfied):")
    print(f"  Analytic: ✓ (ratio of exp functions)")
    print(f"  Lipschitz: ✓ (|tanh'| = sech² ≤ 1)")
    print(f"  Deriv conv: ✓ (tanh'→0 at ±∞)")
    print(f"  Bounded: ✓ (-1 < tanh < 1)")

    # Check: is log(sigmoid) related to known Sheffer expressions?
    print("\nlog(S(x)) = x - σ(x) values:")
    for xv in [-3, -1, 0, 1, 3]:
        ls = xv - softplus(xv)
        ms = -softplus(-xv)
        print(f"  x={xv:>3}: log(S({xv})) = {ls:.6f}, -σ(-{xv}) = {ms:.6f}, match: {abs(ls-ms)<1e-10}")

    print("\n→ Q36 & Q38 are EQUIVALENT (proved in Lean): tanh ∈ S ⟺ sigmoid ∈ S")
    print("→ log(S(x)) = x - σ(x) IS in ShefferAlg, but S(x) = exp(log(S(x))) requires exp")
    print("→ This suggests S ∉ ShefferAlg, since exp ∉ ShefferAlg")


# ─── Experiment 6: Conjectured Fourth Barrier ───

def experiment_fourth_barrier():
    """Investigate the conjectured fourth barrier: asymptotic exponential decay."""
    print("\n" + "=" * 60)
    print("Experiment 6: Fourth Barrier - Asymptotic Structure")
    print("=" * 60)

    # For compositions σ(σ(x)): what's the decay rate?
    print("\nDecay rates for various Sheffer expressions:")
    print(f"{'Expression':>20} | {'Decay at +∞':>20} | {'Rate':>10}")
    print("-" * 56)

    x_vals = np.array([10.0, 20.0, 50.0])

    # σ(x) - x: decays like e⁻ˣ
    corrections = softplus(x_vals) - x_vals
    rates = -np.diff(np.log(corrections)) / np.diff(x_vals)
    print(f"{'σ(x) - x':>20} | {'e⁻ˣ':>20} | {rates[0]:>10.6f}")

    # σ(σ(x)) - x: log(2) + O(e⁻ˣ)
    corrections = softplus(softplus(x_vals)) - x_vals - np.log(2)
    rates = -np.diff(np.log(np.abs(corrections))) / np.diff(x_vals)
    print(f"{'σ(σ(x)) - x - log2':>20} | {'e⁻ˣ':>20} | {rates[0]:>10.6f}")

    # 2σ(x) - x: decays like 2e⁻ˣ
    corrections = 2*softplus(x_vals) - x_vals - softplus(0)
    # Actually 2σ(x) - x = x + 2log(1+e⁻ˣ) - x = 2log(1+e⁻ˣ) → 0

    print("\n→ Conjecture: All Sheffer expressions have exponential decay")
    print("   f(x) - L₊x - c₊ = O(e⁻ᵅˣ) as x → +∞ for some α > 0")


# ─── Main ───

if __name__ == '__main__':
    print("=" * 60)
    print("Sheffer Algebra Numerical Explorer (v7)")
    print("=" * 60)

    experiment_orbit_merging()
    experiment_derivative_limits()
    experiment_sigmoid_approximation()
    experiment_exponential_decay()
    experiment_q36_tanh()
    experiment_fourth_barrier()

    print("\n" + "=" * 60)
    print("All experiments complete!")
    print("=" * 60)
