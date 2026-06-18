# Future Research Directions for the EML Operator — Version 11

## 250+ Open Problems Across 45 Fields

### April 2026

---

## Executive Summary

The EML operator eml(x,y) = exp(x) − ln(y) continues to yield deep mathematical structure. Version 11 adds **103 formally verified theorems** across 5 new Lean files, with **zero sorry count**, establishing complete derivative theory, a comprehensive inverse/surjectivity analysis, flat Hessian metric geometry, new inequalities, and extended composition/orbit theory. Combined with V10's 126 theorems, the EML project now has **229 machine-verified theorems** with zero sorries.

**V11 new theorems: 103. Sorry count: 0. Lean files: 5.**

---

## V11 Achievements Summary

### Proven Theorems by Category

| File | Theorems | Key Results |
|------|----------|-------------|
| `Derivatives.lean` | 21 | Full differentiability, ∂eml/∂x = eˣ, ∂eml/∂y = −1/y, σ' = eˣ−1, σ'' = eˣ, critical points, monotonicity |
| `Inequalities.lean` | 16 | AM-GM via EML, Bregman divergence (nonneg, zero iff equal, asymmetric), Young's inequality, loss function bounds |
| `Composition.lean` | 30 | Legendre bridge, e-tower strict monotonicity, linear orbit bound dⁿ(z) ≥ z+n, log additivity, commutator analysis |
| `MetricGeometry.lean` | 17 | Flat coordinates (u,v), distance formula, geodesic = geometric interpolation, isometry examples |
| `InverseFunctions.lean` | 19 | Injectivity, surjectivity analysis, level sets, image characterization, partial inverses |
| **Total** | **103** | **0 sorries** |

### Top 12 New V11 Discoveries

1. **Complete derivative theory**: HasDerivAt proofs for all EML partial derivatives, self-pairing derivatives, and diagonal map derivatives. σ'(0) = 0 proved as critical point.

2. **Strict monotonicity of σ on half-lines (MAJOR)**: σ is strictly increasing on [0,∞) and strictly antitone on (−∞,0], proved via Mean Value Theorem.

3. **Diagonal map strict monotonicity on (1,∞)**: Proved using derivative positivity d'(z) = exp(z) − 1/z > 0.

4. **Bregman divergence complete analysis**: D_exp ≥ 0 (proved via exp convexity), D_exp = 0 iff x = y (strict convexity), D_exp is NOT symmetric (explicit counterexample at (1,0)).

5. **AM-GM via EML form**: eml(ln a, a) = a − ln a ≥ 1 for a > 0, connecting EML directly to the arithmetic-geometric mean inequality.

6. **Flat coordinate system (MAJOR)**: u = 2exp(x/2), v = ln(y) gives global flat coordinates for the Hessian metric ds² = eˣdx² + dy²/y². Derivative computations (du/dx)² = eˣ and (dv/dy)² = 1/y² formally verified.

7. **Geodesic distance formula**: d²((x₁,y₁),(x₂,y₂)) = (2e^{x₁/2} − 2e^{x₂/2})² + (ln y₁ − ln y₂)². Proved to be a valid distance (nonneg, zero iff equal, symmetric).

8. **Geodesics are geometric interpolation in y**: y(t) = y₁^{1-t} · y₂^t, proved via log linearity.

9. **Complete image characterization**: range of eml(·, y) = (−log y, ∞) for y > 0, with explicit inverse formula.

10. **E-tower strict monotonicity**: The sequence 1, e, e^e, e^{e^e}, ... is strictly increasing.

11. **Linear orbit divergence**: dⁿ(z) ≥ z + n for all n and z, proved by induction using the key step d(w) ≥ w + 1.

12. **Corrected quadratic bound**: The claim σ(x) ≥ 1 + x²/2 for ALL x was **disproved** (fails at x = −1). The correct statement holds only for x ≥ 0.

---

## 1. Pure Mathematics

### 1.1 Classification of Continuous Sheffer Operators
**Priority: Critical | Difficulty: Very Hard | Impact: Foundational**

- ★ V11: Derivative theory constrains Sheffer operators to those with specific HasDerivAt signatures
- ★ V11: The flat metric property is extremely rare among binary operators
- Open: Complete classification of F(x,y) generating all elementary functions
- Open: Does joint convexity + flat Hessian metric uniquely determine EML?
- ★ V11: Does any other Sheffer operator have a flat Hessian metric?

