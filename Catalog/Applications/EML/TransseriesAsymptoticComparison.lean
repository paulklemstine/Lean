import Applications.EML.TransseriesDerivation

/-!
# The asymptotic comparison theorem for EML transseries

This file proves the *asymptotic comparison theorem* in both of its guises.

**Formal side.**  A transseries which is asymptotically smaller than *every* transmonomial
is zero (`EMLTS.eq_zero_of_abs_lt_all_transmonomials`).  Equivalently, two transseries
that "agree to all orders" — i.e. whose difference is dominated by every transmonomial
`exp (d exp x) exp (a x) x ^ b (log x) ^ c` — are equal
(`EMLTS.eq_iff_abs_sub_lt_all_transmonomials`).  This is a genuinely non-formal statement:
it says that the transseries field has *no* nonzero element below the whole scale, i.e.
the value group `Rank` has no "infinitely small" gap that the field could fall through.

**Analytic side.**  If the difference of two EML functions is `o` of every transmonomial
then the two EML functions are literally the same element of the EML algebra
(`EMLTS.eq_of_isLittleO_all_rankFun`), hence have the same germ at `+∞`.  So the
transseries expansion of an EML function is a complete asymptotic invariant: there are no
"transexponentially small" EML corrections, which is exactly the statement that the EML
germs form a Hardy field with no flat elements.

## Main results

* `EMLTS.mono_lt_of_order_lt` : a transmonomial of rank above the order of a positive
  transseries is strictly below it.
* `EMLTS.eq_iff_abs_sub_lt_all_transmonomials` : the formal asymptotic comparison theorem.
* `EMLTS.eq_of_isLittleO_all_rankFun` : the analytic asymptotic comparison theorem.
* `EMLTS.no_flat_EMLFun` : a nonzero EML function is never `o` of all transmonomials —
  the EML Hardy field contains no flat germs.
-/

noncomputable section

open Filter Asymptotics Real HahnSeries

open scoped Topology

namespace EMLTS

/-! ## Monomials indexed directly by ranks -/

/-- The positive transmonomial attached to a rank. -/
def Mono (g : Rank) : TS := toLex (single g (1 : ℝ))

theorem Mono_pos (g : Rank) : 0 < Mono g := by
  rw [← leadingCoeff_pos_iff]
  simp [Mono, leadingCoeff_of_single]

/-- Every transmonomial `T d a b c` is a `Mono`, and conversely. -/
theorem T_eq_Mono (g : Rank) : T (-(rd g)) (-(ra g)) (-(rb g)) (-(rc g)) = Mono g := by
  rw [T, Mono, neg_neg, neg_neg, neg_neg, neg_neg, rk_eta]

/-- The rank of `log x`, a strictly positive rank; it is what makes the rank group have
no largest element and hence what powers the comparison theorem. -/
theorem rk_log_pos : (0 : Rank) < rk 0 0 0 1 := by
  rw [show (0 : Rank) = rk 0 0 0 0 from rfl, rk_lt_rk_iff]
  norm_num

/-- A transmonomial whose rank is strictly larger than the order of a positive transseries
is strictly smaller than that transseries.  (Large rank = small transseries.) -/
theorem mono_lt_of_order_lt {v : TS} (hv : 0 < v) {g : Rank} (hg : (ofLex v).order < g) :
    Mono g < v := by
  refine (HahnSeries.lt_iff _ _).mpr ⟨(ofLex v).order, fun j hj => ?_, ?_⟩
  · rw [Mono, ofLex_toLex, coeff_single_of_ne (hj.trans hg).ne,
      coeff_eq_zero_of_lt_order hj]
  · rw [Mono, ofLex_toLex, coeff_single_of_ne hg.ne, ← leadingCoeff_eq]
    exact leadingCoeff_pos_iff.mpr hv

/-- Every strictly positive transseries dominates some transmonomial: the scale of
transmonomials is *cofinal from below* in the positive cone. -/
theorem exists_mono_lt_of_pos {v : TS} (hv : 0 < v) : ∃ g : Rank, Mono g < v :=
  ⟨(ofLex v).order + rk 0 0 0 1,
    mono_lt_of_order_lt hv (lt_add_of_pos_right _ rk_log_pos)⟩

/-! ## The formal asymptotic comparison theorem -/

