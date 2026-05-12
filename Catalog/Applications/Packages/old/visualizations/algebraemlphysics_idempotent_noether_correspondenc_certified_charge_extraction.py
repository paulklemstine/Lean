#!/usr/bin/env python3
"""
Idempotent Noether Correspondence — Algorithms

Implements the certified charge extraction and symmetry reconstruction
algorithms from the Idempotent Noether Correspondence theory.
"""

from typing import Callable, Dict, FrozenSet, List, Optional, Set, Tuple
import numpy as np
from dataclasses import dataclass


# ─────────────────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────────────────

@dataclass
class ClosureOperator:
    """A closure operator on a finite set {0, ..., n-1}.
    
    Represented as a function cl: int -> int satisfying:
      - Extensive: x ≤ cl(x) (in the given partial order)
      - Monotone: x ≤ y => cl(x) ≤ cl(y)
      - Idempotent: cl(cl(x)) = cl(x)
    """
    n: int
    cl: Callable[[int], int]
    
    def is_closed(self, x: int) -> bool:
        """Check if x is a closed element."""
        return self.cl(x) == x
    
    def closed_elements(self) -> List[int]:
        """Return all closed elements."""
        return [x for x in range(self.n) if self.is_closed(x)]
    
    def verify(self, leq: Callable[[int, int], bool]) -> bool:
        """Verify the closure axioms with respect to a partial order."""
        for x in range(self.n):
            # Extensive
            if not leq(x, self.cl(x)):
                return False
            # Idempotent
            if self.cl(self.cl(x)) != self.cl(x):
                return False
            # Monotone
            for y in range(self.n):
                if leq(x, y) and not leq(self.cl(x), self.cl(y)):
                    return False
        return True


@dataclass
class SymmetryGenerator:
    """A symmetry generator σ: {0,...,n-1} → {0,...,n-1}."""
    n: int
    sigma: List[int]  # σ as a permutation table
    
    def __call__(self, x: int) -> int:
        return self.sigma[x]
    
    def fixed_points(self) -> Set[int]:
        """Return the set of fixed points of σ."""
        return {x for x in range(self.n) if self.sigma[x] == x}
    
    def descent_set(self) -> Set[int]:
        """Return the descent set {x | σ(x) ≤ x} (linear order)."""
        return {x for x in range(self.n) if self.sigma[x] <= x}
    
    def commutes_with(self, tau: List[int]) -> bool:
        """Check if σ commutes with τ."""
        return all(
            self.sigma[tau[x]] == tau[self.sigma[x]]
            for x in range(self.n)
        )
    
    def fixed_point_indicator(self) -> Tuple[int, ...]:
        """Return the fixed-point indicator charge."""
        return tuple(int(self.sigma[x] == x) for x in range(self.n))


@dataclass
class ConservedCharge:
    """A conserved charge Q: X → Γ with conservation certificate."""
    n: int
    values: Tuple[int, ...]  # Q(x) for each x
    source_symmetry: Optional[str] = None  # Which symmetry generated this
    
    def is_conserved(self, tau: List[int]) -> bool:
        """Verify that Q(τ(x)) = Q(x) for all x."""
        return all(
            self.values[tau[x]] == self.values[x]
            for x in range(self.n)
        )


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Certified Charge Extraction
# ─────────────────────────────────────────────────────────────────────

