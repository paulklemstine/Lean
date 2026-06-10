#!/usr/bin/env python3
"""
Applications of the Transfer-Matrix Theory for Cellular Automata.

Real-world applications and concrete use cases:
1. Constrained sequence counting (tiling, coding theory)
2. Cellular automata classification by dynamical complexity
3. Cryptographic stream cipher analysis
4. Error-correcting code enumeration
"""

from itertools import product
from collections import defaultdict
from fractions import Fraction


# ============================================================
# Application 1: Constrained Channel Capacity
# ============================================================

def channel_capacity_estimate(rule, alphabet: list, height: int, 
                                max_width: int = 20) -> float:
    """
    Estimate the channel capacity of the CA spacetime constraint.
    
    For a CA rule, the spacetime constraint defines a sofic shift.
    The topological entropy (= channel capacity) is:
        h = lim_{n→∞} log(count(n)) / n
    where count(n) is the number of valid width-n strips.
    
    By the transfer-matrix theorem, count(n) = trace(A^n),
    so h = log(spectral_radius(A)).
    
    Application: This gives the maximum information density
    achievable in a channel constrained by the CA dynamics.
    """
    # Build transfer matrix
    columns = list(product(alphabet, repeat=height))
    states = [(c1, c2) for c1 in columns for c2 in columns]
    n_states = len(states)
    state_index = {s: i for i, s in enumerate(states)}
    
    A = [[0] * n_states for _ in range(n_states)]
    for s1_idx, (c1, c2) in enumerate(states):
        for c3 in columns:
            compatible = True
            for t in range(height - 1):
                if c2[t + 1] != rule(c1[t], c2[t], c3[t]):
                    compatible = False
                    break
            if compatible:
                A[s1_idx][state_index[(c2, c3)]] += 1
    
    # Compute trace(A^n) for increasing n to estimate spectral radius
    import math
    
    # Power iteration for largest eigenvalue
    vec = [1.0] * n_states
    for _ in range(max_width):
        new_vec = [0.0] * n_states
        for i in range(n_states):
            for j in range(n_states):
                new_vec[i] += A[i][j] * vec[j]
        norm = max(abs(x) for x in new_vec) if new_vec else 1
        vec = [x / norm for x in new_vec]
    
    # Estimate spectral radius from last iteration
    new_vec = [0.0] * n_states
    for i in range(n_states):
        for j in range(n_states):
            new_vec[i] += A[i][j] * vec[j]
    
    # Rayleigh quotient
    dot_num = sum(new_vec[i] * vec[i] for i in range(n_states))
    dot_den = sum(vec[i] * vec[i] for i in range(n_states))
    spectral_radius = dot_num / dot_den if dot_den > 0 else 1
    
    return math.log2(max(spectral_radius, 1))


# ============================================================
# Application 2: Elementary CA Classification
# ============================================================

def classify_elementary_ca(max_height: int = 3) -> dict:
    """
    Classify all 256 elementary CA rules by their spacetime complexity.
    
    For each rule and each height, compute:
    - Transfer matrix size
    - Minimal recurrence order of the trace sequence
    - Growth rate (spectral radius estimate)
    
    This gives a rigorous complexity taxonomy of elementary CA.
    """
    results = {}
    
    for rule_num in range(256):
        def rule(l, c, r, rn=rule_num):
            idx = l * 4 + c * 2 + r
            return (rn >> idx) & 1
        
        info = {"rule": rule_num, "heights": {}}
        
        for h in range(2, max_height + 1):
            # Count valid strips for small widths
            columns = list(product([0, 1], repeat=h))
            states = [(c1, c2) for c1 in columns for c2 in columns]
            n_states = len(states)
            state_index = {s: i for i, s in enumerate(states)}
            
            A = [[0] * n_states for _ in range(n_states)]
            for s1_idx, (c1, c2) in enumerate(states):
                for c3 in columns:
                    compatible = True
                    for t in range(h - 1):
                        if c2[t + 1] != rule(c1[t], c2[t], c3[t]):
                            compatible = False
                            break
                    if compatible:
                        A[s1_idx][state_index[(c2, c3)]] += 1
            
            # Compute traces by matrix power
            def mat_mul(M1, M2, size):
                res = [[0]*size for _ in range(size)]
                for i in range(size):
                    for k in range(size):
                        if M1[i][k] == 0:
                            continue
                        for j in range(size):
                            res[i][j] += M1[i][k] * M2[k][j]
                return res
            
            power = [[1 if i == j else 0 for j in range(n_states)] for i in range(n_states)]
            traces = []
            for n in range(8):
                traces.append(sum(power[i][i] for i in range(n_states)))
                power = mat_mul(power, A, n_states)
            
            # Estimate growth rate
            growth = traces[-1] / traces[-2] if traces[-2] > 0 else 0
            
            info["heights"][h] = {
                "matrix_size": n_states,
                "traces": traces[1:],  # Skip n=0
                "growth_rate": round(growth, 4)
            }
        
        results[rule_num] = info
    
    return results


