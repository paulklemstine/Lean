import Algebra.PGLQuotient.CuspTail

/-!
# Rank two: exact vertex volume and the height zeta function

For `d = 2` the standard arithmetic quotient is the ray `Γ \ X` of Serre's theory of trees:
the vertex `λ = (n, 0)` has stabiliser of order `|GL_2(F_q)|` for `n = 0` and
`(q-1)^2 q^{n+1}` for `n ≥ 1`.  We compute here, with no sorries:

* `autOrder_rank_two` : the exact stabiliser order;
* `heightZeta_rank_two` : the positive-moment height zeta function
  `Z(s) = ∑_λ α(λ)^s / |Aut λ|` in closed form for `s < 2`, exhibiting it as a *rational*
  function of `u = q^{s/2}`, namely
  `Z = 1/(q(q-1)(q^2-1)) + u/((q-1)^2 q (q-u))`,
  whose unique pole sits at `u = q`, i.e. exactly at `s = d = 2`;
* `vertexMass_rank_two`, `vertexVolume_rank_two` : the closed product form of the vertex
  volume, obtained by specialising to `s = 0`:
  `∑_λ 1/|Aut λ| = 2/((q-1)^2 (q^2-1))`, so the `PGL`-normalised vertex volume is
  `(q-1) ∑_λ 1/|Aut λ| = 2/((q-1)(q^2-1))`;
* `heightZeta_rank_two_unbounded` : `Z(s) → ∞` as `s ↑ 2`, i.e. the pole is genuine.
-/

namespace PGLQuotient

open Finset

variable {q : ℝ}

/-! ### Explicit rank-two data -/

lemma lam_rank_two_zero (g : Vertex 2) : lam g 0 = g 0 := by
  simp [lam, gapAt]

lemma lam_rank_two_one (g : Vertex 2) : lam g 1 = 0 := by
  simp [lam]

lemma heightExp_rank_two (g : Vertex 2) : heightExp g = g 0 := by
  simp [heightExp, gapAt]

lemma endDim_rank_two (g : Vertex 2) : endDim g = if g 0 = 0 then 4 else g 0 + 3 := by
  simp only [endDim, Finset.sum_range_succ, Finset.sum_range_zero, zero_add,
    lam_rank_two_zero, lam_rank_two_one]
  split <;> omega

lemma blockRank_rank_two_zero (g : Vertex 2) : blockRank g 0 = 1 := by
  simp [blockRank, Finset.filter_singleton]

lemma blockRank_rank_two_one (g : Vertex 2) : blockRank g 1 = if g 0 = 0 then 2 else 1 := by
  have hr : range (1 + 1) = ({0, 1} : Finset ℕ) := by decide
  unfold blockRank
  rw [hr, Finset.filter_insert, Finset.filter_singleton, lam_rank_two_zero, lam_rank_two_one]
  by_cases h : g 0 = 0 <;> simp [h]

/-- The exact order of the vertex stabiliser in rank two. -/
lemma autOrder_rank_two (hq : 1 < q) (g : Vertex 2) :
    autOrder q g = if g 0 = 0 then q * (q - 1) * (q ^ 2 - 1)
      else (q - 1) ^ 2 * q ^ (g 0 + 1) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hqne : q ≠ 0 := ne_of_gt hq0
  unfold autOrder
  rw [show (range 2) = {0, 1} from by decide, Finset.prod_insert (by decide),
    Finset.prod_singleton, blockRank_rank_two_zero, blockRank_rank_two_one, endDim_rank_two]
  by_cases h : g 0 = 0
  · rw [if_pos h, if_pos h, if_pos h]
    field_simp
  · rw [if_neg h, if_neg h, if_neg h]
    field_simp
    ring

lemma vertexWeight_rank_two (hq : 1 < q) (g : Vertex 2) :
    vertexWeight q g = if g 0 = 0 then (q * (q - 1) * (q ^ 2 - 1))⁻¹
      else ((q - 1) ^ 2 * q ^ (g 0 + 1))⁻¹ := by
  unfold vertexWeight
  rw [autOrder_rank_two hq]
  split <;> rfl

/-! ### The height zeta function in rank two -/

/-- The positive-moment height zeta function of the quotient (Mellin transform of the
cusp-height distribution). -/
noncomputable def heightZeta (q : ℝ) (d : ℕ) (s : ℝ) : ℝ :=
  ∑' g : Vertex d, vertexWeight q g * height q g ^ s

