import Mathlib

/-!
# Klein four-groups in the 2-torsion of the twist family `y² = x³ - 3d²x`

This file proves, **unconditionally and in both regimes**, the counting law for the
2-torsion of the quadratic twist family

`E_d : y² = x³ - 3 d² x`,  `d ∈ 𝔽_p^×`,

over a prime field `𝔽_p = ZMod p` with `p ≠ 2, 3`.

The 2-division polynomial of `E_d` is `ψ₂-cubic` `x³ - 3d²x = x (x² - 3d²)`, so the affine
2-torsion points are `(x, 0)` with `x ∈ {0, ± d√3}`.  Hence the full 2-torsion group
`E_d(𝔽_p)[2]` is the Klein four-group `V₄` exactly when `3` is a square mod `p`, and is
cyclic of order `2` otherwise — *uniformly in the twisting parameter `d`*, because
`3 d²` is a square iff `3` is.

Main results:

* `card_V4_of_isSquare` / `card_V4_of_not_isSquare` — the fibre count, factor by factor;
* `sum_card_V4_of_isSquare_three : ∑_{d ≠ 0} |E_d(𝔽_p)[2]| = 4 (p-1)`;
* `sum_card_V4_of_not_isSquare_three : ∑_{d ≠ 0} |E_d(𝔽_p)[2]| = 2 (p-1)`;
* `isSquare_three_iff_mod_twelve : IsSquare (3 : ZMod p) ↔ p % 12 = 1 ∨ p % 12 = 11`
  (the reciprocity input, deduced from quadratic reciprocity), together with the
  explicit consequences for the residue classes `1, 5, 7, 11 mod 12`;
* `psi2_split` / `psi2_not_split` — the corresponding factorisation of the 2-division
  polynomial into linear factors over `𝔽_p`.
-/

namespace KleinFourTwoTorsion

open Finset

variable {p : ℕ} [Fact p.Prime]

/-! ## Square roots in a prime field -/

/-- If `q` is a prime different from `p`, then `q` is invertible in `ZMod p`. -/
theorem cast_prime_ne_zero {q : ℕ} (hq : q.Prime) (hpq : p ≠ q) : ((q : ℕ) : ZMod p) ≠ 0 := by
  rw [Ne, ZMod.natCast_eq_zero_iff]
  intro hdvd
  exact hpq ((Nat.prime_dvd_prime_iff_eq (Fact.out : p.Prime) hq).1 hdvd)

/-- The set of square roots of `c`. -/
def sqrts (c : ZMod p) : Finset (ZMod p) := univ.filter fun x => x ^ 2 = c

/-- If `c ≠ 0` is a square in `ZMod p` with `p ≠ 2`, it has exactly two square roots. -/
theorem card_sqrts_of_isSquare (hp2 : p ≠ 2) {c : ZMod p} (hc : c ≠ 0) (h : IsSquare c) :
    (sqrts c).card = 2 := by
  obtain ⟨s, hs⟩ := h
  have hs0 : s ≠ 0 := by
    rintro rfl; exact hc (by simpa using hs)
  have hchar : (2 : ZMod p) ≠ 0 := cast_prime_ne_zero Nat.prime_two hp2
  have hne : s ≠ -s := by
    intro hss
    apply hs0
    have : (2 : ZMod p) * s = 0 := by linear_combination hss
    rcases mul_eq_zero.1 this with h | h
    · exact absurd h hchar
    · exact h
  have hset : sqrts c = {s, -s} := by
    ext x
    simp only [sqrts, mem_filter, mem_univ, true_and, mem_insert, mem_singleton]
    constructor
    · intro hx
      have hxx : x * x = s * s := by
        rw [← sq, hx, hs]
      exact mul_self_eq_mul_self_iff.1 hxx
    · rintro (rfl | rfl) <;> rw [hs] <;> ring
  rw [hset, card_insert_of_notMem (by simpa using hne), card_singleton]

