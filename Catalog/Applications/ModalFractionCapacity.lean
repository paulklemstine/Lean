import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialResolution
import MachineLearning.ZeroFitDialEnvelope
import Cryptography.BalancedBKeyFixedWeight

/-!
# Universal law-change capacity: how far can a draw-law swap move the tie ceiling?

## Research context

`Cryptography.BalancedBKeyFixedWeight.law_change_capacity` records that swapping the *uniform*
draw law for the *balanced* (fixed-weight) one moves the Spearman tie ceiling by less than
`0.07` in `ρ`.  The mission conjecture (a "universal tie budget") was:

> two draw laws whose modal fractions `a`, `a'` differ by `δ` have ceilings within
> `δ + O(1/n)` of each other.

This file settles that conjecture.  The verdict is **negative, and quantitatively so**:

* the modal fraction pins the ceiling only to a *window*, never to a point
  (`mass_fraction_floor`, `modal_fraction_cap`, `cubeFrac_window`);
* the window has width up to `4/27` in `ρ²`, and two-block profiles realise both of its
  endpoints (`window_sharp_upper`, `window_sharp_lower`);
* consequently there are profiles with **equal** modal fractions whose ceilings differ by more
  than `1/20` in `ρ`, *uniformly in `n`* (`equal_modal_ceiling_gap`), which kills the
  conjecture and every `O(1/n)` repair of it (`no_modal_lipschitz`,
  `no_modal_lipschitz_with_rate`);
* the *sharp* universal budget is not `|a - a'|` but `|a - a'| + C` with
  `1/2 < C ≤ 109/200 = 0.545` (`spearman_modal_budget`, `budget_constant_gt_half`,
  `budget_constant_bracket`).

The correct Lipschitz law replaces the modal fraction by the **cube-mass fraction**
`c(L) = Σ m³ / n³`: there `|ρ² - ρ'²| ≤ |c - c'| + O(1/n²)` (`cubeFrac_lipschitz`), and the
modal fraction only controls `c` inside `[a³, a²]`.  This is the precise sense in which
"law-swap comparisons need the full profile".

## Main results

* `mass_fraction_floor` : `1 - a² ≤ ρ²` (mass-fraction floor).
* `modal_fraction_cap` : `ρ² ≤ 1 - a³ + 1/(n²-1)` (dominant-block upper law, fractional form).
* `cubeFrac_window`, `modal_window_width` : `a³ ≤ c ≤ a²` and `a² - a³ ≤ 4/27`.
* `cubeFrac_lipschitz` : the corrected Lipschitz law, in the cube-mass fraction.
* `spearman_modal_budget` : `|ρ - ρ'| ≤ |a - a'| + 109/200 + O(1/n²) + O(1/n'²)`.
* `equal_modal_ceiling_gap`, `no_modal_lipschitz`, `no_modal_lipschitz_with_rate` :
  refutation of the conjectured budget.
* `dominant_tied_excess`, `budget_constant_gt_half`, `budget_constant_bracket` : the optimal
  additive constant lies in `(1/2, 109/200]`.
* `catalog_law_swap_zero_modal_gap` : the recorded balanced-versus-uniform swap of the catalog
  has modal-fraction gap exactly `0`, so its recorded `< 0.07` movement is *entirely* a
  full-profile effect — the conjectured budget would have predicted `0`.
-/

open Catalog.Novelty.ZeroFitDialU64
open Catalog.MachineLearning.ZeroFitDialResolution
open Catalog.MachineLearning.ZeroFitDialEnvelope
open Catalog.Cryptography.BalancedBKeyFixedWeight

namespace Catalog.Applications.ModalFractionCapacity

/-! ## 1. The modal block and the modal fraction -/

/-- The largest tie class of a profile. -/
def modalBlock (L : List ℕ) : ℕ := L.foldr max 0

@[simp] lemma modalBlock_nil : modalBlock [] = 0 := rfl

@[simp] lemma modalBlock_cons (a : ℕ) (L : List ℕ) :
    modalBlock (a :: L) = max a (modalBlock L) := rfl

lemma le_modalBlock {L : List ℕ} {m : ℕ} (hm : m ∈ L) : m ≤ modalBlock L := by
  induction L with
  | nil => simp at hm
  | cons a L ih =>
      rcases List.mem_cons.1 hm with rfl | h
      · simp
      · have := ih h
        simp only [modalBlock_cons]
        omega

lemma modalBlock_le_of_forall {L : List ℕ} {M : ℕ} (h : ∀ m ∈ L, m ≤ M) : modalBlock L ≤ M := by
  induction L with
  | nil => simp
  | cons a L ih =>
      have h1 : a ≤ M := h a (List.mem_cons_self ..)
      have h2 : modalBlock L ≤ M := ih (fun m hm => h m (List.mem_cons_of_mem _ hm))
      simp only [modalBlock_cons]
      omega

lemma modalBlock_mem {L : List ℕ} (h : L ≠ []) : modalBlock L ∈ L := by
  induction L with
  | nil => exact absurd rfl h
  | cons a L ih =>
      rcases eq_or_ne L [] with rfl | hL
      · simp
      · have hmem := ih hL
        have := le_modalBlock (L := L) hmem
        simp only [modalBlock_cons]
        rcases le_total a (modalBlock L) with hle | hle
        · rw [max_eq_right hle]
          exact List.mem_cons_of_mem _ hmem
        · rw [max_eq_left hle]
          exact List.mem_cons_self ..

/-- If `M` occurs in `L` and dominates `L`, it *is* the modal block. -/
lemma modalBlock_eq {L : List ℕ} {M : ℕ} (hmem : M ∈ L) (hle : ∀ m ∈ L, m ≤ M) :
    modalBlock L = M :=
  le_antisymm (modalBlock_le_of_forall hle) (le_modalBlock hmem)

/-- The **modal fraction** of a tie profile: the share of the sample carried by its largest
tie class. -/
def modalFrac (L : List ℕ) : ℚ := (modalBlock L : ℚ) / (L.sum : ℚ)

lemma sum_pos_of_two_le {L : List ℕ} (h : 2 ≤ L.sum) : (0 : ℚ) < (L.sum : ℚ) := by
  have : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  linarith

lemma modalBlock_le_sum (L : List ℕ) : modalBlock L ≤ L.sum := by
  rcases eq_or_ne L [] with rfl | hL
  · simp
  · exact le_sum_of_mem (modalBlock_mem hL)

