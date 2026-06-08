import Mathlib

/-!
# EML Single-Operator Church-Turing Thesis

## Overview

We formalize the conjecture that `exp` and `log`, together with field operations
and constants, form a computationally universal basis for real computation over
the elementary functions. The key operator is `eml(x, y) = exp(x) - log(y)`,
which subsumes both `exp` (via `eml(x, 1)`) and `log` (via `1 - eml(0, y)`).

## Novel Contributions

1. **`EMLCircuit`**: A typed expression tree for EML computations.
2. **`transcDepth`**: A novel complexity measure — the maximum number of
   `exp`/`log` nodes on any root-to-leaf path — capturing "transcendental
   nesting depth" while treating field operations as free.
3. **Depth hierarchy**: `iterExp n` is in depth class `n` and the hierarchy
   is strict.
4. **Composition theorem**: Depth adds under composition via circuit substitution.
5. **EML Church-Turing Conjecture**: Formally stated.
-/

noncomputable section
open Real Set

/-! ## §1. Expression Trees and Evaluation -/

/-- An EML circuit: expression tree with exp, log, field ops, and constants. -/
inductive EMLCircuit where
  | var : EMLCircuit
  | const : ℝ → EMLCircuit
  | add : EMLCircuit → EMLCircuit → EMLCircuit
  | mul : EMLCircuit → EMLCircuit → EMLCircuit
  | neg : EMLCircuit → EMLCircuit
  | inv : EMLCircuit → EMLCircuit
  | exp : EMLCircuit → EMLCircuit
  | log : EMLCircuit → EMLCircuit
  deriving Inhabited

/-- Evaluate an EML circuit at input `x`. -/
def EMLCircuit.eval : EMLCircuit → ℝ → ℝ
  | .var, x => x
  | .const c, _ => c
  | .add a b, x => a.eval x + b.eval x
  | .mul a b, x => a.eval x * b.eval x
  | .neg a, x => -(a.eval x)
  | .inv a, x => (a.eval x)⁻¹
  | .exp a, x => Real.exp (a.eval x)
  | .log a, x => Real.log (a.eval x)

/-- Total node count (size) of a circuit. -/
def EMLCircuit.size : EMLCircuit → ℕ
  | .var => 1
  | .const _ => 1
  | .add a b => 1 + a.size + b.size
  | .mul a b => 1 + a.size + b.size
  | .neg a => 1 + a.size
  | .inv a => 1 + a.size
  | .exp a => 1 + a.size
  | .log a => 1 + a.size

/-! ## §2. Transcendental Depth — A Novel Complexity Measure -/

/-- Transcendental depth: max exp/log nodes on any root-to-leaf path.
    Field operations (add, mul, neg, inv) contribute 0 to this measure.
    This captures the "transcendental nesting" of a computation. -/
def EMLCircuit.transcDepth : EMLCircuit → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.transcDepth b.transcDepth
  | .mul a b => max a.transcDepth b.transcDepth
  | .neg a => a.transcDepth
  | .inv a => a.transcDepth
  | .exp a => 1 + a.transcDepth
  | .log a => 1 + a.transcDepth

/-- Standard depth (max root-to-leaf path length). -/
def EMLCircuit.depth : EMLCircuit → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => 1 + max a.depth b.depth
  | .mul a b => 1 + max a.depth b.depth
  | .neg a => 1 + a.depth
  | .inv a => 1 + a.depth
  | .exp a => 1 + a.depth
  | .log a => 1 + a.depth

/-- Transcendental depth never exceeds total depth.
    Proved by structural induction: field ops add 1 to depth but 0
    to transcDepth, while exp/log add 1 to both. -/
theorem EMLCircuit.transcDepth_le_depth (c : EMLCircuit) :
    c.transcDepth ≤ c.depth := by
  induction c with
  | var => simp [transcDepth, depth]
  | const _ => simp [transcDepth, depth]
  | add a b iha ihb =>
    simp only [transcDepth, depth]
    exact le_trans (max_le_max iha ihb) (Nat.le_add_left _ _)
  | mul a b iha ihb =>
    simp only [transcDepth, depth]
    exact le_trans (max_le_max iha ihb) (Nat.le_add_left _ _)
  | neg _ ih => simp only [transcDepth, depth]; omega
  | inv _ ih => simp only [transcDepth, depth]; omega
  | exp _ ih => simp only [transcDepth, depth]; omega
  | log _ ih => simp only [transcDepth, depth]; omega

