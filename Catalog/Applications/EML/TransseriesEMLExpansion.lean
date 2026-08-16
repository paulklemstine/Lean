import Applications.EML.TransseriesRoots

/-!
# EML functions and their transseries expansions

This file connects the formal transseries field `EMLTS.TS` with genuine real functions.

To a growth rank `r = rk d a b c` we attach the real function

  `rankFun r x = exp (-d · exp x) · exp (-a · x) · x ^ (-b) · (log x) ^ (-c)`,

the transmonomial that `r` names (recall that in `EMLTS` a *small* rank is a *large*
transseries, whence the signs).  A finitely supported family `p : Rank →₀ ℝ` of
coefficients then determines both

* a transseries `EMLTS.toTS p : TS`, and
* an EML function `EMLTS.EMLFun p : ℝ → ℝ`, a finite linear combination of
  transmonomials.

The main results are:

* `EMLTS.tendsto_rankFun_zero` : a transmonomial of positive rank tends to `0`; this is
  the analytic content of the lexicographic ordering of growth ranks
  (`exp (exp x) ≫ exp x ≫ x ≫ log x`).
* `EMLTS.eventually_pos_of_toTS_pos` : an EML function whose transseries is positive is
  eventually positive — the *asymptotic sign theorem*.
* `EMLTS.eventuallyEq_iff_toTS_eq` : two EML functions are eventually equal iff their
  transseries expansions agree to all orders.  Thus the transseries expansion of an EML
  function determines the function, and conversely: this is the asymptotic comparison
  theorem for EML functions.
* `EMLTS.eventually_lt_iff_toTS_lt` : the expansion is an *order* embedding — the germ at
  `+∞` of an EML function is smaller iff its transseries is smaller.  So EML functions
  form an ordered ring embedded in the transseries field (a Hardy-field statement).
-/

noncomputable section

open Filter Asymptotics Real HahnSeries

open scoped Topology

namespace EMLTS

/-! ## Reading off the four exponents of a rank -/

/-- Double-exponential rate of a rank. -/
def rd (r : Rank) : ℝ := (ofLex r).1
/-- Exponential rate of a rank. -/
def ra (r : Rank) : ℝ := (ofLex (ofLex r).2).1
/-- Power of `x` of a rank. -/
def rb (r : Rank) : ℝ := (ofLex (ofLex (ofLex r).2).2).1
/-- Power of `log x` of a rank. -/
def rc (r : Rank) : ℝ := (ofLex (ofLex (ofLex r).2).2).2

@[simp] theorem rd_rk (d a b c : ℝ) : rd (rk d a b c) = d := rfl
@[simp] theorem ra_rk (d a b c : ℝ) : ra (rk d a b c) = a := rfl
@[simp] theorem rb_rk (d a b c : ℝ) : rb (rk d a b c) = b := rfl
@[simp] theorem rc_rk (d a b c : ℝ) : rc (rk d a b c) = c := rfl

@[simp] theorem rd_add (r s : Rank) : rd (r + s) = rd r + rd s := rfl
@[simp] theorem ra_add (r s : Rank) : ra (r + s) = ra r + ra s := rfl
@[simp] theorem rb_add (r s : Rank) : rb (r + s) = rb r + rb s := rfl
@[simp] theorem rc_add (r s : Rank) : rc (r + s) = rc r + rc s := rfl

theorem rk_eta (r : Rank) : rk (rd r) (ra r) (rb r) (rc r) = r := rfl

/-- Lexicographic positivity of a rank, spelled out in the four exponents. -/
theorem rank_pos_iff {r : Rank} :
    0 < r ↔ 0 < rd r ∨ (rd r = 0 ∧ (0 < ra r ∨ (ra r = 0 ∧
      (0 < rb r ∨ (rb r = 0 ∧ 0 < rc r))))) := by
  conv_lhs => rw [← rk_eta r, show (0 : Rank) = rk 0 0 0 0 from rfl]
  rw [rk_lt_rk_iff]
  simp only [eq_comm]

/-! ## Transmonomials as real functions -/

