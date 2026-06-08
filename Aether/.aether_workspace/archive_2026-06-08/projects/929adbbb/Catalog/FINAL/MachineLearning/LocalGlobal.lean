/-
# Local-Global Framework for Sums of Three Cubes

This file develops the local solvability framework for the equation x³+y³+z³=n,
connecting global integer representability to local representability modulo m.
It provides:
- Reduction from global to local: if n is a sum of three cubes, then it is
  locally representable modulo every m.
- The HasLocalPointEverywhere predicate and its relationship to mod-9 admissibility.
- Infrastructure for the Hasse principle tension.
-/
import Mathlib
import Speculative.AutoResearch.NumberTheory.SumThreeCubes.Basic
import Speculative.AutoResearch.NumberTheory.SumThreeCubes.Mod9

/-
Global representability implies local representability: if n = x³+y³+z³ over ℤ,
then the equation has a solution modulo every positive m. This is the "easy direction"
of the Hasse principle.
-/
theorem global_implies_local (n : ℤ) (h : SumThreeCubesRep n) (m : ℕ) (_hm : m ≠ 0) :
    LocRep m (n : ZMod m) := by
  obtain ⟨ x, y, z, h ⟩ := h; exact ⟨ x, y, z, by simpa using congr_arg ( fun x : ℤ => x : ℤ → ZMod m ) h ⟩ ;

/-
If n is representable as a sum of three cubes, then it satisfies the
local condition everywhere.
-/
theorem hasLocalPointEverywhere_of_rep (n : ℤ) (h : SumThreeCubesRep n) :
    HasLocalPointEverywhere n := by
  exact fun m hm => global_implies_local n h m hm

/-
Contrapositive: if the local condition fails at some modulus, then n is not
representable. This gives the general obstruction principle.
-/
theorem not_rep_of_local_failure (n : ℤ) (m : ℕ) (hm : m ≠ 0)
    (h : ¬LocRep m (n : ZMod m)) :
    ¬SumThreeCubesRep n := by
  exact fun hn => h <| global_implies_local n hn m hm

/-
The mod-9 obstruction is a special case of local failure: integers
congruent to 4 or 5 mod 9 fail the local condition at m=9.
-/
theorem mod9_obstruction_from_local (n : ℤ) (h : n % 9 = 4 ∨ n % 9 = 5) :
    ¬HasLocalPointEverywhere n := by
  -- By the contrapositive of the global_implies_local theorem, if the local condition fails, then n is not representable.
  have h_local : ¬LocRep 9 (n : ZMod 9) := by
    rcases h with ( h | h ) <;> rw [ ← Int.emod_add_mul_ediv n 9, h ];
    · unfold LocRep; norm_num [ ZMod, Int.add_emod, Int.mul_emod ] ;
      erw [ show ( 9 : ZMod 9 ) = 0 by rfl ] ; simp +decide;
    · simp +decide [ LocRep ];
      erw [ show ( 9 : ZMod 9 ) = 0 by rfl ] ; simp +decide;
  exact fun h => h_local <| h 9 ( by decide )

/-
A nontrivial polynomial family: for all a b : ℤ, we have a³ + b³ + (-a-b)³
equals -3ab(a+b). This gives infinitely many representable integers via a
two-parameter identity.
-/
theorem sum_three_cubes_neg_sum :
    ∀ a b : ℤ, a ^ 3 + b ^ 3 + (-a - b) ^ 3 = -3 * a * b * (a + b) := by
  exact fun a b => by ring;

/-
For any integer k, the integer -3*k*(k+1)*(2*k+1) is representable as a
sum of three cubes. This gives a dense infinite family.
-/
theorem family_neg3_product (k : ℤ) :
    SumThreeCubesRep (-3 * k * (k + 1) * (2 * k + 1)) := by
  -- Let $a = k$ and $b = k + 1$. Then $-3ab(a + b) = -3k(k + 1)(2k + 1)$.
  use k, k + 1, -2 * k - 1;
  ring