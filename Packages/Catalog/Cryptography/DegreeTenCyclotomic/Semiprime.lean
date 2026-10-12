import Cryptography.DegreeTenCyclotomic.Channel

/-!
# The degree-ten semiprime channel

For `N = pq` with independent uniform Frobenius classes:

* `semi_channel` — `I(N mod 11 ; {T(p),T(q)}) = log₂ 5 + (12/25) log₂ 3 − 47/25 ≈ 1.2027`
  (this is the paper-78 closed-form anchor).
* `semi_channel_ordered`, `semi_which_factor_wall` — the ordered pair gives exactly the same
  value: the which-factor wall is `0` at degree ten.
-/

namespace DegreeTen

open TypeChannel Finset Real

set_option maxRecDepth 4000000
set_option maxHeartbeats 4000000

/-- Residue of the semiprime `N = pq` modulo 11. -/
def semiN (q : U11 × U11) : ℕ := resid (q.1 * q.2)

/-- The unordered pair of Frobenius types of the two prime factors. -/
def semiPair (q : U11 × U11) : ℕ × ℕ :=
  (min (frobType q.1) (frobType q.2), max (frobType q.1) (frobType q.2))

/-- The ordered pair of Frobenius types. -/
def semiOrd (q : U11 × U11) : ℕ × ℕ := (frobType q.1, frobType q.2)

/-- The semiprime sample space: independent uniform Frobenius classes of `p` and `q`. -/
abbrev SP : Finset (U11 × U11) := univ ×ˢ univ

lemma SP_card : SP.card = 100 := by decide

lemma neg_term_100 (c : ℝ) (hc : 0 < c) :
    -((c / 100) * logb 2 (c / 100)) = c / 100 * (2 + 2 * logb 2 5 - logb 2 c) := by
  rw [neg_prob_logb_real c 100 hc (by norm_num), logb2_hundred]


theorem semi_entropy_N : entropy SP semiN = 1 + logb 2 5 := by
  rw [entropy_eq_sumList (A := [1,2,3,4,5,6,7,8,9,10]) (L := [10,10,10,10,10,10,10,10,10,10])
    (by decide) (by decide) (by decide), SP_card]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat]
  rw [neg_term_100 10 (by norm_num), logb2_five_ten]
  ring

theorem semi_entropy_pair : entropy SP semiPair = 2 * logb 2 5 - 93/50 := by
  rw [entropy_eq_sumList
    (A := [(1, 1), (1, 2), (1, 5), (1, 10), (2, 2), (2, 5), (2, 10), (5, 5), (5, 10), (10, 10)])
    (L := [1, 2, 8, 8, 1, 8, 8, 16, 32, 16]) (by decide) (by decide) (by decide), SP_card]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_term_100 1 (by norm_num), neg_term_100 2 (by norm_num), neg_term_100 8 (by norm_num),
    neg_term_100 16 (by norm_num), neg_term_100 32 (by norm_num)]
  rw [logb2_two, logb2_eight, logb2_sixteen, logb2_thirtytwo, Real.logb_one]
  ring

theorem semi_entropy_joint :
    entropy SP (pairObs semiN semiPair) = 2 * logb 2 5 + 51/50 - 12/25 * logb 2 3 := by
  rw [entropy_eq_sumList
    (A := [(1, (1, 1)), (1, (2, 2)), (1, (5, 5)), (1, (10, 10)), (2, (1, 10)), (2, (2, 5)),
      (2, (5, 10)), (3, (1, 5)), (3, (2, 10)), (3, (5, 5)), (3, (10, 10)), (4, (1, 5)),
      (4, (2, 10)), (4, (5, 5)), (4, (10, 10)), (5, (1, 5)), (5, (2, 10)), (5, (5, 5)),
      (5, (10, 10)), (6, (1, 10)), (6, (2, 5)), (6, (5, 10)), (7, (1, 10)), (7, (2, 5)),
      (7, (5, 10)), (8, (1, 10)), (8, (2, 5)), (8, (5, 10)), (9, (1, 5)), (9, (2, 10)),
      (9, (5, 5)), (9, (10, 10)), (10, (1, 2)), (10, (5, 10))])
    (L := [1, 1, 4, 4, 2, 2, 6, 2, 2, 3, 3, 2, 2, 3, 3, 2, 2, 3, 3, 2, 2, 6, 2, 2, 6, 2, 2, 6, 2,
      2, 3, 3, 2, 8]) (by decide) (by decide) (by decide), SP_card]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_term_100 1 (by norm_num), neg_term_100 2 (by norm_num), neg_term_100 3 (by norm_num),
    neg_term_100 4 (by norm_num), neg_term_100 6 (by norm_num), neg_term_100 8 (by norm_num)]
  rw [logb2_two, logb2_four, logb2_six, logb2_eight, Real.logb_one]
  ring

