import Shared.AttentionBudgetSummability

/-!
# Cycle 4: a measurement protocol for the attention budget — tail fit, energy floor,
and error propagation

Cycles 1–3 (`Shared.AttentionBudgetKnee`, `Shared.AttentionBudgetScaling`,
`Shared.AttentionBudgetSummability`) established *qualitative* facts about the knee
`k*`: geometric decay gives a context-independent budget, exact flatness is false, and
context stability is equivalent to summability of the sorted attention profile.  None of
them is a *deployable* protocol: they certify existence of a budget, not a number one can
report with error bars.

This cycle builds the protocol.  It has three components.

1. **The energy floor (a lower certificate).**  Writing `M(k) = retained w n k` for the
   retained mass and `E = energy w n = ∑ᵢ pᵢ²` for the ℓ²-energy (collision probability)
   of the normalised profile, Cauchy–Schwarz gives `M(k)² ≤ k · E`, hence the two-sided
   sandwich
   `g² / E ≤ k*(n, g) ≤ n`   (`budget_sandwich`).
   Equivalently `k* ≥ g² · exp(H₂)` where `H₂ = -log E` is the Rényi-2 (collision)
   entropy (`kstar_ge_gate_sq_mul_exp_collisionEntropy`): the *floor* of the budget is an
   entropy exponential, but it must be the **collision** entropy.  Substituting the
   Hartley entropy `log n` (i.e. using the support size) produces a false floor
   (`hartley_floor_refuted`): a 17-key spike profile has `k* = 1` while `g² n = 17/4`.
   This is the precise sense in which "entropy alone cannot certify a budget".

2. **The tail fit (an upper certificate).**  `TailFit C r w` is the fitted law
   `1 - M(k) ≤ C rᵏ`.  A fit yields the explicit reportable budget
   `budgetOfFit C r τ = max ⌈log((1-τ)/C) / log r⌉₊ 1` (`kstar_le_budgetOfFit`), and every
   geometrically decaying profile admits the fit `(1/(1-r), r)`
   (`tailFit_of_geometric_decay`), so the cycle-1 estimate is the special case of a
   measured fit.

3. **Uncertainty propagation.**  The certified budget is *monotone in the fit box*
   (`budgetOfFit_mono`): the upper corner `(C⁺, r⁺)` of a confidence box certifies the
   budget for every parameter pair inside it (`kstar_le_budgetOfFit_of_box`).  On the data
   side, a two-point fit `r̂ = (t₂/t₁)^{1/d}` is exact on a true geometric tail
   (`fitRatio_exact`) and its multiplicative error is the `d`-th root of the data error
   (`fitRatio_error_bound`), so any target precision is reachable purely by increasing the
   probe separation `d` (`fit_precision_of_probe_separation`).  Finally the two
   certificates must be consistent: an admissible fit can never certify a budget below the
   energy floor (`energy_floor_le_budgetOfFit`), which turns the floor into a *falsifier*
   of a reported fit (`tailFit_refuted_of_budget_below_floor`).

The capstone `measurement_protocol` packages the report: lower bound `g²/E`, upper bound
`n`, and the fitted budget `budgetOfFit C⁺ r⁺ τ` from the worst corner of the fit box.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 4, ranked):
 (H12) The budget has a *lower* certificate computable from one scalar statistic of the
       profile, and that statistic is the ℓ²-energy, not the Shannon entropy.   [BOLD]
 (H13) The correct entropy in the floor `g² e^H` is the Rényi-2 entropy; using the
       Hartley entropy `log n` (support size) is unsound.                       [BOLD]
 (H14) Fit uncertainty propagates monotonically: the certified budget is monotone in
       both fitted parameters, so a confidence box maps onto a budget interval.
 (H15) Multiplicative data error on the tail measurements is damped like the `d`-th
       root in the fitted ratio, so probe separation buys precision for free. [BOLD]
 (H16) The floor and the fit are not independent: any admissible fit obeys the energy
       floor, giving a cheap falsification test for a reported `(C, r)`.

Experimenter: H12 = `budget_sandwich`; H13 = `kstar_ge_gate_sq_mul_exp_collisionEntropy`
together with the explicit refutation `hartley_floor_refuted` (spike profile
`w = (16, 1, …, 1)` on `n = 17`: `E = 17/64`, energy floor `16/17 ≤ 1 = k*`, Hartley
floor `17/4 > 1 = k*`); H14 = `budgetOfFit_mono` + `kstar_le_budgetOfFit_of_box`;
H15 = `fitRatio_error_bound` + `fit_precision_of_probe_separation`;
H16 = `energy_floor_le_budgetOfFit` + `tailFit_refuted_of_budget_below_floor`.
All proved with zero sorries.

