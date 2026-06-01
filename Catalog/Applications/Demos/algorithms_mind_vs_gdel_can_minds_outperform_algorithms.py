#!/usr/bin/env python3
"""
Algorithms for Incompleteness Phenomena

Type-hinted implementations of the key algorithms from the
Mind vs Gödel formalization.
"""

from typing import Callable, Set, Optional, List, Tuple, Dict, FrozenSet
from dataclasses import dataclass, field


# ============================================================
# Core Types
# ============================================================

Sentence = int  # Abstract sentences represented as integers


@dataclass
class FormalSystem:
    """An abstract formal system with provability and truth predicates."""
    provable: Callable[[Sentence], bool]
    true_in_model: Callable[[Sentence], bool]
    neg: Callable[[Sentence], Sentence]
    name: str = "F"

    def is_sound(self, domain: range) -> bool:
        """Check soundness on a finite domain."""
        return all(
            not self.provable(s) or self.true_in_model(s)
            for s in domain
        )

    def is_consistent(self, domain: range) -> bool:
        """Check consistency on a finite domain."""
        return all(
            not (self.provable(s) and self.provable(self.neg(s)))
            for s in domain
        )

    def is_complete(self, domain: range) -> bool:
        """Check completeness on a finite domain."""
        return all(
            self.provable(s) or self.provable(self.neg(s))
            for s in domain
        )

    def godel_sentence(self, domain: range) -> Optional[Sentence]:
        """Find a Gödel sentence: true iff not provable."""
        for s in domain:
            if self.true_in_model(s) == (not self.provable(s)):
                if not self.provable(s) and self.true_in_model(s):
                    return s
        return None


@dataclass
class IncompletenessChain:
    """A chain of formal systems, each extending the previous."""
    systems: List[FormalSystem]

    @staticmethod
    def build(
        base_provable: Set[Sentence],
        base_true: Set[Sentence],
        neg: Callable[[Sentence], Sentence],
        godel_sentences: List[Sentence],
        levels: int
    ) -> 'IncompletenessChain':
        """Build an incompleteness chain by iteratively adding Gödel sentences."""
        systems: List[FormalSystem] = []
        current_provable = set(base_provable)

        for n in range(levels):
            prov = frozenset(current_provable)
            systems.append(FormalSystem(
                provable=lambda s, p=prov: s in p,
                true_in_model=lambda s, t=base_true: s in t,
                neg=neg,
                name=f"F_{n}"
            ))
            if n < len(godel_sentences):
                current_provable.add(godel_sentences[n])

        return IncompletenessChain(systems=systems)


# ============================================================
# Algorithm 1: Incompleteness Chain Construction
# ============================================================

def build_incompleteness_chain(
    base_system: FormalSystem,
    godel_constructor: Callable[[FormalSystem], Optional[Sentence]],
    levels: int,
    domain: range
) -> List[Tuple[FormalSystem, Optional[Sentence]]]:
    """
    Build an incompleteness chain by iteratively finding and
    adding Gödel sentences.

    Returns: List of (system, godel_sentence) pairs at each level.

    Complexity: O(levels × |domain|) for the Gödel sentence search.
    """
    chain: List[Tuple[FormalSystem, Optional[Sentence]]] = []
    current_provable: Set[Sentence] = set()

    # Collect initially provable sentences
    for s in domain:
        if base_system.provable(s):
            current_provable.add(s)

    for n in range(levels):
        prov = frozenset(current_provable)
        system = FormalSystem(
            provable=lambda s, p=prov: s in p,
            true_in_model=base_system.true_in_model,
            neg=base_system.neg,
            name=f"F_{n}"
        )
        g = godel_constructor(system)
        chain.append((system, g))

        if g is not None:
            current_provable.add(g)

    return chain


# ============================================================
# Algorithm 2: Berry Number Computation
# ============================================================

def compute_berry_number(
    definable: Callable[[int, int], bool],
    level: int,
    search_limit: int = 10000
) -> int:
    """
    Compute the Berry number at a given level: the least natural
    number not definable at that level.

    The Berry paradox shows that this function cannot itself be
    captured at any fixed definability level.

    Complexity: O(search_limit) in the worst case.
    """
    for k in range(search_limit):
        if not definable(level, k):
            return k
    return search_limit  # Fallback


def berry_paradox_check(
    definable: Callable[[int, int], bool],
    berry_cost: int,
    max_level: int = 20
) -> List[Tuple[int, int, bool]]:
    """
    Check the Berry paradox: at each level n, compute the Berry number
    and check if it's definable at the fixed cost level.

    Returns: List of (level, berry_number, is_paradoxical) triples.
    """
    results: List[Tuple[int, int, bool]] = []

    for n in range(1, max_level + 1):
        bn = compute_berry_number(definable, n)
        is_paradoxical = definable(berry_cost, bn) and not definable(n, bn)
        results.append((n, bn, is_paradoxical))

    return results


# ============================================================
# Algorithm 3: Chaitin Bound Computation
# ============================================================

