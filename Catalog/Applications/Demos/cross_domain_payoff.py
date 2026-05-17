#!/usr/bin/env python3
"""
Real-World Applications of Tropical Perron–Frobenius Theory

Demonstrates certified throughput analysis for:
1. Manufacturing production lines
2. Processor instruction pipelines
3. Railway timetable optimization
4. Packet-switching network analysis
5. Synchronous dataflow graph analysis
"""

import numpy as np
from algorithms import (
    trop_mat_vec, karp_max_cycle_mean, howard_policy_iteration,
    collatz_wielandt_certify, throughput_analysis, TropicalEigenpair
)


def application_manufacturing():
    """
    Application 1: Automotive Manufacturing Line
    
    A car assembly line with 4 stations:
    - Body welding (Station 1)
    - Painting (Station 2)
    - Engine installation (Station 3)
    - Final assembly (Station 4)
    
    Each station has processing time and transfer delays.
    """
    print("=" * 60)
    print("APPLICATION 1: Automotive Manufacturing Line")
    print("=" * 60)
    print()
    
    stations = ["Body Welding", "Painting", "Engine Install", "Final Assembly"]
    
    # A[i][j] = time for station i to receive input from station j
    # Diagonal = self-processing time
    # Off-diagonal = transfer + synchronization delay
    A = np.array([
        [5,  0,  0,  2],   # Welding: 5 min self, 2 min from final (new chassis)
        [8,  7,  0,  0],   # Painting: 8 min from welding, 7 min self
        [0,  3, 10,  0],   # Engine: 3 min from painting, 10 min self
        [0,  0,  6,  4],   # Final: 6 min from engine, 4 min self
    ], dtype=float)
    
    print("Timing matrix (minutes):")
    for i, name in enumerate(stations):
        print(f"  {name:>16s}: {A[i]}")
    print()
    
    result = throughput_analysis(A, stations)
    
    print(f"Cycle time (max cycle mean): {result['eigenvalue']:.2f} minutes")
    print(f"Throughput: {result['throughput']:.4f} cars/minute")
    print(f"           = {result['throughput'] * 60:.2f} cars/hour")
    print(f"           = {result['throughput'] * 60 * 8:.1f} cars/8-hour shift")
    print()
    
    ep = result['eigenpair']
    print("Phase offsets (eigenvector):")
    for i, name in enumerate(stations):
        print(f"  {name:>16s}: {ep.eigenvector[i]:+.2f} min relative to cycle start")
    print()
    
    cert = result['certificate']
    print(f"Collatz–Wielandt certification:")
    print(f"  Cycle time ∈ [{cert.lower_bound:.2f}, {cert.upper_bound:.2f}] min")
    print(f"  Certificate gap: {cert.gap:.2e} min")
    print(f"  Eigenpair verified: {result['verified']}")
    print()


def application_processor_pipeline():
    """
    Application 2: Superscalar Processor Pipeline
    
    A simplified model of an out-of-order processor:
    - Fetch unit
    - Decode unit
    - Issue/Execute unit
    - Memory unit
    - Retire/Commit unit
    
    Dependencies model data hazards and resource conflicts.
    """
    print("=" * 60)
    print("APPLICATION 2: Superscalar Processor Pipeline")
    print("=" * 60)
    print()
    
    stages = ["Fetch", "Decode", "Execute", "Memory", "Commit"]
    
    # Cycle counts for each pipeline dependency
    A = np.array([
        [1, 0, 0, 0, 1],   # Fetch: 1 cycle self, 1 from commit (branch resolution)
        [2, 1, 0, 0, 0],   # Decode: 2 from fetch (alignment), 1 self
        [0, 3, 2, 0, 0],   # Execute: 3 from decode (scheduling), 2 self
        [0, 0, 4, 1, 0],   # Memory: 4 from execute (cache access), 1 self
        [0, 0, 0, 2, 1],   # Commit: 2 from memory, 1 self
    ], dtype=float)
    
    print("Pipeline timing matrix (clock cycles):")
    for i, name in enumerate(stages):
        print(f"  {name:>10s}: {A[i]}")
    print()
    
    result = throughput_analysis(A, stages)
    
    print(f"Critical path cycle time: {result['eigenvalue']:.2f} cycles")
    print(f"IPC (instructions per cycle): {result['throughput']:.4f}")
    print()
    
    ep = result['eigenpair']
    print("Pipeline stage phases:")
    for i, name in enumerate(stages):
        print(f"  {name:>10s}: phase = {ep.eigenvector[i]:+.2f} cycles")
    print()
    
    # Show bottleneck
    crit = result['critical_graph']
    print(f"Critical edges (bottlenecks):")
    for i, j in crit['edges']:
        print(f"  {stages[i]} ← {stages[j]} ({A[i,j]:.0f} cycles)")
    print()


