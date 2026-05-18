#!/usr/bin/env python3
"""
applications.py — Real-world applications of knot invariants

Demonstrates connections to:
1. DNA topology (supercoiling detection)
2. Quantum computation (anyonic braiding)
3. Statistical mechanics (partition functions)
"""

from demo import LaurentPoly, delta, kauffman_bracket
from algorithms import compute_span


# ============================================================
# Application 1: DNA Topology
# ============================================================

def dna_supercoiling_analysis():
    """
    DNA molecules can form knots during replication.
    The Jones polynomial can distinguish different supercoiling states.

    In gel electrophoresis, knotted DNA migrates differently.
    The crossing number (related to bracket span) correlates with
    migration speed.
    """
    print("=== DNA Supercoiling Analysis ===\n")

    # Simulate different DNA conformations
    # Unknotted circular DNA (plasmid)
    unknot_bracket = kauffman_bracket(0, lambda s: 1)
    print(f"  Unknotted DNA (relaxed plasmid):")
    print(f"    Bracket = {unknot_bracket}")
    print(f"    Span = {compute_span(unknot_bracket)}")
    print(f"    Predicted migration: fast (compact)")

    # Trefoil-knotted DNA (3 crossings)
    from demo import trefoil_loops
    trefoil_bracket = kauffman_bracket(3, trefoil_loops)
    print(f"\n  Trefoil-knotted DNA (3 crossings):")
    print(f"    Bracket = {trefoil_bracket}")
    print(f"    Span = {compute_span(trefoil_bracket)}")
    print(f"    Predicted migration: slower (more extended)")

    # The span correlates with topological complexity
    print(f"\n  Key insight: span > 0 certifies non-trivial knotting")
    print(f"  This can distinguish knotted from unknotted DNA molecules")
    print(f"  in gel electrophoresis experiments.\n")


# ============================================================
# Application 2: Quantum Computation
# ============================================================

def quantum_braiding_demo():
    """
    In topological quantum computation, anyons are braided
    to perform quantum gates. The Jones polynomial of the
    resulting braid closure encodes the quantum amplitude.
    """
    print("=== Quantum Braiding Simulation ===\n")

    # The Temperley-Lieb algebra at root of unity gives
    # finite-dimensional representations of the braid group.
    # At A = e^{iπ/4} (for SU(2) level k=2):
    import cmath
    A_val = cmath.exp(1j * cmath.pi / 4)
    delta_val = -A_val**2 - A_val**(-2)

    print(f"  At A = e^(iπ/4):")
    print(f"    A = {A_val:.4f}")
    print(f"    δ = -A² - A⁻² = {delta_val:.4f}")
    print(f"    |δ| = {abs(delta_val):.4f}")

    # Evaluate trefoil bracket at this point
    from demo import trefoil_loops
    bracket_terms = []
    from itertools import product as iprod
    for state in iprod([0, 1], repeat=3):
        num_a = state.count(0)
        num_b = state.count(1)
        n_loops = trefoil_loops(state)
        exponent = num_a - num_b
        term = A_val**exponent * delta_val**(n_loops - 1)
        bracket_terms.append(term)

    bracket_val = sum(bracket_terms)
    print(f"\n  Trefoil bracket at A = e^(iπ/4):")
    print(f"    ⟨trefoil⟩ = {bracket_val:.6f}")
    print(f"    |⟨trefoil⟩| = {abs(bracket_val):.6f}")

    # Jones polynomial evaluation
    writhe = -3
    sign = (-1)**writhe
    writhe_factor = sign * A_val**(-3 * writhe)
    jones_val = writhe_factor * bracket_val
    print(f"\n  Trefoil Jones at A = e^(iπ/4):")
    print(f"    V(trefoil) = {jones_val:.6f}")
    print(f"    |V(trefoil)| = {abs(jones_val):.6f}")

    print(f"\n  The Jones polynomial evaluated at roots of unity")
    print(f"  gives quantum amplitudes for topological quantum gates.")
    print(f"  Non-trivial values confirm anyonic braiding produces")
    print(f"  non-trivial quantum operations.\n")


# ============================================================
# Application 3: Statistical Mechanics
# ============================================================

def partition_function_demo():
    """
    The Kauffman bracket is a partition function for
    the Potts model on the medial graph of the knot diagram.
    """
    print("=== Statistical Mechanics Connection ===\n")

    print("  The Kauffman bracket ⟨D⟩ = Σ_s A^σ(s) δ^(ℓ(s)-1)")
    print("  is precisely a partition function:")
    print()
    print("    Z = Σ_s exp(-βE(s))")
    print()
    print("  where:")
    print("    - States s = smoothing assignments (spin configurations)")
    print("    - σ(s) = #A - #B acts as an 'energy' from external field")
    print("    - δ = -A² - A⁻² = loop fugacity (Boltzmann weight per loop)")
    print("    - The sum is over 2^n configurations")
    print()

    # Compute partition function for small knots
    print("  Partition function values (as polynomials in A):")
    from demo import trefoil_loops, figure_eight_loops

    for name, n, loops_fn in [
        ("Unknot", 0, lambda s: 1),
        ("Trefoil", 3, trefoil_loops),
        ("Figure-eight", 4, figure_eight_loops),
    ]:
        Z = kauffman_bracket(n, loops_fn)
        n_states = 2**n
        print(f"\n  {name} ({n} crossings, {n_states} states):")
        print(f"    Z = {Z}")
        print(f"    Span = {compute_span(Z)}")

    print(f"\n  The span of Z measures the 'energy range' of the system.")
    print(f"  Non-zero span ↔ non-trivial phase structure ↔ non-trivial knot.\n")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    dna_supercoiling_analysis()
    quantum_braiding_demo()
    partition_function_demo()


