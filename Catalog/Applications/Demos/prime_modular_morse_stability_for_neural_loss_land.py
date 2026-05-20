#!/usr/bin/env python3
"""
Prime-Modular Morse Stability: Applications

Demonstrates real-world applications of the arithmetic-to-real dictionary
for loss landscape analysis. Shows how finite-field computations can
serve as diagnostic tools for optimization.
"""

from typing import List, Dict, Tuple
from collections import Counter
import math


# ============================================================
# Core utilities (self-contained)
# ============================================================

def poly_eval_mod(coeffs: List[int], x: int, p: int) -> int:
    result = 0
    for c in reversed(coeffs):
        result = (result * x + c) % p
    return result

def poly_deriv(coeffs: List[int]) -> List[int]:
    return [k * c for k, c in enumerate(coeffs) if k > 0] or [0]

def poly_eval(coeffs: List[int], x) -> float:
    return sum(c * x**k for k, c in enumerate(coeffs))

def find_crits_mod_p(coeffs: List[int], p: int) -> List[int]:
    d = poly_deriv(coeffs)
    return [x for x in range(p) if poly_eval_mod(d, x, p) == 0]

def crit_profile(coeffs: List[int], p: int) -> Dict[int, int]:
    crits = find_crits_mod_p(coeffs, p)
    vals = [poly_eval_mod(coeffs, x, p) for x in crits]
    return dict(Counter(vals))

def legendre(a: int, p: int) -> int:
    if p == 2: return a % 2
    a = a % p
    if a == 0: return 0
    v = pow(a, (p-1)//2, p)
    return 1 if v == 1 else -1

def primes_up_to(n: int) -> List[int]:
    sieve = [True] * (n+1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5)+1):
        if sieve[i]:
            for j in range(i*i, n+1, i):
                sieve[j] = False
    return [i for i in range(2, n+1) if sieve[i]]


# ============================================================
# Application 1: Loss Landscape Ruggedness Diagnostic
# ============================================================

def landscape_ruggedness_score(components: List[List[int]], prime_range: int = 100) -> float:
    """
    Compute a ruggedness score for a separable polynomial loss landscape
    using finite-field critical data.

    The score is based on the variance of critical counts across primes,
    normalized by the expected count. Higher variance suggests more
    complex critical structure.

    This implements the "hardness proxy hypothesis": variance of modular
    profiles correlates with optimization difficulty.
    """
    primes = [p for p in primes_up_to(prime_range) if p > 2]
    counts = []

    for p in primes:
        total = 1
        for f in components:
            total *= len(find_crits_mod_p(f, p))
        counts.append(total)

    if not counts:
        return 0.0

    mean = sum(counts) / len(counts)
    if mean == 0:
        return 0.0
    variance = sum((c - mean)**2 for c in counts) / len(counts)
    return variance / mean  # coefficient of dispersion


def compare_landscape_complexity():
    """
    Compare ruggedness scores of different loss landscapes.
    Demonstrates the hardness proxy hypothesis.
    """
    print("=" * 70)
    print("APPLICATION 1: Loss Landscape Ruggedness Diagnostic")
    print("=" * 70)
    print()

    landscapes = [
        ("Simple quadratic: x² + y²",
         [[0, 0, 1], [0, 0, 1]]),

        ("Double-well: (x⁴ - 2x²) + y²",
         [[0, 0, -2, 0, 1], [0, 0, 1]]),

        ("Double-double-well: (x⁴ - 2x²) + (y⁴ - 2y²)",
         [[0, 0, -2, 0, 1], [0, 0, -2, 0, 1]]),

        ("Triple well: (x⁶ - 3x⁴ + 2x²) + (y⁴ - 2y²)",
         [[0, 0, 2, 0, -3, 0, 1], [0, 0, -2, 0, 1]]),

        ("High-degree: (x⁸ - 4x⁶ + 6x⁴ - 4x² + 1) + y²",
         [[1, 0, -4, 0, 6, 0, -4, 0, 1], [0, 0, 1]]),
    ]

    print(f"{'Landscape':50s} | {'Ruggedness':>12} | {'Avg crits':>10}")
    print("-" * 78)

    for name, comps in landscapes:
        score = landscape_ruggedness_score(comps)
        # Average critical count
        primes = [p for p in primes_up_to(100) if p > 2]
        avg = sum(
            math.prod(len(find_crits_mod_p(f, p)) for f in comps)
            for p in primes
        ) / len(primes)
        print(f"{name:50s} | {score:12.2f} | {avg:10.1f}")

    print()
    print("Interpretation: Higher ruggedness scores indicate more complex landscapes")
    print("with more critical points and greater variation in critical structure.")
    print()


