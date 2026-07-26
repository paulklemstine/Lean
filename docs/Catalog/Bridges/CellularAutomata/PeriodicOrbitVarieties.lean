/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Periodic Orbit Varieties of Elementary Cellular Automata

This file extends the algebraic-geometric study of elementary cellular automata (ECAs)
from fixed points to k-periodic orbits. The central result is that periodic orbit sets
of linear ECAs form linear codes over GF(2), generalizing the Linear Code Theorem
from fixed points to all periodic orbits.

## Main Definitions

* `ECA.IsPeriodicPoint` — A state is k-periodic if F^k(s) = s
* `ECA.periodicPointSet` — The set of all k-periodic points
* `ECA.PeriodicOrbitCode` — The linear code structure on periodic orbits of linear rules

## Main Results

* `ECA.periodic_xor_closed` — Periodic points of linear ECAs are closed under XOR
* `ECA.iterate_add` — F^(j+k) = F^j ∘ F^k (iteration is additive)
* `ECA.periodic_mul_periodic` — k-periodic points are also (mk)-periodic
* `ECA.fixed_implies_periodic` — Fixed points are k-periodic for all k
* `ECA.zero_periodic_linear` — Zero state is k-periodic for all linear rules
* `ECA.periodic_set_monotone` — Period hierarchy under divisibility
* `ECA.periodic_code_dimension_bound` — Code dimension bounded by n

## References

* Wolfram, "A New Kind of Science" (2002)
* Cattaneo et al., "Solution of some conjectures about topological properties of
  linear cellular automata" (2004)
-/

import Mathlib

open Finset Function

namespace ECA

/-! ### Local Rule and Global Step -/

/-- The local update function for ECA rule `r`. -/
def localRule (r : ℕ) (left center right : Bool) : Bool :=
  r.testBit ((if left then 4 else 0) + (if center then 2 else 0) + (if right then 1 else 0))

/-- Global ECA update function on a cyclic array of n cells. -/
def step (r : ℕ) {n : ℕ} (hn : 0 < n) (s : Fin n → Bool) : Fin n → Bool := fun i =>
  localRule r
    (s ⟨(i.val + n - 1) % n, Nat.mod_lt _ hn⟩)
    (s i)
    (s ⟨(i.val + 1) % n, Nat.mod_lt _ hn⟩)

/-- A state is a fixed point of rule r. -/
def IsFixedPoint (r : ℕ) {n : ℕ} (hn : 0 < n) (s : Fin n → Bool) : Prop :=
  step r hn s = s

/-- Iterated application of the ECA rule. -/
def iterate (r : ℕ) {n : ℕ} (hn : 0 < n) : ℕ → (Fin n → Bool) → (Fin n → Bool)
  | 0 => id
  | k + 1 => step r hn ∘ iterate r hn k

/-- An ECA rule is *linear* over GF(2). -/
def IsLinearRule (r : ℕ) : Prop :=
  localRule r false false false = false ∧
  ∀ l₁ c₁ r₁ l₂ c₂ r₂ : Bool,
    localRule r (xor l₁ l₂) (xor c₁ c₂) (xor r₁ r₂) =
    xor (localRule r l₁ c₁ r₁) (localRule r l₂ c₂ r₂)

/-- XOR of two states (pointwise). -/
def stateXor {n : ℕ} (s t : Fin n → Bool) : Fin n → Bool := fun i => xor (s i) (t i)

/-- The all-zero state. -/
def zeroState (n : ℕ) : Fin n → Bool := fun _ => false

/-! ## Part I: Periodic Points — Core Definitions -/

/-- A state `s` is *k-periodic* under rule `r` if applying the rule `k` times
    returns to `s`. This generalizes `IsFixedPoint` (which is the k=1 case). -/
def IsPeriodicPoint (r : ℕ) {n : ℕ} (hn : 0 < n) (k : ℕ) (s : Fin n → Bool) : Prop :=
  iterate r hn k s = s

/-- The set of all k-periodic points. -/
def periodicPointSet (r : ℕ) {n : ℕ} (hn : 0 < n) (k : ℕ) : Set (Fin n → Bool) :=
  {s | IsPeriodicPoint r hn k s}

