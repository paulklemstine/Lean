#!/usr/bin/env python3
"""
Applications of the Unified Witness Framework for Primality Testing

Demonstrates real-world applications:
1. Certified primality testing with confidence bounds
2. Carmichael number detection and analysis
3. Spectral analysis of pseudoprime structure
4. Deterministic hitting set construction
5. AKS certificate verification

Each application connects to formally verified theorems in Lean 4.
"""

from algorithms import (
    is_strong_probable_prime, miller_rabin_test,
    compute_strong_liar_set, compute_mr_base_set,
    aks_poly_congruence_check, aks_full_check,
    additive_energy, sumset_size, spectral_regularity_score,
    repeated_squaring_orbit, orbit_period,
    two_adic_decomposition, euler_totient,
    liar_density, find_carmichael_numbers
)
from math import gcd, isqrt, log2, log
from typing import List, Set, Tuple


# ═══════════════════════════════════════════════════════════════════════════════
#  APPLICATION 1: Certified Primality Testing
# ═══════════════════════════════════════════════════════════════════════════════

def certified_primality_test(n: int, confidence_bits: int = 128) -> dict:
    """
    Primality test with formal confidence guarantee.

    By the amplification theorem (millerRabin_k_round_error_bound'),
    k rounds of Miller–Rabin give error probability ≤ (1/4)^k.
    For confidence_bits bits of security, we need k ≥ confidence_bits/2.

    Args:
        n: Integer to test
        confidence_bits: Desired security level (e.g., 128 for 2^{-128} error)

    Returns:
        Dictionary with test results and confidence analysis
    """
    if n < 2:
        return {"n": n, "is_prime": False, "certain": True, "method": "trivial"}
    if n < 4:
        return {"n": n, "is_prime": True, "certain": True, "method": "trivial"}
    if n % 2 == 0:
        return {"n": n, "is_prime": False, "certain": True, "method": "even"}

    k = (confidence_bits + 1) // 2  # Each round gives 2 bits of security
    bases = list(range(2, min(2 + k, n)))

    results = []
    for a in bases:
        if gcd(a, n) != 1:
            return {
                "n": n, "is_prime": False, "certain": True,
                "method": f"gcd witness: gcd({a}, {n}) = {gcd(a, n)}",
                "witness": a
            }
        results.append(is_strong_probable_prime(n, a))

    all_pass = all(results)
    witnesses = [bases[i] for i, r in enumerate(results) if not r]

    error_bound = (0.25) ** len(bases)

    return {
        "n": n,
        "is_prime": all_pass,
        "certain": not all_pass,  # If composite, we found a witness
        "rounds": len(bases),
        "error_bound": error_bound,
        "confidence_bits": -log2(error_bound) if error_bound > 0 else float('inf'),
        "witnesses": witnesses if not all_pass else [],
        "method": "Miller-Rabin"
    }


# ═══════════════════════════════════════════════════════════════════════════════
#  APPLICATION 2: Carmichael Number Analysis
# ═══════════════════════════════════════════════════════════════════════════════

def analyze_carmichael_structure(n: int) -> dict:
    """
    Detailed structural analysis of a Carmichael number.

    Carmichael numbers are the worst case for Fermat tests (all coprime
    bases pass), but Miller–Rabin still detects them with high probability.
    The quarter bound (strongLiarSet_card_le_quarter') guarantees ≤ 25% liars.

    Args:
        n: Suspected Carmichael number

    Returns:
        Structural analysis dictionary
    """
    liars = compute_strong_liar_set(n)
    bases = compute_mr_base_set(n)

    # Factor n
    factors = []
    temp = n
    p = 2
    while p * p <= temp:
        while temp % p == 0:
            factors.append(p)
            temp //= p
        p += 1
    if temp > 1:
        factors.append(temp)

    s, d = two_adic_decomposition(n - 1)
    phi = euler_totient(n)

    # Check Korselt's criterion
    unique_factors = list(set(factors))
    is_squarefree = len(factors) == len(unique_factors)
    korselt = is_squarefree and all((n - 1) % (p - 1) == 0 for p in unique_factors)

    # Spectral analysis
    reg_score = spectral_regularity_score(liars, n) if len(liars) > 1 else 0

    return {
        "n": n,
        "factorization": factors,
        "is_squarefree": is_squarefree,
        "is_carmichael": korselt and len(unique_factors) >= 3,
        "phi_n": phi,
        "n_minus_1_decomp": f"2^{s} * {d}",
        "liar_count": len(liars),
        "base_count": len(bases),
        "liar_density": len(liars) / len(bases) if bases else 0,
        "quarter_bound_satisfied": 4 * len(liars) <= len(bases),
        "spectral_regularity": reg_score,
        "first_witness": min(bases - liars) if bases - liars else None,
    }


