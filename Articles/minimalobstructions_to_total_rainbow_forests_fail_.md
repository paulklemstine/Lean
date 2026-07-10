# The Obstruction That Refuses to Shrink

## A puzzle about colored graphs

Imagine you are handed a network — a collection of dots (call them *vertices*) joined by lines (call them *edges*). Every edge has been painted some color. Your job is to pick out a set of edges that satisfies two demands at once.

First, the edges you pick must form a **forest**: no closed loops allowed. A forest is what you get when you connect things together without ever creating a redundant cycle — the skeleton of a road map with no roundabouts, the wiring of a circuit with no short-circuit loops.

Second, the edges you pick must be **rainbow**: no two of them may share a color. Every edge in your chosen set is a different hue.

A set of edges that is *both* a forest *and* rainbow is called a **total rainbow forest**. The central question is deceptively simple:

> How large a total rainbow forest can we find?

This is not an idle game. It is a template for an enormous family of real problems. Colors can encode *categories*, *time slots*, *frequencies*, or *owners*; the forest condition encodes *no redundancy* or *no conflict*. Scheduling, network design, and resource allocation all secretly ask this question.

## Two hidden structures

The magic begins when we notice that each of the two demands is not just a rule, but a rich mathematical object called a **matroid** — an abstract structure that captures the essence of "independence."

The forest condition gives us the **graphic matroid**. Here a set of edges is "independent" precisely when it contains no cycle. Attached to it is a *rank function* $r_1$: for any set of edges $A$, the number $r_1(A)$ is the size of the largest forest hiding inside $A$.

The rainbow condition gives us a **partition matroid**. A set of edges is "independent" here when it uses each color at most once. Its rank function $r_2(A)$ counts how many distinct colors appear among the edges of $A$.

A total rainbow forest is exactly a set that is independent in *both* matroids simultaneously — what mathematicians call a **common independent set**. And finding the largest common independent set of two matroids is one of the crown jewels of combinatorial optimization, solved by **Edmonds' Matroid Intersection Theorem**.

## The min–max miracle

Edmonds' theorem is a *min–max* identity, and it is genuinely beautiful. It says that the largest total rainbow forest you can build is controlled by a single elegant quantity. For any way of splitting the edge set $E$ into a part $A$ and its complement $A^c = E \setminus A$, define the **objective**

$$\mathrm{obj}(A) = r_1(A) + r_2(A^c).$$

Read this out loud: "the biggest forest I can fit inside $A$, plus the number of distinct colors available outside $A$." Edmonds' theorem states:

$$\max_{\text{total rainbow forests } I} |I| \;=\; \min_{A \subseteq E} \; \mathrm{obj}(A).$$

The largest achievable equals the smallest allowable. Every subset $A$ is a *certificate*: it hands you an upper bound $\mathrm{obj}(A)$ on how big a rainbow forest can ever be, and the theorem promises that some certificate is perfectly tight.

The **easy half** of this identity — the part called *weak duality* — is a small gem in its own right, and it is worth seeing why it is true. Suppose $I$ is any total rainbow forest, and let $A$ be any subset of edges. Split $I$ into the part inside $A$ and the part outside:

$$|I| = |I \cap A| + |I \setminus A|.$$

The first piece, $I \cap A$, is a forest sitting inside $A$, so it can be no larger than the biggest forest in $A$: $|I \cap A| \le r_1(A)$. The second piece, $I \setminus A$, is a rainbow set sitting outside $A$, so it uses at most as many colors as are available there: $|I \setminus A| \le r_2(A^c)$. Add the two inequalities:

$$|I| \le r_1(A) + r_2(A^c) = \mathrm{obj}(A).$$

That's it. Every rainbow forest is capped by every certificate. In particular, if you can ever exhibit a total rainbow forest of size $t$, then automatically $t \le \mathrm{obj}(A)$ for *all* $A$ — a fact we'll call the **Rainbow Forest Inequality** at target $t$.

## Obstructions

Now flip the question around. Sometimes you *want* a total rainbow forest of a certain size $t$ and you *cannot* get one. The graph is an **obstruction**: there exists some subset $A$ with $\mathrm{obj}(A) < t$. That single subset is a "smoking gun" — an unavoidable bottleneck that keeps the rainbow forest small.

