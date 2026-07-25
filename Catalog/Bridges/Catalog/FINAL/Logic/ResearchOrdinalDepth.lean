import Mathlib

/-!
# Research Ordinal Depth: A Formal Complexity Invariant

This module formalizes a framework for measuring the "depth" of finitely described
research objects using ordinal-valued invariants. Research objects are modeled as
finite trees with four constructors: atoms, compositions, bootstraps, and oracle nodes.

## Main definitions

* `ResearchObject` — An inductive type representing finitely described research structures.
* `researchDepth` — An ordinal-valued depth function on research objects.
* `natDepth` — A computable natural-number approximation to ordinal depth.
* `Subobject` — A structural inclusion relation on research objects.
* `HeightBound` — A predicate bounding the height of the research tree.

## Main results

* `researchDepth_bootstrap_strict` — Bootstrap strictly increases ordinal depth.
* `researchDepth_compose` — Composition depth equals the ordinal sum of component depths.
* `researchDepth_mono` — Depth is monotone under the subobject relation.
* `natDepth_eq_researchDepth` — The computable approximation exactly equals the ordinal depth.
* `natDepth_height_bound` — Bounded height implies bounded `natDepth`.
* `bootstrapIter_depth` — Iterated bootstrap depth equals base depth plus iteration count.
-/

noncomputable section

open Ordinal

/-! ## Core Definitions -/

/-- A `ResearchObject` represents a finitely described research structure.
- `atom n` is an atomic research unit (e.g., a single lemma or axiom).
- `compose A B` is the sequential composition of two research programs.
- `bootstrap A` is a self-improving transformation (non-idempotent amplification).
- `oracleNode arity deps` is a branching node with `arity` dependencies. -/
inductive ResearchObject where
  | atom : ℕ → ResearchObject
  | compose : ResearchObject → ResearchObject → ResearchObject
  | bootstrap : ResearchObject → ResearchObject
  | oracleNode : (arity : ℕ) → (Fin arity → ResearchObject) → ResearchObject

namespace ResearchObject

/-! ## Ordinal Depth -/

/-- The ordinal-valued depth of a research object.
- Atoms have depth 1.
- Compositions have depth equal to the ordinal sum of components.
- Bootstrap takes the successor (strictly increases depth).
- Oracle nodes take the supremum of successor depths over dependencies.
  An oracle node with zero dependencies has depth 0 (the empty supremum). -/
def researchDepth : ResearchObject → Ordinal
  | .atom _ => 1
  | .compose A B => researchDepth A + researchDepth B
  | .bootstrap A => Order.succ (researchDepth A)
  | .oracleNode arity deps =>
      ⨆ i : Fin arity, Order.succ (researchDepth (deps i))

/-! ## Computable Natural Depth -/

/-- A computable natural-number approximation to ordinal depth.
For finite research objects, this exactly captures the ordinal depth
when viewed as a natural number (since all depths are finite). -/
def natDepth : ResearchObject → ℕ
  | .atom _ => 1
  | .compose A B => natDepth A + natDepth B
  | .bootstrap A => natDepth A + 1
  | .oracleNode 0 _ => 0
  | .oracleNode (n + 1) deps =>
      Finset.sup Finset.univ fun i : Fin (n + 1) => (natDepth (deps i) + 1)

/-! ## Structural Predicates -/

/-- `Subobject A B` means `A` is a structural part of `B`:
either `A = B`, or `A` is a subobject of a component of `B`. -/
inductive Subobject : ResearchObject → ResearchObject → Prop where
  | refl (A : ResearchObject) : Subobject A A
  | composeLeft {A X Y : ResearchObject} : Subobject A X → Subobject A (.compose X Y)
  | composeRight {A X Y : ResearchObject} : Subobject A Y → Subobject A (.compose X Y)
  | bootstrapInner {A X : ResearchObject} : Subobject A X → Subobject A (.bootstrap X)
  | oracleDep {A : ResearchObject} {arity : ℕ} {deps : Fin arity → ResearchObject}
      {i : Fin arity} : Subobject A (deps i) → Subobject A (.oracleNode arity deps)

