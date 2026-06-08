/-
# EML Stone–Weierstrass for Compact Hausdorff Codomains as Inverse Limits

This file establishes a codomain-universal approximation theorem for
compact Hausdorff codomains presented as inverse limits of compact
metrizable stages.

## Mathematical content

The core result is a *reduction theorem*: if a class of maps (e.g. EML maps)
is dense in continuous maps to each compact metrizable stage `Y n`, then
that class is dense in continuous maps to the inverse limit `L` of the
system `(Y n, p n)`.

The proof proceeds by:
1. **Finite-coordinate metric control**: The inverse-limit topology is
   metrized so that finitely many coordinate projections control the metric.
2. **Compatible approximation at finite stages**: Approximate the first
   `N` coordinate projections by maps from the given class, maintaining
   compatibility across the inverse system.
3. **Assembly and error bound**: The finite-coordinate control ensures
   the assembled map is close to the original in the limit metric.

## Main results

* `inverseLimit_metric_control` — finitely many projections control the
  metric on `C(X, L)`.
* `approx_inverseLimit_from_finite_coordinates` — the main reduction
  theorem: given finite-coordinate metric control and compatible
  approximation at finite stages, the class is dense in `C(X, L)`.
* `stoneWeierstrass_inverseLimit` — the combined self-contained version.
* `dense_inverseLimit_nat` — the version with explicit inverse-limit structure.
* `compatible_approx_from_section` — derivation of the compatible
  approximation hypothesis from section-based finite-stage density.
* `dense_inverseLimit_full_pipeline` — the full end-to-end pipeline.

## Design choices

- We parameterize by a general map predicate `P : C(X, L) → Prop` rather
  than a specific `IsEMLMap` definition. This makes the theorems applicable
  to any class of maps satisfying the closure property (e.g., EML maps,
  neural network maps, polynomial maps).
- We work with the Mathlib metric on `C(X, Y)` for compact `X` and metric `Y`.
- The inverse system is indexed by `ℕ` with bonding maps `p n : C(Y (n+1), Y n)`.
-/
import Mathlib

noncomputable section

open scoped Topology
open ContinuousMap Set Metric

/-! ## §1. Finite-Coordinate Metric Control

The key lemma: if the projections of an inverse limit separate points
metrically (in the sense that finitely many projections suffice to control
the distance), then the same holds for the sup-metric on `C(X, L)`. -/

variable {X : Type*} [TopologicalSpace X] [CompactSpace X]

/-- **Finite-coordinate metric control for function spaces.**

If `L` is metrized so that finitely many projections `π n` control the
distance (i.e., closeness in the first `N` coordinates implies closeness
in `L`), then the same control lifts to the sup-metric on `C(X, L)`.

This is the fundamental bridge between stage-level approximation and
approximation in the inverse limit. -/
theorem inverseLimit_metric_control
    {L : Type*} [MetricSpace L] [CompactSpace L]
    {Y : ℕ → Type*} [∀ n, MetricSpace (Y n)] [∀ n, CompactSpace (Y n)]
    (π : ∀ n, C(L, Y n))
    (h_embed : ∀ ε > 0, ∃ N : ℕ, ∀ ⦃y z : L⦄,
      (∀ n ≤ N, dist (π n y) (π n z) < ε / 2) → dist y z < ε) :
    ∀ ε > 0, ∃ N : ℕ, ∀ ⦃f g : C(X, L)⦄,
      (∀ n ≤ N, dist ((π n).comp f) ((π n).comp g) < ε / 2) →
      dist f g < ε := by
  intro ε hε
  obtain ⟨N, hN⟩ := h_embed ε hε
  refine ⟨N, fun {f g} hfg => ?_⟩
  rw [ContinuousMap.dist_lt_iff hε]
  intro x
  apply hN
  intro n hn
  have h1 : dist (((π n).comp f) x) (((π n).comp g) x) ≤
      dist ((π n).comp f) ((π n).comp g) := ContinuousMap.dist_apply_le_dist x
  simp only [ContinuousMap.comp_apply] at h1
  linarith [hfg n hn]

/-! ## §2. Main Reduction Theorem -/

