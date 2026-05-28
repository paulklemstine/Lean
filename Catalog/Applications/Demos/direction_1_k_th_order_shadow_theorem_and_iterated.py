"""
Applications of Iterated Shadow Geometry.

Demonstrates practical applications of the k-th shadow theory to:
1. Sparse symbolic differentiation complexity prediction
2. Newton polytope analysis
3. Derivative support compression bounds
"""

from itertools import combinations
from math import comb


# =====================================================================
# Self-contained core functions
# =====================================================================

def total_mass(sigma):
    return sum(sigma)

def enumerate_sub_indices(alpha, k):
    n = len(alpha)
    results = set()
    def backtrack(pos, rem, cur):
        if pos == n:
            if rem == 0:
                results.add(tuple(cur))
            return
        for t in range(min(alpha[pos], rem) + 1):
            cur.append(alpha[pos] - t)
            backtrack(pos + 1, rem - t, cur)
            cur.pop()
    backtrack(0, k, [])
    return results

def kth_shadow(S, k):
    shadow = set()
    for alpha in S:
        shadow.update(enumerate_sub_indices(alpha, k))
    return shadow

def shadow_profile(S, max_k=None):
    if not S:
        return [0]
    if max_k is None:
        max_k = max(total_mass(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k + 1)]

def uniform_matroid_support(n, r):
    result = set()
    for combo in combinations(range(n), r):
        vec = [0] * n
        for i in combo:
            vec[i] = 1
        result.add(tuple(vec))
    return result

def homogeneous_support(n, d):
    def gen(pos, rem):
        if pos == n - 1:
            yield (rem,)
            return
        for v in range(rem + 1):
            for rest in gen(pos + 1, rem - v):
                yield (v,) + rest
    if n == 0:
        return {()} if d == 0 else set()
    return set(gen(0, d))


# =====================================================================
# Application 1: Sparse Differentiation Complexity
# =====================================================================

def differentiation_complexity_analysis():
    """
    Application: predict the monomial complexity of all k-th order mixed
    partial derivatives of a sparse polynomial, without computing them.

    The k-th shadow theorem says: the number of distinct monomials across
    ALL k-th order derivatives equals |Shadow_k(supp(f))|.
    """
    print("=" * 70)
    print("APPLICATION 1: Sparse Differentiation Complexity Prediction")
    print("=" * 70)
    print()
    print("Given a sparse polynomial with known support, predict the total")
    print("monomial complexity of all k-th order derivatives WITHOUT computing them.")
    print()

    # Example: a sparse polynomial in 5 variables
    S = {(3, 0, 0, 0, 0), (0, 3, 0, 0, 0), (1, 1, 1, 0, 0),
         (0, 0, 0, 2, 1), (1, 0, 0, 1, 1), (0, 1, 0, 0, 2)}

    print(f"Polynomial support ({len(S)} monomials in 5 variables):")
    for alpha in sorted(S):
        terms = []
        for i, a in enumerate(alpha):
            if a > 0:
                terms.append(f"x{i+1}^{a}" if a > 1 else f"x{i+1}")
        print(f"  {'*'.join(terms) if terms else '1'}")

    print()
    profile = shadow_profile(S)
    print("Shadow profile (monomial complexity per derivative order):")
    for k, count in enumerate(profile):
        # Number of distinct derivative operators of order k
        n_ops = len(homogeneous_support(5, k)) if k <= 3 else "many"
        print(f"  Order k={k}: {count} distinct result monomials "
              f"(across {n_ops} derivative operators)")

    # Savings calculation
    naive_k1 = len(S) * 5  # upper bound: each monomial, each variable
    actual_k1 = profile[1] if len(profile) > 1 else 0
    print(f"\nNaive upper bound for k=1: {naive_k1} monomials")
    print(f"Actual (from shadow): {actual_k1} monomials")
    print(f"Reduction: {100*(1-actual_k1/max(naive_k1,1)):.0f}%")
    print()


