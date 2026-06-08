import Mathlib
import Algebra.SumThreeCubes.Defs
import Algebra.SumThreeCubes.LocalGlobal
import Algebra.SumThreeCubes.LocalObstruction

/-!
# Proto-Brauer–Manin Obstructions for Integral Points on Cubic Surfaces

This file develops the first layer of a Brauer–Manin obstruction theory for the
Diophantine equation x³ + y³ + z³ = k, building on the local admissibility
infrastructure in `Algebra.SumThreeCubes`.

## Overview

We formalize the observation that the classical mod 9 obstruction is not an isolated
congruence accident, but the first visible footprint of a deeper adelic/cohomological
mechanism. The key definitions are:

* `CubicObstructionProfile k` — the set of moduli where solvability fails
* `ProtoBrauerCompatible k` — solvability modulo every positive modulus

We prove:
1. Global representability implies proto-Brauer compatibility
2. The mod 9 obstruction propagates to the proto-Brauer level
3. Solvability descends along divisibility of moduli
4. Obstruction profiles certify search pruning
5. The mod 9 obstruction controls all 3-power levels

## Cross-domain connections

The obstruction profile is a certified search-pruning invariant, creating a bridge
between arithmetic geometry and computational complexity. If a modulus m lies in
`CubicObstructionProfile k`, then no integer solution exists, and any bounded
search is provably futile.
-/

open ZMod in
/-- The **cubic obstruction profile** of k: the set of moduli m for which
x³ + y³ + z³ = k has no solution in ZMod m. This is a finite-level shadow
of the Brauer–Manin obstruction set. -/
def CubicObstructionProfile (k : ℤ) : Set ℕ :=
  {m | ¬ ∃ x y z : ZMod m, x ^ 3 + y ^ 3 + z ^ 3 = (k : ZMod m)}

/-- **Proto-Brauer compatibility**: k is solvable modulo every positive modulus.
This is a finite-level approximation to adelic compatibility. -/
def ProtoBrauerCompatible (k : ℤ) : Prop :=
  ∀ m : ℕ, m ≠ 0 → ∃ x y z : ZMod m, x ^ 3 + y ^ 3 + z ^ 3 = (k : ZMod m)

/-- Bounded three-cube search: integers bounded by B whose cubes sum to k. -/
def BoundedThreeCubeSearch (k : ℤ) (B : ℕ) : Prop :=
  ∃ x y z : ℤ, |x| ≤ B ∧ |y| ≤ B ∧ |z| ≤ B ∧ x ^ 3 + y ^ 3 + z ^ 3 = k

/-! ## Relationship between ProtoBrauerCompatible and EverywhereLocallyAdmissible -/

/-- `ProtoBrauerCompatible` is equivalent to `EverywhereLocallyAdmissible`. -/
theorem protoBrauerCompatible_iff_everywhereLocallyAdmissible (k : ℤ) :
    ProtoBrauerCompatible k ↔ EverywhereLocallyAdmissible k := by
  constructor
  · intro h n hn; exact h n (by omega)
  · intro h n hn; exact h n (by omega)

/-! ## Theorem 1: Global representation implies proto-Brauer compatibility -/

