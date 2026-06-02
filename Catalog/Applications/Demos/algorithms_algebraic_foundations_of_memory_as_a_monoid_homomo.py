#!/usr/bin/env python3
"""
Algorithms for Memory Algebra.

Type-hinted implementations of the key algorithms from the research paper.
"""

from typing import (
    Callable, Dict, FrozenSet, Generic, List, Optional,
    Set, Tuple, TypeVar
)
from collections import defaultdict
from dataclasses import dataclass
from itertools import product


E = TypeVar('E')  # Experience type
S = TypeVar('S')  # State type


@dataclass
class MemorySystem(Generic[E, S]):
    """A memory system: monoid homomorphism from experiences to states.
    
    Attributes:
        encode: The encoding function (monoid homomorphism)
        identity_state: The identity element of the state monoid
        name: Human-readable name
    """
    encode: Callable[[E], S]
    identity_state: S
    name: str = ""


def compute_congruence_classes(
    mem: MemorySystem[E, S],
    experiences: List[E]
) -> Dict[S, List[E]]:
    """Compute the congruence classes of a memory system.
    
    Groups experiences by their image under the encoding.
    Time complexity: O(|experiences| * T_encode)
    
    Args:
        mem: The memory system
        experiences: List of experiences to classify
        
    Returns:
        Dictionary mapping each state to the list of experiences encoding to it
    """
    classes: Dict[S, List[E]] = defaultdict(list)
    for exp in experiences:
        classes[mem.encode(exp)].append(exp)
    return dict(classes)


def compute_kernel(
    mem: MemorySystem[E, S],
    experiences: List[E]
) -> Set[E]:
    """Compute the kernel of a memory system.
    
    Returns the set of experiences mapping to the identity state.
    Time complexity: O(|experiences| * T_encode)
    
    Args:
        mem: The memory system
        experiences: List of experiences to check
        
    Returns:
        Set of experiences in the kernel
    """
    return {exp for exp in experiences if mem.encode(exp) == mem.identity_state}


def check_refinement(
    mem1: MemorySystem[E, S],
    mem2: MemorySystem[E, S],
    experiences: List[E]
) -> Tuple[bool, Optional[Tuple[E, E]]]:
    """Check if mem1 refines mem2.
    
    mem1 refines mem2 iff whenever mem1 equates two experiences,
    mem2 also equates them.
    
    Time complexity: O(|experiences|^2 * (T_encode1 + T_encode2))
    
    Args:
        mem1: The potentially finer memory system
        mem2: The potentially coarser memory system
        experiences: List of experiences to check
        
    Returns:
        (True, None) if mem1 refines mem2
        (False, (e1, e2)) if counterexample found
    """
    # Group by mem1's encoding for efficiency
    classes1 = compute_congruence_classes(mem1, experiences)
    
    for state, class_members in classes1.items():
        # All members of this class must also be equated by mem2
        mem2_states = {mem2.encode(exp) for exp in class_members}
        if len(mem2_states) > 1:
            # Found a pair equated by mem1 but distinguished by mem2
            for i, e1 in enumerate(class_members):
                for e2 in class_members[i+1:]:
                    if mem2.encode(e1) != mem2.encode(e2):
                        return False, (e1, e2)
    return True, None


def compute_factoring_map(
    mem1: MemorySystem[E, S],
    mem2: MemorySystem[E, S],
    experiences: List[E]
) -> Optional[Dict[S, S]]:
    """Compute the factoring map f: S1 → S2 such that f ∘ encode1 = encode2.
    
    Requires that mem1 refines mem2.
    
    Time complexity: O(|experiences| * (T_encode1 + T_encode2))
    
    Args:
        mem1: The finer memory system (must be surjective on given experiences)
        mem2: The coarser memory system
        experiences: List of experiences
        
    Returns:
        Dictionary mapping states of mem1 to states of mem2, or None if
        mem1 does not refine mem2
    """
    factor_map: Dict[S, S] = {}
    
    for exp in experiences:
        s1 = mem1.encode(exp)
        s2 = mem2.encode(exp)
        
        if s1 in factor_map:
            if factor_map[s1] != s2:
                return None  # Not a valid refinement
        else:
            factor_map[s1] = s2
    
    return factor_map


