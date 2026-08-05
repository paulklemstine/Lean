import Mathlib

/-!
# EML Differential Equations

Exponential–logarithmic (**EML**) functions are the real functions built from the
identity, real constants, `+`, `*`, `⁻¹`, `Real.exp` and `Real.log`.  This file
develops the differential calculus of that class and uses it to analyse the
second-order linear equation

  `y'' = r · y`,   `r` a polynomial,

with the **Airy equation** `y'' = x · y` as the guiding example.

## Contents

* `EMLExpr`, `EMLExpr.eval`, `EMLExpr.D`, `EMLExpr.Regular` — a syntax for EML
  functions, its interpretation, its *symbolic* derivative and the (pointwise)
  regularity predicate saying that all inversions and logarithms occurring in an
  expression have nonzero argument at a point.
* `EMLExpr.hasDerivAt_eval` — **correctness of symbolic differentiation**: at a
  regular point the analytic derivative of `eval e` is `eval (D e)`.  In
  particular the class of EML functions is closed under differentiation
  (`EMLExpr.Regular.D`).
* `EMLExpr.exp_solves_firstOrder` and `EMLExpr.firstOrder_unique` — the complete
  solution theory of the first-order linear EML equation `y' = c · y`: the
  exponential of an antiderivative solves it, and every solution is a constant
  multiple of that one.
* `riccati_no_rational_solution` — the **algebraic Kovacic obstruction**: if
  `r` is a polynomial of odd degree then the Riccati equation `u' + u² = r` has
  no solution `u = P/Q` in the field of rational functions.
* `airy_no_rational_logDeriv` — the analytic form: no nowhere-vanishing solution
  of `y'' = x·y` has a rational logarithmic derivative.
* `airy_no_eml_exponential_solution` — consequently the Airy equation has no
  solution of the EML shape `y = exp ∘ F` with `F'` rational; this is exactly
  the failure of the first Kovacic case for Airy's equation.
* `riccati_odd_degree_sharp`, `exp_half_sq_solves` — sharpness: for the
  even-degree coefficient `r = x² + 1` the Riccati equation *does* have the
  rational solution `u = x`, and `y = exp (x²/2)` is a genuine EML solution of
  `y'' = (x²+1) y`.
-/

namespace EMLDiffEq

open Polynomial

/-! ## 1. Syntax and calculus of EML functions -/

/-- Syntax for exponential–logarithmic expressions in one real variable. -/
inductive EMLExpr : Type
  | X : EMLExpr
  | const : ℝ → EMLExpr
  | add : EMLExpr → EMLExpr → EMLExpr
  | mul : EMLExpr → EMLExpr → EMLExpr
  | inv : EMLExpr → EMLExpr
  | exp : EMLExpr → EMLExpr
  | log : EMLExpr → EMLExpr

namespace EMLExpr

/-- Interpretation of an EML expression as a real function (junk values `0⁻¹ = 0`
and `Real.log 0 = 0` are used outside the regular locus). -/
noncomputable def eval : EMLExpr → ℝ → ℝ
  | X, x => x
  | const c, _ => c
  | add a b, x => eval a x + eval b x
  | mul a b, x => eval a x * eval b x
  | inv a, x => (eval a x)⁻¹
  | exp a, x => Real.exp (eval a x)
  | log a, x => Real.log (eval a x)

/-- Symbolic derivative of an EML expression.  The point of the construction is
that the class of EML expressions is *closed* under it. -/
def D : EMLExpr → EMLExpr
  | X => const 1
  | const _ => const 0
  | add a b => add (D a) (D b)
  | mul a b => add (mul (D a) b) (mul a (D b))
  | inv a => mul (const (-1)) (mul (D a) (mul (inv a) (inv a)))
  | exp a => mul (D a) (exp a)
  | log a => mul (D a) (inv a)

/-- `Regular e x` says that every inversion and every logarithm occurring in `e`
has nonzero argument at `x`; this is the precise domain condition under which
symbolic differentiation is analytically valid. -/
def Regular : EMLExpr → ℝ → Prop
  | X, _ => True
  | const _, _ => True
  | add a b, x => Regular a x ∧ Regular b x
  | mul a b, x => Regular a x ∧ Regular b x
  | inv a, x => Regular a x ∧ eval a x ≠ 0
  | exp a, x => Regular a x
  | log a, x => Regular a x ∧ eval a x ≠ 0

