#!/usr/bin/env python3
"""
Stone Duality for Neural Networks: Core Algorithms

Type-hinted implementations of the key algorithms from the research.
"""

from typing import List, Tuple, Set, Dict, FrozenSet, Optional
import numpy as np
from math import comb
from dataclasses import dataclass


@dataclass
class HyperplaneArrangement:
    """A hyperplane arrangement in R^n with m hyperplanes.
    
    Each hyperplane H_j is defined by {x : w_j . x + b_j = 0}.
    The positive halfspace is {x : w_j . x + b_j > 0}.
    """
    weights: np.ndarray  # shape (m, n)
    biases: np.ndarray   # shape (m,)
    
    @property
    def n_dim(self) -> int:
        return self.weights.shape[1]
    
    @property
    def n_hyperplanes(self) -> int:
        return self.weights.shape[0]
    
    def activation(self, x: np.ndarray) -> np.ndarray:
        """Compute activation values for all neurons at point x."""
        return self.weights @ x + self.biases
    
    def pattern(self, x: np.ndarray) -> Tuple[bool, ...]:
        """Compute the activation pattern of x."""
        return tuple(a > 0 for a in self.activation(x))
    
    def append(self, other: 'HyperplaneArrangement') -> 'HyperplaneArrangement':
        """Compose two arrangements by concatenation."""
        assert self.n_dim == other.n_dim
        return HyperplaneArrangement(
            weights=np.vstack([self.weights, other.weights]),
            biases=np.concatenate([self.biases, other.biases])
        )


ActivationPattern = Tuple[bool, ...]


def enumerate_regions(
    arr: HyperplaneArrangement,
    n_samples: int = 100000,
    seed: int = 42
) -> Set[ActivationPattern]:
    """Enumerate realizable activation patterns by random sampling.
    
    Args:
        arr: The hyperplane arrangement
        n_samples: Number of random samples to draw
        seed: Random seed for reproducibility
    
    Returns:
        Set of distinct activation patterns found
    
    Note: This is a Monte Carlo estimate. For exact enumeration,
    use linear programming (see `exact_enumerate_regions`).
    """
    rng = np.random.default_rng(seed)
    patterns: Set[ActivationPattern] = set()
    for _ in range(n_samples):
        x = rng.standard_normal(arr.n_dim) * 10
        patterns.add(arr.pattern(x))
    return patterns


def exact_enumerate_regions(
    arr: HyperplaneArrangement
) -> Set[ActivationPattern]:
    """Enumerate all realizable activation patterns exactly.
    
    Uses linear programming feasibility checks for each candidate pattern.
    Exponential in m but exact.
    
    Args:
        arr: The hyperplane arrangement
    
    Returns:
        Set of all realizable activation patterns
    """
    from itertools import product as cart_product
    try:
        from scipy.optimize import linprog
    except ImportError:
        # Fallback to sampling if scipy not available
        return enumerate_regions(arr, n_samples=500000)
    
    m, n = arr.weights.shape
    realizable: Set[ActivationPattern] = set()
    
    for sigma in cart_product([False, True], repeat=m):
        # Check feasibility: exists x such that
        # w_j . x + b_j > 0 if sigma_j = True
        # w_j . x + b_j <= 0 if sigma_j = False
        # Use LP: minimize 0 subject to constraints
        A_ub = []
        b_ub_list = []
        for j in range(m):
            if sigma[j]:
                # w_j . x + b_j > 0 -> -w_j . x < b_j (strict, use epsilon)
                A_ub.append(-arr.weights[j])
                b_ub_list.append(-arr.biases[j] - 1e-8)
            else:
                # w_j . x + b_j <= 0 -> w_j . x <= -b_j
                A_ub.append(arr.weights[j])
                b_ub_list.append(-arr.biases[j])
        
        A_ub_arr = np.array(A_ub)
        b_ub_arr = np.array(b_ub_list)
        
        result = linprog(
            c=np.zeros(n),
            A_ub=A_ub_arr,
            b_ub=b_ub_arr,
            bounds=[(None, None)] * n,
            method='highs'
        )
        
        if result.success:
            realizable.add(sigma)
    
    return realizable


def zaslavsky_bound(n: int, m: int) -> int:
    """Compute the Zaslavsky bound: sum_{i=0}^{min(n,m)} C(m, i).
    
    This is the maximum number of regions of m hyperplanes in R^n.
    The bound is tight for arrangements in general position.
    
    Args:
        n: Ambient dimension
        m: Number of hyperplanes
    
    Returns:
        The Zaslavsky bound
    """
    return sum(comb(m, i) for i in range(min(n, m) + 1))


