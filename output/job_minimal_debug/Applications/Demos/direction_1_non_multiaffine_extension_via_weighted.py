#!/usr/bin/env python3
"""
applications.py — Real-world Applications of the Quadratic Shadow Theorem

Demonstrates how the shadow theorem applies to:
1. Hessian sparsity prediction for optimization
2. Partition function analysis in statistical physics
3. Complexity bounds for symbolic differentiation
"""

from typing import Dict, Set, Tuple, List
from itertools import combinations
from collections import defaultdict

Exponent = Tuple[int, ...]


def compute_quadratic_shadow(support: Set[Exponent], n_vars: int) -> Set[Exponent]:
    """Compute Sh₂(S)."""
    shadow: Set[Exponent] = set()
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            ai = list(alpha)
            ai[i] -= 1
            for j in range(n_vars):
                if ai[j] < 1:
                    continue
                beta = list(ai)
                beta[j] -= 1
                shadow.add(tuple(beta))
    return shadow


# =============================================================================
# APPLICATION 1: Hessian Sparsity Prediction for Optimization
# =============================================================================

def predict_hessian_sparsity(support: Set[Exponent], n_vars: int) -> List[Tuple[int, int]]:
    """
    Predict which entries (i,j) of the Hessian matrix H_f can be nonzero,
    purely from Newton support data — no symbolic differentiation needed.
    
    H_f[i,j](x) = ∂²f/∂xᵢ∂xⱼ is nonzero as a polynomial iff there exists
    some β with β + eᵢ + eⱼ ∈ support(f).
    
    This is a direct application of the shadow theorem to optimization:
    knowing the Hessian sparsity pattern enables efficient second-order methods.
    
    Returns: list of (i,j) pairs where H_f[i,j] is potentially nonzero.
    """
    nonzero_entries = []
    for i in range(n_vars):
        for j in range(i, n_vars):
            # Check if there exists α ∈ S with α_i ≥ 1 and (α-eᵢ)_j ≥ 1
            has_witness = False
            for alpha in support:
                if i == j:
                    if alpha[i] >= 2:
                        has_witness = True
                        break
                else:
                    if alpha[i] >= 1 and alpha[j] >= 1:
                        has_witness = True
                        break
            if has_witness:
                nonzero_entries.append((i, j))
    return nonzero_entries


# =============================================================================
# APPLICATION 2: Partition Function Shadow Analysis
# =============================================================================

def partition_function_shadow(
    energy_levels: List[Exponent],
    n_species: int
) -> Dict[str, any]:
    """
    Analyze the second-order response structure of a partition function.
    
    In statistical physics, a partition function Z = Σ_α c_α x^α encodes
    the thermodynamic properties of a system. The support corresponds to
    accessible energy configurations. Second derivatives of log(Z) give
    susceptibilities and correlations.
    
    The shadow theorem tells us: the set of second-order response modes
    is predicted purely by the shadow of the energy landscape support.
    
    Returns analysis dictionary.
    """
    support = set(energy_levels)
    shadow = compute_quadratic_shadow(support, n_species)
    
    # Compute multiplicity for each shadow point
    multiplicities = defaultdict(int)
    for alpha in support:
        for i in range(n_species):
            if alpha[i] < 1:
                continue
            ai = list(alpha)
            ai[i] -= 1
            for j in range(n_species):
                if ai[j] < 1:
                    continue
                beta = list(ai)
                beta[j] -= 1
                multiplicities[tuple(beta)] += 1
    
    return {
        "support_size": len(support),
        "shadow_size": len(shadow),
        "total_multiplicity": sum(multiplicities.values()),
        "max_multiplicity": max(multiplicities.values()) if multiplicities else 0,
        "avg_multiplicity": sum(multiplicities.values()) / len(shadow) if shadow else 0,
        "shadow_points": sorted(shadow),
        "multiplicities": dict(multiplicities),
    }


# =============================================================================
# APPLICATION 3: Symbolic Differentiation Complexity
# =============================================================================

