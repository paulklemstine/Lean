import random
import matplotlib.pyplot as plt


def count_3aps(A: set, N: int) -> int:
    total = 0
    for a in A:
        for d in range(1, N):
            if (a + d) % N in A and (a + 2 * d) % N in A:
                total += 1
    return total


N = 101
densities = [i / 20 for i in range(1, 20)]
avg_counts = []
for dens in densities:
    trials = [count_3aps(set(random.sample(range(N), int(dens * N))), N)
              for _ in range(5)]
    avg_counts.append(sum(trials) / len(trials))
plt.figure(figsize=(8, 5))
plt.plot(densities, avg_counts, 'o-', label='observed 3-APs')
plt.plot(densities, [d ** 3 * N * N for d in densities], '--',
         label='delta^3 * N^2 (Fourier prediction)')
plt.xlabel('density delta = |A|/N')
plt.ylabel('number of 3-APs')
plt.title(f'3-AP count vs density in Z/{N}Z')
plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
plt.savefig('roth_density.png', dpi=150)
print('saved roth_density.png')