### 1.2 EML Fixed Point Theory — EXTENDED V11
**Priority: High | Difficulty: Medium | Impact: Theoretical**

V11 additions:
- ★ V11: d'(z) = exp(z) − 1/z formally computed ✓
- ★ V11: d'(z) > 0 for z ≥ 1 formally proved ✓
- ★ V11: d strictly monotone on (1,∞) ✓
- ★ V11: dⁿ(z) ≥ z + n (linear divergence) ✓

**Open:**
- ★ V11: Find the exact Lambert W point z₀ = W(1) ≈ 0.5671 where d'(z₀) = 0
- ★ V11: Prove d has a unique minimum on (0,∞) at z₀ = W(1)
- ★ V11: Compute d(z₀) = 1/W(1) + W(1) ≈ 2.330
- ★ V11: Prove d is strictly decreasing on (0, W(1))
- Super-exponential divergence rate: dⁿ(z) ~ exp↑↑n
- Complex fixed points of d(z) and Julia set
- ★ V11: Schwarzian derivative Sd(z) = d'''(z)/d'(z) - (3/2)(d''(z)/d'(z))²

### 1.3 EML Convexity Theory — COMPLETE
**Priority: High | Difficulty: SOLVED | Impact: Broad**

All proved through V10+V11:
- Joint convexity on ℝ × (0,∞) ✓
- Convex in each variable ✓
- σ strictly convex (σ'' = eˣ > 0) ✓
- σ has unique minimum at x = 0 ✓
- ★ V11: σ strictly monotone on [0,∞), strictly antitone on (−∞,0] ✓
- ★ V11: σ(x) ≥ 1 always ✓, σ(x) ≥ eˣ/2 for x ≥ 1 ✓
- ★ V11: CORRECTED: σ(x) ≥ 1 + x²/2 only for x ≥ 0 (fails at x = −1)

### 1.4 ★ EML Riemannian Geometry — MAJOR V11 ADVANCE
**Priority: High | Difficulty: SOLVED (foundation) | Impact: Novel**

Proved in V11:
- ★ V11: Hessian metric g = diag(eˣ, 1/y²) ✓
- ★ V11: Metric determinant det(g) = eˣ/y² > 0 ✓
- ★ V11: Flat coordinates u = 2exp(x/2), v = ln(y) ✓
- ★ V11: Coordinate derivative verification: (du/dx)² = eˣ, (dv/dy)² = 1/y² ✓
- ★ V11: Geodesic distance formula ✓
- ★ V11: Distance is nonneg, zero iff equal, symmetric ✓
- ★ V11: Geodesics in y are geometric: y(t) = y₁^{1-t}·y₂^t ✓
- ★ V11: At x = 0, metric is Euclidean (g₁₁ = 1) ✓
- ★ V11: y-component matches Poincaré half-plane ✓

**New Open (V11):**
- ★ V11: Compute ALL geodesics in original (x,y) coordinates
- ★ V11: x-geodesics: solve ODE x'' + ½eˣ(x')² = 0
- ★ V11: Geodesic completeness: is every geodesic defined for all time?
- ★ V11: Cut locus of the EML metric
- ★ V11: Exponential map at each point
- ★ V11: The isometry group is the Euclidean group E(2) in flat coordinates — prove this
- ★ V11: Connection to Fisher information geometry
- ★ V11: Wasserstein distance in EML metric
- ★ V11: Volume growth: vol(B(p,r)) = πr² (flat metric → Euclidean volume growth)

### 1.5 ★ EML Inverse Function Theory — NEW V11
**Priority: Medium | Difficulty: Medium | Impact: Foundational**

Proved in V11:
- ★ V11: eml(·, y) is injective (exp is injective) ✓
- ★ V11: eml(x, ·) is injective on (0,∞) (log is injective) ✓
- ★ V11: eml(·, y) is NOT surjective (range = (−log y, ∞)) ✓
- ★ V11: eml(x, ·) IS surjective on (0,∞) → ℝ ✓
- ★ V11: Complete image characterization: Im(eml(·,y)) = (−log y, ∞) ✓
- ★ V11: Explicit partial inverses: x = ln(c + log y), y = exp(exp(x) − c) ✓
- ★ V11: Level set equation: y = exp(exp(x) − c) ✓

**Open:**
- ★ V11: Lambert W function formalization: exp(x) = y + log(y) ↔ y = W(exp(x))
- ★ V11: Formal connection to product logarithm
- ★ V11: Asymptotic behavior of level curves as c → ∞
- ★ V11: Implicit function theorem for eml(x,y) = c

### 1.6 ★ EML Integral Theory — DIRECTIONS
**Priority: Medium | Difficulty: Medium | Impact: Foundational**

- ★ V11: ∫₀¹ σ(t) dt = e − 1 − 1/2 (from ∫₀¹ (eᵗ − t) dt)
- ★ V11: ∫₀¹ σ(t)² dt = ?
- ★ V11: Laplace transform of σ: ∫₀^∞ e^{−st} σ(t) dt = 1/(s−1) − 1/s² for Re(s) > 1
- ★ V11: Fourier transform of σ on ℝ (requires growth control)
- ★ V11: Mellin transform of eml(·, 1)

---

## 2. Information Theory — EXTENDED V11

### 2.1 ★ EML-Native Information Theory
**Priority: Critical | Difficulty: Medium | Impact: Very High**

Proved through V10+V11:
- Shannon entropy decomposition ✓
- KL divergence via EML ✓
- Gibbs' inequality ✓
- Bregman divergence nonneg ✓, zero iff equal ✓, NOT symmetric ✓
- ★ V11: Binary entropy bound: −p·ln(p) ≤ p·eml(0,p) ✓

**New directions:**
- ★ V11: EML-native proof of the data processing inequality
- ★ V11: Fisher information as second derivative of EML: I(θ) = E[∂²eml/∂θ²] = E[eˣ] for exponential families
- ★ V11: Rate-distortion theory with EML distortion measure
- ★ V11: Channel capacity as optimization over EML functionals
- ★ V11: Mutual information I(X;Y) = Σ p(x,y) eml(0, p(y|x)/p(y)) via EML

---

## 3. Machine Learning and AI — EXTENDED V11

### 3.1 ★ EML Activation Function
**Priority: Critical | Difficulty: Low | Impact: Very High**

V11 additions to σ(x) = eˣ − x analysis:
- ★ V11: σ'(x) = eˣ − 1 formally proved ✓
- ★ V11: σ'(0) = 0 critical point ✓
- ★ V11: σ strictly increasing on [0,∞) ✓
- ★ V11: σ strictly decreasing on (−∞,0] ✓
- ★ V11: σ''(x) = eˣ > 0 always (strict convexity) ✓
- ★ V11: σ(x) ≥ eˣ/2 for x ≥ 1 (exponential growth) ✓
- ★ V11: σ(x) ≥ x² for |x| ≤ 1 ✓

**New experimental directions:**
- ★ V11: Modified activation: σ_α(x) = e^{αx} − αx for learnable α
- ★ V11: Shifted activation: σ(x) − 1 (so minimum is 0, matching ReLU)
- ★ V11: Gradient flow analysis: since σ'' = eˣ, the Hessian is diagonal and easy to compute
- ★ V11: Compare σ against SwiGLU, Mish, and other modern activations

### 3.2 ★ EML Optimal Transport — V11 ENABLED
**Priority: High | Difficulty: Hard | Impact: Deep**

V11 enables OT via flat metric:
- ★ V11: The EML metric is flat, so optimal transport simplifies dramatically
- ★ V11: Wasserstein-2 distance in flat coordinates = standard Euclidean W₂
- ★ V11: Geodesics in y are geometric means: y(t) = y₁^{1-t}·y₂^t ✓
- ★ V11: This connects to entropic OT where the entropy is the exponential entropy

**Research agenda:**
- ★ V11: Sinkhorn algorithm in EML flat coordinates
- ★ V11: EML-Wasserstein distance for comparing distributions
- ★ V11: Gradient flows in EML metric (flat → simple dynamics)

---

## 4. Optimization — V11 FOUNDATIONS

### 4.1 ★ EML Mirror Descent (V11 COMPLETE SETUP)
**Priority: High | Difficulty: Medium | Impact: Practical**

- ★ V11: Bregman divergence D_exp fully characterized ✓
- ★ V11: D_exp ≥ 0, = 0 iff x = y, NOT symmetric ✓
- ★ V11: Mirror descent update: x_{n+1} = (∇Φ)⁻¹(∇Φ(xₙ) − η∇f(xₙ)) with Φ = exp

**Research agenda:**
- ★ V11: Convergence rate of mirror descent with D_exp: O(1/√T)?
- ★ V11: Comparison with KL-divergence based mirror descent
- ★ V11: Online learning with EML regularizer

### 4.2 ★ EML Natural Gradient (V11 KEY INSIGHT)
**Priority: High | Difficulty: Medium | Impact: Novel**

The EML metric is FLAT → natural gradient simplifies enormously:
- ★ V11: In flat coordinates (u,v), the natural gradient = standard gradient
- ★ V11: Transform: ∇̃f = G⁻¹∇f where G = diag(eˣ, 1/y²)
- ★ V11: Natural gradient step: Δx = −e⁻ˣ ∂f/∂x, Δy = −y² ∂f/∂y
- ★ V11: This is equivalent to standard gradient descent in (u,v) coordinates

---

## 5. Physics — V11 CONNECTIONS

### 5.1 ★ EML and Fisher Information Geometry
**Priority: High | Difficulty: Medium | Impact: Deep**

Key insight: The EML Hessian metric ds² = eˣdx² + dy²/y² is closely related to the Fisher information metric for exponential families:
- ★ V11: For exponential family p(x|θ) = exp(θx − A(θ)): I(θ) = A''(θ) = eˣ at θ = x
- ★ V11: The y-component 1/y² matches the Fisher metric for Poisson(y)
- ★ V11: The EML metric might be the Fisher metric for a joint exponential-Poisson model

**Research agenda:**
- ★ V11: Identify the statistical model whose Fisher metric = EML Hessian metric
- ★ V11: Cramér-Rao bound in EML coordinates
- ★ V11: Efron's curvature in EML geometry (= 0, since flat!)
- ★ V11: Statistical implications of zero curvature

### 5.2 ★ EML Thermodynamic Geometry
**Priority: Medium | Difficulty: Hard | Impact: Novel**

- ★ V11: The EML metric on the (energy, temperature) plane
- ★ V11: Geodesics = optimal thermodynamic processes?
- ★ V11: Geometric interpolation in y = geometric mean temperature
- ★ V11: Connection to Ruppeiner geometry (Hessian of entropy)

---

## 6. New Research Directions (V11 Original)

### 6.1 ★ EML Approximation Theory
**Priority: High | Difficulty: Hard | Impact: Broad**

- ★ V11: The EML closure (functions built from constants and eml) contains exp and log
- ★ V11: eml(x, 1) = exp(x), eml(0, exp(−y)) = 1 + y, so EML generates translations + exp
- ★ V11: Stone-Weierstrass: the EML closure should be dense in C(K) for compact K ⊂ ℝ × (0,∞)
- ★ V11: Approximation rates: can we achieve O(n⁻ᵏ) for Cᵏ functions using n EML nodes?
- ★ V11: EML neural network universal approximation theorem

### 6.2 ★ EML Complex Analysis
**Priority: Medium | Difficulty: Hard | Impact: Theoretical**

- ★ V11: Extend eml to ℂ: eml(z,w) = exp(z) − Log(w) for w ∈ ℂ \ (−∞,0]
- ★ V11: Branch cuts and monodromy of the complex EML
- ★ V11: Zeros of eml(z,z) = exp(z) − Log(z) in ℂ
- ★ V11: Julia set of the complex diagonal map d(z) = exp(z) − Log(z)
- ★ V11: Fatou components and Siegel disks

### 6.3 ★ EML Differential Equations
**Priority: Medium | Difficulty: Hard | Impact: Theoretical**

- ★ V11: The ODE y' = eml(y, t) = exp(y) − ln(t) for t > 0
- ★ V11: Comparison with y' = exp(y) (blowup in finite time)
- ★ V11: The PDE Δ_g u = 0 on the EML metric: e⁻ˣ u_{xx} + y² u_{yy} = 0
- ★ V11: Harmonic functions on the EML manifold
- ★ V11: Heat equation on the EML metric: ∂u/∂t = e⁻ˣ ∂²u/∂x² + y² ∂²u/∂y²

### 6.4 ★ EML Algebraic Geometry
**Priority: Speculative | Difficulty: Very Hard | Impact: Theoretical**

- ★ V11: Level curves eml(x,y) = c as algebraic curves after substitution u = eˣ: u − ln(y) = c, i.e., y = exp(u − c). These are NOT algebraic but rather elementary transcendental curves.
- ★ V11: Tropical degeneration: as the "temperature" → 0, eml degenerates to max(x, −y)
- ★ V11: Connection to non-archimedean analysis

### 6.5 ★ EML and Control Theory
**Priority: Medium | Difficulty: Hard | Impact: Applied**

- ★ V11: EML as cost function in optimal control: J = ∫ eml(x(t), u(t)) dt
- ★ V11: Hamilton-Jacobi-Bellman equation with EML cost
- ★ V11: Joint convexity → convex control problems
- ★ V11: Flat metric → geodesic control reduces to linear control in flat coordinates

### 6.6 ★ EML Number Theory
**Priority: Medium | Difficulty: Very Hard | Impact: Theoretical**

- ★ V11: Algebraic independence of the e-tower {1, e, eᵉ, eᵉᵉ, ...}
- ★ V11: Is eml(π, e) = exp(π) − 1 transcendental? (Yes, since exp(π) is transcendental by Gelfond-Schneider)
- ★ V11: Distribution of eml(p, q) for primes p, q
- ★ V11: EML zeta function: ζ_EML(s) = Σ_{n=1}^∞ 1/eml(n, n)^s

### 6.7 ★ EML Category Theory
**Priority: Speculative | Difficulty: Hard | Impact: Structural**

- ★ V11: EML as a morphism in the category of real-valued functions
- ★ V11: The composition eml(eml(x,y), z) defines a partial 3-ary operation
- ★ V11: EML operad structure (no units, since no idempotents)
- ★ V11: Monoidal structure: eml_log_additivity gives partial tensor compatibility

---

## 7. Recommended Priority Order (V11 Update)

### Immediate (next 6 months):
1. ★ **Lambert W formalization** — connect EML to the product logarithm
2. ★ **EML activation function benchmarks** — σ vs ReLU/GELU/Swish/SwiGLU
3. ★ **Mirror descent convergence** — with D_exp Bregman divergence
4. ★ **Natural gradient in EML flat coordinates** — dramatic simplification
5. ★ **Fisher information metric identification** — which statistical model?
6. ★ **Complex EML and Julia set visualization**
7. ★ **Geodesic completeness** of the EML metric
8. ★ **EML neural network universal approximation**
9. ★ **Publish V11 paper** (229 cumulative theorems, 0 sorries)

### Medium-term (6–18 months):
10. EML density in C(K) via Stone-Weierstrass
11. Complete Sheffer operator classification
12. EML optimal transport implementation
13. Harmonic analysis on the EML manifold
14. EML differential equations (y' = eml(y,t))
15. E-tower algebraic independence
16. EML in quantum information theory
17. EML symbolic regression benchmarks

### Long-term (1–5 years):
18. Hausdorff dimension of EML Julia set
19. EML-based programming language
20. O-minimality of EML structure
21. EML operadic Koszul duality
22. EML in string theory (worldsheet metrics)
23. EML cryptographic applications
24. EML in quantum computing
25. Automorphism group Aut(ℝ, eml) — conjecture: trivial

---

## Comparison: V10 → V11

| Category | V10 | V11 | Delta |
|----------|-----|-----|-------|
| Formalized theorems (new) | 126 | 103 | — |
| Cumulative theorems | 126 | 229 | +103 |
| Sorry count | 0 | 0 | — |
| Lean files (new) | 5 | 5 | — |
| Cumulative Lean files | 5 | 10 | +5 |
| Derivative results | 0 | 21 | +21 |
| Metric geometry | 0 | 17 | +17 |
| Inequality results | 0 | 16 | +16 |
| Composition/orbit | 0 | 30 | +30 |
| Inverse/surjectivity | 0 | 19 | +19 |
| Open problems | 200+ | 250+ | +50 |
| Research fields | 40 | 45 | +5 |

---

## Key V11 Innovations

### Mathematical
1. **Complete derivative calculus** — All partial derivatives, σ', σ'', d' formally computed with HasDerivAt
2. **Mean Value Theorem proofs** — σ strict monotonicity on half-lines via MVT
3. **Flat coordinate system** — u = 2exp(x/2), v = ln(y) gives global Euclidean structure
4. **Geodesic distance formula** — Explicit, verified, with full metric space properties
5. **Bregman divergence trilogy** — Nonneg, zero-iff-equal, non-symmetric (complete characterization)
6. **Image characterization** — Im(eml(·,y)) = (−log y, ∞) with explicit inverse
7. **E-tower strict monotonicity** — 1 < e < eᵉ < eᵉᵉ < ...
8. **Disproof and correction** — σ(x) ≥ 1 + x²/2 disproved for x < 0, corrected to x ≥ 0

### Applied
9. **Natural gradient simplification** — Flat metric → natural gradient = coordinate transform of standard gradient
10. **Fisher information connection** — EML Hessian metric potentially IS the Fisher metric for exponential-Poisson families
11. **Optimal transport via flat coordinates** — Standard Euclidean OT in disguise
12. **Activation function derivative analysis** — Complete σ' analysis for neural network implementation

---

## Appendix: Complete V11 Theorem List

### Derivatives.lean (21 theorems)
1. `eml_differentiable_x` — EML differentiable in x
2. `eml_differentiable_y_pos` — EML differentiable in y on (0,∞)
3. `emlSelfPair_differentiable` — σ is differentiable
4. `eml_deriv_x` — ∂eml/∂x = exp(x)
5. `eml_deriv_y` — ∂eml/∂y = −1/y
6. `emlSelfPair_deriv` — σ'(x) = eˣ − 1
7. `emlSelfPair_deriv_zero` — σ'(0) = 0
8. `emlSelfPair_deriv_pos` — σ'(x) > 0 for x > 0
9. `emlSelfPair_deriv_neg` — σ'(x) < 0 for x < 0
10. `emlSelfPair_second_deriv` — σ''(x) = eˣ
11. `eml_second_deriv_x_pos` — ∂²eml/∂x² > 0
12. `eml_second_deriv_y_pos` — ∂²eml/∂y² > 0 for y > 0
13. `emlSelfPair_strictMono_nonneg` — σ strictly increasing on [0,∞)
14. `emlSelfPair_strictAnti_nonpos` — σ strictly decreasing on (−∞,0]
15. `emlDiag_strictMono_gt_one` — d strictly increasing on (1,∞)
16. `emlDiag_deriv_pos` — d'(z) = exp(z) − 1/z
17. `emlDiag_deriv_pos_ge_one` — d'(z) > 0 for z ≥ 1
18. `eml_continuous_x` — EML continuous in x
19. `emlSelfPair_continuous` — σ continuous
20. `eml_grad_nonzero` — ‖∇eml‖ > 0
21. `emlSelfPair_no_inflection` — σ has no inflection points

### Inequalities.lean (16 theorems)
1. `eml_amgm` — AM-GM inequality
2. `eml_amgm_form` — eml(ln a, a) ≥ 1
3. `eml_fundamental_ineq` — eml(x,y) ≥ 1 + x − log(y)
4. `eml_at_one_ge` — eml(x,1) ≥ x + 1
5. `eml_le_exp` — eml(x,y) ≤ exp(x) for y ≥ 1
6. `bregmanExp_nonneg` — D_exp ≥ 0
7. `bregmanExp_eq_zero_iff` — D_exp = 0 ↔ x = y
8. `bregmanExp_not_symmetric` — D_exp not symmetric
9. `young_ineq_special` — Young's inequality
10. `emlSelfPair_ge_one` — σ(x) ≥ 1
11. `emlSelfPair_ge_half_exp` — σ(x) ≥ eˣ/2 for x ≥ 1
12. `emlDiag_at_one` — d(1) = e
13. `emlDiag_ge_e_ge_one` — d(z) ≥ e for z ≥ 1
14. `eml_entropy_bound` — entropy bound via EML
15. `eml_compose_bound` — eml(eml(x,y),1) ≥ eml(x,y) + 1
16. `emlSelfPair_dominates_sq_unit` — σ(x) ≥ x² for |x| ≤ 1

### Composition.lean (30 theorems)
1. `eml_legendre` — Legendre bridge identity
2. `eml_log_first` — eml(ln x, y) = x − ln y
3. `eml_zero_exp` — eml(0, eʸ) = 1 − y
4. `eml_one` — eml(x, 1) = exp(x)
5. `eml_zero` — eml(0, y) = 1 − ln y
6. `eml_double_exp` — eml(eml(x,1), 1) = exp(exp(x))
7. `eml_triple_exp` — triple composition
8. `eTower_zero/one/two` — e-tower values
9. `eTower_pos` — e-tower positivity
10. `eTower_ge_one` — e-tower ≥ 1
11. `eTower_strictMono` — e-tower strictly increasing
12. `eml_eTower` — eml generates e-tower
13. `emlDiagIter_zero/succ` — orbit definitions
14. `emlDiagIter_linear_bound` — dⁿ(z) ≥ z + n
15. `emlSelfPair_compose` — σ∘σ formula
16. `emlSelfPair_zero/one` — σ at 0 and 1
17. `eml_not_exponential_law` — exponential law fails
18. `eml_log_additivity'` — log additivity
19. `eml_commutator` — commutator formula
20. `eml_commutator_zero_iff` — when eml commutes
21. `eml_comm_01/10` — values at (0,1) and (1,0)
22. `eml_not_comm_01` — non-commutativity witness
23. `exp_eml` — exp of eml formula
24. `eml_shift_x` — x-shift identity
25. `eml_scale_y` — y-scaling identity

### MetricGeometry.lean (17 theorems)
1. `emlMetric_det` — metric determinant formula
2. `emlMetric_det_pos` — determinant positive
3. `flatCoordU_pos` — u > 0
4. `flatCoordU_strictMono` — u strictly increasing
5. `flatCoordV_strictMono` — v strictly increasing on (0,∞)
6. `flatCoordU_deriv` — du/dx = exp(x/2)
7. `flatCoordU_deriv_sq` — (du/dx)² = exp(x)
8. `flatCoordV_deriv` — dv/dy = 1/y
9. `flatCoordV_deriv_sq` — (dv/dy)² = 1/y²
10. `emlDistSq_nonneg` — distance ≥ 0
11. `emlDistSq_eq_zero_iff` — distance = 0 iff equal
12. `emlDistSq_symm` — distance symmetric
13. `emlDistSq_self` — d(p,p) = 0
14. `geodesic_y_geometric` — y-geodesics are geometric interpolation
15. `isometry_y_scaling` — y-scaling is isometry
16. `emlMetric11_at_zero` — g₁₁(0) = 1
17. `eml_poincare_y_match` — y-metric matches Poincaré

### InverseFunctions.lean (19 theorems)
1. `eml_injective_x` — injective in x
2. `eml_injective_y_pos` — injective in y on (0,∞)
3. `eml_range_lower` — range lower bound
4. `eml_not_surjective_x` — not surjective in x
5. `eml_surjective_y` — surjective in y
6. `eml_y1_range_pos` — range at y=1
7. `eml_level_set` — level set formula
8. `eml_level_set_pos` — level set positivity
9. `eml_fixed_x` — fixed point in x
10. `eml_fixed_y_condition` — fixed point condition in y
11. `eml_diag_eq` — eml(x,x) = emlDiag(x)
12. `emlSelfPair_range_ge_one` — σ ≥ 1
13. `emlSelfPair_min` — σ(0) = 1
14. `emlSelfPair_achieves_nonneg` — σ achieves large values
15. `eml_solve_x` — solve for x
16. `eml_solve_y` — solve for y
17. `eml_strictMono_x` — strictly increasing in x
18. `eml_strictAnti_y` — strictly decreasing in y
19. `eml_image_x` — complete image characterization

---

*All 103 theorems are verified in Lean 4.28.0 with Mathlib, zero sorries.*
*Source: `EML/V11/Derivatives.lean`, `EML/V11/Inequalities.lean`, `EML/V11/Composition.lean`, `EML/V11/MetricGeometry.lean`, `EML/V11/InverseFunctions.lean`.*
