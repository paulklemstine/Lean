#!/usr/bin/env python3
"""
Tropical Noether Shadow — Algorithms

Implements the core algorithms for tropical Lagrangian mechanics:
1. Tropical Lagrangian evaluation and active piece computation
2. Tropical Noether charge computation with correctness verification
3. Breakpoint detection and Kirchhoff balance verification
4. Tropical action computation along trajectories
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass


@dataclass
class TropicalLagrangianData:
    """Data for a tropical Lagrangian L(q,v) = max_i (a_i·q + b_i·v + c_i).

    Attributes:
        a: (m, n) position coefficients
        b: (m, n) velocity coefficients
        c: (m,) constant offsets
    """
    a: np.ndarray
    b: np.ndarray
    c: np.ndarray

    @property
    def num_pieces(self) -> int:
        return self.a.shape[0]

    @property
    def dimension(self) -> int:
        return self.a.shape[1]


@dataclass
class ChargeReport:
    """Report from tropical Noether charge computation.

    Attributes:
        charges: charge at each time step
        active_pieces: active piece index at each step
        breakpoints: indices where active piece changes
        is_piecewise_constant: True if charge constant between breakpoints
        is_globally_constant: True if charge constant everywhere
        kirchhoff_balanced: True if KCL holds at all breakpoints
    """
    charges: List[float]
    active_pieces: List[int]
    breakpoints: List[int]
    is_piecewise_constant: bool
    is_globally_constant: bool
    kirchhoff_balanced: bool


def evaluate_tropical_lagrangian(L: TropicalLagrangianData,
                                  q: np.ndarray, v: np.ndarray) -> Tuple[float, int]:
    """Evaluate tropical Lagrangian and return (value, active_piece).

    Time complexity: O(m * n) where m = num_pieces, n = dimension.

    Args:
        L: tropical Lagrangian data
        q: position vector (n,)
        v: velocity vector (n,)

    Returns:
        (L(q,v), j*) where j* is the active piece index
    """
    vals = L.a @ q + L.b @ v + L.c  # (m,) vectorized
    j_star = int(np.argmax(vals))
    return float(vals[j_star]), j_star


def compute_noether_charge(L: TropicalLagrangianData,
                            xi: np.ndarray,
                            q: np.ndarray, v: np.ndarray) -> float:
    """Compute tropical Noether charge Q = b_{j*} · xi.

    Time complexity: O(m * n)

    Args:
        L: tropical Lagrangian data
        xi: symmetry direction (n,)
        q: position (n,)
        v: velocity (n,)

    Returns:
        Noether charge value
    """
    _, j_star = evaluate_tropical_lagrangian(L, q, v)
    return float(L.b[j_star] @ xi)


def verify_translation_symmetry(L: TropicalLagrangianData,
                                 xi: np.ndarray,
                                 tol: float = 1e-12) -> Tuple[bool, np.ndarray]:
    """Verify translation symmetry: a_i · xi = 0 for all i.

    Time complexity: O(m * n)

    Args:
        L: tropical Lagrangian data
        xi: symmetry direction

    Returns:
        (is_symmetric, violations) where violations[i] = a_i · xi
    """
    violations = L.a @ xi  # (m,)
    is_symmetric = np.all(np.abs(violations) < tol)
    return bool(is_symmetric), violations


def compute_charge_along_trajectory(L: TropicalLagrangianData,
                                     xi: np.ndarray,
                                     positions: List[np.ndarray],
                                     tol: float = 1e-10) -> ChargeReport:
    """Compute tropical Noether charge along a trajectory with full verification.

    This is the certified algorithm: it computes the charge at each step,
    detects breakpoints, and verifies both piecewise constancy and
    Kirchhoff balance.

    Time complexity: O(T * m * n) where T = len(positions) - 1

    Args:
        L: tropical Lagrangian data
        xi: symmetry direction
        positions: list of position vectors
        tol: numerical tolerance

    Returns:
        ChargeReport with full verification results
    """
    T = len(positions) - 1
    assert T >= 1, "Need at least 2 positions"

    charges: List[float] = []
    active_pieces: List[int] = []
    breakpoints: List[int] = []

    # Compute charges and active pieces
    for t in range(T):
        q = positions[t]
        v = positions[t + 1] - positions[t]
        _, j = evaluate_tropical_lagrangian(L, q, v)
        charge = float(L.b[j] @ xi)
        charges.append(charge)
        active_pieces.append(j)

    # Detect breakpoints
    for t in range(T - 1):
        if active_pieces[t] != active_pieces[t + 1]:
            breakpoints.append(t)

    # Verify piecewise constancy: charge constant when active piece doesn't change
    is_pw_const = True
    for t in range(T - 1):
        if active_pieces[t] == active_pieces[t + 1]:
            if abs(charges[t] - charges[t + 1]) > tol:
                is_pw_const = False
                break

    # Verify Kirchhoff balance at breakpoints
    kirchhoff_ok = True
    for bp in breakpoints:
        if abs(charges[bp] - charges[bp + 1]) > tol:
            kirchhoff_ok = False
            break

    # Check global constancy
    is_global_const = True
    if charges:
        ref = charges[0]
        for c in charges[1:]:
            if abs(c - ref) > tol:
                is_global_const = False
                break

    return ChargeReport(
        charges=charges,
        active_pieces=active_pieces,
        breakpoints=breakpoints,
        is_piecewise_constant=is_pw_const,
        is_globally_constant=is_global_const,
        kirchhoff_balanced=kirchhoff_ok,
    )


def compute_tropical_action(L: TropicalLagrangianData,
                             positions: List[np.ndarray]) -> float:
    """Compute tropical action: max over time steps of L(q_t, v_t).

    This is the max-plus "integral" of the Lagrangian along the path.

    Time complexity: O(T * m * n)

    Args:
        L: tropical Lagrangian data
        positions: trajectory positions

    Returns:
        Tropical action value
    """
    T = len(positions) - 1
    max_val = float('-inf')
    for t in range(T):
        q = positions[t]
        v = positions[t + 1] - positions[t]
        val, _ = evaluate_tropical_lagrangian(L, q, v)
        max_val = max(max_val, val)
    return max_val


def build_kirchhoff_node(charge_in: float, charge_out: float) -> Dict:
    """Build a Kirchhoff network node from tropical charges.

    The node has two terminals:
    - Terminal 0: current = charge_in
    - Terminal 1: current = -charge_out

    KCL holds iff charge_in = charge_out.

    Args:
        charge_in: incoming Noether charge
        charge_out: outgoing Noether charge

    Returns:
        Dict with node data and KCL verification
    """
    currents = [charge_in, -charge_out]
    kcl_sum = sum(currents)
    return {
        'currents': currents,
        'kcl_sum': kcl_sum,
        'kcl_holds': abs(kcl_sum) < 1e-10,
        'tropical_balance': abs(charge_in - charge_out) < 1e-10,
    }


def generate_symmetric_lagrangian(n: int, m: int,
                                   xi: np.ndarray,
                                   uniform_charge: bool = True,
                                   seed: Optional[int] = None) -> TropicalLagrangianData:
    """Generate a random tropical Lagrangian with translation symmetry.

    Ensures a_i · xi = 0 for all pieces. Optionally ensures
    b_i · xi is the same for all pieces (uniform charge).

    Args:
        n: dimension
        m: number of pieces
        xi: symmetry direction
        uniform_charge: if True, enforce uniform b·xi
        seed: random seed

    Returns:
        TropicalLagrangianData with guaranteed symmetry
    """
    if seed is not None:
        np.random.seed(seed)

    xi_norm = xi / np.linalg.norm(xi)

    # Position coefficients orthogonal to xi
    a = np.random.randn(m, n) * 3
    for i in range(m):
        a[i] -= (a[i] @ xi_norm) * xi_norm

    # Velocity coefficients
    b = np.random.randn(m, n) * 3
    if uniform_charge:
        target = b[0] @ xi
        for i in range(1, m):
            b[i] += ((target - b[i] @ xi) / (xi @ xi)) * xi

    c = np.random.randn(m) * 2

    return TropicalLagrangianData(a=a, b=b, c=c)


# Example usage
if __name__ == "__main__":
    np.random.seed(0)
    n, m = 2, 5
    xi = np.array([1.0, 0.0])

    L = generate_symmetric_lagrangian(n, m, xi, uniform_charge=True, seed=42)

    # Verify symmetry
    sym_ok, violations = verify_translation_symmetry(L, xi)
    print(f"Translation symmetry: {sym_ok}")
    print(f"Violations: {violations}")

    # Generate trajectory and compute charges
    positions = [np.random.randn(n) for _ in range(21)]
    report = compute_charge_along_trajectory(L, xi, positions)

    print(f"\nCharge report:")
    print(f"  Steps: {len(report.charges)}")
    print(f"  Breakpoints: {len(report.breakpoints)} at {report.breakpoints}")
    print(f"  Piecewise constant: {report.is_piecewise_constant}")
    print(f"  Globally constant: {report.is_globally_constant}")
    print(f"  Kirchhoff balanced: {report.kirchhoff_balanced}")
    print(f"  Charge values: {[round(c, 6) for c in report.charges[:10]]}...")

    # Kirchhoff verification at first breakpoint
    if report.breakpoints:
        bp = report.breakpoints[0]
        node = build_kirchhoff_node(report.charges[bp], report.charges[bp + 1])
        print(f"\nKirchhoff node at breakpoint {bp}:")
        print(f"  Currents: {node['currents']}")
        print(f"  KCL sum: {node['kcl_sum']:.2e}")
        print(f"  KCL holds: {node['kcl_holds']}")
        print(f"  Tropical balance: {node['tropical_balance']}")
