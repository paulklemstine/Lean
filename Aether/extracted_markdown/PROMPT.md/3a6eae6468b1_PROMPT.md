## Research Task: Quantitative Stone–Weierstrass for EML activation algebras

Research Mode: PROVE

Work in a new file
`EML/QuantitativeApproximation.lean`.

The goal is to upgrade the existing qualitative EML density/Stone–Weierstrass results to a formally usable quantitative approximation theorem with an explicit synthesis pattern and explicit sup-norm error bounds. The key point is to avoid a mere existential density statement and instead construct approximants from finite oscillation covers and algebraic peak functions.

### Precise theorem targets

Use concrete Lean statements over compact metric spaces and continuous maps. A good setup is to work with a predicate
`IsEML : C(X, ℝ) → Prop`
or a bundled subalgebra if that is how the existing development encodes the EML algebra. State closure hypotheses explicitly if needed.

A first core theorem should have essentially the following shape:

```lean
open scoped Topology BigOperators
open Metric

variable {X : Type*} [MetricSpace X] [CompactSpace X]

def osc_on (f : C(X, ℝ)) (s : Set X) : ℝ :=
  sSup ((fun p : X × X => |f p.1 - f p.2|) '' {p : X × X | p.1 ∈ s ∧ p.2 ∈ s})

theorem exists_eml_supnorm_approx_from_finite_cover
    (A : Set C(X, ℝ))
    (hA_subalg : Subalgebra ℝ C(X, ℝ)) -- replace by actual bundled EML algebra
    (hA_sep : ∀ x y : X, x ≠ y → ∃ g ∈ A, g x ≠ g y)
    (hA_consts : ∀ c : ℝ, (fun _ : X => c) ∈ A)
    (hA_add : ∀ f g, f ∈ A → g ∈ A → f + g ∈ A)
    (hA_mul : ∀ f g, f ∈ A → g ∈ A → f * g ∈ A)
    (hA_max : ∀ f g, f ∈ A → g ∈ A → max f g ∈ A) -- or derive from existing EML closure
    (hA_min : ∀ f g, f ∈ A → g ∈ A → min f g ∈ A)
    (f : C(X, ℝ)) (ε : ℝ) (hε : 0 < ε)
    (ι : Type*) [Fintype ι]
    (U : ι → Set X)
    (hU_open : ∀ i, IsOpen (U i))
    (hcover : Set.univ ⊆ ⋃ i, U i)
    (hosc : ∀ i, ∀ x y, x ∈ U i → y ∈ U i → |f x - f y| ≤ ε) :
    ∃ g ∈ A, ‖f - g‖ ≤ 2 * ε := by
  sorry
```

If the existing code already uses `‖f - g‖ = sSup {r | ...}` for the sup norm on `C(X,ℝ)`, adapt the conclusion to the actual norm on continuous maps:
```lean
∃ g ∈ A, ‖f - g‖ ≤ 2 * ε
```
or equivalently
```lean
∃ g ∈ A, ∀ x, |f x - g x| ≤ 2 * ε
```
if the normed-space API is inconvenient. The pointwise version is often much easier to formalize first, with the norm estimate derived afterwards by `norm_le`.

A more constructive variant, often easier to prove, is:

```lean
theorem exists_eml_weighted_cover_approx
    (f : C(X, ℝ)) (ε : ℝ) (hε : 0 < ε)
    (ι : Type*) [Fintype ι]
    (x : ι → X) (φ : ι → C(X, ℝ))
    (hφ_nonneg : ∀ i z, 0 ≤ φ i z)
    (hφ_sum_one : ∀ z, (∑ i, φ i z) = 1)
    (hφ_local : ∀ i z, φ i z ≠ 0 → z ∈ U i)
    (hosc : ∀ i, ∀ y, y ∈ U i → |f y - f (x i)| ≤ ε) :
    ∀ z, |f z - ∑ i, (f (x i)) * φ i z| ≤ ε := by
  sorry
```

This isolates the analytic heart: once a partition of unity subordinate to the oscillation cover exists inside the EML algebra, the approximation estimate is immediate.

Then prove an EML-internal approximate partition-of-unity theorem. A realistic formulation is:

```lean
theorem exists_eml_approx_partition_of_unity
    (A : Set C(X, ℝ))
    (fsep : ...)
    (ι : Type*) [Fintype ι]
    (K : ι → Set X) (U : ι → Set X)
    (hK_compact : ∀ i, IsCompact (K i))
    (hU_open : ∀ i, IsOpen (U i))
    (hKU : ∀ i, K i ⊆ U i)
    (hcover : Set.univ ⊆ ⋃ i, K i)
    (δ : ℝ) (hδ : 0 < δ) :
    ∃ φ : ι → C(X, ℝ),
      (∀ i, φ i ∈ A) ∧
      (∀ i x, 0 ≤ φ i x) ∧
      (∀ x, (∑ i, φ i x) ≠ 0) ∧
      (∀ i x, x ∉ U i → φ i x ≤ δ) := by
  sorry
```