lemma modalFrac_nonneg (L : List ℕ) : 0 ≤ modalFrac L := by
  unfold modalFrac
  positivity

lemma modalFrac_le_one {L : List ℕ} (h : 2 ≤ L.sum) : modalFrac L ≤ 1 := by
  have hpos := sum_pos_of_two_le h
  have hle : ((modalBlock L : ℕ) : ℚ) ≤ (L.sum : ℚ) := by
    exact_mod_cast modalBlock_le_sum L
  rw [modalFrac, div_le_one hpos]
  exact hle

/-! ## 2. The ceiling as a cube-mass ratio -/

/-- **Cube-ratio form of the tie ceiling.**  `ρ² = (n³ - Σ mⱼ³)/(n³ - n)`. -/
theorem spearmanSq_eq_cube_ratio (L : List ℕ) (h : 2 ≤ L.sum) :
    spearmanSq L = ((L.sum : ℚ) ^ 3 - cubeSum L) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  rw [spearmanSq_eq L h, twelve_tieCorr_eq L, eq_div_iff (ne_of_gt hden), sub_mul, one_mul,
    div_mul_cancel₀ _ (ne_of_gt hden)]
  ring

/-- Every block is at most `M`, so the cube sum is at most `M²n`. -/
lemma cubeSum_le_sq_mul_sum {L : List ℕ} {M : ℕ} (hle : ∀ m ∈ L, m ≤ M) :
    cubeSum L ≤ (M : ℚ) ^ 2 * (L.sum : ℚ) := by
  induction L with
  | nil => simp [cubeSum]
  | cons a L ih =>
      have ha : a ≤ M := hle a (List.mem_cons_self ..)
      have haQ : (a : ℚ) ≤ (M : ℚ) := by exact_mod_cast ha
      have ha0 : (0 : ℚ) ≤ (a : ℚ) := by positivity
      have hrest := ih (fun m hm => hle m (List.mem_cons_of_mem _ hm))
      have hasq : (a : ℚ) ^ 2 ≤ (M : ℚ) ^ 2 := by nlinarith
      have hterm : (a : ℚ) ^ 3 ≤ (M : ℚ) ^ 2 * (a : ℚ) := by nlinarith
      have hsum : (((a :: L).sum : ℕ) : ℚ) = (a : ℚ) + ((L.sum : ℕ) : ℚ) := by
        push_cast [List.sum_cons]; ring
      rw [cubeSum, hsum]
      nlinarith

/-- The cube sum dominates the cube of any single block. -/
lemma cube_le_cubeSum {L : List ℕ} {M : ℕ} (hM : M ∈ L) : (M : ℚ) ^ 3 ≤ cubeSum L := by
  induction L with
  | nil => simp at hM
  | cons a L ih =>
      rcases List.mem_cons.1 hM with rfl | h
      · have := cubeSum_nonneg L
        rw [cubeSum]
        linarith
      · have h1 := ih h
        have h2 : (0 : ℚ) ≤ (a : ℚ) ^ 3 := by positivity
        rw [cubeSum]
        linarith

/-! ## 3. The two fractional laws: floor and cap -/

/-- **Mass-fraction floor.**  A profile whose largest tie class carries a fraction `a` of the
sample has ceiling at least `1 - a²`.  (No hypothesis on the rest of the profile.) -/
theorem mass_fraction_floor (L : List ℕ) (h : 2 ≤ L.sum) :
    1 - modalFrac L ^ 2 ≤ spearmanSq L := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hpos : (0 : ℚ) < (L.sum : ℚ) := by linarith
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  have hMn0 : ((modalBlock L : ℕ) : ℚ) ≤ ((L.sum : ℕ) : ℚ) := by
    exact_mod_cast modalBlock_le_sum L
  set n : ℚ := (L.sum : ℚ) with hnval
  set M : ℚ := ((modalBlock L : ℕ) : ℚ) with hMval
  have hM0 : (0 : ℚ) ≤ M := by positivity
  have hMn : M ≤ n := hMn0
  have hC : cubeSum L ≤ M ^ 2 * n := cubeSum_le_sq_mul_sum (fun m hm => le_modalBlock hm)
  rw [spearmanSq_eq_cube_ratio L h, modalFrac, ← hnval, ← hMval, le_div_iff₀ hden]
  have hexp : (1 - (M / n) ^ 2) * (n ^ 3 - n) = n ^ 3 - n - M ^ 2 * n + M ^ 2 / n := by
    field_simp
    ring
  have hMdiv : M ^ 2 / n ≤ n := by
    rw [div_le_iff₀ hpos]
    nlinarith
  rw [hexp]
  linarith

/-- **Dominant-block upper law, fractional form.**  The ceiling of a profile with modal
fraction `a` is at most `1 - a³ + 1/(n²-1)`. -/
theorem modal_fraction_cap (L : List ℕ) (h : 2 ≤ L.sum) :
    spearmanSq L ≤ 1 - modalFrac L ^ 3 + 1 / ((L.sum : ℚ) ^ 2 - 1) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hpos : (0 : ℚ) < (L.sum : ℚ) := by linarith
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  have hMn0 : ((modalBlock L : ℕ) : ℚ) ≤ ((L.sum : ℕ) : ℚ) := by
    exact_mod_cast modalBlock_le_sum L
  set n : ℚ := (L.sum : ℚ) with hnval
  set M : ℚ := ((modalBlock L : ℕ) : ℚ) with hMval
  have hM0 : (0 : ℚ) ≤ M := by positivity
  have hMn : M ≤ n := hMn0
  have hne : L ≠ [] := by
    rintro rfl
    simp at h
  have hC : M ^ 3 ≤ cubeSum L := cube_le_cubeSum (modalBlock_mem hne)
  have hsq : (0 : ℚ) < n ^ 2 - 1 := by nlinarith
  have hstep : (n ^ 3 - cubeSum L) / (n ^ 3 - n) ≤ (n ^ 3 - M ^ 3) / (n ^ 3 - n) := by
    gcongr
  have hkey : (n ^ 3 - M ^ 3) / (n ^ 3 - n) ≤ 1 - (M / n) ^ 3 + 1 / (n ^ 2 - 1) := by
    rw [div_le_iff₀ hden]
    have hexp : (1 - (M / n) ^ 3 + 1 / (n ^ 2 - 1)) * (n ^ 3 - n)
        = n ^ 3 - n - M ^ 3 + M ^ 3 / n ^ 2 + n := by
      field_simp
      ring
    rw [hexp]
    have : (0 : ℚ) ≤ M ^ 3 / n ^ 2 := by positivity
    linarith
  rw [spearmanSq_eq_cube_ratio L h, modalFrac, ← hnval, ← hMval]
  linarith

