import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def conductor_count(d, Q, B):
    return Q * ((2 * (2 * B + 1)) ** d)

B = 5
Q_values = np.arange(1, 101)
fig, axes = plt.subplots(1, 2, figsize=(14, 6))
for d in [1, 2, 3, 4]:
    counts = [conductor_count(d, int(Q), B) for Q in Q_values]
    axes[0].plot(Q_values, counts, label=f'd={d}', linewidth=2)
    axes[1].plot(Q_values, counts, label=f'd={d}', linewidth=2)
axes[0].set_xlabel('Q'); axes[0].set_ylabel('N_d(Q,B)'); axes[0].set_title('Linear'); axes[0].legend(); axes[0].grid(True, alpha=0.3)
axes[1].set_xlabel('Q'); axes[1].set_ylabel('N_d(Q,B)'); axes[1].set_title('Log'); axes[1].set_yscale('log'); axes[1].legend(); axes[1].grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('counting_growth.png', dpi=150)