#!/usr/bin/env python3
"""
Algorithms for Gröbner Footprint Analysis on Finite Grids

Implements the computational side of the footprint bound theorem,
including polynomial reduction, leading monomial extraction, and
anti-footprint computation over finite fields.
"""

import itertools
from typing import Dict, Tuple, List, Optional
from functools import reduce


# ============================================================
# Core Finite Field Arithmetic
# ============================================================

class GFPoly:
    """
    Multivariate polynomial over GF(q) for prime q.

    Represented as a dictionary: exponent tuple → coefficient (mod q).
    Only nonzero coefficients are stored.

    Attributes:
        terms: Dict mapping exponent tuples to nonzero coefficients mod q.
        n_vars: Number of variables.
        q: Field size (prime).
    """

    def __init__(self, terms: Dict[Tuple[int, ...], int], n_vars: int, q: int):
        self.q = q
        self.n_vars = n_vars
        self.terms: Dict[Tuple[int, ...], int] = {}
        for exp, coeff in terms.items():
            c = coeff % q
            if c != 0:
                assert len(exp) == n_vars, f"Exponent tuple length mismatch: {len(exp)} vs {n_vars}"
                self.terms[exp] = c

    def is_zero(self) -> bool:
        """Check if polynomial is the zero polynomial."""
        return len(self.terms) == 0

    def is_reduced(self) -> bool:
        """Check if all exponents are < q (reduced mod grid)."""
        return all(e < self.q for exp in self.terms for e in exp)

    def eval(self, point: Tuple[int, ...]) -> int:
        """Evaluate polynomial at a point in GF(q)^n."""
        result = 0
        for exp, coeff in self.terms.items():
            term = coeff
            for i, e in enumerate(exp):
                term = (term * pow(point[i], e, self.q)) % self.q
            result = (result + term) % self.q
        return result

    def lex_leading_monomial(self) -> Optional[Tuple[int, ...]]:
        """Return the lexicographically largest monomial."""
        if self.is_zero():
            return None
        return max(self.terms.keys())

    def leading_coefficient(self) -> int:
        """Return the coefficient of the lex-leading monomial."""
        lm = self.lex_leading_monomial()
        if lm is None:
            return 0
        return self.terms[lm]

    def __repr__(self) -> str:
        if self.is_zero():
            return "0"
        parts = []
        for exp in sorted(self.terms.keys(), reverse=True):
            coeff = self.terms[exp]
            vars_str = ""
            for i, e in enumerate(exp):
                if e > 0:
                    var = f"X{i}"
                    if e > 1:
                        var += f"^{e}"
                    vars_str += var
            if vars_str:
                if coeff == 1:
                    parts.append(vars_str)
                else:
                    parts.append(f"{coeff}·{vars_str}")
            else:
                parts.append(str(coeff))
        return " + ".join(parts)


# ============================================================
# Reduction Modulo the Grid Ideal
# ============================================================

def reduce_mod_grid(poly: GFPoly) -> GFPoly:
    """
    Reduce a polynomial modulo X_i^q - X_i for all variables.

    Over GF(q), every element satisfies a^q = a (Fermat's little theorem /
    finite field axiom). So X_i^q can be replaced by X_i.

    More precisely, for exponent e_i:
    - If e_i = 0: X_i^0 = 1 (stays as is)
    - If e_i > 0: X_i^{e_i} = X_i^{((e_i - 1) mod (q-1)) + 1} over GF(q)*
      but we must handle x=0 separately.

    The correct reduction: replace e_i with ((e_i - 1) % (q-1)) + 1 if e_i > 0.

    Time complexity: O(|support| × n_vars)
    Space complexity: O(|support|)

    Args:
        poly: Input polynomial over GF(q).

    Returns:
        Reduced polynomial with all exponents < q.
    """
    q = poly.q
    new_terms: Dict[Tuple[int, ...], int] = {}

    for exp, coeff in poly.terms.items():
        new_exp = []
        for e in exp:
            if e == 0:
                new_exp.append(0)
            elif q == 1:
                new_exp.append(0)
            else:
                # x^e = x^{((e-1) mod (q-1)) + 1} for x ≠ 0, and 0^e = 0 for e > 0
                new_e = ((e - 1) % (q - 1)) + 1
                new_exp.append(new_e)
        new_exp_tuple = tuple(new_exp)
        if new_exp_tuple in new_terms:
            new_terms[new_exp_tuple] = (new_terms[new_exp_tuple] + coeff) % q
        else:
            new_terms[new_exp_tuple] = coeff % q

    # Remove zero coefficients
    new_terms = {k: v for k, v in new_terms.items() if v != 0}
    return GFPoly(new_terms, poly.n_vars, q)


