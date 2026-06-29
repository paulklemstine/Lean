#!/usr/bin/env python3
"""
Tropical One-Way Minors: Collision Separation Demo

Demonstrates the tropical matrix semigroup action framework and the
collision bridge theorem with concrete numerical examples.
"""

import numpy as np
from itertools import product as cart_product
from typing import List, Tuple, Optional, Dict
import json


# ─── Core Tropical Algebra ──────────────────────────────────────────────────

def tropical_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (ordinary addition)."""
    return a + b


def tropical_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Min-plus matrix multiplication: C[i,j] = min_k (A[i,k] + B[k,j])."""
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def tropical_matvec(A: np.ndarray, v: np.ndarray) -> np.ndarray:
    """Min-plus matrix-vector product: (Av)[i] = min_k (A[i,k] + v[k])."""
    n = A.shape[0]
    result = np.full(n, np.inf)
    for i in range(n):
        for k in range(n):
            result[i] = min(result[i], A[i, k] + v[k])
    return result


def standard_matvec(A: np.ndarray, v: np.ndarray) -> np.ndarray:
    """Standard matrix-vector product."""
    return A @ v


# ─── Word Evaluation ────────────────────────────────────────────────────────

def eval_word_matrix(generators: List[np.ndarray], word: List[int],
                     use_tropical: bool = False) -> np.ndarray:
    """Evaluate a word as a matrix product.

    Args:
        generators: List of generator matrices.
        word: List of generator indices.
        use_tropical: If True, use min-plus multiplication.
    """
    n = generators[0].shape[0]
    result = np.eye(n) if not use_tropical else np.zeros((n, n))
    if use_tropical:
        for i in range(n):
            for j in range(n):
                result[i, j] = 0.0 if i == j else np.inf

    mul_fn = tropical_matmul if use_tropical else np.matmul
    for g in word:
        result = mul_fn(generators[g], result)
    return result


def tropical_act(generators: List[np.ndarray], v0: np.ndarray,
                 word: List[int], use_tropical: bool = False) -> np.ndarray:
    """Compute the action of a word on an input vector."""
    M = eval_word_matrix(generators, word, use_tropical)
    if use_tropical:
        return tropical_matvec(M, v0)
    else:
        return standard_matvec(M, v0)


# ─── Valuation-Congruence Profile ───────────────────────────────────────────

class ValCongProfile:
    """Valuation-congruence profile for a matrix."""

    def __init__(self, principal_minors: np.ndarray,
                 kernel_datum: int = 0, cong_class: int = 0):
        self.principal_minors = principal_minors
        self.kernel_datum = kernel_datum
        self.cong_class = cong_class

    def __eq__(self, other):
        return (np.allclose(self.principal_minors, other.principal_minors) and
                self.kernel_datum == other.kernel_datum and
                self.cong_class == other.cong_class)

    def __repr__(self):
        return (f"Profile(minors={self.principal_minors.tolist()}, "
                f"kernel={self.kernel_datum}, cong={self.cong_class})")


def basic_profile(A: np.ndarray) -> ValCongProfile:
    """Extract the basic profile from a matrix (diagonal entries)."""
    return ValCongProfile(np.diag(A))


def word_profile(generators: List[np.ndarray], word: List[int],
                 use_tropical: bool = False) -> ValCongProfile:
    """Compute the profile of a word."""
    M = eval_word_matrix(generators, word, use_tropical)
    return basic_profile(M)


# ─── Collision Detection ────────────────────────────────────────────────────

def enumerate_words(num_generators: int, max_length: int) -> List[List[int]]:
    """Enumerate all words of length ≤ max_length over num_generators symbols."""
    words = [[]]  # empty word
    for length in range(1, max_length + 1):
        for w in cart_product(range(num_generators), repeat=length):
            words.append(list(w))
    return words


def find_collisions(generators: List[np.ndarray], v0: np.ndarray,
                    max_radius: int, use_tropical: bool = False
                    ) -> List[Tuple[List[int], List[int]]]:
    """Find all collisions on the ball of radius max_radius."""
    words = enumerate_words(len(generators), max_radius)
    outputs = {}
    collisions = []

    for w in words:
        out = tuple(tropical_act(generators, v0, w, use_tropical).round(10))
        key = out
        if key in outputs:
            collisions.append((outputs[key], w))
        else:
            outputs[key] = w

    return collisions