/-! ## 4. The corrected law: the cube-mass fraction -/

/-- The **cube-mass fraction** `c(L) = Σ mⱼ³ / n³`: the exact tie invariant that the ceiling
sees (`ρ² = 1 - c + O(1/n²)`). -/
def cubeFrac (L : List ℕ) : ℚ := cubeSum L / (L.sum : ℚ) ^ 3

/-- **The modal fraction only pins the cube-mass fraction to a window** `[a³, a²]`. -/
theorem cubeFrac_window (L : List ℕ) (h : 2 ≤ L.sum) :
    modalFrac L ^ 3 ≤ cubeFrac L ∧ cubeFrac L ≤ modalFrac L ^ 2 := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hpos : (0 : ℚ) < (L.sum : ℚ) := by linarith
  have hne : L ≠ [] := by
    rintro rfl
    simp at h
  set n : ℚ := (L.sum : ℚ) with hnval
  set M : ℚ := ((modalBlock L : ℕ) : ℚ) with hMval
  have hM0 : (0 : ℚ) ≤ M := by positivity
  have hlow : M ^ 3 ≤ cubeSum L := cube_le_cubeSum (modalBlock_mem hne)
  have hhigh : cubeSum L ≤ M ^ 2 * n := cubeSum_le_sq_mul_sum (fun m hm => le_modalBlock hm)
  have hn3 : (0 : ℚ) < n ^ 3 := by positivity
  have hn2 : (0 : ℚ) < n ^ 2 := by positivity
  constructor
  · rw [cubeFrac, modalFrac, ← hnval, ← hMval, div_pow, div_le_div_iff₀ hn3 hn3]
    nlinarith
  · rw [cubeFrac, modalFrac, ← hnval, ← hMval, div_pow, div_le_div_iff₀ hn3 hn2]
    nlinarith [mul_le_mul_of_nonneg_right hhigh (le_of_lt hn2)]

/-- The window `[a³, a²]` has width at most `4/27`, attained at `a = 2/3`. -/
theorem modal_window_width (L : List ℕ) (h : 2 ≤ L.sum) :
    modalFrac L ^ 2 - modalFrac L ^ 3 ≤ 4 / 27 := by
  have h0 := modalFrac_nonneg L
  have h1 := modalFrac_le_one h
  nlinarith [sq_nonneg (3 * modalFrac L - 2), sq_nonneg (modalFrac L)]

/-- The ceiling *is* one minus the cube-mass fraction, to `O(1/n²)`. -/
theorem ceiling_eq_one_sub_cubeFrac (L : List ℕ) (h : 2 ≤ L.sum) :
    |spearmanSq L - (1 - cubeFrac L)| ≤ 1 / ((L.sum : ℚ) ^ 2 - 1) := by
  have hn : (2 : ℚ) ≤ (L.sum : ℚ) := by exact_mod_cast h
  have hpos : (0 : ℚ) < (L.sum : ℚ) := by linarith
  have hden : (0 : ℚ) < (L.sum : ℚ) ^ 3 - (L.sum : ℚ) := cube_sub_self_pos hn
  set n : ℚ := (L.sum : ℚ) with hnval
  have hsq : (0 : ℚ) < n ^ 2 - 1 := by nlinarith
  have hC0 : 0 ≤ cubeSum L := cubeSum_nonneg L
  have hCn : cubeSum L ≤ n ^ 3 := by
    have := cubeSum_le_sq_mul_sum (L := L) (M := L.sum) (fun m hm => le_sum_of_mem hm)
    calc cubeSum L ≤ (L.sum : ℚ) ^ 2 * (L.sum : ℚ) := this
      _ = n ^ 3 := by rw [hnval]; ring
  have hdiff : spearmanSq L - (1 - cubeFrac L)
      = (n ^ 3 - cubeSum L) * n / (n ^ 3 * (n ^ 3 - n)) := by
    rw [spearmanSq_eq_cube_ratio L h, cubeFrac, ← hnval]
    field_simp
    ring
  have hnum : (0 : ℚ) ≤ (n ^ 3 - cubeSum L) * n / (n ^ 3 * (n ^ 3 - n)) := by
    apply div_nonneg
    · nlinarith
    · positivity
  rw [hdiff, abs_of_nonneg hnum, div_le_div_iff₀ (by positivity) hsq]
  nlinarith

