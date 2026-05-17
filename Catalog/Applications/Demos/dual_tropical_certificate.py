#!/usr/bin/env python3
"""
Applications of Tropical Classifier Certification
===================================================
Real-world applications demonstrating the tropical certification framework:
  1. Neural network robustness certification (ReLU networks as tropical classifiers)
  2. Post-quantum cryptographic parameter stability
  3. Multi-class image classifier certification simulation
"""

import numpy as np
from typing import List, Dict, Tuple


class TropicalAffineForm:
    """f(x) = max_k (a_k · x + b_k)"""
    def __init__(self, slopes: np.ndarray, intercepts: np.ndarray):
        self.slopes = np.atleast_2d(slopes)
        self.intercepts = np.atleast_1d(intercepts)
        self.K = self.slopes.shape[0]
        self.n = self.slopes.shape[1]

    def eval(self, x: np.ndarray) -> float:
        return float(max(self.slopes[k] @ x + self.intercepts[k] for k in range(self.K)))

    def lipschitz_l1(self) -> float:
        return max(float(np.sum(np.abs(self.slopes[k]))) for k in range(self.K))


# ──────────────────────────────────────────────
# Application 1: ReLU Network as Tropical Classifier
# ──────────────────────────────────────────────

def relu_network_to_tropical(
    weights: List[np.ndarray],
    biases: List[np.ndarray]
) -> Dict[int, TropicalAffineForm]:
    """
    Convert a small ReLU network into tropical affine forms.

    For a 2-layer ReLU network with K hidden units and C output classes,
    the output for each class is a tropical polynomial (max of affine forms)
    with up to 2^K terms (one per activation pattern of the hidden layer).

    This demonstrates that ReLU networks ARE tropical classifiers.

    Args:
        weights: [W1 (K×n), W2 (C×K)] weight matrices
        biases: [b1 (K,), b2 (C,)] bias vectors

    Returns:
        Dictionary mapping class index to TropicalAffineForm
    """
    W1, W2 = weights
    b1, b2 = biases
    K = W1.shape[0]  # hidden units
    C = W2.shape[0]  # classes
    n = W1.shape[1]  # input dim

    forms = {}
    # Enumerate all 2^K activation patterns
    num_patterns = 2 ** K
    for c in range(C):
        slopes_list = []
        intercepts_list = []
        for pattern in range(num_patterns):
            # pattern encodes which ReLUs are active
            mask = np.array([(pattern >> i) & 1 for i in range(K)], dtype=float)
            # Active slope: W2[c] @ diag(mask) @ W1
            slope = W2[c] @ np.diag(mask) @ W1
            # Active intercept: W2[c] @ diag(mask) @ b1 + b2[c]
            intercept = float(W2[c] @ (mask * b1) + b2[c])
            slopes_list.append(slope)
            intercepts_list.append(intercept)

        forms[c] = TropicalAffineForm(
            slopes=np.array(slopes_list),
            intercepts=np.array(intercepts_list)
        )

    return forms


def demo_relu_certification():
    """Demonstrate robustness certification of a small ReLU network."""
    print("=" * 60)
    print("APPLICATION 1: ReLU Network Robustness Certification")
    print("=" * 60)

    np.random.seed(42)
    n_input = 3  # input dimension
    K = 4        # hidden units
    C = 3        # classes

    # Random small network
    W1 = np.random.randn(K, n_input) * 0.5
    b1 = np.random.randn(K) * 0.1
    W2 = np.random.randn(C, K) * 0.5
    b2 = np.random.randn(C) * 0.1

    forms = relu_network_to_tropical([W1, W2], [b1, b2])

    print(f"\nNetwork: {n_input}→{K}→{C} ReLU network")
    print(f"Tropical forms: {C} classes, each with up to {2**K} affine terms")

    # Test certification on several points
    for trial in range(5):
        x = np.random.randn(n_input)
        scores = {c: forms[c].eval(x) for c in range(C)}
        pred = max(scores, key=scores.get)
        margin = min(scores[pred] - scores[d] for d in range(C) if d != pred)
        L = max(forms[c].lipschitz_l1() for c in range(C))
        radius = max(0, margin / (2 * L)) if L > 0 else 0

        print(f"\n  Point {trial+1}: x={np.round(x, 2)}")
        print(f"    Predicted class: {pred}, margin: {margin:.4f}")
        print(f"    Lipschitz constant: {L:.4f}")
        print(f"    Certified radius: {radius:.6f}")


