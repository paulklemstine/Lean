import Tropical.Barrier4FixedWindowOracle

/-!
# Conjecture D: the SET/COST dichotomy and the residue cap `4/3`

Conjecture D asserts that a barrier-4 pipeline factors, `S(Π) = S(R ∘ F) = S(R) · S(F)`, into a
**COST-class** residue filter `F` and a **SET-class** positional stage `R`, with

* `sup_F S(F) = 4/3`, attained at the balanced residue density `θ = 1/2`;
* `S(R) ≤ min (1/μ_eff, 2^k_bits)`.

This file proves all three components and the resulting *class-crossing* statement.

* `residueCost θ = 1 − θ(1−θ)` is exactly the drafted fire-or-silent law of the T1 stratum
  evaluated at its **uninformative point** `P = μ = θ` (`residueCost_eq_master_uninformative`) —
  this is the identity that welds Conjecture D to T1.
* `residue_cap_isGreatest` : `4/3` is the *greatest* residue speedup, attained exactly at
  `θ = 1/2` (`residue_speedup_eq_cap_iff`).  So a COST-class action can never buy more than a
  factor `4/3`.
* `certified_partition_cost_ge` / `partition_speedup_le_card` / `partition_speedup_le_two_pow` :
  a SET-class positional stage that certifies membership in one of `n ≤ 2^k` classes has
  expected cost `∑ mᵢ²  ≥ 1/n`, hence speedup at most `n ≤ 2^k` — the bits cap.  (Proof: Cauchy–
  Schwarz; the bound is attained exactly at the uniform partition.)
* `pipeline_speedup_factorises` : the factorisation `S(R ∘ F) = S(R) · S(F)`.
* `class_crossing` plus the four measured anchors (`anchor_519`, `anchor_691`, `anchor_435`,
  `anchor_291`, verified as exact rationals): each anchor exceeds the residue cap `4/3` yet is
  realised by a legal pair `(S(R), S(F))` with `S(F) = 4/3` and `S(R) ≤ 1/μ`.  Exceeding `4/3`
  is therefore **class-crossing, not cap-breaking**; and no residue filter alone can produce an
  anchor (`anchor_not_residue_realizable`).
-/

namespace Barrier4

open Finset

/-! ## 1. The residue (COST-class) law and its cap -/

/-- Expected cost of a residue filter of density `θ`: with probability `θ` the target lies in the
selected class and the class (measure `θ`) is scanned; otherwise the filter is silent and the
whole space is scanned. -/
def residueCost (theta : ℝ) : ℝ := 1 - theta * (1 - theta)

/-- **The T1 ↔ Conjecture D identity.**  The residue law is the master (fire-or-silent) law at its
uninformative point `P = μ = θ`. -/
theorem residueCost_eq_master_uninformative (theta : ℝ) :
    residueCost theta = costFireOrSilent theta theta := by
  simp only [residueCost, costFireOrSilent]; ring

theorem residueCost_ge_three_quarters (theta : ℝ) : 3 / 4 ≤ residueCost theta := by
  simp only [residueCost]
  nlinarith [sq_nonneg (theta - 1 / 2)]

theorem residueCost_pos (theta : ℝ) : 0 < residueCost theta :=
  lt_of_lt_of_le (by norm_num) (residueCost_ge_three_quarters theta)

/-- **Residue cap.**  No residue filter beats `4/3`. -/
theorem residue_speedup_le_cap (theta : ℝ) : speedup (residueCost theta) ≤ 4 / 3 := by
  have h := residueCost_ge_three_quarters theta
  have hpos := residueCost_pos theta
  unfold speedup
  rw [div_le_div_iff₀ hpos (by norm_num)]
  linarith

theorem residue_speedup_at_half : speedup (residueCost (1 / 2)) = 4 / 3 := by
  unfold speedup residueCost; norm_num

