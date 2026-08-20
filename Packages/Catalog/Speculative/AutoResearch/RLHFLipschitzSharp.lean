import Algebra.RLHFTiltTorsorPTX

/-!
# The reward-hacking budget is sharp

`RLHF.freeEnergy_lipschitz` bounds the change of the alignment value by the sup-norm distance
between reward models, with constant `1`:

```
|F(r) − F(s)| ≤ ‖r − s‖_∞ .
```

This file shows the constant cannot be improved: on a two-response space with a uniform SFT
reference, a reward perturbation of sup-norm `K` moves the alignment value by at least
`K − β log 2`, so letting the KL temperature `β` shrink makes the bound as tight as desired
(`RLHF.freeEnergy_lipschitz_sharp`).  Consequently no constant `c < 1` works
(`RLHF.no_better_lipschitz_constant`).

A second, complementary negative result is proved: the sup-norm cannot be replaced by the
*reference-weighted* quadratic norm `‖f‖²_{L²(p)} = ∑ p y f y ^ 2`
(`RLHF.no_reference_weighted_bound`), no matter how large a constant is allowed.

Interpretation: a neurosymbolic reward model corrupted by at most `K` in sup-norm can change the
attainable alignment value by essentially the full `K`, and this worst case is realized at low
KL temperature — precisely the regime in which reward hacking is observed in practice.  Moreover
the corruption is invisible to any norm that discounts responses the SFT model rarely emits,
which is exactly how reward hacking evades reference-weighted diagnostics.

All results are `sorry`-free.
-/

namespace RLHF

open Finset

/-- Uniform reference policy on the two-response space. -/
noncomputable def twoUnif : Bool → ℝ := fun _ => 1 / 2

/-- The perturbed reward model: value `K` on `true`, `0` on `false`. -/
noncomputable def twoSpike (K : ℝ) : Bool → ℝ := fun b => if b then K else 0

theorem twoUnif_isPosDist : IsPosDist twoUnif := by
  refine ⟨fun y => by norm_num [twoUnif], ?_⟩
  simp [twoUnif]

theorem freeEnergy_zero_reward {β : ℝ} : freeEnergy β (fun _ => (0 : ℝ)) twoUnif = 0 := by
  have hZ : partition β (fun _ => (0 : ℝ)) twoUnif = 1 := by
    unfold partition
    simp [twoUnif]
  unfold freeEnergy
  rw [hZ, Real.log_one, mul_zero]

theorem freeEnergy_twoSpike_ge {β K : ℝ} (hβ : 0 < β) :
    K - β * Real.log 2 ≤ freeEnergy β (twoSpike K) twoUnif := by
  have hZ : partition β (twoSpike K) twoUnif
      = (Real.exp (K / β) + 1) / 2 := by
    unfold partition twoUnif twoSpike
    rw [Fintype.sum_bool]
    simp
    ring
  have hpos : (0 : ℝ) < Real.exp (K / β) / 2 := by positivity
  have hle : Real.exp (K / β) / 2 ≤ (Real.exp (K / β) + 1) / 2 := by linarith
  have hlog : Real.log (Real.exp (K / β) / 2) ≤ Real.log ((Real.exp (K / β) + 1) / 2) :=
    Real.log_le_log hpos hle
  have hval : Real.log (Real.exp (K / β) / 2) = K / β - Real.log 2 := by
    rw [Real.log_div (Real.exp_ne_zero _) (by norm_num), Real.log_exp]
  rw [hval] at hlog
  have hmul : β * (K / β - Real.log 2) ≤ β * Real.log ((Real.exp (K / β) + 1) / 2) :=
    mul_le_mul_of_nonneg_left hlog hβ.le
  have hsimp : β * (K / β - Real.log 2) = K - β * Real.log 2 := by
    field_simp
  unfold freeEnergy
  rw [hZ]
  linarith [hmul, hsimp]

/-- **Sharpness of the reward-hacking budget.**  For every perturbation size `K ≥ 0` and every
tolerance `ε > 0` there is an instance (a KL temperature, an SFT reference and two reward models
at sup-norm distance at most `K`) whose alignment values differ by more than `K − ε`. -/
theorem freeEnergy_lipschitz_sharp {K ε : ℝ} (hK : 0 ≤ K) (hε : 0 < ε) :
    ∃ (β : ℝ) (p r s : Bool → ℝ), 0 < β ∧ IsPosDist p ∧ (∀ y, |r y - s y| ≤ K) ∧
      K - ε < |freeEnergy β r p - freeEnergy β s p| := by
  refine ⟨ε / 2, twoUnif, fun _ => (0 : ℝ), twoSpike K, by linarith, twoUnif_isPosDist,
    fun y => ?_, ?_⟩
  · cases y <;> simp [twoSpike, abs_of_nonneg, hK]
  · have hlog2 : Real.log 2 ≤ 1 := by
      have := Real.log_le_sub_one_of_pos (x := 2) (by norm_num)
      linarith
    have hge := freeEnergy_twoSpike_ge (β := ε / 2) (K := K) (by linarith)
    have hsmall : (ε / 2) * Real.log 2 ≤ ε / 2 := by nlinarith [Real.log_nonneg (by norm_num : (1:ℝ) ≤ 2)]
    rw [freeEnergy_zero_reward]
    have hbound : K - ε / 2 ≤ freeEnergy (ε / 2) (twoSpike K) twoUnif := by linarith
    have habs : freeEnergy (ε / 2) (twoSpike K) twoUnif
        ≤ |0 - freeEnergy (ε / 2) (twoSpike K) twoUnif| := by
      rw [zero_sub, abs_neg]
      exact le_abs_self _
    linarith

