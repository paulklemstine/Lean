"""
Algorithms for Topological Quantum Compiling
=============================================

Implements the core algorithms from the research paper:
1. Solovay-Kitaev gate approximation using braid words
2. Fibonacci anyon fusion tree enumeration
3. Jones representation computation
4. Braid word optimization (cancellation of inverse pairs)
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum


class Sign(Enum):
    POS = 1
    NEG = -1


@dataclass
class BraidGenerator:
    """A braid generator σ_i^{±1} in B_n."""
    index: int
    sign: Sign

    def inverse(self) -> 'BraidGenerator':
        return BraidGenerator(
            self.index,
            Sign.NEG if self.sign == Sign.POS else Sign.POS
        )

    def __repr__(self):
        s = "" if self.sign == Sign.POS else "⁻¹"
        return f"σ_{self.index}{s}"


BraidWord = List[BraidGenerator]


# ============================================================
# Algorithm 1: Braid Word Algebra
# ============================================================

def compose(w1: BraidWord, w2: BraidWord) -> BraidWord:
    """Compose two braid words. O(|w1| + |w2|)."""
    return w1 + w2


def inverse_word(w: BraidWord) -> BraidWord:
    """Compute the inverse of a braid word. O(|w|)."""
    return [g.inverse() for g in reversed(w)]


def exponent_sum(w: BraidWord) -> int:
    """Compute the exponent sum (abelianization homomorphism B_n → ℤ). O(|w|)."""
    return sum(g.sign.value for g in w)


def word_length(w: BraidWord) -> int:
    """Word length of a braid word. O(1)."""
    return len(w)


# ============================================================
# Algorithm 2: Free Cancellation (Braid Word Reduction)
# ============================================================

def free_reduce(w: BraidWord) -> BraidWord:
    """Free reduction of a braid word: cancel adjacent σ_i · σ_i^{-1} pairs.

    Time complexity: O(|w|)
    Space complexity: O(|w|)

    This is a greedy algorithm that processes generators left to right,
    maintaining a stack. When the new generator cancels with the top of
    the stack, both are removed.

    Note: This does NOT produce a fully reduced braid word (that requires
    solving the word problem in B_n, which needs Garside's algorithm).
    It only performs free cancellations.

    Returns:
        A freely reduced braid word equivalent to w in the free group.
    """
    stack: BraidWord = []
    for g in w:
        if stack and stack[-1].index == g.index and stack[-1].sign != g.sign:
            stack.pop()
        else:
            stack.append(g)
    return stack


# ============================================================
# Algorithm 3: Fibonacci Dimension Computation
# ============================================================

def fibonacci_dim(n: int) -> int:
    """Compute the Fibonacci anyon fusion space dimension.

    Uses the recurrence: fibDim(0) = 1, fibDim(1) = 1,
    fibDim(n+2) = fibDim(n) + fibDim(n+1).

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        n: Number of anyons (non-negative integer)

    Returns:
        Dimension of the fusion space for n Fibonacci anyons
    """
    if n <= 1:
        return 1
    a, b = 1, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


# ============================================================
# Algorithm 4: Jones Representation Matrices
# ============================================================

def jones_rep_fibonacci(n_strands: int) -> List[np.ndarray]:
    """Compute the Jones representation matrices for B_n with Fibonacci anyons.

    At level k=5 (Fibonacci anyons), the braiding matrices are determined by
    the F-matrices and R-matrices of the Fibonacci fusion category.

    For the 3-dimensional representation (n=4 strands), we use the explicit
    construction from the Fibonacci anyon model.

    Time complexity: O(d^3) per generator where d = fibDim(n-1)
    Space complexity: O(d^2 * (n-1)) for storing all generators

    Args:
        n_strands: Number of strands (must be >= 2)

    Returns:
        List of (n-1) unitary matrices representing σ_1, ..., σ_{n-1}
    """
    phi = (1 + np.sqrt(5)) / 2
    tau = 1 / phi

    # R-matrix eigenvalues for Fibonacci anyons
    r_1 = np.exp(-4j * np.pi / 5)   # trivial channel
    r_tau = np.exp(3j * np.pi / 5)  # Fibonacci channel

    if n_strands == 4:
        # 3-dimensional representation
        # F-matrix for the Fibonacci category
        F = np.array([
            [tau, np.sqrt(tau)],
            [np.sqrt(tau), -tau]
        ], dtype=complex)

        # Build the three generators
        R_diag = np.diag([r_tau, r_1])

        # σ₁ acts on the first two anyons
        sigma1 = np.zeros((3, 3), dtype=complex)
        sigma1[0, 0] = r_tau
        block = F @ R_diag @ np.linalg.inv(F)
        sigma1[1:, 1:] = block

        # σ₂ acts on the middle two anyons
        sigma2 = np.zeros((3, 3), dtype=complex)
        block2 = F @ R_diag @ np.linalg.inv(F)
        sigma2[:2, :2] = block2
        sigma2[2, 2] = r_tau

        # σ₃ acts on the last two anyons
        sigma3 = np.zeros((3, 3), dtype=complex)
        sigma3[0, 0] = r_tau
        sigma3[1, 1] = r_tau
        sigma3[2, 2] = r_1

        return [sigma1, sigma2, sigma3]

    elif n_strands == 3:
        # 2-dimensional representation
        F = np.array([
            [tau, np.sqrt(tau)],
            [np.sqrt(tau), -tau]
        ], dtype=complex)

        R_diag = np.diag([r_tau, r_1])
        sigma1 = F @ R_diag @ np.linalg.inv(F)
        sigma2 = R_diag

        return [sigma1, sigma2]

    else:
        raise NotImplementedError(
            f"Jones representation for {n_strands} strands not yet implemented. "
            f"Only 3 and 4 strands are currently supported."
        )


def evaluate_braid_word(word: BraidWord, matrices: List[np.ndarray]) -> np.ndarray:
    """Evaluate a braid word as a matrix product using the Jones representation.

    Time complexity: O(|word| * d^3) where d is the matrix dimension

    Args:
        word: Braid word to evaluate
        matrices: List of generator matrices [σ_1, σ_2, ..., σ_{n-1}]

    Returns:
        Product matrix ρ(word)
    """
    d = matrices[0].shape[0]
    result = np.eye(d, dtype=complex)
    for g in word:
        M = matrices[g.index]
        if g.sign == Sign.NEG:
            M = np.linalg.inv(M)
        result = result @ M
    return result


# ============================================================
# Algorithm 5: Solovay-Kitaev Approximation (Simplified)
# ============================================================

def solovay_kitaev_search(
    target: np.ndarray,
    generators: List[np.ndarray],
    max_length: int = 10,
    tolerance: float = 0.1
) -> Tuple[Optional[BraidWord], float]:
    """Brute-force search for a braid word approximating a target unitary.

    This is a simplified version of the Solovay-Kitaev algorithm that uses
    exhaustive search over short braid words. The full SK algorithm achieves
    O(log^c(1/ε)) word length for precision ε, where c ≈ 3.97.

    Time complexity: O((2g)^L * d^3) where g = number of generators, L = max_length
    Space complexity: O(d^2 * (2g)^L) for storing all matrices

    Args:
        target: Target unitary matrix to approximate
        generators: Braid generator matrices
        max_length: Maximum braid word length to search
        tolerance: Required approximation precision (operator norm)

    Returns:
        Tuple of (best_word, best_distance) or (None, inf) if no good approximation found
    """
    d = target.shape[0]
    n_gens = len(generators)

    # Precompute inverse generators
    all_gens = []
    for i, g in enumerate(generators):
        all_gens.append((BraidGenerator(i, Sign.POS), g))
        all_gens.append((BraidGenerator(i, Sign.NEG), np.linalg.inv(g)))

    best_word: Optional[BraidWord] = None
    best_dist = float('inf')

    # BFS over braid words of increasing length
    queue: List[Tuple[BraidWord, np.ndarray]] = [([], np.eye(d, dtype=complex))]

    for length in range(max_length + 1):
        next_queue = []
        for word, matrix in queue:
            dist = np.linalg.norm(matrix - target, ord=2)
            if dist < best_dist:
                best_dist = dist
                best_word = word
                if dist < tolerance:
                    return best_word, best_dist

            if length < max_length:
                for gen, gen_mat in all_gens:
                    new_word = word + [gen]
                    new_mat = matrix @ gen_mat
                    next_queue.append((new_word, new_mat))

        queue = next_queue

    return best_word, best_dist


# ============================================================
# Algorithm 6: Infinite Order Test
# ============================================================

def test_infinite_order(
    matrix: np.ndarray,
    max_power: int = 1000,
    tolerance: float = 1e-8
) -> Tuple[bool, int]:
    """Test whether a unitary matrix has infinite order.

    Checks if M^m = I for any 1 ≤ m ≤ max_power.

    Time complexity: O(max_power * d^3)
    Space complexity: O(d^2)

    Args:
        matrix: Unitary matrix to test
        max_power: Maximum power to check
        tolerance: Tolerance for identity check

    Returns:
        Tuple of (is_infinite_order, first_identity_power_or_0)
    """
    d = matrix.shape[0]
    identity = np.eye(d, dtype=complex)
    power = np.eye(d, dtype=complex)

    for m in range(1, max_power + 1):
        power = power @ matrix
        if np.allclose(power, identity, atol=tolerance):
            return False, m

    return True, 0


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHMS DEMO")
    print("=" * 60)

    # Fibonacci dimensions
    print("\nFibonacci dimensions for 1-10 anyons:")
    for n in range(1, 11):
        print(f"  {n} anyons: dim = {fibonacci_dim(n)}")

    # Braid word algebra
    w = [BraidGenerator(0, Sign.POS), BraidGenerator(1, Sign.POS),
         BraidGenerator(0, Sign.NEG), BraidGenerator(1, Sign.POS)]
    print(f"\nBraid word: {w}")
    print(f"  Length: {word_length(w)}")
    print(f"  Exponent sum: {exponent_sum(w)}")
    print(f"  Free reduced: {free_reduce(w)}")

    # Jones representation
    print("\nJones representation (k=5, B_4):")
    gens = jones_rep_fibonacci(4)
    for i, g in enumerate(gens):
        print(f"  σ_{i+1}:")
        for row in g:
            print(f"    [{', '.join(f'{x.real:+.4f}{x.imag:+.4f}i' for x in row)}]")

    # Infinite order test
    product = gens[0] @ gens[1] @ gens[2]
    is_inf, order = test_infinite_order(product)
    print(f"\nInfinite order test for σ₁σ₂σ₃:")
    print(f"  Infinite order (up to m=1000): {is_inf}")
    if not is_inf:
        print(f"  Finite order: {order}")
