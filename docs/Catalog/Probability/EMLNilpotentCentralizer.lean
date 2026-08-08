import Probability.EMLLieRigidity

/-!
# Cycle 3: nilpotency of the shift generator and the centralizer of an EML field

This file continues the research thread of
`Catalog/Probability/EMLExpLogDuality.lean` (the infinitesimal side of the EML
exp–log duality), `Catalog/Probability/EMLScalingGroupDuality.lean` (the global
side) and `Catalog/Probability/EMLLieRigidity.lean` (representation obstructions
and rigidity of the vector-field realization).  It settles the two open
sub-conjectures NC1 and NC3 recorded in `FUTURE_DIRECTIONS.md`.

## NC1 — proved, in a stronger form than conjectured

Conjecture NC1 asked whether, in every finite-dimensional real representation
`ρ` of the EML generator algebra of dimension `n`, the pure-scaling generator
satisfies `(ρ T) ^ n = 0`; only the case `n = 2` had been proved
(`EMLLieRigidity.rep_dim_two_shift_isNilpotent`), and the route suggested there
was Newton's identities applied to the vanishing power traces.

We prove the full statement, and by a different — and much more robust —
mechanism.  The relation `⁅A, B⁆ = B` propagates to `⁅A, B ^ (k+1)⁆
= (k+1) • B ^ (k+1)` (`EMLLieRigidity.lie_pow_eq_nsmul`), so *every* nonzero
power of `B` is an eigenvector of the single linear operator `ad A` acting on
the finite-dimensional space of matrices, with pairwise distinct eigenvalues
`1, 2, 3, …`.  An endomorphism of a finite-dimensional space has only finitely
many eigenvalues, so almost all of those powers must vanish:

* `isNilpotent_of_lie_eq_self` : `A * B - B * A = B` implies `IsNilpotent B`;
* `pow_card_eq_zero_of_lie_eq_self` : and then `B ^ (card n) = 0`, via
  `charpoly B = X ^ (card n)` and Cayley–Hamilton;
* `rep_shift_isNilpotent`, `rep_shift_pow_card_eq_zero` : the representation
  form of the two statements;
* `rep_dim_one_eq_scaleChar_smul` : consequently every one-dimensional
  representation is the scale character `g ↦ g.scale` times a fixed matrix, so
  the only one-dimensional representations are the characters — the
  representation-theoretic shadow of the abelian quotient
  `EMLGen ⧸ shiftIdeal ≅ ℝ`.

## NC3 — refuted as stated, and replaced by the correct dichotomy-free theorem

Conjecture NC3 predicted that the centralizer of `emlField g` inside the
differentiable vector fields on `(0, ∞)` is one-dimensional when `g.scale ≠ 0`
and *infinite*-dimensional when `g.scale = 0`.  The first half is correct; the
second half is false.  For `g = (0, b)` with `b ≠ 0` the centralizer equation is
`b (y F' - F) = 0`, i.e. the Euler equation `y F' = F`, whose only differentiable
solutions on the connected set `(0, ∞)` are the scaling fields `F y = c y`.  The
centralizer is therefore *one*-dimensional in that case too
(`emlField_centralizer_of_scale_eq_zero`).

The uniform theorem is `emlField_centralizer`: for every `g ≠ 0` the centralizer
of `emlField g` is exactly the line `ℝ · emlField g`
(`emlField_mem_centralizer` for the inclusion `⊇`), and
`centralizer_pairwise_dependent` states the resulting one-dimensionality in
elementary terms.

The analytically interesting case is `g.scale ≠ 0`, where the equation is
singular at the fixed point `p = exp(-g.shift / g.scale)` of the flow.  There
the quotient `F / emlField g` is locally constant off `p` but is *not*
continuous at `p`, so the glueing lemma of cycle 2 does not apply.  The two
constants are matched instead by comparing the one-sided limits of the
difference quotient of `F` at `p` (`const_glue_of_differentiableAt`): both equal
`c · (emlField g)' p` and `(emlField g)' p = g.scale ≠ 0`.
-/

noncomputable section

open Filter Topology
open EMLExpLogDuality EMLExpLogDuality.EMLGen

namespace EMLNilpotentCentralizer

/-! ## 1.  Nilpotency of the shift generator (NC1) -/

