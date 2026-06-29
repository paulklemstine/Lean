# When Can a Tangled Graph Be Untangled? The Hidden Arithmetic of Biased Graphs

## A puzzle about consistency

Imagine you are handed a map of cities connected by roads, but with a twist. Along every road someone has written a number. As you walk around any closed loop in this map, you add up the numbers — but with a sign: forward along a road you add its number, backward you subtract it. Some loops, when you go all the way around and return home, total to zero. Others do not.

Now turn the puzzle around. Suppose you are *not* given the numbers. Instead, a referee simply tells you, for each closed loop, whether it is "balanced" or "unbalanced." Your job is to *invent* numbers on the roads so that the loops the referee called balanced are exactly the ones that sum to zero, and the unbalanced loops are exactly the ones that don't.

Sometimes you can. Sometimes, no matter how cleverly you choose, you cannot. The deep question is: **when is it possible, and what stops you when it isn't?**

This is the theory of *biased graphs* and *gain labellings*, and it sits at a surprising crossroads of graph theory, group theory, and the abstract study of "matroids." This article tells the story of a clean, complete answer to one important slice of the puzzle — an answer that turns out to depend, in a beautiful and unexpected way, on the *arithmetic* of the number system you are allowed to use.

## The cast of characters

Let us make the puzzle precise, because the precision is where the magic hides.

A **graph** is a collection of edges; a **closed walk** is a sequence of edges that starts and ends at the same place, each traversed in some direction (forward or backward). A **biased graph** is a graph in which we have additionally declared, for each closed walk that forms a genuine cycle, whether it is *balanced* or *unbalanced*. You should think of "balanced" as meaning "consistent" and "unbalanced" as meaning "there is a built-in contradiction here."

A **gain labelling** chooses, for each edge $e$, a value $g(e)$ drawn from some number system $A$ that you can add and subtract. The **gain of a cycle** is the signed sum around it:
$$\text{signedSum}(g, c) = \sum_{\text{edge } e \text{ in } c} \pm\, g(e),$$
where the sign is $+$ if the edge is traversed forward and $-$ if backward.

We say the labelling **realises** the biased graph when, for every cycle $c$,
$$c \text{ is balanced} \iff \text{signedSum}(g, c) = 0.$$
And we say the biased graph is **gainable over $A$** when *some* such labelling exists. When the number system is the cyclic group of integers modulo $n$ — clock arithmetic with $n$ hours, written $\mathbb{Z}/n$ — we simply say the graph is $\mathbb{Z}/n$-**gainable**.

The choice of number system matters enormously. Working modulo $2$ you have only the values $\{0, 1\}$; modulo $12$ you have a clock face with twelve positions. A graph that refuses to be untangled on a $2$-hour clock might untangle perfectly on a $12$-hour clock. Pinning down exactly which graphs work on which clocks is the heart of the matter.

## The simplest obstruction: too many roads between two towns

The cleanest source of trouble is also the most intuitive. Picture just two towns joined by several parallel roads. Two such roads, say road $i$ traversed out and road $j$ traversed back, form a loop — a **digon**. In our setting we declare every such two-road loop *unbalanced*: the two roads are genuinely different, so going out on one and back on another should never "cancel."

For the labelling to honour this, every pair of roads must carry *different* numbers — because if roads $i$ and $j$ had the same label, the out-and-back loop would sum to $g(i) - g(j) = 0$, falsely marking it balanced. So all the road labels must be **distinct** elements of the number system.

Here is the punchline. On an $n$-hour clock there are only $n$ distinct values. So if there are $n+1$ parallel roads, the pigeonhole principle forbids a valid labelling outright: you cannot fit $n+1$ different values into $n$ slots. This configuration — $n+1$ parallel edges between two vertices, with all digons unbalanced — is written $(n{+}1)K_2$, and it is the canonical "thing that cannot be untangled" modulo $n$.

In the formal development this is the theorem **`parallelEdges_not_gainable`**: for every $n \ge 2$, the biased graph $(n{+}1)K_2$ is not $\mathbb{Z}/n$-gainable. The proof is exactly the pigeonhole argument above, made airtight. A subtle but important point: the *prior* version of this result, in the literature and in earlier formal work, was stated only for *prime* moduli $p$. One of the contributions of the work described here is the realization that **primality is a red herring**. The pigeonhole obstruction never uses any arithmetic fact about $n$ beyond "there are exactly $n$ values." It holds for every $n \ge 2$, prime or composite.

