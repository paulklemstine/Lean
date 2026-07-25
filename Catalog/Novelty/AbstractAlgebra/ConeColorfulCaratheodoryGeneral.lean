import Mathlib

/-!
# The Cone Colorful Carathéodory Theorem in general dimension

This file deepens the *cone colorful Carathéodory* development.  Earlier work
established the homogeneity bridge between conical and convex representability of
the origin, together with the **dimension-one** colorful theorem and the conic
Carathéodory bound.  Here we prove the theorem in **arbitrary finite dimension**.

The main results are:

* `ConeColorfulGeneral.isConicZero_iff_isConvexZero` — the homogeneity bridge:
  for the origin, "nontrivial conical combination" and "convex combination"
  coincide.
* `ConeColorfulGeneral.colorful_caratheodory_zero` — the **affine colorful
  Carathéodory theorem for the origin**: given `d + 1` (or more) color classes in
  a `d`-dimensional real inner product space, each having the origin in its
  convex hull, there is a colorful transversal (one point per color) whose convex
  hull contains the origin.  This is Bárány's colorful Carathéodory theorem,
  specialised to the origin and formalised via a nearest-point descent argument.
* `ConeColorfulGeneral.colorful_cone` — the **cone colorful Carathéodory
  theorem**: the same statement phrased for convex cones, i.e. each color class
  captures the origin as a nontrivial conical combination and so does the
  resulting transversal.

The threshold `finrank + 1 ≤ #colors` is sharp already in dimension one.
-/

open scoped BigOperators RealInnerProductSpace
open Finset

namespace ConeColorfulGeneral

variable {ι : Type*} {V : Type*}

section Defs
variable [AddCommGroup V] [Module ℝ V]

/-- The origin is a **nontrivial conical combination** of the vectors `p i`,
`i ∈ s`: nonnegative weights, not all zero, whose weighted sum vanishes. -/
def IsConicZero (s : Finset ι) (p : ι → V) : Prop :=
  ∃ w : ι → ℝ, (∀ i ∈ s, 0 ≤ w i) ∧ (∃ i ∈ s, 0 < w i) ∧ ∑ i ∈ s, w i • p i = 0

/-- The origin is a **convex combination** of the vectors `p i`, `i ∈ s`. -/
def IsConvexZero (s : Finset ι) (p : ι → V) : Prop :=
  ∃ w : ι → ℝ, (∀ i ∈ s, 0 ≤ w i) ∧ (∑ i ∈ s, w i = 1) ∧ ∑ i ∈ s, w i • p i = 0

/-- **Homogeneity bridge.**  For the origin, conical and convex representability
coincide. -/
theorem isConicZero_iff_isConvexZero (s : Finset ι) (p : ι → V) :
    IsConicZero s p ↔ IsConvexZero s p := by
  refine' ⟨ _, _ ⟩
  · rintro ⟨ w, hw₁, hw₂, hw₃ ⟩
    refine' ⟨ fun i => w i / ( ∑ i ∈ s, w i ), _, _, _ ⟩ <;> simp_all +decide [ ← Finset.sum_div _ _ _ ]
    · exact fun i hi => div_nonneg ( hw₁ i hi ) ( Finset.sum_nonneg hw₁ )
    · exact ne_of_gt ( lt_of_lt_of_le hw₂.choose_spec.2 ( Finset.single_le_sum ( fun i _ => hw₁ i ‹_› ) hw₂.choose_spec.1 ) )
    · simp +decide only [div_eq_inv_mul, mul_smul]
      rw [ ← Finset.smul_sum, hw₃, smul_zero ]
  · rintro ⟨ w, hw₁, hw₂ ⟩
    exact ⟨ w, hw₁, by obtain ⟨ i, hi, hi' ⟩ := Finset.exists_ne_zero_of_sum_ne_zero ( by linarith : ( ∑ i ∈ s, w i ) ≠ 0 ) ; exact ⟨ i, hi, lt_of_le_of_ne ( hw₁ i hi ) hi'.symm ⟩, hw₂.2 ⟩

end Defs

section Conversions
variable [NormedAddCommGroup V] [InnerProductSpace ℝ V]

