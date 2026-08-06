/-
# Massart's finite class lemma

If a hypothesis class restricted to a sample of size `n` consists of `N` vectors, each
of Euclidean length at most `r`, then its empirical Rademacher complexity is at most

  `r * √(2 log N) / n`.

The proof is the classical Chernoff/MGF argument:

* Jensen's inequality moves the expectation inside the exponential;
* a maximum is bounded by a sum, and the moment generating function of a Rademacher
  sum factorises into hyperbolic cosines, `𝔼 exp(λ⟨σ,v⟩) = ∏ cosh(λ vᵢ)`;
* `cosh t ≤ exp(t²/2)` gives the sub-Gaussian bound `exp(λ²r²/2)`;
* optimising over `λ` yields `√(2 log N)`.

Combined with `Massart` for the class of all `±1` patterns, this shows the bound is
tight up to the absolute constant `√(2 log 2) ≈ 1.177`; see `rad_cube` and
`massart_cube_tight` at the end of the file.

This file is self-contained.
-/
import Mathlib

namespace RademacherMassart

open Finset

variable {n : ℕ}

/-- The sign vector attached to a boolean vector: `true ↦ 1`, `false ↦ -1`. -/
def sgn (ε : Fin n → Bool) (i : Fin n) : ℝ := if ε i then 1 else -1

/-- The linear functional `v ↦ (1/n) ∑ σ i * v i` associated with a sign vector. -/
noncomputable def signAvg (ε : Fin n → Bool) (v : Fin n → ℝ) : ℝ :=
  (1 / (n : ℝ)) * ∑ i, sgn ε i * v i

/-- The empirical Rademacher complexity of a class `F` of vectors. -/
noncomputable def rad (F : Set (Fin n → ℝ)) : ℝ :=
  (∑ ε : Fin n → Bool, sSup (signAvg ε '' F)) / 2 ^ n

/-! ### Elementary facts about sign patterns -/

lemma sum_sign_neg (g : (Fin n → Bool) → ℝ) :
    ∑ ε : Fin n → Bool, g (fun j => !(ε j)) = ∑ ε : Fin n → Bool, g ε := by
  refine Finset.sum_nbij' (fun ε => fun j => !(ε j)) (fun ε => fun j => !(ε j))
    ?_ ?_ ?_ ?_ ?_ <;> intros <;> simp

lemma sgn_neg (ε : Fin n → Bool) (i : Fin n) : sgn (fun j => !(ε j)) i = -sgn ε i := by
  simp only [sgn]
  rcases Bool.eq_false_or_eq_true (ε i) with h | h <;> simp [h]

lemma sum_sgn_eq_zero (i : Fin n) : ∑ ε : Fin n → Bool, sgn ε i = 0 := by
  have h := sum_sign_neg (fun ε => sgn ε i)
  simp only [sgn_neg] at h
  rw [Finset.sum_neg_distrib] at h
  linarith

/-- The Rademacher complexity of a single vector is zero. -/
theorem rad_singleton (v : Fin n → ℝ) : rad ({v} : Set (Fin n → ℝ)) = 0 := by
  unfold rad
  have himg : ∀ ε : Fin n → Bool, sSup (signAvg ε '' ({v} : Set (Fin n → ℝ))) = signAvg ε v := by
    intro ε; simp [Set.image_singleton]
  rw [Finset.sum_congr rfl fun ε _ => himg ε]
  have : ∑ ε : Fin n → Bool, signAvg ε v = 0 := by
    unfold signAvg
    rw [← Finset.mul_sum, Finset.sum_comm]
    have h : ∀ i : Fin n, ∑ ε : Fin n → Bool, sgn ε i * v i = 0 := fun i => by
      rw [← Finset.sum_mul, sum_sgn_eq_zero i, zero_mul]
    simp [h]
  rw [this]; simp

/-! ### The two analytic ingredients -/