From such `φ i`, normalize by
```lean
ψ i x = φ i x / ∑ j, φ j x
```
and prove:
- `0 ≤ ψ i x`
- `∑ i, ψ i x = 1`
- if `x ∉ U i`, then `ψ i x` is small.

If exact division closure is unavailable inside the algebra, that is fine: use the normalized `ψ` only analytically to define the approximant and then separately show that the resulting expression belongs to the EML class if the class already contains the needed reciprocal/log-sum-exp style normalization, or else state a weaker theorem first with an unnormalized weighted average and denominator bounds. A fallback theorem with constant `C = 3` or `4` is acceptable if exact algebra closure under division is not formalized.

A second theorem should specialize to cubes and convert oscillation control into a width/cardinality bound. For example:

```lean
theorem exists_eml_cube_approx_with_covering_bound
    {d : ℕ} (f : C((Fin d → ℝ), ℝ))
    (K : Set (Fin d → ℝ))
    (hK_compact : IsCompact K)
    (ε : ℝ) (hε : 0 < ε)
    (ω : ℝ → ℝ)
    (hmod : ∀ x ∈ K, ∀ y ∈ K, |f x - f y| ≤ ω (dist x y))
    (hωmono : Monotone ω)
    (hωε : ∃ r > 0, ω r ≤ ε) :
    ∃ N : ℕ, ∃ g,
      IsEML g ∧
      (∀ x ∈ K, |f x - g x| ≤ 2 * ε) ∧
      N ≤ Nat.ceil ((diam K / Classical.choose hωε) ^ d) := by
  sorry
```

If `diam K` on arbitrary subsets is cumbersome, specialize further to `K = Set.Icc a b` in dimension `1`, or to a compact cube `[a,b]^d` encoded as a closed ball / product box already available in Mathlib. The essential quantitative content is that a mesh of size `r` gives oscillation at most `ω(r)`, hence a finite cover cardinality bound by a covering number.

### Proof strategy

1. **Derive EML peak functions from separation.**  
   The crucial local lemma is: for a point `x : X` and compact `K : Set X` with `x ∉ K`, construct `p ∈ A` such that `0 ≤ p ≤ 1`, `p x` is close to `1`, and `p` is uniformly small on `K`.  
   Formal route:
   - For each `y ∈ K`, use separation to get `g_y ∈ A` with `g_y x ≠ g_y y`.
   - Affine-rescale `g_y` so that `g_y x = 1` and `g_y y = 0`.
   - By continuity, there is an open neighborhood `V_y` of `y` on which `g_y ≤ δ`.
   - Compactness of `K` gives finitely many `y₁,...,y_n`.
   - Set `p := ⨅ j, g_{y_j}` or `p := 1 - ⨆ j, (1 - g_{y_j})`; use min/max closure of the EML algebra.
   This is the main nontrivial bridge from qualitative separation to quantitative localization.

2. **Build finite bump families adapted to a finite oscillation cover.**  
   For each cover set `U i`, choose a sample point `x i ∈ U i` and a compact shrink `K i ⊆ U i` still covering `X`. The compact shrink may be obtained from a Lebesgue-number argument or by taking closed balls inside the cover if you first derive a finite ball cover.  
   Then apply the peak-function lemma to `K i` versus the closed complement of `U i` to get `φ i ∈ A` with:
   - `0 ≤ φ i ≤ 1`
   - `φ i ≈ 1` on `K i`
   - `φ i ≤ δ` on `X \ U i`.
   The intended estimate is that for every `x`, at least one `φ i x` is bounded below away from `0`, because the `K i` cover `X`.

3. **Normalize to an approximate partition of unity and control leakage.**  
   Let `S x := ∑ i, φ i x`. Prove `S x ≥ c > 0` pointwise from the covering property of the `K i`. Then define
   ```lean
   ψ i x := φ i x / S x
   ```
   and show:
   - `ψ i x ≥ 0`
   - `∑ i, ψ i x = 1`
   - if `x ∉ U i`, then `ψ i x ≤ δ / c`.
   This converts qualitative support information into a quantitative weighted-average estimate. If exact support is hard, “small outside” is enough.

4. **Approximate by sampled values and prove the `2ε` bound.**  
   Define
   ```lean
   g x := ∑ i, f (x i) * ψ i x
   ```
   Then for each `x`,
   ```lean
   f x - g x = ∑ i, ψ i x * (f x - f (x i)).
   ```
   Split the sum into indices with `x ∈ U i` and `x ∉ U i`.
   - On the first part, oscillation gives `|f x - f (x i)| ≤ ε`.
   - On the second part, use the leakage bound on `ψ i x` and a crude uniform bound on `|f x - f (x i)|` from compactness of `f`.
   Choosing `δ` sufficiently small yields total error `≤ 2ε`.  
   If exact support is available, the estimate improves immediately to `≤ ε`.

