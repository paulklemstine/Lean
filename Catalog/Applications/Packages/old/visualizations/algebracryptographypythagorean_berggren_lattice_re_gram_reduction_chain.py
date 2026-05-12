import numpy as np
from typing import Tuple, List, Optional, Dict
from math import gcd, isqrt

def gram_reduction_chain(a: int, b: int, c: int) -> List[Dict]:
    """
    Perform lattice reduction on the Gram encoding by tracing ancestry.
    
    Each step:
      1. Encode current triple as Gram matrix
      2. Find Berggren parent (= one reduction step)
      3. Record the determinant decrease
    
    This demonstrates the certified short-vector extraction theorem:
    lattice reduction on Gram forms ↔ Berggren ancestor recovery.
    
    Time: O(depth × 1) = O(log c)
    Space: O(log c)
    """
    chain = []
    current = (a, b, c)
    
    while True:
        ca, cb, cc = current
        G = gram_encode(ca, cb, cc)
        det = gram_det(ca, cb, cc)
        trace = ca**2 + 2 * cc**2
        
        chain.append({
            'triple': current,
            'gram': G.tolist(),
            'det': det,
            'trace': trace,
            'height': cc,
        })
        
        if current == (3, 4, 5):
            break
        
        result = berggren_inverse(ca, cb, cc)
        if result is None:
            break
        _, parent = result
        current = parent
    
    return chain