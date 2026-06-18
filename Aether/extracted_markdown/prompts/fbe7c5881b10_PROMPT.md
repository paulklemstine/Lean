## Research Task: EML Stone–Weierstrass for compact polyhedral codomains via simplicial embedding and piecewise-affine neighborhood retraction

Research Mode: PROVE

Work in a new file
`EML/StoneWeierstrass/PolyhedronCodomain.lean`.

The goal is to prove a genuinely new vector-valued universal approximation theorem for EML maps with codomain a compact polyhedron realized inside Euclidean space. The intended route is not CW approximation but an explicit PL-neighborhood-retraction argument: approximate in the ambient Euclidean space, then retract back to the polyhedron.

This should be organized as a sequence of precise intermediate theorems, with the final theorem stated for a compact subset `K : Set (Fin n → ℝ)` equipped with explicit neighborhood-retraction data. If the full simplicial-realization formalization is too heavy, isolate it behind a clean structure and prove the approximation theorem from that structure. The key novelty is the passage from Euclidean-valued EML approximation to polyhedron-valued approximation via a continuous retraction that is uniformly stable near `K`.

### Core formal setup

Introduce a structure encoding the data actually needed by the approximation theorem:

```lean
import Mathlib.Topology.Basic
import Mathlib.Topology.ContinuousFunction.Basic
import Mathlib.Topology.MetricSpace.Basic
import Mathlib.Analysis.NormedSpace.Basic
import Mathlib.Data.Real.Basic

open Set Metric Topology
open scoped Topology

/-- A compact polyhedral target presented as a compact subset of Euclidean space
with an open neighborhood and a continuous retraction. -/
structure PolyhedralRetract (n : ℕ) where
  K : Set (Fin n → ℝ)
  isCompact_K : IsCompact K
  nonempty_K : K.Nonempty
  U : Set (Fin n → ℝ)
  isOpen_U : IsOpen U
  hKU : K ⊆ U
  r : C(U, K)
```

If `C(U, K)` is inconvenient because `U` is a subtype and `K` is a subtype, an equivalent formulation is also acceptable:

```lean
structure PolyhedralRetract' (n : ℕ) where
  K : Set (Fin n → ℝ)
  isCompact_K : IsCompact K
  nonempty_K : K.Nonempty
  U : Set (Fin n → ℝ)
  isOpen_U : IsOpen U
  hKU : K ⊆ U
  r : U → (Fin n → ℝ)
  continuous_r : Continuous r
  mapsTo_r : MapsTo r U K
  retracts_K : ∀ x : (Fin n → ℝ), x ∈ K → r ⟨x, hKU ‹x ∈ K›⟩ = x
```

The second version is often easier to use in Lean. If needed, define both and prove conversion lemmas.

### First target: metric neighborhood stability of the retraction

Prove that compactness of `K` and openness of `U` imply a uniform tubular margin: every point within sufficiently small distance of `K` lies in `U`.

A useful exact statement is:

```lean
theorem exists_thickening_subset_open
    {n : ℕ} {K U : Set (Fin n → ℝ)}
    (hKc : IsCompact K) (hUo : IsOpen U) (hKU : K ⊆ U) :
    ∃ δ > 0, {x | infDist x K < δ} ⊆ U := by
```

If `infDist` causes friction, an equivalent “pointwise witness” version is acceptable:

```lean
theorem exists_uniform_nhd_of_compact_in_open
    {n : ℕ} {K U : Set (Fin n → ℝ)}
    (hKc : IsCompact K) (hUo : IsOpen U) (hKU : K ⊆ U) :
    ∃ δ > 0, ∀ x, (∃ y ∈ K, dist x y < δ) → x ∈ U := by
```

This is the geometric lemma that allows an ambient approximant `g` sufficiently close to a `K`-valued map `f` to land entirely in the retraction neighborhood `U`.

### Second target: uniform continuity of the retraction near the compact target

You need a quantitative modulus near `K`: if `r` is a retraction and `x` is close to `K`, then `r x` is close to the nearby point of `K`. The cleanest way is to use uniform continuity on a compact thickening of `K`.

A robust theorem is:

```lean
theorem retract_uniform_near_id
    {n : ℕ} (P : PolyhedralRetract' n) :
    ∀ ε > 0, ∃ δ > 0,
      ∀ x : (Fin n → ℝ),
        x ∈ P.U →
        infDist x P.K < δ →
        dist (P.r ⟨x, ‹x ∈ P.U›⟩) x < ε := by
```

If proving closeness to `x` directly is awkward, prove the slightly weaker but sufficient estimate relative to a nearby `y ∈ K`:

