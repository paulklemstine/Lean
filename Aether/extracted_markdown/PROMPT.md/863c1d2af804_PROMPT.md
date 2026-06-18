## Research Task: EML Stone–Weierstrass for compact metrizable ANR codomains via Euclidean embedding and neighborhood retraction

Research Mode: PROVE

Prove a codomain-lifting universal approximation theorem that reduces approximation into a compact metrizable ANR target to the already-established finite-dimensional Euclidean-valued EML approximation theorem.

### Main theorem to target

Work in the following concrete Euclidean-retract setting rather than abstract ANR language alone.

Let `K` be a compact Hausdorff space, let `n : ℕ`, let `Y : Type*` be a compact topological space, let `e : Y ↪ ℝ^n` be a topological embedding, let `U : Set (ℝ^n)` be open, assume `Set.range e ⊆ U`, and let
```lean
r : C(U, Set.range e)
```
be a continuous retraction of the inclusion in the sense that
```lean
∀ y : Set.range e, r ⟨y.1, ?hy⟩ = y
```
whenever `?hy : y.1 ∈ U` is supplied using `Set.range e ⊆ U`.

For a continuous map `f : C(K, Y)`, define its Euclidean realization
```lean
def ef : C(K, ℝ^n) := ⟨fun x => e (f x), continuous_subtype_val.comp (e.continuous.comp f.continuous)⟩
```
up to the obvious implementation details.

The core approximation statement should have essentially the following shape:
```lean
theorem eml_dense_into_ANR_via_retract
  {K : Type*} [TopologicalSpace K] [CompactSpace K]
  {Y : Type*} [TopologicalSpace Y] [CompactSpace Y]
  (n : ℕ)
  (e : Y ↪ ℝ^n)
  (he : Embedding e)
  (U : Set (ℝ^n)) (hU_open : IsOpen U)
  (h_rangeU : Set.range e ⊆ U)
  (r : C(U, Set.range e))
  (hr : ∀ y : Set.range e, r ⟨y.1, h_rangeU y.property⟩ = y)
  (f : C(K, Y)) :
  ∀ ε > 0, ∃ g : C(K, ℝ^n),
    IsEMLVectorApprox g ∧
    (∀ x : K, g x ∈ U) ∧
    (∀ x : K, ‖g x - e (f x)‖ < ε) →
    ∀ ε' > 0, ∃ g : C(K, ℝ^n),
      IsEMLVectorApprox g ∧
      (∀ x : K, g x ∈ U) ∧
      (∀ x : K, ‖((r ⟨g x, ‹g x ∈ U›⟩ : Set.range e).1) - e (f x)‖ < ε')
```
This statement is too cumbersome as written, so you should refactor it into two clean theorems:

1. **Neighborhood-stable Euclidean approximation lemma**
```lean
theorem exists_eml_vector_approx_in_open_tube
  {K : Type*} [TopologicalSpace K] [CompactSpace K]
  (F : C(K, ℝ^n)) {U : Set (ℝ^n)} (hU_open : IsOpen U)
  (hFU : Set.range F ⊆ U) :
  ∃ η > 0, ∀ g : C(K, ℝ^n),
    (supNormDist g F < η) → (Set.range g ⊆ U)
```
where `supNormDist` is the uniform/sup norm distance on `C(K, ℝ^n)`.

2. **Retraction-postcomposition approximation theorem**
```lean
theorem eml_dense_retract_target
  {K : Type*} [TopologicalSpace K] [CompactSpace K]
  {Y : Type*} [TopologicalSpace Y] [CompactSpace Y]
  (n : ℕ)
  (e : Y ↪ ℝ^n) (he : Embedding e)
  (U : Set (ℝ^n)) (hU_open : IsOpen U)
  (h_rangeU : Set.range e ⊆ U)
  (r : C(U, Set.range e))
  (hr : ∀ y : Set.range e, r ⟨y.1, h_rangeU y.property⟩ = y)
  (f : C(K, Y)) :
  ∀ ε > 0, ∃ g : C(K, ℝ^n),
    IsEMLVectorApprox g ∧
    (Set.range g ⊆ U) ∧
    supNormDist
      (fun x => ((r ⟨g x, by exact ‹Set.range g ⊆ U› ⟨x, rfl⟩⟩ : Set.range e).1))
      (fun x => e (f x))
      < ε
```

