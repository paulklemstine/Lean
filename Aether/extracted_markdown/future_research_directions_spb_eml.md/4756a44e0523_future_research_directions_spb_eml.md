# SPB-EML: Recommended Future Research Directions

## A Prioritized Roadmap with Feasibility Assessment

---

## Executive Summary

We present a structured research roadmap organized into four tiers. Each direction includes: (a) precise mathematical formulation, (b) feasibility assessment, (c) resource requirements, (d) expected timeline, and (e) dependencies on prior results.

All Tier A directions build directly on machine-verified foundations (43 theorems proved in Lean 4).

---

## Tier A: High Feasibility, High Impact — Do These Now

### A1. SPB Neural Networks for Periodic Regression

**Mathematical formulation:**
Define the SPB neuron:
$$\text{SPBNeuron}(\mathbf{x}; \mathbf{w}) = \text{spb}(w_1 x_1, \text{spb}(w_2 x_2, \ldots, \text{spb}(w_{n-1} x_{n-1}, w_n x_n)))$$

**Verified gradient:**
$$\frac{\partial \text{spb}(x, y)}{\partial x} = \frac{1 + y^2}{(1 - xy)^2}$$

**Experiment design:**
1. Implement SPBNeuron in PyTorch with custom backward pass
2. Train on: (a) Fourier series fitting, (b) seasonal time series, (c) phase estimation
3. Compare against MLP, LSTM, Transformer baselines
4. Metrics: MSE, training speed, generalization to unseen frequencies

**Expected outcome:** 10-30% improvement on periodic tasks.

**Feasibility:** HIGH. All mathematical foundations are proved. Implementation is straightforward.

**Resources:** 1 ML researcher, 2-3 months, GPU cluster.

**Dependencies:** Proved gradient formula (SPBCocycle.lean).

---

### A2. SPB-CORDIC Hardware Implementation

**Mathematical formulation:**
Each CORDIC step in tangent coordinates:
$$t_{n+1} = \text{spb}(t_n, d_n \cdot 2^{-n}) = \frac{t_n + d_n \cdot 2^{-n}}{1 - t_n \cdot d_n \cdot 2^{-n}}$$

This replaces the standard 4-operation step with a 3-operation SPB evaluation.

**Implementation plan:**
1. Design SPB arithmetic unit in Verilog/VHDL
2. Pipeline: multiply stage → subtract stage → divide stage (3 cycles)
3. Compare latency and area against standard CORDIC on Xilinx FPGA
4. Target: 16-bit and 32-bit fixed-point precision

**Expected outcome:** 25% latency reduction per CORDIC iteration.

**Feasibility:** HIGH. The SPB-CORDIC equivalence is formally proved (SPBCORDIC.lean).

**Resources:** 1 digital design engineer, 3-4 months, FPGA board.

---

### A3. SPB Diffie-Hellman Prototype

**Protocol:**
- Public parameters: prime $p$, generator $g$
- Alice: choose random $a$, send $A = \text{spb}^a(g) \bmod p$
- Bob: choose random $b$, send $B = \text{spb}^b(g) \bmod p$
- Shared secret: $\text{spb}^a(B) = \text{spb}^{a+b}(g) = \text{spb}^b(A)$

**Security analysis:**
- SPB DLP reduces to standard DLP in $\mathbb{Z}/(p \pm 1)$ via the isomorphism $\arctan: (\mathbb{F}_p, \text{spb}) \to (\mathbb{Z}/(p \pm 1), +)$
- Key size equivalent to standard DH with same prime
- Computational advantage: only field ops, no EC point multiplication

**Implementation plan:**
1. Implement SPB iteration over $\mathbb{F}_p$ in Python/Rust
2. Benchmark against standard DH and ECDH for equivalent security levels
3. Measure: ops/key exchange, energy/key exchange, code size

**Feasibility:** HIGH. The $p \pm 1$ law is computationally verified (SPBFiniteFieldOrder.lean).

**Resources:** 1 cryptography researcher, 2-3 months.

---

### A4. SPB Kalman Filter for IMU Sensor Fusion

**State update equation:**
$$\hat{\theta}_k = \text{spb}(\hat{\theta}_{k-1|k-1},\, K_k \cdot (\theta_{\text{meas}} - \hat{\theta}_{k-1|k-1}))$$

where operations on angular differences use SPB, $K_k$ is the Kalman gain, and the prediction step uses SPB with gyroscope-integrated angle.

**Key advantage:** No angle wrapping. The SPB state update is an intrinsically circular operation — there's no $2\pi$ discontinuity to handle.

