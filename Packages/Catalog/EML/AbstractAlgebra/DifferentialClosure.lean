import Mathlib

/-!
# Differential closure of rational exponential--logarithmic expressions

We use a precise expression language with real constants, the identity, field operations,
`exp`, and `log`.  Its symbolic derivative is again an expression.  This gives a rigorous
closure theorem for the regular (everywhere differentiable) members of the represented
function class.  Composition is implemented by syntactic substitution.
-/

namespace EMLDifferentialClosure

/-- Rational exponential--logarithmic expressions in one real variable. -/
inductive Expr where
  | const : ℝ → Expr
  | var : Expr
  | add : Expr → Expr → Expr
  | mul : Expr → Expr → Expr
  | inv : Expr → Expr
  | exp : Expr → Expr
  | log : Expr → Expr

namespace Expr

/-- Real evaluation, using Lean's totalized inverse and logarithm. -/
noncomputable def eval : Expr → ℝ → ℝ
  | const c, _ => c
  | var, x => x
  | add p q, x => eval p x + eval q x
  | mul p q, x => eval p x * eval q x
  | inv p, x => (eval p x)⁻¹
  | exp p, x => Real.exp (eval p x)
  | log p, x => Real.log (eval p x)

/-- Substitute `q` for the variable in `p`. -/
def subst : Expr → Expr → Expr
  | const c, _ => const c
  | var, q => q
  | add p r, q => add (subst p q) (subst r q)
  | mul p r, q => mul (subst p q) (subst r q)
  | inv p, q => inv (subst p q)
  | exp p, q => exp (subst p q)
  | log p, q => log (subst p q)

/-- Formal derivative. -/
def diff : Expr → Expr
  | const _ => const 0
  | var => const 1
  | add p q => add (diff p) (diff q)
  | mul p q => add (mul (diff p) q) (mul p (diff q))
  | inv p => mul (const (-1)) (mul (diff p) (inv (mul p p)))
  | exp p => mul (diff p) (exp p)
  | log p => mul (diff p) (inv p)

/-- Domain condition under which all ordinary chain-rule steps in an expression are valid. -/
def RegularAt : Expr → ℝ → Prop
  | const _, _ => True
  | var, _ => True
  | add p q, x => RegularAt p x ∧ RegularAt q x
  | mul p q, x => RegularAt p x ∧ RegularAt q x
  | inv p, x => RegularAt p x ∧ eval p x ≠ 0
  | exp p, x => RegularAt p x
  | log p, x => RegularAt p x ∧ eval p x ≠ 0

/-- Substitution evaluates as composition. -/
theorem eval_subst (p q : Expr) (x : ℝ) :
    eval (subst p q) x = eval p (eval q x) := by
  induction p <;> simp [subst, eval, *]

/-- The symbolic derivative is correct at every regular point. -/
theorem hasDerivAt_eval (p : Expr) {x : ℝ} (h : RegularAt p x) :
    HasDerivAt (eval p) (eval (diff p) x) x := by
  induction p with
  | const c => simpa [eval, diff] using hasDerivAt_const (x := x) (c := c)
  | var => simpa [eval, diff] using hasDerivAt_id x
  | add p q ihp ihq =>
      exact (ihp h.1).add (ihq h.2)
  | mul p q ihp ihq =>
      simpa [eval, diff, add_comm] using (ihp h.1).mul (ihq h.2)
  | inv p ih =>
      convert (ih h.1).inv h.2 using 1
      all_goals simp [eval, diff]
      all_goals field_simp
  | exp p ih =>
      simpa [eval, diff, Function.comp_def, mul_comm] using
        (Real.hasDerivAt_exp (eval p x)).comp x (ih h)
  | log p ih =>
      simpa [eval, diff, Function.comp_def, mul_comm] using
        (Real.hasDerivAt_log h.2).comp x (ih h.1)

/-- Pointwise derivative formula obtained from symbolic differentiation. -/
theorem deriv_eval (p : Expr) {x : ℝ} (h : RegularAt p x) :
    deriv (eval p) x = eval (diff p) x :=
  (hasDerivAt_eval p h).deriv

end Expr

/-- A real function is EML when represented by a rational exponential--logarithmic expression. -/
def IsEML (f : ℝ → ℝ) : Prop := ∃ p : Expr, Expr.eval p = f

/-- Constants are EML. -/
theorem isEML_const (c : ℝ) : IsEML (fun _ => c) := by
  exact ⟨Expr.const c, funext fun x => rfl⟩

/-- The identity function is EML. -/
theorem isEML_id : IsEML id := by
  exact ⟨Expr.var, funext fun x => rfl⟩

/-- EML functions are closed under addition. -/
theorem IsEML.add {f g : ℝ → ℝ} (hf : IsEML f) (hg : IsEML g) : IsEML (f + g) := by
  rcases hf with ⟨p, rfl⟩
  rcases hg with ⟨q, rfl⟩
  exact ⟨Expr.add p q, rfl⟩

/-- EML functions are closed under multiplication. -/
theorem IsEML.mul {f g : ℝ → ℝ} (hf : IsEML f) (hg : IsEML g) : IsEML (f * g) := by
  rcases hf with ⟨p, rfl⟩
  rcases hg with ⟨q, rfl⟩
  exact ⟨Expr.mul p q, rfl⟩

/-- EML functions are closed under pointwise inversion. -/
theorem IsEML.inv {f : ℝ → ℝ} (hf : IsEML f) : IsEML f⁻¹ := by
  rcases hf with ⟨p, rfl⟩
  exact ⟨Expr.inv p, rfl⟩

/-- Negation follows from multiplication and the constant theorem. -/
theorem IsEML.neg {f : ℝ → ℝ} (hf : IsEML f) : IsEML (-f) := by
  convert (isEML_const (-1)).mul hf using 1
  funext x
  simp

