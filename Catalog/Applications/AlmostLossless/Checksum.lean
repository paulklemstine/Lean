/-
# Almost-lossless compression V: parity checksums — failures are never silent

`Applications.AlmostLossless.Core` guarantees soundness for *undamaged* codewords.
A transmission channel, however, may flip bits, and a decoder that then returns a
wrong source would be a *silent* corruption — the failure mode the gate of this
research thread forbids.

This file adds a one-bit parity checksum on top of an arbitrary code and proves:

* `AlmostLossless.parity_concat` — the augmented word always has even parity.
* `AlmostLossless.parity_set_not` — flipping any single bit flips the parity.
* `AlmostLossless.withParity_detects_single_flip` — **any single-bit channel
  corruption is detected**: the decoder returns `none`, never a wrong source.
* `AlmostLossless.withParity_sound`, `AlmostLossless.goodSet_withParity`,
  `AlmostLossless.withParity_failProb` — the checksum costs exactly one bit and
  changes neither the good set nor the failure probability.
* `AlmostLossless.withParity_cost` — checking the parity costs one step per
  received bit, so decoding stays linear: `2k + 6` steps at rate `k`.
-/
import Mathlib
import Applications.AlmostLossless.Complexity

namespace AlmostLossless

open Finset

/-! ## Parity -/

/-- The parity (XOR) of a bit string. -/
def parity (l : List Bool) : Bool := l.foldr xor false

@[simp] theorem parity_nil : parity [] = false := rfl

@[simp] theorem parity_cons (b : Bool) (l : List Bool) :
    parity (b :: l) = xor b (parity l) := rfl

theorem parity_append (l₁ l₂ : List Bool) :
    parity (l₁ ++ l₂) = xor (parity l₁) (parity l₂) := by
  induction l₁ with
  | nil => simp
  | cons b l ih => simp [ih]

/-- Appending the parity bit makes the parity of the whole word `false`. -/
@[simp] theorem parity_concat (l : List Bool) : parity (l ++ [parity l]) = false := by
  rw [parity_append]
  simp [parity]

/-- **Flipping one bit flips the parity.** -/
theorem parity_set_not : ∀ (l : List Bool) (i : ℕ) (h : i < l.length),
    parity (l.set i (!(l.get ⟨i, h⟩))) = !(parity l) := by
  intro l
  induction l with
  | nil => intro i h; simp at h
  | cons b t ih =>
      intro i h
      cases i with
      | zero => simp
      | succ j =>
          have hj : j < t.length := by simpa using h
          have hstep : parity (t.set j (!t[j])) = !(parity t) := ih j hj
          simp only [List.set_cons_succ, parity_cons, List.get_eq_getElem,
            List.getElem_cons_succ, hstep]
          cases b <;> cases parity t <;> rfl

/-! ## The checksummed code -/

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Append a parity bit to every codeword; on reception, reject any word of odd
parity. -/
def withParity (c : Code α) : Code α where
  enc x := c.enc x ++ [parity (c.enc x)]
  dec w := if parity w then none else c.dec w.dropLast

omit [Fintype α] [DecidableEq α] in
@[simp] theorem withParity_dec_enc (c : Code α) (x : α) :
    (withParity c).dec ((withParity c).enc x) = c.dec (c.enc x) := by
  show (if parity (c.enc x ++ [parity (c.enc x)]) then none
    else c.dec (c.enc x ++ [parity (c.enc x)]).dropLast) = _
  rw [parity_concat]
  simp

omit [Fintype α] [DecidableEq α] in
/-- The checksum preserves soundness. -/
theorem withParity_sound {c : Code α} (hs : Sound c) : Sound (withParity c) := by
  intro x y hxy
  rw [withParity_dec_enc] at hxy
  exact hs x y hxy

/-- The checksum changes neither the set of decodable sources … -/
theorem goodSet_withParity (c : Code α) : goodSet (withParity c) = goodSet c := by
  ext x
  simp [mem_goodSet, Decodes]

/-- … nor the failure probability. -/
theorem withParity_failProb (p : α → ℝ) (c : Code α) :
    failProb p (withParity c) = failProb p c := by
  rw [failProb, failProb, goodSet_withParity]

omit [Fintype α] [DecidableEq α] in
/-- The checksum costs exactly one bit. -/
theorem withParity_lengthBound {c : Code α} {t : ℕ} (ht : LengthBound c t) :
    LengthBound (withParity c) (t + 1) := by
  intro x
  show (c.enc x ++ [parity (c.enc x)]).length ≤ t + 1
  simpa using Nat.succ_le_succ (ht x)

omit [Fintype α] [DecidableEq α] in
/-- **No silent corruption on the channel.**  If a single bit of a transmitted
codeword is flipped, the decoder reports failure — it never returns a source. -/
theorem withParity_detects_single_flip (c : Code α) (x : α) (i : ℕ)
    (h : i < ((withParity c).enc x).length) :
    (withParity c).dec (((withParity c).enc x).set i
      (!(((withParity c).enc x).get ⟨i, h⟩))) = none := by
  set w : List Bool := (withParity c).enc x with hw
  have hpar : parity w = false := by
    rw [hw]
    exact parity_concat (c.enc x)
  have hflip : parity (w.set i (!(w.get ⟨i, h⟩))) = !(parity w) := parity_set_not w i h
  rw [hpar] at hflip
  show (if parity (w.set i (!(w.get ⟨i, h⟩))) then none
    else c.dec (w.set i (!(w.get ⟨i, h⟩))).dropLast) = none
  rw [hflip]
  simp

/-! ## Cost of the checksum -/

/-- Step-counting parity check: one step per received bit. -/
def parityI : List Bool → Bool × ℕ
  | [] => (false, 0)
  | b :: l => (xor b (parityI l).1, (parityI l).2 + 1)

@[simp] theorem parityI_fst (l : List Bool) : (parityI l).1 = parity l := by
  induction l with
  | nil => simp [parityI]
  | cons b l ih => simp [parityI, ih]

@[simp] theorem parityI_snd (l : List Bool) : (parityI l).2 = l.length := by
  induction l with
  | nil => simp [parityI]
  | cons b l ih => simp [parityI, ih]

omit [Fintype α] in
/-- **Total decoding cost of the checksummed enumerative scheme.**  Verifying the
checksum costs `k + 2` steps (one per received bit) and the enumerative decode a
further `k + 2`, so the complete decoder — checksum included — still runs in
`2k + 4 ≤ 2k + 6` steps, linear in the rate, versus `2 ^ k` for exhaustive
codebook search. -/
theorem withParity_cost {S : Finset α} {k : ℕ} (hcard : S.card ≤ 2 ^ k) {x : α} (hx : x ∈ S) :
    (parityI ((withParity (enumCode S k)).enc x)).2
      + (enumDecI S ((enumCode S k).enc x)).2 = 2 * k + 4 := by
  have hlen : ((withParity (enumCode S k)).enc x).length = k + 2 := by
    show ((enumCode S k).enc x ++ [parity ((enumCode S k).enc x)]).length = k + 2
    rw [enumCode_enc_mem hx]
    simp
  rw [parityI_snd, hlen, enumDecI_cost_enc hcard hx]
  ring

end AlmostLossless