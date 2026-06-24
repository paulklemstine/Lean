# Counting Without Crowding: How Forbidden Patterns Tame a Graph

## A party problem that never gets old

Imagine a vast social network — a million people, each pair either acquainted or not. A sociologist wants to count the *tightly knit cliques* of a particular shape inside it. Not triangles, not random clusters, but a very specific committee structure: three organizers, each of whom personally knows every one of a fixed panel of, say, five advisors. How many such committees can possibly exist?

If the network is allowed to be arbitrarily dense, the answer is boring: pack everyone together and the count explodes. The interesting science begins the moment we forbid one kind of structure. Suppose no three people in the whole network ever share a panel of $t$ common acquaintances — a "no-three-share-$t$-friends" rule. How much does this single prohibition constrain the total number of committees of *every other* shape?

This is the heart of **extremal graph theory**: the study of how forbidding one local pattern forces global scarcity. The surprising answer in the case we study here is sharp and clean. Forbidding the small bipartite pattern $K_{3,t}$ — three vertices jointly adjacent to $t$ others — caps the number of copies of the much larger bipartite pattern $K_{a,b}$ at roughly $n^3$, where $n$ is the number of people. Not $n^4$, not $n^5$, but exactly cubic growth, no matter how large $a$ and $b$ are. The "3" in $n^3$ is not an accident of the proof. It is the literal "3" inside $K_{3,t}$, fossilized in the answer.

## The cast of characters

Let us fix vocabulary, because precision is where the beauty lives.

A **graph** $G$ is a set of $n$ vertices (people) together with a symmetric, irreflexive adjacency relation (acquaintance). The **complete bipartite graph** $K_{a,b}$ is the pattern consisting of two disjoint groups, one of size $a$ and one of size $b$, with *every* cross pair between the groups adjacent and no constraint within either group. A **copy of $K_{a,b}$** inside $G$ is a labelled pair $(A,B)$ of disjoint vertex sets with $|A|=a$, $|B|=b$, such that every $u\in A$ is adjacent to every $v\in B$.

The forbidden pattern is $K_{3,t}$: three vertices on one side, $t$ on the other, all cross edges present. We say $G$ is **$K_{3,t}$-free** if no such configuration exists anywhere inside it:
$$\neg\,\exists\, A,B:\ |A|=3,\ |B|=t,\ A\cap B=\varnothing,\ \forall u\in A,\ \forall v\in B,\ u\sim v.$$

