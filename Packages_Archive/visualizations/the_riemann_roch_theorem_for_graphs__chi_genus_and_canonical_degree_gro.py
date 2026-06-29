import matplotlib.pyplot as plt
from typing import List

def plot_invariants() -> None:
    ns: List[int] = list(range(3, 21))
    genus = [(n - 1) * (n - 2) // 2 for n in ns]
    degK = [n * (n - 3) for n in ns]
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ns, genus, 'o-', label='genus g(K_n) = (n-1)(n-2)/2')
    ax.plot(ns, degK, 's-', label='canonical degree deg K = n(n-3)')
    ax.plot(ns, [2 * g - 2 for g in genus], 'k--', label='2g - 2 (= deg K)')
    ax.set_xlabel('n  (number of vertices)')
    ax.set_ylabel('value')
    ax.set_title('Invariants of complete graphs K_n')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('kn_invariants.png', dpi=150)
    print('saved kn_invariants.png')

if __name__ == '__main__':
    plot_invariants()
