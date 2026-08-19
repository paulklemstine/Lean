import NumberTheory.RLHFZetaEulerPolicy
import NumberTheory.RLHFTemperatureSpectrum

/-!
# Log-convexity of the RLHF partition function and of truncated Dirichlet series

The partition function `Z(t) = ∑_y p y exp (r y · t)` of a KL-regularized RLHF problem, read
as a function of the *inverse* temperature `t = 1/β`, is a Cauchy–Schwarz object: it is
log-convex.  This file proves that and reads off the arithmetic content.

Main results (all `sorry`-free):

* `RLHF.expSum_sq_le` — `Z((t₁+t₂)/2)² ≤ Z(t₁) Z(t₂)` (midpoint log-convexity, proved by
  Cauchy–Schwarz with the vectors `√p e^{r t_i/2}`).
* `RLHF.partition_sq_le_harmonic` — the same statement in the temperature variable: the
  relevant midpoint of `β₁` and `β₂` is their **harmonic** mean.
* `RLHF.log_partition_midpoint_convex` and `RLHF.freeEnergy_harmonic_le` — the alignment
  value at the harmonic-mean temperature is dominated by the corresponding average of the
  endpoint values: annealing between two KL coefficients can never beat the mean.
* `RLHF.zetaSum_sq_le` and `RLHF.localZeta_sq_le` — the arithmetic instantiation:
  **truncated Dirichlet series are log-convex in the exponent**,
  `ζ_trunc((s₁+s₂)/2)² ≤ ζ_trunc(s₁) ζ_trunc(s₂)`, both globally on the smooth response
  space and factor by factor in the Euler product.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω]

/-! ## 1. Cauchy–Schwarz for exponential sums -/

/-- **Midpoint log-convexity of the exponential sum.**  For a nonnegative weight `p` the
function `t ↦ ∑_y p y exp (r y t)` is log-convex. -/
theorem expSum_sq_le (r p : Ω → ℝ) (hp : ∀ y, 0 ≤ p y) (t₁ t₂ : ℝ) :
    (∑ y, p y * Real.exp (r y * ((t₁ + t₂) / 2))) ^ 2
      ≤ (∑ y, p y * Real.exp (r y * t₁)) * (∑ y, p y * Real.exp (r y * t₂)) := by
  set f : Ω → ℝ := fun y => Real.sqrt (p y) * Real.exp (r y * t₁ / 2) with hf
  set g : Ω → ℝ := fun y => Real.sqrt (p y) * Real.exp (r y * t₂ / 2) with hg
  have hfg : ∀ y, f y * g y = p y * Real.exp (r y * ((t₁ + t₂) / 2)) := by
    intro y
    have hsq : Real.sqrt (p y) * Real.sqrt (p y) = p y := Real.mul_self_sqrt (hp y)
    have hexp : Real.exp (r y * t₁ / 2) * Real.exp (r y * t₂ / 2)
        = Real.exp (r y * ((t₁ + t₂) / 2)) := by
      rw [← Real.exp_add]; ring_nf
    calc f y * g y
        = (Real.sqrt (p y) * Real.sqrt (p y))
            * (Real.exp (r y * t₁ / 2) * Real.exp (r y * t₂ / 2)) := by rw [hf, hg]; ring
      _ = p y * Real.exp (r y * ((t₁ + t₂) / 2)) := by rw [hsq, hexp]
  have hf2 : ∀ y, f y ^ 2 = p y * Real.exp (r y * t₁) := by
    intro y
    have hsq : Real.sqrt (p y) ^ 2 = p y := Real.sq_sqrt (hp y)
    have hexp : Real.exp (r y * t₁ / 2) ^ 2 = Real.exp (r y * t₁) := by
      rw [sq, ← Real.exp_add]; ring_nf
    rw [hf]
    simp only [mul_pow, hsq, hexp]
  have hg2 : ∀ y, g y ^ 2 = p y * Real.exp (r y * t₂) := by
    intro y
    have hsq : Real.sqrt (p y) ^ 2 = p y := Real.sq_sqrt (hp y)
    have hexp : Real.exp (r y * t₂ / 2) ^ 2 = Real.exp (r y * t₂) := by
      rw [sq, ← Real.exp_add]; ring_nf
    rw [hg]
    simp only [mul_pow, hsq, hexp]
  have hCS := Finset.sum_mul_sq_le_sq_mul_sq univ f g
  rw [Finset.sum_congr rfl (fun y _ => hfg y), Finset.sum_congr rfl (fun y _ => hf2 y),
    Finset.sum_congr rfl (fun y _ => hg2 y)] at hCS
  exact hCS

