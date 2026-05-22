/-
Copyright (c) 2025. All rights reserved.
Character-Theoretic Rigidity: Standard Representation and Decomposition

This file defines the standard representation of `S_n` and proves
that the permutation character decomposes as trivial + standard.
-/
import Mathlib
import Algebra.RepresentationTheory.Symmetric.PermutationRep

open Finset

/-! ## Trivial and Standard Characters

We define characters as functions on the group and establish
the decomposition of the permutation character. -/

/-- The trivial character of a finite group: constantly 1. -/
noncomputable def trivialCharFn (K : Type*) [Field K]
    (G : Type*) [Group G] [Fintype G] : G → K :=
  fun _ => 1

/-- The sign character of `S_n`: maps `σ` to its sign `±1`. -/
noncomputable def signCharFn (K : Type*) [Field K] {n : ℕ} :
    Equiv.Perm (Fin n) → K :=
  fun σ => Equiv.Perm.sign σ

/-- The permutation character: maps `σ` to the number of fixed points. -/
noncomputable def permCharFn (K : Type*) [Field K] {n : ℕ} :
    Equiv.Perm (Fin n) → K :=
  fun σ => ↑(Fintype.card {i : Fin n // σ i = i})

/-- The standard character of `S_n`: `χ_std(σ) = fix(σ) - 1`.
    This corresponds to the `(n-1)`-dimensional irreducible representation. -/
noncomputable def standardCharFn (K : Type*) [Field K] {n : ℕ} :
    Equiv.Perm (Fin n) → K :=
  fun σ => permCharFn K σ - 1

/-! ## Character Decomposition Theorem

The permutation character decomposes as the trivial character plus the standard character.
This is a fundamental structural result. -/

/-
**Permutation Character Decomposition**: For any `n`, the permutation character
    equals the sum of the trivial character and the standard character.
    `χ_perm = χ_triv + χ_std`, i.e., `fix(σ) = 1 + (fix(σ) - 1)`.
-/
theorem permutation_character_decomposition (K : Type*) [Field K] [CharZero K]
    {n : ℕ} (σ : Equiv.Perm (Fin n)) :
    permCharFn K σ = trivialCharFn K (Equiv.Perm (Fin n)) σ + standardCharFn K σ := by
  unfold permCharFn trivialCharFn standardCharFn; ring;
  rfl

/-! ## Degree of the Standard Character -/

/-
The degree of the standard character (its value at the identity) is `n - 1`.
-/
theorem standardCharFn_degree (K : Type*) [Field K] [CharZero K]
    {n : ℕ} (hn : 1 ≤ n) :
    standardCharFn K (1 : Equiv.Perm (Fin n)) = (n : K) - 1 := by
  unfold standardCharFn;
  simp +decide [ permCharFn ]

/-! ## The Standard Subspace

The standard subspace is the kernel of the summation map `Fin n → K` sending
`v` to `∑ i, v i`. It is `(n-1)`-dimensional and `S_n`-invariant. -/

/-- The summation linear map: sends `v : Fin n → K` to `∑ i, v i`. -/
noncomputable def sumMap (K : Type*) [Field K] (n : ℕ) :
    (Fin n → K) →ₗ[K] K where
  toFun v := ∑ i, v i
  map_add' u v := by simp [Finset.sum_add_distrib]
  map_smul' c v := by simp [Finset.mul_sum]

/-- The standard subspace: `{v : Fin n → K | ∑ i, v i = 0}`. -/
noncomputable def standardSubspace (K : Type*) [Field K] (n : ℕ) :
    Submodule K (Fin n → K) :=
  LinearMap.ker (sumMap K n)

/-
The standard subspace is invariant under the permutation representation:
    if `∑ v i = 0` then `∑ (v ∘ σ⁻¹) i = 0`.
-/
theorem standardSubspace_invariant (K : Type*) [Field K] {n : ℕ}
    (σ : Equiv.Perm (Fin n)) (v : Fin n → K) (hv : v ∈ standardSubspace K n) :
    permLinearRep K σ v ∈ standardSubspace K n := by
  unfold permLinearRep standardSubspace at *;
  simp_all +decide [ sumMap, LinearMap.mem_ker ];
  rw [ ← hv, Equiv.sum_comp σ.symm ]

/-! ## Character Inner Product

The character inner product for a finite group is:
`⟨χ, ψ⟩ = (1/|G|) ∑ g, χ(g) * ψ(g)`
(over ℚ or ℝ, without conjugation needed for real-valued characters). -/

/-- Character inner product over a field (for real-valued characters).
    `⟨χ, ψ⟩ = (1/|G|) ∑ g, χ(g) * ψ(g)`. -/
noncomputable def characterInner (K : Type*) [Field K]
    (G : Type*) [Group G] [Fintype G]
    (χ ψ : G → K) : K :=
  (↑(Fintype.card G))⁻¹ * ∑ g : G, χ g * ψ g

/-
The trivial character has inner product 1 with itself.
    This follows from `⟨1, 1⟩ = (1/|G|) ∑ g, 1 = 1`.
-/
theorem trivialCharFn_inner_self (K : Type*) [Field K] [CharZero K]
    (G : Type*) [Group G] [Fintype G] :
    characterInner K G (trivialCharFn K G) (trivialCharFn K G) = 1 := by
  unfold characterInner trivialCharFn; simp +decide [ Finset.card_univ ] ;

/-
The trivial and standard characters are orthogonal.
    `⟨χ_triv, χ_std⟩ = 0`.
-/
theorem trivial_standard_orthogonal (K : Type*) [Field K] [CharZero K]
    {n : ℕ} (hn : 2 ≤ n) :
    characterInner K (Equiv.Perm (Fin n))
      (trivialCharFn K (Equiv.Perm (Fin n)))
      (standardCharFn K) = 0 := by
  unfold characterInner trivialCharFn standardCharFn permCharFn;
  -- Let's simplify the sum $\sum_{\sigma \in S_n} \text{fix}(\sigma)$.
  have h_sum_fix : ∑ σ : Equiv.Perm (Fin n), (Fintype.card {i : Fin n // σ i = i}) = (Fintype.card (Equiv.Perm (Fin n))) := by
    have h_sum_fixed_points : ∑ σ : Equiv.Perm (Fin n), (Finset.univ.filter (fun i => σ i = i)).card = ∑ i : Fin n, (Finset.univ.filter (fun σ : Equiv.Perm (Fin n) => σ i = i)).card := by
      simp +decide only [card_filter];
      rw [ Finset.sum_comm ];
    -- Each element $i$ is fixed by $(n-1)!$ permutations, so the sum is $n \cdot (n-1)! = n!$.
    have h_fixed_points_count : ∀ i : Fin n, (Finset.univ.filter (fun σ : Equiv.Perm (Fin n) => σ i = i)).card = (Fintype.card (Equiv.Perm (Fin n))) / n := by
      intro i
      have h_fixed_points_count : (Finset.univ.filter (fun σ : Equiv.Perm (Fin n) => σ i = i)).card * n = (Fintype.card (Equiv.Perm (Fin n))) := by
        have h_fixed_points_count : Finset.card (Finset.univ : Finset (Equiv.Perm (Fin n))) = ∑ j : Fin n, Finset.card (Finset.filter (fun σ : Equiv.Perm (Fin n) => σ i = j) Finset.univ) := by
          simp +decide only [card_eq_sum_ones, sum_fiberwise];
        -- Since these sets are disjoint and their union is the entire set of permutations, we can apply the cardinality addition formula.
        have h_card_add : ∀ j : Fin n, Finset.card (Finset.filter (fun σ : Equiv.Perm (Fin n) => σ i = j) Finset.univ) = Finset.card (Finset.filter (fun σ : Equiv.Perm (Fin n) => σ i = i) Finset.univ) := by
          intro j
          have h_bijection : Finset.filter (fun σ : Equiv.Perm (Fin n) => σ i = j) Finset.univ = Finset.image (fun σ : Equiv.Perm (Fin n) => Equiv.swap i j * σ) (Finset.filter (fun σ : Equiv.Perm (Fin n) => σ i = i) Finset.univ) := by
            ext σ; simp +decide [ Equiv.swap_apply_def ] ; aesop;
          rw [ h_bijection, Finset.card_image_of_injective _ fun x y hxy => by simpa using hxy ];
        simp_all +decide [ mul_comm ]
      exact Eq.symm (Nat.div_eq_of_eq_mul_left (by linarith) (by linarith));
    simp_all +decide [ Fintype.card_subtype ];
    rw [ Nat.mul_div_cancel' ];
    simp +decide [ Fintype.card_perm ];
    exact Nat.dvd_factorial ( by linarith ) ( by linarith );
  simp_all +decide [ Finset.sum_sub_distrib, mul_sub ];
  rw [ ← Nat.cast_sum, h_sum_fix, inv_mul_cancel₀ ( Nat.cast_ne_zero.mpr <| Fintype.card_ne_zero ), sub_self ]