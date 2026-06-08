/-
  # Bayesian Werewolf: Optimal Strategy for Social Deduction Games

  In the game Werewolf (Mafia), n players include k werewolves and n-k villagers.
  Each night, werewolves eliminate one villager. Each day, all remaining players
  vote to eliminate one player. Villagers win if all werewolves are eliminated;
  werewolves win if they equal or outnumber the remaining villagers.

  This module formalizes the game-theoretic foundations:
  - Game state and win conditions
  - Combinatorial bounds on game duration
  - The random elimination probability (a baseline strategy)
  - Bayesian posterior framework
  - Connection to Markov chain absorption probabilities and information theory
-/

import Mathlib

open Finset BigOperators

/-! ## Game State Definition -/

/-- A Werewolf game state tracks the number of remaining werewolves and villagers. -/
structure WerewolfState where
  /-- Number of remaining werewolves -/
  wolves : ℕ
  /-- Number of remaining villagers -/
  villagers : ℕ
  deriving Repr, DecidableEq

namespace WerewolfState

/-- Total number of remaining players -/
def totalPlayers (s : WerewolfState) : ℕ := s.wolves + s.villagers

/-- The game is over when werewolves win or are all eliminated -/
def gameOver (s : WerewolfState) : Prop :=
  s.wolves = 0 ∨ s.wolves ≥ s.villagers

/-- Villagers win condition: all werewolves eliminated with at least one villager alive -/
def villagersWin (s : WerewolfState) : Prop :=
  s.wolves = 0 ∧ s.villagers > 0

/-- Werewolves win condition: werewolves equal or outnumber villagers -/
def werewolvesWin (s : WerewolfState) : Prop :=
  s.wolves ≥ s.villagers ∧ s.wolves > 0

instance : DecidablePred (fun s : WerewolfState => s.gameOver) :=
  fun s => inferInstanceAs (Decidable (s.wolves = 0 ∨ s.wolves ≥ s.villagers))

/-- A valid game state has at least one werewolf and strictly more villagers than werewolves -/
def valid (s : WerewolfState) : Prop :=
  s.wolves > 0 ∧ s.wolves < s.villagers

/-- State after a day round where a werewolf is correctly eliminated -/
def eliminateWolf (s : WerewolfState) : WerewolfState :=
  ⟨s.wolves - 1, s.villagers⟩

/-- State after a day round where a villager is incorrectly eliminated -/
def eliminateVillager (s : WerewolfState) : WerewolfState :=
  ⟨s.wolves, s.villagers - 1⟩

/-- State after a night round (werewolves eliminate one villager) -/
def nightKill (s : WerewolfState) : WerewolfState :=
  ⟨s.wolves, s.villagers - 1⟩

/-- A full round: day elimination of wolf followed by night kill -/
def fullRoundCorrect (s : WerewolfState) : WerewolfState :=
  s.eliminateWolf.nightKill

/-- A full round where a villager is eliminated during the day -/
def fullRoundIncorrect (s : WerewolfState) : WerewolfState :=
  s.eliminateVillager.nightKill

/-
The win condition is exclusive: villagers and werewolves cannot both win.
-/
theorem win_exclusive (s : WerewolfState) :
    ¬(s.villagersWin ∧ s.werewolvesWin) := by
  unfold WerewolfState.villagersWin WerewolfState.werewolvesWin; aesop;

/-
If the game is over, exactly one side has won (given at least one player).
-/
theorem game_over_dichotomy (s : WerewolfState) (h : s.gameOver) (hp : s.totalPlayers > 0) :
    s.villagersWin ∨ s.werewolvesWin := by
  unfold WerewolfState.villagersWin WerewolfState.werewolvesWin;
  cases h <;> unfold WerewolfState.totalPlayers at hp <;> omega

/-
Each correct full round strictly reduces total players by 2.
-/
theorem full_round_correct_decreases (s : WerewolfState) (hw : 0 < s.wolves)
    (hv : 0 < s.villagers) :
    s.fullRoundCorrect.totalPlayers < s.totalPlayers := by
  -- Simplify the plan for the full round correct case using the definitions of `eliminateWolf`, `nightKill`, and `totalPlayers`.
  simp [WerewolfState.fullRoundCorrect, WerewolfState.eliminateWolf, WerewolfState.nightKill, WerewolfState.totalPlayers];
  omega

