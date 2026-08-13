import Mathlib

/-!
# Round-7 closure AGREEMENT: barrier-2-invariant character aggregates collapse

This file formalises experiment 325 of the round-7 batch.  For a semiprime
`N = p q` the **agreement set**

`A(N) = { a ∈ (ℤ/Nℤ)ˣ : (a/p) = (a/q) }`

is invariant under both barrier-2 symmetries (the swap `p ↔ q` and conjugation),
so it was a candidate for a factor-revealing aggregate that escapes the
residue/order classification.  It does not:

* `agree_card_two_mul` : `2 · |A(N)| = φ(N)`, i.e. `A(N) = φ(N)/2` exactly, for
  every semiprime with an odd prime factor — the count is a *function of `N`
  alone* (through `φ(N)`), hence carries no information about `p` and `q`;
* `mem_agree_iff_jacobiSym` : the agreement set *is* the set where the
  `N`-computable Jacobi symbol `J(a | N)` equals `1`, so the aggregate collapses
  onto the quadratic character mod `N` by character orthogonality.

The proof is a pairing argument: an element `u` that is a non-residue mod `p`
and `≡ 1 (mod q)` (produced by CRT) translates the agreement set bijectively
onto its complement.
-/

namespace Round7Agreement

open Finset

variable {p q : ℕ}

section Chars

variable [Fact p.Prime] [Fact q.Prime]

/-- Reduction `ℤ/pqℤ → ℤ/pℤ`. -/
def redP (p q : ℕ) : ZMod (p * q) →+* ZMod p := ZMod.castHom ⟨q, rfl⟩ (ZMod p)

/-- Reduction `ℤ/pqℤ → ℤ/qℤ`. -/
def redQ (p q : ℕ) : ZMod (p * q) →+* ZMod q := ZMod.castHom ⟨p, mul_comm p q⟩ (ZMod q)

/-- The Legendre character mod `p`, read on the units of `ℤ/pqℤ`. -/
noncomputable def chiP (p q : ℕ) [Fact p.Prime] (a : (ZMod (p * q))ˣ) : ℤ :=
  quadraticChar (ZMod p) (redP p q (a : ZMod (p * q)))

/-- The Legendre character mod `q`, read on the units of `ℤ/pqℤ`. -/
noncomputable def chiQ (p q : ℕ) [Fact q.Prime] (a : (ZMod (p * q))ˣ) : ℤ :=
  quadraticChar (ZMod q) (redQ p q (a : ZMod (p * q)))

omit [Fact q.Prime] in
theorem redP_ne_zero (a : (ZMod (p * q))ˣ) : redP p q (a : ZMod (p * q)) ≠ 0 :=
  (a.isUnit.map (redP p q)).ne_zero

omit [Fact p.Prime] in
theorem redQ_ne_zero (a : (ZMod (p * q))ˣ) : redQ p q (a : ZMod (p * q)) ≠ 0 :=
  (a.isUnit.map (redQ p q)).ne_zero

omit [Fact q.Prime] in
theorem chiP_mul (a b : (ZMod (p * q))ˣ) : chiP p q (a * b) = chiP p q a * chiP p q b := by
  simp [chiP, Units.val_mul, map_mul]

omit [Fact p.Prime] in
theorem chiQ_mul (a b : (ZMod (p * q))ˣ) : chiQ p q (a * b) = chiQ p q a * chiQ p q b := by
  simp [chiQ, Units.val_mul, map_mul]

omit [Fact q.Prime] in
theorem chiP_one : chiP p q 1 = 1 := by simp [chiP]

omit [Fact p.Prime] in
theorem chiQ_one : chiQ p q 1 = 1 := by simp [chiQ]

omit [Fact q.Prime] in
theorem chiP_dichotomy (a : (ZMod (p * q))ˣ) : chiP p q a = 1 ∨ chiP p q a = -1 :=
  quadraticChar_dichotomy (redP_ne_zero a)

omit [Fact p.Prime] in
theorem chiQ_dichotomy (a : (ZMod (p * q))ˣ) : chiQ p q a = 1 ∨ chiQ p q a = -1 :=
  quadraticChar_dichotomy (redQ_ne_zero a)