def differentiation_complexity_bound(
    support: Set[Exponent],
    n_vars: int
) -> Dict[str, int]:
    """
    Compute complexity bounds for symbolic Hessian computation.
    
    The shadow theorem gives a tight bound on the number of nonzero
    monomials across ALL second partial derivatives:
    
    Σ_{i,j} |supp(∂ᵢ∂ⱼf)| ≤ |S| · n²
    
    but the number of DISTINCT monomials appearing is exactly |Sh₂(S)|.
    
    This is relevant for:
    - Sparse automatic differentiation
    - Arithmetic circuit lower bounds  
    - Hessian compression in optimization
    """
    shadow = compute_quadratic_shadow(support, n_vars)
    
    # Count exact monomials per derivative
    deriv_counts = {}
    for i in range(n_vars):
        for j in range(i, n_vars):
            count = 0
            for alpha in support:
                if i == j:
                    if alpha[i] >= 2:
                        count += 1
                else:
                    if alpha[i] >= 1 and alpha[j] >= 1:
                        count += 1
            if count > 0:
                deriv_counts[(i,j)] = count
    
    return {
        "support_size": len(support),
        "n_vars": n_vars,
        "shadow_size": len(shadow),
        "naive_bound": len(support) * n_vars * n_vars,
        "nonzero_hessian_entries": len(deriv_counts),
        "total_deriv_monomials": sum(deriv_counts.values()),
        "max_deriv_monomials": max(deriv_counts.values()) if deriv_counts else 0,
    }


def main():
    print("="*60)
    print("APPLICATION 1: Hessian Sparsity Prediction")
    print("="*60)
    
    # A sparse polynomial in 5 variables
    S = {(3,0,0,0,0), (0,3,0,0,0), (1,1,1,0,0), (0,0,0,2,1), (0,0,0,1,2)}
    n = 5
    
    nonzero = predict_hessian_sparsity(S, n)
    total_entries = n * (n + 1) // 2
    print(f"\nPolynomial support: {sorted(S)}")
    print(f"Variables: {n}")
    print(f"Nonzero Hessian entries: {len(nonzero)} / {total_entries}")
    print(f"Sparsity: {1 - len(nonzero)/total_entries:.1%}")
    print(f"Nonzero positions: {nonzero}")
    print(f"→ Only {len(nonzero)} entries need computation, not {total_entries}!")
    
    print(f"\n{'='*60}")
    print("APPLICATION 2: Partition Function Analysis")
    print("="*60)
    
    # Model: 3-species system with specific energy configurations
    energy_configs = [
        (2,1,0), (1,2,0), (0,2,1), (0,1,2), (1,0,2), (2,0,1),
        (3,0,0), (0,3,0), (0,0,3)
    ]
    result = partition_function_shadow(energy_configs, 3)
    print(f"\nEnergy configurations: {len(result['support_size'])} states" 
          if isinstance(result['support_size'], list) 
          else f"\nEnergy configurations: {result['support_size']} states")
    print(f"Second-order response modes: {result['shadow_size']}")
    print(f"Total collision multiplicity: {result['total_multiplicity']}")
    print(f"Max multiplicity at single mode: {result['max_multiplicity']}")
    print(f"Average multiplicity: {result['avg_multiplicity']:.1f}")
    print(f"→ All {result['shadow_size']} response modes are predicted by shadow geometry!")
    
    print(f"\n{'='*60}")
    print("APPLICATION 3: Symbolic Differentiation Complexity")
    print("="*60)
    
    # Compare complexity for different polynomial families
    families = {
        "Pure powers (x⁴+y⁴+z⁴)": {(4,0,0), (0,4,0), (0,0,4)},
        "Full degree 3 in 3 vars": set(_compositions(3, 3)),
        "Sparse degree 5 in 4 vars": {(5,0,0,0), (0,5,0,0), (0,0,5,0), (0,0,0,5), (2,2,1,0), (0,1,2,2)},
    }
    
    print(f"\n{'Family':<35} {'|S|':>4} {'|Sh₂|':>6} {'Naive':>7} {'Savings':>8}")
    print("-" * 65)
    for name, S in families.items():
        n = len(next(iter(S)))
        result = differentiation_complexity_bound(S, n)
        savings = 1 - result['shadow_size'] / result['naive_bound'] if result['naive_bound'] > 0 else 0
        print(f"{name:<35} {result['support_size']:>4} {result['shadow_size']:>6} {result['naive_bound']:>7} {savings:>7.1%}")
    
    print(f"\n→ Shadow complexity is always ≤ naive bound, often much smaller.")
    print(f"→ This is the computational content of the shadow theorem.")


