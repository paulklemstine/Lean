/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Transseries: The Exp/Log Substitution is a Field Automorphism, and Tower Cofinality

Building on `ExpShift.lean`, this file closes two of the conjectures raised in the previous
cycle's `FUTURE_DIRECTIONS.md`:

* **C1** — the exp-substitution `expShift : TSeries →+* TSeries` is in fact a **field
  automorphism**.  Its inverse is the *log-substitution* `logShift` (index translation
  `i ↦ i + 1`, i.e. tower height `h ↦ h - 1`).  We package the pair as a `RingEquiv`
  `expShiftEquiv : TSeries ≃+* TSeries`.

* **C3** — the standard exp-tower `x, exp x, exp(exp x), …` is **cofinal** in the
  transmonomial value group: every transmonomial is dominated by some `exp^n x`.  This
  upgrades `ExponentLaws.exists_gt` ("a larger element exists") to "the canonical exp-tower
  already exhausts all growth orders from above".

## Main results

- `EMLTransseries.logShift`            : the log-substitution ring homomorphism.
- `EMLTransseries.logShift_term`       : `logShift (term h a) = term (h-1) a`.
- `EMLTransseries.expShift_logShift`   : `expShift ∘ logShift = id`.
- `EMLTransseries.logShift_expShift`   : `logShift ∘ expShift = id`.
- `EMLTransseries.expShiftEquiv`       : the field automorphism `TSeries ≃+* TSeries`.
- `EMLTransseries.exists_exp_tower_gt` : the exp-tower is cofinal in the value group.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): if `x ↦ exp x` is a ring endomorphism (C1 from last cycle), it
ought to be invertible, with inverse `x ↦ log x`; and the *concrete* exp-tower (not just some
abstract larger element) should be cofinal.

Experiment (Experimenter): `logShift` mirrors `expShift` with the inverse index translation
`i ↦ i + 1`.  The round-trips reduce, via `Finsupp.equivMapDomain_trans`, to
`logEquiv.trans shiftEquiv = Equiv.refl` (and symmetrically), so at the value-group level
`shift ∘ lshift = id`.  Lifting to the ring level uses `HahnSeries.embDomain_coeff` together
with surjectivity of the (now bijective) height shift.  Cofinality reuses the
`Finsupp.Lex.lt_iff` "first differing index" technique from `exists_gt`, choosing the tower
height `n = (1 - i₀).toNat` just past the most significant index `i₀` of the given monomial.

Analysis (Analyst): C1 promotes the embedding to a genuine *symmetry of the asymptotic
field*: exp- and log-substitution are mutually inverse order automorphisms of the value
group, so the whole dominance hierarchy is invariant under shifting the tower.  C3 shows the
hierarchy is not merely unbounded but is *generated from above* by a single explicit sequence
— the iterated exponentials — which is the precise sense in which transseries "go beyond"
every power series at once.

Critique (Critic): the automorphism is not a formality — surjectivity genuinely needs the
two-sided value-group inverse and the `embDomain` coefficient calculus; `RingEquiv.ofBijective`
then only packages injectivity (`ExpShift.expShift_injective`) with this surjectivity.
Cofinality is constructive: the witness `n` is computed from the monomial's support, and the
`<` is verified, not asserted.
-- !-- Lab Notes -- !--
-/
import EML.Transseries.ExpShift
import EML.Transseries.ExponentLaws

open HahnSeries

namespace EMLTransseries

noncomputable section

/-! ### The log-substitution `logShift` -/

/-- The index translation `i ↦ i + 1` on `ℤ`, the engine of the log-substitution. -/
def logEquiv : ℤ ≃ ℤ := Equiv.addRight 1

/-- The **log-substitution** acting on transmonomials: relabel the tower-height index by
`i ↦ i + 1`, i.e. lower every tower height by one (`exp x ↦ x`, `x ↦ log x`, …). -/
def lshift (x : TransMono) : TransMono := toLex (Finsupp.equivMapDomain logEquiv (ofLex x))

/-- `lshift` as an additive group homomorphism on the transmonomial group. -/
def lshiftHom : TransMono →+ TransMono where
  toFun := lshift
  map_zero' := by simp [lshift]
  map_add' x y := by
    simp only [lshift, ofLex_add, Finsupp.equivMapDomain_eq_mapDomain, Finsupp.mapDomain_add,
      toLex_add]

