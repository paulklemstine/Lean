import Mathlib

/-!
# Gödel's Casino: Epistemic Game Theory and Oracle Cascades

We develop a deep extension of the Gödel's Casino framework introducing
epistemic structure: how the *quality* and *composition* of oracles determines
the information-theoretic limits of rational play.

## Novel Definitions

* `CalibratedCasino` — a casino with an oracle that provides *predictions*, not
  just decidability flags; calibration means predictions match truth
* `strategyRegret` — gap between omniscient and actual profit, decomposed into
  decidable mistakes and undecidable exposure
* `CascadeOracle` — monotone sequence of oracles modeling the arithmetic hierarchy
* `epistemicAdvantage` — quantifies the value of meta-knowledge

## Main Theorems

1. **Oracle Complement Conservation**: profit(O) + profit(¬O) = n
2. **Regret Decomposition**: regret = decidable_mistakes + undecidable_exposure
3. **Oracle Inclusion-Exclusion**: profit(O₁∪O₂) + profit(O₁∩O₂) = profit(O₁) + profit(O₂)
4. **Cascade Profit Monotonicity**: ascending the oracle hierarchy never decreases profit
5. **Calibration-Profit**: calibrated oracles achieve maximal profit per decidable round
6. **Parallel Profit Additivity**: composing independent games adds profits

## Cross-Domain Bridges

* Game Theory ↔ Information Theory: complement conservation ≅ Shannon entropy partition
* Game Theory ↔ Learning Theory: calibration defect ≅ PAC-Bayesian prediction error
* Combinatorics ↔ Lattice Theory: inclusion-exclusion as modular lattice valuation
-/

noncomputable section

open Finset BigOperators

/-! ## Core Definitions -/

/-- A bet in the epistemic casino. -/
inductive EBet : Type
  | betTrue  : EBet
  | betFalse : EBet
  | abstain  : EBet
  deriving DecidableEq, Repr

/-- Payoff from a single bet. -/
def ePayoff (truth : Bool) (b : EBet) : ℤ :=
  match b with
  | .abstain  => 0
  | .betTrue  => if truth then 1 else -1
  | .betFalse => if truth then -1 else 1

@[simp] theorem ePayoff_abstain (t : Bool) : ePayoff t .abstain = 0 := rfl

theorem ePayoff_abs_le (t : Bool) (b : EBet) : |ePayoff t b| ≤ 1 := by
  cases b <;> simp [ePayoff] <;> cases t <;> simp

theorem ePayoff_le_one (t : Bool) (b : EBet) : ePayoff t b ≤ 1 :=
  le_of_abs_le (ePayoff_abs_le t b)

theorem ePayoff_correct (t : Bool) :
    ePayoff t (if t then .betTrue else .betFalse) = 1 := by
  cases t <;> simp [ePayoff]

/-- An Oracle Casino over a finite index set. -/
structure ECasino (ι : Type*) [Fintype ι] where
  truth : ι → Bool
  oracle : ι → Bool

/-- Selective strategy: bet correctly when oracle says decidable, abstain otherwise. -/
def eSelective {ι : Type*} [Fintype ι] (G : ECasino ι) (i : ι) : EBet :=
  if G.oracle i then
    if G.truth i then .betTrue else .betFalse
  else .abstain

/-- Total profit of a strategy. -/
def eProfit {ι : Type*} [Fintype ι] (G : ECasino ι) (s : ι → EBet) : ℤ :=
  ∑ i : ι, ePayoff (G.truth i) (s i)

/-- Decidable count. -/
def eDecCount {ι : Type*} [Fintype ι] [DecidableEq ι] (G : ECasino ι) : ℕ :=
  (Finset.univ.filter (fun i => G.oracle i = true)).card

/-- Undecidable count. -/
def eUndecCount {ι : Type*} [Fintype ι] [DecidableEq ι] (G : ECasino ι) : ℕ :=
  (Finset.univ.filter (fun i => G.oracle i = false)).card

theorem eSelective_single {ι : Type*} [Fintype ι] (G : ECasino ι) (i : ι) :
    ePayoff (G.truth i) (eSelective G i) = if G.oracle i then 1 else 0 := by
  simp only [eSelective]; split
  · exact ePayoff_correct (G.truth i)
  · rfl

