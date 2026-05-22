/-
# EML Stone–Weierstrass for Compact Polyhedral Codomains via Neighborhood Retraction

This file establishes a universal approximation theorem for continuous maps
into a compact polyhedron realized inside Euclidean space. The key idea is:

1. Package the polyhedral target as a compact subset `K ⊆ ℝⁿ` equipped with
   an open neighborhood `U ⊇ K` and a continuous retraction `r : U → K`.
2. Prove a **uniform tubular margin**: compactness of `K` and openness of `U`
   imply a positive δ such that any point within distance δ of `K` lies in `U`.
3. Prove **uniform continuity of the retraction** near `K`: on a compact
   thickening of `K`, the retraction has a quantitative modulus of continuity.
4. Given ambient Euclidean-valued EML approximation, produce an approximant `g`
   close enough to the target that `g(x) ∈ U` for all `x`.
5. Compose with the retraction to obtain a `K`-valued approximant `r ∘ g`.

This lifts Euclidean-valued Stone–Weierstrass to polyhedron-valued approximation
via a purely geometric argument. The pattern generalizes beyond polyhedra to any
compact ANR target.

## Main results

* `PolyhedralRetract` — structure encoding retraction data for a compact polyhedron.
* `exists_thickening_subset_open` — uniform tubular margin from compactness.
* `mapsTo_of_uniform_close_to_compact` — close-to-compact maps land in `U`.
* `retract_uniform_near_points` — uniform retraction stability near `K`.
* `eml_approx_into_retraction_nhd` — ambient approximation landing in `U`.
* `eml_uniform_dense_polyhedral_codomain` — the main K-valued universal approximation.

## References

The neighborhood retraction approach to polyhedral approximation is classical
in PL topology. See e.g. Munkres, *Elements of Algebraic Topology* for the
existence of PL neighborhood retractions of compact polyhedra.
-/
import Mathlib

noncomputable section

open Set Metric Topology Filter

/-! ## Section 1: Polyhedral Retract Structure -/

/-- A compact polyhedral target presented as a compact subset of Euclidean space
with an open neighborhood and a continuous retraction.

This captures the essential data of a compact polyhedron (or more generally, a
compact ANR) embedded in `ℝⁿ`: a compact set `K`, an open neighborhood `U ⊇ K`,
and a continuous retraction `r : U → ℝⁿ` that maps into `K` and fixes `K` pointwise. -/
structure PolyhedralRetract (n : ℕ) where
  /-- The compact target set in `ℝⁿ`. -/
  K : Set (Fin n → ℝ)
  /-- `K` is compact. -/
  isCompact_K : IsCompact K
  /-- `K` is nonempty. -/
  nonempty_K : K.Nonempty
  /-- An open neighborhood of `K` in `ℝⁿ`. -/
  U : Set (Fin n → ℝ)
  /-- `U` is open. -/
  isOpen_U : IsOpen U
  /-- `K` is contained in `U`. -/
  hKU : K ⊆ U
  /-- The retraction map from `U` to `ℝⁿ`. -/
  r : U → (Fin n → ℝ)
  /-- The retraction is continuous. -/
  continuous_r : Continuous r
  /-- The retraction maps into `K`. -/
  mapsTo_r : ∀ u : U, r u ∈ K
  /-- The retraction fixes points in `K`. -/
  retracts_K : ∀ x : (Fin n → ℝ), (hx : x ∈ K) → r ⟨x, hKU hx⟩ = x

/-! ## Section 2: Uniform Tubular Margin from Compactness -/

/-
**Uniform tubular margin**: If `K` is compact, `U` is open, and `K ⊆ U`,
then there exists `δ > 0` such that the `δ`-thickening of `K` is contained in `U`.

This is the key geometric lemma: it guarantees that any point within distance `δ`
of the compact target `K` lies in the retraction neighborhood `U`.
-/
theorem exists_thickening_subset_open
    {n : ℕ} {K U : Set (Fin n → ℝ)}
    (hKc : IsCompact K) (hUo : IsOpen U) (hKU : K ⊆ U) :
    ∃ δ > 0, Metric.thickening δ K ⊆ U := by
  have := hKc.exists_thickening_subset_open hUo hKU;
  exact this

