#!/usr/bin/env python3
"""
Algorithms for Cellular Automata as Algebraic Geometry
======================================================

Implements the core algorithms from the research paper:
1. ECA rule evaluation and polynomial extraction (ANF)
2. Transfer matrix method for fixed-point counting
3. Fixed-point variety dimension computation
4. Linear rule classification
5. Section counting (sheaf-theoretic approach)
"""

from itertools import product
from math import gcd, log2


def eca_local_rule(r: int, left: int, center: int, right: int) -> int:
    """Local update function for ECA rule r.
    
    Args:
        r: Rule number (0-255)
        left, center, right: Cell values (0 or 1)
    
    Returns:
        New center value (0 or 1)
    
    Time complexity: O(1)
    Space complexity: O(1)
    """
    idx = 4 * left + 2 * center + right
    return (r >> idx) & 1


def eca_step(r: int, state: list[int]) -> list[int]:
    """Apply one step of ECA rule r to a cyclic state array.
    
    Args:
        r: Rule number
        state: List of 0s and 1s
    
    Returns:
        New state after one step
    
    Time complexity: O(n)
    Space complexity: O(n)
    """
    n = len(state)
    return [eca_local_rule(r, state[(i-1) % n], state[i], state[(i+1) % n]) for i in range(n)]


def is_fixed_point(r: int, state: list[int]) -> bool:
    """Check if state is a fixed point of rule r.
    
    Time complexity: O(n)
    """
    return eca_step(r, state) == state


def count_fixed_points_brute(r: int, n: int) -> int:
    """Count fixed points by brute-force enumeration.
    
    Time complexity: O(n · 2^n)
    Space complexity: O(n)
    """
    count = 0
    for bits in product([0, 1], repeat=n):
        if is_fixed_point(r, list(bits)):
            count += 1
    return count


def rule_to_anf(r: int) -> list[int]:
    """Convert rule number to Algebraic Normal Form (ANF) coefficients.
    
    Returns coefficients [a₀, a₁, a₂, a₃, a₄, a₅, a₆, a₇] where:
    f(l,c,r) = a₀ ⊕ a₁·r ⊕ a₂·c ⊕ a₃·cr ⊕ a₄·l ⊕ a₅·lr ⊕ a₆·lc ⊕ a₇·lcr
    
    Uses the Möbius transform over GF(2).
    
    Time complexity: O(1) (constant 8 entries)
    Space complexity: O(1)
    """
    # Get truth table indexed by (4*l + 2*c + r)
    table = [(r >> i) & 1 for i in range(8)]
    
    # Möbius transform
    anf = table.copy()
    for bit in range(3):
        step = 1 << bit
        for j in range(8):
            if j & step:
                anf[j] ^= anf[j ^ step]
    
    return anf


def anf_to_polynomial_str(anf: list[int]) -> str:
    """Convert ANF coefficients to human-readable polynomial string."""
    names = ['1', 'r', 'c', 'cr', 'l', 'lr', 'lc', 'lcr']
    terms = [names[i] for i in range(8) if anf[i]]
    return ' + '.join(terms) if terms else '0'


def anf_degree(anf: list[int]) -> int:
    """Compute the degree of an ANF polynomial."""
    max_deg = 0
    for i in range(8):
        if anf[i]:
            deg = bin(i).count('1')
            max_deg = max(max_deg, deg)
    return max_deg


def is_linear_rule(r: int) -> bool:
    """Check if rule r is linear over GF(2).
    
    A rule is linear iff its ANF has degree ≤ 1 and zero constant term.
    """
    anf = rule_to_anf(r)
    return anf[0] == 0 and all(anf[i] == 0 for i in range(8) if bin(i).count('1') > 1)


def transfer_matrix(r: int) -> list[list[int]]:
    """Compute the 4×4 transfer matrix for fixed-point counting.
    
    States (s_i, s_{i+1}) are indexed by 2*s_i + s_{i+1}.
    Transition (s_i, s_j) → (s_j, s_k) is valid if localRule(s_i, s_j, s_k) = s_j.
    
    Time complexity: O(1)
    """
    T = [[0]*4 for _ in range(4)]
    for row in range(4):
        si = (row >> 1) & 1
        sj = row & 1
        for sk in range(2):
            col = 2 * sj + sk
            if eca_local_rule(r, si, sj, sk) == sj:
                T[row][col] = 1
    return T


def mat_mul(A: list[list[int]], B: list[list[int]]) -> list[list[int]]:
    """Multiply two 4×4 integer matrices."""
    n = len(A)
    C = [[0]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] += A[i][k] * B[k][j]
    return C


