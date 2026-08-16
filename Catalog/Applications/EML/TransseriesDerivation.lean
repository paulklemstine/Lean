import Applications.EML.TransseriesRingEmbedding

/-!
# The EML algebra is a differential ring, compatibly with real differentiation

The transmonomial `exp (d exp x) exp (a x) x ^ b (log x) ^ c` has logarithmic derivative

  `d exp x + a + b / x + c / (x log x)`,

which is again a finite combination of transmonomials.  Hence the EML algebra
`EMLTS.EMLAlg` carries a derivation `EMLTS.emlDeriv`, and this formal derivation computes
the honest derivative of the corresponding real function on `(1, ∞)`.

## Main results

* `EMLTS.emlDeriv_mul` : the Leibniz rule — `EMLAlg` is a differential ring.
* `EMLTS.hasDerivAt_EMLFun` : for `x > 1`, `EMLFun p` is differentiable at `x` with
  derivative `EMLFun (emlDeriv p) x`; the formal derivation is the analytic one.
* `EMLTS.emlDeriv_ne_zero_of_transmonomial` : nonconstant transmonomials have nonzero
  derivative, so the derivation is not degenerate.

Together with `TransseriesEMLExpansion` (nonzero EML functions are eventually nonzero and
of constant sign) this exhibits the germs at `+∞` of EML functions as an ordered
differential integral domain — the Hardy-field picture of transseries.
-/

noncomputable section

open Filter Asymptotics Real HahnSeries

open scoped Topology

namespace EMLTS

/-! ## The formal derivation -/

/-- The rank of `exp x`. -/
def rExp : Rank := rk 0 (-1) 0 0
/-- The rank of `1 / x`. -/
def rInvX : Rank := rk 0 0 1 0
/-- The rank of `1 / (x log x)`. -/
def rInvXLog : Rank := rk 0 0 1 1

/-- The logarithmic derivative of the transmonomial of rank `g`, as an element of the EML
algebra: `d exp x + a + b / x + c / (x log x)` (with the sign convention of `rankFun`). -/
def dlog (g : Rank) : EMLAlg :=
  AddMonoidAlgebra.single rExp (-(rd g)) + AddMonoidAlgebra.single (0 : Rank) (-(ra g))
    + AddMonoidAlgebra.single rInvX (-(rb g)) + AddMonoidAlgebra.single rInvXLog (-(rc g))

theorem dlog_add (g h : Rank) : dlog (g + h) = dlog g + dlog h := by
  simp only [dlog, rd_add, ra_add, rb_add, rc_add, neg_add, Finsupp.single_add]
  abel

/-- The formal derivation of the EML algebra. -/
def emlDeriv (p : EMLAlg) : EMLAlg := p.sum fun g c => AddMonoidAlgebra.single g c * dlog g

theorem emlDeriv_single (g : Rank) (c : ℝ) :
    emlDeriv (AddMonoidAlgebra.single g c) = AddMonoidAlgebra.single g c * dlog g := by
  classical
  rw [emlDeriv, Finsupp.sum_single_index]
  simp

@[simp] theorem emlDeriv_zero : emlDeriv 0 = 0 := by simp [emlDeriv]

