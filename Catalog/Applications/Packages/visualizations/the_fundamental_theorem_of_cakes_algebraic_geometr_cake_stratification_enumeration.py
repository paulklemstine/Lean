"""
Algorithms for Cake Geometry.

Implements the core mathematical constructions from the Fundamental Theorem
of Cakes, including stratification enumeration, polynomial computation,
and moduli space dimension analysis.
"""

from typing import List, Tuple, Optional
from itertools import combinations
from math import comb
import numpy as np


class CakeSpec:
    """A cake specification: the combinatorial data of a cake.
    
    Attributes:
        base_dim: Dimension of the base manifold
        num_layers: Number of layers (depth of stratification)
        genus: Number of cherries (= first Betti number)
        frosting_rank: Rank of the frosting sheaf (default 1)
    """
    
    def __init__(self, base_dim: int, num_layers: int, genus: int,
                 frosting_rank: int = 1):
        self.base_dim = base_dim
        self.num_layers = num_layers
        self.genus = genus
        self.frosting_rank = frosting_rank
    
    def is_well_formed(self) -> bool:
        """Check if the cake is well-formed: layers ≤ dim and rank > 0."""
        return self.num_layers <= self.base_dim and self.frosting_rank > 0
    
    def moduli_dim(self) -> int:
        """Compute the moduli dimension 3g - 3."""
        return 3 * self.genus - 3
    
    def frosting_number(self) -> int:
        """Compute the frosting number: rank × (dim - 1)."""
        return self.frosting_rank * max(0, self.base_dim - 1)
    
    def total_invariant(self) -> Tuple[int, int, int, int]:
        """Return the total invariant (dim, genus, layers, moduli_dim)."""
        return (self.base_dim, self.genus, self.num_layers, self.moduli_dim())
    
    def flavor_equiv(self, other: 'CakeSpec') -> bool:
        """Check flavor equivalence (ignoring frosting rank)."""
        return (self.base_dim == other.base_dim and
                self.num_layers == other.num_layers and
                self.genus == other.genus)
    
    def __repr__(self) -> str:
        return (f"CakeSpec(dim={self.base_dim}, layers={self.num_layers}, "
                f"genus={self.genus}, frosting={self.frosting_rank})")
    
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, CakeSpec):
            return False
        return (self.base_dim == other.base_dim and
                self.num_layers == other.num_layers and
                self.genus == other.genus and
                self.frosting_rank == other.frosting_rank)


class ValidStratification:
    """A valid stratification: strictly decreasing sequence from n to 0.
    
    Attributes:
        n: Ambient dimension
        k: Depth (number of layers)
        layers: List of layer dimensions [d_0, d_1, ..., d_k]
    """
    
    def __init__(self, n: int, k: int, layers: List[int]):
        self.n = n
        self.k = k
        self.layers = layers
        self._validate()
    
    def _validate(self):
        """Verify stratification validity."""
        assert len(self.layers) == self.k + 1, \
            f"Expected {self.k + 1} layers, got {len(self.layers)}"
        assert self.layers[0] == self.n, \
            f"Top layer must be {self.n}, got {self.layers[0]}"
        assert self.layers[-1] == 0, \
            f"Bottom layer must be 0, got {self.layers[-1]}"
        for i in range(self.k):
            assert self.layers[i] > self.layers[i + 1], \
                f"Not strictly decreasing at position {i}: " \
                f"{self.layers[i]} ≤ {self.layers[i + 1]}"
    
    def euler_cake(self) -> int:
        """Compute the Euler-cake characteristic."""
        return sum((-1)**i * d for i, d in enumerate(self.layers))
    
    def cake_polynomial_coeffs(self) -> List[int]:
        """Return the coefficients of the cake polynomial."""
        return list(self.layers)
    
    def cake_polynomial_eval(self, t: float) -> float:
        """Evaluate the cake polynomial at t."""
        return sum(d * t**i for i, d in enumerate(self.layers))
    
    def layer_dim_bounds(self) -> List[Tuple[int, int]]:
        """Return (lower_bound, upper_bound) for each layer dimension.
        
        Lower bound: k - i (Theorem 5.2)
        Upper bound: n (Theorem 5.3)
        """
        return [(self.k - i, self.n) for i in range(self.k + 1)]
    
    def __repr__(self) -> str:
        return f"Stratification({self.n}, {self.k}, {self.layers})"


