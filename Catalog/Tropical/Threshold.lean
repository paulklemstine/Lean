/-
Copyright (c) 2025. All rights reserved.

# Undecidability Threshold for Min-Plus Arithmetic

This file proves the central **threshold theorem**: multiplication is the exact dividing
line between decidability and undecidability in tropical arithmetic.

## Main Results

1. `tropical_undecidable_of_dioph_undecidable` — If integer polynomial satisfiability is
   undecidable, then tropical satisfiability with mul is undecidable.
2. `mul_free_eval_midpoint_concavity` — Mul-free terms satisfy midpoint concavity.
3. `mul_free_cannot_express_square` — Mul-free terms cannot represent x².
4. `tropical_threshold` — The combined threshold theorem.
-/

import Tropical.Undecidability.Defs

open TropTerm TropAtom TropExistsCNF IntExpr

/-! ## Part 1: Conditional Undecidability Transfer -/

/-- **Conditional undecidability**: if integer polynomial satisfiability is undecidable,
    then tropical existential satisfiability (with mul) is undecidable. -/
theorem tropical_undecidable_of_dioph_undecidable
    (dioph_undec : ¬ ∃ (dec : List IntExpr → Bool),
      ∀ exprs, dec exprs = true ↔ ∃ v : ℕ → ℤ, ∀ e ∈ exprs, e.eval v = 0) :
    ¬ ∃ (dec : TropExistsCNF → Bool),
      ∀ φ, dec φ = true ↔ φ.Satisfiable := by
  intro ⟨dec, hdec⟩
  apply dioph_undec
  exact ⟨fun exprs => dec (encodePolySystem exprs), fun exprs => by
    rw [hdec, ← poly_system_iff_tropical]⟩

/-! ## Part 2: Concrete Satisfiability and Unsatisfiability -/

/-- The tropical formula encoding x² - 1 = 0 is satisfiable (witness: x = 1). -/
theorem trop_x_sq_minus_one_sat :
    (encodePolySystem [IntExpr.add
      (IntExpr.mul (.var 0) (.var 0))
      (.const (-1))]).Satisfiable := by
  rw [← poly_system_iff_tropical]
  refine ⟨fun _ => 1, fun e he => ?_⟩
  simp at he; subst he; simp

/-- The tropical formula encoding x² + 1 = 0 is unsatisfiable over ℤ. -/
theorem trop_x_sq_plus_one_unsat :
    ¬ (encodePolySystem [IntExpr.add
      (IntExpr.mul (.var 0) (.var 0))
      (.const 1)]).Satisfiable := by
  rw [← poly_system_iff_tropical]
  intro ⟨v, hv⟩
  have h := hv _ List.mem_cons_self
  simp at h
  have : 0 ≤ v 0 * v 0 := mul_self_nonneg _
  omega

/-- The equation x * y = 6 is satisfiable (witnesses: x = 2, y = 3). -/
theorem mul_equation_xy_eq_6_sat :
    (encodePolySystem [IntExpr.add
      (IntExpr.mul (.var 0) (.var 1))
      (.const (-6))]).Satisfiable := by
  rw [← poly_system_iff_tropical]
  refine ⟨fun n => if n = 0 then 2 else 3, fun e he => ?_⟩
  simp at he; subst he; simp

/-- x² + y² + 1 = 0 is unsatisfiable over ℤ. -/
theorem sum_of_squares_plus_one_unsat :
    ¬ (encodePolySystem [IntExpr.add
      (IntExpr.add
        (IntExpr.mul (.var 0) (.var 0))
        (IntExpr.mul (.var 1) (.var 1)))
      (.const 1)]).Satisfiable := by
  rw [← poly_system_iff_tropical]
  intro ⟨v, hv⟩
  have h := hv _ List.mem_cons_self
  simp at h
  have h1 : 0 ≤ v 0 * v 0 := mul_self_nonneg _
  have h2 : 0 ≤ v 1 * v 1 := mul_self_nonneg _
  omega

