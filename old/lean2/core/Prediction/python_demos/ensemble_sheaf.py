#!/usr/bin/env python3
"""
ENSEMBLE PREDICTION AS SHEAF THEORY

Demonstrates the sheaf-theoretic view of ensemble forecasting:
- Each predictor provides "local" predictions (sections over time intervals)
- The sheaf condition requires consistency on overlaps
- Global prediction = gluing of consistent local sections

This framework explains:
1. Why ensemble methods (random forests, boosting) outperform single models
2. Why inconsistent predictions signal unreliability
3. How to detect "prediction phase transitions" (sudden loss of consensus)

EXPERIMENT: We validate three hypotheses about prediction ensembles.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

np.random.seed(42)

# ============================================================
# THE SIGNAL: A process with varying predictability
# ============================================================

def generate_signal(n_points=1000):
    """Generate a signal with three regimes:
    1. Periodic (highly predictable)
    2. Trending with noise (moderately predictable)
    3. Chaotic (unpredictable)
    """
    t = np.linspace(0, 10, n_points)
    signal = np.zeros(n_points)

    # Phase 1: Periodic (t < 3.3)
    mask1 = t < 3.3
    signal[mask1] = np.sin(2 * np.pi * t[mask1]) + 0.1 * np.random.randn(mask1.sum())

    # Phase 2: Trending (3.3 ≤ t < 6.6)
    mask2 = (t >= 3.3) & (t < 6.6)
    signal[mask2] = 0.5 * (t[mask2] - 5) + 0.3 * np.random.randn(mask2.sum())

    # Phase 3: Chaotic (t ≥ 6.6)
    mask3 = t >= 6.6
    n3 = mask3.sum()
    chaotic = np.zeros(n3)
    chaotic[0] = 0.1
    for i in range(1, n3):
        chaotic[i] = 3.9 * chaotic[i-1] * (1 - chaotic[i-1])  # Logistic map
    signal[mask3] = chaotic + 0.1 * np.random.randn(n3)

    return t, signal

# ============================================================
# PREDICTORS: Different "local sections" of the prediction sheaf
# ============================================================

def moving_average_predictor(signal, window=20):
    """Simple moving average — good for trends"""
    pred = np.convolve(signal, np.ones(window)/window, mode='same')
    return pred

def fourier_predictor(signal, n_harmonics=5):
    """Fourier extrapolation — good for periodic signals"""
    fft = np.fft.rfft(signal)
    fft[n_harmonics:] = 0
    return np.fft.irfft(fft, n=len(signal))

def linear_predictor(signal, window=50):
    """Local linear regression — good for trends"""
    pred = np.zeros_like(signal)
    for i in range(len(signal)):
        start = max(0, i - window)
        end = min(len(signal), i + 1)
        x = np.arange(end - start)
        if len(x) > 1:
            coeffs = np.polyfit(x, signal[start:end], 1)
            pred[i] = coeffs[0] * len(x) + coeffs[1]
        else:
            pred[i] = signal[i]
    return pred

def persistence_predictor(signal):
    """Tomorrow = today — the simplest predictor"""
    pred = np.roll(signal, 1)
    pred[0] = signal[0]
    return pred

# ============================================================
# SHEAF CONSISTENCY: Measuring agreement among predictors
# ============================================================

def sheaf_consistency(predictions, window=30):
    """Measure how well predictors agree (the sheaf condition).
    Low consistency = predictors disagree = predictions unreliable.
    This is the "overlap agreement" in sheaf-theoretic language."""
    n_predictors = len(predictions)
    n_points = len(predictions[0])
    consistency = np.zeros(n_points)

    for i in range(n_points):
        start = max(0, i - window // 2)
        end = min(n_points, i + window // 2)
        local_preds = np.array([p[start:end] for p in predictions])
        # Consistency = 1 - normalized variance across predictors
        variance = np.mean(np.var(local_preds, axis=0))
        signal_var = np.var(np.mean(local_preds, axis=0)) + 1e-10
        consistency[i] = max(0, 1 - variance / (signal_var + variance))

    return consistency

def ensemble_predict(predictions, weights=None):
    """Weighted ensemble prediction (the "glued section")"""
    if weights is None:
        weights = np.ones(len(predictions)) / len(predictions)
    return sum(w * p for w, p in zip(weights, predictions))

def adaptive_weights(predictions, signal, window=30):
    """Compute adaptive weights based on recent performance.
    Better recent performers get higher weights — this is the
    "meta-oracle" choosing which oracle to trust."""
    n_predictors = len(predictions)
    n_points = len(predictions[0])
    weights = np.zeros((n_predictors, n_points))

    for i in range(n_points):
        start = max(0, i - window)
        end = i + 1
        errors = np.array([
            np.mean((p[start:end] - signal[start:end])**2) + 1e-10
            for p in predictions
        ])
        # Exponential weighting: better performers get exponentially more weight
        inv_errors = 1.0 / errors
        weights[:, i] = inv_errors / inv_errors.sum()

    return weights

# ============================================================
# MAIN EXPERIMENT
# ============================================================

def main():
    t, signal = generate_signal(1000)

    # Create predictions (local sections)
    preds = [
        moving_average_predictor(signal, window=20),
        fourier_predictor(signal, n_harmonics=5),
        linear_predictor(signal, window=50),
        persistence_predictor(signal),
    ]
    pred_names = ['Moving Avg', 'Fourier', 'Linear', 'Persistence']

    # Compute sheaf consistency
    consistency = sheaf_consistency(preds, window=30)

    # Compute adaptive weights
    weights = adaptive_weights(preds, signal, window=30)

    # Equal-weight ensemble
    equal_ensemble = ensemble_predict(preds)

    # Adaptive ensemble
    adaptive_ensemble = np.array([
        sum(weights[j, i] * preds[j][i] for j in range(len(preds)))
        for i in range(len(signal))
    ])

    # === VISUALIZATION ===
    fig = plt.figure(figsize=(18, 20))
    fig.suptitle("Prediction as Sheaf Theory: Local Consistency → Global Accuracy",
                 fontsize=16, fontweight='bold', y=0.98)
    gs = GridSpec(4, 2, figure=fig, hspace=0.4, wspace=0.3)

    # Panel 1: Signal with regime annotations
    ax1 = fig.add_subplot(gs[0, :])
    ax1.plot(t, signal, 'k-', linewidth=1.5, alpha=0.8, label='True Signal')
    ax1.axvspan(0, 3.3, alpha=0.1, color='green', label='Periodic regime')
    ax1.axvspan(3.3, 6.6, alpha=0.1, color='yellow', label='Trending regime')
    ax1.axvspan(6.6, 10, alpha=0.1, color='red', label='Chaotic regime')
    ax1.set_title('The Signal: Three Predictability Regimes', fontsize=13)
    ax1.legend(fontsize=10, loc='upper right')
    ax1.set_xlabel('Time')
    ax1.grid(True, alpha=0.3)

    # Panel 2: Individual predictors
    ax2 = fig.add_subplot(gs[1, 0])
    colors = ['blue', 'orange', 'green', 'purple']
    for pred, name, color in zip(preds, pred_names, colors):
        ax2.plot(t, pred, color=color, alpha=0.7, linewidth=1, label=name)
    ax2.plot(t, signal, 'k-', alpha=0.3, linewidth=0.5, label='Truth')
    ax2.set_title('Individual Predictors (Local Sections)', fontsize=13)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # Panel 3: Sheaf consistency
    ax3 = fig.add_subplot(gs[1, 1])
    ax3.fill_between(t, 0, consistency, alpha=0.5, color='teal')
    ax3.plot(t, consistency, 'teal', linewidth=1.5)
    ax3.axvspan(0, 3.3, alpha=0.05, color='green')
    ax3.axvspan(3.3, 6.6, alpha=0.05, color='yellow')
    ax3.axvspan(6.6, 10, alpha=0.05, color='red')
    ax3.set_title('Sheaf Consistency (Predictor Agreement)', fontsize=13)
    ax3.set_ylabel('Consistency Score')
    ax3.set_ylim(0, 1)
    ax3.grid(True, alpha=0.3)
    ax3.text(1.5, 0.9, 'HIGH\n(Predictable)', ha='center', fontsize=11, color='green',
             fontweight='bold')
    ax3.text(8.3, 0.15, 'LOW\n(Chaotic)', ha='center', fontsize=11, color='red',
             fontweight='bold')

    # Panel 4: Ensemble predictions
    ax4 = fig.add_subplot(gs[2, 0])
    ax4.plot(t, signal, 'k-', linewidth=1.5, alpha=0.5, label='Truth')
    ax4.plot(t, equal_ensemble, 'b-', linewidth=1.5, alpha=0.8, label='Equal-weight')
    ax4.plot(t, adaptive_ensemble, 'r-', linewidth=1.5, alpha=0.8, label='Adaptive (meta-oracle)')
    ax4.set_title('Ensemble Predictions (Glued Sections)', fontsize=13)
    ax4.legend(fontsize=10)
    ax4.grid(True, alpha=0.3)

    # Panel 5: Adaptive weights over time
    ax5 = fig.add_subplot(gs[2, 1])
    for j, (name, color) in enumerate(zip(pred_names, colors)):
        ax5.fill_between(t, 0, weights[j], alpha=0.3, color=color)
        ax5.plot(t, weights[j], color=color, linewidth=1, label=name)
    ax5.set_title('Adaptive Weights (Meta-Oracle Allocation)', fontsize=13)
    ax5.set_ylabel('Weight')
    ax5.legend(fontsize=9, loc='upper right')
    ax5.grid(True, alpha=0.3)

    # Panel 6: Error comparison
    ax6 = fig.add_subplot(gs[3, 0])
    window = 30
    for pred, name, color in zip(preds, pred_names, colors):
        err = np.convolve((pred - signal)**2, np.ones(window)/window, mode='same')
        ax6.semilogy(t, err + 1e-10, color=color, alpha=0.7, linewidth=1, label=name)

    equal_err = np.convolve((equal_ensemble - signal)**2,
                            np.ones(window)/window, mode='same')
    adaptive_err = np.convolve((adaptive_ensemble - signal)**2,
                               np.ones(window)/window, mode='same')
    ax6.semilogy(t, equal_err + 1e-10, 'b--', linewidth=2.5, label='Equal Ensemble')
    ax6.semilogy(t, adaptive_err + 1e-10, 'r--', linewidth=2.5, label='Adaptive Ensemble')
    ax6.set_title('Rolling MSE: Ensembles vs. Individuals', fontsize=13)
    ax6.legend(fontsize=8, loc='upper left')
    ax6.grid(True, alpha=0.3)
    ax6.set_xlabel('Time')

    # Panel 7: Hypothesis validation
    ax7 = fig.add_subplot(gs[3, 1])
    ax7.axis('off')

    # Compute hypothesis metrics
    periodic_mask = t < 3.3
    trend_mask = (t >= 3.3) & (t < 6.6)
    chaotic_mask = t >= 6.6

    results = []
    for mask, regime in [(periodic_mask, 'Periodic'), (trend_mask, 'Trending'),
                          (chaotic_mask, 'Chaotic')]:
        idx = np.where(mask)[0]
        individual_mses = [np.mean((p[idx] - signal[idx])**2) for p in preds]
        best_individual = min(individual_mses)
        equal_mse = np.mean((equal_ensemble[idx] - signal[idx])**2)
        adaptive_mse = np.mean((adaptive_ensemble[idx] - signal[idx])**2)
        consistency_mean = np.mean(consistency[idx])
        results.append({
            'regime': regime,
            'best_individual': best_individual,
            'equal_ensemble': equal_mse,
            'adaptive_ensemble': adaptive_mse,
            'consistency': consistency_mean
        })

    text = "═══════════════════════════════════════════════\n"
    text += "         HYPOTHESIS VALIDATION RESULTS\n"
    text += "═══════════════════════════════════════════════\n\n"

    text += "H1: Sheaf consistency predicts error magnitude\n"
    for r in results:
        text += f"  {r['regime']:10s}: consistency={r['consistency']:.3f}, "
        text += f"error={r['adaptive_ensemble']:.4f}\n"
    h1_valid = results[0]['consistency'] > results[2]['consistency'] and \
               results[0]['adaptive_ensemble'] < results[2]['adaptive_ensemble']
    text += f"  → {'✅ CONFIRMED' if h1_valid else '❌ REFUTED'}: "
    text += "High consistency ↔ Low error\n\n"

    text += "H2: Adaptive ensemble ≤ best individual\n"
    h2_scores = []
    for r in results:
        better = r['adaptive_ensemble'] <= r['best_individual'] * 1.05  # 5% tolerance
        h2_scores.append(better)
        text += f"  {r['regime']:10s}: adaptive={r['adaptive_ensemble']:.4f}, "
        text += f"best_ind={r['best_individual']:.4f} "
        text += f"{'✅' if better else '❌'}\n"
    text += f"  → {'✅ CONFIRMED' if all(h2_scores) else '⚠️ PARTIAL'}\n\n"

    text += "H3: Consistency drops at regime transitions\n"
    # Check consistency dip at transition points
    trans1_idx = np.argmin(np.abs(t - 3.3))
    trans2_idx = np.argmin(np.abs(t - 6.6))
    local_consistency_1 = consistency[trans1_idx-10:trans1_idx+10].mean()
    local_consistency_2 = consistency[trans2_idx-10:trans2_idx+10].mean()
    global_mean = consistency.mean()
    text += f"  Transition 1 (t≈3.3): consistency={local_consistency_1:.3f}\n"
    text += f"  Transition 2 (t≈6.6): consistency={local_consistency_2:.3f}\n"
    text += f"  Global mean:           consistency={global_mean:.3f}\n"
    h3_valid = local_consistency_1 < global_mean or local_consistency_2 < global_mean
    text += f"  → {'✅ CONFIRMED' if h3_valid else '❌ REFUTED'}: "
    text += "Consistency dips at transitions\n"

    ax7.text(0.05, 0.95, text, transform=ax7.transAxes,
             fontsize=9.5, verticalalignment='top', fontfamily='monospace',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

    plt.savefig('/workspace/request-project/Predicting The Future/python_demos/ensemble_sheaf.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("✅ Saved ensemble_sheaf.png")
    print(text)

if __name__ == '__main__':
    main()
