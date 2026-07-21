import Mathlib
import Bridges.TropicalHecke.MinPlusAlgebra

/-!
# Tropical aggregation and the finite Arrow obstruction

A tropical social score is modeled as a map from voter scores to a social score.
Translation equivariance is the tropical Pareto condition, while preservation of
coordinatewise minima is a weak tropical independence condition.  The decisive-
coalition form of independence is stronger: coalitions on which the map depends
must form an ultrafilter.

The unrestricted assertion that the first projection is the unique tropical
social welfare function is false, since every coordinate projection has the same
formal properties.  The corrected theorem says that a finite decisive-coalition
ultrafilter selects a unique voter; after normalization, the score is precisely
that voter's coordinate.  Fixing the decisive ultrafilter to the first voter then
recovers the advertised first projection.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  (1) Finite ultrafilter compatibility forces a unique
normalized tropical projection.  (2) Fixing the principal ultrafilter at voter
zero forces the first projection.  (3) Weak tropical Pareto and min-preservation
permit a genuinely non-projective aggregator.  (4) The min-plus expression
language realizes that aggregator and supplies concavity.  (5) Anonymity is
incompatible with strong decisive-coalition independence for at least two voters.

EXPERIMENT (Experimenter).  On two voters, `min x₀ x₁` is translation equivariant,
preserves coordinatewise minima, and is normalized.  Inputs `(0,1)` and `(1,0)`
disprove equality with either projection.  Thus the original uniqueness claim
needs the decisive-ultrafilter hypothesis, not merely tropical linearity.

ANALYSIS (Analyst).  If a finite ultrafilter is principal at `d`, compatibility
says the score depends only on coordinate `d`.  Compare any profile with the
constant profile of value `x d`; dependence gives equality, translation
-equivariance evaluates the constant profile, and normalization removes the
additive offset.  This separates the combinatorial Arrow step from tropical
algebra.

CRITIQUE (Critic).  Dictatorship is not silently identified with voter zero:
the general theorem quantifies over the uniquely selected voter, and the voter-zero
corollary explicitly assumes the corresponding principal ultrafilter.  The weak
counterexample is proved non-projective on every coordinate, not merely exhibited
by numerical sampling.  No classical-limit theorem is claimed: without a chosen
dequantization and a ranking semantics, that phrase has no invariant meaning.

SYNTHESIS (Principal Investigator).  Strong independence reproduces the finite
ultrafilter core of Arrow's theorem, whereas tropical min-linearity alone admits
non-dictatorial aggregation.  The boundary is exactly the upgrade from algebraic
min-preservation to an ultrafilter of decisive coalitions.
-- !-- Lab Notes -- !--
-/

open Set Filter

namespace TropicalSocialChoice

/-- Coordinatewise minimum of two score profiles. -/
def profileMin {V : Type*} (x y : V → ℝ) : V → ℝ := fun i => min (x i) (y i)

/-- Weak tropical linearity: preservation of tropical addition (`min`) and
translation by tropical scalars. -/
structure TropicalLinear {V : Type*} (f : (V → ℝ) → ℝ) : Prop where
  map_min : ∀ x y, f (profileMin x y) = min (f x) (f y)
  add_const : ∀ x c, f (fun i => x i + c) = f x + c

/-- Normalization at the zero profile. -/
def Normalized {V : Type*} (f : (V → ℝ) → ℝ) : Prop := f (fun _ => 0) = 0

/-- The social score depends only on the coordinates in coalition `S`. -/
def DependsOnlyOn {V : Type*} (f : (V → ℝ) → ℝ) (S : Set V) : Prop :=
  ∀ x y, (∀ i ∈ S, x i = y i) → f x = f y

/-- A strong Arrow-style independence axiom: the coalitions carrying all
relevant information are exactly the members of a decisive ultrafilter. -/
def ArrowCompatible {V : Type*} (f : (V → ℝ) → ℝ) (U : Ultrafilter V) : Prop :=
  ∀ S : Set V, S ∈ U ↔ DependsOnlyOn f S

/-- The coordinate projection associated with voter `d`. -/
def projection {V : Type*} (d : V) : (V → ℝ) → ℝ := fun x => x d

lemma projection_tropicalLinear {V : Type*} (d : V) : TropicalLinear (projection d) := by
  constructor <;> intros <;> aesop

lemma projection_normalized {V : Type*} (d : V) : Normalized (projection d) := by
  rfl

