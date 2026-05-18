#!/usr/bin/env python3
"""
Applications of Quantum Stabilizer Code Bounds

Real-world applications of the formalized code bounds theory:
1. Quantum hardware resource estimation
2. Error threshold analysis
3. Code selection for fault-tolerant quantum computing
4. Topological memory overhead analysis
"""

import math
from typing import List, Tuple, Dict


def hamming_sum(n: int, t: int) -> int:
    """Hamming packing sum."""
    return sum(3**i * math.comb(n, i) for i in range(t + 1))


# ============================================================
# Application 1: Quantum Hardware Resource Estimation
# ============================================================

def estimate_resources(logical_qubits: int, target_distance: int,
                       code_type: str = "toric") -> Dict:
    """Estimate physical qubit requirements for fault-tolerant computation.
    
    Given desired logical qubits and error correction distance,
    compute the physical resource overhead for different code families.
    
    Args:
        logical_qubits: Number of logical qubits needed.
        target_distance: Desired code distance for error suppression.
        code_type: "toric", "surface", or "generic".
    
    Returns:
        Resource estimate dictionary.
    """
    d = target_distance
    
    if code_type == "toric":
        # Toric code: k = 2 per code block, n = 2d²
        blocks_needed = math.ceil(logical_qubits / 2)
        n_per_block = 2 * d**2
        total_physical = blocks_needed * n_per_block
        total_logical = blocks_needed * 2
        
        return {
            "code_type": "Toric code [[2d², 2, d]]",
            "blocks": blocks_needed,
            "physical_per_block": n_per_block,
            "total_physical": total_physical,
            "total_logical": total_logical,
            "overhead_ratio": total_physical / total_logical,
            "correction_radius": (d - 1) // 2,
        }
    
    elif code_type == "surface":
        # Surface code: k = 1 per patch, n ≈ 2d² - 2d + 1
        n_per_patch = 2 * d**2 - 2 * d + 1
        total_physical = logical_qubits * n_per_patch
        
        return {
            "code_type": f"Surface code [[~2d²-2d+1, 1, d]]",
            "blocks": logical_qubits,
            "physical_per_block": n_per_patch,
            "total_physical": total_physical,
            "total_logical": logical_qubits,
            "overhead_ratio": total_physical / logical_qubits,
            "correction_radius": (d - 1) // 2,
        }
    
    else:  # Generic Singleton bound
        # Best possible: n ≥ k + 2(d-1)
        n_min = logical_qubits + 2 * (d - 1)
        
        return {
            "code_type": "Generic (Singleton lower bound)",
            "blocks": 1,
            "physical_per_block": n_min,
            "total_physical": n_min,
            "total_logical": logical_qubits,
            "overhead_ratio": n_min / logical_qubits,
            "correction_radius": (d - 1) // 2,
        }


# ============================================================
# Application 2: Error Threshold Analysis
# ============================================================

def error_threshold_analysis(physical_error_rate: float,
                             code_distances: List[int]) -> Dict:
    """Analyze logical error rate vs. physical error rate.
    
    For a code of distance d, the logical error rate scales as:
        p_L ≈ (c · p)^{⌊d/2⌋ + 1}
    where p is the physical error rate and c ≈ 1 for depolarizing noise.
    
    The threshold is the physical error rate below which increasing
    distance improves the logical error rate.
    """
    results = []
    for d in code_distances:
        t = (d - 1) // 2
        # Simplified model: p_L ≈ (100 * p)^(t+1) / 100
        # More realistic threshold ≈ 1% for surface codes
        threshold = 0.01
        p_logical = (physical_error_rate / threshold) ** (t + 1) * threshold
        
        results.append({
            "distance": d,
            "correction_radius": t,
            "logical_error_rate": p_logical,
            "suppression_factor": (physical_error_rate / threshold) ** t,
            "below_threshold": physical_error_rate < threshold,
        })
    
    return {
        "physical_error_rate": physical_error_rate,
        "threshold": 0.01,
        "results": results,
    }