theorem emlDeriv_add (p q : EMLAlg) : emlDeriv (p + q) = emlDeriv p + emlDeriv q := by
  refine Finsupp.sum_add_index' (fun g => by simp) (fun g c c' => ?_)
  rw [show (AddMonoidAlgebra.single g (c + c') : EMLAlg)
    = AddMonoidAlgebra.single g c + AddMonoidAlgebra.single g c' from Finsupp.single_add g c c',
    add_mul]

/-- `emlDeriv` as an additive homomorphism. -/
def emlDerivAddHom : EMLAlg →+ EMLAlg where
  toFun := emlDeriv
  map_zero' := emlDeriv_zero
  map_add' := emlDeriv_add

@[simp] theorem emlDerivAddHom_apply (p : EMLAlg) : emlDerivAddHom p = emlDeriv p := rfl

/-- **Leibniz rule**: the EML algebra is a differential ring. -/
theorem emlDeriv_mul (p q : EMLAlg) :
    emlDeriv (p * q) = emlDeriv p * q + p * emlDeriv q := by
  classical
  induction p using Finsupp.induction_linear with
  | zero => simp
  | add p₁ p₂ h₁ h₂ =>
      rw [add_mul, emlDeriv_add, h₁, h₂, emlDeriv_add, add_mul, add_mul]
      abel
  | single g c =>
      induction q using Finsupp.induction_linear with
      | zero => simp
      | add q₁ q₂ h₁ h₂ =>
          rw [mul_add, emlDeriv_add, h₁, h₂, emlDeriv_add, mul_add, mul_add]
          abel
      | single h e =>
          rw [AddMonoidAlgebra.single_mul_single, emlDeriv_single, emlDeriv_single,
            emlDeriv_single, dlog_add, mul_add]
          congr 1
          · rw [mul_right_comm, AddMonoidAlgebra.single_mul_single]
          · rw [← mul_assoc, AddMonoidAlgebra.single_mul_single]

/-! ## The formal derivation is the analytic derivative -/

private theorem hasDerivAt_rankLog {g : Rank} {x : ℝ} (hx : 1 < x) :
    HasDerivAt (rankLog g)
      (-(rd g * Real.exp x + ra g + rb g / x + rc g / (x * Real.log x))) x := by
  have hx0 : (0 : ℝ) < x := lt_trans zero_lt_one hx
  have hlog : 0 < Real.log x := Real.log_pos hx
  have h1 : HasDerivAt (fun y : ℝ => rd g * Real.exp y) (rd g * Real.exp x) x :=
    (Real.hasDerivAt_exp x).const_mul (rd g)
  have h2 : HasDerivAt (fun y : ℝ => ra g * y) (ra g) x := by
    simpa using (hasDerivAt_id x).const_mul (ra g)
  have hlogx : HasDerivAt Real.log x⁻¹ x := Real.hasDerivAt_log hx0.ne'
  have h3 : HasDerivAt (fun y : ℝ => rb g * Real.log y) (rb g / x) x := by
    simpa [div_eq_mul_inv] using hlogx.const_mul (rb g)
  have hloglog : HasDerivAt (fun y : ℝ => Real.log (Real.log y)) ((Real.log x)⁻¹ * x⁻¹) x :=
    (Real.hasDerivAt_log hlog.ne').comp x hlogx
  have h4 : HasDerivAt (fun y : ℝ => rc g * Real.log (Real.log y))
      (rc g / (x * Real.log x)) x := by
    have := hloglog.const_mul (rc g)
    refine this.congr_deriv ?_
    field_simp
  have := (((h1.add h2).add h3).add h4).neg
  exact this

/-- On `(1, ∞)` the formal derivation computes the derivative of the transmonomial. -/
theorem hasDerivAt_rankFun {g : Rank} {x : ℝ} (hx : 1 < x) :
    HasDerivAt (rankFun g)
      (-(rd g * Real.exp x + ra g + rb g / x + rc g / (x * Real.log x)) * rankFun g x) x := by
  have h := (hasDerivAt_rankLog (g := g) hx).exp
  rw [mul_comm]
  exact h

theorem EMLFun_dlog {g : Rank} {x : ℝ} (hx : 1 < x) :
    EMLFun (dlog g) x = -(rd g * Real.exp x + ra g + rb g / x + rc g / (x * Real.log x)) := by
  have hx0 : (0 : ℝ) < x := lt_trans zero_lt_one hx
  have hlog : 0 < Real.log x := Real.log_pos hx
  have hexp : rankFun rExp x = Real.exp x := by
    simp [rankFun, rankLog, rExp]
  have hinv : rankFun rInvX x = x⁻¹ := by
    rw [rankFun, rankLog]
    simp only [rInvX, rd_rk, ra_rk, rb_rk, rc_rk]
    rw [show -(0 * Real.exp x + 0 * x + 1 * Real.log x + 0 * Real.log (Real.log x))
      = -Real.log x by ring, Real.exp_neg, Real.exp_log hx0]
  have hinvlog : rankFun rInvXLog x = (x * Real.log x)⁻¹ := by
    rw [rankFun, rankLog]
    simp only [rInvXLog, rd_rk, ra_rk, rb_rk, rc_rk]
    rw [show -(0 * Real.exp x + 0 * x + 1 * Real.log x + 1 * Real.log (Real.log x))
      = -(Real.log x + Real.log (Real.log x)) by ring, Real.exp_neg, Real.exp_add,
      Real.exp_log hx0, Real.exp_log hlog]
  rw [dlog]
  rw [EMLFun_add, EMLFun_add, EMLFun_add, EMLFun_single, EMLFun_single, EMLFun_single,
    EMLFun_single, hexp, hinv, hinvlog]
  simp only [rankFun_zero, mul_one]
  field_simp
  ring

/-- **The formal derivation computes the analytic derivative.**  For `x > 1`, the EML
function of `p` is differentiable at `x` with derivative the EML function of
`emlDeriv p`. -/
theorem hasDerivAt_EMLFun (p : EMLAlg) {x : ℝ} (hx : 1 < x) :
    HasDerivAt (EMLFun p) (EMLFun (emlDeriv p) x) x := by
  classical
  induction p using Finsupp.induction_linear with
  | zero =>
      simpa using (hasDerivAt_const x (0 : ℝ))
  | add p₁ p₂ h₁ h₂ =>
      have hfun : EMLFun (p₁ + p₂) = fun y => EMLFun p₁ y + EMLFun p₂ y :=
        funext fun y => EMLFun_add p₁ p₂ y
      rw [hfun, emlDeriv_add, EMLFun_add]
      exact h₁.add h₂
  | single g c =>
      have hmono : HasDerivAt (fun y => c * rankFun g y)
          (c * (-(rd g * Real.exp x + ra g + rb g / x + rc g / (x * Real.log x))
            * rankFun g x)) x := (hasDerivAt_rankFun hx).const_mul c
      have hval : EMLFun (emlDeriv (AddMonoidAlgebra.single g c)) x
          = c * (-(rd g * Real.exp x + ra g + rb g / x + rc g / (x * Real.log x))
            * rankFun g x) := by
        rw [emlDeriv_single, EMLFun_mul, EMLFun_single, EMLFun_dlog hx]
        ring
      have hfun : EMLFun (AddMonoidAlgebra.single g c) = fun y => c * rankFun g y :=
        funext fun y => EMLFun_single g c y
      rw [hfun, hval]
      exact hmono

/-! ## The derivation on the named transmonomials -/

/-- `exp' = exp`. -/
theorem emlDeriv_exp (c : ℝ) :
    emlDeriv (AddMonoidAlgebra.single rExp c) = AddMonoidAlgebra.single rExp c := by
  have hd : dlog rExp = 1 := by
    simp [dlog, rExp, AddMonoidAlgebra.one_def]
  rw [emlDeriv_single, hd, mul_one]

/-- `x' = 1`. -/
theorem emlDeriv_id :
    emlDeriv (AddMonoidAlgebra.single (rk 0 0 (-1) 0) (1 : ℝ)) = 1 := by
  have hd : dlog (rk 0 0 (-1) 0) = AddMonoidAlgebra.single rInvX (1 : ℝ) := by
    simp [dlog, rInvX]
  rw [emlDeriv_single, hd, AddMonoidAlgebra.single_mul_single]
  rw [show rk 0 0 (-1) 0 + rInvX = (0 : Rank) by
    simp only [rInvX, rk_add]
    exact rk_congr (by ring) (by ring) (by ring) (by ring)]
  simp [AddMonoidAlgebra.one_def]

/-- `(log x)' = 1 / x`. -/
theorem emlDeriv_log :
    emlDeriv (AddMonoidAlgebra.single (rk 0 0 0 (-1)) (1 : ℝ))
      = AddMonoidAlgebra.single rInvX (1 : ℝ) := by
  have hd : dlog (rk 0 0 0 (-1)) = AddMonoidAlgebra.single rInvXLog (1 : ℝ) := by
    simp [dlog, rInvXLog]
  rw [emlDeriv_single, hd, AddMonoidAlgebra.single_mul_single]
  rw [show rk 0 0 0 (-1) + rInvXLog = rInvX by
    simp only [rInvXLog, rInvX, rk_add]
    exact rk_congr (by ring) (by ring) (by ring) (by ring)]
  norm_num

/-- `(exp (exp x))' = exp (exp x) · exp x`. -/
theorem emlDeriv_expexp :
    emlDeriv (AddMonoidAlgebra.single (rk (-1) 0 0 0) (1 : ℝ))
      = AddMonoidAlgebra.single (rk (-1) 0 0 0) (1 : ℝ) * AddMonoidAlgebra.single rExp (1 : ℝ) := by
  have hd : dlog (rk (-1) 0 0 0) = AddMonoidAlgebra.single rExp (1 : ℝ) := by
    simp [dlog, rExp]
  rw [emlDeriv_single, hd]

/-- The derivation is nondegenerate. -/
theorem emlDeriv_ne_zero_exp : emlDeriv (AddMonoidAlgebra.single rExp (1 : ℝ)) ≠ 0 := by
  rw [emlDeriv_exp]
  simp

end EMLTS