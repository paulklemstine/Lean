# Future Directions: Quantum Phase Transitions via Lorentzian Geometry

## Synthesis

The five directions below form a coherent program extending the core discovery — that quantum sampling hardness has a geometric order parameter — along complementary axes. Direction 1 (mixed curvature) refines the invariant within the Lorentzian framework. Direction 2 (tropical geometry) connects to asymptotic combinatorics and dequantization. Direction 3 (tensor networks) extends the framework to the dominant paradigm in quantum simulation. Direction 4 (free probability) gives universal predictions for random instances. Direction 5 (experimental validation) closes the theory-experiment loop.

Together, these directions chart a path from a single formal theorem to a comprehensive geometric theory of quantum computational phase transitions.

---

## Direction 1: Mixed Lorentzian Curvature as a Sharper Hardness Invariant

**Conjecture:** The simple Lorentzian gap (second eigenvalue) is a coarse invariant. A refined *mixed curvature* tensor, capturing the full anisotropic structure of the Lorentzian region boundary, gives strictly tighter noise threshold predictions.

**The key insight is** that the Lorentzian region in matrix space is not a sphere — it has curvature that varies by direction. Perturbations along the "most dangerous" direction hit the boundary sooner than perturbations along "safe" directions. The mixed curvature tensor captures this directional information, yielding a certified threshold that depends on the noise *type*, not just its magnitude.

**Why now?** The formal infrastructure for the basic gap-based threshold is complete (Theorems 1–5). The eigendecomposition machinery is already in place. Extending to a tensor-valued invariant requires modest additional formalization.

**Test:** For n = 6 matching Hessians, compare:
- Gap-based certified threshold (current, isotropic)
- Curvature-based certified threshold (anisotropic, direction-dependent)
- Empirical threshold under structured (non-isotropic) perturbations

If the curvature-based threshold is strictly tighter for structured noise, the mixed curvature invariant is justified.

**Impact:** A tighter invariant directly translates to better noise budget allocation in photonic quantum computing experiments.

**Catalog References:**
- `Catalog/Pythagorean/QuantumPhaseTransition.lean`: `residual_gap_of_perturbation`, `exists_positive_algorithmic_radius`
- `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean`: `robust_quadform_negativity`

**Proof Strategy:** Define the mixed curvature tensor as the Hessian of the gap function on the space of symmetric matrices. Show it is computable from the eigendecomposition of A. Prove a directional stability theorem: the safe radius in direction E is gap / ‖E projected onto critical subspace‖.

**Domain Bridges:** Differential geometry (curvature of algebraic varieties) ↔ quantum information (directional noise analysis)

**Lineage:** Direct extension of Theorem 1 (positive radius). Replaces the isotropic radius with a directional one.

**Ambition:** ★★★☆☆ (Solid extension — refines existing invariant)

---

## Direction 2: Tropicalized Permanent Geometry and Dequantization Thresholds

**Conjecture:** The tropical limit of the Lorentzian stability radius for permanent-type polynomials converges to a combinatorial quantity — the *tropical matching distance* — that governs dequantization thresholds in the large-n limit.

**The key insight is** that tropical geometry replaces sums with maxima and products with sums, turning polynomial algebra into piecewise-linear combinatorics. The Lorentzian condition tropicalizes to a condition on the Newton polytope. The stability radius tropicalizes to a piecewise-linear distance from the polytope boundary.

**Why now?** Tropical methods have recently yielded breakthroughs in combinatorics (Adiprasito–Huh–Katz for log-concavity of matroids). The Lorentzian polynomial theory already has deep tropical connections (Brändén–Huh, Section 7). Our framework provides the algorithmic motivation to study the tropical stability radius.

**Test:** For K_n permanent polynomials:
1. Compute the Lorentzian stability radius (algebraic, real).
2. Compute the tropical stability radius (combinatorial, piecewise-linear).
3. Compare scaling as n → ∞.

If the two converge (after normalization), the tropical approximation is justified for large instances.

**Impact:** Tropical computations are polynomial-time even when the algebraic computations are exponential. A validated tropical approximation would extend the certified threshold computation to instances far beyond the reach of exact eigendecomposition.

**Catalog References:**
- `Catalog/Pythagorean/TropicalBridge/Defs.lean`, `Catalog/Pythagorean/TropicalBridge/Theorems.lean`
- `Catalog/Pythagorean/QuantumPhaseTransition.lean`: core definitions

**Proof Strategy:** Define the tropicalization of HasGappedSignature as a condition on the support of the polynomial. Show it is equivalent to a polyhedral containment condition. Prove that the tropical stability radius is a lower bound on the algebraic one.

**Domain Bridges:** Tropical geometry ↔ complexity theory (dequantization) ↔ combinatorial optimization

**Lineage:** Builds on the phase transition existence theorem (Theorem 4). Provides an asymptotic analysis tool.

**Ambition:** ★★★★☆ (Grand challenge — connects tropical geometry to quantum complexity)

---

## Direction 3: Tensor Network Analogues of Lorentzian Phase Boundaries

**Conjecture:** For quantum states represented as tensor networks (MPS, PEPS), there exists a Lorentzian-type condition on the bond tensor Hessians that controls the noise threshold for approximate classical simulation via tensor network contraction.

**The key insight is** that tensor network contraction is another paradigm where quantum sampling hardness is believed to persist until a critical noise level. The bond tensors play a role analogous to the amplitude polynomial Hessian. A "Lorentzian bond condition" would provide certified noise margins for tensor network quantum advantage.

