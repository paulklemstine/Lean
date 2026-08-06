import Mathlib

/-!
# The successor and limit structure of the aleph/beth hierarchies

This file locates the Continuum Hypothesis precisely inside the transfinite
cardinal hierarchy and develops the interaction between the two canonical
towers of infinite cardinals: the *aleph* hierarchy `ℵ_o`, defined by
successor and supremum, and the *beth* hierarchy `ℶ_o`, defined by iterated
exponentiation.

The results are organized around three questions.

* **What is the least uncountable cardinal?**  We characterize `ℵ₁` purely in
  terms of a countability predicate on types: a type has cardinality below
  `ℵ₁` exactly when it is countable, `ℵ₁` is the least cardinal strictly above
  `ℵ₀`, and nothing lies strictly between `ℵ₀` and `ℵ₁`.

* **Where does the Continuum Hypothesis live?**  We give three equivalent
  formulations of `CH`: the successor form `ℵ₁ = 𝔠`, the "no intermediate
  cardinal" form, and the classical statement that every set of reals is
  countable or of full continuum size.  Each isolates the single undecidable
  inequality `𝔠 ≤ ℵ₁`.

* **How do the aleph and beth towers compare?**  We compute `ℶ₁ = 𝔠`, recast
  `CH` as the coincidence `ℵ₁ = ℶ₁`, and prove that under the Generalized
  Continuum Hypothesis the two hierarchies agree at *every* ordinal stage
  `ℶ_o = ℵ_o`, from which `CH` follows.

All statements are theorems of ordinary set theory; the independence of `CH`
and `GCH` themselves is a separate metatheoretic matter.
-/

open Cardinal Ordinal

namespace CardinalHierarchy

universe u

/-! ## 1. The least uncountable cardinal

`ℵ₁` is the least uncountable cardinal.  We first phrase this through the
countability predicate on types, then as a minimality property, and finally as
the absence of any cardinal strictly between `ℵ₀` and `ℵ₁`. -/