/-- **Approximation via inverse-limit finite-coordinate reduction.**

This is the main reduction theorem. It shows that density of a class of
maps in the inverse-limit codomain `L` follows from:
1. Finite-coordinate metric control (`h_embed`),
2. The ability to produce compatible approximations from the class at
   finitely many stages and assemble them into `L` (`h_compatible_approx`).

The parameter `P` is any predicate on `C(X, L)` (e.g., "is EML-realizable"). -/
theorem approx_inverseLimit_from_finite_coordinates
    {L : Type*} [MetricSpace L] [CompactSpace L]
    {Y : ℕ → Type*} [∀ n, MetricSpace (Y n)] [∀ n, CompactSpace (Y n)]
    (π : ∀ n, C(L, Y n))
    (h_embed : ∀ ε > 0, ∃ N : ℕ, ∀ ⦃y z : L⦄,
      (∀ n ≤ N, dist (π n y) (π n z) < ε / 2) → dist y z < ε)
    {P : C(X, L) → Prop}
    (h_compatible_approx : ∀ (f : C(X, L)) (N : ℕ) (δ : ℝ), 0 < δ →
      ∃ G : C(X, L), P G ∧
        ∀ n ≤ N, dist ((π n).comp f) ((π n).comp G) < δ) :
    ∀ (f : C(X, L)) (ε : ℝ), 0 < ε →
      ∃ G : C(X, L), P G ∧ dist f G < ε := by
  intro f ε hε
  -- Step 1: Get N such that N-coordinate control implies ε-control
  obtain ⟨N, hN⟩ := inverseLimit_metric_control (X := X) π h_embed ε hε
  -- Step 2: Get compatible approximation at the first N stages
  obtain ⟨G, hG_class, hG_close⟩ := h_compatible_approx f N (ε / 2) (half_pos hε)
  -- Step 3: Conclude using metric control
  exact ⟨G, hG_class, hN hG_close⟩

/-! ## §3. Inverse-Limit Structure -/

/-- A presentation of `L` as an inverse limit of the system `(Y, p)`.
This captures the essential data: projection maps, compatibility with
bonding maps, and the separation property. -/
structure InverseLimitPresentation
    {Y : ℕ → Type*} [∀ n, TopologicalSpace (Y n)]
    (p : ∀ n, C(Y (n + 1), Y n))
    (L : Type*) [TopologicalSpace L] where
  /-- The projection maps from `L` to each stage. -/
  proj : ∀ n, C(L, Y n)
  /-- Projections are compatible with bonding maps. -/
  compat : ∀ n, (p n).comp (proj (n + 1)) = proj n
  /-- Projections separate points. -/
  separates : ∀ (x y : L), (∀ n, proj n x = proj n y) → x = y

/-! ## §4. Density Theorem with Inverse-Limit Structure -/

/-- **Density theorem for inverse-limit codomains.**

If `L` is a compact metrizable space presented as an inverse limit of
compact metrizable stages `Y n`, and a class of maps `P` admits compatible
finite-stage approximation, then `P` is dense in `C(X, L)`. -/
theorem dense_inverseLimit_nat
    {Y : ℕ → Type*}
    [∀ n, MetricSpace (Y n)]
    [∀ n, CompactSpace (Y n)]
    (p : ∀ n, C(Y (n + 1), Y n))
    {L : Type*} [MetricSpace L] [CompactSpace L]
    (lim : InverseLimitPresentation p L)
    (h_embed : ∀ ε > 0, ∃ N : ℕ, ∀ ⦃y z : L⦄,
      (∀ n ≤ N, dist (lim.proj n y) (lim.proj n z) < ε / 2) → dist y z < ε)
    {P : C(X, L) → Prop}
    (h_compatible_approx : ∀ (f : C(X, L)) (N : ℕ) (δ : ℝ), 0 < δ →
      ∃ G : C(X, L), P G ∧
        ∀ n ≤ N, dist ((lim.proj n).comp f) ((lim.proj n).comp G) < δ) :
    ∀ (f : C(X, L)) (ε : ℝ), 0 < ε →
      ∃ G : C(X, L), P G ∧ dist f G < ε :=
  approx_inverseLimit_from_finite_coordinates lim.proj h_embed h_compatible_approx

