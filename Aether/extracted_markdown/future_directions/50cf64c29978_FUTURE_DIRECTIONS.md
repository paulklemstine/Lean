# Future Directions: Product Noise and Spectral Structure on Berggren Word Cubes

This document outlines **five breakthrough-level research directions** opened by our formalization of the product noise operator and its exact spectral decomposition on the ternary cube `(Fin 3)^L`.

---

## 1. Hypercontractivity on `Fin 3` Product Spaces (Ternary Bonami–Beckner Inequality)

### Precise Theorem Statement

For `1 ≤ p ≤ q` and `ρ ≤ √((p−1)/(q−1))`, the product noise operator satisfies:

```
‖T_ρ f‖_q ≤ ‖f‖_p
```

where norms are taken with respect to the uniform measure on `(Fin 3)^L`.

### Lean Target

```lean
theorem hypercontractive_ternary
    (L : ℕ) (p q ρ : ℝ) (hp : 1 ≤ p) (hpq : p ≤ q)
    (hρ : ρ ≤ Real.sqrt ((p - 1) / (q - 1)))
    (f : BerggrenFn L) :
    Lq_norm q f ≤ Lp_norm p f := ...
```

### Why It Matters

Hypercontractivity is the foundation of:
- **Noise sensitivity analysis**: characterizing which observables are stable under perturbation.
- **Small-set expansion**: proving that small subsets of `(Fin 3)^L` expand well under the noise graph.
- **Sharp threshold phenomena**: establishing that balanced Boolean (or ternary) functions undergo phase transitions.

For Berggren word spaces, this would give certified quantitative bounds on the stability of arithmetic observables under word perturbation, connecting symbolic dynamics to probabilistic combinatorics.

### Proof Strategy

1. Prove the two-function version of hypercontractivity on `Fin 3` (one-site) using explicit eigenvalue analysis—our `singleSiteNoise_meanZero` already gives the spectral structure.
2. Tensorize: use the product structure and our homogeneous degree decomposition to lift to `(Fin 3)^L` by induction on `L`.
3. The key lemma is the "two-point inequality" on `Fin 3`, which can be verified by an explicit calculus computation.

### Dependencies

- `singleSiteNoise_meanZero` (proved)
- `productNoise_eigen_on_homogeneousDegree` (proved)
- `Lp` / `Lq` norm definitions on finite spaces (partially in Mathlib via `MeasureTheory.Lp`)

---

## 2. KKL/Influence Theory for Ternary Observables

### Precise Theorem Statement

Define the **influence** of coordinate `i` on a function `f : (Fin 3)^L → ℝ` as:

```
Inf_i(f) = (1/3^L) Σ_x Var_{x_i}[f(x)]
```

where the variance is over the uniform distribution on `Fin 3` with other coordinates fixed.

**KKL-type theorem**: For any balanced function `f` (i.e., `𝔼[f] = 0`, `𝔼[f²] = 1`), there exists a coordinate `i` such that:

```
Inf_i(f) ≥ C · log(L) / L
```

for some universal constant `C > 0`.

### Lean Target

```lean
def influence (L : ℕ) (i : Fin L) (f : BerggrenFn L) : ℝ := ...

theorem kkl_ternary (L : ℕ) (hL : 1 ≤ L)
    (f : BerggrenFn L) (hbalanced : berggrenInner f (fun _ => 1) = 0)
    (hnorm : berggrenInner f f = 1) :
    ∃ i : Fin L, influence L i f ≥ C * Real.log L / L := ...
```

### Why It Matters

The KKL theorem is the starting point for:
- **Junta testing**: determining whether a function depends on few coordinates.
- **Arrow's theorem generalizations**: impossibility results for aggregation on ternary preferences.
- **Complexity lower bounds**: showing that certain predicates cannot be computed by shallow circuits.

Applied to Berggren word observables, this would prove that any non-trivial arithmetic statistic must be "sensitive" to at least one tree-generation step.

### Proof Strategy

