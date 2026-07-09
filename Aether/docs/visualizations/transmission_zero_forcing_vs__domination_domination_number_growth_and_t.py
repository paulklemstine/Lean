import matplotlib.pyplot as plt
from typing import List


def gamma_path(n: int) -> int:
    return (n + 2) // 3


def main() -> None:
    ns: List[int] = list(range(1, 31))
    gamma: List[int] = [gamma_path(n) for n in ns]
    z: List[int] = [1 for _ in ns]
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.step(ns, gamma, where='mid', label=r'$\gamma(P_n)=\lceil n/3\rceil$',
            color='#1f77b4', linewidth=2)
    ax.plot(ns, z, label=r'$Z(P_n)=1$', color='#d62728', linewidth=2)
    ax.fill_between(ns, z, gamma, step='mid', alpha=0.15, color='#1f77b4',
                    label='separation gap')
    ax.set_xlabel('n (path length)')
    ax.set_ylabel('value')
    ax.set_title('Domination number vs. zero forcing number of the path')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('domination_vs_zeroforcing.png', dpi=150)
    print('wrote domination_vs_zeroforcing.png')


if __name__ == "__main__":
    main()
