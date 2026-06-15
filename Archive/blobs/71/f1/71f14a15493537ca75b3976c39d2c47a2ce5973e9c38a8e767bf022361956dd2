# FUTURE DIRECTIONS — Gravity from Information: Spacetime as a Quantum Error-Correcting Code

Research cycle output for the **Bridges** domain. This cycle produced
`Bridges/InformationGravity.lean`, extending the existing `Bridges/HolographicCoding.lean`
skeleton with the quantum-information layer of the holographic dictionary: mutual information,
conditional mutual information / strong subadditivity, quantum Markov chains, holographic monogamy
(MMI), and the Einstein first law `δArea = 4 δS`.

Below are bold, precise, and falsifiable conjectures to drive subsequent cycles. Each is phrased so
that it can be (dis)proved as a Lean theorem about `HolographicCodeProfile` /
`HolographicMMIProfile`.

---

## C1. Markov chains are closed under conditioning-region union (chain rule rigidity)

**Conjecture.** Let `H : HolographicCodeProfile α`. If `(A, B, C)` and `(A, B, C')` are both quantum
Markov chains (`condMutualInfo = 0`) with `C` and `C'` disjoint from `A ∪ B` and from each other,
then `(A, B, C ∪ C')` is a quantum Markov chain.

**Why it matters.** This is the discrete analogue of "gluing flat bulk regions stays flat." A proof
would show the modular (zero-curvature) locus is a sub-lattice; a counterexample would exhibit
emergent curvature from union of flat interfaces. Testable by enumerating small `Finset`-indexed
profiles.

## C2. The chain rule for conditional mutual information

**Conjecture.** For pairwise-disjoint `A, B₁, B₂, C`,
`condMutualInfo H A (B₁ ∪ B₂) C = condMutualInfo H A B₁ C + condMutualInfo H A B₂ (B₁ ∪ C)`.

**Why it matters.** The chain rule `I(A:B₁B₂|C) = I(A:B₁|C) + I(A:B₂|B₁C)` is the backbone of all
recoverability theory. If it holds *identically* in the lattice model (not just under saturation),
then `HolographicCoding` automatically satisfies all SSA-generated entropy inequalities. Falsifiable:
the identity is a `ring`-level statement once the relevant intersections collapse, so any failure
pinpoints a missing disjointness hypothesis.

## C3. MMI is strictly stronger than SSA in the catalog model

**Conjecture.** There exists `H : HolographicCodeProfile α` (some finite `α`) and pairwise-disjoint
`A, B, C` with `tripartiteInfo H A B C > 0`. Equivalently, not every `HolographicCodeProfile`
extends to a `HolographicMMIProfile`.

**Why it matters.** This certifies that the `mmi` axiom of `HolographicMMIProfile` is *non-vacuous
and independent*: holographic states form a strictly smaller cone than SSA-states. A constructive
counterexample (e.g. a 4-element boundary with an explicitly tabulated `S`) settles it. This is the
single most important sanity check on the entropy-cone program.

## C4. Saturation of the Singleton/area bound forces global Markovianity

**Conjecture (sharpening of `HolographicCoding.SaturationModularityConjecture`).** If
`H.S X = (X.card : ℝ)` for every `X` in a laminar family `L`, then for all pairwise-disjoint
`A, B, C` drawn from `L`, `IsMarkov H A B C` holds. I.e. perfect coding efficiency along a
non-crossing geodesic foliation makes the entire bulk flat.

**Why it matters.** Connects the coding-theoretic extremal condition (Singleton-bound saturation)
to the information-geometric flatness condition (vanishing CMI). Decompose via the already-proved
`saturation_conjecture_disjoint_saturated` and `markov_iff_modular`.

## C5. Quantitative recoverability: a Fawzi–Renner-type lower bound

**Conjecture.** Define a "recovery fidelity proxy" `F(A,B,C) := 1 - condMutualInfo H A B C / (2 ⋅ Smax)`
where `Smax` bounds the entropies in play. Then `condMutualInfo H A B C ≤ ε` implies the area defect
`areaDefect H (A∪C) (B∪C) ≤ 4ε`, giving an explicit "approximate Markov ⇒ approximately flat"
stability theorem, with the constant `4` (the RT slope) being sharp.

**Why it matters.** Upgrades the exact `markov_iff_zero_syndrome` bridge to a robust, quantitative
one — the form actually needed for emergent gravity from *approximate* codes. The constant `4` ties
directly to `areaDefect_eq_four_syndromeDefect`; sharpness is a small finite optimization.

---

### Methodological note
All five conjectures are stated over finite `Finset α` and computable rational entropies, so each is
amenable to `decide`/`Finset`-enumeration counterexample search before attempting a full proof. The
recommended attack order is **C2 → C1 → C3 → C4 → C5** (chain rule first, since C1 and C4 likely
reduce to it; C3 is an independent existence/counterexample; C5 is the capstone quantitative result).
