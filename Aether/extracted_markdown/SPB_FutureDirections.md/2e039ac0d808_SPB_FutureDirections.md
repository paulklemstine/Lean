# SPB-EML Future Research Directions: An Updated Roadmap

## A Prioritized Research Agenda with Feasibility Assessment

**Version: April 2026 — Post-Verification Update**

---

## Executive Summary

Building on a foundation of 100+ machine-verified theorems in Lean 4 (including 28 new results from the latest verification campaign), we present an updated and expanded research roadmap for the Stereographic Projection Bridge (SPB) and Exponential-Multiplicative-Logarithmic (EML) framework. The roadmap is organized into four tiers (A–D) by feasibility and impact, with eight **newly enabled** research directions made possible by the latest results.

### Key New Results That Enable Future Work

| New Result | What It Opens | Primary Impact Area |
|-----------|---------------|-------------------|
| Cross-ratio invariance | Möbius group membership confirmed | Cryptography, conformal geometry |
| Elliptic classification | No-fixed-point proof | Dynamical systems, ergodic theory |
| Projective SPB + norm mult. | Division-free computation | CORDIC hardware, FPGA |
| Infinitesimal generator | V(x)=1+x² generates flow | Stochastic processes, Kalman filters |
| Brahmagupta–Fibonacci | SPB norm = Gaussian norm | Division algebra conjecture |
| Cocycle 2-cocycle property | Group cohomology triviality | Series acceleration, algebraic K-theory |
| Hyperbolic contraction | Einstein velocity closure | Relativistic physics, Lorentz geometry |
| Cauchy pullback identity | Density transformation law | Information geometry, robust statistics |

---

## 1. Tier A: High Feasibility, High Impact — Immediate Priorities

### A1. SPB Neural Networks for Periodic Regression

**Status:** READY TO IMPLEMENT

**Foundation:** The infinitesimal generator theorem (V(x) = 1 + x²) provides the linearization needed for stable training. The derivative formula ∂spb/∂x = (1+y²)/(1-xy)² enables custom backward passes. The Cauchy pullback identity confirms the natural noise model.

**Concrete Experiment Design:**
1. Implement `SPBNeuron(x; w) = spb(w₁x₁, spb(w₂x₂, ...))` in PyTorch/JAX
2. Custom backward pass using the verified gradient formula
3. Benchmarks:
   - Fourier series fitting (5, 10, 20 harmonics)
   - Seasonal time series (temperature, electricity demand)
   - Phase estimation from noisy sinusoids
   - Direction-of-arrival estimation in array signal processing
4. Baselines: MLP, LSTM, Transformer, Fourier Neural Operator
5. Metrics: MSE, training speed, generalization to unseen frequencies

**New Insight:** The Cauchy distribution is the natural noise model for SPB neurons. SPB networks may be inherently robust to heavy-tailed noise — a significant advantage in radar, sonar, and financial applications where Gaussian assumptions fail.

**Key Open Questions:**
- What is the sample complexity of learning periodic functions with SPB trees?
- Does the SPB activation function prevent vanishing/exploding gradients?
- How does the VC dimension of depth-n SPB trees compare to standard ReLU networks?

**Expected Outcome:** 10–30% improvement on periodic tasks; built-in heavy-tail robustness.
**Timeline:** 2–3 months. **Team:** 1 ML researcher + GPU cluster.

---

### A2. SPB-CORDIC Hardware with Projective Coordinates

**Status:** READY TO IMPLEMENT

**Foundation:** Projective SPB eliminates division: [x₁:x₂] ⊕ [y₁:y₂] = [x₁y₂ + x₂y₁ : x₂y₂ − x₁y₁]. Requires only 4 multiplications and 2 additions. Norm multiplicativity (x₁²+x₂²)(y₁²+y₂²) = result₁² + result₂² verified.

**Implementation Plan:**
1. Design projective SPB arithmetic unit in Verilog/VHDL
2. Pipeline: two parallel multiply stages → add/subtract stage (2 cycles vs 3 for standard)
3. Implement affine-to-projective and projective-to-affine conversion units
4. Compare latency and area against standard CORDIC on Xilinx/Intel FPGA
5. Target: 16-bit and 32-bit fixed-point precision

