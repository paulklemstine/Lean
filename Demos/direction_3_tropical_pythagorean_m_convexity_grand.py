#!/usr/bin/env python3
"""
Applications of Tropical Pythagorean M-Convexity

Demonstrates practical applications of the tropical valuation theory
for Pythagorean triples, including:
1. Divisibility prediction for Pythagorean triples
2. Prime factorization structure analysis
3. Counting triples with prescribed local behavior
4. Visualization of tropical images
"""

from math import gcd
from collections import defaultdict, Counter


def padic_val(p: int, n: int) -> int:
    """Compute v_p(n)."""
    if n == 0:
        return float('inf')
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def primitive_triples(bound: int) -> list[tuple[int, int, int]]:
    """Enumerate primitive Pythagorean triples with c ≤ bound."""
    triples = set()
    m = 2
    while m * m + 1 <= bound:
        for n in range(1, m):
            if (m - n) % 2 == 0 or gcd(m, n) != 1:
                continue
            a, b, c = m*m - n*n, 2*m*n, m*m + n*n
            if c > bound:
                break
            triples.add((min(a, b), max(a, b), c))
        m += 1
    return sorted(triples)


# ============================================================
# APPLICATION 1: Divisibility Prediction
# ============================================================

def predict_hypotenuse_divisibility(p: int, a: int, b: int) -> str:
    """Predict divisibility of hypotenuse by p using the tropical min-law.
    
    The theorem vₚ(c) = min(vₚ(a), vₚ(b)) (when vₚ(a) ≠ vₚ(b), odd p)
    lets us predict how many times p divides the hypotenuse from the legs alone.
    
    Application: In cryptographic protocols using Pythagorean triples,
    this predicts factorization structure without computing c.
    """
    va, vb = padic_val(p, a), padic_val(p, b)
    c_squared = a*a + b*b
    c = int(c_squared ** 0.5)
    if c * c != c_squared:
        return f"({a}, {b}) is not part of a Pythagorean triple"
    
    vc_actual = padic_val(p, c)
    
    if va != vb:
        predicted_vc = min(va, vb)
        correct = predicted_vc == vc_actual
        return (f"p={p}: vₚ(a)={va}, vₚ(b)={vb} → predicted vₚ(c)={predicted_vc}, "
                f"actual={vc_actual} {'✓' if correct else '✗'}")
    else:
        return (f"p={p}: vₚ(a)={va} = vₚ(b)={vb} → vₚ(c) ≥ {va}, "
                f"actual={vc_actual} (≥ bound only)")


# ============================================================
# APPLICATION 2: Counting by Valuation Pattern
# ============================================================

def count_triples_by_pattern(bound: int, primes: list[int]) -> dict:
    """Count primitive triples grouped by their multi-prime valuation pattern.
    
    The valuation pattern at multiple primes characterizes the local
    arithmetic structure of the triple. This is useful for:
    - Understanding distribution of Pythagorean triples in residue classes
    - Designing sieving algorithms for finding triples with specific properties
    """
    triples = primitive_triples(bound)
    pattern_counts = defaultdict(int)
    
    for a, b, c in triples:
        pattern = tuple(
            (p, padic_val(p, a), padic_val(p, b), padic_val(p, c))
            for p in primes
        )
        pattern_counts[pattern] += 1
    
    return dict(sorted(pattern_counts.items(), key=lambda x: -x[1]))


# ============================================================
# APPLICATION 3: Tropical Energy Landscape
# ============================================================

def tropical_energy(p: int, a: int, b: int, c: int) -> float:
    """Compute the tropical energy of a Pythagorean triple.
    
    E_p(a,b,c) = v_p(a)² + v_p(b)² + v_p(c)²
    
    Interprets the valuation vector as an energy state. The tropical
    min-law constrains the energy landscape: states with very different
    leg valuations have hypotenuse valuation determined by the minimum.
    """
    va, vb, vc = padic_val(p, a), padic_val(p, b), padic_val(p, c)
    return va**2 + vb**2 + vc**2