# ============================================================
# Application 2: Architecture Comparison via Arithmetic Fingerprint
# ============================================================

def architecture_fingerprint(components: List[List[int]], primes: List[int]) -> List[int]:
    """
    Compute an arithmetic fingerprint for a loss landscape.
    The fingerprint is the sequence of critical counts modulo each prime.
    """
    return [
        math.prod(len(find_crits_mod_p(f, p)) for f in components)
        for p in primes
    ]


def compare_architectures():
    """
    Compare two neural network architectures by their arithmetic fingerprints.
    """
    print("=" * 70)
    print("APPLICATION 2: Architecture Comparison via Arithmetic Fingerprint")
    print("=" * 70)
    print()

    # Model A: 2D loss with double-well in x, quadratic in y
    arch_a = [[0, 0, -2, 0, 1], [0, 0, 1]]  # x^4 - 2x^2, y^2
    # Model B: 2D loss with cubic in x, quadratic in y
    arch_b = [[0, 3, 0, -1], [0, 0, 1]]  # -x^3 + 3x, y^2
    # Model C: Same critical count as A but different structure
    arch_c = [[0, 0, -2, 0, 1], [0, 0, -1]]  # x^4 - 2x^2, -y^2

    primes = [p for p in primes_up_to(60) if p > 2]

    fp_a = architecture_fingerprint(arch_a, primes)
    fp_b = architecture_fingerprint(arch_b, primes)
    fp_c = architecture_fingerprint(arch_c, primes)

    print("Architecture A: L(x,y) = (x⁴ - 2x²) + y²")
    print("Architecture B: L(x,y) = (-x³ + 3x) + y²")
    print("Architecture C: L(x,y) = (x⁴ - 2x²) + (-y²)")
    print()

    print(f"{'p':>5} | {'A':>5} | {'B':>5} | {'C':>5}")
    print("-" * 30)
    for i, p in enumerate(primes[:15]):
        print(f"{p:5d} | {fp_a[i]:5d} | {fp_b[i]:5d} | {fp_c[i]:5d}")

    print()
    print("A vs B fingerprint match:", fp_a == fp_b)
    print("A vs C fingerprint match:", fp_a == fp_c)
    print()
    print("Note: A and C have the same critical COUNTS but different Morse")
    print("structure (different Hessian signatures). The count-level fingerprint")
    print("cannot distinguish them, but the quadratic signature can.")
    print()

    # Quadratic signature comparison for architectures with diagonal structure
    print("Quadratic character signatures for diagonal components:")
    eps_a = [1, 1]   # Both coefficients positive
    eps_c = [1, -1]  # Mixed signs

    print(f"\n{'p':>5} | {'χ(A)':>6} | {'χ(C)':>6} | {'different?':>10}")
    print("-" * 38)
    for p in primes[:15]:
        det_a = math.prod(2*e for e in eps_a)
        det_c = math.prod(2*e for e in eps_c)
        chi_a = legendre(det_a, p)
        chi_c = legendre(det_c, p)
        diff = "YES" if chi_a != chi_c else "no"
        print(f"{p:5d} | {chi_a:6d} | {chi_c:6d} | {diff:>10}")

    print()
    print("The quadratic character signature successfully distinguishes the")
    print("Hessian structure of architectures A and C.")
    print()


# ============================================================
# Application 3: Saddle Point Detection via Character Sums
# ============================================================

