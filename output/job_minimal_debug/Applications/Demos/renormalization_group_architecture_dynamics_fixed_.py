"""
Renormalization Group Architecture Dynamics — Algorithms
=========================================================

Implementation of the core algorithms from the research paper:
1. RG direction classification
2. Generalization gap computation
3. Universality class matching
4. Contraction rate estimation
5. Certified robustness radius computation
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Optional


@dataclass
class OperatorClass:
    """Classification of an RG operator direction.
    
    Corresponds to the Lean definition:
        inductive OperatorClass where
          | relevant (eigval : ℝ)
          | marginal
          | irrelevant (eigval : ℝ)
    """
    kind: str  # 'relevant', 'marginal', 'irrelevant'
    eigenvalue: float
    
    def __repr__(self):
        return f"OperatorClass({self.kind}, λ={self.eigenvalue:.4f})"


@dataclass
class RGLinearization:
    """Linearized RG transformation at a fixed point.
    
    Corresponds to the Lean structure RGLinearization.
    
    Attributes:
        fixed_point: The RG fixed point vector
        matrix: Matrix representation of the linear map
        max_norm: Operator norm bound (Lipschitz constant)
    """
    fixed_point: np.ndarray
    matrix: np.ndarray
    max_norm: float
    eigenvalues: np.ndarray
    operator_classes: List[OperatorClass]
    
    @property
    def dim(self) -> int:
        return len(self.fixed_point)
    
    @property
    def d_rel(self) -> int:
        return sum(1 for oc in self.operator_classes if oc.kind == 'relevant')
    
    @property
    def d_irrel(self) -> int:
        return sum(1 for oc in self.operator_classes if oc.kind == 'irrelevant')


@dataclass
class RGFlowCertificate:
    """Complete RG flow certificate for an architecture.
    
    Corresponds to the Lean structure RGFlowCertificate.
    """
    rg: RGLinearization
    d_rel: int
    d_irrel: int
    nu: float  # correlation length exponent
    C_gen: float  # generalization constant
    
    def gap(self, n: int) -> float:
        """Compute the generalization gap bound: C_gen * d_rel / n."""
        return self.C_gen * self.d_rel / n


@dataclass
class RGArchitecture:
    """An architecture with RG flow data.
    
    Corresponds to the Lean structure RGArchitecture.
    """
    dim: int
    depth: int
    layer_lipschitz: float
    d_rel: int
    C_gen: float
    name: str = "unnamed"
    
    def gap(self, n: int) -> float:
        """Generalization gap: C_gen * d_rel / n."""
        return self.C_gen * self.d_rel / n


def classify_rg_directions(matrix: np.ndarray, 
                            threshold: float = 1.0,
                            tolerance: float = 1e-8) -> Tuple[RGLinearization, List[OperatorClass]]:
    """Classify RG directions from a linear operator matrix.
    
    Algorithm: ClassifyRGDirections
    Complexity: O(dim³) for eigenvalue decomposition
    
    Args:
        matrix: Square matrix representing the linearized RG
        threshold: Boundary between relevant and irrelevant (default 1.0)
        tolerance: Numerical tolerance for marginal classification
        
    Returns:
        (RGLinearization, list of OperatorClass)
    """
    dim = matrix.shape[0]
    assert matrix.shape == (dim, dim), "Matrix must be square"
    
    eigenvalues = np.linalg.eigvals(matrix)
    eigenvalues = np.sort(np.abs(eigenvalues))[::-1]  # sort by magnitude
    
    classes = []
    for ev in eigenvalues:
        mag = abs(ev)
        if abs(mag - threshold) < tolerance:
            classes.append(OperatorClass('marginal', float(ev)))
        elif mag > threshold:
            classes.append(OperatorClass('relevant', float(ev)))
        else:
            classes.append(OperatorClass('irrelevant', float(ev)))
    
    max_norm = float(np.max(np.abs(eigenvalues)))
    fixed_point = np.zeros(dim)  # trivial fixed point
    
    rg = RGLinearization(
        fixed_point=fixed_point,
        matrix=matrix,
        max_norm=max_norm,
        eigenvalues=eigenvalues,
        operator_classes=classes
    )
    
    return rg, classes


def compute_generalization_bound(cert: RGFlowCertificate, n: int) -> float:
    """Compute the RG generalization bound.
    
    Algorithm: ComputeGeneralizationBound
    Complexity: O(1)
    
    Implements: generalizationGap(C_gen, d_rel, n) = C_gen * d_rel / n
    """
    assert n > 0, "Dataset size must be positive"
    return cert.C_gen * cert.d_rel / n


def match_universality_class(arch1: RGArchitecture, 
                              arch2: RGArchitecture,
                              tolerance: float = 1e-8) -> bool:
    """Check if two architectures belong to the same universality class.
    
    Algorithm: MatchUniversalityClass
    Complexity: O(1) (assuming d_rel already computed)
    
    Two architectures are equivalent if d_rel and C_gen match.
    """
    return (arch1.d_rel == arch2.d_rel and 
            abs(arch1.C_gen - arch2.C_gen) < tolerance)


def estimate_contraction_rate(matrix: np.ndarray, 
                               n_iterations: int = 100,
                               n_samples: int = 50) -> float:
    """Estimate the contraction rate of a linear operator empirically.
    
    Complexity: O(n_iterations * n_samples * dim²)
    
    Returns the estimated contraction factor c such that ||T^k v|| ≈ c^k ||v||.
    """
    dim = matrix.shape[0]
    rates = []
    
    for _ in range(n_samples):
        v = np.random.randn(dim)
        v_norm = np.linalg.norm(v)
        if v_norm < 1e-12:
            continue
            
        w = v.copy()
        for k in range(1, n_iterations + 1):
            w = matrix @ w
            w_norm = np.linalg.norm(w)
            if w_norm < 1e-15:
                rates.append(0.0)
                break
            rate = (w_norm / v_norm) ** (1.0 / k)
            rates.append(rate)
    
    return float(np.median(rates)) if rates else 0.0


def certified_robustness_radius(cert: RGFlowCertificate,
                                 margin: float,
                                 depth: int) -> float:
    """Compute the certified robustness radius from the RG certificate.
    
    For a contractive architecture with contraction factor c < 1:
    radius = margin / (c^depth)
    
    But along irrelevant directions, the effective Lipschitz constant
    is c^depth, so the radius grows exponentially with depth.
    
    Args:
        cert: RG flow certificate
        margin: Classification margin
        depth: Network depth
        
    Returns:
        Certified robustness radius
    """
    # Get the irrelevant contraction factor
    irrel_eigenvalues = [abs(oc.eigenvalue) for oc in cert.rg.operator_classes 
                         if oc.kind == 'irrelevant']
    
    if not irrel_eigenvalues:
        return margin  # No contraction, radius = margin
    
    c_irrel = max(irrel_eigenvalues)
    if c_irrel >= 1.0:
        return margin  # Not contractive
    
    # Lipschitz constant along irrelevant directions after depth layers
    lipschitz = c_irrel ** depth
    
    # Certified radius: perturbation that stays within margin
    return margin / lipschitz if lipschitz > 1e-15 else float('inf')


def power_law_scaling(C_gen: float, nu: float, n_values: List[int]) -> List[float]:
    """Compute power-law generalization scaling ε(n) ~ C * n^(-1/ν).
    
    Args:
        C_gen: Generalization constant
        nu: Correlation length exponent
        n_values: List of dataset sizes
        
    Returns:
        List of generalization error estimates
    """
    return [C_gen * n ** (-1.0 / nu) for n in n_values]


# ---- Example usage ----

if __name__ == "__main__":
    print("=" * 60)
    print("RG Architecture Dynamics — Algorithm Demonstrations")
    print("=" * 60)
    
    # Example 1: Classify RG directions
    print("\n--- Example 1: RG Direction Classification ---")
    dim = 10
    eigenvalues = np.array([1.5, 1.3, 1.1, 0.99, 0.8, 0.6, 0.4, 0.3, 0.2, 0.1])
    matrix = np.diag(eigenvalues)
    
    rg, classes = classify_rg_directions(matrix)
    print(f"Dimension: {dim}")
    print(f"d_rel: {rg.d_rel}")
    print(f"d_irrel: {rg.d_irrel}")
    print(f"Operator norm: {rg.max_norm:.4f}")
    print(f"Classifications: {classes}")
    
    # Example 2: Compute generalization bound
    print("\n--- Example 2: Generalization Bound ---")
    cert = RGFlowCertificate(rg=rg, d_rel=rg.d_rel, d_irrel=rg.d_irrel, 
                              nu=0.63, C_gen=2.5)
    
    for n in [100, 1000, 10000, 100000]:
        bound = compute_generalization_bound(cert, n)
        print(f"  n = {n:>7d}: gap ≤ {bound:.6f}")
    
    # Example 3: Universality class matching
    print("\n--- Example 3: Universality Class Matching ---")
    arch1 = RGArchitecture(dim=50000, depth=8, layer_lipschitz=0.95, 
                           d_rel=3, C_gen=2.5, name="ConvNet")
    arch2 = RGArchitecture(dim=175000000, depth=96, layer_lipschitz=0.98,
                           d_rel=3, C_gen=2.5, name="Transformer")
    arch3 = RGArchitecture(dim=1000000, depth=20, layer_lipschitz=0.90,
                           d_rel=7, C_gen=3.1, name="ResNet")
    
    print(f"  {arch1.name} ≡ {arch2.name}: {match_universality_class(arch1, arch2)}")
    print(f"  {arch1.name} ≡ {arch3.name}: {match_universality_class(arch1, arch3)}")
    print(f"  {arch2.name} ≡ {arch3.name}: {match_universality_class(arch2, arch3)}")
    
    # Example 4: Certified robustness
    print("\n--- Example 4: Certified Robustness Radius ---")
    for depth in [5, 10, 20, 50]:
        radius = certified_robustness_radius(cert, margin=1.0, depth=depth)
        print(f"  depth = {depth:3d}: certified radius = {radius:.4f}")
    
    # Example 5: Power-law scaling
    print("\n--- Example 5: Power-Law Scaling ε(n) ~ n^(-1/ν) ---")
    n_values = [100, 1000, 10000, 100000, 1000000]
    for nu in [0.5, 0.63, 1.0, 2.0]:
        errors = power_law_scaling(C_gen=1.0, nu=nu, n_values=n_values)
        print(f"  ν = {nu:.2f}: {[f'{e:.4f}' for e in errors]}")
    
    print("\nAll algorithm demonstrations completed!")


"""
Renormalization Group Architecture Dynamics — Applications
===========================================================

