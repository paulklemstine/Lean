import Algebra.PGLQuotient.VertexVolumeGeneral
import Algebra.PGLQuotient.HeightZetaRankTwo

/-!
# The height zeta function in arbitrary rank: rationality and the pole at `s = d`

`Algebra.PGLQuotient.HeightZetaRankTwo` computes the positive-moment height zeta function

`Z_d(s) = ∑_λ α(λ)^s / |Aut λ|`

of the standard arithmetic quotient of `PGL_d(F_q((t^{-1})))` in closed form for `d = 2`,
exhibiting it as a rational function of `u = q^{s/2}` with a single pole at `u = q`.
This file establishes the corresponding statement in **arbitrary rank `d ≥ 1`**.

The mechanism is the same row-peeling recursion that produced the vertex volume in
`Algebra.PGLQuotient.VertexVolumeGeneral`, run on a *height-weighted* twisted mass

`twZ q c j w λ = w ^ heightExp λ · twWeight q c j λ`.

Since `heightExp (cons a λ') = (n+1)·a + heightExp λ'`, the extra factor is compatible with
peeling: it only changes the ratio of the geometric series in the top gap from
`q^{-(n+1)(c+1)}` to `w^{n+1} q^{-(n+1)(c+1)}`.  Hence:

* `twZMass_succ` — the row-peeling recursion for the height-weighted twisted mass;
* `twZ_rational` — for every rank and every pair of twisting parameters the sum is a rational
  function of `w` on the whole interval `0 ≤ w < q`, with a denominator that does not vanish
  there;
* `heightZeta_rational_general` — **the height zeta function of the rank-`d` quotient is a
  rational function of `u = q^{s/d}`**, uniformly for `s < d`;
* `heightZeta_unbounded_general` — **the pole at `s = d` is genuine in every rank**:
  `Z_d(s) → ∞` as `s ↑ d`.  Combined with `summable_weight_height_iff` this pins the abscissa
  of convergence at exactly `s = d`.

The threshold `w < q` is exactly `s < d` under `w = q^{s/d}`, so the domain of rationality is
precisely the half-plane of convergence.
-/

namespace PGLQuotient

open Finset

variable {q : ℝ}

/-- The height-weighted twisted vertex mass: `w^{heightExp λ} · twWeight q c j λ`. -/
noncomputable def twZ {d : ℕ} (q : ℝ) (c j : ℕ) (w : ℝ) (g : Vertex d) : ℝ :=
  w ^ heightExp g * twWeight q c j g

section Summability

/-- The base of the geometric series in the `k`-th gap direction, with height weight `w`. -/
noncomputable def gapRatioW (q : ℝ) (d : ℕ) (w : ℝ) (k : Fin (d - 1)) : ℝ :=
  (q ^ (((k : ℕ) + 1) * (d - 1 - (k : ℕ))))⁻¹ * w ^ (d - 1 - (k : ℕ))

variable {d : ℕ}

lemma prod_gapRatioW (w : ℝ) (g : Vertex d) :
    ∏ k, gapRatioW q d w k ^ g k = (q ^ pairExp g)⁻¹ * w ^ heightExp g := by
  have hterm : ∀ k : Fin (d - 1), gapRatioW q d w k ^ g k
      = (q⁻¹) ^ ((((k : ℕ) + 1) * (d - 1 - (k : ℕ))) * g k)
        * w ^ ((d - 1 - (k : ℕ)) * g k) := by
    intro k
    unfold gapRatioW
    rw [mul_pow, ← inv_pow, ← pow_mul, ← pow_mul]
  rw [Finset.prod_congr rfl (fun k _ => hterm k), Finset.prod_mul_distrib,
    Finset.prod_pow_eq_pow_sum, Finset.prod_pow_eq_pow_sum, ← inv_pow]
  congr 2
  · rw [pairExp, ← Fin.sum_univ_eq_sum_range (fun k => (k + 1) * (d - 1 - k) * gapAt g k)]
    exact Finset.sum_congr rfl (fun k _ => by rw [gapAt_coe, mul_assoc])
  · rw [heightExp, ← Fin.sum_univ_eq_sum_range (fun k => (d - 1 - k) * gapAt g k)]
    exact Finset.sum_congr rfl (fun k _ => by rw [gapAt_coe])

lemma gapRatioW_nonneg (hq : 1 < q) {w : ℝ} (hw : 0 ≤ w) (k : Fin (d - 1)) :
    0 ≤ gapRatioW q d w k := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  unfold gapRatioW
  positivity

