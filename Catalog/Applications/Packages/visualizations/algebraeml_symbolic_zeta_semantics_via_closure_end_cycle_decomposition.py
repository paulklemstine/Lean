import numpy as np
from typing import Callable, Dict, List, Optional, Set, Tuple
from dataclasses import dataclass
import numpy as np
from typing import List, Dict, Tuple
from algorithms import (
    ClosureDynamics, periodic_count, compute_capacity,
    compute_certified_radius, detect_eventual_periodicity,
    find_cycle_decomposition, orbit_hash_collision_bound,
    build_transition_matrix
)
import numpy as np
from typing import Callable, Dict, List, Set, Tuple
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from typing import List, Callable
import base64
from io import BytesIO

def find_cycle_decomposition(
    sys: ClosureDynamics
) -> Tuple[List[List[int]], List[List[int]]]:
    """Decompose the functional graph into tails and cycles.

    Returns:
        (tails, cycles): Lists of tail paths and cycle lists.

    Time: O(|states|)
    Space: O(|states|)
    """
    visited = {}  # state -> (visit_order, path_id)
    tails = []
    cycles = []

    for start in sys.states:
        if start in visited:
            continue

        path = []
        x = start
        while x not in visited:
            visited[x] = len(path)
            path.append(x)
            x = sys.step(x)

        if x in [p for p in path]:
            # Found a new cycle
            cycle_start_idx = path.index(x)
            tail = path[:cycle_start_idx]
            cycle = path[cycle_start_idx:]
            if tail:
                tails.append(tail)
            cycles.append(cycle)
        # else: x was visited in a previous component

    return tails, cycles