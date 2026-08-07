/-
  Penrose–Hawking singularity theorems: the focusing mechanism, formalized.

  Building on `Catalog.Physics.Spacetime.RaychaudhuriFocusing`, this file packages the
  geometric data of a geodesic congruence into structures and derives, with complete
  proofs, the incompleteness conclusions of the singularity theorems in the form in which
  the analytic content actually lives:

  * a congruence whose expansion obeys the Raychaudhuri equation, with non-negative shear
    and non-negative Ricci focusing term (energy condition), and which is initially
    converging, cannot be extended in affine parameter beyond `m / |θ₀|`;
  * a *trapped surface* (both null normal congruences converging) therefore has both
    families of null generators incomplete, with an explicit uniform bound;
  * time reversal gives Hawking's cosmological statement: an everywhere expanding
    hypersurface forces *past* incompleteness (a Big-Bang-type singularity);
  * the structures are non-vacuous: explicit congruences and a trapped surface saturating
    the bound are constructed.

  Conventions.  `m > 0` is the effective transverse dimension: `m = n - 2` for a null
  congruence and `m = n - 1` for a timelike congruence in an `n`-dimensional spacetime.
  Affine parameter runs over `[0, L)`; `L` is the affine length of the congruence, so
  "`L ≤ B`" is the statement that the generators are incomplete beyond `B`.
-/

import Physics.Spacetime.RaychaudhuriFocusing

open Set

namespace Catalog.Physics.Spacetime

/-- A geodesic congruence, given by the data appearing in the Raychaudhuri equation, on
the affine interval `[0, L)` with effective transverse dimension `m`.  `shearSq` is the
squared shear `σ²` and `ricci` is the curvature term `Ric(k,k)`; the last two fields are
the pointwise energy condition (`Ric(k,k) ≥ 0`, i.e. the null/strong energy condition via
the Einstein equations) and the algebraic non-negativity of `σ²` for a hypersurface
orthogonal congruence. -/
structure GeodesicCongruence (m L : ℝ) where
  /-- The expansion scalar `θ` of the congruence. -/
  expansion : ℝ → ℝ
  /-- The affine derivative `dθ/dλ`. -/
  expansionDot : ℝ → ℝ
  /-- The squared shear scalar `σ²`. -/
  shearSq : ℝ → ℝ
  /-- The curvature focusing term `Ric(k,k)`. -/
  ricci : ℝ → ℝ
  hasDeriv : ∀ t ∈ Ico (0 : ℝ) L, HasDerivAt expansion (expansionDot t) t
  raychaudhuri : ∀ t ∈ Ico (0 : ℝ) L,
    expansionDot t = -(expansion t) ^ 2 / m - shearSq t - ricci t
  shearSq_nonneg : ∀ t ∈ Ico (0 : ℝ) L, 0 ≤ shearSq t
  energy_condition : ∀ t ∈ Ico (0 : ℝ) L, 0 ≤ ricci t

namespace GeodesicCongruence

variable {m L : ℝ} (C : GeodesicCongruence m L)

/-- The Raychaudhuri equation together with the energy condition gives the focusing
*inequality* `dθ/dλ ≤ -θ²/m`. -/
theorem expansionDot_le : ∀ t ∈ Ico (0 : ℝ) L,
    C.expansionDot t ≤ -(C.expansion t) ^ 2 / m := by
  intro t ht
  have h := C.raychaudhuri t ht
  have h1 := C.shearSq_nonneg t ht
  have h2 := C.energy_condition t ht
  rw [h]
  linarith

/-- **Focusing.**  An initially converging congruence stays converging. -/
theorem expansion_le_initial (hm : 0 < m) (htrap : C.expansion 0 < 0) :
    ∀ t ∈ Ico (0 : ℝ) L, C.expansion t ≤ C.expansion 0 :=
  expansion_le_init hm C.hasDeriv C.expansionDot_le htrap

/-- **Sharp comparison.**  The expansion of an initially converging congruence is
dominated by the exact Riccati solution with the same initial value; in particular it
diverges to `-∞` as the affine parameter approaches `m / |θ₀|`. -/
theorem expansion_le_riccati (hm : 0 < m) (htrap : C.expansion 0 < 0) :
    ∀ t ∈ Ico (0 : ℝ) L, C.expansion t ≤ riccatiSol m (C.expansion 0) t :=
  expansion_comparison hm C.hasDeriv C.expansionDot_le htrap

