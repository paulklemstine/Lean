#!/usr/bin/env python3
"""
Algorithms for Weighted Consequence Systems and Closure Proof Complexity

Implements the key algorithms from the research:
1. Closure operator computation from weighted rules
2. Minimum derivation cost via dynamic programming
3. Full implicational basis reconstruction
4. Proof rate computation
5. Principal increment extraction
"""

import itertools
from typing import FrozenSet, Dict, List, Set, Optional, Tuple
from collections import defaultdict
import heapq


# ============================================================
# Algorithm 1: Forward Chaining Closure Computation
# ============================================================

def forward_chaining_closure(
    rules: List[Tuple[FrozenSet[str], str, int]],
    seed: FrozenSet[str]
) -> FrozenSet[str]:
    """
    Compute the derivable closure of a seed set under Horn rules.

    Algorithm: Forward chaining (bottom-up fixpoint).
    Time: O(|rules| * |alphabet|) per iteration, O(|alphabet|) iterations worst case.
    Total: O(|rules| * |alphabet|^2)

    Args:
        rules: List of (premises, conclusion, weight) triples
        seed: Initial set of derived atoms

    Returns:
        The derivable closure (smallest superset of seed closed under all rules)
    """
    current = set(seed)
    changed = True
    while changed:
        changed = False
        for premises, conclusion, _ in rules:
            if premises <= current and conclusion not in current:
                current.add(conclusion)
                changed = True
    return frozenset(current)


# ============================================================
# Algorithm 2: Minimum Derivation Cost (Subset Enumeration)
# ============================================================

def min_deriv_cost_exact(
    rules: List[Tuple[FrozenSet[str], str, int]],
    target: FrozenSet[str]
) -> Optional[int]:
    """
    Exact minimum derivation cost via subset enumeration.

    Algorithm: Enumerate all 2^|rules| subsets, compute closure for each,
    check if target is derived, track minimum cost.

    Time: O(2^|rules| * |rules| * |alphabet|^2)
    Space: O(|rules| + |alphabet|)

    Args:
        rules: List of (premises, conclusion, weight) triples
        target: Set of atoms to derive from ∅

    Returns:
        Minimum cost, or None if target is not derivable
    """
    n = len(rules)
    best = None

    for mask in range(1 << n):
        subset = [rules[i] for i in range(n) if mask & (1 << i)]
        cost = sum(w for _, _, w in subset)
        if best is not None and cost >= best:
            continue  # Prune

        closure = forward_chaining_closure(subset, frozenset())
        if target <= closure:
            best = cost

    return best


# ============================================================
# Algorithm 3: Minimum Derivation Cost (Greedy Heuristic)
# ============================================================

def min_deriv_cost_greedy(
    rules: List[Tuple[FrozenSet[str], str, int]],
    target: FrozenSet[str]
) -> Optional[int]:
    """
    Greedy heuristic for minimum derivation cost.

    Algorithm: Repeatedly add the cheapest rule that derives at least one
    new element needed for the target, until target is fully derived.

    Time: O(|rules|^2 * |alphabet|)
    Space: O(|rules| + |alphabet|)

    Note: This is a heuristic and may not find the optimal solution.
    It provides an upper bound on the minimum cost.

    Args:
        rules: List of (premises, conclusion, weight) triples
        target: Set of atoms to derive from ∅

    Returns:
        Upper bound on minimum cost, or None if target is not derivable
    """
    remaining = set(target)
    derived = set()
    used_rules = []
    total_cost = 0

    while remaining:
        # Find applicable rules
        best_rule = None
        best_value = float('inf')

        for i, (premises, conclusion, weight) in enumerate(rules):
            if premises <= derived and conclusion in remaining:
                # Value = weight per new element
                value = weight
                if value < best_value:
                    best_value = value
                    best_rule = i

        if best_rule is None:
            # Try to extend derived set with any applicable rule
            extended = False
            for i, (premises, conclusion, weight) in enumerate(rules):
                if premises <= derived and conclusion not in derived:
                    derived.add(conclusion)
                    used_rules.append(i)
                    total_cost += weight
                    remaining.discard(conclusion)
                    extended = True
                    break
            if not extended:
                return None  # Cannot derive target
        else:
            premises, conclusion, weight = rules[best_rule]
            derived.add(conclusion)
            used_rules.append(best_rule)
            total_cost += weight
            remaining.discard(conclusion)

        # Forward chain to discover new derivable elements
        changed = True
        while changed:
            changed = False
            for i in used_rules:
                premises, conclusion, weight = rules[i]
                if premises <= derived and conclusion not in derived:
                    derived.add(conclusion)
                    remaining.discard(conclusion)
                    changed = True

    return total_cost


