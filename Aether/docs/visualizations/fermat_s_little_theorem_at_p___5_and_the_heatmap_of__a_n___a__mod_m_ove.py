import numpy as np
import matplotlib.pyplot as plt

def universal(n: int, m: int, bases=range(0, 50)) -> bool:
    return all((a ** n - a) % m == 0 for a in bases)

def main() -> None:
    ns = range(2, 16)
    ms = range(2, 40)
    grid = np.array([[1 if universal(n, m) else 0 for n in ns] for m in ms])
    plt.figure(figsize=(9, 7))
    plt.imshow(grid, aspect='auto', origin='lower',
               extent=[min(ns), max(ns), min(ms), max(ms)], cmap='viridis')
    plt.colorbar(label='m | a^n - a for all a')
    plt.xlabel('exponent n'); plt.ylabel('modulus m')
    plt.title('Universal divisibility of a^n - a')
    plt.tight_layout(); plt.savefig('divisibility_heatmap.png', dpi=150)
    print('saved divisibility_heatmap.png')

if __name__ == '__main__':
    main()
