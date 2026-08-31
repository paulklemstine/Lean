import Mathlib

/-!
# Where the residual dial signal comes from: exact equidistribution of the small-prime
# quadratic-residue pattern

## Research context (FACT round-70 #1, exp 545, `TDIAL-U112-CONTINUES-FADE`)

The U112 record (see `Novelty.TDialU112FadeReacceleration` for the statistical layer) reports a
pooled Spearman correlation of `0.462` between the dial statistic `T` and a downstream rate,
below the `0.55` band floor, and comments that "the residual `≈ 0.46` correlation is still far
above chance, so the small-prime QR pattern carries real per-`N` signal at bitlen 112".

Every earlier file in the thread treats the dial as an opaque real number attached to a run.
This file supplies the *arithmetic* layer that the sentence above presupposes: it proves, from
scratch, that the small-prime quadratic-residue pattern of a uniformly drawn integer is an
exactly equidistributed family of independent fair bits, so the dial is a genuinely
informative statistic of `N` at every bit length — a fact about `ℤ`, not about the experiment.

The point is a separation of concerns.  What fades with bit length is the *coupling* between
the dial and the downstream rate; the dial's own information content does **not** fade, and
this file computes it exactly.

## Main results

* `two_mul_card_qrSet` — for an odd prime `p`, exactly `(p−1)/2` nonzero residues are squares
  (stated as `2 · |QR(p)| = p − 1`, avoiding truncated division).  Proved from the vanishing
  of the quadratic-character sum.
* `two_mul_card_nqrSet` — the same count for the non-residues.
* `card_filter_crt` — **CRT independence in counting form**: for coprime moduli, the number of
  `x mod mn` whose two reductions satisfy prescribed conditions is the product of the two
  separate counts.  This is the precise sense in which the residue bits at distinct primes are
  independent.
* `card_pattern_SS`, `card_pattern_SN`, `card_pattern_NS`, `card_pattern_NN` — hence each of
  the four QR patterns at two distinct odd primes occurs exactly `(p−1)(q−1)/4` times.
* `qrDial_binomial` — the two-prime dial `T ∈ {0, 1, 2}` therefore has the exact
  `Binomial(2, 1/2)` law: `4·|T = 0| = 2·|T = 1| = 4·|T = 2| = (p−1)(q−1)`.
* `qrDial_takes_all_values` — all three levels are attained, so the dial is a nonconstant
  statistic on the unit part.
* `two_mul_dial_variance` — the exact second moment: `2 ∑ (T − 1)² = |units|`, i.e. the dial
  has variance exactly `1/2` — independent of the primes and hence of the bit length.

## Lab notes (exp 545, arithmetic layer)

```
p = 3,  q = 5 : |QR(3)| = 1, |QR(5)| = 2, pattern counts 2,2,2,2, dial law 2:4:2
p = 7,  q = 11: |QR(7)| = 3, |QR(11)| = 5, pattern counts 15 each, dial law 15:30:15
dial mean     : 1                       dial variance : 1/2   (all primes, all bitlens)
```
-/

open Finset
open scoped Classical

namespace Catalog.Novelty.TDialU112QuadraticResidueSignal

/-! ## 1. The residue count at a single small prime -/

/-- The nonzero quadratic residues mod `m`. -/
def qrSet (m : ℕ) [NeZero m] : Finset (ZMod m) :=
  univ.filter (fun a : ZMod m => a ≠ 0 ∧ IsSquare a)

/-- The quadratic non-residues mod `m`. -/
def nqrSet (m : ℕ) [NeZero m] : Finset (ZMod m) :=
  univ.filter (fun a : ZMod m => a ≠ 0 ∧ ¬ IsSquare a)

lemma card_qrSet_add_card_nqrSet (p : ℕ) [Fact p.Prime] :
    (qrSet p).card + (nqrSet p).card = p - 1 := by
  have hS : Finset.filter (fun a : ZMod p => IsSquare a)
        (univ.filter (fun a : ZMod p => a ≠ 0)) = qrSet p := Finset.filter_filter _ _ _
  have hN : Finset.filter (fun a : ZMod p => ¬ IsSquare a)
        (univ.filter (fun a : ZMod p => a ≠ 0)) = nqrSet p := Finset.filter_filter _ _ _
  rw [← hS, ← hN, Finset.card_filter_add_card_filter_not]
  have hE : (univ.filter (fun a : ZMod p => a ≠ 0)) = univ.erase (0 : ZMod p) := by
    ext a; simp [Finset.mem_erase]
  rw [hE, Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ, ZMod.card]