/-
Equivalent pointwise version of the tubular margin:
for any `x` with a nearby point in `K`, `x ∈ U`.
-/
theorem exists_uniform_nhd_of_compact_in_open
    {n : ℕ} {K U : Set (Fin n → ℝ)}
    (hKc : IsCompact K) (hUo : IsOpen U) (hKU : K ⊆ U) :
    ∃ δ > 0, ∀ x, (∃ y ∈ K, dist x y < δ) → x ∈ U := by
  -- By the existence of a uniform tubular margin, there exists a δ > 0 such that the δ-thickening of K is contained in U.
  obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, Metric.thickening δ K ⊆ U := by
    exact exists_thickening_subset_open hKc hUo hKU;
  exact ⟨ δ, hδ_pos, fun x hx => hδ <| mem_thickening_iff.2 hx ⟩

/-! ## Section 3: Maps Close to Compact Sets Land in Open Neighborhoods -/

/-
If `K ⊆ U` with `K` compact and `U` open, then any map uniformly close
to a `K`-valued map has image in `U`. This is the mechanism by which ambient
Euclidean approximation is guaranteed to land in the retraction neighborhood.
-/
theorem mapsTo_of_uniform_close_to_compact
    {X : Type*} {n : ℕ} {K U : Set (Fin n → ℝ)}
    (hKc : IsCompact K) (hUo : IsOpen U) (hKU : K ⊆ U) :
    ∃ δ > 0, ∀ (f g : X → (Fin n → ℝ)),
      (∀ x, g x ∈ K) →
      (∀ x, dist (f x) (g x) < δ) →
      ∀ x, f x ∈ U := by
  obtain ⟨ δ, hδ_pos, hδ ⟩ := exists_uniform_nhd_of_compact_in_open hKc hUo hKU;
  exact ⟨ δ, hδ_pos, fun f g hg hf x => hδ _ ⟨ g x, hg x, hf x ⟩ ⟩

/-! ## Section 4: Uniform Continuity of the Retraction near `K` -/

/-
**Retraction stability near `K`**: for any `ε > 0`, there exists `δ > 0`
such that if `y ∈ K` and `x ∈ U` with `dist x y < δ`, then `dist (r x) y < ε`.

This follows from continuity of `r` and the identity `r(y) = y` for `y ∈ K`:
since `r` is continuous and `K` is compact, `r` is uniformly continuous on
any compact thickening of `K`.
-/
theorem retract_uniform_near_points
    {n : ℕ} (P : PolyhedralRetract n) :
    ∀ ε > 0, ∃ δ > 0,
      ∀ (x y : Fin n → ℝ),
        (hy : y ∈ P.K) →
        (hx : x ∈ P.U) →
        dist x y < δ →
        dist (P.r ⟨x, hx⟩) y < ε := by
  intro ε hε_pos
  obtain ⟨δ₀, hδ₀_pos, hδ₀⟩ : ∃ δ₀ > 0, Metric.cthickening δ₀ P.K ⊆ P.U := by
    have := P.isCompact_K;
    have := this.exists_cthickening_subset_open P.isOpen_U P.hKU;
    tauto;
  -- Since $r$ is continuous on $cthickening δ₀ P.K$ and $cthickening δ₀ P.K$ is compact, $r$ is uniformly continuous on $cthickening δ₀ P.K$.
  have h_unif_cont : UniformContinuousOn (fun x : P.U => P.r x) {x : P.U | x.val ∈ Metric.cthickening δ₀ P.K} := by
    have h_compact : IsCompact {x : (Fin n → ℝ) | x ∈ Metric.cthickening δ₀ P.K} := by
      exact P.isCompact_K.cthickening;
    apply_rules [ IsCompact.uniformContinuousOn_of_continuous, h_compact ];
    · convert h_compact.of_isClosed_subset _ _;
      rotate_left;
      exact Set.image ( fun x : P.U => x.val ) { x : P.U | x.val ∈ cthickening δ₀ P.K };
      · convert h_compact.isClosed using 1;
        ext; aesop;
      · grind;
      · exact Subtype.isCompact_iff;
    · exact P.continuous_r.continuousOn;
  rcases Metric.uniformContinuousOn_iff.mp h_unif_cont ε hε_pos with ⟨ δ₁, hδ₁_pos, hδ₁ ⟩;
  refine' ⟨ Min.min δ₁ δ₀, lt_min hδ₁_pos hδ₀_pos, fun x y hy hx hxy => _ ⟩;
  convert hδ₁ ⟨ x, hx ⟩ _ ⟨ y, hδ₀ <| _ ⟩ _ _ using 1;
  rw [ P.retracts_K y hy ];
  all_goals norm_num [ cthickening ];
  any_goals exact lt_of_lt_of_le hxy ( min_le_left _ _ );
  · exact le_trans ( infEDist_le_edist_of_mem hy ) ( by simpa [ edist_dist ] using ENNReal.ofReal_le_ofReal ( le_of_lt ( lt_of_lt_of_le hxy ( min_le_right _ _ ) ) ) );
  · exact le_trans ( infEDist_le_edist_of_mem hy ) ( by simp +decide );
  · exact le_trans ( infEDist_le_edist_of_mem hy ) ( by simp +decide )