def extract_conserved_charges(
    n: int,
    tau: List[int],
    symmetries: Dict[str, List[int]],
    verify: bool = True
) -> List[ConservedCharge]:
    """
    Extract conserved fixed-point indicator charges from symmetries.
    
    Given:
      - n: size of the finite set X = {0, ..., n-1}
      - tau: bijective dynamics τ as a permutation table
      - symmetries: named symmetry generators, each commuting with τ
    
    Returns:
      List of ConservedCharge objects, each certified conserved.
    
    Time complexity: O(|symmetries| × n)
    Space complexity: O(|symmetries| × n)
    
    The algorithm:
    1. For each symmetry σ, compute the fixed-point indicator Q_σ(x) = [σ(x) = x]
    2. Verify Q_σ(τ(x)) = Q_σ(x) for all x (conservation certificate)
    3. Return the list of certified charges
    """
    charges = []
    
    for name, sigma in symmetries.items():
        sym = SymmetryGenerator(n, sigma)
        
        if verify and not sym.commutes_with(tau):
            raise ValueError(f"Symmetry {name} does not commute with τ")
        
        indicator = sym.fixed_point_indicator()
        charge = ConservedCharge(
            n=n,
            values=indicator,
            source_symmetry=name
        )
        
        if verify and not charge.is_conserved(tau):
            raise ValueError(
                f"Conservation verification failed for {name} — "
                "this should not happen if commutation holds"
            )
        
        charges.append(charge)
    
    return charges


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Symmetry Reconstruction from Charges
# ─────────────────────────────────────────────────────────────────────

def reconstruct_fixed_points(charge: ConservedCharge) -> Set[int]:
    """
    Reconstruct the fixed-point set from a Boolean conserved charge.
    
    Given a charge Q that equals the fixed-point indicator of some σ,
    return {x | Q(x) = 1} = Fix(σ).
    
    Time complexity: O(n)
    """
    return {x for x in range(charge.n) if charge.values[x] == 1}


def charges_separate(charges: List[ConservedCharge]) -> bool:
    """
    Check if the given charges separate symmetry classes — i.e.,
    whether distinct symmetries yield distinct charge vectors.
    
    Time complexity: O(|charges| × n)
    """
    seen = set()
    for charge in charges:
        if charge.values in seen:
            return False
        seen.add(charge.values)
    return True


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Monoid Conservation Verification
# ─────────────────────────────────────────────────────────────────────

def verify_monoid_conservation(
    n: int,
    cl: Callable[[int], int],
    sigma: List[int],
    Q: Callable[[int], int],
    max_iterations: int = 100
) -> Tuple[bool, int]:
    """
    Verify that Q is conserved under all iterations of (cl ∘ σ).
    
    Returns (is_conserved, max_iteration_tested).
    
    For finite X, (cl ∘ σ)^n must eventually cycle, so we only
    need to check up to |X| iterations.
    
    Time complexity: O(n × min(max_iterations, n))
    """
    for k in range(1, min(max_iterations, n) + 1):
        for x in range(n):
            # Compute (cl ∘ σ)^k(x)
            y = x
            for _ in range(k):
                y = cl(sigma[y])
            
            if Q(y) != Q(x):
                return False, k
    
    return True, min(max_iterations, n)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Tropical Noether Charge Map
# ─────────────────────────────────────────────────────────────────────

def noether_charge_map(
    n: int,
    symmetries: Dict[str, List[int]],
    tau: List[int]
) -> Dict[str, Tuple[int, ...]]:
    """
    Compute the Noether charge map: symmetry → conserved charge.
    
    Maps each symmetry generator to its fixed-point indicator charge,
    which is proven to be conserved when the symmetry commutes with
    bijective dynamics τ.
    
    Time complexity: O(|symmetries| × n)
    
    Returns:
      Dictionary mapping symmetry names to charge vectors.
    """
    charge_map = {}
    for name, sigma in symmetries.items():
        sym = SymmetryGenerator(n, sigma)
        charge_map[name] = sym.fixed_point_indicator()
    return charge_map


def is_charge_map_injective(charge_map: Dict[str, Tuple[int, ...]]) -> bool:
    """Check if the Noether charge map is injective on fixed-point profiles."""
    values = list(charge_map.values())
    return len(values) == len(set(values))


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Complete Symmetry-Charge Analysis
# ─────────────────────────────────────────────────────────────────────