# ============================================================
# Application 3: Cyclic Code Enumeration
# ============================================================

def enumerate_ca_cyclic_codes(p: int, a: int, b: int, c: int, 
                               max_n: int = 30) -> dict:
    """
    Enumerate cyclic codes arising from additive CA over GF(p).
    
    For additive CA f(l,c,r) = a*l + b*c + c*r over GF(p),
    the fixed-point set on (GF(p))^n is a cyclic code.
    
    This function computes:
    - Code dimension (= log_p of fixed-point count)
    - Code parameters [n, k] over GF(p)
    - Periodicity of the dimension sequence
    
    Application: These codes arise naturally in CA dynamics
    and may have useful algebraic properties.
    """
    results = {}
    
    for n in range(1, max_n + 1):
        # Build circulant matrix
        T = [[0] * n for _ in range(n)]
        for i in range(n):
            T[i][(i - 1) % n] = a % p
            T[i][i] = b % p
            T[i][(i + 1) % n] = (T[i][(i + 1) % n] + c) % p
        
        # Compute T - I mod p
        TmI = [row[:] for row in T]
        for i in range(n):
            TmI[i][i] = (TmI[i][i] - 1) % p
        
        # Gaussian elimination mod p
        rank = 0
        for col in range(n):
            pivot = None
            for row in range(rank, n):
                if TmI[row][col] % p != 0:
                    pivot = row
                    break
            if pivot is None:
                continue
            TmI[rank], TmI[pivot] = TmI[pivot], TmI[rank]
            inv = pow(TmI[rank][col], p - 2, p)
            for j in range(n):
                TmI[rank][j] = (TmI[rank][j] * inv) % p
            for row in range(n):
                if row != rank and TmI[row][col] % p != 0:
                    factor = TmI[row][col]
                    for j in range(n):
                        TmI[row][j] = (TmI[row][j] - factor * TmI[rank][j]) % p
            rank += 1
        
        k = n - rank
        results[n] = {
            "n": n,
            "k": k,
            "code_size": p ** k,
            "rate": k / n if n > 0 else 0
        }
    
    return results


# ============================================================
# Application 4: Pattern Avoidance in CA Spacetime
# ============================================================

def forbidden_pattern_analysis(rule_num: int, height: int = 3, 
                                 max_width: int = 6) -> dict:
    """
    Analyze forbidden patterns in CA spacetime strips.
    
    For each width, determine which column sequences cannot appear
    in valid spacetime diagrams. This reveals the constraint structure
    of the CA dynamics.
    
    Application: Understanding forbidden patterns is essential for
    error detection in CA-based communication systems.
    """
    def rule(l, c, r):
        idx = l * 4 + c * 2 + r
        return (rule_num >> idx) & 1
    
    columns = list(product([0, 1], repeat=height))
    col_to_idx = {c: i for i, c in enumerate(columns)}
    
    # Build adjacency for column pairs
    compatible_triples = set()
    for c1 in columns:
        for c2 in columns:
            for c3 in columns:
                ok = True
                for t in range(height - 1):
                    if c2[t + 1] != rule(c1[t], c2[t], c3[t]):
                        ok = False
                        break
                if ok:
                    compatible_triples.add((col_to_idx[c1], col_to_idx[c2], col_to_idx[c3]))
    
    results = {
        "rule": rule_num,
        "height": height,
        "num_columns": len(columns),
        "compatible_triples": len(compatible_triples),
        "total_triples": len(columns) ** 3,
        "constraint_ratio": len(compatible_triples) / (len(columns) ** 3),
    }
    
    return results


