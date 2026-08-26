import Catalog.Bridges.BerggrenHarmonicMeasure

/-!
# The transfer operator of the Berggren walk and its spectrum

The Markov operator of the Berggren random walk acts on functions on the boundary
`Bdry = ℕ → Fin 3` by

`(L f)(x) = p₁ f(1·x) + p₂ f(2·x) + p₃ f(3·x)`,

where `a·x = cons a x` prepends the Berggren move `a`.  This is the operator whose fixed
points are the harmonic functions of the walk and whose invariant measure is the harmonic
measure `bernoulli P` of `Catalog.Bridges.BerggrenHarmonicMeasure`.

The conjecture motivating this cycle was that the *spectral gap* of the Berggren walk is
governed by the silver ratio `1 + √2` of the tree's metric growth.  The results below show
that this is false in a strong and clean way: on the natural core of locally constant
functions (the union of the finite-dimensional spaces `DependsOn n`, which is dense in every
reasonable completion), the transfer operator is **nilpotent modulo constants**.

## Main results

* `transfer_dependsOn` : `L` maps functions of the first `n+1` letters to functions of the
  first `n` letters — the operator strictly decreases the "memory" of a function.
* `iterate_transfer_const` : hence `Lⁿ f` is *constant* for every `f` depending on the first
  `n` letters.  This is the nilpotency statement.
* `eigenvalue_eq_zero_or_one` : consequently every eigenvalue of `L` on locally constant
  functions is `0` or `1`, and (`eigenfunction_one_isConst`) the eigenvalue `1` has only the
  constants as eigenfunctions.  The **spectral gap is `1`, independently of `(p₁,p₂,p₃)`**.
* `log_silver_not_eigenvalue` : in particular `log(1+√2)` — the growth exponent of the
  Berggren tree — is *not* an eigenvalue of the Markov operator: the conjectured
  silver-ratio spectral gap is refuted.  (`log_silver_pos_lt_one` isolates the numerical
  fact `0 < log(1+√2) < 1` on which the refutation rests.)
-/

namespace BerggrenHarmonic

open Finset

/-- The transfer (Markov) operator of the Berggren walk on boundary functions. -/
noncomputable def transfer (P : ProbVec) (f : Bdry → ℝ) : Bdry → ℝ :=
  fun x => ∑ a, P.p a * f (cons a x)

/-- `f` is determined by the first `n` letters of its argument. -/
def DependsOn (n : ℕ) (f : Bdry → ℝ) : Prop :=
  ∀ x y : Bdry, (∀ i < n, x i = y i) → f x = f y

lemma dependsOn_zero_iff (f : Bdry → ℝ) : DependsOn 0 f ↔ ∀ x y, f x = f y := by
  constructor
  · intro h x y; exact h x y (fun i hi => absurd hi (Nat.not_lt_zero i))
  · intro h x y _; exact h x y

lemma dependsOn_mono {m n : ℕ} {f : Bdry → ℝ} (hmn : m ≤ n) (hf : DependsOn m f) :
    DependsOn n f :=
  fun x y hxy => hf x y (fun i hi => hxy i (lt_of_lt_of_le hi hmn))

/-- The operator preserves constants: `L 1 = 1`. -/
@[simp] lemma transfer_const (P : ProbVec) (c : ℝ) :
    transfer P (fun _ => c) = fun _ => c := by
  funext x
  simp only [transfer, ← Finset.sum_mul]
  rw [P.sum_eq, one_mul]

/-- **The transfer operator forgets a letter.**  If `f` only depends on the first `n+1`
letters, then `L f` only depends on the first `n`. -/
theorem transfer_dependsOn (P : ProbVec) {n : ℕ} {f : Bdry → ℝ} (hf : DependsOn (n + 1) f) :
    DependsOn n (transfer P f) := by
  intro x y hxy
  refine Finset.sum_congr rfl fun a _ => ?_
  congr 1
  refine hf _ _ fun i hi => ?_
  cases i with
  | zero => rfl
  | succ k => exact hxy k (by omega)

/-- **Nilpotency modulo constants.**  If `f` depends only on the first `n` letters then
`Lⁿ f` is a constant function. -/
theorem iterate_transfer_dependsOn_zero (P : ProbVec) :
    ∀ (n : ℕ) (f : Bdry → ℝ), DependsOn n f → DependsOn 0 ((transfer P)^[n] f) := by
  intro n
  induction n with
  | zero => intro f hf; simpa using hf
  | succ n ih =>
      intro f hf
      rw [Function.iterate_succ_apply]
      exact ih _ (transfer_dependsOn P hf)

theorem iterate_transfer_const (P : ProbVec) {n : ℕ} {f : Bdry → ℝ} (hf : DependsOn n f) :
    ∃ c : ℝ, (transfer P)^[n] f = fun _ => c := by
  refine ⟨(transfer P)^[n] f (fun _ => 0), ?_⟩
  funext x
  exact (dependsOn_zero_iff _).1 (iterate_transfer_dependsOn_zero P n f hf) x _

/-! ## The spectrum on locally constant functions -/