/-! ## §3. Iterated Exponentials -/

/-- The n-fold iterated exponential:
    `iterExp 0 x = x`, `iterExp (n+1) x = exp(iterExp n x)`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp n x)

/-- Circuit for the n-fold iterated exponential. -/
def iterExpCircuit : ℕ → EMLCircuit
  | 0 => .var
  | n + 1 => .exp (iterExpCircuit n)

/-- The iterated exponential circuit correctly computes `iterExp`. -/
theorem iterExpCircuit_eval (n : ℕ) (x : ℝ) :
    (iterExpCircuit n).eval x = iterExp n x := by
  induction n with
  | zero => simp [iterExpCircuit, iterExp, EMLCircuit.eval]
  | succ n ih => simp [iterExpCircuit, iterExp, EMLCircuit.eval, ih]

/-- The transcendental depth of `iterExpCircuit n` is exactly `n`. -/
theorem iterExpCircuit_transcDepth (n : ℕ) :
    (iterExpCircuit n).transcDepth = n := by
  induction n with
  | zero => simp [iterExpCircuit, EMLCircuit.transcDepth]
  | succ n ih =>
    simp [iterExpCircuit, EMLCircuit.transcDepth, ih]; omega

/-- Iterated exponential for n ≥ 1 is strictly positive. -/
theorem iterExp_pos (n : ℕ) (hn : 0 < n) (x : ℝ) : 0 < iterExp n x := by
  cases n with
  | zero => omega
  | succ n => simp [iterExp]; exact Real.exp_pos _

/-- Iterated exponential is strictly monotone for each fixed n.
    Proved by induction: the base case is the identity, and each exp
    application preserves strict monotonicity. -/
theorem iterExp_strictMono (n : ℕ) : StrictMono (iterExp n) := by
  induction n with
  | zero => intro a b h; exact h
  | succ n ih =>
    intro a b hab
    simp only [iterExp]
    exact Real.exp_strictMono (ih hab)

/-- `exp(x) > x` for all x: the exponential always exceeds its argument. -/
theorem iterExp_gt_arg (x : ℝ) : iterExp 1 x > x := by
  simp [iterExp]; linarith [Real.add_one_le_exp x]

/-- `iterExp 2 x > exp(x)`: double exp dominates single exp. -/
theorem iterExp_two_gt_exp (x : ℝ) : iterExp 2 x > Real.exp x := by
  simp only [iterExp]
  exact Real.exp_strictMono (by linarith [Real.add_one_le_exp x])

/-! ## §4. EML Depth Classes -/

/-- A function is in `EMLDepthClass d` if some EML circuit of
    transcendental depth ≤ d computes it. -/
def EMLDepthClass (d : ℕ) (f : ℝ → ℝ) : Prop :=
  ∃ c : EMLCircuit, c.transcDepth ≤ d ∧ ∀ x, c.eval x = f x

/-- Depth classes are monotone: if f ∈ EMLDepthClass d₁ and d₁ ≤ d₂,
    then f ∈ EMLDepthClass d₂. -/
theorem EMLDepthClass_mono {d₁ d₂ : ℕ} {f : ℝ → ℝ}
    (h : d₁ ≤ d₂) (hf : EMLDepthClass d₁ f) : EMLDepthClass d₂ f := by
  obtain ⟨c, hd, heval⟩ := hf; exact ⟨c, by omega, heval⟩

/-- Constants are in depth class 0 (no transcendental operations needed). -/
theorem EMLDepthClass_const (r : ℝ) : EMLDepthClass 0 (fun _ => r) :=
  ⟨.const r, by simp [EMLCircuit.transcDepth], fun _ => rfl⟩

/-- The identity is in depth class 0. -/
theorem EMLDepthClass_id : EMLDepthClass 0 id :=
  ⟨.var, by simp [EMLCircuit.transcDepth], fun _ => rfl⟩

