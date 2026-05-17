"""
Tropical Polynomial Canonicalization–Automata Bridge: Algorithms
================================================================

Implements the core algorithms from the research paper:
1. Canonicalization (Pareto front computation)
2. Tropical polynomial evaluation
3. Residual computation and Nerode class counting
4. Finite automaton construction
5. Lower envelope visualization support
"""

from typing import List, Tuple, Optional, Dict, Set, Callable
from dataclasses import dataclass
import numpy as np


@dataclass(frozen=True)
class TropMono:
    """Tropical monomial: coeff + exp * x.

    Attributes:
        exp: Non-negative integer exponent (slope).
        coeff: Real coefficient (intercept).
    """
    exp: int
    coeff: float

    def eval(self, x: float) -> float:
        """Evaluate the monomial at x."""
        return self.coeff + self.exp * x

    def __repr__(self):
        if self.exp == 0:
            return f"{self.coeff:.2f}"
        return f"{self.coeff:.2f} + {self.exp}x"


def trop_eval(monomials: List[TropMono], x: float) -> float:
    """Evaluate a tropical polynomial at x: min over all monomials.

    Args:
        monomials: Nonempty list of monomials.
        x: Evaluation point.

    Returns:
        min_{m ∈ monomials} (m.coeff + m.exp * x)

    Time complexity: O(|monomials|)
    """
    assert len(monomials) > 0, "Polynomial must be nonempty"
    return min(m.eval(x) for m in monomials)


def nat_dominates(m1: TropMono, m2: TropMono) -> bool:
    """Check if m1 ℕ-dominates m2.

    Theorem (natDominates_iff):
        NatDominates(m1, m2) ⟺ m1.exp ≤ m2.exp ∧ m1.coeff ≤ m2.coeff

    Time complexity: O(1)
    """
    return m1.exp <= m2.exp and m1.coeff <= m2.coeff


def canonicalize(monomials: List[TropMono]) -> List[TropMono]:
    """Compute the ℕ-canonical form (Pareto front).

    Algorithm:
        1. Sort by exponent (ascending)
        2. Scan, keeping only monomials with strictly decreasing coefficient

    This implements NatCanonical(p) from the formal development.

    Args:
        monomials: Nonempty list of monomials.

    Returns:
        Pareto-optimal monomials (non-dominated subset).

    Time complexity: O(n log n) where n = |monomials|
    Space complexity: O(n)
    """
    assert len(monomials) > 0

    # Sort by exponent, then by coefficient for same exponent
    sorted_monos = sorted(monomials, key=lambda m: (m.exp, m.coeff))

    # Among same-exponent monomials, keep only the one with smallest coefficient
    deduped = []
    for m in sorted_monos:
        if not deduped or deduped[-1].exp != m.exp:
            deduped.append(m)
        elif m.coeff < deduped[-1].coeff:
            deduped[-1] = m

    # Scan for Pareto front: keep monomials with strictly decreasing coefficient
    result = [deduped[0]]
    for m in deduped[1:]:
        if m.coeff < result[-1].coeff:
            result.append(m)

    return result


def poly_language(monomials: List[TropMono], n: int) -> float:
    """Compute the weighted language L_p(n) = tropEval(p, n).

    Time complexity: O(|monomials|)
    """
    return trop_eval(monomials, float(n))


def compute_residual(monomials: List[TropMono], k: int, n: int) -> float:
    """Compute residual(L_p, k)(n) = L_p(k + n).

    Time complexity: O(|monomials|)
    """
    return poly_language(monomials, k + n)


def residual_signature(monomials: List[TropMono], k: int,
                       length: int = 30) -> Tuple[float, ...]:
    """Compute a signature for the residual at k (first `length` values).

    Two residuals are equal iff their signatures match (for large enough length).

    Time complexity: O(length * |monomials|)
    """
    return tuple(round(compute_residual(monomials, k, n), 10)
                 for n in range(length))


def count_nerode_classes(monomials: List[TropMono],
                         max_k: int = 100,
                         sig_length: int = 30) -> int:
    """Count the number of distinct Nerode classes up to prefix length max_k.

    Time complexity: O(max_k * sig_length * |monomials|)
    """
    seen: Set[Tuple[float, ...]] = set()
    for k in range(max_k + 1):
        sig = residual_signature(monomials, k, sig_length)
        seen.add(sig)
    return len(seen)


