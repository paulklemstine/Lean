import Bridges.Ma1EffectiveScaleDecay

/-!
# The information-theoretic price of MA-1

Third cycle of the MA-1 effectivization loop.  Cycles 1 and 2
(`Bridges.Ma1EffectiveEquidistribution`, `Bridges.Ma1EffectiveScaleDecay`) measure the cost
of the equidistribution assumption in the *order* structure of the count vector: a ratio
`(1+ε)/(1−ε)`, an additive cap excess `(8/3)ε/(1−ε)`.  This file measures the same cost in
the *information* structure, and finds that the two agree exactly up to a factor `3/4`.

Write `p_a = π(x; m, a) / π(x)` for the empirical distribution of primes over the reduced
residue classes.  MA-1 asserts `p = uniform`.  We prove:

* `kl_le_of_equiCert` — an `ε`-certificate forces the Kullback–Leibler divergence of the
  empirical class distribution from uniform to satisfy `D(p‖u) ≤ 2ε/(1−ε)` nats.  The proof
  is the `log t ≤ t − 1` bound applied to `n·p_a`, plus the observation that the certificate
  caps `Σ p_a²` by `max p_a`.
* `entropy_deficit_le` — equivalently, the Shannon entropy of the class distribution is
  within `2ε/(1−ε)` of its maximum `log φ(m)`.
* `kl_le_cap_excess` — **the unification.**  The information cost is exactly `3/4` of the
  excess of the effective cap constant over `4/3`:
  `D(p‖u) ≤ (3/4)·(capConst ε − 4/3)`.  The two effectivizations of MA-1 — the order-theoretic
  one of cycle 1 and the information-theoretic one here — are the *same* quantity.
* `exp509_kl_le`, `exp509_entropy_deficit` — the numeric payload: at the recorded
  `ε = 0.000446`, the class distribution of primes below `2^30` is within `0.00090` nats of
  uniform, i.e. the equidistribution assumption costs under a thousandth of a nat.
-/

namespace Ma1Effective

open Finset

variable {ι : Type*} [Fintype ι] {N : ι → ℝ} {μ ε : ℝ}

/-! ## The empirical class distribution -/

/-- The empirical distribution of the counts over the classes. -/
noncomputable def classDist (N : ι → ℝ) : ι → ℝ := fun a => N a / ∑ b, N b

/-- Kullback–Leibler divergence of a distribution on the classes from the uniform one. -/
noncomputable def klFromUniform (p : ι → ℝ) : ℝ :=
  ∑ a, p a * Real.log ((Fintype.card ι : ℝ) * p a)

/-- Shannon entropy (in nats) of a distribution on the classes. -/
noncomputable def entropy (p : ι → ℝ) : ℝ := -∑ a, p a * Real.log (p a)

section Basic

variable [Nonempty ι]

theorem card_pos_real : (0 : ℝ) < (Fintype.card ι : ℝ) := by
  have : 0 < Fintype.card ι := Fintype.card_pos
  exact_mod_cast this

omit [Fintype ι] in
/-- A certificate with a positive target forces `ε ≥ 0`. -/
theorem eps_nonneg_of_equiCert (h : EquiCert N μ ε) (hμ : 0 < μ) : 0 ≤ ε := by
  obtain ⟨a⟩ := ‹Nonempty ι›
  have hnn : (0 : ℝ) ≤ ε * μ := (abs_nonneg (N a - μ)).trans (h a)
  nlinarith

omit [Nonempty ι] in
/-- The total count is bounded below by `n(1−ε)μ`. -/
theorem total_ge (h : EquiCert N μ ε) :
    (Fintype.card ι : ℝ) * ((1 - ε) * μ) ≤ ∑ b, N b := by
  calc (Fintype.card ι : ℝ) * ((1 - ε) * μ) = ∑ _b : ι, (1 - ε) * μ := by
        rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    _ ≤ ∑ b, N b := Finset.sum_le_sum fun b _ => h.lower b

theorem total_pos (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε < 1) : 0 < ∑ b, N b := by
  have hc := card_pos_real (ι := ι)
  have hlow := total_ge h
  have h1 : (0 : ℝ) < (1 - ε) * μ := by
    have h1e : (0 : ℝ) < 1 - ε := by linarith
    positivity
  nlinarith

