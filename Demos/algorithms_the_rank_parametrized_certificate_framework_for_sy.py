"""
Algorithms for Symplectic Expansion Certificate Framework
=========================================================

Implements the core algorithms from the research paper:
1. Certificate construction from character-ratio data
2. Mixing time computation
3. Expander code parameter optimization
4. Certificate tensor product composition
"""

import math
from dataclasses import dataclass
from typing import List, Optional, Tuple


@dataclass
class ExpansionCertificate:
    """An expansion certificate packaging spectral gap data.
    
    Attributes:
        vertices: Number of vertices in the Cayley graph
        degree: Regularity degree
        gap: Spectral gap ε ∈ (0, 1]
        char_ratio_bound: Character ratio bound C/q
    """
    vertices: int
    degree: int
    gap: float
    char_ratio_bound: float

    def __post_init__(self):
        assert self.gap > 0, f"Gap must be positive, got {self.gap}"
        assert self.gap <= 1, f"Gap must be ≤ 1, got {self.gap}"
        assert self.vertices > 0
        assert self.degree >= 2

    def tensor(self, other: 'ExpansionCertificate') -> 'ExpansionCertificate':
        """Tensor product of two certificates.
        
        Time complexity: O(1)
        Space complexity: O(1)
        
        For product graphs G □ H, the spectral gap is min(ε_G, ε_H).
        """
        return ExpansionCertificate(
            vertices=self.vertices * other.vertices,
            degree=self.degree + other.degree,
            gap=min(self.gap, other.gap),
            char_ratio_bound=max(self.char_ratio_bound, other.char_ratio_bound)
        )

    def mixing_bound(self, t: int) -> float:
        """Mixing bound (1 - ε)^t after t steps.
        
        Time complexity: O(log t)
        """
        return (1.0 - self.gap) ** t

    def tv_distance_bound(self, t: int) -> float:
        """Total variation distance bound: sqrt(n) * (1-ε)^t.
        
        Time complexity: O(log t)
        """
        return math.sqrt(self.vertices) * self.mixing_bound(t)

    def mixing_time(self, target: float = 0.01) -> int:
        """Steps to reach target TV distance.
        
        Time complexity: O(1) using logarithm
        
        Returns ⌈log(target / √n) / log(1-ε)⌉
        """
        if self.gap >= 1.0:
            return 1
        adjusted_target = target / math.sqrt(self.vertices)
        if adjusted_target >= 1.0:
            return 0
        return math.ceil(math.log(adjusted_target) / math.log(1.0 - self.gap))

    def at_least_as_strong(self, other: 'ExpansionCertificate') -> bool:
        """Check if this certificate is at least as strong as other."""
        return self.gap >= other.gap and self.char_ratio_bound <= other.char_ratio_bound


@dataclass
class ExpanderCodeParams:
    """Parameters for an expander code.
    
    Built from a bipartite expander with spectral gap and a local inner code.
    
    Attributes:
        left_deg: Check node degree (c)
        right_deg: Variable node degree (d)
        block_length: Number of variable nodes (n)
        spectral_gap: Gap of underlying expander (ε)
        inner_distance: Min distance of inner code as fraction (δ)
    """
    left_deg: int
    right_deg: int
    block_length: int
    spectral_gap: float
    inner_distance: float

    @property
    def rate(self) -> float:
        """Code rate: 1 - c/d.
        
        Time complexity: O(1)
        """
        return 1.0 - self.left_deg / self.right_deg

    @property
    def distance_bound(self) -> float:
        """Distance lower bound: (δ - (1-ε)) · n.
        
        Positive when inner distance exceeds spectral deficiency.
        Time complexity: O(1)
        """
        return (self.inner_distance - (1.0 - self.spectral_gap)) * self.block_length

    @property
    def in_expansion_regime(self) -> bool:
        """Check if δ > 1 - ε (expansion beats deficiency)."""
        return self.inner_distance > 1.0 - self.spectral_gap


def construct_rank_certificate(
    n: int, q: int
) -> Optional[ExpansionCertificate]:
    """Construct an expansion certificate for Sp_{2n}(F_q).
    
    Algorithm:
    1. Compute character ratio bound (n+1)/q
    2. Verify expansion regime: (n+1)/q < 1
    3. Package as certificate with gap = 1 - (n+1)/q
    
    Time complexity: O(1)
    Space complexity: O(1)
    
    Args:
        n: Rank parameter (≥ 1)
        q: Field size (prime, must satisfy q > n+1)
    
    Returns:
        Certificate if q > n+1, None otherwise
    """
    if n < 1 or q <= n + 1:
        return None
    
    ratio = (n + 1) / q
    gap = 1.0 - ratio
    
    # Sp_{2n}(F_q) has |G| = q^{n^2} * prod(q^{2i} - 1) for i=1..n
    # For certificate, we use a simplified vertex count
    vertices = q ** (n * n)  # simplified; true order is larger
    degree = 4  # symmetric generating set {s, s^{-1}, t, t^{-1}}
    
    return ExpansionCertificate(
        vertices=vertices,
        degree=degree,
        gap=gap,
        char_ratio_bound=ratio
    )


