import Mathlib

/-!
# Effective density of coprime pairs in a square, with parity refinement

This file proves a completely explicit, effective lower bound for the number of
coprime pairs `(n, m)` with `1 ≤ n < m ≤ X` and `n + m` odd:

    `11 * X^2 ≤ 144 * (copOpp X).card + 36`.

The proof is elementary and self-contained (no analytic number theory):

* the number of pairs in the square `[1,X]^2` is `X^2`;
* a pair whose gcd is `g ≥ 2` is `g` times a pair in `[1, X/g]^2`, so the number
  of *non*-coprime pairs is at most `∑_{g=2}^{X} ⌊X/g⌋^2 ≤ (25/36) X^2`,
  using `∑_{g ≥ 2} 1/g^2 ≤ 1/4 + 1/9 + 1/3 = 25/36`;
* symmetry (swapping the two coordinates) costs a factor `2`;
* pairs of two odd coprime numbers inject into opposite-parity coprime pairs via
  `(n, m) ↦ ((m-n)/2, (m+n)/2)`, costing another factor `2`.

This is the arithmetic input for the counting of primitive Pythagorean triples,
and hence of Berggren-generated triples, in a box.
-/

namespace CoprimePairDensity

open Finset

/-- All pairs in the square `[1,X] × [1,X]`. -/
def sq (X : ℕ) : Finset (ℕ × ℕ) := Finset.Icc 1 X ×ˢ Finset.Icc 1 X

lemma card_sq (X : ℕ) : (sq X).card = X ^ 2 := by
  simp [sq, Nat.card_Icc, pow_two]

/-- Coprime pairs in the square `[1,X] × [1,X]`. -/
def cop (X : ℕ) : Finset (ℕ × ℕ) := (sq X).filter (fun p => Nat.gcd p.1 p.2 = 1)

/-- Non-coprime pairs in the square `[1,X] × [1,X]`. -/
def bad (X : ℕ) : Finset (ℕ × ℕ) := (sq X).filter (fun p => ¬ (Nat.gcd p.1 p.2 = 1))

lemma card_cop_add_card_bad (X : ℕ) : (cop X).card + (bad X).card = X ^ 2 := by
  rw [cop, bad, Finset.card_filter_add_card_filter_not, card_sq]

/-- Every non-coprime pair in the square is `g`-times a pair in the smaller square,
where `g` is its gcd. -/
lemma bad_subset (X : ℕ) :
    bad X ⊆ (Finset.Icc 2 X).biUnion
      (fun g => (sq (X / g)).image (fun p => (g * p.1, g * p.2))) := by
  rintro ⟨n, m⟩ hp
  simp only [bad, sq, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc] at hp
  obtain ⟨⟨⟨hn1, hnX⟩, hm1, hmX⟩, hg⟩ := hp
  set g := Nat.gcd n m with hgdef
  have hgn : g ∣ n := Nat.gcd_dvd_left n m
  have hgm : g ∣ m := Nat.gcd_dvd_right n m
  have hgpos : 0 < g := Nat.gcd_pos_of_pos_left _ hn1
  have hg2 : 2 ≤ g := by omega
  have hgX : g ≤ X := le_trans (Nat.le_of_dvd (by omega) hgn) hnX
  refine Finset.mem_biUnion.2 ⟨g, Finset.mem_Icc.2 ⟨hg2, hgX⟩, ?_⟩
  refine Finset.mem_image.2 ⟨(n / g, m / g), ?_, ?_⟩
  · simp only [sq, Finset.mem_product, Finset.mem_Icc]
    refine ⟨⟨?_, ?_⟩, ?_, ?_⟩
    · exact Nat.one_le_div_iff hgpos |>.2 (Nat.le_of_dvd (by omega) hgn)
    · exact Nat.div_le_div_right hnX
    · exact Nat.one_le_div_iff hgpos |>.2 (Nat.le_of_dvd (by omega) hgm)
    · exact Nat.div_le_div_right hmX
  · simp [Nat.mul_div_cancel' hgn, Nat.mul_div_cancel' hgm]

lemma card_bad_le (X : ℕ) : (bad X).card ≤ ∑ g ∈ Finset.Icc 2 X, (X / g) ^ 2 := by
  refine le_trans (Finset.card_le_card (bad_subset X)) ?_
  refine le_trans (Finset.card_biUnion_le) ?_
  refine Finset.sum_le_sum ?_
  intro g _
  exact le_trans (Finset.card_image_le) (le_of_eq (card_sq _))

