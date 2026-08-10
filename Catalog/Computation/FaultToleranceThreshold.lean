import Mathlib

/-!
# The fault-tolerance threshold theorem, sharply

Every recursive fault-tolerance scheme — code concatenation, magic-state distillation,
recursive purification — is governed by one *one-step error map*

  `p ↦ C · p ^ k`,

where `k` is the number of independent faults needed to defeat one level of the scheme
(`k = 2` for a distance-3 concatenated code, `k = 3` for the 15-to-1 magic-state
distillation routine) and `C` counts the malignant fault locations.  The threshold
theorem is the statement that this map has a *sharp* critical point, and that below it
the error rate decays **doubly exponentially** in the number of levels.

Writing `C = a ^ m` and `k = m + 1` (i.e. `a = C ^ (1/(k-1))` is the reciprocal of the
threshold) turns the whole theory into one exact algebraic identity,

  `a · pₙ = (a · p) ^ (k ^ n)`   (`ftIter_rescaled`),

from which every analytic statement below follows.  This is the reason the threshold is
*sharp*: the rescaled variable `a · p` is an exact conjugacy invariant of the recursion,
so the dynamics is literally `x ↦ x ^ k` on `[0, ∞)`, whose only fixed points are `0`,
`1`, and `∞`.

## Main results

* `ftIter_rescaled` — the exact conjugacy identity; everything else is a corollary.
* `ftIter_tendsto_zero` / `ftIter_tendsto_atTop` / `ftIter_critical` — the trichotomy
  below / above / at the threshold `p_th = 1/a`.
* `ftIter_tendsto_zero_iff` — **sharpness**: for a positive error rate, the scheme works
  *iff* `p < 1/a`.  No gap between the two regimes.
* `ftIter_le_doubly_exponential` — the doubly-exponential suppression law.
* `ftIter_le_of_level`, `ftIter_le_at_loglog_level` — the overhead law: `log log (1/ε)`
  levels of recursion suffice for target accuracy `ε`.
* `concatenation_standard_form` — the textbook formula `p_L = p_th · (p/p_th) ^ (2 ^ L)`.
* `steane_threshold_one_percent`, `magic_state_distillation_15to1_converges` — numerical
  instances (`C = 100`, and `p_out = 35 p³`).
* `union_bound`, `threshold_theorem_circuit`, `gadget_size_polylog`, `threshold_theorem` —
  the algorithmic form: an `L`-location computation reaches total failure `η` with
  `log log (L/η)` levels and only polylogarithmic gadget-size overhead.