lemma gapRatioW_lt_one (hq : 1 < q) {w : ℝ} (hw : 0 ≤ w) (hwq : w < q) (k : Fin (d - 1)) :
    gapRatioW q d w k < 1 := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  set m : ℕ := d - 1 - (k : ℕ) with hm
  have hm1 : 1 ≤ m := by have := k.isLt; omega
  have h1 : w ^ m < q ^ m := pow_lt_pow_left₀ hwq hw (by omega)
  have h2 : q ^ m ≤ q ^ (((k : ℕ) + 1) * m) :=
    pow_le_pow_right₀ hq.le (Nat.le_mul_of_pos_left m (Nat.succ_pos (k : ℕ)))
  unfold gapRatioW
  rw [← hm, inv_mul_lt_one₀ (pow_pos hq0 _)]
  exact lt_of_lt_of_le h1 h2

end Summability

section Recursion

/-- The height weight is compatible with peeling the top row. -/
lemma heightExp_cons {n : ℕ} (a : ℕ) (g : Vertex (n + 1)) :
    heightExp (consV a g) = (n + 1) * a + heightExp g := by
  show ∑ k ∈ range (n + 1), (n + 1 - k) * gapAt (consV a g) k
      = (n + 1) * a + ∑ k ∈ range n, (n - k) * gapAt g k
  rw [Finset.sum_range_succ' (fun k => (n + 1 - k) * gapAt (consV a g) k) n,
    gapAt_consV_zero, Nat.sub_zero, Nat.add_comm]
  congr 1
  refine Finset.sum_congr rfl (fun k _ => ?_)
  rw [gapAt_consV_succ]
  congr 1
  omega

variable {w : ℝ}

lemma twZ_cons_zero {n : ℕ} (hq : 1 < q) (c j : ℕ) (g : Vertex (n + 1)) :
    twZ q c j w (consV 0 g)
      = (q ^ (n + 2 + j) * (1 - q⁻¹ ^ (1 + j)))⁻¹ * twZ q (c + 1) (j + 1) w g := by
  unfold twZ
  rw [heightExp_cons, twWeight_cons_zero hq, Nat.mul_zero, Nat.zero_add]
  ring

lemma twZ_cons_succ {n : ℕ} (hq : 1 < q) (c j a : ℕ) (g : Vertex (n + 1)) :
    twZ q c j w (consV (a + 1) g)
      = (q ^ (n + 2 + j) * (1 - q⁻¹ ^ (1 + j)))⁻¹
        * ((w ^ (n + 1)) ^ (a + 1) * ((q ^ ((n + 1) * (c + 1))) ^ (a + 1))⁻¹)
        * twZ q (c + 1) 0 w g := by
  unfold twZ
  rw [heightExp_cons, twWeight_cons_succ hq, pow_add, pow_mul]
  ring

/-- Summability of the height-weighted twisted mass, on the full range `0 ≤ w < q`. -/
lemma summable_twZ (hq : 1 < q) (hw : 0 ≤ w) (hwq : w < q) (n c j : ℕ) :
    Summable (fun g : Vertex (n + 1) => twZ q c j w g) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  obtain ⟨hsum, -⟩ := summable_pi_geom (gapRatioW q (n + 1) w)
    (gapRatioW_nonneg hq hw) (gapRatioW_lt_one hq hw hwq)
  refine Summable.of_nonneg_of_le (fun g => ?_) (fun g => ?_)
    (hsum.mul_left (((1 - q⁻¹) ^ (n + 1))⁻¹))
  · exact mul_nonneg (pow_nonneg hw _) (twWeight_pos hq c j g).le
  · rw [prod_gapRatioW w g, ← mul_assoc]
    have hle : twWeight q c j g ≤ ((1 - q⁻¹) ^ (n + 1))⁻¹ * (q ^ pairExp g)⁻¹ :=
      le_trans (twWeight_le_vertexWeight hq c j g) (vertexWeight_le g hq)
    calc w ^ heightExp g * twWeight q c j g
        ≤ w ^ heightExp g * (((1 - q⁻¹) ^ (n + 1))⁻¹ * (q ^ pairExp g)⁻¹) :=
          mul_le_mul_of_nonneg_left hle (pow_nonneg hw _)
      _ = ((1 - q⁻¹) ^ (n + 1))⁻¹ * (q ^ pairExp g)⁻¹ * w ^ heightExp g := by ring

