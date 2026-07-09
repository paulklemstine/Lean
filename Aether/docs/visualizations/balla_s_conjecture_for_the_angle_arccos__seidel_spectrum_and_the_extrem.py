import numpy as np
import matplotlib.pyplot as plt

rng = np.random.default_rng(0)
m = 20
U = rng.integers(0, 2, size=(m, m)) * 2 - 1  # +-1 entries
S = np.triu(U, 1)
S = S + S.T                                   # symmetric, zero diagonal
eigs = np.sort(np.linalg.eigvalsh(S.astype(float)))

plt.figure(figsize=(8, 5))
plt.plot(range(1, m + 1), eigs, 'o-')
plt.axhline(-3, color='red', ls='--', label='eigenvalue -3 threshold')
plt.xlabel('index')
plt.ylabel('eigenvalue')
plt.title('Spectrum of a symmetric 0/+-1 Seidel matrix')
plt.legend()
plt.tight_layout()
plt.savefig('seidel_spectrum.png', dpi=150)
print('saved seidel_spectrum.png')
