/-
# Uniqueness of the A/X crossing for the fork channel

## Setting

The *fork channel of arity `n`* is the elementary read-out model of a branching
node with `n` outgoing branches.  Two competing read-out architectures are
attached to such a node.

* The **address channel** `A n`.  Naming a branch of the fork costs `log₂ n`
  bits; one of these bits is consumed by the fork decision itself, and the
  architecture pays an *additive* penalty equal to the **entropy deficit**
  `δ n = 1 / n²`:

  `A n = log₂ n - 1 - δ n`.

* The **exchange channel** `X n`.  The exchange architecture always transmits a
  two-bit packet, but its rate is degraded *multiplicatively* by the same
  entropy deficit:

  `X n = 2 · (1 - δ n)`.

The entropy deficit `δ n = 1/n²` is not an arbitrary correction: for integral
arity it is exactly the **collision probability of the fork**, i.e. the
probability that two independent uniform probes of the ordered branch pair set
`[n] × [n]` return the same pair (`deficit_eq_forkCollision`).

The two architectures therefore differ only in *how* they are degraded —
additively versus multiplicatively — by one and the same physical quantity.

## Results

The whole comparison collapses onto a single scalar, the **resonance**

`R n = log₂ n + δ n`,   with   `A n - X n = R n - 3`.

The main theorems are:

* `resonance_strictMonoOn` : `R` is strictly increasing on `[2, ∞)`.  (The
  derivative `1/(n log 2) - 2/n³` is positive as soon as `n² > 2 log 2`.)
* `integer_criterion` / `integer_criterion_lt` : for **integral** arity `m ≥ 2`
  the comparison of the two channels is *exactly* the integer inequality
  `m ^ (m²)` vs `2 ^ (3m² - 1)` — one integer inequality per side.  The two
  decisive certificates are `7 ^ 49 < 2 ^ 146` and `2 ^ 191 < 8 ^ 64`.
* `A_lt_X_of_le_seven` : `A n < X n` for all real `2 < n ≤ 7`.
* `X_lt_A_of_ge_eight` : `X n < A n` for all real `n ≥ 8`.
* `exists_unique_crossing` : there is a *unique* `r > 2` with `A r = X r`, and
  it satisfies `7 < r < 8`.  Thus the crossing observed between `n = 7` and
  `n = 8` is the only one: the conjecture is settled.
* `ratio_strictMonoOn` : the ratio `A/X` is strictly increasing on `(1, ∞)` —
  in particular on `[8, ∞)`, which is the missing monotonicity statement.
* `ratio_tendsto_atTop` : `A/X → ∞`.

Everything below is self-contained (the model, the combinatorial grounding of
the deficit, and all analytic input).
-/
import Mathlib

namespace ForkChannel

open Real Set Filter Topology

/-! ## 1. The model -/

/-- The **entropy deficit** of a fork of arity `n`: `δ n = 1 / n²`. -/
noncomputable def deficit (n : ℝ) : ℝ := 1 / n ^ 2

/-- The **address channel** of a fork of arity `n`: the `log₂ n` bits of a branch
address, less the one bit consumed by the fork decision, less an *additive*
entropy-deficit penalty. -/
noncomputable def A (n : ℝ) : ℝ := logb 2 n - 1 - deficit n

/-- The **exchange channel** of a fork of arity `n`: a two-bit packet whose rate
is degraded *multiplicatively* by the entropy deficit. -/
noncomputable def X (n : ℝ) : ℝ := 2 * (1 - deficit n)

/-- The **resonance** of the fork: `log₂ n + δ n`.  The whole `A`-versus-`X`
comparison is governed by whether this exceeds `3`. -/
noncomputable def resonance (n : ℝ) : ℝ := logb 2 n + deficit n

/-- The channel ratio `A / X`. -/
noncomputable def ratio (n : ℝ) : ℝ := A n / X n

/-! ## 2. Combinatorial grounding of the entropy deficit

For integral arity the deficit is the collision probability of two independent
uniform probes of the ordered branch-pair set `[n] × [n]`. -/