def enumerate_stratifications(n: int, k: int) -> List[ValidStratification]:
    """Enumerate all valid stratifications of depth k in dimension n.
    
    Algorithm: Choose k-1 intermediate values from {1, ..., n-1},
    then arrange as [n, ..., 0] in decreasing order.
    
    Time complexity: O(C(n-1, k-1))
    Space complexity: O(k) per stratification
    
    Args:
        n: Ambient dimension
        k: Depth of stratification
    
    Returns:
        List of all valid stratifications
    """
    if k > n:
        return []
    if k == 0:
        if n == 0:
            return [ValidStratification(0, 0, [0])]
        return []
    
    result = []
    for combo in combinations(range(1, n), k - 1):
        layers = [n] + sorted(combo, reverse=True) + [0]
        result.append(ValidStratification(n, k, layers))
    return result


def count_stratifications(n: int, k: int) -> int:
    """Count valid stratifications without enumerating them.
    
    The count equals C(n-1, k-1): choose k-1 intermediate values
    from {1, ..., n-1}.
    
    Time complexity: O(min(k, n-k))
    """
    if k > n or k < 0:
        return 0
    if k == 0:
        return 1 if n == 0 else 0
    return comb(n - 1, k - 1)


def trivalent_graph_data(g: int) -> Tuple[int, int]:
    """Compute (V, E) for a trivalent graph on genus-g surface.
    
    From Euler + trivalent:
      V = 2(g - 1)
      E = 3(g - 1) = moduliDim(g) + 0
    
    Returns:
        Tuple (vertices, edges)
    """
    E = 3 * (g - 1)
    V = 2 * (g - 1)
    return V, E


def moduli_dim(g: int) -> int:
    """Compute the moduli dimension 3g - 3."""
    return 3 * g - 3


def flavor_class_count(n: int, k: int, g: int) -> int:
    """Count flavor-isomorphism classes with bounded parameters.
    
    The count is (n+1)(k+1)(g+1), since each class is determined
    by the triple (baseDim, numLayers, genus).
    """
    return (n + 1) * (k + 1) * (g + 1)


def cake_polynomial_product(strat1: ValidStratification,
                            strat2: ValidStratification) -> List[int]:
    """Compute the product of two cake polynomials.
    
    Uses numpy polynomial multiplication for efficiency.
    
    Args:
        strat1: First stratification
        strat2: Second stratification
    
    Returns:
        Coefficients of the product polynomial
    """
    p1 = np.array(strat1.layers, dtype=int)
    p2 = np.array(strat2.layers, dtype=int)
    return list(np.convolve(p1, p2).astype(int))


# ─── Example usage ───

if __name__ == "__main__":
    # Create a cake
    cake = CakeSpec(base_dim=5, num_layers=3, genus=3)
    print(f"Cake: {cake}")
    print(f"Well-formed: {cake.is_well_formed()}")
    print(f"Moduli dim: {cake.moduli_dim()}")
    print(f"Frosting number: {cake.frosting_number()}")
    print(f"Total invariant: {cake.total_invariant()}")
    
    # Enumerate stratifications
    strats = enumerate_stratifications(5, 3)
    print(f"\nStratifications for n=5, k=3: {len(strats)} total")
    print(f"Expected: C(4,2) = {count_stratifications(5, 3)}")
    for s in strats:
        bounds = s.layer_dim_bounds()
        print(f"  {s.layers}  χ={s.euler_cake()}  "
              f"P(-1)={s.cake_polynomial_eval(-1):.0f}")
    
    # Trivalent graph bridge
    print("\nTrivalent graph bridge:")
    for g in range(2, 6):
        V, E = trivalent_graph_data(g)
        print(f"  g={g}: V={V}, E={E}, moduliDim={moduli_dim(g)}, "
              f"match={E == moduli_dim(g)}")
