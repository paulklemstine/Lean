/-
# The log-free EML differential algebra

A small syntactic differential algebra of "exponential–multiplication–linear"
(log-free EML) terms over `ℝ`, built from constants, the identity, addition,
multiplication, negation, and the real exponential.

We define
* `Term.eval`  : the interpretation of a term as a real function;
* `Term.D`     : the syntactic derivative (product rule + exponential chain rule);
* `Term.comp`  : syntactic substitution / composition.

and prove smoothness of every represented function, correctness of the syntactic
derivative (both the local `HasDerivAt` form and the `deriv` form), correctness of
composition, and that the represented functions form an exact subalgebra of the
function algebra `ℝ → ℝ`, all of whose members are smooth.
-/
import Mathlib

namespace LogFreeEML

/-- Syntax of log-free EML terms over `ℝ`. -/
inductive Term : Type
  | const : ℝ → Term
  | X : Term
  | add : Term → Term → Term
  | mul : Term → Term → Term
  | neg : Term → Term
  | exp : Term → Term

namespace Term

/-- Interpretation of a term as a real function. -/
noncomputable def eval : Term → ℝ → ℝ
  | const c => fun _ => c
  | X => fun x => x
  | add a b => fun x => a.eval x + b.eval x
  | mul a b => fun x => a.eval x * b.eval x
  | neg a => fun x => -(a.eval x)
  | exp a => fun x => Real.exp (a.eval x)

@[simp] theorem eval_const (c : ℝ) (x : ℝ) : (const c).eval x = c := rfl
@[simp] theorem eval_X (x : ℝ) : X.eval x = x := rfl
@[simp] theorem eval_add (a b : Term) (x : ℝ) : (add a b).eval x = a.eval x + b.eval x := rfl
@[simp] theorem eval_mul (a b : Term) (x : ℝ) : (mul a b).eval x = a.eval x * b.eval x := rfl
@[simp] theorem eval_neg (a : Term) (x : ℝ) : (neg a).eval x = -(a.eval x) := rfl
@[simp] theorem eval_exp (a : Term) (x : ℝ) : (exp a).eval x = Real.exp (a.eval x) := rfl

/-- Syntactic derivative: product rule and exponential chain rule. -/
def D : Term → Term
  | const _ => const 0
  | X => const 1
  | add a b => add a.D b.D
  | mul a b => add (mul a.D b) (mul a b.D)
  | neg a => neg a.D
  | exp a => mul a.D (exp a)

@[simp] theorem D_const (c : ℝ) : (const c).D = const 0 := rfl
@[simp] theorem D_X : X.D = const 1 := rfl
@[simp] theorem D_add (a b : Term) : (add a b).D = add a.D b.D := rfl
@[simp] theorem D_mul (a b : Term) : (mul a b).D = add (mul a.D b) (mul a b.D) := rfl
@[simp] theorem D_neg (a : Term) : (neg a).D = neg a.D := rfl
@[simp] theorem D_exp (a : Term) : (exp a).D = mul a.D (exp a) := rfl

/-- Syntactic substitution of `t` for the variable `X` in `s`. -/
def comp : Term → Term → Term
  | const c, _ => const c
  | X, t => t
  | add a b, t => add (a.comp t) (b.comp t)
  | mul a b, t => mul (a.comp t) (b.comp t)
  | neg a, t => neg (a.comp t)
  | exp a, t => exp (a.comp t)

/-! ### A. Smoothness -/

/-- Every represented function is smooth. -/
theorem contDiff_eval (t : Term) : ContDiff ℝ ⊤ t.eval := by
  induction t with
  | const c => simpa [eval] using (contDiff_const : ContDiff ℝ ⊤ (fun _ : ℝ => c))
  | X => simpa [eval] using (contDiff_id : ContDiff ℝ ⊤ (id : ℝ → ℝ))
  | add a b iha ihb => simpa [eval] using iha.add ihb
  | mul a b iha ihb => simpa [eval] using iha.mul ihb
  | neg a iha => simpa [eval] using iha.neg
  | exp a iha => simpa [eval] using iha.exp

/-! ### B. Correctness of syntactic differentiation -/

/-- The syntactic derivative computes the actual derivative, locally. -/
theorem hasDerivAt_eval (t : Term) (x : ℝ) :
    HasDerivAt t.eval ((Term.D t).eval x) x := by
  induction t generalizing x with
  | const c => simpa [eval, D] using hasDerivAt_const x c
  | X => simpa [eval, D] using hasDerivAt_id x
  | add a b iha ihb => simpa [eval, D] using (iha x).add (ihb x)
  | mul a b iha ihb => simpa [eval, D] using (iha x).mul (ihb x)
  | neg a iha => simpa [eval, D] using (iha x).neg
  | exp a iha => simpa [eval, D, mul_comm] using (iha x).exp