def application_railway():
    """
    Application 3: Railway Timetable Analysis
    
    A circular railway line with 4 stations.
    Travel times between consecutive stations vary.
    """
    print("=" * 60)
    print("APPLICATION 3: Railway Timetable (Circular Line)")
    print("=" * 60)
    print()
    
    stations = ["Central", "North", "East", "South"]
    
    # A[i][j] = minimum time from station j departure to station i readiness
    # Including: travel time + dwell time + turnaround
    A = np.array([
        [10,  0,  0, 25],   # Central: 10 min turnaround, 25 from South
        [15, 10,  0,  0],   # North: 15 from Central, 10 turnaround
        [ 0, 20, 10,  0],   # East: 20 from North, 10 turnaround
        [ 0,  0, 18, 10],   # South: 18 from East, 10 turnaround
    ], dtype=float)
    
    print("Station timing matrix (minutes):")
    for i, name in enumerate(stations):
        print(f"  {name:>10s}: {A[i]}")
    print()
    
    result = throughput_analysis(A, stations)
    
    cycle_time = result['eigenvalue']
    print(f"Minimum headway (cycle time): {cycle_time:.1f} minutes")
    print(f"Service frequency: {60/cycle_time:.2f} trains/hour")
    print()
    
    ep = result['eigenpair']
    print("Optimal timetable offsets:")
    for i, name in enumerate(stations):
        offset = ep.eigenvector[i]
        print(f"  {name:>10s}: depart at t₀ + {offset:.1f} min (mod {cycle_time:.1f})")
    print()
    
    # Show all cycles
    if result['all_cycles']:
        print("All circuit timings:")
        for c in result['all_cycles'][:6]:
            route = " → ".join(stations[v] for v in c.vertices) + f" → {stations[c.vertices[0]]}"
            print(f"  {route}: {c.weight:.0f} min, mean = {c.mean:.1f} min/station")
    print()


def application_network():
    """
    Application 4: Packet-Switching Network
    
    A network with 3 routers processing packets.
    Each router has processing delay and link latencies.
    """
    print("=" * 60)
    print("APPLICATION 4: Packet-Switching Network")
    print("=" * 60)
    print()
    
    nodes = ["Router A", "Router B", "Router C"]
    
    # Delays in microseconds
    A = np.array([
        [5,  12,  8],   # Router A: 5μs self, 12μs from B, 8μs from C
        [10,  5, 15],   # Router B: 10μs from A, 5μs self, 15μs from C
        [7,   9,  5],   # Router C: 7μs from A, 9μs from B, 5μs self
    ], dtype=float)
    
    print("Latency matrix (microseconds):")
    for i, name in enumerate(nodes):
        print(f"  {name:>10s}: {A[i]}")
    print()
    
    result = throughput_analysis(A, nodes)
    
    print(f"Maximum cycle delay: {result['eigenvalue']:.1f} μs")
    print(f"Maximum packet rate: {1e6/result['eigenvalue']:.0f} packets/second")
    print()
    
    cert = result['certificate']
    print(f"Certified delay bounds: [{cert.lower_bound:.1f}, {cert.upper_bound:.1f}] μs")
    print(f"Certification gap: {cert.gap:.2e} μs")
    print()