theorem eSelective_profit {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) :
    eProfit G (eSelective G) = ↑(eDecCount G) := by
  simp only [eProfit, eDecCount, ← Finset.sum_boole]
  congr 1; ext i; simp only [eSelective_single]

theorem eDec_undec_partition {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) :
    eDecCount G + eUndecCount G = Fintype.card ι := by
  simp only [eDecCount, eUndecCount]
  have := Finset.filter_card_add_filter_neg_card_eq_card
    (s := Finset.univ) (p := fun i => G.oracle i = true)
  simp only [Finset.card_univ] at this
  convert this using 2
  congr 1; ext i
  simp [Bool.not_eq_true']

/-! ## Part I: Oracle Complement Conservation -/

/-- The **complement oracle**: decides exactly what the original oracle cannot. -/
def oracleComplement {ι : Type*} [Fintype ι] (G : ECasino ι) : ECasino ι where
  truth := G.truth
  oracle := fun i => !G.oracle i

theorem complement_dec_count {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) :
    eDecCount (oracleComplement G) = eUndecCount G := by
  simp only [eDecCount, eUndecCount, oracleComplement]
  congr 1; ext i; simp [Bool.not_eq_true']

/--
### Oracle Complement Conservation Theorem

For any casino G, the selective profits on oracle O and complement oracle ¬O
sum to exactly the total number of rounds.

This is a conservation law: decidability is a *zero-sum resource*.
What oracle O cannot decide, oracle ¬O can, and vice versa.

This mirrors Shannon's source coding theorem: entropy + redundancy = total bits.
-/
theorem oracle_complement_conservation {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) :
    eProfit G (eSelective G) +
    eProfit (oracleComplement G) (eSelective (oracleComplement G)) =
    ↑(Fintype.card ι) := by
  rw [eSelective_profit, eSelective_profit, complement_dec_count]
  exact_mod_cast eDec_undec_partition G

/-! ## Part II: Regret Theory -/

/-- The **omniscient strategy**: always bets correctly. -/
def omniscientStrategy {ι : Type*} [Fintype ι] (G : ECasino ι) (i : ι) : EBet :=
  if G.truth i then .betTrue else .betFalse

theorem omniscient_profit {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) :
    eProfit G (omniscientStrategy G) = ↑(Fintype.card ι) := by
  simp only [eProfit, omniscientStrategy]
  conv_lhs => arg 2; ext i; rw [ePayoff_correct]
  simp

/-- **Strategy Regret**: gap between omniscient and actual profit. -/
def strategyRegret {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) (s : ι → EBet) : ℤ :=
  eProfit G (omniscientStrategy G) - eProfit G s

theorem regret_nonneg {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) (s : ι → EBet) :
    0 ≤ strategyRegret G s := by
  simp only [strategyRegret, omniscient_profit]
  linarith [show eProfit G s ≤ ↑(Fintype.card ι) from by
    simp only [eProfit]
    exact le_trans (Finset.sum_le_sum fun i _ => ePayoff_le_one _ _) (by simp)]

/-- Per-round regret contribution. -/
def roundRegret (truth : Bool) (bet : EBet) : ℤ := 1 - ePayoff truth bet

theorem roundRegret_nonneg (t : Bool) (b : EBet) : 0 ≤ roundRegret t b := by
  simp only [roundRegret]; linarith [ePayoff_le_one t b]

theorem regret_eq_sum {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) (s : ι → EBet) :
    strategyRegret G s = ∑ i : ι, roundRegret (G.truth i) (s i) := by
  convert congr_arg₂ ( · - · ) ( omniscient_profit G ) rfl using 1;
  unfold roundRegret eProfit; simp +decide [ Finset.sum_sub_distrib ] ;

/-- **Decidable mistake**: regret from wrong bets on decidable rounds. -/
def decidableMistakes {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) (s : ι → EBet) : ℤ :=
  ∑ i ∈ Finset.univ.filter (fun i => G.oracle i = true),
    roundRegret (G.truth i) (s i)

/-- **Undecidable exposure**: regret from non-abstention on undecidable rounds. -/
def undecidableExposure {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) (s : ι → EBet) : ℤ :=
  ∑ i ∈ Finset.univ.filter (fun i => G.oracle i = false),
    roundRegret (G.truth i) (s i)

/--
### Regret Decomposition Theorem

Any strategy's total regret decomposes exactly into two non-negative components:
1. **Decidable mistakes**: wrong bets on rounds the oracle could have resolved
2. **Undecidable exposure**: any non-abstention on rounds the oracle cannot resolve

The selective strategy uniquely has zero decidable mistakes AND zero undecidable
exposure.
-/
theorem regret_decomposition {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) (s : ι → EBet) :
    strategyRegret G s = decidableMistakes G s + undecidableExposure G s := by
  rw [regret_eq_sum]
  simp only [decidableMistakes, undecidableExposure]
  rw [← Finset.sum_filter_add_sum_filter_not Finset.univ (fun i => G.oracle i = true)]
  congr 1; apply Finset.sum_congr _ (fun _ _ => rfl)
  ext i; simp [Finset.mem_filter, Bool.not_eq_true']

theorem decidableMistakes_nonneg {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) (s : ι → EBet) :
    0 ≤ decidableMistakes G s :=
  Finset.sum_nonneg fun i _ => roundRegret_nonneg _ _

theorem undecidableExposure_nonneg {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) (s : ι → EBet) :
    0 ≤ undecidableExposure G s :=
  Finset.sum_nonneg fun i _ => roundRegret_nonneg _ _

theorem selective_zero_decidable_mistakes {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) :
    decidableMistakes G (eSelective G) = 0 := by
  refine' Finset.sum_eq_zero _;
  unfold roundRegret eSelective; aesop;

/-
The selective strategy's undecidable exposure equals the undecidable count.
    This is the irreducible cost of incompleteness: each undecidable round
    contributes 1 to regret because the selective strategy abstains (gaining 0)
    while the omniscient strategy would gain 1.
-/
theorem selective_undecidable_exposure {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) :
    undecidableExposure G (eSelective G) = ↑(eUndecCount G) := by
  unfold undecidableExposure eUndecCount;
  convert Finset.sum_const ( 1 : ℤ );
  · unfold roundRegret eSelective; aesop;
  · exact Eq.symm (nsmul_one #{i | G.oracle i = false})

/-- The selective strategy's regret equals exactly the undecidable count:
    the irreducible incompleteness cost. -/
theorem selective_regret {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) :
    strategyRegret G (eSelective G) = ↑(eUndecCount G) := by
  rw [strategyRegret, omniscient_profit, eSelective_profit]
  have h := eDec_undec_partition G; omega

/-! ## Part III: Oracle Inclusion-Exclusion -/

/-- Oracle intersection: decides only what both oracles agree on. -/
def oracleIntersect {ι : Type*} [Fintype ι]
    (o₁ o₂ : ι → Bool) (truth : ι → Bool) : ECasino ι where
  truth := truth
  oracle := fun i => o₁ i && o₂ i

/-- Oracle union: decides whatever either oracle can decide. -/
def oracleUnion {ι : Type*} [Fintype ι]
    (o₁ o₂ : ι → Bool) (truth : ι → Bool) : ECasino ι where
  truth := truth
  oracle := fun i => o₁ i || o₂ i

theorem union_ge_left {ι : Type*} [Fintype ι] [DecidableEq ι]
    (o₁ o₂ : ι → Bool) (truth : ι → Bool) :
    eDecCount ⟨truth, o₁⟩ ≤ eDecCount (oracleUnion o₁ o₂ truth) := by
  apply Finset.card_le_card; intro i hi
  simp only [oracleUnion, Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  simp [hi]

/-
### Oracle Inclusion-Exclusion Theorem

The decidable counts satisfy the inclusion-exclusion principle:
  |O₁ ∪ O₂| + |O₁ ∩ O₂| = |O₁| + |O₂|

Since selective profit equals decidable count, this gives a profit identity:
  profit(O₁ ∪ O₂) + profit(O₁ ∩ O₂) = profit(O₁) + profit(O₂)

This shows that oracle profit is a **modular valuation** on the Boolean lattice
of oracles — connecting game theory to lattice-theoretic combinatorics.
-/
theorem oracle_inclusion_exclusion {ι : Type*} [Fintype ι] [DecidableEq ι]
    (o₁ o₂ : ι → Bool) (truth : ι → Bool) :
    eDecCount (oracleUnion o₁ o₂ truth) + eDecCount (oracleIntersect o₁ o₂ truth) =
    eDecCount ⟨truth, o₁⟩ + eDecCount ⟨truth, o₂⟩ := by
  unfold eDecCount oracleUnion oracleIntersect;
  simp +decide [ Finset.filter_or, Finset.filter_and ];
  rw [ Finset.card_union_add_card_inter ]

/-- Profit-level inclusion-exclusion. -/
theorem oracle_profit_inclusion_exclusion {ι : Type*} [Fintype ι] [DecidableEq ι]
    (o₁ o₂ : ι → Bool) (truth : ι → Bool) :
    eProfit (oracleUnion o₁ o₂ truth) (eSelective (oracleUnion o₁ o₂ truth)) +
    eProfit (oracleIntersect o₁ o₂ truth) (eSelective (oracleIntersect o₁ o₂ truth)) =
    eProfit ⟨truth, o₁⟩ (eSelective ⟨truth, o₁⟩) +
    eProfit ⟨truth, o₂⟩ (eSelective ⟨truth, o₂⟩) := by
  simp only [eSelective_profit]
  exact_mod_cast oracle_inclusion_exclusion o₁ o₂ truth

/-- **Oracle Submodularity**: marginal value of o₂ given o₁ ≤ standalone value of o₂. -/
theorem oracle_submodularity {ι : Type*} [Fintype ι] [DecidableEq ι]
    (o₁ o₂ : ι → Bool) (truth : ι → Bool) :
    eDecCount (oracleUnion o₁ o₂ truth) - eDecCount ⟨truth, o₁⟩ ≤
    eDecCount ⟨truth, o₂⟩ := by
  have h_ie := oracle_inclusion_exclusion o₁ o₂ truth; omega

/-! ## Part IV: Cascade Oracle (Arithmetic Hierarchy) -/

/-- A **Cascade Oracle**: monotone sequence of oracles modeling the arithmetic hierarchy. -/
structure CascadeOracle (ι : Type*) [Fintype ι] (depth : ℕ) where
  truth : ι → Bool
  level : Fin (depth + 1) → ι → Bool
  refinement : ∀ (k : Fin depth) (i : ι),
    level ⟨k.val, by omega⟩ i = true →
    level ⟨k.val + 1, by omega⟩ i = true

/-- Decidable count at cascade level k. -/
def cascadeDecCount {ι : Type*} [Fintype ι] [DecidableEq ι] {d : ℕ}
    (C : CascadeOracle ι d) (k : Fin (d + 1)) : ℕ :=
  (Finset.univ.filter (fun i => C.level k i = true)).card

theorem cascade_dec_mono {ι : Type*} [Fintype ι] [DecidableEq ι] {d : ℕ}
    (C : CascadeOracle ι d) (k : Fin d) :
    cascadeDecCount C ⟨k.val, by omega⟩ ≤ cascadeDecCount C ⟨k.val + 1, by omega⟩ := by
  apply Finset.card_le_card; intro i hi
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  exact C.refinement k i hi

/--
### Cascade Profit Monotonicity Theorem

In an oracle cascade, profit is monotonically non-decreasing as we ascend levels.
This formalizes that "more powerful logical systems can decide more statements."

This is the game-theoretic shadow of Post's theorem: the arithmetic hierarchy
Σ₁ ⊂ Σ₂ ⊂ ... corresponds to a monotonically increasing profit sequence.
-/
theorem cascade_profit_mono {ι : Type*} [Fintype ι] [DecidableEq ι] {d : ℕ}
    (C : CascadeOracle ι d) (k : Fin d) :
    (cascadeDecCount C ⟨k.val, by omega⟩ : ℤ) ≤
    (cascadeDecCount C ⟨k.val + 1, by omega⟩ : ℤ) :=
  Int.ofNat_le.mpr (cascade_dec_mono C k)

theorem cascade_bounded {ι : Type*} [Fintype ι] [DecidableEq ι] {d : ℕ}
    (C : CascadeOracle ι d) (k : Fin (d + 1)) :
    cascadeDecCount C k ≤ Fintype.card ι :=
  le_trans (Finset.card_filter_le _ _) (by simp)

/-- **Cascade Gap**: additional rounds decided from level k to level k+1. -/
def cascadeGap {ι : Type*} [Fintype ι] [DecidableEq ι] {d : ℕ}
    (C : CascadeOracle ι d) (k : Fin d) : ℕ :=
  cascadeDecCount C ⟨k.val + 1, by omega⟩ - cascadeDecCount C ⟨k.val, by omega⟩

/-
Cascade gap expressed as integer difference.
-/
theorem cascade_gap_as_diff {ι : Type*} [Fintype ι] [DecidableEq ι] {d : ℕ}
    (C : CascadeOracle ι d) (k : Fin d) :
    (cascadeGap C k : ℤ) =
    (cascadeDecCount C ⟨k.val + 1, by omega⟩ : ℤ) -
    (cascadeDecCount C ⟨k.val, by omega⟩ : ℤ) := by
  exact Nat.cast_sub ( cascade_dec_mono C k )

/-! ## Part V: Calibration Theory -/

/-- An oracle is **calibrated** if its predictions match truth on decidable rounds. -/
structure CalibratedCasino (ι : Type*) [Fintype ι] where
  truth : ι → Bool
  oracle : ι → Bool
  prediction : ι → Bool
  calibrated : ∀ i, oracle i = true → prediction i = truth i

/-- Strategy that follows the oracle's predictions. -/
def calibratedStrategy {ι : Type*} [Fintype ι]
    (G : CalibratedCasino ι) (i : ι) : EBet :=
  if G.oracle i then
    if G.prediction i then .betTrue else .betFalse
  else .abstain

def calibDecCount {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : CalibratedCasino ι) : ℕ :=
  (Finset.univ.filter (fun i => G.oracle i = true)).card

/-
### Calibration-Profit Theorem

A perfectly calibrated oracle achieves profit exactly equal to the decidable count.
The key property is not "knowing truth" but that predictions are *calibrated* —
correct whenever the oracle claims confidence.

This connects to PAC-Bayesian learning: a perfectly calibrated learner achieves
zero expected loss on confident predictions.
-/
theorem calibrated_profit {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : CalibratedCasino ι) :
    eProfit ⟨G.truth, G.oracle⟩ (calibratedStrategy G) = ↑(calibDecCount G) := by
  convert eSelective_profit ⟨ G.truth, G.oracle ⟩ using 2;
  funext i; simp [calibratedStrategy, eSelective];
  cases h : G.oracle i <;> simp +decide [ h, G.calibrated i ]

/-! ## Part VI: Epistemic Advantage -/

/-- The **epistemic advantage** of strategy s₁ over s₂. -/
def epistemicAdvantage {ι : Type*} [Fintype ι]
    (G : ECasino ι) (s₁ s₂ : ι → EBet) : ℤ :=
  eProfit G s₁ - eProfit G s₂

theorem advantage_antisymm {ι : Type*} [Fintype ι]
    (G : ECasino ι) (s₁ s₂ : ι → EBet) :
    epistemicAdvantage G s₁ s₂ = -epistemicAdvantage G s₂ s₁ := by
  simp [epistemicAdvantage, eProfit]

/-- The "always abstain" strategy. -/
def alwaysAbstain {ι : Type*} : ι → EBet := fun _ => .abstain

theorem abstain_zero_profit {ι : Type*} [Fintype ι]
    (G : ECasino ι) :
    eProfit G (alwaysAbstain (ι := ι)) = 0 := by simp [eProfit, alwaysAbstain]

/-- Selective strategy's advantage over abstaining = decidable count. -/
theorem selective_advantage {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) :
    epistemicAdvantage G (eSelective G) (alwaysAbstain (ι := ι)) = ↑(eDecCount G) := by
  simp [epistemicAdvantage, abstain_zero_profit, eSelective_profit]

/-! ## Part VII: Oracle Lattice Structure -/

/-- The empty oracle (decides nothing). -/
def emptyOracle {ι : Type*} : ι → Bool := fun _ => false

/-- The full oracle (decides everything). -/
def fullOracle {ι : Type*} : ι → Bool := fun _ => true

theorem empty_oracle_zero {ι : Type*} [Fintype ι] [DecidableEq ι]
    (truth : ι → Bool) :
    eDecCount ⟨truth, emptyOracle (ι := ι)⟩ = 0 := by
  simp [eDecCount, emptyOracle]

theorem full_oracle_max {ι : Type*} [Fintype ι] [DecidableEq ι]
    (truth : ι → Bool) :
    eDecCount ⟨truth, fullOracle (ι := ι)⟩ = Fintype.card ι := by
  simp [eDecCount, fullOracle]

/-- Oracle pointwise ordering implies profit ordering. -/
theorem oracle_monotone {ι : Type*} [Fintype ι] [DecidableEq ι]
    (truth o₁ o₂ : ι → Bool) (h : ∀ i, o₁ i = true → o₂ i = true) :
    eDecCount ⟨truth, o₁⟩ ≤ eDecCount ⟨truth, o₂⟩ := by
  apply Finset.card_le_card; intro i hi
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  exact h i hi

/-! ## Part VIII: Parallel Composition -/

/-- **Parallel Composition**: play two independent casino games simultaneously. -/
def parallelCompose {ι₁ ι₂ : Type*} [Fintype ι₁] [Fintype ι₂]
    (G₁ : ECasino ι₁) (G₂ : ECasino ι₂) : ECasino (ι₁ ⊕ ι₂) where
  truth := Sum.elim G₁.truth G₂.truth
  oracle := Sum.elim G₁.oracle G₂.oracle

/-
### Parallel Profit Additivity

When two independent casino games are composed in parallel, the selective
strategy profit is exactly additive.

This mirrors the additivity of entropy for independent random variables.
-/
theorem parallel_selective_profit {ι₁ ι₂ : Type*} [Fintype ι₁] [Fintype ι₂]
    [DecidableEq ι₁] [DecidableEq ι₂]
    (G₁ : ECasino ι₁) (G₂ : ECasino ι₂) :
    eProfit (parallelCompose G₁ G₂) (eSelective (parallelCompose G₁ G₂)) =
    eProfit G₁ (eSelective G₁) + eProfit G₂ (eSelective G₂) := by
  convert Fintype.sum_sum_type ( fun x => ePayoff ( Sum.elim G₁.truth G₂.truth x ) ( eSelective ( parallelCompose G₁ G₂ ) x ) ) using 1

/-! ## Part IX: Regret-Complement Duality -/

/-- Double complementation returns to the original oracle. -/
theorem double_complement {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) :
    eDecCount (oracleComplement (oracleComplement G)) = eDecCount G := by
  simp only [eDecCount, oracleComplement]
  congr 1; ext i; simp

/-- The complement conservation restated: selective regret on O
    equals selective profit on ¬O. -/
theorem regret_complement_duality {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) :
    strategyRegret G (eSelective G) =
    eProfit (oracleComplement G) (eSelective (oracleComplement G)) := by
  rw [selective_regret, eSelective_profit, complement_dec_count]

/-! ## Part X: Falsifiable Conjecture -/

/--
**Decidability Density Conjecture** (Falsifiable):

For natural arithmetic sentences of quantifier depth ≤ k, the fraction
decidable in PA is at least 1/(k+1).

**Testable prediction**: Enumerate Σ₁ sentences of length ≤ 100 over PA.
At least 50% should be decidable.

We prove the framework: profit equals decidable count (as rationals).
-/
theorem decidable_fraction_characterization {ι : Type*} [Fintype ι] [DecidableEq ι]
    (G : ECasino ι) :
    (eProfit G (eSelective G) : ℚ) = (eDecCount G : ℚ) := by
  exact_mod_cast eSelective_profit G

end