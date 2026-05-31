"""
Demo: Spectral-Compression Complexity (SCC) for Deep Network Generalization

This script demonstrates the key results of the SCC framework:
1. Computes SCC for example networks
2. Shows the double descent witness construction
3. Visualizes how the SCC bound varies with sample size
4. Compares spectral and compression-based bounds
"""

import math
import numpy as np
from algorithms import (
    SpectralProfile,
    compute_spectral_profile,
    spectral_complexity,
    total_effective_rank,
    spectral_compression_complexity,
    scc_generalization_bound,
    compression_gap,
    double_descent_witness,
    effective_rank,
)


def demo_basic_profiles():
    """Demonstrate basic spectral profile computations."""
    print("=" * 60)
    print("DEMO 1: Basic Spectral Profile Computations")
    print("=" * 60)

    # Example 1: Orthogonal network (spectral norms = 1)
    ortho = SpectralProfile(
        spectral_norms=[1.0, 1.0, 1.0],
        frobenius_norms=[5.0, 5.0, 5.0],
        margin=0.5
    )
    print(f"\nOrthogonal 3-layer network (σ=1, F=5, γ=0.5):")
    print(f"  Spectral complexity: {spectral_complexity(ortho):.4f}")
    print(f"  Total effective rank: {total_effective_rank(ortho):.1f}")
    print(f"  SCC: {spectral_compression_complexity(ortho):.2f}")
    print(f"  Gen bound (n=1000, δ=0.05): {scc_generalization_bound(ortho, 1000, 0.05):.4f}")

    # Example 2: High-norm network
    high_norm = SpectralProfile(
        spectral_norms=[3.0, 3.0, 3.0],
        frobenius_norms=[5.0, 5.0, 5.0],
        margin=0.5
    )
    print(f"\nHigh-norm 3-layer network (σ=3, F=5, γ=0.5):")
    print(f"  Spectral complexity: {spectral_complexity(high_norm):.4f}")
    print(f"  Total effective rank: {total_effective_rank(high_norm):.1f}")
    print(f"  SCC: {spectral_compression_complexity(high_norm):.2f}")
    print(f"  Gen bound (n=1000, δ=0.05): {scc_generalization_bound(high_norm, 1000, 0.05):.4f}")

    # Example 3: From random weight matrices
    np.random.seed(42)
    W1 = np.random.randn(100, 50) * 0.1
    W2 = np.random.randn(50, 50) * 0.1
    W3 = np.random.randn(50, 10) * 0.1
    profile = compute_spectral_profile([W1, W2, W3], margin=0.3)
    print(f"\nRandom 3-layer network (100→50→50→10, init scale 0.1):")
    print(f"  Spectral norms: {[f'{s:.3f}' for s in profile.spectral_norms]}")
    print(f"  Frobenius norms: {[f'{f:.3f}' for f in profile.frobenius_norms]}")
    print(f"  Effective ranks: {[f'{effective_rank(profile, i):.1f}' for i in range(3)]}")
    print(f"  Spectral complexity: {spectral_complexity(profile):.6f}")
    print(f"  SCC: {spectral_compression_complexity(profile):.6f}")
    print(f"  Gen bound (n=1000, δ=0.05): {scc_generalization_bound(profile, 1000, 0.05):.6f}")


def demo_double_descent():
    """Demonstrate the double descent witness construction."""
    print("\n" + "=" * 60)
    print("DEMO 2: Double Descent Witness")
    print("=" * 60)

    gamma = 1.0
    p1, p2 = double_descent_witness(gamma)

    print(f"\nProfile P1 (2-layer, rank-1 matrices):")
    print(f"  Depth: {p1.depth}")
    print(f"  Spectral norms: {p1.spectral_norms}")
    print(f"  Frobenius norms: {p1.frobenius_norms}")
    print(f"  Total effective rank: {total_effective_rank(p1):.0f}")
    print(f"  Spectral complexity: {spectral_complexity(p1):.0f}")
    print(f"  SCC: {spectral_compression_complexity(p1):.0f}")

    print(f"\nProfile P2 (1-layer, high effective rank):")
    print(f"  Depth: {p2.depth}")
    print(f"  Spectral norms: {p2.spectral_norms}")
    print(f"  Frobenius norms: {p2.frobenius_norms}")
    print(f"  Total effective rank: {total_effective_rank(p2):.0f}")
    print(f"  Spectral complexity: {spectral_complexity(p2):.0f}")
    print(f"  SCC: {spectral_compression_complexity(p2):.0f}")

    print(f"\n  P2 has {total_effective_rank(p2)/total_effective_rank(p1):.0f}× more effective parameters")
    print(f"  But P2's SCC is {spectral_compression_complexity(p1)/spectral_compression_complexity(p2):.0f}× smaller!")

    print(f"\n  Generalization bounds (n=1000, δ=0.05):")
    n, delta = 1000, 0.05
    b1 = scc_generalization_bound(p1, n, delta)
    b2 = scc_generalization_bound(p2, n, delta)
    print(f"    P1 (fewer params): {b1:.4f}")
    print(f"    P2 (more params):  {b2:.4f}")
    print(f"    P2 bound is {b1/b2:.1f}× tighter ✓")


