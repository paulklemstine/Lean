/-
# Erdős–Straus Conjecture: Certified Bounded Search

This file implements decision procedures for the Erdős–Straus equation
and proves soundness and completeness theorems.

## Approach

We provide two search strategies:
1. **Brute force**: enumerate all (x,y,z) ≤ B (for soundness/completeness proofs)
2. **Smart search**: for each x, compute z from the equation (for efficiency)
-/
import Speculative.ErdosStraus.Defs

/-- Check whether (n, x, y, z) satisfies the Erdős–Straus equation.
This is the decidable kernel of the search. -/
def checkErdosStraus (n x y z : ℕ) : Bool :=
  0 < x && 0 < y && 0 < z &&
    (4 * x * y * z : Int) == (n : Int) * ((x : Int) * y + x * z + y * z)

/-- The check function is correct: it returns true iff ErdosStrausRep holds. -/
theorem checkErdosStraus_iff {n x y z : ℕ} :
    checkErdosStraus n x y z = true ↔ ErdosStrausRep n x y z := by
  simp [checkErdosStraus]
  unfold ErdosStrausRep; aesop

/-- Bounded search: enumerate all triples (x,y,z) with 1 ≤ x,y,z ≤ B. -/
def searchErdosStraus (n B : ℕ) : Bool :=
  (List.range B).any fun x' =>
    (List.range B).any fun y' =>
      (List.range B).any fun z' =>
        checkErdosStraus n (x' + 1) (y' + 1) (z' + 1)

/-- **Soundness**: if the search returns true, an Erdős–Straus decomposition exists. -/
theorem searchErdosStraus_sound
    {n B : ℕ} :
    searchErdosStraus n B = true →
    ErdosStrausSolvable n := by
  intro h
  unfold searchErdosStraus at h
  simp at h
  obtain ⟨ x, hx, y, hy, z, hz, h ⟩ := h
  exact ⟨ x + 1, y + 1, z + 1, by simpa [ErdosStrausRep] using checkErdosStraus_iff.mp h ⟩

/-- **Completeness relative to bound**: if a decomposition with all
denominators ≤ B exists, the brute-force search finds it. -/
theorem searchErdosStraus_complete_bounded
    {n B : ℕ} :
    (∃ x ≤ B, ∃ y ≤ B, ∃ z ≤ B, ErdosStrausRep n x y z) →
    searchErdosStraus n B = true := by
  intro h
  obtain ⟨x, hx, y, hy, z, hz, hrep⟩ := h
  by_cases hx' : x = 0 <;> by_cases hy' : y = 0 <;> by_cases hz' : z = 0 <;>
    simp_all +decide [ErdosStrausRep]
  unfold searchErdosStraus; simp +decide [*]
  exact ⟨ x - 1, by omega, y - 1, by omega, z - 1, by omega,
    by rw [show x = x - 1 + 1 by rw [Nat.sub_add_cancel hrep.1],
           show y = y - 1 + 1 by rw [Nat.sub_add_cancel hrep.2.1],
           show z = z - 1 + 1 by rw [Nat.sub_add_cancel hrep.2.2.1]] at hrep
       unfold checkErdosStraus; aesop ⟩

/-! ## Smart search: 2D enumeration with computed z

For fixed x and n, the equation 4xyz = n(xy + xz + yz) can be solved for z:
  z = nxy / (4xy - n(x+y))
provided the denominator is positive and divides the numerator.
-/

/-- Compute z from (n, x, y) if it exists and is positive. Returns 0 on failure. -/
def computeZ (n x y : ℕ) : ℕ :=
  let num := n * x * y
  let denom_signed := (4 * x * y : Int) - (n : Int) * (x + y)
  if denom_signed > 0 then
    let denom := denom_signed.toNat
    if num % denom == 0 then num / denom else 0
  else 0

/-- Smart search: for each x from 1 to B, y from 1 to B, compute z.
This is O(B²) instead of O(B³). -/
def smartSearchErdosStraus (n B : ℕ) : Bool :=
  (List.range B).any fun x' =>
    (List.range B).any fun y' =>
      let x := x' + 1
      let y := y' + 1
      let z := computeZ n x y
      checkErdosStraus n x y z

/-
The smart search is sound.
-/
theorem smartSearchErdosStraus_sound
    {n B : ℕ} :
    smartSearchErdosStraus n B = true →
    ErdosStrausSolvable n := by
  intro h
  unfold smartSearchErdosStraus at h
  simp at h;
  obtain ⟨ x, hx, y, hy, h ⟩ := h; use x + 1, y + 1, computeZ n ( x + 1 ) ( y + 1 ) ; exact checkErdosStraus_iff.mp h;

/-- Wrapper: verify ErdosStrausSolvable for specific n using native_decide. -/
theorem erdos_straus_of_smart_search (n : ℕ) (B : ℕ)
    (h : smartSearchErdosStraus n B = true) :
    ErdosStrausSolvable n :=
  smartSearchErdosStraus_sound h