/-- Tail bound `∑_{g=4}^{X} 1/g^2 ≤ 1/3 - 1/X` (for `X ≥ 3`), by telescoping. -/
lemma sum_inv_sq_tail (X : ℕ) (hX : 3 ≤ X) :
    (∑ g ∈ Finset.Icc 4 X, (1 : ℚ) / (g : ℚ) ^ 2) ≤ 1 / 3 - 1 / (X : ℚ) := by
  induction X with
  | zero => omega
  | succ n ih =>
    rcases Nat.lt_or_ge n 3 with hn | hn
    · have : n = 2 := by omega
      subst this
      norm_num
    · have hn0 : (0 : ℚ) < (n : ℚ) := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hn
      have hsum := ih hn
      rw [Finset.sum_Icc_succ_top (by omega)]
      push_cast
      have hkey : (1 : ℚ) / ((n : ℚ) + 1) ^ 2 ≤ 1 / (n : ℚ) - 1 / ((n : ℚ) + 1) := by
        rw [div_sub_div _ _ (ne_of_gt hn0) (by positivity)]
        rw [div_le_div_iff₀ (by positivity) (by positivity)]
        nlinarith [hn0]
      linarith

/-- `∑_{g=2}^{X} 1/g^2 ≤ 25/36`. -/
lemma sum_inv_sq_le (X : ℕ) :
    (∑ g ∈ Finset.Icc 2 X, (1 : ℚ) / (g : ℚ) ^ 2) ≤ 25 / 36 := by
  have hIcc22 : Finset.Icc (2:ℕ) 2 = ({2} : Finset ℕ) := rfl
  have hIcc23 : Finset.Icc (2:ℕ) 3 = ({2, 3} : Finset ℕ) := rfl
  rcases Nat.lt_or_ge X 4 with hX | hX
  · interval_cases X <;> norm_num [hIcc22, hIcc23]
  · have hsplit : Finset.Icc 2 X = Finset.Icc 2 3 ∪ Finset.Icc 4 X := by
      ext g; simp only [Finset.mem_Icc, Finset.mem_union]; omega
    have hdisj : Disjoint (Finset.Icc 2 3) (Finset.Icc 4 X) := by
      rw [Finset.disjoint_left]
      intro g hg hg'
      simp only [Finset.mem_Icc] at hg hg'
      omega
    rw [hsplit, Finset.sum_union hdisj]
    have h1 : (∑ g ∈ Finset.Icc (2:ℕ) 3, (1 : ℚ) / (g : ℚ) ^ 2) = 13 / 36 := by
      rw [hIcc23]; norm_num
    have h2 := sum_inv_sq_tail X (by omega)
    have h3 : (0 : ℚ) < (X : ℚ) := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hX
    have : (1 : ℚ) / (X : ℚ) > 0 := by positivity
    linarith

/-- The counting bound in the full square: at least `11/36` of all pairs are coprime. -/
theorem card_cop_ge (X : ℕ) : 11 * X ^ 2 ≤ 36 * (cop X).card := by
  have hbad : 36 * (∑ g ∈ Finset.Icc 2 X, (X / g) ^ 2) ≤ 25 * X ^ 2 := by
    have hQ : (36 : ℚ) * (∑ g ∈ Finset.Icc 2 X, (((X / g : ℕ) : ℚ)) ^ 2) ≤ 25 * (X : ℚ) ^ 2 := by
      have hterm : ∀ g ∈ Finset.Icc 2 X, (((X / g : ℕ) : ℚ)) ^ 2 ≤ (X : ℚ) ^ 2 * (1 / (g : ℚ) ^ 2) := by
        intro g hg
        simp only [Finset.mem_Icc] at hg
        have hg0 : (0 : ℚ) < (g : ℚ) := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hg.1
        have hle : (((X / g : ℕ) : ℚ)) ≤ (X : ℚ) / (g : ℚ) := Nat.cast_div_le
        have hnn : (0 : ℚ) ≤ ((X / g : ℕ) : ℚ) := by positivity
        calc (((X / g : ℕ) : ℚ)) ^ 2 ≤ ((X : ℚ) / (g : ℚ)) ^ 2 := by nlinarith
          _ = (X : ℚ) ^ 2 * (1 / (g : ℚ) ^ 2) := by field_simp
      have hsum : (∑ g ∈ Finset.Icc 2 X, (((X / g : ℕ) : ℚ)) ^ 2)
          ≤ ∑ g ∈ Finset.Icc 2 X, (X : ℚ) ^ 2 * (1 / (g : ℚ) ^ 2) := Finset.sum_le_sum hterm
      rw [← Finset.mul_sum] at hsum
      have hX2 : (0 : ℚ) ≤ (X : ℚ) ^ 2 := by positivity
      nlinarith [sum_inv_sq_le X, hsum]
    have := hQ
    push_cast at this
    exact_mod_cast this
  have h1 := card_cop_add_card_bad X
  have h2 := card_bad_le X
  set S := X ^ 2
  set B := ∑ g ∈ Finset.Icc 2 X, (X / g) ^ 2
  omega