5. **Specialize to cubes via a mesh cover.**  
   On `[a,b]^d` or another concrete compact cube, pick mesh size `r` with `ω_f(r) ≤ ε`. Cover the cube by at most `N_ε` sets of diameter `≤ r`; then the previous theorem gives an approximant with error `≤ 2ε`.  
   Formalize `N_ε` as either:
   - an explicit cardinality of a finite grid cover, or
   - a bound by a covering number already defined in the file.
   Even a coarse bound of the form `(Nat.ceil ((b-a)/r) + 1)^d` is mathematically meaningful and sufficient.

### Suggested intermediate lemmas

These are likely the right decomposition for Lean:

```lean
theorem exists_eml_peak_point_compact
    (x : X) (K : Set X) (hKc : IsCompact K) (hxK : x ∉ K)
    (δ : ℝ) (hδ : 0 < δ) :
    ∃ p : C(X, ℝ),
      IsEML p ∧
      (∀ z, 0 ≤ p z) ∧
      (∀ z, p z ≤ 1) ∧
      p x = 1 ∧
      (∀ z ∈ K, p z ≤ δ) := by
  sorry
```

```lean
theorem finite_compact_shrink_of_open_cover
    (ι : Type*) [Fintype ι] (U : ι → Set X)
    (hU_open : ∀ i, IsOpen (U i))
    (hcover : Set.univ ⊆ ⋃ i, U i) :
    ∃ K : ι → Set X,
      (∀ i, IsCompact (K i)) ∧
      (∀ i, K i ⊆ U i) ∧
      Set.univ ⊆ ⋃ i, K i := by
  sorry
```

```lean
theorem weighted_average_approx_of_local_oscillation
    (f : C(X, ℝ)) (ι : Type*) [Fintype ι]
    (U : ι → Set X) (x₀ : ι → X) (ψ : ι → C(X, ℝ))
    (hψ_nonneg : ∀ i z, 0 ≤ ψ i z)
    (hψ_sum : ∀ z, (∑ i, ψ i z) = 1)
    (hψ_small_outside : ∀ i z, z ∉ U i → ψ i z ≤ η)
    (hosc : ∀ i z, z ∈ U i → |f z - f (x₀ i)| ≤ ε)
    (hbd : ∀ z, |f z| ≤ M)
    (hη : (Fintype.card ι : ℝ) * η * (2 * M) ≤ ε) :
    ∀ z, |f z - ∑ i, (f (x₀ i)) * ψ i z| ≤ 2 * ε := by
  sorry
```

For the compact uniform bound `hbd`, use:
```lean
obtain ⟨M, hM⟩ := isCompact.exists_bound_of_continuousOn ...
```
or the corresponding theorem for continuous real-valued functions on compact spaces.

### Lean-specific implementation hints

- It may be substantially easier to prove pointwise estimates first:
  ```lean
  ∀ x, |f x - g x| ≤ 2 * ε
  ```
  and only then package them into a norm bound using the sup norm on `C(X,ℝ)`.

- For finite combinations of continuous maps, rely on:
  - `ContinuousMap.add_apply`
  - `ContinuousMap.mul_apply`
  - `Finset.sum_apply`
  - coercions from constants via `ContinuousMap.const`.

- For max/min closure, if the EML algebra already contains log-sum-exp approximations to max, you can either:
  1. prove exact closure under `max`/`min` if already available, or
  2. formulate an approximate-peak theorem using softmax/log-sum-exp and absorb the extra approximation error into the final `2ε` or `3ε` bound.
  This is actually mathematically interesting: it connects the prior log-sum-exp results to constructive Stone–Weierstrass.

- If normalization by division is not internally available in the algebra, separate the theorem into:
  1. existence of analytic partition functions `ψ`,
  2. EML realizability of the resulting weighted sum under whatever reciprocal/exponential closure the EML library already has.
  A theorem with a hypothesis such as
  ```lean
  (hA_div_pos : ...)
  ```
  is acceptable if that matches the current API.

- On compact metric spaces, a very clean route is to avoid arbitrary open covers and instead use a finite cover by open balls of radius `< r`, where `r` comes from a modulus of continuity or a Lebesgue number. This often simplifies both the oscillation hypothesis and the compact-shrink construction.

### Why this matters

This theorem is the missing quantitative layer in the EML approximation program. The existing qualitative density result shows expressivity in principle; the present target turns it into a usable approximation theorem with explicit error budgets and finite model complexity. That matters for three reasons:

1. **It converts abstract density into constructive synthesis.**  
   Instead of “some EML term approximates `f`,” we get a finite weighted cover construction that can be reused in later formal developments.

2. **It links algebraic closure to approximation complexity.**  
   The partition-of-unity proof makes precise how point separation and lattice/algebra operations generate local bumps, and how cover cardinality controls width. This is the correct formal bridge from Stone–Weierstrass to universal approximation with rates.

3. **It interfaces naturally with the ML side of the project.**  
   The cube specialization gives explicit finite-width bounds in terms of a modulus of continuity and a covering number, which is exactly the kind of theorem needed to connect the EML algebraic theory to network-size complexity and robustness questions.

A very good outcome would be:
- one general compact-metric-space theorem with error `≤ 2ε` from a finite oscillation cover;
- one cube/cell-cover corollary translating modulus of continuity into an explicit width/cardinality bound.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: EML
Research mode: prove