section Nilpotency

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- **The eigenvalue-counting obstruction.**  If `⁅A, B⁆ = B` then `B` is
nilpotent: otherwise each power `B ^ (k+1)` would be an eigenvector of `ad A`
with eigenvalue `k + 1`, giving an endomorphism of a finite-dimensional space
infinitely many eigenvalues. -/
theorem isNilpotent_of_lie_eq_self (A B : Matrix n n ℝ) (h : A * B - B * A = B) :
    IsNilpotent B := by
  by_contra hnil
  have hpow : ∀ k : ℕ, B ^ (k + 1) ≠ 0 := fun k hk => hnil ⟨k + 1, hk⟩
  set f : Module.End ℝ (Matrix n n ℝ) := LieAlgebra.ad ℝ (Matrix n n ℝ) A with hf
  have heig : ∀ k : ℕ, f.HasEigenvalue ((k : ℝ) + 1) := by
    intro k
    refine Module.End.hasEigenvalue_of_hasEigenvector (x := B ^ (k + 1)) ⟨?_, hpow k⟩
    rw [Module.End.mem_eigenspace_iff]
    show ⁅A, B ^ (k + 1)⁆ = _
    rw [Ring.lie_def]
    exact EMLLieRigidity.lie_pow_eq_nsmul A B h k
  have hinf : (setOf f.HasEigenvalue).Infinite :=
    Set.infinite_of_injective_forall_mem (f := fun k : ℕ => (k : ℝ) + 1)
      (fun a b hab => by simpa using hab) heig
  exact hinf (Module.End.finite_hasEigenvalue f)

/-- A nilpotent matrix has characteristic polynomial `X ^ n`, hence vanishes in
the `n`-th power by Cayley–Hamilton. -/
theorem pow_card_eq_zero_of_isNilpotent (B : Matrix n n ℝ) (hB : IsNilpotent B) :
    B ^ (Fintype.card n) = 0 := by
  have h0 : B.charpoly - Polynomial.X ^ (Fintype.card n) = 0 :=
    (Matrix.isNilpotent_charpoly_sub_pow_of_isNilpotent hB).eq_zero
  have hchar : B.charpoly = Polynomial.X ^ (Fintype.card n) := by
    linear_combination (norm := ring_nf) h0
  have hCH := B.aeval_self_charpoly
  rw [hchar] at hCH
  simpa using hCH

/-- **NC1, matrix form.**  An `ad`-eigenvector of eigenvalue one vanishes in the
`n`-th power, `n` being the size of the matrices. -/
theorem pow_card_eq_zero_of_lie_eq_self (A B : Matrix n n ℝ) (h : A * B - B * A = B) :
    B ^ (Fintype.card n) = 0 :=
  pow_card_eq_zero_of_isNilpotent B (isNilpotent_of_lie_eq_self A B h)

variable (rho : EMLGen →ₗ⁅ℝ⁆ Matrix n n ℝ)

/-- **NC1.**  In every finite-dimensional real representation of the EML
generator algebra the pure-scaling generator acts by a nilpotent matrix. -/
theorem rep_shift_isNilpotent : IsNilpotent (rho T) :=
  isNilpotent_of_lie_eq_self (rho D) (rho T) (EMLLieRigidity.rep_lie_relation rho)

/-- **NC1, sharp exponent.**  In a representation of dimension `n` the
pure-scaling generator satisfies `(ρ T) ^ n = 0`. -/
theorem rep_shift_pow_card_eq_zero : (rho T) ^ (Fintype.card n) = 0 :=
  pow_card_eq_zero_of_isNilpotent _ (rep_shift_isNilpotent rho)

end Nilpotency

/-- **Only characters in dimension one.**  A one-dimensional representation
kills the shift generator, hence is `g ↦ g.scale • ρ D`: the one-dimensional
representations of the EML algebra are exactly the multiples of the scale
character. -/
theorem rep_dim_one_eq_scaleChar_smul (rho : EMLGen →ₗ⁅ℝ⁆ Matrix (Fin 1) (Fin 1) ℝ)
    (g : EMLGen) : rho g = g.scale • rho D := by
  have htr : Matrix.trace (rho T) = 0 := by
    simpa using EMLLieRigidity.rep_shift_trace_pow_eq_zero rho 0
  have hT : rho T = 0 := by
    have h00 : rho T 0 0 = 0 := by
      rwa [Matrix.trace_fin_one] at htr
    ext i j
    fin_cases i
    fin_cases j
    simpa using h00
  have hdec : g = g.scale • D + g.shift • T := basis_decomposition g
  calc rho g = rho (g.scale • D + g.shift • T) := by rw [← hdec]
    _ = g.scale • rho D := by rw [map_add, map_smul, map_smul, hT, smul_zero, add_zero]

