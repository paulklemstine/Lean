/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# PRNGs Cannot Beat the Pigeonhole Bound

A formal negative result for the research question *"can a pseudo-random number
generator help compress arbitrary data?"*.  The answer is **no**, and this file
proves it in several independent, quantitative ways, together with a fully
formal "demo": a concrete hybrid compressor built on top of a PRNG which
genuinely compresses every PRNG output to `s + 1` bits, while some string still
provably needs `n` bits, and the compressible strings form a `2 ^ (s+2-n)`
fraction of all strings.

## Central Idea

A PRNG is a *function* `G : seeds → streams`.  Functions do not create
information: `2 ^ s` seeds produce at most `2 ^ s` streams.  Any decompressor —
PRNG-driven or not — is just a map `List Bool → data`, so the counting bounds of
`MachineLearning.PRNGCompressionCore` apply verbatim.  A PRNG therefore only
compresses data that *was already* of low description complexity; it never
enlarges the set of `k`-bit-describable strings beyond `2 ^ (k+1)`.

## Main Definitions

* `KC D x` — description complexity of `x` relative to the decompressor `D`
  (length of the shortest program `p` with `D p = x`)
* `hybridDecoder G` — the "PRNG demo" decompressor: a `false` flag selects
  *seed mode* (run the PRNG on the following `s` bits), a `true` flag selects
  *literal mode* (copy the following `n` bits)

## Main Results

Pure PRNG (no side information):

* `prng_seed_bits_lower_bound` — a surjective PRNG needs `s ≥ n` seed bits
* `exists_unreachable_of_short_seed` — if `s < n` some string is never produced
* `prng_range_density` — the PRNG's output set covers at most a `2 ^ (s-n)`
  fraction of all `n`-bit strings

PRNG plus arbitrary side information (this kills the "seed + patch" idea):

* `prng_assisted_no_gain` — for *any* seed-indexed decoder family and *any*
  encoder, some string needs `s + |program| ≥ n` total bits

Complexity-theoretic form:

* `exists_KC_ge` — for every decompressor, some `n`-bit string has `KC ≥ n`
* `KC_compressible_count` — at most a `2 ^ (1-d)` fraction of strings have
  `KC ≤ n - d`
* `KC_postprocess_le` — running a PRNG after a decoder never *increases*
  complexity (data processing), yet the counting bound is unchanged

The demo (both sides of the coin, formally):

* `KC_hybrid_prng_output_le` — every PRNG output compresses to `s + 1` bits
* `KC_hybrid_le_succ` — nothing ever blows up: `KC ≤ n + 1` for all strings
* `prng_no_free_lunch` — yet if `s + 1 < n` there is a string with `KC ≥ n`,
  and that string is provably not a PRNG output
* `lcg_image_card_le`, `lcg_missing_count` — a concrete 4-bit-seed LCG whose
  `8`-bit outputs hit exactly `16` of the `256` values (`240` are unreachable)

## Application Keywords

pseudo-random number generator, Kolmogorov complexity, incompressibility,
pigeonhole principle, lossless compression, no free lunch, seed search
-/

import MachineLearning.PRNGCompressionCore

open Finset

namespace PRNGCompression

/-! ## Seeds as bit strings -/

/-- The bit string spelled out by a seed. -/
def seedBits {s : ℕ} (seed : Bits s) : List Bool := List.ofFn seed

@[simp] lemma seedBits_length {s : ℕ} (seed : Bits s) : (seedBits seed).length = s := by
  simp [seedBits]

/-- Reading a bit string back as a seed. -/
def bitsOfList (s : ℕ) (q : List Bool) : Bits s := fun i => q.getD i false

@[simp] lemma bitsOfList_seedBits {s : ℕ} (seed : Bits s) :
    bitsOfList s (seedBits seed) = seed := by
  funext i
  simp [bitsOfList, seedBits]

lemma seedBits_injective {s : ℕ} : Function.Injective (seedBits (s := s)) := by
  intro a b h
  have := congrArg (bitsOfList s) h
  simpa using this

/-! ## A pure PRNG: no side information -/

