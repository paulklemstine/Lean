"""Visualisation: the divisibility lattice of cyclic gain groups.

Draws the Hasse diagram of divisors of 12 under divisibility; an edge m -> n with
m | n indicates that every Z/m-gainable biased graph is Z/n-gainable
(gainable_mono_of_dvd). Requires matplotlib and networkx.
"""
from itertools import combinations
import matplotlib.pyplot as plt
import networkx as nx

def divisors(n: int) -> list:
    return [d for d in range(1, n + 1) if n % d == 0]

def main() -> None:
    N = 12
    ds = divisors(N)
    G = nx.DiGraph()
    G.add_nodes_from(ds)
    for a, b in combinations(ds, 2):
        if b % a == 0:
            # add covering relations only (Hasse diagram)
            if not any((b % c == 0 and c % a == 0 and c not in (a, b)) for c in ds):
                G.add_edge(a, b)
    pos = {d: (i, d) for i, d in enumerate(ds)}
    plt.figure(figsize=(7, 6))
    nx.draw(G, pos, with_labels=True, node_color="#cde", node_size=1200,
            font_size=12, arrows=True, arrowsize=18,
            labels={d: f"Z/{d}" for d in ds})
    plt.title("Divisibility lattice of divisors of 12:\n"
              "m | n  =>  Z/m-gainable implies Z/n-gainable")
    plt.tight_layout()
    plt.savefig("divisibility_lattice.png", dpi=150)
    print("wrote divisibility_lattice.png")

if __name__ == "__main__":
    main()
