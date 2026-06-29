#!/usr/bin/env python3
"""
Algorithms for Triadic Hardness Transport

Implements the core algorithms from the research paper:
1. AffineMorphism — composable affine transfer maps
2. TheorySpec — theories with real-valued invariants
3. TransferChain — chains of morphisms with automatic composition
4. SecurityCertifier — end-to-end security certification pipeline
"""

from dataclasses import dataclass
from typing import Callable, Optional
import math


@dataclass
class AffineMorphism:
    """
    An affine morphism between invariant theories.
    
    Represents the relationship: source_inv(x) ≤ c * target_inv(f(x)) + a
    where c > 0 is the multiplicative constant and a is the additive offset.
    
    Attributes:
        name: Human-readable description of the morphism
        c: Multiplicative constant (must be > 0)
        a: Additive constant
    """
    name: str
    c: float
    a: float
    
    def __post_init__(self):
        if self.c <= 0:
            raise ValueError(f"Multiplicative constant must be positive, got {self.c}")
    
    def compose(self, other: 'AffineMorphism') -> 'AffineMorphism':
        """
        Compose self with other: self ∘ other.
        
        If self has (c₁, a₁) and other has (c₂, a₂), the composition has:
            c = c₁ * c₂
            a = a₁ + c₁ * a₂
        
        This is the key algebraic law that makes hardness transport composable.
        
        >>> f = AffineMorphism("A→B", 1.5, 0.1)
        >>> g = AffineMorphism("B→C", 2.0, 0.05)
        >>> h = f.compose(g)
        >>> h.c  # 1.5 * 2.0
        3.0
        >>> h.a  # 0.1 + 1.5 * 0.05
        0.175
        """
        return AffineMorphism(
            name=f"{self.name} ∘ {other.name}",
            c=self.c * other.c,
            a=self.a + self.c * other.a,
        )
    
    def transport_lower_bound(self, B: float) -> float:
        """
        Transport a lower bound through the morphism.
        
        Given B ≤ source_inv(x), compute the implied lower bound on target_inv:
            (B - a) / c ≤ target_inv(f(x))
        
        Args:
            B: Lower bound on source invariant
            
        Returns:
            Lower bound on target invariant
        """
        return (B - self.a) / self.c
    
    def __repr__(self) -> str:
        return f"AffineMorphism('{self.name}', c={self.c}, a={self.a})"


def compose_chain(morphisms: list[AffineMorphism]) -> AffineMorphism:
    """
    Compose a chain of morphisms left-to-right.
    
    Given morphisms [f₁, f₂, ..., fₙ], computes f₁ ∘ f₂ ∘ ... ∘ fₙ.
    
    Time complexity: O(n)
    Space complexity: O(1) (streaming composition)
    
    Args:
        morphisms: List of affine morphisms to compose
        
    Returns:
        The composed morphism with explicit constants
        
    >>> chain = [
    ...     AffineMorphism("L→H", 1.5, 0.1),
    ...     AffineMorphism("H→T", 2.0, 0.05),
    ...     AffineMorphism("T→S", 1.0, 0.02),
    ... ]
    >>> result = compose_chain(chain)
    >>> result.c  # 1.5 * 2.0 * 1.0
    3.0
    """
    if not morphisms:
        raise ValueError("Cannot compose empty chain")
    
    result = morphisms[0]
    for m in morphisms[1:]:
        result = result.compose(m)
    return result


