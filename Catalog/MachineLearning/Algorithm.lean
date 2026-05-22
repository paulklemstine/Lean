import Mathlib
import Speculative.ExceptionalSet.Defs

/-!
# Certified Obstruction Search Algorithm

## Overview

This file formalizes a certified screening procedure for finding
candidate exceptional parameters. The algorithm scans parameters
`c ∈ [-C, C]`, searches primes up to `P`, and tests a finite-depth
degeneracy criterion up to iterate depth `N`.

## Main Results

- `obstructionWitnessSearch`: A decidable search function returning
  candidate exceptional parameters with their witness primes.
- `obstructionWitnessSearch_sound`: Soundness theorem guaranteeing
  that every returned parameter has a finite-depth obstruction.
- `quadIterMod_periodic_of_repeated`: If two iterates agree mod `p`,
  the orbit is eventually periodic mod `p` (pigeonhole witness).
-/

open Finset Nat

/-! ## Computable Quadratic Iteration -/

/-- Compute the n-th iterate of x under T_c, using the computable definition. -/
def quadIterComp (c : ℤ) (x : ℤ) : ℕ → ℤ
  | 0 => x
  | n + 1 => (quadIterComp c x n) ^ 2 + c

@[simp] theorem quadIterComp_zero (c x : ℤ) : quadIterComp c x 0 = x := rfl
@[simp] theorem quadIterComp_succ (c x : ℤ) (n : ℕ) :
    quadIterComp c x (n + 1) = (quadIterComp c x n) ^ 2 + c := rfl

/-
`quadIterComp` agrees with `quadIter` from Defs.
-/
theorem quadIterComp_eq_quadIter (c x : ℤ) (n : ℕ) :
    quadIterComp c x n = quadIter c x n := by
  -- By definition of `quadIter`, we know that `quadIter c x n = quadIterComp c x n`.
  unfold quadIter; induction' n with n ih <;> simp [quadIterComp];
  cases n <;> aesop

/-! ## Finite-Depth Obstruction Check -/

/-- Check whether there exist `i < j ≤ N` with `f(i) ≡ f(j) (mod p)`.
This is decidable and serves as the computable witness for eventual periodicity. -/
def hasRepeatedResidue (f : ℕ → ℤ) (p : ℕ) (N : ℕ) : Bool :=
  (List.range (N + 1)).any fun j =>
    (List.range j).any fun i =>
      (f i % (p : ℤ)) == (f j % (p : ℤ))

/-
Correctness of `hasRepeatedResidue`: it returns true iff
there exist `i < j ≤ N` with matching residues.
-/
theorem hasRepeatedResidue_iff (f : ℕ → ℤ) (p : ℕ) (N : ℕ) :
    hasRepeatedResidue f p N = true ↔ FiniteDepthObstruction f p N := by
  -- The `Bool.any` operation on the list corresponds to the existence of such a pair in the `Prop` definition.
  simp [FiniteDepthObstruction, hasRepeatedResidue];
  exact ⟨ fun ⟨ i, hi, j, hj, h ⟩ => ⟨ j, i, hj, hi, h ⟩, fun ⟨ i, j, hij, hj, h ⟩ => ⟨ j, hj, i, hij, h ⟩ ⟩

/-- The list of primes up to `P`. -/
def primesUpTo (P : ℕ) : List ℕ :=
  (List.range (P + 1)).filter Nat.Prime

/-- Search for candidate exceptional parameters.
Scans `c ∈ [-C, C]`, checks primes up to `P`, and tests finite-depth
degeneracy up to iterate depth `N` with seed `x₀ = 0`. -/
def obstructionWitnessSearch (C P N : ℕ) : List ℤ :=
  let primes := primesUpTo P
  let candidates := (List.range (2 * C + 1)).map fun i => (i : ℤ) - (C : ℤ)
  candidates.filter fun c =>
    primes.any fun p => hasRepeatedResidue (quadIterComp c 0) p N

/-
**Soundness of the obstruction search.**

Every parameter returned by `obstructionWitnessSearch` has a
finite-depth obstruction at some prime `p ≤ P` for the orbit
starting at seed 0.
-/
theorem obstructionWitnessSearch_sound
    (C P N : ℕ) :
    ∀ c ∈ obstructionWitnessSearch C P N,
      ∃ p, p ≤ P ∧ Nat.Prime p ∧ FiniteDepthObstruction (quadIterComp c 0) p N := by
  unfold obstructionWitnessSearch at *;
  unfold primesUpTo at *;
  simp +zetaDelta at *;
  exact fun a ha x hx hx' hx'' => ⟨ x, hx, hx', hasRepeatedResidue_iff _ _ _ |>.1 hx'' ⟩

/-! ## Repeated Residues Witness Eventual Periodicity -/

/-
**Pigeonhole principle for modular orbits.**

If the quadratic orbit starting at seed 0 has two iterates `i < j`
with the same residue mod `p`, then the entire orbit mod `p` is
eventually periodic (with preperiod `i` and period dividing `j - i`).

This is the key bridge from the computable finite-depth check to
the mathematical degeneracy predicate.
-/
theorem quadOrbitMod_periodic_of_repeated
    (c : ℤ) (p : ℕ) (_hp : Nat.Prime p) (i j : ℕ)
    (hij : i < j) (hmod : quadIterComp c 0 i % (p : ℤ) = quadIterComp c 0 j % (p : ℤ)) :
    DegenerateModPrime (quadIterComp c 0) p := by
  refine' ⟨ i, j - i, tsub_pos_of_lt hij, _ ⟩;
  intro n hn
  induction' hn with n hn ih;
  · simp +decide [ hij.le, hmod ];
  · simp_all +decide [ Nat.succ_add, quadIterComp ];
    exact Int.ModEq.add ( Int.ModEq.pow _ ih ) rfl