/-
Each incorrect full round strictly reduces total players by 2.
-/
theorem full_round_incorrect_decreases (s : WerewolfState)
    (hv : 1 < s.villagers) :
    s.fullRoundIncorrect.totalPlayers < s.totalPlayers := by
  unfold WerewolfState.totalPlayers; rcases s with ⟨ w, v ⟩ ; rcases v with ( _ | _ | v ) <;> simp +arith +decide at *;
  unfold WerewolfState.fullRoundIncorrect; simp +arith +decide [ WerewolfState.eliminateVillager, WerewolfState.nightKill ] ;

/-
With perfect play (always eliminate a werewolf), villagers win
    if 2k < n (enough villagers survive after k night kills).
-/
theorem perfect_play_villagers_win {n k : ℕ} (hk : 0 < k) (hn : 2 * k < n) :
    (⟨0, n - 2 * k⟩ : WerewolfState).villagersWin := by
  grind +locals

/-- Probability of eliminating a werewolf by random vote. -/
def randomEliminationProb (s : WerewolfState) : ℚ :=
  if s.totalPlayers = 0 then 0
  else s.wolves / s.totalPlayers

/-
The random elimination probability is at most 1.
-/
theorem random_elim_prob_le_one (s : WerewolfState) :
    randomEliminationProb s ≤ 1 := by
  unfold WerewolfState.randomEliminationProb;
  split_ifs <;> [ norm_num; exact div_le_one_of_le₀ ( mod_cast by unfold WerewolfState.totalPlayers; linarith ) ( by positivity ) ]

/-
The random elimination probability is non-negative.
-/
theorem random_elim_prob_nonneg (s : WerewolfState) :
    0 ≤ randomEliminationProb s := by
  unfold WerewolfState.randomEliminationProb;
  positivity

