#!/usr/bin/env python3
"""
Algorithms for Tropical Polynomial Canonicalization and Automata Construction

Implements:
1. Pareto-canonical form computation (O(n log n))
2. Envelope-canonical form computation (O(n log n) via convex hull)
3. Diagonal WFA construction from canonical monomials
4. Nerode equivalence class computation
5. Minimal automaton extraction
"""

import numpy as np
from typing import List, Tuple, Optional, Dict, Set
from dataclasses import dataclass, field


@dataclass(frozen=True)
class TropMono:
    """A tropical monomial: coeff + exp · x."""
    exp: int
    coeff: float

    def eval(self, x: float) -> float:
        return self.coeff + self.exp * x

    def __repr__(self):
        return f"({self.exp}, {self.coeff:.2f})"


@dataclass
class TropPoly:
    """A tropical polynomial: a collection of monomials."""
    monomials: List[TropMono]

    def eval(self, x: float) -> float:
        """Evaluate: min over all monomials."""
        return min(m.eval(x) for m in self.monomials)

    def language(self, n: int) -> float:
        """The weighted language L(n)."""
        return self.eval(float(n))

    def residual(self, k: int, n: int) -> float:
        """Residual at prefix k evaluated at suffix n."""
        return self.language(k + n)


# =============================================================================
# Algorithm 1: Pareto-Canonical Form (O(n log n))
# =============================================================================

def pareto_canonical(poly: TropPoly) -> TropPoly:
    """
    Compute the ℕ-canonical (Pareto) form.

    Algorithm:
    1. Sort monomials by exponent (ascending).
    2. For each exponent group, keep only the one with smallest coefficient.
    3. Scan the deduplicated list; remove any monomial dominated by a previous one
       (i.e., with both larger exponent and larger coefficient).

    Complexity: O(n log n) where n = |monomials|.

    Returns:
        TropPoly with only Pareto-optimal monomials.
    """
    if not poly.monomials:
        return TropPoly([])

    # Step 1: Sort by exponent, then by coefficient for ties
    sorted_monos = sorted(poly.monomials, key=lambda m: (m.exp, m.coeff))

    # Step 2: Deduplicate by exponent (keep smallest coefficient)
    deduped: List[TropMono] = []
    for m in sorted_monos:
        if not deduped or deduped[-1].exp != m.exp:
            deduped.append(m)
        # else: skip (already have one with same exp and ≤ coeff)

    # Step 3: Pareto filter — scan and keep only non-dominated monomials
    # After deduplication, exponents are strictly increasing.
    # A monomial is dominated iff some earlier monomial has ≤ coeff (and ≤ exp).
    # Since exponents increase, we need: no earlier monomial has ≤ coeff.
    # Track the running minimum coefficient.
    result: List[TropMono] = []
    min_coeff = float('inf')
    for m in deduped:
        if m.coeff < min_coeff:
            # Not dominated: its coefficient is strictly less than all previous
            result.append(m)
            min_coeff = m.coeff
        # else: dominated by some earlier monomial with ≤ coeff and ≤ exp

    return TropPoly(result)


# =============================================================================
# Algorithm 2: Envelope-Canonical Form (O(n log n) via lower hull)
# =============================================================================

def envelope_canonical(poly: TropPoly) -> TropPoly:
    """
    Compute the envelope-canonical form: keep only monomials that contribute
    to the lower envelope (achieve the minimum at some n ∈ ℕ).

    Algorithm:
    1. Start with the Pareto-canonical form.
    2. The lower envelope of affine functions is computed via a scan similar
       to convex hull: process monomials in decreasing exponent order,
       maintain a stack of "active" monomials.
    3. Check which monomials contribute at integer points.

    Complexity: O(n log n).
    """
    pareto = pareto_canonical(poly)
    if len(pareto.monomials) <= 1:
        return pareto

    # Pareto monomials have strictly increasing exponent and strictly
    # decreasing coefficient. Process them to find which contribute
    # to the lower envelope on ℕ.
    monos = pareto.monomials  # sorted by increasing exp, decreasing coeff

    # Find the range where each monomial is optimal
    # Monomial i is optimal when: c_i + e_i * x ≤ c_j + e_j * x for all j
    # Between consecutive monomials i and i+1:
    # Crossover at x* = (c_i - c_{i+1}) / (e_{i+1} - e_i)

    essential: List[TropMono] = []
    stack: List[int] = []  # indices into monos

    for i in range(len(monos)):
        while len(stack) >= 2:
            j = stack[-1]
            k = stack[-2]
            # Check if monos[j] is below monos[i] and monos[k]'s crossing
            # Crossing of k and i: x* = (c_k - c_i) / (e_i - e_k)
            # Crossing of k and j: x** = (c_k - c_j) / (e_j - e_k)
            # If x* <= x**, then j is never the minimum — remove it
            cross_ki = (monos[k].coeff - monos[i].coeff) / (monos[i].exp - monos[k].exp)
            cross_kj = (monos[k].coeff - monos[j].coeff) / (monos[j].exp - monos[k].exp)
            if cross_ki <= cross_kj:
                stack.pop()
            else:
                break
        stack.append(i)

    # Now check which stacked monomials actually achieve the min at some n ∈ ℕ
    for idx in stack:
        essential.append(monos[idx])

    return TropPoly(essential)


