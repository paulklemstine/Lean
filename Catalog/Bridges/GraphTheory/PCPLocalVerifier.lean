import Mathlib
import Cryptography.ZeroKnowledge.Graph3Coloring

/-!
# Bridge: 3-Colourability as a Constant-Query (PCP-style) Local Verifier

The PCP theorem asserts `NP ⊆ PCP(poly, O(1))`: every NP language has a proof
checkable by a randomized verifier that reads only a **constant** number of proof
symbols. This file makes the *constant-query local-verifiability* content of that
statement concrete and fully formal on the NP-complete problem of **graph
3-colourability**, reusing the zero-knowledge protocol of
`Cryptography/ZeroKnowledge/Graph3Coloring.lean`.

We model a PCP-style proof as a colouring `c : V → Fin 3` (a proof string indexed
by the vertices, over the constant-size alphabet `Fin 3`). The verifier's
randomness is a single edge `e : V × V`; it queries exactly the two endpoint
symbols `c e.1, c e.2` and accepts iff they differ.

## Main results

* `query_count_le_two` — the verifier reads at most **2** proof symbols per run,
  independent of the instance size `|V|`. This is the `O(1)` query complexity.
* `pcp_accepts_all_iff_proper` — the verifier accepts on *every* random edge iff
  the proof is a proper 3-colouring (the local checks characterise the global
  NP-witness property).
* `pcp_perfect_completeness` — for any proper colouring, the honest prover's
  randomized (colour-permuted) proof is accepted on every edge: **perfect
  completeness**.
* `pcp_soundness_exists_reject` / `pcp_soundness_gap` — if the graph is **not**
  3-colourable, then *every* proof is rejected on at least one edge, so the
  verifier rejects with probability `≥ 1/|E|`: a nonzero **soundness gap** from
  only two queries.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The GMW 3-colouring sigma protocol is *already* a
2-query PCP-style verifier; the only thing separating it from a textbook PCP is
gap amplification (constant rejection probability), which is exactly what the full
PCP theorem supplies on top of constant-query local checkability.

Experiment (Experimenter): Reused `ZK.Graph3Coloring.IsProperColoring`,
`completeness`, `soundness_exists_catch`, and `soundness_prob`. Proved the query
bound via `Finset.card_insert_le` and the bridge identity by definitional unfolding.

Analysis (Analyst): The constant-query and perfect-completeness aspects are
*exactly* captured. The soundness *gap* obtained here (`1/|E|`) is the raw,
un-amplified gap; the deep content of the PCP theorem is amplifying `1/|E|` to a
universal constant for all NP. That amplification (and `NP`-hardness of the gap
problem) is the "true but hard" part deliberately not formalized here.

Critique (Critic): `pcp_accepts_all_iff_proper` is a definitional bridge (honestly
flagged); the load-bearing theorems (`query_count_le_two`, completeness via an
arbitrary permutation, and the soundness gap with `by_contra`-style use of
non-3-colourability) are non-trivial and reuse a separate catalog file.

Synthesis (PI): 3-colourability — an NP-complete problem — is verifiable by a
2-query (`O(1)`) local verifier with perfect completeness and a `1/|E|` soundness
gap, instantiating the constant-query backbone of `NP ⊆ PCP(poly, O(1))`.
-- !-- Lab Notes -- !--
-/

namespace Bridges.PCPLocalVerifier

open Finset ZK.Graph3Coloring

variable {V : Type*}

/-- The PCP-style local verifier on proof `c` and random edge `e`: it accepts iff
the two queried endpoint colours differ. -/
def pcpVerifier (c : V → Fin 3) (e : V × V) : Prop := c e.1 ≠ c e.2

/-- The set of proof positions the verifier queries on randomness `e`: the two
endpoints of the challenged edge. -/
def queryPositions [DecidableEq V] (e : V × V) : Finset V := {e.1, e.2}

/-- **Constant query complexity.** The verifier reads at most two proof symbols
on any random edge, independent of the number of vertices `|V|`. This is the
`O(1)` in `PCP(poly, O(1))`. -/
theorem query_count_le_two [DecidableEq V] (e : V × V) : (queryPositions e).card ≤ 2 := by
  unfold queryPositions
  calc (({e.1, e.2} : Finset V)).card
      ≤ ({e.2} : Finset V).card + 1 := Finset.card_insert_le _ _
    _ = 2 := by simp

/-- **Bridge identity.** The verifier accepts on *every* random edge iff the proof
is a proper 3-colouring. (Definitional: the local two-query checks, ranging over
all edges, are exactly the global NP-witness predicate.) -/
theorem pcp_accepts_all_iff_proper (E : Finset (V × V)) (c : V → Fin 3) :
    (∀ e ∈ E, pcpVerifier c e) ↔ IsProperColoring E c := Iff.rfl

/-- **Perfect completeness.** Given a proper colouring `c`, the honest prover's
randomized proof `π ∘ c` (for any colour permutation `π`) is accepted by the
verifier on every edge. -/
theorem pcp_perfect_completeness (E : Finset (V × V)) (c : V → Fin 3)
    (hc : IsProperColoring E c) (π : Equiv.Perm (Fin 3)) :
    ∀ e ∈ E, pcpVerifier (fun v => π (c v)) e :=
  (pcp_accepts_all_iff_proper E _).mpr (completeness E c hc π)

/-- **Soundness (existence of a rejecting query).** If the graph is not
3-colourable, then for *every* proof `c` there is an edge on which the verifier
rejects (the two endpoints get the same colour). -/
theorem pcp_soundness_exists_reject (E : Finset (V × V)) (c : V → Fin 3)
    (hG : ¬ ∃ c' : V → Fin 3, IsProperColoring E c') :
    ∃ e ∈ E, ¬ pcpVerifier c e := by
  have hc : ¬ IsProperColoring E c := fun h => hG ⟨c, h⟩
  obtain ⟨e, heE, hee⟩ := soundness_exists_catch E c hc
  exact ⟨e, heE, by simp [pcpVerifier, hee]⟩

/-- **Soundness gap.** If the graph is not 3-colourable, then against any proof the
verifier rejects with probability at least `1/|E|` over a uniformly random edge:
the fraction of rejecting edges (those `e` with `c e.1 = c e.2`, i.e.
`¬ pcpVerifier c e`) is `≥ 1/|E|`. -/
theorem pcp_soundness_gap (E : Finset (V × V)) (c : V → Fin 3)
    (hE : 0 < E.card)
    (hG : ¬ ∃ c' : V → Fin 3, IsProperColoring E c') :
    (1 : ℚ) / E.card ≤
      ((E.filter (fun e => c e.1 = c e.2)).card : ℚ) / E.card := by
  have hc : ¬ IsProperColoring E c := fun h => hG ⟨c, h⟩
  exact soundness_prob E c hE hc

end Bridges.PCPLocalVerifier