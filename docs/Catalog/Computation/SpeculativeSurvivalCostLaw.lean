/-
# The Speculative-Decoding Cost Law: Survival Curves, Optimal Depth, and Noise

This file formalizes the *cost law* governing speculative decoding (draft-model
speculation for a large target model), the object measured in the NET-96
experiment: a fine depth sweep `d ∈ {1,…,8}` over two prompt registers
(prose / code), with a per-position **survival curve** `s` extracted from the
cumulative mean acceptance `m(d)` by numerical differencing
`s_d = d·m(d) − (d−1)·m(d−1)`.

The macroscopic observable is the **gain** (expected verified tokens per unit
verification cost)

  `gain c s d = (∑_{i < d} s i) / (1 + c·d)`,

where `c` is the marginal per-drafted-token overhead (measured `c ≈ 0.118`).

## Main results

* `gain_le_succ_iff` : the one-step improvement test is exactly the sign of the
  *marginal* `marginal c s d = s d · (1 + c·d) − c · accept s d`.
* `marginal_antitone` : for an antitone (monotonically decaying) survival curve
  the marginal is itself antitone — a *discrete concavity* statement.
* `gain_quasiconcave` : hence the cost law is unimodal in depth.
* `myopic_stopping_optimal` : the first depth at which the marginal turns
  negative is a **global** maximiser; greedy one-step lookahead is exact.
* `gain_max_of_single_crossing` : antitonicity can be dropped entirely — a single
  sign change of the marginal already certifies a global optimum.
* `marginal_neg_of_vanishing` : past the support of the survival curve the
  marginal is negative, so a finite sweep certifies a global optimum.
* `optimal_depth_antitone_in_cost` : higher per-token overhead never deepens the
  optimum (comparative statics in `c`).
* `exists_global_max` : a global optimal depth exists whenever the cumulative
  acceptance is bounded.
* `gain_lt_inv_cost` : the universal speedup ceiling `gain < 1/c`.
* `accept_eq_tailsum` : bridge to probability — cumulative acceptance is the
  expectation of the run-length distribution whose tail is `s` (Abel summation).
* `gain_perturb_bound`, `argmax_stable` : the argmax is stable under sup-norm
  perturbation of the survival curve (the robustness that rescues NET-96's
  conclusion despite the noisy differencing).
* `diffSurv_error_bound`, `diffSurv_error_tight`, `accept_error_bound` :
  numerical differencing amplifies aggregate noise by the factor `2d+1` and this
  is attained, while the cumulative statistic only amplifies by `d+1`. This is
  the formal content of the NET-96 lesson: per-position acceptance must be
  instrumented directly, not differenced out of small-`n` aggregates.
-/

import Mathlib

namespace Catalog.Computation.SpecDecode

open Finset

/-- Cumulative expected accepted tokens at speculation depth `d`:
the sum of the per-position survival probabilities `s 0, …, s (d-1)`
(position `i` of the file is drafted token number `i+1`). -/
def accept (s : ℕ → ℝ) (d : ℕ) : ℝ := ∑ i ∈ range d, s i

/-- The cost law / throughput gain at depth `d` with marginal drafting
overhead `c`. -/
noncomputable def gain (c : ℝ) (s : ℕ → ℝ) (d : ℕ) : ℝ := accept s d / (1 + c * d)

/-- The marginal of the cost law: `gain` increases from `d` to `d+1` exactly
when this quantity is nonnegative. -/
def marginal (c : ℝ) (s : ℕ → ℝ) (d : ℕ) : ℝ := s d * (1 + c * d) - c * accept s d

@[simp] lemma accept_zero (s : ℕ → ℝ) : accept s 0 = 0 := by simp [accept]

lemma accept_succ (s : ℕ → ℝ) (d : ℕ) : accept s (d + 1) = accept s d + s d := by
  simp [accept, Finset.sum_range_succ]

@[simp] lemma gain_zero (c : ℝ) (s : ℕ → ℝ) : gain c s 0 = 0 := by simp [gain]

lemma denom_pos {c : ℝ} (hc : 0 ≤ c) (d : ℕ) : (0:ℝ) < 1 + c * d := by
  have : (0:ℝ) ≤ c * d := mul_nonneg hc (Nat.cast_nonneg d)
  linarith

/-! ## The one-step test and discrete concavity -/