**Cocycle Acceleration:** For small xy, use truncated geometric series:
1/(1-xy) ≈ 1 + xy + (xy)² (2 terms: O((xy)³) error)

**Expected Outcome:** 25–35% latency reduction per CORDIC iteration.
**Timeline:** 3–4 months. **Team:** 1 digital design engineer.

---

### A3. SPB Diffie-Hellman Prototype

**Status:** READY TO IMPLEMENT

**Foundation:** Cross-ratio invariance confirms SPB is a Möbius transformation. The SPB DLP reduces to standard DLP via arctan. The p±1 law is computationally verified.

**Protocol:**
1. Public: prime p, generator g ∈ 𝔽ₚ
2. Alice: random a, computes A = spb^a(g) mod p
3. Bob: random b, computes B = spb^b(g) mod p
4. Shared secret: spb^a(B) = spb^{a+b}(g) = spb^b(A)

**Security Analysis:**
- For p ≡ 3 (mod 4): group order p+1 (slightly larger than standard p−1)
- For p ≡ 1 (mod 4): group order p−1 (same as standard)
- Hardness: equivalent to standard DH for same-size primes

**Open Research Questions:**
- Can the p+1 group order provide advantages for specific prime choices?
- Is there a Pollard rho analogue for the SPB DLP?
- Can SPB-DH be combined with lattice-based methods for post-quantum security?

**Timeline:** 2–3 months. **Team:** 1 cryptography researcher.

---

### A4. SPB Kalman Filter for IMU Sensor Fusion

**Status:** READY TO IMPLEMENT

**Foundation:** The infinitesimal generator gives the continuous-time model:
dθ/dt = (1 + θ²) · ω, where θ = tan(angle/2) and ω is angular velocity.

**State Update:**
θ̂ₖ = spb(θ̂_{k-1|k-1}, Kₖ · (θ_meas − θ̂_{k-1|k-1}))

**Key Advantages:**
- No angle wrapping discontinuity
- Cauchy noise model (naturally robust to outliers)
- Closed-form Jacobian for the extended Kalman filter

**Experiment Design:**
1. Simulate 9-axis IMU with known ground truth
2. Include large angular changes (somersaults, 360° rotations)
3. Compare: standard EKF with wrapping, quaternion EKF, SPB Kalman filter
4. Metrics: RMS error, convergence speed, robustness to initialization
5. Real-data validation with MPU-9250 sensor

**Timeline:** 2–3 months. **Team:** 1 controls engineer.

---

### A5. SPB Phase Estimation (Signal Processing)

**Status:** READY TO IMPLEMENT

**Foundation:** SPB natively operates on the tangent parameterization of angles. Phase differences are computed directly by spb(tan φ₁, −tan φ₂).

**Applications:**
- Radar Doppler phase tracking
- Array signal processing (direction of arrival)
- Optical interferometry
- Communications (carrier phase recovery)

**Key Advantage:** No phase unwrapping needed. Works natively on ℝ via stereographic projection.

**Timeline:** 2–3 months. **Team:** 1 signal processing researcher.

---

### A6. Cauchy Robust Statistics via SPB (NEW)

**Status:** NEWLY ENABLED by Cauchy pullback identity

**Motivation:** The verified identity (1 + spb(x,a)²)·(1−xa)² = (1+x²)(1+a²) proves that SPB translations preserve the Cauchy family. This is the *defining property* of a location family, making SPB the natural group action for Cauchy statistical models.

**Research Plan:**
1. Derive the maximum likelihood estimator for location in the SPB parameterization
2. Compare efficiency with trimmed mean, median, and Huber M-estimators
3. Apply to financial returns data (known to be heavy-tailed)
4. Develop SPB-equivariant confidence intervals

**Expected Outcome:** New robust estimators with natural geometric structure.
**Timeline:** 3–4 months. **Team:** 1 statistician.

---

## 2. Tier B: Medium Feasibility, High Impact — Next Phase

### B1. SPB Approximation Theory

**Status:** PARTIALLY FORMALIZED

**Key Question:** What class of functions do SPB trees of depth n approximate?

**Known:** Under x = tan(θ/2), an SPB tree of depth n produces tan(P(θ)) where P is a trigonometric polynomial of degree ≤ 2^{n−1}.

