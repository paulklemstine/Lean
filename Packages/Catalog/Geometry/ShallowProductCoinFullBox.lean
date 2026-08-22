/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.ShallowProductCoinAttainment

/-!
# Conjecture 3″ at fixed depth: product coins never reach the optimum off full boxes

`Catalog/Geometry/ShallowProductCoinRigidity.lean` proved a quantitative gap for a
resonance set that is not a box with respect to *the first* coordinate split.  This file
upgrades that to the intrinsic hypothesis: `R` fails to be a **full combinatorial box**
`∏ᵢ Sᵢ` inside `D^(n+1)`.

## Main results

* `splitAt` — the coordinate split `D^(n+1) ≃ D × D^n` at an arbitrary index `i`.
* `productCoin_depth_amplitude_sq_le_of_not_box_at` — the gap at any coordinate split.
* `isFullBox_of_forall_isBox` — a purely combinatorial structure theorem: if every single
  coordinate split of `R` is a box, then `R` is the product of all its coordinate
  projections.  The proof is a coordinate-by-coordinate crossover induction.
* `productCoin_depth_gap_of_not_isFullBox` — **the quantified Conjecture 3″ at fixed
  depth**: if `R ⊆ D^(n+1)` is not a full box then *every* depth-`(n+1)` product coin
  satisfies `‖A(ψ)‖² ≤ (1 - c)·|R|` with `c = 1/(9|R|²) > 0`, an explicit constant
  independent of the depth.
* `exists_optimal_depthCoin_of_isFullBox` and `depthCoin_optimum_iff_isFullBox` — the
  converse and hence the exact dichotomy at depth `n`.
-/

namespace Catalog.Geometry.ShallowProductCoin

open Finset

section FullBox

variable {D : Type*} [Fintype D] [DecidableEq D]

/-- The state-space splitting `D^(n+1) ≃ D × D^n` peeling off the coordinate `i`. -/
def splitAt {n : ℕ} (i : Fin (n + 1)) : (Fin (n + 1) → D) ≃ D × (Fin n → D) :=
  (Fin.insertNthEquiv (fun _ => D) i).symm

omit [Fintype D] [DecidableEq D] in
@[simp] lemma splitAt_apply {n : ℕ} (i : Fin (n + 1)) (x : Fin (n + 1) → D) :
    splitAt i x = (x i, fun j => x (i.succAbove j)) := rfl

omit [Fintype D] [DecidableEq D] in
@[simp] lemma splitAt_symm_apply {n : ℕ} (i : Fin (n + 1)) (a : D) (b : Fin n → D) :
    (splitAt i).symm (a, b) = i.insertNth a b := rfl

/-- The depth-`n` rigidity gap, taken at an arbitrary coordinate split. -/
theorem productCoin_depth_amplitude_sq_le_of_not_box_at {n : ℕ} (i : Fin (n + 1))
    (R : Finset (Fin (n + 1) → D)) (f : Fin (n + 1) → D → ℝ)
    (hf : ∀ k, ∑ d, f k d ^ 2 = 1)
    (hbox : ¬ IsBox (R.map (splitAt i).toEmbedding)) :
    resonanceAmplitude R (depthCoin f) ^ 2 ≤ (R.card : ℝ) - 1 / (9 * R.card) := by
  set R' := R.map (splitAt i).toEmbedding with hR'
  set g : (Fin n → D) → ℝ := depthCoin (fun j => f (i.succAbove j)) with hg
  have hgu : ∑ z : Fin n → D, g z ^ 2 = 1 :=
    depthCoin_isUnitCoin (fun j => f (i.succAbove j)) (fun j => hf (i.succAbove j))
  have hamp : resonanceAmplitude R' (prodCoin (f i) g)
      = resonanceAmplitude R (depthCoin f) := by
    unfold resonanceAmplitude
    rw [hR', Finset.sum_map]
    refine Finset.sum_congr rfl fun x _ => ?_
    simp only [Equiv.coe_toEmbedding, splitAt_apply, prodCoin, hg, depthCoin]
    rw [Fin.prod_univ_succAbove (fun k => f k (x k)) i]
  have hcard : R'.card = R.card := by rw [hR', Finset.card_map]
  have hmain := productCoin_amplitude_sq_le_of_not_box R' (f i) g (hf i) hgu hbox
  rw [hamp, hcard] at hmain
  exact hmain

/-- `R ⊆ D^n` is a *full combinatorial box* when it is the product of its `n` coordinate
projections. -/
def IsFullBox {n : ℕ} (R : Finset (Fin n → D)) : Prop :=
  R = Fintype.piFinset (fun i => R.image (fun x => x i))

omit [Fintype D] in
lemma subset_piFinset_image {n : ℕ} (R : Finset (Fin n → D)) :
    R ⊆ Fintype.piFinset (fun i => R.image (fun x => x i)) := by
  intro x hx
  rw [Fintype.mem_piFinset]
  exact fun i => Finset.mem_image_of_mem _ hx

