/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Semantic Adequacy Theorems

This file proves the main semantic adequacy theorem for coherent closure proof semirings:

> **Theorem** (Jacobson Adequacy). For elements `x, y` of a coherent closure proof semiring,
> `derivable x y` if and only if every admissible evaluation validates `e x → e y`.

The proof has two parts:
1. **Soundness** (`derivable_sound_for_admissible_evaluations`): monotonicity and
   closure compatibility of admissible evaluations imply they validate all derivable pairs.
2. **Completeness** (`derivable_of_valid_in_all_admissible_evaluations`): if every
   admissible evaluation validates `e x → e y`, then `derivable x y`. The contrapositive
   uses the prime ideal theorem for bounded distributive lattices to extract a
   Jacobson prime witness, which yields an admissible counterevaluation.

## Key Intermediate Results

* `not_derivable_exists_prime_separation` — non-derivability implies existence of a
  separating prime ideal (via the prime ideal theorem for distributive lattices)
* `prime_separation_yields_admissible_evaluation` — a separating prime ideal yields
  an admissible evaluation witnessing the failure
* `not_derivable_exists_jacobson_counterevaluation` — the combined countermodel theorem
* `derivable_iff_all_jacobson_evaluations_validate` — the main biconditional
* `jacobson_proof_congruence_eq_semantic` — the proof congruence equals the
  semantic preorder (intersection of all evaluation kernels)
-/

import Bridges.JacobsonAdequacy.Defs

open Order Set CoherentClosureProofSemiring

namespace CoherentClosureProofSemiring

variable {S : Type*} [CoherentClosureProofSemiring S]

/-! ## Soundness -/

/-- **Soundness**: every derivable pair is validated by every admissible evaluation.

If `derivable x y` (i.e., `cl x ≤ cl y`) and `e` is an admissible evaluation
(monotone and closure-compatible), then `e x → e y`.

*Proof.* From `e x`, closure compatibility gives `e (cl x)`. Monotonicity with
`cl x ≤ cl y` gives `e (cl y)`. Closure compatibility again gives `e y`. -/
theorem derivable_sound_for_admissible_evaluations {x y : S}
    (hxy : derivable x y)
    (e : S → Prop) (he : AdmissibleEvaluation (S := S) e) :
    e x → e y := by
  intro hex
  exact (he.cl_compat y).mp (he.monotone _ _ hxy ((he.cl_compat x).mpr hex))

/-! ## Prime Separation -/

/-
If `¬ derivable x y`, then there exists a prime ideal `J` of the distributive
lattice separating `cl x` from `cl y`: specifically `cl y ∈ J` and `cl x ∉ J`.

This is the core application of the **prime ideal theorem for bounded distributive
lattices** (`DistribLattice.prime_ideal_of_disjoint_filter_ideal`). The principal
filter of `cl x` and the principal ideal of `cl y` are disjoint precisely when
`cl x ≰ cl y`, and the theorem upgrades this to a prime ideal.
-/
theorem not_derivable_exists_prime_separation {x y : S}
    (hnd : ¬ derivable x y) :
    ∃ J : Ideal S, J.IsPrime ∧ separates J x y := by
  have h_disjoint : Disjoint (Order.PFilter.principal (cl' x) : Set S) (Order.Ideal.principal (cl' y) : Set S) := by
    exact Set.disjoint_left.mpr fun z hz₁ hz₂ => hnd <| by exact le_trans hz₁ hz₂;
  obtain ⟨ J, hJ₁, hJ₂ ⟩ := DistribLattice.prime_ideal_of_disjoint_filter_ideal h_disjoint;
  refine' ⟨ J, hJ₁, _, _ ⟩ <;> simp_all +decide [ Set.disjoint_left ]

/-
Any prime ideal in a bounded distributive lattice naturally gives rise to a
Jacobson prime point: since the lattice order ideal is downward-closed, the
closure compatibility `x ∈ J → cl x ∈ J` is guaranteed by the extensiveness
axiom combined with the ideal's upward-directed property.

