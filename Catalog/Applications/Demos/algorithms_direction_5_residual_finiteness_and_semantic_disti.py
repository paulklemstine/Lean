#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for free group semantic separation.

Implements the mathematical algorithms described in the research paper:
1. Free group word reduction (Dehn's algorithm)
2. Stallings automaton construction for permutation representations
3. Bounded test suite generation
4. Separation profile computation

All algorithms are backed by the formally verified theorems in the Lean development.
"""

import itertools
from typing import Optional
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════════════════
# Data Structures
# ═══════════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class Letter:
    """A letter in the free group: generator with sign."""
    gen: str
    positive: bool

    def inverse(self) -> 'Letter':
        return Letter(self.gen, not self.positive)

    def __repr__(self):
        return self.gen if self.positive else f"{self.gen}⁻¹"


@dataclass
class FreeGroupWord:
    """A reduced word in the free group."""
    letters: list[Letter]

    @staticmethod
    def identity() -> 'FreeGroupWord':
        return FreeGroupWord([])

    @staticmethod
    def generator(g: str) -> 'FreeGroupWord':
        return FreeGroupWord([Letter(g, True)])

    @staticmethod
    def from_string(s: str) -> 'FreeGroupWord':
        """Parse 'aba^-1b^-1' into a FreeGroupWord."""
        letters = []
        i = 0
        while i < len(s):
            if s[i].isalpha():
                gen = s[i]
                if i + 3 < len(s) and s[i+1:i+4] == '^-1':
                    letters.append(Letter(gen, False))
                    i += 4
                elif i + 2 < len(s) and s[i+1:i+3] == '-1':
                    letters.append(Letter(gen, False))
                    i += 3
                else:
                    letters.append(Letter(gen, True))
                    i += 1
            else:
                i += 1
        return FreeGroupWord(letters).reduce()

    def reduce(self) -> 'FreeGroupWord':
        """Reduce the word by canceling adjacent inverse pairs.

        Time complexity: O(n) where n = len(self.letters)
        Space complexity: O(n)

        This implements Dehn's algorithm for free group word reduction.
        The result is the unique reduced representative of the equivalence class.
        """
        stack: list[Letter] = []
        for letter in self.letters:
            if stack and stack[-1].gen == letter.gen and stack[-1].positive != letter.positive:
                stack.pop()
            else:
                stack.append(letter)
        return FreeGroupWord(stack)

    def multiply(self, other: 'FreeGroupWord') -> 'FreeGroupWord':
        """Multiply two words and reduce. O(n + m) time."""
        return FreeGroupWord(self.letters + other.letters).reduce()

    def invert(self) -> 'FreeGroupWord':
        """Invert the word. O(n) time."""
        return FreeGroupWord([l.inverse() for l in reversed(self.letters)])

    @property
    def length(self) -> int:
        return len(self.letters)

    @property
    def is_identity(self) -> bool:
        return len(self.letters) == 0

    @property
    def generators_used(self) -> set[str]:
        return {l.gen for l in self.letters}

    def __eq__(self, other):
        if not isinstance(other, FreeGroupWord):
            return False
        return self.letters == other.letters

    def __hash__(self):
        return hash(tuple(self.letters))

    def __repr__(self):
        if not self.letters:
            return "1"
        return "".join(str(l) for l in self.letters)


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 1: Stallings Automaton Construction
# ═══════════════════════════════════════════════════════════════════════════

@dataclass
class StallingsAutomaton:
    """The Stallings automaton for a free group word.

    For a reduced word w of length L, the automaton has L+1 states (vertices)
    and L edges, one for each letter of w. The edges trace a path from
    state 0 to state L.

    The automaton produces a permutation representation:
        φ : generators → Perm(Fin(L+1))
    such that the composition of permutations according to w maps state 0
    to state L, proving w ≠ 1 in the image.
    """
    word: FreeGroupWord
    n_states: int
    # For each generator: partial permutation data
    forward_edges: dict[str, dict[int, int]]  # gen -> {source -> target}
    backward_edges: dict[str, dict[int, int]]  # gen -> {target -> source}

    @staticmethod
    def build(word: FreeGroupWord) -> 'StallingsAutomaton':
        """Build the Stallings automaton for a reduced word.

        Time complexity: O(L) where L = word.length
        Space complexity: O(L)

        The construction creates L+1 vertices and L directed edges.
        For each letter (gen, positive) at position i (0-indexed) in the
        REVERSED word:
        - If positive: generator gen maps vertex i → i+1
        - If negative: generator gen maps vertex i+1 → i

        The forward_edges dict stores the partial permutation for each
        generator (source → target for the generator, NOT its inverse).
        """
        L = word.length
        n_states = L + 1
        forward_edges: dict[str, dict[int, int]] = {}
        backward_edges: dict[str, dict[int, int]] = {}

        # Process reversed word to get correct vertex numbering
        reversed_letters = list(reversed(word.letters))
        for i, letter in enumerate(reversed_letters):
            gen = letter.gen
            if gen not in forward_edges:
                forward_edges[gen] = {}
                backward_edges[gen] = {}
            if letter.positive:
                # gen maps i → i+1
                forward_edges[gen][i] = i + 1
            else:
                # gen⁻¹ maps i → i+1, so gen maps i+1 → i
                forward_edges[gen][i + 1] = i

        return StallingsAutomaton(
            word=word,
            n_states=n_states,
            forward_edges=forward_edges,
            backward_edges=backward_edges,
        )

    def extend_to_permutation(self, gen: str) -> list[int]:
        """Extend the partial permutation for generator `gen` to a full permutation.

        Time complexity: O(n_states)

        Uses a greedy matching: vertices not in the partial function's domain
        are matched to vertices not in its range, preserving injectivity.
        """
        n = self.n_states
        perm = list(range(n))  # Start with identity

        # The forward_edges dict gives the partial permutation for gen
        # (source → target for the generator itself)
        partial = self.forward_edges.get(gen, {})

        # Apply the partial function
        used_sources = set(partial.keys())
        used_targets = set(partial.values())

        # Remaining vertices (not in domain or range)
        free_sources = [i for i in range(n) if i not in used_sources]
        free_targets = [i for i in range(n) if i not in used_targets]

        # For reduced words, the partial function is injective,
        # so domain and range have equal size
        assert len(free_sources) == len(free_targets), \
            f"Mismatch for gen={gen}: free_sources={free_sources}, free_targets={free_targets}, partial={partial}"
        extension = dict(zip(free_sources, free_targets))

        # Build full permutation
        for src, tgt in partial.items():
            perm[src] = tgt
        for src, tgt in extension.items():
            perm[src] = tgt

        return perm

    def to_representation(self, generators: list[str]) -> dict[str, list[int]]:
        """Convert the automaton to a permutation representation.

        Returns φ : generators → Perm(Fin(n_states))

        Time complexity: O(|generators| * n_states)
        """
        phi = {}
        for gen in generators:
            phi[gen] = self.extend_to_permutation(gen)
        return phi


def stallings_separator(word: FreeGroupWord,
                        generators: list[str]) -> Optional[dict[str, list[int]]]:
    """Construct a Stallings permutation representation separating word from identity.

    Time complexity: O(L * |generators|) where L = word.length
    Space complexity: O(L * |generators|)

    Returns None if word is identity, otherwise returns φ : generators → S_{L+1}
    such that φ(word) ≠ identity.
    """
    if word.is_identity:
        return None
    automaton = StallingsAutomaton.build(word)
    return automaton.to_representation(generators)


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 2: Brute-Force Separation Search
# ═══════════════════════════════════════════════════════════════════════════

def brute_force_separator(w1: FreeGroupWord,
                          w2: FreeGroupWord,
                          generators: list[str],
                          max_k: int = 8) -> Optional[tuple[int, dict[str, list[int]]]]:
    """Find the smallest k and assignment φ : generators → S_k separating w1 from w2.

    Time complexity: O(Σ_{k=2}^{max_k} (k!)^|generators| * k * max(|w1|, |w2|))
    Space complexity: O(k * |generators|)

    This is exponential but exhaustive: it is guaranteed to find the minimum k
    if one exists within the search range.
    """
    for k in range(2, max_k + 1):
        perms = list(itertools.permutations(range(k)))
        for assignment in itertools.product(perms, repeat=len(generators)):
            phi = {g: list(p) for g, p in zip(generators, assignment)}
            v1 = _eval_word_perm(w1, phi, k)
            v2 = _eval_word_perm(w2, phi, k)
            if v1 != v2:
                return k, phi
    return None


def _eval_word_perm(word: FreeGroupWord,
                    phi: dict[str, list[int]],
                    k: int) -> list[int]:
    """Evaluate a word as a permutation under assignment phi."""
    result = list(range(k))
    for letter in word.letters:
        p = phi.get(letter.gen, list(range(k)))
        if not letter.positive:
            p = _invert_perm(p)
        result = _compose_perm(p, result)
    return result


def _compose_perm(p: list[int], q: list[int]) -> list[int]:
    return [p[q[i]] for i in range(len(p))]


def _invert_perm(p: list[int]) -> list[int]:
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return inv


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 3: Bounded Test Suite Generation
# ═══════════════════════════════════════════════════════════════════════════

@dataclass
class TestSuite:
    """A finite test suite for semantic separation up to a given word length."""
    tests: list[tuple[int, dict[str, list[int]]]]  # (degree, assignment) pairs
    generators: list[str]
    max_length: int

    def separates(self, w1: FreeGroupWord, w2: FreeGroupWord) -> bool:
        """Check if the test suite separates w1 from w2."""
        for k, phi in self.tests:
            v1 = _eval_word_perm(w1, phi, k)
            v2 = _eval_word_perm(w2, phi, k)
            if v1 != v2:
                return True
        return False

    @property
    def size(self) -> int:
        return len(self.tests)

    @property
    def max_degree(self) -> int:
        return max((k for k, _ in self.tests), default=0)


def generate_test_suite(generators: list[str],
                        max_length: int,
                        method: str = 'stallings') -> TestSuite:
    """Generate a test suite that separates all distinct pairs up to max_length.

    Args:
        generators: List of generator names
        max_length: Maximum word length
        method: 'stallings' for Stallings construction, 'brute_force' for exhaustive search

    Time complexity (Stallings): O(N^2 * L * |generators|) where N = number of words
    Time complexity (brute force): much higher

    Returns a TestSuite that is guaranteed to separate all distinct pairs
    of reduced words of length ≤ max_length.
    """
    words = _enumerate_reduced_words(generators, max_length)
    tests_set: set[tuple] = set()
    tests: list[tuple[int, dict[str, list[int]]]] = []

    for i in range(len(words)):
        for j in range(i + 1, len(words)):
            w1, w2 = words[i], words[j]
            # Check if already separated
            already_separated = False
            for k, phi in tests:
                v1 = _eval_word_perm(w1, phi, k)
                v2 = _eval_word_perm(w2, phi, k)
                if v1 != v2:
                    already_separated = True
                    break

            if not already_separated:
                # Find a separator
                diff = w1.multiply(w2.invert())
                if method == 'stallings':
                    phi = stallings_separator(diff, generators)
                    if phi is not None:
                        k = diff.length + 1
                        key = (k, tuple(sorted(
                            (g, tuple(p)) for g, p in phi.items()
                        )))
                        if key not in tests_set:
                            tests_set.add(key)
                            tests.append((k, phi))
                else:
                    result = brute_force_separator(w1, w2, generators)
                    if result:
                        k, phi = result
                        key = (k, tuple(sorted(
                            (g, tuple(p)) for g, p in phi.items()
                        )))
                        if key not in tests_set:
                            tests_set.add(key)
                            tests.append((k, phi))

    return TestSuite(tests=tests, generators=generators, max_length=max_length)


def _enumerate_reduced_words(generators: list[str],
                             max_length: int) -> list[FreeGroupWord]:
    """Enumerate all reduced words of length ≤ max_length."""
    words = [FreeGroupWord.identity()]
    letters = [Letter(g, b) for g in generators for b in [True, False]]
    for length in range(1, max_length + 1):
        for combo in itertools.product(letters, repeat=length):
            word = FreeGroupWord(list(combo)).reduce()
            if word.length == length:
                words.append(word)
    return words


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 4: Separation Profile Analysis
# ═══════════════════════════════════════════════════════════════════════════

def compute_separation_profile(generators: list[str],
                               max_L: int,
                               max_k: int = 8,
                               verbose: bool = True) -> dict[int, dict]:
    """Compute detailed separation profile data.

    For each L ≤ max_L, computes:
    - Maximum k needed to separate all pairs
    - Distribution of separation degrees
    - Whether S_{L+1} suffices (conjecture test)

    Returns dict mapping L to analysis data.
    """
    results = {}

    for L in range(1, max_L + 1):
        words = _enumerate_reduced_words(generators, L)
        n_words = len(words)
        n_pairs = n_words * (n_words - 1) // 2

        degree_counts = {}  # k -> count of pairs needing exactly k
        max_k_needed = 2
        unseparated = 0

        for i in range(len(words)):
            for j in range(i + 1, len(words)):
                result = brute_force_separator(words[i], words[j],
                                               generators, max_k)
                if result:
                    k, _ = result
                    degree_counts[k] = degree_counts.get(k, 0) + 1
                    max_k_needed = max(max_k_needed, k)
                else:
                    unseparated += 1

        results[L] = {
            'n_words': n_words,
            'n_pairs': n_pairs,
            'max_k': max_k_needed,
            'degree_distribution': degree_counts,
            'unseparated': unseparated,
            'conjecture_holds': max_k_needed <= L + 1,
        }

        if verbose:
            print(f"L={L}: {n_words} words, {n_pairs} pairs, "
                  f"max k={max_k_needed}, "
                  f"S_{{{L+1}}} conjecture: "
                  f"{'✓' if max_k_needed <= L + 1 else '✗'}")

    return results


# ═══════════════════════════════════════════════════════════════════════════
# Algorithm 5: Cayley Embedding
# ═══════════════════════════════════════════════════════════════════════════

def cayley_embedding(group_table: list[list[int]]) -> list[list[int]]:
    """Compute the Cayley embedding of a finite group into its symmetric group.

    Args:
        group_table: n×n multiplication table where group_table[i][j] = i * j

    Returns:
        List of permutations, one for each group element.

    Time complexity: O(n^2)

    This implements the left regular representation: for each group element g,
    the permutation σ_g maps h to g*h.
    """
    n = len(group_table)
    perms = []
    for g in range(n):
        perm = [group_table[g][h] for h in range(n)]
        perms.append(perm)
    return perms


# ═══════════════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("═══ Algorithm Demonstrations ═══\n")

    # Example 1: Stallings separator
    print("─── Stallings Automaton ───")
    w = FreeGroupWord.from_string("aba^-1b^-1")
    print(f"Word: {w} (commutator [a,b])")
    phi = stallings_separator(w, ['a', 'b'])
    if phi:
        print(f"Stallings representation (degree {w.length + 1}):")
        for gen, perm in phi.items():
            print(f"  φ({gen}) = {perm}")
        result = _eval_word_perm(w, phi, w.length + 1)
        print(f"  φ(w) = {result}")
        print(f"  φ(w)(0) = {result[0]} ≠ 0: {'✓' if result[0] != 0 else '✗'}")

    # Example 2: Test suite generation
    print("\n─── Test Suite Generation ───")
    suite = generate_test_suite(['a', 'b'], 2, method='stallings')
    print(f"Test suite for L=2: {suite.size} tests, max degree {suite.max_degree}")

    # Verify completeness
    words = _enumerate_reduced_words(['a', 'b'], 2)
    all_separated = True
    for i in range(len(words)):
        for j in range(i + 1, len(words)):
            if not suite.separates(words[i], words[j]):
                print(f"  FAIL: cannot separate {words[i]} and {words[j]}")
                all_separated = False
    if all_separated:
        print(f"  ✓ Suite correctly separates all {len(words)} words pairwise")

    # Example 3: Separation profile
    print("\n─── Separation Profile (rank 2, L ≤ 3) ───")
    profile = compute_separation_profile(['a', 'b'], 3, max_k=6)
