# How Often Must a Snake Turn? Combs, Corners, and the Hunt for Long Paths in the Hypercube

*A cheap way to tidy up a snake, and why the hard part is somewhere else.*

---

## A game on the corners of a cube

Take an ordinary cube and label its eight corners with three-bit strings: $000$, $001$, $010$, and so on up to $111$. Two corners share an edge exactly when their labels differ in one bit. Do the same thing with $n$ bits and you get the **$n$-dimensional hypercube** $Q_n$. It has $2^n$ corners, and each corner has $n$ neighbours, one for each bit you can flip.

Now play a game. Start at some corner and walk along edges. Each step flips one bit. There is one rule, and it is strict: **your path may never come back next to itself.** Each new corner you step on must be adjacent to the corner you just left and to no other corner you have already visited. A path that follows this rule is called a **snake**, and the old puzzle known as *snake-in-the-box* asks how long a snake can get.

The rule bites quickly. In the ordinary cube $Q_3$ the longest snake has just $4$ edges, although the cube has $8$ corners. The best known lengths grow like this:

| dimension $n$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| longest snake $S(n)$ | 1 | 2 | 4 | 7 | 13 | 26 | 50 |

After $n = 7$ nobody knows the exact answer, and record-hunters use large computer searches to push the lower bounds up. The question has a practical side as well. A snake is a code that detects errors. If you read a sequence of positions from a sensor and a single bit is corrupted, the corrupted word is either not a position on the snake or sits right next to the true one, so the damage stays small. Engineers met this problem in the 1950s while designing analog-to-digital converters, and it has stayed in the literature since.

The obvious difficulty is the size of the search space. The number of possible snakes grows explosively with $n$. Any principled way to cut the space down, by saying "you only need to look at snakes of *this* special shape", is valuable.

This article is about one proposed cut, the **turn-minimal normal form**, and about what happened when it was examined carefully.

## Snakes as two-dimensional pictures

The key move is to see the hypercube as a product. Split the $n$ bits into two groups: the first $a$ bits, which we call the **row**, and the remaining $b = n - a$ bits, which we call the **column**. Each corner of $Q_n$ is then a pair (row, column). One step of a snake flips one bit, so it changes either the row or the column, never both. In the language of graph theory, $Q_n$ is the **box product** $Q_a \,\square\, Q_b$. You can picture it as a grid whose rows are copies of $Q_b$ and whose columns are copies of $Q_a$.

Now follow a snake and write down only its row at each moment. You get the snake's **row sequence**. Most steps leave the row alone, because they flip a column bit. Occasionally a step flips a row bit and the snake jumps to another row. Call such a step a **turn**, or **direction change**. The **turn count** is the number of turns.

Here is the picture to keep in mind. A snake crawls along inside one row for a while, which means it is wandering through a copy of the smaller hypercube $Q_b$. Then it hops to a neighbouring row and crawls there, then hops again. The stretches between hops are called **blocks**.

## The comb: the tidiest possible snake

Suppose a snake visits $r$ different rows. It needs at least $r - 1$ hops to reach all of them, since each hop brings in at most one new row. When can it get away with exactly $r - 1$? Only when it never goes back to a row it has already left. Each row is then visited in one unbroken stretch, and the row sequence looks like

$$\underbrace{A\,A\,A\,A}_{\text{row }A}\;\underbrace{B\,B\,B}_{\text{row }B}\;\underbrace{C\,C\,C\,C\,C}_{\text{row }C}\;\cdots$$

Drawn as a picture, this looks like the teeth of a comb, and the name stuck: a row sequence in which every row occupies a single contiguous block is a **comb**.

> **The Comb Theorem.** A row sequence that visits $r$ distinct rows makes at least $r - 1$ turns. It makes exactly $r - 1$ turns if and only if it is a comb.

