# When Duplicates Don't Matter: The Hidden Mathematics of "Taking the Minimum"

## The GPS That Couldn't Forget

Imagine you're building a GPS navigation system. Your software computes the shortest route from home to work by considering every possible path: through the highway, through downtown, through the side streets. For each pair of intermediate waypoints, it calculates the minimum travel time. Simple enough.

But here's a problem that plagued early navigation algorithms: the system would compute the same path multiple times. The route "home → highway → exit 5 → work" might appear three times in the internal calculations—once from considering exit 5 as an intermediate stop, once from considering the highway segment, and once from a different decomposition entirely. The software dutifully tracked all three copies, consuming memory and processing time, even though taking the minimum of the same number three times gives you... the same number.

This sounds trivial. Of course min(3, 3, 5) = min(3, 5). Every programmer knows this. But when you're building certified software—systems that must provably produce correct results, like avionics controllers or autonomous vehicle planners—"of course" isn't good enough. You need a mathematical *proof* that eliminating duplicates never changes the answer. And you need that proof to compose: not just for individual numbers, but for entire families of symbolic expressions involving variables, additions, and nested minimum operations.

This is the story of how that proof was finally constructed, and why it opens doors far beyond navigation.

## The Algebra Hiding in Your Spreadsheet

To understand why this matters, we need to see the world through the lens of *tropical mathematics*—a beautiful alternative to ordinary arithmetic that has been quietly revolutionizing fields from optimization to biology.

In tropical mathematics, you replace the usual addition with "take the minimum" and the usual multiplication with ordinary addition. So the tropical sum of 3 and 5 is min(3, 5) = 3, and the tropical product of 3 and 5 is 3 + 5 = 8. This sounds bizarre, but it's the natural arithmetic for optimization problems. When you want the shortest path in a network, you're adding edge weights (tropical multiplication) and choosing the minimum over alternatives (tropical addition).

This "min-plus" algebra shows up everywhere:
- **Shortest paths**: The Floyd-Warshall algorithm is tropical matrix multiplication.
- **Dynamic programming**: The Bellman equation is a tropical recurrence.
- **Machine learning**: The "log-sum-exp" trick in neural networks is a smooth approximation of tropical arithmetic.
- **Biology**: Gene regulatory networks can be modeled with tropical polynomial systems.

The key algebraic property that makes tropical arithmetic different from ordinary arithmetic is *idempotence*: min(a, a) = a. In ordinary addition, 3 + 3 = 6, not 3. But in tropical addition, the "sum" of a number with itself is just the number. Duplicates vanish.

## The Canonicalization Problem

Now here's where it gets mathematically interesting. Suppose you have two symbolic expressions involving variables, min, and addition:

Expression A: min(x, min(x, y))
Expression B: min(x, y)

Are these "the same"? In what sense?

They're certainly *semantically* equivalent: plug in any values for x and y, and both expressions give the same result. But proving this for all possible inputs requires more than plugging in test cases.

There's a classical approach: define a *normal form*—a canonical way to write each expression—and show that equivalent expressions always reduce to the same normal form. This is the strategy behind many automated reasoning systems. For tropical expressions, the standard approach handles commutativity (min(a,b) = min(b,a)) and associativity (min(min(a,b),c) = min(a,min(b,c))) by flattening nested min-operations into a sorted list: min(x, min(x, y)) becomes the sorted list [x, x, y], and min(x, y) becomes [x, y]. These are different lists, so the AC normalizer says they're *not* equivalent.

But they *are* equivalent! The second x is redundant. To capture this, we need to go further: after flattening and sorting, we must also *deduplicate*—remove adjacent equal elements. This gives [x, y] for both expressions. This is the ACI normalizer: it handles Associativity, Commutativity, and Idempotence.

## From Bags to Sets

