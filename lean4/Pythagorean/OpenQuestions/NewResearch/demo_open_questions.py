#!/usr/bin/env python3
"""
Gravitational Factoring: Open Questions — Computational Experiments
===================================================================

Ten computational experiments addressing the open questions from the
gravitational factoring research program.

Experiments:
  1. Density formula verification
  2. Cross-collision channel effectiveness
  3. Sieve-augmented factoring
  4. Octonionic non-associativity
  5. Parity filter analysis
  6. Statistical mechanics phase transition
  7. Balanced vs. unbalanced semiprimes
  8. Channel amplification scaling
  9. Quaternion norm factoring
 10. k-tuple tree descent verification
"""

import math
import random
import itertools
from collections import defaultdict
from typing import List, Tuple, Optional, Dict

# ============================================================================
# EXPERIMENT 1: Density Formula Verification
# ============================================================================

def experiment_1_density_formula():
    """Verify: #{x ∈ [1,N] : gcd(x,N) > 1} = p + q - 1 for N = pq (distinct primes)."""
    print("=" * 70)
    print("EXPERIMENT 1: Exact Density Formula for Semiprimes N = p·q")
    print("=" * 70)
    print()

    test_cases = [
        (3, 5), (3, 7), (5, 7), (5, 11), (7, 11), (7, 13),
        (11, 13), (13, 17), (17, 19), (23, 29), (31, 37),
        (41, 43), (59, 61), (71, 73), (97, 101), (197, 199)
    ]

    print(f"{'p':>5} {'q':>5} {'N=pq':>8} {'Predicted':>10} {'Empirical':>10} {'Error':>6} {'δ₁(N)':>10}")
    print("-" * 60)

    all_correct = True
    for p, q in test_cases:
        N = p * q
        predicted = p + q - 1
        empirical = sum(1 for x in range(N) if math.gcd(x, N) > 1)
        error = abs(predicted - empirical)
        density = predicted / N
        status = "✓" if error == 0 else "✗"
        print(f"{p:>5} {q:>5} {N:>8} {predicted:>10} {empirical:>10} {error:>5}{status} {density:>10.6f}")
        if error != 0:
            all_correct = False

    print()
    if all_correct:
        print("✓ VERIFIED: Formula p + q - 1 is EXACT for all tested semiprimes.")
    else:
        print("✗ DISCREPANCY found!")
    print()

# ============================================================================
# EXPERIMENT 2: Cross-Collision Channel Effectiveness
# ============================================================================

def generate_pythagorean_triples(D):
    """Generate Pythagorean triples a² + b² = c² with c ≤ D."""
    triples = []
    for m in range(1, int(D**0.5) + 2):
        for n in range(1, m):
            if (m - n) % 2 == 1 and math.gcd(m, n) == 1:
                a, b, c = m*m - n*n, 2*m*n, m*m + n*n
                if c > D:
                    break
                k = 1
                while k * c <= D:
                    triples.append(tuple(sorted([k*a, k*b])) + (k*c,))
                    k += 1
    return triples

def experiment_2_cross_collision():
    """Test cross-collision channels on odd semiprimes."""
    print("=" * 70)
    print("EXPERIMENT 2: Cross-Collision Channel Effectiveness")
    print("=" * 70)
    print()

    semiprimes = [(p, q) for p, q in
                  [(3,5),(3,7),(5,7),(5,11),(7,11),(7,13),(11,13),
                   (13,17),(17,19),(23,29),(31,37),(41,43),(59,61),
                   (71,73),(97,101),(127,131),(151,157),(191,193),(197,199),(223,227)]
                  if p != q]

    peel_only = 0
    cross_only = 0
    both = 0
    neither = 0

    print(f"{'N':>8} {'p×q':>12} {'Peel':>6} {'Cross':>6} {'Result':>15}")
    print("-" * 55)

    for p, q in semiprimes[:20]:
        N = p * q
        triples = generate_pythagorean_triples(N)

        peel_success = False
        cross_success = False

        # Check peel channels
        for a, b, c in triples:
            for x in [a, b]:
                g = math.gcd(c - x, N)
                if 1 < g < N:
                    peel_success = True
                    break
                g = math.gcd(c + x, N)
                if 1 < g < N:
                    peel_success = True
                    break
            if peel_success:
                break

        # Check cross-collision channels
        hyp_groups = defaultdict(list)
        for a, b, c in triples:
            hyp_groups[c].append((a, b))
        for c, tuples in hyp_groups.items():
            if len(tuples) >= 2:
                for (a1, b1), (a2, b2) in itertools.combinations(tuples, 2):
                    for diff in [a1 - a2, b1 - b2, a1 - b2, b1 - a2]:
                        g = math.gcd(abs(diff), N)
                        if 1 < g < N:
                            cross_success = True
                            break
                    if cross_success:
                        break
            if cross_success:
                break

        if peel_success and cross_success:
            both += 1
            result = "Both ✓"
        elif peel_success:
            peel_only += 1
            result = "Peel only"
        elif cross_success:
            cross_only += 1
            result = "Cross only"
        else:
            neither += 1
            result = "Neither"

        print(f"{N:>8} {p:>3}×{q:<3} {'✓' if peel_success else '✗':>6} "
              f"{'✓' if cross_success else '✗':>6} {result:>15}")

    print()
    total = peel_only + cross_only + both + neither
    print(f"Both succeed:     {both}/{total} ({100*both/total:.0f}%)")
    print(f"Peel only:        {peel_only}/{total} ({100*peel_only/total:.0f}%)")
    print(f"Cross only:       {cross_only}/{total} ({100*cross_only/total:.0f}%)")
    print(f"Neither:          {neither}/{total} ({100*neither/total:.0f}%)")
    print()