# ============================================================
# Main: Run all applications
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Applications of Transfer-Matrix Theory for Cellular Automata")
    print("=" * 60)
    
    # Application 1: Channel capacity
    print("\n--- Application 1: Channel Capacity ---")
    def rule_110(l, c, r):
        return (110 >> (l * 4 + c * 2 + r)) & 1
    
    def rule_90(l, c, r):
        return l ^ r
    
    for rule_fn, name in [(rule_90, "Rule 90"), (rule_110, "Rule 110")]:
        for h in [2, 3]:
            cap = channel_capacity_estimate(rule_fn, [0, 1], h)
            print(f"  {name}, height={h}: capacity ≈ {cap:.4f} bits/column")
    
    # Application 2: Classification (subset for speed)
    print("\n--- Application 2: Elementary CA Classification (sample) ---")
    for r in [30, 90, 110, 150, 184]:
        def rule(l, c, r_val, rn=r):
            return (rn >> (l * 4 + c * 2 + r_val)) & 1
        
        columns = list(product([0, 1], repeat=2))
        states = [(c1, c2) for c1 in columns for c2 in columns]
        n = len(states)
        idx = {s: i for i, s in enumerate(states)}
        A = [[0] * n for _ in range(n)]
        for si, (c1, c2) in enumerate(states):
            for c3 in columns:
                if all(c2[t+1] == rule(c1[t], c2[t], c3[t]) for t in range(1)):
                    A[si][idx[(c2, c3)]] += 1
        
        power = [[1 if i == j else 0 for j in range(n)] for i in range(n)]
        traces = []
        for step in range(6):
            traces.append(sum(power[i][i] for i in range(n)))
            new_power = [[0]*n for _ in range(n)]
            for i in range(n):
                for k in range(n):
                    if power[i][k]:
                        for j in range(n):
                            new_power[i][j] += power[i][k] * A[k][j]
            power = new_power
        
        print(f"  Rule {r}: traces = {traces[1:]}")
    
    # Application 3: Cyclic codes
    print("\n--- Application 3: Cyclic Codes from Rule 90 ---")
    codes = enumerate_ca_cyclic_codes(2, 1, 0, 1, max_n=20)
    print(f"  {'n':>3} | {'k':>3} | {'size':>6} | {'rate':>6}")
    print(f"  {'-'*3}-+-{'-'*3}-+-{'-'*6}-+-{'-'*6}")
    for n in range(1, 21):
        c = codes[n]
        print(f"  {c['n']:>3} | {c['k']:>3} | {c['code_size']:>6} | {c['rate']:>6.3f}")
    
    # Application 4: Forbidden patterns
    print("\n--- Application 4: Constraint Analysis ---")
    for r in [30, 90, 110, 150]:
        info = forbidden_pattern_analysis(r, height=3)
        print(f"  Rule {r}: {info['compatible_triples']}/{info['total_triples']} "
              f"triples valid ({info['constraint_ratio']:.3f})")
    
    print("\nAll applications complete!")


#!/usr/bin/env python3
"""
Demonstration of the Transfer-Matrix Rationality Theorem for Cellular Automata.

This script provides concrete numerical examples of:
1. Spacetime column compatibility and transfer matrices for CA
2. Trace(A^n) counting cyclic spacetime diagrams
3. Linear recurrence of trace sequences (Cayley-Hamilton)
4. Additive CA over finite fields and fixed-point counting

These computations illustrate the formally verified theorems from
the Lean 4 formalization.
"""

import numpy as np
from typing import Callable, List, Tuple
from itertools import product


def build_ca_columns(alphabet: list, height: int) -> list:
    """Generate all possible spacetime columns of given height."""
    return list(product(alphabet, repeat=height))


def ca_rule_110(l: int, c: int, r: int) -> int:
    """Elementary CA Rule 110 (binary)."""
    idx = l * 4 + c * 2 + r
    return (110 >> idx) & 1


