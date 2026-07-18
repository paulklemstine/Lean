/-
# Stochastic Galois theory: roots, fixed points, and the finite-field correction

The proposed finite-field `S_n` Galois-group claim is false for `n ≥ 3`: finite-field
Galois groups are cyclic.  The valid random-permutation connection is instead between
factorization/Frobenius cycle statistics and permutation cycle statistics.

This file proves an exact first-moment bridge.  A monic degree-`n` polynomial over a
finite commutative ring is represented by its `n` lower coefficients.  For `n > 0`,
the total number of (polynomial, root) incidences is `|K|^n`.  Independently, the total
number of (permutation, fixed-point) incidences in `S_n` is `n!`.  Thus both uniform
models have expected fixed-point/root count exactly one.  It also proves the cyclicity
obstruction to identifying a finite-field Galois group with `S_n` for `n ≥ 3`.
-/
import Mathlib

open Finset Equiv
open scoped BigOperators

namespace StochasticGaloisBridge

section Roots

variable {K : Type*} [CommRing K] [Fintype K] [DecidableEq K]

/-- Evaluation of the monic polynomial `X^n + ∑ i, v i X^i`. -/
def monicEval (n : ℕ) (v : Fin n → K) (r : K) : K :=
  r ^ n + ∑ i : Fin n, v i * r ^ (i : ℕ)

/-- For a prescribed root, exactly `|K|^m` monic polynomials of degree `m+1`
have that root.  The constant coefficient is uniquely forced. -/
lemma card_polynomials_with_prescribed_root (m : ℕ) (r : K) :
    (univ.filter (fun v : Fin (m + 1) → K => monicEval (m + 1) v r = 0)).card
      = (Fintype.card K) ^ m := by
  set S := {v : Fin (m + 1) → K | monicEval (m + 1) v r = 0}
  have hS : ∀ v : Fin (m + 1) → K,
      v ∈ S ↔ v 0 = -(r ^ (m + 1) + ∑ j : Fin m, v j.succ * r ^ (j.succ : ℕ)) := by
    simp only [S, Set.mem_setOf_eq, monicEval]
    intro v
    rw [Fin.sum_univ_succ]
    simp only [Fin.val_zero, pow_zero, mul_one]
    constructor <;> intro h <;> linear_combination h
  let e : S ≃ (Fin m → K) := Equiv.ofBijective
    (fun v j => v.1 j.succ)
    (by
      constructor
      · intro a b hab
        apply Subtype.ext
        funext i
        induction i using Fin.inductionOn with
        | zero =>
            rw [(hS a).1 a.2, (hS b).1 b.2]
            congr 2
            apply Finset.sum_congr rfl
            intro j _
            rw [show a.1 j.succ = b.1 j.succ from congrFun hab j]
        | succ i => exact congrFun hab i
      · intro a
        let v : Fin (m + 1) → K :=
          Fin.cons (-(r ^ (m + 1) + ∑ j : Fin m, a j * r ^ (j.succ : ℕ))) a
        have hv : v ∈ S := (hS v).2 (by simp [v])
        exact ⟨⟨v, hv⟩, by funext j; simp [v]⟩)
  have hc := Fintype.card_congr e
  simpa [Fintype.card_subtype, S, Fintype.card_pi] using hc