/-- `HeightBound n A` means the tree height of `A` is at most `n`.
All constructors increase the height by one, except atoms which have height 0. -/
inductive HeightBound : ℕ → ResearchObject → Prop where
  | atom (n m : ℕ) : HeightBound n (.atom m)
  | compose {n : ℕ} {A B : ResearchObject} : HeightBound n A → HeightBound n B →
      HeightBound (n + 1) (.compose A B)
  | bootstrap {n : ℕ} {A : ResearchObject} : HeightBound n A →
      HeightBound (n + 1) (.bootstrap A)
  | oracleNode {n arity : ℕ} {deps : Fin arity → ResearchObject} :
      (∀ i, HeightBound n (deps i)) →
      HeightBound (n + 1) (.oracleNode arity deps)

/-
HeightBound is monotone: if an object has height ≤ n, it also has height ≤ n + 1.
-/
theorem HeightBound.weaken {n : ℕ} {A : ResearchObject} (h : HeightBound n A) :
    HeightBound (n + 1) A := by
  -- We proceed by induction on the structure of `A`.
  induction' A with A ihA B ihB A' ihA' arity deps ihDeps generalizing n;
  · exact HeightBound.atom _ _;
  · cases h ; tauto;
  · cases h ; tauto;
  · cases h ; tauto

/-! ## Theorem A: Bootstrap strictly increases depth -/

/-- Any bootstrap operation strictly increases ordinal depth.
This is the central structural result: self-amplifying research
transformations are ordinally visible. -/
theorem researchDepth_bootstrap_strict (A : ResearchObject) :
    researchDepth A < researchDepth (.bootstrap A) := by
  exact Order.lt_succ_iff.mpr (le_refl _)

/-! ## Theorem B: Composition depth equals ordinal sum -/

/-- The depth of composed research procedures equals the ordinal sum
of their depths. -/
theorem researchDepth_compose (A B : ResearchObject) :
    researchDepth (.compose A B) = researchDepth A + researchDepth B := by
  rfl

/-! ## Theorem C: Monotonicity under subobject inclusion -/

/-
Depth is monotone under the subobject relation.
-/
theorem researchDepth_mono {A B : ResearchObject} (h : Subobject A B) :
    researchDepth A ≤ researchDepth B := by
  induction' h;
  · rfl;
  · exact le_trans ‹_› ( Ordinal.le_add_right _ _ ) |> le_trans <| by rw [ researchDepth_compose ] ;
  · exact le_trans ‹_› ( Ordinal.le_add_left _ _ );
  · exact le_trans ‹_› ( le_of_lt ( by exact? ) );
  · refine' le_trans _ ( le_ciSup _ _ );
    exact le_trans ‹_› ( Order.le_succ _ );
    exact?

/-! ## Theorem D: Computable approximation equals ordinal depth -/

/-
The natural depth of a research object, cast to ordinals,
equals the ordinal depth. For our finitely branching objects,
both measures agree exactly.
-/
theorem natDepth_eq_researchDepth (A : ResearchObject) :
    (natDepth A : Ordinal) = researchDepth A := by
  -- By induction on the structure of A, we can show that the depth of A is equal to its natural number depth cast to an ordinal.
  induction' A with A B hA hB;
  · -- The research depth of an atom is 1 by definition.
    simp [ResearchObject.researchDepth];
    rfl;
  · simp_all +decide [ ResearchObject.natDepth, ResearchObject.researchDepth ];
  · simp +arith +decide [ *, ResearchObject.natDepth, ResearchObject.researchDepth ];
  · cases ‹ℕ› <;> simp_all +decide [ ResearchObject.natDepth, ResearchObject.researchDepth ];
    rw [ @ciSup_eq_of_forall_le_of_forall_lt_exists_gt ];
    · intro i;
      refine' le_trans _ ( Nat.cast_le.mpr <| Finset.le_sup <| Finset.mem_univ i );
      aesop;
    · rename_i k hk ih;
      intro w hw;
      contrapose! hw;
      induction' ( Finset.univ : Finset ( Fin ( k + 1 ) ) ) using Finset.induction <;> simp_all +decide [ Finset.sup_insert ];
      cases max_cases ( ( hk ‹_› ).natDepth + 1 ) ( Finset.sup ‹_› fun i => ( hk i ).natDepth + 1 ) <;> simp_all +decide [ Nat.cast_add, Nat.cast_one ]

/-- Sound embedding: the computable `natDepth` is a lower bound for `researchDepth`.
This follows immediately from the equality. -/
theorem natDepth_le_researchDepth (A : ResearchObject) :
    (natDepth A : Ordinal) ≤ researchDepth A :=
  le_of_eq (natDepth_eq_researchDepth A)

