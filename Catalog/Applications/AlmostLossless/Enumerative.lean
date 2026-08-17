/-
# Almost-lossless compression II: an explicit ε-almost-lossless scheme

This file supplies the *achievability* half of the thread.  Given a "typical set"
`S` of sources carrying probability mass `≥ 1 - ε`, the **enumerative code**
`AlmostLossless.enumCode S k` transmits

* one flag bit (`true` = "the source was in the typical set"), followed by
* the `k`-bit index of the source inside `S`,

and transmits the single bit `[false]` — an explicit *failure marker* — otherwise.
The decoder is a partial function that returns `none` exactly on the atypical
sources, so **failures are never silent**.

## Main definitions

* `AlmostLossless.toBits`, `AlmostLossless.fromBits` — `k`-bit binary index codec.
* `AlmostLossless.enumCode` — the scheme.

## Main results

* `AlmostLossless.fromBits_toBits` — the codec is correct below `2 ^ k`.
* `AlmostLossless.enumCode_sound` — no silent corruption.
* `AlmostLossless.enumCode_detects_failure` — atypical sources are *detected*.
* `AlmostLossless.goodSet_enumCode` — the good set is exactly `S`.
* `AlmostLossless.enumCode_failProb` — the failure probability is the mass of the
  atypical set.
* `AlmostLossless.achievability` — **the scheme**: mass `≥ 1 - ε` on a set of size
  `≤ 2 ^ k` yields a sound code of length `k + 1` failing with probability `≤ ε`.
* `AlmostLossless.uniform_achievability` — for the uniform source, rate
  `k + 1` bits suffice whenever `(1 - ε) * N ≤ 2 ^ k`, matching the converse
  `Core.uniform_rate_bound` to within two bits.
-/
import Mathlib
import Applications.AlmostLossless.Core

namespace AlmostLossless

open Finset

/-! ## A `k`-bit index codec -/

/-- `toBits k n` is the little-endian `k`-bit binary expansion of `n`. -/
def toBits : ℕ → ℕ → List Bool
  | 0, _ => []
  | k + 1, n => (decide (n % 2 = 1)) :: toBits k (n / 2)

/-- `fromBits` reads a little-endian bit list as a natural number. -/
def fromBits : List Bool → ℕ
  | [] => 0
  | b :: l => (if b then 1 else 0) + 2 * fromBits l

@[simp] theorem length_toBits (k n : ℕ) : (toBits k n).length = k := by
  induction k generalizing n with
  | zero => simp [toBits]
  | succ k ih => simp [toBits, ih]

/-- The codec is correct on indices below `2 ^ k`. -/
theorem fromBits_toBits : ∀ (k n : ℕ), n < 2 ^ k → fromBits (toBits k n) = n := by
  intro k
  induction k with
  | zero => intro n hn; simpa [toBits, fromBits] using (Nat.lt_one_iff.mp (by simpa using hn)).symm
  | succ k ih =>
      intro n hn
      have hhalf : n / 2 < 2 ^ k := by
        have : n < 2 * 2 ^ k := by simpa [pow_succ, Nat.mul_comm] using hn
        omega
      have hrec := ih (n / 2) hhalf
      simp only [toBits, fromBits, hrec]
      rcases Nat.even_or_odd n with he | ho
      · have h0 : n % 2 = 0 := Nat.even_iff.mp he
        simp [h0]
        omega
      · have h1 : n % 2 = 1 := Nat.odd_iff.mp ho
        simp [h1]
        omega

/-! ## The enumerative scheme -/

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- **The enumerative ε-almost-lossless code.**  Sources inside the typical set `S`
are sent as `true :: (k-bit index in S)`; every other source is sent as the
one-bit failure marker `[false]`, which the decoder maps to `none`. -/
noncomputable def enumCode (S : Finset α) (k : ℕ) : Code α where
  enc x := if h : x ∈ S then true :: toBits k ((S.equivFin ⟨x, h⟩ : Fin S.card) : ℕ)
    else false :: toBits k 0
  dec l := match l with
    | [] => none
    | false :: _ => none
    | true :: rest =>
        if h : fromBits rest < S.card then
          some ((S.equivFin.symm ⟨fromBits rest, h⟩ : S) : α)
        else none

