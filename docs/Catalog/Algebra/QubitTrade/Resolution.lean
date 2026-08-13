import Mathlib

/-!
# QUBIT-TRADE I: the resolution threshold of continued-fraction order recovery

Shor's order-finding algorithm returns a phase estimate `x ≈ k / r`, where
`r = ord_N(a)` and `0 ≤ k < r`, and the classical post-processing recovers `k/r`
(hence `r`) by continued fractions.  If the phase register is *truncated* to its
top `t` bits, the estimate is only known to accuracy `2^{-(t+1)}`.

The experiment QUBIT-TRADE measured a truncation threshold `t_min ≈ 2·log₂ r`.
This file proves that this threshold is **exact**, as a two-sided statement about
the *information* carried by a `t`-bit phase:

* `QubitTrade.rat_den_separation` — two distinct rationals are at distance at
  least `1/(den₁ · den₂)` (the Farey separation bound);
* `QubitTrade.cf_target_unique` — **sufficiency**: if `R^2 ≤ 2^t`, i.e.
  `t ≥ 2 log₂ R`, then at most one rational of denominator `≤ R` is compatible
  with a `t`-bit phase, so the continued-fraction target — and with it the order
  — is uniquely determined;
* `QubitTrade.order_unique_of_resolution` — the order-level corollary;
* `QubitTrade.cf_target_ambiguous` — **necessity**: if `2^t < R(R-1)`, i.e.
  `t < 2 log₂ R` up to one bit, there is a phase compatible with *two* distinct
  reduced fractions of denominator `≤ R`, realised by two distinct orders
  `R` and `R-1`.  No post-processing can separate them.
* `QubitTrade.threshold_two_sided` — the two statements packaged: the threshold
  sits in the window `R(R-1) ≤ 2^t < R^2`, i.e. `t_min = ⌈2 log₂ R⌉ ± 1`.
* `QubitTrade.linear_register_ambiguous` — the refutation of the predicted
  `log r + O(log log r)` register: for every constant `c`, a register of
  `log₂ R + c` bits is ambiguous as soon as `R > 2^c + 1`.

Everything is unconditional and model-free: it is a statement about how many
rationals of bounded denominator fit inside an interval of width `2^{-t}`.
-/

namespace QubitTrade

open scoped Rat

/-! ## Farey separation -/

/-- **Farey separation.** Two distinct rationals differ by at least the reciprocal
of the product of their reduced denominators. -/
theorem rat_den_separation (a b : ℚ) (h : a ≠ b) :
    ((a.den : ℝ) * b.den)⁻¹ ≤ |(a : ℝ) - b| := by
  have ha : a * (a.den : ℚ) = (a.num : ℚ) := Rat.mul_den_eq_num a
  have hb : b * (b.den : ℚ) = (b.num : ℚ) := Rat.mul_den_eq_num b
  have hda : (0:ℚ) < a.den := by exact_mod_cast a.pos
  have hdb : (0:ℚ) < b.den := by exact_mod_cast b.pos
  set z : ℤ := a.num * b.den - b.num * a.den with hz
  have key : (a - b) * ((a.den : ℚ) * b.den) = (z : ℚ) := by
    rw [hz]; push_cast [← ha, ← hb]; ring
  have hzne : (z : ℚ) ≠ 0 := by
    rw [← key]; exact mul_ne_zero (sub_ne_zero.mpr h) (by positivity)
  have h1 : (1:ℚ) ≤ |(z:ℚ)| := by
    have hz0 : z ≠ 0 := by exact_mod_cast hzne
    have : (1:ℤ) ≤ |z| := Int.one_le_abs (by omega)
    exact_mod_cast this
  have habs : |a - b| * ((a.den : ℚ) * b.den) = |(z:ℚ)| := by
    rw [← key, abs_mul, abs_of_pos (show (0:ℚ) < (a.den:ℚ) * b.den by positivity)]
  have hQ : (((a.den : ℚ)) * b.den)⁻¹ ≤ |a - b| := by
    rw [inv_le_iff_one_le_mul₀ (by positivity)]
    calc (1:ℚ) ≤ |(z:ℚ)| := h1
      _ = |a - b| * ((a.den:ℚ) * b.den) := habs.symm
  have hR : ((((a.den : ℚ)) * b.den)⁻¹ : ℝ) ≤ ((|a - b| : ℚ) : ℝ) := by exact_mod_cast hQ
  push_cast at hR
  simpa using hR