@[simp] theorem eval_inv_apply (a : EMLExpr) : eval (inv a) = fun t => (eval a t)⁻¹ := rfl

/-- **Correctness of symbolic differentiation.**  At a regular point the function
`eval e` is differentiable with derivative `eval (D e)`. -/
theorem hasDerivAt_eval : ∀ (e : EMLExpr) (x : ℝ), Regular e x →
    HasDerivAt (eval e) (eval (D e) x) x := by
  intro e
  induction e with
  | X => intro x _; simpa [eval, D] using (hasDerivAt_id x)
  | const c => intro x _; simpa [eval, D] using (hasDerivAt_const x c)
  | add a b iha ihb =>
      intro x hx
      exact (iha x hx.1).add (ihb x hx.2)
  | mul a b iha ihb =>
      intro x hx
      simpa [eval, D, mul_comm, mul_left_comm, mul_assoc] using (iha x hx.1).mul (ihb x hx.2)
  | inv a iha =>
      intro x hx
      have h := (iha x hx.1).inv hx.2
      have he : eval (D (inv a)) x = -eval (D a) x / eval a x ^ 2 := by
        simp only [eval, D]; ring
      rw [eval_inv_apply, he]
      exact h
  | exp a iha =>
      intro x hx
      simpa [eval, D, mul_comm] using (iha x hx).exp
  | log a iha =>
      intro x hx
      have h := (iha x hx.1).log hx.2
      simpa [eval, D, div_eq_mul_inv] using h

/-- The class of EML functions is closed under differentiation, *together with*
its regularity locus: a regular point of `e` is a regular point of `D e`. -/
theorem Regular.D : ∀ (e : EMLExpr) (x : ℝ), Regular e x → Regular (EMLExpr.D e) x := by
  intro e
  induction e with
  | X => intro x _; trivial
  | const c => intro x _; trivial
  | add a b iha ihb => intro x hx; exact ⟨iha x hx.1, ihb x hx.2⟩
  | mul a b iha ihb =>
      intro x hx
      exact ⟨⟨iha x hx.1, hx.2⟩, ⟨hx.1, ihb x hx.2⟩⟩
  | inv a iha =>
      intro x hx
      exact ⟨trivial, iha x hx.1, ⟨hx.1, hx.2⟩, ⟨hx.1, hx.2⟩⟩
  | exp a iha => intro x hx; exact ⟨iha x hx, hx⟩
  | log a iha => intro x hx; exact ⟨iha x hx.1, hx.1, hx.2⟩

/-! ## 2. First-order linear EML equations -/

/-- **Solution of the first-order linear equation.**  If `F` is an EML expression
that is regular at `x`, then `y = exp ∘ F` satisfies `y' = F' · y` there.  Thus
every EML coefficient possessing an EML antiderivative yields a closed-form,
nowhere-vanishing EML solution. -/
theorem exp_solves_firstOrder (F : EMLExpr) (x : ℝ) (hF : Regular F x) :
    HasDerivAt (fun t => Real.exp (eval F t))
      (eval (D F) x * Real.exp (eval F x)) x := by
  have h := hasDerivAt_eval (EMLExpr.exp F) x hF
  simpa [eval, D] using h

/-- **Uniqueness up to a constant.**  If `F` is everywhere regular and `y` is any
solution of `y' = F' · y` on `ℝ`, then `y = K · exp ∘ F` for a constant `K`. -/
theorem firstOrder_unique (F : EMLExpr) (hF : ∀ x, Regular F x)
    (y : ℝ → ℝ) (hy : ∀ x, HasDerivAt y (eval (D F) x * y x) x) :
    ∃ K : ℝ, ∀ x, y x = K * Real.exp (eval F x) := by
  set g : ℝ → ℝ := fun t => y t * Real.exp (-(eval F t)) with hg
  have hgd : ∀ x, HasDerivAt g 0 x := by
    intro x
    have h1 : HasDerivAt (fun t => Real.exp (-(eval F t)))
        (-(eval (D F) x) * Real.exp (-(eval F x))) x := by
      have := ((hasDerivAt_eval F x (hF x)).neg).exp
      simpa [mul_comm] using this
    show HasDerivAt (fun t => y t * Real.exp (-(eval F t))) 0 x
    convert (hy x).mul h1 using 1
    ring
  have hconst : ∀ x, g x = g 0 :=
    fun x => is_const_of_deriv_eq_zero (fun t => (hgd t).differentiableAt)
      (fun t => (hgd t).deriv) x 0
  refine ⟨g 0, fun x => ?_⟩
  have hx := hconst x
  have h2 : y x * Real.exp (-(eval F x)) * Real.exp (eval F x) = g 0 * Real.exp (eval F x) := by
    rw [← hx]
  rw [mul_assoc, ← Real.exp_add] at h2
  simpa using h2