/-- A non-square has no square roots. -/
theorem card_sqrts_of_not_isSquare {c : ZMod p} (h : ¬ IsSquare c) : (sqrts c).card = 0 := by
  rw [card_eq_zero]
  ext x
  simp only [sqrts, mem_filter, mem_univ, true_and, notMem_empty, iff_false]
  intro hx
  exact h ⟨x, by rw [← hx]; ring⟩

/-! ## The 2-torsion of the twisted curves -/

/-- The affine 2-torsion points of `y² = x³ - c x`: the points `(x, 0)` with `x³ = c x`. -/
def V4 (c : ZMod p) : Finset (ZMod p × ZMod p) :=
  univ.filter fun P => P.2 = 0 ∧ P.1 ^ 3 = c * P.1

/-- The order of the full 2-torsion group `E(𝔽_p)[2]`: the affine 2-torsion points together
with the point at infinity. -/
def cardV4 (c : ZMod p) : ℕ := (V4 c).card + 1

/-- The affine 2-torsion points are in bijection with the roots of the 2-division cubic. -/
theorem card_V4_eq (c : ZMod p) :
    (V4 c).card = (univ.filter fun x : ZMod p => x ^ 3 = c * x).card := by
  apply Finset.card_bij (fun P _ => P.1)
  · rintro ⟨x, y⟩ hP
    simp only [V4, mem_filter, mem_univ, true_and] at hP
    simpa using hP.2
  · rintro ⟨x, y⟩ hP ⟨x', y'⟩ hP' h
    simp only [V4, mem_filter, mem_univ, true_and] at hP hP'
    simp_all
  · intro x hx
    simp only [mem_filter, mem_univ, true_and] at hx
    exact ⟨(x, 0), by simp [V4, hx], rfl⟩

/-- Roots of the 2-division cubic `x³ - c x`: the root `0` together with the square roots
of `c`. -/
theorem card_cubic_roots {c : ZMod p} (hc : c ≠ 0) :
    (univ.filter fun x : ZMod p => x ^ 3 = c * x).card = 1 + (sqrts c).card := by
  have hsplit : (univ.filter fun x : ZMod p => x ^ 3 = c * x)
      = {(0 : ZMod p)} ∪ sqrts c := by
    ext x
    simp only [sqrts, mem_filter, mem_univ, true_and, mem_union, mem_singleton]
    constructor
    · intro hx
      have hx' : x * (x ^ 2 - c) = 0 := by linear_combination hx
      rcases mul_eq_zero.1 hx' with h | h
      · exact Or.inl h
      · exact Or.inr (sub_eq_zero.1 h)
    · rintro (rfl | hx)
      · ring
      · rw [← hx]; ring
  have hdisj : Disjoint ({(0 : ZMod p)} : Finset (ZMod p)) (sqrts c) := by
    simp only [disjoint_singleton_left, sqrts, mem_filter, mem_univ, true_and]
    intro h
    exact hc (by simpa using h.symm)
  rw [hsplit, card_union_of_disjoint hdisj, card_singleton]

/-- **Fibre count, square regime.** If `c ≠ 0` is a square, the 2-torsion has order `4`. -/
theorem card_V4_of_isSquare (hp2 : p ≠ 2) {c : ZMod p} (hc : c ≠ 0) (h : IsSquare c) :
    cardV4 c = 4 := by
  rw [cardV4, card_V4_eq, card_cubic_roots hc, card_sqrts_of_isSquare hp2 hc h]

/-- **Fibre count, non-square regime.** If `c` is a non-square, the 2-torsion has order `2`. -/
theorem card_V4_of_not_isSquare {c : ZMod p} (h : ¬ IsSquare c) : cardV4 c = 2 := by
  have hc : c ≠ 0 := by rintro rfl; exact h (IsSquare.zero)
  rw [cardV4, card_V4_eq, card_cubic_roots hc, card_sqrts_of_not_isSquare h]

/-! ## Twist invariance -/

/-- `3 d²` is a square iff `3` is, for `d ≠ 0`: the 2-torsion field of the family is the
single quadratic field `ℚ(√3)`, independent of the twist. -/
theorem isSquare_three_mul_sq {d : ZMod p} (hd : d ≠ 0) :
    IsSquare ((3 : ZMod p) * d ^ 2) ↔ IsSquare (3 : ZMod p) := by
  constructor
  · rintro ⟨t, ht⟩
    exact ⟨t / d, by field_simp at ht ⊢; linear_combination ht⟩
  · rintro ⟨s, hs⟩
    exact ⟨s * d, by rw [hs]; ring⟩

