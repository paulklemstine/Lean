#!/usr/bin/env python3
"""
Categorical Deviation Theory — Core Algorithms

Type-hinted implementations of the key structures and algorithms
from categorical deviation theory.
"""

from dataclasses import dataclass
from typing import Callable, Generic, TypeVar, List, Tuple, Optional
import math

T = TypeVar('T')


@dataclass
class MetricQuiver(Generic[T]):
    """A quiver with pseudometric hom-sets.

    Objects are of type T.
    Morphisms between objects are represented as arbitrary values.
    The distance function measures how far apart two morphisms are.
    """
    dist: Callable[[any, any], float]

    def verify_pseudometric(self, samples: List[any]) -> bool:
        """Verify pseudometric axioms on a sample of morphisms."""
        for f in samples:
            if abs(self.dist(f, f)) > 1e-10:
                return False
        for f in samples:
            for g in samples:
                if abs(self.dist(f, g) - self.dist(g, f)) > 1e-10:
                    return False
                if self.dist(f, g) < -1e-10:
                    return False
        for f in samples:
            for g in samples:
                for h in samples:
                    if self.dist(f, h) > self.dist(f, g) + self.dist(g, h) + 1e-10:
                        return False
        return True


@dataclass
class ExpectationQuiver(Generic[T]):
    """A metric quiver with expected morphisms and surprise functional.

    The surprise of a morphism f is dist(f, expected).
    """
    dist: Callable[[any, any], float]
    expected: Callable[[T, T], any]

    def surprise(self, a: T, b: T, f: any) -> float:
        """Compute the surprise of morphism f from a to b."""
        return self.dist(f, self.expected(a, b))

    def surprise_lipschitz_check(self, a: T, b: T, f: any, g: any) -> bool:
        """Verify |σ(f) - σ(g)| ≤ d(f,g)."""
        return abs(self.surprise(a, b, f) - self.surprise(a, b, g)) <= self.dist(f, g) + 1e-10


@dataclass
class ComposableExpectationQuiver(Generic[T]):
    """Full deviation theory structure with composition."""
    dist: Callable[[any, any], float]
    comp: Callable[[any, any], any]
    expected: Callable[[T, T], any]

    def surprise(self, a: T, b: T, f: any) -> float:
        """Surprise of morphism f from a to b."""
        return self.dist(f, self.expected(a, b))

    def coherence_defect(self, a: T, b: T, c: T) -> float:
        """Coherence defect at triple (a,b,c)."""
        composed_expect = self.comp(self.expected(b, c), self.expected(a, b))
        direct_expect = self.expected(a, c)
        return self.dist(composed_expect, direct_expect)

    def is_coherent(self, objects: List[T], tol: float = 1e-10) -> bool:
        """Check if expectations are coherent on given objects."""
        for a in objects:
            for b in objects:
                for c in objects:
                    if self.coherence_defect(a, b, c) > tol:
                        return False
        return True

    def chain_surprise(self, objects: List[T], morphisms: List[any]) -> Tuple[float, float]:
        """Compute composed surprise and individual surprise sum for a chain.

        Returns (composed_surprise, total_individual_surprise).
        """
        assert len(morphisms) == len(objects) - 1

        # Individual surprises
        individual = [
            self.surprise(objects[i], objects[i+1], morphisms[i])
            for i in range(len(morphisms))
        ]
        total_individual = sum(individual)

        # Composed morphism
        composed = morphisms[0]
        for i in range(1, len(morphisms)):
            composed = self.comp(morphisms[i], composed)

        composed_surprise = self.surprise(objects[0], objects[-1], composed)
        return composed_surprise, total_individual


@dataclass
class DeviationMonoid:
    """A monoid with nonexpansive multiplication and deviation from identity."""
    mul: Callable[[any, any], any]
    one: any
    dist: Callable[[any, any], float]

    def deviation(self, a: any) -> float:
        """Deviation of element a from identity."""
        return self.dist(a, self.one)

    def pow(self, a: any, n: int) -> any:
        """Compute a^n by repeated multiplication."""
        result = self.one
        for _ in range(n):
            result = self.mul(a, result)
        return result

    def deviation_pow_data(self, a: any, max_n: int) -> List[Tuple[int, float, float]]:
        """Compute (n, deviation(a^n), n*deviation(a)) for n = 0..max_n.

        Returns list of (n, actual_deviation, bound).
        """
        dev_a = self.deviation(a)
        data = []
        a_n = self.one
        for n in range(max_n + 1):
            dev = self.dist(a_n, self.one)
            data.append((n, dev, n * dev_a))
            a_n = self.mul(a, a_n)
        return data


@dataclass
class GradedDeviationSystem:
    """A metric space with grading that modulates deviation accumulation."""
    dist: Callable[[any, any], float]
    grade: Callable[[any], float]

    def graded_bound(self, a: any, intermediaries: List[any], b: any) -> float:
        """Compute the graded deviation bound from a to b through intermediaries.

        Returns Σ d(consecutive) + Σ grade(intermediary).
        """
        chain = [a] + intermediaries + [b]
        dist_sum = sum(self.dist(chain[i], chain[i+1]) for i in range(len(chain)-1))
        grade_sum = sum(self.grade(x) for x in intermediaries)
        return dist_sum + grade_sum


def build_real_line_quiver() -> ComposableExpectationQuiver:
    """Construct the real line quiver from the paper."""
    return ComposableExpectationQuiver(
        dist=lambda f, g: abs(f - g),
        comp=lambda f, g: f + g,
        expected=lambda a, b: b - a,
    )


def build_matrix_deviation_monoid(dim: int = 2) -> DeviationMonoid:
    """Construct a deviation monoid from dim×dim matrices with Frobenius norm."""
    import numpy as np

    identity = np.eye(dim)

    def mat_mul(A, B):
        return A @ B

    def mat_dist(A, B):
        return float(np.linalg.norm(A - B, 'fro'))

    return DeviationMonoid(
        mul=mat_mul,
        one=identity,
        dist=mat_dist,
    )


def compute_surprise_spectrum(
    quiver: ComposableExpectationQuiver,
    a: any, b: any,
    morphism_samples: List[any]
) -> dict:
    """Compute statistics of the surprise functional over a sample of morphisms."""
    surprises = [quiver.surprise(a, b, f) for f in morphism_samples]
    return {
        "min": min(surprises),
        "max": max(surprises),
        "mean": sum(surprises) / len(surprises),
        "std": (sum((s - sum(surprises)/len(surprises))**2 for s in surprises) / len(surprises)) ** 0.5,
    }


if __name__ == "__main__":
    # Quick self-test
    Q = build_real_line_quiver()
    assert Q.is_coherent([0.0, 1.0, 2.0, 5.0])
    print("Real line quiver: coherent ✓")

    cs, ts = Q.chain_surprise([0, 3, 7, 10], [4, 3, 2])
    print(f"Chain: composed_surprise={cs:.2f}, total_individual={ts:.2f}")
    assert cs <= ts + 1e-10
    print("Chain bound verified ✓")

    # Surprise spectrum
    import random
    random.seed(42)
    morphisms = [random.gauss(5, 2) for _ in range(1000)]
    spectrum = compute_surprise_spectrum(Q, 0.0, 5.0, morphisms)
    print(f"Surprise spectrum (0→5): min={spectrum['min']:.3f}, max={spectrum['max']:.3f}, "
          f"mean={spectrum['mean']:.3f}, std={spectrum['std']:.3f}")