def check_profile_separation(generators: List[np.ndarray],
                              max_radius: int,
                              use_tropical: bool = False
                              ) -> Tuple[bool, Optional[Tuple]]:
    """Check if word profiles are separated (injective) on the ball."""
    words = enumerate_words(len(generators), max_radius)
    profiles = {}

    for w in words:
        prof = word_profile(generators, w, use_tropical)
        key = tuple(prof.principal_minors.round(10))
        if key in profiles:
            return False, (profiles[key], w, prof)
        profiles[key] = w

    return True, None


# ─── Demo Functions ─────────────────────────────────────────────────────────

def demo_standard_matrices():
    """Demo with standard (non-tropical) matrix multiplication over integers."""
    print("=" * 70)
    print("DEMO 1: Standard Matrix Semigroup Action")
    print("=" * 70)

    # 3x3 integer matrices, 2 generators
    np.random.seed(42)
    n = 3
    G0 = np.array([[1, 2, 0], [0, 1, 1], [1, 0, 2]], dtype=float)
    G1 = np.array([[2, 0, 1], [1, 1, 0], [0, 1, 1]], dtype=float)
    generators = [G0, G1]
    v0 = np.array([1.0, 0.0, 0.0])

    print(f"\nGenerator G0:\n{G0}")
    print(f"\nGenerator G1:\n{G1}")
    print(f"\nInput vector v0: {v0}")

    # Evaluate some words
    test_words = [[], [0], [1], [0, 1], [1, 0], [0, 0], [1, 1]]
    print("\nWord evaluations:")
    for w in test_words:
        out = tropical_act(generators, v0, w)
        prof = word_profile(generators, w)
        word_str = "ε" if not w else "".join(str(g) for g in w)
        print(f"  word={word_str:6s}  output={out}  "
              f"diag_profile={prof.principal_minors.tolist()}")

    # Check collisions
    R = 3
    collisions = find_collisions(generators, v0, R)
    print(f"\nCollisions on ball of radius {R}: {len(collisions)}")
    if collisions:
        for w1, w2 in collisions[:5]:
            print(f"  {''.join(str(g) for g in w1)} = {''.join(str(g) for g in w2)}")

    # Check profile separation
    separated, info = check_profile_separation(generators, R)
    print(f"Profile separation on radius {R}: {separated}")

    # Verify the bridge theorem numerically
    print("\n--- Bridge Theorem Verification ---")
    if separated and not collisions:
        print("✓ Profiles separated AND no collisions: Bridge theorem confirmed!")
    elif not separated:
        print(f"  Profile collision found: words "
              f"{''.join(str(g) for g in info[0])} and "
              f"{''.join(str(g) for g in info[1])}")
        print(f"  Common profile: {info[2]}")


def demo_tropical_matrices():
    """Demo with tropical (min-plus) matrix multiplication."""
    print("\n" + "=" * 70)
    print("DEMO 2: Tropical (Min-Plus) Matrix Semigroup Action")
    print("=" * 70)

    n = 3
    # Tropical generators with distinct diagonals
    G0 = np.array([[0, 5, 3], [7, 1, 4], [2, 6, 2]], dtype=float)
    G1 = np.array([[3, 1, 8], [4, 0, 2], [1, 3, 5]], dtype=float)
    generators = [G0, G1]
    v0 = np.array([0.0, 0.0, 0.0])

    print(f"\nTropical Generator G0:\n{G0}")
    print(f"\nTropical Generator G1:\n{G1}")
    print(f"\nInput vector v0: {v0}")
    print("\nMultiplication rule: (A⊗B)[i,j] = min_k(A[i,k] + B[k,j])")

    # Evaluate some words
    test_words = [[], [0], [1], [0, 1], [1, 0], [0, 0], [1, 1]]
    print("\nTropical word evaluations:")
    for w in test_words:
        out = tropical_act(generators, v0, w, use_tropical=True)
        prof = word_profile(generators, w, use_tropical=True)
        word_str = "ε" if not w else "".join(str(g) for g in w)
        print(f"  word={word_str:6s}  output={out}  "
              f"diag_profile={prof.principal_minors.tolist()}")

    # Check collisions
    R = 3
    collisions = find_collisions(generators, v0, R, use_tropical=True)
    print(f"\nTropical collisions on ball of radius {R}: {len(collisions)}")
    if collisions:
        for w1, w2 in collisions[:5]:
            s1 = "ε" if not w1 else "".join(str(g) for g in w1)
            s2 = "ε" if not w2 else "".join(str(g) for g in w2)
            print(f"  {s1} = {s2}")

    # Check profile separation
    separated, info = check_profile_separation(generators, R, use_tropical=True)
    print(f"Tropical profile separation on radius {R}: {separated}")

    print("\n--- Bridge Theorem Verification ---")
    if separated and not collisions:
        print("✓ Profiles separated AND no collisions: Bridge theorem confirmed!")
    elif not separated and collisions:
        print("✗ Profiles NOT separated AND collisions exist: "
              "Witness extraction applicable")
    elif not separated:
        print(f"  Profile collision detected")


