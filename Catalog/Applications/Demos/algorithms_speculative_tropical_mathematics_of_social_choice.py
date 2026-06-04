#!/usr/bin/env python3
"""
Tropical Social Choice Theory — Algorithms

Type-hinted implementations of core TropSWF operations.
"""

from dataclasses import dataclass
from typing import List, Set, Tuple, Optional
import math


@dataclass
class TropSWF:
    """Tropical Social Welfare Function for n voters.
    
    Represents f(x) = max_i(weights[i] + x[i]).
    This is a max-plus linear map parameterized by voter weights.
    """
    weights: List[int]
    
    @property
    def n(self) -> int:
        """Number of voters."""
        return len(self.weights)
    
    def eval(self, profile: List[int]) -> int:
        """Evaluate the TropSWF on a preference profile.
        
        f(x) = max_i(w_i + x_i)
        
        Time complexity: O(n)
        """
        assert len(profile) == self.n
        return max(w + x for w, x in zip(self.weights, profile))
    
    def eval_with_argmax(self, profile: List[int]) -> Tuple[int, int]:
        """Evaluate and return the decisive voter.
        
        Returns (outcome, decisive_voter_index).
        Time complexity: O(n)
        """
        assert len(profile) == self.n
        terms = [w + x for w, x in zip(self.weights, profile)]
        max_val = max(terms)
        argmax = terms.index(max_val)
        return max_val, argmax
    
    @property
    def max_weight(self) -> int:
        """Maximum weight across all voters.
        
        Unanimity holds iff max_weight == 0.
        Time complexity: O(n)
        """
        return max(self.weights)
    
    @property
    def min_weight(self) -> int:
        """Minimum weight across all voters."""
        return min(self.weights)
    
    @property
    def weight_gap(self) -> int:
        """Weight gap: max_weight - min_weight.
        
        Measures influence separation. Analog of tropical spectral gap.
        Gap = 0 iff all weights equal (egalitarian).
        Time complexity: O(n)
        """
        return self.max_weight - self.min_weight
    
    @property
    def support(self) -> Set[int]:
        """Support: set of voters with maximum weight.
        
        These form the ruling coalition.
        Time complexity: O(n)
        """
        mw = self.max_weight
        return {i for i, w in enumerate(self.weights) if w == mw}
    
    @property
    def is_unanimous(self) -> bool:
        """Check if the TropSWF satisfies unanimity.
        
        Equivalent to max_weight == 0.
        Time complexity: O(n)
        """
        return self.max_weight == 0
    
    @property
    def is_egalitarian(self) -> bool:
        """Check if all voters have equal weight.
        
        Equivalent to weight_gap == 0.
        Time complexity: O(n)
        """
        return self.weight_gap == 0
    
    def scale(self, k: int) -> 'TropSWF':
        """Scale all weights by factor k.
        
        New weight gap = k * old weight gap (for k > 0).
        Time complexity: O(n)
        """
        return TropSWF(weights=[k * w for w in self.weights])
    
    def shift(self, c: int) -> 'TropSWF':
        """Shift all weights by constant c.
        
        Preserves weight gap. Changes unanimity status.
        Time complexity: O(n)
        """
        return TropSWF(weights=[w + c for w in self.weights])
    
    def compose(self, other: 'TropSWF') -> 'TropSWF':
        """Compose two TropSWFs (tropical matrix product for 1D output).
        
        If self has m weights and other maps m groups of voters to m values,
        the composition applies other first, then self.
        
        For the simple case where other is also a 1D TropSWF:
        (self ∘ other)(x) = self.eval([other.eval(x)])
        """
        raise NotImplementedError("Composition requires matrix TropSWF extension")
    
    @staticmethod
    def pure_max(n: int) -> 'TropSWF':
        """Create the pure max function (all weights zero).
        
        f(x) = max_i(x_i). Satisfies unanimity and is maximally egalitarian.
        """
        return TropSWF(weights=[0] * n)
    
    @staticmethod
    def near_dictator(n: int, dictator: int, gap: int) -> 'TropSWF':
        """Create a near-dictator TropSWF.
        
        Voter `dictator` has weight 0; all others have weight -gap.
        Satisfies unanimity. As gap → ∞, approaches (but never reaches) dictatorship.
        """
        return TropSWF(weights=[0 if i == dictator else -gap for i in range(n)])
    
    @staticmethod
    def oligarchy(n: int, coalition: Set[int], gap: int = 1) -> 'TropSWF':
        """Create an oligarchic TropSWF.
        
        Coalition members have weight 0; others have weight -gap.
        """
        return TropSWF(weights=[0 if i in coalition else -gap for i in range(n)])


