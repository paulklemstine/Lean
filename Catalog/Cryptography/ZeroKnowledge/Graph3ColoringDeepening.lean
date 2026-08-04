import Cryptography.ZeroKnowledge.Graph3ColoringSimulator

/-!
# Repetition and observational privacy for the graph 3-colouring protocol

This file develops two consequences of the one-round protocol:

* soundness amplification for independent repeated edge challenges; and
* perfect privacy against every deterministic transcript distinguisher.

The probability model for soundness is the exact rational fraction of edges on
which a fixed committed colouring is accepted.  The privacy model uses the PMF
transcript distributions from `Graph3ColoringSimulator`.
-/

namespace ZK.Graph3Coloring

open Finset
open scoped Classical

variable {V : Type*}

/-- The exact one-round acceptance probability for a fixed committed colouring,
when the verifier samples uniformly from the edge set. -/
def acceptanceProbability (E : Finset (V × V)) (c' : V → Fin 3) : ℚ :=
  ((E.filter (fun e => c' e.1 ≠ c' e.2)).card : ℚ) / E.card

/-- The exact one-round rejection probability for a fixed committed colouring. -/
def rejectionProbability (E : Finset (V × V)) (c' : V → Fin 3) : ℚ :=
  ((E.filter (fun e => c' e.1 = c' e.2)).card : ℚ) / E.card

/-- Acceptance and rejection partition the edge challenges. -/
theorem acceptance_add_rejection (E : Finset (V × V)) (c' : V → Fin 3)
    (hE : 0 < E.card) :
    acceptanceProbability E c' + rejectionProbability E c' = 1 := by
  unfold acceptanceProbability rejectionProbability
  have hcard := Finset.card_filter_add_card_filter_not
    (s := E) (fun e => c' e.1 ≠ c' e.2)
  simp only [not_ne_iff] at hcard
  have hcardQ :
      ((E.filter (fun e => c' e.1 ≠ c' e.2)).card : ℚ) +
        (E.filter (fun e => c' e.1 = c' e.2)).card = E.card := by
    exact_mod_cast hcard
  have hne : (E.card : ℚ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hE)
  field_simp
  exact hcardQ

/-- **Perfect completeness as a probability statement.** A proper commitment is
accepted on every edge, hence with probability one. -/
theorem honest_acceptance_eq_one (E : Finset (V × V)) (c : V → Fin 3)
    (hE : 0 < E.card) (hc : IsProperColoring E c) :
    acceptanceProbability E c = 1 := by
  unfold acceptanceProbability
  have hall : E.filter (fun e => c e.1 ≠ c e.2) = E := by
    ext e
    simp only [mem_filter]
    constructor
    · exact fun h => h.1
    · intro he
      exact ⟨he, hc e he⟩
  rw [hall]
  have hne : (E.card : ℚ) ≠ 0 := by exact_mod_cast (Nat.ne_of_gt hE)
  exact div_self hne

/-- **One-round soundness.** Every improper commitment is accepted with
probability at most `1 - 1 / |E|`. -/
theorem one_round_acceptance_bound (E : Finset (V × V)) (c' : V → Fin 3)
    (hE : 0 < E.card) (hbad : ¬ IsProperColoring E c') :
    acceptanceProbability E c' ≤ 1 - (1 : ℚ) / E.card := by
  have hsum := acceptance_add_rejection E c' hE
  have hrejection : (1 : ℚ) / E.card ≤ rejectionProbability E c' := by
    exact soundness_prob E c' hE hbad
  linarith

/-- **Repeated soundness amplification.** If `k` edge challenges are sampled
independently, the probability that a fixed improper commitment passes every
round is at most `(1 - 1 / |E|)^k`. -/
theorem repeated_acceptance_bound (E : Finset (V × V)) (c' : V → Fin 3)
    (hE : 0 < E.card) (hbad : ¬ IsProperColoring E c') (k : ℕ) :
    (acceptanceProbability E c') ^ k ≤ (1 - (1 : ℚ) / E.card) ^ k := by
  apply pow_le_pow_left₀
  · unfold acceptanceProbability
    positivity
  · exact one_round_acceptance_bound E c' hE hbad

/-- The transcript distribution on a concrete challenged edge of a properly
3-coloured graph. -/
noncomputable def edgeTranscriptDist (E : Finset (V × V)) (c : V → Fin 3)
    (hc : IsProperColoring E c) (e : V × V) (he : e ∈ E) : PMF DistinctPair :=
  realTranscriptDist (c e.1) (c e.2) (hc e he)

/-- A deterministic observer's probability of returning `true` on a transcript. -/
noncomputable def distinguisherAcceptance
    (μ : PMF DistinctPair) (D : DistinctPair → Bool) : ENNReal :=
  ∑' p, if D p then μ p else 0

/-- **Perfect observational zero knowledge.** No deterministic distinguisher can
have any advantage in telling a real transcript on a graph edge from the
colouring-oblivious simulator's transcript. -/
theorem perfect_hvzk_distinguisher (E : Finset (V × V)) (c : V → Fin 3)
    (hc : IsProperColoring E c) (e : V × V) (he : e ∈ E)
    (D : DistinctPair → Bool) :
    distinguisherAcceptance (edgeTranscriptDist E c hc e he) D =
      distinguisherAcceptance simulatorDist D := by
  have hdist : edgeTranscriptDist E c hc e he = simulatorDist := by
    unfold edgeTranscriptDist
    exact perfect_hvzk_dist _ _ (hc e he)
  rw [hdist]

/-- Both one-sided distinguishing advantages are exactly zero. -/
theorem perfect_hvzk_zero_advantage (E : Finset (V × V)) (c : V → Fin 3)
    (hc : IsProperColoring E c) (e : V × V) (he : e ∈ E)
    (D : DistinctPair → Bool) :
    distinguisherAcceptance (edgeTranscriptDist E c hc e he) D -
        distinguisherAcceptance simulatorDist D = 0 ∧
      distinguisherAcceptance simulatorDist D -
        distinguisherAcceptance (edgeTranscriptDist E c hc e he) D = 0 := by
  rw [perfect_hvzk_distinguisher E c hc e he D]
  simp

/-- Real edge transcripts are independent of both the proper colouring and the
challenged edge: any two valid protocol instances induce exactly the same PMF. -/
theorem edge_transcript_colour_independence
    (E₁ : Finset (V × V)) (c₁ : V → Fin 3) (hc₁ : IsProperColoring E₁ c₁)
    (e₁ : V × V) (he₁ : e₁ ∈ E₁)
    (E₂ : Finset (V × V)) (c₂ : V → Fin 3) (hc₂ : IsProperColoring E₂ c₂)
    (e₂ : V × V) (he₂ : e₂ ∈ E₂) :
    edgeTranscriptDist E₁ c₁ hc₁ e₁ he₁ =
      edgeTranscriptDist E₂ c₂ hc₂ e₂ he₂ := by
  unfold edgeTranscriptDist
  exact hvzk_colour_independence _ _ _ _ (hc₁ e₁ he₁) (hc₂ e₂ he₂)

/-- The real transcript is uniform: every valid opened colour pair occurs with
probability exactly `1/6`, on every properly coloured challenged edge. -/
theorem edge_transcript_apply (E : Finset (V × V)) (c : V → Fin 3)
    (hc : IsProperColoring E c) (e : V × V) (he : e ∈ E) (p : DistinctPair) :
    edgeTranscriptDist E c hc e he p = (1 : ENNReal) / 6 := by
  unfold edgeTranscriptDist
  exact perfect_hvzk_apply _ _ (hc e he) p

end ZK.Graph3Coloring