def demo_convergence():
    """Show that the SCC bound converges to 0 as n → ∞."""
    print("\n" + "=" * 60)
    print("DEMO 3: SCC Bound Convergence")
    print("=" * 60)

    profile = SpectralProfile(
        spectral_norms=[2.0, 2.0],
        frobenius_norms=[5.0, 5.0],
        margin=0.5
    )
    scc = spectral_compression_complexity(profile)
    print(f"\n2-layer network with SCC = {scc:.0f}")
    print(f"\n{'n':>10} | {'Bound':>10} | {'Bound²×n':>10}")
    print("-" * 36)
    for n in [100, 500, 1000, 5000, 10000, 50000, 100000]:
        b = scc_generalization_bound(profile, n, 0.05)
        print(f"{n:>10} | {b:>10.6f} | {b**2 * n:>10.2f}")

    print("\nNote: Bound → 0 as n → ∞ (consistency theorem)")
    print("Note: Bound² × n → SCC × ln(2) ≈ {:.1f} (the asymptotic rate)".format(
        scc * math.log(2)))


def demo_compression_comparison():
    """Compare spectral and compression bounds."""
    print("\n" + "=" * 60)
    print("DEMO 4: Spectral vs Compression Bounds")
    print("=" * 60)

    n = 1000
    delta = 0.05

    print(f"\nSample size n = {n}, confidence δ = {delta}")
    print(f"\n{'k (bits)':>10} | {'Compression gap':>15} | {'SCC bound (equiv)':>17}")
    print("-" * 50)

    for k in [10, 50, 100, 500, 1000, 5000]:
        c_gap = compression_gap(k, n, delta)
        # Equivalent SCC that would give same bound
        equiv_scc = (c_gap**2 * n - math.log(1/delta)) / math.log(2*n) if c_gap > 0 else 0
        print(f"{k:>10} | {c_gap:>15.6f} | {max(0,equiv_scc):>17.2f}")


def demo_depth_tradeoff():
    """Show the depth vs spectral norm tradeoff."""
    print("\n" + "=" * 60)
    print("DEMO 5: Depth vs Spectral Norm Tradeoff")
    print("=" * 60)

    gamma = 1.0
    n, delta = 5000, 0.05

    print(f"\nFixed margin γ = {gamma}, n = {n}, δ = {delta}")
    print(f"Frobenius norm = 10 for each layer")
    print(f"\n{'Depth':>6} | {'σ_per_layer':>11} | {'C_spec':>10} | {'R_eff':>8} | {'SCC':>12} | {'Bound':>8}")
    print("-" * 70)

    for L in [1, 2, 3, 5, 10, 20]:
        # Spectral norm chosen so C_spec stays constant at 10
        sigma = 10 ** (1/L)
        F = 10.0
        profile = SpectralProfile(
            spectral_norms=[sigma] * L,
            frobenius_norms=[F] * L,
            margin=gamma
        )
        c = spectral_complexity(profile)
        r = total_effective_rank(profile)
        scc = spectral_compression_complexity(profile)
        b = scc_generalization_bound(profile, n, delta)
        print(f"{L:>6} | {sigma:>11.4f} | {c:>10.2f} | {r:>8.1f} | {scc:>12.1f} | {b:>8.4f}")


