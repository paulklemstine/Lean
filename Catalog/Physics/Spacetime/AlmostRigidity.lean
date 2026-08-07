/-
  Quantitative (almost-)rigidity of the focusing bounds.

  `FocusingRigidity` proves the *equality* case of the two comparison theorems: if a
  congruence saturates the Penrose comparison (or the Prüfer phase estimate) at a single
  interior affine parameter, then it is exactly the model solution and its defect —
  the shear plus the Ricci focusing term — vanishes identically.

  Equality cases are unstable statements: nothing in them says what happens for a
  congruence that saturates the bound only *approximately*.  This file proves the
  quantitative version (Conjecture D of `FUTURE_DIRECTIONS.md`): being `δ`-close to the
  model forces the *accumulated defect* to be `O(δ)`, with an explicit constant.

  * `penrose_stability` — if `θ t₀ ≥ riccatiSol m θ₀ t₀ - δ`, then the accumulated defect
    satisfies `P t₀ ≤ δ / (1 - δ U)²` where `U = riccatiScale m θ₀ t₀ = 1/|θ_model(t₀)|`
    is the reciprocal size of the model expansion at `t₀`.  The bound is linear in `δ` to
    leading order and degenerates exactly when `δ` reaches `|θ_model(t₀)|`, i.e. when the
    hypothesis stops carrying information.
  * `penrose_weighted_stability` — the same estimate for the defect measured against the
    natural weight `1/θ²`: `W t₀ ≤ δ U²` for *every* `δ ≥ 0`, with no smallness hypothesis.
    The factor `1/(1 - δU)²` above is exactly the price of converting the weight away.
  * `penrose_rigidity_of_stability` — the `δ = 0` specialization returns the rigidity
    statement (zero accumulated defect), so the stability estimate genuinely interpolates.
  * `myers_phase_stability` — the same phenomenon for the Prüfer/Bonnet–Myers estimate:
    a phase deficit of at most `δ` at `t₀` forces `P t₀ ≤ ((mε + M²)/√(mε)) δ`, where
    `M² = max (θ₀², θ(t₀)²)` is the (automatically finite) range of the expansion.
  * `GeodesicCongruence.accumulated_defect_le_of_almost_saturated`,
    `GeodesicCongruence.weighted_defect_le_of_almost_saturated` and
    `GeodesicCongruence.accumulated_defect_le_of_phase_deficit` — the congruence forms,
    with the accumulated defect written as the honest integral `∫₀^{t₀} (σ² + Ric)`.

  The mechanism in both cases is the same: the monotone quantity used to prove the bound
  (`1/θ - t/m` for Penrose, the Prüfer angle for Myers) is monotone *with a definite
  margin* proportional to the defect rate, so an almost-extremal endpoint value leaves
  only `O(δ)` room for the accumulated margin.
-/

import Physics.Spacetime.FocusingRigidity

open Set

namespace Catalog.Physics.Spacetime

/-! ### An antitone companion to `monotoneOn_of_hasDerivAt_nonneg` -/

section Antitone