/-- The diagonal of `S × S` for `S = Fin n × Fin n` has exactly `n²` elements,
out of `(n²)²` pairs: the fork collision probability is `1/n²`, which is the
entropy deficit. -/
theorem deficit_eq_forkCollision (n : ℕ) (hn : 0 < n) :
    deficit n =
      ((Finset.univ : Finset (Fin n × Fin n)).diag.card : ℝ) /
        ((Fintype.card (Fin n × Fin n) : ℝ) * (Fintype.card (Fin n × Fin n) : ℝ)) := by
  have hcard : ((Finset.univ : Finset (Fin n × Fin n)).diag.card : ℝ) = (n : ℝ) ^ 2 := by
    rw [Finset.diag_card]
    simp [pow_two]
  have hft : (Fintype.card (Fin n × Fin n) : ℝ) = (n : ℝ) ^ 2 := by
    simp [pow_two]
  have hne : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  rw [hcard, hft, deficit]
  field_simp

/-! ## 3. The exchange channel and the sharpened `X · n²` identity -/

/-- The sharpened finite-`n` identity for `X · n²`. -/
theorem X_mul_sq (n : ℝ) (hn : n ≠ 0) : X n * n ^ 2 = 2 * n ^ 2 - 2 := by
  unfold X deficit
  field_simp

theorem X_pos {n : ℝ} (hn : 1 < n) : 0 < X n := by
  unfold X deficit
  have h1 : (0:ℝ) < n := lt_trans one_pos hn
  have h2 : (1:ℝ) < n ^ 2 := by nlinarith
  have : 1 / n ^ 2 < 1 := by
    rw [div_lt_one (by positivity)]; exact h2
  linarith

theorem X_lt_two {n : ℝ} (hn : 0 < n) : X n < 2 := by
  unfold X deficit
  have : 0 < 1 / n ^ 2 := by positivity
  linarith

/-! ## 4. The gap collapses onto the resonance -/

/-- The key algebraic collapse: `A - X = R - 3`. -/
theorem A_sub_X (n : ℝ) : A n - X n = resonance n - 3 := by
  unfold A X resonance
  ring

theorem A_lt_X_iff (n : ℝ) : A n < X n ↔ resonance n < 3 := by
  constructor
  · intro h; have := A_sub_X n; linarith
  · intro h; have := A_sub_X n; linarith

theorem X_lt_A_iff (n : ℝ) : X n < A n ↔ 3 < resonance n := by
  constructor
  · intro h; have := A_sub_X n; linarith
  · intro h; have := A_sub_X n; linarith

theorem A_eq_X_iff (n : ℝ) : A n = X n ↔ resonance n = 3 := by
  constructor
  · intro h; have := A_sub_X n; linarith
  · intro h; have := A_sub_X n; linarith

/-! ## 5. Derivatives -/

theorem hasDerivAt_deficit {n : ℝ} (hn : n ≠ 0) :
    HasDerivAt deficit (-2 / n ^ 3) n := by
  have hsq : HasDerivAt (fun x : ℝ => x ^ 2) (2 * n) n := by
    simpa using (hasDerivAt_pow 2 n)
  have hne : (n : ℝ) ^ 2 ≠ 0 := pow_ne_zero _ hn
  have h := (hasDerivAt_const n (1:ℝ)).div hsq hne
  refine h.congr_deriv ?_
  field_simp
  ring

theorem hasDerivAt_logb2 {n : ℝ} (hn : n ≠ 0) :
    HasDerivAt (fun x : ℝ => logb 2 x) (1 / (n * Real.log 2)) n := by
  have hlog : HasDerivAt Real.log n⁻¹ n := Real.hasDerivAt_log hn
  have h : HasDerivAt (fun x : ℝ => logb 2 x) (n⁻¹ / Real.log 2) n :=
    hlog.div_const (Real.log 2)
  refine h.congr_deriv ?_
  field_simp

theorem hasDerivAt_resonance {n : ℝ} (hn : n ≠ 0) :
    HasDerivAt resonance (1 / (n * Real.log 2) - 2 / n ^ 3) n := by
  have h : HasDerivAt resonance (1 / (n * Real.log 2) + -2 / n ^ 3) n :=
    (hasDerivAt_logb2 hn).add (hasDerivAt_deficit hn)
  refine h.congr_deriv ?_
  ring

theorem hasDerivAt_A {n : ℝ} (hn : n ≠ 0) :
    HasDerivAt A (1 / (n * Real.log 2) + 2 / n ^ 3) n := by
  have h : HasDerivAt A (1 / (n * Real.log 2) - -2 / n ^ 3) n :=
    ((hasDerivAt_logb2 hn).sub_const 1).sub (hasDerivAt_deficit hn)
  refine h.congr_deriv ?_
  ring

