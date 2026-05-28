"""
Visualization 3: Conditional Negative Semidefiniteness

This script visualizes the key theorem: on the weighted zero-sum hyperplane,
the Hessian quadratic form is nonpositive. Shows:
- Quadratic form values for random vectors projected to the hyperplane
- The decomposition into rank-1 and Hadamard-square terms
- Comparison of the hyperplane projection effect
"""

import numpy as np
import matplotlib.pyplot as plt


def generate_psd_contraction(n, seed=None):
    rng = np.random.default_rng(seed)
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    eigs = rng.uniform(0.05, 0.95, n)
    K = Q @ np.diag(eigs) @ Q.T
    return (K + K.T) / 2


def compute_hessian_data(K):
    n = K.shape[0]
    A = np.eye(n) + K
    L = np.linalg.inv(A)
    det_A = np.linalg.det(A)
    diag = np.diag(L)
    H = det_A * (np.outer(diag, diag) - L ** 2)
    np.fill_diagonal(H, 0.0)
    return H, diag, det_A, L


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Conditional Negative Semidefiniteness of DPP Hessian',
             fontsize=16, fontweight='bold')

# Use a fixed kernel for all panels
n = 15
K = generate_psd_contraction(n, seed=42)
H, w, det_A, L = compute_hessian_data(K)
rng = np.random.default_rng(123)

# Panel 1: Quadratic form values — on vs off hyperplane
ax1 = axes[0, 0]
on_hyperplane = []
off_hyperplane = []
for _ in range(2000):
    v = rng.standard_normal(n)
    qf_off = v @ H @ v
    off_hyperplane.append(qf_off)
    
    # Project to hyperplane
    c = np.dot(w, v) / np.dot(w, w)
    v_proj = v - c * w
    qf_on = v_proj @ H @ v_proj
    on_hyperplane.append(qf_on)

ax1.hist(off_hyperplane, bins=80, alpha=0.5, color='#FF9800',
         label='General vectors', density=True)
ax1.hist(on_hyperplane, bins=80, alpha=0.5, color='#2196F3',
         label='On hyperplane (∑wᵢvᵢ=0)', density=True)
ax1.axvline(x=0, color='red', linewidth=2, linestyle='--')
ax1.set_xlabel('Quadratic form value v^T H v', fontsize=12)
ax1.set_ylabel('Density', fontsize=12)
ax1.set_title('Quadratic Form: On vs Off Hyperplane', fontsize=12)
ax1.legend(fontsize=10)

# Panel 2: Decomposition into rank-1 and Hadamard terms
ax2 = axes[0, 1]
rank1_vals = []
hadamard_vals = []
for _ in range(1000):
    v = rng.standard_normal(n)
    c = np.dot(w, v) / np.dot(w, w)
    v = v - c * w
    
    # Rank-1 term: (∑ L_ii v_i)^2
    rank1 = (np.dot(w, v)) ** 2
    # Hadamard-square term: ∑_{i,j} L_ij^2 v_i v_j
    hadamard = v @ (L ** 2) @ v
    
    rank1_vals.append(rank1 * det_A)
    hadamard_vals.append(hadamard * det_A)

ax2.scatter(hadamard_vals, rank1_vals, s=5, alpha=0.3, c='#2196F3', edgecolors='none')
max_val = max(max(hadamard_vals), max(rank1_vals)) * 1.1
ax2.plot([0, max_val], [0, max_val], 'r--', linewidth=1.5, label='y = x (breakeven)')
ax2.set_xlabel('Hadamard term: det(A) · v^T(L∘L)v', fontsize=11)
ax2.set_ylabel('Rank-1 term: det(A) · (∑Lᵢᵢvᵢ)²', fontsize=11)
ax2.set_title('Decomposition (on hyperplane: rank-1 = 0)', fontsize=12)
ax2.legend(fontsize=10)
ax2.set_xlim(left=0)
ax2.set_ylim(bottom=-0.01 * max_val)

# Panel 3: Angular distribution of quadratic form
ax3 = axes[1, 0]
# Generate vectors at various angles from the weight vector
angles = np.linspace(0, np.pi, 200)
qf_by_angle = []
for theta in angles:
    # Generate random vector, decompose into w-component and orthogonal
    v_rand = rng.standard_normal(n)
    v_orth = v_rand - (np.dot(w, v_rand) / np.dot(w, w)) * w
    v_orth = v_orth / (np.linalg.norm(v_orth) + 1e-15)
    w_norm = w / np.linalg.norm(w)
    
    v = np.cos(theta) * w_norm + np.sin(theta) * v_orth
    qf = v @ H @ v
    qf_by_angle.append(qf)

ax3.plot(np.degrees(angles), qf_by_angle, color='#2196F3', linewidth=1.5)
ax3.axhline(y=0, color='red', linewidth=1, linestyle='--')
ax3.axvline(x=90, color='green', linewidth=1.5, linestyle=':',
            label='Hyperplane (θ=90°)')
ax3.fill_between(np.degrees(angles), qf_by_angle, 0,
                 where=np.array(qf_by_angle) > 0, alpha=0.3, color='#FF9800',
                 label='Positive region')
ax3.fill_between(np.degrees(angles), qf_by_angle, 0,
                 where=np.array(qf_by_angle) <= 0, alpha=0.3, color='#2196F3',
                 label='Negative region')
ax3.set_xlabel('Angle from weight vector w (degrees)', fontsize=12)
ax3.set_ylabel('Quadratic form v^T H v', fontsize=12)
ax3.set_title('Angular Profile of Quadratic Form', fontsize=12)
ax3.legend(fontsize=9)

# Panel 4: Eigenvalue spectrum with marked positive eigenvalue
ax4 = axes[1, 1]
eigs = np.sort(np.linalg.eigvalsh(H))[::-1]
colors = ['#E91E63' if e > 1e-10 else ('#2196F3' if e < -1e-10 else '#9E9E9E')
          for e in eigs]
ax4.barh(range(len(eigs)), eigs, color=colors, edgecolor='black', linewidth=0.3)
ax4.axvline(x=0, color='black', linewidth=1)
ax4.set_ylabel('Eigenvalue index', fontsize=12)
ax4.set_xlabel('Eigenvalue', fontsize=12)
ax4.set_title(f'Hessian Spectrum (n={n}): Lorentzian Signature', fontsize=12)
ax4.invert_yaxis()

# Add annotation
num_pos = int(np.sum(np.array(eigs) > 1e-10))
num_neg = int(np.sum(np.array(eigs) < -1e-10))
ax4.text(0.95, 0.95, f'Signature: ({num_pos}+, {num_neg}−)',
         transform=ax4.transAxes, fontsize=11, verticalalignment='top',
         horizontalalignment='right',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.tight_layout()
plt.savefig('conditional_nsd.png', dpi=150, bbox_inches='tight')
print("Saved conditional_nsd.png")
