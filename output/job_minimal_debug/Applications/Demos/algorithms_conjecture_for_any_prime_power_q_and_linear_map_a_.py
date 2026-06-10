"""
Algorithms for Rank-Entropy Computation and Tropical Information Theory

Implements the core algorithms from the research paper with full type hints,
docstrings, and complexity analysis.
"""

import numpy as np
from typing import Callable, Dict, List, Set, Tuple, Optional
from collections import Counter
from itertools import product
import math


# ================================================================
# Algorithm 1: Entropy Defect Computation
# ================================================================

def compute_entropy_defect(
    f: Callable[[tuple], tuple],
    domain: List[tuple]
) -> float:
    """
    Compute the entropy defect of f under uniform input.
    
    H(X) - H(f(X)) = log|domain| - log|range(f)|
    
    Time complexity: O(|domain| * T_f) where T_f is cost of evaluating f
    Space complexity: O(|range(f)|)
    
    Args:
        f: Function from domain elements to output tuples
        domain: List of all domain elements
        
    Returns:
        Entropy defect in nats (natural log units)
        
    Example:
        >>> domain = list(product([0,1], repeat=3))
        >>> f = lambda x: (x[0] ^ x[1], x[2])
        >>> compute_entropy_defect(f, domain)  # XOR preserves info partially
    """
    if not domain:
        return 0.0
    
    range_set = set(f(x) for x in domain)
    return math.log(len(domain)) - math.log(len(range_set))


def compute_entropy_defect_gf2_matrix(
    A: np.ndarray,
    n_cols: int
) -> float:
    """
    Compute entropy defect of a matrix over GF(2).
    
    Uses the algebraic Landauer principle:
        entropy_defect = dim(ker A) * log(2)
    
    Time complexity: O(rows * cols) for rank computation
    Space complexity: O(rows * cols)
    
    This is dramatically faster than enumerating all 2^n inputs.
    
    Args:
        A: Matrix over GF(2) (entries 0 or 1)
        n_cols: Number of columns (dimension of domain)
        
    Returns:
        Entropy defect = (n_cols - rank(A)) * log(2)
        
    Example:
        >>> A = np.array([[1, 0, 1], [0, 1, 1]])
        >>> compute_entropy_defect_gf2_matrix(A, 3)
        0.6931...  # = 1 * log(2), since ker dim = 1
    """
    # Compute rank over GF(2) using Gaussian elimination
    rank = gf2_rank(A)
    ker_dim = n_cols - rank
    return ker_dim * math.log(2)


def gf2_rank(A: np.ndarray) -> int:
    """
    Compute rank of matrix over GF(2) via Gaussian elimination.
    
    Time complexity: O(min(m,n) * m * n) where A is m×n
    Space complexity: O(m * n)
    
    Args:
        A: Integer matrix (will be reduced mod 2)
        
    Returns:
        Rank of A over GF(2)
    """
    M = A.copy() % 2
    rows, cols = M.shape
    rank = 0
    
    for col in range(cols):
        # Find pivot
        pivot = None
        for row in range(rank, rows):
            if M[row, col] % 2 == 1:
                pivot = row
                break
        
        if pivot is None:
            continue
        
        # Swap rows
        M[[rank, pivot]] = M[[pivot, rank]]
        
        # Eliminate
        for row in range(rows):
            if row != rank and M[row, col] % 2 == 1:
                M[row] = (M[row] + M[rank]) % 2
        
        rank += 1
    
    return rank


def gf2_kernel_basis(A: np.ndarray) -> List[np.ndarray]:
    """
    Compute a basis for ker(A) over GF(2).
    
    Time complexity: O(n^2 * m) for an m×n matrix
    Space complexity: O(n^2)
    
    Args:
        A: Integer matrix (entries mod 2)
        
    Returns:
        List of basis vectors for ker(A) over GF(2)
    """
    M = A.copy() % 2
    rows, cols = M.shape
    
    # Augment with identity for tracking
    aug = np.hstack([M.T, np.eye(cols, dtype=int)])  # cols × (rows + cols)
    
    # Row reduce the transpose
    rank = 0
    for col in range(rows):
        pivot = None
        for row in range(rank, cols):
            if aug[row, col] % 2 == 1:
                pivot = row
                break
        if pivot is None:
            continue
        aug[[rank, pivot]] = aug[[pivot, rank]]
        for row in range(cols):
            if row != rank and aug[row, col] % 2 == 1:
                aug[row] = (aug[row] + aug[rank]) % 2
        rank += 1
    
    # Kernel basis = rows of aug[rank:, rows:] (mod 2)
    kernel_vectors = []
    for i in range(rank, cols):
        v = aug[i, rows:] % 2
        if np.any(v):
            kernel_vectors.append(v)
    
    return kernel_vectors


