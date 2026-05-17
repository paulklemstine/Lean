#!/usr/bin/env python3
"""
Algorithms for Tropical Perturbation Amplification

Implements the core computational algorithms underlying the tropical
perturbation tensorization law, including:
1. Tropical max functional evaluation
2. Weight recovery from functional evaluations
3. Perturbation bound computation and verification
4. Product system analysis
5. N-fold amplification computation
"""

import math
import numpy as np
from typing import Dict, List, Tuple, Optional, Callable, Any


# ============================================================
# Algorithm 1: Tropical Max Functional
# ============================================================

def tropical_max(
    support: List[Any],
    weights: Dict[Any, float],
    f: Dict[Any, float]
) -> float:
    """
    Evaluate the tropical max functional F(f) = max_{s in S} (f(s) + w(s)).

    Time complexity: O(|S|)
    Space complexity: O(1)

    Parameters:
        support: List of support elements S
        weights: Weight function w : S → ℝ
        f: Input function f : S → ℝ

    Returns:
        max_{s in S} (f(s) + w(s))

    Example:
        >>> S = [0, 1, 2]
        >>> w = {0: 1.0, 1: -0.5, 2: 0.3}
        >>> f = {0: 0.0, 1: 2.0, 2: 1.0}
        >>> tropical_max(S, w, f)
        1.5
    """
    if not support:
        raise ValueError("Support must be nonempty")
    return max(f[s] + weights[s] for s in support)


def tropical_max_argmax(
    support: List[Any],
    weights: Dict[Any, float],
    f: Dict[Any, float]
) -> Tuple[float, Any]:
    """
    Evaluate the tropical max functional and return the achieving element.

    Time complexity: O(|S|)
    Space complexity: O(1)

    Returns:
        (value, achieving_element)
    """
    if not support:
        raise ValueError("Support must be nonempty")
    best_s = support[0]
    best_val = f[best_s] + weights[best_s]
    for s in support[1:]:
        val = f[s] + weights[s]
        if val > best_val:
            best_val = val
            best_s = s
    return best_val, best_s


# ============================================================
# Algorithm 2: Weight Recovery
# ============================================================

def recover_weights(
    support: List[Any],
    functional: Callable[[Dict[Any, float]], float],
    M: Optional[float] = None
) -> Dict[Any, float]:
    """
    Recover weights from a tropical max functional using isolation test functions.

    Given access to F(f) = max_{s in S} (f(s) + w(s)), recovers each w(s) by
    evaluating F on a test function that isolates s:
        f_s(a) = 0 if a = s, -M otherwise
    For large M, F(f_s) = w(s).

    Time complexity: O(|S|) evaluations of the functional
    Space complexity: O(|S|)

    Parameters:
        support: List of support elements
        functional: Black-box access to F
        M: Isolation parameter (default: auto-computed)

    Returns:
        Dictionary mapping support elements to recovered weights

    Pseudocode:
        RECOVER-WEIGHTS(S, F):
            M ← sufficiently large constant
            for each s in S:
                f ← function with f(s) = 0, f(a) = -M for a ≠ s
                w[s] ← F(f)
            return w
    """
    if M is None:
        M = 1e10  # Sufficiently large for practical purposes

    recovered = {}
    for s in support:
        test_f = {a: (0.0 if a == s else -M) for a in support}
        recovered[s] = functional(test_f)

    return recovered


# ============================================================
# Algorithm 3: Tropical Perturbation Bound
# ============================================================

def tropical_perturbation_bound(cardinality: int) -> float:
    """
    Compute the tropical perturbation bound Φ(S) = log |S|.

    Time complexity: O(1)
    Space complexity: O(1)

    Parameters:
        cardinality: |S|, the number of elements in the support

    Returns:
        log(|S|), the natural logarithm of the cardinality

    Pseudocode:
        TROPICAL-BOUND(n):
            return ln(n)
    """
    if cardinality <= 0:
        raise ValueError("Cardinality must be positive")
    return math.log(cardinality)


def tropical_bit_complexity(cardinality: int) -> float:
    """
    Compute the tropical bit complexity Φ₂(S) = log₂ |S|.

    Time complexity: O(1)
    """
    if cardinality <= 0:
        raise ValueError("Cardinality must be positive")
    return math.log2(cardinality)


# ============================================================
# Algorithm 4: Product System Analysis
# ============================================================