# ──────────────────────────────────────────────
# Application 2: Post-Quantum Parameter Stability
# ──────────────────────────────────────────────

def demo_crypto_stability():
    """Demonstrate cryptographic parameter stability analysis."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Post-Quantum Cryptographic Stability")
    print("=" * 60)

    # Model: lattice-based crypto where security depends on parameters
    # Security advantage = min gap between basis vector norms and attack threshold
    # Modeled as tropical function of lattice parameters

    np.random.seed(123)
    n_params = 8  # lattice dimension parameters

    # Security advantage as difference of tropical forms
    K1, K2 = 5, 4
    slopes_defense = np.random.randn(K1, n_params) * 0.3
    intercepts_defense = np.random.randn(K1) + 2.0
    slopes_attack = np.random.randn(K2, n_params) * 0.2
    intercepts_attack = np.random.randn(K2)

    form_defense = TropicalAffineForm(slopes_defense, intercepts_defense)
    form_attack = TropicalAffineForm(slopes_attack, intercepts_attack)

    def security_advantage(params):
        return form_defense.eval(params) - form_attack.eval(params)

    L = form_defense.lipschitz_l1() + form_attack.lipschitz_l1()

    # Nominal parameters
    params = np.ones(n_params) * 1.5
    adv = security_advantage(params)

    print(f"\nLattice dimension: {n_params}")
    print(f"Security advantage at nominal params: {adv:.4f}")
    print(f"Combined Lipschitz constant: {L:.4f}")

    if adv > 0:
        cert_radius = adv / L
        print(f"Certified perturbation radius: {cert_radius:.6f}")

        # Verify with random perturbations
        n_tests = 10000
        n_secure = 0
        for _ in range(n_tests):
            delta = np.random.randn(n_params)
            delta = delta / max(np.max(np.abs(delta)), 1e-10) * cert_radius * 0.95
            if security_advantage(params + delta) >= -1e-10:
                n_secure += 1
        print(f"Verification: {n_secure}/{n_tests} perturbations maintained security")

        # Dimension scaling analysis
        print(f"\nDimension scaling of certified radius:")
        for dim in [4, 8, 16, 32, 64, 128]:
            s_d = np.random.randn(K1, dim) * 0.3
            i_d = np.random.randn(K1) + 2.0
            s_a = np.random.randn(K2, dim) * 0.2
            i_a = np.random.randn(K2)
            fd = TropicalAffineForm(s_d, i_d)
            fa = TropicalAffineForm(s_a, i_a)
            p = np.ones(dim) * 1.5
            a = fd.eval(p) - fa.eval(p)
            lip = fd.lipschitz_l1() + fa.lipschitz_l1()
            r = a / lip if a > 0 and lip > 0 else 0
            print(f"    dim={dim:4d}: advantage={a:.3f}, L={lip:.1f}, radius={r:.6f}")


# ──────────────────────────────────────────────
# Application 3: Ensemble Classifier Certification
# ──────────────────────────────────────────────

def demo_ensemble():
    """Demonstrate certification of an ensemble of linear classifiers."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Ensemble Classifier Certification")
    print("=" * 60)

    np.random.seed(7)
    n = 5    # input dim
    C = 4    # classes
    M = 3    # ensemble members

    # Each ensemble member is a linear classifier
    # Ensemble score = max over members (best-of-M)
    # This is exactly a tropical affine form with M terms per class
    forms = {}
    for c in range(C):
        slopes = np.random.randn(M, n) * 0.5
        intercepts = np.random.randn(M) * 0.2
        forms[c] = TropicalAffineForm(slopes, intercepts)

    x = np.random.randn(n)
    scores = {c: forms[c].eval(x) for c in range(C)}
    pred = max(scores, key=scores.get)
    margin = min(scores[pred] - scores[d] for d in range(C) if d != pred)
    L = max(forms[c].lipschitz_l1() for c in range(C))
    radius = margin / (2 * L) if margin > 0 and L > 0 else 0

    print(f"\nEnsemble: {M} members, {C} classes, {n}D input")
    print(f"Scores: {', '.join(f'{c}:{v:.3f}' for c, v in scores.items())}")
    print(f"Predicted: {pred}, margin: {margin:.4f}")
    print(f"Lipschitz constant: {L:.4f}")
    print(f"Certified radius: {radius:.6f}")

    # Verify
    n_tests = 5000
    n_robust = 0
    for _ in range(n_tests):
        delta = np.random.randn(n)
        delta = delta / max(np.max(np.abs(delta)), 1e-10) * radius * 0.99
        y = x + delta
        scores_y = {c: forms[c].eval(y) for c in range(C)}
        if max(scores_y, key=scores_y.get) == pred:
            n_robust += 1
    print(f"Robustness verification: {n_robust}/{n_tests} (expected: all)")