/-- **Singularity theorem (incompleteness estimate).**  A congruence satisfying the energy
condition and initially converging (`θ₀ < 0`) has affine length at most `m / |θ₀|`:
its geodesics are incomplete (or terminate at a focal point) before that parameter. -/
theorem affine_length_le (hm : 0 < m) (htrap : C.expansion 0 < 0) :
    L ≤ m / (-C.expansion 0) :=
  focusing_domain_bound hm C.hasDeriv C.expansionDot_le htrap

/-- No congruence satisfying the energy condition can be initially converging and extend
past the focusing distance: the two hypotheses are contradictory. -/
theorem not_extends_past_focusing (hm : 0 < m) (htrap : C.expansion 0 < 0)
    (hlong : m / (-C.expansion 0) < L) : False :=
  absurd (C.affine_length_le hm htrap) (not_le.2 hlong)

end GeodesicCongruence

/-! ### Trapped surfaces -/

/-- A **trapped surface**: a codimension-two spacelike surface both of whose future
directed null normal congruences are converging.  `Lout`, `Lin` are the affine lengths of
the outgoing and ingoing families of null generators. -/
structure TrappedSurface (m Lout Lin : ℝ) where
  /-- The outgoing null normal congruence. -/
  outgoing : GeodesicCongruence m Lout
  /-- The ingoing null normal congruence. -/
  ingoing : GeodesicCongruence m Lin
  outgoing_converging : outgoing.expansion 0 < 0
  ingoing_converging : ingoing.expansion 0 < 0

namespace TrappedSurface

variable {m Lout Lin : ℝ} (T : TrappedSurface m Lout Lin)

/-- **Penrose's incompleteness conclusion.**  Both families of null generators of a
trapped surface have bounded affine length. -/
theorem null_generators_incomplete (hm : 0 < m) :
    Lout ≤ m / (-T.outgoing.expansion 0) ∧ Lin ≤ m / (-T.ingoing.expansion 0) :=
  ⟨T.outgoing.affine_length_le hm T.outgoing_converging,
   T.ingoing.affine_length_le hm T.ingoing_converging⟩

/-- **Uniform focusing bound.**  If the trapping is uniform, `θ₀ ≤ -k` with `k > 0` on
both null normal directions, then *every* generator terminates by affine parameter
`m / k`.  This is the quantitative form of "a trapped surface makes the spacetime
null geodesically incomplete". -/
theorem uniform_affine_bound (hm : 0 < m) {k : ℝ} (hk : 0 < k)
    (hout : T.outgoing.expansion 0 ≤ -k) (hin : T.ingoing.expansion 0 ≤ -k) :
    max Lout Lin ≤ m / k := by
  have hmono : ∀ (a : ℝ), a ≤ -k → m / (-a) ≤ m / k := by
    intro a ha
    have hka : k ≤ -a := by linarith
    exact div_le_div_of_nonneg_left hm.le hk hka
  refine max_le ?_ ?_
  · exact le_trans (T.outgoing.affine_length_le hm T.outgoing_converging) (hmono _ hout)
  · exact le_trans (T.ingoing.affine_length_le hm T.ingoing_converging) (hmono _ hin)

/-- A trapped surface cannot have a null generator of arbitrarily large affine length:
the existence of a complete generator is contradictory. -/
theorem no_complete_outgoing_generator (hm : 0 < m)
    (hlong : m / (-T.outgoing.expansion 0) < Lout) : False :=
  T.outgoing.not_extends_past_focusing hm T.outgoing_converging hlong

end TrappedSurface

/-! ### Time reversal: Hawking's cosmological singularity -/

section PastIncompleteness

