"""
Visualization: Product Set Growth Profiles in GL(2, F_q)

Visualizes the growth trajectories |A|, |A^2|, |A^3|, ... for multiple
generating pairs, showing how all trajectories strictly increase until
saturation — the central theorem proved formally.

Self-contained: all functions are inlined.
"""

import numpy as np
import matplotlib.pyplot as plt
import random
from itertools import product as iterproduct
import math


# =================== INLINED HELPERS ===================

def mat_mul(A, B, q):
    return (A @ B) % q

def mat_det(M, q):
    return int((M[0, 0] * M[1, 1] - M[0, 1] * M[1, 0]) % q)

def mat_inv(M, q):
    d = mat_det(M, q)
    if d == 0:
        return None
    d_inv = pow(int(d), q - 2, q)
    return np.array([
        [M[1, 1] * d_inv % q, (-M[0, 1]) * d_inv % q],
        [(-M[1, 0]) * d_inv % q, M[0, 0] * d_inv % q]
    ], dtype=int) % q

def mat_to_tuple(M):
    return tuple(M.flatten())

def tuple_to_mat(t):
    return np.array(t, dtype=int).reshape(2, 2)

def gl2_order(q):
    return (q**2 - 1) * (q**2 - q)

def symmetric_closure(g, h, q):
    I = np.eye(2, dtype=int)
    g_inv = mat_inv(g, q)
    h_inv = mat_inv(h, q)
    elements = {mat_to_tuple(I)}
    for M in [g, g_inv, h, h_inv]:
        if M is not None:
            elements.add(mat_to_tuple(M))
    return elements

def product_set(A, B, q):
    result = set()
    for a_tup in A:
        a = tuple_to_mat(a_tup)
        for b_tup in B:
            b = tuple_to_mat(b_tup)
            result.add(mat_to_tuple(mat_mul(a, b, q)))
    return result

def generates_gl2(g, h, q):
    total = gl2_order(q)
    I = np.eye(2, dtype=int)
    seen = {mat_to_tuple(I)}
    queue = [I]
    gens = [g, h, mat_inv(g, q), mat_inv(h, q)]
    gens = [x for x in gens if x is not None]
    idx = 0
    while idx < len(queue):
        if len(seen) == total:
            return True
        current = queue[idx]; idx += 1
        for gen in gens:
            prod = mat_mul(current, gen, q)
            t = mat_to_tuple(prod)
            if t not in seen:
                seen.add(t)
                queue.append(prod)
    return len(seen) == total

def has_distinct_eigenvalues(M, q):
    tr = int((M[0, 0] + M[1, 1]) % q)
    det = mat_det(M, q)
    disc = (tr * tr - 4 * det) % q
    if disc == 0:
        return False
    if q == 2:
        return disc != 0
    return pow(int(disc), (q - 1) // 2, q) == 1

def is_transverse_pair(g, h, q):
    tr = int((g[0, 0] + g[1, 1]) % q)
    det = mat_det(g, q)
    disc = (tr * tr - 4 * det) % q
    if disc == 0:
        return False
    sqrt_disc = None
    for x in range(q):
        if (x * x) % q == disc:
            sqrt_disc = x
            break
    if sqrt_disc is None:
        return False
    inv2 = pow(2, q - 2, q) if q > 2 else 0
    lam1 = (tr + sqrt_disc) * inv2 % q
    lam2 = (tr - sqrt_disc) * inv2 % q
    if lam1 == lam2:
        return False
    vecs = []
    for lam in [lam1, lam2]:
        A_mat = (g - lam * np.eye(2, dtype=int)) % q
        if A_mat[0, 0] == 0 and A_mat[0, 1] == 0:
            v = np.array([1, 0], dtype=int)
        elif A_mat[0, 0] != 0:
            v = np.array([(-A_mat[0, 1]) % q, A_mat[0, 0] % q], dtype=int)
        else:
            v = np.array([1, 0], dtype=int)
        vecs.append(v)
    v1, v2 = vecs
    hv1 = mat_mul(h, v1.reshape(2, 1), q).flatten() % q
    hv2 = mat_mul(h, v2.reshape(2, 1), q).flatten() % q
    def is_scalar_multiple(u, v, q):
        for i in range(len(v)):
            if v[i] != 0:
                c = u[i] * pow(int(v[i]), q - 2, q) % q
                return all((u[j] - c * v[j]) % q == 0 for j in range(len(v)))
        return all(x == 0 for x in u)
    p = ((is_scalar_multiple(hv1, v1, q) and is_scalar_multiple(hv2, v2, q)) or
         (is_scalar_multiple(hv1, v2, q) and is_scalar_multiple(hv2, v1, q)))
    return not p


# =================== VISUALIZATION ===================

def main():
    q = 5
    total = gl2_order(q)
    
    # Enumerate GL(2, F_q)
    gl2 = []
    for a, b, c, d in iterproduct(range(q), repeat=4):
        M = np.array([[a, b], [c, d]], dtype=int)
        if mat_det(M, q) != 0:
            gl2.append(M)
    
    # Find generating pairs and compute growth trajectories
    random.seed(42)
    trajectories = []
    labels = []
    colors_list = []
    
    for trial in range(500):
        if len(trajectories) >= 12:
            break
        g = random.choice(gl2)
        h = random.choice(gl2)
        if not generates_gl2(g, h, q):
            continue
        
        A = symmetric_closure(g, h, q)
        sizes = [len(A)]
        current = A
        for step in range(1, 10):
            current = product_set(current, A, q)
            sizes.append(len(current))
            if len(current) == total:
                break
        
        transverse = is_transverse_pair(g, h, q)
        trajectories.append(sizes)
        labels.append(f"|A|={sizes[0]}, {'T' if transverse else 'NT'}")
        colors_list.append('tab:blue' if transverse else 'tab:red')
    
    # Create figure with 2 subplots
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Plot 1: Growth trajectories
    for i, (traj, label, color) in enumerate(zip(trajectories, labels, colors_list)):
        steps = list(range(1, len(traj) + 1))
        ax1.plot(steps, traj, 'o-', color=color, alpha=0.7, markersize=4,
                label=label if i < 6 else None)
    
    ax1.axhline(y=total, color='green', linestyle='--', alpha=0.5, 
                label=f'|GL(2,F_{q})| = {total}')
    ax1.set_xlabel('Power n', fontsize=12)
    ax1.set_ylabel('|A^n|', fontsize=12)
    ax1.set_title(f'Product Set Growth in GL(2, F_{q})\n'
                  f'Blue = Transverse, Red = Non-transverse', fontsize=13)
    ax1.legend(fontsize=8, loc='lower right')
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Growth increments (the "growth profile")
    for i, (traj, label, color) in enumerate(zip(trajectories, labels, colors_list)):
        increments = [traj[j+1] - traj[j] for j in range(len(traj)-1)]
        steps = list(range(2, len(traj) + 1))
        ax2.plot(steps, increments, 's-', color=color, alpha=0.6, markersize=4,
                label=label if i < 6 else None)
    
    ax2.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax2.set_xlabel('Power n', fontsize=12)
    ax2.set_ylabel('|A^n| - |A^(n-1)|  (growth increment)', fontsize=12)
    ax2.set_title('Growth Profile: Increments Per Step\n'
                  'Always positive until saturation (Theorem 1)', fontsize=13)
    ax2.legend(fontsize=8, loc='upper right')
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('growth_profiles.png', dpi=150, bbox_inches='tight')
    print("Saved growth_profiles.png")


if __name__ == '__main__':
    main()
