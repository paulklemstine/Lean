"""
algorithms.py — Algorithms for Cognitive Braid Analysis

Implements algorithms for computing braid invariants, Jones polynomial
approximations, and cognitive complexity measures.
"""

from typing import List, Dict, Tuple, Optional
import math


# ─── Core Data Structures ─────────────────────────────────────────────────

class BraidGenerator:
    """
    A generator σ_i^ε of the braid group B_n.

    Args:
        index: The strand index i (0-indexed).
        sign: +1 for σ_i, -1 for σ_i⁻¹.
    """
    def __init__(self, index: int, sign: int = 1):
        assert sign in (1, -1), "Sign must be +1 or -1"
        self.index = index
        self.sign = sign

    def inverse(self) -> 'BraidGenerator':
        """Return the inverse generator."""
        return BraidGenerator(self.index, -self.sign)

    def __repr__(self) -> str:
        sup = "" if self.sign == 1 else "⁻¹"
        return f"σ{sup}_{self.index}"

    def __eq__(self, other) -> bool:
        return self.index == other.index and self.sign == other.sign

    def __hash__(self) -> int:
        return hash((self.index, self.sign))


class BraidWord:
    """
    A word in the braid group B_n.

    Represents a cognitive process as a sequence of neural strand crossings.

    Attributes:
        n_strands: Number of strands (brain regions).
        generators: List of braid generators.

    Time complexity:
        - Construction: O(k) where k is the word length.
        - Composition: O(k₁ + k₂).
        - Writhe computation: O(k).
        - Inversion: O(k).
    """
    def __init__(self, n_strands: int, generators: List[BraidGenerator] = None):
        assert n_strands >= 1, "Need at least 1 strand"
        self.n_strands = n_strands
        self.generators = generators or []
        # Validate strand indices
        for g in self.generators:
            assert 0 <= g.index < n_strands - 1, \
                f"Generator index {g.index} out of range for {n_strands} strands"

    def compose(self, other: 'BraidWord') -> 'BraidWord':
        """
        Compose two braid words (concatenation).

        Time: O(k₁ + k₂)
        Space: O(k₁ + k₂)
        """
        assert self.n_strands == other.n_strands
        return BraidWord(self.n_strands, self.generators + other.generators)

    def inverse(self) -> 'BraidWord':
        """
        Compute the inverse braid word.

        Algorithm: Reverse the list and invert each generator.
        Time: O(k)
        Space: O(k)
        """
        return BraidWord(
            self.n_strands,
            [g.inverse() for g in reversed(self.generators)]
        )

    @property
    def writhe(self) -> int:
        """
        Compute the writhe (algebraic crossing number).

        The writhe is the sum of signs of all crossings.
        It is a braid word invariant (not a knot invariant without
        normalization by the Kauffman bracket).

        Time: O(k)
        Space: O(1)

        Returns:
            Integer writhe value.
        """
        return sum(g.sign for g in self.generators)

    @property
    def crossing_number(self) -> int:
        """Total number of crossings. Time: O(1)."""
        return len(self.generators)

    @property
    def info_content(self) -> int:
        """
        Information content: |writhe|.

        Measures the "net signal" of the cognitive process.
        Bounded above by crossing_number (proved in Lean).

        Time: O(k)
        """
        return abs(self.writhe)

    def strand_usage(self) -> Dict[int, int]:
        """
        Count how many times each strand is involved in crossings.

        Returns:
            Dict mapping strand index to crossing count.

        Time: O(k)
        """
        usage: Dict[int, int] = {}
        for g in self.generators:
            usage[g.index] = usage.get(g.index, 0) + 1
        return usage

    def cognitive_level(self) -> str:
        """
        Classify the cognitive complexity level.

        Based on crossing number thresholds (proved monotone in Lean):
        - 0 crossings: trivial (linear thought)
        - 1-2 crossings: simple (basic association)
        - 3-5 crossings: moderate (reasoning)
        - 6+ crossings: complex (creative insight)

        Time: O(1)
        """
        k = self.crossing_number
        if k == 0:
            return "trivial"
        elif k <= 2:
            return "simple"
        elif k <= 5:
            return "moderate"
        else:
            return "complex"

    def __repr__(self) -> str:
        if not self.generators:
            return f"e ∈ B_{self.n_strands}"
        gens = " · ".join(str(g) for g in self.generators)
        return f"({gens}) ∈ B_{self.n_strands}"


# ─── Kauffman Bracket Polynomial ──────────────────────────────────────────

