/-
# Constrained = Penalised: the duality core of the KL-regularised alignment problem

This file formalises, over a finite outcome type, the equivalence between

* the **penalised** ("soft") problem  `max_p  𝔼_p[r] - β · KL(p ‖ π₀)`, whose solution is the
  exponentially tilted family `π*_β (i) ∝ π₀(i) · exp(r i / β)`, and
* the **constrained** ("hard") problem  `max { 𝔼_p[r] : KL(p ‖ π₀) ≤ k }`.

The main results are:

* `duality_identity` — an exact, hypothesis-light algebraic identity
  `t · (𝔼_{p_t}[r] - 𝔼_p[r]) = KL(p_t‖π₀) - KL(p‖π₀) + KL(p‖p_t)`
  from which every optimality statement below follows without any calculus;
* `klCurve_strictMonoOn` — the KL budget `k(t) = KL(p_t‖π₀)` is strictly increasing
  (proved *without* differentiating the log-partition function, using the identity twice);
* `klCurve_lt_tropicalCeiling` and `klCurve_tendsto_tropicalCeiling` — the achievable range of
  KL budgets is exactly `[0, L)` with `L = -log (π₀ (argmax r))`, the **tropical ceiling**;
* `existsUnique_beta_of_mem_range` — for every achievable `k` there is a unique `β > 0` with
  `KL(π*_β ‖ π₀) = k`;
* `constrained_eq_penalised` — that `π*_β` is the (unique) maximiser of `𝔼_p[r]` over the
  KL-ball `{p : KL(p‖π₀) ≤ k}`.

The tropical thread: `log_partitionFn_sandwich` and `tropical_limit_of_logPartition` exhibit the
`β → 0` limit as Maslov dequantization, `(1/t)·log Z(t) → max r`, with an explicit two-sided
error controlled by the argmax mass; the same mass is exactly the tropical ceiling `L`.
-/
import Mathlib

namespace Catalog.Tropical.ConstrainedPenalised

open Finset Real

variable {ι : Type*} [Fintype ι]

/-! ## Basic objects -/

/-- `p` is a probability vector on the finite type `ι`. -/
def IsProb (p : ι → ℝ) : Prop := (∀ i, 0 ≤ p i) ∧ ∑ i, p i = 1

/-- The log-partition normaliser `Z(t) = ∑ π₀(i) e^{t r(i)}` of the exponentially tilted family. -/
noncomputable def partitionFn (p0 r : ι → ℝ) (t : ℝ) : ℝ := ∑ i, p0 i * Real.exp (t * r i)

/-- The exponential tilt `p_t(i) = π₀(i) e^{t r(i)} / Z(t)`. -/
noncomputable def tilted (p0 r : ι → ℝ) (t : ℝ) (i : ι) : ℝ :=
  p0 i * Real.exp (t * r i) / partitionFn p0 r t

/-- Kullback–Leibler divergence `KL(p‖q) = ∑ p log (p/q)` (with the usual `0 log 0 = 0`). -/
noncomputable def klDiv (p q : ι → ℝ) : ℝ := ∑ i, p i * Real.log (p i / q i)

/-- Expectation `𝔼_p[f] = ∑ p(i) f(i)`. -/
noncomputable def expect (p f : ι → ℝ) : ℝ := ∑ i, p i * f i

/-- The KL budget curve `k(t) = KL(p_t ‖ π₀)` of the tilted family. -/
noncomputable def klCurve (p0 r : ι → ℝ) (t : ℝ) : ℝ := klDiv (tilted p0 r t) p0

/-- The RLHF optimal policy `π*_β(i) ∝ π₀(i) exp (r i / β)`: the tilt at inverse temperature
`t = 1/β`. -/
noncomputable def piStar (p0 r : ι → ℝ) (β : ℝ) : ι → ℝ := tilted p0 r β⁻¹

/-! ## Elementary properties of the tilted family -/

section Tilt

variable {p0 r : ι → ℝ}

lemma partitionFn_pos [Nonempty ι] (hp : ∀ i, 0 < p0 i) (t : ℝ) : 0 < partitionFn p0 r t := by
  refine Finset.sum_pos (fun i _ => mul_pos (hp i) (Real.exp_pos _)) ?_
  exact Finset.univ_nonempty

lemma tilted_pos [Nonempty ι] (hp : ∀ i, 0 < p0 i) (t : ℝ) (i : ι) : 0 < tilted p0 r t i :=
  div_pos (mul_pos (hp i) (Real.exp_pos _)) (partitionFn_pos hp t)

lemma tilted_sum_one [Nonempty ι] (hp : ∀ i, 0 < p0 i) (t : ℝ) :
    ∑ i, tilted p0 r t i = 1 := by
  unfold tilted
  rw [← Finset.sum_div]
  exact div_self (partitionFn_pos hp t).ne'

lemma tilted_isProb [Nonempty ι] (hp : ∀ i, 0 < p0 i) (t : ℝ) : IsProb (tilted p0 r t) :=
  ⟨fun i => (tilted_pos hp t i).le, tilted_sum_one hp t⟩

/-- At `t = 0` the tilt is the reference distribution itself. -/
lemma tilted_zero (hs : ∑ i, p0 i = 1) (i : ι) :
    tilted p0 r 0 i = p0 i := by
  unfold tilted partitionFn
  simp [hs]

end Tilt

/-! ## Nonnegativity and the equality case of KL -/

section KL

variable {p q : ι → ℝ}

/-- Termwise Gibbs bound: `a log (a/b) ≥ a - b`, for `a ≥ 0 < b`. -/
lemma kl_term_bound {a b : ℝ} (ha : 0 ≤ a) (hb : 0 < b) :
    a - b ≤ a * Real.log (a / b) := by
  rcases eq_or_lt_of_le ha with h | h
  · simp [← h]; linarith
  · have hlog : Real.log (b / a) ≤ b / a - 1 := Real.log_le_sub_one_of_pos (div_pos hb h)
    have hne : Real.log (b / a) = - Real.log (a / b) := by
      rw [← Real.log_inv]; congr 1; field_simp
    rw [hne] at hlog
    have : a * (- Real.log (a / b)) ≤ a * (b / a - 1) := by
      exact mul_le_mul_of_nonneg_left hlog ha
    have hba : a * (b / a - 1) = b - a := by field_simp
    nlinarith [this]

