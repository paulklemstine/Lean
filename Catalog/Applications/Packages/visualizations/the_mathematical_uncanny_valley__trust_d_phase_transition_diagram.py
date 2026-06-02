import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def valley_model(alpha, r):
    return r - alpha * r**2 * (1 - r)

alphas = np.linspace(0, 20, 500)
depths = []
for a in alphas:
    rs = np.linspace(0, 1, 10000)
    vals = np.array([valley_model(a, r) for r in rs])
    endpoint_min = min(valley_model(a, 0), valley_model(a, 1))
    depths.append(max(0, endpoint_min - np.min(vals)))

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(alphas, depths, 'b-', linewidth=2)
ax.axvline(4, color='r', linestyle='--', label='α=4 (threshold)')
ax.set_xlabel('Suspicion Sensitivity α')
ax.set_ylabel('Valley Depth')
ax.set_title('Phase Transition in Valley Depth')
ax.legend()
ax.grid(True, alpha=0.3)
fig.savefig('phase_transition.png', dpi=150)
print('Saved phase_transition.png')