/-- **The corrected Lipschitz law.**  Two draw laws whose cube-mass fractions differ by `γ`
have ceilings within `γ + O(1/n²) + O(1/n'²)` of each other.  (Contrast with
`no_modal_lipschitz`: the same statement with the *modal* fraction is false.) -/
theorem cubeFrac_lipschitz (L L' : List ℕ) (h : 2 ≤ L.sum) (h' : 2 ≤ L'.sum) :
    |spearmanSq L - spearmanSq L'|
      ≤ |cubeFrac L - cubeFrac L'| + 1 / ((L.sum : ℚ) ^ 2 - 1) + 1 / ((L'.sum : ℚ) ^ 2 - 1) := by
  have h1 := ceiling_eq_one_sub_cubeFrac L h
  have h2 := ceiling_eq_one_sub_cubeFrac L' h'
  have hkey : spearmanSq L - spearmanSq L'
      = (spearmanSq L - (1 - cubeFrac L)) - (spearmanSq L' - (1 - cubeFrac L'))
        + (cubeFrac L' - cubeFrac L) := by ring
  have habs : |cubeFrac L' - cubeFrac L| = |cubeFrac L - cubeFrac L'| := abs_sub_comm _ _
  calc |spearmanSq L - spearmanSq L'|
      ≤ |(spearmanSq L - (1 - cubeFrac L)) - (spearmanSq L' - (1 - cubeFrac L'))|
          + |cubeFrac L' - cubeFrac L| := by rw [hkey]; exact abs_add_le _ _
    _ ≤ (|spearmanSq L - (1 - cubeFrac L)| + |spearmanSq L' - (1 - cubeFrac L')|)
          + |cubeFrac L' - cubeFrac L| := by
        have hsub := abs_sub (spearmanSq L - (1 - cubeFrac L)) (spearmanSq L' - (1 - cubeFrac L'))
        linarith
    _ ≤ |cubeFrac L - cubeFrac L'| + 1 / ((L.sum : ℚ) ^ 2 - 1)
          + 1 / ((L'.sum : ℚ) ^ 2 - 1) := by rw [habs]; linarith

/-! ## 5. The universal budget in `ρ` -/

lemma eps_nonneg {L : List ℕ} (h : 2 ≤ L.sum) : (0 : ℝ) ≤ 1 / (((L.sum : ℕ) : ℝ) ^ 2 - 1) := by
  have hn : (2 : ℝ) ≤ ((L.sum : ℕ) : ℝ) := by exact_mod_cast h
  have hpos : (0 : ℝ) < ((L.sum : ℕ) : ℝ) ^ 2 - 1 := by nlinarith
  positivity

/-- Upper half of the budget: `ρ ≤ 1 - a³/2 + 1/(n²-1)`. -/
theorem spearman_le_of_modal (L : List ℕ) (h : 2 ≤ L.sum) :
    spearman L ≤ 1 - ((modalFrac L : ℚ) : ℝ) ^ 3 / 2 + 1 / (((L.sum : ℕ) : ℝ) ^ 2 - 1) := by
  obtain ⟨N, hN⟩ : ∃ N : ℕ, L.sum = N := ⟨_, rfl⟩
  have hN2 : 2 ≤ N := hN ▸ h
  have hNR : (2 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN2
  have hsq : (0 : ℝ) < (N : ℝ) ^ 2 - 1 := by nlinarith
  have he0 : (0 : ℝ) ≤ 1 / ((N : ℝ) ^ 2 - 1) := le_of_lt (div_pos one_pos hsq)
  have hQ := modal_fraction_cap L h
  rw [hN] at hQ
  have ha0 : (0 : ℝ) ≤ ((modalFrac L : ℚ) : ℝ) := by exact_mod_cast modalFrac_nonneg L
  have ha1 : ((modalFrac L : ℚ) : ℝ) ≤ 1 := by exact_mod_cast modalFrac_le_one h
  have hcast : ((spearmanSq L : ℚ) : ℝ)
      ≤ 1 - ((modalFrac L : ℚ) : ℝ) ^ 3 + 1 / ((N : ℝ) ^ 2 - 1) := by
    have hc := (Rat.cast_le (K := ℝ)).2 hQ
    push_cast at hc
    linarith
  rw [hN, spearman_eq_sqrt L h]
  set a : ℝ := ((modalFrac L : ℚ) : ℝ) with ha
  set e : ℝ := 1 / ((N : ℝ) ^ 2 - 1) with he
  have ha3 : a ^ 3 ≤ 1 := pow_le_one₀ ha0 ha1
  have ha3' : (0 : ℝ) ≤ a ^ 3 := by positivity
  have hy0 : (0 : ℝ) ≤ 1 - a ^ 3 / 2 + e := by linarith
  have hys : ((spearmanSq L : ℚ) : ℝ) ≤ (1 - a ^ 3 / 2 + e) ^ 2 := by
    nlinarith [sq_nonneg (a ^ 3), sq_nonneg e, mul_nonneg he0 (by linarith : (0 : ℝ) ≤ 1 - a ^ 3)]
  calc Real.sqrt ((spearmanSq L : ℚ) : ℝ) ≤ Real.sqrt ((1 - a ^ 3 / 2 + e) ^ 2) :=
        Real.sqrt_le_sqrt hys
    _ = 1 - a ^ 3 / 2 + e := Real.sqrt_sq hy0

/-- Lower half of the budget: `ρ ≥ 1 - a`. -/
theorem spearman_ge_of_modal (L : List ℕ) (h : 2 ≤ L.sum) :
    1 - ((modalFrac L : ℚ) : ℝ) ≤ spearman L := by
  have ha0 : (0 : ℝ) ≤ ((modalFrac L : ℚ) : ℝ) := by exact_mod_cast modalFrac_nonneg L
  have ha1 : ((modalFrac L : ℚ) : ℝ) ≤ 1 := by exact_mod_cast modalFrac_le_one h
  have hfloor : (1 : ℝ) - ((modalFrac L : ℚ) : ℝ) ^ 2 ≤ ((spearmanSq L : ℚ) : ℝ) := by
    have hc := (Rat.cast_le (K := ℝ)).2 (mass_fraction_floor L h)
    push_cast at hc
    linarith
  have hx0 : (0 : ℝ) ≤ ((spearmanSq L : ℚ) : ℝ) := by
    exact_mod_cast spearmanSq_nonneg L
  rw [spearman_eq_sqrt L h, Real.le_sqrt (by linarith) hx0]
  nlinarith

/-- The elementary optimisation behind the budget constant: `a - a³/2 ≤ 109/200` on `[0,1]`. -/
lemma cubic_budget_bound {a : ℝ} (ha0 : 0 ≤ a) : a - a ^ 3 / 2 ≤ 109 / 200 := by
  nlinarith [sq_nonneg (a - 33 / 40), sq_nonneg (a + 33 / 20), sq_nonneg a,
    sq_nonneg (a - 4 / 5), sq_nonneg (a - 1)]

/-- **The universal law-change budget.**  For any two tie profiles with modal fractions `a`,
`a'`, the tie ceilings satisfy `|ρ - ρ'| ≤ |a - a'| + 109/200 + O(1/n²) + O(1/n'²)`.
The additive constant `109/200 = 0.545` cannot be removed (`equal_modal_ceiling_gap`) nor
lowered below `1/2` (`budget_constant_gt_half`). -/
theorem spearman_modal_budget (L L' : List ℕ) (h : 2 ≤ L.sum) (h' : 2 ≤ L'.sum) :
    |spearman L - spearman L'|
      ≤ |((modalFrac L : ℚ) : ℝ) - ((modalFrac L' : ℚ) : ℝ)| + 109 / 200
        + 1 / (((L.sum : ℕ) : ℝ) ^ 2 - 1) + 1 / (((L'.sum : ℕ) : ℝ) ^ 2 - 1) := by
  have ha0 : (0 : ℝ) ≤ ((modalFrac L : ℚ) : ℝ) := by exact_mod_cast modalFrac_nonneg L
  have ha1 : ((modalFrac L : ℚ) : ℝ) ≤ 1 := by exact_mod_cast modalFrac_le_one h
  have ha0' : (0 : ℝ) ≤ ((modalFrac L' : ℚ) : ℝ) := by exact_mod_cast modalFrac_nonneg L'
  have ha1' : ((modalFrac L' : ℚ) : ℝ) ≤ 1 := by exact_mod_cast modalFrac_le_one h'
  have hup := spearman_le_of_modal L h
  have hlo := spearman_ge_of_modal L h
  have hup' := spearman_le_of_modal L' h'
  have hlo' := spearman_ge_of_modal L' h'
  have he := eps_nonneg h
  have he' := eps_nonneg h'
  set a : ℝ := ((modalFrac L : ℚ) : ℝ) with ha
  set a' : ℝ := ((modalFrac L' : ℚ) : ℝ) with ha'
  have hda : a - a' ≤ |a - a'| := le_abs_self _
  have hda' : a' - a ≤ |a - a'| := by
    rw [abs_sub_comm]; exact le_abs_self _
  have hb : a - a ^ 3 / 2 ≤ 109 / 200 := cubic_budget_bound ha0
  have hb' : a' - a' ^ 3 / 2 ≤ 109 / 200 := cubic_budget_bound ha0'
  rw [abs_le]
  constructor
  · have hstep : a - a' ^ 3 / 2 = (a - a') + (a' - a' ^ 3 / 2) := by ring
    linarith
  · have hstep : a' - a ^ 3 / 2 = (a' - a) + (a - a ^ 3 / 2) := by ring
    linarith

/-- **Response-effect test.**  For samples of at least `100` points the budget reads
`|Δρ| ≤ |Δa| + 0.55`.  Any recorded law-to-law movement exceeding this cannot be a tie effect
at all, whatever the two profiles are. -/
theorem response_effect_threshold (L L' : List ℕ) (hn : 100 ≤ L.sum) (hn' : 100 ≤ L'.sum) :
    |spearman L - spearman L'|
      ≤ |((modalFrac L : ℚ) : ℝ) - ((modalFrac L' : ℚ) : ℝ)| + 11 / 20 := by
  have h : 2 ≤ L.sum := by omega
  have h' : 2 ≤ L'.sum := by omega
  have hnR : (100 : ℝ) ≤ ((L.sum : ℕ) : ℝ) := by exact_mod_cast hn
  have hnR' : (100 : ℝ) ≤ ((L'.sum : ℕ) : ℝ) := by exact_mod_cast hn'
  have hb := spearman_modal_budget L L' h h'
  have hsmall : 1 / (((L.sum : ℕ) : ℝ) ^ 2 - 1) ≤ 1 / 9999 := by
    apply one_div_le_one_div_of_le (by norm_num)
    nlinarith
  have hsmall' : 1 / (((L'.sum : ℕ) : ℝ) ^ 2 - 1) ≤ 1 / 9999 := by
    apply one_div_le_one_div_of_le (by norm_num)
    nlinarith
  linarith