/-- Strict AM–GM for two distinct nonnegative reals. -/
theorem sqrt_mul_lt_mid {u v : ℝ} (hu : 0 ≤ u) (hv : 0 ≤ v) (huv : u ≠ v) :
    Real.sqrt (u * v) < (u + v) / 2 := by
  have hsu : Real.sqrt u ^ 2 = u := Real.sq_sqrt hu
  have hsv : Real.sqrt v ^ 2 = v := Real.sq_sqrt hv
  have hne : Real.sqrt u ≠ Real.sqrt v := by
    intro h
    exact huv (by rw [← hsu, ← hsv, h])
  have hpos : 0 < (Real.sqrt u - Real.sqrt v) ^ 2 := by
    have : Real.sqrt u - Real.sqrt v ≠ 0 := sub_ne_zero.2 hne
    positivity
  rw [Real.sqrt_mul hu]
  nlinarith [hsu, hsv, hpos]

/-- Non-strict AM–GM for two nonnegative reals. -/
theorem sqrt_mul_le_mid {u v : ℝ} (hu : 0 ≤ u) (hv : 0 ≤ v) :
    Real.sqrt (u * v) ≤ (u + v) / 2 := by
  have hsu : Real.sqrt u ^ 2 = u := Real.sq_sqrt hu
  have hsv : Real.sqrt v ^ 2 = v := Real.sq_sqrt hv
  rw [Real.sqrt_mul hu]
  nlinarith [hsu, hsv, sq_nonneg (Real.sqrt u - Real.sqrt v)]