/-- Strict Gibbs bound when the ratio is not `1`. -/
lemma kl_term_bound_strict {a b : ℝ} (ha : 0 ≤ a) (hb : 0 < b) (hab : a ≠ b) :
    a - b < a * Real.log (a / b) := by
  rcases eq_or_lt_of_le ha with h | h
  · simp [← h]; linarith
  · have hne1 : b / a ≠ 1 := by
      intro hh
      apply hab
      field_simp at hh
      linarith
    have hlog : Real.log (b / a) < b / a - 1 := Real.log_lt_sub_one_of_pos (div_pos hb h) hne1
    have hne : Real.log (b / a) = - Real.log (a / b) := by
      rw [← Real.log_inv]; congr 1; field_simp
    rw [hne] at hlog
    have h2 : a * (- Real.log (a / b)) < a * (b / a - 1) := by
      exact mul_lt_mul_of_pos_left hlog h
    have hba : a * (b / a - 1) = b - a := by field_simp
    nlinarith [h2]

/-- Gibbs' inequality. -/
theorem klDiv_nonneg (hp : IsProb p) (hq : IsProb q) (hqpos : ∀ i, 0 < q i) :
    0 ≤ klDiv p q := by
  have key : ∑ i, (p i - q i) ≤ ∑ i, p i * Real.log (p i / q i) :=
    Finset.sum_le_sum (fun i _ => kl_term_bound (hp.1 i) (hqpos i))
  have : ∑ i, (p i - q i) = 0 := by
    rw [Finset.sum_sub_distrib, hp.2, hq.2]; ring
  rw [this] at key
  exact key

/-- The equality case of Gibbs' inequality. -/
theorem klDiv_eq_zero_iff (hp : IsProb p) (hq : IsProb q) (hqpos : ∀ i, 0 < q i) :
    klDiv p q = 0 ↔ p = q := by
  constructor
  · intro h
    by_contra hne
    obtain ⟨i0, hi0⟩ : ∃ i, p i ≠ q i := by
      by_contra hc
      push_neg at hc
      exact hne (funext hc)
    have hstrict : ∑ i, (p i - q i) < ∑ i, p i * Real.log (p i / q i) := by
      refine Finset.sum_lt_sum (fun i _ => kl_term_bound (hp.1 i) (hqpos i)) ⟨i0, mem_univ _, ?_⟩
      exact kl_term_bound_strict (hp.1 i0) (hqpos i0) hi0
    have hz : ∑ i, (p i - q i) = 0 := by
      rw [Finset.sum_sub_distrib, hp.2, hq.2]; ring
    rw [hz] at hstrict
    exact absurd h (ne_of_gt hstrict)
  · rintro rfl
    unfold klDiv
    have : ∀ i, p i * Real.log (p i / p i) = 0 := by
      intro i
      rcases eq_or_lt_of_le (hp.1 i) with h | h
      · simp [← h]
      · rw [div_self h.ne']; simp
    exact Finset.sum_eq_zero (fun i _ => this i)

end KL

/-! ## The master decomposition and the duality identity -/

section Duality

variable [Nonempty ι] {p0 r p : ι → ℝ}

/-- **Master decomposition.** For any probability vector `p` and any tilt parameter `t`,
`KL(p ‖ p_t) = KL(p ‖ π₀) - t · 𝔼_p[r] + log Z(t)`.
This single identity is the engine of the whole file. -/
theorem klDiv_tilted_decomposition (hp0 : ∀ i, 0 < p0 i) (hp : IsProb p) (t : ℝ) :
    klDiv p (tilted p0 r t) = klDiv p p0 - t * expect p r + Real.log (partitionFn p0 r t) := by
  have hZ : 0 < partitionFn p0 r t := partitionFn_pos hp0 t
  have hterm : ∀ i : ι,
      p i * Real.log (p i / tilted p0 r t i)
        = p i * Real.log (p i / p0 i) - t * (p i * r i) + p i * Real.log (partitionFn p0 r t) := by
    intro i
    rcases eq_or_lt_of_le (hp.1 i) with h | h
    · simp [← h]
    · have hti : 0 < tilted p0 r t i := tilted_pos hp0 t i
      have hlt : Real.log (tilted p0 r t i)
          = Real.log (p0 i) + t * r i - Real.log (partitionFn p0 r t) := by
        unfold tilted
        rw [Real.log_div (mul_pos (hp0 i) (Real.exp_pos _)).ne' hZ.ne',
          Real.log_mul (hp0 i).ne' (Real.exp_ne_zero _),
          Real.log_exp]
      rw [Real.log_div h.ne' hti.ne', Real.log_div h.ne' (hp0 i).ne', hlt]
      ring
  unfold klDiv expect
  rw [Finset.sum_congr rfl (fun i _ => hterm i)]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.sum_mul, hp.2]
  ring

/-- The KL budget of the tilt, in closed form: `k(t) = t·𝔼_{p_t}[r] - log Z(t)`. -/
theorem klCurve_eq (hp0 : ∀ i, 0 < p0 i) (t : ℝ) :
    klCurve p0 r t = t * expect (tilted p0 r t) r - Real.log (partitionFn p0 r t) := by
  have h := klDiv_tilted_decomposition (r := r) hp0 (tilted_isProb (r := r) hp0 t) t
  have hzero : klDiv (tilted p0 r t) (tilted p0 r t) = 0 :=
    (klDiv_eq_zero_iff (tilted_isProb (r := r) hp0 t) (tilted_isProb (r := r) hp0 t)
      (tilted_pos hp0 t)).2 rfl
  rw [hzero] at h
  unfold klCurve
  linarith

/-- **The duality identity.**  For every probability vector `p` and every `t`,
`t · (𝔼_{p_t}[r] - 𝔼_p[r]) = KL(p_t‖π₀) - KL(p‖π₀) + KL(p‖p_t)`.
Both optimality of the tilt and monotonicity of the budget curve fall out of this. -/
theorem duality_identity (hp0 : ∀ i, 0 < p0 i) (hp : IsProb p) (t : ℝ) :
    t * (expect (tilted p0 r t) r - expect p r)
      = klCurve p0 r t - klDiv p p0 + klDiv p (tilted p0 r t) := by
  have h1 := klDiv_tilted_decomposition (r := r) hp0 hp t
  have h2 := klCurve_eq (p0 := p0) (r := r) hp0 t
  linarith [h1, h2]

