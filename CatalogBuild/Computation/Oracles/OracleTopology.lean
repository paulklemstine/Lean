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


theorem oracle_fixedPoints_closed {X : Type*} [TopologicalSpace X] [T2Space X]
    (O : X → X) (hO : Continuous O) :
    IsClosed {x | O x = x} := by
      exact isClosed_eq hO continuous_id


/-- [Section: ## §2: Retraction Theory] -/
theorem retraction_identity_on_image {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (y : X) (hy : y ∈ range O) : O y = y := by
      grind


theorem image_idempotent_stable {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x) :
    range (O ∘ O) = range O := by
      aesop


theorem idempotent_range_identity {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (x : X) : O (O x) = O x := by
      exact hO x


/-- [Section: ## §3: Convergence and Stability] -/
theorem oracle_sequence_eventually_const {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (x : X) : ∀ n m : ℕ, n ≥ 1 → m ≥ 1 → O^[n] x = O^[m] x := by
      intro n m hn hm; induction' hn with n hn ih <;> induction' hm with m hm ih <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
      grind


theorem oracle_preimage_contains_fixedpoint {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (y : X) (hy : O y = y) : y ∈ O ⁻¹' {y} := by
      aesop


/-- [Section: ## §4: Topological Dynamics] -/
theorem oracle_fixedPoints_compact {X : Type*} [TopologicalSpace X] [T2Space X]
    [CompactSpace X] (O : X → X) (hO_cont : Continuous O) (hO_idem : ∀ x, O (O x) = O x) :
    IsCompact {x : X | O x = x} := by
      convert isClosed_eq hO_cont continuous_id |> IsClosed.isCompact using 1


theorem oracle_range_compact {X : Type*} [TopologicalSpace X] [CompactSpace X]
    (O : X → X) (hO : Continuous O) :
    IsCompact (range O) := by
      exact isCompact_range hO


/-- An idempotent endomorphism squares to itself -/
theorem endo_idempotent_square {C : Type*} [Category C] (X : C)
    (e : X ⟶ X) (he : e ≫ e = e) :
    (e ≫ e) ≫ e = e ≫ e := by
      -- Since $e$ is idempotent, we have $e \circ e = e$. Therefore, $(e \circ e) \circ e = e \circ e = e$.
      simp [he]


end