# ================================================================
# Algorithm 2: Tropical Entropy Loss
# ================================================================

def compute_tropical_entropy_loss(
    f: Callable[[tuple], tuple],
    domain: List[tuple]
) -> float:
    """
    Compute tropical entropy loss = log(max fiber size).
    
    Time complexity: O(|domain| * T_f)
    Space complexity: O(|range(f)|)
    
    Args:
        f: Function from domain to codomain
        domain: List of all domain elements
        
    Returns:
        Tropical entropy loss in nats
    """
    if not domain:
        return 0.0
    
    outputs = [f(x) for x in domain]
    fiber_sizes = Counter(str(y) for y in outputs)
    return math.log(max(fiber_sizes.values()))


def compute_fiber_spectrum(
    f: Callable[[tuple], tuple],
    domain: List[tuple]
) -> Dict[int, int]:
    """
    Compute the fiber spectrum: how many outputs have each fiber size.
    
    Time complexity: O(|domain| * T_f)
    Space complexity: O(|range(f)|)
    
    Args:
        f: Function from domain to codomain
        domain: List of all domain elements
        
    Returns:
        Dictionary mapping fiber_size -> count_of_outputs_with_that_size
        
    Example:
        >>> domain = list(product([0,1], repeat=3))
        >>> f = lambda x: (x[0] & x[1], x[2])
        >>> compute_fiber_spectrum(f, domain)
        {1: 2, 3: 2}  # 2 outputs have 1 preimage, 2 have 3 preimages
    """
    outputs = [str(f(x)) for x in domain]
    fiber_sizes = Counter(outputs)
    spectrum = Counter(fiber_sizes.values())
    return dict(spectrum)


def is_constant_fiber(
    f: Callable[[tuple], tuple],
    domain: List[tuple]
) -> Tuple[bool, Optional[int]]:
    """
    Check if f has constant fibers (all nonempty fibers equal size).
    
    Returns (True, fiber_size) or (False, None).
    
    Time complexity: O(|domain| * T_f)
    """
    outputs = [str(f(x)) for x in domain]
    fiber_sizes = Counter(outputs)
    sizes = set(fiber_sizes.values())
    if len(sizes) == 1:
        return True, sizes.pop()
    return False, None


def shannon_tropical_gap(
    f: Callable[[tuple], tuple],
    domain: List[tuple]
) -> float:
    """
    Compute the gap: tropical_loss - shannon_loss ≥ 0.
    
    This is zero iff f has constant fibers.
    """
    return compute_tropical_entropy_loss(f, domain) - compute_entropy_defect(f, domain)


# ================================================================
# Algorithm 3: Garbage Compression Analysis
# ================================================================

def analyze_garbage_compression(
    f: Callable[[tuple], tuple],
    g: Callable[[tuple], tuple],
    domain: List[tuple]
) -> Dict[str, float]:
    """
    Analyze the thermodynamic cost of garbage in a reversible implementation.
    
    Given f (the desired computation) and g (the garbage function),
    compute various entropy/complexity bounds.
    
    Time complexity: O(|domain| * (T_f + T_g))
    
    Args:
        f: Target function
        g: Garbage function
        domain: Input domain
        
    Returns:
        Dictionary with:
        - 'garbage_range_size': |range(g)|
        - 'naive_erasure_cost': log(|codomain of g|) (not computed, needs codomain info)
        - 'compressed_erasure_cost': log(|range(g)|)
        - 'entropy_defect_of_garbage': log|domain| - log|range(g)|
        - 'is_constant_fiber': whether g has constant fibers
    """
    garbage_outputs = set(g(x) for x in domain)
    garbage_range_size = len(garbage_outputs)
    
    const, fiber_size = is_constant_fiber(g, domain)
    
    return {
        'garbage_range_size': garbage_range_size,
        'compressed_erasure_cost': math.log(garbage_range_size),
        'entropy_defect_of_garbage': compute_entropy_defect(g, domain),
        'tropical_loss_of_garbage': compute_tropical_entropy_loss(g, domain),
        'is_constant_fiber': const,
        'fiber_size': fiber_size,
    }


def find_optimal_garbage_compression(
    g: Callable[[tuple], tuple],
    domain: List[tuple]
) -> Tuple[int, float]:
    """
    Find the minimal compressed garbage size and its erasure cost.
    
    The optimal compression maps range(g) bijectively to {0, ..., |range(g)|-1}.
    
    Returns:
        (compressed_size, compressed_erasure_cost)
    """
    garbage_range = set(g(x) for x in domain)
    compressed_size = len(garbage_range)
    return compressed_size, math.log(compressed_size) if compressed_size > 0 else 0.0