if __name__ == "__main__":
    demo_relu_certification()
    demo_crypto_stability()
    demo_ensemble()


#!/usr/bin/env python3
"""
Tropical Classifier Certification — Demonstration
===================================================
Demonstrates the core theorems from the Dual Tropical Certificate framework:
  1. Tropical affine score evaluation
  2. Chamber decomposition of the margin region
  3. Certified robustness radius computation
  4. Security stability under parameter perturbation
"""

import numpy as np
from itertools import product as cartesian_product

# ──────────────────────────────────────────────
# 1. Tropical Affine Form Evaluation
# ──────────────────────────────────────────────

class TropicalAffineForm:
    """A tropical affine form: f(x) = max_k (a_k · x + b_k)."""
    def __init__(self, slopes: np.ndarray, intercepts: np.ndarray):
        # slopes: (K, n) array, intercepts: (K,) array
        self.slopes = np.atleast_2d(slopes)
        self.intercepts = np.atleast_1d(intercepts)
        self.K = self.slopes.shape[0]
        self.n = self.slopes.shape[1]

    def eval(self, x: np.ndarray) -> float:
        """Evaluate the tropical affine form at x."""
        return max(self.slopes[k] @ x + self.intercepts[k] for k in range(self.K))

    def active_term(self, x: np.ndarray) -> int:
        """Return the index of the active (maximizing) term."""
        vals = [self.slopes[k] @ x + self.intercepts[k] for k in range(self.K)]
        return int(np.argmax(vals))


class TropicalClassifier:
    """A classifier where each class score is a tropical affine form."""
    def __init__(self, forms: dict):
        self.forms = forms  # class_label -> TropicalAffineForm
        self.classes = list(forms.keys())

    def score(self, c, x):
        return self.forms[c].eval(x)

    def predict(self, x):
        return max(self.classes, key=lambda c: self.score(c, x))

    def margin(self, c0, x):
        """Minimum margin of c0 over all competitors."""
        s0 = self.score(c0, x)
        return min(s0 - self.score(d, x) for d in self.classes if d != c0)

    def pairwise_margins(self, c0, x):
        """Return dict {d: score(c0,x) - score(d,x)} for d ≠ c0."""
        s0 = self.score(c0, x)
        return {d: s0 - self.score(d, x) for d in self.classes if d != c0}

    def lipschitz_constant(self):
        """Upper bound on Lipschitz constant (L1 norm of slopes, max over terms and classes)."""
        L = 0.0
        for c in self.classes:
            form = self.forms[c]
            for k in range(form.K):
                L = max(L, np.sum(np.abs(form.slopes[k])))
        return L

    def certified_radius(self, c0, x):
        """Certified radius: margin / (2 * L)."""
        m = self.margin(c0, x)
        L = self.lipschitz_constant()
        if m <= 0 or L <= 0:
            return 0.0
        return m / (2 * L)

    def chamber_assignment(self, x):
        """Return the chamber assignment σ: which term is active for each class."""
        return {c: self.forms[c].active_term(x) for c in self.classes}


