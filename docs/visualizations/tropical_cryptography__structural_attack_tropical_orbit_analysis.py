#!/usr/bin/env python3
"""
Visualization: Tropical Matrix Power Orbit and Eigenvalue Convergence

Shows how the tropical trace (minimum diagonal entry) of A^k converges
to the tropical eigenvalue, demonstrating the subadditivity attack.
"""
import matplotlib.pyplot as plt
import numpy as np

def trop_add(a, b):
    return min(a, b)

def trop_mul(a, b):
    if a == float('inf') or b == float('inf'):
        return float('inf')
    return a + b

def trop_mat_mul(A, B):
    n = len(A)
    C = [[float('inf')] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = trop_add(C[i][j], trop_mul(A[i][k], B[k][j]))
    return C

def trop_mat_identity(n):
    I = [[float('inf')] * n for _ in range(n)]
    for i in range(n):
        I[i][i] = 0
    return I

def trop_trace(A):
    return min(A[i][i] for i in range(len(A)))

def main():
    # Test matrix
    A = [[2, 5, 1, 8],
         [3, 4, 7, 2],
         [6, 1, 3, 5],
         [4, 8, 2, 6]]

    max_k = 30
    traces = []
    mean_traces = []
    diag_entries = {i: [] for i in range(4)}
    
    power = trop_mat_identity(4)
    for k in range(1, max_k + 1):
        power = trop_mat_mul(power, A)
        tr = trop_trace(power)
        traces.append(tr)
        mean_traces.append(tr / k)
        for i in range(4):
            diag_entries[i].append(power[i][i])

    # Create figure with 3 subplots
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Diagonal entries showing subadditivity
    ks = list(range(1, max_k + 1))
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    for i in range(4):
        axes[0].plot(ks, diag_entries[i], '-o', markersize=3,
                    color=colors[i], label=f'(A^k)_{{{i}{i}}}')
    axes[0].set_xlabel('Power k', fontsize=12)
    axes[0].set_ylabel('Diagonal entry value', fontsize=12)
    axes[0].set_title('Diagonal Entries of A^k\n(Subadditive sequences)', fontsize=13)
    axes[0].legend(fontsize=9)
    axes[0].grid(True, alpha=0.3)

    # Plot 2: Trace and subadditivity bound
    axes[1].plot(ks, traces, 'b-o', markersize=3, label='tr(A^k) = min diag')
    # Show subadditivity: tr(A^{m+k}) ≤ tr(A^m) + tr(A^k)
    bound = [traces[0] * k for k in ks]
    axes[1].plot(ks, bound, 'r--', alpha=0.7, label=f'k · tr(A) = k · {traces[0]}')
    axes[1].set_xlabel('Power k', fontsize=12)
    axes[1].set_ylabel('Tropical trace', fontsize=12)
    axes[1].set_title('Tropical Trace: tr(A^k)\n(Linear bound from subadditivity)', fontsize=13)
    axes[1].legend(fontsize=9)
    axes[1].grid(True, alpha=0.3)

    # Plot 3: Convergence to tropical eigenvalue
    axes[2].plot(ks, mean_traces, 'g-o', markersize=3, label='tr(A^k) / k')
    eigenvalue = min(mean_traces)
    axes[2].axhline(y=eigenvalue, color='r', linestyle='--', alpha=0.7,
                   label=f'λ(A) ≈ {eigenvalue:.3f}')
    axes[2].set_xlabel('Power k', fontsize=12)
    axes[2].set_ylabel('Normalized trace', fontsize=12)
    axes[2].set_title('Convergence to Tropical Eigenvalue\nλ(A) = lim tr(A^k)/k', fontsize=13)
    axes[2].legend(fontsize=9)
    axes[2].grid(True, alpha=0.3)

    plt.suptitle('Tropical Matrix Power Analysis: Walk Concatenation & Eigenvalue Attack',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('tropical_orbit_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tropical_orbit_analysis.png")

if __name__ == '__main__':
    main()
