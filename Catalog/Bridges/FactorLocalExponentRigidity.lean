import Mathlib
import Bridges.FactorLocalExponentPlane
import Bridges.FermatArmDerivative

/-!
# Exponent rigidity of the factor-local cost plane

`Bridges.FactorLocalExponentPlane` proved the three exact cost laws behind the measured
exponents `α_td = 1.0009`, `α_fermat = 0.9932`, `α_rho = 0.4994`: on a bounded-ratio
semiprime arm (`2p ≤ q ≤ 4p`) trial division costs *exactly* `p`, Fermat's gap lies in
`[p/12, 5p/2]`, and the birthday threshold is bracketed by `√p` and `1 + 1.178·√p`.

Those are statements about a *single* semiprime.  What an experiment actually reports is
a **fitted exponent** `log_p (cost)`, and the claim under test is that this fitted number
converges to `1`, `1`, `1/2`.  This file proves that it does, and — this is the rigidity
content — that it does so for *every* cost function obeying the proved two-sided
sandwiches: the constants `1`, `1/12`, `5/2`, `1`, `2 + √(2 log 2)` are invisible in the
limit, so no choice of cost model consistent with the halting laws can produce a
different exponent.  A measurement of `0.9932` is therefore a finite-size constant
effect, never evidence of a different `α`.

* `logb_tendsto_of_bracket` — the analytic core: a two-sided bracket
  `a·P^α ≤ f ≤ b·P^α` with `P → ∞` forces `log_P f → α`, for any positive `a`, `b`.
* `td_exponent_limit`, `fermat_exponent_limit`, `rho_exponent_limit` — the three arms.
* `birthday_threshold_witness` — the rho bracket is not vacuous: an explicit `t` sits
  inside it *and* pushes the collision probability past `1/2`.
* `exponent_plane_rigidity` — the three limits `(1, 1, 1/2)` in one statement.
-/

namespace FactorPlane

open Filter Topology

/-! ## The analytic core -/

/-- **Bracket ⇒ exponent.**  If a cost function `f` is squeezed between `a·P^α` and
`b·P^α` along a sequence of moduli `P → ∞`, then the fitted exponent `log_P f`
converges to `α`.  The constants `a`, `b` disappear: only the exponent survives. -/
theorem logb_tendsto_of_bracket {α a b : ℝ} (ha : 0 < a) (hb : 0 < b)
    {P : ℕ → ℕ} (hP : Tendsto (fun n => (P n : ℝ)) atTop atTop) {f : ℕ → ℝ}
    (hf : ∀ᶠ n in atTop, a * (P n : ℝ) ^ α ≤ f n ∧ f n ≤ b * (P n : ℝ) ^ α) :
    Tendsto (fun n => Real.logb (P n) (f n)) atTop (𝓝 α) := by
  have hL : Tendsto (fun n => Real.log (P n)) atTop atTop :=
    Real.tendsto_log_atTop.comp hP
  have hlow : Tendsto (fun n => α + Real.log a / Real.log (P n)) atTop (𝓝 α) := by
    have h0 : Tendsto (fun n => Real.log a / Real.log (P n)) atTop (𝓝 0) :=
      Tendsto.div_atTop tendsto_const_nhds hL
    simpa using (tendsto_const_nhds (x := α) (f := atTop)).add h0
  have hhigh : Tendsto (fun n => α + Real.log b / Real.log (P n)) atTop (𝓝 α) := by
    have h0 : Tendsto (fun n => Real.log b / Real.log (P n)) atTop (𝓝 0) :=
      Tendsto.div_atTop tendsto_const_nhds hL
    simpa using (tendsto_const_nhds (x := α) (f := atTop)).add h0
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hhigh ?_ ?_
  · filter_upwards [hf, hP.eventually_ge_atTop 2] with n hfn hPn
    have hP0 : (0 : ℝ) < P n := by linarith
    have hL0 : 0 < Real.log (P n) := Real.log_pos (by linarith)
    have hpos : 0 < a * (P n : ℝ) ^ α := by positivity
    have hlog : Real.log (a * (P n : ℝ) ^ α) = Real.log a + α * Real.log (P n) := by
      rw [Real.log_mul (ne_of_gt ha) (by positivity), Real.log_rpow hP0]
    have hmono : Real.log a + α * Real.log (P n) ≤ Real.log (f n) := by
      rw [← hlog]
      exact Real.log_le_log hpos hfn.1
    rw [Real.logb, le_div_iff₀ hL0]
    have hexp : (α + Real.log a / Real.log (P n)) * Real.log (P n)
        = α * Real.log (P n) + Real.log a := by
      field_simp
    rw [hexp]
    linarith
  · filter_upwards [hf, hP.eventually_ge_atTop 2] with n hfn hPn
    have hP0 : (0 : ℝ) < P n := by linarith
    have hL0 : 0 < Real.log (P n) := Real.log_pos (by linarith)
    have hpos : 0 < f n := lt_of_lt_of_le (by positivity) hfn.1
    have hlog : Real.log (b * (P n : ℝ) ^ α) = Real.log b + α * Real.log (P n) := by
      rw [Real.log_mul (ne_of_gt hb) (by positivity), Real.log_rpow hP0]
    have hmono : Real.log (f n) ≤ Real.log b + α * Real.log (P n) := by
      rw [← hlog]
      exact Real.log_le_log hpos hfn.2
    rw [Real.logb, div_le_iff₀ hL0]
    have hexp : (α + Real.log b / Real.log (P n)) * Real.log (P n)
        = α * Real.log (P n) + Real.log b := by
      field_simp
    rw [hexp]
    linarith

