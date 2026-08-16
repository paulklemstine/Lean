import Physics.WrongTheories.TruncationHierarchy

/-!
# Boundaries of the meta-theorem, and a worked instance from the catalog

Adversarial companion to `Physics.WrongTheories.MetaTheorem` and
`Physics.WrongTheories.TruncationHierarchy`.  Both main theorems are stated
inside a *window of couplings*, and this file shows that the window is not an
artefact of the proof: outside it both conclusions genuinely fail.

* `WrongTheory.meta_needs_small_coupling` — at a coupling of size `1/2` an
  approximately correct theory can be beaten by a rival that is itself wrong;
  hence `meta_unreasonable_effectiveness` really needs its window.
* `WrongTheory.hierarchy_not_monotone_outside_window` — outside the window the
  *higher* truncation can be strictly worse than the lower one, so
  `higher_order_eventually_better` cannot be upgraded to a global statement.
* `WrongTheory.wilson_predict_eq` — the two-loop anomalous dimension of the
  catalog file `Physics.WilsonEpsilonExpansion` is literally a perturbative
  theory in the present sense, and `WrongTheory.wilson_beats_rival` applies the
  meta-theorem to it.

The explicit families used here are built from `binomialFamily`, whose wrongness
series is computed exactly.
-/

namespace WrongTheory

/-! ### An exactly computable two-term family -/

/-- The perturbative family over a single phenomenon whose only nonzero
corrections are `a₀ ε + a₁ ε²`, with truth `0`. -/
noncomputable def binomialFamily (a₀ a₁ : ℝ) : Perturbative Unit where
  truth := fun _ => 0
  coeff := fun n _ => if n = 0 then a₀ else if n = 1 then a₁ else 0
  bound := |a₀| + |a₁|
  ratio := 1
  bound_nonneg := by positivity
  ratio_nonneg := zero_le_one
  coeff_le := by
    intro n p
    rcases eq_or_ne n 0 with rfl | h0
    · simp only [one_pow, mul_one]
      exact le_add_of_nonneg_right (abs_nonneg a₁)
    · rcases eq_or_ne n 1 with rfl | h1
      · simp only [one_pow, mul_one, if_neg h0]
        exact le_add_of_nonneg_left (abs_nonneg a₀)
      · simp only [one_pow, mul_one, if_neg h0, if_neg h1, abs_zero]
        positivity

@[simp] lemma binomialFamily_truth (a₀ a₁ : ℝ) (p : Unit) :
    (binomialFamily a₀ a₁).truth p = 0 := rfl

/-- The wrongness series of `binomialFamily` sums to the quadratic
`a₀ ε + a₁ ε²`. -/
theorem wrongness_binomialFamily (a₀ a₁ ε : ℝ) (p : Unit) :
    wrongness (binomialFamily a₀ a₁) ε p = a₀ * ε + a₁ * ε ^ 2 := by
  have hzero : ∀ n ∉ ({0, 1} : Finset ℕ), wrongTerm (binomialFamily a₀ a₁) ε p n = 0 := by
    intro n hn
    have h0 : n ≠ 0 := by simpa using fun h => hn (by simp [h])
    have h1 : n ≠ 1 := by simpa using fun h => hn (by simp [h])
    simp [wrongTerm, binomialFamily, if_neg h0, if_neg h1]
  rw [wrongness, tsum_eq_sum hzero]
  simp [wrongTerm, binomialFamily]

/-- The prediction of `binomialFamily` at coupling `ε`. -/
theorem predict_binomialFamily (a₀ a₁ ε : ℝ) (p : Unit) :
    predict (binomialFamily a₀ a₁) ε p = a₀ * ε + a₁ * ε ^ 2 := by
  simp [predict, wrongness_binomialFamily]

/-! ### The coupling window is necessary -/