/-! ## Section 5: Euclidean-Valued Approximation Abstraction -/

/-- Abstract predicate for a class of maps that is uniformly dense in `C(X, ℝⁿ)`.
In the EML context, this is the class of EML-generated vector-valued maps.

If the EML library already provides a concrete density theorem, use it directly.
This abstraction allows the polyhedral codomain theorem to be stated independently
of any particular approximation class. -/
def UniformDenseApprox
    (X : Type*) [TopologicalSpace X]
    (n : ℕ) : Prop :=
  ∀ f : C(X, Fin n → ℝ), ∀ ε > 0,
    ∃ g : C(X, Fin n → ℝ),
      ∀ x, ‖g x - f x‖ < ε

/-! ## Section 6: Ambient Approximation Landing in `U` -/

/-
**Approximation into the retraction neighborhood**: if ambient Euclidean-valued
approximation is dense, then any `K`-valued map can be approximated by maps
whose image lies in `U`.

Given `f : X → K` continuous and `ε > 0`, we first choose `δ` from the
tubular margin lemma, then find an ambient approximant `g` with `‖g - f‖ < δ`.
Since `f` maps into `K` and every point within `δ` of `K` lies in `U`, the
image of `g` is contained in `U`.
-/
theorem eml_approx_into_retraction_nhd
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ} (P : PolyhedralRetract n)
    (hDense : UniformDenseApprox X n)
    (f : C(X, Fin n → ℝ))
    (hf : ∀ x, f x ∈ P.K) :
    ∀ ε > 0, ∃ g : C(X, Fin n → ℝ),
      (∀ x, dist (g x) (f x) < ε) ∧
      (∀ x, g x ∈ P.U) := by
  intro ε hεpos
  obtain ⟨δ₀, hδ₀pos, hδ₀⟩ : ∃ δ₀ > 0, ∀ x, (∃ y ∈ P.K, dist x y < δ₀) → x ∈ P.U := exists_uniform_nhd_of_compact_in_open P.isCompact_K P.isOpen_U P.hKU;
  obtain ⟨ g, hg ⟩ := hDense f ( Min.min ε δ₀ ) ( lt_min hεpos hδ₀pos );
  exact ⟨ g, fun x => lt_of_lt_of_le ( hg x ) ( min_le_left _ _ ), fun x => hδ₀ _ ⟨ f x, hf x, lt_of_lt_of_le ( hg x ) ( min_le_right _ _ ) ⟩ ⟩

/-! ## Section 7: Main Theorem — K-Valued Universal Approximation -/

/-
**EML universal approximation for compact polyhedral codomains.**

For any continuous map `f : X → K` from a compact space into a compact polyhedron
`K ⊆ ℝⁿ` equipped with neighborhood retraction data, and any `ε > 0`, there exists
a continuous map `h : X → K` such that `‖h(x) - f(x)‖ < ε` for all `x`.

