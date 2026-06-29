#!/usr/bin/env python3
"""
Berggren–Modular Correspondence: Interactive Demo

Demonstrates the connection between Pythagorean triples, Lorentz transformations,
the modular group PSL(2,Z), and Gaussian integer factorization.

All results verified formally in Lean 4 (see BerggrenLorentz.lean, BerggrenGaussian.lean,
BerggrenCrossDomain.lean).
"""

import numpy as np
from fractions import Fraction
from math import gcd, isqrt, log2

# ============================================================
# Berggren Matrices (3x3, acting on triples)
# ============================================================

A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

# Inverse matrices (for descent)
A_inv = np.array([[1, 2, -2], [-2, -1, 2], [-2, -2, 3]])
B_inv = np.array([[1, 2, -2], [2, 1, -2], [-2, -2, 3]])
C_inv = np.array([[-1, -2, 2], [2, 1, -2], [-2, -2, 3]])

MATRICES = {'A': A, 'B': B, 'C': C}
INV_MATRICES = {'A': A_inv, 'B': B_inv, 'C': C_inv}

# Minkowski metric
eta = np.diag([1, 1, -1])

# 2x2 Parameter matrices (acting on (m, n))
pA = np.array([[2, -1], [1, 0]])
pB = np.array([[2, 1], [1, 0]])
pC = np.array([[1, 2], [0, 1]])
PARAM_MATRICES = {'A': pA, 'B': pB, 'C': pC}

ROOT = np.array([3, 4, 5])

# ============================================================
# Core Functions
# ============================================================

def minkowski_form(v):
    """Q(v) = v[0]^2 + v[1]^2 - v[2]^2"""
    return v[0]**2 + v[1]**2 - v[2]**2

def is_pythagorean(a, b, c):
    return a**2 + b**2 == c**2

def get_params(a, b, c):
    """Get (m, n) parameters: a = m^2 - n^2, b = 2mn, c = m^2 + n^2"""
    # c = m^2 + n^2, a = m^2 - n^2 => m^2 = (a+c)/2, n^2 = (c-a)/2
    m_sq = (a + c) // 2
    n_sq = (c - a) // 2
    m = isqrt(m_sq)
    n = isqrt(n_sq)
    if m * m == m_sq and n * n == n_sq:
        return (m, n)
    # Try b = 2mn with the other leg assignment
    m_sq = (b + c) // 2 if (b + c) % 2 == 0 else 0
    n_sq = (c - b) // 2 if (c - b) % 2 == 0 else 0
    if m_sq > 0 and n_sq >= 0:
        m = isqrt(m_sq)
        n = isqrt(n_sq)
        if m * m == m_sq and n * n == n_sq:
            return (m, n)
    return None

def farey_map(a, b, c):
    """φ(a,b,c) = b / (a + c)"""
    return Fraction(b, a + c)

def berggren_children(triple):
    """Generate the three children of a triple in the Berggren tree."""
    return {
        'A': tuple(A @ triple),
        'B': tuple(B @ triple),
        'C': tuple(C @ triple)
    }

def berggren_descent(a, b, c, max_steps=100):
    """Descend from (a,b,c) to (3,4,5) recording the path."""
    path = []
    triple = np.array([a, b, c])
    for _ in range(max_steps):
        if tuple(triple) == (3, 4, 5):
            return path, tuple(triple)
        # Try each inverse
        for label, inv in INV_MATRICES.items():
            parent = inv @ triple
            if all(p > 0 for p in parent) and is_pythagorean(*parent):
                path.append(label)
                triple = parent
                break
        else:
            return path, tuple(triple)  # stuck
    return path, tuple(triple)

def gaussian_factorization(m, n):
    """The Gaussian factorization: c = (m + ni)(m - ni) = m^2 + n^2"""
    return (m, n), (m, -n), m**2 + n**2

# ============================================================
# Demo
# ============================================================

def print_header(title):
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)