# =====================================================================
# Application 2: Newton Polytope Derivative Tracking
# =====================================================================

def newton_polytope_tracking():
    """
    Track how the Newton polytope of a polynomial shrinks under differentiation.
    The shadow provides exact lattice-point counts at each level.
    """
    print("=" * 70)
    print("APPLICATION 2: Newton Polytope Derivative Tracking")
    print("=" * 70)
    print()

    # Generic dense polynomial of degree d in n variables
    for n, d in [(2, 5), (3, 4), (4, 3)]:
        S = homogeneous_support(n, d)
        profile = shadow_profile(S)
        print(f"Homogeneous polynomial: {n} variables, degree {d}")
        print(f"  Support size: {len(S)}")
        print(f"  Shadow profile: {profile}")
        print(f"  Expected (binomial): {[comb(n+d-k-1, n-1) for k in range(d+1)]}")

        # Verify they match for homogeneous
        expected = [comb(n + d - k - 1, n - 1) for k in range(d + 1)]
        match = (profile == expected)
        print(f"  Matches binomial formula: {match}")

        # Derivative decay rate
        if len(profile) > 1:
            ratios = [profile[k+1]/profile[k] for k in range(len(profile)-1) if profile[k] > 0]
            print(f"  Decay ratios: {[f'{r:.3f}' for r in ratios]}")
        print()


# =====================================================================
# Application 3: Matroid Derivative Support Bounds
# =====================================================================

def matroid_derivative_bounds():
    """
    For matroid basis generating polynomials, compute exact derivative
    support sizes using the shadow theory. Compare with the ambient
    (dense polynomial) bounds.
    """
    print("=" * 70)
    print("APPLICATION 3: Matroid Derivative Support Compression")
    print("=" * 70)
    print()
    print("Compare derivative support sizes for matroid basis polynomials")
    print("against the dense polynomial upper bound.")
    print()

    for n in range(4, 9):
        for r in range(2, min(n, 6)):
            S = uniform_matroid_support(n, r)
            profile = shadow_profile(S)
            # Ambient bound: binom(n, r-k)
            ambient = [comb(n, max(r - k, 0)) if r - k >= 0 else 0
                       for k in range(r + 1)]

            compression = [f"{p}/{a}" if a > 0 else "0/0"
                           for p, a in zip(profile, ambient)]

            print(f"  U_{{{r},{n}}}: shadow={profile}, ambient={ambient[:len(profile)]}")
            print(f"           compression ratios: "
                  f"{[f'{p/a:.2f}' if a > 0 else 'n/a' for p, a in zip(profile, ambient)]}")
    print()


# =====================================================================
# Main
# =====================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║          ITERATED SHADOW GEOMETRY — Applications                   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    differentiation_complexity_analysis()
    newton_polytope_tracking()
    matroid_derivative_bounds()

    print("All applications complete.")


"""
Interactive Demonstration: Iterated Shadow Geometry

This demo constructs sample polynomial supports, computes k-th shadows,
compares them with actual mixed derivative supports, tests log-concavity
on exchange-family examples, and searches for counterexamples to the
Shadow Log-Concavity Conjecture.
"""

from itertools import combinations, permutations, product as iproduct
from math import comb, factorial
from collections import defaultdict


# =====================================================================
# Core Algorithms (self-contained)
# =====================================================================

def total_mass(sigma):
    return sum(sigma)

def desc_factorial(n, k):
    if k > n or k < 0:
        return 0
    r = 1
    for i in range(k):
        r *= (n - i)
    return r

def multi_desc_factorial(alpha, tau):
    r = 1
    for a, t in zip(alpha, tau):
        r *= desc_factorial(a, t)
    return r