def optimal_field_for_gap(n: int, target_gap: float) -> int:
    """Find smallest q such that Sp_{2n}(F_q) has gap ≥ target_gap.
    
    Algorithm:
    1. Solve 1 - (n+1)/q ≥ target_gap
    2. q ≥ (n+1)/(1 - target_gap)
    3. Round up to next prime
    
    Time complexity: O(q log log q) for primality testing
    
    Args:
        n: Rank
        target_gap: Desired spectral gap in (0, 1)
    
    Returns:
        Smallest prime q achieving the target gap
    """
    if target_gap <= 0 or target_gap >= 1:
        raise ValueError(f"target_gap must be in (0,1), got {target_gap}")
    
    q_min = math.ceil((n + 1) / (1 - target_gap))
    
    # Find next prime ≥ q_min
    def is_prime(p):
        if p < 2: return False
        if p < 4: return True
        if p % 2 == 0: return False
        for i in range(3, int(math.sqrt(p)) + 1, 2):
            if p % i == 0: return False
        return True
    
    q = max(q_min, 3)
    if q % 2 == 0:
        q += 1
    while not is_prime(q):
        q += 2
    return q


def tensor_family(
    certificates: List[ExpansionCertificate]
) -> ExpansionCertificate:
    """Tensor product of a family of certificates.
    
    Algorithm: Iteratively apply binary tensor product.
    
    Time complexity: O(k) where k = len(certificates)
    Space complexity: O(1) 
    
    The gap of the result is min of all component gaps (proved in Lean).
    """
    if not certificates:
        raise ValueError("Need at least one certificate")
    
    result = certificates[0]
    for cert in certificates[1:]:
        result = result.tensor(cert)
    return result


def optimize_expander_code(
    available_gaps: List[float],
    inner_distances: List[float],
    block_length: int,
    min_rate: float = 0.1
) -> Optional[ExpanderCodeParams]:
    """Find optimal expander code parameters.
    
    Algorithm:
    1. For each (gap, inner_dist) pair, compute code parameters
    2. Filter by minimum rate constraint
    3. Select by maximum distance bound
    
    Time complexity: O(|gaps| × |inner_distances|)
    
    Args:
        available_gaps: Available spectral gaps
        inner_distances: Available inner code distances
        block_length: Desired block length
        min_rate: Minimum acceptable code rate
    
    Returns:
        Optimal ExpanderCodeParams or None
    """
    best = None
    best_distance = -1.0
    
    for gap in available_gaps:
        for inner_dist in inner_distances:
            # Try various degree pairs
            for left_deg in range(2, 20):
                for right_deg in range(left_deg + 1, 40):
                    rate = 1.0 - left_deg / right_deg
                    if rate < min_rate:
                        continue
                    
                    params = ExpanderCodeParams(
                        left_deg=left_deg,
                        right_deg=right_deg,
                        block_length=block_length,
                        spectral_gap=gap,
                        inner_distance=inner_dist
                    )
                    
                    if params.in_expansion_regime and params.distance_bound > best_distance:
                        best = params
                        best_distance = params.distance_bound
    
    return best


# ========== Example Usage ==========
if __name__ == "__main__":
    print("Certificate Construction Examples")
    print("=" * 50)
    
    # Build certificates for various ranks
    for n in [1, 2, 3, 4, 5]:
        q = optimal_field_for_gap(n, 0.5)
        cert = construct_rank_certificate(n, q)
        if cert:
            t_mix = cert.mixing_time(0.01)
            print(f"Sp_{2*n}(F_{q}): gap={cert.gap:.4f}, "
                  f"mixing_time={t_mix}, "
                  f"|G|≈{cert.vertices:.2e}")
    
    print("\nTensor Product Composition")
    print("=" * 50)
    certs = [construct_rank_certificate(n, 13) for n in range(1, 5)]
    certs = [c for c in certs if c is not None]
    tensor = tensor_family(certs)
    print(f"Tensor of {len(certs)} certificates: gap={tensor.gap:.4f}")
    
    print("\nExpander Code Optimization")
    print("=" * 50)
    best_code = optimize_expander_code(
        available_gaps=[0.5, 0.6, 0.7, 0.8],
        inner_distances=[0.3, 0.4, 0.5],
        block_length=1000,
        min_rate=0.2
    )
    if best_code:
        print(f"Best code: rate={best_code.rate:.3f}, "
              f"distance≥{best_code.distance_bound:.1f}, "
              f"gap={best_code.spectral_gap}")
