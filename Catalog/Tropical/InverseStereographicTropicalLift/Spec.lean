import Mathlib

/-!
# Inverse Stereographic Tropical Lift

This file separates two standard conventions for the tropical projective line.
The **finite** line uses only finite tropical coordinates.  After quotienting
`(x₀,x₁)` by simultaneous translation, its canonical coordinate is `x₁-x₀`,
so it is represented here by `ℝ`.  The **compactified** line permits an infinite
endpoint and is represented by `EReal`.

For the finite line, the pole-inspired max-plus rational expression

`max (2x) x - max x 0`

looks quadratic but simplifies globally to `x`.  It is consequently a
homeomorphism.  This also disproves the stronger claim that its *minimal*
tropical rational degree is exactly two: it already has a linear presentation.
For the compactified convention, no homeomorphism to `ℝ` can exist, by
compactness.
-/

namespace InverseStereographicTropicalLift

/-- The finite tropical projective line in its canonical normalized coordinate
`x₁ - x₀`. -/
abbrev FiniteTP1 := ℝ

/-- The compactified tropical projective line, obtained by allowing infinite
coordinates before projectivization. -/
abbrev CompactifiedTP1 := EReal

/-- The quadratic-over-linear max-plus expression proposed as the tropical
stereographic pole construction. -/
def tropicalStereo (x : FiniteTP1) : ℝ :=
  max (2 * x) x - max x 0

/-- A function has the particular quadratic tropical rational shape relevant
for the pole construction.  Coefficients are finite and the displayed leading
quadratic term is present. -/
def HasQuadraticTropicalPresentation (f : ℝ → ℝ) : Prop :=
  ∃ a b c d : ℝ, ∀ x, f x = max (2 * x + a) (x + b) - max (x + c) d

/-- A function has a degree-at-most-one tropical presentation if it is an
ordinary translation in the normalized tropical coordinate. -/
def HasLinearTropicalPresentation (f : ℝ → ℝ) : Prop :=
  ∃ c : ℝ, ∀ x, f x = x + c

/-- The pole expression simplifies to the canonical coordinate. -/
theorem tropicalStereo_eq_identity (x : ℝ) : tropicalStereo x = x := by
  rcases le_total x 0 with hx | hx
  · rw [tropicalStereo, max_eq_right hx]
    have h2x : 2 * x ≤ x := by linarith
    rw [max_eq_right h2x]
    linarith
  · rw [tropicalStereo, max_eq_left hx]
    have h2x : x ≤ 2 * x := by linarith
    rw [max_eq_left h2x]
    linarith

/-- Moving the tropical pole to `p` gives the corresponding family of
quadratic-over-linear expressions. -/
def tropicalStereoAt (p x : ℝ) : ℝ :=
  max (2 * x) (x + p) - max x p

/-- Bold rigidity theorem: every finite pole gives exactly the same normalized
coordinate map.  Thus pole position is erased by tropical projectivization. -/
theorem tropicalStereoAt_eq_identity (p x : ℝ) : tropicalStereoAt p x = x := by
  rw [tropicalStereoAt]
  have hmax : max (2 * x) (x + p) = x + max x p := by
    simpa [two_mul] using (add_max x x p).symm
  rw [hmax]
  ring

/-- Consequently, no pair of finite poles can produce distinct normalized
stereographic maps. -/
theorem tropicalStereo_pole_independence (p q : ℝ) :
    tropicalStereoAt p = tropicalStereoAt q := by
  funext x
  rw [tropicalStereoAt_eq_identity, tropicalStereoAt_eq_identity]

/-- The finite tropical stereographic projection is a homeomorphism
`TP¹_fin ≃ₜ TR¹`. -/
def tropicalStereoHomeomorph : FiniteTP1 ≃ₜ ℝ where
  toFun := tropicalStereo
  invFun := id
  left_inv x := tropicalStereo_eq_identity x
  right_inv x := tropicalStereo_eq_identity x
  continuous_toFun := by
    apply Continuous.congr (continuous_id : Continuous (id : ℝ → ℝ))
    intro x
    exact (tropicalStereo_eq_identity x).symm
  continuous_invFun := continuous_id

/-- The map genuinely admits the proposed quadratic-over-linear tropical
rational presentation. -/
theorem tropicalStereo_has_quadratic_presentation :
    HasQuadraticTropicalPresentation tropicalStereo := by
  refine ⟨0, 0, 0, 0, ?_⟩
  intro x
  simp [tropicalStereo]

/-- Contrarian result: the same map has a linear presentation, so the displayed
quadratic degree is not an intrinsic minimal degree. -/
theorem tropicalStereo_has_linear_presentation :
    HasLinearTropicalPresentation tropicalStereo := by
  exact ⟨0, fun x => by simp [tropicalStereo_eq_identity]⟩

/-- Therefore the conjecture that this map has minimal degree exactly two,
formalized as quadratic-presentable but not linear-presentable, is false. -/
theorem not_tropicalStereo_minimal_degree_two :
    ¬ (HasQuadraticTropicalPresentation tropicalStereo ∧
       ¬ HasLinearTropicalPresentation tropicalStereo) := by
  intro h
  exact h.2 tropicalStereo_has_linear_presentation

/-- Under the compactified convention, the proposed homeomorphism to the real
line is impossible: the source is compact and the target is not. -/
theorem no_compactified_tropical_stereo_homeomorph :
    IsEmpty (CompactifiedTP1 ≃ₜ ℝ) := by
  constructor
  intro h
  have hc : IsCompact (Set.univ : Set CompactifiedTP1) := isCompact_univ
  have hr : IsCompact (Set.univ : Set ℝ) := by
    simpa using hc.image h.continuous
  exact noncompact_univ ℝ hr

/-- Small exact-value table used as computational evidence for both branches of
the piecewise max expression. -/
theorem tropicalStereo_sample_table :
    tropicalStereo (-3) = -3 ∧ tropicalStereo (-1) = -1 ∧
    tropicalStereo 0 = 0 ∧ tropicalStereo 2 = 2 ∧ tropicalStereo 5 = 5 := by
  norm_num [tropicalStereo]

end InverseStereographicTropicalLift