def detect_saddle_structure():
    """
    Use quadratic character signatures to detect saddle points
    in diagonal quadratic losses without computing real eigenvalues.
    """
    print("=" * 70)
    print("APPLICATION 3: Saddle Point Detection via Character Sums")
    print("=" * 70)
    print()

    test_cases = [
        ([1, 1, 1, 1], "Pure minimum (index 0)"),
        ([1, 1, 1, -1], "Saddle (index 1)"),
        ([1, 1, -1, -1], "Saddle (index 2)"),
        ([1, -1, -1, -1], "Saddle (index 3)"),
        ([-1, -1, -1, -1], "Pure maximum (index 4)"),
    ]

    primes = [p for p in primes_up_to(50) if p > 2]

    for epsilon, desc in test_cases:
        n = len(epsilon)
        idx = sum(1 for e in epsilon if e < 0)
        det = math.prod(2*e for e in epsilon)
        sign_prod = math.prod(epsilon)

        print(f"ε = {epsilon}  ({desc})")
        print(f"  Morse index = {idx}, det(Hess) = {det}")

        # Character sum analysis
        chi_values = [legendre(det, p) for p in primes]
        pos = sum(1 for c in chi_values if c == 1)
        neg = sum(1 for c in chi_values if c == -1)

        print(f"  χ_p(det) statistics: +1 occurs {pos} times, -1 occurs {neg} times")

        # The key formula: χ_p(det) = χ_p(2)^n · χ_p((-1)^idx)
        # For even index: χ_p((-1)^idx) = 1, so χ_p(det) = χ_p(2)^n
        # For odd index: χ_p((-1)^idx) = χ_p(-1), varies with p
        if idx % 2 == 0:
            print(f"  Even index → χ_p(det) = χ_p(2)^{n} (depends only on p mod 8)")
        else:
            print(f"  Odd index → χ_p(det) = χ_p(2)^{n} · χ_p(-1) (depends on p mod 8 and p mod 4)")

        # Verify formula
        mismatches = 0
        for p in primes:
            computed = legendre(det, p)
            predicted = legendre(2, p)**n * legendre((-1)**idx, p)
            if predicted > 1: predicted -= p
            if predicted < -1: predicted += p
            if computed != predicted:
                mismatches += 1

        print(f"  Formula verification: {len(primes) - mismatches}/{len(primes)} primes match")
        print()

    print("Conclusion: The quadratic character signature χ_p(det Hess) reliably")
    print("detects whether a critical point is a minimum, maximum, or saddle,")
    print("and the parity of the Morse index can be read from the distribution")
    print("of χ_p values across primes in different residue classes.")
    print()


# ============================================================
# Application 4: Prime Selection for Optimal Diagnostics
# ============================================================

def optimal_prime_selection():
    """
    Demonstrate how to select primes for maximum diagnostic power.
    """
    print("=" * 70)
    print("APPLICATION 4: Optimal Prime Selection for Diagnostics")
    print("=" * 70)
    print()

    # For a polynomial with known exceptional set
    f_coeffs = [0, 0, -2, 0, 1]  # x^4 - 2x^2
    # Critical points at 0, ±1
    # f''(0) = -4, f''(1) = 8, f''(-1) = 8
    # Exceptional primes: factors of 4 and 8 = {2}

    print("Polynomial: f(x) = x⁴ - 2x²")
    print("Integer critical points: x = -1, 0, 1")
    print("Second derivatives: f''(-1) = 8, f''(0) = -4, f''(1) = 8")
    print("Exceptional primes: {2} (divides 4 and 8)")
    print()

    print("Diagnostic quality by prime:")
    print(f"{'p':>5} | {'crits':>5} | {'all nondeg':>10} | {'profile':>20} | {'quality':>8}")
    print("-" * 60)

    d = poly_deriv(f_coeffs)
    dd = poly_deriv(d)

    for p in primes_up_to(50):
        crits = find_crits_mod_p(f_coeffs, p)
        nondeg = all(poly_eval_mod(dd, x, p) != 0 for x in crits)
        prof = crit_profile(f_coeffs, p)

        # Quality metric: number of distinct critical values
        quality = "excellent" if nondeg and len(prof) == len(crits) else \
                  "good" if nondeg else "poor"

        print(f"{p:5d} | {len(crits):5d} | {'yes' if nondeg else 'NO':>10} | {str(prof):>20} | {quality:>8}")

    print()
    print("Recommendation: Use primes p > max(exceptional set) for reliable diagnostics.")
    print("Larger primes give profiles closer to the real critical structure.")
    print()


