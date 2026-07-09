"""
Self-Improving Proofs: A Refinement Calculus on Proof Complexity
================================================================

Numerical demonstrations of the refinement theory.

We model a *proof* of a theorem as a bundle of a complexity value
    C(P) = length(P) + depth(P) + #lemmas(P)  in the natural numbers,
together with a marker that the underlying theorem is true.  A proof P'
*refines* P when it proves the same theorem strictly more simply:
    P' refines P   <=>   C(P') < C(P).

Because C(P) is a natural number and the natural numbers are well-ordered,
the following all hold (and are demonstrated below):

  * every nonempty family of proofs has a complexity-minimal member;
  * the limit P_infinity (a globally simplest proof) always exists;
  * the minimal complexity is a well-defined invariant of the theorem;
  * no infinite strictly-descending refinement chain exists;
  * every non-increasing refinement sequence is eventually constant;
  * yet refinement chains can be arbitrarily long.

The script is self-contained: run `python demo.py`.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, List, Optional, Sequence


# ---------------------------------------------------------------------------
# The model
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Proof:
    """A proof of a (true) theorem, abstracted by its complexity.

    Attributes
    ----------
    name:
        A human label for the proof strategy.
    length:
        Number of proof steps.
    depth:
        Nesting depth of sub-derivations.
    lemmas:
        Number of auxiliary lemmas invoked.
    theorem_holds:
        Certificate marker that the underlying theorem is true.  A Proof is
        only meaningful when this is True (existence <=> theorem is true).
    """

    name: str
    length: int
    depth: int
    lemmas: int
    theorem_holds: bool = True

    @property
    def complexity(self) -> int:
        """C(P) = length(P) + depth(P) + #lemmas(P)."""
        return self.length + self.depth + self.lemmas


def refines(p: Proof, q: Proof) -> bool:
    """True iff `p` refines `q`, i.e. C(p) < C(q)."""
    return p.complexity < q.complexity


# ---------------------------------------------------------------------------
# Core algorithms from the theory
# ---------------------------------------------------------------------------

def minimal_proof(family: Sequence[Proof]) -> Proof:
    """Return a complexity-minimal member of a nonempty family (Theorem 4.1).

    No member of the family refines the returned proof.
    """
    if not family:
        raise ValueError("family must be nonempty")
    return min(family, key=lambda p: p.complexity)


def minimal_complexity(family: Sequence[Proof]) -> int:
    """The well-defined minimal complexity of a nonempty family (Def. 5.2)."""
    return minimal_proof(family).complexity


def is_globally_simplest(p: Proof, universe: Sequence[Proof]) -> bool:
    """True iff no proof in `universe` refines `p` (the P_infinity property)."""
    return not any(refines(q, p) for q in universe)


def refinement_terminates(sequence: Sequence[Proof]) -> Optional[int]:
    """For a non-increasing sequence, return the first index N after which the
    complexity is constant (Theorem 6.2); return None if the sequence is not
    non-increasing.
    """
    comps = [p.complexity for p in sequence]
    if any(comps[i + 1] > comps[i] for i in range(len(comps) - 1)):
        return None  # not non-increasing
    final = comps[-1]
    for n, c in enumerate(comps):
        if c == final:
            return n
    return len(comps) - 1


def long_refinement_chain(theorem_holds: bool, N: int) -> List[Proof]:
    """A strictly descending refinement chain of length N+1 (Theorem 7.1).

    The proofs have complexities N, N-1, ..., 0.
    """
    if not theorem_holds:
        raise ValueError("theorem must hold to build proofs of it")
    return [Proof(name=f"P_{i}", length=N - i, depth=0, lemmas=0) for i in range(N + 1)]


def is_strictly_descending(chain: Sequence[Proof]) -> bool:
    """True iff each proof strictly refines the previous one."""
    return all(refines(chain[i + 1], chain[i]) for i in range(len(chain) - 1))


# ---------------------------------------------------------------------------
# Demonstration 1: the sqrt(2) worked example (chain 7 -> 4 -> 2)
# ---------------------------------------------------------------------------