if __name__ == "__main__":
    demo_basic_profiles()
    demo_double_descent()
    demo_convergence()
    demo_compression_comparison()
    demo_depth_tradeoff()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""Generate PACKAGE.json from component files."""
import json

# Read files
with open("ARTICLE.md") as f:
    article = f.read()
with open("RESEARCH_PAPER.md") as f:
    research_paper = f.read()
with open("FUTURE_DIRECTIONS.md") as f:
    future_directions = f.read()
with open("demo.py") as f:
    demo_code = f.read()
with open("algorithms.py") as f:
    algo_code = f.read()
with open("viz_double_descent.py") as f:
    viz1_code = f.read()
with open("viz_convergence.py") as f:
    viz2_code = f.read()
with open("viz_spectral_landscape.py") as f:
    viz3_code = f.read()
with open("MachineLearning/Generalization/SpectralBounds.lean") as f:
    lean_code = f.read()

interactive_html = '''<div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px; background: #f8f9fa; border-radius: 12px;">
  <h2 style="color: #1a237e; margin-bottom: 5px;">Spectral-Compression Complexity Explorer</h2>
  <p style="color: #666; font-size: 14px; margin-top: 0;">Explore how depth, spectral norms, and margin interact to determine generalization bounds</p>

  <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
    <div style="background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
      <label style="font-weight: 600; color: #333;">Depth (L): <span id="depthVal">3</span></label><br>
      <input type="range" id="depth" min="1" max="20" value="3" style="width: 100%;" oninput="update()">

      <label style="font-weight: 600; color: #333;">Spectral Norm (σ): <span id="sigmaVal">1.50</span></label><br>
      <input type="range" id="sigma" min="50" max="500" value="150" style="width: 100%;" oninput="update()">

      <label style="font-weight: 600; color: #333;">Frobenius Norm (F): <span id="frobVal">5.0</span></label><br>
      <input type="range" id="frob" min="100" max="3000" value="500" style="width: 100%;" oninput="update()">

      <label style="font-weight: 600; color: #333;">Margin (γ): <span id="marginVal">1.00</span></label><br>
      <input type="range" id="margin" min="10" max="500" value="100" style="width: 100%;" oninput="update()">

      <label style="font-weight: 600; color: #333;">Samples (n): <span id="nVal">1000</span></label><br>
      <input type="range" id="nsamples" min="100" max="100000" value="1000" style="width: 100%;" oninput="update()">
    </div>

    <div style="background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
      <h3 style="margin-top: 0; color: #1a237e;">Network Profile</h3>
      <div id="results" style="font-size: 14px; line-height: 2;"></div>
    </div>
  </div>

  <div style="background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px;">
    <h3 style="margin-top: 0; color: #1a237e;">Generalization Bound vs Sample Size</h3>
    <canvas id="chart" width="850" height="300" style="width: 100%;"></canvas>
  </div>

  <div style="background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <h3 style="margin-top: 0; color: #1a237e;">Double Descent Comparison</h3>
    <div id="dd_results" style="font-size: 14px;"></div>
  </div>

  <script>
    function computeSCC(L, sigma, F, gamma) {
      var R_eff = L * Math.pow(F / sigma, 2);
      var C_spec = Math.pow(sigma, L) / gamma;
      return L * L * R_eff * C_spec * C_spec;
    }

    function sccBound(scc, n, delta) {
      var inner = scc * Math.log(2 * n) / n + Math.log(1 / delta) / n;
      return Math.sqrt(Math.max(0, inner));
    }

    function update() {
      var L = parseInt(document.getElementById('depth').value);
      var sigma = parseInt(document.getElementById('sigma').value) / 100;
      var F = parseInt(document.getElementById('frob').value) / 100;
      var gamma = parseInt(document.getElementById('margin').value) / 100;
      var n = parseInt(document.getElementById('nsamples').value);
      var delta = 0.05;

      if (F < sigma) { F = sigma + 0.01; document.getElementById('frob').value = Math.round(F * 100); }

      document.getElementById('depthVal').textContent = L;
      document.getElementById('sigmaVal').textContent = sigma.toFixed(2);
      document.getElementById('frobVal').textContent = F.toFixed(1);
      document.getElementById('marginVal').textContent = gamma.toFixed(2);
      document.getElementById('nVal').textContent = n;

      var R_eff = L * Math.pow(F / sigma, 2);
      var C_spec = Math.pow(sigma, L) / gamma;
      var scc = computeSCC(L, sigma, F, gamma);
      var bound = sccBound(scc, n, delta);

      var resultsHTML = '<div>';
      resultsHTML += '<b>Spectral Complexity:</b> ' + C_spec.toFixed(2) + '<br>';
      resultsHTML += '<b>Effective Rank/Layer:</b> ' + (Math.pow(F/sigma, 2)).toFixed(1) + '<br>';
      resultsHTML += '<b>Total Effective Rank:</b> ' + R_eff.toFixed(1) + '<br>';
      resultsHTML += '<b style="color: #e65100;">SCC:</b> ' + scc.toExponential(2) + '<br>';
      resultsHTML += '<b style="color: #1b5e20;">Gen Bound:</b> ' + bound.toFixed(4) + '<br>';

      var color = bound < 0.1 ? '#4CAF50' : bound < 1.0 ? '#FF9800' : '#F44336';
      resultsHTML += '<div style="margin-top: 10px; padding: 8px; background: ' + color + '22; border-left: 4px solid ' + color + '; border-radius: 4px;">';
      resultsHTML += bound < 0.1 ? '✅ Tight bound — network likely generalizes well' :
                     bound < 1.0 ? '⚠️ Moderate bound — generalization possible but uncertain' :
                     '❌ Loose bound — generalization not guaranteed by this measure';
      resultsHTML += '</div></div>';
      document.getElementById('results').innerHTML = resultsHTML;

      // Draw chart
      var canvas = document.getElementById('chart');
      var ctx = canvas.getContext('2d');
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      var nValues = [];
      var bounds = [];
      for (var i = 2; i <= 6; i += 0.02) {
        var ni = Math.round(Math.pow(10, i));
        nValues.push(ni);
        bounds.push(sccBound(scc, ni, delta));
      }

      var maxB = Math.max(...bounds);
      var minN = nValues[0], maxN = nValues[nValues.length - 1];
      var pad = 50;
      var w = canvas.width - 2 * pad, h = canvas.height - 2 * pad;

      // Axes
      ctx.strokeStyle = '#ccc'; ctx.lineWidth = 1;
      ctx.beginPath(); ctx.moveTo(pad, pad); ctx.lineTo(pad, pad + h); ctx.lineTo(pad + w, pad + h); ctx.stroke();

      // Labels
      ctx.fillStyle = '#333'; ctx.font = '12px sans-serif';
      ctx.fillText('Sample size n (log scale)', pad + w/2 - 60, pad + h + 40);
      ctx.save(); ctx.rotate(-Math.PI/2); ctx.fillText('Bound', -(pad + h/2 + 20), 15); ctx.restore();

      // X-axis ticks
      for (var exp = 2; exp <= 6; exp++) {
        var x = pad + (exp - 2) / 4 * w;
        ctx.fillText('10^' + exp, x - 10, pad + h + 20);
        ctx.beginPath(); ctx.moveTo(x, pad + h); ctx.lineTo(x, pad + h + 5); ctx.stroke();
      }

      // Plot
      ctx.strokeStyle = '#1a237e'; ctx.lineWidth = 2.5;
      ctx.beginPath();
      for (var i = 0; i < nValues.length; i++) {
        var x = pad + (Math.log10(nValues[i]) - 2) / 4 * w;
        var y = pad + h - (bounds[i] / maxB) * h;
        if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
      }
      ctx.stroke();

      // Current n marker
      if (n >= minN && n <= maxN) {
        var cx = pad + (Math.log10(n) - 2) / 4 * w;
        var cy = pad + h - (bound / maxB) * h;
        ctx.fillStyle = '#F44336'; ctx.beginPath(); ctx.arc(cx, cy, 6, 0, 2*Math.PI); ctx.fill();
        ctx.fillStyle = '#333'; ctx.fillText('n=' + n + ', bound=' + bound.toFixed(3), cx + 10, cy - 5);
      }

      // Double descent comparison
      var scc1 = computeSCC(2, 10, 10, gamma);
      var scc2 = computeSCC(1, 1, 10, gamma);
      var b1 = sccBound(scc1, n, delta);
      var b2 = sccBound(scc2, n, delta);
      var ddHTML = '<table style="width: 100%; border-collapse: collapse;">';
      ddHTML += '<tr style="background: #e3f2fd;"><th style="padding: 8px; text-align: left;">Profile</th><th>Depth</th><th>Eff. Rank</th><th>SCC</th><th>Bound</th></tr>';
      ddHTML += '<tr><td style="padding: 8px;"><b>P₁</b> (deep, rank-1)</td><td style="text-align:center;">2</td><td style="text-align:center;">2</td><td style="text-align:center;">' + scc1.toFixed(0) + '</td><td style="text-align:center; color: #F44336;">' + b1.toFixed(4) + '</td></tr>';
      ddHTML += '<tr style="background: #f1f8e9;"><td style="padding: 8px;"><b>P₂</b> (shallow, wide)</td><td style="text-align:center;">1</td><td style="text-align:center;">100</td><td style="text-align:center;">' + scc2.toFixed(0) + '</td><td style="text-align:center; color: #4CAF50;">' + b2.toFixed(4) + '</td></tr>';
      ddHTML += '</table>';
      ddHTML += '<p style="margin-top: 10px; color: #666;">P₂ has <b>50×</b> more effective parameters but <b>' + (scc1/scc2).toFixed(0) + '×</b> smaller SCC → tighter bound!</p>';
      document.getElementById('dd_results').innerHTML = ddHTML;
    }

    update();
  </script>
</div>'''

package = {
    "title": "Spectral-Compression Complexity: Unified Generalization Bounds for Deep Networks",
    "domain": "MachineLearning",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "SCC Demo",
            "code": demo_code,
            "description": "Demonstrates SCC computation, double descent witness, convergence, and depth tradeoffs"
        }
    ],
    "algorithms": [
        {
            "name": "SCC Computation",
            "pseudocode": "For each layer: compute spectral norm (SVD), Frobenius norm. R_eff = sum((F_i/sigma_i)^2). C_spec = prod(sigma_i)/gamma. SCC = L^2 * R_eff * C_spec^2.",
            "code": algo_code
        }
    ],
    "visualizations": [
        {
            "name": "Double Descent in SCC Bounds",
            "code": viz1_code,
            "description": "Shows how effective rank and spectral norms interact to create double descent"
        },
        {
            "name": "SCC Bound Convergence",
            "code": viz2_code,
            "description": "Demonstrates that the SCC bound converges to zero as sample size increases"
        },
        {
            "name": "Spectral Complexity Landscape",
            "code": viz3_code,
            "description": "Heatmap of SCC in depth-sigma space showing the spectral regularization sweet spot"
        }
    ],
    "interactive_demos": [
        {
            "name": "SCC Explorer",
            "html": interactive_html,
            "description": "Interactive widget to explore how network depth, spectral norms, margin, and sample size affect the SCC generalization bound"
        }
    ],
    "lean_proofs": [
        {
            "name": "Spectral Generalization Bounds",
            "file": "MachineLearning/Generalization/SpectralBounds.lean",
            "code": lean_code,
            "description": "Fully verified Lean 4 proofs of spectral complexity bounds, effective rank properties, compression gap monotonicity, SCC convergence, and double descent algebraic theorem"
        }
    ]
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("Generated PACKAGE.json")


"""
Visualization: SCC Bound Convergence

