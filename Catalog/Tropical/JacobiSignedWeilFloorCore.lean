import Mathlib

/-!
# The Jacobi-signed circle count: core structure (JACSIGN)

For an odd prime `p` let `χ = quadraticChar (ZMod p)` be the Legendre character and let

`S(p) = {(x, y) ∈ (ZMod p)² : x² + y² = 1}`

be the unit circle over `ZMod p`.  The *Jacobi-signed circle count* is the character
weighted point count

`circleWeight p = ∑_{(x,y) ∈ S(p)} χ(x)`.

This file proves the basic structure of this weight:

* `JacSign.circleWeight_eq_W` : the geometric weight collapses to the **cubic character sum**
  `W p = ∑_x χ(x(1 - x²))`, i.e. the trace of Frobenius of the curve `y² = x - x³`
  (up to sign).
* `JacSign.W_neg_reflect` : the reflection identity `W p = χ(-1) · W p`.
* `JacSign.W_eq_zero_of_three_mod_four` : `W p = 0` whenever `p ≡ 3 (mod 4)` — the
  supersingular half of the primes carries **no** signal at all.
* `JacSign.W_even` : `W p` is always even, so the weight can never be an odd number;
  this matches the observed data `-2, -10, 6, -18, 14, 22`.

These are the structural facts underlying the JACSIGN experiment; the Weil bound
`W p ^ 2 ≤ 4 p` is proved in `JacobiSignedWeilFloorBound.lean`.
-/

open Finset

namespace JacSign

/-- The character sum `W p = ∑_x χ(x (1 - x²))`, where `χ` is the Legendre character. -/
noncomputable def W (p : ℕ) [Fact p.Prime] : ℤ :=
  ∑ x : ZMod p, quadraticChar (ZMod p) (x * (1 - x ^ 2))

/-- The Jacobi-signed circle count: the points of the unit circle `x² + y² = 1` over
`ZMod p`, each weighted by the Legendre symbol of its `x`-coordinate. -/
noncomputable def circleWeight (p : ℕ) [Fact p.Prime] : ℤ :=
  ∑ x : ZMod p, ∑ y : ZMod p, if x ^ 2 + y ^ 2 = 1 then quadraticChar (ZMod p) x else 0

variable (p : ℕ) [Fact p.Prime]

/-- The geometric (circle) weight equals the cubic character sum `W p`. -/
theorem circleWeight_eq_W (hp : p ≠ 2) : circleWeight p = W p := by
  have hF : ringChar (ZMod p) ≠ 2 := by rw [ZMod.ringChar_zmod_n]; exact hp
  have key : ∀ a : ZMod p,
      ((univ.filter (fun y : ZMod p => y ^ 2 = a)).card : ℤ) = quadraticChar (ZMod p) a + 1 := by
    intro a
    simpa [Set.toFinset_setOf] using quadraticChar_card_sqrts (F := ZMod p) hF a
  have step : ∀ x : ZMod p,
      (∑ y : ZMod p, if x ^ 2 + y ^ 2 = 1 then quadraticChar (ZMod p) x else 0)
        = quadraticChar (ZMod p) x * (quadraticChar (ZMod p) (1 - x ^ 2) + 1) := by
    intro x
    rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const]
    have hset : (univ.filter (fun y : ZMod p => x ^ 2 + y ^ 2 = 1))
        = (univ.filter (fun y : ZMod p => y ^ 2 = 1 - x ^ 2)) := by
      apply Finset.filter_congr
      intro y _
      constructor <;> intro h <;> linear_combination h
    rw [hset, nsmul_eq_mul, smul_zero, add_zero, ← key (1 - x ^ 2), mul_comm]
  simp only [circleWeight, step, mul_add, mul_one, Finset.sum_add_distrib]
  rw [quadraticChar_sum_zero hF, add_zero]
  simp [W, map_mul]

/-- Reflection identity: replacing `x` by `-x` multiplies the summand by `χ(-1)`. -/
theorem W_neg_reflect : W p = quadraticChar (ZMod p) (-1) * W p := by
  have hrefl : ∀ x : ZMod p, quadraticChar (ZMod p) (x * (1 - x ^ 2))
      = quadraticChar (ZMod p) (-1) * quadraticChar (ZMod p) ((-x) * (1 - (-x) ^ 2)) := by
    intro x
    rw [← map_mul]
    congr 1
    ring
  calc W p = ∑ x : ZMod p, quadraticChar (ZMod p) (-1) *
              quadraticChar (ZMod p) ((-x) * (1 - (-x) ^ 2)) := by
        rw [W]; exact Finset.sum_congr rfl fun x _ => hrefl x
    _ = quadraticChar (ZMod p) (-1) * W p := by
        rw [← Finset.mul_sum]
        congr 1
        exact Fintype.sum_equiv (Equiv.neg (ZMod p)) _ _ fun x => rfl

theorem chi_neg_one_eq_neg_one (hp : p % 4 = 3) : quadraticChar (ZMod p) (-1) = -1 := by
  rw [quadraticChar_neg_one_iff_not_isSquare, ZMod.exists_sq_eq_neg_one_iff]
  simp [hp]

theorem chi_neg_one_eq_one (hp : p % 4 = 1) : quadraticChar (ZMod p) (-1) = 1 := by
  have hne : (-1 : ZMod p) ≠ 0 := neg_ne_zero.mpr one_ne_zero
  rw [quadraticChar_one_iff_isSquare hne, ZMod.exists_sq_eq_neg_one_iff]
  omega

/-- **Half of all primes carry no signal.** For `p ≡ 3 (mod 4)` the Jacobi-signed
circle count vanishes identically. -/
theorem W_eq_zero_of_three_mod_four (hp : p % 4 = 3) : W p = 0 := by
  have h := W_neg_reflect p
  rw [chi_neg_one_eq_neg_one p hp] at h
  linarith

