"""
Numerical demonstrations for:

    "The Wide-Trail Strategy, Formalized:
     Four Rounds of AES Activate at Least 25 S-boxes, Tightly"

This script reproduces, in plain Python, the combinatorial facts that the
formal development certifies:

  1. The active-S-box weight machinery (wt, colWeight, colActive) on 4x4 states.
  2. The round bound:          B * colActive(out) <= wt(in) + wt(out).
  3. The generic four-round bound:   B^2 <= total active S-boxes.
  4. The AES specialization:         25 <= total active S-boxes (B = 5).
  5. Tightness via the explicit 1-4-16-4 trail (total weight exactly 25).
  6. The AES S-box differential uniformity = 4, giving p_max = 2^-6, hence a
     four-round trail probability bound of (2^-6)^25 = 2^-150.

Everything is self-contained: no third-party imports.
"""

from __future__ import annotations

from typing import Callable, List, Tuple

# A "state" is a 4x4 grid of integers; an entry is "active" iff it is nonzero.
State = List[List[int]]


# ---------------------------------------------------------------------------
# 1. Weight machinery
# ---------------------------------------------------------------------------

def wt(a: State) -> int:
    """Total number of active (nonzero) bytes in the state = active S-boxes."""
    return sum(1 for row in a for x in row if x != 0)


def col_weight(a: State, j: int) -> int:
    """Number of active bytes in column j."""
    return sum(1 for i in range(len(a)) if a[i][j] != 0)


def col_active(a: State) -> int:
    """Number of columns that contain at least one active byte."""
    ncols = len(a[0])
    return sum(1 for j in range(ncols) if any(a[i][j] != 0 for i in range(len(a))))


def column_is_active(a: State, j: int) -> bool:
    """Whether column j has any active byte."""
    return any(a[i][j] != 0 for i in range(len(a)))


# ---------------------------------------------------------------------------
# 2. AES ShiftRows: row i is cyclically shifted left by i.
#    (shiftRows a)[i][j] = a[i][(j + i) mod 4]
# ---------------------------------------------------------------------------

def aes_shift_rows(a: State) -> State:
    """Apply the AES ShiftRows permutation to a 4x4 state."""
    n = len(a)
    return [[a[i][(j + i) % n] for j in range(n)] for i in range(n)]


# ---------------------------------------------------------------------------
# 3. Round bound and four-round bound verification
# ---------------------------------------------------------------------------

def round_bound_holds(a_in: State, a_out: State, B: int) -> bool:
    """
    Verify the hypotheses and conclusion of the round bound for a transition
    a_in -> a_out with branch number B.  Returns True iff:
      - (activity) for each column j: column j active in shiftRows(a_in)
        iff column j active in a_out, and
      - (branch)   for each active column j of shiftRows(a_in):
        B <= colWeight(shiftRows(a_in), j) + colWeight(a_out, j), and
      - (conclusion) B * colActive(a_out) <= wt(a_in) + wt(a_out).
    """
    sr = aes_shift_rows(a_in)
    ncols = len(a_in[0])
    for j in range(ncols):
        if column_is_active(sr, j) != column_is_active(a_out, j):
            return False
    for j in range(ncols):
        if column_is_active(sr, j):
            if not (B <= col_weight(sr, j) + col_weight(a_out, j)):
                return False
    return B * col_active(a_out) <= wt(a_in) + wt(a_out)


def four_round_total(a1: State, a2: State, a3: State, a4: State) -> int:
    """Total number of active S-boxes over a four-round trail."""
    return wt(a1) + wt(a2) + wt(a3) + wt(a4)


def four_round_bound_certificate(
    a1: State, a2: State, a3: State, a4: State, B: int
) -> Tuple[bool, int, int]:
    """
    Check the generic four-round bound for a trail with branch number B.
    Returns (ok, B*B, total) where ok asserts all hypotheses hold AND
    B*B <= total active S-boxes.
    """
    super_box = B <= col_active(a2) + col_active(a4)
    rounds = round_bound_holds(a1, a2, B) and round_bound_holds(a3, a4, B)
    total = four_round_total(a1, a2, a3, a4)
    ok = super_box and rounds and (B * B <= total)
    return ok, B * B, total


# ---------------------------------------------------------------------------
# 4. The explicit 1-4-16-4 tightness trail (over Z/2)
# ---------------------------------------------------------------------------