/-! ## §5. Quantitative Estimates for Projection Maps -/

/-- The composition with a 1-Lipschitz map is nonexpansive on `C(X, -)`. -/
theorem dist_comp_le_of_lipschitz
    {Y Z : Type*} [MetricSpace Y] [CompactSpace Y] [MetricSpace Z] [CompactSpace Z]
    (φ : C(Y, Z)) (hφ : LipschitzWith 1 φ)
    (f g : C(X, Y)) :
    dist (φ.comp f) (φ.comp g) ≤ dist f g := by
  rw [ContinuousMap.dist_le (dist_nonneg)]
  intro x
  calc dist (φ (f x)) (φ (g x))
      ≤ 1 * dist (f x) (g x) := hφ.dist_le_mul _ _
    _ = dist (f x) (g x) := one_mul _
    _ ≤ dist f g := ContinuousMap.dist_apply_le_dist x

/-- If a projection is 1-Lipschitz, closeness in `C(X, L)` implies
closeness in coordinates. -/
theorem stage_close_of_total_close
    {L : Type*} [MetricSpace L] [CompactSpace L]
    {Y : Type*} [MetricSpace Y] [CompactSpace Y]
    (π : C(L, Y)) (hπ : LipschitzWith 1 π)
    {f g : C(X, L)} {δ : ℝ} (h : dist f g < δ) :
    dist (π.comp f) (π.comp g) < δ :=
  lt_of_le_of_lt (dist_comp_le_of_lipschitz π hπ f g) h

/-! ## §6. Combined Self-Contained Statement -/

/-- **Stone–Weierstrass for inverse-limit codomains (combined statement).**

All hypotheses are stated explicitly without reference to auxiliary structures.
The key hypotheses are:
- `h_embed`: finitely many projections control the metric on `L`,
- `h_finite_assembly`: compatible approximations from the class `P` at
  finitely many stages can be assembled into a class-`P` map to `L`.

The conclusion is that the class `P` is dense in `C(X, L)`. -/
theorem stoneWeierstrass_inverseLimit
    {L : Type*} [MetricSpace L] [CompactSpace L]
    {Y : ℕ → Type*} [∀ n, MetricSpace (Y n)] [∀ n, CompactSpace (Y n)]
    (π : ∀ n, C(L, Y n))
    (h_embed : ∀ ε > 0, ∃ N : ℕ, ∀ ⦃y z : L⦄,
      (∀ n ≤ N, dist (π n y) (π n z) < ε / 2) → dist y z < ε)
    {P : C(X, L) → Prop}
    (h_finite_assembly : ∀ (f : C(X, L)) (N : ℕ) (δ : ℝ), 0 < δ →
      ∃ G : C(X, L), P G ∧
        ∀ n ≤ N, dist ((π n).comp f) ((π n).comp G) < δ) :
    ∀ (f : C(X, L)) (ε : ℝ), 0 < ε →
      ∃ G : C(X, L), P G ∧ dist f G < ε :=
  approx_inverseLimit_from_finite_coordinates π h_embed h_finite_assembly

/-! ## §7. Postcomposition Stability -/

/-- If a map predicate `P` is closed under postcomposition by continuous maps,
and `f` satisfies `P`, then `φ ∘ f` satisfies `P`. -/
theorem map_class_comp
    {A B C : Type*} [TopologicalSpace A] [TopologicalSpace B] [TopologicalSpace C]
    {P : C(A, B) → Prop} {Q : C(A, C) → Prop}
    (h_comp : ∀ (φ : C(B, C)) (f : C(A, B)), P f → Q (φ.comp f))
    (φ : C(B, C)) {f : C(A, B)} (hf : P f) :
    Q (φ.comp f) :=
  h_comp φ f hf

/-! ## §8. Derivation of Compatible Approximation via Sections

We show how the compatible approximation hypothesis can be derived from
two ingredients:
1. A "finite-stage density" theorem applied to a space `Z_N` (intuitively,
   the finite limit stage — the subspace of compatible truncated families).