1. Define coordinate influences using our `meanZeroAt` predicate and the inner product `berggrenInner`.
2. Relate total influence `Σ_i Inf_i(f)` to the spectral decomposition: `Σ_i Inf_i(f) = Σ_d d · ‖f_d‖²` where `f_d` is the degree-`d` component.
3. Use the hypercontractivity result (Direction 1) to bound the contribution of high-degree components.
4. Optimize over the noise parameter `ρ` to extract the `log(L)/L` bound.

### Dependencies

- `homogeneousDegreeSubmodule` and eigenvalue theorem (proved)
- Hypercontractivity (Direction 1)
- Inner product / L² norm infrastructure

---

## 3. Exact Decomposition Equivalence: Coordinate Dependence = Spectral Degree

### Precise Theorem Statement

The degree-≤k submodule defined via coordinate dependence equals the direct sum of homogeneous degree sectors ≤ k:

```
degreeLeSubmodule L k = ⨆ (d : Fin (k+1)), homogeneousDegreeSubmodule L d
```

### Lean Target

```lean
theorem degreeLeSubmodule_eq_iSup_homogeneous (L k : ℕ) :
    degreeLeSubmodule L k = ⨆ (d : Fin (k+1)), homogeneousDegreeSubmodule L d.val := ...
```

### Why It Matters

This theorem provides:
- **Semantic equivalence** between the "combinatorial" notion of degree (how many coordinates a function depends on) and the "spectral" notion (eigenspace decomposition under noise).
- **Bridge between junta analysis and Fourier analysis**: a function is a k-junta if and only if its spectral support is contained in degrees ≤ k.
- **Validation** that our two independently-motivated definitions are consistent.

### Proof Strategy

1. **Forward inclusion** (`degreeLeSubmodule L k ≤ ⨆ ...`): If `f` depends on at most `k` coordinates (say on set `S` with `|S| ≤ k`), decompose `f` into its homogeneous Fourier components. Each component has degree ≤ `|S|` ≤ `k`. This requires constructing the explicit orthogonal projection onto each homogeneous sector using the mean-zero decomposition at each coordinate.

2. **Backward inclusion** (`⨆ ... ≤ degreeLeSubmodule L k`): If `f` is in `homogeneousDegreeSubmodule L d` with `d ≤ k`, then `f` depends on at most `d ≤ k` coordinates by the `ConstantAt` condition in the definition of generators.

The backward direction is straightforward. The forward direction requires constructing the coordinate-wise Fourier projection, which is `(1/3) Σ_v f(update x i v)` for the constant part and `f(x) - (1/3) Σ_v f(update x i v)` for the mean-zero part.

### Dependencies

- `homogeneousDegreeSubmodule`, `degreeLeSubmodule` (defined)
- `meanZeroAt`, `ConstantAt` (defined)
- Coordinate-wise Fourier projection (to be defined)

---

## 4. Thermodynamic Formalism Bridge: Transfer Operators via Product Noise

### Precise Theorem Statement

Let `Φ : BerggrenWordSpace L → ℝ` be a potential function and define the transfer operator:

```
(L_Φ f)(w) = Σ_{w' : σ^{-1}(w)} exp(Φ(w')) · f(w')
```

where `σ` is the shift map. Then the spectral radius of `L_Φ` on the degree-≤k subspace is bounded by:

```
r_k(L_Φ) ≤ ‖exp ∘ Φ‖_∞ · (1 + ε_k)
```

where `ε_k → 0` as the potential becomes "close to product form," quantified via the degree decomposition.

### Lean Target

```lean
def transferOperator (L : ℕ) (Φ : BerggrenFn L) : BerggrenFn L →ₗ[ℝ] BerggrenFn L := ...

theorem transfer_spectral_bound (L k : ℕ) (Φ : BerggrenFn L)
    (hΦ : ∀ d > k, ‖project_degree d Φ‖ ≤ ε) :
    spectral_radius (transferOperator L Φ) (degreeLeSubmodule L k) ≤ ... := ...
```

