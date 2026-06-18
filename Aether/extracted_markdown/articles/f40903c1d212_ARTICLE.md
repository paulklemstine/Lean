# When Circles Collide: How Overlapping Cycles Reveal Hidden Structure in Networks

## The Particle Problem

Imagine you are a physicist studying a gas of particles in a box. Each particle bounces around independently, and you can describe the whole system by describing each particle separately. Life is simple—because the particles don't interact.

Now turn on the forces between them. Suddenly, particles that are close enough begin to push and pull each other. The system can no longer be understood one particle at a time. Instead, you need to identify which clusters of particles are interacting and analyze each cluster as a unit. Particles in different clusters—too far apart to influence each other—can still be treated independently. The hard physics happens inside each cluster.

This is exactly the situation that arises in a seemingly unrelated corner of mathematics—the study of cycles in networks. And a new set of results shows that the same decomposition principle, the same clustering of interactions, governs the algebraic structure of network cycles in a surprisingly precise way.

## Cycles in Networks

A network—what mathematicians call a graph—is a collection of nodes connected by links. Think of cities connected by roads, neurons connected by synapses, or computers connected by cables. One of the most fundamental features of any network is its cycles: closed loops where you can start at one node, follow links through other nodes, and return to where you began without retracing your steps.

Cycles are everywhere. In an electrical circuit, current flows in loops. In a social network, cycles represent closed chains of acquaintance. In a transportation system, cycles are circular routes. Understanding the cycle structure of a network is one of the oldest problems in mathematics, going back to Euler's famous analysis of the bridges of Königsberg in 1736.

Every cycle has a *support*—the set of nodes it passes through. A triangle in a social network has a support of three people. A hexagonal ring in a chemical molecule has a support of six atoms. The support is the cycle's footprint on the network.

When a network has multiple independent cycles, their supports tell you where each cycle "lives." And here is where things get interesting: sometimes those supports overlap.

## The Disjoint World

Until recently, the best-understood case was the one where cycle supports don't overlap at all—where each cycle occupies its own private territory in the network.

In this disjoint regime, there is a beautiful uniqueness theorem. To state it, we need a concept from *tropical mathematics*—a variant of ordinary algebra where addition is replaced by taking minimums and multiplication is replaced by ordinary addition. (Yes, mathematicians really do this, and it turns out to be enormously useful in optimization, computational biology, and algebraic geometry.)

The tropical kernel of a network is a mathematical object that encodes all the cycle information at once. When cycle supports are disjoint, the theorem says that the "generators" of this tropical kernel—the building blocks from which all cycle information can be reconstructed—are essentially unique. There's only one way to decompose the cycle structure into independent pieces, up to trivial relabeling and shifting.

This is elegant, but limited. In most real networks, cycles share nodes. The cycles in a road network share intersections. The loops in a protein's backbone share amino acids. What happens when supports collide?

## The Overlap Graph

The new theory begins with a deceptively simple idea: build a graph of the overlaps.

Given a family of cycle supports, create a new network—the *overlap graph*—whose nodes are the supports themselves and whose links connect any two supports that share at least one element. Two cycles that pass through a common node are linked; two cycles with no nodes in common are not.

The connected components of this overlap graph are called *overlap classes*. Supports in the same class are connected by chains of shared elements. Supports in different classes have no shared elements whatsoever—not directly, and not through any chain of intermediaries.

This simple construction turns out to be exactly the right decomposition.

## The Factorization Theorem

The central mathematical result is the *overlap class factorization theorem*: supports from different overlap classes have completely disjoint unions. Not just pairwise disjoint supports, but disjoint *unions of supports within each class*. If you take all the nodes belonging to cycles in one overlap class and all the nodes belonging to cycles in another, those two sets of nodes have no overlap at all.

This means the network's cycle structure decomposes into independent sectors—one for each overlap class. Just as non-interacting particles in a gas can be analyzed separately, cycles in different overlap classes can be studied independently. The hard, entangled mathematics happens only within each class.

The proof uses induction on the chain of overlaps. If two supports are not connected by any chain of shared elements, then there is no path of pairwise intersections linking them. This means their intersection must be empty. Extending this from individual supports to their unions requires careful tracking of the transitive closure of the overlap relation—the mathematical machinery that turns a local property (pairwise overlap) into a global one (class membership).

