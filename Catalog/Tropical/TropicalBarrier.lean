/-
# Tropical Semiring Barrier Theorems

This file formalizes a structural barrier showing that tropical (min-plus)
expressions cannot represent non-monotone Boolean predicates such as parity.

## Main results

* `tropical_expr_monotone` — Every tropical expression computes a monotone
  function with respect to the pointwise order on ℕ-valued assignments.
* `no_monotone_tropical_represents_parity` — Parity on n ≥ 2 variables
  cannot be exactly computed by any tropical expression under Boolean encoding.
* `not_trop_representable_of_nonmonotone` — General barrier: no non-monotone
  Boolean function is tropically representable.

## Mathematical significance

These results formalize a **complexity barrier**: the min-plus (tropical)
semiring, which underlies dynamic programming and shortest-path algorithms,
is fundamentally limited in its ability to compute predicates that require
alternation or non-monotonicity. This is a tropical analogue of classical
monotone circuit lower bounds (Razborov, Alon–Boppana).
-/

import Mathlib

/-! ## Tropical Expression Language -/

/-- A tropical expression over `n` variables, built from natural number
constants, variable references, tropical addition (`min`), and tropical
multiplication (`+`). -/
inductive TropExpr (n : ℕ) : Type where
  | const : ℕ → TropExpr n
  | var   : Fin n → TropExpr n
  | tmin  : TropExpr n → TropExpr n → TropExpr n
  | tadd  : TropExpr n → TropExpr n → TropExpr n
  deriving Repr, DecidableEq

namespace TropExpr

/-- Evaluate a tropical expression given a variable assignment `v : Fin n → ℕ`. -/
def eval : TropExpr n → (Fin n → ℕ) → ℕ
  | const c, _  => c
  | var i, v    => v i
  | tmin e₁ e₂, v => min (eval e₁ v) (eval e₂ v)
  | tadd e₁ e₂, v => eval e₁ v + eval e₂ v

/-- The size of a tropical expression (number of nodes). -/
def size : TropExpr n → ℕ
  | const _ => 1
  | var _ => 1
  | tmin e₁ e₂ => 1 + size e₁ + size e₂
  | tadd e₁ e₂ => 1 + size e₁ + size e₂

/-! ## Monotonicity Theorem -/

/-
Every tropical expression computes a monotone function: if `u ≤ v`
pointwise, then `eval e u ≤ eval e v`. This is the fundamental structural
property that creates the barrier.
-/
theorem eval_monotone (e : TropExpr n) {u v : Fin n → ℕ}
    (huv : ∀ i, u i ≤ v i) : eval e u ≤ eval e v := by
  -- We proceed by induction on the structure of the tropical expression `e`.
  induction' e with e₁ e₂ ih₁ ih₂;
  · rfl;
  · exact huv _;
  · exact min_le_min ‹_› ‹_›;
  · exact Nat.add_le_add ‹_› ‹_›

/-
`eval e` is monotone as a function `(Fin n → ℕ) → ℕ` with respect to
the pointwise partial order.
-/
theorem tropical_expr_monotone (e : TropExpr n) :
    Monotone (fun v : Fin n → ℕ => eval e v) := by
  exact fun u v huv => eval_monotone e fun i => huv i

end TropExpr

/-! ## Boolean Encoding -/

/-- Encode a Boolean as a tropical (natural number) value:
`true ↦ 0`, `false ↦ 1`. Under this encoding, the natural order
`0 ≤ 1` corresponds to `true ≥ false` in the Boolean truth order. -/
def boolEnc : Bool → ℕ
  | true  => 0
  | false => 1

/-- Lift a Boolean assignment to a natural number assignment via `boolEnc`. -/
def liftBool (v : Fin n → Bool) : Fin n → ℕ := fun i => boolEnc (v i)

/-! ## Parity Function -/

/-- The parity function on Boolean assignments, encoded tropically:
returns `0` if the number of `true` values is odd, `1` otherwise. -/
def parityFun (v : Fin n → Bool) : ℕ :=
  if Odd (Finset.univ.sum fun i => (v i).toNat) then 0 else 1

/-! ## Non-Monotonicity of Parity -/

/-
Helper: parity is not monotone for n ≥ 2. We exhibit concrete
assignments witnessing non-monotonicity.
-/
theorem parity_not_monotone_aux (n : ℕ) (hn : 2 ≤ n) :
    ∃ u v : Fin n → Bool,
      (∀ i, boolEnc (u i) ≤ boolEnc (v i)) ∧
      ¬ (parityFun u ≤ parityFun v) := by
  -- Let's choose the specific assignments $u$ and $v$ given in the provided solution.
  use fun i => if i.val < 2 then true else false, fun i => if i.val < 1 then true else false;
  rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ Fin.forall_fin_succ, parityFun ] at *;
  split_ifs <;> simp_all +decide [ Fin.sum_univ_succ ]

