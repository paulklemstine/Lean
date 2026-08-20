import Novelty.RLHFPinskerDrift

/-!
# The true alignment drift rate is `β⁻¹`, not `β^{-1/2}`

Domain: Novelty (information theory × asymptotic analysis × alignment theory).

`Novelty.RLHFPinskerDrift` proves the "no-collapse law"
`‖π_β − p‖₁ ≤ √(2 · range(r)/β)`, obtained by combining the self-limiting KL bound
`KL(π_β ‖ p) ≤ range(r)/β` with Pinsker.  Since Pinsker's constant is optimal
(`Novelty.RLHFPinskerSharp`), improving that rate requires improving the *KL* input,
not the Pinsker step.

This file does exactly that, by exploiting the exponential-family structure of the
Gibbs policy rather than only the value of the objective:

* `RLHF.kl_gibbs_le_quadratic` — `KL(π_β ‖ p) ≤ range(r)²/(2β²) · exp(range(r)/β)`,
  a *quadratic* decay in `β⁻¹` (the KL divergence of a tilt is second order in the
  tilt parameter, a fact invisible to the variational argument).
* `RLHF.gibbs_l1_le_quadratic` — hence `‖π_β − p‖₁ ≤ (range(r)/β) · exp(range(r)/(2β))`.
* `RLHF.gibbs_l1_le_two_range_div` — the clean form `‖π_β − p‖₁ ≤ 2 range(r)/β`
  for `β ≥ range(r)`.
* `RLHF.gibbs_l1_ge_two_point` — a matching *lower* bound on a two-point example:
  `‖π_β − p‖₁ ≥ 1/(3β)` for `β ≥ 2`.  So the rate `Θ(β⁻¹)` is exact.

Everything is elementary and `sorry`-free: no differentiation under the sum, only
the pointwise bounds `1 + x ≤ eˣ` and `|eˣ − 1| ≤ |x| e^{|x|}`.
-/

namespace RLHF

open Finset Set Filter Topology

/-! ## 1. Two elementary exponential estimates -/