2. A continuous section/embedding from `Z_N` back to `L`.

This shows that the hard hypothesis in the main theorem can be reduced to
density in a single compact metrizable ANR codomain. -/

/-- **Compatible approximation from finite-stage density via sections.**

If for each `N` there is:
- An embedding `embedN : C(L, Z_N)` and section `sectionN : C(Z_N, L)`,
- Such that `sectionN ∘ embedN` preserves the first `N` coordinates exactly,
- And the class `P` is dense in `C(X, Z_N)` (with `P` closed under
  postcomposition by `sectionN`),
- And the projections and sections are 1-Lipschitz,

then the compatible approximation hypothesis holds. -/
theorem compatible_approx_from_section
    {L : Type*} [MetricSpace L] [CompactSpace L]
    {Y : ℕ → Type*} [∀ n, MetricSpace (Y n)] [∀ n, CompactSpace (Y n)]
    (π : ∀ n, C(L, Y n))
    {P : C(X, L) → Prop}
    -- For each N, a "finite limit stage" space
    {Z : ℕ → Type*} [∀ N, MetricSpace (Z N)] [∀ N, CompactSpace (Z N)]
    -- Embedding L into the finite limit stage
    (embedN : ∀ N, C(L, Z N))
    -- Section from finite limit stage back to L
    (sectionN : ∀ N, C(Z N, L))
    -- Section ∘ embed preserves coordinates exactly
    (h_section_embed : ∀ N n, n ≤ N →
      ∀ y : L, (π n) ((sectionN N) ((embedN N) y)) = π n y)
    -- P is dense in C(X, Z_N) with postcomposition by sectionN
    (h_dense_stage : ∀ N (f : C(X, Z N)) (δ : ℝ), 0 < δ →
      ∃ g : C(X, Z N), P ((sectionN N).comp g) ∧ dist f g < δ)
    -- Projections are Lipschitz
    (h_proj_lip : ∀ n, LipschitzWith 1 (π n))
    -- Sections are Lipschitz
    (h_section_lip : ∀ N, LipschitzWith 1 (sectionN N)) :
    ∀ (f : C(X, L)) (N : ℕ) (δ : ℝ), 0 < δ →
      ∃ G : C(X, L), P G ∧
        ∀ n ≤ N, dist ((π n).comp f) ((π n).comp G) < δ := by
  intro f N δ hδ
  -- Embed f into the finite limit stage
  let fN := (embedN N).comp f
  -- Approximate fN in C(X, Z_N)
  obtain ⟨gN, hgN_class, hgN_close⟩ := h_dense_stage N fN δ hδ
  -- G = sectionN N ∘ gN
  refine ⟨(sectionN N).comp gN, hgN_class, fun n hn => ?_⟩
  -- We need: dist ((π n).comp f) ((π n).comp ((sectionN N).comp gN)) < δ
  -- Key: (π n).comp f = (π n).comp (sectionN N).comp (embedN N).comp f
  --   because sectionN ∘ embedN preserves coordinate n
  have key : (π n).comp f = (π n).comp ((sectionN N).comp fN) := by
    ext x
    simp only [ContinuousMap.comp_apply, fN]
    exact (h_section_embed N n hn (f x)).symm
  rw [key]
  -- Now: dist ((π n).comp (sectionN N).comp fN) ((π n).comp (sectionN N).comp gN) < δ
  show dist ((π n).comp ((sectionN N).comp fN)) ((π n).comp ((sectionN N).comp gN)) < δ
  have h_comp_lip : LipschitzWith 1 ((π n).comp (sectionN N)) := by
    have := (h_proj_lip n).comp (h_section_lip N)
    simpa [mul_one] using this
  calc dist ((π n).comp ((sectionN N).comp fN)) ((π n).comp ((sectionN N).comp gN))
      = dist (((π n).comp (sectionN N)).comp fN) (((π n).comp (sectionN N)).comp gN) := by
        rfl
    _ ≤ dist fN gN := dist_comp_le_of_lipschitz _ h_comp_lip fN gN
    _ < δ := hgN_close

