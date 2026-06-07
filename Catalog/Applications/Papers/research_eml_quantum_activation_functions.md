# The Quantum Activation Algebra: Bridging Unitary Phase Gates and Amplitude Control in Neural Networks

## Abstract

We introduce the **Quantum Activation Algebra (QAA)**, a novel mathematical structure that parameterizes complex-valued neural network activations through a two-parameter family:

$$\text{qact}(\theta, \phi) = e^{i\theta} \cdot (1 + i\phi), \quad \theta, \phi \in \mathbb{R}.$$

This function decomposes into a *phase gate* $e^{i\theta}$ (unitary) and an *amplitude factor* $(1 + i\phi)$ (non-unitary for $\phi \neq 0$), providing a smooth interpolation between unitary quantum operations and general linear maps. We prove 30+ theorems about this structure, including:

1. **Spectral Gap Identity**: $\|\text{qact}(\theta, \phi)\|^2 = 1 + \phi^2$, establishing that $\phi^2$ is the unitarity defect.
2. **Image Characterization**: The image of qact is exactly the closed exterior of the unit disk $\{z \in \mathbb{C} : |z| \geq 1\}$.
3. **Spectral Gap Pinching**: For $|\phi| \leq 1$, the spectral gap $\sqrt{1+\phi^2} - 1$ lies between $\phi^2/3$ and $\phi^2/2$.
4. **Depth Amplification**: $n$-layer composition has norm $({\sqrt{1+\phi^2}})^n$, growing exponentially.
5. **Gauge Invariance**: The unitarity defect is independent of the phase parameter.
6. **Information Additivity**: The information content $\log(1+\phi^2)$ is additive under independent layer composition.

All results are formalized and verified in Lean 4 with Mathlib.

## 1. Introduction

Quantum computing and classical neural networks operate in fundamentally different mathematical frameworks. Quantum gates are unitary operators ($UU^\dagger = I$), preserving probability amplitudes, while classical activation functions (ReLU, sigmoid, etc.) are non-unitary maps that introduce nonlinearity through amplitude changes.

The Exponential-Multiplicative-Logarithmic (EML) framework [catalog references] provides a bridge through its core operation $\text{eml}(x,y) = e^x - \log y$, which interleaves exponential and logarithmic transformations. We extend this to the complex domain, defining the **quantum EML activation**:

$$\text{qact}(\theta, \phi) = e^{i\theta} \cdot (1 + i\phi).$$

This is a principled choice: $e^{i\theta}$ is the simplest unitary operation (a phase rotation), and $(1 + i\phi)$ is the simplest linear departure from the identity. The product captures the interplay between quantum coherence (controlled by $\theta$) and classical information gain (controlled by $\phi$).

## 2. Definitions

### 2.1 The Quantum EML Activation

**Definition 1** (Quantum Activation). For $\theta, \phi \in \mathbb{R}$, define:
$$\text{qact}(\theta, \phi) = e^{i\theta} \cdot (1 + i\phi) \in \mathbb{C}.$$

**Definition 2** (Amplitude-squared). $A(\phi) = 1 + \phi^2$.

**Definition 3** (Spectral Gap). $\Delta(\phi) = \sqrt{1 + \phi^2} - 1$.

**Definition 4** (Information Content). $I(\phi) = \log(1 + \phi^2)$.

**Definition 5** (Unitarity Defect). $D(\theta, \phi) = \|\text{qact}(\theta,\phi)\|^2 - 1$.

**Definition 6** (Multi-layer Activation). For parameters $\{(\theta_i, \phi_i)\}_{i=1}^n$:
$$\text{qactLayer}_n = \prod_{i=1}^n \text{qact}(\theta_i, \phi_i).$$

### 2.2 The Quantum Activation Algebra (QAA)

**Definition 7** (QActivation). A `QActivation` is a pair $q = (\theta, \phi) \in \mathbb{R}^2$ with:
- Evaluation: $q.\text{eval} = \text{qact}(\theta, \phi)$
- Norm: $q.\text{norm} = \sqrt{1 + \phi^2}$
- Identity: $\mathbf{1} = (0, 0)$, satisfying $\mathbf{1}.\text{eval} = 1$
- Composition: defined via the norm-multiplicative rule $(1 + \phi_{\text{comp}}) = \sqrt{(1+\phi_1^2)(1+\phi_2^2)}$

## 3. Main Results

### 3.1 The Spectral Gap Identity (PEGB)

