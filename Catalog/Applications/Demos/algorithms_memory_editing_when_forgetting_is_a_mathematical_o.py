"""
Memory Algebra: Algorithms for Memory Systems

Type-hinted implementations of memory system operations including
encoding, collision detection, kernel pair computation, and
tropical memory valuation.
"""

from typing import List, Tuple, Dict, Set, Callable, Optional
from dataclasses import dataclass
from itertools import product as cart_product


@dataclass
class MemorySystem:
    """A memory system over a finite alphabet with finite state space.
    
    The encoding is specified by a transition function on generators
    (single-character experiences) and extended to all words by
    monoid homomorphism (concatenation maps to composition).
    """
    alphabet_size: int
    num_states: int
    # generator_images[a] = image of generator a in the state monoid
    # represented as a permutation/function table
    multiplication_table: List[List[int]]  # mult_table[i][j] = i * j
    generator_images: List[int]  # image of each alphabet symbol
    identity: int  # identity element index
    
    def encode_symbol(self, a: int) -> int:
        """Encode a single alphabet symbol."""
        return self.generator_images[a]
    
    def multiply(self, s1: int, s2: int) -> int:
        """Multiply two states in the monoid."""
        return self.multiplication_table[s1][s2]
    
    def encode(self, word: List[int]) -> int:
        """Encode an experience stream (word) to a memory state.
        
        This is the monoid homomorphism φ: FreeMonoid(α) → M.
        Time complexity: O(len(word)).
        """
        state = self.identity
        for symbol in word:
            state = self.multiply(state, self.generator_images[symbol])
        return state
    
    def find_collision(self, max_length: int = 100) -> Optional[Tuple[List[int], List[int]]]:
        """Find two distinct words with the same memory state.
        
        By the Lossy Memory Theorem, a collision must exist.
        By the Periodicity Collision Theorem, one exists among
        the first |M|+1 powers of any generator.
        """
        seen: Dict[int, List[int]] = {}
        # Check powers of first generator (guaranteed collision by periodicity)
        word: List[int] = []
        for length in range(self.num_states + 2):
            state = self.encode(word)
            if state in seen:
                return (seen[state], word.copy())
            seen[state] = word.copy()
            word.append(0)
        return None
    
    def kernel_pair_sample(self, max_length: int = 4) -> List[Tuple[List[int], List[int]]]:
        """Sample elements of the kernel pair (confused word pairs).
        
        Returns pairs (w1, w2) with w1 ≠ w2 and encode(w1) = encode(w2).
        """
        # Group words by their encoding
        state_to_words: Dict[int, List[List[int]]] = {}
        for length in range(max_length + 1):
            for word in cart_product(range(self.alphabet_size), repeat=length):
                w = list(word)
                state = self.encode(w)
                if state not in state_to_words:
                    state_to_words[state] = []
                state_to_words[state].append(w)
        
        # Extract pairs from groups with multiple words
        pairs = []
        for words in state_to_words.values():
            for i in range(len(words)):
                for j in range(i + 1, min(len(words), i + 3)):  # limit pairs
                    pairs.append((words[i], words[j]))
        return pairs[:20]  # return at most 20
    
    def discrimination_count(self, length: int) -> int:
        """Count the number of distinct memory states achieved by words of given length.
        
        By the Capacity Bound Theorem, this is at most num_states.
        """
        states: Set[int] = set()
        for word in cart_product(range(self.alphabet_size), repeat=length):
            states.add(self.encode(list(word)))
        return len(states)


@dataclass
class TropicalMemoryValuation:
    """A tropical memory valuation assigning forgetting costs to experiences."""
    costs: List[float]  # cost of each alphabet symbol
    threshold: float    # forgetting threshold
    
    def stream_cost(self, word: List[int]) -> float:
        """Compute the total forgetting cost of a word."""
        return sum(self.costs[a] for a in word)
    
    def is_forgettable(self, word: List[int]) -> bool:
        """Check if a word is forgettable (cost exceeds threshold)."""
        return self.stream_cost(word) >= self.threshold
    
    def memorable_words(self, alphabet_size: int, max_length: int) -> List[List[int]]:
        """Enumerate all memorable (non-forgettable) words up to given length."""
        result = []
        for length in range(max_length + 1):
            for word in cart_product(range(alphabet_size), repeat=length):
                w = list(word)
                if not self.is_forgettable(w):
                    result.append(w)
        return result


def make_modular_memory(k: int, n: int) -> MemorySystem:
    """Construct a memory system using modular addition (Z/nZ).
    
    This is a natural example where the monoid operation is
    addition modulo n, and generators map to 0, 1, ..., k-1 mod n.
    """
    mult_table = [[(i + j) % n for j in range(n)] for i in range(n)]
    generator_images = [i % n for i in range(k)]
    return MemorySystem(
        alphabet_size=k,
        num_states=n,
        multiplication_table=mult_table,
        generator_images=generator_images,
        identity=0
    )


def verify_kernel_submonoid(mem: MemorySystem, max_length: int = 3) -> bool:
    """Verify that the kernel pair is closed under the monoid operation.
    
    This is a computational check of the Information Loss Submonoid Theorem.
    """
    pairs = mem.kernel_pair_sample(max_length)
    for (w1, w2) in pairs:
        for (w3, w4) in pairs:
            # Check that (w1++w3, w2++w4) is also in the kernel
            concat1 = w1 + w3
            concat2 = w2 + w4
            if mem.encode(concat1) != mem.encode(concat2):
                return False
    return True


def collision_detection_algorithm(
    mem: MemorySystem
) -> Tuple[List[int], List[int]]:
    """
    Collision Detection Algorithm
    
    INPUT: A memory system (M, φ) with |M| = n states
    OUTPUT: Two distinct words w₁ ≠ w₂ with φ(w₁) = φ(w₂)
    
    ALGORITHM:
    1. Fix generator a = 0
    2. Compute φ(aⁱ) for i = 0, 1, ..., n
    3. By pigeonhole, find i ≠ j with φ(aⁱ) = φ(aʲ)
    4. Return (aⁱ, aʲ)
    
    COMPLEXITY: O(n) time, O(n) space
    CORRECTNESS: Guaranteed by Periodicity Collision Theorem
    """
    result = mem.find_collision()
    if result is None:
        raise RuntimeError("Bug: collision must exist by Lossy Memory Theorem")
    return result
