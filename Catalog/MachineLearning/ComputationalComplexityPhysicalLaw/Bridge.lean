import Logic.PvsNPFoundations
import Physics.LandauerSecondLaw

/-!
# Computational Complexity and Thermodynamic Irreversibility

This chapter separates two claims that are often conflated in discussions of
Maxwell's demon.  The extended Church–Turing thesis is represented as an inclusion
from efficiently realizable physical decision processes into a polynomial-time
complexity class.  A collapse assumption identifies the nondeterministic class with
that polynomial-time class.  Independently, the Jarzynski equality forces every
one-bit erasure process at positive temperature to have positive mean work.

The resulting bridge gives a guarded answer to the speculative claim: a complexity
collapse can make an NP decision problem efficiently implementable, but efficiency
does not make logical erasure thermodynamically free.  Thus the collapse alone does
not entail a violation of the second law in this finite model.
-/

noncomputable section

open Set
open PvsNPFoundations
open JarzynskiLandauer
open LandauerSecondLaw

namespace ComputationalComplexityPhysicalLaw

/-- An abstract physical-complexity model over inputs `α`.  `physicalPoly` records
processes realizable within a polynomial physical resource bound, `polyTM` records
problems decidable by polynomial-time machines, and `nondeterministicPoly` records
the corresponding nondeterministic class. -/
structure PhysicalComplexityModel (α : Type*) where
  physicalPoly : Set (Set α)
  polyTM : Set (Set α)
  nondeterministicPoly : Set (Set α)
  extendedChurchTuring : physicalPoly ⊆ polyTM
  deterministicToNondeterministic : polyTM ⊆ nondeterministicPoly
  polyClosedUnderReductions : ClosedUnderReductions polyTM

/-- The class-collapse hypothesis, stated in the only direction not already supplied
by deterministic simulation. -/
def PCollapsesNP {α : Type*} (M : PhysicalComplexityModel α) : Prop :=
  M.nondeterministicPoly ⊆ M.polyTM

/-- A proposed demon solves a problem hard for the entire nondeterministic class. -/
def IsNPHardDemon {α : Type*} (M : PhysicalComplexityModel α) (demon : Set α) : Prop :=
  IsHardFor demon M.nondeterministicPoly

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): Three falsifiable bridge claims were ranked by impact.
-- (1) A polynomially realizable physical solver for an NP-hard demon collapses the
-- nondeterministic class into the machine-polynomial class. (2) Under a P/NP collapse,
-- any nondeterministic demon becomes efficient. (3) The strongest popular claim—that
-- this efficiency makes erasure free—is incompatible with finite Jarzynski dynamics.
-- Further candidates were a hierarchy-wide physical simulation principle, a reversible
-- implementation theorem, and a quantitative time–entropy tradeoff.
-- Experiment (Experimenter): The two complexity claims were reduced to many-one
-- completeness transfer. For the thermodynamic claim, the Boolean erasure example was
-- tested at the boundary W = 0: positive k and T force a strictly positive lower bound,
-- so zero work contradicts the Jarzynski condition rather than violating the second law.
-- Analysis (Analyst): Complexity cost and thermodynamic work occupy different orders:
-- polynomial time controls growth with input length, whereas Landauer cost measures
-- entropy discarded by a logically irreversible map. No implication from “polynomial”
-- to “zero heat” is available. The common structural pattern is monotone transfer:
-- reductions transfer efficient solvability, while entropy loss transfers to work cost.
-- Critique (Critic): The extended Church–Turing thesis and P = NP remain explicit
-- hypotheses, not purported consequences. Jarzynski dynamics, positivity of k and T,
-- and a normalized finite probability distribution are essential boundaries. The model
-- does not claim that every decision procedure erases a bit; it applies only when the
-- proposed implementation realizes the specified erasure process.
-- Synthesis (Principal Investigator): The strongest surviving statement is a no-go
-- bridge: collapse yields efficient demons, but an efficient erasing demon still has
-- positive mean work, and therefore cannot be a zero-work second-law counterexample.
-- !-- end Lab Notes -- !--

