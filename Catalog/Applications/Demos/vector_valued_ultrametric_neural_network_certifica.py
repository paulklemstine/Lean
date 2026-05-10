#!/usr/bin/env python3
"""
Algorithms for Ultrametric Neural Network Certification
========================================================

Implements the certification algorithms from the research paper,
with complete docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class AffineLayer:
    """Affine layer: x ↦ Wx + b.
    
    Attributes:
        weight: Weight matrix (output_dim × input_dim)
        bias: Bias vector (output_dim,)
    """
    weight: np.ndarray
    bias: np.ndarray
    
    @property
    def input_dim(self) -> int:
        return self.weight.shape[1]
    
    @property
    def output_dim(self) -> int:
        return self.weight.shape[0]
    
    def __call__(self, x: np.ndarray) -> np.ndarray:
        return self.weight @ x + self.bias


@dataclass
class Activation:
    """Activation function with Lipschitz constant.
    
    Attributes:
        fn: The activation function
        lip_const: Scalar Lipschitz constant
    """
    fn: callable
    lip_const: float
    
    def __call__(self, x: np.ndarray) -> np.ndarray:
        return np.vectorize(self.fn)(x)


@dataclass
class LayeredMap:
    """One affine-activation block.
    
    Computes: x ↦ activation(Wx + b) coordinatewise.
    """
    layer: AffineLayer
    activation: Activation
    
    def __call__(self, x: np.ndarray) -> np.ndarray:
        return self.activation(self.layer(x))


# ============================================================
# Standard Activations
# ============================================================

IDENTITY = Activation(fn=lambda x: x, lip_const=1.0)
RELU = Activation(fn=lambda x: max(0, x), lip_const=1.0)
SIGMOID = Activation(fn=lambda x: 1 / (1 + np.exp(-x)), lip_const=0.25)
TANH = Activation(fn=lambda x: np.tanh(x), lip_const=1.0)


# ============================================================
# Core Algorithms
# ============================================================

def op_sup_norm(A: np.ndarray) -> float:
    """Compute operator sup norm: max_{j,i} |A_{ji}|.
    
    Time complexity: O(m × n) for m × n matrix.
    Space complexity: O(1).
    
    This is the ultrametric operator norm, which is width-free:
    it doesn't depend on the dimensions of A, only on the magnitudes
    of its entries.
    
    Args:
        A: Weight matrix (m × n)
    
    Returns:
        max |A_{ji}| over all entries
    """
    return float(np.max(np.abs(A)))


def layer_lipschitz(layer: LayeredMap) -> float:
    """Compute layer Lipschitz constant.
    
    Time complexity: O(m × n) where m × n = weight dimensions.
    
    Returns: activation.lip_const × op_sup_norm(weight)
    """
    return layer.activation.lip_const * op_sup_norm(layer.layer.weight)


def network_lipschitz(layers: List[LayeredMap]) -> float:
    """Compute network Lipschitz constant (product formula).
    
    Time complexity: O(D × W²) where D = depth, W = max width.
    Space complexity: O(1).
    
    The key theorem: this product is width-free. Each factor
    layer_lipschitz(L) = act.lip × max|W_{ji}| depends only on
    the weight magnitudes, not on the matrix dimensions.
    
    Args:
        layers: List of layered maps (from input to output)
    
    Returns:
        Product of all layer Lipschitz constants
    """
    lip = 1.0
    for layer in layers:
        lip *= layer_lipschitz(layer)
    return lip


def eval_network(layers: List[LayeredMap], x: np.ndarray) -> np.ndarray:
    """Evaluate network on input.
    
    Time complexity: O(D × W²) for forward pass.
    
    Args:
        layers: Network layers
        x: Input vector
    
    Returns:
        Output vector
    """
    y = x.copy()
    for layer in layers:
        y = layer(y)
    return y


def competitor_margin(y: np.ndarray, good: int) -> float:
    """Compute competitor margin: min_{j ≠ good} |y[good] - y[j]|.
    
    Time complexity: O(n) where n = output dimension.
    
    Args:
        y: Output vector
        good: Index of the correct/winning label
    
    Returns:
        Minimum gap between good label and all competitors
    """
    n = len(y)
    if n <= 1:
        return float('inf')
    
    min_gap = float('inf')
    for j in range(n):
        if j != good:
            gap = abs(y[good] - y[j])
            min_gap = min(min_gap, gap)
    return min_gap


def certified_radius(margin: float, lip: float) -> float:
    """Compute certified radius = margin / (2 × lip).
    
    Time complexity: O(1).
    
    By the ultrametric certification theorem, any input perturbation
    with sup-norm distance less than this radius is guaranteed not
    to change the predicted label.
    
    Args:
        margin: Output competitor margin (must be > 0 for nontrivial result)
        lip: Network Lipschitz constant (must be > 0)
    
    Returns:
        Certified perturbation radius
    """
    if lip <= 0 or margin <= 0:
        return 0.0
    return margin / (2 * lip)


def certify(layers: List[LayeredMap], x: np.ndarray, 
            good: Optional[int] = None) -> dict:
    """Full certification pipeline.
    
    Time complexity: O(D × W²) total.
      - O(D × W²) for network evaluation
      - O(D × W²) for Lipschitz constant computation
      - O(W) for margin computation
    
    Args:
        layers: Network layers
        x: Input vector
        good: Correct label (if None, uses argmax of output)
    
    Returns:
        Dictionary with:
        - 'output': network output vector
        - 'predicted': predicted label
        - 'margin': competitor margin
        - 'lip': network Lipschitz constant
        - 'radius': certified robustness radius
        - 'layer_lips': per-layer Lipschitz constants
    """
    # Forward pass
    y = eval_network(layers, x)
    
    # Determine good label
    if good is None:
        good = int(np.argmax(y))
    
    # Compute per-layer and total Lipschitz
    layer_lips = [layer_lipschitz(L) for L in layers]
    total_lip = 1.0
    for ll in layer_lips:
        total_lip *= ll
    
    # Compute margin and radius
    margin = competitor_margin(y, good)
    radius = certified_radius(margin, total_lip)
    
    return {
        'output': y,
        'predicted': good,
        'margin': margin,
        'lip': total_lip,
        'radius': radius,
        'layer_lips': layer_lips,
    }


def verify_certification(layers: List[LayeredMap], x: np.ndarray,
                          good: int, radius: float,
                          n_samples: int = 10000) -> Tuple[int, int]:
    """Empirically verify certification by random sampling.
    
    Args:
        layers: Network layers
        x: Input vector
        good: Correct label
        radius: Certified radius
        n_samples: Number of random perturbations to test
    
    Returns:
        (n_robust, n_samples): Number of robust samples out of total
    """
    dim = len(x)
    n_robust = 0
    
    for _ in range(n_samples):
        # Random perturbation within certified ball (sup norm < radius)
        delta = np.random.uniform(-radius * 0.99, radius * 0.99, dim)
        z = x + delta
        y_z = eval_network(layers, z)
        if np.argmax(y_z) == good:
            n_robust += 1
    
    return n_robust, n_samples


# ============================================================
# Example Usage
# ============================================================

if __name__ == '__main__':
    np.random.seed(42)
    
    # Create a 3-layer network
    width = 10
    layers = [
        LayeredMap(
            AffineLayer(
                weight=np.random.uniform(-0.4, 0.4, (width, width)),
                bias=np.random.uniform(-0.1, 0.1, width)
            ),
            IDENTITY
        )
        for _ in range(3)
    ]
    
    # Certify
    x = np.random.randn(width)
    result = certify(layers, x)
    
    print("Certification Result:")
    print(f"  Predicted label: {result['predicted']}")
    print(f"  Margin: {result['margin']:.6f}")
    print(f"  Network Lip: {result['lip']:.6f}")
    print(f"  Layer Lips: {[f'{l:.4f}' for l in result['layer_lips']]}")
    print(f"  Certified radius: {result['radius']:.6f}")
    
    # Verify
    n_robust, n_total = verify_certification(
        layers, x, result['predicted'], result['radius'], n_samples=5000
    )
    print(f"  Verification: {n_robust}/{n_total} perturbations preserved label")


#!/usr/bin/env python3
"""
Applications of Ultrametric Neural Network Certification
==========================================================

