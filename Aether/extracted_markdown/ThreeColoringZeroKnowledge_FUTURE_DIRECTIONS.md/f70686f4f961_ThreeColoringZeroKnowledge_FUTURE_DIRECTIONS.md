# Future Directions: Zero-Knowledge for Graph 3-Colorability

The file `Cryptography/ThreeColoringZeroKnowledge.lean` builds a fully verified
account of the Goldreich–Micali–Wigderson interactive proof for graph
3-colorability: completeness (`completeness`), soundness (`soundness`), the
symmetric-group rigidity lemma (`perm_unique_on_distinct_pair`), perfect
honest-verifier zero-knowledge as an equal-fiber statement (`zk_indistinguishable`),
and the matching of honest and simulated transcript supports (`simulator_support`).
The deliberate design choice — modeling the *commit/challenge/reveal* round
abstractly and isolating the combinatorics of the color permutation — exposes
exactly where privacy comes from. The following directions extend this skeleton
into a quantitative, composable, and cross-domain theory.

## 1. Quantitative soundness with an explicit rejection probability

Right now `soundness` is the *combinatorial core*: a cheating prover's committed
assignment must contain a monochromatic edge. The natural strengthening is the
probabilistic statement that, for a finite graph with edge set `E`, an
honest-but-failing committed coloring is rejected with probability at least
`1 / |E|` per round, hence with probability `1 - (1 - 1/|E|)^k` after `k`
independent rounds. **The key insight is** that soundness amplification is purely
a statement about sampling a uniform element from the nonempty set of
"bad" edges guaranteed by `soundness`, so it can be phrased entirely with
`PMF.uniformOfFintype` and a `Finset.card` lower bound — no new cryptography
needed. *Why now?* The combinatorial witness (`∃ u v, G.Adj u v ∧ f u = f v`) is
already proven, so the only remaining work is turning one guaranteed bad edge into
a probability bound, which Mathlib's `PMF`/`ENNReal` machinery now supports
directly.

## 2. Distributional (not just support-level) zero-knowledge over `PMF`

`zk_indistinguishable` shows every transcript has the *same fiber size*
independent of the witness, and `simulator_support` matches the supports. The
next step is to package these as a literal equality of probability mass functions:
the pushforward of the uniform distribution on `Equiv.Perm (Fin 3)` under the
honest prover equals the uniform distribution on distinct color pairs produced by
the simulator. **The key insight is** that "constant fibers + equal support" is
exactly the hypothesis of a counting bijection, so the `PMF` equality reduces to
`Finset.card`-bookkeeping already discharged by `reveal_fiber_card_one` and
`reveal_fiber_card_zero`. *Why now?* The fiber cardinalities are pinned to the
exact constants `1` and `0`, which is the precise input a `PMF.map` equality proof
needs; lifting from cardinalities to distributions is mechanical once the constants
are known.

## 3. From `Fin 3` to `Fin k`: rigidity degrades, and that is the point

The rigidity lemma `perm_unique_on_distinct_pair` is *unique* only because
`|Fin 3| = 3` and fixing two of three values forces the third. For `Fin k` with
`k > 3` the analogous fiber has size `(k-2)!`, still independent of the underlying
colors. **The key insight is** that zero-knowledge for `k`-coloring needs only
fiber *uniformity*, not fiber *uniqueness*: the count `(k-2)!` is constant in the
witness, so the equal-fiber HVZK argument survives verbatim while completeness and
soundness generalize unchanged. *Why now?* The current proof already separates
"the fiber has constant size" (used by `zk_indistinguishable`) from "the size is
exactly 1," making the `Fin k` generalization a drop-in replacement of the
constant — a clean test of whether our abstraction captured the right invariant.

## 4. Composition: sequential repetition preserves zero-knowledge

A single round leaks nothing, but real protocols repeat. The conjecture is that
the product simulator — sampling `k` independent distinct color pairs — perfectly
simulates `k` independent honest rounds, i.e. the `k`-fold product of the
single-round transcript distributions. **The key insight is** that independence
across rounds turns composition into a product of identical `PMF`s, so the
`k`-round indistinguishability is the `k`-th tensor power of the single-round
result with no new cross-round correlations to control. *Why now?* With
single-round distributional ZK (Direction 2) in hand, Mathlib's `PMF` monad and
`PMF.bind`/product constructions give sequential composition essentially for free,
making this the first genuinely *composable* verified ZK statement in the catalog.

## 5. Cross-domain bridge: NP-completeness packaging via the Cook–Levin neighborhood

3-colorability is NP-complete, so this verified ZK protocol is, in principle, a
zero-knowledge proof for *every* NP statement via reduction. The conjecture is a
bridge theorem: given any graph produced by a polynomial reduction from an NP
relation `R`, a witness for `R` yields a proper 3-coloring (hence an accepting
honest prover), and conversely. **The key insight is** that our `soundness`/
`completeness` pair already speaks the language of `SimpleGraph.Colorable`, which
is the exact target of standard Karp reductions, so the bridge only needs the
reduction's correctness lemma, not a re-proof of the protocol. *Why now?* The
catalog contains both combinatorial graph results and complexity-flavored files;
connecting `Colorable 3` to a generic NP relation would be the first theorem to
route privacy guarantees through NP-completeness inside this project, a
high-value cross-domain link.
