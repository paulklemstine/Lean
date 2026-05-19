/-
Copyright (c) 2025. All rights reserved.

# CRT Compression for Primitive Residue Solutions

## Main Results

- `primitiveResidueSolution_mul_iff`: For coprime M, N with M > 1, N > 1,
  `PrimitiveResidueSolution (M * N) x y z ↔
    PrimitiveResidueSolution M x y z ∧ PrimitiveResidueSolution N x y z`

This is the **foundational local-global theorem** of the obstruction theory:
the search for primitive residue solutions decomposes completely over
coprime factors.

## Proof Strategy

Uses the ring isomorphism `ZMod (M * N) ≃+* ZMod M × ZMod N` from
Mathlib's `ZMod.chineseRemainder`. Units in a product ring are exactly
pairs of units (`Prod.isUnit_iff`), and ring isomorphisms preserve both
units and polynomial equations.
-/
import Mathlib
import Speculative.Beal.Defs
import Speculative.Beal.Monotonicity

open ZMod

/-! ## CRT Compression: Forward Direction -/

/-- Forward direction: a solution at M*N projects to solutions at M and N. -/
theorem primitiveResidueSolution_mul_of
    {M N x y z : ℕ}
    (_hcop : Nat.Coprime M N)
    (hsol : PrimitiveResidueSolution (M * N) x y z) :
    PrimitiveResidueSolution M x y z ∧ PrimitiveResidueSolution N x y z :=
  ⟨primitiveResidueSolution_of_dvd (dvd_mul_right M N) hsol,
   primitiveResidueSolution_of_dvd (dvd_mul_left N M) hsol⟩

/-! ## CRT Compression: Backward Direction -/

/-
Backward direction: solutions at coprime M and N lift to M*N.
This is the hard direction, using the CRT isomorphism.
-/
theorem primitiveResidueSolution_of_factors
    {M N x y z : ℕ}
    (hcop : Nat.Coprime M N)
    (hM : PrimitiveResidueSolution M x y z)
    (hN : PrimitiveResidueSolution N x y z) :
    PrimitiveResidueSolution (M * N) x y z := by
  -- By the Chinese Remainder Theorem, there exists a ring isomorphism $\phi : \mathbb{Z} / (MN) \mathbb{Z} \to \mathbb{Z} / M \mathbb{Z} \times \mathbb{Z} / N \mathbb{Z}$.
  obtain ⟨ϕ, hϕ⟩ : ∃ ϕ : ZMod (M * N) ≃+* ZMod M × ZMod N, True := by
    exact ⟨ ZMod.chineseRemainder hcop, trivial ⟩;
  -- By the properties of the Chinese Remainder Theorem, we can lift the solutions from ZMod M and ZMod N to ZMod (M * N).
  obtain ⟨a₁, b₁, c₁, ha₁, hb₁, hc₁, h_eq₁⟩ := hM
  obtain ⟨a₂, b₂, c₂, ha₂, hb₂, hc₂, h_eq₂⟩ := hN
  use ϕ.symm (a₁, a₂), ϕ.symm (b₁, b₂), ϕ.symm (c₁, c₂);
  simp_all +decide [← map_pow, ← map_add ];
  exact ⟨ Prod.isUnit_iff.mpr ⟨ ha₁, ha₂ ⟩, Prod.isUnit_iff.mpr ⟨ hb₁, hb₂ ⟩, Prod.isUnit_iff.mpr ⟨ hc₁, hc₂ ⟩ ⟩

/-! ## CRT Compression: Main Theorem -/

/-- **CRT Compression Theorem**: Primitive residue solvability decomposes
completely over coprime moduli.

For coprime `M, N`, solutions modulo `M * N` exist if and only if
solutions exist modulo both `M` and `N`. This turns the search for
obstructions into a completely local problem at prime powers. -/
theorem primitiveResidueSolution_mul_iff
    {M N x y z : ℕ}
    (hcop : Nat.Coprime M N) :
    PrimitiveResidueSolution (M * N) x y z ↔
      PrimitiveResidueSolution M x y z ∧ PrimitiveResidueSolution N x y z :=
  ⟨primitiveResidueSolution_mul_of hcop,
   fun ⟨hM, hN⟩ => primitiveResidueSolution_of_factors hcop hM hN⟩

/-- **Obstruction from prime power factors**: if any prime power factor of N
obstructs, then N obstructs. This is the key reduction for computational search. -/
theorem cubic_obstruction_of_prime_power_obstruction
    {N : ℕ} (_hN : 2 ≤ N) {x y z : ℕ} :
    (∃ p k : ℕ, Nat.Prime p ∧ 1 ≤ k ∧ p ^ k ∣ N ∧
      ¬ PrimitiveResidueSolution (p ^ k) x y z) →
    ¬ PrimitiveResidueSolution N x y z := by
  rintro ⟨p, k, _, _, hdvd, hno⟩
  exact no_primitiveResidueSolution_of_dvd hdvd hno