# ═══════════════════════════════════════════════════════════════════════════════
#  APPLICATION 3: Deterministic Hitting Set Construction
# ═══════════════════════════════════════════════════════════════════════════════

def find_minimal_hitting_set(n: int, max_size: int = 20) -> List[int]:
    """
    Find a small set of bases that certifies compositeness of n.

    A "hitting set" for Miller–Rabin is a set of bases such that
    every composite passes through at least one witness. The liar
    cardinality bound (strongLiarSet_card_le_quarter') guarantees
    that random bases work with probability ≥ 3/4 each round.

    This function greedily constructs a minimal-size witness set.

    Args:
        n: Composite number to certify
        max_size: Maximum hitting set size

    Returns:
        List of witness bases, or empty if n appears prime
    """
    for a in range(2, min(n, 2 + max_size)):
        if gcd(a, n) > 1 and gcd(a, n) < n:
            return [a]  # GCD witness
        if not is_strong_probable_prime(n, a):
            return [a]  # Single MR witness

    return []  # No witness found; n is likely prime


# ═══════════════════════════════════════════════════════════════════════════════
#  APPLICATION 4: Spectral Pseudoprime Classification
# ═══════════════════════════════════════════════════════════════════════════════

def classify_composite_spectrally(n: int) -> dict:
    """
    Classify a composite number by the spectral properties of its liar set.

    The spectral sparsity conjecture predicts that Carmichael numbers
    maximize spectral regularity among squarefree composites.

    Related to Lean theorems:
    - many_strong_liars_force_collision_obstruction'
    - strongLiar_spectral_upper_bound'

    Args:
        n: Odd composite ≥ 9

    Returns:
        Classification dictionary
    """
    liars = compute_strong_liar_set(n)
    bases = compute_mr_base_set(n)
    m = len(liars)

    if m < 2:
        return {"n": n, "class": "trivial", "liar_count": m}

    energy = additive_energy(liars, n)
    sset = sumset_size(liars, n)
    reg = spectral_regularity_score(liars, n)

    # Classify
    if m == len(bases):
        cls = "prime"
    elif 4 * m > len(bases):
        cls = "anomalous"  # Shouldn't happen for composites
    elif reg > 0.5:
        cls = "high_regularity"
    elif reg > 0.1:
        cls = "moderate_regularity"
    else:
        cls = "low_regularity"

    return {
        "n": n,
        "class": cls,
        "liar_count": m,
        "base_count": len(bases),
        "density": m / len(bases) if bases else 0,
        "additive_energy": energy,
        "sumset_size": sset,
        "regularity_score": reg,
        "energy_ratio": energy / m**3 if m > 0 else 0,
        "random_threshold": m**3 / n if n > 0 else 0,
    }


# ═══════════════════════════════════════════════════════════════════════════════
#  APPLICATION 5: AKS Certificate Verification
# ═══════════════════════════════════════════════════════════════════════════════

