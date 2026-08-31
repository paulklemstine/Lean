/-
# A single exchange already saturates the floor: Diophantine dynamics of the PTX slack

Cycle 3 of the PTX starvation programme.  Cycle 1 showed that the slack spectrum
`{service / ideal}` over *all* PTX instances is exactly `[1, 2)`.  That leaves a sharper
question, invisible at the level of instances:

> can a **single** exchange, watched over time, see the whole spectrum?

Here the demand of a class grows geometrically, `d ↦ α · d`, so the ideal share runs along the
ladder `α^n`.  The log-slack of the dyadic arbiter on that ladder is
```
logSlack (α ^ n) = Int.fract (−n · log₂ α),
```
an orbit of the rotation by `−log₂ α` on the circle `ℝ/ℤ` (`logSlack_zpow`).  Classical
Diophantine dynamics then decides everything:

* `ptx_slack_orbit_dense_of_irrational` : if `log₂ α` is irrational, the log-slacks come
  `ε`-close to every value in `(0,1)`, hence
  `ptx_slack_closure_of_irrational` : the closure of the orbit is all of `[0,1]`.  A single
  exchange saturates the floor *and* the factor-`2` ceiling over time
  (`ptx_single_exchange_realises_sharpness`).
* `logSlack_zpow_periodic`, `ptx_slack_orbit_finite_of_rational` : if `log₂ α = p/q` is
  rational the orbit is periodic with period `q` and takes finitely many values, so it is
  *not* dense (`ptx_slack_not_dense_of_rational`).
* `ptx_slack_orbit_dichotomy` : density of the slack orbit is **equivalent** to irrationality
  of `log₂ α`.  Sharpness of the no-starvation floor for a fixed exchange is therefore a
  Diophantine property of the growth ratio, not a scheduling property.

Note that `log₂ α` is irrational for every `α` that is not a rational power of `2`; e.g.
`α = 3` (`logb 2 3` irrational) makes a single exchange see the entire slack spectrum.
-/

import Physics.PTXStarvationJitter

namespace Physics.PTX

open Real

/-! ## 1. The slack of the dyadic arbiter as a circle rotation -/

/-- The multiplicative slack of the dyadic arbiter at request size `x`. -/
noncomputable def slack (x : ℝ) : ℝ := gridCeil 2 x / x

/-- The log-slack, i.e. the slack measured in backoff levels. -/
noncomputable def logSlack (x : ℝ) : ℝ := Real.logb 2 (slack x)

lemma slack_eq_rpow_logSlack {x : ℝ} (hx : 0 < x) : slack x = (2 : ℝ) ^ (logSlack x) := by
  have hpos : 0 < slack x := div_pos (gridCeil_pos (by norm_num)) hx
  rw [logSlack, Real.rpow_logb (by norm_num) (by norm_num) hpos]

/-- The log-slack is the ceiling defect of `log₂ x`, i.e. the fractional part of `−log₂ x`. -/
theorem logSlack_eq_fract {x : ℝ} (hx : 0 < x) :
    logSlack x = Int.fract (-Real.logb 2 x) := by
  have hlog : (2:ℝ) ^ (Real.logb 2 x) = x := Real.rpow_logb (by norm_num) (by norm_num) hx
  have hdiv : slack x = (2:ℝ) ^ (((⌈Real.logb 2 x⌉ : ℤ) : ℝ) - Real.logb 2 x) := by
    rw [slack, Real.rpow_sub (by norm_num), gridCeil_eq_rpow, hlog]
  rw [logSlack, hdiv, Real.logb_rpow (by norm_num) (by norm_num)]
  exact ceil_sub_self_eq_fract_neg _

/-- Along a geometric demand ladder the log-slack is the orbit of a circle rotation. -/
theorem logSlack_zpow {alpha : ℝ} (halpha : 0 < alpha) (n : ℤ) :
    logSlack (alpha ^ n) = Int.fract ((n : ℝ) * (-Real.logb 2 alpha)) := by
  have hpow : (0:ℝ) < alpha ^ n := zpow_pos halpha n
  have hlogb : Real.logb 2 (alpha ^ n) = (n : ℝ) * Real.logb 2 alpha := by
    rw [Real.logb, Real.logb, Real.log_zpow]
    ring
  rw [logSlack_eq_fract hpow, hlogb]
  ring_nf

/-! ## 2. Diophantine input: irrational rotations are dense -/