/-- **Exactly half of the nonzero residues are squares.**  For an odd prime `p`,
`2 · |QR(p)| = p − 1`.  The proof runs through the vanishing of the quadratic character sum,
so it uses the multiplicative structure of `(ZMod p)ˣ`, not a counting bijection. -/
theorem two_mul_card_qrSet (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    2 * (qrSet p).card = p - 1 := by
  have hchar : ringChar (ZMod p) ≠ 2 := by rw [ZMod.ringChar_zmod_n]; exact hp
  have h0 : ∑ a : ZMod p, quadraticChar (ZMod p) a = 0 := quadraticChar_sum_zero hchar
  have hne : ∑ a ∈ univ.filter (fun a : ZMod p => a ≠ 0), quadraticChar (ZMod p) a = 0 := by
    rw [← h0]
    refine Finset.sum_subset (f := fun a : ZMod p => quadraticChar (ZMod p) a)
      (Finset.filter_subset (fun a : ZMod p => a ≠ 0) univ) ?_
    intro x _ hx
    simp only [mem_filter, mem_univ, true_and, not_not] at hx
    simp [hx]
  have hsplit := Finset.sum_filter_add_sum_filter_not
    (univ.filter (fun a : ZMod p => a ≠ 0)) (fun a : ZMod p => IsSquare a)
    (quadraticChar (ZMod p))
  have hS : Finset.filter (fun a : ZMod p => IsSquare a)
        (univ.filter (fun a : ZMod p => a ≠ 0)) = qrSet p := Finset.filter_filter _ _ _
  have hN : Finset.filter (fun a : ZMod p => ¬ IsSquare a)
        (univ.filter (fun a : ZMod p => a ≠ 0)) = nqrSet p := Finset.filter_filter _ _ _
  have hsum1 : ∑ a ∈ qrSet p, quadraticChar (ZMod p) a = ((qrSet p).card : ℤ) := by
    rw [Finset.sum_congr rfl (fun a ha => ?_), Finset.sum_const, nsmul_eq_mul, mul_one]
    simp only [qrSet, mem_filter] at ha
    exact (quadraticChar_one_iff_isSquare ha.2.1).mpr ha.2.2
  have hsum2 : ∑ a ∈ nqrSet p, quadraticChar (ZMod p) a = -((nqrSet p).card : ℤ) := by
    rw [Finset.sum_congr rfl (fun a ha => ?_), Finset.sum_const, nsmul_eq_mul, mul_neg_one]
    simp only [nqrSet, mem_filter] at ha
    exact quadraticChar_neg_one_iff_not_isSquare.mpr ha.2.2
  rw [hS, hN, hsum1, hsum2, hne] at hsplit
  have hcard := card_qrSet_add_card_nqrSet p
  omega

/-- The matching count for the non-residues. -/
theorem two_mul_card_nqrSet (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    2 * (nqrSet p).card = p - 1 := by
  have h1 := two_mul_card_qrSet p hp
  have h2 := card_qrSet_add_card_nqrSet p
  omega

/-- Both classes are inhabited at an odd prime: `1` is a residue and, since the two classes
have equal size and `p ≥ 3`, a non-residue exists too. -/
theorem card_qrSet_pos (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) : 0 < (qrSet p).card := by
  have hp3 : 3 ≤ p := by
    have h2 := (Fact.out : p.Prime).two_le
    omega
  have h1 := two_mul_card_qrSet p hp
  omega

theorem card_nqrSet_pos (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) : 0 < (nqrSet p).card := by
  have hp3 : 3 ≤ p := by
    have h2 := (Fact.out : p.Prime).two_le
    omega
  have h1 := two_mul_card_nqrSet p hp
  omega

/-! ## 2. CRT independence of the residue bits -/

/-- Reduction of `x mod mn` to `x mod m`. -/
def redFst (m n : ℕ) : ZMod (m * n) →+* ZMod m := ZMod.castHom ⟨n, rfl⟩ (ZMod m)

/-- Reduction of `x mod mn` to `x mod n`. -/
def redSnd (m n : ℕ) : ZMod (m * n) →+* ZMod n := ZMod.castHom ⟨m, mul_comm m n⟩ (ZMod n)

lemma chineseRemainder_fst {m n : ℕ} (h : m.Coprime n) (x : ZMod (m * n)) :
    (ZMod.chineseRemainder h x).1 = redFst m n x := by
  have hcomp : (RingHom.fst (ZMod m) (ZMod n)).comp
      (ZMod.chineseRemainder h : ZMod (m * n) →+* _) = redFst m n := RingHom.ext_zmod _ _
  exact congrArg (fun f => f x) hcomp

lemma chineseRemainder_snd {m n : ℕ} (h : m.Coprime n) (x : ZMod (m * n)) :
    (ZMod.chineseRemainder h x).2 = redSnd m n x := by
  have hcomp : (RingHom.snd (ZMod m) (ZMod n)).comp
      (ZMod.chineseRemainder h : ZMod (m * n) →+* _) = redSnd m n := RingHom.ext_zmod _ _
  exact congrArg (fun f => f x) hcomp

/-- **CRT independence, counting form.**  For coprime moduli the two reduction bits are
statistically independent: the number of residues mod `mn` satisfying a condition at `m` *and*
a condition at `n` is the product of the two individual counts. -/
theorem card_filter_crt {m n : ℕ} [NeZero m] [NeZero n] [NeZero (m * n)]
    (h : m.Coprime n) (P : ZMod m → Prop) (Q : ZMod n → Prop) :
    (univ.filter (fun x : ZMod (m * n) => P (redFst m n x) ∧ Q (redSnd m n x))).card
      = (univ.filter P).card * (univ.filter Q).card := by
  rw [← Finset.card_product]
  refine Finset.card_equiv (ZMod.chineseRemainder h).toEquiv ?_
  intro x
  simp only [mem_filter, mem_univ, true_and, Finset.mem_product, RingEquiv.toEquiv_eq_coe,
    RingEquiv.coe_toEquiv]
  rw [chineseRemainder_fst h x, chineseRemainder_snd h x]

/-! ## 3. The two-prime dial and its exact law -/

variable (p q : ℕ) [Fact p.Prime] [Fact q.Prime]

/-- Residues mod `pq` that are quadratic residues at both primes. -/
def patternSS : Finset (ZMod (p * q)) :=
  univ.filter (fun x => redFst p q x ∈ qrSet p ∧ redSnd p q x ∈ qrSet q)

/-- Residue at `p`, non-residue at `q`. -/
def patternSN : Finset (ZMod (p * q)) :=
  univ.filter (fun x => redFst p q x ∈ qrSet p ∧ redSnd p q x ∈ nqrSet q)

/-- Non-residue at `p`, residue at `q`. -/
def patternNS : Finset (ZMod (p * q)) :=
  univ.filter (fun x => redFst p q x ∈ nqrSet p ∧ redSnd p q x ∈ qrSet q)

/-- Non-residue at both primes. -/
def patternNN : Finset (ZMod (p * q)) :=
  univ.filter (fun x => redFst p q x ∈ nqrSet p ∧ redSnd p q x ∈ nqrSet q)

/-- The two-prime QR dial: how many of the two small primes see `x` as a quadratic residue. -/
def qrDial (x : ZMod (p * q)) : ℕ :=
  (if redFst p q x ∈ qrSet p then 1 else 0) + (if redSnd p q x ∈ qrSet q then 1 else 0)

variable {p q}

/-- **Each QR pattern occurs exactly `(p−1)(q−1)/4` times.**  (Stated as
`4 · count = (p−1)(q−1)`.) -/
theorem card_pattern_SS (hpq : p ≠ q) (hp : p ≠ 2) (hq : q ≠ 2) :
    4 * (patternSS p q).card = (p - 1) * (q - 1) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes Fact.out Fact.out).mpr hpq
  have h := card_filter_crt (m := p) (n := q) hcop (· ∈ qrSet p) (· ∈ qrSet q)
  have hP := two_mul_card_qrSet p hp
  have hQ := two_mul_card_qrSet q hq
  have hcard : (patternSS p q).card = (qrSet p).card * (qrSet q).card := by
    rw [patternSS]; convert h using 3 <;> simp [qrSet]
  rw [hcard]
  calc 4 * ((qrSet p).card * (qrSet q).card)
      = (2 * (qrSet p).card) * (2 * (qrSet q).card) := by ring
    _ = (p - 1) * (q - 1) := by rw [hP, hQ]

theorem card_pattern_SN (hpq : p ≠ q) (hp : p ≠ 2) (hq : q ≠ 2) :
    4 * (patternSN p q).card = (p - 1) * (q - 1) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes Fact.out Fact.out).mpr hpq
  have h := card_filter_crt (m := p) (n := q) hcop (· ∈ qrSet p) (· ∈ nqrSet q)
  have hP := two_mul_card_qrSet p hp
  have hQ := two_mul_card_nqrSet q hq
  have hcard : (patternSN p q).card = (qrSet p).card * (nqrSet q).card := by
    rw [patternSN]; convert h using 3 <;> simp [qrSet, nqrSet]
  rw [hcard]
  calc 4 * ((qrSet p).card * (nqrSet q).card)
      = (2 * (qrSet p).card) * (2 * (nqrSet q).card) := by ring
    _ = (p - 1) * (q - 1) := by rw [hP, hQ]

