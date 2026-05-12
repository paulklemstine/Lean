/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.AlgebraEMLComputation.Defs

/-!
# Closure-Hankel Realization Theorems

This file proves the main theorems of closure-Hankel realization theory
over commutative semirings.

## Main results

### Proved theorems
* `wordAction_append` — composition law for word actions
* `evalLinearSystem_append` — evaluation decomposes over word append
* `realization_implies_finiteHankelGeneratorRank` — any realization gives finite generator rank
* `finiteHankelRank_implies_realization` — Hankel row rank gives realization (Myhill-Nerode)
* `minimalClosureRealization_dim_unique` — minimal realizations have unique dimension
* `finiteClosureHankelRank_implies_realization` — closure version of forward direction
* `realization_implies_closureGeneratorRank` — closure version of backward direction

### Mathematical notes

Over fields, `FiniteHankelRank` and `FiniteHankelGeneratorRank` coincide because
any finite spanning set can be refined to a basis of Hankel rows. Over general
commutative semirings, these notions differ: a behavior may have finite generator
rank (with arbitrary generating functions) without having finite Hankel row rank
(where generators must be actual Hankel rows). The forward direction
(`FiniteHankelRank → realization`) is proved constructively via the Myhill-Nerode
shift structure. The backward direction (`realization → FiniteHankelGeneratorRank`)
is proved for general generators.
-/

noncomputable section

open Finset BigOperators

universe u v

variable {Alpha : Type u} {S : Type v}

/-! ## Basic Properties of Word Actions -/

section WordAction
variable [Semiring S]

@[simp]
theorem wordAction_nil {n : ℕ}
    (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S)) :
    wordAction A [] = LinearMap.id :=
  rfl

@[simp]
theorem wordAction_cons {n : ℕ}
    (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S))
    (a : Alpha) (w : List Alpha) :
    wordAction A (a :: w) = (wordAction A w).comp (A a) :=
  rfl

/-- `wordAction` decomposes over list append. -/
theorem wordAction_append {n : ℕ}
    (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S))
    (u v : List Alpha) :
    wordAction A (u ++ v) = (wordAction A v).comp (wordAction A u) := by
  induction u with
  | nil => simp [LinearMap.comp_id]
  | cons a u ih => simp [ih, LinearMap.comp_assoc]

/-- `evalLinearSystem` decomposes over append via the state vector. -/
theorem evalLinearSystem_append {n : ℕ}
    (α β : Fin n → S)
    (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S))
    (u v : List Alpha) :
    evalLinearSystem α β A (u ++ v) =
      dotProd α (wordAction A v (wordAction A u β)) := by
  simp [evalLinearSystem, wordAction_append]

end WordAction

/-! ## Commutative Semiring Lemmas -/

section CommLemmas
variable [CommSemiring S]

/-- Standard basis vector: `e_j i = if i = j then 1 else 0`. -/
def stdBasis {n : ℕ} (j : Fin n) : Fin n → S :=
  fun i => if i = j then 1 else 0

/-- Any vector is a linear combination of standard basis vectors. -/
theorem vec_as_sum_stdBasis {n : ℕ} (x : Fin n → S) :
    x = ∑ j : Fin n, x j • stdBasis (S := S) j := by
  ext i; simp [stdBasis]

/-- `dotProd` is linear in its second argument over a commutative semiring. -/
theorem dotProd_sum {n m : ℕ} (α : Fin n → S) (f : Fin m → (Fin n → S))
    (c : Fin m → S) :
    dotProd α (∑ j : Fin m, c j • f j) =
      ∑ j : Fin m, c j * dotProd α (f j) := by
  unfold dotProd
  simp [Finset.mul_sum]
  exact Finset.sum_comm.trans
    (Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring)

/-- `dotProd` distributes over linear maps via standard basis expansion. -/
theorem dotProd_linear_expand {n : ℕ} (α : Fin n → S)
    (f : (Fin n → S) →ₗ[S] (Fin n → S)) (x : Fin n → S) :
    dotProd α (f x) = ∑ j : Fin n, x j * dotProd α (f (stdBasis j)) := by
  conv_lhs => rw [vec_as_sum_stdBasis x]
  convert dotProd_sum α (fun j => f (stdBasis (S := S) j)) (fun j => x j) using 1
  simp [dotProd, map_sum, map_smul]