end EMLExpr

/-! ## 3. The algebraic Kovacic obstruction -/

section Algebraic

variable {K : Type*} [Field K]

/-- The numerator `P'Q - PQ'` of the derivative of `P/Q` has degree strictly less
than `deg P + deg Q`. -/
theorem degree_wronskianNum_lt (P Q : K[X]) (hP : P ≠ 0) (hQ : Q ≠ 0) :
    (derivative P * Q - P * derivative Q).degree < P.degree + Q.degree := by
  have h1 : (derivative P * Q).degree < P.degree + Q.degree := by
    have := Polynomial.degree_derivative_lt hP
    calc (derivative P * Q).degree ≤ (derivative P).degree + Q.degree :=
          Polynomial.degree_mul_le _ _
      _ < P.degree + Q.degree := by
          exact WithBot.add_lt_add_right (by simpa using hQ) this
  have h2 : (P * derivative Q).degree < P.degree + Q.degree := by
    have := Polynomial.degree_derivative_lt hQ
    calc (P * derivative Q).degree ≤ P.degree + (derivative Q).degree :=
          Polynomial.degree_mul_le _ _
      _ < P.degree + Q.degree := by
          exact WithBot.add_lt_add_left (by simpa using hP) this
  exact lt_of_le_of_lt (Polynomial.degree_sub_le _ _) (max_lt h1 h2)

/-- A polynomial of odd natural degree is nonzero. -/
theorem ne_zero_of_odd_natDegree {r : K[X]} (hr : Odd r.natDegree) : r ≠ 0 := by
  rintro rfl
  simp only [Polynomial.natDegree_zero] at hr
  obtain ⟨k, hk⟩ := hr
  omega

/-- Branch `deg Q ≤ deg P` of `riccati_no_rational_solution`: here the term `P²`
dominates, so the left-hand side has the even degree `2 · deg P`, while the
right-hand side has odd degree. -/
theorem riccati_ne_of_degree_le (r P Q : K[X]) (hr : Odd r.natDegree) (hP : P ≠ 0) (hQ : Q ≠ 0)
    (hle : Q.natDegree ≤ P.natDegree) :
    derivative P * Q - P * derivative Q + P ^ 2 ≠ r * Q ^ 2 := by
  intro heq
  have hr0 : r ≠ 0 := ne_zero_of_odd_natDegree hr
  have hW := degree_wronskianNum_lt P Q hP hQ
  have hlt' : (derivative P * Q - P * derivative Q).degree < (P ^ 2).degree := by
    refine lt_of_lt_of_le hW ?_
    rw [sq, Polynomial.degree_mul, Polynomial.degree_eq_natDegree hP,
      Polynomial.degree_eq_natDegree hQ]
    exact_mod_cast Nat.add_le_add_left hle P.natDegree
  have hdeg : (derivative P * Q - P * derivative Q + P ^ 2).degree = (P ^ 2).degree :=
    Polynomial.degree_add_eq_right_of_degree_lt hlt'
  rw [heq] at hdeg
  have h1 : (r * Q ^ 2).natDegree = (P ^ 2).natDegree :=
    Polynomial.natDegree_eq_of_degree_eq hdeg
  rw [Polynomial.natDegree_mul hr0 (pow_ne_zero 2 hQ), Polynomial.natDegree_pow,
    Polynomial.natDegree_pow] at h1
  obtain ⟨k, hk⟩ := hr
  omega

