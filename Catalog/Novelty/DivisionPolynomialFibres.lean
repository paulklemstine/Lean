import Mathlib
import Novelty.KleinFourTwoTorsionReciprocity

/-!
# Division polynomials, their factorisation, and fibre counting

This file supplies the *polynomial* half of the picture developed in
`Novelty/KleinFourTwoTorsionReciprocity.lean` and
`Novelty/KleinFourEllipticStructure.lean`:

* the 2-division polynomial `ψ₂-cubic` of `E_d : y² = x³ - 3 d² x` factors into three distinct
  linear factors over `𝔽_p` exactly in the split regime `p ≡ ±1 mod 12`, and into a linear
  factor times an irreducible quadratic in the non-split regime `p ≡ 5, 7 mod 12`
  (`psi2_split`, `psi2_irreducible_quadratic_factor`);

* the 3-division polynomial `ψ₃ = 3 X (X³ + 4b)` of the `j = 0` family `y² = x³ + b` obeys a
  *regime-independent* summed fibre count `∑_{b ≠ 0} #roots(ψ₃) = 2 (p - 1)`
  (`sum_card_psi3_roots`), even though the individual fibre counts jump between `2` and `4`
  according to whether `p ≡ 1` or `2 mod 3`.

The contrast between the two computations isolates exactly which input is arithmetic
(reciprocity for the classes mod 12, controlling `ψ₂`) and which is purely combinatorial
(the fibre-counting bijection `x ↦ x³`, controlling the summed `ψ₃` count).
-/

namespace DivisionPolynomialFibres

open Finset Polynomial

variable {p : ℕ} [Fact p.Prime]

/-! ## The 2-division polynomial -/

/-- The 2-division cubic of `y² = x³ - c x`. -/
noncomputable def psi2 (c : ZMod p) : (ZMod p)[X] := X ^ 3 - C c * X

/-- **Split factorisation.** If `c = s²` then the 2-division cubic splits into three linear
factors, whose roots `0, s, -s` are the `x`-coordinates of the Klein four 2-torsion. -/
theorem psi2_split {c s : ZMod p} (hs : s ^ 2 = c) :
    psi2 c = X * (X - C s) * (X + C s) := by
  subst hs
  simp only [psi2, map_pow]
  ring

/-- **Non-split factorisation.** If `c` is a non-square, the 2-division cubic is the product of
`X` with an irreducible quadratic. -/
theorem psi2_factor (c : ZMod p) : psi2 c = X * (X ^ 2 - C c) := by
  simp only [psi2]; ring

theorem psi2_irreducible_quadratic_factor {c : ZMod p} (hns : ¬ IsSquare c) :
    Irreducible (X ^ 2 - C c : (ZMod p)[X]) := by
  have hdeg : (X ^ 2 - C c : (ZMod p)[X]).natDegree = 2 := by
    simp
  refine Polynomial.irreducible_of_degree_le_three_of_not_isRoot (by simp [hdeg]) ?_
  intro x hx
  rw [IsRoot, eval_sub, eval_pow, eval_X, eval_C, sub_eq_zero] at hx
  exact hns ⟨x, by rw [← hx]; ring⟩

/-- The `x`-coordinates of the affine 2-torsion are precisely the roots of `psi2`. -/
theorem isRoot_psi2_iff {c x : ZMod p} : (psi2 c).IsRoot x ↔ x ^ 3 = c * x := by
  simp only [psi2, IsRoot, eval_sub, eval_pow, eval_X, eval_mul, eval_C, sub_eq_zero]

/-! ## Cubing in characteristic `p ≡ 2 mod 3` -/

/-- If `p ≡ 2 mod 3` then cubing is injective on `𝔽_p`: this is the "`gcd(3, p-1) = 1`"
mechanism, made explicit by the exponent `k` with `3k = 2(p-1) + 1`. -/
theorem cube_injective (hp3 : p % 3 = 2) : Function.Injective fun x : ZMod p => x ^ 3 := by
  obtain ⟨k, hk⟩ : ∃ k : ℕ, 3 * k = 2 * (p - 1) + 1 := by
    have hp1 : 1 ≤ p := (Fact.out : p.Prime).one_le
    exact ⟨(2 * (p - 1) + 1) / 3, by omega⟩
  have key : ∀ x : ZMod p, (x ^ 3) ^ k = x := by
    intro x
    rcases eq_or_ne x 0 with rfl | hx
    · have hk0 : k ≠ 0 := by rintro rfl; omega
      simp [zero_pow, hk0]
    · have hfermat : x ^ (p - 1) = 1 := ZMod.pow_card_sub_one_eq_one hx
      rw [← pow_mul, hk, pow_succ, mul_comm 2 (p - 1), pow_mul, hfermat, one_pow, one_mul]
  intro a b hab
  simpa only [key] using congrArg (fun t : ZMod p => t ^ k) hab