def _compositions(d, n):
    """Generate weak compositions."""
    if n == 0:
        if d == 0:
            yield ()
        return
    if n == 1:
        yield (d,)
        return
    for first in range(d + 1):
        for rest in _compositions(d - first, n - 1):
            yield (first,) + rest


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Demonstrates the Quadratic Shadow Theorem for Homogeneous Polynomials

Constructs example homogeneous polynomials, computes their Newton support and
quadratic shadow, computes actual second-derivative leaves, and compares them.
Also searches for cancellation counterexamples.
"""

from itertools import product
from collections import defaultdict
import sys


def partitions_of_d_into_n(d, n):
    """Generate all compositions of d into n nonneg parts (weak compositions)."""
    if n == 0:
        if d == 0:
            yield ()
        return
    if n == 1:
        yield (d,)
        return
    for first in range(d + 1):
        for rest in partitions_of_d_into_n(d - first, n - 1):
            yield (first,) + rest


def quadratic_shadow(support, n_vars):
    """
    Compute Sh_2(S) = {β : ∃ α ∈ S, ∃ i,j, α = β + e_i + e_j}.
    Equivalently, β ∈ Sh_2(S) iff ∃ α ∈ S, ∃ i,j such that
    α - e_i - e_j = β with α_i ≥ 1 and (α-e_i)_j ≥ 1.
    """
    shadow = set()
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            alpha_minus_ei = list(alpha)
            alpha_minus_ei[i] -= 1
            for j in range(n_vars):
                if alpha_minus_ei[j] < 1:
                    continue
                beta = list(alpha_minus_ei)
                beta[j] -= 1
                shadow.add(tuple(beta))
    return shadow


def shadow_multiplicity(support, n_vars, beta):
    """Count the number of (α, i, j) witnesses for β in Sh_2(S)."""
    count = 0
    beta_t = tuple(beta)
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            alpha_minus_ei = list(alpha)
            alpha_minus_ei[i] -= 1
            for j in range(n_vars):
                if alpha_minus_ei[j] < 1:
                    continue
                test = list(alpha_minus_ei)
                test[j] -= 1
                if tuple(test) == beta_t:
                    count += 1
    return count


def coeff_second_deriv(coeffs, n_vars, i, j, beta):
    """
    Compute the coefficient of x^β in ∂_j(∂_i f).
    
    coeff_β(∂_j(∂_i f)) = coeff_{β+e_j+e_i}(f) * ((β+e_j)_i + 1) * (β_j + 1)
    
    For individual second partial derivatives, this is a SINGLE term—
    no cancellation can occur!
    """
    ancestor = list(beta)
    ancestor[j] += 1
    ancestor[i] += 1
    ancestor_t = tuple(ancestor)
    
    if ancestor_t not in coeffs:
        return 0
    
    c = coeffs[ancestor_t]
    # Numerical factor
    beta_plus_ej = list(beta)
    beta_plus_ej[j] += 1
    factor = beta_plus_ej[i] + 1  # (β+e_j)(i) + 1 -- but wait, if i==j this is β_i+2
    factor *= (beta[j] + 1)
    
    # Actually, for i==j: ancestor = β + 2e_i, factor = (β_i+2)*(β_i+1)
    # For i≠j: ancestor = β + e_i + e_j, factor = (β_i+1)*(β_j+1)
    return c * factor


def actual_leaf_set(coeffs, n_vars, degree):
    """
    Compute the actual nonzero quadratic leaf set:
    {β : ∃ i,j, coeff_β(∂_i∂_j f) ≠ 0}
    """
    leaves = set()
    # β must have degree d-2
    target_deg = degree - 2
    if target_deg < 0:
        return leaves
    
    for beta in partitions_of_d_into_n(target_deg, n_vars):
        for i in range(n_vars):
            for j in range(n_vars):
                c = coeff_second_deriv(coeffs, n_vars, i, j, list(beta))
                if c != 0:
                    leaves.add(beta)
                    break
            else:
                continue
            break
    return leaves


def demo_polynomial(name, n_vars, degree, coeffs):
    """Run the full analysis on a polynomial."""
    print(f"\n{'='*60}")
    print(f"  {name}")
    print(f"  Variables: {n_vars}, Degree: {degree}")
    print(f"{'='*60}")
    
    support = set(coeffs.keys())
    print(f"\nNewton support ({len(support)} monomials):")
    for alpha in sorted(support):
        print(f"  x^{alpha} with coeff {coeffs[alpha]}")
    
    shadow = quadratic_shadow(support, n_vars)
    print(f"\nQuadratic shadow Sh_2(S) ({len(shadow)} points):")
    for beta in sorted(shadow):
        mult = shadow_multiplicity(support, n_vars, beta)
        print(f"  {beta}  (multiplicity = {mult})")
    
    leaves = actual_leaf_set(coeffs, n_vars, degree)
    print(f"\nActual nonzero quadratic leaves ({len(leaves)} points):")
    for beta in sorted(leaves):
        print(f"  {beta}")
    
    # Verify the theorem
    if leaves == shadow:
        print(f"\n✓ THEOREM VERIFIED: Leaf set = Shadow (exact equality)")
    elif leaves <= shadow:
        print(f"\n⊂ Leaf set ⊂ Shadow (strict containment — cancellation occurred!)")
        missing = shadow - leaves
        print(f"  Shadow points NOT in leaf set: {sorted(missing)}")
    else:
        print(f"\n✗ ERROR: Leaf set NOT contained in shadow!")
    
    return leaves, shadow


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Quadratic Shadow Theorem: Demonstration & Verification ║")
    print("╠══════════════════════════════════════════════════════════╣")
    print("║  For any polynomial f over a domain of char 0:          ║")
    print("║  NonzeroQuadLeafSet(f) = QuadraticShadow(Supp(f))       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    # Example 1: x^3 + y^3 + z^3 (degree 3 in 3 variables, non-multiaffine)
    coeffs1 = {(3,0,0): 1, (0,3,0): 1, (0,0,3): 1}
    demo_polynomial("f = x³ + y³ + z³ (pure powers)", 3, 3, coeffs1)
    
    # Example 2: x²y + xy² + y²z + yz² + z²x + zx² (degree 3, positive coefficients)
    coeffs2 = {
        (2,1,0): 1, (1,2,0): 1,
        (0,2,1): 1, (0,1,2): 1,
        (1,0,2): 1, (2,0,1): 1
    }
    demo_polynomial("f = Σ x²y (Schur-like, positive coefficients)", 3, 3, coeffs2)
    
    # Example 3: Elementary symmetric polynomial e_3(x,y,z,w) = Σ xᵢxⱼxₖ
    # This is multiaffine, so our theory should match the classical result
    coeffs3 = {}
    for combo in [(1,1,1,0), (1,1,0,1), (1,0,1,1), (0,1,1,1)]:
        coeffs3[combo] = 1
    demo_polynomial("e₃(x,y,z,w) — multiaffine (classical case)", 4, 3, coeffs3)
    
    # Example 4: Power sum p_4(x,y,z) = x⁴ + y⁴ + z⁴
    coeffs4 = {(4,0,0): 1, (0,4,0): 1, (0,0,4): 1}
    demo_polynomial("p₄(x,y,z) = x⁴ + y⁴ + z⁴ (high-degree powers)", 3, 4, coeffs4)
    
    # Example 5: Full homogeneous polynomial (all monomials)
    coeffs5 = {}
    for alpha in partitions_of_d_into_n(3, 3):
        coeffs5[alpha] = 1
    demo_polynomial("Full degree-3 homogeneous in 3 vars (all coeffs = 1)", 3, 3, coeffs5)
    
    # Example 6: Search for cancellation counterexample over integers
    # Use negative coefficients to try to create cancellation
    print("\n" + "="*60)
    print("  CANCELLATION SEARCH (integer coefficients, mixed signs)")
    print("="*60)
    
    import random
    random.seed(42)
    
    found_strict = False
    n_trials = 1000
    for trial in range(n_trials):
        n = 3
        d = 4
        all_alphas = list(partitions_of_d_into_n(d, n))
        # Pick random subset of support
        k = random.randint(2, len(all_alphas))
        chosen = random.sample(all_alphas, k)
        # Random nonzero integer coefficients (allowing negatives)
        coeffs_trial = {}
        for alpha in chosen:
            c = random.choice([-3, -2, -1, 1, 2, 3])
            coeffs_trial[alpha] = c
        
        support = set(coeffs_trial.keys())
        shadow = quadratic_shadow(support, n)
        leaves = actual_leaf_set(coeffs_trial, n, d)
        
        if leaves < shadow:  # Strict containment
            found_strict = True
            print(f"\n  Trial {trial}: STRICT containment found!")
            print(f"  Polynomial: {coeffs_trial}")
            print(f"  Shadow size: {len(shadow)}, Leaf size: {len(leaves)}")
            print(f"  Shadow \\ Leaves: {shadow - leaves}")
            break
    
    if not found_strict:
        print(f"\n  No strict containment found in {n_trials} random trials.")
        print(f"  This is consistent with the theorem: over integral domains")
        print(f"  of characteristic 0, the equality ALWAYS holds.")
    
    # Example 7: Show that over Z/2Z (char 2), cancellation CAN occur
    print("\n" + "="*60)
    print("  CHARACTERISTIC 2 EXAMPLE (where the theorem fails)")
    print("="*60)
    
    # Over F_2: x^2*y + x*y^2 has degree 3 in 2 variables
    # ∂_x∂_y f = 2xy + ... ≡ 0 (mod 2) for some terms
    coeffs_f2 = {(2,1): 1, (1,2): 1}  # x²y + xy² over F_2
    n = 2
    d = 3
    support = set(coeffs_f2.keys())
    shadow = quadratic_shadow(support, n)
    
    print(f"\n  f = x²y + xy² over F₂")
    print(f"  Shadow: {sorted(shadow)}")
    
    # Over F_2, compute derivatives mod 2
    print(f"  Over F₂ (char 2):")
    for beta in sorted(shadow):
        for i in range(n):
            for j in range(n):
                c = coeff_second_deriv(coeffs_f2, n, i, j, list(beta))
                c_mod2 = c % 2
                if c != 0:
                    print(f"    coeff_{beta}(∂_{i}∂_{j} f) = {c} ≡ {c_mod2} (mod 2)")
    
    print("\n  The theorem requires CharZero and NoZeroDivisors.")
    print("  In characteristic 2, numerical factors (β_i+1) can vanish mod 2,")
    print("  breaking the bijection between ancestor and descendant nonvanishing.")
    
    print("\n" + "="*60)
    print("  SUMMARY")
    print("="*60)
    print("""
  The Quadratic Shadow Theorem states:
  
    NonzeroQuadLeafSet(f) = QuadraticShadow(Supp(f))
  
  for any polynomial f over a domain of characteristic zero.
  
  Key insight: Each coefficient of ∂ᵢ∂ⱼf at exponent β equals
  a NONZERO natural-number factor times the coefficient of f at
  the ancestor exponent β + eᵢ + eⱼ. Since these numerical
  factors are always ≥ 1, and we work in a domain of char 0,
  the coefficient vanishes iff the ancestor coefficient vanishes.
  
  This means cancellation NEVER occurs for individual second
  partial derivatives — a striking structural result.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Quadratic Shadow Multiplicity Heatmap