**Experiment:**
1. Simulate 9-axis IMU data with known ground truth
2. Compare: (a) standard EKF with angle wrapping, (b) SPB Kalman filter, (c) quaternion Kalman filter
3. Metrics: estimation error, convergence speed, robustness to large angular changes

**Expected outcome:** Comparable or better accuracy than quaternion methods, with simpler implementation.

**Feasibility:** HIGH. Core SPB algebra is fully verified.

**Resources:** 1 controls engineer, 2-3 months.

---

## Tier B: Medium Feasibility, High Impact — Do These Next

### B1. SPB Approximation Theory

**Key questions:**
1. What class of functions do SPB trees of depth $n$ approximate?
2. What is the approximation rate? (Conjectured: $O(\omega(f, 2^{-n}))$)
3. How does SPB approximation compare to Chebyshev and Padé?

**Mathematical framework:**
An SPB tree of depth $n$ with parameters $(a_1, \ldots, a_{2^n - 1})$ produces:
$$T_n(x) = \text{spb}(T_{n-1}^L(x), T_{n-1}^R(x))$$

Under $x = \tan(\theta/2)$, this becomes a trigonometric polynomial of degree $\leq 2^{n-1}$.

**Research plan:**
1. Prove the rational function degree bound formally
2. Implement best SPB tree fitting for standard test functions (Runge, |x|, step function)
3. Compare rates with Chebyshev and Padé approximants

**Feasibility:** MEDIUM. Framework exists (SPBApproximation.lean), theory needs development.

**Resources:** 1 approximation theorist, 4-6 months.

---

### B2. Information Geometry of the Cauchy Family

**Goal:** Prove that SPB translations are isometries of the Fisher information metric on the Cauchy family $\{C(\mu, \gamma)\}$.

**Key steps:**
1. Compute the Fisher metric tensor: $g_{11} = 1/(2\gamma^2)$, $g_{22} = 1/(2\gamma^2)$, $g_{12} = 0$
2. Show that $\mu \mapsto \text{spb}(\mu, a)$ preserves $g_{11}$ (using the pullback identity)
3. Identify the isometry group of the Fisher metric as the modular group action

**Building blocks available:** Cauchy pullback identity (Theorem 20), cocycle coboundary (H10).

**Feasibility:** MEDIUM. Requires Riemannian geometry in Lean 4 (partially available in Mathlib).

**Resources:** 1 differential geometer + formal methods support, 4-6 months.

---

### B3. p-adic SPB

**Goal:** Characterize $(\mathbb{Z}_p, \text{spb})$ for all primes $p$.

**Expected structure:**
- For $p \equiv 1 \pmod{4}$: $i = \sqrt{-1}$ exists in $\mathbb{F}_p$, the SPB group splits as $\mathbb{Z}_p^\times \times \mathbb{Z}_p^\times$
- For $p \equiv 3 \pmod{4}$: $i \notin \mathbb{F}_p$, the SPB group is the norm-1 elements of $\mathbb{Z}_{p^2}$

**Connection to class field theory:** The SPB group over $\mathbb{Q}_p$ should be related to the local Artin map for the extension $\mathbb{Q}_p(\sqrt{-1})/\mathbb{Q}_p$.

**Feasibility:** MEDIUM. Requires p-adic number theory (partially in Mathlib).

**Resources:** 1 number theorist, 6 months.

---

## Tier C: Lower Feasibility, Very High Impact — Strategic Bets

### C1. Division Algebra Obstruction Theorem

**Conjecture:** The SPB operation defines a group in dimension $d$ iff a normed division algebra exists in dimension $d+1$.

**Known cases:**
- $d = 1$: SPB on $\mathbb{R}$ ✓ (division algebra: $\mathbb{C}$, dim 2)
- $d = 3$: SPB on $\mathbb{R}^3$ ✓ (division algebra: $\mathbb{H}$, dim 4)
- $d = 7$: SPB on $\mathbb{R}^7$ should work (division algebra: $\mathbb{O}$, dim 8)
- $d = 2, 4, 5, 6$: should fail (no division algebra in dim 3, 5, 6, 7)

**Research plan:**
1. Formalize the SPB norm identity $|1 - \mathbf{u} \cdot \mathbf{v}|^2 \cdot (1 + |\text{spb}_d|^2) = (1 + |\mathbf{u}|^2)(1 + |\mathbf{v}|^2)$
2. Show this requires a multiplication on $\mathbb{R}^{d+1}$ satisfying the norm condition
3. Apply Hurwitz's theorem to conclude $d + 1 \in \{1, 2, 4, 8\}$

