import Tropical.CompressionDelta.Pigeonhole

/-!
# Amortized model-delta compression, IV: the losslessness gate

The falsifiability gate of the research thread requires *lossless* decoding with the
decoder fixed at deploy time and the model delta counted inside the transmitted message.
This file provides the constructive side: a shared codec (the "specialized decompressor"
selected by the transmitted delta) whose stream decoder reproduces the input exactly,
together with the bit accounting showing that it strictly beats the delta-free protocol
past the break-even point established in `CompressionDelta.Amortization`.

## Main results

* `CompressionDelta.exists_sharedCodec` — a domain-adapted codec exists whenever the
  domain `S` fits in `2 ^ s` codewords.
* `CompressionDelta.decodeStream_encodeStream` — **exact** reconstruction of the whole
  stream (the losslessness gate).
* `CompressionDelta.amortized_protocol` — the full statement: an exactly-lossless
  streaming protocol using `D + n * s` bits, strictly fewer than the `n * (s + 1)` bits of
  the delta-free generic protocol as soon as the stream is longer than the delta.
-/

namespace CompressionDelta

variable {X : Type*}

/-- A shared decompressor specialised to a domain: an encoder into `s`-bit codewords and a
decoder fixed at deploy time.  The `s`-bit codewords are the arithmetic-coded residuals;
selecting the codec is what the transmitted model delta pays for. -/
structure SharedCodec (X : Type*) (s : ℕ) where
  /-- Encoder: maps a message to its `s`-bit residual codeword. -/
  encode : X → Fin (2 ^ s)
  /-- Decoder, fixed at deploy time up to the transmitted delta. -/
  decode : Fin (2 ^ s) → X

/-- Encode a stream message by message. -/
def encodeStream {s : ℕ} (codec : SharedCodec X s) (xs : List X) : List (Fin (2 ^ s)) :=
  xs.map codec.encode

/-- Decode a stream message by message. -/
def decodeStream {s : ℕ} (codec : SharedCodec X s) (is : List (Fin (2 ^ s))) : List X :=
  is.map codec.decode

/-- A codec is lossless on the domain `S` if it round-trips every message of `S`. -/
def LosslessOn {s : ℕ} (codec : SharedCodec X s) (S : Finset X) : Prop :=
  ∀ x ∈ S, codec.decode (codec.encode x) = x

/-- **Existence of the domain-adapted codec.**  If the domain `S` has at most `2 ^ s`
elements then some codec is exactly lossless on it. -/
theorem exists_sharedCodec [DecidableEq X] [Nonempty X] (S : Finset X) (s : ℕ)
    (hS : S.card ≤ 2 ^ s) :
    ∃ codec : SharedCodec X s, LosslessOn codec S := by
  classical
  have hcard : Fintype.card {x // x ∈ S} ≤ Fintype.card (Fin (2 ^ s)) := by
    simp only [Fintype.card_coe, Fintype.card_fin]
    exact hS
  obtain ⟨e⟩ := Function.Embedding.nonempty_of_card_le hcard
  refine ⟨⟨fun x => if h : x ∈ S then e ⟨x, h⟩ else ⟨0, Nat.two_pow_pos s⟩,
      fun i => if h : ∃ y : {x // x ∈ S}, e y = i then (Classical.choose h).1
        else Classical.arbitrary X⟩, ?_⟩
  · intro x hx
    have hex : ∃ y : {x // x ∈ S}, e y = e ⟨x, hx⟩ := ⟨⟨x, hx⟩, rfl⟩
    simp only [hx, dif_pos]
    rw [dif_pos hex]
    have hchoose := Classical.choose_spec hex
    have : Classical.choose hex = (⟨x, hx⟩ : {x // x ∈ S}) := e.injective hchoose
    exact congrArg Subtype.val this

/-- **The losslessness gate.**  A codec that round-trips every message of the domain
reconstructs an entire stream from that domain *exactly*. -/
theorem decodeStream_encodeStream {s : ℕ} (codec : SharedCodec X s) (S : Finset X)
    (hcodec : LosslessOn codec S) :
    ∀ xs : List X, (∀ x ∈ xs, x ∈ S) → decodeStream codec (encodeStream codec xs) = xs := by
  intro xs
  induction xs with
  | nil => intro _; simp [encodeStream, decodeStream]
  | cons x xs ih =>
      intro hxs
      have hx : x ∈ S := hxs x (by simp)
      have hrest : ∀ y ∈ xs, y ∈ S := fun y hy => hxs y (by simp [hy])
      simp only [encodeStream, decodeStream, List.map_cons] at *
      rw [hcodec x hx, ih hrest]

/-- Total number of transmitted bits of the amortized protocol on a stream of `n`
messages: the model delta once, then `s` bits of residual per message. -/
def amortizedBits (D s n : ℕ) : ℕ := D + n * s

/-- **The amortized protocol.**  For a domain fitting in `2 ^ s` codewords there is a
codec that decodes every stream from that domain exactly, and whose bit budget
`D + n * s` (model delta included) is strictly smaller than the `n * (s + 1)` bits of the
delta-free generic protocol precisely when the stream is longer than the delta.  Together
with `CompressionDelta.stream_counting_bound` (floor `n * s`) this pins the protocol to
within `D` bits of the information-theoretic optimum, uniformly in `n`. -/
theorem amortized_protocol [DecidableEq X] [Nonempty X] (S : Finset X) (s : ℕ)
    (hS : S.card ≤ 2 ^ s) (D n : ℕ) :
    ∃ codec : SharedCodec X s,
      (∀ xs : List X, (∀ x ∈ xs, x ∈ S) → decodeStream codec (encodeStream codec xs) = xs) ∧
      (amortizedBits D s n < n * (s + 1) ↔ D < n) ∧
      n * s ≤ amortizedBits D s n := by
  obtain ⟨codec, hcodec⟩ := exists_sharedCodec S s hS
  refine ⟨codec, decodeStream_encodeStream codec S hcodec, ?_, ?_⟩
  · unfold amortizedBits
    have : n * (s + 1) = n * s + n := by ring
    omega
  · unfold amortizedBits
    omega

end CompressionDelta