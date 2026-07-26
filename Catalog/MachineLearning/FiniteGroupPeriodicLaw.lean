import Mathlib

/-!
# A limitation of a periodic table based on coarse group invariants

This file gives a machine-checked counterexample to the proposed predictive principle.
For every odd `n > 1`, the cyclic group of order `2n` and the dihedral group of the
same order have the same cardinality and the same group exponent, but one is cyclic
and commutative while the other is neither.  Thus even the pair “atomic number +
exponent” does not determine basic structural behavior.

At order six this compares `C₆ = Multiplicative (ZMod 6)` with `D₆ = DihedralGroup 3`.
-/

namespace FiniteGroupPeriodicLaw

/-- The cyclic comparison group has order `2 * n`. -/
theorem cyclic_card (n : ℕ) [NeZero n] :
    Fintype.card (Multiplicative (ZMod (2 * n))) = 2 * n := by
  letI : NeZero (2 * n) := ⟨mul_ne_zero (by omega) (NeZero.ne n)⟩
  calc
    Fintype.card (Multiplicative (ZMod (2 * n))) = Fintype.card (ZMod (2 * n)) :=
      Fintype.card_congr Multiplicative.toAdd
    _ = 2 * n := ZMod.card (2 * n)

/-- The dihedral comparison group has order `2 * n` when `n` is nonzero. -/
theorem dihedral_card (n : ℕ) [NeZero n] :
    Fintype.card (DihedralGroup n) = 2 * n := by
  exact DihedralGroup.card

/-- For odd `n`, the cyclic group of order `2n` has exponent `2n`. -/
theorem cyclic_exponent (n : ℕ) [NeZero n] :
    Monoid.exponent (Multiplicative (ZMod (2 * n))) = 2 * n := by
  letI : NeZero (2 * n) := ⟨mul_ne_zero (by omega) (NeZero.ne n)⟩
  rw [IsCyclic.exponent_eq_card, Nat.card_eq_fintype_card]
  exact cyclic_card n

/-- For odd `n`, the dihedral group of order `2n` also has exponent `2n`. -/
theorem dihedral_exponent_of_odd {n : ℕ} (hn : Odd n) :
    Monoid.exponent (DihedralGroup n) = 2 * n := by
  rw [DihedralGroup.exponent]
  simpa [Nat.mul_comm] using hn.coprime_two_right.lcm_eq_mul

/-- Cyclic groups in the comparison family are commutative. -/
theorem cyclic_commutative (n : ℕ) :
    Std.Commutative (fun x y : Multiplicative (ZMod (2 * n)) => x * y) := by
  infer_instance

/-- Nondegenerate dihedral groups in the comparison family are not commutative. -/
theorem dihedral_not_commutative {n : ℕ} (h1 : n ≠ 1) (h2 : n ≠ 2) :
    ¬ Std.Commutative (fun x y : DihedralGroup n => x * y) := by
  exact DihedralGroup.not_commutative h1 h2

/-- Nontrivial dihedral groups are not cyclic. -/
theorem dihedral_not_cyclic {n : ℕ} (h1 : n ≠ 1) :
    ¬ IsCyclic (DihedralGroup n) := by
  exact DihedralGroup.not_isCyclic h1

/--
**Main theorem.** For every odd `n > 1`, two finite groups have the same order and
exponent, yet differ in cyclicity and commutativity.  The witnesses are the cyclic
group `C_(2n)` and the dihedral group `D_(2n)`.
-/
theorem same_order_exponent_different_structure
    {n : ℕ} [NeZero n] (hn : Odd n) (hgt : 1 < n) :
    Fintype.card (Multiplicative (ZMod (2 * n))) = Fintype.card (DihedralGroup n) ∧
    Monoid.exponent (Multiplicative (ZMod (2 * n))) =
      Monoid.exponent (DihedralGroup n) ∧
    IsCyclic (Multiplicative (ZMod (2 * n))) ∧
    ¬ IsCyclic (DihedralGroup n) ∧
    Std.Commutative (fun x y : Multiplicative (ZMod (2 * n)) => x * y) ∧
    ¬ Std.Commutative (fun x y : DihedralGroup n => x * y) := by
  refine ⟨?_, ?_, inferInstance, ?_, cyclic_commutative n, ?_⟩
  · rw [cyclic_card, dihedral_card]
  · rw [cyclic_exponent, dihedral_exponent_of_odd hn]
  · exact dihedral_not_cyclic (by omega)
  · exact dihedral_not_commutative (by omega) (by
      rintro rfl
      norm_num at hn)

/-- The smallest concrete witness in the family occurs at order six. -/
theorem order_six_counterexample :
    Fintype.card (Multiplicative (ZMod 6)) = Fintype.card (DihedralGroup 3) ∧
    Monoid.exponent (Multiplicative (ZMod 6)) = Monoid.exponent (DihedralGroup 3) ∧
    IsCyclic (Multiplicative (ZMod 6)) ∧
    ¬ IsCyclic (DihedralGroup 3) ∧
    Std.Commutative (fun x y : Multiplicative (ZMod 6) => x * y) ∧
    ¬ Std.Commutative (fun x y : DihedralGroup 3 => x * y) := by
  simpa using same_order_exponent_different_structure (n := 3) (by decide) (by omega)

/-- Every cyclic finite group has exactly `φ(|G|)` automorphisms. -/
theorem cyclic_automorphism_count (n : ℕ) [NeZero n] :
    Nat.card (MulAut (Multiplicative (ZMod n))) = Nat.totient n := by
  simpa using IsCyclic.card_mulAut (Multiplicative (ZMod n))

/-- In particular, the cyclic group of order six has two automorphisms. -/
theorem cyclic_six_automorphism_count :
    Nat.card (MulAut (Multiplicative (ZMod 6))) = 2 := by
  rw [cyclic_automorphism_count]
  decide

/-- The center of the cyclic comparison group is the whole group. -/
theorem cyclic_center_full (n : ℕ) :
    Subgroup.center (Multiplicative (ZMod n)) = ⊤ := by
  exact SetLike.ext fun x => by
    simp [Subgroup.mem_center_iff, mul_comm]

/-- For odd `n > 1`, the dihedral group's center is trivial. -/
theorem dihedral_center_trivial {n : ℕ} (hn : Odd n) (hgt : 1 < n) :
    Subgroup.center (DihedralGroup n) = ⊥ := by
  exact DihedralGroup.center_eq_bot_of_odd_ne_one hn (by omega)

/-- At order six, the dihedral group's center is trivial. -/
theorem dihedral_three_center_trivial :
    Subgroup.center (DihedralGroup 3) = ⊥ := by
  exact dihedral_center_trivial (by decide) (by omega)

end FiniteGroupPeriodicLaw