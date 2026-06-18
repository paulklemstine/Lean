## Research Task: EML Stone–Weierstrass for compact retract codomains in Euclidean space

Research Mode: PROVE

Develop a reusable “ambient approximation + retraction” theorem for EML classes. The goal is to show that scalar/vector-valued EML density in Euclidean space upgrades automatically to density for maps into any compact subset `K ⊆ ℝⁿ` that is a retract of an open neighborhood. This is the right abstraction behind the already-completed convex/product/smooth-manifold/ANR special cases: approximate in the ambient linear space, then project back by a continuous retraction.

The central theorem should be stated in a way that isolates the topological mechanism from the EML approximation mechanism. In particular, prove a general lemma of the following shape, then specialize it to the EML class.

### Core theorem: ambient approximation followed by retraction

Work with `Fin n → ℝ` as the ambient Euclidean space; this is usually easier in Mathlib than `EuclideanSpace ℝ (Fin n)` for sup-norm estimates and coordinatewise approximation.

A good target signature is:

```lean
theorem dense_of_compact_retract_into_finEucl
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ}
    {K U : Set (Fin n → ℝ)}
    (hK_compact : IsCompact K)
    (hU_open : IsOpen U)
    (hKU : K ⊆ U)
    (r : U → K)
    (hr_cont : Continuous r)
    (hr_fix : ∀ x : K, r ⟨x.1, hKU x.2⟩ = x)
    (F : Set (C(X, Fin n → ℝ)))
    (hF_dense :
      ∀ f : C(X, Fin n → ℝ), ∀ ε > 0,
        ∃ g ∈ F, ∀ x, ‖g x - f x‖ < ε) :
    ∀ (fK : C(X, K)) (ε : ℝ), ε > 0 →
      ∃ g ∈ F,
        ∀ x, ‖(r ⟨g x, by
          -- membership in U obtained from the approximation bound
          sorry⟩ : K) - fK x‖ < ε
```

This statement may need mild refactoring depending on your existing normed-topology API and the exact representation of continuous maps into subtypes. If it is cleaner, first prove a version where the conclusion is existence of a continuous map `φ : C(X, K)` of the form
`φ x = r ⟨g x, hgU x⟩`,
then derive the pointwise estimate.

A more implementation-friendly decomposition is:

```lean
theorem exists_eml_near_compact_retract
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ}
    {K U : Set (Fin n → ℝ)}
    (hK_compact : IsCompact K)
    (hU_open : IsOpen U)
    (hKU : K ⊆ U)
    (r : U → K)
    (hr_cont : Continuous r)
    (hr_fix : ∀ x : K, r ⟨x.1, hKU x.2⟩ = x)
    (h_dense :
      ∀ f : C(X, Fin n → ℝ), ∀ ε > 0,
        ∃ g : C(X, Fin n → ℝ), IsEMLMap g ∧ ∀ x, ‖g x - f x‖ < ε) :
    ∀ (f : C(X, K)) (ε : ℝ), ε > 0,
      ∃ g : C(X, Fin n → ℝ),
        IsEMLMap g ∧
        (∀ x, g x ∈ U) ∧
        ∀ x, ‖(r ⟨g x, by simpa using ‹g x ∈ U›⟩ : K) - f x‖ < ε
```

where `IsEMLMap g` means each coordinate belongs to the scalar EML class; if your library already has a vector-valued EML predicate, use that exact notion instead.

### Final EML specialization

After the abstract retract lemma, prove the actual EML density statement:

```lean
theorem eml_dense_compact_retract_codomain
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    [T2Space X]
    {n : ℕ}
    {K U : Set (Fin n → ℝ)}
    (hK_compact : IsCompact K)
    (hU_open : IsOpen U)
    (hKU : K ⊆ U)
    (r : U → K)
    (hr_cont : Continuous r)
    (hr_fix : ∀ x : K, r ⟨x.1, hKU x.2⟩ = x) :
    ∀ (f : C(X, K)) (ε : ℝ), ε > 0,
      ∃ g : C(X, Fin n → ℝ),
        IsEMLMap g ∧
        (∀ x, g x ∈ U) ∧
        ∀ x, ‖(r ⟨g x, by simpa using ‹g x ∈ U›⟩ : K) - f x‖ < ε
```

