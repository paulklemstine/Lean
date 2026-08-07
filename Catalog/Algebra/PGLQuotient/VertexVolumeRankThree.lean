import Algebra.PGLQuotient.CuspTail

/-!
# Rank three: the exact vertex volume in closed product form

We evaluate, with no sorries, the total vertex mass of the standard arithmetic quotient
of the affine Bruhat–Tits building of `PGL_3(F_q((t^{-1})))`:

`∑_λ 1/|Aut λ| = 3 / ((q-1)^2 (q^2-1)^2 (q^3-1)) = 3 / (P(3) P(2))`,

where `P(m) = ∏_{k=1}^m (q^k - 1)`.  Equivalently the `PGL`-normalised vertex volume is
`(q-1) ∑_λ 1/|Aut λ| = 3/((q-1)(q^2-1)^2(q^3-1))`.

This is the `d = 3` instance of the conjectured closed product form
`d (q-1) / (P(d) P(d-1))` (see `FUTURE_DIRECTIONS.md`); the `d = 2` instance is
`vertexVolume_rank_two`.

The proof is the building-theoretic one: vertices are parametrised by the dominant sector
(here `ℕ^2` in gap coordinates), the stabiliser orders are computed *exactly* in the four
strata `g = (0,0)`, `(0,b)`, `(a,0)`, `(a,b)` cut out by the vanishing of the gaps, and the
resulting sum over the strata (the `d = 3` "cut-set" decomposition) is summed as a double
geometric series.
-/

namespace PGLQuotient

open Finset

variable {q : ℝ}

/-! ### A geometric summation helper -/

/-- A series which is arbitrary at `n = 0` and geometric afterwards is summable. -/
lemma summable_ite_geom {c₀ c r : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) :
    Summable (fun n : ℕ => if n = 0 then c₀ else c * r ^ (n - 1)) := by
  have hbase : Summable (fun n : ℕ => c * r ^ n) :=
    (summable_geometric_of_lt_one hr0 hr1).mul_left c
  have h2 : (fun n : ℕ => (fun m : ℕ => if m = 0 then c₀ else c * r ^ (m - 1)) (n + 1))
      = fun n : ℕ => c * r ^ n := by
    funext n; simp
  exact (summable_nat_add_iff 1).mp (by rw [h2]; exact hbase)

/-- Summation of a series which is arbitrary at `n = 0` and geometric afterwards. -/
lemma tsum_ite_geom {c₀ c r : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) :
    ∑' n : ℕ, (if n = 0 then c₀ else c * r ^ (n - 1)) = c₀ + c * (1 - r)⁻¹ := by
  rw [(summable_ite_geom hr0 hr1).tsum_eq_zero_add]
  congr 1
  have hstep : ∀ n : ℕ, (if n + 1 = 0 then c₀ else c * r ^ (n + 1 - 1)) = c * r ^ n := by
    intro n; simp
  rw [tsum_congr hstep, (summable_geometric_of_lt_one hr0 hr1).tsum_mul_left,
    tsum_geometric_of_lt_one hr0 hr1]

/-! ### Explicit rank-three data -/

lemma lam_rank_three_zero (g : Vertex 3) : lam g 0 = g 0 + g 1 := by
  have h : Finset.Ico 0 (3 - 1) = ({0, 1} : Finset ℕ) := by decide
  simp [lam, h, gapAt]

lemma lam_rank_three_one (g : Vertex 3) : lam g 1 = g 1 := by
  have h : Finset.Ico 1 (3 - 1) = ({1} : Finset ℕ) := by decide
  simp [lam, h, gapAt]

lemma lam_rank_three_two (g : Vertex 3) : lam g 2 = 0 := by
  simp [lam]

/-- `dim End(⨁ O(λ_i))` for `d = 3`, in the four strata. -/
lemma endDim_rank_three (g : Vertex 3) :
    endDim g = if g 0 = 0 then (if g 1 = 0 then 9 else 2 * g 1 + 7)
      else (if g 1 = 0 then 2 * g 0 + 7 else 2 * g 0 + 2 * g 1 + 6) := by
  simp only [endDim, Finset.sum_range_succ, Finset.sum_range_zero, zero_add,
    lam_rank_three_zero, lam_rank_three_one, lam_rank_three_two]
  split_ifs <;> omega

lemma blockRank_rank_three_zero (g : Vertex 3) : blockRank g 0 = 1 := by
  simp [blockRank, Finset.filter_singleton]

lemma blockRank_rank_three_one (g : Vertex 3) :
    blockRank g 1 = if g 0 = 0 then 2 else 1 := by
  have hr : range (1 + 1) = ({0, 1} : Finset ℕ) := by decide
  unfold blockRank
  rw [hr, Finset.filter_insert, Finset.filter_singleton, lam_rank_three_zero,
    lam_rank_three_one]
  by_cases h : g 0 = 0 <;> simp [h]