/-- A type has cardinality strictly below `ℵ₁` **iff** it is countable.  This is
the type-theoretic face of "`ℵ₁` is the first uncountable cardinal": the
cardinals below `ℵ₁` are exactly `0, 1, 2, …, ℵ₀`. -/
theorem mk_lt_alephOne_iff_countable (α : Type u) :
    (#α) < aleph 1 ↔ Countable α := by
  rw [← Cardinal.succ_aleph0, Order.lt_succ_iff, Cardinal.mk_le_aleph0_iff]

/-- **`ℵ₁` is the least uncountable cardinal.**  Any cardinal strictly larger
than `ℵ₀` is already at least `ℵ₁`.  This expresses `ℵ₁` as the successor of
`ℵ₀` in its minimality form. -/
theorem alephOne_least_uncountable {c : Cardinal.{u}} (h : ℵ₀ < c) :
    aleph 1 ≤ c := by
  rw [← Cardinal.succ_aleph0]
  exact Order.succ_le_of_lt h

/-- There is **no cardinal strictly between** `ℵ₀` and `ℵ₁`: the step from the
countable to the first uncountable cardinal is a genuine successor step, with no
intermediate cardinality. -/
theorem no_cardinal_between_aleph0_alephOne :
    ¬ ∃ c : Cardinal.{u}, ℵ₀ < c ∧ c < aleph 1 := by
  rintro ⟨c, h1, h2⟩
  rw [← Cardinal.succ_aleph0, Order.lt_succ_iff] at h2
  exact absurd h2 (not_le.2 h1)

/-! ## 2. The Continuum Hypothesis, placed exactly

The Continuum Hypothesis asserts that the first uncountable cardinal is the
cardinality of the continuum.  Since `ℵ₁ ≤ 𝔠` always holds, `CH` is precisely
the reverse inequality; we present three faces of this single statement. -/

/-- The **Continuum Hypothesis**: the first uncountable cardinal equals the
cardinality of the continuum. -/
def CH : Prop := aleph.{0} 1 = continuum.{0}

/-- **`CH` as the absence of an intermediate cardinal.**  The Continuum
Hypothesis holds exactly when no cardinal lies strictly between `ℵ₀` and the
continuum — i.e. when the continuum is the immediate successor of the countable
infinite. -/
theorem CH_iff_no_cardinal_between :
    CH ↔ ¬ ∃ c : Cardinal.{0}, ℵ₀ < c ∧ c < continuum := by
  constructor
  · intro h
    rw [← h]
    rintro ⟨c, h1, h2⟩
    rw [← Cardinal.succ_aleph0, Order.lt_succ_iff] at h2
    exact absurd h2 (not_le.2 h1)
  · intro h
    have h1 : ℵ₀ < aleph 1 := Cardinal.aleph0_lt_aleph_one
    have h2 : aleph 1 ≤ continuum := Cardinal.aleph_one_le_continuum
    rcases lt_or_eq_of_le h2 with hlt | heq
    · exact absurd ⟨aleph 1, h1, hlt⟩ h
    · exact heq

/-- **`CH` as a dichotomy for sets of reals.**  The Continuum Hypothesis holds
exactly when every set of real numbers is either countable or of full continuum
cardinality — Cantor's original formulation.  The forward direction squeezes an
uncountable set between `ℵ₁` and `𝔠`; the reverse produces a set of reals of
size `ℵ₁` and forces it to have size `𝔠`. -/
theorem CH_iff_subsets_of_reals :
    CH ↔ ∀ S : Set ℝ, S.Countable ∨ #S = continuum := by
  constructor
  · intro hCH S
    by_cases hc : S.Countable
    · exact Or.inl hc
    · right
      rw [Cardinal.countable_iff_lt_aleph_one, not_lt] at hc
      have hup : #S ≤ continuum := by
        have := Cardinal.mk_set_le S
        rwa [Cardinal.mk_real] at this
      rw [hCH] at hc
      exact le_antisymm hup hc
  · intro h
    have hle : aleph 1 ≤ #ℝ := by
      rw [Cardinal.mk_real]; exact Cardinal.aleph_one_le_continuum
    obtain ⟨S, hS⟩ := Cardinal.le_mk_iff_exists_set.mp hle
    have hnc : ¬ S.Countable := by
      rw [Cardinal.countable_iff_lt_aleph_one, hS]; exact lt_irrefl _
    rcases h S with hc | heq
    · exact absurd hc hnc
    · rw [hS] at heq; exact heq

/-! ## 3. The aleph and beth hierarchies

The beth hierarchy is generated from `ℵ₀` by iterated exponentiation:
`ℶ₀ = ℵ₀` and `ℶ_{o+1} = 2 ^ ℶ_o`.  Its first uncountable stage is the
continuum, which recasts `CH` as the coincidence of the two hierarchies at
stage `1`. -/

/-- The first beth stage is the continuum: `ℶ₁ = 2 ^ ℵ₀ = 𝔠`. -/
theorem beth_one_eq_continuum : beth 1 = continuum := by
  have h : (1 : Ordinal) = Order.succ 0 := by simp
  rw [h, Cardinal.beth_succ, Cardinal.beth_zero, Cardinal.two_power_aleph0]

/-- The first uncountable cardinal never exceeds the first beth stage:
`ℵ₁ ≤ ℶ₁`.  Equality is exactly the Continuum Hypothesis. -/
theorem alephOne_le_beth_one : aleph.{0} 1 ≤ beth.{0} 1 := by
  rw [beth_one_eq_continuum]
  exact Cardinal.aleph_one_le_continuum

/-- **`CH` as the meeting of the two hierarchies.**  The Continuum Hypothesis is
precisely the statement that the aleph and beth towers agree at stage `1`,
`ℵ₁ = ℶ₁`. -/
theorem CH_iff_alephOne_eq_beth_one : CH ↔ aleph.{0} 1 = beth.{0} 1 := by
  rw [beth_one_eq_continuum]
  rfl

/-! ## 4. The Generalized Continuum Hypothesis and full hierarchy coincidence

The Generalized Continuum Hypothesis asserts that exponentiation acts as the
successor operation on every infinite cardinal.  Under this assumption the beth
and aleph hierarchies coincide at every ordinal stage, by transfinite induction
through zero, successor, and limit stages. -/

/-- The **Generalized Continuum Hypothesis** as a statement about cardinal
exponentiation: for every infinite cardinal `c`, its power `2 ^ c` is the
immediate successor `c⁺`. -/
def GCH_pred : Prop := ∀ c : Cardinal.{u}, ℵ₀ ≤ c → 2 ^ c = Order.succ c

/-- **Under GCH the beth and aleph hierarchies coincide at every stage**:
`ℶ_o = ℵ_o` for all ordinals `o`.  The proof is by transfinite induction:
at `0` both towers start at `ℵ₀`; the successor step converts exponentiation
`2 ^ ℶ_o` into the cardinal successor via GCH, matching `ℵ_{o+1} = (ℵ_o)⁺`; and
at a limit stage both towers are suprema of their earlier values, equal by the
inductive hypothesis. -/
theorem GCH_beth_eq_aleph (h : GCH_pred.{u}) (o : Ordinal.{u}) :
    beth o = aleph o := by
  induction o using Ordinal.limitRecOn with
  | zero => rw [Cardinal.beth_zero, Cardinal.aleph_zero]
  | succ o ih =>
      rw [Cardinal.beth_succ, ih, h _ (Cardinal.aleph0_le_aleph o), Cardinal.aleph_succ]
  | limit o hlim ih =>
      rw [Cardinal.beth_limit hlim, Cardinal.aleph_limit hlim]
      exact iSup_congr (fun a => ih a a.2)

/-- **GCH implies CH.**  Specializing the hierarchy coincidence to stage `1`
gives `ℶ₁ = ℵ₁`; since `ℶ₁ = 𝔠`, the Continuum Hypothesis follows. -/
theorem GCH_implies_CH (h : GCH_pred.{0}) : CH := by
  have hstage := GCH_beth_eq_aleph h 1
  rw [beth_one_eq_continuum] at hstage
  exact hstage.symm

end CardinalHierarchy

/-
-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer).
  Building on the previous cycle's Cantor tower (`ℵ₀ < 2^ℵ₀ < …`) and its
  isolation of CH into the single inequality `𝔠 ≤ ℵ₁`, we conjectured that the
  Continuum Hypothesis admits several structurally distinct but provably
  equivalent presentations, and that the aleph/beth hierarchies can be compared
  stage by stage.  Boldest conjecture: under a cardinal-arithmetic form of GCH,
  the aleph and beth towers coincide at *every* ordinal, not merely finitely.