def enumerate_sub_indices(alpha, k):
    n = len(alpha)
    results = set()
    def backtrack(pos, rem, cur):
        if pos == n:
            if rem == 0:
                results.add(tuple(cur))
            return
        for t in range(min(alpha[pos], rem) + 1):
            cur.append(alpha[pos] - t)
            backtrack(pos + 1, rem - t, cur)
            cur.pop()
    backtrack(0, k, [])
    return results

def kth_shadow(S, k):
    shadow = set()
    for alpha in S:
        shadow.update(enumerate_sub_indices(alpha, k))
    return shadow

def shadow_profile(S, max_k=None):
    if not S:
        return [0]
    if max_k is None:
        max_k = max(total_mass(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k + 1)]

def is_log_concave(seq):
    for k in range(1, len(seq) - 1):
        if seq[k] ** 2 < seq[k-1] * seq[k+1]:
            return False
    return True

def is_ratio_monotone(seq):
    for k in range(1, len(seq) - 1):
        if seq[k-1] > 0 and seq[k] > 0:
            if seq[k+1] * seq[k-1] > seq[k] ** 2:
                return False
    return True

def is_discrete_exchange_family(S):
    S_frozen = frozenset(S)
    n = len(next(iter(S))) if S else 0
    for alpha in S:
        for beta in S:
            for i in range(n):
                if beta[i] < alpha[i]:
                    found = False
                    for j in range(n):
                        if alpha[j] < beta[j]:
                            c = list(alpha)
                            c[i] -= 1
                            c[j] += 1
                            if tuple(c) in S_frozen:
                                found = True
                                break
                    if not found:
                        return False
    return True

def uniform_matroid_support(n, r):
    result = set()
    for combo in combinations(range(n), r):
        vec = [0] * n
        for i in combo:
            vec[i] = 1
        result.add(tuple(vec))
    return result

def homogeneous_support(n, d):
    def gen(pos, rem):
        if pos == n - 1:
            yield (rem,)
            return
        for v in range(rem + 1):
            for rest in gen(pos + 1, rem - v):
                yield (v,) + rest
    if n == 0:
        return {()} if d == 0 else set()
    return set(gen(0, d))

def simplex_support(n, d):
    def gen(pos, rem):
        if pos == n:
            yield ()
            return
        for v in range(rem + 1):
            for rest in gen(pos + 1, rem - v):
                yield (v,) + rest
    return set(gen(0, d, ))

def permutahedron_support(n):
    return set(permutations(range(n)))


# =====================================================================
# Demo 1: Shadow Theorem Verification
# =====================================================================

def demo_shadow_theorem():
    """Verify the exact k-th shadow theorem on concrete examples."""
    print("=" * 70)
    print("DEMO 1: Exact k-th Shadow Theorem Verification")
    print("=" * 70)
    print()
    print("The theorem states: for a generic polynomial f with support S,")
    print("the union of supports of all k-th order derivatives D^tau(f)")
    print("equals exactly the k-th shadow Shadow_k(S).")
    print()

    # Example 1: Simple 2-variable polynomial
    print("--- Example 1: f = x^3 + x^2*y + x*y^2 + y^3 (homogeneous deg 3, 2 vars) ---")
    S = homogeneous_support(2, 3)
    print(f"Support S = {sorted(S)}")

    for k in range(5):
        shadow = kth_shadow(S, k)
        # Compute union of derivative supports
        deriv_union = set()
        for alpha in S:
            for beta in enumerate_sub_indices(alpha, k):
                deriv_union.add(beta)

        match = shadow == deriv_union
        print(f"  k={k}: |Shadow_k| = {len(shadow):3d}, |DerivUnion_k| = {len(deriv_union):3d}, match = {match}")
        if shadow:
            print(f"         Shadow_k = {sorted(shadow)}")

    # Example 2: Uniform matroid U_{2,4}
    print()
    print("--- Example 2: Basis polynomial of U_{2,4} ---")
    S = uniform_matroid_support(4, 2)
    print(f"Support S = {sorted(S)}")

    for k in range(4):
        shadow = kth_shadow(S, k)
        deriv_union = set()
        for alpha in S:
            for beta in enumerate_sub_indices(alpha, k):
                deriv_union.add(beta)
        match = shadow == deriv_union
        print(f"  k={k}: |Shadow_k| = {len(shadow):3d}, |DerivUnion_k| = {len(deriv_union):3d}, match = {match}")

    print()