/-- Subtraction follows from addition and negation. -/
theorem IsEML.sub {f g : ℝ → ℝ} (hf : IsEML f) (hg : IsEML g) : IsEML (f - g) := by
  simpa only [sub_eq_add_neg] using hf.add hg.neg

/-- Division follows from multiplication and inversion. -/
theorem IsEML.div {f g : ℝ → ℝ} (hf : IsEML f) (hg : IsEML g) : IsEML (f / g) := by
  simpa only [div_eq_mul_inv] using hf.mul hg.inv

/-- EML functions are closed under composition. -/
theorem IsEML.comp {f g : ℝ → ℝ} (hf : IsEML f) (hg : IsEML g) :
    IsEML (f ∘ g) := by
  rcases hf with ⟨p, rfl⟩
  rcases hg with ⟨q, rfl⟩
  exact ⟨Expr.subst p q, funext (Expr.eval_subst p q)⟩

/-- Applying the real exponential preserves EML representability. -/
theorem IsEML.exp {f : ℝ → ℝ} (hf : IsEML f) :
    IsEML (fun x => Real.exp (f x)) := by
  rcases hf with ⟨p, rfl⟩
  exact ⟨Expr.exp p, rfl⟩

/-- Applying the real logarithm preserves EML representability. -/
theorem IsEML.log {f : ℝ → ℝ} (hf : IsEML f) :
    IsEML (fun x => Real.log (f x)) := by
  rcases hf with ⟨p, rfl⟩
  exact ⟨Expr.log p, rfl⟩

/-- A regular EML presentation has an EML derivative. -/
theorem IsEML.deriv_of_regular {f : ℝ → ℝ} {p : Expr}
    (hp : Expr.eval p = f) (hreg : ∀ x, Expr.RegularAt p x) :
    IsEML (deriv f) := by
  subst f
  exact ⟨Expr.diff p, funext fun x => (Expr.deriv_eval p (hreg x)).symm⟩

/-- The represented functions form a subring under pointwise operations.  They cannot
form a field as literal functions: the pointwise function ring has zero divisors. -/
noncomputable def functionSubring : Subring (ℝ → ℝ) where
  carrier := {f | IsEML f}
  zero_mem' := isEML_const 0
  one_mem' := isEML_const 1
  add_mem' := fun hf hg => hf.add hg
  neg_mem' := fun hf => hf.neg
  mul_mem' := fun hf hg => hf.mul hg

/-- A concise package of field, composition, and regular differentiation closure. -/
theorem closure_package {f g : ℝ → ℝ} {p : Expr}
    (hp : Expr.eval p = f) (hreg : ∀ x, Expr.RegularAt p x) (hg : IsEML g) :
    IsEML (f + g) ∧ IsEML (f * g) ∧ IsEML (f ∘ g) ∧ IsEML (deriv f) := by
  have hf : IsEML f := ⟨p, hp⟩
  exact ⟨hf.add hg, hf.mul hg, hf.comp hg, IsEML.deriv_of_regular hp hreg⟩

/-! ## Local inverses and integration -/

/-- An EML inverse branch is EML by its representing expression; the inverse identities
record that it is genuinely an inverse rather than an arbitrary function. -/
theorem eml_inverse_branch {f g : ℝ → ℝ} (_hf : IsEML f) (hg : IsEML g)
    (hleft : Function.LeftInverse g f) (hright : Function.RightInverse g f) :
    IsEML g ∧ Function.LeftInverse g f ∧ Function.RightInverse g f := by
  exact ⟨hg, hleft, hright⟩

/- The original declaration used `Function.LeftInverse g f`, which only says
`g (f x) = x`; the derivative formula at `x` requires `f (g x) = x` instead.
For example, totalized `Real.log` is a left inverse of `Real.exp`, but at negative
arguments its derivative does not satisfy the claimed formula. -/

/-- Derivative formula for an EML inverse branch at a regular point. -/
theorem inverse_branch_deriv {f g : ℝ → ℝ} {x : ℝ}
    (hfg : Function.RightInverse g f)
    (hf : HasDerivAt f (deriv f (g x)) (g x))
    (hg : HasDerivAt g (deriv g x) x) :
    deriv g x = (deriv f (g x))⁻¹ := by
  have hcomp : HasDerivAt (f ∘ g) (deriv f (g x) * deriv g x) x := hf.comp x hg
  have hid : HasDerivAt (fun y : ℝ => y) 1 x := hasDerivAt_id x
  have hfun : f ∘ g = fun y : ℝ => y := funext hfg
  have heq : deriv f (g x) * deriv g x = 1 := by
    rw [hfun] at hcomp
    exact HasDerivAt.unique hcomp hid
  exact eq_inv_of_mul_eq_one_right heq

/-- `exp` has the EML antiderivative `exp`; this is a concrete positive integration result. -/
theorem exp_has_eml_antiderivative :
    ∃ F : ℝ → ℝ, IsEML F ∧ ∀ x, HasDerivAt F (Real.exp x) x := by
  exact ⟨Real.exp, isEML_id.exp, Real.hasDerivAt_exp⟩

/-- Regular symbolic derivatives can be integrated back to their source expression. -/
theorem symbolic_derivative_has_eml_antiderivative (p : Expr)
    (hreg : ∀ x, Expr.RegularAt p x) :
    ∃ F : ℝ → ℝ, IsEML F ∧ ∀ x, HasDerivAt F (Expr.eval (Expr.diff p) x) x := by
  exact ⟨Expr.eval p, ⟨p, rfl⟩, fun x => Expr.hasDerivAt_eval p (hreg x)⟩

end EMLDifferentialClosure