/-- No constant smaller than `1` can bound the change of the alignment value by the sup-norm
change of the reward model. -/
theorem no_better_lipschitz_constant {c : ℝ} (hc : c < 1) :
    ¬ (∀ (Ω : Type) (_ : Fintype Ω) (_ : Nonempty Ω) (β K : ℝ) (p r s : Ω → ℝ),
        0 < β → IsPosDist p → (∀ y, |r y - s y| ≤ K) →
        |freeEnergy β r p - freeEnergy β s p| ≤ c * K) := by
  intro h
  obtain ⟨β, p, r, s, hβ, hp, hK, hgt⟩ :=
    freeEnergy_lipschitz_sharp (K := 1) (ε := (1 - c) / 2) (by norm_num) (by linarith)
  have hle := h Bool inferInstance inferInstance β 1 p r s hβ hp hK
  rw [mul_one] at hle
  linarith


/-! ## Reference-weighted norms do not control reward hacking

The sup-norm bound `freeEnergy_lipschitz` implies, trivially, the same bound for every norm
dominating the sup-norm (e.g. the unweighted `ℓ²` norm).  It fails badly for the *reference
weighted* energy `‖f‖²_{L²(p)} = ∑ p y f y ^ 2`, which discounts responses the SFT model rarely
emits: those are exactly the responses a corrupted reward model exploits.
-/

namespace Sharp

/-- The `δ`-biased reference policy on the two-response space. -/
noncomputable def biasedRef (δ : ℝ) : Bool → ℝ := fun b => if b then δ else 1 - δ

theorem biasedRef_isPosDist {δ : ℝ} (h0 : 0 < δ) (h1 : δ < 1) : IsPosDist (biasedRef δ) := by
  refine ⟨fun y => ?_, ?_⟩
  · cases y <;> simp [biasedRef] <;> linarith
  · simp [biasedRef]

theorem freeEnergy_zero_biased {β δ : ℝ} (h0 : 0 < δ) (h1 : δ < 1) :
    freeEnergy β (fun _ => (0 : ℝ)) (biasedRef δ) = 0 := by
  have hZ : partition β (fun _ => (0 : ℝ)) (biasedRef δ) = 1 := by
    unfold partition
    simpa using (biasedRef_isPosDist h0 h1).2
  unfold freeEnergy
  rw [hZ, Real.log_one, mul_zero]

theorem freeEnergy_spike_biased_ge {β δ : ℝ} (hβ : 0 < β) (h0 : 0 < δ) (h1 : δ < 1) :
    1 + β * Real.log δ ≤ freeEnergy β (twoSpike 1) (biasedRef δ) := by
  have hZ : partition β (twoSpike 1) (biasedRef δ) = δ * Real.exp (1 / β) + (1 - δ) := by
    unfold partition biasedRef twoSpike
    rw [Fintype.sum_bool]
    simp
  have hpos : (0 : ℝ) < δ * Real.exp (1 / β) := by positivity
  have hle : δ * Real.exp (1 / β) ≤ δ * Real.exp (1 / β) + (1 - δ) := by linarith
  have hlog := Real.log_le_log hpos hle
  have hval : Real.log (δ * Real.exp (1 / β)) = Real.log δ + 1 / β := by
    rw [Real.log_mul (ne_of_gt h0) (Real.exp_ne_zero _), Real.log_exp]
  rw [hval] at hlog
  have hmul : β * (Real.log δ + 1 / β) ≤ β * Real.log (δ * Real.exp (1 / β) + (1 - δ)) :=
    mul_le_mul_of_nonneg_left hlog hβ.le
  have hsimp : β * (Real.log δ + 1 / β) = 1 + β * Real.log δ := by
    field_simp
    ring
  unfold freeEnergy
  rw [hZ]
  linarith [hmul, hsimp]

end Sharp