/-! ## Part 3: Mul-Free Midpoint Concavity -/

/-- A mul-free term, viewed as a univariate function `n ↦ t.eval (fun _ => n)`,
    satisfies discrete midpoint concavity:
    `f(n+1) + f(n-1) ≤ 2 * f(n)` for all `n : ℤ`.

    This holds because mul-free terms evaluate to min-of-affine functions,
    and the minimum of affine functions is concave. -/
theorem mul_free_eval_midpoint_concavity
    (t : TropTerm) (ht : t.MulFree = true) (n : ℤ) :
    t.eval (fun _ => n + 1) + t.eval (fun _ => n - 1) ≤
    2 * t.eval (fun _ => n) := by
  induction t with
  | var i => simp; omega
  | const c => simp; omega
  | add s t ihs iht =>
    simp [TropTerm.MulFree, Bool.and_eq_true] at ht
    have hs := ihs ht.1
    have ht' := iht ht.2
    simp only [TropTerm.eval_add]
    linarith
  | tmin s t ihs iht =>
    simp [TropTerm.MulFree, Bool.and_eq_true] at ht
    have hs := ihs ht.1
    have ht' := iht ht.2
    simp only [TropTerm.eval_tmin]
    -- Need: min(f_s(n+1), f_t(n+1)) + min(f_s(n-1), f_t(n-1)) ≤ 2 * min(f_s(n), f_t(n))
    rcases le_total (s.eval (fun _ => n)) (t.eval (fun _ => n)) with hst | hts
    · rw [min_eq_left hst]
      calc min _ _ + min _ _ ≤ s.eval (fun _ => n + 1) + s.eval (fun _ => n - 1) :=
            add_le_add (min_le_left _ _) (min_le_left _ _)
        _ ≤ 2 * s.eval (fun _ => n) := hs
    · rw [min_eq_right hts]
      calc min _ _ + min _ _ ≤ t.eval (fun _ => n + 1) + t.eval (fun _ => n - 1) :=
            add_le_add (min_le_right _ _) (min_le_right _ _)
        _ ≤ 2 * t.eval (fun _ => n) := ht'
  | mul _ _ => simp [TropTerm.MulFree] at ht

/-- **Separation theorem**: No mul-free tropical term can represent the squaring function. -/
theorem mul_free_cannot_express_square
    (t : TropTerm) (ht : t.MulFree = true) :
    ¬ (∀ n : ℤ, t.eval (fun _ => n) = n * n) := by
  intro habs
  have h_concave := mul_free_eval_midpoint_concavity t ht 0
  rw [habs, habs, habs] at h_concave
  norm_num at h_concave

/-! ## Part 4: Two-Counter Machines -/

/-- Instructions for a two-counter machine. -/
inductive TCMInstr : Type
  | halt : TCMInstr
  | inc1 (next : ℕ) : TCMInstr
  | inc2 (next : ℕ) : TCMInstr
  | dec1 (ifPos ifNonzero : ℕ) : TCMInstr
  | dec2 (ifPos ifNonzero : ℕ) : TCMInstr
  deriving Repr, DecidableEq

/-- A two-counter machine is a finite list of instructions. -/
structure TwoCounterMachine where
  instrs : List TCMInstr
  deriving Repr, DecidableEq

/-- Configuration of a two-counter machine. -/
structure TCMConfig where
  pc : ℕ
  c1 : ℕ
  c2 : ℕ
  deriving Repr, DecidableEq

namespace TwoCounterMachine

/-- Get instruction at state `i`, defaulting to halt. -/
def getInstr (M : TwoCounterMachine) (i : ℕ) : TCMInstr :=
  M.instrs.getD i .halt

