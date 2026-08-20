/-
# From refined coefficients to genuine Solomon zeta coefficients

The Solomon zeta function of a lattice `M` is the Dirichlet series
`ζ_M(s) = Σ_{N ≤ M of finite index} [M : N]^{-s}`, whose `k`-th coefficient is the number of
submodules of index `k`.  The *refined* (Bushnell–Reiner) coefficients
`SolomonZeta.quotIsoCount` count submodules with a prescribed quotient isomorphism type; the
genuine coefficient is the sum of the refined ones over all isomorphism types of order `k`.

This file introduces the index-counting coefficient `SolomonZeta.indexCount` and identifies it
with refined coefficients in the two cases where the isomorphism type is unique:

* `SolomonZeta.indexCount_prime` — quotients of prime order are cyclic, so the `p`-th Solomon
  coefficient of `ℤⁿ` is `1 + p + ⋯ + pⁿ⁻¹`;
* `SolomonZeta.indexCount_int_eq_one` — every index is attained exactly once by a sublattice of
  the rank one lattice, i.e. `ζ_ℤ(s) = ζ(s)`.
-/
import Catalog.Shared.SolomonZeta.Applications

namespace SolomonZeta

open Finset

variable {R M : Type*} [Ring R] [AddCommGroup M] [Module R M]

variable (R M) in
/-- The `k`-th Solomon zeta coefficient of the lattice `M`: the number of submodules of index
`k`. -/
noncomputable def indexCount (k : ℕ) : ℕ := Nat.card {N : Submodule R M // Nat.card (M ⧸ N) = k}

/-- Any abelian group of prime order `p` is `ℤ`-linearly isomorphic to `ℤ/p`. -/
theorem linearEquiv_zmod_of_card_prime (A : Type*) [AddCommGroup A] (p : ℕ) [Fact p.Prime]
    (h : Nat.card A = p) : Nonempty (A ≃ₗ[ℤ] ZMod p) :=
  ⟨AddEquiv.toIntLinearEquiv (addEquivOfPrimeCardEq h (by simp))⟩

/-- Submodules of prime index are exactly the submodules with cyclic quotient of that order. -/
theorem indexCount_prime_eq_quotIsoCount (p : ℕ) [Fact p.Prime] :
    indexCount ℤ M p = quotIsoCount ℤ M (ZMod p) := by
  have hset : {N : Submodule ℤ M | Nat.card (M ⧸ N) = p}
      = {N : Submodule ℤ M | Nonempty ((M ⧸ N) ≃ₗ[ℤ] ZMod p)} := by
    ext N
    constructor
    · intro h
      exact linearEquiv_zmod_of_card_prime _ p h
    · rintro ⟨e⟩
      show Nat.card (M ⧸ N) = p
      rw [Nat.card_congr e.toEquiv]
      simp
  rw [indexCount, quotIsoCount,
    show {N : Submodule ℤ M // Nat.card (M ⧸ N) = p}
      = ↥({N : Submodule ℤ M | Nat.card (M ⧸ N) = p}) from rfl,
    show {N : Submodule ℤ M // Nonempty ((M ⧸ N) ≃ₗ[ℤ] ZMod p)}
      = ↥({N : Submodule ℤ M | Nonempty ((M ⧸ N) ≃ₗ[ℤ] ZMod p)}) from rfl, hset]

/-- **The `p`-th Solomon zeta coefficient of the free lattice of rank `n`.** -/
theorem indexCount_prime (p : ℕ) [Fact p.Prime] (n : ℕ) :
    (indexCount ℤ (Fin n → ℤ) p : ℤ) = ∑ i ∈ Finset.range n, (p : ℤ) ^ i := by
  rw [indexCount_prime_eq_quotIsoCount, card_index_p_sublattices_geom]

/-! ### The rank one lattice -/

/-- Every submodule of `ℤ` has a cyclic quotient of the corresponding order. -/
theorem int_quot_linearEquiv_zmod (N : Submodule ℤ ℤ) :
    Nonempty ((ℤ ⧸ N) ≃ₗ[ℤ] ZMod (Nat.card (ℤ ⧸ N))) := by
  obtain ⟨m, hm⟩ := IsPrincipalIdealRing.principal N
  have hm' : N = Submodule.span ℤ {m} := hm
  subst hm'
  have e : (ℤ ⧸ (Submodule.span ℤ {m} : Submodule ℤ ℤ)) ≃ₗ[ℤ] ZMod m.natAbs :=
    AddEquiv.toIntLinearEquiv (Int.quotientSpanEquivZMod m).toAddEquiv
  have hcard : Nat.card (ℤ ⧸ (Submodule.span ℤ {m} : Submodule ℤ ℤ)) = m.natAbs := by
    rw [Nat.card_congr e.toEquiv]
    simp
  rw [hcard]
  exact ⟨e⟩

/-- **`ζ_ℤ(s) = ζ(s)`.**  For every `k ≥ 1` the rank one lattice `ℤ` has exactly one sublattice
of index `k`, so all its Solomon zeta coefficients are `1`. -/
theorem indexCount_int_eq_one (k : ℕ) (hk : 0 < k) : indexCount ℤ ℤ k = 1 := by
  have hset : {N : Submodule ℤ ℤ | Nat.card (ℤ ⧸ N) = k}
      = {N : Submodule ℤ ℤ | Nonempty ((ℤ ⧸ N) ≃ₗ[ℤ] ZMod k)} := by
    ext N
    constructor
    · intro h
      obtain ⟨e⟩ := int_quot_linearEquiv_zmod N
      rw [h] at e
      exact ⟨e⟩
    · rintro ⟨e⟩
      haveI : NeZero k := ⟨hk.ne'⟩
      show Nat.card (ℤ ⧸ N) = k
      rw [Nat.card_congr e.toEquiv]
      simp
  rw [indexCount,
    show {N : Submodule ℤ ℤ // Nat.card (ℤ ⧸ N) = k}
      = ↥({N : Submodule ℤ ℤ | Nat.card (ℤ ⧸ N) = k}) from rfl, hset]
  exact quotIsoCount_int_zmod k hk

end SolomonZeta