# ============================================================================
# EXPERIMENT 3: Sieve-Augmented Factoring
# ============================================================================

def is_smooth(n, B):
    """Check if n is B-smooth (all prime factors ≤ B)."""
    if n <= 1:
        return True
    for p in range(2, B + 1):
        while n % p == 0:
            n //= p
    return n == 1

def experiment_3_sieve_augmented():
    """Demonstrate sieve-augmented gravitational factoring."""
    print("=" * 70)
    print("EXPERIMENT 3: Sieve-Augmented Gravitational Factoring")
    print("=" * 70)
    print()

    targets = [(7, 11), (11, 13), (13, 17), (17, 19), (23, 29), (31, 37)]
    B = 50  # Smoothness bound

    print(f"{'N':>6} {'p×q':>8} {'Triples':>8} {'Smooth':>7} {'Factor':>8}")
    print("-" * 45)

    for p, q in targets:
        N = p * q
        triples = generate_pythagorean_triples(N + 100)

        smooth_products = []
        factor_found = None

        for a, b, c in triples:
            for x in [a, b]:
                peel_minus = c - x
                peel_plus = c + x
                product = peel_minus * peel_plus

                # Direct GCD check
                g = math.gcd(abs(peel_minus), N)
                if 1 < g < N and factor_found is None:
                    factor_found = g

                # Check smoothness for sieve
                if product > 0 and is_smooth(abs(product), B):
                    smooth_products.append((peel_minus, peel_plus, product))

        # Try congruence of squares from smooth products
        if factor_found is None and len(smooth_products) >= 2:
            for i in range(len(smooth_products)):
                for j in range(i + 1, len(smooth_products)):
                    combined = smooth_products[i][2] * smooth_products[j][2]
                    sqrt_combined = int(math.isqrt(abs(combined)))
                    if sqrt_combined * sqrt_combined == abs(combined):
                        a_val = smooth_products[i][0] * smooth_products[j][0]
                        g = math.gcd(abs(a_val - sqrt_combined), N)
                        if 1 < g < N:
                            factor_found = g
                            break
                if factor_found:
                    break

        status = f"{factor_found} ✓" if factor_found else "—"
        print(f"{N:>6} {p:>2}×{q:<2} {len(triples):>8} {len(smooth_products):>7} {status:>8}")

    print()

# ============================================================================
# EXPERIMENT 4: Octonionic Non-Associativity
# ============================================================================

def octonion_multiply(a, b):
    """Multiply two octonions using the standard Cayley-Dickson multiplication."""
    # Standard Fano plane multiplication table for imaginary units e1..e7
    # e_i * e_j = ε_{ijk} * e_k for each triple in the Fano plane
    fano_triples = [
        (1, 2, 3), (1, 4, 5), (1, 7, 6),
        (2, 4, 6), (2, 5, 7),
        (3, 4, 7), (3, 6, 5)
    ]

    # Build multiplication table
    mult = [[0]*8 for _ in range(8)]
    sign = [[0]*8 for _ in range(8)]

    for i in range(8):
        mult[0][i] = i
        sign[0][i] = 1
        mult[i][0] = i
        sign[i][0] = 1

    for i in range(1, 8):
        mult[i][i] = 0
        sign[i][i] = -1

    for (i, j, k) in fano_triples:
        mult[i][j] = k; sign[i][j] = 1
        mult[j][i] = k; sign[j][i] = -1
        mult[j][k] = i; sign[j][k] = 1
        mult[k][j] = i; sign[k][j] = -1
        mult[k][i] = j; sign[k][i] = 1
        mult[i][k] = j; sign[i][k] = -1

    result = [0] * 8
    for i in range(8):
        for j in range(8):
            k = mult[i][j]
            s = sign[i][j]
            result[k] += s * a[i] * b[j]

    return result