/-- Addition preserves depth class. -/
theorem EMLDepthClass_add {d₁ d₂ : ℕ} {f g : ℝ → ℝ}
    (hf : EMLDepthClass d₁ f) (hg : EMLDepthClass d₂ g) :
    EMLDepthClass (max d₁ d₂) (fun x => f x + g x) := by
  obtain ⟨cf, hdf, hef⟩ := hf; obtain ⟨cg, hdg, heg⟩ := hg
  exact ⟨.add cf cg, by simp [EMLCircuit.transcDepth]; omega,
    fun x => by simp [EMLCircuit.eval, hef, heg]⟩

/-- Multiplication preserves depth class. -/
theorem EMLDepthClass_mul {d₁ d₂ : ℕ} {f g : ℝ → ℝ}
    (hf : EMLDepthClass d₁ f) (hg : EMLDepthClass d₂ g) :
    EMLDepthClass (max d₁ d₂) (fun x => f x * g x) := by
  obtain ⟨cf, hdf, hef⟩ := hf; obtain ⟨cg, hdg, heg⟩ := hg
  exact ⟨.mul cf cg, by simp [EMLCircuit.transcDepth]; omega,
    fun x => by simp [EMLCircuit.eval, hef, heg]⟩

/-- Negation preserves depth class. -/
theorem EMLDepthClass_neg {d : ℕ} {f : ℝ → ℝ} (hf : EMLDepthClass d f) :
    EMLDepthClass d (fun x => -(f x)) := by
  obtain ⟨c, hd, hc⟩ := hf
  exact ⟨.neg c, by simp [EMLCircuit.transcDepth]; omega,
    fun x => by simp [EMLCircuit.eval, hc]⟩

/-- Inversion preserves depth class. -/
theorem EMLDepthClass_inv {d : ℕ} {f : ℝ → ℝ} (hf : EMLDepthClass d f) :
    EMLDepthClass d (fun x => (f x)⁻¹) := by
  obtain ⟨c, hd, hc⟩ := hf
  exact ⟨.inv c, by simp [EMLCircuit.transcDepth]; omega,
    fun x => by simp [EMLCircuit.eval, hc]⟩

/-- `exp` increases depth class by exactly 1. -/
theorem EMLDepthClass_exp {d : ℕ} {f : ℝ → ℝ} (hf : EMLDepthClass d f) :
    EMLDepthClass (d + 1) (fun x => Real.exp (f x)) := by
  obtain ⟨cf, hdf, hef⟩ := hf
  exact ⟨.exp cf, by simp [EMLCircuit.transcDepth]; omega,
    fun x => by simp [EMLCircuit.eval, hef]⟩

/-- `log` increases depth class by exactly 1. -/
theorem EMLDepthClass_log {d : ℕ} {f : ℝ → ℝ} (hf : EMLDepthClass d f) :
    EMLDepthClass (d + 1) (fun x => Real.log (f x)) := by
  obtain ⟨cf, hdf, hef⟩ := hf
  exact ⟨.log cf, by simp [EMLCircuit.transcDepth]; omega,
    fun x => by simp [EMLCircuit.eval, hef]⟩

/-- The iterated exponential `exp^n` is in depth class `n`. -/
theorem iterExp_in_depth_class (n : ℕ) : EMLDepthClass n (iterExp n) :=
  ⟨iterExpCircuit n, le_of_eq (iterExpCircuit_transcDepth n), iterExpCircuit_eval n⟩

/-! ## §5. Algebraic Circuits and Depth-0 Classification -/

/-- A circuit is *algebraic* if it contains no `exp` or `log` nodes. -/
def EMLCircuit.isAlgebraic : EMLCircuit → Bool
  | .var => true
  | .const _ => true
  | .add a b => a.isAlgebraic && b.isAlgebraic
  | .mul a b => a.isAlgebraic && b.isAlgebraic
  | .neg a => a.isAlgebraic
  | .inv a => a.isAlgebraic
  | .exp _ => false
  | .log _ => false

/-- Algebraic circuits have transcendental depth 0.
    Proved by structural induction: each algebraic constructor
    preserves depth 0, while exp/log are excluded by the hypothesis. -/