/-- The logarithm of the transmonomial named by a rank. -/
def rankLog (r : Rank) (x : ℝ) : ℝ :=
  -(rd r * Real.exp x + ra r * x + rb r * Real.log x + rc r * Real.log (Real.log x))

/-- The transmonomial named by a rank, as a real function:
`rankFun (rk d a b c) x = exp (-d exp x) exp (-a x) x ^ (-b) (log x) ^ (-c)`. -/
def rankFun (r : Rank) (x : ℝ) : ℝ := Real.exp (rankLog r x)

theorem rankFun_pos (r : Rank) (x : ℝ) : 0 < rankFun r x := Real.exp_pos _

theorem rankFun_ne_zero (r : Rank) (x : ℝ) : rankFun r x ≠ 0 := (rankFun_pos r x).ne'

@[simp] theorem rankFun_zero (x : ℝ) : rankFun 0 x = 1 := by
  simp [rankFun, rankLog, rd, ra, rb, rc]

theorem rankFun_add (r s : Rank) (x : ℝ) :
    rankFun (r + s) x = rankFun r x * rankFun s x := by
  simp only [rankFun, rankLog, rd_add, ra_add, rb_add, rc_add, ← Real.exp_add]
  ring_nf

theorem rankFun_neg (r : Rank) (x : ℝ) : rankFun (-r) x = (rankFun r x)⁻¹ := by
  have h : rankFun (-r) x * rankFun r x = 1 := by
    rw [← rankFun_add, neg_add_cancel, rankFun_zero]
  exact eq_inv_of_mul_eq_one_left h

theorem rankFun_sub (r s : Rank) (x : ℝ) :
    rankFun (r - s) x = rankFun r x / rankFun s x := by
  rw [sub_eq_add_neg, rankFun_add, rankFun_neg, div_eq_mul_inv]

/-- On `(1, ∞)` the abstract definition of `rankFun` really is the transmonomial
`exp (-d exp x) · exp (-a x) · x ^ (-b) · (log x) ^ (-c)`. -/
theorem rankFun_eq_transmonomial {d a b c x : ℝ} (hx : 1 < x) :
    rankFun (rk d a b c) x =
      Real.exp (-d * Real.exp x) * Real.exp (-a * x) * x ^ (-b) * (Real.log x) ^ (-c) := by
  have hx0 : (0 : ℝ) < x := lt_trans zero_lt_one hx
  have hlog : 0 < Real.log x := Real.log_pos hx
  rw [Real.rpow_def_of_pos hx0, Real.rpow_def_of_pos hlog]
  simp only [rankFun, rankLog, rd_rk, ra_rk, rb_rk, rc_rk, ← Real.exp_add]
  congr 1
  ring

/-! ## The dominance limits -/

private theorem tendsto_atTop_of_pos_mul_add {g h : ℝ → ℝ} {D : ℝ} (hD : 0 < D)
    (hg : Tendsto g atTop atTop) (hh : h =o[atTop] g) :
    Tendsto (fun x => D * g x + h x) atTop atTop := by
  have hbound := hh.bound (c := D / 2) (by positivity)
  have hgnn : ∀ᶠ x in atTop, 0 ≤ g x := hg.eventually_ge_atTop 0
  have hmono : ∀ᶠ x in atTop, (D / 2) * g x ≤ D * g x + h x := by
    filter_upwards [hbound, hgnn] with x hx hgx
    have h1 : |h x| ≤ (D / 2) * |g x| := by simpa using hx
    have h2 : |g x| = g x := abs_of_nonneg hgx
    rw [h2] at h1
    linarith [neg_abs_le (h x)]
  refine tendsto_atTop_mono' _ hmono ?_
  exact hg.const_mul_atTop (by positivity)

private theorem isLittleO_id_exp : (fun x : ℝ => x) =o[atTop] Real.exp := by
  simpa using Real.isLittleO_pow_exp_atTop (n := 1)

private theorem isLittleO_log_exp : Real.log =o[atTop] Real.exp :=
  Real.isLittleO_log_id_atTop.trans isLittleO_id_exp

private theorem isLittleO_loglog_log :
    (fun x : ℝ => Real.log (Real.log x)) =o[atTop] Real.log :=
  Real.isLittleO_log_id_atTop.comp_tendsto Real.tendsto_log_atTop

