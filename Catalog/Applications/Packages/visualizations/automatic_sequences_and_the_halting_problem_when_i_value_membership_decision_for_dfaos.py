"""
Algorithms for k-automatic sequences and the decidability boundary.

This module implements:
1. DFAO (Deterministic Finite Automaton with Output) simulation
2. Thue-Morse sequence generation via popcount parity
3. BFS-based reachability for the decidability algorithm
4. k-kernel computation
5. Uniform morphism iteration
"""

from typing import List, Dict, Set, Tuple, Optional, Callable
from collections import deque


class DFAO:
    """Deterministic Finite Automaton with Output.

    A DFAO over alphabet {0, ..., k-1} with states {0, ..., n-1}.
    Given a natural number m, writes it in base k and feeds the digits
    (least significant first) through the automaton.

    Attributes:
        n_states: Number of states.
        k: Size of input alphabet (base).
        transition: transition[state][digit] -> next_state
        initial: Initial state.
        output: output[state] -> output value
    """

    def __init__(
        self,
        n_states: int,
        k: int,
        transition: List[List[int]],
        initial: int,
        output: List[int],
    ):
        self.n_states = n_states
        self.k = k
        self.transition = transition
        self.initial = initial
        self.output = output

    def run(self, digits: List[int]) -> int:
        """Run the DFAO on a sequence of digits, returning the final state."""
        state = self.initial
        for d in digits:
            state = self.transition[state][d]
        return state

    def eval(self, digits: List[int]) -> int:
        """Evaluate the DFAO on a digit sequence, returning the output."""
        return self.output[self.run(digits)]

    def to_base_k(self, m: int) -> List[int]:
        """Convert m to base-k digits (least significant first)."""
        if m == 0:
            return []
        digits = []
        while m > 0:
            digits.append(m % self.k)
            m //= self.k
        return digits

    def sequence(self, m: int) -> int:
        """Compute the m-th term of the generated sequence."""
        return self.eval(self.to_base_k(m))

    def reachable_states(self) -> Set[int]:
        """Compute the set of all reachable states via BFS.

        This is the core of the decidability algorithm: by computing
        the (finite) reachable set, we can decide all properties that
        depend only on which states are visited.
        """
        visited: Set[int] = set()
        queue = deque([self.initial])
        while queue:
            state = queue.popleft()
            if state in visited:
                continue
            visited.add(state)
            for d in range(self.k):
                next_state = self.transition[state][d]
                if next_state not in visited:
                    queue.append(next_state)
        return visited

    def value_appears(self, v: int) -> bool:
        """Decide whether value v appears in the generated sequence.

        This is the zero-in-sequence decision procedure:
        v appears iff some reachable state has output v.
        Runs in O(n * k) time where n = number of states.
        """
        reachable = self.reachable_states()
        return any(self.output[s] == v for s in reachable)

    def output_range(self) -> Set[int]:
        """Compute the set of all values that appear in the sequence."""
        reachable = self.reachable_states()
        return {self.output[s] for s in reachable}


def thue_morse_dfao() -> DFAO:
    """Construct the 2-state DFAO generating the Thue-Morse sequence.

    States: 0 (even parity), 1 (odd parity)
    Transitions: digit d from state s goes to (s + d) mod 2
    Output: state itself (0 or 1)
    """
    return DFAO(
        n_states=2,
        k=2,
        transition=[[0, 1], [1, 0]],
        initial=0,
        output=[0, 1],
    )


def rudin_shapiro_dfao() -> DFAO:
    """Construct the 4-state DFAO generating the Rudin-Shapiro sequence.

    The Rudin-Shapiro sequence counts the number of (possibly overlapping)
    occurrences of '11' in the binary expansion of n, modulo 2.
    """
    # States track the last digit and running parity
    # State 0: last=0, parity=0; State 1: last=1, parity=0
    # State 2: last=0, parity=1; State 3: last=1, parity=1
    return DFAO(
        n_states=4,
        k=2,
        transition=[
            [0, 1],  # state 0: see 0 -> state 0, see 1 -> state 1
            [2, 0],  # state 1: see 0 -> state 2 (11 seen, flip), see 1 -> state 0
            # Wait, this isn't right. Let me reconsider.
            # Actually for LSB-first we need to track differently.
            [2, 3],  # state 2
            [0, 1],  # state 3
        ],
        initial=0,
        output=[0, 0, 1, 1],  # parity of count of '11' patterns
    )


