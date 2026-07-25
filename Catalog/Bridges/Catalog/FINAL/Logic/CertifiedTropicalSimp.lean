import Mathlib

/-!
# Certified Tropical Normalization

This file defines a reified syntax for tropical (min-plus) expressions,
an evaluator, a normalization procedure, and proves soundness: normalization
preserves semantics. This yields a certified `tropical_simp` reflection
principle: two tropical expressions are semantically equal whenever their
normal forms coincide.

## Main Results

* `TropExpr.toNF_sound` — conversion to normal form preserves evaluation
* `tropical_simp_sound` — syntactic NF equality implies semantic equality
* `tropical_add_distrib_min` — a + min b c = min (a+b) (a+c)

## Mathematical Content

A tropical expression over variables from `α` is built from:
- variables `var a`
- constants `const c`
- tropical addition `tadd e₁ e₂` (interpreted as ordinary addition on ℕ)
- tropical minimum `tmin e₁ e₂` (interpreted as `min`)

The **normal form** is a list of "monomials" (lists of base expressions
to be summed). The full NF evaluates to the minimum over all monomial sums.
Normalization distributes addition over minimum to produce this canonical
"min-of-sums" form.
-/

/-! ## Syntax -/

/-- Reified syntax for tropical (min-plus) expressions. -/
inductive TropExpr (α : Type)
  | var : α → TropExpr α
  | const : ℕ → TropExpr α
  | tadd : TropExpr α → TropExpr α → TropExpr α
  | tmin : TropExpr α → TropExpr α → TropExpr α
  deriving Repr, BEq

/-! ## Evaluator -/

/-- Evaluate a tropical expression under valuation `σ`.
    `tadd` is ordinary addition; `tmin` is `min`. -/
def TropExpr.eval {α : Type} (σ : α → ℕ) : TropExpr α → ℕ
  | .var a => σ a
  | .const c => c
  | .tadd e₁ e₂ => e₁.eval σ + e₂.eval σ
  | .tmin e₁ e₂ => min (e₁.eval σ) (e₂.eval σ)

/-! ## Normal Form: Min-of-Sums representation -/

/-- A monomial is a list of base expressions to be summed. -/
abbrev TropMonomial (α : Type) := List (TropExpr α)

/-- A normal form is a list of monomials; semantics = min over sums. -/
abbrev TropNF (α : Type) := List (TropMonomial α)

/-- Evaluate a monomial: sum of evaluations. -/
def evalMonomial {α : Type} (σ : α → ℕ) : TropMonomial α → ℕ
  | [] => 0
  | e :: es => e.eval σ + evalMonomial σ es

/-- Evaluate a normal form: minimum over monomial evaluations.
    Empty normal form evaluates to 0. -/
def evalNF {α : Type} (σ : α → ℕ) : TropNF α → ℕ
  | [] => 0
  | [m] => evalMonomial σ m
  | m :: ms => min (evalMonomial σ m) (evalNF σ ms)

/-- Convert an expression to min-of-sums normal form. -/
def TropExpr.toNF {α : Type} : TropExpr α → TropNF α
  | .var a => [[.var a]]
  | .const c => [[.const c]]
  | .tmin e₁ e₂ => e₁.toNF ++ e₂.toNF
  | .tadd e₁ e₂ =>
    let nf1 := e₁.toNF
    let nf2 := e₂.toNF
    (nf1.map (fun m1 => nf2.map (fun m2 => m1 ++ m2))).flatten

/-! ## Soundness Lemmas -/

theorem evalMonomial_append {α : Type} (σ : α → ℕ) (m1 m2 : TropMonomial α) :
    evalMonomial σ (m1 ++ m2) = evalMonomial σ m1 + evalMonomial σ m2 := by
  induction m1 with
  | nil => simp [evalMonomial]
  | cons e es ih => simp [evalMonomial, ih, Nat.add_assoc]

theorem evalNF_singleton {α : Type} (σ : α → ℕ) (m : TropMonomial α) :
    evalNF σ [m] = evalMonomial σ m := by
  simp [evalNF]

/-
Every toNF produces a non-empty list.
-/
theorem TropExpr.toNF_ne_nil {α : Type} : ∀ e : TropExpr α, e.toNF ≠ [] := by
  intro e;
  induction e <;> simp +decide [ *, TropExpr.toNF ];
  exact List.length_pos_iff_exists_mem.mp ( List.length_pos_iff.mpr ‹_› )

/-
Appending two non-empty NFs evaluates as min.
-/
theorem evalNF_append {α : Type} (σ : α → ℕ) (nf1 nf2 : TropNF α)
    (h1 : nf1 ≠ []) (h2 : nf2 ≠ []) :
    evalNF σ (nf1 ++ nf2) = min (evalNF σ nf1) (evalNF σ nf2) := by
  induction' nf1 with m ms ih generalizing nf2 <;> simp +decide [ * ];
  · contradiction;
  · cases ms <;> cases nf2 <;> simp_all +decide [ evalNF ]

