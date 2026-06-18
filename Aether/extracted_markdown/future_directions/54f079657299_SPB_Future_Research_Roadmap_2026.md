# SPB-EML Future Research Roadmap 2026

## A Prioritized Research Agenda with Feasibility Assessment

---

## Executive Summary

Building on a foundation of 70+ machine-verified theorems in Lean 4, we present an updated research roadmap for the Stereographic Projection Bridge (SPB) and Exponential-Multiplicative-Logarithmic (EML) framework. The roadmap is organised into four tiers (A–D) by feasibility and impact. We highlight six **newly enabled** research directions made possible by our latest results, including cross-ratio invariance, elliptic classification, projective coordinates, and the cocycle expansion.

---

## 1. Newly Proved Foundations

The following new results (all machine-verified) expand the set of feasible research directions:

| Result | Opens | Impact |
|--------|-------|--------|
| Cross-ratio invariance | Confirms SPB is a genuine Möbius transform | Cryptography, projective geometry |
| Elliptic classification | Algebraic no-fixed-point proof | Dynamical systems, orbit analysis |
| Projective SPB | Singularity-free formulation | Hardware (CORDIC), numerical methods |
| Infinitesimal generator | $V(x) = 1 + x^2$ generates SPB flows | Stochastic processes, Kalman filters |
| Brahmagupta–Fibonacci | SPB norm = Gaussian integer norm | Division algebra conjecture |
| Geometric cocycle | $1/(1-xy) = \sum (xy)^n$ | Series acceleration, CORDIC without division |

---

## 2. Tier A: High Feasibility, High Impact — Do Now

### A1. SPB Neural Networks for Periodic Regression

**Status update:** The infinitesimal generator theorem ($V(x) = 1+x^2$) provides the linearisation needed for stable training. The derivative formula $\partial\operatorname{spb}/\partial x = (1+y^2)/(1-xy)^2$ enables custom backward passes.

**Concrete experiment design:**
1. Implement `SPBNeuron(x; w) = spb(w₁x₁, spb(w₂x₂, ...))` in PyTorch
2. Custom backward pass using the verified gradient formula
3. Benchmarks:
   - Fourier series fitting (5, 10, 20 harmonics)
   - Seasonal time series (temperature, electricity demand)
   - Phase estimation from noisy sinusoids
   - Direction-of-arrival estimation in array signal processing
4. Baselines: MLP, LSTM, Transformer, Fourier Neural Operator
5. Metrics: MSE, training speed, generalisation to unseen frequencies

**New insight:** The infinitesimal generator $1+x^2$ is the reciprocal of the Cauchy density. This means the "natural noise model" for SPB neurons is Cauchy noise, not Gaussian. SPB networks may be inherently robust to heavy-tailed noise.

**Expected outcome:** 10-30% improvement on periodic tasks.
**Timeline:** 2-3 months. **Team:** 1 ML researcher, GPU cluster.

---

### A2. SPB-CORDIC Hardware with Projective Coordinates

**Status update:** The projective SPB formulation eliminates the division in each CORDIC step. The operation $[x₁:x₂] \oplus [y₁:y₂] = [x₁y₂ + x₂y₁ : x₂y₂ - x₁y₁]$ requires only 4 multiplications and 2 additions/subtractions per step.

**Implementation plan:**
1. Design projective SPB arithmetic unit in Verilog/VHDL
2. Pipeline: two parallel multiply stages → add/subtract stage (2 cycles vs 3 for standard)
3. Implement affine-to-projective and projective-to-affine conversion units
4. Compare latency and area against standard CORDIC on Xilinx/Intel FPGA
5. Target: 16-bit and 32-bit fixed-point precision

**New advantage:** The cocycle expansion ($1/(1-xy) = 1 + xy + (xy)^2 + ...$) provides an alternative: for small $xy$, truncate after 2-3 terms. This avoids division with controllable error.

**Expected outcome:** 25-35% latency reduction per CORDIC iteration.
**Timeline:** 3-4 months. **Team:** 1 digital design engineer.

---

### A3. SPB Diffie-Hellman Prototype

**Status update:** Cross-ratio invariance confirms that SPB translation is a Möbius transformation. The SPB DLP (discrete logarithm problem) reduces to the standard DLP via arctan.

