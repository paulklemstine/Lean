import Mathlib
import Probability.PositionalRateLinkLayers

/-!
# The harmonic positional law and the universal edge-decile excess (paper 230)

`Catalog/NumberTheory/FermatPositionDensity.lean` established, on the arithmetic
side, that the self-divisibility carrier of the sieve polynomial
`v(j) = (b + j)² − N` has density exactly `1/j` at position `j`, and that the
resulting harmonic weight declines from block to block.  Experiment 578/580
observed the continuum shadow of that law: hits are distributed inside the scan
window with a `1/x` ("harmonic") density, and the leading decile of the window
carries a **stable excess** over the uniform value `1/10`
(measured 0.229 / 0.245 / 0.230 in the hit-poor / mid / hit-rich terciles).

This file proves the continuum law and the universality statement.

Main results.

* `PositionalRateLink.harmCDF` – the position CDF of the harmonic density in the
  linear window coordinate `u ∈ [0,1]`, `F_r(u) = log(1 + (r−1)u) / log r`,
  where `r` is the ratio of the window endpoints.
* `harmCDF_hasDerivAt` – `F_r` is indeed the CDF of a `1/x` density.
* `harmonic_window_mass` – **scale invariance**: the harmonic mass of the
  leading `u`-fraction of the window `[a, r·a]` equals `F_r(u)` for *every*
  `a > 0`.  The profile depends on the window ratio alone, never on `N`.  This
  is the exact reason the edge-decile excess replicates across terciles.
* `harmCDF_gt_id` – **early-window excess**: `F_r(u) > u` for all `0 < u < 1`
  and `r > 1`; strict Bernoulli/concavity, no asymptotics.
* `decileMass`, `decileMass_sum`, `decileMass_nonneg`,
  `edge_decile_excess` – the induced decile profile is a genuine probability
  vector on ten bins whose first bin exceeds `1/10`.
* `edge_decile_excess_replicates` – the joint statement with the two-layer
  model: if every index carries the harmonic decile profile, then *every*
  stratum of the rate layer (hit-poor, mid, hit-rich) reproduces exactly the
  same profile, and in particular the same edge-decile excess.  Positional law
  and rate layer do not interact.
-/

open Finset Real

namespace PositionalRateLink

/-- CDF, in the linear window coordinate `u ∈ [0,1]`, of the harmonic (`1/x`)
density on a window whose endpoint ratio is `r`. -/
noncomputable def harmCDF (r u : ℝ) : ℝ := Real.log (1 + (r - 1) * u) / Real.log r

@[simp] lemma harmCDF_zero (r : ℝ) : harmCDF r 0 = 0 := by simp [harmCDF]