/-- **A PRNG creates no entropy.**  If every `n`-bit string can be produced by
the generator `G` from an `s`-bit seed, then `s ≥ n`: seeds are not shorter than
the data they must represent. -/
theorem prng_seed_bits_lower_bound {n s : ℕ} (G : Bits s → Bits n)
    (hG : Function.Surjective G) : n ≤ s := by
  have hcard : Fintype.card (Bits n) ≤ Fintype.card (Bits s) :=
    Fintype.card_le_of_surjective G hG
  rw [card_bits, card_bits] at hcard
  exact (Nat.pow_le_pow_iff_right (by norm_num)).mp hcard

/-- The output set of a PRNG has at most `2 ^ s` elements. -/
theorem prng_range_card_le {n s : ℕ} (G : Bits s → Bits n) :
    (univ.image G).card ≤ 2 ^ s := by
  classical
  calc (univ.image G).card ≤ (univ : Finset (Bits s)).card := Finset.card_image_le
    _ = 2 ^ s := by simp [Bits]

/-- With fewer seed bits than data bits, some string is *never* generated:
"the seed that contains my file" does not exist for most files. -/
theorem exists_unreachable_of_short_seed {n s : ℕ} (hs : s < n) (G : Bits s → Bits n) :
    ∃ x : Bits n, ∀ seed, G seed ≠ x := by
  by_contra h
  push_neg at h
  have hsurj : Function.Surjective G := by
    intro x
    obtain ⟨seed, hseed⟩ := h x
    exact ⟨seed, hseed⟩
  have := prng_seed_bits_lower_bound G hsurj
  omega

/-- **Density of PRNG outputs.**  With an `s`-bit seed the reachable set covers
at most a `2 ^ (s - n)` fraction of the `2 ^ n` strings. -/
theorem prng_range_density {n s : ℕ} (hs : s ≤ n) (G : Bits s → Bits n) :
    2 ^ (n - s) * (univ.image G).card ≤ 2 ^ n := by
  classical
  have h1 := prng_range_card_le G
  have h2 : (2 : ℕ) ^ (n - s) * 2 ^ s = 2 ^ n := by
    rw [← pow_add]
    congr 1
    omega
  calc 2 ^ (n - s) * (univ.image G).card ≤ 2 ^ (n - s) * 2 ^ s :=
        Nat.mul_le_mul_left _ h1
    _ = 2 ^ n := h2

/-! ## A PRNG with arbitrary side information -/

/-- **No gain from "seed + patch".**  Let `D seed p` be *any* decoder that may
consult a PRNG seeded with `seed` and additionally read a program `p`
(the program can be anything: a correction list, a residual, a second seed…).
If an encoder `enc` produces a `(seed, program)` pair from which every `n`-bit
string is recovered, then some string costs at least `n` bits in total.
The PRNG contributes nothing beyond the `s` bits used to name its seed. -/
theorem prng_assisted_no_gain {n s : ℕ} (D : Bits s → List Bool → Bits n)
    (enc : Bits n → Bits s × List Bool)
    (hdec : ∀ x, D (enc x).1 (enc x).2 = x) :
    ∃ x : Bits n, n ≤ s + ((enc x).2).length := by
  classical
  set c : Bits n → List Bool := fun x => seedBits (enc x).1 ++ (enc x).2 with hc
  have hcinj : Function.Injective c := by
    intro x y hxy
    have hlen : (seedBits (enc x).1).length = (seedBits (enc y).1).length := by simp
    obtain ⟨h1, h2⟩ := List.append_inj hxy hlen
    have hs : (enc x).1 = (enc y).1 := seedBits_injective h1
    have := hdec x
    rw [hs, h2, hdec y] at this
    exact this.symm
  obtain ⟨x, hx⟩ := exists_long_codeword n c hcinj
  refine ⟨x, ?_⟩
  have : (c x).length = s + ((enc x).2).length := by simp [hc]
  omega

/-! ## Description complexity relative to a decompressor -/

/-- Description complexity of `x` with respect to the decompressor `D`:
the length of the shortest program that `D` maps to `x`. -/
noncomputable def KC {X : Type*} (D : List Bool → X) (x : X) : ℕ :=
  sInf {l | ∃ p : List Bool, p.length = l ∧ D p = x}

lemma KC_le_of_decodes {X : Type*} {D : List Bool → X} {p : List Bool} {x : X}
    (h : D p = x) : KC D x ≤ p.length :=
  Nat.sInf_le ⟨p, rfl, h⟩

