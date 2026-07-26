import Mathlib

/-!
# Gödel's Casino: sharp Bayesian and minimax laws

This file deepens the finite Boolean casino model.  A Bayesian card has a rational
probability `q` of being true.  We identify the optimal deterministic bet on every
card and prove the exact value of the whole deck: the sum of the absolute biases
`|2q-1|`.  Thus independence of a statement from a formal theory alone supplies
no edge; an edge is exactly probabilistic bias away from one half.

The second part allows a player to randomize among finitely many deterministic
strategies.  Complementing a world negates the mixed payoff, proving a finite
minimax/no-free-lunch theorem: every mixed strategy has a world with nonpositive
expected payoff.  No positivity or normalization assumption on the mixing weights
is needed for this obstruction.
-/

namespace GodelCasinoDeepening

/-- Unit payoff for predicting a Boolean truth value. -/
def unitPayoff (prediction truth : Bool) : ℤ :=
  if prediction = truth then 1 else -1

/-- Total unit-stake payoff on a finite deck. -/
def totalPayoff {n : ℕ} (strategy truth : Fin n → Bool) : ℤ :=
  ∑ i, unitPayoff (strategy i) (truth i)

/-- The world obtained by reversing every truth value. -/
def complementWorld {n : ℕ} (truth : Fin n → Bool) : Fin n → Bool :=
  fun i => !(truth i)

/-- Expected contribution of one card whose probability of truth is `q`. -/
def cardExpectedPayoff (q : ℚ) (prediction : Bool) : ℚ :=
  if prediction then 2 * q - 1 else 1 - 2 * q

/-- Expected payoff of a deterministic strategy from the cards' truth marginals. -/
def bayesianPayoff {n : ℕ} (q : Fin n → ℚ) (strategy : Fin n → Bool) : ℚ :=
  ∑ i, cardExpectedPayoff (q i) (strategy i)

/-- Bet true precisely when truth has probability at least one half. -/
def bayesStrategy {n : ℕ} (q : Fin n → ℚ) : Fin n → Bool :=
  fun i => decide ((1 : ℚ) / 2 ≤ q i)

/-
The Bayes bet realizes the absolute bias on each individual card.
-/
lemma cardExpectedPayoff_bayes (q : ℚ) :
    cardExpectedPayoff q (decide ((1 : ℚ) / 2 ≤ q)) = |2 * q - 1| := by
  unfold cardExpectedPayoff;
  grind

/-
No deterministic prediction beats the absolute bias available on one card.
-/
lemma cardExpectedPayoff_le_abs (q : ℚ) (prediction : Bool) :
    cardExpectedPayoff q prediction ≤ |2 * q - 1| := by
  unfold cardExpectedPayoff;
  grind

/-
**Exact Bayesian value theorem.**  Optimal expected deck profit is the sum of
absolute marginal biases.
-/
theorem bayesStrategy_exact {n : ℕ} (q : Fin n → ℚ) :
    bayesianPayoff q (bayesStrategy q) = ∑ i, |2 * q i - 1| := by
  convert Finset.sum_congr rfl fun i _ => cardExpectedPayoff_bayes ( q i )

/-
The Bayes strategy dominates every deterministic strategy.
-/
theorem bayesStrategy_optimal {n : ℕ} (q : Fin n → ℚ)
    (strategy : Fin n → Bool) :
    bayesianPayoff q strategy ≤ bayesianPayoff q (bayesStrategy q) := by
  rw [ bayesStrategy_exact, bayesianPayoff ];
  exact Finset.sum_le_sum fun i _ => cardExpectedPayoff_le_abs _ _

/-
The casino has zero Bayesian value exactly when every card is fair.
-/
theorem bayesian_value_eq_zero_iff {n : ℕ} (q : Fin n → ℚ) :
    bayesianPayoff q (bayesStrategy q) = 0 ↔ ∀ i, q i = 1 / 2 := by
  constructor <;> intro h;
  · rw [ bayesStrategy_exact ] at h;
    exact fun i => by linarith [ abs_eq_zero.mp ( Finset.sum_eq_zero_iff_of_nonneg ( fun _ _ => abs_nonneg _ ) |>.1 h i ( Finset.mem_univ i ) ) ] ;
  · convert bayesStrategy_exact q;
    norm_num [ h ]

/-
A deck has a strictly positive optimal edge exactly when at least one card is
biased away from one half.
-/
theorem bayesian_value_pos_iff {n : ℕ} (q : Fin n → ℚ) :
    0 < bayesianPayoff q (bayesStrategy q) ↔ ∃ i, q i ≠ 1 / 2 := by
  constructor <;> intro h;
  · exact not_forall.mp fun h' => h.ne' <| by simpa [ h' ] using bayesian_value_eq_zero_iff q;
  · exact lt_of_not_ge fun h' => h.elim fun i hi => hi <| bayesian_value_eq_zero_iff q |>.1 ( le_antisymm h' <| bayesStrategy_exact q ▸ Finset.sum_nonneg fun _ _ => abs_nonneg _ ) i