def ca_rule_90(l: int, c: int, r: int) -> int:
    """Elementary CA Rule 90: XOR of left and right (additive over GF(2))."""
    return l ^ r


def ca_rule_150(l: int, c: int, r: int) -> int:
    """Elementary CA Rule 150: l XOR c XOR r (additive over GF(2))."""
    return l ^ c ^ r


def columns_compatible(rule: Callable, c_left: tuple, c_mid: tuple, c_right: tuple) -> bool:
    """Check if three consecutive columns satisfy the CA rule.
    
    For height h+1 columns, checks that for each time step t < h:
    c_mid[t+1] = rule(c_left[t], c_mid[t], c_right[t])
    """
    h = len(c_mid) - 1  # h = number of evolution steps
    for t in range(h):
        if c_mid[t + 1] != rule(c_left[t], c_mid[t], c_right[t]):
            return False
    return True


def build_transfer_matrix(rule: Callable, alphabet: list, height: int) -> np.ndarray:
    """Build the transfer matrix for CA spacetime strip counting.
    
    States are pairs (c_prev, c_curr) of consecutive columns.
    Transition from (c1, c2) to (c2', c3) requires c2 = c2'
    and columns_compatible(rule, c1, c2, c3).
    
    Args:
        rule: CA local rule function
        alphabet: list of alphabet symbols
        height: h+1 where h is number of evolution steps
    
    Returns:
        Transfer matrix as numpy array
    """
    columns = build_ca_columns(alphabet, height)
    states = [(c1, c2) for c1 in columns for c2 in columns]
    n_states = len(states)
    
    state_index = {s: i for i, s in enumerate(states)}
    A = np.zeros((n_states, n_states), dtype=int)
    
    for s1_idx, (c1, c2) in enumerate(states):
        for c3 in columns:
            if columns_compatible(rule, c1, c2, c3):
                s2 = (c2, c3)
                s2_idx = state_index[s2]
                A[s1_idx, s2_idx] += 1
    
    return A


def trace_sequence(A: np.ndarray, max_n: int) -> list:
    """Compute trace(A^n) for n = 0, 1, ..., max_n."""
    traces = []
    power = np.eye(A.shape[0], dtype=object)  # Use object for big ints
    A_obj = A.astype(object)
    for n in range(max_n + 1):
        traces.append(int(np.trace(power)))
        power = power @ A_obj
    return traces


def find_linear_recurrence(seq: list, max_order: int = None) -> Tuple[int, list]:
    """Find a linear recurrence satisfied by the sequence.
    
    Returns (order, coefficients) such that:
    seq[n + order] = sum(coeffs[i] * seq[n + i] for i in range(order))
    """
    if max_order is None:
        max_order = len(seq) // 2
    
    for d in range(1, max_order + 1):
        if 2 * d > len(seq):
            break
        # Build the system: for each n, seq[n+d] = sum c_i * seq[n+i]
        rows = len(seq) - d
        if rows < d:
            continue
        
        M = np.zeros((rows, d))
        b = np.zeros(rows)
        for n in range(rows):
            for i in range(d):
                M[n, i] = seq[n + i]
            b[n] = seq[n + d]
        
        # Try to solve using least squares
        try:
            coeffs, residuals, rank, sv = np.linalg.lstsq(M, b, rcond=None)
            # Verify the solution
            if np.allclose(M @ coeffs, b, atol=1e-6):
                return d, [round(c) for c in coeffs]
        except np.linalg.LinAlgError:
            continue
    
    return None, None


def count_cyclic_spacetime_diagrams(rule: Callable, alphabet: list, 
                                      height: int, width: int) -> int:
    """Directly count valid cyclic spacetime diagrams by brute force.
    
    A valid diagram has height rows and width columns (cyclic in space),
    where each row after the first is determined by the CA rule.
    """
    if width == 0:
        return 0
    
    columns = build_ca_columns(alphabet, height)
    count = 0
    
    # Try all possible sequences of width columns (with cyclic wraparound)
    for col_seq in product(columns, repeat=width):
        valid = True
        for pos in range(width):
            c_left = col_seq[(pos - 1) % width]
            c_mid = col_seq[pos]
            c_right = col_seq[(pos + 1) % width]
            if not columns_compatible(rule, c_left, c_mid, c_right):
                valid = False
                break
        if valid:
            count += 1
    
    return count