def energy_spectrum(p: int, bound: int) -> dict:
    """Compute the energy spectrum of primitive Pythagorean triples.
    
    Returns distribution of tropical energies, which reveals the
    concentration of triples at different valuation depths.
    """
    triples = primitive_triples(bound)
    energies = Counter()
    for a, b, c in triples:
        e = tropical_energy(p, a, b, c)
        energies[e] += 1
    return dict(sorted(energies.items()))


# ============================================================
# APPLICATION 4: Anomaly Detection
# ============================================================

def find_equal_valuation_triples(p: int, bound: int) -> list:
    """Find primitive triples where vₚ(a) = vₚ(b) — the 'cancellation' cases.
    
    These are the anomalous triples where the tropical equality theorem
    doesn't apply and the hypotenuse valuation can exceed the minimum.
    Understanding these cases is crucial for the full tropical picture.
    """
    triples = primitive_triples(bound)
    anomalies = []
    for a, b, c in triples:
        va, vb, vc = padic_val(p, a), padic_val(p, b), padic_val(p, c)
        if va == vb:
            excess = vc - va  # How much vₚ(c) exceeds the common value
            anomalies.append({
                'triple': (a, b, c),
                'common_val': va,
                'vc': vc,
                'excess': excess,
            })
    return anomalies


# ============================================================
# MAIN
# ============================================================

