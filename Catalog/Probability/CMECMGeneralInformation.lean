/-
# CM-ECM-GENERAL: the information-theoretic half

Two probabilistic laws extracted from the CM-ECM-GENERAL experiment
(round 17 #2), both proved here and both tied back to the arithmetic of the
`j = 0` curve `y² = x³ + 1` formalised in `Probability.CMECMGeneralJ0`.

## (1) Rational-torsion degeneracy: a constant event carries exactly zero bits

For a finite sample `Ω` (in the experiment: a list of primes), a class label
`c : Ω → κ` (in the experiment: `p mod m`) and a Boolean observable
`E : Ω → Bool`, `empMI c E` is the empirical (plug-in) mutual information of the
pair.  `empMI_of_const` says that a *constant* observable has `empMI = 0`
**exactly**, not approximately.

Because `3 ∣ #E_{j0}(𝔽_p)` holds unconditionally for every prime `p > 3`
(`CMECMGeneral.three_dvd_curveCard_j0`), the `ℓ = 3` ECM-order event on the
`j = 0` curve is such a constant observable, whence

  `ecm_order_channel_zero_information :`
  `empMI c (fun ω => decide (3 ∣ cardJ0 (sample ω))) = 0`

for *every* sample of primes `> 3` and *every* class function `c` — the exact
`0.0000` measured in the experiment, now a theorem.  A fully residue-visible,
abelian, `p+1`-sourced congruence on the elliptic order can reveal zero bits:
the shadow is real only when the event is *conditional*.

## (2) The union-dilution law

The experiment measures a conditional-variation ("shadow") statistic of a union
event `A ∪ B` where `B` is a class-independent half.  Writing `a k = P(A | k)`
and `b = P(B)` (class independent, disjoint from `A`), the union has
`P(A ∪ B | k) = a k + b`.  The *numerator* (weighted conditional variance) is
unchanged by the shift (`wvar_add_const`), but the *normaliser* `μ(1-μ)` grows
as long as the base rate stays below `1/2`, so the normalised shadow can only
shrink:

  `union_dilution : eta2 w (a + b) ≤ eta2 w a`.

This is the field-independent mechanism behind "CM shadow ≤ inert-class OR
channel": the split-half base rate raises the union's unconditional probability
and compresses conditional variation.  `union_dilution_strict` shows the
inequality is strict as soon as `b > 0` and the channel is nondegenerate, and
`eta2_dilution_factor` gives the exact dilution factor `μ_A(1-μ_A)/μ_U(1-μ_U)`.
-/
import Mathlib
import Probability.CMECMGeneralJ0

namespace CMECMGeneralInfo

open Finset

/-! ## 1. Empirical mutual information on a finite sample -/

section MI

variable {Ω : Type*} [Fintype Ω] [DecidableEq Ω] {κ : Type*} [Fintype κ] [DecidableEq κ]

/-- Empirical joint probability of `{c = k}` and `{E = b}` under the counting
measure of the sample `Ω`. -/
noncomputable def joint (c : Ω → κ) (E : Ω → Bool) (k : κ) (b : Bool) : ℝ :=
  ((univ.filter fun ω => c ω = k ∧ E ω = b).card : ℝ) / (Fintype.card Ω : ℝ)

/-- Empirical probability of the class `{c = k}`. -/
noncomputable def margClass (c : Ω → κ) (k : κ) : ℝ :=
  ((univ.filter fun ω => c ω = k).card : ℝ) / (Fintype.card Ω : ℝ)

/-- Empirical probability of the event `{E = b}`. -/
noncomputable def margEvent (E : Ω → Bool) (b : Bool) : ℝ :=
  ((univ.filter fun ω => E ω = b).card : ℝ) / (Fintype.card Ω : ℝ)

/-- Empirical (plug-in) mutual information `I(c ; E)` of a class label and a
Boolean observable, with the usual `0 log 0 = 0` convention (automatic here,
since `Real.log` is total and the prefactor vanishes). -/
noncomputable def empMI (c : Ω → κ) (E : Ω → Bool) : ℝ :=
  ∑ k : κ, ∑ b : Bool,
    joint c E k b * Real.log (joint c E k b / (margClass c k * margEvent E b))

omit [DecidableEq Ω] in
/-- **Degeneracy law.**  A constant Boolean observable has *exactly* zero
empirical mutual information with every class label. -/
theorem empMI_of_const [Nonempty Ω] (c : Ω → κ) (E : Ω → Bool) (v : Bool)
    (hE : ∀ ω, E ω = v) : empMI c E = 0 := by
  classical
  have hN : (Fintype.card Ω : ℝ) ≠ 0 := by
    have : 0 < Fintype.card Ω := Fintype.card_pos
    positivity
  have hmarg : margEvent E v = 1 := by
    have hset : (univ.filter fun ω => E ω = v) = (univ : Finset Ω) := by
      apply filter_true_of_mem
      intro ω _
      exact hE ω
    rw [margEvent, hset, card_univ]
    field_simp
  have hjoint : ∀ k, joint c E k v = margClass c k := by
    intro k
    have hset : (univ.filter fun ω => c ω = k ∧ E ω = v)
        = (univ.filter fun ω => c ω = k) := by
      apply filter_congr
      intro ω _
      simp [hE ω]
    rw [joint, margClass, hset]
  have hzero : ∀ k, ∀ b : Bool, b ≠ v → joint c E k b = 0 := by
    intro k b hb
    have hset : (univ.filter fun ω => c ω = k ∧ E ω = b) = (∅ : Finset Ω) := by
      apply filter_false_of_mem
      intro ω _ hmem
      exact hb (by rw [← hmem.2, hE ω])
    rw [joint, hset]
    simp
  refine Finset.sum_eq_zero fun k _ => Finset.sum_eq_zero fun b _ => ?_
  by_cases hb : b = v
  · subst hb
    rw [hjoint k, hmarg, mul_one]
    by_cases hm : margClass c k = 0
    · rw [hm]; simp
    · rw [div_self hm, Real.log_one, mul_zero]
  · rw [hzero k b hb, zero_mul]

end MI

/-! ## 2. Bridge: the `ℓ = 3` ECM-order channel on the `j = 0` curve is silent -/

/-- A prime `> 3` (the good primes of the `j = 0` curve). -/
def PrimeGt3 : Type := {q : ℕ // q.Prime ∧ 3 < q}

/-- `#E_{j0}(𝔽_q)` for a prime `q > 3`. -/
def cardJ0 (q : PrimeGt3) : ℕ :=
  @ECMParity.curveCard q.1 ⟨q.2.1⟩ 0 1

/-- The unconditional divisibility, restated on `PrimeGt3`. -/
theorem three_dvd_cardJ0 (q : PrimeGt3) : 3 ∣ cardJ0 q := by
  obtain ⟨n, hn, hn3⟩ := q
  exact @CMECMGeneral.three_dvd_curveCard_j0 n ⟨hn⟩ (by omega) (by omega)

/-- **Rational-torsion degeneracy, information form.**  For *any* finite sample
of primes `> 3` and *any* class statistic, the `ℓ = 3` ECM-order event on the
`j = 0` curve carries exactly zero bits. -/
theorem ecm_order_channel_zero_information
    {Ω : Type*} [Fintype Ω] [DecidableEq Ω] [Nonempty Ω]
    {κ : Type*} [Fintype κ] [DecidableEq κ]
    (sample : Ω → PrimeGt3) (c : Ω → κ) :
    empMI c (fun ω => decide (3 ∣ cardJ0 (sample ω))) = 0 := by
  refine empMI_of_const c _ true (fun ω => ?_)
  simp [three_dvd_cardJ0 (sample ω)]

/-! ## 3. The union-dilution law -/

section Dilution

variable {κ : Type*} [Fintype κ] {w a : κ → ℝ} {b : ℝ}

/-- Weighted mean of a conditional-probability profile. -/
noncomputable def wmean (w a : κ → ℝ) : ℝ := ∑ k, w k * a k

/-- Weighted conditional variance of a profile (the "shadow" numerator). -/
noncomputable def wvar (w a : κ → ℝ) : ℝ := ∑ k, w k * (a k - wmean w a) ^ 2

/-- Normalised conditional variation (squared correlation ratio) of a binary
channel: the statistic the experiment reports. -/
noncomputable def eta2 (w a : κ → ℝ) : ℝ := wvar w a / (wmean w a * (1 - wmean w a))

theorem wmean_add_const (hw : ∑ k, w k = 1) (b : ℝ) :
    wmean w (fun k => a k + b) = wmean w a + b := by
  simp only [wmean, mul_add]
  rw [Finset.sum_add_distrib, ← Finset.sum_mul, hw, one_mul]

/-- **The numerator is shift-invariant**: mixing in a class-independent event
does not change the conditional variation. -/
theorem wvar_add_const (hw : ∑ k, w k = 1) (b : ℝ) :
    wvar w (fun k => a k + b) = wvar w a := by
  simp only [wvar, wmean_add_const hw b]
  refine Finset.sum_congr rfl fun k _ => ?_
  ring_nf

theorem wvar_nonneg (hw : ∀ k, 0 ≤ w k) : 0 ≤ wvar w a :=
  Finset.sum_nonneg fun k _ => mul_nonneg (hw k) (sq_nonneg _)

/-- The normaliser `μ(1-μ)` is increasing on `[0, 1/2]`. -/
theorem base_rate_mono {s t : ℝ} (hst : s ≤ t) (ht : t ≤ 1 / 2) :
    s * (1 - s) ≤ t * (1 - t) := by nlinarith

/-- **Union-dilution law.**  If the class-independent half `b` is mixed into the
event and the resulting base rate stays below `1/2`, the normalised conditional
variation can only shrink: the union channel is never stronger than the
conditional class channel it contains. -/
theorem union_dilution (hw : ∀ k, 0 ≤ w k) (hsum : ∑ k, w k = 1)
    (hb : 0 ≤ b) (hpos : 0 < wmean w a) (hhalf : wmean w a + b ≤ 1 / 2) :
    eta2 w (fun k => a k + b) ≤ eta2 w a := by
  have hden_a : 0 < wmean w a * (1 - wmean w a) := by
    have h1 : wmean w a ≤ 1 / 2 := by linarith
    nlinarith
  have hmono : wmean w a * (1 - wmean w a)
      ≤ (wmean w a + b) * (1 - (wmean w a + b)) :=
    base_rate_mono (by linarith) hhalf
  unfold eta2
  rw [wmean_add_const hsum, wvar_add_const hsum]
  exact div_le_div_of_nonneg_left (wvar_nonneg hw) hden_a hmono

/-- The dilution is *strict* as soon as the mixed-in half has positive
probability and the class channel is nondegenerate. -/
theorem union_dilution_strict (hsum : ∑ k, w k = 1)
    (hb : 0 < b) (hpos : 0 < wmean w a) (hhalf : wmean w a + b ≤ 1 / 2)
    (hvar : 0 < wvar w a) :
    eta2 w (fun k => a k + b) < eta2 w a := by
  have hden_a : 0 < wmean w a * (1 - wmean w a) := by
    have h1 : wmean w a ≤ 1 / 2 := by linarith
    nlinarith
  have hmono : wmean w a * (1 - wmean w a)
      < (wmean w a + b) * (1 - (wmean w a + b)) := by nlinarith
  unfold eta2
  rw [wmean_add_const hsum, wvar_add_const hsum]
  exact div_lt_div_of_pos_left hvar hden_a hmono

/-- The exact dilution factor: the union statistic equals the class statistic
times `μ_A(1-μ_A) / μ_U(1-μ_U)`. -/
theorem eta2_dilution_factor (hsum : ∑ k, w k = 1)
    (hpos : 0 < wmean w a) (hlt : wmean w a < 1)
    (hu : (wmean w a + b) * (1 - (wmean w a + b)) ≠ 0) :
    eta2 w (fun k => a k + b)
      = eta2 w a * ((wmean w a * (1 - wmean w a)) / ((wmean w a + b) * (1 - (wmean w a + b)))) := by
  have hden_a : wmean w a * (1 - wmean w a) ≠ 0 := by
    have : 0 < wmean w a * (1 - wmean w a) := by nlinarith
    exact ne_of_gt this
  have key : ∀ V A B : ℝ, A ≠ 0 → B ≠ 0 → V / B = V / A * (A / B) := by
    intro V A B hA hB; field_simp
  unfold eta2
  rw [wmean_add_const hsum, wvar_add_const hsum]
  exact key _ _ _ hden_a hu

end Dilution

end CMECMGeneralInfo