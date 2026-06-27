/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# McEliece Cryptosystem, Part I: Linear Codes and Bounded-Distance Decoding

This file develops the abstract decoding theory underlying the McEliece
cryptosystem.  The McEliece scheme encrypts a message by encoding it with a
secret linear code (a Goppa code) and adding a random error vector of weight at
most `t`.  Decryption succeeds because the secret code can correct `t` errors,
while an attacker only sees a scrambled generator matrix and must decode a
*random-looking* linear code — the hardness assumption.

The mathematical heart of "correcting `t` errors" is a packing argument in the
Hamming metric:

* `unique_decoding` — if any two distinct codewords are at Hamming distance at
  least `2t+1`, then every received word lies within distance `t` of at most one
  codeword.  This is the rigorous statement of *bounded-distance decoding*.

* `syndrome_eq_of_codeword` — the syndrome `H·(c+e)` of a transmitted codeword
  `c` plus error `e` equals the syndrome `H·e` of the error alone.  This is why
  decoding can be performed from the syndrome (Niederreiter / syndrome decoding).

* `syndrome_decoding_unique` — **syndrome decoding correctness**: if the linear
  code `ker H` has minimum weight at least `2t+1`, then two error vectors of
  weight at most `t` with the same syndrome must be equal.  Hence the syndrome of
  a received word determines the (unique low-weight) error.

## References

* R. J. McEliece, *A Public-Key Cryptosystem Based on Algebraic Coding Theory*,
  DSN Progress Report (1978).
* H. Niederreiter, *Knapsack-type cryptosystems and algebraic coding theory*,
  Problems of Control and Information Theory (1986).
-/

namespace McEliece

open Finset Matrix

-- !-- Lab Notes -- !--
-- HYPOTHESIS (Hypothesizer): "Correcting `t` errors" is not an algorithmic
--   accident but a metric-geometric inevitability: a code whose codewords are
--   pairwise `≥ 2t+1` apart has disjoint radius-`t` Hamming balls, so a received
--   word can come from only one codeword.
-- EXPERIMENT (Experimenter): formalize via the Hamming-metric triangle
--   inequality (`hammingDist_triangle`).  The packing argument is a two-line
--   `by_contra` + `omega` once distances are bounded.
-- ANALYSIS (Analyst): the same triangle bound, applied to differences of error
--   vectors, yields *syndrome-decoding* uniqueness, linking the metric picture
--   to the linear-algebra picture `ker H`.
-- CRITIQUE (Critic): the statements are vacuous only if no codeword pair exists;
--   we keep the hypotheses on `C`/`H` general so the results bite for real codes
--   (instantiated for Goppa/GRS codes in `GoppaDistance.lean`).
-- SYNTHESIS (PI): the packing lemma and syndrome-uniqueness lemma together are
--   the abstract decoding interface that `GoppaDistance.lean` instantiates and
--   `Parameters.lean` quantifies, giving the full McEliece correctness story.
-- !-- -- !--

variable {n : ℕ} {K : Type*}

/-! ### Bounded-distance decoding (the packing argument) -/

/-
**Unique decoding within the packing radius.**

If every two distinct codewords of `C` are at Hamming distance at least `2t+1`
(i.e. the code has minimum distance `≥ 2t+1`), then any received word `r` is
within Hamming distance `t` of **at most one** codeword.  This is the precise
sense in which such a code "corrects `t` errors".
-/
theorem unique_decoding [DecidableEq K] (C : Set (Fin n → K)) (t : ℕ)
    (hsep : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * t + 1 ≤ hammingDist x y)
    (r x y : Fin n → K) (hx : x ∈ C) (hy : y ∈ C)
    (hrx : hammingDist r x ≤ t) (hry : hammingDist r y ≤ t) :
    x = y := by
  by_contra hxy;
  have h_triangle : hammingDist x y ≤ hammingDist x r + hammingDist r y :=
    hammingDist_triangle x r y
  linarith [ hsep x hx y hy hxy, show hammingDist x r = hammingDist r x from by rw [ hammingDist_comm ] ]

/-- **A correctable error is recovered exactly.**

If a codeword `c` is transmitted and corrupted by an error of weight at most `t`,
producing `r`, then `c` is the *unique* codeword within distance `t` of `r`
(under the same `2t+1` separation hypothesis). -/
theorem decoded_codeword_unique [DecidableEq K] (C : Set (Fin n → K)) (t : ℕ)
    (hsep : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * t + 1 ≤ hammingDist x y)
    (c r : Fin n → K) (hc : c ∈ C) (hcr : hammingDist r c ≤ t)
    (c' : Fin n → K) (hc' : c' ∈ C) (hc'r : hammingDist r c' ≤ t) :
    c' = c :=
  unique_decoding C t hsep r c' c hc' hc hc'r hcr

/-! ### Syndrome decoding -/

variable {t : ℕ} [Field K]

/-
**Syndrome of received word = syndrome of error.**

If `c` is a codeword (`H·c = 0`) corrupted by error `e`, the syndrome of the
received word `c + e` equals the syndrome of `e`.  Syndrome decoding exploits
this: it recovers the error from the syndrome, independent of which codeword was
sent.
-/
theorem syndrome_eq_of_codeword (H : Matrix (Fin t) (Fin n) K)
    (c e : Fin n → K) (hc : H.mulVec c = 0) :
    H.mulVec (c + e) = H.mulVec e := by
  rw [ Matrix.mulVec_add, hc, zero_add ]

/-
**Syndrome decoding correctness.**

Let `H` be a parity-check matrix whose code `ker H` has minimum weight at least
`2t+1` (every nonzero codeword has Hamming weight `≥ 2t+1`).  Then two error
vectors of weight at most `t` that share a syndrome are equal.  Consequently the
syndrome of a received word uniquely determines the low-weight error, which is
exactly what the McEliece/Niederreiter decoder computes.
-/
theorem syndrome_decoding_unique [DecidableEq K] (H : Matrix (Fin t) (Fin n) K)
    (hmin : ∀ c : Fin n → K, H.mulVec c = 0 → c ≠ 0 → 2 * t + 1 ≤ hammingNorm c)
    (e₁ e₂ : Fin n → K) (he₁ : hammingNorm e₁ ≤ t) (he₂ : hammingNorm e₂ ≤ t)
    (hsyn : H.mulVec e₁ = H.mulVec e₂) :
    e₁ = e₂ := by
  contrapose! hmin;
  refine' ⟨ e₁ - e₂, _, _, _ ⟩;
  · rw [ Matrix.mulVec_sub, hsyn, sub_self ];
  · exact sub_ne_zero_of_ne hmin;
  · refine' lt_of_le_of_lt ( _ : hammingNorm ( e₁ - e₂ ) ≤ hammingNorm e₁ + hammingNorm e₂ ) ( by linarith );
    exact le_trans ( Finset.card_le_card fun i hi => by by_cases hi₁ : e₁ i = 0 <;> by_cases hi₂ : e₂ i = 0 <;> simp_all +decide [ sub_eq_zero ] ) ( Finset.card_union_le _ _ )

end McEliece