### Why It Matters

- Connects our product noise calculus to the **Ruelle–Perron–Frobenius theory** used in statistical mechanics and ergodic theory.
- Provides **certified spectral gap estimates** for symbolic dynamical systems.
- Opens a path to formalizing **decay of correlations** and **central limit theorems** for Berggren-generated arithmetic sequences.
- The product noise operator `productNoise L ρ` is the simplest transfer operator (corresponding to a "product potential"), and our exact spectral theorem gives the baseline against which more complex potentials can be perturbatively analyzed.

### Proof Strategy

1. Express the transfer operator as `productNoise` plus a perturbation term that captures the non-product part of `Φ`.
2. Use our eigenvalue theorem to analyze `productNoise` exactly.
3. Apply operator perturbation theory (Kato–Rellich style bounds) to control the effect of the non-product perturbation on the spectrum.
4. The degree filtration provides a natural truncation scheme for the perturbation series.

### Dependencies

- `productNoise_eigen_on_homogeneousDegree` (proved)
- `degreeLeSubmodule` and `homogeneousDegreeSubmodule` (defined)
- Operator norm estimates (partially in Mathlib)
- Perturbation theory for finite-dimensional operators

---

## 5. Arithmetic Observable Bias: Exponential Decay for Berggren-Generated Statistics

### Precise Theorem Statement

Let `T_B` denote the Berggren walk operator—the operator that, starting from a Pythagorean triple `(a, b, c)`, applies one of the three Berggren matrices uniformly at random. Let `χ : ℤ³ → ℝ` be a "low-complexity" observable (e.g., parity of `a`, residue of `c` mod `m`, a bounded-degree polynomial in the entries).

After `n` steps, the bias of `χ` decays exponentially:

```
|𝔼[χ(T_B^n(a₀, b₀, c₀))] - 𝔼_uniform[χ]| ≤ C · ρ^n
```

where `ρ < 1` depends on the degree of `χ` in the Berggren word encoding.

### Lean Target

```lean
theorem berggren_observable_mixing
    (n k : ℕ) (ρ : ℝ) (hρ : 0 < ρ ∧ ρ < 1)
    (χ : BerggrenFn L)
    (hχ : χ ∈ degreeLeSubmodule L k) :
    |noiseBias ρ χ| ≤ C * ρ^(k * n) := ...
```

### Why It Matters

- Gives **quantitative equidistribution** for statistics of Berggren-generated Pythagorean triples.
- Proves that after sufficiently many generation steps, the triple "looks random" to any low-complexity test.
- Connects number theory (Pythagorean triples) to pseudorandomness theory.
- The exponential rate `ρ^k` is explicitly computable from the spectral decomposition, making this a **constructive** equidistribution result.

### Proof Strategy

1. Encode the Berggren walk as an operator on `BerggrenFn L` using the product noise framework.
2. Decompose `χ` into its homogeneous degree components using the spectral theorem.
3. Apply `berggren_bias_bound_of_spectral_decay` to each component.
4. Sum the bounds, using the fact that high-degree components are exponentially damped.

### Dependencies

- `berggren_bias_bound_of_spectral_decay` (proved)
- `productNoise_eigen_on_homogeneousDegree` (proved)
- Berggren matrix definitions (in existing codebase)
- Connection between Berggren matrices and the product noise encoding

---

## Implementation Priority

| Priority | Direction | Estimated Effort | Prerequisites |
|----------|-----------|-----------------|---------------|
| 1 | Decomposition Equivalence (§3) | Medium | Current work only |
| 2 | KKL/Influence (§2) | Medium-High | §3, inner product infra |
| 3 | Hypercontractivity (§1) | High | One-site calculus |
| 4 | Arithmetic Bias (§5) | Medium | Berggren matrix defs |
| 5 | Thermodynamic Bridge (§4) | High | Operator perturbation theory |

**Recommended next step**: Direction 3 (Decomposition Equivalence), as it requires only existing infrastructure and validates the conceptual coherence of the two degree notions.
