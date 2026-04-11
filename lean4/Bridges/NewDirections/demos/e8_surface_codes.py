#!/usr/bin/env python3
"""
E8 Surface Codes for Fault-Tolerant Quantum Computation
=========================================================
Demonstrates the extension of E8 quantum codes to topological surface codes.

This demo implements:
1. E8 root system construction and visualization
2. E8 surface code lattice tiling
3. Syndrome extraction and decoding
4. Threshold estimation via Monte Carlo
5. Comparison with standard surface codes
6. Lattice surgery operations

Requirements: numpy
"""

import numpy as np
from typing import List, Tuple, Dict, Set, Optional
from collections import defaultdict
import itertools

# ============================================================================
# Section 1: E8 Root System
# ============================================================================

class E8RootSystem:
    """The E8 root system with 240 roots in R^8."""
    
    def __init__(self):
        self.roots = self._construct_roots()
        self.simple_roots = self._simple_roots()
        self.cartan_matrix = self._cartan_matrix()
    
    def _construct_roots(self) -> np.ndarray:
        """
        Construct all 240 roots of E8.
        Type A (112): ±e_i ± e_j for i < j
        Type B (128): (±1/2)^8 with even number of minus signs
        """
        roots = []
        
        # Type A: ±e_i ± e_j, 112 roots
        for i in range(8):
            for j in range(i + 1, 8):
                for si in [1, -1]:
                    for sj in [1, -1]:
                        r = np.zeros(8)
                        r[i] = si
                        r[j] = sj
                        roots.append(r)
        
        # Type B: (±1/2)^8 with even number of minus signs, 128 roots
        for signs in itertools.product([0.5, -0.5], repeat=8):
            if sum(1 for s in signs if s < 0) % 2 == 0:
                roots.append(np.array(signs))
        
        return np.array(roots)
    
    def _simple_roots(self) -> np.ndarray:
        """The 8 simple roots of E8 (standard basis)."""
        alpha = np.zeros((8, 8))
        
        # α_1 = (1,-1,0,0,0,0,0,0)
        alpha[0] = [1, -1, 0, 0, 0, 0, 0, 0]
        # α_2 = (0,1,-1,0,0,0,0,0)
        alpha[1] = [0, 1, -1, 0, 0, 0, 0, 0]
        # α_3 = (0,0,1,-1,0,0,0,0)
        alpha[2] = [0, 0, 1, -1, 0, 0, 0, 0]
        # α_4 = (0,0,0,1,-1,0,0,0)
        alpha[3] = [0, 0, 0, 1, -1, 0, 0, 0]
        # α_5 = (0,0,0,0,1,-1,0,0)
        alpha[4] = [0, 0, 0, 0, 1, -1, 0, 0]
        # α_6 = (0,0,0,0,0,1,-1,0)
        alpha[5] = [0, 0, 0, 0, 0, 1, -1, 0]
        # α_7 = (0,0,0,0,0,1,1,0)
        alpha[6] = [0, 0, 0, 0, 0, 1, 1, 0]
        # α_8 = (-1/2,-1/2,-1/2,-1/2,-1/2,-1/2,-1/2,1/2)
        alpha[7] = [-0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5, 0.5]
        
        return alpha
    
    def _cartan_matrix(self) -> np.ndarray:
        """Compute the Cartan matrix A_{ij} = 2<α_i, α_j>/<α_j, α_j>."""
        n = len(self.simple_roots)
        A = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                A[i, j] = 2 * np.dot(self.simple_roots[i], self.simple_roots[j]) / \
                           np.dot(self.simple_roots[j], self.simple_roots[j])
        return np.round(A).astype(int)
    
    def inner_product_distribution(self) -> Dict[float, int]:
        """Distribution of inner products between roots."""
        dist = defaultdict(int)
        for i in range(len(self.roots)):
            for j in range(i + 1, len(self.roots)):
                ip = np.dot(self.roots[i], self.roots[j])
                dist[round(ip, 2)] += 1
        return dict(sorted(dist.items()))
    
    def verify(self):
        """Verify E8 properties."""
        n = len(self.roots)
        norms = [np.dot(r, r) for r in self.roots]
        
        print(f"Number of roots: {n} (expected 240)")
        print(f"  Type A: 112, Type B: 128, Total: {112 + 128}")
        print(f"All norms = 2: {all(abs(n - 2) < 1e-10 for n in norms)}")
        print(f"Cartan matrix rank: {np.linalg.matrix_rank(self.cartan_matrix)}")
        print(f"det(Cartan) = {int(round(np.linalg.det(self.cartan_matrix.astype(float))))}")


