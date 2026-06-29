"""
Applications of Higher-Order Shadow Tower Theory
=================================================

Demonstrates real-world applications of shadow tower analysis
to polynomial optimization, sparse interpolation complexity,
and jet bundle dimension counting.
"""
from math import comb, log2, factorial
from typing import Optional


def sparse_polynomial_derivative_complexity(
    d: int, m: int, sparsity: int
) -> dict:
    """Analyze the cost of computing all partial derivatives of a sparse polynomial.
    
    For a polynomial with `sparsity` terms in d variables of degree m,
    the shadow tower provides lower bounds on the computational complexity
    of producing all k-th order derivative supports.
    
    Application: Sparse interpolation, symbolic differentiation engines,
    automatic differentiation complexity analysis.
    
    Args:
        d: Number of variables.
        m: Maximum degree.
        sparsity: Number of nonzero terms.
    
    Returns:
        Analysis dictionary with bounds for each derivative order.
    """
    results = []
    for k in range(1, min(m, d) + 1):
        # Shadow of a generic sparse polynomial
        # Upper bound on shadow cardinality
        max_shadow = min(sparsity * comb(d + k - 1, k), comb(m - k + d - 1, d - 1))
        channels = comb(d + k - 1, k)  # Number of distinct k-th derivatives
        lb = max_shadow / channels if channels > 0 else 0
        
        results.append({
            'order': k,
            'max_shadow_card': max_shadow,
            'derivative_channels': channels,
            'circuit_lower_bound': lb,
        })
    
    return {
        'd': d, 'm': m, 'sparsity': sparsity,
        'derivative_analysis': results,
    }


def automatic_differentiation_cost(d: int, m: int, k: int) -> dict:
    """Estimate the cost of k-th order automatic differentiation.
    
    In reverse-mode AD, the cost of computing k-th order derivatives
    is related to the jet dimension and shadow structure.
    
    The shadow tower provides structural lower bounds:
    any AD implementation must produce at least |Sh_k(S)| distinct
    derivative terms, requiring circuit size ≥ |Sh_k(S)| / d^k.
    
    Application: Deep learning higher-order optimization, Hessian-free methods.
    
    Args:
        d: Number of parameters (variables).
        m: Polynomial degree of the objective.
        k: Derivative order.
    
    Returns:
        Cost analysis dictionary.
    """
    shadow_card = comb(m - k + d - 1, d - 1) if k <= m else 0
    jet_dim = comb(d + k - 1, k)
    channels = d ** k
    
    return {
        'd': d, 'm': m, 'k': k,
        'shadow_cardinality': shadow_card,
        'jet_dimension': jet_dim,
        'output_channels': channels,
        'min_circuit_size': shadow_card / channels if channels > 0 else 0,
        'total_derivative_terms': shadow_card * jet_dim,
        'naive_cost': shadow_card * channels,
        'structured_cost': shadow_card * jet_dim,
        'savings_factor': channels / jet_dim if jet_dim > 0 else 1,
    }


def newton_polytope_erosion_analysis(vertices: list[tuple[int, ...]]) -> dict:
    """Analyze Newton polytope erosion through the shadow tower.
    
    The shadow tower of a Newton polytope corresponds to discrete
    Minkowski differences with the standard simplex. This connects
    algebraic circuit complexity to discrete convex geometry.
    
    Application: Toric geometry, algebraic optimization, Newton polytope methods.
    
    Args:
        vertices: Vertices of the Newton polytope (exponent vectors).
    
    Returns:
        Erosion analysis with cardinalities at each level.
    """
    if not vertices:
        return {'levels': []}
    
    d = len(vertices[0])
    
    # Generate all lattice points in the polytope (convex hull)
    # For simplicity, use the simplex case
    support = set()
    for v in vertices:
        support.add(v)
    
    # Compute shadow tower
    levels = []
    current = support
    k = 0
    while current:
        levels.append({
            'k': k,
            'cardinality': len(current),
            'sample': list(current)[:3],
        })
        # Compute first shadow
        shadow = set()
        for alpha in current:
            for i in range(d):
                if alpha[i] > 0:
                    beta = list(alpha)
                    beta[i] -= 1
                    shadow.add(tuple(beta))
        current = shadow
        k += 1
    
    return {
        'dimension': d,
        'initial_size': len(support),
        'tower_depth': len(levels),
        'levels': levels,
    }