Visualizes the shadow multiplicity m_S(β) for degree-4 homogeneous polynomials
in 3 variables. Each point in the simplex of degree-2 exponents is colored by
its shadow multiplicity (number of ancestor paths). This reveals the geometric
structure of the shadow: high-multiplicity points have many "parents" in the
support, while boundary points have few.

Uses barycentric coordinates on the degree-2 simplex for 3 variables.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.tri as tri
from collections import defaultdict


def compositions(d, n):
    """Generate all weak compositions of d into n parts."""
    if n == 0:
        if d == 0:
            yield ()
        return
    if n == 1:
        yield (d,)
        return
    for first in range(d + 1):
        for rest in compositions(d - first, n - 1):
            yield (first,) + rest


def compute_shadow_with_multiplicity(support, n_vars):
    """Compute shadow with multiplicities."""
    result = defaultdict(int)
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            ai = list(alpha)
            ai[i] -= 1
            for j in range(n_vars):
                if ai[j] < 1:
                    continue
                beta = list(ai)
                beta[j] -= 1
                result[tuple(beta)] += 1
    return dict(result)


def barycentric_to_cartesian(a, b, c):
    """Convert barycentric coords (a,b,c) to 2D Cartesian for equilateral triangle."""
    total = a + b + c
    if total == 0:
        return 0, 0
    a, b, c = a/total, b/total, c/total
    x = 0.5 * (2*b + c)
    y = (np.sqrt(3)/2) * c
    return x, y


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Three polynomial families
families = [
    ("Pure Powers: x⁴+y⁴+z⁴", {(4,0,0), (0,4,0), (0,0,4)}),
    ("Symmetric: Σ x²y²", {(2,2,0), (2,0,2), (0,2,2)}),
    ("Full Degree 4", set(compositions(4, 3))),
]