/-- Jensen's inequality for `exp` over the uniform distribution on sign patterns. -/
lemma exp_avg_le (y : (Fin n → Bool) → ℝ) :
    Real.exp ((∑ ε : Fin n → Bool, y ε) / 2 ^ n)
      ≤ (∑ ε : Fin n → Bool, Real.exp (y ε)) / 2 ^ n := by
  have hc : (0:ℝ) < 2 ^ n := by positivity
  have hw : ∀ ε ∈ (Finset.univ : Finset (Fin n → Bool)), (0:ℝ) ≤ 1 / 2 ^ n := by
    intro ε _; positivity
  have hsum : ∑ _ε : Fin n → Bool, (1:ℝ) / 2 ^ n = 1 := by
    rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
    simp
  have key := ConvexOn.map_sum_le (𝕜 := ℝ) (t := (Finset.univ : Finset (Fin n → Bool)))
    (w := fun _ => 1 / (2:ℝ) ^ n) (p := y) convexOn_exp hw hsum (fun ε _ => Set.mem_univ _)
  simp only [smul_eq_mul] at key
  calc Real.exp ((∑ ε : Fin n → Bool, y ε) / 2 ^ n)
      = Real.exp (∑ ε : Fin n → Bool, (1 / (2:ℝ) ^ n) * y ε) := by
        rw [← Finset.mul_sum]; ring_nf
    _ ≤ ∑ ε : Fin n → Bool, (1 / (2:ℝ) ^ n) * Real.exp (y ε) := key
    _ = (∑ ε : Fin n → Bool, Real.exp (y ε)) / 2 ^ n := by
        rw [← Finset.mul_sum]; ring

/-- Factorisation of the Rademacher moment generating function into a product over
coordinates. -/
lemma sum_exp_signed (v : Fin n → ℝ) (l : ℝ) :
    ∑ ε : Fin n → Bool, Real.exp (l * ∑ i, sgn ε i * v i)
      = ∏ i, (Real.exp (l * v i) + Real.exp (-(l * v i))) := by
  classical
  have hfac : ∀ ε : Fin n → Bool,
      Real.exp (l * ∑ i, sgn ε i * v i) = ∏ i, Real.exp (l * sgn ε i * v i) := by
    intro ε
    rw [← Real.exp_sum, Finset.mul_sum]
    congr 1
    exact Finset.sum_congr rfl fun i _ => by ring
  have h := Finset.prod_univ_sum (κ := fun _ : Fin n => Bool)
      (fun _ => (Finset.univ : Finset Bool))
      (fun i b => Real.exp (l * (if b then (1:ℝ) else -1) * v i))
  rw [Fintype.piFinset_univ] at h
  rw [Finset.sum_congr rfl (fun ε _ => hfac ε)]
  simp only [sgn]
  rw [← h]
  refine Finset.prod_congr rfl fun i _ => ?_
  rw [Fintype.sum_bool]
  norm_num

/-- The sub-Gaussian bound for a Rademacher sum, in product form. -/
lemma prod_exp_le (v : Fin n → ℝ) (l : ℝ) :
    ∏ i, (Real.exp (l * v i) + Real.exp (-(l * v i)))
      ≤ 2 ^ n * Real.exp (l ^ 2 * (∑ i, (v i) ^ 2) / 2) := by
  have hstep : ∀ i : Fin n, Real.exp (l * v i) + Real.exp (-(l * v i))
      ≤ 2 * Real.exp ((l * v i) ^ 2 / 2) := by
    intro i
    have h := Real.cosh_le_exp_half_sq (l * v i)
    rw [Real.cosh_eq] at h
    linarith
  have hnn : ∀ i : Fin n, (0:ℝ) ≤ Real.exp (l * v i) + Real.exp (-(l * v i)) := by
    intro i; positivity
  calc ∏ i, (Real.exp (l * v i) + Real.exp (-(l * v i)))
      ≤ ∏ i, (2 * Real.exp ((l * v i) ^ 2 / 2)) :=
        Finset.prod_le_prod (fun i _ => hnn i) (fun i _ => hstep i)
    _ = 2 ^ n * ∏ i, Real.exp ((l * v i) ^ 2 / 2) := by
        rw [Finset.prod_mul_distrib]; simp
    _ = 2 ^ n * Real.exp (∑ i, (l * v i) ^ 2 / 2) := by rw [Real.exp_sum]
    _ = 2 ^ n * Real.exp (l ^ 2 * (∑ i, (v i) ^ 2) / 2) := by
        congr 2
        rw [Finset.mul_sum, Finset.sum_div]
        exact Finset.sum_congr rfl fun i _ => by ring