theorem card_pattern_NS (hpq : p ≠ q) (hp : p ≠ 2) (hq : q ≠ 2) :
    4 * (patternNS p q).card = (p - 1) * (q - 1) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes Fact.out Fact.out).mpr hpq
  have h := card_filter_crt (m := p) (n := q) hcop (· ∈ nqrSet p) (· ∈ qrSet q)
  have hP := two_mul_card_nqrSet p hp
  have hQ := two_mul_card_qrSet q hq
  have hcard : (patternNS p q).card = (nqrSet p).card * (qrSet q).card := by
    rw [patternNS]; convert h using 3 <;> simp [qrSet, nqrSet]
  rw [hcard]
  calc 4 * ((nqrSet p).card * (qrSet q).card)
      = (2 * (nqrSet p).card) * (2 * (qrSet q).card) := by ring
    _ = (p - 1) * (q - 1) := by rw [hP, hQ]

theorem card_pattern_NN (hpq : p ≠ q) (hp : p ≠ 2) (hq : q ≠ 2) :
    4 * (patternNN p q).card = (p - 1) * (q - 1) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes Fact.out Fact.out).mpr hpq
  have h := card_filter_crt (m := p) (n := q) hcop (· ∈ nqrSet p) (· ∈ nqrSet q)
  have hP := two_mul_card_nqrSet p hp
  have hQ := two_mul_card_nqrSet q hq
  have hcard : (patternNN p q).card = (nqrSet p).card * (nqrSet q).card := by
    rw [patternNN]; convert h using 3 <;> simp [nqrSet]
  rw [hcard]
  calc 4 * ((nqrSet p).card * (nqrSet q).card)
      = (2 * (nqrSet p).card) * (2 * (nqrSet q).card) := by ring
    _ = (p - 1) * (q - 1) := by rw [hP, hQ]

