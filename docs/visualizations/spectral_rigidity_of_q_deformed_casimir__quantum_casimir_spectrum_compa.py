import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def q_integer(q, n):
    if n == 0: return 0.0
    return sum(q**(n-1-2*k) for k in range(n))

def q_casimir(q, n):
    return q_integer(q, n) * q_integer(q, n+1)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

ns = np.arange(0, 12)
for q_val in [0.5, 0.8, 1.0, 1.2, 1.5, 2.0]:
    eigs = [q_casimir(q_val, n) for n in ns]
    style = '--' if q_val == 1.0 else '-'
    axes[0,0].plot(ns, eigs, style, linewidth=1.5, label=f'q={q_val}', marker='o', markersize=4)
axes[0,0].set_xlabel('n'); axes[0,0].set_ylabel('λ_n(q)')
axes[0,0].set_title('q-Casimir Eigenvalues'); axes[0,0].legend(fontsize=8)
axes[0,0].set_yscale('log'); axes[0,0].set_ylim(bottom=0.5); axes[0,0].grid(True, alpha=0.3)

ns2 = np.arange(0, 10)
for q_val in [0.5, 0.8, 1.0, 1.5, 2.0]:
    qints = [q_integer(q_val, n) for n in ns2]
    style = '--' if q_val == 1.0 else '-'
    axes[0,1].plot(ns2, qints, style, linewidth=1.5, label=f'q={q_val}', marker='s', markersize=4)
axes[0,1].set_xlabel('n'); axes[0,1].set_ylabel('[n]_q')
axes[0,1].set_title('q-Integers'); axes[0,1].legend(fontsize=8); axes[0,1].grid(True, alpha=0.3)

q_values = np.linspace(0.2, 5.0, 200)
for n in [2, 3, 5, 8]:
    qints = [q_integer(q, n) for q in q_values]
    axes[1,0].plot(q_values, qints, linewidth=1.5, label=f'[{n}]_q')
axes[1,0].axvline(x=1.0, color='gray', linestyle=':', alpha=0.5)
axes[1,0].set_xlabel('q'); axes[1,0].set_ylabel('[n]_q')
axes[1,0].set_title('Weyl Symmetry: [n]_q = [n]_{q⁻¹}'); axes[1,0].legend(fontsize=8); axes[1,0].grid(True, alpha=0.3)

q_vals = np.linspace(0.15, 6.0, 500)
f_vals = q_vals + 1.0/q_vals
axes[1,1].plot(q_vals, f_vals, 'b-', linewidth=2, label='f(q) = q + q⁻¹')
axes[1,1].axhline(y=2.0, color='red', linestyle='--', alpha=0.5, label='min = 2')
axes[1,1].set_xlabel('q'); axes[1,1].set_ylabel('q + q⁻¹')
axes[1,1].set_title('Spectral Rigidity'); axes[1,1].legend(fontsize=8)
axes[1,1].set_ylim(1.5, 8); axes[1,1].grid(True, alpha=0.3)

plt.suptitle('Quantum Casimir Spectral Theory', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('quantum_casimir_spectrum.png', dpi=150, bbox_inches='tight')
print('Saved: quantum_casimir_spectrum.png')