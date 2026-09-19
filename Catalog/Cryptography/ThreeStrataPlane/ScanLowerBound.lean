import Cryptography.ThreeStrataPlane.StratumA

/-!
# Why the definition-route pays: a hitting-set lower bound on trial division

The exponent `1/2` of Stratum A is usually justified by "you have to divide by
everything up to `√N`".  That is an upper bound.  Here is the matching *lower*
bound, and it is a purely combinatorial fact about candidate sets, not an
assumption about algorithms.

Call `S` a **complete divisor-test set up to `B`** if, for every semiprime
`N = pq` with `p < q ≤ B`, some candidate in `S` splits `N`.  Then:

* `splitting_candidate_mem_pair` : a candidate that splits `pq` must *be* `p` or
  `q` — there is nothing else to find;
* `missing_primes_card_le_one` : consequently `S` can miss at most one prime
  `≤ B`;
* `complete_test_set_card_ge` : hence `|S| ≥ π(B) - 1`.

With `B ≈ √N` this is the price of structure-blindness in its sharpest form: a
method that learns nothing about `N` beyond "does `s` divide it?" must carry
essentially every prime below `√N` in its candidate list, whereas Pollard `ρ`
carries none.
-/

namespace ThreeStrata

open Finset

/-- The primes up to `B`, as a finite set. -/
def primesUpTo (B : ℕ) : Finset ℕ := (Finset.range (B + 1)).filter Nat.Prime

@[simp] theorem mem_primesUpTo {B n : ℕ} : n ∈ primesUpTo B ↔ n ≤ B ∧ n.Prime := by
  simp [primesUpTo]

/-- A candidate that properly splits a semiprime is one of its two prime
factors: the search space of trial division contains no shortcuts. -/
theorem splitting_candidate_mem_pair {p q s : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hs : s ∣ p * q) (hs1 : 1 < s) (hsN : s < p * q) : s = p ∨ s = q := by
  have hp0 : 0 < p := hp.pos
  have hq0 : 0 < q := hq.pos
  have hmem : s ∈ (p * q).divisors := Nat.mem_divisors.2 ⟨hs, by positivity⟩
  rw [divisors_semiprime hp hq] at hmem
  simp only [Finset.mem_insert, Finset.mem_singleton] at hmem
  rcases hmem with h | h | h | h
  · omega
  · exact Or.inl h
  · exact Or.inr h
  · omega

/-- `S` is a *complete divisor-test set up to `B`*: it splits every semiprime
built from two distinct primes `≤ B`. -/
def CompleteTestSet (S : Finset ℕ) (B : ℕ) : Prop :=
  ∀ p q : ℕ, p.Prime → q.Prime → p < q → q ≤ B →
    ∃ s ∈ S, s ∣ p * q ∧ 1 < s ∧ s < p * q

/-- A complete divisor-test set misses at most one prime below `B`. -/
theorem missing_primes_card_le_one {S : Finset ℕ} {B : ℕ} (h : CompleteTestSet S B) :
    (primesUpTo B \ S).card ≤ 1 := by
  refine Finset.card_le_one.2 ?_
  intro a ha b hb
  by_contra hne
  simp only [Finset.mem_sdiff, mem_primesUpTo] at ha hb
  obtain ⟨⟨haB, hap⟩, haS⟩ := ha
  obtain ⟨⟨hbB, hbp⟩, hbS⟩ := hb
  -- order the two missing primes
  rcases lt_or_gt_of_ne hne with hab | hab
  · obtain ⟨s, hsS, hsd, hs1, hsN⟩ := h a b hap hbp hab hbB
    rcases splitting_candidate_mem_pair hap hbp hsd hs1 hsN with rfl | rfl
    · exact haS hsS
    · exact hbS hsS
  · obtain ⟨s, hsS, hsd, hs1, hsN⟩ := h b a hbp hap hab haB
    rcases splitting_candidate_mem_pair hbp hap hsd hs1 hsN with rfl | rfl
    · exact hbS hsS
    · exact haS hsS

