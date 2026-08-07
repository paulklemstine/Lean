import Novelty.BekensteinHawkingAreaLaw

/-!
# The projection constraint does not change the horizon entropy density

In the isolated-horizon microstate counting of
`Novelty.BekensteinHawkingAreaLaw`, a horizon configuration is a list of
punctures `(k, M)`, `k = 2j ≥ 1`, `M = 2m ∈ {-k, …, k}`.  Physically only the
configurations satisfying the *projection (Gauss) constraint* `∑ m = 0` are
admissible states of the quantum horizon.

This file proves that imposing this constraint leaves the entropy *density*
unchanged and costs at most a *logarithmic* correction in the area:

* `mem_horizonStates_iff` : the recursive definition of `horizonStates` really
  does enumerate all puncture configurations of a given total area;
* `hStatesProj_neg` : the projection distribution is symmetric, `D(n, -M) = D(n, M)`
  (proved by the puncture-wise magnetic-number flip involution);
* `hStatesProj_mul_le_singlet` : concatenating two horizons with opposite total
  projections produces a constrained horizon, giving
  `D(n, M) * D(m, -M) ≤ Z(n+m)`;
* `hStates_le_card_mul_hStatesProj` : a pigeonhole bound `W(n) ≤ (2n+1) · D(n,M)`
  for a suitable sector `M`;
* `hStates_sq_le_singlet` : combining the three previous points,
  `W(n)² ≤ (2n+1)² · Z(2n)` — the combinatorial heart of the argument;
* `hStatesSinglet_odd` : the constraint has no solutions in odd area (a parity
  superselection rule);
* `singlet_bounds` and `singlet_entropy_defect_le` : two-sided bounds
  `(2+√2)^{2n} / (4 (2n+1)²) ≤ Z(2n) ≤ (2+√2)^{2n}`, hence the entropy defect
  caused by the constraint is at most `log 4 + 2 log (2n+1)`, i.e. logarithmic
  in the horizon area;
* `singlet_entropy_area_law` : the constrained entropy obeys the same area law
  with the same density `log (2+√2)`.
-/

open Finset

namespace BekensteinHawking

/-- Total area (sum of spin labels) of a puncture configuration. -/
def areaOf (l : List (ℕ × ℤ)) : ℕ := (l.map Prod.fst).sum

/-- Total magnetic projection `∑ 2m` of a puncture configuration. -/
def projOf (l : List (ℕ × ℤ)) : ℤ := (l.map Prod.snd).sum

/-- A list of punctures is admissible: every spin label is `≥ 1` and every
magnetic number is admissible for its spin. -/
def IsHorizonConfig (l : List (ℕ × ℤ)) : Prop :=
  ∀ p ∈ l, 1 ≤ p.1 ∧ p.2 ∈ punctureLabels p.1

@[simp] lemma areaOf_nil : areaOf [] = 0 := rfl
@[simp] lemma projOf_nil : projOf [] = 0 := rfl
@[simp] lemma areaOf_cons (p : ℕ × ℤ) (l : List (ℕ × ℤ)) :
    areaOf (p :: l) = p.1 + areaOf l := rfl
@[simp] lemma projOf_cons (p : ℕ × ℤ) (l : List (ℕ × ℤ)) :
    projOf (p :: l) = p.2 + projOf l := rfl

lemma areaOf_append (l l' : List (ℕ × ℤ)) : areaOf (l ++ l') = areaOf l + areaOf l' := by
  simp [areaOf]

lemma projOf_append (l l' : List (ℕ × ℤ)) : projOf (l ++ l') = projOf l + projOf l' := by
  simp [projOf]

/-! ## Membership characterisation -/

lemma mem_punctureLabels_iff (k : ℕ) (M : ℤ) :
    M ∈ punctureLabels k ↔ (-(k : ℤ) ≤ M ∧ M ≤ k ∧ (M - k) % 2 = 0) := by
  simp only [punctureLabels, Finset.mem_image, Finset.mem_range]
  constructor
  · rintro ⟨i, hi, rfl⟩
    exact ⟨by omega, by omega, by omega⟩
  · rintro ⟨h1, h2, h3⟩
    exact ⟨((k : ℤ) - M).toNat / 2, by omega, by omega⟩

