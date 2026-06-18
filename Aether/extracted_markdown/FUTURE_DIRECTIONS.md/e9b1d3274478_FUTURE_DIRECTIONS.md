# Future Directions — Closure-Stable Probe Compression

The file `Bridges/ClosureProbeCompression.lean` establishes a complete
*algorithmic* compression pipeline for closure systems reconstructed from finite
probe families: `probeClosure` is a genuine `SetClosureOperator`, every finite
family admits an irredundant subfamily with identical closure
(`exists_irredundant_subfamily`), indispensability has a falsifiable witness
certificate (`indispensable_iff_certificate`), and irredundant families are
bounded in size by their kernel partitions, yielding the computable certificate
bound `2 ^ (n²)` (`irredundant_card_le`, `compression_bound`). The directions
below extend this skeleton toward sharper bounds, canonicity, and dynamics.

## 1. Kernel-lattice sharpening of the certificate bound

The bound `Q.card ≤ 2 ^ (n²)` is computable but loose: it counts arbitrary
subsets of `α × α`, whereas every kernel is an *equivalence relation*, so the
true ceiling is the Bell number `B(n)` of partitions of the carrier, and an
irredundant family that is also kernel-*antichain* should be even smaller.
**Conjecture.** For an irredundant `Q`, `Q.card ≤ B(Fintype.card α)`, and the
kernels of `Q` form an antichain in the partition lattice ordered by refinement
(no kernel refines another), so `Q.card` is bounded by the width of that lattice.
The key insight is that `redundant_of_sameKernel_dup` is the degenerate
(equality) case of a refinement-monotonicity phenomenon: if `ker p` refines
`ker q` then `q`'s constraint is subsumed and `q` becomes redundant, forcing the
surviving kernels into an antichain. Why now: `sameKernel_iff_kernelFinset`
already exposes kernels as concrete `Finset (α × α)` data, so the refinement
order is `⊆` on those finsets and the antichain statement is directly formalizable
against the existing infrastructure.

## 2. Refinement subsumption as the true redundancy criterion

`redundant_of_sameKernel_dup` only deletes *duplicate* kernels. The natural
generalization replaces equality by refinement.
**Conjecture.** If `p, q ∈ P`, `p ≠ q`, and `ker q` refines `ker p`
(`∀ x y, q x = q y → p x = p y`), then `p` is redundant in `P`.
The key insight is that the finer probe `q` already separates everything `p`
separates, so `p` never contributes a fresh constraint to `probeClosure`; this
turns compression from "remove duplicates" into "keep only refinement-minimal
probes". Why now: the proof of `redundant_of_sameKernel_dup` already routes the
witness through `q ∈ P.erase p`; only the final kernel-transfer step
`(hk x y).2 hqy` must be weakened from a biconditional to the single implication
supplied by refinement, so the existing proof is one edit away from the general
statement.

## 3. Canonical compressed family up to kernel equivalence

Theorem A produces *an* irredundant subfamily but not a canonical one; different
deletion orders can yield different `Q`. The optional strengthening in the
research brief asks for uniqueness up to extensional (kernel) equivalence.
**Conjecture.** Any two irredundant subfamilies `Q₁, Q₂ ⊆ P` with
`probeClosure Q₁ = probeClosure Q₂` (= `probeClosure P`) satisfy
`Q₁.image kernelFinset = Q₂.image kernelFinset`; i.e. the *set of kernels* of a
minimal reconstruction is an invariant of the closure, even though the probe
representatives are not. The key insight is that the closure operator determines,
for each pair `(x, y)`, whether some probe must separate them, and an irredundant
family must realize exactly the refinement-minimal such separations — a matroid-
like exchange property. Why now: combined with directions 1–2 the kernels of an
irredundant family are forced to be the refinement-minimal generators of a single
fixed kernel-lattice, which is exactly the canonical-basis situation, and
`closure_eq_of_sameClosedSets` from the catalog already gives the rigidity needed
to pin closures down from their closed-set lattice.

## 4. Dynamic compression under the semimodule transition map

The catalog's `ClosureSemimoduleSystem` carries a transition map `step : σ → α → σ`
and `evalWord`; the present file ignores dynamics. A probe family should be
compressible *relative to reachability*.
**Conjecture.** Restricting attention to the reachable support
`R = {evalWord M s w | w}` from a start state `s`, the reachable-compressed family
`Q_R` (irredundant for `probeClosure` evaluated only on subsets of `R`) can be
strictly smaller than the global `Q`, and `compression_bound` improves to
`2 ^ (|R|²)`. The key insight is that probes only need to separate *reachable*
states, so the effective carrier is `R`, not `α`, and certificate size collapses
when the reachable set is small even if `α` is huge. Why now: `evalWord`,
`ClosureTrace`, and `closureTrace_append` already give a clean reachable-support
calculus in `AlgebraEMLClosureComputation.lean`, so the reachable closure operator
is `probeClosure P` post-composed with intersection-by-`R`, an immediate variant
of the existing `probeClosureOp`.

## 5. Cost-weighted greedy compression and an approximation guarantee

Probes may carry acquisition costs; one wants a *minimum-cost* irredundant family,
not just any. Assign `cost : (α → K) → ℕ`.
**Conjecture.** When the redundancy structure of `P` forms a matroid on its
kernels (plausible by direction 3's exchange property), the greedy deletion of the
highest-cost redundant probe yields a globally minimum-cost irredundant subfamily;
without the matroid hypothesis greedy is within a `H(n)`-factor (harmonic-number)
of optimal, mirroring set-cover. The key insight is that compression is a basis-
extraction problem and the irredundant families are precisely the bases, so
minimum-cost reconstruction inherits the exactness/approximation dichotomy of
weighted matroid versus set-cover optimization. Why now: `exists_irredundant_subfamily`
already performs an *unweighted* greedy descent with a clean termination measure
(`Finset.card`), so threading a cost into the deletion choice and proving the
exchange/matroid property is a direct, well-scoped extension of the present proof.