/-- **The hitting-set lower bound.**  A complete divisor-test set up to `B` has
at least `π(B) - 1` elements. -/
theorem complete_test_set_card_ge {S : Finset ℕ} {B : ℕ} (h : CompleteTestSet S B) :
    (primesUpTo B).card ≤ S.card + 1 := by
  have hsplit : (primesUpTo B).card ≤ (primesUpTo B ∩ S).card + (primesUpTo B \ S).card := by
    rw [Finset.card_inter_add_card_sdiff]
  have h1 : (primesUpTo B ∩ S).card ≤ S.card :=
    Finset.card_le_card Finset.inter_subset_right
  have h2 := missing_primes_card_le_one h
  omega

/-- **Corollary: no bounded candidate list works.**  If a single finite set `S`
were a complete divisor-test set for every bound `B`, the number of primes would
be bounded by `|S| + 1`; since there are infinitely many primes, no such `S`
exists.  Structure-blind trial division has no finite universal candidate list. -/
theorem no_universal_test_set (S : Finset ℕ) : ∃ B : ℕ, ¬ CompleteTestSet S B := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨T, hTsub, hTcard⟩ :=
    Nat.infinite_setOf_prime.exists_subset_card_eq (S.card + 2)
  set B : ℕ := T.sup id with hB
  have hTsubset : T ⊆ primesUpTo B := by
    intro n hn
    refine mem_primesUpTo.2 ⟨Finset.le_sup (f := id) hn, hTsub hn⟩
  have h1 : T.card ≤ (primesUpTo B).card := Finset.card_le_card hTsubset
  have h2 : (primesUpTo B).card ≤ S.card + 1 := complete_test_set_card_ge (hcon B)
  omega

/-! ## A quantitative version via Bertrand's postulate -/

/-- Bertrand's postulate gives a prime in each dyadic interval `(2^i, 2^{i+1}]`,
hence at least `k` primes below `2^k`. -/
theorem card_primesUpTo_two_pow_ge (k : ℕ) : k ≤ (primesUpTo (2 ^ k)).card := by
  have H : ∀ i : ℕ, ∃ r : ℕ, r.Prime ∧ 2 ^ i < r ∧ r ≤ 2 ^ (i + 1) := by
    intro i
    obtain ⟨r, hr, h1, h2⟩ := Nat.exists_prime_lt_and_le_two_mul (2 ^ i) (by positivity)
    exact ⟨r, hr, h1, by simpa [pow_succ, two_mul, mul_comm] using h2⟩
  choose f hfp hflt hfle using H
  have hmono : ∀ i j : ℕ, i < j → f i < f j := by
    intro i j hij
    calc f i ≤ 2 ^ (i + 1) := hfle i
      _ ≤ 2 ^ j := Nat.pow_le_pow_right (by norm_num) hij
      _ < f j := hflt j
  have hmaps : Set.MapsTo f (Finset.range k : Finset ℕ) (primesUpTo (2 ^ k)) := by
    intro i hi
    simp only [Finset.coe_range, Set.mem_Iio] at hi
    refine Finset.mem_coe.2 (mem_primesUpTo.2 ⟨?_, hfp i⟩)
    exact le_trans (hfle i) (Nat.pow_le_pow_right (by norm_num) hi)
  have hinj : Set.InjOn f (Finset.range k : Finset ℕ) := by
    intro i _ j _ hij
    by_contra hne
    rcases lt_or_gt_of_ne hne with h | h
    · exact absurd hij (hmono i j h).ne
    · exact absurd hij.symm (hmono j i h).ne
  simpa using Finset.card_le_card_of_injOn f hmaps hinj

/-- **The candidate list grows at least linearly in the bit-size.**  A complete
divisor-test set up to `2^k` must contain at least `k - 1` candidates; taking
`2^k ≈ √N` this says the structure-blind route carries a candidate list growing
at least linearly in `log N`, while Pollard `ρ` carries none. -/
theorem complete_test_set_card_ge_bits {S : Finset ℕ} {k : ℕ}
    (h : CompleteTestSet S (2 ^ k)) : k ≤ S.card + 1 :=
  le_trans (card_primesUpTo_two_pow_ge k) (complete_test_set_card_ge h)

end ThreeStrata