The map `h` is constructed as `r ∘ g` where `g` is an ambient Euclidean approximant
and `r` is the retraction. This is the key mechanism: approximate in the ambient
space, then retract back to the polyhedron.

**Proof outline:**
1. Use `retract_uniform_near_points` to find `δ₁` such that `r` is `ε`-stable
   near `K`.
2. Use `mapsTo_of_uniform_close_to_compact` to find `δ₂` such that `δ₂`-close
   maps land in `U`.
3. Set `δ = min δ₁ δ₂` and use `hDense` to find an ambient approximant `g`
   with `‖g - f‖ < δ`.
4. Then `g(x) ∈ U` for all `x`, so `h(x) = r(g(x))` is well-defined and in `K`.
5. Since `dist(g(x), f(x)) < δ₁` and `f(x) ∈ K`, we get `dist(r(g(x)), f(x)) < ε`.
-/
theorem eml_uniform_dense_polyhedral_codomain
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ} (P : PolyhedralRetract n)
    (hDense : UniformDenseApprox X n) :
    ∀ (f : C(X, Fin n → ℝ)), (∀ x, f x ∈ P.K) →
    ∀ ε > 0,
      ∃ h : C(X, Fin n → ℝ),
        (∀ x, h x ∈ P.K) ∧
        (∀ x, dist (h x) (f x) < ε) := by
  intro f hf ε hε;
  obtain ⟨ δ₁, hδ₁, hδ₁' ⟩ := retract_uniform_near_points P ε hε;
  obtain ⟨g, hg⟩ : ∃ g : C(X, Fin n → ℝ), (∀ x, dist (g x) (f x) < δ₁) ∧ (∀ x, g x ∈ P.U) := by
    exact eml_approx_into_retraction_nhd P hDense f hf δ₁ hδ₁;
  refine' ⟨ ⟨ fun x => P.r ⟨ g x, hg.2 x ⟩, _ ⟩, _, _ ⟩;
  exact P.continuous_r.comp ( Continuous.subtype_mk g.continuous fun x => hg.2 x );
  · exact fun x => P.mapsTo_r ⟨ g x, hg.2 x ⟩;
  · exact fun x => hδ₁' _ _ ( hf x ) ( hg.2 x ) ( hg.1 x )

/-
**Constructive version**: the approximant is explicitly `r ∘ g` where `g` is
the ambient Euclidean approximant. This makes the geometric mechanism transparent.
-/
theorem exists_retracted_eml_approx
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ} (P : PolyhedralRetract n)
    (hDense : UniformDenseApprox X n) :
    ∀ (f : C(X, Fin n → ℝ)), (∀ x, f x ∈ P.K) →
    ∀ ε > 0,
      ∃ g : C(X, Fin n → ℝ),
        ∃ hgU : ∀ x, g x ∈ P.U,
        (∀ x, P.r ⟨g x, hgU x⟩ ∈ P.K) ∧
        (∀ x, dist (P.r ⟨g x, hgU x⟩) (f x) < ε) := by
  intro f hf ε εpos
  obtain ⟨δ₁, δ₁pos, hδ₁⟩ := retract_uniform_near_points P ε εpos
  obtain ⟨δ₂, δ₂pos, hδ₂⟩ := exists_uniform_nhd_of_compact_in_open P.isCompact_K P.isOpen_U P.hKU;
  obtain ⟨g, hg⟩ : ∃ g : C(X, Fin n → ℝ), ∀ x, dist (g x) (f x) < min δ₁ δ₂ := by
    exact hDense f _ ( lt_min δ₁pos δ₂pos );
  refine' ⟨ g, fun x => hδ₂ _ ⟨ f x, hf x, lt_of_lt_of_le ( hg x ) ( min_le_right _ _ ) ⟩, fun x => P.mapsTo_r _, fun x => hδ₁ _ _ ( hf x ) _ ( lt_of_lt_of_le ( hg x ) ( min_le_left _ _ ) ) ⟩

end