Shows that the SCC generalization bound converges to zero as n → ∞,
verifying the consistency theorem for different network configurations.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def scc_bound(scc_val, n, delta):
    """Compute sqrt(SCC * log(2n)/n + log(1/delta)/n)."""
    inner = scc_val * math.log(2*n) / n + math.log(1/delta) / n
    return math.sqrt(max(0, inner))


def main():
    delta = 0.05
    n_values = np.logspace(1.5, 6, 300).astype(int)
    n_values = sorted(set(n_values))

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Plot 1: Bound vs n for different SCC values
    ax = axes[0]
    scc_configs = [
        (100, '#2196F3', 'SCC = 100 (shallow, wide)'),
        (1000, '#FF9800', 'SCC = 1,000'),
        (10000, '#FF5722', 'SCC = 10,000'),
        (80000, '#9C27B0', 'SCC = 80,000 (deep, narrow)'),
    ]

    for scc_val, color, label in scc_configs:
        bounds = [scc_bound(scc_val, n, delta) for n in n_values]
        ax.plot(n_values, bounds, color=color, linewidth=2, label=label)

    ax.set_xlabel('Sample Size n', fontsize=12)
    ax.set_ylabel('Generalization Bound', fontsize=12)
    ax.set_title('SCC Bound Convergence to Zero', fontsize=13)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Add O(1/sqrt(n)) reference line
    ref_n = np.array(n_values)
    ref = 50 / np.sqrt(ref_n)
    ax.plot(ref_n, ref, 'k--', alpha=0.3, linewidth=1, label='O(1/√n)')
    ax.legend(fontsize=9)

    # Plot 2: Bound² × n (should converge to SCC × ln(2))
    ax = axes[1]
    for scc_val, color, label in scc_configs:
        convergence = [scc_bound(scc_val, n, delta)**2 * n for n in n_values]
        ax.plot(n_values, convergence, color=color, linewidth=2, label=label)
        # Reference line
        ax.axhline(y=scc_val * math.log(2), color=color, linestyle='--',
                   alpha=0.4, linewidth=1)

    ax.set_xlabel('Sample Size n', fontsize=12)
    ax.set_ylabel('Bound² × n', fontsize=12)
    ax.set_title('Asymptotic Rate (→ SCC × ln 2)', fontsize=13)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_convergence.png")