/-! ### Massart's lemma -/

/-- The unnormalised maximum correlation of the class `F` with the sign pattern `ε`. -/
noncomputable def maxCorr (F : Finset (Fin n → ℝ)) (hne : F.Nonempty) (ε : Fin n → Bool) : ℝ :=
  F.sup' hne (fun v => ∑ i, sgn ε i * v i)

/-- For a finite class the supremum defining the Rademacher complexity is a maximum. -/
lemma sSup_image_finset (F : Finset (Fin n → ℝ)) (hne : F.Nonempty) (ε : Fin n → Bool) :
    sSup (signAvg ε '' (F : Set (Fin n → ℝ))) = (1 / (n : ℝ)) * maxCorr F hne ε := by
  have hmem : ∃ v ∈ F, F.sup' hne (fun v => ∑ i, sgn ε i * v i) = ∑ i, sgn ε i * v i :=
    Finset.exists_mem_eq_sup' hne _
  obtain ⟨v₀, hv₀, hval⟩ := hmem
  refine IsGreatest.csSup_eq ⟨⟨v₀, hv₀, ?_⟩, ?_⟩
  · unfold signAvg maxCorr
    rw [hval]
  · rintro a ⟨v, hv, rfl⟩
    unfold signAvg maxCorr
    have hle : ∑ i, sgn ε i * v i ≤ F.sup' hne (fun v => ∑ i, sgn ε i * v i) :=
      Finset.le_sup' (fun v : Fin n → ℝ => ∑ i, sgn ε i * v i) hv
    have hn : (0:ℝ) ≤ 1 / (n:ℝ) := by positivity
    exact mul_le_mul_of_nonneg_left hle hn

/-- The Rademacher complexity of a finite class in terms of `maxCorr`. -/
lemma rad_finset (F : Finset (Fin n → ℝ)) (hne : F.Nonempty) :
    rad (F : Set (Fin n → ℝ))
      = (1 / (n : ℝ)) * ((∑ ε : Fin n → Bool, maxCorr F hne ε) / 2 ^ n) := by
  unfold rad
  rw [Finset.sum_congr rfl fun ε _ => sSup_image_finset F hne ε, ← Finset.mul_sum]
  ring

