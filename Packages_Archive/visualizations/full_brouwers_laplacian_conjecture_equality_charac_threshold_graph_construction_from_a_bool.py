from __future__ import annotations
from typing import Sequence
import numpy as np

def build_threshold_graph(creation: Sequence[bool]) -> np.ndarray:
    """Adjacency matrix of the threshold graph with a given creation sequence.

    creation[v] == True: vertex v is 'dominating' (joins all earlier vertices).
    creation[v] == False: vertex v is 'isolated'.
    Distinct vertices i, j are adjacent iff creation[max(i, j)] is True.
    """
    n = len(creation)
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if creation[j]:                      # j is the later-born vertex
                adj[i, j] = adj[j, i] = 1
    return adj