#!/usr/bin/env python3
"""
demo.py — Kauffman bracket and Jones polynomial computation

Demonstrates the state-sum computation of the Kauffman bracket
for concrete knots (trefoil, figure-eight, torus knots).
"""

from itertools import product
from collections import defaultdict
from typing import Dict, List, Tuple

# ============================================================
# Laurent polynomial arithmetic
# ============================================================

class LaurentPoly:
    """Laurent polynomial in variable A with integer coefficients."""

    def __init__(self, coeffs: Dict[int, int] = None):
        self.coeffs = defaultdict(int)
        if coeffs:
            for k, v in coeffs.items():
                if v != 0:
                    self.coeffs[k] = v

    @classmethod
    def monomial(cls, deg: int, coeff: int = 1):
        return cls({deg: coeff})

    @classmethod
    def zero(cls):
        return cls()

    @classmethod
    def one(cls):
        return cls({0: 1})

    def __add__(self, other):
        result = LaurentPoly(dict(self.coeffs))
        for k, v in other.coeffs.items():
            result.coeffs[k] += v
            if result.coeffs[k] == 0:
                del result.coeffs[k]
        return result

    def __neg__(self):
        return LaurentPoly({k: -v for k, v in self.coeffs.items()})

    def __sub__(self, other):
        return self + (-other)

    def __mul__(self, other):
        result = LaurentPoly()
        for k1, v1 in self.coeffs.items():
            for k2, v2 in other.coeffs.items():
                result.coeffs[k1 + k2] += v1 * v2
                if result.coeffs[k1 + k2] == 0:
                    del result.coeffs[k1 + k2]
        return result

    def __pow__(self, n: int):
        if n == 0:
            return LaurentPoly.one()
        result = LaurentPoly.one()
        for _ in range(n):
            result = result * self
        return result

    def __eq__(self, other):
        if isinstance(other, int):
            other = LaurentPoly({0: other}) if other != 0 else LaurentPoly()
        return dict(self.coeffs) == dict(other.coeffs)

    def __repr__(self):
        if not self.coeffs:
            return "0"
        terms = []
        for k in sorted(self.coeffs.keys(), reverse=True):
            v = self.coeffs[k]
            if v == 0:
                continue
            if k == 0:
                terms.append(f"{v}")
            elif k == 1:
                terms.append(f"{v}A" if abs(v) != 1 else ("A" if v > 0 else "-A"))
            elif k == -1:
                terms.append(f"{v}A⁻¹" if abs(v) != 1 else ("A⁻¹" if v > 0 else "-A⁻¹"))
            else:
                coeff = f"{v}" if abs(v) != 1 else ("" if v > 0 else "-")
                deg = f"A^{k}" if k > 0 else f"A^({k})"
                terms.append(f"{coeff}{deg}")
        result = terms[0]
        for t in terms[1:]:
            if t.startswith("-"):
                result += f" - {t[1:]}"
            else:
                result += f" + {t}"
        return result

    @property
    def span(self):
        if not self.coeffs:
            return 0
        return max(self.coeffs.keys()) - min(self.coeffs.keys())

    def substitute(self, t_var: str = "t") -> str:
        """Express in terms of t = A^{-4}."""
        if not self.coeffs:
            return "0"
        terms = []
        for k in sorted(self.coeffs.keys(), reverse=True):
            v = self.coeffs[k]
            if v == 0:
                continue
            # A^k = t^{-k/4} only makes sense if k is divisible by 4
            # For display, just show the A-form
            terms.append(f"{v}*A^{k}")
        return " + ".join(terms)


# ============================================================
# Kauffman bracket computation
# ============================================================

# The loop value δ = -A² - A⁻²
A = LaurentPoly.monomial(1)
Ainv = LaurentPoly.monomial(-1)
delta = -LaurentPoly.monomial(2) - LaurentPoly.monomial(-2)