/-- **Closed rational form of the rank-two height zeta function.**  For `s < 2` the series
converges and equals a rational function of `u = q^{s/2}` whose only pole is at `u = q`,
that is, at `s = d = 2`. -/
theorem heightZeta_rank_two (hq : 1 < q) {s : ℝ} (hs : s < 2) :
    heightZeta q 2 s
      = (q * (q - 1) * (q ^ 2 - 1))⁻¹ + q ^ (s / 2) / ((q - 1) ^ 2 * q * (q - q ^ (s / 2))) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hqne : q ≠ 0 := ne_of_gt hq0
  have hu0 : 0 < q ^ (s / 2) := Real.rpow_pos_of_pos hq0 _
  have huq : q ^ (s / 2) < q := by
    have h1 : s / 2 < 1 := by linarith
    calc q ^ (s / 2) < q ^ (1:ℝ) := (Real.rpow_lt_rpow_left_iff hq).mpr h1
      _ = q := Real.rpow_one q
  have hqu : 0 < q - q ^ (s / 2) := by linarith
  have hterm : ∀ g : Vertex 2, vertexWeight q g * height q g ^ s
      = (if g 0 = 0 then (q * (q - 1) * (q ^ 2 - 1))⁻¹
          else ((q - 1) ^ 2 * q ^ (g 0 + 1))⁻¹) * (q ^ (s / 2)) ^ (g 0) := by
    intro g
    rw [vertexWeight_rank_two hq g, height_pow hq g s, heightExp_rank_two]
    norm_num
  have hsummable : Summable (fun g : Vertex 2 => vertexWeight q g * height q g ^ s) :=
    summable_weight_height_of_lt hq (by norm_num) (by simpa using hs)
  have hreindex : heightZeta q 2 s
      = ∑' n : ℕ, (if n = 0 then (q * (q - 1) * (q ^ 2 - 1))⁻¹
          else ((q - 1) ^ 2 * q ^ (n + 1))⁻¹) * (q ^ (s / 2)) ^ n := by
    unfold heightZeta
    rw [tsum_congr hterm]
    exact ((Equiv.funUnique (Fin 1) ℕ).symm.tsum_eq
      (fun g : Vertex 2 => (if g 0 = 0 then (q * (q - 1) * (q ^ 2 - 1))⁻¹
        else ((q - 1) ^ 2 * q ^ (g 0 + 1))⁻¹) * (q ^ (s / 2)) ^ (g 0))).symm
  have hsummableN : Summable (fun n : ℕ => (if n = 0 then (q * (q - 1) * (q ^ 2 - 1))⁻¹
      else ((q - 1) ^ 2 * q ^ (n + 1))⁻¹) * (q ^ (s / 2)) ^ n) := by
    have hcomp := hsummable.comp_injective
      (i := fun n : ℕ => ((Equiv.funUnique (Fin 1) ℕ).symm n : Vertex 2))
      (Equiv.injective _)
    refine hcomp.congr (fun n => ?_)
    simp only [Function.comp_apply]
    rw [hterm]
    rfl
  rw [hreindex, hsummableN.tsum_eq_zero_add]
  have hzero : (if (0:ℕ) = 0 then (q * (q - 1) * (q ^ 2 - 1))⁻¹
      else ((q - 1) ^ 2 * q ^ ((0:ℕ) + 1))⁻¹) * (q ^ (s / 2)) ^ (0:ℕ)
      = (q * (q - 1) * (q ^ 2 - 1))⁻¹ := by simp
  rw [hzero]
  congr 1
  have htail : ∀ n : ℕ, (if n + 1 = 0 then (q * (q - 1) * (q ^ 2 - 1))⁻¹
      else ((q - 1) ^ 2 * q ^ ((n + 1) + 1))⁻¹) * (q ^ (s / 2)) ^ (n + 1)
      = ((q ^ (s / 2)) * ((q - 1) ^ 2 * q ^ 2)⁻¹) * ((q ^ (s / 2)) / q) ^ n := by
    intro n
    rw [if_neg (by omega), div_pow, pow_succ, pow_add, pow_add]
    field_simp
    ring
  rw [tsum_congr htail]
  have hratio : (0:ℝ) ≤ (q ^ (s / 2)) / q := le_of_lt (div_pos hu0 hq0)
  have hratio1 : (q ^ (s / 2)) / q < 1 := by rw [div_lt_one hq0]; exact huq
  rw [(summable_geometric_of_lt_one hratio hratio1).tsum_mul_left,
    tsum_geometric_of_lt_one hratio hratio1]
  have hne : (1 : ℝ) - (q ^ (s / 2)) / q ≠ 0 := by linarith
  have hq1 : q - 1 ≠ 0 := by
    have : (0:ℝ) < q - 1 := by linarith
    exact ne_of_gt this
  field_simp

