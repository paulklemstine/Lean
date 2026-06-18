# SPB–EML Bridge: Future Research Directions

## Recommended Explorations, Ranked by Impact and Feasibility

---

## Priority 1: Immediate Impact (High feasibility, High impact)

### 1.1 SPB Neural Network Architectures

**Hypothesis**: SPB neurons outperform standard neurons on periodic/cyclical data.

**Experiment Design**:
1. Define `SPBNeuron(x₁,...,xₙ; w₁,...,wₙ) = spb(w₁x₁, spb(w₂x₂, ..., wₙxₙ))`
2. Implement backpropagation using the verified derivative: ∂spb/∂x = (1+y²)/(1−xy)²
3. Train on:
   - Fourier series approximation (periodic regression)
   - Phase estimation (quantum chemistry)
   - Daily/yearly cyclical time series
4. Compare against MLP, LSTM, Transformer baselines
5. Measure: accuracy, training speed, gradient stability

**Predicted result**: 10-30% improvement on periodic tasks, comparable on non-periodic.

### 1.2 EML-Based Computation Engine

**Hypothesis**: A computation engine using only EML as the primitive can match standard ALU performance while providing algebraic guarantees.

**Experiment**:
1. Implement EML-only arithmetic: `add(x,y)`, `mul(x,y)`, `pow(x,n)` via EML
2. Benchmark against standard floating-point
3. Measure error propagation properties

### 1.3 Finite Field SPB for Lightweight Cryptography

**Hypothesis**: SPB over F_p provides equivalent security to elliptic curve DLP with simpler arithmetic.

**Experiment**:
1. Implement Diffie-Hellman over SPB(F_p) for primes p ≡ 3 (mod 4)
2. Benchmark key generation and exchange times vs. ECDH
3. Test resistance to baby-step giant-step and Pohlig-Hellman attacks
4. Assess suitability for IoT/embedded devices

---

## Priority 2: Short-term Research (3-6 months)

### 2.1 SPB Approximation Theory

**Key question**: How well do SPB expression trees of depth n approximate continuous functions?

**Approach**:
1. SPB trees generate functions of the form tan(P(arctan(x))) where P is an integer polynomial
2. Under substitution x = tan(θ/2), these are trigonometric polynomials
3. Apply Jackson's theorem to get approximation rates
4. Compare with Padé approximants and continued fractions

**Experiment**: Approximate Runge's function f(x) = 1/(1+25x²) using SPB trees vs. polynomials vs. Padé.

### 2.2 3D SPB and Quaternions

**Hypothesis**: spb₃(u, v) = (u + v + u×v)/(1 − u·v) recovers quaternion multiplication under the 3D Cayley transform.

**Experiment**:
1. Implement spb₃ in Python
2. Verify: C₃(spb₃(u,v)) = C₃(u) · C₃(v) where C₃ is the 3D Cayley transform to S³
3. Compute the Thomas-Wigner rotation: spb₃(u,v) vs spb₃(v,u)
4. Formalize in Lean 4

### 2.3 All-Pass Filter Optimization

**Hypothesis**: SPB-based parametrization simplifies all-pass filter cascade design.

**Experiment**:
1. Parametrize all-pass filters by their SPB parameter
2. Optimize cascades for target group delay specifications
3. Compare optimization landscape vs. direct coefficient optimization

### 2.4 Random SPB and Cauchy Distributions

**Hypothesis**: Random SPB iteration x_{n+1} = spb(x_n, a_n) with i.i.d. symmetric a_n converges to a Cauchy invariant measure.

**Experiment**:
1. Simulate 10⁶ iterations with a_n ~ N(0,1) and a_n ~ Uniform(-1,1)
2. Test the limiting distribution against Cauchy fits
3. Estimate the Lyapunov exponent λ = E[log(1+a²)]/2

---

## Priority 3: Medium-term Research (6-12 months)

### 3.1 Tropical SPB

Define the tropical SPB: in the tropical semiring (ℝ∪{∞}, min, +), SPB tropicalizes to:
```
spb_trop(x, y) = min(x, y) − max(x+y, 0)
```
or similar. Study:
- Does tropical SPB form a tropical group?
- What are the tropical analogues of the norm identity?
- Applications to optimization and machine learning

### 3.2 p-adic SPB

Study spb(x,y) over ℚ_p:
- Identify the p-adic domain of convergence
- Characterize the resulting p-adic Lie group
- Find the p-adic Cayley transform

### 3.3 SPB in Quantum Computing

The Bloch sphere uses stereographic projection. Express:
- Single-qubit rotations as SPB operations
- Universal gate sets via SPB
- Solovay-Kitaev approximation in SPB coordinates

### 3.4 Cocycle Cohomology

The function c(x,y) = 1/(1−xy) satisfies the group cocycle condition. Determine:
- The cohomology class in H²(S¹, ℝ*)
- Whether it's a coboundary (expected: yes, with cochain f(x) = 1+x²)
- Connections to the Schur multiplier of SO(2)

