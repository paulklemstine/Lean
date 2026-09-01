import Applications.MarginScarcityPortability

/-!
# Across blocks: the margin statistic correlates with damage, the norm does not

`Applications.MarginScarcityPortability` compared the two candidate predictors
of transplant damage *per block*.  This file compares them **across a family of
blocks**, which is the form in which the NET-54/NET-56 measurement is actually
read: one number per layer block, and a question about whether the ranking of
the blocks by predictor matches their ranking by measured damage.

Two results, of opposite type.

**A. A positive-correlation theorem for the margin screen.**  Write `dam b` for
the measured damage of block `b` and `pred b` for its margin-uncertified
fraction.  `margin_route_screens_damage` gives `dam b ≤ pred b`; suppose in
addition that the screen is *tight to `eta`*, i.e. `pred b ≤ dam b + eta`.
Then `famCov_margin_lower_bound` shows

  `cov(pred, dam) ≥ Var(dam) − (eta/2)·√Var(dam)`,

so the empirical covariance is strictly positive as soon as the damage spread
`√Var(dam)` exceeds `eta/2` (`margin_predictor_positively_correlated`).  The
proof is the Cauchy–Schwarz bound on covariances plus the Popoviciu-type
variance bound `famVar_le_of_range` for a slack confined to `[0, eta]`.

**B. An anti-correlation construction for the weight distance.**  No analogous
statement can hold for the norm predictor: `margin_predicts_norm_does_not`
exhibits an explicit two-block family — the dead-direction block of
`weight_distance_not_monotone` and its live-direction partner — for which

  `cov(margin predictor, damage) = 1/4 > 0`  while
  `cov(weight distance, damage) = −(D − d)/4 < 0`.

Same measurement, same blocks: the cheap forward-pass statistic orders the
blocks correctly and the weight-space distance orders them backwards.  This is
the sharpest possible form of the conjecture under test.

## Lab notes

Instantiating **A** at the two NET-54 arms (`dam = (0.4557, 0.1615)` for the
tail and bulk arms) gives `Var(dam) = 0.02164`, `√Var(dam) = 0.14710`, so the
covariance is certified positive for any screen slack `eta < 0.2942`.  The
measured margin scarcity of the tail arm saturates its screen exactly
(`net54_margin_scarcity`), i.e. `eta = 0` on that arm.
-/

namespace Catalog.Applications.MarginScarcityCorrelation

open Finset
open Catalog.Novelty.KVDecisionDissociation
open Catalog.Probability.TailTransplantGeometry
open Catalog.Probability.TailTransplantCost
open Catalog.Applications.MarginScarcityPortability

/-! ### 1. Empirical mean, covariance and variance across a family of blocks -/

/-- Empirical mean of a per-block statistic. -/
noncomputable def famMean {L : ℕ} (f : Fin L → ℝ) : ℝ := (∑ b, f b) / (L : ℝ)

/-- Empirical covariance of two per-block statistics. -/
noncomputable def famCov {L : ℕ} (f g : Fin L → ℝ) : ℝ :=
  (∑ b, (f b - famMean f) * (g b - famMean g)) / (L : ℝ)

/-- Empirical variance of a per-block statistic. -/
noncomputable def famVar {L : ℕ} (f : Fin L → ℝ) : ℝ := famCov f f

lemma famVar_eq {L : ℕ} (f : Fin L → ℝ) :
    famVar f = (∑ b, (f b - famMean f) ^ 2) / (L : ℝ) := by
  rw [famVar, famCov]
  congr 1
  exact Finset.sum_congr rfl (fun b _ => by ring)

lemma famVar_nonneg {L : ℕ} (f : Fin L → ℝ) : 0 ≤ famVar f := by
  rw [famVar_eq]
  positivity

lemma famCov_comm {L : ℕ} (f g : Fin L → ℝ) : famCov f g = famCov g f := by
  rw [famCov, famCov]
  congr 1
  exact Finset.sum_congr rfl (fun b _ => by ring)

lemma famMean_add {L : ℕ} (f g : Fin L → ℝ) :
    famMean (fun b => f b + g b) = famMean f + famMean g := by
  rw [famMean, famMean, famMean, ← add_div, Finset.sum_add_distrib]