/-- The cap is attained **only** at the balanced density `θ = 1/2`. -/
theorem residue_speedup_eq_cap_iff {theta : ℝ} :
    speedup (residueCost theta) = 4 / 3 ↔ theta = 1 / 2 := by
  constructor
  · intro h
    have hpos := residueCost_pos theta
    have hcost : residueCost theta = 3 / 4 := by
      unfold speedup at h
      field_simp at h
      linarith
    have : (theta - 1 / 2) ^ 2 = 0 := by simp only [residueCost] at hcost; nlinarith
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this
    linarith
  · rintro rfl; exact residue_speedup_at_half

/-- **`4/3` is the greatest residue speedup.** -/
theorem residue_cap_isGreatest :
    IsGreatest (Set.range fun theta : ℝ => speedup (residueCost theta)) (4 / 3) :=
  ⟨⟨1 / 2, residue_speedup_at_half⟩, by
    rintro x ⟨theta, rfl⟩; exact residue_speedup_le_cap theta⟩

/-! ## 2. The SET-class bits cap -/

/-- **Certified-partition cost bound (Cauchy–Schwarz).**  A positional stage that partitions the
space into classes of relative measures `mᵢ` (summing to `1`) and certifies which class contains
the target has expected cost `∑ mᵢ²`, which is at least `1 / n`. -/
theorem certified_partition_cost_ge {ι : Type*} (s : Finset ι) (m : ι → ℝ)
    (hsum : ∑ i ∈ s, m i = 1) :
    1 / (s.card : ℝ) ≤ ∑ i ∈ s, (m i) ^ 2 := by
  have hcard : s.Nonempty := by
    rcases s.eq_empty_or_nonempty with rfl | h
    · simp at hsum
    · exact h
  have hc : (0 : ℝ) < (s.card : ℝ) := by
    exact_mod_cast Finset.card_pos.mpr hcard
  have h := sq_sum_le_card_mul_sum_sq (s := s) (f := m)
  rw [hsum, one_pow] at h
  rw [div_le_iff₀ hc]
  linarith [h]

/-- **The bits cap.**  A positional stage with `n` certified classes has speedup at most `n`. -/
theorem partition_speedup_le_card {ι : Type*} (s : Finset ι) (m : ι → ℝ)
    (hsum : ∑ i ∈ s, m i = 1) (hpos : 0 < ∑ i ∈ s, (m i) ^ 2) :
    speedup (∑ i ∈ s, (m i) ^ 2) ≤ (s.card : ℝ) := by
  have hcard : s.Nonempty := by
    rcases s.eq_empty_or_nonempty with rfl | h
    · simp at hsum
    · exact h
  have hc : (0 : ℝ) < (s.card : ℝ) := by exact_mod_cast Finset.card_pos.mpr hcard
  have h := certified_partition_cost_ge s m hsum
  unfold speedup
  rw [div_le_iff₀ hpos]
  rw [div_le_iff₀ hc] at h
  nlinarith

/-- `k` bits of positional certificate cap the SET-class speedup at `2^k`. -/
theorem partition_speedup_le_two_pow {ι : Type*} (s : Finset ι) (m : ι → ℝ) (k : ℕ)
    (hsum : ∑ i ∈ s, m i = 1) (hpos : 0 < ∑ i ∈ s, (m i) ^ 2) (hk : s.card ≤ 2 ^ k) :
    speedup (∑ i ∈ s, (m i) ^ 2) ≤ 2 ^ k := by
  have h := partition_speedup_le_card s m hsum hpos
  have : (s.card : ℝ) ≤ 2 ^ k := by exact_mod_cast hk
  linarith

/-! ## 3. Factorisation of a pipeline -/

/-- A pipeline `R ∘ F`: the filter retains an expected fraction `cF` of the space, on which the
positional stage then pays its own relative cost `cR`. -/
def pipelineCost (cR cF : ℝ) : ℝ := cR * cF

/-- **Conjecture D, factorisation.**  Speedups multiply along a pipeline. -/
theorem pipeline_speedup_factorises {cR cF : ℝ} (hR : cR ≠ 0) (hF : cF ≠ 0) :
    speedup (pipelineCost cR cF) = speedup cR * speedup cF := by
  unfold speedup pipelineCost
  field_simp