def product_bound_additive(
    card_S: int,
    card_T: int
) -> Tuple[float, float, float, float]:
    """
    Verify the tensorization law Φ(S × T) = Φ(S) + Φ(T).

    Time complexity: O(1)

    Returns:
        (Φ(S), Φ(T), Φ(S) + Φ(T), Φ(S × T))

    Pseudocode:
        PRODUCT-BOUND(|S|, |T|):
            φS ← ln(|S|)
            φT ← ln(|T|)
            φST ← ln(|S| · |T|)
            assert φST = φS + φT
            return (φS, φT, φS + φT, φST)
    """
    phi_s = tropical_perturbation_bound(card_S)
    phi_t = tropical_perturbation_bound(card_T)
    phi_sum = phi_s + phi_t
    phi_product = tropical_perturbation_bound(card_S * card_T)
    return phi_s, phi_t, phi_sum, phi_product


def n_fold_amplification(
    card_S: int,
    n: int
) -> Tuple[float, float]:
    """
    Compute n-fold amplification: Φ(S^n) = n · Φ(S).

    Time complexity: O(1) (using log identity)

    Returns:
        (Φ(S^n), n · Φ(S))

    Pseudocode:
        N-FOLD-BOUND(|S|, n):
            φ ← ln(|S|)
            return (n · φ, ln(|S|^n))
    """
    phi = tropical_perturbation_bound(card_S)
    return n * phi, math.log(card_S ** n) if card_S ** n > 0 else float('-inf')


# ============================================================
# Algorithm 5: Perturbation Verification
# ============================================================

def verify_perturbation_stability(
    support: List[Any],
    w1: Dict[Any, float],
    w2: Dict[Any, float],
    epsilon: float,
    n_tests: int = 1000,
    seed: int = 42
) -> Tuple[bool, float, float]:
    """
    Verify that weight perturbation ≤ ε implies functional perturbation ≤ ε.

    This implements the certified perturbation bound check:
    if max_{s in S} |w1(s) - w2(s)| ≤ ε, then
    max_f |F_{w1}(f) - F_{w2}(f)| ≤ ε.

    Time complexity: O(n_tests · |S|)

    Parameters:
        support: Support set
        w1, w2: Two weight functions
        epsilon: Claimed perturbation bound
        n_tests: Number of random test functions
        seed: Random seed

    Returns:
        (passed, max_weight_diff, max_functional_diff)

    Pseudocode:
        VERIFY-PERTURBATION(S, w1, w2, ε, N):
            δw ← max_{s in S} |w1(s) - w2(s)|
            if δw > ε: return FAIL
            δF ← 0
            for i = 1 to N:
                f ← random function on S
                δF ← max(δF, |F_{w1}(f) - F_{w2}(f)|)
            return (δF ≤ ε, δw, δF)
    """
    rng = np.random.RandomState(seed)

    max_weight_diff = max(abs(w1[s] - w2[s]) for s in support)

    max_func_diff = 0.0
    for _ in range(n_tests):
        f = {s: rng.randn() for s in support}
        f1 = tropical_max(support, w1, f)
        f2 = tropical_max(support, w2, f)
        max_func_diff = max(max_func_diff, abs(f1 - f2))

    passed = max_weight_diff <= epsilon + 1e-12 and max_func_diff <= epsilon + 1e-12
    return passed, max_weight_diff, max_func_diff


# ============================================================
# Algorithm 6: Product Perturbation Composition
# ============================================================

def verify_product_perturbation(
    S: List[Any],
    T: List[Any],
    wS1: Dict[Any, float],
    wS2: Dict[Any, float],
    wT1: Dict[Any, float],
    wT2: Dict[Any, float],
    eps_S: float,
    eps_T: float,
    n_tests: int = 500,
    seed: int = 42
) -> Tuple[bool, float, float]:
    """
    Verify additive perturbation composition for product systems.

    If |wS1(s) - wS2(s)| ≤ εS and |wT1(t) - wT2(t)| ≤ εT, then
    the product functional perturbation ≤ εS + εT.

    Time complexity: O(n_tests · |S| · |T|)

    Returns:
        (passed, max_product_weight_diff, max_functional_diff)
    """
    rng = np.random.RandomState(seed)

    ST = [(s, t) for s in S for t in T]
    w_prod1 = {(s, t): wS1[s] + wT1[t] for s in S for t in T}
    w_prod2 = {(s, t): wS2[s] + wT2[t] for s in S for t in T}

    max_weight_diff = max(abs(w_prod1[p] - w_prod2[p]) for p in ST)

    max_func_diff = 0.0
    for _ in range(n_tests):
        f = {p: rng.randn() for p in ST}
        f1 = tropical_max(ST, w_prod1, f)
        f2 = tropical_max(ST, w_prod2, f)
        max_func_diff = max(max_func_diff, abs(f1 - f2))

    eps_total = eps_S + eps_T
    passed = max_func_diff <= eps_total + 1e-12
    return passed, max_weight_diff, max_func_diff