/-- If `p ≡ 2 mod 3` then every element of `𝔽_p` has exactly one cube root. -/
theorem card_cube_roots_of_mod_three_eq_two (hp3 : p % 3 = 2) (a : ZMod p) :
    (univ.filter fun x : ZMod p => x ^ 3 = a).card = 1 := by
  have hbij : Function.Bijective fun x : ZMod p => x ^ 3 :=
    (Finite.injective_iff_bijective).1 (cube_injective hp3)
  obtain ⟨r, hr⟩ := hbij.2 a
  have : (univ.filter fun x : ZMod p => x ^ 3 = a) = {r} := by
    ext x
    simp only [mem_filter, mem_univ, true_and, mem_singleton]
    exact ⟨fun hx => hbij.1 (hx.trans hr.symm), fun hx => by rw [hx]; exact hr⟩
  rw [this, card_singleton]

/-! ## The 3-division polynomial of the `j = 0` family -/

/-- The 3-division polynomial of `y² = x³ + b`. -/
noncomputable def psi3 (b : ZMod p) : (ZMod p)[X] := C 3 * X ^ 4 + C (12 * b) * X

theorem psi3_factor (b : ZMod p) : psi3 b = C 3 * X * (X ^ 3 + C (4 * b)) := by
  have h12 : (C (12 * b) : (ZMod p)[X]) = C 3 * (C 4 * C b) := by
    rw [show (12 : ZMod p) * b = 3 * (4 * b) by ring, map_mul, map_mul]
  have h4 : (C (4 * b) : (ZMod p)[X]) = C 4 * C b := by rw [map_mul]
  rw [psi3, h12, h4]
  ring

theorem isRoot_psi3_iff {b x : ZMod p} (h3 : (3 : ZMod p) ≠ 0) :
    (psi3 b).IsRoot x ↔ x = 0 ∨ x ^ 3 = -(4 * b) := by
  have he : (psi3 b).eval x = 3 * x * (x ^ 3 + 4 * b) := by
    simp only [psi3, eval_add, eval_mul, eval_pow, eval_C, eval_X]
    ring
  rw [IsRoot, he]
  constructor
  · intro h
    rcases mul_eq_zero.1 h with h' | h'
    · rcases mul_eq_zero.1 h' with h'' | h''
      · exact absurd h'' h3
      · exact Or.inl h''
    · exact Or.inr (by linear_combination h')
  · rintro (rfl | h)
    · ring
    · have hz : x ^ 3 + 4 * b = 0 := by linear_combination h
      rw [hz, mul_zero]

/-- The root set of `ψ₃`, for `b ≠ 0`, is `{0}` together with the cube roots of `-4b`. -/
theorem card_roots_psi3 (hp2 : p ≠ 2) (h3 : (3 : ZMod p) ≠ 0) {b : ZMod p} (hb : b ≠ 0) :
    (univ.filter fun x : ZMod p => (psi3 b).IsRoot x).card
      = 1 + (univ.filter fun x : ZMod p => x ^ 3 = -(4 * b)).card := by
  have h4 : (4 : ZMod p) ≠ 0 := by
    have h2 : ((2 : ℕ) : ZMod p) ≠ 0 :=
      KleinFourTwoTorsion.cast_prime_ne_zero Nat.prime_two hp2
    have h2' : (2 : ZMod p) ≠ 0 := by simpa using h2
    intro hcon
    exact h2' (by
      rcases mul_eq_zero.1 (show (2 : ZMod p) * 2 = 0 by linear_combination hcon) with h | h <;>
        exact h)
  have hne : -(4 * b) ≠ 0 := neg_ne_zero.2 (mul_ne_zero h4 hb)
  have hsplit : (univ.filter fun x : ZMod p => (psi3 b).IsRoot x)
      = {(0 : ZMod p)} ∪ (univ.filter fun x : ZMod p => x ^ 3 = -(4 * b)) := by
    ext x
    simp only [mem_filter, mem_univ, true_and, mem_union, mem_singleton, isRoot_psi3_iff h3]
  have hdisj : Disjoint ({(0 : ZMod p)} : Finset (ZMod p))
      (univ.filter fun x : ZMod p => x ^ 3 = -(4 * b)) := by
    simp only [disjoint_singleton_left, mem_filter, mem_univ, true_and]
    intro h
    exact hne (by rw [← h]; ring)
  rw [hsplit, card_union_of_disjoint hdisj, card_singleton]