/-- Covariance is additive in its first argument. -/
lemma famCov_add_left {L : ℕ} (f g h : Fin L → ℝ) :
    famCov (fun b => f b + g b) h = famCov f h + famCov g h := by
  rw [famCov, famCov, famCov, ← add_div, famMean_add, ← Finset.sum_add_distrib]
  congr 1
  exact Finset.sum_congr rfl (fun b _ => by ring)

/-- **Cauchy–Schwarz for the empirical covariance.** -/
lemma famCov_sq_le {L : ℕ} (f g : Fin L → ℝ) :
    famCov f g ^ 2 ≤ famVar f * famVar g := by
  rcases Nat.eq_zero_or_pos L with hL | hL
  · subst hL
    simp [famCov, famVar]
  have hLR : (0 : ℝ) < (L : ℝ) := by exact_mod_cast hL
  have hCS := Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset (Fin L))
    (fun b => f b - famMean f) (fun b => g b - famMean g)
  rw [famCov, famVar_eq, famVar_eq, div_pow]
  rw [div_mul_div_comm, ← pow_two]
  apply div_le_div_of_nonneg_right hCS
  positivity

/-- Absolute-value form of Cauchy–Schwarz for covariances. -/
lemma abs_famCov_le {L : ℕ} (f g : Fin L → ℝ) :
    |famCov f g| ≤ Real.sqrt (famVar f) * Real.sqrt (famVar g) := by
  have h := famCov_sq_le f g
  have hprod : Real.sqrt (famVar f) * Real.sqrt (famVar g)
      = Real.sqrt (famVar f * famVar g) :=
    (Real.sqrt_mul (famVar_nonneg f) _).symm
  rw [hprod]
  calc |famCov f g| = Real.sqrt (famCov f g ^ 2) := (Real.sqrt_sq_eq_abs _).symm
    _ ≤ Real.sqrt (famVar f * famVar g) := Real.sqrt_le_sqrt h