/-- **Strict log-convexity.**  If the reward model is non-constant and the two inverse
temperatures differ, the Cauchy–Schwarz inequality of `expSum_sq_le` is strict.  Together
with `RLHF.strict_improvement` this identifies non-constancy of the reward as the single
non-degeneracy condition behind both the alignment gain and the curvature of the value
curve. -/
theorem expSum_sq_lt {r p : Ω → ℝ} (hp : IsPosDist p) {t₁ t₂ : ℝ} (ht : t₁ ≠ t₂)
    {y₀ z₀ : Ω} (hr : r y₀ ≠ r z₀) :
    (∑ y, p y * Real.exp (r y * ((t₁ + t₂) / 2))) ^ 2
      < (∑ y, p y * Real.exp (r y * t₁)) * (∑ y, p y * Real.exp (r y * t₂)) := by
  have hne : (univ : Finset Ω).Nonempty := ⟨y₀, Finset.mem_univ y₀⟩
  set a : Ω → ℝ := fun y => p y * Real.exp (r y * t₁) with ha
  set b : Ω → ℝ := fun y => p y * Real.exp (r y * t₂) with hb
  have hapos : ∀ y, 0 < a y := by
    intro y
    have hpy := hp.1 y
    show 0 < p y * Real.exp (r y * t₁)
    positivity
  have hbpos : ∀ y, 0 < b y := by
    intro y
    have hpy := hp.1 y
    show 0 < p y * Real.exp (r y * t₂)
    positivity
  set A := ∑ y, a y with hA
  set B := ∑ y, b y with hB
  have hApos : 0 < A := Finset.sum_pos (fun y _ => hapos y) hne
  have hBpos : 0 < B := Finset.sum_pos (fun y _ => hbpos y) hne
  -- a discrepancy exists because `r` is non-constant and `t₁ ≠ t₂`
  have hdisc : ∃ y, a y / A ≠ b y / B := by
    by_contra hcon
    push_neg at hcon
    have hratio : ∀ y, Real.exp (r y * (t₁ - t₂)) = A / B := by
      intro y
      have h := hcon y
      have hpy := hp.1 y
      rw [ha, hb, div_eq_div_iff (ne_of_gt hApos) (ne_of_gt hBpos)] at h
      have hcancel : Real.exp (r y * t₁) * B = Real.exp (r y * t₂) * A := by
        have : p y * (Real.exp (r y * t₁) * B) = p y * (Real.exp (r y * t₂) * A) := by
          rw [← mul_assoc, ← mul_assoc]; exact h
        exact mul_left_cancel₀ (ne_of_gt hpy) this
      rw [mul_sub, Real.exp_sub, div_eq_div_iff (ne_of_gt (Real.exp_pos _)) (ne_of_gt hBpos)]
      linarith [hcancel]
    have h1 := hratio y₀
    have h2 := hratio z₀
    have hEq : r y₀ * (t₁ - t₂) = r z₀ * (t₁ - t₂) := Real.exp_injective (h1.trans h2.symm)
    exact hr (mul_right_cancel₀ (sub_ne_zero.2 ht) hEq)
  obtain ⟨y₁, hy₁⟩ := hdisc
  -- rewrite the midpoint sum as `√(AB)` times a sum of geometric means of probabilities
  have hterm : ∀ y, p y * Real.exp (r y * ((t₁ + t₂) / 2))
      = Real.sqrt (A * B) * Real.sqrt ((a y / A) * (b y / B)) := by
    intro y
    have hprod : A * B * ((a y / A) * (b y / B)) = a y * b y := by
      field_simp
    have hab : a y * b y = (p y * Real.exp (r y * ((t₁ + t₂) / 2))) ^ 2 := by
      rw [ha, hb]
      have : Real.exp (r y * t₁) * Real.exp (r y * t₂)
          = Real.exp (r y * ((t₁ + t₂) / 2)) * Real.exp (r y * ((t₁ + t₂) / 2)) := by
        rw [← Real.exp_add, ← Real.exp_add]; ring_nf
      calc p y * Real.exp (r y * t₁) * (p y * Real.exp (r y * t₂))
          = (p y * p y) * (Real.exp (r y * t₁) * Real.exp (r y * t₂)) := by ring
        _ = (p y * Real.exp (r y * ((t₁ + t₂) / 2))) ^ 2 := by rw [this]; ring
    have hnonneg : 0 ≤ p y * Real.exp (r y * ((t₁ + t₂) / 2)) := by
      have := (hp.1 y).le; positivity
    rw [← Real.sqrt_mul (by positivity), hprod, hab, Real.sqrt_sq hnonneg]
  have hsum_a : ∑ y, a y / A = 1 := by
    rw [← Finset.sum_div, ← hA, div_self (ne_of_gt hApos)]
  have hsum_b : ∑ y, b y / B = 1 := by
    rw [← Finset.sum_div, ← hB, div_self (ne_of_gt hBpos)]
  have hstrict : ∑ y, Real.sqrt ((a y / A) * (b y / B)) < 1 := by
    have hle : ∀ y ∈ (univ : Finset Ω), Real.sqrt ((a y / A) * (b y / B))
        ≤ ((a y / A) + (b y / B)) / 2 :=
      fun y _ => sqrt_mul_le_mid (div_nonneg (hapos y).le hApos.le)
        (div_nonneg (hbpos y).le hBpos.le)
    have hlt : Real.sqrt ((a y₁ / A) * (b y₁ / B)) < ((a y₁ / A) + (b y₁ / B)) / 2 :=
      sqrt_mul_lt_mid (div_nonneg (hapos y₁).le hApos.le)
        (div_nonneg (hbpos y₁).le hBpos.le) hy₁
    have hsum := Finset.sum_lt_sum hle ⟨y₁, Finset.mem_univ y₁, hlt⟩
    have hrhs : ∑ y, ((a y / A) + (b y / B)) / 2 = 1 := by
      rw [← Finset.sum_div, Finset.sum_add_distrib, hsum_a, hsum_b]
      norm_num
    rwa [hrhs] at hsum
  have hZ : ∑ y, p y * Real.exp (r y * ((t₁ + t₂) / 2))
      = Real.sqrt (A * B) * ∑ y, Real.sqrt ((a y / A) * (b y / B)) := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl (fun y _ => hterm y)
  have hsqrt_pos : 0 < Real.sqrt (A * B) := Real.sqrt_pos.2 (by positivity)
  have hZlt : ∑ y, p y * Real.exp (r y * ((t₁ + t₂) / 2)) < Real.sqrt (A * B) := by
    rw [hZ]
    calc Real.sqrt (A * B) * ∑ y, Real.sqrt ((a y / A) * (b y / B))
        < Real.sqrt (A * B) * 1 := by exact mul_lt_mul_of_pos_left hstrict hsqrt_pos
      _ = Real.sqrt (A * B) := mul_one _
  have hZnonneg : 0 ≤ ∑ y, p y * Real.exp (r y * ((t₁ + t₂) / 2)) :=
    Finset.sum_nonneg (fun y _ => by have := (hp.1 y).le; positivity)
  have hsq : (∑ y, p y * Real.exp (r y * ((t₁ + t₂) / 2))) ^ 2 < (Real.sqrt (A * B)) ^ 2 := by
    nlinarith [hZlt, hZnonneg, hsqrt_pos]
  rwa [Real.sq_sqrt (by positivity)] at hsq

