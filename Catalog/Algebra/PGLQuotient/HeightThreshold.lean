import Algebra.PGLQuotient.VertexModel

/-!
# Integrability threshold for the lattice-minima height

Let `α` be the homothety-invariant normalised lattice-minima height on the standard
arithmetic quotient of the Bruhat–Tits building of `PGL_d(F_q((t^{-1})))`, modelled as in
`Algebra.PGLQuotient.VertexModel`.

The main theorem of this file is the *exact integrability threshold*

`Summable (fun g => vertexWeight q g * α g ^ s) ↔ s < d`,

i.e. `α ∈ L^r` precisely for `r < d` (in particular for `0 < r < d`).  The positive direction
is proved by factoring the majorant into a product of `d-1` independent geometric series over
the gap coordinates; the negative direction uses the cusp ray `λ = (n,0,…,0)`, along which the
mass decays exactly like `α^{-d}`.
-/

namespace PGLQuotient

open Finset

section PiGeom

/-- A product of independent geometric series over the lattice `Fin m → ℕ`. -/
lemma summable_pi_geom : ∀ {m : ℕ} (x : Fin m → ℝ), (∀ k, 0 ≤ x k) → (∀ k, x k < 1) →
    Summable (fun h : Fin m → ℕ => ∏ k, x k ^ h k) ∧
      ∑' h : Fin m → ℕ, ∏ k, x k ^ h k = ∏ k, (1 - x k)⁻¹ := by
  intro m
  induction m with
  | zero =>
      intro x _ _
      refine ⟨Summable.of_finite, ?_⟩
      simp
  | succ m ih =>
      intro x h0 h1
      obtain ⟨hs2, hv2⟩ := ih (fun k => x k.succ) (fun k => h0 _) (fun k => h1 _)
      have hsum1 : Summable (fun n : ℕ => x 0 ^ n) :=
        summable_geometric_of_lt_one (h0 0) (h1 0)
      have hnn1 : (0 : ℕ → ℝ) ≤ fun n : ℕ => x 0 ^ n := fun n => pow_nonneg (h0 0) n
      have hnn2 : (0 : (Fin m → ℕ) → ℝ) ≤ fun h : Fin m → ℕ => ∏ k : Fin m, x k.succ ^ h k :=
        fun h => Finset.prod_nonneg (fun k _ => pow_nonneg (h0 _) _)
      have hprod := hsum1.mul_of_nonneg hs2 hnn1 hnn2
      have key : ∀ p : ℕ × (Fin m → ℕ),
          (∏ k : Fin (m+1), x k ^ ((Fin.consEquiv (fun _ => ℕ)) p) k)
            = x 0 ^ p.1 * ∏ k : Fin m, x k.succ ^ p.2 k := by
        intro p
        rw [Fin.prod_univ_succ]
        simp [Fin.consEquiv_apply]
      have hcomp : Summable (fun p : ℕ × (Fin m → ℕ) =>
          ∏ k : Fin (m+1), x k ^ ((Fin.consEquiv (fun _ => ℕ)) p) k) := by
        simpa only [key] using hprod
      have hsummable : Summable (fun h : Fin (m+1) → ℕ => ∏ k, x k ^ h k) :=
        (Equiv.summable_iff (Fin.consEquiv (fun _ => ℕ))).mp hcomp
      refine ⟨hsummable, ?_⟩
      have hval : ∑' h : Fin (m+1) → ℕ, ∏ k, x k ^ h k
          = ∑' p : ℕ × (Fin m → ℕ), x 0 ^ p.1 * ∏ k : Fin m, x k.succ ^ p.2 k := by
        rw [← (Fin.consEquiv (fun _ => ℕ)).tsum_eq (fun h : Fin (m+1) → ℕ => ∏ k, x k ^ h k)]
        exact tsum_congr key
      have hslice : ∀ b : ℕ, Summable
          (fun c : Fin m → ℕ => x 0 ^ b * ∏ k : Fin m, x k.succ ^ c k) := fun b => hs2.mul_left _
      rw [hval, hprod.tsum_prod' hslice]
      rw [tsum_congr (fun n : ℕ => hs2.tsum_mul_left (x 0 ^ n)), tsum_mul_right, hv2,
        tsum_geometric_of_lt_one (h0 0) (h1 0), Fin.prod_univ_succ]

end PiGeom

section Threshold

variable {d : ℕ} {q : ℝ}

lemma gapAt_coe (g : Vertex d) (k : Fin (d - 1)) : gapAt g (k : ℕ) = g k := by
  simp [gapAt, k.isLt]

/-- The base of the geometric series in the `k`-th gap direction, for the `s`-th moment. -/
noncomputable def gapRatio (q : ℝ) (d : ℕ) (s : ℝ) (k : Fin (d - 1)) : ℝ :=
  (q ^ (((k : ℕ) + 1) * (d - 1 - (k : ℕ))))⁻¹ * (q ^ (s / d)) ^ (d - 1 - (k : ℕ))

lemma height_pow (hq : 1 < q) (g : Vertex d) (s : ℝ) :
    height q g ^ s = (q ^ (s / d)) ^ heightExp g := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  unfold height
  rw [← Real.rpow_natCast (q ^ (s / d)) (heightExp g), ← Real.rpow_mul hq0.le,
    ← Real.rpow_mul hq0.le]
  congr 1
  ring

lemma prod_gapRatio (s : ℝ) (g : Vertex d) :
    ∏ k, gapRatio q d s k ^ g k = (q ^ pairExp g)⁻¹ * (q ^ (s / d)) ^ heightExp g := by
  have hterm : ∀ k : Fin (d - 1), gapRatio q d s k ^ g k
      = (q⁻¹) ^ ((((k : ℕ) + 1) * (d - 1 - (k : ℕ))) * g k)
        * (q ^ (s / d)) ^ ((d - 1 - (k : ℕ)) * g k) := by
    intro k
    unfold gapRatio
    rw [mul_pow, ← inv_pow, ← pow_mul, ← pow_mul]
  rw [Finset.prod_congr rfl (fun k _ => hterm k), Finset.prod_mul_distrib,
    Finset.prod_pow_eq_pow_sum, Finset.prod_pow_eq_pow_sum, ← inv_pow]
  congr 2
  · rw [pairExp, ← Fin.sum_univ_eq_sum_range (fun k => (k + 1) * (d - 1 - k) * gapAt g k)]
    exact Finset.sum_congr rfl (fun k _ => by rw [gapAt_coe, mul_assoc])
  · rw [heightExp, ← Fin.sum_univ_eq_sum_range (fun k => (d - 1 - k) * gapAt g k)]
    exact Finset.sum_congr rfl (fun k _ => by rw [gapAt_coe])

lemma gapRatio_nonneg (hq : 1 < q) (s : ℝ) (k : Fin (d - 1)) : 0 ≤ gapRatio q d s k := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  unfold gapRatio
  positivity

lemma gapRatio_lt_one (hq : 1 < q) (hd : 2 ≤ d) {s : ℝ} (hs : s < d) (k : Fin (d - 1)) :
    gapRatio q d s k < 1 := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hd0 : (0:ℝ) < (d : ℝ) := by
    have : 0 < d := by omega
    exact_mod_cast this
  have hcq : q ^ (s / d) < q := by
    have h1 : s / d < 1 := by rw [div_lt_one hd0]; exact hs
    calc q ^ (s / d) < q ^ (1:ℝ) := by
          exact (Real.rpow_lt_rpow_left_iff hq).mpr h1
      _ = q := Real.rpow_one q
  have hcpos : (0:ℝ) < q ^ (s / d) := Real.rpow_pos_of_pos hq0 _
  set m : ℕ := d - 1 - (k : ℕ) with hm
  have hm1 : 1 ≤ m := by have := k.isLt; omega
  have h1 : (q ^ (s / d)) ^ m < q ^ m :=
    pow_lt_pow_left₀ hcq (le_of_lt hcpos) (by omega)
  have h2 : q ^ m ≤ q ^ (((k : ℕ) + 1) * m) :=
    pow_le_pow_right₀ hq.le (by nlinarith [Nat.le_mul_of_pos_left m (Nat.succ_pos (k : ℕ))])
  unfold gapRatio
  rw [← hm, inv_mul_lt_one₀ (pow_pos hq0 _)]
  calc (q ^ (s / d)) ^ m < q ^ m := h1
    _ ≤ q ^ (((k : ℕ) + 1) * m) := h2

/-- Positive direction of the integrability threshold. -/
theorem summable_weight_height_of_lt (hq : 1 < q) (hd : 2 ≤ d) {s : ℝ} (hs : s < d) :
    Summable (fun g : Vertex d => vertexWeight q g * height q g ^ s) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  obtain ⟨hsum, -⟩ := summable_pi_geom (gapRatio q d s)
    (gapRatio_nonneg hq s) (gapRatio_lt_one hq hd hs)
  refine Summable.of_nonneg_of_le (fun g => ?_) (fun g => ?_)
    (hsum.mul_left (((1 - q⁻¹) ^ d)⁻¹))
  · exact mul_nonneg (le_of_lt (vertexWeight_pos g hq))
      (le_of_lt (Real.rpow_pos_of_pos (Real.rpow_pos_of_pos hq0 _) s))
  · rw [height_pow hq g s, prod_gapRatio s g, ← mul_assoc]
    exact mul_le_mul_of_nonneg_right (vertexWeight_le g hq)
      (pow_nonneg (le_of_lt (Real.rpow_pos_of_pos hq0 _)) _)

/-- The cusp ray `λ = (n, 0, …, 0)`. -/
def rayVertex (d : ℕ) (n : ℕ) : Vertex d := fun k => if (k : ℕ) = 0 then n else 0

lemma gapAt_ray (hd : 2 ≤ d) (n k : ℕ) :
    gapAt (rayVertex d n) k = if k = 0 then n else 0 := by
  unfold gapAt rayVertex
  by_cases hk : k < d - 1
  · rw [dif_pos hk]
  · rw [dif_neg hk]
    have hk0 : k ≠ 0 := by omega
    simp [hk0]

lemma heightExp_ray (hd : 2 ≤ d) (n : ℕ) : heightExp (rayVertex d n) = (d - 1) * n := by
  unfold heightExp
  rw [Finset.sum_eq_single 0]
  · rw [gapAt_ray hd]
    simp
  · intro k _ hk
    rw [gapAt_ray hd]
    simp [hk]
  · intro h
    exact absurd (Finset.mem_range.mpr (by omega)) h

lemma pairExp_ray (hd : 2 ≤ d) (n : ℕ) : pairExp (rayVertex d n) = (d - 1) * n := by
  unfold pairExp
  rw [Finset.sum_eq_single 0]
  · rw [gapAt_ray hd]
    simp
  · intro k _ hk
    rw [gapAt_ray hd]
    simp [hk]
  · intro h
    exact absurd (Finset.mem_range.mpr (by omega)) h

lemma rayVertex_injective (hd : 2 ≤ d) : Function.Injective (rayVertex d) := by
  intro m n hmn
  have h0 : (0 : ℕ) < d - 1 := by omega
  have := congrFun hmn ⟨0, h0⟩
  simpa [rayVertex] using this

/-- Negative direction of the integrability threshold. -/
theorem not_summable_weight_height_of_ge (hq : 1 < q) (hd : 2 ≤ d) {s : ℝ} (hs : (d : ℝ) ≤ s) :
    ¬ Summable (fun g : Vertex d => vertexWeight q g * height q g ^ s) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hd0 : (0:ℝ) < (d : ℝ) := by
    have : 0 < d := by omega
    exact_mod_cast this
  intro hsum
  have hcomp : Summable (fun n : ℕ => vertexWeight q (rayVertex d n)
      * height q (rayVertex d n) ^ s) := hsum.comp_injective (rayVertex_injective hd)
  -- every term along the ray is at least `q^{-d^2}`
  have hcq : q ≤ q ^ (s / d) := by
    have h1 : (1:ℝ) ≤ s / d := by rw [le_div_iff₀ hd0]; linarith
    calc q = q ^ (1:ℝ) := (Real.rpow_one q).symm
      _ ≤ q ^ (s / d) := by
          exact Real.rpow_le_rpow_left_iff hq |>.mpr h1
  have hlow : ∀ n : ℕ, (q ^ (d * d))⁻¹
      ≤ vertexWeight q (rayVertex d n) * height q (rayVertex d n) ^ s := by
    intro n
    have hw := vertexWeight_ge (rayVertex d n) hq
    rw [height_pow hq _ s, heightExp_ray hd, pairExp_ray hd] at *
    have hpow : q ^ ((d - 1) * n) ≤ (q ^ (s / d)) ^ ((d - 1) * n) :=
      pow_le_pow_left₀ (le_of_lt hq0) hcq _
    calc (q ^ (d * d))⁻¹
        = (q ^ (d * d))⁻¹ * ((q ^ ((d - 1) * n))⁻¹ * q ^ ((d - 1) * n)) := by
          rw [inv_mul_cancel₀ (ne_of_gt (pow_pos hq0 _)), mul_one]
      _ ≤ (q ^ (d * d))⁻¹ * ((q ^ ((d - 1) * n))⁻¹ * (q ^ (s / d)) ^ ((d - 1) * n)) := by
          refine mul_le_mul_of_nonneg_left ?_ (by positivity)
          exact mul_le_mul_of_nonneg_left hpow (by positivity)
      _ = ((q ^ (d * d))⁻¹ * (q ^ ((d - 1) * n))⁻¹) * (q ^ (s / d)) ^ ((d - 1) * n) := by ring
      _ ≤ vertexWeight q (rayVertex d n) * (q ^ (s / d)) ^ ((d - 1) * n) := by
          refine mul_le_mul_of_nonneg_right hw ?_
          positivity
  have htend := hcomp.tendsto_atTop_zero
  have hpos : (0:ℝ) < (q ^ (d * d))⁻¹ := by positivity
  obtain ⟨N, hN⟩ := Metric.tendsto_atTop.mp htend ((q ^ (d * d))⁻¹) hpos
  have h1 := hN N le_rfl
  rw [Real.dist_eq, sub_zero] at h1
  have h2 := hlow N
  have h3 : |vertexWeight q (rayVertex d N) * height q (rayVertex d N) ^ s|
      = vertexWeight q (rayVertex d N) * height q (rayVertex d N) ^ s := by
    refine abs_of_nonneg (mul_nonneg (le_of_lt (vertexWeight_pos _ hq)) ?_)
    exact le_of_lt (Real.rpow_pos_of_pos (Real.rpow_pos_of_pos hq0 _) s)
  rw [h3] at h1
  linarith

/-- **Exact integrability threshold.**  The normalised lattice-minima height `α` has a finite
`s`-th moment on the standard arithmetic quotient of `PGL_d` precisely when `s < d`. -/
theorem summable_weight_height_iff (hq : 1 < q) (hd : 2 ≤ d) (s : ℝ) :
    Summable (fun g : Vertex d => vertexWeight q g * height q g ^ s) ↔ s < d := by
  constructor
  · intro hsum
    by_contra hcon
    exact not_summable_weight_height_of_ge hq hd (not_lt.mp hcon) hsum
  · exact summable_weight_height_of_lt hq hd

end Threshold

end PGLQuotient