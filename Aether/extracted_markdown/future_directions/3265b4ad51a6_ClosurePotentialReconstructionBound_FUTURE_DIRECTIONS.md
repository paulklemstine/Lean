# Future Directions — Closure Potentials and Monotone Reconstruction Bounds

The file `Bridges/ClosurePotentialReconstructionBound.lean` establishes the core
bridge: a closure-stable probe family equipped with a defect potential
`D(A) = |C \ A|` reconstructs a finite closed set `C` along a strictly
descending potential, terminating within `D(A₀)` updates and recovering `C`
exactly (`reconstruct_terminates`), packaged as a `CertifiedDescentAlgorithm`
in the spirit of `Computation/InfoEfficientAlgorithms.lean`'s
`InfoEfficientAlgorithm`. The §4 counterexample (`stalled_never_recovers`) shows
the closure-stability hypothesis is sharp. Below are five testable, falsifiable
extensions, each building on this scaffold and on the catalog files
`AlgebraEMLClosureComputation`, `AlgebraEMLReconstruction`, and
`AlgebraicEMLThermodynamicFormalism`.

## 1. Subadditivity of defect under probe-stage composition

Conjecture: if two closure-stable updates `update₁`, `update₂` are *composable*
(each maps consistent approximations into consistent approximations of the same
target `C`), then the composite `update₂ ∘ update₁` is again a closure-stable
update, and its defect satisfies the subadditive descent estimate
`D(A) − D((update₂ ∘ update₁) A) ≥ (D(A) − D(update₁ A)) + (D(update₁ A) − D(update₂ (update₁ A)))`
with the total step count of the staged pipeline bounded by `D(A₀)`.
**The key insight is** that defect is a finite cardinality and therefore an
*additive* measure on the recovered-information lattice, so stagewise gains
compose without double-counting — the same telescoping that makes
`iterate_reaches_done_of_invariant` work at the level of single steps lifts to
the level of composed pipelines. **Why now?** The single-step monotonicity
(`defect_strict_decrease`) and the generic invariant-carrying termination engine
are already proven and general enough to be reused verbatim for a product update,
so only the composition bookkeeping remains — a self-contained, finite,
falsifiable target.

## 2. Minimality / uniqueness of the recovered closed set

Conjecture: among all closed sets `S` with `cl S = S` that are *consistent with
the observations* (i.e. `A₀ ⊆ S` and `S` agrees with every closure-stable probe
on `A₀`), the reconstructed set `C` is the unique minimal one, equal to `cl A₀`
when the update operator is the closure-saturation `update A = cl A ∩ C`.
**The key insight is** that closure-stable probes cannot separate `A₀` from
`cl A₀`, so the closure operator's own `sInf`-of-closed-supersets
characterization (`closure_eq_sInf_closed_eq` in `AlgebraEMLReconstruction`)
pins the recovered set to the least closed superset — turning Tannaka-style
uniqueness (`closure_eq_of_sameClosedSets`) into reconstruction uniqueness.
**Why now?** The reconstruction state space, invariant, and termination are
already formalized here, and the closed-set lattice machinery already exists in
the catalog; the missing piece is a clean `update A = cl A ∩ C` instance plus a
minimality lemma, both finite and decidable.

## 3. Quantitative pressure/free-energy bound on reconstruction cost

Conjecture: equip `α` with a `ClosurePotential` `φ` (from
`AlgebraicEMLThermodynamicFormalism`) and define a *weighted* defect
`D_β(A) = Σ_{x ∈ C \ A} exp(β · φ x)`. Then any closure-stable reconstruction
satisfies a thermodynamic descent inequality and the number of updates is bounded
by `D_β(A₀) / (min_{x ∈ C} exp(β · φ x))`, recovering the cardinality bound as
the `β → 0` (infinite-temperature) limit. **The key insight is** that the
cardinality potential is the uniform-weight specialization of the Gibbs partition
sum, so the *combinatorial* complexity certificate is the high-temperature shadow
of a genuine *free-energy* certificate — unifying `closurePartitionFunction` with
`InfoEfficientAlgorithm` step counts. **Why now?** Both the partition-function
formalism and the integer descent theorem are in hand; the bridge is a single
weighting argument over a finite sum, which `Finset.sum` lemmas in Mathlib make
tractable and numerically falsifiable.

## 4. Adaptive vs. oblivious probe schedules: an optimality gap theorem

Conjecture: there exist finite closure systems on which every *oblivious* probe
schedule (a fixed sequence of single-element tests independent of observed
responses) needs `Θ(|C|)` updates, while an *adaptive* closure-stable update can
recover `C` in `Θ(log |C|)` updates; moreover no adaptive schedule beats
`⌈log₂(number of closed sets)⌉`. **The key insight is** that each closure-stable
update partitions the remaining closed-set hypotheses, so the defect descent is
secretly an entropy descent — exactly the binary-search entropy certificate
(`binarySearch_entropy_certificate` in `InfoEfficientAlgorithms`) transported to
the closed-set lattice. **Why now?** The certified-descent packaging already
exposes the potential as the complexity measure, so comparing two instantiations
of `CertifiedDescentAlgorithm` reduces an algorithmic optimality claim to two
finite potential computations.

## 5. Robustness: noisy probes and an approximate-recovery bound

Conjecture: if probes are *almost* closure-stable — each update may add at most
`k` spurious elements outside `C` but always adds at least one genuine element —
then a corrected defect `D'(A) = |C \ A| + |A \ C|` still descends after a
bounded correction phase, and the reconstruction terminates within
`D'(A₀) + k · (number of update steps)` updates, recovering a set within
Hausdorff/symmetric-difference distance `k` of `C`. **The key insight is** that
the identity map's `1`-Lipschitz stability on set distance
(`lipschitz_certified_robustness_identity` in `AlgebraEMLReconstruction`)
lets bounded noise be absorbed as an additive potential offset rather than
destroying monotonicity outright. **Why now?** The sharp failure mode is already
isolated in `stalled_never_recovers`, so the natural next question — *how much*
instability can be tolerated before the bound breaks — is precisely framed, and
the symmetric-difference potential is a finite cardinality amenable to the same
`Finset.card_lt_card` descent argument used here.