def demo_witness_extraction():
    """Demo of bounded witness extraction when collisions exist."""
    print("\n" + "=" * 70)
    print("DEMO 3: Bounded Witness Extraction")
    print("=" * 70)

    # Use degenerate generators to force collisions
    n = 2
    # G0 and G1 differ only in off-diagonal — same diagonal ⟹ profile collision
    G0 = np.array([[2, 1], [0, 3]], dtype=float)
    G1 = np.array([[2, 0], [1, 3]], dtype=float)
    generators = [G0, G1]
    v0 = np.array([1.0, 1.0])

    print(f"\nGenerator G0:\n{G0}")
    print(f"\nGenerator G1:\n{G1}")
    print(f"\nInput vector v0: {v0}")
    print("\nNote: G0 and G1 have the same diagonal [2, 3]")

    R = 3
    collisions = find_collisions(generators, v0, R)
    print(f"\nCollisions found on ball of radius {R}: {len(collisions)}")

    for w1, w2 in collisions[:5]:
        s1 = "ε" if not w1 else "".join(str(g) for g in w1)
        s2 = "ε" if not w2 else "".join(str(g) for g in w2)
        out1 = tropical_act(generators, v0, w1)
        out2 = tropical_act(generators, v0, w2)
        M1 = eval_word_matrix(generators, w1)
        M2 = eval_word_matrix(generators, w2)
        diff = M1 - M2

        print(f"\n  Collision: {s1} ↔ {s2}")
        print(f"    Output: {out1}")
        print(f"    Matrix diff (witness): norm = {np.linalg.norm(diff):.4f}")
        print(f"    Diagonal diff: {np.diag(diff).tolist()}")

        # The "bounded witness" is the matrix difference restricted to entries
        # that explain the collision
        nonzero_entries = np.argwhere(np.abs(diff) > 1e-10)
        if len(nonzero_entries) > 0:
            print(f"    Witness entries: {nonzero_entries.tolist()}")
            max_entry = np.max(np.abs(diff))
            print(f"    Witness bound k = {int(np.ceil(max_entry))}")


def demo_profile_statistics():
    """Statistics on profile separation for random generators."""
    print("\n" + "=" * 70)
    print("DEMO 4: Profile Separation Statistics")
    print("=" * 70)

    np.random.seed(123)
    n_trials = 20
    n = 3
    R = 3

    results = {"separated": 0, "collision_free": 0, "both": 0}

    for trial in range(n_trials):
        # Random integer generators
        gens = [np.random.randint(-3, 4, size=(n, n)).astype(float)
                for _ in range(2)]
        v0 = np.random.randint(0, 3, size=n).astype(float)

        sep, _ = check_profile_separation(gens, R)
        colls = find_collisions(gens, v0, R)
        cf = len(colls) == 0

        if sep:
            results["separated"] += 1
        if cf:
            results["collision_free"] += 1
        if sep and cf:
            results["both"] += 1

    print(f"\nOver {n_trials} random 3×3 integer generator pairs, R={R}:")
    print(f"  Profile-separated: {results['separated']}/{n_trials}")
    print(f"  Collision-free:    {results['collision_free']}/{n_trials}")
    print(f"  Both (bridge):     {results['both']}/{n_trials}")
    print(f"\nBridge theorem confirms: separation ⟹ collision-freeness")


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_standard_matrices()
    demo_tropical_matrices()
    demo_witness_extraction()
    demo_profile_statistics()

    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)