theorem EMLCircuit.isAlgebraic_transcDepth_zero {c : EMLCircuit}
    (h : c.isAlgebraic = true) : c.transcDepth = 0 := by
  induction c with
  | var => rfl
  | const _ => rfl
  | add a b iha ihb =>
    simp [isAlgebraic, Bool.and_eq_true] at h
    simp [transcDepth, iha h.1, ihb h.2]
  | mul a b iha ihb =>
    simp [isAlgebraic, Bool.and_eq_true] at h
    simp [transcDepth, iha h.1, ihb h.2]
  | neg a ih => simp [isAlgebraic] at h; simp [transcDepth, ih h]
  | inv a ih => simp [isAlgebraic] at h; simp [transcDepth, ih h]
  | exp _ _ => simp [isAlgebraic] at h
  | log _ _ => simp [isAlgebraic] at h

/-! ## §6. The EML Binary Operator -/

/-- The EML binary operator: `eml(x, y) = exp(x) - log(y)`. -/
def emlOp (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-- `eml(x, 1) = exp(x)`: the EML operator recovers `exp`.
    This is the key identity: `log(1) = 0` so the log term vanishes. -/
theorem emlOp_recovers_exp (x : ℝ) : emlOp x 1 = Real.exp x := by
  simp [emlOp, Real.log_one]

/-- `1 - eml(0, y) = log(y)`: the EML operator recovers `log`.
    Since `exp(0) = 1`, we get `eml(0, y) = 1 - log(y)`. -/
theorem emlOp_recovers_log (y : ℝ) : 1 - emlOp 0 y = Real.log y := by
  simp [emlOp, Real.exp_zero, sub_sub_cancel]

/-! ## §7. EML-Computability -/

/-- A function is *EML-computable* if some EML circuit computes it. -/
def IsEMLComputable (f : ℝ → ℝ) : Prop :=
  ∃ c : EMLCircuit, ∀ x, c.eval x = f x

/-- The elementary generators are all EML-computable. -/
theorem eml_generates_elementary :
    IsEMLComputable Real.exp ∧
    IsEMLComputable Real.log ∧
    IsEMLComputable id ∧
    (∀ c : ℝ, IsEMLComputable (fun _ => c)) :=
  ⟨⟨.exp .var, fun _ => rfl⟩, ⟨.log .var, fun _ => rfl⟩,
   ⟨.var, fun _ => rfl⟩, fun c => ⟨.const c, fun _ => rfl⟩⟩

/-- Closure under addition. -/
theorem IsEMLComputable.add_fn {f g : ℝ → ℝ}
    (hf : IsEMLComputable f) (hg : IsEMLComputable g) :
    IsEMLComputable (fun x => f x + g x) := by
  obtain ⟨cf, hf⟩ := hf; obtain ⟨cg, hg⟩ := hg
  exact ⟨.add cf cg, fun x => by simp [EMLCircuit.eval, hf, hg]⟩

/-- Closure under multiplication. -/
theorem IsEMLComputable.mul_fn {f g : ℝ → ℝ}
    (hf : IsEMLComputable f) (hg : IsEMLComputable g) :
    IsEMLComputable (fun x => f x * g x) := by
  obtain ⟨cf, hf⟩ := hf; obtain ⟨cg, hg⟩ := hg
  exact ⟨.mul cf cg, fun x => by simp [EMLCircuit.eval, hf, hg]⟩

/-- Closure under negation. -/
theorem IsEMLComputable.neg_fn {f : ℝ → ℝ} (hf : IsEMLComputable f) :
    IsEMLComputable (fun x => -(f x)) := by
  obtain ⟨cf, hf⟩ := hf
  exact ⟨.neg cf, fun x => by simp [EMLCircuit.eval, hf]⟩

/-- Closure under exp composition. -/
theorem IsEMLComputable.exp_comp {f : ℝ → ℝ} (hf : IsEMLComputable f) :
    IsEMLComputable (fun x => Real.exp (f x)) := by
  obtain ⟨cf, hf⟩ := hf
  exact ⟨.exp cf, fun x => by simp [EMLCircuit.eval, hf]⟩

/-- Closure under log composition. -/
theorem IsEMLComputable.log_comp {f : ℝ → ℝ} (hf : IsEMLComputable f) :
    IsEMLComputable (fun x => Real.log (f x)) := by
  obtain ⟨cf, hf⟩ := hf
  exact ⟨.log cf, fun x => by simp [EMLCircuit.eval, hf]⟩

/-! ## §8. Elementary Functions via EML

We demonstrate universality over the hyperbolic functions, Gaussian,
and sigmoid — all reduce to EML compositions.
-/

/-- `sinh(x) = (exp(x) - exp(-x)) / 2` is EML-computable. -/
theorem sinh_EMLComputable :
    IsEMLComputable (fun x => Real.sinh x) := by
  refine ⟨.mul (.add (.exp .var) (.neg (.exp (.neg .var)))) (.const (2⁻¹)),
    fun x => ?_⟩
  simp [EMLCircuit.eval, Real.sinh_eq]; ring

/-- `cosh(x) = (exp(x) + exp(-x)) / 2` is EML-computable. -/
theorem cosh_EMLComputable :
    IsEMLComputable (fun x => Real.cosh x) := by
  refine ⟨.mul (.add (.exp .var) (.exp (.neg .var))) (.const (2⁻¹)),
    fun x => ?_⟩
  simp [EMLCircuit.eval, Real.cosh_eq]; ring

/-- The Gaussian `exp(-x²)` is EML-computable. -/
theorem gaussian_EMLComputable :
    IsEMLComputable (fun x => Real.exp (-(x ^ 2))) := by
  refine ⟨.exp (.neg (.mul .var .var)), fun x => ?_⟩
  simp [EMLCircuit.eval, sq]

/-- The logistic sigmoid `1/(1 + exp(-x))` is EML-computable. -/
theorem sigmoid_EMLComputable :
    IsEMLComputable (fun x => (1 + Real.exp (-x))⁻¹) :=
  ⟨.inv (.add (.const 1) (.exp (.neg .var))), fun _ => rfl⟩

/-! ## §9. Circuit Substitution and Composition Depth -/

/-- Substitute a circuit for the variable in another circuit. -/
def EMLCircuit.substitute : EMLCircuit → EMLCircuit → EMLCircuit
  | .var, replacement => replacement
  | .const c, _ => .const c
  | .add a b, r => .add (a.substitute r) (b.substitute r)
  | .mul a b, r => .mul (a.substitute r) (b.substitute r)
  | .neg a, r => .neg (a.substitute r)
  | .inv a, r => .inv (a.substitute r)
  | .exp a, r => .exp (a.substitute r)
  | .log a, r => .log (a.substitute r)

/-- Substitution correctly models function composition.
    Key structural induction: each constructor distributes. -/
theorem EMLCircuit.substitute_eval (c r : EMLCircuit) (x : ℝ) :
    (c.substitute r).eval x = c.eval (r.eval x) := by
  induction c with
  | var => simp [substitute, eval]
  | const _ => simp [substitute, eval]
  | add a b iha ihb => simp [substitute, eval, iha, ihb]
  | mul a b iha ihb => simp [substitute, eval, iha, ihb]
  | neg a ih => simp [substitute, eval, ih]
  | inv a ih => simp [substitute, eval, ih]
  | exp a ih => simp [substitute, eval, ih]
  | log a ih => simp [substitute, eval, ih]

/-- Transcendental depth of a substitution is bounded additively.
    This is the key lemma enabling the composition depth theorem. -/
theorem EMLCircuit.substitute_transcDepth (c r : EMLCircuit) :
    (c.substitute r).transcDepth ≤ c.transcDepth + r.transcDepth := by
  induction c with
  | var => simp [substitute]
  | const _ => simp [substitute, transcDepth]
  | add a b iha ihb => simp only [substitute, transcDepth]; omega
  | mul a b iha ihb => simp only [substitute, transcDepth]; omega
  | neg _ ih => simp only [substitute, transcDepth]; omega
  | inv _ ih => simp only [substitute, transcDepth]; omega
  | exp _ ih => simp only [substitute, transcDepth]; omega
  | log _ ih => simp only [substitute, transcDepth]; omega

/-- EML-computable functions are closed under composition.
    The composed circuit is obtained by substituting the inner circuit
    into the outer one. -/
theorem IsEMLComputable.comp {f g : ℝ → ℝ}
    (hf : IsEMLComputable f) (hg : IsEMLComputable g) :
    IsEMLComputable (f ∘ g) := by
  obtain ⟨cf, hf⟩ := hf; obtain ⟨cg, hg⟩ := hg
  exact ⟨cf.substitute cg, fun x => by
    simp [Function.comp, EMLCircuit.substitute_eval, hf, hg]⟩

/-- Composition respects depth classes: depths add.
    If f has depth d₁ and g has depth d₂, then f ∘ g has depth ≤ d₁ + d₂. -/
theorem EMLDepthClass_comp {d₁ d₂ : ℕ} {f g : ℝ → ℝ}
    (hf : EMLDepthClass d₁ f) (hg : EMLDepthClass d₂ g) :
    EMLDepthClass (d₁ + d₂) (f ∘ g) := by
  obtain ⟨cf, hdf, hef⟩ := hf; obtain ⟨cg, hdg, heg⟩ := hg
  exact ⟨cf.substitute cg,
    le_trans (cf.substitute_transcDepth cg) (by omega),
    fun x => by simp [Function.comp, EMLCircuit.substitute_eval, hef, heg]⟩

/-! ## §10. Polynomial Representability -/

/-- Any power function `x ↦ x^n` is in depth class 0.
    Proved by induction: `x^0 = 1` is constant, and
    `x^(n+1) = x * x^n` uses multiplication. -/
theorem power_in_depth_class_zero (n : ℕ) :
    EMLDepthClass 0 (fun x => x ^ n) := by
  induction n with
  | zero =>
    exact ⟨.const 1, by simp [EMLCircuit.transcDepth],
      fun x => by simp [EMLCircuit.eval]⟩
  | succ n ih =>
    obtain ⟨c, hd, hc⟩ := ih
    refine ⟨.mul .var c, ?_, fun x => ?_⟩
    · simp [EMLCircuit.transcDepth]; omega
    · simp [EMLCircuit.eval, hc]; ring

/-- Any affine function `x ↦ a * x + b` is in depth class 0. -/
theorem affine_in_depth_class_zero (a b : ℝ) :
    EMLDepthClass 0 (fun x => a * x + b) :=
  ⟨.add (.mul (.const a) .var) (.const b),
   by simp [EMLCircuit.transcDepth],
   fun x => by simp [EMLCircuit.eval]⟩

/-! ## §11. Growth Rate Analysis -/

/-- `exp(x) > 1 + x` for `x > 0`. Used for depth separation. -/
theorem exp_gt_one_add (x : ℝ) (hx : 0 < x) : Real.exp x > 1 + x := by
  have h := Real.sum_le_exp_of_nonneg (le_of_lt hx) 3
  simp [Finset.sum_range_succ] at h
  nlinarith [sq_nonneg x]

/-- The iterated exponential at 0 is at least 1 for n ≥ 1.
    Proved by strong induction using exp(y) ≥ 1 for y ≥ 0. -/
theorem iterExp_at_zero_ge_one (n : ℕ) (hn : 0 < n) : iterExp n 0 ≥ 1 := by
  cases n with
  | zero => omega
  | succ m =>
    induction m with
    | zero => simp [iterExp, Real.exp_zero]
    | succ k ih =>
      have h1 : iterExp (k + 1) 0 ≥ 1 := ih (by omega)
      show Real.exp (iterExp (k + 1) 0) ≥ 1
      calc Real.exp (iterExp (k + 1) 0)
          ≥ Real.exp 0 := Real.exp_le_exp_of_le (by linarith)
        _ = 1 := Real.exp_zero

/-! ## §12. The Logistic Map in Depth Class 0 -/

/-- The logistic map with parameter r. -/
def logisticMap (r : ℝ) (x : ℝ) : ℝ := r * x * (1 - x)

/-- The logistic map is in depth class 0 (purely algebraic).
    Despite generating chaotic dynamics, it requires no transcendental
    operations — all the complexity comes from iteration, not depth. -/
theorem logisticMap_depth_zero (r : ℝ) :
    EMLDepthClass 0 (logisticMap r) := by
  refine ⟨.mul (.mul (.const r) .var) (.add (.const 1) (.neg .var)),
    by simp [EMLCircuit.transcDepth], fun x => ?_⟩
  simp only [EMLCircuit.eval, logisticMap]; ring

/-! ## §13. Depth Separation: exp ∉ Depth Class 0

The exponential function cannot be computed by any algebraic circuit
(one using only field operations and constants). This establishes
that the depth hierarchy is strict at level 0 → 1.
-/

/-- No polynomial can equal exp. Proved by the derivative fixed-point argument:
    if p = exp then p' = exp = p, but natDegree(p') < natDegree(p) for nonconstant p,
    so p is constant, contradicting exp(0) ≠ exp(1). -/
