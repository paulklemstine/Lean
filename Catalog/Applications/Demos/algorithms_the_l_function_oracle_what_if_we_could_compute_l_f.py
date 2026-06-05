#!/usr/bin/env python3
"""
Oracle Spectral Algebra — Core Algorithms

Type-hinted implementations of the key algorithms from the
Oracle Spectral Algebra framework.
"""

from dataclasses import dataclass, field
from typing import Callable, List, Tuple, Optional, Dict
from math import gcd, log, ceil


# ============================================================
# Data Structures
# ============================================================

@dataclass
class Jet:
    """A k-jet at a basepoint: stores k derivative values."""
    basepoint: complex
    coeffs: List[complex]
    
    @property
    def depth(self) -> int:
        return len(self.coeffs)
    
    def vanishing_order(self, tol: float = 1e-12) -> int:
        """Compute the vanishing order (index of first nonzero coefficient)."""
        for i, c in enumerate(self.coeffs):
            if abs(c) > tol:
                return i
        return self.depth
    
    def is_nondegenerate(self, tol: float = 1e-12) -> bool:
        """Check if at least one coefficient is nonzero."""
        return any(abs(c) > tol for c in self.coeffs)
    
    @classmethod
    def zero(cls, k: int, s: complex) -> 'Jet':
        """Create the zero jet of depth k."""
        return cls(basepoint=s, coeffs=[0.0] * k)
    
    @classmethod
    def from_function(cls, f: Callable[[complex], complex], s: complex, k: int, 
                      h: float = 1e-8) -> 'Jet':
        """Numerically compute the k-jet of f at s using finite differences."""
        coeffs = []
        for n in range(k):
            # n-th derivative via finite differences
            val = 0.0
            for j in range(n + 1):
                binom = 1
                for i in range(j):
                    binom = binom * (n - i) // (i + 1)
                sign = (-1) ** (n - j)
                val += sign * binom * f(s + j * h)
            val /= h ** n
            coeffs.append(val)
        return cls(basepoint=s, coeffs=coeffs)


@dataclass
class OracleSpectrum:
    """
    Multi-scale fingerprint of an analytic function.
    Captures what an L-function oracle observes.
    """
    critical_value: complex  # f(1), the critical value
    zero_counts: Dict[float, int]  # T -> N(T), zero counts by height
    spectral_weight: int  # arithmetic complexity measure
    
    def product(self, other: 'OracleSpectrum') -> 'OracleSpectrum':
        """
        Product of two spectra (Rankin-Selberg convolution model).
        Zero counts add, spectral weights add.
        """
        all_heights = set(self.zero_counts.keys()) | set(other.zero_counts.keys())
        merged_counts = {
            T: self.zero_counts.get(T, 0) + other.zero_counts.get(T, 0)
            for T in all_heights
        }
        return OracleSpectrum(
            critical_value=self.critical_value * other.critical_value,
            zero_counts=merged_counts,
            spectral_weight=self.spectral_weight + other.spectral_weight,
        )
    
    @classmethod
    def trivial(cls) -> 'OracleSpectrum':
        """The trivial spectrum: no zeros, weight 0."""
        return cls(critical_value=0, zero_counts={}, spectral_weight=0)


@dataclass
class ZeroCertificate:
    """
    A certified list of zeros for a function F in a bounded region.
    """
    zeros: List[complex]
    height_bound: float  # T: the certificate covers |Im(s)| ≤ T
    
    def check_regional_rh(self, tol: float = 1e-10) -> Tuple[bool, List[complex]]:
        """
        Check Regional RH: are all zeros on the critical line Re(s) = 1/2?
        
        Returns (True, []) if all zeros pass, or
                (False, offenders) with the list of violating zeros.
        
        This implements the Zero Certificate Decidability Theorem.
        """
        offenders = []
        for z in self.zeros:
            if 0 < z.real < 1 and abs(z.imag) <= self.height_bound:
                if abs(z.real - 0.5) > tol:
                    offenders.append(z)
        return (len(offenders) == 0, offenders)


# ============================================================
# Algorithm 1: Oracle-Assisted Factoring
# ============================================================