**Protocol:**
1. Public: prime $p$, generator $g \in \mathbb{F}_p$
2. Alice: random $a$, sends $A = \operatorname{spb}^a(g) \bmod p$
3. Bob: random $b$, sends $B = \operatorname{spb}^b(g) \bmod p$
4. Shared secret: $\operatorname{spb}^a(B) = \operatorname{spb}^{a+b}(g) = \operatorname{spb}^b(A)$

**Security:** Equivalent to standard DH with the same prime. The $p \pm 1$ law means:
- For $p \equiv 3 \pmod{4}$: group order $p+1$ (slightly larger than standard $p-1$)
- For $p \equiv 1 \pmod{4}$: group order $p-1$ (same as standard)

**Implementation:**
1. Implement in Rust with constant-time SPB modular arithmetic
2. Benchmark: ops/key exchange, energy/key exchange, code size
3. Compare against standard DH and ECDH (Curve25519)

**Timeline:** 2-3 months. **Team:** 1 cryptography researcher.

---

### A4. SPB Kalman Filter for IMU Sensor Fusion

**Status update:** The infinitesimal generator theorem provides the continuous-time model: $\dot{\theta} = (1 + \theta^2) \cdot \omega$ where $\theta = \tan(\text{angle}/2)$ and $\omega$ is angular velocity.

**State update:**
$$\hat{\theta}_k = \operatorname{spb}\!\left(\hat{\theta}_{k-1|k-1},\; K_k \cdot (\theta_{\text{meas}} - \hat{\theta}_{k-1|k-1})\right)$$

**Key advantage:** No angle wrapping. The SPB parameterisation maps the circle to the real line continuously (except at the antipodal point), and the Cauchy distribution is the natural noise model.

**Experiment:**
1. Simulate 9-axis IMU with known ground truth trajectories
2. Include large angular changes (somersaults, 360° rotations)
3. Compare: standard EKF with wrapping, quaternion EKF, SPB Kalman filter
4. Metrics: RMS error, convergence speed, robustness to initialisation

**Timeline:** 2-3 months. **Team:** 1 controls engineer.

---

### A5. SPB Signal Processing for Phase Estimation (NEW)

**Motivation:** Phase estimation from noisy complex signals is fundamental in radar, communications, and interferometry. Standard approaches use $\arctan$ followed by unwrapping. SPB provides a native framework.

**Key idea:** Given signal $s(t) = A \cos(\omega t + \phi) + n(t)$, the instantaneous phase satisfies $\tan(\phi(t)) = \text{Im}(s)/\text{Re}(s)$. Phase differences are computed by SPB:
$$\Delta\phi_{12} = \operatorname{spb}(\tan\phi_1, -\tan\phi_2)$$

**Advantage:** No phase unwrapping needed. Works natively on the tangent parameterisation.

**Timeline:** 2-3 months. **Team:** 1 signal processing researcher.

---

## 3. Tier B: Medium Feasibility, High Impact — Do Next

### B1. SPB Approximation Theory

**Question:** What class of functions do SPB trees of depth $n$ approximate?

**Known:** Under $x = \tan(\theta/2)$, an SPB tree of depth $n$ produces $\tan(P(\theta))$ where $P$ is a trigonometric polynomial of degree $\leq 2^{n-1}$.

**Research plan:**
1. Prove degree bound formally (partially done in SPBApproximation.lean)
2. Implement best SPB tree fitting via nonlinear optimisation
3. Compare: SPB tree (depth $n$) vs Chebyshev (degree $2^{n-1}$) vs Padé
4. Test functions: Runge, $|x|$, step function, saw-tooth wave

**Conjecture:** SPB trees achieve the optimal approximation rate $O(\omega(f, 2^{-n}))$ for continuous periodic functions, matching Chebyshev with potentially better numerical stability.

**Timeline:** 4-6 months. **Team:** 1 approximation theorist.

---

### B2. Information Geometry of the Cauchy Family

**Goal:** Prove that SPB translations are isometries of the Fisher information metric on $\{C(\mu, 1)\}$.

**Building blocks available:**
- Cauchy pullback identity (proved)
- Infinitesimal generator $V(x) = 1 + x^2$ (proved)
- Derivative of Cauchy kernel (proved)

