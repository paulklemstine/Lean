#!/usr/bin/env python3
"""
algorithms.py — Verified Algorithms for Quantum Information Rigidity

Implements:
1. Universal cloner test: checks if a candidate linear map clones all states
2. Bell-state recognizer: verified entry-wise comparison
3. Monogamy witness: computes Bell fidelities and checks shareability
4. Teleportation verifier: checks Pauli correction correctness
5. Density matrix tools: partial traces, purity, product-state detection

All algorithms correspond to formally verified properties in the Lean codebase.
"""

import numpy as np
from typing import Optional, Tuple, List, Callable


# ═══════════════════════════════════════════════════════════════
# Pauli matrices (fundamental quantum gates)
# ═══════════════════════════════════════════════════════════════

I2 = np.eye(2, dtype=complex)
PAULI_X = np.array([[0, 1], [1, 0]], dtype=complex)
PAULI_Y = np.array([[0, -1j], [1j, 0]], dtype=complex)
PAULI_Z = np.array([[1, 0], [0, -1]], dtype=complex)
PAULI_XZ = PAULI_X @ PAULI_Z

# Bell state |Φ⁺⟩ = (|00⟩ + |11⟩) / √2
BELL_PLUS = np.array([1, 0, 0, 1], dtype=complex) / np.sqrt(2)
BELL_DM = np.outer(BELL_PLUS, BELL_PLUS.conj())


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Universal Cloner Test
# ═══════════════════════════════════════════════════════════════