# ──────────────────────────────────────────────
# 2. Example: 2D Classifier with 3 Classes
# ──────────────────────────────────────────────

def demo_classifier():
    print("=" * 60)
    print("DEMO 1: Tropical Classifier in 2D with 3 Classes")
    print("=" * 60)

    # Class A: max(2x+y+1, -x+3y+2)
    form_A = TropicalAffineForm(
        slopes=np.array([[2.0, 1.0], [-1.0, 3.0]]),
        intercepts=np.array([1.0, 2.0])
    )
    # Class B: max(x-y+0.5, -2x+y+1.5)
    form_B = TropicalAffineForm(
        slopes=np.array([[1.0, -1.0], [-2.0, 1.0]]),
        intercepts=np.array([0.5, 1.5])
    )
    # Class C: max(-x-y+3, x+2y-1)
    form_C = TropicalAffineForm(
        slopes=np.array([[-1.0, -1.0], [1.0, 2.0]]),
        intercepts=np.array([3.0, -1.0])
    )

    clf = TropicalClassifier({'A': form_A, 'B': form_B, 'C': form_C})

    # Test point
    x = np.array([1.0, 0.5])
    print(f"\nTest point: x = {x}")
    print(f"Scores: A={clf.score('A', x):.2f}, B={clf.score('B', x):.2f}, C={clf.score('C', x):.2f}")
    print(f"Predicted class: {clf.predict(x)}")
    print(f"Margin for class A: {clf.margin('A', x):.4f}")
    print(f"Pairwise margins: {clf.pairwise_margins('A', x)}")
    print(f"Lipschitz constant L: {clf.lipschitz_constant():.2f}")
    print(f"Certified radius: {clf.certified_radius('A', x):.4f}")
    print(f"Chamber assignment: {clf.chamber_assignment(x)}")

    # Verify robustness within certified radius
    r = clf.certified_radius('A', x)
    print(f"\nVerifying robustness within radius {r:.4f}:")
    np.random.seed(42)
    n_tests = 1000
    n_robust = 0
    for _ in range(n_tests):
        delta = np.random.randn(2)
        delta = delta / np.max(np.abs(delta)) * r * 0.99  # stay within radius (l∞ ball)
        y = x + delta
        if clf.predict(y) == 'A':
            n_robust += 1
    print(f"  {n_robust}/{n_tests} perturbations preserved prediction (expected: all 1000)")


# ──────────────────────────────────────────────
# 3. Chamber Decomposition Visualization Data
# ──────────────────────────────────────────────

def demo_chambers():
    print("\n" + "=" * 60)
    print("DEMO 2: Chamber Decomposition")
    print("=" * 60)

    form_A = TropicalAffineForm(
        slopes=np.array([[2.0, 1.0], [-1.0, 3.0]]),
        intercepts=np.array([1.0, 2.0])
    )
    form_B = TropicalAffineForm(
        slopes=np.array([[1.0, -1.0], [-2.0, 1.0]]),
        intercepts=np.array([0.5, 1.5])
    )

    clf = TropicalClassifier({'A': form_A, 'B': form_B})

    # Enumerate all chamber assignments
    chambers = list(cartesian_product(range(form_A.K), range(form_B.K)))
    print(f"\nNumber of possible chamber assignments: {len(chambers)}")
    print("(A_term, B_term) assignments:", chambers)

    # Sample the plane and categorize by chamber
    grid = np.linspace(-2, 2, 50)
    for i, (ka, kb) in enumerate(chambers):
        count = 0
        for gx in grid:
            for gy in grid:
                x = np.array([gx, gy])
                if form_A.active_term(x) == ka and form_B.active_term(x) == kb:
                    count += 1
        print(f"  Chamber (A={ka}, B={kb}): {count} grid points")


