#!/usr/bin/env python3
"""
Substitution Tiling Algebra — Core Algorithms

Type-hinted implementations of the key algorithms from the STA framework.
"""

from typing import Dict, List, Set, Tuple, Optional
import numpy as np
from numpy.typing import NDArray


def apply_substitution(rules: Dict[str, List[str]], word: List[str]) -> List[str]:
    """Apply a substitution rule to every letter in a word.

    Time complexity: O(|word| * max_rule_length)
    Space complexity: O(output_length)
    """
    result: List[str] = []
    for letter in word:
        result.extend(rules[letter])
    return result


def iterate_substitution(rules: Dict[str, List[str]], start: str, depth: int) -> List[str]:
    """Compute σ^depth(start) — the depth-fold iteration of substitution.

    Warning: output length grows exponentially. For expanding systems,
    |σ^n(a)| ≥ 2^n. Use depth ≤ 15 for practical computation.
    """
    word: List[str] = [start]
    for _ in range(depth):
        word = apply_substitution(rules, word)
    return word


def substitution_matrix(rules: Dict[str, List[str]], alphabet: List[str]) -> NDArray[np.int64]:
    """Compute the substitution matrix M where M[i,j] = count(alphabet[i], rules[alphabet[j]]).

    The substitution matrix is the key algebraic invariant of a substitution system.
    Its eigenvalues determine growth rates and aperiodicity properties.
    """
    k: int = len(alphabet)
    M: NDArray[np.int64] = np.zeros((k, k), dtype=np.int64)
    for j, src in enumerate(alphabet):
        for i, tgt in enumerate(alphabet):
            M[i, j] = rules[src].count(tgt)
    return M


def is_primitive(rules: Dict[str, List[str]], alphabet: List[str],
                 max_depth: int = 20) -> Tuple[bool, int]:
    """Check if a substitution system is primitive.

    Returns (is_primitive, witness_depth) where witness_depth is the minimal
    depth at which all letters appear in all iterated words.

    A primitive system has the property that its substitution matrix M satisfies
    M^n > 0 (all entries positive) for some n.
    """
    for n in range(1, max_depth + 1):
        all_present: bool = True
        for start in alphabet:
            word = iterate_substitution(rules, start, n)
            word_set: Set[str] = set(word)
            if not all(letter in word_set for letter in alphabet):
                all_present = False
                break
        if all_present:
            return True, n
    return False, -1


def growth_sequence(rules: Dict[str, List[str]], start: str,
                    max_depth: int = 20) -> List[int]:
    """Compute the growth sequence g(start, 0), g(start, 1), ..., g(start, max_depth).

    For expanding systems (all rules have length ≥ 2), this grows exponentially.
    For the hat system starting from H: 1, 7, 35, 187, 1001, ...
    For Fibonacci starting from a: 1, 2, 3, 5, 8, 13, 21, ...
    """
    word: List[str] = [start]
    lengths: List[int] = [1]
    for _ in range(max_depth):
        word = apply_substitution(rules, word)
        lengths.append(len(word))
    return lengths


def factor_complexity(word: List[str], max_length: int) -> List[int]:
    """Compute factor complexity p(1), p(2), ..., p(max_length).

    For aperiodic words, p(n) ≥ n + 1 (Morse-Hedlund theorem).
    For periodic words with period q, p(n) ≤ q for all n ≥ q.
    """
    complexities: List[int] = []
    for n in range(1, max_length + 1):
        if n > len(word):
            complexities.append(0)
            continue
        factors: Set[Tuple[str, ...]] = set()
        for i in range(len(word) - n + 1):
            factors.add(tuple(word[i:i+n]))
        complexities.append(len(factors))
    return complexities


def spectral_aperiodicity_check(rules: Dict[str, List[str]],
                                 alphabet: List[str]) -> Dict[str, object]:
    """Check if a substitution system has a spectral aperiodicity certificate.

    Returns a dict with:
    - 'is_primitive': bool
    - 'primitive_depth': int (witness depth, or -1)
    - 'is_expanding': bool (all rules have length ≥ 2)
    - 'has_certificate': bool
    - 'eigenvalues': list of eigenvalues of the substitution matrix
    - 'dominant_eigenvalue': float
    """
    M = substitution_matrix(rules, alphabet)
    eigenvalues = sorted(np.linalg.eigvals(M).real, reverse=True)
    prim, depth = is_primitive(rules, alphabet)
    expanding = all(len(rules[a]) >= 2 for a in alphabet)

    return {
        'is_primitive': prim,
        'primitive_depth': depth,
        'is_expanding': expanding,
        'has_certificate': prim and expanding,
        'matrix': M.tolist(),
        'eigenvalues': eigenvalues,
        'dominant_eigenvalue': eigenvalues[0] if eigenvalues else 0.0,
    }


def letter_frequencies(rules: Dict[str, List[str]], alphabet: List[str],
                       start: str, depth: int) -> Dict[str, float]:
    """Compute letter frequencies in σ^depth(start).

    For primitive systems, these converge to the Perron eigenvector
    (left eigenvector of the substitution matrix for the dominant eigenvalue).
    """
    word = iterate_substitution(rules, start, depth)
    total = len(word)
    return {letter: word.count(letter) / total for letter in alphabet}


# === Predefined Systems ===

HAT_RULES: Dict[str, List[str]] = {
    'H': ['H', 'H', 'H', 'H', 'T', 'P', 'F'],
    'T': ['H', 'H', 'T'],
    'P': ['H', 'P'],
    'F': ['H', 'F'],
}
HAT_ALPHABET: List[str] = ['H', 'T', 'P', 'F']

FIBONACCI_RULES: Dict[str, List[str]] = {
    'a': ['a', 'b'],
    'b': ['a'],
}
FIBONACCI_ALPHABET: List[str] = ['a', 'b']

THUE_MORSE_RULES: Dict[str, List[str]] = {
    'a': ['a', 'b'],
    'b': ['b', 'a'],
}
THUE_MORSE_ALPHABET: List[str] = ['a', 'b']


if __name__ == "__main__":
    # Quick test
    for name, rules, alphabet in [
        ("Hat", HAT_RULES, HAT_ALPHABET),
        ("Fibonacci", FIBONACCI_RULES, FIBONACCI_ALPHABET),
        ("Thue-Morse", THUE_MORSE_RULES, THUE_MORSE_ALPHABET),
    ]:
        print(f"\n{'='*50}")
        print(f"System: {name}")
        result = spectral_aperiodicity_check(rules, alphabet)
        for key, value in result.items():
            print(f"  {key}: {value}")

        freqs = letter_frequencies(rules, alphabet, alphabet[0], 8)
        print(f"  Letter frequencies at depth 8: {freqs}")
