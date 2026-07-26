import Mathlib

/-!
# Finite-Temperature Tropical Approximation

This file formalizes the quantitative relationship between the log-sum-exp (softmax)
operation and the tropical max-plus semiring. The key insight is that temperature
(parameterized by inverse temperature `β > 0`) provides a mathematically controlled
deformation from smooth analytic structures to tropical ones, with explicit error bounds.

## Main results

* `softmax2_lower` / `softmax2_upper`: Two-sided bounds for binary log-sum-exp
* `softmax2_max_bounds`: Combined binary finite-temperature tropical approximation
* `finset_lse_lower_of_mem` / `finset_lse_upper_of_bound`: Abstract finset LSE bounds
* `finset_lse_max_bounds`: Combined finset log-sum-exp vs tropical maximum
* `tropical_matrix_soft_approx`: Pointwise approximation for tropical matrix action
* `softmax2_sharpness`: The upper bound is attained exactly when `x = y`

## References

The error bound `log(|s|)/β` is the exact entropic correction, corresponding to the
free energy = energy + entropy/β principle from statistical mechanics.
-/

noncomputable section

open Real Finset BigOperators

/-! ## Definitions -/

/-- Binary soft-max (log-sum-exp divided by β). -/
def softmax2 (β x y : ℝ) : ℝ :=
  Real.log (Real.exp (β * x) + Real.exp (β * y)) / β

/-- Finset log-sum-exp operator. -/
def finsetLSE {α : Type*} (β : ℝ) (s : Finset α) (f : α → ℝ) : ℝ :=
  Real.log (∑ i ∈ s, Real.exp (β * f i)) / β

/-! ## Helper lemmas -/

/-
Sum of exponentials is positive.
-/
theorem sum_exp_pos {α : Type*} (s : Finset α) (f : α → ℝ) (β : ℝ)
    (hs : s.Nonempty) :
    0 < ∑ i ∈ s, Real.exp (β * f i) := by
  exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hs

/-
Factoring out exp(β * m) from the sum.
-/
theorem sum_exp_factor {α : Type*}
    (s : Finset α) (f : α → ℝ) (β m : ℝ) :
    ∑ i ∈ s, Real.exp (β * f i) =
    Real.exp (β * m) * ∑ i ∈ s, Real.exp (β * (f i - m)) := by
  rw [ Finset.mul_sum _ _ _, Finset.sum_congr rfl ] ; intros ; rw [ ← Real.exp_add ] ; ring

/-
Upper bound on shifted exponential sum.
-/
theorem sum_exp_shift_le_card {α : Type*}
    (s : Finset α) (f : α → ℝ) (β : ℝ) (m : ℝ)
    (hβ : 0 ≤ β)
    (hm : ∀ i ∈ s, f i ≤ m) :
    ∑ i ∈ s, Real.exp (β * (f i - m)) ≤ s.card := by
  exact le_trans ( Finset.sum_le_sum fun i hi => Real.exp_le_one_iff.mpr ( mul_nonpos_of_nonneg_of_nonpos hβ ( sub_nonpos.mpr ( hm i hi ) ) ) ) ( by simp +decide )

/-! ## Theorem A: Binary finite-temperature tropical approximation -/