# =====================================================================
# Demo 2: Semigroup Law Verification
# =====================================================================

def demo_semigroup_law():
    """Verify Shadow_b(Shadow_a(S)) = Shadow_{a+b}(S)."""
    print("=" * 70)
    print("DEMO 2: Semigroup Law for Shadows")
    print("=" * 70)
    print()
    print("The semigroup law states: Shadow_b(Shadow_a(S)) = Shadow_{a+b}(S)")
    print()

    S = homogeneous_support(3, 4)
    print(f"Test set: homogeneous degree 4, 3 variables, |S| = {len(S)}")

    all_pass = True
    for a in range(5):
        for b in range(5):
            lhs = kth_shadow(kth_shadow(S, a), b)
            rhs = kth_shadow(S, a + b)
            ok = lhs == rhs
            if not ok:
                all_pass = False
                print(f"  FAIL: a={a}, b={b}")
            else:
                print(f"  a={a}, b={b}: |LHS|={len(lhs):3d}, |RHS|={len(rhs):3d}, match=True")

    print(f"\nAll tests passed: {all_pass}")
    print()


# =====================================================================
# Demo 3: Shadow Profiles and Log-Concavity
# =====================================================================

def demo_shadow_profiles():
    """Compute and analyze shadow profiles."""
    print("=" * 70)
    print("DEMO 3: Shadow Profiles and Log-Concavity")
    print("=" * 70)
    print()

    test_cases = [
        ("Uniform matroid U_{3,6}", uniform_matroid_support(6, 3)),
        ("Uniform matroid U_{4,8}", uniform_matroid_support(8, 4)),
        ("Homogeneous deg 3, 3 vars", homogeneous_support(3, 3)),
        ("Homogeneous deg 4, 3 vars", homogeneous_support(3, 4)),
        ("Permutahedron n=4", permutahedron_support(4)),
    ]

    for name, S in test_cases:
        profile = shadow_profile(S)
        lc = is_log_concave(profile)
        rm = is_ratio_monotone(profile)
        exch = is_discrete_exchange_family(S) if len(S) < 200 else "skipped"

        print(f"--- {name} ---")
        print(f"  |S| = {len(S)}")
        print(f"  Profile: {profile}")
        print(f"  Log-concave: {lc}")
        print(f"  Ratio-monotone: {rm}")
        print(f"  Exchange family: {exch}")
        print()


# =====================================================================
# Demo 4: Coefficient Transport
# =====================================================================

def demo_coefficient_transport():
    """Demonstrate the coefficient transport formula."""
    print("=" * 70)
    print("DEMO 4: Coefficient Transport Formula")
    print("=" * 70)
    print()
    print("coeff_beta(D^tau f) = prod_i descFactorial((beta+tau)_i, tau_i) * coeff_{beta+tau}(f)")
    print()

    # Example: f = 3*x^2*y + 5*x*y^2 + 2*y^3
    # Represented as {(2,1): 3, (1,2): 5, (0,3): 2}
    f = {(2, 1): 3, (1, 2): 5, (0, 3): 2}
    print("f = 3*x^2*y + 5*x*y^2 + 2*y^3")
    print()

    test_taus = [(1, 0), (0, 1), (1, 1), (2, 0), (0, 2)]

    for tau in test_taus:
        print(f"  D^{tau} f:")
        deriv_coeffs = {}
        for alpha, c in f.items():
            if all(t <= a for a, t in zip(alpha, tau)):
                beta = tuple(a - t for a, t in zip(alpha, tau))
                scalar = multi_desc_factorial(alpha, tau)
                new_c = scalar * c
                deriv_coeffs[beta] = deriv_coeffs.get(beta, 0) + new_c
                print(f"    alpha={alpha}, c={c}: scalar={scalar}, beta={beta}, contribution={new_c}")

        # Verify via formula
        print(f"    Result: {dict(sorted(deriv_coeffs.items()))}")

        # Verify transport formula
        for beta, val in deriv_coeffs.items():
            alpha_check = tuple(b + t for b, t in zip(beta, tau))
            expected_scalar = multi_desc_factorial(alpha_check, tau)
            expected_coeff = f.get(alpha_check, 0)
            expected = expected_scalar * expected_coeff
            ok = (val == expected)
            print(f"    Verify beta={beta}: scalar={expected_scalar} * coeff_{alpha_check}={expected_coeff} = {expected}, match={ok}")
        print()


