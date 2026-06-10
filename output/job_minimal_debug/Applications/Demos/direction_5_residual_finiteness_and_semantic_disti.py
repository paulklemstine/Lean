#!/usr/bin/env python3
"""
applications.py — Real-world applications of free group semantic separation.

Demonstrates how the mathematical theory of residual finiteness and semantic
distinguishability applies to:
1. Compiler optimization verification
2. Reversible circuit equivalence checking
3. Algebraic program testing
"""

from algorithms import (
    FreeGroupWord, Letter, stallings_separator,
    brute_force_separator, _eval_word_perm, _invert_perm, _compose_perm,
    generate_test_suite, _enumerate_reduced_words
)


# ═══════════════════════════════════════════════════════════════════════════
# Application 1: Compiler Optimization Verification
# ═══════════════════════════════════════════════════════════════════════════

def compiler_verification_demo():
    """Demonstrate verification of compiler optimizations using finite group testing.

    In a reversible computation model, operations are represented as generators
    of a free group:
    - Generator 'a' = operation A (e.g., NOT gate)
    - Generator 'b' = operation B (e.g., swap gate)
    - 'a^-1' = inverse of A

    A compiler optimization rewrites program P₁ to P₂. The optimization is
    CORRECT iff P₁ = P₂ in the free group (same reduced word).

    Our theorem says: if P₁ ≠ P₂, then there exists a finite permutation
    test that detects the difference.
    """
    print("═══ Application 1: Compiler Optimization Verification ═══\n")

    # Example: A compiler claims aba = bab (braid relation)
    # In a free group, this is FALSE (no braid relation)
    p1 = FreeGroupWord.from_string("aba")
    p2 = FreeGroupWord.from_string("bab")

    print(f"Program P₁: {p1}")
    print(f"Program P₂: {p2}")
    print(f"Compiler claims P₁ ≡ P₂")
    print()

    if p1 == p2:
        print("✓ Programs are identical (same reduced word)")
    else:
        print("✗ Programs differ! Searching for a distinguishing test...")
        diff = p1.multiply(p2.invert())
        print(f"  Difference word P₁P₂⁻¹ = {diff}")

        result = brute_force_separator(p1, p2, ['a', 'b'])
        if result:
            k, phi = result
            v1 = _eval_word_perm(p1, phi, k)
            v2 = _eval_word_perm(p2, phi, k)
            print(f"  Found distinguishing test in S_{k}:")
            for gen, perm in phi.items():
                print(f"    φ({gen}) = {perm}")
            print(f"  φ(P₁) = {v1}")
            print(f"  φ(P₂) = {v2}")
            print(f"  These are different ⟹ optimization is INCORRECT")

    print()

    # Example 2: A correct optimization
    # a * a^-1 * b = b (cancellation)
    p3 = FreeGroupWord.from_string("aa^-1b")
    p4 = FreeGroupWord.from_string("b")
    print(f"Program P₃: aa⁻¹b (before reduction)")
    print(f"Program P₄: b")
    print(f"After reduction: P₃ = {p3}, P₄ = {p4}")
    if p3 == p4:
        print("✓ Optimization is CORRECT (same reduced word)")
    else:
        print("✗ Optimization is INCORRECT")


# ═══════════════════════════════════════════════════════════════════════════
# Application 2: Reversible Circuit Equivalence
# ═══════════════════════════════════════════════════════════════════════════

def reversible_circuit_demo():
    """Demonstrate equivalence checking for reversible circuits.

    Reversible logic gates (Toffoli, Fredkin, CNOT, etc.) form a group.
    Two circuits are equivalent iff they represent the same group element.

    We model a simplified scenario with two gates:
    - X gate (NOT): generator 'x'
    - CNOT-like gate: generator 'c'
    """
    print("═══ Application 2: Reversible Circuit Equivalence ═══\n")

    generators = ['x', 'c']

    # Two candidate circuits
    circuit_a = FreeGroupWord.from_string("xcxc^-1x^-1")
    circuit_b = FreeGroupWord.from_string("cx^-1c^-1")

    print(f"Circuit A: {circuit_a}")
    print(f"Circuit B: {circuit_b}")

    if circuit_a == circuit_b:
        print("✓ Circuits are equivalent")
    else:
        diff = circuit_a.multiply(circuit_b.invert())
        print(f"Difference: A·B⁻¹ = {diff}")

        # Use Stallings separator
        phi = stallings_separator(diff, generators)
        if phi:
            n = diff.length + 1
            va = _eval_word_perm(circuit_a, phi, n)
            vb = _eval_word_perm(circuit_b, phi, n)
            print(f"Stallings test (S_{n}):")
            for gen, perm in phi.items():
                print(f"  φ({gen}) = {perm}")
            print(f"  φ(A) = {va}")
            print(f"  φ(B) = {vb}")
            if va != vb:
                print("  ✗ Circuits are NOT equivalent")
            else:
                print("  ✓ Test inconclusive (need larger group)")