lemma neg_mem_punctureLabels {k : ℕ} {M : ℤ} (h : M ∈ punctureLabels k) :
    -M ∈ punctureLabels k := by
  rw [mem_punctureLabels_iff] at h ⊢
  omega

/-- The recursive definition of `horizonStates` enumerates exactly the
admissible puncture configurations of the given total area. -/
theorem mem_horizonStates_iff (n : ℕ) (l : List (ℕ × ℤ)) :
    l ∈ horizonStates n ↔ (IsHorizonConfig l ∧ areaOf l = n) := by
  induction n using Nat.strong_induction_on generalizing l with
  | _ n ih =>
    match n with
    | 0 =>
      rw [horizonStates]
      simp only [Finset.mem_singleton]
      constructor
      · rintro rfl; exact ⟨by simp [IsHorizonConfig], rfl⟩
      · rintro ⟨hc, ha⟩
        cases l with
        | nil => rfl
        | cons p t =>
          exfalso
          have := (hc p (by simp)).1
          simp only [areaOf_cons] at ha
          omega
    | (n + 1) =>
      rw [horizonStates]
      simp only [Finset.mem_biUnion, Finset.mem_image, Finset.mem_range]
      constructor
      · rintro ⟨i, hi, M, hM, l', hl', rfl⟩
        have hrec := (ih (n - i) (by omega) l').mp hl'
        refine ⟨?_, ?_⟩
        · intro p hp
          rcases List.mem_cons.mp hp with rfl | hp'
          · exact ⟨by omega, hM⟩
          · exact hrec.1 p hp'
        · simp only [areaOf_cons]
          have h2 := hrec.2
          omega
      · rintro ⟨hc, ha⟩
        cases l with
        | nil => simp [areaOf] at ha
        | cons p t =>
          obtain ⟨hk, hM⟩ := hc p (by simp)
          simp only [areaOf_cons] at ha
          refine ⟨p.1 - 1, by omega, p.2, ?_, t, ?_, ?_⟩
          · have h : p.1 - 1 + 1 = p.1 := by omega
            rw [h]; exact hM
          · exact (ih (n - (p.1 - 1)) (by omega) t).mpr
              ⟨fun q hq => hc q (by simp [hq]), by omega⟩
          · have h : p.1 - 1 + 1 = p.1 := by omega
            rw [h]

lemma isHorizonConfig_of_mem {n : ℕ} {l : List (ℕ × ℤ)} (h : l ∈ horizonStates n) :
    IsHorizonConfig l := ((mem_horizonStates_iff n l).mp h).1

lemma areaOf_of_mem {n : ℕ} {l : List (ℕ × ℤ)} (h : l ∈ horizonStates n) :
    areaOf l = n := ((mem_horizonStates_iff n l).mp h).2

/-- An admissible configuration of zero area is empty (every puncture carries at
least one area quantum). -/
lemma eq_nil_of_areaOf_zero {l : List (ℕ × ℤ)} (hc : IsHorizonConfig l) (h : areaOf l = 0) :
    l = [] := by
  cases l with
  | nil => rfl
  | cons p t =>
    exfalso
    have := (hc p (by simp)).1
    simp only [areaOf_cons] at h
    omega

/-- The total projection is bounded by the area. -/
lemma abs_projOf_le {l : List (ℕ × ℤ)} (hc : IsHorizonConfig l) :
    |projOf l| ≤ (areaOf l : ℤ) := by
  induction l with
  | nil => simp
  | cons p t ih =>
    have hp := hc p (by simp)
    have ht : IsHorizonConfig t := fun q hq => hc q (by simp [hq])
    have h1 := (mem_punctureLabels_iff p.1 p.2).mp hp.2
    have h2 := ih ht
    simp only [areaOf_cons, projOf_cons, Nat.cast_add]
    have := abs_le.mp h2
    rw [abs_le]
    constructor <;> [linarith [h1.1, h1.2.1]; linarith [h1.1, h1.2.1]]

/-! ## The constrained (projection-zero) count -/

/-- Number of horizon configurations of area `n` and total projection `M`. -/
noncomputable def hStatesProj (n : ℕ) (M : ℤ) : ℕ :=
  ((horizonStates n).filter (fun l => projOf l = M)).card

/-- Number of *physical* horizon states of area `n`: those obeying the
projection constraint `∑ m = 0`. -/
noncomputable def hStatesSinglet (n : ℕ) : ℕ := hStatesProj n 0

lemma hStatesProj_le (n : ℕ) (M : ℤ) : hStatesProj n M ≤ hStates n :=
  Finset.card_filter_le _ _

/-- Flipping every magnetic number. -/
def flipProj (l : List (ℕ × ℤ)) : List (ℕ × ℤ) := l.map (fun p => (p.1, -p.2))

@[simp] lemma flipProj_flipProj (l : List (ℕ × ℤ)) : flipProj (flipProj l) = l := by
  induction l with
  | nil => rfl
  | cons p t ih => simp [flipProj] at ih ⊢; exact ih

@[simp] lemma areaOf_flipProj (l : List (ℕ × ℤ)) : areaOf (flipProj l) = areaOf l := by
  induction l with
  | nil => rfl
  | cons p t ih => simp [areaOf, flipProj] at ih ⊢; omega

@[simp] lemma projOf_flipProj (l : List (ℕ × ℤ)) : projOf (flipProj l) = -projOf l := by
  induction l with
  | nil => rfl
  | cons p t ih => simp [projOf, flipProj] at ih ⊢; omega

lemma isHorizonConfig_flipProj {l : List (ℕ × ℤ)} (hc : IsHorizonConfig l) :
    IsHorizonConfig (flipProj l) := by
  intro p hp
  simp only [flipProj, List.mem_map] at hp
  obtain ⟨q, hq, rfl⟩ := hp
  exact ⟨(hc q hq).1, neg_mem_punctureLabels (hc q hq).2⟩

lemma flipProj_mem {n : ℕ} {l : List (ℕ × ℤ)} (h : l ∈ horizonStates n) :
    flipProj l ∈ horizonStates n := by
  rw [mem_horizonStates_iff] at h ⊢
  exact ⟨isHorizonConfig_flipProj h.1, by simpa using h.2⟩

/-- The projection distribution of the horizon is symmetric. -/
theorem hStatesProj_neg (n : ℕ) (M : ℤ) : hStatesProj n (-M) = hStatesProj n M := by
  unfold hStatesProj
  refine Finset.card_nbij' flipProj flipProj ?_ ?_ ?_ ?_
  · intro l hl
    simp only [Finset.mem_coe, Finset.mem_filter] at hl ⊢
    exact ⟨flipProj_mem hl.1, by rw [projOf_flipProj, hl.2]; ring⟩
  · intro l hl
    simp only [Finset.mem_coe, Finset.mem_filter] at hl ⊢
    exact ⟨flipProj_mem hl.1, by rw [projOf_flipProj, hl.2]⟩
  · intro l _; simp
  · intro l _; simp

/-! ## Concatenation of horizons -/

lemma append_left_inj {l₁ l₁' l₂ l₂' : List (ℕ × ℤ)}
    (h₁ : IsHorizonConfig l₁) (h₁' : IsHorizonConfig l₁')
    (harea : areaOf l₁ = areaOf l₁') (h : l₁ ++ l₂ = l₁' ++ l₂') :
    l₁ = l₁' ∧ l₂ = l₂' := by
  rcases List.append_eq_append_iff.mp h with ⟨a, rfl, rfl⟩ | ⟨c, rfl, rfl⟩
  · have hca : IsHorizonConfig a := by
      intro p hp; exact h₁' p (by simp [hp])
    have : areaOf a = 0 := by
      rw [areaOf_append] at harea; omega
    rw [eq_nil_of_areaOf_zero hca this]
    simp
  · have hcc : IsHorizonConfig c := by
      intro p hp; exact h₁ p (by simp [hp])
    have : areaOf c = 0 := by
      rw [areaOf_append] at harea; omega
    rw [eq_nil_of_areaOf_zero hcc this]
    simp

/-- Concatenating a horizon of projection `M` with one of projection `-M`
produces a physical (projection-zero) horizon. -/
theorem hStatesProj_mul_le_singlet (n m : ℕ) (M : ℤ) :
    hStatesProj n M * hStatesProj m (-M) ≤ hStatesSinglet (n + m) := by
  classical
  have hcard : (((horizonStates n).filter (fun l => projOf l = M)) ×ˢ
      ((horizonStates m).filter (fun l => projOf l = -M))).card
      = hStatesProj n M * hStatesProj m (-M) := Finset.card_product _ _
  rw [← hcard, hStatesSinglet, hStatesProj]
  refine Finset.card_le_card_of_injOn (fun p => p.1 ++ p.2) ?_ ?_
  · rintro ⟨l₁, l₂⟩ hp
    simp only [Finset.mem_coe, Finset.mem_product, Finset.mem_filter] at hp ⊢
    obtain ⟨⟨hl₁, hp₁⟩, ⟨hl₂, hp₂⟩⟩ := hp
    refine ⟨?_, ?_⟩
    · rw [mem_horizonStates_iff]
      refine ⟨?_, ?_⟩
      · intro p hp
        rcases List.mem_append.mp hp with h | h
        · exact isHorizonConfig_of_mem hl₁ p h
        · exact isHorizonConfig_of_mem hl₂ p h
      · rw [areaOf_append, areaOf_of_mem hl₁, areaOf_of_mem hl₂]
    · rw [projOf_append, hp₁, hp₂]; ring
  · rintro ⟨l₁, l₂⟩ hp ⟨l₁', l₂'⟩ hp' heq
    simp only [Finset.mem_coe, Finset.mem_product, Finset.mem_filter] at hp hp'
    have hkey := append_left_inj (isHorizonConfig_of_mem hp.1.1)
      (isHorizonConfig_of_mem hp'.1.1)
      (by rw [areaOf_of_mem hp.1.1, areaOf_of_mem hp'.1.1]) heq
    simp only [Prod.mk.injEq]
    exact ⟨hkey.1, hkey.2⟩

/-! ## Pigeonhole in the projection sectors -/

lemma card_Icc_proj (n : ℕ) : (Finset.Icc (-(n : ℤ)) n).card = 2 * n + 1 := by
  rw [Int.card_Icc]
  omega

/-- Pigeonhole: some projection sector contains at least a `1/(2n+1)` fraction
of all configurations of area `n`. -/
theorem hStates_le_card_mul_hStatesProj (n : ℕ) :
    ∃ M : ℤ, hStates n ≤ (2 * n + 1) * hStatesProj n M := by
  classical
  have hmaps : ∀ l ∈ horizonStates n, projOf l ∈ Finset.Icc (-(n : ℤ)) (n : ℤ) := by
    intro l hl
    have h := abs_projOf_le (isHorizonConfig_of_mem hl)
    rw [areaOf_of_mem hl] at h
    have := abs_le.mp h
    simp only [Finset.mem_Icc]
    exact ⟨this.1, this.2⟩
  have hsum : hStates n
      = ∑ M ∈ Finset.Icc (-(n : ℤ)) (n : ℤ),
          ((horizonStates n).filter (fun l => projOf l = M)).card :=
    Finset.card_eq_sum_card_fiberwise hmaps
  obtain ⟨M, hM, hmax⟩ := Finset.exists_max_image (Finset.Icc (-(n : ℤ)) (n : ℤ))
    (fun M => ((horizonStates n).filter (fun l => projOf l = M)).card)
    ⟨0, by simp only [Finset.mem_Icc]; omega⟩
  refine ⟨M, ?_⟩
  calc hStates n = ∑ M' ∈ Finset.Icc (-(n : ℤ)) (n : ℤ),
        ((horizonStates n).filter (fun l => projOf l = M')).card := hsum
    _ ≤ ∑ _M' ∈ Finset.Icc (-(n : ℤ)) (n : ℤ),
        ((horizonStates n).filter (fun l => projOf l = M)).card :=
        Finset.sum_le_sum (fun M' hM' => hmax M' hM')
    _ = (2 * n + 1) * hStatesProj n M := by
        rw [Finset.sum_const, card_Icc_proj, smul_eq_mul]; rfl

/-- **Combinatorial heart.**  The constrained count in area `2n` dominates the
square of the unconstrained count in area `n`, up to a quadratic factor. -/
theorem hStates_sq_le_singlet (n : ℕ) :
    hStates n * hStates n ≤ (2 * n + 1) ^ 2 * hStatesSinglet (2 * n) := by
  obtain ⟨M, hM⟩ := hStates_le_card_mul_hStatesProj n
  have hconcat : hStatesProj n M * hStatesProj n (-M) ≤ hStatesSinglet (n + n) :=
    hStatesProj_mul_le_singlet n n M
  rw [hStatesProj_neg] at hconcat
  have h2n : n + n = 2 * n := by ring
  rw [h2n] at hconcat
  calc hStates n * hStates n
      ≤ ((2 * n + 1) * hStatesProj n M) * ((2 * n + 1) * hStatesProj n M) :=
        Nat.mul_le_mul hM hM
    _ = (2 * n + 1) ^ 2 * (hStatesProj n M * hStatesProj n M) := by ring
    _ ≤ (2 * n + 1) ^ 2 * hStatesSinglet (2 * n) := Nat.mul_le_mul_left _ hconcat

/-! ## Parity superselection -/

lemma projOf_parity {n : ℕ} {l : List (ℕ × ℤ)} (hl : l ∈ horizonStates n) :
    (projOf l - n) % 2 = 0 := by
  have hc := isHorizonConfig_of_mem hl
  have ha := areaOf_of_mem hl
  subst ha
  clear hl
  induction l with
  | nil => simp
  | cons p t ih =>
    have hp := (mem_punctureLabels_iff p.1 p.2).mp (hc p (by simp)).2
    have ht : IsHorizonConfig t := fun q hq => hc q (by simp [hq])
    have := ih ht
    simp only [areaOf_cons, projOf_cons, Nat.cast_add] at *
    omega

/-- In odd area no configuration satisfies the projection constraint: a parity
superselection rule for the quantum horizon. -/
theorem hStatesSinglet_odd (n : ℕ) : hStatesSinglet (2 * n + 1) = 0 := by
  unfold hStatesSinglet hStatesProj
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro l hl h0
  have := projOf_parity hl
  rw [h0] at this
  push_cast at this
  omega

/-! ## The area law survives the constraint -/

/-- Two-sided bounds for the constrained microstate count. -/
theorem singlet_bounds (n : ℕ) (hn : 1 ≤ n) :
    growth ^ (2 * n) / (4 * (2 * n + 1) ^ 2) ≤ (hStatesSinglet (2 * n) : ℝ)
      ∧ (hStatesSinglet (2 * n) : ℝ) ≤ growth ^ (2 * n) := by
  obtain ⟨hlow, hupp⟩ := hStates_bounds n hn
  obtain ⟨_, hupp2⟩ := hStates_bounds (2 * n) (by omega)
  have hkey : (hStates n : ℝ) * hStates n ≤ ((2 * n + 1) : ℝ) ^ 2 * hStatesSinglet (2 * n) := by
    exact_mod_cast hStates_sq_le_singlet n
  have hpow : growth ^ (2 * n) = (growth ^ n) ^ 2 := by
    rw [← pow_mul, mul_comm]
  have hgpos : (0:ℝ) < growth ^ n := pow_pos growth_pos n
  have hcard : (0:ℝ) < ((2 * n + 1) : ℝ) ^ 2 := by positivity
  constructor
  · rw [div_le_iff₀ (by positivity), hpow]
    nlinarith
  · calc (hStatesSinglet (2 * n) : ℝ) ≤ (hStates (2 * n) : ℝ) := by
          exact_mod_cast hStatesProj_le (2 * n) 0
      _ ≤ growth ^ (2 * n) := hupp2

/-- The entropy defect caused by the projection constraint is nonnegative and at
most logarithmic in the horizon area. -/
theorem singlet_entropy_defect_le (n : ℕ) (hn : 1 ≤ n) :
    0 ≤ (2 * n : ℝ) * entropyDensity - Real.log (hStatesSinglet (2 * n))
      ∧ (2 * n : ℝ) * entropyDensity - Real.log (hStatesSinglet (2 * n))
          ≤ Real.log 4 + 2 * Real.log (2 * n + 1) := by
  obtain ⟨hlow, hupp⟩ := singlet_bounds n hn
  have hgpos : (0:ℝ) < growth ^ (2 * n) := pow_pos growth_pos _
  have hden : (0:ℝ) < 4 * (2 * n + 1) ^ 2 := by positivity
  have hZpos : (0:ℝ) < (hStatesSinglet (2 * n) : ℝ) := lt_of_lt_of_le (by positivity) hlow
  have hlogpow : Real.log (growth ^ (2 * n)) = (2 * n : ℝ) * entropyDensity := by
    rw [Real.log_pow]; push_cast; rfl
  constructor
  · have := Real.log_le_log hZpos hupp
    rw [hlogpow] at this
    linarith
  · have h := Real.log_le_log (by positivity) hlow
    rw [Real.log_div (ne_of_gt hgpos) (ne_of_gt hden), hlogpow, Real.log_mul (by norm_num)
      (by positivity), Real.log_pow] at h
    push_cast at h
    linarith

/-- `log n / n → 0`. -/
lemma tendsto_log_div_nat : Filter.Tendsto (fun n : ℕ => Real.log n / n) Filter.atTop (nhds 0) := by
  have h := Real.tendsto_pow_log_div_mul_add_atTop 1 0 1 one_ne_zero
  have := h.comp tendsto_natCast_atTop_atTop (α := ℕ)
  simpa [Function.comp] using this

/-- **The projection constraint does not change the entropy density.** -/
theorem singlet_entropy_area_law :
    Filter.Tendsto (fun n : ℕ => Real.log (hStatesSinglet (2 * n)) / (2 * n))
      Filter.atTop (nhds entropyDensity) := by
  rw [← tendsto_sub_nhds_zero_iff]
  apply squeeze_zero_norm' (a := fun n : ℕ => (Real.log 4 + 2 * Real.log 3) / (2 * n)
      + Real.log n / n)
  · filter_upwards [Filter.eventually_ge_atTop 1] with n hn
    have hnpos : (0:ℝ) < n := by exact_mod_cast hn
    have hn1 : (1:ℝ) ≤ n := by exact_mod_cast hn
    obtain ⟨h0, h1⟩ := singlet_entropy_defect_le n hn
    have hlog3 : Real.log (2 * (n:ℝ) + 1) ≤ Real.log 3 + Real.log n := by
      have h3 : (2 * (n:ℝ) + 1) ≤ 3 * n := by linarith
      calc Real.log (2 * (n:ℝ) + 1) ≤ Real.log (3 * n) := Real.log_le_log (by linarith) h3
        _ = Real.log 3 + Real.log n := Real.log_mul (by norm_num) (ne_of_gt hnpos)
    have hsub : Real.log (hStatesSinglet (2 * n)) / (2 * n) - entropyDensity
        = -(((2 * n : ℝ) * entropyDensity - Real.log (hStatesSinglet (2 * n))) / (2 * n)) := by
      field_simp
      ring
    rw [Real.norm_eq_abs, hsub, abs_neg, abs_of_nonneg (by positivity)]
    rw [div_le_iff₀ (by positivity)]
    have hpos2 : (0:ℝ) < 2 * n := by linarith
    have hexp : ((Real.log 4 + 2 * Real.log 3) / (2 * n) + Real.log n / n) * (2 * n)
        = (Real.log 4 + 2 * Real.log 3) + 2 * Real.log n := by
      field_simp
    rw [hexp]
    linarith
  · have h1 : Filter.Tendsto (fun n : ℕ => (Real.log 4 + 2 * Real.log 3) / (2 * (n:ℝ)))
        Filter.atTop (nhds 0) := by
      have := tendsto_const_div_atTop_nhds_zero_nat ((Real.log 4 + 2 * Real.log 3) / 2)
      refine this.congr ?_
      intro n
      exact div_div _ _ _
    have := h1.add tendsto_log_div_nat
    simpa using this

end BekensteinHawking