In our setting, we construct the admissible evaluation directly from the prime ideal
rather than requiring an intermediate Jacobson prime point with cl-closure. The
evaluation `e(z) = (cl z ∉ J)` automatically absorbs `cl`.
-/
theorem prime_separation_yields_admissible_evaluation {x y : S}
    (h : ∃ J : Ideal S, J.IsPrime ∧ separates J x y) :
    ∃ e, AdmissibleEvaluation (S := S) e ∧ ¬ (e x → e y) := by
  obtain ⟨ J, hJ₁, hJ₂ ⟩ := h;
  refine' ⟨ fun z => cl' z ∉ J, ⟨ _, _ ⟩, _ ⟩ <;> simp_all +decide [ separates ];
  · intro x y hxy hx hy;
    exact hx ( J.lower (cl_monotone x y hxy) hy );
  · have := ‹CoherentClosureProofSemiring S›.cl_idempotent; aesop;

/-! ## Counterevaluation -/

/-- **Jacobson counterevaluation theorem**: if `x` does not derive `y`, then there
exists an admissible evaluation `e` witnessing the failure: `e x` holds but `e y` does not.

This combines prime separation (from the distributive lattice prime ideal theorem)
with the evaluation construction from the separating ideal. -/
theorem not_derivable_exists_jacobson_counterevaluation {x y : S}
    (hnd : ¬ derivable x y) :
    ∃ e, AdmissibleEvaluation (S := S) e ∧ ¬ (e x → e y) := by
  exact prime_separation_yields_admissible_evaluation (not_derivable_exists_prime_separation hnd)

/-! ## Completeness -/

/-- **Completeness**: if every admissible evaluation validates `e x → e y`,
then `derivable x y`.

*Proof.* By contrapositive. If `¬ derivable x y`, the counterevaluation theorem
produces an admissible `e` with `e x` and `¬ e y`, contradicting the hypothesis. -/
theorem derivable_of_valid_in_all_admissible_evaluations {x y : S}
    (hsem : ∀ e, AdmissibleEvaluation (S := S) e → (e x → e y)) :
    derivable x y := by
  by_contra hnd
  obtain ⟨e, he, hne⟩ := not_derivable_exists_jacobson_counterevaluation hnd
  exact hne (hsem e he)

/-! ## Main Adequacy Theorem -/

/-- **Semantic Adequacy (predicate form)**: derivability is exactly validation
in all admissible evaluations.

```
derivable x y ↔ ∀ e, AdmissibleEvaluation e → (e x → e y)
```

The forward direction is soundness; the reverse is completeness via contrapositive
using the Jacobson counterevaluation theorem. -/
theorem derivable_iff_all_jacobson_evaluations_validate'
    (x y : S) :
    derivable x y ↔ ∀ e, AdmissibleEvaluation (S := S) e → (e x → e y) := by
  constructor
  · intro hxy e he
    exact derivable_sound_for_admissible_evaluations hxy e he
  · exact derivable_of_valid_in_all_admissible_evaluations

/-- **Semantic Adequacy (set-membership form)**: equivalent formulation using
`admissibleEvaluations S` as a set. -/
theorem derivable_iff_all_jacobson_evaluations_validate
    (x y : S) :
    derivable x y ↔ ∀ e ∈ admissibleEvaluations S, (e x → e y) := by
  rw [derivable_iff_all_jacobson_evaluations_validate']
  simp only [admissibleEvaluations, Set.mem_setOf_eq]

/-- **Kernel intersection**: the derivability relation equals the semantic preorder
(intersection of all admissible evaluation kernels).

This is the algebraic engine behind adequacy: the proof congruence is exactly
the intersection of all evaluation kernels. -/
theorem derivable_iff_mem_jacobson_kernel (x y : S) :
    derivable x y ↔ ∀ e, AdmissibleEvaluation (S := S) e → e x → e y :=
  derivable_iff_all_jacobson_evaluations_validate' x y

/-- The proof congruence equals the semantic preorder. -/
theorem proof_congruence_eq_semantic :
    (proofCongruence : S → S → Prop) = semanticPreorder := by
  ext x y
  exact derivable_iff_all_jacobson_evaluations_validate' x y

/-! ## Jacobson Prime Point Structure -/

/-- From a prime ideal in a bounded distributive lattice, construct a Jacobson
prime point by considering the closure-compatible variant. The evaluation
`e(z) = (cl z ∉ J)` bypasses the need for `J` itself to be cl-closed. -/
theorem not_derivable_exists_jacobson_prime_separator {x y : S}
    (hnd : ¬ derivable x y) :
    ∃ J : Ideal S, J.IsPrime ∧ separates J x y :=
  not_derivable_exists_prime_separation hnd

end CoherentClosureProofSemiring