/-- **Log-convexity in the harmonic temperature mean.**  If the inverse temperature `1/β` is
the midpoint of `1/β₁` and `1/β₂` (i.e. `β` is the harmonic mean of `β₁` and `β₂`), then
`Z(β)² ≤ Z(β₁) Z(β₂)`. -/
theorem partition_sq_le_harmonic {β β₁ β₂ : ℝ} {r p : Ω → ℝ} (hp : ∀ y, 0 ≤ p y)
    (hmean : β⁻¹ = (β₁⁻¹ + β₂⁻¹) / 2) :
    (partition β r p) ^ 2 ≤ partition β₁ r p * partition β₂ r p := by
  have hrw : ∀ (γ : ℝ), partition γ r p = ∑ y, p y * Real.exp (r y * γ⁻¹) :=
    fun γ => Finset.sum_congr rfl (fun y _ => by rw [div_eq_mul_inv])
  rw [hrw β, hrw β₁, hrw β₂, hmean]
  exact expSum_sq_le r p hp β₁⁻¹ β₂⁻¹

/-- **Strict log-convexity in the temperature variable.**  For distinct positive KL
coefficients and a non-constant reward, the interpolation inequality is strict. -/
theorem partition_sq_lt_harmonic {β β₁ β₂ : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p)
    (hne : β₁ ≠ β₂) {y₀ z₀ : Ω} (hr : r y₀ ≠ r z₀)
    (hmean : β⁻¹ = (β₁⁻¹ + β₂⁻¹) / 2) :
    (partition β r p) ^ 2 < partition β₁ r p * partition β₂ r p := by
  have hrw : ∀ (γ : ℝ), partition γ r p = ∑ y, p y * Real.exp (r y * γ⁻¹) :=
    fun γ => Finset.sum_congr rfl (fun y _ => by rw [div_eq_mul_inv])
  have hinv : β₁⁻¹ ≠ β₂⁻¹ := fun h => hne (by
    rw [← inv_inv β₁, ← inv_inv β₂, h])
  rw [hrw β, hrw β₁, hrw β₂, hmean]
  exact expSum_sq_lt hp hinv hr