**Research Plan:**
1. Prove the degree bound formally (skeleton exists)
2. Implement best SPB tree fitting via nonlinear optimization
3. Compare: SPB tree (depth n) vs Chebyshev (degree 2^{n−1}) vs Padé
4. Test functions: Runge, |x|, step function, sawtooth wave

**Conjecture:** SPB trees achieve the optimal approximation rate O(ω(f, 2^{−n})) for continuous periodic functions, matching Chebyshev with better numerical stability.

**Timeline:** 4–6 months.

---

### B2. Information Geometry of the Cauchy Family

**Status:** NEWLY ENABLED by infinitesimal generator + Cauchy pullback

**Goal:** Prove that SPB translations are isometries of the Fisher information metric on {C(μ, 1)}.

**Building Blocks (All Verified):**
- Cauchy pullback identity: (1 + spb(x,a)²)(1−xa)² = (1+x²)(1+a²)
- Infinitesimal generator V(x) = 1 + x²
- Generator positivity: 1 + x² > 0

**Key Steps:**
1. Fisher metric on {C(μ, γ)}: ds² = (dμ² + dγ²)/(2γ²) — the Poincaré half-plane metric
2. For fixed γ = 1: ds² = dμ²/2
3. Show SPB μ ↦ spb(μ, a) preserves g₁₁ via the pullback
4. Identify the isometry group as PSL(2, ℝ)

**New Opportunity:** The elliptic classification immediately tells us the curvature of SPB orbits on the Fisher manifold — they are circles in the Poincaré half-plane.

**Timeline:** 4–6 months. **Team:** 1 differential geometer.

---

### B3. p-adic SPB

**Status:** COMPUTATIONALLY VERIFIED; NEEDS FORMAL PROOF

**Goal:** Characterize (ℤₚ, spb) for all primes p.

**Predicted Structure:**
- p ≡ 1 (mod 4): √(−1) ∈ 𝔽ₚ, Cayley maps SPB to 𝔽ₚˣ. Group order p−1.
- p ≡ 3 (mod 4): √(−1) ∉ 𝔽ₚ, Cayley maps SPB to norm-1 elements of 𝔽_{p²}ˣ. Group order p+1.

**Connection to Local Class Field Theory:** The SPB group over ℚₚ should be U(1, ℚ_{p²}/ℚₚ) — the unitary group of the unramified quadratic extension.

**Timeline:** 6 months. **Team:** 1 number theorist.

---

### B4. SPB Stochastic Processes (NEW)

**Status:** NEWLY ENABLED by infinitesimal generator

**Key Insight:** V(x) = 1 + x² defines a natural diffusion:
dXₜ = (1 + Xₜ²) dWₜ

Under θ = arctan(X), this becomes dθₜ = dWₜ — Brownian motion on the circle!

**Questions:**
1. What is the hitting time distribution for SPB diffusion?
2. How does SPB discretization compare to Euler–Maruyama for circular diffusions?
3. What is the mixing time to the invariant Cauchy measure?
4. Applications to directional statistics and circular data analysis?

**Timeline:** 4–6 months. **Team:** 1 stochastic analyst.

---

### B5. Wick Rotation Formalization (NEW)

**Status:** NEWLY ENABLED by verified dual norm identities

**Foundation (Both Verified):**
- Circular: (1+x²)(1+y²) = (1−xy)² + (x+y)²
- Hyperbolic: (1−x²)(1−y²) = (1+xy)² − (x+y)²

The sign-flip x² → −x² transforms the circular identity into the hyperbolic one. This is the 1D Wick rotation.

**Research Plan:**
1. Formalize the analytic continuation that connects circular and hyperbolic SPB
2. Extend to n-point functions: what happens to SPB cocycles under Wick rotation?
3. Connect to the Osterwalder–Schrader axioms for QFT
4. Study the boundary behavior at |x| = 1 (the "light cone")

**Timeline:** 6–8 months. **Team:** 1 mathematical physicist.

---

## 3. Tier C: Lower Feasibility, Very High Impact — Strategic Bets

### C1. Division Algebra Obstruction Theorem (General Case)

**Status:** d = 1 CASE VERIFIED

**Conjecture:** SPB defines a group in dimension d iff a normed division algebra exists in dimension d+1.