```lean
theorem retract_uniform_near_points
    {n : ℕ} (P : PolyhedralRetract' n) :
    ∀ ε > 0, ∃ δ > 0,
      ∀ x : (Fin n → ℝ), ∀ y : (Fin n → ℝ),
        y ∈ P.K →
        x ∈ P.U →
        dist x y < δ →
        dist (P.r ⟨x, ‹x ∈ P.U›⟩) y < ε := by
```

This version is often easier: continuity of `r` on a compact neighborhood plus the identity property on `K` gives
`r(y) = y`, so uniform continuity of `r` yields `dist (r x) (r y) < ε`, i.e. `dist (r x) y < ε`.

### Third target: ambient approximation + neighborhood control

Assume you already have the EML scalar/vector Stone–Weierstrass machinery giving Euclidean-valued approximants on compact Hausdorff domains. Package the needed hypothesis abstractly if necessary.

A good abstraction is:

```lean
def UniformDenseEMLToEuclidean
    (X : Type*) [TopologicalSpace X]
    (n : ℕ)
    (A : Set (C(X, ℝ))) : Prop :=
  ∀ f : C(X, Fin n → ℝ), ∀ ε > 0,
    ∃ g : C(X, Fin n → ℝ),
      -- replace by the actual EML-definability predicate available in the library
      True ∧
      ∀ x, ‖g x - f x‖ < ε
```

If the library already has a stronger or differently typed density theorem, use that exact theorem instead of introducing this abstraction. The final theorem should consume the real theorem, not a dummy placeholder. But if the interface is not yet stable, isolating the approximation assumption behind a definition is acceptable.

Now prove the key neighborhood-control lemma:

```lean
theorem eml_approx_into_retraction_nhd
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ} (P : PolyhedralRetract' n)
    (hDense : UniformDenseEMLToEuclidean X n A)
    (f : C(X, P.K)) :
    ∀ ε > 0, ∃ g : C(X, Fin n → ℝ),
      True ∧
      (∀ x, dist (g x) (f x : Fin n → ℝ) < ε) ∧
      Set.MapsTo g Set.univ P.U := by
```

Here `A` should be replaced by the actual EML function class parameter. The proof should not merely approximate into Euclidean space; it must force the image of `g` into `U`. The compactness/open-neighborhood lemma above is exactly what makes this possible: first choose `δ₀` so that `δ₀`-closeness to `K` implies membership in `U`, then ask the Euclidean approximation theorem for error `< δ₀`.

### Final target: K-valued universal approximation via postcomposition with the retraction

The main theorem should state that any continuous `K`-valued map can be uniformly approximated by EML maps after ambient approximation and retraction.

A concrete final theorem, with the EML predicate left schematic, is:

```lean
theorem eml_uniform_dense_polyhedral_codomain
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ} (P : PolyhedralRetract' n)
    (A : Set (C(X, ℝ)))
    (hA_const : True)          -- replace by actual “contains constants”
    (hA_sep : True)            -- replace by actual “separates points”
    (hDense : UniformDenseEMLToEuclidean X n A) :
    ∀ f : C(X, P.K), ∀ ε > 0,
      ∃ h : C(X, P.K),
        True ∧                 -- replace by actual “h is EML-generated / in closure of induced K-valued EML maps”
        ∀ x, dist (h x : Fin n → ℝ) (f x : Fin n → ℝ) < ε := by
```

A more explicit construction theorem is even better:

```lean
theorem exists_retracted_eml_approx
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ} (P : PolyhedralRetract' n)
    (hDense : UniformDenseEMLToEuclidean X n A)
    (f : C(X, P.K)) :
    ∀ ε > 0, ∃ g : C(X, Fin n → ℝ), ∃ h : C(X, P.K),
      True ∧
      h = ContinuousMap.comp P.r
            (show C(X, P.U) from
              { toFun := fun x => ⟨g x, by
                  -- from MapsTo g univ U
                ⟩
                continuous_toFun := by continuity }) ∧
      ∀ x, dist (h x : Fin n → ℝ) (f x : Fin n → ℝ) < ε := by
```

This theorem captures the actual geometric mechanism and is likely the best endpoint for the file.

### Suggested proof strategy

1. **Extract a uniform neighborhood radius from compactness.**  
   For each `y ∈ K`, openness of `U` gives `ρ_y > 0` with `ball y ρ_y ⊆ U`. Use compactness of `K` to extract a finite subcover and let `δ` be the minimum of the corresponding radii. Then any `x` with `dist x K < δ` belongs to `U`. In Lean, this will likely go through `Metric.isCompact_iff_finite_subcover` or compactness of `K` plus the open cover by balls contained in `U`.