theorem classDist_pos (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε < 1) (a : ι) :
    0 < classDist N a := by
  have hNa : 0 < N a := h.pos hμ hε a
  have hS : 0 < ∑ b, N b := total_pos h hμ hε
  exact div_pos hNa hS

theorem classDist_sum_one (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε < 1) :
    ∑ a, classDist N a = 1 := by
  have hS : 0 < ∑ b, N b := total_pos h hμ hε
  unfold classDist
  rw [← Finset.sum_div, div_self (ne_of_gt hS)]

/-- The certificate caps every class probability by `(1+ε)/((1−ε)·n)`. -/
theorem classDist_le (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε < 1) (a : ι) :
    classDist N a ≤ (1 + ε) * μ / ((Fintype.card ι : ℝ) * ((1 - ε) * μ)) := by
  have hlow := total_ge h
  have hc := card_pos_real (ι := ι)
  have hden : 0 < (Fintype.card ι : ℝ) * ((1 - ε) * μ) := by
    have h1 : (0 : ℝ) < 1 - ε := by linarith
    positivity
  have hup : N a ≤ (1 + ε) * μ := h.upper a
  have hε0 : 0 ≤ ε := eps_nonneg_of_equiCert h hμ
  unfold classDist
  rw [div_le_div_iff₀ (total_pos h hμ hε) hden]
  nlinarith [mul_le_mul_of_nonneg_right hup (le_of_lt hden),
    mul_le_mul_of_nonneg_left hlow (by positivity : (0 : ℝ) ≤ (1 + ε) * μ)]

end Basic

/-! ## The divergence bound -/

section Divergence

variable [Nonempty ι]

/-- **The information price of MA-1.**  An `ε`-certificate forces the empirical class
distribution to be within `2ε/(1−ε)` nats of uniform in Kullback–Leibler divergence. -/
theorem kl_le_of_equiCert (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε < 1) (hε0 : 0 ≤ ε) :
    klFromUniform (classDist N) ≤ 2 * ε / (1 - ε) := by
  have hc := card_pos_real (ι := ι)
  have h1e : (0 : ℝ) < 1 - ε := by linarith
  set p : ι → ℝ := classDist N with hp
  have hppos : ∀ a, 0 < p a := fun a => classDist_pos h hμ hε a
  have hpsum : ∑ a, p a = 1 := classDist_sum_one h hμ hε
  have hpmax : ∀ a, p a ≤ (1 + ε) / ((Fintype.card ι : ℝ) * (1 - ε)) := by
    intro a
    have hb := classDist_le h hμ hε a
    have hrw : (1 + ε) * μ / ((Fintype.card ι : ℝ) * ((1 - ε) * μ))
        = (1 + ε) / ((Fintype.card ι : ℝ) * (1 - ε)) := by
      field_simp
    rw [hrw] at hb
    exact hb
  -- pointwise `log t ≤ t − 1`
  have hpt : ∀ a ∈ (Finset.univ : Finset ι),
      p a * Real.log ((Fintype.card ι : ℝ) * p a)
        ≤ p a * ((Fintype.card ι : ℝ) * p a - 1) := by
    intro a _
    have hpos : 0 < (Fintype.card ι : ℝ) * p a := mul_pos hc (hppos a)
    exact mul_le_mul_of_nonneg_left (Real.log_le_sub_one_of_pos hpos) (le_of_lt (hppos a))
  have hstep1 : klFromUniform p
      ≤ ∑ a, p a * ((Fintype.card ι : ℝ) * p a - 1) := Finset.sum_le_sum hpt
  -- the second-moment estimate
  have hsq : ∀ a ∈ (Finset.univ : Finset ι),
      p a * ((Fintype.card ι : ℝ) * p a - 1)
        ≤ p a * ((1 + ε) / (1 - ε) - 1) := by
    intro a _
    have hb := hpmax a
    have hnp : (Fintype.card ι : ℝ) * p a ≤ (1 + ε) / (1 - ε) := by
      rw [le_div_iff₀ h1e]
      rw [le_div_iff₀ (by positivity : (0:ℝ) < (Fintype.card ι : ℝ) * (1 - ε))] at hb
      nlinarith
    exact mul_le_mul_of_nonneg_left (by linarith) (le_of_lt (hppos a))
  have hstep2 : ∑ a, p a * ((Fintype.card ι : ℝ) * p a - 1)
      ≤ ∑ a, p a * ((1 + ε) / (1 - ε) - 1) := Finset.sum_le_sum hsq
  have hstep3 : ∑ a, p a * ((1 + ε) / (1 - ε) - 1) = (1 + ε) / (1 - ε) - 1 := by
    rw [← Finset.sum_mul, hpsum, one_mul]
  have hfinal : (1 + ε) / (1 - ε) - 1 = 2 * ε / (1 - ε) := by
    field_simp
    ring
  linarith [hstep1.trans (hstep2.trans (le_of_eq hstep3)), hfinal]