def application_dataflow():
    """
    Application 5: Synchronous Dataflow Graph (SDF)
    
    A signal processing pipeline modeled as an SDF graph:
    - FFT computation
    - Filter application
    - IFFT computation
    With feedback for overlap-save processing.
    """
    print("=" * 60)
    print("APPLICATION 5: Synchronous Dataflow (Signal Processing)")
    print("=" * 60)
    print()
    
    actors = ["FFT", "Filter", "IFFT", "Output"]
    
    # Execution times in milliseconds
    A = np.array([
        [0,  0,  0, 5],    # FFT: gets 5ms input from Output (overlap)
        [8,  0,  0, 0],    # Filter: 8ms from FFT
        [0, 12,  0, 0],    # IFFT: 12ms from Filter
        [0,  0,  3, 0],    # Output: 3ms from IFFT
    ], dtype=float)
    
    print("Actor timing matrix (milliseconds):")
    for i, name in enumerate(actors):
        print(f"  {name:>10s}: {A[i]}")
    print()
    
    result = throughput_analysis(A, actors)
    
    cycle_time = result['eigenvalue']
    print(f"Iteration period: {cycle_time:.1f} ms")
    print(f"Sample rate: {1000/cycle_time:.1f} iterations/second")
    print()
    
    ep = result['eigenpair']
    print("Actor schedule (phase offsets):")
    for i, name in enumerate(actors):
        print(f"  {name:>10s}: fires at t = {ep.eigenvector[i]:+.1f} ms (mod {cycle_time:.1f})")
    print()
    
    # Linear growth demo
    print("System evolution (first 5 iterations):")
    x = ep.eigenvector.copy()
    for k in range(6):
        print(f"  k={k}: completion times = [{', '.join(f'{t:.1f}' for t in x)}]")
        x = trop_mat_vec(A, x)
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  TROPICAL PERRON–FROBENIUS: REAL-WORLD APPLICATIONS        ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()
    
    application_manufacturing()
    application_processor_pipeline()
    application_railway()
    application_network()
    application_dataflow()
    
    print("=" * 60)
    print("All applications demonstrate the same principle:")
    print("The tropical eigenvalue λ certifies the exact cycle time.")
    print("Throughput = 1/λ, verified by finite graph optimization.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Perron–Frobenius Demo: Certified Throughput for Discrete-Event Systems

Demonstrates the core theorems of max-plus tropical spectral theory
applied to scheduling and performance verification.

Key concepts demonstrated:
1. Tropical (max-plus) matrix-vector multiplication
2. Tropical eigenpairs and their computation
3. Exact linear growth along eigenvectors
4. Maximum cycle mean as the tropical eigenvalue
5. Collatz–Wielandt bounds for eigenvalue certification
6. Application to manufacturing cell throughput analysis
"""

import numpy as np
from typing import Tuple, List, Optional


def trop_mat_vec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Max-plus matrix-vector product: (T_A x)_i = max_j (A_ij + x_j)"""
    n = A.shape[0]
    result = np.empty(n)
    for i in range(n):
        result[i] = np.max(A[i, :] + x)
    return result


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Max-plus matrix multiplication: (A ⊗ B)_ij = max_k (A_ik + B_kj)"""
    n = A.shape[0]
    C = np.empty((n, n))
    for i in range(n):
        for j in range(n):
            C[i, j] = np.max(A[i, :] + B[:, j])
    return C


def is_eigenpair(A: np.ndarray, lam: float, v: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if (λ, v) is a tropical eigenpair: T_A v = λ + v"""
    Tv = trop_mat_vec(A, v)
    return np.allclose(Tv, lam + v, atol=tol)


def max_cycle_mean(A: np.ndarray) -> float:
    """
    Compute the maximum cycle mean using Karp's algorithm.
    This is the tropical eigenvalue for irreducible matrices.
    
    For a digraph with weight matrix A, the maximum cycle mean is:
        λ = max over all simple cycles c of (weight(c) / length(c))
    """
    n = A.shape[0]
    # D[k][i] = maximum weight of a walk of length k ending at i
    # starting from a virtual source with 0-weight edges to all nodes
    D = np.full((n + 1, n), -np.inf)
    D[0, :] = 0.0  # Start from each node with weight 0
    
    for k in range(1, n + 1):
        for i in range(n):
            D[k, i] = np.max(D[k-1, :] + A[:, i])
    
    # Karp's formula: λ = max_i min_k (D[n][i] - D[k][i]) / (n - k)
    result = -np.inf
    for i in range(n):
        min_val = np.inf
        for k in range(n):
            if D[n, i] > -np.inf and D[k, i] > -np.inf:
                val = (D[n, i] - D[k, i]) / (n - k)
                min_val = min(min_val, val)
        if min_val < np.inf:
            result = max(result, min_val)
    
    return result


def find_eigenvector(A: np.ndarray, lam: float) -> np.ndarray:
    """
    Find a tropical eigenvector for eigenvalue λ using the
    critical graph method: solve max_j(A_ij + v_j) = λ + v_i.
    
    This is equivalent to finding a node potential in the graph
    A - λI (subtracting λ from diagonal entries).
    """
    n = A.shape[0]
    # Construct B = A - λI (subtract λ from all entries, conceptually shift)
    B = A.copy()
    for i in range(n):
        B[i, i] -= lam
    
    # Find shortest/longest paths using modified Bellman-Ford
    # We want v such that max_j(B_ij + v_j) = v_i for all i
    # Start with v = 0 and iterate
    v = np.zeros(n)
    for _ in range(n * 2):
        v_new = trop_mat_vec(B, v)
        # Normalize by subtracting v[0]
        v_new -= v_new[0]
        if np.allclose(v, v_new, atol=1e-10):
            break
        v = v_new
    
    return v


def collatz_wielandt_bounds(A: np.ndarray, x: np.ndarray) -> Tuple[float, float]:
    """
    Compute the Collatz–Wielandt bounds:
        lower = min_i (T_A(x)_i - x_i)
        upper = max_i (T_A(x)_i - x_i)
    
    For any tropical eigenvalue λ: lower ≤ λ ≤ upper.
    Equality (lower = upper) means x is an eigenvector.
    """
    Tx = trop_mat_vec(A, x)
    gaps = Tx - x
    return float(np.min(gaps)), float(np.max(gaps))


def print_separator():
    print("=" * 70)


def demo_2x2_manufacturing():
    """
    Demo 1: Two-Machine Manufacturing Cell
    
    Machine 1 ←→ Machine 2
    Transfer 1→2 takes 3 time units
    Transfer 2→1 takes 2 time units
    Self-processing: 0 time units each
    """
    print_separator()
    print("DEMO 1: Two-Machine Manufacturing Cell")
    print_separator()
    print()
    print("System matrix A:")
    A = np.array([[0, 2],
                  [3, 0]], dtype=float)
    print(A)
    print()
    
    # Compute max cycle mean
    lam = max_cycle_mean(A)
    print(f"Maximum cycle mean (tropical eigenvalue): λ = {lam}")
    print(f"  Self-loop 1: mean = {A[0,0]}")
    print(f"  Self-loop 2: mean = {A[1,1]}")
    print(f"  2-cycle (1→2→1): mean = ({A[0,1]} + {A[1,0]}) / 2 = {(A[0,1]+A[1,0])/2}")
    print()
    
    # Eigenvector
    v = np.array([0.0, 0.5])
    print(f"Eigenvector: v = {v}")
    print(f"Verification: T_A(v) = {trop_mat_vec(A, v)}")
    print(f"              λ + v  = {lam + v}")
    print(f"Eigenpair valid: {is_eigenpair(A, lam, v)}")
    print()
    
    # Linear growth
    print("Linear growth of iterates:")
    x = v.copy()
    for k in range(6):
        print(f"  k={k}: x = [{x[0]:6.1f}, {x[1]:6.1f}]  "
              f"(predicted: [{k*lam + v[0]:6.1f}, {k*lam + v[1]:6.1f}])")
        x = trop_mat_vec(A, x)
    
    print()
    throughput = 1.0 / lam
    print(f"Certified throughput: {throughput:.4f} parts/time unit")
    print(f"Cycle time: {lam} time units per part")
    print()


def demo_3x3_pipeline():
    """
    Demo 2: Three-Station Cyclic Pipeline
    
    Station 1 → Station 2: 4 time units
    Station 2 → Station 3: 3 time units  
    Station 3 → Station 1: 2 time units (feedback/recycle)
    """
    print_separator()
    print("DEMO 2: Three-Station Cyclic Pipeline")
    print_separator()
    print()
    
    A = np.array([[0, 0, 2],
                  [4, 0, 0],
                  [0, 3, 0]], dtype=float)
    print("System matrix A:")
    print(A)
    print()
    
    lam = max_cycle_mean(A)
    print(f"Maximum cycle mean: λ = {lam}")
    print(f"  3-cycle (1→2→3→1): mean = ({A[1,0]} + {A[2,1]} + {A[0,2]}) / 3 = {(A[1,0]+A[2,1]+A[0,2])/3}")
    print()
    
    v = np.array([0, 1, 1], dtype=float)
    print(f"Eigenvector: v = {v}")
    print(f"Verification: T_A(v) = {trop_mat_vec(A, v)}")
    print(f"              λ + v  = {lam + v}")
    print(f"Eigenpair valid: {is_eigenpair(A, lam, v)}")
    print()
    
    # Collatz-Wielandt bounds
    test_vectors = [np.zeros(3), np.ones(3), np.array([1, 2, 3], dtype=float)]
    print("Collatz–Wielandt bounds from various test vectors:")
    for tv in test_vectors:
        lo, hi = collatz_wielandt_bounds(A, tv)
        print(f"  x = {tv} → [{lo:.2f}, {hi:.2f}]  (λ = {lam})")
    print()
    
    # Linear growth
    print("Linear growth demonstration (20 steps):")
    x = v.copy()
    for k in range(21):
        if k % 5 == 0:
            avg = (x - v) / max(k, 1)
            print(f"  k={k:2d}: x = [{x[0]:7.1f}, {x[1]:7.1f}, {x[2]:7.1f}]  "
                  f"avg growth = {avg[0]:.3f}")
        x = trop_mat_vec(A, x)
    print()
    throughput = 1.0 / lam
    print(f"Certified throughput: {throughput:.4f} items/time unit")
    print(f"One item every {lam} time units")
    print()


def demo_5x5_processor():
    """
    Demo 3: 5-Stage Processor Pipeline
    
    A simplified model of a 5-stage instruction pipeline:
    Fetch → Decode → Execute → Memory → Writeback → Fetch
    """
    print_separator()
    print("DEMO 3: Five-Stage Processor Pipeline")
    print_separator()
    print()
    
    # Pipeline stages with varying latencies
    A = np.array([
        [0, 0, 0, 0, 1],   # Fetch ← Writeback: 1 cycle
        [2, 0, 0, 0, 0],   # Decode ← Fetch: 2 cycles
        [0, 1, 0, 0, 0],   # Execute ← Decode: 1 cycle
        [0, 0, 3, 0, 0],   # Memory ← Execute: 3 cycles
        [0, 0, 0, 1, 0],   # Writeback ← Memory: 1 cycle
    ], dtype=float)
    
    stages = ["Fetch", "Decode", "Execute", "Memory", "Writeback"]
    print("Pipeline adjacency matrix A:")
    print(A)
    print()
    
    lam = max_cycle_mean(A)
    print(f"Maximum cycle mean: λ = {lam}")
    total = A[1,0] + A[2,1] + A[3,2] + A[4,3] + A[0,4]
    print(f"  Full pipeline cycle: ({A[1,0]}+{A[2,1]}+{A[3,2]}+{A[4,3]}+{A[0,4]}) / 5 = {total/5}")
    print()
    
    v = find_eigenvector(A, lam)
    print(f"Eigenvector (phase offsets):")
    for i, stage in enumerate(stages):
        print(f"  {stage:>10s}: v[{i}] = {v[i]:.3f}")
    print(f"Eigenpair valid: {is_eigenpair(A, lam, v)}")
    print()
    
    throughput = 1.0 / lam if lam > 0 else float('inf')
    print(f"Certified throughput: {throughput:.4f} instructions/cycle")
    print(f"Pipeline bottleneck: {lam} cycles per instruction")
    print()


def demo_collatz_wielandt_convergence():
    """
    Demo 4: Collatz–Wielandt Bound Convergence
    
    Shows how the CW bounds tighten as we choose better test vectors.
    """
    print_separator()
    print("DEMO 4: Collatz–Wielandt Bound Convergence")
    print_separator()
    print()
    
    A = np.array([[1, 5, 3],
                  [2, 0, 4],
                  [6, 1, 2]], dtype=float)
    
    lam = max_cycle_mean(A)
    print(f"System matrix A = ")
    print(A)
    print(f"True eigenvalue λ = {lam:.4f}")
    print()
    
    # Start with x = 0 and iterate to improve bounds
    x = np.zeros(3)
    print("Iteration  CW Lower  CW Upper   Gap")
    print("-" * 45)
    for k in range(10):
        lo, hi = collatz_wielandt_bounds(A, x)
        gap = hi - lo
        print(f"  k={k:2d}     {lo:8.4f}  {hi:8.4f}  {gap:8.4f}")
        # Update x by tropical iteration
        x = trop_mat_vec(A, x)
        x -= x[0]  # Normalize
    
    print()
    v = find_eigenvector(A, lam)
    lo, hi = collatz_wielandt_bounds(A, v)
    print(f"At eigenvector: CW bounds = [{lo:.6f}, {hi:.6f}], gap = {hi-lo:.2e}")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  TROPICAL PERRON–FROBENIUS: CERTIFIED THROUGHPUT DEMONSTRATIONS     ║")
    print("║                                                                      ║")
    print("║  Max-plus spectral theory for discrete-event systems                 ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_2x2_manufacturing()
    demo_3x3_pipeline()
    demo_5x5_processor()
    demo_collatz_wielandt_convergence()
    
    print_separator()
    print("All demonstrations complete.")
    print("Key insight: The tropical eigenvalue λ exactly determines the")
    print("asymptotic cycle time. Throughput = 1/λ, certified by finite")
    print("combinatorial optimization over the graph's cycle structure.")
    print_separator()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all deliverables embedded."""

import base64
import json

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_base64(path):
    with open(path, 'rb') as f:
        return 'data:image/png;base64,' + base64.b64encode(f.read()).decode()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_defs = read_file('Tropical/PerronFrobenius/Defs.lean')
lean_basic = read_file('Tropical/PerronFrobenius/Basic.lean')
lean_throughput = read_file('Tropical/PerronFrobenius/Throughput.lean')

# Read images
img1 = read_base64('fig_linear_growth.png')
img2 = read_base64('fig_collatz_wielandt.png')
img3 = read_base64('fig_cycle_means.png')
img4 = read_base64('fig_comparison.png')

package = {
    "title": "Certified Tropical Perron–Frobenius for Discrete-Event Systems",
    "domain": "Tropical Algebra / Max-Plus Spectral Theory / Scheduling Verification",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Throughput Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Karp's Maximum Cycle Mean Algorithm",
            "pseudocode": """function KARP_MAX_CYCLE_MEAN(A, n):
    D[0][i] ← 0 for all i
    for k = 1 to n:
        for i = 0 to n-1:
            D[k][i] ← max_j (D[k-1][j] + A[j][i])
    λ* ← max_i min_{0≤k<n} (D[n][i] - D[k][i]) / (n - k)
    return λ*

Time: O(n³), Space: O(n²)""",
            "code": algorithms_code
        },
        {
            "name": "Collatz–Wielandt Certification",
            "pseudocode": """function CW_CERTIFY(A, x, n):
    Tx ← TROP_MAT_VEC(A, x)
    lo ← min_i (Tx[i] - x[i])
    hi ← max_i (Tx[i] - x[i])
    return [lo, hi]

Time: O(n²), Space: O(n)
Guarantee: lo ≤ λ* ≤ hi for the true eigenvalue λ*""",
            "code": "# See algorithms.py for full implementation\n" + algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Linear Growth Along Eigenvector",
            "data": img1
        },
        {
            "name": "Collatz–Wielandt Bound Convergence",
            "data": img2
        },
        {
            "name": "Cycle Mean Landscape",
            "data": img3
        },
        {
            "name": "System Evolution Comparison",
            "data": img4
        }
    ],
    "lean_proofs": lean_defs + "\n\n" + lean_basic + "\n\n" + lean_throughput
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated successfully ({len(json.dumps(package))} bytes)")


#!/usr/bin/env python3
"""
Visualizations for Tropical Perron–Frobenius Theory

Generates publication-quality figures demonstrating:
1. Linear growth of tropical iterates
2. Collatz–Wielandt bound convergence
3. Cycle mean landscape
4. System evolution comparison
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO


def trop_mat_vec(A, x):
    n = A.shape[0]
    return np.array([np.max(A[i, :] + x) for i in range(n)])


def save_fig_base64(fig):
    """Save figure to base64 string."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_linear_growth():
    """Plot 1: Linear growth of tropical iterates for 2×2 system."""
    A = np.array([[0, 2], [3, 0]], dtype=float)
    lam = 2.5
    v = np.array([0, 0.5])
    
    K = 20
    times = np.zeros((K+1, 2))
    times[0] = v
    for k in range(K):
        times[k+1] = trop_mat_vec(A, times[k])
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: absolute completion times
    ks = np.arange(K+1)
    ax1.plot(ks, times[:, 0], 'o-', color='#2196F3', linewidth=2, 
             markersize=5, label='Station 1')
    ax1.plot(ks, times[:, 1], 's-', color='#FF5722', linewidth=2, 
             markersize=5, label='Station 2')
    ax1.plot(ks, lam * ks + v[0], '--', color='#2196F3', alpha=0.5, 
             linewidth=1, label=f'k·λ + v₁ (λ={lam})')
    ax1.plot(ks, lam * ks + v[1], '--', color='#FF5722', alpha=0.5, 
             linewidth=1, label=f'k·λ + v₂')
    ax1.set_xlabel('Iteration k', fontsize=12)
    ax1.set_ylabel('Completion Time', fontsize=12)
    ax1.set_title('Exact Linear Growth Along Eigenvector', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Right: growth rate per step
    growth = np.diff(times, axis=0)
    ax2.plot(ks[1:], growth[:, 0], 'o-', color='#2196F3', linewidth=2, 
             markersize=5, label='Station 1')
    ax2.plot(ks[1:], growth[:, 1], 's-', color='#FF5722', linewidth=2, 
             markersize=5, label='Station 2')
    ax2.axhline(y=lam, color='green', linestyle='--', linewidth=2, 
                label=f'λ = {lam}', alpha=0.7)
    ax2.set_xlabel('Step k', fontsize=12)
    ax2.set_ylabel('Growth Rate (x_{k+1} - x_k)', fontsize=12)
    ax2.set_title('Per-Step Growth = Tropical Eigenvalue', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_ylim(lam - 0.5, lam + 0.5)
    ax2.grid(True, alpha=0.3)
    
    fig.suptitle('Tropical Perron–Frobenius: Linear Growth Theorem', fontsize=14, y=1.02)
    fig.tight_layout()
    
    fig.savefig('/workspace/request-project/fig_linear_growth.png', dpi=150, bbox_inches='tight')
    return save_fig_base64(fig)


def plot_collatz_wielandt():
    """Plot 2: Collatz–Wielandt bound convergence."""
    A = np.array([[1, 5, 3], [2, 0, 4], [6, 1, 2]], dtype=float)
    
    # Find eigenvalue
    from algorithms import karp_max_cycle_mean
    lam, _ = karp_max_cycle_mean(A)
    
    K = 15
    lowers = []
    uppers = []
    x = np.zeros(3)
    
    for k in range(K):
        Tx = trop_mat_vec(A, x)
        gaps = Tx - x
        lowers.append(np.min(gaps))
        uppers.append(np.max(gaps))
        x = Tx
        x -= x[0]
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ks = np.arange(K)
    
    ax.fill_between(ks, lowers, uppers, alpha=0.2, color='#4CAF50', label='CW interval')
    ax.plot(ks, lowers, 'v-', color='#2196F3', linewidth=2, markersize=6, label='CW Lower bound')
    ax.plot(ks, uppers, '^-', color='#FF5722', linewidth=2, markersize=6, label='CW Upper bound')
    ax.axhline(y=lam, color='black', linestyle='--', linewidth=2, label=f'λ* = {lam:.4f}', alpha=0.8)
    
    ax.set_xlabel('Iteration k', fontsize=12)
    ax.set_ylabel('Bound Value', fontsize=12)
    ax.set_title('Collatz–Wielandt Bounds: Certified Convergence to Eigenvalue', fontsize=13)
    ax.legend(fontsize=11, loc='upper right')
    ax.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_collatz_wielandt.png', dpi=150, bbox_inches='tight')
    return save_fig_base64(fig)


def plot_cycle_means():
    """Plot 3: Cycle mean landscape for a 3×3 matrix."""
    A = np.array([[1, 5, 3], [2, 0, 4], [6, 1, 2]], dtype=float)
    
    from algorithms import enumerate_simple_cycles, karp_max_cycle_mean
    cycles = enumerate_simple_cycles(A)
    lam, _ = karp_max_cycle_mean(A)
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    labels = []
    means = []
    colors = []
    
    for c in cycles:
        verts = " → ".join(str(v) for v in c.vertices) + f" → {c.vertices[0]}"
        labels.append(f"({verts})\nlen={c.length}")
        means.append(c.mean)
        colors.append('#FF5722' if abs(c.mean - lam) < 1e-10 else '#2196F3')
    
    bars = ax.bar(range(len(means)), means, color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)
    ax.axhline(y=lam, color='red', linestyle='--', linewidth=2, label=f'λ* = {lam:.4f} (max cycle mean)')
    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels(labels, fontsize=8, rotation=0)
    ax.set_ylabel('Cycle Mean', fontsize=12)
    ax.set_title('All Simple Cycle Means (Critical Cycle in Red)', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_cycle_means.png', dpi=150, bbox_inches='tight')
    return save_fig_base64(fig)


def plot_system_comparison():
    """Plot 4: Compare evolution of different systems."""
    systems = {
        'Manufacturing (2×2)': (np.array([[0, 2], [3, 0]]), np.array([0, 0.5])),
        'Pipeline (3×3)': (np.array([[0, 0, 2], [4, 0, 0], [0, 3, 0]]), np.array([0, 1, 1])),
    }
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0', '#FF9800']
    
    for idx, (name, (A, v)) in enumerate(systems.items()):
        ax = axes[idx]
        K = 15
        n = A.shape[0]
        
        times = np.zeros((K+1, n))
        times[0] = v
        for k in range(K):
            times[k+1] = trop_mat_vec(A, times[k])
        
        ks = np.arange(K+1)
        for i in range(n):
            ax.plot(ks, times[:, i], 'o-', color=colors[i], linewidth=2, 
                    markersize=4, label=f'Station {i+1}')
        
        # Compute eigenvalue
        from algorithms import karp_max_cycle_mean
        lam, _ = karp_max_cycle_mean(A)
        
        ax.set_xlabel('Iteration k', fontsize=12)
        ax.set_ylabel('Completion Time', fontsize=12)
        ax.set_title(f'{name}\nλ = {lam:.2f}, throughput = {1/lam:.3f}', fontsize=12)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
    
    fig.suptitle('System Evolution Comparison', fontsize=14, y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_comparison.png', dpi=150, bbox_inches='tight')
    return save_fig_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_1 = plot_linear_growth()
    print(f"  [1/4] Linear growth plot saved ({len(b64_1)} bytes)")
    
    b64_2 = plot_collatz_wielandt()
    print(f"  [2/4] Collatz–Wielandt convergence plot saved ({len(b64_2)} bytes)")
    
    b64_3 = plot_cycle_means()
    print(f"  [3/4] Cycle means landscape saved ({len(b64_3)} bytes)")
    
    b64_4 = plot_system_comparison()
    print(f"  [4/4] System comparison plot saved ({len(b64_4)} bytes)")
    
    print("All visualizations generated successfully.")