private theorem isLittleO_loglog_id :
    (fun x : ℝ => Real.log (Real.log x)) =o[atTop] (fun x : ℝ => x) :=
  isLittleO_loglog_log.trans Real.isLittleO_log_id_atTop

private theorem isLittleO_loglog_exp :
    (fun x : ℝ => Real.log (Real.log x)) =o[atTop] Real.exp :=
  isLittleO_loglog_log.trans isLittleO_log_exp

/-- **The scale hierarchy, analytically.**  If a rank is lexicographically positive then
the transmonomial it names tends to `0` at `+∞`. -/
theorem tendsto_rankFun_zero {r : Rank} (hr : 0 < r) :
    Tendsto (rankFun r) atTop (𝓝 0) := by
  have key : Tendsto (fun x => rd r * Real.exp x + ra r * x + rb r * Real.log x
      + rc r * Real.log (Real.log x)) atTop atTop := by
    rcases rank_pos_iff.mp hr with hd | ⟨hd, hcase⟩
    · have := tendsto_atTop_of_pos_mul_add (g := Real.exp)
        (h := fun x => ra r * x + rb r * Real.log x + rc r * Real.log (Real.log x)) hd
        Real.tendsto_exp_atTop
        (((isLittleO_id_exp.const_mul_left (ra r)).add
          (isLittleO_log_exp.const_mul_left (rb r))).add
          (isLittleO_loglog_exp.const_mul_left (rc r)))
      refine this.congr fun x => by ring
    · rcases hcase with ha | ⟨ha, hcase⟩
      · have := tendsto_atTop_of_pos_mul_add (g := fun x : ℝ => x)
          (h := fun x => rb r * Real.log x + rc r * Real.log (Real.log x)) ha
          tendsto_id
          ((Real.isLittleO_log_id_atTop.const_mul_left (rb r)).add
            (isLittleO_loglog_id.const_mul_left (rc r)))
        refine this.congr fun x => by rw [hd]; ring
      · rcases hcase with hb | ⟨hb, hc⟩
        · have := tendsto_atTop_of_pos_mul_add (g := Real.log)
            (h := fun x => rc r * Real.log (Real.log x)) hb
            Real.tendsto_log_atTop
            (isLittleO_loglog_log.const_mul_left (rc r))
          refine this.congr fun x => by rw [hd, ha]; ring
        · have := (Real.tendsto_log_atTop.comp Real.tendsto_log_atTop).const_mul_atTop hc
          refine this.congr fun x => by rw [hd, ha, hb]; simp [Function.comp]
  have : Tendsto (fun x => rankLog r x) atTop atBot :=
    (tendsto_neg_atTop_atBot.comp key).congr fun x => rfl
  simpa [rankFun] using Real.tendsto_exp_atBot.comp this

/-! ## EML functions and their expansions -/

/-- The transseries determined by a finitely supported family of coefficients. -/
def toTS (p : Rank →₀ ℝ) : TS := toLex (HahnSeries.ofFinsupp p)

@[simp] theorem coeff_toTS (p : Rank →₀ ℝ) (g : Rank) : (ofLex (toTS p)).coeff g = p g := rfl

theorem toTS_injective : Function.Injective toTS := by
  intro p q h
  ext g
  simpa using congrArg (fun t : TS => (ofLex t).coeff g) h

@[simp] theorem toTS_zero : toTS 0 = 0 := by
  refine ofLex.injective (HahnSeries.ext ?_)
  funext g
  simp

@[simp] theorem toTS_add (p q : Rank →₀ ℝ) : toTS (p + q) = toTS p + toTS q := by
  refine ofLex.injective (HahnSeries.ext ?_)
  funext g
  simp

@[simp] theorem toTS_neg (p : Rank →₀ ℝ) : toTS (-p) = -toTS p := by
  refine ofLex.injective (HahnSeries.ext ?_)
  funext g
  simp

theorem toTS_sub (p q : Rank →₀ ℝ) : toTS (p - q) = toTS p - toTS q := by
  rw [sub_eq_add_neg, toTS_add, toTS_neg, sub_eq_add_neg]

