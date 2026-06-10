#!/usr/bin/env python3
"""
Algorithms for Sum-Check Protocol Soundness Analysis

Implements the core algebraic primitives and protocol simulations
for the sum-check interactive proof system.
"""

from typing import List, Tuple, Optional
import random


class FiniteFieldPoly:
    """Polynomial over F_p (integers mod a prime p).

    Coefficients are stored in ascending degree order:
    coeffs[i] is the coefficient of x^i.

    Example:
        >>> p = FiniteFieldPoly([3, 2, 1], 7)  # x^2 + 2x + 3 over F_7
        >>> p.eval(2)  # 1*4 + 2*2 + 3 = 11 ≡ 4 mod 7
        4
    """

    def __init__(self, coeffs: List[int], prime: int):
        self.prime = prime
        self.coeffs = [c % prime for c in coeffs]
        self._trim()

    def _trim(self):
        """Remove trailing zero coefficients."""
        while len(self.coeffs) > 1 and self.coeffs[-1] == 0:
            self.coeffs.pop()

    @property
    def degree(self) -> int:
        """Natural degree of the polynomial."""
        if self.is_zero():
            return 0
        return len(self.coeffs) - 1

    def is_zero(self) -> bool:
        """Check if this is the zero polynomial."""
        return all(c == 0 for c in self.coeffs)

    def eval(self, x: int) -> int:
        """Evaluate the polynomial at x using Horner's method.

        Time complexity: O(degree)

        Args:
            x: Point at which to evaluate (will be reduced mod p)

        Returns:
            p(x) mod prime
        """
        x = x % self.prime
        result = 0
        for c in reversed(self.coeffs):
            result = (result * x + c) % self.prime
        return result

    def __sub__(self, other: 'FiniteFieldPoly') -> 'FiniteFieldPoly':
        """Subtract two polynomials over the same field."""
        assert self.prime == other.prime
        n = max(len(self.coeffs), len(other.coeffs))
        result = [0] * n
        for i in range(n):
            a = self.coeffs[i] if i < len(self.coeffs) else 0
            b = other.coeffs[i] if i < len(other.coeffs) else 0
            result[i] = (a - b) % self.prime
        return FiniteFieldPoly(result, self.prime)

    def __eq__(self, other) -> bool:
        if not isinstance(other, FiniteFieldPoly):
            return False
        if self.prime != other.prime:
            return False
        return self.coeffs == other.coeffs

    def __ne__(self, other) -> bool:
        return not self.__eq__(other)

    def roots(self) -> List[int]:
        """Find all roots of the polynomial in F_p.

        Time complexity: O(p) — brute force over all field elements.

        Returns:
            Sorted list of roots in {0, 1, ..., p-1}
        """
        return [x for x in range(self.prime) if self.eval(x) == 0]

    def agreement_set(self, other: 'FiniteFieldPoly') -> List[int]:
        """Find all points where self and other agree.

        Equivalent to (self - other).roots().

        Returns:
            Sorted list of agreement points
        """
        return (self - other).roots()

    def __repr__(self) -> str:
        terms = []
        for i, c in enumerate(self.coeffs):
            if c == 0:
                continue
            if i == 0:
                terms.append(str(c))
            elif i == 1:
                terms.append(f"{c}x" if c != 1 else "x")
            else:
                terms.append(f"{c}x^{i}" if c != 1 else f"x^{i}")
        return " + ".join(terms) if terms else "0"


def verify_root_bound(p: FiniteFieldPoly, q: FiniteFieldPoly) -> dict:
    """Verify the Schwartz-Zippel root bound for two polynomials.

    Checks that |{x : p(x) = q(x)}| ≤ natDegree(p - q).

    Args:
        p, q: Polynomials over the same finite field

    Returns:
        Dictionary with verification results

    Example:
        >>> p = FiniteFieldPoly([1, 3], 7)
        >>> q = FiniteFieldPoly([1, 5], 7)
        >>> result = verify_root_bound(p, q)
        >>> result['bound_holds']
        True
    """
    diff = p - q
    agree = p.agreement_set(q)
    bound = diff.degree

    return {
        'p': str(p),
        'q': str(q),
        'p_minus_q': str(diff),
        'degree_diff': bound,
        'agreement_points': agree,
        'agreement_count': len(agree),
        'bound_holds': len(agree) <= bound,
        'detection_probability': 1 - len(agree) / p.prime if p != q else 0.0
    }