The proof is a counting argument. Cut the sequence at each turn. A sequence with $t$ turns falls into $t + 1$ maximal blocks, and each block is a run of one row. Every visited row owns at least one block, so $t + 1 \ge r$. Equality holds exactly when each row owns *exactly* one block, and that is the definition of a comb.

So among all ways to visit a given set of rows, the comb uses the fewest direction changes, and it is the only arrangement that does. This is the formal sense of the phrase "turn-minimal".

## Why turns matter: the conjecture

Combs matter in practice because many of the best constructions of long snakes are *product constructions*. You take snakes in a smaller cube, lay them out as the teeth of a comb, and join them with short connectors. At each interface, where the snake hops from one row to the next, the construction sacrifices a little: roughly one connector cell per hop. The more turns a construction has, the more it loses.

That observation led to an attractive conjecture.

> **Turn-Minimal Normal Form Conjecture.** Every snake of length $L$ in $Q_n$ can be transformed into a snake of length at least $L - O(n)$ that has only $O(L/n)$ direction changes.

If true, it would justify a large practical shortcut: record searches could look only at snakes with few turns and give up at most a small, explicitly bounded amount of length.

There was also a pessimistic counter-hypothesis: *direction changes are essential to long snakes*, so any product method must give up a constant fraction of length.

Both hunches turn out to be right, in a precise sense.

## The first surprise: snakes must turn

Start with the pessimistic side. A block, meaning a stretch during which the row is constant, lies entirely inside one copy of the column cube $Q_b$. The snake rule still applies inside that block. If two corners within the block were adjacent without being consecutive, they would be adjacent in $Q_n$ too, which the rule forbids. So:

> **The Block Lemma.** Every block of a snake in a product $G \,\square\, H$ is itself a snake in the factor $H$.

So no block can be longer than the longest snake in $H$. A block of a snake in $Q_n$ contains at most $S(b) + 1$ corners. A snake with $t$ turns has $t + 1$ blocks, and the snake of length $L$ has $L + 1$ corners, so

$$L + 1 \;\le\; (t + 1)\,\bigl(S(b) + 1\bigr) \;\le\; (t+1)\, 2^{b}.$$

> **Direction Changes Are Essential.** If every snake in $H$ has length at most $S$, then every snake of length $L$ in $G \,\square\, H$ makes at least $\frac{L+1}{S+1} - 1$ turns. In particular, a snake of length $L$ in $Q_{a+b}$ changes its first $a$ coordinates at least $\frac{L+1}{2^b} - 1$ times.

A long snake cannot stay inside one row; it is forced to hop. This is a lower bound on turns, and it holds for every way of choosing the rows.

There is also an exact bookkeeping identity behind all of this. Every step changes the row or the column but never both, so

$$(\text{number of row turns}) + (\text{number of column turns}) = L.$$

We call this **step accounting**. It means the row and the column always share the snake's total length between them.

## The second surprise: the conjecture is true, and costs nothing

Now the optimistic side. Can we always find a way of looking at a snake in which it turns rarely?

Look at a single snake and count how often it flips each coordinate. Call this list of $n$ numbers the snake's **flip profile**. Every step flips exactly one coordinate, so the flip profile adds up to exactly $L$. The average coordinate is therefore flipped $L/n$ times, and *some* coordinate is flipped at most $L/n$ times.

Choose that least-flipped coordinate to be the row. The row sequence changes exactly when this coordinate flips, so the snake makes at most $L/n$ turns in the split $Q_1 \,\square\, Q_{n-1}$.

To put it in standard position, relabel the coordinates so that the chosen one comes first. Permuting coordinates is a symmetry of the hypercube: it maps edges to edges and non-edges to non-edges, so it maps snakes to snakes of exactly the same length. **The snake loses no length at all.**

The same averaging works for any number $a$ of row coordinates. Over all $\binom{n}{a}$ choices of an $a$-element row set, each coordinate belongs to a fraction $a/n$ of them, so the average number of turns is $aL/n$. Some choice does at least as well as the average.

