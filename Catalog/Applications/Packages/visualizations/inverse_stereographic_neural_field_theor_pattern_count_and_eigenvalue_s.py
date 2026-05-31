import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
L = np.arange(0, 16)
dims = 2 * L + 1
axes[0].bar(L, dims, color='steelblue', alpha=0.8)
axes[0].set_xlabel('Degree l'); axes[0].set_ylabel('2l+1')
axes[0].set_title('Pattern Count per Degree')
cumul = np.cumsum(dims)
axes[1].plot(L, cumul, 'bo-', label='Σ(2l+1)')
axes[1].plot(L, (L+1)**2, 'r--', lw=2, label='(L+1)²')
axes[1].legend(); axes[1].set_title("Gauss's Sum")
evals = L * (L + 1)
axes[2].plot(L, evals, 'go-')
axes[2].set_xlabel('l'); axes[2].set_ylabel('λ_l')
axes[2].set_title('Eigenvalues l(l+1)')
plt.tight_layout()
plt.savefig('pattern_count_eigenvalues.png', dpi=150)
plt.close()