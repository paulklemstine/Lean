import Algebra.PGLQuotient.HeightThreshold

/-!
# The open stratum of the dominant sector, in every rank

The dominant sector `ℕ^{d-1}` parametrising the vertices of the standard arithmetic quotient
is stratified by the vanishing pattern of the gaps `g_k = λ_k - λ_{k+1}`; this is the
"cut-set" decomposition used to evaluate the vertex volume.  Here we treat the *open* (generic)
stratum `g_k ≥ 1` for all `k`, in **arbitrary rank `d`**, and obtain its mass in closed
product form:

`∑_{λ regular dominant} 1/|Aut λ| = 1 / ( q^{d(d-1)/2} (q-1)^d ∏_{k=1}^{d-1} (q^{k(d-k)} - 1) )`.

For `d = 2` this is `1/(q (q-1)^3)` and for `d = 3` it is `1/(q^3 (q-1)^3 (q^2-1)^2)`,
matching the open-stratum terms of `vertexVolume_rank_two` and `vertexVolume_rank_three`.

The three building-theoretic inputs, all established here in arbitrary rank, are:

* `lam_lt_of_gap_pos`  : on the open stratum the coweight `λ` is strictly decreasing;
* `blockRank_open`     : hence every block has size one, so the reductive part of the
  stabiliser is a maximal torus and contributes `(1 - q^{-1})^d`;
* `endDim_open`        : hence `dim End(⨁ O(λ_i)) = ∑_{i<j}(λ_i - λ_j) + d(d+1)/2` exactly.

The resulting sum is a product of `d-1` independent geometric series, evaluated with
`summable_pi_geom`.
-/

namespace PGLQuotient

open Finset

variable {d : ℕ} {q : ℝ}

/-! ### A triangular-number identity -/

lemma sum_range_sub_eq (n : ℕ) : ∑ i ∈ range n, (n - i) = n + n * (n - 1) / 2 := by
  have h1 : ∑ i ∈ range n, (n - i) = ∑ i ∈ range n, (i + 1) := by
    conv_rhs => rw [← Finset.sum_range_reflect]
    refine Finset.sum_congr rfl (fun i hi => ?_)
    have := Finset.mem_range.mp hi
    omega
  have h2 : ∑ i ∈ range n, (i + 1) = (∑ i ∈ range n, i) + n := by
    rw [Finset.sum_add_distrib, Finset.sum_const, Finset.card_range, smul_eq_mul, mul_one]
  have h3 := Finset.sum_range_id_mul_two n
  omega

/-! ### The open stratum -/

section OpenStratum

variable (g : Vertex d)

/-- On the open stratum the dominant coweight is *strictly* decreasing. -/
lemma lam_lt_of_gap_pos (h : ∀ k, 1 ≤ g k) {i j : ℕ} (hji : j < i) (hi : i < d) :
    lam g i < lam g j := by
  have hid : i ≤ d - 1 := by omega
  have hsub : lam g j - lam g i = ∑ k ∈ Finset.Ico j i, gapAt g k :=
    lam_sub g hji.le hid
  have hpos : 1 ≤ ∑ k ∈ Finset.Ico j i, gapAt g k := by
    have hmem : j ∈ Finset.Ico j i := Finset.mem_Ico.mpr ⟨le_refl _, hji⟩
    have hterm : 1 ≤ gapAt g j := by
      have hjd : j < d - 1 := by omega
      rw [gapAt, dif_pos hjd]
      exact h _
    calc 1 ≤ gapAt g j := hterm
      _ ≤ ∑ k ∈ Finset.Ico j i, gapAt g k :=
        Finset.single_le_sum (fun k _ => Nat.zero_le _) hmem
  have hanti : lam g i ≤ lam g j := lam_antitone g hji.le
  omega

/-- On the open stratum every block of equal coweight entries is a singleton. -/
lemma blockRank_open (h : ∀ k, 1 ≤ g k) {i : ℕ} (hi : i < d) : blockRank g i = 1 := by
  have hfil : (range (i + 1)).filter (fun j => lam g j = lam g i) = {i} := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_singleton]
    constructor
    · rintro ⟨hj, hlam⟩
      by_contra hne
      have hji : j < i := by omega
      exact absurd hlam (ne_of_gt (lam_lt_of_gap_pos g h hji hi))
    · rintro rfl
      exact ⟨Nat.lt_succ_self _, rfl⟩
  unfold blockRank
  rw [hfil, Finset.card_singleton]

