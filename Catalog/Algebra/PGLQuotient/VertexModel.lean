import Mathlib

/-!
# The standard arithmetic quotient of `PGL_d`: the vertex model

This file sets up an explicit combinatorial model for the vertex set of the standard
non-uniform arithmetic quotient of the affine Bruhat–Tits building of
`PGL_d (F_q((t^{-1})))` by `Γ = PGL_d(F_q[t])`.

By Soulé's theorem the quotient `Γ \ X` is (simplicially) a dominant sector: its vertices are
in bijection with dominant coweights `λ = (λ_0 ≥ λ_1 ≥ ⋯ ≥ λ_{d-1} = 0)`, and the stabiliser
of the vertex `λ` in `GL_d(F_q[t])` is the group of matrices `(a_{ij})` over `F_q[t]` with
`deg a_{ij} ≤ λ_i - λ_j`; equivalently, it is the automorphism group of the vector bundle
`⨁_i O(λ_i)` on `P^1`, i.e. the unit group of the algebra `End = ⨁_{i,j} H^0(O(λ_i - λ_j))`.
Its order is

`|Aut(λ)| = q^{dim End} * ∏_i (1 - q^{-r_i})`,

where `dim End = ∑_{i,j} max (0, λ_i - λ_j + 1)` and `r_i = #{ j ≤ i : λ_j = λ_i }` is the
position of `i` inside its block of equal entries (so that the second factor accounts for the
Levi `∏_b GL_{m_b}(F_q)` of the block composition).  With the Haar measure normalised so that
a maximal compact subgroup has volume `1`, the vertex `λ` carries the mass `1/|Aut(λ)|`
(`GL`-normalisation) resp. `(q-1)/|Aut(λ)|` (`PGL`-normalisation).

Vertices are parametrised here by their *gaps* `g_k = λ_k - λ_{k+1} ∈ ℕ`, `0 ≤ k ≤ d-2`, i.e.
by `Vertex d = Fin (d-1) → ℕ`.

The homothety-invariant normalised lattice-minima height is
`α(λ) = q^{λ_0 - (λ_0 + ⋯ + λ_{d-1})/d}`, which in gap coordinates reads
`log_q α = (∑_k (d-1-k) g_k)/d`.

## Main results of this file

* `sum_lam_sub_eq_pairExp` : the cut-set/double-counting identity
  `∑_{i,j} (λ_i - λ_j) = ∑_k (k+1)(d-1-k) g_k`;
* `vertexWeight_le`, `vertexWeight_ge` : sharp-order two-sided bounds
  `c₁ q^{-P(g)} ≤ 1/|Aut(λ)| ≤ c₂ q^{-P(g)}` with `P(g) = ∑_k (k+1)(d-1-k) g_k`.

These drive all the analytic results (integrability threshold, cusp tail, height zeta
function) in the companion files.
-/

namespace PGLQuotient

open Finset

/-- Vertices of the standard quotient in gap coordinates: `g k = λ_k - λ_{k+1}`. -/
abbrev Vertex (d : ℕ) : Type := Fin (d - 1) → ℕ

variable {d : ℕ}

/-- The `k`-th gap, extended by `0` outside the range. -/
def gapAt (g : Vertex d) (k : ℕ) : ℕ := if h : k < d - 1 then g ⟨k, h⟩ else 0

/-- The dominant coweight attached to a gap vector: `λ_i = ∑_{k ≥ i} g_k`. -/
def lam (g : Vertex d) (i : ℕ) : ℕ := ∑ k ∈ Finset.Ico i (d - 1), gapAt g k

/-- `dim_{F_q} End(⨁_i O(λ_i)) = ∑_{i,j} max (0, λ_i - λ_j + 1)`. -/
def endDim (g : Vertex d) : ℕ := ∑ i ∈ range d, ∑ j ∈ range d, (lam g i + 1 - lam g j)

/-- The position of `i` inside its block of equal coweight entries. -/
def blockRank (g : Vertex d) (i : ℕ) : ℕ :=
  ((range (i + 1)).filter (fun j => lam g j = lam g i)).card