/-- **Asymptotic comparison, zero form.**  A transseries smaller in absolute value than
every transmonomial is zero. -/
theorem eq_zero_of_abs_lt_all_transmonomials {u : TS} (h : ∀ g : Rank, |u| < Mono g) :
    u = 0 := by
  by_contra hu
  obtain ⟨g, hg⟩ := exists_mono_lt_of_pos (abs_pos.mpr hu)
  exact absurd (h g) (asymm hg)

/-- **Asymptotic comparison theorem.**  Two transseries that agree to all orders — their
difference being dominated by every transmonomial — are equal. -/
theorem eq_iff_abs_sub_lt_all_transmonomials {f h : TS} :
    f = h ↔ ∀ d a b c : ℝ, |f - h| < T d a b c := by
  constructor
  · rintro rfl d a b c
    simpa using T_pos d a b c
  · intro H
    refine sub_eq_zero.mp (eq_zero_of_abs_lt_all_transmonomials fun g => ?_)
    rw [← T_eq_Mono g]
    exact H _ _ _ _

/-! ## The analytic asymptotic comparison theorem -/

/-- **No flat EML germs.**  A nonzero element of the EML algebra is not `o` of every
transmonomial: there is a transmonomial that it dominates. -/
theorem no_flat_EMLFun {r : Rank →₀ ℝ} (hr : r ≠ 0) :
    ∃ g : Rank, ¬ (EMLFun r) =o[atTop] rankFun g := by
  classical
  have hne : r.support.Nonempty := Finsupp.support_nonempty_iff.mpr hr
  set g0 := r.support.min' hne with hg0
  refine ⟨g0, fun hlo => ?_⟩
  have h1 : Tendsto (fun x => EMLFun r x / rankFun g0 x) atTop (𝓝 (r g0)) :=
    tendsto_EMLFun_div hne
  have h2 : Tendsto (fun x => EMLFun r x / rankFun g0 x) atTop (𝓝 0) :=
    hlo.tendsto_div_nhds_zero
  have : r g0 = 0 := tendsto_nhds_unique h1 h2
  exact (Finsupp.mem_support_iff.mp (r.support.min'_mem hne)) this

/-- **Analytic asymptotic comparison theorem.**  If the difference of two EML functions is
`o` of *every* transmonomial, then the two EML data are equal; in particular the functions
agree everywhere they are defined.  So the transseries expansion is a complete asymptotic
invariant of an EML function. -/
theorem eq_of_isLittleO_all_rankFun {p q : Rank →₀ ℝ}
    (H : ∀ g : Rank, (fun x => EMLFun p x - EMLFun q x) =o[atTop] rankFun g) : p = q := by
  by_contra hpq
  have hr : p - q ≠ 0 := sub_ne_zero.mpr hpq
  obtain ⟨g, hg⟩ := no_flat_EMLFun hr
  refine hg ?_
  have hfun : EMLFun (p - q) = fun x => EMLFun p x - EMLFun q x :=
    funext fun x => EMLFun_sub p q x
  rw [hfun]
  exact H g

/-- The analytic comparison theorem in germ form: two EML functions have the same germ at
`+∞` as soon as their difference is `o` of every transmonomial. -/
theorem eventuallyEq_of_isLittleO_all_rankFun {p q : Rank →₀ ℝ}
    (H : ∀ g : Rank, (fun x => EMLFun p x - EMLFun q x) =o[atTop] rankFun g) :
    ∀ᶠ x in atTop, EMLFun p x = EMLFun q x := by
  rw [eventuallyEq_iff_toTS_eq]
  exact congrArg toTS (eq_of_isLittleO_all_rankFun H)

/-- A nonzero EML function is bounded below by a genuine transmonomial in the strong sense
that the quotient by that transmonomial has a nonzero limit. -/
theorem exists_dominant_transmonomial {r : Rank →₀ ℝ} (hr : r ≠ 0) :
    ∃ (g : Rank) (L : ℝ), L ≠ 0 ∧ Tendsto (fun x => EMLFun r x / rankFun g x) atTop (𝓝 L) := by
  classical
  have hne : r.support.Nonempty := Finsupp.support_nonempty_iff.mpr hr
  exact ⟨r.support.min' hne, r (r.support.min' hne),
    Finsupp.mem_support_iff.mp (r.support.min'_mem hne), tendsto_EMLFun_div hne⟩

end EMLTS