The mathematical insight is beautiful in its simplicity. An AC normalizer treats the children of a min-expression as a *multiset* (a bag that tracks multiplicity). An ACI normalizer treats them as a *set* (where multiplicity doesn't matter). The passage from AC to ACI is exactly the passage from multisets to finite sets.

This isn't just an optimization. It's a change in the mathematical ontology of expressions. Under AC, min(x, x, y) and min(x, y) are genuinely different objects—one has two copies of x, the other has one. Under ACI, they're identified: what matters is the *support* (which variables appear), not the multiplicity.

For tropical mathematics, this is exactly the right abstraction. In a shortest-path computation, having two copies of the same path option doesn't create a shorter path. In a tropical polynomial, duplicate monomials don't change the polynomial's graph—a piecewise-linear function determined entirely by which affine functions participate, not how many times each appears.

## The Five Theorems

The mathematical framework consists of five interlocking theorems:

**Soundness**: The ACI normalizer preserves meaning. Normalizing an expression never changes what it computes. This is the baseline correctness guarantee.

**Completeness**: Two expressions are ACI-equivalent if and only if they have the same normal form. This means the normalizer is a perfect decision procedure—it never misses an equivalence, and never falsely identifies non-equivalent expressions.

**Idempotence**: Normalizing an already-normalized expression returns it unchanged. This certifies that the algorithm computes genuine canonical forms, not just reduced forms that might shift on re-application.

**Decision Procedure**: Equal normal forms guarantee equal semantics for all inputs. This is the practical payoff—a computable test for semantic equivalence.

**Strict Strengthening**: The ACI normalizer identifies strictly more equivalences than the AC normalizer. There exist expressions that AC cannot equate but ACI can. This proves the extension is genuine, not vacuous.

## Why Certification Matters

You might wonder: isn't it obvious that deduplication preserves the minimum? Why bother proving it formally?

The answer lies in the gap between intuition and correctness. In practice, normalization algorithms are notoriously tricky to get right. Off-by-one errors in list processing, subtle issues with empty lists, corner cases where the canonical form isn't actually canonical—these bugs are the bane of symbolic computation systems.

The formal proof eliminates this entire class of errors. Every step of the normalization pipeline—flattening nested expressions, sorting children into canonical order, removing adjacent duplicates, rebuilding the tree—is verified against its specification. The proof that deduplication preserves evaluation semantics isn't just a one-line appeal to "min is idempotent"; it requires careful induction over the list structure, handling the interaction between comparison, equality, and minimum at each step.

More importantly, the formal framework *composes*. Once you have certified ACI normalization, you can build certified tools on top of it: automated equality checkers for tropical expressions, simplifiers for optimization problems, preprocessors for geometric computations. Each tool inherits the correctness guarantee of the underlying normalizer.

## The Semilattice Connection

There's a deeper algebraic story here. The operation min on real numbers isn't just "an operation that happens to be idempotent." It's the *meet* operation in a *semilattice*—a partially ordered set where every pair of elements has a greatest lower bound.

This perspective reveals that ACI normalization is really *semilattice normalization*. The same algorithm works for any semilattice operation: lattice meet (∧), lattice join (∨), set intersection (∩), set union (∪), or GCD. In each case, the passage from AC to ACI corresponds to recognizing that the operation satisfies a²= a, and that therefore the normal form should be a *set* of generators rather than a multiset.

This unifies a vast landscape of algebraic simplification problems. The tropical case is a particularly clean entry point because the total order on real numbers makes sorting straightforward and deduplication well-defined. But the ideas extend to any decidable semilattice.

## Shortest Paths and Beyond

The practical implications ripple outward. Consider the Floyd-Warshall algorithm for all-pairs shortest paths. Internally, it computes expressions of the form

min(d[i][j], d[i][k] + d[k][j])

for all intermediate vertices k. As the algorithm runs, the same path may be "discovered" through multiple intermediate vertices, creating duplicate min-branches. In a naïve implementation, these duplicates are carried along, inflating the expression size.

ACI normalization provides a certified way to eliminate these redundancies. After each round of the algorithm, you normalize the accumulated expression, collapsing duplicates. The soundness theorem guarantees this doesn't change the computed shortest distances. The compression can be dramatic: in pathological cases, the expression size grows linearly rather than exponentially.

The same principle applies to dynamic programming more broadly. Any DP recurrence over a min-plus semiring—optimal alignment in bioinformatics, minimum-cost flow in network optimization, Viterbi decoding in speech recognition—can benefit from certified duplicate elimination.

## The Road Ahead

This work opens several concrete research directions. The most immediate is packaging the normalizer as an automated reasoning tool: a push-button procedure that simplifies min/max expressions in proof assistants and computer algebra systems. Beyond that, extending the framework to handle distributivity (the identity a + min(b,c) = min(a+b, a+c)) would yield a normalizer for full tropical polynomials—the bread and butter of tropical geometry.

Further afield, the semilattice perspective suggests connections to abstract interpretation in program analysis (where lattice operations model information flow), to weighted automata theory (where idempotent semirings classify regular languages by weight), and to quantum computing (where the tropical limit of partition functions connects statistical mechanics to optimization).

The mathematics of "taking the minimum" turns out to be surprisingly rich. A simple observation—that min(a, a) = a—when formalized carefully, leads to a certified decision procedure, a generic simplification framework, and a bridge between algebra, geometry, and computation. Not bad for an identity that seemed obvious.
