import numpy as np
import matplotlib.pyplot as plt

p, g, x = 23, 5, 8
Y = (x * g) % p

# Honest: index by (r, c) -> transcript (r*g, c, r + c*x)
honest = np.zeros((p, p), dtype=int)  # rows = challenge c, cols = response s
for r in range(p):
    for c in range(p):
        s = (r + c * x) % p
        honest[c, s] += 1

# Simulated: index by (c, s) -> transcript (s*g - c*Y, c, s)
sim = np.zeros((p, p), dtype=int)
for c in range(p):
    for s in range(p):
        sim[c, s] += 1

fig, axes = plt.subplots(1, 2, figsize=(11, 5))
for ax, data, title in ((axes[0], honest, 'Honest'),
                        (axes[1], sim, 'Simulated')):
    im = ax.imshow(data, cmap='viridis', origin='lower')
    ax.set_title(f'{title} transcript counts')
    ax.set_xlabel('response s'); ax.set_ylabel('challenge c')
    fig.colorbar(im, ax=ax)
fig.suptitle('Perfect HVZK: honest and simulated distributions coincide')
fig.tight_layout()
fig.savefig('schnorr_hvzk_heatmaps.png', dpi=150)
print('identical:', bool(np.array_equal(honest, sim)))
