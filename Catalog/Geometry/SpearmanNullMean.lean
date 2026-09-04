import Mathlib
import Geometry.SpearmanPermutohedronGap

/-!
# The dial is exactly unbiased: the centroid of the permutohedron and a zero null mean

## Research context (FACT round-44 #2, exp 499, `T-DIAL-AXES`)

The anchor column of the round-44 grid replicates paper 165 on five fresh seeds and reads
`0.7167`, inside the pre-registered band `[0.71, 0.76]`.  Reading that as *evidence* presumes
the dial has no built-in drift: that a Spearman statistic computed against an unrelated ranking
averages to `0`, exactly, and not merely asymptotically.  For a finite population of size `n`
this is a statement about the **centroid of the permutohedron**, and it is exact.

This file proves it.  The argument is group-theoretic rather than probabilistic: right
translation by a transposition is a bijection of the symmetric group, so the total rank
`∑_σ σ(i)` carried by a fixed position `i` does not depend on `i`.  Summing over positions
pins the common value, and the exact `∑ d²` moment follows.

## Main results

* `sum_rk_indep_of_index` — the "position-blindness" of the uniform ensemble: `∑_σ σ(i)` is
  independent of `i`.  (This is the statement that the centroid of the permutohedron is the
  barycentric point `((n−1)/2, …, (n−1)/2)`.)
* `card_mul_sum_ip` — `n · ∑_σ ⟨σ, id⟩ = |Sₙ| · (∑ i)²`: the average inner product with a fixed
  ranking is exactly the product of the coordinate means.
* `six_mul_sum_D` — the exact first moment of the raw statistic:
  `6 · ∑_σ ∑d²(σ, id) = |Sₙ| · (n³ − n)`, i.e. `E[∑d²] = (n³ − n)/6`.
* `sprho_null_mean` — **the dial is exactly unbiased**: `∑_σ sprho σ 1 = 0` for `n ≥ 2`.
* `exists_sprho_nonpos` / `exists_sprho_nonneg` — the immediate consequence used when reading a
  grid column: an in-band positive reading is never forced; both signs occur in the ensemble.

## Lab notes

`labnote_null_mean_fin3` records the exhaustive `n = 3` check of the moment identity:
the six vertices of the hexagon have `∑_σ ∑d² = 24 = 6·(27−3)/6`, so the mean `∑d²` is `4`
and the mean Spearman value is `0`.
-/

namespace Catalog.Geometry.SpearmanNull

open Finset Catalog.Geometry.SpearmanPermutohedron

variable {n : ℕ}

/-- Abbreviation for `|Sₙ|` as an integer. -/
def permCard (n : ℕ) : ℤ := (Fintype.card (Equiv.Perm (Fin n)) : ℤ)

/-- **Position blindness.**  Right translation by the transposition `(i j)` is a bijection of
`Sₙ`, so the total rank carried by position `i` equals that carried by position `j`. -/
theorem sum_rk_indep_of_index (i j : Fin n) :
    ∑ σ : Equiv.Perm (Fin n), rk σ i = ∑ σ : Equiv.Perm (Fin n), rk σ j := by
  rw [← Equiv.sum_comp (Equiv.mulRight (Equiv.swap i j)) (fun σ => rk σ i)]
  refine Finset.sum_congr rfl fun σ _ => ?_
  show rk (σ * Equiv.swap i j) i = rk σ j
  rw [rk_mul, Equiv.swap_apply_left]

/-- The common value of `∑_σ σ(i)`, pinned by summing over the `n` positions. -/
theorem card_mul_sum_rk (i : Fin n) :
    (n : ℤ) * (∑ σ : Equiv.Perm (Fin n), rk σ i) = permCard n * linSum n := by
  have hdouble : ∑ j : Fin n, ∑ σ : Equiv.Perm (Fin n), rk σ j
      = ∑ σ : Equiv.Perm (Fin n), ∑ j : Fin n, rk σ j := Finset.sum_comm
  have hinner : ∑ σ : Equiv.Perm (Fin n), ∑ j : Fin n, rk σ j
      = permCard n * linSum n := by
    simp_rw [perm_vertex_sum]
    rw [Finset.sum_const, nsmul_eq_mul]
    simp [permCard]
  have hconst : ∑ j : Fin n, ∑ σ : Equiv.Perm (Fin n), rk σ j
      = ∑ _j : Fin n, ∑ σ : Equiv.Perm (Fin n), rk σ i :=
    Finset.sum_congr rfl fun j _ => sum_rk_indep_of_index j i
  rw [hconst, Finset.sum_const, nsmul_eq_mul] at hdouble
  simp only [Finset.card_univ, Fintype.card_fin] at hdouble
  rw [hdouble, hinner]

/-- The ensemble average of the inner product with a fixed ranking is the product of the
coordinate means. -/
theorem card_mul_sum_ip :
    (n : ℤ) * (∑ σ : Equiv.Perm (Fin n), ip σ 1) = permCard n * (linSum n) ^ 2 := by
  have hip : ∀ σ : Equiv.Perm (Fin n), ip σ 1 = ∑ i, rk σ i * ((i : ℕ) : ℤ) :=
    fun σ => Finset.sum_congr rfl fun i _ => by rw [rk_one]
  simp_rw [hip]
  rw [Finset.sum_comm, Finset.mul_sum]
  have hterm : ∀ i : Fin n,
      (n : ℤ) * (∑ σ : Equiv.Perm (Fin n), rk σ i * ((i : ℕ) : ℤ))
        = permCard n * linSum n * ((i : ℕ) : ℤ) := by
    intro i
    rw [← Finset.sum_mul, ← mul_assoc, card_mul_sum_rk i]
  simp_rw [hterm]
  rw [← Finset.mul_sum]
  have : ∑ i : Fin n, ((i : ℕ) : ℤ) = linSum n := rfl
  rw [this]
  ring

