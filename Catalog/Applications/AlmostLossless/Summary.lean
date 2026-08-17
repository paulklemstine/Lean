/-
# Almost-lossless compression VII: the deliverable, in one theorem

This file assembles the results of
`Applications.AlmostLossless.{Core, Enumerative, Complexity, RandomCoding, Checksum, Optimal}`
into the single statement demanded by the research gate: *a scheme, a proof that
decoding succeeds with probability ≥ 1 − ε, an exact decoding-complexity figure,
and a guarantee that failures are never silent — neither on the source side nor on
the channel side.*

* `AlmostLossless.almost_lossless_master` — the checksummed enumerative scheme
  `withParity (enumCode S k)`:
  1. **soundness** — a returned source is always the true one;
  2. **rate** — `k + 2` bits (index, failure flag, parity bit);
  3. **failure probability** — `≤ ε`, where `ε` is the mass outside the typical set;
  4. **explicit failure reporting** — atypical sources decode to `none`;
  5. **exact decoding complexity** — `2k + 4` steps (checksum verification plus
     index decoding), linear in the rate;
  6. **channel error detection** — any single flipped bit is detected.

* `AlmostLossless.almost_lossless_converse_master` — and no scheme can do better
  than the counting bound allows.
-/
import Mathlib
import Applications.AlmostLossless.Checksum
import Applications.AlmostLossless.RandomCoding
import Applications.AlmostLossless.Optimal

namespace AlmostLossless

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- **The scheme and its full guarantee.** -/
theorem almost_lossless_master {p : α → ℝ} (hsum : ∑ x, p x = 1) (S : Finset α) (k : ℕ)
    (hcard : S.card ≤ 2 ^ k) {ε : ℝ} (hmass : 1 - ε ≤ ∑ x ∈ S, p x) :
    Sound (withParity (enumCode S k)) ∧
    LengthBound (withParity (enumCode S k)) (k + 2) ∧
    failProb p (withParity (enumCode S k)) ≤ ε ∧
    (∀ x ∉ S, (withParity (enumCode S k)).dec ((withParity (enumCode S k)).enc x) = none) ∧
    (∀ x ∈ S, (parityI ((withParity (enumCode S k)).enc x)).2
        + (enumDecI S ((enumCode S k).enc x)).2 = 2 * k + 4) ∧
    (∀ (x : α) (i : ℕ) (h : i < ((withParity (enumCode S k)).enc x).length),
        (withParity (enumCode S k)).dec
          (((withParity (enumCode S k)).enc x).set i
            (!(((withParity (enumCode S k)).enc x).get ⟨i, h⟩))) = none) := by
  refine ⟨withParity_sound (enumCode_sound S k hcard),
    withParity_lengthBound (enumCode_lengthBound S k), ?_, ?_, ?_,
    fun x i h => withParity_detects_single_flip (enumCode S k) x i h⟩
  · rw [withParity_failProb]
    have hmg : ∑ x ∈ goodSet (enumCode S k), p x = 1 - failProb p (enumCode S k) :=
      mass_goodSet hsum _
    rw [goodSet_enumCode S k hcard] at hmg
    linarith
  · intro x hx
    rw [withParity_dec_enc]
    exact enumCode_detects_failure hx
  · intro x hx
    exact withParity_cost hcard hx

/-- **The matching converse.**  Any sound code with codewords of length `≤ t` and
failure probability `≤ ε` — however it is built, randomised or not — obeys the
ε-relaxed counting bound, and if it fails anywhere it must reserve a codeword for
the failure marker. -/
theorem almost_lossless_converse_master {p : α → ℝ} (hsum : ∑ x, p x = 1)
    {c : Code α} (hs : Sound c) {t : ℕ} (ht : LengthBound c t) {ε : ℝ}
    (hfail : failProb p c ≤ ε) :
    (∃ S : Finset α, S.card + 1 ≤ 2 ^ (t + 1) ∧ 1 - ε ≤ ∑ x ∈ S, p x) ∧
      (goodSet c ≠ univ → (goodSet c).card + 2 ≤ 2 ^ (t + 1)) :=
  ⟨epsilon_relaxed_pigeonhole hsum hs ht hfail, fun hne => card_goodSet_add_two_le hs ht hne⟩

end AlmostLossless