# ═══════════════════════════════════════════════════════════════════════════
# Application 3: Algebraic Test Suite for Program Equivalence
# ═══════════════════════════════════════════════════════════════════════════

def test_suite_demo():
    """Demonstrate generation and use of finite test suites.

    For programs up to a given size, generate a FINITE set of tests
    that is guaranteed to detect any inequivalence.
    """
    print("═══ Application 3: Finite Test Suite for Program Equivalence ═══\n")

    generators = ['a', 'b']
    max_length = 2

    print(f"Generators: {generators}")
    print(f"Maximum program length: {max_length}")
    print()

    # Generate the test suite
    suite = generate_test_suite(generators, max_length, method='stallings')
    print(f"Generated test suite:")
    print(f"  Number of tests: {suite.size}")
    print(f"  Maximum permutation degree: {suite.max_degree}")
    print()

    # List all tests
    for i, (k, phi) in enumerate(suite.tests):
        print(f"  Test {i+1} (S_{k}):")
        for gen, perm in phi.items():
            print(f"    φ({gen}) = {perm}")
    print()

    # Verify completeness
    words = _enumerate_reduced_words(generators, max_length)
    print(f"Total programs of length ≤ {max_length}: {len(words)}")
    total_pairs = len(words) * (len(words) - 1) // 2
    separated = 0
    failed = 0

    for i in range(len(words)):
        for j in range(i + 1, len(words)):
            if suite.separates(words[i], words[j]):
                separated += 1
            else:
                failed += 1
                print(f"  FAIL: {words[i]} vs {words[j]}")

    print(f"Pairs separated: {separated}/{total_pairs}")
    if failed == 0:
        print("✓ Test suite is COMPLETE — detects all inequivalences!")
    else:
        print(f"✗ {failed} pairs not separated")


# ═══════════════════════════════════════════════════════════════════════════
# Application 4: Property-Based Testing Analogue
# ═══════════════════════════════════════════════════════════════════════════

def property_testing_demo():
    """Show how residual finiteness provides a mathematical foundation
    for property-based testing of algebraic programs.

    Key insight: Instead of testing against arbitrary models (as in QuickCheck),
    test against a bounded family of finite permutation groups.
    This is COMPLETE for bounded-length programs.
    """
    print("═══ Application 4: Certified Property-Based Testing ═══\n")

    generators = ['f', 'g']

    # Simulate a "QuickCheck-like" test
    # Claim: f·g·f⁻¹ = g (i.e., f and g commute)
    lhs = FreeGroupWord.from_string("fgf^-1")
    rhs = FreeGroupWord.from_string("g")

    print(f"Testing claim: {lhs} = {rhs}")
    print(f"(i.e., f and g commute in the free group)")
    print()

    if lhs == rhs:
        print("✓ Claim is TRUE in the free group")
    else:
        print("Claim is FALSE in the free group.")
        print("Finding minimal counterexample...")

        result = brute_force_separator(lhs, rhs, generators)
        if result:
            k, phi = result
            print(f"\nCounterexample found in S_{k}:")
            for gen, perm in phi.items():
                print(f"  {gen} ↦ {perm}")
            v_lhs = _eval_word_perm(lhs, phi, k)
            v_rhs = _eval_word_perm(rhs, phi, k)
            print(f"  {lhs} ↦ {v_lhs}")
            print(f"  {rhs} ↦ {v_rhs}")
            print(f"\n  These differ ⟹ the programs are NOT equivalent")
            print(f"  This counterexample is guaranteed to exist by our theorem")


# ═══════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    compiler_verification_demo()
    print("\n" + "─" * 60 + "\n")
    reversible_circuit_demo()
    print("\n" + "─" * 60 + "\n")
    test_suite_demo()
    print("\n" + "─" * 60 + "\n")
    property_testing_demo()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of free group semantic separation.