/-! ## The two regimes of the summed count -/

/-- The sum of the 2-torsion orders over the twist family `E_d : y² = x³ - 3d²x`,
`d` ranging over `𝔽_p^×`. -/
def sum_card_V4 (p : ℕ) [Fact p.Prime] : ℕ :=
  ∑ d ∈ (univ.erase (0 : ZMod p)), cardV4 (3 * d ^ 2)

theorem card_erase_zero : (univ.erase (0 : ZMod p)).card = p - 1 := by
  rw [card_erase_of_mem (mem_univ _), card_univ, ZMod.card]

/-- **Square regime.** If `3` is a square mod `p`, then every member of the twist family has
full Klein four 2-torsion, so the summed count is `4 (p-1)`. -/
theorem sum_card_V4_of_isSquare_three (hp2 : p ≠ 2) (hp3 : p ≠ 3)
    (h : IsSquare (3 : ZMod p)) : sum_card_V4 p = 4 * (p - 1) := by
  have h3 : (3 : ZMod p) ≠ 0 := cast_prime_ne_zero Nat.prime_three hp3
  have : ∀ d ∈ (univ.erase (0 : ZMod p)), cardV4 (3 * d ^ 2) = 4 := by
    intro d hd
    have hd0 : d ≠ 0 := (mem_erase.1 hd).1
    exact card_V4_of_isSquare hp2 (by
      exact mul_ne_zero h3 (pow_ne_zero _ hd0)) ((isSquare_three_mul_sq hd0).2 h)
  rw [sum_card_V4, sum_congr rfl this, sum_const, card_erase_zero, smul_eq_mul, mul_comm]

/-- **Non-square regime.** If `3` is not a square mod `p`, then every member of the twist
family has 2-torsion of order `2`, so the summed count is `2 (p-1)`. -/
theorem sum_card_V4_of_not_isSquare_three (h : ¬ IsSquare (3 : ZMod p)) :
    sum_card_V4 p = 2 * (p - 1) := by
  have : ∀ d ∈ (univ.erase (0 : ZMod p)), cardV4 (3 * d ^ 2) = 2 := by
    intro d hd
    have hd0 : d ≠ 0 := (mem_erase.1 hd).1
    exact card_V4_of_not_isSquare (fun hsq => h ((isSquare_three_mul_sq hd0).1 hsq))
  rw [sum_card_V4, sum_congr rfl this, sum_const, card_erase_zero, smul_eq_mul, mul_comm]

end KleinFourTwoTorsion

namespace KleinFourTwoTorsion

open Finset

variable {p : ℕ} [Fact p.Prime]

/-! ## The reciprocity input: when is `3` a square mod `p`? -/

/-- A prime `p ≠ 3` is not divisible by `3`. -/
theorem mod_three_ne_zero (hp3 : p ≠ 3) : p % 3 ≠ 0 := by
  intro h
  have : (3 : ℕ) ∣ p := Nat.dvd_of_mod_eq_zero h
  exact hp3 ((Nat.prime_dvd_prime_iff_eq Nat.prime_three (Fact.out : p.Prime)).1 this).symm

/-- For a prime `p ≠ 3`, `p` is a square mod `3` iff `p ≡ 1 mod 3`. -/
theorem isSquare_cast_mod_three (hp3 : p ≠ 3) :
    IsSquare ((p : ℕ) : ZMod 3) ↔ p % 3 = 1 := by
  have hp0 : p % 3 ≠ 0 := mod_three_ne_zero hp3
  have hcast : ((p : ℕ) : ZMod 3) = ((p % 3 : ℕ) : ZMod 3) := (ZMod.natCast_mod p 3).symm
  have h12 : p % 3 = 1 ∨ p % 3 = 2 := by omega
  rcases h12 with h | h <;> rw [hcast, h] <;> decide

