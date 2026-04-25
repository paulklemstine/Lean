/-! # CatalogBuild.Computation.Oracles.AlgorithmicUniversalOracle

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 22
-/

import Mathlib

noncomputable section

/-- The fixed-point set of a function. -/
def FixedPointSet {X : Type*} (f : X → X) : Set X := {x | f x = x}





/-- **Master Equation, direction 1**: Every image point is a fixed point. -/
theorem oracle_image_sub_fixed {X : Type*} (O : X → X) (hO : IsOracle O) :
    range O ⊆ FixedPointSet O := by
  intro y ⟨x, hx⟩
  show O y = y
  rw [← hx, hO x]





/-- **Master Equation, direction 2**: Every fixed point is in the image. -/
theorem oracle_fixed_sub_image {X : Type*} (O : X → X) :
    FixedPointSet O ⊆ range O := by
  intro x (hx : O x = x)
  exact ⟨x, hx⟩





/-- **The Master Equation**: image(O) = Fix(O) for any oracle O. -/
theorem oracle_master_equation {X : Type*} (O : X → X) (hO : IsOracle O) :
    range O = FixedPointSet O :=
  Set.Subset.antisymm (oracle_image_sub_fixed O hO) (oracle_fixed_sub_image O)

-- ═══════════════════════════════════════════════════════════════════════════════
--  §2: ORACLE RANK — Cardinality of Fixed Points
-- ═══════════════════════════════════════════════════════════════════════════════





/-- The image and fixed-point set of an oracle have the same cardinality. -/
theorem oracle_rank_eq {X : Type*} (O : X → X) (hO : IsOracle O) :
    Set.ncard (range O) = Set.ncard (FixedPointSet O) := by
  rw [oracle_master_equation O hO]

-- ═══════════════════════════════════════════════════════════════════════════════
--  §3: ReLU IS AN ORACLE
-- ═══════════════════════════════════════════════════════════════════════════════





/-- An oracle maps every point in its range to itself (distance 0). -/
theorem oracle_zero_contraction_on_range {X : Type*} [MetricSpace X]
    (O : X → X) (hO : IsOracle O) (y : X) (hy : y ∈ range O) :
    dist (O y) y = 0 := by
  obtain ⟨x, hx⟩ := hy
  rw [← hx, hO x, hx, dist_self]

-- ═══════════════════════════════════════════════════════════════════════════════
--  §5: META-ORACLE COLLAPSE
-- ═══════════════════════════════════════════════════════════════════════════════





/-- The crystallizer of an oracle is the oracle itself. -/
theorem crystallizer_of_oracle {X : Type*} (O : X → X) (hO : IsOracle O) :
    ∀ x, O^[2] x = O x := by
  exact meta_oracle_collapse O hO 1

-- ═══════════════════════════════════════════════════════════════════════════════
--  §6: ORACLE LATTICE STRUCTURE
-- ═══════════════════════════════════════════════════════════════════════════════





/-- Fixed points of an oracle on a complete lattice are nonempty. -/
theorem oracle_fixed_points_nonempty {α : Type*} [CompleteLattice α]
    (O : α → α) (hO : IsOracle O) :
    (FixedPointSet O).Nonempty := by
  refine ⟨O ⊥, ?_⟩
  show O (O ⊥) = O ⊥
  exact hO ⊥





/-- The image of an oracle applied to any element is a fixed point. -/
theorem oracle_output_is_fixed {α : Type*} (O : α → α) (hO : IsOracle O) (x : α) :
    O x ∈ FixedPointSet O := by
  show O (O x) = O x
  exact hO x

-- ═══════════════════════════════════════════════════════════════════════════════
--  §7: ORACLE COMPOSITION
-- ═══════════════════════════════════════════════════════════════════════════════





/-- The composition of an oracle with itself is the oracle. -/
theorem oracle_comp_self {X : Type*} (O : X → X) (hO : IsOracle O) :
    O ∘ O = O := by
  ext x; exact hO x