/-! ## Part II: Iteration Composition -/

/-
Iteration is additive: F^(j+k) = F^j ∘ F^k.
-/
theorem iterate_add (r : ℕ) {n : ℕ} (hn : 0 < n) (j k : ℕ) (s : Fin n → Bool) :
    iterate r hn (j + k) s = iterate r hn j (iterate r hn k s) := by
  induction' j with j ih generalizing s;
  · aesop;
  · convert congr_arg ( step r hn ) ( ih s ) using 1;
    simp +arith +decide [ *, ECA.iterate ]

/-
A fixed point is invariant under iteration.
-/
theorem fixed_point_iterate {r : ℕ} {n : ℕ} {hn : 0 < n} {s : Fin n → Bool}
    (hfp : IsFixedPoint r hn s) (k : ℕ) :
    iterate r hn k s = s := by
  induction' k with k ih;
  · rfl;
  · rw [ show iterate r hn ( k + 1 ) s = step r hn ( iterate r hn k s ) by rfl, ih, hfp ]

/-! ## Part III: Period Divisibility -/

/-- Every state is trivially 0-periodic (F^0 = id). -/
theorem zero_periodic (r : ℕ) {n : ℕ} (hn : 0 < n) (s : Fin n → Bool) :
    IsPeriodicPoint r hn 0 s := rfl

/-
Fixed points are exactly the 1-periodic points.
-/
theorem fixed_iff_one_periodic (r : ℕ) {n : ℕ} (hn : 0 < n) (s : Fin n → Bool) :
    IsFixedPoint r hn s ↔ IsPeriodicPoint r hn 1 s := by
  rfl

/-
If s is k-periodic, then s is also (m*k)-periodic for any m.
-/
theorem periodic_mul_periodic {r : ℕ} {n : ℕ} {hn : 0 < n} {k : ℕ}
    {s : Fin n → Bool} (hpk : IsPeriodicPoint r hn k s) (m : ℕ) :
    IsPeriodicPoint r hn (m * k) s := by
  induction m <;> simp_all +decide [ IsPeriodicPoint, iterate_add, Nat.succ_mul ];
  rfl

/-
Fixed points are k-periodic for every k.
-/
theorem fixed_implies_periodic {r : ℕ} {n : ℕ} {hn : 0 < n}
    {s : Fin n → Bool} (hfp : IsFixedPoint r hn s) (k : ℕ) :
    IsPeriodicPoint r hn k s := by
  -- By definition of IsPeriodicPoint, we need to show that iterate r hn k s = s.
  apply fixed_point_iterate hfp k

/-
The fixed point set is contained in the k-periodic point set.
-/
theorem fixedPointSet_subset_periodicPointSet (r : ℕ) {n : ℕ} (hn : 0 < n) (k : ℕ)
    (_hk : 1 ≤ k) :
    {s | IsFixedPoint r hn s} ⊆ periodicPointSet r hn k := by
  exact fun s hs => fixed_implies_periodic hs k

/-! ## Part IV: Linear Rules and Periodic Points -/

/-
A linear ECA commutes with XOR at the step level.
-/
theorem linear_step_xor {r : ℕ} {n : ℕ} {hn : 0 < n}
    (hlin : IsLinearRule r) (s t : Fin n → Bool) :
    step r hn (stateXor s t) = stateXor (step r hn s) (step r hn t) := by
  exact funext fun i => hlin.2 _ _ _ _ _ _

/-
Iteration of a linear rule also commutes with XOR.
-/
theorem linear_iterate_xor {r : ℕ} {n : ℕ} {hn : 0 < n}
    (hlin : IsLinearRule r) (k : ℕ) (s t : Fin n → Bool) :
    iterate r hn k (stateXor s t) = stateXor (iterate r hn k s) (iterate r hn k t) := by
  induction' k with k ih generalizing s t;
  · rfl;
  · convert linear_step_xor hlin ( iterate r hn k s ) ( iterate r hn k t ) using 1;
    convert congr_arg ( step r hn ) ( ih s t ) using 1

