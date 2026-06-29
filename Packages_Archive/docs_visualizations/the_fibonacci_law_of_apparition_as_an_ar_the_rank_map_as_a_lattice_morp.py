"""Visualization: the rank map as a lattice morphism on divisibility.

Draws, side by side, the divisibility lattice of small moduli and the lattice of
their ranks of apparition under z. Edges (a | b) on the left map to edges
(z(a) | z(b)) on the right (monotonicity), and lcm cells are preserved exactly
while gcd cells may collapse (strict meet). Requires matplotlib and networkx.
"""
import matplotlib.pyplot as plt
import networkx as nx

def fib_rank(m: int) -> int:
    if m == 1:
        return 1
    a, b = 0 % m, 1 % m
    k = 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k

def divides(a: int, b: int) -> bool:
    return b % a == 0

def main() -> None:
    moduli = [1, 2, 3, 4, 6, 12]
    G = nx.DiGraph()
    for a in moduli:
        for b in moduli:
            if a != b and divides(a, b) and not any(
                a != c and c != b and divides(a, c) and divides(c, b) for c in moduli):
                G.add_edge(a, b)
    pos = nx.spring_layout(G, seed=1)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    nx.draw(G, pos, ax=ax1, with_labels=True, node_color="#cde",
            node_size=900, arrows=True)
    ax1.set_title("Divisibility lattice of moduli m")
    labels = {m: f"z({m})={fib_rank(m)}" for m in moduli}
    nx.draw(G, pos, ax=ax2, labels=labels, node_color="#dec",
            node_size=1400, arrows=True)
    ax2.set_title("Image under the rank map z (join-preserving)")
    fig.tight_layout()
    fig.savefig("fibonacci_rank_lattice.png", dpi=150)
    print("saved fibonacci_rank_lattice.png")

if __name__ == "__main__":
    main()
