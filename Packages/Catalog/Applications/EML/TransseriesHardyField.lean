import Applications.EML.TransseriesConstants

/-!
# EML germs form a Hardy field: eventual monotonicity and existence of limits

A *Hardy field* is a field of germs at `+∞` of real functions, closed under
differentiation.  Two properties characterise the good behaviour of such fields, and both
are proved here for the germs of EML functions:

* **no oscillation**: every EML function is eventually strictly monotone or eventually
  constant (`EMLTS.eventually_strictMono_or_strictAnti_or_const`);
* **existence of limits**: every EML function has a limit in `ℝ ∪ {±∞}` at `+∞`
  (`EMLTS.tendsto_EMLFun_limit`).

Both are consequences of the transseries expansion: the dominant transmonomial of a
nonzero EML expression controls the whole germ, and the derivation `EMLTS.emlDeriv`
keeps us inside the same algebra, so the derivative's sign is eventually constant too.
The second property refines to a precise trichotomy governed by the sign of the dominant
rank (`EMLTS.tendsto_EMLFun_of_dominant`).

## Main results

* `EMLTS.tendsto_rankFun_atTop` : a transmonomial of negative rank tends to `+∞`.
* `EMLTS.tendsto_EMLFun_limit` : every EML germ has a limit in the extended reals.
* `EMLTS.eventually_strictMono_or_strictAnti_or_const` : no EML germ oscillates.
* `EMLTS.EMLFun_eventually_injOn` : a non-constant EML function is eventually injective.
-/

noncomputable section

open Filter Asymptotics Real HahnSeries Set

open scoped Topology

namespace EMLTS

/-! ## Transmonomials of negative rank blow up -/

/-- A transmonomial whose rank is negative (i.e. a transmonomial that grows) tends to
`+∞`; this is the counterpart of `EMLTS.tendsto_rankFun_zero`. -/
theorem tendsto_rankFun_atTop {r : Rank} (hr : r < 0) :
    Tendsto (rankFun r) atTop atTop := by
  have hpos : (0 : Rank) < -r := neg_pos.mpr hr
  have h0 : Tendsto (rankFun (-r)) atTop (𝓝 0) := tendsto_rankFun_zero hpos
  have hw : Tendsto (rankFun (-r)) atTop (𝓝[>] (0 : ℝ)) :=
    tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _ h0
      (Eventually.of_forall fun x => rankFun_pos (-r) x)
  have hinv := hw.inv_tendsto_nhdsGT_zero
  have heq : (rankFun (-r))⁻¹ = rankFun r := by
    funext x
    rw [Pi.inv_apply, rankFun_neg, inv_inv]
  rwa [heq] at hinv

/-! ## Every EML germ has a limit in the extended reals -/