def compute_chaitin_bound(
    provable_sentences: List[Sentence],
    complexity: Callable[[Sentence], int]
) -> int:
    """
    Compute the Chaitin bound: the maximum complexity of any
    provable sentence, plus one.

    No sentence with complexity ≥ bound can be proven to have
    that complexity.

    Complexity: O(|provable_sentences|)
    """
    if not provable_sentences:
        return 0

    max_complexity = max(complexity(s) for s in provable_sentences)
    return max_complexity + 1


# ============================================================
# Algorithm 4: Self-Recognition Test
# ============================================================

def self_recognition_test(
    mind: Callable[[FormalSystem], Set[Sentence]],
    system: FormalSystem,
    domain: range
) -> Optional[Sentence]:
    """
    Test whether a mind function has blind spots with respect
    to a formal system.

    Returns: A sentence that is true but not recognized by the mind
             (if found), or None.
    """
    recognized = mind(system)

    for s in domain:
        if system.true_in_model(s) and not system.provable(s):
            if s not in recognized:
                return s  # Found a blind spot

    return None


# ============================================================
# Algorithm 5: Oracle Extension Construction
# ============================================================

def oracle_extension(
    base: FormalSystem,
    oracle: Callable[[Sentence], bool],
    oracle_sound: bool = True
) -> FormalSystem:
    """
    Construct an oracle extension of a formal system.

    The extended system proves everything the base proves,
    plus everything the oracle approves.
    """
    return FormalSystem(
        provable=lambda s: base.provable(s) or oracle(s),
        true_in_model=base.true_in_model,
        neg=base.neg,
        name=f"{base.name}+oracle"
    )


# ============================================================
# Demonstration
# ============================================================

def demo() -> None:
    """Run demonstrations of all algorithms."""

    # Set up a simple formal system
    # Sentences 0-99, even numbers are true, system proves multiples of 4
    N = 100
    domain = range(N)

    true_sentences = {s for s in domain if s % 2 == 0}
    provable_sentences = {s for s in domain if s % 4 == 0}

    system = FormalSystem(
        provable=lambda s: s in provable_sentences,
        true_in_model=lambda s: s in true_sentences,
        neg=lambda s: s + 1 if s % 2 == 0 else s - 1,  # Pair each even with next odd
        name="F_0"
    )

    print("=" * 50)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 50)
    print()

    # 1. Incompleteness chain
    print("1. Incompleteness Chain Construction")
    print("-" * 40)

    # True but unprovable: even numbers not divisible by 4
    godel_candidates = [s for s in domain if s % 2 == 0 and s % 4 != 0]

    def godel_constructor(sys: FormalSystem) -> Optional[Sentence]:
        for s in domain:
            if sys.true_in_model(s) and not sys.provable(s):
                return s
        return None

    chain = build_incompleteness_chain(system, godel_constructor, 5, domain)
    for i, (sys, g) in enumerate(chain):
        provable_count = sum(1 for s in domain if sys.provable(s))
        print(f"  Level {i}: {provable_count} provable, Gödel = {g}")
    print()

    # 2. Berry number
    print("2. Berry Number Computation")
    print("-" * 40)

    def definable(level: int, k: int) -> bool:
        return k < 2 ** level

    for n in range(1, 11):
        bn = compute_berry_number(definable, n)
        print(f"  Level {n}: Berry number = {bn} (= 2^{n})")
    print()

    # 3. Chaitin bound
    print("3. Chaitin Bound")
    print("-" * 40)

    complexity = lambda s: s  # Simple complexity = value
    prov_list = list(provable_sentences)
    bound = compute_chaitin_bound(prov_list, complexity)
    print(f"  Provable sentences: {len(prov_list)}")
    print(f"  Max complexity among provable: {max(complexity(s) for s in prov_list)}")
    print(f"  Chaitin bound: {bound}")
    print()

    # 4. Self-recognition test
    print("4. Self-Recognition Test")
    print("-" * 40)

    def mind(sys: FormalSystem) -> Set[Sentence]:
        # A mind that recognizes the first unprovable true sentence
        result = set()
        for s in domain:
            if sys.true_in_model(s) and not sys.provable(s):
                result.add(s)
                break  # Only sees the first one
        return result

    blind_spot = self_recognition_test(mind, system, domain)
    if blind_spot is not None:
        print(f"  Mind has blind spot at sentence {blind_spot}")
        print(f"  (true: {system.true_in_model(blind_spot)}, "
              f"provable: {system.provable(blind_spot)})")
    print()

    # 5. Oracle extension
    print("5. Oracle Extension")
    print("-" * 40)

    oracle = lambda s: s == 2  # Oracle that proves sentence 2
    ext = oracle_extension(system, oracle)
    ext_provable = sum(1 for s in domain if ext.provable(s))
    print(f"  Base provable: {len(provable_sentences)}")
    print(f"  Extended provable: {ext_provable}")
    print(f"  Extension still incomplete: {not ext.is_complete(domain)}")
    print()


if __name__ == "__main__":
    demo()