/-
Exact one-card regret: disagreeing with the Bayes prediction costs twice the
available absolute bias, while agreeing costs nothing.
-/
lemma cardExpectedPayoff_regret (q : ℚ) (prediction : Bool) :
    cardExpectedPayoff q (decide ((1 : ℚ) / 2 ≤ q)) -
        cardExpectedPayoff q prediction =
      if prediction = decide ((1 : ℚ) / 2 ≤ q) then 0 else 2 * |2 * q - 1| := by
  split_ifs <;> cases prediction <;> simp_all +decide [ cardExpectedPayoff ];
  · grind +qlia;
  · grind;
  · grind

/-
**Exact regret decomposition.**  The loss against the optimal strategy is the
sum of twice the biases precisely on the cards where the player's bet differs.
-/
theorem bayesian_regret_exact {n : ℕ} (q : Fin n → ℚ)
    (strategy : Fin n → Bool) :
    bayesianPayoff q (bayesStrategy q) - bayesianPayoff q strategy =
      ∑ i, if strategy i = bayesStrategy q i then 0 else 2 * |2 * q i - 1| := by
  convert Finset.sum_congr rfl fun i _ => cardExpectedPayoff_regret ( q i ) ( strategy i ) using 1;
  unfold bayesianPayoff; rw [ Finset.sum_sub_distrib ] ;
  rfl

/-
On a deck with no fair cards, the Bayes strategy is uniquely optimal.
-/
theorem bayesStrategy_unique_of_no_ties {n : ℕ} (q : Fin n → ℚ)
    (hbiased : ∀ i, q i ≠ 1 / 2) (strategy : Fin n → Bool)
    (hoptimal : bayesianPayoff q strategy = bayesianPayoff q (bayesStrategy q)) :
    strategy = bayesStrategy q := by
  contrapose! hoptimal;
  obtain ⟨ i, hi ⟩ := Function.ne_iff.mp hoptimal;
  refine' ne_of_lt ( lt_of_sub_pos _ );
  rw [ bayesian_regret_exact ];
  exact lt_of_lt_of_le ( by norm_num [ hi ] ; cases abs_cases ( 2 * q i - 1 ) <;> cases lt_or_gt_of_ne ( hbiased i ) <;> linarith ) ( Finset.single_le_sum ( fun i _ => by positivity ) ( Finset.mem_univ i ) )

/-- A concrete five-card calculation used as a small computational check. -/
example : bayesianPayoff
    (fun i : Fin 5 => ![(1 : ℚ) / 2, 2 / 3, 1 / 4, 9 / 10, 0] i)
    (bayesStrategy (fun i : Fin 5 => ![(1 : ℚ) / 2, 2 / 3, 1 / 4, 9 / 10, 0] i))
    = 79 / 30 := by
  norm_num [bayesianPayoff, bayesStrategy, cardExpectedPayoff, Fin.sum_univ_succ]

/-- Weighted payoff of a finite mixture of deterministic strategies in one world.
The weights may in particular be probabilities summing to one. -/
def mixedPayoff {m n : ℕ} (weight : Fin m → ℚ)
    (strategy : Fin m → Fin n → Bool) (truth : Fin n → Bool) : ℚ :=
  ∑ j, weight j * totalPayoff (strategy j) truth

/-
Complementing the world reverses the payoff of every mixed strategy.
-/
theorem mixedPayoff_complement {m n : ℕ} (weight : Fin m → ℚ)
    (strategy : Fin m → Fin n → Bool) (truth : Fin n → Bool) :
    mixedPayoff weight strategy (complementWorld truth) =
      -mixedPayoff weight strategy truth := by
  unfold mixedPayoff;
  simp +decide [ totalPayoff, complementWorld, unitPayoff ];
  rw [ ← Finset.sum_neg_distrib, Finset.sum_congr rfl ] ; intros ; rw [ Finset.mul_sum ] ; rw [ Finset.mul_sum ] ; rw [ ← Finset.sum_neg_distrib ] ; congr ; ext ; aesop;

/-
**Mixed minimax/no-free-lunch theorem.**  For every finite randomized player,
there is a possible world where its expected payoff is nonpositive.
-/
theorem mixedStrategy_exists_nonpositive_world {m n : ℕ} (weight : Fin m → ℚ)
    (strategy : Fin m → Fin n → Bool) :
    ∃ truth : Fin n → Bool, mixedPayoff weight strategy truth ≤ 0 := by
  by_contra h;
  -- Choose an arbitrary world, e.g. all true. By mixedPayoff_complement its complement payoff is the negation.
  obtain ⟨truth, htruth⟩ : ∃ truth : Fin n → Bool, True := by
    exact ⟨ fun _ => Bool.true, trivial ⟩;
  exact h ⟨ complementWorld truth, by linarith [ mixedPayoff_complement weight strategy truth, not_le.mp fun h' => h ⟨ truth, h' ⟩ ] ⟩

/-
Consequently no finite mixed strategy can guarantee a strict win in every
possible truth assignment.
-/
theorem no_mixed_uniform_strict_win {m n : ℕ} (weight : Fin m → ℚ)
    (strategy : Fin m → Fin n → Bool) :
    ¬ ∀ truth : Fin n → Bool, 0 < mixedPayoff weight strategy truth := by
  convert @mixedStrategy_exists_nonpositive_world m n weight strategy using 1;
  grind +splitImp

end GodelCasinoDeepening