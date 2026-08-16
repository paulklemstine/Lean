/-
# Depth rigidity, long-context mass decay, and the random-`k` control

Second cycle of the NET-36 formalisation.  The three files
`Probability.AttentionConcentration`, `Probability.AttentionCostLaw` and
`Probability.AttentionTruncationOutput` derived the measured law
`k* = d·ctx/32` from two structural hypotheses (nonexpansive layers, a
scale-free `1/x` attention tail) and certified a separation between the
*mass* knee and the measured *accuracy* knee.  This file closes three of the
conjectures that were left open there.

* **C5 (depth rigidity).**  `layerComp_dist_le_lip` generalises the depth leg
  from nonexpansive layers to `Λ`-Lipschitz layers: the accumulated error is
  `ε · ∑_{i<d} Λ^i`.  Two consequences make the hypothesis falsifiable.
  - `depth_leg_linear_of_near_isometry` : if `Λ ≤ 1 + c/d` (near-isometry at
    the measured scale) the geometric factor is `≤ exp c`, so the law stays
    *linear* in depth — this is the regime the grid reports.
  - `expansive_depth_leg_superlinear` and `expansive_knee_not_linear` : if
    instead `Λ = 1 + x` with a *fixed* `x > 0`, the accumulated error, and
    hence the least feasible top-`k` budget, eventually exceeds `M·d` for
    **every** constant `M`.  So `k* = 4d` cannot survive a uniformly expansive
    stack: the depth leg is a spectral statement, measurable without any
    top-`k` sweep.
* **C3 (long context).**  `mass_at_law_budget_le` : if the effective support
  grows at least linearly in context, `α·ctx ≤ N_eff`, then at the law's own
  budget `k = d·ctx/32` the retained attention *mass* is at most
  `sqrt (d / (32 α))` — a **context-independent** bound below `1/2` as soon as
  `d < 8α`.  `ctx1024_mass_prediction` states the pre-registered numeric form
  of this for the open `d = 4` run.
* **C4 (random-`k` control).**  `sum_powersetCard_mass` and
  `random_mass_average` compute the mass retained by a uniformly random budget
  of `k` positions exactly: on average `k/ctx` of the mass, versus the
  selection bound `sqrt (k/N_eff)`.  `selection_gain_le` bounds the mass
  advantage of selection over the control by `ctx / sqrt (k · N_eff)`, and
  `netB_selection_gain_le` instantiates it at the measured cell
  (`ctx = 512`, `k = 64`, `N_eff = 152.11`): the control can lose at most a
  factor `5.2` of mass, so the reported accuracy gaps are not a mass artefact.
-/

import Mathlib
import Probability.AttentionConcentration
import Probability.AttentionCostLaw

namespace AttentionDepthRigidity

open Finset Filter Topology AttentionConcentration AttentionCostLaw
open scoped NNReal

/-!
## 1.  The depth leg with a general Lipschitz constant (conjecture C5)
-/

variable {X : Type*}

/-- **Depth leg, general Lipschitz constant.**  If every exact layer is
`Λ`-Lipschitz and each truncated layer deviates pointwise by at most `ε ≥ 0`,
then a `d`-layer stack deviates by at most `ε · ∑_{i<d} Λ^i`.  At `Λ = 1` this
is the additive law `d·ε` used in `AttentionCostLaw.layerComp_dist_le_uniform`. -/
theorem layerComp_dist_le_lip [PseudoMetricSpace X] (f g : ℕ → X → X) (L : ℝ≥0)
    (hf : ∀ i, LipschitzWith L (f i)) {ε : ℝ}
    (hε : ∀ i x, dist (g i x) (f i x) ≤ ε) (d : ℕ) (x : X) :
    dist (layerComp g d x) (layerComp f d x) ≤ ε * ∑ i ∈ Finset.range d, (L : ℝ) ^ i := by
  induction d with
  | zero => simp
  | succ n ih =>
      have htri : dist (g n (layerComp g n x)) (f n (layerComp f n x))
          ≤ dist (g n (layerComp g n x)) (f n (layerComp g n x))
            + dist (f n (layerComp g n x)) (f n (layerComp f n x)) :=
        dist_triangle _ _ _
      have h1 : dist (g n (layerComp g n x)) (f n (layerComp g n x)) ≤ ε := hε n _
      have h2 : dist (f n (layerComp g n x)) (f n (layerComp f n x))
          ≤ (L : ℝ) * dist (layerComp g n x) (layerComp f n x) := by
        simpa using (hf n).dist_le_mul (layerComp g n x) (layerComp f n x)
      have h3 : (L : ℝ) * dist (layerComp g n x) (layerComp f n x)
          ≤ (L : ℝ) * (ε * ∑ i ∈ Finset.range n, (L : ℝ) ^ i) :=
        mul_le_mul_of_nonneg_left ih L.coe_nonneg
      have hsum : ε * ∑ i ∈ Finset.range (n + 1), (L : ℝ) ^ i
          = ε + (L : ℝ) * (ε * ∑ i ∈ Finset.range n, (L : ℝ) ^ i) := by
        rw [geom_sum_succ]
        ring
      simp only [layerComp_succ, hsum]
      linarith

