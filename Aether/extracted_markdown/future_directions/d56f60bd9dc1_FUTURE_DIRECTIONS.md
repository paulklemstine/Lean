# Future Directions: Closure Probe Minimization and Set-Cover Reconstruction

The file `Catalog/Bridges/ClosureProbeReconstruction.lean` builds a probe-signature
layer on top of the catalog's closure reconstruction infrastructure
(`Bridges/AlgebraEMLReconstruction.lean`). It proves that a probe family
separating the closed sets makes the signature map injective
(`signature_injOn_closed`, `separatesClosed_iff_injOn`), that closure is
reconstructable as an intersection of probe-consistent closed sets
(`closure_eq_sInter_probeConsistent`, recasting the catalog's
`closure_eq_sInf_closed_eq`), that irredundant separating families are exactly
those where every probe carries a witness pair (`irredundant_iff_witness`,
`irredundantSeparating_iff`), and that any finite separating family contains a
minimal certificate (`exists_irredundant_subfamily`). The boundary theorem
`signature_not_injOn_of_empty` shows separation cannot be dropped. The following
directions extend this frontier.

## 1. Cardinality lower bounds for separating probe families

Conjecture: for a finite closure system with `n` closed sets, every separating
probe family has at least `⌈log₂ n⌉` probes when probes are Boolean, and this
bound is tight for the discrete (powerset) closure. This is the closure-system
analogue of the information-theoretic identification bound, connecting the
`signature` map to a binary search certificate.

The key insight is that an injective Boolean signature map on the closed-set
lattice is exactly an injective code into `{0,1}^P`, so `|P| ≥ log₂(#closed)` is
forced by counting, while a balanced separating family achieves it. Why now? The
injectivity backbone is already proved in `signature_injOn_closed` and
`separatesClosed_iff_injOn`, so the remaining work is a pure counting argument
over `Fintype` closed sets — directly testable by exhibiting the discrete-closure
extremal example as a `decide`-checkable finite case.

## 2. Uniqueness of the minimal certificate (matroid structure)

Conjecture: the irredundant separating subfamilies of a fixed finite probe family
all have the same cardinality if and only if the witness-pair incidence relation
forms a matroid; in general they need not, and the gap is governed by the witness
hypergraph. This refines `exists_irredundant_subfamily` from existence to a
structural classification.

The key insight is that `irredundant_iff_witness` turns minimality into a
covering condition on witness pairs, so equicardinality of all minimal certificates
is precisely the basis-exchange property of the associated set system. Why now?
`WitnessPair` and `irredundant_iff_witness` already isolate the per-probe
certificate, so one can connect to Mathlib's `Matroid` API and test the conjecture
on the catalog's `ClosureMatroidSecretSharing.lean` examples for a cross-domain
bridge.

## 3. Weakest probe axiom for exact (non-intersection) reconstruction

Conjecture: there is a strictly weaker hypothesis than full membership-probe
completeness — namely "closure-stability plus point-separation of the
closure-generating points" — under which `cl S` equals the *unique* closed set
whose signature dominates that of `S`, eliminating the intersection in
`closure_eq_sInter_probeConsistent`.

The key insight is that the intersection in the reconstruction formula collapses
to a single set exactly when probe-consistent closed sets are downward directed,
which is implied by closure-stability of the probes (the `ClosureStableProbe`
notion from `AlgebraEMLClosureComputation.lean`). Why now? Both ingredients —
`closure_eq_sInter_probeConsistent` here and `ClosureStableProbe` in the catalog —
already exist, so the task is to identify and prove the minimal compatibility
axiom linking them, and to falsify the naive version with an explicit
two-closed-set counterexample.

## 4. Algorithmic complexity of certified closure computation

Conjecture: given a finite closure system presented by an irredundant separating
probe family of size `k` over `n` points, the closure of any set is computable in
`O(k · n)` probe evaluations, and this is optimal up to constants. This turns
`closure_eq_sInter_probeConsistent` into a verified algorithm with a matching
lower bound.

The key insight is that signature dominance (`SignatureLE`) is monotone and
membership probes recover inclusion (`signatureLE_mem_iff`), so closure
computation reduces to a single monotone sweep over the certified probe family
rather than over the full closed-set lattice. Why now? The reconstruction
identity and the inclusion-equivalence lemma are both proved, so a `Computation`
domain formalization can wrap them into an executable `cl`-evaluator and certify
its output against the lattice definition.

## 5. Functoriality of signatures under closure-preserving maps

Conjecture: a closure-preserving endomorphism (the `ClosurePreservingEnd` of
`AlgebraEMLReconstruction.lean`) induces a natural transformation on probe
signatures, so separating families pull back to separating families along
surjective closure morphisms, giving a reconstruction-respecting category of
closure systems.

The key insight is that `signature` is contravariant in the probe family and
covariant in the set, so a closure morphism `f` with `f '' cl S ⊆ cl (f '' S)`
transports a probe `p` to `p ∘ (image f)` while preserving the separation
property witnessed in `signature_injOn_closed`. Why now? The endomorphism monoid
and its closure-preservation law are already developed in the catalog, so this
direction simply glues the existing `ClosurePreservingEnd` algebra to the new
`signature`/`SeparatesClosed` layer, yielding a genuinely categorical bridge
theorem.
