import Mathlib
import Applications.CellularAutomataVariety.Basic
import Computation.CellularAutomata.ShiftsPolynomialsOrbits
import Computation.CellularAutomata.RuleSymmetries

/-!
# Rules whose fixed-point variety is exactly the pair of constant configurations

The right-transitivity criterion of `ShiftsPolynomialsOrbits` certifies rules whose
fixed-point variety is a single point.  There is a companion criterion, satisfied by
the traffic rule 184 among others, in which zeros propagate *leftwards* and ones
propagate *rightwards*: it forces the fixed-point variety to be exactly the two
constant configurations, again for every lattice size.

## Main results

* `forall_of_pred_closed`: the cyclic lattice is also transitive under moving one step
  to the *left*, the mirror of the propagation lemma already used.
* `fixedPoints_eq_pair_of_constant_pair`: the criterion `LeftZeroPropagating`,
  `RightOnePropagating`, `g 0 0 0 = 0`, `g 1 1 1 = 1` forces
  `V(g,n) = {0, 1}` for every nonempty cyclic lattice, hence `#V(g,n) = 2`.
* `card_constantPairRules = 4`: exactly `4` of the `256` rules satisfy it, namely
  `176`, `178`, `184`, `186`.
* `rule184_fixedPoints_ncard`: the traffic rule 184 has exactly two fixed
  configurations on every cyclic lattice, and so does its mirror image.

-- !-- Lab Notes -- !--

HYPOTHESIS.  The census of "`#V` constant in `n`" rules should split into families
indexed by which constant configurations survive; the value `1` family is governed by
rightward propagation of zeros, and there should be a value `2` family governed by a
two-sided propagation pattern.

EXPERIMENT.  Enumeration gave `#V(184,n) = 2` for `n ≤ 8`.  Decoding the truth table
of `184` shows `g a 0 c = 0 → a = 0` and `g a 1 c = 1 → c = 1`: zeros travel left,
ones travel right — the "traffic jam" interpretation of rule 184.

ANALYSIS.  Abstracting those two implications gives a criterion satisfied by exactly
`4` rule numbers, all with `#V ≡ 2`.  Together with the `48` rules of the extended
singleton census this accounts for `52` of the `256` rules by proof rather than by
enumeration.

CRITIQUE.  The criterion is sufficient, not necessary; other rules have `#V ≡ 2`
without satisfying it (for example every rule whose fixed set is a two-element orbit
of a different shape), and no claim to the contrary is made here.
-/

namespace CAConstantPairRules

open CellularAutomataVariety CAShiftsPolynomialsOrbits CARuleSymmetries

variable {n : ℕ}

/-! ## 1. Leftward transitivity of the cyclic lattice -/

/-- If a property passes from each site to its *left* neighbour and holds somewhere,
it holds everywhere. -/
theorem forall_of_pred_closed [NeZero n] (P : ZMod n → Prop)
    (hstep : ∀ i, P i → P (i - 1)) {i₀ : ZMod n} (h0 : P i₀) : ∀ j, P j := by
  have hnat : ∀ k : ℕ, P (i₀ - (k : ZMod n)) := by
    intro k
    induction k with
    | zero => simpa using h0
    | succ m ih =>
        have hm := hstep _ ih
        have e : (i₀ - ((m + 1 : ℕ) : ZMod n)) = (i₀ - (m : ZMod n)) - 1 := by push_cast; ring
        rw [e]; exact hm
  intro j
  have hj : j = i₀ - ((i₀ - j).val : ZMod n) := by
    rw [ZMod.natCast_val, ZMod.cast_id]; ring
  rw [hj]; exact hnat _

/-! ## 2. The two-sided propagation criterion -/

/-- Zeros travel leftwards: a vanishing cell forces its *left* neighbour to vanish. -/
def LeftZeroPropagating (g : LocalRule) : Prop := ∀ a c : Cell, g a 0 c = 0 → a = 0

/-- Ones travel rightwards: a cell equal to `1` forces its *right* neighbour to be
`1`. -/
def RightOnePropagating (g : LocalRule) : Prop := ∀ a c : Cell, g a 1 c = 1 → c = 1

