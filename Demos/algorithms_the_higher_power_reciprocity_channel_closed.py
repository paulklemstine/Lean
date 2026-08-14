"""All four algorithms of the package, in one runnable file (each block is also
shipped separately in the package's algorithm list)."""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, List, Optional, Sequence, Tuple

# ============================================================ ALGORITHM 1
MR_BASES = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin for n < 3.3e24."""
    if n < 2:
        return False
    for p in MR_BASES:
        if n % p == 0:
            return n == p
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in MR_BASES:
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def power_residuacity_bit(a: int, p: int, k: int) -> bool:
    """Decide whether a is a k-th power residue modulo the prime p.

    Implements the k-th power criterion in the cyclic group (Z/p)^*:
    for k | p-1, a is a k-th power iff a^((p-1)/k) = 1 (mod p).
    Cost: O(log(p/k) squarings) = O(log^3 p) bit operations.
    """
    if a % p == 0:
        raise ValueError("base must be prime to p")
    d = gcd(k, p - 1)
    if d == 1:
        return True                      # k-th powers exhaust the units
    return pow(a, (p - 1) // d, p) == 1


# ============================================================ ALGORITHM 2
def refute_period(k: int, base: int, modulus: int, search_bound: int,
                  congruence_class: Optional[int] = None) -> Optional[Tuple[int, int, int]]:
    """Search for two primes congruent modulo `modulus` with opposite k-th power
    residuacity bits at `base`, refuting `modulus` as a period of the channel.

    Returns (p, q, shared_residue) or None if none is found below the bound.
    Cost: O(pi(B) * log^3 B) time, O(modulus) memory.
    """
    if congruence_class is None:
        congruence_class = 1
    seen: Dict[int, Tuple[int, bool]] = {}
    for p in range(5, search_bound):
        if not is_prime(p) or (p - 1) % k != 0 or p % base == 0:
            continue
        if p % k != congruence_class % k and (p - 1) % k != 0:
            continue
        bit = power_residuacity_bit(base, p, k)
        r = p % modulus
        if r in seen:
            q, bit_q = seen[r]
            if bit_q != bit:
                return (q, p, r)
        else:
            seen[r] = (p, bit)
    return None


# ============================================================ ALGORITHM 3
def capacity_profile(primes: Sequence[int], bases: Sequence[int], k: int
                     ) -> List[Tuple[int, int, int, int]]:
    """For each prefix length K of `bases`, report
    (K, distinct bit-fingerprints, ceiling 2^K, distinct raw symbol vectors).

    The bit column is provably capped by the ceiling at every exponent k; the raw
    column is not capped, because raw symbol values live in Z/p and encode p.
    Cost: O(|primes| * |bases| * log^3 p).
    """
    usable = [p for p in primes if (p - 1) % k == 0 and all(p % a for a in bases)]
    out: List[Tuple[int, int, int, int]] = []
    for K in range(1, len(bases) + 1):
        pref = bases[:K]
        fps = {tuple(power_residuacity_bit(a, p, k) for a in pref) for p in usable}
        raw = {tuple(pow(a, (p - 1) // k, p) for a in pref) for p in usable}
        out.append((K, len(fps), 2 ** K, len(raw)))
    return out


# ============================================================ ALGORITHM 4
def cubic_bit_via_gauss_form(p: int) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """Decide cubic residuacity of 2 modulo a prime p = 1 (mod 3) by Gauss's
    criterion: 2 is a cube modulo p iff p = x^2 + 27 y^2.

    Returns (bit, representation or None).  Cost: O(sqrt(p/27)) integer square
    roots -- exponential in log p, which is exactly why this route is useless to
    an adversary who does not already hold p.
    """
    if p % 3 != 1:
        raise ValueError("criterion applies to primes congruent to 1 mod 3")
    y = 1
    while 27 * y * y <= p:
        rest = p - 27 * y * y
        x = isqrt(rest)
        if x * x == rest:
            return (True, (x, y))
        y += 1
    return (False, None)


# ============================================================ ALGORITHM 5
def hybrid_indistinguishability(candidates: Sequence[int], hint_modulus: int,
                                dial_conductors: Sequence[int],
                                bases: Sequence[int], k: int) -> Dict[str, float]:
    """Compute the guaranteed indistinguishable class size for an observer holding
    a residue hint modulo `hint_modulus`, the readings of dials with the given
    conductors, and K residuacity bits, and compare it with the largest class
    actually observed.

    Guarantee: |Omega| / ((M* / gcd(M*, m)) * 2^K), where M* is the lcm of the
    dial conductors.  Cost: O(|Omega| * (L + K) * log^3 p).
    """
    M_star = 1
    for c in dial_conductors:
        M_star = M_star * c // gcd(M_star, c)
    K = len(bases)
    divisor = (M_star // gcd(M_star, hint_modulus)) * 2 ** K
    fibres: Dict[Tuple, int] = {}
    for p in candidates:
        key = (tuple(p % c for c in dial_conductors),
               tuple(power_residuacity_bit(a, p, k) for a in bases))
        fibres[key] = fibres.get(key, 0) + 1
    largest = max(fibres.values()) if fibres else 0
    return {
        "candidates": float(len(candidates)),
        "dial_conductor_lcm": float(M_star),
        "bound_divisor": float(divisor),
        "guaranteed_class_size": len(candidates) / divisor if divisor else 0.0,
        "observed_largest_class": float(largest),
    }


if __name__ == "__main__":
    print("bit(2, 43, 3)      =", power_residuacity_bit(2, 43, 3))
    print("bit(2, 720763, 3)  =", power_residuacity_bit(2, 720763, 3))
    print("refute period 24   =", refute_period(3, 2, 24, 20000))
    ps = [p for p in range(1000, 2000) if is_prime(p) and p % 3 == 1]
    for row in capacity_profile(ps, (2, 3, 5, 7, 11), 3):
        print("K=%d bits=%d ceiling=%d raw=%d" % row)
    print("Gauss form 43      =", cubic_bit_via_gauss_form(43))
    print("Gauss form 720763  =", cubic_bit_via_gauss_form(720763))
    omega = [p for p in range(1000, 20000) if is_prime(p) and p % 4 == 1 and p % 3 == 1]
    print(hybrid_indistinguishability(omega, 4, (8, 5), (2, 3, 5), 3))
