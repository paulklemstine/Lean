import Algebra.PGLQuotient.HeightThreshold

/-!
# The sharp cusp-tail estimate of order `T^{-d}`

For the standard arithmetic quotient of the Bruhat–Tits building of `PGL_d(F_q((t^{-1})))`,
with the normalised lattice-minima height `α` of `Algebra.PGLQuotient.VertexModel`, we prove
the two-sided cusp-tail estimate

`c · T^{-d} ≤ mass {α > T} ≤ C · T^{-d}`   for all `T ≥ 1`.

The upper bound is the delicate half: the naive estimate coming from the integrability
threshold only gives `T^{-r}` for every `r < d`.  The sharp exponent is obtained by
*fibering the gap lattice over the height exponent*: the linear form
`N(g) = ∑_k (d-1-k) g_k = d log_q α` determines the first gap coordinate `g_0` once the
remaining coordinates are known, and the residual exponent `R(g) = ∑_k k(d-1-k) g_k` does not
involve `g_0` at all.  Hence `∑_{N(g) = n} q^{-R(g)}` is bounded uniformly in `n`, and
summing the resulting geometric series in `n` produces the exact exponent `T^{-d}`.

The lower bound comes from a single vertex on the cusp ray `λ = (n, 0, …, 0)`.
-/

namespace PGLQuotient

open Finset

variable {d : ℕ} {q : ℝ}

/-- The cusp-tail mass at height level `T`. -/
noncomputable def cuspTail (q : ℝ) (d : ℕ) (T : ℝ) : ℝ :=
  ∑' g : {g : Vertex d | T < height q g}, vertexWeight q (g : Vertex d)

lemma summable_vertexWeight (hq : 1 < q) (hd : 2 ≤ d) :
    Summable (fun g : Vertex d => vertexWeight q g) := by
  have hd0 : (0:ℝ) < (d : ℝ) := by
    have : 0 < d := by omega
    exact_mod_cast this
  have h := summable_weight_height_of_lt (q := q) (d := d) hq hd (s := 0) hd0
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  refine h.congr (fun g => ?_)
  rw [Real.rpow_zero, mul_one]

/-! ### The fibering majorant -/

/-- The per-coordinate base of the residual geometric series: the coordinate `k = 0`
is switched off, since the residual exponent `R` does not involve it. -/
noncomputable def resBase (q : ℝ) (d : ℕ) (k : Fin (d - 1)) : ℝ :=
  if (k : ℕ) = 0 then 0 else (q ^ ((k : ℕ) * (d - 1 - (k : ℕ))))⁻¹

lemma resBase_nonneg (hq : 1 < q) (k : Fin (d - 1)) : 0 ≤ resBase q d k := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  unfold resBase
  split
  · exact le_rfl
  · positivity

lemma resBase_lt_one (hq : 1 < q) (k : Fin (d - 1)) : resBase q d k < 1 := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  unfold resBase
  split
  · exact zero_lt_one
  · rename_i hk
    have hk1 : 1 ≤ (k : ℕ) := by omega
    have hkd : 1 ≤ d - 1 - (k : ℕ) := by have := k.isLt; omega
    have h1 : 1 ≤ (k : ℕ) * (d - 1 - (k : ℕ)) := Nat.one_le_iff_ne_zero.mpr (by positivity)
    have : (1:ℝ) < q ^ ((k : ℕ) * (d - 1 - (k : ℕ))) := by
      calc (1:ℝ) = q ^ 0 := (pow_zero q).symm
        _ < q ^ ((k : ℕ) * (d - 1 - (k : ℕ))) := by
            exact pow_lt_pow_right₀ hq (by omega)
    exact inv_lt_one_of_one_lt₀ this

