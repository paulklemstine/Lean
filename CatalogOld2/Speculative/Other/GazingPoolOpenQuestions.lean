/-! # CatalogBuild.Speculative.Other.GazingPoolOpenQuestions

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 20
-/

import Mathlib

noncomputable section

/-- A **Gazing Pool** on a type `W` (the "World"). -/
structure GazingPool' (W : Type*) where
  S : Type*
  reflect : W → W
  reflect_invol : ∀ w, reflect (reflect w) = w
  shadow : W → S
  reconstruct : S → W
  shadow_surj : Surjective shadow
  shadow_reconstruct : ∀ s, shadow (reconstruct s) = s

namespace GazingPool'

variable {W : Type*} (P : GazingPool' W)


/-- The **retract**: image of `reconstruct ∘ shadow`. -/
def retract : Set W := {w | P.reconstruct (P.shadow w) = w}


/-- A reflection is **conscious-admitting** for given shadow/reconstruct. -/
def IsConsciousAdmitting {W S : Type*} (shadow : W → S) (reconstruct : S → W)
    (reflect : W → W) : Prop :=
  ∃ w : W, reconstruct (shadow (reflect w)) = w


/-- **Spectrum Theorem**: A reflection is conscious-admitting iff some
retract element is mapped into its own shadow fiber. -/
theorem spectrum_characterization {W S : Type*} (shadow : W → S) (reconstruct : S → W)
    (h_section : ∀ s, shadow (reconstruct s) = s) (reflect : W → W) :
    IsConsciousAdmitting shadow reconstruct reflect ↔
    ∃ w, reconstruct (shadow w) = w ∧ shadow (reflect w) = shadow w := by
  constructor
  · rintro ⟨w, hw⟩
    have hsf : shadow w = shadow (reflect w) := by
      conv_lhs => rw [← hw]
      exact h_section _
    exact ⟨w, by rw [hsf]; exact hw, hsf.symm⟩
  · rintro ⟨w, hw_ret, hw_shadow⟩
    exact ⟨w, by rw [hw_shadow, hw_ret]⟩


/-- The identity is always conscious-admitting (when S is nonempty). -/
theorem id_conscious_admitting {W S : Type*} [Nonempty S]
    (shadow : W → S) (reconstruct : S → W)
    (h_section : ∀ s, shadow (reconstruct s) = s) :
    IsConsciousAdmitting shadow reconstruct id := by
  obtain ⟨s⟩ := ‹Nonempty S›
  exact ⟨reconstruct s, by simp [h_section]⟩


/-- **Symmetric reflections are conscious-admitting** (when S is nonempty). -/
theorem symmetric_conscious_admitting {W S : Type*} [Nonempty S]
    (shadow : W → S) (reconstruct : S → W)
    (h_section : ∀ s, shadow (reconstruct s) = s)
    (reflect : W → W) (h_symm : ∀ w, shadow (reflect w) = shadow w) :
    IsConsciousAdmitting shadow reconstruct reflect := by
  obtain ⟨s⟩ := ‹Nonempty S›
  exact ⟨reconstruct s, by rw [h_symm, h_section]⟩


theorem knaster_tarski_consciousness {W : Type*} [CompleteLattice W]
    (f : W → W) (hf : Monotone f) :
    ∃ w : W, f w = w := by
  -- By the Knaster-Tarski theorem, a monotone function on a complete lattice has a fixed point.
  have h_fixed_point : ∃ w : W, f w = w := by
    have h_lfp : ∃ w : W, f w ≤ w ∧ ∀ y : W, f y ≤ y → w ≤ y := by
      refine' ⟨ sInf { y | f y ≤ y }, _, _ ⟩;
      · exact le_sInf fun y hy => hf ( sInf_le hy ) |> le_trans <| hy;
      · exact fun y hy => sInf_le hy
    exact ⟨ h_lfp.choose, le_antisymm h_lfp.choose_spec.1 ( h_lfp.choose_spec.2 ( f h_lfp.choose ) ( hf h_lfp.choose_spec.1 ) ) ⟩;
  exact h_fixed_point


theorem fixed_points_nonempty {W : Type*} [CompleteLattice W]
    (f : W → W) (hf : Monotone f) :
    {w : W | f w = w}.Nonempty := by
  exact ⟨ _, knaster_tarski_lfp f hf |> Classical.choose_spec |> And.left ⟩


/-- A **stochastic matrix**: nonneg entries with row sums = 1. -/
structure StochMatrix (n : ℕ) where
  val : Fin n → Fin n → ℝ
  nonneg : ∀ i j, 0 ≤ val i j
  row_sum : ∀ i, ∑ j, val i j = 1


/-- Apply a stochastic matrix to a distribution: (πM)_j = Σ_i π_i M_{ij}. -/
def StochMatrix.apply {n : ℕ} (M : StochMatrix n) (π : ProbDist n) : Fin n → ℝ :=
  fun j => ∑ i, π.val i * M.val i j


/-- A distribution is **stationary** (probabilistically conscious). -/
def IsStationary {n : ℕ} (M : StochMatrix n) (π : ProbDist n) : Prop :=
  ∀ j, M.apply π j = π.val j


theorem doubly_stochastic_uniform_stationary {n : ℕ} (hn : 0 < n)
    (M : StochMatrix n)
    (h_col : ∀ j, ∑ i, M.val i j = 1) :
    IsStationary M (uniformDist n hn) := by
  intro j
  simp [IsStationary, uniformDist]
  simp +decide [StochMatrix.apply]
  rw [← Finset.mul_sum _ _ _, h_col, mul_one]


theorem fixed_points_closed {X : Type*} [TopologicalSpace X] [T2Space X]
    (f : X → X) (hf : Continuous f) :
    IsClosed {x | f x = x} := by
  exact isClosed_eq hf continuous_id


/-- **Conscious Set is Closed**: For a continuous gaze on a Hausdorff space,
the set of conscious observers is closed. -/
theorem conscious_set_is_closed {W : Type*} [TopologicalSpace W] [T2Space W]
    (gaze : W → W) (hgaze : Continuous gaze) :
    IsClosed {w | gaze w = w} :=
  fixed_points_closed gaze hgaze


/-- The finset of all conscious observers (fixed points of gaze). -/
def consciousFinset {W : Type*} [Fintype W] [DecidableEq W] (gaze : W → W) : Finset W :=
  Finset.univ.filter (fun w => gaze w = w)


/-- A conscious observer exists iff the conscious finset is nonempty. -/
theorem conscious_iff_finset_nonempty {W : Type*} [Fintype W] [DecidableEq W]
    (gaze : W → W) :
    (∃ w, gaze w = w) ↔ (consciousFinset gaze).Nonempty := by
  simp [consciousFinset, Finset.Nonempty]


theorem periodic_orbit_from_any {X : Type*} [Fintype X] [DecidableEq X]
    (f : X → X) (x : X) :
    ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card X ∧ f^[i] x = f^[j] x := by
  by_contra h;
  exact absurd ( Finset.card_le_univ ( Finset.image ( fun i => f^[i] x ) ( Finset.Iic ( Fintype.card X ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.mp fun hi' => h ⟨ j, i, hi', by aesop, hij.symm ⟩ ) ( not_lt.mp fun hj' => h ⟨ i, j, hj', by aesop, hij ⟩ ) ] ; simpa )


theorem finite_endo_periodic {X : Type*} [Fintype X] [Nonempty X]
    (f : X → X) : ∃ x : X, ∃ k : ℕ, 0 < k ∧ f^[k] x = x := by
  -- By the pigeonhole principle, since $X$ is finite and nonempty, the sequence $x, f(x), f^2(x), \ldots$ must eventually repeat.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ f^[i] (Classical.arbitrary X) = f^[j] (Classical.arbitrary X) := by
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ hi hij.symm ) ( not_lt.1 fun hj => h _ _ hj hij ) ) ) ( Set.not_infinite.2 <| Set.toFinite _ );
  refine' ⟨ f^[i] ( Classical.arbitrary X ), j - i, tsub_pos_of_lt hij, _ ⟩;
  rw [ ← Function.iterate_add_apply, Nat.sub_add_cancel hij.le, h_eq ]


