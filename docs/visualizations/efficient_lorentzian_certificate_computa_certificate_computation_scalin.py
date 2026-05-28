"""
Visualization 2: Certificate Computation Scaling and Complexity

This script visualizes:
- O(n³) scaling of certificate computation
- Comparison with eigendecomposition cost
- Signature defect as a function of kernel rank
"""

import numpy as np
import matplotlib.pyplot as plt
import time


def generate_psd_contraction(n, rank=None, seed=None):
    rng = np.random.default_rng(seed)
    if rank is None:
        rank = n
    rank = min(rank, n)
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    eigs = np.zeros(n)
    eigs[:rank] = rng.uniform(0.05, 0.95, rank)
    K = Q @ np.diag(eigs) @ Q.T
    return (K + K.T) / 2


def compute_certificate_timed(K):
    n = K.shape[0]
    start = time.perf_counter()
    A = np.eye(n) + K
    L = np.linalg.inv(A)
    det_A = np.linalg.det(A)
    diag_L = np.diag(L)
    H = det_A * (np.outer(diag_L, diag_L) - L ** 2)
    np.fill_diagonal(H, 0.0)
    cert_time = time.perf_counter() - start

    start = time.perf_counter()
    eigs = np.linalg.eigvalsh(H)
    eig_time = time.perf_counter() - start

    num_pos = int(np.sum(eigs > 1e-10))
    return cert_time, eig_time, num_pos, H, diag_L


fig, axes = plt.subplots(1, 3, figsize=(18, 5))
fig.suptitle('Lorentzian Certificate: Complexity and Scaling', fontsize=16, fontweight='bold')

# Panel 1: Computation time scaling
ax1 = axes[0]
sizes = [5, 10, 20, 30, 50, 75, 100, 150, 200, 300, 400, 500]
cert_times_avg = []
eig_times_avg = []
num_trials = 5

for n in sizes:
    ct_list, et_list = [], []
    for trial in range(num_trials):
        K = generate_psd_contraction(n, seed=trial * 1000 + n)
        ct, et, _, _, _ = compute_certificate_timed(K)
        ct_list.append(ct)
        et_list.append(et)
    cert_times_avg.append(np.mean(ct_list))
    eig_times_avg.append(np.mean(et_list))

ax1.loglog(sizes, cert_times_avg, 'o-', color='#2196F3', linewidth=2,
           markersize=6, label='Certificate (inv + det)')
ax1.loglog(sizes, eig_times_avg, 's-', color='#E91E63', linewidth=2,
           markersize=6, label='Eigendecomposition of H')
# Reference O(n^3) line
ref_sizes = np.array(sizes)
ref = ref_sizes ** 3 * cert_times_avg[0] / sizes[0] ** 3
ax1.loglog(sizes, ref, '--', color='gray', linewidth=1, label='O(n³) reference')

ax1.set_xlabel('Matrix dimension n', fontsize=12)
ax1.set_ylabel('Time (seconds)', fontsize=12)
ax1.set_title('Computation Time Scaling', fontsize=12)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Certificate cost ratio
ax2 = axes[1]
total_times = [c + e for c, e in zip(cert_times_avg, eig_times_avg)]
ratios = [c / t if t > 0 else 0 for c, t in zip(cert_times_avg, total_times)]
ax2.bar(range(len(sizes)), ratios, color='#4CAF50', alpha=0.7,
        edgecolor='black', linewidth=0.5)
ax2.set_xticks(range(len(sizes)))
ax2.set_xticklabels([str(s) for s in sizes], rotation=45)
ax2.set_xlabel('Matrix dimension n', fontsize=12)
ax2.set_ylabel('Fraction of total time', fontsize=12)
ax2.set_title('Certificate vs Total Cost Ratio', fontsize=12)
ax2.axhline(y=0.5, color='red', linestyle='--', linewidth=1, alpha=0.5)

# Panel 3: Weight vector distribution across dimensions
ax3 = axes[2]
for n, color, marker in [(5, '#2196F3', 'o'), (10, '#4CAF50', 's'),
                          (20, '#FF9800', '^'), (50, '#E91E63', 'D')]:
    K = generate_psd_contraction(n, seed=42)
    _, _, _, _, w = compute_certificate_timed(K)
    w_sorted = np.sort(w)[::-1]
    ax3.plot(range(len(w_sorted)), w_sorted, marker=marker, markersize=4,
             linewidth=1.5, color=color, label=f'n={n}', alpha=0.8)

ax3.set_xlabel('Index (sorted)', fontsize=12)
ax3.set_ylabel('Weight wᵢ = L_{ii}', fontsize=12)
ax3.set_title('Resolvent Weight Distribution', fontsize=12)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('certificate_scaling.png', dpi=150, bbox_inches='tight')
print("Saved certificate_scaling.png")