**Proof Strategy (Validated for d = 1):**
1. The d-dimensional SPB norm identity requires: |1 − u·v|² · (1 + |spb_d(u,v)|²) = (1 + |u|²)(1 + |v|²)
2. Define w = spb_d(u,v). The map (u,v) ↦ (w, 1−u·v) preserves the norm 1+|·|²
3. Extend to ℝ^{d+1} via (1,u)·(1,v) = (1−u·v, w)
4. This multiplication satisfies |ab| = |a||b| → normed division algebra
5. By Hurwitz: d+1 ∈ {1,2,4,8}, so d ∈ {0,1,3,7}

**Known Cases:**
- d = 0: Trivial (SPB on a point, division algebra ℝ) ✓
- d = 1: Complex numbers ℂ — **VERIFIED** (Theorems 17–19)
- d = 3: Quaternions ℍ — Partially formalized
- d = 7: Octonions 𝕆 — Not yet attempted

**Next Step:** Formalize the d = 3 case using quaternion multiplication and the 4-square identity.

**Timeline:** 6–12 months. **Team:** 1 algebraist + formal methods support.

---

### C2. Langlands Connection via SPB Matrices

**Status:** FOUNDATIONAL RESULTS VERIFIED

**The SPB Matrix Subgroup:**
Γ_SPB = ⟨M(n) : n ∈ ℤ⟩ ⊂ GL(2, ℤ)

**Verified Properties:**
- det M(n) = 1 + n² (sum of two squares)
- tr M(n) = 2 (constant)
- Elliptic classification: tr² < 4·det for n ≠ 0
- det(∏ M(nᵢ)) = ∏(1 + nᵢ²) — product formula

**Key Questions:**
1. What is the index [GL(2, ℤ) : Γ_SPB]?
2. Products of k matrices have det = ∏(1 + nᵢ²). The representable integers are exactly products of primes ≡ 1 (mod 4) and 2 — connecting to Gaussian integers.
3. Are there "SPB modular forms" — functions on the upper half-plane invariant under Γ_SPB?
4. If so, what are their L-functions?
5. How does Γ_SPB relate to congruence subgroups?

**Timeline:** 6–12 months. **Team:** 1 number theorist + 1 algebraist.

---

### C3. SPB-Based Quantum Error Correction (NEW)

**Status:** CONCEPTUAL

**Motivation:** Single-qubit rotations about the z-axis act as multiplication on the Bloch sphere stereographic coordinate. X-rotations act as SPB. The Clifford group is generated by gates that correspond to specific SPB parameters.

**Key Observation:** The Hadamard gate maps |0⟩ to |+⟩, which in SPB coordinates is spb(0, 1) = 1. The T-gate corresponds to multiplication by e^{iπ/4}, or SPB with parameter tan(π/8).

**Questions:**
1. Can quantum error correction codes be described in SPB coordinates?
2. Does the SPB cocycle have a quantum information-theoretic interpretation?
3. Can projective SPB (no singularity) improve numerical stability of quantum circuit simulation?
4. What is the connection between SPB group order over 𝔽ₚ and quantum codes over 𝔽ₚ?

**Timeline:** 6–12 months. **Team:** 1 quantum information researcher.

---

### C4. Tropical SPB and Optimization

**Status:** CONCEPTUAL

**The Tropical Limit:** As coordinates go to ±∞, SPB should degenerate to max-plus operations:
trop-spb(x, y) = max(x, y) (approximately, for large positive values)

**Connection:** The tropical limit of the Brahmagupta–Fibonacci identity should give the tropical sum of squares identity, connecting to tropical geometry and optimization.

**Questions:**
1. What is the precise tropical limit of SPB?
2. Does the SPB cocycle have a tropical analogue?
3. Can tropical SPB be used for optimization (max-plus algebra is central to scheduling and shortest path problems)?

**Timeline:** 6–12 months.

---

## 4. Tier D: Long-Term Vision

### D1. SPB Category Theory
Define the category **SPB**: objects = fields with char ≠ 2, morphisms = field homomorphisms preserving SPB. Study functoriality, limits, colimits, relation to the category of commutative rings.

### D2. SPB and Motivic Cohomology
The cocycle coboundary result (H² = 0) lives in group cohomology. Extend to motivic cohomology: is the SPB cocycle motivic? Connect to algebraic K-theory via the Cayley transform as a motivic homotopy.

