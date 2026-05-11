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

class ProductVerifier:
    """Product of multiple verifiers running in parallel.
    
    Accepts iff ALL component verifiers accept (conjunction).
    State = tuple of component states.
    """
    components: List[FiniteVerifier]
    
    def n_states(self) -> int:
        """Total state count = product of component state counts.
        
        Time complexity: O(len(components))
        """
        result = 1
        for v in self.components:
            result *= v.n_states
        return result
    
    def verify(self, x: int) -> bool:
        """Accept iff all components accept.
        
        Time complexity: O(len(components))
        """
        return all(v.verify(x) for v in self.components)