def full_noether_analysis(
    n: int,
    tau: List[int],
    symmetries: Dict[str, List[int]],
    cl: Optional[Callable[[int], int]] = None
) -> Dict:
    """
    Perform complete Noether correspondence analysis.
    
    Given finite dynamics and symmetries:
    1. Verify all commutation relations
    2. Extract conserved charges
    3. Check charge separation
    4. Compute the Noether charge map
    5. Verify monoid conservation (if closure provided)
    
    Returns a comprehensive analysis dictionary.
    
    Time complexity: O(|symmetries|² × n)
    """
    results = {
        "n": n,
        "tau": tau,
        "num_symmetries": len(symmetries),
        "commutation_verified": True,
        "charges": {},
        "all_conserved": True,
        "charges_separate": True,
        "noether_map_injective": True,
        "monoid_conservation": None
    }
    
    # Step 1: Verify commutation
    for name, sigma in symmetries.items():
        sym = SymmetryGenerator(n, sigma)
        if not sym.commutes_with(tau):
            results["commutation_verified"] = False
            return results
    
    # Step 2: Extract charges
    charges = extract_conserved_charges(n, tau, symmetries)
    for charge in charges:
        results["charges"][charge.source_symmetry] = {
            "values": charge.values,
            "conserved": charge.is_conserved(tau),
            "fixed_points": sorted(reconstruct_fixed_points(charge)),
            "num_fixed": sum(charge.values)
        }
        if not charge.is_conserved(tau):
            results["all_conserved"] = False
    
    # Step 3: Check separation
    results["charges_separate"] = charges_separate(charges)
    
    # Step 4: Noether map
    charge_map = noether_charge_map(n, symmetries, tau)
    results["noether_map_injective"] = is_charge_map_injective(charge_map)
    
    # Step 5: Monoid conservation (if closure provided)
    if cl is not None:
        results["monoid_conservation"] = {}
        for name, sigma in symmetries.items():
            conserved, max_iter = verify_monoid_conservation(
                n, cl, sigma,
                lambda x, s=sigma: int(s[x] == x)
            )
            results["monoid_conservation"][name] = {
                "conserved": conserved,
                "iterations_checked": max_iter
            }
    
    return results


# ─────────────────────────────────────────────────────────────────────
# Main: Run algorithms on example inputs
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("  Idempotent Noether — Algorithm Demonstrations")
    print("=" * 60)
    
    # Example: S₃ symmetries on {0,1,2,3,4,5}
    n = 6
    tau = [1, 0, 3, 2, 5, 4]  # product of transpositions
    
    symmetries = {
        "id":     [0, 1, 2, 3, 4, 5],
        "(01)":   [1, 0, 2, 3, 4, 5],
        "(23)":   [0, 1, 3, 2, 4, 5],
        "(45)":   [0, 1, 2, 3, 5, 4],
        "(01)(23)": [1, 0, 3, 2, 4, 5],
        "(01)(45)": [1, 0, 2, 3, 5, 4],
        "τ":      tau,
    }
    
    # Filter to only commuting symmetries
    commuting = {
        name: sigma for name, sigma in symmetries.items()
        if SymmetryGenerator(n, sigma).commutes_with(tau)
    }
    
    print(f"\n  n = {n}, τ = {tau}")
    print(f"  {len(symmetries)} candidate symmetries, "
          f"{len(commuting)} commute with τ")
    
    results = full_noether_analysis(n, tau, commuting)
    
    print(f"\n  Analysis Results:")
    print(f"  ─────────────────")
    print(f"  Commutation verified: {results['commutation_verified']}")
    print(f"  All charges conserved: {results['all_conserved']}")
    print(f"  Charges separate classes: {results['charges_separate']}")
    print(f"  Noether map injective: {results['noether_map_injective']}")
    
    print(f"\n  Extracted Charges:")
    for name, info in results["charges"].items():
        print(f"    {name:>12}: Q = {info['values']}, "
              f"Fix = {info['fixed_points']}, |Fix| = {info['num_fixed']}, "
              f"conserved = {info['conserved']}")
    
    print(f"\n  ✓ Algorithm completed successfully!")