# ============================================================
# Anti-Footprint Computation
# ============================================================

def anti_footprint_card(leading_exp: Tuple[int, ...], q: int) -> int:
    """
    Compute the anti-footprint cardinality: ∏(q - e_i).

    This is the lower bound on the number of nonzero evaluations
    guaranteed by the footprint bound theorem.

    Args:
        leading_exp: Exponent vector of the leading monomial.
        q: Field size.

    Returns:
        Product ∏(q - e_i).
    """
    result = 1
    for e in leading_exp:
        result *= (q - e)
    return result


def anti_footprint_set(leading_exp: Tuple[int, ...], q: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all monomials in the anti-footprint region.

    The anti-footprint of monomial m with exponent vector e in the q-box
    consists of all monomials with exponents a_i satisfying e_i ≤ a_i < q.

    Args:
        leading_exp: Exponent vector of the leading monomial.
        q: Field size.

    Returns:
        List of exponent tuples in the anti-footprint.
    """
    ranges = [range(e, q) for e in leading_exp]
    return list(itertools.product(*ranges))


def footprint_set(leading_exp: Tuple[int, ...], q: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all monomials in the footprint (complement of anti-footprint in q-box).

    Args:
        leading_exp: Exponent vector of the leading monomial.
        q: Field size.

    Returns:
        List of exponent tuples in the footprint.
    """
    anti = set(anti_footprint_set(leading_exp, q))
    all_monomials = itertools.product(*[range(q) for _ in leading_exp])
    return [m for m in all_monomials if m not in anti]


# ============================================================
# Verification Algorithm
# ============================================================

def verify_footprint_bound(poly: GFPoly) -> dict:
    """
    Verify the footprint bound for a given polynomial.

    Computes the actual number of nonzero evaluations and compares
    with the anti-footprint bound.

    Time complexity: O(q^n × |support|)

    Args:
        poly: Nonzero reduced polynomial over GF(q).

    Returns:
        Dictionary with verification results.
    """
    assert not poly.is_zero(), "Polynomial must be nonzero"
    assert poly.is_reduced(), "Polynomial must be reduced"

    q = poly.q
    n = poly.n_vars

    # Count nonzero evaluations
    nonzero_count = 0
    zero_points = []
    nonzero_points = []

    for point in itertools.product(range(q), repeat=n):
        val = poly.eval(point)
        if val != 0:
            nonzero_count += 1
            nonzero_points.append(point)
        else:
            zero_points.append(point)

    # Compute bound
    leading = poly.lex_leading_monomial()
    bound = anti_footprint_card(leading, q)

    return {
        "polynomial": str(poly),
        "field_size": q,
        "n_vars": n,
        "leading_monomial": leading,
        "anti_footprint_bound": bound,
        "actual_nonzero": nonzero_count,
        "total_points": q ** n,
        "bound_satisfied": nonzero_count >= bound,
        "tightness_ratio": nonzero_count / bound if bound > 0 else float('inf'),
        "zero_points": zero_points,
    }


# ============================================================
# Inductive Proof Illustration
# ============================================================

def illustrate_induction(poly: GFPoly) -> None:
    """
    Illustrate the inductive proof of the footprint bound.

    Shows how the polynomial decomposes into fibers and how the
    univariate root bound combines with the inductive hypothesis.

    Args:
        poly: Nonzero reduced polynomial over GF(q).
    """
    q = poly.q
    n = poly.n_vars

    print(f"\n  Inductive proof illustration for: {poly}")
    print(f"  Over GF({q}), {n} variables")

    if n == 0:
        print("  Base case: 0 variables, polynomial is a constant ≠ 0")
        print("  Exactly 1 evaluation point, value is nonzero ✓")
        return

    # View as polynomial in X_0 with coefficients in GF(q)[X_1,...,X_{n-1}]
    # Group terms by X_0 exponent
    by_x0_degree: Dict[int, Dict[Tuple[int, ...], int]] = {}
    for exp, coeff in poly.terms.items():
        d0 = exp[0]
        rest = exp[1:]
        if d0 not in by_x0_degree:
            by_x0_degree[d0] = {}
        by_x0_degree[d0][rest] = coeff

    max_d0 = max(by_x0_degree.keys())
    leading_coeff_terms = by_x0_degree[max_d0]

    print(f"\n  Step 1: View as polynomial in X₀ of degree {max_d0}")
    print(f"  Leading coefficient (in X₁,...,X_{n-1}): ", end="")
    lc_poly = GFPoly(leading_coeff_terms, n - 1, q)
    print(lc_poly)

    # Count where leading coefficient is nonzero
    lc_nonzero = 0
    for point in itertools.product(range(q), repeat=n - 1):
        if lc_poly.eval(point) != 0:
            lc_nonzero += 1

    lm = poly.lex_leading_monomial()
    lc_lm = lc_poly.lex_leading_monomial()
    lc_bound = anti_footprint_card(lc_lm, q) if lc_lm else 1

    print(f"\n  Step 2: Leading coefficient has {lc_nonzero} nonzero evaluations")
    print(f"  Inductive bound: ∏(q - e_i) for i≥1 = {lc_bound}")

    print(f"\n  Step 3: For each 'good' tail assignment s (lc(s) ≠ 0):")
    print(f"    Specialized polynomial has degree {max_d0} in X₀")
    print(f"    → at most {max_d0} zeros in X₀")
    print(f"    → at least {q} - {max_d0} = {q - max_d0} nonzero values")

    total_bound = lc_bound * (q - max_d0)
    actual = sum(1 for pt in itertools.product(range(q), repeat=n)
                 if poly.eval(pt) != 0)

    print(f"\n  Step 4: Total bound = {lc_bound} × {q - max_d0} = {total_bound}")
    print(f"  Actual nonzero evaluations: {actual}")
    print(f"  Bound satisfied: {actual >= total_bound} ✓")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Example 1: Reduction
    print("\n--- Reduction mod grid ---")
    p = GFPoly({(5, 3): 1, (1, 1): 2, (0, 0): 1}, 2, 3)
    print(f"  Original: {p}")
    r = reduce_mod_grid(p)
    print(f"  Reduced mod X^3-X: {r}")
    print(f"  Is reduced: {r.is_reduced()}")

    # Example 2: Anti-footprint
    print("\n--- Anti-footprint ---")
    leading = (2, 1)
    q = 5
    af_card = anti_footprint_card(leading, q)
    af_set = anti_footprint_set(leading, q)
    print(f"  Leading monomial exps: {leading}, q={q}")
    print(f"  Anti-footprint cardinality: {af_card}")
    print(f"  Anti-footprint monomials: {af_set}")

    # Example 3: Verification
    print("\n--- Bound verification ---")
    poly = GFPoly({(2, 1): 1, (1, 0): 1, (0, 2): 1, (0, 0): 1}, 2, 5)
    result = verify_footprint_bound(poly)
    for k, v in result.items():
        if k != 'zero_points':
            print(f"  {k}: {v}")

    # Example 4: Induction illustration
    print("\n--- Induction illustration ---")
    poly = GFPoly({(2, 1): 1, (0, 2): 1, (0, 0): 1}, 2, 3)
    illustrate_induction(poly)

    print("\n\nAll algorithm demonstrations complete!")
