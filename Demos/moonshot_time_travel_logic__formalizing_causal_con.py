"""
Time-Travel Logic: A Fixed-Point Theory of Causal Consistency
=============================================================

Numerical demonstrations of the results in the accompanying paper.

Core idea: a closed timelike curve (CTC) is summarized by its *loop map*
    f : S -> S
recording the net effect of one traversal on the world-state.  The Novikov
self-consistency principle holds for the loop exactly when f has a fixed point,
    exists s with f(s) = s.

This script demonstrates:
  1. The fixed-point criterion and closed-timelike-history equivalence.
  2. The grandfather paradox: the flip loop has no fixed point (impossible).
  3. Three positive guarantees:
       - monotone loops on a finite lattice (Knaster-Tarski),
       - continuous loops on [0,1] (1-D Brouwer via bisection on f(x)-x),
       - involutive loops on an odd-sized set (parity).
  4. The many-worlds branching resolution: every paradoxical action admits a
     consistent branching history, with a strictly increasing branch index.

Everything is self-contained; run `python demo.py`.
"""

from __future__ import annotations

from typing import Callable, List, Optional, Tuple, TypeVar, Sequence

T = TypeVar("T")


# ---------------------------------------------------------------------------
# 1. Core model: loop maps, fixed points, and closed timelike histories
# ---------------------------------------------------------------------------

def is_self_consistent(f: Callable[[T], T], states: Sequence[T]) -> bool:
    """A loop map f is self-consistent iff it has a fixed point among `states`."""
    return any(f(s) == s for s in states)


def find_fixed_point(f: Callable[[T], T], states: Sequence[T]) -> Optional[T]:
    """Return a world-state reproduced by one traversal, or None if paradoxical."""
    for s in states:
        if f(s) == s:
            return s
    return None


def traverse(steps: Sequence[Callable[[T], T]], k: int, s: T) -> T:
    """State after applying the first k causal steps, starting from s."""
    state = s
    for i in range(k):
        state = steps[i](state)
    return state


def closed_history_from_fixed_point(
    steps: Sequence[Callable[[T], T]], n: int, s: T
) -> List[T]:
    """
    Given a fixed point s of the length-n loop (traverse(steps, n, s) == s),
    build its closed timelike history h(0), ..., h(n) with h(n) == h(0).
    """
    return [traverse(steps, k, s) for k in range(n + 1)]


def is_closed_history(steps: Sequence[Callable[[T], T]], n: int, h: Sequence[T]) -> bool:
    """Check: every step realized and the loop closes (h[n] == h[0])."""
    steps_ok = all(h[k + 1] == steps[k](h[k]) for k in range(n))
    closes = h[n] == h[0]
    return steps_ok and closes


def demo_novikov_equivalence() -> None:
    print("=" * 70)
    print("1. Novikov equivalence: fixed point  <=>  closed timelike history")
    print("=" * 70)
    # A length-3 loop on Z/6 whose composite is a rotation with a fixed point.
    m = 6
    steps: List[Callable[[int], int]] = [
        lambda x: (x + 2) % m,
        lambda x: (x + 3) % m,
        lambda x: (x + 1) % m,  # net shift +6 == 0  => identity => every state fixed
    ]
    n = 3
    states = list(range(m))
    loop = lambda s: traverse(steps, n, s)
    fp = find_fixed_point(loop, states)
    print(f"  Net loop map shift = {(2 + 3 + 1) % m} (mod {m})  ->  identity")
    print(f"  A fixed point of the length-{n} loop: s = {fp}")
    h = closed_history_from_fixed_point(steps, n, fp)
    print(f"  Closed timelike history from it: {h}")
    print(f"  Valid closed history? {is_closed_history(steps, n, h)}")
    print()


# ---------------------------------------------------------------------------
# 2. The grandfather paradox
# ---------------------------------------------------------------------------

def demo_grandfather() -> None:
    print("=" * 70)
    print("2. Grandfather paradox: the flip loop is paradoxical (impossible)")
    print("=" * 70)
    # World-state = ancestor status; True = alive, False = dead.
    flip: Callable[[bool], bool] = lambda s: not s
    states = [True, False]
    paradoxical = all(flip(s) != s for s in states)
    print(f"  Loop map = boolean negation (flip ancestor's fate).")
    print(f"  For every state, flip(s) != s : {paradoxical}  -> paradoxical")
    print(f"  Fixed point? {find_fixed_point(flip, states)}")
    print(f"  Self-consistent single timeline? {is_self_consistent(flip, states)}")
    print("  => The grandfather paradox admits NO self-consistent history.")
    print()


# ---------------------------------------------------------------------------
# 3a. Monotone loops on a finite lattice (Knaster-Tarski)
# ---------------------------------------------------------------------------

def least_fixed_point_lattice(
    f: Callable[[int], int], bottom: int, top: int
) -> int:
    """
    Least fixed point of a monotone f on the chain {bottom, ..., top} by
    Kleene iteration from the bottom: bottom <= f(bottom) <= f^2(bottom) <= ...
    """
    x = bottom
    while True:
        nx = f(x)
        if nx == x:
            return x
        x = nx
        if x > top:  # safety guard
            raise RuntimeError("f left the lattice; not a self-map")