/-- **Kronecker's theorem, in the form we need.**  If `θ` is irrational, the fractional parts of
its integer multiples come arbitrarily close to every point of `(0,1)`. -/
theorem fract_zsmul_approx {theta : ℝ} (h : Irrational theta) {y : ℝ} (hy0 : 0 < y)
    (hy1 : y < 1) {eps : ℝ} (heps : 0 < eps) :
    ∃ n : ℤ, |Int.fract ((n : ℝ) * theta) - y| < eps := by
  have hd : Dense ((AddSubgroup.closure {theta, (1:ℝ)} : AddSubgroup ℝ) : Set ℝ) := by
    rw [dense_addSubgroupClosure_pair_iff]
    simpa using h
  set delta := min eps (min y (1 - y)) with hdelta
  have hdpos : 0 < delta := lt_min heps (lt_min hy0 (by linarith))
  obtain ⟨z, hz, hzd⟩ := hd.exists_dist_lt y hdpos
  obtain ⟨m, k, hmk⟩ := AddSubgroup.mem_closure_pair.1 hz
  refine ⟨m, ?_⟩
  have hzy : |z - y| < delta := by rwa [dist_comm, Real.dist_eq] at hzd
  obtain ⟨hlo, hhi⟩ := abs_lt.1 hzy
  have hz0 : 0 < z := by
    have : delta ≤ y := le_trans (min_le_right _ _) (min_le_left _ _)
    linarith
  have hz1 : z < 1 := by
    have : delta ≤ 1 - y := le_trans (min_le_right _ _) (min_le_right _ _)
    linarith
  have hfr : Int.fract ((m:ℝ) * theta) = z := by
    have hrw : (m:ℝ) * theta = z - k := by rw [← hmk]; ring
    rw [hrw, Int.fract_sub_intCast, Int.fract_eq_self.2 ⟨le_of_lt hz0, hz1⟩]
  rw [hfr]
  exact lt_of_lt_of_le hzy (min_le_left _ _)

/-! ## 3. The irrational case: one exchange sees the whole spectrum -/

/-- **Density of the slack orbit.**  If `log₂ α` is irrational, the log-slacks of the geometric
demand ladder `α^n` approximate every value in `(0,1)`. -/
theorem ptx_slack_orbit_dense_of_irrational {alpha : ℝ} (halpha : 0 < alpha)
    (h : Irrational (Real.logb 2 alpha)) {s : ℝ} (hs0 : 0 < s) (hs1 : s < 1) {eps : ℝ}
    (heps : 0 < eps) : ∃ n : ℤ, |logSlack (alpha ^ n) - s| < eps := by
  obtain ⟨n, hn⟩ := fract_zsmul_approx h.neg hs0 hs1 heps
  exact ⟨n, by rwa [logSlack_zpow halpha n]⟩

/-- The closure of the log-slack orbit is the whole interval `[0,1]`. -/
theorem ptx_slack_closure_of_irrational {alpha : ℝ} (halpha : 0 < alpha)
    (h : Irrational (Real.logb 2 alpha)) :
    Set.Icc (0:ℝ) 1 ⊆ closure (Set.range fun n : ℤ => logSlack (alpha ^ n)) := by
  have hsub : Set.Ioo (0:ℝ) 1 ⊆ closure (Set.range fun n : ℤ => logSlack (alpha ^ n)) := by
    intro s hs
    rw [Metric.mem_closure_iff]
    intro eps heps
    obtain ⟨n, hn⟩ := ptx_slack_orbit_dense_of_irrational halpha h hs.1 hs.2 heps
    refine ⟨logSlack (alpha ^ n), Set.mem_range_self n, ?_⟩
    rw [Real.dist_eq, abs_sub_comm]
    exact hn
  calc Set.Icc (0:ℝ) 1 = closure (Set.Ioo (0:ℝ) 1) := (closure_Ioo (by norm_num)).symm
    _ ⊆ closure (closure (Set.range fun n : ℤ => logSlack (alpha ^ n))) := closure_mono hsub
    _ = closure (Set.range fun n : ℤ => logSlack (alpha ^ n)) := closure_closure

/-- **A single exchange saturates both ends of the slack spectrum.**  With an irrational
growth exponent the demand ladder produces slacks arbitrarily close to the ceiling `2` and
arbitrarily close to the floor `1`. -/
theorem ptx_single_exchange_realises_sharpness {alpha : ℝ} (halpha : 0 < alpha)
    (h : Irrational (Real.logb 2 alpha)) {eps : ℝ} (heps : 0 < eps) (heps1 : eps < 1) :
    (∃ n : ℤ, (2:ℝ) ^ (1 - eps) < slack (alpha ^ n)) ∧
      (∃ m : ℤ, slack (alpha ^ m) < (2:ℝ) ^ eps) := by
  constructor
  · obtain ⟨n, hn⟩ := ptx_slack_orbit_dense_of_irrational halpha h
      (s := 1 - eps / 2) (by linarith) (by linarith) (eps := eps / 4) (by linarith)
    refine ⟨n, ?_⟩
    rw [slack_eq_rpow_logSlack (zpow_pos halpha n)]
    apply (Real.rpow_lt_rpow_left_iff (by norm_num)).2
    have := abs_lt.1 hn
    linarith [this.1]
  · obtain ⟨m, hm⟩ := ptx_slack_orbit_dense_of_irrational halpha h
      (s := eps / 2) (by linarith) (by linarith) (eps := eps / 4) (by linarith)
    refine ⟨m, ?_⟩
    rw [slack_eq_rpow_logSlack (zpow_pos halpha m)]
    apply (Real.rpow_lt_rpow_left_iff (by norm_num)).2
    have := abs_lt.1 hm
    linarith [this.2]

