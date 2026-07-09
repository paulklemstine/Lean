import math
import numpy as np
import matplotlib.pyplot as plt

def rho(s, x):
    return np.exp(-math.pi * x**2 / s**2)

xs = np.linspace(-8, 8, 400)
fig, ax = plt.subplots(figsize=(8, 5))
for s in [1.0, 2.0, 3.0]:
    ax.plot(xs, rho(s, xs), label=f'rho_s, s={s}')
pts = np.arange(-8, 9)
s = 2.0
w = rho(s, pts); w = w / w.sum()
ax.stem(pts, w, linefmt='C3-', markerfmt='C3o', basefmt=' ',
        label='discrete Gaussian (s=2)')
ax.set_xlabel('x'); ax.set_ylabel('weight / mass')
ax.set_title('Gaussian weight and discrete Gaussian')
ax.legend(); fig.tight_layout()
fig.savefig('gaussian_weights.png', dpi=150)
print('saved gaussian_weights.png')