if __name__ == "__main__":
    main()


"""
Visualization: Double Descent in SCC Bounds

Shows how the SCC generalization bound can be non-monotone in effective rank,
demonstrating the algebraic core of the double descent phenomenon.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def spectral_compression_complexity(depth, spectral_norms, frobenius_norms, margin):
    """Compute SCC given layer-wise norms."""
    L = depth
    eff_ranks = [(f/s)**2 for s, f in zip(spectral_norms, frobenius_norms)]
    R_eff = sum(eff_ranks)
    C_spec = 1.0
    for s in spectral_norms:
        C_spec *= s
    C_spec /= margin
    return L**2 * R_eff * C_spec**2


def scc_bound(scc_val, n, delta):
    """Compute sqrt(SCC * log(2n)/n + log(1/delta)/n)."""
    inner = scc_val * math.log(2*n) / n + math.log(1/delta) / n
    return math.sqrt(max(0, inner))


def main():
    gamma = 1.0
    n = 1000
    delta = 0.05

    # Vary the Frobenius norm (controls effective rank) for different depths
    frob_values = np.linspace(1.01, 20, 200)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: SCC vs effective rank for different depths
    ax = axes[0]
    for L, color in [(1, '#2196F3'), (2, '#FF5722'), (3, '#4CAF50'), (5, '#9C27B0')]:
        sigma = 1.0  # spectral norm = 1 (orthogonal)
        sccs = []
        eff_ranks = []
        for F in frob_values:
            eff_ranks.append(L * (F/sigma)**2)
            scc_val = spectral_compression_complexity(
                L, [sigma]*L, [F]*L, gamma)
            sccs.append(scc_val)
        ax.plot(eff_ranks, sccs, color=color, linewidth=2, label=f'L={L}')

    ax.set_xlabel('Total Effective Rank', fontsize=12)
    ax.set_ylabel('SCC', fontsize=12)
    ax.set_title('SCC vs Effective Rank\n(σ=1 per layer)', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Plot 2: Double descent witness - varying spectral norm with fixed rank
    ax = axes[1]
    sigma_values = np.linspace(0.5, 5, 200)
    for L, color in [(1, '#2196F3'), (2, '#FF5722'), (3, '#4CAF50')]:
        F = 10.0
        bounds = []
        for sigma in sigma_values:
            scc_val = spectral_compression_complexity(
                L, [sigma]*L, [F]*L, gamma)
            bounds.append(scc_bound(scc_val, n, delta))
        ax.plot(sigma_values, bounds, color=color, linewidth=2, label=f'L={L}')

    ax.set_xlabel('Spectral Norm per Layer', fontsize=12)
    ax.set_ylabel('Generalization Bound', fontsize=12)
    ax.set_title(f'Bound vs Spectral Norm\n(F=10, n={n})', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 3: The actual double descent shape
    ax = axes[2]
    # Simulate: as width increases, effective rank increases but spectral norm decreases
    widths = np.logspace(0.5, 3, 200)
    for L, color in [(2, '#FF5722'), (3, '#4CAF50')]:
        bounds = []
        eff_ranks_plot = []
        for w in widths:
            # Model: sigma ~ 1 + 1/sqrt(w), F ~ sqrt(w)
            sigma = 1 + 1/math.sqrt(w)
            F = math.sqrt(w)
            if F < sigma:
                F = sigma + 0.01
            scc_val = spectral_compression_complexity(
                L, [sigma]*L, [F]*L, gamma)
            bounds.append(scc_bound(scc_val, n, delta))
            eff_ranks_plot.append(L * (F/sigma)**2)
        ax.plot(eff_ranks_plot, bounds, color=color, linewidth=2, label=f'L={L}')

    ax.set_xlabel('Total Effective Rank', fontsize=12)
    ax.set_ylabel('Generalization Bound', fontsize=12)
    ax.set_title('Double Descent Shape\n(σ→1 as width→∞)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_double_descent.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_double_descent.png")


if __name__ == "__main__":
    main()


"""
Visualization: Spectral Complexity Landscape

