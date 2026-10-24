import Bridges.MultiplicativeHierarchyFibration
import Speculative.AutoResearch.FibreSpectrumRank

/-!
# Conjecture M in the catalog's language

The dictionary `injOrbits_eq_tInj : FibreSpectrum.injOrbits G X r = tInj G X r` identifies the
catalog spectrum (multiplicity of the discrete pattern, `Catalog/Speculative/AutoResearch/
FibreSpectrumRank.lean`) with the orbit count of injective tuples used in
`MultiplicativeHierarchyCore` / `MultiplicativeHierarchyFibration`, and transports every result:
exact fibration formula, refined and corrected hierarchy, sharpness, free-action saturation, and
the refutation of the coarse form `t_{r+s} ≥ t_r · (t_s − r)`.
-/

open MulAction Function

namespace MultiplicativeHierarchy

section Bridge

variable (G : Type*) [Group G] (X : Type*) [MulAction G X]

/-- An orbit of `r`-tuples has the discrete kernel pattern exactly when it consists of injective
tuples. -/
theorem orbitPattern_eq_idPattern_iff {r : ℕ} (o : orbitRel.Quotient G (Fin r → X)) :
    MoonshineBell.orbitPattern o = FibreSpectrum.idPattern r ↔
      ∃ f : Fin r → X, Injective f ∧ Quotient.mk (orbitRel G (Fin r → X)) f = o := by
  induction o using Quotient.inductionOn with
  | h f =>
    rw [MoonshineBell.orbitPattern_mk]
    constructor
    · intro h
      exact ⟨f, FibreSpectrum.injective_iff_kerPat_eq_id.2 (congrArg Subtype.val h), rfl⟩
    · rintro ⟨f', hf', he⟩
      obtain ⟨g, hg⟩ := exists_smul_of_mk_eq he
      exact Subtype.ext (MoonshineBell.kerPat_of_injective (injective_of_smul_eq hg hf'))

/-- **Dictionary.**  The catalog spectrum `t_r = injOrbits G X r` (the multiplicity of the discrete
pattern) is the number `tInj G X r` of orbits of injective `r`-tuples used in this development. -/
theorem injOrbits_eq_tInj (r : ℕ) : FibreSpectrum.injOrbits G X r = tInj G X r := by
  rw [FibreSpectrum.injOrbits, MoonshineFibre.patternMultiplicity, tInj]
  exact Nat.card_congr (Equiv.subtypeEquivRight (orbitPattern_eq_idPattern_iff G X))

variable [Finite X]

/-- **Conjecture M, exact form, in the catalog's language.**
`t_{r+s} = Σ_{[u]} #(Stab(u) \ Inj_s(X ∖ u))`. -/
theorem injOrbits_add_eq_sum_relCount (r s : ℕ) :
    FibreSpectrum.injOrbits G X (r + s) = ∑ᶠ o : InjOrbit G X r, relCount G o.1.out s := by
  rw [injOrbits_eq_tInj]
  exact tInj_add_eq_sum_relCount G X r s

/-- **Conjecture M, refined form, in the catalog's language.**  If every orbit of injective
`r`-tuples is avoided by at least `m` orbits of injective `s`-tuples, then `t_{r+s} ≥ t_r · m`. -/
theorem injOrbits_mul_le_of_avoidCount (r s m : ℕ)
    (hm : ∀ o : InjOrbit G X r, m ≤ avoidCount G X o s) :
    FibreSpectrum.injOrbits G X r * m ≤ FibreSpectrum.injOrbits G X (r + s) := by
  rw [injOrbits_eq_tInj, injOrbits_eq_tInj]
  exact tInj_mul_le_of_avoidCount G X r s m hm

/-- **One step of the hierarchy:** `t_{r+1} ≥ t_r · (t_1 − r)`. -/
theorem injOrbits_mul_sub_le_succ (r : ℕ) :
    FibreSpectrum.injOrbits G X r * (FibreSpectrum.injOrbits G X 1 - r)
      ≤ FibreSpectrum.injOrbits G X (r + 1) := by
  simp only [injOrbits_eq_tInj]
  exact tInj_mul_sub_le_succ G X r

/-- **The full multiplicative hierarchy:** `t_{r+s} ≥ t_r · (t_1 − r)(t_1 − r − 1)⋯(t_1 − r − s + 1)`. -/
theorem injOrbits_mul_descFactorial_le (r s : ℕ) :
    FibreSpectrum.injOrbits G X r * (FibreSpectrum.injOrbits G X 1 - r).descFactorial s
      ≤ FibreSpectrum.injOrbits G X (r + s) := by
  simp only [injOrbits_eq_tInj]
  exact tInj_mul_descFactorial_le G X r s

/-- The base case `r = 0` of the hierarchy: `t_s ≥ t_1^{\underline{s}}`. -/
theorem descFactorial_injOrbits_one_le (s : ℕ) :
    (FibreSpectrum.injOrbits G X 1).descFactorial s ≤ FibreSpectrum.injOrbits G X s := by
  simp only [injOrbits_eq_tInj]
  exact descFactorial_tInj_one_le G X s

/-- The hierarchy is sharp: for a trivial action every inequality is an equality. -/
theorem injOrbits_hierarchy_eq_of_trivial (htriv : ∀ (g : G) (x : X), g • x = x) (r s : ℕ) :
    FibreSpectrum.injOrbits G X (r + s)
      = FibreSpectrum.injOrbits G X r * (FibreSpectrum.injOrbits G X 1 - r).descFactorial s := by
  simp only [injOrbits_eq_tInj]
  exact tInj_hierarchy_eq_of_trivial G X htriv r s

/-- **Free actions saturate the fibration** (catalog language): if every injective `r`-tuple has
trivial stabiliser then `t_{r+s} = t_r · (|X| − r)^{\underline{s}}`. -/
theorem injOrbits_add_eq_of_free (r s : ℕ)
    (hfree : ∀ u : Fin r → X, Injective u → ∀ g : G, g • u = u → g = 1) :
    FibreSpectrum.injOrbits G X (r + s)
      = FibreSpectrum.injOrbits G X r * (Nat.card X - r).descFactorial s := by
  simp only [injOrbits_eq_tInj]
  exact tInj_add_eq_of_free G X r s hfree

/-- **The two-sided sandwich** (catalog language):
`t_r · (t_1 − r)^{\underline{s}} ≤ t_{r+s} ≤ t_r · (|X| − r)^{\underline{s}}`. -/
theorem injOrbits_sandwich (r s : ℕ) :
    FibreSpectrum.injOrbits G X r * (FibreSpectrum.injOrbits G X 1 - r).descFactorial s
        ≤ FibreSpectrum.injOrbits G X (r + s) ∧
      FibreSpectrum.injOrbits G X (r + s)
        ≤ FibreSpectrum.injOrbits G X r * (Nat.card X - r).descFactorial s := by
  simp only [injOrbits_eq_tInj]
  exact ⟨tInj_mul_descFactorial_le G X r s, tInj_add_le G X r s⟩

/-- **The coarse form of Conjecture M, repaired** (catalog language): the correction `r` must be
replaced by `|X|^{\underline{s}} − (|X| − r)^{\underline{s}}`, which equals `r` when `s = 1`. -/
theorem injOrbits_mul_sub_correction_le (r s : ℕ) :
    FibreSpectrum.injOrbits G X r * (FibreSpectrum.injOrbits G X s
        - ((Nat.card X).descFactorial s - (Nat.card X - r).descFactorial s))
      ≤ FibreSpectrum.injOrbits G X (r + s) := by
  simp only [injOrbits_eq_tInj]
  exact tInj_mul_sub_correction_le G X r s

end Bridge

/-- **The coarse form of Conjecture M is false** (catalog language): `t_{r+s} ≥ t_r · (t_s − r)`
fails for the trivial group on three points with `r = 1`, `s = 2`. -/
theorem injOrbits_coarse_conjecture_false :
    ¬ ∀ (G : Type) [Group G] (X : Type) [MulAction G X] [Finite X] (r s : ℕ),
      r + s ≤ Nat.card X →
        FibreSpectrum.injOrbits G X r * (FibreSpectrum.injOrbits G X s - r)
          ≤ FibreSpectrum.injOrbits G X (r + s) := by
  intro h
  apply coarse_conjecture_false
  intro G _ X _ _ r s hrs
  have := h G X r s hrs
  simpa only [injOrbits_eq_tInj] using this

end MultiplicativeHierarchy