theorem lshift_inj : Function.Injective lshift := by
  intro x y h
  have h2 := congrArg ofLex h
  simp only [lshift, ofLex_toLex, Finsupp.equivMapDomain_eq_mapDomain] at h2
  exact ofLex_inj.mp (Finsupp.mapDomain_injective logEquiv.injective h2)

/-- Log-substitution preserves dominance: it is an order isomorphism of the value group. -/
theorem lshift_lt_iff (x y : TransMono) : lshift x < lshift y ↔ x < y := by
  unfold lshift
  rw [Finsupp.Lex.lt_iff, Finsupp.Lex.lt_iff]
  constructor
  · rintro ⟨i, hlt, hi⟩
    refine ⟨logEquiv.symm i, fun d hd => ?_, ?_⟩
    · have := hlt (logEquiv d) (by simp [logEquiv, Equiv.addRight] at *; omega)
      simpa [Finsupp.equivMapDomain_apply] using this
    · simpa [Finsupp.equivMapDomain_apply] using hi
  · rintro ⟨i, hlt, hi⟩
    refine ⟨logEquiv i, fun d hd => ?_, ?_⟩
    · have := hlt (logEquiv.symm d) (by simp [logEquiv, Equiv.addRight] at *; omega)
      simpa [Finsupp.equivMapDomain_apply] using this
    · simpa [Finsupp.equivMapDomain_apply] using hi