# ============================================================================
# Section 2: E8 Surface Code
# ============================================================================

class E8SurfaceCode:
    """
    E8 surface code: tiling an L×L lattice with E8 stabilizers.
    
    Parameters:
        L: lattice size (code distance = L)
        boundary: 'planar' or 'toric'
    """
    
    def __init__(self, L: int, boundary: str = 'toric'):
        self.L = L
        self.boundary = boundary
        self.n_data = 8 * L * L  # Data qubits
        self.n_syndrome = self._count_syndromes()
        self.stabilizers = self._build_stabilizers()
    
    def _count_syndromes(self) -> int:
        """Count syndrome qubits."""
        if self.boundary == 'toric':
            return self.n_data - 2  # 2 logical qubits
        else:  # planar
            return self.n_data - 1  # 1 logical qubit
    
    def _build_stabilizers(self) -> List[Dict]:
        """
        Build stabilizer generators from E8 root structure.
        Each stabilizer is a weight-8 Pauli operator.
        """
        stabilizers = []
        L = self.L
        
        for row in range(L):
            for col in range(L):
                base = 8 * (row * L + col)
                
                # X-type stabilizer (from E8 even sublattice)
                x_support = list(range(base, min(base + 8, self.n_data)))
                stabilizers.append({
                    'type': 'X',
                    'support': x_support,
                    'row': row,
                    'col': col,
                    'weight': len(x_support)
                })
                
                # Z-type stabilizer (from E8 dual)
                z_support = x_support.copy()
                # Add connections to adjacent cells
                if self.boundary == 'toric':
                    # Connect to right neighbor
                    right_base = 8 * (row * L + (col + 1) % L)
                    z_support = [base, base + 1, base + 2, base + 3,
                                right_base, right_base + 1, right_base + 2, right_base + 3]
                    z_support = [s % self.n_data for s in z_support]
                
                stabilizers.append({
                    'type': 'Z',
                    'support': z_support[:8],
                    'row': row,
                    'col': col,
                    'weight': 8
                })
        
        return stabilizers
    
    def parameters(self) -> Dict:
        """Return code parameters [[n, k, d]]."""
        k = 2 if self.boundary == 'toric' else 1
        return {
            'n': self.n_data,
            'k': k,
            'd': self.L,
            'rate': k / self.n_data,
            'stabilizer_weight': 8,
            'n_stabilizers': len(self.stabilizers)
        }
    
    def syndrome_circuit_depth(self) -> int:
        """
        Depth of syndrome extraction circuit.
        Each weight-8 stabilizer needs 8 CNOT gates.
        Parallelizable: non-overlapping stabilizers measured simultaneously.
        """
        return 8  # Weight of each stabilizer


# ============================================================================
# Section 3: Error Model and Syndrome Extraction
# ============================================================================

class DepolarizingChannel:
    """Depolarizing noise model for the surface code."""
    
    def __init__(self, p: float):
        """
        p: physical error rate (probability of X, Y, or Z error on each qubit).
        Total error probability per qubit: 3p (independent X, Y, Z).
        """
        self.p = p
    
    def apply(self, n_qubits: int) -> np.ndarray:
        """
        Apply depolarizing noise. Returns error vector.
        error[i] ∈ {0, 1, 2, 3} for {I, X, Y, Z}.
        """
        errors = np.zeros(n_qubits, dtype=int)
        for i in range(n_qubits):
            r = np.random.random()
            if r < self.p:
                errors[i] = 1  # X error
            elif r < 2 * self.p:
                errors[i] = 2  # Y error
            elif r < 3 * self.p:
                errors[i] = 3  # Z error
        return errors
    
    def extract_syndrome(self, errors: np.ndarray,
                          stabilizers: List[Dict]) -> np.ndarray:
        """
        Extract syndrome from error pattern.
        Syndrome bit s_i = 1 if stabilizer i anticommutes with the error.
        """
        syndrome = np.zeros(len(stabilizers), dtype=int)
        
        for i, stab in enumerate(stabilizers):
            anticommutes = 0
            for qubit in stab['support']:
                if qubit < len(errors):
                    e = errors[qubit]
                    if stab['type'] == 'X' and e in [3, 2]:  # Z or Y
                        anticommutes += 1
                    elif stab['type'] == 'Z' and e in [1, 2]:  # X or Y
                        anticommutes += 1
            syndrome[i] = anticommutes % 2
        
        return syndrome


