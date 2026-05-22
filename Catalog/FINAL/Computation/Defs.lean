import Mathlib

/-!
# Monotone Circuit Complexity: Definitions

This file provides the foundational definitions for the formal theory of monotone
Boolean circuit complexity and the Karchmer-Wigderson correspondence.

## Main Definitions

- `BitwiseLE` — pointwise ordering on Boolean vectors
- `MonotoneBool` — monotonicity of Boolean functions
- `MonoFormula` — monotone Boolean formulas (AND/OR trees, no negation)
- `KWProto` — certified Karchmer-Wigderson protocol trees

## References

* M. Karchmer, A. Wigderson, "Monotone circuits for connectivity require super-logarithmic
  depth", STOC 1988.
-/

noncomputable section
open Classical

namespace CircuitComplexity

/-! ## Bitwise Ordering -/

/-- Pointwise ordering on Boolean vectors: `x ≤ y` iff `x i = true → y i = true` for all `i`. -/
def BitwiseLE {n : ℕ} (x y : Fin n → Bool) : Prop :=
  ∀ i, x i = true → y i = true

theorem BitwiseLE.refl {n : ℕ} (x : Fin n → Bool) : BitwiseLE x x :=
  fun _ h => h

theorem BitwiseLE.trans {n : ℕ} {x y z : Fin n → Bool}
    (hxy : BitwiseLE x y) (hyz : BitwiseLE y z) : BitwiseLE x z :=
  fun i h => hyz i (hxy i h)

/-! ## Monotone Boolean Functions -/

/-- A Boolean function `f : (Fin n → Bool) → Bool` is **monotone** if it preserves
    the bitwise ordering: `x ≤ y → f x = true → f y = true`. -/
def MonotoneBool {n : ℕ} (f : (Fin n → Bool) → Bool) : Prop :=
  ∀ ⦃x y⦄, BitwiseLE x y → f x = true → f y = true

/-! ## Monotone Formulas -/

/-- A **monotone Boolean formula** over `n` variables.
    Built from variables, constants (`top`/`bot`), AND, and OR gates — no negation.
    This is a *formula* (tree), not a circuit (DAG). -/
inductive MonoFormula (n : ℕ) where
  | var : Fin n → MonoFormula n
  | top : MonoFormula n
  | bot : MonoFormula n
  | and : MonoFormula n → MonoFormula n → MonoFormula n
  | or  : MonoFormula n → MonoFormula n → MonoFormula n
  deriving Repr

namespace MonoFormula

/-- Evaluate a monotone formula on an input assignment. -/
def eval {n : ℕ} : MonoFormula n → (Fin n → Bool) → Bool
  | var i, x => x i
  | top, _ => true
  | bot, _ => false
  | and φ₁ φ₂, x => φ₁.eval x && φ₂.eval x
  | or φ₁ φ₂, x => φ₁.eval x || φ₂.eval x

/-- Depth (height) of a monotone formula tree. -/
def depth {n : ℕ} : MonoFormula n → ℕ
  | var _ => 0
  | top => 0
  | bot => 0
  | and φ₁ φ₂ => 1 + max φ₁.depth φ₂.depth
  | or φ₁ φ₂ => 1 + max φ₁.depth φ₂.depth

/-- Size (number of nodes) of a monotone formula tree. -/
def size {n : ℕ} : MonoFormula n → ℕ
  | var _ => 1
  | top => 1
  | bot => 1
  | and φ₁ φ₂ => 1 + φ₁.size + φ₂.size
  | or φ₁ φ₂ => 1 + φ₁.size + φ₂.size

/-
Every monotone formula computes a monotone Boolean function.
-/
theorem eval_monotone {n : ℕ} (φ : MonoFormula n) : MonotoneBool φ.eval := by
  intro x y hxy hx; induction' φ with φ₁ φ₂ ih₁ ih₂; aesop;
  · exact?;
  · cases hx;
  · simp_all +decide [ MonoFormula.eval ];
  · simp_all +decide [ MonoFormula.eval ];
    grind

end MonoFormula

/-! ## KW Witness Existence -/

/-
**KW witness existence**: For a monotone function `f`, if `f x = true` and `f y = false`,
    then there exists a **separating index** `i` with `x i = true` and `y i = false`.
    This is the fundamental fact that makes the Karchmer-Wigderson game well-defined.
-/
theorem exists_KW_witness {n : ℕ} {f : (Fin n → Bool) → Bool}
    (hf : MonotoneBool f) {x y : Fin n → Bool}
    (hx : f x = true) (hy : f y = false) :
    ∃ i : Fin n, x i = true ∧ y i = false := by
  contrapose! hy;
  exact hf ( fun i hi => by specialize hy i hi; aesop ) hx |> fun h => by aesop;

/-! ## Karchmer-Wigderson Protocol Trees -/

