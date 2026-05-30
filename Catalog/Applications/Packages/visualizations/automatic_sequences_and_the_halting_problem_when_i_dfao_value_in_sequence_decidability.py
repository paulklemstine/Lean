"""
Algorithms for Automatic Sequences and Decidability

Implements:
1. DFAO (Deterministic Finite Automaton with Output)
2. Base-k representation
3. Thue-Morse sequence
4. Zero-in-sequence decidability algorithm for DFAOs
5. Morphism iteration for morphic sequences
6. Kernel computation for automatic sequences
"""

from typing import List, Dict, Set, Tuple, Optional, Callable
from dataclasses import dataclass
from collections import deque


@dataclass
class DFAO:
    """Deterministic Finite Automaton with Output.
    
    Attributes:
        n_states: Number of states (states are 0..n_states-1)
        k: Alphabet size (digits are 0..k-1)
        transition: Dict mapping (state, digit) -> next_state
        initial: Initial state
        output: Dict mapping state -> output value
    """
    n_states: int
    k: int
    transition: Dict[Tuple[int, int], int]
    initial: int
    output: Dict[int, int]
    
    def run_from(self, state: int, digits: List[int]) -> int:
        """Run the DFAO from a given state on a sequence of digits."""
        s = state
        for d in digits:
            s = self.transition[(s, d)]
        return s
    
    def run(self, digits: List[int]) -> int:
        """Run the DFAO from the initial state."""
        return self.run_from(self.initial, digits)
    
    def eval(self, digits: List[int]) -> int:
        """Get the output for a given input sequence."""
        return self.output[self.run(digits)]
    
    def sequence(self, n: int) -> int:
        """Compute the n-th term of the generated sequence."""
        digits = to_base_k(n, self.k)
        return self.eval(digits)
    
    def reachable_states(self) -> Set[int]:
        """Compute the set of reachable states via BFS.
        
        Time complexity: O(n_states * k)
        Space complexity: O(n_states)
        """
        visited = {self.initial}
        queue = deque([self.initial])
        while queue:
            s = queue.popleft()
            for d in range(self.k):
                t = self.transition[(s, d)]
                if t not in visited:
                    visited.add(t)
                    queue.append(t)
        return visited
    
    def value_exists(self, target: int) -> bool:
        """Decide whether the target value appears in the generated sequence.
        
        This is the key decidability result: for automatic sequences,
        the zero-in-sequence problem is decidable.
        
        Algorithm: Compute reachable states, check if any maps to target.
        Time complexity: O(n_states * k)
        """
        reachable = self.reachable_states()
        return any(self.output[s] == target for s in reachable)
    
    def sequence_values(self) -> Set[int]:
        """Compute all values that appear in the generated sequence.
        
        Returns the set of output values of reachable states.
        """
        reachable = self.reachable_states()
        return {self.output[s] for s in reachable}


def to_base_k(n: int, k: int) -> List[int]:
    """Convert n to base-k representation (least significant digit first).
    
    Args:
        n: Non-negative integer
        k: Base (k >= 2)
    
    Returns:
        List of digits in base k, LSB first. Empty list for n=0.
    """
    if n == 0:
        return []
    digits = []
    while n > 0:
        digits.append(n % k)
        n //= k
    return digits


def from_base_k(digits: List[int], k: int) -> int:
    """Convert base-k digits (LSB first) to integer."""
    result = 0
    for i, d in enumerate(digits):
        result += d * (k ** i)
    return result


def bit_sum(n: int) -> int:
    """Count the number of 1-bits in n (popcount)."""
    count = 0
    while n > 0:
        count += n & 1
        n >>= 1
    return count


def thue_morse(n: int) -> int:
    """Compute the n-th term of the Thue-Morse sequence.
    
    t(n) = popcount(n) mod 2
    
    Properties:
    - t(2n) = t(n)
    - t(2n+1) = 1 - t(n)
    - Not eventually periodic
    """
    return bit_sum(n) % 2


def thue_morse_dfao() -> DFAO:
    """Construct the 2-state DFAO that generates the Thue-Morse sequence.
    
    States: {0, 1} (representing current parity of bit sum)
    Alphabet: {0, 1} (binary digits)
    Transitions:
      - (0, 0) -> 0 (adding a 0-bit doesn't change parity)
      - (0, 1) -> 1 (adding a 1-bit flips parity)
      - (1, 0) -> 1
      - (1, 1) -> 0
    Initial: 0
    Output: identity (state IS the output)
    """
    return DFAO(
        n_states=2,
        k=2,
        transition={(0, 0): 0, (0, 1): 1, (1, 0): 1, (1, 1): 0},
        initial=0,
        output={0: 0, 1: 1}
    )


