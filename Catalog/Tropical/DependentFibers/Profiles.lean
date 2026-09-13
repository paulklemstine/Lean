import Tropical.DependentFibers.Corners

/-!
# Newton-polygon profiles: fibres of a convex tropical polynomial are computable windows

The previous files bound multiplicities (`multiplicity_sum_le`) and show corners always
exist (`exists_corner`).  This file computes the fibres *exactly* for polynomials given
by their slope increments, which is the Newton-polygon description of a tropical
polynomial.

Given an increment function `d : ℕ → ℚ` put

`sumCoeff d i = d 0 + d 1 + ⋯ + d (i−1)`,

so that the monomial values of the tropical polynomial with coefficients `sumCoeff d`
satisfy the telescoping identity `v_j(x) − v_i(x) = ∑_{i ≤ l < j} (d l + x)`
(`sumCoeff_value_diff`).  The main theorem

`fiber_sumCoeff_eq_Icc`

says: if at the point `x = −v` the increments are `< v` below an index `A`, exactly
`= v` on `[A, B)`, and `> v` from `B` on, then the fibre is the whole window
`Icc A B`, hence the local multiplicity is `B − A + 1`: **the multiplicity of a corner
is one more than the number of Newton-polygon increments of that slope.**

This makes the *converse* of the degree bound constructive.  `two_block_profile`
realises any prescribed splitting `n = m + (n − m)` as the multiplicity profile of an
explicit degree-`n` polynomial with exactly two corners of multiplicities `m + 1` and
`n − m + 1`, whose excesses sum to `n` — so the inequality `multiplicity_sum_le` is an
equality on the nose for every composition of `n` into two parts.
-/

namespace TropicalDependentFibers

open Finset

/-- The coefficient vector with prescribed slope increments: `sumCoeff d i = ∑_{l<i} d l`.
Convex `d` (nondecreasing) means the Newton polygon of the resulting polynomial is the
graph of `d`. -/
def sumCoeff (d : ℕ → ℚ) : ℕ → ℚ := fun i => ∑ l ∈ range i, d l

/-- **Telescoping identity.**  Differences of monomial values are partial sums of the
shifted increments. -/
theorem sumCoeff_value_diff (d : ℕ → ℚ) (x : ℚ) {i j : ℕ} (hij : i ≤ j) :
    (sumCoeff d j + (j : ℚ) * x) - (sumCoeff d i + (i : ℚ) * x)
      = ∑ l ∈ Ico i j, (d l + x) := by
  have hsum : ∑ l ∈ Ico i j, (d l + x) = (∑ l ∈ Ico i j, d l) + ((j - i : ℕ) : ℚ) * x := by
    rw [Finset.sum_add_distrib, Finset.sum_const, Nat.card_Ico, nsmul_eq_mul]
  have hd : ∑ l ∈ Ico i j, d l = sumCoeff d j - sumCoeff d i := by
    simp only [sumCoeff]
    rw [Finset.sum_Ico_eq_sub _ hij]
  have hcast : ((j - i : ℕ) : ℚ) = (j : ℚ) - (i : ℚ) := by
    have : (i : ℚ) ≤ (j : ℚ) := by exact_mod_cast hij
    push_cast [Nat.cast_sub hij]
    ring
  rw [hsum, hd, hcast]
  ring

