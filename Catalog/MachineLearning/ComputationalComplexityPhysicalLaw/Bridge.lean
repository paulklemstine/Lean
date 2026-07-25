import Logic.PVsNp.PvsNPFoundations
import Physics.InformationTheory.LandauerSecondLaw

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
-- Hypothesis (Hypothesizer): Six falsifiable bridge claims were ranked by impact.
-- (1) A polynomially realizable physical solver for an NP-hard demon collapses the
-- nondeterministic class into the machine-polynomial class. (2) A stable collapse in a
-- hierarchy, combined with physical realization at the collapse level, makes every
-- higher level machine-simulable. (3) Under P = NP, every nondeterministic demon becomes
-- efficient. (4) The strongest popular claim—that this efficiency makes erasure free—is
-- incompatible with finite Jarzynski dynamics. (5) Every efficient demon admits a
-- logically reversible implementation with no asymptotic overhead. (6) A quantitative
-- time–entropy tradeoff controls arbitrary physical computation. Claims (1), (2), and
-- (4) are the highest-impact survivors supported by the present hypotheses.
-- Experiment (Experimenter): The reduction claim was reduced to many-one completeness
-- transfer, while the hierarchy claim was reduced to stable adjacent-level collapse.
-- For the thermodynamic claim, the Boolean erasure example was
-- tested at the boundary W = 0: positive k and T force a strictly positive lower bound,
-- so zero work contradicts the Jarzynski condition rather than violating the second law.
-- Analysis (Analyst): Claims (1)–(4) survive as conditional theorems. Claims (5) and
-- (6) need different definitions: the present model records language membership but no
-- machine configurations, reversible simulation overhead, runtime polynomial, or entropy
-- flow indexed by input size. They are neither established nor refuted here. Complexity
-- cost and thermodynamic work occupy different orders: polynomial time controls growth
-- with input length, whereas Landauer cost measures entropy discarded by a logically
-- irreversible map. No implication from “polynomial” to “zero heat” is available. The
-- common structural pattern is monotone transfer: reductions transfer efficient
-- solvability, hierarchy equalities transfer simulation, and entropy loss transfers cost.
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

/-- **Hierarchy-wide simulation above a stable collapse.** If adjacent equality at
level `k` propagates upward, and every problem at level `k` has a polynomially bounded
physical realization, then every problem at every higher level has a polynomial-time
machine simulation. This combines hierarchy collapse with the extended Church–Turing
inclusion rather than assuming direct physical realizability separately at each level.
-/
theorem stabilized_physical_hierarchy_is_machine_simulable {α : Type*}
    (M : PhysicalComplexityModel α) (H : ComplexityHierarchy α) (k : ℕ)
    (hcollapse : H.level k = H.level (k + 1))
    (hstable : ∀ m, H.level m = H.level (m + 1) →
      H.level (m + 1) = H.level (m + 2))
    (hphysical : H.level k ⊆ M.physicalPoly) :
    ∀ j, k ≤ j → H.level j ⊆ M.polyTM := by
  intro j hj
  have h_eq : H.level j = H.level k := by
    exact (hierarchy_collapse H k hcollapse hstable j hj).symm
  rw [h_eq]
  exact Set.Subset.trans hphysical M.extendedChurchTuring

/-- **Integrated no-go theorem.** A physically polynomial NP-hard solver does force
class equality, but if that solver is implemented by one-bit erasure obeying the
finite Jarzynski equality at positive temperature, it still cannot have zero mean
work. Thus the same hypotheses yield the complexity collapse and the thermodynamic
obstruction simultaneously, without postulating `P = NP` separately.
-/
theorem physical_npHard_erasing_demon_collapse_and_no_zero_work
    {α Ω : Type*} [Fintype Ω]
    (M : PhysicalComplexityModel α) (demon : Set α)
    (hhard : IsNPHardDemon M demon) (hphysical : demon ∈ M.physicalPoly)
    (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ)
    (k T : ℝ) (hk : 0 < k) (hT : 0 < T)
    (hJ : JarzynskiCondition p W (k * T)⁻¹ (k * T * Real.log 2)) :
    M.polyTM = M.nondeterministicPoly ∧
      demon ∈ M.polyTM ∧ ¬ Function.Injective erasure ∧ 0 < expect p W := by
  have heq := physical_npHard_demon_yields_class_equality M demon hhard hphysical
  have hefficient := M.extendedChurchTuring hphysical
  rcases logical_to_thermodynamic_irreversibility p hp W k T hk hT hJ with
    ⟨hirreversible, hwork⟩
  exact ⟨heq, hefficient, hirreversible, hwork⟩

end ComputationalComplexityPhysicalLaw

end