/-- A shortest program exists whenever `x` is decodable at all. -/
lemma exists_shortest_program {X : Type*} {D : List Bool → X} {x : X}
    (h : ∃ p : List Bool, D p = x) :
    ∃ p : List Bool, p.length = KC D x ∧ D p = x := by
  obtain ⟨p, hp⟩ := h
  have hne : {l | ∃ p : List Bool, p.length = l ∧ D p = x}.Nonempty :=
    ⟨p.length, p, rfl, hp⟩
  exact Nat.sInf_mem hne

/-- **Data processing.**  Post-composing a decoder with *any* function (running
a PRNG on its output, say) never increases description complexity — and, by the
counting theorems below, never helps either. -/
theorem KC_postprocess_le {X Y : Type*} (D : List Bool → X) (f : X → Y) (x : X)
    (h : ∃ p : List Bool, D p = x) :
    KC (f ∘ D) (f x) ≤ KC D x := by
  obtain ⟨p, hlen, hdec⟩ := exists_shortest_program h
  have hfp : (f ∘ D) p = f x := by simp [hdec]
  have := KC_le_of_decodes (D := f ∘ D) hfp
  omega

/-- Choosing a shortest program for each string is an injective code. -/
theorem exists_shortest_code {n : ℕ} (D : List Bool → Bits n) (hD : Function.Surjective D) :
    ∃ c : Bits n → List Bool, Function.Injective c ∧ ∀ x, (c x).length = KC D x ∧ D (c x) = x := by
  have hall : ∀ x : Bits n, ∃ p : List Bool, p.length = KC D x ∧ D p = x := by
    intro x
    exact exists_shortest_program (hD x)
  choose c hc1 hc2 using hall
  refine ⟨c, ?_, fun x => ⟨hc1 x, hc2 x⟩⟩
  intro x y hxy
  have := hc2 x
  rw [hxy, hc2 y] at this
  exact this.symm

/-- **Incompressibility.**  For *every* decompressor `D` — in particular every
PRNG-based one — some `n`-bit string has description complexity at least `n`. -/
theorem exists_KC_ge {n : ℕ} (D : List Bool → Bits n) (hD : Function.Surjective D) :
    ∃ x : Bits n, n ≤ KC D x := by
  obtain ⟨c, hinj, hspec⟩ := exists_shortest_code D hD
  obtain ⟨x, hx⟩ := exists_long_codeword n c hinj
  exact ⟨x, by rw [← (hspec x).1]; exact hx⟩

/-- **Quantitative incompressibility.**  For every decompressor, at most a
`2 ^ (1-d)` fraction of the `2 ^ n` strings have complexity `≤ n - d`. -/
theorem KC_compressible_count {n : ℕ} (d : ℕ) (D : List Bool → Bits n)
    (hD : Function.Surjective D) :
    2 ^ d * (univ.filter (fun x : Bits n => KC D x + d ≤ n)).card ≤ 2 ^ (n + 1) := by
  classical
  obtain ⟨c, hinj, hspec⟩ := exists_shortest_code D hD
  have hfilter : (univ.filter (fun x : Bits n => KC D x + d ≤ n))
      = (univ.filter (fun x : Bits n => (c x).length + d ≤ n)) := by
    apply Finset.filter_congr
    intro x _
    rw [(hspec x).1]
  rw [hfilter]
  exact card_compressible_le n d c hinj

/-! ## The demo: a PRNG-powered compressor that works exactly where it must -/

/-- The PRNG demo decompressor.  A leading `false` means *seed mode*: run `G` on
the next `s` bits.  A leading `true` means *literal mode*: copy the next `n`
bits.  This is the best possible "compress to the seed" scheme. -/
def hybridDecoder {n s : ℕ} (G : Bits s → Bits n) : List Bool → Bits n
  | [] => fun _ => false
  | false :: q => G (bitsOfList s q)
  | true :: q => bitsOfList n q

/-- Seed mode works: PRNG outputs are compressed to `s + 1` bits, no matter how
large `n` is.  This is the (only) genuine win a PRNG offers. -/
theorem KC_hybrid_prng_output_le {n s : ℕ} (G : Bits s → Bits n) (seed : Bits s) :
    KC (hybridDecoder G) (G seed) ≤ s + 1 := by
  have hdec : hybridDecoder G (false :: seedBits seed) = G seed := by
    simp [hybridDecoder]
  have := KC_le_of_decodes hdec
  simpa [Nat.add_comm] using this

