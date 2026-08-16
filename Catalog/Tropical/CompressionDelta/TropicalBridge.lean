import Tropical.CompressionDelta.Amortization

/-!
# Amortized model-delta compression, V: the tropical semiring bridge

The amortized compression protocol of this thread is a min-plus object: costs of
consecutive steps *add*, and the protocol takes the *minimum* over schedules.  This file
makes that identification literal by showing that the dynamic program `optCost` on a
stream of identical messages is computed by **powers of a matrix over Mathlib's tropical
semiring** `Tropical (WithTop ℕ)`.

## Main results

* `CompressionDelta.natCast_iInf` — the coercion `ℕ → WithTop ℕ` commutes with finite
  infima.
* `CompressionDelta.trop_optCost_cons` — one step of the compression dynamic program is
  exactly one tropical linear (matrix–vector) step.
* `CompressionDelta.tropical_pow_mulVec_eq_optCost` — the optimum for a stream of `n`
  messages is the `n`-th tropical matrix power of the cost matrix applied to the tropical
  all-ones vector.
* `CompressionDelta.boolModel_tropical_pow` — combining with the sharp amortization
  theorem, a closed form for the powers of the associated `2 × 2` min-plus matrix:
  the entry is `n * r + min D n`, i.e. the min-plus power exhibits the break-even kink
  at `n = D`.
-/

namespace CompressionDelta

open Tropical Matrix

variable {M : Type*} [Fintype M] [DecidableEq M] [Nonempty M]

omit [DecidableEq M] in
/-- The coercion `ℕ → WithTop ℕ` commutes with infima over a finite nonempty type. -/
theorem natCast_iInf (f : M → ℕ) :
    ((⨅ m : M, f m : ℕ) : WithTop ℕ) = ⨅ m : M, ((f m : ℕ) : WithTop ℕ) := by
  obtain ⟨i, hi⟩ := exists_natInf_eq f
  have hmin : ∀ m : M, f i ≤ f m := by
    intro m
    rw [← hi]
    exact natInf_le f m
  rw [hi]
  refine le_antisymm (le_ciInf ?_) (ciInf_le (OrderBot.bddBelow _) i)
  intro m
  exact_mod_cast WithTop.coe_le_coe.mpr (hmin m)

omit [DecidableEq M] in
/-- **One dynamic-programming step is one tropical linear step.**  The min-plus recursion
defining the protocol optimum is literally a sum of tropical products. -/
theorem trop_optCost_cons (dlt : M → M → ℕ) (c : M → ℕ) (cs : List (M → ℕ)) (prev : M) :
    trop ((optCost dlt prev (c :: cs) : ℕ) : WithTop ℕ) =
      ∑ m : M, trop ((dlt prev m : ℕ) : WithTop ℕ) * trop ((c m : ℕ) : WithTop ℕ) *
        trop ((optCost dlt m cs : ℕ) : WithTop ℕ) := by
  rw [optCost_cons, natCast_iInf, trop_iInf]
  refine Finset.sum_congr rfl ?_
  intro m _
  rw [← trop_add, ← trop_add]
  congr 1

/-- The min-plus cost matrix of the protocol: entry `(i, j)` is the number of bits to move
the shared decoder from state `i` to state `j` and then code one message in state `j`. -/
noncomputable def costMatrix (dlt : M → M → ℕ) (c : M → ℕ) :
    Matrix M M (Tropical (WithTop ℕ)) :=
  Matrix.of fun i j => trop (((dlt i j + c j : ℕ) : WithTop ℕ))

/-- **The protocol optimum is a tropical matrix power.**  For a stream of `n` identical
messages, the optimal number of transmitted bits (model deltas included) is read off from
the `n`-th power of the min-plus cost matrix. -/
theorem tropical_pow_mulVec_eq_optCost (dlt : M → M → ℕ) (c : M → ℕ) (prev : M) :
    ∀ n : ℕ,
      ((costMatrix dlt c ^ n) *ᵥ (fun _ => 1)) prev =
        trop ((optCost dlt prev (List.replicate n c) : ℕ) : WithTop ℕ) := by
  intro n
  induction n generalizing prev with
  | zero =>
      simp only [pow_zero, Matrix.one_mulVec, List.replicate_zero, optCost_nil]
      rw [show ((0 : ℕ) : WithTop ℕ) = (0 : WithTop ℕ) by simp, trop_zero]
  | succ n ih =>
      have hstep : ((costMatrix dlt c ^ (n + 1)) *ᵥ (fun _ => 1)) prev =
          ∑ m : M, costMatrix dlt c prev m * ((costMatrix dlt c ^ n) *ᵥ (fun _ => 1)) m := by
        rw [pow_succ' (costMatrix dlt c) n, ← Matrix.mulVec_mulVec]
        simp [Matrix.mulVec, dotProduct]
      rw [hstep, List.replicate_succ, optCost_cons, natCast_iInf, trop_iInf]
      refine Finset.sum_congr rfl ?_
      intro m _
      rw [ih m, costMatrix]
      simp only [Matrix.of_apply]
      rw [← trop_add]
      congr 1

/-- **Closed form for a `2 × 2` min-plus power.**  In the explicit two-state model of
`CompressionDelta.Amortization`, the tropical matrix power applied to the tropical
all-ones vector is `n * r + min D n`: a piecewise-linear function of `n` with a kink
exactly at the break-even stream length `n = D`. -/
theorem boolModel_tropical_pow (r D n : ℕ) :
    ((costMatrix (boolDelta D) (boolCost r) ^ n) *ᵥ (fun _ => 1)) false =
      trop (((n * r + min D n : ℕ) : WithTop ℕ)) := by
  rw [tropical_pow_mulVec_eq_optCost (boolDelta D) (boolCost r) false n, boolModel_optCost]

end CompressionDelta