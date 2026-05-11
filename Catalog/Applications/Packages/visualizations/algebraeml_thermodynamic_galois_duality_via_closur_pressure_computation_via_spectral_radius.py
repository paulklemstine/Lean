import numpy as np
from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass
import numpy as np
from algorithms import (
    ClosureSystem, build_transfer_matrix, compute_equilibrium,
    detect_phases, find_canonical_quotient, compute_galois_maps,
    compute_pressure_sequence, compute_partition_sums
)
import numpy as np
from typing import List, Tuple, Dict, Optional
import json
import sys
import os
from visualizations import generate_all_visualizations
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap
import base64
import io

def spectral_radius(A: np.ndarray) -> float:
    """Compute the spectral radius (largest absolute eigenvalue)."""
    eigenvalues = np.linalg.eigvals(A)
    return max(abs(eigenvalues))