/-- A near-isometric stack: `(1 + c/d)^d ≤ exp c`, so the geometric factor over
`d` layers is at most `d · exp c`. -/
theorem geom_sum_le_of_near_isometry {c : ℝ} (hc : 0 ≤ c) {d : ℕ} (hd : 0 < d) :
    ∑ i ∈ Finset.range d, (1 + c / d) ^ i ≤ d * Real.exp c := by
  have hdR : (0 : ℝ) < d := by exact_mod_cast hd
  have hbase : (1 : ℝ) ≤ 1 + c / d := by
    have : 0 ≤ c / d := by positivity
    linarith
  have hstep : (1 : ℝ) + c / d ≤ Real.exp (c / d) := by
    linarith [Real.add_one_le_exp (c / (d : ℝ))]
  have hpow : ∀ i ∈ Finset.range d, (1 + c / d) ^ i ≤ Real.exp c := by
    intro i hi
    have hid : i ≤ d := (Finset.mem_range.mp hi).le
    have h1 : (1 + c / d) ^ i ≤ (1 + c / d) ^ d := pow_le_pow_right₀ hbase hid
    have h2 : (1 + c / d) ^ d ≤ (Real.exp (c / d)) ^ d :=
      pow_le_pow_left₀ (by linarith) hstep d
    have h3 : (Real.exp (c / d)) ^ d = Real.exp c := by
      rw [← Real.exp_nat_mul]
      congr 1
      field_simp
    linarith [h1, h2, h3.le, h3.ge]
  calc ∑ i ∈ Finset.range d, (1 + c / d) ^ i ≤ ∑ _i ∈ Finset.range d, Real.exp c :=
        Finset.sum_le_sum hpow
    _ = d * Real.exp c := by
        rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]

/-- **C5, positive branch.**  A stack whose layers are `(1 + c/d)`-Lipschitz —
"nonexpansive up to `O(1/d)`", the regime the trained models are conjectured to
be in — still obeys an *additive* depth law: the end-to-end truncation error is
at most `exp c` times the nonexpansive bound `d·ε`.  The linear depth leg
`k* = 4d` is therefore robust to a small amount of expansion per layer. -/
theorem depth_leg_linear_of_near_isometry [PseudoMetricSpace X] (f g : ℕ → X → X)
    {c : ℝ} (hc : 0 ≤ c) {d : ℕ} (hd : 0 < d) (L : ℝ≥0) (hL : (L : ℝ) = 1 + c / d)
    (hf : ∀ i, LipschitzWith L (f i))
    {ε : ℝ} (hε0 : 0 ≤ ε) (hε : ∀ i x, dist (g i x) (f i x) ≤ ε) (x : X) :
    dist (layerComp g d x) (layerComp f d x) ≤ Real.exp c * (d * ε) := by
  have h := layerComp_dist_le_lip f g L hf hε d x
  rw [hL] at h
  have hgeom := geom_sum_le_of_near_isometry hc hd
  have : ε * ∑ i ∈ Finset.range d, (1 + c / d) ^ i ≤ ε * (d * Real.exp c) :=
    mul_le_mul_of_nonneg_left hgeom hε0
  calc dist (layerComp g d x) (layerComp f d x)
      ≤ ε * ∑ i ∈ Finset.range d, (1 + c / d) ^ i := h
    _ ≤ ε * (d * Real.exp c) := this
    _ = Real.exp c * (d * ε) := by ring

