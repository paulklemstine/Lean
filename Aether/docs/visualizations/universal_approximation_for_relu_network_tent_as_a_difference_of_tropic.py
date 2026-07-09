"""Visualization: a ReLU-built tent as a difference of two tropical polynomials,
plus the empirical O(1/N) and O(1/N^2) approximation rates.

Requires matplotlib and numpy.  Saves tropical_relu_demo.png.
"""
import numpy as np
import matplotlib.pyplot as plt


def tent(x):
    return np.maximum(0.0, 1.0 - np.abs(2.0 * x - 1.0))


def pl_interp(g, N, x):
    nodes = np.linspace(0, 1, N + 1)
    vals = g(nodes)
    return np.interp(x, nodes, vals)


fig, ax = plt.subplots(1, 2, figsize=(12, 5))

x = np.linspace(0, 1, 600)
# Tent = G - H : G(x)=min(2x, 2-2x) shifted; show concave parts and the bump.
G = np.minimum(2 * x, 2 - 2 * x)          # concave tropical polynomial
H = np.zeros_like(x)                       # trivial subtrahend here
ax[0].plot(x, tent(x), 'k', lw=2.5, label='tent  T = G - H')
ax[0].plot(x, G, '--', color='tab:blue', label='G = min(2x, 2-2x)  (concave)')
ax[0].plot([0, 1], [0, 0], ':', color='tab:red', label='endpoint chord')
ax[0].fill_between(x, 0, tent(x), alpha=0.12, color='tab:green')
ax[0].set_title('A unimodal bump needs the rational form')
ax[0].legend(); ax[0].set_xlabel('x')

Ns = np.array([4, 8, 16, 32, 64, 128])
g_lip = lambda t: np.abs(t - 1/3)
g_smooth = lambda t: t ** 2
xs = np.linspace(0, 1, 4001)
err_lip = [np.max(np.abs(g_lip(xs) - pl_interp(g_lip, N, xs))) for N in Ns]
err_sm = [np.max(np.abs(g_smooth(xs) - pl_interp(g_smooth, N, xs))) for N in Ns]
ax[1].loglog(Ns, err_lip, 'o-', label='Lipschitz target  (slope -1)')
ax[1].loglog(Ns, err_sm, 's-', label='C^{1,1} target  (slope -2)')
ax[1].loglog(Ns, 0.45 / Ns, 'k--', alpha=0.5)
ax[1].loglog(Ns, 0.25 / Ns ** 2, 'k:', alpha=0.5)
ax[1].set_title('Monomial count controls the rate')
ax[1].set_xlabel('N (monomials ~ O(N))'); ax[1].set_ylabel('sup error')
ax[1].legend()

plt.tight_layout()
plt.savefig('tropical_relu_demo.png', dpi=140)
print('saved tropical_relu_demo.png')