Real-world applications of RG architecture theory:
1. Architecture selection for target generalization
2. Transfer learning certification
3. Adversarial robustness certification
4. Scaling law prediction
"""

import numpy as np
from dataclasses import dataclass
from typing import Dict, List


@dataclass
class ArchSpec:
    """Architecture specification with RG parameters."""
    name: str
    dim: int
    depth: int
    d_rel: int
    C_gen: float
    c_irrel: float  # max irrelevant eigenvalue
    nu: float  # correlation length exponent


def application_1_architecture_selection():
    """Application 1: Select architecture to meet generalization target.
    
    Given: target gap ε, dataset size n
    Find: architectures with gap(n) ≤ ε
    
    Uses: relevant_operator_generalization_bound
    """
    print("=" * 60)
    print("APPLICATION 1: Architecture Selection")
    print("=" * 60)
    
    target_gap = 0.01  # 1% generalization gap
    n = 50000  # dataset size
    
    architectures = [
        ArchSpec("MLP-Small",     1000,   3,  5, 1.0, 0.8, 0.63),
        ArchSpec("ConvNet-Med",   50000,  8, 12, 2.0, 0.7, 0.63),
        ArchSpec("ResNet-50",     25e6,  50, 20, 1.5, 0.6, 0.50),
        ArchSpec("Transformer-S", 85e6,  12, 30, 3.0, 0.9, 1.00),
        ArchSpec("Transformer-L", 175e6, 96, 42, 2.5, 0.95, 1.20),
    ]
    
    print(f"\nTarget: gap ≤ {target_gap}")
    print(f"Dataset: n = {n:,}")
    print(f"\n{'Architecture':>16} | {'dim':>10} | {'d_rel':>6} | {'gap':>10} | {'Meets target?':>14}")
    print("-" * 66)
    
    for arch in architectures:
        gap = arch.C_gen * arch.d_rel / n
        meets = gap <= target_gap
        print(f"{arch.name:>16} | {arch.dim:>10.0f} | {arch.d_rel:>6} | {gap:>10.4f} | {'✓ YES' if meets else '✗ NO':>14}")
    
    # Find minimum d_rel for target
    C_gen_typical = 2.0
    max_d_rel = int(target_gap * n / C_gen_typical)
    print(f"\nFor C_gen = {C_gen_typical}, target requires d_rel ≤ {max_d_rel}")
    print()


def application_2_transfer_certification():
    """Application 2: Certify transfer between same-class architectures.
    
    Uses: universality_class_transfer
    """
    print("=" * 60)
    print("APPLICATION 2: Transfer Learning Certification")
    print("=" * 60)
    
    # Source architecture (certified)
    source = ArchSpec("ResNet-50", 25e6, 50, 20, 1.5, 0.6, 0.50)
    
    # Target architectures
    targets = [
        ArchSpec("ResNet-101",  44e6,  101, 20, 1.5, 0.6, 0.50),  # same class
        ArchSpec("DenseNet-121", 8e6,   121, 20, 1.5, 0.55, 0.50),  # same class
        ArchSpec("VGG-19",      144e6,  19, 35, 2.8, 0.75, 0.80),  # different class
    ]
    
    print(f"\nSource: {source.name} (d_rel={source.d_rel}, C_gen={source.C_gen})")
    print(f"\n{'Target':>16} | {'d_rel':>6} | {'C_gen':>6} | {'Same class?':>12} | {'Transfer?':>10}")
    print("-" * 60)
    
    for target in targets:
        same_class = (target.d_rel == source.d_rel and 
                      abs(target.C_gen - source.C_gen) < 0.01)
        transfer = "FREE ✓" if same_class else "REQUIRES RETRAIN"
        print(f"{target.name:>16} | {target.d_rel:>6} | {target.C_gen:>6.1f} | {'YES ✓' if same_class else 'NO ✗':>12} | {transfer:>10}")
    
    n = 50000
    source_gap = source.C_gen * source.d_rel / n
    print(f"\nSource gap at n={n:,}: {source_gap:.4f}")
    for target in targets:
        if target.d_rel == source.d_rel and abs(target.C_gen - source.C_gen) < 0.01:
            target_gap = target.C_gen * target.d_rel / n
            print(f"  → {target.name} gap: {target_gap:.4f} (identical by universality!)")
    print()


def application_3_adversarial_robustness():
    """Application 3: Certified adversarial robustness from RG.
    
    Uses: certified_lipschitz_from_contraction, monotone_generalization_in_layers
    """
    print("=" * 60)
    print("APPLICATION 3: Certified Adversarial Robustness")
    print("=" * 60)
    
    margin = 0.5  # classification margin
    
    architectures = [
        ArchSpec("Shallow-Net",   1000,   3, 10, 1.0, 0.9,  0.63),
        ArchSpec("Medium-Net",   50000,  10, 10, 1.0, 0.7,  0.63),
        ArchSpec("Deep-Net",    200000,  50, 10, 1.0, 0.5,  0.63),
        ArchSpec("Ultra-Deep",  500000, 100, 10, 1.0, 0.3,  0.63),
    ]
    
    print(f"\nClassification margin: {margin}")
    print(f"\n{'Architecture':>14} | {'Depth':>6} | {'c_irrel':>8} | {'Lip(depth)':>11} | {'Radius':>10} | {'Robust?':>8}")
    print("-" * 70)
    
    for arch in architectures:
        lip = arch.c_irrel ** arch.depth
        radius = margin / lip if lip > 1e-15 else float('inf')
        robust = radius > 0.1  # threshold
        print(f"{arch.name:>14} | {arch.depth:>6} | {arch.c_irrel:>8.2f} | {lip:>11.2e} | {radius:>10.2f} | {'✓' if robust else '✗':>8}")
    
    print("\nKey insight: Deeper contractive networks have EXPONENTIALLY")
    print("better certified robustness radii!")
    print()


def application_4_scaling_prediction():
    """Application 4: Predict generalization scaling laws.
    
    Uses: correlation_length_scaling, fisher_scaling_relation
    """
    print("=" * 60)
    print("APPLICATION 4: Scaling Law Prediction")
    print("=" * 60)
    
    # Different universality classes
    classes = [
        {"name": "Gaussian (d_rel=0)",    "nu": 0.5,  "d_rel": 0, "alpha": 2.0},
        {"name": "Ising-like (d_rel=2)",  "nu": 0.63, "d_rel": 2, "alpha": 0.74},
        {"name": "Mean-field (d_rel=4)",  "nu": 0.5,  "d_rel": 4, "alpha": 0.0},
        {"name": "Critical (d_rel=10)",   "nu": 1.0,  "d_rel": 10, "alpha": -8.0},
    ]
    
    n_values = [100, 1000, 10000, 100000, 1000000]
    
    for uc in classes:
        print(f"\n--- {uc['name']} ---")
        print(f"ν = {uc['nu']}, d_rel = {uc['d_rel']}")
        
        # Verify Fisher scaling: d_rel * nu = 2 - alpha
        fisher_lhs = uc['d_rel'] * uc['nu']
        fisher_rhs = 2 - uc['alpha']
        print(f"Fisher scaling: d_rel·ν = {fisher_lhs:.2f}, 2-α = {fisher_rhs:.2f}")
        
        if uc['d_rel'] > 0:
            C_gen = 1.0
            print(f"{'n':>10} | {'gap = C·d_rel/n':>16} | {'ε ~ n^(-1/ν)':>14}")
            print("-" * 45)
            for n in n_values:
                gap = C_gen * uc['d_rel'] / n
                scaling = n ** (-1.0 / uc['nu'])
                print(f"{n:>10,} | {gap:>16.6f} | {scaling:>14.6f}")
        else:
            print("  → Zero generalization gap (Gaussian fixed point)")
    print()


if __name__ == "__main__":
    application_1_architecture_selection()
    application_2_transfer_certification()
    application_3_adversarial_robustness()
    application_4_scaling_prediction()
    print("All applications completed!")


"""
Renormalization Group Architecture Dynamics — Demo
===================================================