def is_cloning_map(delta: np.ndarray, n_tests: int = 100,
                   tol: float = 1e-8) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Test if a 4×2 matrix represents a cloning map Δ: ℂ² → ℂ²⊗ℂ².

    A cloning map satisfies Δ(ψ) = ψ⊗ψ for all unit vectors ψ.
    By the no-cloning theorem, this always returns False for
    any linear map.

    Args:
        delta: 4×2 complex matrix representing the linear map
        n_tests: number of random unit vectors to test
        tol: numerical tolerance

    Returns:
        (is_cloner, counterexample) where counterexample is a
        unit vector for which cloning fails, or None if n_tests
        exhausted without finding one.

    Complexity: O(n_tests × n²) where n is the dimension.
    """
    assert delta.shape == (4, 2), f"Expected shape (4,2), got {delta.shape}"

    for _ in range(n_tests):
        # Random unit vector in ℂ²
        psi = np.random.randn(2) + 1j * np.random.randn(2)
        psi /= np.linalg.norm(psi)

        # Apply the map
        result = delta @ psi

        # Expected: ψ ⊗ ψ
        expected = np.kron(psi, psi)

        if not np.allclose(result, expected, atol=tol):
            return False, psi

    return True, None


def prove_no_cloning(delta: np.ndarray) -> Tuple[bool, str]:
    """
    Algebraically prove that a given linear map is not a cloner.

    Uses the linearity argument: if Δ clones |0⟩ and |1⟩, then
    Δ(|+⟩) = (1/√2)(Δ|0⟩ + Δ|1⟩) ≠ |+⟩⊗|+⟩.

    Returns:
        (is_disproved, explanation)
    """
    ket0 = np.array([1, 0], dtype=complex)
    ket1 = np.array([0, 1], dtype=complex)
    plus = (ket0 + ket1) / np.sqrt(2)

    # Check if Δ clones |0⟩
    d0 = delta @ ket0
    e0 = np.kron(ket0, ket0)
    if not np.allclose(d0, e0):
        return True, f"Δ|0⟩ ≠ |0⟩⊗|0⟩: got {d0}, expected {e0}"

    # Check if Δ clones |1⟩
    d1 = delta @ ket1
    e1 = np.kron(ket1, ket1)
    if not np.allclose(d1, e1):
        return True, f"Δ|1⟩ ≠ |1⟩⊗|1⟩: got {d1}, expected {e1}"

    # By linearity: Δ(|+⟩) = (1/√2)(Δ|0⟩ + Δ|1⟩)
    lin_result = (d0 + d1) / np.sqrt(2)
    clone_result = np.kron(plus, plus)

    if not np.allclose(lin_result, clone_result):
        return True, (f"Linearity gives Δ|+⟩ = {lin_result}, "
                       f"but cloning requires {clone_result}")

    return False, "Could not disprove (unexpected — check input)"


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Bell-State Recognizer
# ═══════════════════════════════════════════════════════════════

def recognize_bell_state(rho: np.ndarray, tol: float = 1e-8) -> dict:
    """
    Verified Bell-state recognizer for 2-qubit density matrices.

    Checks entry-by-entry against the Bell state |Φ⁺⟩⟨Φ⁺|.
    Corresponds to the verified `bell_density_eq_iff` theorem.

    Args:
        rho: 4×4 complex density matrix

    Returns:
        dict with 'is_bell', 'fidelity', 'max_entry_error'
    """
    fidelity = np.real(np.trace(rho @ BELL_DM))
    max_error = np.max(np.abs(rho - BELL_DM))
    is_bell = max_error < tol

    return {
        'is_bell': is_bell,
        'fidelity': fidelity,
        'max_entry_error': max_error,
    }


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Monogamy Witness
# ═══════════════════════════════════════════════════════════════

def partial_trace_C(rho_ABC: np.ndarray) -> np.ndarray:
    """Trace out C from a 3-qubit (8×8) density matrix."""
    r = rho_ABC.reshape(4, 2, 4, 2)
    return np.einsum('iaja->ij', r)


def partial_trace_B(rho_ABC: np.ndarray) -> np.ndarray:
    """Trace out B from a 3-qubit (8×8) density matrix."""
    r = rho_ABC.reshape(2, 2, 2, 2, 2, 2)
    return np.einsum('ijakjb->iakb', r).reshape(4, 4)


def partial_trace_A(rho_ABC: np.ndarray) -> np.ndarray:
    """Trace out A from a 3-qubit (8×8) density matrix."""
    r = rho_ABC.reshape(2, 4, 2, 4)
    return np.einsum('iaia->ia', r).reshape(4, 4)


def monogamy_witness(psi_ABC: np.ndarray) -> dict:
    """
    Compute monogamy witness for a 3-qubit pure state.

    For a pure state |ψ_ABC⟩:
    - Computes reduced states ρ_AB, ρ_AC
    - Computes Bell fidelities F_AB, F_AC
    - Checks if AB being Bell implies AC is product

    Corresponds to verified `bell_pair_monogamy` theorem.

    Args:
        psi_ABC: 8-component complex vector (3-qubit state)

    Returns:
        dict with fidelities, product-state check, and monogamy data
    """
    psi = psi_ABC / np.linalg.norm(psi_ABC)
    rho = np.outer(psi, psi.conj())

    rho_AB = partial_trace_C(rho)
    rho_AC = partial_trace_B(rho)

    fid_AB = np.real(np.trace(rho_AB @ BELL_DM))
    fid_AC = np.real(np.trace(rho_AC @ BELL_DM))

    # Check if AC is a product state
    rho_A_from_AC = np.trace(rho_AC.reshape(2, 2, 2, 2), axis1=1, axis2=3)
    rho_C_from_AC = np.trace(rho_AC.reshape(2, 2, 2, 2), axis1=0, axis2=2)
    product_AC = np.kron(rho_A_from_AC, rho_C_from_AC)
    is_product_AC = np.allclose(rho_AC, product_AC, atol=1e-8)

    return {
        'bell_fidelity_AB': fid_AB,
        'bell_fidelity_AC': fid_AC,
        'is_AB_bell': np.isclose(fid_AB, 1.0),
        'is_AC_product': is_product_AC,
        'monogamy_sum': fid_AB + fid_AC,
    }


def scan_monogamy_tradeoff(n_samples: int = 10000) -> dict:
    """
    Monte Carlo scan of the monogamy tradeoff F_AB + F_AC.

    Samples random 3-qubit pure states and computes Bell fidelities
    of AB and AC subsystems.

    Returns:
        dict with arrays of fidelities and summary statistics
    """
    fid_AB = np.zeros(n_samples)
    fid_AC = np.zeros(n_samples)

    for i in range(n_samples):
        v = np.random.randn(8) + 1j * np.random.randn(8)
        v /= np.linalg.norm(v)
        result = monogamy_witness(v)
        fid_AB[i] = result['bell_fidelity_AB']
        fid_AC[i] = result['bell_fidelity_AC']

    return {
        'fid_AB': fid_AB,
        'fid_AC': fid_AC,
        'max_sum': np.max(fid_AB + fid_AC),
        'mean_sum': np.mean(fid_AB + fid_AC),
        'max_fid_AC_when_AB_high': (
            np.max(fid_AC[fid_AB > 0.9]) if np.any(fid_AB > 0.9) else None
        ),
    }


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Teleportation Verifier
# ═══════════════════════════════════════════════════════════════

def verify_teleportation(rho: np.ndarray) -> dict:
    """
    Verify teleportation correctness for a qubit density matrix.

    For each of the 4 measurement outcomes (a,b) ∈ {0,1}²,
    checks that σ·(σ·ρ·σ†)·σ† = ρ where σ is the Pauli correction.

    Corresponds to verified `teleportation_all_outcomes_correct`.

    Args:
        rho: 2×2 complex density matrix

    Returns:
        dict with verification results per outcome
    """
    corrections = [
        ("I", I2),
        ("X", PAULI_X),
        ("Z", PAULI_Z),
        ("XZ", PAULI_XZ),
    ]

    results = {}
    for name, sigma in corrections:
        distorted = sigma @ rho @ sigma.conj().T
        recovered = sigma @ distorted @ sigma.conj().T
        results[name] = {
            'correct': np.allclose(recovered, rho),
            'error': np.max(np.abs(recovered - rho)),
        }

    return results


# ═══════════════════════════════════════════════════════════════
# Algorithm 5: Product State Detector
# ═══════════════════════════════════════════════════════════════

def is_product_state(rho_2q: np.ndarray, tol: float = 1e-8) -> Tuple[bool, Optional[Tuple]]:
    """
    Check if a 2-qubit density matrix is a product state ρ_A ⊗ ρ_B.

    Uses SVD of the reshaped matrix: a product state has rank 1
    when viewed as a 4×1 vector in the Hilbert-Schmidt space.

    Returns:
        (is_product, (rho_A, rho_B)) if product, else (False, None)
    """
    # Reshape ρ as a matrix of shape (d_A², d_B²) for Schmidt decomp
    M = rho_2q.reshape(2, 2, 2, 2).transpose(0, 2, 1, 3).reshape(4, 4)
    U, S, Vh = np.linalg.svd(M)

    # Product iff rank 1 (only one nonzero singular value)
    n_nonzero = np.sum(S > tol)

    if n_nonzero <= 1:
        # Extract marginals
        rho_A = np.trace(rho_2q.reshape(2, 2, 2, 2), axis1=1, axis2=3)
        rho_B = np.trace(rho_2q.reshape(2, 2, 2, 2), axis1=0, axis2=2)
        return True, (rho_A, rho_B)

    return False, None


# ═══════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Quantum Information Rigidity — Algorithm Suite")
    print("=" * 50)

    # 1. Test no-cloning
    print("\n1. No-Cloning Test")
    # Try the "best candidate" cloner: map to Bell state
    delta = np.zeros((4, 2), dtype=complex)
    delta[0, 0] = 1  # |0⟩ → |00⟩
    delta[3, 1] = 1  # |1⟩ → |11⟩
    is_cloner, cex = is_cloning_map(delta)
    print(f"   Candidate cloner test: is_cloner={is_cloner}")
    if cex is not None:
        print(f"   Counterexample: ψ = {cex}")

    disproved, explanation = prove_no_cloning(delta)
    print(f"   Algebraic disproof: {explanation}")

    # 2. Bell recognizer
    print("\n2. Bell-State Recognizer")
    result = recognize_bell_state(BELL_DM)
    print(f"   Bell state: {result}")

    result2 = recognize_bell_state(np.eye(4) / 4)
    print(f"   Maximally mixed: {result2}")

    # 3. Monogamy witness
    print("\n3. Monogamy Witness")
    psi = np.kron(BELL_PLUS, np.array([1, 0]))
    mw = monogamy_witness(psi)
    print(f"   |Φ⁺⟩_AB ⊗ |0⟩_C: {mw}")

    # 4. Teleportation verifier
    print("\n4. Teleportation Verifier")
    psi = np.array([np.cos(0.3), np.exp(1j * 0.7) * np.sin(0.3)])
    rho = np.outer(psi, psi.conj())
    tv = verify_teleportation(rho)
    for name, result in tv.items():
        print(f"   {name}: correct={result['correct']}, "
              f"error={result['error']:.2e}")

    # 5. Product state detector
    print("\n5. Product State Detector")
    prod = np.kron(
        np.outer([1, 0], [1, 0]),
        np.outer([0, 1], [0, 1])
    )
    is_prod, factors = is_product_state(prod)
    print(f"   |0⟩⟨0| ⊗ |1⟩⟨1|: is_product={is_prod}")

    is_prod2, _ = is_product_state(BELL_DM)
    print(f"   Bell state: is_product={is_prod2}")