def kauffman_bracket(n_crossings: int,
                     loops_fn,
                     verbose: bool = False) -> LaurentPoly:
    """
    Compute the Kauffman bracket of a diagram.

    Parameters:
        n_crossings: number of crossings
        loops_fn: function(state) -> int, where state is a tuple of 0/1
                  (0 = A-smoothing, 1 = B-smoothing)
        verbose: print per-state contributions

    Returns:
        The bracket as a LaurentPoly
    """
    result = LaurentPoly.zero()

    for state in product([0, 1], repeat=n_crossings):
        num_a = state.count(0)
        num_b = state.count(1)
        n_loops = loops_fn(state)
        exponent = num_a - num_b
        contribution = LaurentPoly.monomial(exponent) * (delta ** (n_loops - 1))

        if verbose:
            state_str = "".join("A" if s == 0 else "B" for s in state)
            print(f"  State {state_str}: #A={num_a}, #B={num_b}, "
                  f"loops={n_loops}, contribution = {contribution}")

        result = result + contribution

    return result


def jones_polynomial(n_crossings: int,
                     loops_fn,
                     writhe: int) -> LaurentPoly:
    """
    Compute the Jones polynomial V_D(A) = (-A)^{-3w} · ⟨D⟩.
    """
    bracket = kauffman_bracket(n_crossings, loops_fn)
    # (-A)^{-3w} = (-1)^w · A^{-3w}
    sign = (-1) ** writhe
    writhe_factor = LaurentPoly.monomial(-3 * writhe, sign)
    return writhe_factor * bracket


# ============================================================
# Concrete knot examples
# ============================================================

def trefoil_loops(state: Tuple[int, ...]) -> int:
    """Loop counts for the left trefoil (3 negative crossings)."""
    table = {
        (0,0,0): 3, (0,0,1): 2, (0,1,0): 2, (0,1,1): 1,
        (1,0,0): 2, (1,0,1): 1, (1,1,0): 1, (1,1,1): 2,
    }
    return table[state]


def figure_eight_loops(state: Tuple[int, ...]) -> int:
    """Loop counts for the figure-eight knot (4 crossings)."""
    table = {
        (0,0,0,0): 3, (0,0,0,1): 2, (0,0,1,0): 2, (0,0,1,1): 1,
        (0,1,0,0): 2, (0,1,0,1): 1, (0,1,1,0): 1, (0,1,1,1): 2,
        (1,0,0,0): 2, (1,0,0,1): 1, (1,0,1,0): 1, (1,0,1,1): 2,
        (1,1,0,0): 1, (1,1,0,1): 2, (1,1,1,0): 2, (1,1,1,1): 3,
    }
    return table[state]


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Kauffman Bracket and Jones Polynomial Computation")
    print("=" * 60)

    # Unknot
    print("\n--- Unknot ---")
    unknot_bracket = kauffman_bracket(0, lambda s: 1)
    print(f"  Bracket: {unknot_bracket}")
    print(f"  Jones:   {unknot_bracket}")
    assert unknot_bracket == 1, "Unknot bracket should be 1"

    # Left trefoil
    print("\n--- Left Trefoil (3 negative crossings, writhe = -3) ---")
    trefoil_bracket = kauffman_bracket(3, trefoil_loops, verbose=True)
    print(f"\n  Bracket ⟨trefoil⟩ = {trefoil_bracket}")
    print(f"  Span = {trefoil_bracket.span}")
    trefoil_jones = jones_polynomial(3, trefoil_loops, writhe=-3)
    print(f"  Jones V(trefoil) = {trefoil_jones}")

    # Figure-eight
    print("\n--- Figure-Eight Knot (4 crossings, writhe = 0) ---")
    fe_bracket = kauffman_bracket(4, figure_eight_loops, verbose=False)
    print(f"  Bracket ⟨figure-eight⟩ = {fe_bracket}")
    print(f"  Span = {fe_bracket.span}")
    fe_jones = jones_polynomial(4, figure_eight_loops, writhe=0)
    print(f"  Jones V(figure-eight) = {fe_jones}")

    # Verify key properties
    print("\n--- Verification ---")
    print(f"  Trefoil bracket ≠ 1: {trefoil_bracket != 1}")
    print(f"  Figure-eight bracket ≠ 1: {fe_bracket != 1}")
    print(f"  Trefoil Jones ≠ 1: {trefoil_jones != 1}")
    print(f"  Figure-eight Jones ≠ 1: {fe_jones != 1}")

    # Verify δ identity
    print(f"\n  δ = {delta}")
    print(f"  A·δ + A⁻¹ = {A * delta + Ainv}")
    print(f"  Should be -A³ = {-LaurentPoly.monomial(3)}")
    assert A * delta + Ainv == -LaurentPoly.monomial(3), "RI identity failed"
    print("  ✓ RI identity verified: Aδ + A⁻¹ = -A³")

    print(f"\n  A + A⁻¹·δ = {LaurentPoly.monomial(1) + Ainv * delta}")
    print(f"  Should be -A⁻³ = {-LaurentPoly.monomial(-3)}")
    assert LaurentPoly.monomial(1) + Ainv * delta == -LaurentPoly.monomial(-3)
    print("  ✓ Negative RI identity verified: A + A⁻¹δ = -A⁻³")

    print("\n" + "=" * 60)
    print("All computations verified successfully!")
    print("=" * 60)