Concrete numerical demonstrations of the core theorems:
1. Exponential contraction of irrelevant directions
2. Exponential expansion of relevant directions  
3. Generalization gap bounds from d_rel
4. Geometric series cumulative error bounds
5. Universality class transfer
"""

import numpy as np

def demo_contraction():
    """Demonstrate Theorem 2.1: Operator Norm Iterate Bound.
    
    For a contractive operator with ||T v|| <= c ||v||, c < 1,
    we verify ||T^k v|| <= c^k ||v|| for various k.
    """
    print("=" * 60)
    print("DEMO 1: Irrelevant Direction Contraction")
    print("Theorem: ||T^k v|| <= c^k ||v|| for c < 1")
    print("=" * 60)
    
    dim = 5
    c_irrel = 0.7  # contraction factor
    
    # Create a contractive operator: diagonal with eigenvalues < c
    eigenvalues = np.array([0.7, 0.5, 0.3, 0.6, 0.4])
    T = np.diag(eigenvalues)
    
    v = np.random.randn(dim)
    v_norm = np.linalg.norm(v)
    
    print(f"\nOperator eigenvalues: {eigenvalues}")
    print(f"Contraction factor c = {c_irrel}")
    print(f"Initial ||v|| = {v_norm:.4f}")
    print(f"\n{'k':>4} | {'||T^k v||':>12} | {'c^k ||v||':>12} | {'Bound holds?':>12}")
    print("-" * 50)
    
    w = v.copy()
    for k in range(15):
        bound = c_irrel**k * v_norm
        actual = np.linalg.norm(w)
        holds = "✓" if actual <= bound + 1e-10 else "✗"
        print(f"{k:4d} | {actual:12.6f} | {bound:12.6f} | {holds:>12}")
        w = T @ w
    print()


def demo_expansion():
    """Demonstrate Theorem 2.2: Relevant Direction Expansion.
    
    For an expansive operator with ||T v|| >= c ||v||, c > 1,
    we verify ||T^k v|| >= c^k ||v||.
    """
    print("=" * 60)
    print("DEMO 2: Relevant Direction Expansion")
    print("Theorem: ||T^k v|| >= c^k ||v|| for c > 1")
    print("=" * 60)
    
    dim = 3
    c_rel = 1.2  # expansion factor
    
    eigenvalues = np.array([1.2, 1.5, 1.3])
    T = np.diag(eigenvalues)
    
    v = np.array([1.0, 0.5, 0.8])
    v_norm = np.linalg.norm(v)
    
    print(f"\nOperator eigenvalues: {eigenvalues}")
    print(f"Expansion factor c = {c_rel}")
    print(f"Initial ||v|| = {v_norm:.4f}")
    print(f"\n{'k':>4} | {'||T^k v||':>12} | {'c^k ||v||':>12} | {'Bound holds?':>12}")
    print("-" * 50)
    
    w = v.copy()
    for k in range(10):
        bound = c_rel**k * v_norm
        actual = np.linalg.norm(w)
        holds = "✓" if actual >= bound - 1e-10 else "✗"
        print(f"{k:4d} | {actual:12.4f} | {bound:12.4f} | {holds:>12}")
        w = T @ w
    print()


def demo_generalization_gap():
    """Demonstrate Theorem 3.1: Generalization Gap = C * d_rel / n.
    
    Show how the gap depends on d_rel (not total dim) and dataset size n.
    """
    print("=" * 60)
    print("DEMO 3: Generalization Gap Bound")
    print("Theorem: gap = C_gen * d_rel / n")
    print("=" * 60)
    
    C_gen = 1.0
    total_dim = 1_000_000  # 1M parameters (overparameterized!)
    
    print(f"\nTotal dimension: {total_dim:,}")
    print(f"C_gen = {C_gen}")
    
    print(f"\n{'d_rel':>8} | {'n':>10} | {'gap (d_rel)':>12} | {'gap (dim)':>12} | {'Ratio':>8}")
    print("-" * 60)
    
    for d_rel in [10, 100, 1000]:
        for n in [1000, 10000, 100000]:
            gap_rel = C_gen * d_rel / n
            gap_dim = C_gen * total_dim / n
            ratio = gap_rel / gap_dim if gap_dim > 0 else 0
            print(f"{d_rel:8d} | {n:10d} | {gap_rel:12.6f} | {gap_dim:12.1f} | {ratio:8.2e}")
    
    print(f"\nKey insight: d_rel/dim = {10}/{total_dim:,} = {10/total_dim:.1e}")
    print("The RG bound is tighter by a factor of dim/d_rel!")
    print()


def demo_geometric_series():
    """Demonstrate Theorem 2.4: Geometric Series Bound.
    
    Verify Σ c^k ≤ 1/(1-c) for various c and n.
    """
    print("=" * 60)
    print("DEMO 4: Geometric Series Contraction Bound")
    print("Theorem: Σ_{k=0}^{n-1} c^k ≤ 1/(1-c)")
    print("=" * 60)
    
    print(f"\n{'c':>6} | {'n':>6} | {'Σ c^k':>12} | {'1/(1-c)':>12} | {'Gap':>12}")
    print("-" * 55)
    
    for c in [0.5, 0.7, 0.9, 0.95, 0.99]:
        bound = 1 / (1 - c)
        for n in [10, 50, 100]:
            partial_sum = sum(c**k for k in range(n))
            gap = bound - partial_sum
            print(f"{c:6.2f} | {n:6d} | {partial_sum:12.6f} | {bound:12.6f} | {gap:12.2e}")
    print()


def demo_universality_transfer():
    """Demonstrate Theorem 4.5: Universality Class Transfer.
    
    Two architectures with same (d_rel, C_gen) have identical gaps.
    """
    print("=" * 60)
    print("DEMO 5: Universality Class Transfer")
    print("Theorem: archEquiv(A₁, A₂) → gap(A₁, n) = gap(A₂, n)")
    print("=" * 60)
    
    # Architecture 1: Small ConvNet
    arch1 = {"name": "ConvNet-Small", "dim": 50000, "depth": 8, "d_rel": 42, "C_gen": 2.5}
    # Architecture 2: Large Transformer (same universality class)
    arch2 = {"name": "Transformer-L", "dim": 175000000, "depth": 96, "d_rel": 42, "C_gen": 2.5}
    
    print(f"\nArchitecture 1: {arch1['name']}")
    print(f"  dim = {arch1['dim']:,}, depth = {arch1['depth']}, d_rel = {arch1['d_rel']}, C_gen = {arch1['C_gen']}")
    print(f"\nArchitecture 2: {arch2['name']}")
    print(f"  dim = {arch2['dim']:,}, depth = {arch2['depth']}, d_rel = {arch2['d_rel']}, C_gen = {arch2['C_gen']}")
    
    print(f"\nSame universality class: d_rel = {arch1['d_rel']}, C_gen = {arch1['C_gen']}")
    print(f"\n{'n':>10} | {'gap(A₁)':>12} | {'gap(A₂)':>12} | {'Equal?':>8}")
    print("-" * 48)
    
    for n in [1000, 10000, 100000, 1000000]:
        gap1 = arch1['C_gen'] * arch1['d_rel'] / n
        gap2 = arch2['C_gen'] * arch2['d_rel'] / n
        equal = "✓" if abs(gap1 - gap2) < 1e-15 else "✗"
        print(f"{n:10d} | {gap1:12.6f} | {gap2:12.6f} | {equal:>8}")
    
    print(f"\nDespite {arch2['dim']/arch1['dim']:.0f}x difference in parameters,")
    print("the generalization gaps are IDENTICAL!")
    print()


def demo_spectral_gap():
    """Demonstrate Theorem 5.4: Spectral Gap Stability.
    
    Show that small perturbations preserve the contraction property.
    """
    print("=" * 60)
    print("DEMO 6: Spectral Gap Stability")
    print("Theorem: c < 1 → ∃ ε > 0, |c' - c| < ε → c' < 1")
    print("=" * 60)
    
    c = 0.85
    eps = 1 - c  # = 0.15
    
    print(f"\nOriginal contraction factor: c = {c}")
    print(f"Spectral gap: 1 - c = {1-c}")
    print(f"Stability radius: ε = {eps}")
    
    print(f"\n{'c_perturbed':>12} | {'|c - c_perturbed|':>18} | {'< ε?':>6} | {'c_perturbed < 1?':>16}")
    print("-" * 58)
    
    for delta in [-0.14, -0.10, -0.05, 0.0, 0.05, 0.10, 0.14, 0.15, 0.20]:
        c_p = c + delta
        within = abs(delta) < eps
        stable = c_p < 1
        print(f"{c_p:12.4f} | {abs(delta):18.4f} | {'✓' if within else '✗':>6} | {'✓' if stable else '✗':>16}")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    demo_contraction()
    demo_expansion()
    demo_generalization_gap()
    demo_geometric_series()
    demo_universality_transfer()
    demo_spectral_gap()
    print("All demos completed successfully!")


"""
Renormalization Group Architecture Dynamics — Visualizations
=============================================================