def demo_knaster_tarski() -> None:
    print("=" * 70)
    print("3a. Monotone loops on a complete lattice are self-consistent")
    print("=" * 70)
    # Chain lattice {0,...,10}; monotone self-map that saturates at 7.
    top = 10
    f: Callable[[int], int] = lambda x: min(x + 1, 7)
    lfp = least_fixed_point_lattice(f, 0, top)
    print(f"  Lattice = chain 0..{top}, f(x) = min(x+1, 7) (monotone self-map).")
    print(f"  Least fixed point (canonical consistent world): {lfp}")
    print(f"  Check f(lfp) == lfp : {f(lfp) == lfp}")
    print()


# ---------------------------------------------------------------------------
# 3b. Continuous loops on [0,1] (1-D Brouwer via IVT / bisection)
# ---------------------------------------------------------------------------

def brouwer_1d_fixed_point(
    f: Callable[[float], float], tol: float = 1e-12, max_iter: int = 200
) -> float:
    """
    Fixed point of a continuous self-map f of [0,1] by bisection on
    g(x) = f(x) - x, using g(0) >= 0 >= g(1).
    """
    g: Callable[[float], float] = lambda x: f(x) - x
    lo, hi = 0.0, 1.0
    glo, ghi = g(lo), g(hi)
    if glo == 0.0:
        return lo
    if ghi == 0.0:
        return hi
    # g(lo) >= 0 >= g(hi); bisect maintaining the sign change.
    for _ in range(max_iter):
        mid = 0.5 * (lo + hi)
        gm = g(mid)
        if abs(gm) < tol or (hi - lo) < tol:
            return mid
        if gm > 0.0:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def demo_brouwer_1d() -> None:
    print("=" * 70)
    print("3b. Continuous loops on the phase interval [0,1] are self-consistent")
    print("=" * 70)
    import math
    # A continuous self-map of [0,1] (Goedel-universe toy model).
    f: Callable[[float], float] = lambda x: 0.5 * (math.cos(math.pi * x) + 1.0) ** 1.0 * 0.8 + 0.1
    s = brouwer_1d_fixed_point(f)
    print("  f(x) = 0.8 * (cos(pi x)+1)/2 + 0.1, a continuous self-map of [0,1].")
    print(f"  Fixed point s ~ {s:.10f}")
    print(f"  Residual |f(s) - s| = {abs(f(s) - s):.2e}")
    print()


# ---------------------------------------------------------------------------
# 3c. Involutive loops on odd-sized state spaces (parity)
# ---------------------------------------------------------------------------

def demo_involution_parity() -> None:
    print("=" * 70)
    print("3c. Involutive loops on an odd-sized state space are self-consistent")
    print("=" * 70)
    # Involution on Z/n given by x -> (c - x) mod n; for odd n it has a fixed point.
    for n in (5, 7, 9):
        c = 2
        f: Callable[[int], int] = lambda x, c=c, n=n: (c - x) % n
        states = list(range(n))
        involutive = all(f(f(x)) == x for x in states)
        fp = find_fixed_point(f, states)
        print(f"  n={n} (odd): f(x)=({c}-x) mod {n}, involution? {involutive}, "
              f"fixed point s={fp}")
    # Contrast: an even-sized state space can host a fixed-point-free involution.
    n = 4
    f_even: Callable[[int], int] = lambda x: (x + 2) % n  # pairs (0,2),(1,3)
    involutive = all(f_even(f_even(x)) == x for x in range(n))
    print(f"  n={n} (even): f(x)=(x+2) mod {n}, involution? {involutive}, "
          f"fixed point {find_fixed_point(f_even, list(range(n)))} (none possible)")
    print()


# ---------------------------------------------------------------------------
# 4. Many-worlds branching resolution
# ---------------------------------------------------------------------------

def branch(a: Callable[[T], T]) -> Callable[[Tuple[T, int]], Tuple[T, int]]:
    """Branching evolution: apply action a and advance to a fresh branch."""
    return lambda p: (a(p[0]), p[1] + 1)


def branching_history(
    a: Callable[[T], T], s0: T, length: int
) -> List[Tuple[T, int]]:
    """History H(0)=(s0,0), H(k+1)=branch(a)(H(k))."""
    step = branch(a)
    hist: List[Tuple[T, int]] = [(s0, 0)]
    for _ in range(length):
        hist.append(step(hist[-1]))
    return hist


def demo_branching() -> None:
    print("=" * 70)
    print("4. Many-worlds: branching resolves EVERY paradox")
    print("=" * 70)
    flip: Callable[[bool], bool] = lambda s: not s  # grandfather action
    hist = branching_history(flip, True, 5)
    print("  Grandfather action in the multiverse (True=alive):")
    print(f"  History: {hist}")
    indices = [b for (_, b) in hist]
    print(f"  Branch indices strictly increasing? {all(b2 > b1 for b1, b2 in zip(indices, indices[1:]))}")
    print(f"  Any repeated multiverse-state? {len(set(hist)) != len(hist)}")
    print("  => No single-timeline fixed point, yet a fully consistent branching history exists.")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    demo_novikov_equivalence()
    demo_grandfather()
    demo_knaster_tarski()
    demo_brouwer_1d()
    demo_involution_parity()
    demo_branching()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