def sumcheck_one_round(
    sent: FiniteFieldPoly,
    true_poly: FiniteFieldPoly,
    challenge: Optional[int] = None
) -> dict:
    """Simulate one round of the sum-check protocol.

    The verifier checks whether sent.eval(r) == true_poly.eval(r)
    for a random (or specified) challenge r.

    Args:
        sent: Polynomial sent by the prover
        true_poly: True partial-sum polynomial
        challenge: Optional specific challenge point; random if None

    Returns:
        Dictionary with round results
    """
    prime = sent.prime
    if challenge is None:
        challenge = random.randint(0, prime - 1)

    sent_val = sent.eval(challenge)
    true_val = true_poly.eval(challenge)
    passed = (sent_val == true_val)
    is_honest = (sent == true_poly)

    return {
        'challenge': challenge,
        'sent_value': sent_val,
        'true_value': true_val,
        'check_passed': passed,
        'is_honest': is_honest,
        'correct_detection': is_honest or not passed
    }


def sumcheck_multi_round_simulation(
    n_rounds: int,
    degree: int,
    prime: int,
    n_trials: int = 10000
) -> dict:
    """Simulate multi-round sum-check with a cheating prover.

    At each round, we model the cheating prover as sending a polynomial
    that differs from the true one, with the discrepancy polynomial
    having exactly `degree` roots (worst case).

    Args:
        n_rounds: Number of protocol rounds
        degree: Maximum degree per round
        prime: Size of the finite field
        n_trials: Number of Monte Carlo trials

    Returns:
        Dictionary with simulation results

    Algorithm:
        1. For each trial, simulate n_rounds independent checks.
        2. At each round, the cheater passes iff the random challenge
           lands on one of ≤ degree agreement points.
        3. The cheater wins only if ALL rounds pass.
        4. Compare empirical success rate with theoretical bound n*d/|F|.

    Time complexity: O(n_trials * n_rounds)
    Space complexity: O(1)
    """
    cheat_successes = 0

    for _ in range(n_trials):
        all_passed = True
        for _ in range(n_rounds):
            # Model: agreement set has exactly `degree` points
            # Probability of hitting one: degree / prime
            r = random.randint(0, prime - 1)
            if r >= degree:  # not in agreement set
                all_passed = False
                break
        if all_passed:
            cheat_successes += 1

    empirical_rate = cheat_successes / n_trials
    # Exact probability: (degree/prime)^n_rounds (independence)
    exact_prob = (degree / prime) ** n_rounds
    # Union bound: n_rounds * degree / prime
    union_bound = min(1.0, n_rounds * degree / prime)

    return {
        'n_rounds': n_rounds,
        'degree': degree,
        'prime': prime,
        'n_trials': n_trials,
        'empirical_cheat_rate': empirical_rate,
        'exact_probability': exact_prob,
        'union_bound': union_bound,
        'empirical_below_bound': empirical_rate <= union_bound * 1.01
    }


def schwartz_zippel_analysis(prime: int, max_degree: int) -> List[dict]:
    """Analyze the Schwartz-Zippel bound across degrees for a given field.

    For each degree d from 1 to max_degree, constructs a polynomial
    with exactly d roots and verifies the bound.

    Args:
        prime: Field size (must be prime)
        max_degree: Maximum degree to test

    Returns:
        List of analysis results per degree
    """
    results = []
    for d in range(1, min(max_degree + 1, prime)):
        # Construct polynomial with exactly d roots: prod(x - i) for i in 0..d-1
        poly = FiniteFieldPoly([1], prime)
        for i in range(d):
            # Multiply by (x - i)
            new_coeffs = [0] * (len(poly.coeffs) + 1)
            neg_i = (-i) % prime
            for j, c in enumerate(poly.coeffs):
                new_coeffs[j] = (new_coeffs[j] + c * neg_i) % prime
                new_coeffs[j + 1] = (new_coeffs[j + 1] + c) % prime
            poly = FiniteFieldPoly(new_coeffs, prime)

        roots = poly.roots()
        results.append({
            'degree': d,
            'polynomial': str(poly),
            'roots': roots,
            'root_count': len(roots),
            'bound': d,
            'tight': len(roots) == d,
            'fraction': len(roots) / prime
        })

    return results


if __name__ == "__main__":
    print("=== Schwartz-Zippel Analysis over F_13 ===\n")
    analysis = schwartz_zippel_analysis(13, 6)
    for r in analysis:
        status = "TIGHT" if r['tight'] else "LOOSE"
        print(f"  deg {r['degree']}: {r['root_count']} roots ≤ {r['bound']}  [{status}]"
              f"  fraction = {r['fraction']:.4f}")

    print("\n=== Multi-Round Simulation ===\n")
    for n in [1, 5, 10]:
        result = sumcheck_multi_round_simulation(n, 1, 101, 50000)
        print(f"  {n} rounds: empirical={result['empirical_cheat_rate']:.6f}"
              f"  exact={result['exact_probability']:.6f}"
              f"  bound={result['union_bound']:.6f}")
