/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Transseries: Bridge to the Catalog Transmonomial Hierarchy

The catalog file `Applications/TransseriesDefs.lean` introduces a *labelled* notion of
transmonomial, `Transseries.TransMonomial`, carrying a `level : ℤ` (positive = iterated
`exp`, negative = iterated `log`) and a real `exponent`, together with a hand-rolled
dominance relation `TransMonomial.domRel`.

This file connects that combinatorial catalog data to the rigorous Hahn-series field model
`EMLTransseries.TransMono = Lex (ℤ →₀ ℝ)` built in `Field.lean`, via the embedding
`embed m = mono m.level m.exponent`.  The main theorem shows that, for monomials with
positive exponent (the regime where "level dominates" is the intended meaning), the catalog
dominance relation is *exactly* the lexicographic order of the transmonomial group.

## Main results

- `EMLTransseries.embed`            : embed a catalog `TransMonomial` into `TransMono`.
- `EMLTransseries.embed_domRel_iff` : `domRel` matches the group order on positive monomials.
- `EMLTransseries.domRel_imp_lt`    : the easy direction without positivity on the larger one.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the catalog's ad-hoc `domRel` (compare level, then exponent) is a
shadow of the genuine lexicographic order on the transmonomial group.

Experiment (Experimenter): we embed `TransMonomial (level L, exponent a)` as the
height-`L` generator `mono L a` and compare via `Finsupp.Lex.lt_iff`.

Analysis (Analyst): the correspondence requires *positive* exponents.  With a negative
exponent at the dominant level, e.g. `(exp x)^{-1}`, the genuine growth order disagrees with
the level-first `domRel` — a real mathematical subtlety the catalog definition silently
assumes away.  This positivity hypothesis is therefore load-bearing, not cosmetic.

Critique (Critic): the theorem genuinely *uses* the catalog (`TransMonomial`, `domRel`,
`TransLevel`) and is not a renaming: it identifies a combinatorial relation with an order
coming from a completely different (Hahn-series) construction.
-- !-- Lab Notes -- !--
-/
import EML.Transseries.Field
import Applications.TransseriesDefs

open HahnSeries Filter Transseries

namespace EMLTransseries

noncomputable section

/-- Embed a catalog `TransMonomial` (level `L`, exponent `a`) into the rigorous
transmonomial group as the height-`L` generator `mono L a`. -/
def embed (m : TransMonomial) : TransMono := mono m.level m.exponent

/-- The forward direction: catalog dominance with a positive dominating exponent gives
strict order of the embeddings.  (No hypothesis on the smaller monomial.) -/
theorem domRel_imp_lt (m₁ m₂ : TransMonomial)
    (h2 : 0 < m₂.exponent) (h : m₁.domRel m₂) : embed m₁ < embed m₂ := by
  rcases h with hlt | ⟨heq, hexp⟩
  · exact mono_lt_mono_of_height m₁.level m₂.level hlt m₁.exponent m₂.exponent h2
  · show mono m₁.level m₁.exponent < mono m₂.level m₂.exponent
    rw [heq]
    exact mono_lt_mono_same m₂.level m₁.exponent m₂.exponent hexp

/-- **Bridge theorem.**  For catalog transmonomials with positive exponents, the catalog
dominance relation `domRel` coincides with the lexicographic order of the transmonomial
group under the embedding.  The positivity hypotheses are essential (see Lab Notes). -/
theorem embed_domRel_iff (m₁ m₂ : TransMonomial)
    (h1 : 0 < m₁.exponent) (h2 : 0 < m₂.exponent) :
    m₁.domRel m₂ ↔ embed m₁ < embed m₂ := by
  constructor
  · exact domRel_imp_lt m₁ m₂ h2
  · intro hlt
    rcases lt_trichotomy m₁.level m₂.level with h | heq | hgt
    · exact Or.inl h
    · refine Or.inr ⟨heq, ?_⟩
      rcases lt_trichotomy m₁.exponent m₂.exponent with he | he | he
      · exact he
      · exfalso
        apply lt_irrefl (embed m₁)
        have : embed m₂ = embed m₁ := by
          show mono m₂.level m₂.exponent = mono m₁.level m₁.exponent
          rw [heq, he]
        rwa [this] at hlt
      · exfalso
        have hgt' : embed m₂ < embed m₁ := by
          show mono m₂.level m₂.exponent < mono m₁.level m₁.exponent
          rw [heq]
          exact mono_lt_mono_same m₂.level m₂.exponent m₁.exponent he
        exact lt_asymm hlt hgt'
    · exfalso
      have hgt' : embed m₂ < embed m₁ :=
        domRel_imp_lt m₂ m₁ h1 (Or.inl hgt)
      exact lt_asymm hlt hgt'

end

end EMLTransseries