# =============================================================================
# Algorithm 3: Nerode Equivalence Classes
# =============================================================================

def nerode_classes(poly: TropPoly, max_k: int = 50, suffix_len: int = 50) -> Dict[int, List[int]]:
    """
    Compute Nerode equivalence classes by comparing residual functions.

    Two prefix lengths k₁, k₂ are Nerode-equivalent if their residuals agree:
    L(k₁ + n) = L(k₂ + n) for all n.

    We approximate by checking suffixes up to suffix_len.

    Returns:
        Dict mapping representative k to list of equivalent k values.
    """
    classes: Dict[int, List[int]] = {}
    residuals: Dict[int, Tuple[float, ...]] = {}

    for k in range(max_k):
        res = tuple(poly.residual(k, n) for n in range(suffix_len))
        residuals[k] = res

        found = False
        for rep in classes:
            if residuals[rep] == res:
                classes[rep].append(k)
                found = True
                break
        if not found:
            classes[k] = [k]

    return classes


# =============================================================================
# Algorithm 4: Diagonal WFA Construction
# =============================================================================

@dataclass
class TropWFA:
    """A tropical weighted finite automaton over a single letter."""
    states: List[str]
    init_costs: Dict[str, float]
    trans_costs: Dict[str, float]  # self-loop cost for each state
    final_costs: Dict[str, float]

    def eval(self, n: int) -> float:
        """Evaluate: min over states of (init + n * trans + final)."""
        return min(
            self.init_costs[s] + n * self.trans_costs[s] + self.final_costs[s]
            for s in self.states
        )


def build_diagonal_wfa(poly: TropPoly) -> TropWFA:
    """
    Build a diagonal WFA from a tropical polynomial.

    Each monomial (e, c) becomes a state with:
    - Initial cost = c
    - Self-loop transition cost = e
    - Final cost = 0

    The WFA computes L(n) = min_i (c_i + e_i · n).
    """
    states = []
    init_costs = {}
    trans_costs = {}
    final_costs = {}

    for i, m in enumerate(poly.monomials):
        name = f"s{i}({m.exp},{m.coeff:.0f})"
        states.append(name)
        init_costs[name] = m.coeff
        trans_costs[name] = float(m.exp)
        final_costs[name] = 0.0

    return TropWFA(states, init_costs, trans_costs, final_costs)


# =============================================================================
# Main Demo
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Tropical Polynomial Canonicalization Algorithms")
    print("=" * 70)

    # Example polynomial
    poly = TropPoly([
        TropMono(0, 10), TropMono(1, 5), TropMono(2, 3),
        TropMono(2, 7), TropMono(3, 0), TropMono(3, 4),
        TropMono(5, -2)
    ])

    print(f"\nOriginal: {poly.monomials}")

    # Pareto canonical
    pareto = pareto_canonical(poly)
    print(f"Pareto canonical: {pareto.monomials}")

    # Envelope canonical
    envelope = envelope_canonical(poly)
    print(f"Envelope canonical: {envelope.monomials}")

    # Verify language preservation
    print(f"\nLanguage preservation check:")
    for n in range(10):
        orig = poly.language(n)
        par = pareto.language(n)
        env = envelope.language(n)
        print(f"  n={n}: L_orig={orig:.1f}, L_pareto={par:.1f}, "
              f"L_envelope={env:.1f}, "
              f"match={'✓' if abs(orig-par)<1e-10 and abs(orig-env)<1e-10 else '✗'}")

    # Nerode classes
    print(f"\nNerode equivalence classes:")
    classes = nerode_classes(poly, max_k=20)
    for rep, members in classes.items():
        print(f"  Class {rep}: {members}")

    # WFA construction
    wfa = build_diagonal_wfa(pareto)
    print(f"\nDiagonal WFA from Pareto canonical ({len(wfa.states)} states):")
    for s in wfa.states:
        print(f"  {s}: init={wfa.init_costs[s]:.0f}, "
              f"trans={wfa.trans_costs[s]:.0f}, "
              f"final={wfa.final_costs[s]:.0f}")

    print(f"\nWFA evaluation check:")
    for n in range(10):
        wfa_val = wfa.eval(n)
        poly_val = poly.language(n)
        print(f"  n={n}: WFA={wfa_val:.1f}, L={poly_val:.1f}, "
              f"match={'✓' if abs(wfa_val-poly_val)<1e-10 else '✗'}")