variable {m L : ℝ} {θ θ' : ℝ → ℝ}

/-- **Hawking's past incompleteness estimate.**  If the expansion of a congruence obeys
the Raychaudhuri inequality on the *past* interval `(-L, 0]` and the congruence is
initially *expanding* (`θ 0 > 0`, as for a cosmological slice of an expanding universe),
then the congruence cannot be extended to the past beyond affine parameter `m / θ 0`.
This is the Big-Bang form of the singularity theorem; it is obtained from the future
statement by the time reversal `t ↦ -θ(-t)`. -/
theorem past_focusing_domain_bound (hm : 0 < m)
    (hd : ∀ x ∈ Ioc (-L) (0 : ℝ), HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ioc (-L) (0 : ℝ), θ' x ≤ -(θ x) ^ 2 / m)
    (h0 : 0 < θ 0) :
    L ≤ m / θ 0 := by
  set φ : ℝ → ℝ := fun t => -θ (-t) with hφ
  set φ' : ℝ → ℝ := fun t => θ' (-t) with hφ'
  have hmem : ∀ x ∈ Ico (0 : ℝ) L, -x ∈ Ioc (-L) (0 : ℝ) := by
    intro x hx
    exact ⟨by linarith [hx.2], by linarith [hx.1]⟩
  have hdφ : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt φ (φ' x) x := by
    intro x hx
    have h1 : HasDerivAt (fun t : ℝ => θ (-t)) (θ' (-x) * (-1)) x :=
      HasDerivAt.comp x (hd (-x) (hmem x hx)) ((hasDerivAt_id x).neg)
    have h2 := h1.neg
    simpa [hφ, hφ'] using h2
  have hineqφ : ∀ x ∈ Ico (0 : ℝ) L, φ' x ≤ -(φ x) ^ 2 / m := by
    intro x hx
    have h := hineq (-x) (hmem x hx)
    simpa [hφ, hφ'] using h
  have h0φ : φ 0 < 0 := by simpa [hφ] using h0
  have hbound := focusing_domain_bound hm hdφ hineqφ h0φ
  have heq : -φ 0 = θ 0 := by simp [hφ]
  rwa [heq] at hbound

end PastIncompleteness

/-! ### Non-vacuity: explicit congruences saturating the bound -/

section Examples

/-- The shear-free, Ricci-flat congruence whose expansion is the exact Riccati solution.
It exists precisely on `[0, m / |θ₀|)`, so it *saturates* the incompleteness bound of
`GeodesicCongruence.affine_length_le`; in particular that bound cannot be improved and the
structure `GeodesicCongruence` is non-vacuous. -/
noncomputable def exactCongruence (m t0 : ℝ) (hm : 0 < m) (h0 : t0 < 0) :
    GeodesicCongruence m (m / (-t0)) where
  expansion := riccatiSol m t0
  expansionDot := fun t => -(riccatiSol m t0 t) ^ 2 / m
  shearSq := fun _ => 0
  ricci := fun _ => 0
  hasDeriv := fun t ht => (riccatiSol_sharp hm h0).2 t ht
  raychaudhuri := by intro t _; ring
  shearSq_nonneg := by intro t _; exact le_rfl
  energy_condition := by intro t _; exact le_rfl

@[simp] theorem exactCongruence_expansion_zero (m t0 : ℝ) (hm : 0 < m) (h0 : t0 < 0) :
    (exactCongruence m t0 hm h0).expansion 0 = t0 :=
  (riccatiSol_sharp hm h0).1

/-- A trapped surface built from two copies of the exact congruence.  Its generators have
affine length exactly `m / |θ₀|`, matching the general bound. -/
noncomputable def exactTrappedSurface (m t0 : ℝ) (hm : 0 < m) (h0 : t0 < 0) :
    TrappedSurface m (m / (-t0)) (m / (-t0)) where
  outgoing := exactCongruence m t0 hm h0
  ingoing := exactCongruence m t0 hm h0
  outgoing_converging := by simpa using h0
  ingoing_converging := by simpa using h0

/-- **The Penrose bound is attained.**  For the explicit trapped surface, the affine
length of the generators equals the general upper bound `m / |θ₀|`.  Hence
`TrappedSurface.null_generators_incomplete` is sharp. -/
theorem exactTrappedSurface_saturates (m t0 : ℝ) (hm : 0 < m) (h0 : t0 < 0) :
    m / (-t0) = m / (-(exactTrappedSurface m t0 hm h0).outgoing.expansion 0) := by
  simp [exactTrappedSurface]

/-- Numerical instance: in a four-dimensional spacetime (`m = n - 2 = 2`) a trapped
surface with initial null expansion `-1` has all generators terminating by affine
parameter `2`. -/
theorem four_dimensional_bound {Lout Lin : ℝ} (T : TrappedSurface 2 Lout Lin)
    (hout : T.outgoing.expansion 0 ≤ -1) (hin : T.ingoing.expansion 0 ≤ -1) :
    max Lout Lin ≤ 2 := by
  have h := T.uniform_affine_bound (by norm_num) (k := 1) (by norm_num) hout hin
  simpa using h

end Examples

end Catalog.Physics.Spacetime