"""
demo.py — Numerical demonstrations for the Gaussian-Integer Bridge for Ring-LWE.

This self-contained script illustrates, with concrete numbers, every key result
from the formal development:

  1. The Gaussian norm  N(a + bi) = a^2 + b^2  and its multiplicativity
     (the Brahmagupta-Fibonacci composition identity).
  2. The split / inert dichotomy of rational primes in Z[i], governed by p mod 4
     (Fermat's two-squares theorem).
  3. Nearest-codeword rounding and one-dimensional decoding correctness.
  4. The Euclidean-ball error bound  e_x^2 + e_y^2 < (q/4)^2  and the derived
     per-coordinate bounds.
  5. End-to-end ring-LWE bit encryption over Z[i] with decryption correctness.
  6. The pigeonhole per-coordinate advantage bound of the search-to-decision
     reduction, and the Regev approximation-factor bound gamma <= q*sqrt(n)/2.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import List, Optional, Tuple


# ---------------------------------------------------------------------------
# 1. The Gaussian integers and their norm
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Gaussian:
    """A Gaussian integer a + b*i with integer coordinates."""
    re: int
    im: int

    def __add__(self, other: "Gaussian") -> "Gaussian":
        return Gaussian(self.re + other.re, self.im + other.im)

    def __sub__(self, other: "Gaussian") -> "Gaussian":
        return Gaussian(self.re - other.re, self.im - other.im)

    def __mul__(self, other: "Gaussian") -> "Gaussian":
        # (a + b i)(c + d i) = (ac - bd) + (ad + bc) i
        return Gaussian(
            self.re * other.re - self.im * other.im,
            self.re * other.im + self.im * other.re,
        )

    def __repr__(self) -> str:
        sign = "+" if self.im >= 0 else "-"
        return f"({self.re} {sign} {abs(self.im)}i)"


def gauss_norm(z: Gaussian) -> int:
    """N(a + b i) = a^2 + b^2 (the Pythagorean sum of two squares)."""
    return z.re ** 2 + z.im ** 2


def demo_norm_multiplicativity() -> None:
    """Verify gaussNorm_mul: N(z*w) = N(z)*N(w) via Brahmagupta-Fibonacci."""
    print("=" * 70)
    print("1. MULTIPLICATIVITY OF THE GAUSSIAN NORM (gaussNorm_mul)")
    print("=" * 70)
    pairs: List[Tuple[Gaussian, Gaussian]] = [
        (Gaussian(1, 2), Gaussian(2, 3)),
        (Gaussian(3, 4), Gaussian(5, 12)),
        (Gaussian(-2, 5), Gaussian(7, -1)),
    ]
    for z, w in pairs:
        lhs = gauss_norm(z * w)
        rhs = gauss_norm(z) * gauss_norm(w)
        # Brahmagupta-Fibonacci in explicit coordinate form:
        a, b, c, d = z.re, z.im, w.re, w.im
        bf_lhs = (a ** 2 + b ** 2) * (c ** 2 + d ** 2)
        bf_rhs = (a * c - b * d) ** 2 + (a * d + b * c) ** 2
        ok = (lhs == rhs == bf_lhs == bf_rhs)
        print(f"  z={z}, w={w}:  N(zw)={lhs}, N(z)N(w)={rhs}   "
              f"[B-F: {bf_lhs} = {bf_rhs}]   {'OK' if ok else 'FAIL'}")
        assert ok
    print()


# ---------------------------------------------------------------------------
# 2. Split / inert primes (Fermat's two-squares theorem)
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


def sum_of_two_squares(p: int) -> Optional[Tuple[int, int]]:
    """Return (a, b) with a^2 + b^2 = p if it exists, else None."""
    a = 0
    while a * a <= p:
        b2 = p - a * a
        b = int(math.isqrt(b2))
        if b * b == b2:
            return (a, b)
        a += 1
    return None


def classify_prime(p: int) -> str:
    """Classify a rational prime by its behaviour in Z[i]."""
    if p == 2:
        return "ramified (2 = -i*(1+i)^2)"
    if p % 4 == 1:
        return "split"
    return "inert"


def demo_prime_dichotomy() -> None:
    """Verify prime_split / prime_inert / *_sum_two_squares."""
    print("=" * 70)
    print("2. SPLIT / INERT DICHOTOMY OF PRIMES IN Z[i]")
    print("=" * 70)
    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29]:
        assert is_prime(p)
        cls = classify_prime(p)
        sq = sum_of_two_squares(p)
        if p % 4 == 1:
            assert sq is not None, "split prime must be a sum of two squares"
            a, b = sq
            assert a * a + b * b == p
            print(f"  p={p:2d}  (p mod 4 = 1)  {cls:8s}  "
                  f"= {a}^2 + {b}^2 = ({a}+{b}i)({a}-{b}i)")
        elif p % 4 == 3:
            assert sq is None, "inert prime is NOT a sum of two squares"
            print(f"  p={p:2d}  (p mod 4 = 3)  {cls:8s}  "
                  f"not a sum of two squares; stays prime in Z[i]")
    print()


# ---------------------------------------------------------------------------
# 3 & 4. Rounding decoder and Euclidean-ball error bound
# ---------------------------------------------------------------------------

def decode_coord(t: int, v: int) -> int:
    """Nearest-codeword decoder: 0 if 2v < t, else 1 (decodeCoord)."""
    return 0 if 2 * v < t else 1


def coord_bounds_from_ball(q: int, e_re: int, e_im: int) -> bool:
    """Check the Euclidean ball e_re^2 + e_im^2 < (q/4)^2 and the derived
    per-coordinate bounds 2|e| < t (coord_bound_re / coord_bound_im)."""
    t = q // 2
    in_ball = e_re ** 2 + e_im ** 2 < (q / 4) ** 2
    if in_ball:
        # Theorems coord_bound_re / coord_bound_im
        assert 2 * abs(e_re) < t
        assert 2 * abs(e_im) < t
    return in_ball


def demo_decoding() -> None:
    """Verify decodeCoord_correct and the ball -> coordinate implication."""
    print("=" * 70)
    print("3-4. ROUNDING DECODER AND EUCLIDEAN-BALL ERROR BOUND")
    print("=" * 70)
    q = 16
    t = q // 2  # = 8
    print(f"  modulus q = {q}, half-modulus t = q/2 = {t}, radius q/4 = {q/4}")
    # One-dimensional decoding correctness for all small errors with 2|e| < t.
    for m in (0, 1):
        for e in range(-(t // 2) + 1, t // 2):
            if 2 * abs(e) < t:
                got = decode_coord(t, e + m * t)
                assert got == m, (m, e, got)
    print("  decodeCoord_correct verified for all e with 2|e| < t, m in {0,1}")
    # Ball -> coordinate bounds.
    for (er, ei) in [(2, 2), (3, 1), (0, 3), (3, 3), (4, 0)]:
        in_ball = coord_bounds_from_ball(q, er, ei)
        status = "inside ball -> coords bounded" if in_ball else "outside ball"
        print(f"  (e_x,e_y)=({er},{ei}): e_x^2+e_y^2={er**2+ei**2} "
              f"vs (q/4)^2={(q//4)**2:>2}  {status}")
    print()


# ---------------------------------------------------------------------------
# 5. End-to-end ring-LWE bit encryption over Z[i]
# ---------------------------------------------------------------------------

def encode_msg(t: int, m_re: int, m_im: int) -> Gaussian:
    """encodeMsg: pack two bits as (m_re*t) + (m_im*t) i."""
    return Gaussian(m_re * t, m_im * t)


def encrypt(t: int, s: Gaussian, a: Gaussian,
            e_re: int, e_im: int, m_re: int, m_im: int) -> Tuple[Gaussian, Gaussian]:
    """encrypt: ciphertext (u, v) = (a, a*s + e + encodeMsg)."""
    v = a * s + Gaussian(e_re, e_im) + encode_msg(t, m_re, m_im)
    return (a, v)


def decrypt(t: int, s: Gaussian, c: Tuple[Gaussian, Gaussian]) -> Tuple[int, int]:
    """decrypt: strip the mask u*s and round each coordinate."""
    u, v = c
    phase = v - u * s
    return (decode_coord(t, phase.re), decode_coord(t, phase.im))


def demo_encryption() -> None:
    """Verify end-to-end decryption correctness over Z[i]."""
    print("=" * 70)
    print("5. RING-LWE BIT ENCRYPTION OVER Z[i] (decryption correctness)")
    print("=" * 70)
    q = 16
    t = q // 2  # = 8
    s = Gaussian(3, -2)   # secret
    a = Gaussian(5, 1)    # public coordinate
    trials = [
        (0, 0, 1, 1),
        (0, 1, 2, -2),
        (1, 0, -1, 3),
        (1, 1, 3, 0),
    ]
    for (m_re, m_im, e_re, e_im) in trials:
        assert e_re ** 2 + e_im ** 2 < (q / 4) ** 2, "error must be inside ball"
        c = encrypt(t, s, a, e_re, e_im, m_re, m_im)
        out = decrypt(t, s, c)
        ok = out == (m_re, m_im)
        print(f"  msg=({m_re},{m_im}), err=({e_re},{e_im}) -> decrypt={out}  "
              f"{'OK' if ok else 'FAIL'}")
        assert ok
    print()


# ---------------------------------------------------------------------------
# 6. Search-to-decision pigeonhole bound and Regev approx factor
# ---------------------------------------------------------------------------

def best_coordinate_advantage(coord_adv: List[float]) -> Tuple[int, float]:
    """search_to_decision_advantage_bound: with total delta = sum(coord_adv),
    some coordinate has advantage >= delta/n."""
    n = len(coord_adv)
    delta = sum(coord_adv)
    i_best = max(range(n), key=lambda i: coord_adv[i])
    assert coord_adv[i_best] >= delta / n - 1e-12
    return i_best, coord_adv[i_best]


def regev_approx_factor_bound(n: float, q: float, alpha: float) -> Tuple[float, float]:
    """Regev: gamma = n/alpha, and feasibility alpha*q >= 2*sqrt(n) implies
    gamma <= q*sqrt(n)/2 (RegevReductionCertificate.approx_factor_le)."""
    assert alpha * q >= 2 * math.sqrt(n) - 1e-9, "feasibility alpha*q >= 2 sqrt(n)"
    gamma = n / alpha
    bound = q * math.sqrt(n) / 2
    assert gamma <= bound + 1e-9
    return gamma, bound


def demo_reduction() -> None:
    """Verify the pigeonhole advantage bound and the Regev approx-factor bound."""
    print("=" * 70)
    print("6. SEARCH-TO-DECISION AND REGEV APPROXIMATION FACTOR")
    print("=" * 70)
    coord_adv = [0.01, 0.05, 0.02, 0.07, 0.03]
    n = len(coord_adv)
    delta = sum(coord_adv)
    i, adv = best_coordinate_advantage(coord_adv)
    print(f"  coord advantages = {coord_adv}")
    print(f"  total delta = {delta:.3f}, n = {n}, delta/n = {delta/n:.4f}")
    print(f"  best coordinate i={i} has advantage {adv:.3f} >= delta/n  OK")
    print()
    for (n_dim, q, alpha) in [(256.0, 4093.0, 0.01), (512.0, 12289.0, 0.005)]:
        gamma, bound = regev_approx_factor_bound(n_dim, q, alpha)
        print(f"  n={n_dim:.0f}, q={q:.0f}, alpha={alpha}: "
              f"gamma = n/alpha = {gamma:.1f} <= q*sqrt(n)/2 = {bound:.1f}  OK")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("GAUSSIAN-INTEGER BRIDGE FOR RING-LWE — NUMERICAL DEMONSTRATIONS")
    print()
    demo_norm_multiplicativity()
    demo_prime_dichotomy()
    demo_decoding()
    demo_encryption()
    demo_reduction()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
