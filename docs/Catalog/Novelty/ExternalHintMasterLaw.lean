import Mathlib

/-!
# External-hint filters: one scalar prices everything (FACT round 38 #4, paper 138)

A *filter* is run in front of an exhaustive search.  When the filter's
prediction is right (a **hit**) the search only pays the fraction `θ` of the
full cost; when it is wrong it pays the full cost `1`.  This file proves, on an
arbitrary finite probability space:

* `work_eq_master` / `speedup_eq_master` — the **master law**
  `Speedup = 1 / (1 - (1 - θ) · P_hit)`.  The filter enters *only* through the
  scalar `P_hit` (`speedup_eq_of_phit_eq`), and the law is strictly increasing
  in `P_hit` with ceiling `1/θ` attained exactly at a certain hit
  (`masterSpeedup_strictMono`, `masterSpeedup_le_inv`, `masterSpeedup_eq_inv_iff`).

* **The symmetry break** (`internal_phit_eq`, `external_phit_eq`).  On a product
  space `C × Fin K` whose label is uniform on every fibre of the observable
  coordinate `c`, *every* reading that is generated from `c` (even through an
  arbitrary `c`-dependent randomisation) has `P_hit = 1/K` — it dies on the
  fibre-uniformity step.  A hint whose likelihood `L b h` lives on the label
  coordinate survives that step verbatim: `P_hit = (1/K) Σ_b L b b`.
  For `K = 2`, `θ = 1/2` the internal value is exactly the `4/3` cap
  (`internal_cap_four_thirds`): the cap is the *uninformative point* of the
  master law.

* **The which-factor ceiling** (`whichFactor_phit_eq`, `whichFactor_speedup_lt_two`).
  If the hint speaks about a uniformly chosen one of the two factors, without
  saying which, then `P_hit = (α + 1/K)/2`, and with the per-dial cost
  `θ = 1/K` the speedup is at most `2K²/(K²+1) < 2` for **every** dial size
  `K` — external hints are capped at `2×` per dial.  For `K = 2` this is the
  **canonical partition law** `8/(7 - 2α)` (`partition_law`), which reproduces
  `4/3` at `α = 1/2` and only reaches `8/5` at a perfect hint.
  Isolating the factor removes the ceiling (`isolated_speedup_perfect`).

* **Certain-hint ladder** `2^(t-2)/(1 - 2^(1-t))` (`ladder_eq_master`,
  `ladder_bounds`, `ladder_bit_loss`, `ladder_ratio_tendsto`): a master-law
  point with `P_hit = 1`; it sits in `(2^(t-2), 2^(t-1)]`, loses *exactly two
  bits* against `2^t` asymptotically, and doubles per extra bit.

* **Trace hints** `2^(t-1)/C_t` (`traceSpeedup_rate`, `traceSpeedup_increment`):
  a bounded recovery divisor `C_t` changes `log₂ Speedup` by a bounded amount,
  so the rate is still one work bit per hint bit.

* **Noise break-even surface** (`noisyWork_lt_one_iff`, `alphaStar_mono`,
  `noise_tolerance`): in an explicit fallback cost model the break-even
  accuracy `α*(θ,ε)` is computed in closed form, rises with `ε`, and external
  hints tolerate strictly more noise than internal filters for every `θ`.
  (The model's thresholds at `θ = 1/2` are `1/3` and `3/7`; the paper's
  `1/6` and `3/5` come from a different cost accounting that is not
  reconstructed here.)

* **Moduli with `r` factors** (`manyFactor_phit_eq`, `manyFactor_speedup_le`,
  `manyFactor_ceiling_tendsto`, `manyFactor_overshoot`,
  `manyFactor_binary_dial_optimal`, `manyFactor_collapse_to_four_thirds`):
  `P_hit = (α + (r-1)/K)/r`; the ceiling tends to `r/(r-1)` as the dial is
  refined, is overshot at finite `K` once `r ≥ 3`, and for `r ≥ 7` its global
  maximum over all dial sizes is `4r/(3r-1)` at `K = 2`, which tends to the
  internal `4/3` cap.

The companion file `ExternalHintGuessingBound.lean` proves the strategy-free
ceiling: a `t`-bit hint never buys more than `2^t`.
-/

namespace Catalog.Novelty.ExternalHintFilter

open Finset BigOperators

/-! ### 1. The master law on an arbitrary finite probability space -/

section Master

variable {Ω : Type*} [Fintype Ω]

/-- Probability of a hit: mass of the event on which the filter is right. -/
noncomputable def phit (μ : Ω → ℝ) (hit : Ω → Prop) [DecidablePred hit] : ℝ :=
  ∑ ω, if hit ω then μ ω else 0

/-- Expected (normalised) work of the filtered search: cost `θ` on a hit,
cost `1` on a miss. -/
noncomputable def work (μ : Ω → ℝ) (hit : Ω → Prop) [DecidablePred hit] (θ : ℝ) : ℝ :=
  ∑ ω, μ ω * (if hit ω then θ else 1)

/-- Speedup relative to the unfiltered search (whose work is `1`). -/
noncomputable def speedup (μ : Ω → ℝ) (hit : Ω → Prop) [DecidablePred hit] (θ : ℝ) : ℝ :=
  1 / work μ hit θ

/-- The closed form of the master law, as a function of the single scalar `P`. -/
noncomputable def masterSpeedup (θ P : ℝ) : ℝ := 1 / (1 - (1 - θ) * P)

/-- **Master law, work form.** -/
theorem work_eq_master (μ : Ω → ℝ) (hμ : ∑ ω, μ ω = 1) (hit : Ω → Prop)
    [DecidablePred hit] (θ : ℝ) :
    work μ hit θ = 1 - (1 - θ) * phit μ hit := by
  unfold work phit
  have h : ∀ ω, μ ω * (if hit ω then θ else 1)
      = μ ω - (1 - θ) * (if hit ω then μ ω else 0) := by
    intro ω; split_ifs <;> ring
  simp_rw [h, Finset.sum_sub_distrib, ← Finset.mul_sum, hμ]

/-- **Master law.** `Speedup(H) = 1 / (1 - (1 - θ) P_hit)`. -/
theorem speedup_eq_master (μ : Ω → ℝ) (hμ : ∑ ω, μ ω = 1) (hit : Ω → Prop)
    [DecidablePred hit] (θ : ℝ) :
    speedup μ hit θ = masterSpeedup θ (phit μ hit) := by
  unfold speedup masterSpeedup; rw [work_eq_master μ hμ]