def demo_sqrt2() -> None:
    print("=" * 70)
    print("DEMO 1  Irrationality of sqrt(2):  the chain  7  ->  4  ->  2")
    print("=" * 70)

    # Complexities engineered to total 7, 4, 2 respectively.
    strategy_A = Proof("A: classical contradiction", length=4, depth=2, lemmas=1)  # 7
    strategy_B = Proof("B: via prime divisibility", length=2, depth=1, lemmas=1)   # 4
    strategy_C = Proof("C: packaged theorem", length=1, depth=1, lemmas=0)         # 2

    family = [strategy_A, strategy_B, strategy_C]
    for p in family:
        print(f"  {p.name:32s}  C = {p.complexity}")

    print(f"\n  B refines A? {refines(strategy_B, strategy_A)}  (4 < 7)")
    print(f"  C refines B? {refines(strategy_C, strategy_B)}  (2 < 4)")
    print(f"  C refines A (by transitivity)? {refines(strategy_C, strategy_A)}")

    simplest = minimal_proof(family)
    print(f"\n  Simplest of the three: {simplest.name}  (C = {simplest.complexity})")
    print(f"  Globally simplest within the family? "
          f"{is_globally_simplest(simplest, family)}")
    print(f"  Minimal complexity C_min over the family: {minimal_complexity(family)}")


# ---------------------------------------------------------------------------
# Demonstration 2: uniqueness of the minimal complexity
# ---------------------------------------------------------------------------

def demo_invariant() -> None:
    print("\n" + "=" * 70)
    print("DEMO 2  Two different simplest proofs share the same complexity")
    print("=" * 70)

    # Two genuinely different proofs, both of complexity 3.
    p = Proof("proof P", length=2, depth=1, lemmas=0)  # 3
    q = Proof("proof Q", length=1, depth=1, lemmas=1)  # 3
    universe = [p, q, Proof("bulky", length=5, depth=3, lemmas=2)]

    print(f"  C(P) = {p.complexity}, C(Q) = {q.complexity}")
    print(f"  P globally simplest? {is_globally_simplest(p, universe)}")
    print(f"  Q globally simplest? {is_globally_simplest(q, universe)}")
    print(f"  Equal complexity (Theorem 5.1)? {p.complexity == q.complexity}")
    print("  => The minimal complexity is an invariant of the theorem,")
    print("     even though the simplest proof object is NOT unique.")


# ---------------------------------------------------------------------------
# Demonstration 3: termination of a non-increasing sequence
# ---------------------------------------------------------------------------

def demo_termination() -> None:
    print("\n" + "=" * 70)
    print("DEMO 3  A non-increasing refinement sequence halts")
    print("=" * 70)

    # Complexities 9,7,5,5,5,5,...  -- decreasing then frozen.
    comps = [9, 7, 5, 5, 5, 5]
    seq = [Proof(f"step {i}", length=c, depth=0, lemmas=0) for i, c in enumerate(comps)]
    print("  complexities:", [p.complexity for p in seq])
    N = refinement_terminates(seq)
    print(f"  Sequence becomes constant from index N = {N} "
          f"(C = {seq[N].complexity}) onward.")


# ---------------------------------------------------------------------------
# Demonstration 4: arbitrarily long chains that still terminate
# ---------------------------------------------------------------------------

def demo_long_chains() -> None:
    print("\n" + "=" * 70)
    print("DEMO 4  Chains can be arbitrarily long (yet always terminate)")
    print("=" * 70)

    for N in (3, 10, 100):
        chain = long_refinement_chain(theorem_holds=True, N=N)
        print(f"  N = {N:3d}:  chain length {len(chain):3d}, "
              f"strictly descending? {is_strictly_descending(chain)}, "
              f"complexities {chain[0].complexity} -> ... -> {chain[-1].complexity}")

    print("\n  No bound on chain length exists, but every chain still bottoms")
    print("  out at complexity 0 -- termination is guaranteed, speed is not.")


def main() -> None:
    demo_sqrt2()
    demo_invariant()
    demo_termination()
    demo_long_chains()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
