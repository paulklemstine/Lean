from typing import Dict

Vertex = int
Color = int

def proper_complete_coloring(n: int) -> Dict[Vertex, Dict[Vertex, Color]]:
    """Round-robin (circle method) proper edge-coloring of K_n.

    For odd n this uses exactly n-1 colors and is genuinely proper, so by the
    structural theorem every triangle is rainbow: rt(K_n) = C(n,3) and
    delta_c = n-1 >= (n+1)/2. O(n^2) time.
    """
    adj: Dict[Vertex, Dict[Vertex, Color]] = {v: {} for v in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            color: Color = (i + j) % n
            adj[i][j] = color
            adj[j][i] = color
    return adj