# ============================================================
# Algorithm 4: Full Implicational Basis Reconstruction
# ============================================================

def reconstruct_basis(
    alphabet: Set[str],
    cl: callable
) -> List[Tuple[FrozenSet[str], str]]:
    """
    Reconstruct the full implicational basis from a closure operator.

    Algorithm: For each subset P of the alphabet and each element x ∈ cl(P) \ P,
    add the implication (P, x) to the basis.

    Time: O(2^|alphabet| * |alphabet| * T_cl) where T_cl is the cost of
          evaluating the closure operator.
    Space: O(2^|alphabet| * |alphabet|)

    Args:
        alphabet: The finite set of atomic propositions
        cl: Closure operator (function from frozenset to frozenset)

    Returns:
        List of (premises, conclusion) pairs forming the basis
    """
    basis = []
    sorted_alpha = sorted(alphabet)

    for r in range(len(sorted_alpha) + 1):
        for prem_tuple in itertools.combinations(sorted_alpha, r):
            prem = frozenset(prem_tuple)
            closure = cl(prem)
            for x in sorted(closure - prem):
                basis.append((prem, x))

    return basis


def reconstruct_minimal_basis(
    alphabet: Set[str],
    cl: callable
) -> List[Tuple[FrozenSet[str], str]]:
    """
    Reconstruct a minimal (irredundant) implicational basis.

    Algorithm: Start with full basis, then remove implications that are
    derivable from the remaining ones.

    Time: O(|full_basis|^2 * |alphabet|^2)

    Args:
        alphabet: The finite set of atomic propositions
        cl: Closure operator

    Returns:
        Minimal implicational basis
    """
    full = reconstruct_basis(alphabet, cl)

    # Try removing each implication
    minimal = list(full)
    for imp in full:
        candidate = [i for i in minimal if i != imp]
        # Check if candidate still generates the same closure
        rules_candidate = [(prem, concl, 1) for prem, concl in candidate]
        still_complete = True
        for r in range(len(sorted(alphabet)) + 1):
            for prem_tuple in itertools.combinations(sorted(alphabet), r):
                prem = frozenset(prem_tuple)
                cl_original = cl(prem)
                cl_candidate = forward_chaining_closure(rules_candidate, prem)
                if cl_original != cl_candidate:
                    still_complete = False
                    break
            if not still_complete:
                break
        if still_complete:
            minimal = candidate

    return minimal


# ============================================================
# Algorithm 5: Principal Increment Extraction
# ============================================================

def extract_principal_increments(
    alphabet: Set[str],
    cl: callable
) -> Dict[Tuple[FrozenSet[str], str], FrozenSet[str]]:
    """
    Extract principal increments: for each closed set C and element x ∉ C,
    compute cl(C ∪ {x}).

    These are the atomic proof steps in the closure lattice.

    Args:
        alphabet: The finite set
        cl: Closure operator

    Returns:
        Dictionary mapping (C, x) → cl(C ∪ {x}) for closed C and x ∉ C
    """
    # Find all closed sets
    closed_sets = set()
    for r in range(len(alphabet) + 1):
        for subset in itertools.combinations(sorted(alphabet), r):
            s = frozenset(subset)
            c = cl(s)
            closed_sets.add(c)

    increments = {}
    for C in sorted(closed_sets, key=lambda s: (len(s), sorted(s))):
        for x in sorted(alphabet - C):
            increment = cl(C | frozenset({x}))
            increments[(C, x)] = increment

    return increments


# ============================================================
# Algorithm 6: Proof Rate Computation
# ============================================================

def compute_proof_rate(
    alphabet: Set[str],
    rules: List[Tuple[FrozenSet[str], str, int]],
    max_rank: int
) -> List[Optional[int]]:
    """
    Compute the proof rate function R(m) for m = 0, 1, ..., max_rank.

    R(m) = sup { min_cost(C) : C closed, rank(C) ≤ m }

    Time: O(max_rank * 2^|alphabet| * 2^|rules| * |rules| * |alphabet|^2)

    Args:
        alphabet: The finite set
        rules: Weighted Horn rules
        max_rank: Maximum rank to compute

    Returns:
        List of R(m) values for m = 0, ..., max_rank
    """
    # Compute all closed sets with their ranks and costs
    closed_data = []  # (closed_set, rank, cost)

    for r in range(len(alphabet) + 1):
        for subset in itertools.combinations(sorted(alphabet), r):
            seed = frozenset(subset)
            cl_set = forward_chaining_closure(rules, seed)
            # Check if already seen
            if any(c == cl_set for c, _, _ in closed_data):
                continue
            # Compute rank
            rank = None
            for rr in range(len(alphabet) + 1):
                for sub2 in itertools.combinations(sorted(alphabet), rr):
                    if forward_chaining_closure(rules, frozenset(sub2)) == cl_set:
                        rank = rr
                        break
                if rank is not None:
                    break
            # Compute cost
            cost = min_deriv_cost_exact(rules, cl_set)
            closed_data.append((cl_set, rank, cost))

    # Compute R(m)
    rates = []
    for m in range(max_rank + 1):
        max_cost = 0
        for cl_set, rank, cost in closed_data:
            if rank is not None and rank <= m and cost is not None:
                max_cost = max(max_cost, cost)
        rates.append(max_cost)

    return rates


