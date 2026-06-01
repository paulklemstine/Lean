import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
n, steps, c, target = 8, 30, 0.7, 0.5
rng = np.random.default_rng(42)
ax = axes[0]
for _ in range(5):
    init = rng.random(n)
    traj = [init.copy()]
    current = init.copy()
    for _ in range(steps):
        current = c * current + (1-c) * target
        traj.append(current.copy())
    traj = np.array(traj)
    for j in range(n):
        ax.plot(range(steps+1), traj[:, j], alpha=0.5, linewidth=0.8)
ax.axhline(y=target, color='red', linestyle='--', linewidth=2)
ax.set_title('Contraction Convergence')
ax.set_xlabel('Step')
ax.set_ylabel('Score')

ax = axes[1]
for c_val in [0.3, 0.5, 0.7, 0.9]:
    diffs = []
    f, g = np.array([0.0, 0.2, 0.8, 1.0]), np.array([0.5]*4)
    for m in range(40):
        diffs.append(np.max(np.abs(f - g)))
        f = c_val*f + (1-c_val)*0.5
        g = c_val*g + (1-c_val)*0.5
    ax.semilogy(range(40), diffs, label=f'c={c_val}')
ax.set_title('Exponential Decay')
ax.legend()
ax.grid(True, alpha=0.3)

ax = axes[2]
thresholds = np.array([0.3, 0.5, 0.7])
scores = np.linspace(0, 1, 200)
tiers = [int(np.sum(thresholds <= s)) for s in scores]
ax.plot(scores, tiers, 'b-', linewidth=2)
for t in thresholds:
    ax.axvline(x=t, color='red', linestyle='--', alpha=0.5)
ax.set_title('Phase Transitions')
plt.tight_layout()
plt.savefig('convergence_dynamics.png', dpi=150)
plt.close()