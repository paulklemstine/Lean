import Mathlib

/-!
# Information-Theoretic Limits of Encoding and Proof Search

This file formalizes the *counting* core of the information-theoretic limits behind
proof search: **no code can compress everything**, **most objects are incompressible**,
and **the space of candidate proofs of a given length is exponentially large**.

We model a "description" as a finite binary string.  A statement/message of `n` bits is
an element of `Bits n := Fin n → Bool` (there are exactly `2 ^ n` of them).  A finite
binary string of length `< n` is an element of

`ShortCode n := Σ k : Fin n, (Fin (k : ℕ) → Bool)`,

and there are exactly `2 ^ n - 1` of these.  A *code* is an injective map that assigns to
each message a finite binary description; the full description space is
`BinStr := Σ k : ℕ, (Fin k → Bool)`, with description length `len ⟨k, _⟩ = k`.

## Main results

* `card_Bits`               : `Fintype.card (Bits n) = 2 ^ n`.
* `card_ShortCode`          : `Fintype.card (ShortCode n) = 2 ^ n - 1`.
* `no_universal_compression`: no injection `Bits n → ShortCode n` exists — no lossless
  code maps every one of the `2 ^ n` messages to a string of length `< n`.
* `exists_incompressible`   : for every code `f : Bits n → BinStr` some message has
  description length `≥ n`; it cannot be compressed below its own size.
* `compressible_le`         : for every code, at most `2 ^ t - 1` messages get a
  description shorter than `t`.
* `incompressible_count`    : hence at least `2 ^ n - (2 ^ t - 1)` messages have
  description length `≥ t` — *most* messages are incompressible.
* `search_space_exponential`: the number of candidate descriptions of length `≤ L` is at
  least `2 ^ L`, so brute-force search over descriptions is exponential in the length.
* `incompressible_fraction`: for any code, the *fraction* of messages whose description has
  length `≥ n - c` is at least `1 - 2 ^ (-c)` — most messages are essentially incompressible.

These are the rigorous finite-combinatorial statements underlying the slogan
"verifying a proof is easy, finding one is exponentially hard": checking a candidate is a
single evaluation, while the candidate space grows like `2 ^ L`, and no scheme can dodge
this by compressing all descriptions.
-/

namespace ProofSearchInfo

/-- A message / statement of `n` bits.  There are exactly `2 ^ n` of these. -/
abbrev Bits (n : ℕ) : Type := Fin n → Bool

/-- All finite binary strings of length strictly less than `n` (the "short descriptions"). -/
abbrev ShortCode (n : ℕ) : Type := Σ k : Fin n, (Fin (k : ℕ) → Bool)

/-- The full space of finite binary strings (descriptions of arbitrary length). -/
abbrev BinStr : Type := Σ k : ℕ, (Fin k → Bool)

/-- The length (number of bits) of a binary string. -/
def len (s : BinStr) : ℕ := s.1

/-- There are exactly `2 ^ n` messages of `n` bits. -/
theorem card_Bits (n : ℕ) : Fintype.card (Bits n) = 2 ^ n := by
  simp +decide [Bits]

/-- There are exactly `2 ^ n - 1` binary strings of length `< n`. -/
theorem card_ShortCode (n : ℕ) : Fintype.card (ShortCode n) = 2 ^ n - 1 := by
  -- Rewrite the cardinality as a sum over lengths, then sum the geometric series.
  have h_card_sum :
      Fintype.card (ShortCode n) = ∑ k ∈ Finset.range n, Fintype.card (Fin k → Bool) := by
    simp +decide [Fintype.card_sigma, Finset.sum_range]
  simp_all +decide [Fintype.card_pi]
  rw [Nat.geomSum_eq] <;> norm_num

/-- **Incompressibility, cardinality form.**  There is no injective encoding of the `2 ^ n`
length-`n` messages into strings of length `< n`: no lossless code can map *every* message
to a strictly shorter description.  (There are only `2 ^ n - 1 < 2 ^ n` shorter strings.) -/
theorem no_universal_compression (n : ℕ) :
    ¬ ∃ f : Bits n → ShortCode n, Function.Injective f := by
  intro ⟨f, hf⟩
  exact absurd (Fintype.card_le_of_injective f hf)
    (by erw [card_Bits, card_ShortCode]
        exact Nat.not_le_of_gt (Nat.sub_lt (by positivity) (by positivity)))