/-- The EML function determined by a finitely supported family of coefficients: the finite
linear combination `∑ p g • rankFun g` of transmonomials. -/
def EMLFun (p : Rank →₀ ℝ) (x : ℝ) : ℝ := p.sum fun g c => c * rankFun g x

theorem EMLFun_eq_sum (p : Rank →₀ ℝ) (x : ℝ) :
    EMLFun p x = ∑ g ∈ p.support, p g * rankFun g x := rfl

@[simp] theorem EMLFun_zero (x : ℝ) : EMLFun 0 x = 0 := by simp [EMLFun]

theorem EMLFun_add (p q : Rank →₀ ℝ) (x : ℝ) :
    EMLFun (p + q) x = EMLFun p x + EMLFun q x :=
  Finsupp.sum_add_index' (fun g => by simp) (fun g c c' => by ring)

theorem EMLFun_neg (p : Rank →₀ ℝ) (x : ℝ) : EMLFun (-p) x = -EMLFun p x := by
  simp only [EMLFun_eq_sum, Finsupp.support_neg, Finsupp.coe_neg, Pi.neg_apply, neg_mul,
    Finset.sum_neg_distrib]

theorem EMLFun_sub (p q : Rank →₀ ℝ) (x : ℝ) :
    EMLFun (p - q) x = EMLFun p x - EMLFun q x := by
  rw [sub_eq_add_neg, EMLFun_add, EMLFun_neg, sub_eq_add_neg]

/-! ## The asymptotic sign theorem -/

