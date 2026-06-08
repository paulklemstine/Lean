import Mathlib

/-!
# Standard Conjectures on Algebraic Cycles: Core Definitions

We formalize the algebraic skeleton of Grothendieck's standard conjectures on
algebraic cycles. The key insight is that many implications between the conjectures
can be expressed purely in terms of:

1. **Graded intersection pairings** on finite-dimensional ℚ-vector spaces
2. **Lefschetz operators** satisfying Hard Lefschetz
3. **Equivalence relations** on cycle classes (homological, numerical)

We abstract away the geometric content (smooth projective varieties, Weil
cohomology theories) and work with the linear-algebraic structures that
underlie the conjectures.

## References

- Grothendieck, "Standard Conjectures on Algebraic Cycles" (1969)
- Kleiman, "The Standard Conjectures" (1994)
- André, "Une introduction aux motifs" (2004)
-/

noncomputable section

open LinearMap Submodule

/-! ## Graded Intersection Pairings -/

/-- A `GradedIntersectionSpace` models a single degree of the cohomology of a
    smooth projective variety. It consists of V (cycles in degree i) paired
    with W (cycles in complementary degree 2n-i) via an intersection pairing. -/
structure GradedIntersectionSpace where
  V : Type*
  W : Type*
  [instVACG : AddCommGroup V]
  [instVMod : Module ℚ V]
  [instVFD : FiniteDimensional ℚ V]
  [instWACG : AddCommGroup W]
  [instWMod : Module ℚ W]
  [instWFD : FiniteDimensional ℚ W]
  pairing : V →ₗ[ℚ] W →ₗ[ℚ] ℚ

attribute [instance] GradedIntersectionSpace.instVACG
  GradedIntersectionSpace.instVMod GradedIntersectionSpace.instVFD
  GradedIntersectionSpace.instWACG GradedIntersectionSpace.instWMod
  GradedIntersectionSpace.instWFD

namespace GradedIntersectionSpace

variable (G : GradedIntersectionSpace)

/-- The numerical kernel: classes α with ⟨α, β⟩ = 0 for all β. -/
def numericalKernel : Submodule ℚ G.V :=
  LinearMap.ker G.pairing

/-- A class is numerically trivial iff it pairs to zero with everything. -/
theorem mem_numericalKernel_iff (v : G.V) :
    v ∈ G.numericalKernel ↔ ∀ w : G.W, G.pairing v w = 0 := by
  simp [numericalKernel, LinearMap.mem_ker, DFunLike.ext_iff]

/-- The pairing is nondegenerate iff the numerical kernel is trivial. -/
def isNondegenerate : Prop := G.numericalKernel = ⊥

theorem isNondegenerate_iff :
    G.isNondegenerate ↔ ∀ v : G.V, (∀ w : G.W, G.pairing v w = 0) → v = 0 := by
  constructor
  · intro h v hv
    have hmem : v ∈ G.numericalKernel := (G.mem_numericalKernel_iff v).mpr hv
    rw [h] at hmem
    exact (Submodule.mem_bot ℚ).mp hmem
  · intro h
    ext v
    simp only [numericalKernel, mem_bot, mem_ker]
    constructor
    · intro hv
      apply h
      intro w
      exact LinearMap.congr_fun hv w
    · intro hv
      ext w
      simp
      rw [hv]
      simp

end GradedIntersectionSpace

/-! ## Lefschetz Module -/

/-- A `LefschetzModule` models the action of cup product with a hyperplane class
    on the cohomology of a projective variety. -/
structure LefschetzModule where
  V : Type*
  [instACG : AddCommGroup V]
  [instMod : Module ℚ V]
  [instFD : FiniteDimensional ℚ V]
  /-- The Lefschetz operator L : V → V -/
  L : V →ₗ[ℚ] V
  /-- Symmetric bilinear form Q on V (intersection pairing) -/
  Q : V →ₗ[ℚ] V →ₗ[ℚ] ℚ
  /-- Q is symmetric -/
  Q_symm : ∀ x y, Q x y = Q y x

attribute [instance] LefschetzModule.instACG LefschetzModule.instMod
  LefschetzModule.instFD

namespace LefschetzModule

variable (M : LefschetzModule)

