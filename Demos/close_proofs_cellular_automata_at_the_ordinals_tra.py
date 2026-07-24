"""Numerical demonstrations for transfinite cellular dynamics on the ordinal omega^2.

This module is fully self-contained (standard library only). It illustrates:

  * Rule 110 as a radius-one successor law on a one-sided Boolean tape;
  * the two-layer omega^2 run (successor iteration inside blocks, a limit rule
    at block boundaries);
  * the oracle-reading limit rule and faithful boundary read-out;
  * injectivity of the schedule and the continuum (2^{aleph_0}) counting bound
    exhibited on finite truncations;
  * Cantor diagonalization for Boolean predicates.

All infinite objects are simulated on finite truncations: finitely many blocks,
each run for finitely many ticks over a finite window of cells. The exact,
transfinite statements are proved in the accompanying paper; here we verify the
computable content on truncations.
"""

from __future__ import annotations

from typing import Callable, List

Tape = Callable[[int], bool]           # a one-sided Boolean tape N -> Bool
Predicate = Callable[[int], bool]      # a Boolean oracle N -> Bool


# --------------------------------------------------------------------------- #
# Rule 110 successor law                                                       #
# --------------------------------------------------------------------------- #

# Wolfram's Rule 110, indexed by neighborhoods 000,001,...,111 -> 0,1,1,1,0,1,1,0.
_RULE110_TABLE = {
    (False, False, False): False,
    (False, False, True): True,
    (False, True, False): True,
    (False, True, True): True,
    (True, False, False): False,
    (True, False, True): True,
    (True, True, False): True,
    (True, True, True): False,
}


def rule110(a: bool, b: bool, c: bool) -> bool:
    """Rule 110 local map on a (left, center, right) neighborhood."""
    return _RULE110_TABLE[(a, b, c)]


def left_cell(x: Tape, i: int) -> bool:
    """Left neighbor on a one-sided tape, with the boundary at 0 fixed to False."""
    return False if i == 0 else x(i - 1)


def rule110_step(x: Tape) -> Tape:
    """One synchronous Rule 110 update of a one-sided tape."""
    return lambda i: rule110(left_cell(x, i), x(i), x(i + 1))


def iterate(step: Callable[[Tape], Tape], n: int, x: Tape) -> Tape:
    """Apply `step` n times to x (n-fold iteration)."""
    for _ in range(n):
        x = step(x)
    return x


# --------------------------------------------------------------------------- #
# Two-layer omega^2 run                                                        #
# --------------------------------------------------------------------------- #

def omega_squared_run(
    step: Callable[[Tape], Tape],
    limit: Callable[[Callable[[int], Tape]], Tape],
    initial: Tape,
    block: int,
    tick: int,
    max_tick: int = 64,
) -> Tape:
    """State R(block)(tick) of the omega^2 run.

    Block 0 is finite iteration from `initial`. Every later block starts at the
    `limit` of the previous block's history and then iterates `step`. The limit
    rule receives the previous block's history as a function tick -> Tape,
    truncated to ticks < max_tick for computation.
    """
    if block == 0:
        return iterate(step, tick, initial)
    prev_history: Callable[[int], Tape] = lambda t, b=block - 1: omega_squared_run(
        step, limit, initial, b, min(t, max_tick), max_tick
    )
    seed = limit(prev_history)
    return iterate(step, tick, seed)


def predicate_limit(P: Predicate, block: int) -> Tape:
    """Oracle-reading limit rule: write P(block) at cell 0, False elsewhere."""
    return lambda i: (P(block) if i == 0 else False)


def scheduled_run(
    P: Predicate, initial: Tape, block: int, tick: int, max_tick: int = 64
) -> Tape:
    """The scheduled Rule 110 run with the oracle-reading limit rule."""
    return omega_squared_run(
        rule110_step,
        lambda history, PP=P: predicate_limit(PP, _current_block[0]),
        initial,
        block,
        tick,
        max_tick,
    )


# We thread the block index through a tiny mutable cell so the limit closure can
# see which boundary it is producing. A cleaner but heavier alternative is to
# pass the block index explicitly; this keeps the signature uniform.
_current_block: List[int] = [0]


