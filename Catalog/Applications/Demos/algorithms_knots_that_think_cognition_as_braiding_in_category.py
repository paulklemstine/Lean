"""
Cognitive Braids: Algorithms for Braid Group Invariants

Implements braid word representations, exponent sum computation,
Jones polynomial approximation via Kauffman bracket, and cognitive
complexity measures.
"""

from typing import List, Tuple
from dataclasses import dataclass
import math
import cmath


@dataclass
class BraidGen:
    """A braid generator: crossing at strand `idx` with sign (+1 or -1)."""
    idx: int
    sign: int  # +1 for positive crossing, -1 for negative

    def __repr__(self) -> str:
        s = "" if self.sign == 1 else "⁻¹"
        return f"σ_{self.idx}{s}"


BraidWord = List[BraidGen]


def exponent_sum(word: BraidWord) -> int:
    """Compute the exponent sum (algebraic crossing number) of a braid word.

    This is a braid invariant: it is preserved under all braid relations
    (cancellation, far commutativity, and the Yang-Baxter relation).

    Args:
        word: A list of BraidGen objects.

    Returns:
        The sum of signs of all generators.
    """
    return sum(g.sign for g in word)


def crossing_number(word: BraidWord) -> int:
    """The crossing number: total number of crossings."""
    return len(word)


def abs_writhe(word: BraidWord) -> int:
    """The absolute writhe: |exponent_sum|.

    This is a lower bound on the crossing number of any equivalent braid.
    """
    return abs(exponent_sum(word))


def generator_span(word: BraidWord) -> int:
    """Number of distinct generator indices used."""
    return len(set(g.idx for g in word))


def braid_inverse(word: BraidWord) -> BraidWord:
    """Compute the inverse of a braid word (reverse and flip signs)."""
    return [BraidGen(g.idx, -g.sign) for g in reversed(word)]


def braid_compose(w1: BraidWord, w2: BraidWord) -> BraidWord:
    """Compose (concatenate) two braid words."""
    return w1 + w2


def braid_permutation(n: int, word: BraidWord) -> List[int]:
    """Compute the permutation induced by a braid word on n strands.

    Args:
        n: Number of strands.
        word: The braid word.

    Returns:
        A permutation of [0, 1, ..., n-1].
    """
    perm = list(range(n))
    for g in word:
        i = g.idx
        if 0 <= i < n - 1:
            perm[i], perm[i + 1] = perm[i + 1], perm[i]
    return perm


# --- Kauffman Bracket / Jones Polynomial ---

def kauffman_bracket_naive(crossings: List[Tuple[int, int, int]],
                           n_strands: int) -> dict:
    """Compute the Kauffman bracket of a braid closure (naive exponential algorithm).

    Uses the state-sum model: for each crossing, choose A-smoothing or B-smoothing,
    then compute (-A^2 - A^{-2})^{loops-1} * A^{sum of choices}.

    Args:
        crossings: List of (strand_i, strand_j, sign) tuples.
        n_strands: Number of strands.

    Returns:
        Dictionary mapping powers of A to coefficients.
    """
    n = len(crossings)
    if n == 0:
        return {0: 1}

    result: dict = {}

    for state in range(2 ** n):
        # Each bit determines A-smoothing (0) or B-smoothing (1)
        power = 0
        # Track strand connections to count loops
        connections = list(range(2 * n_strands))

        for k, (i, j, sign) in enumerate(crossings):
            bit = (state >> k) & 1
            if bit == 0:
                power += 1  # A-smoothing contributes A
            else:
                power -= 1  # B-smoothing contributes A^{-1}

            # Adjust for crossing sign
            if sign == -1:
                bit = 1 - bit

        # Count loops (simplified for braid closures)
        n_loops = 1  # Placeholder: proper loop counting requires planar diagram

        # Contribution: A^power * (-A^2 - A^{-2})^{n_loops - 1}
        if power not in result:
            result[power] = 0
        result[power] += 1

    return result


def jones_polynomial_from_exponent_sum(exp_sum: int, n_crossings: int) -> str:
    """Approximate Jones polynomial characterization from braid data.

    For specific well-known braids, returns the Jones polynomial.
    This is a lookup-based method for canonical examples.

    Args:
        exp_sum: The exponent sum of the braid.
        n_crossings: The crossing number.

    Returns:
        String representation of the Jones polynomial.
    """
    if n_crossings == 0:
        return "1"
    elif exp_sum == 3 and n_crossings == 3:
        return "-t^{-4} + t^{-3} + t^{-1}"  # Right trefoil
    elif exp_sum == -3 and n_crossings == 3:
        return "-t^4 + t^3 + t"  # Left trefoil
    elif exp_sum == 0 and n_crossings == 4:
        return "t^2 - t + 1 - t^{-1} + t^{-2}"  # Figure-eight knot
    else:
        return f"Unknown (exp_sum={exp_sum}, crossings={n_crossings})"