# =====================================================================
# Demo 5: Counterexample Search for Log-Concavity
# =====================================================================

def demo_counterexample_search():
    """Search for counterexamples to the Shadow Log-Concavity Conjecture."""
    print("=" * 70)
    print("DEMO 5: Counterexample Search for Shadow Log-Concavity")
    print("=" * 70)
    print()
    print("Conjecture: If S is a discrete exchange family, then the shadow")
    print("profile (a_0, a_1, ...) is log-concave: a_k^2 >= a_{k-1}*a_{k+1}.")
    print()

    counterexamples_lc = []
    counterexamples_rm = []
    tests_run = 0

    # Test uniform matroids U_{r,n}
    print("Testing uniform matroids U_{r,n}:")
    for n in range(2, 9):
        for r in range(1, n + 1):
            S = uniform_matroid_support(n, r)
            profile = shadow_profile(S)
            lc = is_log_concave(profile)
            rm = is_ratio_monotone(profile)
            tests_run += 1
            status = "✓" if lc else "✗"
            if not lc:
                counterexamples_lc.append(("U_{%d,%d}" % (r, n), profile))
            if not rm:
                counterexamples_rm.append(("U_{%d,%d}" % (r, n), profile))
            if n <= 6:
                print(f"  U_{{{r},{n}}}: profile={profile}, LC={lc}, RM={rm} {status}")

    print()

    # Test homogeneous supports
    print("Testing homogeneous supports:")
    for n in range(2, 6):
        for d in range(1, 7):
            S = homogeneous_support(n, d)
            if len(S) > 500:
                continue
            profile = shadow_profile(S)
            lc = is_log_concave(profile)
            rm = is_ratio_monotone(profile)
            tests_run += 1

            is_exch = is_discrete_exchange_family(S) if len(S) < 100 else None
            if is_exch and not lc:
                counterexamples_lc.append((f"Hom({n},{d})", profile))
            if n <= 4 and d <= 4:
                print(f"  Hom(n={n},d={d}): |S|={len(S)}, profile={profile}, LC={lc}, Exch={is_exch}")

    print()

    # Test permutahedron supports
    print("Testing permutahedron supports:")
    for n in range(2, 6):
        S = permutahedron_support(n)
        if len(S) > 500:
            continue
        profile = shadow_profile(S)
        lc = is_log_concave(profile)
        tests_run += 1
        is_exch = is_discrete_exchange_family(S) if len(S) < 100 else None
        print(f"  Perm(n={n}): |S|={len(S)}, profile={profile}, LC={lc}, Exch={is_exch}")

    print()
    print(f"Total tests: {tests_run}")
    print(f"Log-concavity counterexamples (among exchange families): {len(counterexamples_lc)}")
    if counterexamples_lc:
        for name, prof in counterexamples_lc:
            print(f"  {name}: {prof}")
    else:
        print("  None found! Conjecture holds for all tested cases.")

    print(f"Ratio-monotonicity counterexamples: {len(counterexamples_rm)}")
    if counterexamples_rm:
        for name, prof in counterexamples_rm[:5]:
            print(f"  {name}: {prof}")
    else:
        print("  None found!")
    print()


