# Future Directions: Graded Proof Phase Transitions

This cycle delivered `Catalog/Computation/ProofPhaseTransitions.lean`: the deterministic
skeleton of derivability thresholds (monotonicity `ederiv_mono`/`ederiv_upward_closed`,
the barrier method `closed_preserved`/`barrier_not_derivable`, and the chain
minimal-certificate result `chain_edge_critical`) **together with a new graded layer**.
The graded layer is the part the previous synthesis flagged as missing: a length-indexed
closure `DerivIn`/`DerivLen` carrying an explicit derivation length, the potential
theorem `derivIn_potential` (a height function increasing by `1` along each axiom pins the
*exact* derivation length), the diameter lower bound `chain_min_length` (no derivation of
`0 ⟶ n` is shorter than `n`), and `ederivLen_mono` (length-bounded reachability is still
a monotone Boolean function). The directions below build directly on these named results.

## Direction 1: A two-parameter (density × length) phase diagram

**Conjecture.** In the random digraph model `G(n,p)` on `Fin n`, the bounded-reachability
event `EDerivLen E L 0 (n-1)` exhibits a *joint* threshold: for each length budget
`L = L(n)` there is a critical density `p*(n, L)`, and the surface `p*(n, L)` is strictly
decreasing in `L`, collapsing onto the unbounded threshold `p*(n, ∞)` as `L → ∞`.

**The key insight is** that `ederivLen_mono` makes `EDerivLen · L 0 (n-1)` a monotone
Boolean function *for every fixed `L`*, so the entire family is simultaneously threshold-
amenable, and `chain_min_length` already certifies that shrinking `L` below the diameter
kills the event deterministically — giving the lower edge of the surface for free.

**Why now?** Both monotonicity (in edges *and* in `L`, via `derivLen_mono_len`) and the
deterministic length lower bound are now formalized; only the product-measure / Fourier
input remains, and it can be developed one `L`-slice at a time.

**Falsifiable test.** Formalize the product measure on `Finset (Fin n × Fin n)` and prove
`p*(n, L) > p*(n, L+1)` for the chain-plus-noise model at small `n`; a flat surface would
refute the conjecture and show length is asymptotically free above threshold.

## Direction 2: Potential functions characterize minimum proof length

**Conjecture.** For an arbitrary finite theory `T`, the minimum derivation length
`d_T(a,b)` equals the supremum, over all integer height functions `φ` with
`φ y - φ x ≤ 1` whenever `T x y`, of `φ b - φ a` — an exact LP-duality / max-potential =
shortest-path identity at the proof-theoretic level.

**The key insight is** that `derivIn_potential` already proves the *easy* (weak-duality)
inequality in its graded form: any unit-increment potential lower-bounds every derivation
length. Promoting `= 1` to `≤ 1` turns it into a certificate family, and the chain shows
the bound is tight, so the open content is only the completeness (strong-duality) half.

**Why now?** The exact graded equality is in hand for unit-increment potentials; relaxing
to sub-unit increments is a direct generalization of the existing induction on `DerivIn`.

**Falsifiable test.** Prove the `≤ 1` weak bound (a one-line generalization), then attempt
strong duality on DAGs; a gap on some DAG would localize where potentials fail to be
complete shortest-path certificates.

## Direction 3: Hypergraph (Horn) thresholds via a graded firing closure

**Conjecture.** Generalizing axioms `a → b` to Horn rules `(a₁ ∧ ⋯ ∧ a_k) → b`, the graded
closure `HDerivIn` (fire a rule only when all premises are already derived, charging one
length unit) admits a potential theorem and a `k`-uniform chain whose threshold window
*sharpens* as `k` grows, mirroring random `k`-SAT.

**The key insight is** that `closed_preserved` and `barrier_not_derivable` are stated for
an arbitrary relation, so the barrier invariant lifts to "closed under hyperedge firing"
almost mechanically; the only genuinely new object is the multi-premise length accounting,
which the `DerivIn` inductive already models in spirit.

**Why now?** The relational barrier method and the length-indexed inductive are both
proven and decoupled from the binary-edge assumption, so the Horn generalization reuses
them rather than rebuilding.

**Falsifiable test.** Define `HDerivIn`, re-prove `closed_preserved` for the closure
operator, and build the `k`-uniform chain; failure to obtain a finite invariant
characterization would isolate exactly where arity breaks the relational abstraction.

## Direction 4: A criticality-index monotonicity law and the proof backbone

**Conjecture.** Define the criticality index of an axiom `e` as the least `m` such that
some `m`-edge subset containing `e` is critical for `0 ⟶ n`. Adding axioms can only
*decrease* existing indices (a monotonicity law), and at the density threshold the index
distribution is heavy-tailed — the proof-theoretic analogue of SAT backbone variables.

**The key insight is** that `chain_edge_critical` already exhibits index-`1` axioms (each
chain edge is critical in a minimal certificate), while `ederiv_mono` gives the
monotonicity engine: more edges ⇒ more derivations ⇒ weaker criticality, all expressible
as a `Finset.sdiff` bookkeeping argument on top of the proven monotonicity.

**Why now?** Index-`1` witnesses and edge-monotonicity are both formalized; the law is a
finite combinatorial argument requiring no new analytic input.

**Falsifiable test.** Formalize the index and prove monotonicity from `ederiv_mono`; a
counterexample where adding an axiom *raises* some index would refute the "redundancy only
dilutes criticality" intuition.

## Direction 5: Diameter-driven proof-length transition is genuinely separate

**Conjecture.** There exist theory families where derivability (`EDeriv 0 (n-1)`) holds
w.h.p. at density `p` but the *shortest* derivation has length super-polylogarithmic — so
the proof-length transition `chain_min_length` detects sits strictly above the existence
transition, rather than coinciding with it.

**The key insight is** that `chain_min_length` already separates the two notions
deterministically on the chain (length is forced to equal `n`, the diameter), so the
question is whether random perturbations of the chain preserve a large diameter while
adding existence-shortcuts — a structural, not merely probabilistic, phenomenon.

**Why now?** The exact length/diameter equality for the chain is proven, giving a concrete
hard instance to perturb; without it there was no length witness to separate from
existence at all.

**Falsifiable test.** Add `o(n)` random shortcut edges to `chainEdges n` and bound the
resulting diameter from below via a perturbed potential (`derivIn_potential`); a collapse
to polylog length would show the two transitions coincide and there is no separate
proof-length transition.