/-- **One scalar prices everything**: two filters, on possibly different
probability spaces, with the same `P_hit` have the same speedup. -/
theorem speedup_eq_of_phit_eq {Ω' : Type*} [Fintype Ω'] (μ : Ω → ℝ) (μ' : Ω' → ℝ)
    (hμ : ∑ ω, μ ω = 1) (hμ' : ∑ ω, μ' ω = 1) (hit : Ω → Prop) [DecidablePred hit]
    (hit' : Ω' → Prop) [DecidablePred hit'] (θ : ℝ)
    (h : phit μ hit = phit μ' hit') :
    speedup μ hit θ = speedup μ' hit' θ := by
  rw [speedup_eq_master μ hμ, speedup_eq_master μ' hμ', h]

/-- `P_hit` is a probability. -/
theorem phit_mem_Icc (μ : Ω → ℝ) (h0 : ∀ ω, 0 ≤ μ ω) (hμ : ∑ ω, μ ω = 1)
    (hit : Ω → Prop) [DecidablePred hit] : 0 ≤ phit μ hit ∧ phit μ hit ≤ 1 := by
  unfold phit
  refine ⟨Finset.sum_nonneg fun ω _ => ?_, ?_⟩
  · split_ifs <;> simp [h0 ω]
  · rw [← hμ]; exact Finset.sum_le_sum fun ω _ => by split_ifs <;> simp [h0 ω]

end Master

/-- The master law is strictly increasing in `P_hit` on `[0,1]` for `0 < θ < 1`. -/
theorem masterSpeedup_strictMono {θ : ℝ} (h0 : 0 < θ) (h1 : θ < 1) :
    StrictMonoOn (masterSpeedup θ) (Set.Icc 0 1) := by
  intro P hP Q hQ hPQ
  unfold masterSpeedup
  have hQ' : 0 < 1 - (1 - θ) * Q := by nlinarith [hQ.2]
  apply one_div_lt_one_div_of_lt hQ'
  nlinarith

/-- The master law never exceeds the per-dial ceiling `1/θ`. -/
theorem masterSpeedup_le_inv {θ P : ℝ} (h0 : 0 < θ) (h1 : θ ≤ 1) (hP : P ≤ 1) :
    masterSpeedup θ P ≤ 1 / θ := by
  unfold masterSpeedup
  apply one_div_le_one_div_of_le h0
  nlinarith

/-- The ceiling `1/θ` is attained exactly by a certain hit. -/
theorem masterSpeedup_eq_inv_iff {θ P : ℝ} (h0 : 0 < θ) (h1 : θ < 1) :
    masterSpeedup θ P = 1 / θ ↔ P = 1 := by
  unfold masterSpeedup
  constructor
  · intro h
    have hne : 1 - (1 - θ) * P ≠ 0 := by
      intro hz; rw [hz] at h; simp at h; linarith
    rw [div_eq_div_iff hne h0.ne'] at h
    have : (1 - θ) * (P - 1) = 0 := by linarith
    rcases mul_eq_zero.1 this with h' | h'
    · linarith
    · linarith
  · rintro rfl; congr 1; ring

/-! ### 2. The symmetry break: fibre uniformity kills internal readings -/

section Fibre

variable {C : Type*} [Fintype C] {K : ℕ}

/-- Joint law on `C × label × reading`: the observable coordinate `c` has law
`ν`, the label `b` is uniform on every fibre of `c`, and the reading `h` is
drawn from a kernel `R`. -/
noncomputable def jointLaw (ν : C → ℝ) (R : C → Fin K → Fin K → ℝ) :
    C × Fin K × Fin K → ℝ :=
  fun x => ν x.1 / K * R x.1 x.2.1 x.2.2

/-- The hit event: the reading equals the label. -/
def readHit (x : C × Fin K × Fin K) : Prop := x.2.2 = x.2.1

instance : DecidablePred (readHit (C := C) (K := K)) :=
  fun x => inferInstanceAs (Decidable (x.2.2 = x.2.1))

theorem phit_jointLaw (ν : C → ℝ) (R : C → Fin K → Fin K → ℝ) :
    phit (jointLaw ν R) readHit = ∑ c, ν c / K * ∑ b, R c b b := by
  unfold phit jointLaw readHit
  rw [Fintype.sum_prod_type]
  refine Finset.sum_congr rfl fun c _ => ?_
  rw [Fintype.sum_prod_type, Finset.mul_sum]
  refine Finset.sum_congr rfl fun b _ => ?_
  rw [Finset.sum_ite_eq']; simp

/-- **Internal readings die on the fibre-uniformity step.**  A reading drawn
from any kernel that depends on the observable coordinate `c` only (not on the
label) hits with probability exactly `1/K`. -/
theorem internal_phit_eq (ν : C → ℝ) (hν : ∑ c, ν c = 1)
    (R : C → Fin K → ℝ) (hR : ∀ c, ∑ h, R c h = 1) :
    phit (jointLaw ν (fun c _ h => R c h)) readHit = 1 / K := by
  rw [phit_jointLaw]
  simp_rw [hR, mul_one, div_eq_mul_inv, ← Finset.sum_mul, hν]

/-- **A hint's likelihood survives verbatim.**  If the reading is drawn from a
likelihood `L b h` living on the (non-`c`-measurable) label coordinate, then
`P_hit = (1/K) Σ_b L b b`, whatever the law of `c`. -/
theorem external_phit_eq (ν : C → ℝ) (hν : ∑ c, ν c = 1) (L : Fin K → Fin K → ℝ) :
    phit (jointLaw ν (fun _ b h => L b h)) readHit = (1 / K) * ∑ b, L b b := by
  rw [phit_jointLaw]
  simp_rw [div_eq_mul_inv, mul_assoc, ← Finset.sum_mul, hν]

/-- The joint law is a probability law whenever `ν` and every row of the kernel are. -/
theorem jointLaw_sum (hK : 0 < K) (ν : C → ℝ) (hν : ∑ c, ν c = 1)
    (R : C → Fin K → Fin K → ℝ) (hR : ∀ c b, ∑ h, R c b h = 1) :
    ∑ x, jointLaw ν R x = 1 := by
  unfold jointLaw
  rw [Fintype.sum_prod_type]
  have hKr : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
  have : ∀ c, ∑ y : Fin K × Fin K, ν c / K * R c y.1 y.2 = ν c := by
    intro c
    rw [Fintype.sum_prod_type]
    simp only [← Finset.mul_sum, hR, mul_one, Finset.sum_const, Finset.card_univ,
      Fintype.card_fin, nsmul_eq_mul]
    field_simp
  simp_rw [this, hν]

/-- **Paper 132's `4/3` cap is the uninformative point of the master law.**
For a binary label and half-cost dial, every internal reading gives exactly
`4/3`. -/
theorem internal_cap_four_thirds (ν : C → ℝ) (hν : ∑ c, ν c = 1)
    (R : C → Fin 2 → ℝ) (hR : ∀ c, ∑ h, R c h = 1) :
    speedup (jointLaw ν (fun c (_ : Fin 2) h => R c h)) readHit (1 / 2) = 4 / 3 := by
  rw [speedup_eq_master _ (jointLaw_sum (K := 2) (by norm_num) ν hν _ (fun c _ => hR c)),
    internal_phit_eq ν hν R hR]
  unfold masterSpeedup; norm_num

/-- A perfect external hint (identity likelihood) attains the full ceiling `1/θ`,
which no internal reading can approach. -/
theorem external_perfect_phit (hK : 0 < K) (ν : C → ℝ) (hν : ∑ c, ν c = 1) :
    phit (jointLaw ν (fun _ (b h : Fin K) => if b = h then (1 : ℝ) else 0)) readHit = 1 := by
  rw [external_phit_eq ν hν]
  simp only [if_true, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul,
    mul_one]
  have : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
  field_simp

end Fibre

/-! ### 3. The which-factor ceiling -/

section WhichFactor

variable {K : ℕ}

/-- Which-factor model on `(b_p, b_q, w, h)`: the labels of the two factors are
independent and uniform on `Fin K`, a fair coin `w` decides which factor the
hint speaks about (`true` = the wanted factor `p`), and the hint value `h` is
drawn from the likelihood `L` applied to that factor's label. -/
noncomputable def wfLaw (L : Fin K → Fin K → ℝ) : (Fin K × Fin K) × Bool × Fin K → ℝ :=
  fun x => 1 / (2 * (K : ℝ) ^ 2) * L (if x.2.1 then x.1.1 else x.1.2) x.2.2

/-- A hit: the hint value equals the label of the wanted factor `p`. -/
def wfHit (x : (Fin K × Fin K) × Bool × Fin K) : Prop := x.2.2 = x.1.1

instance : DecidablePred (wfHit (K := K)) :=
  fun x => inferInstanceAs (Decidable (x.2.2 = x.1.1))

/-- Hint accuracy: the probability that the hint is right about the factor it
speaks about. -/
noncomputable def accuracy (L : Fin K → Fin K → ℝ) : ℝ := (1 / K) * ∑ b, L b b

theorem wfLaw_sum (hK : 0 < K) (L : Fin K → Fin K → ℝ) (hL : ∀ b, ∑ h, L b h = 1) :
    ∑ x, wfLaw L x = 1 := by
  unfold wfLaw
  have hKr : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
  simp only [Fintype.sum_prod_type, Fintype.sum_bool, if_true, Bool.false_eq_true, if_false,
    ← Finset.mul_sum, hL]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  field_simp; ring

/-- **Which-factor hit probability**: `P_hit = (α + 1/K)/2`.  Half of the time
the hint speaks about the wrong factor, whose label is independent of the
wanted one, so that half contributes only the chance rate `1/K`. -/
theorem whichFactor_phit_eq (hK : 0 < K) (L : Fin K → Fin K → ℝ)
    (hL : ∀ b, ∑ h, L b h = 1) :
    phit (wfLaw L) wfHit = (accuracy L + 1 / K) / 2 := by
  unfold phit wfLaw wfHit accuracy
  have hKr : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
  simp only [Fintype.sum_prod_type, Fintype.sum_bool, if_true, Bool.false_eq_true, if_false]
  simp only [Finset.sum_ite_eq', Finset.mem_univ, if_true]
  have h2 : ∀ bp : Fin K, ∑ bq : Fin K, 1 / (2 * (K : ℝ) ^ 2) * L bp bp
      = 1 / (2 * K) * L bp bp := by
    intro bp
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  simp_rw [Finset.sum_add_distrib, h2]
  rw [Finset.sum_comm (f := fun bp bq => 1 / (2 * (K : ℝ) ^ 2) * L bq bp)]
  simp_rw [← Finset.mul_sum, hL]
  simp only [mul_one, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  field_simp

theorem accuracy_le_one (hK : 0 < K) (L : Fin K → Fin K → ℝ) (h0 : ∀ b h, 0 ≤ L b h)
    (hL : ∀ b, ∑ h, L b h = 1) : accuracy L ≤ 1 := by
  unfold accuracy
  have hKr : (0 : ℝ) < K := by exact_mod_cast hK
  have : ∑ b, L b b ≤ ∑ _b : Fin K, (1 : ℝ) := Finset.sum_le_sum fun b _ => by
    rw [← hL b]
    exact Finset.single_le_sum (fun h _ => h0 b h) (Finset.mem_univ b)
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul,
    mul_one] at this
  rw [div_mul_eq_mul_div, one_mul, div_le_one hKr]; exact this

/-- Speedup of a which-factor hint at the per-dial cost `θ = 1/K`. -/
theorem whichFactor_speedup_eq (hK : 0 < K) (L : Fin K → Fin K → ℝ)
    (hL : ∀ b, ∑ h, L b h = 1) :
    speedup (wfLaw L) wfHit (1 / K) =
      masterSpeedup (1 / K) ((accuracy L + 1 / K) / 2) := by
  rw [speedup_eq_master _ (wfLaw_sum hK L hL), whichFactor_phit_eq hK L hL]

/-- **The which-factor ceiling.**  For every dial size `K ≥ 1` and every hint
likelihood, the speedup is at most `2K²/(K²+1)`, hence strictly below `2`. -/
theorem whichFactor_speedup_le (hK : 0 < K) (L : Fin K → Fin K → ℝ)
    (h0 : ∀ b h, 0 ≤ L b h) (hL : ∀ b, ∑ h, L b h = 1) :
    speedup (wfLaw L) wfHit (1 / K) ≤ 2 * (K : ℝ) ^ 2 / ((K : ℝ) ^ 2 + 1) := by
  rw [whichFactor_speedup_eq hK L hL]
  have ha := accuracy_le_one hK L h0 hL
  have hKr : (1 : ℝ) ≤ K := by exact_mod_cast hK
  unfold masterSpeedup
  have hden : 0 < 1 - (1 - 1 / (K : ℝ)) * ((accuracy L + 1 / K) / 2) := by
    have : 1 / (K : ℝ) ≤ 1 := by rw [div_le_one (by linarith)]; exact hKr
    have : 0 ≤ 1 / (K : ℝ) := by positivity
    nlinarith
  rw [div_le_div_iff₀ hden (by positivity)]
  have h1K : 1 / (K : ℝ) * K = 1 := by field_simp
  have : (1 - 1 / (K : ℝ)) * ((accuracy L + 1 / K) / 2)
      ≤ (1 - 1 / (K : ℝ)) * ((1 + 1 / K) / 2) := by
    apply mul_le_mul_of_nonneg_left (by linarith)
    rw [sub_nonneg, div_le_one (by linarith)]; exact hKr
  have key : (1 - (1 - 1 / (K : ℝ)) * ((1 + 1 / K) / 2)) * (2 * K ^ 2) = K ^ 2 + 1 := by
    field_simp; ring
  nlinarith

/-- The `2×` per-dial ceiling: external hints that do not say which factor they
are about never reach a doubling, at any dial resolution. -/
theorem whichFactor_speedup_lt_two (hK : 0 < K) (L : Fin K → Fin K → ℝ)
    (h0 : ∀ b h, 0 ≤ L b h) (hL : ∀ b, ∑ h, L b h = 1) :
    speedup (wfLaw L) wfHit (1 / K) < 2 := by
  refine lt_of_le_of_lt (whichFactor_speedup_le hK L h0 hL) ?_
  rw [div_lt_iff₀ (by positivity)]; linarith

/-- The ceiling `2K²/(K²+1)` is sharp: a perfect hint attains it. -/
theorem whichFactor_perfect (hK : 0 < K) :
    speedup (wfLaw (fun b h : Fin K => if b = h then (1 : ℝ) else 0)) wfHit (1 / K)
      = 2 * (K : ℝ) ^ 2 / ((K : ℝ) ^ 2 + 1) := by
  have hL : ∀ b : Fin K, ∑ h, (if b = h then (1 : ℝ) else 0) = 1 := by
    intro b; simp
  rw [whichFactor_speedup_eq hK _ hL]
  have hKr : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
  have ha : accuracy (fun b h : Fin K => if b = h then (1 : ℝ) else 0) = 1 := by
    unfold accuracy; simp; field_simp
  rw [ha]; unfold masterSpeedup
  have e : 1 - (1 - 1 / (K : ℝ)) * ((1 + 1 / K) / 2) = ((K : ℝ) ^ 2 + 1) / (2 * K ^ 2) := by
    field_simp; ring
  rw [e, one_div_div]

/-- … and the ceiling tends to `2` as the dial is refined. -/
theorem whichFactor_ceiling_tendsto :
    Filter.Tendsto (fun K : ℕ => 2 * (K : ℝ) ^ 2 / ((K : ℝ) ^ 2 + 1)) Filter.atTop
      (nhds 2) := by
  have h : (fun K : ℕ => 2 * (K : ℝ) ^ 2 / ((K : ℝ) ^ 2 + 1))
      = fun K : ℕ => 2 - 2 / ((K : ℝ) ^ 2 + 1) := by
    funext K; field_simp; ring
  rw [h]
  have : Filter.Tendsto (fun K : ℕ => 2 / ((K : ℝ) ^ 2 + 1)) Filter.atTop (nhds 0) := by
    apply Filter.Tendsto.div_atTop tendsto_const_nhds
    apply Filter.tendsto_atTop_add_const_right
    exact (Filter.tendsto_pow_atTop two_ne_zero).comp tendsto_natCast_atTop_atTop
  simpa using (tendsto_const_nhds (x := (2 : ℝ))).sub this

/-- **Canonical partition law** (`K = 2`, `θ = 1/2`): `Speedup = 8/(7 - 2α)`. -/
theorem partition_law (L : Fin 2 → Fin 2 → ℝ) (hL : ∀ b, ∑ h, L b h = 1) :
    speedup (wfLaw L) wfHit (1 / 2) = 8 / (7 - 2 * accuracy L) := by
  have := whichFactor_speedup_eq (K := 2) (by norm_num) L hL
  push_cast at this
  rw [this]; unfold masterSpeedup
  have e : 1 - (1 - 1 / (2 : ℝ)) * ((accuracy L + 1 / 2) / 2) = (7 - 2 * accuracy L) / 8 := by
    ring
  rw [e, one_div_div]

/-- The partition law at its two landmark points: `α = 1/2` reproduces the
internal cap `4/3`; a perfect hint `α = 1` gives only `8/5 < 2`. -/
theorem partition_law_landmarks :
    (8 : ℝ) / (7 - 2 * (1 / 2)) = 4 / 3 ∧ (8 : ℝ) / (7 - 2 * 1) = 8 / 5 ∧
      (8 : ℝ) / 5 < 2 := by
  norm_num

/-- **Isolation removes the ceiling.**  If, in addition, the hint is known to
speak about the wanted factor (the which-factor bit is paid for by isolation
queries), a perfect hint attains the full per-dial ceiling `K`, a gain of
`(K² + 1)/(2K)` over the which-factor ceiling. -/
theorem isolated_speedup_perfect (hK : 0 < K) :
    masterSpeedup (1 / K) 1 = K ∧
      (K : ℝ) / (2 * (K : ℝ) ^ 2 / ((K : ℝ) ^ 2 + 1)) = ((K : ℝ) ^ 2 + 1) / (2 * K) := by
  have hKr : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
  constructor
  · unfold masterSpeedup; field_simp; ring
  · have : (K : ℝ) ^ 2 + 1 ≠ 0 := by positivity
    field_simp

end WhichFactor

/-! ### 4. The certain-hint ladder: two bit-losses -/

/-- The certain-hint ladder `2^(t-2) / (1 - 2^(1-t))`. -/
noncomputable def ladder (t : ℕ) : ℝ := (2 : ℝ) ^ t / 4 / (1 - 2 / 2 ^ t)

theorem two_pow_ge_four {t : ℕ} (ht : 2 ≤ t) : (4 : ℝ) ≤ 2 ^ t := by
  have : (2 : ℝ) ^ 2 ≤ 2 ^ t := pow_le_pow_right₀ (by norm_num) ht
  norm_num at this; exact this

/-- **The ladder is a master-law point**: a certain hit (`P_hit = 1`) at the
effective cost `θ_t = 2a(1-a)` with `a = 2^(1-t)`. -/
theorem ladder_eq_master {t : ℕ} (ht : 2 ≤ t) :
    ladder t = masterSpeedup (2 * (2 / 2 ^ t) * (1 - 2 / 2 ^ t)) 1 := by
  have h4 := two_pow_ge_four ht
  have hne : (1 : ℝ) - 2 / 2 ^ t ≠ 0 := by
    have : (2 : ℝ) / 2 ^ t ≤ 1 / 2 := by rw [div_le_iff₀ (by positivity)]; linarith
    linarith
  unfold ladder masterSpeedup
  have hp : (2 : ℝ) ^ t ≠ 0 := by positivity
  have hp2 : (2 : ℝ) ^ t - 2 ≠ 0 := by linarith
  have hp3 : (2 : ℝ) ^ t * 4 - 8 ≠ 0 := by linarith
  field_simp
  ring

/-- The ladder lies strictly above `2^(t-2)` and at most at `2^(t-1)`. -/
theorem ladder_bounds {t : ℕ} (ht : 2 ≤ t) :
    (2 : ℝ) ^ t / 4 < ladder t ∧ ladder t ≤ (2 : ℝ) ^ t / 2 := by
  have h4 := two_pow_ge_four ht
  have hp : (0 : ℝ) < 2 ^ t := by positivity
  have ha : (0 : ℝ) < 2 / 2 ^ t := by positivity
  have ha2 : (2 : ℝ) / 2 ^ t ≤ 1 / 2 := by rw [div_le_iff₀ hp]; linarith
  have hd : 0 < 1 - (2 : ℝ) / 2 ^ t := by linarith
  unfold ladder
  constructor
  · rw [lt_div_iff₀ hd]
    have : 0 < (2 : ℝ) ^ t / 4 := by positivity
    nlinarith
  · rw [div_le_iff₀ hd]
    nlinarith

/-- **Exactly two bits are lost** relative to the `2^t` ceiling:
`2^t / ladder t = 4 (1 - 2^(1-t))`, which lies in `[2, 4)` and tends to `4`
(parity bit + which-factor bit). -/
theorem ladder_bit_loss {t : ℕ} (ht : 2 ≤ t) :
    (2 : ℝ) ^ t / ladder t = 4 * (1 - 2 / 2 ^ t) := by
  have hp : (2 : ℝ) ^ t ≠ 0 := by positivity
  have h4 := two_pow_ge_four ht
  have hne : (1 : ℝ) - 2 / 2 ^ t ≠ 0 := by
    have : (2 : ℝ) / 2 ^ t ≤ 1 / 2 := by rw [div_le_iff₀ (by positivity)]; linarith
    linarith
  unfold ladder
  field_simp

theorem tendsto_two_div_two_pow :
    Filter.Tendsto (fun t : ℕ => (2 : ℝ) / 2 ^ t) Filter.atTop (nhds 0) := by
  have h := tendsto_pow_atTop_nhds_zero_of_lt_one (r := (1 / 2 : ℝ)) (by norm_num)
    (by norm_num)
  have : (fun t : ℕ => (2 : ℝ) / 2 ^ t) = fun t => 2 * (1 / 2 : ℝ) ^ t := by
    funext t; rw [one_div_pow, mul_one_div]
  rw [this]; simpa using h.const_mul 2

theorem ladder_bit_loss_tendsto :
    Filter.Tendsto (fun t => (2 : ℝ) ^ t / ladder t) Filter.atTop (nhds 4) := by
  have h : Filter.Tendsto (fun t : ℕ => 4 * (1 - (2 : ℝ) / 2 ^ t)) Filter.atTop
      (nhds (4 * (1 - 0))) :=
    (tendsto_const_nhds.sub tendsto_two_div_two_pow).const_mul 4
  rw [show (4 : ℝ) * (1 - 0) = 4 by norm_num] at h
  refine h.congr' ?_
  filter_upwards [Filter.eventually_ge_atTop 2] with t ht
  exact (ladder_bit_loss ht).symm

/-- **Linear in bits**: each extra certain bit asymptotically doubles the
speedup, `ladder (t+1) / ladder t → 2`. -/
theorem ladder_ratio_tendsto :
    Filter.Tendsto (fun t => ladder (t + 1) / ladder t) Filter.atTop (nhds 2) := by
  have key : ∀ t : ℕ, 2 ≤ t →
      ladder (t + 1) / ladder t = 2 * ((2 : ℝ) ^ t / ladder t) / ((2 : ℝ) ^ (t + 1) /
        ladder (t + 1)) := by
    intro t ht
    have h1 : 0 < ladder t := lt_trans (by positivity) (ladder_bounds ht).1
    have h2 : 0 < ladder (t + 1) := lt_trans (by positivity) (ladder_bounds (by omega)).1
    rw [pow_succ]
    field_simp
  have hlim : Filter.Tendsto (fun t => 2 * ((2 : ℝ) ^ t / ladder t) /
      ((2 : ℝ) ^ (t + 1) / ladder (t + 1))) Filter.atTop (nhds (2 * 4 / 4)) :=
    (ladder_bit_loss_tendsto.const_mul 2).div
      (ladder_bit_loss_tendsto.comp (Filter.tendsto_add_atTop_nat 1)) (by norm_num)
  rw [show (2 : ℝ) * 4 / 4 = 2 by norm_num] at hlim
  refine hlim.congr' ?_
  filter_upwards [Filter.eventually_ge_atTop 2] with t ht
  exact (key t ht).symm

/-! ### 5. Trace hints: a constant divisor is not a rate penalty -/

/-- Trace-hint speedup `2^(t-1) / C_t`. -/
noncomputable def traceSpeedup (C : ℕ → ℝ) (t : ℕ) : ℝ := (2 : ℝ) ^ t / 2 / C t

theorem logb_traceSpeedup (C : ℕ → ℝ) (hC : ∀ t, 0 < C t) (t : ℕ) :
    Real.logb 2 (traceSpeedup C t) = t - 1 - Real.logb 2 (C t) := by
  unfold traceSpeedup
  have hC' := (hC t).ne'
  rw [Real.logb_div (by positivity) hC', Real.logb_div (by positivity) (by norm_num),
    Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
  ring

/-- **The rate is one bit per bit.**  If the recovery divisor `C_t` stays
between two positive constants, then `log₂(Speedup)/t → 1`: the generic
recovery overhead costs a constant number of bits, never a fraction of the
rate. -/
theorem traceSpeedup_rate (C : ℕ → ℝ) {c₀ c₁ : ℝ} (h0 : 0 < c₀)
    (hlo : ∀ t, c₀ ≤ C t) (hhi : ∀ t, C t ≤ c₁) :
    Filter.Tendsto (fun t : ℕ => Real.logb 2 (traceSpeedup C t) / t) Filter.atTop
      (nhds 1) := by
  have hC : ∀ t, 0 < C t := fun t => lt_of_lt_of_le h0 (hlo t)
  set B := 1 + |Real.logb 2 c₀| + |Real.logb 2 c₁|
  have hbound : ∀ t, |1 + Real.logb 2 (C t)| ≤ B := by
    intro t
    have hl : Real.logb 2 c₀ ≤ Real.logb 2 (C t) :=
      Real.logb_le_logb_of_le (by norm_num) h0 (hlo t)
    have hu : Real.logb 2 (C t) ≤ Real.logb 2 c₁ :=
      Real.logb_le_logb_of_le (by norm_num) (hC t) (hhi t)
    rw [abs_le]
    constructor
    · have := neg_abs_le (Real.logb 2 c₀)
      have := abs_nonneg (Real.logb 2 c₁)
      linarith
    · have := le_abs_self (Real.logb 2 c₁)
      have := abs_nonneg (Real.logb 2 c₀)
      linarith
  have hsmall : Filter.Tendsto (fun t : ℕ => (1 + Real.logb 2 (C t)) / t) Filter.atTop
      (nhds 0) := by
    apply squeeze_zero_norm' (a := fun t : ℕ => B / t)
    · filter_upwards [Filter.eventually_gt_atTop 0] with t ht
      rw [Real.norm_eq_abs, abs_div, Nat.abs_cast]
      exact div_le_div_of_nonneg_right (hbound t) (Nat.cast_nonneg t)
    · exact tendsto_const_div_atTop_nhds_zero_nat B
  have h := (tendsto_const_nhds (x := (1 : ℝ))).sub hsmall
  rw [sub_zero] at h
  refine h.congr' ?_
  filter_upwards [Filter.eventually_gt_atTop 0] with t ht
  have ht' : (t : ℝ) ≠ 0 := by exact_mod_cast ht.ne'
  rw [logb_traceSpeedup C hC]
  field_simp
  ring

/-- **Per-bit increments converge to one bit.**  If the divisor settles,
`C_t → c > 0`, then each extra hint bit eventually adds exactly one work bit. -/
theorem traceSpeedup_increment (C : ℕ → ℝ) (hC : ∀ t, 0 < C t) {c : ℝ} (hc : 0 < c)
    (hlim : Filter.Tendsto C Filter.atTop (nhds c)) :
    Filter.Tendsto (fun t : ℕ => Real.logb 2 (traceSpeedup C (t + 1)) -
      Real.logb 2 (traceSpeedup C t)) Filter.atTop (nhds 1) := by
  have hlog : Filter.Tendsto (fun t => Real.logb 2 (C t)) Filter.atTop
      (nhds (Real.logb 2 c)) :=
    (Real.continuousAt_logb (b := 2) hc.ne').tendsto.comp hlim
  have hlog1 := hlog.comp (Filter.tendsto_add_atTop_nat 1)
  have h := (tendsto_const_nhds (x := (1 : ℝ))).sub (hlog1.sub hlog)
  rw [sub_self, sub_zero] at h
  refine h.congr fun t => ?_
  simp only [Function.comp, logb_traceSpeedup C hC]
  push_cast; ring

/-! ### 6. The noise break-even surface -/

/-- Work of a noisy filter in the *fallback* cost model: with probability `ε`
the hint is corrupted, the hinted region (cost `θ`) is searched in vain and the
full search (cost `1`) follows; otherwise the master law applies. -/
noncomputable def noisyWork (θ P ε : ℝ) : ℝ :=
  (1 - ε) * (1 - (1 - θ) * P) + ε * (1 + θ)

/-- Break-even accuracy surface for the which-factor hint (`P = (α + θ)/2`). -/
noncomputable def alphaStar (θ ε : ℝ) : ℝ := 2 * ε * θ / ((1 - ε) * (1 - θ)) - θ

/-- **Break-even surface.**  A noisy which-factor hint of accuracy `α` is
net-positive exactly above the surface `α*(θ, ε)`. -/
theorem noisyWork_lt_one_iff {θ ε α : ℝ} (hθ1 : θ < 1) (hε1 : ε < 1) :
    noisyWork θ ((α + θ) / 2) ε < 1 ↔ alphaStar θ ε < α := by
  unfold noisyWork alphaStar
  have hd : 0 < (1 - ε) * (1 - θ) := mul_pos (by linarith) (by linarith)
  rw [sub_lt_iff_lt_add, div_lt_iff₀ hd]
  constructor <;> intro h <;> nlinarith

/-- The surface rises with the noise level: noisier channels need better hints. -/
theorem alphaStar_mono {θ ε ε' : ℝ} (hθ0 : 0 < θ) (hθ1 : θ < 1)
    (hεε' : ε ≤ ε') (hε'1 : ε' < 1) : alphaStar θ ε ≤ alphaStar θ ε' := by
  unfold alphaStar
  have h1 : 0 < 1 - θ := by linarith
  have hd : 0 < (1 - ε) * (1 - θ) := mul_pos (by linarith) h1
  have hd' : 0 < (1 - ε') * (1 - θ) := mul_pos (by linarith) h1
  rw [sub_le_sub_iff_right, div_le_div_iff₀ hd hd']
  have : 0 ≤ 2 * θ * (1 - θ) := by positivity
  nlinarith

/-- **External filters tolerate more noise than internal ones.**  In the
fallback model an internal (uninformative, `P = θ`) filter is net-positive iff
`ε < (1-θ)/(2-θ)`, a perfect which-factor hint (`α = 1`) iff
`ε < (1-θ²)/(1+2θ-θ²)`, and the second threshold is strictly larger for every
`θ ∈ (0,1)`.  At `θ = 1/2` these are `1/3` and `3/7`. -/
theorem noise_tolerance {θ ε : ℝ} (hθ0 : 0 < θ) (hθ1 : θ < 1) :
    (noisyWork θ θ ε < 1 ↔ ε < (1 - θ) / (2 - θ)) ∧
    (noisyWork θ ((1 + θ) / 2) ε < 1 ↔ ε < (1 - θ ^ 2) / (1 + 2 * θ - θ ^ 2)) ∧
    (1 - θ) / (2 - θ) < (1 - θ ^ 2) / (1 + 2 * θ - θ ^ 2) := by
  unfold noisyWork
  have h2 : 0 < 2 - θ := by linarith
  have h3 : 0 < 1 + 2 * θ - θ ^ 2 := by nlinarith
  refine ⟨?_, ?_, ?_⟩
  · rw [lt_div_iff₀ h2]
    constructor <;> intro h <;> nlinarith [mul_pos hθ0 (by linarith : (0 : ℝ) < 1 - θ)]
  · rw [lt_div_iff₀ h3]
    constructor <;> intro h <;> nlinarith [mul_pos hθ0 (by linarith : (0 : ℝ) < 1 - θ)]
  · rw [div_lt_div_iff₀ h2 h3]
    nlinarith [mul_pos hθ0 (by linarith : (0 : ℝ) < 1 - θ)]

theorem noise_tolerance_half :
    (1 - (1 / 2 : ℝ)) / (2 - 1 / 2) = 1 / 3 ∧
      (1 - (1 / 2 : ℝ) ^ 2) / (1 + 2 * (1 / 2) - (1 / 2) ^ 2) = 3 / 7 := by
  norm_num

/-! ### 7. Moduli with `r = s + 1` factors: the ceiling becomes `r/(r-1)`

The hint speaks about one of `r` factors chosen uniformly.  Only the label of
the spoken-about factor matters, and every other factor's label is independent
of the wanted factor's label, so the law reduces to the sufficient statistic
`(b_p, b_other, j, h)`: `j = 0` means the hint speaks about `p`. -/

section ManyFactors

variable {K s : ℕ}

/-- Reduced `r`-factor which-factor law, `r = s + 1`. -/
noncomputable def wfrLaw (L : Fin K → Fin K → ℝ) :
    (Fin K × Fin K) × Fin (s + 1) × Fin K → ℝ :=
  fun x => 1 / ((s + 1) * (K : ℝ) ^ 2) * L (if x.2.1 = 0 then x.1.1 else x.1.2) x.2.2

/-- A hit: the hint value equals the wanted factor's label. -/
def wfrHit (x : (Fin K × Fin K) × Fin (s + 1) × Fin K) : Prop := x.2.2 = x.1.1

instance : DecidablePred (wfrHit (K := K) (s := s)) :=
  fun x => inferInstanceAs (Decidable (x.2.2 = x.1.1))

theorem wfrLaw_sum (hK : 0 < K) (L : Fin K → Fin K → ℝ) (hL : ∀ b, ∑ h, L b h = 1) :
    ∑ x, wfrLaw (s := s) L x = 1 := by
  unfold wfrLaw
  have hKr : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
  simp only [Fintype.sum_prod_type, ← Finset.mul_sum]
  have : ∀ (a b : Fin K) (j : Fin (s + 1)), ∑ h, L (if j = 0 then a else b) h = 1 :=
    fun a b j => hL _
  simp only [this, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul,
    mul_one]
  push_cast
  field_simp

/-- **`r`-factor hit probability**: `P_hit = (α + s/K)/(s + 1)`. -/
theorem manyFactor_phit_eq (hK : 0 < K) (L : Fin K → Fin K → ℝ)
    (hL : ∀ b, ∑ h, L b h = 1) :
    phit (wfrLaw (s := s) L) wfrHit = (accuracy L + s / K) / (s + 1) := by
  unfold phit wfrLaw wfrHit accuracy
  have hKr : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
  simp only [Fintype.sum_prod_type, Fin.sum_univ_succ, Fin.succ_ne_zero, if_true, if_false]
  simp only [Finset.sum_ite_eq', Finset.mem_univ, if_true, Finset.sum_add_distrib]
  set c : ℝ := 1 / ((s + 1) * (K : ℝ) ^ 2)
  have h2 : ∑ x : Fin K, ∑ y : Fin K, ∑ _i : Fin s, c * L y x = s * c * K := by
    rw [Finset.sum_comm]
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    simp_rw [← Finset.mul_sum, hL]
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    ring
  have h1 : ∑ x : Fin K, ∑ _y : Fin K, c * L x x = K * c * ∑ b, L b b := by
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun b _ => by ring
  rw [h1, h2]
  simp only [c]
  field_simp

theorem manyFactor_den_pos {K : ℝ} (hK1 : 1 ≤ K) (s : ℕ) :
    (0 : ℝ) < s * K ^ 2 - (s - 1) * K + s := by
  have e : (s : ℝ) * K ^ 2 - (s - 1) * K + s = s * (K * (K - 1) + 1) + K := by ring
  rw [e]
  have : (0 : ℝ) ≤ K * (K - 1) := mul_nonneg (by linarith) (by linarith)
  have hs : (0 : ℝ) ≤ s := Nat.cast_nonneg s
  positivity

/-- Closed form of the `r`-factor ceiling at per-dial cost `1/K`. -/
theorem manyFactor_ceiling_closed (hK : 0 < K) :
    masterSpeedup (1 / K) ((1 + s / K) / (s + 1)) =
      (s + 1) * (K : ℝ) ^ 2 / (s * K ^ 2 - (s - 1) * K + s) := by
  have hKr : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
  have hK1 : (1 : ℝ) ≤ K := by exact_mod_cast hK
  have hpos := manyFactor_den_pos hK1 s
  unfold masterSpeedup
  have e : 1 - (1 - 1 / (K : ℝ)) * ((1 + s / K) / (s + 1)) =
      (s * K ^ 2 - (s - 1) * K + s) / ((s + 1) * K ^ 2) := by
    field_simp; ring
  rw [e, one_div_div]

/-- **The `r`-factor ceiling.**  Every hint likelihood is bounded by the
perfect-hint value `(s+1)K²/(sK² - (s-1)K + s)`. -/
theorem manyFactor_speedup_le (hK : 0 < K) (L : Fin K → Fin K → ℝ)
    (h0 : ∀ b h, 0 ≤ L b h) (hL : ∀ b, ∑ h, L b h = 1) :
    speedup (wfrLaw (s := s) L) wfrHit (1 / K) ≤
      (s + 1) * (K : ℝ) ^ 2 / (s * K ^ 2 - (s - 1) * K + s) := by
  rw [speedup_eq_master _ (wfrLaw_sum hK L hL), manyFactor_phit_eq hK L hL,
    ← manyFactor_ceiling_closed hK]
  have hK1 : (1 : ℝ) ≤ K := by exact_mod_cast hK
  have ha1 := accuracy_le_one hK L h0 hL
  have ha0 : 0 ≤ accuracy L := by
    unfold accuracy
    exact mul_nonneg (by positivity) (Finset.sum_nonneg fun b _ => h0 b b)
  have hs : (0 : ℝ) ≤ s := Nat.cast_nonneg s
  have hsK : (s : ℝ) / K ≤ s := div_le_self hs hK1
  have hθ : 1 / (K : ℝ) ≤ 1 := by rw [div_le_one (by linarith)]; exact hK1
  unfold masterSpeedup
  have hP1 : (1 + s / (K : ℝ)) / (s + 1) ≤ 1 := by
    rw [div_le_one (by linarith)]; linarith
  have hden : 0 < 1 - (1 - 1 / (K : ℝ)) * ((1 + s / K) / (s + 1)) := by
    have : 0 < 1 / (K : ℝ) := by positivity
    have := mul_le_mul_of_nonneg_left hP1 (by linarith : (0 : ℝ) ≤ 1 - 1 / K)
    linarith
  apply one_div_le_one_div_of_le hden
  have hmono : (accuracy L + s / K) / (s + 1) ≤ (1 + s / (K : ℝ)) / (s + 1) :=
    div_le_div_of_nonneg_right (by linarith) (by linarith)
  have : 0 ≤ 1 - 1 / (K : ℝ) := by linarith
  nlinarith

/-- **Fine-dial limit**: the `r`-factor ceiling tends to `r/(r-1) = (s+1)/s`. -/
theorem manyFactor_ceiling_tendsto (hs : 0 < s) :
    Filter.Tendsto (fun K : ℕ => (s + 1) * (K : ℝ) ^ 2 / (s * K ^ 2 - (s - 1) * K + s))
      Filter.atTop (nhds (((s : ℝ) + 1) / s)) := by
  have hsr : (0 : ℝ) < s := by exact_mod_cast hs
  have hinv : Filter.Tendsto (fun K : ℕ => (1 : ℝ) / K) Filter.atTop (nhds 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have hlim : Filter.Tendsto (fun K : ℕ => ((s : ℝ) + 1) /
      (s - (s - 1) * (1 / K) + s * (1 / K) ^ 2)) Filter.atTop
      (nhds (((s : ℝ) + 1) / (s - (s - 1) * 0 + s * 0 ^ 2))) := by
    apply tendsto_const_nhds.div
    · exact ((tendsto_const_nhds.sub (hinv.const_mul _)).add ((hinv.pow 2).const_mul _))
    · simp; omega
  simp only [mul_zero, sub_zero, add_zero, ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true,
    zero_pow] at hlim
  refine hlim.congr' ?_
  filter_upwards [Filter.eventually_gt_atTop 0] with K hK
  have hKr : (K : ℝ) ≠ 0 := by exact_mod_cast hK.ne'
  have hK1 : (1 : ℝ) ≤ K := by exact_mod_cast hK
  have hpos := manyFactor_den_pos hK1 s
  have hpos' : (0 : ℝ) < s - (s - 1) * (1 / K) + s * (1 / K) ^ 2 := by
    have : s - (s - 1) * (1 / (K : ℝ)) + s * (1 / K) ^ 2 =
        (s * K ^ 2 - (s - 1) * K + s) / K ^ 2 := by field_simp
    rw [this]; positivity
  rw [div_eq_div_iff hpos'.ne' hpos.ne']
  field_simp

/-- **Two factors approach the ceiling from below, three or more from above.**
For `r = 2` the ceiling `2K²/(K²+1)` stays below its limit `2`; for `r ≥ 3`
the finite-dial ceiling at `K = r` already exceeds the limit `r/(r-1)`. -/
theorem manyFactor_overshoot (hs : 2 ≤ s) :
    ((s : ℝ) + 1) / s < (s + 1) * ((s + 1 : ℕ) : ℝ) ^ 2 /
      (s * ((s + 1 : ℕ) : ℝ) ^ 2 - (s - 1) * ((s + 1 : ℕ) : ℝ) + s) := by
  push_cast
  have hs' : (2 : ℝ) ≤ s := by exact_mod_cast hs
  have hpos : (0 : ℝ) < s * (s + 1) ^ 2 - (s - 1) * (s + 1) + s := by nlinarith
  rw [div_lt_div_iff₀ (by linarith) hpos]
  nlinarith

/-- For two factors the general ceiling is the which-factor ceiling of §3. -/
theorem manyFactor_two (K : ℕ) :
    ((1 : ℕ) + 1 : ℝ) * (K : ℝ) ^ 2 / ((1 : ℕ) * K ^ 2 - ((1 : ℕ) - 1) * K + (1 : ℕ)) =
      2 * (K : ℝ) ^ 2 / ((K : ℝ) ^ 2 + 1) := by
  push_cast; ring_nf

/-- At the binary dial `K = 2` the `r`-factor ceiling is `4(s+1)/(3s+2) = 4r/(3r-1)`. -/
theorem manyFactor_binary_dial :
    (s + 1) * ((2 : ℕ) : ℝ) ^ 2 / (s * ((2 : ℕ) : ℝ) ^ 2 - (s - 1) * ((2 : ℕ) : ℝ) + s) =
      4 * (s + 1) / (3 * s + 2) := by
  push_cast
  congr 1 <;> ring

/-- **Many factors: the binary dial is globally optimal.**  For `r ≥ 7`
factors (`s ≥ 6`), no dial size beats `K = 2`: the best which-factor ceiling
over *all* dial resolutions is `4r/(3r-1)`. -/
theorem manyFactor_binary_dial_optimal (hs : 6 ≤ s) {K : ℕ} (hK : 0 < K) :
    (s + 1) * (K : ℝ) ^ 2 / (s * K ^ 2 - (s - 1) * K + s) ≤ 4 * (s + 1) / (3 * s + 2) := by
  have hK1 : (1 : ℝ) ≤ K := by exact_mod_cast hK
  have hpos := manyFactor_den_pos hK1 s
  have hs' : (6 : ℝ) ≤ s := by exact_mod_cast hs
  rw [div_le_div_iff₀ hpos (by linarith)]
  have key : (0 : ℝ) ≤ ((K : ℝ) - 2) * ((s - 2) * K - 2 * s) := by
    rcases Nat.lt_or_ge K 3 with h | h
    · interval_cases K
      · norm_num; linarith
      · norm_num
    · have hK3 : (3 : ℝ) ≤ K := by exact_mod_cast h
      apply mul_nonneg (by linarith)
      nlinarith
  have hs1 : (0 : ℝ) < s + 1 := by linarith
  nlinarith [mul_nonneg hs1.le key]

/-- **Many factors collapse onto the internal cap**: the best which-factor
ceiling `4r/(3r-1)` tends to `4/3` as the number of factors grows — for
multi-prime moduli an external hint that does not name its factor is asymptotically
worth no more than an uninformative internal reading at `K = 2`. -/
theorem manyFactor_collapse_to_four_thirds :
    Filter.Tendsto (fun s : ℕ => 4 * ((s : ℝ) + 1) / (3 * s + 2)) Filter.atTop
      (nhds (4 / 3)) := by
  have hinv : Filter.Tendsto (fun s : ℕ => (1 : ℝ) / s) Filter.atTop (nhds 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have hlim : Filter.Tendsto (fun s : ℕ => 4 * (1 + 1 / (s : ℝ)) / (3 + 2 * (1 / s)))
      Filter.atTop (nhds (4 * (1 + 0) / (3 + 2 * 0))) :=
    ((tendsto_const_nhds.add hinv).const_mul 4).div
      (tendsto_const_nhds.add (hinv.const_mul 2)) (by norm_num)
  rw [show (4 : ℝ) * (1 + 0) / (3 + 2 * 0) = 4 / 3 by norm_num] at hlim
  refine hlim.congr' ?_
  filter_upwards [Filter.eventually_gt_atTop 0] with s hs
  have hs' : (s : ℝ) ≠ 0 := by exact_mod_cast hs.ne'
  have : (3 : ℝ) * s + 2 ≠ 0 := by positivity
  field_simp

end ManyFactors

end Catalog.Novelty.ExternalHintFilter