lemma famVar_eq_sub {L : ℕ} (f : Fin L → ℝ) (hL : 0 < L) :
    famVar f = (∑ b, f b ^ 2) / (L : ℝ) - famMean f ^ 2 := by
  have hLR : (0 : ℝ) < (L : ℝ) := by exact_mod_cast hL
  have hsum : ∑ b, f b = (L : ℝ) * famMean f := by
    rw [famMean, mul_div_cancel₀ _ hLR.ne']
  have hexpand : ∑ b, (f b - famMean f) ^ 2
      = (∑ b, f b ^ 2) - 2 * famMean f * (∑ b, f b) + (L : ℝ) * famMean f ^ 2 := by
    rw [Finset.sum_congr rfl (fun b _ =>
      show (f b - famMean f) ^ 2 = f b ^ 2 - 2 * famMean f * f b + famMean f ^ 2 by ring)]
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  rw [famVar_eq, hexpand, hsum]
  field_simp
  ring

/-- **Popoviciu-type bound.**  A statistic confined to `[0, eta]` has empirical
variance at most `eta² / 4`. -/
lemma famVar_le_of_range {L : ℕ} (e : Fin L → ℝ) (eta : ℝ)
    (h0 : ∀ b, 0 ≤ e b) (h1 : ∀ b, e b ≤ eta) : famVar e ≤ eta ^ 2 / 4 := by
  rcases Nat.eq_zero_or_pos L with hL | hL
  · subst hL
    have : (0 : ℝ) ≤ eta ^ 2 / 4 := by positivity
    simpa [famVar, famCov] using this
  have hLR : (0 : ℝ) < (L : ℝ) := by exact_mod_cast hL
  have hsq : ∑ b, e b ^ 2 ≤ eta * ∑ b, e b := by
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum (fun b _ => ?_)
    have := h0 b
    nlinarith [h1 b]
  have hmean : famMean e = (∑ b, e b) / (L : ℝ) := rfl
  have hkey : (∑ b, e b ^ 2) / (L : ℝ) ≤ eta * famMean e := by
    rw [hmean, mul_div_assoc']
    exact div_le_div_of_nonneg_right hsq hLR.le
  have hvar := famVar_eq_sub e hL
  have hm0 : 0 ≤ famMean e := by
    rw [hmean]
    exact div_nonneg (Finset.sum_nonneg (fun b _ => h0 b)) hLR.le
  nlinarith [sq_nonneg (famMean e - eta / 2)]

/-! ### 2. The margin screen correlates with the damage -/

/-- **Correlation theorem for the margin screen.**  If the per-block margin
predictor `pred` dominates the measured damage `dam` and overshoots it by at
most `eta`, then the empirical covariance across blocks is at least
`Var(dam) − (eta/2)·√Var(dam)`. -/
theorem famCov_margin_lower_bound {L : ℕ} (dam pred : Fin L → ℝ) (eta : ℝ)
    (hdom : ∀ b, dam b ≤ pred b) (htight : ∀ b, pred b ≤ dam b + eta) :
    famVar dam - (eta / 2) * Real.sqrt (famVar dam) ≤ famCov pred dam := by
  rcases Nat.eq_zero_or_pos L with hL | hL
  · subst hL
    simp [famCov, famVar, famMean]
  have heta : 0 ≤ eta := by
    have h1 := htight ⟨0, hL⟩
    have h2 := hdom ⟨0, hL⟩
    linarith
  set e : Fin L → ℝ := fun b => pred b - dam b with he
  have hsplit : (fun b => dam b + e b) = pred := by
    funext b; simp [he]
  have hcov : famCov pred dam = famVar dam + famCov e dam := by
    rw [← hsplit, famCov_add_left]
    rfl
  have he0 : ∀ b, 0 ≤ e b := fun b => by simp [he, sub_nonneg, hdom b]
  have he1 : ∀ b, e b ≤ eta := fun b => by
    have := htight b; simp only [he]; linarith
  have hvare : famVar e ≤ eta ^ 2 / 4 := famVar_le_of_range e eta he0 he1
  have hsqrt : Real.sqrt (famVar e) ≤ eta / 2 := by
    have h1 : Real.sqrt (famVar e) ≤ Real.sqrt (eta ^ 2 / 4) := Real.sqrt_le_sqrt hvare
    have h2 : Real.sqrt (eta ^ 2 / 4) = eta / 2 := by
      rw [show eta ^ 2 / 4 = (eta / 2) ^ 2 by ring, Real.sqrt_sq (by linarith)]
    linarith [h1, h2.le, h2.ge]
  have hbound : |famCov e dam| ≤ Real.sqrt (famVar e) * Real.sqrt (famVar dam) :=
    abs_famCov_le e dam
  have hlow : -((eta / 2) * Real.sqrt (famVar dam)) ≤ famCov e dam := by
    have h1 : -|famCov e dam| ≤ famCov e dam := neg_abs_le _
    have h2 : Real.sqrt (famVar e) * Real.sqrt (famVar dam)
        ≤ (eta / 2) * Real.sqrt (famVar dam) :=
      mul_le_mul_of_nonneg_right hsqrt (Real.sqrt_nonneg _)
    linarith
  linarith [hcov.ge, hcov.le]

/-- **The margin predictor is positively correlated with the damage** whenever
the spread of the measured damage across blocks exceeds half the screen slack.
This is the falsifiable cross-block prediction. -/
theorem margin_predictor_positively_correlated {L : ℕ} (hL : 0 < L)
    (dam pred : Fin L → ℝ) (eta : ℝ)
    (hdom : ∀ b, dam b ≤ pred b) (htight : ∀ b, pred b ≤ dam b + eta)
    (hspread : eta / 2 < Real.sqrt (famVar dam)) :
    0 < famCov pred dam := by
  have heta : 0 ≤ eta := by
    have h1 := htight ⟨0, hL⟩
    have h2 := hdom ⟨0, hL⟩
    linarith
  have hbase := famCov_margin_lower_bound dam pred eta hdom htight
  have hs : 0 ≤ Real.sqrt (famVar dam) := Real.sqrt_nonneg _
  have hsq : Real.sqrt (famVar dam) ^ 2 = famVar dam :=
    Real.sq_sqrt (famVar_nonneg dam)
  nlinarith [hbase, hsq, hspread, hs, heta]

/-! ### 3. Two blocks: the margin ranks them right, the norm ranks them backwards -/

/-- Empirical covariance of two-block statistics in closed form. -/
lemma famCov_two (a b c e : ℝ) :
    famCov ![a, b] ![c, e] = (a - b) * (c - e) / 4 := by
  simp [famCov, famMean, Fin.sum_univ_two]
  ring

variable {Ω : Type*} [Fintype Ω] [DecidableEq Ω]

open Classical in
omit [DecidableEq Ω] in
/-- The dead-direction block: a weight perturbation of size `D` that the
features cannot see.  Its margin predictor is `0` and its damage is `0`. -/
lemma dead_direction_block [Nonempty Ω] (D : ℝ) :
    uncertifiedFrac (fun x => blockLogit (![![1, 0], ![0, 0]] : Fin 2 → Fin 2 → ℝ) deadFeat x)
        (fun x => blockLogit (![![1, D], ![0, 0]] : Fin 2 → Fin 2 → ℝ) deadFeat x)
        (fun _ : Ω => 0) 0 = 0 ∧
      damageFrac (fun _ : Ω => (0 : Fin 2)) (fun _ => 0) = 0 := by
  classical
  constructor
  · have hempty : uncertifiedSet
        (fun x => blockLogit (![![1, 0], ![0, 0]] : Fin 2 → Fin 2 → ℝ) deadFeat x)
        (fun x => blockLogit (![![1, D], ![0, 0]] : Fin 2 → Fin 2 → ℝ) deadFeat x)
        (fun _ : Ω => 0) 0 = ∅ := by
      ext x
      simp only [uncertifiedSet, Finset.mem_filter, Finset.mem_univ, true_and,
        Finset.notMem_empty, iff_false, not_not]
      refine ⟨?_, ?_⟩
      · intro j hj
        fin_cases j
        · exact absurd rfl hj
        · simp only [blockLogit_deadFeat]
          norm_num
      · intro j
        fin_cases j <;> simp only [blockLogit_deadFeat] <;> norm_num
    simp [uncertifiedFrac, hempty]
  · have hempty : disagreeSet (fun _ : Ω => (0 : Fin 2)) (fun _ => 0) = ∅ := by
      ext x; simp [mem_disagreeSet]
    simp [damageFrac, hempty]

open Classical in
omit [DecidableEq Ω] in
/-- The live-direction block: a weight perturbation of size `d` (possibly far
smaller than `D`) straight along the feature direction.  Its margin predictor is
`1` and its damage is `1`. -/
lemma live_direction_block [Nonempty Ω] (d : ℝ) (hd : 0 < d) :
    uncertifiedFrac
        (fun x => blockLogit (![![d / 2, 0], ![-(d / 2), 0]] : Fin 2 → Fin 2 → ℝ) deadFeat x)
        (fun x => blockLogit (![![-(d / 2), 0], ![d / 2, 0]] : Fin 2 → Fin 2 → ℝ) deadFeat x)
        (fun _ : Ω => 0) 0 = 1 ∧
      damageFrac (fun _ : Ω => (1 : Fin 2)) (fun _ => 0) = 1 := by
  classical
  have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  constructor
  · have huniv : uncertifiedSet
        (fun x => blockLogit (![![d / 2, 0], ![-(d / 2), 0]] : Fin 2 → Fin 2 → ℝ) deadFeat x)
        (fun x => blockLogit (![![-(d / 2), 0], ![d / 2, 0]] : Fin 2 → Fin 2 → ℝ) deadFeat x)
        (fun _ : Ω => 0) 0 = Finset.univ := by
      ext x
      simp only [uncertifiedSet, Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
      intro hcert
      have h := hcert.2 0
      simp only [blockLogit_deadFeat, Matrix.cons_val_zero] at h
      rw [show d / 2 - -(d / 2) = d by ring, abs_of_pos hd] at h
      linarith
    rw [uncertifiedFrac, huniv, Finset.card_univ, div_self hN.ne']
  · have huniv : disagreeSet (fun _ : Ω => (1 : Fin 2)) (fun _ => 0) = Finset.univ := by
      ext x; simp [mem_disagreeSet]
    rw [damageFrac, huniv, Finset.card_univ, div_self hN.ne']

open Classical in
omit [DecidableEq Ω] in
/-- **The dissociation, across blocks.**  For any `0 < d < D` there is a
two-block family — same features, same architecture — on which

* the margin-uncertified fraction is `(0, 1)` and the measured damage is
  `(0, 1)`, so `cov(margin, damage) = 1/4 > 0`;
* the weight-space distances are `(D, d)` with `D > d`, so
  `cov(distance, damage) = −(D − d)/4 < 0`.

The cheap forward-pass statistic ranks the blocks by portability correctly; the
Lipschitz/norm distance ranks them exactly backwards.  Norm distance is
therefore not merely a loose predictor of transplant damage, it can be an
anti-predictor. -/
theorem margin_predicts_norm_does_not [Nonempty Ω] (d D : ℝ) (hd : 0 < d) (hdD : d < D) :
    ∃ (WA₀ WB₀ WA₁ WB₁ : Fin 2 → Fin 2 → ℝ) (dA₀ dB₀ dA₁ dB₁ : Ω → Fin 2),
      (∀ x, IsStrictTop (blockLogit WA₀ deadFeat x) (dA₀ x)) ∧
      (∀ x, IsStrictTop (blockLogit WB₀ deadFeat x) (dB₀ x)) ∧
      (∀ x, IsStrictTop (blockLogit WA₁ deadFeat x) (dA₁ x)) ∧
      (∀ x, IsStrictTop (blockLogit WB₁ deadFeat x) (dB₁ x)) ∧
      (∀ j i, |WA₀ j i - WB₀ j i| ≤ D) ∧ (∀ j i, |WA₁ j i - WB₁ j i| ≤ d) ∧
      famCov
        ![uncertifiedFrac (fun x => blockLogit WA₀ deadFeat x)
            (fun x => blockLogit WB₀ deadFeat x) dA₀ 0,
          uncertifiedFrac (fun x => blockLogit WA₁ deadFeat x)
            (fun x => blockLogit WB₁ deadFeat x) dA₁ 0]
        ![damageFrac dB₀ dA₀, damageFrac dB₁ dA₁] = 1 / 4 ∧
      famCov ![D, d] ![damageFrac dB₀ dA₀, damageFrac dB₁ dA₁] = -((D - d) / 4) := by
  classical
  have hD : 0 < D := lt_trans hd hdD
  obtain ⟨hu₀, hdam₀⟩ := dead_direction_block (Ω := Ω) D
  obtain ⟨hu₁, hdam₁⟩ := live_direction_block (Ω := Ω) d hd
  refine ⟨![![1, 0], ![0, 0]], ![![1, D], ![0, 0]],
    ![![d / 2, 0], ![-(d / 2), 0]], ![![-(d / 2), 0], ![d / 2, 0]],
    (fun _ => 0), (fun _ => 0), (fun _ => 0), (fun _ => 1), ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro x j hj
    fin_cases j
    · exact absurd rfl hj
    · simp [blockLogit_deadFeat]
  · intro x j hj
    fin_cases j
    · exact absurd rfl hj
    · simp [blockLogit_deadFeat]
  · intro x j hj
    fin_cases j
    · exact absurd rfl hj
    · rw [blockLogit_deadFeat, blockLogit_deadFeat]
      simp
      linarith
  · intro x j hj
    fin_cases j
    · rw [blockLogit_deadFeat, blockLogit_deadFeat]
      simp
      linarith
    · exact absurd rfl hj
  · intro j i
    fin_cases j <;> fin_cases i <;> rw [abs_le] <;> constructor <;> simp <;> linarith
  · intro j i
    fin_cases j <;> fin_cases i <;> rw [abs_le] <;> constructor <;> simp <;> linarith
  · rw [hu₀, hu₁, hdam₀, hdam₁, famCov_two]
    norm_num
  · rw [hdam₀, hdam₁, famCov_two]
    ring

end Catalog.Applications.MarginScarcityCorrelation