/-! ## 2.  The centralizer of an EML vector field (NC3) -/

/-- Every field commutes with itself: `emlField g` lies in its own
centralizer. -/
theorem emlField_mem_centralizer (g : EMLGen) (y : ℝ) :
    vfBracket (emlField g) (emlField g) y = 0 := sub_self _

/-- **Glueing across a singular point.**  Suppose `F` and `X` both vanish at `p`,
`F` is differentiable at `p`, `X` has nonzero derivative `d` there, and `F`
agrees with `c₁ • X` on a left neighbourhood of `p` and with `c₂ • X` on a right
neighbourhood.  Then `c₁ = c₂`: both one-sided limits of the difference quotient
of `F` at `p` compute `deriv F p`, and they equal `c₁ d` and `c₂ d`. -/
theorem const_glue_of_differentiableAt (X F : ℝ → ℝ) (p d c₁ c₂ : ℝ)
    (hF : DifferentiableAt ℝ F p) (hX : HasDerivAt X d p)
    (hX0 : X p = 0) (hF0 : F p = 0) (hd : d ≠ 0)
    (hleft : ∀ᶠ y in 𝓝[<] p, F y = c₁ * X y)
    (hright : ∀ᶠ y in 𝓝[>] p, F y = c₂ * X y) : c₁ = c₂ := by
  have hsub_lt : 𝓝[<] p ≤ 𝓝[≠] p := nhdsWithin_mono _ (fun y hy => ne_of_lt hy)
  have hsub_gt : 𝓝[>] p ≤ 𝓝[≠] p := nhdsWithin_mono _ (fun y hy => ne_of_gt hy)
  have hFslope : Tendsto (slope F p) (𝓝[≠] p) (𝓝 (deriv F p)) :=
    hasDerivAt_iff_tendsto_slope.mp hF.hasDerivAt
  have hXslope : Tendsto (slope X p) (𝓝[≠] p) (𝓝 d) :=
    hasDerivAt_iff_tendsto_slope.mp hX
  have key : ∀ (c : ℝ) (l : Filter ℝ) [l.NeBot], l ≤ 𝓝[≠] p → (∀ᶠ y in l, F y = c * X y) →
      deriv F p = c * d := by
    intro c l _ hle hev
    have h1 : Tendsto (slope F p) l (𝓝 (deriv F p)) := hFslope.mono_left hle
    have h2 : Tendsto (fun y => c * slope X p y) l (𝓝 (c * d)) :=
      (hXslope.mono_left hle).const_mul c
    have h3 : Tendsto (slope F p) l (𝓝 (c * d)) := by
      refine h2.congr' ?_
      filter_upwards [hev] with y hy
      simp only [slope_def_field, div_eq_inv_mul, hF0, hX0, hy]
      ring
    exact tendsto_nhds_unique h1 h3
  have hl := key c₁ (𝓝[<] p) hsub_lt hleft
  have hr := key c₂ (𝓝[>] p) hsub_gt hright
  exact mul_right_cancel₀ hd (by rw [← hl, ← hr])

