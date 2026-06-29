#!/usr/bin/env python3
"""
Algorithms for Valuated Exchange and Derivative Closure

This module implements:
1. Certified K=1 valuated exchange checker
2. Partial derivative weight transform
3. M-convexity checker for support sets
4. Derivative closure verifier
5. Weighted uniform matroid polynomial generator

All algorithms are designed to mirror the formal Lean definitions.
"""

from itertools import combinations
from typing import Dict, List, Tuple, Optional, Set
import random


# --- Core Data Types ---

ExponentVector = Tuple[int, ...]
WeightFunction = Dict[ExponentVector, float]


# --- Algorithm 1: Exchange Vector Computation ---

def exchange_vec(m: ExponentVector, i: int, j: int) -> ExponentVector:
    """
    Compute the exchange move on exponent vector m:
    decrease coordinate i by 1, increase coordinate j by 1.
    
    Mirrors the Lean definition:
      def exchVec (m : σ → ℕ) (i j : σ) : σ → ℕ :=
        fun k => if k = i then m i - 1 else if k = j then m j + 1 else m k
    
    Time complexity: O(n) where n = len(m)
    Space complexity: O(n)
    """
    result = list(m)
    result[i] = max(0, result[i] - 1)  # ℕ subtraction (truncating)
    if i != j:
        result[j] += 1
    return tuple(result)


# --- Algorithm 2: K=1 Valuated Exchange Checker ---

def check_valuated_exchange_one(
    w: WeightFunction,
    eps: float = 1e-10
) -> Tuple[bool, Optional[str]]:
    """
    Check the K=1 valuated exchange condition on weight function w.
    
    For all α, β in support with w(α) > 0, w(β) > 0,
    for all i with α_i > β_i,
    ∃ j ≠ i with β_j > α_j and
      w(exchVec(α,i,j)) * w(exchVec(β,j,i)) ≥ w(α) * w(β)
    
    Time complexity: O(|support|^2 * n^2) where n = dimension
    Space complexity: O(|support|)
    
    Returns: (passes, failure_message)
    """
    support = [m for m, v in w.items() if v > eps]
    if len(support) <= 1:
        return True, None
    
    n = len(support[0])
    
    for alpha in support:
        wa = w.get(alpha, 0.0)
        if wa <= eps:
            continue
        for beta in support:
            wb = w.get(beta, 0.0)
            if wb <= eps:
                continue
            for i in range(n):
                if alpha[i] <= beta[i]:
                    continue
                # Need to find j ≠ i with beta[j] > alpha[j]
                # and exchange inequality
                found = False
                for j in range(n):
                    if j == i or beta[j] <= alpha[j]:
                        continue
                    ea = exchange_vec(alpha, i, j)
                    eb = exchange_vec(beta, j, i)
                    w_ea = w.get(ea, 0.0)
                    w_eb = w.get(eb, 0.0)
                    if w_ea * w_eb >= wa * wb - eps:
                        found = True
                        break
                if not found:
                    return False, (f"Failed: α={alpha}, β={beta}, i={i}, "
                                   f"w(α)={wa:.4f}, w(β)={wb:.4f}")
    return True, None


# --- Algorithm 3: Partial Derivative Weight Transform ---

def partial_derivative_weight(
    var_idx: int,
    w: WeightFunction
) -> WeightFunction:
    """
    Compute the partial derivative weight transform:
      pdWeight(i, w)(m) = (m[i] + 1) * w(m + e_i)
    
    Mirrors the Lean definition:
      def pdWeight (i : σ) (w : (σ → ℕ) → ℝ) : (σ → ℕ) → ℝ :=
        fun m => (↑(m i + 1) : ℝ) * w (Function.update m i (m i + 1))
    
    Time complexity: O(|support|)
    Space complexity: O(|support|)
    """
    dw: WeightFunction = {}
    for alpha, val in w.items():
        if val == 0 or alpha[var_idx] < 1:
            continue
        m = list(alpha)
        m[var_idx] -= 1
        m_tuple = tuple(m)
        # pdWeight formula: (m[i] + 1) * w(m + e_i) = alpha[var_idx] * w(alpha)
        dw[m_tuple] = alpha[var_idx] * val
    return dw


# --- Algorithm 4: M-Convexity Checker ---

def check_m_convex(support: List[ExponentVector]) -> bool:
    """
    Check if a set of exponent vectors satisfies the M-convex exchange property:
    For all α, β ∈ S, for all i with α_i > β_i,
    ∃ j ≠ i with β_j > α_j and α - e_i + e_j ∈ S and β + e_i - e_j ∈ S.
    
    Time complexity: O(|S|^2 * n^2) where n = dimension
    Space complexity: O(|S|)
    """
    support_set = set(support)
    n = len(support[0]) if support else 0
    
    for alpha in support:
        for beta in support:
            for i in range(n):
                if alpha[i] <= beta[i]:
                    continue
                found = False
                for j in range(n):
                    if j == i or beta[j] <= alpha[j]:
                        continue
                    ea = exchange_vec(alpha, i, j)
                    eb = exchange_vec(beta, j, i)
                    if ea in support_set and eb in support_set:
                        found = True
                        break
                if not found:
                    return False
    return True


