import Mathlib
import Probability.PPowMultiseedVarianceDecomposition

/-!
# The fibrewise variance law: `ΔR²` is exactly the within-radical variance fraction

Fourth cycle of the PPOW-MULTISEED study (round-46 #2, experiment 506).  The
previous files showed that the prime-power feature `ppExcess` carries genuine
information that no function of the base feature `rad` can reproduce, and
computed `ΔR² = 1` on the extreme (single-fibre) 2-smooth tower design.  Here we
close the corresponding open direction ("Fibrewise Variance Law for the Radical
Design") in full generality and *with equality*.

For a finite design `S`, a "base model" is any predictor of the form
`n ↦ f (g n)` where `g` is the base statistic (for us `g = rad`).  Such a model
can only see the fibres of `g`, so its best possible residual is the **total
within-fibre sum of squares**

`withinSS S g y = ∑_{c ∈ image g S} TSS (fibre S g c) y`.

Main results.

* `withinSS_le_base_residual` — every base model has residual at least
  `withinSS`, with
* `base_residual_fibrewiseMean` / `exists_base_model_attaining_withinSS` —
  equality attained by the fibrewise mean, so `withinSS` is exactly the optimum.
* `base_R2_le` and `deltaR2_eq_withinSS_div_TSS` — hence the best base-only `R²`
  equals `1 - withinSS/TSS` and the lift of an exact prime-power model over the
  *best* base model is **exactly** `withinSS/TSS`: `ΔR²` is a purely arithmetic
  quantity, the fraction of the variance of `ppExcess` that lives inside the
  fibres of `rad`.
* `withinSS_pos_of_collision` and `deltaR2_pos_of_collision` — the lift is
  strictly positive as soon as the design contains one radical collision with
  different prime-power content (`rad m = rad n`, `ppExcess m ≠ ppExcess n`);
  and `deltaR2_eq_zero_of_fibrewise_constant` shows the converse: with no such
  collision the lift is exactly `0`.  This is the sharp dichotomy behind the
  experiment: the measured `ΔR² ≈ 0.05` is the density of radical collisions in
  a window, not a fitting artefact.
* `deltaR2_two_three_four` — a fully explicit instance: on the design
  `{2, 3, 4}` the lift is exactly `3/4` (strictly between the degenerate values
  `0` and `1`), with `withinSS = (log 2)²/2` and `TSS = (2/3)(log 2)²`.
-/

namespace PPowMultiseed

open Finset

/-! ## Fibres of the base statistic -/

/-- The fibre of the base statistic `g` over the value `c`, inside the design `S`. -/
def fibre (S : Finset ℕ) (g : ℕ → ℕ) (c : ℕ) : Finset ℕ := S.filter fun n => g n = c

lemma mem_fibre {S : Finset ℕ} {g : ℕ → ℕ} {c n : ℕ} :
    n ∈ fibre S g c ↔ n ∈ S ∧ g n = c := by
  simp [fibre]

/-- Total within-fibre sum of squares: the variance of `y` that survives after
conditioning on the base statistic `g`. -/
noncomputable def withinSS (S : Finset ℕ) (g : ℕ → ℕ) (y : ℕ → ℝ) : ℝ :=
  ∑ c ∈ S.image g, TSS (fibre S g c) y

lemma sum_over_fibres (S : Finset ℕ) (g : ℕ → ℕ) (F : ℕ → ℝ) :
    ∑ c ∈ S.image g, ∑ n ∈ fibre S g c, F n = ∑ n ∈ S, F n :=
  Finset.sum_fiberwise_of_maps_to (fun _ hn => Finset.mem_image_of_mem g hn) F

lemma TSS_nonneg {ι : Type*} (S : Finset ι) (y : ι → ℝ) : 0 ≤ TSS S y :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-! ## The optimum of the base-only model class -/

/-- **Lower bound.**  No predictor built from the base statistic alone can beat the
within-fibre sum of squares. -/
theorem withinSS_le_base_residual (S : Finset ℕ) (g : ℕ → ℕ) (y f : ℕ → ℝ) :
    withinSS S g y ≤ ∑ n ∈ S, (y n - f (g n)) ^ 2 := by
  rw [← sum_over_fibres S g fun n => (y n - f (g n)) ^ 2]
  refine Finset.sum_le_sum fun c _ => ?_
  have hconst : ∑ n ∈ fibre S g c, (y n - f (g n)) ^ 2
      = ∑ n ∈ fibre S g c, (y n - f c) ^ 2 :=
    Finset.sum_congr rfl fun n hn => by rw [(mem_fibre.mp hn).2]
  rw [hconst]
  rcases Nat.eq_zero_or_pos (fibre S g c).card with h0 | hpos
  · have : fibre S g c = ∅ := Finset.card_eq_zero.mp h0
    simp [TSS, this]
  · exact sumSqDev_le_sumSq_sub_const _ _ hpos _

/-- The fibrewise mean predictor. -/
noncomputable def fibreMean (S : Finset ℕ) (g : ℕ → ℕ) (y : ℕ → ℝ) (c : ℕ) : ℝ :=
  (∑ j ∈ fibre S g c, y j) / (fibre S g c).card

/-- **Attainment.**  The fibrewise mean realises the within-fibre sum of squares. -/
theorem base_residual_fibrewiseMean (S : Finset ℕ) (g : ℕ → ℕ) (y : ℕ → ℝ) :
    ∑ n ∈ S, (y n - fibreMean S g y (g n)) ^ 2 = withinSS S g y := by
  rw [← sum_over_fibres S g fun n => (y n - fibreMean S g y (g n)) ^ 2]
  refine Finset.sum_congr rfl fun c _ => ?_
  rw [TSS]
  exact Finset.sum_congr rfl fun n hn => by rw [(mem_fibre.mp hn).2, fibreMean]

theorem exists_base_model_attaining_withinSS (S : Finset ℕ) (g : ℕ → ℕ) (y : ℕ → ℝ) :
    ∃ f : ℕ → ℝ, ∑ n ∈ S, (y n - f (g n)) ^ 2 = withinSS S g y :=
  ⟨fibreMean S g y, base_residual_fibrewiseMean S g y⟩

/-! ## The exact `ΔR²` law -/

/-- Every base-only model has `R² ≤ 1 - withinSS/TSS`. -/
theorem base_R2_le {S : Finset ℕ} {g : ℕ → ℕ} {y : ℕ → ℝ} (hTSS : 0 < TSS S y) (f : ℕ → ℝ) :
    R2 S y (fun n => f (g n)) ≤ 1 - withinSS S g y / TSS S y := by
  have h := withinSS_le_base_residual S g y f
  unfold R2
  have : withinSS S g y / TSS S y ≤ (∑ n ∈ S, (y n - f (g n)) ^ 2) / TSS S y := by
    gcongr
  linarith

/-- The bound is attained: the best base-only `R²` is exactly `1 - withinSS/TSS`. -/
theorem base_R2_fibreMean {S : Finset ℕ} {g : ℕ → ℕ} {y : ℕ → ℝ} :
    R2 S y (fun n => fibreMean S g y (g n)) = 1 - withinSS S g y / TSS S y := by
  unfold R2
  rw [base_residual_fibrewiseMean]

/-- **The fibrewise variance law.**  Against the *best* base-only model, an exact
prime-power model gains exactly the within-fibre variance fraction. -/
theorem deltaR2_eq_withinSS_div_TSS {S : Finset ℕ} {g : ℕ → ℕ} {y : ℕ → ℝ} :
    R2 S y y - R2 S y (fun n => fibreMean S g y (g n)) = withinSS S g y / TSS S y := by
  rw [base_R2_fibreMean]
  unfold R2
  simp

/-- Against *any* base-only model the lift is at least the within-fibre fraction. -/
theorem deltaR2_ge_withinSS_div_TSS {S : Finset ℕ} {g : ℕ → ℕ} {y : ℕ → ℝ}
    (hTSS : 0 < TSS S y) (f : ℕ → ℝ) :
    withinSS S g y / TSS S y ≤ R2 S y y - R2 S y (fun n => f (g n)) := by
  have h1 : R2 S y y = 1 := by unfold R2; simp
  have h2 := base_R2_le (g := g) hTSS f
  rw [h1]
  linarith

/-! ## The dichotomy: collisions are exactly the source of the lift -/

/-- A fibre containing two points with different targets has positive variance. -/
theorem TSS_pos_of_two_values {F : Finset ℕ} {y : ℕ → ℝ} {m n : ℕ}
    (hm : m ∈ F) (hn : n ∈ F) (hy : y m ≠ y n) : 0 < TSS F y := by
  rcases lt_or_eq_of_le (TSS_nonneg F y) with h | h
  · exact h
  · exfalso
    have hzero : ∀ i ∈ F, (y i - (∑ j ∈ F, y j) / F.card) ^ 2 = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg fun i _ => sq_nonneg
        (y i - (∑ j ∈ F, y j) / F.card)).mp h.symm
    have hm' : y m = (∑ j ∈ F, y j) / F.card := by
      have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp (hzero m hm)
      linarith
    have hn' : y n = (∑ j ∈ F, y j) / F.card := by
      have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp (hzero n hn)
      linarith
    exact hy (hm'.trans hn'.symm)

/-- **A single radical collision forces a positive within-fibre variance.** -/
theorem withinSS_pos_of_collision {S : Finset ℕ} {g : ℕ → ℕ} {y : ℕ → ℝ} {m n : ℕ}
    (hm : m ∈ S) (hn : n ∈ S) (hg : g m = g n) (hy : y m ≠ y n) :
    0 < withinSS S g y := by
  have hmem : g m ∈ S.image g := Finset.mem_image_of_mem g hm
  have hpos : 0 < TSS (fibre S g (g m)) y := by
    refine TSS_pos_of_two_values (m := m) (n := n) ?_ ?_ hy
    · exact mem_fibre.mpr ⟨hm, rfl⟩
    · exact mem_fibre.mpr ⟨hn, hg.symm⟩
  refine lt_of_lt_of_le hpos ?_
  exact Finset.single_le_sum (f := fun c => TSS (fibre S g c) y)
    (fun c _ => TSS_nonneg _ _) hmem

/-- **Positive lift from a collision.**  If the design contains two integers with the
same radical but different prime-power excess, the prime-power feature strictly
improves on every base-only model. -/
theorem deltaR2_pos_of_collision {S : Finset ℕ} {m n : ℕ}
    (hTSS : 0 < TSS S ppExcess) (hm : m ∈ S) (hn : n ∈ S)
    (hg : rad m = rad n) (hy : ppExcess m ≠ ppExcess n) (f : ℕ → ℝ) :
    0 < R2 S ppExcess ppExcess - R2 S ppExcess (fun k => f (rad k)) := by
  have hpos := withinSS_pos_of_collision (g := rad) (y := ppExcess) hm hn hg hy
  have hle := deltaR2_ge_withinSS_div_TSS (g := rad) hTSS f
  have : 0 < withinSS S rad ppExcess / TSS S ppExcess := div_pos hpos hTSS
  linarith

/-- **Converse: no collision, no lift.**  If the target is constant on every fibre of the
base statistic, the best base-only model is already exact and the lift vanishes. -/
theorem deltaR2_eq_zero_of_fibrewise_constant {S : Finset ℕ} {g : ℕ → ℕ} {y : ℕ → ℝ}
    (hconst : ∀ m ∈ S, ∀ n ∈ S, g m = g n → y m = y n) :
    R2 S y y - R2 S y (fun n => fibreMean S g y (g n)) = 0 := by
  rw [deltaR2_eq_withinSS_div_TSS]
  have hzero : withinSS S g y = 0 := by
    refine Finset.sum_eq_zero fun c hc => ?_
    obtain ⟨m, hmS, rfl⟩ := Finset.mem_image.mp hc
    have hyc : ∀ n ∈ fibre S g (g m), y n = y m := by
      intro n hnf
      obtain ⟨hnS, hgn⟩ := mem_fibre.mp hnf
      exact (hconst m hmS n hnS hgn.symm).symm
    have hsum : ∑ j ∈ fibre S g (g m), y j = (fibre S g (g m)).card * y m := by
      rw [Finset.sum_congr rfl fun n hn => hyc n hn, Finset.sum_const, nsmul_eq_mul]
    have hcard : (fibre S g (g m)).card ≠ 0 := by
      have : m ∈ fibre S g (g m) := mem_fibre.mpr ⟨hmS, rfl⟩
      exact Finset.card_ne_zero_of_mem this
    have hcard' : ((fibre S g (g m)).card : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hcard
    refine Finset.sum_eq_zero fun n hn => ?_
    rw [hyc n hn, hsum]
    field_simp
    ring
  rw [hzero, zero_div]

/-! ## An explicit design with a non-degenerate lift -/

private lemma ppExcess_two : ppExcess 2 = 0 :=
  (ppExcess_eq_zero_iff_squarefree (n := 2) (by norm_num)).mpr
    Nat.squarefree_two

private lemma ppExcess_three : ppExcess 3 = 0 :=
  (ppExcess_eq_zero_iff_squarefree (n := 3) (by norm_num)).mpr
    (Irreducible.squarefree Nat.prime_three)

private lemma ppExcess_four : ppExcess 4 = Real.log 2 := by
  have h := ppExcess_prime_pow (p := 2) (k := 2) Nat.prime_two (by norm_num)
  norm_num at h
  simpa using h

private lemma rad_two : rad 2 = 2 := rad_prime Nat.prime_two

private lemma rad_three : rad 3 = 3 := rad_prime (by norm_num)

private lemma rad_four : rad 4 = 2 := by
  have : (4 : ℕ) = 2 ^ 2 := by norm_num
  rw [this]
  exact rad_prime_pow Nat.prime_two (by norm_num)

/-- The explicit design `{2, 3, 4}`: one radical collision (`rad 2 = rad 4 = 2`) inside a
design that also contains a squarefree singleton fibre. -/
private def D234 : Finset ℕ := {2, 3, 4}

private lemma sum_D234 (F : ℕ → ℝ) : ∑ n ∈ D234, F n = F 2 + F 3 + F 4 := by
  unfold D234
  rw [show ({2, 3, 4} : Finset ℕ) = insert 2 (insert 3 ({4} : Finset ℕ)) from rfl]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
  ring

private lemma card_D234 : D234.card = 3 := by decide

private lemma image_rad_D234 : D234.image rad = {2, 3} := by
  have : D234.image rad = {rad 2, rad 3, rad 4} := by
    unfold D234; simp [Finset.image_insert]
  rw [this, rad_two, rad_three, rad_four]
  decide

private lemma fibre_two : fibre D234 rad 2 = {2, 4} := by
  have : fibre D234 rad 2 = (D234.filter fun n => rad n = 2) := rfl
  rw [this]
  unfold D234
  rw [show ({2, 3, 4} : Finset ℕ) = insert 2 (insert 3 ({4} : Finset ℕ)) from rfl]
  rw [Finset.filter_insert, Finset.filter_insert, Finset.filter_singleton]
  rw [if_pos rad_two, if_neg (by rw [rad_three]; decide), if_pos rad_four]

private lemma fibre_three : fibre D234 rad 3 = {3} := by
  have : fibre D234 rad 3 = (D234.filter fun n => rad n = 3) := rfl
  rw [this]
  unfold D234
  rw [show ({2, 3, 4} : Finset ℕ) = insert 2 (insert 3 ({4} : Finset ℕ)) from rfl]
  rw [Finset.filter_insert, Finset.filter_insert, Finset.filter_singleton]
  rw [if_neg (by rw [rad_two]; decide), if_pos rad_three, if_neg (by rw [rad_four]; decide)]
  decide

/-- The total variance of the design `{2, 3, 4}`. -/
theorem TSS_D234 : TSS D234 ppExcess = 2 / 3 * Real.log 2 ^ 2 := by
  unfold TSS
  rw [sum_D234, card_D234]
  rw [show ∑ j ∈ D234, ppExcess j = Real.log 2 by
    rw [sum_D234, ppExcess_two, ppExcess_three, ppExcess_four]; ring]
  rw [ppExcess_two, ppExcess_three, ppExcess_four]
  push_cast
  ring

/-- The within-fibre variance of the design `{2, 3, 4}`: only the collision fibre
`{2, 4}` contributes. -/
theorem withinSS_D234 : withinSS D234 rad ppExcess = Real.log 2 ^ 2 / 2 := by
  unfold withinSS
  rw [image_rad_D234, show ({2, 3} : Finset ℕ) = insert 2 ({3} : Finset ℕ) from rfl,
    Finset.sum_insert (by decide), Finset.sum_singleton, fibre_two, fibre_three]
  have h3 : TSS ({3} : Finset ℕ) ppExcess = 0 := by
    unfold TSS; simp
  have h2 : TSS ({2, 4} : Finset ℕ) ppExcess = Real.log 2 ^ 2 / 2 := by
    unfold TSS
    rw [show ({2, 4} : Finset ℕ) = insert 2 ({4} : Finset ℕ) from rfl]
    rw [Finset.sum_insert (by decide), Finset.sum_singleton,
      Finset.sum_insert (by decide), Finset.sum_singleton, Finset.card_insert_of_notMem (by decide),
      Finset.card_singleton]
    rw [ppExcess_two, ppExcess_four]
    push_cast
    ring
  rw [h2, h3, add_zero]

/-- **An explicit, non-degenerate `ΔR²`.**  On the design `{2, 3, 4}` the prime-power
model beats the best base-only model by exactly `3/4`: the lift is strictly positive
(there is a radical collision) but strictly below the single-fibre maximum `1` (the
squarefree fibre `{3}` is explained by the base feature alone). -/
theorem deltaR2_D234 :
    R2 D234 ppExcess ppExcess
      - R2 D234 ppExcess (fun n => fibreMean D234 rad ppExcess (rad n)) = 3 / 4 := by
  have hlog : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  rw [deltaR2_eq_withinSS_div_TSS, withinSS_D234, TSS_D234]
  field_simp
  ring

end PPowMultiseed