/-- The residual product equals `q^{-R(g)}` once the zeroth coordinate has been switched off. -/
lemma prod_resBase (hq : 1 < q) (g : Vertex d) (h0 : 0 < d - 1) :
    ∏ k, resBase q d k ^ (Function.update g ⟨0, h0⟩ 0 k) = (q ^ resExp g)⁻¹ := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hterm : ∀ k : Fin (d - 1), resBase q d k ^ (Function.update g ⟨0, h0⟩ 0 k)
      = (q⁻¹) ^ ((k : ℕ) * (d - 1 - (k : ℕ)) * g k) := by
    intro k
    by_cases hk : k = ⟨0, h0⟩
    · subst hk
      simp [resBase]
    · have hk0 : (k : ℕ) ≠ 0 := by
        intro hc
        exact hk (Fin.ext hc)
      rw [Function.update_of_ne hk, resBase, if_neg hk0, ← inv_pow, ← pow_mul]
  rw [Finset.prod_congr rfl (fun k _ => hterm k), Finset.prod_pow_eq_pow_sum, ← inv_pow]
  congr 1
  rw [resExp, ← Fin.sum_univ_eq_sum_range (fun k => k * (d - 1 - k) * gapAt g k)]
  exact Finset.sum_congr rfl (fun k _ => by rw [gapAt_coe])

/-- Summability of the fibering majorant on `ℕ × Vertex d`. -/
lemma summable_tailMajorant (hq : 1 < q) :
    Summable (fun p : ℕ × Vertex d => (q⁻¹) ^ p.1 * ∏ k, resBase q d k ^ (p.2 k)) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hinv : q⁻¹ < 1 := inv_lt_one_of_one_lt hq
  have hinv0 : (0:ℝ) ≤ q⁻¹ := le_of_lt (inv_pos.mpr hq0)
  obtain ⟨hs2, -⟩ := summable_pi_geom (resBase q d) (resBase_nonneg hq) (resBase_lt_one hq)
  have hsum1 : Summable (fun n : ℕ => (q⁻¹) ^ n) := summable_geometric_of_lt_one hinv0 hinv
  have hnn1 : (0 : ℕ → ℝ) ≤ fun n : ℕ => (q⁻¹) ^ n := fun n => pow_nonneg hinv0 n
  have hnn2 : (0 : Vertex d → ℝ) ≤ fun h : Vertex d => ∏ k, resBase q d k ^ h k :=
    fun h => Finset.prod_nonneg (fun k _ => pow_nonneg (resBase_nonneg hq k) _)
  exact (hsum1.mul_of_nonneg hs2 hnn1 hnn2).congr (fun p => rfl)

/-- Splitting off the zeroth gap coordinate from the height exponent. -/
lemma heightExp_split (g : Vertex d) (h0 : 0 < d - 1) :
    heightExp g = (d - 1) * g ⟨0, h0⟩ + ∑ k ∈ Finset.Ico 1 (d - 1), (d - 1 - k) * gapAt g k := by
  unfold heightExp
  rw [Finset.range_eq_Ico, Finset.sum_eq_sum_Ico_succ_bot h0]
  congr 1
  · have : gapAt g 0 = g ⟨0, h0⟩ := by simp [gapAt, h0]
    rw [this]
    simp