def taylor_complexity_bounds(d: int, m: int) -> dict:
    """Compute Taylor expansion complexity bounds via the shadow tower.
    
    For a degree-m polynomial in d variables, the k-th Taylor coefficient
    tensor requires computing |Sh_k| support terms. The shadow tower
    gives a structured view of how Taylor expansion cost scales with order.
    
    Application: Numerical analysis, power series arithmetic, interval arithmetic.
    
    Args:
        d: Number of variables.
        m: Polynomial degree.
    
    Returns:
        Complexity bounds for each Taylor order.
    """
    total_terms = 0
    results = []
    
    for k in range(m + 1):
        shadow_card = comb(m - k + d - 1, d - 1) if k <= m else 0
        jet_dim = comb(d + k - 1, k)
        terms = shadow_card * jet_dim
        total_terms += terms
        
        results.append({
            'order': k,
            'support_size': shadow_card,
            'tensor_dimension': jet_dim,
            'total_terms': terms,
            'cumulative_terms': total_terms,
        })
    
    return {
        'd': d, 'm': m,
        'total_taylor_terms': total_terms,
        'original_terms': comb(m + d - 1, d - 1),
        'expansion_factor': total_terms / comb(m + d - 1, d - 1) if comb(m + d - 1, d - 1) > 0 else 0,
        'orders': results,
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF SHADOW TOWER THEORY")
    print("=" * 70)
    
    # 1. Sparse polynomial derivative complexity
    print("\n--- Sparse Polynomial Derivative Complexity ---")
    analysis = sparse_polynomial_derivative_complexity(d=5, m=10, sparsity=50)
    print(f"Polynomial: {analysis['d']} vars, degree {analysis['m']}, "
          f"{analysis['sparsity']} terms")
    for item in analysis['derivative_analysis']:
        print(f"  Order {item['order']}: shadow ≤ {item['max_shadow_card']}, "
              f"channels = {item['derivative_channels']}, "
              f"circuit ≥ {item['circuit_lower_bound']:.1f}")
    
    # 2. Automatic differentiation cost
    print("\n--- Automatic Differentiation Cost Analysis ---")
    for d in [10, 50, 100]:
        ad = automatic_differentiation_cost(d=d, m=4, k=2)
        print(f"  d={d}: shadow={ad['shadow_cardinality']}, "
              f"jet_dim={ad['jet_dimension']}, "
              f"savings={ad['savings_factor']:.1f}x over naive")
    
    # 3. Taylor complexity
    print("\n--- Taylor Expansion Complexity ---")
    tc = taylor_complexity_bounds(d=3, m=8)
    print(f"Polynomial: {tc['d']} vars, degree {tc['m']}")
    print(f"Original terms: {tc['original_terms']}")
    print(f"Full Taylor expansion: {tc['total_taylor_terms']} terms")
    print(f"Expansion factor: {tc['expansion_factor']:.1f}x")
    for order in tc['orders'][:5]:
        print(f"  Order {order['order']}: {order['support_size']} × "
              f"{order['tensor_dimension']} = {order['total_terms']} terms")
    
    print("\n" + "=" * 70)
    print("All applications demonstrated.")


"""
Higher-Order Shadow Towers: Demonstration
==========================================
Demonstrates the k-th shadow tower theory on simplex supports,
verifying key identities and computing circuit lower bounds.
"""
from math import comb, factorial
from itertools import combinations_with_replacement


def simplex_support(d: int, m: int) -> list[tuple[int, ...]]:
    """Generate all exponent vectors in N^d summing to exactly m.
    
    These are the monomials of a generic homogeneous polynomial of degree m
    in d variables. Equivalent to T(d, m) in the formal theory.
    
    >>> len(simplex_support(3, 2))
    6
    """
    if d == 0:
        return [()] if m == 0 else []
    if d == 1:
        return [(m,)]
    result = []
    for first in range(m + 1):
        for rest in simplex_support(d - 1, m - first):
            result.append((first,) + rest)
    return result


def first_shadow(support: set[tuple[int, ...]]) -> set[tuple[int, ...]]:
    """Compute the first shadow Sh_1(S).
    
    For each alpha in S and each coordinate i, subtract e_i from alpha
    (if alpha_i > 0). Collects all such results.
    
    >>> S = set(simplex_support(3, 3))
    >>> Sh1 = first_shadow(S)
    >>> len(Sh1) == len(simplex_support(3, 2))
    True
    """
    shadow = set()
    for alpha in support:
        d = len(alpha)
        for i in range(d):
            if alpha[i] > 0:
                beta = list(alpha)
                beta[i] -= 1
                shadow.add(tuple(beta))
    return shadow


def kth_shadow(k: int, support: set[tuple[int, ...]]) -> set[tuple[int, ...]]:
    """Compute the k-th shadow Sh_k(S) by iterating the first shadow k times.
    
    >>> S = set(simplex_support(3, 5))
    >>> kth_shadow(3, S) == set(simplex_support(3, 2))
    True
    """
    current = support
    for _ in range(k):
        current = first_shadow(current)
    return current


def simplex_card(d: int, m: int) -> int:
    """Cardinality of simplex support T(d, m) = C(m + d - 1, d - 1)."""
    if d == 0:
        return 1 if m == 0 else 0
    return comb(m + d - 1, d - 1)


def jet_dimension(d: int, k: int) -> int:
    """Jet bundle dimension: C(d + k - 1, k)."""
    return comb(d + k - 1, k)


def circuit_lower_bound(d: int, m: int, k: int) -> float:
    """Lower bound on circuit size for computing k-th derivatives.
    
    Returns C(m - k + d - 1, d - 1) / d^k.
    """
    shadow_card = simplex_card(d, m - k)
    channels = d ** k
    return shadow_card / channels if channels > 0 else float('inf')


def shadow_ratio(d: int, m: int, k: int) -> float:
    """Shadow ratio r_k = |Sh_k(S)| / |S|."""
    s0 = simplex_card(d, m)
    sk = simplex_card(d, m - k)
    return sk / s0 if s0 > 0 else 0.0


# ============================================================
# Main demonstration
# ============================================================
if __name__ == "__main__":
    print("=" * 70)
    print("HIGHER-ORDER SHADOW TOWER DEMONSTRATION")
    print("=" * 70)
    
    # 1. Verify the Tower Simplex Theorem
    print("\n--- Tower Simplex Theorem Verification ---")
    print("Sh_k(T(d, m)) = T(d, m - k)")
    print()
    for d in [2, 3, 4]:
        for m in [4, 6, 8]:
            S = set(simplex_support(d, m))
            for k in range(m + 1):
                Shk = kth_shadow(k, S)
                Tmk = set(simplex_support(d, m - k))
                assert Shk == Tmk, f"FAILED: d={d}, m={m}, k={k}"
            print(f"  d={d}, m={m}: Verified for k = 0..{m} ✓")
    
    # 2. Cardinality via binomial coefficients
    print("\n--- Simplex Support Cardinalities ---")
    print(f"  {'d':>3} {'m':>3} {'|T(d,m)|':>10} {'C(m+d-1,d-1)':>15} {'Match':>6}")
    for d in [2, 3, 4, 5]:
        for m in [3, 5, 10]:
            actual = len(simplex_support(d, m))
            formula = simplex_card(d, m)
            print(f"  {d:3d} {m:3d} {actual:10d} {formula:15d} {'✓' if actual == formula else '✗':>6}")
    
    # 3. Shadow tower descent
    print("\n--- Shadow Tower Descent (d=3, m=10) ---")
    d, m = 3, 10
    S = set(simplex_support(d, m))
    print(f"  {'k':>3} {'|Sh_k|':>10} {'Ratio':>10} {'Lower Bound':>15}")
    for k in range(m + 1):
        Shk = kth_shadow(k, S)
        ratio = shadow_ratio(d, m, k)
        lb = circuit_lower_bound(d, m, k)
        print(f"  {k:3d} {len(Shk):10d} {ratio:10.4f} {lb:15.2f}")
    
    # 4. Circuit lower bounds tower
    print("\n--- Circuit Lower Bound Tower ---")
    print("  For T(d, m), circuit size ≥ C(m-k+d-1, d-1) / d^k")
    print()
    for d in [3, 5, 10]:
        print(f"  d={d}:")
        for m in [10, 20]:
            print(f"    m={m}:")
            for k in range(1, min(m, 6)):
                lb = circuit_lower_bound(d, m, k)
                shadow_card_val = simplex_card(d, m - k)
                print(f"      k={k}: |Sh_k| = {shadow_card_val:8d}, "
                      f"bound = {lb:12.2f}")
    
    # 5. Jet-shadow correspondence
    print("\n--- Jet-Shadow Correspondence ---")
    print("  Jet dimension J^k(R^d) = C(d+k-1, k)")
    for d in [3, 4, 5]:
        for k in [1, 2, 3, 4]:
            jd = jet_dimension(d, k)
            print(f"  d={d}, k={k}: jet_dim = {jd}")
    
    # 6. Superlinear conjecture test
    print("\n--- Superlinear Shadow Conjecture Test ---")
    print("  Testing: C(m-k+d-1,d-1) * d^(k+1) > k * C(m+d-1,d-1) * d^k")
    all_pass = True
    for d in [3, 4, 5]:
        for m in [10, 20, 50]:
            for k in range(1, min(m // 2, 8)):
                lhs = simplex_card(d, m - k) * d ** (k + 1)
                rhs = k * simplex_card(d, m) * d ** k
                holds = lhs > rhs
                if not holds:
                    print(f"  FAILS: d={d}, m={m}, k={k}: {lhs} <= {rhs}")
                    all_pass = False
    if all_pass:
        print("  All tests PASS ✓")
    
    print("\n" + "=" * 70)
    print("All demonstrations complete.")


"""Generate PACKAGE.json from the individual files."""
import json

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Catalog/Pythagorean/HigherOrderShadowTower.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz1 = read_file('viz_shadow_tower.py')
viz2 = read_file('viz_circuit_bounds.py')
viz3 = read_file('viz_jet_shadow.py')

package = {
    "title": "Higher-Order Shadow Towers and Superlinear Circuit Lower Bounds",
    "domain": "Arithmetic Circuit Complexity / Combinatorics / Differential Geometry",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Shadow Tower Verification",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "k-th Shadow Computation",
            "pseudocode": "Algorithm: ComputeKthShadow(S, k)\nInput: Support set S ⊂ N^d, order k\nOutput: Sh_k(S)\n\n1. current ← S\n2. for j = 1 to k:\n3.   shadow ← ∅\n4.   for each α ∈ current:\n5.     for i = 1 to d:\n6.       if α_i > 0:\n7.         β ← α - e_i\n8.         shadow ← shadow ∪ {β}\n9.   current ← shadow\n10. return current\n\nComplexity: O(k · |S| · d) time, O(max_j |Sh_j(S)| · d) space",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Shadow Tower Heatmap & Decay Curves",
            "code": viz1,
            "description": "Heatmap of shadow cardinalities |Sh_k(T(d,m))| for varying m and k, plus shadow ratio decay curves showing how different dimensions affect the rate of shadow shrinkage."
        },
        {
            "name": "Circuit Lower Bound Tower",
            "code": viz2,
            "description": "Four-panel visualization: (1) Circuit bounds vs derivative order for fixed d, (2) Circuit bounds vs k for fixed m, (3) Optimal derivative order k* vs degree, (4) Maximum lower bound growth with degree."
        },
        {
            "name": "Jet-Shadow Correspondence",
            "code": viz3,
            "description": "Three-panel visualization showing the trade-off between jet bundle dimensions and shadow cardinalities, cumulative information distribution, and testing the superlinear growth conjecture."
        }
    ],
    "interactive_demos": [
        {
            "name": "Shadow Tower Explorer",
            "html": """<div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 700px; margin: 0 auto; padding: 20px; background: #f8f9fa; border-radius: 12px;">
  <h3 style="color: #2c3e50; margin-bottom: 15px;">🔍 Shadow Tower Explorer</h3>
  <div style="display: flex; gap: 20px; margin-bottom: 20px;">
    <label style="display: flex; flex-direction: column; font-size: 14px; color: #555;">
      Dimension (d)
      <input type="range" id="st-d" min="2" max="8" value="3" oninput="updateST()">
      <span id="st-d-val" style="text-align: center; font-weight: bold;">3</span>
    </label>
    <label style="display: flex; flex-direction: column; font-size: 14px; color: #555;">
      Degree (m)
      <input type="range" id="st-m" min="2" max="20" value="10" oninput="updateST()">
      <span id="st-m-val" style="text-align: center; font-weight: bold;">10</span>
    </label>
  </div>
  <div id="st-output" style="background: white; padding: 15px; border-radius: 8px; border: 1px solid #dee2e6;"></div>
  <script>
    function choose(n, k) {
      if (k < 0 || k > n) return 0;
      if (k === 0 || k === n) return 1;
      let result = 1;
      for (let i = 0; i < Math.min(k, n - k); i++) {
        result = result * (n - i) / (i + 1);
      }
      return Math.round(result);
    }
    function updateST() {
      const d = parseInt(document.getElementById('st-d').value);
      const m = parseInt(document.getElementById('st-m').value);
      document.getElementById('st-d-val').textContent = d;
      document.getElementById('st-m-val').textContent = m;
      let html = '<table style="width:100%; border-collapse: collapse; font-size: 13px;">';
      html += '<tr style="background: #e9ecef;"><th style="padding: 6px; border: 1px solid #dee2e6;">k</th><th style="padding: 6px; border: 1px solid #dee2e6;">|Sh_k|</th><th style="padding: 6px; border: 1px solid #dee2e6;">Ratio</th><th style="padding: 6px; border: 1px solid #dee2e6;">Circuit LB</th><th style="padding: 6px; border: 1px solid #dee2e6;">Bar</th></tr>';
      const base = choose(m + d - 1, d - 1);
      for (let k = 0; k <= m && k <= 15; k++) {
        const card = choose(m - k + d - 1, d - 1);
        const ratio = base > 0 ? (card / base).toFixed(4) : '0';
        const lb = Math.pow(d, k) > 0 ? (card / Math.pow(d, k)).toFixed(2) : '0';
        const barWidth = base > 0 ? Math.round(card / base * 300) : 0;
        html += '<tr><td style="padding: 4px 6px; border: 1px solid #dee2e6; text-align: center;">' + k + '</td>';
        html += '<td style="padding: 4px 6px; border: 1px solid #dee2e6; text-align: right;">' + card + '</td>';
        html += '<td style="padding: 4px 6px; border: 1px solid #dee2e6; text-align: right;">' + ratio + '</td>';
        html += '<td style="padding: 4px 6px; border: 1px solid #dee2e6; text-align: right;">' + lb + '</td>';
        html += '<td style="padding: 4px 6px; border: 1px solid #dee2e6;"><div style="width:' + barWidth + 'px; height: 14px; background: linear-gradient(90deg, #3498db, #2ecc71); border-radius: 3px;"></div></td></tr>';
      }
      html += '</table>';
      html += '<p style="font-size: 12px; color: #888; margin-top: 10px;">T(' + d + ', ' + m + ') has ' + base + ' monomials. Shadow tower has ' + Math.min(m + 1, 16) + ' levels.</p>';
      document.getElementById('st-output').innerHTML = html;
    }
    updateST();
  </script>
</div>""",
            "description": "Interactive explorer for the shadow tower. Adjust dimension d and degree m to see how the tower of shadows evolves, with cardinalities, ratios, and circuit lower bounds."
        },
        {
            "name": "Jet-Shadow Product Visualizer",
            "html": """<div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 700px; margin: 0 auto; padding: 20px; background: #f0f4f8; border-radius: 12px;">
  <h3 style="color: #2c3e50; margin-bottom: 15px;">📐 Jet-Shadow Information Content</h3>
  <div style="display: flex; gap: 20px; margin-bottom: 15px;">
    <label style="font-size: 14px; color: #555;">d = <input type="number" id="js-d" min="2" max="10" value="4" style="width: 50px;" onchange="updateJS()"></label>
    <label style="font-size: 14px; color: #555;">m = <input type="number" id="js-m" min="3" max="25" value="10" style="width: 50px;" onchange="updateJS()"></label>
  </div>
  <canvas id="js-canvas" width="660" height="300" style="background: white; border-radius: 8px; border: 1px solid #ccc;"></canvas>
  <p id="js-info" style="font-size: 13px; color: #666; margin-top: 8px;"></p>
  <script>
    function chooseJS(n, k) {
      if (k < 0 || k > n) return 0;
      if (k === 0 || k === n) return 1;
      let r = 1;
      for (let i = 0; i < Math.min(k, n - k); i++) r = r * (n - i) / (i + 1);
      return Math.round(r);
    }
    function updateJS() {
      const d = parseInt(document.getElementById('js-d').value);
      const m = parseInt(document.getElementById('js-m').value);
      const canvas = document.getElementById('js-canvas');
      const ctx = canvas.getContext('2d');
      const W = canvas.width, H = canvas.height;
      ctx.clearRect(0, 0, W, H);
      
      let data = [];
      let maxProd = 0, peakK = 0;
      for (let k = 0; k <= m; k++) {
        const jet = chooseJS(d + k - 1, k);
        const shadow = chooseJS(m - k + d - 1, d - 1);
        const prod = jet * shadow;
        data.push({k, jet, shadow, prod});
        if (prod > maxProd) { maxProd = prod; peakK = k; }
      }
      
      const padL = 60, padR = 20, padT = 30, padB = 40;
      const plotW = W - padL - padR, plotH = H - padT - padB;
      
      // Axes
      ctx.strokeStyle = '#999'; ctx.lineWidth = 1;
      ctx.beginPath(); ctx.moveTo(padL, padT); ctx.lineTo(padL, H - padB); ctx.lineTo(W - padR, H - padB); ctx.stroke();
      
      // Draw bars
      const barW = Math.max(2, plotW / (m + 2));
      data.forEach((pt, i) => {
        const x = padL + (i + 0.5) * plotW / (m + 1);
        const h = maxProd > 0 ? pt.prod / maxProd * plotH : 0;
        const color = i === peakK ? '#e74c3c' : '#3498db';
        ctx.fillStyle = color;
        ctx.fillRect(x - barW/2, H - padB - h, barW, h);
        if (m <= 15) {
          ctx.fillStyle = '#333'; ctx.font = '10px sans-serif'; ctx.textAlign = 'center';
          ctx.fillText(i, x, H - padB + 14);
        }
      });
      
      // Labels
      ctx.fillStyle = '#333'; ctx.font = '12px sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText('Derivative Order k', W / 2, H - 5);
      ctx.save(); ctx.translate(15, H / 2); ctx.rotate(-Math.PI / 2);
      ctx.fillText('Info Content (jet × shadow)', 0, 0);
      ctx.restore();
      
      ctx.fillStyle = '#e74c3c'; ctx.font = 'bold 13px sans-serif';
      ctx.fillText('Peak at k = ' + peakK, W / 2, 18);
      
      document.getElementById('js-info').textContent = 
        'Peak info content at k=' + peakK + ': jet_dim=' + data[peakK].jet + 
        ' × shadow=' + data[peakK].shadow + ' = ' + data[peakK].prod + 
        ' terms. Total across all orders: ' + data.reduce((s, p) => s + p.prod, 0);
    }
    updateJS();
  </script>
</div>""",
            "description": "Visualizes the jet dimension × shadow cardinality product across all derivative orders, revealing the peak information content order for any polynomial."
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully.")


"""
Circuit Lower Bound Tower Visualization
=========================================
Visualizes the tower of circuit lower bounds for k-th derivative
computation, showing how the optimal derivative order varies
with dimension and degree.

The key insight: there exists an optimal k* that maximizes the
lower bound, balancing shadow shrinkage against channel explosion.
"""
import numpy as np
import matplotlib.pyplot as plt
from math import comb, log2


def circuit_lower_bound(d: int, m: int, k: int) -> float:
    """C(m - k + d - 1, d - 1) / d^k"""
    if k > m or d <= 0:
        return 0.0
    shadow_card = comb(m - k + d - 1, d - 1)
    channels = d ** k
    return shadow_card / channels if channels > 0 else 0.0


def optimal_k(d: int, m: int) -> tuple[int, float]:
    """Find the optimal k maximizing the circuit lower bound."""
    best_k, best_lb = 0, 0.0
    for k in range(m + 1):
        lb = circuit_lower_bound(d, m, k)
        if lb > best_lb:
            best_k, best_lb = k, lb
    return best_k, best_lb


fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Lower bound curves for fixed d, varying m
ax = axes[0, 0]
d = 4
for m in [5, 10, 15, 20, 30]:
    ks = range(m + 1)
    bounds = [circuit_lower_bound(d, m, k) for k in ks]
    ax.semilogy(ks, [max(b, 0.01) for b in bounds], 'o-', markersize=3, label=f'm = {m}')
    # Mark optimal
    ok, ob = optimal_k(d, m)
    ax.plot(ok, ob, '*', markersize=12, color='red', zorder=5)

ax.set_xlabel('Derivative order k', fontsize=11)
ax.set_ylabel('Circuit lower bound', fontsize=11)
ax.set_title(f'Circuit Bounds vs k (d = {d})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Lower bound curves for fixed m, varying d
ax = axes[0, 1]
m = 15
for d in [2, 3, 4, 5, 8, 12]:
    ks = range(m + 1)
    bounds = [circuit_lower_bound(d, m, k) for k in ks]
    ax.semilogy(ks, [max(b, 0.01) for b in bounds], 'o-', markersize=3, label=f'd = {d}')

ax.set_xlabel('Derivative order k', fontsize=11)
ax.set_ylabel('Circuit lower bound', fontsize=11)
ax.set_title(f'Circuit Bounds vs k (m = {m})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: Optimal k as function of m for various d
ax = axes[1, 0]
for d in [2, 3, 5, 8, 12]:
    ms = range(2, 40)
    opt_ks = [optimal_k(d, m)[0] for m in ms]
    ax.plot(ms, opt_ks, 'o-', markersize=3, label=f'd = {d}')

ax.set_xlabel('Degree m', fontsize=11)
ax.set_ylabel('Optimal derivative order k*', fontsize=11)
ax.set_title('Optimal k* vs Degree', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Maximum lower bound growth
ax = axes[1, 1]
for d in [3, 5, 8, 12]:
    ms = range(2, 50)
    max_bounds = [optimal_k(d, m)[1] for m in ms]
    ax.semilogy(ms, max_bounds, '-', linewidth=2, label=f'd = {d}')

ax.set_xlabel('Degree m', fontsize=11)
ax.set_ylabel('Max circuit lower bound', fontsize=11)
ax.set_title('Maximum Lower Bound Growth', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Higher-Order Shadow Tower: Circuit Complexity Lower Bounds',
             fontsize=15, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('circuit_bounds_tower.png', dpi=150, bbox_inches='tight')
plt.show()


"""
Jet-Shadow Correspondence Visualization
=========================================
Visualizes the cross-domain connection between jet bundle dimensions
and shadow tower cardinalities. Shows how the product
jet_dim(d,k) × |Sh_k(T(d,m))| encodes the full Taylor information
content of a polynomial.
"""
import numpy as np
import matplotlib.pyplot as plt
from math import comb


def jet_dimension(d: int, k: int) -> int:
    """C(d + k - 1, k)"""
    return comb(d + k - 1, k)


def shadow_card(d: int, m: int, k: int) -> int:
    """C(m - k + d - 1, d - 1)"""
    if k > m:
        return 0
    return comb(m - k + d - 1, d - 1)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Jet dimension vs shadow cardinality (trade-off)
ax = axes[0]
d, m = 5, 12
ks = range(m + 1)
jets = [jet_dimension(d, k) for k in ks]
shadows = [shadow_card(d, m, k) for k in ks]
products = [j * s for j, s in zip(jets, shadows)]

ax.semilogy(ks, jets, 's-', color='blue', label='Jet dim C(d+k-1,k)', markersize=5)
ax.semilogy(ks, [max(s, 0.5) for s in shadows], 'o-', color='red', 
            label='Shadow |Sh_k|', markersize=5)
ax.semilogy(ks, products, '^-', color='green', label='Product (info content)', markersize=5)

ax.set_xlabel('Order k', fontsize=11)
ax.set_ylabel('Count (log scale)', fontsize=11)
ax.set_title(f'Jet-Shadow Trade-off (d={d}, m={m})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Information content stacked area
ax = axes[1]
d = 4
for m in [6, 10, 15]:
    ks_list = list(range(m + 1))
    info = [jet_dimension(d, k) * shadow_card(d, m, k) for k in ks_list]
    total = sum(info)
    cumulative = np.cumsum(info) / total
    ax.plot(ks_list, cumulative, 'o-', markersize=4, label=f'm={m}')

ax.set_xlabel('Order k', fontsize=11)
ax.set_ylabel('Cumulative info fraction', fontsize=11)
ax.set_title(f'Taylor Information Distribution (d={d})', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.05)

# Panel 3: Superlinear growth test
ax = axes[2]
for d in [3, 4, 5, 8]:
    m = 20
    ks_list = list(range(1, m // 2 + 1))
    # Ratio: (shadow_card(d,m,k) * d) / (k * shadow_card(d,m,0))
    ratios = []
    for k in ks_list:
        sc_k = shadow_card(d, m, k)
        sc_0 = shadow_card(d, m, 0)
        ratio = (sc_k * d) / (k * sc_0) if k * sc_0 > 0 else 0
        ratios.append(ratio)
    ax.plot(ks_list, ratios, 'o-', markersize=4, label=f'd={d}')

ax.axhline(y=1.0, color='black', linestyle='--', alpha=0.5, label='Threshold')
ax.set_xlabel('Order k', fontsize=11)
ax.set_ylabel('Superlinear ratio', fontsize=11)
ax.set_title(f'Superlinear Conjecture (m=20)', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Jet-Shadow Correspondence: Geometry Meets Complexity',
             fontsize=15, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('jet_shadow_correspondence.png', dpi=150, bbox_inches='tight')
plt.show()


"""
Shadow Tower Heatmap Visualization
===================================
Visualizes the shadow tower cardinalities as a heatmap,
showing how |Sh_k(T(d,m))| varies with d, m, and k.

The heatmap reveals the decay pattern: higher k means fewer
support elements, while higher d means more elements at each level.
"""
import numpy as np
import matplotlib.pyplot as plt
from math import comb


def simplex_card(d: int, m: int) -> int:
    """C(m + d - 1, d - 1)"""
    if d <= 0 or m < 0:
        return 0
    return comb(m + d - 1, d - 1)


# Parameters
m_max = 15
k_max = 15
d = 4  # Fix dimension

# Build the heatmap data
data = np.zeros((k_max + 1, m_max + 1))
for m in range(m_max + 1):
    for k in range(min(k_max, m) + 1):
        data[k, m] = simplex_card(d, m - k)

# Use log scale for better visualization
log_data = np.log10(data + 1)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Heatmap of |Sh_k(T(d,m))|
ax = axes[0]
im = ax.imshow(log_data, aspect='auto', origin='lower', cmap='YlOrRd',
               extent=[-0.5, m_max + 0.5, -0.5, k_max + 0.5])
ax.set_xlabel('Degree m', fontsize=12)
ax.set_ylabel('Shadow order k', fontsize=12)
ax.set_title(f'log₁₀(|Sh_k(T({d}, m))| + 1)', fontsize=14)
fig.colorbar(im, ax=ax, label='log₁₀(cardinality + 1)')

# Add the "forbidden zone" line k = m
ax.plot([0, m_max], [0, m_max], 'w--', linewidth=2, label='k = m (boundary)')
ax.legend(loc='upper left', fontsize=10)

# Right: Shadow ratio decay curves
ax = axes[1]
for d_val in [2, 3, 4, 5, 8]:
    m = 20
    ks = range(m + 1)
    ratios = [simplex_card(d_val, m - k) / simplex_card(d_val, m) 
              for k in ks]
    ax.plot(ks, ratios, 'o-', markersize=3, label=f'd = {d_val}')

ax.set_xlabel('Shadow order k', fontsize=12)
ax.set_ylabel('Shadow ratio |Sh_k| / |S|', fontsize=12)
ax.set_title(f'Shadow Decay Curves (m = 20)', fontsize=14)
ax.legend(fontsize=10)
ax.set_ylim(-0.05, 1.05)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('shadow_tower_heatmap.png', dpi=150, bbox_inches='tight')
plt.show()