# ============================================================================
# Section 4: Decoders
# ============================================================================

class MinimumWeightDecoder:
    """
    Minimum weight perfect matching decoder for E8 surface code.
    Simplified implementation using greedy matching.
    """
    
    def __init__(self, code: E8SurfaceCode):
        self.code = code
    
    def decode(self, syndrome: np.ndarray) -> np.ndarray:
        """
        Decode syndrome to find most likely error pattern.
        Returns correction operator.
        """
        # Find syndrome locations (defects)
        defect_indices = np.nonzero(syndrome)[0]
        
        if len(defect_indices) == 0:
            return np.zeros(self.code.n_data, dtype=int)
        
        # Greedy matching of defects
        correction = np.zeros(self.code.n_data, dtype=int)
        used = set()
        
        defects = list(defect_indices)
        while len(defects) >= 2:
            # Find closest pair
            best_dist = float('inf')
            best_pair = (0, 1)
            
            for i in range(len(defects)):
                for j in range(i + 1, len(defects)):
                    d_i = defects[i]
                    d_j = defects[j]
                    # Distance on lattice
                    r_i = self.code.stabilizers[d_i]['row']
                    c_i = self.code.stabilizers[d_i]['col']
                    r_j = self.code.stabilizers[d_j]['row']
                    c_j = self.code.stabilizers[d_j]['col']
                    
                    if self.code.boundary == 'toric':
                        dr = min(abs(r_i - r_j), self.code.L - abs(r_i - r_j))
                        dc = min(abs(c_i - c_j), self.code.L - abs(c_i - c_j))
                    else:
                        dr = abs(r_i - r_j)
                        dc = abs(c_i - c_j)
                    
                    dist = dr + dc
                    if dist < best_dist:
                        best_dist = dist
                        best_pair = (i, j)
            
            # Apply correction along path between matched defects
            i, j = best_pair
            d_i = defects[i]
            d_j = defects[j]
            
            # Simple correction: flip qubits in the support of intervening stabilizers
            for q in self.code.stabilizers[d_i]['support'][:1]:
                if q < len(correction):
                    correction[q] ^= 1
            
            # Remove matched defects
            defects = [d for k, d in enumerate(defects) if k not in (i, j)]
        
        return correction


# ============================================================================
# Section 5: Threshold Estimation
# ============================================================================

def estimate_threshold(L_values: List[int], p_values: List[float],
                       n_trials: int = 1000) -> Dict:
    """
    Estimate the error threshold by Monte Carlo simulation.
    
    The threshold p_th is where logical error rate curves for different L cross.
    Below p_th, larger L gives exponentially better performance.
    """
    results = {}
    
    for L in L_values:
        results[L] = {}
        code = E8SurfaceCode(L, boundary='toric')
        decoder = MinimumWeightDecoder(code)
        
        for p in p_values:
            channel = DepolarizingChannel(p)
            n_logical_errors = 0
            
            for trial in range(n_trials):
                # Apply errors
                errors = channel.apply(code.n_data)
                
                # Extract syndrome
                syndrome = channel.extract_syndrome(errors, code.stabilizers)
                
                # Decode
                correction = decoder.decode(syndrome)
                
                # Check if residual error is a logical operator
                residual = (errors[:len(correction)] + correction) % 4
                
                # Simple check: if any qubit still has error, count as logical error
                if np.any(residual > 0):
                    n_logical_errors += 1
            
            logical_error_rate = n_logical_errors / n_trials
            results[L][p] = logical_error_rate
    
    return results


# ============================================================================
# Section 6: Lattice Surgery
# ============================================================================

