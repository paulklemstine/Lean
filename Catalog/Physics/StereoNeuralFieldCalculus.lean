import Mathlib

/-!
# Stereographic neural fields I: a verified symbolic calculus for the conformal chart

Neural-field equations on the cortical sphere `S²` are transported to the plane by
inverse stereographic projection.  Every function that occurs in this transport
(the chart coordinates, spherical harmonics pulled back through the chart, the
conformal weight) is a polynomial in the two plane coordinates `x`, `y` and the
single *conformal atom*

`W x y = (1 + x² + y²)⁻¹`.

This file builds a small reflective calculus for exactly that algebra:

* `NExpr` — syntax for polynomials in `x`, `y`, `W`;
* `NExpr.evalAt` — its semantics as a genuine real-valued function of two variables;
* `NExpr.dx`, `NExpr.dy` — *symbolic* partial differentiation, closed on the syntax
  because `∂ₓ W = -2xW²`;
* `hasDerivAt_evalAt_x/y` — the soundness theorem: the symbolic derivative really is
  the analytic partial derivative (proved by structural induction on the syntax);
* `laplacian` — the analytic Euclidean Laplacian defined through iterated `deriv`,
  and `laplacian_evalAt`, which computes it by the symbolic operator `NExpr.lapE`.

The payoff is `laplacian_mul`: the Leibniz rule
`Δ(uv) = uΔv + vΔu + 2∇u·∇v` for the analytic Laplacian of two members of this
algebra, proved once and for all at the syntactic level.  Later files use it to
propagate the Laplace–Beltrami eigenvalue relation from the three chart coordinates
to spherical harmonics of arbitrary degree, so no large rational-function
computation is ever needed twice.
-/

namespace StereoNeuralField

noncomputable section

/-- The conformal atom of the stereographic chart, `W = 1/(1+x²+y²)`.
The round metric of the unit sphere pulled back to the plane is `4W²(dx²+dy²)`. -/
def W (x y : ℝ) : ℝ := (1 + x ^ 2 + y ^ 2)⁻¹

theorem W_pos (x y : ℝ) : 0 < W x y := by
  unfold W
  positivity

theorem denom_ne_zero (x y : ℝ) : (1 + x ^ 2 + y ^ 2) ≠ 0 := by positivity

theorem W_mul_denom (x y : ℝ) : W x y * (1 + x ^ 2 + y ^ 2) = 1 := by
  unfold W
  field_simp

/-- Syntax of the algebra `ℝ[x, y, W]`. -/
inductive NExpr where
  | const : ℝ → NExpr
  | X : NExpr
  | Y : NExpr
  | Wt : NExpr
  | add : NExpr → NExpr → NExpr
  | mul : NExpr → NExpr → NExpr

namespace NExpr

/-- Semantics: an `NExpr` denotes a real function of the two plane coordinates. -/
def evalAt : NExpr → ℝ → ℝ → ℝ
  | const c, _, _ => c
  | X, x, _ => x
  | Y, _, y => y
  | Wt, x, y => W x y
  | add a b, x, y => evalAt a x y + evalAt b x y
  | mul a b, x, y => evalAt a x y * evalAt b x y

instance : Zero NExpr := ⟨const 0⟩
instance : One NExpr := ⟨const 1⟩
instance : Add NExpr := ⟨add⟩
instance : Mul NExpr := ⟨mul⟩

/-- Subtraction inside the algebra. -/
@[reducible] def sub (a b : NExpr) : NExpr := add a (mul (const (-1)) b)

instance : Sub NExpr := ⟨sub⟩

@[simp] theorem evalAt_add (a b : NExpr) (x y : ℝ) :
    evalAt (a + b) x y = evalAt a x y + evalAt b x y := rfl

@[simp] theorem evalAt_mul (a b : NExpr) (x y : ℝ) :
    evalAt (a * b) x y = evalAt a x y * evalAt b x y := rfl

@[simp] theorem evalAt_sub (a b : NExpr) (x y : ℝ) :
    evalAt (a - b) x y = evalAt a x y - evalAt b x y := by
  show evalAt a x y + (-1) * evalAt b x y = _
  ring

/-- Symbolic partial derivative in the first plane coordinate.  The algebra is
closed under it because `∂ₓ W = -2xW²`. -/
def dx : NExpr → NExpr
  | const _ => const 0
  | X => const 1
  | Y => const 0
  | Wt => mul (const (-2)) (mul X (mul Wt Wt))
  | add a b => add (dx a) (dx b)
  | mul a b => add (mul (dx a) b) (mul a (dx b))

/-- Symbolic partial derivative in the second plane coordinate. -/
def dy : NExpr → NExpr
  | const _ => const 0
  | X => const 0
  | Y => const 1
  | Wt => mul (const (-2)) (mul Y (mul Wt Wt))
  | add a b => add (dy a) (dy b)
  | mul a b => add (mul (dy a) b) (mul a (dy b))