/-- The core Chernoff bound: for every positive `λ`, the average maximal correlation is
at most `log N / λ + λ r² / 2`. -/
lemma avg_maxCorr_le (F : Finset (Fin n → ℝ)) (hne : F.Nonempty) {r l : ℝ}
    (hl : 0 < l) (hF : ∀ v ∈ F, ∑ i, (v i) ^ 2 ≤ r ^ 2) :
    (∑ ε : Fin n → Bool, maxCorr F hne ε) / 2 ^ n
      ≤ Real.log F.card / l + l * r ^ 2 / 2 := by
  classical
  have hpow : (0:ℝ) < 2 ^ n := by positivity
  set A := (∑ ε : Fin n → Bool, maxCorr F hne ε) / 2 ^ n with hA
  -- bound the exponential moment
  have hstep1 : Real.exp (l * A)
      ≤ (∑ ε : Fin n → Bool, Real.exp (l * maxCorr F hne ε)) / 2 ^ n := by
    have : l * A = (∑ ε : Fin n → Bool, l * maxCorr F hne ε) / 2 ^ n := by
      rw [← Finset.mul_sum, hA]; ring
    rw [this]
    exact exp_avg_le _
  have hstep2 : ∀ ε : Fin n → Bool, Real.exp (l * maxCorr F hne ε)
      ≤ ∑ v ∈ F, Real.exp (l * ∑ i, sgn ε i * v i) := by
    intro ε
    obtain ⟨v₀, hv₀, hval⟩ := Finset.exists_mem_eq_sup' hne (fun v => ∑ i, sgn ε i * v i)
    have : Real.exp (l * maxCorr F hne ε) = Real.exp (l * ∑ i, sgn ε i * v₀ i) := by
      unfold maxCorr; rw [hval]
    rw [this]
    exact Finset.single_le_sum (f := fun v => Real.exp (l * ∑ i, sgn ε i * v i))
      (fun v _ => (Real.exp_pos _).le) hv₀
  have hstep3 : ∑ ε : Fin n → Bool, Real.exp (l * maxCorr F hne ε)
      ≤ 2 ^ n * (F.card * Real.exp (l ^ 2 * r ^ 2 / 2)) := by
    calc ∑ ε : Fin n → Bool, Real.exp (l * maxCorr F hne ε)
        ≤ ∑ ε : Fin n → Bool, ∑ v ∈ F, Real.exp (l * ∑ i, sgn ε i * v i) :=
          Finset.sum_le_sum fun ε _ => hstep2 ε
      _ = ∑ v ∈ F, ∑ ε : Fin n → Bool, Real.exp (l * ∑ i, sgn ε i * v i) :=
          Finset.sum_comm
      _ ≤ ∑ _v ∈ F, 2 ^ n * Real.exp (l ^ 2 * r ^ 2 / 2) := by
          refine Finset.sum_le_sum fun v hv => ?_
          rw [sum_exp_signed v l]
          calc ∏ i, (Real.exp (l * v i) + Real.exp (-(l * v i)))
              ≤ 2 ^ n * Real.exp (l ^ 2 * (∑ i, (v i) ^ 2) / 2) := prod_exp_le v l
            _ ≤ 2 ^ n * Real.exp (l ^ 2 * r ^ 2 / 2) := by
                have hmono : l ^ 2 * (∑ i, (v i) ^ 2) / 2 ≤ l ^ 2 * r ^ 2 / 2 := by
                  have := hF v hv
                  nlinarith [sq_nonneg l]
                have := Real.exp_le_exp.mpr hmono
                nlinarith [Real.exp_pos (l ^ 2 * (∑ i, (v i) ^ 2) / 2), (by positivity : (0:ℝ) < 2 ^ n)]
      _ = 2 ^ n * (F.card * Real.exp (l ^ 2 * r ^ 2 / 2)) := by
          rw [Finset.sum_const, nsmul_eq_mul]; ring
  have hcard : (0:ℝ) < F.card := by
    exact_mod_cast Finset.card_pos.mpr hne
  have hexp : Real.exp (l * A) ≤ F.card * Real.exp (l ^ 2 * r ^ 2 / 2) := by
    calc Real.exp (l * A)
        ≤ (∑ ε : Fin n → Bool, Real.exp (l * maxCorr F hne ε)) / 2 ^ n := hstep1
      _ ≤ (2 ^ n * (F.card * Real.exp (l ^ 2 * r ^ 2 / 2))) / 2 ^ n := by
          exact div_le_div_of_nonneg_right hstep3 hpow.le
      _ = F.card * Real.exp (l ^ 2 * r ^ 2 / 2) := by field_simp
  have hlog : l * A ≤ Real.log F.card + l ^ 2 * r ^ 2 / 2 := by
    have hrhs : (F.card : ℝ) * Real.exp (l ^ 2 * r ^ 2 / 2)
        = Real.exp (Real.log F.card + l ^ 2 * r ^ 2 / 2) := by
      rw [Real.exp_add, Real.exp_log hcard]
    rw [hrhs] at hexp
    exact Real.exp_le_exp.mp hexp
  rw [div_add' _ _ _ hl.ne', le_div_iff₀ hl]
  nlinarith [hlog]

