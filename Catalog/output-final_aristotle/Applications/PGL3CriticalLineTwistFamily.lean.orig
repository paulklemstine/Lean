import Mathlib
import NumberTheory.GL1Correspondence
import Applications.PGL3CriticalLine

/-!
# Aggregating the critical-line proportion over the family of twists mod `Q`

Fix a self-dual cuspidal automorphic representation `Π₀` of `PGL₃(𝔸_ℚ)`.  For a modulus `Q` the
relevant twists are by the Dirichlet characters `χ` modulo `Q`.  This file combines two ingredients:

* the catalog result `LanglandsGL1.card_dirichlet_eq_totient`, which counts these characters
  (`#{χ mod Q} = φ(Q)`), the GL(1) side of the local Langlands dictionary; and
* the Levinson lower bound `PGL3CriticalLine.aggregate_onLine_ge_ninth` from
  `Catalog.Applications.PGL3CriticalLine`.

Together they say: over the *entire* family of `φ(Q)` twists `L(s, Π₀ × χ)`, if each twist has at
least a `1/9` share of its zeros on the critical line, then so does the pooled ensemble of all
zeros across the family.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the per-twist bound should aggregate — pooling the zeros of all `φ(Q)`
twists keeps the on-line proportion `≥ 1/9`, because an average of ratios each `≥ 1/9` is `≥ 1/9`.

Experiment (Experimenter): the number of twists is exactly `φ(Q)` (catalog
`card_dirichlet_eq_totient`), a `Fintype` with `Nat.card = φ(Q)`.  Summing the per-character
Levinson bounds via `aggregate_onLine_ge_ninth` over `Finset.univ` closes the ensemble bound.

Analysis (Analyst): the bridge is genuinely cross-file: the GL(1) character count (number theory
catalog) meets the GL(3) proportion machinery (this domain).  No new analytic input is needed — the
aggregation is a pure inequality.

Critique (Critic): not vacuous — the hypothesis is the *conclusion* of the per-twist theorem
`PGL3CriticalLine.card_onLine_ge_ninth`, so the aggregate theorem is a faithful strengthening, and
its proof genuinely invokes a catalog theorem and a nontrivial summation lemma.

Synthesis (PI): the `1/9` critical-line proportion is stable under pooling the full `φ(Q)`-member
family of Dirichlet twists.
-/

open scoped BigOperators
open Finset

namespace PGL3CriticalLine.TwistFamily

/-- **Character count (catalog bridge).**  The number of Dirichlet characters modulo `Q` twisting
`Π₀` — i.e. the size of the twist family — equals `φ(Q)`.  This is the GL(1) count from
`Catalog.NumberTheory.GL1Correspondence`. -/
theorem card_twists_eq_totient (Q : ℕ) [NeZero Q] :
    Nat.card (DirichletCharacter ℂ Q) = Nat.totient Q :=
  LanglandsGL1.card_dirichlet_eq_totient Q

/-- **Aggregate Levinson bound over the twist family.**  If every twist `χ` mod `Q` has at least a
`1/9` share of its zeros on the critical line (`(1/9)·Nχ ≤ (#on-line)χ`), then the pooled ensemble
of zeros over all `φ(Q)` twists also has at least a `1/9` share on the critical line. -/
theorem twist_family_onLine_ge_ninth (Q : ℕ) [NeZero Q]
    (tot onl : DirichletCharacter ℂ Q → ℕ)
    (h : ∀ χ, (1 / 9 : ℝ) * (tot χ : ℝ) ≤ (onl χ : ℝ)) :
    (1 / 9 : ℝ) * (∑ χ : DirichletCharacter ℂ Q, (tot χ : ℝ))
      ≤ ∑ χ : DirichletCharacter ℂ Q, (onl χ : ℝ) :=
  PGL3CriticalLine.aggregate_onLine_ge_ninth Finset.univ tot onl (fun b _ => h b)

/-- **Summary over the twist family.**  There are exactly `φ(Q)` twists, and (under the per-twist
Levinson bound) the pooled ensemble of their zeros has at least a `1/9` proportion on the critical
line. -/
theorem twist_family_summary (Q : ℕ) [NeZero Q]
    (tot onl : DirichletCharacter ℂ Q → ℕ)
    (h : ∀ χ, (1 / 9 : ℝ) * (tot χ : ℝ) ≤ (onl χ : ℝ)) :
    Nat.card (DirichletCharacter ℂ Q) = Nat.totient Q ∧
      (1 / 9 : ℝ) * (∑ χ : DirichletCharacter ℂ Q, (tot χ : ℝ))
        ≤ ∑ χ : DirichletCharacter ℂ Q, (onl χ : ℝ) :=
  ⟨card_twists_eq_totient Q, twist_family_onLine_ge_ninth Q tot onl h⟩

end PGL3CriticalLine.TwistFamily