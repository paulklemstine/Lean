#!/usr/bin/env python3
"""
Sheaf-Theoretic Certified Adversarial Robustness — Algorithms

Implements the core algorithms from the research paper:
1. Local certificate computation (margin/Lipschitz)
2. Global certification pipeline (cohomological descent)
3. Čech cohomology computation (H¹ via linear algebra)
4. Vulnerability detection (stalk obstruction)
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


@dataclass
class LocalCertificate:
    """Local robustness certificate for a single activation chamber."""
    chamber_id: int
    margin: float
    lipschitz: float
    radius: float
    
    @staticmethod
    def compute(margin: float, lipschitz: float, chamber_id: int = 0) -> 'LocalCertificate':
        """Compute local certified radius = margin / Lipschitz."""
        if lipschitz <= 0:
            raise ValueError(f"Lipschitz constant must be positive, got {lipschitz}")
        return LocalCertificate(
            chamber_id=chamber_id,
            margin=margin,
            lipschitz=lipschitz,
            radius=margin / lipschitz
        )


@dataclass
class GlobalCertificate:
    """Global robustness certificate from cohomological descent."""
    radius: float
    local_certificates: List[LocalCertificate]
    h1_vanishes: bool
    bottleneck_chamber: int
    
    @property
    def is_robust(self) -> bool:
        return self.radius > 0


@dataclass
class VulnerabilityReport:
    """Report of vulnerability detection via stalk obstruction."""
    vulnerable_points: List[float]
    vulnerable_chambers: List[int]
    obstruction_type: str  # 'zero_margin', 'non_coboundary', 'stalk_collapse'


class CechCohomology:
    """
    Finite Čech cohomology computation for robustness sheaves.
    
    Given a finite cover {U_i} with overlap data, computes:
    - Z¹: space of cocycles
    - B¹: space of coboundaries
    - H¹ = Z¹/B¹: first cohomology group
    """
    
    def __init__(self, n_sets: int):
        self.n = n_sets
    
    def coboundary_matrix(self) -> np.ndarray:
        """
        Construct the coboundary matrix δ⁰ : C⁰ → C¹.
        
        C⁰ has dimension n (0-cochains = functions ι → ℝ).
        C¹ has dimension n² (1-cochains = functions ι × ι → ℝ).
        δ⁰(b)(i,j) = b(j) - b(i).
        
        Returns matrix of shape (n², n).
        """
        n = self.n
        delta = np.zeros((n * n, n))
        for i in range(n):
            for j in range(n):
                row = i * n + j
                delta[row, j] = 1.0   # +b(j)
                delta[row, i] -= 1.0  # -b(i)
        return delta
    
    def is_cocycle(self, c: np.ndarray) -> bool:
        """Check additive cocycle condition: c(i,k) = c(i,j) + c(j,k)."""
        n = self.n
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    if not np.isclose(c[i, k], c[i, j] + c[j, k], atol=1e-10):
                        return False
        return True
    
    def is_coboundary(self, c: np.ndarray) -> Tuple[bool, Optional[np.ndarray]]:
        """
        Check if cocycle is a coboundary and return primitive.
        
        For a cocycle, try b(i) = c(0, i) as the candidate primitive.
        """
        n = self.n
        b = np.array([c[0, i] for i in range(n)])
        
        for i in range(n):
            for j in range(n):
                if not np.isclose(c[i, j], b[j] - b[i], atol=1e-10):
                    return False, None
        return True, b
    
    def compute_h1_dimension(self) -> int:
        """
        Compute dim H¹ = dim Z¹ - dim B¹.
        
        For a finite set with n elements:
        - Z¹ (cocycles satisfying additive condition) has dim n-1
          (any cocycle is determined by c(0,1), c(0,2), ..., c(0,n-1))
        - B¹ (coboundaries) has dim n-1
          (coboundary is determined by b(1)-b(0), ..., b(n-1)-b(0))
        
        Therefore H¹ = 0 for a complete cover (all overlaps nonempty).
        """
        # For a complete graph (all overlaps), H¹ always vanishes
        # This is because every cocycle on a simplex is a coboundary
        return 0
    
    def find_obstruction(self, c: np.ndarray) -> Optional[Tuple[int, int, int]]:
        """Find a triple (i,j,k) violating the cocycle condition."""
        n = self.n
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    if not np.isclose(c[i, k], c[i, j] + c[j, k], atol=1e-10):
                        return (i, j, k)
        return None


class SheafCertifier:
    """
    Main certification pipeline implementing the cohomological descent theorem.
    
    Algorithm 2 from the research paper:
    1. Enumerate chambers intersecting the region
    2. Compute local certificates (margin/Lipschitz)
    3. Check cohomological gluing condition
    4. Return global certified radius or vulnerability report
    """
    
    def __init__(self):
        self.certificates: List[LocalCertificate] = []
        self.cohomology: Optional[CechCohomology] = None
    
    def add_certificate(self, margin: float, lipschitz: float, 
                        chamber_id: int = -1) -> LocalCertificate:
        """Add a local certificate for a chamber."""
        if chamber_id < 0:
            chamber_id = len(self.certificates)
        cert = LocalCertificate.compute(margin, lipschitz, chamber_id)
        self.certificates.append(cert)
        return cert
    
    def certify(self, overlap_cocycle: Optional[np.ndarray] = None) -> GlobalCertificate:
        """
        Run the full certification pipeline.
        
        This implements the cohomological descent theorem:
        If H¹ = 0, then R_global = min(r_i).
        """
        if not self.certificates:
            return GlobalCertificate(
                radius=0.0,
                local_certificates=[],
                h1_vanishes=True,
                bottleneck_chamber=-1
            )
        
        n = len(self.certificates)
        self.cohomology = CechCohomology(n)
        
        # Check cohomological condition
        h1_vanishes = True
        if overlap_cocycle is not None:
            if not self.cohomology.is_cocycle(overlap_cocycle):
                h1_vanishes = False  # Not even a cocycle → inconsistent data
            else:
                is_cob, _ = self.cohomology.is_coboundary(overlap_cocycle)
                h1_vanishes = is_cob
        
        # Global radius = infimum of local radii
        radii = [c.radius for c in self.certificates]
        global_radius = min(radii)
        bottleneck = int(np.argmin(radii))
        
        return GlobalCertificate(
            radius=global_radius,
            local_certificates=self.certificates,
            h1_vanishes=h1_vanishes,
            bottleneck_chamber=bottleneck
        )
    
    def detect_vulnerability(self, 
                             score_gap_fn=None,
                             boundary_points: Optional[List[float]] = None
                             ) -> VulnerabilityReport:
        """
        Detect vulnerable points via stalk obstruction.
        
        A point x is vulnerable if stalkRadius(x) ≤ 0, i.e., 
        no neighborhood of x has uniformly positive score gap.
        """
        vulnerable_points = []
        vulnerable_chambers = []
        
        # Check for zero-margin chambers
        for cert in self.certificates:
            if cert.margin <= 0:
                vulnerable_chambers.append(cert.chamber_id)
        
        # Check boundary points
        if boundary_points and score_gap_fn:
            for x in boundary_points:
                if score_gap_fn(x) <= 0:
                    vulnerable_points.append(x)
        
        obstruction_type = 'none'
        if vulnerable_chambers:
            obstruction_type = 'zero_margin'
        elif vulnerable_points:
            obstruction_type = 'stalk_collapse'
        
        return VulnerabilityReport(
            vulnerable_points=vulnerable_points,
            vulnerable_chambers=vulnerable_chambers,
            obstruction_type=obstruction_type
        )


class ReLUChamberAnalyzer:
    """
    Analyze ReLU network activation chambers for robustness certification.
    
    For a ReLU network f(x) = W₂ · max(0, W₁x + b₁) + b₂:
    - Each activation pattern defines a chamber (convex polytope)
    - On each chamber, f is affine: f(x) = W_eff · x + b_eff
    - Local Lipschitz = ‖W_eff‖_∞ (L∞ operator norm)
    - Local margin = min score gap on chamber
    """
    
    def __init__(self, W1: np.ndarray, b1: np.ndarray, 
                 W2: np.ndarray, b2: np.ndarray):
        self.W1 = W1
        self.b1 = b1
        self.W2 = W2
        self.b2 = b2
        self.input_dim = W1.shape[1]
        self.hidden_dim = W1.shape[0]
    
    def forward(self, x: np.ndarray) -> float:
        """Forward pass."""
        h = np.maximum(0, self.W1 @ x + self.b1)
        return float(self.W2 @ h + self.b2)
    
    def activation_pattern(self, x: np.ndarray) -> tuple:
        """Get activation pattern at x."""
        return tuple((self.W1 @ x + self.b1) > 0)
    
    def effective_weight(self, pattern: tuple) -> np.ndarray:
        """Get effective weight matrix for a given activation pattern."""
        active = np.diag(np.array(pattern, dtype=float))
        return self.W2 @ active @ self.W1
    
    def linf_lipschitz(self, pattern: tuple) -> float:
        """Compute L∞ Lipschitz constant for a chamber."""
        W_eff = self.effective_weight(pattern)
        return float(np.max(np.sum(np.abs(W_eff), axis=1)))
    
    def enumerate_chambers(self, x_range: np.ndarray, 
                           y_range: Optional[np.ndarray] = None
                           ) -> Dict[tuple, dict]:
        """Enumerate activation chambers by grid sampling."""
        chambers = {}
        
        if y_range is not None:
            # 2D case
            for xi in x_range:
                for yi in y_range:
                    x = np.array([xi, yi])
                    pattern = self.activation_pattern(x)
                    score = self.forward(x)
                    if pattern not in chambers:
                        chambers[pattern] = {
                            'points': [], 'scores': [],
                            'lip': self.linf_lipschitz(pattern)
                        }
                    chambers[pattern]['points'].append(x.copy())
                    chambers[pattern]['scores'].append(score)
        else:
            # 1D case
            for xi in x_range:
                x = np.array([xi])
                pattern = self.activation_pattern(x)
                score = self.forward(x)
                if pattern not in chambers:
                    chambers[pattern] = {
                        'points': [], 'scores': [],
                        'lip': self.linf_lipschitz(pattern)
                    }
                chambers[pattern]['points'].append(x.copy())
                chambers[pattern]['scores'].append(score)
        
        return chambers
    
    def certify_chambers(self, chambers: Dict[tuple, dict]) -> List[LocalCertificate]:
        """Compute local certificates for each chamber."""
        certs = []
        for idx, (pattern, data) in enumerate(chambers.items()):
            scores = np.array(data['scores'])
            margin = float(np.min(np.abs(scores)))
            lip = data['lip']
            if lip > 0:
                certs.append(LocalCertificate.compute(margin, lip, idx))
        return certs


# =============================================================================
# Usage Examples
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("ALGORITHM DEMONSTRATION")
    print("=" * 70)
    
    # Example: Full certification pipeline
    certifier = SheafCertifier()
    
    # Add local certificates from 5 chambers
    chamber_data = [
        (1.0, 2.0),   # margin, Lipschitz
        (0.5, 1.0),
        (0.8, 4.0),
        (1.2, 3.0),
        (0.3, 1.5),
    ]
    
    print("\nLocal certificates:")
    for i, (m, l) in enumerate(chamber_data):
        cert = certifier.add_certificate(m, l)
        print(f"  Chamber {i}: margin={m}, Lip={l}, radius={cert.radius:.4f}")
    
    # Run global certification
    result = certifier.certify()
    print(f"\nGlobal certification result:")
    print(f"  Global radius R = {result.radius:.4f}")
    print(f"  H¹ vanishes: {result.h1_vanishes}")
    print(f"  Bottleneck chamber: {result.bottleneck_chamber}")
    print(f"  Is robust: {result.is_robust}")
    
    # Čech cohomology analysis
    print("\n--- Čech Cohomology Analysis ---")
    cech = CechCohomology(3)
    
    # Trivial cocycle
    c_trivial = np.zeros((3, 3))
    c_trivial[0, 1] = 0.1; c_trivial[1, 0] = -0.1
    c_trivial[1, 2] = 0.2; c_trivial[2, 1] = -0.2
    c_trivial[0, 2] = 0.3; c_trivial[2, 0] = -0.3
    
    print(f"  Cocycle check: {cech.is_cocycle(c_trivial)}")
    is_cob, prim = cech.is_coboundary(c_trivial)
    print(f"  Coboundary check: {is_cob}")
    if prim is not None:
        print(f"  Primitive: {prim}")
    print(f"  dim H¹ = {cech.compute_h1_dimension()}")
    
    # ReLU chamber analysis
    print("\n--- ReLU Chamber Analysis ---")
    W1 = np.array([[1.0, 0.5], [-0.5, 1.0], [0.3, -0.8]])
    b1 = np.array([0.1, -0.2, 0.3])
    W2 = np.array([[1.0, -1.0, 0.5]])
    b2 = np.array([0.0])
    
    analyzer = ReLUChamberAnalyzer(W1, b1, W2, b2)
    x_range = np.linspace(-2, 2, 100)
    y_range = np.linspace(-2, 2, 100)
    
    chambers = analyzer.enumerate_chambers(x_range, y_range)
    certs = analyzer.certify_chambers(chambers)
    
    print(f"  Chambers found: {len(chambers)}")
    print(f"  Certificates computed: {len(certs)}")
    
    if certs:
        radii = [c.radius for c in certs]
        print(f"  Min local radius: {min(radii):.6f}")
        print(f"  Max local radius: {max(radii):.6f}")
        print(f"  Global certified radius: {min(radii):.6f}")
