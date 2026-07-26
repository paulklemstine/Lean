/-
# Finite-Field Galois Groups Are Cyclic — a Correction to the "Generic `S_n`" Picture

Over `ℚ`, a "random" polynomial has Galois group `S_n` (Hilbert irreducibility).  The
research prompt conjectures the same is asymptotically true over finite fields.  This is
in fact **false as stated**: the absolute Galois group of a finite field is
(pro)cyclic, so *every* Galois extension of a finite field has a **cyclic** — hence
abelian — Galois group.  Consequently the Galois group of a polynomial over a finite
field is *never* isomorphic to `S_n` for `n ≥ 3` (since `S_n` is non-abelian there).

What survives of the "random permutation" heuristic is the *statistics of the Frobenius
cycle type*, i.e. of the factorization type — captured in `StochasticGaloisRoots.lean`
(fixed points ↔ roots) and `StochasticGaloisDegreeTwo.lean`.  This file records the
group-theoretic obstruction.
-/
import Mathlib

namespace StochasticGalois

/-
The symmetric group on `n ≥ 3` letters is not commutative: the transpositions
`(0 1)` and `(1 2)` do not commute.
-/
lemma perm_not_comm (n : ℕ) (hn : 3 ≤ n) :
    ¬ ∀ a b : Equiv.Perm (Fin n), a * b = b * a := by
  simp +zetaDelta at *;
  refine' ⟨ Equiv.swap ⟨ 0, by linarith ⟩ ⟨ 1, by linarith ⟩, Equiv.swap ⟨ 1, by linarith ⟩ ⟨ 2, by linarith ⟩, _ ⟩;
  intro h; have := congr_arg ( fun f => f ⟨ 0, by linarith ⟩ ) h; simp +decide at this;
  simp +decide [ Equiv.swap_apply_def ] at this

/-
**Correction of the conjecture.** Over a finite field, the Galois group of any field
extension is cyclic (a theorem for finite fields), hence abelian.  Therefore it can never
be isomorphic, as a group, to the symmetric group `S_n = Equiv.Perm (Fin n)` for `n ≥ 3`.
In particular no polynomial over a finite field has Galois group `S_n` for `n ≥ 3`, so the
naive "random polynomials have Galois group `S_n`" expectation fails over finite fields.
-/
theorem finiteField_gal_ne_symm (K L : Type*) [Field K] [Field L] [Algebra K L] [Finite L]
    (n : ℕ) (hn : 3 ≤ n) :
    IsEmpty ((L ≃ₐ[K] L) ≃* Equiv.Perm (Fin n)) := by
  constructor
  intro e
  haveI : IsCyclic (L ≃ₐ[K] L) := FiniteField.instIsCyclicAlgEquivOfFinite K L
  haveI : IsCyclic (Equiv.Perm (Fin n)) :=
    isCyclic_of_surjective e.toMonoidHom e.surjective
  refine perm_not_comm n hn (fun a b => ?_)
  obtain ⟨g, hg⟩ := IsCyclic.exists_generator (α := Equiv.Perm (Fin n))
  obtain ⟨i, rfl⟩ := hg a
  obtain ⟨j, rfl⟩ := hg b
  rw [← zpow_add, ← zpow_add, add_comm]

/-- Concrete instance `n = 3`: no finite-field extension has Galois group `S_3`. -/
theorem finiteField_gal_ne_S3 (K L : Type*) [Field K] [Field L] [Algebra K L] [Finite L] :
    IsEmpty ((L ≃ₐ[K] L) ≃* Equiv.Perm (Fin 3)) :=
  finiteField_gal_ne_symm K L 3 (le_refl 3)

end StochasticGalois