/-! ## Main Barrier Theorems -/

/-- Tropical representability: a function `f : (Fin n → Bool) → ℕ` is
tropically representable if there exists a tropical expression that
computes `f` under Boolean encoding. -/
def TropRepresentable (f : (Fin n → Bool) → ℕ) : Prop :=
  ∃ e : TropExpr n, ∀ v : Fin n → Bool,
    TropExpr.eval e (liftBool v) = f v

/-
**Monotonicity barrier for parity.** No tropical expression can exactly
compute the parity function on n ≥ 2 variables.
-/
theorem no_monotone_tropical_represents_parity (n : ℕ) (hn : 2 ≤ n) :
    ¬ TropRepresentable (parityFun (n := n)) := by
  -- Assume for contradiction that there exists a tropical expression `e` that exactly computes the parity function.
  by_contra h
  obtain ⟨e, he⟩ := h;
  -- By definition of `parityFun`, we know that `parityFun u = 1` if `u` has an even number of true values and `parityFun u = 0` if `u` has an odd number of true values.
  obtain ⟨u, v, huv, hparity⟩ := parity_not_monotone_aux n hn;
  exact hparity <| by simpa [ ← he ] using TropExpr.eval_monotone e huv;

/-- A Boolean function is monotone under the tropical encoding if increasing
the encoded assignment (pointwise) does not decrease the function value. -/
def TropMonotone (f : (Fin n → Bool) → ℕ) : Prop :=
  ∀ u v : Fin n → Bool,
    (∀ i, boolEnc (u i) ≤ boolEnc (v i)) → f u ≤ f v

/-
**General barrier theorem.** If a Boolean function `f` is not monotone
under the tropical encoding, then `f` is not tropically representable.
-/
theorem not_trop_representable_of_nonmonotone {n : ℕ}
    (f : (Fin n → Bool) → ℕ)
    (hf : ¬ TropMonotone f) :
    ¬ TropRepresentable f := by
  rintro ⟨ e, he ⟩;
  exact hf fun u v huv => by simpa [ ← he ] using TropExpr.eval_monotone e huv;

/-! ## Application: XOR on two variables -/

/-- XOR on two variables: returns `0` if exactly one input is `true`. -/
def xorFun (v : Fin 2 → Bool) : ℕ :=
  boolEnc (xor (v 0) (v 1))

/-
XOR is not monotone under tropical encoding.
-/
theorem xor_not_trop_monotone : ¬ TropMonotone xorFun := by
  -- By definition of $TropMonotone$, we need to show that for any $u, v : Fin 2 → Bool$, if $u ≤ v$, then $xorFun u ≤ xorFun v$.
  unfold TropMonotone;
  decide +revert

/-
XOR on two variables is not tropically representable.
-/
theorem xor_not_trop_representable : ¬ TropRepresentable xorFun := by
  -- Apply the theorem that if a function is not monotone under the tropical encoding, then it is not tropically representable.
  exact not_trop_representable_of_nonmonotone _ xor_not_trop_monotone

/-! ## Application: Exact-One predicate -/

/-- The exact-one predicate: returns `0` iff exactly one variable is `true`. -/
def exactOneFun (v : Fin n → Bool) : ℕ :=
  if (Finset.univ.sum fun i => (v i).toNat) = 1 then 0 else 1

/-
Exact-one is not monotone for n ≥ 2.
-/
theorem exactOne_not_trop_monotone (n : ℕ) (hn : 2 ≤ n) :
    ¬ TropMonotone (exactOneFun (n := n)) := by
  intro h_monotone; contrapose! hn;
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ TropMonotone ];
  specialize h_monotone ( fun i => if i.val < 2 then Bool.true else Bool.false ) ( fun i => if i.val < 1 then Bool.true else Bool.false ) ; simp_all +decide [ Fin.forall_fin_succ ];
  unfold exactOneFun at h_monotone; simp_all +arith +decide [ Fin.sum_univ_succ ] ;

/-
Exact-one is not tropically representable for n ≥ 2.
-/
theorem exactOne_not_trop_representable (n : ℕ) (hn : 2 ≤ n) :
    ¬ TropRepresentable (exactOneFun (n := n)) := by
  exact not_trop_representable_of_nonmonotone _ ( exactOne_not_trop_monotone n hn )