/-- **The degree-ten semiprime channel, exact closed form** (the paper-78 anchor):
`I(N mod 11 ; {T(p), T(q)}) = log₂ 5 + (12/25) log₂ 3 − 47/25 ≈ 1.2027` bits. -/
theorem semi_channel :
    mutualInfo SP semiN semiPair = logb 2 5 + 12/25 * logb 2 3 - 47/25 := by
  rw [mutualInfo, semi_entropy_N, semi_entropy_pair, semi_entropy_joint]
  ring

theorem semi_entropy_ord : entropy SP semiOrd = 2 * logb 2 5 - 6/5 := by
  rw [entropy_eq_sumList
    (A := [(1, 1), (1, 2), (1, 5), (1, 10), (2, 1), (2, 2), (2, 5), (2, 10), (5, 1), (5, 2),
      (5, 5), (5, 10), (10, 1), (10, 2), (10, 5), (10, 10)])
    (L := [1, 1, 4, 4, 1, 1, 4, 4, 4, 4, 16, 16, 4, 4, 16, 16]) (by decide) (by decide)
    (by decide), SP_card]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_term_100 1 (by norm_num), neg_term_100 4 (by norm_num), neg_term_100 16 (by norm_num)]
  rw [logb2_four, logb2_sixteen, Real.logb_one]
  ring

theorem semi_entropy_ordJoint :
    entropy SP (pairObs semiN semiOrd) = 2 * logb 2 5 + 42/25 - 12/25 * logb 2 3 := by
  rw [entropy_eq_sumList
    (A := [(1, (1, 1)), (1, (2, 2)), (1, (5, 5)), (1, (10, 10)), (2, (1, 10)), (2, (2, 5)),
      (2, (5, 2)), (2, (5, 10)), (2, (10, 1)), (2, (10, 5)), (3, (1, 5)), (3, (2, 10)),
      (3, (5, 1)), (3, (5, 5)), (3, (10, 2)), (3, (10, 10)), (4, (1, 5)), (4, (2, 10)),
      (4, (5, 1)), (4, (5, 5)), (4, (10, 2)), (4, (10, 10)), (5, (1, 5)), (5, (2, 10)),
      (5, (5, 1)), (5, (5, 5)), (5, (10, 2)), (5, (10, 10)), (6, (1, 10)), (6, (2, 5)),
      (6, (5, 2)), (6, (5, 10)), (6, (10, 1)), (6, (10, 5)), (7, (1, 10)), (7, (2, 5)),
      (7, (5, 2)), (7, (5, 10)), (7, (10, 1)), (7, (10, 5)), (8, (1, 10)), (8, (2, 5)),
      (8, (5, 2)), (8, (5, 10)), (8, (10, 1)), (8, (10, 5)), (9, (1, 5)), (9, (2, 10)),
      (9, (5, 1)), (9, (5, 5)), (9, (10, 2)), (9, (10, 10)), (10, (1, 2)), (10, (2, 1)),
      (10, (5, 10)), (10, (10, 5))])
    (L := [1, 1, 4, 4, 1, 1, 1, 3, 1, 3, 1, 1, 1, 3, 1, 3, 1, 1, 1, 3, 1, 3, 1, 1, 1, 3, 1, 3,
      1, 1, 1, 3, 1, 3, 1, 1, 1, 3, 1, 3, 1, 1, 1, 3, 1, 3, 1, 1, 1, 3, 1, 3, 1, 1, 4, 4])
    (by decide) (by decide) (by decide), SP_card]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_term_100 1 (by norm_num), neg_term_100 3 (by norm_num), neg_term_100 4 (by norm_num)]
  rw [logb2_four, Real.logb_one]
  ring

theorem semi_channel_ordered :
    mutualInfo SP semiN semiOrd = logb 2 5 + 12/25 * logb 2 3 - 47/25 := by
  rw [mutualInfo, semi_entropy_N, semi_entropy_ord, semi_entropy_ordJoint]
  ring

/-- **The which-factor wall vanishes at degree ten**: knowing which prime carried which
type adds exactly nothing about `N mod 11`. -/
theorem semi_which_factor_wall :
    mutualInfo SP semiN semiOrd = mutualInfo SP semiN semiPair := by
  rw [semi_channel, semi_channel_ordered]

end DegreeTen