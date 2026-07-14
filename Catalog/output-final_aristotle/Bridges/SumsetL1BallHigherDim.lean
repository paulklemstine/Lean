/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Bridges.SumsetL1BallSharpDim1

/-!
# A sumset lower bound for boxes / L₁-balls in higher dimensions

This file extends the one–dimensional sharp exponent bound of
`Catalog/Bridges/SumsetL1BallSharpDim1.lean` to **arbitrary dimension**.

The additive engine of the one–dimensional proof — the iterated Cauchy–Davenport
inequality `iterated_cauchy_davenport` — was already established for *any*
torsion-free abelian group `G`, not merely `ℤ`.  Combined with the pure real
inequality `prod_le_rpow`, this yields a clean group-theoretic bound:

> For finite nonempty `A₀, …, A_{n-1} ⊆ G` in a torsion-free abelian group with
> `|Aⱼ| ≤ M` for all `j`,
> `∏ⱼ |Aⱼ| ≤ |A₀ + ⋯ + A_{n-1}|^{q}`,  `q = qExp n M = n·log M / log(1 + n(M−1))`.

This is `prod_card_le_sumset_rpow`, with root form `sumset_lower_bound_root`.

Specialising `G = (Fin d → ℤ)` and taking the box
`{0,…,m}^d = Fintype.piFinset (fun _ ↦ {0,…,m})` (whose cardinality is
`(m+1)^d`) gives the higher-dimensional statement `sumset_box_higherDim`:

> For finite nonempty `Aⱼ ⊆ {0,…,m}^d ⊆ ℤ^d`,
> `∏ⱼ |Aⱼ| ≤ |∑ⱼ Aⱼ|^{qExp n ((m+1)^d)}`.

For `d = 1` this recovers exactly the one-dimensional exponent
`pExp n m = n·log(m+1)/log(nm+1)`, since `qExp n (m+1) = pExp n m`
(`qExp_dim_one_eq_pExp`).

As in dimension one, the exponent never exceeds the naive geometric-mean exponent
`n` (`qExp_le_n`), so the bound is always at least as strong as the AM–GM bound
`∏|Aⱼ| ≤ |∑Aⱼ|^{n}`.

**Sharpness caveat.** In dimension `d ≥ 2` the exponent produced here,
`qExp n ((m+1)^d)`, is a *valid* lower bound but is **not** claimed to be sharp:
the Cauchy–Davenport step `|∑Aⱼ| ≥ 1 + ∑(|Aⱼ|−1)` is far from tight for boxes in
`ℤ^d` with `d ≥ 2`.  Determining the genuinely sharp higher-dimensional exponent
remains open (see `FUTURE_DIRECTIONS.md`).

All statements are `sorry`-free.
-/

open Finset Pointwise

namespace SumsetL1BallHigherDim

open SumsetSharpDim1

noncomputable section

/-! ## Part 1 : the general exponent `qExp` -/

/-- The general exponent `q = n·log M / log(1 + n(M−1))` attached to a cardinality
bound `M` on `n` summands.  For `M = m+1` this is the dimension-one sharp exponent
`pExp n m` (see `qExp_dim_one_eq_pExp`). -/
def qExp (n : ℕ) (M : ℝ) : ℝ := n * Real.log M / Real.log (1 + n * (M - 1))

/-- The general exponent is strictly positive (for `n ≥ 1`, `M > 1`). -/
theorem qExp_pos (n : ℕ) (M : ℝ) (hn : 1 ≤ n) (hM : 1 < M) : 0 < qExp n M := by
  have hn0 : (0:ℝ) < n := by exact_mod_cast hn
  have hLgt : (1:ℝ) < 1 + n * (M - 1) := by
    nlinarith [mul_pos hn0 (show (0:ℝ) < M - 1 by linarith)]
  rw [qExp]
  exact div_pos (mul_pos hn0 (Real.log_pos hM)) (Real.log_pos hLgt)

/-- The general exponent never exceeds the naive geometric-mean exponent `n`, so
the bound below is always at least as strong as the AM–GM bound. -/
theorem qExp_le_n (n : ℕ) (M : ℝ) (hn : 1 ≤ n) (hM : 1 < M) : qExp n M ≤ (n : ℝ) := by
  have hn0 : (0:ℝ) < n := by exact_mod_cast hn
  have hn1 : (1:ℝ) ≤ n := by exact_mod_cast hn
  have hLgt : (1:ℝ) < 1 + n * (M - 1) := by
    nlinarith [mul_pos hn0 (show (0:ℝ) < M - 1 by linarith)]
  have hlogL : 0 < Real.log (1 + n * (M - 1)) := Real.log_pos hLgt
  rw [qExp, div_le_iff₀ hlogL]
  have hMle : M ≤ 1 + n * (M - 1) := by nlinarith
  have hlog : Real.log M ≤ Real.log (1 + n * (M - 1)) := Real.log_le_log (by linarith) hMle
  nlinarith [Real.log_pos hM]

