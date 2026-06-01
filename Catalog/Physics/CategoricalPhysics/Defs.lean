import Mathlib

/-!
# Categorical Physics: Foundations

Foundational definitions for categorical physics, including higher categorical
structures with duals, cobordism categories, TQFTs, and the cobordism hypothesis.
-/

open CategoryTheory

noncomputable section

/-! ## Higher Category Data with Duals -/

/-- Abstract data for a layered categorical structure with n morphism levels.
    Each level has objects and an involutive duality.
    Models the algebraic skeleton of an (∞,n)-category with duals. -/
structure HigherCatData (n : ℕ) where
  /-- Objects at each level 0..n -/
  Obj : Fin (n + 1) → Type
  /-- Duality: every object at each level has a dual -/
  dual : (k : Fin (n + 1)) → Obj k → Obj k
  /-- Duality is involutive -/
  dual_dual : ∀ (k : Fin (n + 1)) (x : Obj k), dual k (dual k x) = x

/-! ## Cobordism Categories -/

/-- Abstract cobordism data in dimension d.
    Objects are closed (d-1)-manifolds, morphisms are d-cobordisms. -/
structure CobordismData (d : ℕ) where
  /-- Closed (d-1)-manifolds -/
  Manifold : Type
  /-- d-dimensional cobordisms between manifolds -/
  Cobordism : Manifold → Manifold → Type
  /-- Identity cobordism (cylinder) -/
  cylinder : (M : Manifold) → Cobordism M M
  /-- Composition of cobordisms (gluing) -/
  glue : {M N P : Manifold} → Cobordism M N → Cobordism N P → Cobordism M P
  /-- Empty manifold (monoidal unit) -/
  empty : Manifold
  /-- Orientation reversal (duality) -/
  rev : Manifold → Manifold
  /-- Reversal is involutive -/
  rev_rev : ∀ M, rev (rev M) = M

/-- A TQFT is a functor from cobordisms to vector spaces. -/
structure TQFT (d : ℕ) (Cob : CobordismData d) where
  /-- State space assigned to each manifold -/
  stateSpace : Cob.Manifold → Type
  /-- Linear map assigned to each cobordism -/
  amplitude : {M N : Cob.Manifold} → Cob.Cobordism M N → (stateSpace M → stateSpace N)
  /-- Cylinders act as identity -/
  cylinder_id : ∀ M, amplitude (Cob.cylinder M) = id
  /-- Gluing corresponds to composition -/
  glue_comp : ∀ {M N P : Cob.Manifold} (W₁ : Cob.Cobordism M N) (W₂ : Cob.Cobordism N P),
    amplitude (Cob.glue W₁ W₂) = amplitude W₂ ∘ amplitude W₁

/-! ## Theory Types and Inclusions -/

/-- Physical theory types. -/
inductive TheoryType where
  | TQFT    -- Topological QFT
  | CFT     -- Conformal field theory
  | String  -- String theory
  | Gravity -- Gravitational theory
  deriving DecidableEq

/-- Theory inclusion hierarchy. -/
inductive TheoryInclusion : TheoryType → TheoryType → Prop where
  | tqft_in_cft : TheoryInclusion .TQFT .CFT
  | cft_in_gravity : TheoryInclusion .CFT .Gravity
  | string_in_gravity : TheoryInclusion .String .Gravity

/-! ## Dualizable Towers -/

/-- A **dualizable tower** models a (2,∞)-category with duals:
    an infinite sequence of levels with involutive duality that
    stabilizes above some level. -/
structure DualizableTower where
  Obj : ℕ → Type
  dual : (n : ℕ) → Obj n → Obj n
  dual_invol : ∀ n x, dual n (dual n x) = x
  stableLevel : ℕ
  stable : ∀ n, stableLevel ≤ n → Subsingleton (Obj n)

/-- A tower is **(2,∞)-shaped** if it stabilizes at level 2. -/
def DualizableTower.isTwoInfinity (T : DualizableTower) : Prop :=
  T.stableLevel = 2

/-! ## Physical Theory Candidates -/

/-- A **physical theory candidate** packages algebraic structure
    with theory type information. -/
structure PhysicalTheoryCandidate where
  tower : DualizableTower
  shadows : Finset TheoryType
  /-- String shadow requires nontrivial level-1 structure -/
  string_needs_level1 : .String ∈ shadows → ¬ Subsingleton (tower.Obj 1)
  /-- TQFT shadow requires nontrivial level-0 structure -/
  tqft_needs_level0 : .TQFT ∈ shadows → ¬ Subsingleton (tower.Obj 0)

end