lemma harmCDF_one {r : ℝ} (hr : 1 < r) : harmCDF r 1 = 1 := by
  have h : (1 : ℝ) + (r - 1) * 1 = r := by ring
  rw [harmCDF, h, div_self (Real.log_pos hr).ne']

/-- `harmCDF r` is strictly increasing on the window. -/
theorem harmCDF_strictMonoOn {r : ℝ} (hr : 1 < r) :
    StrictMonoOn (harmCDF r) (Set.Icc 0 1) := by
  intro x hx y hy hxy
  have hlogr : 0 < Real.log r := Real.log_pos hr
  have hx0 : (0:ℝ) < 1 + (r - 1) * x := by nlinarith [hx.1, hx.2]
  have hxy' : 1 + (r - 1) * x < 1 + (r - 1) * y := by nlinarith
  rw [harmCDF, harmCDF, div_lt_div_iff_of_pos_right hlogr]
  exact Real.log_lt_log hx0 hxy'

/-- `harmCDF r` is the CDF of the harmonic density: its derivative at `u` is
`(r−1) / ((1 + (r−1)u) · log r)`, i.e. proportional to `1/x` at the point
`x = 1 + (r−1)u` of the window. -/
theorem harmCDF_hasDerivAt {r u : ℝ} (hr : 1 < r) (hu : 0 ≤ u) :
    HasDerivAt (harmCDF r) ((r - 1) / ((1 + (r - 1) * u) * Real.log r)) u := by
  have hpos : (0:ℝ) < 1 + (r - 1) * u := by nlinarith
  have h1 : HasDerivAt (fun t : ℝ => 1 + (r - 1) * t) (r - 1) u := by
    simpa using ((hasDerivAt_id u).const_mul (r - 1)).const_add 1
  have h2 : HasDerivAt (fun t : ℝ => Real.log (1 + (r - 1) * t)) ((r - 1) / (1 + (r-1)*u)) u := by
    simpa [div_eq_mul_inv, mul_comm] using h1.log hpos.ne'
  have h3 := h2.div_const (Real.log r)
  have hrw : (r - 1) / (1 + (r - 1) * u) / Real.log r
      = (r - 1) / ((1 + (r - 1) * u) * Real.log r) := by field_simp
  rw [← hrw]
  exact h3

/-- **Scale invariance of the harmonic profile.**  The harmonic mass of the
leading `u`-fraction of the window `[a, r·a]` is `harmCDF r u`, independently of
the scale `a`.  Two moduli `N` with the same relative scan window therefore have
*identical* positional profiles, however different their hit rates. -/
theorem harmonic_window_mass {a r u : ℝ} (ha : 0 < a) (hr : 1 < r) (hu : 0 ≤ u) :
    (Real.log (a + (r * a - a) * u) - Real.log a) / (Real.log (r * a) - Real.log a)
      = harmCDF r u := by
  have hpos : (0:ℝ) < 1 + (r - 1) * u := by nlinarith
  have h1 : a + (r * a - a) * u = a * (1 + (r - 1) * u) := by ring
  rw [h1, Real.log_mul ha.ne' hpos.ne', Real.log_mul (by linarith : (r:ℝ) ≠ 0) ha.ne', harmCDF]
  ring_nf

/-- Two windows with the same endpoint ratio have the same positional profile:
the profile is a function of the ratio only. -/
theorem harmonic_profile_scale_free {a a' r u : ℝ} (ha : 0 < a) (ha' : 0 < a')
    (hr : 1 < r) (hu : 0 ≤ u) :
    (Real.log (a + (r * a - a) * u) - Real.log a) / (Real.log (r * a) - Real.log a)
      = (Real.log (a' + (r * a' - a') * u) - Real.log a') / (Real.log (r * a') - Real.log a') := by
  rw [harmonic_window_mass ha hr hu, harmonic_window_mass ha' hr hu]

/-- **Early-window excess.**  For a harmonic profile the leading `u`-fraction of
the window always carries strictly more than a fraction `u` of the hits.  The
proof is strict Bernoulli's inequality for real exponents (`r^u < 1 + u(r−1)`),
i.e. strict concavity of `log`; no asymptotics are involved. -/
theorem harmCDF_gt_id {r u : ℝ} (hr : 1 < r) (hu0 : 0 < u) (hu1 : u < 1) : u < harmCDF r u := by
  have hlogr : 0 < Real.log r := Real.log_pos hr
  have hs : (-1 : ℝ) ≤ r - 1 := by linarith
  have hs' : r - 1 ≠ 0 := by linarith
  have key : (1 + (r - 1)) ^ u < 1 + u * (r - 1) :=
    rpow_one_add_lt_one_add_mul_self hs hs' hu0 hu1
  have hrr : (1 : ℝ) + (r - 1) = r := by ring
  rw [hrr] at key
  have hpos : (0 : ℝ) < r ^ u := Real.rpow_pos_of_pos (by linarith) u
  have hlog := Real.log_lt_log hpos key
  rw [Real.log_rpow (by linarith : (0:ℝ) < r)] at hlog
  rw [harmCDF, lt_div_iff₀ hlogr]
  calc u * Real.log r < Real.log (1 + u * (r - 1)) := hlog
    _ = Real.log (1 + (r - 1) * u) := by rw [mul_comm u (r-1)]

/-! ### The decile profile -/

/-- Mass of the `k`-th decile of the window under the harmonic law. -/
noncomputable def decileMass (r : ℝ) (k : ℕ) : ℝ :=
  harmCDF r ((k + 1) / 10) - harmCDF r (k / 10)

/-- The ten decile masses sum to `1`. -/
theorem decileMass_sum {r : ℝ} (hr : 1 < r) : ∑ k : Fin 10, decileMass r (k : ℕ) = 1 := by
  rw [Fin.sum_univ_eq_sum_range (fun k => decileMass r k) 10]
  have h := Finset.sum_range_sub (fun k : ℕ => harmCDF r ((k : ℝ) / 10)) 10
  push_cast at h
  simp only [decileMass]
  rw [h]
  norm_num [harmCDF_one hr]

theorem decileMass_nonneg {r : ℝ} (hr : 1 < r) (k : Fin 10) : 0 ≤ decileMass r (k : ℕ) := by
  have hk9 : ((k : ℕ) : ℝ) ≤ 9 := by
    have : (k : ℕ) ≤ 9 := by omega
    exact_mod_cast this
  have hk0 : (0:ℝ) ≤ ((k : ℕ) : ℝ) := Nat.cast_nonneg _
  have h1 : (((k : ℕ) : ℝ)) / 10 ∈ Set.Icc (0:ℝ) 1 := ⟨by linarith, by linarith⟩
  have h2 : ((((k : ℕ) : ℝ)) + 1) / 10 ∈ Set.Icc (0:ℝ) 1 := ⟨by linarith, by linarith⟩
  have hmono := harmCDF_strictMonoOn hr h1 h2 (by linarith)
  simp only [decileMass]
  linarith

/-- **Edge-decile excess.**  The leading decile of the window carries strictly
more than one tenth of the hits, for every window ratio `r > 1`. -/
theorem edge_decile_excess {r : ℝ} (hr : 1 < r) : 1 / 10 < decileMass r 0 := by
  have h := harmCDF_gt_id (r := r) (u := 1/10) hr (by norm_num) (by norm_num)
  simp only [decileMass]
  norm_num at h ⊢
  linarith

/-! ### Joint statement with the two-layer model -/

/-- The two-layer model in which every index carries the harmonic decile
profile, with an arbitrary rate layer. -/
noncomputable def harmonicModel {ι : Type*} [Fintype ι] (r : ℝ) (hr : 1 < r)
    (rate : ι → ℝ) (hrate : ∀ i, 0 < rate i) : TwoLayer ι (Fin 10) where
  rate := rate
  rate_pos := hrate
  prof := fun _ k => decileMass r (k : ℕ)
  prof_nonneg := fun _ k => decileMass_nonneg hr k
  prof_sum := fun _ => decileMass_sum hr

/-- **Universality of the edge-decile excess across rate strata.**  If the
positional layer is the harmonic law, then every stratum of the rate layer — the
hit-poor, mid and hit-rich terciles alike — reproduces exactly the same decile
profile, and in particular exactly the same edge-decile excess above `1/10`.
This is the formal content of the exp-580 observation
`0.229 / 0.245 / 0.230` together with the failure of the interaction test. -/
theorem edge_decile_excess_replicates {ι : Type*} [Fintype ι] {r : ℝ} (hr : 1 < r)
    (rate : ι → ℝ) (hrate : ∀ i, 0 < rate i) (w : ι → ℝ) (S : Finset ι)
    (hS : (harmonicModel r hr rate hrate).mass w S ≠ 0) :
    (harmonicModel r hr rate hrate).normProf w S = (fun k : Fin 10 => decileMass r (k : ℕ)) ∧
      1 / 10 < (harmonicModel r hr rate hrate).normProf w S ⟨0, by norm_num⟩ := by
  have hhom : ∀ i, (harmonicModel r hr rate hrate).prof i
      = fun k : Fin 10 => decileMass r (k : ℕ) := fun _ => rfl
  have heq := TwoLayer.normProf_of_homogeneous (harmonicModel r hr rate hrate) hhom w S hS
  refine ⟨heq, ?_⟩
  rw [heq]
  simpa using edge_decile_excess hr

/-- Consequently, any two rate strata have identical harmonic decile profiles:
the KS contrast between hit-rich and hit-poor terciles is exactly zero at the
population level. -/
theorem harmonic_strata_indistinguishable {ι : Type*} [Fintype ι] {r : ℝ} (hr : 1 < r)
    (rate : ι → ℝ) (hrate : ∀ i, 0 < rate i) (w : ι → ℝ) (S T : Finset ι)
    (hS : (harmonicModel r hr rate hrate).mass w S ≠ 0)
    (hT : (harmonicModel r hr rate hrate).mass w T ≠ 0) :
    (harmonicModel r hr rate hrate).normProf w S
      = (harmonicModel r hr rate hrate).normProf w T :=
  TwoLayer.strata_profiles_eq _ (fun _ => rfl) w S T hS hT

end PositionalRateLink