/-- The optimal choice `λ = √(2 log N)/r` balances the two terms of the Chernoff bound. -/
lemma optimal_lambda {r s L : ℝ} (hr : 0 < r) (hs : 0 < s) (hsq : s * s = 2 * L) :
    L / (s / r) + (s / r) * r ^ 2 / 2 = r * s := by
  field_simp
  nlinarith [hsq]

/-- **Massart's finite class lemma.**  A class of `N` vectors of Euclidean length at most
`r` has empirical Rademacher complexity at most `r √(2 log N) / n`. -/
theorem rad_le_massart (F : Finset (Fin n → ℝ)) (hne : F.Nonempty) (hn : 0 < n)
    {r : ℝ} (hr : 0 ≤ r) (hF : ∀ v ∈ F, ∑ i, (v i) ^ 2 ≤ r ^ 2) :
    rad (F : Set (Fin n → ℝ)) ≤ r * Real.sqrt (2 * Real.log F.card) / n := by
  classical
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  by_cases hcard1 : F.card = 1
  · -- a class with a single element has zero complexity
    obtain ⟨v, hv⟩ := Finset.card_eq_one.mp hcard1
    have hFv : (F : Set (Fin n → ℝ)) = ({v} : Set (Fin n → ℝ)) := by rw [hv]; simp
    rw [hFv, rad_singleton, hv]
    simp
  · -- at least two elements: `log N > 0`
    have hcard2 : 2 ≤ F.card := by
      have := Finset.card_pos.mpr hne
      omega
    have hcardR : (2:ℝ) ≤ F.card := by exact_mod_cast hcard2
    have hlogpos : 0 < Real.log F.card := by
      apply Real.log_pos
      linarith
    rcases eq_or_lt_of_le hr with hr0 | hrpos
    · -- `r = 0` forces every element to be the zero vector, contradicting `2 ≤ N`
      exfalso
      have hzero : ∀ v ∈ F, v = 0 := by
        intro v hv
        have h := hF v hv
        rw [← hr0] at h
        have hsum : ∑ i, (v i) ^ 2 ≤ 0 := by simpa using h
        have := (Finset.sum_eq_zero_iff_of_nonneg (fun i _ => sq_nonneg (v i))).mp
          (le_antisymm hsum (Finset.sum_nonneg fun i _ => sq_nonneg (v i)))
        funext i
        have := this i (Finset.mem_univ i)
        simpa [pow_eq_zero_iff] using this
      have hsub : F ⊆ {0} := fun v hv => by simp [hzero v hv]
      have := Finset.card_le_card hsub
      simp at this
      omega
    · set L := Real.log F.card with hL
      set l := Real.sqrt (2 * L) / r with hl
      have h2L : 0 < 2 * L := by linarith
      have hsq : Real.sqrt (2 * L) > 0 := Real.sqrt_pos.mpr h2L
      have hlpos : 0 < l := by positivity
      have hbound := avg_maxCorr_le F hne hlpos hF
      have hsqsq : Real.sqrt (2 * L) * Real.sqrt (2 * L) = 2 * L :=
        Real.mul_self_sqrt h2L.le
      have hval : L / l + l * r ^ 2 / 2 = r * Real.sqrt (2 * L) := by
        rw [hl]
        exact optimal_lambda hrpos hsq hsqsq
      rw [hval] at hbound
      rw [rad_finset F hne]
      have hmul := mul_le_mul_of_nonneg_left hbound
        (le_of_lt (by positivity : (0:ℝ) < 1 / (n:ℝ)))
      calc (1 / (n:ℝ)) * ((∑ ε : Fin n → Bool, maxCorr F hne ε) / 2 ^ n)
          ≤ (1 / (n:ℝ)) * (r * Real.sqrt (2 * L)) := hmul
        _ = r * Real.sqrt (2 * L) / n := by ring

/-! ### Tightness: the full sign cube -/

