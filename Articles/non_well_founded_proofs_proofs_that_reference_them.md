# When a Proof Draws an Arrow Back to Itself

## The seduction—and danger—of circular reasoning

A proof is usually pictured as a staircase. Each step rests on lower steps, and eventually the staircase reaches the ground: axioms, assumptions, or facts already established. But modern mathematics and computer science are full of objects that do not look like staircases. Recursive programs call themselves. Network protocols revisit earlier states. Definitions of infinite streams refer to the stream still being defined. Why should proofs alone be forbidden from drawing an arrow backward?

The tempting answer is that they should not be forbidden. Perhaps a proof could be a graph rather than a tree, with a later node pointing to an earlier one. Perhaps the resulting circle could be interpreted as a fixed point, just as a recursive equation can define a meaningful function. This possibility is especially attractive in cryptography, where security arguments often reduce an attack to another attack, and in program verification, where reasoning about loops naturally returns to an invariant.

Yet one tiny argument exposes the danger:

> Assume the statement $P$ because this very proof establishes $P$; therefore $P$.

If that loop counted as evidence, every proposition would be provable. The central problem is therefore not whether circular diagrams may be written. They plainly may. It is which diagrams carry mathematical justification.

A clean answer comes from ordinals: numbers generalized far beyond the finite, but still arranged in a well-order. Give every node of a proof graph an ordinal rank, and require rank to decrease strictly whenever one node depends on another. The graph may be drawn with shared subarguments and backward-looking arrows, but its logical dependencies must always move downhill. This simple rule produces a sharp boundary. Every locally correct, decreasing graph unfolds into an ordinary proof. A direct self-loop is impossible. Indeed, every finite dependency cycle is impossible.

The result is less a celebration of circular proof than a diagnosis of it: non-tree-shaped syntax is harmless, but unsupported self-justification is not.

## From proof trees to proof graphs

To make the idea precise, consider a minimal language of propositions. Start with atomic propositions and build implications. If $A$ and $B$ are formulas, then $A\to B$ is a formula.

We use two familiar rules. The **assumption rule** says that if $A$ occurs among the current assumptions $\Gamma$, then $A$ may be concluded. The **implication-introduction rule** says that if $B$ can be derived while temporarily adding $A$ to $\Gamma$, then $A\to B$ can be derived from $\Gamma$.

An ordinary derivation is a finite tree assembled from those rules. A proof graph is more permissive. Each node carries:

1. a context $\Gamma$, listing its assumptions;
2. a conclusion $C$;
3. either an assumption instruction or an implication-introduction instruction pointing to a child node.

The graph is **locally well typed** when every instruction fits its labels. At an assumption node, the conclusion must occur in the context. At an implication node concluding $A\to B$ from context $\Gamma$, its child must have context $A::\Gamma$ and conclusion $B$.

Local correctness is necessary, but it is not enough. A one-node loop can be decorated so that its arrow points back to itself, yet no independent evidence ever appears. Local inspection cannot distinguish productive recursion from an empty promise.

The missing ingredient is a global progress certificate.

## Ordinal ranks as logical fuel

An ordinal is an element of a well-ordered hierarchy: every nonempty collection of ordinals has a least member, and there can be no infinite sequence

$$
\alpha_0>\alpha_1>\alpha_2>\cdots.
$$

Assign an ordinal $\rho(n)$ to every node $n$. Call the graph **guarded** when each dependency edge from a node $n$ to its child $m$ satisfies

$$
\rho(m)<\rho(n).
$$

The rank acts like fuel. Following a dependency consumes rank, and well-foundedness says that fuel cannot be consumed forever. The crucial theorem follows.

**Guarded Graph Soundness Theorem.** *Let a proof graph for implication logic be locally well typed. If its nodes admit ordinal ranks that strictly decrease along every dependency edge, then every node represents an ordinary derivation of its stated conclusion from its stated context.*

The proof is conceptually direct. Choose any node. Assume, by well-founded induction on its ordinal rank, that every lower-ranked child already has an ordinary derivation. If the node is an assumption, its conclusion is available immediately. If it introduces an implication $A\to B$, local typing identifies a lower-ranked child deriving $B$ from the enlarged context containing $A$. Apply implication introduction. Every case reduces to strictly smaller rank, so the induction is legitimate.

This theorem explains why graph-shaped presentations can be safe. Sharing a subproof, compressing a repeated argument, or drawing an edge that looks backward on the page does not damage soundness. What matters is the semantic direction of dependency, certified by descent.

## The smallest positive example

The proposition $P\to P$ is sometimes described informally as “assume $P$, then conclude $P$.” Because the same letter appears twice, it can sound self-referential. It is not.

Its proof has exactly two nodes. The root has empty context, conclusion $P\to P$, and applies implication introduction. Its child has context containing $P$, conclusion $P$, and applies the assumption rule. Give the root rank $1$ and the leaf rank $0$. The only dependency satisfies $0<1$.

**Height-One Identity Theorem.** *For every proposition $P$, the two-node derivation of $P\to P$ has root rank $1$, assumption-leaf rank $0$, and is a valid derivation from no assumptions.*

The distinction matters. The leaf does not claim $P$ unconditionally; it claims $P$ under the temporary assumption $P$. Implication introduction then discharges that assumption. No node depends on itself, and no circular justification occurs.