/-- **NC3, refutation of the second half.**  For a pure scaling generator
`g = (0, b)` with `b ≠ 0` the centralizer equation is the Euler equation
`y F' = F`, whose differentiable solutions on the *connected* half line are
exactly the scaling fields `F y = F 1 · y`.  The centralizer is therefore one-
and not infinite-dimensional. -/
theorem emlField_centralizer_of_scale_eq_zero {b : ℝ} (hb : b ≠ 0)
    (F : ℝ → ℝ) (hF : Differentiable ℝ F)
    (h : ∀ y : ℝ, 0 < y → vfBracket (emlField ⟨0, b⟩) F y = 0) :
    ∀ y : ℝ, 0 < y → F y = (F 1 / b) * emlField ⟨0, b⟩ y := by
  have hEuler : ∀ y : ℝ, 0 < y → y * deriv F y = F y := by
    intro y hy
    have hy0 : y ≠ 0 := ne_of_gt hy
    have hx := h y hy
    rw [vfBracket, deriv_emlField ⟨0, b⟩ hy0] at hx
    have hfield : emlField (⟨0, b⟩ : EMLGen) y = y * b := by simp [emlField]
    rw [hfield] at hx
    simp only at hx
    have hb' : b * (y * deriv F y - F y) = 0 := by ring_nf; ring_nf at hx; linarith
    rcases mul_eq_zero.mp hb' with h' | h'
    · exact absurd h' hb
    · linarith
  set G : ℝ → ℝ := fun y => F y / y with hG
  have hGdiff : DifferentiableOn ℝ G (Set.Ioi 0) :=
    DifferentiableOn.div hF.differentiableOn differentiableOn_id (fun y hy => ne_of_gt hy)
  have hGderiv : ∀ y ∈ Set.Ioi (0:ℝ), deriv G y = 0 := by
    intro y hy
    have hy0 : y ≠ 0 := ne_of_gt hy
    have hd : HasDerivAt G ((deriv F y * y - F y * 1) / y ^ 2) y :=
      ((hF y).hasDerivAt).div (hasDerivAt_id y) hy0
    rw [hd.deriv]
    have hnum : deriv F y * y - F y * 1 = 0 := by
      have := hEuler y hy
      nlinarith [this]
    rw [hnum, zero_div]
  intro y hy
  have hconst : G y = G 1 :=
    isOpen_Ioi.is_const_of_deriv_eq_zero isPreconnected_Ioi hGdiff hGderiv hy (by norm_num)
  have hGy : F y / y = F 1 / 1 := hconst
  have hFy : F y = F 1 * y := by
    field_simp at hGy
    linarith
  have hXy : emlField (⟨0, b⟩ : EMLGen) y = y * b := by simp [emlField]
  rw [hFy, hXy]
  field_simp