/-- The class of all `±1` patterns on the sample. -/
noncomputable def cube (n : ℕ) : Finset (Fin n → ℝ) := by
  classical
  exact (Finset.univ : Finset (Fin n → Bool)).image (fun ε => sgn ε)

lemma cube_nonempty (n : ℕ) : (cube n).Nonempty := by
  refine ⟨sgn (fun _ => true), ?_⟩
  simp [cube]

/-- Every sign pattern correlates perfectly with itself, so the empirical Rademacher
complexity of the full cube is exactly `1`. -/
theorem rad_cube (hn : 0 < n) : rad ((cube n : Finset (Fin n → ℝ)) : Set (Fin n → ℝ)) = 1 := by
  classical
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  have hmax : ∀ ε : Fin n → Bool, maxCorr (cube n) (cube_nonempty n) ε = (n : ℝ) := by
    intro ε
    apply le_antisymm
    · refine Finset.sup'_le _ _ ?_
      rintro v hv
      simp only [cube, Finset.mem_image] at hv
      obtain ⟨δ, -, rfl⟩ := hv
      calc ∑ i, sgn ε i * sgn δ i ≤ ∑ _i : Fin n, (1:ℝ) := by
            refine Finset.sum_le_sum fun i _ => ?_
            simp only [sgn]
            rcases Bool.eq_false_or_eq_true (ε i) with h | h <;>
              rcases Bool.eq_false_or_eq_true (δ i) with h' | h' <;> simp [h, h']
        _ = (n:ℝ) := by simp
    · have hmem : sgn ε ∈ cube n := by simp [cube]
      have := Finset.le_sup' (s := cube n) (fun v : Fin n → ℝ => ∑ i, sgn ε i * v i) hmem
      refine le_trans (le_of_eq ?_) this
      have : ∀ i : Fin n, sgn ε i * sgn ε i = 1 := by
        intro i
        simp only [sgn]
        rcases Bool.eq_false_or_eq_true (ε i) with h | h <;> simp [h]
      simp [this]
  rw [rad_finset (cube n) (cube_nonempty n)]
  rw [Finset.sum_congr rfl fun ε _ => hmax ε]
  rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
  simp only [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]
  push_cast
  field_simp

/-- Massart's bound applied to the full cube gives `√(2 log 2)`, while the true value is
`1`: the finite class lemma is tight up to the absolute constant `√(2 log 2) < 6/5`. -/
theorem massart_cube_tight (hn : 0 < n) :
    rad ((cube n : Finset (Fin n → ℝ)) : Set (Fin n → ℝ)) = 1 ∧
      Real.sqrt (n : ℝ) * Real.sqrt (2 * Real.log ((2:ℝ) ^ n)) / n
        = Real.sqrt (2 * Real.log 2) ∧
      (1:ℝ) ≤ Real.sqrt (2 * Real.log 2) ∧ Real.sqrt (2 * Real.log 2) < 6 / 5 := by
  have hn' : (0:ℝ) < n := by exact_mod_cast hn
  refine ⟨rad_cube hn, ?_, ?_, ?_⟩
  · rw [Real.log_pow]
    have : (2:ℝ) * ((n:ℝ) * Real.log 2) = (n:ℝ) * (2 * Real.log 2) := by ring
    rw [this, Real.sqrt_mul (by positivity)]
    have hns : Real.sqrt (n:ℝ) * Real.sqrt (n:ℝ) = (n:ℝ) := Real.mul_self_sqrt hn'.le
    field_simp
    nlinarith [hns]
  · rw [show (1:ℝ) = Real.sqrt 1 by simp]
    apply Real.sqrt_le_sqrt
    nlinarith [Real.log_two_gt_d9]
  · have h : Real.sqrt (2 * Real.log 2) < Real.sqrt ((6/5) ^ 2) := by
      apply Real.sqrt_lt_sqrt (by positivity)
      nlinarith [Real.log_two_lt_d9]
    rwa [Real.sqrt_sq (by norm_num)] at h

end RademacherMassart