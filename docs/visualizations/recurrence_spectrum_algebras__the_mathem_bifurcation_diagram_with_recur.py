import numpy as np
try:
    import matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot as plt
except: exit(0)
fig, ax = plt.subplots(figsize=(12,6))
r_vals = np.linspace(2.5, 4.0, 2000)
for r in r_vals:
    x = 0.5
    for _ in range(500): x = r*x*(1-x)
    xs = []
    for _ in range(200): x = r*x*(1-x); xs.append(x)
    ax.scatter([r]*200, xs, s=0.02, c='black', alpha=0.3)
ax.axvline(3.8284, color='red', ls='--', alpha=0.7, label='Period-3')
ax.set_xlabel('r'); ax.set_ylabel('x'); ax.set_title('Logistic Map Bifurcation')
ax.legend(); plt.tight_layout(); plt.savefig('bifurcation.png', dpi=150)