/-- `|eˣ − 1| ≤ |x| · e^{|x|}` for every real `x`. -/
theorem abs_exp_sub_one_le_mul (x : ℝ) : |Real.exp x - 1| ≤ |x| * Real.exp |x| := by
  rcases le_or_gt 0 x with hx | hx
  · rw [abs_of_nonneg hx]
    have h1 : Real.exp x - 1 ≤ x * Real.exp x := by
      have h := Real.add_one_le_exp (-x)
      have hx' : Real.exp (-x) = (Real.exp x)⁻¹ := Real.exp_neg x
      rw [hx'] at h
      have hpos : 0 < Real.exp x := Real.exp_pos x
      have := mul_le_mul_of_nonneg_left h hpos.le
      rw [mul_add, mul_inv_cancel₀ (ne_of_gt hpos)] at this
      nlinarith
    have h2 : 0 ≤ Real.exp x - 1 := by
      have := Real.one_le_exp hx
      linarith
    rw [abs_of_nonneg h2]
    exact h1
  · rw [abs_of_neg hx]
    have hle : Real.exp x ≤ 1 := Real.exp_le_one_iff.mpr hx.le
    have hge : 1 + x ≤ Real.exp x := Real.add_one_le_exp x |>.trans_eq' (by ring)
    have habs : |Real.exp x - 1| = 1 - Real.exp x := by
      rw [abs_of_nonpos (by linarith)]; ring
    rw [habs]
    have h1 : (1 : ℝ) ≤ Real.exp (-x) := Real.one_le_exp (by linarith)
    nlinarith

/-- Jensen's inequality for the exponential on a finite probability space:
`log 𝔼_p[e^s] ≥ 𝔼_p[s]`. -/
theorem log_partition_ge {Ω : Type*} [Fintype Ω] {p s : Ω → ℝ} (hp : IsPosDist p) :
    ∑ y, p y * s y ≤ Real.log (∑ y, p y * Real.exp (s y)) := by
  set S := ∑ y, p y * s y with hS
  have hpt : ∀ y ∈ (univ : Finset Ω),
      p y * (Real.exp S * (1 + (s y - S))) ≤ p y * Real.exp (s y) := by
    intro y _
    have h1 : Real.exp S * (1 + (s y - S)) ≤ Real.exp S * Real.exp (s y - S) :=
      mul_le_mul_of_nonneg_left (by linarith [Real.add_one_le_exp (s y - S)])
        (Real.exp_pos S).le
    have h2 : Real.exp S * Real.exp (s y - S) = Real.exp (s y) := by
      rw [← Real.exp_add]; ring_nf
    rw [h2] at h1
    exact mul_le_mul_of_nonneg_left h1 (hp.1 y).le
  have hsum := Finset.sum_le_sum hpt
  have hlhs : ∑ y, p y * (Real.exp S * (1 + (s y - S))) = Real.exp S := by
    have : ∀ y, p y * (Real.exp S * (1 + (s y - S)))
        = Real.exp S * (p y * (1 - S)) + Real.exp S * (p y * s y) := by
      intro y; ring
    rw [Finset.sum_congr rfl (fun y _ => this y), Finset.sum_add_distrib,
      ← Finset.mul_sum, ← Finset.mul_sum, ← Finset.sum_mul, hp.2, ← hS]
    ring
  rw [hlhs] at hsum
  have hZpos : 0 < ∑ y, p y * Real.exp (s y) := by
    apply Finset.sum_pos
    · intro y _; have := hp.1 y; positivity
    · exact univ_nonempty_iff.mpr (by
        by_contra h
        simp only [not_nonempty_iff] at h
        have : (0:ℝ) = 1 := by simpa [Finset.univ_eq_empty] using hp.2
        norm_num at this)
  calc S = Real.log (Real.exp S) := (Real.log_exp S).symm
    _ ≤ Real.log (∑ y, p y * Real.exp (s y)) := Real.log_le_log (Real.exp_pos S) hsum

/-! ## 2. The quadratic KL bound for a bounded, centered reward -/

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-- Explicit formula for the KL divergence of the aligned policy against the reference. -/
theorem klDiv_gibbs_eq {β : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) :
    klDiv (gibbsPolicy β r p) p
      = (∑ y, gibbsPolicy β r p y * (r y / β)) - Real.log (partition β r p) := by
  have hZ := partition_pos (β := β) (r := r) hp
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have hterm : ∀ y ∈ (univ : Finset Ω),
      gibbsPolicy β r p y * Real.log (gibbsPolicy β r p y / p y)
        = gibbsPolicy β r p y * (r y / β) - gibbsPolicy β r p y * Real.log (partition β r p) := by
    intro y _
    have hpy := hp.1 y
    have hratio : gibbsPolicy β r p y / p y = Real.exp (r y / β) / partition β r p := by
      unfold gibbsPolicy
      field_simp
    rw [hratio, Real.log_div (Real.exp_ne_zero _) (ne_of_gt hZ), Real.log_exp]
    ring
  rw [klDiv, Finset.sum_congr rfl hterm, Finset.sum_sub_distrib, ← Finset.sum_mul, hg.2, one_mul]

/-- **Quadratic KL bound for a centered reward.**  If `|r| ≤ m` pointwise then
`KL(π_β ‖ p) ≤ 2 (m/β)² e^{2m/β}`.  The point is the *square*: the tilt parameter
enters the divergence quadratically, whereas the variational argument only sees it
linearly. -/
theorem kl_gibbs_le_of_bounded {β m : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hm : ∀ y, |r y| ≤ m) :
    klDiv (gibbsPolicy β r p) p ≤ 2 * (m / β) ^ 2 * Real.exp (2 * (m / β)) := by
  obtain ⟨y₀⟩ := ‹Nonempty Ω›
  have hm0 : 0 ≤ m := le_trans (abs_nonneg (r y₀)) (hm y₀)
  have ha0 : 0 ≤ m / β := by positivity
  have hsb : ∀ y, |r y / β| ≤ m / β := by
    intro y
    rw [abs_div, abs_of_pos hβ]
    gcongr
    exact hm y
  have hZpos := partition_pos (β := β) (r := r) hp
  have hZeq : partition β r p = ∑ y, p y * Real.exp (r y / β) := rfl
  -- Step 1: the KL is the tilted mean minus the log partition function
  have hmean : (∑ y, gibbsPolicy β r p y * (r y / β))
      = (∑ y, p y * (r y / β) * Real.exp (r y / β)) / partition β r p := by
    rw [Finset.sum_div]
    refine Finset.sum_congr rfl fun y _ => ?_
    unfold gibbsPolicy
    ring
  have hkl : klDiv (gibbsPolicy β r p) p
      = (∑ y, p y * (r y / β) * Real.exp (r y / β)) / partition β r p
        - Real.log (partition β r p) := by
    rw [klDiv_gibbs_eq hp, hmean]
  -- Step 2: Jensen's inequality
  have hjensen : (∑ y, p y * (r y / β)) ≤ Real.log (partition β r p) := by
    rw [hZeq]
    exact log_partition_ge hp
  -- Step 3: the covariance bound, quadratic in the tilt
  have hcov : (∑ y, p y * (r y / β) * Real.exp (r y / β))
      - (∑ y, p y * (r y / β)) * partition β r p
      ≤ 2 * (m / β) ^ 2 * Real.exp (m / β) := by
    have hZm1 : partition β r p - 1 = ∑ y, p y * (Real.exp (r y / β) - 1) := by
      have h : ∑ y, p y * (Real.exp (r y / β) - 1)
          = (∑ y, p y * Real.exp (r y / β)) - ∑ y, p y := by
        rw [← Finset.sum_sub_distrib]
        exact Finset.sum_congr rfl fun y _ => by ring
      rw [h, hp.2, hZeq]
    have hsplit : (∑ y, p y * (r y / β) * Real.exp (r y / β))
        - (∑ y, p y * (r y / β)) * partition β r p
        = (∑ y, p y * (r y / β) * (Real.exp (r y / β) - 1))
          - (∑ y, p y * (r y / β)) * (partition β r p - 1) := by
      have h1 : ∑ y, p y * (r y / β) * (Real.exp (r y / β) - 1)
          = (∑ y, p y * (r y / β) * Real.exp (r y / β)) - ∑ y, p y * (r y / β) := by
        rw [← Finset.sum_sub_distrib]
        exact Finset.sum_congr rfl fun y _ => by ring
      rw [h1]; ring
    have hb1 : (∑ y, p y * (r y / β) * (Real.exp (r y / β) - 1))
        ≤ (m / β) ^ 2 * Real.exp (m / β) := by
      have hterm : ∀ y ∈ (univ : Finset Ω),
          p y * (r y / β) * (Real.exp (r y / β) - 1)
            ≤ p y * ((m / β) ^ 2 * Real.exp (m / β)) := by
        intro y _
        have h2 : |Real.exp (r y / β) - 1| ≤ |r y / β| * Real.exp |r y / β| :=
          abs_exp_sub_one_le_mul _
        have h3 : |r y / β| * Real.exp |r y / β| ≤ (m / β) * Real.exp (m / β) :=
          mul_le_mul (hsb y) (Real.exp_le_exp.mpr (hsb y)) (Real.exp_pos _).le ha0
        have h4 : (r y / β) * (Real.exp (r y / β) - 1) ≤ (m / β) ^ 2 * Real.exp (m / β) := by
          refine le_trans (le_abs_self _) ?_
          rw [abs_mul]
          calc |r y / β| * |Real.exp (r y / β) - 1|
              ≤ |r y / β| * ((m / β) * Real.exp (m / β)) :=
                mul_le_mul_of_nonneg_left (h2.trans h3) (abs_nonneg _)
            _ ≤ (m / β) * ((m / β) * Real.exp (m / β)) :=
                mul_le_mul_of_nonneg_right (hsb y) (by positivity)
            _ = (m / β) ^ 2 * Real.exp (m / β) := by ring
        calc p y * (r y / β) * (Real.exp (r y / β) - 1)
            = p y * ((r y / β) * (Real.exp (r y / β) - 1)) := by ring
          _ ≤ p y * ((m / β) ^ 2 * Real.exp (m / β)) :=
              mul_le_mul_of_nonneg_left h4 (hp.1 y).le
      have h := Finset.sum_le_sum hterm
      rwa [← Finset.sum_mul, hp.2, one_mul] at h
    have hS1 : |∑ y, p y * (r y / β)| ≤ m / β := by
      have hterm : ∀ y ∈ (univ : Finset Ω), |p y * (r y / β)| ≤ p y * (m / β) := by
        intro y _
        rw [abs_mul, abs_of_pos (hp.1 y)]
        exact mul_le_mul_of_nonneg_left (hsb y) (hp.1 y).le
      have h := (Finset.abs_sum_le_sum_abs (fun y => p y * (r y / β)) univ).trans
        (Finset.sum_le_sum hterm)
      rwa [← Finset.sum_mul, hp.2, one_mul] at h
    have hZ1 : |partition β r p - 1| ≤ (m / β) * Real.exp (m / β) := by
      rw [hZm1]
      have hterm : ∀ y ∈ (univ : Finset Ω),
          |p y * (Real.exp (r y / β) - 1)| ≤ p y * ((m / β) * Real.exp (m / β)) := by
        intro y _
        rw [abs_mul, abs_of_pos (hp.1 y)]
        have h2 : |Real.exp (r y / β) - 1| ≤ |r y / β| * Real.exp |r y / β| :=
          abs_exp_sub_one_le_mul _
        have h3 : |r y / β| * Real.exp |r y / β| ≤ (m / β) * Real.exp (m / β) :=
          mul_le_mul (hsb y) (Real.exp_le_exp.mpr (hsb y)) (Real.exp_pos _).le ha0
        exact mul_le_mul_of_nonneg_left (h2.trans h3) (hp.1 y).le
      have h := (Finset.abs_sum_le_sum_abs (fun y => p y * (Real.exp (r y / β) - 1)) univ).trans
        (Finset.sum_le_sum hterm)
      rwa [← Finset.sum_mul, hp.2, one_mul] at h
    have hb2 : -((∑ y, p y * (r y / β)) * (partition β r p - 1))
        ≤ (m / β) ^ 2 * Real.exp (m / β) := by
      have habs : |(∑ y, p y * (r y / β)) * (partition β r p - 1)|
          ≤ (m / β) * ((m / β) * Real.exp (m / β)) := by
        rw [abs_mul]
        exact mul_le_mul hS1 hZ1 (abs_nonneg _) ha0
      calc -((∑ y, p y * (r y / β)) * (partition β r p - 1))
          ≤ |(∑ y, p y * (r y / β)) * (partition β r p - 1)| := neg_le_abs _
        _ ≤ (m / β) * ((m / β) * Real.exp (m / β)) := habs
        _ = (m / β) ^ 2 * Real.exp (m / β) := by ring
    rw [hsplit]
    linarith
  -- Step 4: a lower bound on the partition function
  have hZlow : Real.exp (-(m / β)) ≤ partition β r p := by
    have hterm : ∀ y ∈ (univ : Finset Ω),
        p y * Real.exp (-(m / β)) ≤ p y * Real.exp (r y / β) := by
      intro y _
      exact mul_le_mul_of_nonneg_left
        (Real.exp_le_exp.mpr (neg_le_of_abs_le (hsb y))) (hp.1 y).le
    have h := Finset.sum_le_sum hterm
    rw [← Finset.sum_mul, hp.2, one_mul] at h
    rw [hZeq]
    exact h
  -- Combining the four steps
  have hstep : klDiv (gibbsPolicy β r p) p
      ≤ ((∑ y, p y * (r y / β) * Real.exp (r y / β))
          - (∑ y, p y * (r y / β)) * partition β r p) / partition β r p := by
    rw [hkl, sub_div]
    have h1 : (∑ y, p y * (r y / β)) * partition β r p / partition β r p
        = ∑ y, p y * (r y / β) := by field_simp
    rw [h1]
    linarith
  have hdiv : ((∑ y, p y * (r y / β) * Real.exp (r y / β))
      - (∑ y, p y * (r y / β)) * partition β r p) / partition β r p
      ≤ (2 * (m / β) ^ 2 * Real.exp (m / β)) / partition β r p := by
    gcongr
  have hZinv : (2 * (m / β) ^ 2 * Real.exp (m / β)) / partition β r p
      ≤ 2 * (m / β) ^ 2 * Real.exp (2 * (m / β)) := by
    rw [div_le_iff₀ hZpos]
    have hE : (0 : ℝ) < Real.exp (m / β) := Real.exp_pos _
    have hneg : Real.exp (-(m / β)) = (Real.exp (m / β))⁻¹ := Real.exp_neg _
    rw [hneg] at hZlow
    have h2 : Real.exp (m / β) ≤ Real.exp (m / β) ^ 2 * partition β r p := by
      have h3 := mul_le_mul_of_nonneg_left hZlow (le_of_lt (pow_pos hE 2))
      calc Real.exp (m / β) = Real.exp (m / β) ^ 2 * (Real.exp (m / β))⁻¹ := by field_simp
        _ ≤ Real.exp (m / β) ^ 2 * partition β r p := h3
    have hex : Real.exp (2 * (m / β)) = Real.exp (m / β) ^ 2 := by
      rw [← Real.exp_nat_mul]; ring_nf
    rw [hex]
    nlinarith [h2, sq_nonneg (m / β), hE]
  exact hstep.trans (hdiv.trans hZinv)

/-! ## 3. The quadratic drift law for an arbitrary reward -/

/-- **Quadratic KL bound.**  For any reward model,
`KL(π_β ‖ p) ≤ range(r)²/(2β²) · e^{range(r)/β}`.  Compare
`RLHF.kl_gibbs_le_range_div`, which gives only `range(r)/β`: for `β` large this is
a genuine order-of-magnitude improvement. -/
theorem kl_gibbs_le_quadratic {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    klDiv (gibbsPolicy β r p) p
      ≤ (rewardRange r) ^ 2 / (2 * β ^ 2) * Real.exp (rewardRange r / β) := by
  set c : ℝ := (univ.sup' univ_nonempty r + univ.inf' univ_nonempty r) / 2 with hc
  set m : ℝ := rewardRange r / 2 with hm
  set r' : Ω → ℝ := fun y => r y + (-c) with hr'
  have hbound : ∀ y, |r' y| ≤ m := by
    intro y
    have h1 : r y ≤ univ.sup' univ_nonempty r := Finset.le_sup' r (mem_univ y)
    have h2 : univ.inf' univ_nonempty r ≤ r y := Finset.inf'_le r (mem_univ y)
    rw [abs_le]
    constructor <;> · simp only [hr', hm, hc, rewardRange]; linarith
  have hshift : gibbsPolicy β r' p = gibbsPolicy β r p := gibbsPolicy_shift hp
  have hkl := kl_gibbs_le_of_bounded (r := r') hβ hp hbound
  rw [hshift] at hkl
  have hrw : 2 * (m / β) ^ 2 * Real.exp (2 * (m / β))
      = (rewardRange r) ^ 2 / (2 * β ^ 2) * Real.exp (rewardRange r / β) := by
    rw [hm]
    have h1 : 2 * (rewardRange r / 2 / β) ^ 2 = (rewardRange r) ^ 2 / (2 * β ^ 2) := by
      field_simp
    have h2 : 2 * (rewardRange r / 2 / β) = rewardRange r / β := by field_simp
    rw [h1, h2]
  linarith [hrw ▸ hkl]

/-- **Quadratic no-collapse law.**  `‖π_β − p‖₁ ≤ (range(r)/β) · e^{range(r)/(2β)}`. -/
theorem gibbs_l1_le_quadratic {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    l1Dist (gibbsPolicy β r p) p
      ≤ rewardRange r / β * Real.exp (rewardRange r / (2 * β)) := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have h1 := l1Dist_le_sqrt_two_mul_kl hg.isDist hp
  have h2 := kl_gibbs_le_quadratic (r := r) hβ hp
  have h3 : 2 * klDiv (gibbsPolicy β r p) p
      ≤ (rewardRange r / β * Real.exp (rewardRange r / (2 * β))) ^ 2 := by
    have hexp : (Real.exp (rewardRange r / (2 * β))) ^ 2 = Real.exp (rewardRange r / β) := by
      rw [← Real.exp_nat_mul]
      congr 1
      field_simp
      ring
    have hsq : (rewardRange r / β * Real.exp (rewardRange r / (2 * β))) ^ 2
        = (rewardRange r) ^ 2 / β ^ 2 * Real.exp (rewardRange r / β) := by
      rw [mul_pow, hexp, div_pow]
    rw [hsq]
    have hid : 2 * ((rewardRange r) ^ 2 / (2 * β ^ 2) * Real.exp (rewardRange r / β))
        = (rewardRange r) ^ 2 / β ^ 2 * Real.exp (rewardRange r / β) := by
      field_simp
    linarith [mul_le_mul_of_nonneg_left h2 (by norm_num : (0:ℝ) ≤ 2), hid]
  refine h1.trans ?_
  have hnn : 0 ≤ rewardRange r / β * Real.exp (rewardRange r / (2 * β)) := by
    have := rewardRange_nonneg r
    positivity
  calc Real.sqrt (2 * klDiv (gibbsPolicy β r p) p)
      ≤ Real.sqrt ((rewardRange r / β * Real.exp (rewardRange r / (2 * β))) ^ 2) :=
        Real.sqrt_le_sqrt h3
    _ = rewardRange r / β * Real.exp (rewardRange r / (2 * β)) := Real.sqrt_sq hnn

/-- Clean asymptotic form: once the temperature exceeds the reward range, the drift is
at most `2 range(r)/β`. -/
theorem gibbs_l1_le_two_range_div {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hbig : rewardRange r ≤ β) :
    l1Dist (gibbsPolicy β r p) p ≤ 2 * rewardRange r / β := by
  have hR := rewardRange_nonneg r
  have h1 := gibbs_l1_le_quadratic (r := r) hβ hp
  have hhalf : rewardRange r / (2 * β) ≤ 1 / 2 := by
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    linarith
  have hexp : Real.exp (rewardRange r / (2 * β)) ≤ 2 := by
    have h2 : Real.exp (rewardRange r / (2 * β)) ≤ Real.exp (1 / 2) := Real.exp_le_exp.mpr hhalf
    have h3 : Real.exp (1 / 2) ≤ 2 := by
      have hsq : (Real.exp (1 / 2)) ^ 2 = Real.exp 1 := by
        rw [← Real.exp_nat_mul]; norm_num
      nlinarith [Real.exp_one_lt_d9, Real.exp_pos (1 / 2 : ℝ)]
    linarith
  have hmul : rewardRange r / β * Real.exp (rewardRange r / (2 * β))
      ≤ rewardRange r / β * 2 := by
    have : 0 ≤ rewardRange r / β := by positivity
    exact mul_le_mul_of_nonneg_left hexp this
  calc l1Dist (gibbsPolicy β r p) p ≤ rewardRange r / β * Real.exp (rewardRange r / (2 * β)) := h1
    _ ≤ rewardRange r / β * 2 := hmul
    _ = 2 * rewardRange r / β := by ring

/-! ## 4. A matching lower bound: the rate `β⁻¹` is exact

On the two-point space with the uniform reference and the reward `r = 1_{true}`
(so `range(r) = 1`), the aligned policy is `π_β = (e^{1/β}, 1)/(e^{1/β}+1)` and its
drift is `tanh(1/(2β))`, which is bounded below by `1/(3β)`.  Together with
`gibbs_l1_le_two_range_div` this pins the drift rate at `Θ(β⁻¹)`. -/

/-- The uniform reference policy on `Bool`. -/
noncomputable def unifBool : Bool → ℝ := fun _ => 1 / 2

/-- The one-bit reward `r = 1_{true}`. -/
noncomputable def spikeReward : Bool → ℝ := fun b => if b then 1 else 0

theorem unifBool_isPosDist : IsPosDist unifBool := by
  constructor
  · intro b; norm_num [unifBool]
  · simp [unifBool]

theorem rewardRange_spike : rewardRange spikeReward = 1 := by
  simp [rewardRange, spikeReward]

theorem partition_spike {β : ℝ} :
    partition β spikeReward unifBool = (Real.exp (1 / β) + 1) / 2 := by
  simp [partition, unifBool, spikeReward]
  ring

/-- Exact drift of the aligned policy in the two-point model. -/
theorem l1Dist_spike {β : ℝ} (hβ : 0 < β) :
    l1Dist (gibbsPolicy β spikeReward unifBool) unifBool
      = (Real.exp (1 / β) - 1) / (Real.exp (1 / β) + 1) := by
  have hE : (1 : ℝ) ≤ Real.exp (1 / β) := Real.one_le_exp (by positivity)
  have hden : (0 : ℝ) < Real.exp (1 / β) + 1 := by linarith
  have ht : gibbsPolicy β spikeReward unifBool true
      = Real.exp (1 / β) / (Real.exp (1 / β) + 1) := by
    simp [gibbsPolicy, partition_spike, unifBool, spikeReward]
    field_simp
  have hf : gibbsPolicy β spikeReward unifBool false = 1 / (Real.exp (1 / β) + 1) := by
    simp [gibbsPolicy, partition_spike, unifBool, spikeReward]
    field_simp
  have h1 : Real.exp (1 / β) / (Real.exp (1 / β) + 1) - 1 / 2
      = (Real.exp (1 / β) - 1) / (2 * (Real.exp (1 / β) + 1)) := by
    field_simp; ring
  have h2 : 1 / (Real.exp (1 / β) + 1) - 1 / 2
      = -((Real.exp (1 / β) - 1) / (2 * (Real.exp (1 / β) + 1))) := by
    field_simp; ring
  have hnn : 0 ≤ (Real.exp (1 / β) - 1) / (2 * (Real.exp (1 / β) + 1)) :=
    div_nonneg (by linarith) (by linarith)
  simp only [l1Dist, Fintype.sum_bool, ht, hf, unifBool]
  rw [h1, h2, abs_of_nonneg hnn, abs_neg, abs_of_nonneg hnn]
  field_simp
  ring

theorem exp_half_le_two : Real.exp (1 / 2) ≤ 2 := by
  have hsq : (Real.exp (1 / 2)) ^ 2 = Real.exp 1 := by
    rw [← Real.exp_nat_mul]; norm_num
  nlinarith [Real.exp_one_lt_d9, Real.exp_pos (1 / 2 : ℝ)]

/-- **The `β⁻¹` rate is attained.**  In the two-point model the drift is at least
`1/(3β)` for every `β ≥ 2`, while `gibbs_l1_le_two_range_div` bounds it above by
`2/β`.  Hence alignment drift is `Θ(β⁻¹)`, and the `β^{-1/2}` law of
`Novelty.RLHFPinskerDrift` is *not* tight even though Pinsker's constant is. -/
theorem gibbs_l1_ge_two_point {β : ℝ} (hβ : 2 ≤ β) :
    1 / (3 * β) ≤ l1Dist (gibbsPolicy β spikeReward unifBool) unifBool := by
  have hβ0 : 0 < β := by linarith
  rw [l1Dist_spike hβ0]
  have hx : 1 / β ≤ 1 / 2 := by
    rw [div_le_div_iff₀ hβ0 (by norm_num)]; linarith
  have hE1 : 1 / β + 1 ≤ Real.exp (1 / β) := by
    linarith [Real.add_one_le_exp (1 / β)]
  have hE2 : Real.exp (1 / β) ≤ 2 := le_trans (Real.exp_le_exp.mpr hx) exp_half_le_two
  have hden : (0 : ℝ) < Real.exp (1 / β) + 1 := by positivity
  have hinv : (1 / β) * β = 1 := by field_simp
  have h3 : 3 ≤ (Real.exp (1 / β) - 1) * (3 * β) := by
    have h4 := mul_le_mul_of_nonneg_right hE1 (by positivity : (0 : ℝ) ≤ 3 * β)
    nlinarith [hinv]
  rw [div_le_div_iff₀ (by positivity) hden]
  linarith

end RLHF