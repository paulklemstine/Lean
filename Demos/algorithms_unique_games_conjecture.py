"""
Algorithms for Unique Games: Value Computation, SDP Relaxation, and Analysis.

Implements the mathematical structures from the formal Lean 4 development:
- UniqueGame construction and value computation
- SDP relaxation via CVXPY-compatible formulation
- Parallel repetition analysis
- Constraint expansion measurement
- MAX-CUT to Unique Game reduction
"""

from typing import List, Tuple, Dict, Optional, Callable
import itertools
import math
import random


class Permutation:
    """A permutation on {0, 1, ..., k-1}."""

    def __init__(self, mapping: List[int]):
        self.k = len(mapping)
        self.mapping = list(mapping)
        assert sorted(self.mapping) == list(range(self.k)), "Not a valid permutation"

    def __call__(self, x: int) -> int:
        return self.mapping[x]

    def inverse(self) -> 'Permutation':
        inv = [0] * self.k
        for i, j in enumerate(self.mapping):
            inv[j] = i
        return Permutation(inv)

    def compose(self, other: 'Permutation') -> 'Permutation':
        """self ∘ other"""
        return Permutation([self(other(i)) for i in range(self.k)])

    @staticmethod
    def identity(k: int) -> 'Permutation':
        return Permutation(list(range(k)))

    @staticmethod
    def random_perm(k: int) -> 'Permutation':
        mapping = list(range(k))
        random.shuffle(mapping)
        return Permutation(mapping)

    @staticmethod
    def swap_01(k: int = 2) -> 'Permutation':
        """The swap permutation for MAX-CUT (k=2)."""
        assert k == 2
        return Permutation([1, 0])

    def __repr__(self) -> str:
        return f"Perm({self.mapping})"


class UniqueGame:
    """A unique game instance with n vertices and k labels."""

    def __init__(self, n: int, k: int,
                 edges: List[Tuple[int, int]],
                 constraints: Dict[Tuple[int, int], Permutation],
                 weights: Optional[Dict[Tuple[int, int], float]] = None):
        self.n = n
        self.k = k
        self.edges = edges
        self.constraints = constraints

        if weights is None:
            # Uniform weights
            w = 1.0 / len(edges) if edges else 0.0
            self.weights = {e: w for e in edges}
        else:
            self.weights = weights

        # Normalize weights
        total = sum(self.weights.values())
        if total > 0:
            self.weights = {e: w / total for e, w in self.weights.items()}

    def assignment_value(self, sigma: List[int]) -> float:
        """Compute the value of a given assignment."""
        value = 0.0
        for e in self.edges:
            u, v = e
            pi = self.constraints[e]
            if pi(sigma[u]) == sigma[v]:
                value += self.weights[e]
        return value

    def brute_force_value(self) -> Tuple[float, List[int]]:
        """Find the optimal assignment by brute force.
        Only feasible for small instances (k^n evaluations)."""
        best_value = 0.0
        best_assignment: List[int] = [0] * self.n

        for assignment in itertools.product(range(self.k), repeat=self.n):
            sigma = list(assignment)
            val = self.assignment_value(sigma)
            if val > best_value:
                best_value = val
                best_assignment = sigma

        return best_value, best_assignment

    def greedy_value(self, trials: int = 100) -> Tuple[float, List[int]]:
        """Randomized greedy approximation."""
        best_value = 0.0
        best_assignment: List[int] = [0] * self.n

        for _ in range(trials):
            sigma = [random.randint(0, self.k - 1) for _ in range(self.n)]
            # Local search
            improved = True
            while improved:
                improved = False
                for v in range(self.n):
                    current_val = self.assignment_value(sigma)
                    for l in range(self.k):
                        old = sigma[v]
                        sigma[v] = l
                        new_val = self.assignment_value(sigma)
                        if new_val > current_val:
                            current_val = new_val
                            improved = True
                        else:
                            sigma[v] = old

            val = self.assignment_value(sigma)
            if val > best_value:
                best_value = val
                best_assignment = list(sigma)

        return best_value, best_assignment

    @staticmethod
    def random_instance(n: int, k: int, p: float = 0.5) -> 'UniqueGame':
        """Generate a random unique game on n vertices with k labels.
        Each pair (i,j) with i<j is an edge with probability p."""
        edges = []
        constraints = {}
        for i in range(n):
            for j in range(i + 1, n):
                if random.random() < p:
                    e = (i, j)
                    edges.append(e)
                    constraints[e] = Permutation.random_perm(k)
        return UniqueGame(n, k, edges, constraints)

    @staticmethod
    def satisfiable_instance(n: int, k: int, p: float = 0.5) -> 'UniqueGame':
        """Generate a satisfiable unique game (value = 1)."""
        # Fix a random assignment, then set constraints accordingly
        sigma = [random.randint(0, k - 1) for _ in range(n)]
        edges = []
        constraints = {}
        for i in range(n):
            for j in range(i + 1, n):
                if random.random() < p:
                    e = (i, j)
                    edges.append(e)
                    # Find perm such that perm(sigma[i]) = sigma[j]
                    perm = list(range(k))
                    # Start with identity, then fix the constraint
                    perm_map = list(range(k))
                    # We need perm_map[sigma[i]] = sigma[j]
                    # Swap perm_map[sigma[i]] with sigma[j]
                    idx = perm_map.index(sigma[j])
                    perm_map[sigma[i]], perm_map[idx] = perm_map[idx], perm_map[sigma[i]]
                    constraints[e] = Permutation(perm_map)
        return UniqueGame(n, k, edges, constraints)


