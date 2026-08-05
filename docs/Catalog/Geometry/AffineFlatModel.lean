/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.AffineParityOddLower
import Geometry.AffineParityTopDim

/-!
# Affine subspace statistics in `𝔽₂ⁿ`: the flat model versus the cube model

All the results of `Catalog/Applications/AffineSubspaceStats/` and of the companion files
`Catalog/Geometry/AffineParity*.lean` are stated in the **cube model**: a base point `c` and
`d` directions `v₀,…,v_{d-1}` are drawn uniformly and independently, and one counts the
points of `A` among the `2^d` values `c + ∑ yᵢvᵢ`.  The cube is a genuine affine `d`-flat
exactly when the directions are linearly independent, which happens with probability
`1 - O(2^{d-n})`.

This file introduces the **flat model** — the uniform distribution on *independent* direction
tuples, i.e. on genuine `d`-flats — and compares the two models exactly.  The outcome is
that the comparison is not merely asymptotic: the two probabilities differ by the *exact*
factor `#{independent tuples} / 2^{nd}`, because degenerate tuples contribute nothing at all
to the odd-count event (`AffineParityGap.cnt_even_of_not_indep`).

Consequences:

* `AffineFlatModel.oddProb_eq_flatOddProb_mul` : `oddProb = flatOddProb · (K_d / 2^{nd})`,
  an exact identity valid for all `n, d, A` (`K_d` = number of independent `d`-tuples).
* `AffineFlatModel.model_comparison` : hence
  `(1 - (2^{d+1}-1)/2ⁿ) · flatOddProb ≤ oddProb ≤ flatOddProb`, the quantitative
  cube-to-flat transfer.
* `AffineFlatModel.flatOddProb_le` : **the sharp parity bound in the flat model** is
  `2ⁿ / (2(2ⁿ - 2^d))`, *not* `1/2`; equivalently `flatOddProb ≤ 1/2 + 2^{d-1}/(2ⁿ - 2^d)`.
* `AffineFlatModel.flatOddProb_bentSet`, `AffineFlatModel.maxFlatOddProb_two_eq` : for
  `2`-flats in even dimension the bound is *attained* by a bent set, so in the flat model the
  parity probability genuinely **exceeds** `1/2`
  (`AffineFlatModel.maxFlatOddProb_two_gt_half`).  This is in sharp contrast with the cube
  model, where `1/2` is a strict upper bound for every `n` (`AffineParityGap.maxOddProb_lt_half`).
* `AffineFlatModel.flatOddProb_full_eq_one` : at the other extreme `d = n` the flat bound
  equals `1` and is attained by every set of odd cardinality.
-/

namespace AffineFlatModel

open Finset AffineStats AffineParityGap

variable {n d : ℕ}

section Definitions

/-- The number of linearly independent `d`-tuples of directions in `𝔽₂ⁿ`; equivalently the
number of `d`-flats through a fixed point, counted with their parametrisations. -/
def indepCard (n d : ℕ) : ℕ := (univ.filter fun v : Fin d → Vec n => Indep v).card

/-- The parameters describing a genuine affine `d`-flat: a base point and an independent
direction tuple. -/
def flatParams (n d : ℕ) : Finset (Param n d) := univ.filter fun p => Indep p.2

/-- The parameters of a genuine `d`-flat meeting `A` in an odd number of points. -/
def flatOddSet (n d : ℕ) (A : Finset (Vec n)) : Finset (Param n d) :=
  univ.filter fun p => Indep p.2 ∧ ¬ (2 ∣ cnt A p.1 p.2)

/-- `P[|F ∩ A| odd]` in the **flat model**: `F` is a uniformly random *parametrised* affine
`d`-flat, i.e. the direction tuple is uniform among the independent ones. -/
def flatOddProb (n d : ℕ) (A : Finset (Vec n)) : ℚ :=
  ((flatOddSet n d A).card : ℚ) / (indepCard n d * 2 ^ n)

/-- The maximum of the flat-model odd-intersection probability over all `A ⊆ 𝔽₂ⁿ`. -/
def maxFlatOddProb (n d : ℕ) : ℚ :=
  (univ : Finset (Finset (Vec n))).sup' ⟨∅, mem_univ _⟩ (fun A => flatOddProb n d A)