/-- **Some message is incompressible.**  For any code `f : Bits n → BinStr` (injective
description assignment) there is a message whose description has length `≥ n`; it cannot be
compressed below its own bit-length. -/
theorem exists_incompressible (n : ℕ) (f : Bits n → BinStr) (hf : Function.Injective f) :
    ∃ x : Bits n, n ≤ len (f x) := by
  by_contra h
  -- Otherwise every `f x` has length `< n`, giving an injection `Bits n → ShortCode n`.
  set g : Bits n → ShortCode n := fun x => ⟨⟨(f x).1, by
    exact lt_of_not_ge fun hx => h ⟨x, hx⟩⟩, (f x).2⟩
  generalize_proofs at *
  exact no_universal_compression n ⟨g, by intro x y; aesop⟩

/-- **Few messages compress far.**  For any code `f : Bits n → BinStr`, at most `2 ^ t - 1`
messages receive a description of length `< t`. -/
theorem compressible_le (n : ℕ) (f : Bits n → BinStr) (hf : Function.Injective f) (t : ℕ) :
    (Finset.univ.filter (fun x : Bits n => len (f x) < t)).card ≤ 2 ^ t - 1 := by
  -- The short descriptions of length `< t` form the set `S`; the code injects into it.
  set S := Finset.biUnion (Finset.range t)
    (fun k => Finset.univ.image (fun s : Fin k → Bool => Sigma.mk k s))
  have h_image :
      Finset.image f (Finset.filter (fun x => len (f x) < t) Finset.univ) ⊆ S := by
    intro x hx
    aesop
  convert Finset.card_le_card h_image using 1
  · rw [Finset.card_image_of_injective _ hf]
  · rw [Finset.card_biUnion]
    · rw [Finset.sum_congr rfl fun _ _ => Finset.card_image_of_injective _ fun _ _ h => by aesop]
      norm_num [Nat.geomSum_eq]
    · exact fun i hi j hj hij =>
        Finset.disjoint_left.mpr fun x hx₁ hx₂ => hij <| by aesop

/-- **Most messages are incompressible.**  For any code `f : Bits n → BinStr` and any
threshold `t`, at least `2 ^ n - (2 ^ t - 1)` of the `2 ^ n` messages have description
length `≥ t`.  Taking `t = n - c` this is at least a `1 - 2 ^ (-c)` fraction. -/
theorem incompressible_count (n : ℕ) (f : Bits n → BinStr) (hf : Function.Injective f)
    (t : ℕ) :
    2 ^ n - (2 ^ t - 1) ≤ (Finset.univ.filter (fun x : Bits n => t ≤ len (f x))).card := by
  have := compressible_le n f hf t
  rw [show (Finset.univ.filter fun x => t ≤ len (f x))
        = Finset.univ \ (Finset.univ.filter fun x => len (f x) < t) by ext; aesop,
      Finset.card_sdiff]
  norm_num [card_Bits]
  omega

/-- **The proof-search space is exponential.**  The number of candidate descriptions of
length `≤ L` is at least `2 ^ L`, so exhaustive search over descriptions of length `≤ L`
inspects exponentially many candidates. -/
theorem search_space_exponential (L : ℕ) :
    2 ^ L ≤ Fintype.card (ShortCode (L + 1)) := by
  have := card_ShortCode (L + 1)
  grind

/-- **Quantitative incompressibility.**  For any code `f : Bits n → BinStr` and slack
`c ≤ n`, the fraction of the `2 ^ n` messages whose description has length `≥ n - c` is at
least `1 - 2 ^ (-c)`.  So all but an exponentially small `2 ^ (-c)` fraction of messages are
incompressible up to slack `c`. -/
theorem incompressible_fraction (n c : ℕ) (hc : c ≤ n) (f : Bits n → BinStr)
    (hf : Function.Injective f) :
    1 - (1 : ℚ) / 2 ^ c ≤
      ((Finset.univ.filter (fun x : Bits n => n - c ≤ len (f x))).card : ℚ) / 2 ^ n := by
  field_simp;
  have := incompressible_count n f hf ( n - c );
  rw [ ← @Nat.cast_le ℚ ] at * ; norm_num at *;
  rw [ show ( 2 : ℚ ) ^ n = ( 2 : ℚ ) ^ ( n - c ) * 2 ^ c by rw [ ← pow_add, Nat.sub_add_cancel hc ] ] at *;
  rw [ ← @Nat.cast_le ℚ ] at * ; norm_num at *;
  rw [ show ( 2 : ℚ ) ^ n = ( 2 : ℚ ) ^ ( n - c ) * 2 ^ c by rw [ ← pow_add, Nat.sub_add_cancel hc ] ] at this ; nlinarith [ pow_pos ( zero_lt_two' ℚ ) c, pow_pos ( zero_lt_two' ℚ ) ( n - c ) ]

end ProofSearchInfo