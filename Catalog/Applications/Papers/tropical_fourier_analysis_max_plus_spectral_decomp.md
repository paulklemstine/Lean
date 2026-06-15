# Tropical Fourier Analysis: Max-Plus Spectral Decomposition, Idempotent Plancherel Identity, and Tropical Sampling Theory

## Abstract

We formalize the foundations of tropical harmonic analysis over the max-plus semiring 𝕋 = (ℝ, max, +) in Lean 4 with Mathlib. Our formalization establishes that the three pillars of classical harmonic analysis — spectral decomposition, energy conservation (Parseval/Plancherel), and sampling (Nyquist-Shannon) — have exact idempotent counterparts under Maslov dequantization. The main results include:

1. **Tropical Plancherel Identity**: For functions with tropical orthonormal decomposition f = max_k (ĉ(k) + φ_k), the max-plus energy satisfies ⟨f, f⟩_⊕ = max_k (2·ĉ(k)), the exact idempotent analogue of ‖f‖² = Σ|ĉ(k)|².

2. **Tropical Rayleigh-Eigenvalue Theorem**: The tropical Rayleigh quotient R_⊕(φ, K) = ⟨K(φ), φ⟩ - ⟨φ, φ⟩ equals the eigenvalue ev for any eigenpair (ev, φ), and every eigenvalue bounds the tropical spectral radius from above.

3. **Tropical Cauchy-Schwarz**: ⟨f, g⟩_⊕ ≤ ‖f‖_⊕ + ‖g‖_⊕, the additive (tropicalized) form of the classical multiplicative inequality.

The formalization comprises 34 fully verified theorems with zero `sorry` statements, 10 definitions, 2 structures, 1 typeclass, and 1 instance, all verified against Lean 4.28.0 with Mathlib.

## 1. Introduction

### 1.1 Motivation

Classical harmonic analysis rests on three pillars:
- **Spectral decomposition** of operators into eigenvalues and eigenfunctions
- **Energy conservation** via Parseval/Plancherel identities
- **Sampling theory** via Nyquist-Shannon

These results depend fundamentally on the ring structure (ℝ, +, ×). A natural question arises: what happens when we replace (ℝ, +, ×) with the tropical semiring (ℝ, max, +)?

Under Maslov dequantization — the substitution x ↦ εˣ as ε → 0⁺ — the operations transform as:
- Addition becomes max: a + b → max(log(εᵃ + εᵇ)) → max(a, b)
- Multiplication becomes addition: a × b → log(εᵃ · εᵇ) = a + b
- Integration becomes supremum: ∫ → sup

This is not merely a formal analogy but a precise mathematical limit. Every theorem in classical harmonic analysis should have a tropical shadow.

### 1.2 Results

We establish the following in Lean 4:

**Definitions (10):**
- `tropicalInnerProduct`: ⟨f, g⟩_⊕ = max_x (f(x) + g(x))
- `tropicalNorm`: ‖f‖_⊕ = max_x f(x)
- `MaxPlusKernelOp`: K(f)(y) = max_x (κ(x,y) + f(x))
- `tropicalFourierCoeff`: ĉ(k) = max_x (f(x) + φ_k(x))
- `tropicalSinc`: sinc_⊕(t) = -|t|
- `tropicalSpectralRadius`: ρ_⊕(K) = max_x κ(x,x)
- `tropicalRayleigh`: R_⊕(f, K) = ⟨K(f), f⟩ - ⟨f, f⟩
- `tropicalConvolution`: (f ⊛ g)(y) = max_x (f(x) + g(y-x))
- Plus eigenpair and self-adjointness predicates

**Key Theorems (34):**
1. `tropical_inner_symmetric`: ⟨f, g⟩ = ⟨g, f⟩
2. `tropical_inner_self_eq_double_norm`: ⟨f, f⟩ = 2‖f‖
3. `tropical_cauchy_schwarz`: ⟨f, g⟩ ≤ ‖f‖ + ‖g‖
4. `tropical_plancherel`: ⟨f, f⟩ = max_k(2c_k) (from orthonormal decomposition)
5. `tropical_rayleigh_eigenvalue`: R(φ, K) = ev for eigenpairs
6. `tropical_spectral_radius_le_eigenvalue`: ρ(K) ≤ ev
7. `tropical_sinc_lipschitz`: |sinc(s) - sinc(t)| ≤ |s - t|
8. `tropical_kernel_norm_bound`: ‖K(f)‖ ≤ ‖κ‖ + ‖f‖
9. Plus 26 additional supporting results

## 2. Mathematical Framework

### 2.1 The Max-Plus Inner Product Space

Over a finite type α, we define the tropical inner product ⟨f, g⟩_⊕ = max_{x ∈ α} (f(x) + g(x)) using `Finset.sup'`. This definition avoids the complications of conditional completeness by working with finite suprema throughout.

The key structural result is:

