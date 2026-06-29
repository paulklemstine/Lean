import matplotlib.pyplot as plt
import numpy as np

def is_prime(p: int) -> bool:
    if p < 2: return False
    for d in range(2, int(p**0.5) + 1):
        if p % d == 0: return False
    return True

def apparition_lattice(b: int = 2, n_max: int = 40, p_max: int = 60) -> None:
    primes = [p for p in range(3, p_max + 1) if is_prime(p) and b % p != 0]
    grid = np.zeros((len(primes), n_max))
    for i, p in enumerate(primes):
        for n in range(1, n_max + 1):
            if (pow(b, n, p) - 1) % p == 0:
                grid[i, n - 1] = 1
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.imshow(grid, aspect='auto', cmap='viridis',
              extent=[1, n_max, len(primes), 0])
    ax.set_yticks(np.arange(len(primes)) + 0.5)
    ax.set_yticklabels(primes)
    ax.set_xlabel('index n')
    ax.set_ylabel('prime p')
    ax.set_title(f'Apparition lattice of {b}^n - 1: each row is periodic '
                 f'with period = entryPoint(p) = order({b} mod p)')
    plt.tight_layout()
    plt.savefig('apparition_lattice.png', dpi=150)
    print('saved apparition_lattice.png')

if __name__ == '__main__':
    apparition_lattice()
