import numpy as np
from dataclasses import dataclass, field
from typing import Callable, List, Tuple, Optional, Dict
Array = np.ndarray

def tropical_rg_iteration(
    K: Callable[[Array], Array],
    Cl: Callable[[Array], Array],
    f: Array,
    max_steps: int = 10000,
    energy_fn: Optional[Callable[[Array], int]] = None,
    capacity_fn: Optional[Callable[[Array], int]] = None,
) -> RGResult:
    """Compute the full RG orbit until convergence.
    
    Algorithm:
        1. Initialize orbit with f
        2. Repeatedly apply Krg = Cl ∘ K ∘ Cl
        3. Record c-function at each step
        4. Stop when fixed point reached or max_steps exceeded
    
    Time: O(max_steps * (T_Cl + T_K))
    Space: O(max_steps * n) for storing the orbit
    
    Args:
        K: Transfer operator
        Cl: Closure operator
        f: Initial state
        max_steps: Maximum iteration count
        energy_fn: Energy component of c-function (default: max)
        capacity_fn: Capacity component (default: support size)
    
    Returns:
        RGResult with orbit, energy trajectory, and convergence info
    """
    if energy_fn is None:
        energy_fn = lambda g: int(g.max())
    if capacity_fn is None:
        capacity_fn = lambda g: int(np.count_nonzero(g))
    
    orbit = [f.copy()]
    energies = [energy_fn(f)]
    capacities = [capacity_fn(f)]
    
    for step in range(max_steps):
        f_new = canonical_rg(K, Cl, orbit[-1])
        orbit.append(f_new)
        energies.append(energy_fn(f_new))
        capacities.append(capacity_fn(f_new))
        
        if np.array_equal(f_new, orbit[-2]):
            return RGResult(
                orbit=orbit,
                energies=energies,
                capacities=capacities,
                steps_to_equilibrium=step + 1,
                is_equilibrium=True,
                equilibrium_state=f_new,
            )
    
    return RGResult(
        orbit=orbit,
        energies=energies,
        capacities=capacities,
        steps_to_equilibrium=max_steps,
        is_equilibrium=False,
        equilibrium_state=None,
    )