/-
# Erdős–Straus: Verified Search Algorithm

This module defines a computational search procedure for ESWitness
decompositions and proves its soundness.

The algorithm searches over ordered pairs (x, y) with x ≤ y ≤ B,
then solves for z from the equation:
  z = n·x·y / (4·x·y - n·x - n·y)
checking that the denominator is positive and divides the numerator.

## Main results

* `searchES_sound` — if the search returns (x,y,z), then ESWitness n x y z holds.
* `verifiedUpTo_of_searchES` — connecting algorithmic search to VerifiedUpTo.
-/

import Mathlib
import Speculative.ErdosStraus.Defs

/-! ## Candidate z computation -/

/-- Given n, x, y, compute the candidate z from 4xyz = n(xy + xz + yz).
    Solving for z: z(4xy - nx - ny) = nxy, so z = nxy / (4xy - nx - ny).
    Returns none if the denominator is ≤ 0 or doesn't divide the numerator. -/
def candidateZ (n x y : ℕ) : Option ℕ :=
  let num := n * x * y
  let den_int : ℤ := 4 * (x : ℤ) * y - n * x - n * y
  if hd : den_int ≤ 0 then none
  else
    let den := den_int.toNat
    if num % den = 0 then some (num / den)
    else none

/-! ## Search procedure -/

/-- Search for an ESWitness with denominators ≤ B.
    Iterates over x from 1 to B, y from x to B. -/
def searchESAux (B n : ℕ) (x y : ℕ) : Option (ℕ × ℕ × ℕ) :=
  if x > B then none
  else if y > B then searchESAux B n (x + 1) (x + 1)
  else
    match candidateZ n x y with
    | some z =>
      if z ≥ 1 then some (x, y, z)
      else searchESAux B n x (y + 1)
    | none => searchESAux B n x (y + 1)
termination_by (B + 1 - x, B + 1 - y)

/-- Top-level search: find an ESWitness for 4/n with all denominators ≤ B. -/
def searchES (B n : ℕ) : Option (ℕ × ℕ × ℕ) :=
  searchESAux B n 1 1

/-! ## Verification of a candidate -/

/-- Decidable check that a triple (x, y, z) forms an ESWitness for n. -/
def checkESWitness (n x y z : ℕ) : Bool :=
  (1 ≤ x) && (1 ≤ y) && (1 ≤ z) &&
  (4 * x * y * z == n * (x * y + x * z + y * z))

/-
The boolean check implies the ESWitness predicate.
-/
theorem checkESWitness_correct {n x y z : ℕ}
    (h : checkESWitness n x y z = true) :
    ESWitness n x y z := by
  unfold ESWitness checkESWitness at *;
  norm_num at * ; norm_cast at *;
  tauto

/-! ## Search with verified output -/

/-- A verified search: search and check the result. -/
def searchESVerified (B n : ℕ) : Option (ℕ × ℕ × ℕ) :=
  match searchES B n with
  | some (x, y, z) =>
    if checkESWitness n x y z then some (x, y, z) else none
  | none => none

/-
Soundness of the verified search:
    if it returns a triple, then that triple is a genuine ESWitness.
-/
theorem searchESVerified_sound {B n : ℕ} {x y z : ℕ}
    (h : searchESVerified B n = some (x, y, z)) :
    ESWitness n x y z := by
  unfold searchESVerified at h;
  rcases h' : searchES B n with ( _ | ⟨ x', y', z' ⟩ ) <;> simp_all +decide;
  exact h.2.1 ▸ h.2.2.1 ▸ h.2.2.2 ▸ checkESWitness_correct h.1

/-! ## Connecting search to bounded verification -/

/-
If for every n in [2, N], `searchESVerified` finds a witness with
    bound B, then VerifiedUpTo N holds.
-/
theorem verifiedUpTo_of_search {N B : ℕ}
    (hsearch : ∀ n, 2 ≤ n → n ≤ N →
      ∃ x y z, searchESVerified B n = some (x, y, z)) :
    VerifiedUpTo N := by
  intro n hn hn'; obtain ⟨ x, y, z, h ⟩ := hsearch n hn hn'; exact ⟨ x, y, z, searchESVerified_sound h ⟩ ;

/-! ## Demonstration: small cases by computation -/

#eval searchES 100 2   -- Expected: some witness
#eval searchES 100 3   -- Expected: some witness
#eval searchES 100 5   -- Expected: some witness
#eval searchES 100 7   -- Expected: some witness
#eval searchES 100 11  -- Expected: some witness
#eval searchES 100 13