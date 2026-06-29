"""
Constructive de Jongh-Sambin Fixed Points by Descending Iteration
=================================================================

A fully self-contained numerical demonstration of the order-theoretic core of
Goedel-Loeb provability logic (GL), as developed in the accompanying paper.

We realise a concrete *finite* Goedel-Loeb algebra: the Boolean (hence Heyting)
algebra of subsets of the finite frame (Fin n, <), with provability operator

    box S = { x | for all y, y < x  =>  y in S }   (the "wfBox" of the frame).

Finite frames satisfy the descending chain condition automatically, so the
descending iteration (f . f)^[k] TOP is guaranteed to terminate -- and we watch
it converge, step by step, to the de Jongh-Sambin fixed point.

Everything below is inlined; run `python demo.py`.
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, FrozenSet, List, Tuple

# An element of the algebra Set(Fin n) is a frozenset of worlds {0, 1, ..., n-1}.
Elem = FrozenSet[int]


# --------------------------------------------------------------------------- #
# The finite Heyting / Boolean algebra Set(Fin n)
# --------------------------------------------------------------------------- #
def universe(n: int) -> Elem:
    """The top element TOP = {0, ..., n-1}."""
    return frozenset(range(n))


def bottom() -> Elem:
    """The bottom element BOT = {} (empty set)."""
    return frozenset()


def meet(a: Elem, b: Elem) -> Elem:
    """Lattice meet a AND b = intersection."""
    return a & b


def join(a: Elem, b: Elem) -> Elem:
    """Lattice join a OR b = union."""
    return a | b


def himp(n: int, a: Elem, b: Elem) -> Elem:
    """Heyting implication a => b.

    In a Boolean algebra of sets this is  (complement of a) OR b.
    """
    return (universe(n) - a) | b


def biimp(n: int, a: Elem, b: Elem) -> Elem:
    """Biimplication a <=> b = (a => b) AND (b => a).  Equals TOP iff a == b."""
    return meet(himp(n, a, b), himp(n, b, a))


def le(a: Elem, b: Elem) -> bool:
    """The order a <= b  iff  a is a subset of b."""
    return a <= b


# --------------------------------------------------------------------------- #
# The provability operator: the box of the well-founded frame (Fin n, <)
# --------------------------------------------------------------------------- #
def box(n: int, s: Elem) -> Elem:
    """wfBox of the frame (Fin n, <):  x proves S iff every y < x lies in S."""
    return frozenset(x for x in range(n) if all((y in s) for y in range(x)))


# --------------------------------------------------------------------------- #
# The canonical Goedel/Sambin map and its explicit fixed point
# --------------------------------------------------------------------------- #
def sambin_map(n: int, c: Elem) -> Callable[[Elem], Elem]:
    """The modalised map  p |-> box p => c  (antitone in p)."""
    return lambda p: himp(n, box(n, p), c)


def gl_fix(n: int, c: Elem) -> Elem:
    """The explicit Sambin fixed point  glFix c = box c => c."""
    return himp(n, box(n, c), c)


# --------------------------------------------------------------------------- #
# Algorithm A: descending-iteration fixed point of a monotone map g
# --------------------------------------------------------------------------- #
def descending_iteration(
    n: int, g: Callable[[Elem], Elem]
) -> Tuple[Elem, List[Elem]]:
    """Iterate g from TOP until two consecutive values agree.

    Returns (fixed_point, trace).  Terminates because the frame is finite, so
    the algebra Set(Fin n) satisfies the descending chain condition.
    """
    x: Elem = universe(n)
    trace: List[Elem] = [x]
    while True:
        x_next = g(x)
        trace.append(x_next)
        if x_next == x:
            return x, trace
        x = x_next


# --------------------------------------------------------------------------- #
# Pretty printing
# --------------------------------------------------------------------------- #
def show(s: Elem) -> str:
    return "{" + ", ".join(str(x) for x in sorted(s)) + "}"


def all_subsets(n: int) -> List[Elem]:
    elems: List[Elem] = []
    for k in range(n + 1):
        for combo in combinations(range(n), k):
            elems.append(frozenset(combo))
    return elems


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_axioms(n: int) -> None:
    print(f"=== Goedel-Loeb axioms hold on the frame (Fin {n}, <) ===")
    top = universe(n)
    # Necessitation of truth: box TOP = TOP
    print(f"box(TOP) == TOP : {box(n, top) == top}")
    # Normality: box(a AND b) = box a AND box b
    ok_k = all(
        box(n, meet(a, b)) == meet(box(n, a), box(n, b))
        for a in all_subsets(n)
        for b in all_subsets(n)
    )
    print(f"box(a AND b) == box a AND box b (for all a, b) : {ok_k}")
    # Loeb's axiom: box(box a => a) <= box a
    ok_loeb = all(
        le(box(n, himp(n, box(n, a), a)), box(n, a)) for a in all_subsets(n)
    )
    print(f"box(box a => a) <= box a (for all a) : {ok_loeb}")
    # Derived axiom 4: box a <= box box a
    ok_4 = all(le(box(n, a), box(n, box(n, a))) for a in all_subsets(n))
    print(f"box a <= box box a  (axiom 4, derived) : {ok_4}")
    print()


def demo_godel_second(n: int) -> None:
    print("=== Goedel's second incompleteness theorem (algebraic) ===")
    top = universe(n)
    bot = bottom()
    box_bot = box(n, bot)
    consistent = box_bot != top
    consistency_stmt = himp(n, box_bot, bot)  # "box BOT => BOT"
    provable = box(n, consistency_stmt) == top
    print(f"box(BOT) = {show(box_bot)}   consistent (box BOT != TOP): {consistent}")
    print(f"can prove own consistency  box(box BOT => BOT) == TOP : {provable}")
    print(f"  -> a consistent algebra CANNOT prove its consistency: {consistent and not provable}")
    print()


def demo_provability_ladder(n: int) -> None:
    print("=== Provability ladder  box^k BOT = Iio k = {0,...,k-1} ===")
    s: Elem = bottom()
    for k in range(n + 1):
        expected = frozenset(range(k))
        print(f"box^{k} BOT = {show(s):<18} == Iio {k} = {show(expected)} : {s == expected}")
        s = box(n, s)
    print()


def demo_sambin_fixed_point(n: int, c: Elem) -> None:
    print(f"=== Constructive Sambin fixed point of  p |-> box p => c,  c = {show(c)} ===")
    f = sambin_map(n, c)
    g = lambda p: f(f(p))  # the monotone square
    fp, trace = descending_iteration(n, g)
    print("Descending iteration of the square (f.f)^[k] TOP:")
    for k, x in enumerate(trace):
        print(f"  (f.f)^{k} TOP = {show(x)}")
    closed = gl_fix(n, c)
    print(f"iterative fixed point of f.f : {show(fp)}")
    print(f"f(fixed point)               : {show(f(fp))}   (equals it: {f(fp) == fp})")
    print(f"closed form glFix c = box c => c : {show(closed)}")
    print(f"iteration  ==  closed form   : {fp == closed}")
    # also verify f really fixes the closed form
    print(f"glFix c is a fixed point of f : {f(closed) == closed}")
    print()


def demo_general_uniqueness(n: int, c: Elem) -> None:
    print("=== Uniqueness: the ONLY fixed point of p |-> box p => c equals glFix c ===")
    f = sambin_map(n, c)
    fixed_points = [a for a in all_subsets(n) if f(a) == a]
    closed = gl_fix(n, c)
    print(f"all fixed points found by brute force: {[show(a) for a in fixed_points]}")
    print(f"glFix c = {show(closed)}")
    print(f"exactly one fixed point, equal to glFix c : "
          f"{len(fixed_points) == 1 and fixed_points[0] == closed}")
    print()


def main() -> None:
    n = 4
    demo_axioms(n)
    demo_godel_second(n)
    demo_provability_ladder(n)
    for c in (bottom(), frozenset({1}), frozenset({0, 2})):
        demo_sambin_fixed_point(n, c)
        demo_general_uniqueness(n, c)


if __name__ == "__main__":
    main()
