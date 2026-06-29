#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for FO quotient invariance analysis.

Implements:
1. Kernel computation for linear maps over Z/qZ
2. Fiber decomposition and quotient predicate descent
3. FO consistency evaluation and rejection rate computation
4. Kernel invariance verification for weight functions
5. Game hop bound computation

All algorithms operate on finite modules over Z/qZ and are designed
for rigorous computational verification of the quotient invariance
theorems.
"""

import itertools
from collections import defaultdict
from typing import (
    Callable, Dict, List, Optional, Set, Tuple, TypeVar,
)

# Type aliases
Element = Tuple[int, ...]
Matrix = Tuple[Tuple[int, ...], ...]


def mod_vec(v: Element, q: int) -> Element:
    """Reduce vector entries modulo q."""
    return tuple(x % q for x in v)


def add_mod(a: Element, b: Element, q: int) -> Element:
    """Add two vectors modulo q."""
    return tuple((ai + bi) % q for ai, bi in zip(a, b))


def sub_mod(a: Element, b: Element, q: int) -> Element:
    """Subtract two vectors modulo q."""
    return tuple((ai - bi) % q for ai, bi in zip(a, b))


def dot_mod(a: Element, b: Element, q: int) -> int:
    """Inner product modulo q."""
    return sum(ai * bi for ai, bi in zip(a, b)) % q


def mat_vec_mod(A: Matrix, v: Element, q: int) -> Element:
    """Matrix-vector product modulo q."""
    return tuple(dot_mod(row, v, q) for row in A)


# ---------------------------------------------------------------------------
# Algorithm 1: Kernel Computation
# ---------------------------------------------------------------------------

def compute_kernel(matrix: Matrix, q: int, n: int) -> List[Element]:
    """
    Compute the kernel of a linear map f: (Z/qZ)^n -> (Z/qZ)^m
    represented by an m×n matrix.

    Algorithm: Brute-force enumeration (exact for small instances).

    Complexity: O(q^n · m · n) time, O(|ker|) space.

    Args:
        matrix: m×n matrix over Z/qZ (tuple of row tuples)
        q: modulus
        n: dimension of domain

    Returns:
        List of all vectors v in (Z/qZ)^n with A·v ≡ 0 (mod q)
    """
    kernel = []
    for v in itertools.product(range(q), repeat=n):
        if all(dot_mod(row, v, q) == 0 for row in matrix):
            kernel.append(v)
    return kernel


def compute_image(matrix: Matrix, q: int, n: int) -> Set[Element]:
    """
    Compute the image of a linear map.

    Complexity: O(q^n · m · n) time.
    """
    image = set()
    for v in itertools.product(range(q), repeat=n):
        image.add(mat_vec_mod(matrix, v, q))
    return image


# ---------------------------------------------------------------------------
# Algorithm 2: Fiber Decomposition
# ---------------------------------------------------------------------------

def compute_fibers(
    f: Callable[[Element], Element],
    domain: List[Element],
) -> Dict[Element, List[Element]]:
    """
    Partition domain elements by fibers of f.

    Algorithm: Hash each element by its image under f.

    Complexity: O(|domain| · T(f)) where T(f) is the time to evaluate f.

    Args:
        f: function from domain to codomain
        domain: list of domain elements

    Returns:
        Dictionary mapping codomain elements to their preimage lists
    """
    fibers: Dict[Element, List[Element]] = defaultdict(list)
    for x in domain:
        fibers[f(x)].append(x)
    return dict(fibers)


# ---------------------------------------------------------------------------
# Algorithm 3: FO Consistency Evaluation
# ---------------------------------------------------------------------------

def evaluate_fo_consistency(
    reencrypt: Callable[[int, int], Element],
    recover: Callable[[Element], Tuple[int, int]],
    ciphertext: Element,
) -> bool:
    """
    Evaluate the FO consistency predicate on a single ciphertext.

    The FO check: recover the key-message pair (k, m) from c,
    re-encrypt to get c' = reencrypt(k, m), and check c' == c.

    Complexity: O(T(recover) + T(reencrypt) + T(compare))

    Args:
        reencrypt: encryption function (key, message) -> ciphertext
        recover: decapsulation function ciphertext -> (key, message)
        ciphertext: the ciphertext to check

    Returns:
        True if re-encryption matches the original ciphertext
    """
    k, m = recover(ciphertext)
    return reencrypt(k, m) == ciphertext


def compute_rejection_rate(
    reencrypt: Callable,
    recover: Callable,
    ciphertexts: List[Element],
    weight_fn: Optional[Callable[[Element], float]] = None,
) -> Tuple[float, float]:
    """
    Compute FO acceptance and rejection rates over a finite ciphertext space.

    Complexity: O(|ciphertexts| · (T(reencrypt) + T(recover)))

    Args:
        reencrypt: encryption function
        recover: decapsulation function
        ciphertexts: finite ciphertext space
        weight_fn: probability weight for each ciphertext (uniform if None)

    Returns:
        (acceptance_rate, rejection_rate) tuple
    """
    if weight_fn is None:
        n = len(ciphertexts)
        weight_fn = lambda _: 1.0 / n

    accept = 0.0
    reject = 0.0
    for c in ciphertexts:
        w = weight_fn(c)
        if evaluate_fo_consistency(reencrypt, recover, c):
            accept += w
        else:
            reject += w
    return accept, reject


# ---------------------------------------------------------------------------
# Algorithm 4: Kernel Invariance Verification
# ---------------------------------------------------------------------------

def verify_kernel_invariance(
    weight_fn: Callable[[Element], float],
    kernel: List[Element],
    domain: List[Element],
    q: int,
    tolerance: float = 1e-12,
) -> Tuple[bool, Optional[Tuple[Element, Element, float, float]]]:
    """
    Verify whether a weight function is kernel-invariant.

    A weight function μ is kernel-invariant w.r.t. ker(f) if
    μ(x) = μ(x + k) for all x in domain and k in ker(f).

    Complexity: O(|domain| · |kernel|)

    Args:
        weight_fn: the weight function to check
        kernel: kernel elements
        domain: all domain elements
        q: modulus
        tolerance: numerical tolerance

    Returns:
        (is_invariant, counterexample_or_none)
        If not invariant, returns (x, x+k, μ(x), μ(x+k))
    """
    for x in domain:
        for k in kernel:
            y = add_mod(x, k, q)
            wx, wy = weight_fn(x), weight_fn(y)
            if abs(wx - wy) > tolerance:
                return False, (x, y, wx, wy)
    return True, None


# ---------------------------------------------------------------------------
# Algorithm 5: Predicate Fiber Constancy Check
# ---------------------------------------------------------------------------

def verify_predicate_fiber_constancy(
    predicate: Callable[[Element], bool],
    compress: Callable[[Element], Element],
    domain: List[Element],
) -> Tuple[bool, Optional[Tuple[Element, Element, Element]]]:
    """
    Verify that a predicate is constant on fibers of a compression map.

    This checks the hypothesis of Theorem 1: PredicateFactorsThrough.

    Complexity: O(|domain|)

    Args:
        predicate: boolean predicate on domain elements
        compress: compression map
        domain: all domain elements

    Returns:
        (is_fiber_constant, counterexample_or_none)
        If not constant, returns (compressed_value, x1, x2)
        where predicate(x1) != predicate(x2) but compress(x1) == compress(x2)
    """
    fiber_values: Dict[Element, Tuple[bool, Element]] = {}
    for x in domain:
        key = compress(x)
        val = predicate(x)
        if key in fiber_values:
            if fiber_values[key][0] != val:
                return False, (key, fiber_values[key][1], x)
        else:
            fiber_values[key] = (val, x)
    return True, None


# ---------------------------------------------------------------------------
# Algorithm 6: Game Hop Bound Computation
# ---------------------------------------------------------------------------

def compute_game_hop_bound(
    real_game: Callable[[Element], float],
    hybrid_game: Callable[[Element], float],
    predicate: Callable[[Element], bool],
    weight_fn: Callable[[Element], float],
    domain: List[Element],
) -> Dict[str, float]:
    """
    Compute both sides of the game hop bound:
      |Σ μ(c)·R(c) - Σ μ(c)·H(c)| ≤ Σ_{¬P(c)} μ(c)

    This verifies Theorem 3 computationally.

    Complexity: O(|domain|)

    Args:
        real_game: real game output function
        hybrid_game: hybrid game output function
        predicate: "good event" predicate
        weight_fn: probability weights
        domain: finite domain

    Returns:
        Dictionary with 'lhs', 'rhs', and 'bound_holds' keys
    """
    sum_real = sum(weight_fn(c) * real_game(c) for c in domain)
    sum_hybrid = sum(weight_fn(c) * hybrid_game(c) for c in domain)
    lhs = abs(sum_real - sum_hybrid)

    bad_weight = sum(weight_fn(c) for c in domain if not predicate(c))

    return {
        'lhs': lhs,
        'rhs': bad_weight,
        'bound_holds': lhs <= bad_weight + 1e-12,
        'sum_real': sum_real,
        'sum_hybrid': sum_hybrid,
        'gap': lhs,
    }


# ---------------------------------------------------------------------------
# Algorithm 7: Complete FO Quotient Analysis Pipeline
# ---------------------------------------------------------------------------

def full_fo_analysis(
    q: int,
    n: int,
    compression_matrix: Matrix,
    reencrypt: Callable,
    recover: Callable,
    weight_fn: Optional[Callable] = None,
) -> Dict:
    """
    Complete analysis pipeline: verify all three theorems on a toy instance.

    Steps:
    1. Compute kernel and fibers of compression
    2. Check kernel invariance of weight function
    3. Check fiber constancy of FO predicate
    4. Compute rejection rates before/after compression
    5. Verify game hop bound

    Complexity: O(q^n · (|kernel| + m·n))

    Returns:
        Dictionary with all analysis results
    """
    domain = list(itertools.product(range(q), repeat=n))
    if weight_fn is None:
        weight_fn = lambda _: 1.0 / len(domain)

    compress = lambda v: mat_vec_mod(compression_matrix, v, q)
    kernel = compute_kernel(compression_matrix, q, n)
    fibers = compute_fibers(compress, domain)

    # Check kernel invariance
    ki_result, ki_counter = verify_kernel_invariance(
        weight_fn, kernel, domain, q
    )

    # FO predicate
    fo_pred = lambda c: evaluate_fo_consistency(reencrypt, recover, c)

    # Check fiber constancy
    fc_result, fc_counter = verify_predicate_fiber_constancy(
        fo_pred, compress, domain
    )

    # Rejection rates
    accept_before, reject_before = compute_rejection_rate(
        reencrypt, recover, domain, weight_fn
    )

    # Rejection rate after compression (fiber-wise)
    reject_after = 0.0
    for fiber_key, fiber_elts in fibers.items():
        rep = fiber_elts[0]
        if not fo_pred(rep):
            reject_after += sum(weight_fn(c) for c in fiber_elts)
    accept_after = 1.0 - reject_after

    # Game hop bound
    real_game = lambda c: 1.0
    hybrid_game = lambda c: 1.0 if fo_pred(c) else 0.0
    ghb = compute_game_hop_bound(
        real_game, hybrid_game, fo_pred, weight_fn, domain
    )

    return {
        'q': q,
        'n': n,
        'space_size': len(domain),
        'kernel_size': len(kernel),
        'num_fibers': len(fibers),
        'kernel_invariant': ki_result,
        'ki_counterexample': ki_counter,
        'fiber_constant': fc_result,
        'fc_counterexample': fc_counter,
        'reject_before': reject_before,
        'reject_after': reject_after,
        'rates_match': abs(reject_before - reject_after) < 1e-12,
        'game_hop': ghb,
    }


if __name__ == "__main__":
    print("Running FO quotient analysis pipeline on toy instances...\n")

    for q in [3, 5, 7]:
        matrix = ((1, 0),)  # Project to first coordinate
        reencrypt = lambda k, m, q=q: (k % q, m % q)
        recover = lambda c: (c[0], c[1])

        result = full_fo_analysis(q, 2, matrix, reencrypt, recover)

        print(f"q={q}, n=2, compression=projection:")
        print(f"  Space size: {result['space_size']}")
        print(f"  Kernel size: {result['kernel_size']}")
        print(f"  Kernel invariant: {result['kernel_invariant']}")
        print(f"  Fiber constant: {result['fiber_constant']}")
        print(f"  Reject before: {result['reject_before']:.6f}")
        print(f"  Reject after:  {result['reject_after']:.6f}")
        print(f"  Rates match:   {result['rates_match']}")
        print(f"  Game hop bound holds: {result['game_hop']['bound_holds']}")
        print()
