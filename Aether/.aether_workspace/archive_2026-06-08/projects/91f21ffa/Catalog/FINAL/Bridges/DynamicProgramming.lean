/-
  # Tropical Dynamic Programming for Voice Leading

  Theorem 3: Tropical Bellman recursion for optimal voice leading.
  Local costs combine tropically via dynamic programming, turning
  counterpoint search into a certified tropical shortest-path problem.
-/
import Mathlib
import Bridges.TropicalCounterpoint.Defs

open Finset BigOperators

/-! ## Finite DP formulation over bounded pitch alphabet -/

/-- State cost for a single note at position 0: just the vertical penalty. -/
noncomputable def dpCostBase (cantus0 : ℤ) (x : ℤ) : ℝ :=
  forbiddenVerticalPenalty (x - cantus0)

/-- Transition cost between consecutive notes, incorporating vertical, melodic, and parallel penalties. -/
noncomputable def dpTransition (cantusCurr cantusNext : ℤ) (curr next : ℤ) : ℝ :=
  forbiddenVerticalPenalty (next - cantusNext) +
  melodicLeapPenalty curr next +
  (if perfectConsonance (curr - cantusCurr) ∧ perfectConsonance (next - cantusNext) then 1 else 0)

/-- The DP value function: minimum total cost achievable ending at pitch `x` at step `k`.
    Uses a finite pitch set `Y` for the minimization. -/
noncomputable def dpValue (cantus : ℕ → ℤ) (Y : Finset ℤ) : ℕ → ℤ → ℝ
  | 0, x => dpCostBase (cantus 0) x
  | k + 1, x => if hY : Y.Nonempty then
      Y.inf' hY (fun y => dpTransition (cantus k) (cantus (k + 1)) y x + dpValue cantus Y k y)
    else 0

/-! ## Tropical Bellman equation -/

/-
**Theorem 3 (Tropical Bellman Recursion)**: The DP value at step `k+1`
    satisfies the tropical (min-plus) Bellman equation:
    `dpValue (k+1) x = min_y (dpTransition y x + dpValue k y)`.

    This is the computational heart of tropical counterpoint: it turns
    voice-leading search into a certified shortest-path problem over
    a layered directed acyclic graph.
-/
theorem tropical_bellman (cantus : ℕ → ℤ) (Y : Finset ℤ) (hY : Y.Nonempty)
    (k : ℕ) (x : ℤ) :
    dpValue cantus Y (k + 1) x =
      Y.inf' hY (fun y => dpTransition (cantus k) (cantus (k + 1)) y x +
                           dpValue cantus Y k y) := by
  grind +locals

/-! ## Tropical distributivity: adding a constant distributes over min -/

/-
Addition distributes over minimum (tropical distributivity).
    This is the algebraic law `a + min(b,c) = min(a+b, a+c)` that
    underpins the Bellman recursion.
-/
theorem tropical_plus_distributes_over_min_real (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  grind

/-
Monotonicity: adding candidates cannot increase the tropical optimum.
-/
theorem tropical_monotone_insert (Y : Finset ℤ) (y₀ : ℤ) (f : ℤ → ℝ)
    (hY : Y.Nonempty) :
    (insert y₀ Y).inf' (Finset.insert_nonempty y₀ Y) f ≤ Y.inf' hY f := by
  norm_num [ Finset.inf'_le ];
  exact fun x hx => Or.inr ⟨ x, hx, le_rfl ⟩

/-! ## Path cost equals DP value -/

/-- The cost of a specific path through the pitch space. -/
noncomputable def pathCost (cantus : ℕ → ℤ) : (n : ℕ) → (Fin (n + 1) → ℤ) → ℝ
  | 0, p => dpCostBase (cantus 0) (p 0)
  | n + 1, p =>
    pathCost cantus n (fun i => p ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩) +
    dpTransition (cantus n) (cantus (n + 1)) (p ⟨n, Nat.lt_succ_of_lt (Nat.lt.base n)⟩) (p ⟨n + 1, Nat.lt.base (n + 1)⟩)

/-
The DP value lower-bounds any path cost ending at the given pitch.
-/
theorem dpValue_le_pathCost (cantus : ℕ → ℤ) (Y : Finset ℤ)
    (n : ℕ) (p : Fin (n + 1) → ℤ)
    (_hY : Y.Nonempty)
    (hp : ∀ i : Fin (n + 1), p i ∈ Y) :
    dpValue cantus Y n (p ⟨n, Nat.lt.base n⟩) ≤ pathCost cantus n p := by
  induction' n with n ih;
  · exact le_rfl;
  · convert le_trans _ ( add_le_add_left ( ih _ _ ) _ ) using 1;
    · rw [ tropical_bellman ];
      convert Finset.inf'_le _ ( hp ⟨ n, Nat.lt_succ_of_lt ( Nat.lt_succ_self _ ) ⟩ ) using 1 ; ring;
    · exact fun i => hp _