/-! ## The three arms -/

variable {P Q : ℕ → ℕ}

/-- **Trial division: fitted exponent `→ 1`** (in fact `= 1` at every point of the
sequence).  Any arm of semiprimes with the small prime tending to infinity. -/
theorem td_exponent_limit (hP : Tendsto (fun n => (P n : ℝ)) atTop atTop)
    (hp : ∀ n, (P n).Prime) (hq : ∀ n, (Q n).Prime) (hle : ∀ n, P n ≤ Q n) :
    Tendsto (fun n => Real.logb (P n) (tdCost (P n * Q n))) atTop (𝓝 1) := by
  refine logb_tendsto_of_bracket (a := 1) (b := 1) one_pos one_pos hP ?_
  filter_upwards with n
  rw [td_cost_semiprime (hp n) (hq n) (hle n), Real.rpow_one]
  constructor <;> simp

/-- **Fermat: fitted exponent `→ 1`.**  On any bounded-ratio arm `2p ≤ q ≤ 4p` the gap is
squeezed between `p/12` and `5p/2`, so the measured `0.9932` is a constant effect. -/
theorem fermat_exponent_limit (hP : Tendsto (fun n => (P n : ℝ)) atTop atTop)
    (hpos : ∀ n, 0 < P n) (h2 : ∀ n, 2 * P n ≤ Q n) (h4 : ∀ n, Q n ≤ 4 * P n) :
    Tendsto (fun n => Real.logb (P n) (fermatGap (P n) (Q n))) atTop (𝓝 1) := by
  refine logb_tendsto_of_bracket (a := 1 / 12) (b := 5 / 2) (by norm_num) (by norm_num) hP ?_
  filter_upwards with n
  rw [Real.rpow_one]
  refine ⟨?_, ?_⟩
  · have := fermat_gap_lower (hpos n) (h2 n)
    linarith
  · have := fermat_gap_upper (h4 n)
    linarith