omit [Fintype α] in
theorem enumCode_enc_mem {S : Finset α} {k : ℕ} {x : α} (h : x ∈ S) :
    (enumCode S k).enc x = true :: toBits k ((S.equivFin ⟨x, h⟩ : Fin S.card) : ℕ) := by
  simp [enumCode, h]

omit [Fintype α] in
theorem enumCode_enc_not_mem {S : Finset α} {k : ℕ} {x : α} (h : x ∉ S) :
    (enumCode S k).enc x = false :: toBits k 0 := by
  simp [enumCode, h]

omit [Fintype α] in
/-- All codewords have exactly the same length `k + 1`; the scheme is a fixed-rate
code, which is what makes block composition parse-free. -/
theorem enumCode_length_eq (S : Finset α) (k : ℕ) (x : α) :
    ((enumCode S k).enc x).length = k + 1 := by
  by_cases h : x ∈ S
  · rw [enumCode_enc_mem h]; simp
  · rw [enumCode_enc_not_mem h]; simp

omit [Fintype α] in
/-- Every typical source is decoded correctly. -/
theorem enumCode_decodes {S : Finset α} {k : ℕ} (hcard : S.card ≤ 2 ^ k) {x : α} (h : x ∈ S) :
    (enumCode S k).dec ((enumCode S k).enc x) = some x := by
  have hlt : ((S.equivFin ⟨x, h⟩ : Fin S.card) : ℕ) < S.card := (S.equivFin ⟨x, h⟩).isLt
  have hlt' : ((S.equivFin ⟨x, h⟩ : Fin S.card) : ℕ) < 2 ^ k := lt_of_lt_of_le hlt hcard
  rw [enumCode_enc_mem h]
  show (if hh : fromBits (toBits k _) < S.card then
      some ((S.equivFin.symm ⟨fromBits (toBits k _), hh⟩ : S) : α) else none) = some x
  rw [dif_pos (by rw [fromBits_toBits _ _ hlt']; exact hlt)]
  congr 1
  have : (⟨fromBits (toBits k ((S.equivFin ⟨x, h⟩ : Fin S.card) : ℕ)),
      by rw [fromBits_toBits _ _ hlt']; exact hlt⟩ : Fin S.card) = S.equivFin ⟨x, h⟩ := by
    apply Fin.ext
    simpa using fromBits_toBits k _ hlt'
  rw [this, Equiv.symm_apply_apply]

omit [Fintype α] in
/-- **Explicit error detection.**  On an atypical source the decoder returns `none`:
the failure is reported, never silently mis-decoded. -/
theorem enumCode_detects_failure {S : Finset α} {k : ℕ} {x : α} (h : x ∉ S) :
    (enumCode S k).dec ((enumCode S k).enc x) = none := by
  rw [enumCode_enc_not_mem h]
  rfl

omit [Fintype α] in
/-- **No silent corruption.**  Whenever the decoder answers, the answer is correct. -/
theorem enumCode_sound (S : Finset α) (k : ℕ) (hcard : S.card ≤ 2 ^ k) :
    Sound (enumCode S k) := by
  intro x y hxy
  by_cases h : x ∈ S
  · rw [enumCode_decodes hcard h] at hxy
    exact (Option.some_inj.mp hxy).symm
  · rw [enumCode_detects_failure h] at hxy
    exact absurd hxy (by simp)

/-- The good set of the enumerative code is exactly the typical set. -/
theorem goodSet_enumCode (S : Finset α) (k : ℕ) (hcard : S.card ≤ 2 ^ k) :
    goodSet (enumCode S k) = S := by
  ext x
  rw [mem_goodSet]
  constructor
  · intro hx
    by_contra hnot
    rw [Decodes, enumCode_detects_failure hnot] at hx
    exact absurd hx (by simp)
  · intro hx
    exact enumCode_decodes hcard hx

omit [Fintype α] in
/-- Codewords are at most `k + 1` bits long. -/
theorem enumCode_lengthBound (S : Finset α) (k : ℕ) : LengthBound (enumCode S k) (k + 1) :=
  fun x => le_of_eq (enumCode_length_eq S k x)

/-- The failure probability is exactly the mass of the atypical set. -/
theorem enumCode_failProb (p : α → ℝ) (S : Finset α) (k : ℕ) (hcard : S.card ≤ 2 ^ k) :
    failProb p (enumCode S k) = ∑ x ∈ univ \ S, p x := by
  rw [failProb, goodSet_enumCode S k hcard]

/-! ## Achievability -/

/-- **The scheme, with its guarantee.**  If the typical set `S` carries mass at
least `1 - ε` and has at most `2 ^ k` elements, then there is a code which

* is sound (never corrupts silently),
* uses at most `k + 1` bits on every source,
* decodes correctly with probability at least `1 - ε`, and
* explicitly reports `none` on every source it cannot decode. -/
theorem achievability {p : α → ℝ} (hsum : ∑ x, p x = 1) (S : Finset α) (k : ℕ)
    (hcard : S.card ≤ 2 ^ k) {ε : ℝ} (hmass : 1 - ε ≤ ∑ x ∈ S, p x) :
    ∃ c : Code α, Sound c ∧ LengthBound c (k + 1) ∧ failProb p c ≤ ε ∧ goodSet c = S ∧
      (∀ x ∉ S, c.dec (c.enc x) = none) := by
  refine ⟨enumCode S k, enumCode_sound S k hcard, enumCode_lengthBound S k, ?_,
    goodSet_enumCode S k hcard, fun x hx => enumCode_detects_failure hx⟩
  have hmg : ∑ x ∈ goodSet (enumCode S k), p x = 1 - failProb p (enumCode S k) :=
    mass_goodSet hsum _
  rw [goodSet_enumCode S k hcard] at hmg
  linarith

/-- **Uniform source achievability.**  For the uniform distribution on `N = #α`
symbols and any `k` with `2 ^ k ≤ N`, discarding the `N - 2 ^ k` least useful
symbols gives a sound code of length `k + 1` whose failure probability is
`1 - 2 ^ k / N`.  Together with `uniform_rate_bound` this pins the optimal rate
to within two bits. -/
theorem uniform_achievability (k : ℕ) (hk : 2 ^ k ≤ Fintype.card α) (hcard : 0 < Fintype.card α) :
    ∃ c : Code α, Sound c ∧ LengthBound c (k + 1) ∧
      failProb (fun _ => (Fintype.card α : ℝ)⁻¹) c = 1 - 2 ^ k / (Fintype.card α : ℝ) := by
  obtain ⟨S, -, hScard⟩ := Finset.exists_subset_card_eq (s := (univ : Finset α))
    (n := 2 ^ k) (by simpa [Finset.card_univ] using hk)
  have hle : S.card ≤ 2 ^ k := le_of_eq hScard
  set N : ℝ := (Fintype.card α : ℝ) with hN
  have hNpos : 0 < N := by rw [hN]; exact_mod_cast hcard
  refine ⟨enumCode S k, enumCode_sound S k hle, enumCode_lengthBound S k, ?_⟩
  have hsum : ∑ _x : α, (N : ℝ)⁻¹ = 1 := by
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, hN]
    field_simp
  have hmg : ∑ x ∈ goodSet (enumCode S k), (N : ℝ)⁻¹
      = 1 - failProb (fun _ => (N : ℝ)⁻¹) (enumCode S k) := mass_goodSet hsum _
  rw [goodSet_enumCode S k hle, Finset.sum_const, nsmul_eq_mul, hScard] at hmg
  rw [show ((2 ^ k : ℕ) : ℝ) * (N : ℝ)⁻¹ = 2 ^ k / N by push_cast; ring] at hmg
  linarith

end AlmostLossless