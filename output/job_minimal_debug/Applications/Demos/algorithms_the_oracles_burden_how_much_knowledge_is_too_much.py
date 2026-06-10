#!/usr/bin/env python3
"""
Oracle Hierarchy Algorithms

Type-hinted implementations of the key algorithms from the research.
"""

from typing import Set, List, Callable, Optional, Tuple, Dict, FrozenSet
from dataclasses import dataclass, field


@dataclass(frozen=True)
class ReflectiveTheory:
    """A formal theory with provability and truth tracking."""
    provable: FrozenSet[int]
    true_sentences: FrozenSet[int]

    def is_sound(self) -> bool:
        """Check if every provable sentence is true."""
        return self.provable.issubset(self.true_sentences)

    def is_complete(self) -> bool:
        """Check if every true sentence is provable."""
        return self.true_sentences.issubset(self.provable)

    def incompleteness_gap(self) -> FrozenSet[int]:
        """True sentences that are not provable."""
        return self.true_sentences - self.provable

    def is_consistent(self) -> bool:
        """Check if there exists a sentence not provable (theory doesn't prove everything)."""
        return len(self.provable) < len(self.true_sentences) or bool(self.true_sentences - self.provable)


@dataclass
class OracleJump:
    """An oracle jump operator on reflective theories."""
    jump_fn: Callable[[FrozenSet[int]], FrozenSet[int]]
    truth: FrozenSet[int]

    def jump(self, theory: ReflectiveTheory) -> ReflectiveTheory:
        """Apply the oracle jump to produce a strictly stronger theory."""
        new_provable = self.jump_fn(theory.provable)
        assert theory.provable.issubset(new_provable), "Jump must be extensive"
        assert new_provable - theory.provable, "Jump must be strict"
        return ReflectiveTheory(
            provable=new_provable,
            true_sentences=theory.true_sentences
        )


def build_oracle_hierarchy(
    base: ReflectiveTheory,
    jump: OracleJump,
    levels: int
) -> List[ReflectiveTheory]:
    """Build the oracle hierarchy up to the given number of levels.

    Returns a list [T_0, T_1, ..., T_levels] where T_0 = base
    and T_{n+1} = jump(T_n).
    """
    hierarchy: List[ReflectiveTheory] = [base]
    current = base
    for _ in range(levels):
        current = jump.jump(current)
        hierarchy.append(current)
    return hierarchy


def verify_strict_hierarchy(hierarchy: List[ReflectiveTheory]) -> bool:
    """Verify that the hierarchy is strictly increasing."""
    for i in range(len(hierarchy) - 1):
        if not (hierarchy[i].provable < hierarchy[i + 1].provable):
            return False
    return True


def find_separating_witnesses(
    hierarchy: List[ReflectiveTheory],
    m: int,
    n: int
) -> FrozenSet[int]:
    """Find sentences provable at level n but not at level m.

    Returns the set T_n.provable \ T_m.provable.
    """
    assert 0 <= m < n < len(hierarchy)
    return hierarchy[n].provable - hierarchy[m].provable


def compute_knowledge_burden(
    hierarchy: List[ReflectiveTheory],
    con_sentences: List[int],
    level: int
) -> Dict[str, object]:
    """Compute the knowledge burden at a given level.

    Returns a dict with:
    - 'known_consistency': set of Con(T_k) known at this level
    - 'unknown_consistency': Con(T_level) which is not known
    - 'burden_count': number of known consistency facts
    """
    known = set()
    for k in range(level):
        if con_sentences[k] in hierarchy[level].provable:
            known.add(f"Con(T_{k})")

    return {
        'known_consistency': known,
        'unknown_consistency': f"Con(T_{level})",
        'burden_count': len(known),
    }


def compute_limit_theory(hierarchy: List[ReflectiveTheory]) -> FrozenSet[int]:
    """Compute the limit theory T_ω = ⋃_n T_n."""
    result: Set[int] = set()
    for theory in hierarchy:
        result |= theory.provable
    return frozenset(result)