# ============================================================
# Algorithm 7: Weighted Basis Assignment
# ============================================================

def assign_optimal_weights(
    alphabet: Set[str],
    cl: callable,
    kappa: Dict[FrozenSet[str], int]
) -> List[Tuple[FrozenSet[str], str, int]]:
    """
    Given a closure operator and target cost function κ on closed sets,
    assign weights to the minimal basis implications to approximate κ.

    Strategy: For each implication (P, x), assign weight proportional to
    the cost increment κ(cl(P ∪ {x})) - κ(cl(P)).

    Args:
        alphabet: The finite set
        cl: Closure operator
        kappa: Cost function on closed sets

    Returns:
        List of weighted rules (premises, conclusion, weight)
    """
    basis = reconstruct_minimal_basis(alphabet, cl)
    weighted_rules = []

    for prem, concl in basis:
        cl_prem = cl(prem)
        cl_extended = cl(prem | frozenset({concl}))
        cost_before = kappa.get(cl_prem, 0)
        cost_after = kappa.get(cl_extended, 0)
        weight = max(0, cost_after - cost_before)
        weighted_rules.append((prem, concl, weight))

    return weighted_rules


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Example: simple closure operator
    alphabet = {"a", "b", "c", "d"}

    rules = [
        (frozenset(), "a", 2),
        (frozenset({"a"}), "b", 3),
        (frozenset({"b"}), "c", 1),
        (frozenset({"a", "c"}), "d", 4),
    ]

    print("\nRules:")
    for prem, concl, w in rules:
        prem_str = ", ".join(sorted(prem)) if prem else "∅"
        print(f"  {{{prem_str}}} → {concl}  [w={w}]")

    print("\n--- Forward Chaining ---")
    for seed_items in [[], ["a"], ["a", "b"], ["b"]]:
        seed = frozenset(seed_items)
        cl = forward_chaining_closure(rules, seed)
        print(f"  cl({set(seed) if seed else '∅'}) = {set(cl)}")

    print("\n--- Minimum Derivation Cost ---")
    targets = [
        frozenset({"a"}),
        frozenset({"a", "b"}),
        frozenset({"a", "b", "c"}),
        frozenset({"a", "b", "c", "d"}),
    ]
    for t in targets:
        exact = min_deriv_cost_exact(rules, t)
        greedy = min_deriv_cost_greedy(rules, t)
        print(f"  target={set(t):>20s}  exact={exact}  greedy={greedy}")

    print("\n--- Proof Rate ---")
    rates = compute_proof_rate(alphabet, rules, 4)
    for m, r in enumerate(rates):
        print(f"  R({m}) = {r}")

    print("\n--- Principal Increments ---")
    def cl_fn(s):
        return forward_chaining_closure(rules, s)

    increments = extract_principal_increments(alphabet, cl_fn)
    for (C, x), result in sorted(increments.items(), key=lambda kv: (len(kv[0][0]), sorted(kv[0][0]))):
        C_str = set(C) if C else "∅"
        print(f"  cl({C_str} ∪ {{{x}}}) = {set(result)}")

    print("\n--- Basis Reconstruction ---")
    basis = reconstruct_basis(alphabet, cl_fn)
    print(f"  Full basis: {len(basis)} implications")
    for prem, concl in basis[:10]:
        prem_str = set(prem) if prem else "∅"
        print(f"    {prem_str} → {concl}")
    if len(basis) > 10:
        print(f"    ... ({len(basis) - 10} more)")

    min_basis = reconstruct_minimal_basis(alphabet, cl_fn)
    print(f"\n  Minimal basis: {len(min_basis)} implications")
    for prem, concl in min_basis:
        prem_str = set(prem) if prem else "∅"
        print(f"    {prem_str} → {concl}")
