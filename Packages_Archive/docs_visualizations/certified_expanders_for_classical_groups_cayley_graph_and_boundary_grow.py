import matplotlib.pyplot as plt
import networkx as nx
from itertools import product

def s3_elements():
    return [p for p in product(range(3), repeat=3) if len(set(p)) == 3]

def mul(a, b):
    return tuple(a[b[i]] for i in range(3))

def build_cayley():
    elems = s3_elements()
    transposition = (1, 0, 2)
    three_cycle = (1, 2, 0)
    three_cycle_inv = (2, 0, 1)
    gen = [transposition, three_cycle, three_cycle_inv]
    G = nx.DiGraph()
    for a in elems:
        for s in gen:
            G.add_edge(a, mul(a, s))
    return G, elems, gen

def reachable_rings(elems, gen, seed, depth=3):
    seen = {seed}
    frontier = {seed}
    rings = [set(frontier)]
    for _ in range(depth):
        nxt = {mul(a, s) for a in frontier for s in gen} - seen
        seen |= nxt
        rings.append(set(nxt))
        frontier = nxt
    return rings

def main():
    G, elems, gen = build_cayley()
    pos = nx.spring_layout(G, seed=1)
    rings = reachable_rings(elems, gen, elems[0], depth=3)
    colors = ['#d62728', '#ff7f0e', '#2ca02c', '#1f77b4', '#9467bd']
    node_color = {}
    for i, ring in enumerate(rings):
        for v in ring:
            node_color.setdefault(v, colors[min(i, len(colors) - 1)])
    nx.draw(G, pos, node_color=[node_color.get(v, '#cccccc') for v in G.nodes()],
            with_labels=False, node_size=500, arrowsize=12)
    prev = len(rings[0])
    for i, ring in enumerate(rings[1:], start=1):
        cur = prev + len(ring)
        print(f'step {i}: reached {cur}, growth factor {cur/prev:.2f}')
        prev = cur
    plt.title('Cayley graph of S_3: boundary growth from a seed vertex')
    plt.savefig('s3_cayley_growth.png', dpi=150, bbox_inches='tight')
    print('saved s3_cayley_growth.png')

if __name__ == '__main__':
    main()