**Key steps:**
1. Fisher metric on $\{C(\mu, \gamma)\}$: $ds^2 = (d\mu^2 + d\gamma^2)/(2\gamma^2)$
2. Show SPB $\mu \mapsto \operatorname{spb}(\mu, a)$ preserves $g_{11}$ via the pullback
3. Identify isometry group as $\operatorname{PSL}(2, \mathbb{R})$

**New opportunity:** The elliptic classification (Theorem 8) immediately tells us the curvature of SPB orbits on the Fisher manifold.

**Timeline:** 4-6 months. **Team:** 1 differential geometer.

---

### B3. p-adic SPB

**Goal:** Characterize $(\mathbb{Z}_p, \operatorname{spb})$ for all primes $p$.

**Structure predicted by Cayley transform:**
- $p \equiv 1 \pmod{4}$: $\sqrt{-1} \in \mathbb{F}_p$, so Cayley maps SPB to $\mathbb{F}_p^\times$. Group order $p-1$.
- $p \equiv 3 \pmod{4}$: $\sqrt{-1} \notin \mathbb{F}_p$, so Cayley maps SPB to norm-1 elements of $\mathbb{F}_{p^2}^\times$. Group order $p+1$.

**Connection to local class field theory:** The SPB group over $\mathbb{Q}_p$ should be $U(1, \mathbb{Q}_{p^2}/\mathbb{Q}_p)$—the unitary group of the unramified quadratic extension. This connects to the local Artin map.

**Timeline:** 6 months. **Team:** 1 number theorist.

---

### B4. SPB Stochastic Processes (NEW)

**Key insight:** The infinitesimal generator $V(x) = 1 + x^2$ defines a natural diffusion on $\mathbb{R}$:
$$dX_t = (1 + X_t^2)\,dW_t$$

Under $\theta = \arctan(X)$, this becomes $d\theta_t = dW_t$ — Brownian motion on the circle! The Cauchy distribution $\frac{1}{\pi(1+x^2)}$ is the invariant measure.

**Questions:**
1. What is the hitting time distribution for SPB diffusion?
2. How does SPB discretisation compare to Euler–Maruyama for circular diffusions?
3. Applications to angular estimation and directional statistics?

**Timeline:** 4-6 months. **Team:** 1 stochastic analyst.

---

## 4. Tier C: Lower Feasibility, Very High Impact — Strategic Bets

### C1. Division Algebra Obstruction Theorem

**Conjecture:** SPB defines a group in dimension $d$ iff a normed division algebra exists in dimension $d+1$.

**Proof strategy:**
1. The $d$-dimensional SPB norm identity requires: $|1 - \mathbf{u} \cdot \mathbf{v}|^2 \cdot (1 + |\operatorname{spb}_d(\mathbf{u}, \mathbf{v})|^2) = (1 + |\mathbf{u}|^2)(1 + |\mathbf{v}|^2)$
2. Define $\mathbf{w} = \operatorname{spb}_d(\mathbf{u}, \mathbf{v})$. The map $(\mathbf{u}, \mathbf{v}) \mapsto (\mathbf{w}, 1 - \mathbf{u}\cdot\mathbf{v})$ preserves the norm $1 + |\cdot|^2$.
3. Extend to $\mathbb{R}^{d+1}$ via $(1, \mathbf{u}) \cdot (1, \mathbf{v}) = (1 - \mathbf{u}\cdot\mathbf{v}, \mathbf{w})$
4. This multiplication satisfies $|ab| = |a||b|$, making $\mathbb{R}^{d+1}$ a normed division algebra
5. By Hurwitz: $d + 1 \in \{1, 2, 4, 8\}$, so $d \in \{0, 1, 3, 7\}$

**Known cases:** $d = 1$ (SPB on $\mathbb{R}$, division algebra $\mathbb{C}$) ✓. $d = 3$ (3D SPB with cross product, division algebra $\mathbb{H}$) ✓.

**Status:** Brahmagupta–Fibonacci (the $d=1$ case) is now formally proved. The $d=3$ case (3D SPB) is partially formalised. The general argument requires formalising Hurwitz's theorem, which is substantial but well-understood.