/-- Symbolic Laplacian. -/
def lapE (e : NExpr) : NExpr := add (dx (dx e)) (dy (dy e))

/-- Symbolic gradient pairing `∇a · ∇b`. -/
def dotE (a b : NExpr) : NExpr := add (mul (dx a) (dx b)) (mul (dy a) (dy b))

end NExpr

open NExpr

/-- Analytic partial derivative of the conformal atom in `x`. -/
theorem hasDerivAt_W_x (x y : ℝ) :
    HasDerivAt (fun s => W s y) (-2 * x * (W x y) ^ 2) x := by
  have hd : HasDerivAt (fun s : ℝ => 1 + s ^ 2 + y ^ 2) (2 * x) x := by
    have h1 : HasDerivAt (fun s : ℝ => s ^ 2) (2 * x) x := by
      simpa using (hasDerivAt_pow 2 x)
    simpa using (h1.const_add (1 : ℝ)).add_const (y ^ 2)
  have hne : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
  have h := hd.inv hne
  refine h.congr_deriv ?_
  unfold W
  field_simp

/-- Analytic partial derivative of the conformal atom in `y`. -/
theorem hasDerivAt_W_y (x y : ℝ) :
    HasDerivAt (fun t => W x t) (-2 * y * (W x y) ^ 2) y := by
  have hd : HasDerivAt (fun t : ℝ => 1 + x ^ 2 + t ^ 2) (2 * y) y := by
    have h1 : HasDerivAt (fun t : ℝ => t ^ 2) (2 * y) y := by
      simpa using (hasDerivAt_pow 2 y)
    simpa using (h1.const_add (1 + x ^ 2))
  have hne : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
  have h := hd.inv hne
  refine h.congr_deriv ?_
  unfold W
  field_simp

/-- **Soundness of symbolic differentiation in `x`.**  For every syntactic
expression the symbolic derivative `dx e` denotes the analytic partial derivative
of the denotation of `e`. -/
theorem hasDerivAt_evalAt_x : ∀ (e : NExpr) (x y : ℝ),
    HasDerivAt (fun s => evalAt e s y) (evalAt (dx e) x y) x := by
  intro e
  induction e with
  | const c => intro x y; simpa [evalAt, dx] using (hasDerivAt_const x c)
  | X => intro x y; simpa [evalAt, dx] using (hasDerivAt_id x)
  | Y => intro x y; simpa [evalAt, dx] using (hasDerivAt_const x y)
  | Wt =>
      intro x y
      have hval : evalAt (dx Wt) x y = -2 * x * (W x y) ^ 2 := by
        simp only [dx, evalAt]; ring
      rw [hval]
      exact hasDerivAt_W_x x y
  | add a b ha hb =>
      intro x y
      simpa [evalAt, dx] using (ha x y).add (hb x y)
  | mul a b ha hb =>
      intro x y
      simpa [evalAt, dx] using (ha x y).mul (hb x y)

/-- **Soundness of symbolic differentiation in `y`.** -/
theorem hasDerivAt_evalAt_y : ∀ (e : NExpr) (x y : ℝ),
    HasDerivAt (fun t => evalAt e x t) (evalAt (dy e) x y) y := by
  intro e
  induction e with
  | const c => intro x y; simpa [evalAt, dy] using (hasDerivAt_const y c)
  | X => intro x y; simpa [evalAt, dy] using (hasDerivAt_const y x)
  | Y => intro x y; simpa [evalAt, dy] using (hasDerivAt_id y)
  | Wt =>
      intro x y
      have hval : evalAt (dy Wt) x y = -2 * y * (W x y) ^ 2 := by
        simp only [dy, evalAt]; ring
      rw [hval]
      exact hasDerivAt_W_y x y
  | add a b ha hb =>
      intro x y
      simpa [evalAt, dy] using (ha x y).add (hb x y)
  | mul a b ha hb =>
      intro x y
      simpa [evalAt, dy] using (ha x y).mul (hb x y)

theorem deriv_evalAt_x (e : NExpr) (x y : ℝ) :
    deriv (fun s => evalAt e s y) x = evalAt (dx e) x y :=
  (hasDerivAt_evalAt_x e x y).deriv

theorem deriv_evalAt_y (e : NExpr) (x y : ℝ) :
    deriv (fun t => evalAt e x t) y = evalAt (dy e) x y :=
  (hasDerivAt_evalAt_y e x y).deriv

/-- The analytic Euclidean Laplacian on the plane, defined through iterated
one-variable derivatives. -/
def laplacian (u : ℝ → ℝ → ℝ) (x y : ℝ) : ℝ :=
  deriv (fun s => deriv (fun t => u t y) s) x + deriv (fun t => deriv (fun s => u x s) t) y