lemma blockRank_rank_three_two (g : Vertex 3) :
    blockRank g 2 = if g 1 = 0 then (if g 0 = 0 then 3 else 2) else 1 := by
  have hr : range (2 + 1) = ({0, 1, 2} : Finset ℕ) := by decide
  unfold blockRank
  rw [hr, Finset.filter_insert, Finset.filter_insert, Finset.filter_singleton,
    lam_rank_three_zero, lam_rank_three_one, lam_rank_three_two]
  by_cases h0 : g 0 = 0 <;> by_cases h1 : g 1 = 0 <;>
    simp [h0, h1]

/-- **The exact stabiliser order in rank three**, in the four strata of the dominant sector. -/
lemma autOrder_rank_three (hq : 1 < q) (g : Vertex 3) :
    autOrder q g =
      if g 0 = 0 then
        (if g 1 = 0 then q ^ 3 * (q - 1) * (q ^ 2 - 1) * (q ^ 3 - 1)
         else q ^ (2 * g 1 + 3) * (q - 1) ^ 2 * (q ^ 2 - 1))
      else
        (if g 1 = 0 then q ^ (2 * g 0 + 3) * (q - 1) ^ 2 * (q ^ 2 - 1)
         else q ^ (2 * g 0 + 2 * g 1 + 3) * (q - 1) ^ 3) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hqne : q ≠ 0 := ne_of_gt hq0
  unfold autOrder
  rw [show (range 3) = {0, 1, 2} from by decide, Finset.prod_insert (by decide),
    Finset.prod_insert (by decide), Finset.prod_singleton, blockRank_rank_three_zero,
    blockRank_rank_three_one, blockRank_rank_three_two, endDim_rank_three]
  by_cases h0 : g 0 = 0 <;> by_cases h1 : g 1 = 0
  · simp only [if_pos h0, if_pos h1]
    field_simp
  · simp only [if_pos h0, if_neg h1]
    rw [show 2 * g 1 + 7 = (2 * g 1 + 3) + 4 from by ring, pow_add]
    field_simp
  · simp only [if_pos h1, if_neg h0]
    rw [show 2 * g 0 + 7 = (2 * g 0 + 3) + 4 from by ring, pow_add]
    field_simp
  · simp only [if_neg h0, if_neg h1]
    rw [show 2 * g 0 + 2 * g 1 + 6 = (2 * g 0 + 2 * g 1 + 3) + 3 from by ring, pow_add]
    field_simp

/-- The vertex mass in rank three, in the four strata. -/
noncomputable def rk3Weight (q : ℝ) (a b : ℕ) : ℝ :=
  if a = 0 then
    (if b = 0 then (q ^ 3 * (q - 1) * (q ^ 2 - 1) * (q ^ 3 - 1))⁻¹
     else (q ^ (2 * b + 3) * (q - 1) ^ 2 * (q ^ 2 - 1))⁻¹)
  else
    (if b = 0 then (q ^ (2 * a + 3) * (q - 1) ^ 2 * (q ^ 2 - 1))⁻¹
     else (q ^ (2 * a + 2 * b + 3) * (q - 1) ^ 3)⁻¹)

lemma vertexWeight_rank_three (hq : 1 < q) (g : Vertex 3) :
    vertexWeight q g = rk3Weight q (g 0) (g 1) := by
  unfold vertexWeight rk3Weight
  rw [autOrder_rank_three hq]
  split_ifs <;> rfl

/-! ### Summing over the dominant sector -/

lemma rk3Weight_zero_row (b : ℕ) :
    rk3Weight q 0 b =
      if b = 0 then (q ^ 3 * (q - 1) * (q ^ 2 - 1) * (q ^ 3 - 1))⁻¹
      else (q ^ 5 * (q - 1) ^ 2 * (q ^ 2 - 1))⁻¹ * ((q ^ 2)⁻¹) ^ (b - 1) := by
  unfold rk3Weight
  rw [if_pos rfl]
  cases b with
  | zero => simp
  | succ b =>
    rw [if_neg (by omega), if_neg (by omega)]
    rw [show 2 * (b + 1) + 3 = 5 + 2 * b from by ring, pow_add, pow_mul, inv_pow, ← mul_inv]
    congr 1
    simp only [Nat.add_sub_cancel]
    ring

lemma rk3Weight_succ_row (a b : ℕ) :
    rk3Weight q (a + 1) b =
      if b = 0 then (q ^ 5 * (q - 1) ^ 2 * (q ^ 2 - 1))⁻¹ * ((q ^ 2)⁻¹) ^ a
      else ((q ^ 7 * (q - 1) ^ 3)⁻¹ * ((q ^ 2)⁻¹) ^ a) * ((q ^ 2)⁻¹) ^ (b - 1) := by
  unfold rk3Weight
  rw [if_neg (by omega)]
  cases b with
  | zero =>
    rw [if_pos rfl, if_pos rfl]
    rw [show 2 * (a + 1) + 3 = 5 + 2 * a from by ring, pow_add, pow_mul, inv_pow, ← mul_inv]
    congr 1
    ring
  | succ b =>
    rw [if_neg (by omega), if_neg (by omega)]
    rw [show 2 * (a + 1) + 2 * (b + 1) + 3 = 7 + 2 * a + 2 * b from by ring,
      pow_add, pow_add, pow_mul, pow_mul, inv_pow, inv_pow, ← mul_inv, ← mul_inv]
    congr 1
    simp only [Nat.add_sub_cancel]
    ring