Analyst: the structural reason a *quadratic* gate factor appears in `g²/E` is that
Cauchy–Schwarz is applied to the head sum, which costs a square; on the flat profile the
floor `g² n` versus the true knee `≈ g n` shows the loss is exactly the factor `g`, and
the bound becomes *sharp* at `g = 1` (`budget_sandwich_sharp_uniform`).  So the floor is
tight in the regime that matters for deployment (gates near `1`, e.g. `0.98`).

Critic: `energy_le_one` and `energy_pos` confirm the floor is never vacuous and never
exceeds the trivial ceiling.  The hypothesis `0 < C` in the fit theorems is load-bearing
(`C = 0` would force zero tail at `k = 0`, which fails whenever `n ≥ 1`), and `r < 1` is
load-bearing (at `r = 1` the log denominator vanishes).  `hartley_floor_refuted` is a
genuine counterexample, not a corner case: the gate `1/2` is interior and the profile is
a plain spike.
-/

namespace AttentionBudget

open Finset

/-! ## 1. Tail mass: the measured quantity `1 - M(k)` -/

/-- The discarded mass `1 - M(k)` of a top-`k` truncation: the quantity that the tail
exponent fit `1 - M(k) ≤ C rᵏ` models. -/
noncomputable def tailMass (w : ℕ → ℝ) (n k : ℕ) : ℝ := 1 - retained w n k

section TailBasic

variable {w : ℕ → ℝ} {n k : ℕ} (hw : ∀ i, 0 < w i)

include hw

lemma tailMass_nonneg (hn : 0 < n) : 0 ≤ tailMass w n k := by
  have := retained_le_one hw n k hn
  simp only [tailMass]; linarith

lemma tailMass_le_one : tailMass w n k ≤ 1 := by
  have := retained_nonneg hw (w := w) n k
  simp only [tailMass]; linarith

/-- More budget discards less mass. -/
lemma tailMass_antitone {a b : ℕ} (hab : a ≤ b) : tailMass w n b ≤ tailMass w n a := by
  have := retained_mono hw n hab
  simp only [tailMass]; linarith