/-- **Sharpness of the meta-theorem.**  Take the approximately correct theory
`predict (binomialFamily 1 0) ε = ε` and the rival constant theory `1/4`, which
is itself wrong.  At the (not small) coupling `ε = 1/2` the rival wins, so the
conclusion of `meta_unreasonable_effectiveness` fails without its window on
`|ε|`. -/
theorem meta_needs_small_coupling :
    ∃ (T : Perturbative Unit) (C : Theory Unit) (ε : ℝ) (p : Unit),
      C p ≠ T.truth p ∧ ¬ Beats (predict T ε) C T.truth p := by
  refine ⟨binomialFamily 1 0, fun _ => 1 / 4, 1 / 2, (), by norm_num, ?_⟩
  rw [Beats, not_lt]
  have h1 : predErr (predict (binomialFamily 1 0) (1 / 2)) (binomialFamily 1 0).truth ()
      = 1 / 2 := by
    rw [predErr, predict_binomialFamily]
    norm_num
  have h2 : predErr (fun _ => 1 / 4) (binomialFamily 1 0).truth () = 1 / 4 := by
    rw [predErr]
    norm_num
  rw [h1, h2]
  norm_num

/-- **Sharpness of the wrongness hierarchy theorem.**  For the family
`ε ↦ ε - 3 ε²` at the coupling `ε = 1`, the first-order truncation is strictly
*worse* than the zeroth-order one, even though the zeroth correction is nonzero.
Monotone improvement along the tower is therefore a genuinely small-coupling
phenomenon. -/
theorem hierarchy_not_monotone_outside_window :
    ∃ (T : Perturbative Unit) (ε : ℝ) (p : Unit), T.coeff 0 p ≠ 0 ∧
      predErr (truncate T 0 ε) (predict T ε) p
        < predErr (truncate T 1 ε) (predict T ε) p := by
  refine ⟨binomialFamily 1 (-3), 1, (), by simp [binomialFamily], ?_⟩
  rw [truncation_err_eq, truncation_err_eq]
  have h0 : tail (binomialFamily 1 (-3)) 1 () 0 = -2 := by
    rw [tail, wrongness_binomialFamily]
    norm_num
  have h1 : tail (binomialFamily 1 (-3)) 1 () 1 = -3 := by
    rw [tail, wrongness_binomialFamily]
    simp [wrongTerm, binomialFamily]
  rw [h0, h1]
  norm_num

/-! ### A worked instance: Wilson's two-loop anomalous dimension -/

/-- The catalog's two-loop anomalous dimension at the Wilson–Fisher fixed point,
`η(ε) = ε²/54`, viewed as a perturbative theory over a single observable. -/
noncomputable def wilsonFamily : Perturbative Unit := binomialFamily 0 (1 / 54)

/-- The prediction of `wilsonFamily` is exactly the catalog's two-loop formula
`WilsonEpsilon.etaOfCoupling (WilsonEpsilon.wilsonFisher ε)`. -/
theorem wilson_predict_eq (ε : ℝ) (p : Unit) :
    predict wilsonFamily ε p
      = WilsonEpsilon.etaOfCoupling (WilsonEpsilon.wilsonFisher ε) := by
  rw [wilsonFamily, predict_binomialFamily, WilsonEpsilon.eta_at_wilsonFisher]
  ring

/-- **The meta-theorem applied to the ε-expansion.**  For every accuracy
threshold there is a window of `ε = 4 - d` in which the truncated (and hence
strictly wrong) two-loop theory outpredicts *every* rival whose error exceeds
the threshold. -/
theorem wilson_beats_rival {η : ℝ} (hη : 0 < η) :
    ∃ δ > 0, ∀ ε : ℝ, |ε| < δ → ∀ C : Theory Unit, ∀ p : Unit,
      η ≤ predErr C wilsonFamily.truth p →
        Beats (fun _ => WilsonEpsilon.etaOfCoupling (WilsonEpsilon.wilsonFisher ε))
          C wilsonFamily.truth p := by
  obtain ⟨δ, hδ, h⟩ := meta_unreasonable_effectiveness wilsonFamily hη
  refine ⟨δ, hδ, fun ε hε C p hp => ?_⟩
  have hfun : (fun _ : Unit => WilsonEpsilon.etaOfCoupling (WilsonEpsilon.wilsonFisher ε))
      = predict wilsonFamily ε := by
    funext _
    rw [wilson_predict_eq]
  rw [hfun]
  exact h ε hε C p hp

end WrongTheory