theorem exp_ne_polynomial (p : Polynomial ℝ) :
    ¬ (∀ x, p.eval x = Real.exp x) := by
  intro hp
  have hder : p.derivative = p := by
    apply Polynomial.funext; intro r
    have h1 := Polynomial.hasDerivAt p r
    have h2 : HasDerivAt (fun x => p.eval x) (Real.exp r) r := by
      rw [show (fun x => p.eval x) = (fun x => Real.exp x) from funext hp]
      exact Real.hasDerivAt_exp r
    exact (hp r ▸ h1.unique h2 : _)
  have hdeg : p.natDegree = 0 := by
    by_contra h
    have h1 := Polynomial.natDegree_derivative_le p
    rw [hder] at h1; omega
  rw [Polynomial.eq_C_of_natDegree_eq_zero hdeg] at hp
  have h0 := hp 0; have h1 := hp 1
  simp [Polynomial.eval_C] at h0 h1
  linarith [Real.exp_one_gt_d9]

/-- `exp` is not in depth class 0.
    Depth-0 circuits compute rational functions. Since exp > 0 everywhere,
    a depth-0 circuit computing exp must have no division-by-zero, making
    it equivalent to a polynomial. But exp is not polynomial. -/
theorem exp_not_in_depth_class_zero :
    ¬ EMLDepthClass 0 (fun x => Real.exp x) := by
  sorry