/-- **The marginal test.** The cost law improves when moving from depth `d` to
depth `d+1` precisely when the marginal is nonnegative. -/
theorem gain_le_succ_iff {c : ℝ} (hc : 0 ≤ c) (s : ℕ → ℝ) (d : ℕ) :
    gain c s d ≤ gain c s (d + 1) ↔ 0 ≤ marginal c s d := by
  have h1 : (0:ℝ) < 1 + c * d := denom_pos hc d
  have h2 : (0:ℝ) < 1 + c * ((d : ℝ) + 1) := by
    have := denom_pos hc (d + 1); push_cast at this; linarith
  rw [gain, gain, accept_succ]
  push_cast
  rw [div_le_div_iff₀ h1 h2]
  unfold marginal
  constructor <;> intro h <;> nlinarith

/-- Strict form of the marginal test. -/
theorem gain_succ_lt_iff {c : ℝ} (hc : 0 ≤ c) (s : ℕ → ℝ) (d : ℕ) :
    gain c s (d + 1) < gain c s d ↔ marginal c s d < 0 := by
  have := gain_le_succ_iff hc s d
  constructor <;> intro h
  · by_contra hcon
    push_neg at hcon
    exact absurd (this.mpr hcon) (not_le.mpr h)
  · by_contra hcon
    push_neg at hcon
    exact absurd (this.mp hcon) (not_le.mpr h)

/-- **Discrete concavity of the cost law.** If the survival curve is antitone
(acceptance decays with position, the physically expected regime), the marginal
is antitone in the depth: `marginal (d+1) − marginal d = (1+c(d+1))·(s(d+1) − s d)`. -/
theorem marginal_succ_sub {c : ℝ} (s : ℕ → ℝ) (d : ℕ) :
    marginal c s (d + 1) - marginal c s d
      = (1 + c * ((d : ℝ) + 1)) * (s (d + 1) - s d) := by
  unfold marginal
  rw [accept_succ]
  push_cast
  ring

theorem marginal_antitone_step {c : ℝ} (hc : 0 ≤ c) {s : ℕ → ℝ} (hs : Antitone s) (d : ℕ) :
    marginal c s (d + 1) ≤ marginal c s d := by
  have hd : (0:ℝ) < 1 + c * ((d : ℝ) + 1) := by
    have := denom_pos hc (d + 1); push_cast at this; linarith
  have hstep : s (d + 1) - s d ≤ 0 := by
    have := hs (Nat.le_succ d); linarith
  have := marginal_succ_sub (c := c) s d
  nlinarith

/-- The marginal of an antitone survival curve is antitone in the depth. -/
theorem marginal_antitone {c : ℝ} (hc : 0 ≤ c) {s : ℕ → ℝ} (hs : Antitone s) :
    Antitone (marginal c s) := by
  apply antitone_nat_of_succ_le
  exact marginal_antitone_step hc hs

/-! ## Unimodality and myopic optimality -/

/-- Once the marginal has turned strictly negative at depth `d`, the cost law is
nonincreasing forever after: no deeper speculation can recover. -/
theorem gain_le_of_marginal_neg {c : ℝ} (hc : 0 ≤ c) {s : ℕ → ℝ} (hs : Antitone s)
    {d : ℕ} (hd : marginal c s d < 0) :
    ∀ e, d ≤ e → gain c s e ≤ gain c s d := by
  intro e he
  induction e, he using Nat.le_induction with
  | base => exact le_rfl
  | succ n hn ih =>
      have hmn : marginal c s n < 0 :=
        lt_of_le_of_lt (marginal_antitone hc hs hn) hd
      have hstep := (gain_succ_lt_iff hc s n).mpr hmn
      exact le_trans (le_of_lt hstep) ih

/-- Before the first sign change the cost law is nondecreasing. -/
theorem gain_le_of_marginal_nonneg {c : ℝ} (hc : 0 ≤ c) {s : ℕ → ℝ}
    {d : ℕ} (hd : ∀ e, e < d → 0 ≤ marginal c s e) :
    ∀ e, e ≤ d → gain c s e ≤ gain c s d := by
  intro e he
  induction d with
  | zero => simp_all
  | succ n ih =>
      rcases Nat.lt_or_ge e (n + 1) with h | h
      · have hn : e ≤ n := Nat.lt_succ_iff.mp h
        have hstep : gain c s n ≤ gain c s (n + 1) :=
          (gain_le_succ_iff hc s n).mpr (hd n (Nat.lt_succ_self n))
        exact le_trans (ih (fun e' he' => hd e' (Nat.lt_succ_of_lt he')) hn) hstep
      · have : e = n + 1 := le_antisymm he h
        subst this
        exact le_rfl

