from typing import Dict, List, Tuple

Config = Tuple[bool, ...]
System = Dict[Config, float]
Graph = Tuple[int, List[Tuple[int, int]]]


def system_of_graph(g: Graph) -> System:
    """Reduction S(G): uniform distribution over the all-off configuration and,
    for each edge {u,v} of G, the configuration on exactly at u and v.
    Support size <= n^2 + 1 (card_SSupport_le); co-activation in S(G) coincides
    with adjacency in G (coactive_iff_adj), so Phi_max(S(G)) = omega(G)."""
    n, edges = g
    configs: List[Config] = [tuple(False for _ in range(n))]
    for u, v in edges:
        cfg = [False] * n
        cfg[u] = True
        cfg[v] = True
        configs.append(tuple(cfg))
    uniq = list(dict.fromkeys(configs))
    w = 1.0 / len(uniq)
    return {cfg: w for cfg in uniq}
