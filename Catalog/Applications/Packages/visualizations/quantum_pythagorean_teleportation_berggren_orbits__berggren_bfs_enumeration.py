#!/usr/bin/env python3
"""
Algorithms for Berggren Tree Dynamics and Parity Analysis

Implements:
1. Berggren tree traversal (BFS/DFS)
2. Inverse Berggren descent (finding the path to a given triple)
3. Parity automaton simulation
4. Quadratic form verification
5. Depth and complexity analysis
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from collections import deque

# ============================================================
# Core Matrices and Constants
# ============================================================

ETA = np.array([[1, 0, 0], [0, 1, 0], [0, 0, -1]], dtype=np.int64)

GENERATORS = {
    'A': np.array([[ 1, -2,  2], [ 2, -1,  2], [ 2, -2,  3]], dtype=np.int64),
    'B': np.array([[ 1,  2,  2], [ 2,  1,  2], [ 2,  2,  3]], dtype=np.int64),
    'C': np.array([[-1,  2,  2], [-2,  1,  2], [-2,  2,  3]], dtype=np.int64),
}

INVERSES = {
    'A': np.array([[ 1,  2, -2], [-2, -1,  2], [-2, -2,  3]], dtype=np.int64),
    'B': np.array([[ 1,  2, -2], [ 2,  1, -2], [-2, -2,  3]], dtype=np.int64),
    'C': np.array([[-1, -2,  2], [ 2,  1, -2], [-2, -2,  3]], dtype=np.int64),
}

ROOT = np.array([3, 4, 5], dtype=np.int64)


# ============================================================
# Algorithm 1: Quadratic Form and Verification
# ============================================================

def pyth_quad(v: np.ndarray) -> int:
    """
    Compute the Pythagorean quadratic form Q(v) = v[0]² + v[1]² - v[2]².
    
    Returns 0 iff v represents a Pythagorean triple.
    
    Complexity: O(1) time, O(1) space
    """
    return int(v[0]**2 + v[1]**2 - v[2]**2)


def verify_lorentz_membership(M: np.ndarray) -> bool:
    """
    Check whether M ∈ O(2,1;ℤ), i.e., Mᵀ η M = η.
    
    Complexity: O(n³) for n×n matrix (here n=3, so O(1))
    """
    return np.array_equal(M.T @ ETA @ M, ETA)


def parity_constraint(v: np.ndarray) -> bool:
    """
    Check the parity constraint: v[0] + v[1] + v[2] ≡ 0 (mod 2).
    
    Complexity: O(1)
    """
    return (v[0] + v[1] + v[2]) % 2 == 0


# ============================================================
# Algorithm 2: Berggren Tree Traversal (BFS)
# ============================================================

def berggren_bfs(max_hypotenuse: int) -> List[Tuple[str, np.ndarray]]:
    """
    Generate all primitive Pythagorean triples with hypotenuse ≤ max_hypotenuse
    using BFS on the Berggren tree.
    
    Returns list of (path, triple) pairs.
    
    Complexity:
      Time:  O(N) where N = number of triples with c ≤ max_hypotenuse
      Space: O(N) for the queue and results
      
    The number of primitive Pythagorean triples with hypotenuse ≤ C
    grows as Θ(C / (2π)), so this is optimal.
    """
    results = []
    queue = deque([("", ROOT)])
    
    while queue:
        path, v = queue.popleft()
        if v[2] > max_hypotenuse:
            continue
        results.append((path, v.copy()))
        
        for label, M in GENERATORS.items():
            child = M @ v
            if child[2] <= max_hypotenuse:
                queue.append((path + label, child))
    
    return results


def berggren_dfs(max_depth: int) -> List[Tuple[str, np.ndarray]]:
    """
    Generate all triples in the Berggren tree up to a given depth using DFS.
    
    Complexity:
      Time:  O(3^d) where d = max_depth
      Space: O(d) stack depth + O(3^d) for results
    """
    results = []
    
    def _dfs(path: str, v: np.ndarray, depth: int):
        results.append((path, v.copy()))
        if depth >= max_depth:
            return
        for label, M in GENERATORS.items():
            _dfs(path + label, M @ v, depth + 1)
    
    _dfs("", ROOT, 0)
    return results


# ============================================================
# Algorithm 3: Inverse Berggren Descent
# ============================================================

def berggren_descent(triple: np.ndarray) -> Optional[str]:
    """
    Find the unique path from the root (3,4,5) to a given primitive
    Pythagorean triple in the Berggren tree.
    
    Uses the inverse matrices to ascend from the triple back to the root.
    
    Complexity:
      Time:  O(log c) where c is the hypotenuse (each step reduces c)
      Space: O(log c) for the path
      
    Returns None if the triple is not in the Berggren tree
    (i.e., not a primitive Pythagorean triple with positive entries).
    """
    v = triple.copy()
    path = []
    max_steps = 1000  # Safety limit
    
    for _ in range(max_steps):
        if np.array_equal(v, ROOT):
            return ''.join(reversed(path))
        
        if v[2] <= 0 or pyth_quad(v) != 0:
            return None
        
        # Try each inverse; exactly one should produce a valid parent
        found = False
        for label, M_inv in INVERSES.items():
            parent = M_inv @ v
            # Valid parent has all positive entries and smaller hypotenuse
            if all(parent > 0) and parent[2] < v[2]:
                path.append(label)
                v = parent
                found = True
                break
        
        if not found:
            return None
    
    return None


# ============================================================
# Algorithm 4: Parity Automaton
# ============================================================

class ParityAutomaton:
    """
    Finite-state automaton on (Z/2Z)³ induced by Berggren generators.
    
    Since all three generators reduce to the identity mod 2,
    the automaton has a trivially stable dynamics — every state
    is a fixed point. The parity constraint x+y+z ≡ 0 (mod 2)
    is an invariant of this automaton.
    
    This is the "proto-stabilizer" structure: a certified finite shadow
    of the infinite integral Lorentz dynamics.
    """
    
    def __init__(self):
        self.generators_mod2 = {}
        for label, M in GENERATORS.items():
            self.generators_mod2[label] = M % 2
    
    def transition(self, state: np.ndarray, generator: str) -> np.ndarray:
        """Apply a generator mod 2 to a parity state."""
        M2 = self.generators_mod2[generator]
        return (M2 @ state) % 2
    
    def is_invariant(self, state: np.ndarray) -> bool:
        """Check if parity constraint holds."""
        return sum(state) % 2 == 0
    
    def orbit(self, state: np.ndarray, word: str) -> List[np.ndarray]:
        """Trace the orbit of a state under a word in {A,B,C}*."""
        trajectory = [state.copy()]
        current = state.copy()
        for letter in word:
            current = self.transition(current, letter)
            trajectory.append(current.copy())
        return trajectory
    
    def full_state_table(self) -> Dict[str, Dict[str, Tuple]]:
        """
        Compute the complete transition table for all 8 states of (Z/2Z)³.
        
        Since all generators ≡ I (mod 2), every state maps to itself.
        """
        table = {}
        for i in range(8):
            state = np.array([(i >> 2) & 1, (i >> 1) & 1, i & 1])
            state_key = f"({state[0]},{state[1]},{state[2]})"
            table[state_key] = {}
            for label in GENERATORS:
                result = self.transition(state, label)
                table[state_key][label] = tuple(result)
        return table


# ============================================================
# Algorithm 5: Hypotenuse Growth Analysis
# ============================================================

def hypotenuse_growth_analysis(depth: int) -> Dict[str, List[int]]:
    """
    Analyze how the hypotenuse grows along each branch of the Berggren tree.
    
    For each generator applied repeatedly, tracks the hypotenuse sequence.
    Shows exponential growth with different rates for different generators.
    
    Complexity: O(depth) per branch
    """
    results = {}
    
    for label, M in GENERATORS.items():
        hyps = []
        v = ROOT.copy()
        for _ in range(depth):
            hyps.append(int(v[2]))
            v = M @ v
        hyps.append(int(v[2]))
        results[label] = hyps
    
    return results


# ============================================================
# Algorithm 6: Triple Statistics
# ============================================================

def triple_statistics(max_hyp: int) -> Dict[str, any]:
    """
    Compute statistics of the Berggren tree up to a given hypotenuse bound.
    
    Returns: count, depth distribution, parity verification, etc.
    """
    triples = berggren_bfs(max_hyp)
    
    depths = {}
    for path, v in triples:
        d = len(path)
        depths[d] = depths.get(d, 0) + 1
    
    all_pythagorean = all(pyth_quad(v) == 0 for _, v in triples)
    all_parity = all(parity_constraint(v) for _, v in triples)
    
    return {
        'count': len(triples),
        'max_hypotenuse': max_hyp,
        'depth_distribution': depths,
        'all_pythagorean': all_pythagorean,
        'all_parity_satisfied': all_parity,
        'sample_triples': [(path, tuple(v)) for path, v in triples[:10]],
    }


# ============================================================
# Main — Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)
    
    # 1. Lorentz verification
    print("\n--- Lorentz Group Membership ---")
    for label, M in GENERATORS.items():
        print(f"  {label} ∈ O(2,1;ℤ): {verify_lorentz_membership(M)}")
    
    # 2. BFS enumeration
    print("\n--- BFS Enumeration (hypotenuse ≤ 100) ---")
    triples = berggren_bfs(100)
    print(f"  Found {len(triples)} primitive Pythagorean triples")
    for path, v in triples:
        print(f"    [{path or 'root':>6}] ({v[0]:>3}, {v[1]:>3}, {v[2]:>3})")
    
    # 3. Inverse descent
    print("\n--- Inverse Descent ---")
    test_triples = [
        np.array([5, 12, 13]),
        np.array([8, 15, 17]),
        np.array([7, 24, 25]),
        np.array([20, 21, 29]),
    ]
    for t in test_triples:
        path = berggren_descent(t)
        print(f"  ({t[0]:>3}, {t[1]:>3}, {t[2]:>3}) → path: {path}")
    
    # 4. Parity automaton
    print("\n--- Parity Automaton ---")
    automaton = ParityAutomaton()
    print("  Transition table (all generators ≡ I mod 2):")
    table = automaton.full_state_table()
    for state, transitions in table.items():
        parity_ok = sum(int(c) for c in state if c.isdigit()) % 2 == 0
        marker = "✓ invariant" if parity_ok else "  outside"
        print(f"    {state} → A:{transitions['A']} B:{transitions['B']} C:{transitions['C']}  {marker}")
    
    # 5. Growth analysis
    print("\n--- Hypotenuse Growth ---")
    growth = hypotenuse_growth_analysis(8)
    for label, hyps in growth.items():
        print(f"  {label}-branch: {hyps}")
    
    # 6. Statistics
    print("\n--- Statistics (hypotenuse ≤ 1000) ---")
    stats = triple_statistics(1000)
    print(f"  Count: {stats['count']}")
    print(f"  All Pythagorean: {stats['all_pythagorean']}")
    print(f"  All parity OK: {stats['all_parity_satisfied']}")
    print(f"  Depth distribution: {stats['depth_distribution']}")
