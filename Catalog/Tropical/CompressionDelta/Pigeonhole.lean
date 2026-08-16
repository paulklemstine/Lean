import Mathlib

/-!
# Amortized model-delta compression, III: the counting (pigeonhole) floor

The falsifiability gate of this research thread demands *lossless* compression with the
delta counted as part of the transmitted message.  This file supplies the hard information
theoretic floor that no such scheme can cross, in a form that is agnostic about *what* the
decompressor is: the decoder may be a gzip table, a context mixer or a 16 GB pretrained
language model — only injectivity of the encoder is used.

## Main results

* `CompressionDelta.card_shortStrings` — there are exactly `2 ^ (t + 1) - 1` bitstrings of
  length at most `t` (stated without truncated subtraction).
* `CompressionDelta.card_compressible_le` — for an injective encoder, the number of
  sources whose *entire* transmission (model delta included) is at most `t` bits is at
  most `2 ^ (t + 1) - 1`; so compressible objects are exponentially rare.
* `CompressionDelta.exists_long_codeword` — the pigeonhole bound: some source must be
  transmitted in more than `t` bits as soon as there are `2 ^ (t + 1)` sources.
* `CompressionDelta.stream_counting_bound` — the streaming form: a stream of `n` messages
  from a `2 ^ s`-symbol source needs `n * s` bits for some stream, however clever the
  shared decompressor and its transmitted delta are.
-/

namespace CompressionDelta

open Finset

/-! ## Counting bitstrings of bounded length -/

/-- `shortStrings t` is the finite set of all bitstrings of length at most `t`. -/
def shortStrings : ℕ → Finset (List Bool)
  | 0 => {[]}
  | t + 1 =>
      insert [] (((shortStrings t).image (fun l => true :: l)) ∪
        ((shortStrings t).image (fun l => false :: l)))

@[simp] theorem mem_shortStrings : ∀ (t : ℕ) (l : List Bool),
    l ∈ shortStrings t ↔ l.length ≤ t := by
  intro t
  induction t with
  | zero =>
      intro l
      simp [shortStrings, List.length_eq_zero_iff]
  | succ t ih =>
      intro l
      cases l with
      | nil => simp [shortStrings]
      | cons b l =>
          cases b <;>
            simp [shortStrings, ih]

/-- There are exactly `2 ^ (t + 1) - 1` bitstrings of length at most `t`. -/
theorem card_shortStrings : ∀ t : ℕ, (shortStrings t).card + 1 = 2 ^ (t + 1) := by
  intro t
  induction t with
  | zero => simp [shortStrings]
  | succ t ih =>
      have hinjT : Function.Injective (fun l : List Bool => true :: l) := by
        intro a b h; simpa using h
      have hinjF : Function.Injective (fun l : List Bool => false :: l) := by
        intro a b h; simpa using h
      have hdisj : Disjoint ((shortStrings t).image (fun l => true :: l))
          ((shortStrings t).image (fun l => false :: l)) := by
        rw [Finset.disjoint_left]
        rintro a ha hb
        simp only [Finset.mem_image] at ha hb
        obtain ⟨x, _, hx⟩ := ha
        obtain ⟨y, _, hy⟩ := hb
        rw [← hx] at hy
        simp at hy
      have hnotmem : ([] : List Bool) ∉
          ((shortStrings t).image (fun l => true :: l)) ∪
            ((shortStrings t).image (fun l => false :: l)) := by
        simp
      rw [shortStrings, Finset.card_insert_of_notMem hnotmem,
        Finset.card_union_of_disjoint hdisj, Finset.card_image_of_injective _ hinjT,
        Finset.card_image_of_injective _ hinjF]
      have : 2 ^ (t + 1 + 1) = 2 * 2 ^ (t + 1) := by ring
      omega

/-! ## The counting floor for lossless codes -/

/-- **Compressible sources are exponentially rare.**  For any injective (i.e. losslessly
decodable) encoder `enc`, at most `2 ^ (t + 1) - 1` sources are transmitted in `t` bits or
fewer — no matter how large or clever the shared decompressor is, since the decompressor
is not transmitted here at all. -/
theorem card_compressible_le {α : Type*} [Fintype α] [DecidableEq α]
    (enc : α → List Bool) (hinj : Function.Injective enc) (t : ℕ) :
    ({a : α | (enc a).length ≤ t} : Set α).toFinset.card + 1 ≤ 2 ^ (t + 1) := by
  have hsub : ({a : α | (enc a).length ≤ t} : Set α).toFinset.card ≤ (shortStrings t).card := by
    refine Finset.card_le_card_of_injOn enc ?_ (fun a _ b _ h => hinj h)
    intro a ha
    simp only [Finset.mem_coe, Set.mem_toFinset, Set.mem_setOf_eq] at ha
    exact Finset.mem_coe.mpr ((mem_shortStrings t _).mpr ha)
  have := card_shortStrings t
  omega

/-- **Pigeonhole bound.**  With `2 ^ (t + 1)` distinct sources, any lossless encoder must
spend more than `t` bits on at least one of them.  The transmitted model delta, if any, is
part of `enc a`. -/
theorem exists_long_codeword {α : Type*} [Fintype α] [DecidableEq α]
    (enc : α → List Bool) (hinj : Function.Injective enc) (t : ℕ)
    (hcard : 2 ^ (t + 1) ≤ Fintype.card α) :
    ∃ a : α, t < (enc a).length := by
  by_contra hcon
  push_neg at hcon
  have hall : ({a : α | (enc a).length ≤ t} : Set α).toFinset = Finset.univ := by
    ext a
    simp [hcon a]
  have h := card_compressible_le enc hinj t
  rw [hall, Finset.card_univ] at h
  omega

/-- **The streaming counting floor.**  For a stream of `n` messages drawn from an alphabet
of `2 ^ s` symbols, every lossless transmission scheme — shared pretrained decompressor
plus transmitted model delta plus arithmetic-coded residuals, all of it — must use at
least `n * s` bits on some stream.  This is the floor that the amortized protocol of
`CompressionDelta.Amortization` meets up to the one-off delta. -/
theorem stream_counting_bound (n s : ℕ) (hs : 1 ≤ s)
    (enc : (Fin n → Fin (2 ^ s)) → List Bool) (hinj : Function.Injective enc) :
    ∃ x : Fin n → Fin (2 ^ s), n * s ≤ (enc x).length := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · exact ⟨fun i => i.elim0, by simp⟩
  have hcard : Fintype.card (Fin n → Fin (2 ^ s)) = 2 ^ (n * s) := by
    simp [← pow_mul, Nat.mul_comm]
  have hle : 2 ^ ((n * s - 1) + 1) ≤ Fintype.card (Fin n → Fin (2 ^ s)) := by
    rw [hcard]
    have : (n * s - 1) + 1 = n * s := by
      have : 1 ≤ n * s := Nat.one_le_iff_ne_zero.mpr (by positivity)
      omega
    rw [this]
  obtain ⟨x, hx⟩ := exists_long_codeword enc hinj (n * s - 1) hle
  refine ⟨x, ?_⟩
  have : 1 ≤ n * s := Nat.one_le_iff_ne_zero.mpr (by positivity)
  omega

end CompressionDelta