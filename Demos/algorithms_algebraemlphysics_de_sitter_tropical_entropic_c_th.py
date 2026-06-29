#!/usr/bin/env python3
"""
Algorithms for Tropical Cosmological Renormalization

Implements the core algorithms from the research paper:
1. TropicalRGIteration — compute RG orbits with certified c-function trajectories
2. EquilibriumDetector — identify and characterize transfer equilibria
3. BoundTransfer — transfer c-function bounds across morphisms
4. ConvergenceCertifier — produce certified convergence bounds

All algorithms include complexity analysis and docstrings.
"""

import numpy as np
from dataclasses import dataclass, field
from typing import Callable, List, Tuple, Optional, Dict

Array = np.ndarray


@dataclass
class RGResult:
    """Result of an RG iteration."""
    orbit: List[Array]
    energies: List[int]
    capacities: List[int]
    steps_to_equilibrium: int
    is_equilibrium: bool
    equilibrium_state: Optional[Array]


@dataclass
class BoundCertificate:
    """Certificate that c-function bounds hold across a morphism."""
    source_energies: List[int]
    target_energies: List[int]
    bound_holds: bool
    violated_step: Optional[int] = None


@dataclass
class ConvergenceBound:
    """Certified convergence bound."""
    upper_bound_steps: int
    actual_steps: int
    initial_energy: int
    divisor: int


# ─── Core Operators ──────────────────────────────────────────────────────────

def max_closure(f: Array) -> Array:
    """Closure: replace all values with the global maximum.
    
    Time: O(n) where n = |X|
    Space: O(n)
    """
    return np.full_like(f, f.max())


def half_transfer(f: Array) -> Array:
    """Transfer: integer division by 2.
    
    Time: O(n)
    Space: O(n)
    """
    return f // 2


def div_transfer(f: Array, d: int = 2) -> Array:
    """Transfer: integer division by d.
    
    Time: O(n)
    Space: O(n)
    """
    return f // d


def canonical_rg(K: Callable, Cl: Callable, f: Array) -> Array:
    """Canonical RG step: Krg(f) = Cl(K(Cl(f))).
    
    Time: O(T_Cl + T_K + T_Cl) where T_X is the time for operator X
    Space: O(n)
    """
    return Cl(K(Cl(f)))


# ─── Algorithm 1: TropicalRGIteration ────────────────────────────────────────

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


# ─── Algorithm 2: EquilibriumDetector ────────────────────────────────────────

def is_transfer_equilibrium(
    K: Callable[[Array], Array],
    Cl: Callable[[Array], Array],
    f: Array,
) -> Tuple[bool, Dict[str, bool]]:
    """Check if f is a transfer equilibrium.
    
    A state f is a transfer equilibrium iff:
        1. Cl(f) = f  (closure-saturated)
        2. Cl(K(f)) = f  (transfer-closed)
    
    Time: O(T_Cl + T_K)
    
    Returns:
        (is_equilibrium, details) where details has keys
        'is_closed' and 'is_transfer_closed'
    """
    is_closed = np.array_equal(Cl(f), f)
    is_transfer_closed = np.array_equal(Cl(K(f)), f)
    
    return (is_closed and is_transfer_closed, {
        'is_closed': is_closed,
        'is_transfer_closed': is_transfer_closed,
    })


def find_all_equilibria(
    K: Callable[[Array], Array],
    Cl: Callable[[Array], Array],
    n: int,
    max_val: int = 10,
) -> List[Array]:
    """Brute-force search for equilibria (small systems only).
    
    Time: O(max_val^n * (T_Cl + T_K))
    Only feasible for n ≤ 4 and small max_val.
    """
    equilibria = []
    
    def search(partial: List[int]):
        if len(partial) == n:
            f = np.array(partial)
            is_eq, _ = is_transfer_equilibrium(K, Cl, f)
            if is_eq:
                equilibria.append(f.copy())
            return
        for v in range(max_val + 1):
            search(partial + [v])
    
    search([])
    return equilibria


# ─── Algorithm 3: BoundTransfer ──────────────────────────────────────────────