/-- **NC3, first half.**  For `g.scale ≠ 0` the centralizer of `emlField g` is
the line spanned by `emlField g` itself.  The proof has to cross the singular
point `p = exp(-g.shift / g.scale)`, the fixed point of the flow of the field,
where the quotient `F / emlField g` is undefined: the two locally constant
values are matched by the one-sided difference quotients of `F` at `p`. -/
theorem emlField_centralizer_of_scale_ne_zero (g : EMLGen) (ha : g.scale ≠ 0)
    (F : ℝ → ℝ) (hF : Differentiable ℝ F)
    (h : ∀ y : ℝ, 0 < y → vfBracket (emlField g) F y = 0) :
    ∃ c : ℝ, ∀ y : ℝ, 0 < y → F y = c * emlField g y := by
  set a := g.scale with hadef
  set b := g.shift with hbdef
  set p : ℝ := Real.exp (-b / a) with hpdef
  have hp0 : 0 < p := Real.exp_pos _
  have hlogp : Real.log p = -b / a := Real.log_exp _
  have hXval : ∀ y : ℝ, emlField g y = y * (a * Real.log y + b) := fun _ => rfl
  have hXp : emlField g p = 0 := by
    rw [hXval, hlogp]
    field_simp
    ring
  have hXderiv : ∀ y : ℝ, y ≠ 0 →
      HasDerivAt (emlField g) (a * Real.log y + b + a) y := fun y hy =>
    emlField_hasDerivAt g hy
  have hXderivp : HasDerivAt (emlField g) a p := by
    have hd := hXderiv p (ne_of_gt hp0)
    have hval : a * Real.log p + b + a = a := by
      rw [hlogp]; field_simp; ring
    rwa [hval] at hd
  have hXne : ∀ y : ℝ, 0 < y → y ≠ p → emlField g y ≠ 0 := by
    intro y hy hyp hzero
    rw [hXval] at hzero
    rcases mul_eq_zero.mp hzero with h' | h'
    · exact absurd h' (ne_of_gt hy)
    · have hlog : Real.log y = -b / a := by
        field_simp at h' ⊢
        linarith
      have hyeq : y = p := by
        have hexp := congrArg Real.exp hlog
        rw [Real.exp_log hy] at hexp
        rw [hpdef]
        exact hexp
      exact hyp hyeq
  -- the centralizer equation, written out
  have hode : ∀ y : ℝ, 0 < y →
      emlField g y * deriv F y - F y * (a * Real.log y + b + a) = 0 := by
    intro y hy
    have hx := h y hy
    rw [vfBracket, deriv_emlField g (ne_of_gt hy)] at hx
    exact hx
  have hFp : F p = 0 := by
    have hx := hode p hp0
    rw [hXp] at hx
    have hval : a * Real.log p + b + a = a := by rw [hlogp]; field_simp; ring
    rw [hval] at hx
    have : F p * a = 0 := by linarith
    rcases mul_eq_zero.mp this with h' | h'
    · exact h'
    · exact absurd h' ha
  -- the quotient is locally constant off the singular point
  set G : ℝ → ℝ := fun y => F y / emlField g y with hGdef
  have hGderiv : ∀ y : ℝ, 0 < y → y ≠ p → deriv G y = 0 := by
    intro y hy hyp
    have hXy := hXne y hy hyp
    have hd : HasDerivAt G
        ((deriv F y * emlField g y - F y * (a * Real.log y + b + a)) / (emlField g y) ^ 2) y :=
      ((hF y).hasDerivAt).div (hXderiv y (ne_of_gt hy)) hXy
    rw [hd.deriv]
    have hnum : deriv F y * emlField g y - F y * (a * Real.log y + b + a) = 0 := by
      have := hode y hy
      linarith [this, mul_comm (deriv F y) (emlField g y)]
    rw [hnum, zero_div]
  have hGdiffOn : ∀ s : Set ℝ, (∀ y ∈ s, 0 < y) → (∀ y ∈ s, y ≠ p) →
      DifferentiableOn ℝ G s := by
    intro s hs hsp
    exact DifferentiableOn.div hF.differentiableOn
      (fun y hy => (hXderiv y (ne_of_gt (hs y hy))).differentiableAt.differentiableWithinAt)
      (fun y hy => hXne y (hs y hy) (hsp y hy))
  have hlowConst : ∀ y ∈ Set.Ioo (0:ℝ) p, G y = G (p / 2) := by
    intro y hy
    refine isOpen_Ioo.is_const_of_deriv_eq_zero isPreconnected_Ioo
      (hGdiffOn _ (fun z hz => hz.1) (fun z hz => ne_of_lt hz.2))
      (fun z hz => hGderiv z hz.1 (ne_of_lt hz.2)) hy ?_
    constructor <;> [linarith; linarith]
  have hhighConst : ∀ y ∈ Set.Ioi p, G y = G (2 * p) := by
    intro y hy
    refine isOpen_Ioi.is_const_of_deriv_eq_zero isPreconnected_Ioi
      (hGdiffOn _ (fun z hz => lt_trans hp0 hz) (fun z hz => ne_of_gt hz))
      (fun z hz => hGderiv z (lt_trans hp0 hz) (ne_of_gt hz)) hy ?_
    show p < 2 * p
    linarith
  set c₁ := G (p / 2) with hc₁
  set c₂ := G (2 * p) with hc₂
  have hlow : ∀ y ∈ Set.Ioo (0:ℝ) p, F y = c₁ * emlField g y := by
    intro y hy
    have hGy : F y / emlField g y = c₁ := hlowConst y hy
    have hXy := hXne y hy.1 (ne_of_lt hy.2)
    exact (div_eq_iff hXy).mp hGy
  have hhigh : ∀ y ∈ Set.Ioi p, F y = c₂ * emlField g y := by
    intro y hy
    have hGy : F y / emlField g y = c₂ := hhighConst y hy
    have hXy := hXne y (lt_trans hp0 hy) (ne_of_gt hy)
    exact (div_eq_iff hXy).mp hGy
  have hglue : c₁ = c₂ := by
    refine const_glue_of_differentiableAt (emlField g) F p a c₁ c₂ (hF p) hXderivp hXp hFp ha
      ?_ ?_
    · filter_upwards [Ioo_mem_nhdsLT hp0] with y hy
      exact hlow y hy
    · filter_upwards [self_mem_nhdsWithin] with y hy
      exact hhigh y hy
  refine ⟨c₁, ?_⟩
  intro y hy
  rcases lt_trichotomy y p with hyp | hyp | hyp
  · exact hlow y ⟨hy, hyp⟩
  · rw [hyp, hFp, hXp, mul_zero]
  · rw [hhigh y hyp, hglue]