**Impact:** Would provide a new characterization of division algebras via the SPB formalism.

**Feasibility:** MEDIUM-LOW. The proof strategy is clear but formalization is substantial.

---

### C2. Langlands Connection via SPB Matrices

**Setup:** The matrices $M(n) = \begin{pmatrix}1&n\\-n&1\end{pmatrix}$ for $n \in \mathbb{Z}$ generate a subgroup $\Gamma_{\text{SPB}}$ of $\text{GL}(2, \mathbb{Z})$.

**Questions:**
1. What is $[\text{SL}(2, \mathbb{Z}) : \Gamma_{\text{SPB}} \cap \text{SL}(2, \mathbb{Z})]$?
2. Is $\Gamma_{\text{SPB}}$ a congruence subgroup?
3. What is the genus of the modular curve $X(\Gamma_{\text{SPB}})$?
4. Are there modular forms of weight 2 for $\Gamma_{\text{SPB}}$, and what are their $L$-functions?

**Note:** $\det M(n) = 1 + n^2$, so $M(n) \notin \text{SL}(2, \mathbb{Z})$ for $n \neq 0$. But $M(n) / \sqrt{1+n^2}$ is in $\text{SO}(2, \mathbb{R})$, and the projectivization is in $\text{PSL}(2, \mathbb{R})$.

**Impact:** Could connect SPB to the theory of automorphic forms.

**Feasibility:** LOW-MEDIUM. Requires deep number theory expertise.

---

### C3. Wick Rotation in Interacting QFT

**Goal:** Use the SPB sign-flip formalism to provide a rigorous framework for Wick rotation beyond free field theories.

**The problem:** In free QFT, Wick rotation ($t \to it$, or equivalently $1 - xy \to 1 + xy$) is straightforward. In interacting theories, the continuation to imaginary time requires controlling the singularity structure of correlation functions.

**SPB approach:** Model the 1D Wick rotation as the map $\text{spb} \to \text{spbH}$ and study how this extends to higher-dimensional analogs. The circular norm ↔ hyperbolic norm exchange (Theorems 10-11) is the model case.

**Feasibility:** LOW. This is a deep open problem in mathematical physics.

---

## Tier D: Long-term Vision

### D1. SPB Category Theory
Define the category **SPB**: objects = fields with $\text{char} \neq 2$, morphisms = field homomorphisms preserving SPB.

### D2. SPB and Motivic Cohomology
The cocycle coboundary result (H² = 0) lives in group cohomology. Extend to motivic cohomology and connect to algebraic K-theory.

### D3. Quantum SPB Computing
Design quantum circuits that implement SPB operations natively. The Cayley transform provides the bridge between SPB parameters and unitary gates.

### D4. SPB-Based Proof Assistants
Use the EML-SPB conjugation framework to design a proof assistant that reasons natively about periodic and circular mathematical objects.

---

## Summary Table

| Direction | Tier | Impact | Timeline | Team |
|-----------|------|--------|----------|------|
| A1: SPB Neural Nets | A | High | 2-3 mo | ML |
| A2: SPB-CORDIC FPGA | A | High | 3-4 mo | HW |
| A3: SPB Diffie-Hellman | A | High | 2-3 mo | Crypto |
| A4: SPB Kalman Filter | A | High | 2-3 mo | Controls |
| B1: Approximation Theory | B | High | 4-6 mo | Math |
| B2: Information Geometry | B | High | 4-6 mo | Geom |
| B3: p-adic SPB | B | V.High | 6 mo | NT |
| C1: Division Algebra | C | V.High | 6-12 mo | Algebra |
| C2: Langlands | C | V.High | 6-12 mo | NT |
| C3: Wick QFT | C | Transform | 12+ mo | Physics |

---

## Key Dependencies Graph

```
Proved foundations (43 theorems)
├── A1: SPB Neural Nets (gradient formula)
├── A2: CORDIC FPGA (SPB-CORDIC equivalence)
├── A3: Crypto (p±1 law)
├── A4: Kalman (SPB algebra)
├── B1: Approximation (SPB tree framework)
├── B2: Info Geometry (Cauchy pullback)
│   └── C2: Langlands (Möbius group)
├── B3: p-adic (finite field structure)
│   └── C1: Division Algebra (norm identity)
└── C3: Wick QFT (Wick rotation identities)
```

All Tier A directions are independent and can proceed in parallel.
