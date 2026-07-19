# Counting the Impossible Away

## How finite arithmetic turns chance into existence

Imagine coloring every connection among a group of people either red or blue. Red might mean that two people know one another; blue might mean that they do not. Must a large enough gathering contain a sizeable group whose every internal connection has the same color?

Ramsey theory says yes. Yet its most revealing arguments often proceed in the opposite direction: they show that a surprisingly large network can avoid such order. The trick is not to draw the network cleverly. It is to count all drawings at once.

That trick belongs to the **probabilistic method**. Its characteristic sentence is almost paradoxical: choose an object at random, prove that failure has probability less than one, and conclude that a successful object exists. Chance is used as a telescope, not as a source of uncertainty. Once positive probability has been established, at least one concrete object must lie inside the finite universe being counted.

The results developed here expose the finite machinery beneath that sentence. They establish an exact counting criterion for avoiding monochromatic cliques, a general survivor principle for finite families of forbidden sets, and a sharp family of triangle-free graphs at the opposite edge of extremal graph theory. Together they show how avoidance and maximization can be understood as two views of the same combinatorial landscape.

## A universe of colorings

Write $K_n$ for the complete graph on $n$ vertices: every pair of vertices is joined by an edge. It has

$$
\binom{n}{2}
$$

edges. A red-blue coloring therefore amounts to making one binary choice for each edge, so the number of colorings is exactly

$$
2^{\binom{n}{2}}.
$$

A set of $k$ vertices spans a copy of $K_k$. How many colorings make that copy entirely red? Its $\binom{k}{2}$ internal edges are forced to be red, while every other edge remains free. Hence there are

$$
2^{\binom{n}{2}-\binom{k}{2}}
$$

such colorings. The same count applies to an entirely blue copy.

There are $\binom{n}{k}$ choices for the vertex set. If we add the sizes of all red and blue failure classes, we may count some colorings more than once, but that only makes our estimate larger. Thus the number of bad colorings is at most

$$
2\binom{n}{k}2^{\binom{n}{2}-\binom{k}{2}}.
$$

If this is smaller than the total number of colorings, some coloring is not bad. Cancelling the common power of two yields the central criterion.

**Ramsey Counting Theorem.** If $k\le n$ and

$$
2\binom{n}{k}<2^{\binom{k}{2}},
$$

then the edges of $K_n$ admit a red-blue coloring containing no monochromatic copy of $K_k$. Equivalently, the diagonal Ramsey number satisfies $R(k,k)>n$.

This is the probabilistic method with the probability language removed. Every object is finite, every class is explicitly countable, and existence follows because the union of all failure classes does not fill the universe.

A convenient, though weaker, version uses $\binom{n}{k}\le n^k$.

**Power Criterion.** If $k\le n$ and

$$
2n^k<2^{\binom{k}{2}},
$$

then $R(k,k)>n$.

For $k=10$ and $n=16$, the left side is $2\cdot16^{10}=2^{41}$, while the right side is $2^{45}$. Therefore:

**Concrete Ramsey Bound.** There is a red-blue coloring of $K_{16}$ with no monochromatic $K_{10}$; in particular,

$$
R(10,10)>16.
$$

This does not exhibit the coloring directly. It says something subtler: among the $2^{120}$ possible colorings, the forbidden ones cannot occupy the whole space. Exhaustive search could, in principle, find a survivor. Random sampling offers another search strategy, although the theorem itself makes no runtime promise.

## The anatomy of survival

The same logic can be abstracted away from graphs. Let $\Omega$ be a nonempty finite set of outcomes, let $I$ be a finite index set, and let $B_i\subseteq\Omega$ be the bad outcomes associated with constraint $i$. For a set $S\subseteq I$ of constraints already imposed, define the survivor set

$$
\operatorname{Surv}(S)=\{\omega\in\Omega:\omega\notin B_i\text{ for every }i\in S\}.
$$

Adding a constraint simply filters the current survivors:

$$
\operatorname{Surv}(S\cup\{i\})
=
\{\omega\in\operatorname{Surv}(S):\omega\notin B_i\}.
$$

This identity supports a clean induction.

**Finite Conditional-Avoidance Theorem.** Suppose $\Omega$ is nonempty and, whenever $S\subseteq I$, $i\notin S$, and $\operatorname{Surv}(S)$ is nonempty, the newly forbidden portion is strictly smaller than the current survivor set:

$$
|\operatorname{Surv}(S)\cap B_i|<|\operatorname{Surv}(S)|.
$$

Then some $\omega\in\Omega$ avoids every bad set $B_i$.