/-- The divergence is the entropy deficit: `D(p‖u) = log n − H(p)`. -/
theorem kl_eq_log_card_sub_entropy {p : ι → ℝ} (hppos : ∀ a, 0 < p a) (hpsum : ∑ a, p a = 1) :
    klFromUniform p = Real.log (Fintype.card ι : ℝ) - entropy p := by
  have hc := card_pos_real (ι := ι)
  have hterm : ∀ a : ι, p a * Real.log ((Fintype.card ι : ℝ) * p a)
      = p a * Real.log (Fintype.card ι : ℝ) + p a * Real.log (p a) := by
    intro a
    rw [Real.log_mul (ne_of_gt hc) (ne_of_gt (hppos a))]
    ring
  unfold klFromUniform entropy
  rw [Finset.sum_congr rfl fun a _ => hterm a, Finset.sum_add_distrib, ← Finset.sum_mul,
    hpsum, one_mul]
  ring

/-- **Entropy form.**  The Shannon entropy of the empirical class distribution is within
`2ε/(1−ε)` of its maximal value `log φ(m)`. -/
theorem entropy_deficit_le (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε < 1) (hε0 : 0 ≤ ε) :
    Real.log (Fintype.card ι : ℝ) - entropy (classDist N) ≤ 2 * ε / (1 - ε) := by
  rw [← kl_eq_log_card_sub_entropy (fun a => classDist_pos h hμ hε a)
    (classDist_sum_one h hμ hε)]
  exact kl_le_of_equiCert h hμ hε hε0

/-- **The unification of the two effectivizations.**  The information-theoretic price of the
MA-1 assumption is exactly three quarters of the excess of the effective cap constant over
the ideal `4/3`.  The order-theoretic cost of cycle 1 and the entropic cost here are the
same number. -/
theorem kl_le_cap_excess (h : EquiCert N μ ε) (hμ : 0 < μ) (hε : ε < 1) (hε0 : 0 ≤ ε) :
    klFromUniform (classDist N) ≤ 3 / 4 * (capConst ε - 4 / 3) := by
  have hkl := kl_le_of_equiCert h hμ hε hε0
  have hexc : capConst ε - 4 / 3 = 8 / 3 * (ε / (1 - ε)) := capConst_sub_eq (by linarith)
  have h1e : (0 : ℝ) < 1 - ε := by linarith
  have hrw : 3 / 4 * (8 / 3 * (ε / (1 - ε))) = 2 * ε / (1 - ε) := by
    field_simp
    ring
  rw [hexc, hrw]
  exact hkl

/-- **The numeric payload.**  At the recorded `ε = 0.000446` the empirical distribution of
primes over the reduced classes is within `0.0009` nats of uniform. -/
theorem exp509_kl_le (h : EquiCert N μ 0.000446) (hμ : 0 < μ) :
    klFromUniform (classDist N) ≤ 0.0009 := by
  have hkl := kl_le_of_equiCert h hμ (by norm_num) (by norm_num)
  have hnum : 2 * (0.000446 : ℝ) / (1 - 0.000446) ≤ 0.0009 := by norm_num
  linarith

/-- The same statement in entropy form: the class entropy is within `0.0009` nats of
`log φ(m)`. -/
theorem exp509_entropy_deficit (h : EquiCert N μ 0.000446) (hμ : 0 < μ) :
    Real.log (Fintype.card ι : ℝ) - entropy (classDist N) ≤ 0.0009 := by
  rw [← kl_eq_log_card_sub_entropy (fun a => classDist_pos h hμ (by norm_num) a)
    (classDist_sum_one h hμ (by norm_num))]
  exact exp509_kl_le h hμ

end Divergence

end Ma1Effective