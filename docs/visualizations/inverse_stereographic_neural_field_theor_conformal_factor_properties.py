import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def conformal_factor(r_sq):
    return 2.0 / (1.0 + r_sq)

fig, axes = plt.subplots(1, 3, figsize=(15, 4))
r_sq = np.linspace(0, 20, 200)
sigma = conformal_factor(r_sq)
axes[0].plot(r_sq, sigma, 'b-', lw=2)
axes[0].set_xlabel('r²'); axes[0].set_ylabel('σ(r²)')
axes[0].set_title('Conformal Factor'); axes[0].grid(True, alpha=0.3)
r_sq2 = np.linspace(1, 50, 200)
axes[1].semilogy(r_sq2, conformal_factor(r_sq2), 'b-', lw=2, label='σ')
axes[1].semilogy(r_sq2, 2.0/r_sq2, 'r--', lw=2, label='2/r²')
axes[1].legend(); axes[1].set_title('Decay Bound'); axes[1].grid(True, alpha=0.3)
for l in [1,2,3,5]:
    axes[2].semilogy(r_sq2, conformal_factor(r_sq2)**l, lw=2, label=f'σ^{l}')
axes[2].legend(); axes[2].set_title('Pattern Decay'); axes[2].grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('conformal_factor_properties.png', dpi=150)
plt.close()