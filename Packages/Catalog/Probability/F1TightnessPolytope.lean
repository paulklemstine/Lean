import Mathlib
import Probability.F1TightnessCore
import Probability.F1TightnessFibration

/-!
# The constrained mean-position polytope of the slack factor

`Probability.F1TightnessFibration` solved the *unconstrained* extremal problem
for the slack factor `X`: since `X` depends on the profile only through the mean
probe position `E_x`, and the reachable mean positions form the interval
`[1/(2M), (2M−1)/(2M)]`, the reachable slacks are exactly
`[(M+1)/(2M), (M+1)/2]`.

Direction 3 of `FUTURE_DIRECTIONS.md` asks for the same computation under the
measured *tail* constraint: the profile must place at least a mass `m` on the
cells from index `K` on (the "edge mass bounded below" constraint of the
measured positional profile).  This file closes that question for a single
linear tail constraint.

* `edgeMass` — the mass on the cells of index `≥ K`.
* `meanPos_ge_of_edgeMass` — the sharp linear-programming bound
  `E_x ≥ (1/2 + K·m)/M` for every admissible profile.
* `gapX_le_of_edgeMass` — the resulting constraint on the slack,
  `X ≤ (M+1)/(2·K·m + 2)`.
* `pairProfile` — the two-cell profile `(1−m)·δ_a + m·δ_b`; the bound above is
  attained by `pairProfile 0 K m`, so the extremal profile of the constrained
  linear programme is supported on **at most two cells**, as conjectured.
* `constrained_gapX_range_sharp` — the packaged statement: under the tail
  constraint the reachable slacks are exactly `[(M+1)/(2M), (M+1)/(2·K·m+2)]`,
  both endpoints attained.
* `edgeMass_bound_of_gapX` — read backwards, a *measured* slack bounds the
  admissible edge mass: `K·m ≤ ((M+1)/X − 2)/2`.  This is the promised transfer
  of the booked CI on `Λ` into a constraint on the prior itself.
-/

namespace F1Tightness

open Finset

variable {M : ℕ}

/-- The **edge mass** at cut `K`: the probability the target sits in a cell of
index `≥ K`. -/
noncomputable def edgeMass (K : ℕ) (p : Fin M → ℝ) : ℝ :=
  ∑ i ∈ Finset.univ.filter (fun i : Fin M => K ≤ (i : ℕ)), p i

/-- The mean position splits off its minimal value `1/(2M)`: the remainder is
the index-weighted mass. -/
theorem meanPos_eq_half_add {p : Fin M → ℝ} (hM : 0 < M)
    (hsum : ∑ i : Fin M, p i = 1) :
    meanPos p = 1 / (2 * (M : ℝ)) + ∑ i : Fin M, (((i : ℕ) : ℝ) / (M : ℝ)) * p i := by
  have hMR : (M : ℝ) ≠ 0 := by
    have : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
    exact this.ne'
  have h : ∀ i : Fin M, ((((i : ℕ) : ℝ) + 1 / 2) / (M : ℝ)) * p i
      = (1 / (2 * (M : ℝ))) * p i + (((i : ℕ) : ℝ) / (M : ℝ)) * p i := by
    intro i
    field_simp
    ring
  rw [meanPos, Finset.sum_congr rfl fun i _ => h i, Finset.sum_add_distrib,
    ← Finset.mul_sum, hsum]
  ring

/-- **Linear-programming bound.**  A profile that places at least mass `m` on
the cells of index `≥ K` has mean probe position at least `(1/2 + K·m)/M`. -/
theorem meanPos_ge_of_edgeMass {K : ℕ} {m : ℝ} {p : Fin M → ℝ} (hM : 0 < M)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i : Fin M, p i = 1) (hm : m ≤ edgeMass K p) :
    (1 / 2 + (K : ℝ) * m) / (M : ℝ) ≤ meanPos p := by
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  set S : Finset (Fin M) := Finset.univ.filter (fun i : Fin M => K ≤ (i : ℕ)) with hS
  have hsub : ∑ i ∈ S, (((i : ℕ) : ℝ) / (M : ℝ)) * p i
      ≤ ∑ i : Fin M, (((i : ℕ) : ℝ) / (M : ℝ)) * p i := by
    refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S) ?_
    intro i _ _
    have := hp i
    positivity
  have hterm : ∀ i ∈ S, ((K : ℝ) / (M : ℝ)) * p i ≤ (((i : ℕ) : ℝ) / (M : ℝ)) * p i := by
    intro i hi
    have hKi : (K : ℝ) ≤ ((i : ℕ) : ℝ) := by
      have : K ≤ (i : ℕ) := by
        simpa [hS] using hi
      exact_mod_cast this
    have hdiv : (K : ℝ) / (M : ℝ) ≤ ((i : ℕ) : ℝ) / (M : ℝ) := by gcongr
    nlinarith [hp i]
  have hlow : ((K : ℝ) / (M : ℝ)) * edgeMass K p
      ≤ ∑ i ∈ S, (((i : ℕ) : ℝ) / (M : ℝ)) * p i := by
    rw [edgeMass, ← hS, Finset.mul_sum]
    exact Finset.sum_le_sum hterm
  have hKm : ((K : ℝ) / (M : ℝ)) * m ≤ ((K : ℝ) / (M : ℝ)) * edgeMass K p := by
    have hK0 : (0 : ℝ) ≤ (K : ℝ) / (M : ℝ) := by positivity
    exact mul_le_mul_of_nonneg_left hm hK0
  have hmean := meanPos_eq_half_add (p := p) hM hsum
  have hsplit : (1 / 2 + (K : ℝ) * m) / (M : ℝ)
      = 1 / (2 * (M : ℝ)) + ((K : ℝ) / (M : ℝ)) * m := by
    field_simp
  rw [hsplit, hmean]
  linarith

