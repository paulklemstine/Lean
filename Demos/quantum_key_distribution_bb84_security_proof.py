"""
BB84 Security: numerical demonstrations of the formally verified results.

This script is fully self-contained (standard library only) and exercises the
MAIN theorems of the accompanying paper:

  * interceptResendQBER_eq          -- intercept-resend QBER = 1/4
  * secureKeyRate_pos_iff / _strictAntiOn / exists_threshold / threshold_unique
                                     -- the ~11% one-way QBER threshold
  * secureKeyRate_one_quarter_neg   -- the 25% attack is detectable
  * binEntropy_one_eighth_gt / _one_sixteenth_lt
                                     -- integer-certified threshold brackets
  * statDist_le_collision / privacyAmplification_exp_bound
                                     -- leftover-hash / privacy amplification
  * two_universal / two_universal_k -- optimal two-universality of random parity

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------
# 1. Binary entropy and the secret-key rate
# --------------------------------------------------------------------------

def bin_entropy_nats(q: float) -> float:
    """binEntropy(q) in NATS: -q*ln q - (1-q)*ln(1-q). Matches Mathlib's Real.binEntropy."""
    if q <= 0.0 or q >= 1.0:
        return 0.0
    return -q * math.log(q) - (1.0 - q) * math.log(1.0 - q)


def secure_key_rate(q: float) -> float:
    """secureKeyRate(Q) = log 2 - 2 * binEntropy(Q)  (nats).  = (1 - 2 H2(Q)) * log 2."""
    return math.log(2.0) - 2.0 * bin_entropy_nats(q)


def secure_key_rate_bits(q: float) -> float:
    """Textbook one-way Shor-Preskill rate r(Q) = 1 - 2 H2(Q)  (bits)."""
    return secure_key_rate(q) / math.log(2.0)


# --------------------------------------------------------------------------
# 2. The intercept-resend attack  (Protocol.lean)
# --------------------------------------------------------------------------

def bob_error_prob(alice_basis: bool, eve_basis: bool) -> float:
    """0 if Eve guessed the basis, else 1/2 (random outcome in conjugate basis)."""
    return 0.0 if eve_basis == alice_basis else 0.5


def intercept_resend_qber(alice_basis: bool) -> float:
    """Expected Bob-error over Eve's uniformly random basis on a sifted round."""
    return sum(0.5 * bob_error_prob(alice_basis, e) for e in (False, True))


# --------------------------------------------------------------------------
# 3. Threshold: existence (bisection) + integer-certified brackets
# --------------------------------------------------------------------------

def find_threshold(lo: float = 1.0 / 16, hi: float = 1.0 / 8,
                   iters: int = 200) -> float:
    """Bisect secureKeyRate on (lo, hi) to locate the critical QBER p*."""
    f = secure_key_rate
    assert f(lo) > 0.0 > f(hi), "bracket must contain a sign change"
    for _ in range(iters):
        mid = 0.5 * (lo + hi)
        if f(mid) > 0.0:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def certify_eighth_bracket() -> Tuple[bool, int, int]:
    """binEntropy(1/8) > (log2)/2  <=>  7^7 < 2^20  (pure integer comparison)."""
    return (7 ** 7 < 2 ** 20, 7 ** 7, 2 ** 20)


def certify_sixteenth_bracket() -> Tuple[bool, int, int]:
    """binEntropy(1/16) < (log2)/2  <=>  2^56 < 15^15  (pure integer comparison)."""
    return (2 ** 56 < 15 ** 15, 2 ** 56, 15 ** 15)


# --------------------------------------------------------------------------
# 4. Privacy amplification: leftover-hash bound  (PrivacyAmplification.lean)
# --------------------------------------------------------------------------

def stat_dist_to_uniform(p: List[float]) -> float:
    """LHS of statDist_le_collision: sum_i |p_i - 1/M| (twice total variation)."""
    m = len(p)
    return sum(abs(pi - 1.0 / m) for pi in p)


def collision_bound(p: List[float]) -> float:
    """RHS of statDist_le_collision: sqrt(M * sum p_i^2 - 1)."""
    m = len(p)
    excess = m * sum(pi * pi for pi in p) - 1.0
    return math.sqrt(max(excess, 0.0))


def privacy_amplification_bound(ell: int, k: int) -> float:
    """RHS of privacyAmplification_exp_bound: sqrt(2^(ell-k)) given collision <= 2^-k."""
    return math.sqrt(2.0 ** (ell - k))


# --------------------------------------------------------------------------
# 5. Two-universality of the GF(2) inner-product (random parity) hash
# --------------------------------------------------------------------------

def inner_hash(a: Tuple[int, ...], x: Tuple[int, ...]) -> int:
    """innerHash(a, x) = sum a_i x_i  mod 2."""
    return sum(ai * xi for ai, xi in zip(a, x)) % 2


def count_colliding_seeds(n: int, x: Tuple[int, ...], y: Tuple[int, ...]) -> int:
    """#{a in (Z/2)^n : innerHash(a,x) = innerHash(a,y)} by brute force."""
    return sum(
        1
        for a in itertools.product((0, 1), repeat=n)
        if inner_hash(a, x) == inner_hash(a, y)
    )


