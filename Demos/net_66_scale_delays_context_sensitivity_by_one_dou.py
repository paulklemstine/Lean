"""
The one-octave exchange law for knee tables — numerical demonstrations.

Self-contained, dependency-free Python (standard library only).

Contents
--------
1.  Knees, chains and the octave shift.
2.  Rigidity: two local laws reconstruct the whole scale x context table.
3.  The two structural impossibilities (no amplification, no flattening).
4.  The budget table: reach, staircase, triangular area.
5.  The exchange-rate spectrum and identification of the rate from one cell.
6.  Stability: epsilon-approximate tables and noise-robust rate estimation.
7.  The grid razor: the exact bracket (16, 20] and the one-standard-error reopening.
8.  Realisation of the measured row by an explicit workload of 10,000 windows.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, Dict, List, Optional, Sequence, Tuple

# ---------------------------------------------------------------------------
# 0. Measured data
# ---------------------------------------------------------------------------

GATE: Fraction = Fraction(98, 100)                      # quality gate 0.98
GRID: Tuple[int, ...] = (8, 12, 16, 20, 24, 32)         # budget sweep grid
MEASURED_ROW: Dict[int, Fraction] = {                   # large model, ctx = 2048
    8: Fraction(9597, 10000),
    12: Fraction(9715, 10000),
    16: Fraction(9785, 10000),
    20: Fraction(9817, 10000),
    24: Fraction(9846, 10000),
    32: Fraction(9867, 10000),
}
SMALL_CHAIN: Tuple[int, ...] = (16, 20, 24)             # 0.5B: octaves 0,1,2
LARGE_CHAIN: Tuple[int, ...] = (16, 16, 20)             # 1.5B: octaves 0,1,2
K0: int = 16                                            # base knee
DELTA: int = 4                                          # keys per context doubling


def ctx_of_octave(j: int) -> int:
    """Context length of octave j:  512 * 2^j."""
    return 512 * (2 ** j)


# ---------------------------------------------------------------------------
# 1. Knees, chains, and the octave shift
# ---------------------------------------------------------------------------

def knee(curve: Callable[[int], Fraction], gate: Fraction, kmax: int = 4096) -> Optional[int]:
    """Least budget k with curve(k) >= gate (None if the gate is never met below kmax)."""
    for k in range(kmax + 1):
        if curve(k) >= gate:
            return k
    return None


def trunc_sub(a: int, b: int) -> int:
    """Truncated subtraction (a - b)^+."""
    return a - b if a > b else 0


def shift(chain: Callable[[int], int], s: int) -> Callable[[int], int]:
    """The octave shift: (sigma^s K)(j) = K((j - s)^+)."""
    return lambda j: chain(trunc_sub(j, s))


def base_chain(j: int) -> int:
    """The measured small-model chain K0(j) = 16 + 4j  ->  16, 20, 24, 28, ..."""
    return K0 + DELTA * j


def table(chain: Callable[[int], int], rate: int = 1) -> Callable[[int, int], int]:
    """The rate-p completion F(s, j) = K((j - p*s)^+)."""
    return lambda s, j: chain(trunc_sub(j, rate * s))


# ---------------------------------------------------------------------------
# 2. Rigidity
# ---------------------------------------------------------------------------

def reconstruct_from_local_laws(base: Sequence[int], scales: int) -> List[List[int]]:
    """
    Rebuild the whole table using ONLY the two local laws
        exchange:  F(s+1, j+1) = F(s, j)
        boundary:  F(s+1, 0)   = F(s, 0)
    starting from the measured base row.  Rigidity says the result equals
    F(s, j) = base[(j - s)^+].
    """
    rows: List[List[int]] = [list(base)]
    for _ in range(scales):
        prev = rows[-1]
        row = [prev[0]] + [prev[j] for j in range(len(prev) - 1)]
        rows.append(row)
    return rows


# ---------------------------------------------------------------------------
# 4. Budget table
# ---------------------------------------------------------------------------

def first_fail(chain: Callable[[int], int], budget: int, jmax: int = 64) -> Optional[int]:
    """The first octave whose knee exceeds the budget."""
    for j in range(jmax + 1):
        if chain(j) > budget:
            return j
    return None


def served_cells(F: Callable[[int, int], int], budget: int, S: int, J: int) -> List[Tuple[int, int]]:
    """The cells (s, j) of the S x J corner served by the budget."""
    return [(s, j) for s, j in product(range(S), range(J)) if F(s, j) <= budget]


# ---------------------------------------------------------------------------
# 6. Stability
# ---------------------------------------------------------------------------

def approx_shift_error(F: Callable[[int, int], int], base: Callable[[int], int],
                       S: int, J: int) -> List[int]:
    """max_j |F(s, j) - base((j - s)^+)| for each scale s < S."""
    return [max(abs(F(s, j) - base(trunc_sub(j, s))) for j in range(J)) for s in range(S)]


def candidate_rates(base: Callable[[int], int], observed: Sequence[int],
                    eps: int, jmax: int = 8) -> List[int]:
    """All shifts a whose predicted chain is within eps of the observed chain."""
    out: List[int] = []
    for a in range(jmax + 1):
        pred = shift(base, a)
        if all(abs(pred(j) - observed[j]) <= eps for j in range(len(observed))):
            out.append(a)
    return out


# ---------------------------------------------------------------------------
# 7. The grid razor
# ---------------------------------------------------------------------------

def meas_num(k: int) -> int:
    """Measured row in units of 1e-4, as a monotone step function of the budget."""
    total = 0
    for threshold, rise in ((8, 9597), (12, 118), (16, 70), (20, 32), (24, 29), (32, 21)):
        if k >= threshold:
            total += rise
    return total


def meas_curve(k: int) -> Fraction:
    return Fraction(meas_num(k), 10000)


def bump(t: int, v: int) -> Callable[[int], int]:
    """max(measured, v * [k >= t]) — a monotone curve lifted from budget t onward."""
    return lambda k: max(meas_num(k), v if k >= t else 0)


def grid_bracket(readings: Dict[int, Fraction], gate: Fraction) -> Tuple[Optional[int], Optional[int]]:
    """Last failing and first passing grid points: the honest output of a sweep."""
    ks = sorted(readings)
    last_fail = None
    for k in ks:
        if readings[k] < gate:
            last_fail = k
    first_pass = next((k for k in ks if readings[k] >= gate), None)
    return last_fail, first_pass


def realised_knees(gate: Fraction) -> List[int]:
    """
    Knees of monotone curves that reproduce the measured row at every grid point,
    realised via bumped curves of height 0.9817 at each candidate location.
    """
    out: List[int] = []
    for t in range(1, 33):
        cand = bump(t, 9817)
        agrees = all(Fraction(cand(k), 10000) == MEASURED_ROW[k] for k in GRID)
        mono = all(cand(k) <= cand(k + 1) for k in range(0, 48))
        if agrees and mono:
            out.append(knee(lambda k, c=cand: Fraction(c(k), 10000), gate))
    return sorted(set(out))


# ---------------------------------------------------------------------------
# 8. Workload realisation
# ---------------------------------------------------------------------------

def demand(i: int) -> int:
    """Key demand of window i in the realising workload of 10,000 windows."""
    for bound, d in ((9597, 8), (9715, 12), (9785, 16), (9817, 20),
                     (9846, 24), (9867, 32)):
        if i < bound:
            return d
    return 40


def workload_agree(k: int, n: int = 10000) -> Fraction:
    """Agreement curve of the realising workload."""
    return Fraction(sum(1 for i in range(n) if demand(i) <= k), n)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def section(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_measurement() -> None:
    section("1. The measurement: two chains, three octaves")
    print(f"{'octave':>7} {'context':>8} {'small':>7} {'large':>7}")
    for j in range(3):
        print(f"{j:>7} {ctx_of_octave(j):>8} {SMALL_CHAIN[j]:>7} {LARGE_CHAIN[j]:>7}")
    ok = all(LARGE_CHAIN[j + 1] == SMALL_CHAIN[j] for j in range(2))
    print(f"\nexchange law  K1(j+1) = K0(j) on measured cells : {ok}")
    print(f"boundary law  K1(0) = K0(0)                     : {LARGE_CHAIN[0] == SMALL_CHAIN[0]}")
    print(f"P1 upward break at ctx 2048 (16 -> 20)          : {LARGE_CHAIN[1] < LARGE_CHAIN[2]}")
    print(f"P3 refuted: large needs fewer keys at 2048      : {LARGE_CHAIN[2] < SMALL_CHAIN[2]}")


def demo_rigidity() -> None:
    section("2. Rigidity: the local laws rebuild the entire table")
    J, S = 6, 4
    rebuilt = reconstruct_from_local_laws([base_chain(j) for j in range(J)], S - 1)
    F = table(base_chain, rate=1)
    print(f"{'scale':>6} " + " ".join(f"{ctx_of_octave(j):>6}" for j in range(J)))
    for s in range(S):
        print(f"{s:>6} " + " ".join(f"{rebuilt[s][j]:>6}" for j in range(J)))
    match = all(rebuilt[s][j] == F(s, j) for s in range(S) for j in range(J))
    print(f"\nlocal-law reconstruction equals K((j - s)^+) everywhere : {match}")
    print("predicted next scale step (s = 2), octaves 0..3        :",
          [F(2, j) for j in range(4)])


def demo_impossibilities() -> None:
    section("3. Two structural impossibilities")
    F = table(base_chain, rate=1)
    S, J = 5, 8
    antitone = all(F(s + 1, j) <= F(s, j) for s in range(S) for j in range(J))
    print(f"antitone in scale, F(s+1, j) <= F(s, j) for all cells : {antitone}")
    print("no flattening: for each scale, an octave exceeding any bound")
    for s in range(3):
        b = 40
        j = next(j for j in range(200) if F(s, j) > b)
        print(f"   scale {s}: F({s}, {j}) = {F(s, j)} > {b}  (context {ctx_of_octave(j)})")


def demo_budget_table() -> None:
    section("4. The budget table: reach, staircase, triangular area")
    F = table(base_chain, rate=1)
    for b in (16, 20, 24):
        reaches = [first_fail(lambda j, s=s: F(s, j), b) for s in range(4)]
        print(f"budget {b:>3} keys : first failing octave by scale = {reaches}"
              f"   (covers up to contexts {[ctx_of_octave(r - 1) for r in reaches]})")
    b, S, J = 16, 5, 12
    f = first_fail(lambda j: F(0, j), b)
    cells = served_cells(F, b, S, J)
    print(f"\nserved staircase for budget {b}, S = {S}, J = {J}")
    print(f"   |served|      = {len(cells)}")
    print(f"   S*f + S(S-1)/2 = {S * f + S * (S - 1) // 2}")
    print(f"   identity 2|served| = 2Sf + S(S-1) : "
          f"{2 * len(cells) == 2 * S * f + S * (S - 1)}")
    for s in range(S):
        row = "".join("#" if (s, j) in cells else "." for j in range(J))
        print(f"   s={s} |{row}|")


def demo_rate_spectrum() -> None:
    section("5. The exchange-rate spectrum: one cell forces rate 1")
    print(f"{'rate p':>7} {'predicted F(1, 2)':>19}  verdict")
    for p in range(1, 5):
        F = table(base_chain, rate=p)
        pred = F(1, 2)
        verdict = "matches measured 20" if pred == 20 else "refuted (measured 20)"
        print(f"{p:>7} {pred:>19}  {verdict}")
    print("\nRate-1 and rate-2 tables differ only from the cell (s=1, j=2) onward:")
    F1, F2 = table(base_chain, 1), table(base_chain, 2)
    for s in range(3):
        print(f"   s={s}: rate1 {[F1(s, j) for j in range(4)]}"
              f"   rate2 {[F2(s, j) for j in range(4)]}")


def demo_stability() -> None:
    section("6. Stability under noise")
    eps = 2
    # A perturbed table: each cell nudged, but the local laws still hold to within eps.
    F = table(base_chain, rate=1)

    def noisy(s: int, j: int) -> int:
        return F(s, j) + (eps if (s + j) % 2 == 0 else 0)

    S, J = 5, 8
    exch = max(abs(noisy(s + 1, j + 1) - noisy(s, j)) for s in range(S) for j in range(J))
    bnd = max(abs(noisy(s + 1, 0) - noisy(s, 0)) for s in range(S))
    errs = approx_shift_error(noisy, lambda j: noisy(0, j), S, J)
    print(f"observed exchange defect      : {exch}")
    print(f"observed boundary defect      : {bnd}")
    print(f"max |F(s,j) - F(0,(j-s)^+)|   : {errs}")
    print(f"bound eps*s with eps = {max(exch, bnd)}        : {[max(exch, bnd) * s for s in range(S)]}")
    print(f"stability bound holds         : "
          f"{all(errs[s] <= max(exch, bnd) * s for s in range(S))}")

    print("\nNoise-robust rate identification (base rises by 4 keys per octave):")
    observed = [shift(base_chain, 1)(j) for j in range(6)]
    for e in (0, 3, 4, 5):
        cands = candidate_rates(base_chain, observed, e)
        tag = "identified" if len(cands) == 1 else "ambiguous"
        print(f"   noise tolerance {e} keys -> admissible shifts {cands}  ({tag})")


def demo_razor() -> None:
    section("7. The grid razor: the bracket (16, 20]")
    print(f"{'k':>4} {'retained':>10}  gate 0.98")
    for k in GRID:
        mark = "pass" if MEASURED_ROW[k] >= GATE else "FAIL"
        print(f"{k:>4} {float(MEASURED_ROW[k]):>10.4f}  {mark}")
    p, q = grid_bracket(MEASURED_ROW, GATE)
    print(f"\nhonest sweep output          : bracket ({p}, {q}]")
    print(f"reported knee (right endpoint): {q}")
    print(f"knee of the step model        : {knee(meas_curve, GATE)}")
    print(f"knees realised by monotone curves matching the row exactly : {realised_knees(GATE)}")
    print(f"   -> exactly the integers of (16, 20]  : {realised_knees(GATE) == [17, 18, 19, 20]}")

    se = Fraction(15, 10000)
    reopened = bump(16, 9800)
    dev = max(abs(Fraction(reopened(k), 10000) - MEASURED_ROW[k]) for k in GRID)
    kn = knee(lambda k: Fraction(reopened(k), 10000), GATE)
    print(f"\none-standard-error perturbation ({float(se):.4f}):")
    print(f"   max grid deviation of the reopening curve : {float(dev):.4f}")
    print(f"   its knee                                  : {kn}")
    print(f"   left endpoint reopened (deviation <= 1 SE): {dev <= se and kn == 16}")


def demo_workload() -> None:
    section("8. The measured row is a genuine demand profile")
    print(f"{'k':>4} {'workload agreement':>20} {'measured':>10}  equal")
    for k in GRID:
        a = workload_agree(k)
        print(f"{k:>4} {float(a):>20.4f} {float(MEASURED_ROW[k]):>10.4f}  {a == MEASURED_ROW[k]}")
    kn = knee(workload_agree, GATE, kmax=64)
    print(f"\nknee of the workload's agreement curve at gate 0.98 : {kn}")


def demo_planning_rule() -> None:
    section("9. The planning rule in closed form:  k*(s, j) = 16 + 4 (j - s)^+")
    print(f"{'scale':>6} " + " ".join(f"{ctx_of_octave(j):>6}" for j in range(5)))
    for s in range(4):
        print(f"{s:>6} " + " ".join(f"{K0 + DELTA * trunc_sub(j, s):>6}" for j in range(5)))
    print("\nCells with equal ctx / 2^s carry equal budgets, e.g.")
    for s in range(4):
        j = s + 2
        print(f"   scale {s}, context {ctx_of_octave(j):>5} -> {K0 + DELTA * trunc_sub(j, s)} keys")


def main() -> None:
    demo_measurement()
    demo_rigidity()
    demo_impossibilities()
    demo_budget_table()
    demo_rate_spectrum()
    demo_stability()
    demo_razor()
    demo_workload()
    demo_planning_rule()
    print()


if __name__ == "__main__":
    main()