If the exact `C(U, Set.range e)` notation is awkward, it is also acceptable to formulate `r` as a map
```lean
r : U → Set.range e
```
with a continuity hypothesis, and to package the postcomposition map as a continuous map `K → ℝ^n` by taking subtype values.

### Preferred strengthened theorem

A better final statement is a density theorem in the uniform topology on `C(K, Y)` after identifying `Y` with `Set.range e`:

```lean
theorem eml_dense_compact_ANR_codomain
  {K : Type*} [TopologicalSpace K] [CompactSpace K]
  {Y : Type*} [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
  (n : ℕ)
  (e : Y ↪ ℝ^n) (he : Embedding e)
  (U : Set (ℝ^n)) (hU_open : IsOpen U)
  (h_rangeU : Set.range e ⊆ U)
  (r : C(U, Set.range e))
  (hr : ∀ y : Set.range e, r ⟨y.1, h_rangeU y.property⟩ = y)
  (f : C(K, Y)) :
  ∀ ε > 0, ∃ g : C(K, ℝ^n),
    IsEMLVectorApprox g ∧
    (Set.range g ⊆ U) ∧
    supNormDist
      (fun x => e ((Homeomorph.ofEmbedding e he ?closed_range).symm
        ((r ⟨g x, by exact ‹Set.range g ⊆ U› ⟨x, rfl⟩⟩ : Set.range e))))
      f < ε
```

But if transporting the metric back from `Set.range e` to `Y` is technically heavy, it is completely acceptable to prove the theorem in embedded form, i.e. density of retract-corrected EML maps in the subset `e ∘ C(K,Y) ⊆ C(K,ℝ^n)`.

### Key intermediate lemmas you should prove

1. **Compact image has positive distance from closed complement of an open neighborhood**
```lean
theorem exists_pos_tube_of_compact_range_subset_open
  {K : Type*} [TopologicalSpace K] [CompactSpace K]
  (F : C(K, ℝ^n)) {U : Set (ℝ^n)}
  (hU_open : IsOpen U) (hFU : Set.range F ⊆ U) :
  ∃ η > 0, ∀ x : K, Metric.closedBall (F x) η ⊆ U
```
A weaker pointwise-ball version is enough, but the uniform `η` is what drives the proof.

2. **Uniform continuity modulus on a compact tube**
Choose a compact set such as the closed `η`-neighborhood of `Set.range (e ∘ f)` inside `U`, then prove:
```lean
theorem retract_uniform_continuous_on_compact_tube
  (hTubeCompact : IsCompact T)
  (hTU : T ⊆ U) :
  ∀ ε > 0, ∃ δ > 0, ∀ z w : U,
    z.1 ∈ T → w.1 ∈ T → ‖z.1 - w.1‖ < δ →
    ‖(r z).1 - (r w).1‖ < ε
```
This is just uniform continuity of `r` restricted to a compact subset of `U`.

3. **Retraction fixes the embedded image**
For `F := fun x => (⟨e (f x), h_rangeU ⟨f x, rfl⟩⟩ : U)`, show
```lean
∀ x : K, (r F x).1 = e (f x)
```
or the equivalent pointwise statement needed in the sup norm estimate.

4. **Postcomposition error estimate**
If `g` is uniformly `δ`-close to `e ∘ f` and both lie in the compact tube on which `r` is uniformly continuous, then
```lean
supNormDist (fun x => (r ⟨g x, hgU x⟩).1) (fun x => e (f x)) < ε
```
This is the exact place where the retract identity and modulus of continuity combine.