Experiment (Experimenter).
  - `mk_lt_alephOne_iff_countable`: reduced `#α < ℵ₁` to `#α ≤ ℵ₀` through
    `succ_aleph0` and `lt_succ_iff`, then to `Countable α`.
  - Three CH equivalences: the "no intermediate cardinal" and "dichotomy for
    sets of reals" forms both hinge on `countable_iff_lt_aleph_one` and the
    fact that `ℵ₁` is the successor of `ℵ₀`.  The reals-dichotomy reverse
    direction required manufacturing a set of reals of size `ℵ₁` via
    `le_mk_iff_exists_set`.
  - `GCH_beth_eq_aleph`: transfinite induction with `limitRecOn`; the limit
    case used `beth_limit`, `aleph_limit`, and `iSup_congr`.

Analysis (Analyst).
  All conjectures survived as theorems of ZFC.  The unifying structural pattern
  is that `ℵ₁` is a *successor* cardinal: every result reduces to "`< succ`
  means `≤`", whether phrased via countability, intermediate cardinals, or
  subsets of the reals.  The GCH result shows the beth hierarchy is exactly the
  aleph hierarchy precisely when exponentiation *is* succession, cleanly
  separating the arithmetic content (GCH) from the ordinal bookkeeping
  (induction through limits).

Critique (Critic).
  - None of the theorems is vacuous: `CH` and `GCH_pred` are genuine `Prop`s,
    not `True`, and the equivalences have non-trivial content in both
    directions (checked that neither side is definitionally the other).
  - `CH_iff_alephOne_eq_beth_one` closes by `rfl` only *after* the substantive
    rewrite `beth_one_eq_continuum`; the mathematical work is the beth
    computation, not the final unfolding.
  - No theorem references itself; each proof uses only earlier results and
    Mathlib lemmas.  Independence of CH/GCH is deliberately *not* claimed —
    these are ZFC theorems about where CH sits, not metatheoretic results.

Synthesis (Principal Investigator).
  The Continuum Hypothesis is pinned to a single successor step, exhibited in
  three equivalent guises, and lifted to the full hierarchy comparison
  `GCH → ∀ o, ℶ_o = ℵ_o → CH`.  See FUTURE_DIRECTIONS.md for the next round.
-/