def oracle_factor(n: int, character_oracle: Optional[Callable] = None) -> Tuple[int, int]:
    """
    Factor n = p * q using character-separating invariants.
    
    The Factor Extraction Theorem (Theorem 3.8) guarantees:
    if a is divisible by p but not q, then gcd(a, n) = p.
    
    In practice, the 'character_oracle' would provide character values
    from L-function evaluations. Here we simulate with a simple search.
    
    Args:
        n: The number to factor (assumed to be a semiprime p*q)
        character_oracle: Optional oracle providing separating values
    
    Returns:
        (p, q) where n = p * q
    """
    if character_oracle is not None:
        # Use the oracle to find a separating invariant
        a = character_oracle(n)
        g = gcd(a, n)
        if 1 < g < n:
            return (g, n // g)
    
    # Fallback: trial search for separating invariant
    for a in range(2, n):
        g = gcd(a, n)
        if 1 < g < n:
            return (g, n // g)
    
    raise ValueError(f"Could not factor {n}")


# ============================================================
# Algorithm 2: Vanishing Order Detection
# ============================================================

def detect_vanishing_order(
    derivative_oracle: Callable[[int], complex],
    max_depth: int = 100,
    tol: float = 1e-12
) -> int:
    """
    Detect the vanishing order of a function at a point using
    a derivative oracle.
    
    The Jet Detection Theorem (Theorem 3.2) guarantees:
    if some derivative of order ≤ k is nonzero, the vanishing
    order is at most k.
    
    Args:
        derivative_oracle: f^(n)(s₀) -> complex value
        max_depth: maximum number of derivatives to check
        tol: numerical tolerance for "nonzero"
    
    Returns:
        The vanishing order (index of first nonzero derivative)
    """
    for n in range(max_depth):
        val = derivative_oracle(n)
        if abs(val) > tol:
            return n
    return max_depth  # All derivatives zero up to max_depth


# ============================================================
# Algorithm 3: Regional RH Verification
# ============================================================

def verify_regional_rh(
    certificate: ZeroCertificate,
    tol: float = 1e-10
) -> bool:
    """
    Verify Regional RH using a zero certificate.
    
    The Zero Certificate Decidability Theorem (Theorem 3.7) states:
    Regional RH ↔ all certified zeros have Re(z) = 1/2.
    
    This reduces an infinite verification to a finite check.
    
    Args:
        certificate: ZeroCertificate containing all zeros up to height T
        tol: numerical tolerance for critical line check
    
    Returns:
        True if Regional RH holds, False if a violation is found
    """
    passed, offenders = certificate.check_regional_rh(tol)
    if not passed:
        print(f"  RH VIOLATED: {len(offenders)} zero(s) off critical line")
        for z in offenders:
            print(f"    z = {z}, Re(z) = {z.real:.10f}")
    return passed


# ============================================================
# Algorithm 4: Oracle Filtration Analysis
# ============================================================

@dataclass
class OracleAlgebra:
    """An algebra of functions with oracle-compatible filtration."""
    functions: List[Callable[[complex], complex]]
    names: List[str]
    
    def compute_filtration(self, s: complex, max_depth: int = 10,
                           h: float = 1e-6) -> Dict[int, List[str]]:
        """
        Compute the filtration levels for all functions in the algebra.
        
        F_k = {f | f^(m)(s) = 0 for all m < k}
        
        Returns: {k: [names of functions in F_k]}
        """
        result: Dict[int, List[str]] = {}
        
        for f, name in zip(self.functions, self.names):
            jet = Jet.from_function(f, s, max_depth, h)
            order = jet.vanishing_order()
            for k in range(order + 1):
                if k not in result:
                    result[k] = []
                result[k].append(name)
        
        return result


# ============================================================
# Algorithm 5: Query Complexity Analysis
# ============================================================

def analyze_query_complexity(
    function_class: List[Callable[[complex], complex]],
    point: complex,
    max_queries: int = 20,
    h: float = 1e-6
) -> Dict[str, int]:
    """
    Analyze the query complexity for vanishing order detection.
    
    For each function, determine how many derivative queries are needed
    to detect its vanishing order at the given point.
    
    Returns: {function_index: queries_needed}
    """
    results: Dict[str, int] = {}
    
    for i, f in enumerate(function_class):
        jet = Jet.from_function(f, point, max_queries, h)
        order = jet.vanishing_order()
        queries_needed = order + 1 if order < max_queries else max_queries
        results[f"f_{i}"] = queries_needed
    
    return results


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("Oracle Spectral Algebra — Algorithm Demonstrations")
    print("=" * 50)
    
    # Demo 1: Factoring
    print("\n1. Oracle-Assisted Factoring")
    for n in [15, 77, 221, 1073, 10403]:
        try:
            p, q = oracle_factor(n)
            print(f"   {n} = {p} × {q}")
        except ValueError as e:
            print(f"   {e}")
    
    # Demo 2: Vanishing Order Detection
    print("\n2. Vanishing Order Detection")
    # f(z) = z^4 at z=0: derivatives are 0,0,0,0,24,...
    derivs_z4 = [0, 0, 0, 0, 24, 0, 0]
    oracle_z4 = lambda n: derivs_z4[n] if n < len(derivs_z4) else 0
    print(f"   z^4 at z=0: vanishing order = {detect_vanishing_order(oracle_z4)}")
    
    # f(z) = sin(z) at z=0: derivatives are 0,1,0,-1,...
    import math
    oracle_sin = lambda n: [0, 1, 0, -1][n % 4] if n < 20 else 0
    print(f"   sin(z) at z=0: vanishing order = {detect_vanishing_order(oracle_sin)}")
    
    # Demo 3: Regional RH
    print("\n3. Regional RH Verification")
    cert_pass = ZeroCertificate(
        zeros=[complex(0.5, 14.134), complex(0.5, 21.022), complex(0.5, 25.011)],
        height_bound=30.0
    )
    print(f"   Certificate with on-line zeros: RH = {verify_regional_rh(cert_pass)}")
    
    cert_fail = ZeroCertificate(
        zeros=[complex(0.5, 14.134), complex(0.7, 21.022)],
        height_bound=30.0
    )
    print(f"   Certificate with off-line zero: RH = {verify_regional_rh(cert_fail)}")
    
    # Demo 4: Spectrum Product
    print("\n4. Oracle Spectrum Product")
    s1 = OracleSpectrum(critical_value=0.0, zero_counts={10: 2, 20: 5}, spectral_weight=1)
    s2 = OracleSpectrum(critical_value=1.5, zero_counts={10: 3, 20: 7}, spectral_weight=2)
    prod = s1.product(s2)
    print(f"   S1: weight={s1.spectral_weight}, N(10)={s1.zero_counts[10]}")
    print(f"   S2: weight={s2.spectral_weight}, N(10)={s2.zero_counts[10]}")
    print(f"   S1×S2: weight={prod.spectral_weight}, N(10)={prod.zero_counts[10]}")