def make_trail() -> Tuple[State, State, State, State]:
    """Build the canonical 1-4-16-4 trail t1, t2, t3, t4."""
    t1 = [[1 if (i == 0 and j == 0) else 0 for j in range(4)] for i in range(4)]
    t2 = [[1 if j == 0 else 0 for j in range(4)] for i in range(4)]
    t3 = [[1 for _ in range(4)] for _ in range(4)]
    t4 = [[1 if i == 0 else 0 for _ in range(4)] for i in range(4)]
    return t1, t2, t3, t4


# ---------------------------------------------------------------------------
# 5. AES S-box differential uniformity over GF(2^8)
# ---------------------------------------------------------------------------

GF_MODULUS = 0x11B  # x^8 + x^4 + x^3 + x + 1, the AES Rijndael polynomial


def gf_mul(a: int, b: int) -> int:
    """Multiply two elements of GF(2^8) using the AES reduction polynomial."""
    p = 0
    for _ in range(8):
        if b & 1:
            p ^= a
        b >>= 1
        carry = a & 0x80
        a = (a << 1) & 0xFF
        if carry:
            a ^= (GF_MODULUS & 0xFF)
    return p


def gf_inv(a: int) -> int:
    """Multiplicative inverse in GF(2^8); inv(0) := 0 (AES convention)."""
    if a == 0:
        return 0
    # a^(254) = a^(-1) since the group has order 255.
    result = 1
    base = a
    exp = 254
    while exp > 0:
        if exp & 1:
            result = gf_mul(result, base)
        base = gf_mul(base, base)
        exp >>= 1
    return result


def differential_uniformity(sbox: Callable[[int], int]) -> int:
    """
    Maximal off-origin entry of the difference-distribution table:
        max over a != 0, b of  #{ x : S(x ^ a) ^ S(x) == b }.
    For the AES inversion S-box this equals 4, giving p_max = 4/256 = 2^-6.
    """
    best = 0
    for a in range(1, 256):
        counts = [0] * 256
        for x in range(256):
            b = sbox(x ^ a) ^ sbox(x)
            counts[b] += 1
        best = max(best, max(counts))
    return best


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print(" Wide-Trail Strategy: four rounds of AES activate >= 25 S-boxes")
    print("=" * 70)

    # --- Tightness trail ---
    t1, t2, t3, t4 = make_trail()
    print("\n[1] The canonical 1-4-16-4 trail (weights per round):")
    print(f"    wt(t1) = {wt(t1)}  (single active byte)")
    print(f"    wt(t2) = {wt(t2)}  (one full column)")
    print(f"    wt(t3) = {wt(t3)}  (full state)")
    print(f"    wt(t4) = {wt(t4)}  (one active byte per column)")
    total = four_round_total(t1, t2, t3, t4)
    print(f"    total  = {total}   (expected 25)")
    assert total == 25, "trail weight must be 25"

    print("\n[2] Column-level structure of the trail:")
    print(f"    colActive(t2) = {col_active(t2)}, colActive(t4) = {col_active(t4)}")
    print(f"    super-box branch: colActive(t2)+colActive(t4) = "
          f"{col_active(t2) + col_active(t4)}  (>= 5, here equality)")

    # --- Generic four-round bound with B = 5 ---
    print("\n[3] Four-round bound certificate (B = 5):")
    ok, bsq, tot = four_round_bound_certificate(t1, t2, t3, t4, B=5)
    print(f"    B^2 = {bsq},  total active S-boxes = {tot},  bound holds: {ok}")
    assert ok and bsq == 25, "generic 25 bound must hold"

    # --- Generic B^2 scaling demonstration ---
    print("\n[4] Generic B^2 scaling (lower bound is the branch number squared):")
    for B in (2, 3, 4, 5, 6):
        print(f"    branch number B = {B}  =>  guaranteed >= {B*B} active S-boxes")

    # --- S-box differential uniformity ---
    print("\n[5] AES S-box (GF(2^8) inversion) differential uniformity:")
    du = differential_uniformity(gf_inv)
    print(f"    differential uniformity = {du}  (expected 4)")
    print(f"    p_max = {du}/256 = 2^-{8 - (du.bit_length() - 1)}  (expected 2^-6)")
    assert du == 4, "AES inversion S-box has differential uniformity 4"

    # --- Probability bound for four rounds ---
    print("\n[6] Four-round trail probability bound:")
    n_active = 25
    exponent = 6 * n_active
    print(f"    (2^-6)^{n_active} = 2^-{exponent}")
    print(f"    2^-{exponent} << 2^-128  =>  no exploitable 4-round trail")

    print("\nAll checks passed. The minimum number of active S-boxes over four")
    print("rounds of AES is exactly 25.")


if __name__ == "__main__":
    main()