/-- Exact arithmetic first moment: the sum of the numbers of roots over all monic
coefficient vectors is the number of coefficient vectors itself. -/
theorem total_root_incidences (n : ℕ) (hn : 0 < n) :
    ∑ v : Fin n → K, (univ.filter (fun r : K => monicEval n v r = 0)).card
      = (Fintype.card K) ^ n := by
  obtain ⟨m, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn.ne'
  simp only [card_filter]
  rw [Finset.sum_comm]
  simp only [← card_filter, card_polynomials_with_prescribed_root]
  rw [sum_const, card_univ, smul_eq_mul, pow_succ']

end Roots

section Permutations

/-- Orbit-stabilizer count: exactly `(n-1)!` permutations fix a chosen letter. -/
lemma card_permutations_fixing (n : ℕ) (hn : 0 < n) (i : Fin n) :
    #(univ.filter (fun σ : Perm (Fin n) => σ i = i)) = (n - 1).factorial := by
  haveI : NeZero n := ⟨hn.ne'⟩
  have hstab : #(univ.filter (fun σ : Perm (Fin n) => σ i = i))
      = Fintype.card (MulAction.stabilizer (Perm (Fin n)) i) := by
    rw [Fintype.card_subtype]
    rfl
  have horbit : Fintype.card (MulAction.orbit (Perm (Fin n)) i) = n := by
    rw [MulAction.orbit_eq_univ]
    simp
  have hos := MulAction.card_orbit_mul_card_stabilizer_eq_card_group (Perm (Fin n)) i
  rw [horbit, Fintype.card_perm, Fintype.card_fin] at hos
  have hmul : n * (n - 1).factorial = n.factorial := Nat.mul_factorial_pred hn.ne'
  rw [hstab]
  exact Nat.eq_of_mul_eq_mul_left hn (hos.trans hmul.symm)

/-- Exact combinatorial first moment: the sum of fixed-point counts over `S_n` is `n!`. -/
theorem total_fixed_point_incidences (n : ℕ) (hn : 0 < n) :
    ∑ σ : Perm (Fin n), #(univ.filter (fun i : Fin n => σ i = i)) = n.factorial := by
  simp_rw [card_filter]
  rw [Finset.sum_comm]
  have hfiber : ∀ i : Fin n,
      ∑ σ : Perm (Fin n), (if σ i = i then 1 else 0) = (n - 1).factorial := by
    intro i
    rw [← card_filter]
    exact card_permutations_fixing n hn i
  rw [Finset.sum_congr rfl (fun i _ => hfiber i), sum_const, card_univ,
    Fintype.card_fin, smul_eq_mul]
  exact Nat.mul_factorial_pred hn.ne'

end Permutations

section Bridge

variable {K : Type*} [CommRing K] [Fintype K] [DecidableEq K]

/-- **Root/fixed-point bridge.** After clearing the two sample-space sizes, the total
root incidence in the monic-polynomial model equals the total fixed-point incidence in
the permutation model.  Equivalently, each uniform model has first moment exactly one. -/
theorem root_fixed_point_bridge (n : ℕ) (hn : 0 < n) :
    (∑ v : Fin n → K, #(univ.filter (fun r : K => monicEval n v r = 0))) * n.factorial
      = (∑ σ : Perm (Fin n), #(univ.filter (fun i : Fin n => σ i = i)))
          * (Fintype.card K) ^ n := by
  rw [total_root_incidences n hn, total_fixed_point_incidences n hn, mul_comm]

end Bridge

section Correction

/-- `S_n` is noncommutative for `n ≥ 3`. -/
lemma symmetric_group_not_commutative (n : ℕ) (hn : 3 ≤ n) :
    ¬ ∀ a b : Perm (Fin n), a * b = b * a := by
  simp +zetaDelta at *
  refine ⟨Equiv.swap ⟨0, by omega⟩ ⟨1, by omega⟩,
    Equiv.swap ⟨1, by omega⟩ ⟨2, by omega⟩, ?_⟩
  intro h
  have h0 := congr_arg (fun f => f ⟨0, by omega⟩) h
  simp [Equiv.swap_apply_def] at h0

/-- **Finite-field correction.** A finite-field Galois group is cyclic and hence cannot
be isomorphic to `S_n` when `n ≥ 3`.  Thus the meaningful finite-field random-permutation
analogy concerns Frobenius cycle type, not the abstract Galois group being `S_n`. -/
theorem finite_field_galois_group_not_symmetric
    (K L : Type*) [Field K] [Field L] [Algebra K L] [Finite L]
    (n : ℕ) (hn : 3 ≤ n) :
    IsEmpty ((L ≃ₐ[K] L) ≃* Perm (Fin n)) := by
  constructor
  intro e
  haveI : IsCyclic (L ≃ₐ[K] L) := FiniteField.instIsCyclicAlgEquivOfFinite K L
  haveI : IsCyclic (Perm (Fin n)) := isCyclic_of_surjective e.toMonoidHom e.surjective
  refine symmetric_group_not_commutative n hn (fun a b => ?_)
  obtain ⟨g, hg⟩ := IsCyclic.exists_generator (α := Perm (Fin n))
  obtain ⟨i, rfl⟩ := hg a
  obtain ⟨j, rfl⟩ := hg b
  rw [← zpow_add, ← zpow_add, add_comm]

end Correction

end StochasticGaloisBridge