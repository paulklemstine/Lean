/-! # CatalogBuild.Speculative.RosettaStone.CrossBridge_IdempotentThread

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 10
-/

import Mathlib

/-- Boolean: inf is universally idempotent in any semilattice. -/
theorem lattice_inf_idempotent {α : Type*} [SemilatticeInf α] (a : α) :
    a ⊓ a = a := inf_idem a


/-- Ring: complementary idempotent. -/
theorem ring_idempotent_complement {R : Type*} [Ring R] (e : R) (he : e * e = e) :
    (1 - e) * (1 - e) = 1 - e := by
  have h1 : (1 - e) * e = 0 := by rw [sub_mul, one_mul, he, sub_self]
  calc (1 - e) * (1 - e) = 1 - e - (1 - e) * e := by rw [mul_sub, mul_one]
    _ = 1 - e - 0 := by rw [h1]
    _ = 1 - e := by rw [sub_zero]


/-- The tropical lattice identity. -/
theorem tropical_is_lattice_idempotent (a b : ℝ) :
    min a b = a ⊓ b := rfl


/-- Stone ≤ Gelfand: idempotent and its complement. -/
theorem boolean_to_projection {R : Type*} [Ring R] (e : R)
    (he : e * e = e) : e * e = e ∧ (1 - e) * (1 - e) = 1 - e :=
  ⟨he, ring_idempotent_complement e he⟩


/-- Gelfand ≤ NC Geometry: commutative projections commute. -/
theorem commutative_projections_commute {R : Type*} [CommRing R]
    (e f : R) : e * f = f * e := mul_comm e f


/-- Classical ≤ Tropical: multiplication distributes over min for nonneg. -/
theorem classical_to_tropical_distrib (a b c : ℝ) (ha : 0 ≤ a) :
    a * min b c = min (a * b) (a * c) :=
  mul_min_of_nonneg b c ha


/-- ℤ/1ℤ is trivially all-idempotent. -/
theorem zmod1_all_idempotent :
    ∀ e : ZMod 1, e * e = e := by
  intro e; exact Subsingleton.elim _ _


/-- ℤ/2ℤ: both elements are idempotent. -/
theorem zmod2_all_idempotent :
    ∀ e : ZMod 2, e * e = e := by decide


/-- ℤ/3ℤ: 2 idempotents. -/
theorem zmod3_idempotent_count :
    (Finset.univ.filter (fun e : ZMod 3 => e * e = e)).card = 2 := by decide


/-- ℤ/30ℤ: 8 idempotents (2³ since 30 = 2·3·5). -/
theorem zmod30_idempotent_count :
    (Finset.univ.filter (fun e : ZMod 30 => e * e = e)).card = 8 := by decide