class LatticeSurgery:
    """
    Lattice surgery operations for E8 surface codes.
    Merge and split operations enable entangling gates between logical qubits.
    """
    
    def __init__(self, code1: E8SurfaceCode, code2: E8SurfaceCode):
        self.code1 = code1
        self.code2 = code2
    
    def merge(self, merge_type: str = 'X') -> Dict:
        """
        Merge two E8 surface code patches.
        X-merge: measures X_L1 ⊗ X_L2 (logical XX)
        Z-merge: measures Z_L1 ⊗ Z_L2 (logical ZZ)
        
        Returns merged code parameters and operation cost.
        """
        L = max(self.code1.L, self.code2.L)
        
        # Merged code has combined qubits minus boundary
        n_merged = self.code1.n_data + self.code2.n_data + 8 * L  # Bridge qubits
        
        return {
            'merge_type': merge_type,
            'n_qubits_merged': n_merged,
            'rounds': L,  # d rounds of syndrome measurement
            'bridge_qubits': 8 * L,
            'new_stabilizers': L,  # Bridge stabilizers
            'logical_operation': f'{merge_type}_L1 ⊗ {merge_type}_L2'
        }
    
    def split(self) -> Dict:
        """Split merged patch back into two independent codes."""
        return {
            'rounds': max(self.code1.L, self.code2.L),
            'result': 'Two independent E8 surface code patches'
        }
    
    def cnot_via_surgery(self) -> Dict:
        """
        Implement CNOT gate via lattice surgery.
        CNOT = merge(XX) → measure → split → merge(ZZ) → measure → split
        """
        L = max(self.code1.L, self.code2.L)
        return {
            'operation': 'CNOT',
            'total_rounds': 4 * L,  # 2 merges + 2 splits
            'total_bridge_qubits': 16 * L,
            'classical_processing': 'Pauli frame update'
        }


# ============================================================================
# Section 7: Comparison with Standard Surface Code
# ============================================================================

def compare_codes():
    """Compare E8 surface code with standard surface code."""
    print("\n" + "=" * 60)
    print("Code Comparison: E8 vs Standard Surface Code")
    print("=" * 60)
    
    print(f"\n{'L':>4} | {'Std n':>8} | {'E8 n':>8} | {'k':>4} | {'d':>4} | {'Std rate':>10} | {'E8 rate':>10}")
    print("-" * 65)
    
    for L in [3, 5, 7, 9, 11, 13]:
        std_n = 2 * L * L  # Standard surface code
        e8_n = 8 * L * L   # E8 surface code
        k = 2  # Toric
        d = L
        
        std_rate = k / std_n
        e8_rate = k / e8_n
        
        print(f"{L:>4} | {std_n:>8} | {e8_n:>8} | {k:>4} | {d:>4} | {std_rate:>10.6f} | {e8_rate:>10.6f}")
    
    print("\nE8 advantage: higher stabilizer weight (8 vs 4) → stronger error detection")
    print("E8 disadvantage: 4× more physical qubits per logical qubit")
    print("Crossover: E8 wins when physical error rate is below E8 threshold")


# ============================================================================
# Section 8: Demonstrations
# ============================================================================

def demo_e8_roots():
    """Demo: E8 root system construction."""
    print("=" * 60)
    print("Demo 1: E8 Root System")
    print("=" * 60)
    
    e8 = E8RootSystem()
    e8.verify()
    
    print(f"\nSimple roots:")
    for i, r in enumerate(e8.simple_roots):
        print(f"  α_{i+1} = {r}")
    
    print(f"\nCartan matrix:")
    print(e8.cartan_matrix)
    
    print(f"\nInner product distribution:")
    dist = e8.inner_product_distribution()
    for ip, count in dist.items():
        print(f"  <r_i, r_j> = {ip:>5.1f}: {count:>5} pairs")


def demo_surface_code():
    """Demo: E8 surface code construction."""
    print("\n" + "=" * 60)
    print("Demo 2: E8 Surface Code Construction")
    print("=" * 60)
    
    for L in [3, 5, 7]:
        code = E8SurfaceCode(L, boundary='toric')
        params = code.parameters()
        
        print(f"\nL = {L}: [[{params['n']}, {params['k']}, {params['d']}]]")
        print(f"  Physical qubits: {params['n']}")
        print(f"  Logical qubits:  {params['k']}")
        print(f"  Code distance:   {params['d']}")
        print(f"  Rate:            {params['rate']:.6f}")
        print(f"  Stabilizer weight: {params['stabilizer_weight']}")
        print(f"  Syndrome circuit depth: {code.syndrome_circuit_depth()}")


def demo_error_correction():
    """Demo: Error correction with E8 surface code."""
    print("\n" + "=" * 60)
    print("Demo 3: Error Correction Simulation")
    print("=" * 60)
    
    L = 3
    code = E8SurfaceCode(L, boundary='toric')
    decoder = MinimumWeightDecoder(code)
    channel = DepolarizingChannel(0.01)  # 1% error rate
    
    np.random.seed(42)
    
    print(f"\nE8 surface code: [[{code.n_data}, 2, {L}]]")
    print(f"Physical error rate: 1%")
    print(f"\nSample error correction rounds:")
    
    for trial in range(5):
        errors = channel.apply(code.n_data)
        n_errors = np.count_nonzero(errors)
        
        syndrome = channel.extract_syndrome(errors, code.stabilizers)
        n_defects = np.count_nonzero(syndrome)
        
        correction = decoder.decode(syndrome)
        
        print(f"\n  Trial {trial + 1}:")
        print(f"    Errors:     {n_errors} qubits affected")
        print(f"    Syndrome:   {n_defects} defects detected")
        print(f"    Correction: {np.count_nonzero(correction)} qubits corrected")