/-- The "lower half" of the nonzero residues: one representative of each pair
`{x, -x}`. -/
def halfSet (p : ℕ) [Fact p.Prime] : Finset (ZMod p) :=
  (univ.filter (fun x : ZMod p => 2 * x.val < p)).erase 0

/-- **A reflection-parity lemma.** Any function on `ZMod p` that is invariant under
`x ↦ -x` and vanishes at `0` has total sum twice its sum over the lower half: the
nonzero arguments pair up. -/
theorem sum_eq_two_mul_half (hp : p ≠ 2) (f : ZMod p → ℤ)
    (hfneg : ∀ x : ZMod p, f (-x) = f x) (hf0 : f 0 = 0) :
    (∑ x : ZMod p, f x) = 2 * ∑ x ∈ halfSet p, f x := by
  have hprime := (Fact.out : p.Prime)
  have hodd : p % 2 = 1 := hprime.eq_two_or_odd.resolve_left hp
  have hp3 : 3 ≤ p := by
    rcases hprime.two_le.lt_or_eq with h | h
    · omega
    · omega
  haveI : NeZero p := ⟨by omega⟩
  set A : Finset (ZMod p) := univ.filter (fun x => 2 * x.val < p) with hA
  have hsplit : (∑ x : ZMod p, f x)
      = ∑ x ∈ A, f x + ∑ x ∈ univ.filter (fun x : ZMod p => ¬ (2 * x.val < p)), f x :=
    (Finset.sum_filter_add_sum_filter_not univ _ f).symm
  have hval0 : ∀ x : ZMod p, x.val = 0 ↔ x = 0 := fun x => ZMod.val_eq_zero x
  have hne : ∀ x : ZMod p, x ≠ 0 → 2 * x.val ≠ p := by
    intro x _ h
    omega
  have hB : ∑ x ∈ univ.filter (fun x : ZMod p => ¬ (2 * x.val < p)), f x
      = ∑ x ∈ A.erase 0, f x := by
    refine Finset.sum_nbij' (i := fun x => -x) (j := fun x => -x) ?_ ?_ ?_ ?_ ?_
    · intro a ha
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, not_lt] at ha
      have ha0 : a ≠ 0 := by
        intro h; rw [h] at ha; simp at ha; omega
      haveI : NeZero a := ⟨ha0⟩
      have hv : (-a).val = p - a.val := ZMod.val_neg_of_ne_zero a
      have hlt : a.val < p := ZMod.val_lt a
      have hne' : 2 * a.val ≠ p := hne a ha0
      refine Finset.mem_erase.mpr ⟨?_, ?_⟩
      · simpa [neg_eq_zero] using ha0
      · simp only [hA, Finset.mem_filter, Finset.mem_univ, true_and, hv]
        omega
    · intro a ha
      have ha0 : a ≠ 0 := (Finset.mem_erase.mp ha).1
      have ha' := (Finset.mem_erase.mp ha).2
      simp only [hA, Finset.mem_filter, Finset.mem_univ, true_and] at ha'
      haveI : NeZero a := ⟨ha0⟩
      have hv : (-a).val = p - a.val := ZMod.val_neg_of_ne_zero a
      have hlt : a.val < p := ZMod.val_lt a
      have hpos : 0 < a.val := by
        rcases Nat.eq_zero_or_pos a.val with h | h
        · exact absurd ((hval0 a).mp h) ha0
        · exact h
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, not_lt, hv]
      omega
    · intro a _; simp
    · intro a _; simp
    · intro a _; exact (hfneg a).symm
  have hA0 : ∑ x ∈ A, f x = ∑ x ∈ A.erase 0, f x := by
    by_cases h0 : (0 : ZMod p) ∈ A
    · rw [← Finset.add_sum_erase A f h0, hf0, zero_add]
    · rw [Finset.erase_eq_of_notMem h0]
  rw [hsplit, hB, hA0, halfSet, ← hA]
  ring

/-- The total sum of a reflection-invariant function vanishing at `0` is even. -/
theorem sum_even_of_neg_invariant (hp : p ≠ 2) (f : ZMod p → ℤ)
    (hfneg : ∀ x : ZMod p, f (-x) = f x) (hf0 : f 0 = 0) :
    (2 : ℤ) ∣ ∑ x : ZMod p, f x :=
  ⟨_, sum_eq_two_mul_half p hp f hfneg hf0⟩

/-- The Jacobi-signed weight is always even; this matches every observed value
(`-2, -10, 6, -18, 14, 22, 34, ...`). -/
theorem W_even (hp : p ≠ 2) : (2 : ℤ) ∣ W p := by
  have hprime := (Fact.out : p.Prime)
  have hodd : p % 2 = 1 := hprime.eq_two_or_odd.resolve_left hp
  by_cases h4 : p % 4 = 3
  · rw [W_eq_zero_of_three_mod_four p h4]; exact dvd_zero 2
  have h1 : p % 4 = 1 := by
    have := hprime.two_le
    omega
  refine sum_even_of_neg_invariant p hp (fun x => quadraticChar (ZMod p) (x * (1 - x ^ 2)))
    (fun x => ?_) (by simp)
  show quadraticChar (ZMod p) ((-x) * (1 - (-x) ^ 2)) = quadraticChar (ZMod p) (x * (1 - x ^ 2))
  have hx : quadraticChar (ZMod p) ((-x) * (1 - (-x) ^ 2))
      = quadraticChar (ZMod p) (-1) * quadraticChar (ZMod p) (x * (1 - x ^ 2)) := by
    rw [← map_mul]; congr 1; ring
  rw [hx, chi_neg_one_eq_one p h1, one_mul]

end JacSign