def octonion_norm(a):
    return sum(x*x for x in a)

def experiment_4_octonionic():
    """Demonstrate octonionic non-commutativity and non-associativity."""
    print("=" * 70)
    print("EXPERIMENT 4: Octonionic Non-Associativity")
    print("=" * 70)
    print()

    A = [3, 1, 2, 0, 1, 0, 0, 1]
    B = [2, 1, 0, 1, 1, 0, 1, 0]
    C = [1, 1, 0, 1, 0, 0, 1, 0]

    print(f"A = {A}  (Norm = {octonion_norm(A)})")
    print(f"B = {B}  (Norm = {octonion_norm(B)})")
    print(f"C = {C}  (Norm = {octonion_norm(C)})")
    print()

    AB = octonion_multiply(A, B)
    BA = octonion_multiply(B, A)
    print(f"A·B = {AB}  (Norm = {octonion_norm(AB)})")
    print(f"B·A = {BA}  (Norm = {octonion_norm(BA)})")
    print(f"A·B ≠ B·A: {AB != BA}")

    diff_count = sum(1 for i in range(8) if AB[i] != BA[i])
    print(f"Components differing: {diff_count}/8")
    print()

    # Non-associativity
    AB_C = octonion_multiply(AB, C)
    BC = octonion_multiply(B, C)
    A_BC = octonion_multiply(A, BC)

    print(f"(A·B)·C = {AB_C}  (Norm = {octonion_norm(AB_C)})")
    print(f"A·(B·C) = {A_BC}  (Norm = {octonion_norm(A_BC)})")
    print(f"(A·B)·C ≠ A·(B·C): {AB_C != A_BC}")

    diff_count = sum(1 for i in range(8) if AB_C[i] != A_BC[i])
    print(f"Components differing: {diff_count}/8")
    print()

    # Norm multiplicativity still holds
    expected_norm = octonion_norm(A) * octonion_norm(B) * octonion_norm(C)
    print(f"Norm(A)·Norm(B)·Norm(C) = {expected_norm}")
    print(f"Norm((A·B)·C) = {octonion_norm(AB_C)}")
    print(f"Norm(A·(B·C)) = {octonion_norm(A_BC)}")
    print(f"Norm multiplicativity verified: {octonion_norm(AB_C) == expected_norm == octonion_norm(A_BC)}")
    print()

# ============================================================================
# EXPERIMENT 5: Parity Filter Analysis
# ============================================================================

def experiment_5_parity():
    """Analyze parity's effect on peel channel success."""
    print("=" * 70)
    print("EXPERIMENT 5: Parity Filter Analysis")
    print("=" * 70)
    print()

    semiprimes = [(p, q) for p, q in
                  [(3,5),(5,7),(7,11),(11,13),(13,17),(17,19),(23,29),(29,31),
                   (31,37),(37,41),(41,43),(43,47)]
                  if p % 2 == 1 and q % 2 == 1]

    even_success = 0
    even_total = 0
    odd_success = 0
    odd_total = 0

    for p, q in semiprimes:
        N = p * q
        triples = generate_pythagorean_triples(N)

        for a, b, c in triples:
            for x in [a, b]:
                g = math.gcd(abs(c - x), N)
                if x % 2 == 0:
                    even_total += 1
                    if 1 < g < N:
                        even_success += 1
                else:
                    odd_total += 1
                    if 1 < g < N:
                        odd_success += 1

    even_rate = even_success / max(even_total, 1) * 100
    odd_rate = odd_success / max(odd_total, 1) * 100

    print(f"Even legs: {even_success}/{even_total} ({even_rate:.1f}% success)")
    print(f"Odd legs:  {odd_success}/{odd_total} ({odd_rate:.1f}% success)")
    print(f"Difference: {abs(even_rate - odd_rate):.1f} percentage points")
    print()

# ============================================================================
# EXPERIMENT 6: Statistical Mechanics Phase Transition
# ============================================================================