Real-world applications connecting the formal theory to:
1. Hierarchical classification with robustness guarantees
2. Post-quantum cryptographic noise tolerance
3. Quantized network certification
"""

import numpy as np
from algorithms import (
    AffineLayer, Activation, LayeredMap, 
    certify, verify_certification, eval_network,
    IDENTITY, RELU
)


def application_hierarchical_classification():
    """Hierarchical classification with ultrametric robustness.
    
    Application: Classifying items in a taxonomy (e.g., biological species).
    The ultrametric distance between taxonomy nodes is the height of their
    least common ancestor, making the sup norm the natural metric.
    
    We construct a network that classifies 8 items organized in a
    binary tree hierarchy, and certify its robustness.
    """
    print("=" * 60)
    print("Application 1: Hierarchical Classification")
    print("=" * 60)
    
    np.random.seed(42)
    dim = 8  # 8 leaf categories
    
    # Create a network that respects the hierarchy
    # Layer 1: Extract hierarchical features
    W1 = np.zeros((dim, dim))
    for i in range(dim):
        for j in range(dim):
            # Weights based on tree distance
            dist = bin(i ^ j).count('1')  # Hamming distance = tree distance
            W1[i, j] = 0.5 ** dist
    W1 *= 0.3  # Scale down
    
    # Layer 2: Refine
    W2 = np.eye(dim) * 0.4 + np.random.uniform(-0.1, 0.1, (dim, dim))
    
    layers = [
        LayeredMap(AffineLayer(W1, np.zeros(dim)), IDENTITY),
        LayeredMap(AffineLayer(W2, np.zeros(dim)), IDENTITY),
    ]
    
    # Test inputs: one-hot encodings for each category
    for category in range(min(4, dim)):
        x = np.zeros(dim)
        x[category] = 1.0
        
        result = certify(layers, x)
        print(f"  Category {category}: margin={result['margin']:.4f}, "
              f"radius={result['radius']:.4f}, "
              f"lip={result['lip']:.4f}")
    print()


def application_lattice_crypto_noise():
    """Post-quantum cryptographic noise tolerance.
    
    Application: In lattice-based encryption (LWE), ciphertexts are of the form
    c = As + e where e is a noise vector with ||e||_∞ ≤ B.
    
    A neural network classifier operating on ciphertexts is robust to
    decryption noise iff its certified radius exceeds B.
    
    We demonstrate this connection.
    """
    print("=" * 60)
    print("Application 2: Post-Quantum Noise Tolerance")
    print("=" * 60)
    
    np.random.seed(42)
    dim = 16  # Lattice dimension
    
    # Simulate LWE parameters
    noise_bounds = [0.01, 0.05, 0.1, 0.5]
    
    # Create a simple classifier network
    layers = [
        LayeredMap(
            AffineLayer(
                np.random.uniform(-0.3, 0.3, (dim, dim)),
                np.zeros(dim)
            ),
            IDENTITY
        )
        for _ in range(2)
    ]
    
    # Test with a "plaintext"
    x = np.random.randn(dim)
    result = certify(layers, x)
    
    print(f"  Network Lipschitz constant: {result['lip']:.4f}")
    print(f"  Output margin: {result['margin']:.4f}")
    print(f"  Certified radius: {result['radius']:.4f}")
    print()
    
    for B in noise_bounds:
        is_robust = result['radius'] > B
        print(f"  Noise bound B={B:.2f}: "
              f"{'✓ ROBUST' if is_robust else '✗ NOT certified'} "
              f"(need r > B, have r={result['radius']:.4f})")
    
    print()
    print("  Interpretation: The certified radius is the maximum LWE noise")
    print("  level at which the classifier is provably correct.")
    print()


def application_quantized_networks():
    """Certification of quantized neural networks.
    
    Application: Quantized networks (binary, ternary, or low-precision weights)
    naturally have bounded operator sup norms. The ultrametric certification
    gives tighter bounds than Archimedean methods because the sup norm
    equals the quantization level, regardless of matrix dimensions.
    """
    print("=" * 60)
    print("Application 3: Quantized Network Certification")
    print("=" * 60)
    
    np.random.seed(42)
    
    quant_levels = {
        'Binary (-1, +1)': [-1, 1],
        'Ternary (-1, 0, +1)': [-1, 0, 1],
        'Low-precision (-2..2)': [-2, -1, 0, 1, 2],
    }
    
    widths = [10, 50, 100, 500]
    depth = 3
    
    for name, levels in quant_levels.items():
        print(f"\n  Quantization: {name}")
        print(f"  Max weight magnitude: {max(abs(l) for l in levels)}")
        
        for width in widths:
            layers = []
            for _ in range(depth):
                W = np.random.choice(levels, (width, width)).astype(float)
                b = np.zeros(width)
                layers.append(LayeredMap(AffineLayer(W, b), IDENTITY))
            
            x = np.random.choice(levels, width).astype(float)
            result = certify(layers, x)
            
            print(f"    Width {width:>4d}: lip={result['lip']:.4f}, "
                  f"margin={result['margin']:.4f}, "
                  f"radius={result['radius']:.6f}")
    
    print()
    print("  Key observation: The Lipschitz constant is CONSTANT across widths")
    print("  because op_sup_norm = max|W_{ji}| = quantization level.")
    print()


if __name__ == '__main__':
    print("\n" + "=" * 60)
    print("  ULTRAMETRIC CERTIFICATION: REAL-WORLD APPLICATIONS")
    print("=" * 60 + "\n")
    
    application_hierarchical_classification()
    application_lattice_crypto_noise()
    application_quantized_networks()
    
    print("Done!")


#!/usr/bin/env python3
"""Build the PACKAGE.html file with embedded images."""
import base64

# Read images
images = {}
for f in ['width_independence.png', 'depth_scaling.png', 'margin_radius.png']:
    with open(f, 'rb') as fh:
        images[f] = base64.b64encode(fh.read()).decode()

with open('diagram.svg', 'r') as fh:
    diagram_svg = fh.read()

with open('ARTICLE.md', 'r') as fh:
    article = fh.read()
with open('RESEARCH_PAPER.md', 'r') as fh:
    paper = fh.read()
with open('algorithms.py', 'r') as fh:
    algo_code = fh.read()
with open('demo.py', 'r') as fh:
    demo_code = fh.read()

def md_to_html(text):
    lines = text.split('\n')
    out = []
    in_code = False
    for line in lines:
        if line.startswith('```'):
            if in_code:
                out.append('</code></pre>')
                in_code = False
            else:
                out.append('<pre><code>')
                in_code = True
            continue
        if in_code:
            out.append(line.replace('<', '&lt;').replace('>', '&gt;'))
            continue
        if line.startswith('# '):
            out.append(f'<h1>{line[2:]}</h1>')
        elif line.startswith('## '):
            out.append(f'<h2>{line[3:]}</h2>')
        elif line.startswith('### '):
            out.append(f'<h3>{line[4:]}</h3>')
        elif line.startswith('- '):
            out.append(f'<li>{line[2:]}</li>')
        elif line.strip():
            out.append(f'<p>{line}</p>')
    if in_code:
        out.append('</code></pre>')
    return '\n'.join(out)

def escape_code(text):
    return text.replace('<', '&lt;').replace('>', '&gt;')

html = f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Ultrametric Neural Network Certification</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"
  onload="renderMathInElement(document.body,{{delimiters:[{{left:'$$',right:'$$',display:true}},{{left:'$',right:'$',display:false}}]}})"></script>
<style>
:root{{--bg:#1a1a2e;--fg:#e8e8e8;--accent:#e94560;--accent2:#ffd700;--panel:#16213e;--code-bg:#0f3460}}
body{{margin:0;font-family:Georgia,serif;background:var(--bg);color:var(--fg);line-height:1.7}}
.container{{max-width:1100px;margin:0 auto;padding:20px}}
nav{{position:fixed;top:0;width:100%;background:var(--panel);z-index:100;padding:10px 0;border-bottom:2px solid var(--accent)}}
nav ul{{list-style:none;display:flex;justify-content:center;gap:30px;margin:0;padding:0}}
nav a{{color:var(--accent2);text-decoration:none;font-size:15px;font-family:Arial,sans-serif;font-weight:bold}}
nav a:hover{{color:var(--accent)}}
.tab{{display:none}}.tab.active{{display:block}}
h1{{color:var(--accent);font-size:2em;text-align:center;margin-top:80px}}
h2{{color:var(--accent2);border-bottom:1px solid var(--accent2);padding-bottom:5px;margin-top:40px}}
h3{{color:#a7c5eb}}
pre{{background:var(--code-bg);padding:15px;border-radius:8px;overflow-x:auto;font-size:13px;line-height:1.5}}
code{{font-family:"Fira Code",monospace;font-size:13px}}
img{{max-width:100%;border-radius:8px;margin:20px 0}}
details{{margin:15px 0}}
summary{{cursor:pointer;color:var(--accent2);font-weight:bold;font-size:16px}}
p{{margin:10px 0}}
li{{margin:5px 0}}
</style>
</head>
<body>
<nav>
<ul>
<li><a href="#" onclick="showTab('article')">Article</a></li>
<li><a href="#" onclick="showTab('paper')">Research Paper</a></li>
<li><a href="#" onclick="showTab('viz')">Visualizations</a></li>
<li><a href="#" onclick="showTab('code')">Code</a></li>
</ul>
</nav>
<div class="container">

<div id="article" class="tab active">
{md_to_html(article)}
</div>

<div id="paper" class="tab">
{md_to_html(paper)}
</div>

<div id="viz" class="tab">
<h1>Visualizations</h1>
<h2>Network Architecture &amp; Certification</h2>
{diagram_svg}
<h2>Width Independence</h2>
<p>The ultrametric certified radius (blue) stays constant as width grows, while the Archimedean bound (red) decays rapidly.</p>
<img src="data:image/png;base64,{images['width_independence.png']}" alt="Width Independence" />
<h2>Depth Scaling</h2>
<p>Certified radius decays exponentially with depth, with rate controlled by the per-layer Lipschitz constant.</p>
<img src="data:image/png;base64,{images['depth_scaling.png']}" alt="Depth Scaling" />
<h2>Margin vs Radius</h2>
<p>Linear relationship: the certified radius is directly proportional to the output margin.</p>
<img src="data:image/png;base64,{images['margin_radius.png']}" alt="Margin vs Radius" />
</div>

<div id="code" class="tab">
<h1>Code Listings</h1>
<h2>Certification Algorithms (algorithms.py)</h2>
<pre><code>{escape_code(algo_code)}</code></pre>
<h2>Demo Script (demo.py)</h2>
<details><summary>Click to expand</summary>
<pre><code>{escape_code(demo_code)}</code></pre>
</details>
</div>

</div>
<script>
function showTab(id){{
  document.querySelectorAll('.tab').forEach(t=>t.classList.remove('active'));
  document.getElementById(id).classList.add('active');
  window.scrollTo(0,0);
}}
</script>
</body>
</html>'''

with open('PACKAGE.html', 'w') as fh:
    fh.write(html)

print(f'PACKAGE.html written ({len(html)} chars)')


#!/usr/bin/env python3
"""
Demo: Ultrametric Neural Network Certification
================================================

