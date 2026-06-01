"""
Memory Algebra: Algorithms for Memory Systems

Implements the core algorithms from the memory algebra framework:
- Memory system encoding via monoid homomorphisms
- Confusion set computation
- Selective forgetting
- Capacity bound verification
"""

from typing import TypeVar, Generic, Callable, Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
from itertools import product
from collections import defaultdict
import math

T = TypeVar('T')


@dataclass
class MemorySystem(Generic[T]):
    """A memory system: monoid homomorphism from FreeMonoid(alphabet) to M.

    The encoding is specified by a generator map (where each alphabet symbol maps)
    and a monoid operation on M. The homomorphism extends uniquely from generators.
    """
    alphabet: List[str]
    identity: T
    mul: Callable[[T, T], T]
    generator_map: Dict[str, T]

    def encode(self, stream: List[str]) -> T:
        """Encode an experience stream to a memory state."""
        result = self.identity
        for symbol in stream:
            result = self.mul(result, self.generator_map[symbol])
        return result

    def is_confused(self, s: List[str], t: List[str]) -> bool:
        """Check if two streams map to the same memory state."""
        return self.encode(s) == self.encode(t)


def detect_confusion(ms: MemorySystem, max_length: int) -> Optional[Tuple[List[str], List[str]]]:
    """Find two distinct streams that map to the same memory state.

    Searches all streams up to max_length. Returns None if no confusion found.

    Time complexity: O(|alphabet|^max_length)
    """
    state_map: Dict = {}
    for k in range(max_length + 1):
        for seq_tuple in product(ms.alphabet, repeat=k):
            seq = list(seq_tuple)
            m = ms.encode(seq)
            key = repr(m)  # hashable representation
            if key in state_map and state_map[key] != seq:
                return (state_map[key], seq)
            state_map[key] = seq
    return None


def compute_confusion_set(ms: MemorySystem, max_length: int) -> Set[Tuple[Tuple[str, ...], Tuple[str, ...]]]:
    """Compute the confusion set for streams up to given length.

    Returns set of (s, t) pairs where s < t lexicographically and encode(s) = encode(t).
    """
    confusion: Set[Tuple[Tuple[str, ...], Tuple[str, ...]]] = set()
    # Group streams by their encoding
    encoding_groups: Dict[str, List[Tuple[str, ...]]] = defaultdict(list)

    for k in range(max_length + 1):
        for seq_tuple in product(ms.alphabet, repeat=k):
            m = ms.encode(list(seq_tuple))
            encoding_groups[repr(m)].append(seq_tuple)

    for group in encoding_groups.values():
        for i in range(len(group)):
            for j in range(i + 1, len(group)):
                confusion.add((group[i], group[j]))

    return confusion


def selective_forget(stream: List[str], forgotten_symbols: Set[str]) -> List[str]:
    """Apply selective forgetting: remove all symbols in the forgotten set.

    This implements the selective forgetting congruence from the theory.
    Two streams are equivalent iff selective_forget returns the same result.
    """
    return [s for s in stream if s not in forgotten_symbols]


def verify_submonoid_closure(
    ms: MemorySystem,
    confused_pairs: List[Tuple[List[str], List[str]]]
) -> bool:
    """Verify that the confusion set is closed under concatenation.

    For each pair of confused pairs (s1,t1) and (s2,t2), checks that
    (s1++s2, t1++t2) is also confused.
    """
    for (s1, t1) in confused_pairs:
        for (s2, t2) in confused_pairs:
            combined_s = s1 + s2
            combined_t = t1 + t2
            if not ms.is_confused(combined_s, combined_t):
                return False
    return True


def capacity_bound(alphabet_size: int, memory_size: int) -> int:
    """Compute maximum distinguishing length: floor(log_n(m)).

    Returns the maximum k such that n^k <= m, where n = alphabet_size, m = memory_size.
    """
    if alphabet_size <= 1 or memory_size <= 0:
        return 0
    return int(math.log(memory_size) / math.log(alphabet_size))


def confusion_class_sizes(ms: MemorySystem, length: int) -> Dict[str, int]:
    """Compute the size of each confusion class for streams of a given length.

    Returns a dictionary mapping memory state representations to the number
    of length-k streams mapping to that state.
    """
    class_sizes: Dict[str, int] = defaultdict(int)
    for seq_tuple in product(ms.alphabet, repeat=length):
        m = ms.encode(list(seq_tuple))
        class_sizes[repr(m)] += 1
    return dict(class_sizes)


# Modular arithmetic memory system factory
def modular_memory(alphabet: List[str], modulus: int,
                   generator_values: Dict[str, int]) -> MemorySystem[int]:
    """Create a memory system using Z/nZ as the memory monoid.

    Each alphabet symbol maps to an element of Z/nZ, and the monoid
    operation is addition modulo n.
    """
    return MemorySystem(
        alphabet=alphabet,
        identity=0,
        mul=lambda a, b: (a + b) % modulus,
        generator_map=generator_values
    )


def matrix_memory(alphabet: List[str], size: int,
                  generator_matrices: Dict[str, List[List[int]]],
                  modulus: int) -> MemorySystem[Tuple[Tuple[int, ...], ...]]:
    """Create a memory system using matrix multiplication over Z/nZ.

    More expressive than modular arithmetic — can capture non-commutative memory.
    """
    def mat_identity(n: int) -> Tuple[Tuple[int, ...], ...]:
        return tuple(
            tuple(1 if i == j else 0 for j in range(n))
            for i in range(n)
        )

    def mat_mul(a: Tuple[Tuple[int, ...], ...],
                b: Tuple[Tuple[int, ...], ...]) -> Tuple[Tuple[int, ...], ...]:
        n = len(a)
        return tuple(
            tuple(sum(a[i][k] * b[k][j] for k in range(n)) % modulus
                  for j in range(n))
            for i in range(n)
        )

    gen_map = {
        s: tuple(tuple(row) for row in m)
        for s, m in generator_matrices.items()
    }

    return MemorySystem(
        alphabet=alphabet,
        identity=mat_identity(size),
        mul=mat_mul,
        generator_map=gen_map
    )