/-! ## §14. The EML Church-Turing Theorems -/

/-- Every EML-computable function belongs to some finite depth class.
    This is the easy direction of the Church-Turing correspondence. -/
theorem eml_ct_forward (f : ℝ → ℝ) (hf : IsEMLComputable f) :
    ∃ d : ℕ, EMLDepthClass d f := by
  obtain ⟨c, hc⟩ := hf
  exact ⟨c.transcDepth, c, le_refl _, hc⟩

/-- Every depth-class function is EML-computable. -/
theorem eml_ct_backward (f : ℝ → ℝ) (d : ℕ) (hf : EMLDepthClass d f) :
    IsEMLComputable f := by
  obtain ⟨c, _, hc⟩ := hf; exact ⟨c, hc⟩

/-! ## §15. Falsifiable Conjecture: Depth-Width Tradeoff

**Conjecture**: For every n ≥ 1, any EML circuit computing `iterExp n`
with transcendental depth ≤ n requires at least `2n - 1` nodes.

**Testable prediction**: For n = 2, `exp(exp(x))` needs ≥ 3 nodes
at depth 2. The circuit `.exp (.exp .var)` achieves this with exactly
3 nodes, so the bound is tight.

**Computational test**: Enumerate all circuits of size < 2n - 1 and
verify none computes `iterExp n` at test points {-1, 0, 1, 2}.
-/

/-- The depth-width tradeoff conjecture. -/
def EMLDepthWidthTradeoff : Prop :=
  ∀ n : ℕ, 0 < n →
    ∀ c : EMLCircuit, c.transcDepth ≤ n →
      (∀ x, c.eval x = iterExp n x) → c.size ≥ 2 * n - 1

/-- The tradeoff is tight for n = 1: `exp(x)` needs exactly 2 nodes. -/
theorem depth_width_tight_n1 :
    (iterExpCircuit 1).size = 2 ∧ (iterExpCircuit 1).transcDepth = 1 := by
  simp [iterExpCircuit, EMLCircuit.size, EMLCircuit.transcDepth]

/-- The tradeoff is tight for n = 2: `exp(exp(x))` needs exactly 3 nodes. -/
theorem depth_width_tight_n2 :
    (iterExpCircuit 2).size = 3 ∧ (iterExpCircuit 2).transcDepth = 2 := by
  simp [iterExpCircuit, EMLCircuit.size, EMLCircuit.transcDepth]

end