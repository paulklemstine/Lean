#!/usr/bin/env python3
"""
Applications of Quadratic Reciprocity

Demonstrates real-world applications of quadratic reciprocity in:
1. Cryptographic residue testing (Solovay-Strassen primality test)
2. Efficient square-root computation modulo primes
3. Quadratic sieve factoring (residue selection)
4. Error-correcting codes (quadratic residue codes)
"""

from typing import List, Tuple, Optional
import math
import random


# ---------------------------------------------------------------------------
# Application 1: Solovay-Strassen Primality Test
# ---------------------------------------------------------------------------

def jacobi_symbol(a: int, n: int) -> int:
    """Compute the Jacobi symbol (a/n)."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("n must be a positive odd integer")
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def solovay_strassen_test(n: int, k: int = 20) -> bool:
    """
    Solovay-Strassen primality test using quadratic reciprocity.

    The test exploits the fact that for prime p, the Jacobi symbol (a/p)
    equals a^((p-1)/2) mod p (Euler's criterion). For composites, this
    identity fails for at least half of all witnesses a.

    Args:
        n: Number to test for primality.
        k: Number of rounds (probability of error ≤ 2^(-k)).

    Returns:
        True if n is probably prime, False if definitely composite.

    Example:
        >>> solovay_strassen_test(997)
        True
        >>> solovay_strassen_test(999)
        False
    """
    if n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False

    for _ in range(k):
        a = random.randint(2, n - 1)
        jac = jacobi_symbol(a, n)
        if jac == 0:
            return False
        euler = pow(a, (n - 1) // 2, n)
        if euler != jac % n:
            return False
    return True


# ---------------------------------------------------------------------------
# Application 2: Modular Square Roots (Tonelli-Shanks)
# ---------------------------------------------------------------------------

def tonelli_shanks(n: int, p: int) -> Optional[int]:
    """
    Compute a square root of n modulo prime p using Tonelli-Shanks algorithm.

    The algorithm uses the Legendre symbol (computed via quadratic reciprocity)
    to first verify that n is a quadratic residue, then finds the actual root.

    Time complexity: O(log²(p)) expected.

    Args:
        n: Integer to find square root of.
        p: Odd prime modulus.

    Returns:
        An integer r such that r² ≡ n (mod p), or None if n is not a QR.

    Example:
        >>> r = tonelli_shanks(2, 7)
        >>> r is not None and (r * r) % 7 == 2
        True
    """
    n = n % p
    if n == 0:
        return 0
    if pow(n, (p - 1) // 2, p) != 1:
        return None  # Not a quadratic residue

    # Factor out powers of 2 from p-1
    q = p - 1
    s = 0
    while q % 2 == 0:
        q //= 2
        s += 1

    if s == 1:
        return pow(n, (p + 1) // 4, p)

    # Find a quadratic non-residue
    z = 2
    while pow(z, (p - 1) // 2, p) != p - 1:
        z += 1

    m = s
    c = pow(z, q, p)
    t = pow(n, q, p)
    r = pow(n, (q + 1) // 2, p)

    while True:
        if t == 1:
            return r
        i = 1
        temp = (t * t) % p
        while temp != 1:
            temp = (temp * temp) % p
            i += 1
        b = pow(c, 1 << (m - i - 1), p)
        m = i
        c = (b * b) % p
        t = (t * c) % p
        r = (r * b) % p


# ---------------------------------------------------------------------------
# Application 3: Quadratic Residue Codes
# ---------------------------------------------------------------------------

def qr_code_generator(p: int) -> List[int]:
    """
    Generate a quadratic residue code of length p.

    Quadratic residue codes are a class of cyclic error-correcting codes
    whose generator polynomial is determined by the quadratic residues mod p.
    They achieve near-optimal minimum distance for their rate.

    The generator polynomial has roots at the quadratic non-residues modulo p.

    Args:
        p: An odd prime (code length).

    Returns:
        List of positions corresponding to quadratic residues mod p.

    Example:
        >>> qr_code_generator(7)
        [1, 2, 4]
    """
    residues = []
    for a in range(1, p):
        if pow(a, (p - 1) // 2, p) == 1:
            residues.append(a)
    return residues


def qr_code_check_matrix(p: int) -> List[List[int]]:
    """
    Build the parity check matrix for a QR code of length p over GF(2).

    The code corrects up to t = (d-1)/2 errors where d is the minimum distance.
    For QR codes, d ≥ √p by the square root bound.

    Args:
        p: An odd prime.

    Returns:
        Parity check matrix as list of rows.
    """
    residues = set(qr_code_generator(p))
    non_residues = [a for a in range(1, p) if a not in residues]

    # The check matrix has rows indexed by non-residues
    matrix = []
    for nr in non_residues[:len(non_residues)//2 + 1]:
        row = [0] * p
        for j in range(p):
            row[j] = 1 if (j - nr) % p in residues or j == nr else 0
        matrix.append(row)
    return matrix


# ---------------------------------------------------------------------------
# Application 4: Quadratic Sieve - Residue Selection
# ---------------------------------------------------------------------------

def factor_base_selection(n: int, bound: int) -> List[int]:
    """
    Select a factor base for the quadratic sieve using Legendre symbols.

    Only primes p for which (n mod p) is a quadratic residue are useful
    in the factor base, since we need x² - n ≡ 0 (mod p) to have solutions.

    This uses quadratic reciprocity to efficiently compute the Legendre symbols.

    Args:
        n: Number to factor.
        bound: Upper bound for factor base primes.

    Returns:
        List of primes p ≤ bound with (n/p) = 1.

    Example:
        >>> fb = factor_base_selection(1000009, 50)
        >>> all(pow(1000009, (p-1)//2, p) == 1 for p in fb)
        True
    """
    def sieve(limit):
        s = [True] * (limit + 1)
        s[0] = s[1] = False
        for i in range(2, int(limit**0.5) + 1):
            if s[i]:
                for j in range(i*i, limit+1, i):
                    s[j] = False
        return [p for p in range(2, limit+1) if s[p]]

    primes = sieve(bound)
    factor_base = [2]  # Always include 2
    for p in primes:
        if p == 2:
            continue
        # Use Jacobi symbol for efficiency (equals Legendre for primes)
        if jacobi_symbol(n % p, p) == 1:
            factor_base.append(p)
    return factor_base


# ---------------------------------------------------------------------------
# Main demonstration
# ---------------------------------------------------------------------------

def main():
    print("=" * 60)
    print("  APPLICATIONS OF QUADRATIC RECIPROCITY")
    print("=" * 60)

    # Application 1: Primality testing
    print("\n─── Solovay-Strassen Primality Test ───")
    test_numbers = [
        (997, True), (999, False), (7919, True),
        (8051, False), (104729, True), (104731, False),
    ]
    for n, expected in test_numbers:
        result = solovay_strassen_test(n, k=30)
        status = "✓" if result == expected else "✗"
        print(f"  n={n:8d}  probably_prime={result!s:5s}  "
              f"expected={expected!s:5s}  {status}")

    # Application 2: Square roots mod p
    print("\n─── Modular Square Roots (Tonelli-Shanks) ───")
    test_cases = [(2, 7), (3, 11), (5, 23), (10, 13), (2, 113)]
    for n, p in test_cases:
        r = tonelli_shanks(n, p)
        if r is not None:
            verify = (r * r) % p == n % p
            print(f"  √{n} mod {p} = {r}  "
                  f"(verify: {r}² = {r*r} ≡ {(r*r)%p} mod {p})  "
                  f"{'✓' if verify else '✗'}")
        else:
            print(f"  √{n} mod {p} = None (not a QR)")

    # Application 3: QR codes
    print("\n─── Quadratic Residue Codes ───")
    for p in [7, 11, 17, 23]:
        residues = qr_code_generator(p)
        non_res = [a for a in range(1, p) if a not in residues]
        print(f"  p={p:2d}: QRs={residues}, Non-QRs={non_res}, "
              f"rate={(len(residues)+1)}/{p}")

    # Application 4: Factor base selection
    print("\n─── Quadratic Sieve Factor Base ───")
    n = 1000009
    fb = factor_base_selection(n, 100)
    print(f"  n = {n}")
    print(f"  Factor base (primes ≤ 100 with (n/p)=1): {fb}")
    print(f"  Factor base size: {len(fb)} out of 25 primes ≤ 100")

    # Verify the factor base
    all_ok = all(pow(n, (p-1)//2, p) == 1 for p in fb if p > 2)
    print(f"  All verified as QRs: {all_ok}")

    print()

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Quadratic Reciprocity: Interactive Exploration & Verification

Demonstrates three independent computation methods for quadratic reciprocity
and verifies they agree across many prime pairs. Also verifies the supplementary
laws for (-1/p) and (2/p), and visualizes Eisenstein's lattice-point proof.

Usage:
    python demo.py
"""

import math
from typing import List, Tuple

# ---------------------------------------------------------------------------
# Primality and basic number theory
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Check if n is prime."""
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

def odd_primes(limit: int) -> List[int]:
    """Return all odd primes up to limit."""
    return [p for p in range(3, limit + 1) if is_prime(p)]

# ---------------------------------------------------------------------------
# Legendre symbol via Euler's criterion
# ---------------------------------------------------------------------------

def legendre_symbol(a: int, p: int) -> int:
    """Compute the Legendre symbol (a/p) using Euler's criterion."""
    if p == 2:
        raise ValueError("p must be an odd prime")
    a = a % p
    if a == 0:
        return 0
    result = pow(a, (p - 1) // 2, p)
    return result if result == 1 else -1

# ---------------------------------------------------------------------------
# Method 1: Direct Legendre symbol product
# ---------------------------------------------------------------------------

def qr_direct(p: int, q: int) -> int:
    """Compute legendreSym(q, p) * legendreSym(p, q) directly."""
    return legendre_symbol(q, p) * legendre_symbol(p, q)

# ---------------------------------------------------------------------------
# Method 2: Eisenstein floor-sum
# ---------------------------------------------------------------------------

def eisenstein_floor_sum(p: int, q: int) -> int:
    """Compute ∑_{i=1}^{(p-1)/2} ⌊iq/p⌋."""
    return sum((i * q) // p for i in range(1, (p - 1) // 2 + 1))

def qr_eisenstein(p: int, q: int) -> int:
    """Compute (-1)^(eisenstein_floor_sum(p,q) + eisenstein_floor_sum(q,p))."""
    total = eisenstein_floor_sum(p, q) + eisenstein_floor_sum(q, p)
    return (-1) ** total

def eisenstein_identity_value(p: int, q: int) -> int:
    """Compute (p-1)(q-1)/4."""
    return (p - 1) * (q - 1) // 4

# ---------------------------------------------------------------------------
# Method 3: Gauss lemma (upper-half residue count)
# ---------------------------------------------------------------------------

def upper_half_residue_count(a: int, p: int) -> int:
    """Count k in [1, (p-1)/2] such that (a*k) mod p > p/2."""
    half = (p - 1) // 2
    return sum(1 for k in range(1, half + 1) if (a * k) % p > p // 2)

def qr_gauss(p: int, q: int) -> int:
    """Compute (-1)^(upper_half_count(q,p) + upper_half_count(p,q))."""
    total = upper_half_residue_count(q, p) + upper_half_residue_count(p, q)
    return (-1) ** total

# ---------------------------------------------------------------------------
# Supplementary laws
# ---------------------------------------------------------------------------

def supplementary_minus_one(p: int) -> Tuple[int, int]:
    """Return (actual Legendre symbol, predicted value) for (-1/p)."""
    actual = legendre_symbol(p - 1, p)  # -1 ≡ p-1 mod p
    predicted = (-1) ** ((p - 1) // 2)
    return actual, predicted

def supplementary_two(p: int) -> Tuple[int, int]:
    """Return (actual Legendre symbol, predicted value) for (2/p)."""
    actual = legendre_symbol(2, p)
    predicted = (-1) ** ((p * p - 1) // 8)
    return actual, predicted

# ---------------------------------------------------------------------------
# Lattice region for Eisenstein's proof
# ---------------------------------------------------------------------------

def lattice_region(p: int, q: int) -> List[Tuple[int, int]]:
    """Return lattice points (x,y) with 1≤x≤(p-1)/2, 1≤y≤(q-1)/2, y*p < x*q."""
    points = []
    for x in range(1, (p - 1) // 2 + 1):
        for y in range(1, (q - 1) // 2 + 1):
            if y * p < x * q:
                points.append((x, y))
    return points

def visualize_lattice(p: int, q: int):
    """ASCII visualization of Eisenstein's lattice region."""
    half_p = (p - 1) // 2
    half_q = (q - 1) // 2

    print(f"\n  Eisenstein lattice for p={p}, q={q}")
    print(f"  Rectangle: [1,{half_p}] × [1,{half_q}]")
    print(f"  Line: y = ({q}/{p})x")
    print()

    below = lattice_region(p, q)
    above = lattice_region(q, p)  # symmetric: (y,x) with x*q < y*p

    for y in range(half_q, 0, -1):
        row = f"  {y:2d} |"
        for x in range(1, half_p + 1):
            if y * p < x * q:
                row += " ▼"  # below the line
            elif x * q < y * p:
                row += " ▲"  # above the line (would be in the q,p region)
            else:
                row += " ·"  # on the line (shouldn't happen for coprime p,q)
        print(row)
    print("     +" + "--" * half_p)
    nums = "      "
    for x in range(1, half_p + 1):
        nums += f"{x:2d}"
    print(nums)
    print(f"\n  ▼ = below line ({len(below)} points) = eisensteinFloorSum({p},{q})")
    print(f"  Total below+above = {len(below)}+{len(above)} = {len(below)+len(above)}")
    print(f"  Expected: ({p}-1)({q}-1)/4 = {eisenstein_identity_value(p, q)}")

# ---------------------------------------------------------------------------
# Main demonstration
# ---------------------------------------------------------------------------

def main():
    primes = odd_primes(50)
    print("=" * 72)
    print("  QUADRATIC RECIPROCITY: THREE PROOF METHODS COMPARED")
    print("=" * 72)

    # --- Eisenstein floor-sum identity ---
    print("\n─── Eisenstein Floor-Sum Identity ───")
    print(f"{'p':>4} {'q':>4} {'FloorSum(p,q)':>14} {'FloorSum(q,p)':>14} {'Sum':>6} {'(p-1)(q-1)/4':>14} {'Match':>6}")
    print("-" * 72)
    all_match = True
    for i, p in enumerate(primes):
        for q in primes[i+1:]:
            fs_pq = eisenstein_floor_sum(p, q)
            fs_qp = eisenstein_floor_sum(q, p)
            total = fs_pq + fs_qp
            expected = eisenstein_identity_value(p, q)
            match = "✓" if total == expected else "✗"
            if total != expected:
                all_match = False
            if p <= 19 and q <= 19:
                print(f"{p:4d} {q:4d} {fs_pq:14d} {fs_qp:14d} {total:6d} {expected:14d} {match:>6}")
    print(f"\nAll Eisenstein identities match: {all_match}")

    # --- Three methods comparison ---
    print("\n─── Quadratic Reciprocity: Three Methods ───")
    print(f"{'p':>4} {'q':>4} {'Direct':>8} {'Eisenstein':>12} {'Gauss':>8} {'(-1)^exp':>10} {'All agree':>10}")
    print("-" * 72)
    all_agree = True
    for i, p in enumerate(primes):
        for q in primes[i+1:]:
            direct = qr_direct(p, q)
            eisen = qr_eisenstein(p, q)
            gauss = qr_gauss(p, q)
            exp_val = (-1) ** (((p - 1) // 2) * ((q - 1) // 2))
            agree = direct == eisen == gauss == exp_val
            if not agree:
                all_agree = False
            if p <= 13:
                print(f"{p:4d} {q:4d} {direct:8d} {eisen:12d} {gauss:8d} {exp_val:10d} {'✓' if agree else '✗':>10}")
    print(f"\nAll three methods agree across {len(primes)} primes: {all_agree}")

    # --- Supplementary laws ---
    print("\n─── Supplementary Laws ───")
    print(f"{'p':>4} {'(-1/p) actual':>14} {'(-1/p) pred':>12} {'(2/p) actual':>14} {'(2/p) pred':>12} {'Match':>6}")
    print("-" * 72)
    supp_ok = True
    for p in primes:
        m1_act, m1_pred = supplementary_minus_one(p)
        t2_act, t2_pred = supplementary_two(p)
        ok = m1_act == m1_pred and t2_act == t2_pred
        if not ok:
            supp_ok = False
        print(f"{p:4d} {m1_act:14d} {m1_pred:12d} {t2_act:14d} {t2_pred:12d} {'✓' if ok else '✗':>6}")
    print(f"\nAll supplementary laws verified: {supp_ok}")

    # --- Lattice visualization ---
    visualize_lattice(7, 11)
    visualize_lattice(5, 13)

    # --- Parity equivalence ---
    print("\n─── Eisenstein vs Gauss Parity Equivalence ───")
    print(f"{'p':>4} {'q':>4} {'Eisen parity':>14} {'Gauss parity':>14} {'Match':>6}")
    print("-" * 56)
    parity_ok = True
    for i, p in enumerate(primes):
        for q in primes[i+1:]:
            e_parity = (eisenstein_floor_sum(p, q) + eisenstein_floor_sum(q, p)) % 2
            g_parity = (upper_half_residue_count(q, p) + upper_half_residue_count(p, q)) % 2
            ok = e_parity == g_parity
            if not ok:
                parity_ok = False
            if p <= 13:
                print(f"{p:4d} {q:4d} {e_parity:14d} {g_parity:14d} {'✓' if ok else '✗':>6}")
    print(f"\nEisenstein-Gauss parity equivalence: {parity_ok}")

    # --- Summary ---
    print("\n" + "=" * 72)
    print("  SUMMARY")
    print("=" * 72)
    print(f"  Eisenstein floor-sum identity:     {'VERIFIED' if all_match else 'FAILED'}")
    print(f"  Three-method agreement:            {'VERIFIED' if all_agree else 'FAILED'}")
    print(f"  Supplementary laws:                {'VERIFIED' if supp_ok else 'FAILED'}")
    print(f"  Eisenstein-Gauss parity equiv:     {'VERIFIED' if parity_ok else 'FAILED'}")
    print(f"  Primes tested: {primes}")
    print()

if __name__ == "__main__":
    main()