/-- On the open stratum the endomorphism dimension is exactly
`∑_{i<j}(λ_i - λ_j) + d(d+1)/2`. -/
lemma endDim_open (h : ∀ k, 1 ≤ g k) :
    endDim g = pairExp g + (d + d * (d - 1) / 2) := by
  have hterm : ∀ i ∈ range d, ∀ j ∈ range d,
      (lam g i + 1 - lam g j) = (lam g i - lam g j) + (if i ≤ j then 1 else 0) := by
    intro i hi j hj
    have hi' := Finset.mem_range.mp hi
    by_cases hij : i ≤ j
    · have := lam_antitone g hij
      rw [if_pos hij]
      omega
    · have hji : j < i := by omega
      have := lam_lt_of_gap_pos g h hji hi'
      rw [if_neg hij]
      omega
  have hsplit : endDim g
      = (∑ i ∈ range d, ∑ j ∈ range d, (lam g i - lam g j))
        + ∑ i ∈ range d, ∑ j ∈ range d, (if i ≤ j then 1 else 0) := by
    unfold endDim
    rw [← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl (fun i hi => ?_)
    rw [← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl (fun j hj => hterm i hi j hj)
  have hcount : ∀ i ∈ range d, (∑ j ∈ range d, (if i ≤ j then 1 else 0)) = d - i := by
    intro i _
    rw [← Finset.sum_filter]
    have hf : (range d).filter (fun j => i ≤ j) = Finset.Ico i d := by
      ext j
      simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico]
      omega
    rw [hf, Finset.sum_const, Nat.card_Ico, smul_eq_mul, mul_one]
  rw [hsplit, sum_lam_sub_eq_pairExp, Finset.sum_congr rfl hcount, sum_range_sub_eq]

/-- The exact stabiliser order on the open stratum, in arbitrary rank. -/
lemma autOrder_open (h : ∀ k, 1 ≤ g k) :
    autOrder q g = q ^ (pairExp g + (d + d * (d - 1) / 2)) * (1 - q⁻¹) ^ d := by
  unfold autOrder
  rw [endDim_open g h]
  congr 1
  rw [Finset.prod_congr rfl (fun i hi => by
      rw [blockRank_open g h (Finset.mem_range.mp hi)]), Finset.prod_const, Finset.card_range]
  simp

end OpenStratum

/-! ### The mass of the open stratum -/

/-- The coefficient of `g_k` in `∑_{i<j} (λ_i - λ_j)`, namely `(k+1)(d-1-k)`. -/
def pairCoef (d k : ℕ) : ℕ := (k + 1) * (d - 1 - k)

/-- The total coefficient `∑_{k=1}^{d-1} k(d-k)`. -/
def pairSum (d : ℕ) : ℕ := ∑ k ∈ range (d - 1), pairCoef d k

lemma pairExp_shift (g : Vertex d) :
    pairExp (fun k => g k + 1) = pairExp g + pairSum d := by
  unfold pairExp pairSum pairCoef
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl (fun k hk => ?_)
  have hk' : k < d - 1 := Finset.mem_range.mp hk
  rw [gapAt, dif_pos hk', gapAt, dif_pos hk']
  ring

lemma pairExp_eq_fin_sum (g : Vertex d) :
    pairExp g = ∑ k : Fin (d - 1), pairCoef d (k : ℕ) * g k := by
  have h1 : ∑ k : Fin (d - 1), pairCoef d (k : ℕ) * g k
      = ∑ k ∈ range (d - 1), pairCoef d k * gapAt g k := by
    rw [← Fin.sum_univ_eq_sum_range (fun k : ℕ => pairCoef d k * gapAt g k) (d - 1)]
    exact Finset.sum_congr rfl (fun k _ => by rw [gapAt_coe])
  rw [h1]
  unfold pairExp pairCoef
  rfl

/-- **The mass of the open stratum, in arbitrary rank.**  Summing `1/|Aut λ|` over the regular
dominant coweights (all gaps `≥ 1`) gives the closed product form
`1 / (q^{d(d-1)/2} (q-1)^d ∏_{k=1}^{d-1} (q^{k(d-k)} - 1))`. -/
theorem openStratum_mass (hq : 1 < q) :
    ∑' g : Vertex d, vertexWeight q (fun k => g k + 1)
      = (q ^ (d * (d - 1) / 2) * (q - 1) ^ d)⁻¹
        * ∏ k ∈ range (d - 1), (q ^ pairCoef d k - 1)⁻¹ := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hqne : q ≠ 0 := ne_of_gt hq0
  have hq1 : (0:ℝ) < q - 1 := by linarith
  have hq1' : q - 1 ≠ 0 := ne_of_gt hq1
  have hcpos : ∀ k : Fin (d - 1), 1 ≤ pairCoef d (k : ℕ) := by
    intro k
    have hk := k.isLt
    unfold pairCoef
    have h2 : 1 ≤ d - 1 - (k : ℕ) := by omega
    calc 1 = 1 * 1 := by ring
      _ ≤ ((k : ℕ) + 1) * (d - 1 - (k : ℕ)) := Nat.mul_le_mul (by omega) h2
  have hqcgt : ∀ k : Fin (d - 1), 1 < q ^ pairCoef d (k : ℕ) :=
    fun k => one_lt_pow₀ hq (by have := hcpos k; omega)
  have hx0 : ∀ k : Fin (d - 1), (0:ℝ) ≤ (q ^ pairCoef d (k : ℕ))⁻¹ := fun k => by positivity
  have hx1 : ∀ k : Fin (d - 1), (q ^ pairCoef d (k : ℕ))⁻¹ < 1 := by
    intro k
    rw [inv_lt_one_iff₀]
    right
    exact hqcgt k
  obtain ⟨hsum, hval⟩ :=
    summable_pi_geom (fun k : Fin (d - 1) => (q ^ pairCoef d (k : ℕ))⁻¹) hx0 hx1
  have hweight : ∀ g : Vertex d,
      vertexWeight q (fun k => g k + 1)
        = (q ^ (pairSum d + (d + d * (d - 1) / 2)) * (1 - q⁻¹) ^ d)⁻¹
          * ∏ k : Fin (d - 1), ((q ^ pairCoef d (k : ℕ))⁻¹) ^ g k := by
    intro g
    have hpos : ∀ k : Fin (d - 1), 1 ≤ (fun k => g k + 1) k := fun k => Nat.le_add_left 1 _
    have hprodx : ∏ k : Fin (d - 1), ((q ^ pairCoef d (k : ℕ))⁻¹) ^ g k = (q ^ pairExp g)⁻¹ := by
      simp only [← inv_pow, ← pow_mul]
      rw [Finset.prod_pow_eq_pow_sum, ← pairExp_eq_fin_sum g]
    unfold vertexWeight
    rw [autOrder_open (q := q) (fun k => g k + 1) hpos, pairExp_shift g, hprodx,
      show pairExp g + pairSum d + (d + d * (d - 1) / 2)
        = (pairSum d + (d + d * (d - 1) / 2)) + pairExp g from by ring, pow_add]
    simp only [mul_inv]
    ring
  rw [tsum_congr hweight, hsum.tsum_mul_left, hval]
  have hfactor : ∀ k : Fin (d - 1),
      (1 - (q ^ pairCoef d (k : ℕ))⁻¹)⁻¹
        = q ^ pairCoef d (k : ℕ) * (q ^ pairCoef d (k : ℕ) - 1)⁻¹ := by
    intro k
    have h1 : (0:ℝ) < q ^ pairCoef d (k : ℕ) := by positivity
    have h2 : q ^ pairCoef d (k : ℕ) - 1 ≠ 0 := by have := hqcgt k; linarith
    have key : (1 : ℝ) - (q ^ pairCoef d (k : ℕ))⁻¹
        = (q ^ pairCoef d (k : ℕ) - 1) / q ^ pairCoef d (k : ℕ) := by
      field_simp
    rw [key, inv_div, div_eq_mul_inv]
  rw [Finset.prod_congr rfl (fun k _ => hfactor k), Finset.prod_mul_distrib,
    Finset.prod_pow_eq_pow_sum]
  have hSfin : ∑ k : Fin (d - 1), pairCoef d (k : ℕ) = pairSum d :=
    Fin.sum_univ_eq_sum_range (fun k : ℕ => pairCoef d k) (d - 1)
  have hPfin : ∏ k : Fin (d - 1), (q ^ pairCoef d (k : ℕ) - 1)⁻¹
      = ∏ k ∈ range (d - 1), (q ^ pairCoef d k - 1)⁻¹ :=
    Fin.prod_univ_eq_prod_range (fun k : ℕ => (q ^ pairCoef d k - 1)⁻¹) (d - 1)
  rw [hSfin, hPfin]
  have hinvq : (1 : ℝ) - q⁻¹ = (q - 1) / q := by field_simp
  rw [hinvq, div_pow, pow_add, pow_add]
  have hqs : (q : ℝ) ^ pairSum d ≠ 0 := pow_ne_zero _ hqne
  have hqd : (q : ℝ) ^ d ≠ 0 := pow_ne_zero _ hqne
  have hqD : (q : ℝ) ^ (d * (d - 1) / 2) ≠ 0 := pow_ne_zero _ hqne
  field_simp

end PGLQuotient