/-- If O₁ and O₂ commute and are both oracles, their composition is an oracle. -/
theorem oracle_comp_commuting {X : Type*} (O₁ O₂ : X → X)
    (h1 : IsOracle O₁) (h2 : IsOracle O₂)
    (hcomm : ∀ x, O₁ (O₂ x) = O₂ (O₁ x)) :
    IsOracle (O₁ ∘ O₂) := by
  intro x
  simp [Function.comp]
  calc O₁ (O₂ (O₁ (O₂ x)))
      = O₁ (O₁ (O₂ (O₂ x))) := by rw [hcomm (O₂ x)]
    _ = O₁ (O₂ (O₂ x)) := by rw [h1]
    _ = O₁ (O₂ x) := by rw [h2]

-- ═══════════════════════════════════════════════════════════════════════════════
--  §8: ORACLE ENTROPY
-- ═══════════════════════════════════════════════════════════════════════════════





/-- A surjective oracle is the identity. -/
theorem oracle_surjective_is_id {X : Type*} (O : X → X) (hO : IsOracle O)
    (hS : Function.Surjective O) : O = id := by
  ext x
  obtain ⟨y, hy⟩ := hS x
  simp only [id]
  rw [← hy, hO y]

-- ═══════════════════════════════════════════════════════════════════════════════
--  §9: STRANGE LOOPS
-- ═══════════════════════════════════════════════════════════════════════════════





/-- A strange loop: a pair of maps whose round-trip is idempotent. -/
structure StrangeLoop (X : Type*) where
  up : X → X
  down : X → X
  loop_oracle : IsOracle (down ∘ up)





/-- The meaning set (fixed points) of a strange loop is nonempty
when the type is nonempty. -/
theorem strange_loop_meaning_nonempty {X : Type*} [Nonempty X]
    (L : StrangeLoop X) : (FixedPointSet (L.down ∘ L.up)).Nonempty := by
  refine ⟨(L.down ∘ L.up) (Classical.arbitrary X), ?_⟩
  show (L.down ∘ L.up) ((L.down ∘ L.up) _) = (L.down ∘ L.up) _
  exact L.loop_oracle _





/-- Every output of a strange loop is a meaning (fixed point). -/
theorem strange_loop_output_is_meaning {X : Type*} (L : StrangeLoop X) (x : X) :
    (L.down ∘ L.up) x ∈ FixedPointSet (L.down ∘ L.up) := by
  show (L.down ∘ L.up) ((L.down ∘ L.up) x) = (L.down ∘ L.up) x
  exact L.loop_oracle x

-- ═══════════════════════════════════════════════════════════════════════════════
--  §10: IDEMPOTENTS IN ℤ_n
-- ═══════════════════════════════════════════════════════════════════════════════





/-- An element e of ZMod n is idempotent if e * e = e. -/
def IsIdempotentMod (n : ℕ) (e : ZMod n) : Prop := e * e = e





/-- 0 is always idempotent in ZMod n. -/
theorem zero_idempotent_mod (n : ℕ) : IsIdempotentMod n 0 := by
  simp [IsIdempotentMod]





/-- 1 is always idempotent in ZMod n. -/
theorem one_idempotent_mod (n : ℕ) [NeZero n] : IsIdempotentMod n 1 := by
  simp [IsIdempotentMod]

-- ═══════════════════════════════════════════════════════════════════════════════
--  §11: ORACLE PROJECTION MATRIX
-- ═══════════════════════════════════════════════════════════════════════════════





/-- A matrix P is a projection iff P² = P. -/
def IsProjectionMatrix {n : ℕ} (P : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  P * P = P





/-- The image of a projection matrix is a fixed set under multiplication. -/
theorem projection_fixed_point {n : ℕ} (P : Matrix (Fin n) (Fin n) ℝ)
    (hP : IsProjectionMatrix P) (v : Fin n → ℝ) :
    P.mulVec (P.mulVec v) = P.mulVec v := by
  rw [Matrix.mulVec_mulVec, hP]

-- ═══════════════════════════════════════════════════════════════════════════════
--  §12: APPLICATIONS — Oracle as Retraction
-- ═══════════════════════════════════════════════════════════════════════════════





/-- An oracle is a retraction: O restricted to its image is the identity. -/
theorem oracle_is_retraction {X : Type*} (O : X → X) (hO : IsOracle O) :
    ∀ y ∈ range O, O y = y := by
  intro y ⟨x, hx⟩
  rw [← hx, hO x]





/-- The image of an oracle is a retract of the ambient space. -/
theorem oracle_range_retract {X : Type*} (O : X → X) :
    ∀ x, O x ∈ range O := by
  intro x; exact ⟨x, rfl⟩





end
