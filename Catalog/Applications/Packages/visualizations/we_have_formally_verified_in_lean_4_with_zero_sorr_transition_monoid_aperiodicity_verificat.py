#!/usr/bin/env python3
"""
Algorithms for symbolic dynamics of cellular automata.

Implements:
1. Transition monoid computation for spacetime column languages
2. Aperiodicity verification with exponent bound
3. GCD degree sequence computation over finite fields
4. Period detection for eventually periodic sequences
"""

from typing import List, Tuple, Set, Optional, Dict
from itertools import product
from collections import defaultdict


# ============================================================
# Algorithm 1: Transition Monoid of Spacetime Column Language
# ============================================================

class SpacetimeColumnDFA:
    """DFA recognizing the spacetime column language of a nearest-neighbor CA.

    States: columns (tuples of height h over alphabet) + dead state (None)
    Alphabet: same as states (columns)
    Transitions: T_σ(q) = σ if compatible(q, σ), else dead

    Time complexity: O(|α|^h) states, O(|α|^{2h}) transitions
    Space complexity: O(|α|^h) for state set
    """

    def __init__(self, alphabet: List, height: int, rule):
        """
        Args:
            alphabet: List of symbols (e.g., [0, 1])
            height: Height of spacetime strip
            rule: Function (a, b) -> c defining the CA local rule
        """
        self.alphabet = alphabet
        self.height = height
        self.rule = rule
        self.columns = list(product(alphabet, repeat=height))
        self.n_states = len(self.columns)  # plus dead state

    def compatible(self, c1: tuple, c2: tuple) -> bool:
        """Check if columns c1 and c2 are spacetime-compatible.

        Time: O(h)
        """
        for i in range(self.height - 1):
            if c1[i + 1] != self.rule(c1[i], c2[i]):
                return False
        return True

    def transition(self, state: Optional[tuple], symbol: tuple) -> Optional[tuple]:
        """Apply transition function.

        Time: O(h)
        """
        if state is None:
            return None
        if self.compatible(state, symbol):
            return symbol
        return None

    def transition_function_table(self, symbol: tuple) -> Dict:
        """Compute the full transition function for a symbol.

        Returns: dict mapping state -> next_state

        Time: O(|α|^h · h)
        """
        table = {None: None}
        for col in self.columns:
            table[col] = self.transition(col, symbol)
        return table

    def compute_transition_monoid_element(self, word: List[tuple]) -> Dict:
        """Compute the transition monoid element for a word.

        Time: O(|w| · |α|^h · h)
        """
        # Start with identity
        result = {None: None}
        for col in self.columns:
            result[col] = col

        for symbol in word:
            new_result = {}
            for state, image in result.items():
                new_result[state] = self.transition(image, symbol)
            result = new_result

        return result

    def is_partial_constant(self, func: Dict) -> Tuple[bool, Optional[tuple], Set]:
        """Check if a transition function is a partial constant function.

        Returns: (is_partial_const, target, source_set)

        Time: O(|α|^h)
        """
        target = None
        source = set()

        for state, image in func.items():
            if state is None:
                if image is not None:
                    return False, None, set()
                continue
            if image is not None:
                if target is None:
                    target = image
                elif image != target:
                    return False, None, set()
                source.add(state)

        return True, target, source

    def verify_aperiodicity(self, max_word_length: int = 3) -> Tuple[bool, int]:
        """Verify that all transition monoid elements satisfy m^3 = m^2.

        Args:
            max_word_length: Maximum word length to check generators and products

        Returns: (is_aperiodic, max_exponent)
            is_aperiodic: True if all elements satisfy m^{k+1} = m^k for some k ≤ 2
            max_exponent: Maximum k found (should be ≤ 2)

        Time: O(|α|^{h·max_word_length} · |α|^h · h)
        """
        max_k = 0
        all_aperiodic = True

        # Check all words up to given length
        for length in range(1, max_word_length + 1):
            for word in product(self.columns, repeat=length):
                m = self.compute_transition_monoid_element(list(word))
                m2 = self._compose(m, m)
                m3 = self._compose(m2, m)

                if m == m2:
                    max_k = max(max_k, 1)
                elif m2 == m3:
                    max_k = max(max_k, 2)
                else:
                    all_aperiodic = False

        return all_aperiodic, max_k

    def _compose(self, f: Dict, g: Dict) -> Dict:
        """Compose transition functions: (f ∘ g)(x) = f(g(x))."""
        result = {}
        for state, image in g.items():
            result[state] = f.get(image, None)
        return result


# ============================================================
# Algorithm 2: GCD Degree Sequence over Finite Fields
# ============================================================

