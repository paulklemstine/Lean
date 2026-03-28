"""
Demo 6: Quantum Advantage Simulation
=====================================
Simulates the quantum enhancement predicted by Theorem 3.2:
entangled photon sources provide log(N) additional phase entropy.
Compares classical vs quantum holographic reconstruction fidelity.

Generates: output/quantum_advantage.png
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.fft import fft2, ifft2, fftshift, ifftshift

def simulate_classical_source(N, num_photons_per_pixel):
    """Simulate a classical coherent laser source with shot noise."""
    rng = np.random.RandomState(42)
    # Classical coherent state: Poisson photon statistics
    amplitude = np.sqrt(num_photons_per_pixel) * np.ones((N, N))
    phase = rng.uniform(0, 2 * np.pi, (N, N))
    # Add shot noise (Poisson → Gaussian for large n)
    noise = rng.normal(0, 1, (N, N)) / np.sqrt(num_photons_per_pixel + 1)
    field = (amplitude + noise) * np.exp(1j * phase)
    return field, phase

def simulate_quantum_source(N, num_photons_per_pixel, entanglement_order=2):
    """
    Simulate a quantum entangled source.
    Entanglement provides sub-shot-noise phase estimation:
    phase uncertainty ~ 1/(N_ent * sqrt(n)) instead of 1/sqrt(n).
    """
    rng = np.random.RandomState(42)
    amplitude = np.sqrt(num_photons_per_pixel) * np.ones((N, N))
    phase = rng.uniform(0, 2 * np.pi, (N, N))
    # Quantum advantage: reduced phase noise by factor of entanglement_order
    noise = rng.normal(0, 1, (N, N)) / (np.sqrt(num_photons_per_pixel + 1) * entanglement_order)
    field = (amplitude + noise) * np.exp(1j * phase)
    return field, phase

def holographic_reconstruction(source_field, target_amplitude, iterations=50):
    """Run phase retrieval with given source field."""
    N = target_amplitude.shape[0]
    phase = np.angle(source_field)
    source_amplitude = np.abs(source_field)
    source_amplitude = source_amplitude / source_amplitude.max()
    
    errors = []
    for _ in range(iterations):
        src = source_amplitude * np.exp(1j * phase)
        tgt = fftshift(fft2(ifftshift(src)))
        err = np.sqrt(np.mean((np.abs(tgt) / (np.max(np.abs(tgt)) + 1e-15)
                                - target_amplitude / (np.max(target_amplitude) + 1e-15))**2))
        errors.append(err)
        tgt_phase = np.angle(tgt)
        tgt_c = target_amplitude * np.exp(1j * tgt_phase)
        src = ifftshift(ifft2(fftshift(tgt_c)))
        phase = np.angle(src)
    
    final_src = source_amplitude * np.exp(1j * phase)
    final_tgt = fftshift(fft2(ifftshift(final_src)))
    recon = np.abs(final_tgt)
    recon = recon / (recon.max() + 1e-15)
    
    mse = np.mean((recon - target_amplitude / (target_amplitude.max() + 1e-15))**2)
    psnr = 10 * np.log10(1.0 / (mse + 1e-15))
    
    return recon, psnr, errors

def main():
    N = 128
    
    # Create target
    x = np.linspace(-1, 1, N)
    X, Y = np.meshgrid(x, x)
    R = np.sqrt(X**2 + Y**2)
    target = np.zeros((N, N))
    for r0 in [0.15, 0.35, 0.55, 0.75]:
        target += np.exp(-((R - r0) / 0.03)**2)
    target += 0.5 * np.exp(-((X - 0.3)**2 + (Y - 0.3)**2) / 0.01)
    target += 0.5 * np.exp(-((X + 0.3)**2 + (Y + 0.3)**2) / 0.01)
    target = target / target.max()
    
    # === Experiment 1: Varying photon number ===
    photon_numbers = [10, 50, 100, 500, 1000, 5000, 10000]
    classical_psnrs = []
    quantum_psnrs_2 = []
    quantum_psnrs_4 = []
    quantum_psnrs_8 = []
    
    for n_photons in photon_numbers:
        # Classical
        src_c, _ = simulate_classical_source(N, n_photons)
        _, psnr_c, _ = holographic_reconstruction(src_c, target, iterations=30)
        classical_psnrs.append(psnr_c)
        
        # Quantum N=2
        src_q2, _ = simulate_quantum_source(N, n_photons, entanglement_order=2)
        _, psnr_q2, _ = holographic_reconstruction(src_q2, target, iterations=30)
        quantum_psnrs_2.append(psnr_q2)
        
        # Quantum N=4
        src_q4, _ = simulate_quantum_source(N, n_photons, entanglement_order=4)
        _, psnr_q4, _ = holographic_reconstruction(src_q4, target, iterations=30)
        quantum_psnrs_4.append(psnr_q4)
        
        # Quantum N=8
        src_q8, _ = simulate_quantum_source(N, n_photons, entanglement_order=8)
        _, psnr_q8, _ = holographic_reconstruction(src_q8, target, iterations=30)
        quantum_psnrs_8.append(psnr_q8)
    
    # === Experiment 2: Detailed comparison at fixed photon number ===
    n_fixed = 100
    src_classical, _ = simulate_classical_source(N, n_fixed)
    recon_classical, psnr_classical, errors_classical = holographic_reconstruction(
        src_classical, target, iterations=80)
    
    src_quantum, _ = simulate_quantum_source(N, n_fixed, entanglement_order=4)
    recon_quantum, psnr_quantum, errors_quantum = holographic_reconstruction(
        src_quantum, target, iterations=80)
    
    # === Plotting ===
    fig, axes = plt.subplots(2, 3, figsize=(20, 13))
    fig.suptitle('Quantum Advantage in Holographic Reconstruction\n'
                 'Classical Coherent vs Entangled Photon Sources',
                 fontsize=18, fontweight='bold')
    
    # Panel 1: PSNR vs photon number
    ax = axes[0, 0]
    ax.semilogx(photon_numbers, classical_psnrs, 'ko-', linewidth=2, markersize=8,
                label='Classical (coherent)')
    ax.semilogx(photon_numbers, quantum_psnrs_2, 'b^-', linewidth=2, markersize=8,
                label='Quantum (N=2 entangled)')
    ax.semilogx(photon_numbers, quantum_psnrs_4, 'rs-', linewidth=2, markersize=8,
                label='Quantum (N=4 entangled)')
    ax.semilogx(photon_numbers, quantum_psnrs_8, 'gD-', linewidth=2, markersize=8,
                label='Quantum (N=8 entangled)')
    ax.set_xlabel('Photons per pixel', fontsize=13)
    ax.set_ylabel('PSNR (dB)', fontsize=13)
    ax.set_title('Fidelity vs Source Brightness', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Quantum advantage (dB improvement)
    ax = axes[0, 1]
    advantage_2 = np.array(quantum_psnrs_2) - np.array(classical_psnrs)
    advantage_4 = np.array(quantum_psnrs_4) - np.array(classical_psnrs)
    advantage_8 = np.array(quantum_psnrs_8) - np.array(classical_psnrs)
    
    ax.semilogx(photon_numbers, advantage_2, 'b^-', linewidth=2, markersize=8,
                label='N=2 (predicted: +3.0 dB)')
    ax.semilogx(photon_numbers, advantage_4, 'rs-', linewidth=2, markersize=8,
                label='N=4 (predicted: +6.0 dB)')
    ax.semilogx(photon_numbers, advantage_8, 'gD-', linewidth=2, markersize=8,
                label='N=8 (predicted: +9.0 dB)')
    
    # Theoretical predictions
    ax.axhline(y=10*np.log10(2), color='b', linestyle='--', alpha=0.5)
    ax.axhline(y=10*np.log10(4), color='r', linestyle='--', alpha=0.5)
    ax.axhline(y=10*np.log10(8), color='g', linestyle='--', alpha=0.5)
    
    ax.set_xlabel('Photons per pixel', fontsize=13)
    ax.set_ylabel('Quantum Advantage (dB)', fontsize=13)
    ax.set_title('Quantum Enhancement over Classical', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Target
    ax = axes[0, 2]
    ax.imshow(target, cmap='hot', origin='lower', extent=[-1, 1, -1, 1])
    ax.set_title('Target Pattern', fontsize=14)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    
    # Panel 4: Classical reconstruction
    ax = axes[1, 0]
    ax.imshow(recon_classical, cmap='hot', origin='lower', extent=[-1, 1, -1, 1])
    ax.set_title(f'Classical Reconstruction\nPSNR = {psnr_classical:.1f} dB\n(100 photons/pixel)',
                 fontsize=12)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    
    # Panel 5: Quantum reconstruction
    ax = axes[1, 1]
    ax.imshow(recon_quantum, cmap='hot', origin='lower', extent=[-1, 1, -1, 1])
    ax.set_title(f'Quantum Reconstruction (N=4)\nPSNR = {psnr_quantum:.1f} dB\n(100 photons/pixel)',
                 fontsize=12)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    
    # Panel 6: Convergence comparison
    ax = axes[1, 2]
    ax.semilogy(errors_classical, 'k-', linewidth=2, label=f'Classical ({psnr_classical:.1f} dB)')
    ax.semilogy(errors_quantum, 'r-', linewidth=2, label=f'Quantum N=4 ({psnr_quantum:.1f} dB)')
    ax.set_xlabel('Iteration', fontsize=13)
    ax.set_ylabel('RMS Error', fontsize=13)
    ax.set_title('Convergence Comparison', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demos/output/quantum_advantage.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated: demos/output/quantum_advantage.png")

if __name__ == '__main__':
    main()