def experiment_6_phase_transition():
    """Model factoring as a thermal system with Boltzmann weights."""
    print("=" * 70)
    print("EXPERIMENT 6: Statistical Mechanics Phase Transition")
    print("=" * 70)
    print()

    N = 77  # 7 × 11
    triples = generate_pythagorean_triples(N + 50)

    def energy(a, b, c, N):
        """Factoring energy: min distance to a factor-revealing residue."""
        scores = []
        for x in [a, b]:
            scores.append(min(abs((c - x) % N), abs((c + x) % N)))
        return min(scores) if scores else N

    temperatures = [0.1, 0.2, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0]
    trials = 1000

    print(f"{'T':>6} {'P(factor)':>10} {'⟨E⟩':>8} {'Phase':>12}")
    print("-" * 40)

    for T in temperatures:
        successes = 0
        total_energy = 0

        for _ in range(trials):
            if not triples:
                break
            # Boltzmann-weighted sampling
            energies = [energy(a, b, c, N) for a, b, c in triples]
            weights = [math.exp(-E / T) for E in energies]
            total_w = sum(weights)
            probs = [w / total_w for w in weights]

            # Sample
            r = random.random()
            cumulative = 0
            idx = 0
            for i, prob in enumerate(probs):
                cumulative += prob
                if cumulative >= r:
                    idx = i
                    break

            a, b, c = triples[idx]
            E = energies[idx]
            total_energy += E

            if E == 0:
                successes += 1

        avg_E = total_energy / trials
        prob = successes / trials * 100
        phase = "Ordered" if T < 1.0 else ("Critical" if T < 3.0 else "Disordered")
        print(f"{T:>6.1f} {prob:>9.1f}% {avg_E:>8.2f} {phase:>12}")

    print()

# ============================================================================
# EXPERIMENT 7: Balanced vs. Unbalanced Semiprimes
# ============================================================================

def experiment_7_balanced():
    """Compare factoring difficulty for balanced vs. unbalanced semiprimes."""
    print("=" * 70)
    print("EXPERIMENT 7: Balanced vs. Unbalanced Semiprimes")
    print("=" * 70)
    print()

    cases = [
        # (p, q, label)
        (3, 101, "Unbalanced (ratio 33.7)"),
        (7, 43, "Moderate (ratio 6.1)"),
        (17, 19, "Balanced (ratio 1.1)"),
        (3, 167, "Unbalanced (ratio 55.7)"),
        (7, 71, "Moderate (ratio 10.1)"),
        (23, 29, "Balanced (ratio 1.3)"),
    ]

    print(f"{'N':>6} {'p':>4} {'q':>4} {'Ratio':>6} {'δ₁(N)':>10} {'Channels':>9} {'Label':>30}")
    print("-" * 80)

    for p, q, label in cases:
        N = p * q
        density = (p + q - 1) / N
        triples = generate_pythagorean_triples(N)
        channels_found = 0
        for a, b, c in triples:
            for x in [a, b]:
                g = math.gcd(abs(c - x), N)
                if 1 < g < N:
                    channels_found += 1
        ratio = max(p, q) / min(p, q)
        print(f"{N:>6} {p:>4} {q:>4} {ratio:>6.1f} {density:>10.6f} {channels_found:>9} {label:>30}")

    print()
    print("Key insight: Unbalanced semiprimes have higher density δ₁(N)")
    print("because the small prime contributes N/p = q >> √N divisible residues.")
    print()

# ============================================================================
# EXPERIMENT 8: Channel Amplification Scaling
# ============================================================================

def experiment_8_channels():
    """Show how channels scale with dimension k."""
    print("=" * 70)
    print("EXPERIMENT 8: Channel Amplification Scaling")
    print("=" * 70)
    print()

    print(f"{'k':>3} {'Peel':>6} {'Cross':>6} {'Total':>6} {'Ratio':>8} {'Algebra':>15}")
    print("-" * 50)

    algebras = {
        1: "ℝ (trivial)",
        2: "ℂ (Gaussian)",
        3: "—",
        4: "ℍ (quaternions)",
        5: "—",
        6: "—",
        7: "—",
        8: "𝕆 (octonions)",
        16: "𝕊 (sedenions)"
    }

    for k in [1, 2, 3, 4, 5, 6, 7, 8, 16, 32]:
        peel = k
        cross = k * (k - 1) // 2
        total = peel + cross
        ratio = total / max(1, k)
        algebra = algebras.get(k, "—")
        print(f"{k:>3} {peel:>6} {cross:>6} {total:>6} {ratio:>8.1f} {algebra:>15}")

    print()
    print("Note: Total channels = k(k+1)/2, growing quadratically.")
    print("At k=8 (octonions): 36 channels, 6× the k=3 case.")
    print("At k=16 (sedenions): 136 channels, but no norm multiplicativity.")
    print()

# ============================================================================
# EXPERIMENT 9: Quaternion Norm Factoring
# ============================================================================

