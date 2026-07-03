"""
Dark Mathematics: Theorems That Exist But Cannot Be Found
=========================================================

A self-contained numerical illustration of the theory of *dark theorems*.

A statement T(.) is DARK for a sound proof system when:
    (1) the system proves the existential closure  "exists x, T(x)", yet
    (2) for every specific n, the system does NOT prove the instance  T(n).

We build the explicit "cautious" model from the paper:

    * Sentences are atoms atom(n), an existential builder ex(T), and a
      counting builder atLeast(k, T).
    * Truth (cTrue) is the honest semantics over a chosen set of true atoms.
    * Provability (cProv) is deliberately weakened: it certifies any *true*
      existential or counting sentence but NEVER certifies an atom.

Under this model we exhibit:
    - a genuinely dark statement (Shadow Theorem),
    - the strict darkness hierarchy at levels 0, 1, 2, 3, ...,
    - the abundance of dark statements (injection from {True,False}^N),
    - the failure of any uniform provability decider (diagonalization).

Run with:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, List, Optional, Set


# --------------------------------------------------------------------------- #
# Sentence algebra
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class Sentence:
    """A node of the inductive sentence algebra `Sent`.

    kind is one of: "atom", "bot", "ex", "atLeast".
    """
    kind: str
    n: int = 0                                   # atom index
    k: int = 0                                   # count for atLeast
    pred: Optional[Callable[[int], "Sentence"]] = None  # predicate for ex/atLeast


def atom(n: int) -> Sentence:
    return Sentence(kind="atom", n=n)


def bot() -> Sentence:
    return Sentence(kind="bot")


def ex(pred: Callable[[int], Sentence]) -> Sentence:
    return Sentence(kind="ex", pred=pred)


def at_least(k: int, pred: Callable[[int], Sentence]) -> Sentence:
    return Sentence(kind="atLeast", k=k, pred=pred)


# --------------------------------------------------------------------------- #
# The cautious model: truth (cTrue) and provability (cProv)
# --------------------------------------------------------------------------- #
class ConcreteModel:
    """concreteModel(A): a sound proof system parameterized by atom-truth A.

    `search_bound` bounds the finite search used to evaluate existentials and
    counts (the underlying mathematics is over all of N; we truncate for
    computation).
    """

    def __init__(self, atom_true: Callable[[int], bool], search_bound: int = 64) -> None:
        self.atom_true = atom_true
        self.search_bound = search_bound

    # ---- truth --------------------------------------------------------- #
    def c_true(self, s: Sentence) -> bool:
        if s.kind == "atom":
            return self.atom_true(s.n)
        if s.kind == "bot":
            return False
        if s.kind == "ex":
            assert s.pred is not None
            return any(self.c_true(s.pred(n)) for n in range(self.search_bound))
        if s.kind == "atLeast":
            assert s.pred is not None
            witnesses = [n for n in range(self.search_bound) if self.c_true(s.pred(n))]
            return len(witnesses) >= s.k
        raise ValueError(f"unknown sentence kind: {s.kind}")

    # ---- provability (deliberately cautious) --------------------------- #
    def c_prov(self, s: Sentence) -> bool:
        """Prove only *true* existential/counting sentences; never an atom."""
        if s.kind in ("ex", "atLeast"):
            return self.c_true(s)
        return False  # atoms and bot are never provable

    # ---- witness bookkeeping ------------------------------------------- #
    def true_witnesses(self, pred: Callable[[int], Sentence]) -> Set[int]:
        return {n for n in range(self.search_bound) if self.c_true(pred(n))}


# --------------------------------------------------------------------------- #
# Darkness predicates
# --------------------------------------------------------------------------- #
def is_dark(model: ConcreteModel, pred: Callable[[int], Sentence],
            index_bound: int = 64) -> bool:
    """Dark: proves existence, proves no instance."""
    proves_existence = model.c_prov(ex(pred))
    proves_no_instance = all(not model.c_prov(pred(n)) for n in range(index_bound))
    return proves_existence and proves_no_instance


def is_dark_level(model: ConcreteModel, k: int, pred: Callable[[int], Sentence],
                  index_bound: int = 64) -> bool:
    """Dark at level k: proves at-least-k witnesses, proves no instance."""
    proves_count = model.c_prov(at_least(k, pred))
    proves_no_instance = all(not model.c_prov(pred(n)) for n in range(index_bound))
    return proves_count and proves_no_instance


def darkness_level(model: ConcreteModel, pred: Callable[[int], Sentence],
                   index_bound: int = 64) -> int:
    """Largest k with dark-at-level-k (= number of provable witnesses)."""
    k = 0
    while is_dark_level(model, k + 1, pred, index_bound):
        k += 1
    # confirm base darkness (proves no instance) even at k = 0
    return k if is_dark_level(model, k, pred, index_bound) else -1


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_shadow_theorem() -> None:
    print("=" * 70)
    print("1. THE SHADOW THEOREM: a witness that exists but cannot be found")
    print("=" * 70)
    model = ConcreteModel(atom_true=lambda _n: True)   # every atom is true
    pred = atom                                         # T(n) = atom(n)

    print(f"  Proves existence  'exists x, T(x)' : {model.c_prov(ex(pred))}")
    print(f"  Proves any instance T(n)?          : "
          f"{any(model.c_prov(pred(n)) for n in range(16))}")
    print(f"  => Dark                             : {is_dark(model, pred)}")

    # Shadow theorem: some instance is genuinely TRUE though unprovable.
    true_ns = [n for n in range(8) if model.c_true(pred(n))]
    print(f"  Genuinely true instances (sample)  : {true_ns}")
    print(f"  ... yet none of them is provable   : "
          f"{all(not model.c_prov(pred(n)) for n in true_ns)}")
    print("  Interpretation: the shadow is cast by a real, invisible object.\n")


def demo_strict_hierarchy() -> None:
    print("=" * 70)
    print("2. THE STRICT DARKNESS HIERARCHY: levels 0, 1, 2, 3 are distinct")
    print("=" * 70)
    for k in range(5):
        # exactly k true atoms: {0, ..., k-1}
        model = ConcreteModel(atom_true=lambda n, k=k: n < k)
        pred = atom
        level = darkness_level(model, pred)
        proves_k = model.c_prov(at_least(k, pred))
        proves_kp1 = model.c_prov(at_least(k + 1, pred))
        print(f"  A(n) = [n < {k}]  ->  proves AtLeast({k}) = {proves_k}, "
              f"proves AtLeast({k+1}) = {proves_kp1}, darkness level = {level}")
    print("  Each level is achieved and strictly separated from the next.\n")


def demo_abundance() -> None:
    print("=" * 70)
    print("3. ABUNDANCE: an injection {True,False}^N  ->  dark statements")
    print("=" * 70)
    # Each g : N -> Bool yields a distinct model whose atom-predicate is dark,
    # as long as at least one coordinate is true (existence stays provable).
    import itertools
    patterns = list(itertools.product([True, False], repeat=3))
    dark_count = 0
    for g in patterns:
        gfun = lambda n, g=g: g[n] if n < len(g) else True  # tail all-true
        model = ConcreteModel(atom_true=gfun)
        if is_dark(model, atom):
            dark_count += 1
    print(f"  Finite sample: {dark_count}/{len(patterns)} length-3 flag "
          f"patterns give dark statements.")
    print("  The full family is indexed by {True,False}^N, of cardinality")
    print("  2^aleph0 = continuum: the dark statements are UNCOUNTABLE.\n")


def demo_no_uniform_decider() -> None:
    print("=" * 70)
    print("4. NO UNIFORM DECIDER: diagonalization defeats any master table")
    print("=" * 70)

    # Suppose D(i, n) claims to decide whether instance n of statement i is
    # provable. Build a diagonal statement that disagrees on its own diagonal.
    def fake_decider(i: int, n: int) -> bool:
        return (i * 7 + n) % 2 == 0  # any concrete total table

    def diagonal_pattern(i: int) -> List[bool]:
        # statement i's true instances are the NEGATION of D's diagonal guess
        return [not fake_decider(i, i)]

    disagreements = sum(
        1 for i in range(10)
        if diagonal_pattern(i)[0] != fake_decider(i, i)
    )
    print(f"  Constructed a statement disagreeing with the decider on all "
          f"{disagreements}/10 diagonal entries.")
    print("  No total table can predict its own diagonal: no uniform decider "
          "exists.\n")


def main() -> None:
    demo_shadow_theorem()
    demo_strict_hierarchy()
    demo_abundance()
    demo_no_uniform_decider()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