/-- A **certified Karchmer-Wigderson protocol tree**.

    This is the core data structure for the KW correspondence. The tree is indexed by
    predicates `PA` and `PB` describing the sets of valid Alice and Bob inputs at each node.

    - `leaf i hA hB`: a leaf outputting index `i`. The conditions `hA` and `hB` are
      guarded by nonemptiness of the opposite set, which makes vacuous protocols
      (for constant functions) constructible.
    - `alice q t_ff t_tt`: an Alice node where Alice evaluates `q(x)` and sends a bit.
    - `bob q t_ff t_tt`: a Bob node where Bob evaluates `q(y)` and sends a bit.
-/
inductive KWProto (n : ℕ) :
    ((Fin n → Bool) → Prop) → ((Fin n → Bool) → Prop) → Type 1 where
  | leaf (i : Fin n)
      (hA : (∃ y, PB y) → ∀ x, PA x → x i = true)
      (hB : (∃ x, PA x) → ∀ y, PB y → y i = false) :
      KWProto n PA PB
  | alice (q : (Fin n → Bool) → Bool)
      (t_ff : KWProto n (fun x => PA x ∧ q x = false) PB)
      (t_tt : KWProto n (fun x => PA x ∧ q x = true) PB) :
      KWProto n PA PB
  | bob (q : (Fin n → Bool) → Bool)
      (t_ff : KWProto n PA (fun y => PB y ∧ q y = false))
      (t_tt : KWProto n PA (fun y => PB y ∧ q y = true)) :
      KWProto n PA PB

namespace KWProto

/-- Communication cost (depth) of a KW protocol tree. -/
def cost : KWProto n PA PB → ℕ
  | leaf _ _ _ => 0
  | alice _ t₀ t₁ => 1 + max t₀.cost t₁.cost
  | bob _ t₀ t₁ => 1 + max t₀.cost t₁.cost

/-- Weaken the predicates of a KW protocol. If `PA' ⊆ PA` and `PB' ⊆ PB`, then a
    protocol for `(PA, PB)` can be adapted to `(PA', PB')`. -/
def weaken {PA PA' PB PB' : (Fin n → Bool) → Prop}
    (hA : ∀ x, PA' x → PA x) (hB : ∀ y, PB' y → PB y) :
    KWProto n PA PB → KWProto n PA' PB'
  | leaf i hA₀ hB₀ =>
      leaf i
        (fun ⟨y, hy⟩ x hx => hA₀ ⟨y, hB y hy⟩ x (hA x hx))
        (fun ⟨x, hx⟩ y hy => hB₀ ⟨x, hA x hx⟩ y (hB y hy))
  | alice q t₀ t₁ =>
      alice q
        (t₀.weaken (fun x ⟨h, hq⟩ => ⟨hA x h, hq⟩) hB)
        (t₁.weaken (fun x ⟨h, hq⟩ => ⟨hA x h, hq⟩) hB)
  | bob q t₀ t₁ =>
      bob q
        (t₀.weaken hA (fun y ⟨h, hq⟩ => ⟨hB y h, hq⟩))
        (t₁.weaken hA (fun y ⟨h, hq⟩ => ⟨hB y h, hq⟩))

/-
Weakening preserves cost.
-/
theorem weaken_cost {PA PA' PB PB' : (Fin n → Bool) → Prop}
    (hA : ∀ x, PA' x → PA x) (hB : ∀ y, PB' y → PB y)
    (T : KWProto n PA PB) :
    (T.weaken hA hB).cost = T.cost := by
  induction' T with PA PB T ih generalizing PA' PB';
  · rfl;
  · nontriviality;
    rename_i h₁ h₂ h₃ h₄;
    rw [ show ( weaken hA hB ( alice _ _ _ ) ) = alice _ ( weaken ( fun x hx => ⟨ hA x hx.1, hx.2 ⟩ ) hB _ ) ( weaken ( fun x hx => ⟨ hA x hx.1, hx.2 ⟩ ) hB _ ) from rfl ];
    simp +arith +decide [ KWProto.cost, h₂, h₃ ];
  · rename_i hA' hB' ih₁ ih₂;
    exact congr_arg₂ ( fun x y => 1 + Max.max x y ) ( ih₁ hA ( fun y hy => ⟨ hB y hy.1, hy.2 ⟩ ) ) ( ih₂ hA ( fun y hy => ⟨ hB y hy.1, hy.2 ⟩ ) )

end KWProto

/-- A KW protocol for a Boolean function `f` is a certified protocol tree where
    Alice's inputs are `f⁻¹(true)` and Bob's inputs are `f⁻¹(false)`. -/
abbrev KWProtocol (n : ℕ) (f : (Fin n → Bool) → Bool) :=
  KWProto n (fun x => f x = true) (fun y => f y = false)

end CircuitComplexity