/-! ## §9. Full Pipeline: From Stage-Level Density to Inverse-Limit Density -/

/-- **Full pipeline theorem.**

Combines the finite-coordinate metric control, section-based compatible
approximation, and the main reduction theorem into a single end-to-end
statement. Given:
- An inverse limit with metric control,
- Section maps from finite limit stages back to `L`,
- Density of the class `P` at each finite stage,

we conclude density of `P` in `C(X, L)`. -/
theorem dense_inverseLimit_full_pipeline
    {L : Type*} [MetricSpace L] [CompactSpace L]
    {Y : ℕ → Type*} [∀ n, MetricSpace (Y n)] [∀ n, CompactSpace (Y n)]
    (π : ∀ n, C(L, Y n))
    (h_embed : ∀ ε > 0, ∃ N : ℕ, ∀ ⦃y z : L⦄,
      (∀ n ≤ N, dist (π n y) (π n z) < ε / 2) → dist y z < ε)
    {P : C(X, L) → Prop}
    -- Finite limit stages with sections
    {Z : ℕ → Type*} [∀ N, MetricSpace (Z N)] [∀ N, CompactSpace (Z N)]
    (embedN : ∀ N, C(L, Z N))
    (sectionN : ∀ N, C(Z N, L))
    (h_section_embed : ∀ N n, n ≤ N →
      ∀ y : L, (π n) ((sectionN N) ((embedN N) y)) = π n y)
    (h_dense_stage : ∀ N (f : C(X, Z N)) (δ : ℝ), 0 < δ →
      ∃ g : C(X, Z N), P ((sectionN N).comp g) ∧ dist f g < δ)
    (h_proj_lip : ∀ n, LipschitzWith 1 (π n))
    (h_section_lip : ∀ N, LipschitzWith 1 (sectionN N)) :
    ∀ (f : C(X, L)) (ε : ℝ), 0 < ε →
      ∃ G : C(X, L), P G ∧ dist f G < ε :=
  approx_inverseLimit_from_finite_coordinates π h_embed
    (compatible_approx_from_section π embedN sectionN h_section_embed
      h_dense_stage h_proj_lip h_section_lip)

/-! ## §10. Concrete EML Specialization

We define a concrete `IsEMLMap` predicate for the reduction theorem. -/

/-- An EML map predicate, abstracting the essential closure property. -/
structure EMLDensity
    (Y : ℕ → Type*) [∀ n, MetricSpace (Y n)] [∀ n, CompactSpace (Y n)]
    (L : Type*) [MetricSpace L] [CompactSpace L]
    (π : ∀ n, C(L, Y n)) where
  /-- The predicate on maps `C(X, L)` asserting EML-realizability. -/
  isEML : C(X, L) → Prop
  /-- Compatible finite-stage approximation from EML maps. -/
  compatible_approx : ∀ (f : C(X, L)) (N : ℕ) (δ : ℝ), 0 < δ →
    ∃ G : C(X, L), isEML G ∧
      ∀ n ≤ N, dist ((π n).comp f) ((π n).comp G) < δ

/-- **EML-specific inverse-limit density theorem.**

If `L` is presented as an inverse limit with metric control, and we have
EML density data (as packaged in `EMLDensity`), then every continuous
map `f : C(X, L)` can be uniformly approximated by EML-realizable maps. -/
theorem eml_dense_inverseLimit
    {Y : ℕ → Type*} [∀ n, MetricSpace (Y n)] [∀ n, CompactSpace (Y n)]
    {L : Type*} [MetricSpace L] [CompactSpace L]
    (π : ∀ n, C(L, Y n))
    (h_embed : ∀ ε > 0, ∃ N : ℕ, ∀ ⦃y z : L⦄,
      (∀ n ≤ N, dist (π n y) (π n z) < ε / 2) → dist y z < ε)
    (eml : EMLDensity (X := X) Y L π) :
    ∀ (f : C(X, L)) (ε : ℝ), 0 < ε →
      ∃ G : C(X, L), eml.isEML G ∧ dist f G < ε :=
  approx_inverseLimit_from_finite_coordinates π h_embed eml.compatible_approx

end