/-- **Exact fibre of a convex tropical polynomial (Newton-polygon form).**  If the
increments are `< v` before `A`, equal to `v` on `[A, B)` and `> v` after `B`, then the
fibre at `x = −v` is exactly the index window `Icc A B`. -/
theorem fiber_sumCoeff_eq_Icc {n A B : ℕ} {d : ℕ → ℚ} {v : ℚ} (hAB : A ≤ B) (hBn : B ≤ n)
    (hlow : ∀ l < A, d l < v) (hmid : ∀ l, A ≤ l → l < B → d l = v)
    (hhigh : ∀ l, B ≤ l → l < n → v < d l) :
    fiber n (sumCoeff d) (-v) = Finset.Icc A B := by
  have hAn : A ≤ n := le_trans hAB hBn
  set c := sumCoeff d with hc
  set V : ℕ → ℚ := fun i => c i + (i : ℚ) * (-v) with hV
  -- above `A` the value never decreases
  have hup : ∀ i, A ≤ i → i ≤ n → 0 ≤ V i - V A := by
    intro i hAi hin
    rw [hV]
    simp only
    rw [sumCoeff_value_diff d (-v) hAi]
    refine Finset.sum_nonneg fun l hl => ?_
    rw [Finset.mem_Ico] at hl
    rcases lt_or_ge l B with hlB | hlB
    · have := hmid l hl.1 hlB
      simp [this]
    · have := hhigh l hlB (lt_of_lt_of_le hl.2 hin)
      linarith
  -- below `A` the value is strictly larger
  have hdown : ∀ i, i < A → V A < V i := by
    intro i hiA
    have hne : (Finset.Ico i A).Nonempty := by
      rw [Finset.nonempty_Ico]; exact hiA
    have hsum : ∑ l ∈ Finset.Ico i A, (d l + -v) < 0 := by
      have : ∑ l ∈ Finset.Ico i A, (d l + -v) < ∑ _l ∈ Finset.Ico i A, (0 : ℚ) := by
        refine Finset.sum_lt_sum_of_nonempty hne fun l hl => ?_
        rw [Finset.mem_Ico] at hl
        have := hlow l hl.2
        linarith
      simpa using this
    have hdiff := sumCoeff_value_diff d (-v) (le_of_lt hiA)
    rw [hV]
    simp only
    simp only [hV] at *
    linarith
  -- on the window the value is constant
  have hconst : ∀ i, A ≤ i → i ≤ B → V i = V A := by
    intro i hAi hiB
    have hz : V i - V A = 0 := by
      rw [hV]
      simp only
      rw [sumCoeff_value_diff d (-v) hAi]
      refine Finset.sum_eq_zero fun l hl => ?_
      rw [Finset.mem_Ico] at hl
      have := hmid l hl.1 (lt_of_lt_of_le hl.2 hiB)
      simp [this]
    linarith
  -- beyond the window the value is strictly larger
  have hbeyond : ∀ i, B < i → i ≤ n → V A < V i := by
    intro i hBi hin
    have hAi : A ≤ i := le_trans hAB (le_of_lt hBi)
    have hpos : 0 < ∑ l ∈ Finset.Ico A i, (d l + -v) := by
      have hmem : B ∈ Finset.Ico A i := Finset.mem_Ico.mpr ⟨hAB, hBi⟩
      have hterms : ∀ l ∈ Finset.Ico A i, (0 : ℚ) ≤ d l + -v := by
        intro l hl
        rw [Finset.mem_Ico] at hl
        rcases lt_or_ge l B with hlB | hlB
        · have := hmid l hl.1 hlB
          simp [this]
        · have := hhigh l hlB (lt_of_lt_of_le hl.2 hin)
          linarith
      have hstrict : (0 : ℚ) < d B + -v := by
        have := hhigh B (le_refl B) (lt_of_lt_of_le hBi hin)
        linarith
      calc (0 : ℚ) = ∑ _l ∈ Finset.Ico A i, (0 : ℚ) := by simp
        _ < ∑ l ∈ Finset.Ico A i, (d l + -v) :=
            Finset.sum_lt_sum hterms ⟨B, hmem, by simpa using hstrict⟩
    have := sumCoeff_value_diff d (-v) hAi
    rw [hV]
    simp only
    simp only [hV] at *
    linarith [this, hpos]
  -- assemble
  ext i
  rw [mem_fiber_iff, Finset.mem_Icc]
  constructor
  · rintro ⟨hin, hmin⟩
    constructor
    · by_contra hlt
      push_neg at hlt
      have h1 := hmin A hAn
      have h2 := hdown i hlt
      simp only [hV] at h2
      linarith
    · by_contra hgt
      push_neg at hgt
      have h1 := hmin A hAn
      have h2 := hbeyond i hgt hin
      simp only [hV] at h2
      linarith
  · rintro ⟨hAi, hiB⟩
    refine ⟨le_trans hiB hBn, fun j hj => ?_⟩
    have hiA : V i = V A := hconst i hAi hiB
    rcases lt_or_ge j A with hjA | hjA
    · have := hdown j hjA
      simp only [hV] at hiA this ⊢
      linarith
    · have := hup j hjA hj
      simp only [hV] at hiA this ⊢
      linarith

