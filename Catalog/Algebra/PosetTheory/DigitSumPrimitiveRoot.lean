import Mathlib

/-!
# Digit sum of full-period (primitive-root) fractions

If `p` is prime, `b ≥ 2`, and `b` is a primitive root modulo `p` (its multiplicative
order modulo `p` equals `p - 1`), then the sum of the digits in one period of the
base-`b` expansion of `1/p` equals `(b - 1)(p - 1)/2`.

The base-`b` long division of `1/p` proceeds through remainders `r k = b^k mod p` and
digits `d k = ⌊b · r k / p⌋`.  The argument is:

* The power map `k ↦ b^k mod p` is a bijection from `{0, …, p-2}` onto the nonzero
  residues (bijectivity of the power map for a primitive root), so the **remainder sum**
  `S = ∑ r k` satisfies `2S = p(p-1)`, i.e. `S = p(p-1)/2`.
* Summing the elementary division-algorithm identity `b · r k = p · d k + r (k+1)` over
  one period, and using that the shifted remainder sum again equals `S`, gives
  `p · D + S = b · S`.
* Solving directly, `p · D = (b-1) S`, hence `2 · D = (b-1)(p-1)` and
  `D = (b-1)(p-1)/2`.

The proof does not use the half-period result nor any statement that presupposes the
digit-sum formula.
-/

open Finset

namespace DigitSumPrimitiveRoot

/-- The `k`-th remainder in the base-`b` long division of `1/p`, equal to `b^k mod p`. -/
def rem (p b k : ℕ) : ℕ := b ^ k % p

/-- The `(k+1)`-st base-`b` digit of `1/p`, equal to `⌊b · (b^k mod p) / p⌋`. -/
def digit (p b k : ℕ) : ℕ := (b * rem p b k) / p

/-- The sum of the remainders over one period. -/
def remSum (p b : ℕ) : ℕ := ∑ k ∈ range (p - 1), rem p b k

/-- The sum of the digits over one period. -/
def digitSum (p b : ℕ) : ℕ := ∑ k ∈ range (p - 1), digit p b k

/-- The next remainder is `b` times the current remainder, reduced mod `p`. -/
lemma rem_succ (p b k : ℕ) : rem p b (k + 1) = (b * rem p b k) % p := by
  unfold rem
  rw [pow_succ, Nat.mul_mod, Nat.mul_mod b, Nat.mod_mod, mul_comm]

/-- The elementary division-algorithm identity for one long-division step. -/
lemma division_identity (p b k : ℕ) :
    b * rem p b k = p * digit p b k + rem p b (k + 1) := by
  rw [rem_succ, digit]
  exact (Nat.div_add_mod (b * rem p b k) p).symm

/-- The initial remainder is `1`. -/
lemma rem_zero (p b : ℕ) (hp : 2 ≤ p) : rem p b 0 = 1 := by
  unfold rem
  simp [Nat.mod_eq_of_lt hp]

/-- After a full period the remainder returns to `1` (this is where the primitive-root
hypothesis enters, via `b^(p-1) ≡ 1`). -/
lemma rem_period (p b : ℕ) (hp : p.Prime) (hord : orderOf (b : ZMod p) = p - 1) :
    rem p b (p - 1) = 1 := by
  haveI := Fact.mk hp
  haveI : NeZero p := ⟨hp.ne_zero⟩
  have hone : (b : ZMod p) ^ (p - 1) = 1 := by
    rw [← hord]; exact pow_orderOf_eq_one _
  have : rem p b (p - 1) = ((b : ZMod p) ^ (p - 1)).val := by
    unfold rem; rw [← Nat.cast_pow, ZMod.val_natCast]
  rw [this, hone, ZMod.val_one]