/-
A finite set captures the origin as a convex combination iff the origin lies
in its convex hull.
-/
theorem isConvexZero_id_iff_mem_convexHull (s : Finset V) :
    IsConvexZero s (id : V → V) ↔ (0 : V) ∈ convexHull ℝ (s : Set V) := by
  rw [ Finset.convexHull_eq ];
  simp +decide [ IsConvexZero, Finset.centerMass ];
  exact ⟨ fun ⟨ w, hw₁, hw₂, hw₃ ⟩ => ⟨ w, hw₁, hw₂, Or.inr hw₃ ⟩, fun ⟨ w, hw₁, hw₂, hw₃ ⟩ => ⟨ w, hw₁, hw₂, hw₃.resolve_left ( by linarith ) ⟩ ⟩

/-
If the origin lies in the convex hull of the range of a transversal, it is a
convex combination indexed by the colors.
-/
theorem isConvexZero_univ_of_mem_convexHull_range [Fintype ι] (t : ι → V)
    (h : (0 : V) ∈ convexHull ℝ (Set.range t)) :
    IsConvexZero (Finset.univ : Finset ι) t := by
  contrapose! h;
  simp_all +decide [ IsConvexZero, convexHull_range_eq_exists_affineCombination ];
  intro s x hx₁ hx₂ hx₃;
  convert h ( fun i => if i ∈ s then x i else 0 ) _ _ _;
  exact fun _ => Classical.dec _;
  · grind;
  · rw [ ← hx₂, ← Finset.sum_filter ] ; congr ; aesop;
  · aesop

end Conversions

section Core
variable [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V]

/-
An affinely independent finite set all of whose points lie on a common level
set `⟪p, ·⟫ = c` of a nonzero linear functional has at most `finrank ℝ V` points:
the differences all lie in the hyperplane `ker ⟪p, ·⟫` of dimension `finrank - 1`.
-/
theorem card_le_finrank_of_const_inner {p : V} (hp : p ≠ 0) {A : Finset V} {c : ℝ}
    (hAI : AffineIndependent ℝ ((↑) : A → V))
    (hconst : ∀ a ∈ A, ⟪p, a⟫ = c) :
    A.card ≤ Module.finrank ℝ V := by
  by_contra h_contra;
  -- Let $f : V →ₗ[ℝ] ℝ$ be the linear functional $f = innerₗ (𝕜:=ℝ) p$, i.e. $f x = ⟪p, x⟫$.
  set f : V →ₗ[ℝ] ℝ := innerₛₗ ℝ p with hf_def;
  -- By `AffineIndependent.finrank_vectorSpan_add_one hAI`, `finrank (vectorSpan ℝ (Set.range ((↑) : A → V))) + 1 = Fintype.card A = A.card`.
  have h_finrank : Module.finrank ℝ (vectorSpan ℝ (Set.range ((↑) : A → V))) + 1 = A.card := by
    convert AffineIndependent.finrank_vectorSpan_add_one hAI;
    · rw [ Fintype.card_of_subtype ] ; aesop;
    · exact Finset.card_pos.mp ( pos_of_gt ( lt_of_not_ge h_contra ) ) |> fun ⟨ x, hx ⟩ => ⟨ ⟨ x, hx ⟩ ⟩;
  -- Claim `vectorSpan ℝ (↑A : Set V) ≤ LinearMap.ker f`.
  have h_vectorSpan_le_ker : vectorSpan ℝ (Set.range ((↑) : A → V)) ≤ LinearMap.ker f := by
    simp +decide [ vectorSpan, Set.range ];
    rw [ Submodule.span_le ];
    rintro _ ⟨ a, ha, b, hb, rfl ⟩ ; simp +decide ;
    aesop;
  have := LinearMap.finrank_range_add_finrank_ker f; simp_all +decide ;
  rw [ show f.range = ⊤ from _ ] at this ; simp_all +decide ;
  · linarith [ show Module.finrank ℝ ( vectorSpan ℝ ( Set.range ( ( ↑ ) : A → V ) ) ) ≤ Module.finrank ℝ ( LinearMap.ker f ) from Submodule.finrank_mono <| by aesop ];
  · exact LinearMap.range_eq_top.mpr fun x => ⟨ ( x / ‖p‖ ^ 2 ) • p, by simp +decide [ hf_def, inner_self_eq_norm_sq_to_K, hp ] ⟩