# ============================================================
# Application 3: Code Selection Guide
# ============================================================

def code_selection(n_available: int, k_needed: int,
                   min_distance: int = 3) -> List[Dict]:
    """Suggest quantum error-correcting codes for given constraints.
    
    Given available qubits and required logical qubits,
    find codes that satisfy both Hamming and Singleton bounds.
    """
    candidates = []
    
    for d in range(min_distance, n_available // 2 + 2):
        for k in range(k_needed, n_available + 1):
            # Check Singleton
            if 2 * d + k > n_available + 2:
                continue
            
            t = (d - 1) // 2
            hs = hamming_sum(n_available, t)
            ss = 2 ** (n_available - k)
            
            # Check Hamming
            if hs > ss:
                continue
            
            candidates.append({
                "n": n_available,
                "k": k,
                "d": d,
                "correction_radius": t,
                "packing_ratio": hs / ss,
                "is_perfect": hs == ss,
                "is_mds": 2 * d + k == n_available + 2,
            })
    
    # Sort by distance (descending), then k (descending)
    candidates.sort(key=lambda x: (-x["d"], -x["k"]))
    return candidates[:10]  # Top 10


# ============================================================
# Application 4: Topological Memory Scaling
# ============================================================

def topological_memory_scaling(target_logical_error: float,
                               physical_error_rate: float = 0.001) -> Dict:
    """Determine toric code size needed for target logical error rate.
    
    For toric codes, the logical error rate scales as:
        p_L ≈ (p / p_th)^{L/2}
    
    where p_th ≈ 11% for optimal decoding.
    
    Returns the minimum L and corresponding physical resources.
    """
    p_th = 0.11  # Toric code threshold (optimal decoding)
    ratio = physical_error_rate / p_th
    
    if ratio >= 1:
        return {"feasible": False, "reason": "Above threshold"}
    
    # Need: ratio^{L/2} ≤ target
    # L/2 · log(ratio) ≤ log(target)
    # L ≥ 2 · log(target) / log(ratio)
    
    L_min = math.ceil(2 * math.log(target_logical_error) / math.log(ratio))
    L_min = max(L_min, 2)
    
    n = 2 * L_min**2
    estimated_logical_error = ratio ** (L_min / 2)
    
    return {
        "feasible": True,
        "L_min": L_min,
        "physical_qubits": n,
        "logical_qubits": 2,
        "distance": L_min,
        "estimated_logical_error": estimated_logical_error,
        "target_logical_error": target_logical_error,
        "overhead_ratio": n / 2,
    }


# ============================================================
# Main: Demonstrate Applications
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Quantum Hardware Resource Estimation")
    print("=" * 70)
    print()
    
    for k, d in [(10, 7), (50, 11), (100, 15), (1000, 21)]:
        for code_type in ["toric", "surface", "generic"]:
            r = estimate_resources(k, d, code_type)
            print(f"  {k} logical qubits, d={d}, {code_type}: "
                  f"{r['total_physical']:>10,} physical ({r['overhead_ratio']:.0f}x)")
        print()
    
    print("=" * 70)
    print("APPLICATION 2: Error Threshold Analysis")
    print("=" * 70)
    print()
    
    for p in [0.001, 0.005, 0.01, 0.02]:
        analysis = error_threshold_analysis(p, [3, 5, 7, 11, 15, 21])
        print(f"  Physical error rate: {p:.3f}")
        for r in analysis["results"]:
            print(f"    d={r['distance']:>2}: p_L = {r['logical_error_rate']:.2e} "
                  f"(suppression: {r['suppression_factor']:.2e})")
        print()
    
    print("=" * 70)
    print("APPLICATION 3: Code Selection for n=15 qubits, k≥1")
    print("=" * 70)
    print()
    
    candidates = code_selection(15, 1, min_distance=3)
    print(f"  {'Parameters':>12} {'d':>4} {'t':>4} {'Packing':>10} {'Perfect':>8} {'MDS':>6}")
    for c in candidates:
        print(f"  [[{c['n']},{c['k']},{c['d']}]] {c['d']:>4} {c['correction_radius']:>4} "
              f"{c['packing_ratio']:>10.4f} {'★' if c['is_perfect'] else '':>8} "
              f"{'★' if c['is_mds'] else '':>6}")
    
    print()
    print("=" * 70)
    print("APPLICATION 4: Topological Memory Scaling")
    print("=" * 70)
    print()
    
    targets = [1e-6, 1e-10, 1e-15, 1e-20]
    for target in targets:
        result = topological_memory_scaling(target, 0.001)
        if result["feasible"]:
            print(f"  Target p_L = {target:.0e}: L = {result['L_min']}, "
                  f"n = {result['physical_qubits']:>6}, "
                  f"actual p_L ≈ {result['estimated_logical_error']:.1e}, "
                  f"overhead = {result['overhead_ratio']:.0f}x")
    
    print()
    print("All applications completed.")


#!/usr/bin/env python3
"""
Quantum Stabilizer Code Bounds — Interactive Demonstrations

Demonstrates the key theorems from the formal verification:
1. Quantum Hamming bound computation
2. Perfect code classification
3. Toric code parameter analysis
4. Singleton bound verification
"""

import math
from typing import List, Tuple


def hamming_sum(n: int, t: int) -> int:
    """Compute the Hamming packing sum: Σ_{i=0}^{t} 3^i * C(n,i).
    
    This counts the number of n-qubit Pauli errors of weight ≤ t.
    Each qubit position can have one of 3 non-identity Pauli operators
    (X, Y, or Z), and there are C(n,i) ways to choose i positions.
    """
    return sum(3**i * math.comb(n, i) for i in range(t + 1))


def syndrome_size(n: int, k: int) -> int:
    """Syndrome space cardinality: 2^(n-k)."""
    return 2 ** (n - k)


def hamming_ratio(n: int, k: int, d: int) -> float:
    """Packing efficiency: how much of syndrome space is used."""
    t = (d - 1) // 2
    return hamming_sum(n, t) / syndrome_size(n, k)


# =============================================================
# Demo 1: Quantum Hamming Bound for Known Codes
# =============================================================
print("=" * 65)
print("DEMO 1: Quantum Hamming Bound for Known Codes")
print("=" * 65)
print()

codes = [
    ("Five-qubit [[5,1,3]]", 5, 1, 3),
    ("Steane [[7,1,3]]", 7, 1, 3),
    ("Shor [[9,1,3]]", 9, 1, 3),
    ("[[15,1,3]]", 15, 1, 3),
    ("[[23,1,7]]", 23, 1, 7),
]

print(f"{'Code':<25} {'Hamming Sum':>12} {'Syndrome':>10} {'Ratio':>8} {'Perfect?':>10}")
print("-" * 65)

for name, n, k, d in codes:
    t = (d - 1) // 2
    hs = hamming_sum(n, t)
    ss = syndrome_size(n, k)
    ratio = hs / ss
    perfect = "YES ★" if hs == ss else "no"
    print(f"{name:<25} {hs:>12,} {ss:>10,} {ratio:>8.4f} {perfect:>10}")

print()
print("The five-qubit code is perfect: it exactly saturates the bound.")
print("Other codes leave syndrome space 'unused' (degenerate decoding possible).")

# =============================================================
# Demo 2: Perfect Code Classification (d = 3)
# =============================================================
print()
print("=" * 65)
print("DEMO 2: Perfect Code Classification (d = 3, single-error)")
print("=" * 65)
print()

print("Searching for solutions of 1 + 3n = 2^(n-k) with k ≥ 1:")
print()
solutions = []
for m in range(1, 40):
    val = 2**m
    if (val - 1) % 3 == 0:
        n = (val - 1) // 3
        k = n - m
        if k >= 1 and k <= n:
            solutions.append((n, k, m))
            print(f"  n = {n:>4}, k = {k:>4}, n-k = {m:>3}, "
                  f"verify: 1 + 3·{n} = {1 + 3*n} = 2^{m} ✓")

print()
print(f"Found {len(solutions)} solutions.")
print()

# Check MDS property: 2d + k = n + 2 with d = 3
print("Checking MDS condition (2·3 + k = n + 2):")
for n, k, m in solutions:
    is_mds = (6 + k == n + 2)
    print(f"  [[{n},{k},3]]: 6 + {k} = {6+k}, n + 2 = {n+2} → "
          f"{'MDS ★' if is_mds else 'not MDS'}")

print()
print("RESULT: [[5,1,3]] is the UNIQUE MDS perfect code at distance 3.")

# =============================================================
# Demo 3: Toric Code Parameters
# =============================================================
print()
print("=" * 65)
print("DEMO 3: Toric Code Family [[2L², 2, L]]")
print("=" * 65)
print()

print(f"{'L':>4} {'n = 2L²':>8} {'k':>4} {'d = L':>6} {'Rate k/n':>10} "
      f"{'Singleton':>11} {'kd² = n':>8} {'d²/n':>6}")
print("-" * 65)

for L in range(2, 11):
    n = 2 * L**2
    k = 2
    d = L
    rate = k / n
    singleton_ok = 2*d + k <= n + 2
    kd2 = k * d**2
    d2_over_n = d**2 / n
    print(f"{L:>4} {n:>8} {k:>4} {d:>6} {rate:>10.4f} "
          f"{'✓ ' + str(2*d+k) + '≤' + str(n+2):>11} "
          f"{'✓' if kd2 == n else '✗':>8} {d2_over_n:>6.2f}")

print()
print("Key observations:")
print("  • kd² = n exactly (BPT bound saturated)")
print("  • d² = n/2, so distance scales as √(n/2)")
print("  • Rate k/n → 0 as L → ∞ (topological overhead)")
print("  • Singleton bound always satisfied: 2L + 2 ≤ 2L² + 2")

# =============================================================
# Demo 4: Hamming Bound Tightness Analysis
# =============================================================
print()
print("=" * 65)
print("DEMO 4: Hamming Bound Tightness — How Close to Perfect?")
print("=" * 65)
print()

print(f"{'Code':>18} {'Sum/2^(n-k)':>14} {'Unused fraction':>18}")
print("-" * 55)

for n in range(5, 26, 2):
    k = 1
    d = 3
    t = 1
    hs = hamming_sum(n, t)
    ss = syndrome_size(n, k)
    ratio = hs / ss
    unused = 1 - ratio
    bar = "█" * int(ratio * 30) + "░" * int(unused * 30)
    print(f"  [[{n},{k},{d}]] {ratio:>12.6f} {unused:>16.4%}  {bar}")

print()
print("As n grows, the packing becomes exponentially loose.")
print("This is why degenerate codes can outperform the Hamming bound.")

# =============================================================
# Demo 5: Singleton Bound Landscape
# =============================================================
print()
print("=" * 65)
print("DEMO 5: Quantum Singleton Bound — Parameter Space")
print("=" * 65)
print()

print("For d = 3: k ≤ n - 4 (equivalently, 2·3 + k ≤ n + 2)")
print("MDS codes achieve equality: k = n - 4")
print()

print(f"{'n':>4} {'k_max (Singleton)':>18} {'Hamming feasible?':>18}")
print("-" * 45)

for n in range(5, 21):
    k_max = n - 4  # Singleton bound for d = 3
    t = 1
    # Check Hamming: 1 + 3n ≤ 2^(n-k_max) = 2^4 = 16
    hamming_ok = (1 + 3 * n <= 2 ** (n - k_max))
    # Actual max k from Hamming
    best_k = -1
    for k_try in range(k_max, 0, -1):
        if hamming_sum(n, t) <= syndrome_size(n, k_try):
            best_k = k_try
            break
    print(f"{n:>4} {k_max:>18} {'✓ (k_H = ' + str(best_k) + ')' if best_k > 0 else '✗':>18}")


if __name__ == "__main__":
    print()
    print("All demonstrations completed successfully.")