/-- The order of the stabiliser `Aut(⨁_i O(λ_i))` of the vertex `g` in `GL_d(F_q[t])`. -/
noncomputable def autOrder (q : ℝ) (g : Vertex d) : ℝ :=
  q ^ endDim g * ∏ i ∈ range d, (1 - q⁻¹ ^ blockRank g i)

/-- The mass carried by a vertex of the quotient (Haar normalised by `vol(K) = 1`). -/
noncomputable def vertexWeight (q : ℝ) (g : Vertex d) : ℝ := (autOrder q g)⁻¹

/-- `d * log_q α`, the numerator of the normalised lattice-minima height. -/
def heightExp (g : Vertex d) : ℕ := ∑ k ∈ range (d - 1), (d - 1 - k) * gapAt g k

/-- The residual exponent `∑_k k (d-1-k) g_k`. -/
def resExp (g : Vertex d) : ℕ := ∑ k ∈ range (d - 1), k * (d - 1 - k) * gapAt g k

/-- The pair exponent `∑_{i<j} (λ_i - λ_j) = ∑_k (k+1)(d-1-k) g_k`. -/
def pairExp (g : Vertex d) : ℕ := ∑ k ∈ range (d - 1), (k + 1) * (d - 1 - k) * gapAt g k

/-- The homothety-invariant normalised lattice-minima height `α`. -/
noncomputable def height (q : ℝ) (g : Vertex d) : ℝ := q ^ ((heightExp g : ℝ) / d)

section Combinatorics

variable (g : Vertex d)

lemma lam_antitone {i j : ℕ} (h : i ≤ j) : lam g j ≤ lam g i := by
  refine Finset.sum_le_sum_of_subset ?_
  intro k hk
  simp only [Finset.mem_Ico] at hk ⊢
  exact ⟨le_trans h hk.1, hk.2⟩

lemma lam_sub {i j : ℕ} (hij : i ≤ j) (hj : j ≤ d - 1) :
    lam g i - lam g j = ∑ k ∈ Finset.Ico i j, gapAt g k := by
  have : lam g i = (∑ k ∈ Finset.Ico i j, gapAt g k) + lam g j := by
    unfold lam
    rw [← Finset.sum_Ico_consecutive _ hij hj]
  omega

/-- Pointwise description of `λ_i - λ_j` as a gap sum with an indicator. -/
lemma lam_sub_indicator {i j : ℕ} (hj : j < d) :
    lam g i - lam g j = ∑ k ∈ range (d - 1), (if i ≤ k ∧ k < j then gapAt g k else 0) := by
  rw [← Finset.sum_filter]
  by_cases hij : i < j
  · have hjd : j ≤ d - 1 := by omega
    rw [lam_sub g hij.le hjd]
    congr 1
    ext k
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico]
    omega
  · have h0 : lam g i - lam g j = 0 := by
      have := lam_antitone g (show j ≤ i by omega); omega
    rw [h0]
    symm
    apply Finset.sum_eq_zero
    intro k hk
    simp only [Finset.mem_filter] at hk
    omega

