import numpy as np
import matplotlib.pyplot as plt

xs = np.linspace(1e-6, 1.0, 400)
s = -xs * np.log(xs)
ps = np.linspace(1e-6, 1 - 1e-6, 400)
Hbin = -ps * np.log(ps) - (1 - ps) * np.log(1 - ps)

fig, ax = plt.subplots(1, 2, figsize=(11, 4))
ax[0].plot(xs, s, lw=2, color='crimson')
ax[0].scatter([0], [0], color='crimson', zorder=5)
ax[0].set_title('Surprise function  s(x) = -x log x')
ax[0].set_xlabel('x'); ax[0].set_ylabel('s(x)')
ax[0].grid(alpha=0.3)

ax[1].plot(ps, Hbin, lw=2, color='navy')
ax[1].axhline(np.log(2), ls='--', color='gray',
              label='log 2 = 1 bit')
ax[1].axvline(0.5, ls=':', color='gray')
ax[1].set_title('Binary entropy  H(p) = s(p) + s(1-p)')
ax[1].set_xlabel('p'); ax[1].set_ylabel('H(p) [nats]')
ax[1].legend(); ax[1].grid(alpha=0.3)

plt.tight_layout()
plt.savefig('entropy_curves.png', dpi=150)
print('wrote entropy_curves.png')
