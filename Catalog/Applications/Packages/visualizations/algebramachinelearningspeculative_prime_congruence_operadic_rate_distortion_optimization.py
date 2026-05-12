"""
Algorithms for Observer-Relative Rate–Distortion Theory

Implements the core computational procedures from the theory:
1. Observer distortion computation
2. Rate–distortion optimization
3. Spectral certificate enumeration
4. Canonical observer code construction
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass


@dataclass
class ObserverFamily:
    """Finite family of equivalence relations on a model space.
    
    Represented as a matrix where entry (i, m) gives the equivalence class
    of model m under observer i.
    
    Attributes:
        class_matrix: np.ndarray of shape (num_observers, num_models)
            Entry (i, m) is the class index of model m under observer i.
    """
    class_matrix: np.ndarray
    
    @property
    def num_observers(self) -> int:
        return self.class_matrix.shape[0]
    
    @property
    def num_models(self) -> int:
        return self.class_matrix.shape[1]
    
    def observe(self, obs_idx: int, model_a: int, model_b: int) -> bool:
        """True if observer considers models equivalent."""
        return self.class_matrix[obs_idx, model_a] == self.class_matrix[obs_idx, model_b]
    
    def distortion_count(self, model_a: int, model_b: int) -> int:
        """Number of observers distinguishing two models.
        
        Time complexity: O(num_observers)
        """
        return int(np.sum(self.class_matrix[:, model_a] != self.class_matrix[:, model_b]))
    
    def distortion_matrix(self) -> np.ndarray:
        """Compute the full distortion matrix.
        
        Time complexity: O(num_models^2 * num_observers)
        
        Returns:
            Symmetric matrix D where D[i,j] = distortion_count(i,j)
        """
        n = self.num_models
        D = np.zeros((n, n), dtype=int)
        for i in range(n):
            for j in range(i + 1, n):
                d = self.distortion_count(i, j)
                D[i, j] = d
                D[j, i] = d
        return D


@dataclass 
class SpectralCertificate:
    """A spectral certificate specifying which observers must agree.
    
    Attributes:
        agreed_observers: frozenset of observer indices where agreement is required
        num_total: total number of observers
    """
    agreed_observers: frozenset
    num_total: int
    
    @property
    def num_disagreed(self) -> int:
        return self.num_total - len(self.agreed_observers)
    
    def is_valid(self, epsilon: int) -> bool:
        """Certificate is valid at threshold epsilon."""
        return self.num_disagreed <= epsilon
    
    def cost(self, O: ObserverFamily, candidates: List[Tuple[int, int]], 
             target: int) -> float:
        """Minimum code length among models realizing this certificate.
        
        Args:
            O: Observer family
            candidates: List of (model_id, code_length) pairs
            target: Target model id
            
        Returns:
            Minimum code length, or infinity if no realizer exists
        """
        best = float('inf')
        for model_id, code_length in candidates:
            # Check if model realizes the certificate
            realizes = all(
                O.observe(i, target, model_id) 
                for i in self.agreed_observers
            )
            if realizes:
                best = min(best, code_length)
        return best


def rate_distortion_optimize(
    O: ObserverFamily,
    candidates: List[Tuple[int, int]],
    target: int,
    epsilon: int
) -> Tuple[Optional[int], Optional[Tuple[int, int]]]:
    """Compute the operadic rate–distortion value and find the minimizer.
    
    Algorithm: Enumerate all candidates, filter by distortion constraint,
    return the one with minimum code length.
    
    Time complexity: O(|candidates| * num_observers)
    
    Args:
        O: Observer family
        candidates: List of (model_id, code_length) pairs
        target: Target model id
        epsilon: Maximum allowed distortion
    
    Returns:
        (optimal_code_length, optimal_candidate) or (None, None) if infeasible
    """
    best_cost = None
    best_candidate = None
    
    for model_id, code_length in candidates:
        dist = O.distortion_count(target, model_id)
        if dist <= epsilon:
            if best_cost is None or code_length < best_cost:
                best_cost = code_length
                best_candidate = (model_id, code_length)
    
    return best_cost, best_candidate


def enumerate_valid_certificates(
    num_observers: int, 
    epsilon: int
) -> List[SpectralCertificate]:
    """Enumerate all valid spectral certificates at threshold epsilon.
    
    A certificate is valid if the number of non-agreed observers ≤ epsilon.
    This means agreed_observers has size ≥ num_observers - epsilon.
    
    Time complexity: O(sum_{k=n-eps}^{n} C(n,k)) where n = num_observers
    
    Args:
        num_observers: Total number of observers
        epsilon: Distortion threshold
        
    Returns:
        List of valid SpectralCertificates
    """
    certs = []
    min_agreed = max(0, num_observers - epsilon)
    
    for size in range(min_agreed, num_observers + 1):
        for agreed in combinations(range(num_observers), size):
            cert = SpectralCertificate(
                agreed_observers=frozenset(agreed),
                num_total=num_observers
            )
            certs.append(cert)
    
    return certs


def prime_congruence_rate_optimize(
    O: ObserverFamily,
    candidates: List[Tuple[int, int]],
    target: int,
    epsilon: int
) -> Tuple[float, Optional[SpectralCertificate]]:
    """Compute the prime-congruence rate via spectral certificate enumeration.
    
    Algorithm: Enumerate all valid certificates, compute the cost of each,
    return the minimum.
    
    Time complexity: O(2^n * |candidates| * n) where n = num_observers
    
    Args:
        O: Observer family
        candidates: List of (model_id, code_length) pairs
        target: Target model id
        epsilon: Distortion threshold
        
    Returns:
        (optimal_cost, optimal_certificate) or (inf, None)
    """
    certs = enumerate_valid_certificates(O.num_observers, epsilon)
    
    best_cost = float('inf')
    best_cert = None
    
    for cert in certs:
        c = cert.cost(O, candidates, target)
        if c < best_cost:
            best_cost = c
            best_cert = cert
    
    return best_cost, best_cert


def canonical_observer_code(
    O: ObserverFamily,
    candidates: List[Tuple[int, int]],
    target: int,
    epsilon: int
) -> Optional[Dict]:
    """Construct the canonical observer code with certified distortion.
    
    Returns a dictionary containing:
    - 'model': the optimal compressed model
    - 'code_length': the code length
    - 'distortion': the actual distortion
    - 'certificate': the induced spectral certificate
    - 'agreed_observers': which observers are preserved
    
    Time complexity: O(|candidates| * num_observers)
    
    Args:
        O: Observer family
        candidates: List of (model_id, code_length) pairs
        target: Target model id
        epsilon: Distortion threshold
        
    Returns:
        Dictionary with code details, or None if infeasible
    """
    opt_cost, opt_candidate = rate_distortion_optimize(O, candidates, target, epsilon)
    
    if opt_candidate is None:
        return None
    
    model_id, code_length = opt_candidate
    
    # Compute the induced spectral certificate
    agreed = frozenset(
        i for i in range(O.num_observers)
        if O.observe(i, target, model_id)
    )
    
    return {
        'model': model_id,
        'code_length': code_length,
        'distortion': O.distortion_count(target, model_id),
        'certificate': SpectralCertificate(agreed, O.num_observers),
        'agreed_observers': sorted(agreed),
        'disagreed_observers': sorted(set(range(O.num_observers)) - agreed),
    }


def verify_duality(
    O: ObserverFamily,
    candidates: List[Tuple[int, int]],
    target: int,
    max_epsilon: Optional[int] = None
) -> List[Dict]:
    """Verify the rate–distortion duality for all thresholds.
    
    For each epsilon from 0 to max_epsilon, compute both the operadic
    rate–distortion and the prime-congruence rate, and verify they are equal
    (when the problem is feasible).
    
    Args:
        O: Observer family
        candidates: List of (model_id, code_length) pairs
        target: Target model id
        max_epsilon: Maximum threshold to check (default: num_observers)
        
    Returns:
        List of dictionaries with results for each epsilon
    """
    if max_epsilon is None:
        max_epsilon = O.num_observers
    
    results = []
    for eps in range(max_epsilon + 1):
        r_op, _ = rate_distortion_optimize(O, candidates, target, eps)
        r_pc, cert = prime_congruence_rate_optimize(O, candidates, target, eps)
        
        # Check feasibility
        feasible = r_op is not None
        
        # Check duality
        if feasible:
            duality_holds = (r_op == r_pc)
        else:
            duality_holds = None  # Not applicable
        
        results.append({
            'epsilon': eps,
            'operadic_rate': r_op if r_op is not None else float('inf'),
            'spectral_rate': r_pc,
            'feasible': feasible,
            'duality_holds': duality_holds,
            'optimal_certificate': cert,
        })
    
    return results


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Create a sample observer family
    # 6 models, 4 observers
    class_matrix = np.array([
        [0, 0, 1, 1, 2, 2],  # Observer 0: 3 classes
        [0, 1, 0, 1, 0, 1],  # Observer 1: 2 classes (even/odd)
        [0, 0, 0, 1, 1, 1],  # Observer 2: 2 classes (first/second half)
        [0, 1, 2, 0, 1, 2],  # Observer 3: 3 classes (mod 3)
    ])
    
    O = ObserverFamily(class_matrix)
    
    # Candidates with varying complexity
    candidates = [(i, i + 1) for i in range(6)]  # cost = model_id + 1
    
    print("Observer-Relative Rate–Distortion: Algorithm Demonstration")
    print("=" * 60)
    
    print(f"\nDistortion matrix:")
    D = O.distortion_matrix()
    print(D)
    
    print(f"\n\nDuality verification (target = model 0):")
    results = verify_duality(O, candidates, target=0)
    
    print(f"\n{'ε':>3} | {'R_op':>6} | {'R_pc':>6} | {'Feasible':>8} | {'Duality':>8}")
    print("-" * 45)
    for r in results:
        r_op = r['operadic_rate'] if r['operadic_rate'] < float('inf') else '∞'
        r_pc = r['spectral_rate'] if r['spectral_rate'] < float('inf') else '∞'
        feas = '✓' if r['feasible'] else '✗'
        dual = '✓' if r['duality_holds'] else ('✗' if r['duality_holds'] is not None else 'N/A')
        print(f"{r['epsilon']:>3} | {r_op:>6} | {r_pc:>6} | {feas:>8} | {dual:>8}")
    
    print(f"\n\nCanonical observer code (target=0, ε=2):")
    code = canonical_observer_code(O, candidates, target=0, epsilon=2)
    if code:
        print(f"  Compressed model: M{code['model']}")
        print(f"  Code length: {code['code_length']}")
        print(f"  Distortion: {code['distortion']}")
        print(f"  Agreed observers: {code['agreed_observers']}")
        print(f"  Disagreed observers: {code['disagreed_observers']}")