def count_colliding_matrices(n: int, k: int,
                             x: Tuple[int, ...], y: Tuple[int, ...]) -> int:
    """#{A : Fin k -> (Z/2)^n | all k rows collide on x,y} by brute force."""
    seeds = list(itertools.product((0, 1), repeat=n))
    colliding_rows = [a for a in seeds if inner_hash(a, x) == inner_hash(a, y)]
    return len(colliding_rows) ** k


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("BB84 SECURITY: NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # ---- 1. Intercept-resend QBER = 1/4 (interceptResendQBER_eq) ----------
    print("\n[1] Intercept-resend attack  (interceptResendQBER_eq)")
    for a in (False, True):
        q = intercept_resend_qber(a)
        print(f"    QBER(basis={a!s:>5}) = {q:.4f}   (expected 0.25)")
    assert abs(intercept_resend_qber(False) - 0.25) < 1e-12
    assert abs(intercept_resend_qber(True) - 0.25) < 1e-12

    # ---- 2. Threshold existence + integer certificates -------------------
    print("\n[2] The ~11% threshold  (exists_threshold, threshold_unique)")
    p_star = find_threshold()
    print(f"    bisected p*           = {p_star:.6f}  ({100*p_star:.3f}%)")
    print(f"    secureKeyRate(p*)     = {secure_key_rate(p_star): .2e}  (~0)")
    print(f"    p* in (1/16, 1/8)?    = {1/16 < p_star < 1/8}")

    ok8, lhs8, rhs8 = certify_eighth_bracket()
    ok16, lhs16, rhs16 = certify_sixteenth_bracket()
    print("    integer certificates of the bracket:")
    print(f"      binEntropy(1/8)  > (log2)/2  <=>  7^7 < 2^20 : "
          f"{lhs8} < {rhs8} = {ok8}")
    print(f"      binEntropy(1/16) < (log2)/2  <=>  2^56 < 15^15 : "
          f"{lhs16} < {rhs16} = {ok16}")
    assert ok8 and ok16

    # ---- 3. 25% attack is detectable (secureKeyRate_one_quarter_neg) -----
    print("\n[3] Detectability  (secureKeyRate_one_quarter_neg / interceptResend_insecure)")
    print(f"    secureKeyRate(1/4)    = {secure_key_rate(0.25): .4f}  (< 0)")
    print(f"    p* < 1/4 ?            = {p_star < 0.25}")
    assert secure_key_rate(0.25) < 0.0

    # monotonicity sanity (secureKeyRate_strictAntiOn)
    grid = [i / 100 for i in range(0, 51)]
    mono = all(secure_key_rate(grid[i]) > secure_key_rate(grid[i + 1])
               for i in range(len(grid) - 1))
    print(f"    strictly decreasing on [0,1/2]? = {mono}")
    assert mono

    # ---- 4. Privacy amplification (statDist_le_collision, exp bound) -----
    print("\n[4] Privacy amplification  (statDist_le_collision, privacyAmplification_exp_bound)")
    examples: List[Tuple[str, List[float]]] = [
        ("near-uniform (M=4)", [0.30, 0.25, 0.25, 0.20]),
        ("spiked      (M=4)", [0.70, 0.10, 0.10, 0.10]),
        ("point mass  (M=4)", [1.0, 0.0, 0.0, 0.0]),
    ]
    for name, p in examples:
        lhs = stat_dist_to_uniform(p)
        rhs = collision_bound(p)
        print(f"    {name:>20}: ||p-U||_1 = {lhs:.4f} <= sqrt(...) = {rhs:.4f}  "
              f"[{lhs <= rhs + 1e-12}]")
        assert lhs <= rhs + 1e-9

    print("    exponential leakage decay (output ell=8 bits, min-entropy k):")
    for k in range(8, 40, 4):
        print(f"      ell=8, k={k:>2}: distance <= sqrt(2^(ell-k)) = "
              f"{privacy_amplification_bound(8, k):.3e}")

    # ---- 5. Two-universality (two_universal, two_universal_k) ------------
    print("\n[5] Optimal two-universality  (two_universal, two_universal_k)")
    for n in range(1, 6):
        x = tuple([0] * n)
        y = tuple([1] + [0] * (n - 1))  # differs from x at coordinate 0
        c = count_colliding_seeds(n, x, y)
        print(f"    n={n}: 2 * #collisions = {2*c} ; 2^n = {2**n}  "
              f"[match={2*c == 2**n}]  (collision prob = {c/2**n:.3f})")
        assert 2 * c == 2 ** n

    print("    k-row generalization (collision prob = 2^-k):")
    n = 4
    x = tuple([0] * n)
    y = tuple([1] + [0] * (n - 1))
    for k in range(1, 5):
        c = count_colliding_matrices(n, k, x, y)
        print(f"      n={n}, k={k}: 2^k * #collisions = {2**k * c} ; "
              f"(2^n)^k = {(2**n)**k}  [match={2**k * c == (2**n)**k}]")
        assert 2 ** k * c == (2 ** n) ** k

    print("\n" + "=" * 70)
    print("All assertions passed: numerics agree with the verified theorems.")
    print("=" * 70)


if __name__ == "__main__":
    main()