/-- **Single crossing suffices.** Antitonicity of the survival curve is *not*
needed for myopic optimality: all that matters is that the marginal is
nonnegative before some depth and negative from it on. This is the hypothesis
that survives on the noisy NET-96 curves, which are not antitone. -/
theorem gain_max_of_single_crossing {c : ℝ} (hc : 0 ≤ c) {s : ℕ → ℝ} {d : ℕ}
    (hbefore : ∀ e, e < d → 0 ≤ marginal c s e)
    (hafter : ∀ e, d ≤ e → marginal c s e < 0) :
    ∀ e, gain c s e ≤ gain c s d := by
  intro e
  rcases Nat.le_total e d with h | h
  · exact gain_le_of_marginal_nonneg hc hbefore e h
  · induction e, h using Nat.le_induction with
    | base => exact le_rfl
    | succ n hn ih =>
        have hstep := (gain_succ_lt_iff hc s n).mpr (hafter n hn)
        linarith

/-- Beyond the support of a survival curve the cumulative acceptance is
constant. -/
theorem accept_const_of_vanishing {s : ℕ → ℝ} {D : ℕ} (hzero : ∀ i, D ≤ i → s i = 0) :
    ∀ e, D ≤ e → accept s e = accept s D := by
  intro e he
  induction e, he using Nat.le_induction with
  | base => rfl
  | succ n hn ih => rw [accept_succ, hzero n hn, ih, add_zero]

/-- **Finite support forces stopping.** If the draft model is only ever accepted
within a horizon `D` and some acceptance occurs, then every depth past `D` has a
strictly negative marginal, so a finite sweep to `D` certifies a *global*
optimum. -/
theorem marginal_neg_of_vanishing {c : ℝ} (hc : 0 < c) {s : ℕ → ℝ} {D : ℕ}
    (hzero : ∀ i, D ≤ i → s i = 0) (hpos : 0 < accept s D) :
    ∀ e, D ≤ e → marginal c s e < 0 := by
  intro e he
  rw [marginal, hzero e he, accept_const_of_vanishing hzero e he]
  nlinarith

/-- **Myopic stopping is globally optimal.** For an antitone survival curve, the
first depth at which the one-step marginal turns negative maximises the cost law
over *all* depths. This is the structural theorem behind NET-96's P3: an argmax
computed from the extracted survival curve is the true throughput optimum. -/
theorem myopic_stopping_optimal {c : ℝ} (hc : 0 ≤ c) {s : ℕ → ℝ} (hs : Antitone s)
    {d : ℕ} (hbefore : ∀ e, e < d → 0 ≤ marginal c s e) (hat : marginal c s d < 0) :
    ∀ e, gain c s e ≤ gain c s d := by
  intro e
  rcases Nat.le_total e d with h | h
  · exact gain_le_of_marginal_nonneg hc hbefore e h
  · exact gain_le_of_marginal_neg hc hs hat e h

/-- **Quasi-concavity (unimodality) of the cost law.** For an antitone survival
curve, if the gain fails to improve at depth `d` then it never improves again. -/
theorem gain_quasiconcave {c : ℝ} (hc : 0 ≤ c) {s : ℕ → ℝ} (hs : Antitone s)
    {d : ℕ} (hd : gain c s (d + 1) < gain c s d) :
    ∀ e, d ≤ e → gain c s e ≤ gain c s d :=
  gain_le_of_marginal_neg hc hs ((gain_succ_lt_iff hc s d).mp hd)

/-! ## Comparative statics in the overhead `c` -/

