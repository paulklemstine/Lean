"""
Visualization: Growth Exponent Heatmap for GL(2, F_q)

Creates a heatmap showing the distribution of growth exponents
log|A^3|/log|A| across different primes q, illustrating the
conjecture that this ratio stays bounded away from 1.

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


# =================== VISUALIZATION ===================

def main():
    primes = [3, 5, 7]
    
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    for idx, q in enumerate(primes):
        total = gl2_order(q)
        
        gl2 = []
        for a, b, c, d in iterproduct(range(q), repeat=4):
            M = np.array([[a, b], [c, d]], dtype=int)
            if mat_det(M, q) != 0:
                gl2.append(M)
        
        random.seed(42 + q)
        
        a_sizes = []
        a3_sizes = []
        exponents = []
        saturated_count = 0
        
        for trial in range(300):
            g = random.choice(gl2)
            h = random.choice(gl2)
            if not generates_gl2(g, h, q):
                continue
            
            A = symmetric_closure(g, h, q)
            current = A
            for _ in range(2):
                current = product_set(current, A, q)
            a3_size = len(current)
            a_size = len(A)
            
            if a3_size == total:
                saturated_count += 1
                continue
            
            if a_size > 1:
                exp = math.log(a3_size) / math.log(a_size)
                a_sizes.append(a_size)
                a3_sizes.append(a3_size)
                exponents.append(exp)
        
        ax = axes[idx]
        
        if exponents:
            # Scatter plot of |A| vs growth exponent
            scatter = ax.scatter(a_sizes, exponents, c=exponents, cmap='RdYlGn',
                               s=40, alpha=0.7, edgecolors='black', linewidth=0.5,
                               vmin=1.0, vmax=max(exponents) if exponents else 2.0)
            ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Exponent = 1')
            if exponents:
                min_exp = min(exponents)
                ax.axhline(y=min_exp, color='blue', linestyle=':', alpha=0.5, 
                          label=f'Min = {min_exp:.3f}')
            plt.colorbar(scatter, ax=ax, label='Growth exponent')
        
        ax.set_xlabel('|A| (generator set size)', fontsize=11)
        ax.set_ylabel('log|A³| / log|A|', fontsize=11)
        ax.set_title(f'GL(2, F_{q})\n|G|={total}, {len(exponents)} non-sat. pairs, '
                    f'{saturated_count} saturated', fontsize=11)
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(0.9, max(exponents + [2.0]) * 1.05 if exponents else 2.5)
    
    plt.suptitle('Growth Exponents for Generating Pairs in GL(2, F_q)\n'
                 'Conjecture: exponent stays bounded away from 1', 
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('growth_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved growth_heatmap.png")


if __name__ == '__main__':
    main()