/-- The shifted remainder sum over one period equals the remainder sum: the shift drops
`rem 0 = 1` and appends `rem (p-1) = 1`. -/
lemma sum_shift (p b : ℕ) (hp : p.Prime) (hord : orderOf (b : ZMod p) = p - 1) :
    ∑ k ∈ range (p - 1), rem p b (k + 1) = remSum p b := by
  have hp1 : 1 ≤ p := hp.one_lt.le
  have key : (∑ k ∈ range (p - 1), rem p b (k + 1)) + rem p b 0
      = remSum p b + rem p b (p - 1) := by
    rw [← Finset.sum_range_succ']
    unfold remSum
    rw [← Finset.sum_range_succ]
  rw [rem_zero p b hp.two_le, rem_period p b hp hord] at key
  omega

/-- The remainder sum equals the sum of `ZMod.val` over the nonzero residues: the power
map `k ↦ (b : ZMod p)^k` is a bijection from `range (p-1)` onto the nonzero residues
(bijectivity of the power map for a primitive root). -/
lemma remSum_eq_sum_erase (p b : ℕ) [NeZero p] (hp : p.Prime)
    (hord : orderOf (b : ZMod p) = p - 1) :
    remSum p b = ∑ x ∈ (univ.erase (0 : ZMod p)), x.val := by
  haveI := Fact.mk hp
  have hp2 : 2 ≤ p := hp.two_le
  have hrem : ∀ k, rem p b k = ((b : ZMod p) ^ k).val := by
    intro k; unfold rem; rw [← Nat.cast_pow, ZMod.val_natCast]
  unfold remSum
  simp only [hrem]
  have hbne : (b : ZMod p) ≠ 0 := by
    intro h; rw [h, orderOf_zero] at hord; omega
  have hinj : Set.InjOn (fun k => (b : ZMod p) ^ k) (range (p - 1)) := by
    intro i hi j hj hij
    have hi' : i ∈ Set.Iio (orderOf (b : ZMod p)) := by
      rw [Set.mem_Iio, hord]; rw [mem_coe, mem_range] at hi; exact hi
    have hj' : j ∈ Set.Iio (orderOf (b : ZMod p)) := by
      rw [Set.mem_Iio, hord]; rw [mem_coe, mem_range] at hj; exact hj
    exact pow_injOn_Iio_orderOf hi' hj' hij
  rw [← Finset.sum_image (g := fun k => (b : ZMod p) ^ k) (f := fun x => ZMod.val x) hinj]
  congr 1
  apply Finset.eq_of_subset_of_card_le
  · intro x hx
    rw [mem_image] at hx
    obtain ⟨k, _, rfl⟩ := hx
    rw [mem_erase]
    exact ⟨pow_ne_zero k hbne, mem_univ _⟩
  · rw [Finset.card_erase_of_mem (mem_univ _), Finset.card_univ, ZMod.card,
      Finset.card_image_of_injOn hinj, Finset.card_range]

/-- Twice the sum of `ZMod.val` over all residues equals `p(p-1)`. -/
lemma two_mul_sum_val (p : ℕ) [NeZero p] :
    2 * (∑ x : ZMod p, x.val) = p * (p - 1) := by
  have : ∑ x : ZMod p, x.val = ∑ i ∈ range p, i := by
    refine Finset.sum_nbij' (fun x => x.val) (fun i => (i : ZMod p)) ?_ ?_ ?_ ?_ ?_
    · intro a _; rw [mem_range]; exact ZMod.val_lt a
    · intro a _; exact mem_univ _
    · intro a _; simp
    · intro a ha; rw [mem_range] at ha; exact ZMod.val_natCast_of_lt ha
    · intro a _; rfl
  rw [this, mul_comm, Finset.sum_range_id_mul_two]

/-- The remainder sum, computed via bijectivity of the power map: `2S = p(p-1)`. -/
lemma two_mul_remSum (p b : ℕ) (hp : p.Prime) (hord : orderOf (b : ZMod p) = p - 1) :
    2 * remSum p b = p * (p - 1) := by
  haveI := Fact.mk hp
  haveI : NeZero p := ⟨hp.ne_zero⟩
  rw [remSum_eq_sum_erase p b hp hord]
  have : ∑ x ∈ (univ.erase (0 : ZMod p)), x.val = ∑ x : ZMod p, x.val := by
    rw [Finset.sum_erase _ (by simp)]
  rw [this]
  exact two_mul_sum_val p

/-- The division-algorithm identity summed over one period: `p·D + S = b·S`. -/
lemma pdigit_add_rem (p b : ℕ) (hp : p.Prime) (hord : orderOf (b : ZMod p) = p - 1) :
    p * digitSum p b + remSum p b = b * remSum p b := by
  have hb : b * remSum p b = ∑ k ∈ range (p - 1), (p * digit p b k + rem p b (k + 1)) := by
    unfold remSum
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl (fun k _ => division_identity p b k)
  rw [hb, Finset.sum_add_distrib, ← Finset.mul_sum, sum_shift p b hp hord]
  rfl

/-- **Digit-sum identity for full-period fractions.**
If `p` is prime, `b ≥ 2`, and `b` is a primitive root modulo `p` (i.e. the
multiplicative order of `b` modulo `p` is `p - 1`), then the sum of the digits in one
period of the base-`b` expansion of `1/p` equals `(b - 1)(p - 1)/2`. -/
theorem digitSum_eq (p b : ℕ) (hp : p.Prime) (hb : 2 ≤ b)
    (hord : orderOf (b : ZMod p) = p - 1) :
    digitSum p b = (b - 1) * (p - 1) / 2 := by
  have hkey := pdigit_add_rem p b hp hord
  have hS := two_mul_remSum p b hp hord
  have hp0 : 0 < p := hp.pos
  -- From `p·D + S = b·S` and `b ≥ 1` we get `p·D = (b-1)·S`.
  have hpD : p * digitSum p b = (b - 1) * remSum p b := by
    have hle : remSum p b ≤ b * remSum p b := Nat.le_mul_of_pos_left _ (by omega)
    have hbS : (b - 1) * remSum p b + remSum p b = b * remSum p b := by
      rw [Nat.sub_one_mul]; omega
    omega
  -- Multiply by 2 and cancel `p`.
  have h2 : p * (2 * digitSum p b) = p * ((b - 1) * (p - 1)) := by
    have e1 : 2 * (p * digitSum p b) = (b - 1) * (2 * remSum p b) := by rw [hpD]; ring
    rw [hS] at e1
    calc p * (2 * digitSum p b) = 2 * (p * digitSum p b) := by ring
      _ = (b - 1) * (p * (p - 1)) := e1
      _ = p * ((b - 1) * (p - 1)) := by ring
  have h2D : 2 * digitSum p b = (b - 1) * (p - 1) :=
    Nat.eq_of_mul_eq_mul_left hp0 h2
  omega

end DigitSumPrimitiveRoot