/-- The analytic Euclidean gradient pairing. -/
def gradDot (u v : ℝ → ℝ → ℝ) (x y : ℝ) : ℝ :=
  deriv (fun s => u s y) x * deriv (fun s => v s y) x +
    deriv (fun t => u x t) y * deriv (fun t => v x t) y

/-- **Reflection theorem.**  The analytic Laplacian of a denoted expression is
computed by the symbolic Laplacian. -/
theorem laplacian_evalAt (e : NExpr) (x y : ℝ) :
    laplacian (evalAt e) x y = evalAt (lapE e) x y := by
  have hx : (fun s => deriv (fun t => evalAt e t y) s) = fun s => evalAt (dx e) s y := by
    funext s; exact deriv_evalAt_x e s y
  have hy : (fun t => deriv (fun s => evalAt e x s) t) = fun t => evalAt (dy e) x t := by
    funext t; exact deriv_evalAt_y e x t
  unfold laplacian lapE
  rw [hx, hy, deriv_evalAt_x, deriv_evalAt_y]
  simp [evalAt]

/-- The analytic gradient pairing of denoted expressions is computed symbolically. -/
theorem gradDot_evalAt (a b : NExpr) (x y : ℝ) :
    gradDot (evalAt a) (evalAt b) x y = evalAt (dotE a b) x y := by
  unfold gradDot dotE
  rw [deriv_evalAt_x, deriv_evalAt_x, deriv_evalAt_y, deriv_evalAt_y]
  simp [evalAt]

/-- **Leibniz rule for the Laplacian**, proved once at the syntactic level:
`Δ(uv) = uΔv + vΔu + 2 ∇u·∇v`. -/
theorem laplacian_mul (a b : NExpr) (x y : ℝ) :
    laplacian (evalAt (a * b)) x y =
      evalAt a x y * laplacian (evalAt b) x y + evalAt b x y * laplacian (evalAt a) x y +
        2 * gradDot (evalAt a) (evalAt b) x y := by
  rw [laplacian_evalAt, laplacian_evalAt, laplacian_evalAt, gradDot_evalAt]
  show evalAt (lapE (mul a b)) x y = _
  simp only [lapE, dotE, dx, dy, evalAt]
  ring

/-- The Laplacian is additive on the algebra. -/
theorem laplacian_add (a b : NExpr) (x y : ℝ) :
    laplacian (evalAt (a + b)) x y = laplacian (evalAt a) x y + laplacian (evalAt b) x y := by
  rw [laplacian_evalAt, laplacian_evalAt, laplacian_evalAt]
  show evalAt (lapE (add a b)) x y = _
  simp only [lapE, dx, dy, evalAt]
  ring

/-- The Laplacian commutes with scalar multiples inside the algebra. -/
theorem laplacian_const_mul (c : ℝ) (a : NExpr) (x y : ℝ) :
    laplacian (evalAt (NExpr.const c * a)) x y = c * laplacian (evalAt a) x y := by
  rw [laplacian_evalAt, laplacian_evalAt]
  show evalAt (lapE (mul (NExpr.const c) a)) x y = _
  simp only [lapE, dx, dy, evalAt]
  ring

/-- The Laplacian respects subtraction inside the algebra. -/
theorem laplacian_sub (a b : NExpr) (x y : ℝ) :
    laplacian (evalAt (a - b)) x y = laplacian (evalAt a) x y - laplacian (evalAt b) x y := by
  rw [laplacian_evalAt, laplacian_evalAt, laplacian_evalAt]
  show evalAt (lapE (NExpr.sub a b)) x y = _
  simp only [lapE, dx, dy, evalAt]
  ring

/-- Bilinearity of the gradient pairing in its second slot. -/
theorem gradDot_add_right (a b c : NExpr) (x y : ℝ) :
    gradDot (evalAt a) (evalAt (b + c)) x y =
      gradDot (evalAt a) (evalAt b) x y + gradDot (evalAt a) (evalAt c) x y := by
  rw [gradDot_evalAt, gradDot_evalAt, gradDot_evalAt]
  show evalAt (dotE a (add b c)) x y = _
  simp only [dotE, dx, dy, evalAt]
  ring

/-- Leibniz rule for the gradient pairing. -/
theorem gradDot_mul_right (a b c : NExpr) (x y : ℝ) :
    gradDot (evalAt a) (evalAt (b * c)) x y =
      evalAt b x y * gradDot (evalAt a) (evalAt c) x y +
        evalAt c x y * gradDot (evalAt a) (evalAt b) x y := by
  rw [gradDot_evalAt, gradDot_evalAt, gradDot_evalAt]
  show evalAt (dotE a (mul b c)) x y = _
  simp only [dotE, dx, dy, evalAt]
  ring

end

end StereoNeuralField