This script demonstrates the core mathematical result: distinct elements of a free
group can be separated by evaluation into finite symmetric groups. Given two words
in free group generators, it searches for the smallest symmetric group S_k and a
generator assignment φ that distinguishes them.

Usage:
    python demo.py                    # Interactive mode
    python demo.py --batch L          # Batch test all pairs up to length L
    python demo.py --word "aba^-1b^-1" # Test a specific word against identity
"""

import itertools
import sys
from typing import Optional


# ─── Free Group Word Representation ───────────────────────────────────────────

def parse_word(s: str, generators: list[str] = None) -> list[tuple[str, bool]]:
    """Parse a string like 'aba^-1b^-1' into a list of (generator, is_positive) pairs."""
    if generators is None:
        generators = sorted(set(c for c in s if c.isalpha()))
    result = []
    i = 0
    while i < len(s):
        if s[i].isalpha():
            gen = s[i]
            if i + 3 < len(s) and s[i+1:i+4] == '^-1':
                result.append((gen, False))
                i += 4
            elif i + 2 < len(s) and s[i+1:i+3] == '-1':
                result.append((gen, False))
                i += 3
            else:
                result.append((gen, True))
                i += 1
        else:
            i += 1
    return result


def reduce_word(word: list[tuple[str, bool]]) -> list[tuple[str, bool]]:
    """Reduce a free group word by canceling adjacent inverse pairs."""
    stack = []
    for letter in word:
        if stack and stack[-1][0] == letter[0] and stack[-1][1] != letter[1]:
            stack.pop()
        else:
            stack.append(letter)
    return stack


def word_to_string(word: list[tuple[str, bool]]) -> str:
    """Convert a reduced word back to string representation."""
    if not word:
        return "1"
    parts = []
    for gen, positive in word:
        if positive:
            parts.append(gen)
        else:
            parts.append(f"{gen}⁻¹")
    return "".join(parts)


def multiply_words(w1: list[tuple[str, bool]],
                   w2: list[tuple[str, bool]]) -> list[tuple[str, bool]]:
    """Multiply two free group words and reduce."""
    return reduce_word(w1 + w2)


def invert_word(word: list[tuple[str, bool]]) -> list[tuple[str, bool]]:
    """Invert a free group word."""
    return [(g, not b) for g, b in reversed(word)]


# ─── Permutation Arithmetic ─────────────────────────────────────────────────

def identity_perm(n: int) -> list[int]:
    """Identity permutation on {0, ..., n-1}."""
    return list(range(n))


def compose_perm(p: list[int], q: list[int]) -> list[int]:
    """Compose permutations: (p ∘ q)(i) = p(q(i))."""
    return [p[q[i]] for i in range(len(p))]


def invert_perm(p: list[int]) -> list[int]:
    """Invert a permutation."""
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return inv


def is_identity(p: list[int]) -> bool:
    """Check if a permutation is the identity."""
    return all(p[i] == i for i in range(len(p)))


def all_perms(n: int):
    """Generate all permutations of {0, ..., n-1}."""
    return [list(p) for p in itertools.permutations(range(n))]


# ─── Free Group Evaluation ──────────────────────────────────────────────────

def eval_word(word: list[tuple[str, bool]],
              phi: dict[str, list[int]],
              n: int) -> list[int]:
    """Evaluate a free group word under assignment φ : generators → S_n.

    Returns the permutation in S_n corresponding to the word.
    """
    result = identity_perm(n)
    for gen, positive in word:
        p = phi.get(gen, identity_perm(n))
        if not positive:
            p = invert_perm(p)
        result = compose_perm(p, result)
    return result


# ─── Separation Search ──────────────────────────────────────────────────────

def find_separator(w1: list[tuple[str, bool]],
                   w2: list[tuple[str, bool]],
                   generators: list[str],
                   max_k: int = 8) -> Optional[tuple[int, dict[str, list[int]]]]:
    """Find the smallest k such that some φ : generators → S_k separates w1 and w2.

    Returns (k, phi) if found, None otherwise.
    """
    for k in range(2, max_k + 1):
        perms = all_perms(k)
        # Search over all assignments φ
        for assignment in itertools.product(perms, repeat=len(generators)):
            phi = dict(zip(generators, [list(p) for p in assignment]))
            v1 = eval_word(w1, phi, k)
            v2 = eval_word(w2, phi, k)
            if v1 != v2:
                return k, phi
    return None


def find_separator_from_identity(word: list[tuple[str, bool]],
                                 generators: list[str],
                                 max_k: int = 8) -> Optional[tuple[int, dict[str, list[int]]]]:
    """Find smallest k such that some φ : generators → S_k maps word to non-identity."""
    return find_separator(word, [], generators, max_k)


# ─── Word Enumeration ───────────────────────────────────────────────────────

def enumerate_reduced_words(generators: list[str],
                            max_length: int) -> list[list[tuple[str, bool]]]:
    """Enumerate all reduced words of length ≤ max_length over given generators."""
    words = [[]]  # identity
    for length in range(1, max_length + 1):
        letters = [(g, b) for g in generators for b in [True, False]]
        for word_tuple in itertools.product(letters, repeat=length):
            word = list(word_tuple)
            reduced = reduce_word(word)
            if len(reduced) == length:
                words.append(word)
    return words


# ─── Separation Profile Computation ────────────────────────────────────────

def compute_separation_profile(generators: list[str],
                               max_L: int,
                               max_k: int = 8) -> dict[int, int]:
    """Compute the permutation separation profile.

    For each L ≤ max_L, find the maximum k needed to separate all distinct
    pairs of reduced words of length ≤ L.
    """
    profile = {}
    for L in range(1, max_L + 1):
        words = enumerate_reduced_words(generators, L)
        max_needed = 2
        total_pairs = 0
        separated = 0
        for i in range(len(words)):
            for j in range(i + 1, len(words)):
                total_pairs += 1
                result = find_separator(words[i], words[j], generators, max_k)
                if result:
                    k, _ = result
                    max_needed = max(max_needed, k)
                    separated += 1
                else:
                    print(f"  Warning: could not separate "
                          f"{word_to_string(words[i])} and "
                          f"{word_to_string(words[j])} up to S_{max_k}")
        profile[L] = max_needed
        print(f"  L={L}: max k needed = {max_needed}, "
              f"separated {separated}/{total_pairs} pairs")
    return profile


# ─── Demo Functions ─────────────────────────────────────────────────────────

def demo_single_word(word_str: str, generators: list[str] = None):
    """Demonstrate separation of a single word from the identity."""
    word = parse_word(word_str)
    word = reduce_word(word)
    if generators is None:
        generators = sorted(set(g for g, _ in word))
    if not word:
        print(f"Word '{word_str}' reduces to the identity.")
        return

    print(f"\nWord: {word_to_string(word)} (length {len(word)})")
    print(f"Generators: {generators}")
    print(f"Searching for separating permutation assignment...")

    result = find_separator_from_identity(word, generators)
    if result:
        k, phi = result
        perm = eval_word(word, phi, k)
        print(f"\n✓ Separated in S_{k}!")
        print(f"  Assignment:")
        for gen in generators:
            print(f"    φ({gen}) = {phi[gen]}")
        print(f"  Result: φ(w) = {perm} ≠ identity")
    else:
        print(f"\n✗ Could not separate up to S_8")


def demo_pair(w1_str: str, w2_str: str, generators: list[str] = None):
    """Demonstrate separation of two words."""
    w1 = reduce_word(parse_word(w1_str))
    w2 = reduce_word(parse_word(w2_str))
    if generators is None:
        generators = sorted(set(g for g, _ in w1 + w2) or ['a'])
    if w1 == w2:
        print(f"Words are equal (both reduce to {word_to_string(w1)})")
        return

    print(f"\nWord 1: {word_to_string(w1)} (length {len(w1)})")
    print(f"Word 2: {word_to_string(w2)} (length {len(w2)})")
    print(f"Generators: {generators}")
    print(f"Searching for separating assignment...")

    result = find_separator(w1, w2, generators)
    if result:
        k, phi = result
        v1 = eval_word(w1, phi, k)
        v2 = eval_word(w2, phi, k)
        print(f"\n✓ Separated in S_{k}!")
        print(f"  Assignment:")
        for gen in generators:
            print(f"    φ({gen}) = {phi[gen]}")
        print(f"  φ(w₁) = {v1}")
        print(f"  φ(w₂) = {v2}")
    else:
        print(f"\n✗ Could not separate up to S_8")


def demo_batch(max_L: int, generators: list[str] = ['a', 'b']):
    """Batch test: compute separation profile for all pairs up to length L."""
    print(f"\n═══ Separation Profile for F({','.join(generators)}) ═══")
    print(f"Testing all pairs of reduced words up to length {max_L}")
    print()
    profile = compute_separation_profile(generators, max_L)
    print(f"\n═══ Summary ═══")
    print(f"{'L':>3} │ {'max k needed':>12} │ {'L+1':>4} │ {'S_(L+1) suffices?':>18}")
    print(f"{'─'*3}─┼─{'─'*12}─┼─{'─'*4}─┼─{'─'*18}")
    for L, k in sorted(profile.items()):
        suffices = "✓" if k <= L + 1 else "✗"
        print(f"{L:>3} │ {k:>12} │ {L+1:>4} │ {suffices:>18}")


def demo_commutator():
    """Demonstrate separation of the commutator [a,b] = aba⁻¹b⁻¹."""
    print("\n═══ Commutator [a,b] = aba⁻¹b⁻¹ ═══")
    demo_single_word("aba^-1b^-1", ['a', 'b'])

    print("\n\n═══ Double commutator [[a,b],a] ═══")
    commutator = parse_word("aba^-1b^-1")
    double = multiply_words(
        multiply_words(commutator, parse_word("a")),
        multiply_words(invert_word(commutator), parse_word("a^-1"))
    )
    demo_single_word(word_to_string(double), ['a', 'b'])


def interactive_mode():
    """Interactive demonstration mode."""
    print("═══ Free Group Semantic Separator ═══")
    print("Demonstrates that distinct free group elements can be")
    print("separated by evaluation into finite symmetric groups.\n")

    while True:
        print("\nOptions:")
        print("  1. Test a word against the identity")
        print("  2. Test two words against each other")
        print("  3. Commutator examples")
        print("  4. Batch separation profile (slow for L > 3)")
        print("  5. Quit")

        choice = input("\nChoice: ").strip()

        if choice == '1':
            word = input("Enter word (e.g., aba^-1b^-1): ").strip()
            gens = input("Generators (comma-separated, or Enter for auto): ").strip()
            gens = [g.strip() for g in gens.split(',')] if gens else None
            demo_single_word(word, gens)
        elif choice == '2':
            w1 = input("Enter word 1: ").strip()
            w2 = input("Enter word 2: ").strip()
            gens = input("Generators (comma-separated, or Enter for auto): ").strip()
            gens = [g.strip() for g in gens.split(',')] if gens else None
            demo_pair(w1, w2, gens)
        elif choice == '3':
            demo_commutator()
        elif choice == '4':
            L = int(input("Max word length L (recommend ≤ 3): ").strip())
            n = int(input("Number of generators (recommend 2): ").strip())
            gens = [chr(ord('a') + i) for i in range(n)]
            demo_batch(L, gens)
        elif choice == '5':
            break
        else:
            print("Invalid choice.")


# ─── Main ───────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    if len(sys.argv) > 1:
        if sys.argv[1] == '--batch':
            L = int(sys.argv[2]) if len(sys.argv) > 2 else 3
            demo_batch(L)
        elif sys.argv[1] == '--word':
            word = sys.argv[2] if len(sys.argv) > 2 else "aba^-1b^-1"
            demo_single_word(word)
        elif sys.argv[1] == '--commutator':
            demo_commutator()
        else:
            print(f"Unknown option: {sys.argv[1]}")
            print("Usage: python demo.py [--batch L] [--word WORD] [--commutator]")
    else:
        # Run default demos
        print("═══ Free Group Semantic Separation Demo ═══\n")

        print("─── Example 1: Generator ───")
        demo_single_word("a", ['a', 'b'])

        print("\n\n─── Example 2: Product of generators ───")
        demo_single_word("ab", ['a', 'b'])

        print("\n\n─── Example 3: Commutator [a,b] ───")
        demo_single_word("aba^-1b^-1", ['a', 'b'])

        print("\n\n─── Example 4: Separating two distinct words ───")
        demo_pair("ab", "ba", ['a', 'b'])

        print("\n\n─── Example 5: Separation profile (L ≤ 3) ───")
        demo_batch(3, ['a', 'b'])
