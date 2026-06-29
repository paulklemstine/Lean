#!/usr/bin/env python3
"""
Algorithms for Collatz Orbit Analysis
======================================
Type-hinted implementations of the key algorithms from the research.
"""

from fractions import Fraction
from typing import List, Tuple, Optional, Dict
import math


def collatz_step(n: int) -> int:
    """The Collatz step function T(n).

    T(n) = n/2 if n is even, 3n+1 if n is odd.
    """
    if n % 2 == 0:
        return n // 2
    else:
        return 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 100000) -> List[int]:
    """Compute the full Collatz orbit until reaching 1.

    Returns the sequence [n, T(n), T²(n), ...] terminating at 1.
    """
    orbit = [n]
    current = n
    while current != 1 and len(orbit) < max_steps:
        current = collatz_step(current)
        orbit.append(current)
    return orbit


def stopping_time(n: int, max_steps: int = 1000000) -> Optional[int]:
    """Compute the stopping time: minimum k with T^k(n) = 1.

    Returns None if 1 is not reached within max_steps.
    """
    current = n
    for k in range(max_steps):
        if current == 1:
            return k
        current = collatz_step(current)
    return None


def syracuse_step(n: int) -> int:
    """The Syracuse function S(n) = (3n+1)/2.

    Precondition: n must be odd.
    """
    assert n % 2 == 1
    return (3 * n + 1) // 2


def parity_word(n: int, k: int) -> List[bool]:
    """Extract the parity word of the first k values in the orbit.

    Returns a list where True = odd, False = even.
    """
    word: List[bool] = []
    current = n
    for _ in range(k):
        word.append(current % 2 == 1)
        current = collatz_step(current)
    return word


def affine_parameters(word: List[bool]) -> Tuple[Fraction, Fraction]:
    """Compute the affine encoding (multiplier, offset) for a parity word.

    After following parity word w starting from rational q, the result is:
      multiplier(w) * q + offset(w)

    The word is in chronological order: word[i] = parity at step i.
    The encoding gives affine_image(n) = mult * n + off = T^k(n).
    """
    mult = Fraction(1)
    off = Fraction(0)
    for b in word:
        if b:  # odd: multiply by 3 and add 1
            mult = 3 * mult
            off = 3 * off + 1
        else:  # even: divide by 2
            mult = mult / 2
            off = off / 2
    return mult, off


def affine_compose(
    m1: Fraction, o1: Fraction,
    m2: Fraction, o2: Fraction
) -> Tuple[Fraction, Fraction]:
    """Compose two affine maps: (m1, o1) ∘ (m2, o2).

    If f(x) = m1*x + o1 and g(x) = m2*x + o2,
    then (f ∘ g)(x) = m1*m2*x + m1*o2 + o1.
    """
    return m1 * m2, m1 * o2 + o1


def inverse_preimages(n: int) -> List[int]:
    """Find all Collatz preimages of n.

    Every n has the even preimage 2n.
    n has an odd preimage (n-1)/3 iff n ≡ 4 (mod 6) and (n-1)/3 ≥ 1.
    """
    preimages = [2 * n]  # even preimage always exists
    if n >= 4 and n % 6 == 4:
        m = (n - 1) // 3
        if m >= 1 and m % 2 == 1:
            preimages.append(m)
    return preimages


def orbit_merge_point(a: int, b: int) -> Optional[Tuple[int, int, int]]:
    """Find where the orbits of a and b first merge.

    Returns (j, k, value) where T^j(a) = T^k(b) = value,
    or None if no merge found within bounds.
    """
    orbit_a = collatz_orbit(a)
    orbit_b = collatz_orbit(b)
    set_a: Dict[int, int] = {v: i for i, v in enumerate(orbit_a)}
    for k, v in enumerate(orbit_b):
        if v in set_a:
            return set_a[v], k, v
    return None


def two_adic_valuation(n: int) -> int:
    """Compute the 2-adic valuation v₂(n): largest k with 2^k | n."""
    if n == 0:
        return -1  # convention: v₂(0) = ∞
    v = 0
    while n % 2 == 0:
        n //= 2
        v += 1
    return v


def consecutive_halvings(n: int) -> int:
    """For odd n, count how many consecutive halvings follow the 3n+1 step.

    This equals v₂(3n+1), the 2-adic valuation of 3n+1.
    """
    assert n % 2 == 1
    return two_adic_valuation(3 * n + 1)


def max_stopping_time(N: int) -> Tuple[int, int]:
    """Find the maximum stopping time among [1, N].

    Returns (argmax, max_value).
    """
    best_n, best_t = 1, 0
    for n in range(1, N + 1):
        t = stopping_time(n)
        if t is not None and t > best_t:
            best_n, best_t = n, t
    return best_n, best_t


def residue_class_analysis(mod: int, steps: int = 2) -> Dict[int, List[int]]:
    """Analyze Collatz behavior by residue class mod `mod`.

    For each residue class r mod `mod`, compute the residue class of T^steps(r)
    mod `mod` (if it's well-defined for all representatives).
    """
    result: Dict[int, List[int]] = {}
    for r in range(mod):
        trajectory: List[int] = [r]
        current = r
        for _ in range(steps):
            # Use a representative large enough to avoid issues
            n = current + mod * 100
            current = collatz_step(n) % mod
            trajectory.append(current)
        result[r] = trajectory
    return result


if __name__ == "__main__":
    # Quick test
    print("Orbit of 27:", collatz_orbit(27)[:15], "...")
    print("Stopping time of 27:", stopping_time(27))
    print("Parity word of 27 (10 steps):", parity_word(27, 10))
    print("Affine params:", affine_parameters(parity_word(27, 10)))
    print("Preimages of 10:", inverse_preimages(10))
    print("Merge point 7, 15:", orbit_merge_point(7, 15))
    print("2-adic val of 3*7+1=22:", two_adic_valuation(22))
    print("Consecutive halvings from 7:", consecutive_halvings(7))
