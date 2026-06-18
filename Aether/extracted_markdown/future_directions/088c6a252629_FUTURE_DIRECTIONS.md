# Future Directions: Spectral Calculus on Ternary Word Cubes

## Overview

The product noise operator `productNoise` on `BerggrenWordSpace L = Fin L → Fin 3` now has a fully certified spectral decomposition: degree-`d` functions are eigenspaces with eigenvalue `ρ^d`. This creates a foundation for several breakthrough research directions.

---

## 1. Hypercontractivity on Ternary Product Spaces

### Theorem Statement (Target)
For `2 ≤ q ≤ 1 + 2ρ/(1-ρ)` (ternary Bonami–Beckner condition):
```
‖T_ρ f‖_q ≤ ‖f‖_2
```
where norms are with respect to uniform measure on `(Fin 3)^L`.

### Why It Matters
Hypercontractivity is the engine behind sharp threshold results, KKL-type influence inequalities, and hardness amplification. The ternary case extends the classical Boolean theory (Bonami 1970, Beckner 1975) to non-binary alphabets, opening applications to symbolic dynamics on Berggren trees and ternary coding theory.

### Proof Strategy
1. Prove the single-site hypercontractive inequality for `singleSiteNoise` on `Fin 3 → ℝ` using the explicit 2-dimensional mean-zero eigenspace.
2. Tensorize using the product structure: the product noise operator factors as independent single-site operators.
3. The key estimate: for a mean-zero function `g` on `Fin 3`, show `‖ρg‖_q ≤ ‖g‖_2` under the Bonami–Beckner condition.

### Dependencies
- `coordNoise_meanZeroAt`, `coordNoise_constantAt` (present work)
- `productNoise_eigen_on_homogeneousDegree` (present work)
- Lp space API from Mathlib (`MeasureTheory.Lp`)

---

## 2. KKL/Influence Theory for Ternary Observables

### Theorem Statement (Target)
For any balanced function `f : (Fin 3)^L → {-1, 0, 1}`:
```
max_i Inf_i(f) ≥ C · Var(f) · log(L) / L
```
where `Inf_i(f) = E[Var_{x_i}[f(x)]]` is the coordinate influence.

### Why It Matters
The KKL theorem (Kahn–Kalai–Linial 1988) is one of the deepest results in Boolean analysis, with applications from social choice theory to computational complexity. Extending it to ternary alphabets would give influence lower bounds for observables on Berggren-generated Pythagorean data.

### Proof Strategy
1. Define coordinate influences via the degree-1 Fourier mass.
2. Use hypercontractivity (Direction 1) to control the influence sum.
3. Apply the entropy–influence method of Kahn–Kalai–Linial, adapted to `q = 3`.

### Dependencies
- Hypercontractivity (Direction 1)
- `homogeneousDegreeSubmodule` decomposition (present work)
- Shannon entropy formalization in Mathlib

---

## 3. Exact Decomposition Equivalence

### Theorem Statement (Target)
```lean
theorem degreeLeSubmodule_eq_iSup_homogeneous (L k : ℕ) :
    degreeLeSubmodule L k = ⨆ (d : Fin (k + 1)), homogeneousDegreeSubmodule L d
```

The submodule of functions depending on at most `k` coordinates equals the sum of homogeneous degree sectors `0, 1, ..., k`.

### Why It Matters
This bridges two natural definitions of "low degree": one combinatorial (depending on few coordinates) and one spectral (small Fourier weight on high frequencies). Their equivalence is a foundational result in Boolean Fourier analysis that hasn't been formalized for non-binary alphabets.

### Proof Strategy
1. **Forward inclusion**: A function depending on coordinates `S` with `|S| ≤ k` lies in the span of homogeneous sectors of degree ≤ k. Prove by writing the function in the product basis and observing that each basis function has degree ≤ |S|.
2. **Backward inclusion**: A function in homogeneous degree `d ≤ k` depends on at most `d ≤ k` coordinates by definition.
3. Key lemma: every function on `(Fin 3)^L` has a unique decomposition into homogeneous degree sectors.

### Dependencies
- `degreeLeSubmodule`, `homogeneousDegreeSubmodule` (present work)
- Linear algebra: direct sum decomposition
- Orthogonality of homogeneous sectors (new)

---

## 4. Thermodynamic Formalism Bridge

### Theorem Statement (Target)
For the Berggren transfer operator `L_φ` with potential `φ` depending on the first `k` coordinates:
```lean
theorem transfer_operator_spectral_factorization :
    ∃ (T : BerggrenFn L →ₗ[ℝ] BerggrenFn L),
      (∀ f, L_φ f = productNoise L ρ (T f)) ∧
      T.eigenvalues ⊆ {eigenvalues depending only on φ|_{Fin k}}
```

### Why It Matters
The Ruelle–Perron–Frobenius transfer operator is the central object in thermodynamic formalism. Showing that it factors through the product noise operator connects the spectral theory of statistical mechanics to the explicit finite-dimensional decomposition we've built.

### Proof Strategy
1. Define the Berggren transfer operator as a weighted version of `productNoise`.
2. Show the weight function (potential) decomposes in the degree filtration.
3. Use the eigenspace structure to diagonalize the transfer operator.

### Dependencies
- `productNoise_eigen_on_homogeneousDegree` (present work)
- Ruelle operator API (to be built)
- Existing `ThermodynamicFormalism/SpectralBounds.lean`

---

## 5. Arithmetic Observable Bias on Pythagorean Data

### Theorem Statement (Target)
For a Berggren random walk of length `n` starting from triple `(3, 4, 5)`, and any arithmetic observable `f` of degree `d` (depending on `d` matrix choices):
```
|E[f(walk)] - E_uniform[f]| ≤ ρ^d · ‖f‖₂ · (1/2)^n
```

### Why It Matters
This gives quantitative pseudorandomness guarantees for statistics of Berggren-generated Pythagorean triples. It shows that any "simple" test (depending on few coordinates) cannot distinguish a random walk on the Berggren tree from uniform sampling, with exponential decay.

### Proof Strategy
1. Model the Berggren walk as `n` steps of a transition operator `T` on `Fin 3 → ℝ`.
2. Decompose the observable `f` using `productNoise_eigen_on_homogeneousDegree`.
3. Apply `bias_bound_of_spectral_decay` from `SpectralPseudorandomness.lean` with the eigenvalue bound `ρ^d`.
4. Combine the degree-`d` eigenvalue decay with the `(1/2)^n` mixing of the Berggren sibling walk.

### Dependencies
- `productNoise_eigen_on_homogeneousDegree` (present work)
- `bias_bound_of_spectral_decay` (existing in `SpectralPseudorandomness.lean`)
- `berggren_sibling_spectral_decay` (existing)
- Composition of spectral decay bounds (new lemma)

---

## Priority Ranking

1. **Direction 3** (Decomposition equivalence) — easiest, most immediately useful
2. **Direction 5** (Arithmetic observable bias) — directly uses existing infrastructure
3. **Direction 1** (Hypercontractivity) — foundational, medium difficulty
4. **Direction 2** (KKL/influence) — deep, depends on hypercontractivity
5. **Direction 4** (Thermodynamic formalism) — ambitious, connects to broader program

Each direction builds on the spectral infrastructure established in this work. The product noise operator `productNoise L ρ` with its certified eigenvalue decomposition `λ_d = ρ^d` is the common foundation.