class LaurentPoly:
    """
    A Laurent polynomial in one variable with integer coefficients.

    Represented as a dict mapping exponent -> coefficient.
    Used for computing the Kauffman bracket and Jones polynomial.

    Time complexity for operations:
        - Addition: O(max(|p|, |q|))
        - Multiplication: O(|p| * |q|)
    """
    def __init__(self, coeffs: Dict[int, int] = None):
        self.coeffs = {}
        if coeffs:
            for k, v in coeffs.items():
                if v != 0:
                    self.coeffs[k] = v

    @staticmethod
    def monomial(exp: int, coeff: int = 1) -> 'LaurentPoly':
        """Create a monomial c * t^exp."""
        if coeff == 0:
            return LaurentPoly()
        return LaurentPoly({exp: coeff})

    def __add__(self, other: 'LaurentPoly') -> 'LaurentPoly':
        result = dict(self.coeffs)
        for k, v in other.coeffs.items():
            result[k] = result.get(k, 0) + v
        return LaurentPoly(result)

    def __sub__(self, other: 'LaurentPoly') -> 'LaurentPoly':
        result = dict(self.coeffs)
        for k, v in other.coeffs.items():
            result[k] = result.get(k, 0) - v
        return LaurentPoly(result)

    def __mul__(self, other: 'LaurentPoly') -> 'LaurentPoly':
        result: Dict[int, int] = {}
        for e1, c1 in self.coeffs.items():
            for e2, c2 in other.coeffs.items():
                e = e1 + e2
                result[e] = result.get(e, 0) + c1 * c2
        return LaurentPoly(result)

    def scale(self, c: int) -> 'LaurentPoly':
        """Multiply by an integer scalar."""
        return LaurentPoly({k: v * c for k, v in self.coeffs.items()})

    def evaluate(self, t: complex) -> complex:
        """Evaluate the polynomial at a complex number t."""
        return sum(c * t**e for e, c in self.coeffs.items())

    def __repr__(self) -> str:
        if not self.coeffs:
            return "0"
        terms = []
        for e in sorted(self.coeffs.keys()):
            c = self.coeffs[e]
            if c == 0:
                continue
            if e == 0:
                terms.append(str(c))
            elif e == 1:
                terms.append(f"{c}t" if c != 1 else "t")
            elif e == -1:
                terms.append(f"{c}t⁻¹" if c != 1 else "t⁻¹")
            else:
                terms.append(f"{c}·t^{e}" if c != 1 else f"t^{e}")
        return " + ".join(terms) if terms else "0"


def jones_polynomial_of_writhe(writhe: int) -> LaurentPoly:
    """
    Approximate Jones polynomial based on writhe.

    For a braid with writhe w, the Jones polynomial contribution from
    the writhe factor is (-t)^(-3w). This is the "framing correction"
    in the Kauffman bracket approach.

    This is a simplified model; the full Jones polynomial requires
    resolving all crossings via the Kauffman bracket skein relation.

    Time: O(1)
    Space: O(1)
    """
    # (-1)^(-3w) * t^(-3w)
    sign = (-1) ** (-3 * writhe)
    return LaurentPoly.monomial(-3 * writhe, sign)


def quantum_dimension(writhe: int) -> float:
    """
    Compute the quantum dimension of a cognitive braid.

    Defined as log(|V(e^{2πi/3})|) where V is the Jones polynomial.
    For our simplified model, this reduces to log(|(-e^{2πi/3})^{-3w}|).
    Since |e^{2πi/3}| = 1, this is always 0 for the writhe factor alone.

    For more realistic computation, we use the crossing number as a proxy.

    Time: O(1)
    """
    # The true quantum dimension involves the full Jones polynomial
    # For the writhe-based approximation:
    if writhe == 0:
        return 0.0
    return math.log(abs(writhe) + 1)


# ─── Canonical Cognitive Braids ───────────────────────────────────────────

def canonical_braids(n: int = 3) -> Dict[str, BraidWord]:
    """
    Return a dictionary of canonical cognitive braids.

    Args:
        n: Number of strands (brain regions). Must be ≥ 3.

    Returns:
        Dict mapping descriptive names to BraidWord instances.
    """
    return {
        "identity (no thought)": BraidWord(n),
        "simple association": BraidWord(n, [BraidGenerator(0)]),
        "Hopf link (paired thought)": BraidWord(n, [
            BraidGenerator(0), BraidGenerator(0)
        ]),
        "trefoil (creative insight)": BraidWord(n, [
            BraidGenerator(0), BraidGenerator(0), BraidGenerator(0)
        ]),
        "figure-eight (confused thinking)": BraidWord(n, [
            BraidGenerator(0, 1), BraidGenerator(1, -1),
            BraidGenerator(0, 1), BraidGenerator(1, -1)
        ]),
        "full twist (deep focus)": BraidWord(n, [
            BraidGenerator(0), BraidGenerator(1),
            BraidGenerator(0), BraidGenerator(1),
            BraidGenerator(0), BraidGenerator(1)
        ]),
    }


# ─── Analysis Functions ──────────────────────────────────────────────────

def analyze_braid(name: str, braid: BraidWord) -> Dict:
    """
    Compute all invariants and measures for a cognitive braid.

    Args:
        name: Descriptive name.
        braid: The BraidWord to analyze.

    Returns:
        Dict with all computed measures.
    """
    w = braid.writhe
    cn = braid.crossing_number
    info = braid.info_content
    level = braid.cognitive_level()
    qdim = quantum_dimension(w)
    jones = jones_polynomial_of_writhe(w)

    return {
        "name": name,
        "n_strands": braid.n_strands,
        "word": str(braid),
        "writhe": w,
        "crossing_number": cn,
        "info_content": info,
        "cognitive_level": level,
        "quantum_dimension": round(qdim, 4),
        "jones_writhe_factor": str(jones),
        "info_le_complexity": info <= cn,  # Verified theorem
    }


if __name__ == "__main__":
    print("=" * 70)
    print("COGNITIVE BRAID ANALYSIS")
    print("=" * 70)

    braids = canonical_braids(3)
    for name, braid in braids.items():
        result = analyze_braid(name, braid)
        print(f"\n{'─' * 50}")
        print(f"  Name: {result['name']}")
        print(f"  Braid: {result['word']}")
        print(f"  Writhe: {result['writhe']}")
        print(f"  Crossings: {result['crossing_number']}")
        print(f"  Info Content: {result['info_content']}")
        print(f"  Level: {result['cognitive_level']}")
        print(f"  Quantum Dim: {result['quantum_dimension']}")
        print(f"  Jones factor: {result['jones_writhe_factor']}")
        print(f"  info ≤ complexity: {result['info_le_complexity']}")