### 3.5 SPB-EML Category Theory

Define the category SPB with:
- Objects: fields F
- Morphisms: field homomorphisms preserving SPB
Study functors to Grp, Ring, and the relationship to EML.

---

## Priority 4: Long-term / Speculative (1+ years)

### 4.1 SPB and the Langlands Program

The SPB matrices M(n) = [[1,n],[-n,1]] generate a subgroup of SL(2,ℤ).
- Determine its index
- Find the associated modular curve
- Study automorphic forms for this subgroup

### 4.2 SPB and Quantum Field Theory

The Wick rotation (t → it) corresponds to the sign flip in SPB (1−xy ↔ 1+xy).
- Can SPB provide a rigorous framework for Wick rotations in interacting QFTs?
- Connection to Osterwalder-Schrader axioms?

### 4.3 SPB Information Geometry

The Fisher metric on Cauchy distributions should be related to the hyperbolic metric.
- Prove: SPB acts as isometries of the Fisher metric
- Construct optimal statistical estimators using SPB structure
- Connect to natural gradient methods in machine learning

### 4.4 Division Algebra SPB

The SPB dimension sequence {1, 3, 7} matches the division algebra dimensions {ℝ, ℍ, 𝕆} minus one.
- Prove this is not a coincidence: the SPB group operation exists iff a division algebra exists
- Connect to the Hurwitz theorem
- Formalize in Lean 4

---

## New Algorithmic Ideas

### Algorithm 1: SPB-CORDIC

The CORDIC algorithm computes trig functions via iterated pseudo-rotations. Each step is:
```
x_{n+1} = x_n − d_n · y_n · 2^{-n}
y_{n+1} = y_n + d_n · x_n · 2^{-n}
```
In SPB coordinates (t = y/x), this becomes:
```
t_{n+1} = spb(t_n, d_n · 2^{-n})
```
**Advantage**: Single scalar operation instead of two parallel operations.

### Algorithm 2: SPB Gradient Descent

For optimization on the circle (e.g., phase estimation):
```
θ_{n+1} = θ_n − η · ∇f(θ_n)
```
In SPB coordinates (t = tan(θ/2)):
```
t_{n+1} = spb(t_n, −η · ∇f(t_n) / (1 + t_n²))
```
**Advantage**: Intrinsic optimization on S¹ without angle wrapping.

### Algorithm 3: EML Function Compiler

Compile arbitrary elementary functions into EML expression trees:
1. Parse the function into an AST
2. Replace each operation with its EML equivalent
3. Optimize the EML tree (common subexpression elimination)
4. Execute with minimal exp/log evaluations

### Algorithm 4: SPB Kalman Filter

For state estimation with angular variables:
- State update: x_{k|k} = spb(x_{k|k-1}, K_k · innovation)
- Prediction: x_{k+1|k} = spb(x_{k|k}, u_k)
**Advantage**: No angle wrapping, natural handling of circular uncertainty.

---

## Key Hypotheses to Test

| # | Hypothesis | Method | Expected Outcome |
|---|-----------|--------|------------------|
| H1 | SPB neurons beat MLPs on periodic data | Train & compare | 10-30% improvement |
| H2 | Random SPB → Cauchy invariant measure | Monte Carlo simulation | Confirmed |
| H3 | SPB(F_p) order = p±1 law | Enumerate for p < 10000 | Confirmed |
| H4 | 3D SPB = quaternion multiplication | Symbolic verification | Confirmed |
| H5 | SPB trees approximate at Chebyshev rate | Numerical experiments | O(ρ⁻ⁿ) rate |
| H6 | EML complexity of SPB = 3 | Lower bound argument | Likely true |
| H7 | Tropical SPB forms a group | Algebraic verification | Partially (semigroup) |
| H8 | SPB Kalman filter avoids angle wrapping | Control experiment | Confirmed |
| H9 | SPB-CORDIC is faster than standard CORDIC | Hardware simulation | ~15% speedup |
| H10 | SPB cocycle is a coboundary | Cohomological computation | Confirmed |

---

## Recommended Team Structure

- **Pure Mathematics**: Higher-dim SPB, finite fields, cohomology, modular forms
- **Applied Mathematics**: Approximation theory, PDEs, continued fractions
- **Physics**: Thomas precession, Bloch sphere, Wick rotation, information geometry
- **Computer Science**: Neural networks, cryptography, CORDIC hardware
- **Engineering**: Signal processing, robotics, filter design
- **Formalization**: Lean 4 library extension, Mathlib integration

Each team member should have access to:
1. The Lean 4 formalization (for rigorous verification)
2. The Python demo suite (for rapid experimentation)
3. This research directions document (for context)

---

*Document version: 1.0 | Date: 2026-04-14*