/-- Gauss' sum, in `ℝ`. -/
private lemma sum_range_cast (d : ℕ) :
    ∑ i ∈ Finset.range d, (i : ℝ) = d * (d - 1) / 2 := by
  induction d with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_range_succ, ih]
      push_cast
      ring

/-- **Quadratic lower bound for an expansive stack.**  For any per-layer
expansion `x ≥ 0`, `∑_{i<d} (1+x)^i ≥ d + x·d·(d-1)/2`. -/
theorem geom_sum_ge_quadratic {x : ℝ} (hx : 0 ≤ x) (d : ℕ) :
    (d : ℝ) + x * ((d : ℝ) * ((d : ℝ) - 1) / 2) ≤ ∑ i ∈ Finset.range d, (1 + x) ^ i := by
  have hterm : ∀ i ∈ Finset.range d, 1 + (i : ℝ) * x ≤ (1 + x) ^ i := by
    intro i _
    exact one_add_mul_le_pow (by linarith) i
  have hsum : ∑ i ∈ Finset.range d, (1 + (i : ℝ) * x) ≤ ∑ i ∈ Finset.range d, (1 + x) ^ i :=
    Finset.sum_le_sum hterm
  have hlhs : ∑ i ∈ Finset.range d, (1 + (i : ℝ) * x)
      = (d : ℝ) + x * ((d : ℝ) * ((d : ℝ) - 1) / 2) := by
    rw [Finset.sum_add_distrib, Finset.sum_const, Finset.card_range, nsmul_eq_mul,
      ← Finset.sum_mul, sum_range_cast]
    ring
  linarith [hsum, hlhs.le, hlhs.ge]

/-- **C5, negative branch.**  If the layers expand by a *fixed* factor `1 + x`
with `x > 0`, the accumulated truncation error grows superlinearly in depth: for
every constant `M` there is a depth beyond which the geometric factor exceeds
`M·d`.  A depth-linear knee is therefore incompatible with uniform expansion. -/
theorem expansive_depth_leg_superlinear {x : ℝ} (hx : 0 < x) (M : ℝ) :
    ∃ D : ℕ, ∀ d : ℕ, D ≤ d → M * d ≤ ∑ i ∈ Finset.range d, (1 + x) ^ i := by
  obtain ⟨D, hD⟩ := exists_nat_gt (1 + 2 * M / x)
  refine ⟨D, fun d hdD => ?_⟩
  have hdR : (1 : ℝ) + 2 * M / x < d := by
    have : (D : ℝ) ≤ (d : ℝ) := by exact_mod_cast hdD
    linarith
  have hd1 : 2 * M / x ≤ (d : ℝ) - 1 := by linarith
  have hdpos : (0 : ℝ) ≤ d := Nat.cast_nonneg d
  have hkey : M * d ≤ (d : ℝ) + x * ((d : ℝ) * ((d : ℝ) - 1) / 2) := by
    have h2 : 2 * M ≤ x * ((d : ℝ) - 1) := by
      rw [div_le_iff₀ hx] at hd1
      linarith
    nlinarith [hdpos, hd1]
  exact le_trans hkey (geom_sum_ge_quadratic hx.le d)