/-- Branch `deg P < deg Q` of `riccati_no_rational_solution`: here the whole
left-hand side has degree `< 2 · deg Q`, which is smaller than the degree of the
right-hand side. -/
theorem riccati_ne_of_degree_lt (r P Q : K[X]) (hr : Odd r.natDegree) (hP : P ≠ 0) (hQ : Q ≠ 0)
    (hlt : P.natDegree < Q.natDegree) :
    derivative P * Q - P * derivative Q + P ^ 2 ≠ r * Q ^ 2 := by
  intro heq
  have hr0 : r ≠ 0 := ne_zero_of_odd_natDegree hr
  have hr1 : 1 ≤ r.natDegree := by obtain ⟨k, hk⟩ := hr; omega
  have hRHS : (r * Q ^ 2).degree = ((r.natDegree + 2 * Q.natDegree : ℕ) : WithBot ℕ) := by
    rw [Polynomial.degree_eq_natDegree (mul_ne_zero hr0 (pow_ne_zero 2 hQ)),
      Polynomial.natDegree_mul hr0 (pow_ne_zero 2 hQ), Polynomial.natDegree_pow]
  have hPQ : P.degree + Q.degree = ((P.natDegree + Q.natDegree : ℕ) : WithBot ℕ) := by
    rw [Polynomial.degree_eq_natDegree hP, Polynomial.degree_eq_natDegree hQ]
    push_cast
    ring
  have hP2 : (P ^ 2).degree = ((2 * P.natDegree : ℕ) : WithBot ℕ) := by
    rw [Polynomial.degree_eq_natDegree (pow_ne_zero 2 hP), Polynomial.natDegree_pow]
  have hW := degree_wronskianNum_lt P Q hP hQ
  rw [hPQ] at hW
  have hd1 : (derivative P * Q - P * derivative Q).degree < (r * Q ^ 2).degree := by
    refine lt_of_lt_of_le hW ?_
    rw [hRHS]
    exact_mod_cast (by omega : P.natDegree + Q.natDegree ≤ r.natDegree + 2 * Q.natDegree)
  have hd2 : (P ^ 2).degree < (r * Q ^ 2).degree := by
    rw [hRHS, hP2]
    exact_mod_cast (by omega : 2 * P.natDegree < r.natDegree + 2 * Q.natDegree)
  have hfin : (derivative P * Q - P * derivative Q + P ^ 2).degree < (r * Q ^ 2).degree :=
    lt_of_le_of_lt (Polynomial.degree_add_le _ _) (max_lt hd1 hd2)
  rw [heq] at hfin
  exact lt_irrefl _ hfin

/-- **Kovacic's first case fails for odd-degree coefficients.**

If `r` is a polynomial of odd degree then the Riccati equation `u' + u² = r`
has no solution in the rational function field: there are no polynomials `P`,
`Q` with `Q ≠ 0` satisfying the cleared-denominator identity

  `P'·Q - P·Q' + P² = r·Q²`.

Equivalently, the equation `y'' = r·y` has no solution with rational
logarithmic derivative.  The proof is a degree count: the left-hand side always
has even degree (or too small a degree), while the right-hand side has odd
degree. -/
theorem riccati_no_rational_solution (r P Q : K[X]) (hr : Odd r.natDegree) (hQ : Q ≠ 0) :
    derivative P * Q - P * derivative Q + P ^ 2 ≠ r * Q ^ 2 := by
  have hr0 : r ≠ 0 := ne_zero_of_odd_natDegree hr
  rcases eq_or_ne P 0 with hP | hP
  · intro heq
    rw [hP] at heq
    simp only [map_zero, zero_mul, sub_zero, ne_eq, OfNat.ofNat_ne_zero,
      not_false_eq_true, zero_pow, add_zero] at heq
    exact (mul_ne_zero hr0 (pow_ne_zero 2 hQ)) heq.symm
  · rcases Nat.lt_or_ge P.natDegree Q.natDegree with h | h
    · exact riccati_ne_of_degree_lt r P Q hr hP hQ h
    · exact riccati_ne_of_degree_le r P Q hr hP hQ h

/-- **The Kovacic degree and leading-coefficient determination step.**