The quantity we want to understand is the **generalized Turán number**
$$\mathrm{ex}(n, K_{a,b}, K_{3,t}) = \max\{\,\#\text{ copies of } K_{a,b} \text{ in } G : G \text{ has } n \text{ vertices and is } K_{3,t}\text{-free}\,\}.$$
This is the Alon–Shikhelman generalization of the classical Turán problem, which asked only about *edges* (copies of $K_{1,1}$). Here we count copies of a large structure inside a graph that avoids a small one. The main result is that this maximum grows like $n^3$.

## The one idea that makes it work: common neighborhoods

Every deep counting argument in this corner of mathematics rests on a single, almost childishly simple observation. For a set $S$ of vertices, its **common neighborhood** is the set of vertices adjacent to *all* of them:
$$N(S) = \{\,w : \forall u\in S,\ u\sim w\,\}.$$

Two facts about common neighborhoods drive everything.

First, **common neighborhoods shrink as you demand more**. If you enlarge the set $S$, you impose more adjacency requirements, so fewer vertices can satisfy all of them. Formally, if $S\subseteq T$ then $N(T)\subseteq N(S)$. Antitone — the bigger the demand, the smaller the supply.

Second — and this is where the prohibition bites — **being $K_{3,t}$-free is exactly the same as capping every triple's common neighborhood at $t-1$**. If some three vertices $S$ had $t$ common neighbors, those three plus those $t$ would form a forbidden $K_{3,t}$. Conversely, a forbidden $K_{3,t}$ is precisely a triple with $t$ common neighbors. So the abstract prohibition translates into a hard, quantitative ceiling:
$$\text{$G$ is $K_{3,t}$-free} \iff \forall S,\ |S|=3 \Rightarrow |N(S)| \le t-1.$$
This equivalence (call it the *common-neighborhood reformulation*) is the bridge between a logical statement ("no such pattern exists") and an arithmetical one ("this number is at most $t-1$"). Once you have a number to push around, you can count.

A small but useful refinement: because common neighborhoods are antitone, the cap extends from triples to *any* set of size at least three. A set $B$ with $|B|\ge 3$ contains a triple $S$, and $N(B)\subseteq N(S)$, so $|N(B)|\le t-1$ too. Demanding adjacency to three or more people already pins you inside a bounded pool.

## The double count: anchoring on a triple

Now we count copies of $K_{a,b}$. The strategy is the oldest trick in combinatorics — count the same thing two ways — executed with a clever choice of *anchor*.

Here is the picture. Take any copy $(A,B)$ of $K_{a,b}$. The side $A$ has $a\ge 3$ vertices, so it contains at least one triple $S\subseteq A$. We are going to organize all copies by which triple sits inside their $A$-side.

**Step 1 — the fiber bound.** Fix one triple $S$. How many copies $(A,B)$ can have $S\subseteq A$? Every vertex of $B$ is adjacent to all of $A$, hence to all of $S$, so $B\subseteq N(S)$. The ceiling says $|N(S)|\le t-1$, so $B$ is a $b$-subset of a pool of size at most $t-1$: at most $\binom{t-1}{b}$ choices. Having chosen $B$, every vertex of $A\setminus S$ is adjacent to all of $B$, so $A\setminus S\subseteq N(B)$; since $|B|=b\ge 3$, the ceiling applies again and $|N(B)|\le t-1$, giving at most $\binom{t-1}{a-3}$ choices for the remaining $a-3$ vertices. The map $(A,B)\mapsto (A\setminus S,\, B)$ is injective on this family, so
$$\#\{\text{copies with } S\subseteq A\}\ \le\ \binom{t-1}{b}\binom{t-1}{a-3}.$$
A constant. Independent of $n$. That is the entire miracle, compressed into one inequality.

**Step 2 — sum over anchors.** Every copy is counted at least once across all triples $S$, because its $A$-side contains at least $\binom{a}{3}\ge 1$ triples. Summing the fiber bound over all $\binom{n}{3}$ triples of the whole graph:
$$\#\text{ copies of } K_{a,b}\ \le\ \binom{n}{3}\,\binom{t-1}{b}\binom{t-1}{a-3}.$$
And since $\binom{n}{3}\le n^3$, this is
$$\boxed{\ \#\text{ copies of } K_{a,b}\ \le\ \binom{t-1}{b}\binom{t-1}{a-3}\cdot n^3\ } $$
a clean cubic bound. The leading constant depends only on the three small parameters $a$, $b$, $t$ — never on the size of the network. This is the main theorem.

Notice what the proof reveals about *why* the exponent is three. The three vertices of the anchor $S$ are the only "free" vertices; every other vertex of the copy — all $a+b-3$ of them — is forced into a bounded common neighborhood and contributes only a constant factor. The exponent counts the vertices that escape the ceiling, and the ceiling is a property of triples. Change the forbidden pattern from $K_{3,t}$ to $K_{s,t}$ and the exponent would change to $s$. The shape of the prohibition dictates the shape of the answer.

## The threshold: a story about parity

There is a subtle question hiding in plain sight: *how large must $t$ be for any of this to be non-trivial?* If $t$ is tiny, $\binom{t-1}{b}=0$ and the bound says there are zero copies — true but uninteresting, because $K_{a,b}$ itself contains a $K_{3,t}$ and cannot appear at all. The arithmetic only becomes meaningful once $t$ is large enough that a $K_{a,b}$ can coexist with $K_{3,t}$-freeness. The natural cutoff is the **necessary threshold** $t = b+1$: any smaller and a single $K_{a,b}$ already hides a forbidden $K_{3,t}$.

At exactly this threshold, something elegant happens to the leading constant. With $t-1 = b$, the factor $\binom{t-1}{b} = \binom{b}{b} = 1$ collapses, and the whole constant simplifies to
$$\binom{t-1}{b}\binom{t-1}{a-3}\ \longrightarrow\ \binom{b}{a-3}.$$
The bound becomes as lean as possible.

The deeper story concerns the gap between what is *provable by current heavy machinery* and what is *conjecturally necessary*. The state-of-the-art lower-bound construction (a theorem of Janzer–Longbrake–Yepremyan) guarantees the matching $\Theta(n^3)$ growth only when $t$ is at least the **proved threshold** $2\max\{3,\lceil b/2\rceil\}+1$. For $b\ge 6$ this expression simplifies, by a one-line parity computation, to
$$2\max\{3,\lceil b/2\rceil\}+1 = b + 1 + (b \bmod 2).$$
Compare this to the necessary threshold $b+1$. The two coincide **exactly when $b$ is even** — the proved bound already lands on the necessary one. When $b$ is **odd**, the proved threshold overshoots by precisely one. The entire remaining frontier of the problem is this single off-by-one, governed by nothing more than the parity of $b$:
$$\text{necessary threshold} < \text{proved threshold} \iff b \text{ is odd}.$$
A whole research conjecture distilled to a question about even versus odd. The upper bound proved here, by contrast, is *parity-blind*: it holds at the necessary threshold for every $b$, even or odd. The asymmetry between the easy upper direction and the delicate lower direction is exactly where the mathematics is still alive.

## Why deletion never breaks the bound

A final, very practical virtue of this kind of theorem is its **robustness under deletion**. Suppose you have a $K_{3,t}$-free network and you start removing edges — perhaps modelling unreliable connections, or a "cleaning" step that strips away rare configurations. Does the cubic bound survive?

It does, and the reason is structural rather than computational. Removing edges only *shrinks* common neighborhoods: if $G$ is a subgraph of $G'$ (written $G\le G'$), then $N_G(S)\subseteq N_{G'}(S)$ for every set $S$. Three consequences cascade from this:

- **Freeness is inherited downward.** A subgraph of a $K_{3,t}$-free graph is itself $K_{3,t}$-free — you cannot create a forbidden pattern by deleting edges.
- **The ceiling can only fall.** Common-neighborhood sizes are monotone: $|N_G(S)|\le |N_{G'}(S)|$.
- **The whole bound transfers.** If $G\le G'$ and $G'$ is $K_{3,t}$-free (at the threshold $t\ge b+1$), then $G$ obeys the *same* cubic bound $\binom{t-1}{b}\binom{t-1}{a-3}\cdot n^3$ — with the identical constant.

This is *downward closure*: the cubic estimate, proved once for the dense extremal graph, is automatically true for every subgraph living beneath it in the partial order of graphs. In the language of deletion arguments, the surviving graph after any cleaning step is guaranteed to inherit the count — you never have to re-run the hard double-count. The expensive theorem is proved at the top of the order and rains down on everything below.

## The bigger picture

What makes this little corner of mathematics so satisfying is how a single quantitative idea — *cap the common neighborhood of a triple* — propagates through every layer of the theory. It turns a logical prohibition into a number; the number feeds a double count; the double count yields a cubic law; the cubic law's constant collapses at the natural threshold; the threshold's only mystery is a parity gap; and the entire result, once proved, is stable under deletion by sheer monotonicity.

Extremal graph theory is, at bottom, the science of how local rules become global laws. Forbid three people from ever sharing too many friends, and you have — whether you intended to or not — limited the number of every committee in the network to grow no faster than the cube of its population. The crowd polices itself, and the proof fits on a page.