/-- The transseries of a nonzero family is positive exactly when the coefficient of its
dominant (lexicographically least) rank is positive. -/
theorem toTS_pos_iff {p : Rank →₀ ℝ}
    (hne : p.support.Nonempty) : 0 < toTS p ↔ 0 < p (p.support.min' hne) := by
  set g0 := p.support.min' hne with hg0
  have hg0mem : g0 ∈ p.support := p.support.min'_mem hne
  constructor
  · intro h
    obtain ⟨i, hj, hi⟩ := (HahnSeries.lt_iff _ _).mp h
    simp only [ofLex_zero, HahnSeries.coeff_zero, coeff_toTS] at hj hi
    have himem : i ∈ p.support := Finsupp.mem_support_iff.mpr hi.ne'
    have hle : g0 ≤ i := p.support.min'_le i himem
    rcases hle.eq_or_lt with heq | hlt
    · rwa [← heq] at hi
    · exact absurd (hj g0 hlt).symm (Finsupp.mem_support_iff.mp hg0mem)
  · intro h
    refine (HahnSeries.lt_iff _ _).mpr ⟨g0, fun j hj => ?_, ?_⟩
    · have : j ∉ p.support := fun hmem => absurd (p.support.min'_le j hmem) (not_le.mpr hj)
      simp [Finsupp.notMem_support_iff.mp this]
    · simpa using h

/-- **Asymptotic sign theorem.**  Dividing an EML function by its dominant transmonomial
converges to the dominant coefficient. -/
theorem tendsto_EMLFun_div {p : Rank →₀ ℝ} (hne : p.support.Nonempty) :
    Tendsto (fun x => EMLFun p x / rankFun (p.support.min' hne) x) atTop
      (𝓝 (p (p.support.min' hne))) := by
  classical
  set g0 := p.support.min' hne with hg0
  have hg0mem : g0 ∈ p.support := p.support.min'_mem hne
  have hrewrite : ∀ x, EMLFun p x / rankFun g0 x
      = ∑ g ∈ p.support, p g * rankFun (g - g0) x := by
    intro x
    rw [EMLFun_eq_sum, Finset.sum_div]
    refine Finset.sum_congr rfl fun g _ => ?_
    rw [rankFun_sub, mul_div_assoc]
  have hlim : Tendsto (fun x => ∑ g ∈ p.support, p g * rankFun (g - g0) x) atTop
      (𝓝 (∑ g ∈ p.support, if g = g0 then p g0 else 0)) := by
    refine tendsto_finset_sum _ fun g hg => ?_
    by_cases hgg : g = g0
    · subst hgg
      simp
    · have hgt : 0 < g - g0 := by
        have hle : g0 ≤ g := p.support.min'_le g hg
        exact sub_pos.mpr (lt_of_le_of_ne hle (Ne.symm hgg))
      have := (tendsto_rankFun_zero hgt).const_mul (p g)
      simpa [hgg] using this
  rw [Finset.sum_ite_eq' p.support g0] at hlim
  simp only [hg0mem, if_true] at hlim
  exact (tendsto_congr hrewrite).mpr hlim

/-- **An EML function with positive transseries is eventually positive.** -/
theorem eventually_pos_of_toTS_pos {p : Rank →₀ ℝ} (hp : 0 < toTS p) :
    ∀ᶠ x in atTop, 0 < EMLFun p x := by
  have hp0 : p ≠ 0 := by
    rintro rfl
    simp at hp
  have hne : p.support.Nonempty := Finsupp.support_nonempty_iff.mpr hp0
  have hpos : 0 < p (p.support.min' hne) := (toTS_pos_iff hne).mp hp
  have hlim := tendsto_EMLFun_div hne
  filter_upwards [hlim.eventually_const_lt hpos] with x hx
  have hr : 0 < rankFun (p.support.min' hne) x := rankFun_pos _ _
  have h2 := mul_pos hx hr
  rwa [div_mul_cancel₀ _ (rankFun_ne_zero _ x)] at h2

/-- An EML function with negative transseries is eventually negative. -/
theorem eventually_neg_of_toTS_neg {p : Rank →₀ ℝ} (hp : toTS p < 0) :
    ∀ᶠ x in atTop, EMLFun p x < 0 := by
  have h : 0 < toTS (-p) := by rw [toTS_neg]; exact neg_pos.mpr hp
  filter_upwards [eventually_pos_of_toTS_pos h] with x hx
  rw [EMLFun_neg] at hx
  linarith

/-- A nonzero EML function is eventually nonzero: EML functions have no accumulation of
zeros at `+∞`. -/
theorem eventually_ne_zero {p : Rank →₀ ℝ} (hp : p ≠ 0) :
    ∀ᶠ x in atTop, EMLFun p x ≠ 0 := by
  have hts : toTS p ≠ 0 := fun h => hp (toTS_injective (by simpa using h))
  rcases lt_or_gt_of_ne hts with hneg | hpos
  · filter_upwards [eventually_neg_of_toTS_neg hneg] with x hx using hx.ne
  · filter_upwards [eventually_pos_of_toTS_pos hpos] with x hx using hx.ne'

/-- **Asymptotic comparison theorem.**  One EML function is eventually smaller than
another exactly when its transseries is smaller.  The expansion is therefore an order
embedding of EML functions (as germs at `+∞`) into the transseries field. -/
theorem eventually_lt_iff_toTS_lt (p q : Rank →₀ ℝ) :
    (∀ᶠ x in atTop, EMLFun p x < EMLFun q x) ↔ toTS p < toTS q := by
  constructor
  · intro h
    by_contra hle
    rw [not_lt] at hle
    rcases hle.eq_or_lt with heq | hlt
    · have hpq : q = p := toTS_injective heq
      subst hpq
      obtain ⟨x, hx⟩ := h.exists
      exact absurd hx (lt_irrefl _)
    · have hneg : toTS (q - p) < 0 := by rw [toTS_sub]; exact sub_neg.mpr hlt
      have := eventually_neg_of_toTS_neg hneg
      obtain ⟨x, hx1, hx2⟩ := (h.and this).exists
      rw [EMLFun_sub] at hx2
      linarith
  · intro h
    have hpos : 0 < toTS (q - p) := by rw [toTS_sub]; exact sub_pos.mpr h
    filter_upwards [eventually_pos_of_toTS_pos hpos] with x hx
    rw [EMLFun_sub] at hx
    linarith

/-- **Uniqueness of the transseries expansion.**  Two EML functions have the same germ at
`+∞` if and only if their transseries expansions are equal, i.e. agree to all orders. -/
theorem eventuallyEq_iff_toTS_eq (p q : Rank →₀ ℝ) :
    (∀ᶠ x in atTop, EMLFun p x = EMLFun q x) ↔ toTS p = toTS q := by
  constructor
  · intro h
    by_contra hne
    have hpq : p - q ≠ 0 := by
      intro h0
      exact hne (by rw [← sub_eq_zero, ← toTS_sub, h0, toTS_zero])
    obtain ⟨x, hx1, hx2⟩ := (h.and (eventually_ne_zero hpq)).exists
    rw [EMLFun_sub] at hx2
    exact hx2 (by rw [hx1, sub_self])
  · intro h
    have : p = q := toTS_injective h
    subst this
    exact Eventually.of_forall fun x => rfl

/-- The transseries expansion of an EML function determines it, and conversely: agreement
to all orders is the same as agreement of germs at `+∞`.  (Coefficient form.) -/
theorem eventuallyEq_iff_coeff_eq (p q : Rank →₀ ℝ) :
    (∀ᶠ x in atTop, EMLFun p x = EMLFun q x) ↔ ∀ g, p g = q g := by
  rw [eventuallyEq_iff_toTS_eq]
  constructor
  · intro h g
    simpa using congrArg (fun t : TS => (ofLex t).coeff g) h
  · intro h
    exact congrArg toTS (Finsupp.ext h)

/-! ## The named EML functions and their expansions -/

/-- `exp x` is the EML function of the transmonomial `Lexp`. -/
theorem EMLFun_single_exp (x : ℝ) :
    EMLFun (Finsupp.single (rk 0 (-1) 0 0) 1) x = Real.exp x := by
  simp [EMLFun, Finsupp.sum_single_index, rankFun, rankLog]

theorem toTS_single_exp : toTS (Finsupp.single (rk 0 (-1) 0 0) 1) = Lexp := by
  refine ofLex.injective (HahnSeries.ext ?_)
  funext g
  by_cases h : g = rk 0 (-1) 0 0 <;>
    simp [Lexp, T, h, coeff_single_of_ne]

/-- `exp (exp x)` is the EML function of the transmonomial `Lexpexp`. -/
theorem EMLFun_single_expexp (x : ℝ) :
    EMLFun (Finsupp.single (rk (-1) 0 0 0) 1) x = Real.exp (Real.exp x) := by
  simp [EMLFun, Finsupp.sum_single_index, rankFun, rankLog]

theorem toTS_single_expexp : toTS (Finsupp.single (rk (-1) 0 0 0) 1) = Lexpexp := by
  refine ofLex.injective (HahnSeries.ext ?_)
  funext g
  by_cases h : g = rk (-1) 0 0 0 <;>
    simp [Lexpexp, T, h, coeff_single_of_ne]

/-- The identity function `x` is the EML function of the transmonomial `Lx`
(on the domain `x > 0`, where `x = exp (log x)`). -/
theorem EMLFun_single_id {x : ℝ} (hx : 0 < x) :
    EMLFun (Finsupp.single (rk 0 0 (-1) 0) 1) x = x := by
  simp [EMLFun, Finsupp.sum_single_index, rankFun, rankLog, Real.exp_log hx]

theorem toTS_single_id : toTS (Finsupp.single (rk 0 0 (-1) 0) 1) = Lx := by
  refine ofLex.injective (HahnSeries.ext ?_)
  funext g
  by_cases h : g = rk 0 0 (-1) 0 <;>
    simp [Lx, T, h, coeff_single_of_ne]

/-- `log x` is the EML function of the transmonomial `Llog` (on the domain `x > 1`). -/
theorem EMLFun_single_log {x : ℝ} (hx : 1 < x) :
    EMLFun (Finsupp.single (rk 0 0 0 (-1)) 1) x = Real.log x := by
  have hlog : 0 < Real.log x := Real.log_pos hx
  simp [EMLFun, Finsupp.sum_single_index, rankFun, rankLog, Real.exp_log hlog]

theorem toTS_single_log : toTS (Finsupp.single (rk 0 0 0 (-1)) 1) = Llog := by
  refine ofLex.injective (HahnSeries.ext ?_)
  funext g
  by_cases h : g = rk 0 0 0 (-1) <;>
    simp [Llog, T, h, coeff_single_of_ne]

end EMLTS