## Minors: obstructions that hide inside bigger graphs

A single forbidden configuration is not enough, because trouble can be *embedded*. A large, complicated biased graph might contain $(n{+}1)K_2$ hidden inside it — and if it does, it inherits the impossibility.

The right notion of "contains a copy of" here is the **minor** relation. Informally, $H$ is a minor of $G$ if you can find $H$ sitting inside $G$ after deleting some edges, identifying others, and possibly flipping orientations — all while respecting which cycles are balanced. The formal model captures this as an injection of $H$'s edges into $G$'s edges, together with a per-edge orientation switch, that carries cycles to cycles and matches balance.

The crucial structural fact is that **gainability is inherited by minors**. If you can untangle $G$ on an $n$-hour clock, then you can untangle any minor $H$ of $G$ as well — you simply *pull back* the labelling along the embedding, negating the labels of the flipped edges. This is the theorem **`gainableBy_of_isMinor`**, and it rests on a small but essential computation, **`signedSum_mapCycle`**, showing that the signed sum of a transported cycle equals the signed sum computed with the pulled-back labels.

Combining the two facts gives a clean necessity statement, **`not_isMinor_parallelEdges_of_gainable`**: any $\mathbb{Z}/n$-gainable biased graph — of *any* shape whatsoever — contains no $(n{+}1)K_2$ minor. If it did, that minor would have to be gainable too, and we just proved it can't be.

## The full conjecture, and the slice that is now nailed down

So forbidding $(n{+}1)K_2$ is *necessary*. Is it *sufficient*? Not quite, in full generality. The complete conjecture — due in spirit to Zaslavsky and Funk — predicts that exactly **three** families of forbidden minors govern $\mathbb{Z}/n$-gainability:

> **Conjecture.** For every $n \ge 2$, a biased graph is $\mathbb{Z}/n$-gainable if and only if it contains none of the minors $(n{+}1)K_2$, $\pm K_3$, or $-K_4$.

The first, $(n{+}1)K_2$, is the parallel-roads obstruction we have met. The other two, $\pm K_3$ and $-K_4$, are subtler signed-graph configurations built from triangles and tetrahedra; they encode contradictions that live not in any single loop but in the way several triangles *share* vertices. Crucially, these two are *fixed* — they do not grow with $n$.

The work described here settles, completely and rigorously, the **parallel-class slice** of this conjecture. A *parallel class* is a biased graph in which every edge joins the same two vertices — so the only cycles are digons, and "balanced" is governed by an equivalence relation $s$ grouping the roads into classes. For these graphs the answer is exact and elegant:

> **Theorem (`digon_excluded_minor`).** A parallel-class biased graph is $\mathbb{Z}/n$-gainable if and only if it contains no $(n{+}1)K_2$ minor.

The proof goes through a single illuminating quantity: the number of balance classes. A parallel-class graph is gainable precisely when its number of classes is at most $n$ (theorem **`digon_gainable_iff_card`**) — you simply assign a different clock value to each class. And it contains a $(n{+}1)K_2$ minor precisely when it has *at least* $n+1$ classes (theorem **`digon_isMinor_iff_card`**). These two thresholds are complementary: "at most $n$" is the exact negation of "at least $n+1$." The characterization falls out immediately. For this whole family, the single excluded minor $(n{+}1)K_2$ tells the entire story — and it does so for every modulus $n \ge 2$, with no appeal to primality.

## The arithmetic twist: bigger clocks untangle more graphs

The most striking discovery is a law connecting *different* clocks to one another. Intuitively, a bigger clock should be more forgiving — it has more values, so more graphs should be untangleable. But "bigger" turns out to mean something precise and number-theoretic: not bigger in size, but bigger in *divisibility*.

> **Divisibility Law (`gainable_mono_of_dvd`).** If $m$ divides $n$, then every $\mathbb{Z}/m$-gainable biased graph is also $\mathbb{Z}/n$-gainable.

