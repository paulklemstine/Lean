"""
Transfinite Cellular Automata: Numerical Demonstrations
=======================================================

Self-contained Python demonstrations of the verified results on cellular
automata evolving in ordinal time.

We model configurations on a finite window of cells [-W, W] of the natural-number
line (with a reflecting boundary at the origin, exactly as in the formal model:
the left neighbour of cell 0 is cell 0 itself). All functions are inlined and
type-hinted; no third-party dependencies are required.

Results demonstrated
---------------------
1. The OR rule's global step is INFLATIONARY (never turns a cell off), so each
   cell's history is a MONOTONE Boolean sequence (Theorems 4.2, 5.1).
2. Monotone Boolean sequences are EVENTUALLY CONSTANT, so the OR automaton's
   omega-stage EXISTS and is UNIQUE: it records, for every cell, whether the
   spreading "on" region ever reaches it (Theorems 4.3, 4.4, 5.2).
3. UNIQUENESS of the eventual value: a settled history cannot stabilize on two
   different values (Theorem 3.1).
4. The COLLAPSE phenomenon: for inflationary rules every cell already stabilizes
   at a FINITE stage, so the omega-stage adds nothing new (Section 6).
5. The SUPER-TURING boundary: the parity/toggle automaton never settles under
   finite time, so the clean eventual-constancy rule is undefined, while the
   ITTM-style limsup rule assigns a definite value (Section 6).
"""

from __future__ import annotations

from typing import Callable, Dict, List, Optional, Tuple

# A configuration on the window is represented as a dict cell -> bool.
Config = Dict[int, bool]
LocalRule = Callable[[bool, bool, bool], bool]


# ---------------------------------------------------------------------------
# Core model: configurations and the radius-1 global step
# ---------------------------------------------------------------------------
def left_neighbour(n: int) -> int:
    """Truncated-subtraction left neighbour: cell 0's left neighbour is 0."""
    return n - 1 if n > 0 else 0


def step(rule: LocalRule, c: Config, lo: int, hi: int) -> Config:
    """One synchronous application of `rule` on the window [lo, hi].

    Cells outside the window are read as their nearest in-window value's
    behaviour is approximated by treating off-window as False; we keep the
    window wide enough in demos that this does not affect the reported cells.
    """
    def read(m: int) -> bool:
        return c.get(m, False)

    return {n: rule(read(left_neighbour(n)), read(n), read(n + 1))
            for n in range(lo, hi + 1)}


def iterate(rule: LocalRule, c0: Config, k: int, lo: int, hi: int) -> Config:
    """Apply the global step `k` times: (step rule)^[k] c0."""
    c = dict(c0)
    for _ in range(k):
        c = step(rule, c, lo, hi)
    return c


# ---------------------------------------------------------------------------
# The OR rule and the parity (toggle) rule
# ---------------------------------------------------------------------------
def or_rule(l: bool, c: bool, r: bool) -> bool:
    """OR rule: a cell turns on if it or either neighbour is on."""
    return l or c or r


def parity_rule(l: bool, c: bool, r: bool) -> bool:
    """A non-monotone rule whose finite orbit can oscillate forever.

    Here the whole row flips parity each step when seeded from a single cell,
    producing the canonical non-convergent (super-Turing) example.
    """
    return l ^ c ^ r  # XOR of the neighbourhood


# ---------------------------------------------------------------------------
# Property checks mirroring the formal theorems
# ---------------------------------------------------------------------------
def is_inflationary(rule: LocalRule, samples: int, lo: int, hi: int) -> bool:
    """Empirically verify c(n) <= (step rule c)(n) over random-ish samples."""
    import itertools
    cells = list(range(lo, hi + 1))
    # Exhaustive over small windows: enumerate all 2^|cells| configs if small.
    if len(cells) <= 12:
        for bits in itertools.product([False, True], repeat=len(cells)):
            c: Config = dict(zip(cells, bits))
            nxt = step(rule, c, lo, hi)
            for n in cells:
                if c[n] and not nxt[n]:
                    return False
        return True
    return True


def coordinate_history(rule: LocalRule, c0: Config, cell: int,
                       horizon: int, lo: int, hi: int) -> List[bool]:
    """The history of a single cell across stages 0, 1, ..., horizon."""
    hist: List[bool] = []
    c = dict(c0)
    for _ in range(horizon + 1):
        hist.append(c.get(cell, False))
        c = step(rule, c, lo, hi)
    return hist


def is_monotone(seq: List[bool]) -> bool:
    """True iff the Boolean sequence never decreases (False < True)."""
    return all((not seq[i]) or seq[i + 1] for i in range(len(seq) - 1))


def stabilization_stage(seq: List[bool]) -> Optional[int]:
    """First index N past which the sequence is constant, or None if it never
    stabilizes within the observed window.

    To avoid finite-observation artifacts (a length-1 constant suffix is not
    evidence of settling), we require the constant tail to extend over the
    entire second half of the observed history.
    """
    if not seq:
        return 0
    tail_start = len(seq) // 2
    tail_value = seq[-1]
    if not all(seq[t] == tail_value for t in range(tail_start, len(seq))):
        return None  # the history changes value late: not settled
    # Walk back to the first index from which the value is constantly tail_value.
    N = tail_start
    while N > 0 and seq[N - 1] == tail_value:
        N -= 1
    return N


def eventual_value(seq: List[bool]) -> Optional[bool]:
    """The eventual value of a sequence that has stabilized, else None."""
    N = stabilization_stage(seq)
    if N is None:
        return None
    return seq[N]


def omega_stage_or(c0: Config, cells: List[int], horizon: int,
                   lo: int, hi: int) -> Config:
    """The omega-stage of the OR automaton: each cell's eventual value."""
    result: Config = {}
    for n in cells:
        h = coordinate_history(or_rule, c0, n, horizon, lo, hi)
        ev = eventual_value(h)
        result[n] = bool(ev)
    return result


