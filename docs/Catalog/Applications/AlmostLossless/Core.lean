/-
# Almost-lossless compression I: the ε-relaxed counting bound

**Research thread:** *Compression Beyond the Pigeonhole Bound*, Phase B,
Question 2 ("can random number generators help?").

The pigeonhole bound of `Catalog/Tropical/CompressionDelta/Pigeonhole.lean`
governs *exact* decoding of *all* strings: an injective encoder into codewords of
length `≤ t` can serve at most `2 ^ (t+1) - 1` sources.  Here we relax the
requirement: the decoder is allowed to *fail* on a set of sources of probability
mass `≤ ε`, but — crucially — **it is never allowed to fail silently**.  This is
formalised by making the decoder partial (`List Bool → Option α`) and demanding
soundness: whenever the decoder returns a value, that value is the true source.

## Main definitions

* `AlmostLossless.Code` — an encoder/partial-decoder pair.
* `AlmostLossless.Sound` — *no silent corruption*: `dec (enc x) = some y → y = x`.
* `AlmostLossless.goodSet` — the set of sources that are decoded correctly.
* `AlmostLossless.failProb` — the probability that decoding fails.

## Main results

* `AlmostLossless.injOn_enc_goodSet` — a sound code is injective on its good set.
* `AlmostLossless.card_goodSet_le` — the good set of a sound code with codeword
  length `≤ t` has at most `2 ^ (t+1) - 1` elements (pigeonhole, restricted).
* `AlmostLossless.epsilon_relaxed_pigeonhole` — **the ε-relaxed counting bound**.
* `AlmostLossless.uniform_rate_bound` — for the uniform source on `N` symbols the
  counting bound relaxes exactly by the factor `(1 - ε)`.
* `AlmostLossless.uniform_rate_bound_logb` — the same in rate (bits) form.
* `AlmostLossless.exact_pigeonhole_of_zero_error` — at `ε = 0` the exact
  pigeonhole bound is recovered, so the relaxation is conservative.
-/
import Mathlib
import Tropical.CompressionDelta.Pigeonhole

namespace AlmostLossless

open Finset

/-! ## Codes with partial decoders -/

/-- A *code* on the source alphabet `α`: a total encoder into bitstrings together
with a **partial** decoder.  Partiality is what makes error *detection* possible:
`none` is an explicit "I failed" answer. -/
structure Code (α : Type*) where
  /-- The encoder. -/
  enc : α → List Bool
  /-- The decoder; `none` means detected failure. -/
  dec : List Bool → Option α

variable {α : Type*}

/-- **No silent corruption.**  Whenever the decoder produces an answer on a
legitimately produced codeword, that answer is the true source. -/
def Sound (c : Code α) : Prop := ∀ x y : α, c.dec (c.enc x) = some y → y = x

/-- The source `x` is decoded correctly. -/
def Decodes (c : Code α) (x : α) : Prop := c.dec (c.enc x) = some x

/-- All codewords have length at most `t`. -/
def LengthBound (c : Code α) (t : ℕ) : Prop := ∀ x : α, (c.enc x).length ≤ t

variable [Fintype α] [DecidableEq α]

/-- The *good set*: the sources on which the decoder succeeds. -/
def goodSet (c : Code α) : Finset α := univ.filter (fun x => c.dec (c.enc x) = some x)

@[simp] theorem mem_goodSet {c : Code α} {x : α} : x ∈ goodSet c ↔ Decodes c x := by
  simp [goodSet, Decodes]

/-- The failure probability of a code under the source distribution `p`. -/
def failProb (p : α → ℝ) (c : Code α) : ℝ := ∑ x ∈ univ \ goodSet c, p x

/-! ## Counting: the relaxed pigeonhole -/

/-- A sound code is injective on the set of sources it decodes correctly.  This is
the exact point at which "almost lossless" still pays the counting price — but only
for the good set. -/
theorem injOn_enc_goodSet {c : Code α} (hs : Sound c) :
    Set.InjOn c.enc (goodSet c : Set α) := by
  intro x hx y hy hxy
  have hy' : c.dec (c.enc y) = some y := (mem_goodSet).1 (by simpa using hy)
  have : c.dec (c.enc x) = some y := by rw [hxy]; exact hy'
  exact (hs x y this).symm

/-- **Restricted pigeonhole.**  A sound code whose codewords are at most `t` bits
long can decode at most `2 ^ (t+1) - 1` sources correctly. -/
theorem card_goodSet_le {c : Code α} (hs : Sound c) {t : ℕ} (ht : LengthBound c t) :
    (goodSet c).card + 1 ≤ 2 ^ (t + 1) := by
  have hsub : (goodSet c).card ≤ (CompressionDelta.shortStrings t).card := by
    refine Finset.card_le_card_of_injOn c.enc (fun a _ => ?_) ?_
    · exact Finset.mem_coe.mpr ((CompressionDelta.mem_shortStrings t _).mpr (ht a))
    · intro a ha b hb h
      exact injOn_enc_goodSet hs ha hb h
  have := CompressionDelta.card_shortStrings t
  omega

/-! ## Probability accounting -/

variable {p : α → ℝ}

/-- The mass of the good set is `1 - failProb`. -/
theorem mass_goodSet (hsum : ∑ x, p x = 1) (c : Code α) :
    ∑ x ∈ goodSet c, p x = 1 - failProb p c := by
  have hsplit : ∑ x ∈ goodSet c, p x + ∑ x ∈ univ \ goodSet c, p x = ∑ x, p x :=
    Finset.sum_add_sum_compl (goodSet c) p
  rw [hsum] at hsplit
  simp only [failProb]
  linarith