lemma flatOddProb_nonneg (A : Finset (Vec n)) : 0 ≤ flatOddProb n d A := by
  unfold flatOddProb; positivity

lemma card_flatParams (n d : ℕ) : (flatParams n d).card = 2 ^ n * indepCard n d := by
  classical
  have hset : flatParams n d
      = (univ : Finset (Vec n)) ×ˢ (univ.filter fun v : Fin d → Vec n => Indep v) := by
    ext p
    simp [flatParams, Finset.mem_product]
  rw [hset, Finset.card_product, Finset.card_univ, card_Vec, indepCard]

end Definitions

section Comparison

/-- Degenerate direction tuples never give an odd count, so the odd-parameter set of the
cube model already lies inside the flat parameters. -/
lemma flatOddSet_eq_oddSet (A : Finset (Vec n)) : flatOddSet n d A = oddSet n d A := by
  classical
  ext p
  simp only [flatOddSet, oddSet, mem_filter, mem_univ, true_and]
  constructor
  · exact fun h => h.2
  · intro h
    refine ⟨?_, h⟩
    by_contra hw
    exact h (cnt_even_of_not_indep A p.1 hw)

/-- The number of independent tuples, as a rational product. -/
lemma indepCard_cast (hdn : d ≤ n) :
    ((indepCard n d : ℕ) : ℚ) = ∏ i : Fin d, ((2 : ℚ) ^ n - 2 ^ (i : ℕ)) := by
  rw [indepCard, card_indep_eq_prod hdn, Nat.cast_prod]
  refine Finset.prod_congr rfl fun i _ => ?_
  have hle : (2 : ℕ) ^ (i : ℕ) ≤ 2 ^ n :=
    Nat.pow_le_pow_right (by norm_num) (le_trans (le_of_lt i.isLt) hdn)
  push_cast [Nat.cast_sub hle]
  ring

/-- There is at least one independent `d`-tuple as soon as `d ≤ n`. -/
lemma indepCard_pos (hdn : d ≤ n) : 0 < indepCard n d := by
  have hQ : (0 : ℚ) < ((indepCard n d : ℕ) : ℚ) := by
    rw [indepCard_cast hdn]
    refine Finset.prod_pos fun i _ => ?_
    have hlt : (2 : ℚ) ^ (i : ℕ) < 2 ^ n := by
      refine pow_lt_pow_right₀ (by norm_num) ?_
      exact lt_of_lt_of_le i.isLt hdn
    linarith
  exact_mod_cast hQ

/-- Extending an independent tuple: `K_{d+1} = K_d · (2ⁿ - 2^d)`. -/
lemma indepCard_succ_cast (hdn : d + 1 ≤ n) :
    ((indepCard n (d + 1) : ℕ) : ℚ) = (indepCard n d : ℚ) * ((2 : ℚ) ^ n - 2 ^ d) := by
  rw [indepCard_cast hdn, indepCard_cast (by omega : d ≤ n), Fin.prod_univ_castSucc]
  simp