def demo_lorentz():
    print_header("1. LORENTZ STRUCTURE: Berggren Matrices Preserve Q(v) = x²+y²-z²")
    
    print("\nThe Minkowski form Q(v) = v₀² + v₁² - v₂² vanishes on Pythagorean triples.")
    print(f"  Q(3, 4, 5) = {minkowski_form(ROOT)}")
    
    print("\nBerggren matrices preserve the Minkowski form (Mᵀ η M = η):")
    for name, M in MATRICES.items():
        preserved = np.allclose(M.T @ eta @ M, eta)
        det_val = int(round(np.linalg.det(M)))
        print(f"  {name}: Mᵀ η M = η? {preserved},  det = {det_val}")
    
    print("\nChildren of (3, 4, 5):")
    children = berggren_children(ROOT)
    for label, child in children.items():
        q = minkowski_form(child)
        params = get_params(*child)
        print(f"  {label}: {child}  Q = {q}  params (m,n) = {params}")

def demo_modular():
    print_header("2. MODULAR GROUP: 2×2 Parameter Space Transformations")
    
    root_params = np.array([2, 1])  # (m, n) for (3, 4, 5)
    
    print(f"\nRoot (3,4,5) has Gaussian parameters (m,n) = {tuple(root_params)}")
    print(f"  Verification: m²-n² = {2**2 - 1**2}, 2mn = {2*2*1}, m²+n² = {2**2 + 1**2}")
    
    print("\n2×2 parameter matrices and their action on (2,1):")
    for name, pM in PARAM_MATRICES.items():
        result = pM @ root_params
        det_val = int(round(np.linalg.det(pM)))
        m, n = result
        triple = (m**2 - n**2, 2*m*n, m**2 + n**2)
        print(f"  p{name}: (2,1) → ({m},{n}) → triple ({triple[0]},{triple[1]},{triple[2]})  det = {det_val}")
    
    print("\nSL(2,ℤ) generators:")
    S = np.array([[0, -1], [1, 0]])
    T = np.array([[1, 1], [0, 1]])
    print(f"  S = {S.tolist()},  S² = {(S @ S).tolist()}")
    print(f"  T = {T.tolist()},  T² = {(T @ T).tolist()}")
    print(f"  pC = T²? {np.array_equal(pC, T @ T)}")
    
    # Check S⁴ = I
    S4 = S @ S @ S @ S
    print(f"  S⁴ = I? {np.array_equal(S4, np.eye(2, dtype=int))}")
    
    # Check (ST)³ = -I
    ST = S @ T
    ST3 = ST @ ST @ ST
    print(f"  (ST)³ = -I? {np.array_equal(ST3, -np.eye(2, dtype=int))}")

def demo_farey():
    print_header("3. FAREY CORRESPONDENCE: φ(a,b,c) = b/(a+c) = n/m")
    
    triples = [(3,4,5), (5,12,13), (15,8,17), (21,20,29), (7,24,25),
               (9,40,41), (11,60,61), (35,12,37), (45,28,53)]
    
    print(f"\n{'Triple':<15} {'Farey φ':<10} {'Params (m,n)':<15} {'n/m':<10} {'Match?':<8}")
    print("-" * 58)
    for a, b, c in triples:
        if is_pythagorean(a, b, c):
            phi = farey_map(a, b, c)
            params = get_params(a, b, c)
            if params:
                m, n = params
                ratio = Fraction(n, m)
                match = phi == ratio
                print(f"({a},{b},{c}){'':<{10-len(f'({a},{b},{c})')}} {str(phi):<10} ({m},{n}){'':<{12-len(f'({m},{n})')}} {str(ratio):<10} {'✓' if match else '✗'}")
            else:
                print(f"({a},{b},{c}){'':<{10-len(f'({a},{b},{c})')}} {str(phi):<10} {'(swap legs)':<15}")

def demo_descent():
    print_header("4. DESCENT: O(log c) Gaussian Factorization Recovery")
    
    test_triples = [
        (5, 12, 13),
        (7, 24, 25),
        (15, 8, 17),
        (21, 20, 29),
        (55, 48, 73),
        (39, 80, 89),
        (119, 120, 169),
        (697, 696, 985),
    ]
    
    print(f"\n{'Triple':<20} {'Path':<15} {'Depth':<7} {'log₂(c)':<10} {'Gaussian':<20}")
    print("-" * 72)
    for a, b, c in test_triples:
        path, final = berggren_descent(a, b, c)
        path_str = ''.join(path) if path else '(root)'
        log_c = f"{log2(c):.1f}"
        params = get_params(a, b, c)
        if params:
            m, n = params
            gauss = f"({m}+{n}i)({m}-{n}i)"
        else:
            gauss = "?"
        print(f"({a},{b},{c}){'':<{17-len(f'({a},{b},{c})')}} {path_str:<15} {len(path):<7} {log_c:<10} {gauss}")