/-- **C5, the falsifiable consequence for the knee.**  Under a Zipf tail of
amplitude `A > 0` over context `ctx > 0` and an end-to-end budget `δ > 0`, if the
layers expand by a fixed factor `1 + x`, `x > 0`, then for every constant `M`
there is a depth beyond which *every* feasible top-`k` budget satisfies
`k ≥ M·d`.  In particular no law of the form `k* = C·d` can hold: a measurement
of per-layer Jacobian norms bounded away from `1` would refute the depth leg
without running a single sweep. -/
theorem expansive_knee_not_linear {A ctx δ x : ℝ} (hA : 0 < A) (hctx : 0 < ctx)
    (hδ : 0 < δ) (hx : 0 < x) (M : ℝ) :
    ∃ D : ℕ, ∀ d : ℕ, D ≤ d → ∀ k : ℕ, 0 < k →
      (∑ i ∈ Finset.range d, (1 + x) ^ i) * zipfTail A ctx k ≤ δ → M * d ≤ k := by
  obtain ⟨D, hD⟩ := expansive_depth_leg_superlinear hx (M * δ / (A * ctx))
  refine ⟨D, fun d hdD k hk hfeas => ?_⟩
  have hkR : (0 : ℝ) < k := by exact_mod_cast hk
  have hG : M * δ / (A * ctx) * d ≤ ∑ i ∈ Finset.range d, (1 + x) ^ i := hD d hdD
  have htail : zipfTail A ctx k = A * ctx / k := rfl
  rw [htail, mul_div_assoc'] at hfeas
  rw [div_le_iff₀ hkR] at hfeas
  -- `G · A · ctx ≤ δ · k`, and `G ≥ M δ d /(A ctx)`
  have hAc : 0 < A * ctx := by positivity
  have h1 : (M * δ / (A * ctx) * d) * (A * ctx) ≤
      (∑ i ∈ Finset.range d, (1 + x) ^ i) * (A * ctx) :=
    mul_le_mul_of_nonneg_right hG hAc.le
  have h2 : (M * δ / (A * ctx) * d) * (A * ctx) = M * d * δ := by
    field_simp
  have h3 : (∑ i ∈ Finset.range d, (1 + x) ^ i) * (A * ctx) ≤ δ * k := hfeas
  have h4 : M * d * δ ≤ δ * k := by linarith [h1, h2.le, h2.ge]
  exact le_of_mul_le_mul_right (by linarith : M * d * δ ≤ (k : ℝ) * δ) hδ

/-!
## 2.  Long context: the mass retained at the law's budget (conjecture C3)
-/

variable {ι : Type*}

/-- **C3, the certified form.**  Suppose the effective support grows at least
linearly with context, `α·ctx ≤ N_eff` (equivalently `collision ≤ 1/(α·ctx)`),
and take the law's own budget, `k ≤ d·ctx/32`.  Then the retained attention
*mass* is at most `sqrt (d / (32 α))`, **independently of the context length**.
At `d = 4, α = 1` this is `≤ 0.354 < 1/2`: at long context the model must be
retaining `≥ 0.98` of its accuracy on less than half of its attention mass. -/
theorem mass_at_law_budget_le (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hp : ∀ i ∈ s, 0 ≤ p i) {α ctx d : ℝ} (hα : 0 < α) (hctx : 0 < ctx) (hd : 0 ≤ d)
    (hcol : collision s p ≤ 1 / (α * ctx)) (hcard : (T.card : ℝ) ≤ d * ctx / 32) :
    ∑ i ∈ T, p i ≤ Real.sqrt (d / (32 * α)) := by
  have hcardnn : (0 : ℝ) ≤ (T.card : ℝ) := Nat.cast_nonneg _
  have hcolnn : 0 ≤ collision s p := collision_nonneg s p
  have hbound : (T.card : ℝ) * collision s p ≤ d / (32 * α) := by
    have h1 : (T.card : ℝ) * collision s p ≤ (d * ctx / 32) * (1 / (α * ctx)) := by
      have := mul_le_mul hcard hcol hcolnn (by positivity)
      exact this
    have h2 : (d * ctx / 32) * (1 / (α * ctx)) = d / (32 * α) := by
      field_simp
    linarith [h1, h2.le, h2.ge]
  calc ∑ i ∈ T, p i ≤ Real.sqrt (T.card * collision s p) := mass_le_sqrt s T p hT hp
    _ ≤ Real.sqrt (d / (32 * α)) := Real.sqrt_le_sqrt hbound

/-- **Pre-registered `ctx = 1024` prediction.**  At `d = 4`, if the effective
support keeps up with context (`N_eff ≥ ctx`, i.e. `collision ≤ 1/ctx`), then at
the predicted knee `k* = 4·1024/32 = 128` the retained attention mass is at most
`0.36` — less than half.  Any run that reports `≥ 0.98` retained accuracy at
`k = 128` therefore certifies a mass/accuracy separation of at least a factor
`2.7`, and a run reporting more than `0.36` retained *mass* there refutes the
linear growth of `N_eff`. -/
theorem ctx1024_mass_prediction (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hp : ∀ i ∈ s, 0 ≤ p i) (hcol : collision s p ≤ 1 / (1 * 1024 : ℝ))
    (hcard : T.card ≤ 128) :
    ∑ i ∈ T, p i ≤ 0.36 := by
  have hcardR : (T.card : ℝ) ≤ 4 * 1024 / 32 := by
    have : (T.card : ℝ) ≤ 128 := by exact_mod_cast hcard
    linarith
  have h := mass_at_law_budget_le s T p hT hp (α := 1) (ctx := 1024) (d := 4)
    (by norm_num) (by norm_num) (by norm_num) hcol hcardR
  refine h.trans ?_
  have h1 : Real.sqrt (4 / (32 * 1) : ℝ) ≤ Real.sqrt ((0.36 : ℝ) ^ 2) := by
    apply Real.sqrt_le_sqrt; norm_num
  rwa [Real.sqrt_sq (by norm_num : (0:ℝ) ≤ 0.36)] at h1

/-- **Non-vacuity of the `ctx = 1024` prediction.**  The hypotheses of
`ctx1024_mass_prediction` are realised by the uniform attention row over `1024`
positions: its collision mass is exactly `1/1024`, any `128` of its positions
carry mass `1/8`, and `1/8 ≤ 0.36` as the theorem asserts. -/
theorem uniform_row_realises_ctx1024_hypotheses :
    collision (Finset.univ : Finset (Fin 1024)) (fun _ => (1 : ℝ) / 1024)
        ≤ 1 / (1 * 1024 : ℝ) ∧
      ∀ T : Finset (Fin 1024), #T = 128 →
        ∑ _i ∈ T, (1 : ℝ) / 1024 = 1 / 8 := by
  constructor
  · have : collision (Finset.univ : Finset (Fin 1024)) (fun _ => (1 : ℝ) / 1024)
        = 1 / 1024 := by
      unfold collision
      rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      norm_num
    rw [this]
    norm_num
  · intro T hT
    rw [Finset.sum_const, hT, nsmul_eq_mul]
    norm_num

/-!
## 3.  The random-`k` control: exact mean retained mass (conjecture C4)
-/

section RandomControl

/-- The `k+1`-subsets of `s` containing a fixed `i ∈ s` are in bijection with the
`k`-subsets of `s.erase i`; hence there are `C(#s - 1, k)` of them. -/
theorem card_filter_mem_powersetCard [DecidableEq ι] (s : Finset ι) (i : ι) (hi : i ∈ s) (k : ℕ) :
    #{T ∈ s.powersetCard (k + 1) | i ∈ T} = (#s - 1).choose k := by
  have hbij : #{T ∈ s.powersetCard (k + 1) | i ∈ T} = #((s.erase i).powersetCard k) := by
    refine Finset.card_bij' (fun T _ => T.erase i) (fun U _ => insert i U) ?_ ?_ ?_ ?_
    · intro T hT
      simp only [Finset.mem_filter, Finset.mem_powersetCard] at hT
      obtain ⟨⟨hTs, hTcard⟩, hiT⟩ := hT
      refine Finset.mem_powersetCard.mpr ⟨?_, ?_⟩
      · intro j hj
        have hj' := Finset.mem_of_mem_erase hj
        exact Finset.mem_erase.mpr ⟨Finset.ne_of_mem_erase hj, hTs hj'⟩
      · rw [Finset.card_erase_of_mem hiT, hTcard]
        rfl
    · intro U hU
      simp only [Finset.mem_powersetCard] at hU
      obtain ⟨hUs, hUcard⟩ := hU
      have hiU : i ∉ U := fun h => (Finset.mem_erase.mp (hUs h)).1 rfl
      refine Finset.mem_filter.mpr ⟨Finset.mem_powersetCard.mpr ⟨?_, ?_⟩, Finset.mem_insert_self _ _⟩
      · intro j hj
        rcases Finset.mem_insert.mp hj with rfl | hj'
        · exact hi
        · exact Finset.mem_of_mem_erase (hUs hj')
      · rw [Finset.card_insert_of_notMem hiU, hUcard]
    · intro T hT
      simp only [Finset.mem_filter] at hT
      exact Finset.insert_erase hT.2
    · intro U hU
      simp only [Finset.mem_powersetCard] at hU
      have hiU : i ∉ U := fun h => (Finset.mem_erase.mp (hU.1 h)).1 rfl
      exact Finset.erase_insert hiU
  rw [hbij, Finset.card_powersetCard, Finset.card_erase_of_mem hi]

/-- **Total mass over all `k+1`-subsets.**  Double counting: each position is
contained in `C(#s - 1, k)` of the `(k+1)`-subsets. -/
theorem sum_powersetCard_mass [DecidableEq ι] (s : Finset ι) (p : ι → ℝ) (k : ℕ) :
    ∑ T ∈ s.powersetCard (k + 1), ∑ i ∈ T, p i
      = ((#s - 1).choose k : ℝ) * ∑ i ∈ s, p i := by
  have hstep : ∀ T ∈ s.powersetCard (k + 1),
      ∑ i ∈ T, p i = ∑ i ∈ s, if i ∈ T then p i else 0 := by
    intro T hT
    have hTs : T ⊆ s := (Finset.mem_powersetCard.mp hT).1
    rw [Finset.sum_ite_mem, Finset.inter_eq_right.mpr hTs]
  rw [Finset.sum_congr rfl hstep, Finset.sum_comm]
  have hinner : ∀ i ∈ s,
      (∑ T ∈ s.powersetCard (k + 1), if i ∈ T then p i else 0)
        = ((#s - 1).choose k : ℝ) * p i := by
    intro i hi
    rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const_zero, add_zero, nsmul_eq_mul,
      card_filter_mem_powersetCard s i hi k]
  rw [Finset.sum_congr rfl hinner, ← Finset.mul_sum]

/-- **C4, the exact control law.**  The *average* mass retained by a uniformly
random budget of `k+1` positions out of `#s` is exactly `(k+1)/#s` of the total
mass — no selection, no concentration.  (Here the average is written as
`(number of subsets)⁻¹ · (total)`.) -/
theorem random_mass_average [DecidableEq ι] (s : Finset ι) (p : ι → ℝ) (k : ℕ) (hk : k + 1 ≤ #s) :
    (#(s.powersetCard (k + 1)) : ℝ)⁻¹ * ∑ T ∈ s.powersetCard (k + 1), ∑ i ∈ T, p i
      = ((k + 1 : ℝ) / #s) * ∑ i ∈ s, p i := by
  have hspos : 0 < #s := lt_of_lt_of_le (Nat.succ_pos k) hk
  have hchoose : (#s).choose (k + 1) * (k + 1) = #s * (#s - 1).choose k := by
    have h0 := Nat.add_one_mul_choose_eq (#s - 1) k
    have hs : #s - 1 + 1 = #s := Nat.succ_pred_eq_of_pos hspos
    rw [hs] at h0
    exact h0.symm
  have hcpos : 0 < (#s).choose (k + 1) := Nat.choose_pos hk
  have hcposR : (0 : ℝ) < ((#s).choose (k + 1) : ℝ) := by exact_mod_cast hcpos
  have hsposR : (0 : ℝ) < (#s : ℝ) := by exact_mod_cast hspos
  rw [Finset.card_powersetCard, sum_powersetCard_mass]
  have hchooseR : ((#s).choose (k + 1) : ℝ) * (k + 1 : ℝ) = (#s : ℝ) * ((#s - 1).choose k : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) hchoose
  have key : ((#s - 1).choose k : ℝ) = ((#s).choose (k + 1) : ℝ) * (k + 1) / (#s : ℝ) := by
    rw [eq_div_iff hsposR.ne']
    linarith [hchooseR]
  rw [key]
  have hcancel : ((#s).choose (k + 1) : ℝ)⁻¹ * ((#s).choose (k + 1) : ℝ) = 1 :=
    inv_mul_cancel₀ hcposR.ne'
  linear_combination ((k + 1 : ℝ) / (#s : ℝ) * ∑ i ∈ s, p i) * hcancel

/-- **C4, the selection-gain bound.**  Compare the two branches of the control
experiment on a normalised attention row: a *selected* budget of `k` positions
retains at most `sqrt (k / N_eff)` of the mass, whereas the random control
retains `k/ctx` on average.  Hence the mass advantage of selection is at most
`ctx / sqrt (k · N_eff)` — bounded, and shrinking as the effective support
approaches the context length. -/
theorem selection_gain_le (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hp : ∀ i ∈ s, 0 ≤ p i) {ctx Neff : ℝ} (hctx : 0 < ctx) (hNeff : 0 < Neff)
    (hk : 0 < T.card) (hcol : collision s p ≤ 1 / Neff) :
    (∑ i ∈ T, p i) / ((T.card : ℝ) / ctx) ≤ ctx / Real.sqrt (T.card * Neff) := by
  have hkR : (0 : ℝ) < (T.card : ℝ) := by exact_mod_cast hk
  have hmass : ∑ i ∈ T, p i ≤ Real.sqrt ((T.card : ℝ) / Neff) := by
    refine (mass_le_sqrt s T p hT hp).trans (Real.sqrt_le_sqrt ?_)
    have : (T.card : ℝ) * collision s p ≤ (T.card : ℝ) * (1 / Neff) :=
      mul_le_mul_of_nonneg_left hcol hkR.le
    calc (T.card : ℝ) * collision s p ≤ (T.card : ℝ) * (1 / Neff) := this
      _ = (T.card : ℝ) / Neff := by ring
  have hratio : (0 : ℝ) < (T.card : ℝ) / ctx := by positivity
  rw [div_le_div_iff₀ hratio (Real.sqrt_pos.mpr (by positivity))]
  have hsqrt : Real.sqrt ((T.card : ℝ) / Neff) * Real.sqrt ((T.card : ℝ) * Neff)
      = (T.card : ℝ) := by
    rw [← Real.sqrt_mul (by positivity)]
    have : (T.card : ℝ) / Neff * ((T.card : ℝ) * Neff) = (T.card : ℝ) ^ 2 := by
      field_simp
    rw [this, Real.sqrt_sq hkR.le]
  have h1 : (∑ i ∈ T, p i) * Real.sqrt ((T.card : ℝ) * Neff)
      ≤ Real.sqrt ((T.card : ℝ) / Neff) * Real.sqrt ((T.card : ℝ) * Neff) :=
    mul_le_mul_of_nonneg_right hmass (Real.sqrt_nonneg _)
  have h2 : ctx * ((T.card : ℝ) / ctx) = (T.card : ℝ) := by field_simp
  rw [h2]
  linarith [h1, hsqrt.le, hsqrt.ge]

/-- **The measured cell.**  At NET-36 cell B (`ctx = 512`, `k = 64`,
`N_eff = 152.11`) the selection advantage in retained *mass* is at most a factor
`5.2`.  Selection therefore cannot be buying more than `5.2×` the control's mass,
while the measured accuracy gap is `+7.6/+5.2` points: the control gap is a
selection effect on which positions are kept, not a bulk mass effect. -/
theorem netB_selection_gain_le (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hp : ∀ i ∈ s, 0 ≤ p i) (hcard : T.card = 64)
    (hcol : collision s p ≤ 1 / 152.11) :
    (∑ i ∈ T, p i) / ((T.card : ℝ) / 512) ≤ 5.2 := by
  have hk : 0 < T.card := by omega
  have h := selection_gain_le s T p hT hp (ctx := 512) (Neff := 152.11)
    (by norm_num) (by norm_num) hk hcol
  refine h.trans ?_
  rw [hcard]
  have hlow : (98.6 : ℝ) ≤ Real.sqrt ((64 : ℕ) * 152.11) := by
    have h1 : Real.sqrt ((98.6 : ℝ) ^ 2) ≤ Real.sqrt (((64 : ℕ) : ℝ) * 152.11) := by
      apply Real.sqrt_le_sqrt; norm_num
    rwa [Real.sqrt_sq (by norm_num : (0:ℝ) ≤ 98.6)] at h1
  have hpos : (0 : ℝ) < Real.sqrt (((64 : ℕ) : ℝ) * 152.11) := by
    have : (0 : ℝ) < ((64 : ℕ) : ℝ) * 152.11 := by norm_num
    exact Real.sqrt_pos.mpr this
  rw [div_le_iff₀ hpos]
  push_cast at hlow ⊢
  linarith

end RandomControl

end AttentionDepthRigidity