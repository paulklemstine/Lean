# Path Minor Width Detection - Self-contained implementation
import itertools
from collections import defaultdict, deque
from typing import List, Set, Dict, FrozenSet, Optional, Tuple

def find_path_minor_width(vertices, adj, max_width=10):
    if len(vertices) < 2:
        return 0
    best_width = 0
    for w in range(1, min(max_width, len(vertices) // 2) + 1):
        if _try_path_minor(vertices, adj, w):
            best_width = w
        else:
            break
    return best_width

def _try_path_minor(vertices, adj, width):
    if len(vertices) < 2 * width:
        return False
    vertex_to_idx = {v: i for i, v in enumerate(vertices)}
    for start_idx in range(min(5, len(vertices))):
        layers = []
        used = set()
        current_layer = {start_idx}
        used.update(current_layer)
        while current_layer:
            if len(current_layer) >= width:
                supernode = set(list(current_layer)[:width])
                layers.append(supernode)
                used.update(supernode)
            else:
                expanded = set(current_layer)
                for v_idx in current_layer:
                    v = vertices[v_idx]
                    for u in adj.get(v, set()):
                        u_idx = vertex_to_idx.get(u)
                        if u_idx is not None and u_idx not in used:
                            expanded.add(u_idx)
                            if len(expanded) >= width:
                                break
                    if len(expanded) >= width:
                        break
                if len(expanded) >= width:
                    supernode = set(list(expanded)[:width])
                    layers.append(supernode)
                    used.update(supernode)
                else:
                    break
            next_layer = set()
            for v_idx in (layers[-1] if layers else current_layer):
                v = vertices[v_idx]
                for u in adj.get(v, set()):
                    u_idx = vertex_to_idx.get(u)
                    if u_idx is not None and u_idx not in used:
                        next_layer.add(u_idx)
            current_layer = next_layer
        if len(layers) >= 2:
            valid = True
            for i in range(len(layers) - 1):
                has_edge = False
                for v_idx in layers[i]:
                    v = vertices[v_idx]
                    for u in adj.get(v, set()):
                        u_idx = vertex_to_idx.get(u)
                        if u_idx in layers[i + 1]:
                            has_edge = True
                            break
                    if has_edge:
                        break
                if not has_edge:
                    valid = False
                    break
            if valid:
                return True
    return False

# Example usage
print("Path Minor Width Detection Algorithm")
print("Test: Simple path graph with 10 vertices")
vertices = list(range(10))
adj = {i: {i-1, i+1} & set(vertices) for i in vertices}
w = find_path_minor_width(vertices, adj)
print(f"Path minor width of P_10: {w}")
