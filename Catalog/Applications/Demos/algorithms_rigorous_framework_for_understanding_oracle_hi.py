#!/usr/bin/env python3
"""
Algorithms for Reflective Oracle Hierarchies

Type-hinted implementations of the core algorithms:
1. ReflectiveHierarchy construction
2. Frontier tracking
3. Soundness deficit computation
4. Gap transfer analysis
"""

from dataclasses import dataclass, field
from typing import Callable, Set, List, Dict, Tuple, Optional


@dataclass
class ReflectiveTheory:
    """A formal theory with provability and truth predicates."""
    sentences: Set[int]
    provable: Set[int]
    true_set: Set[int]
    bot: int
    
    def is_sound(self) -> bool:
        """Check if everything provable is true."""
        return self.provable.issubset(self.true_set)
    
    def is_complete(self) -> bool:
        """Check if everything true is provable."""
        return self.true_set.issubset(self.provable)
    
    def is_consistent(self) -> bool:
        """Check if bot is not provable."""
        return self.bot not in self.provable
    
    def soundness_gap(self) -> Set[int]:
        """Sentences provable but not true."""
        return self.provable - self.true_set
    
    def completeness_gap(self) -> Set[int]:
        """Sentences true but not provable."""
        return self.true_set - self.provable


@dataclass
class ReflectiveHierarchy:
    """An ℕ-indexed tower of reflective theories."""
    witness_fn: Callable[[int], int]
    bot: int
    max_sentence: int = 100
    
    def _true_set(self) -> Set[int]:
        """The set of true sentences (all witnesses)."""
        return {self.witness_fn(k) for k in range(self.max_sentence)}
    
    def _provable_at(self, n: int) -> Set[int]:
        """Sentences provable at level n."""
        return {self.witness_fn(k) for k in range(n)}
    
    def con_sentence(self, n: int) -> int:
        """The consistency sentence for level n."""
        return self.witness_fn(n)
    
    def theory_at(self, n: int) -> ReflectiveTheory:
        """Extract the theory at level n."""
        sentences = set(range(self.max_sentence))
        return ReflectiveTheory(
            sentences=sentences,
            provable=self._provable_at(n),
            true_set=self._true_set(),
            bot=self.bot
        )
    
    def verify_consistency_one_jump(self, n: int) -> bool:
        """Verify Con(n) is unprovable at n but provable at n+1."""
        con_n = self.con_sentence(n)
        return (con_n not in self._provable_at(n) and 
                con_n in self._provable_at(n + 1))
    
    def completeness_gap_at(self, n: int) -> Set[int]:
        """True sentences unprovable at level n."""
        return self._true_set() - self._provable_at(n)
    
    def frontier_at(self, n: int) -> Dict[str, object]:
        """Analyze the frontier of ignorance at level n."""
        gap = self.completeness_gap_at(n)
        con_n = self.con_sentence(n)
        
        resolved_from_prev = set()
        if n > 0:
            prev_gap = self.completeness_gap_at(n - 1)
            resolved_from_prev = prev_gap - gap
        
        new_in_gap = set()
        if n > 0:
            prev_gap = self.completeness_gap_at(n - 1)
            new_in_gap = gap - prev_gap
        
        return {
            'level': n,
            'gap_size': len(gap),
            'con_in_gap': con_n in gap,
            'resolved': resolved_from_prev,
            'new_entries': new_in_gap,
        }


def build_hierarchy(witness_fn: Callable[[int], int], bot: int, 
                    max_sentence: int = 100) -> ReflectiveHierarchy:
    """
    Build a reflective hierarchy from a witness function.
    
    Algorithm:
    1. Define sentences as natural numbers up to max_sentence
    2. Define truth as membership in the witness function's range
    3. Define provability at level n as witnesses with index < n
    4. Verify all structural axioms
    
    Args:
        witness_fn: Injective function ℕ → ℕ giving consistency sentences
        bot: A sentence not in the range of witness_fn
        max_sentence: Upper bound on sentence enumeration
    
    Returns:
        A ReflectiveHierarchy with verified structural properties
    """
    H = ReflectiveHierarchy(witness_fn=witness_fn, bot=bot, 
                            max_sentence=max_sentence)
    
    # Verify structural properties
    for n in range(min(10, max_sentence)):
        assert H.verify_consistency_one_jump(n), \
            f"Consistency one-jump failed at level {n}"
        
        T_n = H.theory_at(n)
        assert T_n.is_consistent(), f"Inconsistency at level {n}"
        assert not T_n.is_complete(), f"Unexpected completeness at level {n}"
    
    return H