/-- `dotProd` is commutative over a commutative semiring. -/
theorem dotProd_comm {n : ℕ} (x y : Fin n → S) :
    dotProd x y = dotProd y x := by
  simp [dotProd, mul_comm]

end CommLemmas

/-! ## Backward Direction: Realization → Finite Generator Rank -/

section RealizationToRank
variable [CommSemiring S]

/-- **Realization → Finite Generator Rank.**
If `B = evalLinearSystem α β A`, then the Hankel row space has finite
generator rank ≤ n. The generators are the observation functions
`v ↦ dotProd α (wordAction A v (stdBasis j))`. -/
theorem realization_implies_finiteHankelGeneratorRank {n : ℕ}
    (α β : Fin n → S)
    (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S))
    (B : List Alpha → S)
    (hreal : ∀ w, B w = evalLinearSystem α β A w) :
    FiniteHankelGeneratorRank B := by
  refine ⟨n, fun j v => dotProd α (wordAction A v (stdBasis (S := S) j)), fun u => ?_⟩
  use fun j => (wordAction A u β) j
  intro v
  rw [hreal, evalLinearSystem_append]
  exact dotProd_linear_expand α (wordAction A v) (wordAction A u β)

/-- Closure version: realization of `cl B` implies finite closure generator rank. -/
theorem realization_implies_closureGeneratorRank {n : ℕ}
    (cl : (List Alpha → S) → (List Alpha → S))
    (α β : Fin n → S)
    (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S))
    (B : List Alpha → S)
    (hreal : ∀ w, cl B w = evalLinearSystem α β A w) :
    FiniteHankelGeneratorRank (cl B) :=
  realization_implies_finiteHankelGeneratorRank α β A (cl B) hreal

end RealizationToRank

/-! ## Forward Direction: Finite Hankel Row Rank → Realization

The Myhill-Nerode construction: given basis prefixes whose Hankel rows
span all Hankel rows, construct a linear realization by using the
shift structure of Hankel rows to define transition maps.
-/

section RankToRealization
variable [CommSemiring S]

/-- Helper: choose coefficient vectors for each prefix word. -/
private def chooseCoeffs {n : ℕ} {B : List Alpha → S} {bases : Fin n → List Alpha}
    (hspan : ∀ u, ∃ coeffs : Fin n → S,
      ∀ v, B (u ++ v) = ∑ i, coeffs i * B (bases i ++ v)) :
    List Alpha → Fin n → S :=
  fun u => Classical.choose (hspan u)

/-- The chosen coefficients satisfy the spanning property. -/
private theorem chooseCoeffs_spec {n : ℕ} {B : List Alpha → S} {bases : Fin n → List Alpha}
    (hspan : ∀ u, ∃ coeffs : Fin n → S,
      ∀ v, B (u ++ v) = ∑ i, coeffs i * B (bases i ++ v))
    (u : List Alpha) (v : List Alpha) :
    B (u ++ v) = ∑ i, chooseCoeffs hspan u i * B (bases i ++ v) :=
  Classical.choose_spec (hspan u) v

/-
**Finite Hankel Row Rank → Realization (Theorem 1, Forward Direction).**
If the Hankel row space is generated by `n` Hankel rows (at basis prefixes),
then a linear realization of dimension `n` exists.

Construction:
- State space: `Fin n → S`
- Initial vector `α_j = B(bases_j)` (behavior at basis prefixes)
- Output vector `β = c([])` (coefficients of empty prefix)
- Transition `A(a)`: matrix `M(a)_{kj} = c(bases_j ++ [a])_k`

