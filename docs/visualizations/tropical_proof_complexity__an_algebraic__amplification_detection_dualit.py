import math
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np
except ImportError:
    print('matplotlib/numpy not available')
    exit(0)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Tropical Proof Complexity', fontsize=14, fontweight='bold')

ks = np.arange(1, 51)
for eps in [0.5, 0.3, 0.1]:
    axes[0,0].semilogy(ks, eps**ks, label=f'ε={eps}', linewidth=2)
axes[0,0].set_xlabel('Repetitions k')
axes[0,0].set_ylabel('Error ε^k')
axes[0,0].set_title('(a) Error Decay')
axes[0,0].legend()
axes[0,0].grid(True, alpha=0.3)

for eps in [0.5, 0.3, 0.1]:
    axes[0,1].plot(ks, ks*(-math.log(eps)), label=f'ε={eps}', linewidth=2)
axes[0,1].set_xlabel('Repetitions k')
axes[0,1].set_ylabel('Tropical Cost')
axes[0,1].set_title('(b) Cost Scaling')
axes[0,1].legend()
axes[0,1].grid(True, alpha=0.3)

qs = np.arange(1, 101)
for d in [0.05, 0.1, 0.2]:
    axes[1,0].semilogy(qs, (1-d)**qs, linewidth=2, label=f'δ={d}')
    axes[1,0].semilogy(qs, np.exp(-d*qs), '--', linewidth=1, alpha=0.5)
axes[1,0].set_xlabel('Queries q')
axes[1,0].set_ylabel('Miss Probability')
axes[1,0].set_title('(c) Oracle Detection')
axes[1,0].legend()
axes[1,0].grid(True, alpha=0.3)

bits = np.arange(10, 260, 5)
for eps in [0.5, 0.3, 0.1]:
    axes[1,1].plot(bits, np.ceil(bits*math.log(2)/(-math.log(eps))), label=f'ε={eps}', linewidth=2)
axes[1,1].set_xlabel('Security (bits)')
axes[1,1].set_ylabel('Min Rounds')
axes[1,1].set_title('(d) Security Thresholds')
axes[1,1].legend()
axes[1,1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_proof_complexity.png', dpi=150)
print('Saved tropical_proof_complexity.png')