def compute_soundness_deficit(H: ReflectiveHierarchy, 
                               num_levels: int = 10) -> List[int]:
    """
    Compute the soundness deficit at each level.
    
    The deficit at level n is the number of true-but-unprovable sentences.
    
    Algorithm:
    1. For each level n, compute the completeness gap
    2. Record gap sizes
    3. Return the deficit sequence
    
    Args:
        H: A reflective hierarchy
        num_levels: Number of levels to analyze
    
    Returns:
        List of deficit values [deficit(0), deficit(1), ..., deficit(num_levels-1)]
    """
    deficits = []
    for n in range(num_levels):
        gap = H.completeness_gap_at(n)
        deficits.append(len(gap))
    return deficits


def analyze_gap_transfer(H: ReflectiveHierarchy, n: int) -> Dict[str, object]:
    """
    Analyze the gap transfer from level n to level n+1.
    
    Algorithm:
    1. Compute completeness gap at level n
    2. Compute completeness gap at level n+1
    3. Identify transferred (resolved) and new gap elements
    4. Verify Con(n) transfers out and Con(n+1) transfers in
    
    Returns:
        Dictionary with transfer analysis
    """
    gap_n = H.completeness_gap_at(n)
    gap_n1 = H.completeness_gap_at(n + 1)
    
    resolved = gap_n - gap_n1  # Were in gap at n, no longer at n+1
    persistent = gap_n & gap_n1  # In gap at both levels
    new_entries = gap_n1 - gap_n  # New entries at n+1
    
    con_n = H.con_sentence(n)
    con_n1 = H.con_sentence(n + 1)
    
    return {
        'level': n,
        'gap_n_size': len(gap_n),
        'gap_n1_size': len(gap_n1),
        'resolved_count': len(resolved),
        'persistent_count': len(persistent),
        'new_count': len(new_entries),
        'con_n_resolved': con_n in resolved,
        'con_n1_new': con_n1 in gap_n1,
    }


def hierarchy_speedup_analysis(H: ReflectiveHierarchy, 
                                num_levels: int = 10) -> List[Dict]:
    """
    Analyze the speed-up phenomenon across the hierarchy.
    
    For each level n, identifies Con(n) and checks:
    - Proof length at level n (0, since unprovable)
    - Proof length at level n+1 (positive, since provable)
    - The "speed-up factor" (∞ → finite)
    
    Returns:
        List of speed-up analysis dictionaries
    """
    results = []
    for n in range(num_levels):
        con_n = H.con_sentence(n)
        provable_at_n = con_n in H._provable_at(n)
        provable_at_n1 = con_n in H._provable_at(n + 1)
        
        results.append({
            'level': n,
            'con_sentence': con_n,
            'provable_at_own_level': provable_at_n,
            'provable_at_next_level': provable_at_n1,
            'speedup': 'infinite → finite' if not provable_at_n and provable_at_n1 else 'none',
        })
    return results


if __name__ == "__main__":
    # Build the standard hierarchy
    H = build_hierarchy(
        witness_fn=lambda k: 2 * k + 1,
        bot=0,
        max_sentence=200
    )
    
    print("Reflective Hierarchy constructed successfully.")
    print()
    
    # Soundness deficit
    deficits = compute_soundness_deficit(H, 15)
    print(f"Soundness deficits: {deficits}")
    print()
    
    # Gap transfer analysis
    for n in range(5):
        analysis = analyze_gap_transfer(H, n)
        print(f"Gap transfer {n} → {n+1}: {analysis}")
    print()
    
    # Speed-up analysis
    speedups = hierarchy_speedup_analysis(H, 8)
    for s in speedups:
        print(f"Speed-up at level {s['level']}: {s['speedup']}")