def soundness_gap_analysis(
    hierarchy: List[ReflectiveTheory],
    con_sentences: List[int],
    snd_sentences: List[int]
) -> List[Dict[str, bool]]:
    """Analyze the consistency-soundness gap at each level.

    For each level n, checks:
    - Is Con(T_n) provable at level n+1?
    - Is Sound(T_n) provable at level n+1?
    """
    results = []
    for n in range(len(hierarchy) - 1):
        con_at_next = con_sentences[n] in hierarchy[n + 1].provable
        snd_at_next = snd_sentences[n] in hierarchy[n + 1].provable
        results.append({
            'level': n,
            'con_provable_at_next': con_at_next,
            'snd_provable_at_next': snd_at_next,
            'gap_exists': con_at_next and not snd_at_next
        })
    return results


def oracle_power(theory: FrozenSet[int], universe_size: int) -> int:
    """Compute the oracle power: |T ∩ [0, N)|."""
    return len({s for s in theory if s < universe_size})


def power_growth_verification(
    hierarchy: List[ReflectiveTheory],
    universe_size: int
) -> List[Tuple[int, int, bool]]:
    """Verify that oracle power strictly increases at each level.

    Returns list of (level, power, is_strictly_greater_than_previous).
    """
    results = []
    for i, theory in enumerate(hierarchy):
        power = oracle_power(theory.provable, universe_size)
        growing = i == 0 or power > oracle_power(hierarchy[i - 1].provable, universe_size)
        results.append((i, power, growing))
    return results


def construct_concrete_hierarchy(
    base_size: int = 10,
    levels: int = 10
) -> Tuple[List[ReflectiveTheory], List[int], List[int]]:
    """Construct a concrete oracle hierarchy for demonstration.

    Returns (hierarchy, con_sentences, snd_sentences).
    """
    # True arithmetic: all sentences 0..base_size+2*levels
    truth = frozenset(range(base_size + 2 * levels))

    # Base theory: sentences 0..base_size-1
    base_provable = frozenset(range(base_size))
    base = ReflectiveTheory(provable=base_provable, true_sentences=truth)

    # Con(T_n) = base_size + n
    con_sentences = [base_size + n for n in range(levels)]

    # Sound(T_n) = base_size + levels + n (never added to any level)
    snd_sentences = [base_size + levels + n for n in range(levels)]

    # Jump: add Con(T_n) at level n+1
    hierarchy = [base]
    current_provable = set(base_provable)
    for n in range(levels):
        current_provable.add(con_sentences[n])
        new_theory = ReflectiveTheory(
            provable=frozenset(current_provable),
            true_sentences=truth
        )
        hierarchy.append(new_theory)

    return hierarchy, con_sentences, snd_sentences


# --- Main demonstration ---

if __name__ == "__main__":
    hierarchy, con_sents, snd_sents = construct_concrete_hierarchy(
        base_size=10, levels=8
    )

    print("=== Oracle Hierarchy (Concrete Construction) ===\n")
    for i, t in enumerate(hierarchy):
        print(f"Level {i}: |provable| = {len(t.provable)}, "
              f"sound = {t.is_sound()}, "
              f"complete = {t.is_complete()}, "
              f"|gap| = {len(t.incompleteness_gap())}")

    print(f"\nStrict hierarchy: {verify_strict_hierarchy(hierarchy)}")

    print("\n=== Knowledge Burden ===\n")
    for n in range(len(hierarchy)):
        burden = compute_knowledge_burden(hierarchy, con_sents, n)
        print(f"Level {n}: burden = {burden['burden_count']}, "
              f"unknown = {burden['unknown_consistency']}")

    print("\n=== Soundness Gap Analysis ===\n")
    gap_results = soundness_gap_analysis(hierarchy, con_sents, snd_sents)
    for r in gap_results:
        print(f"Level {r['level']}: Con at n+1 = {r['con_provable_at_next']}, "
              f"Snd at n+1 = {r['snd_provable_at_next']}, "
              f"gap = {r['gap_exists']}")

    print("\n=== Power Growth ===\n")
    power_results = power_growth_verification(hierarchy, universe_size=30)
    for level, power, growing in power_results:
        print(f"Level {level}: power = {power}, growing = {growing}")

    print("\n=== Limit Theory ===\n")
    limit = compute_limit_theory(hierarchy)
    print(f"|T_ω| = {len(limit)}")
    for n in range(len(hierarchy)):
        escape = limit - hierarchy[n].provable
        print(f"  |T_ω \\ T_{n}| = {len(escape)}")