# ============================================================
# Main: Run all algorithms with examples
# ============================================================

if __name__ == "__main__":
    print("Tropical Perturbation Amplification: Algorithm Demonstrations")
    print("=" * 65)

    # Algorithm 1: Tropical Max
    print("\n--- Algorithm 1: Tropical Max Functional ---")
    S = [0, 1, 2, 3, 4]
    w = {0: 1.0, 1: -0.5, 2: 0.3, 3: 2.1, 4: -1.0}
    f = {0: 0.0, 1: 2.0, 2: 1.0, 3: -1.0, 4: 3.0}
    val, arg = tropical_max_argmax(S, w, f)
    print(f"Support: {S}")
    print(f"Weights: {w}")
    print(f"Function: {f}")
    print(f"F(f) = max_s (f(s) + w(s)) = {val:.4f}, achieved at s = {arg}")

    # Algorithm 2: Weight Recovery
    print("\n--- Algorithm 2: Weight Recovery ---")
    true_weights = {0: 1.5, 1: -0.3, 2: 2.0}
    S_small = [0, 1, 2]

    def make_functional(support, weights):
        def F(f_input):
            return tropical_max(support, weights, f_input)
        return F

    F = make_functional(S_small, true_weights)
    recovered = recover_weights(S_small, F)
    print(f"True weights:      {true_weights}")
    print(f"Recovered weights: {recovered}")
    print(f"Max error: {max(abs(true_weights[s] - recovered[s]) for s in S_small):.2e}")

    # Algorithm 3: Perturbation Bounds
    print("\n--- Algorithm 3: Perturbation Bounds ---")
    for n in [2, 10, 100, 1000]:
        print(f"|S| = {n:>5}: Φ(S) = {tropical_perturbation_bound(n):.4f}, "
              f"Φ₂(S) = {tropical_bit_complexity(n):.4f} bits")

    # Algorithm 4: Product Analysis
    print("\n--- Algorithm 4: Product System Analysis ---")
    for cs, ct in [(5, 7), (10, 10), (100, 100)]:
        ps, pt, psum, pprod = product_bound_additive(cs, ct)
        print(f"|S|={cs}, |T|={ct}: Φ(S)={ps:.4f}, Φ(T)={pt:.4f}, "
              f"sum={psum:.4f}, Φ(S×T)={pprod:.4f}, err={abs(psum-pprod):.2e}")

    # Algorithm 5: Perturbation Verification
    print("\n--- Algorithm 5: Perturbation Stability Verification ---")
    rng = np.random.RandomState(0)
    S_test = list(range(8))
    w_true = {s: rng.randn() for s in S_test}
    eps = 0.15
    w_pert = {s: w_true[s] + rng.uniform(-eps, eps) for s in S_test}
    passed, dw, df = verify_perturbation_stability(S_test, w_true, w_pert, eps)
    print(f"ε = {eps}, max|Δw| = {dw:.6f}, max|ΔF| = {df:.6f}, passed = {passed}")

    # Algorithm 6: Product Perturbation
    print("\n--- Algorithm 6: Product Perturbation Composition ---")
    S_p = list(range(4))
    T_p = list(range(3))
    wS1 = {s: rng.randn() for s in S_p}
    wT1 = {t: rng.randn() for t in T_p}
    eS, eT = 0.1, 0.2
    wS2 = {s: wS1[s] + rng.uniform(-eS, eS) for s in S_p}
    wT2 = {t: wT1[t] + rng.uniform(-eT, eT) for t in T_p}
    passed, dw, df = verify_product_perturbation(S_p, T_p, wS1, wS2, wT1, wT2, eS, eT)
    print(f"εS={eS}, εT={eT}, εS+εT={eS+eT}")
    print(f"max|Δw_product| = {dw:.6f}, max|ΔF_product| = {df:.6f}, passed = {passed}")

    print("\n" + "=" * 65)
    print("All algorithm demonstrations complete.")