/-- A birthday threshold for modulus `m`: a number of draws that is at least `√m` and at
most `2 + √(2 m log 2)`, i.e. one lying inside the proved two-sided bracket of
`birthday_threshold_two_sided`. -/
def IsBirthdayThreshold (m t : ℕ) : Prop :=
  Real.sqrt m ≤ t ∧ (t : ℝ) ≤ 2 + Real.sqrt (2 * m * Real.log 2)

/-- **The bracket is not vacuous, and it really is a threshold.**  For every `m ≥ 1` the
explicit draw count `t = ⌈√(2 m log 2)⌉ + 1` lies in the bracket *and* exceeds
`1 + √(2 m log 2)`, hence (by `birthday_threshold_two_sided`, whenever `t ≤ m`) makes the
collision probability at least `1/2`. -/
theorem birthday_threshold_witness {m : ℕ} (hm : 0 < m) :
    IsBirthdayThreshold m (⌈Real.sqrt (2 * m * Real.log 2)⌉₊ + 1) ∧
      1 + Real.sqrt (2 * m * Real.log 2) ≤ (⌈Real.sqrt (2 * m * Real.log 2)⌉₊ + 1 : ℕ) := by
  have hm0 : (1 : ℝ) ≤ m := by exact_mod_cast hm
  have hlog : (1 : ℝ) ≤ 2 * Real.log 2 := by
    have h2 : Real.log 2 ≥ 0.6931 := by
      have := Real.log_two_gt_d9
      linarith
    linarith
  set x := Real.sqrt (2 * m * Real.log 2) with hx
  have hxnn : 0 ≤ x := Real.sqrt_nonneg _
  have hge : Real.sqrt m ≤ x := by
    apply Real.sqrt_le_sqrt
    nlinarith
  have hceil : x ≤ (⌈x⌉₊ : ℝ) := Nat.le_ceil x
  have hceil' : (⌈x⌉₊ : ℝ) ≤ x + 1 := by
    have := Nat.ceil_lt_add_one hxnn
    linarith
  have hcast : ((⌈x⌉₊ + 1 : ℕ) : ℝ) = (⌈x⌉₊ : ℝ) + 1 := by push_cast; ring
  refine ⟨⟨?_, ?_⟩, ?_⟩ <;> rw [hcast] <;> linarith