def sauer_shelah_bound(d: int, n: int) -> int:
    """Compute the Sauer-Shelah bound: sum_{i=0}^d C(n, i).
    
    If a hypothesis class has VC dimension d, then the number of
    distinct labelings on any n points is at most this bound.
    
    Args:
        d: VC dimension
        n: Number of points
    
    Returns:
        The Sauer-Shelah bound
    """
    return sum(comb(n, i) for i in range(d + 1))


def neural_boolean_algebra_size(m: int) -> int:
    """Size of the neural Boolean algebra: 2^(2^m).
    
    This is the number of possible Boolean combinations of
    activation regions for m neurons.
    
    Args:
        m: Number of neurons
    
    Returns:
        Size of the Boolean algebra
    """
    return 2 ** (2 ** m)


@dataclass
class NeuralBooleanAlgebra:
    """The Boolean algebra of activation patterns.
    
    Elements are frozensets of activation patterns.
    Operations: union (join), intersection (meet), complement.
    """
    patterns: FrozenSet[ActivationPattern]
    universe: FrozenSet[ActivationPattern]
    
    def union(self, other: 'NeuralBooleanAlgebra') -> 'NeuralBooleanAlgebra':
        return NeuralBooleanAlgebra(
            self.patterns | other.patterns, self.universe)
    
    def intersection(self, other: 'NeuralBooleanAlgebra') -> 'NeuralBooleanAlgebra':
        return NeuralBooleanAlgebra(
            self.patterns & other.patterns, self.universe)
    
    def complement(self) -> 'NeuralBooleanAlgebra':
        return NeuralBooleanAlgebra(
            self.universe - self.patterns, self.universe)
    
    @property
    def is_atom(self) -> bool:
        return len(self.patterns) == 1
    
    @property
    def atoms(self) -> List['NeuralBooleanAlgebra']:
        return [NeuralBooleanAlgebra(frozenset([p]), self.universe) 
                for p in self.patterns]
    
    def __repr__(self) -> str:
        return f"NeuralBoolAlg({len(self.patterns)} patterns / {len(self.universe)} total)"


def build_neural_boolean_algebra(
    arr: HyperplaneArrangement,
    n_samples: int = 100000
) -> NeuralBooleanAlgebra:
    """Build the neural Boolean algebra for an arrangement.
    
    Args:
        arr: The hyperplane arrangement
        n_samples: Samples for region enumeration
    
    Returns:
        The full neural Boolean algebra (universe = all realizable patterns)
    """
    patterns = frozenset(enumerate_regions(arr, n_samples))
    return NeuralBooleanAlgebra(patterns, patterns)


def estimate_vc_dimension(
    arr: HyperplaneArrangement,
    max_d: int = 20,
    n_trials: int = 1000,
    seed: int = 42
) -> int:
    """Estimate the VC dimension of the family of decision regions.
    
    Uses random sampling to find the largest set that can be shattered.
    
    Args:
        arr: The hyperplane arrangement
        max_d: Maximum dimension to check
        n_trials: Number of random point sets to try per dimension
        seed: Random seed
    
    Returns:
        Estimated VC dimension (lower bound)
    """
    rng = np.random.default_rng(seed)
    best_d = 0
    
    for d in range(1, max_d + 1):
        shattered = False
        for _ in range(n_trials):
            # Random d points
            points = [rng.standard_normal(arr.n_dim) * 5 for _ in range(d)]
            
            # Check all 2^d labelings
            all_labelings = set()
            # Sample many random halfspace selections
            for _ in range(min(10000, 3 ** arr.n_hyperplanes)):
                # Random element of Boolean algebra
                subset = frozenset(
                    j for j in range(arr.n_hyperplanes) 
                    if rng.random() < 0.5
                )
                labeling = tuple(
                    any(
                        arr.activation(p)[j] > 0 
                        for j in subset
                    )
                    for p in points
                )
                all_labelings.add(labeling)
            
            if len(all_labelings) == 2 ** d:
                shattered = True
                break
        
        if shattered:
            best_d = d
        else:
            break
    
    return best_d


if __name__ == "__main__":
    # Quick demo
    arr = HyperplaneArrangement(
        weights=np.array([[1.0, 0.0], [0.0, 1.0], [1.0, -1.0]]),
        biases=np.array([0.0, 0.0, 0.0])
    )
    
    regions = enumerate_regions(arr)
    print(f"3 hyperplanes in R^2: {len(regions)} regions")
    print(f"Zaslavsky bound: {zaslavsky_bound(2, 3)}")
    
    ba = build_neural_boolean_algebra(arr)
    print(f"Boolean algebra: {ba}")
    print(f"Atoms: {len(ba.atoms)}")
    print(f"Full algebra size: 2^{len(ba.atoms)} = {2**len(ba.atoms)}")