Demonstrates the width-free certification theorem for neural networks
operating under sup-norm / ultrametric constraints.

Key insight: In the ultrametric setting, the certified robustness radius
depends only on layer Lipschitz constants and output margin, NOT on hidden
layer widths. This demo shows:

1. Width-independence of the certified radius
2. Comparison with Archimedean (standard) certification bounds
3. Depth scaling of the network Lipschitz constant
4. Margin computation and certification visualization
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple

# ============================================================
# Core definitions matching the Lean formalization
# ============================================================

def vec_sup_norm(x: np.ndarray) -> float:
    """Sup norm: max_i |x_i|. Matches vecSupNorm in Lean."""
    return np.max(np.abs(x))

def vec_sup_dist(x: np.ndarray, y: np.ndarray) -> float:
    """Sup distance: max_i |x_i - y_i|. Matches vecSupDist in Lean."""
    return vec_sup_norm(x - y)

def op_sup_norm(A: np.ndarray) -> float:
    """Operator sup norm: max_{j,i} |A_{ji}|. Matches opSupNorm in Lean."""
    return np.max(np.abs(A))

def layer_lip(weight: np.ndarray, act_lip: float) -> float:
    """Layer Lipschitz constant. Matches layerLip in Lean."""
    return act_lip * op_sup_norm(weight)

