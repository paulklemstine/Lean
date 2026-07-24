import Mathlib
import Geometry.FiniteContraction

/-!
# Time-travel consistency as a fixed-point theorem

A causal loop is represented by its one-circuit evolution map.  A boundary-value
solution is a state whose value after one circuit agrees with its value before the
circuit.  This identifies Novikov consistency with a fixed-point problem.

The principal results establish existence, uniqueness, global attraction, and an
explicit error estimate when the causal return map is contractive.  A second theorem
specializes the construction to polynomial return maps on complete invariant domains.
The hypotheses are essential: an unrestricted polynomial need not have a real fixed
point, and Boolean negation gives a finite paradox with no consistent state.
-/

noncomputable section

open Filter Function Set
open scoped Topology

namespace TimeTravelConsistency

/-- A boundary-value problem for one circuit of a causal loop. -/
structure CausalBoundaryProblem (X : Type*) where
  /-- Evolution after one complete causal circuit. -/
  returnMap : X → X

/-- A self-consistent boundary state closes after one causal circuit. -/
def CausalBoundaryProblem.IsSolution {X : Type*}
    (P : CausalBoundaryProblem X) (x : X) : Prop :=
  P.returnMap x = x

/-- Novikov consistency means that the causal boundary-value problem has a solution. -/
def CausalBoundaryProblem.NovikovConsistent {X : Type*}
    (P : CausalBoundaryProblem X) : Prop :=
  ∃ x, P.IsSolution x

/-
The consistency condition is exactly the fixed-point condition, with no extra
physical assumption hidden in the terminology.
-/
theorem novikov_iff_fixedPoint {X : Type*} (P : CausalBoundaryProblem X) :
    P.NovikovConsistent ↔ ∃ x, Function.IsFixedPt P.returnMap x := by
  unfold CausalBoundaryProblem.NovikovConsistent CausalBoundaryProblem.IsSolution IsFixedPt; aesop;

/-
**Novikov–Banach theorem.** A contractive causal return map on a nonempty complete
metric state space has exactly one self-consistent boundary state.
-/
theorem novikov_banach_unique
    {X : Type*} [MetricSpace X] [CompleteSpace X] [Nonempty X]
    (P : CausalBoundaryProblem X) {K : NNReal}
    (hP : ContractingWith K P.returnMap) :
    ∃! x, P.IsSolution x := by
  unfold CausalBoundaryProblem.IsSolution;
  obtain ⟨x, hx⟩ : ∃ x : X, P.returnMap x = x := by
    exact ⟨ _, hP.fixedPoint_isFixedPt ⟩;
  refine' ⟨ x, hx, fun y hy => _ ⟩;
  have := hP.dist_le_mul y x;
  by_contra hxy;
  exact hxy ( by simpa [ hx, hy ] using this.trans_lt ( mul_lt_of_lt_one_left ( dist_pos.mpr hxy ) ( show ( K : ℝ ) < 1 from hP.1 ) ) )

/-
The self-consistent state selected by Banach's theorem attracts every initial
boundary state under repeated traversals of the causal loop.
-/
theorem novikov_banach_global_attractor
    {X : Type*} [MetricSpace X] [CompleteSpace X] [Nonempty X]
    (P : CausalBoundaryProblem X) {K : NNReal}
    (hP : ContractingWith K P.returnMap) (x₀ : X) :
    Tendsto (fun n => P.returnMap^[n] x₀) atTop
      (𝓝 (ContractingWith.fixedPoint P.returnMap hP)) := by
  convert hP.tendsto_iterate_fixedPoint x₀

/-
The finite-time consistency defect controls distance to the unique consistent
state.  This makes the fixed-point statement quantitatively testable.
-/
theorem novikov_aposteriori_error
    {X : Type*} [MetricSpace X] [CompleteSpace X] [Nonempty X]
    (P : CausalBoundaryProblem X) {K : NNReal}
    (hP : ContractingWith K P.returnMap) (x : X) :
    dist x (ContractingWith.fixedPoint P.returnMap hP)
      ≤ dist x (P.returnMap x) / (1 - (K : ℝ)) := by
  convert hP.dist_fixedPoint_le x using 1

/-- A polynomial causal map restricted to a proposed physical state domain. -/
def polynomialProblem (p : Polynomial ℝ) : CausalBoundaryProblem ℝ :=
  ⟨fun x => p.eval x⟩

/-
**Polynomial Novikov theorem on an invariant domain.** If a real polynomial maps
a complete physical domain into itself and its restricted return map is contractive,
then it has a unique self-consistent state in that domain.  This is the precise guarded
form of the claim for polynomial causal maps.
-/
theorem polynomial_novikov_on_complete_domain
    (p : Polynomial ℝ) (s : Set ℝ) (hs : IsComplete s) (hne : s.Nonempty)
    (hmap : MapsTo (fun x => p.eval x) s s) {K : NNReal}
    (hcontract : ContractingWith K (hmap.restrict (fun x => p.eval x) s s)) :
    ∃! x : s, p.eval (x : ℝ) = (x : ℝ) := by
  obtain ⟨x, hx⟩ : ∃ x : s, (fun x : s => ⟨(p.eval x.val), by
    exact hmap x.2⟩) x = x := by
    all_goals generalize_proofs at *;
    have h_fixed_point : ∃ x : s, Function.IsFixedPt (MapsTo.restrict (fun x => p.eval x) s s hmap) x := by
      have h_complete : CompleteSpace s := by
        exact hs.completeSpace_coe
      have := @ContractingWith.exists_fixedPoint s;
      exact Exists.elim ( this hcontract ⟨ hne.some, hne.choose_spec ⟩ ( by simp +decide [ edist_dist ] ) ) fun x hx => ⟨ x, hx.1 ⟩;
    exact h_fixed_point
  generalize_proofs at *;
  refine' ⟨ x, _, _ ⟩ <;> simp_all +decide [ Subtype.ext_iff ];
  intro y hy hy'; have := hcontract.dist_inequality ( ⟨ y, hy ⟩ : s ) x; simp_all +decide [ Subtype.dist_eq ] ;

