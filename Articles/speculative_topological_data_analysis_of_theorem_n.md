# What a Citation Graph Cannot See

## The hidden geometry of mathematical influence

A mathematical paper rarely speaks to one theorem at a time. It gathers several results into a single line of thought: perhaps a classical lemma, a modern structural theorem, and a computational estimate. Those joint appearances carry information. They say not merely that theorem $A$ is associated with theorem $B$, but that $A$, $B$, and $C$ were used or discussed together in one intellectual act.

Ordinary citation networks flatten that information into pairs. Draw a vertex for each theorem, join two vertices when some source cites both, and the result is a graph. Graphs are familiar, visual, and useful. Yet the flattening can erase exactly the distinction one hopes to study: the difference between several pairwise relationships and one genuinely collective relationship.

The simplest example already contains the central surprise. Take three theorems, called $A$, $B$, and $C$. Imagine a corpus with three records: one jointly cites $A$ and $B$, another cites $B$ and $C$, and a third cites $A$ and $C$. The pairwise graph is a triangle. Now add a fourth record that jointly cites all three theorems. The pairwise graph does not change; every possible edge was present already. But the higher-order structure changes decisively. Before the new record, the triangle has an empty interior. Afterward, it is filled.

That difference is the point of treating theorem networks as simplicial complexes rather than graphs.

## From records to shapes

Let $V$ be a finite set of theorems. A corpus is a finite collection of records, where each record is a subset of $V$ containing the theorems jointly cited by one source. The associated co-citation complex contains a finite set $S\subseteq V$ whenever all the theorems in $S$ occur together in at least one record. Because every subset of a jointly cited set is also jointly cited, this collection is closed under taking subsets. That closure is precisely what makes it a simplicial complex.

Its pieces have an intuitive hierarchy. A theorem is a vertex. A jointly cited pair is an edge. A jointly cited triple is a filled triangle, or $2$-simplex. Four theorems cited together form a solid tetrahedron, or $3$-simplex, and so on. The usual co-citation graph is only the $1$-skeleton: it remembers vertices and edges while discarding which larger sets possessed a common witness.

Topology asks about holes in this complex. The zeroth Betti number $\beta_0$ counts connected components. The first Betti number $\beta_1$ counts independent loop-like holes. The second Betti number $\beta_2$ counts independent shell-like voids. These numbers do not merely count faces; they compare cycles with the higher-dimensional faces that fill them.

In the three-theorem example, the three pair records produce a loop made from three edges. No record contains $\{A,B,C\}$, so there is no triangular face to fill that loop. The complex has $\beta_0=1$, $\beta_1=1$, and $\beta_2=0$. Adding the joint triple leaves the graph unchanged but inserts the missing face. The loop becomes a boundary and no longer represents a hole, giving $\beta_0=1$, $\beta_1=0$, and $\beta_2=0$.

This yields a clean structural theorem: **adding a record that jointly cites all three members of a pairwise triangle can strictly enlarge the co-citation complex while leaving its pairwise graph exactly unchanged.** The proof is visible in the picture. The old records supply all three edges; the new record supplies the triple; and no new edge can appear because the graph was already complete.

## Why the missing interior matters

Suppose the three vertices represent cryptographic theorems associated with three hardness assumptions. Pairwise records may compare each pair separately, yet no argument may place all three assumptions in a common framework. A graph reports a tightly connected triangle in either case. The complex distinguishes a ring of pairwise bridges from a single integrated treatment.

That does not mean every loop is a “school of mathematics,” nor that every newly filled shell marks a “paradigm shift.” Topology identifies structural patterns, not their historical meaning. A persistent loop could arise from disciplinary separation, incompatible terminology, publication customs, or missing data. Interpretation requires dates, subject labels, authorship information, and comparison with suitable null models. The mathematics establishes what information survives and what information is lost; empirical work must establish what that information predicts.

The warning is nevertheless strong. If analysis begins with a graph, the higher-order distinction is gone before any clustering or visualization begins. No sophisticated graph statistic can recover whether a clique came from one common citation record or from many records that each witnessed only a pair, unless extra assumptions are imposed.

One such assumption is conformality: every clique in the pairwise graph must be contained in a single corpus record. Under conformality, the graph’s cliques faithfully reconstruct the higher-order complex. Without it, clique filling invents collective relationships that the corpus never recorded. The three-pair triangle is the smallest failure of conformality.

