import Mathlib

/-!
# Sums of Three Cubes: the Exact Modulo-Nine Obstruction

This file proves that reduction modulo nine gives exactly one obstruction:
a residue is a sum of three cubes in `ZMod 9` precisely when it is not `4`
or `5`. It also records global consequences, sign symmetry, a polynomial
family of integral points, and the corresponding affine-cubic-surface view.
-/

namespace SumsOfThreeCubes

/-- An integer is globally representable by three integral cubes. -/
def Representable (k : ℤ) : Prop :=
  ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = k

/-- The familiar modulo-nine obstruction. -/
def ForbiddenModNine (k : ℤ) : Prop :=
  k % 9 = 4 ∨ k % 9 = 5

/-- Solvability of the cubic equation after reduction modulo `n`. -/
def LocallyRepresentable (k : ℤ) (n : ℕ) : Prop :=
  ∃ x y z : ZMod n, x ^ 3 + y ^ 3 + z ^ 3 = (k : ZMod n)

/-- The affine cubic surface over a commutative ring. -/
def CubicSurface (R : Type*) [CommRing R] (k : R) : Set (R × R × R) :=
  {p | p.1 ^ 3 + p.2.1 ^ 3 + p.2.2 ^ 3 = k}

/-- Every integral cube is congruent to `0`, `1`, or `-1` modulo nine. -/
theorem cube_residue_mod_nine (x : ℤ) :
    x ^ 3 % 9 = 0 ∨ x ^ 3 % 9 = 1 ∨ x ^ 3 % 9 = 8 := by
  have hnonneg := Int.emod_nonneg x (by norm_num : (9 : ℤ) ≠ 0)
  have hlt := Int.emod_lt_of_pos x (by norm_num : (0 : ℤ) < 9)
  norm_num [pow_succ, Int.mul_emod]
  interval_cases x % 9 <;> norm_num

/-- Three cube residues modulo nine cannot sum to `4` or `5`. -/
theorem three_cube_residues_avoid_forbidden
    (a b c : ℤ)
    (ha : a % 9 = 0 ∨ a % 9 = 1 ∨ a % 9 = 8)
    (hb : b % 9 = 0 ∨ b % 9 = 1 ∨ b % 9 = 8)
    (hc : c % 9 = 0 ∨ c % 9 = 1 ∨ c % 9 = 8) :
    (a + b + c) % 9 ≠ 4 ∧ (a + b + c) % 9 ≠ 5 := by
  omega

/-- Global representability forces avoidance of the two forbidden classes. -/
theorem representable_not_forbidden {k : ℤ} (h : Representable k) :
    ¬ ForbiddenModNine k := by
  rcases h with ⟨x, y, z, rfl⟩
  exact fun hbad => by
    have havoid := three_cube_residues_avoid_forbidden
      (x ^ 3) (y ^ 3) (z ^ 3)
      (cube_residue_mod_nine x) (cube_residue_mod_nine y) (cube_residue_mod_nine z)
    rcases hbad with h4 | h5
    · exact havoid.1 h4
    · exact havoid.2 h5

/-- Every non-forbidden residue has an explicit three-cube solution modulo nine. -/
theorem not_forbidden_locally_mod_nine {k : ℤ} (h : ¬ ForbiddenModNine k) :
    LocallyRepresentable k 9 := by
  have hnonneg := Int.emod_nonneg k (by norm_num : (9 : ℤ) ≠ 0)
  have hlt := Int.emod_lt_of_pos k (by norm_num : (0 : ℤ) < 9)
  have hkcast : (k : ZMod 9) = (k % 9 : ℤ) := by
    exact (ZMod.intCast_mod k 9).symm
  unfold ForbiddenModNine at h
  unfold LocallyRepresentable
  interval_cases hk : k % 9
  · exact ⟨0, 0, 0, by rw [hkcast]; norm_num⟩
  · exact ⟨1, 0, 0, by rw [hkcast]; norm_num⟩
  · exact ⟨1, 1, 0, by rw [hkcast]; norm_num⟩
  · exact ⟨1, 1, 1, by rw [hkcast]; norm_num⟩
  · exact (h (Or.inl (by omega))).elim
  · exact (h (Or.inr (by omega))).elim
  · exact ⟨-1, -1, -1, by rw [hkcast]; decide⟩
  · exact ⟨-1, -1, 0, by rw [hkcast]; decide⟩
  · exact ⟨-1, 0, 0, by rw [hkcast]; decide⟩