def mat_pow(M: list[list[int]], p: int) -> list[list[int]]:
    """Matrix exponentiation by squaring."""
    n = len(M)
    result = [[1 if i == j else 0 for j in range(n)] for i in range(n)]
    base = [row[:] for row in M]
    while p > 0:
        if p & 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        p >>= 1
    return result


def count_fixed_points_transfer(r: int, n: int) -> int:
    """Count fixed points using the transfer matrix method.
    
    For cyclic boundary conditions, |Fix| = Tr(T^n).
    
    Time complexity: O(64 · log n) = O(log n) (matrix exponentiation)
    Space complexity: O(16) = O(1)
    """
    T = transfer_matrix(r)
    Tn = mat_pow(T, n)
    return sum(Tn[i][i] for i in range(4))


def fixed_point_dimension(r: int, n: int) -> float:
    """Compute the fixed-point variety dimension = log₂|Fix|.
    
    Uses transfer matrix method for efficiency.
    """
    fp = count_fixed_points_transfer(r, n)
    if fp <= 0:
        return -float('inf')
    return log2(fp)


def count_local_sections(r: int, width: int) -> int:
    """Count the number of local sections of width w.
    
    A local section is an assignment of w consecutive cells that satisfies
    the fixed-point equation on all interior cells.
    
    Time complexity: O(w · 2^w)
    """
    count = 0
    for bits in product([0, 1], repeat=width):
        valid = True
        for i in range(1, width - 1):
            if eca_local_rule(r, bits[i-1], bits[i], bits[i+1]) != bits[i]:
                valid = False
                break
        if valid:
            count += 1
    return count


def classify_all_rules(n: int = 8) -> dict[str, list[int]]:
    """Classify all 256 ECA rules by their fixed-point variety dimension.
    
    Returns a dictionary mapping dimension range to list of rule numbers.
    """
    classes = {
        'dim=0 (1 fixed point)': [],
        'dim>0 (multiple fixed points)': [],
        'dim=n (all fixed points)': [],
        'no fixed points': [],
        'linear rules': [],
    }
    
    for r in range(256):
        fp = count_fixed_points_transfer(r, n)
        dim = log2(fp) if fp > 0 else -1
        
        if fp == 0:
            classes['no fixed points'].append(r)
        elif fp == 1:
            classes['dim=0 (1 fixed point)'].append(r)
        elif fp == 2**n:
            classes['dim=n (all fixed points)'].append(r)
        else:
            classes['dim>0 (multiple fixed points)'].append(r)
        
        if is_linear_rule(r):
            classes['linear rules'].append(r)
    
    return classes


def section_growth_rate(r: int, max_width: int = 12) -> list[tuple[int, int]]:
    """Compute the section count for increasing widths.
    
    The growth rate of sections characterizes the "sheaf complexity" of the rule.
    For linear rules, sections grow as 2^(dim * width).
    For nonlinear rules, the growth can be subexponential.
    """
    results = []
    for w in range(1, max_width + 1):
        sec = count_local_sections(r, w)
        results.append((w, sec))
    return results


if __name__ == '__main__':
    print("=== Algorithm Demos ===")
    
    # ANF computation
    print("\n--- Algebraic Normal Forms ---")
    for r in [0, 30, 90, 110, 150, 204, 255]:
        anf = rule_to_anf(r)
        poly_str = anf_to_polynomial_str(anf)
        deg = anf_degree(anf)
        linear = is_linear_rule(r)
        print(f"  Rule {r:3d}: f = {poly_str:20s} (degree {deg}, linear: {linear})")
    
    # Transfer matrix method
    print("\n--- Transfer Matrix Fixed-Point Counting ---")
    for r in [0, 90, 110, 204]:
        for n in [10, 50, 100]:
            fp = count_fixed_points_transfer(r, n)
            dim = fixed_point_dimension(r, n)
            print(f"  Rule {r:3d}, n={n:3d}: |Fix|={fp:>15d}, dim={dim:.2f}")
    
    # Section growth
    print("\n--- Section Growth Rates ---")
    for r in [0, 90, 110, 204]:
        growth = section_growth_rate(r, 10)
        widths = [f"{c:3d}" for _, c in growth]
        print(f"  Rule {r:3d}: sections by width: {' '.join(widths)}")
    
    # Full classification
    print("\n--- Rule Classification (n=8) ---")
    classes = classify_all_rules(8)
    for cls, rules in classes.items():
        print(f"  {cls}: {len(rules)} rules")