/-- The packaged criterion. -/
def ConstantPairCriterion (g : LocalRule) : Prop :=
  LeftZeroPropagating g ∧ RightOnePropagating g ∧ g 0 0 0 = 0 ∧ g 1 1 1 = 1

instance (g : LocalRule) : Decidable (ConstantPairCriterion g) := by
  unfold ConstantPairCriterion LeftZeroPropagating RightOnePropagating; infer_instance

/-- **Constant-pair theorem.**  Under the criterion the fixed-point variety consists
of exactly the two constant configurations, on every nonempty cyclic lattice. -/
theorem fixedPoints_eq_pair_of_constant_pair [NeZero n] {g : LocalRule}
    (hg : ConstantPairCriterion g) :
    {s : Config n | IsFixed g s} = {(fun _ => 0 : Config n), (fun _ => 1 : Config n)} := by
  obtain ⟨hzero, hone, h0, h1⟩ := hg
  ext s
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · intro hs
    by_cases hex : ∃ i : ZMod n, s i = 0
    · obtain ⟨i₀, hi₀⟩ := hex
      left
      have hprop : ∀ i : ZMod n, s i = 0 → s (i - 1) = 0 := by
        intro i hi
        have hfix := congrFun hs i
        simp only [step] at hfix
        rw [hi] at hfix
        exact hzero _ _ hfix
      have : ∀ j : ZMod n, s j = 0 := forall_of_pred_closed (fun i => s i = 0) hprop hi₀
      funext j; exact this j
    · right
      push_neg at hex
      funext j
      rcases (by decide : ∀ c : Cell, c = 0 ∨ c = 1) (s j) with hc | hc
      · exact absurd hc (hex j)
      · exact hc
  · rintro (rfl | rfl)
    · funext i; exact h0
    · funext i; exact h1

/-- The corresponding count. -/
theorem ncard_fixed_of_constant_pair [NeZero n] {g : LocalRule}
    (hg : ConstantPairCriterion g) : {s : Config n | IsFixed g s}.ncard = 2 := by
  rw [fixedPoints_eq_pair_of_constant_pair hg]
  refine Set.ncard_pair ?_
  intro hcon
  have h := congrFun hcon 0
  revert h
  decide

/-! ## 3. The census of constant-pair rules -/

/-- The elementary rules certified to have exactly the two constant fixed
configurations. -/
def constantPairRules : Finset (Fin 256) :=
  Finset.univ.filter (fun r => ConstantPairCriterion (ruleOfNum r.val))

set_option maxRecDepth 100000 in
/-- **Census.**  Exactly four rules satisfy the criterion. -/
theorem card_constantPairRules : constantPairRules.card = 4 := by
  unfold constantPairRules; decide

set_option maxRecDepth 100000 in
/-- They are the rules `176`, `178`, `184` and `186`. -/
theorem constantPairRules_eq : constantPairRules = {176, 178, 184, 186} := by
  unfold constantPairRules; decide

set_option maxRecDepth 100000 in
theorem rule184_constantPairCriterion : ConstantPairCriterion (ruleOfNum 184) := by
  unfold ConstantPairCriterion LeftZeroPropagating RightOnePropagating; decide

/-- **The traffic rule 184 has exactly two fixed configurations on every cyclic
lattice.** -/
theorem rule184_fixedPoints_ncard [NeZero n] :
    {s : Config n | IsFixed (ruleOfNum 184) s}.ncard = 2 :=
  ncard_fixed_of_constant_pair rule184_constantPairCriterion

/-- By the mirror symmetry, the reflected traffic rule has the same count. -/
theorem rule184_mirror_fixedPoints_ncard [NeZero n] :
    {s : Config n | IsFixed (mirrorRule (ruleOfNum 184)) s}.ncard = 2 := by
  rw [ncard_fixed_mirrorRule]
  exact rule184_fixedPoints_ncard

/-- The traffic rule is separated from Rule 110 by the fixed-point statistic on every
lattice size. -/
theorem rule184_ncard_ne_rule110_ncard [NeZero n] :
    {s : Config n | IsFixed (ruleOfNum 184) s}.ncard
      ≠ {s : Config n | IsFixed rule110 s}.ncard := by
  rw [rule184_fixedPoints_ncard, rule110_fixedPoints_ncard]
  norm_num

end CAConstantPairRules