theorem lshiftHom_le_iff (g g' : TransMono) : lshiftHom g ≤ lshiftHom g' ↔ g ≤ g' := by
  show lshift g ≤ lshift g' ↔ g ≤ g'
  rw [le_iff_lt_or_eq, le_iff_lt_or_eq, lshift_lt_iff]
  exact ⟨fun h => h.imp id (fun e => lshift_inj e), fun h => h.imp id (fun e => by rw [e])⟩

/-- The **log-substitution ring homomorphism** `x ↦ log x` on transseries. -/
def logShift : TSeries →+* TSeries :=
  HahnSeries.embDomainRingHom lshiftHom lshift_inj lshiftHom_le_iff

theorem lshift_mono (h : ℤ) (a : ℝ) : lshift (mono h a) = mono (h - 1) a := by
  unfold lshift mono
  rw [ofLex_toLex]
  congr 1
  ext i
  rw [Finsupp.equivMapDomain_apply, Finsupp.single_apply, Finsupp.single_apply]
  have hs : (logEquiv.symm i) = i - 1 := by simp [logEquiv, sub_eq_add_neg]
  rw [hs]
  rcases eq_or_ne (-h) (i - 1) with h1 | h1
  · rw [if_pos h1, if_pos (by omega)]
  · rw [if_neg h1, if_neg (by omega)]

/-- Log-substitution on a one-term transseries lowers the tower height by one. -/
theorem logShift_term (h : ℤ) (a : ℝ) : logShift (term h a) = term (h - 1) a := by
  unfold logShift term
  rw [HahnSeries.embDomainRingHom_apply, HahnSeries.embDomain_single]
  show single (lshift (mono h a)) (1 : ℝ) = single (mono (h - 1) a) 1
  rw [lshift_mono]

/-! ### The round-trips, and the field automorphism -/

theorem shift_lshift (x : TransMono) : shift (lshift x) = x := by
  unfold shift lshift
  have he : logEquiv.trans shiftEquiv = Equiv.refl ℤ := by
    ext i; simp [logEquiv, shiftEquiv, Equiv.addRight, Equiv.subRight]
  rw [ofLex_toLex, ← Finsupp.equivMapDomain_trans, he, Finsupp.equivMapDomain_refl, toLex_ofLex]

theorem lshift_shift (x : TransMono) : lshift (shift x) = x := by
  unfold shift lshift
  have he : shiftEquiv.trans logEquiv = Equiv.refl ℤ := by
    ext i; simp [logEquiv, shiftEquiv, Equiv.addRight, Equiv.subRight]
  rw [ofLex_toLex, ← Finsupp.equivMapDomain_trans, he, Finsupp.equivMapDomain_refl, toLex_ofLex]

/-- `expShift ∘ logShift = id`: log-substitution undoes exp-substitution. -/
theorem expShift_logShift (t : TSeries) : expShift (logShift t) = t := by
  unfold expShift logShift
  rw [HahnSeries.embDomainRingHom_apply, HahnSeries.embDomainRingHom_apply]
  ext g
  have hg : g = (⟨⟨shiftHom, shift_inj⟩, shiftHom_le_iff _ _⟩ : TransMono ↪o TransMono)
      (lshift g) := by
    show g = shift (lshift g); rw [shift_lshift]
  rw [hg, HahnSeries.embDomain_coeff]
  show (HahnSeries.embDomain _ t).coeff (lshift g) = t.coeff (shift (lshift g))
  rw [shift_lshift]
  exact HahnSeries.embDomain_coeff (a := g)

/-- `logShift ∘ expShift = id`: exp-substitution undoes log-substitution. -/
theorem logShift_expShift (t : TSeries) : logShift (expShift t) = t := by
  unfold expShift logShift
  rw [HahnSeries.embDomainRingHom_apply, HahnSeries.embDomainRingHom_apply]
  ext g
  have hg : g = (⟨⟨lshiftHom, lshift_inj⟩, lshiftHom_le_iff _ _⟩ : TransMono ↪o TransMono)
      (shift g) := by
    show g = lshift (shift g); rw [lshift_shift]
  rw [hg, HahnSeries.embDomain_coeff]
  show (HahnSeries.embDomain _ t).coeff (shift g) = t.coeff (lshift (shift g))
  rw [lshift_shift]
  exact HahnSeries.embDomain_coeff (a := g)

/-- **The exp-substitution is a field automorphism** of the transseries field, with inverse
the log-substitution.  Exp- and log-substitution are mutually inverse symmetries of the
entire asymptotic dominance hierarchy. -/
def expShiftEquiv : TSeries ≃+* TSeries :=
  RingEquiv.ofBijective expShift
    ⟨expShift_injective, fun t => ⟨logShift t, expShift_logShift t⟩⟩

@[simp] theorem expShiftEquiv_apply (t : TSeries) : expShiftEquiv t = expShift t := rfl

theorem expShiftEquiv_symm_apply (t : TSeries) : expShiftEquiv.symm t = logShift t := by
  apply expShiftEquiv.injective
  rw [expShiftEquiv.apply_symm_apply, expShiftEquiv_apply, expShift_logShift]

/-! ### Cofinality of the exp-tower in the value group (C3) -/

/-- **The exp-tower is cofinal.**  Every transmonomial `g` is strictly dominated by some
iterated exponential `exp^n x = mono n 1`.  Thus the explicit sequence
`x, exp x, exp(exp x), …` exhausts all growth orders from above — the sharp sense in which
transseries surpass every power series simultaneously. -/
theorem exists_exp_tower_gt (g : TransMono) : ∃ n : ℕ, g < mono n 1 := by
  classical
  set f := ofLex g with hf
  by_cases hsupp : f.support.Nonempty
  · obtain ⟨i₀, hi₀mem, hi₀⟩ := f.support.exists_min_image id hsupp
    refine ⟨(1 - i₀).toNat, ?_⟩
    rw [show g = toLex f from rfl, mono, Finsupp.Lex.lt_iff]
    refine ⟨-((1 - i₀).toNat : ℤ), fun d hd => ?_, ?_⟩
    · simp only [ofLex_toLex, Finsupp.single_apply]
      rw [if_neg (by omega)]
      have hd' : d ∉ f.support := fun hmem => by
        have := hi₀ d hmem; simp only [id] at this; omega
      exact Finsupp.notMem_support_iff.mp hd'
    · simp only [ofLex_toLex, Finsupp.single_eq_same]
      have hd' : (-((1 - i₀).toNat : ℤ)) ∉ f.support := fun hmem => by
        have := hi₀ _ hmem; simp only [id] at this; omega
      rw [Finsupp.notMem_support_iff.mp hd']
      norm_num
  · rw [Finset.not_nonempty_iff_eq_empty, Finsupp.support_eq_empty] at hsupp
    refine ⟨1, ?_⟩
    rw [show g = toLex f from rfl, hsupp, mono, Finsupp.Lex.lt_iff]
    refine ⟨-1, fun d hd => ?_, ?_⟩
    · simp only [ofLex_toLex, Finsupp.coe_zero, Pi.zero_apply, Finsupp.single_apply]
      rw [if_neg (by push_cast; omega)]
    · simp only [ofLex_toLex, Finsupp.coe_zero, Pi.zero_apply]
      rw [show (-1 : ℤ) = -((1 : ℕ) : ℤ) by norm_num, Finsupp.single_eq_same]; norm_num

end

end EMLTransseries