/-- Literal mode works: the hybrid decompressor is surjective, so it never
fails and never inflates data beyond `n + 1` bits. -/
theorem hybridDecoder_surjective {n s : ℕ} (G : Bits s → Bits n) :
    Function.Surjective (hybridDecoder G) := by
  intro x
  refine ⟨true :: seedBits x, ?_⟩
  simp [hybridDecoder, bitsOfList_seedBits]

theorem KC_hybrid_le_succ {n s : ℕ} (G : Bits s → Bits n) (x : Bits n) :
    KC (hybridDecoder G) x ≤ n + 1 := by
  have hdec : hybridDecoder G (true :: seedBits x) = x := by
    simp [hybridDecoder, bitsOfList_seedBits]
  have := KC_le_of_decodes hdec
  simpa [Nat.add_comm] using this

/-- **No free lunch for PRNG compression.**  Whatever the generator `G`, as soon
as the seed is shorter than the data (`s + 1 < n`) there is an `n`-bit string
that the PRNG-powered compressor cannot describe in fewer than `n` bits — and
that string is provably outside the range of `G`.  Compressing to a seed works
only for data the PRNG already generates. -/
theorem prng_no_free_lunch {n s : ℕ} (hs : s + 1 < n) (G : Bits s → Bits n) :
    ∃ x : Bits n, n ≤ KC (hybridDecoder G) x ∧ ∀ seed, G seed ≠ x := by
  obtain ⟨x, hx⟩ := exists_KC_ge (hybridDecoder G) (hybridDecoder_surjective G)
  refine ⟨x, hx, ?_⟩
  intro seed hseed
  have := KC_hybrid_prng_output_le G seed
  rw [hseed] at this
  omega

/-- **The win is rare.**  At most `2 ^ (s+2)` of the `2 ^ n` strings enjoy the
PRNG shortcut, i.e. a fraction `2 ^ (s+2-n)`. -/
theorem prng_shortcut_is_rare {n s : ℕ} (hs : s + 1 ≤ n) (G : Bits s → Bits n) :
    2 ^ (n - (s + 1)) *
        (univ.filter (fun x : Bits n => KC (hybridDecoder G) x ≤ s + 1)).card
      ≤ 2 ^ (n + 1) := by
  classical
  have hcount := KC_compressible_count (n := n) (n - (s + 1)) (hybridDecoder G)
      (hybridDecoder_surjective G)
  have hsub :
      (univ.filter (fun x : Bits n => KC (hybridDecoder G) x ≤ s + 1))
        ⊆ (univ.filter (fun x : Bits n => KC (hybridDecoder G) x + (n - (s + 1)) ≤ n)) := by
    intro x hx
    have := (Finset.mem_filter.mp hx).2
    exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, by omega⟩
  exact le_trans (Nat.mul_le_mul_left _ (Finset.card_le_card hsub)) hcount

/-! ## Concrete demo: a 4-bit-seed linear congruential generator -/

/-- One step of the LCG `x ↦ 5x + 3 mod 16`. -/
def lcgStep (x : ℕ) : ℕ := (5 * x + 3) % 16

/-- Eight bits of PRNG output produced from a four-bit seed. -/
def lcgOut (seed : ℕ) : ℕ := lcgStep seed + 16 * lcgStep (lcgStep seed)

/-- The generator reaches at most `16` of the `256` eight-bit values. -/
theorem lcg_image_card_le : ((Finset.range 16).image lcgOut).card ≤ 16 := by
  calc ((Finset.range 16).image lcgOut).card ≤ (Finset.range 16).card := Finset.card_image_le
    _ = 16 := by simp

set_option maxRecDepth 100000 in
/-- Exactly `240` of the `256` eight-bit strings are unreachable: a "random
file" is overwhelmingly likely to have no seed at all. -/
theorem lcg_missing_count :
    ((Finset.range 256).filter (fun v => v ∉ (Finset.range 16).image lcgOut)).card = 240 := by
  decide

/-- A concrete unreachable value. -/
theorem lcg_misses_zero : (0 : ℕ) ∉ (Finset.range 16).image lcgOut := by decide

/-- Conversely, PRNG outputs *are* compressible: each of them is named by a
four-bit seed. -/
theorem lcg_outputs_have_short_names (seed : ℕ) (h : seed < 16) :
    lcgOut seed ∈ (Finset.range 16).image lcgOut :=
  Finset.mem_image.mpr ⟨seed, Finset.mem_range.mpr h, rfl⟩

end PRNGCompression