## Time turns topology into a film

Citation corpora grow. Let $C_t$ denote all records observed by time $t$, and assume records are never deleted, so $C_s\subseteq C_t$ whenever $s\le t$. Then the corresponding co-citation complexes are nested as well. Every face present at time $s$ remains present at time $t$.

This is the face-persistence theorem: **in a monotonically growing filtered corpus, any jointly witnessed simplex present at an earlier time remains in the co-citation complex at every later time.** Its proof is immediate but fundamental. If a face $S$ was contained in some earlier record, that record remains available later, so it continues to witness $S$.

Holes behave more subtly than faces. New edges can create a loop; a later triple can fill it. Persistent homology records the birth and death of such classes across the filtration. A long-lived first-dimensional class describes a loop resistant to many additions. A second-dimensional class describes a shell of triangular relations not yet filled by tetrahedral integration. This turns a static map into a film of intellectual organization.

The triangle example is a complete miniature persistence story. At the pairwise stage, a one-dimensional class is born. When the triple record arrives, that class dies. The one-skeleton remains constant across the transition, so a graph-only time series sees no event at all.

## A proposed growth law meets a dimensional ceiling

A tempting slogan says that the $k$th Betti number of a theorem network with $n$ vertices should grow like

$$
\beta_k\approx n^{k+1}.
$$

The exponent has an intuitive source: a $k$-dimensional face uses $k+1$ vertices, and there are roughly $n^{k+1}$ ordered choices. But that intuition ignores both unordered counting and the boundary relations that topology measures.

For a complex on $n$ vertices, the number of possible $k$-faces is at most

$$
\binom{n}{k+1}.
$$

Therefore the dimension of the $k$th chain space, and hence $\beta_k$, cannot exceed $\binom{n}{k+1}$. More dramatically, when $k\ge n$, there are no sets of $k+1$ distinct vertices at all. Thus

$$
\beta_k=0\qquad\text{for every }k\ge n.
$$

This finite-dimensional vanishing immediately rules out an exact law $\beta_k=n^{k+1}$ holding in every dimension for any nonempty finite network. At $k=n$, the left side is zero while $n^{n+1}$ is positive.

Even a relaxed, constant-factor lower law fails. There is no positive integer $a$ such that

$$
n^{k+1}\le a\beta_k
$$

for every $k$. Again choose $k=n$: the right side is $a\cdot0=0$, while the left side is positive. This is not a numerical accident or a feature of a particular corpus. It is a universal dimensional obstruction.

The correction is important. A power law might still describe a fixed dimension $k$ while $n$ grows, perhaps in a specified random model or within a critical density window. The impossibility result refutes only a positive law demanded uniformly across all dimensions. It redirects the question from an unqualified slogan to a meaningful asymptotic program: fix $k$, specify how records are generated, and determine how face counts and boundary ranks interact.

## What can responsibly be claimed

Three firm conclusions emerge.

First, higher-order citation data are not generally reconstructible from pairwise co-citation. A graph can remain unchanged while the topology changes.

Second, growing corpora naturally produce filtrations: faces persist forward in time, while homology classes may be born or killed. This supplies the mathematical foundation for persistent analysis.

Third, no nonempty finite theorem network can obey $\beta_k=n^{k+1}$ in every dimension, nor can any positive constant turn that expression into a dimension-uniform lower bound. The right universal benchmark is the binomial chain ceiling and eventual vanishing.

These conclusions are structural, not sociological. They do not prove that first homology identifies communities or that second homology detects conceptual revolutions. They show how to ask those questions without discarding the relevant data or adopting an impossible scaling law.

The next empirical step is therefore clear. Build timestamped hypergraph corpora that retain each source’s full joint citation set. Compare persistent classes with independently curated research communities and dated conceptual changes. Use degree-preserving temporal null models to distinguish meaningful persistence from consequences of corpus size and citation frequency. In cryptography, one can ask whether durable cycles form around interchangeable assumptions and whether higher-order fillings coincide with unifying reductions.

A citation graph is a shadow. Sometimes the shadow is faithful. Sometimes an empty triangle and a filled one cast exactly the same outline. To study the architecture of mathematical ideas, we must keep track not only of which results meet in pairs, but of which results truly meet together.