## Tropical Projective Equivalence and Invariance

The second major result connects this decomposition to the algebraic structure of tropical kernels.

Two families of cycle generators are considered "tropically projectively equivalent" if one can be obtained from the other by permuting the generators and shifting each by a constant. This is the natural notion of sameness for tropical objects—just as two bases of a vector space are related by a change-of-basis matrix, two tropical generating families are related by permutation and shift.

The theorem shows that tropical projective equivalence *preserves the overlap class structure*. If you replace one generating family by an equivalent one, the overlap pattern among the corresponding variation supports remains the same. Overlap classes are not just a combinatorial curiosity—they are an invariant of the algebraic structure.

More precisely, the theory introduces the *variation support*: instead of asking where a function is nonzero, you ask where it differs from its value at a chosen basepoint. This variation support is immune to constant shifts—the tropical analogue of scalar multiplication—making it the correct notion for studying tropical equivalence. And the theorem proves that tropical projective equivalence maps overlap classes to overlap classes, preserving the entire decomposition.

## From Disjoint to Overlapping: A Unified Framework

Perhaps the most satisfying aspect of the new theory is that it subsumes the old one. When all cycle supports are pairwise disjoint, the overlap degree—the number of overlapping pairs—is zero. Each support is its own overlap class. The factorization theorem reduces to the trivial observation that disjoint supports have disjoint unions. And the old uniqueness theorem falls out as a special case.

But the new framework goes further. It introduces the *overlap degree* as a complexity measure: zero in the classical case, positive in the interacting case. It defines the *overlap signature*—the sorted list of intersection sizes—as a finer invariant that captures not just whether supports overlap but how much they overlap. And it connects the overlap equivalence relation to graph reachability, showing that being in the same overlap class is the same as being connected in the overlap graph.

## Connections Across Mathematics

The overlap class framework connects to surprising corners of mathematics.

In *matroid theory*, the cycle supports of a graph are the circuits of its graphic matroid. The overlap classes are the connected components of the circuit intersection graph. The factorization theorem becomes a statement about matroid structure: circuits in different components of the circuit intersection graph involve completely different ground set elements.

In *coding theory*, codewords have supports (positions where they are nonzero), and the overlap structure of minimum-weight codeword supports controls the interaction pattern of error correction. Overlap classes identify independent error-correction sectors—a potential tool for designing codes with predictable structure.

In *network science*, the overlap graph is a second-order network—a network of relationships between network features. The factorization theorem says that the algebra of network cycles respects this second-order structure. Independent interaction sectors in the overlap graph correspond to algebraically independent sectors of the cycle space.

## What Comes Next

The theory opens several doors. The most tantalizing question is whether the overlap class count exactly determines the number of tropical projective equivalence classes—whether knowing the overlap pattern is sufficient to reconstruct the full algebraic structure. Computational evidence on small graphs supports this conjecture, but a proof or counterexample remains open.

Another direction is to strengthen the overlap graph to a *support nerve* or hypergraph, capturing higher-order interactions among three or more supports simultaneously. The current pairwise overlap graph is a coarse shadow of this richer structure, and the finer invariant may be needed to fully control the tropical algebra.

Perhaps most ambitiously, the framework suggests a bridge to *tropical Hodge theory*—the study of cohomological structures on tropical varieties. If tropical kernel generators decompose according to overlap classes, this decomposition might lift to a decomposition of tropical cohomology groups, connecting combinatorial graph theory to deep algebraic geometry.

## The Bigger Picture

Mathematics often progresses by finding the right level of abstraction—the right way to group things that should be grouped together and separate things that should be kept apart. The overlap class theory does exactly this for cycle supports in networks.

The key insight is that overlap is contagious. If cycle A shares a node with cycle B, and cycle B shares a node with cycle C, then A and C are part of the same interaction sector—even if A and C share no nodes themselves. This transitive structure, captured by the connected components of the overlap graph, is the natural boundary between independence and entanglement.

Just as physicists discovered that the behavior of interacting particles is governed by their interaction clusters, mathematicians have now shown that the algebra of network cycles is governed by their overlap classes. The non-interacting case was understood first, as it always is. But the real world is full of interactions—and the new theory provides the tools to handle them.