If a *polynomial* `u ≠ 0` solves the Riccati equation `u' + u² = r`, then the
degree and the leading coefficient of `u` are completely determined by `r`:
`deg r = 2 · deg u` and `lead r = (lead u)²`.  (The point is that `u'` has
strictly smaller degree than `u²`, so `u²` dictates the top of `r`.)  This is
what makes the polynomial search in Kovacic's algorithm a finite one. -/
theorem polynomial_riccati_natDegree (r u : K[X]) (hu : u ≠ 0)
    (h : derivative u + u ^ 2 = r) :
    r.natDegree = 2 * u.natDegree ∧ r.leadingCoeff = u.leadingCoeff ^ 2 := by
  have hu2 : u ^ 2 ≠ 0 := pow_ne_zero 2 hu
  have hlt : (derivative u).degree < (u ^ 2).degree := by
    refine lt_of_lt_of_le (Polynomial.degree_derivative_lt hu) ?_
    rw [sq, Polynomial.degree_mul, Polynomial.degree_eq_natDegree hu]
    exact_mod_cast Nat.le_add_left u.natDegree u.natDegree
  constructor
  · have hd : r.natDegree = (u ^ 2).natDegree := by
      rw [← h]
      exact Polynomial.natDegree_eq_of_degree_eq
        (Polynomial.degree_add_eq_right_of_degree_lt hlt)
    rw [hd, Polynomial.natDegree_pow]
  · rw [← h, Polynomial.leadingCoeff_add_of_degree_lt hlt, Polynomial.leadingCoeff_pow]

/-- The Airy Riccati equation `u' + u² = x` has no *polynomial* solution: the
degree of `x` is odd, contradicting `polynomial_riccati_natDegree`. -/
theorem airy_no_polynomial_riccati (u : K[X]) :
    derivative u + u ^ 2 ≠ (X : K[X]) := by
  intro h
  rcases eq_or_ne u 0 with rfl | hu
  · simp only [Polynomial.derivative_zero, ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true,
      zero_pow, add_zero] at h
    exact Polynomial.X_ne_zero h.symm
  · obtain ⟨hdeg, -⟩ := polynomial_riccati_natDegree X u hu h
    rw [Polynomial.natDegree_X] at hdeg
    omega

/-- Specialisation to the **Airy equation** `y'' = x·y`: the associated Riccati
equation `u' + u² = x` has no rational solution. -/
theorem airy_riccati_no_rational_solution (P Q : K[X]) (hQ : Q ≠ 0) :
    derivative P * Q - P * derivative Q + P ^ 2 ≠ (X : K[X]) * Q ^ 2 := by
  refine riccati_no_rational_solution _ _ _ ?_ hQ
  simp only [Polynomial.natDegree_X]
  exact odd_one

/-- The Airy equation has no nonzero *polynomial* solution. -/
theorem airy_no_polynomial_solution (P : K[X]) (hP : P ≠ 0) :
    derivative (derivative P) ≠ (X : K[X]) * P := by
  intro h
  have h1 : (X * P).degree = 1 + P.degree := by
    rw [Polynomial.degree_mul, Polynomial.degree_X]
  have h2 : (derivative (derivative P)).degree < P.degree := by
    rcases eq_or_ne (derivative P) 0 with h0 | h0
    · rw [h0, Polynomial.derivative_zero, Polynomial.degree_zero,
        Polynomial.degree_eq_natDegree hP]
      exact WithBot.bot_lt_coe _
    · exact lt_trans (Polynomial.degree_derivative_lt h0) (Polynomial.degree_derivative_lt hP)
  rw [h, h1, Polynomial.degree_eq_natDegree hP] at h2
  have : 1 + P.natDegree < P.natDegree := by exact_mod_cast h2
  omega

end Algebraic

/-! ## 4. From analysis to algebra: Airy has no EML exponential solution -/

/-- **No nowhere-vanishing solution of the Airy equation has a rational
logarithmic derivative.**