/-- Coprime pairs with `n < m`. -/
def copLt (X : ℕ) : Finset (ℕ × ℕ) := (cop X).filter (fun p => p.1 < p.2)

theorem card_cop_le_two_mul_copLt (X : ℕ) : (cop X).card ≤ 2 * (copLt X).card + 1 := by
  have hsplit : (copLt X).card + ((cop X).filter (fun p => ¬ p.1 < p.2)).card = (cop X).card := by
    rw [copLt]; exact Finset.card_filter_add_card_filter_not _
  have hge : ((cop X).filter (fun p => ¬ p.1 < p.2))
      ⊆ insert ((1 : ℕ), (1 : ℕ)) ((copLt X).image Prod.swap) := by
    rintro ⟨n, m⟩ hp
    simp only [Finset.mem_filter, cop, sq, Finset.mem_product, Finset.mem_Icc, not_lt] at hp
    obtain ⟨⟨⟨⟨hn1, hnX⟩, hm1, hmX⟩, hgcd⟩, hmn⟩ := hp
    rcases eq_or_lt_of_le hmn with heq | hlt
    · -- m = n forces n = 1
      subst heq
      have : Nat.gcd m m = m := Nat.gcd_self m
      rw [this] at hgcd
      simp [hgcd]
    · refine Finset.mem_insert_of_mem (Finset.mem_image.2 ⟨(m, n), ?_, rfl⟩)
      simp only [copLt, cop, sq, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
      exact ⟨⟨⟨⟨hm1, hmX⟩, hn1, hnX⟩, by rwa [Nat.gcd_comm]⟩, hlt⟩
  have hcard : ((cop X).filter (fun p => ¬ p.1 < p.2)).card ≤ (copLt X).card + 1 := by
    refine le_trans (Finset.card_le_card hge) ?_
    refine le_trans (Finset.card_insert_le _ _) ?_
    have := Finset.card_image_le (s := copLt X) (f := Prod.swap)
    omega
  omega

/-- Coprime pairs with `n < m` and `n + m` odd (opposite parity). -/
def copOpp (X : ℕ) : Finset (ℕ × ℕ) := (copLt X).filter (fun p => (p.1 + p.2) % 2 = 1)

lemma mem_copLt {X : ℕ} {p : ℕ × ℕ} :
    p ∈ copLt X ↔
      1 ≤ p.1 ∧ p.1 ≤ X ∧ 1 ≤ p.2 ∧ p.2 ≤ X ∧ Nat.gcd p.1 p.2 = 1 ∧ p.1 < p.2 := by
  constructor
  · intro h
    obtain ⟨h1, hlt⟩ := Finset.mem_filter.mp h
    obtain ⟨h2, hg⟩ := Finset.mem_filter.mp h1
    obtain ⟨hA, hB⟩ := Finset.mem_product.mp h2
    obtain ⟨ha1, ha2⟩ := Finset.mem_Icc.mp hA
    obtain ⟨hb1, hb2⟩ := Finset.mem_Icc.mp hB
    exact ⟨ha1, ha2, hb1, hb2, hg, hlt⟩
  · rintro ⟨ha1, ha2, hb1, hb2, hg, hlt⟩
    refine Finset.mem_filter.mpr ⟨Finset.mem_filter.mpr ⟨Finset.mem_product.mpr ⟨?_, ?_⟩, hg⟩, hlt⟩
    · exact Finset.mem_Icc.mpr ⟨ha1, ha2⟩
    · exact Finset.mem_Icc.mpr ⟨hb1, hb2⟩

lemma mem_copOpp {X : ℕ} {p : ℕ × ℕ} :
    p ∈ copOpp X ↔
      1 ≤ p.1 ∧ p.1 ≤ X ∧ 1 ≤ p.2 ∧ p.2 ≤ X ∧ Nat.gcd p.1 p.2 = 1 ∧ p.1 < p.2 ∧
        (p.1 + p.2) % 2 = 1 := by
  constructor
  · intro h
    obtain ⟨h1, hpar⟩ := Finset.mem_filter.mp h
    obtain ⟨ha1, ha2, hb1, hb2, hg, hlt⟩ := mem_copLt.mp h1
    exact ⟨ha1, ha2, hb1, hb2, hg, hlt, hpar⟩
  · rintro ⟨ha1, ha2, hb1, hb2, hg, hlt, hpar⟩
    exact Finset.mem_filter.mpr ⟨mem_copLt.mpr ⟨ha1, ha2, hb1, hb2, hg, hlt⟩, hpar⟩

theorem card_copLt_le_two_mul_copOpp (X : ℕ) : (copLt X).card ≤ 2 * (copOpp X).card := by
  have hsplit : (copOpp X).card + ((copLt X).filter (fun p => ¬ (p.1 + p.2) % 2 = 1)).card
      = (copLt X).card := by
    rw [copOpp]; exact Finset.card_filter_add_card_filter_not _
  -- the both-odd coprime pairs inject into the opposite-parity ones
  have hinj : ((copLt X).filter (fun p => ¬ (p.1 + p.2) % 2 = 1)).card ≤ (copOpp X).card := by
    refine Finset.card_le_card_of_injOn (fun p => ((p.2 - p.1) / 2, (p.2 + p.1) / 2)) ?_ ?_
    · rintro ⟨n, m⟩ hp
      obtain ⟨hp1, hpar⟩ := Finset.mem_filter.mp hp
      obtain ⟨hn1, hnX, hm1, hmX, hgcd, hnm⟩ := mem_copLt.mp hp1
      simp only at hn1 hnX hm1 hmX hgcd hnm hpar
      have hnodd : n % 2 = 1 ∧ m % 2 = 1 := by
        rcases Nat.even_or_odd n with hn | hn
        · rcases Nat.even_or_odd m with hm | hm
          · exfalso
            obtain ⟨k, hk⟩ := hn; obtain ⟨l, hl⟩ := hm
            have h2n : 2 ∣ n := ⟨k, by omega⟩
            have h2m : 2 ∣ m := ⟨l, by omega⟩
            have hd := Nat.dvd_gcd h2n h2m
            rw [hgcd] at hd
            omega
          · exfalso; obtain ⟨k, hk⟩ := hn; obtain ⟨l, hl⟩ := hm; omega
        · rcases Nat.even_or_odd m with hm | hm
          · exfalso; obtain ⟨k, hk⟩ := hn; obtain ⟨l, hl⟩ := hm; omega
          · obtain ⟨k, hk⟩ := hn; obtain ⟨l, hl⟩ := hm; omega
      obtain ⟨hno, hmo⟩ := hnodd
      set a := (m - n) / 2 with ha
      set b := (m + n) / 2 with hb
      have hab : a + b = m := by omega
      have hba : b - a = n := by omega
      have hgab : Nat.gcd a b = 1 := by
        have hd1 : Nat.gcd a b ∣ m := by
          rw [← hab]; exact Nat.dvd_add (Nat.gcd_dvd_left a b) (Nat.gcd_dvd_right a b)
        have hd2 : Nat.gcd a b ∣ n := by
          rw [← hba]; exact Nat.dvd_sub (Nat.gcd_dvd_right a b) (Nat.gcd_dvd_left a b)
        have hd := Nat.dvd_gcd hd2 hd1
        rw [hgcd] at hd
        exact Nat.eq_one_of_dvd_one hd
      refine mem_copOpp.mpr ⟨?_, ?_, ?_, ?_, hgab, ?_, ?_⟩ <;> simp only <;> omega
    · rintro ⟨n, m⟩ hp ⟨n', m'⟩ hp' heq
      obtain ⟨hp1, hpar⟩ := Finset.mem_filter.mp hp
      obtain ⟨hn1, hnX, hm1, hmX, hgcd, hnm⟩ := mem_copLt.mp hp1
      obtain ⟨hp1', hpar'⟩ := Finset.mem_filter.mp hp'
      obtain ⟨hn1', hnX', hm1', hmX', hgcd', hnm'⟩ := mem_copLt.mp hp1'
      simp only at hn1 hnX hm1 hmX hnm hpar hn1' hnX' hm1' hmX' hnm' hpar'
      simp only [Prod.mk.injEq] at heq
      have hkey : n = n' ∧ m = m' := by omega
      simp [hkey.1, hkey.2]
  omega

/-- **Main density bound.** -/
theorem card_copOpp_ge (X : ℕ) : 11 * X ^ 2 ≤ 144 * (copOpp X).card + 36 := by
  have h1 := card_cop_ge X
  have h2 := card_cop_le_two_mul_copLt X
  have h3 := card_copLt_le_two_mul_copOpp X
  set S := X ^ 2
  omega

end CoprimePairDensity