/-
The zero state is always a fixed point for linear rules.
-/
theorem linear_zero_fixed {r : ℕ} {n : ℕ} {hn : 0 < n}
    (hlin : IsLinearRule r) : step r hn (zeroState n) = zeroState n := by
  ext i; exact hlin.1;

/-
The zero state is k-periodic for any linear rule and any k.
-/
theorem zero_periodic_linear {r : ℕ} {n : ℕ} {hn : 0 < n}
    (hlin : IsLinearRule r) (k : ℕ) :
    IsPeriodicPoint r hn k (zeroState n) := by
  -- Use `fixed_implies_periodic` with the fact that `zeroState` is a fixed point.
  have h_zero_fixed : IsFixedPoint r hn (zeroState n) := by
    exact linear_zero_fixed hlin
  exact fixed_implies_periodic h_zero_fixed k

/-
**The Periodic Linear Code Theorem**: k-periodic points of a linear ECA
    are closed under XOR.
-/
theorem periodic_xor_closed {r : ℕ} {n : ℕ} {hn : 0 < n}
    (hlin : IsLinearRule r) (k : ℕ)
    (s t : Fin n → Bool)
    (hs : IsPeriodicPoint r hn k s) (ht : IsPeriodicPoint r hn k t) :
    IsPeriodicPoint r hn k (stateXor s t) := by
  rw [IsPeriodicPoint] at *;
  rw [ linear_iterate_xor hlin, hs, ht ]

/-! ## Part V: The Periodic Orbit Code -/

/-- Convert Bool to ZMod 2. -/
def boolToGF2 (b : Bool) : ZMod 2 := if b then 1 else 0

/-- Convert ZMod 2 to Bool. -/
def gf2ToBool (x : ZMod 2) : Bool := x ≠ 0

/-- Convert a Bool state to a GF(2) state. -/
def toGF2 {n : ℕ} (s : Fin n → Bool) : Fin n → ZMod 2 := boolToGF2 ∘ s

/-- Convert a GF(2) state to a Bool state. -/
def fromGF2 {n : ℕ} (s : Fin n → ZMod 2) : Fin n → Bool := gf2ToBool ∘ s

/-
**stateXor corresponds to addition over GF(2)**:
    fromGF2(a + b) = stateXor (fromGF2 a) (fromGF2 b).
    This is the key bridge between the algebraic and Boolean views.
-/
theorem fromGF2_add {n : ℕ} (a b : Fin n → ZMod 2) :
    fromGF2 (a + b) = stateXor (fromGF2 a) (fromGF2 b) := by
  funext i; simp +decide [ fromGF2, stateXor ] ;
  cases Fin.exists_fin_two.mp ⟨ a i, rfl ⟩ <;> cases Fin.exists_fin_two.mp ⟨ b i, rfl ⟩ <;> simp +decide [ * ]

/-
fromGF2 of zero is the zero state.
-/
theorem fromGF2_zero {n : ℕ} : fromGF2 (0 : Fin n → ZMod 2) = zeroState n := by
  unfold fromGF2 zeroState; aesop;

/-
fromGF2 of a scalar multiple by c : ZMod 2.
-/
theorem fromGF2_smul {n : ℕ} (c : ZMod 2) (v : Fin n → ZMod 2) :
    fromGF2 (c • v) = if c = 0 then zeroState n else fromGF2 v := by
  fin_cases c <;> aesop

/-- **The Periodic Orbit Code**: For a linear ECA rule r and period k,
    the k-periodic orbits form a linear code (submodule of (ZMod 2)^n). -/
noncomputable def PeriodicOrbitCode (r : ℕ) (n : ℕ) (hn : 0 < n) (k : ℕ)
    (hlin : IsLinearRule r) : Submodule (ZMod 2) (Fin n → ZMod 2) where
  carrier := {v | IsPeriodicPoint r hn k (fromGF2 v)}
  add_mem' := by
    intro a b ha hb
    simp only [Set.mem_setOf_eq] at *
    rw [fromGF2_add]
    exact periodic_xor_closed hlin k _ _ ha hb
  zero_mem' := by
    simp only [Set.mem_setOf_eq]
    rw [fromGF2_zero]
    exact zero_periodic_linear hlin k
  smul_mem' := by
    intro c v hv
    simp only [Set.mem_setOf_eq] at *
    rw [fromGF2_smul]
    split
    · exact zero_periodic_linear hlin k
    · exact hv