/-! ## The agreement set -/

/-- The agreement set `A(N) = {a : (a/p) = (a/q)}`. -/
noncomputable def agree (p q : ℕ) [Fact p.Prime] [Fact q.Prime] :
    Finset ((ZMod (p * q))ˣ) :=
  Finset.univ.filter (fun a => chiP p q a = chiQ p q a)

theorem mem_agree {a : (ZMod (p * q))ˣ} : a ∈ agree p q ↔ chiP p q a = chiQ p q a := by
  simp [agree]

end Chars

/-! ## A CRT witness: non-residue mod `p`, trivial mod `q` -/

section Witness

variable [Fact p.Prime] [Fact q.Prime]

/-- **The flipping unit.** If `p` is an odd prime and `q ≠ p` is a prime, there
is a unit of `ℤ/pqℤ` which is a non-residue mod `p` and a square (indeed `1`)
mod `q`.  This is the CRT witness that translates agreement into disagreement. -/
theorem exists_flip (hp2 : p ≠ 2) (hpq : p ≠ q) :
    ∃ u : (ZMod (p * q))ˣ, chiP p q u = -1 ∧ chiQ p q u = 1 := by
  classical
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  -- a non-residue mod `p`
  obtain ⟨y, hy⟩ : ∃ y : ZMod p, quadraticChar (ZMod p) y = -1 := by
    refine quadraticChar_exists_neg_one ?_
    rw [ZMod.ringChar_zmod_n]
    exact hp2
  have hy0 : y ≠ 0 := by
    intro h
    rw [h, quadraticChar_zero] at hy
    exact absurd hy (by norm_num)
  -- CRT: a natural number `k` with `k ≡ y (mod p)` and `k ≡ 1 (mod q)`
  obtain ⟨k, hk1, hk2⟩ := Nat.chineseRemainder hcop y.val 1
  haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.pos.ne' hq.pos.ne'⟩
  have hkp : ((k : ℕ) : ZMod p) = y := by
    have : ((k : ℕ) : ZMod p) = ((y.val : ℕ) : ZMod p) :=
      (ZMod.natCast_eq_natCast_iff _ _ _).mpr hk1
    rw [this, ZMod.natCast_val, ZMod.cast_id]
  have hkq : ((k : ℕ) : ZMod q) = 1 := by
    have : ((k : ℕ) : ZMod q) = ((1 : ℕ) : ZMod q) :=
      (ZMod.natCast_eq_natCast_iff _ _ _).mpr hk2
    rw [this, Nat.cast_one]
  -- `k` is coprime to `pq`
  have hkcop : Nat.Coprime k (p * q) := by
    refine Nat.Coprime.mul_right ?_ ?_
    · rw [Nat.coprime_comm]
      refine (Nat.Prime.coprime_iff_not_dvd hp).mpr ?_
      intro hdvd
      apply hy0
      rw [← hkp]
      exact (ZMod.natCast_eq_zero_iff k p).mpr hdvd
    · rw [Nat.coprime_comm]
      refine (Nat.Prime.coprime_iff_not_dvd hq).mpr ?_
      intro hdvd
      have : ((k : ℕ) : ZMod q) = 0 := (ZMod.natCast_eq_zero_iff k q).mpr hdvd
      rw [hkq] at this
      exact one_ne_zero this
  have hunit : IsUnit ((k : ℕ) : ZMod (p * q)) := (ZMod.isUnit_iff_coprime k (p * q)).mpr hkcop
  refine ⟨hunit.unit, ?_, ?_⟩
  · rw [chiP, IsUnit.unit_spec, map_natCast, hkp, hy]
  · rw [chiQ, IsUnit.unit_spec, map_natCast, hkq, MulChar.map_one]

end Witness

/-! ## The count -/

section Count

variable [Fact p.Prime] [Fact q.Prime]

