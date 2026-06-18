# Future Directions: Karchmer–Wigderson Games for Closure-Stable Probe Systems

## 1. Exact KW Communication Complexity for Layered st-Connectivity

The current work proves a logarithmic lower bound on the monotone KW communication
complexity of path st-connectivity: `P.depth ≥ Nat.log 2 (n - 1)`. The Karchmer–Wigderson
1990 result establishes that for layered graphs with k layers of width k, the exact
monotone communication complexity is Θ(k²). Formalizing this would require extending
the hard-pair construction from simple paths to layered graphs, and proving that no
protocol of depth less than k² can solve the resulting separation problem.

The key insight is that in layered graphs, the adversary can force the protocol to
traverse Θ(k) layers, each requiring Θ(k) bits of information to specify the
disconnection point, yielding quadratic total complexity.

Why now? The infrastructure for BFS monotonicity, hard pair construction, and leaf
counting is already formalized. The extension to layered graphs requires only a
more complex graph family definition and a refined counting argument on separating edges.

## 2. Closure Operator Depth Hierarchy via Probe Rank

The `closure_kw_witness` theorem shows that closure-stable probe families with the
separation property yield KW witnesses. A natural strengthening would bound the
*depth* of the resulting protocol by the algebraic rank of the probe family over the
base semiring—the minimum number of probes needed for unique reconstruction.

Conjecture: If a closure operator on a finite state space α has reconstruction rank r
(meaning r closure-stable probes suffice to reconstruct every state from its probe
values), then the KW communication complexity of any closed-set membership predicate
is at most r. The converse—that r probes are also necessary—would establish a tight
correspondence between algebraic rank and communication complexity.

The key insight is that each probe query can be simulated by one round of communication,
where Alice sends the probe value on her state and Bob checks consistency with his state.

Why now? The `iterativeProtocol_depth_le` theorem already bounds depth by probe count
for non-repeating protocols. The gap is formalizing reconstruction rank and showing
that non-repeating protocols suffice.

## 3. Quantitative Separation Strength and Potential-Based Depth Bounds

The `HasSeparation` property is qualitative: either a probe separates or it doesn't.
A quantitative version would assign a *separation strength* to each probe-set pair,
measured by how much the probe value differs from all values achievable in the set.
For semiring-valued probes over ordered fields, this would be the gap
`inf_{y ∈ C} |p(x) - p(y)|`.

Conjecture: If every probe achieves separation strength at least ε, and the
diameter of the probe space is D, then at most ⌈log₂(D/ε)⌉ binary search rounds
suffice for separation—connecting KW protocols to binary search via the
`InfoEfficientAlgorithm` framework.

The key insight is that quantitative separation turns the combinatorial KW game into
an optimization problem where each round halves the remaining uncertainty, exactly
as in binary search over the probe value space.

Why now? The `InfoEfficientAlgorithm.terminates_within_potential` theorem provides
the termination bound. The missing bridge is defining a potential function on the
KW game state that decreases by a factor related to separation strength.

## 4. Tannaka Reconstruction as KW Protocol Completeness

The `closure_eq_of_sameClosedSets` theorem in `AlgebraEMLReconstruction.lean` shows
that closure operators are determined by their closed-set lattices. This suggests
a *completeness* result for KW protocols: every monotone predicate defined by a
closure operator admits a KW protocol whose leaf labels are exactly the minimal
separating probes.

Conjecture: For a finitary closure operator with separation, the KW protocol
constructed from iterative probing is *complete* in the sense that its leaf labels
biject with the minimal separating sets of the Tannaka reconstruction. This would
give a precise algebraic characterization of protocol structure.

The key insight is that the Tannaka separator witnessing non-membership in a closure
provides exactly the leaf label of the protocol—connecting algebraic reconstruction
theory to communication complexity structure theory.

Why now? The `tannakianSeparator` predicate and `closure_eq_of_sameClosedSets` are
already formalized. The connection to KW leaf structure requires showing that each
leaf of the protocol corresponds to a unique closure-preserving endomorphism that
witnesses separation.

## 5. Monotone Circuit Lower Bounds via Probe Complexity

The `STConn_circuit_depth_lower_bound` transfers the KW lower bound to monotone
circuit depth. The next step would be to formalize *size* lower bounds using
Razborov's method of approximations, which can be cast as constructing a sequence
of closure operators that approximate the target Boolean function.

Conjecture: If a monotone Boolean function f has KW communication complexity C(f),
and the closure operator underlying f has finiteGeneratorRank r, then any monotone
circuit computing f has size at least 2^{C(f)/r}. This would connect closure
complexity to circuit size via the probe/communication bridge.

The key insight is that each gate in a monotone circuit can be "approximated" by
a closure operator that preserves at most one probe value, so a circuit of size s
can only maintain s distinct probe configurations, requiring s ≥ 2^{C(f)/r}.

Why now? The `closureComplexity` and `finiteGeneratorRank` are formalized in
`AlgebraEMLReconstruction.lean`, and the KW-to-circuit transfer is complete.
The gap is formalizing Razborov-style approximation within the closure framework.
