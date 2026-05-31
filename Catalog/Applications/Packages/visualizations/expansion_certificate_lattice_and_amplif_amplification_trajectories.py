import math
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
except ImportError:
    print('matplotlib not available')
    exit()

def k_fold_tensor_gap(eps, k):
    return 1.0 - (1.0 - eps) ** k

fig, ax = plt.subplots(figsize=(8, 5))
for eps in [0.1, 0.2, 0.3, 0.5, 0.7]:
    ks = list(range(21))
    gaps = [k_fold_tensor_gap(eps, k) for k in ks]
    ax.plot(ks, gaps, 'o-', label=f'eps={eps}', markersize=3)
ax.axhline(y=2/3, color='gray', linestyle='--', alpha=0.5)
ax.set_xlabel('Tensor steps k')
ax.set_ylabel('Gap')
ax.set_title('Gap Amplification')
ax.legend()
ax.grid(True, alpha=0.3)
plt.savefig('amplification.png', dpi=150)
print('Saved amplification.png')