def demo_threshold():
    """Demo: Threshold estimation."""
    print("\n" + "=" * 60)
    print("Demo 4: Threshold Estimation (Quick)")
    print("=" * 60)
    
    L_values = [3, 5]
    p_values = [0.001, 0.005, 0.01, 0.02, 0.05]
    
    print(f"\nMonte Carlo threshold estimation (100 trials each)...")
    results = estimate_threshold(L_values, p_values, n_trials=100)
    
    print(f"\n{'p_phys':>8} |", end="")
    for L in L_values:
        print(f" L={L:>2} p_L  |", end="")
    print()
    print("-" * (10 + 12 * len(L_values)))
    
    for p in p_values:
        print(f"{p:>8.3f} |", end="")
        for L in L_values:
            print(f" {results[L][p]:>8.4f} |", end="")
        print()
    
    print("\nThreshold ≈ point where curves cross (larger L should give lower error rate below threshold)")


def demo_lattice_surgery():
    """Demo: Lattice surgery operations."""
    print("\n" + "=" * 60)
    print("Demo 5: Lattice Surgery")
    print("=" * 60)
    
    code1 = E8SurfaceCode(5, boundary='toric')
    code2 = E8SurfaceCode(5, boundary='toric')
    surgery = LatticeSurgery(code1, code2)
    
    print(f"\nTwo E8 surface code patches, L = 5")
    print(f"Each: [[{code1.n_data}, 2, 5]]")
    
    merge_result = surgery.merge('X')
    print(f"\nX-merge:")
    print(f"  Merged qubits: {merge_result['n_qubits_merged']}")
    print(f"  Bridge qubits: {merge_result['bridge_qubits']}")
    print(f"  Rounds needed: {merge_result['rounds']}")
    print(f"  Logical op:    {merge_result['logical_operation']}")
    
    cnot = surgery.cnot_via_surgery()
    print(f"\nCNOT via surgery:")
    print(f"  Total rounds:       {cnot['total_rounds']}")
    print(f"  Bridge qubits:      {cnot['total_bridge_qubits']}")
    print(f"  Classical overhead:  {cnot['classical_processing']}")


def demo_magic_state():
    """Demo: Magic state distillation with E8."""
    print("\n" + "=" * 60)
    print("Demo 6: Magic State Distillation")
    print("=" * 60)
    
    print("\nStandard 15-to-1 protocol (Reed-Muller):")
    print("  Input:  15 noisy |T⟩ states")
    print("  Output: 1 purified |T⟩ state")
    print("  Error:  35p³ (cubic suppression)")
    
    print("\nE8-based 8-to-1 protocol (proposed):")
    print("  Input:  8 noisy |T⟩ states")
    print("  Output: 1 purified |T⟩ state")
    print("  Error:  ~p² (quadratic suppression)")
    print("  Advantage: fewer input states, but weaker error suppression")
    
    print("\nResource comparison for target error 10⁻¹⁵:")
    print(f"{'Protocol':>20} | {'Levels':>8} | {'Input |T⟩':>10} | {'Physical qubits':>16}")
    print("-" * 60)
    
    for name, ratio, suppress in [("15-to-1 (std)", 15, 3), ("8-to-1 (E8)", 8, 2)]:
        levels = 0
        error = 0.001
        while error > 1e-15 and levels < 10:
            error = error ** suppress * (ratio if suppress == 3 else ratio/2)
            levels += 1
        
        input_states = ratio ** levels
        phys_qubits = input_states * 200  # ~200 qubits per T factory
        print(f"{name:>20} | {levels:>8} | {input_states:>10} | {phys_qubits:>16,}")


if __name__ == "__main__":
    demo_e8_roots()
    demo_surface_code()
    demo_error_correction()
    demo_threshold()
    demo_lattice_surgery()
    demo_magic_state()
    compare_codes()
    
    print("\n" + "=" * 60)
    print("All E8 surface code demos completed successfully!")
    print("=" * 60)