/-! ### The dial level sets -/

lemma qrSet_nqrSet_disjoint (m : ℕ) [NeZero m] {a : ZMod m} (h1 : a ∈ qrSet m) :
    a ∉ nqrSet m := by
  simp only [qrSet, nqrSet, mem_filter, mem_univ, true_and] at h1 ⊢
  exact fun h2 => h2.2 h1.2

lemma qrDial_eq_two {x : ZMod (p * q)} (hx : x ∈ patternSS p q) : qrDial p q x = 2 := by
  simp only [patternSS, mem_filter, mem_univ, true_and] at hx
  simp [qrDial, hx.1, hx.2]

lemma qrDial_eq_zero {x : ZMod (p * q)} (hx : x ∈ patternNN p q) : qrDial p q x = 0 := by
  simp only [patternNN, mem_filter, mem_univ, true_and] at hx
  have h1 : redFst p q x ∉ qrSet p := fun h => qrSet_nqrSet_disjoint p h hx.1
  have h2 : redSnd p q x ∉ qrSet q := fun h => qrSet_nqrSet_disjoint q h hx.2
  simp [qrDial, h1, h2]

lemma qrDial_eq_one_SN {x : ZMod (p * q)} (hx : x ∈ patternSN p q) : qrDial p q x = 1 := by
  simp only [patternSN, mem_filter, mem_univ, true_and] at hx
  have h2 : redSnd p q x ∉ qrSet q := fun h => qrSet_nqrSet_disjoint q h hx.2
  simp [qrDial, hx.1, h2]

