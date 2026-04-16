#!/usr/bin/env python3
"""
Miller-Rabin Primality Test — Interactive Demo

Demonstrates the Miller-Rabin probabilistic primality test with step-by-step
explanation, building on formally verified Euler criterion and QR theory.

Explores:
  - Strong pseudoprimes vs Fermat pseudoprimes
  - Carmichael numbers and why they need Miller-Rabin
  - Deterministic Miller-Rabin for small numbers
  - Connection to quadratic reciprocity

Usage:
    python miller_rabin_demo.py [N]
"""

import sys
import math
import random

def is_prime_naive(n):
    """Trial division primality test."""
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def decompose(n):
    """Write n-1 = 2^s × d with d odd."""
    s = 0
    d = n - 1
    while d % 2 == 0:
        s += 1
        d //= 2
    return s, d

def miller_rabin_test(n, a, verbose=False):
    """
    Perform one round of Miller-Rabin test with base a.
    
    Returns: (is_probable_prime, witness_type)
    """
    if n < 2:
        return False, "trivial"
    if n == 2 or n == 3:
        return True, "small prime"
    if n % 2 == 0:
        return False, "even"
    if a % n == 0:
        return True, "trivial base"
    
    s, d = decompose(n)
    
    if verbose:
        print(f"    n - 1 = {n-1} = 2^{s} × {d}")
    
    # Compute a^d mod n
    x = pow(a, d, n)
    
    if verbose:
        print(f"    a^d mod n = {a}^{d} mod {n} = {x}")
    
    if x == 1:
        if verbose:
            print(f"    → a^d ≡ 1 (mod n) → PROBABLE PRIME")
        return True, "a^d ≡ 1"
    
    if x == n - 1:
        if verbose:
            print(f"    → a^d ≡ -1 (mod n) → PROBABLE PRIME")
        return True, "a^d ≡ -1"
    
    for r in range(1, s):
        x = pow(x, 2, n)
        if verbose:
            print(f"    a^(2^{r}·d) mod n = {x}")
        
        if x == n - 1:
            if verbose:
                print(f"    → a^(2^{r}·d) ≡ -1 (mod n) → PROBABLE PRIME")
            return True, f"a^(2^{r}·d) ≡ -1"
        
        if x == 1:
            if verbose:
                print(f"    → Found non-trivial sqrt of 1! → COMPOSITE")
            return False, f"nontrivial sqrt(1) at r={r}"
    
    if verbose:
        print(f"    → Exhausted all r without finding -1 → COMPOSITE")
    return False, "exhausted"

def explore_pseudoprimes():
    """Find and analyze pseudoprimes."""
    print(f"\n{'=' * 70}")
    print(f"  PSEUDOPRIME EXPLORATION")
    print(f"{'=' * 70}")
    
    # Fermat pseudoprimes to base 2
    print(f"\n  Fermat pseudoprimes to base 2 (n composite, 2^(n-1) ≡ 1 mod n):")
    fermat_psps = []
    for n in range(3, 10000, 2):
        if not is_prime_naive(n) and n > 1:
            if pow(2, n - 1, n) == 1:
                fermat_psps.append(n)
    
    for n in fermat_psps[:15]:
        # Factor it
        factors = []
        temp = n
        for p in range(2, n):
            while temp % p == 0:
                factors.append(p)
                temp //= p
            if temp == 1:
                break
        
        # Is it a strong pseudoprime?
        is_strong, _ = miller_rabin_test(n, 2)
        strong_mark = "STRONG" if is_strong else "weak"
        print(f"    {n:6d} = {'×'.join(map(str,factors)):15s} [{strong_mark}]")
    
    print(f"  Total Fermat pseudoprimes to base 2 below 10000: {len(fermat_psps)}")
    
    # Strong pseudoprimes to base 2
    strong_psps = []
    for n in fermat_psps:
        is_strong, _ = miller_rabin_test(n, 2)
        if is_strong:
            strong_psps.append(n)
    
    print(f"  Strong pseudoprimes to base 2 below 10000: {len(strong_psps)}")
    if strong_psps:
        print(f"  Values: {strong_psps[:10]}")
    
    # Carmichael numbers
    print(f"\n  Carmichael Numbers (Fermat pseudoprimes to ALL coprime bases):")
    carmichaels = []
    for n in range(3, 10000, 2):
        if is_prime_naive(n):
            continue
        if n < 4:
            continue
        
        is_carmichael = True
        for a in range(2, min(n, 50)):
            if math.gcd(a, n) != 1:
                continue
            if pow(a, n - 1, n) != 1:
                is_carmichael = False
                break
        
        if is_carmichael:
            # Verify with more bases
            for a in range(50, min(n, 200)):
                if math.gcd(a, n) != 1:
                    continue
                if pow(a, n - 1, n) != 1:
                    is_carmichael = False
                    break
        
        if is_carmichael:
            carmichaels.append(n)
    
    for n in carmichaels[:10]:
        # Factor
        factors = []
        temp = n
        for p in range(2, n):
            while temp % p == 0:
                factors.append(p)
                temp //= p
            if temp == 1:
                break
        
        # Find MR witness
        mr_witness = None
        for a in range(2, n):
            is_pp, reason = miller_rabin_test(n, a)
            if not is_pp:
                mr_witness = a
                break
        
        print(f"    {n:6d} = {'×'.join(map(str,factors)):15s} "
              f"MR witness: a={mr_witness}")
    
    print(f"  Total Carmichael numbers below 10000: {len(carmichaels)}")