/-- **Exact first moment of the raw Spearman statistic.**  `E[∑d²] = (n³ − n)/6`. -/
theorem six_mul_sum_D :
    6 * (∑ σ : Equiv.Perm (Fin n), D σ 1) * (n : ℤ)
      = permCard n * ((n : ℤ) ^ 3 - (n : ℤ)) * (n : ℤ) := by
  have hD : ∀ σ : Equiv.Perm (Fin n), D σ 1 = 2 * (normSq n - ip σ 1) :=
    fun σ => D_eq_two_mul_sub σ 1
  have hsum : ∑ σ : Equiv.Perm (Fin n), D σ 1
      = 2 * (permCard n * normSq n - ∑ σ : Equiv.Perm (Fin n), ip σ 1) := by
    simp_rw [hD]
    rw [← Finset.mul_sum, Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul]
    simp [permCard]
  have hip := card_mul_sum_ip (n := n)
  have hlin := two_mul_linSum n
  have hnsq := six_mul_normSq n
  rw [hsum]
  linear_combination (-12 : ℤ) * hip + (2 * (n : ℤ) * permCard n) * hnsq +
    (-3 * permCard n * (2 * linSum n + (n : ℤ) * ((n : ℤ) - 1))) * hlin

/-- **The dial is exactly unbiased.**  Averaged over all rankings, the Spearman reading is
zero — not approximately, but identically. -/
theorem sprho_null_mean (hn : 2 ≤ n) : ∑ σ : Equiv.Perm (Fin n), sprho σ 1 = 0 := by
  have hpos := cube_sub_pos hn
  have hne : ((n : ℚ) ^ 3 - (n : ℚ)) ≠ 0 := ne_of_gt hpos
  have hn0 : (0 : ℤ) < (n : ℤ) := by
    have : (0 : ℕ) < n := by omega
    exact_mod_cast this
  have hmoment : 6 * (∑ σ : Equiv.Perm (Fin n), D σ 1) = permCard n * ((n : ℤ) ^ 3 - (n : ℤ)) := by
    have h := six_mul_sum_D (n := n)
    have hne0 : (n : ℤ) ≠ 0 := ne_of_gt hn0
    exact mul_right_cancel₀ hne0 h
  have hmomentQ : 6 * ((∑ σ : Equiv.Perm (Fin n), D σ 1 : ℤ) : ℚ)
      = ((permCard n : ℤ) : ℚ) * ((n : ℚ) ^ 3 - (n : ℚ)) := by
    exact_mod_cast hmoment
  have hA : ∑ _σ : Equiv.Perm (Fin n), (1 : ℚ) = ((permCard n : ℤ) : ℚ) := by
    simp [permCard]
  have hB : ∑ σ : Equiv.Perm (Fin n), 6 * (D σ 1 : ℚ) / ((n : ℚ) ^ 3 - (n : ℚ))
      = 6 * ((∑ σ : Equiv.Perm (Fin n), D σ 1 : ℤ) : ℚ) / ((n : ℚ) ^ 3 - (n : ℚ)) := by
    rw [← Finset.sum_div, ← Finset.mul_sum]
    push_cast
    ring
  have hexp : ∑ σ : Equiv.Perm (Fin n), sprho σ 1
      = ((permCard n : ℤ) : ℚ)
        - 6 * ((∑ σ : Equiv.Perm (Fin n), D σ 1 : ℤ) : ℚ) / ((n : ℚ) ^ 3 - (n : ℚ)) := by
    unfold sprho
    rw [Finset.sum_sub_distrib, hA, hB]
  have hdiv : 6 * ((∑ σ : Equiv.Perm (Fin n), D σ 1 : ℤ) : ℚ) / ((n : ℚ) ^ 3 - (n : ℚ))
      = ((permCard n : ℤ) : ℚ) := by
    rw [hmomentQ, mul_div_assoc, div_self hne, mul_one]
  rw [hexp, hdiv]
  ring

/-- Both signs occur: the ensemble cannot be uniformly positive. -/
theorem exists_sprho_nonpos (hn : 2 ≤ n) :
    ∃ σ : Equiv.Perm (Fin n), sprho σ 1 ≤ 0 := by
  by_contra hc
  push_neg at hc
  have hsum : 0 < ∑ σ : Equiv.Perm (Fin n), sprho σ 1 := by
    refine Finset.sum_pos (fun σ _ => hc σ) ?_
    exact ⟨1, Finset.mem_univ 1⟩
  rw [sprho_null_mean hn] at hsum
  exact lt_irrefl 0 hsum

theorem exists_sprho_nonneg :
    ∃ σ : Equiv.Perm (Fin n), 0 ≤ sprho σ 1 :=
  ⟨1, by simp [sprho, (D_eq_zero_iff (1 : Equiv.Perm (Fin n)) 1).2 rfl]⟩

/-! ## Lab notes -/

/-- Exhaustive `n = 3` check of the first-moment identity: `∑_σ ∑d² = 24 = 6·(3³−3)/6`. -/
theorem labnote_null_mean_fin3 :
    (∑ σ : Equiv.Perm (Fin 3), D σ 1) = 24 := by decide

end Catalog.Geometry.SpearmanNull