lemma qrDial_eq_one_NS {x : ZMod (p * q)} (hx : x ∈ patternNS p q) : qrDial p q x = 1 := by
  simp only [patternNS, mem_filter, mem_univ, true_and] at hx
  have h1 : redFst p q x ∉ qrSet p := fun h => qrSet_nqrSet_disjoint p h hx.1
  simp [qrDial, h1, hx.2]

/-- The two "exactly one residue" patterns are disjoint. -/
lemma patternSN_disjoint_NS : Disjoint (patternSN p q) (patternNS p q) := by
  refine Finset.disjoint_left.mpr ?_
  intro x hx hy
  simp only [patternSN, patternNS, mem_filter, mem_univ, true_and] at hx hy
  exact qrSet_nqrSet_disjoint p hx.1 hy.1

/-- The dial level `1` set. -/
def dialOne : Finset (ZMod (p * q)) := patternSN p q ∪ patternNS p q

/-- **The exact binomial law of the two-prime dial.**  Over all residues mod `pq` that are
units at both primes, the dial `T ∈ {0,1,2}` is distributed exactly as the number of heads in
two fair coin flips: `4·|T = 2| = 2·|T = 1| = 4·|T = 0| = (p−1)(q−1)`.  No asymptotics and no
error term: the small-prime QR pattern is a family of *exactly* uniform independent bits. -/
theorem qrDial_binomial (hpq : p ≠ q) (hp : p ≠ 2) (hq : q ≠ 2) :
    4 * (patternSS p q).card = (p - 1) * (q - 1) ∧
      2 * (dialOne (p := p) (q := q)).card = (p - 1) * (q - 1) ∧
      4 * (patternNN p q).card = (p - 1) * (q - 1) := by
  refine ⟨card_pattern_SS hpq hp hq, ?_, card_pattern_NN hpq hp hq⟩
  have hcard : (dialOne (p := p) (q := q)).card
      = (patternSN p q).card + (patternNS p q).card :=
    Finset.card_union_of_disjoint patternSN_disjoint_NS
  have h1 := card_pattern_SN hpq hp hq
  have h2 := card_pattern_NS hpq hp hq
  omega

/-- **The dial is a nonconstant statistic.**  All three levels are attained, so the QR pattern
genuinely separates residues mod `pq` — the per-`N` signal the record refers to exists at the
arithmetic level, independently of any downstream rate. -/
theorem qrDial_takes_all_values (hpq : p ≠ q) (hp : p ≠ 2) (hq : q ≠ 2) :
    (∃ x : ZMod (p * q), qrDial p q x = 0) ∧ (∃ x : ZMod (p * q), qrDial p q x = 1) ∧
      (∃ x : ZMod (p * q), qrDial p q x = 2) := by
  have hp3 : 3 ≤ p := by have := (Fact.out : p.Prime).two_le; omega
  have hq3 : 3 ≤ q := by have := (Fact.out : q.Prime).two_le; omega
  have hprod : 0 < (p - 1) * (q - 1) := Nat.mul_pos (by omega) (by omega)
  have hSS : 0 < (patternSS p q).card := by
    have := card_pattern_SS hpq hp hq; omega
  have hNN : 0 < (patternNN p q).card := by
    have := card_pattern_NN hpq hp hq; omega
  have hSN : 0 < (patternSN p q).card := by
    have := card_pattern_SN hpq hp hq; omega
  obtain ⟨x, hx⟩ := Finset.card_pos.mp hSS
  obtain ⟨y, hy⟩ := Finset.card_pos.mp hNN
  obtain ⟨z, hz⟩ := Finset.card_pos.mp hSN
  exact ⟨⟨y, qrDial_eq_zero hy⟩, ⟨z, qrDial_eq_one_SN hz⟩, ⟨x, qrDial_eq_two hx⟩⟩