theorem hasDerivAt_X {n : ℝ} (hn : n ≠ 0) : HasDerivAt X (4 / n ^ 3) n := by
  have h : HasDerivAt X (2 * -(-2 / n ^ 3)) n :=
    ((hasDerivAt_deficit hn).const_sub 1).const_mul (2:ℝ)
  refine h.congr_deriv ?_
  ring

/-! ## 6. Strict monotonicity of the resonance -/

theorem resonance_deriv_pos {n : ℝ} (hn : 2 ≤ n) :
    0 < 1 / (n * Real.log 2) - 2 / n ^ 3 := by
  have hl2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hnpos : (0:ℝ) < n := by linarith
  have h1 : 0 < n * Real.log 2 := by positivity
  have h2 : (0:ℝ) < n ^ 3 := by positivity
  have hl2u : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have hn3 : 4 * n ≤ n ^ 3 := by
    nlinarith [mul_nonneg (mul_nonneg hnpos.le (sub_nonneg.2 hn)) (by linarith : (0:ℝ) ≤ n + 2)]
  have hnl : n * Real.log 2 < n * 0.6931471808 := by nlinarith
  rw [sub_pos, div_lt_div_iff₀ h2 h1]
  linarith

theorem resonance_continuousOn : ContinuousOn resonance (Ici 2) := by
  intro x hx
  have hx0 : x ≠ 0 := by
    have : (2:ℝ) ≤ x := hx
    intro h; rw [h] at this; linarith
  exact (hasDerivAt_resonance hx0).continuousAt.continuousWithinAt

/-- The resonance `log₂ n + 1/n²` is strictly increasing on `[2, ∞)`. -/
theorem resonance_strictMonoOn : StrictMonoOn resonance (Ici 2) := by
  apply strictMonoOn_of_deriv_pos (convex_Ici 2) resonance_continuousOn
  intro x hx
  rw [interior_Ici] at hx
  have hx2 : (2:ℝ) ≤ x := le_of_lt hx
  have hx0 : x ≠ 0 := by intro h; rw [h] at hx2; linarith
  rw [(hasDerivAt_resonance hx0).deriv]
  exact resonance_deriv_pos hx2

/-! ## 7. The integer criterion: one integer inequality per side -/

theorem resonance_lt_three_iff {n : ℝ} (hn : 0 < n) :
    resonance n < 3 ↔ Real.log n * n ^ 2 < (3 * n ^ 2 - 1) * Real.log 2 := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hn2 : (0:ℝ) < n ^ 2 := by positivity
  unfold resonance deficit logb
  rw [div_add_div _ _ (ne_of_gt hl2) (ne_of_gt hn2), div_lt_iff₀ (by positivity)]
  constructor <;> intro h <;> nlinarith [h]

theorem three_lt_resonance_iff {n : ℝ} (hn : 0 < n) :
    3 < resonance n ↔ (3 * n ^ 2 - 1) * Real.log 2 < Real.log n * n ^ 2 := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hn2 : (0:ℝ) < n ^ 2 := by positivity
  unfold resonance deficit logb
  rw [div_add_div _ _ (ne_of_gt hl2) (ne_of_gt hn2), lt_div_iff₀ (by positivity)]
  constructor <;> intro h <;> nlinarith [h]

/-- Bridge between the real analytic comparison and pure integer arithmetic. -/
theorem log_compare_iff_nat (m : ℕ) (hm : 2 ≤ m) :
    Real.log m * (m:ℝ) ^ 2 < (3 * (m:ℝ) ^ 2 - 1) * Real.log 2 ↔
      m ^ (m ^ 2) < 2 ^ (3 * m ^ 2 - 1) := by
  have hm0 : (0:ℝ) < (m:ℝ) := by
    exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hm
  have hone : 1 ≤ 3 * m ^ 2 := by nlinarith [hm]
  have hcast : ((3 * m ^ 2 - 1 : ℕ) : ℝ) = 3 * (m:ℝ) ^ 2 - 1 := by
    rw [Nat.cast_sub hone]; push_cast; ring
  have hL : Real.log ((m:ℝ) ^ (m ^ 2)) = Real.log m * (m:ℝ) ^ 2 := by
    rw [Real.log_pow]
    push_cast
    ring
  have hR : Real.log ((2:ℝ) ^ (3 * m ^ 2 - 1)) = (3 * (m:ℝ) ^ 2 - 1) * Real.log 2 := by
    rw [Real.log_pow, hcast]
  constructor
  · intro h
    have : ((m:ℝ)) ^ (m ^ 2) < (2:ℝ) ^ (3 * m ^ 2 - 1) := by
      rw [← Real.log_lt_log_iff (by positivity) (by positivity), hL, hR]
      exact h
    exact_mod_cast this
  · intro h
    have h' : ((m:ℝ)) ^ (m ^ 2) < (2:ℝ) ^ (3 * m ^ 2 - 1) := by exact_mod_cast h
    rw [← hL, ← hR]
    exact (Real.log_lt_log_iff (by positivity) (by positivity)).2 h'