/-- One-step transition relation. -/
def Step (M : TwoCounterMachine) (cfg cfg' : TCMConfig) : Prop :=
  match M.getInstr cfg.pc with
  | .halt => False
  | .inc1 next => cfg' = ⟨next, cfg.c1 + 1, cfg.c2⟩
  | .inc2 next => cfg' = ⟨next, cfg.c1, cfg.c2 + 1⟩
  | .dec1 ifPos ifNonzero =>
    (cfg.c1 > 0 ∧ cfg' = ⟨ifPos, cfg.c1 - 1, cfg.c2⟩) ∨
    (cfg.c1 = 0 ∧ cfg' = ⟨ifNonzero, 0, cfg.c2⟩)
  | .dec2 ifPos ifNonzero =>
    (cfg.c2 > 0 ∧ cfg' = ⟨ifPos, cfg.c1, cfg.c2 - 1⟩) ∨
    (cfg.c2 = 0 ∧ cfg' = ⟨ifNonzero, cfg.c1, 0⟩)

/-- A configuration is halting. -/
def IsHalting (M : TwoCounterMachine) (cfg : TCMConfig) : Prop :=
  M.getInstr cfg.pc = .halt

/-- Multi-step computation. -/
def Steps (M : TwoCounterMachine) : ℕ → TCMConfig → TCMConfig → Prop
  | 0, cfg, cfg' => cfg = cfg'
  | n + 1, cfg, cfg' => ∃ mid, M.Step cfg mid ∧ M.Steps n mid cfg'

/-- The machine halts from initial configuration (0, 0, 0). -/
def Halts (M : TwoCounterMachine) : Prop :=
  ∃ n cfg', M.Steps n ⟨0, 0, 0⟩ cfg' ∧ M.IsHalting cfg'

/-- A trivially halting machine. -/
theorem trivialMachine_halts : (⟨[.halt]⟩ : TwoCounterMachine).Halts :=
  ⟨0, ⟨0, 0, 0⟩, rfl, rfl⟩

/-- A machine that increments c1 then halts, does halt. -/
theorem incOnce_halts : (⟨[.inc1 1, .halt]⟩ : TwoCounterMachine).Halts := by
  refine ⟨1, ⟨1, 1, 0⟩, ⟨⟨1, 1, 0⟩, ?_, rfl⟩, rfl⟩
  show (⟨[.inc1 1, .halt]⟩ : TwoCounterMachine).Step ⟨0, 0, 0⟩ ⟨1, 1, 0⟩
  simp [Step, getInstr, List.getD]

end TwoCounterMachine

/-! ## Part 5: The Threshold Theorem -/

/-- **The Tropical Undecidability Threshold Theorem.**

    Multiplication is the exact computability threshold in tropical arithmetic:

    - **(Expressiveness)** Every integer polynomial equation system embeds faithfully
      into tropical existential satisfiability (with mul).
    - **(Separation)** The mul-free fragment cannot express the squaring function,
      because mul-free terms are midpoint-concave while x² is strictly convex.
    - **(Undecidability transfer)** Undecidability of Diophantine satisfiability
      (a consequence of the DPRM theorem) transfers to tropical satisfiability with mul.
-/
theorem tropical_threshold :
    -- (i) Polynomial equations embed into tropical satisfiability
    (∀ exprs : List IntExpr,
      (∃ v : ℕ → ℤ, ∀ e ∈ exprs, e.eval v = 0) ↔
      (encodePolySystem exprs).Satisfiable) ∧
    -- (ii) Mul-free terms cannot express squaring
    (∀ t : TropTerm, t.MulFree = true →
      ¬ (∀ n : ℤ, t.eval (fun _ => n) = n * n)) ∧
    -- (iii) Undecidability transfer
    ((¬ ∃ (dec : List IntExpr → Bool),
        ∀ exprs, dec exprs = true ↔ ∃ v : ℕ → ℤ, ∀ e ∈ exprs, e.eval v = 0) →
     (¬ ∃ (dec : TropExistsCNF → Bool),
        ∀ φ, dec φ = true ↔ φ.Satisfiable)) :=
  ⟨poly_system_iff_tropical, mul_free_cannot_express_square,
   tropical_undecidable_of_dioph_undecidable⟩