/-- **Regime-independent fibre count for `ψ₃`.** Summed over the family `y² = x³ + b`,
`b ∈ 𝔽_p^×`, the number of roots of the 3-division polynomial is `2 (p - 1)`, whatever the
residue of `p` mod `3`. The mechanism is the fibre-counting bijection for `x ↦ x³`. -/
theorem sum_card_psi3_roots (hp2 : p ≠ 2) (h3 : (3 : ZMod p) ≠ 0) :
    ∑ b ∈ univ.erase (0 : ZMod p),
        (univ.filter fun x : ZMod p => (psi3 b).IsRoot x).card = 2 * (p - 1) := by
  have h4 : (4 : ZMod p) ≠ 0 := by
    have h2 : ((2 : ℕ) : ZMod p) ≠ 0 :=
      KleinFourTwoTorsion.cast_prime_ne_zero Nat.prime_two hp2
    have h2' : (2 : ZMod p) ≠ 0 := by simpa using h2
    intro hcon
    exact h2' (by
      rcases mul_eq_zero.1 (show (2 : ZMod p) * 2 = 0 by linear_combination hcon) with h | h <;>
        exact h)
  have hterm : ∀ b ∈ univ.erase (0 : ZMod p),
      (univ.filter fun x : ZMod p => (psi3 b).IsRoot x).card
        = 1 + (univ.filter fun x : ZMod p => x ^ 3 = -(4 * b)).card := by
    intro b hb
    exact card_roots_psi3 hp2 h3 (mem_erase.1 hb).1
  rw [sum_congr rfl hterm, sum_add_distrib, sum_const, KleinFourTwoTorsion.card_erase_zero,
    smul_eq_mul, mul_one]
  have hcount : ∑ b ∈ univ.erase (0 : ZMod p),
      (univ.filter fun x : ZMod p => x ^ 3 = -(4 * b)).card = p - 1 := by
    have hmaps : ∀ x ∈ univ.erase (0 : ZMod p), (-x ^ 3 / 4) ∈ univ.erase (0 : ZMod p) := by
      intro x hx
      have hx0 : x ≠ 0 := (mem_erase.1 hx).1
      refine mem_erase.2 ⟨?_, mem_univ _⟩
      intro hcon
      rw [div_eq_zero_iff] at hcon
      rcases hcon with hcon | hcon
      · exact hx0 (pow_eq_zero_iff (n := 3) (by norm_num) |>.1 (by linear_combination -hcon))
      · exact h4 hcon
    have hfib := Finset.card_eq_sum_card_fiberwise hmaps
    have hterm2 : ∀ b ∈ univ.erase (0 : ZMod p),
        ((univ.erase (0 : ZMod p)).filter fun x : ZMod p => -x ^ 3 / 4 = b).card
          = (univ.filter fun x : ZMod p => x ^ 3 = -(4 * b)).card := by
      intro b hb
      have hb0 : b ≠ 0 := (mem_erase.1 hb).1
      congr 1
      ext x
      simp only [mem_filter, mem_erase, mem_univ, true_and, and_true]
      constructor
      · rintro ⟨-, hx⟩
        rw [div_eq_iff h4] at hx
        linear_combination -hx
      · intro hx
        have hx0 : x ≠ 0 := by
          rintro rfl
          apply hb0
          have : (4 : ZMod p) * b = 0 := by linear_combination hx
          rcases mul_eq_zero.1 this with h | h
          · exact absurd h h4
          · exact h
        refine ⟨hx0, ?_⟩
        rw [div_eq_iff h4]
        linear_combination -hx
    rw [← sum_congr rfl hterm2, ← hfib, KleinFourTwoTorsion.card_erase_zero]
  rw [hcount]
  have hp1 : 1 ≤ p := (Fact.out : p.Prime).one_le
  omega

/-- **Individual `ψ₃` fibre count when `3` is inert-like.** For `p ≡ 2 mod 3` every member of
the `j = 0` family has exactly two `x`-coordinates of 3-torsion, consistent with the
regime-independent summed count. -/
theorem card_roots_psi3_of_mod_three_eq_two (hp2 : p ≠ 2) (hpm : p % 3 = 2)
    (h3 : (3 : ZMod p) ≠ 0) {b : ZMod p} (hb : b ≠ 0) :
    (univ.filter fun x : ZMod p => (psi3 b).IsRoot x).card = 2 := by
  rw [card_roots_psi3 hp2 h3 hb, card_cube_roots_of_mod_three_eq_two hpm]

end DivisionPolynomialFibres