/-- **The centralizer theorem.**  For every nonzero generator `g` the centralizer
of `emlField g` inside the differentiable vector fields on `(0, ∞)` is exactly
the line `ℝ · emlField g`.  This confirms the first half of NC3 and refutes the
second: there is no dichotomy, the answer is one-dimensional in both cases. -/
theorem emlField_centralizer (g : EMLGen) (hg : g ≠ 0)
    (F : ℝ → ℝ) (hF : Differentiable ℝ F)
    (h : ∀ y : ℝ, 0 < y → vfBracket (emlField g) F y = 0) :
    ∃ c : ℝ, ∀ y : ℝ, 0 < y → F y = c * emlField g y := by
  by_cases ha : g.scale = 0
  · have hb : g.shift ≠ 0 := by
      intro hb
      exact hg (by ext <;> simp [ha, hb])
    have hgeq : g = ⟨0, g.shift⟩ := by ext <;> simp [ha]
    refine ⟨F 1 / g.shift, ?_⟩
    intro y hy
    have := emlField_centralizer_of_scale_eq_zero hb F hF
      (by intro z hz; rw [← hgeq]; exact h z hz) y hy
    rw [this, ← hgeq]
  · exact emlField_centralizer_of_scale_ne_zero g ha F hF h

/-- **One-dimensionality, elementary form.**  Any two differentiable fields
commuting with `emlField g` (`g ≠ 0`) are linearly dependent on `(0, ∞)`.  Since
`emlField g` itself is a nonzero member of the centralizer, the centralizer is
exactly one-dimensional. -/
theorem centralizer_pairwise_dependent (g : EMLGen) (hg : g ≠ 0)
    (F₁ F₂ : ℝ → ℝ) (hF₁ : Differentiable ℝ F₁) (hF₂ : Differentiable ℝ F₂)
    (h₁ : ∀ y : ℝ, 0 < y → vfBracket (emlField g) F₁ y = 0)
    (h₂ : ∀ y : ℝ, 0 < y → vfBracket (emlField g) F₂ y = 0) :
    ∃ u v : ℝ, (u, v) ≠ (0, 0) ∧ ∀ y : ℝ, 0 < y → u * F₁ y + v * F₂ y = 0 := by
  obtain ⟨c₁, hc₁⟩ := emlField_centralizer g hg F₁ hF₁ h₁
  obtain ⟨c₂, hc₂⟩ := emlField_centralizer g hg F₂ hF₂ h₂
  by_cases hz : c₁ = 0 ∧ c₂ = 0
  · refine ⟨1, 0, by simp, ?_⟩
    intro y hy
    rw [hc₁ y hy, hz.1]
    ring
  · refine ⟨c₂, -c₁, ?_, ?_⟩
    · intro hcon
      apply hz
      have h1 : c₂ = 0 := congrArg Prod.fst hcon
      have h2 : -c₁ = 0 := congrArg Prod.snd hcon
      exact ⟨by linarith, h1⟩
    · intro y hy
      rw [hc₁ y hy, hc₂ y hy]
      ring

/-- The nonzero member: `emlField g` does not vanish identically on `(0, ∞)`
when `g ≠ 0`, so the centralizer really is one-dimensional and not zero. -/
theorem emlField_ne_zero_on_Ioi (g : EMLGen) (hg : g ≠ 0) :
    ∃ y : ℝ, 0 < y ∧ emlField g y ≠ 0 := by
  by_cases ha : g.scale = 0
  · have hb : g.shift ≠ 0 := by
      intro hb
      exact hg (by ext <;> simp [ha, hb])
    refine ⟨1, one_pos, ?_⟩
    simp [emlField, ha, hb]
  · refine ⟨Real.exp ((1 - g.shift) / g.scale), Real.exp_pos _, ?_⟩
    simp only [emlField, Real.log_exp]
    have hval : g.scale * ((1 - g.shift) / g.scale) + g.shift = 1 := by
      field_simp
      ring
    rw [hval, mul_one]
    exact (Real.exp_pos _).ne'

end EMLNilpotentCentralizer