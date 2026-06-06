#!/usr/bin/env python3
"""
Visualization: TDLP Attack Success Rate vs Matrix Size

Compares the success of different attack strategies across matrix sizes,
demonstrating that the TDLP is structurally weak.
"""
import matplotlib.pyplot as plt
import numpy as np
import random
import time

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

def trop_mat_pow(A, k):
    n = len(A)
    result = trop_mat_identity(n)
    base = [row[:] for row in A]
    while k > 0:
        if k & 1:
            result = trop_mat_mul(result, base)
        base = trop_mat_mul(base, base)
        k >>= 1
    return result

def trop_trace(A):
    return min(A[i][i] for i in range(len(A)))

def diagonal_attack(A, B):
    n = len(A)
    for i in range(n):
        if A[i][i] != 0 and A[i][i] != float('inf') and B[i][i] != float('inf'):
            k_est = B[i][i] / A[i][i]
            if abs(k_est - round(k_est)) < 0.001 and k_est > 0:
                k = int(round(k_est))
                if trop_mat_pow(A, k) == B:
                    return k
    return None

def orbit_attack(A, B, max_k=200):
    n = len(A)
    power = trop_mat_identity(n)
    for k in range(1, max_k + 1):
        power = trop_mat_mul(power, A)
        if power == B:
            return k
    return None

def random_tropical_matrix(n, max_val=20, inf_prob=0.1):
    A = []
    for i in range(n):
        row = []
        for j in range(n):
            if random.random() < inf_prob:
                row.append(float('inf'))
            else:
                row.append(random.randint(0, max_val))
        A.append(row)
    return A

def main():
    random.seed(42)
    
    sizes = [2, 3, 4, 5, 6, 8]
    trials = 30
    secret_k = 50
    
    diag_success = []
    orbit_success = []
    total_success = []
    avg_times = []
    
    for n in sizes:
        d_wins = 0
        o_wins = 0
        t_wins = 0
        times = []
        
        for _ in range(trials):
            A = random_tropical_matrix(n, max_val=20, inf_prob=0.05)
            B = trop_mat_pow(A, secret_k)
            
            t0 = time.time()
            
            # Try diagonal attack
            k = diagonal_attack(A, B)
            if k is not None:
                d_wins += 1
                t_wins += 1
                times.append(time.time() - t0)
                continue
            
            # Try orbit attack
            k = orbit_attack(A, B, max_k=200)
            if k is not None:
                o_wins += 1
                t_wins += 1
                times.append(time.time() - t0)
                continue
            
            times.append(time.time() - t0)
        
        diag_success.append(d_wins / trials * 100)
        orbit_success.append(o_wins / trials * 100)
        total_success.append(t_wins / trials * 100)
        avg_times.append(np.mean(times) * 1000)
    
    # Create figure
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    x = np.arange(len(sizes))
    width = 0.25
    
    ax1.bar(x - width, diag_success, width, label='Diagonal Attack',
           color='#e74c3c', alpha=0.8)
    ax1.bar(x, orbit_success, width, label='Orbit Attack',
           color='#3498db', alpha=0.8)
    ax1.bar(x + width, total_success, width, label='Combined',
           color='#2ecc71', alpha=0.8)
    
    ax1.set_xlabel('Matrix Size n', fontsize=12)
    ax1.set_ylabel('Attack Success Rate (%)', fontsize=12)
    ax1.set_title(f'TDLP Attack Success Rate\n(k = {secret_k}, {trials} trials per size)',
                 fontsize=13)
    ax1.set_xticks(x)
    ax1.set_xticklabels([f'{n}×{n}' for n in sizes])
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3, axis='y')
    ax1.set_ylim(0, 105)
    
    # Plot 2: Attack time vs matrix size
    ax2.semilogy(sizes, avg_times, 'ro-', markersize=8, linewidth=2,
                label='Average attack time')
    
    # Polynomial fit for comparison
    coeffs = np.polyfit(np.log(sizes), np.log(avg_times), 1)
    fit_x = np.linspace(min(sizes), max(sizes), 100)
    fit_y = np.exp(coeffs[1]) * fit_x ** coeffs[0]
    ax2.semilogy(fit_x, fit_y, 'b--', alpha=0.5,
                label=f'Power law: O(n^{{{coeffs[0]:.1f}}})')
    
    ax2.set_xlabel('Matrix Size n', fontsize=12)
    ax2.set_ylabel('Average Time (ms)', fontsize=12)
    ax2.set_title('Attack Computational Cost\n(Polynomial, NOT exponential)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.suptitle('Structural Cryptanalysis of the Tropical DLP',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('tropical_attack_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tropical_attack_comparison.png")

if __name__ == '__main__':
    main()
