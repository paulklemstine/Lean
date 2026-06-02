#!/usr/bin/env python3
"""
Algorithms for Argumentation Framework Topology

Type-hinted implementations of all algorithms from the research paper.
"""

from itertools import combinations
from typing import Set, FrozenSet, List, Tuple, Dict, Optional
from dataclasses import dataclass, field


@dataclass
class ArgFramework:
    """An argumentation framework AF = (A, R)."""
    arguments: Set[int]
    attacks: Set[Tuple[int, int]]

    def is_attack(self, a: int, b: int) -> bool:
        """Check if a attacks b."""
        return (a, b) in self.attacks

    def attackers_of(self, a: int) -> Set[int]:
        """Return all arguments that attack a."""
        return {b for b in self.arguments if self.is_attack(b, a)}

    def attacked_by(self, a: int) -> Set[int]:
        """Return all arguments attacked by a."""
        return {b for b in self.arguments if self.is_attack(a, b)}


def is_conflict_free(af: ArgFramework, S: FrozenSet[int]) -> bool:
    """Check if S is conflict-free in AF.

    A set S is conflict-free if no argument in S attacks another in S.
    Time complexity: O(|S|^2)
    """
    for a in S:
        for b in S:
            if af.is_attack(a, b):
                return False
    return True


def compute_independence_complex(af: ArgFramework) -> List[FrozenSet[int]]:
    """Compute all conflict-free subsets (the independence complex).

    Returns the list of all conflict-free subsets of A, ordered by size.
    Time complexity: O(2^|A| * |A|^2)
    """
    result: List[FrozenSet[int]] = []
    args_list = sorted(af.arguments)
    n = len(args_list)

    for k in range(n + 1):
        for subset in combinations(args_list, k):
            fs = frozenset(subset)
            if is_conflict_free(af, fs):
                result.append(fs)
    return result


def defends(af: ArgFramework, S: FrozenSet[int], a: int) -> bool:
    """Check if set S defends argument a.

    S defends a if for every attacker b of a, there exists c in S
    such that c attacks b.
    """
    for b in af.attackers_of(a):
        if not any(af.is_attack(c, b) for c in S):
            return False
    return True


def is_admissible(af: ArgFramework, S: FrozenSet[int]) -> bool:
    """Check if S is admissible (conflict-free + self-defending)."""
    if not is_conflict_free(af, S):
        return False
    return all(defends(af, S, a) for a in S)


def characteristic_function(af: ArgFramework, S: FrozenSet[int]) -> FrozenSet[int]:
    """Compute F(S) = {a in A : S defends a}.

    The characteristic function maps a set to all arguments it defends.
    Monotone by Theorem 4.1.
    """
    return frozenset(a for a in af.arguments if defends(af, S, a))


def compute_grounded_extension(af: ArgFramework) -> FrozenSet[int]:
    """Compute the grounded extension via fixed-point iteration.

    Uses the monotonicity of the characteristic function (Theorem 4.1)
    to iterate from the empty set until convergence.

    Converges in at most |A| iterations.
    """
    G: FrozenSet[int] = frozenset()
    for _ in range(len(af.arguments) + 1):
        G_new = characteristic_function(af, G)
        if G_new == G:
            return G
        G = G_new
    return G  # Should never reach here


def compute_preferred_extensions(af: ArgFramework) -> List[FrozenSet[int]]:
    """Compute all preferred extensions (maximal admissible sets)."""
    complex = compute_independence_complex(af)
    admissible_sets = [S for S in complex if is_admissible(af, S)]

    preferred: List[FrozenSet[int]] = []
    for S in admissible_sets:
        if not any(S < T for T in admissible_sets):
            preferred.append(S)
    return preferred


def compute_stable_extensions(af: ArgFramework) -> List[FrozenSet[int]]:
    """Compute all stable extensions.

    A stable extension is conflict-free and attacks every outsider.
    """
    result: List[FrozenSet[int]] = []
    for S in compute_independence_complex(af):
        if not is_conflict_free(af, S):
            continue
        # Check that S attacks every argument not in S
        is_stable = True
        for a in af.arguments:
            if a not in S:
                if not any(af.is_attack(b, a) for b in S):
                    is_stable = False
                    break
        if is_stable:
            result.append(S)
    return result