This is a useful lesson in mathematical storytelling. Phrases such as “the proof assumes what it proves” can blur the difference between a hypothetical assumption inside an implication and an illicit global assumption of the desired conclusion. The rank-$1$ derivation makes the difference visible.

## Why genuine cycles fail

Now consider a direct self-reference. A node $n$ points to itself as its own required subproof. Guardedness would demand

$$
\rho(n)<\rho(n),
$$

which is impossible for every ordinal. Thus we obtain the first obstruction.

**No-Self-Reference Theorem.** *No direct self-dependency can be certified by a strictly decreasing ordinal rank.*

The obstruction extends beyond one-node loops.

**Acyclicity Theorem for Ranked Dependencies.** *Suppose every dependency edge $a\to b$ satisfies $\rho(b)<\rho(a)$. Then no nonempty finite path of dependency edges can begin and end at the same node.*

Along a path of length $k>0$, repeated transitivity gives

$$
\rho(n_k)<\rho(n_{k-1})<\cdots<\rho(n_0).
$$

If $n_k=n_0$, this would imply $\rho(n_0)<\rho(n_0)$, a contradiction. Consequently, edge-by-edge ordinal descent does not merely control cycles; it eliminates them.

This finding corrects a seductive conjecture. One might hope that a circular proof is valid whenever references occur at “smaller ordinal height.” But if every edge in a genuine cycle decreases, returning to the starting point is impossible. Ordinal descent validates compressed well-founded proofs, not genuine circular justification.

## The liar at the boundary

The classic liar sentence says, “This sentence is false.” In arithmetic, the more disciplined Gödelian analogue says, roughly, “This sentence is not provable in the present sound system.” Negative self-reference behaves very differently from the harmless hypothetical reasoning behind $P\to P$.

Two obstructions meet here. Structurally, a pure proof loop cannot receive an ordinal height: it would require a rank smaller than itself. Semantically, in a sound diagonal system, the sentence asserting its own unprovability cannot itself be proved. If it were proved, its assertion of unprovability would be false, contradicting soundness.

These are related but distinct facts. The rank argument concerns the shape of dependency graphs. The Gödelian argument concerns truth, provability, and diagonal self-description. Keeping them separate prevents a graph-theoretic observation from being mistaken for a complete account of incompleteness.

## Why cryptographers should care

Cryptographic proofs routinely chain reductions. To show that protocol $X$ is secure, one may transform an attacker against $X$ into an attacker against primitive $Y$. Composed protocols can produce reduction diagrams with shared nodes, repeated games, and apparent back-references. An ordinal or natural-number progress measure can serve as an audit trail: every reduction step must simplify an attack, shorten a remaining interaction, lower a protocol phase, or decrease another well-founded quantity.

The guarded soundness theorem says that such a certificate is not decorative. It is what turns a diagram into an eliminable abbreviation for an ordinary argument. Conversely, a reduction that simply returns the same security claim with no decrease has supplied no evidence.

The same principle appears in termination proofs, recursive definitions, model checking, and inductive invariants. Productive recursion must reveal structure before recurring. Loop invariants must be established independently before being reused. Cyclic reasoning about inductive objects needs a progress condition along infinite traces.

## Beyond edge-by-edge descent

If strict descent rules out every finite cycle, can genuinely cyclic proofs ever be valid? Possibly—but they need a subtler criterion.

One direction is a **trace condition**. Instead of demanding a decrease on every edge, permit some nondecreasing motion while requiring that every infinite branch witness infinitely many genuine decreases at designated progress points. This resembles Büchi acceptance in automata theory: recurrence is allowed, but progress must recur as well.

Another direction uses a modal “later” operator. A recursive reference is accepted only beneath a constructor that delays its use. The slogan is that self-reference becomes meaningful after observable proof structure has been produced. This is the proof-theoretic analogue of defining an infinite stream by giving its first element before recurring on the tail.

A third direction studies partial proof trees ordered by information. Finite approximations may form the compact pieces of a domain whose limits include infinite trees. Yet the domain can contain both meaningful and meaningless limits, so a least admissible fixed point or independent productivity condition is still required.

The present results establish the baseline against which these richer systems must be measured. They show exactly what the simplest ordinal proposal can and cannot do.

## The moral of the loop

A picture may be circular while its justification is well founded. That is the durable insight.

Proof graphs are useful representations: they share repeated work, describe recursion, and match the architecture of algorithms and protocols. But shape alone does not confer validity. Local rule checking alone does not confer validity either. A global certificate must explain why following dependencies cannot postpone evidence forever.

Strict ordinal descent gives one exceptionally clear certificate. It proves that every guarded graph unfolds into an ordinary derivation, validates the height-one proof of $P\to P$, rejects direct self-reference, and forbids every finite dependency cycle. The liar is not transformed into a theorem; unsupported circularity is exposed as unsupported.

The boundary is therefore sharper than the original dream of “proofs that reference themselves.” Safe non-tree syntax is real. Genuine self-justification is not. To move beyond that boundary, future theories must replace simple descent with richer notions of recurring progress, delayed productivity, and admissible fixed points—without ever confusing a loop drawn on paper with a reason to believe what it says.