# ──────────────────────────────────────────────
# 4. Security Stability Demo
# ──────────────────────────────────────────────

def demo_security_stability():
    print("\n" + "=" * 60)
    print("DEMO 3: Security Stability under Parameter Perturbation")
    print("=" * 60)

    # Simulate a security advantage function as a tropical form
    # adv(params) = max(3p1 + 2p2 - 5, -p1 + 4p2 - 3) - max(2p1 - p2 + 1, -3p1 + p2 + 2)
    form_pos = TropicalAffineForm(
        slopes=np.array([[3.0, 2.0], [-1.0, 4.0]]),
        intercepts=np.array([-5.0, -3.0])
    )
    form_neg = TropicalAffineForm(
        slopes=np.array([[2.0, -1.0], [-3.0, 1.0]]),
        intercepts=np.array([1.0, 2.0])
    )

    def advantage(p):
        return form_pos.eval(p) - form_neg.eval(p)

    # Lipschitz constant: sum of L1 norms of all slopes
    L = max(
        max(np.sum(np.abs(form_pos.slopes[k])) for k in range(form_pos.K)),
        max(np.sum(np.abs(form_neg.slopes[k])) for k in range(form_neg.K))
    ) * 2  # factor of 2 for the difference

    params = np.array([2.0, 1.5])
    m = advantage(params)
    print(f"\nBase parameters: {params}")
    print(f"Advantage at base: {m:.4f}")
    print(f"Lipschitz constant: {L:.2f}")

    if m > 0:
        cert_radius = m / L
        print(f"Certified perturbation radius: {cert_radius:.4f}")
        print(f"\nVerifying: all perturbations within radius preserve positive advantage")

        np.random.seed(123)
        n_tests = 1000
        n_secure = sum(
            1 for _ in range(n_tests)
            if advantage(params + np.random.randn(2) * cert_radius * 0.99 /
                         np.sqrt(2)) >= -1e-10
        )
        print(f"  {n_secure}/{n_tests} perturbations maintained security (expected: all)")
    else:
        print("Advantage is not positive at base parameters.")


# ──────────────────────────────────────────────
# 5. Dimension Scaling of Certified Radius
# ──────────────────────────────────────────────

def demo_scaling():
    print("\n" + "=" * 60)
    print("DEMO 4: Certified Radius vs Dimension")
    print("=" * 60)

    np.random.seed(0)
    for n in [2, 5, 10, 20, 50]:
        # Random tropical classifier with 3 classes, 4 terms each
        forms = {}
        for c in ['A', 'B', 'C']:
            slopes = np.random.randn(4, n)
            intercepts = np.random.randn(4)
            forms[c] = TropicalAffineForm(slopes, intercepts)

        clf = TropicalClassifier(forms)
        x = np.random.randn(n)
        pred = clf.predict(x)
        margin = clf.margin(pred, x)
        L = clf.lipschitz_constant()
        radius = clf.certified_radius(pred, x)
        print(f"  n={n:3d}: margin={margin:.4f}, L={L:.2f}, radius={radius:.6f}")


if __name__ == "__main__":
    demo_classifier()
    demo_chambers()
    demo_security_stability()
    demo_scaling()


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
import json

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_viz_data():
    """Parse viz_data.txt into dict of name -> base64 string."""
    lines = read_file('viz_data.txt').strip().split('\n')
    result = {}
    i = 0
    while i < len(lines):
        name = lines[i].strip()
        i += 1
        if i < len(lines):
            result[name] = lines[i].strip()
            i += 1
    return result

# Read all files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('DualTropicalCertificate/Basic.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualization data
viz = read_viz_data()

