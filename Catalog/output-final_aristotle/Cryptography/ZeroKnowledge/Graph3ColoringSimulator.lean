import Mathlib
import Cryptography.ZeroKnowledge.Graph3Coloring

/-!
# The Simulation Paradigm for the GMW Graph 3-Colouring Proof

This file formalizes the **simulation paradigm** for the Goldreich–Micali–Wigderson
zero-knowledge proof of graph 3-colourability, building directly on
`Cryptography.ZeroKnowledge.Graph3Coloring`.

The zero-knowledge property is expressed as an *equality of probability
distributions* (`PMF`): the distribution of the verifier's real transcript on a
challenged edge is **exactly equal** to the distribution produced by an efficient
simulator that knows nothing about the prover's secret colouring. Because the two
distributions are literally equal (not merely statistically close), this is
*perfect* honest-verifier zero knowledge.

## The two distributions

* `realTranscriptDist a b hab` — the honest prover holds a proper colouring; on a
  challenged edge with (distinct) endpoint colours `a ≠ b`, it samples a uniformly
  random colour permutation `π ∈ S₃` and opens `(π a, π b)`. This is the pushforward
  of the uniform distribution on `S₃` under the view map.
* `simulatorDist` — the simulator samples a uniformly random *distinct ordered
  pair* of colours, with no reference to any colouring.

## Main results

* `map_uniformOfFintype_of_bijective` — a reusable lemma: the pushforward of a
  uniform distribution under a bijection is again uniform.
* `perfect_hvzk_dist` — **the simulation theorem**: `realTranscriptDist a b hab =
  simulatorDist`. The real transcript and the simulated transcript are identically
  distributed.
* `hvzk_colour_independence` — the real transcript distribution does not depend on
  the actual endpoint colours `(a, b)` at all (only that they are distinct): any
  two challenged edges induce the same distribution. This is the operational
  content of "the verifier learns nothing".
* `perfect_hvzk_apply` — the closed-form probability: every distinct opened pair
  appears with probability exactly `1/6`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The GMW 3-colouring protocol is not merely
"simulatable up to negligible error" but *perfectly* simulatable: the real and
simulated transcript distributions are equal as `PMF`s, because the view map
`π ↦ (π a, π b)` is a bijection from `S₃` onto the six distinct ordered pairs.

Experiment (Experimenter): Formalized both distributions as `PMF`. The proof
reduces perfect ZK to the reusable lemma `map_uniformOfFintype_of_bijective`
(pushforward of uniform under a bijection is uniform), instantiated at the
bijection `hvzk_bijection` already proved in `Graph3Coloring`. Colour-independence
then follows purely formally by transitivity through `simulatorDist`.

Analysis (Analyst): The distributional formulation is strictly stronger than the
bijection lemma alone: it upgrades a combinatorial bijection into a statement
about randomized transcripts, which is the actual definition of zero knowledge.
The colour-independence corollary is the crispest possible statement that the
transcript "leaks nothing" — the *same* random variable is produced regardless of
the secret. The "true but hard" boundary avoided here is full malicious-verifier
ZK (needs rewinding); for the honest verifier, perfect equality is attainable and
proved.

Critique (Critic): `perfect_hvzk_dist` is non-vacuous — it genuinely transports a
bijection through `PMF.map` and `tsum`, not a `decide`. The `Nonempty` instance on
distinct pairs is discharged by an explicit witness `(0,1)`, so the simulator
distribution is well-defined. `perfect_hvzk_apply` gives a concrete `1/6`, ruling
out a trivial reading.

Synthesis (PI): Together with completeness and the soundness gap from
`Graph3Coloring`, this file closes the simulation paradigm: a colouring-oblivious
simulator reproduces the honest transcript distribution exactly.
-- !-- Lab Notes -- !--
-/

namespace ZK.Graph3Coloring

open scoped Classical

/-- The type of ordered pairs of *distinct* colours — the support of an opened
transcript. -/
abbrev DistinctPair := {p : Fin 3 × Fin 3 // p.1 ≠ p.2}

instance : Nonempty DistinctPair := ⟨⟨(0, 1), by decide⟩⟩

/-- **Reusable lemma.** The pushforward of a uniform distribution over a finite
type under a bijection is the uniform distribution over the target. -/
theorem map_uniformOfFintype_of_bijective
    {α β : Type*} [Fintype α] [Nonempty α] [Fintype β] [Nonempty β]
    (f : α → β) (hf : Function.Bijective f) :
    PMF.map f (PMF.uniformOfFintype α) = PMF.uniformOfFintype β := by
  ext b
  rw [PMF.map_apply, PMF.uniformOfFintype_apply]
  obtain ⟨a, rfl⟩ := hf.surjective b
  rw [tsum_eq_single a]
  · simp [PMF.uniformOfFintype_apply, Fintype.card_congr (Equiv.ofBijective f hf)]
  · intro a' ha'
    have : f a ≠ f a' := fun h => ha' (hf.injective h.symm ▸ rfl)
    simp [this]

/-- The **real transcript distribution**: sample a uniform colour permutation
`π ∈ S₃` and open the pair `(π a, π b)` on a challenged edge whose (distinct)
endpoint colours are `a ≠ b`. -/
noncomputable def realTranscriptDist (a b : Fin 3) (hab : a ≠ b) : PMF DistinctPair :=
  PMF.map
    (fun π : Equiv.Perm (Fin 3) =>
      (⟨revealedView a b π, revealedView_distinct a b hab π⟩ : DistinctPair))
    (PMF.uniformOfFintype (Equiv.Perm (Fin 3)))

/-- The **simulator's transcript distribution**: a uniformly random distinct
ordered pair of colours, chosen with no knowledge of the prover's colouring. -/
noncomputable def simulatorDist : PMF DistinctPair :=
  PMF.uniformOfFintype DistinctPair

/-- **The simulation theorem (perfect honest-verifier zero knowledge).** The real
transcript distribution on any challenged edge equals the colouring-oblivious
simulator's distribution. -/
theorem perfect_hvzk_dist (a b : Fin 3) (hab : a ≠ b) :
    realTranscriptDist a b hab = simulatorDist := by
  unfold realTranscriptDist simulatorDist
  exact map_uniformOfFintype_of_bijective _ (hvzk_bijection a b hab)

/-- **Colour-independence of the transcript.** The real transcript distribution is
the *same* for any two challenged edges with distinct endpoint colours — it does
not depend on the actual colours. This is the operational statement that the
verifier's view leaks nothing about the secret colouring. -/
theorem hvzk_colour_independence (a b a' b' : Fin 3) (hab : a ≠ b) (hab' : a' ≠ b') :
    realTranscriptDist a b hab = realTranscriptDist a' b' hab' := by
  rw [perfect_hvzk_dist, perfect_hvzk_dist]

/-- **Closed-form transcript probability.** Every distinct opened pair appears in
the (real = simulated) transcript with probability exactly `1/6`. -/
theorem perfect_hvzk_apply (a b : Fin 3) (hab : a ≠ b) (p : DistinctPair) :
    realTranscriptDist a b hab p = (1 : ENNReal) / 6 := by
  rw [perfect_hvzk_dist]
  unfold simulatorDist
  rw [PMF.uniformOfFintype_apply]
  norm_num [Fintype.card_subtype, show (Finset.univ.filter (fun p : Fin 3 × Fin 3 => p.1 ≠ p.2)).card = 6 from by decide]

end ZK.Graph3Coloring