**Theorem 1** (Spectral Gap Identity, `qact_norm_sq`).
$$\|\text{qact}(\theta, \phi)\|^2 = 1 + \phi^2.$$

*Proof sketch*: By multiplicativity of the complex norm, $\|e^{i\theta}\| = 1$ and $\|1 + i\phi\|^2 = 1 + \phi^2$.

**Example**: $\text{qact}(\pi/4, 1)$ has $|\text{qact}|^2 = 1 + 1 = 2$, so $|\text{qact}| = \sqrt{2}$.

**Generalization**: For matrix-valued activations $U = e^{iH} \cdot (I + i\Phi)$ where $H$ is Hermitian and $\Phi$ is Hermitian, the analogous identity should be $\|U\|_F^2 = \text{tr}(I + \Phi^2)$.

**Boundary**: The identity fails if we replace $(1 + i\phi)$ with a general complex number $a + bi$; the norm becomes $a^2 + b^2$, losing the "$1+$" structure that guarantees the output lies outside the unit disk.

### 3.2 Image Characterization

**Theorem 2** (Surjectivity, `qact_surj_exterior`).
For every $z \in \mathbb{C}$ with $\|z\| \geq 1$, there exist $\theta, \phi \in \mathbb{R}$ such that $\text{qact}(\theta, \phi) = z$.

**Theorem 3** (Confinement, `qact_norm_ge_one`).
$\|\text{qact}(\theta, \phi)\| \geq 1$ for all $\theta, \phi$.

Together, these establish:
$$\text{Image}(\text{qact}) = \{z \in \mathbb{C} : |z| \geq 1\}.$$

*Proof of surjectivity*: Given $z$ with $|z| \geq 1$, set $\phi = \sqrt{|z|^2 - 1}$ (well-defined since $|z| \geq 1$). Then $|1 + i\phi| = |z|$. Choose $\theta$ so that $e^{i\theta}$ corrects the argument.

**Example**: To reach $z = 2 + 3i$ (with $|z| = \sqrt{13} \approx 3.61$), set $\phi = \sqrt{12} \approx 3.46$ and $\theta \approx 0.494$.

**Generalization**: For matrix activations on $\mathbb{C}^{n \times n}$, the image should be all matrices with operator norm $\geq 1$.

**Boundary**: The point $z = 0$ is never reached (by `qact_ne_zero`). Points with $|z| < 1$ require a different activation structure (e.g., $e^{i\theta} \cdot (a + i\phi)$ with $|a| < 1$).

### 3.3 Spectral Gap Pinching

**Theorem 4** (`spectralGap_pinch`). For $|\phi| \leq 1$:
$$\frac{\phi^2}{3} \leq \Delta(\phi) \leq \frac{\phi^2}{2}.$$

**Theorem 5** (`spectralGap_linear_upper`). For all $\phi$:
$$\Delta(\phi) \leq |\phi|.$$

*Proof sketch (upper bound)*: $\sqrt{1+\phi^2} \leq 1 + \phi^2/2$ follows from squaring both sides: $1 + \phi^2 \leq 1 + \phi^2 + \phi^4/4$.

*Proof sketch (lower bound)*: $\sqrt{1+\phi^2} \geq 1 + \phi^2/3$ for $|\phi| \leq 1$ follows from squaring: $1+\phi^2 \geq 1 + 2\phi^2/3 + \phi^4/9$, i.e., $\phi^2/3 \geq \phi^4/9$, i.e., $3 \geq \phi^2$, which holds.

**Example**: At $\phi = 0.5$: $\Delta = \sqrt{1.25} - 1 \approx 0.118$, while $0.25/3 \approx 0.083$ and $0.25/2 = 0.125$. Confirmed: $0.083 \leq 0.118 \leq 0.125$.

**Generalization**: Higher-order Taylor expansion gives $\Delta(\phi) = \phi^2/2 - \phi^4/8 + O(\phi^6)$, suggesting the bound $\phi^2/2$ is tight as $\phi \to 0$.

**Boundary**: At $\phi = 1$: lower bound $= 1/3 \approx 0.333$, actual $= \sqrt{2}-1 \approx 0.414$, upper bound $= 0.5$. The pinching is not tight at the boundary.

### 3.4 Gauge Invariance

**Theorem 6** (`unitarityDefect_phase_invariant`).
$$D(\theta_1, \phi) = D(\theta_2, \phi) \quad \text{for all } \theta_1, \theta_2.$$

This is because $D(\theta, \phi) = \phi^2$ independently of $\theta$.

