import Geometry.TaxicabCubicReps

/-!
# Cabtaxi numbers: the signed Fermat cubic and how much cheaper signs are

This file studies the *full* affine cubic `x³ + y³ = N` over `ℤ` (both signs allowed,
`x, y ≠ 0`), the "cabtaxi" setting, and compares it with the positive-orthant
("taxicab") setting of `Geometry.TaxicabCubicReps`.

Main results.

* `signed_sq_bound` — a geometric a priori bound: any lattice point of the signed cubic
  `x³ + y³ = N` (`N > 0`, `x, y ≠ 0`) satisfies `x² ≤ N` and `y² ≤ N`. In particular the
  hyperbola-like branch in the second/fourth quadrant is *quantitatively* trapped, which
  is what makes the signed problem finite.
* `signedCubeReps_91`, `cabtaxi_two_eq_91` — `Cabtaxi 2 = 91`: `91 = 3³ + 4³ = 6³ − 5³`
  and no smaller positive integer has two signed representations.
* `cabtaxi_two_lt_taxicab_two` — **Conjecture 4 for `n = 2`, proved**: allowing a negative
  summand strictly lowers the least number with two representations, `91 < 1729`.
* `signedCubeReps_728`, `cabtaxi_three_eq_728` — `Cabtaxi 3 = 728`, with
  `728 = 6³ + 8³ = 9³ − 1³ = 12³ − 10³`, while `728` has only one *positive* representation.
* `cubeReps_card_le_signed` — the unsigned count never exceeds the signed count, and
  `signed_gap_728` shows the gap can be as large as `3 : 1` already at `728`.
-/

namespace Taxicab

open Finset

/-- Representations of `N` as a sum of two nonzero **integer** cubes, `a ≤ b`.
The ambient box `[-N, N]²` is harmless (see `mem_signedCubeReps`). -/
def signedCubeReps (N : ℕ) : Finset (ℤ × ℤ) :=
  ((Finset.Icc (-(N : ℤ)) N) ×ˢ (Finset.Icc (-(N : ℤ)) N)).filter
    fun p => p.1 ≠ 0 ∧ p.2 ≠ 0 ∧ p.1 ≤ p.2 ∧ p.1 ^ 3 + p.2 ^ 3 = (N : ℤ)

/-- An integer `≤ -1` has cube `≤ -1`. -/
private theorem cube_le_neg_one {x : ℤ} (hx : x ≤ -1) : x ^ 3 ≤ -1 := by
  have h1 : (1 : ℤ) ≤ x ^ 2 := by nlinarith
  have h2 : x * x ^ 2 ≤ x * 1 := mul_le_mul_of_nonpos_left h1 (by linarith)
  nlinarith [h2]

/-- An integer `≥ 1` has cube `≥` its square. -/
private theorem sq_le_cube {x : ℤ} (hx : 1 ≤ x) : x ^ 2 ≤ x ^ 3 := by nlinarith

/-- **A priori bound on the signed cubic.** Every nonzero integral point of
`x³ + y³ = N` with `N > 0` satisfies `x² ≤ N` and `y² ≤ N`.

For points in the positive quadrant this is immediate; the content is the branch with
`x < 0 < y`, where `N = y³ - |x|³ = (y - |x|)(y² + y|x| + x²) ≥ y² + y|x| + x²`. -/
theorem signed_sq_bound {N : ℕ} (hN : 0 < N) {a b : ℤ} (ha : a ≠ 0) (hb : b ≠ 0)
    (hab : a ≤ b) (h : a ^ 3 + b ^ 3 = (N : ℤ)) : a ^ 2 ≤ (N : ℤ) ∧ b ^ 2 ≤ (N : ℤ) := by
  have hNpos : (0 : ℤ) < (N : ℤ) := by exact_mod_cast hN
  have hbpos : 0 < b := by
    rcases lt_trichotomy b 0 with hb' | hb' | hb'
    · exfalso
      have ha' : a ≤ -1 := by omega
      have hb'' : b ≤ -1 := by omega
      have := cube_le_neg_one ha'
      have := cube_le_neg_one hb''
      linarith [h, hNpos]
    · exact absurd hb' hb
    · exact hb'
  rcases lt_trichotomy a 0 with ha' | ha' | ha'
  · -- the mixed-sign branch
    obtain ⟨k, rfl⟩ : ∃ k, a = -k := ⟨-a, by ring⟩
    have hk1 : 1 ≤ k := by omega
    have hlt : k < b := by
      by_contra hc
      push_neg at hc
      have hcube : b ^ 3 ≤ k ^ 3 := pow_le_pow_left₀ hbpos.le hc 3
      nlinarith [h]
    have hb1 : 1 ≤ b - k := by omega
    have hexp : (b - k) * (b ^ 2 + b * k + k ^ 2) = (N : ℤ) := by rw [← h]; ring
    have hsum : b ^ 2 + b * k + k ^ 2 ≤ (N : ℤ) := by nlinarith [hexp, hb1, hk1, hbpos]
    constructor
    · nlinarith [hsum, hk1, hbpos]
    · nlinarith [hsum, hk1, hbpos]
  · exact absurd ha' ha
  · -- the positive quadrant
    have ha1 : 1 ≤ a := ha'
    have hb1 : 1 ≤ b := hab.trans' ha1
    have hbcube : b ^ 2 ≤ b ^ 3 := sq_le_cube hb1
    have hacube : (1 : ℤ) ≤ a ^ 3 := one_le_pow₀ ha1
    have hbsq : b ^ 2 ≤ (N : ℤ) := by linarith [h, hbcube, hacube]
    have ha0 : (0 : ℤ) ≤ a := by linarith
    have hasq : a ^ 2 ≤ b ^ 2 := pow_le_pow_left₀ ha0 hab 2
    exact ⟨le_trans hasq hbsq, hbsq⟩