/-- The logarithm of the partition function is midpoint convex in the inverse temperature. -/
theorem log_partition_midpoint_convex [Nonempty Ω] {β β₁ β₂ : ℝ} {r p : Ω → ℝ}
    (hp : IsPosDist p) (hmean : β⁻¹ = (β₁⁻¹ + β₂⁻¹) / 2) :
    2 * Real.log (partition β r p)
      ≤ Real.log (partition β₁ r p) + Real.log (partition β₂ r p) := by
  have hZ := partition_pos (β := β) (r := r) hp
  have hZ₁ := partition_pos (β := β₁) (r := r) hp
  have hZ₂ := partition_pos (β := β₂) (r := r) hp
  have hsq := partition_sq_le_harmonic (β := β) (β₁ := β₁) (β₂ := β₂) (r := r) (fun y => (hp.1 y).le) hmean
  have hlog : Real.log ((partition β r p) ^ 2)
      ≤ Real.log (partition β₁ r p * partition β₂ r p) :=
    Real.log_le_log (by positivity) hsq
  rwa [Real.log_pow, Real.log_mul (ne_of_gt hZ₁) (ne_of_gt hZ₂), Nat.cast_ofNat] at hlog

/-- **Annealing inequality.**  Writing `V(β) = β log Z(β)` for the optimal RLHF value, the
value at the harmonic mean temperature obeys `2 V(β)/β ≤ V(β₁)/β₁ + V(β₂)/β₂`: the
*normalized* alignment value is convex in the inverse KL coefficient. -/
theorem freeEnergy_harmonic_le [Nonempty Ω] {β β₁ β₂ : ℝ} {r p : Ω → ℝ} (hβ : 0 < β)
    (hβ₁ : 0 < β₁) (hβ₂ : 0 < β₂) (hp : IsPosDist p) (hmean : β⁻¹ = (β₁⁻¹ + β₂⁻¹) / 2) :
    2 * (freeEnergy β r p / β) ≤ freeEnergy β₁ r p / β₁ + freeEnergy β₂ r p / β₂ := by
  have hkey := log_partition_midpoint_convex (β := β) (β₁ := β₁) (β₂ := β₂) (r := r) hp hmean
  unfold freeEnergy
  rw [mul_comm β (Real.log (partition β r p)), mul_div_assoc, div_self (ne_of_gt hβ),
    mul_comm β₁ (Real.log (partition β₁ r p)), mul_div_assoc, div_self (ne_of_gt hβ₁),
    mul_comm β₂ (Real.log (partition β₂ r p)), mul_div_assoc, div_self (ne_of_gt hβ₂)]
  simpa using hkey

/-! ## 2. Arithmetic instantiation: log-convexity of truncated Dirichlet series -/

variable {A B : ℕ}

/-- Cauchy–Schwarz for the truncated zeta weights. -/
theorem zetaWeight_mid {s₁ s₂ : ℝ} {n : ℕ} (hn : 0 < n) :
    zetaWeight ((s₁ + s₂) / 2) n
      = Real.sqrt (zetaWeight s₁ n) * Real.sqrt (zetaWeight s₂ n) := by
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have h1 : Real.sqrt (zetaWeight s₁ n) = (n : ℝ) ^ (-s₁ / 2) := by
    rw [zetaWeight, Real.sqrt_eq_rpow, ← Real.rpow_mul hnR.le]
    ring_nf
  have h2 : Real.sqrt (zetaWeight s₂ n) = (n : ℝ) ^ (-s₂ / 2) := by
    rw [zetaWeight, Real.sqrt_eq_rpow, ← Real.rpow_mul hnR.le]
    ring_nf
  rw [h1, h2, ← Real.rpow_add hnR, zetaWeight]
  ring_nf

