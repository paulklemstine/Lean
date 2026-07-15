# When Arguments Become Games: A Three-Way Mathematical Dictionary

An argument attacks another argument. A chess position leads to another position. A vertex points along an arrow to a neighboring vertex. These sentences seem to belong to different worlds: debate, games, and graph theory. Yet the same mathematical structure lies beneath all three. Once the arrows are oriented correctly, a stable collection of mutually compatible arguments is exactly a kernel of a directed graph and exactly the collection of losing positions in a consistently solved normal-play game.

This dictionary does more than rename ideas. It explains why a triangle of attacks can resist every attempt at a stable verdict, why a square admits two opposite verdicts, and why every genuinely terminating system has one—and only one—solution. It also derives the familiar rule “a player with no move loses” from two elementary geometric conditions rather than assuming it as an extra convention.

## Three views of one arrow diagram

Let $X$ be any set of positions, arguments, or vertices, and let $R(x,y)$ mean that there is a directed arrow from $x$ to $y$.

In argumentation theory, the arrow $R(x,y)$ says that argument $x$ attacks argument $y$. A set $S\subseteq X$ is called **stable** when it satisfies two requirements:

1. no member of $S$ attacks another member of $S$;
2. every point outside $S$ is attacked by some member of $S$.

The first condition is internal peace. The second is external decisiveness. A stable set contains no unresolved conflict of its own, yet it answers every excluded argument.

Graph theory packages almost the same conditions under the name **kernel**. A set $K\subseteq X$ is a kernel of the directed relation $R$ when:

1. no arrow of $R$ runs between two members of $K$;
2. every point outside $K$ has an arrow leading to some member of $K$.

The subtle difference is the direction of the second arrow. Stable arguments attack outward; vertices outside a kernel point inward. If $R^{\mathrm{op}}$ denotes the reversed relation, defined by

$$
R^{\mathrm{op}}(x,y) \quad\text{exactly when}\quad R(y,x),
$$

then the mismatch disappears.

**Stable–Kernel Dictionary.** A set $S$ is stable for an attack relation $R$ if and only if $S$ is a kernel of the reversed relation $R^{\mathrm{op}}$.

The proof is almost visual. Internal conflict-freeness is unchanged when every arrow is reversed: an arrow between two chosen points remains an arrow between two chosen points. Meanwhile, “every outsider is attacked by a chosen point” becomes, after reversal, “every outsider has an arrow to a chosen point.” These are precisely the two kernel conditions.

## The game hidden in the graph

Now interpret $R(x,y)$ as a legal move from position $x$ to position $y$. Under normal play, a **P-position** is a position from which the player who just moved—the previous player—can force a win. Equivalently, it is losing for the player whose turn it is. The recursive rule is familiar:

$$
x\text{ is losing} \quad\Longleftrightarrow\quad
\text{every legal move from }x\text{ goes to a non-losing position}.
$$

Write $P$ for the set of losing positions. A **game solution** is a set satisfying

$$
x\in P \quad\Longleftrightarrow\quad
\forall y,\; R(x,y)\Rightarrow y\notin P.
$$

This single equivalence has two halves. If $x$ is losing, it cannot move to another losing position. If $x$ is not losing, then the right side must fail, so at least one legal move reaches a losing position. Those are exactly independence and absorption.

**Kernel–Game Dictionary.** A set $K$ is a kernel of $R$ if and only if it is a P-position solution of the game whose moves are the arrows of $R$.

Combining the two dictionaries gives the central identity:

$$
\text{stable sets for }R
=
\text{kernels of }R^{\mathrm{op}}
=
\text{P-position solutions for }R^{\mathrm{op}}.
$$

The equality is conceptual, not merely symbolic. A verdict in an argument network, an absorbing independent set in a digraph, and a complete win–loss classification of a reversed-arrow game are the same object described in three dialects.

## Why terminal positions must be losing

Consider a position $t$ with no legal move. Suppose $K$ is a kernel. Could $t$ lie outside $K$? Absorption would then demand an arrow from $t$ to some point of $K$. But $t$ has no outgoing arrows. This contradiction forces $t\in K$.

**Terminal-Position Principle.** Every terminal position belongs to every kernel and therefore to every P-position solution.

Thus “no move means loss” is not an additional decoration attached to the theory. Once a solution is required to be independent and absorbing, terminal positions are automatically losing. The local geometry of arrows already contains the normal-play boundary condition.

This matters in applications. A terminal state might be a completed task in a workflow, a dead end in a planning problem, or a settled claim in a debate. Whatever its interpretation, any coherent kernel-based classification must place it on the P-side.

## The triangle that refuses a verdict

Not every arrow diagram can be solved. Take three vertices $0,1,2$ with arrows

$$
0\to1,\qquad 1\to2,\qquad 2\to0.
$$

This directed triangle has no kernel. To see why, suppose one vertex, say $0$, is chosen. Independence forbids choosing $1$, while absorption of the unchosen vertex $1$ forces $2$ to be chosen because $1$ points only to $2$. But then the arrow $2\to0$ violates independence. The same contradiction follows from either of the other starting choices. Choosing no vertices fails absorption, and choosing multiple adjacent vertices fails independence.