/-! ## Optimality of the tilt inside a KL ball -/

/-- **Constrained optimality.** If `p` respects the KL budget of the tilt `p_t` (`t > 0`), then
`p` cannot beat `p_t` in expected reward. -/
theorem tilted_maximises (hp0 : ∀ i, 0 < p0 i) (hp : IsProb p) {t : ℝ} (ht : 0 < t)
    (hk : klDiv p p0 ≤ klCurve p0 r t) :
    expect p r ≤ expect (tilted p0 r t) r := by
  have hid := duality_identity (r := r) hp0 hp t
  have hnn : 0 ≤ klDiv p (tilted p0 r t) :=
    klDiv_nonneg hp (tilted_isProb (r := r) hp0 t) (tilted_pos hp0 t)
  nlinarith [hid, hnn, hk]

/-- **Uniqueness of the maximiser.** Any budget-feasible `p` attaining the tilt's expected reward
*is* the tilt. -/
theorem tilted_unique_maximiser (hp0 : ∀ i, 0 < p0 i) (hp : IsProb p) {t : ℝ}
    (hk : klDiv p p0 ≤ klCurve p0 r t)
    (heq : expect p r = expect (tilted p0 r t) r) :
    p = tilted p0 r t := by
  have hid := duality_identity (r := r) hp0 hp t
  rw [heq] at hid
  simp only [sub_self, mul_zero] at hid
  have hnn : 0 ≤ klDiv p (tilted p0 r t) :=
    klDiv_nonneg hp (tilted_isProb (r := r) hp0 t) (tilted_pos hp0 t)
  have : klDiv p (tilted p0 r t) = 0 := le_antisymm (by linarith) hnn
  exact (klDiv_eq_zero_iff hp (tilted_isProb (r := r) hp0 t) (tilted_pos hp0 t)).1 this

/-! ## Monotonicity, without calculus -/

/-- **Two-sided duality.** Applying `duality_identity` at `s` and at `t` and adding gives a
nonnegative-difference formula: `(t-s)(𝔼_t[r] - 𝔼_s[r]) = KL(p_s‖p_t) + KL(p_t‖p_s)`,
i.e. the Jeffreys divergence of the two tilts. -/
theorem jeffreys_identity (hp0 : ∀ i, 0 < p0 i) (s t : ℝ) :
    (t - s) * (expect (tilted p0 r t) r - expect (tilted p0 r s) r)
      = klDiv (tilted p0 r s) (tilted p0 r t) + klDiv (tilted p0 r t) (tilted p0 r s) := by
  have h1 := duality_identity (p := tilted p0 r s) (r := r) hp0 (tilted_isProb hp0 s) t
  have h2 := duality_identity (p := tilted p0 r t) (r := r) hp0 (tilted_isProb hp0 t) s
  have e1 : klDiv (tilted p0 r s) p0 = klCurve p0 r s := rfl
  have e2 : klDiv (tilted p0 r t) p0 = klCurve p0 r t := rfl
  rw [e1] at h1
  rw [e2] at h2
  nlinarith [h1, h2]

/-- Expected reward along the tilted path is monotone in the tilt parameter. -/
theorem expect_tilted_mono (hp0 : ∀ i, 0 < p0 i) : Monotone (fun t => expect (tilted p0 r t) r) := by
  intro s t hst
  rcases eq_or_lt_of_le hst with rfl | hlt
  · exact le_rfl
  · have hj := jeffreys_identity (r := r) hp0 s t
    have hn1 : 0 ≤ klDiv (tilted p0 r s) (tilted p0 r t) :=
      klDiv_nonneg (tilted_isProb hp0 s) (tilted_isProb hp0 t) (tilted_pos hp0 t)
    have hn2 : 0 ≤ klDiv (tilted p0 r t) (tilted p0 r s) :=
      klDiv_nonneg (tilted_isProb hp0 t) (tilted_isProb hp0 s) (tilted_pos hp0 s)
    have hpos : 0 < t - s := by linarith
    nlinarith [hj, hn1, hn2]

/-- Quantitative monotonicity of the KL budget curve: for `0 ≤ s ≤ t`,
`k(t) - k(s) ≥ KL(p_t ‖ p_s) ≥ 0`. -/
theorem klCurve_sub_ge_klDiv (hp0 : ∀ i, 0 < p0 i) {s t : ℝ} (hs : 0 ≤ s) (hst : s ≤ t) :
    klDiv (tilted p0 r t) (tilted p0 r s) ≤ klCurve p0 r t - klCurve p0 r s := by
  have h2 := duality_identity (p := tilted p0 r t) (r := r) hp0 (tilted_isProb hp0 t) s
  have e2 : klDiv (tilted p0 r t) p0 = klCurve p0 r t := rfl
  rw [e2] at h2
  have hmono : expect (tilted p0 r s) r ≤ expect (tilted p0 r t) r :=
    expect_tilted_mono (r := r) hp0 hst
  nlinarith [h2, hmono, hs]

/-- If two tilts coincide at different parameters then the reward is constant. -/
theorem tilted_eq_imp_reward_const (hp0 : ∀ i, 0 < p0 i) {s t : ℝ} (hst : s ≠ t)
    (h : tilted p0 r s = tilted p0 r t) : ∀ i j, r i = r j := by
  have hZs : 0 < partitionFn p0 r s := partitionFn_pos hp0 s
  have hZt : 0 < partitionFn p0 r t := partitionFn_pos hp0 t
  have key : ∀ i, (t - s) * r i = Real.log (partitionFn p0 r t) - Real.log (partitionFn p0 r s) := by
    intro i
    have hi := congrFun h i
    unfold tilted at hi
    rw [div_eq_div_iff hZs.ne' hZt.ne'] at hi
    have h1 : Real.log (p0 i * Real.exp (s * r i) * partitionFn p0 r t)
        = Real.log (p0 i * Real.exp (t * r i) * partitionFn p0 r s) := by rw [hi]
    rw [Real.log_mul (mul_pos (hp0 i) (Real.exp_pos _)).ne' hZt.ne',
      Real.log_mul (mul_pos (hp0 i) (Real.exp_pos _)).ne' hZs.ne',
      Real.log_mul (hp0 i).ne' (Real.exp_ne_zero _), Real.log_mul (hp0 i).ne' (Real.exp_ne_zero _),
      Real.log_exp, Real.log_exp] at h1
    linarith
  intro i j
  have hi := key i
  have hj := key j
  have hne : t - s ≠ 0 := sub_ne_zero.2 (Ne.symm hst)
  have : (t - s) * r i = (t - s) * r j := by rw [hi, hj]
  exact mul_left_cancel₀ hne this