/-- The marginal is antitone in the per-token overhead `c` (for antitone,
nonnegative survival): raising drafting cost only makes stopping more attractive. -/
theorem marginal_antitone_in_cost {c c' : ℝ} (hcc : c ≤ c') {s : ℕ → ℝ}
    (hs : Antitone s) (d : ℕ) :
    marginal c' s d ≤ marginal c s d := by
  have hsum : (d : ℝ) * s d ≤ accept s d := by
    have : ∀ i ∈ range d, s d ≤ s i := by
      intro i hi
      exact hs (le_of_lt (mem_range.mp hi))
    calc (d : ℝ) * s d = ∑ _i ∈ range d, s d := by
              rw [Finset.sum_const, card_range]; ring
      _ ≤ accept s d := Finset.sum_le_sum this
  unfold marginal
  nlinarith

/-- **Higher overhead never deepens the optimum.** If the marginal test says
"stop at depth `d`" for overhead `c`, it also says so for any larger overhead. -/
theorem optimal_depth_antitone_in_cost {c c' : ℝ} (hc : 0 ≤ c) (hcc : c ≤ c')
    {s : ℕ → ℝ} (hs : Antitone s) {d : ℕ} (hd : marginal c s d < 0) :
    ∀ e, d ≤ e → gain c' s e ≤ gain c' s d := by
  have hc' : 0 ≤ c' := le_trans hc hcc
  exact gain_le_of_marginal_neg hc' hs
    (lt_of_le_of_lt (marginal_antitone_in_cost hcc hs d) hd)

/-! ## Universal ceiling and existence of an optimum -/

/-- **The speedup ceiling.** Survival probabilities are at most one, so the cost
law can never exceed `1/c`, whatever the draft model: verification overhead alone
caps speculative decoding. -/
theorem gain_lt_inv_cost {c : ℝ} (hc : 0 < c) {s : ℕ → ℝ} (hs : ∀ i, s i ≤ 1) (d : ℕ) :
    gain c s d < 1 / c := by
  have hden : (0:ℝ) < 1 + c * d := denom_pos hc.le d
  have hA : accept s d ≤ (d : ℝ) := by
    have : accept s d ≤ ∑ _i ∈ range d, (1:ℝ) := Finset.sum_le_sum (fun i _ => hs i)
    simpa [accept] using this
  rw [gain, div_lt_div_iff₀ hden hc]
  nlinarith [Nat.cast_nonneg (α := ℝ) d]

/-- If the cumulative acceptance is bounded (e.g. a summable survival curve), a
globally optimal speculation depth exists. -/
theorem exists_global_max {c B : ℝ} (hc : 0 < c) {s : ℕ → ℝ}
    (hB : ∀ d, accept s d ≤ B) :
    ∃ d0, ∀ d, gain c s d ≤ gain c s d0 := by
  by_cases hall : ∀ d, gain c s d ≤ 0
  · exact ⟨0, by simpa using hall⟩
  push_neg at hall
  obtain ⟨d1, hd1⟩ := hall
  obtain ⟨N, hN⟩ := exists_nat_gt ((B / gain c s d1 - 1) / c)
  set M := max N d1 with hM
  -- the finite maximum over `range (M+1)`
  have hne : (range (M + 1)).Nonempty := ⟨0, by simp⟩
  obtain ⟨d0, hd0mem, hd0⟩ := Finset.exists_max_image (range (M + 1)) (gain c s) hne
  refine ⟨d0, ?_⟩
  intro d
  by_cases hd : d ≤ M
  · exact hd0 d (mem_range.mpr (by omega))
  · push_neg at hd
    have hgd1 : gain c s d1 ≤ gain c s d0 := hd0 d1 (mem_range.mpr (by omega))
    have hden : (0:ℝ) < 1 + c * d := denom_pos hc.le d
    have hcd : (B / gain c s d1 - 1) / c < (d : ℝ) := by
      have hNd : (N : ℝ) ≤ (d : ℝ) := by
        have : N ≤ d := le_of_lt (lt_of_le_of_lt (le_max_left N d1) hd)
        exact_mod_cast this
      linarith
    have hkey : B / gain c s d1 < 1 + c * d := by
      have := (div_lt_iff₀ hc).mp hcd
      linarith
    have h2 : B / (1 + c * d) < gain c s d1 := by
      rw [div_lt_iff₀ hden]
      have := (div_lt_iff₀ hd1).mp hkey
      linarith [this]
    have h3 : gain c s d ≤ B / (1 + c * d) := by
      rw [gain, div_le_div_iff_of_pos_right hden]
      exact hB d
    linarith

/-! ## Bridge to probability: acceptance as a tail sum -/

