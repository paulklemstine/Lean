import Logic.TopoErrorMitigation.MajorityDecoding

/-!
# Majority Voting *is* Nearest-Codeword (Maximum-Likelihood) Decoding

The companion file `Logic.TopoErrorMitigation.MajorityDecoding` defines the
repetition-code majority decoder and proves a one-sided correctness threshold.
Here we characterise *what the decoder optimises*: we prove that the majority
vote returns precisely the logical bit at minimum Hamming distance from the noisy
readout. For the binary repetition code the two codewords are the all-`false` and
all-`true` strings, and the Hamming distance to codeword `b` is `errors s b`.
Thus `majority` is the maximum-likelihood / nearest-codeword decoder.

Main results:

* `errors_complement` — the error counts against the two codewords partition the
  block length: `errors s true + errors s false = n`;
* `majority_nearest_codeword` — for every logical bit `b`, the decoded word is at
  least as close as `b`: `errors s (majority s) ≤ errors s b`;
* `majority_eq_min_errors` — quantitatively, the decoder attains the minimum,
  `errors s (majority s) = min (errors s true) (errors s false)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The `> n/2` majority rule is not an ad-hoc tie-break
  but an *optimal* decoder: it always outputs the codeword minimising Hamming
  distance to the observed readout (maximum likelihood under symmetric noise).
Experiment (Experimenter): Reduced both codeword distances to the single counter
  `ones s` via `errors_false : errors s false = ones s` and
  `errors_true : errors s true = n - ones s`, then closed the optimisation by a
  `2 * ones s > n` case split and `omega`. The partition identity came from a
  disjoint-union computation on `Finset.filter`.
Analysis (Analyst): The whole nearest-codeword theory collapses onto the scalar
  `ones s`; the topological "barcode" of the readout for the repetition code is
  one-dimensional. This is *why* the simple count works — and exactly what fails
  for codes with nontrivial `H₁`, motivating the persistent-homology decoders of
  the sister files. Key insight: `errors s true + errors s false = n` is the
  conservation law turning "minimise distance" into "compare `ones s` to `n/2`".
Critique (Critic): The tie `2 * ones s = n` is the only delicate point; there
  `majority = false` and both distances equal `n/2`, so `≤`/`min` still hold —
  no vacuity and no off-by-one. The results are stated for arbitrary readouts,
  not just low-weight ones, so they are not a restatement of the imported
  threshold lemma.
Synthesis (PI): Majority decoding = nearest-codeword decoding, proved exactly
  (`min`), upgrading the imported one-sided threshold to an optimality statement.
-/

namespace TopoErrorMitigation

open Finset

variable {n : ℕ}

/-- The Hamming distance to the all-`false` codeword is the number of `true`
readouts. -/
theorem errors_false (s : Fin n → Bool) : errors s false = ones s := by
  unfold errors ones
  congr 1
  ext i
  simp

/-- The error counts against the two codewords partition the block length. -/
theorem errors_complement (s : Fin n → Bool) :
    errors s true + errors s false = n := by
  unfold errors
  rw [← Finset.card_union_of_disjoint]
  · have huniv : (univ.filter (fun i => s i ≠ true))
        ∪ (univ.filter (fun i => s i ≠ false)) = univ := by
      ext i; cases s i <;> simp
    rw [huniv]; simp
  · rw [Finset.disjoint_filter]; intro i _ h; simpa using h

/-- The Hamming distance to the all-`true` codeword is `n - ones s`. -/
theorem errors_true (s : Fin n → Bool) : errors s true = n - ones s := by
  have h1 := errors_complement s
  have h2 := errors_false s
  omega

/-- **Majority voting is nearest-codeword decoding.** For every logical bit `b`,
the decoded word is at least as close (in Hamming distance) to the readout as
`b` is. -/
theorem majority_nearest_codeword (s : Fin n → Bool) (b : Bool) :
    errors s (majority s) ≤ errors s b := by
  have hf := errors_false s
  have ht := errors_true s
  unfold majority
  by_cases h : 2 * ones s > n
  · simp only [h, decide_true]
    cases b <;> simp only [hf, ht] <;> omega
  · simp only [h, decide_false]
    cases b <;> simp only [hf, ht] <;> omega

/-- **Quantitative optimality.** The decoder attains exactly the minimum Hamming
distance over the two codewords. -/
theorem majority_eq_min_errors (s : Fin n → Bool) :
    errors s (majority s) = min (errors s true) (errors s false) := by
  have hf := errors_false s
  have ht := errors_true s
  unfold majority
  by_cases h : 2 * ones s > n
  · simp only [h, decide_true]
    rw [ht, hf]; omega
  · simp only [h, decide_false]
    rw [hf, ht]; omega

end TopoErrorMitigation