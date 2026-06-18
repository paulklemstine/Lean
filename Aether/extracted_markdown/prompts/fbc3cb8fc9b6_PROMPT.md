Repair and complete the intended proof-complexity density theorem as a focused Lean 4 formalization task.

Target file: Catalog/Logic/ProofComplexity/LadderDensity.lean

Mathematical goal:
For each integer k >= 1, define an explicit simulation system interPowSys k whose degree lies strictly between the adjacent ladder systems powSystem k and powSystem (k+1). Prove a theorem of the form
  exists_strictly_between_powSystem : forall k >= 1, ∃ S, degree (powSystem k) < degree S ∧ degree S < degree (powSystem (k+1))
by taking S = interPowSys k.

Required focus:
1. Stay entirely within the existing proof-complexity / simulation-degree framework already developed in the catalog.
2. Do not introduce unrelated domains or speculative abstractions.
3. Produce a single self-contained Lean file with complete proofs and no sorry.

Recommended construction:
Define interPowSys k explicitly using a piecewise size function that alternates between the lower growth rate and the upper growth rate on two infinite classes of inputs. The preferred witness is parity-gluing:
- on even n, use the upper growth 2 ^ (n ^ (k+1))
- on odd n, use the lower growth 2 ^ (n ^ k)
wrapped into the existing system constructor used for powSystem.
If this exact definition creates avoidable technical friction, you may switch to any equally explicit two-subsequence witness (for example, values on n = 2m and n = 2m+1, or another fixed arithmetic progression split) as long as it is definable in Lean and still proves strict intermediate degree.

Proof strategy constraints:
- Build on the catalog’s existing characterization of simulation between size-based systems, especially any iff lemmas reducing simulation to eventual domination of size functions.
- Prove the four comparison components separately:
  a) powSystem k ≤ interPowSys k
  b) not (interPowSys k ≤ powSystem k)
  c) interPowSys k ≤ powSystem (k+1)
  d) not (powSystem (k+1) ≤ interPowSys k)
- The non-simulation directions should use infinitely many witnesses of a chosen parity/arithmetic progression where the faster/slower branch forces failure of eventual domination.
- If needed, first establish helper lemmas giving eventual inequalities for powers/exponentials under substitution n ↦ 2n or n ↦ 2n+1.
- Prefer simple explicit arithmetic lemmas over over-general asymptotic machinery.

Engineering guidance:
- Keep theorem statements concrete and falsifiable.
- Reuse existing names and structures from the catalog instead of redefining the degree framework.
- Add local helper lemmas if the imported gap lemmas are not parity-aware enough.
- If strict degree notation is already defined in DegreeLattice, use it directly; otherwise prove the corresponding pair of preorder and non-converse statements in the catalog’s native language.

Deliverable standard:
A finished Lean file that compiles, with clear theorem names and comments explaining the witness and the two strictness arguments. The result should be a genuine completion of the ladder-density theorem, not a partial sketch.