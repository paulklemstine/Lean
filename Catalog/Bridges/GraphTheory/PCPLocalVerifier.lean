import Mathlib
import Cryptography.ZeroKnowledge.Graph3Coloring

/-!
# The two-query local verifier of the graph 3-colouring PCP

`Cryptography.ZeroKnowledge.VerifiableComputation` refers to this module for the
constant-query component of the PCP connection, but the module itself was
missing from the catalog, which broke the build of the whole `ZeroKnowledge`
subtree.  It is supplied here, with the two facts that file uses:

* `query_count_le_two` — the verifier reads at most two symbols of the alleged
  proof, independently of the size of the graph;
* `pcp_soundness_exists_reject` — if the graph is not 3-colourable then every
  alleged proof (i.e. every colouring) is rejected on at least one edge.

The predicate `pcpVerifier` is the local acceptance test, so a proof is accepted
on every edge exactly when it is a proper colouring in the sense of
`ZK.Graph3Coloring.IsProperColoring`.
-/

namespace Bridges.PCPLocalVerifier

variable {V : Type*}

/-- The positions of the alleged proof that the verifier reads when it
challenges the edge `e`: the two endpoints. -/
def queryPositions [DecidableEq V] (e : V × V) : Finset V := {e.1, e.2}

/-- **Constant query complexity.**  The verifier reads at most two symbols. -/
theorem query_count_le_two [DecidableEq V] (e : V × V) :
    (queryPositions e).card ≤ 2 := by
  simpa [queryPositions] using Finset.card_insert_le e.1 {e.2}

/-- The local acceptance test on the edge `e`. -/
def pcpVerifier (c : V → Fin 3) (e : V × V) : Prop := c e.1 ≠ c e.2

/-- A proof is accepted on every edge exactly when it is a proper colouring. -/
theorem pcpVerifier_all_iff (E : Finset (V × V)) (c : V → Fin 3) :
    (∀ e ∈ E, pcpVerifier c e) ↔ ZK.Graph3Coloring.IsProperColoring E c :=
  Iff.rfl

/-- **Soundness.**  If the graph is not 3-colourable, then for every alleged
proof there is an edge on which the two-query verifier rejects. -/
theorem pcp_soundness_exists_reject (E : Finset (V × V)) (c : V → Fin 3)
    (hG : ¬ ∃ c' : V → Fin 3, ZK.Graph3Coloring.IsProperColoring E c') :
    ∃ e ∈ E, ¬ pcpVerifier c e := by
  by_contra hcon
  push_neg at hcon
  refine hG ⟨c, ?_⟩
  intro e he
  have := hcon e he
  simpa [pcpVerifier] using this

end Bridges.PCPLocalVerifier