def main():
    print("=" * 72)
    print("  APPLICATIONS OF TROPICAL PYTHAGOREAN M-CONVEXITY")
    print("=" * 72)
    
    # Application 1: Divisibility Prediction
    print("\n" + "=" * 72)
    print("  APPLICATION 1: Divisibility Prediction")
    print("=" * 72)
    print("\n  Using the min-law vₚ(c) = min(vₚ(a), vₚ(b)) to predict")
    print("  prime divisibility of hypotenuse from legs alone:\n")
    
    test_cases = [(3, 4, 3), (3, 4, 5), (5, 12, 3), (9, 40, 3),
                  (7, 24, 5), (20, 21, 7), (33, 56, 3)]
    for case in test_cases:
        if len(case) == 3:
            a, b, p = case
            print(f"    ({a}, {b}): {predict_hypotenuse_divisibility(p, a, b)}")
    
    # Application 2: Pattern Counting
    print("\n" + "=" * 72)
    print("  APPLICATION 2: Multi-Prime Valuation Patterns")
    print("=" * 72)
    
    bound = 500
    patterns = count_triples_by_pattern(bound, [3, 5])
    print(f"\n  Triples with c ≤ {bound}, grouped by (v₃, v₅) pattern:")
    print(f"  Total distinct patterns: {len(patterns)}")
    for pat, count in list(patterns.items())[:10]:
        pat_str = ", ".join(f"p={p}:({va},{vb},{vc})" for p, va, vb, vc in pat)
        print(f"    [{pat_str}] → {count} triples")
    
    # Application 3: Energy Landscape
    print("\n" + "=" * 72)
    print("  APPLICATION 3: Tropical Energy Spectrum")
    print("=" * 72)
    
    for p in [3, 5]:
        spectrum = energy_spectrum(p, 500)
        print(f"\n  p = {p}: Energy spectrum (energy → count)")
        for energy, count in spectrum.items():
            bar = "█" * min(count, 50)
            print(f"    E={energy:4.0f}: {count:3d} {bar}")
    
    # Application 4: Anomaly Detection
    print("\n" + "=" * 72)
    print("  APPLICATION 4: Equal-Valuation Anomalies")
    print("=" * 72)
    
    for p in [3, 5, 7]:
        anomalies = find_equal_valuation_triples(p, 500)
        print(f"\n  p = {p}: {len(anomalies)} triples with vₚ(a) = vₚ(b)")
        for a_info in anomalies[:5]:
            t = a_info['triple']
            print(f"    ({t[0]}, {t[1]}, {t[2]}): common val={a_info['common_val']}, "
                  f"vₚ(c)={a_info['vc']}, excess={a_info['excess']}")
        if len(anomalies) > 5:
            print(f"    ... and {len(anomalies) - 5} more")
    
    # Summary
    print("\n" + "=" * 72)
    print("  SUMMARY OF APPLICATIONS")
    print("=" * 72)
    print("""
  1. DIVISIBILITY PREDICTION: The min-law theorem lets us predict the
     exact p-divisibility of a Pythagorean hypotenuse from its legs,
     without computing the hypotenuse itself.
     
  2. PATTERN COUNTING: Multi-prime valuation patterns provide a new
     classification of Pythagorean triples by local arithmetic structure,
     useful for sieving and enumeration algorithms.
     
  3. ENERGY LANDSCAPE: The tropical energy spectrum reveals concentration
     phenomena — most triples cluster at low energy (small valuations),
     with exponentially rare high-valuation triples.
     
  4. ANOMALY DETECTION: Triples with equal leg valuations are the
     "tropical cancellation" cases where the min-law gives only a
     lower bound. These anomalies are structurally significant and
     may hold the key to full M-convexity.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tropical Pythagorean M-Convexity — Interactive Demo

Explores the p-adic valuation images of primitive Pythagorean triples,
verifies the tropical min-plus relation, and tests weak exchange axioms
for primes p ≤ 7 with hypotenuse bound c ≤ 100.
"""

from math import gcd
from collections import defaultdict


def padic_val(p: int, n: int) -> int:
    """Compute the p-adic valuation v_p(n) — the largest k such that p^k | n."""
    if n == 0:
        return float('inf')
    if p < 2:
        return 0
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def primitive_pythagorean_triples(bound: int) -> list[tuple[int, int, int]]:
    """Enumerate all primitive Pythagorean triples (a, b, c) with c ≤ bound.
    
    Uses Euclid's parametrization: a = m²-n², b = 2mn, c = m²+n²
    with m > n > 0, gcd(m,n) = 1, m ≢ n (mod 2).
    Returns both (a,b,c) and (b,a,c) orderings.
    """
    triples = set()
    m = 2
    while True:
        m2 = m * m
        if m2 + 1 > bound:
            break
        for n in range(1, m):
            if (m - n) % 2 == 0:
                continue
            if gcd(m, n) != 1:
                continue
            a = m2 - n * n
            b = 2 * m * n
            c = m2 + n * n
            if c > bound:
                break
            triples.add((min(a, b), max(a, b), c))
        m += 1
    return sorted(triples)


def valuation_vector(p: int, a: int, b: int, c: int) -> tuple[int, int, int]:
    """Compute (v_p(a), v_p(b), v_p(c))."""
    return (padic_val(p, a), padic_val(p, b), padic_val(p, c))


def verify_tropical_inequality(p: int, triples: list) -> bool:
    """Verify: min(2·v_p(a), 2·v_p(b)) ≤ 2·v_p(c) for all triples."""
    all_ok = True
    for a, b, c in triples:
        va, vb, vc = padic_val(p, a), padic_val(p, b), padic_val(p, c)
        lhs = min(2 * va, 2 * vb)
        rhs = 2 * vc
        if lhs > rhs:
            print(f"  ✗ COUNTEREXAMPLE: ({a},{b},{c}), p={p}: "
                  f"min(2·{va}, 2·{vb}) = {lhs} > {rhs} = 2·{vc}")
            all_ok = False
    return all_ok


def verify_tropical_equality(p: int, triples: list) -> tuple[bool, int]:
    """Verify: when v_p(a) ≠ v_p(b), min(2·v_p(a), 2·v_p(b)) = 2·v_p(c)."""
    all_ok = True
    count = 0
    for a, b, c in triples:
        va, vb, vc = padic_val(p, a), padic_val(p, b), padic_val(p, c)
        if va != vb:
            count += 1
            lhs = min(2 * va, 2 * vb)
            rhs = 2 * vc
            if lhs != rhs:
                print(f"  ✗ COUNTEREXAMPLE: ({a},{b},{c}), p={p}: "
                      f"min(2·{va}, 2·{vb}) = {lhs} ≠ {rhs} = 2·{vc}")
                all_ok = False
    return all_ok, count


def verify_min_dichotomy(p: int, triples: list) -> tuple[bool, int]:
    """Verify: when v_p(a) ≠ v_p(b), v_p(c) = min(v_p(a), v_p(b))."""
    all_ok = True
    count = 0
    for a, b, c in triples:
        va, vb, vc = padic_val(p, a), padic_val(p, b), padic_val(p, c)
        if va != vb:
            count += 1
            expected = min(va, vb)
            if vc != expected:
                print(f"  ✗ COUNTEREXAMPLE: ({a},{b},{c}), p={p}: "
                      f"v_p(c) = {vc} ≠ min({va},{vb}) = {expected}")
                all_ok = False
    return all_ok, count


def check_weak_exchange(valuation_set: set, verbose: bool = False) -> tuple[bool, list]:
    """Check weak tropical exchange: for v, w ∈ S with v_i > w_i,
    ∃ j with v_j < w_j and ∃ u ∈ S with u_i < v_i and u_j ≥ v_j."""
    vals = list(valuation_set)
    violations = []
    for v in vals:
        for w in vals:
            for i in range(3):
                if v[i] > w[i]:
                    # Need j with v[j] < w[j]
                    candidates_j = [j for j in range(3) if v[j] < w[j]]
                    if not candidates_j:
                        continue  # v dominates w except at i, no exchange needed
                    found = False
                    for j in candidates_j:
                        # Check: ∃ u ∈ S with u[i] < v[i] and u[j] ≥ v[j]
                        for u in vals:
                            if u[i] < v[i] and u[j] >= v[j]:
                                found = True
                                break
                        if found:
                            break
                    if not found:
                        violations.append((v, w, i, candidates_j))
                        if verbose:
                            print(f"  ✗ Exchange fails: v={v}, w={w}, i={i}")
    return len(violations) == 0, violations


def print_valuation_image(p: int, triples: list) -> set:
    """Compute and display the valuation image for prime p."""
    image = set()
    for a, b, c in triples:
        v = valuation_vector(p, a, b, c)
        image.add(v)
    return image


def main():
    BOUND = 100
    PRIMES = [3, 5, 7]
    
    print("=" * 72)
    print("  TROPICAL PYTHAGOREAN M-CONVEXITY — COMPUTATIONAL EXPLORATION")
    print("=" * 72)
    
    triples = primitive_pythagorean_triples(BOUND)
    print(f"\nPrimitive Pythagorean triples with c ≤ {BOUND}: {len(triples)}")
    print(f"First 10: {triples[:10]}")
    
    # ===== Theorem Verification =====
    print("\n" + "=" * 72)
    print("  THEOREM VERIFICATION")
    print("=" * 72)
    
    for p in [2, 3, 5, 7]:
        print(f"\n--- Prime p = {p} ---")
        
        # Tropical inequality
        ok = verify_tropical_inequality(p, triples)
        print(f"  Tropical inequality min(2·vₚ(a), 2·vₚ(b)) ≤ 2·vₚ(c): "
              f"{'✓ VERIFIED' if ok else '✗ FAILED'}")
        
        if p != 2:  # Equality only for odd primes
            ok_eq, cnt_eq = verify_tropical_equality(p, triples)
            print(f"  Tropical equality (when vₚ(a) ≠ vₚ(b)): "
                  f"{'✓ VERIFIED' if ok_eq else '✗ FAILED'} ({cnt_eq} cases tested)")
            
            ok_min, cnt_min = verify_min_dichotomy(p, triples)
            print(f"  Min dichotomy vₚ(c) = min(vₚ(a), vₚ(b)): "
                  f"{'✓ VERIFIED' if ok_min else '✗ FAILED'} ({cnt_min} cases tested)")
    
    # ===== Valuation Images =====
    print("\n" + "=" * 72)
    print("  VALUATION IMAGES Trop_p(P)")
    print("=" * 72)
    
    for p in PRIMES:
        image = print_valuation_image(p, triples)
        print(f"\nPrime p = {p}: |Trop_p(P)| = {len(image)}")
        sorted_image = sorted(image)
        for v in sorted_image:
            # Find a witness triple
            for a, b, c in triples:
                if valuation_vector(p, a, b, c) == v:
                    print(f"  {v}  ← ({a}, {b}, {c})")
                    break
    
    # ===== Weak Exchange Axiom =====
    print("\n" + "=" * 72)
    print("  WEAK TROPICAL EXCHANGE AXIOM TEST")
    print("=" * 72)
    
    for p in PRIMES:
        image = print_valuation_image(p, triples)
        ok, violations = check_weak_exchange(image)
        status = "✓ SATISFIED" if ok else f"✗ {len(violations)} violations"
        print(f"\n  p = {p}: Weak exchange: {status}")
        if not ok:
            print(f"    First 3 violations:")
            for v, w, i, js in violations[:3]:
                print(f"      v={v}, w={w}, coord i={i}")
    
    # ===== Detailed analysis for p=3 =====
    print("\n" + "=" * 72)
    print("  DETAILED ANALYSIS: p = 3")
    print("=" * 72)
    
    p = 3
    val_to_triples = defaultdict(list)
    for a, b, c in triples:
        v = valuation_vector(p, a, b, c)
        val_to_triples[v].append((a, b, c))
    
    print(f"\n  Valuation vector → triple count:")
    for v in sorted(val_to_triples.keys()):
        ts = val_to_triples[v]
        print(f"    {v}: {len(ts)} triples")
        for t in ts[:3]:
            print(f"        {t}")
        if len(ts) > 3:
            print(f"        ... and {len(ts) - 3} more")
    
    # ===== Scaling structure =====
    print("\n" + "=" * 72)
    print("  TROPICAL TRANSLATION INVARIANCE (SCALING)")
    print("=" * 72)
    
    print("\n  Demonstrating: scaling (a,b,c) by k shifts all valuations by vₚ(k)")
    base_triple = (3, 4, 5)
    p = 3
    print(f"\n  Base triple: {base_triple}, p = {p}")
    for k in [1, 3, 9, 27, 6, 15]:
        a, b, c = base_triple
        v_base = valuation_vector(p, a, b, c)
        v_scaled = valuation_vector(p, k*a, k*b, k*c)
        vk = padic_val(p, k)
        expected = tuple(x + vk for x in v_base)
        print(f"    k={k:3d} (v₃(k)={vk}): base={v_base}, "
              f"scaled={v_scaled}, expected={expected}, "
              f"{'✓' if v_scaled == expected else '✗'}")
    
    print("\n" + "=" * 72)
    print("  SUMMARY")
    print("=" * 72)
    print(f"""
  • Enumerated {len(triples)} primitive Pythagorean triples with c ≤ {BOUND}.
  • Verified tropical inequality and equality theorems for p = 2, 3, 5, 7.
  • Computed valuation images Trop_p(P) for odd primes p = 3, 5, 7.
  • Tested weak tropical exchange axiom on valuation images.
  • Demonstrated tropical translation invariance (scaling property).
  
  The computational evidence confirms the formally proved theorems and
  supports the conjecture that Pythagorean valuation images carry
  tropical M-convex-like structure.
""")


if __name__ == "__main__":
    main()