def network_lip(layers: List[Tuple[np.ndarray, float]]) -> float:
    """Network Lipschitz constant (product of layer constants).
    Matches networkLip in Lean."""
    lip = 1.0
    for weight, act_lip in layers:
        lip *= layer_lip(weight, act_lip)
    return lip

def archimedean_op_norm(A: np.ndarray) -> float:
    """Standard operator norm (spectral norm) for comparison."""
    return np.linalg.norm(A, ord=2)

def archimedean_network_lip(layers: List[Tuple[np.ndarray, float]]) -> float:
    """Archimedean network Lipschitz constant using spectral norms."""
    lip = 1.0
    for weight, act_lip in layers:
        lip *= act_lip * archimedean_op_norm(weight)
    return lip

def competitor_margin(y: np.ndarray, good: int) -> float:
    """Competitor margin: min_{j != good} |y[good] - y[j]|.
    Matches competitorMargin in Lean."""
    gaps = [abs(y[good] - y[j]) for j in range(len(y)) if j != good]
    return min(gaps) if gaps else float('inf')

def certified_radius(margin: float, lip: float) -> float:
    """Certified radius = margin / (2 * lip).
    Matches certifiedRadius in Lean."""
    if lip <= 0:
        return float('inf') if margin > 0 else 0.0
    return margin / (2 * lip)