> **The Averaging Normal Form.** For every snake of length $L$ in $Q_n$ and every $1 \le a \le n$, after a relabelling of coordinates (which preserves the length exactly), the snake's row sequence in the split $Q_a \,\square\, Q_{n-a}$ makes at most $aL/n$ turns. Combined with the lower bound,
> $$\frac{L+1}{2^{\,n-a}} - 1 \;\le\; \text{turns} \;\le\; \frac{aL}{n}.$$

For $a = 1$ this is the conjectured $O(L/n)$ bound on direction changes, with loss $0$ instead of $O(n)$.

## So what did we learn?

At first glance this looks like a triumph: the conjecture is proved, with a better constant than hoped. The honest reading is more modest, and more useful.

The conjecture is **true but cheap**. Once a "turn" is defined as a change in a chosen set of coordinates, the bound follows from averaging, and nothing about the structure of long snakes is used. Every snake, long or short, good or bad, satisfies it. A normal form that every object already satisfies does not shrink a search space.

The analysis therefore points to where the real difficulty lies. A useful normal form must say something about the **blocks**, and not only how many there are. The Block Lemma says each block is a snake of the smaller cube $Q_{n-1}$. A strong normal form would require most blocks to be *long* snakes of $Q_{n-1}$, so that the snake is built mostly from near-record pieces. That statement is not cheap, and it is now the central open question.

## What the records say

To see how real record snakes behave, we computed flip profiles of record snakes in small dimensions. The results show more structure than the averaging argument predicts.

* In $Q_5$, a longest snake (length $13$) has flip profile $(4, 3, 3, 2, 1)$. One coordinate flips **once**, so the snake is a one-turn comb in $Q_1 \,\square\, Q_4$: two snakes of $Q_4$ joined by a single hop.
* In $Q_6$, the longest snake (length $26$) found by our search has flip profile $(6, 5, 2, 5, 6, 2)$. Its least-flipped coordinate flips twice.
* In $Q_7$, a snake of length $48$ appears as a one-turn comb: one coordinate flips once, and the snake is two snakes of $Q_6$ of total length $47 = 2\cdot 26 - 5$ joined by one hop. A quick search finds a similar one-turn comb of length $47 = 25 + 1 + 21$ within seconds.

Two patterns stand out. First, the lower bound $\lceil (L+1)/(S(n-1)+1) \rceil - 1$ on the least-flipped coordinate equals $1$ in each of these cases, and the records meet it exactly for $n = 2, 3, 4, 5, 7$. The only exception is the single $26$-snake in $Q_6$, which was not chosen for this property. Second, the least-flipped coordinate is flipped at most $L/(2n)$ times in each record we examined ($13 \to 1$, $26 \to 2$, $48 \to 1$), a factor of two below what averaging guarantees.

Both patterns suggest that the best snakes really are close to combs built from very long pieces, which is the stronger normal form the analysis calls for.

## Open roads

Four conjectures come out of this work.

1. **Comb saturation.** Some longest snake in $Q_n$ has a split in which its number of turns equals the lower bound $\lceil (S(n)+1)/(S(n-a)+1)\rceil - 1$.
2. **The one-turn doubling gap.** $S(n) \ge 2S(n-1) - c$ for an absolute constant $c$, realised by one-turn combs. A one-turn comb is a pair of snakes in $Q_{n-1}$ that meet only at the hop point. This is a packing problem that SAT solvers can attack directly.
3. **Uneven flip profiles.** In every longest snake in $Q_n$ with $n \ge 5$, the least-flipped coordinate is flipped at most $L/(2n)$ times.
4. **Block-maximal normal form.** Every snake can be modified, at a cost of $O(n)$ in length, so that in some split all but $O(1)$ of its blocks have length at least $S(n-1)/2$.

The overall picture is simple to state. A snake in the hypercube can always be viewed so that it hops rarely, and this costs nothing. It can never avoid hopping entirely, since the Block Lemma forces it to. What remains open is whether the pieces between the hops can always be made long.