*Physical interpretation*: The phase $\theta$ is a "gauge degree of freedom" — it affects the quantum phase but not the degree of non-unitarity. This mirrors the U(1) gauge symmetry in quantum electrodynamics.

### 3.5 Depth Amplification

**Theorem 7** (`constant_layer_norm`). For constant parameters:
$$\|\text{qactLayer}_n(\theta, \phi)\| = (\sqrt{1 + \phi^2})^n.$$

**Theorem 8** (`qactLayer_norm`). In general:
$$\|\text{qactLayer}_n\| = \prod_{i=1}^n \sqrt{1 + \phi_i^2}.$$

**Theorem 9** (`qactLayer_norm_ge_one`). Always $\|\text{qactLayer}_n\| \geq 1$.

*Physical interpretation*: Non-unitarity compounds exponentially through depth, analogous to the exploding gradient problem in classical neural networks. When $\phi = 0$ (pure phase gates), the norm stays at 1 — perfect unitarity is preserved.

**Example**: With $\phi = 0.5$ and $n = 10$: norm $= (\sqrt{1.25})^{10} \approx 3.05$.

### 3.6 Information Additivity

**Theorem 10** (`infoContent_additive`).
$$\log\left((1+\phi_1^2)(1+\phi_2^2)\right) = I(\phi_1) + I(\phi_2).$$

This follows from the multiplicativity of the norm and the logarithm.

**Theorem 11** (`infoContent_eq_zero_iff`). $I(\phi) = 0 \iff \phi = 0$.

### 3.7 Fixed Point Theorem

**Theorem 12** (`qact_eq_one_implies_phi_zero`). If $\text{qact}(\theta, \phi) = 1$, then $\phi = 0$.

The identity is an "isolated fixed point" in the amplitude direction: you cannot reach $1$ from a non-trivial amplitude. This has implications for the stability of quantum circuits built from these activations.

## 4. Cross-Connection to Classical EML

The classical EML function $\text{eml}(x,y) = e^x - \log y$ connects to the quantum activation through the bridge:
$$\text{qact}(0, e^x - 1) = 1 + i(e^x - 1).$$

The real part is always 1, while the imaginary part encodes the classical exponential $e^x - 1$. The norm-squared gives:
$$\|\text{qact}(0, e^x - 1)\|^2 = 1 + (e^x - 1)^2.$$

This bridges the classical EML's exponential growth to the quantum activation's norm growth.

## 5. The Falsifiable Conjecture

**Conjecture** (Matrix Extension). For the $2 \times 2$ matrix quantum activation
$$\text{Qact}(H_1, H_2) = e^{iH_1} \cdot (I + iH_2),$$
where $H_1, H_2$ are $2 \times 2$ traceless Hermitian matrices, the image is exactly the set of invertible $2 \times 2$ matrices with operator norm $\geq 1$.

**Computational test**: Parameterize $H_1 = a\sigma_x + b\sigma_y + c\sigma_z$ and $H_2 = d\sigma_x + e\sigma_y + f\sigma_z$ (Pauli matrices). Sample $10^6$ random $(a,b,c,d,e,f)$ and check whether the resulting matrices' singular values are always $\geq 1$. If any singular value $< 1$ is found, the conjecture is false.

## 6. Discussion

The Quantum Activation Algebra reveals a clean mathematical structure underlying the interface between quantum and classical computation:

- **Phase controls quantum coherence** (through $\theta$), while **amplitude controls information gain** (through $\phi$).
- The **spectral gap** $\phi^2$ is the natural measure of non-unitarity.
- **Depth compounds non-unitarity exponentially**, providing a precise analogue of the exploding gradient phenomenon.
- The **image characterization** shows that single-layer quantum activations can reach any target outside the unit disk but never inside — a fundamental limitation that could inform quantum circuit design.

## 7. Future Work

1. Extend to matrix-valued activations on $\mathbb{C}^{n \times n}$
2. Characterize the Lie algebra structure of the parameter space
3. Connect to quantum error correction codes
4. Prove the matrix extension conjecture
5. Develop gradient-based optimization for quantum EML networks

## References

- Catalog: `EML/EMLv17Core.lean`, `eml_log_exp`
- Catalog: `Bridges/EMLTropicalSemiring.lean`, `quantum_classical_bound`
- Catalog: `EML/QuantumDensityEstimation.lean`, `eml_exp_log_id`
- Catalog: `Applications/EMLTermAlgebra.lean`