/-
**Descent step.**  In a convex set containing a nonzero point `p` and a point
`y` with `⟪p, y⟫ < ‖p‖²`, there is a point strictly closer to the origin than `p`.
Moving from `p` slightly towards `y` decreases the norm.
-/
omit [FiniteDimensional ℝ V] in
theorem exists_closer_of_inner_lt {K : Set V} (hK : Convex ℝ K) {p y : V}
    (hp : p ∈ K) (hy : y ∈ K) (hpne : p ≠ 0) (hlt : ⟪p, y⟫ < ‖p‖ ^ 2) :
    ∃ q ∈ K, ‖q‖ < ‖p‖ := by
  -- Set θ := min(1, dd / ee). Then 0 < θ (since dd/ee > 0 and 1 > 0) and θ ≤ 1. Also θ ≤ dd/ee, hence θ * ee ≤ dd.
  set dd := ‖p‖^2 - ⟪p, y⟫
  have hdd_pos : 0 < dd := by
    exact sub_pos_of_lt hlt
  set ee := ‖y - p‖^2
  have hee_pos : 0 < ee := by
    exact sq_pos_of_pos ( norm_pos_iff.mpr ( sub_ne_zero.mpr ( by aesop ) ) )
  set θ := min 1 (dd / ee)
  have hθ_pos : 0 < θ := by
    exact lt_min zero_lt_one ( div_pos hdd_pos hee_pos )
  have hθ_le_1 : θ ≤ 1 := by
    exact min_le_left _ _
  have hθ_le_div : θ * ee ≤ dd := by
    exact le_trans ( mul_le_mul_of_nonneg_right ( min_le_right _ _ ) hee_pos.le ) ( by rw [ div_mul_cancel₀ _ hee_pos.ne' ] );
  -- Let $q := (1 - \theta) • p + \theta • y$. Then $q \in K$ by convexity.
  set q := (1 - θ) • p + θ • y
  have hq_mem : q ∈ K := by
    exact hK hp hy ( by linarith ) ( by linarith ) ( by linarith )
  generalize_proofs at *; (
  -- Now show `‖q‖ < ‖p‖`. Rewrite `q = p + θ • (y - p)` (since `(1-θ)•p + θ•y = p + θ•(y-p)`; use `smul_sub`, `sub_smul`, `one_smul`, `ring`-like `module`/`abel`).
  have hq_norm_sq : ‖q‖^2 = ‖p‖^2 - 2 * θ * dd + θ^2 * ee := by
    convert norm_add_sq_real ( p : V ) ( θ • ( y - p ) ) using 1 <;> ring!;
    · simp +decide [ sub_smul, smul_sub ] ; abel_nf;
    · simp +decide [ norm_smul, inner_smul_right, inner_sub_right ] ; ring!;
      rw [ sq_abs ]
  generalize_proofs at *; (
  exact ⟨ q, hq_mem, by nlinarith [ mul_pos hθ_pos hdd_pos, mul_pos hθ_pos hee_pos, norm_nonneg p, norm_nonneg q ] ⟩))

/-
**Support finset on the supporting hyperplane.**  If `p ≠ 0` lies in the
convex hull of a set `s` all of whose points satisfy the separation inequality
`‖p‖² ≤ ⟪p, x⟫`, then there is an affinely independent support finset `A ⊆ s`,
with `p ∈ convexHull A`, and (crucially) `A.card ≤ finrank ℝ V`, because every
point of `A` lies on the hyperplane `⟪p, ·⟫ = ‖p‖²`.
-/
theorem exists_support_finset {p : V} (hp : p ≠ 0) {s : Set V}
    (hpH : p ∈ convexHull ℝ s) (hsep : ∀ x ∈ s, ‖p‖ ^ 2 ≤ ⟪p, x⟫) :
    ∃ A : Finset V, ↑A ⊆ s ∧ p ∈ convexHull ℝ (A : Set V) ∧
      A.card ≤ Module.finrank ℝ V := by
  -- Let `A0 := Caratheodory.minCardFinsetOfMemConvexHull hpH`. It satisfies:
  obtain ⟨A0, hA0⟩ : ∃ A0 : Finset V, (A0 : Set V) ⊆ s ∧ AffineIndependent ℝ ((↑) : A0 → V) ∧ p ∈ convexHull ℝ (A0 : Set V) := by
    exact ⟨ _, Caratheodory.minCardFinsetOfMemConvexHull_subseteq hpH, Caratheodory.affineIndependent_minCardFinsetOfMemConvexHull hpH, Caratheodory.mem_minCardFinsetOfMemConvexHull hpH ⟩;
  obtain ⟨w, hw⟩ : ∃ w : V → ℝ, (∀ a ∈ A0, 0 ≤ w a) ∧ (∑ a ∈ A0, w a = 1) ∧ (∑ a ∈ A0, w a • a = p) ∧ (∀ a ∈ A0, w a ≠ 0 → ⟪p, a⟫ = ‖p‖^2) := by
    obtain ⟨w, hw⟩ : ∃ w : V → ℝ, (∀ a ∈ A0, 0 ≤ w a) ∧ (∑ a ∈ A0, w a = 1) ∧ (∑ a ∈ A0, w a • a = p) := by
      rw [ @Finset.convexHull_eq ] at hA0;
      obtain ⟨ w, hw₁, hw₂, hw₃ ⟩ := hA0.2.2; use w; simp_all +decide [ Finset.centerMass ] ;
    have h_eq : ∑ a ∈ A0, w a * (⟪p, a⟫ - ‖p‖^2) = 0 := by
      simp +decide [ mul_sub, ← Finset.sum_mul _ _ _, hw.2.1 ];
      have h_inner : ⟪p, ∑ a ∈ A0, w a • a⟫ = ∑ a ∈ A0, w a * ⟪p, a⟫ := by
        simp +decide [ inner_sum, inner_smul_right ];
      simp_all +decide;
    rw [ Finset.sum_eq_zero_iff_of_nonneg ] at h_eq;
    · exact ⟨ w, hw.1, hw.2.1, hw.2.2, fun a ha ha' => mul_left_cancel₀ ha' <| by linarith [ h_eq a ha ] ⟩;
    · exact fun x hx => mul_nonneg ( hw.1 x hx ) ( sub_nonneg.2 ( hsep x ( hA0.1 hx ) ) );
  refine' ⟨ A0.filter fun a => w a ≠ 0, _, _, _ ⟩;
  · exact fun x hx => hA0.1 <| Finset.mem_filter.mp hx |>.1;
  · rw [ mem_convexHull_iff ] at *;
    intro t ht ht_convex
    have h_convex_comb : p = ∑ a ∈ A0.filter (fun a => w a ≠ 0), w a • a := by
      rw [ ← hw.2.2.1, Finset.sum_filter_of_ne ] ; aesop;
    convert ht_convex.sum_mem _ _ _;
    · exact fun x hx => hw.1 x ( Finset.mem_filter.mp hx |>.1 );
    · rw [ ← hw.2.1, Finset.sum_filter_of_ne ] ; aesop;
    · exact fun x hx => ht <| by simpa using hx;
  · have h_card : ∀ a ∈ A0.filter (fun a => w a ≠ 0), ⟪p, a⟫ = ‖p‖^2 := by
      aesop;
    apply card_le_finrank_of_const_inner hp;
    convert hA0.2.1.mono _;
    exacts [ fun x hx => Finset.mem_filter.mp hx |>.1, h_card ]

/-
**Separation from the nearest point.**  If `p` is the point of a convex set
`K` nearest to the origin, then every point of `K` lies on the far side of the
supporting hyperplane through `p`: `‖p‖² ≤ ⟪p, w⟫`.
-/
omit [FiniteDimensional ℝ V] in
theorem sep_of_proj {K : Set V} (hK : Convex ℝ K) {p : V} (hp : p ∈ K)
    (heq : ‖(0 : V) - p‖ = ⨅ w : K, ‖(0 : V) - (w : V)‖) :
    ∀ w ∈ K, ‖p‖ ^ 2 ≤ ⟪p, w⟫ := by
  have h_inner : ∀ w ∈ K, ⟪(0 : V) - p, w - p⟫ ≤ 0 := by
    convert norm_eq_iInf_iff_real_inner_le_zero hK hp |>.1 _ using 1;
    exact heq;
  simp_all +decide [ inner_sub_right ]

/-
**Pigeonhole on colors.**  If a finite set `A` of size less than the number
of colors is contained in the range of a color assignment `f`, some color `j` is
avoidable: every element of `A` is realised by a color other than `j`.
-/
omit [NormedAddCommGroup V] [InnerProductSpace ℝ V] [FiniteDimensional ℝ V] in
theorem exists_color_avoiding [Fintype ι] {f : ι → V} {A : Finset V}
    (hAsub : (A : Set V) ⊆ Set.range f) (hlt : A.card < Fintype.card ι) :
    ∃ j : ι, ∀ a ∈ A, ∃ i, i ≠ j ∧ f i = a := by
  -- For each `a : ↥A`, `(a : V) ∈ (A : Set V)` so `(a:V) ∈ Set.range f` by `hAsub`; by `Set.mem_range` choose `φ a : ι` with `f (φ a) = a`.
  obtain ⟨φ, hφ⟩ : ∃ φ : A → ι, ∀ a : A, f (φ a) = a := by
    exact ⟨ fun a => Classical.choose ( hAsub a.2 ), fun a => Classical.choose_spec ( hAsub a.2 ) ⟩;
  by_contra! h;
  -- By assumption, for each color $j$, there exists an element $a_j \in A$ such that $f$ maps no other color to $a_j$.
  have h_unique : ∀ j : ι, ∃ a : A, φ a = j := by
    intro j
    obtain ⟨a, haA, ha⟩ := h j
    use ⟨a, haA⟩;
    exact Classical.not_not.1 fun hj => ha _ hj ( hφ _ );
  exact hlt.not_ge ( by simpa using Fintype.card_le_of_surjective φ h_unique )

/-
**A vertex on the near side exists.**  If the origin is in the convex hull of
`C` and `p ≠ 0`, then `C` has a point strictly on the origin side of the
supporting hyperplane of `p`: `⟪p, y⟫ < ‖p‖²`.
-/
omit [FiniteDimensional ℝ V] in
theorem exists_lt_inner_of_mem_convexHull_zero {p : V} (hp : p ≠ 0) {C : Finset V}
    (hC : (0 : V) ∈ convexHull ℝ (C : Set V)) :
    ∃ y ∈ C, ⟪p, y⟫ < ‖p‖ ^ 2 := by
  rw [ mem_convexHull_iff ] at hC;
  contrapose! hC;
  refine' ⟨ { x | ‖p‖ ^ 2 ≤ ⟪p, x⟫ }, _, _, _ ⟩ <;> simp_all +decide [ Set.subset_def ];
  exact ( convex_iff_forall_pos.mpr fun x hx y hy a b ha hb hab => by simpa [ hab.symm, inner_add_right, inner_smul_right ] using by nlinarith [ hx.out, hy.out ] )

/-- **Affine colorful Carathéodory for the origin.**  Given color classes
`C i` in a `d`-dimensional real inner product space, each with the origin in its
convex hull, and at least `d + 1` colors, there is a colorful transversal `t`
(one point per color) whose convex hull contains the origin. -/
theorem colorful_caratheodory_zero [Fintype ι] (C : ι → Finset V)
    (hcard : Module.finrank ℝ V + 1 ≤ Fintype.card ι)
    (hC : ∀ i, (0 : V) ∈ convexHull ℝ (C i : Set V)) :
    ∃ t : ι → V, (∀ i, t i ∈ C i) ∧ (0 : V) ∈ convexHull ℝ (Set.range t) := by
  classical
  -- Let `S` be the (finite, nonempty) set of all colorful transversals.
  set S := ∀ i, {x : V // x ∈ C i} with hS
  obtain ⟨s0, hs0⟩ :
      ∃ s0 : S, ∀ s : S,
        ⨅ w : (convexHull ℝ (Set.range (fun i => (s i : V)))), ‖(0 : V) - (w : V)‖ ≥
          ⨅ w : (convexHull ℝ (Set.range (fun i => (s0 i : V)))), ‖(0 : V) - (w : V)‖ := by
    convert Finite.exists_min _
    · infer_instance
    · exact ⟨fun i => ⟨Classical.choose (Finset.nonempty_of_ne_empty (by specialize hC i; aesop_cat)),
        Classical.choose_spec (Finset.nonempty_of_ne_empty (by specialize hC i; aesop_cat))⟩⟩
  obtain ⟨p, hpK, hpeq⟩ :
      ∃ p ∈ convexHull ℝ (Set.range (fun i => (s0 i : V))),
        ‖(0 : V) - p‖ =
          ⨅ w : (convexHull ℝ (Set.range (fun i => (s0 i : V)))), ‖(0 : V) - (w : V)‖ := by
    have h_complete : IsComplete (convexHull ℝ (Set.range (fun i => (s0 i : V)))) :=
      (Set.Finite.isCompact_convexHull (Set.toFinite _)).isComplete
    exact exists_norm_eq_iInf_of_complete_convex
      (Set.nonempty_of_mem (subset_convexHull ℝ _
        (Set.mem_range_self (Classical.choose (Finset.card_pos.mp (pos_of_gt hcard))))))
      h_complete (convex_convexHull ℝ _) 0
  by_cases hp : p = 0
  · exact ⟨_, fun i => (s0 i).2, hp ▸ hpK⟩
  · -- Separation gives an affinely independent support finset `A` on the supporting hyperplane.
    obtain ⟨A, hAsub, hpA, hAcard, hAsep⟩ :
        ∃ A : Finset V, ↑A ⊆ Set.range (fun i => (s0 i : V)) ∧ p ∈ convexHull ℝ (A : Set V) ∧
          A.card ≤ Module.finrank ℝ V ∧ ∀ x ∈ A, ‖p‖ ^ 2 ≤ ⟪p, x⟫ := by
      have hsep : ∀ x ∈ Set.range (fun i => (s0 i : V)), ‖p‖ ^ 2 ≤ ⟪p, x⟫ := by
        have hK := sep_of_proj (convex_convexHull ℝ _) hpK hpeq
        exact fun x hx => hK x (subset_convexHull ℝ _ hx)
      obtain ⟨A, hA1, hA2, hA3⟩ := exists_support_finset hp hpK hsep
      exact ⟨A, hA1, hA2, hA3, fun x hx => hsep x (hA1 hx)⟩
    -- Pigeonhole: some color `j` is avoidable.
    obtain ⟨j, hj⟩ : ∃ j : ι, ∀ a ∈ A, ∃ i, i ≠ j ∧ (s0 i : V) = a :=
      exists_color_avoiding hAsub (by omega)
    -- A near-side vertex `y` in color `j`.
    obtain ⟨y, hyC, hylt⟩ : ∃ y ∈ C j, ⟪p, y⟫ < ‖p‖ ^ 2 :=
      exists_lt_inner_of_mem_convexHull_zero hp (hC j)
    -- Replace color `j`'s vertex by `y`.
    set s' : S := Function.update s0 j ⟨y, hyC⟩ with hs'def
    have hs'j : (s' j : V) = y := by rw [hs'def, Function.update_self]
    have hs'ne : ∀ i, i ≠ j → (s' i : V) = (s0 i : V) := by
      intro i hi; rw [hs'def, Function.update_of_ne hi]
    -- `p` and `y` both lie in the new transversal's convex hull.
    have hpK' : p ∈ convexHull ℝ (Set.range (fun i => (s' i : V))) := by
      refine convexHull_mono ?_ hpA
      intro x hx
      obtain ⟨i, hij, rfl⟩ := hj x hx
      exact ⟨i, hs'ne i hij⟩
    have hyK' : y ∈ convexHull ℝ (Set.range (fun i => (s' i : V))) :=
      subset_convexHull ℝ _ ⟨j, hs'j⟩
    -- Descent: a strictly closer point exists, contradicting minimality.
    obtain ⟨q, hqK', hqlt⟩ :=
      exists_closer_of_inner_lt (convex_convexHull ℝ _) hpK' hyK' hp hylt
    have hD : ⨅ w : (convexHull ℝ (Set.range (fun i => (s' i : V)))), ‖(0 : V) - (w : V)‖ ≤ ‖q‖ := by
      refine le_trans (ciInf_le ⟨0, Set.forall_mem_range.2 fun w => norm_nonneg _⟩ ⟨q, hqK'⟩) ?_
      simp
    have hcontra := hs0 s'
    simp only [ge_iff_le] at hcontra
    have hpp : ‖p‖ = ⨅ w : (convexHull ℝ (Set.range (fun i => (s0 i : V)))), ‖(0 : V) - (w : V)‖ := by
      rw [← hpeq]; simp
    have hchain : ‖p‖ ≤ ‖q‖ := by
      rw [hpp]; exact le_trans hcontra hD
    linarith

/-
**Cone colorful Carathéodory theorem.**  Given at least `d + 1` color classes
in a `d`-dimensional real inner product space, each of which captures the origin
as a nontrivial conical combination, there is a colorful transversal whose own
conical cone captures the origin.
-/
theorem colorful_cone [Fintype ι] (C : ι → Finset V)
    (hcard : Module.finrank ℝ V + 1 ≤ Fintype.card ι)
    (hC : ∀ i, IsConicZero (C i) (id : V → V)) :
    ∃ t : ι → V, (∀ i, t i ∈ C i) ∧ IsConicZero (Finset.univ : Finset ι) t := by
  obtain ⟨t, ht⟩ : ∃ t : ι → V, (∀ i, t i ∈ C i) ∧ (0 : V) ∈ convexHull ℝ (Set.range t) := by
    apply colorful_caratheodory_zero;
    · exact hcard;
    · exact fun i => ( isConvexZero_id_iff_mem_convexHull ( C i ) ).mp ( ( isConicZero_iff_isConvexZero ( C i ) id ).mp ( hC i ) );
  exact ⟨ t, ht.1, ( isConicZero_iff_isConvexZero _ _ ) |>.2 ( isConvexZero_univ_of_mem_convexHull_range _ ht.2 ) ⟩

end Core

section Euclidean

/-- **Cone colorful Carathéodory in `ℝᵈ`.**  The concrete instance in the standard
`d`-dimensional Euclidean space with exactly `d + 1` colors.  Given `d + 1`
finite sets of vectors in `ℝᵈ`, each capturing the origin as a nontrivial conical
combination, there is a colorful transversal whose conical cone captures the
origin. -/
theorem colorful_cone_euclidean {d : ℕ}
    (C : Fin (d + 1) → Finset (EuclideanSpace ℝ (Fin d)))
    (hC : ∀ i, IsConicZero (C i) (id : EuclideanSpace ℝ (Fin d) → EuclideanSpace ℝ (Fin d))) :
    ∃ t : Fin (d + 1) → EuclideanSpace ℝ (Fin d), (∀ i, t i ∈ C i) ∧
      IsConicZero (Finset.univ : Finset (Fin (d + 1))) t := by
  refine colorful_cone C ?_ hC
  rw [finrank_euclideanSpace_fin, Fintype.card_fin]

/-- **Affine colorful Carathéodory in `ℝᵈ`.**  The convex-hull form of the
previous statement: `d + 1` finite sets in `ℝᵈ`, each with the origin in its
convex hull, admit a colorful transversal whose convex hull contains the
origin. -/
theorem colorful_caratheodory_zero_euclidean {d : ℕ}
    (C : Fin (d + 1) → Finset (EuclideanSpace ℝ (Fin d)))
    (hC : ∀ i, (0 : EuclideanSpace ℝ (Fin d)) ∈ convexHull ℝ (C i : Set (EuclideanSpace ℝ (Fin d)))) :
    ∃ t : Fin (d + 1) → EuclideanSpace ℝ (Fin d), (∀ i, t i ∈ C i) ∧
      (0 : EuclideanSpace ℝ (Fin d)) ∈ convexHull ℝ (Set.range t) := by
  refine colorful_caratheodory_zero C ?_ hC
  rw [finrank_euclideanSpace_fin, Fintype.card_fin]

end Euclidean

end ConeColorfulGeneral