Shows how depth and spectral norm interact to determine the
generalization bound, illustrating the depth-norm tradeoff.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def scc_value(depth, sigma, frob, margin):
    """Compute SCC for a homogeneous network."""
    L = depth
    R_eff = L * (frob / sigma) ** 2
    C_spec = sigma ** L / margin
    return L ** 2 * R_eff * C_spec ** 2


def scc_bound(scc_val, n, delta):
    inner = scc_val * math.log(2 * n) / n + math.log(1 / delta) / n
    return math.sqrt(max(0, inner))


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    n, delta, frob, gamma = 5000, 0.05, 10.0, 1.0

    # Plot 1: Heatmap of SCC in (depth, sigma) space
    ax = axes[0]
    depths = np.arange(1, 21)
    sigmas = np.linspace(0.5, 3.0, 100)
    Z = np.zeros((len(sigmas), len(depths)))
    for i, s in enumerate(sigmas):
        for j, L in enumerate(depths):
            Z[i, j] = math.log10(max(1e-10, scc_value(L, s, frob, gamma)))

    im = ax.pcolormesh(depths, sigmas, Z, cmap='RdYlBu_r', shading='auto')
    plt.colorbar(im, ax=ax, label='log₁₀(SCC)')
    ax.set_xlabel('Depth L', fontsize=12)
    ax.set_ylabel('Spectral Norm σ', fontsize=12)
    ax.set_title('SCC Landscape\n(F=10, γ=1)', fontsize=13)

    # Mark the σ=1 line (orthogonal)
    ax.axhline(y=1.0, color='white', linestyle='--', linewidth=1.5, alpha=0.8)
    ax.text(15, 1.05, 'σ=1 (orthogonal)', color='white', fontsize=9)

    # Plot 2: Bound vs depth for different spectral norms
    ax = axes[1]
    depths_fine = np.arange(1, 31)
    for sigma, color, ls in [(0.8, '#2196F3', '-'), (1.0, '#4CAF50', '-'),
                               (1.2, '#FF9800', '-'), (1.5, '#FF5722', '-'),
                               (2.0, '#9C27B0', '-')]:
        bounds = []
        for L in depths_fine:
            scc = scc_value(L, sigma, frob, gamma)
            bounds.append(scc_bound(scc, n, delta))
        ax.plot(depths_fine, bounds, color=color, linewidth=2,
                linestyle=ls, label=f'σ={sigma}')

    ax.set_xlabel('Depth L', fontsize=12)
    ax.set_ylabel('Generalization Bound', fontsize=12)
    ax.set_title(f'Bound vs Depth\n(n={n}, δ={delta})', fontsize=13)
    ax.set_yscale('log')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Plot 3: Effective rank contribution
    ax = axes[2]
    frob_values = np.linspace(1.01, 30, 200)
    for L, color in [(1, '#2196F3'), (2, '#FF5722'), (5, '#4CAF50'), (10, '#9C27B0')]:
        sigma = 1.0
        bounds = []
        eff_ranks = []
        for F in frob_values:
            eff_ranks.append(L * (F/sigma)**2)
            scc = scc_value(L, sigma, F, gamma)
            bounds.append(scc_bound(scc, n, delta))
        ax.plot(eff_ranks, bounds, color=color, linewidth=2, label=f'L={L}')

    ax.set_xlabel('Total Effective Rank', fontsize=12)
    ax.set_ylabel('Generalization Bound', fontsize=12)
    ax.set_title('Bound vs Effective Rank\n(σ=1 per layer)', fontsize=13)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_spectral_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_spectral_landscape.png")


if __name__ == "__main__":
    main()