/-- **The Gazing Pool Conjecture (THEOREM)**: Every gazing pool on a finite
nonempty world has a periodic point of the gaze operation. -/
theorem gazing_pool_conjecture {W : Type*} [Fintype W] [Nonempty W]
    (P : GazingPool' W) :
    ∃ w : W, ∃ k : ℕ, 0 < k ∧ P.gaze^[k] w = w :=
  finite_endo_periodic P.gaze


theorem gazing_pool_conjecture_bounded {W : Type*} [Fintype W] [DecidableEq W] [Nonempty W]
    (P : GazingPool' W) :
    ∃ w : W, ∃ k : ℕ, 0 < k ∧ k ≤ Fintype.card W ∧ P.gaze^[k] w = w := by
  -- By the pigeonhole principle, there exist integers $i$ and $j$ such that $0 \leq i < j \leq n$ and $P.gaze^i(w) = P.gaze^j(w)$.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, 0 ≤ i ∧ i < j ∧ j ≤ Fintype.card W ∧ P.gaze^[i] (Classical.arbitrary W) = P.gaze^[j] (Classical.arbitrary W) := by
    have := periodic_orbit_from_any P.gaze ( Classical.arbitrary W );
    aesop;
  refine' ⟨ P.gaze^[i] ( Classical.arbitrary W ), j - i, _, _, _ ⟩ <;> try omega;
  rw [ ← Function.iterate_add_apply, Nat.sub_add_cancel h_eq.1.le, h_eq.2.2 ]


end