/-- Multiplying by a flipping unit exchanges agreement and disagreement. -/
theorem mem_agree_mul_flip {u : (ZMod (p * q))ˣ} (hu : chiP p q u = -1) (hu' : chiQ p q u = 1)
    (a : (ZMod (p * q))ˣ) : (a * u ∈ agree p q) ↔ a ∉ agree p q := by
  simp only [mem_agree, chiP_mul, chiQ_mul, hu, hu']
  rcases chiP_dichotomy (p := p) (q := q) a with h1 | h1 <;>
    rcases chiQ_dichotomy (p := p) (q := q) a with h2 | h2 <;>
      simp [h1, h2]

/-- **AGREEMENT collapses.** For a semiprime `N = pq` with `p` an odd prime and
`q ≠ p` prime, the agreement set has exactly `φ(N)/2` elements. -/
theorem agree_card_two_mul (hp2 : p ≠ 2) (hpq : p ≠ q) :
    2 * (agree p q).card = Nat.totient (p * q) := by
  classical
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.pos.ne' hq.pos.ne'⟩
  obtain ⟨u, hu, hu'⟩ := exists_flip hp2 hpq
  have hcard : (agree p q).card = (agree p q)ᶜ.card := by
    refine Finset.card_equiv (Equiv.mulRight u) (fun a => ?_)
    simp only [Equiv.coe_mulRight, Finset.mem_compl, mem_agree_mul_flip hu hu', not_not]
  have hsum : (agree p q).card + (agree p q)ᶜ.card = Fintype.card ((ZMod (p * q))ˣ) :=
    Finset.card_add_card_compl _
  rw [← ZMod.card_units_eq_totient, ← hsum, ← hcard]
  ring

/-- The explicit value: `|A(N)| = (p-1)(q-1)/2`. -/
theorem agree_card_eq (hp2 : p ≠ 2) (hpq : p ≠ q) :
    2 * (agree p q).card = (p - 1) * (q - 1) := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  rw [agree_card_two_mul hp2 hpq, Nat.totient_mul hcop, Nat.totient_prime hp,
    Nat.totient_prime hq]

end Count

/-! ## The collapse onto the Jacobi symbol -/

section Jacobi

variable [Fact p.Prime] [Fact q.Prime]

theorem chiP_eq_legendreSym (a : (ZMod (p * q))ˣ) :
    chiP p q a = legendreSym p ((a : ZMod (p * q)).val : ℤ) := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.pos.ne' hq.pos.ne'⟩
  rw [legendreSym, chiP]
  congr 1
  rw [Int.cast_natCast, ← map_natCast (redP p q) (a : ZMod (p * q)).val,
    ZMod.natCast_zmod_val]

theorem chiQ_eq_legendreSym (a : (ZMod (p * q))ˣ) :
    chiQ p q a = legendreSym q ((a : ZMod (p * q)).val : ℤ) := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.pos.ne' hq.pos.ne'⟩
  rw [legendreSym, chiQ]
  congr 1
  rw [Int.cast_natCast, ← map_natCast (redQ p q) (a : ZMod (p * q)).val,
    ZMod.natCast_zmod_val]

/-- **The aggregate is `N`-computable.** Agreement holds exactly when the Jacobi
symbol `J(a | N)` — a quantity computable from `N` alone — equals `1`. -/
theorem mem_agree_iff_jacobiSym (a : (ZMod (p * q))ˣ) :
    a ∈ agree p q ↔ jacobiSym ((a : ZMod (p * q)).val : ℤ) (p * q) = 1 := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  have hjac : jacobiSym ((a : ZMod (p * q)).val : ℤ) (p * q) = chiP p q a * chiQ p q a := by
    rw [jacobiSym.mul_right, chiP_eq_legendreSym, chiQ_eq_legendreSym,
      jacobiSym.legendreSym.to_jacobiSym, jacobiSym.legendreSym.to_jacobiSym]
  rw [mem_agree, hjac]
  rcases chiP_dichotomy (p := p) (q := q) a with h1 | h1 <;>
    rcases chiQ_dichotomy (p := p) (q := q) a with h2 | h2 <;>
      simp [h1, h2]

end Jacobi

end Round7Agreement