**Why now?** Tensor network methods are the dominant classical simulation technique for quantum circuits. Recent work (Napp et al., 2022) establishes that noisy random circuits become classically simulable above a noise threshold. But no geometric characterization of this threshold exists. Our Lorentzian framework provides the conceptual template.

**Test:** For small MPS states (bond dimension 2–4, physical dimension 2):
1. Extract the Hessian of the amplitude function with respect to bond tensor entries.
2. Check if this Hessian has gapped Lorentzian signature.
3. Compute the stability radius and compare with the empirical noise threshold for classical simulability via bond dimension truncation.

**Impact:** Would extend the geometric phase transition framework from boson sampling to the general quantum circuit setting — the central arena for quantum advantage.

**Catalog References:**
- `Catalog/Pythagorean/QuantumPhaseTransition.lean`: `exists_positive_algorithmic_radius`, `negdef_quantum_proxy_robust`

**Proof Strategy:** Define the bond Hessian for an MPS. Show that for translational-invariant MPS with specific symmetries, the Hessian is negative definite (analogous to matching polynomial Hessians). Apply the cross-domain theorem.

**Domain Bridges:** Tensor networks ↔ Lorentzian geometry ↔ condensed matter physics

**Lineage:** Extension of Theorem 3 (cross-domain bridge) to tensor network amplitudes.

**Ambition:** ★★★★★ (Paradigm-shifting — unifies geometric phase transitions across quantum computing paradigms)

---

## Direction 4: Free Probability Limits of Stability Radii for Random Interferometers

**Conjecture:** For Haar-random unitary matrices of dimension n, the Lorentzian stability radius of the permanent-type Hessian concentrates around a deterministic value r*(n) = Θ(1/√n) as n → ∞, computable via free probability theory.

**The key insight is** that in the large-n limit, the eigenvalue distribution of random matrices is described by free probability (Voiculescu). The Lorentzian gap — which depends on the second-largest eigenvalue — can be analyzed via the free convolution of spectral distributions under perturbation. This gives a universal prediction for the noise threshold of random boson sampling instances.

**Why now?** Random matrix theory for permanents has advanced significantly (Jiang–Li, 2022). Free probability tools for spectral outliers (BBP transition) are mature. Our framework provides the missing link: a formal definition of "noise threshold" that connects to free probability spectral quantities.

**Test:** For random n × n unitary matrices (n = 10, 20, 50, 100):
1. Compute the permanent-type Hessian.
2. Compute the Lorentzian gap.
3. Normalize by √n.
4. Check concentration around a universal constant.

**Impact:** A universal threshold r*(n) = c/√n would provide a definitive answer to "how much noise can boson sampling tolerate?" for typical random instances — the experimentally relevant regime.

**Catalog References:**
- `Catalog/Pythagorean/QuantumPhaseTransition.lean`: `exists_critical_noise_value`

**Proof Strategy:** Use free probability to compute the limiting spectral distribution of the permanent Hessian for Haar-random unitaries. The gap is determined by the support of this distribution. Use free convolution to track how the gap changes under additive noise.

**Domain Bridges:** Free probability ↔ quantum information ↔ random matrix theory

**Lineage:** Asymptotic companion to Theorem 4 (phase transition existence). Gives the n → ∞ behavior.

**Ambition:** ★★★★☆ (Grand challenge — would give universal predictions for boson sampling noise thresholds)

---

## Direction 5: Experimental Validation Against Photonic Boson Sampling Data

**Conjecture:** For real boson sampling experiments (Zhong et al., 2020; Madsen et al., 2022), the certified Lorentzian threshold predicts a lower bound on the noise level at which statistical tests of quantum advantage begin to fail.

**The key insight is** that our framework makes predictions that are directly testable against experimental data. The Lorentzian gap of the actual interferometer matrix (measured via tomography) gives a certified noise budget. If the measured noise exceeds this budget, our theory predicts that quantum advantage is lost — and this prediction can be checked against the statistical tests used to validate the experiment.

**Why now?** Large-scale boson sampling experiments have been performed (up to ~200 photons). Interferometer matrices are characterized experimentally. Our Lean-verified bounds provide rigorous, machine-checked lower bounds with no ambiguity.

**Test:**
1. Obtain the interferometer matrix from published boson sampling experiments.
2. Compute the Lorentzian gap and certified threshold.
3. Compare with the estimated noise in the experiment (from the published characterization).
4. Check whether the noise is below (quantum advantage preserved) or above (advantage questionable) the certified threshold.

**Impact:** Would demonstrate that pure mathematical reasoning about polynomial geometry produces experimentally testable predictions about quantum hardware. This is the strongest possible validation of the program.

**Catalog References:**
- `Catalog/Pythagorean/QuantumPhaseTransition.lean`: all main theorems
- `Catalog/Bridges/Catalog/Pythagorean/RobustLorentzianSampling.lean`: full pipeline

**Proof Strategy:** No new proofs needed — this is an application of existing theorems to experimental data. The key challenge is data access and noise model matching.

**Domain Bridges:** Formal mathematics ↔ experimental quantum optics ↔ statistical validation

**Lineage:** Application of Theorems 1, 3, and the certified estimation algorithm.

**Ambition:** ★★★☆☆ (Solid extension — closes the theory-experiment loop)
