import Mathlib
import Applications.CellularAutomataVariety.Basic
import Computation.CellularAutomata.ShiftsPolynomialsOrbits
import Computation.CellularAutomata.SimulationEmbeddings

/-!
# The Klein four-group of symmetries of elementary rules, and the extended census

Elementary cellular automata carry two classical symmetries: *reflection* (mirror the
lattice) and *complementation* (swap the two letters of `GF(2)`).  They generate a
Klein four-group acting on the `256` rules, and Wolfram's tables are usually organised
by its orbits.  This file formalises both symmetries as *conjugacies of dynamical
systems* — not merely as bijections of truth tables — and harvests the consequences.

## Main results

* `step_mirrorRule`, `step_dualRule`: reflection conjugates the dynamics of `g` to the
  dynamics of `mirrorRule g`, complementation conjugates it to `dualRule g`.
* `mirrorRule_dualRule_klein`: the two operations are commuting involutions, hence
  generate a Klein four-group on rule space.
* `ncard_fixed_mirrorRule`, `ncard_fixed_dualRule`: the fixed-point count is a
  class function for this group.
* `minimalPeriod_reflectConfig`, `minimalPeriod_complConfig`: so is the entire orbit
  spectrum, exact periods included.
* `card_extSingletonRules = 48`: closing the `16`-rule census of
  `ShiftsPolynomialsOrbits` under the group produces `48` rules that provably have a
  unique fixed configuration on *every* cyclic lattice, three times as many as the
  purely local criterion detects.
* `rule124_fixedPoints_ncard`, `rule137_fixedPoints_ncard`, `rule193_fixedPoints_ncard`:
  the three symmetry partners of Rule 110 inherit its singleton theorem.

-- !-- Lab Notes -- !--

HYPOTHESIS.  The gap observed in cycle 2 (a *local* criterion certifies `16` rules,
while `78` rules have unit fixed-point count for all tested sizes) is partly explained
by symmetry: the criterion is not symmetric under mirror/complement, but the invariant
it computes is.

EXPERIMENT.  Compute the orbit of the `16` certified rules under the group generated
by `mirrorRule` and `dualRule`.  Result: `48` distinct rule numbers, including `124`,
`137` and `193` — the partners of `110`.

ANALYSIS.  Fixed-point counting is a class function on the `88` symmetry classes, so
any classification statement should be phrased on classes, not on rule numbers.  The
remaining gap (`78 - 48 = 30` rules) is not explained by symmetry and needs the
transfer-matrix invariant of Conjecture C2.

CRITIQUE.  Every transport statement is a genuine conjugacy proof; only the finite
census `card_extSingletonRules = 48` is a kernel computation, and it is a statement
about the `256` rule numbers, not about lattices.
-/

namespace CARuleSymmetries

open CellularAutomataVariety CAShiftsPolynomialsOrbits CASimulationEmbeddings Function

set_option maxRecDepth 100000

variable {n : ℕ}

/-! ## 1. The two symmetries -/

/-- The mirror image of a local rule: read the neighbourhood right-to-left. -/
def mirrorRule (g : LocalRule) : LocalRule := fun a b c => g c b a

/-- The complement-dual of a local rule: exchange the two letters of `GF(2)` on both
inputs and outputs. -/
def dualRule (g : LocalRule) : LocalRule := fun a b c => 1 + g (1 + a) (1 + b) (1 + c)

/-- Reflection of a configuration through the origin of the cyclic lattice. -/
def reflectConfig (s : Config n) : Config n := fun i => s (-i)

/-- Complementation of a configuration. -/
def complConfig (s : Config n) : Config n := fun i => 1 + s i

/-- Reflection and complementation are commuting involutions of rule space: they
generate a Klein four-group acting on the `256` elementary rules. -/
theorem mirrorRule_dualRule_klein (g : LocalRule) :
    mirrorRule (mirrorRule g) = g ∧ dualRule (dualRule g) = g ∧
      mirrorRule (dualRule g) = dualRule (mirrorRule g) := by
  refine ⟨rfl, ?_, rfl⟩
  funext a b c
  have h2 : (2 : Cell) = 0 := by decide
  show 1 + (1 + g (1 + (1 + a)) (1 + (1 + b)) (1 + (1 + c))) = g a b c
  rw [show (1 : Cell) + (1 + a) = a from by linear_combination h2,
      show (1 : Cell) + (1 + b) = b from by linear_combination h2,
      show (1 : Cell) + (1 + c) = c from by linear_combination h2]
  linear_combination h2

theorem reflectConfig_involutive (s : Config n) :
    reflectConfig (reflectConfig s) = s := by
  funext i; show s (- -i) = s i; rw [neg_neg]

theorem complConfig_involutive (s : Config n) : complConfig (complConfig s) = s := by
  funext i
  have h2 : (2 : Cell) = 0 := by decide
  show 1 + (1 + s i) = s i
  linear_combination h2

theorem reflectConfig_injective : Injective (reflectConfig : Config n → Config n) := by
  intro a b hab
  have h := congrArg reflectConfig hab
  rwa [reflectConfig_involutive, reflectConfig_involutive] at h