/-! ## 6. Two-block families: sharpness of the window, refutation of the conjecture -/

/-- The balanced two-block profile: two tie classes of size `m`. -/
def pairProfile (m : ℕ) : List ℕ := [m, m]

/-- The one-block-plus-singletons profile: one tie class of size `m`, the rest untied. -/
def splitProfile (m : ℕ) : List ℕ := m :: List.replicate m 1

lemma cubeSum_replicate_one (m : ℕ) : cubeSum (List.replicate m 1) = (m : ℚ) := by
  induction m with
  | zero => simp [cubeSum]
  | succ k ih =>
      rw [List.replicate_succ, cubeSum, ih]
      push_cast
      ring

@[simp] lemma pairProfile_sum (m : ℕ) : (pairProfile m).sum = 2 * m := by
  simp [pairProfile, two_mul]

@[simp] lemma splitProfile_sum (m : ℕ) : (splitProfile m).sum = 2 * m := by
  simp [splitProfile, two_mul]

lemma pairProfile_cubeSum (m : ℕ) : cubeSum (pairProfile m) = 2 * (m : ℚ) ^ 3 := by
  rw [pairProfile, cubeSum, cubeSum, cubeSum]
  ring

lemma splitProfile_cubeSum (m : ℕ) : cubeSum (splitProfile m) = (m : ℚ) ^ 3 + (m : ℚ) := by
  rw [splitProfile, cubeSum, cubeSum_replicate_one]

lemma pairProfile_modalBlock (m : ℕ) : modalBlock (pairProfile m) = m := by
  simp [pairProfile]

lemma splitProfile_modalBlock {m : ℕ} (hm : 1 ≤ m) : modalBlock (splitProfile m) = m := by
  refine modalBlock_eq (List.mem_cons_self ..) ?_
  intro x hx
  rcases List.mem_cons.1 hx with rfl | hx'
  · exact le_rfl
  · have := List.eq_of_mem_replicate hx'
    omega

lemma pairProfile_modalFrac {m : ℕ} (hm : 1 ≤ m) : modalFrac (pairProfile m) = 1 / 2 := by
  have hm0 : (m : ℚ) ≠ 0 := by
    have : 0 < m := hm
    positivity
  rw [modalFrac, pairProfile_modalBlock, pairProfile_sum]
  push_cast
  field_simp

lemma splitProfile_modalFrac {m : ℕ} (hm : 1 ≤ m) : modalFrac (splitProfile m) = 1 / 2 := by
  have hm0 : (m : ℚ) ≠ 0 := by
    have : 0 < m := hm
    positivity
  rw [modalFrac, splitProfile_modalBlock hm, splitProfile_sum]
  push_cast
  field_simp

lemma two_le_pair_sum {m : ℕ} (hm : 1 ≤ m) : 2 ≤ (pairProfile m).sum := by
  rw [pairProfile_sum]; omega

lemma two_le_split_sum {m : ℕ} (hm : 1 ≤ m) : 2 ≤ (splitProfile m).sum := by
  rw [splitProfile_sum]; omega

/-- **Upper endpoint of the window is attained**: the balanced two-block profile has
`c = a²` exactly. -/
theorem window_sharp_upper {m : ℕ} (hm : 1 ≤ m) :
    cubeFrac (pairProfile m) = modalFrac (pairProfile m) ^ 2 := by
  have hm0 : (m : ℚ) ≠ 0 := by
    have : 0 < m := hm
    positivity
  rw [cubeFrac, pairProfile_cubeSum, pairProfile_sum, pairProfile_modalFrac hm]
  push_cast
  field_simp