### D3. SPB in Geometric Deep Learning
Graph neural networks on spherical domains could use SPB as a native activation function, replacing the standard approach of embedding spherical data in Euclidean space. The projective SPB formulation avoids singularities.

### D4. SPB-Based Proof Assistant Modules
Use SPB conjugation to design a proof assistant module that reasons natively about periodic and circular mathematical objects, avoiding the 2π discontinuity that plagues standard formalizations.

### D5. SPB and Conformal Field Theory
Cross-ratio invariance directly connects SPB to conformal field theory (CFT). The operator product expansion (OPE) coefficients should have SPB-compatible structure, and the cocycle may encode conformal anomalies.

---

## 5. Cross-Cutting Themes

### Theme 1: The SPB–Cauchy–Fisher Triangle
Three verified results form a self-reinforcing triangle:
- **SPB → Cauchy**: The Cauchy distribution is the invariant measure (generator = 1/(Cauchy density))
- **Cauchy → Fisher**: The Fisher information metric on Cauchy location models is the Poincaré metric
- **Fisher → SPB**: SPB translations are isometries of the Fisher metric (to be proved)

Closing this triangle would establish SPB as a fundamental operation in information geometry.

### Theme 2: The Norm Tower
The SPB norm N(x) = 1 + x² connects to:
- d = 0: N = 1 (trivial)
- d = 1: N = 1 + x² = |1 + xi|² (Gaussian integers ℤ[i]) — **VERIFIED**
- d = 3: N = 1 + |x|² = |1 + xi + xj + xk|² (quaternion norm)
- d = 7: N = 1 + |x|² (octonion norm)

Each level corresponds to a normed division algebra. The norm tower is the algebraic backbone of the division algebra obstruction conjecture.

### Theme 3: Discrete ↔ Continuous
SPB exists in both continuous (ℝ) and discrete (𝔽ₚ) settings. The p±1 law provides a bridge:
- Continuous limit: group order → ∞ as p → ∞
- Finite: group order is exactly p±1
- The error term: group order = p ± 1 (no higher-order correction!)

This exact formula (not asymptotic) suggests deep arithmetic structure.

---

## 6. Brainstorm: 30 Application Ideas

### Engineering (1–10)
1. **Antenna array calibration** using SPB phase arithmetic
2. **Robotic joint estimation** with SPB Kalman filters (no gimbal lock)
3. **Radar Doppler tracking** using SPB signal model
4. **Power grid phasor measurement** in SPB coordinates
5. **Optical fiber polarization tracking** on the Poincaré sphere
6. **GPS carrier phase tracking** with SPB-based PLL
7. **Acoustic source localization** using SPB phase differences
8. **Inertial navigation** with SPB state representation
9. **Motor control** using SPB for rotor angle estimation
10. **Medical imaging** phase reconstruction (MRI, CT)

### Computer Science (11–20)
11. **Computational geometry** with Möbius-invariant algorithms (cross-ratio preserved)
12. **Computer graphics** spherical interpolation via SPB (alternative to slerp)
13. **Data compression** for angular/directional data using SPB coding
14. **Secure multi-party computation** on encrypted angles via SPB
15. **Division-free numerical algorithms** using projective SPB
16. **Streaming algorithm** for circular statistics (SPB-based running median)
17. **Hash functions** based on iterated SPB over finite fields
18. **Random number generation** using SPB orbits over large primes
19. **SPB-based activation functions** for periodic signal processing
20. **Geometric deep learning** on spherical data

### Mathematics (21–25)
21. **Modular forms** via SPB matrix groups
22. **Algebraic K-theory** via SPB cocycles
23. **Diophantine equations** using SPB norm multiplicativity
24. **Algebraic geometry** SPB as a group scheme over Spec ℤ[1/2]
25. **Combinatorics** SPB trees as a basis for rational function spaces

### Physics (26–30)
26. **Berry phase computation** via Bloch sphere SPB coordinates
27. **Thomas precession** via 3D SPB (quaternionic version)
28. **Cauchy spin models** in statistical mechanics (replacing Gaussian)
29. **Jones matrix calculus** via SPB parameterization (polarization optics)
30. **Wick rotation** in interacting quantum field theories

---

## 7. Resource Estimates

