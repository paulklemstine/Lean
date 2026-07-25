import EML.SingleOperatorDefs

/-!
# EML Single Operator Universality: Closure Theorems

We prove that the class of EML-representable functions is closed under
all field operations and transcendental primitives (exp, log).

## Main results

- `EMLRepresentable.add`, `.mul`, `.neg`, `.sub`, `.inv`, `.div`:
  Closure under field operations
- `EMLRepresentable.exp_comp`, `.log_comp`: Closure under exp/log composition
- `EMLRepresentable.const`, `.var`: Constants and projections are representable

These theorems establish that EML-representable functions form a
field-like algebra closed under exponentiation and logarithm —
the algebraic foundation of the universality thesis.
-/

noncomputable section
open Real Set

/-! ## §1. Basic Representability -/

theorem EMLRepresentable.const {n : ℕ} (c : ℝ) :
    EMLRepresentable (n := n) (fun _ => c) :=
  ⟨.const c, fun _ => rfl⟩

theorem EMLRepresentable.var {n : ℕ} (i : Fin n) :
    EMLRepresentable (fun x : Fin n → ℝ => x i) := by
  refine ⟨.var i.val, fun x => ?_⟩
  simp [EMLExpr.eval, finToNat, i.isLt]

/-! ## §2. Field Operation Closure -/

/-- The EML-elementary class is closed under addition. -/
theorem EMLRepresentable.add {n : ℕ} {f g : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) (hg : EMLRepresentable g) :
    EMLRepresentable (fun x => f x + g x) := by
  obtain ⟨ef, hef⟩ := hf
  obtain ⟨eg, heg⟩ := hg
  exact ⟨.add ef eg, fun x => by simp [EMLExpr.eval, hef, heg]⟩

/-- The EML-elementary class is closed under multiplication. -/
theorem EMLRepresentable.mul {n : ℕ} {f g : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) (hg : EMLRepresentable g) :
    EMLRepresentable (fun x => f x * g x) := by
  obtain ⟨ef, hef⟩ := hf
  obtain ⟨eg, heg⟩ := hg
  exact ⟨.mul ef eg, fun x => by simp [EMLExpr.eval, hef, heg]⟩

/-- The EML-elementary class is closed under negation. -/
theorem EMLRepresentable.neg {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) :
    EMLRepresentable (fun x => -(f x)) := by
  obtain ⟨ef, hef⟩ := hf
  exact ⟨.neg ef, fun x => by simp [EMLExpr.eval, hef]⟩

/-- The EML-elementary class is closed under subtraction. -/
theorem EMLRepresentable.sub {n : ℕ} {f g : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) (hg : EMLRepresentable g) :
    EMLRepresentable (fun x => f x - g x) := by
  have : (fun x => f x - g x) = (fun x => f x + (-(g x))) := by ext; ring
  rw [this]
  exact hf.add hg.neg

/-- The EML-elementary class is closed under multiplicative inverse. -/
theorem EMLRepresentable.inv {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) :
    EMLRepresentable (fun x => (f x)⁻¹) := by
  obtain ⟨ef, hef⟩ := hf
  exact ⟨.inv ef, fun x => by simp [EMLExpr.eval, hef]⟩

/-- The EML-elementary class is closed under division. -/
theorem EMLRepresentable.div {n : ℕ} {f g : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) (hg : EMLRepresentable g) :
    EMLRepresentable (fun x => f x / g x) := by
  have : (fun x => f x / g x) = (fun x => f x * (g x)⁻¹) := by ext; ring
  rw [this]
  exact hf.mul hg.inv

/-! ## §3. Transcendental Closure -/

/-- The EML-elementary class is closed under exponentiation. -/
theorem EMLRepresentable.exp_comp {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) :
    EMLRepresentable (fun x => Real.exp (f x)) := by
  obtain ⟨ef, hef⟩ := hf
  exact ⟨.exp ef, fun x => by simp [EMLExpr.eval, hef]⟩

/-- The EML-elementary class is closed under logarithm. -/
theorem EMLRepresentable.log_comp {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) :
    EMLRepresentable (fun x => Real.log (f x)) := by
  obtain ⟨ef, hef⟩ := hf
  exact ⟨.log ef, fun x => by simp [EMLExpr.eval, hef]⟩

/-! ## §4. Derived Operations -/

/-- Scalar multiplication by a constant is representable. -/
theorem EMLRepresentable.const_mul {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (c : ℝ) (hf : EMLRepresentable f) :
    EMLRepresentable (fun x => c * f x) :=
  (EMLRepresentable.const c).mul hf

/-- Integer power of a representable function is representable. -/
theorem EMLRepresentable.pow {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : EMLRepresentable f) (k : ℕ) :
    EMLRepresentable (fun x => (f x) ^ k) := by
  induction k with
  | zero =>
    have : (fun x : Fin n → ℝ => (f x) ^ 0) = (fun _ => 1) := by ext; simp
    rw [this]; exact EMLRepresentable.const 1
  | succ k ih =>
    have : (fun x : Fin n → ℝ => (f x) ^ (k + 1)) = (fun x => f x * (f x) ^ k) := by
      ext; ring
    rw [this]; exact hf.mul ih

end