/-- **Lower endpoint of the window is attained to `O(1/n²)`**: the single-block profile has
`c = a³ + 1/(8m²)`. -/
theorem window_sharp_lower {m : ℕ} (hm : 1 ≤ m) :
    cubeFrac (splitProfile m) - modalFrac (splitProfile m) ^ 3 = 1 / (8 * (m : ℚ) ^ 2) := by
  have hm0 : (m : ℚ) ≠ 0 := by
    have : 0 < m := hm
    positivity
  rw [cubeFrac, splitProfile_cubeSum, splitProfile_sum, splitProfile_modalFrac hm]
  push_cast
  field_simp
  ring

lemma pairProfile_spearmanSq {m : ℕ} (hm : 4 ≤ m) : spearmanSq (pairProfile m) ≤ 16 / 21 := by
  have hm1 : 1 ≤ m := by omega
  have h2 := two_le_pair_sum hm1
  have hmQ : (4 : ℚ) ≤ (m : ℚ) := by exact_mod_cast hm
  have hm2 : (16 : ℚ) ≤ (m : ℚ) ^ 2 := by nlinarith
  have hm3 : (32 : ℚ) * (m : ℚ) ≤ 2 * (m : ℚ) ^ 3 := by nlinarith
  have hden : (0 : ℚ) < (2 * (m : ℚ)) ^ 3 - 2 * (m : ℚ) := by nlinarith
  rw [spearmanSq_eq_cube_ratio _ h2, pairProfile_cubeSum, pairProfile_sum]
  push_cast
  rw [div_le_iff₀ (by nlinarith)]
  nlinarith

lemma splitProfile_spearmanSq {m : ℕ} (hm : 1 ≤ m) : 7 / 8 ≤ spearmanSq (splitProfile m) := by
  have h2 := two_le_split_sum hm
  have hmQ : (1 : ℚ) ≤ (m : ℚ) := by exact_mod_cast hm
  have hm2 : (1 : ℚ) ≤ (m : ℚ) ^ 2 := by nlinarith
  have hm3 : (m : ℚ) ≤ (m : ℚ) ^ 3 := by nlinarith
  have hden : (0 : ℚ) < (2 * (m : ℚ)) ^ 3 - 2 * (m : ℚ) := by nlinarith
  rw [spearmanSq_eq_cube_ratio _ h2, splitProfile_cubeSum, splitProfile_sum]
  push_cast
  rw [le_div_iff₀ (by nlinarith)]
  nlinarith