theorem complConfig_injective : Injective (complConfig : Config n → Config n) := by
  intro a b hab
  have h := congrArg complConfig hab
  rwa [complConfig_involutive, complConfig_involutive] at h

/-! ## 2. The symmetries are conjugacies of the dynamics -/

/-- **Reflection conjugacy.**  Reflecting the lattice turns the dynamics of `g` into
the dynamics of its mirror rule. -/
theorem step_mirrorRule (g : LocalRule) (s : Config n) :
    step (mirrorRule g) (reflectConfig s) = reflectConfig (step g s) := by
  funext i
  show g (s (-(i + 1))) (s (-i)) (s (-(i - 1))) = g (s (-i - 1)) (s (-i)) (s (-i + 1))
  rw [show -(i + 1) = -i - 1 from by ring, show -(i - 1) = -i + 1 from by ring]

/-- **Complementation conjugacy.**  Complementing all cells turns the dynamics of `g`
into the dynamics of its complement-dual. -/
theorem step_dualRule (g : LocalRule) (s : Config n) :
    step (dualRule g) (complConfig s) = complConfig (step g s) := by
  funext i
  have h2 : (2 : Cell) = 0 := by decide
  show 1 + g (1 + (1 + s (i - 1))) (1 + (1 + s i)) (1 + (1 + s (i + 1)))
      = 1 + g (s (i - 1)) (s i) (s (i + 1))
  rw [show (1 : Cell) + (1 + s (i - 1)) = s (i - 1) from by linear_combination h2,
      show (1 : Cell) + (1 + s i) = s i from by linear_combination h2,
      show (1 : Cell) + (1 + s (i + 1)) = s (i + 1) from by linear_combination h2]

/-! ## 3. Transport of fixed points and of orbit spectra -/

theorem isFixed_mirrorRule_iff (g : LocalRule) (s : Config n) :
    IsFixed (mirrorRule g) (reflectConfig s) ↔ IsFixed g s := by
  unfold IsFixed
  rw [step_mirrorRule]
  exact ⟨fun h => reflectConfig_injective h, fun h => congrArg reflectConfig h⟩

theorem isFixed_dualRule_iff (g : LocalRule) (s : Config n) :
    IsFixed (dualRule g) (complConfig s) ↔ IsFixed g s := by
  unfold IsFixed
  rw [step_dualRule]
  exact ⟨fun h => complConfig_injective h, fun h => congrArg complConfig h⟩

/-- The fixed-point count is invariant under reflection of the rule. -/
theorem ncard_fixed_mirrorRule (g : LocalRule) :
    {s : Config n | IsFixed (mirrorRule g) s}.ncard = {s : Config n | IsFixed g s}.ncard := by
  have himg : {s : Config n | IsFixed (mirrorRule g) s}
      = reflectConfig '' {s : Config n | IsFixed g s} := by
    ext u
    simp only [Set.mem_setOf_eq, Set.mem_image]
    constructor
    · intro hu
      refine ⟨reflectConfig u, ?_, reflectConfig_involutive u⟩
      exact (isFixed_mirrorRule_iff g (reflectConfig u)).mp
        (by rwa [reflectConfig_involutive])
    · rintro ⟨s, hs, rfl⟩
      exact (isFixed_mirrorRule_iff g s).mpr hs
  rw [himg, Set.ncard_image_of_injective _ reflectConfig_injective]

/-- The fixed-point count is invariant under complementation of the rule. -/
theorem ncard_fixed_dualRule (g : LocalRule) :
    {s : Config n | IsFixed (dualRule g) s}.ncard = {s : Config n | IsFixed g s}.ncard := by
  have himg : {s : Config n | IsFixed (dualRule g) s}
      = complConfig '' {s : Config n | IsFixed g s} := by
    ext u
    simp only [Set.mem_setOf_eq, Set.mem_image]
    constructor
    · intro hu
      refine ⟨complConfig u, ?_, complConfig_involutive u⟩
      exact (isFixed_dualRule_iff g (complConfig u)).mp (by rwa [complConfig_involutive])
    · rintro ⟨s, hs, rfl⟩
      exact (isFixed_dualRule_iff g s).mpr hs
  rw [himg, Set.ncard_image_of_injective _ complConfig_injective]

/-- Exact orbit lengths are invariant under reflection. -/
theorem minimalPeriod_reflectConfig (g : LocalRule) (s : Config n) :
    minimalPeriod (step (mirrorRule g)) (reflectConfig s) = minimalPeriod (step g) s :=
  minimalPeriod_eq_of_injective_semiconj (f := step g) (u := step (mirrorRule g))
    (e := (reflectConfig : Config n → Config n)) reflectConfig_injective
    (fun x => (step_mirrorRule g x).symm) s

/-- Exact orbit lengths are invariant under complementation. -/
theorem minimalPeriod_complConfig (g : LocalRule) (s : Config n) :
    minimalPeriod (step (dualRule g)) (complConfig s) = minimalPeriod (step g) s :=
  minimalPeriod_eq_of_injective_semiconj (f := step g) (u := step (dualRule g))
    (e := (complConfig : Config n → Config n)) complConfig_injective
    (fun x => (step_dualRule g x).symm) s