def four_square_decomposition(n):
    """Find a representation n = a² + b² + c² + d² (Lagrange's theorem)."""
    for a in range(int(n**0.5) + 1):
        for b in range(a, int((n - a*a)**0.5) + 1):
            for c in range(b, int((n - a*a - b*b)**0.5) + 1):
                rem = n - a*a - b*b - c*c
                if rem >= 0:
                    d = int(rem**0.5)
                    if d*d == rem:
                        return (a, b, c, d)
    return None

def experiment_9_quaternion():
    """Demonstrate quaternion norm factoring."""
    print("=" * 70)
    print("EXPERIMENT 9: Quaternion Norm Factoring")
    print("=" * 70)
    print()

    targets = [15, 21, 35, 77, 143, 221, 323]

    for N in targets:
        decomp = four_square_decomposition(N)
        if decomp is None:
            print(f"N = {N}: No 4-square decomposition found")
            continue

        a, b, c, d_val = decomp
        print(f"N = {N} = {a}² + {b}² + {c}² + {d_val}²")

        # Try peel channels: gcd(N - xⱼ², N) for each component
        factors_found = set()
        for x in decomp:
            if x > 0:
                peel = N - x * x
                g = math.gcd(abs(peel), N)
                if 1 < g < N:
                    factors_found.add(g)

        # Also try √N as hypotenuse
        sqrt_N = int(N**0.5)
        for d_hyp in [sqrt_N, sqrt_N + 1, N]:
            decomp2 = four_square_decomposition(d_hyp * d_hyp)
            if decomp2:
                for x in decomp2:
                    g = math.gcd(abs(d_hyp - x), N)
                    if 1 < g < N:
                        factors_found.add(g)
                    g = math.gcd(abs(d_hyp + x), N)
                    if 1 < g < N:
                        factors_found.add(g)

        if factors_found:
            print(f"  Factors found: {sorted(factors_found)}")
        else:
            print(f"  No nontrivial factors via quaternion channels")
        print()

# ============================================================================
# EXPERIMENT 10: k-Tuple Tree Descent
# ============================================================================

def descent_step(legs, d):
    """Apply one descent step for k-tuple (legs, d)."""
    sigma_2 = sum(legs) - d  # 2σ = Σaᵢ - d
    if sigma_2 % 2 != 0:
        return None
    sigma = sigma_2 // 2
    new_legs = [abs(a - sigma) for a in legs]
    new_d = abs(d - sigma)
    return sorted(new_legs), new_d

def experiment_10_descent():
    """Verify tree descent for Pythagorean k-tuples."""
    print("=" * 70)
    print("EXPERIMENT 10: k-Tuple Tree Descent Verification")
    print("=" * 70)
    print()

    test_cases = [
        # (legs, hypotenuse, k)
        ([0, 0, 1], 1, 3),
        ([1, 2, 2], 3, 3),
        ([2, 3, 6], 7, 3),
        ([1, 4, 8], 9, 3),
        ([0, 0, 0, 1], 1, 4),
        ([1, 2, 4, 7], 70, 4),  # Check this
    ]

    for legs, d, k in test_cases:
        # Verify it's a valid k-tuple
        if sum(x*x for x in legs) != d*d:
            # Find valid d
            s = sum(x*x for x in legs)
            d = int(s**0.5)
            if d*d != s:
                print(f"  Invalid k-tuple: {legs}, d={d}")
                continue

        print(f"  k={k}: {tuple(legs)}, d={d}")
        current_legs, current_d = sorted(legs), d
        steps = 0
        max_steps = 50

        while steps < max_steps:
            if current_d <= 1:
                print(f"    → Root reached in {steps} steps: {current_legs}, d={current_d}")
                break
            result = descent_step(current_legs, current_d)
            if result is None:
                print(f"    → Descent blocked at step {steps}")
                break
            current_legs, current_d = result
            steps += 1
            if steps <= 5:
                print(f"    Step {steps}: {current_legs}, d={current_d}")
        if steps >= max_steps:
            print(f"    → Did not converge in {max_steps} steps")
        print()

# ============================================================================
# MAIN
# ============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  GRAVITATIONAL FACTORING: OPEN QUESTIONS — COMPUTATIONAL EVIDENCE  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    random.seed(42)  # Reproducibility

    experiment_1_density_formula()
    experiment_2_cross_collision()
    experiment_3_sieve_augmented()
    experiment_4_octonionic()
    experiment_5_parity()
    experiment_6_phase_transition()
    experiment_7_balanced()
    experiment_8_channels()
    experiment_9_quaternion()
    experiment_10_descent()

    print("=" * 70)
    print("ALL EXPERIMENTS COMPLETE")
    print("=" * 70)