/-- The unit part of `ZMod (pq)`: residues invertible at both primes. -/
def unitPart : Finset (ZMod (p * q)) :=
  patternSS p q ∪ (patternSN p q ∪ (patternNS p q ∪ patternNN p q))

lemma pattern_pairwise_disjoint_aux {x : ZMod (p * q)}
    (h1 : x ∈ patternSS p q) : x ∉ patternSN p q ∪ (patternNS p q ∪ patternNN p q) := by
  simp only [patternSS, mem_filter, mem_univ, true_and] at h1
  intro hmem
  rcases Finset.mem_union.mp hmem with h | h
  · simp only [patternSN, mem_filter, mem_univ, true_and] at h
    exact qrSet_nqrSet_disjoint q h1.2 h.2
  · rcases Finset.mem_union.mp h with h' | h'
    · simp only [patternNS, mem_filter, mem_univ, true_and] at h'
      exact qrSet_nqrSet_disjoint p h1.1 h'.1
    · simp only [patternNN, mem_filter, mem_univ, true_and] at h'
      exact qrSet_nqrSet_disjoint p h1.1 h'.1

/-- The unit part has exactly `(p−1)(q−1)` elements — Euler's totient of `pq`, recovered here
from the four QR patterns. -/
theorem card_unitPart (hpq : p ≠ q) (hp : p ≠ 2) (hq : q ≠ 2) :
    (unitPart (p := p) (q := q)).card = (p - 1) * (q - 1) := by
  have hdSN_NS : Disjoint (patternSN p q) (patternNS p q) := patternSN_disjoint_NS
  have hdNS_NN : Disjoint (patternNS p q) (patternNN p q) := by
    refine Finset.disjoint_left.mpr ?_
    intro x hx hy
    simp only [patternNS, patternNN, mem_filter, mem_univ, true_and] at hx hy
    exact qrSet_nqrSet_disjoint q hx.2 hy.2
  have hdSN_NN : Disjoint (patternSN p q) (patternNN p q) := by
    refine Finset.disjoint_left.mpr ?_
    intro x hx hy
    simp only [patternSN, patternNN, mem_filter, mem_univ, true_and] at hx hy
    exact qrSet_nqrSet_disjoint p hx.1 hy.1
  have hd2 : Disjoint (patternNS p q) (patternNN p q) := hdNS_NN
  have hd1 : Disjoint (patternSN p q) (patternNS p q ∪ patternNN p q) :=
    Finset.disjoint_union_right.mpr ⟨hdSN_NS, hdSN_NN⟩
  have hd0 : Disjoint (patternSS p q) (patternSN p q ∪ (patternNS p q ∪ patternNN p q)) :=
    Finset.disjoint_left.mpr fun _ hx => pattern_pairwise_disjoint_aux hx
  have hcard : (unitPart (p := p) (q := q)).card
      = (patternSS p q).card + ((patternSN p q).card
        + ((patternNS p q).card + (patternNN p q).card)) := by
    rw [unitPart, Finset.card_union_of_disjoint hd0, Finset.card_union_of_disjoint hd1,
      Finset.card_union_of_disjoint hd2]
  have h1 := card_pattern_SS hpq hp hq
  have h2 := card_pattern_SN hpq hp hq
  have h3 := card_pattern_NS hpq hp hq
  have h4 := card_pattern_NN hpq hp hq
  omega

