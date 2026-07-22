from math import comb
from typing import List, Tuple

def compare_thresholds(n_vertices: int, edges: List[Tuple[int, int]],
                       num_components) -> Tuple[float, float, float]:
    m = len(edges)
    c = num_components(n_vertices, edges)
    corrected = (n_vertices - c) / m
    conjectured = comb(n_vertices, 2) / m
    return corrected, conjectured, conjectured - corrected