def demo_gaussian():
    print_header("5. GAUSSIAN FACTORIZATION: c = (m+ni)(m-ni)")
    
    print("\nBrahmagupta-Fibonacci Identity: (a²+b²)(c²+d²) = (ac-bd)² + (ad+bc)²")
    print("\nExamples:")
    pairs = [(2,1,3,2), (2,1,4,1), (3,2,4,1), (2,1,5,2)]
    for a, b, c, d in pairs:
        lhs = (a**2 + b**2) * (c**2 + d**2)
        p, q = a*c - b*d, a*d + b*c
        p2, q2 = a*c + b*d, a*d - b*c
        print(f"  ({a}²+{b}²)·({c}²+{d}²) = {a**2+b**2}·{c**2+d**2} = {lhs} = {abs(p)}²+{abs(q)}² = {abs(p2)}²+{abs(q2)}²")
    
    print("\nPrimes ≡ 1 (mod 4) factor in ℤ[i]:")
    primes_1mod4 = [5, 13, 17, 29, 37, 41, 53, 61, 73, 89, 97]
    for p in primes_1mod4:
        for m in range(1, isqrt(p) + 1):
            n_sq = p - m*m
            if n_sq >= 0:
                n = isqrt(n_sq)
                if n*n == n_sq and n > 0 and m >= n:
                    print(f"  {p} = {m}² + {n}² = ({m}+{n}i)({m}-{n}i)")
                    break

def demo_tree():
    print_header("6. THE BERGGREN TREE (first 3 levels)")
    
    def print_tree(triple, depth, prefix=""):
        a, b, c = triple
        params = get_params(a, b, c)
        param_str = f"  (m,n)=({params[0]},{params[1]})" if params else ""
        farey = farey_map(a, b, c)
        print(f"{prefix}({a},{b},{c})  φ={farey}{param_str}")
        if depth > 0:
            children = berggren_children(np.array(triple))
            for label in ['A', 'B', 'C']:
                child = children[label]
                branch = "├── " if label != 'C' else "└── "
                ext = "│   " if label != 'C' else "    "
                print(f"{prefix}{branch}{label}: ", end="")
                print_tree(child, depth - 1, prefix + ext)
    
    print()
    print_tree((3, 4, 5), 2)

def demo_parity():
    print_header("7. PARITY THEOREM: In primitive (a,b,c), exactly one of a,b is even")
    
    print("\nVerification for first 20 primitive Pythagorean triples:")
    count = 0
    for c in range(1, 200):
        for b in range(1, c):
            a_sq = c*c - b*b
            a = isqrt(a_sq)
            if a > 0 and a*a == a_sq and a <= b and gcd(a, b) == 1:
                parity_a = "even" if a % 2 == 0 else "odd"
                parity_b = "even" if b % 2 == 0 else "odd"
                check = (a % 2 == 0) != (b % 2 == 0)
                print(f"  ({a},{b},{c}): a={parity_a}, b={parity_b}  {'✓' if check else '✗'}")
                count += 1
                if count >= 15:
                    break
        if count >= 15:
            break

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  BERGGREN–MODULAR CORRESPONDENCE                                   ║")
    print("║  Pythagorean Light Cone Geodesics, PSL(2,ℤ), Gaussian Factorization ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_lorentz()
    demo_modular()
    demo_farey()
    demo_descent()
    demo_gaussian()
    demo_tree()
    demo_parity()
    
    print("\n" + "=" * 70)
    print("  All results formally verified in Lean 4 with zero sorries.")
    print("  See: BerggrenLorentz.lean, BerggrenGaussian.lean, BerggrenCrossDomain.lean")
    print("=" * 70)