def compute_complete_extensions(af: ArgFramework) -> List[FrozenSet[int]]:
    """Compute all complete extensions.

    A complete extension is admissible and contains every argument it defends.
    """
    result: List[FrozenSet[int]] = []
    for S in compute_independence_complex(af):
        if not is_admissible(af, S):
            continue
        # Check that S contains every argument it defends
        defended = characteristic_function(af, S)
        if defended <= S:  # S contains all defended arguments
            result.append(S)
    return result


def compute_f_vector(complex: List[FrozenSet[int]], max_dim: int) -> List[int]:
    """Compute the f-vector of the independence complex.

    f_k = number of faces with exactly k+1 elements.
    """
    return [sum(1 for S in complex if len(S) == k + 1) for k in range(max_dim)]


def compute_euler_characteristic(f_vec: List[int]) -> int:
    """Compute the Euler characteristic from the f-vector.

    χ = Σ_k (-1)^k * f_k
    """
    return sum((-1)**k * f_vec[k] for k in range(len(f_vec)))


@dataclass
class FrameworkAnalysis:
    """Complete analysis of an argumentation framework."""
    framework: ArgFramework
    independence_complex: List[FrozenSet[int]]
    preferred_extensions: List[FrozenSet[int]]
    stable_extensions: List[FrozenSet[int]]
    complete_extensions: List[FrozenSet[int]]
    grounded_extension: FrozenSet[int]
    f_vector: List[int]
    euler_characteristic: int

    @property
    def num_faces(self) -> int:
        return len(self.independence_complex)

    @property
    def dimension(self) -> int:
        if not self.independence_complex:
            return -1
        return max(len(S) for S in self.independence_complex) - 1


def analyze_framework(af: ArgFramework) -> FrameworkAnalysis:
    """Perform complete analysis of an argumentation framework."""
    complex = compute_independence_complex(af)
    n = len(af.arguments)
    fv = compute_f_vector(complex, n)
    chi = compute_euler_characteristic(fv)

    return FrameworkAnalysis(
        framework=af,
        independence_complex=complex,
        preferred_extensions=compute_preferred_extensions(af),
        stable_extensions=compute_stable_extensions(af),
        complete_extensions=compute_complete_extensions(af),
        grounded_extension=compute_grounded_extension(af),
        f_vector=fv,
        euler_characteristic=chi,
    )


def verify_hereditary_property(complex: List[FrozenSet[int]]) -> bool:
    """Verify that the complex satisfies the hereditary (downward closure) property.

    For every face F in the complex and every G ⊆ F, G should also be in the complex.
    """
    complex_set = set(complex)
    for F in complex:
        for k in range(len(F)):
            for subset in combinations(F, k):
                if frozenset(subset) not in complex_set:
                    return False
    return True


if __name__ == "__main__":
    # Verify the counterexample
    af = ArgFramework(arguments={0, 1}, attacks={(0, 1)})
    analysis = analyze_framework(af)

    print("Two-argument counterexample analysis:")
    print(f"  Independence complex: {[set(S) for S in analysis.independence_complex]}")
    print(f"  f-vector: {analysis.f_vector}")
    print(f"  Euler characteristic: {analysis.euler_characteristic}")
    print(f"  Preferred extensions: {[set(S) for S in analysis.preferred_extensions]}")
    print(f"  Grounded extension: {set(analysis.grounded_extension)}")
    print(f"  Hereditary property: {verify_hereditary_property(analysis.independence_complex)}")

    conjecture = len(analysis.preferred_extensions) - len(analysis.grounded_extension)
    print(f"\n  Conjecture: χ = |pref| - |grounded| = {conjecture}")
    print(f"  Actual χ = {analysis.euler_characteristic}")
    print(f"  Conjecture {'holds' if conjecture == analysis.euler_characteristic else 'FAILS'}")
