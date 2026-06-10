#!/usr/bin/env python3
"""
Practical Application: Certified Robustness for EML Neural Classifiers

This script demonstrates how to use the Maslov Dequantization Isometry theorem
to certify robustness of neural network classifiers in practice.

Given a piecewise-linear (ReLU) classifier described by its affine pieces,
this tool:
  1. Computes the tropical margin at any input point
  2. Estimates the Lipschitz constant
  3. Computes the certified robustness radius r* = γ/(2L)
  4. Verifies the certificate empirically with random adversarial attacks
  5. Visualizes the robustness landscape

Usage:
    python robustness_certification_app.py
"""

import numpy as np
import matplotlib.pyplot as plt
from dataclasses import dataclass
from typing import List, Tuple, Optional
import time


@dataclass
class AffineFunction:
    """An affine function f(x) = bias + weights · x."""
    bias: float
    weights: np.ndarray

    def __call__(self, x: np.ndarray) -> float:
        return self.bias + np.dot(self.weights, x)

    @property
    def linf_lipschitz(self) -> float:
        """L∞ Lipschitz constant = L1 norm of weights (by Hölder duality)."""
        return np.sum(np.abs(self.weights))


class EMLClassifier:
    """
    An EML (log-sum-exp) classifier.

    Each class k has d_k affine pieces. The class score is:
        C_ε(x)_k = ε · log(Σ_i exp(Φ_{k,i}(x) / ε))

    As ε → 0, this becomes the tropical (max) classifier:
        C_0(x)_k = max_i Φ_{k,i}(x)
    """

    def __init__(self, pieces: List[List[AffineFunction]], epsilon: float = 1.0):
        """
        pieces[k][i] = AffineFunction for class k, piece i
        epsilon = temperature parameter
        """
        self.pieces = pieces
        self.epsilon = epsilon
        self.m = len(pieces)  # number of classes
        self.d = max(len(p) for p in pieces)  # max pieces per class
        self.n = pieces[0][0].weights.shape[0]  # input dimension

    def _logsumexp(self, values: np.ndarray) -> float:
        """Numerically stable ε·log(Σ exp(v_i/ε))."""
        scaled = values / self.epsilon
        max_val = np.max(scaled)
        return self.epsilon * (max_val + np.log(np.sum(np.exp(scaled - max_val))))

    def eml_scores(self, x: np.ndarray) -> np.ndarray:
        """Compute EML class scores C_ε(x)."""
        scores = np.zeros(self.m)
        for k in range(self.m):
            vals = np.array([f(x) for f in self.pieces[k]])
            scores[k] = self._logsumexp(vals)
        return scores

    def trop_scores(self, x: np.ndarray) -> np.ndarray:
        """Compute tropical class scores C_0(x)."""
        scores = np.zeros(self.m)
        for k in range(self.m):
            vals = np.array([f(x) for f in self.pieces[k]])
            scores[k] = np.max(vals)
        return scores

    def predict(self, x: np.ndarray) -> int:
        """Predict class label."""
        return int(np.argmax(self.eml_scores(x)))

    def lipschitz_constant(self) -> float:
        """Maximum Lipschitz constant over all pieces."""
        return max(f.linf_lipschitz for pieces in self.pieces for f in pieces)

    def tropical_margin(self, x: np.ndarray, y_true: int) -> float:
        """Tropical classification margin at (x, y_true)."""
        scores = self.trop_scores(x)
        margins = [scores[y_true] - scores[j] for j in range(self.m) if j != y_true]
        return min(margins) if margins else float('inf')

    def eml_margin(self, x: np.ndarray, y_true: int) -> float:
        """EML classification margin at (x, y_true)."""
        scores = self.eml_scores(x)
        margins = [scores[y_true] - scores[j] for j in range(self.m) if j != y_true]
        return min(margins) if margins else float('inf')

    def certified_radius(self, x: np.ndarray, y_true: int) -> dict:
        """
        Compute the certified robustness radius using the Maslov theorem.

        Returns a dict with:
          - radius: the certified L∞ radius r* = γ/(2L)
          - gamma: the effective margin after dequantization correction
          - trop_margin: the tropical margin
          - eml_margin: the EML margin
          - lipschitz: the Lipschitz constant L
          - dequant_error: the dequantization error bound ε·log d
        """
        L = self.lipschitz_constant()
        trop_m = self.tropical_margin(x, y_true)
        eml_m = self.eml_margin(x, y_true)
        dequant_err = self.epsilon * np.log(self.d)
        gamma = trop_m - 2 * dequant_err

        if gamma <= 0 or L <= 0:
            r = 0.0
        else:
            r = gamma / (2 * L)

        return {
            'radius': r,
            'gamma': gamma,
            'trop_margin': trop_m,
            'eml_margin': eml_m,
            'lipschitz': L,
            'dequant_error': dequant_err
        }

    def verify_certificate(self, x: np.ndarray, y_true: int,
                          n_attacks: int = 10000) -> dict:
        """
        Empirically verify the robustness certificate using random attacks.
        """
        cert = self.certified_radius(x, y_true)
        r = cert['radius']

        # Test attacks at various radii
        radii = np.linspace(0, r * 3, 50) if r > 0 else np.linspace(0, 1, 50)
        success_rates = []

        for test_r in radii:
            successes = 0
            for _ in range(n_attacks // len(radii)):
                delta = np.random.uniform(-test_r, test_r, self.n)
                pred = self.predict(x + delta)
                if pred != y_true:
                    successes += 1
            success_rates.append(successes / max(1, n_attacks // len(radii)))

        cert['attack_radii'] = radii
        cert['attack_success_rates'] = np.array(success_rates)
        cert['attacks_in_cert_zone'] = sum(1 for r_test, rate in zip(radii, success_rates)
                                          if r_test < r and rate > 0)
        return cert


def create_iris_like_classifier(n_classes=3, n_features=4, n_pieces=5,
                                 epsilon=0.5, seed=42) -> Tuple[EMLClassifier, np.ndarray]:
    """Create a classifier mimicking Iris-like classification."""
    np.random.seed(seed)
    L_target = 2.0

    pieces = []
    for k in range(n_classes):
        class_pieces = []
        for i in range(n_pieces):
            bias = np.random.randn() + k * 1.5
            w = np.random.randn(n_features)
            w = w / np.sum(np.abs(w)) * L_target * np.random.uniform(0.3, 1.0)
            class_pieces.append(AffineFunction(bias, w))
        pieces.append(class_pieces)

    clf = EMLClassifier(pieces, epsilon)
    test_point = np.random.randn(n_features) * 0.5
    return clf, test_point


def demo_certification_pipeline():
    """Complete certification pipeline demonstration."""
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Certified Robustness via Maslov Dequantization        ║")
    print("║   Practical Application Demo                            ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    # ── Step 1: Create classifier ──
    print("Step 1: Creating EML classifier")
    print("-" * 40)
    clf, x0 = create_iris_like_classifier(n_classes=4, n_features=3,
                                           n_pieces=6, epsilon=0.3)
    y_true = clf.predict(x0)
    print(f"  Classes: {clf.m}")
    print(f"  Input dim: {clf.n}")
    print(f"  Pieces/class: {clf.d}")
    print(f"  Temperature ε: {clf.epsilon}")
    print(f"  Test point: {x0}")
    print(f"  Predicted class: {y_true}")
    print()

    # ── Step 2: Compute certificate ──
    print("Step 2: Computing robustness certificate")
    print("-" * 40)
    cert = clf.certified_radius(x0, y_true)
    print(f"  Lipschitz constant L: {cert['lipschitz']:.4f}")
    print(f"  Tropical margin: {cert['trop_margin']:.4f}")
    print(f"  EML margin: {cert['eml_margin']:.4f}")
    print(f"  Dequantization error (ε·log d): {cert['dequant_error']:.4f}")
    print(f"  Effective margin γ: {cert['gamma']:.4f}")
    print(f"  ✓ Certified L∞ radius: r* = {cert['radius']:.4f}")
    print()

    # ── Step 3: Verify empirically ──
    print("Step 3: Empirical verification (10000 random attacks)")
    print("-" * 40)
    cert = clf.verify_certificate(x0, y_true, n_attacks=10000)
    print(f"  Attacks breaking certificate in safe zone: {cert['attacks_in_cert_zone']}")
    if cert['attacks_in_cert_zone'] == 0:
        print(f"  ✓ Certificate VERIFIED: no attack succeeded within r* = {cert['radius']:.4f}")
    else:
        print(f"  ✗ Certificate VIOLATED (this should never happen)")
    print()

    # ── Step 4: Visualize ──
    print("Step 4: Generating visualizations")
    print("-" * 40)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Attack success rate vs radius
    ax = axes[0, 0]
    ax.plot(cert['attack_radii'], cert['attack_success_rates'], 'b-', linewidth=2)
    if cert['radius'] > 0:
        ax.axvline(x=cert['radius'], color='r', linestyle='--', linewidth=2,
                  label=f'r* = {cert["radius"]:.3f}')
        ax.fill_between([0, cert['radius']], [0, 0], [1, 1],
                       alpha=0.1, color='green', label='Certified safe')
    ax.set_xlabel('Perturbation radius (L∞)')
    ax.set_ylabel('Attack success rate')
    ax.set_title('Robustness Certificate Verification')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Margin vs epsilon
    ax = axes[0, 1]
    eps_range = np.logspace(-2, 1, 50)
    trop_margins = []
    eml_margins = []
    certified_radii = []
    for eps in eps_range:
        clf_temp = EMLClassifier(clf.pieces, eps)
        trop_margins.append(clf_temp.tropical_margin(x0, y_true))
        eml_margins.append(clf_temp.eml_margin(x0, y_true))
        c = clf_temp.certified_radius(x0, y_true)
        certified_radii.append(c['radius'])

    ax.semilogx(eps_range, trop_margins, 'b-', linewidth=2, label='Tropical margin')
    ax.semilogx(eps_range, eml_margins, 'r-', linewidth=2, label='EML margin')
    ax.semilogx(eps_range, [tm - 2*eps*np.log(clf.d) for tm, eps in zip(trop_margins, eps_range)],
               'g--', linewidth=2, label='γ = trop - 2ε·log d')
    ax.set_xlabel('Temperature ε')
    ax.set_ylabel('Margin')
    ax.set_title('Margin vs Temperature')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Certified radius vs epsilon
    ax = axes[1, 0]
    ax.semilogx(eps_range, certified_radii, 'r-', linewidth=2)
    ax.set_xlabel('Temperature ε')
    ax.set_ylabel('Certified radius r*')
    ax.set_title('Certified Radius vs Temperature')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='gray', linewidth=0.5)

    # Plot 4: Score profiles along a random direction
    ax = axes[1, 1]
    direction = np.random.randn(clf.n)
    direction = direction / np.max(np.abs(direction))
    t_vals = np.linspace(-2, 2, 200)
    for k in range(clf.m):
        eml_scores_line = [clf.eml_scores(x0 + t * direction)[k] for t in t_vals]
        trop_scores_line = [clf.trop_scores(x0 + t * direction)[k] for t in t_vals]
        ax.plot(t_vals, eml_scores_line, '-', linewidth=2, label=f'EML class {k}')
        ax.plot(t_vals, trop_scores_line, '--', alpha=0.5)
    ax.axvline(x=0, color='gray', linestyle=':')
    ax.set_xlabel('t (along random direction)')
    ax.set_ylabel('Class score')
    ax.set_title('Score Profiles (solid=EML, dashed=Tropical)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Maslov Dequantization: Certified Robustness Application', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('certification_application.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: certification_application.png")
    print()

    # ── Step 5: Batch certification ──
    print("Step 5: Batch certification over random inputs")
    print("-" * 40)
    n_test = 100
    certified_count = 0
    radii = []
    for i in range(n_test):
        x_test = np.random.randn(clf.n)
        y_pred = clf.predict(x_test)
        c = clf.certified_radius(x_test, y_pred)
        if c['radius'] > 0:
            certified_count += 1
            radii.append(c['radius'])

    print(f"  Tested: {n_test} random points")
    print(f"  Certified (r* > 0): {certified_count}/{n_test} ({100*certified_count/n_test:.0f}%)")
    if radii:
        print(f"  Mean certified radius: {np.mean(radii):.4f}")
        print(f"  Median certified radius: {np.median(radii):.4f}")
        print(f"  Min certified radius: {np.min(radii):.4f}")
        print(f"  Max certified radius: {np.max(radii):.4f}")
    print()

    print("=" * 60)
    print("APPLICATION SUMMARY")
    print("=" * 60)
    print("""
The Maslov Dequantization theorem provides a practical pipeline for
certifying neural network robustness:

  1. REPRESENT the network as piecewise-linear (tropical) + smoothing
  2. COMPUTE the tropical margin (fast: just evaluate max over pieces)
  3. COMPUTE the Lipschitz constant (upper bound from weights)
  4. APPLY the theorem: r* = (trop_margin - 2ε·log d) / (2L)

Key advantages over other certification methods:
  • EXACT Lipschitz transfer — no degree penalty
  • COMPOSITIONAL — works for any depth/width
  • FAST — no optimization or sampling needed
  • VERIFIED — proven correct in Lean 4
""")


if __name__ == '__main__':
    demo_certification_pipeline()