If your existing EML Stone–Weierstrass theorem is scalar-valued, first prove a coordinate assembly lemma such as:

```lean
theorem exists_eml_finvec_uniform_approx
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    [T2Space X] {n : ℕ}
    (f : C(X, Fin n → ℝ)) :
    ∀ ε > 0, ∃ g : C(X, Fin n → ℝ),
      IsEMLMap g ∧ ∀ x, ‖g x - f x‖ < ε
```

using coordinatewise approximation and a finite-dimensional norm estimate.

## Proof strategy

1. **Extract a uniform neighborhood scale around `K` inside `U`.**  
   Since `K` is compact and `U` is open with `K ⊆ U`, prove there exists `η > 0` such that
   ```lean
   ∀ y, dist y K < η → y ∈ U
   ```
   or an equivalent ball-thickening statement
   ```lean
   ∃ η > 0, Metric.thickening η K ⊆ U
   ```
   This is the compact-set version of the Lebesgue-number argument for the open cover `{U, Uᶜ}`. In Lean, this may be easiest via compactness of `K` and openness of `U`, obtaining for each `x ∈ K` a radius `η_x`, then extracting a finite subcover and taking the minimum. This step is essential because it turns a uniform approximation estimate into the pointwise membership `g(x) ∈ U`.

2. **Control the retraction near `K` by continuity on a compact neighborhood.**  
   Define the inclusion map
   ```lean
   f0 : C(X, Fin n → ℝ) := fun x => (f x : Fin n → ℝ)
   ```
   where `f : C(X, K)`. Since `r` fixes `K`, one has
   ```lean
   r ∘ Subtype = id on K.
   ```
   For each `z ∈ K`, continuity of `r` at `⟨z, hKU z.property⟩` gives a radius on which
   `‖(r y : Fin n → ℝ) - z‖ < ε`.
   By compactness of `K`, upgrade this to a uniform statement:
   ```lean
   ∃ δ > 0, ∀ y ∈ U, dist y K < δ →
     ‖(r ⟨y, ‹y ∈ U›⟩ : K) - someNearestPoint?‖ < ε
   ```
   A cleaner route avoids nearest points entirely: consider the compact set `f0 '' univ ⊆ K`, and use continuity of the map
   ```lean
   (y,z) ↦ ‖(r y : Fin n → ℝ) - z‖
   ```
   on the closed relation “`z ∈ K` and `y` close to `z`”. Then derive:
   ```lean
   ∃ δ > 0, ∀ x y, y ∈ U → ‖y - f0 x‖ < δ →
     ‖(r ⟨y, ‹y ∈ U›⟩ : K) - f x‖ < ε
   ```
   This formulation is the most usable in the final approximation step. The key insight is that because `r(f0 x) = f x`, continuity of `r` at points of the compact image `f0(X)` yields a uniform modulus on that compact set.

3. **Approximate the ambient Euclidean-valued map coordinatewise.**  
   Apply the existing scalar EML Stone–Weierstrass theorem to each coordinate
   ```lean
   fun x => f0 x i
   ```
   with tolerance `ε' / n` or, better, with a norm-compatible tolerance chosen so that coordinatewise bounds imply
   ```lean
   ‖g x - f0 x‖ < min δ η.
   ```
   In finite dimension, if you use the sup norm on `Fin n → ℝ`, this implication is immediate:
   coordinatewise `< α` gives vector norm `< α`. If your norm is Euclidean, use the standard estimate
   ```lean
   ‖v‖ ≤ √n * max_i ‖v i‖
   ```
   so choose coordinate tolerance `α / (√n)`. It is worth setting up a separate lemma for this finite-dimensional assembly, since it will be reusable in later vector-valued EML approximation theorems.