**Odd Triangle Obstruction.** The directed three-cycle has no kernel. Consequently, the corresponding attack framework has no stable set, and the corresponding move graph has no consistent P-position solution.

The game interpretation makes the paradox vivid. If $0$ is losing, then $2$ must be winning because it can move to $0$; that makes $1$ losing; and that makes $0$ winning—a contradiction. Starting with “winning” merely reverses the chase. The labels circle forever.

In argumentation language, every attempt to accept one claim triggers a forced response that eventually attacks the original accepted claim. Stability asks for more than maximality. A maximal conflict-free set may exist, but a stable set must also attack everything it leaves out. The triangle shows that this stronger demand can be impossible.

## The square and the return of choice

Now take four vertices in a directed cycle:

$$
0\to1\to2\to3\to0.
$$

The alternating set $\{0,2\}$ is a kernel: its two vertices are not connected to each other, while $1$ points to $2$ and $3$ points to $0$. The other alternating set $\{1,3\}$ is also a kernel. Under the argumentation orientation, both alternating sets are stable as well.

**Four-Cycle Theorem.** The directed four-cycle has two distinct stable sets, namely $\{0,2\}$ and $\{1,3\}$. Equivalently, it has two alternating kernel or game solutions after the appropriate reversal of arrows.

Parity has changed the story. Around an even cycle, losing and winning labels can alternate and return consistently to their starting point. Around an odd cycle, alternation returns with the wrong label. But the square also teaches a second lesson: existence does not imply uniqueness. Cycles permit global feedback, and feedback can support multiple self-consistent verdicts.

That phenomenon resembles coordination problems. If four agents respond cyclically to one another, two alternating patterns can each be internally coherent. Local rules alone do not select between them.

## Termination restores a unique answer

The triangle fails to have a solution, and the square has too many. What structural hypothesis gives exactly one? The answer is well-foundedness.

A move relation is **well-founded in the direction needed for recursion** when there is no infinite sequence of legal moves

$$
x_0\to x_1\to x_2\to\cdots.
$$

In finite graphs, this amounts to the absence of directed cycles. More generally, it says every play must eventually stop, even when the set of positions is infinite.

On such a game, define losing positions from the bottom upward. Terminal positions are losing. A position is losing if every move goes to a non-losing position; it is winning if at least one move goes to a losing position. Well-foundedness guarantees that this recursion never depends circularly on itself.

**Well-Founded Kernel Theorem.** Every well-founded directed move graph has exactly one kernel. It is the set $L$ recursively characterized by

$$
x\in L \quad\Longleftrightarrow\quad
\forall y,\; R(x,y)\Rightarrow y\notin L.
$$

Existence follows because the recursive set $L$ is independent and absorbing. If $x\in L$, every successor lies outside $L$, proving independence. If $x\notin L$, the defining universal statement fails, so some successor belongs to $L$, proving absorption.

Uniqueness follows by well-founded induction. Suppose $K$ and $L$ are kernels. At a position $x$, assume they agree at every successor. If $x$ belonged to $K$ but not $L$, absorption for $L$ would provide a successor $y\in L$; agreement below $x$ would put $y$ in $K$, contradicting independence of $K$. The reverse mismatch is symmetric. Therefore $K=L$.

Two translations are immediate.

**Determinacy of Terminating Normal-Play Games.** Every game with no infinite play has exactly one consistent set of P-positions.

**Unique Stability of Well-Founded Argumentation.** If an attack relation has no infinite backward chain of attacks, then it has exactly one stable set.

The orientation in the last statement matters because stable semantics uses attacks outward while kernels use arrows inward. Once that reversal is remembered, all three theorems are one theorem.

## A bridge with practical reach

In an argument network, the unique stable set identifies a coherent collection that defeats every excluded claim. In a terminating game, the same recursion yields perfect-play strategy: from every winning position, move to a losing one. In a directed dependency graph, the kernel identifies independent representatives that absorb all other vertices.

The bridge therefore transfers both intuition and algorithms. Backward induction from games computes stable extensions in well-founded debates. Graph kernels expose the obstruction behind circular argumentation. Argumentation semantics gives a language for interpreting competing global solutions such as the two alternating patterns on the square.

The next frontier is to understand how far the parity picture extends. Positive even cycles have alternating kernels, while odd cycles obstruct them. Larger classes of graphs without odd directed cycles invite kernel-existence theorems. Another direction assigns each position not just a win–loss bit but a numerical Grundy value, with value zero marking precisely the kernel. Finally, one may compare the unique well-founded stable set with the least fixed-point, or grounded, interpretation of argumentation.

The enduring message is simple. Arrows can represent attacks, moves, or dependencies, but the mathematics does not care what story gave them their names. Reverse the arrows once, and stability, absorption, and losing positions line up. Cycles explain failure and ambiguity; termination restores a unique verdict. Three theories become one map.