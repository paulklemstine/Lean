# When Coloring a Network Meets the Golden Ratio

## A puzzle about not-too-close conversations

Imagine a giant trading floor. On one side of the room stand buyers; on the other, sellers. A deal is a line drawn between a buyer and a seller. Now suppose every deal must be discussed over a private radio channel, and there is a strict etiquette: two deals may share the same channel **only if they are genuinely far apart** — they touch no common person, and no third deal links one of their people to the other. Channels are expensive. How few do you need so that every deal can talk without interference?

This is not a story about trading floors, but it is exactly the mathematics behind one of combinatorics' most stubborn open problems: the **strong chromatic index** of a bipartite graph. The "deals" are edges, the "people" are vertices, and the etiquette is the rule that defines a *strong edge coloring*. The number of channels you cannot avoid is the strong chromatic index, written $\chi'_s(G)$.

For decades, a single elegant guess has resisted proof — the **Brualdi–Quinn–Massey conjecture**. It says something almost suspiciously clean: the number of channels you need is never more than the product of the two "busiest person" counts, one from each side of the room.

This article tells the story of that conjecture, of a place where it is provably *tight* (you genuinely cannot do better), and of an unexpected guest who shows up at the extreme of the problem: the Fibonacci numbers, and with them, the golden ratio.

## The rules of the game, precisely

Let $G$ be a **bipartite graph**: its vertices split into two teams, $A$ and $B$, and every edge joins one vertex of $A$ to one vertex of $B$. Edges within a team are forbidden.

A **proper edge coloring** assigns colors to edges so that two edges sharing a vertex get different colors. A **strong** edge coloring asks for more. Each color class must be an *induced matching*: not only do same-colored edges avoid sharing a vertex, but no other edge of the graph may connect their endpoints. Equivalently, two edges may share a color only if they are at **distance at least two** — they are non-adjacent, and no single edge bridges them.

The least number of colors achieving this is the **strong chromatic index** $\chi'_s(G)$.

There is a beautifully mechanical way to think about it. Build a brand-new graph — call it the **conflict graph** — whose *vertices* are the edges of $G$. Join two of these vertices whenever the corresponding edges of $G$ are *forbidden* from sharing a color (they are adjacent, or one short hop apart). Then a strong edge coloring of $G$ is precisely an ordinary vertex coloring of the conflict graph, and

$$\chi'_s(G) = \chi(\text{conflict graph of } G).$$

This reframing is the engine of everything below. A hard-to-picture "coloring at a distance" turns into a familiar question: how many colors does *this* graph need?

## The conjecture: a product bound

For a vertex on the $A$ side, its **degree** is how many deals it is part of. Let $\Delta_A$ be the largest degree among $A$-vertices — the busiest buyer. Let $\Delta_B$ be the busiest seller. The Brualdi–Quinn–Massey conjecture states, for every bipartite graph $G$,

$$\chi'_s(G) \le \Delta_A \cdot \Delta_B.$$

It is short, it is plausible, and it is **open**. The best general theorem to date only guarantees roughly $1.676\,\Delta_A \Delta_B$ — a stubborn $67\%$ overshoot that no one has closed. The conjecture asks us to erase that slack entirely.

Two natural questions immediately arise. First: is the bound even the right *shape* — could the truth be much smaller, like $\Delta_A + \Delta_B$? Second: if the bound is correct, is it ever *exactly* met, or is it always a loose overestimate?

## A floor you cannot improve: complete bipartite graphs

The cleanest possible trading floor is the **complete bipartite graph** $K_{m,n}$: every one of the $m$ buyers deals with every one of the $n$ sellers. There are $m \cdot n$ deals in total, every buyer has degree $n$, and every seller has degree $m$. So here $\Delta_A = n$, $\Delta_B = m$, and the conjectured bound is $\Delta_A \Delta_B = m\cdot n$.

Now look at the conflict graph. Pick any two distinct deals in $K_{m,n}$. Either they share a person, or — because *every* buyer trades with *every* seller — there is automatically a third deal linking one's buyer to the other's seller. In every case, the two deals are at distance at most one. **They conflict.** Every pair of deals conflicts; the conflict graph is *complete*. And a complete graph on $N$ vertices needs exactly $N$ colors. Therefore

$$\chi'_s(K_{m,n}) = m \cdot n = \Delta_A \cdot \Delta_B.$$

This is the headline structural result, captured formally as the theorem `completeBipartite_strongChromaticIndex`. It does two things at once. It confirms the conjecture holds (with no slack) for this family, recorded as `completeBipartite_satisfies_BQM`. And — more pointedly — it proves the bound $\Delta_A\Delta_B$ **cannot be lowered**: any universal theorem with a smaller right-hand side would be false on $K_{m,n}$. The conjecture, if true, is the best clean statement of its kind.

## The bound is no overestimate from below, either

What about the other direction — could the truth be far *below* $\Delta_A\Delta_B$? Here a small, robust observation puts a floor under everything. Fix the busiest buyer, the one with $\Delta_A$ deals. All $\Delta_A$ of those deals pass through the same person, so every two of them share a vertex — they pairwise conflict. In the conflict graph they form a **clique** of size $\Delta_A$. A clique of size $\Delta_A$ forces at least $\Delta_A$ colors, so for *every* bipartite graph,

$$\chi'_s(G) \ge \Delta_A, \qquad \text{and symmetrically} \qquad \chi'_s(G) \ge \Delta_B.$$

These are the theorems `maxDegA_le_strongChromaticIndex` and its mirror image. Combined with the conjectured ceiling, they sandwich the invariant:

$$\max(\Delta_A, \Delta_B) \;\le\; \chi'_s(G) \;\le\; \Delta_A\,\Delta_B.$$

The lower wall is proved unconditionally; the upper wall is the open conjecture; and the complete bipartite graphs sit pinned against the ceiling, showing the ceiling is real.

## Enter the Fibonacci numbers

Here the story takes a turn that no one ordering radio channels would have predicted. We have a clean formula, $\chi'_s(K_{m,n}) = m\cdot n$, that is *multiplicative*: the answer factors through the two side-sizes. Multiplicative formulas love to meet sequences with hidden product structure. So what happens if we choose the sizes of the two sides to be a particular, deeply patterned count?

Consider the triangular array of numbers $t_{n,k} = \binom{n+k}{2k}$ — a so-called **Riordan array**, a cousin of Pascal's triangle whose rows are read along a *steep* diagonal. Sum across a row:

$$A(n) \;=\; \sum_{k=0}^{n} \binom{n+k}{2k}.$$

For $n = 0, 1, 2, 3, 4$ this gives $1, 2, 5, 13, 34$. Anyone who has met the Fibonacci numbers $1, 1, 2, 3, 5, 8, 13, 21, 34, 55,\dots$ will feel a jolt of recognition: $1, 2, 5, 13, 34$ are exactly the **odd-indexed** Fibonacci numbers. Indeed there is a clean identity, proved as `pascalRiordanA_eq_fib`,

$$\sum_{k=0}^{n} \binom{n+k}{2k} \;=\; F_{2n+1},$$

where $F$ is the Fibonacci sequence ($F_1 = 1, F_2 = 1, F_3 = 2, \dots$). A companion identity, `pascalRiordanB_eq_fib`, sums a neighboring steep diagonal to the *even*-indexed Fibonacci numbers, $\sum_k \binom{n+k}{2k+1} = F_{2n}$. And these row sums obey the same heartbeat as the Fibonacci numbers themselves: $A(n+2) = 3\,A(n+1) - A(n)$, recorded as `pascalRiordan_three_term`.

Now we splice the two worlds together. Build the complete bipartite graph whose buyer-team has size $A(a)$ and whose seller-team has size $A(b)$. By the multiplicative formula, its strong chromatic index is the product of the two sizes — and each size is an odd-indexed Fibonacci number. The result, the bridge theorem `strongChromaticIndex_riordan_complete_bipartite`, reads:

$$\chi'_s\!\left(K_{A(a),\,A(b)}\right) \;=\; F_{2a+1}\cdot F_{2b+1}.$$

A purely *graph-coloring* quantity — the irreducible number of interference-free radio channels — has turned into a product of Fibonacci numbers. Equivalently, written entirely in terms of the original binomial sums (`strongChromaticIndex_riordan_binomial`):

$$\chi'_s\!\left(K_{A(a),A(b)}\right) \;=\; \left(\sum_{k=0}^{a}\binom{a+k}{2k}\right)\!\left(\sum_{k=0}^{b}\binom{b+k}{2k}\right).$$

For a concrete taste: take $a = 2$, $b = 3$. Then $A(2) = 5 = F_5$ and $A(3) = 13 = F_7$, and the strong chromatic index of $K_{5,13}$ is exactly $5 \times 13 = 65 = F_5 \cdot F_7$. The same number could be discovered by a graph theorist counting forbidden color clashes or by a number theorist multiplying two diagonal sums of a Pascal-like triangle. They would never know they were computing the same thing.

## Why the golden ratio is lurking

Fibonacci numbers and the golden ratio $\varphi = \tfrac{1+\sqrt5}{2}$ are inseparable: $F_n$ grows like $\varphi^n/\sqrt5$. Because our extremal strong chromatic indices are products of Fibonacci numbers, they inherit golden-ratio growth. As we walk up the family $K_{A(a),A(b)}$, the number of unavoidable colors swells geometrically at rate $\varphi^2 \approx 2.618$ per step — the same constant that controls sunflower spirals and pinecone scales now governs how fast interference-free scheduling gets expensive. The conjecture's product bound, the multiplicativity it forces at the extreme, and the arithmetic of Fibonacci sums conspire to plant the golden ratio in the middle of a scheduling problem.

## Why any of this matters

Strong edge coloring is not an abstraction invented for its own sake. It is the mathematics of **interference-free assignment**. In wireless sensor networks, two links that are physically close must use different frequency or time slots so their signals do not garble; "close" is precisely the distance-two condition. The strong chromatic index is the minimum spectrum a network can possibly survive on. The same structure governs conflict-free scheduling in parallel computing and frequency planning in dense radio deployments. A tight bound is not just elegant — it tells an engineer the true floor of resource cost.

What this body of work pins down is a trio of certainties around a famous uncertainty. The conjectured product bound $\Delta_A\Delta_B$ is the correct *ceiling shape*, because the complete bipartite graphs hit it dead on. A matching *floor*, $\max(\Delta_A,\Delta_B)$, holds for free. And at the extreme, where the bound bites hardest, the answer is not arbitrary but carries the fingerprint of the most famous sequence in mathematics.

The general conjecture remains open — the gap from $1.676\,\Delta_A\Delta_B$ down to $\Delta_A\Delta_B$ is still there, waiting. But we now know exactly what the target looks like, that it is genuinely unbeatable, and that the road to it runs, improbably, straight through Fibonacci's rabbits. Sometimes the shortest path between coloring a network and counting the spirals of a pinecone is a single product of two numbers.