Here `y` is a nowhere-vanishing function whose logarithmic derivative is the
rational function `P/Q` (with `Q` nowhere vanishing) and which satisfies
`y'' = x·y`.  Such a `y` cannot exist. -/
theorem airy_no_rational_logDeriv (P Q : ℝ[X]) (hQ : ∀ x : ℝ, Q.eval x ≠ 0)
    (y : ℝ → ℝ) (hy0 : ∀ x, y x ≠ 0)
    (hy : ∀ x, HasDerivAt y (P.eval x / Q.eval x * y x) x)
    (hy2 : ∀ x, HasDerivAt (fun t => P.eval t / Q.eval t * y t) (x * y x) x) : False := by
  have hQ0 : Q ≠ 0 := by
    intro h; exact hQ 0 (by simp [h])
  have hud : ∀ x : ℝ, HasDerivAt (fun t => P.eval t / Q.eval t)
      (((derivative P).eval x * Q.eval x - P.eval x * (derivative Q).eval x)
        / (Q.eval x) ^ 2) x := fun x => (P.hasDerivAt x).div (Q.hasDerivAt x) (hQ x)
  -- the Riccati identity, pointwise
  have hric : ∀ x : ℝ, x = ((derivative P).eval x * Q.eval x - P.eval x * (derivative Q).eval x)
      / (Q.eval x) ^ 2 + (P.eval x / Q.eval x) ^ 2 := by
    intro x
    have hEq := (hy2 x).unique ((hud x).mul (hy x))
    have h0 : (x - (((derivative P).eval x * Q.eval x - P.eval x * (derivative Q).eval x)
        / (Q.eval x) ^ 2 + (P.eval x / Q.eval x) ^ 2)) * y x = 0 := by
      linear_combination hEq
    have h1 := (mul_eq_zero.mp h0).resolve_right (hy0 x)
    linarith [h1]
  -- clear denominators and pass to a polynomial identity
  have hpoly : ∀ x : ℝ,
      ((derivative P * Q - P * derivative Q + P ^ 2).eval x) = ((X : ℝ[X]) * Q ^ 2).eval x := by
    intro x
    have h := hric x
    have hQx := hQ x
    simp only [Polynomial.eval_add, Polynomial.eval_sub, Polynomial.eval_mul,
      Polynomial.eval_pow, Polynomial.eval_X]
    field_simp at h
    linarith [h]
  exact airy_riccati_no_rational_solution P Q hQ0 (Polynomial.funext hpoly)

open EMLExpr in
/-- **Airy's equation has no EML solution of exponential type.**

If `F` is an everywhere-regular EML expression whose derivative is a rational
function `P/Q`, then `y = exp ∘ F` — an everywhere-positive EML function — is not
a solution of `y'' = x·y`.  This is the failure of the first Kovacic case for
Airy's equation. -/
theorem airy_no_eml_exponential_solution (F : EMLExpr) (hF : ∀ x, Regular F x)
    (P Q : ℝ[X]) (hQ : ∀ x : ℝ, Q.eval x ≠ 0)
    (hPQ : ∀ x : ℝ, eval (D F) x = P.eval x / Q.eval x)
    (hairy : ∀ x : ℝ, HasDerivAt (fun t => P.eval t / Q.eval t * Real.exp (eval F t))
      (x * Real.exp (eval F x)) x) : False := by
  refine airy_no_rational_logDeriv P Q hQ (fun t => Real.exp (eval F t))
    (fun x => Real.exp_ne_zero _) (fun x => ?_) hairy
  rw [← hPQ x]
  exact exp_solves_firstOrder F x (hF x)

/-! ## 5. Sharpness of the odd-degree hypothesis -/

/-- For the even-degree coefficient `r = x² + 1` the Riccati equation *does* have
the rational (indeed polynomial) solution `u = x`, witnessed by the cleared
identity with `P = X`, `Q = 1`. -/
theorem riccati_odd_degree_sharp :
    derivative (X : ℝ[X]) * 1 - (X : ℝ[X]) * derivative 1 + (X : ℝ[X]) ^ 2
      = ((X : ℝ[X]) ^ 2 + 1) * 1 ^ 2 := by
  simp [add_comm]

/-- `y = exp (x²/2)` solves the first-order companion equation `y' = x·y`. -/
theorem exp_half_sq_firstOrder :
    ∀ x : ℝ, HasDerivAt (fun t : ℝ => Real.exp (t ^ 2 / 2))
      (x * Real.exp (x ^ 2 / 2)) x := by
  intro x
  have hq : HasDerivAt (fun t : ℝ => t ^ 2 / 2) x x := by
    simpa using ((hasDerivAt_pow 2 x).div_const 2)
  simpa [mul_comm] using hq.exp

/-- The EML function `y = exp (x²/2)` really solves `y'' = (x²+1)·y`: its
derivative `x·y` has derivative `(x²+1)·y`.  Together with
`riccati_no_rational_solution` this shows the parity hypothesis there is
essential — for `r = x²+1` an EML solution of exponential type does exist. -/
theorem exp_half_sq_solves :
    ∀ x : ℝ, HasDerivAt (fun t : ℝ => t * Real.exp (t ^ 2 / 2))
      ((x ^ 2 + 1) * Real.exp (x ^ 2 / 2)) x := by
  intro x
  have h := (hasDerivAt_id x).mul (exp_half_sq_firstOrder x)
  simp only [id_eq] at h
  convert h using 1
  ring

end EMLDiffEq