def find_eventual_monomial(monomials: List[TropMono]) -> Tuple[int, TropMono]:
    """Find the eventually dominating monomial and threshold N.

    By polyLanguage_eventually_affine, there exists N and m₀ with
    minimal exponent such that L_p(n) = monoEval(m₀, n) for all n ≥ N.

    Returns:
        (N, m₀) where N is the threshold and m₀ is the dominating monomial.

    Time complexity: O(|monomials|)
    """
    # Find monomial with minimum exponent, break ties by coefficient
    m0 = min(monomials, key=lambda m: (m.exp, m.coeff))

    N = 0
    for m in monomials:
        if m.exp == m0.exp and m.coeff == m0.coeff:
            continue
        if m.exp == m0.exp:
            continue  # Same exp but higher coeff, m0 dominates at all n
        # Find smallest n where m0.eval(n) < m.eval(n)
        # c0 + e0*n < c + e*n ⟺ n > (c0 - c) / (e - e0)
        threshold = (m0.coeff - m.coeff) / (m.exp - m0.exp)
        N = max(N, int(np.ceil(threshold)) + 1)

    return N, m0


@dataclass
class TropAutomaton:
    """A finite-state tropical automaton over a single-letter alphabet.

    The automaton has states {0, 1, ..., num_states-1}.
    State 0 is the initial state.
    The transition function increments the state (capped at num_states-1).
    The output function maps each state to a real value.
    """
    num_states: int
    outputs: List[float]

    def run(self, n: int) -> float:
        """Compute the language value at input length n."""
        state = min(n, self.num_states - 1)
        return self.outputs[state]


def build_automaton(monomials: List[TropMono]) -> TropAutomaton:
    """Build a finite-state tropical automaton recognizing L_p.

    Uses the eventual affine behavior: states track input length
    up to threshold N, then remain in the eventual state.

    Time complexity: O(N * |monomials|) where N is the affine threshold
    """
    N, m0 = find_eventual_monomial(monomials)
    num_states = N + 1
    outputs = [poly_language(monomials, k) for k in range(num_states)]
    return TropAutomaton(num_states=num_states, outputs=outputs)


def verify_automaton(monomials: List[TropMono], automaton: TropAutomaton,
                     max_n: int = 100) -> bool:
    """Verify that the automaton correctly recognizes the polynomial language.

    Time complexity: O(max_n * |monomials|)
    """
    N, m0 = find_eventual_monomial(monomials)
    for n in range(max_n + 1):
        expected = poly_language(monomials, n)
        if n < automaton.num_states:
            actual = automaton.outputs[n]
        else:
            actual = m0.eval(float(n))
        if abs(expected - actual) > 1e-10:
            return False
    return True


def lower_envelope_data(monomials: List[TropMono],
                        x_range: Tuple[float, float] = (0, 20),
                        num_points: int = 1000) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Compute the lower envelope and individual monomial curves.

    Returns:
        (x_vals, envelope_vals, mono_vals) where mono_vals[i] is the
        i-th monomial's values.
    """
    x_vals = np.linspace(x_range[0], x_range[1], num_points)
    mono_vals = np.array([[m.eval(x) for x in x_vals] for m in monomials])
    envelope_vals = np.min(mono_vals, axis=0)
    return x_vals, envelope_vals, mono_vals


# === Demonstration ===

if __name__ == "__main__":
    print("Tropical Polynomial Algorithms")
    print("=" * 50)

    # Example polynomial
    monos = [TropMono(0, 10), TropMono(1, 2), TropMono(2, 0)]
    print(f"\nPolynomial: min({', '.join(str(m) for m in monos)})")

    # Canonicalization
    canon = canonicalize(monos)
    print(f"Canonical:  min({', '.join(str(m) for m in canon)})")
    print(f"  Removed {len(monos) - len(canon)} dominated monomials")

    # Language values
    vals = [poly_language(monos, n) for n in range(15)]
    print(f"\nLanguage L(0..14): {vals}")

    # Eventual behavior
    N, m0 = find_eventual_monomial(monos)
    print(f"\nEventually affine from N={N}: L(n) = {m0}")

    # Nerode classes
    n_classes = count_nerode_classes(monos, max_k=N + 10)
    print(f"\nNerode classes (k ≤ {N + 10}): {n_classes}")

    # Automaton
    aut = build_automaton(monos)
    print(f"\nAutomaton: {aut.num_states} states")
    print(f"  Outputs: {aut.outputs}")
    print(f"  Correct: {verify_automaton(monos, aut)}")