/-- Membership in `signedCubeReps` is exactly "being a signed representation". -/
theorem mem_signedCubeReps {N : ℕ} (hN : 0 < N) {p : ℤ × ℤ} :
    p ∈ signedCubeReps N ↔
      p.1 ≠ 0 ∧ p.2 ≠ 0 ∧ p.1 ≤ p.2 ∧ p.1 ^ 3 + p.2 ^ 3 = (N : ℤ) := by
  simp only [signedCubeReps, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
  constructor
  · rintro ⟨_, h⟩; exact h
  · rintro ⟨h1, h2, h3, h4⟩
    obtain ⟨hb1, hb2⟩ := signed_sq_bound hN h1 h2 h3 h4
    refine ⟨⟨⟨?_, ?_⟩, ?_, ?_⟩, h1, h2, h3, h4⟩ <;> nlinarith [hb1, hb2, sq_nonneg p.1,
      sq_nonneg p.2, sq_nonneg (p.1 - 1), sq_nonneg (p.1 + 1), sq_nonneg (p.2 - 1),
      sq_nonneg (p.2 + 1)]

/-- Localisation to a small box: if `N < (B+1)²` then every signed representation of `N`
lives in `[-B, B]²`. -/
theorem signedCubeReps_eq_box {N B : ℕ} (hN : 0 < N) (hNB : N < (B + 1) ^ 2) :
    signedCubeReps N = ((Finset.Icc (-(B : ℤ)) B) ×ˢ (Finset.Icc (-(B : ℤ)) B)).filter
      fun p => p.1 ≠ 0 ∧ p.2 ≠ 0 ∧ p.1 ≤ p.2 ∧ p.1 ^ 3 + p.2 ^ 3 = (N : ℤ) := by
  have hNB' : (N : ℤ) < ((B : ℤ) + 1) ^ 2 := by exact_mod_cast hNB
  ext p
  rw [mem_signedCubeReps hN]
  simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
  constructor
  · rintro ⟨h1, h2, h3, h4⟩
    obtain ⟨hb1, hb2⟩ := signed_sq_bound hN h1 h2 h3 h4
    refine ⟨⟨⟨?_, ?_⟩, ?_, ?_⟩, h1, h2, h3, h4⟩ <;> nlinarith [hb1, hb2, hNB']
  · rintro ⟨_, h⟩; exact h

/-- The finite search space used for the minimality computations: nonzero ordered pairs in
`[-B,B]²` whose cube sum lies strictly between `0` and `M`. -/
private def sbox (B M : ℕ) : Finset (ℤ × ℤ) :=
  ((Finset.Icc (-(B : ℤ)) B) ×ˢ (Finset.Icc (-(B : ℤ)) B)).filter
    fun p => p.1 ≠ 0 ∧ p.2 ≠ 0 ∧ p.1 ≤ p.2 ∧ 0 < p.1 ^ 3 + p.2 ^ 3 ∧
      p.1 ^ 3 + p.2 ^ 3 < (M : ℤ)

private theorem signedCubeReps_eq_sbox_filter {N B M : ℕ} (hN : 0 < N) (hNM : N < M)
    (hNB : N < (B + 1) ^ 2) :
    signedCubeReps N = (sbox B M).filter fun q => q.1 ^ 3 + q.2 ^ 3 = (N : ℤ) := by
  have hNM' : (N : ℤ) < (M : ℤ) := by exact_mod_cast hNM
  have hNpos : (0 : ℤ) < (N : ℤ) := by exact_mod_cast hN
  rw [signedCubeReps_eq_box hN hNB]
  ext p
  simp only [sbox, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
  constructor
  · rintro ⟨hbox, h1, h2, h3, h4⟩
    exact ⟨⟨hbox, h1, h2, h3, by rw [h4]; exact hNpos, by rw [h4]; exact hNM'⟩, h4⟩
  · rintro ⟨⟨hbox, h1, h2, h3, _, _⟩, h4⟩
    exact ⟨hbox, h1, h2, h3, h4⟩

/-! ## `Cabtaxi 2 = 91` -/

set_option maxRecDepth 20000 in
private theorem sbox_91_unique :
    ∀ p ∈ sbox 9 91, ((sbox 9 91).filter fun q => q.1 ^ 3 + q.2 ^ 3 = p.1 ^ 3 + p.2 ^ 3).card
      ≤ 1 := by decide

/-- **Minimality half of `Cabtaxi 2 = 91`.** No positive integer below `91` is a sum of two
nonzero integer cubes in two essentially different ways. -/
theorem signedCubeReps_card_le_one_of_lt_91 {N : ℕ} (hN : 0 < N) (h : N < 91) :
    (signedCubeReps N).card ≤ 1 := by
  rcases Finset.eq_empty_or_nonempty (signedCubeReps N) with hemp | ⟨p, hp⟩
  · simp [hemp]
  have hbox : signedCubeReps N = (sbox 9 91).filter fun q => q.1 ^ 3 + q.2 ^ 3 = (N : ℤ) :=
    signedCubeReps_eq_sbox_filter hN h (by omega)
  have hp' : p ∈ sbox 9 91 ∧ p.1 ^ 3 + p.2 ^ 3 = (N : ℤ) := by
    rw [hbox, Finset.mem_filter] at hp; exact hp
  have := sbox_91_unique p hp'.1
  rw [hp'.2] at this
  rw [hbox]
  exact this

set_option maxRecDepth 20000 in
/-- `91 = 3³ + 4³ = 6³ − 5³`, and these are its only signed representations. -/
theorem signedCubeReps_91 : signedCubeReps 91 = {(-5, 6), (3, 4)} := by
  rw [signedCubeReps_eq_box (B := 9) (by norm_num) (by norm_num)]
  decide

theorem signedCubeReps_card_91 : (signedCubeReps 91).card = 2 := by
  rw [signedCubeReps_91]; decide

/-- **`Cabtaxi 2 = 91`.** -/
theorem cabtaxi_two_eq_91 :
    2 ≤ (signedCubeReps 91).card ∧ ∀ N, 0 < N → N < 91 → (signedCubeReps N).card < 2 := by
  refine ⟨by rw [signedCubeReps_card_91], fun N hN h => ?_⟩
  have := signedCubeReps_card_le_one_of_lt_91 hN h
  omega

/-- **Conjecture 4 for `n = 2`, proved.** Signs are strictly cheaper: the least number with
two signed representations is `91`, whereas the least number with two positive
representations is `1729`. -/
theorem cabtaxi_two_lt_taxicab_two :
    (2 ≤ (signedCubeReps 91).card ∧ ∀ N, 0 < N → N < 91 → (signedCubeReps N).card < 2) ∧
    (2 ≤ (cubeReps 1729).card ∧ ∀ N < 1729, (cubeReps N).card < 2) ∧ (91 : ℕ) < 1729 :=
  ⟨cabtaxi_two_eq_91, taxicab_two_eq_1729, by norm_num⟩

/-! ## `Cabtaxi 3 = 728` -/

set_option maxRecDepth 100000 in
private theorem sbox_728_unique :
    ∀ p ∈ sbox 26 728,
      ((sbox 26 728).filter fun q => q.1 ^ 3 + q.2 ^ 3 = p.1 ^ 3 + p.2 ^ 3).card ≤ 2 := by
  decide

set_option maxRecDepth 100000 in
/-- **Minimality half of `Cabtaxi 3 = 728`.** No positive integer below `728` has three
essentially different signed representations. -/
theorem signedCubeReps_card_le_two_of_lt_728 {N : ℕ} (hN : 0 < N) (h : N < 728) :
    (signedCubeReps N).card ≤ 2 := by
  rcases Finset.eq_empty_or_nonempty (signedCubeReps N) with hemp | ⟨p, hp⟩
  · simp [hemp]
  have hbox : signedCubeReps N = (sbox 26 728).filter fun q => q.1 ^ 3 + q.2 ^ 3 = (N : ℤ) :=
    signedCubeReps_eq_sbox_filter hN h (by omega)
  have hp' : p ∈ sbox 26 728 ∧ p.1 ^ 3 + p.2 ^ 3 = (N : ℤ) := by
    rw [hbox, Finset.mem_filter] at hp; exact hp
  have := sbox_728_unique p hp'.1
  rw [hp'.2] at this
  rw [hbox]
  exact this

set_option maxRecDepth 40000 in
/-- `728 = 6³ + 8³ = 9³ − 1³ = 12³ − 10³`, and these are its only signed representations. -/
theorem signedCubeReps_728 : signedCubeReps 728 = {(-10, 12), (-1, 9), (6, 8)} := by
  rw [signedCubeReps_eq_box (B := 26) (by norm_num) (by norm_num)]
  decide

theorem signedCubeReps_card_728 : (signedCubeReps 728).card = 3 := by
  rw [signedCubeReps_728]; decide

/-- **`Cabtaxi 3 = 728`.** -/
theorem cabtaxi_three_eq_728 :
    3 ≤ (signedCubeReps 728).card ∧ ∀ N, 0 < N → N < 728 → (signedCubeReps N).card < 3 := by
  refine ⟨by rw [signedCubeReps_card_728], fun N hN h => ?_⟩
  have := signedCubeReps_card_le_two_of_lt_728 hN h
  omega

/-! ## Comparing the signed and unsigned counts -/

/-- Every positive representation is a signed representation. -/
theorem cubeReps_card_le_signed (N : ℕ) (hN : 0 < N) :
    (cubeReps N).card ≤ (signedCubeReps N).card := by
  have hmap : ∀ p ∈ cubeReps N, ((p.1 : ℤ), (p.2 : ℤ)) ∈ signedCubeReps N := by
    intro p hp
    rw [mem_cubeReps] at hp
    obtain ⟨h1, h2, h3⟩ := hp
    have hb : 0 < p.2 := lt_of_lt_of_le h1 h2
    rw [mem_signedCubeReps hN]
    dsimp only
    refine ⟨?_, ?_, ?_, ?_⟩
    · exact_mod_cast h1.ne'
    · exact_mod_cast hb.ne'
    · exact_mod_cast h2
    · exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) h3
  refine Finset.card_le_card_of_injOn (fun p => ((p.1 : ℤ), (p.2 : ℤ))) hmap ?_
  rintro ⟨a, b⟩ _ ⟨c, d⟩ _ heq
  simp only [Prod.mk.injEq, Nat.cast_inj] at heq
  simp [heq.1, heq.2]

set_option maxRecDepth 10000 in
theorem cubeReps_728 : cubeReps 728 = {(6, 8)} := by
  ext p
  rw [mem_cubeReps]
  constructor
  · intro hp
    have hb : p.2 ≤ 8 := by
      by_contra hc
      have : 9 ^ 3 ≤ p.2 ^ 3 := Nat.pow_le_pow_left (by omega) 3
      omega
    have hmem : p ∈ (Finset.Icc 1 8 ×ˢ Finset.Icc 1 8).filter
        (fun q => q.1 ≤ q.2 ∧ q.1 ^ 3 + q.2 ^ 3 = 728) := by
      simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
      exact ⟨⟨⟨hp.1, le_trans hp.2.1 hb⟩, by omega, hb⟩, hp.2⟩
    have hcalc : (Finset.Icc 1 8 ×ˢ Finset.Icc 1 8).filter
        (fun q => q.1 ≤ q.2 ∧ q.1 ^ 3 + q.2 ^ 3 = 728) = {(6, 8)} := by decide
    rw [hcalc] at hmem
    exact hmem
  · intro hp
    simp only [Finset.mem_singleton] at hp
    subst hp
    norm_num

/-- **The signed count can strictly dominate the unsigned count.** At `N = 728` the signed
cubic carries three representations while the positive orthant carries only one. -/
theorem signed_gap_728 :
    (cubeReps 728).card = 1 ∧ (signedCubeReps 728).card = 3 ∧
      (cubeReps 728).card < (signedCubeReps 728).card := by
  refine ⟨by rw [cubeReps_728]; rfl, signedCubeReps_card_728, ?_⟩
  rw [signedCubeReps_card_728, cubeReps_728]
  norm_num

end Taxicab