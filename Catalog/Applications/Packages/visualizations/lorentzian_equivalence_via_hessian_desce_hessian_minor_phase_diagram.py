"""
Visualization: 2×2 Principal Minor Lemma for Lorentzian Matrices

Visualizes the key theorem that matrices with at most one positive eigenvalue
have all 2×2 principal minors nonpositive. Shows the boundary between
Lorentzian and non-Lorentzian regions in the (a, c, b) parameter space
for 2×2 symmetric matrices [[a, b], [b, c]].
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

# Generate the parameter space for 2×2 symmetric matrix [[a, b], [b, c]]
# Fix a = 1 and vary b, c to show the region where at most one positive eigenvalue

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Phase diagram in (b, c) space with a = 1
ax = axes[0]
b_range = np.linspace(-3, 3, 300)
c_range = np.linspace(-3, 3, 300)
B, C = np.meshgrid(b_range, c_range)
a = 1.0

# Eigenvalues of [[a, b], [b, c]]
tr = a + C
det = a * C - B**2
disc = np.sqrt(np.maximum((a - C)**2 + 4*B**2, 0))
lam1 = (tr + disc) / 2  # larger eigenvalue
lam2 = (tr - disc) / 2  # smaller eigenvalue

num_pos = (lam1 > 1e-10).astype(int) + (lam2 > 1e-10).astype(int)

colors = ['#2ecc71', '#f39c12', '#e74c3c']  # 0, 1, 2 positive eigenvalues
cmap = LinearSegmentedColormap.from_list('eig', colors, N=3)

im = ax.contourf(B, C, num_pos, levels=[-0.5, 0.5, 1.5, 2.5],
                  colors=colors, alpha=0.7)
# Draw the minor condition boundary: ac = b^2, i.e., c = b^2
b_curve = np.linspace(-3, 3, 500)
c_curve = b_curve**2 / a
ax.plot(b_curve, c_curve, 'k-', linewidth=2, label='$ac = b^2$ (minor boundary)')
ax.set_xlabel('$b$', fontsize=12)
ax.set_ylabel('$c$', fontsize=12)
ax.set_title('Eigenvalue phases ($a = 1$)', fontsize=13)
ax.legend(loc='upper left', fontsize=9)
ax.set_xlim(-3, 3)
ax.set_ylim(-3, 3)

# Add text labels
ax.text(0, 2.5, '2 pos.', fontsize=10, ha='center', color='darkred', weight='bold')
ax.text(0, -1.5, '0 pos.', fontsize=10, ha='center', color='darkgreen', weight='bold')
ax.text(2.5, -0.5, '1 pos.', fontsize=10, ha='center', color='#8B6914', weight='bold')

# Panel 2: The minor ratio A(i,i)*A(j,j)/A(i,j)^2 for random Lorentzian matrices
ax = axes[1]
rng = np.random.default_rng(42)
ratios_lor = []
ratios_nonlor = []

for _ in range(2000):
    n = rng.integers(3, 7)
    M = rng.standard_normal((n, n))
    A = -M @ M.T  # NSD
    v = rng.uniform(0.1, 3, size=n)
    lam = rng.uniform(0, 5)
    A = A + lam * np.outer(v, v)

    eigenvalues = np.linalg.eigvalsh(A)
    num_pos_eig = np.sum(eigenvalues > 1e-10)

    for i in range(n):
        for j in range(i + 1, n):
            if abs(A[i, j]) > 1e-10:
                ratio = A[i, i] * A[j, j] / (A[i, j]**2)
                if num_pos_eig <= 1:
                    ratios_lor.append(ratio)
                else:
                    ratios_nonlor.append(min(ratio, 5))

ratios_lor = [min(r, 5) for r in ratios_lor]
ratios_nonlor = [min(r, 5) for r in ratios_nonlor]

ax.hist(ratios_lor, bins=50, range=(-5, 5), alpha=0.6, color='#2ecc71',
        label='≤ 1 pos. eigenvalue', density=True)
ax.hist(ratios_nonlor, bins=50, range=(-5, 5), alpha=0.6, color='#e74c3c',
        label='> 1 pos. eigenvalue', density=True)
ax.axvline(x=1, color='black', linestyle='--', linewidth=1.5, label='$A_{ii}A_{jj} = A_{ij}^2$')
ax.set_xlabel('$A_{ii} A_{jj} / A_{ij}^2$', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.set_title('Principal minor ratio distribution', fontsize=13)
ax.legend(fontsize=9)
ax.set_xlim(-5, 5)

# Panel 3: Certificate pass rate vs Lorentzian for random polynomials
ax = axes[2]

def check_polynomial(n, d, seed):
    """Check certificate and spectral conditions for a random polynomial."""
    rng_local = np.random.default_rng(seed)
    indices = []
    def gen_mi(nn, dd):
        if nn == 0:
            return [()] if dd == 0 else []
        if nn == 1:
            return [(dd,)]
        res = []
        for k in range(dd + 1):
            for rest in gen_mi(nn - 1, dd - k):
                res.append((k,) + rest)
        return res

    indices = gen_mi(n, d)
    coeffs = {idx: rng_local.uniform(0.1, 5.0) for idx in indices}

    # Check mixed log-concavity
    mixed_ok = True
    if d >= 2:
        leaf_indices = gen_mi(n, d - 2)
        for m in leaf_indices:
            for i in range(n):
                for j in range(i, n):
                    ei = tuple(1 if k == i else 0 for k in range(n))
                    ej = tuple(1 if k == j else 0 for k in range(n))
                    m_ii = tuple(mk + 2 * eik for mk, eik in zip(m, ei))
                    m_jj = tuple(mk + 2 * ejk for mk, ejk in zip(m, ej))
                    m_ij = tuple(mk + eik + ejk for mk, eik, ejk in zip(m, ei, ej))
                    c_ii = coeffs.get(m_ii, 0)
                    c_jj = coeffs.get(m_jj, 0)
                    c_ij = coeffs.get(m_ij, 0)
                    if c_ii * c_jj > c_ij**2 + 1e-10:
                        mixed_ok = False
                        break
                if not mixed_ok:
                    break
            if not mixed_ok:
                break

    # Check spectral condition (simplified for small cases)
    spectral_ok = True
    if d >= 2:
        leaf_indices = gen_mi(n, d - 2)
        for alpha in leaf_indices[:20]:  # Check first 20 leaves
            # Compute iterated derivative
            from collections import defaultdict
            current = dict(coeffs)
            for var in range(n):
                for _ in range(alpha[var]):
                    new_current = defaultdict(float)
                    for idx, c in current.items():
                        if idx[var] > 0:
                            new_idx = list(idx)
                            factor = new_idx[var]
                            new_idx[var] -= 1
                            new_current[tuple(new_idx)] += c * factor
                    current = dict(new_current)
            # Compute Hessian
            H = np.zeros((n, n))
            for i_h in range(n):
                for j_h in range(n):
                    target = [0] * n
                    target[i_h] += 1
                    target[j_h] += 1
                    target_t = tuple(target)
                    c_val = current.get(target_t, 0)
                    factor = 1
                    if i_h == j_h:
                        factor = 2
                    elif target_t in current:
                        factor = 1
                    H[i_h, j_h] = c_val * factor if i_h == j_h else c_val
            eigenvalues = np.linalg.eigvalsh(H)
            if np.sum(eigenvalues > 1e-10) > 1:
                spectral_ok = False
                break

    return mixed_ok, spectral_ok

params = [(2, 2), (2, 3), (2, 4), (3, 2), (3, 3), (4, 2)]
param_labels = [f"n={n},d={d}" for n, d in params]
cert_rates = []
lor_rates = []
agreement_rates = []

for n, d in params:
    n_tests = 100
    n_mixed = 0
    n_spec = 0
    n_agree = 0
    for seed in range(n_tests):
        m_ok, s_ok = check_polynomial(n, d, seed + 9999)
        if m_ok:
            n_mixed += 1
        if s_ok:
            n_spec += 1
        if m_ok == s_ok:
            n_agree += 1
    cert_rates.append(n_mixed / n_tests * 100)
    lor_rates.append(n_spec / n_tests * 100)
    agreement_rates.append(n_agree / n_tests * 100)

x = np.arange(len(params))
width = 0.3
ax.bar(x - width, cert_rates, width, label='Certificate pass rate', color='#3498db', alpha=0.8)
ax.bar(x, lor_rates, width, label='Lorentzian (spectral)', color='#2ecc71', alpha=0.8)
ax.bar(x + width, agreement_rates, width, label='Agreement rate', color='#9b59b6', alpha=0.8)
ax.set_xlabel('Parameters', fontsize=12)
ax.set_ylabel('Rate (%)', fontsize=12)
ax.set_title('Certificate vs Spectral condition', fontsize=13)
ax.set_xticks(x)
ax.set_xticklabels(param_labels, fontsize=9, rotation=20)
ax.legend(fontsize=9)
ax.set_ylim(0, 105)

plt.tight_layout()
plt.savefig('viz_hessian_minor.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_hessian_minor.png")