The proof is almost visual. Begin with all outcomes alive. Add constraints one at a time. At each step, the next bad set removes fewer than all current survivors, so at least one remains. Because there are finitely many constraints, the process ends with an outcome that survives them all.

This theorem is a useful interface. Difficult applications can separate into two jobs: first prove a numerical statement saying that each new bad event cannot consume the entire conditional survivor population; then invoke finite induction. The celebrated Lovász local lemma seeks exactly this kind of conclusion from dependency and probability estimates. The present result is not the full local lemma: it does not derive the survivor-ratio estimate from bounds such as $e p(d+1)\le1$, and it gives no resampling runtime. What it does is identify precisely the finite combinatorial engine that such estimates must drive.

## The opposite question: how dense can avoidance be?

Ramsey counting searches a vast space for an object avoiding many local patterns. Turán theory fixes one graph and asks how many edges it can retain while avoiding a clique.

The simplest sharp case is Mantel’s theorem: a triangle-free graph on $N$ vertices has at most $N^2/4$ edges. When $N=2m$, split the vertices into two groups of $m$ and connect every vertex in one group to every vertex in the other. The resulting complete bipartite graph has no triangle, because any three vertices place two vertices in the same group, where no edge exists. Its edge count is $m^2$.

**Balanced Turán Sharpness Theorem.** For every natural number $m$, the balanced complete bipartite graph on $2m$ vertices is triangle-free and has exactly $m^2$ edges. Equivalently,

$$
4|E|=(2m)^2.
$$

Thus the graph attains the Mantel ceiling exactly.

The two stories have opposite moods. Ramsey theory says the forbidden configurations do not cover all colorings. Turán theory says a forbidden configuration imposes an exact ceiling on edge density, and a balanced partition reaches it. Yet both are controlled by finite cardinalities. In one case we count a union of bad cylinders in a Boolean cube. In the other we count the edges supported between parts.

The results combine in a particularly concrete statement.

**Ramsey–Turán Synthesis.** There exists a red-blue coloring of $K_{16}$ with no monochromatic $K_{10}$; simultaneously, for every $m$, the balanced complete bipartite graph on $2m$ vertices is triangle-free and has exactly $m^2$ edges.

The word “simultaneously” does not claim a mysterious direct implication between the two graphs. It emphasizes a shared finite philosophy: constraints can be handled either by showing that some outcome remains outside their union or by organizing a structure that reaches the maximal size permitted by them.

## Algorithms hiding inside existence

The counting proof suggests a brute-force algorithm. Enumerate all red edge sets of $K_n$. For each coloring, inspect every $k$-vertex subset and reject the coloring if all its internal edges share a color. Under the counting inequality, this finite search must halt with success. The worst-case running time is exponential in $\binom{n}{2}$, so the theorem is constructive in an existence sense without yet being computationally efficient.

The survivor theorem suggests another algorithm: maintain the currently surviving outcomes and filter them constraint by constraint. If the theorem’s strict-cardinality hypothesis holds at every stage, the list never becomes empty. With explicit finite sets, the cost is proportional to the number of outcome–constraint incidence tests, roughly $O(|\Omega||I|)$ under constant-time membership checks.

The balanced Turán graph is much cheaper: divide $2m$ vertices into two equal parts and output all $m^2$ cross-edges. Its construction takes $O(m^2)$ time, matching the output size.

These differences matter. An existence theorem can expose an algorithm while leaving its efficiency unresolved. The Ramsey proof turns success into a finite search certificate. The survivor theorem gives a filtering pipeline. A genuinely efficient local-lemma algorithm would need additional machinery—typically resampling and witness-tree estimates—to explain why the search converges quickly.

## What has, and has not, been established

The finite results are exact. The Ramsey criterion follows from Boolean-lattice counting. The instance $R(10,10)>16$ follows numerically from the power criterion. Conditional avoidance follows from induction on a finite constraint set. Balanced complete bipartite graphs attain the sharp triangle-free edge count.

Several larger ambitions remain open within this framework. The classical exponential-scale assertion near $R(k,k)>2^{k/2}$ for sufficiently large $k$ requires sharper asymptotic estimates than the concrete criterion supplied here. The symmetric Lovász local lemma requires a proof that bounded dependency and the inequality $e p(d+1)\le1$ force the necessary survivor ratios. Expected-time guarantees for resampling require witness-tree analysis. The full general Turán theorem for $K_{r+1}$-free graphs lies beyond the balanced two-part case stated here.

That boundary is mathematically productive. It separates the universal finite core from the analytic and algorithmic estimates still needed. The probabilistic method is not magic and not merely randomness. At its heart is a census: define failure precisely, count how much room it occupies, and prove that the universe has space left over.