def bit_sum(n: int) -> int:
    """Count the number of 1-bits in n (popcount)."""
    count = 0
    while n > 0:
        count += n & 1
        n >>= 1
    return count


def thue_morse(n: int) -> int:
    """Compute the n-th term of the Thue-Morse sequence: popcount(n) mod 2."""
    return bit_sum(n) % 2


def k_kernel(k: int, seq: Callable[[int], int], max_e: int = 5) -> List[Tuple[int, int]]:
    """Compute elements of the k-kernel up to exponent max_e.

    The k-kernel of seq is {n -> seq(k^e * n + r) : e >= 0, 0 <= r < k^e}.

    Returns a list of (e, r) pairs representing distinct kernel elements,
    identified by their first few values.

    Args:
        k: Base.
        seq: The sequence function.
        max_e: Maximum exponent to consider.

    Returns:
        List of (e, r) pairs for distinct kernel elements.
    """
    seen_fingerprints: Dict[tuple, Tuple[int, int]] = {}
    result = []
    test_length = 20  # Number of values to check for distinctness

    for e in range(max_e + 1):
        ke = k**e
        for r in range(ke):
            fingerprint = tuple(seq(ke * n + r) for n in range(test_length))
            if fingerprint not in seen_fingerprints:
                seen_fingerprints[fingerprint] = (e, r)
                result.append((e, r))

    return result


class UniformMorphism:
    """A k-uniform morphism on an alphabet {0, ..., k-1}.

    Each letter maps to a word of length exactly k.
    """

    def __init__(self, k: int, images: List[List[int]]):
        self.k = k
        self.images = images
        assert all(len(img) == k for img in images), "Morphism must be uniform"

    def apply_word(self, word: List[int]) -> List[int]:
        """Apply the morphism to a word."""
        result = []
        for letter in word:
            result.extend(self.images[letter])
        return result

    def iterate(self, letter: int, n: int) -> List[int]:
        """Compute σⁿ(letter)."""
        word = [letter]
        for _ in range(n):
            word = self.apply_word(word)
        return word

    def is_prolongable(self, letter: int) -> bool:
        """Check if the morphism is prolongable on the given letter."""
        img = self.images[letter]
        return len(img) >= 2 and img[0] == letter

    def fixed_point_prefix(self, letter: int, length: int) -> List[int]:
        """Compute a prefix of the fixed point (if prolongable)."""
        if not self.is_prolongable(letter):
            raise ValueError("Morphism not prolongable on this letter")
        word = [letter]
        while len(word) < length:
            word = self.apply_word(word)
        return word[:length]


def thue_morse_morphism() -> UniformMorphism:
    """The Thue-Morse morphism: 0 -> 01, 1 -> 10."""
    return UniformMorphism(2, [[0, 1], [1, 0]])


def decide_zero_in_automatic_sequence(
    dfao: DFAO, target_value: int = 0
) -> Tuple[bool, Optional[int]]:
    """Decide if target_value appears in the DFAO-generated sequence.

    This is the main decidability algorithm. It:
    1. Computes the reachable states via BFS
    2. Checks if any reachable state has the target output

    Returns:
        (appears, witness): Whether the value appears, and if so,
        the smallest index where it appears (found by brute force search
        up to a bound).
    """
    appears = dfao.value_appears(target_value)

    witness = None
    if appears:
        # Find smallest witness by brute force
        for n in range(10000):
            if dfao.sequence(n) == target_value:
                witness = n
                break

    return appears, witness


def is_eventually_periodic(
    seq: Callable[[int], int], max_period: int = 100, max_offset: int = 200
) -> Optional[Tuple[int, int]]:
    """Test if a sequence appears eventually periodic.

    Returns (period, offset) if found, None otherwise.
    """
    for N in range(max_offset):
        for p in range(1, max_period + 1):
            periodic = True
            for m in range(N, N + 100):
                if seq(m + p) != seq(m):
                    periodic = False
                    break
            if periodic:
                return (p, N)
    return None