**Timeline:** 6-12 months. **Team:** 1 algebraist + formal methods support.

---

### C2. Langlands Connection via SPB Matrices

**The subgroup:** $\Gamma_{\text{SPB}} = \langle M(n) : n \in \mathbb{Z} \rangle \subset \operatorname{GL}(2, \mathbb{Z})$.

**New results to leverage:**
- $\det M(n) = 1 + n^2$ (sum of two squares)
- $\operatorname{tr} M(n) = 2$ (constant trace)
- Elliptic classification: $\operatorname{tr}^2 < 4\det$ for $n \neq 0$

**Key questions:**
1. What is the index $[\operatorname{GL}(2, \mathbb{Z}) : \Gamma_{\text{SPB}}]$?
2. Products of $k$ matrices have $\det = \prod(1 + n_i^2)$. What integers are representable? (Answer: products of primes $\equiv 1 \pmod{4}$ and 2.)
3. Are there "SPB modular forms"—functions on the upper half-plane invariant under $\Gamma_{\text{SPB}}$?
4. If so, what are their $L$-functions?

**Connection to sums of two squares:** The representability of $\det(M(n_1) \cdots M(n_k))$ as a sum of two squares is governed by the Gaussian integers. The map $M(n) \mapsto 1 + ni \in \mathbb{Z}[i]$ is a norm homomorphism: $\det = |1 + ni|^2 = N(1 + ni)$.

**Timeline:** 6-12 months. **Team:** 1 number theorist + 1 algebraist.

---

### C3. SPB-Based Quantum Error Correction (NEW)

**Motivation:** Single-qubit rotations about the $z$-axis act as multiplication on the Bloch sphere stereographic coordinate. X-rotations act as SPB. The Clifford group—essential for quantum error correction—is generated by gates that correspond to specific SPB parameters.

**Key observation:** The Hadamard gate maps $|0\rangle$ to $|+\rangle$, which in SPB coordinates is $\operatorname{spb}(0, 1) = 1$. The $T$-gate corresponds to multiplication by $e^{i\pi/4}$, or SPB with parameter $\tan(\pi/8)$.

**Questions:**
1. Can quantum error correction codes be described in SPB coordinates?
2. Does the SPB cocycle $1/(1-xy)$ have a quantum information-theoretic interpretation?
3. Can the projective SPB (no singularity) improve numerical stability of quantum circuit simulation?

**Timeline:** 6-12 months. **Team:** 1 quantum information researcher.

---

### C4. Wick Rotation in Interacting QFT

**Goal:** Use SPB sign-flip to provide rigorous Wick rotation beyond free fields.

**The dual norm identities:**
- Circular: $(1-xy)^2(1+z^2) = (1+x^2)(1+y^2)$ (compact)
- Hyperbolic: $(1+xy)^2(1-z^2) = (1-x^2)(1-y^2)$ (noncompact)

The sign flip $1+x^2 \to 1-x^2$ is well-understood for free propagators. For interactions, the singularity structure of multi-point correlation functions under Wick rotation is a deep open problem.

**SPB approach:** Model 1D Wick rotation as $\operatorname{spb} \to \operatorname{spbH}$ and study how higher-dimensional analogs behave. The cross-ratio invariance theorem may help, since cross-ratios are the fundamental variables for conformal field theory.

**Timeline:** 12+ months. **Team:** 1 mathematical physicist.

---

## 5. Tier D: Long-Term Vision

### D1. SPB Category Theory
Define the category **SPB**: objects = fields with $\operatorname{char} \neq 2$, morphisms = field homomorphisms preserving SPB. Study: functoriality, limits, colimits, relation to the category of commutative rings.

### D2. SPB and Motivic Cohomology
The cocycle coboundary result ($H^2 = 0$) lives in group cohomology. Extend to motivic cohomology: is the SPB cocycle motivic? Connect to algebraic K-theory via the Cayley transform as a motivic homotopy.

### D3. Tropical SPB and Optimization
The "tropical limit" of SPB (as coordinates go to $\pm\infty$) should yield max-plus operations. This could connect tropical geometry to the SPB framework, with applications to optimization and scheduling.

### D4. SPB-Based Proof Assistants
Use SPB conjugation to design a proof assistant module that reasons natively about periodic and circular mathematical objects, avoiding the $2\pi$ discontinuity that plagues standard formalisations.