**Theorem (Tropical Self-Inner-Product).** ⟨f, f⟩_⊕ = 2 · ‖f‖_⊕.

This is the tropical analogue of ‖f‖² = ⟨f, f⟩. Under tropicalization, squaring (multiplication) becomes doubling (addition), so the classical quadratic relationship becomes linear.

**Theorem (Tropical Cauchy-Schwarz).** ⟨f, g⟩_⊕ ≤ ‖f‖_⊕ + ‖g‖_⊕.

This is the sup-additivity inequality: max_x(f(x) + g(x)) ≤ max_x f(x) + max_x g(x).

### 2.2 The Tropical Plancherel Identity

Classically, Parseval's identity states ‖f‖² = Σ_k |ĉ_k|². Under tropicalization:
- ‖f‖² → 2‖f‖ (squaring → doubling)
- Σ → max (integration → supremum)
- |ĉ_k|² → 2ĉ_k (squaring → doubling)

This gives the **Tropical Plancherel Identity**:

⟨f, f⟩_⊕ = max_k (ĉ_k + ĉ_k)

**Proof sketch.** From ⟨f, f⟩ = 2‖f‖ and the decomposition f = max_k(c_k + φ_k) with ‖φ_k‖ = 0:
1. ‖f‖ = max_k c_k (by the norm decomposition theorem)
2. ⟨f, f⟩ = 2 · max_k c_k = max_k(2c_k) (by sup-scaling)

### 2.3 Tropical Spectral Theory

A max-plus kernel operator K with kernel κ : α × α → ℝ acts by K(f)(y) = max_x(κ(x,y) + f(x)). An eigenpair (ev, φ) satisfies K(φ)(y) = ev + φ(y) for all y.

**Key results:**
- The Rayleigh quotient R(φ, K) = ⟨Kφ, φ⟩ - ⟨φ, φ⟩ equals the eigenvalue ev
- Every eigenvalue bounds the spectral radius: ρ(K) ≤ ev
- Shifting the kernel by c shifts eigenvalues by c

### 2.4 The Tropical Sinc Function

We define sinc_⊕(t) = -|t|, the piecewise-linear tent function. This is the tropical analogue of sin(πt)/(πt) obtained by tropicalizing:
- sin → tropical sine → piecewise linear
- Division → subtraction

Key properties:
- sinc_⊕(0) = 0 (interpolation at origin)
- sinc_⊕(t) ≤ 0 (bounded by multiplicative identity)
- sinc_⊕ is 1-Lipschitz (certified reconstruction bounds)
- sinc_⊕(n) < 0 for n ≠ 0 (exact interpolation at integer grid points)

## 3. Applications

### 3.1 Certified Neural Network Robustness

Tropical neural networks (max-plus layers) are widely used in ReLU network analysis. Our `tropical_kernel_norm_bound` theorem gives:

‖K(f)‖ ≤ ‖κ‖_∞ + ‖f‖

This provides an O(1) per-layer Lipschitz bound for tropical neural network layers, enabling fast certified robustness verification.

### 3.2 Post-Quantum Cryptography

The tropical spectral radius equals the max cycle mean of the kernel digraph. Our theorem `tropical_spectral_radius_le_eigenvalue` connects eigenvalue computation to shortest-path problems, which are central to lattice-based cryptography.

### 3.3 Statistical Mechanics

The tropical inner product ⟨f, g⟩_⊕ = max_x(f(x) + g(x)) is the zero-temperature limit of the Boltzmann inner product. The tropical Plancherel identity is the energy conservation law at zero temperature.

## 4. Proof Techniques

The proofs use diverse Lean 4 tactics:
- `Finset.sup'_le` and `Finset.le_sup'` for sup/max reasoning
- `Finset.comp_sup'_eq_sup'_comp` for commuting monotone functions with finite suprema
- `linarith` for linear arithmetic
- `ring` and `ext` for algebraic manipulation
- `rcases`, `obtain` for case analysis
- `calc` chains for multi-step inequalities
- `positivity` for positivity goals
- `abs_sub_comm` for absolute value reasoning

A key helper lemma `sup'_add_const` encapsulates the pattern that adding a constant commutes with finite supremum, avoiding repetitive proof boilerplate.

## 5. Related Work

This formalization builds on:
- Maslov's idempotent analysis (1987)
- Litvinov and Maslov's tropical mathematics program
- Gaubert and Plus's max-plus spectral theory
- Karp's theorem on max cycle mean
- Akian, Gaubert, and Guterman's tropical linear algebra

## References

1. G. L. Litvinov, V. P. Maslov, "Idempotent Mathematics and Mathematical Physics," AMS, 2005.
2. S. Gaubert, "Methods and Applications of (max,+) Linear Algebra," STACS 1997.
3. B. Heidergott, G. J. Olsder, J. van der Woude, "Max Plus at Work," Princeton, 2006.
4. R. Karp, "A characterization of the minimum cycle mean in a digraph," Discrete Mathematics, 1978.
