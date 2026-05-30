"""
Visualization: Sharp Trichotomy — Three Regimes of Wreath Defect

Shows the wreath defect |Δ(k,m(k))| as a function of k for three
canonical scaling sequences:
- Subcritical: m(k) = √k  (defect → 0)
- Critical: m(k) = k      (defect ~ constant)
- Supercritical: m(k) = k² (defect → ∞)

This is the finite-group analog of the renormalization group classification
of perturbations: irrelevant, marginal, and relevant.
"""
import numpy as np
import matplotlib.pyplot as plt

# Model
C0 = 0.5
gamma = 1.0

def wreath_defect_sim(k, m):
    if k < 1:
        return 0.0
    envelope = C0 * m**gamma / k
    return envelope * (0.5 + 0.3 * np.sin(k * 0.7 + m * 0.3))

k_values = np.arange(3, 80)

# Three regimes
sub_defects = [abs(wreath_defect_sim(k, max(1, int(k**0.5)))) for k in k_values]
crit_defects = [abs(wreath_defect_sim(k, k)) for k in k_values]
super_defects = [abs(wreath_defect_sim(k, k*k)) for k in k_values]

fig, axes = plt.subplots(2, 2, figsize=(13, 10))

# Top left: Absolute defect (log scale)
ax = axes[0, 0]
ax.semilogy(k_values, sub_defects, 'b-o', markersize=3, label='Subcritical: m=⌊√k⌋', alpha=0.8)
ax.semilogy(k_values, crit_defects, 'orange', marker='s', markersize=3, label='Critical: m=k', alpha=0.8)
ax.semilogy(k_values, super_defects, 'r-^', markersize=3, label='Supercritical: m=k²', alpha=0.8)
ax.set_xlabel('k', fontsize=11)
ax.set_ylabel('|Δ(k, m(k))|', fontsize=11)
ax.set_title('Wreath Defect: Three Regimes', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Top right: Rescaled defect k·|Δ|/m
ax = axes[0, 1]
sub_rescaled = [abs(wreath_defect_sim(k, max(1, int(k**0.5)))) * k / max(1, int(k**0.5))
                for k in k_values]
crit_rescaled = [abs(wreath_defect_sim(k, k)) * k / k for k in k_values]
super_rescaled = [abs(wreath_defect_sim(k, k*k)) * k / (k*k) for k in k_values]

ax.plot(k_values, sub_rescaled, 'b-o', markersize=3, label='Subcritical', alpha=0.8)
ax.plot(k_values, crit_rescaled, 'orange', marker='s', markersize=3, label='Critical', alpha=0.8)
ax.plot(k_values, super_rescaled, 'r-^', markersize=3, label='Supercritical', alpha=0.8)
ax.axhline(y=C0*0.5, color='gray', linestyle='--', alpha=0.5, label='Expected constant')
ax.set_xlabel('k', fontsize=11)
ax.set_ylabel('k · |Δ(k,m(k))| / m(k)', fontsize=11)
ax.set_title('Rescaled Defect (should be ~constant if α=1)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim([0, 1.5])

# Bottom left: Defect envelope
ax = axes[1, 0]
k_dense = np.linspace(3, 50, 200)
for m_val in [5, 10, 20, 40]:
    envelope = C0 * m_val**gamma / k_dense
    ax.plot(k_dense, envelope, label=f'm={m_val}', linewidth=2)
ax.set_xlabel('k', fontsize=11)
ax.set_ylabel('C₀ · m^γ / k', fontsize=11)
ax.set_title('Defect Envelope Decreasing in k (Theorem 4)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim([0, 8])

# Bottom right: Inductive accumulation
ax = axes[1, 1]
m_vals = np.arange(0, 25)
delta_k = 0.3  # per-copy increment
actual_defects = [0.0]
for m in range(1, 25):
    increment = delta_k * (0.7 + 0.6 * np.random.RandomState(42 + m).random())
    actual_defects.append(actual_defects[-1] + increment)

bound = m_vals * delta_k
ax.plot(m_vals, [abs(d) for d in actual_defects], 'b-o', markersize=4,
        label='Actual |defect(k,m)|', alpha=0.8)
ax.plot(m_vals, bound, 'r--', linewidth=2, label='Bound: m · δ(k)')
ax.fill_between(m_vals, 0, bound, alpha=0.1, color='red')
ax.set_xlabel('m (number of copies)', fontsize=11)
ax.set_ylabel('Defect', fontsize=11)
ax.set_title('Inductive Defect Accumulation (Theorem 6)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('trichotomy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Trichotomy visualization saved to trichotomy.png")