def verify_aks_certificate(n: int, r: int, amax: int) -> dict:
    """
    Verify an AKS primality certificate.

    Corresponds to Lean structure `AKSCertificate'` and theorem
    `aks_prime_certificate'`.

    An AKS certificate (n, r, amax) certifies primality if:
    1. ordLarge: multiplicative order of n mod r > (log₂ n)²
    2. gcdClean: no d in {2,…,r} divides n (or d = n)
    3. congruenceWindow: (X+a)^n ≡ X^n + a mod (X^r-1, n) for a=1,…,amax
    4. amaxSufficient: amax ≥ ⌊√φ(r)⌋ · log₂(n)

    Args:
        n: Integer to certify
        r: Order parameter
        amax: Test window size

    Returns:
        Certificate verification results
    """
    if n <= 1:
        return {"valid": False, "reason": "n ≤ 1"}

    # Check ordLarge
    log_n_sq = int(log2(n)) ** 2 if n > 1 else 0
    ord_check = True
    for k in range(1, log_n_sq + 1):
        if pow(n, k, r) == 1:
            ord_check = False
            break

    # Check gcdClean
    gcd_check = True
    gcd_failure = None
    for d in range(2, r + 1):
        g = gcd(d, n)
        if g > 1 and g < n:
            gcd_check = False
            gcd_failure = d
            break

    # Check amaxSufficient
    phi_r = euler_totient(r)
    required_amax = isqrt(phi_r) * int(log2(n)) if n > 1 else 0
    amax_check = amax >= required_amax

    # Check polynomial congruences
    cong_results = {}
    all_cong = True
    for a in range(1, amax + 1):
        result = aks_poly_congruence_check(n, r, a)
        cong_results[a] = result
        if not result:
            all_cong = False

    return {
        "n": n, "r": r, "amax": amax,
        "ordLarge": ord_check,
        "gcdClean": gcd_check,
        "gcd_failure": gcd_failure,
        "amaxSufficient": amax_check,
        "required_amax": required_amax,
        "congruences_pass": all_cong,
        "congruence_details": cong_results,
        "certificate_valid": ord_check and gcd_check and amax_check and all_cong,
    }


