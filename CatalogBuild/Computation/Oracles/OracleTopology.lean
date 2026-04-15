/-! # CatalogBuild.Computation.Oracles.OracleTopology

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 10
-/

import Mathlib

noncomputable section

theorem oracle_orbit_stabilizes {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (x : X) (n : ℕ) (hn : n ≥ 1) :
    O^[n] x = O x := by
      induction hn <;> simp +decide [ *, Function.iterate_succ_apply' ]

/-
PROBLEM
Fixed points of an idempotent form a closed set when the map is continuous

PROVIDED SOLUTION
The fixed point set is the preimage of the diagonal under (id, O), which is closed in a Hausdorff space. Equivalently, it's the equalizer of O and id, both continuous, so it's closed by isClosed_eq.
-/

theorem oracle_fixedPoints_closed {X : Type*} [TopologicalSpace X] [T2Space X]
    (O : X → X) (hO : Continuous O) :
    IsClosed {x | O x = x} := by
      exact isClosed_eq hO continuous_id

/-! ## §2: Retraction Theory -/

/-
A retraction restricts to the identity on its image
-/

theorem retraction_identity_on_image {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (y : X) (hy : y ∈ range O) : O y = y := by
      grind

/-
The image of an idempotent is the same as iterating twice
-/

theorem image_idempotent_stable {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x) :
    range (O ∘ O) = range O := by
      aesop

/-
For idempotent O, O restricted to its range is the identity
-/

theorem idempotent_range_identity {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (x : X) : O (O x) = O x := by
      exact hO x

/-! ## §3: Convergence and Stability -/

/-
Any sequence x, O(x), O(O(x)), ... is eventually constant
-/

theorem oracle_sequence_eventually_const {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (x : X) : ∀ n m : ℕ, n ≥ 1 → m ≥ 1 → O^[n] x = O^[m] x := by
      intro n m hn hm; induction' hn with n hn ih <;> induction' hm with m hm ih <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
      grind

/-
The preimage of a fixed point under an oracle contains the point itself
-/

theorem oracle_preimage_contains_fixedpoint {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (y : X) (hy : O y = y) : y ∈ O ⁻¹' {y} := by
      aesop

/-! ## §4: Topological Dynamics -/

/-
In a compact metric space, the fixed-point set of a continuous idempotent is compact
-/

theorem oracle_fixedPoints_compact {X : Type*} [TopologicalSpace X] [T2Space X]
    [CompactSpace X] (O : X → X) (hO_cont : Continuous O) (hO_idem : ∀ x, O (O x) = O x) :
    IsCompact {x : X | O x = x} := by
      convert isClosed_eq hO_cont continuous_id |> IsClosed.isCompact using 1

/-
The range of a continuous function on a compact space is compact
-/

theorem oracle_range_compact {X : Type*} [TopologicalSpace X] [CompactSpace X]
    (O : X → X) (hO : Continuous O) :
    IsCompact (range O) := by
      exact isCompact_range hO

/-! ## §5: Category-Theoretic View -/

open CategoryTheory in
/-- An idempotent endomorphism squares to itself -/

theorem endo_idempotent_square {C : Type*} [Category C] (X : C)
    (e : X ⟶ X) (he : e ≫ e = e) :
    (e ≫ e) ≫ e = e ≫ e := by
      -- Since $e$ is idempotent, we have $e \circ e = e$. Therefore, $(e \circ e) \circ e = e \circ e = e$.
      simp [he]

/-
PROBLEM
In a concrete category, composition preserves idempotency for commuting morphisms

PROVIDED SOLUTION
Use funext. (f∘g)∘(f∘g) = f∘g∘f∘g. Since f∘g = g∘f (hc), we get f∘f∘g∘g = f∘g by hf hg.
-/

end