def verify_tropical_additivity(f: TropSWF, x: List[int], y: List[int]) -> bool:
    """Verify f(max(x,y)) = max(f(x), f(y)) for specific inputs."""
    xy_max = [max(a, b) for a, b in zip(x, y)]
    lhs = f.eval(xy_max)
    rhs = max(f.eval(x), f.eval(y))
    return lhs == rhs


def verify_tropical_homogeneity(f: TropSWF, c: int, x: List[int]) -> bool:
    """Verify f(c + x) = c + f(x) for specific inputs."""
    cx = [c + xi for xi in x]
    return f.eval(cx) == c + f.eval(x)


def verify_unanimity(f: TropSWF, test_values: Optional[List[int]] = None) -> bool:
    """Verify unanimity for specific constant profiles."""
    if test_values is None:
        test_values = list(range(-10, 11))
    return all(f.eval([c] * f.n) == c for c in test_values)


def verify_pareto(f: TropSWF, x: List[int], y: List[int]) -> bool:
    """Verify Pareto: if x_i ≤ y_i for all i, then f(x) ≤ f(y)."""
    if all(xi <= yi for xi, yi in zip(x, y)):
        return f.eval(x) <= f.eval(y)
    return True  # Precondition not met, vacuously true


def bounded_domain_influence(
    f: TropSWF, K: int
) -> List[float]:
    """Compute each voter's decisive fraction over bounded domain {0,...,K}^n.
    
    Returns list of fractions (one per voter).
    Warning: exponential in n.
    """
    import itertools
    n = f.n
    counts = [0] * n
    total = 0
    
    for profile in itertools.product(range(K + 1), repeat=n):
        total += 1
        _, winner = f.eval_with_argmax(list(profile))
        counts[winner] += 1
    
    return [c / total for c in counts]


# Example usage
if __name__ == "__main__":
    # Create TropSWFs
    egal = TropSWF.pure_max(5)
    print(f"Egalitarian: weights={egal.weights}, gap={egal.weight_gap}, "
          f"unanimous={egal.is_unanimous}")
    
    near_dict = TropSWF.near_dictator(5, dictator=0, gap=10)
    print(f"Near-dictator: weights={near_dict.weights}, gap={near_dict.weight_gap}, "
          f"unanimous={near_dict.is_unanimous}")
    
    oligarch = TropSWF.oligarchy(5, coalition={0, 2, 4}, gap=5)
    print(f"Oligarchy: weights={oligarch.weights}, gap={oligarch.weight_gap}, "
          f"support={oligarch.support}")
    
    # Verify properties
    x = [1, 5, 3, 2, 4]
    y = [2, 3, 6, 1, 5]
    
    for name, f in [("egal", egal), ("near_dict", near_dict), ("oligarch", oligarch)]:
        print(f"\n{name}:")
        print(f"  f({x}) = {f.eval(x)}")
        print(f"  Tropical additive: {verify_tropical_additivity(f, x, y)}")
        print(f"  Tropical homogeneous (c=3): {verify_tropical_homogeneity(f, 3, x)}")
        print(f"  Unanimous: {verify_unanimity(f)}")