omit [Fintype D] [DecidableEq D] in
/-- Being a box at the coordinate split `i` is precisely closure under *crossover* at the
coordinate `i`: taking the `i`-th entry from one member and all the others from another. -/
lemma crossover_of_isBox {n : ℕ} (i : Fin (n + 1)) (R : Finset (Fin (n + 1) → D))
    (h : IsBox (R.map (splitAt i).toEmbedding)) {x y : Fin (n + 1) → D}
    (hx : x ∈ R) (hy : y ∈ R) :
    i.insertNth (x i) (fun j => y (i.succAbove j)) ∈ R := by
  have hx' : (x i, fun j => x (i.succAbove j)) ∈ R.map (splitAt i).toEmbedding :=
    Finset.mem_map.mpr ⟨x, hx, rfl⟩
  have hy' : (y i, fun j => y (i.succAbove j)) ∈ R.map (splitAt i).toEmbedding :=
    Finset.mem_map.mpr ⟨y, hy, rfl⟩
  obtain ⟨w, hw, hwe⟩ := Finset.mem_map.mp (h _ _ _ _ hx' hy')
  rw [Equiv.coe_toEmbedding] at hwe
  have hw2 : w = i.insertNth (x i) (fun j => y (i.succAbove j)) := by
    have hc := congrArg (splitAt i).symm hwe
    rwa [Equiv.symm_apply_apply, splitAt_symm_apply] at hc
  rwa [← hw2]