/-- **The dial has variance exactly `1/2`, at every pair of small primes.**  Written without
division: `2 · ∑_{x ∈ units} (T x − 1)² = |units|`.  Since the identity is uniform in `p, q`
(and hence in the bit length of `N`), the information content of the QR dial does *not* fade —
only its coupling to the downstream rate does. -/
theorem two_mul_dial_variance (hpq : p ≠ q) (hp : p ≠ 2) (hq : q ≠ 2) :
    2 * ∑ x ∈ unitPart (p := p) (q := q), ((qrDial p q x : ℤ) - 1) ^ 2
      = (((p - 1) * (q - 1) : ℕ) : ℤ) := by
  have hdSN_NS : Disjoint (patternSN p q) (patternNS p q) := patternSN_disjoint_NS
  have hdNS_NN : Disjoint (patternNS p q) (patternNN p q) := by
    refine Finset.disjoint_left.mpr ?_
    intro x hx hy
    simp only [patternNS, patternNN, mem_filter, mem_univ, true_and] at hx hy
    exact qrSet_nqrSet_disjoint q hx.2 hy.2
  have hdSN_NN : Disjoint (patternSN p q) (patternNN p q) := by
    refine Finset.disjoint_left.mpr ?_
    intro x hx hy
    simp only [patternSN, patternNN, mem_filter, mem_univ, true_and] at hx hy
    exact qrSet_nqrSet_disjoint p hx.1 hy.1
  have hd1 : Disjoint (patternSN p q) (patternNS p q ∪ patternNN p q) :=
    Finset.disjoint_union_right.mpr ⟨hdSN_NS, hdSN_NN⟩
  have hd0 : Disjoint (patternSS p q) (patternSN p q ∪ (patternNS p q ∪ patternNN p q)) :=
    Finset.disjoint_left.mpr fun _ hx => pattern_pairwise_disjoint_aux hx
  have eSS : ∑ x ∈ patternSS p q, ((qrDial p q x : ℤ) - 1) ^ 2
      = ((patternSS p q).card : ℤ) := by
    rw [Finset.sum_congr rfl (fun x hx =>
      show ((qrDial p q x : ℤ) - 1) ^ 2 = 1 by rw [qrDial_eq_two hx]; norm_num),
      Finset.sum_const, nsmul_eq_mul, mul_one]
  have eNN : ∑ x ∈ patternNN p q, ((qrDial p q x : ℤ) - 1) ^ 2
      = ((patternNN p q).card : ℤ) := by
    rw [Finset.sum_congr rfl (fun x hx =>
      show ((qrDial p q x : ℤ) - 1) ^ 2 = 1 by rw [qrDial_eq_zero hx]; norm_num),
      Finset.sum_const, nsmul_eq_mul, mul_one]
  have eSN : ∑ x ∈ patternSN p q, ((qrDial p q x : ℤ) - 1) ^ 2 = 0 := by
    rw [Finset.sum_congr rfl (fun x hx =>
      show ((qrDial p q x : ℤ) - 1) ^ 2 = 0 by rw [qrDial_eq_one_SN hx]; norm_num)]
    simp
  have eNS : ∑ x ∈ patternNS p q, ((qrDial p q x : ℤ) - 1) ^ 2 = 0 := by
    rw [Finset.sum_congr rfl (fun x hx =>
      show ((qrDial p q x : ℤ) - 1) ^ 2 = 0 by rw [qrDial_eq_one_NS hx]; norm_num)]
    simp
  have hsum : ∑ x ∈ unitPart (p := p) (q := q), ((qrDial p q x : ℤ) - 1) ^ 2
      = ((patternSS p q).card : ℤ) + ((patternNN p q).card : ℤ) := by
    rw [unitPart, Finset.sum_union hd0, Finset.sum_union hd1, Finset.sum_union hdNS_NN,
      eSS, eSN, eNS, eNN]
    ring
  rw [hsum]
  have h1 := card_pattern_SS hpq hp hq
  have h4 := card_pattern_NN hpq hp hq
  have hnat : 2 * ((patternSS p q).card + (patternNN p q).card) = (p - 1) * (q - 1) := by omega
  exact_mod_cast congrArg (fun k : ℕ => (k : ℤ)) hnat

end Catalog.Novelty.TDialU112QuadraticResidueSignal