Key lemma (proved by induction on `w`):
```
∀ x w v, ∑ j, (wordAction A w x) j * B(bases j ++ v)
       = ∑ j, x j * B(bases j ++ (w ++ v))
```
Specializing to `x = β`, `v = []` gives the realization equation.
-/
theorem finiteHankelRank_implies_realization
    (B : List Alpha → S)
    (hfin : FiniteHankelRank B) :
    ∃ (n : ℕ) (α β : Fin n → S)
      (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S)),
      ∀ w, B w = evalLinearSystem α β A w := by
  obtain ⟨ n, bases, hspan ⟩ := hfin;
  -- Define the transition map A(a) as the linear map with matrix entries M(a)_{kj} = c(bases_j ++ [a])_k.
  set A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S) := fun a => { toFun := fun x k => ∑ j, x j * (chooseCoeffs hspan (bases j ++ [a])) k, map_add' := by
                                                                simp +decide [ funext_iff, Finset.sum_add_distrib, add_mul ], map_smul' := by
                                                                simp +decide [ funext_iff, Finset.mul_sum _ _ _, mul_assoc, mul_left_comm ] }
  generalize_proofs at *;
  refine' ⟨ n, fun j => B ( bases j ), fun j => chooseCoeffs hspan [] j, A, fun w => _ ⟩;
  -- By induction on $w$, we can show that the evaluation of the linear system at $w$ is equal to $B w$.
  have h_ind : ∀ w : List Alpha, ∀ x : Fin n → S, ∀ v : List Alpha, ∑ j, (wordAction A w x) j * B (bases j ++ v) = ∑ j, x j * B (bases j ++ (w ++ v)) := by
    intro w x v
    induction' w with a w ih generalizing x v
    all_goals generalize_proofs at *;
    · simp +decide [ wordAction ];
    · convert ih ( A a x ) v using 1;
      simp +decide [ A, List.append_assoc ];
      simp +decide only [sum_mul, mul_assoc];
      rw [ Finset.sum_comm ];
      refine' Finset.sum_congr rfl fun i _ => _;
      rw [ ← Finset.mul_sum _ _ _, ← chooseCoeffs_spec hspan ];
      simp +decide [ List.append_assoc ]
  generalize_proofs at *;
  convert h_ind w ( fun j => chooseCoeffs hspan [] j ) [] |> Eq.symm using 1;
  · simpa using chooseCoeffs_spec hspan [] w;
  · unfold evalLinearSystem dotProd; simp +decide [ mul_comm ] ;

/-- **Closure-Hankel Row Rank → Realization.**
The closure version: if `cl B` has finite Hankel row rank,
then `cl B` has a finite linear realization. -/
theorem finiteClosureHankelRank_implies_realization
    (cl : (List Alpha → S) → (List Alpha → S))
    (B : List Alpha → S)
    (hfin : FiniteClosureHankelRank cl B) :
    ∃ (n : ℕ) (α β : Fin n → S)
      (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S)),
        ∀ w, cl B w = evalLinearSystem α β A w :=
  finiteHankelRank_implies_realization (cl B) hfin

end RankToRealization

/-! ## Theorem 2: Minimality and Uniqueness -/

section Minimality
variable [CommSemiring S]

/-- **Minimal Closure Realization Uniqueness (Theorem 2).**
Any two minimal closure realizations have the same dimension. -/
theorem minimalClosureRealization_dim_unique
    (cl : (List Alpha → S) → (List Alpha → S))
    (B : List Alpha → S)
    (R₁ R₂ : ClosureRealization (Alpha := Alpha) cl B)
    (hmin₁ : IsMinimalClosureRealization cl B R₁)
    (hmin₂ : IsMinimalClosureRealization cl B R₂) :
    R₁.dim = R₂.dim :=
  le_antisymm (hmin₁.minimal R₂) (hmin₂.minimal R₁)

end Minimality

/-! ## Theorem 3: Certified Reconstruction -/

section Reconstruction
variable [CommSemiring S]

/-- **Certified Reconstruction Theorem (Theorem 3).**
If the closure-Hankel rank is stable on finite windows, then a realization exists. -/
theorem reconstructFromStableHankel [Fintype Alpha] [DecidableEq Alpha] [Preorder S]
    (cl : (List Alpha → S) → (List Alpha → S))
    (B : List Alpha → S)
    (P Q : Finset (List Alpha))
    (hstab : ClosureHankelRankStableOn cl B P Q)
    (hcl : IsEMLClosure cl) :
    ∃ (n : ℕ) (α β : Fin n → S)
      (A : Alpha → (Fin n → S) →ₗ[S] (Fin n → S)),
        ∀ w, cl B w = evalLinearSystem α β A w := by
  -- Extract stabilized rank and basis from the stability condition
  obtain ⟨rank, genPfx, _, hspans, hstable⟩ := hstab
  -- The stability condition gives us a finite Hankel rank for cl B
  -- restricted to the prefix/suffix sets. We extend this to all words
  -- using the closure properties.
  sorry

end Reconstruction

end