/-- **Vertex volume in rank two** (`GL`-normalisation): the total mass of the vertices of the
standard arithmetic quotient is `2/((q-1)^2 (q^2-1))`. -/
theorem vertexMass_rank_two (hq : 1 < q) :
    ∑' g : Vertex 2, vertexWeight q g = 2 / ((q - 1) ^ 2 * (q ^ 2 - 1)) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hqne : q ≠ 0 := ne_of_gt hq0
  have hq1 : q - 1 ≠ 0 := by
    have : (0:ℝ) < q - 1 := by linarith
    exact ne_of_gt this
  have hq2 : q ^ 2 - 1 ≠ 0 := by
    have : (1:ℝ) < q ^ 2 := by nlinarith
    exact ne_of_gt (by linarith)
  have h := heightZeta_rank_two (q := q) hq (s := 0) (by norm_num)
  have hz : heightZeta q 2 0 = ∑' g : Vertex 2, vertexWeight q g := by
    unfold heightZeta
    refine tsum_congr (fun g => ?_)
    rw [Real.rpow_zero, mul_one]
  rw [hz] at h
  rw [h]
  simp only [zero_div, Real.rpow_zero]
  field_simp
  ring

/-- The `PGL`-normalised vertex volume in rank two: `2/((q-1)(q^2-1))`. -/
theorem vertexVolume_rank_two (hq : 1 < q) :
    (q - 1) * ∑' g : Vertex 2, vertexWeight q g = 2 / ((q - 1) * (q ^ 2 - 1)) := by
  have hq1 : q - 1 ≠ 0 := by
    have : (0:ℝ) < q - 1 := by linarith
    exact ne_of_gt this
  have hq2 : q ^ 2 - 1 ≠ 0 := by
    have : (1:ℝ) < q ^ 2 := by nlinarith
    exact ne_of_gt (by linarith)
  rw [vertexMass_rank_two hq]
  field_simp


/-- **The pole at `s = d = 2` is genuine.**  The rank-two height zeta function is unbounded
as `s ↑ 2`: for every `M` there is `s < 2` with `M < Z(s)`.  Together with
`summable_weight_height_iff` this pins the abscissa of convergence at exactly `s = 2`. -/
theorem heightZeta_rank_two_unbounded (hq : 1 < q) (M : ℝ) :
    ∃ s : ℝ, s < 2 ∧ M < heightZeta q 2 s := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  set K : ℝ := (q - 1) ^ 2 * q with hK
  have hKpos : 0 < K := by
    have : (0:ℝ) < q - 1 := by linarith
    positivity
  have hMpos : (0:ℝ) < |M| + 1 := by positivity
  set e : ℝ := min ((q - 1) / 2) (1 / (K * (|M| + 1))) with he
  have hepos : 0 < e := lt_min (by linarith) (by positivity)
  have he1 : e ≤ (q - 1) / 2 := min_le_left _ _
  have he2 : e ≤ 1 / (K * (|M| + 1)) := min_le_right _ _
  have hqe1 : 1 < q - e := by linarith
  have hqe0 : 0 < q - e := by linarith
  refine ⟨2 * Real.logb q (q - e), ?_, ?_⟩
  · have : Real.logb q (q - e) < Real.logb q q :=
      Real.logb_lt_logb hq hqe0 (by linarith)
    rw [Real.logb_self_eq_one hq] at this
    linarith
  · have hs2 : (2 * Real.logb q (q - e)) / 2 = Real.logb q (q - e) := by ring
    have hu : q ^ ((2 * Real.logb q (q - e)) / 2) = q - e := by
      rw [hs2]
      exact Real.rpow_logb hq0 (ne_of_gt hq) hqe0
    have hlt : 2 * Real.logb q (q - e) < 2 := by
      have : Real.logb q (q - e) < Real.logb q q :=
        Real.logb_lt_logb hq hqe0 (by linarith)
      rw [Real.logb_self_eq_one hq] at this
      linarith
    rw [heightZeta_rank_two hq hlt, hu, show q - (q - e) = e from by ring]
    have hApos : 0 < (q * (q - 1) * (q ^ 2 - 1))⁻¹ := by
      have h1 : (0:ℝ) < q - 1 := by linarith
      have h2 : (0:ℝ) < q ^ 2 - 1 := by nlinarith
      positivity
    have hKe : 0 < K * e := by positivity
    have hbound : M < (q - e) / (K * e) := by
      rw [lt_div_iff₀ hKe]
      have habs : M ≤ |M| := le_abs_self M
      have hprod : (K * e) * (|M| + 1) ≤ 1 := by
        rw [← le_div_iff₀ hMpos]
        calc K * e ≤ K * (1 / (K * (|M| + 1))) := by nlinarith
          _ = 1 / (|M| + 1) := by field_simp
      nlinarith
    have hrewrite : (q - e) / ((q - 1) ^ 2 * q * e) = (q - e) / (K * e) := by
      rw [hK]
    rw [hrewrite]
    linarith

end PGLQuotient