/-- **Sharpness of the bits cap.**  The uniform partition into `n` classes attains it. -/
theorem partition_speedup_uniform_eq_card {n : ℕ} (hn : 0 < n) :
    speedup (∑ _i ∈ Finset.range n, ((n : ℝ)⁻¹) ^ 2) = (n : ℝ) := by
  have hn0 : (0:ℝ) < (n : ℝ) := by exact_mod_cast hn
  have : ∑ _i ∈ Finset.range n, ((n : ℝ)⁻¹) ^ 2 = (n : ℝ)⁻¹ := by
    rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
    field_simp
  rw [this]
  unfold speedup
  rw [one_div, inv_inv]

/-- **Rigidity of the bits cap.**  A certified partition attains the cap `1/n` only if it is
uniform: any imbalance strictly costs speedup. -/
theorem partition_cost_eq_iff_uniform {ι : Type*} (s : Finset ι) (m : ι → ℝ)
    (hsum : ∑ i ∈ s, m i = 1) (hcost : ∑ i ∈ s, (m i) ^ 2 = 1 / (s.card : ℝ)) :
    ∀ i ∈ s, m i = 1 / (s.card : ℝ) := by
  have hcard : s.Nonempty := by
    rcases s.eq_empty_or_nonempty with rfl | h
    · simp at hsum
    · exact h
  have hc : (0 : ℝ) < (s.card : ℝ) := by exact_mod_cast Finset.card_pos.mpr hcard
  have hexp : ∑ i ∈ s, (m i - 1 / (s.card : ℝ)) ^ 2 = 0 := by
    have : ∑ i ∈ s, (m i - 1 / (s.card : ℝ)) ^ 2
        = (∑ i ∈ s, (m i) ^ 2) - 2 / (s.card : ℝ) * (∑ i ∈ s, m i)
          + (s.card : ℝ) * (1 / (s.card : ℝ)) ^ 2 := by
      rw [Finset.sum_congr rfl (fun i _ => by ring :
        ∀ i ∈ s, (m i - 1 / (s.card : ℝ)) ^ 2
          = (m i) ^ 2 - 2 / (s.card : ℝ) * m i + (1 / (s.card : ℝ)) ^ 2)]
      rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, Finset.sum_const,
        nsmul_eq_mul]
    rw [this, hsum, hcost]
    field_simp
    ring
  intro i hi
  have hnonneg : ∀ j ∈ s, 0 ≤ (m j - 1 / (s.card : ℝ)) ^ 2 := fun j _ => sq_nonneg _
  have := (Finset.sum_eq_zero_iff_of_nonneg hnonneg).1 hexp i hi
  have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this
  linarith

/-! ## 4. The measured anchors and class crossing -/

/-- **The positional stage must carry the crossing.**  If a speedup `S` factors as `S(R)·S(F)`
with the COST-class factor obeying its cap `4/3`, then the SET-class factor is at least
`(3/4)·S`.  Together with the positional budget `S(R) ≤ 1/μ` this forces `μ ≤ 4/(3S)`. -/
theorem positional_necessary {S SR SF : ℝ} (hS : S = SR * SF)
    (hSF : SF ≤ 4 / 3) (hSR : 0 ≤ SR) : 3 / 4 * S ≤ SR := by
  nlinarith

theorem mu_le_of_anchor {S SR SF mu : ℝ} (hmu : 0 < mu) (hS : S = SR * SF)
    (hSF : SF ≤ 4 / 3) (hSR : 0 ≤ SR) (hbudget : SR ≤ 1 / mu) (hS0 : 0 < S) :
    mu ≤ 4 / (3 * S) := by
  have h := positional_necessary hS hSF hSR
  have h1 : 3 / 4 * S ≤ 1 / mu := le_trans h hbudget
  rw [le_div_iff₀ (by positivity)]
  rw [le_div_iff₀ hmu] at h1
  linarith