/-- **One integer inequality per side (negative side).**  For integral arity
`m ≥ 2` the address channel beats nothing precisely when `m^(m²) < 2^(3m²-1)`. -/
theorem integer_criterion_lt (m : ℕ) (hm : 2 ≤ m) :
    A m < X m ↔ m ^ (m ^ 2) < 2 ^ (3 * m ^ 2 - 1) := by
  have hm0 : (0:ℝ) < (m:ℝ) := by
    exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hm
  rw [A_lt_X_iff, resonance_lt_three_iff hm0, log_compare_iff_nat m hm]

/-- **One integer inequality per side (positive side).** -/
theorem integer_criterion (m : ℕ) (hm : 2 ≤ m) :
    X m < A m ↔ 2 ^ (3 * m ^ 2 - 1) < m ^ (m ^ 2) := by
  have hm0 : (0:ℝ) < (m:ℝ) := by
    exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hm
  have hone : 1 ≤ 3 * m ^ 2 := by nlinarith [hm]
  have hcast : ((3 * m ^ 2 - 1 : ℕ) : ℝ) = 3 * (m:ℝ) ^ 2 - 1 := by
    rw [Nat.cast_sub hone]; push_cast; ring
  have hL : Real.log ((m:ℝ) ^ (m ^ 2)) = Real.log m * (m:ℝ) ^ 2 := by
    rw [Real.log_pow]; push_cast; ring
  have hR : Real.log ((2:ℝ) ^ (3 * m ^ 2 - 1)) = (3 * (m:ℝ) ^ 2 - 1) * Real.log 2 := by
    rw [Real.log_pow, hcast]
  rw [X_lt_A_iff, three_lt_resonance_iff hm0]
  constructor
  · intro h
    have : ((2:ℝ)) ^ (3 * m ^ 2 - 1) < (m:ℝ) ^ (m ^ 2) := by
      rw [← Real.log_lt_log_iff (by positivity) (by positivity), hL, hR]
      exact h
    exact_mod_cast this
  · intro h
    have h' : ((2:ℝ)) ^ (3 * m ^ 2 - 1) < (m:ℝ) ^ (m ^ 2) := by exact_mod_cast h
    rw [← hL, ← hR]
    exact (Real.log_lt_log_iff (by positivity) (by positivity)).2 h'

/-- The decisive integer certificate on the negative side: `7 ^ 49 < 2 ^ 146`. -/
theorem certificate_seven : (7:ℕ) ^ (7 ^ 2) < 2 ^ (3 * 7 ^ 2 - 1) := by norm_num

/-- The decisive integer certificate on the positive side: `2 ^ 191 < 8 ^ 64`. -/
theorem certificate_eight : (2:ℕ) ^ (3 * 8 ^ 2 - 1) < 8 ^ (8 ^ 2) := by norm_num

theorem A_seven_lt_X_seven : A 7 < X 7 := by
  have h := (integer_criterion_lt 7 (by norm_num)).2 certificate_seven
  norm_num at h ⊢
  exact h

theorem X_eight_lt_A_eight : X 8 < A 8 := by
  have h := (integer_criterion 8 (by norm_num)).2 certificate_eight
  norm_num at h ⊢
  exact h

theorem resonance_seven_lt_three : resonance 7 < 3 :=
  (A_lt_X_iff 7).1 A_seven_lt_X_seven

theorem three_lt_resonance_eight : 3 < resonance 8 :=
  (X_lt_A_iff 8).1 X_eight_lt_A_eight

/-! ## 8. The sign dichotomy -/