/-- Local solvability modulo nine rules out residues `4` and `5`. -/
theorem locally_mod_nine_not_forbidden {k : ℤ}
    (h : LocallyRepresentable k 9) : ¬ ForbiddenModNine k := by
  intro hbad
  rcases hbad with h4 | h5
  · revert h
    rw [← Int.emod_add_mul_ediv k 9, h4]
    unfold LocallyRepresentable
    simp +decide
    erw [show (9 : ZMod 9) = 0 by rfl]
    simp +decide
  · revert h
    rw [← Int.emod_add_mul_ediv k 9, h5]
    unfold LocallyRepresentable
    simp +decide [ZMod, Fin.ext_iff, Fin.val_add, Fin.val_mul]

/-- **Exact local theorem.** The mod-nine cubic surface has a point if and only
if the target is not congruent to `4` or `5`. -/
theorem locally_mod_nine_iff_not_forbidden (k : ℤ) :
    LocallyRepresentable k 9 ↔ ¬ ForbiddenModNine k := by
  constructor
  · exact locally_mod_nine_not_forbidden
  · exact not_forbidden_locally_mod_nine

/-- Any integral point reduces to a point modulo every modulus. -/
theorem global_implies_local {k : ℤ} {n : ℕ}
    (h : Representable k) : LocallyRepresentable k n := by
  rcases h with ⟨x, y, z, hxyz⟩
  refine ⟨x, y, z, ?_⟩
  simpa using congrArg (fun q : ℤ => (q : ZMod n)) hxyz

/-- An integral point on the cubic surface is the same data as a global
three-cube representation. -/
theorem representable_iff_surface_nonempty (k : ℤ) :
    Representable k ↔ (CubicSurface ℤ k).Nonempty := by
  simp [Representable, CubicSurface, Set.Nonempty]

/-- Representability is invariant under changing all signs. -/
theorem representable_neg_iff (k : ℤ) :
    Representable (-k) ↔ Representable k := by
  constructor <;> rintro ⟨x, y, z, h⟩ <;>
    refine ⟨-x, -y, -z, ?_⟩ <;> nlinarith

/-- A two-parameter identity producing integral points on infinitely many cubic surfaces. -/
theorem vieta_three_cube_identity (a b : ℤ) :
    a ^ 3 + b ^ 3 + (-a - b) ^ 3 = -3 * a * b * (a + b) := by
  ring

/-- Every value in the Vieta family is globally representable. -/
theorem vieta_family_representable (a b : ℤ) :
    Representable (-3 * a * b * (a + b)) := by
  exact ⟨a, b, -a - b, vieta_three_cube_identity a b⟩

/-- The specialization `6t³` has a representation with all three coordinates
nonzero whenever `t` is nonzero. -/
theorem six_times_cube_genuine_family {t : ℤ} (ht : t ≠ 0) :
    ∃ x y z : ℤ, x ≠ 0 ∧ y ≠ 0 ∧ z ≠ 0 ∧
      x ^ 3 + y ^ 3 + z ^ 3 = 6 * t ^ 3 := by
  refine ⟨2 * t, -t, -t, mul_ne_zero (by norm_num) ht, neg_ne_zero.mpr ht,
    neg_ne_zero.mpr ht, ?_⟩
  ring

/-- Both forbidden congruence classes consist entirely of integers which are
not sums of three cubes. -/
theorem forbidden_progressions_not_representable (t : ℤ) :
    ¬ Representable (9 * t + 4) ∧ ¬ Representable (9 * t + 5) := by
  constructor <;> intro hrep
  · exact representable_not_forbidden hrep (Or.inl (by omega))
  · exact representable_not_forbidden hrep (Or.inr (by omega))

end SumsOfThreeCubes