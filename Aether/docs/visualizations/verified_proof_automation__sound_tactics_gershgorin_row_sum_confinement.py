import numpy as np
import matplotlib.pyplot as plt

A = np.array([[4.0, -1.0, 0.0], [-1.0, 3.0, -1.0], [0.0, -1.0, 2.0]])
eig = np.linalg.eigvals(A)
B = max(np.sum(np.abs(A), axis=1))
fig, ax = plt.subplots(figsize=(6, 6))
th = np.linspace(0, 2*np.pi, 200)
for i in range(A.shape[0]):
    c = A[i, i]; r = np.sum(np.abs(A[i])) - abs(A[i, i])
    ax.plot(c + r*np.cos(th), r*np.sin(th), 'b-', alpha=0.4)
ax.plot(B*np.cos(th), B*np.sin(th), 'g--', label=f'|lambda| <= B = {B:.0f}')
ax.scatter(eig.real, eig.imag, c='red', zorder=5, label='eigenvalues')
ax.axhline(0, color='k', lw=0.5); ax.axvline(0, color='k', lw=0.5)
ax.set_aspect('equal'); ax.legend(); ax.set_title('Gershgorin discs and row-sum bound')
plt.tight_layout(); plt.savefig('gershgorin.png', dpi=150)
print('saved gershgorin.png')