/-! ## 4. The rational case: a finite, periodic orbit -/

/-- If `log₂ α = p/q`, the log-slack orbit is periodic with period `q`. -/
theorem logSlack_zpow_periodic {alpha : ℝ} (halpha : 0 < alpha) {p q : ℤ} (hq : q ≠ 0)
    (hlog : Real.logb 2 alpha = (p : ℝ) / (q : ℝ)) (n k : ℤ) :
    logSlack (alpha ^ (n + k * q)) = logSlack (alpha ^ n) := by
  have hqR : (q : ℝ) ≠ 0 := Int.cast_ne_zero.2 hq
  rw [logSlack_zpow halpha, logSlack_zpow halpha, hlog]
  have hrw : ((n + k * q : ℤ) : ℝ) * (-((p : ℝ) / (q : ℝ)))
      = (n : ℝ) * (-((p : ℝ) / (q : ℝ))) - ((k * p : ℤ) : ℝ) := by
    push_cast
    field_simp
    ring
  rw [hrw, Int.fract_sub_intCast]

/-- In the rational case the slack orbit takes only finitely many values. -/
theorem ptx_slack_orbit_finite_of_rational {alpha : ℝ} (halpha : 0 < alpha) {p q : ℤ}
    (hq : 0 < q) (hlog : Real.logb 2 alpha = (p : ℝ) / (q : ℝ)) :
    (Set.range fun n : ℤ => logSlack (alpha ^ n)).Finite := by
  have hsub : (Set.range fun n : ℤ => logSlack (alpha ^ n))
      ⊆ (fun n : ℤ => logSlack (alpha ^ n)) '' (Set.Ico (0:ℤ) q) := by
    rintro _ ⟨n, rfl⟩
    refine ⟨n % q, ⟨Int.emod_nonneg n (ne_of_gt hq), Int.emod_lt_of_pos n hq⟩, ?_⟩
    have hdecomp : n = n % q + (n / q) * q := by
      have h1 : n % q + q * (n / q) = n := Int.emod_add_mul_ediv n q
      have h2 : q * (n / q) = (n / q) * q := mul_comm _ _
      linarith
    calc logSlack (alpha ^ (n % q))
        = logSlack (alpha ^ (n % q + (n / q) * q)) :=
          (logSlack_zpow_periodic halpha (ne_of_gt hq) hlog _ _).symm
      _ = logSlack (alpha ^ n) := by rw [← hdecomp]
  exact Set.Finite.subset (Set.Finite.image _ (Set.finite_Ico _ _)) hsub

/-- A finite orbit cannot be dense in `[0,1]`, so in the rational case the exchange never sees
the whole slack spectrum. -/
theorem ptx_slack_not_dense_of_rational {alpha : ℝ} (halpha : 0 < alpha) {p q : ℤ}
    (hq : 0 < q) (hlog : Real.logb 2 alpha = (p : ℝ) / (q : ℝ)) :
    ¬ Set.Icc (0:ℝ) 1 ⊆ closure (Set.range fun n : ℤ => logSlack (alpha ^ n)) := by
  intro hsub
  have hfin := ptx_slack_orbit_finite_of_rational halpha hq hlog
  have hclosed : closure (Set.range fun n : ℤ => logSlack (alpha ^ n))
      = Set.range fun n : ℤ => logSlack (alpha ^ n) := hfin.isClosed.closure_eq
  rw [hclosed] at hsub
  exact (Set.Icc_infinite (by norm_num : (0:ℝ) < 1)) (Set.Finite.subset hfin hsub)

/-! ## 5. The dichotomy -/