/-- **Abel summation / tail-sum identity.** If `s i` is the probability that the
run of accepted drafted tokens survives past position `i`, then the cumulative
acceptance `∑_{i<d} s i` is exactly the expectation of the run length, written
through the point masses `p i = s i − s (i+1)` (and the atom `d·s d` at the cap).
This identifies the micro-mechanism (survival curve) with the macro-observable
(mean accepted tokens). -/
theorem accept_eq_tailsum (s : ℕ → ℝ) (d : ℕ) :
    accept s d = (∑ i ∈ range d, ((i : ℝ) + 1) * (s i - s (i + 1))) + (d : ℝ) * s d := by
  induction d with
  | zero => simp
  | succ n ih =>
      rw [accept_succ, Finset.sum_range_succ, ih]
      push_cast
      ring

/-! ## Robustness of the argmax under measurement noise -/

/-- Sup-norm perturbation of the survival curve perturbs the cumulative
acceptance by at most `ε·d`. -/
theorem accept_perturb_bound {s t : ℕ → ℝ} {ε : ℝ} (h : ∀ i, |t i - s i| ≤ ε) (d : ℕ) :
    |accept t d - accept s d| ≤ ε * d := by
  have : accept t d - accept s d = ∑ i ∈ range d, (t i - s i) := by
    simp [accept, Finset.sum_sub_distrib]
  rw [this]
  calc |∑ i ∈ range d, (t i - s i)| ≤ ∑ i ∈ range d, |t i - s i| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i ∈ range d, ε := Finset.sum_le_sum (fun i _ => h i)
    _ = ε * d := by rw [Finset.sum_const, card_range]; ring

/-- …and hence the gain by at most `ε·d/(1+c·d)`. -/
theorem gain_perturb_bound {c : ℝ} (hc : 0 ≤ c) {s t : ℕ → ℝ} {ε : ℝ}
    (h : ∀ i, |t i - s i| ≤ ε) (d : ℕ) :
    |gain c t d - gain c s d| ≤ ε * d / (1 + c * d) := by
  have hden : (0:ℝ) < 1 + c * d := denom_pos hc d
  have : gain c t d - gain c s d = (accept t d - accept s d) / (1 + c * d) := by
    rw [gain, gain, sub_div]
  rw [this, abs_div, abs_of_pos hden, div_le_div_iff_of_pos_right hden]
  exact accept_perturb_bound h d

/-- **Argmax stability.** If the depth `d0` beats the depth `d` by more than the
combined perturbation budget, it still beats it after the survival curve is
perturbed. This is the formal version of NET-96's robustness claim: the optimal
depth is insensitive to the jitter that wrecks the per-position estimates. -/
theorem argmax_stable {c : ℝ} (hc : 0 ≤ c) {s t : ℕ → ℝ} {ε : ℝ}
    (h : ∀ i, |t i - s i| ≤ ε) {d d0 : ℕ}
    (hgap : ε * d / (1 + c * d) + ε * d0 / (1 + c * d0) < gain c s d0 - gain c s d) :
    gain c t d < gain c t d0 := by
  have h1 := gain_perturb_bound hc h d
  have h2 := gain_perturb_bound hc h d0
  have h1' : gain c t d - gain c s d ≤ ε * d / (1 + c * d) :=
    le_trans (le_abs_self _) h1
  have h2' : gain c s d0 - gain c t d0 ≤ ε * d0 / (1 + c * d0) := by
    have : |gain c s d0 - gain c t d0| ≤ ε * d0 / (1 + c * d0) := by
      rwa [abs_sub_comm]
    exact le_trans (le_abs_self _) this
  linarith

/-! ## Why differencing fails: noise amplification -/

/-- Per-position survival recovered from the cumulative mean acceptance `m` by
numerical differencing, `s_i = (i+1)·m(i+1) − i·m(i)` (`m d` is the mean number
of accepted tokens per drafted token at depth `d`). -/
def diffSurv (m : ℕ → ℝ) (i : ℕ) : ℝ := ((i : ℝ) + 1) * m (i + 1) - (i : ℝ) * m i

/-- Differencing is exact on noiseless data: if `m` is the mean acceptance of a
survival curve `s`, differencing returns `s`. -/
theorem diffSurv_exact {s m : ℕ → ℝ} (hm : ∀ d : ℕ, (d : ℝ) * m d = accept s d) (i : ℕ) :
    diffSurv m i = s i := by
  have h1 := hm (i + 1)
  have h2 := hm i
  have h3 : accept s (i + 1) = accept s i + s i := accept_succ s i
  unfold diffSurv
  push_cast at h1
  linarith