/-- The limit of an EML function is governed by its dominant rank: a positive dominant
rank gives limit `0`, a zero dominant rank gives the dominant coefficient, a negative
dominant rank gives `±∞` according to the sign of the dominant coefficient. -/
theorem tendsto_EMLFun_of_dominant {p : Rank →₀ ℝ} (hne : p.support.Nonempty) :
    (0 < p.support.min' hne ∧ Tendsto (EMLFun p) atTop (𝓝 0)) ∨
      (p.support.min' hne = 0 ∧ Tendsto (EMLFun p) atTop (𝓝 (p 0))) ∨
      (p.support.min' hne < 0 ∧ 0 < p (p.support.min' hne) ∧
        Tendsto (EMLFun p) atTop atTop) ∨
      (p.support.min' hne < 0 ∧ p (p.support.min' hne) < 0 ∧
        Tendsto (EMLFun p) atTop atBot) := by
  classical
  set g0 := p.support.min' hne with hg0
  have hdiv : Tendsto (fun x => EMLFun p x / rankFun g0 x) atTop (𝓝 (p g0)) :=
    tendsto_EMLFun_div hne
  have hsplit : EMLFun p = fun x => (EMLFun p x / rankFun g0 x) * rankFun g0 x := by
    funext x
    rw [div_mul_cancel₀ _ (rankFun_ne_zero g0 x)]
  rcases lt_trichotomy g0 0 with hlt | heq0 | hgt
  · have hc : p g0 ≠ 0 := Finsupp.mem_support_iff.mp (p.support.min'_mem hne)
    have htop : Tendsto (rankFun g0) atTop atTop := tendsto_rankFun_atTop hlt
    rcases lt_or_gt_of_ne hc with hneg | hpos
    · refine Or.inr (Or.inr (Or.inr ⟨hlt, hneg, ?_⟩))
      rw [hsplit]
      exact hdiv.neg_mul_atTop hneg htop
    · refine Or.inr (Or.inr (Or.inl ⟨hlt, hpos, ?_⟩))
      rw [hsplit]
      exact hdiv.pos_mul_atTop hpos htop
  · refine Or.inr (Or.inl ⟨heq0, ?_⟩)
    have : EMLFun p = fun x => EMLFun p x / rankFun g0 x := by
      funext x
      rw [heq0, rankFun_zero, div_one]
    rw [this, ← heq0]
    exact hdiv
  · refine Or.inl ⟨hgt, ?_⟩
    have hzero : Tendsto (rankFun g0) atTop (𝓝 0) := tendsto_rankFun_zero hgt
    rw [hsplit]
    simpa using hdiv.mul hzero

/-- **Existence of limits.**  Every EML function converges in `ℝ ∪ {±∞}` at `+∞`:
EML germs never oscillate. -/
theorem tendsto_EMLFun_limit (p : Rank →₀ ℝ) :
    (∃ L : ℝ, Tendsto (EMLFun p) atTop (𝓝 L)) ∨
      Tendsto (EMLFun p) atTop atTop ∨ Tendsto (EMLFun p) atTop atBot := by
  classical
  by_cases hp : p = 0
  · subst hp
    refine Or.inl ⟨0, ?_⟩
    have : EMLFun (0 : Rank →₀ ℝ) = fun _ : ℝ => (0 : ℝ) := by
      funext x; simp [EMLFun]
    rw [this]
    exact tendsto_const_nhds
  · have hne : p.support.Nonempty := Finsupp.support_nonempty_iff.mpr hp
    rcases tendsto_EMLFun_of_dominant hne with ⟨_, h⟩ | ⟨_, h⟩ | ⟨_, _, h⟩ | ⟨_, _, h⟩
    · exact Or.inl ⟨0, h⟩
    · exact Or.inl ⟨_, h⟩
    · exact Or.inr (Or.inl h)
    · exact Or.inr (Or.inr h)

/-! ## No oscillation: eventual strict monotonicity -/

/-- **The Hardy-field property.**  Every EML function is eventually strictly increasing,
eventually strictly decreasing, or eventually constant. -/
theorem eventually_strictMono_or_strictAnti_or_const (p : EMLAlg) :
    ∃ N : ℝ, StrictMonoOn (EMLFun p) (Ici N) ∨ StrictAntiOn (EMLFun p) (Ici N)
      ∨ ∀ x ∈ Ici N, EMLFun p x = EMLFun p N := by
  classical
  have hcontAll : ∀ N : ℝ, 2 ≤ N → ContinuousOn (EMLFun p) (Ici N) := by
    intro N hN y hy
    have hy1 : (1 : ℝ) < y := lt_of_lt_of_le (by norm_num) (le_trans hN hy)
    exact ((hasDerivAt_EMLFun p hy1).continuousAt).continuousWithinAt
  have hderivEq : ∀ x : ℝ, 1 < x → deriv (EMLFun p) x = EMLFun (emlDeriv p) x :=
    fun x hx => (hasDerivAt_EMLFun p hx).deriv
  rcases lt_trichotomy (toTS (emlDeriv p)) 0 with hlt | heq0 | hgt
  · obtain ⟨a, ha⟩ := eventually_atTop.mp (eventually_neg_of_toTS_neg hlt)
    refine ⟨max a 2, Or.inr (Or.inl ?_)⟩
    refine strictAntiOn_of_deriv_neg (convex_Ici _) (hcontAll _ (le_max_right a 2)) ?_
    intro x hx
    rw [interior_Ici] at hx
    have hx2 : max a 2 < x := hx
    have hxa : a ≤ x := le_of_lt (lt_of_le_of_lt (le_max_left a 2) hx2)
    have hx1 : (1 : ℝ) < x := lt_of_lt_of_le (by norm_num) (le_of_lt
      (lt_of_le_of_lt (le_max_right a 2) hx2))
    rw [hderivEq x hx1]
    exact ha x hxa
  · have hz : emlDeriv p = 0 := toTS_injective (by rw [heq0, toTS_zero])
    obtain ⟨c, hc⟩ := (emlDeriv_eq_zero_iff p).mp hz
    refine ⟨2, Or.inr (Or.inr ?_)⟩
    intro x hx
    rw [hc, EMLFun_const, EMLFun_const]
  · obtain ⟨a, ha⟩ := eventually_atTop.mp (eventually_pos_of_toTS_pos hgt)
    refine ⟨max a 2, Or.inl ?_⟩
    refine strictMonoOn_of_deriv_pos (convex_Ici _) (hcontAll _ (le_max_right a 2)) ?_
    intro x hx
    rw [interior_Ici] at hx
    have hx2 : max a 2 < x := hx
    have hxa : a ≤ x := le_of_lt (lt_of_le_of_lt (le_max_left a 2) hx2)
    have hx1 : (1 : ℝ) < x := lt_of_lt_of_le (by norm_num) (le_of_lt
      (lt_of_le_of_lt (le_max_right a 2) hx2))
    rw [hderivEq x hx1]
    exact ha x hxa

/-- A non-constant EML function is eventually injective. -/
theorem EMLFun_eventually_injOn {p : EMLAlg}
    (hp : ∀ c : ℝ, p ≠ AddMonoidAlgebra.single (0 : Rank) c) :
    ∃ N : ℝ, InjOn (EMLFun p) (Ici N) := by
  obtain ⟨N, hN⟩ := eventually_strictMono_or_strictAnti_or_const p
  rcases hN with h | h | h
  · exact ⟨N, h.injOn⟩
  · exact ⟨N, h.injOn⟩
  · exfalso
    have hzero : emlDeriv p = 0 := by
      rw [emlDeriv_eq_zero_iff_eventually_const]
      refine ⟨EMLFun p N, ?_⟩
      filter_upwards [eventually_ge_atTop N] with x hx
      exact h x hx
    obtain ⟨c, hc⟩ := (emlDeriv_eq_zero_iff p).mp hzero
    exact hp c hc

end EMLTS