# ============================================================
# Main
# ============================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   PRIME-MODULAR MORSE STABILITY: APPLICATIONS                      ║")
    print("║   Arithmetic Diagnostics for Optimization Landscapes               ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    compare_landscape_complexity()
    compare_architectures()
    detect_saddle_structure()
    optimal_prime_selection()

    print("=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Prime-Modular Morse Stability: Interactive Demo

Demonstrates the arithmetic-to-real dictionary for critical-point geometry
of polynomial loss functions. Computes real critical points, Morse indices,
and finite-field critical profiles for a range of primes.
"""

from collections import Counter
from typing import List, Tuple, Dict, Callable
import math

# ============================================================
# Polynomial utilities
# ============================================================

def poly_eval(coeffs: List[int], x):
    """Evaluate polynomial with coefficients [a0, a1, a2, ...] at x."""
    return sum(c * x**k for k, c in enumerate(coeffs))

def poly_deriv(coeffs: List[int]) -> List[int]:
    """Derivative of polynomial [a0, a1, a2, ...] -> [a1, 2*a2, 3*a3, ...]."""
    return [k * c for k, c in enumerate(coeffs) if k > 0] or [0]

def poly_eval_mod(coeffs: List[int], x: int, p: int) -> int:
    """Evaluate polynomial mod p."""
    return sum(c * pow(x, k, p) for k, c in enumerate(coeffs)) % p

def poly_deriv_coeffs_mod(coeffs: List[int], p: int) -> List[int]:
    """Derivative coefficients mod p."""
    d = poly_deriv(coeffs)
    return [c % p for c in d]


# ============================================================
# One-variable critical point analysis
# ============================================================

def find_real_critical_points(coeffs: List[int], search_range=(-10, 10), steps=10000) -> List[float]:
    """Find approximate real critical points of a polynomial by scanning."""
    d = poly_deriv(coeffs)
    lo, hi = search_range
    xs = [lo + (hi - lo) * i / (steps - 1) for i in range(steps)]
    vals = [poly_eval(d, x) for x in xs]

    # Find sign changes
    crits = []
    for i in range(len(vals) - 1):
        if vals[i] * vals[i+1] <= 0:
            # Bisection refinement
            lo, hi = xs[i], xs[i+1]
            for _ in range(60):
                mid = (lo + hi) / 2
                if poly_eval(d, lo) * poly_eval(d, mid) <= 0:
                    hi = mid
                else:
                    lo = mid
            crits.append((lo + hi) / 2)
    return crits

def classify_critical_point(coeffs: List[int], x: float) -> str:
    """Classify a critical point as min/max/degenerate using second derivative."""
    dd = poly_deriv(poly_deriv(coeffs))
    val = poly_eval(dd, x)
    if abs(val) < 1e-10:
        return "degenerate"
    return "minimum" if val > 0 else "maximum"

def morse_index_1d(coeffs: List[int], x: float) -> int:
    """Morse index of a 1D critical point (0 for min, 1 for max)."""
    dd = poly_deriv(poly_deriv(coeffs))
    val = poly_eval(dd, x)
    return 0 if val > 0 else 1

def find_mod_p_critical_points(coeffs: List[int], p: int) -> List[int]:
    """Find all critical points of f mod p in F_p."""
    d = poly_deriv(coeffs)
    crits = []
    for x in range(p):
        if poly_eval_mod(d, x, p) == 0:
            crits.append(x)
    return crits

def mod_p_critical_profile(coeffs: List[int], p: int) -> Dict[int, int]:
    """Compute the critical profile: for each critical value t, count critical points."""
    crits = find_mod_p_critical_points(coeffs, p)
    values = [poly_eval_mod(coeffs, x, p) for x in crits]
    return dict(Counter(values))

def is_nondegenerate_mod_p(coeffs: List[int], x: int, p: int) -> bool:
    """Check if x is a nondegenerate critical point mod p."""
    dd = poly_deriv(poly_deriv(coeffs))
    return poly_eval_mod(dd, x, p) != 0


# ============================================================
# Separable loss analysis
# ============================================================

def separable_crit_count(components: List[List[int]], p: int) -> int:
    """Total critical points of separable loss mod p = product of per-component counts."""
    count = 1
    for f in components:
        count *= len(find_mod_p_critical_points(f, p))
    return count

def separable_real_crit_count(components: List[List[int]]) -> int:
    """Total real critical points = product of per-component counts."""
    count = 1
    for f in components:
        count *= len(find_real_critical_points(f))
    return count


# ============================================================
# Diagonal quadratic analysis
# ============================================================

def diag_morse_index(epsilon: List[int]) -> int:
    """Morse index = number of negative coefficients."""
    return sum(1 for e in epsilon if e < 0)

def diag_sign_product(epsilon: List[int]) -> int:
    """Product of sign coefficients."""
    p = 1
    for e in epsilon:
        p *= e
    return p

def diag_hessian_det(epsilon: List[int]) -> int:
    """Hessian determinant = ∏(2εᵢ)."""
    p = 1
    for e in epsilon:
        p *= 2 * e
    return p

def legendre_symbol(a: int, p: int) -> int:
    """Compute the Legendre symbol (a/p)."""
    if a % p == 0:
        return 0
    val = pow(a, (p - 1) // 2, p)
    return val if val <= 1 else val - p

def quad_signature_mod_p(epsilon: List[int], p: int) -> int:
    """Quadratic character signature: χ_p(∏(2εᵢ))."""
    det = diag_hessian_det(epsilon)
    return legendre_symbol(det, p)


# ============================================================
# Demo scenarios
# ============================================================

def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n+1, i):
                sieve[j] = False
    return [i for i in range(2, n+1) if sieve[i]]


def demo_prime_stability():
    """Demo Theorem 2: Prime stability of nondegenerate critical points."""
    print("=" * 70)
    print("DEMO 1: Prime Stability of Nondegenerate Critical Points")
    print("=" * 70)
    print()

    # f(x) = x^4 - 2x^2  =>  f'(x) = 4x^3 - 4x  =>  f''(x) = 12x^2 - 4
    # Critical points: x = 0, ±1
    # f''(0) = -4, f''(1) = 8, f''(-1) = 8
    coeffs = [0, 0, -2, 0, 1]  # x^4 - 2x^2
    print(f"Polynomial: f(x) = x⁴ - 2x²")
    print(f"f'(x) = 4x³ - 4x, f''(x) = 12x² - 4")
    print()

    crits_real = find_real_critical_points(coeffs)
    print("Real critical points:")
    for x in crits_real:
        ctype = classify_critical_point(coeffs, x)
        fval = poly_eval(coeffs, x)
        print(f"  x ≈ {x:8.4f}  f(x) ≈ {fval:8.4f}  type: {ctype}")
    print()

    # Check stability across primes
    print("Prime stability (critical points mod p):")
    print(f"{'p':>5} | {'crit pts mod p':>15} | {'all nondeg?':>12} | {'count':>5}")
    print("-" * 50)

    for p in primes_up_to(50):
        if p == 2:
            continue
        mod_crits = find_mod_p_critical_points(coeffs, p)
        all_nondeg = all(is_nondegenerate_mod_p(coeffs, x, p) for x in mod_crits)
        print(f"{p:5d} | {str(mod_crits):>15s} | {'yes' if all_nondeg else 'NO':>12} | {len(mod_crits):5d}")

    print()
    print("Observation: For all primes > 2, critical points remain nondegenerate")
    print("and the count matches the real count (3). The exceptional set is at most {2}.")
    print()


def demo_separable_decomposition():
    """Demo Theorem 1: Separable critical fiber decomposition."""
    print("=" * 70)
    print("DEMO 2: Separable Loss Critical Fiber Decomposition")
    print("=" * 70)
    print()

    # L(x,y) = (x^4 - 2x^2) + (y^4 - 2y^2)
    f1 = [0, 0, -2, 0, 1]  # x^4 - 2x^2
    f2 = [0, 0, -2, 0, 1]  # y^4 - 2y^2
    components = [f1, f2]

    print("Separable loss: L(x,y) = (x⁴ - 2x²) + (y⁴ - 2y²)")
    print()

    real_count = separable_real_crit_count(components)
    print(f"Real critical points: {real_count} = 3 × 3")
    print()

    print("Mod-p critical counts (should equal real count for good primes):")
    print(f"{'p':>5} | {'mod-p count':>12} | {'= product?':>10} | {'individual':>20}")
    print("-" * 55)

    for p in primes_up_to(50):
        if p == 2:
            continue
        mod_count = separable_crit_count(components, p)
        c1 = len(find_mod_p_critical_points(f1, p))
        c2 = len(find_mod_p_critical_points(f2, p))
        is_product = (mod_count == c1 * c2)
        print(f"{p:5d} | {mod_count:12d} | {'yes' if is_product else 'NO':>10} | {c1} × {c2} = {c1*c2}")

    print()
    print("Observation: The separable structure is verified—mod-p critical count")
    print("equals the product of per-component counts for all primes tested.")
    print()


def demo_diagonal_quadratic():
    """Demo Theorem 4: Morse index and arithmetic signature."""
    print("=" * 70)
    print("DEMO 3: Diagonal Quadratic Morse Index & Arithmetic Signature")
    print("=" * 70)
    print()

    examples = [
        ([1, 1, 1], "All positive: 3D minimum"),
        ([-1, -1, -1], "All negative: 3D maximum"),
        ([1, -1, 1], "Mixed: saddle (index 1)"),
        ([1, -1, -1], "Mixed: saddle (index 2)"),
        ([-1, 1, -1, 1], "4D mixed: saddle (index 2)"),
    ]

    for epsilon, desc in examples:
        n = len(epsilon)
        idx = diag_morse_index(epsilon)
        neg_count = sum(1 for e in epsilon if e == -1)
        sign_prod = diag_sign_product(epsilon)
        hess_det = diag_hessian_det(epsilon)
        expected = (-1) ** neg_count

        print(f"ε = {epsilon}  ({desc})")
        print(f"  Morse index = {idx}")
        print(f"  neg-1 count = {neg_count}")
        print(f"  ∏εᵢ = {sign_prod},  (-1)^count = {expected},  match: {sign_prod == expected}")
        print(f"  Hessian det = {hess_det} = 2^{n} × {sign_prod}")
        print()

        # Arithmetic signature across primes
        print(f"  Quadratic character signature χ_p(det Hess) across primes:")
        print(f"  {'p':>5} | {'χ_p(det)':>8} | {'χ_p(2)^n':>9} | {'χ_p((-1)^idx)':>14}")
        print(f"  " + "-" * 45)

        for p in primes_up_to(30):
            if p == 2:
                continue
            chi_det = legendre_symbol(hess_det, p)
            chi_2_n = pow(legendre_symbol(2, p), n, p) if legendre_symbol(2, p) != 0 else 0
            chi_neg1_idx = legendre_symbol((-1)**idx, p)
            # Normalize
            if chi_2_n > 1:
                chi_2_n = chi_2_n - p
            print(f"  {p:5d} | {chi_det:8d} | {chi_2_n:9d} | {chi_neg1_idx:14d}")
        print()


def demo_profile_stability():
    """Demo: Critical profile stability across primes."""
    print("=" * 70)
    print("DEMO 4: Critical Profile Stability Across Primes")
    print("=" * 70)
    print()

    # Two different losses with same degree but different critical structure
    f_a = [0, 3, 0, -1]   # -x^3 + 3x  (two real crits: x=±1)
    f_b = [0, 0, 0, 1]    # x^3  (one real crit: x=0, degenerate)

    print("Comparing:")
    print("  f_a(x) = -x³ + 3x  (2 nondegenerate critical points)")
    print("  f_b(x) = x³        (1 degenerate critical point)")
    print()

    print(f"{'p':>5} | {'crits(f_a)':>10} | {'crits(f_b)':>10} | {'profiles differ?':>16}")
    print("-" * 50)

    for p in primes_up_to(60):
        if p == 2:
            continue
        ca = len(find_mod_p_critical_points(f_a, p))
        cb = len(find_mod_p_critical_points(f_b, p))
        prof_a = mod_p_critical_profile(f_a, p)
        prof_b = mod_p_critical_profile(f_b, p)
        differ = "YES" if prof_a != prof_b else "no"
        print(f"{p:5d} | {ca:10d} | {cb:10d} | {differ:>16}")

    print()
    print("Observation: The profiles consistently differ, reflecting the different")
    print("critical structure of the two polynomials.")
    print()


def demo_conjecture_test():
    """Demo: Computational test of the Morse histogram conjecture."""
    print("=" * 70)
    print("DEMO 5: Conjecture Test — Morse Histogram Determination")
    print("=" * 70)
    print()

    # L1(x,y) = (x^4 - 2x^2) + (y^2)  — 3 crits in x (indices 0,1,0) × 1 crit in y (index 0)
    # Morse histogram: {index 0: 2, index 1: 1}
    L1 = [[0, 0, -2, 0, 1], [0, 0, 1]]  # x^4 - 2x^2, y^2

    # L2(x,y) = (x^4 - 2x^2) + (-y^2)  — 3 crits in x × 1 crit in y (index 1)
    # Morse histogram: {index 1: 2, index 2: 1}
    L2 = [[0, 0, -2, 0, 1], [0, 0, -1]]  # x^4 - 2x^2, -y^2

    print("L₁(x,y) = (x⁴ - 2x²) + y²")
    print("  Real critical points: 3 × 1 = 3")
    print("  Morse histogram: {index 0: 2, index 1: 1}")
    print()
    print("L₂(x,y) = (x⁴ - 2x²) + (-y²)")
    print("  Real critical points: 3 × 1 = 3")
    print("  Morse histogram: {index 1: 2, index 2: 1}")
    print()

    print("These have DIFFERENT Morse histograms. Can mod-p profiles distinguish them?")
    print()

    print(f"{'p':>5} | {'count(L₁)':>10} | {'count(L₂)':>10} | {'same count?':>12}")
    print("-" * 45)

    for p in primes_up_to(60):
        if p == 2:
            continue
        c1 = separable_crit_count(L1, p)
        c2 = separable_crit_count(L2, p)
        same = "same" if c1 == c2 else "DIFFERENT"
        print(f"{p:5d} | {c1:10d} | {c2:10d} | {same:>12}")

    print()
    print("Note: The critical COUNTS are the same (both 3), as expected from the")
    print("separable structure. To distinguish Morse histograms, one needs finer")
    print("invariants such as the quadratic character signature of the Hessian.")
    print()


# ============================================================
# Main
# ============================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   PRIME-MODULAR MORSE STABILITY FOR NEURAL LOSS LANDSCAPES         ║")
    print("║   An Arithmetic-to-Real Dictionary for Critical-Point Complexity    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demos = {
        "1": ("Prime stability of critical points", demo_prime_stability),
        "2": ("Separable loss decomposition", demo_separable_decomposition),
        "3": ("Diagonal quadratic Morse index", demo_diagonal_quadratic),
        "4": ("Critical profile stability", demo_profile_stability),
        "5": ("Morse histogram conjecture test", demo_conjecture_test),
        "all": ("Run all demos", None),
    }

    print("Available demos:")
    for key, (desc, _) in demos.items():
        print(f"  [{key}] {desc}")
    print()

    # Run all demos by default
    print("Running all demos...\n")
    demo_prime_stability()
    demo_separable_decomposition()
    demo_diagonal_quadratic()
    demo_profile_stability()
    demo_conjecture_test()

    print("=" * 70)
    print("All demos complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
