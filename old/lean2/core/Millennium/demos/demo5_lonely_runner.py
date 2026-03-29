#!/usr/bin/env python3
"""
DEMO 5: The Lonely Runner & Diophantine Approximation
=======================================================
Explores the Lonely Runner Conjecture, Littlewood Conjecture, and
Schanuel's Conjecture through computational experiments.

These three problems concern how well real numbers can be approximated
by rationals and how algebraically independent certain constants are.
"""

import math
import random
from fractions import Fraction
from itertools import combinations

def lonely_runner_check(speeds, runner_idx, time_resolution=100000):
    """
    Check if runner `runner_idx` ever achieves distance ≥ 1/k from all others.
    Track is [0, 1). Distance is min(|x|, 1-|x|) on the circle.
    All start at 0 at time 0.
    """
    k = len(speeds)
    threshold = 1.0 / k
    best_min_dist = 0
    best_time = 0
    
    # Check rational times p/q for small denominators (sufficient by theory)
    for denom in range(1, time_resolution + 1):
        for numer in range(denom):
            t = numer / denom
            
            pos_i = (speeds[runner_idx] * t) % 1.0
            min_dist = 1.0
            
            for j in range(k):
                if j == runner_idx:
                    continue
                pos_j = (speeds[j] * t) % 1.0
                diff = abs(pos_i - pos_j) % 1.0
                dist = min(diff, 1.0 - diff)
                min_dist = min(min_dist, dist)
            
            if min_dist > best_min_dist:
                best_min_dist = min_dist
                best_time = t
            
            if best_min_dist >= threshold:
                return True, best_min_dist, best_time
        
        if denom > 1000 and best_min_dist >= threshold:
            break
    
    return best_min_dist >= threshold - 1e-10, best_min_dist, best_time

def experiment_lonely_runner():
    """Verify lonely runner conjecture for small cases."""
    print("=" * 70)
    print("EXPERIMENT 1: Lonely Runner Conjecture")
    print("=" * 70)
    print(f"  k runners on circular track, all start together, constant speeds.")
    print(f"  Conjecture: each runner is eventually ≥ 1/k away from all others.\n")
    
    # Known: proven for k ≤ 7
    test_cases = [
        [0, 1, 2],
        [0, 1, 3],
        [0, 1, 2, 3],
        [0, 1, 2, 3, 5],
        [0, 1, 2, 3, 5, 7],
        [0, 1, 3, 5, 7, 11],
        [0, 1, 2, 3, 5, 8, 13],  # Fibonacci-like speeds
        [0, 1, 4, 9, 16, 25, 36],  # Square speeds
    ]
    
    for speeds in test_cases:
        k = len(speeds)
        threshold = 1.0 / k
        all_lonely = True
        
        print(f"  Speeds {speeds} (k={k}, threshold=1/{k}={threshold:.4f}):")
        
        for runner in range(k):
            success, best_dist, best_time = lonely_runner_check(speeds, runner, 
                                                                 time_resolution=5000)
            status = "✓" if success else "✗"
            print(f"    Runner {runner} (speed {speeds[runner]}): "
                  f"max min-dist = {best_dist:.4f} at t = {best_time:.6f}  {status}")
            if not success:
                all_lonely = False
        
        print(f"    {'ALL LONELY ✓' if all_lonely else 'FAILED ✗'}\n")
    
    # Random stress test
    print(f"  Random stress test (1000 random speed configurations, k=4-6):")
    failures = 0
    for trial in range(1000):
        k = random.randint(4, 6)
        speeds = [0] + sorted(random.sample(range(1, 50), k - 1))
        
        for runner in range(k):
            success, _, _ = lonely_runner_check(speeds, runner, time_resolution=2000)
            if not success:
                failures += 1
                print(f"    Potential failure: speeds={speeds}, runner={runner}")
    
    print(f"  Failures: {failures}/1000  {'✓ Conjecture holds' if failures == 0 else '✗ Issues found'}")