/-- **Negative side.**  `A n < X n` for every real `2 < n ≤ 7`. -/
theorem A_lt_X_of_le_seven {n : ℝ} (h2 : 2 < n) (h7 : n ≤ 7) : A n < X n := by
  rw [A_lt_X_iff]
  have hmem : n ∈ Ici (2:ℝ) := le_of_lt h2
  have hmem7 : (7:ℝ) ∈ Ici (2:ℝ) := by norm_num
  have : resonance n ≤ resonance 7 := by
    rcases eq_or_lt_of_le h7 with h | h
    · rw [h]
    · exact le_of_lt (resonance_strictMonoOn hmem hmem7 h)
  linarith [resonance_seven_lt_three]

/-- **Positive side.**  `X n < A n` for every real `n ≥ 8`. -/
theorem X_lt_A_of_ge_eight {n : ℝ} (h8 : 8 ≤ n) : X n < A n := by
  rw [X_lt_A_iff]
  have hmem : n ∈ Ici (2:ℝ) := by simp only [mem_Ici]; linarith
  have hmem8 : (8:ℝ) ∈ Ici (2:ℝ) := by norm_num
  have : resonance 8 ≤ resonance n := by
    rcases eq_or_lt_of_le h8 with h | h
    · rw [h]
    · exact le_of_lt (resonance_strictMonoOn hmem8 hmem h)
  linarith [three_lt_resonance_eight]

/-! ## 9. Uniqueness of the crossing -/

/-- There is exactly one arity `r > 2` at which the two channels agree, and it
lies strictly between `7` and `8`.  Hence the crossing found between `n = 7`
and `n = 8` is the *only* crossing. -/
theorem exists_unique_crossing :
    ∃! r : ℝ, 2 < r ∧ A r = X r := by
  -- existence, by the intermediate value theorem on `[7,8]`
  have hsub : Icc (7:ℝ) 8 ⊆ Ici (2:ℝ) := fun x hx => le_trans (by norm_num) hx.1
  have hcont : ContinuousOn resonance (Icc (7:ℝ) 8) :=
    resonance_continuousOn.mono hsub
  have hmem : (3:ℝ) ∈ Icc (resonance 7) (resonance 8) :=
    ⟨le_of_lt resonance_seven_lt_three, le_of_lt three_lt_resonance_eight⟩
  obtain ⟨r, hr, hres⟩ := intermediate_value_Icc (by norm_num : (7:ℝ) ≤ 8) hcont hmem
  refine ⟨r, ⟨by linarith [hr.1], (A_eq_X_iff r).2 hres⟩, ?_⟩
  rintro y ⟨hy2, hy⟩
  have hyres : resonance y = 3 := (A_eq_X_iff y).1 hy
  have hymem : y ∈ Ici (2:ℝ) := le_of_lt hy2
  have hrmem : r ∈ Ici (2:ℝ) := by
    simp only [mem_Ici]; linarith [hr.1]
  exact resonance_strictMonoOn.injOn hymem hrmem (by rw [hyres, hres])

/-- The unique crossing is strictly between `7` and `8`. -/
theorem crossing_mem_Ioo :
    ∃ r : ℝ, 7 < r ∧ r < 8 ∧ A r = X r ∧ ∀ y : ℝ, 2 < y → A y = X y → y = r := by
  obtain ⟨r, ⟨hr2, hrEq⟩, huniq⟩ := exists_unique_crossing
  have hres : resonance r = 3 := (A_eq_X_iff r).1 hrEq
  have h7 : 7 < r := by
    by_contra h
    push_neg at h
    exact absurd hres (ne_of_lt (by
      have := A_lt_X_of_le_seven hr2 h
      have := (A_lt_X_iff r).1 this
      linarith))
  have h8 : r < 8 := by
    by_contra h
    push_neg at h
    have := X_lt_A_of_ge_eight h
    have := (X_lt_A_iff r).1 this
    linarith
  exact ⟨r, h7, h8, hrEq, fun y hy2 hy => huniq y ⟨hy2, hy⟩⟩

/-! ## 10. Monotonicity of the ratio `A/X` -/