/-! ## 4. The extended census -/

/-- A rule passes the extended criterion when it, or one of its three symmetry
partners, passes the local singleton criterion. -/
def ExtSingletonCriterion (g : LocalRule) : Prop :=
  SingletonCriterion g ∨ SingletonCriterion (mirrorRule g) ∨
    SingletonCriterion (dualRule g) ∨ SingletonCriterion (mirrorRule (dualRule g))

instance (g : LocalRule) : Decidable (ExtSingletonCriterion g) := by
  unfold ExtSingletonCriterion; infer_instance

/-- **Symmetry-extended singleton theorem.** -/
theorem ext_fixedPoints_ncard [NeZero n] {g : LocalRule} (hg : ExtSingletonCriterion g) :
    {s : Config n | IsFixed g s}.ncard = 1 := by
  rcases hg with h | h | h | h
  · exact fixedPoints_ncard_of_right_transitive h.1 h.2.1 h.2.2
  · rw [← ncard_fixed_mirrorRule (n := n) g]
    exact fixedPoints_ncard_of_right_transitive h.1 h.2.1 h.2.2
  · rw [← ncard_fixed_dualRule (n := n) g]
    exact fixedPoints_ncard_of_right_transitive h.1 h.2.1 h.2.2
  · rw [← ncard_fixed_dualRule (n := n) g, ← ncard_fixed_mirrorRule (n := n) (dualRule g)]
    exact fixedPoints_ncard_of_right_transitive h.1 h.2.1 h.2.2

/-- The rules certified by the extended criterion. -/
def extSingletonRules : Finset (Fin 256) :=
  Finset.univ.filter (fun r => ExtSingletonCriterion (ruleOfNum r.val))

/-- **Extended census.**  `48` of the `256` elementary rules are certified to have a
unique fixed configuration on every cyclic lattice — three times the `16` detected by
the local criterion alone. -/
theorem card_extSingletonRules : extSingletonRules.card = 48 := by
  unfold extSingletonRules; decide

theorem singletonRules_subset_ext : singletonRules ⊆ extSingletonRules := by
  intro r hr
  simp only [extSingletonRules, Finset.mem_filter, Finset.mem_univ, true_and]
  have h : SingletonCriterion (ruleOfNum r.val) := by
    simpa [singletonRules] using hr
  exact Or.inl h

theorem mem_extSingletonRules_fixedPoints_ncard [NeZero n] {r : Fin 256}
    (hr : r ∈ extSingletonRules) :
    {s : Config n | IsFixed (ruleOfNum r.val) s}.ncard = 1 := by
  have h : ExtSingletonCriterion (ruleOfNum r.val) := by
    simpa [extSingletonRules] using hr
  exact ext_fixedPoints_ncard h

/-! ### The symmetry partners of Rule 110 -/

theorem ruleOfNum_124_eq : ruleOfNum 124 = mirrorRule rule110 := by
  funext a b c; revert a b c; decide

theorem ruleOfNum_137_eq : ruleOfNum 137 = dualRule rule110 := by
  funext a b c; revert a b c; decide

theorem ruleOfNum_193_eq : ruleOfNum 193 = mirrorRule (dualRule rule110) := by
  funext a b c; revert a b c; decide

/-- Rule 124, the mirror of Rule 110, also has exactly one fixed configuration on
every cyclic lattice — even though it fails the local criterion. -/
theorem rule124_fixedPoints_ncard [NeZero n] :
    {s : Config n | IsFixed (ruleOfNum 124) s}.ncard = 1 := by
  rw [ruleOfNum_124_eq, ncard_fixed_mirrorRule]
  exact rule110_fixedPoints_ncard

/-- Rule 137, the complement-dual of Rule 110. -/
theorem rule137_fixedPoints_ncard [NeZero n] :
    {s : Config n | IsFixed (ruleOfNum 137) s}.ncard = 1 := by
  rw [ruleOfNum_137_eq, ncard_fixed_dualRule]
  exact rule110_fixedPoints_ncard

/-- Rule 193, the mirror complement-dual of Rule 110. -/
theorem rule193_fixedPoints_ncard [NeZero n] :
    {s : Config n | IsFixed (ruleOfNum 193) s}.ncard = 1 := by
  rw [ruleOfNum_193_eq, ncard_fixed_mirrorRule, ncard_fixed_dualRule]
  exact rule110_fixedPoints_ncard

/-- Rule 124 also inherits the two-cycles of Rule 110: on every lattice of size
divisible by `4` it has a configuration of exact period two. -/
theorem rule124_exists_minimalPeriod_two (h : 4 ∣ n) :
    ∃ s : Config n, minimalPeriod (step (ruleOfNum 124)) s = 2 := by
  obtain ⟨s, hs⟩ := rule110_exists_minimalPeriod_two h
  refine ⟨reflectConfig s, ?_⟩
  rw [ruleOfNum_124_eq, minimalPeriod_reflectConfig]
  exact hs

end CARuleSymmetries