#!/usr/bin/env python3
"""
Gradual, Not a Cliff — numerical demonstrations.
================================================

Self-contained numerical companion to the study of the capped trailing-zero dial

        T_u(x) = min(v2(x), u)          on the key space {0, 1, ..., 2^b - 1},

where v2(x) is the number of trailing zero bits of x.

Everything below is computed in EXACT rational arithmetic (fractions.Fraction) so
that the claimed inequalities are demonstrated, not approximated.

The demonstrations, in order:

  1. The tie profile of T_u and its exact Spearman tie ceiling, verified against
     the closed product law   rho^2(b,u) = (6/7)(1 - 8^-u) (1 + 1/(4^b - 1)).
  2. Rank-one structure: every 2x2 minor of the ceiling grid vanishes exactly.
  3. Exact cap notch  (3/4) * 8^-u * bit(b) > 0 : the ceiling RISES with the cap.
  4. Flatness on the recorded envelope: any two ceilings differ by < 1e-5.
  5. Attenuation: the drop between the recorded corners exceeds 2/5.
  6. The staircase decomposition and the spreading law on the recorded 4x3 grid,
     contrasted with a genuine cliff grid and with the perfectly gradual grid.
  7. Convention stability: exact one-key move response, the balanced bound 4/N,
     and the envelope bound 1e-9.
  8. The transition-width law and geometric descent at a practical floor.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

Grid = Callable[[int, int], Fraction]

# ----------------------------------------------------------------------------
# Recorded summary of the sweep (the ONLY empirical inputs used anywhere).
# ----------------------------------------------------------------------------

REC_TOP = Fraction(79, 100)    # best recorded correlation
REC_BOT = Fraction(53, 100)    # worst recorded correlation
REC_RANGE = REC_TOP - REC_BOT  # = 26/100
REC_NOTCH = Fraction(9, 100)   # reported per-notch bound
ENV_B_MIN = 32                 # recorded envelope: bit lengths
ENV_U_MIN = 8                  # recorded envelope: caps


# ----------------------------------------------------------------------------
# 1. Tie profiles and the exact tie ceiling
# ----------------------------------------------------------------------------

def cap_blocks(u: int, b: int) -> List[int]:
    """Tie profile of T_u on b-bit keys: block sizes, summing to 2**b.

    Keys with exactly j trailing zeros number 2**(b-1-j) for j < u; keys with at
    least u trailing zeros number 2**(b-u).
    """
    if not (1 <= u <= b):
        raise ValueError("require 1 <= u <= b")
    return [2 ** (b - 1 - j) for j in range(u)] + [2 ** (b - u)]


def tie_correction(profile: Sequence[int]) -> Fraction:
    """Spearman tie correction  tc(L) = sum_i (m_i^3 - m_i) / 12."""
    return Fraction(sum(m ** 3 - m for m in profile), 12)


def spearman_sq(profile: Sequence[int]) -> Fraction:
    """Tie ceiling  rho^2(L) = 1 - 12 tc(L) / (N^3 - N),  N = sum of blocks."""
    n = sum(profile)
    if n < 2:
        raise ValueError("need at least two items")
    return 1 - Fraction(12 * tie_correction(profile), n ** 3 - n)


def cap_factor(u: int) -> Fraction:
    """cap(u) = (6/7)(1 - 8^-u); increases to 6/7."""
    return Fraction(6, 7) * (1 - Fraction(1, 8 ** u))


def bit_factor(b: int) -> Fraction:
    """bit(b) = 1 + 1/(4^b - 1); decreases to 1."""
    return 1 + Fraction(1, 4 ** b - 1)


def ceiling_grid(b: int, u: int) -> Fraction:
    """Closed-form ceiling  C(b,u) = cap(u) * bit(b)."""
    return cap_factor(u) * bit_factor(b)


def demo_product_law() -> None:
    print("=" * 78)
    print("1. THE PRODUCT LAW FOR THE TIE CEILING")
    print("=" * 78)
    print("   rho^2(b,u) = (6/7)(1 - 8^-u) * (1 + 1/(4^b - 1))\n")
    print(f"   {'b':>4} {'u':>4}  {'blocks':>26}  {'direct':>18}  {'closed form':>18}  ok")
    for b, u in [(4, 1), (8, 3), (12, 8), (16, 5), (20, 12), (24, 24)]:
        prof = cap_blocks(u, b)
        direct = spearman_sq(prof)
        closed = ceiling_grid(b, u)
        shown = str(prof if len(prof) <= 5 else prof[:3] + ["..."] + prof[-1:])
        print(f"   {b:>4} {u:>4}  {shown[:26]:>26}  {float(direct):>18.12f}"
              f"  {float(closed):>18.12f}  {direct == closed}")
    print("\n   Exact agreement in every case: the ceiling is a product of a cap")
    print("   factor and a bit factor, with no interaction term.\n")


# ----------------------------------------------------------------------------
# 2. Rank one: vanishing 2x2 minors
# ----------------------------------------------------------------------------

def demo_rank_one() -> None:
    print("=" * 78)
    print("2. RANK ONE: EVERY 2x2 MINOR OF THE CEILING GRID VANISHES")
    print("=" * 78)
    print("   C(b,u) C(b',u') - C(b,u') C(b',u) = 0  for all b,b',u,u'\n")
    worst = Fraction(0)
    for b in range(1, 12):
        for bb in range(1, 12):
            for u in range(1, 12):
                for uu in range(1, 12):
                    minor = (ceiling_grid(b, u) * ceiling_grid(bb, uu)
                             - ceiling_grid(b, uu) * ceiling_grid(bb, u))
                    worst = max(worst, abs(minor))
    print(f"   Largest |2x2 minor| over 11^4 = {11 ** 4} quadruples : {worst}")
    print("   Exactly zero. No cell can deviate from its row and column, so a")
    print("   threshold localised at one (b,u) is arithmetically impossible.\n")


# ----------------------------------------------------------------------------
# 3-4. Notches, direction, and flatness
# ----------------------------------------------------------------------------

def row_step(f: Grid, b: int, u: int) -> Fraction:
    """Decline of the grid when the bit-length dial advances one notch."""
    return f(b, u) - f(b + 1, u)


def col_step(f: Grid, b: int, u: int) -> Fraction:
    """Decline of the grid when the cap dial advances one notch."""
    return f(b, u) - f(b, u + 1)


def demo_notches_and_flatness() -> None:
    print("=" * 78)
    print("3. EXACT NOTCHES OF THE CEILING, AND THEIR DIRECTION")
    print("=" * 78)
    print("   cap notch:  rho^2(b,u+1) - rho^2(b,u) = (3/4) 8^-u bit(b)  > 0\n")
    b = 32
    print(f"   {'u':>4}  {'exact cap gain':>26}  {'= (3/4)8^-u bit(b)':>22}  {'<= 8^-u':>9}")
    for u in [1, 2, 4, 8, 12]:
        gain = ceiling_grid(b, u + 1) - ceiling_grid(b, u)
        predicted = Fraction(3, 4) * Fraction(1, 8 ** u) * bit_factor(b)
        print(f"   {u:>4}  {float(gain):>26.18f}  {gain == predicted!s:>22}"
              f"  {abs(gain) <= Fraction(1, 8 ** u)!s:>9}")
    print("\n   The ceiling RISES with the cap while the recorded correlation FALLS:")
    print("   along the cap dial the observed decline has the wrong sign to be a")
    print("   ceiling effect at all.\n")

    print(f"   bit notch:  |rho^2(b,u) - rho^2(b+1,u)| <= 2 * 4^-b\n")
    u = 8
    print(f"   {'b':>4}  {'|bit notch|':>26}  {'<= 2*4^-b':>10}")
    for bb in [8, 16, 32, 48]:
        step = abs(row_step(ceiling_grid, bb, u))
        print(f"   {bb:>4}  {float(step):>26.3e}  {step <= 2 * Fraction(1, 4 ** bb)!s:>10}")

    print()
    print("=" * 78)
    print("4. FLATNESS ON THE RECORDED ENVELOPE  (b >= 32, u >= 8)")
    print("=" * 78)
    cells = [(b, u) for b in (32, 40, 54, 64) for u in (8, 10, 12)]
    values = [ceiling_grid(b, u) for b, u in cells]
    lo, hi = min(values), max(values)
    six_sevenths = Fraction(6, 7)
    print(f"   6/7                      = {float(six_sevenths):.15f}")
    print(f"   min ceiling on envelope  = {float(lo):.15f}   at {cells[values.index(lo)]}")
    print(f"   max ceiling on envelope  = {float(hi):.15f}   at {cells[values.index(hi)]}")
    print(f"   total spread             = {float(hi - lo):.3e}")
    print(f"   spread < 1e-5            : {hi - lo < Fraction(1, 10 ** 5)}")
    print(f"   recorded decline         = {float(REC_RANGE)}"
          f"   (larger by a factor {float(REC_RANGE / (hi - lo)):.3e})")
    print("\n   The instrument's capacity is the constant 6/7 to five decimals across")
    print("   the whole experiment. None of the recorded decline is a ceiling effect.\n")


# ----------------------------------------------------------------------------
# 5. Attenuation
# ----------------------------------------------------------------------------

def attenuation(s: Fraction, b: int, u: int) -> Fraction:
    """Attenuation factor a with s^2 = a * rho^2(b,u)."""
    return s ** 2 / ceiling_grid(b, u)


def demo_attenuation() -> None:
    print("=" * 78)
    print("5. THE DECLINE IS ATTENUATION, AND IT EXCEEDS 2/5")
    print("=" * 78)
    top_cell, bot_cell = (32, 8), (64, 12)
    a_top = attenuation(REC_TOP, *top_cell)
    a_bot = attenuation(REC_BOT, *bot_cell)
    print(f"   top corner   s = {float(REC_TOP):.2f} at (b,u) = {top_cell}")
    print(f"                ceiling      = {float(ceiling_grid(*top_cell)):.12f}")
    print(f"                attenuation  = {float(a_top):.12f}")
    print(f"   bottom corner s = {float(REC_BOT):.2f} at (b,u) = {bot_cell}")
    print(f"                ceiling      = {float(ceiling_grid(*bot_cell)):.12f}")
    print(f"                attenuation  = {float(a_bot):.12f}")
    print(f"\n   ceiling change    = {float(ceiling_grid(*bot_cell) - ceiling_grid(*top_cell)):+.3e}"
          "   (and it RISES)")
    print(f"   attenuation drop  = {float(a_top - a_bot):.12f}")
    print(f"   drop > 2/5        : {a_top - a_bot > Fraction(2, 5)}")
    print("\n   Capacity constant to 1e-5; the share of capacity used falls from")
    print("   about 73% to about 33%. The effect lives entirely in the coupling.\n")


# ----------------------------------------------------------------------------
# 6. Staircase, spreading law, cliffs
# ----------------------------------------------------------------------------

def stair_steps(f: Grid, b0: int, u0: int, m: int, n: int) -> List[Fraction]:
    """The m + n single-notch declines along the monotone staircase from
    (b0,u0) to (b0+m, u0+n): m row notches, then n column notches."""
    return ([row_step(f, b0 + i, u0) for i in range(m)]
            + [col_step(f, b0 + m, u0 + j) for j in range(n)])


def spreading_certificate(total: Fraction, eps: Fraction) -> int:
    """Lower bound on the number of active notches forced by the spreading law."""
    q = total / eps
    return -((-q.numerator) // q.denominator)  # ceiling of a positive Fraction


def linear_grid(top: Fraction, delta: Fraction) -> Grid:
    """The perfectly gradual grid: loses exactly delta at every notch."""
    return lambda b, u: top - (b + u) * delta


def cliff_grid(b: int, u: int) -> Fraction:
    """A genuine cliff: 0.79 at the origin, 0.53 everywhere else."""
    return REC_TOP if b + u == 0 else REC_BOT


def audit(name: str, f: Grid) -> None:
    steps = stair_steps(f, 0, 0, 3, 2)
    total = sum(steps, Fraction(0))
    corner = f(0, 0) - f(3, 2)
    biggest = max(steps)
    active = sum(1 for x in steps if x > 0)
    print(f"   {name}")
    print(f"      notches        : {[str(x) for x in steps]}")
    print(f"      sum of notches : {total}    corner difference: {corner}"
          f"    identity holds: {total == corner}")
    print(f"      largest notch  : {biggest}   respects bound {REC_NOTCH}: "
          f"{biggest <= REC_NOTCH}")
    print(f"      active notches : {active}")
    if biggest <= REC_NOTCH:
        cert = spreading_certificate(total, REC_NOTCH)
        print(f"      spreading law forces >= {cert} active notches"
              f"   (satisfied: {active >= cert})")
        print(f"      no notch reaches the total {total}: {biggest < total}")
    else:
        print(f"      per-notch bound VIOLATED -> this grid has a cliff:"
              f" one notch of {biggest} carries the whole {total}")
    print()


def demo_staircase() -> None:
    print("=" * 78)
    print("6. THE STAIRCASE DECOMPOSITION AND THE SPREADING LAW")
    print("=" * 78)
    print("   Staircase from (0,0) to (3,2): 3 bit-length notches then 2 cap notches.")
    print("   Sum of notches = corner difference (exactly, for ANY grid).\n")

    audit("(a) perfectly gradual grid, notch 0.052", linear_grid(REC_TOP, Fraction(26, 500)))
    audit("(b) a plausible uneven recorded grid", _uneven_grid())
    audit("(c) a genuine CLIFF grid", cliff_grid)

    print("   Reading: (a) and (b) both hit the recorded corners, respect the")
    print("   reported per-notch bound 0.09, and are therefore certified to spread")
    print("   the 0.26 decline over at least 3 of the 5 notches. (c) hits the same")
    print("   corners but violates exactly the per-notch bound -- which is what makes")
    print("   the gradualness verdict a real constraint rather than a formality.\n")


def _uneven_grid() -> Grid:
    """A monotone grid with the recorded corners and uneven but bounded notches."""
    notches = [Fraction(9, 100), Fraction(7, 100), Fraction(4, 100),
               Fraction(3, 100), Fraction(3, 100)]
    # cumulative decline along the staircase (3 row notches, then 2 col notches)
    def f(b: int, u: int) -> Fraction:
        loss = Fraction(0)
        for i in range(min(b, 3)):
            loss += notches[i]
        for j in range(min(u, 2)):
            loss += notches[3 + j]
        return REC_TOP - loss
    return f


# ----------------------------------------------------------------------------
# 7. Convention stability
# ----------------------------------------------------------------------------

def one_key_move(profile: Sequence[int], i: int, j: int) -> List[int]:
    """Move one key out of block i and into block j (a convention change)."""
    out = list(profile)
    if out[i] == 0:
        raise ValueError("source block is empty")
    out[i] -= 1
    out[j] += 1
    return out


def exact_move_response(m: int, m_prime: int) -> Fraction:
    """Exact change of 12*tc when one key leaves a block of size m+1 and joins a
    block of size m': 3(m'^2 + m') - 3(m^2 + m)."""
    return Fraction(3 * (m_prime ** 2 + m_prime) - 3 * (m ** 2 + m))