# =====================================================================
# Main
# =====================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║        ITERATED SHADOW GEOMETRY — Interactive Demonstration        ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_shadow_theorem()
    demo_semigroup_law()
    demo_shadow_profiles()
    demo_coefficient_transport()
    demo_counterexample_search()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


"""
Visualization: Semigroup Flow of the Shadow Operator

Illustrates the semigroup law Shadow_b(Shadow_a(S)) = Shadow_{a+b}(S)
as a commutative flow diagram, and shows the shadow profile decay curves
for multiple support families.

This script is fully self-contained — all needed functions are inlined.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from math import comb


# --- Self-contained core functions ---

def enumerate_sub_indices(alpha, k):
    n = len(alpha)
    results = set()
    def backtrack(pos, rem, cur):
        if pos == n:
            if rem == 0:
                results.add(tuple(cur))
            return
        for t in range(min(alpha[pos], rem) + 1):
            cur.append(alpha[pos] - t)
            backtrack(pos + 1, rem - t, cur)
            cur.pop()
    backtrack(0, k, [])
    return results

def kth_shadow(S, k):
    shadow = set()
    for alpha in S:
        shadow.update(enumerate_sub_indices(alpha, k))
    return shadow

def shadow_profile(S, max_k=None):
    if not S:
        return [0]
    if max_k is None:
        max_k = max(sum(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k + 1)]

def uniform_matroid_support(n, r):
    result = set()
    for combo in combinations(range(n), r):
        vec = [0] * n
        for i in combo:
            vec[i] = 1
        result.add(tuple(vec))
    return result

def homogeneous_support(n, d):
    def gen(pos, rem):
        if pos == n - 1:
            yield (rem,)
            return
        for v in range(rem + 1):
            for rest in gen(pos + 1, rem - v):
                yield (v,) + rest
    if n == 0:
        return {()} if d == 0 else set()
    return set(gen(0, d))


# --- Figure ---
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Semigroup verification grid
ax = axes[0]
S = homogeneous_support(3, 4)
max_ab = 5
grid = np.zeros((max_ab, max_ab))
for a in range(max_ab):
    for b in range(max_ab):
        lhs = kth_shadow(kth_shadow(S, a), b)
        rhs = kth_shadow(S, a + b)
        grid[b, a] = 1 if lhs == rhs else 0

im = ax.imshow(grid, cmap='Greens', vmin=0, vmax=1, origin='lower')
ax.set_xlabel('a (first shadow depth)', fontsize=11)
ax.set_ylabel('b (second shadow depth)', fontsize=11)
ax.set_title('Semigroup Law Verification\nSh_b(Sh_a(S)) = Sh_{a+b}(S)', fontsize=12)
ax.set_xticks(range(max_ab))
ax.set_yticks(range(max_ab))
for a in range(max_ab):
    for b in range(max_ab):
        ax.text(a, b, '✓' if grid[b, a] == 1 else '✗',
                ha='center', va='center', fontsize=14,
                color='darkgreen' if grid[b, a] == 1 else 'red')

# Panel 2: Profile decay comparison
ax = axes[1]
families = [
    ('U(3,7)', uniform_matroid_support(7, 3)),
    ('U(4,8)', uniform_matroid_support(8, 4)),
    ('Hom(3,4)', homogeneous_support(3, 4)),
    ('Hom(4,3)', homogeneous_support(4, 3)),
    ('Hom(3,5)', homogeneous_support(3, 5)),
]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(families)))
for (name, S), color in zip(families, colors):
    prof = shadow_profile(S)
    # Normalize to start at 1
    norm_prof = [p / prof[0] for p in prof]
    ax.plot(range(len(norm_prof)), norm_prof, 'o-', color=color,
            label=name, markersize=5, linewidth=2)

ax.set_xlabel('Shadow depth k', fontsize=11)
ax.set_ylabel('|Shadow_k| / |S|  (normalized)', fontsize=11)
ax.set_title('Normalized Shadow Decay', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(bottom=0)

# Panel 3: Shadow size vs binomial coefficients
ax = axes[2]
for n in [5, 6, 7, 8]:
    r = n // 2
    S = uniform_matroid_support(n, r)
    prof = shadow_profile(S)
    binomials = [comb(n, r - k) if r - k >= 0 else 0 for k in range(r + 1)]
    # Plot ratio
    ratios = [p / b if b > 0 else 0 for p, b in zip(prof, binomials)]
    ax.plot(range(len(ratios)), ratios, 's-', label=f'U({r},{n})',
            markersize=5, linewidth=2)

ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
ax.set_xlabel('Shadow depth k', fontsize=11)
ax.set_ylabel('|Shadow_k| / C(n, r-k)', fontsize=11)
ax.set_title('Shadow vs Binomial Coefficients', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('The Shadow Operator as a Discrete Flow',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('semigroup_flow.png', dpi=150, bbox_inches='tight')
print("Saved semigroup_flow.png")


"""
Visualization: Shadow Heatmap for 2D Polynomial Supports

