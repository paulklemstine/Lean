import Bridges.GameTheory.ZeroKnowledgeProofs
import Bridges.GraphTheory.PCPLocalVerifier
import Cryptography.ZeroKnowledge.Graph3ColoringSimulator
import Cryptography.ZeroKnowledge.QapSnark

/-!
# Zero-Knowledge Verifiable Computation

This file integrates the catalog's abstract proof-system interface, the GMW
3-colouring protocol, the QAP random-point verifier, and the two-query PCP bridge.
It also supplies distributional definitions of perfect interactive and
non-interactive zero knowledge.  The definitions extend the existing
`ZeroKnowledge.InteractiveProof` rather than replacing it.
-/

namespace ZK.VerifiableComputation

/-- A distributional perfect-zero-knowledge layer on an existing interactive
proof system.  `realView` includes the verifier's full transcript, while
`simulator` has access only to the public statement. -/
structure InteractivePerfectZK {S T : Type*} (ip : ZeroKnowledge.InteractiveProof S T)
    (View : Type*) where
  realView : S → PMF View
  simulator : S → PMF View
  perfect_simulation : ∀ s, ip.valid s → realView s = simulator s

/-- A non-interactive proof is an existing proof system whose entire prover
message is represented by one finite proof object.  Besides perfect simulation,
all proof objects in the support of the honest distribution must be accepted. -/
structure NonInteractivePerfectZK {S Proof : Type*} [Fintype Proof]
    (ip : ZeroKnowledge.InteractiveProof S Proof) where
  honestProof : S → PMF Proof
  simulator : S → PMF Proof
  support_accepted : ∀ s, ip.valid s → ∀ p, honestProof s p ≠ 0 → ip.verify s p
  perfect_simulation : ∀ s, ip.valid s → honestProof s = simulator s

/-- Perfect interactive simulation gives equality of the probability of every
individual verifier view. -/
theorem interactive_view_probability_eq {S T View : Type*}
    (ip : ZeroKnowledge.InteractiveProof S T)
    (zk : InteractivePerfectZK ip View) (s : S) (hs : ip.valid s) (v : View) :
    zk.realView s v = zk.simulator s v := by
  rw [zk.perfect_simulation s hs]

/-- Perfect non-interactive zero knowledge gives equality of every proof-point
probability in the real and simulated distributions. -/
theorem nizk_proof_probability_eq {S Proof : Type*} [Fintype Proof]
    (ip : ZeroKnowledge.InteractiveProof S Proof)
    (zk : NonInteractivePerfectZK ip) (s : S) (hs : ip.valid s) (p : Proof) :
    zk.honestProof s p = zk.simulator s p := by
  rw [zk.perfect_simulation s hs]

/-- Any proof sampled with nonzero probability by an honest non-interactive
prover is accepted. -/
theorem nizk_honest_support_is_accepting {S Proof : Type*} [Fintype Proof]
    (ip : ZeroKnowledge.InteractiveProof S Proof)
    (zk : NonInteractivePerfectZK ip) (s : S) (hs : ip.valid s) (p : Proof)
    (hp : zk.honestProof s p ≠ 0) :
    ip.verify s p := by
  exact zk.support_accepted s hs p hp

/-! ## Graph 3-colouring -/

/-- The GMW transcript on a challenged properly-coloured edge is exactly the
witness-independent simulator distribution.  Combined with the completeness and
soundness theorems in `Graph3Coloring`, this is the perfect honest-verifier
zero-knowledge theorem for graph 3-colourability. -/
theorem graph3color_perfect_hvzk (a b : Fin 3) (hab : a ≠ b) :
    ZK.Graph3Coloring.realTranscriptDist a b hab =
      ZK.Graph3Coloring.simulatorDist := by
  exact ZK.Graph3Coloring.perfect_hvzk_dist a b hab

/-- The graph protocol has perfect completeness under every random colour
permutation. -/
theorem graph3color_perfect_completeness {V : Type*}
    (E : Finset (V × V)) (c : V → Fin 3)
    (hc : ZK.Graph3Coloring.IsProperColoring E c)
    (perm : Equiv.Perm (Fin 3)) :
    ZK.Graph3Coloring.IsProperColoring E (fun v => perm (c v)) := by
  exact ZK.Graph3Coloring.completeness E c hc perm

/-! ## Simplified zk-SNARK soundness -/

/-- A false QAP quotient identity can pass the simplified SNARK's random-point
check at no more points than the degree of its discrepancy polynomial. -/
theorem simplified_snark_soundness {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (p h t : Polynomial F) (hne : p ≠ h * t) :
    (Finset.univ.filter fun s : F => p.eval s = (h * t).eval s).card ≤
      (p - h * t).natDegree := by
  exact ZK.QapSnark.qap_soundness_card p h t hne

/-- Passing at more points than the discrepancy degree forces the claimed QAP
identity, the knowledge-soundness form of the simplified SNARK result. -/
theorem simplified_snark_knowledge_soundness {F : Type*}
    [Field F] [Fintype F] [DecidableEq F]
    (p h t : Polynomial F)
    (hpass : (p - h * t).natDegree <
      (Finset.univ.filter fun s : F => p.eval s = (h * t).eval s).card) :
    p = h * t := by
  exact ZK.QapSnark.qap_knowledge_soundness p h t hpass

/-! ## PCP bridge -/

/-- The graph-colouring verifier reads at most two proof symbols, independently
of graph size: the constant-query component of the PCP connection. -/
theorem graph3color_pcp_query_bound {V : Type*} [DecidableEq V] (e : V × V) :
    (Bridges.PCPLocalVerifier.queryPositions e).card ≤ 2 := by
  exact Bridges.PCPLocalVerifier.query_count_le_two e

/-- If the graph is not 3-colourable, every alleged PCP proof is rejected on at
least one local two-symbol query. -/
theorem graph3color_pcp_soundness {V : Type*}
    (E : Finset (V × V)) (c : V → Fin 3)
    (hG : ¬ ∃ c' : V → Fin 3, ZK.Graph3Coloring.IsProperColoring E c') :
    ∃ e ∈ E, ¬ Bridges.PCPLocalVerifier.pcpVerifier c e := by
  exact Bridges.PCPLocalVerifier.pcp_soundness_exists_reject E c hG

end ZK.VerifiableComputation