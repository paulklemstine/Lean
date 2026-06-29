"""
Discrete Dynamics of Self-Modifying Computation — Numerical Demonstrations
=========================================================================

This self-contained script demonstrates, on finite configuration spaces, the
structural theorems about self-modifying machines:

  * Iterate collision        (a repeat appears within card(P x S) steps)
  * Eventual periodicity     (preperiod tail + positive period, both <= N)
  * Orbit confinement        (every iterate equals one of the first N+1)
  * Quine cycle              (a total finite machine reproduces a past config)
  * Bounded-search safety    (ever-reaches-bad  iff  reaches-bad within N steps)
  * Alignment obstruction    (strong connectivity + one bad state => no safe
                              nonempty forward-invariant region; every start
                              reaches a bad state)

A self-modifying machine is a step function
    step : (program, state) -> (program, state) | None
On a finite space, a *total* machine (step never None) is a self-map
    dyn : (P x S) -> (P x S),
and running for n steps is iterating dyn n times.

No third-party dependencies; standard library only.
"""

from __future__ import annotations

from typing import Callable, Dict, Hashable, List, Optional, Set, Tuple

Config = Hashable
SelfMap = Callable[[Config], Config]


# ---------------------------------------------------------------------------
# Core iteration utilities
# ---------------------------------------------------------------------------

def iterate(f: SelfMap, x: Config, n: int) -> Config:
    """Return f^[n](x): apply f to x exactly n times."""
    cur = x
    for _ in range(n):
        cur = f(cur)
    return cur


def orbit_prefix(f: SelfMap, x: Config, length: int) -> List[Config]:
    """Return [x, f(x), f^2(x), ..., f^[length-1](x)]."""
    out: List[Config] = []
    cur = x
    for _ in range(length):
        out.append(cur)
        cur = f(cur)
    return out


# ---------------------------------------------------------------------------
# Theorem 3.4 / 4.1 : iterate collision  ->  preperiod (tail) and period
# ---------------------------------------------------------------------------

def find_collision(f: SelfMap, x: Config, card: int) -> Tuple[int, int]:
    """
    Find indices i < j <= card with f^[i](x) == f^[j](x), guaranteed to exist
    by the pigeonhole principle on a finite space of size `card`.

    Returns (i, j) where i is the preperiod (tail) length and j - i is the
    cycle period.
    """
    seen: Dict[Config, int] = {}
    cur = x
    for k in range(card + 1):
        if cur in seen:
            return seen[cur], k          # i = first occurrence, j = now
        seen[cur] = k
        cur = f(cur)
    raise RuntimeError("collision must occur within card+1 steps (pigeonhole)")


def tail_and_period(f: SelfMap, x: Config, card: int) -> Tuple[int, int]:
    """Return (preperiod k, period p) with 0 < p <= card and k <= card."""
    i, j = find_collision(f, x, card)
    return i, j - i


# ---------------------------------------------------------------------------
# Theorem 3.6 / 4.2 : orbit confinement and bounded-search safety
# ---------------------------------------------------------------------------

def confined_index(f: SelfMap, x: Config, n: int, card: int) -> int:
    """
    For any n, return k <= card with f^[n](x) == f^[k](x) (orbit confinement).
    """
    target = iterate(f, x, n)
    prefix = orbit_prefix(f, x, card + 1)
    for k, c in enumerate(prefix):
        if c == target:
            return k
    raise RuntimeError("orbit confinement guarantees a witness <= card")


def ever_reaches_bad(f: SelfMap, x: Config, bad: Set[Config], card: int) -> Optional[int]:
    """
    Decide whether the (total) machine ever enters `bad`, by Theorem 4.2 it
    suffices to search the first `card` steps. Returns the first witnessing
    step n (n <= card) or None if the machine is forever safe.
    """
    cur = x
    for n in range(card + 1):
        if cur in bad:
            return n
        cur = f(cur)
    return None


# ---------------------------------------------------------------------------
# Theorem 3.8 / 3.9 / 4.3 : strong connectivity & alignment obstruction
# ---------------------------------------------------------------------------

def reachable_set(f: SelfMap, x: Config, universe: List[Config]) -> Set[Config]:
    """All configurations reachable from x by iterating f (forward orbit)."""
    seen: Set[Config] = set()
    cur = x
    for _ in range(len(universe) + 1):
        if cur in seen:
            break
        seen.add(cur)
        cur = f(cur)
    return seen


def is_strongly_connected(f: SelfMap, universe: List[Config]) -> bool:
    """True iff every configuration reaches every other configuration."""
    full = set(universe)
    return all(reachable_set(f, x, universe) == full for x in universe)


def maximal_safe_invariant(f: SelfMap, universe: List[Config],
                           bad: Set[Config]) -> Set[Config]:
    """
    Compute the largest forward-invariant subset of the safe states
    (universe \\ bad). A state survives iff its entire forward orbit avoids bad.
    By Theorem 3.9 this is empty whenever f is strongly connected and bad != {}.
    """
    safe = set(universe) - bad
    survivors = {x for x in safe if reachable_set(f, x, universe).isdisjoint(bad)}
    # survivors is automatically forward-invariant
    return survivors


# ---------------------------------------------------------------------------
# Example machines on finite spaces
# ---------------------------------------------------------------------------

def cycle_machine(n: int) -> Tuple[SelfMap, List[Config]]:
    """Single directed n-cycle: i -> (i+1) mod n. Total & strongly connected."""
    universe = list(range(n))
    return (lambda i: (i + 1) % n), universe