### D5. SPB in Geometric Deep Learning
Graph neural networks on spherical domains could use SPB as a native activation function, replacing the standard approach of embedding spherical data in Euclidean space.

---

## 6. Applications Brainstorm

### Engineering
1. **Antenna array processing:** SPB for phase calibration without wrapping
2. **Robotics:** Joint angle estimation with SPB Kalman filters
3. **Radar:** Doppler phase tracking using SPB signal model
4. **Power systems:** Phasor measurement using SPB coordinates
5. **Optical fiber:** Polarisation state tracking on the Poincaré sphere

### Computer Science
6. **Computational geometry:** SPB for Möbius-invariant algorithms
7. **Computer graphics:** Spherical interpolation via SPB (alternative to slerp)
8. **Data compression:** SPB-based arithmetic coding for angular data
9. **Secure computation:** SPB homomorphic operations on encrypted angles
10. **Numerical analysis:** Projective SPB for division-free algorithms

### Pure Mathematics
11. **Representation theory:** SPB matrices as representations of $\mathbb{Z}$
12. **Algebraic geometry:** SPB as a group scheme over $\operatorname{Spec}\mathbb{Z}[1/2]$
13. **Differential geometry:** SPB as geodesic flow on the circle
14. **Operator algebras:** SPB as an automorphism of $L^\infty(S^1)$
15. **Combinatorics:** SPB trees as a new basis for rational function spaces

### Physics
16. **Condensed matter:** Berry phase as SPB of Bloch sphere coordinates
17. **General relativity:** Thomas precession via 3D SPB
18. **Statistical mechanics:** Cauchy-distributed spin models (vs Gaussian)
19. **Optics:** Jones matrix calculus via SPB parameterisation
20. **Acoustics:** Phase-based sound localisation using SPB coordinates

---

## 7. Key Dependencies Graph (Updated)

```
Verified Foundations (70+ theorems)
├── A1: Neural Networks (gradient + infinitesimal generator)
├── A2: CORDIC FPGA (SPB-CORDIC + projective SPB)
├── A3: Crypto DH (p±1 law + cross-ratio)
├── A4: Kalman Filter (infinitesimal generator)
├── A5: Phase Estimation (arctan characterisation) [NEW]
├── B1: Approximation Theory (SPB tree + iteration)
├── B2: Info Geometry (Cauchy pullback + Cauchy kernel derivative)
│   └── C4: Wick QFT (dual norm identities)
├── B3: p-adic SPB (finite field + Cayley transform)
│   └── C2: Langlands (SPB matrices + det multiplicativity)
├── B4: Stochastic SPB (infinitesimal generator) [NEW]
└── C1: Division Algebra (norm identity + Brahmagupta-Fibonacci)
    └── C3: Quantum Error Correction (Bloch sphere SPB) [NEW]
```

---

## 8. Estimated Resource Requirements

| Direction | Person-Months | Hardware | Expertise |
|-----------|:---:|:---:|:---:|
| A1: Neural Networks | 3 | GPU cluster | ML |
| A2: CORDIC FPGA | 4 | FPGA board | Digital design |
| A3: Crypto DH | 3 | Standard | Cryptography |
| A4: Kalman Filter | 3 | Standard | Controls |
| A5: Phase Estimation | 3 | Standard | Signal proc. |
| B1: Approximation | 5 | Standard | Approx. theory |
| B2: Info Geometry | 5 | Standard | Diff. geometry |
| B3: p-adic SPB | 6 | Standard | Number theory |
| B4: Stochastic SPB | 5 | Standard | Probability |
| C1: Division Algebra | 10 | Standard | Algebra |
| C2: Langlands | 10 | Standard | Number theory |
| C3: Quantum EC | 8 | Quantum sim. | Quantum info |
| C4: Wick QFT | 15 | Standard | Math. physics |

**Total for Tier A (parallel):** 4 months, 5 researchers.
**Total for Tier B (parallel):** 6 months, 4 researchers.
**Total for Tier C (selective):** 12 months, 3-4 researchers.

---

*All foundations verified in Lean 4.28.0 with Mathlib.*
*Roadmap version: April 2026.*