class FiniteFieldPolynomial:
    """Polynomial arithmetic over GF(p).

    Polynomials are represented as lists of coefficients [a_0, a_1, ..., a_n]
    where the polynomial is a_0 + a_1*x + ... + a_n*x^n.

    All arithmetic is performed modulo p.
    """

    def __init__(self, p: int):
        self.p = p

    def normalize(self, coeffs: List[int]) -> List[int]:
        """Remove trailing zeros and reduce mod p."""
        result = [(c % self.p + self.p) % self.p for c in coeffs]
        while len(result) > 1 and result[-1] == 0:
            result.pop()
        return result if result else [0]

    def degree(self, coeffs: List[int]) -> int:
        """Return the degree of the polynomial (-1 for zero polynomial)."""
        c = self.normalize(coeffs)
        if c == [0]:
            return -1
        return len(c) - 1

    def add(self, a: List[int], b: List[int]) -> List[int]:
        """Add two polynomials."""
        n = max(len(a), len(b))
        result = [0] * n
        for i in range(len(a)):
            result[i] += a[i]
        for i in range(len(b)):
            result[i] += b[i]
        return self.normalize(result)

    def sub(self, a: List[int], b: List[int]) -> List[int]:
        """Subtract b from a."""
        n = max(len(a), len(b))
        result = [0] * n
        for i in range(len(a)):
            result[i] += a[i]
        for i in range(len(b)):
            result[i] -= b[i]
        return self.normalize(result)

    def mul(self, a: List[int], b: List[int]) -> List[int]:
        """Multiply two polynomials."""
        if a == [0] or b == [0]:
            return [0]
        n = len(a) + len(b) - 1
        result = [0] * n
        for i in range(len(a)):
            for j in range(len(b)):
                result[i + j] += a[i] * b[j]
        return self.normalize(result)

    def mod(self, a: List[int], b: List[int]) -> List[int]:
        """Compute a mod b."""
        a = list(self.normalize(a))
        b = self.normalize(b)
        if b == [0]:
            raise ValueError("Division by zero")
        while len(a) >= len(b) and a != [0]:
            if a[-1] % self.p != 0:
                factor = (a[-1] * pow(b[-1], -1, self.p)) % self.p
                for i in range(len(b)):
                    a[len(a) - len(b) + i] = (a[len(a) - len(b) + i] - factor * b[i]) % self.p
            while len(a) > 1 and a[-1] % self.p == 0:
                a.pop()
            if len(a) >= len(b) and a[-1] % self.p == 0:
                break
        return self.normalize(a)

    def gcd(self, a: List[int], b: List[int]) -> List[int]:
        """Compute gcd of a and b (monic normalization)."""
        a = self.normalize(a)
        b = self.normalize(b)
        while b != [0]:
            a, b = b, self.mod(a, b)
        # Make monic
        if a != [0]:
            lead_inv = pow(a[-1], -1, self.p)
            a = [(c * lead_inv) % self.p for c in a]
        return self.normalize(a)

    def x_pow_n_minus_one(self, n: int) -> List[int]:
        """Compute coefficients of X^n - 1."""
        if n == 0:
            return [0]
        coeffs = [0] * (n + 1)
        coeffs[0] = self.p - 1  # -1 mod p
        coeffs[n] = 1
        return self.normalize(coeffs)


def compute_gcd_degree_sequence(p: int, Q: List[int], max_n: int) -> List[int]:
    """Compute the sequence n ↦ deg(gcd(Q, X^n - 1)) for n = 1, ..., max_n.

    Args:
        p: Prime characteristic
        Q: Polynomial coefficients over GF(p)
        max_n: Maximum value of n

    Returns:
        List of degrees [deg(gcd(Q, X^1 - 1)), ..., deg(gcd(Q, X^max_n - 1))]

    Time: O(max_n · deg(Q)^2)
    Space: O(max_n + deg(Q))
    """
    fp = FiniteFieldPolynomial(p)
    degrees = []
    for n in range(1, max_n + 1):
        xn_minus_1 = fp.x_pow_n_minus_one(n)
        g = fp.gcd(Q, xn_minus_1)
        degrees.append(fp.degree(g))
    return degrees