/-- Compatibility with dimension one: `qExp n (m+1) = pExp n m`. -/
theorem qExp_dim_one_eq_pExp (n m : ℕ) : qExp n ((m : ℝ) + 1) = pExp n m := by
  rw [qExp, pExp]
  congr 2
  ring

/-! ## Part 2 : the general group-theoretic bound -/

/-- **General sumset lower bound in a torsion-free abelian group.**

If `A₀, …, A_{n-1}` are finite nonempty subsets of a torsion-free abelian group
`G` with `|Aⱼ| ≤ M` for every `j`, then
`∏ⱼ |Aⱼ| ≤ |A₀ + ⋯ + A_{n-1}|^{qExp n M}`.

The proof combines the iterated Cauchy–Davenport inequality (valid in any
torsion-free abelian group) with the pure real inequality `prod_le_rpow`. -/
theorem prod_card_le_sumset_rpow {G : Type*} [DecidableEq G] [AddCommGroup G]
    [IsAddTorsionFree G] (n : ℕ) (hn : 1 ≤ n) (M : ℝ) (hM : 1 < M)
    (A : ℕ → Finset G) (hne : ∀ i ∈ range n, (A i).Nonempty)
    (hcard : ∀ i ∈ range n, ((A i).card : ℝ) ≤ M) :
    (∏ i ∈ range n, ((A i).card : ℝ))
      ≤ ((∑ i ∈ range n, A i).card : ℝ) ^ (qExp n M) := by
  have hn0 : (0:ℝ) < n := by exact_mod_cast hn
  have ha1 : ∀ i ∈ range n, (1:ℝ) ≤ ((A i).card : ℝ) := by
    intro i hi; have := Finset.card_pos.mpr (hne i hi); exact_mod_cast this
  have hprod := prod_le_rpow n hn M hM (fun i => ((A i).card : ℝ)) ha1 hcard
  simp only at hprod
  have hqpos : 0 < qExp n M := qExp_pos n M hn hM
  have hcd := iterated_cauchy_davenport (Finset.nonempty_range_iff.mpr (by omega)) A hne
  rw [Finset.card_range] at hcd
  set C := (∑ i ∈ range n, A i).card with hCdef
  have hbase_nonneg : (0:ℝ) ≤ 1 + ∑ i ∈ range n, (((A i).card : ℝ) - 1) := by
    have : (0:ℝ) ≤ ∑ i ∈ range n, (((A i).card : ℝ) - 1) :=
      Finset.sum_nonneg (fun i hi => by have := ha1 i hi; linarith)
    linarith
  have hTle : (1 : ℝ) + ∑ i ∈ range n, (((A i).card : ℝ) - 1) ≤ (C : ℝ) := by
    have hsum1 : ∑ i ∈ range n, (((A i).card : ℝ) - 1)
        = (∑ i ∈ range n, ((A i).card : ℝ)) - n := by
      rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_one]
    rw [hsum1]
    have hcastsum : (∑ i ∈ range n, ((A i).card : ℝ))
        = ((∑ i ∈ range n, (A i).card : ℕ) : ℝ) := by rw [Nat.cast_sum]
    rw [hcastsum]
    have hcd' : ((∑ i ∈ range n, (A i).card : ℕ) : ℝ) + 1 ≤ (C : ℝ) + n := by exact_mod_cast hcd
    linarith
  have hpow_le : (1 + ∑ i ∈ range n, (((A i).card : ℝ) - 1)) ^ (qExp n M)
      ≤ (C : ℝ) ^ (qExp n M) := Real.rpow_le_rpow hbase_nonneg hTle (le_of_lt hqpos)
  have hexp : (n:ℝ) * Real.log M / Real.log (1 + (n:ℝ) * (M - 1)) = qExp n M := rfl
  rw [hexp] at hprod
  exact le_trans hprod hpow_le

/-- **Root form** of the general bound:
`(∏ⱼ |Aⱼ|)^{1/qExp n M} ≤ |A₀ + ⋯ + A_{n-1}|`. -/
theorem sumset_lower_bound_root {G : Type*} [DecidableEq G] [AddCommGroup G]
    [IsAddTorsionFree G] (n : ℕ) (hn : 1 ≤ n) (M : ℝ) (hM : 1 < M)
    (A : ℕ → Finset G) (hne : ∀ i ∈ range n, (A i).Nonempty)
    (hcard : ∀ i ∈ range n, ((A i).card : ℝ) ≤ M) :
    ((∏ i ∈ range n, (A i).card : ℕ) : ℝ) ^ ((qExp n M)⁻¹)
      ≤ ((∑ i ∈ range n, A i).card : ℝ) := by
  have hqpos : 0 < qExp n M := qExp_pos n M hn hM
  have hbound := prod_card_le_sumset_rpow n hn M hM A hne hcard
  have hprodcast : (∏ i ∈ range n, ((A i).card : ℝ))
      = ((∏ i ∈ range n, (A i).card : ℕ) : ℝ) := by rw [Nat.cast_prod]
  rw [hprodcast] at hbound
  set C := (∑ i ∈ range n, A i).card with hCdef
  have hCnn : (0:ℝ) ≤ (C : ℝ) := Nat.cast_nonneg _
  have hstep := Real.rpow_le_rpow (Nat.cast_nonneg _) hbound (le_of_lt (inv_pos.mpr hqpos))
  rw [← Real.rpow_mul hCnn, mul_inv_cancel₀ (ne_of_gt hqpos), Real.rpow_one] at hstep
  exact hstep