# ================================================================
# Algorithm 4: Systematic GF(2) Matrix Survey
# ================================================================

def survey_gf2_matrices(m: int, n: int) -> List[Dict]:
    """
    Survey all m×n matrices over GF(2) and verify the rank-entropy law.
    
    Time complexity: O(2^(m*n) * 2^n * m * n) — exponential, for small m,n only
    
    Args:
        m: Number of rows
        n: Number of columns
        
    Returns:
        List of results for each distinct rank
    """
    domain = [np.array(v) for v in product([0, 1], repeat=n)]
    
    results_by_rank = {}
    
    # Enumerate all m×n GF(2) matrices
    total_matrices = 2 ** (m * n)
    for idx in range(total_matrices):
        # Convert index to matrix
        entries = [(idx >> i) & 1 for i in range(m * n)]
        A = np.array(entries).reshape(m, n)
        
        rank = gf2_rank(A)
        if rank in results_by_rank:
            results_by_rank[rank]['count'] += 1
            continue
        
        ker_dim = n - rank
        
        # Compute entropy defect by enumeration
        f = lambda x, A=A: tuple((A @ x % 2).astype(int))
        ed_enum = compute_entropy_defect(f, domain)
        
        # Compute by formula
        ed_formula = ker_dim * math.log(2)
        
        # Verify constant fibers
        const, fsize = is_constant_fiber(f, domain)
        
        # Shannon-tropical comparison
        trop = compute_tropical_entropy_loss(f, domain)
        
        results_by_rank[rank] = {
            'rank': rank,
            'ker_dim': ker_dim,
            'entropy_defect_enum': ed_enum,
            'entropy_defect_formula': ed_formula,
            'match': abs(ed_enum - ed_formula) < 1e-10,
            'constant_fibers': const,
            'fiber_size': fsize,
            'shannon_tropical_equal': abs(ed_enum - trop) < 1e-10,
            'count': 1,
            'example_matrix': A.tolist(),
        }
    
    return sorted(results_by_rank.values(), key=lambda r: r['rank'])


# ================================================================
# Main: Run all examples
# ================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Systematic Survey: All 2×3 Matrices over GF(2)")
    print("=" * 70)
    print()
    
    results = survey_gf2_matrices(2, 3)
    
    print(f"{'Rank':>4} {'ker_dim':>7} {'ED(enum)':>10} {'ED(form)':>10} "
          f"{'Match':>6} {'ConstFib':>8} {'Sh=Trop':>8} {'Count':>6}")
    print("-" * 65)
    
    for r in results:
        print(f"{r['rank']:>4} {r['ker_dim']:>7} {r['entropy_defect_enum']:>10.4f} "
              f"{r['entropy_defect_formula']:>10.4f} "
              f"{'✓' if r['match'] else '✗':>6} "
              f"{'✓' if r['constant_fibers'] else '✗':>8} "
              f"{'✓' if r['shannon_tropical_equal'] else '✗':>8} "
              f"{r['count']:>6}")
    
    all_match = all(r['match'] for r in results)
    all_constant = all(r['constant_fibers'] for r in results)
    all_sh_trop = all(r['shannon_tropical_equal'] for r in results)
    
    print()
    print(f"All entropy defects match formula: {'✓' if all_match else '✗'}")
    print(f"All linear maps have constant fibers: {'✓' if all_constant else '✗'}")
    print(f"Shannon = Tropical for all linear maps: {'✓' if all_sh_trop else '✗'}")
    print(f"Total matrices surveyed: {sum(r['count'] for r in results)}")
    
    print()
    print("=" * 70)
    print("Garbage Compression Analysis for Parity")
    print("=" * 70)
    print()
    
    for n in range(2, 7):
        domain = list(product([0, 1], repeat=n))
        f_parity = lambda x: (sum(x) % 2,)
        g_all_but_last = lambda x: x[:-1]  # Garbage = all bits except last
        
        analysis = analyze_garbage_compression(f_parity, g_all_but_last, domain)
        opt_size, opt_cost = find_optimal_garbage_compression(g_all_but_last, domain)
        
        print(f"n={n}: garbage range size = {analysis['garbage_range_size']}, "
              f"compressed cost = {analysis['compressed_erasure_cost']:.3f}, "
              f"naive cost = {math.log(2**n):.3f}, "
              f"savings = {math.log(2**n) - analysis['compressed_erasure_cost']:.3f}")