/-- The syntactic derivative computes the actual `deriv`. -/
theorem deriv_eval (t : Term) (x : ℝ) : deriv t.eval x = (Term.D t).eval x :=
  (t.hasDerivAt_eval x).deriv

/-! ### C. Correctness of syntactic composition -/

/-- Syntactic composition implements function composition. -/
theorem eval_comp (s t : Term) (x : ℝ) : (Term.comp s t).eval x = s.eval (t.eval x) := by
  induction s with
  | const c => rfl
  | X => rfl
  | add a b iha ihb => simp [comp, eval, iha, ihb]
  | mul a b iha ihb => simp [comp, eval, iha, ihb]
  | neg a iha => simp [comp, eval, iha]
  | exp a iha => simp [comp, eval, iha]

end Term

/-! ### D. The EML subalgebra -/

/-- A function is EML if it is represented by some term. -/
def IsEML (f : ℝ → ℝ) : Prop := ∃ t : Term, t.eval = f

theorem isEML_const (c : ℝ) : IsEML (fun _ => c) := ⟨Term.const c, rfl⟩

theorem isEML_id : IsEML (fun x => x) := ⟨Term.X, rfl⟩

theorem IsEML.add {f g : ℝ → ℝ} (hf : IsEML f) (hg : IsEML g) : IsEML (f + g) := by
  obtain ⟨tf, rfl⟩ := hf
  obtain ⟨tg, rfl⟩ := hg
  exact ⟨Term.add tf tg, by funext x; simp [Term.eval]⟩

theorem IsEML.mul {f g : ℝ → ℝ} (hf : IsEML f) (hg : IsEML g) : IsEML (f * g) := by
  obtain ⟨tf, rfl⟩ := hf
  obtain ⟨tg, rfl⟩ := hg
  exact ⟨Term.mul tf tg, by funext x; simp [Term.eval]⟩

theorem IsEML.neg {f : ℝ → ℝ} (hf : IsEML f) : IsEML (-f) := by
  obtain ⟨tf, rfl⟩ := hf
  exact ⟨Term.neg tf, by funext x; simp [Term.eval]⟩

theorem IsEML.exp {f : ℝ → ℝ} (hf : IsEML f) : IsEML (fun x => Real.exp (f x)) := by
  obtain ⟨tf, rfl⟩ := hf
  exact ⟨Term.exp tf, rfl⟩

theorem IsEML.comp {f g : ℝ → ℝ} (hf : IsEML f) (hg : IsEML g) : IsEML (fun x => f (g x)) := by
  obtain ⟨tf, rfl⟩ := hf
  obtain ⟨tg, rfl⟩ := hg
  exact ⟨Term.comp tf tg, by funext x; simp [Term.eval_comp]⟩

theorem IsEML.deriv {f : ℝ → ℝ} (hf : IsEML f) : IsEML (deriv f) := by
  obtain ⟨tf, rfl⟩ := hf
  exact ⟨Term.D tf, by funext x; simp [Term.deriv_eval]⟩

/-- The exact subalgebra of `ℝ → ℝ` consisting of the EML functions. -/
noncomputable def emlSubalgebra : Subalgebra ℝ (ℝ → ℝ) where
  carrier := {f | IsEML f}
  mul_mem' hf hg := IsEML.mul hf hg
  one_mem' := ⟨Term.const 1, by funext x; simp [Term.eval]⟩
  add_mem' hf hg := IsEML.add hf hg
  zero_mem' := ⟨Term.const 0, by funext x; simp [Term.eval]⟩
  algebraMap_mem' r := ⟨Term.const r, by funext x; simp [Term.eval]⟩

@[simp] theorem mem_emlSubalgebra_iff (f : ℝ → ℝ) : f ∈ emlSubalgebra ↔ IsEML f := Iff.rfl

/-- Every member of the EML subalgebra is smooth. -/
theorem smooth_of_mem_emlSubalgebra {f : ℝ → ℝ} (hf : f ∈ emlSubalgebra) :
    ContDiff ℝ ⊤ f := by
  obtain ⟨t, rfl⟩ := (mem_emlSubalgebra_iff f).mp hf
  exact t.contDiff_eval

end LogFreeEML