/-- **Diophantine dichotomy for the starvation slack.**  A geometrically growing exchange sees a
dense set of slacks precisely when its growth exponent `log₂ α` is irrational. -/
theorem ptx_slack_orbit_dichotomy {alpha : ℝ} (halpha : 0 < alpha) :
    (Set.Icc (0:ℝ) 1 ⊆ closure (Set.range fun n : ℤ => logSlack (alpha ^ n)))
      ↔ Irrational (Real.logb 2 alpha) := by
  constructor
  · intro hdense
    by_contra hrat
    rw [Irrational, not_not] at hrat
    obtain ⟨r, hr⟩ := hrat
    have hq : (0:ℤ) < (r.den : ℤ) := by exact_mod_cast r.pos
    have hlog : Real.logb 2 alpha = ((r.num : ℤ) : ℝ) / (((r.den : ℤ)) : ℝ) := by
      rw [← hr]
      push_cast
      exact Rat.cast_def r
    exact ptx_slack_not_dense_of_rational halpha hq hlog hdense
  · exact fun h => ptx_slack_closure_of_irrational halpha h

/-! ## 6. Back to the exchange -/

/-- The slack of the one-class witness exchange with demand `x` is exactly `slack x`, so all the
statements above are statements about `service / ideal` in a genuine PTX instance. -/
theorem witness_service_div_ideal {x : ℝ} (hx : 0 < x) :
    service (witness x hx) () / ideal (witness x hx) () = slack x := by
  rw [service, witness_ideal x hx (), slack]

/-! ## 7. A concrete saturating exchange: ternary demand growth -/

/-- `log₂ 3` is irrational: if `log₂ 3 = p/q` then `3^q = 2^p`, contradicting unique
factorisation. -/
theorem irrational_logb_two_three : Irrational (Real.logb 2 3) := by
  rintro ⟨r, hr⟩
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hlog3 : (0:ℝ) < Real.log 3 := Real.log_pos (by norm_num)
  have hden : ((r.den : ℝ)) ≠ 0 := Nat.cast_ne_zero.2 r.den_nz
  have hrpos : 0 < r := by
    have hp : (0:ℝ) < Real.logb 2 3 := Real.logb_pos (by norm_num) (by norm_num)
    rw [← hr] at hp
    exact_mod_cast hp
  have hnum : 0 < r.num := Rat.num_pos.2 hrpos
  have h : Real.logb 2 3 = (r.num : ℝ) / (r.den : ℝ) := by rw [← hr, Rat.cast_def]
  have hkey : (r.den : ℝ) * Real.log 3 = (r.num : ℝ) * Real.log 2 := by
    rw [Real.logb] at h
    field_simp at h
    linarith
  set p : ℕ := r.num.toNat with hp
  have hpcast : (r.num : ℝ) = (p : ℝ) := by
    rw [hp]
    exact_mod_cast (Int.toNat_of_nonneg (le_of_lt hnum)).symm
  have hppos : 0 < p := by
    have : 0 < r.num.toNat := by omega
    rwa [hp]
  have h1 : Real.log ((3:ℝ) ^ (r.den)) = Real.log ((2:ℝ) ^ p) := by
    rw [Real.log_pow, Real.log_pow, ← hpcast]
    linarith
  have heq : ((3:ℝ) ^ (r.den) : ℝ) = ((2:ℝ) ^ p : ℝ) := by
    have h2 : (0:ℝ) < (3:ℝ) ^ (r.den) := by positivity
    have h3 : (0:ℝ) < (2:ℝ) ^ p := by positivity
    have h4 := congrArg Real.exp h1
    rwa [Real.exp_log h2, Real.exp_log h3] at h4
  have hnat : (3:ℕ) ^ r.den = 2 ^ p := by exact_mod_cast heq
  have hdvd : (2:ℕ) ∣ 3 ^ r.den := by
    rw [hnat]
    exact dvd_pow_self 2 (by omega)
  have hcontra := Nat.Prime.dvd_of_dvd_pow Nat.prime_two hdvd
  norm_num at hcontra

/-- **A concrete exchange that saturates the sharp floor.**  If demand grows by a factor of `3`
per round, the dyadic arbiter's log-slacks are dense in `[0,1]`, hence the slack itself comes
arbitrarily close to both `1` and `2`. -/
theorem ptx_ternary_growth_saturates :
    Set.Icc (0:ℝ) 1 ⊆ closure (Set.range fun n : ℤ => logSlack ((3:ℝ) ^ n)) :=
  ptx_slack_closure_of_irrational (by norm_num) irrational_logb_two_three

/-- Quantitative form for ternary growth: some round overshoots by more than `2^{1-ε}` and some
round is within `2^ε` of the floor. -/
theorem ptx_ternary_growth_sharpness {eps : ℝ} (heps : 0 < eps) (heps1 : eps < 1) :
    (∃ n : ℤ, (2:ℝ) ^ (1 - eps) < slack ((3:ℝ) ^ n)) ∧
      (∃ m : ℤ, slack ((3:ℝ) ^ m) < (2:ℝ) ^ eps) :=
  ptx_single_exchange_realises_sharpness (by norm_num) irrational_logb_two_three heps heps1

end Physics.PTX