/-- The measured anchors are values of the master (fire-or-silent) law; they are exact
rationals. -/
theorem anchor_519 : speedup (costFireOrSilent (1 / 20) (17 / 20)) = 400 / 77 := by
  unfold speedup costFireOrSilent; norm_num

theorem anchor_691 : speedup (costFireOrSilent (1 / 20) (9003 / 10000)) = 200000 / 28943 := by
  unfold speedup costFireOrSilent; norm_num

theorem anchor_435 : speedup (costFireOrSilent (1 / 20) (8106 / 10000)) = 200000 / 45986 := by
  unfold speedup costFireOrSilent; norm_num

theorem anchor_291 : speedup (costFireOrSilent (1 / 50) (9853 / 10000)) = 500000 / 17203 := by
  unfold speedup costFireOrSilent; norm_num

/-- **Class crossing.**  Any speedup `S` whose *positional residue* `(3/4)·S` fits inside the
positional budget `1/μ` factors as `S = S(R)·S(F)` with the COST-class factor sitting exactly at
its cap `4/3` and the SET-class factor legal.  Exceeding `4/3` is thus never cap-breaking. -/
theorem class_crossing {mu S : ℝ} (hbudget : 3 / 4 * S ≤ 1 / mu) :
    ∃ SR SF : ℝ, S = SR * SF ∧ SF = speedup (residueCost (1 / 2)) ∧ SF = 4 / 3 ∧ SR ≤ 1 / mu := by
  refine ⟨3 / 4 * S, 4 / 3, by ring, residue_speedup_at_half.symm, rfl, hbudget⟩

/-- The `5.19×` anchor crosses the residue cap while staying inside the positional budget. -/
theorem anchor_519_class_crossing :
    4 / 3 < speedup (costFireOrSilent (1 / 20) (17 / 20)) ∧
      3 / 4 * speedup (costFireOrSilent (1 / 20) (17 / 20)) ≤ 1 / (1 / 20 : ℝ) := by
  rw [anchor_519]; norm_num

theorem anchor_691_class_crossing :
    4 / 3 < speedup (costFireOrSilent (1 / 20) (9003 / 10000)) ∧
      3 / 4 * speedup (costFireOrSilent (1 / 20) (9003 / 10000)) ≤ 1 / (1 / 20 : ℝ) := by
  rw [anchor_691]; norm_num

theorem anchor_435_class_crossing :
    4 / 3 < speedup (costFireOrSilent (1 / 20) (8106 / 10000)) ∧
      3 / 4 * speedup (costFireOrSilent (1 / 20) (8106 / 10000)) ≤ 1 / (1 / 20 : ℝ) := by
  rw [anchor_435]; norm_num

theorem anchor_291_class_crossing :
    4 / 3 < speedup (costFireOrSilent (1 / 50) (9853 / 10000)) ∧
      3 / 4 * speedup (costFireOrSilent (1 / 50) (9853 / 10000)) ≤ 1 / (1 / 50 : ℝ) := by
  rw [anchor_291]; norm_num

/-- **No anchor is residue-realisable.**  The COST class alone cannot produce the measured
speedups: every residue filter stays below `4/3 < 5.19`. -/
theorem anchor_not_residue_realizable (theta : ℝ) :
    speedup (residueCost theta) < speedup (costFireOrSilent (1 / 20) (17 / 20)) := by
  have h := residue_speedup_le_cap theta
  rw [anchor_519]
  linarith

/-- **The dichotomy is strict.**  For a *positional* oracle the speedup can be pushed above any
constant (T1), while the residue class is capped at `4/3`: the two classes are genuinely
different resources. -/
theorem set_cost_dichotomy (C : ℝ) :
    (∀ theta : ℝ, speedup (residueCost theta) ≤ 4 / 3) ∧
      ∃ mu P : ℝ, 0 < mu ∧ mu < 1 / 2 ∧ 0 ≤ P ∧ P ≤ 1 ∧ C < speedup (costCert mu P) :=
  ⟨residue_speedup_le_cap, no_constant_cap C⟩

end Barrier4