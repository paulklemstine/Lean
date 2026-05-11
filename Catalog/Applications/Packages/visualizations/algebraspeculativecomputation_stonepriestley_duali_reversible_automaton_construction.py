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

class ReversibleAutomaton:
    """A reversible trace automaton with invertible transitions."""
    n_states: int
    step: Callable[[int, int], int]
    rev_step: Callable[[int, int], int]
    start: int
    accept: Callable[[int], bool]
    name: str = ""
    
    def verify_reversibility(self, inputs: List[int]) -> bool:
        """Check that rev_step(step(q, a), a) = q for all states and inputs."""
        for q in range(self.n_states):
            for a in inputs:
                if self.rev_step(self.step(q, a), a) != q:
                    return False
        return True