# --- Algorithm 5: Contraction Shadow ---

def contraction_shadow(
    var_idx: int,
    support: Set[ExponentVector]
) -> Set[ExponentVector]:
    """
    Compute the contraction shadow of a support set at coordinate var_idx:
      contrShadow(i, S) = {m | m + e_i ∈ S}
    
    Time complexity: O(|S|)
    Space complexity: O(|S|)
    """
    shadow = set()
    for alpha in support:
        if alpha[var_idx] >= 1:
            m = list(alpha)
            m[var_idx] -= 1
            shadow.add(tuple(m))
    return shadow


# --- Algorithm 6: Derivative Closure Checker ---

def check_derivative_closure(
    w: WeightFunction,
    eps: float = 1e-10
) -> Tuple[bool, Dict]:
    """
    Check if w and all its first partial derivatives satisfy K=1 exchange.
    
    Returns (all_pass, details_dict)
    
    Time complexity: O(n * |support|^2 * n^2)
    """
    n = len(next(iter(w))) if w else 0
    
    # Check original
    ok, msg = check_valuated_exchange_one(w, eps)
    details = {
        "original_exchange": ok,
        "original_message": msg,
        "derivatives": {}
    }
    if not ok:
        return False, details
    
    # Check all partial derivatives
    all_ok = True
    for i in range(n):
        dw = partial_derivative_weight(i, w)
        ok_d, msg_d = check_valuated_exchange_one(dw, eps)
        details["derivatives"][i] = {
            "exchange": ok_d,
            "message": msg_d,
            "support_size": sum(1 for v in dw.values() if abs(v) > eps)
        }
        if not ok_d:
            all_ok = False
    
    return all_ok, details


# --- Algorithm 7: Weighted Uniform Matroid Polynomial ---

def weighted_uniform_matroid(
    n: int,
    d: int,
    weights: Optional[List[float]] = None
) -> WeightFunction:
    """
    Generate the weighted uniform matroid polynomial U(d,n).
    
    Support: all 0-1 vectors of weight d.
    Weights: product of coordinate weights for each basis.
    
    Time complexity: O(C(n,d))
    Space complexity: O(C(n,d))
    """
    if d > n:
        return {}
    
    if weights is None:
        weights = [1.0] * n
    
    w: WeightFunction = {}
    for combo in combinations(range(n), d):
        vec = [0] * n
        for i in combo:
            vec[i] = 1
        weight = 1.0
        for i in combo:
            weight *= weights[i]
        w[tuple(vec)] = weight
    
    return w


# --- Algorithm 8: Random Search for Counterexamples ---

def search_counterexamples(
    n_range: range,
    d_range: range,
    num_samples: int = 1000,
    seed: int = 42
) -> List[Dict]:
    """
    Exhaustive random search for counterexamples to derivative closure.
    
    Returns list of any counterexamples found (empty if theorem holds).
    """
    rng = random.Random(seed)
    counterexamples = []
    
    for n in n_range:
        for d in d_range:
            if d > n:
                continue
            for _ in range(num_samples):
                weights = [rng.expovariate(1.0) for _ in range(n)]
                w = weighted_uniform_matroid(n, d, weights)
                if not w:
                    continue
                
                ok, details = check_derivative_closure(w)
                if not ok and details["original_exchange"]:
                    counterexamples.append({
                        "n": n, "d": d,
                        "weights": weights,
                        "details": details
                    })
    
    return counterexamples


if __name__ == "__main__":
    print("=== Algorithms Module ===")
    print()
    
    # Example: U(2,4) with specific weights
    w = weighted_uniform_matroid(4, 2, [1.0, 2.0, 3.0, 4.0])
    print(f"U(2,4) with weights [1,2,3,4]:")
    for m, v in sorted(w.items()):
        print(f"  {m}: {v:.2f}")
    
    ok, details = check_derivative_closure(w)
    print(f"  Derivative closure: {ok}")
    
    # Search for counterexamples
    print("\nSearching for counterexamples (n≤7, d≤4)...")
    cex = search_counterexamples(range(2, 8), range(1, 5), num_samples=500)
    print(f"  Counterexamples found: {len(cex)}")
    if cex:
        for c in cex:
            print(f"  n={c['n']}, d={c['d']}: {c['details']}")
    else:
        print("  No counterexamples — consistent with the theorem!")