/-- **Log-convexity of the truncated zeta sum.**  The normalizing constant of the aligned
zeta policy is log-convex in the Dirichlet exponent. -/
theorem zetaSum_sq_le {s₁ s₂ : ℝ} {p q : ℕ} (hp : 0 < p) (hq : 0 < q) :
    (zetaSum ((s₁ + s₂) / 2) p q A B) ^ 2 ≤ zetaSum s₁ p q A B * zetaSum s₂ p q A B := by
  set f : Smooth A B → ℝ := fun ab => Real.sqrt (zetaWeight s₁ (smoothVal p q ab)) with hf
  set g : Smooth A B → ℝ := fun ab => Real.sqrt (zetaWeight s₂ (smoothVal p q ab)) with hg
  have hCS := Finset.sum_mul_sq_le_sq_mul_sq univ f g
  have hmid : ∀ ab : Smooth A B, f ab * g ab = zetaWeight ((s₁ + s₂) / 2) (smoothVal p q ab) :=
    fun ab => (zetaWeight_mid (smoothVal_pos hp hq ab)).symm
  have hsq₁ : ∀ ab : Smooth A B, f ab ^ 2 = zetaWeight s₁ (smoothVal p q ab) :=
    fun ab => Real.sq_sqrt (zetaWeight_pos (smoothVal_pos hp hq ab)).le
  have hsq₂ : ∀ ab : Smooth A B, g ab ^ 2 = zetaWeight s₂ (smoothVal p q ab) :=
    fun ab => Real.sq_sqrt (zetaWeight_pos (smoothVal_pos hp hq ab)).le
  rw [Finset.sum_congr rfl (fun ab _ => hmid ab), Finset.sum_congr rfl (fun ab _ => hsq₁ ab),
    Finset.sum_congr rfl (fun ab _ => hsq₂ ab)] at hCS
  exact hCS

/-- **Log-convexity of each Euler factor.**  The local (single prime) partition function is
log-convex in the exponent, so the Euler product of the aligned policy is a product of
log-convex factors. -/
theorem localZeta_sq_le {s₁ s₂ : ℝ} {p : ℕ} (hp : 0 < p) {A : ℕ} :
    (localZeta ((s₁ + s₂) / 2) p A) ^ 2 ≤ localZeta s₁ p A * localZeta s₂ p A := by
  set f : Fin (A + 1) → ℝ := fun a => Real.sqrt (zetaWeight s₁ (p ^ (a : ℕ))) with hf
  set g : Fin (A + 1) → ℝ := fun a => Real.sqrt (zetaWeight s₂ (p ^ (a : ℕ))) with hg
  have hpow : ∀ a : Fin (A + 1), 0 < p ^ (a : ℕ) := fun a => pow_pos hp _
  have hCS := Finset.sum_mul_sq_le_sq_mul_sq univ f g
  have hmid : ∀ a : Fin (A + 1), f a * g a = zetaWeight ((s₁ + s₂) / 2) (p ^ (a : ℕ)) :=
    fun a => (zetaWeight_mid (hpow a)).symm
  have hsq₁ : ∀ a : Fin (A + 1), f a ^ 2 = zetaWeight s₁ (p ^ (a : ℕ)) :=
    fun a => Real.sq_sqrt (zetaWeight_pos (hpow a)).le
  have hsq₂ : ∀ a : Fin (A + 1), g a ^ 2 = zetaWeight s₂ (p ^ (a : ℕ)) :=
    fun a => Real.sq_sqrt (zetaWeight_pos (hpow a)).le
  rw [Finset.sum_congr rfl (fun a _ => hmid a), Finset.sum_congr rfl (fun a _ => hsq₁ a),
    Finset.sum_congr rfl (fun a _ => hsq₂ a)] at hCS
  exact hCS

end RLHF