/-- Beyond the context length nothing is discarded. -/
lemma tailMass_eq_zero_of_context_le (hn : 0 < n) (h : n ≤ k) : tailMass w n k = 0 := by
  have hmin : min k n = n := min_eq_right h
  simp [tailMass, retained, hmin, div_self (headMass_pos hw hn).ne']

end TailBasic

/-! ## 2. The energy floor -/

/-- The ℓ²-energy (collision probability) of the normalised attention profile on a
context of length `n`. -/
noncomputable def energy (w : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ i ∈ range n, (w i / headMass w n) ^ 2

/-- The Rényi-2 (collision) entropy of the normalised attention profile. -/
noncomputable def collisionEntropy (w : ℕ → ℝ) (n : ℕ) : ℝ := -Real.log (energy w n)

section Energy

variable {w : ℕ → ℝ} {n k : ℕ} {g : ℝ} (hw : ∀ i, 0 < w i)

include hw

lemma sum_normalised (hn : 0 < n) : ∑ i ∈ range n, w i / headMass w n = 1 := by
  rw [← Finset.sum_div]
  exact div_self (headMass_pos hw hn).ne'

lemma energy_pos (hn : 0 < n) : 0 < energy w n := by
  refine Finset.sum_pos (fun i _ => ?_) ⟨0, mem_range.mpr hn⟩
  have := hw i
  have hS := headMass_pos hw hn
  positivity

omit hw in
lemma energy_nonneg : 0 ≤ energy w n :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- The energy of a probability profile never exceeds `1`. -/
lemma energy_le_one (hn : 0 < n) : energy w n ≤ 1 := by
  have hS := headMass_pos hw hn
  have hterm : ∀ i ∈ range n, (w i / headMass w n) ^ 2 ≤ w i / headMass w n := by
    intro i hi
    have hle : w i ≤ headMass w n := by
      have : headMass w (i + 1) ≤ headMass w n :=
        headMass_mono hw (Nat.succ_le_of_lt (mem_range.mp hi))
      have hexp : headMass w (i + 1) = headMass w i + w i := by
        simp [headMass, Finset.sum_range_succ]
      have := headMass_nonneg hw i
      linarith
    have h1 : w i / headMass w n ≤ 1 := (div_le_one hS).mpr hle
    have h0 : 0 ≤ w i / headMass w n := le_of_lt (div_pos (hw i) hS)
    nlinarith
  calc energy w n ≤ ∑ i ∈ range n, w i / headMass w n := Finset.sum_le_sum hterm
    _ = 1 := sum_normalised hw hn

omit hw in
/-- The retained mass as a sum of normalised weights. -/
lemma retained_eq_sum :
    retained w n k = ∑ i ∈ range (min k n), w i / headMass w n := by
  rw [retained, headMass, Finset.sum_div]

/-- **Cauchy–Schwarz for the head sum.**  The retained mass of a top-`k` truncation is
controlled by the energy: `M(k)² ≤ k · E`. -/
theorem sq_retained_le_mul_energy (hn : 0 < n) :
    (retained w n k) ^ 2 ≤ (k : ℝ) * energy w n := by
  have hS := headMass_pos hw hn
  set p : ℕ → ℝ := fun i => w i / headMass w n with hp
  have hcs : (∑ i ∈ range (min k n), p i) ^ 2
      ≤ ((range (min k n)).card : ℝ) * ∑ i ∈ range (min k n), p i ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have hcard : ((range (min k n)).card : ℝ) = (min k n : ℝ) := by simp
  have hsubset : range (min k n) ⊆ range n :=
    Finset.range_subset_range.2 (min_le_right k n)
  have hsub : ∑ i ∈ range (min k n), p i ^ 2 ≤ energy w n :=
    Finset.sum_le_sum_of_subset_of_nonneg hsubset fun i _ _ => sq_nonneg _
  have hminle : (min k n : ℝ) ≤ (k : ℝ) := by exact_mod_cast min_le_left k n
  have hminnn : (0 : ℝ) ≤ (min k n : ℝ) := by positivity
  have hEnn : 0 ≤ energy w n := energy_nonneg (w := w) (n := n)
  rw [retained_eq_sum (w := w) (n := n) (k := k)]
  calc (∑ i ∈ range (min k n), p i) ^ 2
      ≤ (min k n : ℝ) * ∑ i ∈ range (min k n), p i ^ 2 := by rw [hcard] at hcs; exact hcs
    _ ≤ (min k n : ℝ) * energy w n := by nlinarith
    _ ≤ (k : ℝ) * energy w n := by nlinarith

/-- **H12 — the energy floor.**  Any budget clearing the gate `g` must have at least
`g² / E` keys. -/
theorem sq_gate_le_kstar_mul_energy (hn : 0 < n) (hg0 : 0 ≤ g) (hg1 : g ≤ 1) :
    g ^ 2 ≤ (kstar w n g : ℝ) * energy w n := by
  have hpass : g ≤ retained w n (kstar w n g) := gate_le_retained_kstar hw hn hg1
  have hsq := sq_retained_le_mul_energy (w := w) (n := n) (k := kstar w n g) hw hn
  nlinarith

/-- **The two-sided sandwich `g²/E ≤ k* ≤ n`.**  Both ends are computable from measured
data: the left from the ℓ²-energy of the attention profile, the right from the context
length. -/
theorem budget_sandwich (hn : 0 < n) (hg0 : 0 < g) (hg1 : g ≤ 1) :
    g ^ 2 / energy w n ≤ (kstar w n g : ℝ) ∧ (kstar w n g : ℝ) ≤ (n : ℝ) := by
  refine ⟨?_, by exact_mod_cast kstar_le_context hw hn hg1⟩
  rw [div_le_iff₀ (energy_pos hw hn)]
  exact sq_gate_le_kstar_mul_energy hw hn hg0.le hg1

/-- **H13 — the floor is an entropy exponential, for the Rényi-2 entropy.**  The energy
floor reads `k* ≥ g² · exp(H₂)` with `H₂ = -log E` the collision entropy. -/
theorem kstar_ge_gate_sq_mul_exp_collisionEntropy (hn : 0 < n) (hg0 : 0 < g) (hg1 : g ≤ 1) :
    g ^ 2 * Real.exp (collisionEntropy w n) ≤ (kstar w n g : ℝ) := by
  have hE : 0 < energy w n := energy_pos hw hn
  have hexp : Real.exp (collisionEntropy w n) = (energy w n)⁻¹ := by
    rw [collisionEntropy, Real.exp_neg, Real.exp_log hE]
  rw [hexp, ← div_eq_mul_inv]
  exact (budget_sandwich hw hn hg0 hg1).1

end Energy

/-! ### Sharpness of the floor on the flat profile -/

/-- The flat profile has energy exactly `1/n`, so its floor is `g² n`. -/
theorem energy_uniform {n : ℕ} (hn : 0 < n) : energy (fun _ => (1 : ℝ)) n = 1 / n := by
  have hS : headMass (fun _ => (1 : ℝ)) n = (n : ℝ) := by simp [headMass]
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  simp only [energy, hS]
  rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
  field_simp

/-- At the extreme gate `g = 1` the sandwich collapses: the energy floor and the context
ceiling coincide with the knee itself, so the floor is sharp. -/
theorem budget_sandwich_sharp_uniform {n : ℕ} (hn : 0 < n) :
    (1 : ℝ) ^ 2 / energy (fun _ => (1 : ℝ)) n = (n : ℝ) ∧
      kstar (fun _ => (1 : ℝ)) n 1 = n := by
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  refine ⟨by rw [energy_uniform hn]; field_simp, ?_⟩
  have hlow : (1 : ℝ) * n ≤ (kstar (fun _ => (1 : ℝ)) n 1 : ℝ) :=
    kstar_uniform_ge hn le_rfl
  have hup : kstar (fun _ => (1 : ℝ)) n 1 ≤ n := kstar_le_context uniform_pos hn le_rfl
  have hlow' : n ≤ kstar (fun _ => (1 : ℝ)) n 1 := by
    have : (n : ℝ) ≤ (kstar (fun _ => (1 : ℝ)) n 1 : ℝ) := by linarith
    exact_mod_cast this
  omega

/-! ### H13: the Hartley entropy is *not* a valid floor -/

/-- A spike profile: one dominant key of weight `16` and sixteen keys of weight `1`. -/
noncomputable def spike : ℕ → ℝ := fun i => if i = 0 then 16 else 1

lemma spike_pos : ∀ i, 0 < spike i := by
  intro i
  unfold spike
  split <;> norm_num

lemma headMass_spike_17 : headMass spike 17 = 32 := by
  simp [headMass, spike, Finset.sum_range_succ]
  norm_num

lemma kstar_spike : kstar spike 17 (1 / 2) = 1 := by
  have h0 : retained spike 17 0 < 1 / 2 := by
    simp [retained, headMass]
  have h1 : (1 / 2 : ℝ) ≤ retained spike 17 1 := by
    rw [retained, headMass_spike_17]
    norm_num [headMass, spike]
  obtain ⟨hlt, hle⟩ := knee_bracket spike_pos (n := 17) (by norm_num) (by norm_num) h0 h1
  exact le_antisymm hle hlt

lemma energy_spike : energy spike 17 = 17 / 64 := by
  simp only [energy, headMass_spike_17]
  simp [spike, Finset.sum_range_succ]
  norm_num

/-- **H13 — the support-size (Hartley) floor is unsound.**  For the spike profile at gate
`1/2` the true knee is `1`; the collision-entropy floor `g²/E = 16/17` correctly stays
below it, while the Hartley floor `g² n = 17/4` exceeds it.  Hence the budget floor cannot
be phrased with the support size (equivalently the Hartley entropy `log n`), and the
Shannon entropy — which lies between the two — is likewise not a certificate: only the
ℓ²-energy is. -/
theorem hartley_floor_refuted :
    kstar spike 17 (1 / 2) = 1 ∧ energy spike 17 = 17 / 64 ∧
      (1 / 2 : ℝ) ^ 2 / energy spike 17 ≤ (kstar spike 17 (1 / 2) : ℝ) ∧
      ((kstar spike 17 (1 / 2) : ℝ) < (1 / 2 : ℝ) ^ 2 * 17) := by
  refine ⟨kstar_spike, energy_spike, ?_, ?_⟩
  · rw [kstar_spike, energy_spike]; norm_num
  · rw [kstar_spike]; norm_num

/-! ## 3. The tail fit and the reportable budget -/

/-- The fitted tail law: `1 - M(k) ≤ C rᵏ`, uniformly in the context length. -/
def TailFit (C r : ℝ) (w : ℕ → ℝ) : Prop := ∀ n k : ℕ, 1 ≤ n → tailMass w n k ≤ C * r ^ k

/-- The budget reported by a fit `(C, r)` at gate `τ`. -/
noncomputable def budgetOfFit (C r τ : ℝ) : ℕ :=
  max ⌈Real.log ((1 - τ) / C) / Real.log r⌉₊ 1

/-- Every geometrically decaying profile admits the explicit fit `(1/(1-r), r)`: the
cycle-1 estimate is a special case of a measured tail fit. -/
theorem tailFit_of_geometric_decay {w : ℕ → ℝ} {r : ℝ} (hw : ∀ i, 0 < w i) (hr0 : 0 < r)
    (hr1 : r < 1) (hdec : ∀ i, w (i + 1) ≤ r * w i) : TailFit (1 / (1 - r)) r w := by
  have hr1' : (0 : ℝ) < 1 - r := by linarith
  intro n k hn
  rcases Nat.eq_zero_or_pos k with hk | hk
  · have h1 : tailMass w n k ≤ 1 := tailMass_le_one hw
    have hCk : (1 : ℝ) ≤ 1 / (1 - r) * r ^ k := by
      rw [hk]
      simp only [pow_zero, mul_one]
      rw [le_div_iff₀ hr1']
      linarith
    linarith
  · have hret := retained_ge_of_geometric_decay hw hr0 hr1 hdec hk hn
    simp only [tailMass]
    have hrw : 1 / (1 - r) * r ^ k = r ^ k / (1 - r) := by ring
    rw [hrw]
    linarith

/-- The key inequality behind the reported budget: at `K = budgetOfFit C r τ` the fitted
tail is below the residual `1 - τ`. -/
lemma fit_tail_le_of_budgetOfFit {C r τ : ℝ} (hC : 0 < C) (hr0 : 0 < r) (hr1 : r < 1)
    (hτ : τ < 1) : C * r ^ (budgetOfFit C r τ) ≤ 1 - τ := by
  set K := budgetOfFit C r τ with hK
  have hlogr : Real.log r < 0 := Real.log_neg hr0 hr1
  have hpos : 0 < (1 - τ) / C := div_pos (by linarith) hC
  have hKge : Real.log ((1 - τ) / C) / Real.log r ≤ (K : ℝ) := by
    refine le_trans (Nat.le_ceil _) ?_
    have : (⌈Real.log ((1 - τ) / C) / Real.log r⌉₊ : ℕ) ≤ K := le_max_left _ _
    exact_mod_cast this
  have hmul : (K : ℝ) * Real.log r ≤ Real.log ((1 - τ) / C) := by
    rwa [div_le_iff_of_neg hlogr] at hKge
  have hpow : r ^ K ≤ (1 - τ) / C := by
    have hlp : Real.log (r ^ K) = (K : ℝ) * Real.log r := by rw [Real.log_pow]
    exact (Real.log_le_log_iff (pow_pos hr0 K) hpos).mp (by rw [hlp]; exact hmul)
  rw [le_div_iff₀ hC] at hpow
  linarith [hpow]

/-- **The upper certificate.**  A fit `(C, r)` with `r < 1` bounds the knee by the
explicit reportable number `budgetOfFit C r τ`, at every context length. -/
theorem kstar_le_budgetOfFit {w : ℕ → ℝ} {C r τ : ℝ} {n : ℕ} (hn : 1 ≤ n) (hC : 0 < C)
    (hr0 : 0 < r) (hr1 : r < 1) (hτ : τ < 1) (hfit : TailFit C r w) :
    kstar w n τ ≤ budgetOfFit C r τ := by
  set K := budgetOfFit C r τ with hK
  have h1 : tailMass w n K ≤ C * r ^ K := hfit n K hn
  have h2 : C * r ^ K ≤ 1 - τ := fit_tail_le_of_budgetOfFit hC hr0 hr1 hτ
  refine kstar_le_of_pass ?_
  simp only [tailMass] at h1
  linarith

/-! ### Uncertainty propagation: monotonicity in the fit box -/

/-- **H14 — the certified budget is monotone in both fitted parameters.**  Enlarging the
fitted amplitude `C` or the fitted ratio `r` can only enlarge the reported budget, so a
confidence box for `(C, r)` maps to a budget interval whose right end is the upper
corner. -/
theorem budgetOfFit_mono {C C' r r' τ : ℝ} (hC : 0 < C) (hCC : C ≤ C') (hr0 : 0 < r)
    (hrr : r ≤ r') (hr1 : r' < 1) (hτ : τ < 1) :
    budgetOfFit C r τ ≤ budgetOfFit C' r' τ := by
  have hC' : 0 < C' := lt_of_lt_of_le hC hCC
  have hr0' : 0 < r' := lt_of_lt_of_le hr0 hrr
  have hr1'' : r < 1 := lt_of_le_of_lt hrr hr1
  have hlogr : Real.log r < 0 := Real.log_neg hr0 hr1''
  have hlogr' : Real.log r' < 0 := Real.log_neg hr0' hr1
  have hτ1 : (0 : ℝ) < 1 - τ := by linarith
  set a := Real.log ((1 - τ) / C) with ha
  set a' := Real.log ((1 - τ) / C') with ha'
  have haa : a' ≤ a := by
    have hle : (1 - τ) / C' ≤ (1 - τ) / C := div_le_div_of_nonneg_left hτ1.le hC hCC
    exact Real.log_le_log (div_pos hτ1 hC') hle
  have hlog_le : Real.log r ≤ Real.log r' := Real.log_le_log hr0 hrr
  rcases le_or_gt (a / Real.log r) 0 with hQ | hQ
  · -- the raw quotient is non-positive, so the reported budget is the floor value `1`
    have hceil : ⌈a / Real.log r⌉₊ = 0 := Nat.ceil_eq_zero.mpr hQ
    simp only [budgetOfFit, ← ha, ← ha', hceil, Nat.zero_max]
    exact le_max_right _ _
  · -- both log-amplitudes are negative; smaller `|log r|` gives a larger quotient
    have hanegs : a < 0 := by
      rcases div_pos_iff.mp hQ with ⟨_, h2⟩ | ⟨h1, _⟩
      · linarith
      · exact h1
    have hL : 0 < -Real.log r := by linarith
    have hL' : 0 < -Real.log r' := by linarith
    have hkey : (-a) / (-Real.log r) ≤ (-a') / (-Real.log r') := by
      rw [div_le_div_iff₀ hL hL']
      nlinarith
    have e1 : (-a) / (-Real.log r) = a / Real.log r := neg_div_neg_eq _ _
    have e2 : (-a') / (-Real.log r') = a' / Real.log r' := neg_div_neg_eq _ _
    rw [e1, e2] at hkey
    exact max_le_max (Nat.ceil_le_ceil hkey) le_rfl

/-- **The box certificate.**  If the true tail parameters lie anywhere inside the
confidence box `[C, C⁺] × [r, r⁺]`, the upper corner certifies the budget. -/
theorem kstar_le_budgetOfFit_of_box {w : ℕ → ℝ} {C C' r r' τ : ℝ} {n : ℕ} (hn : 1 ≤ n)
    (hC : 0 < C) (hCC : C ≤ C') (hr0 : 0 < r) (hrr : r ≤ r') (hr1 : r' < 1) (hτ : τ < 1)
    (hfit : TailFit C r w) : kstar w n τ ≤ budgetOfFit C' r' τ :=
  le_trans (kstar_le_budgetOfFit hn hC hr0 (lt_of_le_of_lt hrr hr1) hτ hfit)
    (budgetOfFit_mono hC hCC hr0 hrr hr1 hτ)

/-! ### Consistency of the two certificates -/

/-- **H16 — the fit must respect the energy floor.**  An admissible fit can never report a
budget below the energy floor of the profile it was fitted to. -/
theorem energy_floor_le_budgetOfFit {w : ℕ → ℝ} {C r g : ℝ} {n : ℕ} (hw : ∀ i, 0 < w i)
    (hC : 0 < C) (hr0 : 0 < r) (hr1 : r < 1) (hg0 : 0 < g) (hg1 : g < 1) (hn : 0 < n)
    (hfit : TailFit C r w) : g ^ 2 / energy w n ≤ (budgetOfFit C r g : ℝ) := by
  have h1 : g ^ 2 / energy w n ≤ (kstar w n g : ℝ) := (budget_sandwich hw hn hg0 hg1.le).1
  have h2 : kstar w n g ≤ budgetOfFit C r g := kstar_le_budgetOfFit hn hC hr0 hr1 hg1 hfit
  have h2' : (kstar w n g : ℝ) ≤ (budgetOfFit C r g : ℝ) := by exact_mod_cast h2
  linarith

/-- **The falsifier.**  A reported fit whose budget falls below the measured energy floor
is inadmissible.  This is a one-line consistency test on any deployed `(C, r)` report. -/
theorem tailFit_refuted_of_budget_below_floor {w : ℕ → ℝ} {C r g : ℝ} {n : ℕ}
    (hw : ∀ i, 0 < w i) (hC : 0 < C) (hr0 : 0 < r) (hr1 : r < 1) (hg0 : 0 < g) (hg1 : g < 1)
    (hn : 0 < n) (hviol : (budgetOfFit C r g : ℝ) < g ^ 2 / energy w n) :
    ¬ TailFit C r w := fun hfit =>
  absurd (energy_floor_le_budgetOfFit hw hC hr0 hr1 hg0 hg1 hn hfit) (not_le.mpr hviol)

/-! ## 4. The two-point fit and propagation of measurement error -/

/-- The two-point estimator of the tail ratio from tails measured at budgets separated by
`d`: `r̂ = (t₂ / t₁)^{1/d}`. -/
noncomputable def fitRatio (t₁ t₂ : ℝ) (d : ℕ) : ℝ := (t₂ / t₁) ^ ((d : ℝ)⁻¹)

/-- The amplitude estimator from a tail measured at budget `k₁` and a fitted ratio. -/
noncomputable def fitConst (t₁ r : ℝ) (k₁ : ℕ) : ℝ := t₁ / r ^ k₁

/-- **Exactness of the two-point fit.**  On a genuinely geometric tail the estimator
recovers the ratio exactly. -/
theorem fitRatio_exact {C r : ℝ} {k₁ d : ℕ} (hC : 0 < C) (hr : 0 < r) (hd : 0 < d) :
    fitRatio (C * r ^ k₁) (C * r ^ (k₁ + d)) d = r := by
  have hd' : (d : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hd.ne'
  have hratio : (C * r ^ (k₁ + d)) / (C * r ^ k₁) = r ^ d := by
    rw [pow_add]
    field_simp
  rw [fitRatio, hratio, ← Real.rpow_natCast r d, ← Real.rpow_mul hr.le]
  rw [mul_inv_cancel₀ hd', Real.rpow_one]

/-- The amplitude estimator is exact once the ratio is. -/
theorem fitConst_exact {C r : ℝ} {k₁ : ℕ} (hr : 0 < r) :
    fitConst (C * r ^ k₁) r k₁ = C := by
  have hne : (r : ℝ) ^ k₁ ≠ 0 := (pow_pos hr k₁).ne'
  rw [fitConst, mul_div_assoc, div_self hne, mul_one]

/-- **H15 — data error is damped by the `d`-th root.**  If both tail measurements carry a
multiplicative error of at most `ε`, the fitted ratio is off by at most the factor
`((1+ε)/(1-ε))^{1/d}`. -/
theorem fitRatio_error_bound {t₁ t₂ s₁ s₂ ε : ℝ} {d : ℕ} (hd : 0 < d) (ht₁ : 0 < t₁)
    (ht₂ : 0 < t₂) (hε0 : 0 ≤ ε) (hε1 : ε < 1) (h₁ : (1 - ε) * t₁ ≤ s₁)
    (h₂ : s₂ ≤ (1 + ε) * t₂) (hs₂ : 0 ≤ s₂) :
    fitRatio s₁ s₂ d ≤ ((1 + ε) / (1 - ε)) ^ ((d : ℝ)⁻¹) * fitRatio t₁ t₂ d := by
  have hε' : (0 : ℝ) < 1 - ε := by linarith
  have hs₁ : 0 < s₁ := lt_of_lt_of_le (by positivity) h₁
  have hkey : s₂ / s₁ ≤ ((1 + ε) / (1 - ε)) * (t₂ / t₁) := by
    rw [div_le_iff₀ hs₁]
    have hexp : (1 + ε) / (1 - ε) * (t₂ / t₁) * s₁
        ≥ (1 + ε) / (1 - ε) * (t₂ / t₁) * ((1 - ε) * t₁) := by
      have hfac : 0 ≤ (1 + ε) / (1 - ε) * (t₂ / t₁) := by positivity
      nlinarith
    have hval : (1 + ε) / (1 - ε) * (t₂ / t₁) * ((1 - ε) * t₁) = (1 + ε) * t₂ := by
      field_simp
    linarith [h₂, hexp, hval ▸ hexp]
  have hnn : (0 : ℝ) ≤ s₂ / s₁ := by positivity
  have hexp0 : (0 : ℝ) ≤ ((d : ℝ)⁻¹) := by positivity
  calc fitRatio s₁ s₂ d = (s₂ / s₁) ^ ((d : ℝ)⁻¹) := rfl
    _ ≤ (((1 + ε) / (1 - ε)) * (t₂ / t₁)) ^ ((d : ℝ)⁻¹) :=
        Real.rpow_le_rpow hnn hkey hexp0
    _ = ((1 + ε) / (1 - ε)) ^ ((d : ℝ)⁻¹) * (t₂ / t₁) ^ ((d : ℝ)⁻¹) :=
        Real.mul_rpow (by positivity) (by positivity)
    _ = ((1 + ε) / (1 - ε)) ^ ((d : ℝ)⁻¹) * fitRatio t₁ t₂ d := rfl

/-- A root of a fixed constant can be pushed below `1 + δ` by taking the root deep
enough. -/
lemma exists_root_le_one_add {a δ : ℝ} (ha : 1 ≤ a) (hδ : 0 < δ) :
    ∃ d : ℕ, 0 < d ∧ a ^ ((d : ℝ)⁻¹) ≤ 1 + δ := by
  obtain ⟨m, hm⟩ := pow_unbounded_of_one_lt a (by linarith : (1 : ℝ) < 1 + δ)
  refine ⟨m + 1, Nat.succ_pos m, ?_⟩
  have hd : (0 : ℝ) < ((m + 1 : ℕ) : ℝ) := by positivity
  have hle : a ≤ (1 + δ) ^ (m + 1) := by
    have h1 : a < (1 + δ) ^ m := hm
    have h2 : (1 + δ) ^ m ≤ (1 + δ) ^ (m + 1) := by
      apply pow_le_pow_right₀ (by linarith) (by omega)
    linarith
  have hmono : a ^ (((m + 1 : ℕ) : ℝ)⁻¹) ≤ ((1 + δ) ^ (m + 1)) ^ (((m + 1 : ℕ) : ℝ)⁻¹) :=
    Real.rpow_le_rpow (by linarith) hle (by positivity)
  have hsimp : ((1 + δ) ^ (m + 1) : ℝ) ^ (((m + 1 : ℕ) : ℝ)⁻¹) = 1 + δ := by
    rw [← Real.rpow_natCast (1 + δ) (m + 1), ← Real.rpow_mul (by linarith)]
    push_cast
    rw [mul_inv_cancel₀ (by positivity), Real.rpow_one]
  rw [hsimp] at hmono
  exact hmono

/-- **Measurement design.**  For any data error `ε < 1` and any target relative precision
`δ`, a probe separation `d` exists at which the two-point fit meets the target — the fit's
uncertainty is controlled by the *experiment design*, not by the noise level. -/
theorem fit_precision_of_probe_separation {ε δ : ℝ} (hε0 : 0 ≤ ε) (hε1 : ε < 1)
    (hδ : 0 < δ) :
    ∃ d : ℕ, 0 < d ∧ ∀ t₁ t₂ s₁ s₂ : ℝ, 0 < t₁ → 0 < t₂ → 0 ≤ s₂ →
      (1 - ε) * t₁ ≤ s₁ → s₂ ≤ (1 + ε) * t₂ →
      fitRatio s₁ s₂ d ≤ (1 + δ) * fitRatio t₁ t₂ d := by
  have hε' : (0 : ℝ) < 1 - ε := by linarith
  have ha : (1 : ℝ) ≤ (1 + ε) / (1 - ε) := by
    rw [le_div_iff₀ hε']; linarith
  obtain ⟨d, hd, hroot⟩ := exists_root_le_one_add ha hδ
  refine ⟨d, hd, fun t₁ t₂ s₁ s₂ ht₁ ht₂ hs₂ h₁ h₂ => ?_⟩
  have hbound := fitRatio_error_bound hd ht₁ ht₂ hε0 hε1 h₁ h₂ hs₂
  have hfr : 0 ≤ fitRatio t₁ t₂ d := Real.rpow_nonneg (by positivity) _
  nlinarith

/-! ## 5. The deployable report -/

/-- **The measurement protocol.**  Given a positive attention profile, a fitted tail law
inside a confidence box `[C, C⁺] × [r, r⁺]` with `r⁺ < 1`, a reporting gate `τ < 1` and a
measurement gate `g ∈ (0, 1]`, the protocol outputs a two-sided sandwich for the knee at
gate `g` and a certified budget at gate `τ`, all computable from measured data. -/
theorem measurement_protocol {w : ℕ → ℝ} {C C' r r' τ g : ℝ} {n : ℕ} (hw : ∀ i, 0 < w i)
    (hn : 0 < n) (hC : 0 < C) (hCC : C ≤ C') (hr0 : 0 < r) (hrr : r ≤ r') (hr1 : r' < 1)
    (hτ : τ < 1) (hg0 : 0 < g) (hg1 : g ≤ 1) (hfit : TailFit C r w) :
    g ^ 2 / energy w n ≤ (kstar w n g : ℝ) ∧ (kstar w n g : ℝ) ≤ (n : ℝ) ∧
      kstar w n τ ≤ budgetOfFit C' r' τ :=
  ⟨(budget_sandwich hw hn hg0 hg1).1, (budget_sandwich hw hn hg0 hg1).2,
    kstar_le_budgetOfFit_of_box hn hC hCC hr0 hrr hr1 hτ hfit⟩

end AttentionBudget