/-- The kernel of Q: numerically trivial classes. -/
def numKer : Submodule ℚ M.V := LinearMap.ker M.Q

/-- Membership in the numerical kernel. -/
theorem mem_numKer_iff (v : M.V) :
    v ∈ M.numKer ↔ ∀ w : M.V, M.Q v w = 0 := by
  simp [numKer, LinearMap.mem_ker, DFunLike.ext_iff]

/-- Q is nondegenerate iff numKer = ⊥. -/
def qNondegenerate : Prop := M.numKer = ⊥

/-- An abstract homological kernel: a submodule contained in numKer.
    This models the fact that homological equivalence refines numerical. -/
structure HomologicalData where
  homKer : Submodule ℚ M.V
  homKer_le_numKer : homKer ≤ M.numKer

/-- **Standard Conjecture D** (Grothendieck): Numerical and homological
    equivalence coincide, i.e., homKer = numKer. -/
def standardConjectureD (HD : HomologicalData M) : Prop :=
  HD.homKer = M.numKer

/-- Standard Conjecture D holds iff numKer ≤ homKer. -/
theorem standardConjectureD_iff (HD : HomologicalData M) :
    M.standardConjectureD HD ↔ M.numKer ≤ HD.homKer := by
  constructor
  · intro h; rw [h]
  · intro h; exact le_antisymm HD.homKer_le_numKer h

/-- The primitive subspace: kernel of L. -/
def primitiveSpace : Submodule ℚ M.V := LinearMap.ker M.L

/-- The Lefschetz pairing Q_L(x,y) := Q(x, Ly). -/
def lefschetzPairing : M.V →ₗ[ℚ] M.V →ₗ[ℚ] ℚ := M.Q.comp M.L

end LefschetzModule

/-! ## Weil Cohomology Data -/

/-- Axioms for a Weil cohomology theory, abstracted to the level needed
    for the standard conjectures. -/
structure WeilCohomologyData where
  n : ℕ
  H : Fin (2 * n + 1) → Type*
  [instACG : ∀ i, AddCommGroup (H i)]
  [instMod : ∀ i, Module ℚ (H i)]
  [instFD : ∀ i, FiniteDimensional ℚ (H i)]

attribute [instance] WeilCohomologyData.instACG WeilCohomologyData.instMod
  WeilCohomologyData.instFD

/-! ## Quadratic Forms and Hodge Index -/

/-- A nondegenerate symmetric bilinear form on a finite-dimensional ℚ-space. -/
structure RationalQuadraticForm where
  V : Type*
  [instACG : AddCommGroup V]
  [instMod : Module ℚ V]
  [instFD : FiniteDimensional ℚ V]
  B : V →ₗ[ℚ] V →ₗ[ℚ] ℚ
  B_symm : ∀ x y, B x y = B y x
  B_nondeg : LinearMap.ker B = ⊥

attribute [instance] RationalQuadraticForm.instACG
  RationalQuadraticForm.instMod RationalQuadraticForm.instFD

namespace RationalQuadraticForm

variable (F : RationalQuadraticForm)

def totalDim : ℕ := Module.finrank ℚ F.V

def isIsotropic (v : F.V) : Prop := F.B v v = 0

def isotropicCone : Set F.V := { v | F.isIsotropic v }

end RationalQuadraticForm

/-! ## Pure Motives -/

/-- An abstract pure motive: a triple (V, p, m) where V is the realization
    space, p is an idempotent projector, and m is a Tate twist. -/
structure PureMotive where
  V : Type*
  [instACG : AddCommGroup V]
  [instMod : Module ℚ V]
  [instFD : FiniteDimensional ℚ V]
  projector : V →ₗ[ℚ] V
  projector_idem : projector ∘ₗ projector = projector
  twist : ℤ

attribute [instance] PureMotive.instACG PureMotive.instMod PureMotive.instFD

namespace PureMotive

/-- The image of the projector: the motive's realization. -/
def realization (M : PureMotive) : Submodule ℚ M.V :=
  LinearMap.range M.projector

/-- The rank of the motive. -/
def rank (M : PureMotive) : ℕ :=
  Module.finrank ℚ M.realization

end PureMotive

end