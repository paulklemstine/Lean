"""
Demo 2: Holographic Reconstruction Simulation
==============================================
Simulates the Gerchberg-Saxton algorithm for phase retrieval and compares
it with a TPL-enhanced version that pre-decomposes the target into
topological layers.

Generates: output/holographic_reconstruction.png
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.fft import fft2, ifft2, fftshift, ifftshift

def gerchberg_saxton(target_amplitude, iterations=50):
    """Standard Gerchberg-Saxton algorithm for phase retrieval."""
    N = target_amplitude.shape[0]
    # Start with random phase
    rng = np.random.RandomState(42)
    phase = rng.uniform(0, 2 * np.pi, target_amplitude.shape)
    source_amplitude = np.ones_like(target_amplitude)  # uniform illumination
    
    errors = []
    
    for i in range(iterations):
        # Source plane: apply source constraint
        source_field = source_amplitude * np.exp(1j * phase)
        
        # Propagate to target (Fourier transform)
        target_field = fftshift(fft2(ifftshift(source_field)))
        
        # Target plane: apply target constraint (replace amplitude, keep phase)
        target_phase = np.angle(target_field)
        target_field_constrained = target_amplitude * np.exp(1j * target_phase)
        
        # Compute error
        error = np.sqrt(np.mean((np.abs(target_field) / np.max(np.abs(target_field))
                                  - target_amplitude / np.max(target_amplitude))**2))
        errors.append(error)
        
        # Back-propagate
        source_field = ifftshift(ifft2(fftshift(target_field_constrained)))
        
        # Source plane: keep phase, reset amplitude
        phase = np.angle(source_field)
    
    # Final reconstruction
    final_source = source_amplitude * np.exp(1j * phase)
    final_target = fftshift(fft2(ifftshift(final_source)))
    
    return phase, np.abs(final_target), errors

def tpl_enhanced_gs(target_amplitude, iterations=50):
    """TPL-enhanced Gerchberg-Saxton with topological pre-decomposition."""
    N = target_amplitude.shape[0]
    rng = np.random.RandomState(42)
    
    # Step 1: Decompose target into frequency bands (simulating TPL decomposition)
    target_ft = fftshift(fft2(target_amplitude))
    
    # Low-frequency (topological) component
    mask_low = np.zeros((N, N))
    cx, cy = N // 2, N // 2
    Y, X = np.ogrid[:N, :N]
    r = np.sqrt((X - cx)**2 + (Y - cy)**2)
    mask_low[r < N * 0.1] = 1.0
    
    # Mid-frequency (smooth) component
    mask_mid = np.zeros((N, N))
    mask_mid[(r >= N * 0.1) & (r < N * 0.3)] = 1.0
    
    # High-frequency (texture) component
    mask_high = np.zeros((N, N))
    mask_high[r >= N * 0.3] = 1.0
    
    # Reconstruct each band separately then combine phases
    phase_total = np.zeros((N, N))
    weights = [0.5, 0.35, 0.15]
    
    for mask, weight in zip([mask_low, mask_mid, mask_high], weights):
        band_ft = target_ft * mask
        band_amplitude = np.abs(ifft2(ifftshift(band_ft)))
        band_amplitude = band_amplitude / (band_amplitude.max() + 1e-10) * weight
        
        # Run GS on this band
        phase_band = rng.uniform(0, 2 * np.pi, (N, N))
        source_amplitude = np.ones((N, N))
        
        for _ in range(iterations):
            source_field = source_amplitude * np.exp(1j * phase_band)
            target_field = fftshift(fft2(ifftshift(source_field)))
            target_phase = np.angle(target_field)
            target_field_c = band_amplitude * np.exp(1j * target_phase)
            source_field = ifftshift(ifft2(fftshift(target_field_c)))
            phase_band = np.angle(source_field)
        
        phase_total += phase_band * weight
    
    # Add phase entropy optimization (random diffuser)
    phase_total += rng.uniform(-0.1, 0.1, (N, N)) * np.pi
    
    # Final reconstruction
    errors = []
    source_amplitude = np.ones((N, N))
    phase = phase_total.copy()
    
    for i in range(iterations):
        source_field = source_amplitude * np.exp(1j * phase)
        target_field = fftshift(fft2(ifftshift(source_field)))
        error = np.sqrt(np.mean((np.abs(target_field) / (np.max(np.abs(target_field)) + 1e-10)
                                  - target_amplitude / (np.max(target_amplitude) + 1e-10))**2))
        errors.append(error)
        target_phase = np.angle(target_field)
        target_field_c = target_amplitude * np.exp(1j * target_phase)
        source_field = ifftshift(ifft2(fftshift(target_field_c)))
        phase = np.angle(source_field)
    
    final_source = source_amplitude * np.exp(1j * phase)
    final_target = fftshift(fft2(ifftshift(final_source)))
    
    return phase, np.abs(final_target), errors

def create_test_target(N=256):
    """Create a test target: concentric rings with varying intensity."""
    x = np.linspace(-1, 1, N)
    y = np.linspace(-1, 1, N)
    X, Y = np.meshgrid(x, y)
    R = np.sqrt(X**2 + Y**2)
    
    # Create a pattern: rings + cross + gaussian spots
    target = np.zeros((N, N))
    
    # Rings
    for r0 in [0.2, 0.4, 0.6, 0.8]:
        ring = np.exp(-((R - r0) / 0.03)**2)
        target += ring
    
    # Cross
    cross = np.exp(-(X / 0.02)**2) * (np.abs(Y) < 0.5) + \
            np.exp(-(Y / 0.02)**2) * (np.abs(X) < 0.5)
    target += 0.5 * cross
    
    # Corner spots
    for x0, y0 in [(-0.5, -0.5), (0.5, -0.5), (-0.5, 0.5), (0.5, 0.5)]:
        spot = np.exp(-((X - x0)**2 + (Y - y0)**2) / 0.01)
        target += spot
    
    target = target / target.max()
    return target

def main():
    N = 256
    target = create_test_target(N)
    
    # Run both algorithms
    print("Running standard Gerchberg-Saxton...")
    phase_gs, recon_gs, errors_gs = gerchberg_saxton(target, iterations=100)
    
    print("Running TPL-enhanced Gerchberg-Saxton...")
    phase_tpl, recon_tpl, errors_tpl = tpl_enhanced_gs(target, iterations=100)
    
    # Normalize reconstructions
    recon_gs_norm = recon_gs / recon_gs.max()
    recon_tpl_norm = recon_tpl / recon_tpl.max()
    
    # Calculate PSNR
    mse_gs = np.mean((recon_gs_norm - target)**2)
    mse_tpl = np.mean((recon_tpl_norm - target)**2)
    psnr_gs = 10 * np.log10(1.0 / mse_gs) if mse_gs > 0 else float('inf')
    psnr_tpl = 10 * np.log10(1.0 / mse_tpl) if mse_tpl > 0 else float('inf')
    
    # Plot
    fig, axes = plt.subplots(2, 4, figsize=(20, 10))
    fig.suptitle('Holographic Phase Retrieval: Standard vs TPL-Enhanced',
                 fontsize=18, fontweight='bold')
    
    # Row 1: Standard GS
    axes[0, 0].imshow(target, cmap='hot', origin='lower')
    axes[0, 0].set_title('Target Pattern', fontsize=13)
    axes[0, 0].axis('off')
    
    axes[0, 1].imshow(phase_gs, cmap='hsv', origin='lower')
    axes[0, 1].set_title('GS Phase Pattern', fontsize=13)
    axes[0, 1].axis('off')
    
    axes[0, 2].imshow(recon_gs_norm, cmap='hot', origin='lower')
    axes[0, 2].set_title(f'GS Reconstruction\nPSNR = {psnr_gs:.1f} dB', fontsize=13)
    axes[0, 2].axis('off')
    
    axes[0, 3].imshow(np.abs(recon_gs_norm - target), cmap='magma', origin='lower',
                       vmin=0, vmax=0.5)
    axes[0, 3].set_title('GS Error Map', fontsize=13)
    axes[0, 3].axis('off')
    
    # Row 2: TPL-enhanced
    axes[1, 0].imshow(target, cmap='hot', origin='lower')
    axes[1, 0].set_title('Target Pattern', fontsize=13)
    axes[1, 0].axis('off')
    
    axes[1, 1].imshow(phase_tpl, cmap='hsv', origin='lower')
    axes[1, 1].set_title('TPL Phase Pattern', fontsize=13)
    axes[1, 1].axis('off')
    
    axes[1, 2].imshow(recon_tpl_norm, cmap='hot', origin='lower')
    axes[1, 2].set_title(f'TPL Reconstruction\nPSNR = {psnr_tpl:.1f} dB', fontsize=13)
    axes[1, 2].axis('off')
    
    axes[1, 3].imshow(np.abs(recon_tpl_norm - target), cmap='magma', origin='lower',
                       vmin=0, vmax=0.5)
    axes[1, 3].set_title('TPL Error Map', fontsize=13)
    axes[1, 3].axis('off')
    
    plt.tight_layout()
    plt.savefig('demos/output/holographic_reconstruction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"✓ Generated: demos/output/holographic_reconstruction.png")
    print(f"  Standard GS PSNR: {psnr_gs:.1f} dB")
    print(f"  TPL-Enhanced PSNR: {psnr_tpl:.1f} dB")
    
    # Convergence plot
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.semilogy(errors_gs, 'b-', linewidth=2, label=f'Standard GS (final PSNR: {psnr_gs:.1f} dB)')
    ax.semilogy(errors_tpl, 'r-', linewidth=2, label=f'TPL-Enhanced (final PSNR: {psnr_tpl:.1f} dB)')
    ax.set_xlabel('Iteration', fontsize=14)
    ax.set_ylabel('RMS Error', fontsize=14)
    ax.set_title('Convergence: Standard vs TPL-Enhanced Phase Retrieval', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('demos/output/convergence_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated: demos/output/convergence_comparison.png")

if __name__ == '__main__':
    main()