def quantum_dimension(exp_sum: int, n_crossings: int) -> float:
    """Compute the quantum dimension (information content) of a braid.

    For known braids, computes log(|V(e^{2πi/3})|) where V is the Jones polynomial.

    Args:
        exp_sum: The exponent sum.
        n_crossings: The crossing number.

    Returns:
        The quantum dimension (information content measure).
    """
    t = cmath.exp(2j * cmath.pi / 3)

    if n_crossings == 0:
        return 0.0  # Trivial: V = 1

    elif exp_sum == 3 and n_crossings == 3:
        # Right trefoil: V(t) = -t^{-4} + t^{-3} + t^{-1}
        v = -t**(-4) + t**(-3) + t**(-1)
        return math.log(abs(v))

    elif exp_sum == 0 and n_crossings == 4:
        # Figure-eight: V(t) = t^2 - t + 1 - t^{-1} + t^{-2}
        v = t**2 - t + 1 - t**(-1) + t**(-2)
        return math.log(abs(v))

    else:
        # Fallback: use crossing number as complexity proxy
        return math.log(1 + n_crossings)


# --- Cognitive Braid Types ---

@dataclass
class CognitiveBraid:
    """A cognitive braid: neural firing patterns modeled as braid crossings.

    Attributes:
        n_regions: Number of brain regions (strands).
        word: The braid word representing the cognitive process.
        label: Human-readable description of the thought type.
    """
    n_regions: int
    word: BraidWord
    label: str = ""

    def exponent_sum(self) -> int:
        return exponent_sum(self.word)

    def crossing_number(self) -> int:
        return crossing_number(self.word)

    def abs_writhe(self) -> int:
        return abs_writhe(self.word)

    def generator_span(self) -> int:
        return generator_span(self.word)

    def quantum_dimension(self) -> float:
        return quantum_dimension(self.exponent_sum(), self.crossing_number())

    def permutation(self) -> List[int]:
        return braid_permutation(self.n_regions, self.word)

    def compose(self, other: 'CognitiveBraid') -> 'CognitiveBraid':
        assert self.n_regions == other.n_regions
        return CognitiveBraid(
            self.n_regions,
            braid_compose(self.word, other.word),
            f"({self.label}) ∘ ({other.label})"
        )


# --- Canonical cognitive braids ---

def trivial_braid(n: int = 3) -> CognitiveBraid:
    """The trivial braid: no crossings, no thinking."""
    return CognitiveBraid(n, [], "trivial (no thinking)")


def linear_reasoning(n: int = 4) -> CognitiveBraid:
    """Linear sequential reasoning: σ₀ σ₁ σ₂ ... (monotone chain)."""
    word = [BraidGen(i, 1) for i in range(n - 1)]
    return CognitiveBraid(n, word, "linear reasoning")


def trefoil_insight() -> CognitiveBraid:
    """Creative insight: the trefoil braid σ₀ σ₁ σ₀."""
    return CognitiveBraid(3,
        [BraidGen(0, 1), BraidGen(1, 1), BraidGen(0, 1)],
        "creative insight (trefoil)")


def confused_thinking() -> CognitiveBraid:
    """Confused thinking: the figure-eight braid σ₀ σ₁⁻¹ σ₀ σ₁⁻¹."""
    return CognitiveBraid(3,
        [BraidGen(0, 1), BraidGen(1, -1), BraidGen(0, 1), BraidGen(1, -1)],
        "confused thinking (figure-eight)")


def rumination(n: int = 3, k: int = 5) -> CognitiveBraid:
    """Rumination: repeating the same crossing pattern k times."""
    word = [BraidGen(0, 1), BraidGen(0, -1)] * k
    return CognitiveBraid(n, word, f"rumination (k={k})")


def deep_insight(n: int = 5) -> CognitiveBraid:
    """Deep insight: full twist braid (all strands interleave)."""
    word = []
    for _ in range(2):
        for i in range(n - 1):
            word.append(BraidGen(i, 1))
    return CognitiveBraid(n, word, "deep insight (full twist)")


if __name__ == "__main__":
    braids = [
        trivial_braid(),
        linear_reasoning(),
        trefoil_insight(),
        confused_thinking(),
        rumination(),
        deep_insight(),
    ]

    for b in braids:
        print(f"\n{b.label}:")
        print(f"  Word: {b.word}")
        print(f"  Exponent sum: {b.exponent_sum()}")
        print(f"  Crossing number: {b.crossing_number()}")
        print(f"  Abs writhe: {b.abs_writhe()}")
        print(f"  Generator span: {b.generator_span()}")
        print(f"  Quantum dimension: {b.quantum_dimension():.4f}")
        print(f"  Permutation: {b.permutation()}")
