#!/usr/bin/env python3
"""Numerical demonstrations of complexity transfer and Landauer work bounds.

The examples use only Python's standard library.  They illustrate finite reduction
closure, one-bit erasure non-injectivity, exact construction of a two-trajectory
Jarzynski ensemble, and linear Landauer scaling with temperature and bit count.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from math import exp, isclose, log
from typing import Iterable, Mapping, Sequence

BOLTZMANN_J_PER_K = 1.380649e-23


def landauer_bound(bits: int, temperature_k: float,
                    boltzmann: float = BOLTZMANN_J_PER_K) -> float:
    """Return N k T ln(2) joules for N unbiased erased bits."""
    if bits < 0:
        raise ValueError("bits must be nonnegative")
    if temperature_k <= 0.0 or boltzmann <= 0.0:
        raise ValueError("temperature and Boltzmann constant must be positive")
    return bits * boltzmann * temperature_k * log(2.0)


def erasure(bit: int) -> int:
    """Reset a bit to zero."""
    if bit not in (0, 1):
        raise ValueError("input must be 0 or 1")
    return 0


def is_injective_on_bits() -> bool:
    """Check injectivity of reset on the two-element bit space."""
    return len({erasure(0), erasure(1)}) == 2


@dataclass(frozen=True)
class JarzynskiReport:
    probability_sum: float
    exponential_average: float
    target_exponential: float
    expected_work: float
    free_energy: float
    equality_holds: bool
    mean_bound_holds: bool


def jarzynski_audit(probabilities: Sequence[float], works: Sequence[float],
                     k_t: float, free_energy: float,
                     tolerance: float = 1e-12) -> JarzynskiReport:
    """Audit normalization, the finite Jarzynski equality, and the mean bound."""
    if len(probabilities) != len(works) or not probabilities:
        raise ValueError("probabilities and works must have equal nonzero length")
    if k_t <= 0.0:
        raise ValueError("kT must be positive")
    if any(p < 0.0 for p in probabilities):
        raise ValueError("probabilities must be nonnegative")
    total = sum(probabilities)
    if not isclose(total, 1.0, rel_tol=tolerance, abs_tol=tolerance):
        raise ValueError("probabilities must sum to one")
    exponential_average = sum(
        p * exp(-work / k_t) for p, work in zip(probabilities, works)
    )
    target = exp(-free_energy / k_t)
    expected = sum(p * work for p, work in zip(probabilities, works))
    return JarzynskiReport(
        total, exponential_average, target, expected, free_energy,
        isclose(exponential_average, target,
                rel_tol=tolerance, abs_tol=tolerance),
        expected + tolerance >= free_energy,
    )


def two_trajectory_ensemble(lower_work: float, probability: float = 0.5,
                            k_t: float = 1.0) -> tuple[list[float], list[float]]:
    """Construct a two-path ensemble satisfying one-bit Jarzynski equality.

    The free energy is kT ln(2).  The second work value is solved from the
    equality after the first work and its probability are chosen.
    """
    if not (0.0 < probability < 1.0) or k_t <= 0.0:
        raise ValueError("probability must be in (0,1) and kT must be positive")
    target = 0.5  # exp(-ln 2)
    remainder = (target - probability * exp(-lower_work / k_t)) / (1.0 - probability)
    if not (0.0 < remainder):
        raise ValueError("chosen lower work leaves no positive second weight")
    upper_work = -k_t * log(remainder)
    return [probability, 1.0 - probability], [lower_work, upper_work]


def reduction_closure(reduces_to: Mapping[str, Iterable[str]],
                      known_easy: Iterable[str]) -> set[str]:
    """Propagate easy status backward through a finite reduction graph.

    If A maps to B, then A reduces to B.  Thus A is marked easy whenever B is.
    Runtime is O(V+E) after construction of reverse adjacency lists.
    """
    predecessors: dict[str, set[str]] = {}
    vertices: set[str] = set(known_easy)
    for source, targets in reduces_to.items():
        vertices.add(source)
        for target in targets:
            vertices.add(target)
            predecessors.setdefault(target, set()).add(source)
    easy = set(known_easy)
    queue: deque[str] = deque(easy)
    while queue:
        target = queue.popleft()
        for source in predecessors.get(target, ()):
            if source not in easy:
                easy.add(source)
                queue.append(source)
    return easy & vertices


def main() -> None:
    print("COMPLEXITY–THERMODYNAMICS NUMERICAL DEMONSTRATION")
    print("=" * 62)

    graph = {
        "Demon scheduling": ["Hard target"],
        "Molecular partition": ["Hard target"],
        "Auxiliary verifier": ["Demon scheduling"],
    }
    propagated = reduction_closure(graph, {"Hard target"})
    print("\n1. Reduction closure from an easy hard target")
    for problem in sorted(propagated):
        print(f"   polynomial status transfers to: {problem}")

    print("\n2. Logical reset")
    print(f"   e(0)={erasure(0)}, e(1)={erasure(1)}")
    print(f"   injective on bits? {is_injective_on_bits()}")

    probabilities, works = two_trajectory_ensemble(lower_work=0.2)
    delta_f = log(2.0)  # dimensionless units with kT=1
    report = jarzynski_audit(probabilities, works, 1.0, delta_f)
    print("\n3. Fluctuating two-trajectory ensemble in units kT=1")
    print(f"   probabilities: {probabilities}")
    print(f"   works: {[round(w, 8) for w in works]}")
    print(f"   exponential average: {report.exponential_average:.12f}")
    print(f"   Jarzynski target:    {report.target_exponential:.12f}")
    print(f"   expected work:       {report.expected_work:.12f}")
    print(f"   Landauer scale:      {report.free_energy:.12f}")
    print(f"   equality holds? {report.equality_holds}")
    print(f"   mean bound holds? {report.mean_bound_holds}")

    print("\n4. Landauer scaling at 300 K")
    for bits in (1, 1_000, 1_000_000, 1_000_000_000):
        bound = landauer_bound(bits, 300.0)
        print(f"   {bits:>12,d} bits: {bound:.6e} J")


if __name__ == "__main__":
    main()
