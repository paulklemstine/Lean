import Mathlib
import Cryptography.SchnorrIdentification

/-!
# Knowledge soundness of the Schnorr Σ-protocol (extractor produces a real witness)

The catalog's `special_soundness` shows that two accepting transcripts that share a
commitment but differ in challenge let one recover *the* secret `x` — but it *assumes*
the public key already has the form `P.pk x = x * g`. This file proves the strictly
stronger **knowledge soundness** statement: for an **arbitrary** public key `Y` (no secret
assumed to exist a priori), the extracted value

  `extractWitness = (c₁ - c₂)⁻¹ * (s₁ - s₂)`

is a genuine witness, i.e. `P.pk extractWitness = Y`. Hence two forking transcripts not
merely *determine* a number but *prove existence of a discrete logarithm* of `Y`.

## Main results

* `extractWitness_is_witness` — the extracted value `x*` satisfies `P.pk x* = Y` for any
  `Y`, from two accepting transcripts with `c₁ ≠ c₂`.
* `knowledge_soundness` — existence form: a fork yields `∃ x, P.pk x = Y`.
* `special_soundness_of_knowledge` — recovers the catalog's `special_soundness` as a
  corollary by specialising `Y := P.pk x` and cancelling `g`.

-- !-- Lab Notes -- !--
Hypothesis (KS1): the Schnorr extractor is sound even when no secret is assumed; the two
acceptance equations alone force `(s₁ - s₂) • g = (c₁ - c₂) • Y`, so dividing by the
nonzero scalar `c₁ - c₂` exhibits `Y` as a multiple of `g`.
Experiment: subtract the two acceptance equations, factor out `g`, multiply by the field
inverse `(c₁ - c₂)⁻¹`. Outcome: confirmed; the proof never references a presupposed secret.
Analysis: this separates *soundness* (a valid witness exists) from *correctness of the
named secret* (the catalog lemma). The former is the property actually required by the
Forking Lemma / proof-of-knowledge definition. Critique: ensure `Y` is genuinely arbitrary
(it is: only `h₁, h₂, hc` are used) and that `g ≠ 0` is the sole structural hypothesis.
Synthesis: knowledge soundness ⇒ classical special soundness, the converse needing the
extra `Y = pk x` assumption — so this is a strict generalisation of the catalog result.
-/

namespace SchnorrKS

variable (P : SchnorrParams)

/-- The Schnorr witness extractor applied to two forking transcripts. -/
def extractWitness (c₁ s₁ c₂ s₂ : ZMod P.p) : ZMod P.p :=
  (c₁ - c₂)⁻¹ * (s₁ - s₂)

/-
**Knowledge soundness (extractor correctness).** For an *arbitrary* public key `Y`,
two accepting transcripts `(t, c₁, s₁)`, `(t, c₂, s₂)` sharing the commitment `t` with
`c₁ ≠ c₂` make the extracted value a genuine witness: `P.pk (extractWitness …) = Y`.
-/
theorem extractWitness_is_witness (Y t c₁ s₁ c₂ s₂ : ZMod P.p)
    (h₁ : accepts P Y (t, c₁, s₁))
    (h₂ : accepts P Y (t, c₂, s₂))
    (hc : c₁ ≠ c₂) :
    P.pk (extractWitness P c₁ s₁ c₂ s₂) = Y := by
  have h_inv : (c₁ - c₂)⁻¹ * (c₁ - c₂) = 1 := by
    haveI := Fact.mk P.hp.1; exact inv_mul_cancel₀ ( sub_ne_zero.mpr hc ) ;
  unfold extractWitness; simp_all +decide [accepts]
  unfold SchnorrParams.pk; linear_combination' h_inv * Y + h₁ * (c₁ - c₂)⁻¹ - h₂ * (c₁ - c₂)⁻¹

/-- **Knowledge soundness (existence form).** A fork at a fixed commitment proves that the
public key `Y` has a discrete logarithm. -/
theorem knowledge_soundness (Y t c₁ s₁ c₂ s₂ : ZMod P.p)
    (h₁ : accepts P Y (t, c₁, s₁))
    (h₂ : accepts P Y (t, c₂, s₂))
    (hc : c₁ ≠ c₂) :
    ∃ x, P.pk x = Y :=
  ⟨extractWitness P c₁ s₁ c₂ s₂, extractWitness_is_witness P Y t c₁ s₁ c₂ s₂ h₁ h₂ hc⟩

/-
The catalog's `special_soundness` recovered as a corollary: specialising `Y := P.pk x`
and cancelling the generator `g` shows the named secret equals the extracted value.
-/
theorem special_soundness_of_knowledge (x t c₁ s₁ c₂ s₂ : ZMod P.p)
    (h₁ : accepts P (P.pk x) (t, c₁, s₁))
    (h₂ : accepts P (P.pk x) (t, c₂, s₂))
    (hc : c₁ ≠ c₂) :
    x = extractWitness P c₁ s₁ c₂ s₂ := by
  exact special_soundness P x t c₁ s₁ c₂ s₂ h₁ h₂ hc

end SchnorrKS