/-! ## The truncated-register measurement model -/

/-- The resolution of a `t`-bit phase register: an outcome `m` pins the phase down
to the interval of radius `2^{-(t+1)}` around `m / 2^t`. -/
noncomputable def res (t : ℕ) : ℝ := ((2:ℝ) ^ (t + 1))⁻¹

theorem res_pos (t : ℕ) : 0 < res t := by
  unfold res; positivity

/-- A rational `q` is *compatible* with the phase `x` read off a `t`-bit register
if it lies within the register's resolution of `x`. -/
def Compatible (t : ℕ) (x : ℝ) (q : ℚ) : Prop := |x - (q : ℝ)| < res t

/-- The order fraction `k / r` produced by an order-`r` Shor sample. -/
def orderFrac (k r : ℕ) : ℚ := (k : ℚ) / (r : ℚ)

/-- The reduced denominator of `k / r` is `r / gcd (k, r)`. -/
theorem orderFrac_den (k r : ℕ) (hr : 0 < r) :
    (orderFrac k r).den = r / Nat.gcd k r := by
  unfold orderFrac
  rw [show ((k:ℚ)/r) = Rat.divInt (k : ℤ) (r : ℤ) by rw [Rat.divInt_eq_div]; push_cast; ring]
  rw [Rat.den_divInt]
  simp [Int.gcd, Nat.gcd_comm, hr.ne']

/-- For a sample with `gcd (k, r) = 1` the reduced denominator *is* the order. -/
theorem orderFrac_den_of_coprime {k r : ℕ} (hr : 0 < r) (h : Nat.Coprime k r) :
    (orderFrac k r).den = r := by
  rw [orderFrac_den k r hr, Nat.Coprime.gcd_eq_one h, Nat.div_one]

/-! ## Sufficiency: `t ≥ 2 log₂ R` determines the continued-fraction target -/

/-- **The continued-fraction target is unique above the quadratic threshold.**
If the register satisfies `R^2 ≤ 2^t`, then two rationals with reduced denominator
at most `R` compatible with the same `t`-bit phase are equal. -/
theorem cf_target_unique {R t : ℕ} (hRt : ((R : ℝ)) ^ 2 ≤ 2 ^ t) {x : ℝ} {q₁ q₂ : ℚ}
    (h₁ : q₁.den ≤ R) (h₂ : q₂.den ≤ R)
    (c₁ : Compatible t x q₁) (c₂ : Compatible t x q₂) : q₁ = q₂ := by
  by_contra hne
  have hd₁ : (0:ℝ) < q₁.den := by exact_mod_cast q₁.pos
  have hd₂ : (0:ℝ) < q₂.den := by exact_mod_cast q₂.pos
  have hR₁ : ((q₁.den : ℝ)) ≤ R := by exact_mod_cast h₁
  have hR₂ : ((q₂.den : ℝ)) ≤ R := by exact_mod_cast h₂
  have hRpos : (0:ℝ) < R := lt_of_lt_of_le hd₁ hR₁
  -- the two candidates are close
  have hclose : |(q₁ : ℝ) - q₂| < ((2:ℝ) ^ t)⁻¹ := by
    have htri : |(q₁ : ℝ) - q₂| ≤ |x - q₁| + |x - q₂| := by
      have : (q₁ : ℝ) - q₂ = (x - q₂) - (x - q₁) := by ring
      rw [this]
      calc |(x - (q₂:ℝ)) - (x - q₁)| ≤ |x - (q₂:ℝ)| + |x - (q₁:ℝ)| := abs_sub _ _
        _ = |x - (q₁:ℝ)| + |x - (q₂:ℝ)| := by ring
    have hsum : |x - (q₁:ℝ)| + |x - (q₂:ℝ)| < res t + res t := by
      exact add_lt_add c₁ c₂
    have hres : res t + res t = ((2:ℝ) ^ t)⁻¹ := by
      unfold res
      rw [pow_succ]
      field_simp
      ring
    linarith [htri, hres ▸ hsum]
  -- but they are far apart
  have hfar : ((q₁.den : ℝ) * q₂.den)⁻¹ ≤ |(q₁ : ℝ) - q₂| := rat_den_separation q₁ q₂ hne
  have hprod : ((q₁.den : ℝ)) * q₂.den ≤ (R:ℝ) ^ 2 := by
    have := mul_le_mul hR₁ hR₂ (le_of_lt hd₂) (le_of_lt hRpos)
    nlinarith
  have hlow : ((R:ℝ) ^ 2)⁻¹ ≤ ((q₁.den : ℝ) * q₂.den)⁻¹ :=
    inv_anti₀ (by positivity) hprod
  have : ((2:ℝ) ^ t)⁻¹ ≤ ((R:ℝ)^2)⁻¹ := inv_anti₀ (by positivity) hRt
  linarith

/-- **Order-level uniqueness.** Two Shor samples `k₁/r₁`, `k₂/r₂` with numerators
coprime to their orders, orders bounded by `R`, and both compatible with the same
`t`-bit phase, have the same order — provided `R^2 ≤ 2^t`. -/
theorem order_unique_of_resolution {R t : ℕ} (hRt : ((R : ℝ)) ^ 2 ≤ 2 ^ t) {x : ℝ}
    {k₁ r₁ k₂ r₂ : ℕ} (hr₁ : 0 < r₁) (hr₂ : 0 < r₂)
    (hc₁ : Nat.Coprime k₁ r₁) (hc₂ : Nat.Coprime k₂ r₂)
    (hb₁ : r₁ ≤ R) (hb₂ : r₂ ≤ R)
    (m₁ : Compatible t x (orderFrac k₁ r₁)) (m₂ : Compatible t x (orderFrac k₂ r₂)) :
    r₁ = r₂ := by
  have h₁ : (orderFrac k₁ r₁).den ≤ R := by
    rw [orderFrac_den_of_coprime hr₁ hc₁]; exact hb₁
  have h₂ : (orderFrac k₂ r₂).den ≤ R := by
    rw [orderFrac_den_of_coprime hr₂ hc₂]; exact hb₂
  have := cf_target_unique hRt h₁ h₂ m₁ m₂
  have e₁ : (orderFrac k₁ r₁).den = r₁ := orderFrac_den_of_coprime hr₁ hc₁
  have e₂ : (orderFrac k₂ r₂).den = r₂ := orderFrac_den_of_coprime hr₂ hc₂
  rw [← e₁, ← e₂, this]

/-! ## Necessity: below the quadratic threshold the target is ambiguous -/

/-- The two nearest-neighbour candidates `1/R` and `1/(R-1)`, at distance
`1/(R(R-1))`: the closest pair of reduced fractions with denominators `≤ R`
that the register has to separate. -/
theorem nearest_pair_distance {R : ℕ} (hR : 2 ≤ R) :
    ((orderFrac 1 R : ℚ) : ℝ) < ((orderFrac 1 (R - 1) : ℚ) : ℝ) ∧
      ((orderFrac 1 (R - 1) : ℚ) : ℝ) - ((orderFrac 1 R : ℚ) : ℝ)
        = ((R : ℝ) * ((R : ℝ) - 1))⁻¹ := by
  have hR1 : ((R : ℝ) - 1) = ((R - 1 : ℕ) : ℝ) := by
    have : (1:ℕ) ≤ R := by omega
    push_cast [Nat.cast_sub this]; ring
  have hRpos : (0:ℝ) < R := by
    have : (0:ℕ) < R := by omega
    exact_mod_cast this
  have hR1pos : (0:ℝ) < (R : ℝ) - 1 := by
    have : (2:ℝ) ≤ R := by exact_mod_cast hR
    linarith
  have e₁ : ((orderFrac 1 R : ℚ) : ℝ) = ((R : ℝ))⁻¹ := by
    unfold orderFrac; push_cast; ring
  have e₂ : ((orderFrac 1 (R - 1) : ℚ) : ℝ) = ((R : ℝ) - 1)⁻¹ := by
    unfold orderFrac; push_cast [← hR1]; ring
  constructor
  · rw [e₁, e₂]
    exact inv_strictAnti₀ hR1pos (by linarith)
  · rw [e₁, e₂]
    field_simp
    ring

/-- **Ambiguity below the quadratic threshold.**  If `2^t < R(R-1)`, then there is
a phase `x` compatible with the two *distinct* order fractions `1/R` and `1/(R-1)`.
Both have coprime numerator, so both denominators are honest orders: a `t`-bit
register cannot decide between the orders `R` and `R-1`. -/
theorem cf_target_ambiguous {R t : ℕ} (hR : 2 ≤ R) (h : ((2:ℝ)) ^ t < (R : ℝ) * ((R : ℝ) - 1)) :
    ∃ x : ℝ, orderFrac 1 R ≠ orderFrac 1 (R - 1) ∧
      (orderFrac 1 R).den = R ∧ (orderFrac 1 (R - 1)).den = R - 1 ∧
      Compatible t x (orderFrac 1 R) ∧ Compatible t x (orderFrac 1 (R - 1)) := by
  obtain ⟨hlt, hdist⟩ := nearest_pair_distance hR
  have halve : ∀ X : ℝ, X⁻¹ / 2 = (2 * X)⁻¹ := fun X => by rw [mul_inv]; ring
  have hRpos : (0:ℝ) < R := by
    have : (0:ℕ) < R := by omega
    exact_mod_cast this
  have hR1pos : (0:ℝ) < (R : ℝ) - 1 := by
    have : (2:ℝ) ≤ R := by exact_mod_cast hR
    linarith
  refine ⟨(((orderFrac 1 R : ℚ) : ℝ) + ((orderFrac 1 (R - 1) : ℚ) : ℝ)) / 2, ?_, ?_, ?_, ?_, ?_⟩
  · intro hcon
    rw [hcon] at hlt
    exact lt_irrefl _ hlt
  · exact orderFrac_den_of_coprime (by omega) (Nat.coprime_one_left R)
  · exact orderFrac_den_of_coprime (by omega) (Nat.coprime_one_left (R - 1))
  · have : |(((orderFrac 1 R : ℚ) : ℝ) + ((orderFrac 1 (R - 1) : ℚ) : ℝ)) / 2
        - ((orderFrac 1 R : ℚ) : ℝ)| = ((R : ℝ) * ((R : ℝ) - 1))⁻¹ / 2 := by
      rw [abs_of_nonneg (by linarith), ← hdist]; ring
    unfold Compatible res
    rw [this, halve]
    exact inv_strictAnti₀ (by positivity) (by rw [pow_succ]; linarith)
  · have : |(((orderFrac 1 R : ℚ) : ℝ) + ((orderFrac 1 (R - 1) : ℚ) : ℝ)) / 2
        - ((orderFrac 1 (R - 1) : ℚ) : ℝ)| = ((R : ℝ) * ((R : ℝ) - 1))⁻¹ / 2 := by
      rw [abs_of_nonpos (by linarith), ← hdist]; ring
    unfold Compatible res
    rw [this, halve]
    exact inv_strictAnti₀ (by positivity) (by rw [pow_succ]; linarith)

/-! ## The two-sided threshold -/

/-- **The register threshold is `2 log₂ R`, up to one bit.**  For every bound `R ≥ 2`
on the order:

* if `2^t ≥ R^2` the `t`-bit register determines the continued-fraction target;
* if `2^t < R(R-1)` it does not.

Hence the minimal register size `t_min` satisfies `R(R-1) ≤ 2^{t_min} < 2R^2`, i.e.
`t_min = 2 log₂ R + O(1)` — the predicted `log R + O(log log R)` is impossible. -/
theorem threshold_two_sided {R : ℕ} (hR : 2 ≤ R) :
    (∀ t : ℕ, ((R : ℝ)) ^ 2 ≤ 2 ^ t → ∀ (x : ℝ) (q₁ q₂ : ℚ), q₁.den ≤ R → q₂.den ≤ R →
        Compatible t x q₁ → Compatible t x q₂ → q₁ = q₂) ∧
    (∀ t : ℕ, ((2:ℝ)) ^ t < (R : ℝ) * ((R : ℝ) - 1) →
        ∃ (x : ℝ) (q₁ q₂ : ℚ), q₁ ≠ q₂ ∧ q₁.den ≤ R ∧ q₂.den ≤ R ∧
          Compatible t x q₁ ∧ Compatible t x q₂) := by
  refine ⟨fun t ht x q₁ q₂ h₁ h₂ c₁ c₂ => cf_target_unique ht h₁ h₂ c₁ c₂, fun t ht => ?_⟩
  obtain ⟨x, hne, hd₁, hd₂, c₁, c₂⟩ := cf_target_ambiguous hR ht
  exact ⟨x, orderFrac 1 R, orderFrac 1 (R - 1), hne, by omega, by omega, c₁, c₂⟩

/-- **Refutation of the linear-register prediction.**  A register of
`log₂ R + c` bits is ambiguous for every `R > 2 ^ c + 1`: no constant, and indeed no
`O(log log R)` additive correction, can rescue a register of size `log₂ R + o(log R)`.
Stated with the concrete witness `2 ^ t ≤ 2 ^ c * R`. -/
theorem linear_register_ambiguous {R t c : ℕ} (hR : 2 ^ c + 1 < R)
    (ht : ((2:ℝ)) ^ t ≤ 2 ^ c * (R : ℝ)) :
    ∃ (x : ℝ) (q₁ q₂ : ℚ), q₁ ≠ q₂ ∧ q₁.den ≤ R ∧ q₂.den ≤ R ∧
      Compatible t x q₁ ∧ Compatible t x q₂ := by
  have hR2 : 2 ≤ R := by
    have : 1 ≤ 2 ^ c := Nat.one_le_two_pow
    omega
  have hcR : ((2:ℝ) ^ c : ℝ) < (R : ℝ) - 1 := by
    have h1 : ((2 ^ c + 1 : ℕ) : ℝ) < (R : ℝ) := by exact_mod_cast hR
    push_cast at h1
    linarith
  have hRpos : (0:ℝ) < R := by
    have : (0:ℕ) < R := by omega
    exact_mod_cast this
  have : ((2:ℝ)) ^ t < (R : ℝ) * ((R : ℝ) - 1) := by
    calc ((2:ℝ)) ^ t ≤ 2 ^ c * (R : ℝ) := ht
      _ < ((R : ℝ) - 1) * (R : ℝ) := by
          apply mul_lt_mul_of_pos_right hcR hRpos
      _ = (R : ℝ) * ((R : ℝ) - 1) := by ring
  obtain ⟨x, hne, hd₁, hd₂, c₁, c₂⟩ := cf_target_ambiguous hR2 this
  exact ⟨x, orderFrac 1 R, orderFrac 1 (R - 1), hne, by omega, by omega, c₁, c₂⟩

end QubitTrade