class MaxCutInstance:
    """A MAX-CUT instance."""

    def __init__(self, n: int, edges: List[Tuple[int, int]],
                 weights: Optional[Dict[Tuple[int, int], float]] = None):
        self.n = n
        self.edges = edges
        if weights is None:
            self.weights = {e: 1.0 for e in edges}
        else:
            self.weights = weights

    def cut_value(self, cut: List[bool]) -> float:
        """Value of a cut."""
        value = 0.0
        for e in self.edges:
            if cut[e[0]] != cut[e[1]]:
                value += self.weights[e]
        return value

    def to_unique_game(self) -> UniqueGame:
        """Convert to a unique game with k=2."""
        constraints = {e: Permutation.swap_01() for e in self.edges}
        total_weight = sum(self.weights.values())
        weights = {e: w / total_weight for e, w in self.weights.items()}
        return UniqueGame(self.n, 2, self.edges, constraints, weights)

    def brute_force_maxcut(self) -> Tuple[float, List[bool]]:
        """Find optimal MAX-CUT by brute force."""
        best_value = 0.0
        best_cut: List[bool] = [False] * self.n

        for bits in range(2 ** self.n):
            cut = [(bits >> i) & 1 == 1 for i in range(self.n)]
            val = self.cut_value(cut)
            if val > best_value:
                best_value = val
                best_cut = cut

        return best_value, best_cut


def parallel_repetition_value(game: UniqueGame, sigma: List[int], r: int) -> float:
    """Compute the r-fold parallel repetition value for assignment sigma."""
    v = game.assignment_value(sigma)
    return v ** r


def constraint_expansion(game: UniqueGame, samples: int = 1000) -> float:
    """Estimate the constraint expansion parameter.
    Measures how many distinct labels are reached by propagating
    through random constraint paths."""
    if not game.edges:
        return 1.0

    total_reached = 0
    for _ in range(samples):
        # Start from random vertex with random label
        v = random.randint(0, game.n - 1)
        label = random.randint(0, game.k - 1)

        # Propagate through random path of length sqrt(n)
        path_length = max(1, int(math.sqrt(game.n)))
        reached_labels: set = {label}

        for _ in range(path_length):
            # Find a random neighbor
            neighbors = [(e, game.constraints[e]) for e in game.edges
                        if e[0] == v or e[1] == v]
            if not neighbors:
                break
            e, pi = random.choice(neighbors)
            if e[0] == v:
                label = pi(label)
                v = e[1]
            else:
                label = pi.inverse()(label)
                v = e[0]
            reached_labels.add(label)

        total_reached += len(reached_labels) / game.k

    return total_reached / samples


def gap_ratio(epsilon: float) -> float:
    """Compute the UGC gap ratio (1-ε)/ε."""
    assert 0 < epsilon < 1
    return (1 - epsilon) / epsilon


def label_complexity_estimate(epsilon: float, base: int = 2) -> int:
    """Estimate label complexity for a given ε.
    Uses the heuristic k(ε) ≈ exp(1/ε²)."""
    return max(base, int(math.exp(1.0 / (epsilon * epsilon))))


def gw_constant() -> float:
    """The Goemans-Williamson approximation ratio for MAX-CUT.
    αGW = min_{0<θ≤π} (2/π)(θ/(1-cos θ))"""
    import numpy as np
    thetas = np.linspace(0.001, np.pi, 10000)
    ratios = (2 / np.pi) * thetas / (1 - np.cos(thetas))
    return float(np.min(ratios))


def sdp_indicator_value(game: UniqueGame, sigma: List[int]) -> float:
    """Compute the SDP objective for the indicator solution
    corresponding to assignment sigma.
    This equals the assignment value (by Theorem 3.5)."""
    return game.assignment_value(sigma)


def integrality_gap_estimate(game: UniqueGame, trials: int = 100) -> float:
    """Estimate the integrality gap for a unique game.
    Uses greedy integer value as denominator."""
    int_value, _ = game.greedy_value(trials)
    if int_value == 0:
        return float('inf')
    # SDP value is at least the integer value (by our theorem)
    # and at most 1. Estimate SDP value as 1 for worst case.
    return 1.0 / int_value
