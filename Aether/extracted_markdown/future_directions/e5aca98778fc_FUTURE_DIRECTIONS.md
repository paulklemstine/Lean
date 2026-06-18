# Future Directions: Proof Phase Transitions II

## Synthesis

The catalog file `Catalog/Logic/ProofPhaseTransitions.lean` set up *derivability in an
implicational theory* as reflexive–transitive closure of the axiom relation, and singled out
the **barrier / invariant-cut lemma** (`refl_trans_gen_closed`) as the universal certificate
for *non*-derivability, with the linear chain `chainT` as the minimal-density extremal case.

`Catalog/Logic/ProofPhaseTransitionsCompleteness.lean` closes that loop. The barrier lemma
was only the *soundness* half of a duality. We prove its converse — the conclusion-set of a
fixed source is itself axiom-closed — and obtain:

* **`derivable_iff_forall_closed`**: soundness *and* completeness of the barrier method —
  `a` derives `b` iff `b` lies in every axiom-closed set containing `a`. Derivability is the
  *least* closed set over the source.
* **`not_derivable_iff_exists_barrier`**: every non-derivability has an explicit closed
  barrier separating source from target (an LP-duality / Menger-flavoured completeness).
* **`Cl` + `subset_cl`/`cl_mono`/`cl_idem`**: derivability is a Kuratowski closure operator;
  idempotence *is* transitivity of derivation.
* **`chainSeg` + `chain_derivable_iff` + `instDecidableDerivableChainT`**: a constructive,
  source-general derivation witness, with chain-theory derivability decidable under `decide`.

The unifying observation: *the conclusion-set of a source is closed*. That one fact powers
both completeness of the barrier method and idempotence of the closure operator, so
potential-function / invariant-cut arguments lose no information.

## Results Summary

8 new theorems/instances, `sorry`-free, only standard axioms (`propext`, `Classical.choice`,
`Quot.sound`; the duality theorem uses none). Self-contained over Mathlib, mirroring the
catalog definitions in namespace `ProofPhaseTransitionsII` and citing the catalog lemmas
in the proof sketches.

## Research Directions

### 1. Finite barriers and a compactness theorem for non-derivability

We proved non-derivability is certified by *some* closed barrier set, but that set can be
infinite (e.g. an upward cut in `ℕ`). Conjecture: for locally finite theories (every atom
has finitely many out-axioms), if `a` does not derive `b` then there is a *finite* closed
barrier separating them, computable from the reachable set. **The key insight is** that the
reachable set from `a` is the minimal closed barrier whenever `b` is unreachable, and local
finiteness makes its frontier finite, turning the semantic certificate into a finite witness.
**Why now?** `not_derivable_iff_exists_barrier` already hands us the abstract certificate;
the only missing ingredient is a finiteness refinement, which `Set.Finite`/`Mathlib`'s
reachable-set API supports directly.

### 2. Sharp proof-length thresholds via the Cl operator

Define `derivLen T a b` as the minimal number of axiom steps deriving `b` from `a`, and study
it as a graded version of `Cl`. Conjecture: for the chain theory `derivLen chainT a b = b - a`
exactly (matching `chainSeg_length`), and for a random Erdős–Rényi axiom set on `n` atoms with
edge probability `p`, the typical `derivLen` between a derivable pair undergoes a sharp jump
from `Θ(log n)` to `∞` as `p` crosses `1/n`. **The key insight is** that `chainSeg` already
realises the *exact* minimal length on the extremal chain, so the closure operator can be
refined to a metric (`Cl`-with-radius), and Friedgut sharp-threshold monotonicity (catalog
`derivable_monotone`) applies to each radius level set. **Why now?** Monotonicity and the
constructive optimal witness are both in hand; only the graded `Cl` and a length lower bound
remain.

### 3. Critical-axiom spectra beyond the chain

The catalog proved every chain axiom is critical (deleting it breaks the derivation).
Conjecture: for a general theory, the set of axioms critical to deriving `b` from `a` is
exactly the set of edges lying on *every* minimal closed barrier's frontier — a min-cut /
max-flow duality — and its size (the "criticality index") equals the edge-connectivity from
`a` to `b` in the axiom digraph. **The key insight is** that `not_derivable_iff_exists_barrier`
identifies barriers with cuts, so Menger's theorem should turn axiom-criticality into a flow
quantity. **Why now?** Mathlib has graph connectivity infrastructure, and our barrier-as-cut
completeness theorem is the precise bridge from logical criticality to combinatorial cuts.

### 4. Closure-operator lattice and Horn-theory Galois connection

`Cl` is a Kuratowski closure operator, hence its closed sets form a complete lattice.
Conjecture: the map `theory ↦ Cl-closed-sets` and `family-of-sets ↦ implied-axioms` form a
Galois connection whose fixed points are exactly the Horn theories closed under consequence,
recovering the algebraic closure-system view of propositional Horn logic. **The key insight
is** that `cl_idem` + `cl_mono` already make `Cl` a genuine closure operator, so the closed
sets are automatically a Moore family / complete lattice — the connection to Horn semantics
is then a packaging step. **Why now?** With idempotence proven, the lattice structure is
free, and Mathlib's `ClosureOperator` / `GaloisConnection` classes can absorb the result
directly.

### 5. Decidability transfer across theory morphisms

`instDecidableDerivableChainT` makes chain derivability computable. Conjecture: derivability
is decidable for any theory that admits a *monotone potential* `φ : α → ℕ` strictly increasing
along axioms with finite fibers — the potential bounds search depth, generalising the chain's
`φ = id`. **The key insight is** that the chain decidability came from the barrier cut
`{k | a ≤ k}`, which is exactly a sublevel set of the potential `id`; any such potential gives
a finite, decidable reachable set. **Why now?** The barrier-completeness theorem tells us the
potential cut is *complete* (not just sound), so a decision procedure built from it cannot
miss a derivation — the soundness/completeness pairing is precisely what certifies the
algorithm.
