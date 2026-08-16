/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Counting Core for Lossless Compression: the Pigeonhole Bound

This module develops, from first principles, the counting machinery behind the
classical statement that *no lossless code can shorten all inputs*.  It is the
foundation for the negative result about pseudo-random number generators
(`MachineLearning.PRNGCompressionBound`): a PRNG is just another decompressor,
and every decompressor obeys the bounds proved here.

## Central Idea

A codeword is a finite bit string `List Bool`.  Reading a codeword as a binary
numeral *with a leading `1` prepended* gives an injection
`codeNat : List Bool → ℕ` with `2 ^ len ≤ codeNat l < 2 ^ (len + 1)`.
Hence there are fewer than `2 ^ (k+1)` codewords of length `≤ k`, and any
injective encoding of a set of size `2 ^ n` must use a codeword of length `≥ n`.

## Main Definitions

* `codeNat` — self-delimiting numeric index of a bit string
* `Bits n` — the type of `n`-bit strings, `Fin n → Bool`

## Main Results

* `codeNat_injective` — the numeric index of a bit string determines the string
* `card_short_le` — at most `2 ^ (k+1) - 1` inputs receive a codeword of length `≤ k`
* `exists_long_codeword` — pigeonhole: some `n`-bit string needs `≥ n` code bits
* `card_compressible_le` — at most a `2 ^ (1-d)` fraction of inputs can be
  compressed by `d` bits ("`d` bits of gain costs a factor `2 ^ d` of coverage")
* `card_bits` — `#(Bits n) = 2 ^ n`

## Application Keywords

lossless compression, pigeonhole bound, Kraft inequality, counting argument,
incompressibility, data compression limits
-/

import Mathlib

open Finset

namespace PRNGCompression

/-- The type of `n`-bit strings. -/
abbrev Bits (n : ℕ) : Type := Fin n → Bool

/-- `#(Bits n) = 2 ^ n`. -/
theorem card_bits (n : ℕ) : Fintype.card (Bits n) = 2 ^ n := by
  simp [Bits]

/-- Numeric index of a bit string: read it as a binary numeral with an extra
leading `1`, so that the length is recoverable and the map is injective. -/
def codeNat : List Bool → ℕ
  | [] => 1
  | b :: l => 2 * codeNat l + (if b then 1 else 0)

lemma one_le_codeNat (l : List Bool) : 1 ≤ codeNat l := by
  induction l with
  | nil => simp [codeNat]
  | cons b t ih => simp [codeNat]; omega

/-- A bit string of length `k` gets an index `< 2 ^ (k+1)`. -/
lemma codeNat_lt (l : List Bool) : codeNat l < 2 ^ (l.length + 1) := by
  induction l with
  | nil => simp [codeNat]
  | cons b t ih =>
      have hb : codeNat (b :: t) ≤ 2 * codeNat t + 1 := by
        simp [codeNat]; split <;> omega
      have h2 : (2 : ℕ) ^ (t.length + 1 + 1) = 2 * 2 ^ (t.length + 1) := by ring
      simp only [List.length_cons]
      omega

/-- The numeric index determines the bit string. -/
theorem codeNat_injective : Function.Injective codeNat := by
  intro l
  induction l with
  | nil =>
      intro l' h
      cases l' with
      | nil => rfl
      | cons b t =>
          exfalso
          have := one_le_codeNat t
          simp [codeNat] at h
          split at h <;> omega
  | cons b t ih =>
      intro l' h
      cases l' with
      | nil =>
          exfalso
          have := one_le_codeNat t
          simp [codeNat] at h
          split at h <;> omega
      | cons b' t' =>
          simp only [codeNat] at h
          have hb : b = b' := by
            by_contra hne
            cases b <;> cases b' <;> simp_all <;> omega
          subst hb
          have ht : codeNat t = codeNat t' := by
            cases b <;> simp at h <;> omega
          rw [ih ht]