/-- The slack factor of a profile obeying the edge-mass constraint is at most
`(M+1)/(2·K·m + 2)`. -/
theorem gapX_le_of_edgeMass {K : ℕ} {m : ℝ} {p : Fin M → ℝ} (hM : 0 < M)
    (hm0 : 0 ≤ m) (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i : Fin M, p i = 1)
    (hm : m ≤ edgeMass K p) :
    gapX p ≤ ((M : ℝ) + 1) / (2 * (K : ℝ) * m + 2) := by
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  have hE := meanPos_ge_of_edgeMass hM hp hsum hm
  have hden : 2 * (K : ℝ) * m + 2 ≤ 2 * (M : ℝ) * meanPos p + 1 := by
    have h1 : (1 / 2 + (K : ℝ) * m) ≤ (M : ℝ) * meanPos p := by
      rw [div_le_iff₀ hMR] at hE
      nlinarith [hE]
    linarith
  have hpos : (0 : ℝ) < 2 * (K : ℝ) * m + 2 := by positivity
  rw [gapX_eq_meanPos hM hp hsum]
  have hM1 : (0 : ℝ) ≤ (M : ℝ) + 1 := by positivity
  exact div_le_div_of_nonneg_left hM1 hpos hden

/-! ## Attainment by a two-cell profile -/

/-- The two-cell profile `(1−m)·δ_a + m·δ_b`. -/
noncomputable def pairProfile (a b : Fin M) (m : ℝ) : Fin M → ℝ :=
  fun i => (if i = a then 1 - m else 0) + (if i = b then m else 0)

theorem pairProfile_nonneg {a b : Fin M} {m : ℝ} (h0 : 0 ≤ m) (h1 : m ≤ 1) :
    ∀ i, 0 ≤ pairProfile a b m i := by
  intro i
  unfold pairProfile
  have h₁ : (0 : ℝ) ≤ if i = a then 1 - m else 0 := by
    split <;> linarith
  have h₂ : (0 : ℝ) ≤ if i = b then m else 0 := by
    split <;> linarith
  linarith

theorem pairProfile_sum (a b : Fin M) (m : ℝ) :
    ∑ i : Fin M, pairProfile a b m i = 1 := by
  unfold pairProfile
  rw [Finset.sum_add_distrib]
  simp

theorem pairProfile_meanPos (a b : Fin M) (m : ℝ) :
    meanPos (pairProfile a b m)
      = ((((a : ℕ) : ℝ) + 1 / 2) / (M : ℝ)) * (1 - m)
        + ((((b : ℕ) : ℝ) + 1 / 2) / (M : ℝ)) * m := by
  unfold meanPos pairProfile
  have h : ∀ i : Fin M,
      ((((i : ℕ) : ℝ) + 1 / 2) / (M : ℝ))
          * ((if i = a then 1 - m else 0) + (if i = b then m else 0))
        = (if i = a then ((((i : ℕ) : ℝ) + 1 / 2) / (M : ℝ)) * (1 - m) else 0)
          + (if i = b then ((((i : ℕ) : ℝ) + 1 / 2) / (M : ℝ)) * m else 0) := by
    intro i
    split_ifs <;> ring
  rw [Finset.sum_congr rfl fun i _ => h i, Finset.sum_add_distrib]
  simp