/-- **Strict monotonicity of the KL budget curve on `[0, ∞)`** for a non-constant reward.
No differentiation of the log-partition function is used: the proof is the duality identity
applied twice. -/
theorem klCurve_strictMonoOn (hp0 : ∀ i, 0 < p0 i) (hnc : ∃ i j, r i ≠ r j) :
    StrictMonoOn (klCurve p0 r) (Set.Ici (0 : ℝ)) := by
  intro s hs t _ hst
  have hs0 : (0 : ℝ) ≤ s := hs
  have hne : tilted p0 r t ≠ tilted p0 r s := by
    intro hEq
    obtain ⟨i, j, hij⟩ := hnc
    exact hij (tilted_eq_imp_reward_const hp0 (ne_of_gt hst) hEq i j)
  have hpos : 0 < klDiv (tilted p0 r t) (tilted p0 r s) := by
    rcases lt_or_eq_of_le
      (klDiv_nonneg (tilted_isProb hp0 t) (tilted_isProb hp0 s) (tilted_pos hp0 s)) with h | h
    · exact h
    · exact absurd
        ((klDiv_eq_zero_iff (tilted_isProb hp0 t) (tilted_isProb hp0 s) (tilted_pos hp0 s)).1 h.symm)
        hne
  have := klCurve_sub_ge_klDiv (r := r) hp0 hs0 hst.le
  linarith

omit [Nonempty ι] in
/-- The budget curve starts at zero. -/
theorem klCurve_zero (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1) : klCurve p0 r 0 = 0 := by
  unfold klCurve
  have : tilted p0 r 0 = p0 := funext (fun i => tilted_zero (r := r) hs i)
  rw [this]
  exact (klDiv_eq_zero_iff ⟨fun i => (hp0 i).le, hs⟩ ⟨fun i => (hp0 i).le, hs⟩ hp0).2 rfl

/-- Consequently the budget curve is nonnegative on `[0, ∞)`. -/
theorem klCurve_nonneg (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1) (t : ℝ) :
    0 ≤ klCurve p0 r t :=
  klDiv_nonneg (tilted_isProb hp0 t) ⟨fun i => (hp0 i).le, hs⟩ hp0

end Duality

/-! ## The tropical ceiling: `β → 0` is Maslov dequantization -/

section Tropical

open Filter Topology

variable [Nonempty ι] {p0 r : ι → ℝ}

/-- The tropical (max-plus) value `⨁_i r i = max_i r i` of the reward vector. -/
noncomputable def rewardMax (r : ι → ℝ) : ℝ := Finset.univ.sup' Finset.univ_nonempty r

open scoped Classical in
/-- The set of reward-maximising outcomes: the tropical support of `r`. -/
noncomputable def argmaxSet (r : ι → ℝ) : Finset ι :=
  Finset.univ.filter (fun i => r i = rewardMax r)

/-- The reference mass carried by the argmax set. -/
noncomputable def argmaxMass (p0 r : ι → ℝ) : ℝ := ∑ i ∈ argmaxSet r, p0 i

/-- The **tropical ceiling** `L = -log π₀(argmax r)`: the supremum of achievable KL budgets. -/
noncomputable def tropicalCeiling (p0 r : ι → ℝ) : ℝ := - Real.log (argmaxMass p0 r)

/-- The zero-temperature limit policy: `π₀` conditioned on the argmax set. -/
noncomputable def tropicalLimitPolicy (p0 r : ι → ℝ) (i : ι) : ℝ :=
  if r i = rewardMax r then p0 i / argmaxMass p0 r else 0

lemma mem_argmaxSet_iff {i : ι} : i ∈ argmaxSet r ↔ r i = rewardMax r := by
  classical
  simp [argmaxSet]

lemma le_rewardMax (i : ι) : r i ≤ rewardMax r := Finset.le_sup' r (Finset.mem_univ i)

lemma argmaxSet_nonempty : (argmaxSet r).Nonempty := by
  obtain ⟨i, _, hi⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := ι)) r
  exact ⟨i, mem_argmaxSet_iff.2 hi.symm⟩

lemma argmaxMass_pos (hp0 : ∀ i, 0 < p0 i) : 0 < argmaxMass p0 r :=
  Finset.sum_pos (fun i _ => hp0 i) argmaxSet_nonempty

lemma argmaxMass_le_one (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1) : argmaxMass p0 r ≤ 1 := by
  rw [← hs]
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) (fun i _ _ => (hp0 i).le)

lemma tropicalCeiling_nonneg (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1) :
    0 ≤ tropicalCeiling p0 r := by
  have := Real.log_nonpos (argmaxMass_pos (r := r) hp0).le (argmaxMass_le_one (r := r) hp0 hs)
  simpa [tropicalCeiling] using this

/-! ### The two-sided tropical sandwich for the log-partition function -/

lemma partitionFn_le_exp (hs : ∑ i, p0 i = 1) (hp0 : ∀ i, 0 < p0 i) {t : ℝ} (ht : 0 ≤ t) :
    partitionFn p0 r t ≤ Real.exp (t * rewardMax r) := by
  have : partitionFn p0 r t ≤ ∑ i, p0 i * Real.exp (t * rewardMax r) := by
    refine Finset.sum_le_sum (fun i _ => ?_)
    exact mul_le_mul_of_nonneg_left
      (Real.exp_le_exp.2 (mul_le_mul_of_nonneg_left (le_rewardMax i) ht)) (hp0 i).le
  rwa [← Finset.sum_mul, hs, one_mul] at this

