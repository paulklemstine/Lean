/-
# Local-Global Geometry of the Diophantine Surface x³ + y³ + z³ = k

This file develops a comprehensive local-global theory of the classical Diophantine equation
  x³ + y³ + z³ = k
over the integers. We formalize:

1. **Core predicates**: `IsThreeCubeRepresentable`, `ForbiddenModNine`, `LocallyAtMod`,
   `AdmissibleThreeCube`, and the affine cubic surface `SumThreeCubesSurface`.

2. **Mod 9 obstruction** (Theorem 1): Every integer cube is congruent to 0, 1, or 8 mod 9,
   so x³ + y³ + z³ can never be ≡ 4 or 5 (mod 9).

3. **Negation symmetry** (Theorem 2): k is representable iff −k is representable.

4. **Cubes are representable & infinitude** (Theorem 3): m³ = m³ + 0³ + 0³, and the
   set of representable integers is infinite.

5. **Local obstruction** (Theorem 4): Forbidden mod 9 residues have no solution in ZMod 9.

6. **Global ⇒ local** (Theorem 5): An integer solution reduces to a ZMod n solution.

7. **Local-global contradiction** (Theorem 6): Combining Theorems 4 and 5 gives the
   clean obstruction principle: ForbiddenModNine k → ¬ IsThreeCubeRepresentable k.

8. **Surface viewpoint**: Ring-generic cubic surface definition and integral-to-local
   point transfer.

## Mathematical significance

The mod 9 obstruction is the *only* known universal elementary obstruction to
x³ + y³ + z³ = k. All deeper difficulty is global, sparse, and geometric rather
than purely congruential. This file formalizes the precise mechanism by which
the local-global principle operates for this equation.
-/
import Mathlib

open ZMod Int Set

/-! ## Core Definitions -/

/-- An integer `k` is representable as a sum of three integer cubes. -/
def IsThreeCubeRepresentable (k : ℤ) : Prop :=
  ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = k

/-- The residue classes modulo 9 that are forbidden for sums of three cubes. -/
def ForbiddenModNine (k : ℤ) : Prop :=
  k % 9 = 4 ∨ k % 9 = 5

/-- An integer is admissible for sum-of-three-cubes if it is not forbidden mod 9. -/
def AdmissibleThreeCube (k : ℤ) : Prop :=
  ¬ ForbiddenModNine k

/-- Local representability: there exist x, y, z in ZMod n whose cubes sum to k mod n. -/
def LocallyAtMod (k : ℤ) (n : ℕ) : Prop :=
  ∃ x y z : ZMod n, x ^ 3 + y ^ 3 + z ^ 3 = (k : ZMod n)

/-- The affine cubic surface x³ + y³ + z³ = k over ℤ. -/
def SumThreeCubesSurface (k : ℤ) : Set (ℤ × ℤ × ℤ) :=
  {P | P.1 ^ 3 + P.2.1 ^ 3 + P.2.2 ^ 3 = k}

/-- The affine cubic surface over a general commutative ring R. -/
def SumThreeCubesSurfaceR (R : Type*) [CommRing R] (k : R) : Set (R × R × R) :=
  {P | P.1 ^ 3 + P.2.1 ^ 3 + P.2.2 ^ 3 = k}

/-- `IsThreeCubeRepresentable k` is equivalent to the surface having a point. -/
theorem representable_iff_surface_nonempty (k : ℤ) :
    IsThreeCubeRepresentable k ↔ (SumThreeCubesSurface k).Nonempty := by
  simp [IsThreeCubeRepresentable, SumThreeCubesSurface, Set.Nonempty]

/-! ## Lemma: Cube residues mod 9

Every integer cube is congruent to 0, 1, or 8 modulo 9. This is the key
arithmetic fact underlying the mod 9 obstruction. -/