/-
The bind-map operation preserves semantics for tadd.
-/
theorem evalNF_bind_map {α : Type} (σ : α → ℕ) (nf1 nf2 : TropNF α)
    (h1 : nf1 ≠ []) (h2 : nf2 ≠ []) :
    evalNF σ ((nf1.map (fun m1 => nf2.map (fun m2 => m1 ++ m2))).flatten) =
    evalNF σ nf1 + evalNF σ nf2 := by
  -- We'll use induction on `nf1` to prove the equality.
  induction' nf1 with m1 ms ih;
  · contradiction;
  · rcases ms with ( _ | ⟨ m2, ms ⟩ ) <;> simp_all +decide [ evalNF_append ];
    · induction' nf2 with m2 ms ih;
      · contradiction;
      · cases ms <;> simp_all +decide [ List.map ];
        · exact evalMonomial_append σ m1 m2;
        · simp_all +decide [ evalNF ];
          rw [ evalMonomial_append ] ; omega;
    · -- By definition of `evalNF`, we can expand both sides.
      have h_expand : evalNF σ (List.map (fun m2 => m1 ++ m2) nf2) = evalMonomial σ m1 + evalNF σ nf2 := by
        have h_expand : ∀ (nf : TropNF α), nf ≠ [] → evalNF σ (List.map (fun m2 => m1 ++ m2) nf) = evalMonomial σ m1 + evalNF σ nf := by
          intros nf hnf_nonempty
          induction' nf with m nf ih;
          · contradiction;
          · cases nf <;> simp_all +decide [ evalNF_append ];
            · exact evalMonomial_append σ m1 m;
            · simp_all +decide [ evalNF ];
              rw [ evalMonomial_append ] ; omega;
        exact h_expand nf2 h2
      simp_all +decide [ evalNF ]

/-
**Main soundness theorem**: converting to NF preserves semantics.
-/
theorem TropExpr.toNF_sound {α : Type} (σ : α → ℕ) :
    ∀ e : TropExpr α, evalNF σ e.toNF = e.eval σ := by
  -- By induction on the structure of e.
  intro e
  induction' e with e₁ e₂ ih₁ ih₂;
  · exact?;
  · rfl;
  · convert evalNF_bind_map σ ih₁.toNF ih₂.toNF ( TropExpr.toNF_ne_nil ih₁ ) ( TropExpr.toNF_ne_nil ih₂ ) using 1;
    aesop;
  · rename_i e₁ e₂ ih₁ ih₂;
    convert evalNF_append σ e₁.toNF e₂.toNF ( TropExpr.toNF_ne_nil e₁ ) ( TropExpr.toNF_ne_nil e₂ ) using 1;
    exact ih₁.symm ▸ ih₂.symm ▸ rfl

/-- **Certified reflection principle**: if two tropical expressions produce
    the same normal form, they evaluate identically under all valuations. -/
theorem tropical_simp_sound
    {α : Type} (σ : α → ℕ) (e₁ e₂ : TropExpr α)
    (h : e₁.toNF = e₂.toNF) :
    TropExpr.eval σ e₁ = TropExpr.eval σ e₂ := by
  have h1 := TropExpr.toNF_sound σ e₁
  have h2 := TropExpr.toNF_sound σ e₂
  rw [← h1, ← h2, h]

/-! ## Tropical Algebra Identities -/

/-- Tropical addition distributes over min — the fundamental tropical algebra identity. -/
theorem tropical_add_distrib_min (a b c : ℕ) :
    a + min b c = min (a + b) (a + c) := by omega

/-- Right-distributivity variant. -/
theorem tropical_add_distrib_min_right (a b c : ℕ) :
    min a b + c = min (a + c) (b + c) := by omega

/-- Min is idempotent. -/
theorem tropical_min_idem (a : ℕ) : min a a = a := by omega

/-- Min-plus associativity: min distributes through sums. -/
theorem tropical_double_distrib (a b c d : ℕ) :
    min a b + min c d = min (min (a + c) (a + d)) (min (b + c) (b + d)) := by omega

/-! ## Tactic: tropical_simp -/

/-- The `tropical_simp` tactic normalizes goals involving `min` and `+` on `ℕ`
    by distributing addition over min and simplifying. -/
macro "tropical_simp" : tactic =>
  `(tactic| simp only [Nat.add_min_add_left, Nat.add_min_add_right,
     Nat.min_self, Nat.min_comm, Nat.min_assoc,
     Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] <;> omega)

/-- Demo: tropical_simp solves distributivity automatically. -/
example (a b c : ℕ) : a + min b c = min (a + b) (a + c) := by tropical_simp

/-- Demo: tropical_simp solves nested tropical expressions. -/
example (a b c d : ℕ) : min (a + b) (a + c) + d = min (a + b + d) (a + c + d) := by tropical_simp

/-- Demo: double distribution. -/
example (a b c d : ℕ) :
    min a b + min c d = min (min (a + c) (a + d)) (min (b + c) (b + d)) := by
  tropical_simp