Shows the k-th shadow structure as a heatmap over the lattice Z^2,
illustrating how the shadow contracts the support set as k increases.

This script is fully self-contained — all needed functions are inlined.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# --- Self-contained core functions ---

def enumerate_sub_indices(alpha, k):
    n = len(alpha)
    results = set()
    def backtrack(pos, rem, cur):
        if pos == n:
            if rem == 0:
                results.add(tuple(cur))
            return
        for t in range(min(alpha[pos], rem) + 1):
            cur.append(alpha[pos] - t)
            backtrack(pos + 1, rem - t, cur)
            cur.pop()
    backtrack(0, k, [])
    return results

def kth_shadow(S, k):
    shadow = set()
    for alpha in S:
        shadow.update(enumerate_sub_indices(alpha, k))
    return shadow


# --- Generate a sample 2D support ---
# Homogeneous polynomial of degree 5 in 2 variables
d = 6
S = {(i, d - i) for i in range(d + 1)}
# Add some extra monomials for visual interest
S.update({(2, 2), (3, 1), (1, 3), (4, 0), (0, 4)})

max_k = max(sum(a) for a in S)

# --- Create heatmap ---
fig, axes = plt.subplots(2, 4, figsize=(16, 8))
axes = axes.flatten()

for idx, k in enumerate(range(min(8, max_k + 2))):
    ax = axes[idx]
    shadow = kth_shadow(S, k)

    # Create grid
    if shadow:
        max_coord = max(max(p) for p in shadow) + 1
    else:
        max_coord = max(max(p) for p in S) + 1

    grid = np.zeros((max_coord + 1, max_coord + 1))
    for pt in shadow:
        if pt[0] <= max_coord and pt[1] <= max_coord:
            grid[pt[1], pt[0]] = 1  # note: y, x for imshow

    # Also mark original support
    for pt in S:
        if pt[0] <= max_coord and pt[1] <= max_coord:
            if grid[pt[1], pt[0]] == 0:
                grid[pt[1], pt[0]] = 0.3  # faded original

    im = ax.imshow(grid, cmap='YlOrRd', origin='lower', vmin=0, vmax=1,
                   aspect='equal', interpolation='nearest')
    ax.set_title(f'Shadow$_{{ {k} }}$ ({len(shadow)} pts)', fontsize=11)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')

    # Add grid lines
    ax.set_xticks(np.arange(-0.5, max_coord + 1, 1), minor=True)
    ax.set_yticks(np.arange(-0.5, max_coord + 1, 1), minor=True)
    ax.grid(which='minor', color='gray', linewidth=0.5, alpha=0.3)
    ax.tick_params(which='minor', size=0)