/-! ## Theorem E: Bounded height implies bounded natDepth -/

/-
If a research object has height bounded by `n`, then its `natDepth`
is bounded by `2^(n+1)`. This provides a computable upper bound.
-/
theorem natDepth_height_bound (n : ℕ) (A : ResearchObject)
    (hheight : HeightBound n A) :
    natDepth A ≤ 2 ^ (n + 1) := by
  induction' hheight with n A hA B hB ihA ihB n A hA ihA n arity deps hdeps ihdep;
  · exact Nat.one_le_pow _ _ ( by decide );
  · exact show B.natDepth + hB.natDepth ≤ 2 ^ ( hA + 2 ) by rw [ pow_succ' ] ; linarith;
  · exact Nat.succ_le_of_lt ( lt_of_le_of_lt arity ( pow_lt_pow_right₀ one_lt_two ( Nat.lt_succ_self _ ) ) );
  · rcases hdeps with ( _ | hdeps ) <;> simp_all +decide [ pow_succ' ];
    · exact le_trans ( by rfl ) ( Nat.zero_le _ );
    · exact le_trans ( Finset.sup_le fun i _ => Nat.succ_le_succ ( ‹∀ i, ( ihdep i |> ResearchObject.natDepth ) ≤ 2 * 2 ^ deps› i ) ) ( by simp +arith +decide )

/-! ## Bridge: Oracle composition depth -/

/-- A research oracle realization: maps a validation depth to a ResearchObject. -/
def oracleToResearch : ℕ → ResearchObject
  | 0 => .atom 0
  | n + 1 => .bootstrap (oracleToResearch n)

/-- Composing two oracle realizations has depth equal to the sum of depths. -/
theorem oracle_compose_depth (d₁ d₂ : ℕ) :
    researchDepth (.compose (oracleToResearch d₁) (oracleToResearch d₂)) =
      researchDepth (oracleToResearch d₁) + researchDepth (oracleToResearch d₂) :=
  rfl

/-
The depth of an oracle realization equals d + 1.
-/
theorem oracleToResearch_depth (d : ℕ) :
    researchDepth (oracleToResearch d) = ↑d + 1 := by
  induction' d with d ih;
  · aesop;
  · exact show researchDepth ( .bootstrap ( oracleToResearch d ) ) = ↑ ( d + 1 ) + 1 from by erw [ show researchDepth ( .bootstrap ( oracleToResearch d ) ) = Order.succ ( researchDepth ( oracleToResearch d ) ) from rfl, ih ] ; simp +decide ;

/-! ## Bridge to Dynamical Proof Complexity -/

/-- A bootstrap iterator: applies bootstrap `n` times. -/
def bootstrapIter : ℕ → ResearchObject → ResearchObject
  | 0, A => A
  | n + 1, A => .bootstrap (bootstrapIter n A)

/-
Iterated bootstrap produces strictly increasing depth sequences.
-/
theorem bootstrapIter_strict_increasing (A : ResearchObject) (n : ℕ) :
    researchDepth (bootstrapIter n A) < researchDepth (bootstrapIter (n + 1) A) := by
  convert researchDepth_bootstrap_strict _ using 1

/-
The depth of `n`-fold bootstrap equals the base depth plus `n`.
-/
theorem bootstrapIter_depth (A : ResearchObject) (n : ℕ) :
    researchDepth (bootstrapIter n A) = researchDepth A + n := by
  -- We will prove this by induction on $n$.
  induction' n with n ih;
  · -- The base case when $n = 0$ follows directly from the definition of `bootstrapIter`.
    simp [bootstrapIter];
  · rw [ show bootstrapIter ( n + 1 ) A = .bootstrap ( bootstrapIter n A ) by rfl, ResearchObject.researchDepth ];
    simp +decide [ ih, Ordinal.add_succ ]

/-
Bootstrap iteration is never idempotent for any research object:
applying it twice gives strictly more depth than applying it once.
This mirrors `nontrivial_depth_one_implies_not_idempotent`
from DynamicalProofComplexity.
-/
theorem bootstrap_not_idempotent (A : ResearchObject) :
    researchDepth (.bootstrap (.bootstrap A)) ≠ researchDepth (.bootstrap A) := by
  exact ne_of_gt ( researchDepth_bootstrap_strict _ )

end ResearchObject
end