This is where the story gets interesting, because it invites an irresistible instinct that every mathematician and engineer shares: **to look for the *smallest* obstruction.** If a network fails, surely there is a minimal core of trouble — a tightest, most essential reason for failure, with everything else stripped away. In graph theory this instinct usually pays off spectacularly; whole theories (forbidden minors, critical graphs) are built on minimal obstructions.

The most natural way to shrink an obstruction is to **delete an edge**. Call a graph an *edge-minimal obstruction* if it fails to have a rainbow forest of size $t$, but *every* single-edge deletion $G - e$ succeeds. Such a graph would be a perfectly balanced culprit: guilty as a whole, innocent the moment any part is removed.

The conjecture that launched this investigation hoped that such minimal obstructions would be beautifully rigid — that each one would fail the Rainbow Forest Inequality for *exactly one* subset $A$, a unique fingerprint of failure.

## The twist: minimal obstructions do not exist

Here is the surprise. **For matroids, edge-minimal obstructions cannot exist at all.** The seductive instinct fails completely, and it fails for a clean, structural reason.

The key is a monotonicity fact about deletion. When you delete an edge $e$, the objective can only go *down*, never up. Precisely, for any subset $A$, the deleted graph's objective at the corresponding subset satisfies

$$r_1(A \setminus \{e\}) + r_2\big((E \setminus \{e\}) \setminus (A \setminus \{e\})\big) \le \mathrm{obj}_G(A).$$

The reason is again elementary: removing $e$ can only shrink the forest you fit inside $A$ (so the first term drops or stays), and it can only shrink the pool of colors available outside (so the second term drops or stays). Deletion never helps.

The consequence is devastating for the minimal-obstruction dream. Suppose some subset $A$ certifies that $G$ is an obstruction, meaning $\mathrm{obj}_G(A) < t$. Then after deleting *any* edge $e$, the inequality above hands us a subset of $G - e$ whose objective is still below $t$. **The obstruction survives the deletion.** Every child $G - e$ is still an obstruction. Turned around: if even a *single* deletion $G - e$ managed to satisfy the Rainbow Forest Inequality, then $G$ would have satisfied it too — so $G$ was never an obstruction in the first place.

Put these together and the notion of an edge-minimal obstruction is self-contradictory. You cannot have a graph that fails while all its deletions succeed, because failure is inherited downward without exception. There is no minimal culprit, because the trouble can never be localized by removing edges — it only ever spreads.

## Why the dream fails — and what replaces it

This is a *root-cause* explanation, and it is oddly satisfying. The original conjecture asked about the "unique failing subset" of a minimal obstruction. But you cannot discuss the unique fingerprint of an object that does not exist. The uniqueness question was ill-posed from the start, not because uniqueness is subtle, but because its subject — the edge-minimal obstruction — is a phantom.

To make sure this is a real theorem about real objects and not an empty logical trick, one can exhibit an honest, concrete obstruction on the tiniest possible stage: a two-edge ground set. There, a genuine subset drives the objective below the target, the inequality genuinely fails, and — exactly as the theorem predicts — every deletion inherits a failing subset of its own. The phenomenon is real, not vacuous.

So what *does* survive of the original dream? A great deal, once we ask the right question. Instead of shrinking obstructions by deletion, we can study, for a *fixed* obstruction, the family of all subsets $A$ that certify its failure. That family is far from arbitrary. Because the objective $\mathrm{obj}(A)$ is a **submodular** function — the discrete analogue of a convex function — its minimizers form a **lattice**: closed under taking unions and intersections. This means there is always a unique *smallest* certificate and a unique *largest* certificate of failure, nested one inside the other, even though there can be many certificates in between.

That is the true shape of the answer. Naive uniqueness — "exactly one failing subset" — is false. But it is replaced by something more structured and arguably more elegant:

> The failing subsets of a tight obstruction form a lattice with a unique minimal and maximal certificate, while edge-minimal obstructions do not exist at all.

## The moral

The most valuable results in mathematics are often the ones that redirect a question. We set out to find the smallest reason a colored network fails to hold a large rainbow forest, expecting a delicate uniqueness theorem. We found instead that "smallest reason via deletion" is a mirage: failure is monotone, obstructions are contagious, and no minimal obstruction can exist.

But in ruling out the phantom, we uncovered the genuine structure — the lattice of certificates, guaranteed by the deep convex-like geometry of matroid rank. The lesson is one every scientist eventually learns: sometimes proving that the door you were pushing on is a wall is exactly what reveals the door that was open all along.