-- !-- Lab Notebook -- !--
-- Hypothesis:  The threshold theorem is usually stated as an inequality ("if p < p_th
--   then the error can be made arbitrarily small"), which leaves open whether the
--   transition is sharp.  Conjecture: it is exactly sharp, with no intermediate regime.
-- Experiment 1:  Rescale by the conjectured threshold.  Setting q = a·p turns the
--   recursion into q ↦ q^k *exactly*, with no error term (`ftIter_rescaled`).  This is
--   the reason the transition is sharp rather than merely monotone.
-- Experiment 2:  Test the boundary case q = 1.  The iteration is then *constant*
--   (`ftIter_critical`) — not decaying, not diverging.  So the threshold value itself
--   belongs to the "fails" side, and `ftIter_tendsto_zero_iff` has the strict `<`.
-- Experiment 3:  Numerical spot-check of the 15-to-1 distillation map at p = 0.1 with
--   C = 35:  0.1 → 0.035 → 1.50·10⁻³ → 1.18·10⁻⁷ → 5.79·10⁻²⁰.  Four rounds already reach
--   6·10⁻²⁰, matching the doubly-exponential law (3^n in the exponent).  Formalised as
--   `magic_state_distillation_15to1_converges`.
-- Failure analysis:  A first attempt used `C` directly and needed `C ^ (1/(k-1))`, i.e.
--   real exponents, inside the induction; the `rpow` side conditions made the induction
--   unusable.  Reparametrising by `a` with `C = a ^ m` removes every `rpow` from the
--   core argument and leaves a two-line induction.  Classified as "needs a different
--   definition", not "true but hard".
-/

open Filter Topology

namespace FaultTolerance

/-- The level-`n` logical error rate of a recursive fault-tolerance scheme whose one-step
error map is `p ↦ a ^ m * p ^ (m + 1)`.  The reciprocal `1 / a` is the threshold, and
`k = m + 1` is the number of independent faults needed to defeat one level: `m = 1` is
code concatenation with a distance-3 code, `m = 2` is 15-to-1 magic-state distillation. -/
def ftIter (a : ℝ) (m : ℕ) (p : ℝ) : ℕ → ℝ
  | 0 => p
  | n + 1 => a ^ m * (ftIter a m p n) ^ (m + 1)

@[simp] theorem ftIter_zero (a : ℝ) (m : ℕ) (p : ℝ) : ftIter a m p 0 = p := rfl

@[simp] theorem ftIter_succ (a : ℝ) (m : ℕ) (p : ℝ) (n : ℕ) :
    ftIter a m p (n + 1) = a ^ m * (ftIter a m p n) ^ (m + 1) := rfl

/-! ## The exact conjugacy identity -/

/-- **The threshold identity.**  In the rescaled variable `a · p` the recursion is
*exactly* `x ↦ x ^ (m+1)`; hence `a · pₙ = (a · p) ^ ((m+1) ^ n)`.  Every statement in
this file is a corollary of this single identity, which is why the threshold is sharp. -/
theorem ftIter_rescaled (a : ℝ) (m : ℕ) (p : ℝ) (n : ℕ) :
    a * ftIter a m p n = (a * p) ^ ((m + 1) ^ n) := by
  induction n with
  | zero => simp
  | succ n ih =>
      have h : a * (a ^ m * (ftIter a m p n) ^ (m + 1))
          = (a * ftIter a m p n) ^ (m + 1) := by
        rw [mul_pow, ← mul_assoc]
        ring
      rw [ftIter_succ, h, ih, ← pow_mul, pow_succ]

/-- Closed form for the level-`n` error rate. -/
theorem ftIter_eq_div (a : ℝ) (m : ℕ) (p : ℝ) (n : ℕ) (ha : a ≠ 0) :
    ftIter a m p n = (a * p) ^ ((m + 1) ^ n) / a := by
  rw [← ftIter_rescaled a m p n]
  field_simp

/-- Nonnegativity is preserved by the recursion. -/
theorem ftIter_nonneg {a p : ℝ} (m : ℕ) (ha : 0 ≤ a) (hp : 0 ≤ p) (n : ℕ) :
    0 ≤ ftIter a m p n := by
  induction n with
  | zero => simpa using hp
  | succ n ih => exact mul_nonneg (pow_nonneg ha m) (pow_nonneg ih _)

/-! ## The trichotomy at the threshold `p_th = 1 / a` -/

/-- **Below threshold.**  If `p < 1/a` (equivalently `a p < 1`) the logical error rate
tends to `0` as the number of levels grows. -/
theorem ftIter_tendsto_zero {a p : ℝ} {m : ℕ} (ha : 0 < a) (hp : 0 ≤ p)
    (hm : 1 ≤ m) (hlt : a * p < 1) :
    Tendsto (ftIter a m p) atTop (𝓝 0) := by
  have hq : 0 ≤ a * p := mul_nonneg ha.le hp
  have h1 : Tendsto (fun N : ℕ => (a * p) ^ N) atTop (𝓝 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one hq hlt
  have h2 : Tendsto (fun n : ℕ => (m + 1) ^ n) atTop atTop :=
    tendsto_pow_atTop_atTop_of_one_lt (by omega)
  have h3 : Tendsto (fun n : ℕ => (a * p) ^ ((m + 1) ^ n)) atTop (𝓝 0) := h1.comp h2
  have h4 := h3.div_const a
  simp only [zero_div] at h4
  refine h4.congr fun n => ?_
  rw [ftIter_eq_div a m p n ha.ne']

/-- **Above threshold.**  If `p > 1/a` the logical error rate diverges: recursion makes
things strictly worse, at a doubly-exponential rate. -/
theorem ftIter_tendsto_atTop {a p : ℝ} {m : ℕ} (ha : 0 < a) (hm : 1 ≤ m)
    (hgt : 1 < a * p) :
    Tendsto (ftIter a m p) atTop atTop := by
  have h1 : Tendsto (fun N : ℕ => (a * p) ^ N) atTop atTop :=
    tendsto_pow_atTop_atTop_of_one_lt hgt
  have h2 : Tendsto (fun n : ℕ => (m + 1) ^ n) atTop atTop :=
    tendsto_pow_atTop_atTop_of_one_lt (by omega)
  have h3 : Tendsto (fun n : ℕ => (a * p) ^ ((m + 1) ^ n)) atTop atTop := h1.comp h2
  have h4 := h3.atTop_div_const ha
  refine h4.congr fun n => ?_
  rw [ftIter_eq_div a m p n ha.ne']

/-- **At threshold.**  Exactly at `p = 1/a` the recursion is stationary: every level has
the same error rate, so recursion neither helps nor hurts. -/
theorem ftIter_critical {a p : ℝ} {m : ℕ} (ha : 0 < a) (hcrit : a * p = 1) (n : ℕ) :
    ftIter a m p n = p := by
  have h := ftIter_rescaled a m p n
  rw [hcrit, one_pow] at h
  exact mul_left_cancel₀ ha.ne' (h.trans hcrit.symm)

/-- **Sharpness of the threshold.**  For a strictly positive physical error rate the
recursive scheme succeeds *if and only if* `p` is strictly below the threshold `1/a`.
There is no intermediate regime, and the threshold value itself fails. -/
theorem ftIter_tendsto_zero_iff {a p : ℝ} {m : ℕ} (ha : 0 < a) (hp : 0 < p) (hm : 1 ≤ m) :
    Tendsto (ftIter a m p) atTop (𝓝 0) ↔ a * p < 1 := by
  refine ⟨fun h => ?_, ftIter_tendsto_zero ha hp.le hm⟩
  by_contra hge
  push_neg at hge
  -- above (or at) threshold every level is at least `1/a`, so the limit cannot be `0`
  have hlow : ∀ n, a⁻¹ ≤ ftIter a m p n := by
    intro n
    have h1 : (1 : ℝ) ≤ (a * p) ^ ((m + 1) ^ n) := one_le_pow₀ hge
    have h2 := ftIter_rescaled a m p n
    rw [inv_le_iff_one_le_mul₀ ha]
    rw [mul_comm] at h2
    linarith [h2 ▸ h1]
  have : a⁻¹ ≤ (0 : ℝ) := ge_of_tendsto h (Eventually.of_forall hlow)
  exact absurd this (not_le.2 (inv_pos.2 ha))

/-! ## Doubly-exponential suppression and the overhead law -/

/-- **Doubly-exponential suppression.**  Below threshold the level-`n` error rate is at
most `(a p) ^ (2 ^ n) / a`: the exponent itself grows exponentially in the number of
levels.  (For `m ≥ 1` the true rate `(m+1)^n` is even faster.) -/
theorem ftIter_le_doubly_exponential {a p : ℝ} {m : ℕ} (ha : 0 < a) (hp : 0 ≤ p)
    (hm : 1 ≤ m) (hle : a * p ≤ 1) (n : ℕ) :
    ftIter a m p n ≤ (a * p) ^ (2 ^ n) / a := by
  have hq : 0 ≤ a * p := mul_nonneg ha.le hp
  have hexp : 2 ^ n ≤ (m + 1) ^ n := Nat.pow_le_pow_left (by omega) n
  have h : (a * p) ^ ((m + 1) ^ n) ≤ (a * p) ^ (2 ^ n) := pow_le_pow_of_le_one hq hle hexp
  rw [ftIter_eq_div a m p n ha.ne']
  exact (div_le_div_iff_of_pos_right ha).mpr h

/-- **Overhead law (quantitative).**  If the number of recursion levels `n` satisfies
`log (a ε) / log (a p) ≤ (m+1) ^ n` then the level-`n` error rate is below `ε`.  Since
the right-hand side is exponential in `n`, `n ≈ log₂ log (1/ε)` levels suffice. -/
theorem ftIter_le_of_level {a p ε : ℝ} {m : ℕ} (ha : 0 < a) (hp : 0 < p) (heps : 0 < ε)
    (hlt : a * p < 1) (n : ℕ)
    (hn : Real.log (a * ε) / Real.log (a * p) ≤ ((m + 1) ^ n : ℕ)) :
    ftIter a m p n ≤ ε := by
  set q := a * p with hqdef
  have hq0 : 0 < q := mul_pos ha hp
  have hlogq : Real.log q < 0 := Real.log_neg hq0 hlt
  set N : ℕ := (m + 1) ^ n with hN
  have hstep : (N : ℝ) * Real.log q ≤ Real.log (a * ε) := by
    have := mul_le_mul_of_nonneg_right hn (le_of_lt (neg_pos.2 hlogq))
    nlinarith [hn, hlogq, div_mul_cancel₀ (Real.log (a * ε)) hlogq.ne]
  have hqN : q ^ N ≤ a * ε := by
    have hpos : (0 : ℝ) < q ^ N := pow_pos hq0 N
    have : Real.log (q ^ N) ≤ Real.log (a * ε) := by
      rwa [Real.log_pow]
    exact (Real.log_le_log_iff hpos (by positivity)).1 this
  rw [ftIter_eq_div a m p n ha.ne', div_le_iff₀ ha]
  exact hqN.trans_eq (mul_comm a ε)

/-- **Overhead law (`log log` form).**  Taking `n = ⌈log₂ (log (a ε) / log (a p))⌉`
levels of recursion is enough to reach target error `ε`: the number of levels grows only
like `log log (1/ε)`, which is the quantitative content of the threshold theorem. -/
theorem ftIter_le_at_loglog_level {a p ε : ℝ} {m : ℕ} (ha : 0 < a) (hp : 0 < p)
    (heps : 0 < ε) (hm : 1 ≤ m) (hlt : a * p < 1) :
    ftIter a m p ⌈Real.logb 2 (Real.log (a * ε) / Real.log (a * p))⌉₊ ≤ ε := by
  set X := Real.log (a * ε) / Real.log (a * p) with hX
  set n := ⌈Real.logb 2 X⌉₊ with hn
  refine ftIter_le_of_level ha hp heps hlt n ?_
  have h2n : (2 : ℝ) ^ n ≤ ((m + 1) ^ n : ℕ) := by
    have : (2 : ℕ) ^ n ≤ (m + 1) ^ n := Nat.pow_le_pow_left (by omega) n
    calc (2 : ℝ) ^ n = ((2 ^ n : ℕ) : ℝ) := by push_cast; ring
    _ ≤ ((m + 1) ^ n : ℕ) := by exact_mod_cast this
  refine le_trans ?_ h2n
  by_cases hX0 : 0 < X
  case neg =>
    push_neg at hX0
    exact hX0.trans (by positivity)
  case pos =>
    have hlog : Real.logb 2 X ≤ (n : ℝ) := Nat.le_ceil _
    have := Real.rpow_le_rpow_left_iff (x := (2 : ℝ)) (by norm_num) |>.2 hlog
    calc X = (2 : ℝ) ^ (Real.logb 2 X) := (Real.rpow_logb (by norm_num) (by norm_num) hX0).symm
    _ ≤ (2 : ℝ) ^ (n : ℝ) := this
    _ = (2 : ℝ) ^ n := by rw [Real.rpow_natCast]

/-! ## Instances: concatenation and magic-state distillation -/

/-- **The textbook threshold formula.**  For code concatenation (`m = 1`, one-step map
`p ↦ a p²`) the level-`L` error rate is `p_th · (p / p_th) ^ (2 ^ L)` with
`p_th = 1 / a`. -/
theorem concatenation_standard_form {a : ℝ} (ha : 0 < a) (p : ℝ) (L : ℕ) :
    ftIter a 1 p L = (1 / a) * (p / (1 / a)) ^ (2 ^ L) := by
  rw [ftIter_eq_div a 1 p L ha.ne']
  have : p / (1 / a) = a * p := by field_simp
  rw [this]
  ring

/-- A concatenated scheme with `100` malignant pairs of fault locations per level has
threshold exactly `1 %`: at `p = 0.9 %` the logical error rate is driven to zero. -/
theorem steane_threshold_one_percent :
    Tendsto (ftIter 100 1 (9 / 1000)) atTop (𝓝 0) :=
  ftIter_tendsto_zero (by norm_num) (by norm_num) le_rfl (by norm_num)

/-- Conversely, just above the `1 %` threshold the same scheme diverges — the transition
is sharp at `p = 0.01`. -/
theorem steane_above_threshold_diverges :
    Tendsto (ftIter 100 1 (11 / 1000)) atTop atTop :=
  ftIter_tendsto_atTop (by norm_num) le_rfl (by norm_num)

/-- The 15-to-1 magic-state distillation routine has one-step map `p ↦ 35 p³`, i.e.
`a = √35`, `m = 2`.  Its threshold is `1/√35 ≈ 0.169`, so an input error rate of `10 %`
is distilled to zero. -/
theorem magic_state_distillation_15to1_converges :
    Tendsto (ftIter (Real.sqrt 35) 2 (1 / 10)) atTop (𝓝 0) := by
  refine ftIter_tendsto_zero (Real.sqrt_pos.2 (by norm_num)) (by norm_num) (by norm_num) ?_
  have h : Real.sqrt 35 < 10 := by
    have : Real.sqrt 35 < Real.sqrt 100 := Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
    simpa [show (100 : ℝ) = 10 ^ 2 by norm_num, Real.sqrt_sq] using this
  linarith

/-- The distillation map really is the cube map with constant `35`: `a ^ m = 35`. -/
theorem magic_state_distillation_map (p : ℝ) :
    ftIter (Real.sqrt 35) 2 p 1 = 35 * p ^ 3 := by
  rw [ftIter_succ, ftIter_zero, Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 35)]

/-! ## The circuit threshold theorem

The statements above concern a single logical location.  A computation of `L` locations
fails if any one of them fails, so a union bound turns the per-location guarantee into a
guarantee for the whole circuit; and the recursion depth needed grows only like
`log log (L / η)`, so the *gadget size* `c ^ n` grows only polylogarithmically in `L / η`.
This is the threshold theorem in its usual algorithmic form. -/

/-- Union bound: the failure probability of a circuit is at most the number of locations
times the worst per-location failure probability. -/
theorem union_bound {ι : Type*} (s : Finset ι) (f : ι → ℝ) (q : ℝ)
    (h : ∀ i ∈ s, f i ≤ q) : ∑ i ∈ s, f i ≤ s.card * q := by
  calc ∑ i ∈ s, f i ≤ ∑ _i ∈ s, q := Finset.sum_le_sum h
  _ = s.card * q := by simp [Finset.sum_const, nsmul_eq_mul]

/-- **The threshold theorem for a whole computation.**  Below threshold, a circuit with `L`
locations can be simulated with total failure probability at most `η` using
`⌈log₂ (log (a η / L) / log (a p))⌉` levels of recursion — i.e. `log log (L / η)` levels. -/
theorem threshold_theorem_circuit {a p η : ℝ} {m : ℕ} (ha : 0 < a) (hp : 0 < p)
    (hm : 1 ≤ m) (hlt : a * p < 1) (L : ℕ) (hL : 0 < L) (hη : 0 < η) :
    (L : ℝ) * ftIter a m p ⌈Real.logb 2 (Real.log (a * (η / L)) / Real.log (a * p))⌉₊ ≤ η := by
  have hL0 : (0 : ℝ) < L := by exact_mod_cast hL
  have hstep := ftIter_le_at_loglog_level (a := a) (p := p) (ε := η / L) (m := m)
    ha hp (by positivity) hm hlt
  calc (L : ℝ) * ftIter a m p ⌈Real.logb 2 (Real.log (a * (η / L)) / Real.log (a * p))⌉₊
      ≤ (L : ℝ) * (η / L) := by
        exact mul_le_mul_of_nonneg_left hstep hL0.le
  _ = η := by field_simp

/-- **Polylogarithmic gadget size.**  If each level of recursion multiplies the size of a
gadget by `c > 1`, then `⌈log₂ X⌉` levels cost only `c · X ^ (log₂ c)` — polynomial in
`X = log (a η / L) / log (a p)`, hence *polylogarithmic* in the circuit size and the
inverse target accuracy. -/
theorem gadget_size_polylog {c X : ℝ} (hc : 1 < c) (hX : 1 ≤ X) :
    c ^ (⌈Real.logb 2 X⌉₊) ≤ c * X ^ (Real.logb 2 c) := by
  have hc0 : (0 : ℝ) < c := lt_trans zero_lt_one hc
  have hX0 : (0 : ℝ) < X := lt_of_lt_of_le zero_lt_one hX
  have hlogX : 0 ≤ Real.logb 2 X := Real.logb_nonneg (by norm_num) hX
  have hceil : ((⌈Real.logb 2 X⌉₊ : ℕ) : ℝ) ≤ Real.logb 2 X + 1 :=
    (Nat.ceil_lt_add_one hlogX).le
  have h1 : c ^ (⌈Real.logb 2 X⌉₊) = c ^ (((⌈Real.logb 2 X⌉₊ : ℕ) : ℝ)) := by
    rw [Real.rpow_natCast]
  have h2 : c ^ (((⌈Real.logb 2 X⌉₊ : ℕ) : ℝ)) ≤ c ^ (Real.logb 2 X + 1) :=
    Real.rpow_le_rpow_left_iff hc |>.2 hceil
  have h3 : c ^ (Real.logb 2 X + 1) = c ^ (Real.logb 2 X) * c := by
    rw [Real.rpow_add hc0, Real.rpow_one]
  have h4 : c ^ (Real.logb 2 X) = X ^ (Real.logb 2 c) := by
    rw [Real.rpow_def_of_pos hc0, Real.rpow_def_of_pos hX0]
    congr 1
    unfold Real.logb
    field_simp
  rw [h1]
  calc c ^ (((⌈Real.logb 2 X⌉₊ : ℕ) : ℝ)) ≤ c ^ (Real.logb 2 X) * c := by rw [← h3]; exact h2
  _ = c * X ^ (Real.logb 2 c) := by rw [h4]; ring

/-- **The threshold theorem, complete form.**  Below threshold, and with per-level size
blow-up `c`, an `L`-location computation can be made to fail with probability at most `η`
while the size of each fault-tolerant gadget stays bounded by `c · X ^ (log₂ c)` with
`X = log (a η / L) / log (a p)`: accuracy costs only polylogarithmic overhead. -/
theorem threshold_theorem {a p η c : ℝ} {m : ℕ} (ha : 0 < a) (hp : 0 < p) (hm : 1 ≤ m)
    (hlt : a * p < 1) (L : ℕ) (hL : 0 < L) (hη : 0 < η) (hc : 1 < c)
    (hX : 1 ≤ Real.log (a * (η / L)) / Real.log (a * p)) :
    (L : ℝ) * ftIter a m p ⌈Real.logb 2 (Real.log (a * (η / L)) / Real.log (a * p))⌉₊ ≤ η
      ∧ c ^ (⌈Real.logb 2 (Real.log (a * (η / L)) / Real.log (a * p))⌉₊)
          ≤ c * (Real.log (a * (η / L)) / Real.log (a * p)) ^ (Real.logb 2 c) :=
  ⟨threshold_theorem_circuit ha hp hm hlt L hL hη, gadget_size_polylog hc hX⟩

end FaultTolerance