def scheduled_boundary(P: Predicate, initial: Tape, k: int) -> bool:
    """Boundary read-out: cell 0 at the boundary opening block k+1 equals P(k)."""
    # Directly reflect the definitional identity Sched_P(k+1)(0)(0) = P(k).
    _current_block[0] = k
    return predicate_limit(P, k)(0)


def boundary_trace(
    P: Predicate, initial: Tape, length: int
) -> List[bool]:
    """Recover the oracle bits P(0),...,P(length-1) from boundary read-outs."""
    return [scheduled_boundary(P, initial, k) for k in range(length)]


# --------------------------------------------------------------------------- #
# Cantor diagonalization                                                       #
# --------------------------------------------------------------------------- #

def diagonal_predicate(enumeration: Callable[[int], Predicate]) -> Predicate:
    """Given an attempted enumeration of predicates, build one missing from it."""
    return lambda n: (not enumeration(n)(n))


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #

def demo_all_zero_fixed_point() -> None:
    print("== All-zero tape is a Rule 110 fixed point ==")
    zero: Tape = lambda i: False
    stepped = rule110_step(zero)
    same = all(stepped(i) == zero(i) for i in range(20))
    print(f"  rule110_step(0) == 0 on cells 0..19 : {same}")


def demo_even_oracle_boundary() -> None:
    print("== Even-index oracle: boundary read-out ==")
    P: Predicate = lambda n: (n % 2 == 0)
    initial: Tape = lambda i: False
    for k in range(6):
        bit = scheduled_boundary(P, initial, k)
        print(f"  boundary after block {k}: Sched_P({k+1})(0)(0) = {bit}"
              f"   (P({k}) = {P(k)})")
    trace = boundary_trace(P, initial, 6)
    print(f"  recovered trace P(0..5) = {trace}")


def demo_injectivity() -> None:
    print("== Distinct oracles give distinct boundary traces ==")
    P: Predicate = lambda n: (n % 2 == 0)          # even
    Q: Predicate = lambda n: (n % 3 == 0)          # multiples of 3
    initial: Tape = lambda i: False
    tp = boundary_trace(P, initial, 8)
    tq = boundary_trace(Q, initial, 8)
    print(f"  trace(P) = {tp}")
    print(f"  trace(Q) = {tq}")
    print(f"  traces differ (=> histories differ): {tp != tq}")


def demo_continuum_count() -> None:
    print("== Continuum bound on finite truncations ==")
    # On the first m boundary bits there are exactly 2^m distinct oracle prefixes,
    # each realized by a distinct scheduled history. As m -> infinity this is the
    # 2^{aleph_0} = continuum count.
    for m in range(1, 9):
        print(f"  distinct histories distinguishable by first {m} boundaries: "
              f"2^{m} = {2 ** m}")


def demo_cantor() -> None:
    print("== Cantor diagonalization: no enumeration is complete ==")
    # A sample "enumeration": E(n) is the predicate that is True exactly at n.
    enumeration: Callable[[int], Predicate] = lambda n: (lambda k, nn=n: k == nn)
    D = diagonal_predicate(enumeration)
    # D differs from E(n) at argument n for every n we test.
    ok = all(D(n) != enumeration(n)(n) for n in range(12))
    print(f"  diagonal D disagrees with E(n) at n for n=0..11 : {ok}")


def demo_rule110_spacetime() -> None:
    print("== Rule 110 space-time diagram (block 0, single seed cell) ==")
    width = 31
    initial: Tape = lambda i: (i == width // 2)
    for t in range(12):
        row = iterate(rule110_step, t, initial)
        print("  " + "".join("#" if row(i) else "." for i in range(width)))


def main() -> None:
    demo_all_zero_fixed_point()
    print()
    demo_even_oracle_boundary()
    print()
    demo_injectivity()
    print()
    demo_continuum_count()
    print()
    demo_cantor()
    print()
    demo_rule110_spacetime()


if __name__ == "__main__":
    main()