variable {a b : ℝ} {f f' : ℝ → ℝ}

/-- A function with everywhere non-positive derivative on `[a, b]` is antitone there. -/
theorem antitoneOn_of_hasDerivAt_nonpos
    (hd : ∀ x ∈ Icc a b, HasDerivAt f (f' x) x)
    (hf' : ∀ x ∈ Ioo a b, f' x ≤ 0) :
    AntitoneOn f (Icc a b) := by
  have hmono : MonotoneOn (fun x => -f x) (Icc a b) :=
    monotoneOn_of_hasDerivAt_nonneg (f' := fun x => -f' x)
      (fun x hx => (hd x hx).neg) (fun x hx => by simpa using hf' x hx)
  intro x hx y hy hxy
  have := hmono hx hy hxy
  simpa using this

end Antitone

/-! ### The reciprocal scale of the model solution -/

section Scale

/-- The reciprocal size `1 / |θ_model(t)|` of the model Riccati solution.  It is the
natural scale in which a deviation `δ` from the model has to be measured. -/
noncomputable def riccatiScale (m t0 t : ℝ) : ℝ := -(m + t0 * t) / (m * t0)

theorem riccatiScale_pos {m t0 t : ℝ} (hm : 0 < m) (h0 : t0 < 0)
    (hden : 0 < m + t0 * t) : 0 < riccatiScale m t0 t := by
  have hmt : m * t0 < 0 := mul_neg_of_pos_of_neg hm h0
  unfold riccatiScale
  exact div_pos_of_neg_of_neg (by linarith) hmt

/-- `-riccatiScale` is the reciprocal of the model solution, written out. -/
theorem neg_riccatiScale_eq {m t0 t : ℝ} (hm : m ≠ 0) (h0 : t0 ≠ 0) :
    -riccatiScale m t0 t = t0⁻¹ + t / m := by
  unfold riccatiScale
  field_simp

/-- The model solution and the scale are reciprocal up to sign: `θ_model · U = -1`. -/
theorem riccatiSol_mul_riccatiScale {m t0 t : ℝ} (hm : m ≠ 0) (h0 : t0 ≠ 0)
    (hden : m + t0 * t ≠ 0) :
    riccatiSol m t0 t * riccatiScale m t0 t = -1 := by
  unfold riccatiSol riccatiScale
  field_simp

end Scale

/-! ### Stability of the Penrose comparison -/

section PenroseStability

variable {m L : ℝ} {θ θ' P p W : ℝ → ℝ}

set_option maxHeartbeats 1000000 in
/-- **Quantitative almost-rigidity of the Penrose bound.**
Let `θ` obey the Raychaudhuri inequality with defect rate `p ≥ 0`,
`θ' ≤ -θ²/m - p`, and let `P` be the accumulated defect (`P 0 = 0`, `P' = p`).
If at some interior parameter `t₀` the expansion is within `δ` of the model solution,
then the whole accumulated defect on `[0, t₀]` is at most `δ / (1 - δ U)²`, where
`U = riccatiScale m θ₀ t₀`.  For `δ = 0` this is the rigidity statement `P t₀ ≤ 0`,
and the bound is linear in `δ` for small `δ`. -/
theorem penrose_stability (hm : 0 < m) {t0 delta : ℝ} (ht0 : 0 < t0) (ht0L : t0 < L)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hPd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt P (p x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - p x)
    (hpnn : ∀ x ∈ Ico (0 : ℝ) L, 0 ≤ p x)
    (hP0 : P 0 = 0) (h0 : θ 0 < 0) (hdelta : 0 ≤ delta)
    (hsat : riccatiSol m (θ 0) t0 - delta ≤ θ t0)
    (hsmall : delta * riccatiScale m (θ 0) t0 < 1) :
    P t0 ≤ delta / (1 - delta * riccatiScale m (θ 0) t0) ^ 2 := by
  have hIcc : Icc (0 : ℝ) t0 ⊆ Ico (0 : ℝ) L := fun x hx => ⟨hx.1, lt_of_le_of_lt hx.2 ht0L⟩
  have hne0 : θ 0 ≠ 0 := ne_of_lt h0
  -- the plain Raychaudhuri inequality, forgetting the defect
  have hineq0 : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m := by
    intro x hx
    have h1 := hineq x hx
    have h2 := hpnn x hx
    linarith
  have hle : ∀ t ∈ Ico (0 : ℝ) L, θ t ≤ θ 0 := expansion_le_init hm hd hineq0 h0
  have hneg : ∀ t ∈ Icc (0 : ℝ) t0, θ t < 0 := fun t ht =>
    lt_of_le_of_lt (hle t (hIcc ht)) h0
  have hne : ∀ t ∈ Icc (0 : ℝ) t0, θ t ≠ 0 := fun t ht => ne_of_lt (hneg t ht)
  -- positivity of the model denominator at `t₀`
  have hdenpos : 0 < m + θ 0 * t0 := by
    have hlt : t0 < m / (-θ 0) := focusing_time_bound hm hd hineq0 h0 t0 ⟨ht0.le, ht0L⟩
    rw [lt_div_iff₀ (neg_pos.2 h0)] at hlt
    nlinarith
  set U : ℝ := riccatiScale m (θ 0) t0 with hU
  have hUpos : 0 < U := riccatiScale_pos hm h0 hdenpos
  have hsum : (θ 0)⁻¹ + t0 / m = -U := by
    rw [hU, neg_riccatiScale_eq (ne_of_gt hm) hne0]
  have hmodelval : riccatiSol m (θ 0) t0 = -1 / U := by
    rw [eq_div_iff (ne_of_gt hUpos)]
    exact riccatiSol_mul_riccatiScale (ne_of_gt hm) hne0 (ne_of_gt hdenpos)
  -- the monotone quantity of the Raychaudhuri argument
  set f : ℝ → ℝ := fun x => (θ x)⁻¹ - x / m with hf
  set f' : ℝ → ℝ := fun x => -θ' x / (θ x) ^ 2 - 1 / m with hfd
  have hdf : ∀ x ∈ Icc (0 : ℝ) t0, HasDerivAt f (f' x) x := by
    intro x hx
    simpa [hf, hfd] using ((hd x (hIcc hx)).inv (hne x hx)).sub ((hasDerivAt_id x).div_const m)
  -- the derivative dominates the defect rate divided by `θ²`
  have hmargin : ∀ x ∈ Ioo (0 : ℝ) t0, p x / (θ x) ^ 2 ≤ f' x := by
    intro x hx
    have hxI : x ∈ Icc (0 : ℝ) t0 := Ioo_subset_Icc_self hx
    have h1 : θ' x ≤ -(θ x) ^ 2 / m - p x := hineq x (hIcc hxI)
    have h2 : (0 : ℝ) < (θ x) ^ 2 := by have := hne x hxI; positivity
    have h3 : θ' x * m ≤ -(θ x) ^ 2 - p x * m := by
      have h4 : (-(θ x) ^ 2 / m - p x) * m = -(θ x) ^ 2 - p x * m := by field_simp
      nlinarith [mul_le_mul_of_nonneg_right h1 hm.le]
    simp only [hfd]
    rw [div_sub_div _ _ (ne_of_gt h2) (ne_of_gt hm), div_le_div_iff₀ h2 (by positivity)]
    nlinarith
  have hf'nonneg : ∀ x ∈ Ioo (0 : ℝ) t0, 0 ≤ f' x := by
    intro x hx
    have hxI : x ∈ Icc (0 : ℝ) t0 := Ioo_subset_Icc_self hx
    have h2 : (0 : ℝ) < (θ x) ^ 2 := by have := hne x hxI; positivity
    have hp : 0 ≤ p x := hpnn x (hIcc hxI)
    have hq : 0 ≤ p x / (θ x) ^ 2 := div_nonneg hp h2.le
    linarith [hmargin x hx]
  have hfmono : MonotoneOn f (Icc (0 : ℝ) t0) :=
    monotoneOn_of_hasDerivAt_nonneg hdf hf'nonneg
  -- Step 1: the endpoint value of `f` exceeds the initial one by at most `δ U²`
  have hcomp : θ t0 ≤ riccatiSol m (θ 0) t0 :=
    expansion_comparison hm hd hineq0 h0 t0 ⟨ht0.le, ht0L⟩
  have ht0neg : θ t0 < 0 := hneg t0 (right_mem_Icc.2 ht0.le)
  have hnegdiv : (-1 : ℝ) / U = -(1 / U) := by ring
  have hy1 : 1 / U ≤ -θ t0 := by
    rw [hmodelval, hnegdiv] at hcomp
    linarith
  have hy2 : -θ t0 ≤ 1 / U + delta := by
    rw [hmodelval, hnegdiv] at hsat
    linarith
  have hy0 : 0 < -θ t0 := by linarith [ht0neg]
  have hUy1 : 1 ≤ (-θ t0) * U := (div_le_iff₀ hUpos).1 hy1
  have hUU : (1 / U) * U = 1 := by field_simp
  have hUy2 : (-θ t0) * U ≤ 1 + delta * U := by
    nlinarith [mul_le_mul_of_nonneg_right hy2 hUpos.le]
  have hnet0 : θ t0 ≠ 0 := ne_of_lt ht0neg
  have hkey : (θ t0)⁻¹ + U ≤ delta * U ^ 2 := by
    have hinv : (θ t0)⁻¹ + U = (U * (-θ t0) - 1) / (-θ t0) := by
      field_simp
      ring
    rw [hinv, div_le_iff₀ hy0]
    nlinarith [mul_nonneg (mul_nonneg hdelta hUpos.le) (sub_nonneg.2 hUy1)]
  have hfval : ∀ x : ℝ, f x = (θ x)⁻¹ - x / m := fun x => rfl
  have hf0 : f 0 = (θ 0)⁻¹ := by rw [hfval]; simp
  have hstep1 : f t0 - f 0 ≤ delta * U ^ 2 := by
    rw [hfval, hf0]
    linarith [hkey, hsum]
  -- Step 2: hence `θ` stays bounded on `[0, t₀]`
  set K : ℝ := U * (1 - delta * U) with hK
  have hKval : K = U - delta * U ^ 2 := by rw [hK]; ring
  have hKpos : 0 < K := by
    have h1 : 0 < 1 - delta * U := by linarith
    rw [hK]
    positivity
  have hbdd : ∀ t ∈ Icc (0 : ℝ) t0, (θ t) ^ 2 ≤ 1 / K ^ 2 := by
    intro t ht
    have hft : f t ≤ f t0 := hfmono ht (right_mem_Icc.2 ht0.le) ht.2
    have hinvle : (θ t)⁻¹ - t / m ≤ (θ 0)⁻¹ + delta * U ^ 2 := by
      rw [hfval, hfval] at hft
      rw [hfval, hf0] at hstep1
      linarith
    have hmono0 : t / m ≤ t0 / m := by gcongr; exact ht.2
    have hle2 : (θ t)⁻¹ ≤ -K := by
      rw [hKval]
      linarith [hsum]
    -- convert to a bound on `|θ t|`
    have htneg : θ t < 0 := hneg t ht
    have hpos : 0 < -θ t := by linarith
    have hinvt : (θ t)⁻¹ = -(1 / (-θ t)) := by field_simp
    have hKle : K ≤ 1 / (-θ t) := by
      rw [hinvt] at hle2
      linarith
    have habs : -θ t ≤ 1 / K := by
      rw [le_div_iff₀ hpos] at hKle
      rw [le_div_iff₀ hKpos]
      linarith
    have hsq : (θ t) ^ 2 = (-θ t) ^ 2 := by ring
    rw [hsq]
    have h1K : 0 < 1 / K := by positivity
    have : (1 / K) ^ 2 = 1 / K ^ 2 := by field_simp
    nlinarith
  -- Step 3: the accumulated defect fits into the room left by `δ`
  set h : ℝ → ℝ := fun x => f x - K ^ 2 * P x with hh
  set h' : ℝ → ℝ := fun x => f' x - K ^ 2 * p x with hhd
  have hdh : ∀ x ∈ Icc (0 : ℝ) t0, HasDerivAt h (h' x) x := by
    intro x hx
    exact (hdf x hx).sub ((hPd x (hIcc hx)).const_mul (K ^ 2))
  have hh'nonneg : ∀ x ∈ Ioo (0 : ℝ) t0, 0 ≤ h' x := by
    intro x hx
    have hxI : x ∈ Icc (0 : ℝ) t0 := Ioo_subset_Icc_self hx
    have h2 : (0 : ℝ) < (θ x) ^ 2 := by have := hne x hxI; positivity
    have hp : 0 ≤ p x := hpnn x (hIcc hxI)
    have hbx : (θ x) ^ 2 ≤ 1 / K ^ 2 := hbdd x hxI
    have hK2 : (0 : ℝ) < K ^ 2 := by positivity
    have hprod : K ^ 2 * (θ x) ^ 2 ≤ 1 := by
      have h3 : K ^ 2 * (θ x) ^ 2 ≤ K ^ 2 * (1 / K ^ 2) := by
        exact mul_le_mul_of_nonneg_left hbx hK2.le
      have h4 : K ^ 2 * (1 / K ^ 2) = 1 := by field_simp
      linarith
    have hweight : K ^ 2 * p x ≤ p x / (θ x) ^ 2 := by
      rw [le_div_iff₀ h2]
      nlinarith
    simp only [hhd]
    linarith [hmargin x hx]
  have hhmono : MonotoneOn h (Icc (0 : ℝ) t0) :=
    monotoneOn_of_hasDerivAt_nonneg hdh hh'nonneg
  have hfin : h 0 ≤ h t0 :=
    hhmono (left_mem_Icc.2 ht0.le) (right_mem_Icc.2 ht0.le) ht0.le
  simp only [hh, hP0, mul_zero, sub_zero] at hfin
  have hPle : K ^ 2 * P t0 ≤ delta * U ^ 2 := by linarith
  have hK2 : K ^ 2 = U ^ 2 * (1 - delta * U) ^ 2 := by rw [hK]; ring
  have hUpos2 : (0 : ℝ) < U ^ 2 := by positivity
  have hdpos : (0 : ℝ) < (1 - delta * U) ^ 2 := by
    have h1 : 0 < 1 - delta * U := by linarith
    positivity
  rw [hK2] at hPle
  rw [le_div_iff₀ hdpos]
  nlinarith [hPle]

set_option maxHeartbeats 400000 in
/-- **The weighted form of the stability estimate, valid without any smallness assumption
on `δ`.**  The quantity the Raychaudhuri comparison really controls is the defect measured
against the weight `1/θ²`: if `W` accumulates `p/θ²` then `W t₀ ≤ δ U²` for *every*
`δ ≥ 0`, with no hypothesis `δ U < 1`.  The unweighted bound `penrose_stability` is this
estimate plus the price of converting the weight, which is exactly what produces the
factor `1/(1 - δU)²` and its restriction to `δ U < 1`. -/
theorem penrose_weighted_stability (hm : 0 < m) {t0 delta : ℝ} (ht0 : 0 < t0) (ht0L : t0 < L)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hWd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt W (p x / (θ x) ^ 2) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - p x)
    (hpnn : ∀ x ∈ Ico (0 : ℝ) L, 0 ≤ p x)
    (hW0 : W 0 = 0) (h0 : θ 0 < 0) (hdelta : 0 ≤ delta)
    (hsat : riccatiSol m (θ 0) t0 - delta ≤ θ t0) :
    W t0 ≤ delta * (riccatiScale m (θ 0) t0) ^ 2 := by
  have hIcc : Icc (0 : ℝ) t0 ⊆ Ico (0 : ℝ) L := fun x hx => ⟨hx.1, lt_of_le_of_lt hx.2 ht0L⟩
  have hne0 : θ 0 ≠ 0 := ne_of_lt h0
  have hineq0 : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m := by
    intro x hx
    have h1 := hineq x hx
    have h2 := hpnn x hx
    linarith
  have hle : ∀ t ∈ Ico (0 : ℝ) L, θ t ≤ θ 0 := expansion_le_init hm hd hineq0 h0
  have hneg : ∀ t ∈ Icc (0 : ℝ) t0, θ t < 0 := fun t ht =>
    lt_of_le_of_lt (hle t (hIcc ht)) h0
  have hne : ∀ t ∈ Icc (0 : ℝ) t0, θ t ≠ 0 := fun t ht => ne_of_lt (hneg t ht)
  have hdenpos : 0 < m + θ 0 * t0 := by
    have hlt : t0 < m / (-θ 0) := focusing_time_bound hm hd hineq0 h0 t0 ⟨ht0.le, ht0L⟩
    rw [lt_div_iff₀ (neg_pos.2 h0)] at hlt
    nlinarith
  set U : ℝ := riccatiScale m (θ 0) t0 with hU
  have hUpos : 0 < U := riccatiScale_pos hm h0 hdenpos
  have hsum : (θ 0)⁻¹ + t0 / m = -U := by
    rw [hU, neg_riccatiScale_eq (ne_of_gt hm) hne0]
  have hmodelval : riccatiSol m (θ 0) t0 = -1 / U := by
    rw [eq_div_iff (ne_of_gt hUpos)]
    exact riccatiSol_mul_riccatiScale (ne_of_gt hm) hne0 (ne_of_gt hdenpos)
  set f : ℝ → ℝ := fun x => (θ x)⁻¹ - x / m with hf
  set f' : ℝ → ℝ := fun x => -θ' x / (θ x) ^ 2 - 1 / m with hfd
  have hdf : ∀ x ∈ Icc (0 : ℝ) t0, HasDerivAt f (f' x) x := by
    intro x hx
    simpa [hf, hfd] using ((hd x (hIcc hx)).inv (hne x hx)).sub ((hasDerivAt_id x).div_const m)
  have hmargin : ∀ x ∈ Ioo (0 : ℝ) t0, p x / (θ x) ^ 2 ≤ f' x := by
    intro x hx
    have hxI : x ∈ Icc (0 : ℝ) t0 := Ioo_subset_Icc_self hx
    have h1 : θ' x ≤ -(θ x) ^ 2 / m - p x := hineq x (hIcc hxI)
    have h2 : (0 : ℝ) < (θ x) ^ 2 := by have := hne x hxI; positivity
    have h3 : θ' x * m ≤ -(θ x) ^ 2 - p x * m := by
      have h4 : (-(θ x) ^ 2 / m - p x) * m = -(θ x) ^ 2 - p x * m := by field_simp
      nlinarith [mul_le_mul_of_nonneg_right h1 hm.le]
    simp only [hfd]
    rw [div_sub_div _ _ (ne_of_gt h2) (ne_of_gt hm), div_le_div_iff₀ h2 (by positivity)]
    nlinarith
  -- Step 1: the endpoint value of `f` exceeds the initial one by at most `δ U²`
  have hcomp : θ t0 ≤ riccatiSol m (θ 0) t0 :=
    expansion_comparison hm hd hineq0 h0 t0 ⟨ht0.le, ht0L⟩
  have ht0neg : θ t0 < 0 := hneg t0 (right_mem_Icc.2 ht0.le)
  have hnegdiv : (-1 : ℝ) / U = -(1 / U) := by ring
  have hy1 : 1 / U ≤ -θ t0 := by
    rw [hmodelval, hnegdiv] at hcomp
    linarith
  have hy2 : -θ t0 ≤ 1 / U + delta := by
    rw [hmodelval, hnegdiv] at hsat
    linarith
  have hy0 : 0 < -θ t0 := by linarith [ht0neg]
  have hUy1 : 1 ≤ (-θ t0) * U := (div_le_iff₀ hUpos).1 hy1
  have hUU : (1 / U) * U = 1 := by field_simp
  have hUy2 : (-θ t0) * U ≤ 1 + delta * U := by
    nlinarith [mul_le_mul_of_nonneg_right hy2 hUpos.le]
  have hnet0 : θ t0 ≠ 0 := ne_of_lt ht0neg
  have hkey : (θ t0)⁻¹ + U ≤ delta * U ^ 2 := by
    have hinv : (θ t0)⁻¹ + U = (U * (-θ t0) - 1) / (-θ t0) := by
      field_simp
      ring
    rw [hinv, div_le_iff₀ hy0]
    nlinarith [mul_nonneg (mul_nonneg hdelta hUpos.le) (sub_nonneg.2 hUy1)]
  have hfval : ∀ x : ℝ, f x = (θ x)⁻¹ - x / m := fun x => rfl
  have hf0 : f 0 = (θ 0)⁻¹ := by rw [hfval]; simp
  have hstep1 : f t0 - f 0 ≤ delta * U ^ 2 := by
    rw [hfval, hf0]
    linarith [hkey, hsum]
  -- Step 2: `f - W` is monotone, since `W' = p/θ² ≤ f'`
  set g : ℝ → ℝ := fun x => f x - W x with hg
  have hdg : ∀ x ∈ Icc (0 : ℝ) t0, HasDerivAt g (f' x - p x / (θ x) ^ 2) x := fun x hx =>
    (hdf x hx).sub (hWd x (hIcc hx))
  have hgmono : MonotoneOn g (Icc (0 : ℝ) t0) :=
    monotoneOn_of_hasDerivAt_nonneg hdg fun x hx => by
      linarith [hmargin x hx]
  have hfin : g 0 ≤ g t0 :=
    hgmono (left_mem_Icc.2 ht0.le) (right_mem_Icc.2 ht0.le) ht0.le
  simp only [hg, hW0, sub_zero] at hfin
  linarith

/-- **Rigidity as the `δ = 0` case of stability.**  If the expansion actually reaches the
model value at `t₀`, the accumulated defect vanishes on `[0, t₀]`: the congruence is
shear-free and Ricci-flat there.  This re-derives `riccati_rigidity`'s conclusion from
the quantitative estimate, confirming that the stability bound is a genuine
interpolation. -/
theorem penrose_rigidity_of_stability (hm : 0 < m) {t0 : ℝ} (ht0 : 0 < t0) (ht0L : t0 < L)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hPd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt P (p x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - p x)
    (hpnn : ∀ x ∈ Ico (0 : ℝ) L, 0 ≤ p x)
    (hP0 : P 0 = 0) (h0 : θ 0 < 0)
    (hsat : θ t0 = riccatiSol m (θ 0) t0) :
    P t0 ≤ 0 := by
  have h := penrose_stability (delta := 0) hm ht0 ht0L hd hPd hineq hpnn hP0 h0 le_rfl
    (by rw [hsat]; linarith) (by simp)
  simpa using h

end PenroseStability

/-! ### Stability of the Prüfer / Bonnet–Myers phase estimate -/

section MyersStability

variable {m eps L : ℝ} {θ θ' P p : ℝ → ℝ}

set_option maxHeartbeats 1000000 in
/-- **Quantitative almost-rigidity of the Myers phase estimate.**
Let `θ' ≤ -θ²/m - ε - p` with defect rate `p ≥ 0` and accumulated defect `P`.
The Prüfer estimate says the phase `arctan(θ/√(mε))` has fallen by at least
`(√(mε)/m) t₀` at `t₀`.  If it has fallen by at most `δ` more than that, the accumulated
defect obeys `P t₀ ≤ ((mε + M²)/√(mε)) δ` with `M² = max (θ₀², θ(t₀)²)` the range of the
expansion — which is automatically finite because the expansion is strictly decreasing. -/
theorem myers_phase_stability (hm : 0 < m) (he : 0 < eps) {t0 delta : ℝ}
    (ht0 : 0 < t0) (ht0L : t0 < L)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hPd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt P (p x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - eps - p x)
    (hpnn : ∀ x ∈ Ico (0 : ℝ) L, 0 ≤ p x)
    (hP0 : P 0 = 0)
    (hsat : Real.arctan (θ 0 / Real.sqrt (m * eps))
        - Real.sqrt (m * eps) / m * t0 - delta
      ≤ Real.arctan (θ t0 / Real.sqrt (m * eps))) :
    P t0 ≤ (m * eps + max ((θ 0) ^ 2) ((θ t0) ^ 2)) / Real.sqrt (m * eps) * delta := by
  set a : ℝ := Real.sqrt (m * eps) with ha
  have hapos : 0 < a := Real.sqrt_pos.2 (by positivity)
  have hasq : a ^ 2 = m * eps := Real.sq_sqrt (by positivity)
  have hIcc : Icc (0 : ℝ) t0 ⊆ Ico (0 : ℝ) L := fun x hx => ⟨hx.1, lt_of_le_of_lt hx.2 ht0L⟩
  -- the expansion is strictly decreasing, hence confined between `θ t₀` and `θ 0`
  have hanti : AntitoneOn θ (Icc (0 : ℝ) t0) := by
    refine antitoneOn_of_hasDerivAt_nonpos (fun x hx => hd x (hIcc hx)) ?_
    intro x hx
    have hxI : x ∈ Icc (0 : ℝ) t0 := Ioo_subset_Icc_self hx
    have h1 := hineq x (hIcc hxI)
    have h2 := hpnn x (hIcc hxI)
    have h3 : -(θ x) ^ 2 / m ≤ 0 :=
      div_nonpos_of_nonpos_of_nonneg (by nlinarith [sq_nonneg (θ x)]) hm.le
    linarith
  set M2 : ℝ := max ((θ 0) ^ 2) ((θ t0) ^ 2) with hM2
  have hM2nn : 0 ≤ M2 := le_trans (sq_nonneg _) (le_max_left _ _)
  have hbdd : ∀ t ∈ Icc (0 : ℝ) t0, (θ t) ^ 2 ≤ M2 := by
    intro t ht
    have hup : θ t ≤ θ 0 := hanti (left_mem_Icc.2 ht0.le) ht ht.1
    have hlow : θ t0 ≤ θ t := hanti ht (right_mem_Icc.2 ht0.le) ht.2
    rcases le_or_gt 0 (θ t) with hpos | hnegt
    · exact le_trans (by nlinarith) (le_max_left ((θ 0) ^ 2) ((θ t0) ^ 2))
    · exact le_trans (by nlinarith) (le_max_right ((θ 0) ^ 2) ((θ t0) ^ 2))
  -- the defect-corrected Prüfer angle is non-increasing
  have hdenM : (0 : ℝ) < a ^ 2 + M2 := by positivity
  set c : ℝ := a / (a ^ 2 + M2) with hc
  have hcpos : 0 < c := div_pos hapos hdenM
  set Phi : ℝ → ℝ := fun x => Real.arctan (θ x / a) + a / m * x + c * P x with hPhi
  set Phi' : ℝ → ℝ := fun x => a * θ' x / (a ^ 2 + (θ x) ^ 2) + a / m + c * p x with hPhid
  have hdarctan : ∀ x ∈ Icc (0 : ℝ) t0,
      HasDerivAt (fun s => Real.arctan (θ s / a)) (a * θ' x / (a ^ 2 + (θ x) ^ 2)) x := by
    intro x hx
    have h1 : HasDerivAt (fun s => θ s / a) (θ' x / a) x := (hd x (hIcc hx)).div_const a
    have h2 := (Real.hasDerivAt_arctan (θ x / a)).comp x h1
    convert h2 using 1
    field_simp
  have hdPhi : ∀ x ∈ Icc (0 : ℝ) t0, HasDerivAt Phi (Phi' x) x := by
    intro x hx
    have h1 := hdarctan x hx
    have h2 : HasDerivAt (fun s : ℝ => a / m * s) (a / m) x := by
      simpa using (hasDerivAt_id x).const_mul (a / m)
    have h3 := (hPd x (hIcc hx)).const_mul c
    exact (h1.add h2).add h3
  have hPhi'nonpos : ∀ x ∈ Ioo (0 : ℝ) t0, Phi' x ≤ 0 := by
    intro x hx
    have hxI : x ∈ Icc (0 : ℝ) t0 := Ioo_subset_Icc_self hx
    have h1 : θ' x ≤ -(θ x) ^ 2 / m - eps - p x := hineq x (hIcc hxI)
    have hp : 0 ≤ p x := hpnn x (hIcc hxI)
    have hden : (0 : ℝ) < a ^ 2 + (θ x) ^ 2 := by positivity
    have hbx : (θ x) ^ 2 ≤ M2 := hbdd x hxI
    -- the Prüfer derivative loses `a/m` plus the weighted defect
    have hkey : a * θ' x / (a ^ 2 + (θ x) ^ 2) ≤ -(a / m) - a * p x / (a ^ 2 + (θ x) ^ 2) := by
      rw [div_le_iff₀ hden]
      calc a * θ' x ≤ a * (-(θ x) ^ 2 / m - eps - p x) :=
            mul_le_mul_of_nonneg_left h1 hapos.le
        _ = -(a / m) * (a ^ 2 + (θ x) ^ 2) - a * p x := by rw [hasq]; field_simp; ring
        _ = (-(a / m) - a * p x / (a ^ 2 + (θ x) ^ 2)) * (a ^ 2 + (θ x) ^ 2) := by
            field_simp
    have hweight : c * p x ≤ a * p x / (a ^ 2 + (θ x) ^ 2) := by
      rw [hc, div_mul_eq_mul_div, div_le_div_iff₀ hdenM hden]
      nlinarith [mul_nonneg (mul_nonneg hapos.le hp) (sub_nonneg.2 hbx)]
    simp only [hPhid]
    linarith
  have hPhianti : AntitoneOn Phi (Icc (0 : ℝ) t0) :=
    antitoneOn_of_hasDerivAt_nonpos hdPhi hPhi'nonpos
  have hfin : Phi t0 ≤ Phi 0 :=
    hPhianti (left_mem_Icc.2 ht0.le) (right_mem_Icc.2 ht0.le) ht0.le
  have hPhi0 : Phi 0 = Real.arctan (θ 0 / a) := by simp [hPhi, hP0]
  have hPhit0 : Phi t0 = Real.arctan (θ t0 / a) + a / m * t0 + c * P t0 := by simp [hPhi]
  rw [hPhi0, hPhit0] at hfin
  have hcP : c * P t0 ≤ delta := by linarith [hsat]
  have hposc : (0 : ℝ) < (a ^ 2 + M2) / a := div_pos hdenM hapos
  have hexpand : (a ^ 2 + M2) / a * (c * P t0) = P t0 := by
    rw [hc]
    field_simp
  have hfinal : P t0 ≤ (a ^ 2 + M2) / a * delta := by
    have := mul_le_mul_of_nonneg_left hcP hposc.le
    rwa [hexpand] at this
  rwa [hasq] at hfinal

end MyersStability

/-! ### Congruence forms, with the accumulated defect as an integral -/

namespace GeodesicCongruence

variable {m L : ℝ} (C : GeodesicCongruence m L)

/-- **Almost-rigidity for a geodesic congruence.**  If the expansion of a congruence
satisfying the energy condition is within `δ` of the model Riccati solution at an interior
affine parameter `t₀`, then the total focusing defect accumulated along `[0, t₀]`,
`∫₀^{t₀} (σ² + Ric(k,k))`, is at most `δ / (1 - δ U)²`.  Equality (`δ = 0`) recovers
`rigidity_of_saturated_penrose`. -/
theorem accumulated_defect_le_of_almost_saturated (hm : 0 < m)
    (hcont : Continuous fun t => C.shearSq t + C.ricci t)
    (htrap : C.expansion 0 < 0) {t0 delta : ℝ} (ht0 : 0 < t0) (ht0L : t0 < L)
    (hdelta : 0 ≤ delta)
    (hsat : riccatiSol m (C.expansion 0) t0 - delta ≤ C.expansion t0)
    (hsmall : delta * riccatiScale m (C.expansion 0) t0 < 1) :
    (∫ s in (0 : ℝ)..t0, (C.shearSq s + C.ricci s))
      ≤ delta / (1 - delta * riccatiScale m (C.expansion 0) t0) ^ 2 := by
  refine penrose_stability (θ := C.expansion) (θ' := C.expansionDot)
    (P := fun x => ∫ s in (0 : ℝ)..x, (C.shearSq s + C.ricci s))
    (p := fun x => C.shearSq x + C.ricci x) hm ht0 ht0L C.hasDeriv
    (fun x _ => (hcont.integral_hasStrictDerivAt 0 x).hasDerivAt) ?_ ?_ ?_ htrap hdelta hsat
    hsmall
  · intro x hx
    rw [C.raychaudhuri x hx]
    ring_nf
    linarith
  · intro x hx
    have h1 := C.shearSq_nonneg x hx
    have h2 := C.energy_condition x hx
    linarith
  · simp

/-- **Weighted almost-rigidity for a geodesic congruence, valid for every `δ ≥ 0`.**
Measured against the natural weight `1/θ²`, the accumulated focusing defect obeys
`∫₀^{t₀} (σ² + Ric)/θ² ≤ δ U²` with no smallness hypothesis on `δ`: the blow-up of the
constant in `accumulated_defect_le_of_almost_saturated` is entirely the price of dropping
the weight. -/
theorem weighted_defect_le_of_almost_saturated (hm : 0 < m)
    (hcont : Continuous fun t => (C.shearSq t + C.ricci t) / (C.expansion t) ^ 2)
    (htrap : C.expansion 0 < 0) {t0 delta : ℝ} (ht0 : 0 < t0) (ht0L : t0 < L)
    (hdelta : 0 ≤ delta)
    (hsat : riccatiSol m (C.expansion 0) t0 - delta ≤ C.expansion t0) :
    (∫ s in (0 : ℝ)..t0, (C.shearSq s + C.ricci s) / (C.expansion s) ^ 2)
      ≤ delta * (riccatiScale m (C.expansion 0) t0) ^ 2 := by
  refine penrose_weighted_stability (θ := C.expansion) (θ' := C.expansionDot)
    (W := fun x => ∫ s in (0 : ℝ)..x, (C.shearSq s + C.ricci s) / (C.expansion s) ^ 2)
    (p := fun x => C.shearSq x + C.ricci x) hm ht0 ht0L C.hasDeriv
    (fun x _ => (hcont.integral_hasStrictDerivAt 0 x).hasDerivAt) ?_ ?_ ?_ htrap hdelta hsat
  · intro x hx
    rw [C.raychaudhuri x hx]
    ring_nf
    linarith
  · intro x hx
    have h1 := C.shearSq_nonneg x hx
    have h2 := C.energy_condition x hx
    linarith
  · simp

/-- **Phase-deficit stability for a congruence.**  If in addition the Ricci focusing term
dominates `ε > 0` and the Prüfer phase at `t₀` has fallen by at most `δ` more than the
guaranteed amount, the accumulated shear-plus-excess-curvature defect is `O(δ)`. -/
theorem accumulated_defect_le_of_phase_deficit (hm : 0 < m) {eps : ℝ} (he : 0 < eps)
    (hcont : Continuous fun t => C.shearSq t + (C.ricci t - eps))
    (hstrict : ∀ t ∈ Ico (0 : ℝ) L, eps ≤ C.ricci t)
    {t0 delta : ℝ} (ht0 : 0 < t0) (ht0L : t0 < L)
    (hsat : Real.arctan (C.expansion 0 / Real.sqrt (m * eps))
        - Real.sqrt (m * eps) / m * t0 - delta
      ≤ Real.arctan (C.expansion t0 / Real.sqrt (m * eps))) :
    (∫ s in (0 : ℝ)..t0, (C.shearSq s + (C.ricci s - eps)))
      ≤ (m * eps + max ((C.expansion 0) ^ 2) ((C.expansion t0) ^ 2))
        / Real.sqrt (m * eps) * delta := by
  refine myers_phase_stability (θ := C.expansion) (θ' := C.expansionDot)
    (P := fun x => ∫ s in (0 : ℝ)..x, (C.shearSq s + (C.ricci s - eps)))
    (p := fun x => C.shearSq x + (C.ricci x - eps)) hm he ht0 ht0L C.hasDeriv
    (fun x _ => (hcont.integral_hasStrictDerivAt 0 x).hasDerivAt) ?_ ?_ ?_ hsat
  · intro x hx
    rw [C.raychaudhuri x hx]
    ring_nf
    linarith
  · intro x hx
    have h1 := C.shearSq_nonneg x hx
    have h2 := hstrict x hx
    linarith
  · simp

end GeodesicCongruence

/-! ### Non-vacuity: a subsolution with a strictly positive accumulated defect -/

section Witness

/-- **The stability theorem is not vacuous.**  The explicit subsolution
`θ(x) = -1 - 10 x` on `[0, 1/100)` with `m = 1` obeys the Raychaudhuri inequality with the
constant defect rate `p ≡ 1`, hence with the strictly positive accumulated defect
`P(x) = x`; at `t₀ = 1/200` it is within `δ = 1/20` of the model Riccati solution, and
`δ · U < 1`.  All hypotheses of `penrose_stability` are therefore satisfiable with a
non-zero defect, and the conclusion it produces (`1/200 ≤ (1/20)/(1 - δU)²`) is a true but
non-trivial constraint. -/
theorem penrose_stability_witness :
    ∃ (θ θ' P p : ℝ → ℝ) (L t0 delta : ℝ),
      0 < t0 ∧ t0 < L ∧
      (∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x) ∧
      (∀ x ∈ Ico (0 : ℝ) L, HasDerivAt P (p x) x) ∧
      (∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / 1 - p x) ∧
      (∀ x ∈ Ico (0 : ℝ) L, 0 ≤ p x) ∧
      P 0 = 0 ∧ θ 0 < 0 ∧ 0 ≤ delta ∧
      riccatiSol 1 (θ 0) t0 - delta ≤ θ t0 ∧
      delta * riccatiScale 1 (θ 0) t0 < 1 ∧
      0 < P t0 := by
  refine ⟨fun x => -1 - 10 * x, fun _ => -10, fun x => x, fun _ => 1,
    1 / 100, 1 / 200, 1 / 20, by norm_num, by norm_num, ?_, ?_, ?_, ?_, by norm_num,
    by norm_num, by norm_num, ?_, ?_, by norm_num⟩
  · intro x _
    simpa using ((hasDerivAt_id x).const_mul (10 : ℝ)).const_sub (-1 : ℝ)
  · intro x _
    simpa using hasDerivAt_id x
  · intro x hx
    have h1 : (0 : ℝ) ≤ x := hx.1
    have h2 : x < 1 / 100 := hx.2
    have : (-1 - 10 * x) ^ 2 ≤ 2 := by nlinarith
    simp only
    linarith
  · intro x _
    norm_num
  · show riccatiSol 1 (-1 - 10 * (0 : ℝ)) (1 / 200) - 1 / 20 ≤ -1 - 10 * (1 / 200 : ℝ)
    norm_num [riccatiSol]
  · show (1 / 20 : ℝ) * riccatiScale 1 (-1 - 10 * (0 : ℝ)) (1 / 200) < 1
    norm_num [riccatiScale]

end Witness

end Catalog.Physics.Spacetime