def demo_convention() -> None:
    print("=" * 78)
    print("7. CONVENTION STABILITY: MOVING ONE BOUNDARY KEY")
    print("=" * 78)
    print("   Exact change of 12*tc for a one-key move: 3(m'^2 + m') - 3(m^2 + m)\n")
    for b, u in [(8, 3), (12, 4), (20, 8)]:
        prof = cap_blocks(u, b)
        n = sum(prof)
        i, j = 0, len(prof) - 1                # move a key from the largest block
        moved = one_key_move(prof, i, j)
        m, m_prime = prof[i] - 1, prof[j]
        predicted = exact_move_response(m, m_prime)
        actual = 12 * tie_correction(moved) - 12 * tie_correction(prof)
        shift = abs(spearman_sq(prof) - spearman_sq(moved))
        bound = Fraction(4, n)
        print(f"   b={b:>3} u={u:>2}  N = 2^{b} = {n}")
        print(f"      predicted 12*tc change = {predicted}   actual = {actual}"
              f"   match: {predicted == actual}")
        print(f"      exact ceiling shift    = {float(shift):.6e}")
        print(f"      balanced bound 4/N     = {float(bound):.6e}"
              f"   holds: {shift < bound}")
    print()
    print("   On the recorded envelope (b >= 32, N >= 2^32):")
    n32 = 2 ** ENV_B_MIN
    print(f"      4/N = 4/2^32 = {float(Fraction(4, n32)):.6e}"
          f"   < 1e-9 : {Fraction(4, n32) < Fraction(1, 10 ** 9)}")
    print(f"      recorded decline 0.26 is larger by a factor"
          f" {float(REC_RANGE / Fraction(4, n32)):.3e}")
    print("\n   A convention about a single boundary key is inaudible: it would take")
    print("   on the order of 1e8 reassignments to move the ceiling at the recorded")
    print("   scale.\n")