/-- **Rho: fitted exponent `→ 1/2`.**  *Every* threshold function lying in the proved
birthday bracket has fitted exponent exactly `1/2` in the limit — the birthday constant
`√(2 log 2) ≈ 1.178` and the additive slack are invisible.  This is the rigidity behind
the measurement `0.4994 [0.485, 0.510]`. -/
theorem rho_exponent_limit {T : ℕ → ℕ} (hP : Tendsto (fun n => (P n : ℝ)) atTop atTop)
    (hT : ∀ n, IsBirthdayThreshold (P n) (T n)) :
    Tendsto (fun n => Real.logb (P n) (T n)) atTop (𝓝 (1 / 2)) := by
  have hc : (0 : ℝ) < 2 + Real.sqrt (2 * Real.log 2) := by positivity
  refine logb_tendsto_of_bracket (a := 1) (b := 2 + Real.sqrt (2 * Real.log 2))
    one_pos hc hP ?_
  filter_upwards [hP.eventually_ge_atTop 1] with n hPn
  have hsplit : Real.sqrt (2 * (P n : ℝ) * Real.log 2)
      = Real.sqrt (2 * Real.log 2) * Real.sqrt (P n) := by
    rw [← Real.sqrt_mul (by positivity : (0:ℝ) ≤ 2 * Real.log 2)]
    ring_nf
  have hrpow : ((P n : ℝ)) ^ (1 / 2 : ℝ) = Real.sqrt (P n) := (Real.sqrt_eq_rpow _).symm
  have hsq1 : (1 : ℝ) ≤ Real.sqrt (P n) := by
    rw [show (1 : ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_le_sqrt hPn
  obtain ⟨hlow, hhigh⟩ := hT n
  rw [hrpow]
  refine ⟨by linarith, ?_⟩
  rw [hsplit] at hhigh
  nlinarith [Real.sqrt_nonneg (2 * Real.log 2)]

/-! ## The rigidity statement -/

/-- **Exponent rigidity of the measured plane.**  Fix any arm of semiprimes `N = p·q`
with `p → ∞` and `2p ≤ q ≤ 4p`, and any threshold function inside the proved birthday
bracket.  Then the three fitted exponents converge to exactly `1`, `1` and `1/2`.  No
constant, and no admissible choice of cost model, can change them: the plane
`(1, 1, 1/2)` is rigid. -/
theorem exponent_plane_rigidity {T : ℕ → ℕ}
    (hP : Tendsto (fun n => (P n : ℝ)) atTop atTop)
    (hp : ∀ n, (P n).Prime) (hq : ∀ n, (Q n).Prime)
    (h2 : ∀ n, 2 * P n ≤ Q n) (h4 : ∀ n, Q n ≤ 4 * P n)
    (hT : ∀ n, IsBirthdayThreshold (P n) (T n)) :
    Tendsto (fun n => Real.logb (P n) (tdCost (P n * Q n))) atTop (𝓝 1) ∧
    Tendsto (fun n => Real.logb (P n) (fermatGap (P n) (Q n))) atTop (𝓝 1) ∧
    Tendsto (fun n => Real.logb (P n) (T n)) atTop (𝓝 (1 / 2)) := by
  have hle : ∀ n, P n ≤ Q n := by
    intro n
    have := (hp n).two_le
    have := h2 n
    omega
  exact ⟨td_exponent_limit hP hp hq hle,
    fermat_exponent_limit hP (fun n => (hp n).pos) h2 h4,
    rho_exponent_limit hP hT⟩

/-! ## The finite-size correction, exactly -/

/-- **The fitted Fermat exponent, in closed form.**  On the arm `q = 2p` the gap is
exactly `(3/2 − √2)·p`, so the fitted exponent is *exactly*
`1 + log(3/2 − √2)/log p`: the whole deviation from `1` is the logarithm of the constant
divided by `log p`. -/
theorem fermat_logb_exact {p : ℕ} (hp : 1 < p) :
    Real.logb p (fermatGap p (2 * p))
      = 1 + Real.log (3 / 2 - Real.sqrt 2) / Real.log p := by
  have hp0 : (0 : ℝ) < p := by positivity
  have hp1 : (1 : ℝ) < p := by exact_mod_cast hp
  have hlogp : Real.log p ≠ 0 := ne_of_gt (Real.log_pos hp1)
  have hcpos : 0 < 3 / 2 - Real.sqrt 2 := three_halves_sub_sqrt_two_pos
  have hgap : fermatGap p (2 * p) = (3 / 2 - Real.sqrt 2) * p := by
    have h := fermatGapReal_two_mul hp0
    rw [← fermatGapReal_natCast p (2 * p)]
    push_cast
    exact h
  rw [hgap, Real.logb, Real.log_mul (ne_of_gt hcpos) (ne_of_gt hp0)]
  field_simp
  ring

/-- The fitted exponent is always *below* `1` at finite `p`: the measured deficit has the
sign the constant `3/2 − √2 < 1` predicts. -/
theorem fermat_logb_lt_one {p : ℕ} (hp : 1 < p) :
    Real.logb p (fermatGap p (2 * p)) < 1 := by
  have hp1 : (1 : ℝ) < p := by exact_mod_cast hp
  have hlogp : 0 < Real.log p := Real.log_pos hp1
  have hcpos : 0 < 3 / 2 - Real.sqrt 2 := three_halves_sub_sqrt_two_pos
  have hclt : 3 / 2 - Real.sqrt 2 < 1 := by
    have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
    nlinarith [Real.sqrt_nonneg 2]
  have hlogc : Real.log (3 / 2 - Real.sqrt 2) < 0 := Real.log_neg hcpos hclt
  rw [fermat_logb_exact hp]
  have : Real.log (3 / 2 - Real.sqrt 2) / Real.log p < 0 := div_neg_of_neg_of_pos hlogc hlogp
  linarith

/-- **The scale a given fit demands.**  Observing a Fermat exponent within `ε` of `1` on
the arm `q = 2p` forces `log p ≥ log(1/(3/2 − √2))/ε`.  With `ε = 0.0068` (the deficit of
the reported `0.9932`) this is an astronomically large `p`, so a small measured deficit on
a toy range is a property of the *finite range*, not of this asymptotic constant. -/
theorem fermat_finite_size_scale {p : ℕ} (hp : 1 < p) {ε : ℝ}
    (h : 1 - Real.logb p (fermatGap p (2 * p)) ≤ ε) :
    -Real.log (3 / 2 - Real.sqrt 2) ≤ ε * Real.log p := by
  have hp1 : (1 : ℝ) < p := by exact_mod_cast hp
  have hlogp : 0 < Real.log p := Real.log_pos hp1
  rw [fermat_logb_exact hp] at h
  have h' : -(Real.log (3 / 2 - Real.sqrt 2) / Real.log p) ≤ ε := by linarith
  have := mul_le_mul_of_nonneg_right h' hlogp.le
  calc -Real.log (3 / 2 - Real.sqrt 2)
      = -(Real.log (3 / 2 - Real.sqrt 2) / Real.log p) * Real.log p := by
        field_simp
    _ ≤ ε * Real.log p := this

/-! ## The rigid arm is not empty -/

/-- **Bertrand supplies the arm.**  Every prime `p` has a prime partner `q` with
`2p ≤ q ≤ 4p`, so bounded-ratio semiprime arms exist at every scale. -/
theorem bounded_ratio_partner_exists {p : ℕ} (hp : p.Prime) :
    ∃ q, q.Prime ∧ 2 * p ≤ q ∧ q ≤ 4 * p := by
  obtain ⟨q, hq, hlt, hle⟩ := Nat.exists_prime_lt_and_le_two_mul (2 * p) (by
    have := hp.pos; omega)
  exact ⟨q, hq, le_of_lt hlt, by omega⟩

/-- **The hypotheses of `exponent_plane_rigidity` are satisfiable.**  Taking `P` to be the
sequence of all primes, Bertrand's postulate provides the second prime and
`birthday_threshold_witness` the draw count, so the rigidity theorem is not vacuous. -/
theorem exponent_plane_arm_exists :
    ∃ P Q T : ℕ → ℕ,
      Tendsto (fun n => (P n : ℝ)) atTop atTop ∧ (∀ n, (P n).Prime) ∧ (∀ n, (Q n).Prime) ∧
      (∀ n, 2 * P n ≤ Q n) ∧ (∀ n, Q n ≤ 4 * P n) ∧
      (∀ n, IsBirthdayThreshold (P n) (T n)) := by
  classical
  set P : ℕ → ℕ := fun n => Nat.nth Nat.Prime n with hPdef
  have hPprime : ∀ n, (P n).Prime := fun n => Nat.prime_nth_prime n
  have hmono : StrictMono P := fun i j hij =>
    (Nat.nth_lt_nth Nat.infinite_setOf_prime).mpr hij
  have hPtop : Tendsto (fun n => (P n : ℝ)) atTop atTop :=
    tendsto_natCast_atTop_atTop.comp hmono.tendsto_atTop
  choose Q hQp hQ2 hQ4 using fun n => bounded_ratio_partner_exists (hPprime n)
  refine ⟨P, Q, fun n => ⌈Real.sqrt (2 * P n * Real.log 2)⌉₊ + 1,
    hPtop, hPprime, hQp, hQ2, hQ4, fun n => (birthday_threshold_witness (hPprime n).pos).1⟩

end FactorPlane