/-- **Physical NP-hardness collapse.** If an NP-hard demon is physically realizable
within a polynomial resource bound, the extended Church–Turing thesis and closure
under reductions force every nondeterministic-polynomial problem into the
polynomial-time machine class. -/
theorem physical_npHard_demon_forces_collapse {α : Type*}
    (M : PhysicalComplexityModel α) (demon : Set α)
    (hhard : IsNPHardDemon M demon) (hphysical : demon ∈ M.physicalPoly) :
    PCollapsesNP M := by
  have heasy : demon ∈ M.polyTM := M.extendedChurchTuring hphysical
  exact completeness_transfer hhard M.polyClosedUnderReductions heasy

/-- Under the collapse hypothesis, every nondeterministic-polynomial demon problem
has a polynomial-time machine implementation. -/
theorem collapse_makes_demon_efficient {α : Type*}
    (M : PhysicalComplexityModel α) (demon : Set α)
    (hcollapse : PCollapsesNP M)
    (hdemon : demon ∈ M.nondeterministicPoly) :
    demon ∈ M.polyTM := by
  exact hcollapse hdemon

/-- **Complexity–thermodynamics separation.** Even when a P/NP collapse makes a demon
problem polynomial-time decidable, an implementation that erases a uniformly unknown
bit and obeys the finite Jarzynski equality at positive temperature has strictly
positive mean work. -/
theorem efficient_erasing_demon_has_positive_work
    {α Ω : Type*} [Fintype Ω]
    (M : PhysicalComplexityModel α) (demon : Set α)
    (hcollapse : PCollapsesNP M)
    (hdemon : demon ∈ M.nondeterministicPoly)
    (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ)
    (k T : ℝ) (hk : 0 < k) (hT : 0 < T)
    (hJ : JarzynskiCondition p W (k * T)⁻¹ (k * T * Real.log 2)) :
    demon ∈ M.polyTM ∧ ¬ Function.Injective erasure ∧ 0 < expect p W := by
  have hefficient := collapse_makes_demon_efficient M demon hcollapse hdemon
  rcases logical_to_thermodynamic_irreversibility p hp W k T hk hT hJ with
    ⟨hirreversible, hwork⟩
  exact ⟨hefficient, hirreversible, hwork⟩

/-- **No zero-work Maxwell demon from P = NP.** Under the same finite thermodynamic
assumptions, the conjunction “the demon is polynomial-time” and “its mean erasure
work is zero” is impossible.  The contradiction is quantitative: Landauer's lower
bound is strictly positive. -/
theorem no_zero_work_demon_from_collapse
    {α Ω : Type*} [Fintype Ω]
    (M : PhysicalComplexityModel α) (demon : Set α)
    (hcollapse : PCollapsesNP M)
    (hdemon : demon ∈ M.nondeterministicPoly)
    (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ)
    (k T : ℝ) (hk : 0 < k) (hT : 0 < T)
    (hJ : JarzynskiCondition p W (k * T)⁻¹ (k * T * Real.log 2)) :
    ¬ (demon ∈ M.polyTM ∧ expect p W = 0) := by
  intro hzero
  have hbridge := efficient_erasing_demon_has_positive_work
    M demon hcollapse hdemon p hp W k T hk hT hJ
  rcases hbridge with ⟨_, _, hpositive⟩
  linarith [hzero.2]

/-- The physical simulation thesis and an NP-hard polynomial physical process together
identify the deterministic and nondeterministic classes extensionally. -/
theorem physical_npHard_demon_yields_class_equality {α : Type*}
    (M : PhysicalComplexityModel α) (demon : Set α)
    (hhard : IsNPHardDemon M demon) (hphysical : demon ∈ M.physicalPoly) :
    M.polyTM = M.nondeterministicPoly := by
  apply Set.Subset.antisymm
  · exact M.deterministicToNondeterministic
  · exact physical_npHard_demon_forces_collapse M demon hhard hphysical

end ComputationalComplexityPhysicalLaw

end