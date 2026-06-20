import Mathlib

/-!
# A union-bound style piercing lemma

This file proves a finite combinatorial core: if a family of finite subsets covers a
finite type, then the cardinality of the type is bounded by the sum of the cardinalities
of the subsets. From this we derive a "piercing" union bound, and specialize it to affine
zero sets of multivariate polynomials over a finite field.
-/

namespace RandomPiercing

open Finset

/-- If a family of finite subsets `A` covers a finite type `Ω`, then the cardinality of `Ω`
is bounded by the sum of the cardinalities of the `A i`. -/
theorem card_univ_le_sum_card_of_cover {Ω : Type*} [Fintype Ω] [DecidableEq Ω] {k : ℕ}
    (A : Fin k → Finset Ω) (hcover : ∀ x : Ω, ∃ i : Fin k, x ∈ A i) :
    Fintype.card Ω ≤ ∑ i : Fin k, (A i).card :=
  le_trans
    (Finset.card_le_card
      (show Finset.univ ⊆ Finset.biUnion Finset.univ A from
        fun x _ => by obtain ⟨i, hi⟩ := hcover x; aesop))
    Finset.card_biUnion_le

/-- A finite piercing union bound: if the sets `A i` cover `Ω` and each satisfies
`q * (A i).card ≤ d * |Ω|`, then `q ≤ k * d`. -/
theorem finite_piercing_union_bound {Ω : Type*} [Fintype Ω] [DecidableEq Ω] {k q d : ℕ}
    (A : Fin k → Finset Ω) (hΩ : 0 < Fintype.card Ω)
    (hcover : ∀ x : Ω, ∃ i : Fin k, x ∈ A i)
    (hbound : ∀ i : Fin k, q * (A i).card ≤ d * Fintype.card Ω) :
    q ≤ k * d := by
  -- From the cover lemma we get `|Ω| ≤ ∑ i, (A i).card`. Multiply both sides by `q`.
  have hN : Fintype.card Ω ≤ ∑ i, (A i).card := card_univ_le_sum_card_of_cover A hcover
  have hqN : q * Fintype.card Ω ≤ q * ∑ i, (A i).card := Nat.mul_le_mul_left _ hN
  -- Bound the summed term by `(k * d) * |Ω|` using `hbound`.
  have hqN_simplified : q * Fintype.card Ω ≤ k * d * Fintype.card Ω :=
    hqN.trans (by
      simpa [mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _] using
        Finset.sum_le_sum fun i (_ : i ∈ Finset.univ) => hbound i)
  -- Cancel the positive factor `|Ω|`.
  exact le_of_not_gt fun h => by nlinarith

/-- The zero set of a multivariate polynomial over a finite field, as a finset of points. -/
noncomputable def zeroSet {K : Type*} [Field K] [Fintype K] [DecidableEq K] {n : ℕ}
    (p : MvPolynomial (Fin n) K) : Finset (Fin n → K) :=
  Finset.univ.filter fun x => MvPolynomial.eval x p = 0

/-- Specialization of the piercing union bound to affine zero sets of polynomials. -/
theorem affine_zeroSet_piercing_union_bound {K : Type*} [Field K] [Fintype K] [DecidableEq K]
    {n k q d : ℕ} (p : Fin k → MvPolynomial (Fin n) K)
    (hcover : ∀ x : Fin n → K, ∃ i : Fin k, x ∈ zeroSet (p i))
    (hSZ : ∀ i : Fin k, q * (zeroSet (p i)).card ≤ d * Fintype.card (Fin n → K)) :
    q ≤ k * d :=
  finite_piercing_union_bound (Ω := Fin n → K) (fun i => zeroSet (p i))
    (Fintype.card_pos_iff.mpr inferInstance) hcover hSZ

end RandomPiercing