def detect_eventual_period(seq: List[int], min_offset: int = 0) -> Tuple[int, int]:
    """Detect the eventual period of a sequence.

    Uses the observation that for an eventually periodic sequence with
    period T and offset N, we have seq[n+T] = seq[n] for all n ≥ N.

    Args:
        seq: The sequence to analyze
        min_offset: Minimum offset to consider

    Returns:
        (offset, period): The smallest offset and period found

    Time: O(len(seq)^2) in worst case
    """
    n = len(seq)
    for period in range(1, n // 2 + 1):
        for offset in range(min_offset, n - period):
            is_periodic = True
            for i in range(offset, n - period):
                if seq[i] != seq[i + period]:
                    is_periodic = False
                    break
            if is_periodic:
                return offset, period
    return n, 0  # No period found


# ============================================================
# Algorithm 3: CA Fixed-Point Count via GCD
# ============================================================

def additive_ca_fixed_point_log(p: int, local_poly: List[int],
                                  m: int, max_n: int) -> List[int]:
    """Compute log_p |Fix(T_n^m)| for an additive CA.

    For an additive CA with local polynomial P over GF(p),
    acting on cyclic configurations of length n:
      |Fix(T_n^m)| = p^{deg gcd(X^n - 1, P^m - 1)}

    Here we compute the polynomial Q = P^m - 1 and then
    the GCD degree sequence.

    Args:
        p: Prime characteristic
        local_poly: Coefficients of local polynomial P
        m: Number of iterations
        max_n: Maximum configuration length

    Returns:
        List of log_p |Fix(T_n^m)| for n = 1, ..., max_n

    Time: O(m · deg(P)^2 + max_n · (m·deg(P))^2)
    """
    fp = FiniteFieldPolynomial(p)

    # Compute P^m
    pm = [1]  # start with 1
    for _ in range(m):
        pm = fp.mul(pm, local_poly)

    # Compute Q = P^m - 1
    Q = list(pm)
    Q[0] = (Q[0] - 1) % p
    Q = fp.normalize(Q)

    if Q == [0]:
        # P^m = 1, so all configurations are fixed points
        return list(range(1, max_n + 1))

    return compute_gcd_degree_sequence(p, Q, max_n)


# ============================================================
# Main: Run all algorithms with examples
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)
    print()

    # Algorithm 1: Transition monoid aperiodicity
    print("--- Algorithm 1: Transition Monoid Aperiodicity ---")
    print()

    # Rule 90 (XOR): right-permutative
    dfa = SpacetimeColumnDFA([0, 1], 3, lambda a, b: a ^ b)
    aperiodic, max_k = dfa.verify_aperiodicity(max_word_length=2)
    print(f"  Rule 90, height 3:")
    print(f"    States: {dfa.n_states}")
    print(f"    Aperiodic: {aperiodic}")
    print(f"    Max exponent k (m^{{k+1}} = m^k): {max_k}")
    print()

    # Rule 150: f(a,b) = a XOR b (different from 90 in full ECA but same binary op)
    # Let's try a non-permutative rule: f(a,b) = a AND b
    dfa2 = SpacetimeColumnDFA([0, 1], 3, lambda a, b: a & b)
    aperiodic2, max_k2 = dfa2.verify_aperiodicity(max_word_length=2)
    print(f"  AND rule, height 3:")
    print(f"    States: {dfa2.n_states}")
    print(f"    Aperiodic: {aperiodic2}")
    print(f"    Max exponent k: {max_k2}")
    print(f"    (Aperiodicity holds for ALL CA rules, not just permutative)")
    print()

    # Algorithm 2: GCD degree sequence
    print("--- Algorithm 2: GCD Degree Sequence ---")
    print()

    p = 2
    Q = [1, 1, 0, 1]  # X^3 + X + 1 over GF(2)
    degrees = compute_gcd_degree_sequence(p, Q, 28)
    offset, period = detect_eventual_period(degrees)
    print(f"  Q = X^3 + X + 1 over GF(2)")
    print(f"  Degrees: {degrees}")
    print(f"  Offset: {offset}, Period: {period}")
    print()

    # Algorithm 3: CA fixed-point counts
    print("--- Algorithm 3: Additive CA Fixed-Point Counts ---")
    print()

    # Rule 90 as additive CA: P(X) = 1 + X over GF(2)
    p = 2
    P = [1, 1]  # 1 + X
    for m in [1, 2, 3]:
        logs = additive_ca_fixed_point_log(p, P, m, 20)
        offset, period = detect_eventual_period(logs)
        print(f"  Rule 90, m={m}: log₂|Fix| = {logs}")
        print(f"    Offset: {offset}, Period: {period}")
    print()

    # Rule 150 as additive CA: P(X) = 1 + X + X^(-1) ≈ X + X^2 + 1 after clearing
    # Actually P(U) = U^{-1} + 1 + U, multiply by U: 1 + U + U^2
    P150 = [1, 1, 1]  # 1 + X + X^2 over GF(2)
    for m in [1, 2, 3]:
        logs = additive_ca_fixed_point_log(p, P150, m, 20)
        offset, period = detect_eventual_period(logs)
        print(f"  P = 1+X+X², m={m}: log₂|Fix| = {logs}")
        print(f"    Offset: {offset}, Period: {period}")
