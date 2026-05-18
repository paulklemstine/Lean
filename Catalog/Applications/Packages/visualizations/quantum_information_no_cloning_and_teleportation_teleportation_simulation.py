import numpy as np

def teleport(psi):
    """Simulate quantum teleportation for a qubit state."""
    X = np.array([[0,1],[1,0]], dtype=complex)
    Z = np.array([[1,0],[0,-1]], dtype=complex)
    H = np.array([[1,1],[1,-1]], dtype=complex) / np.sqrt(2)
    I2 = np.eye(2, dtype=complex)
    
    # Bell pair
    bell = np.array([1,0,0,1], dtype=complex) / np.sqrt(2)
    state = np.kron(psi, bell)
    
    # CNOT_12 ⊗ I_3
    CNOT = np.zeros((4,4), dtype=complex)
    CNOT[0,0] = CNOT[1,1] = CNOT[2,3] = CNOT[3,2] = 1
    state = np.kron(CNOT, I2) @ state
    
    # H_1 ⊗ I_2 ⊗ I_3
    state = np.kron(np.kron(H, I2), I2) @ state
    
    # Corrections for each outcome
    corrections = [I2, X, Z, X@Z]
    results = []
    for i, corr in enumerate(corrections):
        bob = state[i*2:(i+1)*2]
        bob_corrected = corr @ bob
        bob_corrected /= np.linalg.norm(bob_corrected)
        results.append(bob_corrected)
    
    return results

psi = np.array([0.6+0.1j, 0.3-0.7j], dtype=complex)
psi /= np.linalg.norm(psi)
results = teleport(psi)
for i, r in enumerate(results):
    fidelity = abs(np.vdot(psi, r))**2
    print(f"Outcome {i}: fidelity = {fidelity:.10f}")