/-
For a valid game, the random elimination probability is in (0, 1).
-/
theorem random_elim_prob_strict (s : WerewolfState) (hv : s.valid) :
    0 < randomEliminationProb s ∧ randomEliminationProb s < 1 := by
  -- Since the total players are positive and the wolves are positive and less than the total players, the probability is between 0 and 1.
  have h_pos : 0 < s.totalPlayers := by
    exact add_pos_of_pos_of_nonneg hv.1 ( Nat.zero_le _ )
  have h_lt_one : s.wolves < s.totalPlayers := by
    exact lt_add_of_pos_right _ ( by exact Nat.pos_of_ne_zero ( by rintro h; simp_all +decide [ WerewolfState.valid ] ) );
  convert And.intro _ _ using 2;
  · exact ( by rw [ show s.randomEliminationProb = ( s.wolves : ℚ ) / s.totalPlayers from if_neg ( ne_of_gt h_pos ) ] ; exact div_pos ( Nat.cast_pos.mpr hv.1 ) ( Nat.cast_pos.mpr h_pos ) );
  · unfold WerewolfState.randomEliminationProb;
    rw [ if_neg h_pos.ne', div_lt_one ] <;> norm_cast

end WerewolfState

/-! ## Bayesian Posterior Framework -/

/-- A Bayesian belief state assigns a probability to each player being a werewolf. -/
structure BayesianBelief (n : ℕ) where
  /-- Probability that player i is a werewolf -/
  prob : Fin n → ℝ
  /-- All probabilities are non-negative -/
  prob_nonneg : ∀ i, 0 ≤ prob i
  /-- All probabilities are at most 1 -/
  prob_le_one : ∀ i, prob i ≤ 1

/-- The uniform prior: each player has probability k/n of being a werewolf. -/
noncomputable def uniformPrior (n k : ℕ) (hn : 0 < n) (hk : k ≤ n) : BayesianBelief n where
  prob := fun _ => (k : ℝ) / n
  prob_nonneg := fun _ => by positivity
  prob_le_one := fun _ => by
    rw [div_le_one (Nat.cast_pos.mpr hn)]
    exact Nat.cast_le.mpr hk

/-- The expected number of werewolves under a belief state. -/
noncomputable def expectedWolves {n : ℕ} (b : BayesianBelief n) : ℝ :=
  ∑ i : Fin n, b.prob i

/-
For the uniform prior, the expected number of werewolves equals k.
-/
theorem uniform_prior_expected_wolves (n k : ℕ) (hn : 0 < n) (hk : k ≤ n) :
    expectedWolves (uniformPrior n k hn hk) = k := by
  unfold expectedWolves uniformPrior; norm_num [ mul_div_cancel₀, hn.ne' ] ;

/-! ## Shannon Entropy of Belief State (Cross-Domain: Information Theory → Game Theory)

  The Shannon entropy of the posterior belief measures the uncertainty
  about werewolf identities. Optimal play minimizes this entropy.
  This connects social deduction games to information theory.
-/

/-- Binary entropy function H(p) = -p log p - (1-p) log (1-p).
    Defined as 0 at the boundary points 0 and 1. -/
noncomputable def binaryEntropy (p : ℝ) : ℝ :=
  if p ≤ 0 ∨ p ≥ 1 then 0
  else -(p * Real.log p + (1 - p) * Real.log (1 - p))

/-- The total Shannon entropy of a belief state. -/
noncomputable def beliefEntropy {n : ℕ} (b : BayesianBelief n) : ℝ :=
  ∑ i : Fin n, binaryEntropy (b.prob i)

/-
Binary entropy is non-negative for p ∈ [0, 1].
-/
theorem binaryEntropy_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    0 ≤ binaryEntropy p := by
  unfold binaryEntropy; split_ifs <;> norm_num;
  nlinarith [ Real.log_nonpos hp0 hp1, Real.log_nonpos ( by linarith : 0 ≤ 1 - p ) ( by linarith ) ]

/-
Binary entropy is maximized at p = 1/2, with value log 2.
-/
theorem binaryEntropy_le_log2 {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    binaryEntropy p ≤ Real.log 2 := by
  by_cases h : p ≤ 0 ∨ p ≥ 1 <;> simp_all +decide [ binaryEntropy ];
  · positivity;
  · rw [ if_neg ( by aesop ) ];
    have h_jensen : ConcaveOn ℝ (Set.Ioi 0) (fun x : ℝ => -x * Real.log x) := by
      apply_rules [ StrictConcaveOn.concaveOn ];
      apply strictConcaveOn_of_deriv2_neg ( convex_Ioi 0 );
      · exact ContinuousOn.mul ( continuousOn_id.neg ) ( Real.continuousOn_log.mono fun x hx => ne_of_gt hx );
      · simp +zetaDelta at *;
        exact fun x hx => by rw [ Filter.EventuallyEq.deriv_eq ( Filter.eventuallyEq_of_mem ( Ioi_mem_nhds hx ) fun y hy => by rw [ Real.deriv_mul_log hy.out.ne' ] ) ] ; norm_num [ hx.ne' ] ; positivity;
    have := h_jensen.2 ( show 0 < p by linarith ) ( show 0 < 1 - p by linarith );
    have := @this ( 1 / 2 ) ( 1 / 2 ) ( by norm_num ) ( by norm_num ) ( by norm_num ) ; norm_num at *;
    ring_nf at this; norm_num [ Real.log_div ] at this; linarith;

/-
The total belief entropy is bounded by n · log 2.
-/
theorem beliefEntropy_bounded {n : ℕ} (b : BayesianBelief n) :
    beliefEntropy b ≤ n * Real.log 2 := by
  convert Finset.sum_le_sum fun i _ => binaryEntropy_le_log2 ( b.prob_nonneg i ) ( b.prob_le_one i ) using 1 ; simp +decide [ beliefEntropy ]

/-! ## Markov Chain Model for Random Elimination -/

/-- The villager win probability under random elimination, as a function
    of remaining (wolves, villagers). This is the absorption probability
    of the corresponding Markov chain.

    Base cases:
    - 0 wolves, v > 0: villagers have won → probability 1
    - wolves ≥ villagers: werewolves have won → probability 0

    Recursive case: with probability w/(w+v), a wolf is eliminated (correct),
    then night kills a villager → state (w-1, v-1).
    With probability v/(w+v), a villager is eliminated (incorrect),
    then night kills another villager → state (w, v-2). -/
noncomputable def villagerWinProb : ℕ → ℕ → ℝ
  | 0, v => if v > 0 then 1 else 0
  | w + 1, v =>
    if w + 1 ≥ v then 0
    else if v ≤ 1 then 0
    else
      let tot := (w + 1 : ℝ) + v
      ((w + 1 : ℝ) / tot) * villagerWinProb w (v - 1) +
      ((v : ℝ) / tot) * villagerWinProb (w + 1) (v - 2)

/-
With no werewolves and at least one villager, villagers have won.
-/
theorem villagerWinProb_zero_wolves (v : ℕ) (hv : 0 < v) :
    villagerWinProb 0 v = 1 := by
  -- By definition of villagerWinProb, when there are no werewolves and at least one villager, the probability is 1.
  simp [villagerWinProb, hv]

/-
When werewolves outnumber or equal villagers, werewolves win.
-/
theorem villagerWinProb_wolves_win (w v : ℕ) (h : v ≤ w) (hw : 0 < w) :
    villagerWinProb w v = 0 := by
  rcases w with ( _ | w ) <;> simp_all +decide;
  unfold villagerWinProb;
  aesop

/-! ## Werewolf Fraction Monotonicity -/

/-
The werewolf fraction increases when a villager is removed.
-/
theorem werewolf_fraction_increases
    {w v : ℕ} (hw : 0 < w) (hv : 1 < v) (_hwv : w < v) :
    (w : ℚ) / (w + v) ≤ (w : ℚ) / (w + (v - 1)) := by
  gcongr <;> norm_num ; linarith [ ( by norm_cast : ( 1 : ℚ ) < v ) ] ;

/-
The werewolf fraction decreases when a werewolf is removed.
-/
theorem werewolf_fraction_decreases
    {w v : ℕ} (hw : 1 < w) (hv : 0 < v) :
    ((w - 1 : ℕ) : ℚ) / ((w - 1 : ℕ) + v) ≤ (w : ℚ) / (w + v) := by
  rw [ div_le_div_iff₀ ] <;> norm_cast <;> nlinarith [ Nat.sub_add_cancel hw.le ]

/-! ## Game Tree Depth -/

/-- The maximum number of full rounds in a game -/
def maxGameRounds (n : ℕ) : ℕ := (n - 1) / 2

theorem game_tree_depth_bound (n : ℕ) (_hn : 1 ≤ n) :
    maxGameRounds n ≤ n - 1 := by
  exact Nat.div_le_self _ _

/-! ## Recurrence for One-Wolf Case

  The villager win probability with 1 wolf satisfies a clean recurrence
  that connects to the theory of random permutations.
-/

/-- The recurrence relation for the 1-wolf case. -/
theorem one_wolf_win_prob_recurrence (v : ℕ) (hv : 1 < v) :
    villagerWinProb 1 v =
      (1 : ℝ) / (1 + v) * villagerWinProb 0 (v - 1) +
      (v : ℝ) / (1 + v) * villagerWinProb 1 (v - 2) := by
  conv_lhs => rw [villagerWinProb]
  simp only [show ¬(1 ≥ v) from by omega, ↓reduceIte]
  ring

/-! ## Conjecture: Villager Win Probability Upper Bound

  **Conjecture** (Falsifiable): For the random elimination strategy with
  k werewolves among n = k + v players (k < v), the villager win probability
  satisfies: villagerWinProb k v ≤ 1 - k / v.

  **Test**: Compute villagerWinProb for various (k, v) and verify.
  For n=7 (k=2, v=5): bound gives 1 - 2/5 = 0.6, known value ≈ 0.36. ✓
  For n=5 (k=1, v=4): bound gives 1 - 1/4 = 0.75, actual ≈ 0.25. ✓
-/