lemma argmaxMass_mul_exp_le_partitionFn (hp0 : ∀ i, 0 < p0 i) (t : ℝ) :
    argmaxMass p0 r * Real.exp (t * rewardMax r) ≤ partitionFn p0 r t := by
  have h1 : argmaxMass p0 r * Real.exp (t * rewardMax r)
      = ∑ i ∈ argmaxSet r, p0 i * Real.exp (t * r i) := by
    rw [argmaxMass, Finset.sum_mul]
    refine Finset.sum_congr rfl (fun i hi => by rw [mem_argmaxSet_iff.1 hi])
  rw [h1]
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
    (fun i _ _ => (mul_pos (hp0 i) (Real.exp_pos _)).le)

/-- **Tropical sandwich.** For `t ≥ 0`, `log Z(t)` differs from the tropical value `t·max r`
by at most `-log π₀(argmax r)`, the tropical ceiling. -/
theorem log_partitionFn_sandwich (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1) {t : ℝ} (ht : 0 ≤ t) :
    t * rewardMax r + Real.log (argmaxMass p0 r) ≤ Real.log (partitionFn p0 r t) ∧
      Real.log (partitionFn p0 r t) ≤ t * rewardMax r := by
  have hZ : 0 < partitionFn p0 r t := partitionFn_pos hp0 t
  have hw : 0 < argmaxMass p0 r := argmaxMass_pos (r := r) hp0
  constructor
  · have h := argmaxMass_mul_exp_le_partitionFn (r := r) hp0 t
    have := Real.log_le_log (by positivity) h
    rwa [Real.log_mul hw.ne' (Real.exp_ne_zero _), Real.log_exp, add_comm] at this
  · have h := partitionFn_le_exp (r := r) hs hp0 ht
    have := Real.log_le_log hZ h
    rwa [Real.log_exp] at this

/-- **Maslov dequantization.** `(1/t)·log Z(t) → max r` as the temperature `β = 1/t → 0`:
the log-partition function tropicalises to the max-plus value of the reward. -/
theorem tropical_limit_of_logPartition (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1) :
    Tendsto (fun t => Real.log (partitionFn p0 r t) / t) atTop (𝓝 (rewardMax r)) := by
  have hw : 0 < argmaxMass p0 r := argmaxMass_pos (r := r) hp0
  have hlow : ∀ᶠ t in atTop,
      rewardMax r + Real.log (argmaxMass p0 r) / t ≤ Real.log (partitionFn p0 r t) / t := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
    have h := (log_partitionFn_sandwich (r := r) hp0 hs ht.le).1
    have key : rewardMax r + Real.log (argmaxMass p0 r) / t
        = (t * rewardMax r + Real.log (argmaxMass p0 r)) / t := by
      field_simp
    rw [key]
    gcongr
  have hhigh : ∀ᶠ t in atTop, Real.log (partitionFn p0 r t) / t ≤ rewardMax r := by
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
    have h := (log_partitionFn_sandwich (r := r) hp0 hs ht.le).2
    rw [div_le_iff₀ ht]
    linarith [h]
  have hL : Tendsto (fun t : ℝ => rewardMax r + Real.log (argmaxMass p0 r) / t) atTop
      (𝓝 (rewardMax r)) := by
    have : Tendsto (fun t : ℝ => Real.log (argmaxMass p0 r) / t) atTop (𝓝 0) :=
      Filter.Tendsto.div_atTop tendsto_const_nhds tendsto_id
    simpa using tendsto_const_nhds.add this
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' hL tendsto_const_nhds hlow hhigh

/-! ### The KL budget curve never exceeds the tropical ceiling -/

lemma expect_le_rewardMax {p : ι → ℝ} (hp : IsProb p) : expect p r ≤ rewardMax r := by
  have : expect p r ≤ ∑ i, p i * rewardMax r :=
    Finset.sum_le_sum (fun i _ => mul_le_mul_of_nonneg_left (le_rewardMax i) (hp.1 i))
  rwa [← Finset.sum_mul, hp.2, one_mul] at this

/-- **The tropical ceiling is a hard cap on the KL budget.** -/
theorem klCurve_le_tropicalCeiling (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1) {t : ℝ}
    (ht : 0 ≤ t) : klCurve p0 r t ≤ tropicalCeiling p0 r := by
  have hk := klCurve_eq (p0 := p0) (r := r) hp0 t
  have h1 := (log_partitionFn_sandwich (r := r) hp0 hs ht).1
  have h2 : expect (tilted p0 r t) r ≤ rewardMax r :=
    expect_le_rewardMax (r := r) (tilted_isProb hp0 t)
  have h3 : t * expect (tilted p0 r t) r ≤ t * rewardMax r :=
    mul_le_mul_of_nonneg_left h2 ht
  rw [hk, tropicalCeiling]
  linarith

/-- Strict version: for a non-constant reward the ceiling is never attained. -/
theorem klCurve_lt_tropicalCeiling (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1)
    (hnc : ∃ i j, r i ≠ r j) {t : ℝ} (ht : 0 ≤ t) : klCurve p0 r t < tropicalCeiling p0 r := by
  have h1 : klCurve p0 r t < klCurve p0 r (t + 1) :=
    klCurve_strictMonoOn hp0 hnc ht (by simp; linarith) (by linarith)
  have h2 := klCurve_le_tropicalCeiling (r := r) hp0 hs (t := t + 1) (by linarith)
  linarith

/-! ### Continuity of the budget curve -/

omit [Nonempty ι] in
lemma continuous_partitionFn : Continuous (partitionFn p0 r) := by
  unfold partitionFn
  exact continuous_finset_sum _ (fun i _ => by fun_prop)

lemma continuous_tilted (hp0 : ∀ i, 0 < p0 i) (i : ι) :
    Continuous (fun t => tilted p0 r t i) := by
  unfold tilted
  exact Continuous.div (by fun_prop) continuous_partitionFn
    (fun t => (partitionFn_pos hp0 t).ne')

lemma continuous_klCurve (hp0 : ∀ i, 0 < p0 i) : Continuous (klCurve p0 r) := by
  have h : klCurve p0 r
      = fun t => t * (∑ i, tilted p0 r t i * r i) - Real.log (partitionFn p0 r t) := by
    funext t
    simpa [expect] using klCurve_eq (p0 := p0) (r := r) hp0 t
  rw [h]
  refine Continuous.sub ?_ (continuous_partitionFn.log (fun t => (partitionFn_pos hp0 t).ne'))
  exact continuous_id.mul
    (continuous_finset_sum _ (fun i _ => (continuous_tilted hp0 i).mul continuous_const))

/-! ### The zero-temperature limit of the tilted family -/

lemma tendsto_exp_mul_of_neg {c : ℝ} (hc : c < 0) :
    Tendsto (fun t : ℝ => Real.exp (t * c)) atTop (𝓝 0) := by
  refine Real.tendsto_exp_atBot.comp ?_
  exact (Filter.Tendsto.atTop_mul_neg hc tendsto_id tendsto_const_nhds).mono_right (by simp)

lemma partitionFn_factor (t : ℝ) :
    partitionFn p0 r t
      = Real.exp (t * rewardMax r) * ∑ j, p0 j * Real.exp (t * (r j - rewardMax r)) := by
  unfold partitionFn
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl (fun j _ => ?_)
  rw [← mul_assoc, mul_comm (Real.exp (t * rewardMax r)) (p0 j), mul_assoc, ← Real.exp_add]
  ring_nf

lemma tendsto_normalisedPartition :
    Tendsto (fun t => ∑ j, p0 j * Real.exp (t * (r j - rewardMax r))) atTop
      (𝓝 (argmaxMass p0 r)) := by
  classical
  have hmass : argmaxMass p0 r = ∑ j, (if r j = rewardMax r then p0 j else 0) := by
    rw [argmaxMass, argmaxSet, Finset.sum_filter]
  rw [hmass]
  refine tendsto_finset_sum _ (fun j _ => ?_)
  by_cases hj : r j = rewardMax r
  · simp [hj]
  · have hneg : r j - rewardMax r < 0 := sub_neg.2 (lt_of_le_of_ne (le_rewardMax j) hj)
    simpa [hj] using (tendsto_exp_mul_of_neg hneg).const_mul (p0 j)

lemma tendsto_tilted (hp0 : ∀ i, 0 < p0 i) (i : ι) :
    Tendsto (fun t => tilted p0 r t i) atTop (𝓝 (tropicalLimitPolicy p0 r i)) := by
  classical
  have hw : 0 < argmaxMass p0 r := argmaxMass_pos (r := r) hp0
  have hrw : ∀ t : ℝ, tilted p0 r t i
      = (p0 i * Real.exp (t * (r i - rewardMax r)))
        / (∑ j, p0 j * Real.exp (t * (r j - rewardMax r))) := by
    intro t
    have hY : (∑ j, p0 j * Real.exp (t * (r j - rewardMax r))) ≠ 0 := by
      have : 0 < ∑ j, p0 j * Real.exp (t * (r j - rewardMax r)) :=
        Finset.sum_pos (fun j _ => mul_pos (hp0 j) (Real.exp_pos _)) Finset.univ_nonempty
      exact this.ne'
    have hexp : Real.exp (t * r i)
        = Real.exp (t * rewardMax r) * Real.exp (t * (r i - rewardMax r)) := by
      rw [← Real.exp_add]; ring_nf
    have hE : Real.exp (t * rewardMax r) ≠ 0 := (Real.exp_pos _).ne'
    rw [tilted, partitionFn_factor, hexp]
    field_simp
  simp only [hrw]
  have hnum : Tendsto (fun t : ℝ => p0 i * Real.exp (t * (r i - rewardMax r))) atTop
      (𝓝 (if r i = rewardMax r then p0 i else 0)) := by
    by_cases hi : r i = rewardMax r
    · simp [hi]
    · have hneg : r i - rewardMax r < 0 := sub_neg.2 (lt_of_le_of_ne (le_rewardMax i) hi)
      simpa [hi] using (tendsto_exp_mul_of_neg hneg).const_mul (p0 i)
  have := hnum.div (tendsto_normalisedPartition (p0 := p0) (r := r)) hw.ne'
  have heq : (if r i = rewardMax r then p0 i else 0) / argmaxMass p0 r
      = tropicalLimitPolicy p0 r i := by
    unfold tropicalLimitPolicy
    by_cases hi : r i = rewardMax r <;> simp [hi]
  rwa [heq] at this

/-! ### The budget curve converges to the tropical ceiling -/

omit [Nonempty ι] in
lemma klDiv_eq_entropyForm {p : ι → ℝ} (hp0 : ∀ i, 0 < p0 i) (hp : ∀ i, 0 ≤ p i) :
    klDiv p p0 = ∑ i, (p i * Real.log (p i) - p i * Real.log (p0 i)) := by
  refine Finset.sum_congr rfl (fun i _ => ?_)
  rcases eq_or_lt_of_le (hp i) with h | h
  · simp [← h]
  · rw [Real.log_div h.ne' (hp0 i).ne']; ring

lemma entropyForm_tropicalLimitPolicy (hp0 : ∀ i, 0 < p0 i) :
    ∑ i, (tropicalLimitPolicy p0 r i * Real.log (tropicalLimitPolicy p0 r i)
      - tropicalLimitPolicy p0 r i * Real.log (p0 i)) = tropicalCeiling p0 r := by
  classical
  set w := argmaxMass p0 r with hwdef
  have hw : 0 < w := argmaxMass_pos (r := r) hp0
  have hzero : ∀ x ∈ (Finset.univ : Finset ι), x ∉ argmaxSet r →
      tropicalLimitPolicy p0 r x * Real.log (tropicalLimitPolicy p0 r x)
        - tropicalLimitPolicy p0 r x * Real.log (p0 x) = 0 := by
    intro x _ hx
    have hzx : tropicalLimitPolicy p0 r x = 0 := by
      unfold tropicalLimitPolicy
      rw [if_neg (fun h => hx (mem_argmaxSet_iff.2 h))]
    simp [hzx]
  rw [← Finset.sum_subset (Finset.subset_univ (argmaxSet r)) hzero]
  have hterm : ∀ i ∈ argmaxSet r,
      tropicalLimitPolicy p0 r i * Real.log (tropicalLimitPolicy p0 r i)
        - tropicalLimitPolicy p0 r i * Real.log (p0 i) = p0 i * (-(Real.log w) / w) := by
    intro i hi
    have hri : r i = rewardMax r := mem_argmaxSet_iff.1 hi
    have hq : tropicalLimitPolicy p0 r i = p0 i / w := by
      unfold tropicalLimitPolicy; simp [hri, hwdef]
    rw [hq, Real.log_div (hp0 i).ne' hw.ne']
    field_simp
    ring
  rw [Finset.sum_congr rfl hterm, ← Finset.sum_mul]
  have hsw : (∑ i ∈ argmaxSet r, p0 i) = w := by rw [hwdef, argmaxMass]
  rw [hsw, tropicalCeiling, ← hwdef, mul_comm, div_mul_cancel₀ _ hw.ne']

/-- **The KL budget curve fills the interval `[0, L)`.** As the tilt parameter goes to infinity
(temperature `β → 0`), the KL budget converges to the tropical ceiling. -/
theorem klCurve_tendsto_tropicalCeiling (hp0 : ∀ i, 0 < p0 i) :
    Tendsto (klCurve p0 r) atTop (𝓝 (tropicalCeiling p0 r)) := by
  have hrw : klCurve p0 r
      = fun t => ∑ i, (tilted p0 r t i * Real.log (tilted p0 r t i)
          - tilted p0 r t i * Real.log (p0 i)) :=
    funext (fun t => klDiv_eq_entropyForm hp0 (fun i => (tilted_pos hp0 t i).le))
  rw [hrw]
  rw [← entropyForm_tropicalLimitPolicy (r := r) hp0]
  refine tendsto_finset_sum _ (fun i _ => ?_)
  have h1 := tendsto_tilted (r := r) hp0 i
  have h2 : Tendsto (fun t => tilted p0 r t i * Real.log (tilted p0 r t i)) atTop
      (𝓝 (tropicalLimitPolicy p0 r i * Real.log (tropicalLimitPolicy p0 r i))) :=
    (Real.continuous_mul_log.tendsto _).comp h1
  exact h2.sub (h1.mul_const _)

/-! ## Main theorems: the achievable range and `constrained = penalised` -/

/-- **Existence and uniqueness of the tilt realising a prescribed KL budget.**
For every `k` in the achievable range `[0, L)` there is exactly one `t ≥ 0` with
`KL(p_t ‖ π₀) = k`. -/
theorem existsUnique_tilt_of_lt_ceiling (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1)
    (hnc : ∃ i j, r i ≠ r j) {k : ℝ} (hk0 : 0 ≤ k) (hkL : k < tropicalCeiling p0 r) :
    ∃! t : ℝ, 0 ≤ t ∧ klCurve p0 r t = k := by
  obtain ⟨T, hT0, hTk⟩ : ∃ T : ℝ, 0 ≤ T ∧ k ≤ klCurve p0 r T := by
    have hev : ∀ᶠ t in atTop, k < klCurve p0 r t :=
      (klCurve_tendsto_tropicalCeiling (r := r) hp0).eventually (lt_mem_nhds hkL)
    obtain ⟨T, hT1, hT2⟩ := ((eventually_ge_atTop (0 : ℝ)).and hev).exists
    exact ⟨T, hT1, hT2.le⟩
  have hcont : ContinuousOn (klCurve p0 r) (Set.Icc 0 T) :=
    (continuous_klCurve hp0).continuousOn
  have hmem : k ∈ Set.Icc (klCurve p0 r 0) (klCurve p0 r T) := by
    rw [klCurve_zero (r := r) hp0 hs]
    exact ⟨hk0, hTk⟩
  obtain ⟨t, htmem, hteq⟩ := intermediate_value_Icc hT0 hcont hmem
  refine ⟨t, ⟨htmem.1, hteq⟩, ?_⟩
  rintro s ⟨hs0, hseq⟩
  exact (klCurve_strictMonoOn hp0 hnc).injOn hs0 htmem.1 (by rw [hseq, hteq])

/-- **Every achievable KL budget comes from a unique temperature `β > 0`.**
This is the first half of the duality core: the penalised family `π*_β` sweeps out the whole
achievable range `(0, L)` of KL budgets, bijectively. -/
theorem existsUnique_beta_of_lt_ceiling (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1)
    (hnc : ∃ i j, r i ≠ r j) {k : ℝ} (hk0 : 0 < k) (hkL : k < tropicalCeiling p0 r) :
    ∃! β : ℝ, 0 < β ∧ klDiv (piStar p0 r β) p0 = k := by
  obtain ⟨t, ⟨ht0, hteq⟩, htuniq⟩ :=
    existsUnique_tilt_of_lt_ceiling (r := r) hp0 hs hnc hk0.le hkL
  have htpos : 0 < t := by
    rcases eq_or_lt_of_le ht0 with h | h
    · rw [← h, klCurve_zero (r := r) hp0 hs] at hteq; exact absurd hteq hk0.ne
    · exact h
  refine ⟨t⁻¹, ⟨inv_pos.2 htpos, ?_⟩, ?_⟩
  · show klCurve p0 r (t⁻¹)⁻¹ = k
    rwa [inv_inv]
  · rintro β ⟨hβ, hβeq⟩
    have : β⁻¹ = t := htuniq β⁻¹ ⟨(inv_pos.2 hβ).le, hβeq⟩
    rw [← this, inv_inv]

/-- **Constrained optimality of the penalised solution.**  `π*_β` attains the maximum of the
expected reward over the whole KL ball of radius `k = KL(π*_β ‖ π₀)`. -/
theorem piStar_isGreatest (hp0 : ∀ i, 0 < p0 i) {β k : ℝ} (hβ : 0 < β)
    (hval : klDiv (piStar p0 r β) p0 = k) :
    IsGreatest {v : ℝ | ∃ p, IsProb p ∧ klDiv p p0 ≤ k ∧ expect p r = v}
      (expect (piStar p0 r β) r) := by
  have hk : klCurve p0 r β⁻¹ = k := hval
  constructor
  · exact ⟨piStar p0 r β, tilted_isProb hp0 _, le_of_eq hval, rfl⟩
  · rintro v ⟨p, hp, hple, rfl⟩
    exact tilted_maximises hp0 hp (inv_pos.2 hβ) (by rw [hk]; exact hple)

/-- **Uniqueness of the constrained optimum.** -/
theorem piStar_unique_optimum (hp0 : ∀ i, 0 < p0 i) {β k : ℝ}
    (hval : klDiv (piStar p0 r β) p0 = k) {p : ι → ℝ} (hp : IsProb p)
    (hple : klDiv p p0 ≤ k) (hopt : expect p r = expect (piStar p0 r β) r) :
    p = piStar p0 r β := by
  have hk : klCurve p0 r β⁻¹ = k := hval
  exact tilted_unique_maximiser hp0 hp (by rw [hk]; exact hple) hopt

/-- **Constrained = penalised.**  For every KL budget `k` strictly between `0` and the tropical
ceiling `L = -log π₀(argmax r)`, there is a unique inverse-temperature `β > 0` whose penalised
optimum `π*_β` sits exactly on the budget, and that `π*_β` is the unique maximiser of the
expected reward over the KL ball `{p : KL(p‖π₀) ≤ k}`. -/
theorem constrained_eq_penalised (hp0 : ∀ i, 0 < p0 i) (hs : ∑ i, p0 i = 1)
    (hnc : ∃ i j, r i ≠ r j) {k : ℝ} (hk0 : 0 < k) (hkL : k < tropicalCeiling p0 r) :
    ∃! β : ℝ, 0 < β ∧ klDiv (piStar p0 r β) p0 = k ∧
      IsGreatest {v : ℝ | ∃ p, IsProb p ∧ klDiv p p0 ≤ k ∧ expect p r = v}
        (expect (piStar p0 r β) r) ∧
      ∀ p, IsProb p → klDiv p p0 ≤ k → expect p r = expect (piStar p0 r β) r →
        p = piStar p0 r β := by
  obtain ⟨β, ⟨hβ, hβk⟩, huniq⟩ := existsUnique_beta_of_lt_ceiling (r := r) hp0 hs hnc hk0 hkL
  refine ⟨β, ⟨hβ, hβk, piStar_isGreatest hp0 hβ hβk,
    fun p hp hple hopt => piStar_unique_optimum hp0 hβk hp hple hopt⟩, ?_⟩
  rintro γ ⟨hγ, hγk, -, -⟩
  exact huniq γ ⟨hγ, hγk⟩

end Tropical

/-! ## A concrete witness: the hypotheses of `constrained_eq_penalised` are satisfiable

Lab note.  Two outcomes, a uniform SFT reference `π₀ = (1/2, 1/2)` and the reward `r = (0, 1)`.
Here `max r = 1`, the argmax set is `{true}` of reference mass `1/2`, so the tropical ceiling is
`L = log 2 ≈ 0.693`.  Every budget `k ∈ (0, log 2)` is therefore realised by exactly one `β > 0`.
Explicitly `π*_β = (1/(1+e^{1/β}), e^{1/β}/(1+e^{1/β}))`, a logistic sweep from `(1/2,1/2)`
(`β → ∞`) to `(0,1)` (`β → 0`), whose KL budget sweeps `[0, log 2)`. -/

section Witness

open Filter Topology

/-- The uniform reference distribution on two outcomes. -/
noncomputable def unif2 : Bool → ℝ := fun _ => 1 / 2

/-- A binary reward: `1` for `true`, `0` for `false`. -/
noncomputable def rew2 : Bool → ℝ := fun b => if b then 1 else 0

lemma unif2_pos : ∀ b, 0 < unif2 b := by intro b; norm_num [unif2]

lemma unif2_sum : ∑ b, unif2 b = 1 := by simp [unif2]

lemma rew2_nonconstant : ∃ i j, rew2 i ≠ rew2 j := ⟨true, false, by norm_num [rew2]⟩

lemma rewardMax_rew2 : rewardMax rew2 = 1 := by
  refine le_antisymm (Finset.sup'_le _ _ (fun i _ => ?_)) ?_
  · cases i <;> norm_num [rew2]
  · rw [rewardMax]
    have h := Finset.le_sup' rew2 (Finset.mem_univ true)
    have h1 : rew2 true = 1 := by norm_num [rew2]
    rw [h1] at h
    exact h

lemma argmaxSet_rew2 : argmaxSet rew2 = {true} := by
  classical
  ext i
  rw [mem_argmaxSet_iff, rewardMax_rew2]
  cases i <;> simp [rew2]

lemma argmaxMass_unif2 : argmaxMass unif2 rew2 = 1 / 2 := by
  rw [argmaxMass, argmaxSet_rew2]
  simp [unif2]

/-- The tropical ceiling of this instance is `log 2`. -/
lemma tropicalCeiling_unif2 : tropicalCeiling unif2 rew2 = Real.log 2 := by
  rw [tropicalCeiling, argmaxMass_unif2]
  rw [show (1 : ℝ) / 2 = (2 : ℝ)⁻¹ by norm_num, Real.log_inv]
  ring

/-- **Non-vacuity.**  In the two-outcome instance every budget `k ∈ (0, log 2)` is achievable,
so `constrained_eq_penalised` has genuine content there. -/
theorem constrained_eq_penalised_witness {k : ℝ} (hk0 : 0 < k) (hkL : k < Real.log 2) :
    ∃! β : ℝ, 0 < β ∧ klDiv (piStar unif2 rew2 β) unif2 = k ∧
      IsGreatest {v : ℝ | ∃ p, IsProb p ∧ klDiv p unif2 ≤ k ∧ expect p rew2 = v}
        (expect (piStar unif2 rew2 β) rew2) ∧
      ∀ p, IsProb p → klDiv p unif2 ≤ k → expect p rew2 = expect (piStar unif2 rew2 β) rew2 →
        p = piStar unif2 rew2 β :=
  constrained_eq_penalised unif2_pos unif2_sum rew2_nonconstant hk0
    (by rw [tropicalCeiling_unif2]; exact hkL)

/-- The interval of achievable budgets in the witness instance is non-degenerate. -/
lemma log_two_pos : 0 < Real.log 2 := Real.log_pos (by norm_num)

end Witness

end Catalog.Tropical.ConstrainedPenalised