theorem ratio_deriv_num_pos {n : ℝ} (hn : 1 < n) :
    0 < (1 / (n * Real.log 2) + 2 / n ^ 3) * X n - A n * (4 / n ^ 3) := by
  have hl2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hl2pos : (0:ℝ) < Real.log 2 := by linarith
  have hnpos : (0:ℝ) < n := lt_trans one_pos hn
  have hlog : Real.log n ≤ n - 1 := Real.log_le_sub_one_of_pos hnpos
  have key : (1 / (n * Real.log 2) + 2 / n ^ 3) * X n - A n * (4 / n ^ 3) =
      2 * ((n ^ 2 - 1) + 4 * Real.log 2 - 2 * Real.log n) / (n ^ 3 * Real.log 2) := by
    unfold A X deficit logb
    field_simp
    ring
  rw [key]
  apply div_pos
  · nlinarith [sq_nonneg (n - 1)]
  · positivity

theorem ratio_continuousOn : ContinuousOn ratio (Ici 2) := by
  intro x hx
  have hx2 : (2:ℝ) ≤ x := hx
  have hx0 : x ≠ 0 := by intro h; rw [h] at hx2; linarith
  have hXne : X x ≠ 0 := ne_of_gt (X_pos (by linarith))
  exact (((hasDerivAt_A hx0).div (hasDerivAt_X hx0) hXne).continuousAt).continuousWithinAt

/-- **Monotonicity of `A/X`.**  The channel ratio is strictly increasing on
`[2, ∞)`; in particular on `[8, ∞)`, which closes the monotonicity gap. -/
theorem ratio_strictMonoOn : StrictMonoOn ratio (Ici 2) := by
  apply strictMonoOn_of_deriv_pos (convex_Ici 2) ratio_continuousOn
  intro x hx
  rw [interior_Ici] at hx
  have hx2 : (2:ℝ) < x := hx
  have hx0 : x ≠ 0 := by intro h; rw [h] at hx2; linarith
  have hXne : X x ≠ 0 := ne_of_gt (X_pos (by linarith))
  have hd : HasDerivAt ratio
      (((1 / (x * Real.log 2) + 2 / x ^ 3) * X x - A x * (4 / x ^ 3)) / X x ^ 2) x :=
    (hasDerivAt_A hx0).div (hasDerivAt_X hx0) hXne
  rw [hd.deriv]
  apply div_pos (ratio_deriv_num_pos (by linarith))
  positivity

theorem ratio_strictMonoOn_Ici_eight : StrictMonoOn ratio (Ici 8) :=
  ratio_strictMonoOn.mono (Set.Ici_subset_Ici.2 (by norm_num))

/-! ## 11. Divergence of the ratio -/

theorem logb_tendsto_atTop : Tendsto (fun n : ℝ => logb 2 n) atTop atTop := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have := Real.tendsto_log_atTop.atTop_div_const hl2
  simpa [Real.logb] using this

theorem ratio_ge_of_ge_eight {n : ℝ} (hn : 8 ≤ n) :
    (logb 2 n - 2) / 2 ≤ ratio n := by
  have hnpos : (0:ℝ) < n := by linarith
  have hXpos : 0 < X n := X_pos (by linarith)
  have hXlt : X n < 2 := X_lt_two hnpos
  have hdef : 0 < deficit n := by unfold deficit; positivity
  have hdef1 : deficit n ≤ 1 := by
    unfold deficit
    rw [div_le_one (by positivity)]
    nlinarith
  have hA : logb 2 n - 2 ≤ A n := by unfold A; linarith
  have hApos : 0 < A n := by
    have h3 : (3:ℝ) ≤ logb 2 n := by
      have : logb 2 (8:ℝ) ≤ logb 2 n := (Real.logb_le_logb (by norm_num) (by norm_num) hnpos).2 hn
      have h8 : logb 2 (8:ℝ) = 3 := by
        rw [show (8:ℝ) = 2 ^ (3:ℕ) by norm_num, Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
        norm_num
      linarith [h8 ▸ this]
    unfold A
    have : deficit n ≤ 1 := hdef1
    linarith
  rw [ratio, le_div_iff₀ hXpos]
  nlinarith

/-- **The ratio diverges.**  `A/X → ∞`. -/
theorem ratio_tendsto_atTop : Tendsto ratio atTop atTop := by
  have hbase : Tendsto (fun n : ℝ => (logb 2 n - 2) / 2) atTop atTop := by
    exact (logb_tendsto_atTop.atTop_add tendsto_const_nhds).atTop_div_const (by norm_num)
  refine tendsto_atTop_mono' atTop ?_ hbase
  filter_upwards [eventually_ge_atTop (8:ℝ)] with n hn
  exact ratio_ge_of_ge_eight hn

end ForkChannel