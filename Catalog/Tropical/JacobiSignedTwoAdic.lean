import Tropical.JacobiSignedTwoSquares

/-!
# The exact 2-adic valuation of the Jacobi-signed circle count

Every observed value of the statistic is `2` times an *odd* number
(`-2, -6, 10, -10, 6, -14, -18, 22, 26, 34, ...`).  This is not a coincidence: we prove

`p ≡ 1 (mod 4) → W p ≡ 2 (mod 4)`  (`JacSign.W_mod_four`),

i.e. `v₂(W p) = 1` exactly.  The argument is a parity count over the "lower half" of the
residues: `W p = 2 S` with `S` a sum of `(p-1)/2` values in `{0, ±1}`, exactly one of which
(the term `x = 1`) vanishes, so `S ≡ (p-1)/2 - 1 ≡ 1 (mod 2)`.

Combined with the Jacobsthal identity of `JacobiSignedTwoSquares.lean` this pins down the
classical normalisation of Fermat's two-square decomposition: `p = a² + b²` with
`a = W p / 2` **odd**.
-/

open Finset

namespace JacSign

variable (p : ℕ) [Fact p.Prime]

/-- The lower half of the residues has `(p-1)/2` elements. -/
theorem card_halfSet (hp : p ≠ 2) : 2 * ((halfSet p).card : ℤ) = (p : ℤ) - 1 := by
  have hp2 := (Fact.out : p.Prime).two_le
  have h := sum_eq_two_mul_half p hp (fun x : ZMod p => if x = 0 then (0 : ℤ) else 1)
    (by intro x; simp [neg_eq_zero]) (by simp)
  have hleft : (∑ x : ZMod p, if x = 0 then (0 : ℤ) else 1) = (p : ℤ) - 1 := by
    rw [Finset.sum_ite]
    have hset : (univ.filter (fun x : ZMod p => ¬ x = 0)) = univ.erase 0 := by
      ext x; simp [Finset.mem_erase, and_comm]
    rw [Finset.sum_const, Finset.sum_const, hset,
      Finset.card_erase_of_mem (Finset.mem_univ (0 : ZMod p)), Finset.card_univ, ZMod.card]
    simp only [smul_zero, zero_add, nsmul_eq_mul, mul_one]
    push_cast [Nat.cast_sub (by omega : 1 ≤ p)]
    ring
  have hright : (∑ x ∈ halfSet p, if x = 0 then (0 : ℤ) else 1) = ((halfSet p).card : ℤ) := by
    rw [Finset.sum_congr rfl (fun x hx => ?_), Finset.sum_const, nsmul_eq_mul, mul_one]
    rw [if_neg (Finset.mem_erase.mp hx).1]
  rw [hleft, hright] at h
  omega

/-- `1` lies in the lower half, `-1` does not. -/
theorem one_mem_halfSet (hp : p ≠ 2) : (1 : ZMod p) ∈ halfSet p := by
  have hprime := (Fact.out : p.Prime)
  have hodd : p % 2 = 1 := hprime.eq_two_or_odd.resolve_left hp
  have hp3 : 3 ≤ p := by have := hprime.two_le; omega
  haveI : NeZero p := ⟨by omega⟩
  have hv : (1 : ZMod p).val = 1 := ZMod.val_one_eq_one_mod p ▸ by
    simp [Nat.mod_eq_of_lt (by omega : 1 < p)]
  refine Finset.mem_erase.mpr ⟨one_ne_zero, ?_⟩
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, hv]
  omega

theorem neg_one_notMem_halfSet (hp : p ≠ 2) : (-1 : ZMod p) ∉ halfSet p := by
  have hprime := (Fact.out : p.Prime)
  have hodd : p % 2 = 1 := hprime.eq_two_or_odd.resolve_left hp
  have hp3 : 3 ≤ p := by have := hprime.two_le; omega
  haveI : NeZero p := ⟨by omega⟩
  have h1 : (1 : ZMod p) ≠ 0 := one_ne_zero
  haveI : NeZero (1 : ZMod p) := ⟨h1⟩
  have hv1 : (1 : ZMod p).val = 1 := ZMod.val_one_eq_one_mod p ▸ by
    simp [Nat.mod_eq_of_lt (by omega : 1 < p)]
  have hv : (-1 : ZMod p).val = p - 1 := by
    rw [ZMod.val_neg_of_ne_zero (1 : ZMod p), hv1]
  intro hmem
  have := (Finset.mem_filter.mp (Finset.mem_of_mem_erase hmem)).2
  rw [hv] at this
  omega