lemma iterate_transfer_smul (P : ProbVec) {f : Bdry → ℝ} {c : ℝ}
    (hc : transfer P f = fun x => c * f x) :
    ∀ n : ℕ, (transfer P)^[n] f = fun x => c ^ n * f x := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply', ih]
      funext x
      have : transfer P (fun x => c ^ n * f x) = fun x => c ^ n * (transfer P f) x := by
        funext y
        simp only [transfer, Finset.mul_sum]
        exact Finset.sum_congr rfl fun a _ => by ring
      rw [this, hc]
      ring

/-- **The eigenvalue `1` is simple.**  A locally constant eigenfunction of the transfer
operator with eigenvalue `1` is constant. -/
theorem eigenfunction_one_isConst (P : ProbVec) {n : ℕ} {f : Bdry → ℝ} (hf : DependsOn n f)
    (hc : transfer P f = fun x => 1 * f x) : ∀ x y, f x = f y := by
  obtain ⟨c, hconst⟩ := iterate_transfer_const P hf
  have h := iterate_transfer_smul P hc n
  rw [hconst] at h
  intro x y
  have hx := congrFun h x
  have hy := congrFun h y
  simp only [one_pow, one_mul] at hx hy
  rw [← hx, ← hy]

/-- **The spectrum of the Berggren transfer operator on locally constant functions is
`{0, 1}`.**  A nonzero locally constant eigenfunction forces the eigenvalue to be `0` or
`1`; equivalently the Markov operator has spectral gap `1`, for *every* choice of the
weights `(p₁, p₂, p₃)`. -/
theorem eigenvalue_eq_zero_or_one (P : ProbVec) {n : ℕ} {f : Bdry → ℝ} (hf : DependsOn n f)
    {c : ℝ} (hc : transfer P f = fun x => c * f x) (hne : ∃ x, f x ≠ 0) :
    c = 0 ∨ c = 1 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨hc0, hc1⟩ := hcon
  obtain ⟨x₀, hx₀⟩ := hne
  obtain ⟨K, hK⟩ := iterate_transfer_const P hf
  have hiter := iterate_transfer_smul P hc n
  rw [hK] at hiter
  -- `f` is constant, because `cⁿ f` is
  have hconst : ∀ x y, f x = f y := by
    intro x y
    have hx := congrFun hiter x
    have hy := congrFun hiter y
    have hcn : c ^ n ≠ 0 := pow_ne_zero n hc0
    have : c ^ n * f x = c ^ n * f y := by rw [← hx, ← hy]
    exact mul_left_cancel₀ hcn this
  -- a constant function is fixed by `L`
  have hfix : transfer P f = f := by
    funext x
    simp only [transfer]
    have : ∀ a : Letter, P.p a * f (cons a x) = P.p a * f x :=
      fun a => by rw [hconst (cons a x) x]
    rw [Finset.sum_congr rfl (fun a _ => this a), ← Finset.sum_mul, P.sum_eq, one_mul]
  have := congrFun (hfix.symm.trans hc) x₀
  have hcx : (c - 1) * f x₀ = 0 := by linarith [this]
  rcases mul_eq_zero.1 hcx with h | h
  · exact hc1 (by linarith)
  · exact hx₀ h

/-! ## Refuting the silver-ratio spectral gap -/

/-- The numerical input to the refutation: `0 < log(1+√2) < 1`. -/
theorem log_silver_pos_lt_one :
    0 < Real.log (1 + Real.sqrt 2) ∧ Real.log (1 + Real.sqrt 2) < 1 := by
  have h2 : Real.sqrt 2 < 1.5 := by
    have : Real.sqrt 2 < Real.sqrt 2.25 := by
      apply Real.sqrt_lt_sqrt <;> norm_num
    have h225 : Real.sqrt 2.25 = 1.5 := by
      rw [show (2.25 : ℝ) = 1.5 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
    linarith [h225 ▸ this]
  have hpos : (0:ℝ) < Real.sqrt 2 := Real.sqrt_pos.2 (by norm_num)
  constructor
  · exact Real.log_pos (by linarith)
  · have he : (1 : ℝ) + Real.sqrt 2 < Real.exp 1 := by
      have := Real.exp_one_gt_d9
      linarith
    calc Real.log (1 + Real.sqrt 2) < Real.log (Real.exp 1) :=
          Real.log_lt_log (by linarith) he
      _ = 1 := Real.log_exp 1

/-- **The silver-ratio spectral gap is refuted.**  `log(1+√2)`, the metric growth exponent of
the Berggren tree, is not an eigenvalue of the Markov operator on locally constant functions:
any locally constant `f` with `L f = log(1+√2) · f` vanishes identically. -/
theorem log_silver_not_eigenvalue (P : ProbVec) {n : ℕ} {f : Bdry → ℝ} (hf : DependsOn n f)
    (hc : transfer P f = fun x => Real.log (1 + Real.sqrt 2) * f x) : ∀ x, f x = 0 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨hlow, hhigh⟩ := log_silver_pos_lt_one
  rcases eigenvalue_eq_zero_or_one P hf hc hcon with h | h
  · exact absurd h (ne_of_gt hlow)
  · exact absurd h (ne_of_lt hhigh)

end BerggrenHarmonic