def rho_machine() -> Tuple[SelfMap, List[Config]]:
    """
    'Rho-shaped' machine on {0..5}: a tail 0->1->2 feeding a 3-cycle 2->3->4->2.
    Has a genuine preperiod (not strongly connected from outside the cycle).
    """
    succ = {0: 1, 1: 2, 2: 3, 3: 4, 4: 2, 5: 0}
    universe = list(range(6))
    return (lambda i: succ[i]), universe


def affine_machine(n: int, a: int, b: int) -> Tuple[SelfMap, List[Config]]:
    """Affine self-modification on Z/n : c -> (a*c + b) mod n."""
    universe = list(range(n))
    return (lambda c: (a * c + b) % n), universe


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_collision_and_period() -> None:
    print("=" * 70)
    print("DEMO 1 — Iterate collision, preperiod and period (Thms 3.4, 3.5)")
    print("=" * 70)
    f, universe = rho_machine()
    card = len(universe)
    i, j = find_collision(f, 0, card)
    k, p = tail_and_period(f, 0, card)
    print(f"  Configuration space size N = {card}")
    print(f"  Orbit of 0: {orbit_prefix(f, 0, card + 1)}")
    print(f"  Collision: f^[{i}](0) == f^[{j}](0)  (i < j <= N)")
    print(f"  Preperiod (tail) k = {k} <= N,  period p = {p}, 0 < p <= N")
    assert iterate(f, 0, k + p) == iterate(f, 0, k)
    print("  Verified: f^[k+p](0) == f^[k](0).")
    print()


def demo_orbit_confinement() -> None:
    print("=" * 70)
    print("DEMO 2 — Orbit confinement (Thm 3.6 / 4.2)")
    print("=" * 70)
    f, universe = rho_machine()
    card = len(universe)
    print(f"  Every iterate equals one of the first N+1 = {card + 1} iterates:")
    for n in [7, 50, 1000, 10 ** 6]:
        k = confined_index(f, 0, n, card)
        assert iterate(f, 0, n) == iterate(f, 0, k)
        print(f"    f^[{n:>7}](0) == f^[{k}](0) = {iterate(f, 0, k)}")
    print()


def demo_quine_cycle() -> None:
    print("=" * 70)
    print("DEMO 3 — Quine cycle: total finite machine reproduces a config")
    print("          (Thm 4.1)")
    print("=" * 70)
    f, universe = cycle_machine(6)
    card = len(universe)
    i, j = find_collision(f, 0, card)
    print(f"  6-cycle machine, N = {card}.")
    print(f"  run(0, {i}) == run(0, {j}):  config {iterate(f,0,i)} is revisited.")
    print(f"  Period = {j - i}; the machine runs forever, cycling this config.")
    assert iterate(f, 0, j) == iterate(f, 0, i)
    print("  Verified self-reproduction within N steps.")
    print()


def demo_bounded_safety() -> None:
    print("=" * 70)
    print("DEMO 4 — Bounded-search safety (Thm 4.2)")
    print("=" * 70)
    f, universe = cycle_machine(8)
    card = len(universe)
    bad = {5}
    n = ever_reaches_bad(f, 0, bad, card)
    print(f"  8-cycle, bad = {bad}. Ever reaches bad?  step = {n} (<= N = {card}).")
    # A machine whose orbit avoids bad:
    f2, uni2 = rho_machine()         # orbit of 0 visits {0,1,2,3,4}
    res = ever_reaches_bad(f2, 0, {5}, len(uni2))
    print(f"  rho machine from 0, bad = {{5}}: ever reaches bad? -> {res} (safe)")
    print()


def demo_alignment_obstruction() -> None:
    print("=" * 70)
    print("DEMO 5 — Alignment obstruction (Thms 3.8, 3.9, 4.3)")
    print("=" * 70)
    f, universe = cycle_machine(6)
    card = len(universe)
    print(f"  6-cycle is strongly connected? {is_strongly_connected(f, universe)}")
    bad = {3}
    safe_inv = maximal_safe_invariant(f, universe, bad)
    print(f"  bad = {bad}: maximal safe forward-invariant region = {safe_inv}")
    print("  -> empty: NO nonempty safe invariant region exists (obstruction).")
    print("  Every start reaches the bad state:")
    for x in universe:
        n = ever_reaches_bad(f, x, bad, card)
        print(f"    start {x}: reaches bad at step {n}")
    print()
    # Breaking connectivity restores controllability:
    succ = {0: 1, 1: 2, 2: 2, 3: 3, 4: 4, 5: 5}  # cut arrows into 3
    g = lambda i: succ[i]
    print("  Now CUT the arrows feeding state 3 (break strong connectivity):")
    print(f"    strongly connected? {is_strongly_connected(g, universe)}")
    safe_inv2 = maximal_safe_invariant(g, universe, {3})
    print(f"    maximal safe forward-invariant region = {sorted(safe_inv2)}")
    print("  -> nonempty: control is now possible. Reachability, not the step")
    print("     map, is the decisive variable.")
    print()


def demo_affine_cycle_lengths() -> None:
    print("=" * 70)
    print("DEMO 6 — Affine self-modification cycle lengths (future direction)")
    print("=" * 70)
    n = 7
    for a in range(1, n):
        f, universe = affine_machine(n, a, 0)
        i, j = find_collision(f, 1, n)
        print(f"  Z/{n}, c -> {a}*c mod {n}: from 1, period = {j - i}")
    print("  Cycle length tracks the multiplicative order of a in (Z/n)^*.")
    print()


def main() -> None:
    demo_collision_and_period()
    demo_orbit_confinement()
    demo_quine_cycle()
    demo_bounded_safety()
    demo_alignment_obstruction()
    demo_affine_cycle_lengths()
    print("All demonstrations completed and assertions verified.")


if __name__ == "__main__":
    main()