/-- **The ε-relaxed counting bound.**  If a sound code with codewords of length
`≤ t` fails with probability at most `ε`, then some set of at most `2 ^ (t+1) - 1`
sources already carries mass `≥ 1 - ε`.  Equivalently: relaxing exact decoding to
`ε`-almost-lossless decoding relaxes the counting bound *exactly* by allowing the
scheme to ignore an `ε`-light set — nothing more. -/
theorem epsilon_relaxed_pigeonhole (hsum : ∑ x, p x = 1) {c : Code α} (hs : Sound c)
    {t : ℕ} (ht : LengthBound c t) {ε : ℝ} (hε : failProb p c ≤ ε) :
    ∃ S : Finset α, S.card + 1 ≤ 2 ^ (t + 1) ∧ 1 - ε ≤ ∑ x ∈ S, p x := by
  refine ⟨goodSet c, card_goodSet_le hs ht, ?_⟩
  rw [mass_goodSet hsum]
  linarith

/-- Contrapositive form: if *every* small set is light, no ε-almost-lossless code of
that rate can exist.  This is the falsifiability gate of the thread: a claimed
scheme with rate `t` and failure `≤ ε` is refuted by exhibiting the mass deficit. -/
theorem no_code_of_all_small_sets_light (hsum : ∑ x, p x = 1) {t : ℕ} {ε : ℝ}
    (hlight : ∀ S : Finset α, S.card + 1 ≤ 2 ^ (t + 1) → ∑ x ∈ S, p x < 1 - ε)
    (c : Code α) (hs : Sound c) (ht : LengthBound c t) : ε < failProb p c := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨S, hcard, hmass⟩ := epsilon_relaxed_pigeonhole hsum hs ht hcon
  exact absurd hmass (not_le.2 (hlight S hcard))

/-! ## The uniform source: the bound relaxes by exactly the factor `1 - ε` -/

/-- **Uniform rate bound.**  For the uniform distribution on `N = #α` symbols, a
sound `ε`-almost-lossless code of length `t` forces `(1 - ε) * N ≤ 2 ^ (t+1)`.
The classical pigeonhole bound `N ≤ 2 ^ (t+1)` is the case `ε = 0`; a positive
failure probability buys exactly the multiplicative slack `1 - ε`, i.e. at most
`log₂ (1/(1-ε))` bits. -/
theorem uniform_rate_bound (hcard : 0 < Fintype.card α) {c : Code α} (hs : Sound c)
    {t : ℕ} (ht : LengthBound c t) {ε : ℝ}
    (hε : failProb (fun _ => (Fintype.card α : ℝ)⁻¹) c ≤ ε) :
    (1 - ε) * (Fintype.card α : ℝ) ≤ 2 ^ (t + 1) := by
  set N : ℝ := (Fintype.card α : ℝ) with hN
  have hNpos : 0 < N := by rw [hN]; exact_mod_cast hcard
  have hsum : ∑ _x : α, (N : ℝ)⁻¹ = 1 := by
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, hN]
    field_simp
  obtain ⟨S, hSc, hSm⟩ := epsilon_relaxed_pigeonhole hsum hs ht hε
  have hmass : ∑ _x ∈ S, (N : ℝ)⁻¹ = S.card / N := by
    rw [Finset.sum_const, nsmul_eq_mul]
    field_simp
  rw [hmass] at hSm
  have h1 : (1 - ε) * N ≤ (S.card : ℝ) := by
    have hlt : (1 - ε) * N ≤ ((S.card : ℝ) / N) * N :=
      mul_le_mul_of_nonneg_right hSm (le_of_lt hNpos)
    calc (1 - ε) * N ≤ ((S.card : ℝ) / N) * N := hlt
      _ = (S.card : ℝ) := by field_simp
  have h2 : (S.card : ℝ) + 1 ≤ (2 : ℝ) ^ (t + 1) := by
    exact_mod_cast (hSc : (S.card + 1 : ℕ) ≤ 2 ^ (t + 1))
  linarith

/-- Rate form of `uniform_rate_bound`: the number of transmitted bits is at least
`log₂ ((1 - ε) N) - 1`. -/
theorem uniform_rate_bound_logb (hcard : 0 < Fintype.card α) {c : Code α} (hs : Sound c)
    {t : ℕ} (ht : LengthBound c t) {ε : ℝ} (hpos : 0 < 1 - ε)
    (hε : failProb (fun _ => (Fintype.card α : ℝ)⁻¹) c ≤ ε) :
    Real.logb 2 ((1 - ε) * (Fintype.card α : ℝ)) ≤ (t : ℝ) + 1 := by
  have hNpos : (0 : ℝ) < (Fintype.card α : ℝ) := by exact_mod_cast hcard
  have hb := uniform_rate_bound hcard hs ht hε
  have hmono : Real.logb 2 ((1 - ε) * (Fintype.card α : ℝ)) ≤ Real.logb 2 ((2 : ℝ) ^ (t + 1)) :=
    Real.logb_le_logb_of_le (by norm_num) (mul_pos hpos hNpos) hb
  rw [Real.logb_pow] at hmono
  simpa using hmono

/-- **Sanity check / conservativity.**  At `ε = 0` (a code that never fails) the
relaxed bound is exactly the classical pigeonhole bound: `#α ≤ 2 ^ (t+1)`. -/
theorem exact_pigeonhole_of_zero_error (hcard : 0 < Fintype.card α) {c : Code α}
    (hs : Sound c) {t : ℕ} (ht : LengthBound c t)
    (hε : failProb (fun _ => (Fintype.card α : ℝ)⁻¹) c ≤ 0) :
    (Fintype.card α : ℝ) ≤ 2 ^ (t + 1) := by
  have := uniform_rate_bound hcard hs ht hε
  linarith

end AlmostLossless