/-
Every integer cube mod 9 lies in {0, 1, 8}.
-/
theorem cube_mod9 (x : ℤ) : x ^ 3 % 9 = 0 ∨ x ^ 3 % 9 = 1 ∨ x ^ 3 % 9 = 8 := by
  norm_num [ pow_succ, Int.mul_emod ] ; have := Int.emod_nonneg x ( by decide : ( 9 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos x ( by decide : ( 9 : ℤ ) > 0 ) ; interval_cases x % 9 <;> trivial;

/-! ## Theorem 1: The mod 9 obstruction is necessary

If k is representable as a sum of three integer cubes, then k is not
congruent to 4 or 5 modulo 9. -/

/-
Sum of three elements from {0,1,8} mod 9 avoids 4 and 5.
-/
theorem sum_three_cube_residues_avoid_4_5
    (a b c : ℤ)
    (ha : a % 9 = 0 ∨ a % 9 = 1 ∨ a % 9 = 8)
    (hb : b % 9 = 0 ∨ b % 9 = 1 ∨ b % 9 = 8)
    (hc : c % 9 = 0 ∨ c % 9 = 1 ∨ c % 9 = 8) :
    (a + b + c) % 9 ≠ 4 ∧ (a + b + c) % 9 ≠ 5 := by
  omega

/-- **Theorem 1**: The mod 9 obstruction is necessary.
If k is a sum of three cubes, then k % 9 ∈ {0, 1, 2, 3, 6, 7, 8}. -/
theorem three_cubes_mod9_necessary {k : ℤ} :
    IsThreeCubeRepresentable k → ¬ ForbiddenModNine k := by
  intro ⟨x, y, z, hxyz⟩ hforbid
  have hx := cube_mod9 x
  have hy := cube_mod9 y
  have hz := cube_mod9 z
  have key := sum_three_cube_residues_avoid_4_5 (x ^ 3) (y ^ 3) (z ^ 3) hx hy hz
  rw [← hxyz] at hforbid
  rcases hforbid with h4 | h5
  · exact key.1 h4
  · exact key.2 h5

/-
Equivalent formulation: representable residues are in {0,1,2,3,6,7,8} mod 9.
-/
theorem three_cubes_mod9_residue {k : ℤ} :
    IsThreeCubeRepresentable k → k % 9 ∈ ({0, 1, 2, 3, 6, 7, 8} : Set ℤ) := by
  intro h
  have h_mod9 : ¬k % 9 = 4 ∧ ¬k % 9 = 5 := by
    exact ⟨ fun h' => three_cubes_mod9_necessary h <| Or.inl h', fun h' => three_cubes_mod9_necessary h <| Or.inr h' ⟩;
  have := Int.emod_nonneg k ( by decide : ( 9 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos k ( by decide : ( 9 : ℤ ) > 0 ) ; interval_cases k % 9 <;> simp +decide at h_mod9 ⊢;

/-! ## Theorem 2: Representability is closed under negation -/

/-- The fundamental sign-symmetry identity for cubes. -/
theorem neg_cube_identity (x y z : ℤ) :
    (-x) ^ 3 + (-y) ^ 3 + (-z) ^ 3 = -(x ^ 3 + y ^ 3 + z ^ 3) := by
  ring

/-
**Theorem 2**: k is representable as a sum of three cubes iff −k is.
-/
theorem three_cube_representable_neg_iff (k : ℤ) :
    IsThreeCubeRepresentable (-k) ↔ IsThreeCubeRepresentable k := by
  constructor <;> rintro ⟨ x, y, z, h ⟩ <;> use -x, -y, -z <;> linarith

/-! ## Theorem 3: Every cube is representable; infinitely many representable integers -/

/-- **Theorem 3a**: Every perfect cube is a sum of three cubes. -/
theorem three_cube_representable_of_cube (m : ℤ) :
    IsThreeCubeRepresentable (m ^ 3) := by
  exact ⟨m, 0, 0, by ring⟩

/-
The map m ↦ m³ is injective on ℤ.
-/
theorem cube_injective : Function.Injective (fun m : ℤ => m ^ 3) := by
  exact fun a b h => by nlinarith [ sq_nonneg ( a - b ), sq_nonneg ( a + b ) ] ;

/-
**Theorem 3b**: Infinitely many integers are representable as sums of three cubes.
-/
theorem infinitely_many_three_cube_representable :
    Set.Infinite {k : ℤ | IsThreeCubeRepresentable k} := by
  exact Set.infinite_of_injective_forall_mem ( cube_injective ) fun m => three_cube_representable_of_cube m

/-! ## Theorem 4: Local obstruction modulo 9

Forbidden mod 9 residues have no solution in ZMod 9. -/

/-
**Theorem 4**: If k is forbidden mod 9, then the cubic surface has no
ZMod 9 point. This is the local obstruction.
-/
theorem not_locally_representable_mod9_of_forbidden {k : ℤ} :
    ForbiddenModNine k → ¬ LocallyAtMod k 9 := by
  intro hAtMod ForbiddenModNine;
  rcases hAtMod with ( h | h ) <;> revert ForbiddenModNine <;> ( rw [ ← Int.emod_add_mul_ediv k 9, h ] ; norm_num );
  · unfold LocallyAtMod;
    simp +decide;
    erw [ show ( 9 : ZMod 9 ) = 0 by rfl ] ; simp +decide;
  · unfold LocallyAtMod;
    simp +decide [ ZMod, Fin.ext_iff, Fin.val_add, Fin.val_mul ]

/-! ## Theorem 5: Global representation implies local representation -/

/-
**Theorem 5**: Any integer solution reduces mod n to give a ZMod n solution.
This is the "easy direction" of the Hasse principle.
-/
theorem global_implies_local {k : ℤ} {n : ℕ} (_hn : 0 < n) :
    IsThreeCubeRepresentable k → LocallyAtMod k n := by
  rintro ⟨ x, y, z, h ⟩;
  exact ⟨ x, y, z, by simpa [ ← ZMod.intCast_eq_intCast_iff ] using congr_arg ( ( ↑ ) : ℤ → ZMod n ) h ⟩

/-! ## Theorem 6: Local-global contradiction / clean obstruction principle -/

/-- **Theorem 6**: Forbidden mod 9 integers are not representable.
This combines Theorems 4 and 5 into the clean obstruction principle:
global representation ⇒ local representation mod 9, but forbidden
residues fail local representation mod 9. -/
theorem forbiddenModNine_not_representable {k : ℤ} :
    ForbiddenModNine k → ¬ IsThreeCubeRepresentable k := by
  intro hforbid hrep
  have hlocal := global_implies_local (n := 9) (by norm_num) hrep
  exact not_locally_representable_mod9_of_forbidden hforbid hlocal

/-- Equivalence: admissibility is necessary for representability. -/
theorem representable_implies_admissible {k : ℤ} :
    IsThreeCubeRepresentable k → AdmissibleThreeCube k :=
  three_cubes_mod9_necessary

/-! ## Surface viewpoint: ring-generic transfer -/

/-
An integral point on the cubic surface gives a ZMod n point by reduction.
-/
theorem integral_point_gives_modn_point {k : ℤ} {n : ℕ} (_hn : 0 < n)
    (hpt : (SumThreeCubesSurface k).Nonempty) :
    (SumThreeCubesSurfaceR (ZMod n) (k : ZMod n)).Nonempty := by
  obtain ⟨ x, hx ⟩ := hpt;
  use (x.1, x.2.1, x.2.2);
  convert congr_arg ( ( ↑ ) : ℤ → ZMod n ) hx using 1;
  simp +decide [ SumThreeCubesSurfaceR ]

/-! ## Two-parameter polynomial family -/

/-- The Vieta-style identity: a³ + b³ + (−a−b)³ = −3ab(a+b). -/
theorem vieta_cubes_identity (a b : ℤ) :
    a ^ 3 + b ^ 3 + (-a - b) ^ 3 = -3 * a * b * (a + b) := by
  ring

/-- Every integer of the form −3ab(a+b) is representable. -/
theorem representable_neg3_family (a b : ℤ) :
    IsThreeCubeRepresentable (-3 * a * b * (a + b)) :=
  ⟨a, b, -a - b, by ring⟩

/-! ## Decidability of ForbiddenModNine -/

instance : DecidablePred ForbiddenModNine := fun k => by
  unfold ForbiddenModNine
  exact instDecidableOr

instance : DecidablePred AdmissibleThreeCube := fun k => by
  unfold AdmissibleThreeCube
  exact instDecidableNot

/-! ## Density: 7 out of 9 residue classes are admissible -/

/-- The set of admissible residues mod 9 has exactly 7 elements. -/
theorem admissible_residues_count :
    ({0, 1, 2, 3, 6, 7, 8} : Finset (ZMod 9)).card = 7 := by
  native_decide

/-- The set of forbidden residues mod 9 has exactly 2 elements. -/
theorem forbidden_residues_count :
    ({4, 5} : Finset (ZMod 9)).card = 2 := by
  native_decide