/-- The two-cell profile places exactly the mass `m` on the tail, provided the
first atom lies strictly before the cut and the second atom at or after it. -/
theorem pairProfile_edgeMass {K : ℕ} {a b : Fin M} {m : ℝ}
    (ha : (a : ℕ) < K) (hb : K ≤ (b : ℕ)) :
    edgeMass K (pairProfile a b m) = m := by
  have hane : ∀ i ∈ Finset.univ.filter (fun i : Fin M => K ≤ (i : ℕ)), i ≠ a := by
    intro i hi hia
    have : K ≤ (i : ℕ) := by simpa using hi
    rw [hia] at this
    omega
  unfold edgeMass pairProfile
  rw [Finset.sum_add_distrib]
  have h1 : ∑ i ∈ Finset.univ.filter (fun i : Fin M => K ≤ (i : ℕ)),
      (if i = a then 1 - m else 0) = 0 := by
    refine Finset.sum_eq_zero ?_
    intro i hi
    simp [hane i hi]
  have h2 : ∑ i ∈ Finset.univ.filter (fun i : Fin M => K ≤ (i : ℕ)),
      (if i = b then m else 0) = m := by
    rw [Finset.sum_ite_eq' _ b]
    simp [hb]
  rw [h1, h2, zero_add]

/-- **Extremal profile of the constrained programme.**  The profile that puts
`1−m` on the first cell and `m` on the cut cell attains the bound of
`gapX_le_of_edgeMass`. -/
theorem pairProfile_gapX_extremal {K : ℕ} {m : ℝ} (hM : 0 < M)
    (hKM : K < M) (h0 : 0 ≤ m) (h1 : m ≤ 1) :
    gapX (pairProfile (⟨0, hM⟩ : Fin M) (⟨K, hKM⟩ : Fin M) m)
      = ((M : ℝ) + 1) / (2 * (K : ℝ) * m + 2) := by
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  have hmean : meanPos (pairProfile (⟨0, hM⟩ : Fin M) (⟨K, hKM⟩ : Fin M) m)
      = (1 / 2 + (K : ℝ) * m) / (M : ℝ) := by
    rw [pairProfile_meanPos]
    field_simp
    ring
  rw [gapX_eq_meanPos hM (pairProfile_nonneg h0 h1) (pairProfile_sum _ _ m), hmean]
  have hden : 2 * (M : ℝ) * ((1 / 2 + (K : ℝ) * m) / (M : ℝ)) + 1
      = 2 * (K : ℝ) * m + 2 := by
    field_simp
    ring
  rw [hden]

/-- **The constrained range is exact.**  Under the tail constraint
`edgeMass K p ≥ m` the slack factor ranges over
`[(M+1)/(2M), (M+1)/(2·K·m+2)]`; the upper endpoint is attained by a two-cell
profile and the lower endpoint by the last-cell point mass. -/
theorem constrained_gapX_range_sharp {K : ℕ} {m : ℝ} (hM : 0 < M) (hK : 0 < K)
    (hKM : K < M) (h0 : 0 ≤ m) (h1 : m ≤ 1) :
    (∀ p : Fin M → ℝ, (∀ i, 0 ≤ p i) → (∑ i : Fin M, p i = 1) → m ≤ edgeMass K p →
        ((M : ℝ) + 1) / (2 * (M : ℝ)) ≤ gapX p
          ∧ gapX p ≤ ((M : ℝ) + 1) / (2 * (K : ℝ) * m + 2))
      ∧ (edgeMass K (pairProfile (⟨0, hM⟩ : Fin M) (⟨K, hKM⟩ : Fin M) m) = m
          ∧ gapX (pairProfile (⟨0, hM⟩ : Fin M) (⟨K, hKM⟩ : Fin M) m)
              = ((M : ℝ) + 1) / (2 * (K : ℝ) * m + 2))
      ∧ (m ≤ edgeMass K (deltaLast M)
          ∧ gapX (deltaLast M) = ((M : ℝ) + 1) / (2 * (M : ℝ))) := by
  refine ⟨?_, ⟨?_, ?_⟩, ?_, ?_⟩
  · intro p hp hsum hm
    exact ⟨(gapX_mem_Icc hM hp hsum).1, gapX_le_of_edgeMass hM h0 hp hsum hm⟩
  · exact pairProfile_edgeMass (by simp [hK]) (by simp)
  · exact pairProfile_gapX_extremal hM hKM h0 h1
  · have hlast : edgeMass K (deltaLast M) = 1 := by
      unfold edgeMass deltaLast
      have h : ∀ i : Fin M, (if ((i : ℕ) = M - 1) then (1 : ℝ) else 0)
          = (if i = (⟨M - 1, by omega⟩ : Fin M) then (1 : ℝ) else 0) := by
        intro i
        simp [Fin.ext_iff]
      rw [Finset.sum_congr rfl fun i _ => h i,
        Finset.sum_ite_eq' _ (⟨M - 1, by omega⟩ : Fin M)]
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      rw [if_pos (by omega)]
    rw [hlast]
    exact h1
  · exact deltaLast_gapX hM

/-- **Reading the constraint backwards.**  A measured slack `X` caps the
admissible edge mass: `K·m ≤ ((M+1)/X − 2)/2`.  This converts the booked
interval for the slack into a constraint on the prior itself. -/
theorem edgeMass_bound_of_gapX {K : ℕ} {m x : ℝ} {p : Fin M → ℝ} (hM : 0 < M)
    (hm0 : 0 ≤ m) (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i : Fin M, p i = 1)
    (hm : m ≤ edgeMass K p) (hx : 0 < x) (hxle : x ≤ gapX p) :
    2 * (K : ℝ) * m + 2 ≤ ((M : ℝ) + 1) / x := by
  have hMR : (0 : ℝ) < (M : ℝ) := by exact_mod_cast hM
  have hden : (0 : ℝ) < 2 * (K : ℝ) * m + 2 := by positivity
  have hle := gapX_le_of_edgeMass hM hm0 hp hsum hm
  have hxX : x ≤ ((M : ℝ) + 1) / (2 * (K : ℝ) * m + 2) := le_trans hxle hle
  rw [le_div_iff₀ hden] at hxX
  rw [le_div_iff₀ hx]
  linarith

end F1Tightness