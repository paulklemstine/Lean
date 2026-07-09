"""
Numerical demonstrations for the Proof-Refinement Framework.

A *refinement system* for a fixed target proposition consists of:
  - a collection of proof candidates,
  - a validity (soundness) predicate on candidates, and
  - a natural-number complexity measure C.

A candidate P' *refines* P when both are valid and C(P') < C(P).

This script demonstrates, with concrete finite systems, the framework's results:

  1. Well-foundedness  -> no infinite refinement chain (chain length <= C(start)).
  2. Halting           -> a deterministic non-increasing process stabilizes.
  3. Existence         -> a globally complexity-minimal valid proof always exists.
  4. Non-uniqueness    -> the simplest proof need not be unique (2 + 2 = 4).
  5. Local minima      -> a greedy process can get stuck above the global optimum.
  6. Tightness         -> chains can be arbitrarily long, but always finite.

All functions are self-contained and type-hinted; no external dependencies.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, Hashable, List, Optional, Sequence


@dataclass(frozen=True)
class RefinementSystem:
    """A refinement system over a finite candidate set.

    Attributes:
        candidates: the finite list of proof candidates (any hashable labels).
        valid: soundness predicate; valid(c) is True iff c certifies the target.
        complexity: natural-number complexity measure C on candidates.
    """

    candidates: Sequence[Hashable]
    valid: Callable[[Hashable], bool]
    complexity: Callable[[Hashable], int]

    def refines(self, p_new: Hashable, p_old: Hashable) -> bool:
        """Return True iff p_new refines p_old: both valid and strictly simpler."""
        return (
            self.valid(p_new)
            and self.valid(p_old)
            and self.complexity(p_new) < self.complexity(p_old)
        )

    def valid_candidates(self) -> List[Hashable]:
        """Return all valid candidates."""
        return [c for c in self.candidates if self.valid(c)]

    def global_minimum(self) -> Optional[Hashable]:
        """Return a globally complexity-minimal valid candidate, or None.

        Existence theorem: whenever a valid candidate exists, so does a minimizer.
        """
        valids = self.valid_candidates()
        if not valids:
            return None
        return min(valids, key=self.complexity)

    def all_global_minima(self) -> List[Hashable]:
        """Return every valid candidate attaining the minimum complexity."""
        valids = self.valid_candidates()
        if not valids:
            return []
        best = min(self.complexity(c) for c in valids)
        return [c for c in valids if self.complexity(c) == best]


def run_deterministic_process(
    system: RefinementSystem,
    step: Callable[[Hashable], Hashable],
    start: Hashable,
    max_iters: int = 1000,
) -> List[Hashable]:
    """Iterate a deterministic non-increasing step rule until complexity stabilizes.

    Halting theorem: if C(step(c)) <= C(c) for all c, the complexity sequence
    becomes eventually constant. We stop once the complexity stops changing.

    Returns the trajectory of visited candidates up to (and including) the point
    where complexity first stabilizes.
    """
    trajectory: List[Hashable] = [start]
    current = start
    for _ in range(max_iters):
        nxt = step(current)
        if system.complexity(nxt) >= system.complexity(current):
            # No strict decrease: the deterministic process has stabilized.
            break
        trajectory.append(nxt)
        current = nxt
    return trajectory


def longest_refinement_chain(system: RefinementSystem, start: Hashable) -> List[Hashable]:
    """Greedily build a strict refinement chain from `start`.

    Length bound: the number of steps is at most C(start), since each step
    decreases a natural-number complexity by at least one.
    """
    chain: List[Hashable] = [start]
    current = start
    while True:
        # pick any strictly simpler valid candidate; here, the simplest available
        candidates = [
            c for c in system.candidates if system.refines(c, current)
        ]
        if not candidates:
            break
        # pick the *closest* simpler candidate to build the longest chain
        nxt = max(candidates, key=system.complexity)
        chain.append(nxt)
        current = nxt
    return chain


# --------------------------------------------------------------------------- #
# Demo 1: Existence + well-foundedness on a generic finite system.
# --------------------------------------------------------------------------- #
def demo_existence_and_wellfounded() -> None:
    print("=" * 70)
    print("DEMO 1: Existence of a simplest proof; well-founded chains")
    print("=" * 70)
    # Candidates labeled by name, all valid (true target); complexities vary.
    weights: Dict[str, int] = {"draft": 9, "revised": 6, "tight": 4, "book": 2}
    system = RefinementSystem(
        candidates=list(weights),
        valid=lambda c: True,
        complexity=lambda c: weights[c],
    )
    gmin = system.global_minimum()
    print(f"Complexities: {weights}")
    print(f"Global minimum (simplest proof): {gmin!r} with C = {weights[gmin]}")
    chain = longest_refinement_chain(system, "draft")
    print(f"Greedy refinement chain from 'draft': {chain}")
    print(f"Chain steps = {len(chain) - 1}, bound C(start) = {weights['draft']} "
          f"(steps <= bound: {len(chain) - 1 <= weights['draft']})")
    print()


# --------------------------------------------------------------------------- #
# Demo 2: Non-uniqueness of the simplest proof (target 2 + 2 = 4).
# --------------------------------------------------------------------------- #
def demo_non_unique_minimum() -> None:
    print("=" * 70)
    print("DEMO 2: The simplest proof need not be unique (target: 2 + 2 = 4)")
    print("=" * 70)
    target_true = (2 + 2 == 4)
    weights = {"computation": 1, "normalization": 1, "verbose": 3}
    system = RefinementSystem(
        candidates=list(weights),
        valid=lambda c: target_true,     # every candidate valid since target holds
        complexity=lambda c: weights[c],
    )
    minima = system.all_global_minima()
    print(f"Complexities: {weights}")
    print(f"All global minima: {minima}")
    print(f"Number of distinct simplest proofs: {len(minima)}")
    print()


# --------------------------------------------------------------------------- #
# Demo 3: Halting at a LOCAL minimum that is not global.
# --------------------------------------------------------------------------- #
def demo_local_minimum_trap() -> None:
    print("=" * 70)
    print("DEMO 3: A deterministic process trapped at a local minimum")
    print("=" * 70)
    weights = {"start": 5, "mid": 4, "local": 3, "global": 2}
    system = RefinementSystem(
        candidates=list(weights),
        valid=lambda c: True,
        complexity=lambda c: weights[c],
    )

    def step(c: str) -> str:
        return {"start": "mid", "mid": "local", "local": "local", "global": "global"}[c]

    trajectory = run_deterministic_process(system, step, "start")
    end = trajectory[-1]
    gmin = system.global_minimum()
    print(f"Complexities: {weights}")
    print(f"Process trajectory: {trajectory}")
    print(f"Process halts at {end!r} with C = {weights[end]} (a LOCAL minimum)")
    print(f"True global minimum: {gmin!r} with C = {weights[gmin]}")
    print(f"'global' refines 'local'? {system.refines('global', 'local')} "
          f"-- yet the process never reaches it.")
    print()


# --------------------------------------------------------------------------- #
# Demo 4: Tightness -- arbitrarily long (but finite) refinement chains.
# --------------------------------------------------------------------------- #
def demo_arbitrarily_long_chains() -> None:
    print("=" * 70)
    print("DEMO 4: Chains can be arbitrarily long, but always finite")
    print("=" * 70)
    for m in (3, 7, 20, 100):
        system = RefinementSystem(
            candidates=list(range(m + 1)),
            valid=lambda c: True,
            complexity=lambda c: int(c),
        )
        chain = longest_refinement_chain(system, m)
        steps = len(chain) - 1
        print(f"m = {m:>3}: chain of exactly {steps} refinement steps "
              f"(bound C(start) = {m}, tight: {steps == m})")
    print()


def main() -> None:
    demo_existence_and_wellfounded()
    demo_non_unique_minimum()
    demo_local_minimum_trap()
    demo_arbitrarily_long_chains()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
