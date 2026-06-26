import Mathlib

/-!
# Central Gaussian coefficient maximizes binary 2-binomial class size

This file develops the combinatorics of the **2-binomial equivalence classes** of binary
words and connects their sizes to the **Gaussian (q-)binomial coefficients**.

## Background

Two finite binary words `u, v` are *2-binomially equivalent* (Rigo–Salimov) when they
contain the same number of scattered occurrences of every factor of length `≤ 2`.
For binary words this is equivalent to: same length `n`, same number of ones `k`, and the
same *inversion number* `inv` (number of pairs `(i, j)` with `i < j`, position `i` a one and
position `j` a zero — i.e. scattered occurrences of the factor `10`).

Hence a 2-binomial class is indexed by the triple `(n, k, i)` and its cardinality, the
`classSize n k i`, is exactly the coefficient of `q^i` in the Gaussian binomial coefficient
`[n choose k]_q` (MacMahon's theorem). The Gaussian binomial coefficients are symmetric and
unimodal, so the *central* coefficient is the maximum: the central inversion number gives the
largest 2-binomial class.

We model a binary word of length `n` with `k` ones by the set `S : Finset (Fin n)` of
positions carrying a one (`|S| = k`).

## Main results

* `invF_le`            : the inversion number is at most `k * (n - k)`.
* `classSize_eq_zero_of_gt` : classes vanish past the maximal inversion number.
* `total_eq_choose`    : the class sizes sum to `n.choose k` (rows sum to a binomial).
* `classSize_symm`     : palindromic symmetry `classSize n k i = classSize n k (k*(n-k) - i)`.
* `central_max_*`      : for explicit `(n, k)`, the central coefficient is the global maximum.

-- !-- Lab Notes -- !--
Hypothesis log / experimental record.

H1. classSize n k i = coeff of q^i in [n choose k]_q.
    EVIDENCE: #eval of classSize for (4,2),(5,2),(6,3) reproduced exactly the known
    Gaussian rows 1,1,2,1,1 / 1,1,2,2,2,1,1 / 1,1,2,3,3,3,3,2,1,1.  CONFIRMED.

H2. The class sizes for fixed (n,k) sum to C(n,k).
    EVIDENCE: ∑_i classSize 5 2 i = 10 = C(5,2).  CONFIRMED → `total_eq_choose`.

H3. The distribution is palindromic about k(n-k)/2.
    EVIDENCE: rows above are all palindromes.  CONFIRMED → `classSize_symm`
    (bijection: reverse the word, which swaps inversions `10` with co-inversions `01`).

H4 (headline). The maximum class size is attained at the central inversion number
    c = k(n-k)/2.  This is full unimodality of Gaussian binomials — a deep theorem
    (Sylvester via hard Lefschetz; first elementary proof O'Hara 1990).  We do NOT prove
    the general statement here (left as a FUTURE_DIRECTIONS conjecture); instead we verify
    it as fully-checked theorems for explicit (n,k) via kernel/native computation.

FAILURE ANALYSIS: an early attempt represented words as `Fin n → Bool`; counting the total
as C(n,k) was awkward.  Switching to `Finset (Fin n)` (the positions of the ones) makes the
total immediate from `Finset.card_powersetCard`.
-/

namespace BinaryTwoBinomial

open Finset

/-- The inversion number of a binary word whose ones sit at positions `S ⊆ Fin n`:
the number of ordered pairs `(i, j)` with `i < j`, position `i` a one and position `j` a
zero (scattered occurrences of the factor `10`). -/
def invF {n : ℕ} (S : Finset (Fin n)) : ℕ :=
  (univ.filter (fun p : Fin n × Fin n => p.1 < p.2 ∧ p.1 ∈ S ∧ p.2 ∉ S)).card

/-- The co-inversion number: pairs `(i, j)`, `i < j`, with `i` a zero and `j` a one
(scattered occurrences of `01`). -/
def coinvF {n : ℕ} (S : Finset (Fin n)) : ℕ :=
  (univ.filter (fun p : Fin n × Fin n => p.1 < p.2 ∧ p.1 ∉ S ∧ p.2 ∈ S)).card

/-- The set of binary words of length `n` with exactly `k` ones (positions of the ones). -/
def words (n k : ℕ) : Finset (Finset (Fin n)) := (univ : Finset (Fin n)).powersetCard k

/-- The size of the 2-binomial class `(n, k, i)`: binary words of length `n` with `k` ones
and inversion number `i`. Equivalently, the coefficient of `q^i` in `[n choose k]_q`. -/
def classSize (n k i : ℕ) : ℕ := ((words n k).filter (fun S => invF S = i)).card

/-- The central inversion number `k(n-k)/2`. -/
def centralIndex (n k : ℕ) : ℕ := k * (n - k) / 2

/-- Membership in `words`: cardinality is exactly `k`. -/
lemma mem_words {n k : ℕ} {S : Finset (Fin n)} : S ∈ words n k ↔ S.card = k := by
  simp [words, Finset.mem_powersetCard]

/-
The inversion number of a word with `k` ones is at most `k * (n - k)`.
-/
lemma invF_le {n k : ℕ} (S : Finset (Fin n)) (h : S.card = k) : invF S ≤ k * (n - k) := by
  -- The number of pairs (i, j) in S × Sᶜ where i < j is at most the cardinality of S × Sᶜ, which is k*(n-k).
  have h_card : (Finset.univ.filter (fun p : Fin n × Fin n => p.1 < p.2 ∧ p.1 ∈ S ∧ p.2 ∉ S)).card ≤ (S ×ˢ (Finset.univ \ S)).card := by
    exact Finset.card_le_card fun x hx => by aesop;
  simp_all +decide [ Finset.card_sdiff ];
  convert h_card using 1

/-
Beyond the maximal inversion number the class is empty.
-/
lemma classSize_eq_zero_of_gt {n k i : ℕ} (h : k * (n - k) < i) : classSize n k i = 0 := by
  exact Finset.card_eq_zero.mpr <| Finset.filter_eq_empty_iff.mpr fun x hx => by linarith [ invF_le x <| Finset.mem_powersetCard.mp hx |>.2 ] ;

/-
The 2-binomial class sizes for fixed `(n, k)` sum to the binomial coefficient `C(n,k)`.
-/
theorem total_eq_choose (n k : ℕ) :
    ∑ i ∈ Finset.range (k * (n - k) + 1), classSize n k i = n.choose k := by
  unfold classSize;
  rw [ ← Finset.card_eq_sum_card_fiberwise ];
  · unfold words; simp +decide [ Finset.card_univ ] ;
  · exact fun x hx => Finset.mem_range_succ_iff.mpr ( invF_le x ( mem_words.mp hx ) )

/-
Reversing a word swaps inversions and co-inversions.
-/
lemma invF_image_rev {n : ℕ} (S : Finset (Fin n)) :
    invF (S.image Fin.rev) = coinvF S := by
  refine' Finset.card_bij ( fun p hp => ( Fin.rev p.2, Fin.rev p.1 ) ) _ _ _ <;> simp +decide;
  · grind;
  · aesop;
  · intro a b hab ha hb; use Fin.rev a; aesop;

/-
Inversions and co-inversions of a `k`-one word partition the `k(n-k)` mixed pairs.
-/
lemma invF_add_coinvF {n k : ℕ} (S : Finset (Fin n)) (h : S.card = k) :
    invF S + coinvF S = k * (n - k) := by
  -- The set of all pairs (i, j) with i < j and i ∈ S ∧ j ∉ S or i ∉ S ∧ j ∈ S is exactly the set of pairs (i, j) with i ∈ S and j ∉ S.
  have h_pairs : (Finset.univ.filter (fun p : Fin n × Fin n => p.1 < p.2 ∧ (p.1 ∈ S ↔ p.2 ∉ S))) = Finset.image (fun p : Fin n × Fin n => if p.1 < p.2 then p else (p.2, p.1)) (S ×ˢ Sᶜ) := by
    ext ⟨x, y⟩; simp [Finset.mem_image];
    grind;
  have h_card : (Finset.univ.filter (fun p : Fin n × Fin n => p.1 < p.2 ∧ (p.1 ∈ S ↔ p.2 ∉ S))).card = (S ×ˢ Sᶜ).card := by
    rw [ h_pairs, Finset.card_image_of_injOn ];
    intro p hp q hq; aesop;
  convert h_card using 1;
  · unfold invF coinvF;
    rw [ ← Finset.card_union_of_disjoint ];
    · congr with p ; by_cases hi : p.1 ∈ S <;> by_cases hj : p.2 ∈ S <;> simp +decide [ hi, hj ];
    · exact Finset.disjoint_filter.mpr ( by aesop );
  · simp +decide [ ← h, Finset.card_compl ]

/-
**Palindromic symmetry** of the 2-binomial class sizes: the class at inversion number
`i` has the same size as the class at the mirror inversion number `k(n-k) - i`.
-/
theorem classSize_symm (n k i : ℕ) (hi : i ≤ k * (n - k)) :
    classSize n k i = classSize n k (k * (n - k) - i) := by
  unfold classSize
  -- Bijection: reversing the word swaps inversions `10` with co-inversions `01`,
  -- sending inversion number `j` to `k(n-k) - j`.
  apply Finset.card_nbij' (fun S => S.image Fin.rev) (fun S => S.image Fin.rev)
  · intro S hS
    simp only [Finset.mem_coe, Finset.mem_filter, mem_words] at hS ⊢
    obtain ⟨hcard, hinv⟩ := hS
    refine ⟨by rw [Finset.card_image_of_injective _ Fin.rev_injective]; exact hcard, ?_⟩
    rw [invF_image_rev]; have := invF_add_coinvF S hcard; omega
  · intro S hS
    simp only [Finset.mem_coe, Finset.mem_filter, mem_words] at hS ⊢
    obtain ⟨hcard, hinv⟩ := hS
    refine ⟨by rw [Finset.card_image_of_injective _ Fin.rev_injective]; exact hcard, ?_⟩
    rw [invF_image_rev]; have := invF_add_coinvF S hcard; omega
  · intro S _
    simp only [Finset.image_image]
    rw [show (Fin.rev ∘ Fin.rev : Fin n → Fin n) = id from funext Fin.rev_rev, Finset.image_id]
  · intro S _
    simp only [Finset.image_image]
    rw [show (Fin.rev ∘ Fin.rev : Fin n → Fin n) = id from funext Fin.rev_rev, Finset.image_id]

/-
**Expected inversion number is central.** Drawing a binary word of length `n` with `k`
ones uniformly at random, the mean inversion number is `k(n-k)/2` — the central index. In
cleared (denominator-free) form: `2 * Σ i·classSize = k(n-k) · C(n,k)`. This is a direct
consequence of the palindromic symmetry `classSize_symm`.
-/
theorem inv_weighted_sum (n k : ℕ) :
    2 * ∑ i ∈ Finset.range (k * (n - k) + 1), i * classSize n k i
      = k * (n - k) * n.choose k := by
  -- By palindromic symmetry, we have $\sum_{i=0}^{M} i \cdot \text{classSize}(n, k, i) = \sum_{i=0}^{M} (M - i) \cdot \text{classSize}(n, k, i)$.
  have h_symm : ∑ i ∈ Finset.range (k * (n - k) + 1), i * classSize n k i = ∑ i ∈ Finset.range (k * (n - k) + 1), (k * (n - k) - i) * classSize n k i := by
    rw [ ← Finset.sum_flip ];
    exact Finset.sum_congr rfl fun x hx => by rw [ classSize_symm _ _ _ ( Nat.le_of_lt_succ ( Finset.mem_range.mp hx ) ) ] ;
  -- Add the two sums together, using the fact that $i + (M - i) = M$ for every $i \in \{0, \ldots, M\}$, and then use $\sum_{i=0}^{M} c_i = C(n,k)$.
  have h_sum_eq : ∑ i ∈ Finset.range (k * (n - k) + 1), i * classSize n k i + ∑ i ∈ Finset.range (k * (n - k) + 1), (k * (n - k) - i) * classSize n k i = (k * (n - k)) * ∑ i ∈ Finset.range (k * (n - k) + 1), classSize n k i := by
    rw [ ← Finset.sum_add_distrib, Finset.mul_sum ];
    exact Finset.sum_congr rfl fun x hx => by rw [ ← add_mul, Nat.add_sub_of_le ( Finset.mem_range_succ_iff.mp hx ) ] ;
  rw [ total_eq_choose ] at * ; linarith

-- !-- Lab Notes -- !--
-- Headline experiments: central coefficient is the *global* maximum for explicit (n,k).
-- Each is a genuine theorem quantified over all i : ℕ (the tail i > k(n-k) is handled by
-- `classSize_eq_zero_of_gt`, the support is checked by computation).

/-- For words of length 4 with 2 ones, the central class (inversion number 2) is largest. -/
theorem central_max_4_2 (i : ℕ) : classSize 4 2 i ≤ classSize 4 2 (centralIndex 4 2) := by
  show classSize 4 2 i ≤ classSize 4 2 2
  rcases Nat.lt_or_ge i 5 with h | h
  · interval_cases i <;> native_decide
  · rw [classSize_eq_zero_of_gt (by omega)]; exact Nat.zero_le _

/-- For words of length 5 with 2 ones, the central class (inversion number 3) is largest. -/
theorem central_max_5_2 (i : ℕ) : classSize 5 2 i ≤ classSize 5 2 (centralIndex 5 2) := by
  show classSize 5 2 i ≤ classSize 5 2 3
  rcases Nat.lt_or_ge i 7 with h | h
  · interval_cases i <;> native_decide
  · rw [classSize_eq_zero_of_gt (by omega)]; exact Nat.zero_le _

/-- For words of length 6 with 3 ones, the central class (inversion number 4) is largest. -/
theorem central_max_6_3 (i : ℕ) : classSize 6 3 i ≤ classSize 6 3 (centralIndex 6 3) := by
  show classSize 6 3 i ≤ classSize 6 3 4
  rcases Nat.lt_or_ge i 10 with h | h
  · interval_cases i <;> native_decide
  · rw [classSize_eq_zero_of_gt (by omega)]; exact Nat.zero_le _

/-- For words of length 7 with 3 ones, the central class is largest. -/
theorem central_max_7_3 (i : ℕ) : classSize 7 3 i ≤ classSize 7 3 (centralIndex 7 3) := by
  show classSize 7 3 i ≤ classSize 7 3 6
  rcases Nat.lt_or_ge i 13 with h | h
  · interval_cases i <;> native_decide
  · rw [classSize_eq_zero_of_gt (by omega)]; exact Nat.zero_le _

end BinaryTwoBinomial