from dataclasses import dataclass
from typing import List, Tuple, Optional, Set, Callable
import math
from algorithms import (
    find_separating_primes, extract_verifier, spectral_width,
    spectral_distance, sieve_primes, compose_verifiers,
    construct_reversible_automaton, FiniteVerifier, ProductVerifier
)
from typing import List, Dict, Tuple
import math
import itertools
from dataclasses import dataclass, field
from typing import Callable, Dict, List, Set, Tuple

def spectral_width(a: int, b: int, primes: List[int]) -> int:
    """Compute the spectral width: number of primes separating a from b.
    
    Time complexity: O(len(primes))
    
    Args:
        a, b: Elements to compare
        primes: List of prime congruences to test
    
    Returns:
        Number of primes in the list that separate a from b
    """
    if a == b:
        return 0
    return sum(1 for p in primes if (a - b) % p != 0)