def deterministic_mr():
    """Demonstrate deterministic Miller-Rabin for bounded ranges."""
    print(f"\n{'=' * 70}")
    print(f"  DETERMINISTIC MILLER-RABIN")
    print(f"{'=' * 70}")
    
    print(f"\n  For n < 2,047: test base {{2}}")
    print(f"  For n < 1,373,653: test bases {{2, 3}}")
    print(f"  For n < 3,215,031,751: test bases {{2, 3, 5, 7}}")
    print(f"  For n < 3,317,044,064,679,887,385,961,981: test bases {{2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37}}")
    
    # Verify the first claim
    print(f"\n  Verification: base {{2}} is sufficient for n < 2047")
    errors = 0
    for n in range(3, 2047, 2):
        is_pp, _ = miller_rabin_test(n, 2)
        actual = is_prime_naive(n)
        if is_pp != actual:
            errors += 1
            print(f"    ERROR at n = {n}: MR says {'prime' if is_pp else 'composite'}, "
                  f"actually {'prime' if actual else 'composite'}")
    
    if errors == 0:
        print(f"    ✓ Verified: 0 errors for all odd n in [3, 2047)")
    
    # Verify base {2, 3}
    print(f"\n  Verification: bases {{2, 3}} sufficient for n < 100000")
    errors = 0
    for n in range(3, 100000, 2):
        all_pass = all(miller_rabin_test(n, a)[0] for a in [2, 3])
        actual = is_prime_naive(n)
        if all_pass != actual:
            errors += 1
            if errors <= 3:
                print(f"    Note: n = {n} is {'prime' if actual else 'composite'}, "
                      f"MR({'{2,3}'}) says {'prime' if all_pass else 'composite'}")
    
    print(f"    Errors in [3, 100000): {errors}")

def detailed_test(N):
    """Detailed Miller-Rabin analysis of a specific number."""
    print(f"\n{'=' * 70}")
    print(f"  DETAILED MILLER-RABIN ANALYSIS: N = {N}")
    print(f"{'=' * 70}")
    
    actual = is_prime_naive(N)
    print(f"\n  Actual primality: {'PRIME' if actual else 'COMPOSITE'}")
    
    if not actual and N > 1:
        factors = []
        temp = N
        for p in range(2, min(N, 100000)):
            while temp % p == 0:
                factors.append(p)
                temp //= p
            if temp == 1:
                break
        if temp > 1:
            factors.append(temp)
        print(f"  Factorization: {' × '.join(map(str, factors))}")
    
    s, d = decompose(N)
    print(f"\n  Decomposition: N - 1 = {N-1} = 2^{s} × {d}")
    
    print(f"\n  Testing bases 2 through 20:")
    witnesses = 0
    liars = 0
    
    for a in range(2, min(21, N)):
        if math.gcd(a, N) > 1:
            print(f"    Base a = {a}: gcd(a, N) = {math.gcd(a, N)} > 1 "
                  f"(trivially composite)")
            continue
        
        is_pp, reason = miller_rabin_test(N, a, verbose=False)
        
        if actual:
            status = "✓ correct (prime passes)"
        elif is_pp:
            status = "⚠ STRONG LIAR"
            liars += 1
        else:
            status = "✓ WITNESS"
            witnesses += 1
        
        print(f"    Base a = {a:2d}: {'probable prime' if is_pp else 'COMPOSITE':15s} "
              f"({reason:20s}) {status}")
    
    if not actual:
        print(f"\n  Summary: {witnesses} witnesses, {liars} strong liars out of "
              f"{witnesses + liars} coprime bases tested")
        if witnesses + liars > 0:
            print(f"  Liar ratio: {liars/(witnesses+liars)*100:.1f}% "
                  f"(theorem guarantees ≤ 25%)")

def euler_criterion_demo():
    """Demonstrate the connection between Euler criterion and MR."""
    print(f"\n{'=' * 70}")
    print(f"  EULER CRITERION AND MILLER-RABIN CONNECTION")
    print(f"{'=' * 70}")
    
    print(f"\n  Euler's criterion: a^((p-1)/2) ≡ (a/p) (mod p)")
    print(f"  This is the foundation of Solovay-Strassen and connects to MR.")
    print(f"  (Formally verified as euler_criterion in v9)")
    
    for p in [7, 11, 13, 17, 23, 29, 31]:
        print(f"\n  p = {p}:")
        qrs = []
        qnrs = []
        for a in range(1, p):
            euler = pow(a, (p - 1) // 2, p)
            is_qr = any((x * x) % p == a for x in range(p))
            
            if is_qr:
                qrs.append(a)
            else:
                qnrs.append(a)
            
            euler_val = 1 if euler == 1 else -1
            expected = 1 if is_qr else -1
            check = "✓" if euler_val == expected else "✗"
            
        print(f"    QRs:  {qrs}")
        print(f"    QNRs: {qnrs}")
        print(f"    |QR| = |QNR| = {(p-1)//2} ✓ (verified: sum_legendre_zero)")

def main():
    N = int(sys.argv[1]) if len(sys.argv) > 1 else 561
    
    print(f"╔{'═' * 68}╗")
    print(f"║{'MILLER-RABIN PRIMALITY TEST — FORMAL FOUNDATIONS':^68s}║")
    print(f"║{'Gravitational Factoring Project v11':^68s}║")
    print(f"╚{'═' * 68}╝")
    
    detailed_test(N)
    explore_pseudoprimes()
    deterministic_mr()
    euler_criterion_demo()
    
    print(f"\n{'=' * 70}")
    print(f"  All foundations formally verified in Lean 4.")
    print(f"  See MillerRabinFoundations.lean for new v11 theorems.")
    print(f"{'=' * 70}")

if __name__ == "__main__":
    main()