/-- Multiplicity of a corner = one more than the number of Newton increments of that
slope. -/
theorem fiber_sumCoeff_card {n A B : ℕ} {d : ℕ → ℚ} {v : ℚ} (hAB : A ≤ B) (hBn : B ≤ n)
    (hlow : ∀ l < A, d l < v) (hmid : ∀ l, A ≤ l → l < B → d l = v)
    (hhigh : ∀ l, B ≤ l → l < n → v < d l) :
    (fiber n (sumCoeff d) (-v)).card = B - A + 1 := by
  rw [fiber_sumCoeff_eq_Icc hAB hBn hlow hmid hhigh, Nat.card_Icc]
  omega

/-! ## Realising a prescribed two-part multiplicity profile -/

/-- Increments of a two-block Newton polygon: slope `1` on the first `m` steps, slope
`2` afterwards. -/
def twoBlockIncr (m : ℕ) : ℕ → ℚ := fun l => if l < m then 1 else 2

theorem twoBlockIncr_of_lt {m l : ℕ} (h : l < m) : twoBlockIncr m l = 1 := if_pos h

theorem twoBlockIncr_of_ge {m l : ℕ} (h : m ≤ l) : twoBlockIncr m l = 2 :=
  if_neg (Nat.not_lt.mpr h)

/-- **Prescribed profile.**  For every splitting `n = m + (n − m)` there is a degree-`n`
tropical polynomial with exactly two corners, of multiplicities `m + 1` and
`n − m + 1`; their multiplicity excesses `m` and `n − m` sum to `n`, so the degree bound
`multiplicity_sum_le` is attained by this profile. -/
theorem two_block_profile {n m : ℕ} (hm : m ≤ n) :
    (fiber n (sumCoeff (twoBlockIncr m)) (-1)).card = m + 1 ∧
      (fiber n (sumCoeff (twoBlockIncr m)) (-2)).card = n - m + 1 := by
  constructor
  · have h := fiber_sumCoeff_card (n := n) (A := 0) (B := m) (d := twoBlockIncr m) (v := 1)
      (Nat.zero_le m) hm (fun l hl => absurd hl (Nat.not_lt_zero l))
      (fun l _ hlm => twoBlockIncr_of_lt hlm)
      (fun l hml _ => by rw [twoBlockIncr_of_ge hml]; norm_num)
    simpa using h
  · have h := fiber_sumCoeff_card (n := n) (A := m) (B := n) (d := twoBlockIncr m) (v := 2)
      hm (le_refl n) (fun l hl => by rw [twoBlockIncr_of_lt hl]; norm_num)
      (fun l hml _ => twoBlockIncr_of_ge hml)
      (fun l _ hln => absurd hln (Nat.not_lt.mpr (by omega)))
    simpa using h

/-- The two corners of `two_block_profile` have unequal cardinality whenever the split
is unbalanced; in particular for `m = 1` and `n ≥ 3` the fibre cardinalities are `2`
and `n`. -/
theorem two_block_unequal {n : ℕ} (hn : 3 ≤ n) :
    (fiber n (sumCoeff (twoBlockIncr 1)) (-1)).card = 2 ∧
      (fiber n (sumCoeff (twoBlockIncr 1)) (-2)).card = n ∧
        (fiber n (sumCoeff (twoBlockIncr 1)) (-1)).card
          ≠ (fiber n (sumCoeff (twoBlockIncr 1)) (-2)).card := by
  obtain ⟨h1, h2⟩ := two_block_profile (n := n) (m := 1) (by omega)
  refine ⟨h1, by omega, ?_⟩
  omega

/-- The multiplicity excesses of the two-corner profile sum to the degree: equality in
`multiplicity_sum_le` for every two-part composition of `n`. -/
theorem two_block_multiplicity_sum {n m : ℕ} (hm : m ≤ n) :
    ((fiber n (sumCoeff (twoBlockIncr m)) (-1)).card - 1)
      + ((fiber n (sumCoeff (twoBlockIncr m)) (-2)).card - 1) = n := by
  obtain ⟨h1, h2⟩ := two_block_profile hm
  omega

end TropicalDependentFibers