/-- **Exact comparison of the two models.** The cube-model probability is the flat-model
probability times the fraction of independent direction tuples. -/
theorem oddProb_eq_flatOddProb_mul (A : Finset (Vec n)) :
    oddProb n d A = flatOddProb n d A * ((indepCard n d : ℚ) / 2 ^ (n * d)) := by
  classical
  rcases Nat.eq_zero_or_pos (indepCard n d) with hK | hK
  · have hempty : (oddSet n d A).card = 0 := by
      rw [← flatOddSet_eq_oddSet]
      refine Finset.card_eq_zero.2 (Finset.eq_empty_iff_forall_notMem.2 fun p hp => ?_)
      have hp' : Indep p.2 := (mem_filter.1 hp).2.1
      have : p.2 ∈ (univ.filter fun v : Fin d → Vec n => Indep v) := by
        simp [hp']
      have : 0 < indepCard n d := Finset.card_pos.2 ⟨p.2, this⟩
      omega
    simp [oddProb, flatOddProb, hempty, hK]
  · have hKQ : (0 : ℚ) < (indepCard n d : ℚ) := by exact_mod_cast hK
    rw [flatOddProb, oddProb, flatOddSet_eq_oddSet]
    rw [div_mul_div_comm]
    rw [div_eq_div_iff (by positivity) (by positivity)]
    have hpow : (2 : ℚ) ^ (n * (d + 1)) = 2 ^ (n * d) * 2 ^ n := by
      rw [← pow_add]; ring_nf
    rw [hpow]
    ring

/-- The flat-model probability expressed through the cube-model one. -/
lemma flatOddProb_eq_oddProb_div (A : Finset (Vec n)) (hK : indepCard n d ≠ 0) :
    flatOddProb n d A = oddProb n d A * 2 ^ (n * d) / (indepCard n d : ℚ) := by
  have hKQ : ((indepCard n d : ℕ) : ℚ) ≠ 0 := Nat.cast_ne_zero.2 hK
  rw [oddProb_eq_flatOddProb_mul A]
  field_simp

/-- **Cube-to-flat transfer, quantitatively.** The two models differ by a factor between
`1 - (2^{d+1}-1)/2ⁿ` and `1`. -/
theorem model_comparison (A : Finset (Vec n)) :
    (1 - ((2 : ℚ) ^ (d + 1) - 1) / 2 ^ n) * flatOddProb n (d + 1) A
      ≤ oddProb n (d + 1) A ∧ oddProb n (d + 1) A ≤ flatOddProb n (d + 1) A := by
  have hF : 0 ≤ flatOddProb n (d + 1) A := flatOddProb_nonneg A
  set K : ℚ := (indepCard n (d + 1) : ℚ) with hKdef
  have hK0 : 0 ≤ K := by positivity
  have hid := oddProb_eq_flatOddProb_mul (n := n) (d := d + 1) A
  have hKle : K ≤ (2 : ℚ) ^ (n * (d + 1)) := by
    have hnat : indepCard n (d + 1) ≤ 2 ^ (n * (d + 1)) := by
      rw [indepCard]
      refine le_trans (Finset.card_filter_le _ _) ?_
      rw [Finset.card_univ]
      simp [← pow_mul]
    have := (Nat.cast_le (α := ℚ)).2 hnat
    push_cast at this
    simpa [hKdef] using this
  have hKge : (2 : ℚ) ^ (n * (d + 1)) - ((2 : ℚ) ^ (d + 1) - 1) * 2 ^ (n * d) ≤ K := by
    have h := card_indep_ge n d
    have hQ : ((2 : ℚ) ^ (n * (d + 1)))
        ≤ K + ((2 ^ (d + 1) - 1 : ℕ) : ℚ) * 2 ^ (n * d) := by
      have := (Nat.cast_le (α := ℚ)).2 h
      push_cast at this
      simpa [hKdef, indepCard] using this
    have hcast : ((2 ^ (d + 1) - 1 : ℕ) : ℚ) = (2 : ℚ) ^ (d + 1) - 1 := by
      have h1 : (1 : ℕ) ≤ 2 ^ (d + 1) := Nat.one_le_two_pow
      push_cast [Nat.cast_sub h1]
      ring
    rw [hcast] at hQ
    linarith
  have hpow : (2 : ℚ) ^ (n * (d + 1)) = 2 ^ (n * d) * 2 ^ n := by
    rw [← pow_add]; ring_nf
  have hpos : (0 : ℚ) < 2 ^ (n * (d + 1)) := by positivity
  constructor
  · rw [hid]
    have hfac : 1 - ((2 : ℚ) ^ (d + 1) - 1) / 2 ^ n ≤ K / 2 ^ (n * (d + 1)) := by
      rw [le_div_iff₀ hpos]
      have h2n : (0 : ℚ) < 2 ^ n := by positivity
      have : (1 - ((2 : ℚ) ^ (d + 1) - 1) / 2 ^ n) * 2 ^ (n * (d + 1))
          = 2 ^ (n * (d + 1)) - ((2 : ℚ) ^ (d + 1) - 1) * 2 ^ (n * d) := by
        rw [hpow]; field_simp
      rw [this]
      exact hKge
    nlinarith [hF, hfac]
  · rw [hid]
    have hfac : K / 2 ^ (n * (d + 1)) ≤ 1 := by
      rw [div_le_one hpos]; exact hKle
    nlinarith [hF, hfac]

end Comparison

section SharpBound

/-- **The sharp parity bound in the flat model.** For a uniformly random affine `(d+1)`-flat
(`d + 1 ≤ n`) the probability of an odd intersection is at most `2ⁿ / (2(2ⁿ - 2^d))`.
Unlike in the cube model this constant is larger than `1/2`, and it is attained
(`flatOddProb_bentSet`). -/
theorem flatOddProb_le (A : Finset (Vec n)) (hdn : d + 1 ≤ n) :
    flatOddProb n (d + 1) A ≤ (2 : ℚ) ^ n / (2 * ((2 : ℚ) ^ n - 2 ^ d)) := by
  have hb : (0 : ℚ) < (2 : ℚ) ^ n - 2 ^ d := by
    have : (2 : ℚ) ^ d < 2 ^ n := by
      refine pow_lt_pow_right₀ (by norm_num) (by omega)
    linarith
  have ha : (0 : ℚ) < (indepCard n d : ℚ) := by
    have := indepCard_pos (n := n) (d := d) (by omega)
    exact_mod_cast this
  have hid := oddProb_eq_flatOddProb_mul (n := n) (d := d + 1) A
  rw [indepCard_succ_cast hdn] at hid
  have hbound := oddProb_le_indepRatio (n := n) (d := d) A
  rw [show ((univ.filter fun w : Fin d → Vec n => Indep w).card : ℚ) = (indepCard n d : ℚ) from
    rfl] at hbound
  rw [hid] at hbound
  have hpow : (2 : ℚ) ^ (n * (d + 1)) = 2 ^ (n * d) * 2 ^ n := by
    rw [← pow_add]; ring_nf
  rw [hpow] at hbound
  have hpd : (0 : ℚ) < 2 ^ (n * d) := by positivity
  have hpn : (0 : ℚ) < (2 : ℚ) ^ n := by positivity
  set F : ℚ := flatOddProb n (d + 1) A with hF
  rw [← mul_div_assoc] at hbound
  rw [div_le_div_iff₀ (by positivity) (by positivity)] at hbound
  have h4 : (F * ((2 : ℚ) ^ n - 2 ^ d) * 2) * ((indepCard n d : ℚ) * 2 ^ (n * d))
      ≤ (2 : ℚ) ^ n * ((indepCard n d : ℚ) * 2 ^ (n * d)) := by nlinarith [hbound]
  have h5 : F * ((2 : ℚ) ^ n - 2 ^ d) * 2 ≤ (2 : ℚ) ^ n :=
    le_of_mul_le_mul_right h4 (by positivity)
  rw [le_div_iff₀ (by positivity)]
  linarith

/-- The flat-model bound, in additive form: the excess over `1/2` is at most `2^{d-n}`. -/
theorem flatOddProb_le_half_add (A : Finset (Vec n)) (hdn : d + 1 ≤ n) :
    flatOddProb n (d + 1) A ≤ 1 / 2 + (2 : ℚ) ^ d / 2 ^ n := by
  refine le_trans (flatOddProb_le A hdn) ?_
  have hd2 : (2 : ℚ) ^ d * 2 ≤ 2 ^ n := by
    rw [show (2 : ℚ) ^ d * 2 = 2 ^ (d + 1) from by ring]
    exact pow_le_pow_right₀ (by norm_num) hdn
  have hb : (0 : ℚ) < (2 : ℚ) ^ n - 2 ^ d := by
    have : (0 : ℚ) < (2 : ℚ) ^ d := by positivity
    linarith
  have hpn : (0 : ℚ) < (2 : ℚ) ^ n := by positivity
  have hbig : (2 : ℚ) ^ n ≤ 2 * ((2 : ℚ) ^ n - 2 ^ d) := by linarith
  have h5 : (2 : ℚ) ^ n / (2 * ((2 : ℚ) ^ n - 2 ^ d))
      = 1 / 2 + (2 : ℚ) ^ d / (2 * ((2 : ℚ) ^ n - 2 ^ d)) := by
    field_simp
    ring
  have h6 : (2 : ℚ) ^ d / (2 * ((2 : ℚ) ^ n - 2 ^ d)) ≤ (2 : ℚ) ^ d / 2 ^ n := by
    gcongr
  linarith

end SharpBound

section Attainment

open AffineParityBent

/-- **The flat bound is attained by a bent set.** For `2`-flats in even dimension `n = 2m ≥ 2`
the odd-intersection probability equals `2ⁿ/(2(2ⁿ-2))`, the maximum allowed by
`flatOddProb_le`. -/
theorem flatOddProb_bentSet (m : ℕ) (hm : 1 ≤ m) :
    flatOddProb (m + m) 2 (bentSet m)
      = (2 : ℚ) ^ (m + m) / (2 * ((2 : ℚ) ^ (m + m) - 2)) := by
  have hn2 : 2 ≤ m + m := by omega
  have hx : (4 : ℚ) ≤ (2 : ℚ) ^ (m + m) := by
    calc (4 : ℚ) = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ (m + m) := pow_le_pow_right₀ (by norm_num) hn2
  have hKQ : ((indepCard (m + m) 2 : ℕ) : ℚ)
      = ((2 : ℚ) ^ (m + m) - 1) * ((2 : ℚ) ^ (m + m) - 2) := by
    rw [indepCard_cast hn2, Fin.prod_univ_two]
    norm_num
  have hKne : indepCard (m + m) 2 ≠ 0 := (indepCard_pos hn2).ne'
  rw [flatOddProb_eq_oddProb_div _ hKne, oddProb_bentSet m, hKQ]
  have hpow : (2 : ℚ) ^ ((m + m) * 2) = 2 ^ (m + m) * 2 ^ (m + m) := by
    rw [← pow_add]; ring_nf
  rw [hpow, show (m + m + 1) = (m + m) + 1 from rfl, pow_succ]
  set x : ℚ := (2 : ℚ) ^ (m + m) with hxdef
  have hne1 : x - 1 ≠ 0 := by simp only [hxdef]; intro h; linarith
  have hne2 : x - 2 ≠ 0 := by simp only [hxdef]; intro h; linarith
  have hne0 : x ≠ 0 := by simp only [hxdef]; intro h; linarith
  field_simp

/-- In even dimension the flat-model parity probability for `2`-flats **exceeds `1/2`** —
the cube-model parity bound fails in the flat model. -/
theorem flatOddProb_bentSet_gt_half (m : ℕ) (hm : 1 ≤ m) :
    1 / 2 < flatOddProb (m + m) 2 (bentSet m) := by
  rw [flatOddProb_bentSet m hm]
  have hx : (4 : ℚ) ≤ (2 : ℚ) ^ (m + m) := by
    calc (4 : ℚ) = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ (m + m) := pow_le_pow_right₀ (by norm_num) (by omega)
  rw [lt_div_iff₀ (by linarith)]
  linarith

/-- **The exact flat-model maximum for `2`-flats in even dimension.** -/
theorem maxFlatOddProb_two_eq (m : ℕ) (hm : 1 ≤ m) :
    maxFlatOddProb (m + m) 2 = (2 : ℚ) ^ (m + m) / (2 * ((2 : ℚ) ^ (m + m) - 2)) := by
  refine le_antisymm ?_ ?_
  · refine Finset.sup'_le _ _ fun A _ => ?_
    have := flatOddProb_le (n := m + m) (d := 1) A (by omega)
    simpa using this
  · rw [← flatOddProb_bentSet m hm]
    exact Finset.le_sup' (fun A => flatOddProb (m + m) 2 A) (mem_univ _)

/-- Consequently the parity bound `1/2` of the cube model is **false** in the flat model. -/
theorem maxFlatOddProb_two_gt_half (m : ℕ) (hm : 1 ≤ m) :
    1 / 2 < maxFlatOddProb (m + m) 2 := by
  rw [maxFlatOddProb_two_eq m hm]
  have hx : (4 : ℚ) ≤ (2 : ℚ) ^ (m + m) := by
    calc (4 : ℚ) = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ (m + m) := pow_le_pow_right₀ (by norm_num) (by omega)
  rw [lt_div_iff₀ (by linarith)]
  linarith

open AffineParityTopDim in
/-- **The other extreme: full-dimensional flats.** A full-dimensional flat is all of `𝔽₂ⁿ`,
so every set of odd cardinality has flat-model probability `1` — which is exactly the value
of the bound `2ⁿ/(2(2ⁿ - 2^{n-1}))`. -/
theorem flatOddProb_full_eq_one (A : Finset (Vec n)) (hA : Odd A.card) :
    flatOddProb n n A = 1 := by
  classical
  have hset : flatOddSet n n A = flatParams n n := by
    ext p
    simp only [flatOddSet, flatParams, mem_filter, mem_univ, true_and]
    constructor
    · exact fun h => h.1
    · intro h
      refine ⟨h, ?_⟩
      rw [cnt_eq_card_of_indep A p.1 h, Nat.odd_iff] at *
      omega
  have hK : 0 < indepCard n n := indepCard_pos (le_refl n)
  have hKQ : (0 : ℚ) < (indepCard n n : ℚ) := by exact_mod_cast hK
  rw [flatOddProb, hset, card_flatParams]
  push_cast
  field_simp

/-- The flat-model probability is a probability. -/
lemma flatOddProb_le_one (A : Finset (Vec n)) (hdn : d ≤ n) : flatOddProb n d A ≤ 1 := by
  have hK : 0 < indepCard n d := indepCard_pos hdn
  have hKQ : (0 : ℚ) < (indepCard n d : ℚ) := by exact_mod_cast hK
  have hsub : flatOddSet n d A ⊆ flatParams n d := by
    intro p hp
    exact mem_filter.2 ⟨mem_univ _, (mem_filter.1 hp).2.1⟩
  have hcard : (flatOddSet n d A).card ≤ 2 ^ n * indepCard n d := by
    rw [← card_flatParams]
    exact Finset.card_le_card hsub
  rw [flatOddProb, div_le_one (by positivity)]
  have : ((flatOddSet n d A).card : ℚ) ≤ ((2 ^ n * indepCard n d : ℕ) : ℚ) := by
    exact_mod_cast hcard
  push_cast at this
  linarith

/-- **The full-dimensional flat maximum is `1`.** -/
theorem maxFlatOddProb_full_eq_one (n : ℕ) : maxFlatOddProb n n = 1 := by
  refine le_antisymm (Finset.sup'_le _ _ fun A _ => flatOddProb_le_one A (le_refl n)) ?_
  have hodd : Odd ({0} : Finset (Vec n)).card := by simp
  rw [← flatOddProb_full_eq_one ({0} : Finset (Vec n)) hodd]
  exact Finset.le_sup' (fun A => flatOddProb n n A) (mem_univ _)

end Attainment

section OddDimension

open AffineParityOdd AffineParityOddLower AffineParityBent

/-- The flat-model probability for `2`-flats, in closed form. -/
lemma flatOddProb_two_eq (A : Finset (Vec n)) (hn : 2 ≤ n) :
    flatOddProb n 2 A
      = oddProb n 2 A * ((2 : ℚ) ^ n * 2 ^ n) / (((2 : ℚ) ^ n - 1) * ((2 : ℚ) ^ n - 2)) := by
  have hx : (4 : ℚ) ≤ (2 : ℚ) ^ n := by
    calc (4 : ℚ) = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ n := pow_le_pow_right₀ (by norm_num) hn
  have hKQ : ((indepCard n 2 : ℕ) : ℚ) = ((2 : ℚ) ^ n - 1) * ((2 : ℚ) ^ n - 2) := by
    rw [indepCard_cast hn, Fin.prod_univ_two]
    norm_num
  have hKne : indepCard n 2 ≠ 0 := (indepCard_pos hn).ne'
  rw [flatOddProb_eq_oddProb_div _ hKne, hKQ]
  congr 1
  rw [show n * 2 = n + n from by ring, pow_add]

/-- **Odd ambient dimension: the flat bound is not attained.** For odd `n ≥ 2` every subset
of `𝔽₂ⁿ` has flat-model odd probability strictly below `2ⁿ/(2(2ⁿ-2))`. -/
theorem flatOddProb_two_lt_of_odd (hodd : ¬ Even n) (hn : 2 ≤ n) (A : Finset (Vec n)) :
    flatOddProb n 2 A < (2 : ℚ) ^ n / (2 * ((2 : ℚ) ^ n - 2)) := by
  have hx : (4 : ℚ) ≤ (2 : ℚ) ^ n := by
    calc (4 : ℚ) = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ n := pow_le_pow_right₀ (by norm_num) hn
  have hp : oddProb n 2 A < 1 / 2 - 1 / 2 ^ (n + 1) := oddProb_two_lt_of_odd hodd A
  have hpe : (1 : ℚ) / 2 - 1 / 2 ^ (n + 1) = ((2 : ℚ) ^ n - 1) / (2 * 2 ^ n) := by
    rw [pow_succ]
    have : (0 : ℚ) < 2 ^ n := by positivity
    field_simp
  rw [hpe] at hp
  rw [flatOddProb_two_eq A hn, div_lt_div_iff₀ (by nlinarith) (by nlinarith)]
  have hp' : 2 * (2 : ℚ) ^ n * oddProb n 2 A < (2 : ℚ) ^ n - 1 := by
    rw [lt_div_iff₀ (by positivity)] at hp
    linarith
  have hxx : (0 : ℚ) < (2 : ℚ) ^ n * ((2 : ℚ) ^ n - 2) := by nlinarith
  nlinarith [mul_lt_mul_of_pos_right hp' hxx, hx]

/-- **Odd ambient dimension: the flat-model lower bound.** The pullback construction gives
`maxFlatOddProb n 2 ≥ 2ⁿ/(2(2ⁿ-1))` for odd `n ≥ 3`. -/
theorem maxFlatOddProb_two_odd_ge (hodd : ¬ Even n) (hn : 3 ≤ n) :
    (2 : ℚ) ^ n / (2 * ((2 : ℚ) ^ n - 1)) ≤ maxFlatOddProb n 2 := by
  have hn2 : 2 ≤ n := by omega
  have hx : (8 : ℚ) ≤ (2 : ℚ) ^ n := by
    calc (8 : ℚ) = 2 ^ 3 := by norm_num
      _ ≤ 2 ^ n := pow_le_pow_right₀ (by norm_num) hn
  obtain ⟨A, -, hA⟩ := Finset.exists_mem_eq_sup' (⟨∅, mem_univ _⟩ :
    (univ : Finset (Finset (Vec n))).Nonempty) (fun A => oddProb n 2 A)
  have hge : 1 / 2 - 1 / (2 : ℚ) ^ n ≤ oddProb n 2 A := by
    have := maxOddProb_two_ge_of_odd hodd
    rwa [maxOddProb, hA] at this
  have hpe : (1 : ℚ) / 2 - 1 / 2 ^ n = ((2 : ℚ) ^ n - 2) / (2 * 2 ^ n) := by
    have : (0 : ℚ) < 2 ^ n := by positivity
    field_simp
  rw [hpe, div_le_iff₀ (by positivity)] at hge
  have hkey : (2 : ℚ) ^ n / (2 * ((2 : ℚ) ^ n - 1)) ≤ flatOddProb n 2 A := by
    rw [flatOddProb_two_eq A hn2, div_le_div_iff₀ (by nlinarith) (by nlinarith)]
    have hxx : (0 : ℚ) < (2 : ℚ) ^ n * ((2 : ℚ) ^ n - 1) := by nlinarith
    nlinarith [mul_le_mul_of_nonneg_right hge (le_of_lt hxx), hx]
  exact le_trans hkey (Finset.le_sup' (fun A => flatOddProb n 2 A) (mem_univ A))

/-- **The odd-dimensional flat-model maximum, localised.** For odd `n ≥ 3`,
`2ⁿ/(2(2ⁿ-1)) ≤ maxFlatOddProb n 2 < 2ⁿ/(2(2ⁿ-2))`; both ends exceed `1/2`. -/
theorem maxFlatOddProb_two_odd_bounds (hodd : ¬ Even n) (hn : 3 ≤ n) :
    (2 : ℚ) ^ n / (2 * ((2 : ℚ) ^ n - 1)) ≤ maxFlatOddProb n 2 ∧
      maxFlatOddProb n 2 < (2 : ℚ) ^ n / (2 * ((2 : ℚ) ^ n - 2)) := by
  refine ⟨maxFlatOddProb_two_odd_ge hodd hn, ?_⟩
  obtain ⟨A, -, hA⟩ := Finset.exists_mem_eq_sup' (⟨∅, mem_univ _⟩ :
    (univ : Finset (Finset (Vec n))).Nonempty) (fun A => flatOddProb n 2 A)
  rw [maxFlatOddProb, hA]
  exact flatOddProb_two_lt_of_odd hodd (by omega) A

/-- The numerical instance `n = 3`: `4/7 ≤ maxFlatOddProb 3 2 < 2/3`.  Both bounds are
strictly above `1/2`, in contrast with the cube-model value `maxOddProb 3 2 = 3/8`. -/
theorem maxFlatOddProb_three_bounds :
    4 / 7 ≤ maxFlatOddProb 3 2 ∧ maxFlatOddProb 3 2 < 2 / 3 := by
  have h := maxFlatOddProb_two_odd_bounds (n := 3) (by decide) (le_refl 3)
  norm_num at h
  exact h

end OddDimension

section Asymptotics

/-- The flat model always sees at least as much as the cube model. -/
theorem maxOddProb_le_maxFlatOddProb (n d : ℕ) :
    maxOddProb n (d + 1) ≤ maxFlatOddProb n (d + 1) := by
  refine Finset.sup'_le _ _ fun A _ => ?_
  exact le_trans (model_comparison A).2
    (Finset.le_sup' (fun A => flatOddProb n (d + 1) A) (mem_univ A))

/-- The flat-model maximum obeys the same bound as each individual set. -/
theorem maxFlatOddProb_le_half_add {n d : ℕ} (hdn : d + 1 ≤ n) :
    maxFlatOddProb n (d + 1) ≤ 1 / 2 + (2 : ℚ) ^ d / 2 ^ n :=
  Finset.sup'_le _ _ fun A _ => flatOddProb_le_half_add A hdn

/-- **Both models have the same limit.** For every fixed flat dimension `d + 1`, the maximal
odd-intersection probability in the flat model tends to `1/2` as `n → ∞`, exactly as in the
cube model (`AffineStats.tendsto_maxOddProb`) — even though for finite `n` the flat value can
exceed `1/2` while the cube value never does. -/
theorem tendsto_maxFlatOddProb (d : ℕ) :
    Filter.Tendsto (fun n => ((maxFlatOddProb n (d + 1) : ℚ) : ℝ)) Filter.atTop
      (nhds (1 / 2 : ℝ)) := by
  have hgeom : Filter.Tendsto (fun n : ℕ => ((1 : ℝ) / 2) ^ n) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
  have hup : Filter.Tendsto (fun n : ℕ => (1 : ℝ) / 2 + (2 : ℝ) ^ d / 2 ^ n)
      Filter.atTop (nhds (1 / 2 : ℝ)) := by
    have h0 : Filter.Tendsto (fun n : ℕ => (2 : ℝ) ^ d / 2 ^ n) Filter.atTop (nhds 0) := by
      have hrw : (fun n : ℕ => (2 : ℝ) ^ d / 2 ^ n)
          = fun n : ℕ => ((2 : ℝ) ^ d) * ((1 / 2) ^ n) := by
        funext n
        rw [div_pow, one_pow]
        field_simp
      rw [hrw]
      simpa using hgeom.const_mul ((2 : ℝ) ^ d)
    simpa using (tendsto_const_nhds (x := (1 : ℝ) / 2) (f := Filter.atTop (α := ℕ))).add h0
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' (AffineStats.tendsto_maxOddProb d) hup
    (Filter.Eventually.of_forall fun n => ?_) ?_
  · exact_mod_cast (Rat.cast_le (K := ℝ)).2 (maxOddProb_le_maxFlatOddProb n d)
  · filter_upwards [Filter.eventually_ge_atTop (d + 1)] with n hn
    have h1 := (Rat.cast_le (K := ℝ)).2 (maxFlatOddProb_le_half_add (n := n) (d := d) hn)
    push_cast at h1
    linarith

end Asymptotics

end AffineFlatModel