/-- **The row-peeling recursion for the height-weighted twisted mass.** -/
theorem twZMass_succ (hq : 1 < q) (hw : 0 ≤ w) (hwq : w < q) (n c j : ℕ) :
    ∑' g : Vertex (n + 2), twZ q c j w g
      = (q ^ (n + 2 + j) * (1 - q⁻¹ ^ (1 + j)))⁻¹ *
        (∑' g : Vertex (n + 1), twZ q (c + 1) (j + 1) w g
          + (w ^ (n + 1) / (q ^ ((n + 1) * (c + 1)) - w ^ (n + 1)))
              * ∑' g : Vertex (n + 1), twZ q (c + 1) 0 w g) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  set K : ℝ := (q ^ (n + 2 + j) * (1 - q⁻¹ ^ (1 + j)))⁻¹ with hKdef
  set A : ℝ := q ^ ((n + 1) * (c + 1)) with hA
  set W : ℝ := w ^ (n + 1) with hW
  set M1 : ℝ := ∑' g : Vertex (n + 1), twZ q (c + 1) (j + 1) w g with hM1
  set M0 : ℝ := ∑' g : Vertex (n + 1), twZ q (c + 1) 0 w g with hM0
  have hApos : (0:ℝ) < A := by rw [hA]; positivity
  have hWnn : (0:ℝ) ≤ W := by rw [hW]; positivity
  have hWA : W < A := by
    rw [hW, hA]
    calc w ^ (n + 1) < q ^ (n + 1) := pow_lt_pow_left₀ hwq hw (by omega)
      _ ≤ q ^ ((n + 1) * (c + 1)) :=
          pow_le_pow_right₀ hq.le (Nat.le_mul_of_pos_right _ (Nat.succ_pos c))
  set r : ℝ := W * A⁻¹ with hr
  have hr0 : (0:ℝ) ≤ r := by rw [hr]; positivity
  have hrlt : r < 1 := by
    rw [hr, ← div_eq_mul_inv, div_lt_one hApos]
    exact hWA
  -- reindex the sum over the top gap
  have hsum2 : Summable (fun g : Vertex (n + 2) => twZ q c j w g) :=
    summable_twZ hq hw hwq (n + 1) c j
  have hF : Summable (fun p : ℕ × Vertex (n + 1) => twZ q c j w (consV p.1 p.2)) :=
    (Equiv.summable_iff (Fin.consEquiv (fun _ : Fin (n + 1) => ℕ))).mpr hsum2
  have hreindex : ∑' g : Vertex (n + 2), twZ q c j w g
      = ∑' p : ℕ × Vertex (n + 1), twZ q c j w (consV p.1 p.2) :=
    ((Fin.consEquiv (fun _ : Fin (n + 1) => ℕ)).tsum_eq
      (fun g : Vertex (n + 2) => twZ q c j w g)).symm
  have hzero : ∑' g : Vertex (n + 1), twZ q c j w (consV 0 g) = K * M1 := by
    rw [tsum_congr (fun g => twZ_cons_zero hq c j g), tsum_mul_left]
  have hsucc : ∀ a : ℕ, ∑' g : Vertex (n + 1), twZ q c j w (consV (a + 1) g)
      = K * (W ^ (a + 1) * ((A ^ (a + 1))⁻¹)) * M0 := by
    intro a
    rw [tsum_congr (fun g => twZ_cons_succ hq c j a g), tsum_mul_left]
  have hgeom : ∑' a : ℕ, K * (W ^ (a + 1) * ((A ^ (a + 1))⁻¹)) * M0
      = K * ((W / (A - W)) * M0) := by
    have hterm : ∀ a : ℕ, K * (W ^ (a + 1) * ((A ^ (a + 1))⁻¹)) * M0
        = (K * M0 * r) * r ^ a := by
      intro a
      simp only [hr, mul_pow, inv_pow, pow_succ, mul_inv]
      ring
    rw [tsum_congr hterm, tsum_mul_left, tsum_geometric_of_lt_one hr0 hrlt]
    have hAne : A ≠ 0 := ne_of_gt hApos
    have hAW : A - W ≠ 0 := by
      have : (0:ℝ) < A - W := by linarith
      exact ne_of_gt this
    have h1r : (1 : ℝ) - r ≠ 0 := by
      have : (0:ℝ) < 1 - r := by linarith
      exact ne_of_gt this
    rw [hr]
    field_simp
  rw [hreindex, hF.tsum_prod' (fun a => hF.prod_factor a), Summable.tsum_eq_zero_add hF.prod,
    hzero, tsum_congr hsucc, hgeom]
  ring

end Recursion

section Rationality

open Polynomial

/-- **Rationality of the height-weighted twisted mass.**  For every rank and every pair of
twisting parameters the sum is a rational function of the height weight `w`, with a
denominator that is nowhere zero on the full convergence range `0 ≤ w < q`. -/
theorem twZ_rational (hq : 1 < q) (n c j : ℕ) :
    ∃ P Q : Polynomial ℝ, ∀ w : ℝ, 0 ≤ w → w < q →
      Q.eval w ≠ 0 ∧ ∑' g : Vertex (n + 1), twZ q c j w g = P.eval w / Q.eval w := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  induction n generalizing c j with
  | zero =>
      refine ⟨C ((q ^ (1 + j) - 1)⁻¹), 1, fun w hw hwq => ⟨by simp, ?_⟩⟩
      have hval : ∀ g : Vertex 1, twZ q c j w g = (q ^ (1 + j) - 1)⁻¹ := by
        intro g
        have hzero : heightExp g = 0 := by
          show ∑ k ∈ range 0, (0 - k) * gapAt g k = 0
          simp
        unfold twZ
        rw [hzero, pow_zero, one_mul]
        have := twMass_eq (q := q) hq 0 c j
        have hsub : ∀ b : Vertex 1, b = (fun i => i.elim0) := fun b => funext (fun i => i.elim0)
        have hg : g = (fun i => i.elim0) := hsub g
        subst hg
        rw [tsum_eq_single (fun i => i.elim0) (fun b hb => absurd (hsub b) hb)] at this
        rw [this]
        unfold NumV DenV
        simp [Gpoly, Jfac, Pfac, Cfac]
      rw [tsum_congr hval]
      have hsub : ∀ b : Vertex 1, b = (fun i => i.elim0) := fun b => funext (fun i => i.elim0)
      rw [tsum_eq_single (fun i => i.elim0) (fun b hb => absurd (hsub b) hb)]
      simp
  | succ m ih =>
      obtain ⟨P1, Q1, h1⟩ := ih (c + 1) (j + 1)
      obtain ⟨P0, Q0, h0⟩ := ih (c + 1) 0
      set K : ℝ := (q ^ (m + 2 + j) * (1 - q⁻¹ ^ (1 + j)))⁻¹ with hK
      set A : ℝ := q ^ ((m + 1) * (c + 1)) with hA
      refine ⟨C K * (P1 * Q0 * (C A - X ^ (m + 1)) + X ^ (m + 1) * P0 * Q1),
        Q1 * Q0 * (C A - X ^ (m + 1)), fun w hw hwq => ?_⟩
      obtain ⟨hQ1, hZ1⟩ := h1 w hw hwq
      obtain ⟨hQ0, hZ0⟩ := h0 w hw hwq
      have hApos : (0:ℝ) < A := by rw [hA]; positivity
      have hWA : w ^ (m + 1) < A := by
        rw [hA]
        calc w ^ (m + 1) < q ^ (m + 1) := pow_lt_pow_left₀ hwq hw (by omega)
          _ ≤ q ^ ((m + 1) * (c + 1)) :=
              pow_le_pow_right₀ hq.le (Nat.le_mul_of_pos_right _ (Nat.succ_pos c))
      have hAW : A - w ^ (m + 1) ≠ 0 := by
        have : (0:ℝ) < A - w ^ (m + 1) := by linarith
        exact ne_of_gt this
      constructor
      · simp only [eval_mul, eval_sub, eval_C, eval_pow, eval_X]
        exact mul_ne_zero (mul_ne_zero hQ1 hQ0) hAW
      · rw [twZMass_succ hq hw hwq m c j, hZ1, hZ0, ← hK, ← hA]
        simp only [eval_mul, eval_add, eval_sub, eval_C, eval_pow, eval_X]
        field_simp

/-- **The height zeta function of the rank-`d` quotient is a rational function of
`u = q^{s/d}`** on the entire half-plane of convergence `s < d`. -/
theorem heightZeta_rational_general (hq : 1 < q) {d : ℕ} (hd : 1 ≤ d) :
    ∃ P Q : Polynomial ℝ, ∀ s : ℝ, s < d →
      Q.eval (q ^ (s / (d : ℝ))) ≠ 0 ∧
        heightZeta q d s = P.eval (q ^ (s / (d : ℝ))) / Q.eval (q ^ (s / (d : ℝ))) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  obtain ⟨n, rfl⟩ : ∃ n, d = n + 1 := ⟨d - 1, by omega⟩
  obtain ⟨P, Q, hPQ⟩ := twZ_rational (q := q) hq n 0 0
  refine ⟨P, Q, fun s hs => ?_⟩
  have hd0 : (0:ℝ) < ((n : ℝ) + 1) := by positivity
  have hcast : ((n + 1 : ℕ) : ℝ) = (n : ℝ) + 1 := by push_cast; ring
  have hw0 : (0:ℝ) ≤ q ^ (s / ((n + 1 : ℕ) : ℝ)) := (Real.rpow_pos_of_pos hq0 _).le
  have hwq : q ^ (s / ((n + 1 : ℕ) : ℝ)) < q := by
    have h1 : s / ((n + 1 : ℕ) : ℝ) < 1 := by
      rw [hcast, div_lt_one hd0]
      rw [hcast] at hs
      exact hs
    calc q ^ (s / ((n + 1 : ℕ) : ℝ)) < q ^ (1:ℝ) := (Real.rpow_lt_rpow_left_iff hq).mpr h1
      _ = q := Real.rpow_one q
  obtain ⟨hQ, hZ⟩ := hPQ _ hw0 hwq
  refine ⟨hQ, ?_⟩
  rw [← hZ]
  unfold heightZeta
  refine tsum_congr (fun g => ?_)
  rw [height_pow hq g s]
  unfold twZ
  rw [twWeight_zero_zero]
  ring

end Rationality

section Pole

/-- **The pole at `s = d` is genuine in every rank `d ≥ 2`.**  For every bound `M` there is
`s < d` with `M < Z_d(s)`; together with `summable_weight_height_iff` this pins the abscissa
of convergence of the height zeta function at exactly `s = d`. -/
theorem heightZeta_unbounded_general (hq : 1 < q) {d : ℕ} (hd : 2 ≤ d) (M : ℝ) :
    ∃ s : ℝ, s < d ∧ M < heightZeta q d s := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hd1 : (1:ℝ) ≤ ((d : ℝ) - 1) := by
    have : (2:ℝ) ≤ (d : ℝ) := by exact_mod_cast hd
    linarith
  have hd1pos : (0:ℝ) < ((d : ℝ) - 1) := by linarith
  have hdpos : (0:ℝ) < (d : ℝ) := by linarith
  set B : ℝ := (q ^ (d * d))⁻¹ with hB
  have hBpos : 0 < B := by rw [hB]; positivity
  have hMpos : (0:ℝ) < |M| + 1 := by positivity
  set e : ℝ := min ((q - 1) / 2) (B * q / (((d : ℝ) - 1) * (|M| + 1))) with he
  have hepos : 0 < e := lt_min (by linarith) (by positivity)
  have he1 : e ≤ (q - 1) / 2 := min_le_left _ _
  have he2 : e ≤ B * q / (((d : ℝ) - 1) * (|M| + 1)) := min_le_right _ _
  have hwpos : 0 < q - e := by linarith
  have hw1 : 1 < q - e := by linarith
  set s : ℝ := (d : ℝ) * Real.logb q (q - e) with hs
  have hlogb : Real.logb q (q - e) < 1 := by
    have h := Real.logb_lt_logb hq hwpos (show q - e < q by linarith)
    rwa [Real.logb_self_eq_one hq] at h
  have hsd : s < d := by
    rw [hs]
    nlinarith
  refine ⟨s, hsd, ?_⟩
  -- the height weight
  have hsu : s / (d : ℝ) = Real.logb q (q - e) := by
    rw [hs]
    field_simp
  have hu : q ^ (s / (d : ℝ)) = q - e := by
    rw [hsu]
    exact Real.rpow_logb hq0 (ne_of_gt hq) hwpos
  set w : ℝ := q - e with hw
  set t : ℝ := (w / q) ^ (d - 1) with ht
  have hwq : w < q := by rw [hw]; linarith
  have hwnn : (0:ℝ) ≤ w := by rw [hw]; linarith
  have hratio0 : (0:ℝ) ≤ w / q := by positivity
  have hratio1 : w / q < 1 := by rw [div_lt_one hq0]; exact hwq
  have ht0 : (0:ℝ) ≤ t := by rw [ht]; positivity
  have ht1 : t < 1 := by
    rw [ht]
    exact pow_lt_one₀ hratio0 hratio1 (by omega)
  -- lower bound the zeta function by the cusp ray
  have hsummZ : Summable (fun g : Vertex d => vertexWeight q g * height q g ^ s) :=
    summable_weight_height_of_lt hq hd hsd
  have hnn : ∀ g : Vertex d, 0 ≤ vertexWeight q g * height q g ^ s := by
    intro g
    exact mul_nonneg (vertexWeight_pos g hq).le
      (Real.rpow_pos_of_pos (Real.rpow_pos_of_pos hq0 _) s).le
  have hray : ∀ n : ℕ, B * t ^ n
      ≤ vertexWeight q (rayVertex d n) * height q (rayVertex d n) ^ s := by
    intro n
    have hwt := vertexWeight_ge (rayVertex d n) hq
    rw [height_pow hq _ s, heightExp_ray hd, hu, pairExp_ray hd] at *
    have hkey : B * t ^ n = (q ^ (d * d))⁻¹ * (q ^ ((d - 1) * n))⁻¹ * w ^ ((d - 1) * n) := by
      rw [hB, ht, ← pow_mul, div_pow, div_eq_mul_inv]
      ring
    rw [hkey]
    exact mul_le_mul_of_nonneg_right hwt (by positivity)
  have hsummG : Summable (fun n : ℕ => B * t ^ n) :=
    (summable_geometric_of_lt_one ht0 ht1).mul_left B
  have hle : ∑' n : ℕ, B * t ^ n ≤ heightZeta q d s := by
    unfold heightZeta
    calc ∑' n : ℕ, B * t ^ n
        ≤ ∑' n : ℕ, vertexWeight q (rayVertex d n) * height q (rayVertex d n) ^ s :=
          hsummG.tsum_le_tsum hray
            (hsummZ.comp_injective (rayVertex_injective hd))
      _ ≤ ∑' g : Vertex d, vertexWeight q g * height q g ^ s :=
          tsum_comp_le_tsum_of_inj hsummZ hnn (rayVertex_injective hd)
  -- evaluate and estimate the geometric series
  have hgeomval : ∑' n : ℕ, B * t ^ n = B * (1 - t)⁻¹ := by
    rw [tsum_mul_left, tsum_geometric_of_lt_one ht0 ht1]
  have hbern : 1 - ((d : ℝ) - 1) * (e / q) ≤ t := by
    have hx : (-2:ℝ) ≤ -(e / q) := by
      have : e / q ≤ 1 := by
        rw [div_le_one hq0]; linarith
      linarith
    have := one_add_mul_le_pow hx (d - 1)
    have hcast : ((d - 1 : ℕ) : ℝ) = (d : ℝ) - 1 := by
      have : (1:ℕ) ≤ d := by omega
      push_cast [Nat.cast_sub this]
      ring
    rw [hcast] at this
    have hrw : (1 : ℝ) + -(e / q) = w / q := by
      rw [hw]; field_simp; ring
    rw [hrw] at this
    rw [ht]
    linarith
  have h1t : 1 - t ≤ ((d : ℝ) - 1) * (e / q) := by linarith
  have h1tpos : (0:ℝ) < 1 - t := by linarith
  have hfinal : M < B * (1 - t)⁻¹ := by
    have hstep : B * (((d : ℝ) - 1) * (e / q))⁻¹ ≤ B * (1 - t)⁻¹ := by
      exact mul_le_mul_of_nonneg_left (inv_anti₀ h1tpos h1t) hBpos.le
    have hval : B * (((d : ℝ) - 1) * (e / q))⁻¹ = B * q / (((d : ℝ) - 1) * e) := by
      field_simp
    have hMlt : M < B * q / (((d : ℝ) - 1) * e) := by
      have hden : (0:ℝ) < ((d : ℝ) - 1) * e := by positivity
      rw [lt_div_iff₀ hden]
      have hkey : (((d : ℝ) - 1) * e) * (|M| + 1) ≤ B * q := by
        have : e * (((d : ℝ) - 1) * (|M| + 1)) ≤ B * q := by
          rw [← le_div_iff₀ (by positivity)]
          exact he2
        nlinarith
      nlinarith [le_abs_self M]
    linarith [hval ▸ hstep]
  linarith [hgeomval ▸ hle]

end Pole

end PGLQuotient