/-- The cut-set double-counting identity `∑_{i,j} (λ_i - λ_j) = ∑_k (k+1)(d-1-k) g_k`. -/
lemma sum_lam_sub_eq_pairExp :
    ∑ i ∈ range d, ∑ j ∈ range d, (lam g i - lam g j) = pairExp g := by
  have h1 : ∀ i ∈ range d, ∑ j ∈ range d, (lam g i - lam g j)
      = ∑ j ∈ range d, ∑ k ∈ range (d-1), (if i ≤ k ∧ k < j then gapAt g k else 0) := by
    intro i _
    exact Finset.sum_congr rfl (fun j hj => lam_sub_indicator g (Finset.mem_range.mp hj))
  rw [Finset.sum_congr rfl h1]
  have step1 : ∀ i : ℕ, ∑ j ∈ range d, ∑ k ∈ range (d-1), (if i ≤ k ∧ k < j then gapAt g k else 0)
      = ∑ k ∈ range (d-1), ∑ j ∈ range d, (if i ≤ k ∧ k < j then gapAt g k else 0) :=
    fun i => Finset.sum_comm
  rw [Finset.sum_congr rfl (fun i _ => step1 i), Finset.sum_comm]
  refine Finset.sum_congr rfl (fun k hk => ?_)
  have hkd : k < d - 1 := Finset.mem_range.mp hk
  have inner : ∀ i : ℕ, ∑ j ∈ range d, (if i ≤ k ∧ k < j then gapAt g k else 0)
      = if i ≤ k then (d - 1 - k) * gapAt g k else 0 := by
    intro i
    by_cases hik : i ≤ k
    · simp only [hik, true_and, if_true]
      rw [← Finset.sum_filter]
      have hfil : (range d).filter (fun j => k < j) = Finset.Ico (k+1) d := by
        ext j; simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico]; omega
      rw [hfil, Finset.sum_const, Nat.card_Ico, smul_eq_mul]
      congr 1
      omega
    · simp [hik]
  rw [Finset.sum_congr rfl (fun i _ => inner i), ← Finset.sum_filter]
  have hfil2 : (range d).filter (fun i => i ≤ k) = range (k+1) := by
    ext i; simp only [Finset.mem_filter, Finset.mem_range]; omega
  rw [hfil2, Finset.sum_const, Finset.card_range, smul_eq_mul, ← mul_assoc]

/-- The pair exponent splits into the height exponent and the residual exponent. -/
lemma pairExp_eq : pairExp g = heightExp g + resExp g := by
  unfold pairExp heightExp resExp
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl (fun k _ => ?_)
  ring

lemma pairExp_le_endDim : pairExp g ≤ endDim g := by
  rw [← sum_lam_sub_eq_pairExp]
  unfold endDim
  refine Finset.sum_le_sum (fun i _ => Finset.sum_le_sum (fun j _ => ?_))
  omega

lemma endDim_le_pairExp : endDim g ≤ pairExp g + d * d := by
  rw [← sum_lam_sub_eq_pairExp]
  unfold endDim
  calc ∑ i ∈ range d, ∑ j ∈ range d, (lam g i + 1 - lam g j)
      ≤ ∑ i ∈ range d, ∑ j ∈ range d, ((lam g i - lam g j) + 1) := by
        refine Finset.sum_le_sum (fun i _ => Finset.sum_le_sum (fun j _ => ?_))
        omega
    _ = (∑ i ∈ range d, ∑ j ∈ range d, (lam g i - lam g j)) + d * d := by
        simp [Finset.sum_add_distrib, Finset.sum_const]

lemma one_le_blockRank (i : ℕ) : 1 ≤ blockRank g i := by
  unfold blockRank
  refine Finset.card_pos.mpr ⟨i, ?_⟩
  simp

end Combinatorics

section Bounds

variable {q : ℝ} (g : Vertex d)

lemma inv_lt_one_of_one_lt (hq : 1 < q) : q⁻¹ < 1 := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  rw [inv_lt_one_iff₀]
  right; exact hq

lemma blockFactor_le_one (hq : 1 < q) (r : ℕ) : 1 - q⁻¹ ^ r ≤ 1 := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have : (0:ℝ) ≤ q⁻¹ ^ r := pow_nonneg (le_of_lt (inv_pos.mpr hq0)) r
  linarith

lemma blockFactor_ge (hq : 1 < q) {r : ℕ} (hr : 1 ≤ r) : 1 - q⁻¹ ≤ 1 - q⁻¹ ^ r := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have h1 : q⁻¹ ^ r ≤ q⁻¹ ^ 1 :=
    pow_le_pow_of_le_one (le_of_lt (inv_pos.mpr hq0)) (le_of_lt (inv_lt_one_of_one_lt hq)) hr
  simp only [pow_one] at h1
  linarith

lemma one_sub_inv_pos (hq : 1 < q) : 0 < 1 - q⁻¹ := by
  have := inv_lt_one_of_one_lt hq; linarith