/-- **Noise amplification of differencing.** A sup-norm error `δ` in the
aggregate mean acceptance becomes an error of up to `(2i+1)·δ` in the differenced
per-position survival. -/
theorem diffSurv_error_bound {m m' : ℕ → ℝ} {δ : ℝ} (h : ∀ d, |m' d - m d| ≤ δ) (i : ℕ) :
    |diffSurv m' i - diffSurv m i| ≤ (2 * (i : ℝ) + 1) * δ := by
  have hexp : diffSurv m' i - diffSurv m i
      = ((i : ℝ) + 1) * (m' (i + 1) - m (i + 1)) - (i : ℝ) * (m' i - m i) := by
    unfold diffSurv; ring
  rw [hexp]
  have hi : (0:ℝ) ≤ (i : ℝ) := Nat.cast_nonneg i
  calc |((i : ℝ) + 1) * (m' (i + 1) - m (i + 1)) - (i : ℝ) * (m' i - m i)|
      ≤ |((i : ℝ) + 1) * (m' (i + 1) - m (i + 1))| + |(i : ℝ) * (m' i - m i)| :=
        abs_sub _ _
    _ = ((i : ℝ) + 1) * |m' (i + 1) - m (i + 1)| + (i : ℝ) * |m' i - m i| := by
        rw [abs_mul, abs_mul, abs_of_nonneg (by linarith : (0:ℝ) ≤ (i:ℝ) + 1),
          abs_of_nonneg hi]
    _ ≤ ((i : ℝ) + 1) * δ + (i : ℝ) * δ := by
        have ha := h (i + 1); have hb := h i; nlinarith [abs_nonneg (m' i - m i)]
    _ = (2 * (i : ℝ) + 1) * δ := by ring

/-- …by contrast the cumulative statistic only amplifies by `d`. -/
theorem accept_error_bound {m m' : ℕ → ℝ} {δ : ℝ} (h : ∀ d, |m' d - m d| ≤ δ) (d : ℕ) :
    |(d : ℝ) * m' d - (d : ℝ) * m d| ≤ (d : ℝ) * δ := by
  have hd : (0:ℝ) ≤ (d : ℝ) := Nat.cast_nonneg d
  rw [← mul_sub, abs_mul, abs_of_nonneg hd]
  exact mul_le_mul_of_nonneg_left (h d) hd

/-- **The amplification bound is attained.** With an alternating-sign aggregate
error of size `δ`, the differenced survival at position `i` is off by exactly
`(2i+1)·δ`. Hence differencing genuinely (asymptotically) doubles the relative
noise of the cumulative statistic — the NET-96 lesson, formalized. -/
theorem diffSurv_error_tight (δ : ℝ) (i : ℕ) :
    ∃ m m' : ℕ → ℝ, (∀ d, |m' d - m d| ≤ |δ|) ∧
      diffSurv m' i - diffSurv m i = (2 * (i : ℝ) + 1) * δ := by
  refine ⟨fun _ => 0, fun k => if k = i + 1 then δ else if k = i then -δ else 0, ?_, ?_⟩
  · intro d
    by_cases h1 : d = i + 1
    · simp [h1]
    · by_cases h2 : d = i <;> simp [h1, h2, abs_neg]
  · simp [diffSurv]
    ring

/-- Quantitative form: for every position `i ≥ 1` the worst-case differencing
error strictly exceeds `3/2` times the worst-case cumulative error at the same
depth, and the ratio tends to `2`. -/
theorem diffSurv_amplification_ratio {δ : ℝ} (hδ : 0 < δ) {i : ℕ} (hi : 1 ≤ i) :
    (3 / 2) * ((i : ℝ) + 1) * δ ≤ (2 * (i : ℝ) + 1) * δ ∧
      (2 * (i : ℝ) + 1) * δ < 2 * ((i : ℝ) + 1) * δ := by
  have hi' : (1:ℝ) ≤ (i : ℝ) := by exact_mod_cast hi
  constructor
  · nlinarith
  · nlinarith

end Catalog.Computation.SpecDecode