/-- The fibering injection: a vertex above a height level is determined by the excess of its
height exponent together with its gap coordinates other than the zeroth one. -/
lemma tailInjection_injective (n₀ : ℕ) (h0 : 0 < d - 1) :
    Function.Injective (fun g : {g : Vertex d // n₀ < heightExp g} =>
      ((heightExp (g : Vertex d) - (n₀ + 1) : ℕ),
        Function.update (g : Vertex d) ⟨0, h0⟩ 0)) := by
  rintro ⟨g, hg⟩ ⟨g', hg'⟩ hEq
  simp only [Prod.mk.injEq] at hEq
  obtain ⟨h1, h2⟩ := hEq
  have hne : ∀ k : Fin (d - 1), k ≠ ⟨0, h0⟩ → g k = g' k := by
    intro k hk
    have := congrFun h2 k
    rwa [Function.update_of_ne hk, Function.update_of_ne hk] at this
  have hgap : ∀ k ∈ Finset.Ico 1 (d - 1),
      (d - 1 - k) * gapAt g k = (d - 1 - k) * gapAt g' k := by
    intro k hk
    simp only [Finset.mem_Ico] at hk
    have hk1 : k < d - 1 := hk.2
    have e1 : gapAt g k = g ⟨k, hk1⟩ := by simp [gapAt, hk1]
    have e2 : gapAt g' k = g' ⟨k, hk1⟩ := by simp [gapAt, hk1]
    rw [e1, e2]
    congr 1
    exact hne ⟨k, hk1⟩ (by
      intro hc
      have : k = 0 := by simpa using congrArg (Fin.val) hc
      omega)
  have hheight : heightExp g = heightExp g' := by omega
  have hsplit := heightExp_split g h0
  have hsplit' := heightExp_split g' h0
  rw [Finset.sum_congr rfl hgap] at hsplit
  have hval : (d - 1) * g ⟨0, h0⟩ = (d - 1) * g' ⟨0, h0⟩ := by omega
  have h0' : g ⟨0, h0⟩ = g' ⟨0, h0⟩ := by
    have : 0 < d - 1 := h0
    exact Nat.eq_of_mul_eq_mul_left this hval
  have hgg : g = g' := by
    funext k
    by_cases hk : k = ⟨0, h0⟩
    · subst hk; exact h0'
    · exact hne k hk
  exact Subtype.ext hgg

/-- **Fibered tail bound.**  The mass above the height level `q^{n₀/d}` is `O(q^{-n₀})`. -/
theorem tailMass_le (hq : 1 < q) (hd : 2 ≤ d) (n₀ : ℕ) :
    ∑' g : {g : Vertex d | n₀ < heightExp g}, vertexWeight q (g : Vertex d)
      ≤ (((1 - q⁻¹) ^ d)⁻¹ * (q ^ (n₀ + 1))⁻¹)
        * ∑' p : ℕ × Vertex d, (q⁻¹) ^ p.1 * ∏ k, resBase q d k ^ (p.2 k) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have h0 : 0 < d - 1 := by omega
  have hmaj := summable_tailMajorant (q := q) (d := d) hq
  have hsubsum : Summable (fun g : {g : Vertex d | n₀ < heightExp g} =>
      vertexWeight q (g : Vertex d)) := (summable_vertexWeight hq hd).subtype _
  have hcst : (0:ℝ) ≤ ((1 - q⁻¹) ^ d)⁻¹ * (q ^ (n₀ + 1))⁻¹ := by
    have := one_sub_inv_pos (q := q) hq
    positivity
  rw [← hmaj.tsum_mul_left]
  refine Summable.tsum_le_tsum_of_inj
    (fun g : {g : Vertex d | n₀ < heightExp g} =>
      ((heightExp (g : Vertex d) - (n₀ + 1) : ℕ),
        Function.update (g : Vertex d) ⟨0, h0⟩ 0))
    (tailInjection_injective n₀ h0) (fun p _ => ?_) (fun g => ?_) hsubsum
    (hmaj.mul_left _)
  · refine mul_nonneg hcst (mul_nonneg (pow_nonneg (le_of_lt (inv_pos.mpr hq0)) _) ?_)
    exact Finset.prod_nonneg (fun k _ => pow_nonneg (resBase_nonneg hq k) _)
  · -- the pointwise bound
    obtain ⟨g, hg⟩ := g
    simp only [Set.mem_setOf_eq] at hg
    rw [prod_resBase hq g h0]
    have hq' : (q:ℝ) ≠ 0 := ne_of_gt hq0
    have hres : (q⁻¹) ^ (heightExp g - (n₀ + 1)) * (q ^ resExp g)⁻¹
        = (q ^ (n₀ + 1)) * (q ^ pairExp g)⁻¹ := by
      obtain ⟨a, ha⟩ : ∃ a, heightExp g = a + (n₀ + 1) := ⟨heightExp g - (n₀ + 1), by omega⟩
      rw [pairExp_eq, ha, Nat.add_sub_cancel, inv_pow, pow_add, pow_add]
      field_simp
      ring
    calc vertexWeight q g ≤ ((1 - q⁻¹) ^ d)⁻¹ * (q ^ pairExp g)⁻¹ := vertexWeight_le g hq
      _ = ((1 - q⁻¹) ^ d)⁻¹ * (q ^ (n₀ + 1))⁻¹
            * ((q⁻¹) ^ (heightExp g - (n₀ + 1)) * (q ^ resExp g)⁻¹) := by
          rw [hres]
          field_simp

/-! ### From the fibered bound to the sharp `T^{-d}` cusp tail -/

lemma height_gt_iff (hq : 1 < q) (hd : 2 ≤ d) {T : ℝ} (hT : 1 ≤ T) (g : Vertex d) :
    T < height q g ↔ (d : ℝ) * Real.logb q T < heightExp g := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hd0 : (0:ℝ) < (d : ℝ) := by
    have : 0 < d := by omega
    exact_mod_cast this
  have hT0 : (0:ℝ) < T := lt_of_lt_of_le zero_lt_one hT
  have hTq : q ^ (Real.logb q T) = T := Real.rpow_logb hq0 (ne_of_gt hq) hT0
  constructor
  · intro h
    rw [← hTq] at h
    have h2 := (Real.rpow_lt_rpow_left_iff hq).mp h
    rw [lt_div_iff₀ hd0] at h2
    linarith
  · intro h
    rw [← hTq]
    refine (Real.rpow_lt_rpow_left_iff hq).mpr ?_
    rw [lt_div_iff₀ hd0]
    linarith

/-- **Sharp cusp-tail upper bound**: the mass above height `T` is `O(T^{-d})`. -/
theorem cuspTail_upper (hq : 1 < q) (hd : 2 ≤ d) :
    ∃ C > 0, ∀ T : ℝ, 1 ≤ T → cuspTail q d T ≤ C * T ^ (-(d:ℝ)) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hpos1 : (0:ℝ) < ((1 - q⁻¹) ^ d)⁻¹ := by
    have := one_sub_inv_pos (q := q) hq
    positivity
  have hmaj := summable_tailMajorant (q := q) (d := d) hq
  set S : ℝ := ∑' p : ℕ × Vertex d, (q⁻¹) ^ p.1 * ∏ k, resBase q d k ^ (p.2 k) with hS
  have hnn : ∀ p : ℕ × Vertex d, 0 ≤ (q⁻¹) ^ p.1 * ∏ k, resBase q d k ^ (p.2 k) := by
    intro p
    exact mul_nonneg (pow_nonneg (le_of_lt (inv_pos.mpr hq0)) _)
      (Finset.prod_nonneg (fun k _ => pow_nonneg (resBase_nonneg hq k) _))
  have hSpos : 0 < S := by
    have hterm : (0:ℝ) < (q⁻¹) ^ (0:ℕ) * ∏ k, resBase q d k ^ ((0 : Vertex d) k) := by
      simp
    calc (0:ℝ) < (q⁻¹) ^ (0:ℕ) * ∏ k, resBase q d k ^ ((0 : Vertex d) k) := hterm
      _ ≤ S := hmaj.le_tsum ((0 : ℕ), (0 : Vertex d)) (fun j _ => hnn j)
  refine ⟨((1 - q⁻¹) ^ d)⁻¹ * S, by positivity, ?_⟩
  intro T hT
  have hT0 : (0:ℝ) < T := lt_of_lt_of_le zero_lt_one hT
  set L : ℝ := Real.logb q T with hL
  have hL0 : 0 ≤ L := Real.logb_nonneg hq hT
  have hTq : q ^ L = T := Real.rpow_logb hq0 (ne_of_gt hq) hT0
  set n₀ : ℕ := ⌊(d : ℝ) * L⌋₊ with hn₀
  have hdL0 : (0:ℝ) ≤ (d : ℝ) * L := by positivity
  have hsub : ∀ g : Vertex d, T < height q g → n₀ < heightExp g := by
    intro g hg
    have h1 : (d : ℝ) * L < heightExp g := (height_gt_iff hq hd hT g).mp hg
    have h2 : ((n₀ : ℕ) : ℝ) ≤ (d : ℝ) * L := Nat.floor_le hdL0
    exact_mod_cast lt_of_le_of_lt h2 h1
  have hsum0 := summable_vertexWeight (q := q) (d := d) hq hd
  have hsub1 : Summable (fun g : {g : Vertex d | T < height q g} =>
      vertexWeight q (g : Vertex d)) := hsum0.subtype _
  have hsub2 : Summable (fun g : {g : Vertex d | n₀ < heightExp g} =>
      vertexWeight q (g : Vertex d)) := hsum0.subtype _
  have hmono : cuspTail q d T
      ≤ ∑' g : {g : Vertex d | n₀ < heightExp g}, vertexWeight q (g : Vertex d) := by
    refine Summable.tsum_le_tsum_of_inj
      (fun g : {g : Vertex d | T < height q g} =>
        (⟨(g : Vertex d), hsub _ g.2⟩ : {g : Vertex d | n₀ < heightExp g}))
      ?_ (fun c _ => le_of_lt (vertexWeight_pos _ hq)) (fun g => le_rfl) hsub1 hsub2
    rintro ⟨g, hg⟩ ⟨g', hg'⟩ h
    simp only [Subtype.mk.injEq] at h
    exact Subtype.ext h
  have hkey := tailMass_le (q := q) (d := d) hq hd n₀
  have hqT : T ^ (d:ℝ) ≤ q ^ (n₀ + 1) := by
    have h1 : (d : ℝ) * L < ((n₀ + 1 : ℕ) : ℝ) := by
      push_cast
      exact Nat.lt_floor_add_one _
    have h2 : T ^ (d:ℝ) = q ^ ((d : ℝ) * L) := by
      rw [← hTq, ← Real.rpow_mul (le_of_lt hq0)]
      ring_nf
    rw [h2, ← Real.rpow_natCast q (n₀ + 1)]
    exact le_of_lt ((Real.rpow_lt_rpow_left_iff hq).mpr h1)
  have hinv : (q ^ (n₀ + 1))⁻¹ ≤ T ^ (-(d:ℝ)) := by
    have hTd : (0:ℝ) < T ^ (d:ℝ) := Real.rpow_pos_of_pos hT0 _
    rw [Real.rpow_neg (le_of_lt hT0)]
    exact inv_anti₀ hTd hqT
  calc cuspTail q d T ≤ ∑' g : {g : Vertex d | n₀ < heightExp g}, vertexWeight q (g : Vertex d) :=
        hmono
    _ ≤ (((1 - q⁻¹) ^ d)⁻¹ * (q ^ (n₀ + 1))⁻¹) * S := hkey
    _ ≤ (((1 - q⁻¹) ^ d)⁻¹ * T ^ (-(d:ℝ))) * S := by
        refine mul_le_mul_of_nonneg_right ?_ (le_of_lt hSpos)
        exact mul_le_mul_of_nonneg_left hinv (le_of_lt hpos1)
    _ = ((1 - q⁻¹) ^ d)⁻¹ * S * T ^ (-(d:ℝ)) := by ring

/-- **Sharp cusp-tail lower bound**: the mass above height `T` is `≫ T^{-d}`. -/
theorem cuspTail_lower (hq : 1 < q) (hd : 2 ≤ d) :
    ∃ c > 0, ∀ T : ℝ, 1 ≤ T → c * T ^ (-(d:ℝ)) ≤ cuspTail q d T := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have hd1 : (1:ℝ) < (d : ℝ) := by
    have : 1 < d := by omega
    exact_mod_cast this
  have hd0 : (0:ℝ) < (d : ℝ) := lt_trans zero_lt_one hd1
  have hdne : (d : ℝ) - 1 ≠ 0 := by linarith
  have hdpos : (0:ℝ) < (d : ℝ) - 1 := by linarith
  refine ⟨(q ^ (d * d))⁻¹ * (q ^ (d - 1))⁻¹, by positivity, ?_⟩
  intro T hT
  have hT0 : (0:ℝ) < T := lt_of_lt_of_le zero_lt_one hT
  set L : ℝ := Real.logb q T with hL
  have hL0 : 0 ≤ L := Real.logb_nonneg hq hT
  have hTq : q ^ L = T := Real.rpow_logb hq0 (ne_of_gt hq) hT0
  have hdm1 : ((d - 1 : ℕ) : ℝ) = (d : ℝ) - 1 := by
    have h1 : 1 ≤ d := by omega
    push_cast [Nat.cast_sub h1]
    ring
  have hquot0 : (0:ℝ) ≤ (d : ℝ) * L / ((d : ℝ) - 1) :=
    div_nonneg (by positivity) (le_of_lt hdpos)
  set n : ℕ := ⌊(d : ℝ) * L / ((d : ℝ) - 1)⌋₊ + 1 with hn
  have hnlow : (d : ℝ) * L / ((d : ℝ) - 1) < (n : ℝ) := by
    rw [hn]
    push_cast
    exact Nat.lt_floor_add_one _
  have hnup : ((d - 1 : ℕ) : ℝ) * (n : ℝ) ≤ (d : ℝ) * L + ((d : ℝ) - 1) := by
    have h1 : (n : ℝ) ≤ (d : ℝ) * L / ((d : ℝ) - 1) + 1 := by
      rw [hn]
      push_cast
      linarith [Nat.floor_le hquot0]
    have h2 : ((d : ℝ) - 1) * ((d : ℝ) * L / ((d : ℝ) - 1) + 1) = (d : ℝ) * L + ((d : ℝ) - 1) := by
      field_simp
    rw [hdm1]
    nlinarith [h1, hdpos]
  have hheight : T < height q (rayVertex d n) := by
    refine (height_gt_iff hq hd hT _).mpr ?_
    rw [heightExp_ray hd]
    push_cast
    rw [hdm1]
    rw [div_lt_iff₀ hdpos] at hnlow
    linarith
  have hsum0 := summable_vertexWeight (q := q) (d := d) hq hd
  have hsub1 : Summable (fun g : {g : Vertex d | T < height q g} =>
      vertexWeight q (g : Vertex d)) := hsum0.subtype _
  have hterm : vertexWeight q (rayVertex d n) ≤ cuspTail q d T :=
    hsub1.le_tsum (⟨rayVertex d n, hheight⟩ : {g : Vertex d | T < height q g})
      (fun j _ => le_of_lt (vertexWeight_pos _ hq))
  refine le_trans ?_ hterm
  have hw := vertexWeight_ge (q := q) (rayVertex d n) hq
  rw [pairExp_ray hd] at hw
  refine le_trans ?_ hw
  have hpowbound : q ^ ((d - 1) * n) ≤ q ^ (d - 1) * T ^ (d:ℝ) := by
    have h1 : q ^ ((d - 1) * n) = q ^ (((d - 1 : ℕ) : ℝ) * (n : ℝ)) := by
      rw [← Real.rpow_natCast q ((d - 1) * n)]
      push_cast
      ring_nf
    have h2 : q ^ (d - 1) * T ^ (d:ℝ) = q ^ (((d : ℝ) - 1) + (d : ℝ) * L) := by
      rw [Real.rpow_add hq0, ← hTq, ← Real.rpow_mul (le_of_lt hq0), ← hdm1,
        ← Real.rpow_natCast q (d - 1)]
      ring_nf
    rw [h1, h2]
    refine (Real.rpow_le_rpow_left_iff hq).mpr ?_
    linarith [hnup]
  have hstep : (q ^ (d - 1))⁻¹ * T ^ (-(d:ℝ)) ≤ (q ^ ((d - 1) * n))⁻¹ := by
    rw [Real.rpow_neg (le_of_lt hT0), ← mul_inv]
    exact inv_anti₀ (pow_pos hq0 _) hpowbound
  calc (q ^ (d * d))⁻¹ * (q ^ (d - 1))⁻¹ * T ^ (-(d:ℝ))
      = (q ^ (d * d))⁻¹ * ((q ^ (d - 1))⁻¹ * T ^ (-(d:ℝ))) := by ring
    _ ≤ (q ^ (d * d))⁻¹ * (q ^ ((d - 1) * n))⁻¹ := by
        refine mul_le_mul_of_nonneg_left hstep (by positivity)

/-- **The sharp cusp-tail estimate of order `T^{-d}`.** -/
theorem cuspTail_asymptotic (hq : 1 < q) (hd : 2 ≤ d) :
    ∃ c C : ℝ, 0 < c ∧ 0 < C ∧
      ∀ T : ℝ, 1 ≤ T → c * T ^ (-(d:ℝ)) ≤ cuspTail q d T ∧ cuspTail q d T ≤ C * T ^ (-(d:ℝ)) := by
  obtain ⟨c, hc, hclow⟩ := cuspTail_lower (q := q) (d := d) hq hd
  obtain ⟨C, hC, hCup⟩ := cuspTail_upper (q := q) (d := d) hq hd
  exact ⟨c, C, hc, hC, fun T hT => ⟨hclow T hT, hCup T hT⟩⟩

end PGLQuotient