Why divisibility rather than mere size? Because the proof works by *embedding* one clock faithfully inside another. When $m$ divides $n$, there is an injective, structure-preserving map from the $m$-hour clock into the $n$-hour clock: send the value $j$ to $j \cdot (n/m)$. For instance, the $3$-hour clock embeds into the $12$-hour clock by $0,1,2 \mapsto 0,4,8$. This map preserves addition perfectly, so any labelling that works modulo $m$ can be transported, value by value, into a labelling that works modulo $n$. The existence of this embedding is the lemma **`exists_injective_zmod_addHom_of_dvd`**.

And this is a special case of something even more general. The transport argument never really needs cyclic groups at all. It works for *any* injective addition-preserving map between *any* two number systems — the theorem **`gainableBy_of_injective_hom`**: if there is an injective homomorphism from $A$ into $B$, then every $A$-gainable graph is $B$-gainable. The cyclic divisibility law is just this general principle, specialized. The engine underneath is the modest-looking identity **`signedSum_addHom`**: applying a homomorphism to every label and then summing gives the same answer as summing first and then applying the homomorphism. Sums and homomorphisms commute, and from that single fact the entire transport theory flows.

What this reveals is a hidden organizing structure. The collection of clocks $\mathbb{Z}/n$, ordered by divisibility, forms a lattice — and the map sending each clock to "the set of graphs it can untangle" *respects* that lattice, climbing monotonically as you climb the divisibility order. The dependence of gainability on $n$ is not a chaotic, prime-by-prime affair; it is governed cleanly by the factorization structure of $n$.

## Why this matters beyond the puzzle

Biased graphs are not a curiosity. They are the combinatorial skeleton of two large theories. First, they generalize **signed graphs** — graphs whose edges carry $+$ or $-$ signs, the natural language for modelling systems of agreements and conflicts, frustration in physical spin systems, and balance in social networks. Whether a signed network can be "untangled" is precisely whether it can be split into two mutually consistent camps; gainability over richer groups generalizes this consistency question to many-valued settings.

Second, biased graphs are the source of **frame matroids** and **Dowling geometries**, central objects in matroid theory that interpolate between graphs and vector spaces. Excluded-minor characterizations are the gold standard of structural mathematics — the same kind of result as Kuratowski's theorem (a graph is planar iff it avoids two forbidden minors) or the monumental Robertson–Seymour theory. To say "object $X$ has property $P$ iff it avoids this finite list of forbidden patterns" is to convert an infinitude of cases into a finite, checkable test.

The story told here delivers exactly such a test for an important family, and pins down the arithmetic that drives it:

- The "counting" obstruction $(n{+}1)K_2$ is **uniform in $n$** and **independent of primality** — it is pure pigeonhole.
- For parallel-class graphs that single obstruction is the *whole* answer, via the threshold "at most $n$ classes."
- Gainability is **monotone under divisibility** of the modulus, organized by a transparent group-embedding mechanism.

What remains open is sharply isolated: the two fixed geometric obstructions $\pm K_3$ and $-K_4$, which require a richer model that tracks how triangles share vertices — information the loop-only picture deliberately discards. The frontier is no longer a moving, $n$-dependent target; it is two specific small graphs. That is exactly the kind of clarity that turns a sprawling conjecture into a solvable problem.

## The shape of the answer

Step back and the narrative arc is satisfying. We started with a homely puzzle — invent road numbers to match a referee's verdicts about loops. We found the simplest impossibility (too many parallel roads), promoted it to a robust obstruction that survives embedding (minors), and discovered that for an entire natural family of graphs it is the *complete* explanation. Along the way the number system stopped being a passive backdrop and became the protagonist: the arithmetic of $n$, through its divisors, quietly choreographs which graphs can be untangled and which cannot.

There is a lesson here that recurs across mathematics. The first proof of a fact often carries extra baggage — here, the assumption that $n$ is prime. Stripping that baggage away does not merely generalize the result; it *clarifies* it, revealing that the real content was a counting principle all along, and exposing a clean monotonicity law that the prime-only view could never have seen. Sometimes the way to understand a theorem better is to ask how little you actually need to prove it.
