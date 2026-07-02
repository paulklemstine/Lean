"""
Superposition over Non-Archimedean Value Fields: numerical demonstrations.

This self-contained script realizes a non-Archimedean ordered field by finite
truncated epsilon-expansions (finite Laurent-style power series in a positive
infinitesimal `eps`), and demonstrates the paper's core results:

    * Exact normalization        : Born weights sum to 1 in the field.
    * Standard normalization     : observed probabilities sum to 1.
    * Unobservability            : an infinitesimal branch has observed prob. 0.
    * Worked three-branch example: observer sees (1/2, 1/2, 0).
    * Lexicographic collapse     : standard part = projection onto primary layer.
    * Visibility hierarchy       : valuation gives the level a branch first appears.

No third-party dependencies are required.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, List, Sequence, Tuple

# Series are truncated at this many powers of eps (orders 0, 1, ..., ORDER-1).
ORDER: int = 12


@dataclass(frozen=True)
class Eps:
    """A truncated power series c[0] + c[1]*eps + ... + c[ORDER-1]*eps^(ORDER-1).

    `eps` is a positive infinitesimal. We only need nonnegative powers, since
    every element that arises in the framework (squares of limited amplitudes,
    their sums, and appreciable inverses) is limited.
    """

    coeffs: Tuple[float, ...]

    @staticmethod
    def const(x: float) -> "Eps":
        c = [0.0] * ORDER
        c[0] = float(x)
        return Eps(tuple(c))

    @staticmethod
    def monomial(coeff: float, power: int) -> "Eps":
        c = [0.0] * ORDER
        if 0 <= power < ORDER:
            c[power] = float(coeff)
        return Eps(tuple(c))

    def __add__(self, other: "Eps") -> "Eps":
        return Eps(tuple(a + b for a, b in zip(self.coeffs, other.coeffs)))

    def __sub__(self, other: "Eps") -> "Eps":
        return Eps(tuple(a - b for a, b in zip(self.coeffs, other.coeffs)))

    def __mul__(self, other: "Eps") -> "Eps":
        out = [0.0] * ORDER
        for i, a in enumerate(self.coeffs):
            if a == 0.0:
                continue
            for j, b in enumerate(other.coeffs):
                if i + j < ORDER:
                    out[i + j] += a * b
        return Eps(tuple(out))

    def inverse(self) -> "Eps":
        """Series inverse of an *appreciable* element (nonzero order-0 term)."""
        a0 = self.coeffs[0]
        if abs(a0) < 1e-15:
            raise ValueError("cannot invert: element is not appreciable (order-0 term is 0)")
        # Write self = a0 * (1 + u), where u has zero order-0 term; then
        # 1/self = (1/a0) * sum_{k>=0} (-u)^k, truncated at ORDER.
        u = Eps(tuple((c / a0) if i > 0 else 0.0 for i, c in enumerate(self.coeffs)))
        result = Eps.const(1.0)
        term = Eps.const(1.0)
        neg_u = Eps.const(0.0) - u
        for _ in range(1, ORDER):
            term = term * neg_u
            result = result + term
        return result * Eps.const(1.0 / a0)

    def __truediv__(self, other: "Eps") -> "Eps":
        return self * other.inverse()

    # ---- magnitude predicates and the standard part ----

    def valuation(self, tol: float = 1e-12) -> int:
        """Least power of eps with a nonzero coefficient (ORDER if identically 0)."""
        for i, c in enumerate(self.coeffs):
            if abs(c) > tol:
                return i
        return ORDER

    def is_infinitesimal(self, tol: float = 1e-12) -> bool:
        return abs(self.coeffs[0]) <= tol and any(abs(c) > tol for c in self.coeffs[1:])

    def is_appreciable(self, tol: float = 1e-12) -> bool:
        return abs(self.coeffs[0]) > tol

    def standard_part(self) -> float:
        """The unique real number infinitesimally close to a limited element."""
        return self.coeffs[0]

    def __repr__(self) -> str:
        terms: List[str] = []
        for i, c in enumerate(self.coeffs):
            if abs(c) > 1e-12:
                if i == 0:
                    terms.append(f"{c:g}")
                elif i == 1:
                    terms.append(f"{c:g}*eps")
                else:
                    terms.append(f"{c:g}*eps^{i}")
        return " + ".join(terms) if terms else "0"


# A canonical positive infinitesimal.
EPS: Eps = Eps.monomial(1.0, 1)


# --------------------------------------------------------------------------- #
#  Core framework: Born weights, observation functional, its guarantees.
# --------------------------------------------------------------------------- #

def total_weight(amplitudes: Sequence[Eps]) -> Eps:
    """Z = sum_i alpha_i^2 in the value field."""
    z = Eps.const(0.0)
    for a in amplitudes:
        z = z + a * a
    return z


def born_weights(amplitudes: Sequence[Eps]) -> List[Eps]:
    """Exact Born weights w_i = alpha_i^2 / Z (elements of the field)."""
    z = total_weight(amplitudes)
    return [(a * a) / z for a in amplitudes]


def observed_probabilities(amplitudes: Sequence[Eps]) -> List[float]:
    """Observed probabilities p_i = st(w_i); requires an admissible state."""
    return [w.standard_part() for w in born_weights(amplitudes)]


def is_admissible(amplitudes: Sequence[Eps], tol: float = 1e-12) -> bool:
    """All amplitudes limited (always true here) and total weight appreciable."""
    return total_weight(amplitudes).is_appreciable(tol)


def visibility_level(amplitudes: Sequence[Eps], k: int) -> int:
    """Valuation of the k-th Born weight: level at which branch k first appears."""
    return born_weights(amplitudes)[k].valuation()


# --------------------------------------------------------------------------- #
#  Lexicographic probability model.
# --------------------------------------------------------------------------- #

def encode_lexicographic(vectors: Sequence[Sequence[float]]) -> List[Eps]:
    """Encode lexicographic vectors q_i = (q_i^0, q_i^1, ...) as Q_i = sum q_i^l eps^l."""
    encoded: List[Eps] = []
    for q in vectors:
        e = Eps.const(0.0)
        for level, val in enumerate(q):
            e = e + Eps.monomial(val, level)
        encoded.append(e)
    return encoded


def lexicographic_observed(vectors: Sequence[Sequence[float]]) -> List[float]:
    """Observed distribution from a lexicographic system: recovers the primary layer."""
    q = encode_lexicographic(vectors)
    z = Eps.const(0.0)
    for e in q:
        z = z + e
    return [(e / z).standard_part() for e in q]


# --------------------------------------------------------------------------- #
#  Demonstrations.
# --------------------------------------------------------------------------- #

def demo_worked_example() -> None:
    print("=" * 70)
    print("Worked example:  |psi> = (1/sqrt2)|0> + (1/sqrt2)|1> + (1/sqrt2)eps|eps>")
    print("=" * 70)
    inv_sqrt2 = Eps.const(2.0 ** -0.5)
    amps = [inv_sqrt2, inv_sqrt2, inv_sqrt2 * EPS]
    z = total_weight(amps)
    ws = born_weights(amps)
    ps = observed_probabilities(amps)
    print(f"  total weight Z            = {z}")
    print(f"  appreciable?              = {z.is_appreciable()}")
    print(f"  Born weights (exact)      = {[str(w) for w in ws]}")
    print(f"  sum of Born weights       = {sum(ws, Eps.const(0.0))}   (Theorem: exactly 1)")
    print(f"  observed probabilities    = {[round(p, 12) for p in ps]}")
    print(f"  sum of observed probs     = {round(sum(ps), 12)}   (Theorem: exactly 1)")
    print(f"  branch 'eps' amplitude infinitesimal? {amps[2].is_infinitesimal()}")
    print(f"  --> infinitesimal branch observed prob = {round(ps[2], 12)} (unobservable)")
    print()


def demo_unobservability() -> None:
    print("=" * 70)
    print("Unobservability across shrinking infinitesimal branches")
    print("=" * 70)
    for k in range(1, 5):
        # amplitude ~ eps^k on the hidden branch
        amps = [Eps.const(1.0), Eps.monomial(1.0, k)]
        ps = observed_probabilities(amps)
        lvl = visibility_level(amps, 1)
        print(f"  hidden amplitude eps^{k}: observed probs = "
              f"({round(ps[0], 6)}, {round(ps[1], 6)}), "
              f"visibility level of hidden branch = {lvl}")
    print("  (each hidden branch has positive exact weight but observed prob 0)")
    print()


def demo_lexicographic() -> None:
    print("=" * 70)
    print("Lexicographic collapse: standard part = projection onto primary layer")
    print("=" * 70)
    # Three outcomes. Outcome C is possible only at the secondary level.
    vectors = [
        [0.5, 0.0, 0.3],   # A: primary 0.5
        [0.5, 0.0, 0.2],   # B: primary 0.5
        [0.0, 1.0, 0.5],   # C: primary 0, secondary 1  -> invisible
    ]
    obs = lexicographic_observed(vectors)
    print(f"  lexicographic vectors     = {vectors}")
    print(f"  observed distribution     = {[round(p, 12) for p in obs]}")
    print(f"  (recovers primary layer (0.5, 0.5, 0); secondary-only C is invisible)")
    print()


def demo_normalization_random() -> None:
    print("=" * 70)
    print("Standard normalization on assorted admissible states")
    print("=" * 70)
    states = [
        [Eps.const(1.0), Eps.const(2.0), Eps.const(2.0)],
        [Eps.const(1.0), EPS, EPS * EPS],
        [Eps.const(3.0), Eps.const(4.0), EPS * Eps.const(7.0)],
    ]
    for s in states:
        ps = observed_probabilities(s)
        print(f"  amplitudes {[str(a) for a in s]}")
        print(f"     observed = {[round(p, 8) for p in ps]}, sum = {round(sum(ps), 12)}")
    print()


if __name__ == "__main__":
    demo_worked_example()
    demo_unobservability()
    demo_lexicographic()
    demo_normalization_random()
    print("All demonstrations completed.")
