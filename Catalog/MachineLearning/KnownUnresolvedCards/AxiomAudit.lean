/-
Audit file: prints the axiom dependencies of the main theorems of the
`KnownUnresolvedCards` development.  Every theorem must depend only on
`propext`, `Classical.choice` and `Quot.sound`.
-/

import MachineLearning.KnownUnresolvedCards.DeckGame
import MachineLearning.KnownUnresolvedCards.FeedbackGame
import MachineLearning.KnownUnresolvedCards.NoFreeLunch
import MachineLearning.KnownUnresolvedCards.BettingSystem

namespace KnownUnresolvedCards

#print axioms expected_total_eq_certain_sum
#print axioms expected_total_eq_certain_count
#print axioms no_fair_portfolio_edge
#print axioms card_fiber_mul
#print axioms card_fiber₂_mul
#print axioms sum_hits_eq_card_perm
#print axioms sum_hits_sq_eq_two_mul
#print axioms sum_hits_sq_collision
#print axioms Var_hits_collision
#print axioms E_slotScore
#print axioms expected_deckScore
#print axioms fair_odds_iff
#print axioms expected_gamePayoff_eq_known
#print axioms expected_unit_score_eq_known_add_one
#print axioms mean_invariant_variance_not
#print axioms expScore_fair_eq_zero
#print axioms expScore_hits_eq_harmonic
#print axioms harmonic_two_pow_ge
#print axioms feedback_edge_unbounded
#print axioms feedback_strictly_beats_blind
#print axioms no_free_lunch_expected_score
#print axioms expected_correct_count
#print axioms no_free_lunch_kary_expected_score
#print axioms expGain_eq_zero
#print axioms doubling_paradox

end KnownUnresolvedCards