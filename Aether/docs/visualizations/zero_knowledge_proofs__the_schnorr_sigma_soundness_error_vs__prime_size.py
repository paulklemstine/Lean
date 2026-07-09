import numpy as np
import matplotlib.pyplot as plt

primes = np.array([5, 11, 23, 47, 97, 197, 397, 797])
fig, ax = plt.subplots(figsize=(8, 5))
for t in (1, 2, 3):
    ax.plot(primes, primes.astype(float) ** (-t), marker='o',
            label=f'{t}-fold repetition: p^-{t}')
ax.set_yscale('log')
ax.set_xlabel('prime modulus p')
ax.set_ylabel('soundness error (log scale)')
ax.set_title('Schnorr soundness error 1/p and parallel repetition p^-t')
ax.legend(); ax.grid(True, which='both', alpha=0.3)
fig.tight_layout()
fig.savefig('schnorr_soundness_error.png', dpi=150)