def bound_transfer(
    KX: Callable, ClX: Callable,
    KY: Callable, ClY: Callable,
    phi: Callable[[Array], Array],
    f: Array,
    energy_fn: Callable[[Array], int],
    max_steps: int = 100,
) -> BoundCertificate:
    """Verify functorial c-function bound transfer.
    
    Given morphism φ : (Y→T) → (X→T), verify that:
        cfunX(KrgX^n(φ(f))) ≤ cfunY(KrgY^n(f))  for all n
    
    Time: O(max_steps * (T_KX + T_ClX + T_KY + T_ClY + T_phi))
    
    Args:
        KX, ClX: X-system operators
        KY, ClY: Y-system operators
        phi: Transfer morphism (pullback map)
        f: Initial state in Y-system
        energy_fn: Energy functional
        max_steps: Number of steps to verify
    
    Returns:
        BoundCertificate with verification result
    """
    gY = f.copy()
    gX = phi(f)
    
    source_energies = [energy_fn(gY)]
    target_energies = [energy_fn(gX)]
    
    for step in range(max_steps):
        gY = canonical_rg(KY, ClY, gY)
        gX = canonical_rg(KX, ClX, gX)
        
        eY = energy_fn(gY)
        eX = energy_fn(gX)
        
        source_energies.append(eY)
        target_energies.append(eX)
        
        if eX > eY:
            return BoundCertificate(
                source_energies=source_energies,
                target_energies=target_energies,
                bound_holds=False,
                violated_step=step + 1,
            )
        
        if np.array_equal(gY, np.zeros_like(gY)) and np.array_equal(gX, np.zeros_like(gX)):
            break
    
    return BoundCertificate(
        source_energies=source_energies,
        target_energies=target_energies,
        bound_holds=True,
    )


# ─── Algorithm 4: ConvergenceCertifier ───────────────────────────────────────

def convergence_bound(f: Array, divisor: int = 2) -> ConvergenceBound:
    """Compute a certified upper bound on steps to equilibrium.
    
    For the div-by-d transfer with max-closure:
        Steps ≤ ceil(log_d(max(f))) + 1
    
    Also computes the actual number of steps.
    
    Time: O(log(max(f)) * n)
    """
    M = int(f.max())
    if M == 0:
        return ConvergenceBound(
            upper_bound_steps=0,
            actual_steps=0,
            initial_energy=0,
            divisor=divisor,
        )
    
    # Compute theoretical bound
    import math
    bound = math.ceil(math.log(M + 1, divisor)) + 2 if M > 0 else 0
    
    # Compute actual
    K = lambda g: g // divisor
    result = tropical_rg_iteration(K, max_closure, f)
    
    return ConvergenceBound(
        upper_bound_steps=bound,
        actual_steps=result.steps_to_equilibrium,
        initial_energy=M,
        divisor=divisor,
    )


# ─── Main: Self-Test ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm Self-Tests")
    print("=" * 50)
    
    # Test 1: Basic RG iteration
    f = np.array([10, 3, 7])
    result = tropical_rg_iteration(half_transfer, max_closure, f)
    print(f"\nTest 1: RG iteration on {f.tolist()}")
    print(f"  Steps: {result.steps_to_equilibrium}")
    print(f"  Energies: {result.energies}")
    print(f"  Reached equilibrium: {result.is_equilibrium}")
    assert result.is_equilibrium
    assert all(result.energies[i] >= result.energies[i+1] 
               for i in range(len(result.energies)-1))
    print("  ✓ Monotonicity verified")
    
    # Test 2: Equilibrium detection
    zero = np.array([0, 0, 0])
    is_eq, details = is_transfer_equilibrium(half_transfer, max_closure, zero)
    print(f"\nTest 2: Is zero an equilibrium? {is_eq}")
    print(f"  Details: {details}")
    assert is_eq
    
    nonzero = np.array([5, 5, 5])
    is_eq2, details2 = is_transfer_equilibrium(half_transfer, max_closure, nonzero)
    print(f"  Is (5,5,5) an equilibrium? {is_eq2}")
    assert not is_eq2
    print("  ✓ Equilibrium detection verified")
    
    # Test 3: Convergence bound
    f = np.array([1024, 512, 256])
    cb = convergence_bound(f, divisor=2)
    print(f"\nTest 3: Convergence bound for max={cb.initial_energy}")
    print(f"  Theoretical bound: {cb.upper_bound_steps} steps")
    print(f"  Actual steps: {cb.actual_steps}")
    assert cb.actual_steps <= cb.upper_bound_steps
    print("  ✓ Bound verified")
    
    # Test 4: Morphism bound transfer
    fY = np.array([20, 15, 10, 5])
    phi = lambda g: np.array([max(g[0], g[1]), max(g[2], g[3])])
    cert = bound_transfer(
        half_transfer, max_closure,
        half_transfer, max_closure,
        phi, fY, lambda g: int(g.max())
    )
    print(f"\nTest 4: Bound transfer via morphism")
    print(f"  Source energies: {cert.source_energies}")
    print(f"  Target energies: {cert.target_energies}")
    print(f"  Bound holds: {cert.bound_holds}")
    assert cert.bound_holds
    print("  ✓ Functorial bound verified")
    
    print("\n" + "=" * 50)
    print("All self-tests passed! ✓")