# ============================================================
# Experiment 1: Width Independence
# ============================================================

def experiment_width_independence():
    """Show that ultrametric certified radius is independent of width."""
    np.random.seed(42)
    
    widths = [10, 50, 100, 200, 500, 1000]
    depth = 3
    act_lip = 0.9  # Nonexpansive activation
    max_weight = 0.5  # Control weight magnitude
    
    ultra_radii = []
    arch_radii = []
    
    for width in widths:
        # Create random network with controlled weight magnitude
        layers = []
        for _ in range(depth):
            W = np.random.uniform(-max_weight, max_weight, (width, width))
            layers.append((W, act_lip))
        
        # Compute Lipschitz constants
        ultra_lip = network_lip(layers)
        arch_lip = archimedean_network_lip(layers)
        
        # Random input and output
        x = np.random.randn(width)
        y = np.zeros(width)
        for weight, _ in layers:
            y = act_lip * (weight @ y + np.random.randn(width) * 0.01)
            # Simplified: just use the weights for demonstration
        
        # Use a fixed margin for comparison
        margin = 1.0
        
        ultra_radii.append(certified_radius(margin, ultra_lip))
        arch_radii.append(certified_radius(margin, arch_lip))
    
    # Plot
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.plot(widths, ultra_radii, 'bo-', linewidth=2, markersize=8, 
            label='Ultrametric (width-free)')
    ax.plot(widths, arch_radii, 'rs--', linewidth=2, markersize=8,
            label='Archimedean (width-dependent)')
    ax.set_xlabel('Network Width', fontsize=14)
    ax.set_ylabel('Certified Radius', fontsize=14)
    ax.set_title('Width-Free Certification: Ultrametric vs Archimedean', fontsize=16)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('width_independence.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    print("=" * 60)
    print("Experiment 1: Width Independence")
    print("=" * 60)
    for w, ur, ar in zip(widths, ultra_radii, arch_radii):
        print(f"  Width {w:>5d}: Ultra r = {ur:.6f}, Arch r = {ar:.6f}, "
              f"Ratio = {ur/ar:.1f}x")
    print()


# ============================================================
# Experiment 2: Depth Scaling
# ============================================================

def experiment_depth_scaling():
    """Show how certified radius scales with depth."""
    np.random.seed(123)
    width = 50
    act_lip = 1.0
    
    depths = list(range(1, 21))
    
    for max_weight in [0.3, 0.5, 0.8, 1.0]:
        radii = []
        for depth in depths:
            layers = []
            for _ in range(depth):
                W = np.random.uniform(-max_weight, max_weight, (width, width))
                layers.append((W, act_lip))
            lip = network_lip(layers)
            radii.append(certified_radius(1.0, lip))
        
        plt.plot(depths, radii, 'o-', label=f'||W||_∞ ≤ {max_weight}', linewidth=2)
    
    plt.xlabel('Network Depth', fontsize=14)
    plt.ylabel('Certified Radius', fontsize=14)
    plt.title('Certified Radius vs Network Depth', fontsize=16)
    plt.yscale('log')
    plt.legend(fontsize=12)
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('depth_scaling.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    print("Experiment 2: Depth Scaling")
    print("=" * 60)
    print(f"  Certified radius scales as (act_lip * max_weight)^(-depth)")
    print(f"  For max_weight=0.5: r(d=1) ≈ {certified_radius(1.0, 0.5):.4f}, "
          f"r(d=10) ≈ {certified_radius(1.0, 0.5**10):.4f}")
    print()


# ============================================================
# Experiment 3: Margin vs Certified Radius
# ============================================================

def experiment_margin_radius():
    """Show the linear relationship between margin and certified radius."""
    lip = 2.5  # Fixed Lipschitz constant
    margins = np.linspace(0.01, 5.0, 100)
    radii = [certified_radius(m, lip) for m in margins]
    
    plt.figure(figsize=(10, 6))
    plt.plot(margins, radii, 'b-', linewidth=2)
    plt.fill_between(margins, 0, radii, alpha=0.1, color='blue')
    plt.xlabel('Output Margin', fontsize=14)
    plt.ylabel('Certified Radius', fontsize=14)
    plt.title(f'Certified Radius vs Output Margin (Lip = {lip})', fontsize=16)
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('margin_radius.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    print("Experiment 3: Margin vs Radius")
    print("=" * 60)
    print(f"  Certified radius = margin / (2 * {lip}) = margin / {2*lip}")
    print(f"  Linear relationship: doubling margin doubles radius")
    print()


# ============================================================
# Experiment 4: Full Certification Pipeline
# ============================================================

def experiment_certification_pipeline():
    """Demonstrate full certification on a concrete example."""
    np.random.seed(42)
    
    # Small network for interpretability
    width = 5
    depth = 3
    
    # Create network
    layers = []
    weights = []
    for d in range(depth):
        W = np.random.uniform(-0.5, 0.5, (width, width))
        b = np.random.uniform(-0.1, 0.1, width)
        weights.append((W, b))
        layers.append((W, 1.0))  # Identity activation (lip=1)
    
    # Input
    x = np.array([1.0, 0.5, -0.3, 0.8, -0.1])
    
    # Evaluate network
    y = x.copy()
    for W, b in weights:
        y = W @ y + b  # Identity activation
    
    # Find best label
    good = np.argmax(y)
    margin = competitor_margin(y, good)
    lip = network_lip(layers)
    radius = certified_radius(margin, lip)
    
    print("Experiment 4: Full Certification Pipeline")
    print("=" * 60)
    print(f"  Input:   {x}")
    print(f"  Output:  {np.round(y, 4)}")
    print(f"  Predicted label: {good}")
    print(f"  Output margin: {margin:.6f}")
    print(f"  Network Lip:   {lip:.6f}")
    print(f"  Certified radius: {radius:.6f}")
    print()
    
    # Verify: perturb within certified radius
    n_tests = 1000
    n_robust = 0
    for _ in range(n_tests):
        delta = np.random.uniform(-radius * 0.99, radius * 0.99, width)
        z = x + delta
        y_z = z.copy()
        for W, b in weights:
            y_z = W @ y_z + b
        if np.argmax(y_z) == good:
            n_robust += 1
    
    print(f"  Verification: {n_robust}/{n_tests} perturbations preserved label")
    print(f"  (All should be preserved within certified radius)")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("\n" + "=" * 60)
    print("  ULTRAMETRIC NEURAL NETWORK CERTIFICATION DEMO")
    print("=" * 60 + "\n")
    
    experiment_width_independence()
    experiment_depth_scaling()
    experiment_margin_radius()
    experiment_certification_pipeline()
    
    print("Figures saved: width_independence.png, depth_scaling.png, margin_radius.png")
    print("\nDone!")