/-- **Reference-weighted energy cannot bound reward hacking.**  For every constant `C` there is
an instance in which the alignment value moves by more than `C` times the `L²(p)` distance
between the two reward models: the sup-norm in `freeEnergy_lipschitz` cannot be replaced by any
reference-weighted quadratic norm, uniformly in the reference policy. -/
theorem no_reference_weighted_bound (C : ℝ) :
    ∃ (β : ℝ) (p r s : Bool → ℝ), 0 < β ∧ IsPosDist p ∧
      C * Real.sqrt (∑ y, p y * (r y - s y) ^ 2)
        < |freeEnergy β r p - freeEnergy β s p| := by
  -- pick a reference bias `δ` small enough that `C √δ ≤ 1/4`
  set δ : ℝ := min (1 / 2) (1 / (16 * (C ^ 2 + 1))) with hδ_def
  have hC1 : (0 : ℝ) < C ^ 2 + 1 := by positivity
  have hδ0 : 0 < δ := lt_min (by norm_num) (by positivity)
  have hδ1 : δ < 1 := lt_of_le_of_lt (min_le_left _ _) (by norm_num)
  have hδC : δ ≤ 1 / (16 * (C ^ 2 + 1)) := min_le_right _ _
  -- and a temperature `β` small enough that the value gap is at least `1/2`
  set L : ℝ := -Real.log δ with hL_def
  have hLpos : 0 ≤ L := by
    have : Real.log δ ≤ 0 := Real.log_nonpos hδ0.le hδ1.le
    simpa [hL_def] using this
  set β : ℝ := 1 / (2 * L + 2) with hβ_def
  have hβpos : 0 < β := by
    apply div_pos one_pos
    linarith
  have hβL : β * L ≤ 1 / 2 := by
    have h2 : (0 : ℝ) < 2 * L + 2 := by linarith
    rw [hβ_def, div_mul_eq_mul_div, one_mul, div_le_iff₀ h2]
    linarith
  refine ⟨β, Sharp.biasedRef δ, fun _ => (0 : ℝ), twoSpike 1, hβpos,
    Sharp.biasedRef_isPosDist hδ0 hδ1, ?_⟩
  -- the reference-weighted distance is exactly `√δ`
  have hnorm : ∑ y, Sharp.biasedRef δ y * ((0 : ℝ) - twoSpike 1 y) ^ 2 = δ := by
    unfold Sharp.biasedRef twoSpike
    rw [Fintype.sum_bool]
    norm_num
  rw [hnorm]
  -- bound the left-hand side by `1/4`
  have hCle : C ≤ Real.sqrt (C ^ 2 + 1) := by
    have h1 : C ≤ |C| := le_abs_self C
    have h2 : |C| = Real.sqrt (C ^ 2) := (Real.sqrt_sq_eq_abs C).symm
    have h3 : Real.sqrt (C ^ 2) ≤ Real.sqrt (C ^ 2 + 1) :=
      Real.sqrt_le_sqrt (by linarith)
    linarith [h2 ▸ h1]
  have hsqrtδ : Real.sqrt δ * Real.sqrt (C ^ 2 + 1) ≤ 1 / 4 := by
    have hprod : Real.sqrt δ * Real.sqrt (C ^ 2 + 1) = Real.sqrt (δ * (C ^ 2 + 1)) :=
      (Real.sqrt_mul hδ0.le _).symm
    have hle : δ * (C ^ 2 + 1) ≤ 1 / 16 := by
      rw [← le_div_iff₀ hC1]
      calc δ ≤ 1 / (16 * (C ^ 2 + 1)) := hδC
        _ = (1 / 16) / (C ^ 2 + 1) := by field_simp
    have : Real.sqrt (δ * (C ^ 2 + 1)) ≤ Real.sqrt (1 / 16) := Real.sqrt_le_sqrt hle
    rw [show (1 / 16 : ℝ) = (1 / 4) ^ 2 by norm_num,
      Real.sqrt_sq (by norm_num : (0:ℝ) ≤ 1 / 4)] at this
    linarith [hprod ▸ this]
  have hleft : C * Real.sqrt δ ≤ 1 / 4 := by
    have hs : 0 ≤ Real.sqrt δ := Real.sqrt_nonneg δ
    nlinarith [mul_le_mul_of_nonneg_right hCle hs, hsqrtδ]
  -- bound the right-hand side from below by `1/2`
  have hge := Sharp.freeEnergy_spike_biased_ge (β := β) (δ := δ) hβpos hδ0 hδ1
  have hlogδ : β * Real.log δ = -(β * L) := by rw [hL_def]; ring
  have hhalf : (1:ℝ) / 2 ≤ freeEnergy β (twoSpike 1) (Sharp.biasedRef δ) := by
    rw [hlogδ] at hge
    linarith
  rw [Sharp.freeEnergy_zero_biased hδ0 hδ1, zero_sub, abs_neg]
  have habs : freeEnergy β (twoSpike 1) (Sharp.biasedRef δ)
      ≤ |freeEnergy β (twoSpike 1) (Sharp.biasedRef δ)| := le_abs_self _
  linarith

end RLHF