/-
Lower bound: `max(x,y) ≤ (1/β) log(exp(βx) + exp(βy))`.
-/
theorem softmax2_lower {β x y : ℝ} (hβ : 0 < β) :
    max x y ≤ Real.log (Real.exp (β * x) + Real.exp (β * y)) / β := by
  rw [ le_div_iff₀' hβ ];
  rw [ Real.le_log_iff_exp_le ( by positivity ) ];
  cases max_cases x y <;> simp +decide [ * ] <;> positivity;

/-
Upper bound: `(1/β) log(exp(βx) + exp(βy)) ≤ max(x,y) + log(2)/β`.
-/
theorem softmax2_upper {β x y : ℝ} (hβ : 0 < β) :
    Real.log (Real.exp (β * x) + Real.exp (β * y)) / β ≤
    max x y + Real.log 2 / β := by
  -- Use the property that exp(β*x) + exp(β*y) ≤ 2 * exp(β*max(x,y)).
  have h_exp_bound : Real.exp (β * x) + Real.exp (β * y) ≤ 2 * Real.exp (β * max x y) := by
    cases max_cases x y <;> [ linarith [ Real.exp_le_exp.mpr ( mul_le_mul_of_nonneg_left ( le_max_left x y ) hβ.le ), Real.exp_le_exp.mpr ( mul_le_mul_of_nonneg_left ( le_max_right x y ) hβ.le ) ] ; linarith [ Real.exp_le_exp.mpr ( mul_le_mul_of_nonneg_left ( le_max_left x y ) hβ.le ), Real.exp_le_exp.mpr ( mul_le_mul_of_nonneg_left ( le_max_right x y ) hβ.le ) ] ];
  rw [ add_div', div_le_div_iff_of_pos_right ] <;> try positivity;
  rw [ mul_comm, ← Real.log_exp ( max x y * β ) ];
  rw [ ← Real.log_mul ( by positivity ) ( by positivity ), mul_comm ] ; exact Real.log_le_log ( by positivity ) ( by ring_nf at *; linarith )

/-- **Theorem A**: Combined two-sided bound for binary soft-max. -/
theorem softmax2_max_bounds {β x y : ℝ} (hβ : 0 < β) :
    max x y ≤ Real.log (Real.exp (β * x) + Real.exp (β * y)) / β ∧
    Real.log (Real.exp (β * x) + Real.exp (β * y)) / β ≤
      max x y + Real.log 2 / β :=
  ⟨softmax2_lower hβ, softmax2_upper hβ⟩

/-
Algebraically convenient variant with `(1/β) *` form.
-/
theorem softmax2_max_bounds' {β x y : ℝ} (hβ : 0 < β) :
    max x y ≤ (1 / β) * Real.log (Real.exp (β * x) + Real.exp (β * y)) ∧
    (1 / β) * Real.log (Real.exp (β * x) + Real.exp (β * y)) ≤
      max x y + (1 / β) * Real.log 2 := by
  have := @softmax2_max_bounds β x y hβ; ring_nf at this ⊢; aesop;

/-! ## Sharpness -/

/-
When `x = y`, the softmax equals `x + log 2 / β`, showing the upper bound is sharp.
-/
theorem softmax2_sharpness {β a : ℝ} (hβ : 0 < β) :
    Real.log (Real.exp (β * a) + Real.exp (β * a)) / β = a + Real.log 2 / β := by
  rw [ show Real.exp ( β * a ) + Real.exp ( β * a ) = 2 * Real.exp ( β * a ) by ring, Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring_nf;
  grind +locals

/-! ## Theorem B: Finset log-sum-exp bounds -/

/-
Abstract lower bound: if `m` is attained in `s`, then `m ≤ LSE_β(f)`.
-/
theorem finset_lse_lower_of_mem {α : Type*}
    (s : Finset α) (f : α → ℝ) {β m : ℝ}
    (hβ : 0 < β)
    (hmem : ∃ i ∈ s, f i = m) :
    m ≤ finsetLSE β s f := by
  -- By definition of $finsetLSE$, we know that
  unfold finsetLSE;
  rw [ le_div_iff₀' hβ ];
  rw [ ← Real.log_exp ( β * m ), Real.log_le_log_iff ];
  · exact Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( β * f i ) ) hmem.choose_spec.1 |> le_trans ( by rw [ hmem.choose_spec.2 ] );
  · positivity;
  · exact Finset.sum_pos ( fun i hi => Real.exp_pos _ ) ⟨ hmem.choose, hmem.choose_spec.1 ⟩

/-
Abstract upper bound: if `m` dominates all values, then `LSE_β(f) ≤ m + log|s|/β`.
-/
theorem finset_lse_upper_of_bound {α : Type*}
    (s : Finset α) (f : α → ℝ) {β m : ℝ}
    (hβ : 0 < β)
    (hs : s.Nonempty)
    (hupper : ∀ i ∈ s, f i ≤ m) :
    finsetLSE β s f ≤ m + Real.log s.card / β := by
  -- Use sum_exp_factor with the given m: Σ exp(β*f(i)) = exp(β*m) * Σ exp(β*(f(i)-m)).
  have h_factor : ∑ i ∈ s, Real.exp (β * f i) = Real.exp (β * m) * ∑ i ∈ s, Real.exp (β * (f i - m)) := by
    rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_congr rfl fun _ _ => by rw [ ← Real.exp_add ] ; ring;
  -- By sum_exp_shift_le_card, the shifted sum ≤ |s|.
  have h_shift_le_card : ∑ i ∈ s, Real.exp (β * (f i - m)) ≤ s.card := by
    exact le_trans ( Finset.sum_le_sum fun i hi => Real.exp_le_one_iff.mpr <| mul_nonpos_of_nonneg_of_nonpos hβ.le <| sub_nonpos.mpr <| hupper i hi ) ( by simp +decide );
  -- Taking log: log(Σ...) ≤ log(exp(β*m) * |s|) = β*m + log|s|.
  have h_log : Real.log (∑ i ∈ s, Real.exp (β * f i)) ≤ β * m + Real.log s.card := by
    rw [ h_factor, Real.log_mul ( by positivity ) ( by exact ne_of_gt ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hs ) ), Real.log_exp ] ; linarith [ Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hs ) h_shift_le_card ] ;
  unfold finsetLSE; rw [ add_div', div_le_div_iff_of_pos_right ] <;> linarith;

/-
**Theorem B**: Finset log-sum-exp is sandwiched between the tropical maximum
    and the tropical maximum plus the entropic correction `log|s|/β`.
-/
theorem finset_lse_max_bounds {α : Type*} [LinearOrder α]
    (s : Finset α) (f : α → ℝ) {β : ℝ}
    (hβ : 0 < β) (hs : s.Nonempty) :
    s.sup' hs f ≤ finsetLSE β s f ∧
    finsetLSE β s f ≤ s.sup' hs f + Real.log s.card / β := by
  grind +suggestions

/-! ## Theorem C: Tropical matrix soft approximation -/

/-
**Theorem C**: Pointwise approximation bound for finite-temperature tropical
    matrix action. Uses `Fin (n+1)` to ensure nonemptiness.
-/
theorem tropical_matrix_soft_approx
    (n : ℕ)
    (A : Fin (n+1) → Fin (n+1) → ℝ) (x : Fin (n+1) → ℝ) {β : ℝ}
    (hβ : 0 < β) :
    ∀ i : Fin (n+1),
      (Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + x j))
        ≤ Real.log (∑ j : Fin (n+1), Real.exp (β * (A i j + x j))) / β ∧
      Real.log (∑ j : Fin (n+1), Real.exp (β * (A i j + x j))) / β
        ≤ (Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + x j))
          + Real.log (n+1 : ℝ) / β := by
  intro i;
  convert finset_lse_max_bounds ( Finset.univ : Finset ( Fin ( n + 1 ) ) ) ( fun j => A i j + x j ) hβ ?_ using 1;
  unfold finsetLSE; norm_num [ Finset.card_univ ] ;

/-! ## Connection to existing catalog theorems -/

/-- Consistency check: `tropical_mirror_theorem` is the degenerate case.
    When `x = y = a`, `max a a = a`, and softmax2 gives exactly `a + log 2 / β`. -/
theorem softmax2_mirror_consistency {β a : ℝ} (hβ : 0 < β) :
    max a a = a ∧
    Real.log (Real.exp (β * a) + Real.exp (β * a)) / β = a + Real.log 2 / β := by
  exact ⟨max_self a, softmax2_sharpness hβ⟩

end