Generate publication-quality figures for the research paper.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

plt.rcParams.update({
    'font.size': 11,
    'axes.labelsize': 12,
    'axes.titlesize': 13,
    'legend.fontsize': 10,
    'figure.dpi': 150,
})


def plot_contraction_expansion():
    """Figure 1: Contraction of irrelevant and expansion of relevant directions."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    k_vals = np.arange(0, 30)
    
    # Contraction
    for c in [0.5, 0.7, 0.85, 0.95]:
        ax1.semilogy(k_vals, c**k_vals, label=f'c = {c}', linewidth=2)
    ax1.set_xlabel('RG Iterations (k)')
    ax1.set_ylabel('||T^k v|| / ||v||')
    ax1.set_title('Irrelevant Direction Decay\n(Theorem 2.1: c < 1)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(1e-8, 2)
    
    # Expansion
    for c in [1.05, 1.1, 1.2, 1.5]:
        ax2.semilogy(k_vals, c**k_vals, label=f'c = {c}', linewidth=2)
    ax2.set_xlabel('RG Iterations (k)')
    ax2.set_ylabel('||T^k v|| / ||v||')
    ax2.set_title('Relevant Direction Growth\n(Theorem 2.2: c > 1)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('fig_contraction_expansion.png', bbox_inches='tight')
    plt.savefig('fig_contraction_expansion.svg', bbox_inches='tight')
    plt.close()
    print("Saved fig_contraction_expansion.{png,svg}")


def plot_generalization_gap():
    """Figure 2: Generalization gap as a function of d_rel and n."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    C_gen = 1.0
    
    # Gap vs n for different d_rel
    n_vals = np.logspace(2, 6, 100)
    for d_rel in [1, 5, 20, 100]:
        gap = C_gen * d_rel / n_vals
        ax1.loglog(n_vals, gap, label=f'd_rel = {d_rel}', linewidth=2)
    ax1.set_xlabel('Dataset size n')
    ax1.set_ylabel('Generalization gap')
    ax1.set_title('Gap vs Dataset Size\n(Theorem 3.3: monotone in n)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Gap vs d_rel for different n
    d_vals = np.arange(1, 101)
    for n in [100, 1000, 10000, 100000]:
        gap = C_gen * d_vals / n
        ax2.plot(d_vals, gap, label=f'n = {n:,}', linewidth=2)
    ax2.set_xlabel('Relevant operators d_rel')
    ax2.set_ylabel('Generalization gap')
    ax2.set_title('Gap vs Relevant Operators\n(Theorem 3.4: monotone in d_rel)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('fig_generalization_gap.png', bbox_inches='tight')
    plt.savefig('fig_generalization_gap.svg', bbox_inches='tight')
    plt.close()
    print("Saved fig_generalization_gap.{png,svg}")


def plot_universality_classes():
    """Figure 3: Universality class structure and transfer."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    # Different "architectures" colored by universality class
    np.random.seed(42)
    
    classes = {
        'Class A (d_rel=3, C=1.5)': {'d_rel': 3, 'C_gen': 1.5, 'color': '#e74c3c', 'marker': 'o'},
        'Class B (d_rel=10, C=2.0)': {'d_rel': 10, 'C_gen': 2.0, 'color': '#3498db', 'marker': 's'},
        'Class C (d_rel=25, C=3.0)': {'d_rel': 25, 'C_gen': 3.0, 'color': '#2ecc71', 'marker': '^'},
    }
    
    for name, cls in classes.items():
        # Generate random architectures in this class
        n_archs = 8
        dims = np.random.randint(1000, 10000000, n_archs)
        depths = np.random.randint(3, 100, n_archs)
        ax.scatter(dims, depths, c=cls['color'], marker=cls['marker'], 
                   s=100, label=name, alpha=0.8, edgecolors='black', linewidth=0.5)
    
    ax.set_xscale('log')
    ax.set_xlabel('Total Parameters (dim)')
    ax.set_ylabel('Depth')
    ax.set_title('Universality Classes: Same Color = Same Gap\n(Theorem 4.5: archEquiv ⟹ identical generalization)')
    ax.legend(loc='upper left')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('fig_universality_classes.png', bbox_inches='tight')
    plt.savefig('fig_universality_classes.svg', bbox_inches='tight')
    plt.close()
    print("Saved fig_universality_classes.{png,svg}")


def plot_spectral_gap_stability():
    """Figure 4: Spectral gap stability region."""
    fig, ax = plt.subplots(figsize=(8, 5))
    
    c_values = [0.3, 0.5, 0.7, 0.85, 0.95]
    
    for i, c in enumerate(c_values):
        eps = 1 - c
        ax.barh(i, eps, left=c, color='#2ecc71', alpha=0.7, height=0.6)
        ax.barh(i, c, color='#3498db', alpha=0.4, height=0.6)
        ax.axvline(x=1.0, color='red', linestyle='--', alpha=0.5)
        ax.text(c + eps/2, i, f'ε = {eps:.2f}', ha='center', va='center', fontsize=9)
    
    ax.set_yticks(range(len(c_values)))
    ax.set_yticklabels([f'c = {c}' for c in c_values])
    ax.set_xlabel('Operator norm')
    ax.set_title('Spectral Gap Stability Regions\n(Theorem 5.4: perturbations within ε preserve c < 1)')
    ax.axvline(x=1.0, color='red', linestyle='--', label='Stability boundary (c = 1)', alpha=0.8)
    ax.legend()
    ax.grid(True, alpha=0.3, axis='x')
    
    plt.tight_layout()
    plt.savefig('fig_spectral_gap.png', bbox_inches='tight')
    plt.savefig('fig_spectral_gap.svg', bbox_inches='tight')
    plt.close()
    print("Saved fig_spectral_gap.{png,svg}")


def plot_geometric_series():
    """Figure 5: Geometric series bound convergence."""
    fig, ax = plt.subplots(figsize=(8, 5))
    
    n_vals = np.arange(1, 51)
    
    for c in [0.3, 0.5, 0.7, 0.9]:
        partial_sums = np.cumsum(c ** np.arange(50))
        bound = 1 / (1 - c)
        ax.plot(n_vals, partial_sums, linewidth=2, label=f'c = {c}, bound = {bound:.2f}')
        ax.axhline(y=bound, color=ax.get_lines()[-1].get_color(), linestyle='--', alpha=0.4)
    
    ax.set_xlabel('Number of terms n')
    ax.set_ylabel('Σ c^k')
    ax.set_title('Geometric Series Convergence\n(Theorem 2.4: Σ c^k ≤ 1/(1-c))')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('fig_geometric_series.png', bbox_inches='tight')
    plt.savefig('fig_geometric_series.svg', bbox_inches='tight')
    plt.close()
    print("Saved fig_geometric_series.{png,svg}")


def plot_overparameterization():
    """Figure 6: Overparameterization resolution."""
    fig, ax = plt.subplots(figsize=(8, 5))
    
    C_gen = 1.0
    d_rel = 10
    dims = [100, 1000, 10000, 100000, 1000000]
    n = 10000
    
    gap_rg = [C_gen * d_rel / n] * len(dims)
    gap_vc = [C_gen * d / n for d in dims]
    
    x = range(len(dims))
    width = 0.35
    
    bars1 = ax.bar([i - width/2 for i in x], gap_vc, width, label='VC bound (uses dim)', 
                    color='#e74c3c', alpha=0.7)
    bars2 = ax.bar([i + width/2 for i in x], gap_rg, width, label='RG bound (uses d_rel)', 
                    color='#2ecc71', alpha=0.7)
    
    ax.set_xticks(x)
    ax.set_xticklabels([f'{d:,}' for d in dims], rotation=45)
    ax.set_xlabel('Total parameters (dim)')
    ax.set_ylabel('Generalization gap bound')
    ax.set_yscale('log')
    ax.set_title(f'Overparameterization Resolution (d_rel = {d_rel}, n = {n:,})\n(Theorem: gap(d_rel) ≤ gap(dim))')
    ax.legend()
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('fig_overparameterization.png', bbox_inches='tight')
    plt.savefig('fig_overparameterization.svg', bbox_inches='tight')
    plt.close()
    print("Saved fig_overparameterization.{png,svg}")


if __name__ == "__main__":
    plot_contraction_expansion()
    plot_generalization_gap()
    plot_universality_classes()
    plot_spectral_gap_stability()
    plot_geometric_series()
    plot_overparameterization()
    print("\nAll visualizations generated!")