/-! ## Part 3 : the higher-dimensional box -/

/-- The discrete box `{0,…,m}^d ⊆ (Fin d → ℤ)`. -/
def box (d m : ℕ) : Finset (Fin d → ℤ) :=
  Fintype.piFinset (fun _ : Fin d => Finset.Icc (0 : ℤ) (m : ℤ))

/-- The box has `(m+1)^d` lattice points. -/
theorem card_box (d m : ℕ) : (box d m).card = (m + 1) ^ d := by
  rw [box, Fintype.card_piFinset]
  simp [Int.card_Icc]

/-- **Higher-dimensional sumset lower bound for the box.**

For finite nonempty subsets `A₀, …, A_{n-1}` of the box `{0,…,m}^d ⊆ ℤ^d`,
`∏ⱼ |Aⱼ| ≤ |A₀ + ⋯ + A_{n-1}|^{qExp n ((m+1)^d)}`.

For `d = 1` this specialises to the one-dimensional bound `sumset_sharp_dim_one`
(the exponent agrees by `qExp_dim_one_eq_pExp`). -/
theorem sumset_box_higherDim (d n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) (hd : 1 ≤ d)
    (A : ℕ → Finset (Fin d → ℤ)) (hne : ∀ i ∈ range n, (A i).Nonempty)
    (hsub : ∀ i ∈ range n, A i ⊆ box d m) :
    (∏ i ∈ range n, ((A i).card : ℝ))
      ≤ ((∑ i ∈ range n, A i).card : ℝ) ^ (qExp n (((m : ℝ) + 1) ^ d)) := by
  have hmr : (1:ℝ) ≤ m := by exact_mod_cast hm
  have hM1 : (1:ℝ) < (m : ℝ) + 1 := by linarith
  have hM : (1:ℝ) < ((m : ℝ) + 1) ^ d := one_lt_pow₀ hM1 (by omega)
  refine prod_card_le_sumset_rpow n hn (((m : ℝ) + 1) ^ d) hM A hne ?_
  intro i hi
  have hle : (A i).card ≤ (box d m).card := Finset.card_le_card (hsub i hi)
  rw [card_box] at hle
  calc ((A i).card : ℝ) ≤ (((m + 1) ^ d : ℕ) : ℝ) := by exact_mod_cast hle
    _ = ((m : ℝ) + 1) ^ d := by push_cast; ring

/-- **Root form** of the higher-dimensional box bound. -/
theorem sumset_box_higherDim_root (d n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) (hd : 1 ≤ d)
    (A : ℕ → Finset (Fin d → ℤ)) (hne : ∀ i ∈ range n, (A i).Nonempty)
    (hsub : ∀ i ∈ range n, A i ⊆ box d m) :
    ((∏ i ∈ range n, (A i).card : ℕ) : ℝ) ^ ((qExp n (((m : ℝ) + 1) ^ d))⁻¹)
      ≤ ((∑ i ∈ range n, A i).card : ℝ) := by
  have hmr : (1:ℝ) ≤ m := by exact_mod_cast hm
  have hM1 : (1:ℝ) < (m : ℝ) + 1 := by linarith
  have hM : (1:ℝ) < ((m : ℝ) + 1) ^ d := one_lt_pow₀ hM1 (by omega)
  refine sumset_lower_bound_root n hn (((m : ℝ) + 1) ^ d) hM A hne ?_
  intro i hi
  have hle : (A i).card ≤ (box d m).card := Finset.card_le_card (hsub i hi)
  rw [card_box] at hle
  calc ((A i).card : ℝ) ≤ (((m + 1) ^ d : ℕ) : ℝ) := by exact_mod_cast hle
    _ = ((m : ℝ) + 1) ^ d := by push_cast; ring

/-- The higher-dimensional exponent is at most `n`, so the box bound is at least
as strong as the geometric-mean bound in every dimension. -/
theorem qExp_box_le_n (d n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) (hd : 1 ≤ d) :
    qExp n (((m : ℝ) + 1) ^ d) ≤ (n : ℝ) := by
  have hmr : (1:ℝ) ≤ m := by exact_mod_cast hm
  have hM1 : (1:ℝ) < (m : ℝ) + 1 := by linarith
  have hM : (1:ℝ) < ((m : ℝ) + 1) ^ d := one_lt_pow₀ hM1 (by omega)
  exact qExp_le_n n (((m : ℝ) + 1) ^ d) hn hM

end

end SumsetL1BallHigherDim