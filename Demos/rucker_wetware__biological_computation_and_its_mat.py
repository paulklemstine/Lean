"""
Wetware Computation — Numerical Demonstrations
==============================================

Self-contained numerical examples illustrating the main results of the paper
"Wetware Computation: Iterated Dynamics and the Information Cost of Determinism".

A *wetware system* is a state space together with a step map; running it means
iterating the step map. We demonstrate:

  1. The flow (semigroup) law:  run(s + t, x) == run(s, run(t, x)).
  2. Finite-data universality:  every function f : X -> Y is computed in one step
     by a wetware system on the disjoint union X (+) Y.
  3. Eventual periodicity:      on a finite state space every orbit cycles.
  4. The energy connector:      wetwareEnergy(n) = n*log2(n) = Theta(n log n),
                                siliconEnergy(n) = n^2       = Theta(n^2),
                                the strict gap n*log2 n < n^2, and the decay
                                (n*log2 n) / n^2 -> 0.

Run with:  python demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

from math import log2
from typing import Callable, Dict, Hashable, List, Tuple, TypeVar, Union

S = TypeVar("S")
X = TypeVar("X")
Y = TypeVar("Y")


# ---------------------------------------------------------------------------
# 1. The wetware dynamical system
# ---------------------------------------------------------------------------
def run(step: Callable[[S], S], t: int, x: S) -> S:
    """Run a wetware system (given by its step map) for t steps from state x."""
    state = x
    for _ in range(t):
        state = step(state)
    return state


def demo_flow_law() -> None:
    """Verify the flow law run(s+t, x) = run(s, run(t, x)) on a concrete map."""
    print("=" * 68)
    print("1. FLOW / SEMIGROUP LAW:  run(s+t, x) = run(s, run(t, x))")
    print("=" * 68)

    # A step map on Z/12 (a 'clock' neuron): add 5 modulo 12.
    step: Callable[[int], int] = lambda s: (s + 5) % 12
    ok = True
    for s in range(6):
        for t in range(6):
            for x in range(12):
                lhs = run(step, s + t, x)
                rhs = run(step, s, run(step, t, x))
                ok = ok and (lhs == rhs)
    print(f"  step(s) = (s + 5) mod 12, checked all s,t in [0,5], x in [0,11]")
    print(f"  flow law holds for every case: {ok}")
    print()


# ---------------------------------------------------------------------------
# 2. Finite-data universality
# ---------------------------------------------------------------------------
def build_universal_wetware(
    f: Callable[[X], Y], domain: List[X]
) -> Tuple[Callable[[Tuple[str, object]], Tuple[str, object]],
           Callable[[X], Tuple[str, object]],
           Callable[[Tuple[str, object]], object]]:
    """
    Construct a wetware system on X (+) Y computing f in ONE step.

    States are tagged pairs: ('in', x) is a pending input, ('out', y) an output.
    Returns (step, enc, dec).
    """
    ftab: Dict[X, Y] = {x: f(x) for x in domain}

    def step(state: Tuple[str, object]) -> Tuple[str, object]:
        tag, val = state
        if tag == "in":
            return ("out", ftab[val])   # transition pending input -> output
        return ("out", val)             # outputs are fixed points

    enc: Callable[[X], Tuple[str, object]] = lambda x: ("in", x)
    dec: Callable[[Tuple[str, object]], object] = lambda st: st[1]
    return step, enc, dec


def demo_universality() -> None:
    """Show that an arbitrary function is computed in one step."""
    print("=" * 68)
    print("2. FINITE-DATA UNIVERSALITY:  dec(run(1, enc(x))) = f(x)")
    print("=" * 68)

    domain = list(range(8))
    f: Callable[[int], int] = lambda x: (x * x + 3) % 8   # an arbitrary table
    step, enc, dec = build_universal_wetware(f, domain)

    print("  target f(x) = (x^2 + 3) mod 8")
    all_ok = True
    for x in domain:
        computed = dec(run(step, 1, enc(x)))
        all_ok = all_ok and (computed == f(x))
        print(f"    x={x}:  computed={computed}   f(x)={f(x)}   match={computed == f(x)}")
    print(f"  universality verified for all inputs: {all_ok}")
    print()


# ---------------------------------------------------------------------------
# 3. Eventual periodicity of finite orbits
# ---------------------------------------------------------------------------
def find_cycle(step: Callable[[S], S], start: S) -> Tuple[int, int]:
    """
    Return (mu, lam): the index mu where the cycle begins and the period lam,
    witnessing run(mu, start) = run(mu + lam, start). Requires a finite orbit.
    """
    seen: Dict[Hashable, int] = {}
    state = start
    t = 0
    while state not in seen:
        seen[state] = t
        state = step(state)
        t += 1
    mu = seen[state]      # first time this repeated state was seen
    lam = t - mu          # period
    return mu, lam


def demo_eventual_periodicity() -> None:
    """Detect the eventual cycle of an orbit on a finite state space."""
    print("=" * 68)
    print("3. EVENTUAL PERIODICITY:  finite orbits must cycle (pigeonhole)")
    print("=" * 68)

    # A step map on Fin 10 with a 'tail' leading into a cycle.
    table = [3, 4, 5, 6, 7, 8, 9, 5, 6, 7]  # note indices 5..9 form a loop
    step: Callable[[int], int] = lambda s: table[s]
    for start in (0, 2, 5):
        mu, lam = find_cycle(step, start)
        i, j = mu, mu + lam
        print(f"  start={start}: cycle onset mu={mu}, period lam={lam} "
              f"=>  run({i}) == run({j})  "
              f"({run(step, i, start)} == {run(step, j, start)})")
    print()


# ---------------------------------------------------------------------------
# 4. The energy connector
# ---------------------------------------------------------------------------
def wetware_energy(n: int) -> float:
    """Bits to specify a deterministic transition map Fin n -> Fin n: n*log2(n)."""
    if n <= 0:
        return 0.0
    return n * log2(n)


def silicon_energy(n: int) -> float:
    """Bits to specify a binary connection matrix Fin n -> Fin n -> Bool: n^2."""
    return float(n * n)


def demo_energy_connector() -> None:
    """Tabulate the strict gap and the vanishing ratio."""
    print("=" * 68)
    print("4. ENERGY CONNECTOR:  n*log2(n)  vs  n^2")
    print("=" * 68)
    print(f"  {'n':>10} | {'wetware=n log2 n':>18} | {'silicon=n^2':>14} | {'ratio':>12}")
    print("  " + "-" * 62)
    for n in [2, 4, 8, 16, 64, 256, 1024, 10**4, 10**6, 10**9]:
        w = wetware_energy(n)
        s = silicon_energy(n)
        ratio = w / s
        print(f"  {n:>10} | {w:>18.2f} | {s:>14.2e} | {ratio:>12.3e}")
    print()
    print("  Strict separation (n>=1): n*log2 n < n^2 holds in every row above.")
    print("  Asymptotic separation:    ratio = log2(n)/n -> 0 as n -> infinity.")
    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    demo_flow_law()
    demo_universality()
    demo_eventual_periodicity()
    demo_energy_connector()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