def rudin_shapiro_dfao() -> DFAO:
    """Construct the DFAO for the Rudin-Shapiro sequence.
    
    The Rudin-Shapiro sequence counts the number of (possibly overlapping)
    occurrences of '11' in the binary representation of n, modulo 2.
    
    States: {0, 1, 2, 3}
    - State encodes (last_digit, current_parity)
    """
    return DFAO(
        n_states=4,
        k=2,
        transition={
            (0, 0): 0, (0, 1): 1,  # saw 0, parity 0 -> read 0/1
            (1, 0): 2, (1, 1): 3,  # saw 1, parity 0 -> read 0/1 (11 flips)
            (2, 0): 0, (2, 1): 1,  # saw 0, parity 1
            (3, 0): 2, (3, 1): 1,  # saw 1, parity 1 -> read 0/read 1(11 flips back)
        },
        initial=0,
        output={0: 0, 1: 0, 2: 1, 3: 1}  # output is the parity component
    )


@dataclass
class Morphism:
    """A morphism on a finite alphabet.
    
    Maps each letter to a word (list of letters).
    """
    k: int  # alphabet size
    image: Dict[int, List[int]]  # letter -> word
    
    def apply_word(self, word: List[int]) -> List[int]:
        """Apply the morphism to a word."""
        result = []
        for letter in word:
            result.extend(self.image[letter])
        return result
    
    def iterate(self, letter: int, n: int) -> List[int]:
        """Compute σ^n(letter)."""
        word = [letter]
        for _ in range(n):
            word = self.apply_word(word)
        return word
    
    def is_uniform(self) -> bool:
        """Check if the morphism is k-uniform (all images have length k)."""
        return all(len(self.image[a]) == self.k for a in range(self.k))
    
    def is_prolongable(self, letter: int) -> bool:
        """Check if the morphism is prolongable on the given letter."""
        img = self.image[letter]
        return len(img) >= 2 and img[0] == letter


def thue_morse_morphism() -> Morphism:
    """The Thue-Morse morphism: 0 -> 01, 1 -> 10."""
    return Morphism(k=2, image={0: [0, 1], 1: [1, 0]})


def compute_k_kernel(seq_func: Callable[[int], int], k: int, 
                      max_e: int = 5, max_check: int = 20) -> List[Tuple[int, int, List[int]]]:
    """Compute representative elements of the k-kernel of a sequence.
    
    Returns list of (e, r, values) where values = [seq(k^e * m + r) for m in range(max_check)].
    Groups kernel elements by their value patterns.
    
    Args:
        seq_func: The sequence function
        k: The base
        max_e: Maximum exponent to check
        max_check: Number of values to check for each kernel element
    """
    seen_patterns: Dict[tuple, Tuple[int, int]] = {}
    kernel_elements = []
    
    for e in range(max_e + 1):
        ke = k ** e
        for r in range(ke):
            values = [seq_func(ke * m + r) for m in range(max_check)]
            pattern = tuple(values)
            if pattern not in seen_patterns:
                seen_patterns[pattern] = (e, r)
                kernel_elements.append((e, r, values))
    
    return kernel_elements


def zero_in_sequence_bfs(dfao: DFAO, target: int) -> Optional[int]:
    """Find the smallest n such that the DFAO sequence has value target at n.
    
    Uses BFS on the state graph to find the shortest path to a state
    with the target output, then converts the path to a number.
    
    Returns None if no such n exists.
    
    Time complexity: O(n_states * k)
    """
    if dfao.output[dfao.initial] == target:
        return 0
    
    # BFS to find shortest path to target output
    visited = {dfao.initial}
    queue = deque([(dfao.initial, [])])  # (state, path of digits)
    
    while queue:
        state, path = queue.popleft()
        for d in range(dfao.k):
            next_state = dfao.transition[(state, d)]
            if next_state not in visited:
                new_path = path + [d]
                if dfao.output[next_state] == target:
                    # Convert path to number
                    return from_base_k(new_path, dfao.k)
                visited.add(next_state)
                queue.append((next_state, new_path))
    
    return None  # Target not reachable


if __name__ == "__main__":
    # Demo: Thue-Morse sequence
    print("Thue-Morse sequence (first 32 terms):")
    print([thue_morse(n) for n in range(32)])
    
    # Verify DFAO generates same sequence
    tm_dfao = thue_morse_dfao()
    print("\nDFAO verification:")
    assert all(tm_dfao.sequence(n) == thue_morse(n) for n in range(1000))
    print("✓ DFAO matches direct computation for n=0..999")
    
    # Decidability demo
    print("\nDecidability of value-in-sequence:")
    print(f"  Does 0 appear? {tm_dfao.value_exists(0)} (found at n={zero_in_sequence_bfs(tm_dfao, 0)})")
    print(f"  Does 1 appear? {tm_dfao.value_exists(1)} (found at n={zero_in_sequence_bfs(tm_dfao, 1)})")
    print(f"  Does 2 appear? {tm_dfao.value_exists(2)}")
    
    # Kernel computation
    print("\nThue-Morse 2-kernel (distinct subsequences):")
    kernel = compute_k_kernel(thue_morse, 2, max_e=4, max_check=10)
    print(f"  Number of distinct kernel elements: {len(kernel)}")
    for e, r, vals in kernel:
        print(f"  (e={e}, r={r}): {vals[:10]}")