| Direction | Person-Months | Hardware | Key Expertise | Risk |
|-----------|:---:|:---:|:---:|:---:|
| A1: Neural Networks | 3 | GPU cluster | ML | Low |
| A2: CORDIC FPGA | 4 | FPGA board | Digital design | Low |
| A3: Crypto DH | 3 | Standard | Cryptography | Low |
| A4: Kalman Filter | 3 | Standard | Controls | Low |
| A5: Phase Estimation | 3 | Standard | Signal proc. | Low |
| A6: Cauchy Statistics | 4 | Standard | Statistics | Low |
| B1: Approximation | 5 | Standard | Approx. theory | Medium |
| B2: Info Geometry | 5 | Standard | Diff. geometry | Medium |
| B3: p-adic SPB | 6 | Standard | Number theory | Medium |
| B4: Stochastic SPB | 5 | Standard | Probability | Medium |
| B5: Wick Rotation | 7 | Standard | Math. physics | Medium |
| C1: Division Algebra | 10 | Standard | Algebra | High |
| C2: Langlands | 10 | Standard | Number theory | High |
| C3: Quantum EC | 8 | Quantum sim. | Quantum info | High |
| C4: Tropical SPB | 5 | Standard | Tropical geom. | Medium |

**Total for Tier A (parallel):** 4 months, 6 researchers.
**Total for Tier B (parallel):** 7 months, 5 researchers.
**Total for Tier C (selective):** 12 months, 3–4 researchers.

---

## 8. Dependency Graph

```
Verified Foundations (100+ theorems)
├─ Cross-ratio invariance
│  ├── A3: Crypto DH
│  ├── C2: Langlands (SPB matrices + cross-ratio)
│  └── D5: Conformal Field Theory
├─ Elliptic classification
│  ├── B2: Info Geometry (curvature of orbits)
│  └── B3: p-adic SPB (classification mod p)
├─ Projective SPB + norm multiplicativity
│  ├── A2: CORDIC FPGA
│  ├── C1: Division Algebra (extend to d=3,7)
│  └── C4: Tropical SPB
├─ Infinitesimal generator V(x) = 1+x²
│  ├── A1: Neural Networks
│  ├── A4: Kalman Filter
│  ├── B4: Stochastic SPB
│  └── B2: Info Geometry (Fisher metric)
├─ Brahmagupta–Fibonacci + Gaussian norm
│  ├── C1: Division Algebra Obstruction
│  └── C2: Langlands (det = sum of squares)
├─ Cocycle 2-cocycle property
│  ├── A2: CORDIC (series acceleration)
│  └── D2: Motivic Cohomology
├─ Cauchy pullback identity
│  ├── A6: Cauchy Robust Statistics [NEW]
│  ├── B2: Info Geometry
│  └── B4: Stochastic SPB
├─ Hyperbolic contraction
│  └── B5: Wick Rotation
└─ Wick dual norm identities
   ├── B5: Wick Rotation
   └── D5: CFT
```

---

## 9. Recommended Team Structure

### Core Formalization Team (2 people)
- Maintain Lean 4 codebase
- Verify new results as they emerge from applied work
- Develop reusable SPB Mathlib contributions

### Applications Sprint Team (4–6 people, rotating)
- 3-month sprints on Tier A topics
- Cross-pollination between ML, hardware, and crypto
- Shared benchmarking infrastructure

### Theory Working Group (2–3 people)
- Monthly seminars on Tier B/C topics
- Collaborate with external number theorists and geometers
- Publish 2–3 papers per year

---

## 10. Conclusion

The SPB-EML framework has reached a critical mass of verified results that enables a broad research program spanning pure mathematics, applied mathematics, engineering, and computer science. The combination of formal verification with practical applications creates a unique research paradigm: every theoretical result can be trusted absolutely, and every application can trace its mathematical foundation to machine-checked proofs.

The most promising near-term directions are:
1. **SPB neural networks** with Cauchy robustness (A1)
2. **Projective CORDIC hardware** for division-free computation (A2)
3. **Information geometry** closing the SPB–Cauchy–Fisher triangle (B2)
4. **Division algebra obstruction** extending to quaternions (C1)

We estimate that a team of 6–8 researchers could complete all Tier A objectives within 4 months and make significant progress on Tier B within a year.

---

*All foundational results verified in Lean 4.28.0 with Mathlib.*
*Roadmap version: April 2026.*