lemma prod_blockFactor_le_one (hq : 1 < q) :
    ∏ i ∈ range d, (1 - q⁻¹ ^ blockRank g i) ≤ 1 := by
  refine Finset.prod_le_one (fun i _ => ?_) (fun i _ => blockFactor_le_one hq _)
  have := blockFactor_ge (q := q) hq (one_le_blockRank g i)
  have := one_sub_inv_pos (q := q) hq
  linarith

lemma prod_blockFactor_ge (hq : 1 < q) :
    (1 - q⁻¹) ^ d ≤ ∏ i ∈ range d, (1 - q⁻¹ ^ blockRank g i) := by
  have h := one_sub_inv_pos (q := q) hq
  calc (1 - q⁻¹) ^ d = ∏ _i ∈ range d, (1 - q⁻¹) := by
        rw [Finset.prod_const, Finset.card_range]
    _ ≤ ∏ i ∈ range d, (1 - q⁻¹ ^ blockRank g i) := by
        refine Finset.prod_le_prod (fun i _ => le_of_lt h)
          (fun i _ => blockFactor_ge hq (one_le_blockRank g i))

lemma prod_blockFactor_pos (hq : 1 < q) :
    0 < ∏ i ∈ range d, (1 - q⁻¹ ^ blockRank g i) :=
  lt_of_lt_of_le (pow_pos (one_sub_inv_pos hq) d) (prod_blockFactor_ge g hq)

lemma autOrder_pos (hq : 1 < q) : 0 < autOrder q g := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  exact mul_pos (pow_pos hq0 _) (prod_blockFactor_pos g hq)

lemma vertexWeight_pos (hq : 1 < q) : 0 < vertexWeight q g :=
  inv_pos.mpr (autOrder_pos g hq)

/-- Upper bound for the vertex mass: `1/|Aut| ≤ (1-1/q)^{-d} q^{-P(g)}`. -/
lemma vertexWeight_le (hq : 1 < q) :
    vertexWeight q g ≤ ((1 - q⁻¹) ^ d)⁻¹ * (q ^ pairExp g)⁻¹ := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hlow : (q ^ pairExp g) * (1 - q⁻¹) ^ d ≤ autOrder q g := by
    unfold autOrder
    refine mul_le_mul ?_ (prod_blockFactor_ge g hq) (le_of_lt (pow_pos (one_sub_inv_pos hq) d))
      (le_of_lt (pow_pos hq0 _))
    exact pow_le_pow_right₀ hq.le (pairExp_le_endDim g)
  have hpos : 0 < (q ^ pairExp g) * (1 - q⁻¹) ^ d :=
    mul_pos (pow_pos hq0 _) (pow_pos (one_sub_inv_pos hq) d)
  unfold vertexWeight
  rw [show ((1 - q⁻¹) ^ d)⁻¹ * (q ^ pairExp g)⁻¹ = ((q ^ pairExp g) * (1 - q⁻¹) ^ d)⁻¹ by
    rw [mul_inv]; ring]
  exact inv_anti₀ hpos hlow

/-- Lower bound for the vertex mass: `q^{-d^2} q^{-P(g)} ≤ 1/|Aut|`. -/
lemma vertexWeight_ge (hq : 1 < q) :
    (q ^ (d * d))⁻¹ * (q ^ pairExp g)⁻¹ ≤ vertexWeight q g := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hhigh : autOrder q g ≤ q ^ (pairExp g + d * d) := by
    unfold autOrder
    calc q ^ endDim g * ∏ i ∈ range d, (1 - q⁻¹ ^ blockRank g i)
        ≤ q ^ endDim g * 1 := by
          exact mul_le_mul_of_nonneg_left (prod_blockFactor_le_one g hq)
            (le_of_lt (pow_pos hq0 _))
      _ = q ^ endDim g := by ring
      _ ≤ q ^ (pairExp g + d * d) := pow_le_pow_right₀ hq.le (endDim_le_pairExp g)
  unfold vertexWeight
  rw [show (q ^ (d * d))⁻¹ * (q ^ pairExp g)⁻¹ = (q ^ (pairExp g + d * d))⁻¹ by
    rw [pow_add, mul_inv]; ring]
  exact inv_anti₀ (autOrder_pos g hq) hhigh

end Bounds

end PGLQuotient