4. **Show the approximant lands in `U`, then retract.**  
   From
   ```lean
   ∀ x, ‖g x - f0 x‖ < min δ η
   ```
   and `f0 x ∈ K`, conclude `dist (g x) K < η`, hence `g x ∈ U`. Therefore the composite
   ```lean
   x ↦ r ⟨g x, hgU x⟩
   ```
   is a well-defined continuous map `X → K`. Then use the uniform continuity estimate from step 2 with the same `δ` to conclude
   ```lean
   ∀ x, ‖(r ⟨g x, hgU x⟩ : K) - f x‖ < ε.
   ```

5. **Package the result as a density theorem for `K`-valued EML maps.**  
   Define the class of `K`-valued EML maps as retracts of ambient EML maps:
   ```lean
   def IsEMLMapInto
       {X : Type*} [TopologicalSpace X]
       {n : ℕ} (K : Set (Fin n → ℝ)) (φ : C(X, K)) : Prop := ...
   ```
   or simply prove the existential approximation statement above. If there is already a notion of closure/density for subclasses of `C(X, Y)`, derive:
   ```lean
   Dense {φ : C(X, K) | IsEMLMapInto K φ}
   ```
   in `C(X, K)` with the sup metric/uniform topology. Even if the topological density statement is slightly cumbersome, the `∀ ε > 0, ∃ φ, ...` version is already mathematically strong and directly usable.

## Key intermediate lemmas worth proving cleanly

These will make the main theorem much easier to maintain.

```lean
lemma compact_subset_open_thickening
    {n : ℕ} {K U : Set (Fin n → ℝ)}
    (hK : IsCompact K) (hU : IsOpen U) (hKU : K ⊆ U) :
    ∃ η > 0, ∀ y, dist y K < η → y ∈ U
```

```lean
lemma continuous_retract_uniform_near_id_on_compact
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ}
    {K U : Set (Fin n → ℝ)}
    (hK_compact : IsCompact K)
    (hU_open : IsOpen U)
    (hKU : K ⊆ U)
    (r : U → K)
    (hr_cont : Continuous r)
    (hr_fix : ∀ x : K, r ⟨x.1, hKU x.2⟩ = x)
    (f : C(X, K)) :
    ∀ ε > 0, ∃ δ > 0,
      ∀ x : X, ∀ y : Fin n → ℝ, y ∈ U → ‖y - (f x : Fin n → ℝ)‖ < δ →
        ‖((r ⟨y, ‹y ∈ U›⟩ : K) : Fin n → ℝ) - (f x : Fin n → ℝ)‖ < ε
```

```lean
lemma eml_coordinatewise_to_finvec
    {X : Type*} [TopologicalSpace X]
    {n : ℕ}
    (g : Fin n → C(X, ℝ)) :
    ∃ G : C(X, Fin n → ℝ), ∀ i x, G x i = g i x
```

```lean
lemma eml_finvec_uniform_of_coordinate_uniform
    {X : Type*} [TopologicalSpace X]
    [CompactSpace X] {n : ℕ}
    {f g : C(X, Fin n → ℝ)} :
    (∀ i x, |g x i - f x i| < ε) →
    ∀ x, ‖g x - f x‖ < C n * ε
```

Choose the norm lemma to match your ambient norm; if possible, use the sup norm on `Fin n → ℝ` to avoid the constant `C n`.

## Why this matters

This theorem is the natural next universal-approximation milestone for the EML program. It strictly subsumes several codomain-specific approximation results by replacing ad hoc geometric arguments with one conceptual mechanism: embed the codomain into a finite-dimensional linear space, approximate there using scalar Stone–Weierstrass, and retract back. Compact Euclidean neighborhood retracts include compact smooth submanifolds, compact polyhedral sets, compact semialgebraic retracts, and many ANR-type examples that arise in applications. Formalizing this theorem gives a durable interface: any future codomain equipped with an explicit neighborhood retraction inherits EML approximation immediately. That makes later extensions to manifolds-with-boundary, stratified spaces, and concrete constrained output layers essentially one-line corollaries once the retraction is available.

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