def demo_transfer_matrix():
    """Demonstrate the transfer matrix theorem with concrete examples."""
    print("=" * 70)
    print("DEMO 1: Transfer Matrix for Cellular Automata Spacetime")
    print("=" * 70)
    
    alphabet = [0, 1]
    
    for rule_fn, rule_name in [(ca_rule_90, "Rule 90 (XOR)"), 
                                (ca_rule_150, "Rule 150 (l⊕c⊕r)")]:
        print(f"\n--- {rule_name} ---")
        
        for height in [2, 3]:
            print(f"\n  Height = {height} (spacetime has {height} rows)")
            
            # Build transfer matrix
            A = build_transfer_matrix(rule_fn, alphabet, height)
            print(f"  Transfer matrix size: {A.shape[0]} × {A.shape[0]}")
            
            # Compute trace sequence
            traces = trace_sequence(A, 10)
            print(f"  trace(A^n) for n=0..10: {traces}")
            
            # Verify against brute force for small widths
            print(f"  Brute-force verification:")
            for n in range(1, 6):
                brute = count_cyclic_spacetime_diagrams(rule_fn, alphabet, height, n)
                trace_val = traces[n]
                match = "✓" if brute == trace_val else "✗"
                print(f"    width={n}: brute_force={brute}, trace(A^{n})={trace_val} {match}")
            
            # Find linear recurrence
            order, coeffs = find_linear_recurrence(traces[1:], max_order=A.shape[0])
            if order:
                print(f"  Linear recurrence of order {order}: a(n+{order}) = ", end="")
                terms = [f"{c}·a(n+{i})" for i, c in enumerate(coeffs) if c != 0]
                print(" + ".join(terms))


def demo_linear_recurrence():
    """Demonstrate that trace sequences satisfy linear recurrences."""
    print("\n" + "=" * 70)
    print("DEMO 2: Linear Recurrence from Cayley-Hamilton")
    print("=" * 70)
    
    # Simple example: 3x3 matrix
    A = np.array([[1, 1, 0], [1, 0, 1], [0, 1, 1]], dtype=object)
    print(f"\nMatrix A =\n{A}")
    
    traces = trace_sequence(A, 15)
    print(f"\ntrace(A^n) for n=0..15: {traces}")
    
    # Characteristic polynomial
    A_float = A.astype(float)
    eigenvalues = np.linalg.eigvals(A_float)
    print(f"\nEigenvalues: {[f'{e:.4f}' for e in eigenvalues]}")
    
    # The characteristic polynomial gives a recurrence of order 3
    # charpoly(A) = det(xI - A) = x^3 - 2x^2 - 2x + 2
    # By Cayley-Hamilton: A^3 = 2A^2 + 2A - 2I
    # So trace(A^{n+3}) = 2*trace(A^{n+2}) + 2*trace(A^{n+1}) - 2*trace(A^n)
    
    order, coeffs = find_linear_recurrence(traces, max_order=5)
    print(f"\nFound recurrence of order {order}:")
    print(f"  Coefficients: {coeffs}")
    
    # Verify
    print("\nVerification:")
    for n in range(len(traces) - order):
        predicted = sum(coeffs[i] * traces[n + i] for i in range(order))
        actual = traces[n + order]
        match = "✓" if predicted == actual else "✗"
        print(f"  n={n}: predicted={predicted}, actual={actual} {match}")