package = {
    "title": "Dual Tropical Certificate: Margin Geometry as Chamber Stability and Cryptographic Distinguishability",
    "domain": "Tropical Geometry / Machine Learning / Cryptography",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Classifier Certification Demo",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Chamber Enumeration",
            "pseudocode": "Input: forms {c -> TropicalAffineForm}\nOutput: list of (assignment, polyhedron) pairs\n\nfor each assignment σ in ∏_c {1..K_c}:\n  halfspaces = []\n  for each class c:\n    for each term k ≠ σ(c):\n      w = slopes[c,σ(c)] - slopes[c,k]\n      b = intercepts[c,σ(c)] - intercepts[c,k]\n      halfspaces.append(AffineHalfspace(w, b))\n  yield (σ, Polyhedron(halfspaces))",
            "code": algorithms_code
        },
        {
            "name": "Certified Robustness Radius",
            "pseudocode": "Input: classifier, class c₀, point x\nOutput: certified radius r\n\n1. margin = min_{d≠c₀} (score(c₀,x) - score(d,x))\n2. L = max_c max_k ∑_i |a_{c,k,i}|  (Lipschitz constant)\n3. r = margin / (2L)\n4. return r",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Chamber Decomposition and Classification Regions",
            "data": viz.get("CHAMBERS", "")
        },
        {
            "name": "Certified Radius Scaling with Dimension",
            "data": viz.get("SCALING", "")
        },
        {
            "name": "Security Stability Landscape",
            "data": viz.get("SECURITY", "")
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
Generate visualizations for the Tropical Certification paper.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
from matplotlib.colors import ListedColormap
import base64
from io import BytesIO


def fig_to_base64(fig):
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


class TropicalAffineForm:
    def __init__(self, slopes, intercepts):
        self.slopes = np.atleast_2d(slopes)
        self.intercepts = np.atleast_1d(intercepts)
        self.K = self.slopes.shape[0]

    def eval(self, x):
        return max(self.slopes[k] @ x + self.intercepts[k] for k in range(self.K))

    def active_term(self, x):
        vals = [self.slopes[k] @ x + self.intercepts[k] for k in range(self.K)]
        return int(np.argmax(vals))

    def lipschitz_l1(self):
        return max(float(np.sum(np.abs(self.slopes[k]))) for k in range(self.K))


# ──────────────────────────────────────────────
# Figure 1: Chamber Decomposition and Classification
# ──────────────────────────────────────────────

def plot_chambers_and_classification():
    form_A = TropicalAffineForm([[2, 1], [-1, 3]], [1, 2])
    form_B = TropicalAffineForm([[1, -1], [-2, 1]], [0.5, 1.5])
    form_C = TropicalAffineForm([[-1, -1], [1, 2]], [3, -1])

    forms = {'A': form_A, 'B': form_B, 'C': form_C}
    classes = ['A', 'B', 'C']

    fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

    grid_res = 300
    x_range = np.linspace(-2, 3, grid_res)
    y_range = np.linspace(-2, 3, grid_res)
    X, Y = np.meshgrid(x_range, y_range)

    # Panel 1: Classification regions
    class_map = np.zeros_like(X)
    for i in range(grid_res):
        for j in range(grid_res):
            pt = np.array([X[i, j], Y[i, j]])
            scores = {c: forms[c].eval(pt) for c in classes}
            pred = max(scores, key=scores.get)
            class_map[i, j] = classes.index(pred)

    cmap = ListedColormap(['#FF6B6B', '#4ECDC4', '#45B7D1'])
    axes[0].contourf(X, Y, class_map, levels=[-0.5, 0.5, 1.5, 2.5], cmap=cmap, alpha=0.6)
    axes[0].contour(X, Y, class_map, levels=[0.5, 1.5], colors='black', linewidths=1.5)
    axes[0].set_title('Classification Regions', fontsize=14, fontweight='bold')
    axes[0].set_xlabel('$x_1$', fontsize=12)
    axes[0].set_ylabel('$x_2$', fontsize=12)

    # Mark test point with certified radius
    test_x = np.array([1.0, 0.5])
    margin = min(forms['A'].eval(test_x) - forms[d].eval(test_x) for d in ['B', 'C'])
    L = max(forms[c].lipschitz_l1() for c in classes)
    radius = margin / (2 * L)
    circle = Circle(test_x, radius, fill=False, color='gold', linewidth=2.5, linestyle='--')
    axes[0].add_patch(circle)
    axes[0].plot(*test_x, 'k*', markersize=15, zorder=5)
    axes[0].annotate(f'r={radius:.2f}', test_x + 0.1, fontsize=10, fontweight='bold')

    # Panel 2: Chamber decomposition
    chamber_map = np.zeros_like(X)
    for i in range(grid_res):
        for j in range(grid_res):
            pt = np.array([X[i, j], Y[i, j]])
            chamber = tuple(forms[c].active_term(pt) for c in classes)
            # Encode chamber as number
            chamber_map[i, j] = chamber[0] * 4 + chamber[1] * 2 + chamber[2]

    cmap2 = plt.cm.Set3
    axes[1].contourf(X, Y, chamber_map, levels=np.arange(-0.5, 8.5), cmap=cmap2, alpha=0.7)
    axes[1].contour(X, Y, chamber_map, colors='gray', linewidths=0.8, alpha=0.5)
    axes[1].set_title('Tropical Chamber Decomposition', fontsize=14, fontweight='bold')
    axes[1].set_xlabel('$x_1$', fontsize=12)
    axes[1].set_ylabel('$x_2$', fontsize=12)
    axes[1].plot(*test_x, 'k*', markersize=15, zorder=5)

    # Panel 3: Margin heatmap
    margin_map = np.zeros_like(X)
    for i in range(grid_res):
        for j in range(grid_res):
            pt = np.array([X[i, j], Y[i, j]])
            scores = {c: forms[c].eval(pt) for c in classes}
            pred = max(scores, key=scores.get)
            margin_map[i, j] = min(scores[pred] - scores[d]
                                    for d in classes if d != pred)

    im = axes[2].contourf(X, Y, margin_map, levels=20, cmap='RdYlGn')
    axes[2].contour(X, Y, margin_map, levels=[0], colors='black', linewidths=2)
    axes[2].contour(X, Y, margin_map, levels=[1, 2, 3], colors='white',
                    linewidths=1, linestyles='--')
    plt.colorbar(im, ax=axes[2], label='Margin')
    axes[2].set_title('Classification Margin', fontsize=14, fontweight='bold')
    axes[2].set_xlabel('$x_1$', fontsize=12)
    axes[2].set_ylabel('$x_2$', fontsize=12)
    axes[2].plot(*test_x, 'k*', markersize=15, zorder=5)

    fig.suptitle('Tropical Classifier: Regions, Chambers, and Margins',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()

    fig.savefig('fig_chambers.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


# ──────────────────────────────────────────────
# Figure 2: Certified Radius Scaling
# ──────────────────────────────────────────────

def plot_radius_scaling():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

    np.random.seed(0)
    dims = [2, 3, 5, 8, 10, 15, 20, 30, 50, 75, 100]
    radii_mean = []
    radii_std = []
    lip_mean = []

    for n in dims:
        rs = []
        ls = []
        for trial in range(50):
            forms = {}
            for c in range(3):
                slopes = np.random.randn(4, n) * 0.5
                intercepts = np.random.randn(4)
                forms[c] = TropicalAffineForm(slopes, intercepts)
            x = np.random.randn(n)
            scores = {c: forms[c].eval(x) for c in range(3)}
            pred = max(scores, key=scores.get)
            margin = min(scores[pred] - scores[d] for d in range(3) if d != pred)
            L = max(forms[c].lipschitz_l1() for c in range(3))
            r = margin / (2 * L) if margin > 0 and L > 0 else 0
            rs.append(r)
            ls.append(L)
        radii_mean.append(np.mean(rs))
        radii_std.append(np.std(rs))
        lip_mean.append(np.mean(ls))

    axes[0].errorbar(dims, radii_mean, yerr=radii_std, fmt='o-',
                     color='#2196F3', capsize=4, linewidth=2, markersize=6)
    axes[0].set_xlabel('Input Dimension $n$', fontsize=12)
    axes[0].set_ylabel('Certified Radius', fontsize=12)
    axes[0].set_title('Certified Radius vs. Dimension', fontsize=14, fontweight='bold')
    axes[0].set_xscale('log')
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(dims, lip_mean, 's-', color='#FF5722', linewidth=2, markersize=6)
    axes[1].set_xlabel('Input Dimension $n$', fontsize=12)
    axes[1].set_ylabel('Lipschitz Constant $L$', fontsize=12)
    axes[1].set_title('Lipschitz Constant vs. Dimension', fontsize=14, fontweight='bold')
    axes[1].set_xscale('log')
    axes[1].set_yscale('log')
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('fig_scaling.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


# ──────────────────────────────────────────────
# Figure 3: Security Stability Visualization
# ──────────────────────────────────────────────

def plot_security_stability():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

    form_pos = TropicalAffineForm([[3, 2], [-1, 4]], [-5, -3])
    form_neg = TropicalAffineForm([[2, -1], [-3, 1]], [1, 2])

    def advantage(p):
        return form_pos.eval(p) - form_neg.eval(p)

    grid_res = 200
    x_range = np.linspace(-1, 4, grid_res)
    y_range = np.linspace(-1, 4, grid_res)
    X, Y = np.meshgrid(x_range, y_range)

    Z = np.zeros_like(X)
    for i in range(grid_res):
        for j in range(grid_res):
            Z[i, j] = advantage(np.array([X[i, j], Y[i, j]]))

    im = axes[0].contourf(X, Y, Z, levels=20, cmap='RdYlGn')
    axes[0].contour(X, Y, Z, levels=[0], colors='black', linewidths=2.5)
    plt.colorbar(im, ax=axes[0], label='Security Advantage')
    axes[0].set_title('Security Advantage Landscape', fontsize=14, fontweight='bold')
    axes[0].set_xlabel('Parameter $p_1$', fontsize=12)
    axes[0].set_ylabel('Parameter $p_2$', fontsize=12)

    # Mark certified region
    params = np.array([2.0, 1.5])
    m = advantage(params)
    L = (form_pos.lipschitz_l1() + form_neg.lipschitz_l1())
    r = m / L
    circle = Circle(params, r, fill=False, color='gold', linewidth=2.5, linestyle='--')
    axes[0].add_patch(circle)
    axes[0].plot(*params, 'k*', markersize=15, zorder=5)
    axes[0].annotate(f'Certified\nr={r:.3f}', params + np.array([0.15, 0.1]),
                     fontsize=10, fontweight='bold', color='gold')

    # Panel 2: Advantage along perturbation directions
    angles = np.linspace(0, 2 * np.pi, 8, endpoint=False)
    distances = np.linspace(0, 0.15, 100)

    for angle in angles:
        direction = np.array([np.cos(angle), np.sin(angle)])
        advs = [advantage(params + d * direction) for d in distances]
        axes[1].plot(distances, advs, alpha=0.6, linewidth=1.5)

    axes[1].axhline(y=0, color='red', linewidth=2, linestyle='--', label='Security boundary')
    axes[1].axvline(x=r, color='gold', linewidth=2, linestyle='--', label=f'Certified radius = {r:.3f}')
    axes[1].set_xlabel('Perturbation Distance', fontsize=12)
    axes[1].set_ylabel('Security Advantage', fontsize=12)
    axes[1].set_title('Advantage Along Perturbation Directions', fontsize=14, fontweight='bold')
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('fig_security.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = plot_chambers_and_classification()
    print(f"  fig_chambers.png generated ({len(b64_1)} chars base64)")
    b64_2 = plot_radius_scaling()
    print(f"  fig_scaling.png generated ({len(b64_2)} chars base64)")
    b64_3 = plot_security_stability()
    print(f"  fig_security.png generated ({len(b64_3)} chars base64)")
    print("Done!")

    # Save base64 strings for JSON package
    with open('viz_data.txt', 'w') as f:
        f.write("CHAMBERS\n")
        f.write(b64_1 + "\n")
        f.write("SCALING\n")
        f.write(b64_2 + "\n")
        f.write("SECURITY\n")
        f.write(b64_3 + "\n")