/-
Dependence on one coordinate, translation equivariance, and normalization
force exact projection onto that coordinate.
-/
lemma eq_projection_of_depends_singleton {V : Type*} {f : (V → ℝ) → ℝ} {d : V}
    (htrans : ∀ x c, f (fun i => x i + c) = f x + c)
    (hnorm : Normalized f) (hdep : DependsOnlyOn f ({d} : Set V)) :
    f = projection d := by
  ext x; specialize hdep x ( fun _ ↦ x d ) ; simp_all +decide ;
  have := htrans ( fun _ => 0 ) ( x d ) ; simp_all +decide [ Normalized, projection ] ;

/-
**Finite tropical Arrow theorem.**  Strong decisive-coalition independence
selects one voter, and every normalized translation-equivariant score is that
voter's projection.
-/
theorem finite_tropical_arrow [Finite V] {f : (V → ℝ) → ℝ} (U : Ultrafilter V)
    (hlin : TropicalLinear f) (hnorm : Normalized f) (hArrow : ArrowCompatible f U) :
    ∃! d : V, f = projection d := by
  obtain ⟨ d, hd ⟩ := Ultrafilter.eq_pure_of_finite U;
  -- By definition of `ArrowCompatible`, we have that `DependsOnlyOn f {d}`.
  have h_dep : DependsOnlyOn f {d} := by
    exact hArrow _ |>.1 ( hd ▸ by simp +decide );
  refine' ⟨ d, _, _ ⟩;
  · exact eq_projection_of_depends_singleton hlin.add_const hnorm h_dep;
  · intro y hy; have := hArrow { y } ; simp_all +decide [ Ultrafilter.mem_pure ] ;
    exact this.mpr ( fun x z h => by aesop ) ▸ rfl

/-
With the decisive ultrafilter fixed at voter `0`, the corrected uniqueness
statement gives exactly the first-coordinate dictator.
-/
theorem first_projection_unique {n : ℕ} (hn : 0 < n) {f : (Fin n → ℝ) → ℝ}
    (hlin : TropicalLinear f) (hnorm : Normalized f)
    (hArrow : ArrowCompatible f (pure (⟨0, hn⟩ : Fin n))) :
    f = projection (⟨0, hn⟩ : Fin n) := by
  have h_dep_0 : DependsOnlyOn f ({⟨0, hn⟩} : Set (Fin n)) := by
    have := hArrow {⟨0, hn⟩}
    exact this.mp <| by simp +decide ;
  exact eq_projection_of_depends_singleton hlin.add_const hnorm h_dep_0

/-- Binary tropical minimum aggregation. -/
def binaryMin : (Fin 2 → ℝ) → ℝ := fun x => min (x 0) (x 1)

/-
The binary minimum is a normalized tropical-linear social score.
-/
theorem binaryMin_tropicalLinear : TropicalLinear binaryMin := by
  constructor;
  · exact fun x y => by unfold binaryMin profileMin; ac_rfl;
  · exact fun x c => min_add_add_right _ _ _

lemma binaryMin_normalized : Normalized binaryMin := by
  exact show min ( 0 : ℝ ) 0 = 0 by norm_num;

/-
The weakly axiomatized binary minimum is not any coordinate projection.
-/
theorem binaryMin_nondictatorial : ∀ d : Fin 2, binaryMin ≠ projection d := by
  rintro d hd; have := congr_fun hd ( fun i => if i = 0 then 1 else 0 ) ; fin_cases d <;> norm_num [ binaryMin, projection ] at this;
  exact absurd ( congr_fun hd ( fun i => if i = 0 then 0 else 1 ) ) ( by simp +decide [ binaryMin, projection ] )

/-
The non-dictatorial aggregator is the evaluation of a genuine min-plus
expression, anchoring the social-choice construction in tropical expression
algebra.
-/
theorem binaryMin_expression_bridge (x : Fin 2 → ℝ) :
    binaryMin x =
      (MinPlusExpr.trop_add (MinPlusExpr.var 0) (MinPlusExpr.var 1)).eval x := by
  rfl

/-
Consequently binary minimum satisfies the concavity inequality inherited
from all min-plus expressions.
-/
theorem binaryMin_concave (x y : Fin 2 → ℝ) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    binaryMin (fun j => (1 - t) * x j + t * y j) ≥
      (1 - t) * binaryMin x + t * binaryMin y := by
  convert MinPlusExpr.eval_concave ( MinPlusExpr.trop_add ( MinPlusExpr.var 0 ) ( MinPlusExpr.var 1 ) ) x y t ht0 ht1 using 1

end TropicalSocialChoice