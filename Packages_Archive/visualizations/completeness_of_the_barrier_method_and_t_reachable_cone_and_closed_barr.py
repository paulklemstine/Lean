from typing import Dict, List, Set, Tuple

def visualize_reachable_cone(
    edges: List[Tuple[int, int]], source: int, n_atoms: int,
    out_path: str = 'reachable_cone.png') -> None:
    succ: Dict[int, List[int]] = {i: [] for i in range(n_atoms)}
    for a, b in edges:
        succ[a].append(b)
    seen: Set[int] = {source}; stack = [source]
    while stack:
        x = stack.pop()
        for y in succ[x]:
            if y not in seen:
                seen.add(y); stack.append(y)
    try:
        import matplotlib.pyplot as plt
        import networkx as nx
        g = nx.DiGraph(); g.add_nodes_from(range(n_atoms)); g.add_edges_from(edges)
        pos = nx.spring_layout(g, seed=1)
        colors = ['#37b24d' if v in seen else '#e03131' for v in g.nodes]
        nx.draw(g, pos, with_labels=True, node_color=colors,
                node_size=700, font_color='white', arrowsize=18)
        plt.title(f'Reachable cone R({source}) (green) vs barrier (red)')
        plt.savefig(out_path, dpi=140, bbox_inches='tight'); plt.close()
        print(f'wrote {out_path}')
    except Exception:
        bar = sorted(set(range(n_atoms)) - seen)
        print(f'R({source}) = {sorted(seen)}; barrier = {bar}')

if __name__ == '__main__':
    visualize_reachable_cone([(0,1),(0,2),(1,3),(2,3),(3,4)], source=0, n_atoms=6)