2. **Quantify continuity of the retraction on a compact thickening.**  
   Choose a smaller thickening `T := {x | infDist x K ≤ δ}` contained in `U`. Show `T` is compact using compactness of `K` and closed boundedness in finite-dimensional Euclidean space, or by realizing `T` as a closed subset of a compact closed neighborhood of `K`. Restrict `r` to `T`; continuity on compact implies uniform continuity. Since `r(y)=y` for `y ∈ K`, if `x` is `δ`-close to some `y ∈ K`, then `r(x)` is close to `y`, hence close to `x` and to the target value.

3. **Approximate the ambient Euclidean realization of the target map.**  
   For `f : C(X, P.K)`, define
   ```lean
   f₀ : C(X, Fin n → ℝ) := f.comp (ContinuousMap.subtype_val P.K)
   ```
   or the equivalent explicit coercion map. Apply the existing Euclidean-valued EML density theorem to get `g` with sup error `< δ`. Because each `f₀ x ∈ K`, this implies `g x ∈ U` for all `x`.

4. **Retract pointwise and control the final error.**  
   Define
   ```lean
   h x := ⟨P.r ⟨g x, hgU x⟩, P.mapsTo_r _ (hgU x)⟩
   ```
   and prove continuity by composition. For the error estimate, pick `δ` small enough so that `dist (P.r x) y < ε` whenever `y ∈ K` and `dist x y < δ`. Then instantiate with `x = g t`, `y = f t`.

5. **Package the result as density of induced K-valued EML maps.**  
   If there is already a notion of “EML-generated vector-valued map” or closure of a model class under continuous postcomposition, prove the retracted map belongs to that class. If exact definability under arbitrary continuous `r` is unavailable, state the theorem as approximation by postcompositions of ambient EML maps with the fixed retraction; this is still a strong universal approximation theorem and is the correct geometric statement.

### Important auxiliary lemmas worth proving explicitly

These will likely make the main theorem manageable:

```lean
theorem compact_image_subtype_val
    {α : Type*} [TopologicalSpace α] {s : Set α}
    (hs : IsCompact s) :
    IsCompact (Set.range (fun x : s => (x : α))) := by
```

```lean
theorem continuous_subtype_val
    {α : Type*} [TopologicalSpace α] {s : Set α} :
    Continuous (fun x : s => (x : α)) := by
```

```lean
theorem continuousMap_coe_comp
    {X : Type*} [TopologicalSpace X] {n : ℕ}
    {K : Set (Fin n → ℝ)} :
    Continuous fun x : K => (x : Fin n → ℝ) := by
```

```lean
theorem mapsTo_of_uniform_close_to_compact
    {X : Type*} {n : ℕ} {K U : Set (Fin n → ℝ)}
    (hKc : IsCompact K) (hUo : IsOpen U) (hKU : K ⊆ U) :
    ∃ δ > 0, ∀ f g : X → (Fin n → ℝ),
      (∀ x, g x ∈ K) →
      (∀ x, dist (f x) (g x) < δ) →
      MapsTo f Set.univ U := by
```

This last lemma is exactly the “ambient approximation lands in the neighborhood” mechanism, separated from EML specifics.

### If simplicial-realization formalization is feasible

If Mathlib already has enough finite simplicial-complex infrastructure, strengthen the file by introducing a theorem that produces `PolyhedralRetract' n` from a finite simplicial realization. A target shape is:

```lean
theorem exists_polyhedralRetract_of_finite_simplicial_realization
    {n : ℕ} (K : Set (Fin n → ℝ))
    (hK : IsFiniteSimplicialPolyhedron K) :
    ∃ P : PolyhedralRetract' n, P.K = K := by
```

But only do this if the required simplicial notions are actually available. Otherwise define the approximation theorem from the retract data and leave the simplicial-to-retract construction as a separate future theorem. The main mathematical contribution remains the universal approximation theorem from explicit neighborhood-retraction data.

### Why this matters

This theorem is the correct polyhedral extension of the EML Stone–Weierstrass program. It upgrades scalar and Euclidean approximation to a large and geometrically meaningful class of nonlinear targets: compact polyhedra, hence finite simplicial realizations, many stratified spaces, and numerous configuration spaces appearing in applications. The proof is also structurally important: it isolates a reusable principle

- ambient Euclidean approximation,
- quantitative control into an open neighborhood,
- retraction back to the target.

That pattern should later generalize from polyhedra to broader ANR targets. So even if the simplicial realization step is abstracted away, proving the retract-based theorem in full detail is already a significant advance in the EML universal approximation line.

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