/-- **Vertex volume in rank three** (`GL`-normalisation): the total mass of the vertices of
the standard arithmetic quotient of `PGL_3` is `3/((q-1)^2 (q^2-1)^2 (q^3-1)) = 3/(P(3)P(2))`. -/
theorem vertexMass_rank_three (hq : 1 < q) :
    ∑' g : Vertex 3, vertexWeight q g
      = 3 / ((q - 1) ^ 2 * (q ^ 2 - 1) ^ 2 * (q ^ 3 - 1)) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hqne : q ≠ 0 := ne_of_gt hq0
  have hq1 : (0:ℝ) < q - 1 := by linarith
  have hq1' : q - 1 ≠ 0 := ne_of_gt hq1
  have hq2 : (1:ℝ) < q ^ 2 := by nlinarith
  have hq2' : q ^ 2 - 1 ≠ 0 := by linarith
  have hq3 : (1:ℝ) < q ^ 3 := by nlinarith
  have hq3' : q ^ 3 - 1 ≠ 0 := by linarith
  set r : ℝ := (q ^ 2)⁻¹ with hr
  have hr0 : 0 ≤ r := by positivity
  have hr1 : r < 1 := by
    rw [hr, inv_lt_one_iff₀]
    right; exact hq2
  have hrne : (1 : ℝ) - r ≠ 0 := by linarith
  -- transport the sum to `ℕ × ℕ`
  set e : ℕ × ℕ ≃ Vertex 3 := (finTwoArrowEquiv ℕ).symm with he
  have hev : ∀ p : ℕ × ℕ, vertexWeight q (e p) = rk3Weight q p.1 p.2 := by
    intro p
    rw [vertexWeight_rank_three hq]
    simp [he, finTwoArrowEquiv]
  have hsumV : Summable (fun g : Vertex 3 => vertexWeight q g) :=
    summable_vertexWeight hq (by norm_num)
  have hsumP : Summable (fun p : ℕ × ℕ => rk3Weight q p.1 p.2) := by
    have h := hsumV.comp_injective e.injective
    exact h.congr hev
  have hstep1 : ∑' g : Vertex 3, vertexWeight q g = ∑' p : ℕ × ℕ, rk3Weight q p.1 p.2 := by
    rw [← e.tsum_eq (fun g : Vertex 3 => vertexWeight q g)]
    exact tsum_congr hev
  -- the inner sums
  set A : ℝ := (q ^ 3 * (q - 1) * (q ^ 2 - 1) * (q ^ 3 - 1))⁻¹ with hA
  set B : ℝ := (q ^ 5 * (q - 1) ^ 2 * (q ^ 2 - 1))⁻¹ with hB
  set D : ℝ := (q ^ 7 * (q - 1) ^ 3)⁻¹ with hD
  have hinner : ∀ a : ℕ, ∑' b : ℕ, rk3Weight q a b
      = if a = 0 then A + B * (1 - r)⁻¹ else (B + D * (1 - r)⁻¹) * r ^ (a - 1) := by
    intro a
    cases a with
    | zero =>
      rw [if_pos rfl, tsum_congr (rk3Weight_zero_row)]
      exact tsum_ite_geom hr0 hr1
    | succ a =>
      rw [if_neg (by omega), tsum_congr (rk3Weight_succ_row a),
        tsum_ite_geom hr0 hr1]
      simp only [Nat.add_sub_cancel]
      ring
  have hstep2 : ∑' p : ℕ × ℕ, rk3Weight q p.1 p.2
      = A + B * (1 - r)⁻¹ + (B + D * (1 - r)⁻¹) * (1 - r)⁻¹ := by
    rw [hsumP.tsum_prod, tsum_congr hinner]
    exact tsum_ite_geom hr0 hr1
  rw [hstep1, hstep2, hA, hB, hD, hr]
  have hinv : ((1 : ℝ) - (q ^ 2)⁻¹)⁻¹ = q ^ 2 / (q ^ 2 - 1) := by
    rw [eq_div_iff hq2']
    field_simp
  rw [hinv]
  field_simp
  ring

/-- The `PGL`-normalised vertex volume in rank three: `3/((q-1)(q^2-1)^2(q^3-1))`. -/
theorem vertexVolume_rank_three (hq : 1 < q) :
    (q - 1) * ∑' g : Vertex 3, vertexWeight q g
      = 3 / ((q - 1) * (q ^ 2 - 1) ^ 2 * (q ^ 3 - 1)) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hq1 : (0:ℝ) < q - 1 := by linarith
  have hq1' : q - 1 ≠ 0 := ne_of_gt hq1
  have hq2 : (1:ℝ) < q ^ 2 := by nlinarith
  have hq2' : q ^ 2 - 1 ≠ 0 := by linarith
  have hq3 : (1:ℝ) < q ^ 3 := by nlinarith
  have hq3' : q ^ 3 - 1 ≠ 0 := by linarith
  rw [vertexMass_rank_three hq]
  field_simp

end PGLQuotient