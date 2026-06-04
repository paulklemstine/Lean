"""
Algorithms for automatic sequences and decidability.

Implements DFAOs, k-automatic sequence generation, k-kernel computation,
and the zero-in-sequence decision procedure.
"""

from typing import List, Dict, Set, Tuple, Optional, Callable
from dataclasses import dataclass


@dataclass
class DFAO:
    """Deterministic Finite Automaton with Output.

    Attributes:
        states: Number of states (states are 0..states-1)
        k: Base / alphabet size
        transition: transition[s][d] = next state
        initial: Initial state
        output: output[s] = output value at state s
    """
    states: int
    k: int
    transition: List[List[int]]
    initial: int
    output: List[int]

    def run(self, word: List[int]) -> int:
        """Run the DFAO on a word, returning the final state."""
        s = self.initial
        for d in word:
            s = self.transition[s][d]
        return s

    def eval(self, word: List[int]) -> int:
        """Evaluate the DFAO on a word, returning the output."""
        return self.output[self.run(word)]

    def to_base_k(self, n: int) -> List[int]:
        """Convert n to base-k digits (least significant first)."""
        if n == 0:
            return []
        digits = []
        while n > 0:
            digits.append(n % self.k)
            n //= self.k
        return digits

    def sequence(self, n: int) -> int:
        """Get the n-th element of the generated sequence."""
        return self.eval(self.to_base_k(n))

    def reachable_states(self) -> Set[int]:
        """Compute the set of reachable states via BFS."""
        visited: Set[int] = {self.initial}
        frontier: List[int] = [self.initial]
        while frontier:
            next_frontier: List[int] = []
            for s in frontier:
                for d in range(self.k):
                    t = self.transition[s][d]
                    if t not in visited:
                        visited.add(t)
                        next_frontier.append(t)
            frontier = next_frontier
        return visited

    def output_values(self) -> Set[int]:
        """Compute the set of output values for reachable states."""
        return {self.output[s] for s in self.reachable_states()}

    def zero_in_sequence(self, target: int = 0) -> bool:
        """Decide whether the target value appears in the sequence.

        This is the zero-in-sequence decision procedure.
        For k-automatic sequences, this is always decidable.
        """
        return target in self.output_values()


def thue_morse_dfao() -> DFAO:
    """The Thue-Morse DFAO: 2 states, base 2.

    State 0: even popcount (output 0)
    State 1: odd popcount (output 1)
    """
    return DFAO(
        states=2,
        k=2,
        transition=[[0, 1], [1, 0]],
        initial=0,
        output=[0, 1]
    )


def rudin_shapiro_dfao() -> DFAO:
    """The Rudin-Shapiro DFAO: 4 states, base 2.

    Counts overlapping 11 pairs in binary representation modulo 2.
    """
    return DFAO(
        states=4,
        k=2,
        transition=[[0, 1], [2, 3], [0, 1], [2, 3]],
        initial=0,
        output=[1, 1, 1, -1]
    )


def paperfolding_dfao() -> DFAO:
    """The regular paperfolding sequence DFAO: 4 states, base 2."""
    return DFAO(
        states=4,
        k=2,
        transition=[[1, 2], [3, 0], [3, 0], [1, 2]],
        initial=0,
        output=[0, 1, 0, 0]
    )


def compute_k_kernel(seq: Callable[[int], int], k: int,
                     max_e: int = 5, max_check: int = 100) -> List[Tuple[int, int]]:
    """Compute the k-kernel of a sequence up to depth max_e.

    Returns list of (e, r) pairs representing distinct subsequences
    n -> seq(k^e * n + r).
    """
    seen_sigs: Dict[tuple, Tuple[int, int]] = {}
    kernel_elements: List[Tuple[int, int]] = []

    for e in range(max_e + 1):
        ke = k ** e
        for r in range(ke):
            sig = tuple(seq(ke * n + r) for n in range(max_check))
            if sig not in seen_sigs:
                seen_sigs[sig] = (e, r)
                kernel_elements.append((e, r))

    return kernel_elements


def product_dfao(m1: DFAO, m2: DFAO) -> DFAO:
    """Construct the product DFAO of two DFAOs with the same base k.

    The product DFAO runs both automata simultaneously, producing
    paired output (encoded as m1.output * max_out2 + m2.output).
    """
    assert m1.k == m2.k
    k = m1.k
    n1, n2 = m1.states, m2.states
    states = n1 * n2

    transition = [[0] * k for _ in range(states)]
    output = [0] * states

    for s1 in range(n1):
        for s2 in range(n2):
            s = s1 * n2 + s2
            for d in range(k):
                t1 = m1.transition[s1][d]
                t2 = m2.transition[s2][d]
                transition[s][d] = t1 * n2 + t2
            output[s] = (m1.output[s1], m2.output[s2])

    return DFAO(
        states=states,
        k=k,
        transition=transition,
        initial=m1.initial * n2 + m2.initial,
        output=output
    )


class AlphabetMorphism:
    """A morphism on a finite alphabet."""

    def __init__(self, images: Dict[int, List[int]]):
        self.images = images
        self.alphabet_size = len(images)

    def apply_word(self, word: List[int]) -> List[int]:
        """Apply the morphism to a word."""
        result = []
        for letter in word:
            result.extend(self.images[letter])
        return result

    def iterate(self, start: int, n: int) -> List[int]:
        """Apply the morphism n times starting from a single letter."""
        word = [start]
        for _ in range(n):
            word = self.apply_word(word)
        return word

    def is_prolongable(self, a: int) -> bool:
        """Check if the morphism is prolongable on letter a."""
        img = self.images[a]
        return len(img) >= 2 and img[0] == a

    def is_uniform(self, target_len: Optional[int] = None) -> bool:
        """Check if the morphism is k-uniform."""
        lengths = [len(v) for v in self.images.values()]
        if target_len is not None:
            return all(l == target_len for l in lengths)
        return len(set(lengths)) <= 1

    def zero_in_morphic_word(self, start: int, target: int,
                             max_iterations: int = 1000000) -> Optional[bool]:
        """Attempt to decide if target appears in the fixed point.

        Returns True if found, False if provably absent, None if undecided.
        For uniform morphisms, always terminates.
        """
        if not self.is_prolongable(start):
            return None

        seen_letters: Set[int] = set()
        frontier: Set[int] = {start}

        while frontier:
            if target in frontier:
                return True
            new_frontier: Set[int] = set()
            for letter in frontier:
                for c in self.images[letter]:
                    if c not in seen_letters:
                        seen_letters.add(c)
                        new_frontier.add(c)
            frontier = new_frontier

        return target not in seen_letters


def thue_morse_morphism() -> AlphabetMorphism:
    """The Thue-Morse morphism: 0 -> 01, 1 -> 10."""
    return AlphabetMorphism({0: [0, 1], 1: [1, 0]})


def fibonacci_morphism() -> AlphabetMorphism:
    """The Fibonacci morphism: 0 -> 01, 1 -> 0."""
    return AlphabetMorphism({0: [0, 1], 1: [0]})