/-
**Theorem 1.** Global representability implies proto-Brauer compatibility:
the solution reduces modulo m for every positive modulus m.
-/
theorem sumThreeCubesRep_implies_protoBrauerCompatible
    (k : ℤ) (h : ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = k) :
    ProtoBrauerCompatible k := by
  exact fun n _ => by rcases h with ⟨ x, y, z, rfl ⟩ ; exact ⟨ x, y, z, by simpa [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ⟩ ;

/-! ## Theorem 3: Compatibility under divisibility of moduli -/

/-
**Theorem 3.** If m ∣ n and x³ + y³ + z³ = k is solvable in ZMod n,
then it is solvable in ZMod m. Uses the canonical ring homomorphism
`ZMod.castHom`.
-/
theorem cubic_solution_mod_downward_closed
    {k : ℤ} {m n : ℕ}
    (hdiv : m ∣ n)
    (hsol : ∃ x y z : ZMod n, x ^ 3 + y ^ 3 + z ^ 3 = (k : ZMod n)) :
    ∃ x y z : ZMod m, x ^ 3 + y ^ 3 + z ^ 3 = (k : ZMod m) := by
  have h_cast : ∃ (f : ZMod n →+* ZMod m), Function.Surjective f ∧ ∀ x : ℤ, f x = x := by
    have h_nat : m ∣ n := hdiv
    have h_int : (m : ℤ) ∣ n := by
      exact_mod_cast h_nat
    refine' ⟨ _, _, _ ⟩;
    exact ZMod.castHom ( Int.natCast_dvd_natCast.mp h_int ) _;
    · exact?;
    · aesop;
  obtain ⟨ f, hf₁, hf₂ ⟩ := h_cast; obtain ⟨ x, y, z, h ⟩ := hsol; exact ⟨ f x, f y, f z, by simpa [ hf₂ ] using congr_arg f h ⟩ ;

/-! ## Theorem 2: The mod 9 obstruction at the proto-Brauer level -/

/-
9 lies in the cubic obstruction profile when k ≡ 4 or 5 (mod 9).
-/
theorem nine_mem_CubicObstructionProfile_of_eq_four_or_five_mod_nine
    {k : ℤ}
    (hk : k % 9 = 4 ∨ k % 9 = 5) :
    9 ∈ CubicObstructionProfile k := by
  rcases hk with ( hk | hk ) <;> rw [ CubicObstructionProfile ] <;> simp +decide [ hk, ← ZMod.intCast_eq_intCast_iff' ];
  · erw [ ← Int.emod_add_mul_ediv k 9, hk ] ; simp +decide [ ZMod ] ;
    simp +decide [ Fin.ext_iff, Fin.val_add, Fin.val_mul ];
  · erw [ ← Int.emod_add_mul_ediv k 9, hk ] ; simp +decide [ ZMod, Int.add_emod, Int.mul_emod, pow_succ ];
    simp +decide [ Fin.ext_iff, Fin.val_add, Fin.val_mul ]

/-
**Theorem 2.** k ≡ 4 or 5 mod 9 implies failure of proto-Brauer compatibility.
-/
theorem eq_four_or_five_mod_nine_implies_not_protoBrauerCompatible
    {k : ℤ}
    (hk : k % 9 = 4 ∨ k % 9 = 5) :
    ¬ ProtoBrauerCompatible k := by
  exact fun h => nine_mem_CubicObstructionProfile_of_eq_four_or_five_mod_nine hk ( h 9 ( by decide ) )

/-! ## Theorem 4: Obstruction profiles as search-pruning invariants -/

/-
A bounded search result implies k has an integral representation.
-/
theorem boundedSearch_implies_rep {k : ℤ} {B : ℕ}
    (hB : BoundedThreeCubeSearch k B) :
    ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = k := by
  obtain ⟨ x, y, z, hx, hy, hz, h ⟩ := hB; exact ⟨ x, y, z, mod_cast h ⟩ ;

/-
**Theorem 4.** If the obstruction profile is nonempty, no bounded
search can find a solution.
-/
theorem obstructionProfile_prunes_search
    {k : ℤ} {m : ℕ} (hm : m ∈ CubicObstructionProfile k) :
    ∀ B : ℕ, ¬ BoundedThreeCubeSearch k B := by
  intro B hB;
  obtain ⟨ x, y, z, hx, hy, hz, h ⟩ := hB;
  rcases m with ( _ | m ) <;> simp_all +decide [ CubicObstructionProfile ];
  · exact?;
  · exact hm ( x : ZMod ( m + 1 ) ) ( y : ZMod ( m + 1 ) ) ( z : ZMod ( m + 1 ) ) ( by simpa [ ← h ] )

/-
A bounded solution empties the obstruction profile.
-/
theorem boundedSearch_implies_empty_obstruction
    {k : ℤ} {B : ℕ}
    (hB : BoundedThreeCubeSearch k B) :
    CubicObstructionProfile k = ∅ := by
  obtain ⟨ x, y, z, hx, hy, hz, h ⟩ := hB;
  exact Set.eq_empty_of_forall_notMem fun m hm => hm ⟨ x, y, z, by simpa [ ← h ] ⟩

/-! ## Theorem 5: Prime-power reduction at the bad prime 3 -/

/-
**Theorem 5.** Failure at mod 9 persists through all 3^e for e ≥ 2.
Uses downward closure: any solution mod 3^e maps to a solution mod 9
via the quotient, contradicting the known obstruction.
-/
theorem mod_nine_obstruction_controls_all_three_power_levels
    {k : ℤ}
    (hk : k % 9 = 4 ∨ k % 9 = 5) :
    ∀ e : ℕ, 2 ≤ e →
      ¬ ∃ x y z : ZMod (3 ^ e), x ^ 3 + y ^ 3 + z ^ 3 = (k : ZMod (3 ^ e)) := by
  intro e he
  by_contra h_contra
  obtain ⟨x, y, z, h_eq⟩ := h_contra
  have h_mod9 : (x ^ 3 + y ^ 3 + z ^ 3 : ZMod (3 ^ e)) = (k : ZMod (3 ^ e)) := by
    convert h_eq using 1;
  -- Since $9 = 3^2$ divides $3^e$ (because $2 \leq e$), by `cubic_solution_mod_downward_closed` we get a solution in $ZMod 9$.
  have h_mod9 : ∃ x y z : ZMod 9, x ^ 3 + y ^ 3 + z ^ 3 = (k : ZMod 9) := by
    convert cubic_solution_mod_downward_closed ( show 9 ∣ 3 ^ e from dvd_trans ( by decide ) ( pow_dvd_pow _ he ) ) ⟨ x, y, z, h_mod9 ⟩ using 1;
  exact nine_mem_CubicObstructionProfile_of_eq_four_or_five_mod_nine hk h_mod9

/-! ## Structural properties of the obstruction profile -/

/-
The obstruction profile is upward closed under divisibility:
if m is an obstruction, so is any multiple of m.
-/
theorem obstruction_upward_closed
    {k : ℤ} {m n : ℕ}
    (hm : m ∈ CubicObstructionProfile k)
    (hdiv : m ∣ n) :
    n ∈ CubicObstructionProfile k := by
  exact fun h => hm <| cubic_solution_mod_downward_closed hdiv h

/-! ## Conjectures -/

/-- **Proto-Brauer Completeness Conjecture**: finite congruence compatibility is
the only obstruction visible at the current formal level. -/
def ProtoBrauerCompletenessConjecture : Prop :=
  ∀ k : ℤ, ProtoBrauerCompatible k → ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = k

/-- Computationally testable finite version. -/
def PassesSearchAndCongruenceTests (k : ℤ) (B M : ℕ) : Prop :=
  (∀ m ≤ M, m ≠ 0 → ∃ x y z : ZMod m, x ^ 3 + y ^ 3 + z ^ 3 = (k : ZMod m)) ∧
  ¬ ∃ x y z : ℤ, |x| ≤ B ∧ |y| ≤ B ∧ |z| ≤ B ∧ x ^ 3 + y ^ 3 + z ^ 3 = k