/-- **Counting bound.**  For an injective code `c`, at most `2 ^ (k+1) - 1`
inputs receive a codeword of length at most `k`. -/
theorem card_short_le {X : Type*} [Fintype X] [DecidableEq X]
    (c : X → List Bool) (hc : Function.Injective c) (k : ℕ) :
    (univ.filter (fun x => (c x).length ≤ k)).card ≤ 2 ^ (k + 1) - 1 := by
  classical
  have key : (univ.filter (fun x => (c x).length ≤ k)).card
      ≤ (Finset.Icc 1 (2 ^ (k + 1) - 1)).card := by
    apply Finset.card_le_card_of_injOn (fun x => codeNat (c x))
    · intro x hx
      have hx2 : (c x).length ≤ k := (Finset.mem_filter.mp hx).2
      have h1 := one_le_codeNat (c x)
      have h2 := codeNat_lt (c x)
      have h3 : (2 : ℕ) ^ ((c x).length + 1) ≤ 2 ^ (k + 1) :=
        Nat.pow_le_pow_right (by norm_num) (by omega)
      simp only [Finset.coe_Icc, Set.mem_Icc]
      omega
    · intro a _ b _ h
      exact hc (codeNat_injective h)
  simpa using key

/-- **Pigeonhole bound.**  Every injective code on `n`-bit strings assigns some
string a codeword of length at least `n`: a "true random file stays at `n` bits". -/
theorem exists_long_codeword (n : ℕ) (c : Bits n → List Bool)
    (hc : Function.Injective c) : ∃ x, n ≤ (c x).length := by
  classical
  rcases Nat.eq_zero_or_pos n with hn | hn
  · subst hn; exact ⟨fun i => i.elim0, Nat.zero_le _⟩
  by_contra h
  push_neg at h
  have hfull : (univ.filter (fun x : Bits n => (c x).length ≤ n - 1)) = univ := by
    apply Finset.filter_true_of_mem
    intro x _
    have := h x; omega
  have hcard := card_short_le c hc (n - 1)
  rw [hfull] at hcard
  have hu : (univ : Finset (Bits n)).card = 2 ^ n := by simp [Bits]
  have h2 : n - 1 + 1 = n := by omega
  rw [hu, h2] at hcard
  have : 0 < 2 ^ n := Nat.two_pow_pos n
  omega

/-- **Quantitative pigeonhole.**  Saving `d` bits costs a factor `2 ^ d` in
coverage: at most a `2 ^ (1 - d)` fraction of all `2 ^ n` strings can be coded
in `n - d` bits.  (Stated multiplicatively to avoid truncated subtraction.) -/
theorem card_compressible_le (n d : ℕ) (c : Bits n → List Bool)
    (hc : Function.Injective c) :
    2 ^ d * (univ.filter (fun x : Bits n => (c x).length + d ≤ n)).card ≤ 2 ^ (n + 1) := by
  classical
  by_cases hd : d ≤ n
  · have hsub : (univ.filter (fun x : Bits n => (c x).length + d ≤ n))
        ⊆ (univ.filter (fun x : Bits n => (c x).length ≤ n - d)) := by
      intro x hx
      have := (Finset.mem_filter.mp hx).2
      exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, by omega⟩
    have h1 := Finset.card_le_card hsub
    have h2 := card_short_le c hc (n - d)
    have h3 : (2 : ℕ) ^ d * (2 ^ (n - d + 1) - 1) ≤ 2 ^ (n + 1) := by
      have hpow : (2 : ℕ) ^ d * 2 ^ (n - d + 1) = 2 ^ (n + 1) := by
        rw [← pow_add]
        congr 1
        omega
      calc (2 : ℕ) ^ d * (2 ^ (n - d + 1) - 1) ≤ 2 ^ d * 2 ^ (n - d + 1) :=
            Nat.mul_le_mul_left _ (Nat.sub_le _ _)
        _ = 2 ^ (n + 1) := hpow
    calc 2 ^ d * (univ.filter (fun x : Bits n => (c x).length + d ≤ n)).card
        ≤ 2 ^ d * (2 ^ (n - d + 1) - 1) := Nat.mul_le_mul_left _ (le_trans h1 h2)
      _ ≤ 2 ^ (n + 1) := h3
  · have hempty : (univ.filter (fun x : Bits n => (c x).length + d ≤ n)) = ∅ := by
      apply Finset.filter_false_of_mem
      intro x _
      omega
    simp [hempty]

end PRNGCompression