for ax_idx, (name, support) in enumerate(families):
    ax = axes[ax_idx]
    n_vars = 3
    
    wsm = compute_shadow_with_multiplicity(support, n_vars)
    all_deg2 = list(compositions(2, 3))
    
    # Plot the shadow
    xs, ys, cs = [], [], []
    for beta in all_deg2:
        x, y = barycentric_to_cartesian(*beta)
        xs.append(x)
        ys.append(y)
        cs.append(wsm.get(beta, 0))
    
    xs, ys, cs = np.array(xs), np.array(ys), np.array(cs)
    
    # Draw triangle outline
    corners_x = [0, 1, 0.5, 0]
    corners_y = [0, 0, np.sqrt(3)/2, 0]
    ax.plot(corners_x, corners_y, 'k-', linewidth=1.5)
    
    # Color-code points by multiplicity
    scatter = ax.scatter(xs, ys, c=cs, s=300, cmap='YlOrRd', edgecolors='black',
                        linewidths=1, zorder=5, vmin=0,
                        vmax=max(max(cs), 1))
    
    # Label points
    for beta, x, y, c in zip(all_deg2, xs, ys, cs):
        label = f"{beta}\nm={int(c)}"
        ax.annotate(label, (x, y), textcoords="offset points",
                   xytext=(0, -25), ha='center', fontsize=7)
    
    # Label support points (degree 4, projected)
    ax.set_title(f"{name}\n|S|={len(support)}, |Sh₂|={len(wsm)}", fontsize=11)
    ax.set_xlim(-0.15, 1.15)
    ax.set_ylim(-0.25, 1.1)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Add variable labels
    ax.text(-0.08, -0.05, 'x', fontsize=12, fontweight='bold', color='blue')
    ax.text(1.04, -0.05, 'y', fontsize=12, fontweight='bold', color='blue')
    ax.text(0.48, np.sqrt(3)/2 + 0.06, 'z', fontsize=12, fontweight='bold', color='blue')

# Add colorbar
fig.subplots_adjust(right=0.92)
cbar_ax = fig.add_axes([0.94, 0.15, 0.02, 0.7])
cbar = fig.colorbar(scatter, cax=cbar_ax)
cbar.set_label('Shadow Multiplicity m_S(β)', fontsize=11)

fig.suptitle('Quadratic Shadow Structure on the Degree-2 Simplex\n'
             '(3 variables, degree 4 → degree 2 shadow)',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_shadow_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_shadow_heatmap.png")