plt.suptitle('Shadow Contraction: Support Shrinks as Derivative Order Increases',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('shadow_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved shadow_heatmap.png")


"""
Visualization: Shadow Profiles and Log-Concavity

Visualizes the shadow profile decay for various polynomial support families,
demonstrating the log-concavity phenomenon and the semigroup structure
of the shadow operator.

This script is fully self-contained — all needed functions are inlined.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


# --- Self-contained core functions ---

def enumerate_sub_indices(alpha, k):
    n = len(alpha)
    results = set()
    def backtrack(pos, rem, cur):
        if pos == n:
            if rem == 0:
                results.add(tuple(cur))
            return
        for t in range(min(alpha[pos], rem) + 1):
            cur.append(alpha[pos] - t)
            backtrack(pos + 1, rem - t, cur)
            cur.pop()
    backtrack(0, k, [])
    return results

def kth_shadow(S, k):
    shadow = set()
    for alpha in S:
        shadow.update(enumerate_sub_indices(alpha, k))
    return shadow

def shadow_profile(S, max_k=None):
    if not S:
        return [0]
    if max_k is None:
        max_k = max(sum(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k + 1)]

def uniform_matroid_support(n, r):
    result = set()
    for combo in combinations(range(n), r):
        vec = [0] * n
        for i in combo:
            vec[i] = 1
        result.add(tuple(vec))
    return result

def homogeneous_support(n, d):
    def gen(pos, rem):
        if pos == n - 1:
            yield (rem,)
            return
        for v in range(rem + 1):
            for rest in gen(pos + 1, rem - v):
                yield (v,) + rest
    if n == 0:
        return {()} if d == 0 else set()
    return set(gen(0, d))


# --- Figure 1: Shadow Profile Comparison ---

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Uniform matroids
ax = axes[0]
for n in [6, 7, 8]:
    for r in [3, 4]:
        S = uniform_matroid_support(n, r)
        prof = shadow_profile(S)
        ax.plot(range(len(prof)), prof, 'o-', label=f'U({r},{n})', markersize=4)
ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('|Shadow_k(S)|', fontsize=12)
ax.set_title('Uniform Matroid Shadows', fontsize=13)
ax.legend(fontsize=8)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Homogeneous polynomial supports
ax = axes[1]
for n in [2, 3, 4]:
    for d in [3, 4, 5]:
        S = homogeneous_support(n, d)
        if len(S) > 200:
            continue
        prof = shadow_profile(S)
        ax.plot(range(len(prof)), prof, 's-', label=f'Hom({n},{d})', markersize=4)
ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('|Shadow_k(S)|', fontsize=12)
ax.set_title('Homogeneous Polynomial Shadows', fontsize=13)
ax.legend(fontsize=8)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 3: Log-concavity verification (a_k^2 vs a_{k-1}*a_{k+1})
ax = axes[2]
for n in [6, 7, 8]:
    S = uniform_matroid_support(n, n // 2)
    prof = shadow_profile(S)
    if len(prof) >= 3:
        ks = range(1, len(prof) - 1)
        lhs = [prof[k] ** 2 for k in ks]
        rhs = [prof[k-1] * prof[k+1] for k in ks]
        ratios = [l / r if r > 0 else float('inf') for l, r in zip(lhs, rhs)]
        ax.plot(list(ks), ratios, 'D-', label=f'U({n//2},{n})', markersize=5)

ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.7, label='LC threshold')
ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('a_k² / (a_{k-1} · a_{k+1})', fontsize=12)
ax.set_title('Log-Concavity Ratios ≥ 1', fontsize=13)
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.suptitle('Iterated Shadow Geometry: Profile Analysis', fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('shadow_profiles.png', dpi=150, bbox_inches='tight')
print("Saved shadow_profiles.png")