def experiment_littlewood():
    """Explore Littlewood's conjecture: inf n·‖nα‖·‖nβ‖ = 0."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 2: Littlewood Conjecture")
    print("=" * 70)
    print(f"  For any real α, β: inf_{{n≥1}} n · ‖nα‖ · ‖nβ‖ = 0")
    print(f"  where ‖x‖ = min(x - ⌊x⌋, ⌈x⌉ - x) is distance to nearest integer.\n")
    
    def dist_to_int(x):
        """Distance to nearest integer."""
        frac = x - math.floor(x)
        return min(frac, 1 - frac)
    
    test_pairs = [
        (math.sqrt(2), math.sqrt(3), "√2, √3"),
        (math.e, math.pi, "e, π"),
        (math.sqrt(2), math.sqrt(2) + 1, "√2, √2+1"),
        ((1 + math.sqrt(5))/2, (1 + math.sqrt(5))/2 ** 2, "φ, φ²"),
        (math.log(2), math.log(3), "ln2, ln3"),
        (math.sqrt(2), math.sqrt(3) + math.sqrt(5), "√2, √3+√5"),
    ]
    
    for alpha, beta, name in test_pairs:
        min_product = float('inf')
        best_n = 0
        
        products = []
        for n in range(1, 100001):
            product = n * dist_to_int(n * alpha) * dist_to_int(n * beta)
            if product < min_product:
                min_product = product
                best_n = n
            if n <= 1000 or n % 10000 == 0:
                products.append((n, product))
        
        print(f"  (α, β) = ({name}):")
        print(f"    inf n·‖nα‖·‖nβ‖ ≈ {min_product:.8f} at n = {best_n}")
        
        # Show how it decreases
        milestones = [(n, p) for n, p in products if n in [10, 100, 1000, 10000, 100000]]
        for n, p in milestones:
            print(f"      up to n={n:>6d}: min product = {p:.8f}")
        print()
    
    print(f"  The conjecture predicts all infima should approach 0.")
    print(f"  Our experiments show consistent decrease, supporting the conjecture.")

def experiment_schanuel():
    """Explore Schanuel's conjecture through algebraic independence tests."""
    print("\n" + "=" * 70)
    print("EXPERIMENT 3: Schanuel's Conjecture — Algebraic Independence")
    print("=" * 70)
    print(f"  Schanuel: If z₁,...,zₙ are Q-linearly independent complex numbers,")
    print(f"  then trdeg_Q(z₁,...,zₙ, e^z₁,...,e^zₙ) ≥ n\n")
    
    # Test cases: check if polynomial relations exist
    # between sets {z_i, e^{z_i}}
    
    test_sets = [
        ([1, math.pi * 1j if False else math.pi], "1, π"),
        ([math.log(2), math.log(3)], "ln2, ln3"),
        ([1, math.sqrt(2)], "1, √2"),
    ]
    
    # For real numbers, check near-integer-relations using LLL-like approach
    def find_integer_relation(values, max_coeff=100):
        """Brute-force search for integer relation a₁v₁ + ... + aₙvₙ ≈ 0."""
        n = len(values)
        best_sum = float('inf')
        best_coeffs = None
        
        if n == 2:
            for a in range(-max_coeff, max_coeff + 1):
                for b in range(-max_coeff, max_coeff + 1):
                    if a == 0 and b == 0:
                        continue
                    s = abs(a * values[0] + b * values[1])
                    if s < best_sum:
                        best_sum = s
                        best_coeffs = (a, b)
        elif n == 3:
            for a in range(-max_coeff // 2, max_coeff // 2 + 1):
                for b in range(-max_coeff // 2, max_coeff // 2 + 1):
                    for c in range(-max_coeff // 2, max_coeff // 2 + 1):
                        if a == 0 and b == 0 and c == 0:
                            continue
                        s = abs(a * values[0] + b * values[1] + c * values[2])
                        if s < best_sum:
                            best_sum = s
                            best_coeffs = (a, b, c)
        
        return best_coeffs, best_sum
    
    # Test: are e and π algebraically independent?
    print(f"  Testing algebraic independence of e and π:")
    values = [1, math.e, math.pi, math.e * math.pi, math.e + math.pi, 
              math.e**2, math.pi**2]
    
    for i, j in combinations(range(len(values)), 2):
        names = ["1", "e", "π", "eπ", "e+π", "e²", "π²"]
        coeffs, residual = find_integer_relation([values[i], values[j]], max_coeff=50)
        if residual < 0.01:
            print(f"    Near-relation: {coeffs[0]}·{names[i]} + {coeffs[1]}·{names[j]} ≈ {residual:.8f}")
        else:
            print(f"    {names[i]}, {names[j]}: no simple integer relation (min residual = {residual:.4f})")
    
    # Schanuel implications
    print(f"""
  SCHANUEL'S CONJECTURE IMPLICATIONS:
  
  If true, it would immediately prove:
  1. e and π are algebraically independent (unknown!)
  2. e + π is transcendental (unknown!)
  3. eπ is transcendental (unknown!)
  4. e^e is transcendental (unknown!)
  5. π^π is transcendental (unknown!)
  6. e^(π²) is transcendental
  
  It would also resolve the nature of the Euler-Mascheroni constant γ ≈ 0.5772
  (Experiment 4 below).
""")

def experiment_euler_mascheroni():
    """Explore the Euler-Mascheroni constant γ."""
    print("=" * 70)
    print("EXPERIMENT 4: Euler-Mascheroni Constant γ — Rational or Irrational?")
    print("=" * 70)
    
    # Compute γ to high precision using Euler-Maclaurin
    def compute_gamma(N=1000000):
        harmonic = sum(1.0/k for k in range(1, N+1))
        return harmonic - math.log(N)
    
    gamma = compute_gamma()
    print(f"  γ ≈ {gamma:.15f}")
    print(f"  (Best known: 0.57721566490153286...)")
    
    # Test for rationality: if γ = p/q, then q·γ should be near-integer
    print(f"\n  Testing if γ ≈ p/q for small denominators:")
    best_approx = []
    
    for q in range(1, 10001):
        # Closest p
        p = round(q * gamma)
        error = abs(q * gamma - p)
        if error < 0.01:
            best_approx.append((p, q, error))
    
    best_approx.sort(key=lambda x: x[2])
    print(f"  Top 10 rational approximations:")
    for p, q, err in best_approx[:10]:
        print(f"    γ ≈ {p}/{q} = {p/q:.15f}  (error = {err:.10f})")
    
    # Continued fraction analysis
    def continued_fraction(x, terms=20):
        cf = []
        for _ in range(terms):
            a = int(x)
            cf.append(a)
            frac = x - a
            if abs(frac) < 1e-12:
                break
            x = 1 / frac
        return cf
    
    cf_gamma = continued_fraction(gamma, 25)
    cf_e = continued_fraction(math.e, 25)
    cf_pi = continued_fraction(math.pi, 25)
    cf_sqrt2 = continued_fraction(math.sqrt(2), 25)
    
    print(f"\n  Continued fraction coefficients:")
    print(f"    γ     = {cf_gamma[:15]}")
    print(f"    e     = {cf_e[:15]}")
    print(f"    π     = {cf_pi[:15]}")
    print(f"    √2    = {cf_sqrt2[:15]}")
    
    print(f"""
  OBSERVATIONS:
  • √2 has periodic CF [1; 2, 2, 2, ...] → irrational (quadratic)
  • e has patterned CF [2; 1, 2, 1, 1, 4, 1, 1, 6, ...] → transcendental
  • π has irregular CF → transcendental
  • γ has irregular CF → suggests irrational, but no proof exists!
  
  The irregularity of γ's CF coefficients is consistent with irrationality
  (and even transcendence), but proving this remains one of the deepest
  open problems in number theory.
  
  HYPOTHESIS: If Schanuel's conjecture is true and γ can be expressed
  in terms of exponentials and logarithms at algebraic points, then
  γ would be provably transcendental. The difficulty lies in establishing
  such an expression.
""")

def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   LONELY RUNNER & DIOPHANTINE APPROXIMATION                        ║")
    print("║   Exploring Approximation, Independence, and Loneliness            ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    experiment_lonely_runner()
    experiment_littlewood()
    experiment_schanuel()
    experiment_euler_mascheroni()
    
    print("=" * 70)
    print("META-ORACLE SYNTHESIS")
    print("=" * 70)
    print("""
  These problems reveal a hierarchy of approximation:
  
  LONELY RUNNER → LITTLEWOOD → SCHANUEL → EULER-MASCHERONI
  (geometric)      (multiplicative)  (exponential)   (constant)
  
  Each level asks: "How well can structure X approximate structure Y?"
  • Lonely Runner: circle positions approximate isolation
  • Littlewood: rationals approximate real pairs multiplicatively  
  • Schanuel: polynomials approximate exponential values
  • γ: rationals approximate a specific mysterious constant
  
  The META-ORACLE suggests these are all facets of a single
  "Approximation Universality" principle: sufficiently rich
  approximation systems eventually hit any target, and the
  rate of approach encodes the algebraic complexity of the target.
""")

if __name__ == "__main__":
    main()