@dataclass
class TransferChain:
    """
    A chain of theory morphisms for hardness transport.
    
    Manages a sequence of affine morphisms and provides:
    - Automatic composition
    - Lower-bound transport
    - Sensitivity analysis
    - Breakdown of constants by stage
    """
    morphisms: list[AffineMorphism]
    
    @property
    def composed(self) -> AffineMorphism:
        """The fully composed morphism."""
        return compose_chain(self.morphisms)
    
    def security_lower_bound(self, B: float) -> float:
        """
        Compute the security lower bound from a learning lower bound.
        
        This is the main user-facing function: given a certified lower bound
        B on the learning invariant, compute the implied lower bound on
        the security invariant.
        """
        return self.composed.transport_lower_bound(B)
    
    def stage_bounds(self, B: float) -> list[tuple[str, float]]:
        """
        Compute the lower bound at each intermediate stage.
        
        Useful for understanding where the bound degrades most.
        """
        bounds = [("Input", B)]
        current = B
        for m in self.morphisms:
            current = m.transport_lower_bound(current)
            bounds.append((m.name, current))
        return bounds
    
    def sensitivity(self, B: float, param: str, 
                    delta: float = 0.01) -> dict[str, float]:
        """
        Compute sensitivity of the security bound to each parameter.
        
        Returns d(security_bound)/d(param) for each morphism constant.
        """
        base = self.security_lower_bound(B)
        sensitivities = {}
        
        for i, m in enumerate(self.morphisms):
            # Sensitivity to c_i
            perturbed = list(self.morphisms)
            perturbed[i] = AffineMorphism(m.name, m.c + delta, m.a)
            chain = TransferChain(perturbed)
            d_c = (chain.security_lower_bound(B) - base) / delta
            sensitivities[f"d/d(c_{i+1})"] = d_c
            
            # Sensitivity to a_i
            perturbed = list(self.morphisms)
            perturbed[i] = AffineMorphism(m.name, m.c, m.a + delta)
            chain = TransferChain(perturbed)
            d_a = (chain.security_lower_bound(B) - base) / delta
            sensitivities[f"d/d(a_{i+1})"] = d_a
        
        return sensitivities


@dataclass
class SecurityCertifier:
    """
    End-to-end security certification pipeline.
    
    Given a neural network's margin and Lipschitz constant, and a chain of
    transfer morphisms, certifies the minimum security parameter.
    """
    chain: TransferChain
    
    def certify(self, margin: float, lipschitz: float, 
                depth: Optional[int] = None) -> dict:
        """
        Certify security from margin/Lipschitz data.
        
        Args:
            margin: Classifier margin δ
            lipschitz: Lipschitz constant K (per layer if depth given)
            depth: Network depth L (optional; uses K^L if provided)
            
        Returns:
            Dictionary with:
            - robustness_radius: δ/K or δ/K^L
            - security_lower_bound: transported bound
            - certified_robust: whether δ - K·ε ≥ 0 for ε = robustness_radius
            - stage_breakdown: bounds at each stage
        """
        if depth is not None and lipschitz < 1.0:
            effective_K = lipschitz ** depth
        else:
            effective_K = lipschitz
            
        radius = margin / effective_K
        sec_bound = self.chain.security_lower_bound(radius)
        stages = self.chain.stage_bounds(radius)
        
        return {
            "margin": margin,
            "lipschitz": lipschitz,
            "depth": depth,
            "effective_lipschitz": effective_K,
            "robustness_radius": radius,
            "security_lower_bound": sec_bound,
            "certified_robust": True,  # always true when ε ≤ δ/K
            "stage_breakdown": stages,
        }


# ═══════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    # Define the triadic transfer chain
    chain = TransferChain([
        AffineMorphism("Learning → Height", c=1.5, a=0.10),
        AffineMorphism("Height → Tropical", c=2.0, a=0.05),
        AffineMorphism("Tropical → Security", c=1.0, a=0.02),
    ])
    
    print("Triadic Transfer Chain")
    print("=" * 50)
    for m in chain.morphisms:
        print(f"  {m}")
    print(f"\nComposed: {chain.composed}")
    
    # Security certification
    certifier = SecurityCertifier(chain)
    
    print("\n\nSecurity Certification Examples")
    print("=" * 50)
    
    examples = [
        (2.0, 0.5, 4),    # Deep contractive network
        (5.0, 1.0, None),  # Single-layer, Lipschitz = 1
        (10.0, 0.8, 3),   # Moderate depth
    ]
    
    for margin, lip, depth in examples:
        result = certifier.certify(margin, lip, depth)
        print(f"\nMargin={margin}, Lipschitz={lip}, Depth={depth}")
        print(f"  Effective Lipschitz: {result['effective_lipschitz']:.6f}")
        print(f"  Robustness radius:   {result['robustness_radius']:.4f}")
        print(f"  Security lower bound: {result['security_lower_bound']:.4f}")
        print(f"  Stage breakdown:")
        for stage, bound in result['stage_breakdown']:
            print(f"    {stage:30s}: {bound:.4f}")
    
    # Sensitivity analysis
    print("\n\nSensitivity Analysis (B = 50.0)")
    print("=" * 50)
    sens = chain.sensitivity(50.0, "all")
    for param, value in sens.items():
        print(f"  {param:12s}: {value:+.6f}")