/-
Affine return maps with slope of absolute value below one are contractions.
-/
lemma affine_contracting (a b : ℝ) (ha : |a| < 1) :
    ContractingWith (Real.toNNReal |a|) (fun x : ℝ => a * x + b) := by
  refine' ⟨ _, _ ⟩;
  · rw [ ← NNReal.coe_lt_coe ] ; aesop;
  · norm_num [ lipschitzWith_iff_norm_sub_le ];
    exact fun x y => by rw [ ← mul_sub, abs_mul ] ;

/-
**Explicit affine time-loop solution.** For `|a| < 1`, the causal law
`x ↦ a x + b` has the unique consistent state `b / (1-a)`.
-/
theorem affine_novikov_solution (a b : ℝ) (ha : |a| < 1) :
    ∃! x : ℝ, a * x + b = x := by
  exact ⟨ b / ( 1 - a ), by linarith [ abs_lt.mp ha, mul_div_cancel₀ b ( by linarith [ abs_lt.mp ha ] : ( 1 - a ) ≠ 0 ) ], fun x hx => by rw [ eq_div_iff ] at * <;> nlinarith [ abs_lt.mp ha ] ⟩

/-
Concrete nontrivial example: repeated causal feedback `x ↦ x/2 + 3` converges
to the unique consistent boundary value `6`.
-/
example : ∃! x : ℝ, (1 / 2 : ℝ) * x + 3 = x := by
  exact affine_novikov_solution ( 1 / 2 ) 3 ( by norm_num [ abs_of_pos ] )

/-
Boundary case: the polynomial return map `x ↦ x² + 1` has no real consistent
state.  Thus polynomiality alone cannot imply Novikov consistency.
-/
theorem quadratic_paradox : ¬ ∃ x : ℝ, x ^ 2 + 1 = x := by
  exact fun ⟨ x, hx ⟩ => by nlinarith;

/-
Discrete boundary case: Boolean negation has no consistent state.
-/
theorem grandfather_paradox : ¬ ∃ b : Bool, (!b) = b := by
  lia

/-
A finite metric state space supplies an independent, elementary instance of the
same principle: strict contraction forces a unique consistent state.  This result
connects the causal interpretation to the catalog's finite contraction theorem.
-/
theorem finite_novikov_unique
    {X : Type*} [MetricSpace X] [Fintype X] [Nonempty X]
    (P : CausalBoundaryProblem X) {K : ℝ} (hK : K < 1)
    (hcontract : ∀ x y, dist (P.returnMap x) (P.returnMap y) ≤ K * dist x y) :
    ∃! x, P.IsSolution x := by
  convert finite_contraction_fixedPoint_unique P.returnMap hK hcontract using 1

#check novikov_banach_unique
#check polynomial_novikov_on_complete_domain
#check finite_contraction_fixedPoint_unique

-- !-- Lab Notes -- !--
/-
Hypothesis (Hypothesizer).  Seven falsifiable targets were ranked by impact:
(1) contraction of the round-trip dynamics implies unique Novikov consistency;
(2) the selected history globally attracts all iterated traversals;
(3) a residual defect gives a computable error certificate;
(4) polynomial causal laws admit consistent histories on complete invariant domains
when their restriction contracts; (5) local derivative bounds can eventually replace
the abstract contraction hypothesis; (6) noncontractive polynomial loops may undergo
fixed-point bifurcations; and (7) stochastic perturbations may select invariant laws
when deterministic consistency fails.  Targets (4)--(7) bridge causal semantics,
real algebraic geometry, dynamics, and probability.

Experiment (Experimenter).  The fixed-point formulation was tested against affine
feedback, the polynomial `x²+1`, and Boolean negation.  The affine family survives
with an explicit unique state.  Both paradox maps refute the unrestricted existence
claim.  The finite-space theorem was imported as an independent route to the same
causal conclusion, while the complete-space results supply convergence and error
bounds unavailable from finiteness alone.

Analysis (Analyst).  The surviving structural pattern is not polynomiality but
contractivity on a closed invariant state domain.  Completeness gives existence,
strict contraction gives uniqueness, and iteration gives physical relaxation toward
the consistent boundary value.  The counterexamples separate three notions that
must not be conflated: having a causal rule, having a polynomial rule, and having a
self-consistent history.

Critique (Critic).  The universal statement “every polynomial causal map is
self-consistent” is false: `x²+1=x` has negative discriminant.  Compactness without
an invariant convex domain is also insufficient.  The main statements therefore
expose completeness, nonemptiness, invariance, and strict contraction explicitly.
The examples are not definitions in disguise, and the main conclusions include
uniqueness, attraction, or quantitative control.

Synthesis (Principal Investigator).  Novikov consistency is established as a
boundary fixed-point condition.  Banach contraction supplies a rigorous sufficient
principle, polynomial maps inherit it on complete invariant domains, and affine maps
provide an explicit family.  The natural generalization is toward local contraction,
multivalued causal response, and stochastic invariant measures; the boundary is
marked by algebraic and discrete paradoxes.
-/

end TimeTravelConsistency