omit [Fintype D] in
/-- **Structure theorem.**  If every single-coordinate split of `R` is a combinatorial
box, then `R` is the full product of its coordinate projections. -/
theorem isFullBox_of_forall_isBox {n : ℕ} (R : Finset (Fin (n + 1) → D))
    (h : ∀ i : Fin (n + 1), IsBox (R.map (splitAt i).toEmbedding)) : IsFullBox R := by
  unfold IsFullBox
  refine Finset.Subset.antisymm (subset_piFinset_image R) ?_
  intro z hz
  rw [Fintype.mem_piFinset] at hz
  -- build a member of `R` agreeing with `z` on the first `k` coordinates
  have key : ∀ k : ℕ, ∃ r ∈ R, ∀ j : Fin (n + 1), (j : ℕ) < k → r j = z j := by
    intro k
    induction k with
    | zero =>
      obtain ⟨x, hx, _⟩ := Finset.mem_image.mp (hz 0)
      exact ⟨x, hx, fun j hj => absurd hj (by omega)⟩
    | succ k ih =>
      obtain ⟨r, hr, hrk⟩ := ih
      by_cases hk : k < n + 1
      · obtain ⟨w, hw, hwi⟩ := Finset.mem_image.mp (hz ⟨k, hk⟩)
        refine ⟨(⟨k, hk⟩ : Fin (n + 1)).insertNth (w ⟨k, hk⟩)
            (fun j => r ((⟨k, hk⟩ : Fin (n + 1)).succAbove j)),
          crossover_of_isBox _ R (h _) hw hr, ?_⟩
        intro j hj
        by_cases hji : j = (⟨k, hk⟩ : Fin (n + 1))
        · subst hji
          rw [Fin.insertNth_apply_same]
          exact hwi
        · have hjk : (j : ℕ) < k := by
            have hne : (j : ℕ) ≠ k := fun hcon => hji (Fin.ext hcon)
            omega
          obtain ⟨j', hj'⟩ := Fin.exists_succAbove_eq hji
          have hrj := hrk j hjk
          rw [← hj'] at hrj ⊢
          rw [Fin.insertNth_apply_succAbove]
          exact hrj
      · exact ⟨r, hr, fun j _ => hrk j (by have := j.isLt; omega)⟩
  obtain ⟨r, hr, hrall⟩ := key (n + 1)
  have hrz : r = z := funext fun j => hrall j j.isLt
  rwa [← hrz]

omit [Fintype D] in
/-- If `R` is not a full box, some coordinate split witnesses it. -/
theorem exists_coord_not_box_of_not_isFullBox {n : ℕ} (R : Finset (Fin (n + 1) → D))
    (hR : ¬ IsFullBox R) : ∃ i, ¬ IsBox (R.map (splitAt i).toEmbedding) := by
  by_contra hc
  push_neg at hc
  exact hR (isFullBox_of_forall_isBox R hc)

/-- **Quantified Conjecture 3″ at fixed depth.**  If the resonance set `R ⊆ D^(n+1)` is
not a full combinatorial box then every depth-`(n+1)` product coin satisfies
`‖A(ψ)‖² ≤ (1 - c)·|R|` with the explicit constant `c = 1/(9|R|²) > 0`, uniform in `n`. -/
theorem productCoin_depth_gap_of_not_isFullBox {n : ℕ} (R : Finset (Fin (n + 1) → D))
    (f : Fin (n + 1) → D → ℝ) (hf : ∀ k, ∑ d, f k d ^ 2 = 1) (hfull : ¬ IsFullBox R) :
    resonanceAmplitude R (depthCoin f) ^ 2
      ≤ (1 - 1 / (9 * (R.card : ℝ) ^ 2)) * (R.card : ℝ) := by
  obtain ⟨i, hi⟩ := exists_coord_not_box_of_not_isFullBox R hfull
  have hmain := productCoin_depth_amplitude_sq_le_of_not_box_at i R f hf hi
  have hR2 : (2:ℝ) ≤ (R.card : ℝ) := by
    have h2 := two_le_card_of_not_box hi
    rw [Finset.card_map] at h2
    exact_mod_cast h2
  have heq : (1 - 1 / (9 * (R.card : ℝ) ^ 2)) * (R.card : ℝ)
      = (R.card : ℝ) - 1 / (9 * (R.card : ℝ)) := by
    have hne : (R.card : ℝ) ≠ 0 := by linarith
    field_simp
  linarith [heq ▸ hmain]

/-! ## Converse at depth `n`: full boxes are optimal -/

/-- **Converse at depth `n`.**  A nonempty full combinatorial box admits a depth-`(n+1)`
product coin attaining the Cauchy–Schwarz optimum exactly. -/
theorem exists_optimal_depthCoin_of_isFullBox {n : ℕ} (R : Finset (Fin (n + 1) → D))
    (hR : R.Nonempty) (hfull : IsFullBox R) :
    ∃ f : Fin (n + 1) → D → ℝ, (∀ k, ∑ d, f k d ^ 2 = 1) ∧
      resonanceAmplitude R (depthCoin f) ^ 2 = (R.card : ℝ) := by
  obtain ⟨S, hS⟩ : ∃ S : Fin (n + 1) → Finset D, S = fun i => R.image (fun x => x i) :=
    ⟨_, rfl⟩
  have hfull' : R = Fintype.piFinset S := by rw [hS]; exact hfull
  have hSne : ∀ i, (S i).Nonempty := by
    intro i; rw [hS]; exact hR.image _
  refine ⟨fun i d => if d ∈ S i then 1 / Real.sqrt (S i).card else 0,
    fun k => sum_sq_normalised_indicator (S k) (hSne k), ?_⟩
  have hamp : resonanceAmplitude R
      (depthCoin (fun i d => if d ∈ S i then 1 / Real.sqrt (S i).card else 0))
      = ∏ i, Real.sqrt (S i).card := by
    simp only [resonanceAmplitude, depthCoin]
    conv_lhs => rw [hfull']
    rw [← Finset.prod_univ_sum S
      (fun i d => if d ∈ S i then 1 / Real.sqrt (S i).card else 0)]
    exact Finset.prod_congr rfl fun i _ => sum_normalised_indicator (S i) (hSne i)
  rw [hamp, ← Finset.prod_pow]
  have hpt : ∀ i : Fin (n + 1), Real.sqrt ((S i).card : ℝ) ^ 2 = ((S i).card : ℝ) :=
    fun i => Real.sq_sqrt (Nat.cast_nonneg _)
  simp only [hpt]
  conv_rhs => rw [hfull']
  rw [Fintype.card_piFinset]
  push_cast
  ring

/-- **The exact dichotomy at depth `n`.**  For a nonempty resonance set in `D^(n+1)`,
some depth-`(n+1)` product coin attains the Cauchy–Schwarz optimum if and only if the set
is a full combinatorial box. -/
theorem depthCoin_optimum_iff_isFullBox {n : ℕ} (R : Finset (Fin (n + 1) → D))
    (hR : R.Nonempty) :
    (∃ f : Fin (n + 1) → D → ℝ, (∀ k, ∑ d, f k d ^ 2 = 1) ∧
      resonanceAmplitude R (depthCoin f) ^ 2 = (R.card : ℝ)) ↔ IsFullBox R := by
  constructor
  · rintro ⟨f, hf, hopt⟩
    by_contra hfull
    have hg := productCoin_depth_gap_of_not_isFullBox R f hf hfull
    rw [hopt] at hg
    obtain ⟨i, hi⟩ := exists_coord_not_box_of_not_isFullBox R hfull
    have hR2 : (2:ℝ) ≤ (R.card : ℝ) := by
      have h2 := two_le_card_of_not_box hi
      rw [Finset.card_map] at h2
      exact_mod_cast h2
    have hc : 0 < 1 / (9 * (R.card : ℝ) ^ 2) := by positivity
    nlinarith
  · exact exists_optimal_depthCoin_of_isFullBox R hR

end FullBox

end Catalog.Geometry.ShallowProductCoin