### Concrete proof strategy

1. **Build a uniform open tube around the compact image.**  
   Let `F := fun x => e (f x)`. Since `Set.range F` is compact and contained in the open set `U`, extract `η > 0` such that every closed ball `closedBall (F x) η` lies in `U`. In metric terms, use compactness of `Set.range F` and the closed set `Uᶜ` to get strictly positive distance from `Set.range F` to `Uᶜ`. This is the key “stays in the neighborhood” lemma.

2. **Apply the existing finite-dimensional EML approximation theorem with tolerance `min η δ`.**  
   Use the already-developed Euclidean/vector-valued EML Stone–Weierstrass theorem to obtain `g : C(K, ℝ^n)` with `IsEMLVectorApprox g` and
   ```lean
   supNormDist g F < min η δ.
   ```
   Then deduce `Set.range g ⊆ U` from the tube lemma. This is the reduction from ANR codomain to Euclidean codomain.

3. **Restrict the retraction to a compact tube and invoke uniform continuity.**  
   Let
   ```lean
   T := {z : ℝ^n | ∃ y ∈ Set.range F, ‖z - y‖ ≤ η}
   ```
   or simply use the closed `η`-thickening of `Set.range F`. Prove `IsCompact T` and `T ⊆ U`. Since `r` is continuous on `U`, its restriction to `T` is uniformly continuous. Extract `δ` for the requested output error `ε`.

4. **Use the retract identity on the exact image.**  
   For each `x`, because `e (f x) ∈ Set.range e`, one has
   ```lean
   r ⟨e (f x), h_rangeU ⟨f x, rfl⟩⟩ = ⟨e (f x), ⟨f x, rfl⟩⟩.
   ```
   Thus the comparison
   ```lean
   (r ⟨g x, hgU x⟩).1  vs  e (f x)
   ```
   can be rewritten as
   ```lean
   (r ⟨g x, hgU x⟩).1  vs  (r ⟨e (f x), ...⟩).1.
   ```
   Then the desired estimate follows from the modulus of continuity of `r` on `T`.

5. **Package the result as density of retract-corrected EML maps.**  
   Define the approximant
   ```lean
   x ↦ (r ⟨g x, hgU x⟩).1
   ```
   as a continuous map `K → ℝ^n` landing in `Set.range e`. If feasible, transport this through the embedding to obtain an actual map `K → Y`; otherwise, state the final density theorem in embedded form. The embedded version is already mathematically substantial and directly usable.

### Significance

This theorem is the natural next step after the finite-dimensional vector-valued EML Stone–Weierstrass result. It shows that Euclidean approximation is not limited to linear or convex codomains: any compact target admitting a neighborhood retraction inside some `ℝ^n` inherits EML universal approximation after a fixed geometric correction by `r`. In particular, this covers compact manifolds and many finite CW-type spaces once embedded in Euclidean space. Formally, it converts the EML approximation theory from “coordinatewise real-valued” to “nonlinear topological target” approximation, which is the right bridge toward manifold-valued learning, equivariant targets, and topology-aware approximation schemes.

### Practical Lean guidance

- Prefer proving the theorem first for `Fin n → ℝ` instead of `ℝ^n` if the existing EML vector theorem is already stated that way.
- If `supNormDist` is not yet defined in the exact needed form, use
  ```lean
  ‖g - F‖
  ```
  in the normed-space structure on `C(K, Fin n → ℝ)` / `C(K, ℝ^n)`, or define
  ```lean
  def supDist (g h : C(K, ℝ^n)) : ℝ := ‖g - h‖
  ```
  and work with that.
- The technically easiest path is likely:
  1. embedded-image theorem in `ℝ^n`,
  2. then a corollary transported back to `Y` only if homeomorphism/subtype machinery is painless.
- Isolate the metric compactness lemma and the uniform continuity-on-compact lemma as reusable standalone results; they are likely useful again for future nonlinear codomain approximation results.

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