# ----------------------------------------------------------------------------
# 8. The practical floor has positive width
# ----------------------------------------------------------------------------

def transition_notches_required(eta: Fraction, d: Fraction) -> int:
    """Transition-width law: crossing a band of half-width eta with per-notch
    bound d requires at least ceil(2 eta / d) notches."""
    return spreading_certificate(2 * eta, d)


def geometric_trace(start: Fraction, r: Fraction, steps: int) -> List[Fraction]:
    """Worst-case trace under a per-notch retention of at least r."""
    out = [start]
    for _ in range(steps):
        out.append(out[-1] * r)
    return out


def demo_floor() -> None:
    print("=" * 78)
    print("8. THE PRACTICAL FLOOR IS A TRANSITION OF POSITIVE WIDTH")
    print("=" * 78)
    eta, d = Fraction(5, 100), REC_NOTCH
    req = transition_notches_required(eta, d)
    print(f"   Transition-width law: 2*eta <= m*d, so m >= 2*eta/d.")
    print(f"      band half-width eta = {eta}, per-notch bound d = {d}")
    print(f"      2*eta/d = {float(2 * eta / d):.6f}  ->  at least {req} notches to cross\n")

    r = Fraction(7, 8)
    trace = geometric_trace(REC_TOP, r, 4)
    print(f"   Geometric descent with retention r = {r} from the recorded top {REC_TOP}:")
    for k, v in enumerate(trace):
        marker = "  <-- still above the recorded bottom 0.53" if v > REC_BOT else ""
        print(f"      after {k} notches: {float(v):.6f}{marker}")
    print(f"\n      (7/8)^2 * 0.79 = {float(r ** 2 * REC_TOP):.6f} > 0.53 :"
          f" {r ** 2 * REC_TOP > REC_BOT}")
    print("      -> the dial CANNOT fall from 0.79 to 0.53 in two notches.")
    print("\n   Crossing has no jump: if s(k) >= tau then s(k+1) >= r*tau, and the")
    print("   crossing notch moves the dial by at most (1-r)*s(k) ="
          f" {float(1 - r):.3f} of its value.\n")


# ----------------------------------------------------------------------------

def main() -> None:
    print()
    print("#" * 78)
    print("#  GRADUAL, NOT A CLIFF — exact numerics for the capped trailing-zero dial")
    print("#" * 78)
    print()
    demo_product_law()
    demo_rank_one()
    demo_notches_and_flatness()
    demo_attenuation()
    demo_staircase()
    demo_convention()
    demo_floor()
    print("=" * 78)
    print("SUMMARY")
    print("=" * 78)
    print("   * capacity  rho^2(b,u) = (6/7)(1-8^-u)(1+1/(4^b-1))  — exact, rank one")
    print("   * capacity varies by < 1e-5 on the recorded envelope, and RISES with u")
    print("   * therefore attenuation must drop by > 2/5 between the recorded corners")
    print("   * a one-key convention change moves the capacity by < 1e-9")
    print("   * the 0.26 decline is spread over >= 3 of 5 notches; no notch reaches it")
    print("   * the reported practical floor is >= 2 notches wide — there is no edge")
    print()


if __name__ == "__main__":
    main()
