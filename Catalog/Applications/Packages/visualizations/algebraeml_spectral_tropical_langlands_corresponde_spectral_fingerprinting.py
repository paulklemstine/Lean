from typing import Callable, Optional
from dataclasses import dataclass
import numpy as np
NEG_INF = float('-inf')
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import base64
from io import BytesIO
NEG_INF = float('-inf')
import itertools
from typing import Optional
NEG_INF = float('-inf')

class SpectralFingerprint:
    """Computable spectral invariant of a residuated action system.
    
    Components:
    - spectral_sizes: tuple of closed-element counts per action
    - closed_profiles: sorted tuple of element-level closure profiles
    - summand_count: number of simple summands
    """
    spectral_sizes: tuple
    closed_profiles: tuple
    summand_count: int
    
    def __eq__(self, other):
        return (self.spectral_sizes == other.spectral_sizes and
                self.summand_count == other.summand_count)
    
    def __hash__(self):
        return hash((self.spectral_sizes, self.summand_count))