# ═══════════════════════════════════════════════════════════════════════════════
#  MAIN DEMO
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    print("=" * 70)
    print("  Applications of the Unified Witness Framework")
    print("=" * 70)

    # Application 1: Certified Testing
    print("\n─── APPLICATION 1: Certified Primality Testing ───")
    for n in [127, 561, 1009, 2047, 1729]:
        result = certified_primality_test(n, confidence_bits=64)
        status = "PRIME" if result["is_prime"] else "COMPOSITE"
        cert = "certain" if result["certain"] else f"error ≤ 2^{-result.get('confidence_bits', 0):.0f}"
        print(f"  n = {n:5d}: {status:9s} ({cert})")
        if result.get("witnesses"):
            print(f"            witness: base {result['witnesses'][0]}")

    # Application 2: Carmichael Analysis
    print("\n─── APPLICATION 2: Carmichael Number Analysis ───")
    carmichaels = [561, 1105, 1729]
    for n in carmichaels:
        info = analyze_carmichael_structure(n)
        print(f"\n  n = {n}: factors = {info['factorization']}")
        print(f"    Carmichael: {info['is_carmichael']}, "
              f"φ(n) = {info['phi_n']}")
        print(f"    Liars: {info['liar_count']}/{info['base_count']} "
              f"(density {info['liar_density']:.4f})")
        print(f"    Quarter bound: {'✓' if info['quarter_bound_satisfied'] else '✗'}")
        print(f"    First witness: base {info['first_witness']}")

    # Application 3: Hitting Sets
    print("\n─── APPLICATION 3: Deterministic Hitting Sets ───")
    composites = [9, 15, 25, 341, 561, 1105, 1729, 2821]
    for n in composites:
        hs = find_minimal_hitting_set(n)
        print(f"  n = {n:5d}: hitting set = {hs}")

    # Application 4: Spectral Classification
    print("\n─── APPLICATION 4: Spectral Classification ───")
    print(f"  {'n':>5s}  {'Class':>18s}  {'|L|':>4s}  {'Density':>8s}  {'E/|L|³':>8s}")
    for n in [9, 15, 21, 25, 35, 49, 77, 91, 221, 341, 561, 1105, 1729]:
        info = classify_composite_spectrally(n)
        if info["liar_count"] > 1:
            print(f"  {n:5d}  {info['class']:>18s}  {info['liar_count']:4d}  "
                  f"{info['density']:8.4f}  {info['energy_ratio']:8.4f}")

    # Application 5: AKS Certificates
    print("\n─── APPLICATION 5: AKS Certificate Verification ───")
    for p in [7, 11, 13]:
        cert = verify_aks_certificate(p, r=5, amax=4)
        print(f"  n = {p:3d}, r = 5, amax = 4: "
              f"congruences {'ALL PASS' if cert['congruences_pass'] else 'SOME FAIL'}")

    for n in [9, 15, 21]:
        cert = verify_aks_certificate(n, r=5, amax=4)
        print(f"  n = {n:3d}, r = 5, amax = 4: "
              f"congruences {'ALL PASS' if cert['congruences_pass'] else 'SOME FAIL'}")

    print("\n" + "=" * 70)
    print("  Applications demo complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Primality Testing Demo — Unified Witness Framework

Interactive demonstration of Miller–Rabin, AKS polynomial congruences,
and spectral analysis of strong liar sets.

Usage:
    python demo.py [n]

If n is provided, analyze that specific integer.
Otherwise, run a comprehensive demo on various interesting integers.
"""

import sys
from math import gcd, isqrt, log2
from collections import Counter
from typing import List, Tuple, Set, Optional


# ─── Core Arithmetic ─────────────────────────────────────────────────────────

def two_adic_decomposition(m: int) -> Tuple[int, int]:
    """Decompose m = 2^s * d with d odd."""
    if m == 0:
        return (0, 0)
    s = 0
    d = m
    while d % 2 == 0:
        d //= 2
        s += 1
    return (s, d)


def mod_pow(base: int, exp: int, mod: int) -> int:
    """Modular exponentiation."""
    return pow(base, exp, mod)


def is_strong_probable_prime(n: int, a: int) -> bool:
    """Test if a is a strong probable prime base for n (Miller–Rabin)."""
    if n < 2:
        return False
    if gcd(a, n) != 1:
        return False
    s, d = two_adic_decomposition(n - 1)
    x = mod_pow(a, d, n)
    if x == 1 or x == n - 1:
        return True
    for _ in range(s - 1):
        x = mod_pow(x, 2, n)
        if x == n - 1:
            return True
    return False


def is_prime_trial(n: int) -> bool:
    """Trial division primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def miller_rabin_check(n: int, bases: List[int]) -> bool:
    """Multi-round Miller–Rabin: returns True if n passes for all bases."""
    return all(is_strong_probable_prime(n, a) for a in bases)


# ─── Strong Liar Set Computation ─────────────────────────────────────────────

def compute_strong_liar_set(n: int) -> Set[int]:
    """Compute the set of strong liars for n in {2, …, n-1}."""
    if n < 3:
        return set()
    return {a for a in range(2, n) if gcd(a, n) == 1 and is_strong_probable_prime(n, a)}


def compute_mr_base_set(n: int) -> Set[int]:
    """Compute the set of admissible MR bases: {a ∈ {2,…,n-1} | gcd(a,n)=1}."""
    if n < 3:
        return set()
    return {a for a in range(2, n) if gcd(a, n) == 1}


# ─── AKS Polynomial Congruence ───────────────────────────────────────────────

def poly_mod_xr_minus_1(coeffs: List[int], r: int, n: int) -> List[int]:
    """Reduce polynomial mod (X^r - 1) and mod n."""
    result = [0] * r
    for i, c in enumerate(coeffs):
        result[i % r] = (result[i % r] + c) % n
    return result


def poly_mul_mod(p: List[int], q: List[int], r: int, n: int) -> List[int]:
    """Multiply two polynomials mod (X^r - 1, n)."""
    result = [0] * r
    for i, a in enumerate(p):
        if a == 0:
            continue
        for j, b in enumerate(q):
            if b == 0:
                continue
            idx = (i + j) % r
            result[idx] = (result[idx] + a * b) % n
    return result


def poly_pow_mod(base_coeffs: List[int], exp: int, r: int, n: int) -> List[int]:
    """Compute polynomial^exp mod (X^r - 1, n) by repeated squaring."""
    result = [0] * r
    result[0] = 1  # polynomial "1"
    b = base_coeffs[:]
    while exp > 0:
        if exp % 2 == 1:
            result = poly_mul_mod(result, b, r, n)
        b = poly_mul_mod(b, b, r, n)
        exp //= 2
    return result


def aks_poly_check(n: int, r: int, a: int) -> bool:
    """Check (X + a)^n ≡ X^n + a mod (X^r - 1, n)."""
    # LHS: (X + a)^n mod (X^r - 1, n)
    base = [0] * r
    base[0] = a % n  # constant term
    if r > 1:
        base[1] = 1  # X term
    elif r == 1:
        base[0] = (base[0] + 1) % n
    lhs = poly_pow_mod(base, n, r, n)

    # RHS: X^n + a mod (X^r - 1, n)
    rhs = [0] * r
    rhs[n % r] = (rhs[n % r] + 1) % n
    rhs[0] = (rhs[0] + a) % n

    return lhs == rhs


# ─── Additive Energy / Spectral Analysis ─────────────────────────────────────

def additive_energy(S: Set[int], n: int) -> int:
    """Compute additive energy E(S) = |{(a,b,c,d) ∈ S^4 : a+b ≡ c+d (mod n)}|."""
    sum_counts = Counter()
    for a in S:
        for b in S:
            sum_counts[(a + b) % n] += 1
    return sum(c * c for c in sum_counts.values())


def sumset_size(S: Set[int], n: int) -> int:
    """Compute |S + S mod n|."""
    return len({(a + b) % n for a in S for b in S})


# ─── Demo Functions ──────────────────────────────────────────────────────────

def analyze_integer(n: int, verbose: bool = True):
    """Comprehensive primality analysis of n."""
    if verbose:
        print(f"\n{'='*60}")
        print(f"  Analyzing n = {n}")
        print(f"{'='*60}")

    prime = is_prime_trial(n)
    print(f"  Prime: {prime}")
    print(f"  Odd:   {n % 2 == 1}")

    if n < 3 or n % 2 == 0:
        print(f"  (Skipping MR analysis for n < 3 or even n)")
        return

    s, d = two_adic_decomposition(n - 1)
    print(f"  n - 1 = 2^{s} × {d}")

    base_set = compute_mr_base_set(n)
    liar_set = compute_strong_liar_set(n)

    print(f"\n  MR Base Set size:    |B| = {len(base_set)}")
    print(f"  Strong Liar Set:     |L| = {len(liar_set)}")

    if len(base_set) > 0:
        ratio = len(liar_set) / len(base_set)
        print(f"  Liar density:        |L|/|B| = {ratio:.4f}")
        print(f"  Quarter bound check: 4·|L| ≤ |B|? "
              f"{'YES ✓' if 4 * len(liar_set) <= len(base_set) else 'NO (prime!)'}")

    if not prime and len(liar_set) > 0 and len(liar_set) <= 50:
        print(f"  Liars: {sorted(liar_set)[:20]}{'...' if len(liar_set) > 20 else ''}")

    # Miller–Rabin with standard bases
    standard_bases = [2, 3, 5, 7, 11, 13]
    for b in standard_bases:
        if b < n:
            result = is_strong_probable_prime(n, b)
            print(f"  MR base {b:2d}: {'PASS (liar)' if result else 'FAIL (witness)'}")

    # AKS polynomial check for small r
    if n <= 1000:
        for r in [3, 5, 7]:
            if r > 1:
                results = [aks_poly_check(n, r, a) for a in range(1, min(6, n))]
                all_pass = all(results)
                print(f"  AKS(r={r}): {['✓' if x else '✗' for x in results]} "
                      f"{'ALL PASS' if all_pass else 'SOME FAIL'}")

    # Spectral analysis
    if not prime and len(liar_set) > 2 and len(liar_set) <= 200:
        energy = additive_energy(liar_set, n)
        m = len(liar_set)
        generic_threshold = m ** 3 / n if n > 0 else 0
        print(f"\n  Spectral Analysis:")
        print(f"    Additive energy E(L):     {energy}")
        print(f"    |L|³/n (random threshold): {generic_threshold:.1f}")
        print(f"    E(L) / |L|³:              {energy / m**3:.4f}" if m > 0 else "")
        print(f"    Sumset |L+L|:             {sumset_size(liar_set, n)}")


def demo_carmichael():
    """Analyze Carmichael numbers — the hardest composites for Fermat tests."""
    print("\n" + "─" * 60)
    print("  CARMICHAEL NUMBERS")
    print("  These pass the Fermat test for ALL coprime bases,")
    print("  but Miller–Rabin detects them.")
    print("─" * 60)

    carmichaels = [561, 1105, 1729, 2465, 2821, 6601, 8911]
    for n in carmichaels:
        analyze_integer(n)


def demo_primes():
    """Analyze primes — all bases should be liars."""
    print("\n" + "─" * 60)
    print("  PRIME NUMBERS")
    print("  All coprime bases are 'liars' (they all pass).")
    print("─" * 60)

    primes = [7, 13, 97, 127, 541]
    for p in primes:
        analyze_integer(p)


def demo_composites():
    """Analyze random odd composites."""
    print("\n" + "─" * 60)
    print("  ODD COMPOSITES")
    print("  Most bases should be witnesses (detect compositeness).")
    print("─" * 60)

    composites = [9, 15, 21, 25, 35, 49, 77, 91, 221, 341]
    for n in composites:
        analyze_integer(n)


def demo_error_amplification():
    """Demonstrate error amplification with multiple rounds."""
    print("\n" + "─" * 60)
    print("  ERROR AMPLIFICATION")
    print("  k rounds → error ≤ (1/4)^k")
    print("─" * 60)

    n = 561  # Carmichael number
    base_set = compute_mr_base_set(n)
    liar_set = compute_strong_liar_set(n)
    B = len(base_set)
    L = len(liar_set)

    print(f"\n  n = {n} (Carmichael), |B| = {B}, |L| = {L}")
    print(f"  Single-round error: |L|/|B| = {L/B:.4f}")
    print(f"\n  {'k':>3s}  {'(|L|/|B|)^k':>15s}  {'(1/4)^k':>15s}  {'Bound holds?':>12s}")
    print(f"  {'─'*50}")

    for k in range(1, 11):
        empirical = (L / B) ** k
        bound = (1 / 4) ** k
        holds = empirical <= bound
        print(f"  {k:3d}  {empirical:15.10f}  {bound:15.10f}  {'✓' if holds else '✗':>12s}")


def demo_spectral_conjecture():
    """Test the spectral sparsity conjecture on small composites."""
    print("\n" + "─" * 60)
    print("  SPECTRAL SPARSITY CONJECTURE TEST")
    print("  Checking additive energy of liar sets")
    print("─" * 60)

    print(f"\n  {'n':>5s}  {'Prime?':>6s}  {'|L|':>4s}  {'|B|':>4s}  {'E(L)':>8s}  "
          f"{'|L|³':>8s}  {'E/|L|³':>8s}")
    print(f"  {'─'*55}")

    for n in range(9, 200, 2):
        if n % 2 == 0:
            continue
        if is_prime_trial(n):
            continue

        liar_set = compute_strong_liar_set(n)
        base_set = compute_mr_base_set(n)
        m = len(liar_set)

        if m < 2:
            continue

        energy = additive_energy(liar_set, n)
        cube = m ** 3

        print(f"  {n:5d}  {'N':>6s}  {m:4d}  {len(base_set):4d}  "
              f"{energy:8d}  {cube:8d}  {energy/cube:.4f}")


# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) > 1:
        try:
            n = int(sys.argv[1])
            analyze_integer(n)
        except ValueError:
            print(f"Error: '{sys.argv[1]}' is not a valid integer.")
            sys.exit(1)
    else:
        print("╔══════════════════════════════════════════════════════════╗")
        print("║   Unified Witness Framework for Primality Testing       ║")
        print("║   Demo: Miller–Rabin, AKS, and Spectral Analysis       ║")
        print("╚══════════════════════════════════════════════════════════╝")

        demo_primes()
        demo_composites()
        demo_carmichael()
        demo_error_amplification()
        demo_spectral_conjecture()

        print("\n" + "=" * 60)
        print("  Demo complete. Run with a specific n: python demo.py 561")
        print("=" * 60)


if __name__ == "__main__":
    main()