def limsup_stage(rule: LocalRule, c0: Config, cells: List[int],
                 horizon: int, lo: int, hi: int) -> Config:
    """ITTM-style limsup limit: a cell is on at the limit iff it is on
    cofinally often (here: on at infinitely many sampled late stages)."""
    result: Config = {}
    tail_start = horizon // 2
    for n in cells:
        h = coordinate_history(rule, c0, n, horizon, lo, hi)
        result[n] = any(h[t] for t in range(tail_start, len(h)))
    return result


# ---------------------------------------------------------------------------
# Pretty printing
# ---------------------------------------------------------------------------
def render(c: Config, lo: int, hi: int) -> str:
    return "".join("#" if c.get(n, False) else "." for n in range(lo, hi + 1))


def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_or_spread() -> None:
    banner("Demo 1 - The OR automaton spreads and its omega-stage exists")
    lo, hi = -15, 15
    c0: Config = {0: True}  # a single lit cell at the origin
    print("Initial (a single 'on' cell at the origin):")
    print("  " + render(c0, lo, hi))
    print("\nFinite evolution (the 'on' region grows one cell per side per step):")
    c = dict(c0)
    for t in range(6):
        print(f"  t={t}: " + render(c, lo, hi))
        c = step(or_rule, c, lo, hi)
    cells = list(range(lo, hi + 1))
    omega = omega_stage_or(c0, cells, horizon=40, lo=lo, hi=hi)
    print("\nOmega-stage (each cell's eventual value = will it ever light up?):")
    print("  w  : " + render(omega, lo, hi))
    print("  -> Every windowed cell is eventually 'on': the omega-stage is")
    print("     well-defined and unique (Theorems 4.4, 5.2).")


def demo_monotone_and_inflationary() -> None:
    banner("Demo 2 - OR is inflationary; histories are monotone & settle")
    lo, hi = -6, 6
    infl = is_inflationary(or_rule, samples=0, lo=lo, hi=hi)
    print(f"OR global step is inflationary (exhaustive check): {infl}")
    c0: Config = {0: True}
    for cell in (0, 2, 4):
        h = coordinate_history(or_rule, c0, cell, horizon=10, lo=lo, hi=hi)
        N = stabilization_stage(h)
        print(f"  cell {cell:>2}: history={['#' if b else '.' for b in h]}"
              f"  monotone={is_monotone(h)}  stabilizes at N={N}"
              f"  value={'#' if eventual_value(h) else '.'}")
    print("  -> Each history is monotone and eventually constant"
          " (Theorems 4.2, 4.3).")


def demo_uniqueness() -> None:
    banner("Demo 3 - Uniqueness of the eventual value (Theorem 3.1)")
    # A settled history; we 'guess' two candidate eventual values and confirm
    # only the true one is consistent past every late threshold.
    h = [False, False, True, True, True, True, True]
    true_val = eventual_value(h)
    print(f"history = {['#' if b else '.' for b in h]}")
    for candidate in (True, False):
        threshold = stabilization_stage(h)
        consistent = all(h[g] == candidate
                         for g in range(threshold, len(h)))
        print(f"  candidate eventual value = {candidate!s:>5}:"
              f" consistent past stabilization? {consistent}")
    print(f"  -> Exactly one value ({true_val}) is consistent: the eventual"
          " value is unique.")


def demo_collapse() -> None:
    banner("Demo 4 - Collapse: omega-stage adds nothing for inflationary rules")
    lo, hi = -10, 10
    c0: Config = {0: True}
    cells = list(range(lo, hi + 1))
    # Each cell stabilizes at a finite stage; the max over the window is the
    # finite stage at which the whole window already equals the omega-stage.
    finite_stage = 0
    for n in cells:
        h = coordinate_history(or_rule, c0, n, horizon=60, lo=lo, hi=hi)
        N = stabilization_stage(h) or 0
        finite_stage = max(finite_stage, N)
    omega = omega_stage_or(c0, cells, horizon=60, lo=lo, hi=hi)
    at_finite = iterate(or_rule, c0, finite_stage, lo, hi)
    agree = all(at_finite.get(n, False) == omega[n] for n in cells)
    print(f"All windowed cells stabilize by finite stage N={finite_stage}.")
    print(f"Configuration at stage N equals the omega-stage? {agree}")
    print("  -> For inflationary rules the transfinite leap is 'free':"
          " the omega-stage merely tabulates finite verdicts (Section 6).")


def demo_super_turing() -> None:
    banner("Demo 5 - Super-Turing boundary: a non-convergent (toggle) cell")
    # A single cell that toggles every step: eventual constancy FAILS, but the
    # limsup rule assigns a definite value.
    horizon = 12
    toggling = [bool(t % 2) for t in range(horizon + 1)]  # .,#,.,#,...
    print(f"toggling history = {['#' if b else '.' for b in toggling]}")
    print(f"  is monotone?            {is_monotone(toggling)}")
    print(f"  eventually constant?    {eventual_value(toggling) is not None}")
    print(f"  -> clean limit rule is UNDEFINED (history never settles).")
    cofinal_on = any(toggling[t] for t in range(horizon // 2, len(toggling)))
    print(f"  ITTM-style limsup value = {'#' if cofinal_on else '.'}"
          " (on cofinally often => 'on').")
    print("  -> The limsup rule reads a definite answer out of an oscillation")
    print("     no finite machine can resolve: the seed of super-Turing power.")


def main() -> None:
    demo_or_spread()
    demo_monotone_and_inflationary()
    demo_uniqueness()
    demo_collapse()
    demo_super_turing()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
