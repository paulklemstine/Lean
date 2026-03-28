"""
Demo 4: Phase Entropy Analysis
===============================
Demonstrates the Phase Entropy functional and its relationship to
holographic fidelity. Validates the Phase Entropy Bound (Theorem 3.1).

Generates: output/phase_entropy_analysis.png
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.fft import fft2, ifft2, fftshift, ifftshift

def compute_phase_entropy(phase):
    """Compute the phase entropy S[φ] = -∫ ρ log ρ dμ."""
    # Phase gradient magnitude
    grad_x = np.gradient(phase, axis=1)
    grad_y = np.gradient(phase, axis=0)
    grad_mag_sq = grad_x**2 + grad_y**2
    
    # Normalize to get density
    total = np.sum(grad_mag_sq)
    if total < 1e-15:
        return 0.0
    rho = grad_mag_sq / total
    
    # Entropy (avoid log(0))
    rho_safe = np.where(rho > 1e-30, rho, 1e-30)
    entropy = -np.sum(rho * np.log(rho_safe)) / rho.size
    
    return entropy

def compute_fidelity(target, reconstruction):
    """Compute holographic fidelity as normalized cross-correlation."""
    t = target / (np.linalg.norm(target) + 1e-15)
    r = reconstruction / (np.linalg.norm(reconstruction) + 1e-15)
    return np.abs(np.sum(t * r))**2

def create_test_target(N, complexity='medium'):
    """Create test targets of varying complexity."""
    x = np.linspace(-1, 1, N)
    y = np.linspace(-1, 1, N)
    X, Y = np.meshgrid(x, y)
    R = np.sqrt(X**2 + Y**2)
    
    if complexity == 'simple':
        return np.exp(-R**2 / 0.2)
    elif complexity == 'medium':
        return np.exp(-R**2 / 0.3) * (1 + 0.5 * np.cos(10 * X) * np.cos(10 * Y))
    elif complexity == 'complex':
        target = np.zeros((N, N))
        rng = np.random.RandomState(42)
        for _ in range(20):
            x0, y0 = rng.uniform(-0.8, 0.8, 2)
            target += np.exp(-((X - x0)**2 + (Y - y0)**2) / 0.02)
        return target / target.max()
    else:
        return np.abs(np.sin(15 * X) * np.sin(15 * Y))

def gs_with_initial_phase(target, initial_phase, iterations=50):
    """Run GS algorithm with a given initial phase."""
    N = target.shape[0]
    source_amplitude = np.ones((N, N))
    phase = initial_phase.copy()
    
    for _ in range(iterations):
        source_field = source_amplitude * np.exp(1j * phase)
        target_field = fftshift(fft2(ifftshift(source_field)))
        target_phase = np.angle(target_field)
        target_field_c = target * np.exp(1j * target_phase)
        source_field = ifftshift(ifft2(fftshift(target_field_c)))
        phase = np.angle(source_field)
    
    # Final reconstruction
    final_source = source_amplitude * np.exp(1j * phase)
    final_target = fftshift(fft2(ifftshift(final_source)))
    
    return phase, np.abs(final_target)

def main():
    N = 128
    num_trials = 200
    rng = np.random.RandomState(42)
    
    target = create_test_target(N, 'medium')
    target = target / target.max()
    
    # Generate phase patterns with varying entropy
    entropies = []
    fidelities = []
    phase_types = []
    
    # Type 1: Low entropy (concentrated gradients)
    for _ in range(num_trials // 4):
        # Create phase with concentrated gradients (low entropy)
        cx, cy = rng.randint(N // 4, 3 * N // 4, 2)
        phase = np.zeros((N, N))
        x_arr = np.arange(N)
        y_arr = np.arange(N)
        XX, YY = np.meshgrid(x_arr, y_arr)
        phase = 5 * np.arctan2(YY - cy, XX - cx) + rng.uniform(-0.5, 0.5, (N, N))
        
        _, recon = gs_with_initial_phase(target, phase, iterations=30)
        recon_norm = recon / (recon.max() + 1e-15)
        
        entropy = compute_phase_entropy(phase)
        fidelity = compute_fidelity(target, recon_norm)
        entropies.append(entropy)
        fidelities.append(fidelity)
        phase_types.append('concentrated')
    
    # Type 2: Medium entropy (smooth random)
    for _ in range(num_trials // 4):
        base = rng.uniform(0, 2 * np.pi, (N // 8, N // 8))
        from scipy.ndimage import zoom
        phase = zoom(base, N / (N // 8), order=3)[:N, :N]
        
        _, recon = gs_with_initial_phase(target, phase, iterations=30)
        recon_norm = recon / (recon.max() + 1e-15)
        
        entropy = compute_phase_entropy(phase)
        fidelity = compute_fidelity(target, recon_norm)
        entropies.append(entropy)
        fidelities.append(fidelity)
        phase_types.append('smooth')
    
    # Type 3: High entropy (random diffuser)
    for _ in range(num_trials // 4):
        phase = rng.uniform(0, 2 * np.pi, (N, N))
        
        _, recon = gs_with_initial_phase(target, phase, iterations=30)
        recon_norm = recon / (recon.max() + 1e-15)
        
        entropy = compute_phase_entropy(phase)
        fidelity = compute_fidelity(target, recon_norm)
        entropies.append(entropy)
        fidelities.append(fidelity)
        phase_types.append('random')
    
    # Type 4: TPL-optimized (structured + diffuser)
    for _ in range(num_trials // 4):
        # Topological component
        charges = rng.randint(-3, 4, rng.randint(1, 5))
        positions = rng.uniform(0, N, (len(charges), 2))
        XX, YY = np.meshgrid(np.arange(N), np.arange(N))
        phase_topo = np.zeros((N, N))
        for q, (px, py) in zip(charges, positions):
            phase_topo += q * np.arctan2(YY - py, XX - px)
        
        # Smooth component
        base = rng.uniform(0, np.pi, (N // 4, N // 4))
        phase_smooth = zoom(base, N / (N // 4), order=3)[:N, :N]
        
        # Noise component (entropy maximizer)
        phase_noise = rng.uniform(-0.5, 0.5, (N, N))
        
        phase = phase_topo + phase_smooth + phase_noise
        
        _, recon = gs_with_initial_phase(target, phase, iterations=30)
        recon_norm = recon / (recon.max() + 1e-15)
        
        entropy = compute_phase_entropy(phase)
        fidelity = compute_fidelity(target, recon_norm)
        entropies.append(entropy)
        fidelities.append(fidelity)
        phase_types.append('TPL')
    
    entropies = np.array(entropies)
    fidelities = np.array(fidelities)
    
    # === Plotting ===
    fig, axes = plt.subplots(2, 2, figsize=(16, 14))
    fig.suptitle('Phase Entropy Analysis: Validating the Holographic Fidelity Bound',
                 fontsize=18, fontweight='bold')
    
    # Panel 1: Entropy vs Fidelity scatter
    colors_map = {'concentrated': '#e74c3c', 'smooth': '#f39c12',
                  'random': '#2ecc71', 'TPL': '#3498db'}
    for ptype in ['concentrated', 'smooth', 'random', 'TPL']:
        mask = np.array(phase_types) == ptype
        axes[0, 0].scatter(entropies[mask], fidelities[mask],
                          c=colors_map[ptype], label=ptype, alpha=0.6, s=30)
    
    # Theoretical bound line
    S_max = np.log(N * N)
    S_range = np.linspace(entropies.min(), entropies.max(), 100)
    bound = 1 - (1 / (2 * np.pi)) * ((S_max - S_range) / S_max)**2 * 2  # χ(D²) = 1
    axes[0, 0].plot(S_range, np.clip(bound, 0, 1), 'k--', linewidth=2,
                     label='Theoretical Bound\n(Theorem 3.1)')
    
    axes[0, 0].set_xlabel('Phase Entropy S[φ]', fontsize=13)
    axes[0, 0].set_ylabel('Holographic Fidelity F', fontsize=13)
    axes[0, 0].set_title('Phase Entropy vs Holographic Fidelity', fontsize=14)
    axes[0, 0].legend(fontsize=10)
    axes[0, 0].grid(True, alpha=0.3)
    
    # Panel 2: Entropy distributions
    for ptype in ['concentrated', 'smooth', 'random', 'TPL']:
        mask = np.array(phase_types) == ptype
        axes[0, 1].hist(entropies[mask], bins=20, alpha=0.5, color=colors_map[ptype],
                        label=ptype, density=True)
    axes[0, 1].set_xlabel('Phase Entropy', fontsize=13)
    axes[0, 1].set_ylabel('Density', fontsize=13)
    axes[0, 1].set_title('Distribution of Phase Entropy by Type', fontsize=14)
    axes[0, 1].legend(fontsize=10)
    axes[0, 1].grid(True, alpha=0.3)
    
    # Panel 3: Fidelity distributions
    for ptype in ['concentrated', 'smooth', 'random', 'TPL']:
        mask = np.array(phase_types) == ptype
        axes[1, 0].hist(fidelities[mask], bins=20, alpha=0.5, color=colors_map[ptype],
                        label=ptype, density=True)
    axes[1, 0].set_xlabel('Holographic Fidelity', fontsize=13)
    axes[1, 0].set_ylabel('Density', fontsize=13)
    axes[1, 0].set_title('Distribution of Fidelity by Phase Type', fontsize=14)
    axes[1, 0].legend(fontsize=10)
    axes[1, 0].grid(True, alpha=0.3)
    
    # Panel 4: Box plots
    data_by_type = {}
    for ptype in ['concentrated', 'smooth', 'random', 'TPL']:
        mask = np.array(phase_types) == ptype
        data_by_type[ptype] = fidelities[mask]
    
    bp = axes[1, 1].boxplot(data_by_type.values(), labels=data_by_type.keys(),
                             patch_artist=True)
    for patch, ptype in zip(bp['boxes'], data_by_type.keys()):
        patch.set_facecolor(colors_map[ptype])
        patch.set_alpha(0.6)
    axes[1, 1].set_ylabel('Holographic Fidelity', fontsize=13)
    axes[1, 1].set_title('Fidelity Comparison Across Phase Types', fontsize=14)
    axes[1, 1].grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('demos/output/phase_entropy_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Generated: demos/output/phase_entropy_analysis.png")

if __name__ == '__main__':
    main()