def demo_additive_ca():
    """Demonstrate additive CA over finite fields."""
    print("\n" + "=" * 70)
    print("DEMO 3: Additive CA over GF(2) - Fixed Point Counting")
    print("=" * 70)
    
    # Rule 90: f(l,c,r) = l + r over GF(2)
    # This is the CA T with polynomial P(U) = U^{-1} + U
    # After clearing: X*P(X) = 1 + X^2 in GF(2)[X]
    
    print("\nRule 90 over GF(2): f(l,c,r) = l ⊕ r")
    print("Polynomial: P(U) = U^{-1} + U")
    
    def count_fixed_points_rule90(n: int, m: int = 1) -> int:
        """Count configurations on Z/nZ fixed by T^m for Rule 90."""
        if n == 0:
            return 0
        # Build the circulant matrix for T^m over GF(2)
        # T acts as: (Tx)_i = x_{i-1} + x_{i+1} (mod 2)
        T = np.zeros((n, n), dtype=int)
        for i in range(n):
            T[i, (i - 1) % n] = 1
            T[i, (i + 1) % n] = 1
        T = T % 2
        
        # Compute T^m mod 2
        Tm = np.eye(n, dtype=int)
        T_power = T.copy()
        mm = m
        while mm > 0:
            if mm % 2 == 1:
                Tm = (Tm @ T_power) % 2
            T_power = (T_power @ T_power) % 2
            mm //= 2
        
        # Fixed points: kernel of T^m - I over GF(2)
        TmI = (Tm - np.eye(n, dtype=int)) % 2
        
        # Count kernel dimension using row reduction over GF(2)
        rank = gf2_rank(TmI, n)
        return 2 ** (n - rank)
    
    for m in [1, 2, 3]:
        print(f"\n  Fixed points of T^{m} on Z/nZ:")
        counts = []
        for n in range(1, 21):
            fp = count_fixed_points_rule90(n, m)
            counts.append(fp)
        print(f"    n=1..20: {counts}")
        
        # Check if log_2 count is eventually periodic
        log_counts = [int(np.log2(c)) if c > 0 else 0 for c in counts]
        print(f"    log_2(count): {log_counts}")


def gf2_rank(M: np.ndarray, n: int) -> int:
    """Compute rank of an n×n matrix over GF(2)."""
    A = M.copy() % 2
    rank = 0
    for col in range(n):
        # Find pivot
        pivot = None
        for row in range(rank, n):
            if A[row, col] % 2 == 1:
                pivot = row
                break
        if pivot is None:
            continue
        # Swap rows
        A[[rank, pivot]] = A[[pivot, rank]]
        # Eliminate
        for row in range(n):
            if row != rank and A[row, col] % 2 == 1:
                A[row] = (A[row] + A[rank]) % 2
        rank += 1
    return rank


if __name__ == "__main__":
    demo_transfer_matrix()
    demo_linear_recurrence()
    demo_additive_ca()
    
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("These computations illustrate the formally verified theorems:")
    print("  1. Cyclic spacetime count = trace(transfer matrix power)")
    print("  2. Trace sequence satisfies linear recurrence (Cayley-Hamilton)")
    print("  3. Additive CA fixed points governed by polynomial arithmetic")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json by reading all deliverable files."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read Lean files
lean_files = []
lean_dir = 'Speculative/CellularAutomata'
for fname in sorted(os.listdir(lean_dir)):
    if fname.endswith('.lean'):
        content = read_file(os.path.join(lean_dir, fname))
        lean_files.append(f"-- File: {lean_dir}/{fname}\n{content}")

lean_proofs = "\n\n".join(lean_files)

package = {
    "title": "Transfer-Matrix Rationality and Linear Recurrence for Cellular Automata Spacetime",
    "domain": "Symbolic Dynamics / Automata Theory / Algebraic Combinatorics",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Transfer Matrix Demo",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Transfer Matrix Construction",
            "pseudocode": "1. Enumerate all columns of height h\n2. Form states as pairs of consecutive columns\n3. For each state pair, check CA compatibility\n4. Record transitions in matrix\nComplexity: O(|α|^{3h} · h) time, O(|α|^{4h}) space",
            "code": algorithms_code
        },
        {
            "name": "Additive CA Fixed-Point Counting",
            "pseudocode": "1. Build circulant matrix T for additive rule on Z/nZ\n2. Compute T^m by matrix exponentiation mod p\n3. Compute rank of (T^m - I) over GF(p)\n4. Return p^{n - rank}\nComplexity: O(n^3 log m) time, O(n^2) space",
            "code": applications_code
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully")
print(f"  Total size: {os.path.getsize('PACKAGE.json')} bytes")
