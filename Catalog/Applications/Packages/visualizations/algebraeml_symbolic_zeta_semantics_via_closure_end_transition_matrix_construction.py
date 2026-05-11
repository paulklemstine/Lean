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

def transition_matrix(f: Callable[[int], int], states: List[int]) -> np.ndarray:
    """Build the transition matrix A where A[i][j] = 1 iff f(states[i]) = states[j]."""
    N = len(states)
    idx = {s: i for i, s in enumerate(states)}
    A = np.zeros((N, N), dtype=int)
    for i, s in enumerate(states):
        j = idx[f(s)]
        A[i][j] = 1
    return A