/-- **The conjecture fails, uniformly in `n`.**  For every `m ≥ 4` the two profiles
`[m, m]` and `[m, 1, …, 1]` have the *same* sample size `2m` and the *same* modal fraction
`1/2`, yet their tie ceilings differ by more than `1/20` in `ρ`. -/
theorem equal_modal_ceiling_gap {m : ℕ} (hm : 4 ≤ m) :
    modalFrac (pairProfile m) = modalFrac (splitProfile m) ∧
      (pairProfile m).sum = (splitProfile m).sum ∧
      1 / 20 < spearman (splitProfile m) - spearman (pairProfile m) := by
  have hm1 : 1 ≤ m := by omega
  refine ⟨by rw [pairProfile_modalFrac hm1, splitProfile_modalFrac hm1], by simp, ?_⟩
  have h2p := two_le_pair_sum hm1
  have h2s := two_le_split_sum hm1
  -- the split profile reads above `0.935`
  have hsplit : (935 : ℝ) / 1000 < spearman (splitProfile m) := by
    rw [spearman_eq_sqrt _ h2s, Real.lt_sqrt (by norm_num)]
    have hc := (Rat.cast_le (K := ℝ)).2 (splitProfile_spearmanSq hm1)
    push_cast at hc
    nlinarith
  -- the balanced pair profile reads below `0.873`
  have hpair : spearman (pairProfile m) < 873 / 1000 := by
    rw [spearman_eq_sqrt _ h2p, Real.sqrt_lt' (by norm_num)]
    have hc := (Rat.cast_le (K := ℝ)).2 (pairProfile_spearmanSq hm)
    push_cast at hc
    nlinarith
  linarith

/-- **No modal-fraction Lipschitz law.**  The conjectured budget `|Δρ| ≤ |Δa| + 1/20` is false. -/
theorem no_modal_lipschitz :
    ¬ ∀ L L' : List ℕ, 2 ≤ L.sum → 2 ≤ L'.sum → L.sum = L'.sum →
      |spearman L - spearman L'|
        ≤ |((modalFrac L : ℚ) : ℝ) - ((modalFrac L' : ℚ) : ℝ)| + 1 / 20 := by
  intro hcon
  obtain ⟨hmodal, hsum, hgap⟩ := equal_modal_ceiling_gap (m := 4) le_rfl
  have hbad := hcon (splitProfile 4) (pairProfile 4) (two_le_split_sum (by norm_num))
    (two_le_pair_sum (by norm_num)) hsum.symm
  rw [hmodal] at hbad
  simp only [sub_self, abs_zero, zero_add] at hbad
  have h1 : spearman (splitProfile 4) - spearman (pairProfile 4)
      ≤ |spearman (splitProfile 4) - spearman (pairProfile 4)| := le_abs_self _
  linarith

/-- **No `O(1/n)` repair either.**  For every constant `C` the budget
`|Δρ| ≤ |Δa| + C/n` fails: the equal-modal gap of `equal_modal_ceiling_gap` stays above
`1/20` while `C/n → 0`. -/
theorem no_modal_lipschitz_with_rate (C : ℝ) :
    ¬ ∀ L L' : List ℕ, 2 ≤ L.sum → 2 ≤ L'.sum → L.sum = L'.sum →
      |spearman L - spearman L'|
        ≤ |((modalFrac L : ℚ) : ℝ) - ((modalFrac L' : ℚ) : ℝ)| + C / ((L.sum : ℕ) : ℝ) := by
  intro hcon
  obtain ⟨m0, hm0⟩ := exists_nat_ge (10 * C)
  set m : ℕ := max m0 4 with hmdef
  have hm4 : 4 ≤ m := le_max_right _ _
  have hmm0 : (m0 : ℝ) ≤ (m : ℝ) := by
    have : m0 ≤ m := le_max_left _ _
    exact_mod_cast this
  have hmpos : (0 : ℝ) < (m : ℝ) := by
    have : (4 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm4
    linarith
  obtain ⟨hmodal, hsum, hgap⟩ := equal_modal_ceiling_gap hm4
  have hbad := hcon (splitProfile m) (pairProfile m) (two_le_split_sum (by omega))
    (two_le_pair_sum (by omega)) hsum.symm
  rw [hmodal] at hbad
  simp only [sub_self, abs_zero, zero_add] at hbad
  have hsmall : C / (((splitProfile m).sum : ℕ) : ℝ) ≤ 1 / 20 := by
    have hs : (((splitProfile m).sum : ℕ) : ℝ) = 2 * (m : ℝ) := by
      rw [splitProfile_sum]; push_cast; ring
    rw [hs, div_le_div_iff₀ (by linarith) (by norm_num)]
    nlinarith
  have h1 : spearman (splitProfile m) - spearman (pairProfile m)
      ≤ |spearman (splitProfile m) - spearman (pairProfile m)| := le_abs_self _
  linarith

/-! ## 7. How large must the additive constant be?  A two-sided bracket -/

/-- One dominant block of size `3k` plus `k` singletons: modal fraction `3/4`, ceiling `> 3/4`. -/
def dominantProfile (k : ℕ) : List ℕ := (3 * k) :: List.replicate k 1

/-- The fully tied profile: one block of size `4k`, modal fraction `1`, ceiling `0`. -/
def tiedProfile (k : ℕ) : List ℕ := [4 * k]

@[simp] lemma dominantProfile_sum (k : ℕ) : (dominantProfile k).sum = 4 * k := by
  simp [dominantProfile]
  ring

@[simp] lemma tiedProfile_sum (k : ℕ) : (tiedProfile k).sum = 4 * k := by
  simp [tiedProfile]

lemma dominantProfile_cubeSum (k : ℕ) :
    cubeSum (dominantProfile k) = 27 * (k : ℚ) ^ 3 + (k : ℚ) := by
  rw [dominantProfile, cubeSum, cubeSum_replicate_one]
  push_cast
  ring

lemma dominantProfile_modalBlock {k : ℕ} (hk : 1 ≤ k) : modalBlock (dominantProfile k) = 3 * k := by
  refine modalBlock_eq (List.mem_cons_self ..) ?_
  intro x hx
  rcases List.mem_cons.1 hx with rfl | hx'
  · exact le_rfl
  · have := List.eq_of_mem_replicate hx'
    omega

lemma tiedProfile_modalBlock (k : ℕ) : modalBlock (tiedProfile k) = 4 * k := by
  simp [tiedProfile]

lemma dominantProfile_modalFrac {k : ℕ} (hk : 1 ≤ k) : modalFrac (dominantProfile k) = 3 / 4 := by
  have hk0 : (k : ℚ) ≠ 0 := by
    have : 0 < k := hk
    positivity
  rw [modalFrac, dominantProfile_modalBlock hk, dominantProfile_sum]
  push_cast
  field_simp

lemma tiedProfile_modalFrac {k : ℕ} (hk : 1 ≤ k) : modalFrac (tiedProfile k) = 1 := by
  have hk0 : (k : ℚ) ≠ 0 := by
    have : 0 < k := hk
    positivity
  rw [modalFrac, tiedProfile_modalBlock, tiedProfile_sum]
  push_cast
  field_simp

lemma tiedProfile_spearman {k : ℕ} (hk : 1 ≤ k) : spearman (tiedProfile k) = 0 := by
  have h2 : 2 ≤ (tiedProfile k).sum := by
    rw [tiedProfile_sum]; omega
  have hzero : spearmanSq (tiedProfile k) = 0 := by
    have hcs : cubeSum (tiedProfile k) = ((4 * k : ℕ) : ℚ) ^ 3 := by
      rw [tiedProfile, cubeSum, cubeSum]
      ring
    rw [spearmanSq_eq_cube_ratio _ h2, tiedProfile_sum, hcs]
    simp
  rw [spearman_eq_sqrt _ h2, hzero]
  simp

lemma dominantProfile_spearmanSq {k : ℕ} (hk : 1 ≤ k) :
    9 / 16 < spearmanSq (dominantProfile k) := by
  have h2 : 2 ≤ (dominantProfile k).sum := by
    rw [dominantProfile_sum]; omega
  have hkQ : (1 : ℚ) ≤ (k : ℚ) := by exact_mod_cast hk
  have hk2 : (1 : ℚ) ≤ (k : ℚ) ^ 2 := by nlinarith
  have hk3 : (k : ℚ) ≤ (k : ℚ) ^ 3 := by nlinarith
  have hden : (0 : ℚ) < (4 * (k : ℚ)) ^ 3 - 4 * (k : ℚ) := by nlinarith
  rw [spearmanSq_eq_cube_ratio _ h2, dominantProfile_cubeSum, dominantProfile_sum]
  push_cast
  rw [lt_div_iff₀ (by nlinarith)]
  nlinarith

/-- **The budget constant must exceed `1/2`.**  The pair (dominant block of `3/4` of the mass,
fully tied profile) has modal-fraction gap `1/4` but ceiling gap `> 3/4`. -/
theorem dominant_tied_excess {k : ℕ} (hk : 1 ≤ k) :
    |((modalFrac (dominantProfile k) : ℚ) : ℝ) - ((modalFrac (tiedProfile k) : ℚ) : ℝ)| + 1 / 2
      < |spearman (dominantProfile k) - spearman (tiedProfile k)| := by
  have h2 : 2 ≤ (dominantProfile k).sum := by
    rw [dominantProfile_sum]; omega
  have hdom : (3 : ℝ) / 4 < spearman (dominantProfile k) := by
    rw [spearman_eq_sqrt _ h2, Real.lt_sqrt (by norm_num)]
    have hc := (Rat.cast_lt (K := ℝ)).2 (dominantProfile_spearmanSq hk)
    push_cast at hc
    nlinarith
  have htied : spearman (tiedProfile k) = 0 := tiedProfile_spearman hk
  have hgap : |((modalFrac (dominantProfile k) : ℚ) : ℝ) - ((modalFrac (tiedProfile k) : ℚ) : ℝ)|
      = 1 / 4 := by
    rw [dominantProfile_modalFrac hk, tiedProfile_modalFrac hk]
    push_cast
    rw [abs_sub_comm, abs_of_nonneg (by norm_num : (0 : ℝ) ≤ 1 - 3 / 4)]
    norm_num
  rw [hgap, htied, sub_zero, abs_of_pos (by linarith)]
  linarith

/-- **Lower bound for any universal budget constant.**  If `C` works as an additive budget for
all profile pairs, then `C > 1/2`. -/
theorem budget_constant_gt_half (C : ℝ)
    (hC : ∀ L L' : List ℕ, 2 ≤ L.sum → 2 ≤ L'.sum →
      |spearman L - spearman L'|
        ≤ |((modalFrac L : ℚ) : ℝ) - ((modalFrac L' : ℚ) : ℝ)| + C) : 1 / 2 < C := by
  have h1 : 2 ≤ (dominantProfile 1).sum := by
    rw [dominantProfile_sum]; omega
  have h2 : 2 ≤ (tiedProfile 1).sum := by
    rw [tiedProfile_sum]; omega
  have hbad := hC (dominantProfile 1) (tiedProfile 1) h1 h2
  have hexc := dominant_tied_excess (k := 1) le_rfl
  linarith

/-- **Bracket for the optimal constant.**  Any universal additive budget constant is `> 1/2`,
and `11/20` works for all samples of at least `100` points.  The conjectured value `0` is
therefore wrong by more than a half. -/
theorem budget_constant_bracket :
    (∀ C : ℝ, (∀ L L' : List ℕ, 2 ≤ L.sum → 2 ≤ L'.sum →
        |spearman L - spearman L'|
          ≤ |((modalFrac L : ℚ) : ℝ) - ((modalFrac L' : ℚ) : ℝ)| + C) → 1 / 2 < C) ∧
      (∀ L L' : List ℕ, 100 ≤ L.sum → 100 ≤ L'.sum →
        |spearman L - spearman L'|
          ≤ |((modalFrac L : ℚ) : ℝ) - ((modalFrac L' : ℚ) : ℝ)| + 11 / 20) :=
  ⟨budget_constant_gt_half, response_effect_threshold⟩

/-! ## 8. The catalog law swap: zero modal gap, nonzero ceiling movement -/

lemma dyadicBlocks_le (b : ℕ) : ∀ m ∈ dyadicBlocks b, m ≤ 2 ^ b := by
  induction b with
  | zero =>
      intro m hm
      simp [dyadicBlocks] at hm
      omega
  | succ k ih =>
      intro m hm
      rw [dyadicBlocks, List.mem_cons] at hm
      rcases hm with rfl | hm'
      · exact Nat.pow_le_pow_right (by norm_num) (by omega)
      · exact le_trans (ih m hm') (Nat.pow_le_pow_right (by norm_num) (by omega))

/-- The uniform (dyadic) tie profile has modal fraction exactly `1/2`. -/
theorem modalFrac_dyadic {b : ℕ} (hb : 1 ≤ b) : modalFrac (dyadicBlocks b) = 1 / 2 := by
  obtain ⟨c, rfl⟩ : ∃ c, b = c + 1 := ⟨b - 1, by omega⟩
  have hmodal : modalBlock (dyadicBlocks (c + 1)) = 2 ^ c := by
    refine modalBlock_eq ?_ ?_
    · rw [dyadicBlocks]
      exact List.mem_cons_self ..
    · intro m hm
      rw [dyadicBlocks, List.mem_cons] at hm
      rcases hm with rfl | hm'
      · exact le_rfl
      · exact dyadicBlocks_le c m hm'
  have hpow : (0 : ℚ) < (2 : ℚ) ^ c := by positivity
  rw [modalFrac, hmodal, dyadicBlocks_sum]
  push_cast
  rw [pow_succ]
  field_simp

/-- The balanced (fixed-weight) tie profile at the exactly balanced weight has modal fraction
exactly `1/2`. -/
theorem modalFrac_weightBlocks {v : ℕ} (hv : 1 ≤ v) :
    modalFrac (weightBlocks (2 * v) v) = 1 / 2 := by
  have hmodal : modalBlock (weightBlocks (2 * v) v) = Nat.choose (2 * v - 1) (v - 1) :=
    modalBlock_eq (modal_mem_weightBlocks _ _) (weightBlocks_le_modal _ _)
  have hsum : (weightBlocks (2 * v) v).sum = Nat.choose (2 * v) v :=
    weightBlocks_sum hv (by omega)
  have hhalf : 2 * Nat.choose (2 * v - 1) (v - 1) = Nat.choose (2 * v) v :=
    half_weight_modal_half hv
  have hposm : 0 < Nat.choose (2 * v - 1) (v - 1) := Nat.choose_pos (by omega)
  have hne : ((Nat.choose (2 * v - 1) (v - 1) : ℕ) : ℚ) ≠ 0 := by
    have : (0 : ℚ) < ((Nat.choose (2 * v - 1) (v - 1) : ℕ) : ℚ) := by exact_mod_cast hposm
    linarith
  have hQ : ((Nat.choose (2 * v) v : ℕ) : ℚ)
      = 2 * ((Nat.choose (2 * v - 1) (v - 1) : ℕ) : ℚ) := by
    exact_mod_cast hhalf.symm
  rw [modalFrac, hmodal, hsum, hQ]
  field_simp

/-- **The catalog law swap is a zero-modal-gap experiment.**  Balanced and uniform draws at
bitlen `2v` have *identical* modal fractions, yet the recorded ceiling movement is nonzero
(and bounded by `0.07`).  Under the conjectured budget the movement would have to vanish;
under the corrected budget an equal-modal pair may move by up to `> 1/20`
(`equal_modal_ceiling_gap`), which is the same order as the recorded `0.07`. -/
theorem catalog_law_swap_zero_modal_gap {v : ℕ} (hv : 2 ≤ v) :
    modalFrac (weightBlocks (2 * v) v) - modalFrac (dyadicBlocks (2 * v)) = 0 ∧
      |spearman (weightBlocks (2 * v) v) - spearman (dyadicBlocks (2 * v))| < 7 / 100 := by
  refine ⟨?_, law_change_capacity hv⟩
  rw [modalFrac_weightBlocks (by omega), modalFrac_dyadic (by omega)]
  ring

end Catalog.Applications.ModalFractionCapacity