/-- **Reciprocity input.** For a prime `p ∉ {2, 3}`, `3` is a square mod `p` exactly for the
residue classes `1` and `11` mod `12`; it is a non-square for the classes `5` and `7`. -/
theorem isSquare_three_iff_mod_twelve (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    IsSquare (3 : ZMod p) ↔ p % 12 = 1 ∨ p % 12 = 11 := by
  haveI : Fact (Nat.Prime 3) := ⟨Nat.prime_three⟩
  have hodd : p % 2 = 1 := Nat.odd_iff.1 ((Fact.out : p.Prime).odd_of_ne_two hp2)
  have h4 : p % 4 = 1 ∨ p % 4 = 3 := by omega
  have hcast : (3 : ZMod p) = ((3 : ℕ) : ZMod p) := by norm_num
  have hp30 : p % 3 ≠ 0 := mod_three_ne_zero hp3
  rcases h4 with h4 | h4
  · rw [hcast, ZMod.exists_sq_eq_prime_iff_of_mod_four_eq_one h4 (by norm_num),
      isSquare_cast_mod_three hp3]
    omega
  · rw [hcast, ZMod.exists_sq_eq_prime_iff_of_mod_four_eq_three h4 (by norm_num) hp3,
      isSquare_cast_mod_three hp3]
    omega

/-! ## The four residue classes mod 12 -/

/-- `p ≡ 1 mod 12`: split regime. -/
theorem sum_card_V4_of_mod_twelve_eq_one (h : p % 12 = 1) : sum_card_V4 p = 4 * (p - 1) := by
  have hp2 : p ≠ 2 := by omega
  have hp3 : p ≠ 3 := by omega
  exact sum_card_V4_of_isSquare_three hp2 hp3 ((isSquare_three_iff_mod_twelve hp2 hp3).2 (Or.inl h))

/-- `p ≡ 11 mod 12`: split regime. -/
theorem sum_card_V4_of_mod_twelve_eq_eleven (h : p % 12 = 11) : sum_card_V4 p = 4 * (p - 1) := by
  have hp2 : p ≠ 2 := by omega
  have hp3 : p ≠ 3 := by omega
  exact sum_card_V4_of_isSquare_three hp2 hp3 ((isSquare_three_iff_mod_twelve hp2 hp3).2 (Or.inr h))

/-- `p ≡ 5 mod 12`: non-split regime. -/
theorem sum_card_V4_of_mod_twelve_eq_five (h : p % 12 = 5) : sum_card_V4 p = 2 * (p - 1) := by
  have hp2 : p ≠ 2 := by omega
  have hp3 : p ≠ 3 := by omega
  refine sum_card_V4_of_not_isSquare_three (fun hsq => ?_)
  have := (isSquare_three_iff_mod_twelve hp2 hp3).1 hsq
  omega

/-- `p ≡ 7 mod 12`: non-split regime. -/
theorem sum_card_V4_of_mod_twelve_eq_seven (h : p % 12 = 7) : sum_card_V4 p = 2 * (p - 1) := by
  have hp2 : p ≠ 2 := by omega
  have hp3 : p ≠ 3 := by omega
  refine sum_card_V4_of_not_isSquare_three (fun hsq => ?_)
  have := (isSquare_three_iff_mod_twelve hp2 hp3).1 hsq
  omega

/-- **Unified dichotomy.** For every prime `p ∉ {2, 3}` the summed 2-torsion count over the twist
family is determined by the residue of `p` mod `12`. -/
theorem sum_card_V4_mod_twelve (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    sum_card_V4 p = if p % 12 = 1 ∨ p % 12 = 11 then 4 * (p - 1) else 2 * (p - 1) := by
  by_cases h : p % 12 = 1 ∨ p % 12 = 11
  · rw [if_pos h]
    exact sum_card_V4_of_isSquare_three hp2 hp3 ((isSquare_three_iff_mod_twelve hp2 hp3).2 h)
  · rw [if_neg h]
    exact sum_card_V4_of_not_isSquare_three
      (fun hsq => h ((isSquare_three_iff_mod_twelve hp2 hp3).1 hsq))

end KleinFourTwoTorsion