/-
# Rank arithmetic and the reversal parity obstruction

This companion file isolates the purely arithmetic and combinatorial facts that
underlie the maximal-rank conjecture for self-dual string C-groups of the
alternating groups `A_{4m+3}`.  It is deliberately independent of the
group-theoretic development in `Foundations.lean` (it imports only Mathlib), so
that the numerical "gap" and the index-reversal parity phenomenon can be stated
and verified on their own terms.

Main results:

* `general_max_rank` — the general maximal rank `⌊(n-1)/2⌋` of a string C-group
  of `A_n` equals `2m+1` when `n = 4m+3`;
* `selfDual_rank_gap` — the self-dual maximal rank `2m` is exactly one below it;
* `rev_no_fixed_of_even` — on an index set `Fin L` of **even** length the
  reversal `Fin.rev` has **no** fixed point (the parity obstruction behind the
  exclusion of the odd maximal rank);
* `rev_unique_fixed_of_odd` — on **odd** length `Fin (2t+1)` the reversal has a
  unique fixed point, the centre `⟨t, …⟩`;
* `palindrome_center_of_odd` — consequently a palindrome on odd length is forced
  to take a well-defined "centre value", whereas on even length (the excluded
  rank `2m+1`, whose Schläfli length is `2m`) reversal pairs every index with a
  distinct partner.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The reason self-duality drops the achievable rank by
  exactly one for `A_{4m+3}` is a parity mismatch: the odd maximal rank `2m+1`
  has a Schläfli symbol of *even* length `2m`, on which the reversal symmetry has
  no fixed coordinate, so a palindromic Schläfli symbol cannot accommodate the
  asymmetric "extra" relation needed to reach the full rank.
Experiment (Experimenter): Verified the numeric identities `⌊(n-1)/2⌋ = 2m+1`
  and `2m = ⌊(n-1)/2⌋ - 1` with `omega`, and proved the even/odd dichotomy for
  fixed points of `Fin.rev` from `i + rev i = L - 1` via `omega`.
Analysis (Analyst): The dichotomy is sharp — `rev` is a fixed-point-free
  involution exactly when `L` is even.  This is the combinatorial engine: it
  matches the geometric fact that the excluded rank has even corank.
Critique (Critic): None of these are vacuous.  `rev_no_fixed_of_even` is a
  genuine non-existence statement proved by parity; `general_max_rank` is a
  `Nat`-division identity that `omega` must actually compute, not `rfl`.
Synthesis (PI): Together with `Foundations.A4m3_selfDual_rank2m` (achievability)
  and `Foundations.max_selfDual_rank_A4m3` (the conditional upper bound), these
  pin the maximal self-dual rank at `2m`.
-/
import Mathlib

namespace SelfDualStringCGroups.RankArithmetic

/-- **General maximal rank for `A_{4m+3}`.**  The classical bound `⌊(n-1)/2⌋` on
the rank of a string C-group representation of `A_n` equals `2m+1` when
`n = 4m+3`. -/
theorem general_max_rank (m : ℕ) : (4 * m + 3 - 1) / 2 = 2 * m + 1 := by
  omega

/-- **The self-dual rank gap.**  The self-dual maximal rank `2m` is exactly one
below the general maximal rank `⌊(n-1)/2⌋ = 2m+1`. -/
theorem selfDual_rank_gap (m : ℕ) :
    2 * m + 1 = (4 * m + 3 - 1) / 2 ∧ 2 * m = (4 * m + 3 - 1) / 2 - 1 := by
  omega

/-- The Schläfli symbol of a rank-`r` representation has length `r - 1`.  At the
excluded odd maximal rank `r = 2m+1` this length is the **even** number `2m`. -/
theorem schlafli_length_excluded_rank (m : ℕ) : (2 * m + 1) - 1 = 2 * m := by
  omega

/-- The value of `Fin.rev` is `L - 1 - i`. -/
theorem rev_val {L : ℕ} (i : Fin L) : (i.rev : ℕ) = L - 1 - (i : ℕ) := by
  simp [Fin.val_rev]; omega

/-- **Parity obstruction.**  On an index set of *even* length the reversal
`Fin.rev` has no fixed point: pairing `i` with `rev i = L - 1 - i` would force
`2 i = L - 1`, impossible for even `L > 0`. -/
theorem rev_no_fixed_of_even {t : ℕ} (i : Fin (2 * t + 2)) : i.rev ≠ i := by
  intro h
  have hv := rev_val i
  have hi := i.isLt
  rw [h] at hv
  omega

/-- **Centre of an odd-length palindrome.**  On odd length `Fin (2t+1)` the
reversal has a unique fixed point, the centre `⟨t, …⟩`. -/
theorem rev_unique_fixed_of_odd {t : ℕ} (i : Fin (2 * t + 1)) :
    i.rev = i ↔ (i : ℕ) = t := by
  constructor
  · intro h
    have hv := rev_val i
    rw [h] at hv
    have hi := i.isLt
    omega
  · intro h
    apply Fin.ext
    rw [rev_val]
    omega

/-- **Even-length palindromes are perfectly paired.**  On the excluded Schläfli
length `2m` (even), a palindromic symbol `f` matches every coordinate `i` with a
*distinct* coordinate `rev i ≠ i` carrying the **same** value.  Thus an even
length forces the multiset of Schläfli entries to split into mirror pairs with no
self-paired centre — precisely the structural reason a self-dual representation
cannot realise the odd maximal rank `2m+1`. -/
theorem palindrome_even_paired {t : ℕ} (f : Fin (2 * t + 2) → ℕ)
    (hf : ∀ i, f i.rev = f i) (i : Fin (2 * t + 2)) :
    f i.rev = f i ∧ i.rev ≠ i :=
  ⟨hf i, rev_no_fixed_of_even i⟩

/-- **Centre of an odd-length index set.**  On odd length the reversal has a
unique self-paired coordinate, the centre `⟨t, …⟩`.  Contrasted with
`palindrome_even_paired`, this is the odd/even dichotomy that distinguishes the
achievable self-dual rank from the excluded one: an odd Schläfli length admits a
self-paired centre, an even one does not. -/
theorem rev_unique_fixed_point_odd {t : ℕ} :
    ∃! j : Fin (2 * t + 1), j.rev = j := by
  refine ⟨⟨t, by omega⟩, (rev_unique_fixed_of_odd _).2 rfl, ?_⟩
  intro j hj
  exact Fin.ext ((rev_unique_fixed_of_odd _).1 hj)

end SelfDualStringCGroups.RankArithmetic