/-- **The exact 2-adic valuation.** For `p ≡ 1 (mod 4)` the statistic is twice an odd
number: `W p ≡ 2 (mod 4)`. -/
theorem W_mod_four (hp : p ≠ 2) (h1 : p % 4 = 1) : ∃ s : ℤ, W p = 2 * s ∧ ¬ (2 : ℤ) ∣ s := by
  have hprime := (Fact.out : p.Prime)
  have hp5 : 5 ≤ p := by
    have := hprime.two_le
    rcases (by omega : p = 5 ∨ p < 5 ∨ 5 < p) with h | h | h
    · omega
    · interval_cases p <;> simp_all
    · omega
  set f : ZMod p → ℤ := fun x => quadraticChar (ZMod p) (x * (1 - x ^ 2)) with hf
  have hfneg : ∀ x : ZMod p, f (-x) = f x := by
    intro x
    show quadraticChar (ZMod p) ((-x) * (1 - (-x) ^ 2)) = quadraticChar (ZMod p) (x * (1 - x ^ 2))
    have hx : quadraticChar (ZMod p) ((-x) * (1 - (-x) ^ 2))
        = quadraticChar (ZMod p) (-1) * quadraticChar (ZMod p) (x * (1 - x ^ 2)) := by
      rw [← map_mul]; congr 1; ring
    rw [hx, chi_neg_one_eq_one p h1, one_mul]
  have hhalf : W p = 2 * ∑ x ∈ halfSet p, f x := sum_eq_two_mul_half p hp f hfneg (by simp [hf])
  refine ⟨∑ x ∈ halfSet p, f x, hhalf, ?_⟩
  -- the squares of the terms count the nonvanishing ones
  have hsq : ∑ x ∈ halfSet p, (f x) ^ 2 = ((halfSet p).card : ℤ) - 1 := by
    have hone : f 1 = 0 := by simp [hf]
    have hrest : ∀ x ∈ (halfSet p).erase 1, (f x) ^ 2 = 1 := by
      intro x hx
      have hx1 : x ≠ 1 := (Finset.mem_erase.mp hx).1
      have hx0 : x ≠ 0 := (Finset.mem_erase.mp (Finset.mem_of_mem_erase hx)).1
      have hxm1 : x ≠ -1 := by
        intro h
        exact neg_one_notMem_halfSet p hp (h ▸ Finset.mem_of_mem_erase hx)
      have hne : x * (1 - x ^ 2) ≠ 0 := by
        refine mul_ne_zero hx0 ?_
        intro h
        have hx2 : x ^ 2 = 1 := by linear_combination -h
        rcases sq_eq_sq_iff_eq_or_eq_neg.mp (by rw [hx2, one_pow] : x ^ 2 = (1 : ZMod p) ^ 2) with
          h' | h'
        · exact hx1 h'
        · exact hxm1 (by simpa using h')
      exact quadraticChar_sq_one hne
    rw [← Finset.add_sum_erase _ _ (one_mem_halfSet p hp), hone,
      Finset.sum_congr rfl hrest, Finset.sum_const, nsmul_eq_mul, mul_one,
      Finset.card_erase_of_mem (one_mem_halfSet p hp)]
    have hcard : 1 ≤ (halfSet p).card := Finset.card_pos.mpr ⟨1, one_mem_halfSet p hp⟩
    push_cast [Nat.cast_sub hcard]
    ring
  -- each term is congruent to its square mod 2
  have hpar : (2 : ℤ) ∣ (∑ x ∈ halfSet p, (f x) ^ 2) - ∑ x ∈ halfSet p, f x := by
    rw [← Finset.sum_sub_distrib]
    refine Finset.dvd_sum fun x _ => ?_
    rcases quadraticChar_isQuadratic (ZMod p) (x * (1 - x ^ 2)) with h | h | h <;>
      rw [hf] <;> simp only <;> rw [h] <;> norm_num
  rw [hsq] at hpar
  have hc := card_halfSet p hp
  intro hdvd
  obtain ⟨k, hk⟩ := hdvd
  obtain ⟨m, hm⟩ := hpar
  -- (p-1)/2 is even since p ≡ 1 (mod 4), so the count minus one is odd
  have hp4 : (4 : ℤ) ∣ (p : ℤ) - 1 := by
    obtain ⟨j, hj⟩ : (4 : ℕ) ∣ (p - 1) := by omega
    refine ⟨(j : ℤ), ?_⟩
    have : ((p - 1 : ℕ) : ℤ) = (p : ℤ) - 1 := by
      push_cast [Nat.cast_sub (by omega : 1 ≤ p)]; ring
    rw [← this, hj]
    push_cast
    ring
  obtain ⟨j, hj⟩ := hp4
  omega

/-- **Fermat's two-square theorem in normalised form**, with the odd leg given by the
Jacobi-signed circle count: `p = a² + b²` with `a = W p / 2` odd. -/
theorem two_squares_odd_leg (hp : p ≠ 2) (h1 : p % 4 = 1) :
    ∃ a b : ℤ, (p : ℤ) = a ^ 2 + b ^ 2 ∧ 2 * a = W p ∧ ¬ (2 : ℤ) ∣ a := by
  obtain ⟨a, b, hab, ha⟩ := two_squares_of_one_mod_four p hp h1
  obtain ⟨s, hs, hsodd⟩ := W_mod_four p hp h1
  have : a = s := by omega
  exact ⟨a, b, hab, ha, this ▸ hsodd⟩

end JacSign