/-! ## Part VI: Monotone Period Hierarchy -/

/-
The periodic point sets form a monotone hierarchy under divisibility.
-/
theorem periodic_set_monotone {r : ℕ} {n : ℕ} {hn : 0 < n}
    {k m : ℕ} (hdvd : k ∣ m) :
    periodicPointSet r hn k ⊆ periodicPointSet r hn m := by
  obtain ⟨ d, rfl ⟩ := hdvd;
  exact fun x hx => by rw [ mul_comm ] ; exact periodic_mul_periodic hx d;

/-
For linear rules, the periodic orbit codes satisfy monotonicity.
-/
theorem periodic_code_monotone {r : ℕ} {n : ℕ} {hn : 0 < n}
    (hlin : IsLinearRule r) {k m : ℕ} (hdvd : k ∣ m) :
    PeriodicOrbitCode r n hn k hlin ≤ PeriodicOrbitCode r n hn m hlin := by
  intro v hv;
  exact periodic_set_monotone hdvd hv

/-! ## Part VII: Rule-Specific Results -/

/-- Rule 0 always outputs false. -/
theorem localRule_zero (l c r : Bool) : localRule 0 l c r = false := by
  simp [localRule, Nat.zero_testBit]

/-- Rule 0 maps every state to the zero state. -/
theorem rule0_step_zero {n : ℕ} (hn : 0 < n) (s : Fin n → Bool) :
    step 0 hn s = zeroState n := by
  ext i; exact localRule_zero _ _ _

/-
Rule 0: all periodic points (k ≥ 1) are the zero state.
-/
theorem rule0_periodic_singleton {n : ℕ} (hn : 0 < n) {k : ℕ} (hk : 1 ≤ k)
    (s : Fin n → Bool) (hp : IsPeriodicPoint 0 hn k s) :
    s = zeroState n := by
  rcases k with ( _ | k ) <;> simp_all +decide [ IsPeriodicPoint ];
  rw [ ← hp, iterate ];
  exact rule0_step_zero hn _

/-- Rule 204 step is the identity. -/
theorem rule204_step_id {n : ℕ} (hn : 0 < n) (s : Fin n → Bool) :
    step 204 hn s = s := by
  ext i
  simp only [step, localRule]
  cases (s ⟨(i.val + n - 1) % n, _⟩) <;> cases (s i) <;>
    cases (s ⟨(i.val + 1) % n, _⟩) <;> native_decide

/-
Rule 204: every state is k-periodic for all k.
-/
theorem rule204_all_periodic {n : ℕ} (hn : 0 < n) (k : ℕ) (s : Fin n → Bool) :
    IsPeriodicPoint 204 hn k s := by
  convert fixed_implies_periodic _ k;
  exact funext fun i => by unfold step localRule; aesop;

/-! ## Part VIII: Code Rate -/

/-- The code rate of the periodic orbit code. -/
noncomputable def periodicCodeRate (r : ℕ) (n : ℕ) (hn : 0 < n) (k : ℕ)
    (hlin : IsLinearRule r) : ℚ :=
  (Module.finrank (ZMod 2) (PeriodicOrbitCode r n hn k hlin) : ℚ) / n

/-- The code rate is nonneg. -/
theorem periodicCodeRate_nonneg (r : ℕ) (n : ℕ) (hn : 0 < n) (k : ℕ)
    (hlin : IsLinearRule r) :
    0 ≤ periodicCodeRate r n hn k hlin := by
  unfold periodicCodeRate
  positivity

/-
**Falsifiable Conjecture**: The periodic orbit code dimension is at most n.
-/
theorem periodic_code_dimension_bound (r : ℕ) (n : ℕ) (hn : 0 < n) (k : ℕ)
    (hlin : IsLinearRule r) :
    Module.finrank (ZMod 2) (PeriodicOrbitCode r n hn k hlin) ≤ n := by
  refine' le_trans ( Submodule.finrank_le _ ) _;
  norm_num

end ECA