def compute_compression_ratio(
    mem: MemorySystem[E, S],
    experiences: List[E]
) -> float:
    """Compute the compression ratio: |image| / |experiences|.
    
    A ratio of 1.0 means no compression (injective).
    A ratio close to 0 means heavy compression.
    
    Args:
        mem: The memory system
        experiences: List of experiences
        
    Returns:
        Compression ratio in [0, 1]
    """
    if not experiences:
        return 1.0
    image = {mem.encode(exp) for exp in experiences}
    return len(image) / len(experiences)


def compute_max_fiber_size(
    mem: MemorySystem[E, S],
    experiences: List[E]
) -> Tuple[int, S]:
    """Find the largest congruence class (fiber) and its state.
    
    Args:
        mem: The memory system
        experiences: List of experiences
        
    Returns:
        (max_size, state) where state has the largest fiber
    """
    classes = compute_congruence_classes(mem, experiences)
    max_state = max(classes, key=lambda s: len(classes[s]))
    return len(classes[max_state]), max_state


@dataclass
class TropicalMemoryState:
    """A tropical memory state with priority (max-plus monoid).
    
    Multiplication: max(a, b)
    Identity: -infinity (represented as float('-inf'))
    """
    priority: float
    
    def __mul__(self, other: 'TropicalMemoryState') -> 'TropicalMemoryState':
        return TropicalMemoryState(max(self.priority, other.priority))
    
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, TropicalMemoryState):
            return NotImplemented
        return self.priority == other.priority
    
    def __hash__(self) -> int:
        return hash(self.priority)
    
    def __repr__(self) -> str:
        return f"T({self.priority})"
    
    @staticmethod
    def identity() -> 'TropicalMemoryState':
        return TropicalMemoryState(float('-inf'))
    
    def is_idempotent(self) -> bool:
        """Verify a * a = a (tropical idempotence)."""
        return (self * self) == self


def build_refinement_lattice(
    memory_systems: List[MemorySystem[E, S]],
    experiences: List[E]
) -> List[Tuple[int, int]]:
    """Compute the refinement partial order on a list of memory systems.
    
    Returns edges (i, j) where system i refines system j.
    
    Args:
        memory_systems: List of memory systems
        experiences: List of experiences
        
    Returns:
        List of (i, j) pairs where system i refines system j
    """
    edges = []
    n = len(memory_systems)
    for i in range(n):
        for j in range(n):
            if i != j:
                refines, _ = check_refinement(
                    memory_systems[i], memory_systems[j], experiences
                )
                if refines:
                    edges.append((i, j))
    return edges


if __name__ == "__main__":
    # Example: compare memory systems on binary strings
    def gen_binary_strings(max_len: int) -> List[str]:
        strings = [""]
        for length in range(1, max_len + 1):
            for bits in product("01", repeat=length):
                strings.append("".join(bits))
        return strings
    
    experiences = gen_binary_strings(5)
    
    # Three memory systems with different granularity
    systems = [
        MemorySystem(lambda s: len(s) % 6, 0, "mod6"),
        MemorySystem(lambda s: len(s) % 3, 0, "mod3"),
        MemorySystem(lambda s: len(s) % 2, 0, "mod2"),
    ]
    
    print("Refinement lattice:")
    edges = build_refinement_lattice(systems, experiences)
    for i, j in edges:
        print(f"  {systems[i].name} refines {systems[j].name}")
    
    print("\nCompression ratios:")
    for sys in systems:
        ratio = compute_compression_ratio(sys, experiences)
        print(f"  {sys.name}: {ratio:.4f}")
    
    print("\nTropical idempotence check:")
    for p in [0, 1, 3.14, 100, -5]:
        state = TropicalMemoryState(p)
        print(f"  T({p}) * T({p}) = {state * state}, idempotent: {state.is_idempotent()}")
