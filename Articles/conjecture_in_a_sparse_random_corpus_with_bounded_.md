# The Shape of a Library

## What the holes in a citation network can — and cannot — tell us

Imagine every theorem ever proved as a dot on an enormous sheet of paper. Now draw the papers: each published article gathers a handful of those dots into a bundle, the set of results it cites together. A bibliography is not a list of arrows so much as a *committee* — a group of theorems summoned to appear side by side.

Mathematicians have a habit, when handed a collection of committees, of gluing. If a paper cites three theorems together, fill in the triangle they span. If it cites four, fill in the tetrahedron. Do this everywhere and the sheet of dots becomes a geometric object: a *shape*, built out of points, edges, triangles, and higher-dimensional cells, that encodes not who cited whom but which results are habitually thought about at the same time.

That shape has holes, and the holes are the interesting part. A one-dimensional hole is a loop of co-citation that never gets filled in: results $A$ and $B$ appear together, $B$ and $C$ appear together, $C$ and $A$ appear together, but no single piece of work ever brings all three into the same frame. That is a real, measurable absence — the mathematical fingerprint of a gap between neighbouring communities. Higher-dimensional holes record subtler failures of the same kind. Counting these holes in each dimension gives a sequence of numbers, the *Betti numbers* $\beta_0, \beta_1, \beta_2, \dots$, and the fantasy is that the Betti numbers of the scientific literature are a portrait of the shape of knowledge itself.

The trouble with fantasies is that they are usually stated too loosely to be wrong. Papers in this area routinely announce that the number of $k$-dimensional holes in a citation network grows like a power of the number of results, that a certain topological signature detects the birth of a research field, that the connected loops of the citation complex *are* the mathematical schools. These sound like theorems. They are not; they are moods. This article is about what happens when you insist on the theorems, and the answer is more interesting than the fantasy: one parameter nobody was tracking turns out to control everything, and one hoped-for application turns out to be provably impossible.

---

## The parameter that matters is bibliography length

Write $n$ for the number of theorems in the corpus and $d$ for the largest number of theorems any single document cites. Every claim in the literature is phrased in terms of $n$. The first result says that $n$ is almost irrelevant, and $d$ is everything.

**Support Theorem.** *If no document in the corpus cites more than $d$ theorems, then the co-citation complex has no faces at all with more than $d$ vertices; consequently every Betti number vanishes in dimension $d$ and above:*
$$\beta_k = 0 \qquad \text{for all } k \ge d.$$

The proof is a single line, which is exactly why the statement is worth isolating. A face of the complex is by definition a subset of some document's bibliography. A subset of a set of size at most $d$ has size at most $d$. So there is nothing in dimension $d$ or higher for homology to be made of, and a hole can only exist where there is material to build it from.

The consequence is bracing. A corpus of a billion theorems in which every paper cites at most twenty results has, unconditionally, no topology whatsoever above dimension nineteen. Not "typically none" — none. Any empirical claim about high-dimensional structure in a citation network is a claim about how long bibliographies are, and about nothing else. The number of theorems supplies the *width* of the shape; the length of a bibliography supplies its *ceiling*.

---

## How much topology can there be?

If $d$ is the ceiling, the natural next question is extremal: with $n$ theorems and bibliographies of length at most $d$, how much topology can you possibly manufacture? Here the most symmetric object imaginable turns out to be the champion. Call the *complete design* the corpus in which every single $d$-element set of theorems is somebody's bibliography — a perfectly egalitarian literature in which every possible committee meets exactly once. Its complex is the $(d-1)$-skeleton of a simplex: all the faces of size up to $d$ and none above.

**Extremal Counting Theorem.** *Among all corpora on $n$ theorems whose documents cite at most $d$ results, the maximum possible number of faces with $q$ vertices is exactly $\binom{n}{q}$ for every $q \le d$, and the complete design attains it.*

Counting faces, however, is not the same as counting holes: a shape can have astronomically many cells and no holes at all (a solid ball, for instance). To convert the counting statement into a topological one, we need a bridge, and the bridge is the oldest invariant in the subject. The *Euler characteristic* is the alternating sum of face counts,
$$\chi \;=\; f_1 - f_2 + f_3 - \cdots,$$
where $f_q$ is the number of faces with $q$ vertices. Euler's insight, in modern dress, is that this alternating sum can equally be computed from the holes:
$$\chi \;=\; \beta_0 - \beta_1 + \beta_2 - \cdots.$$

For the complete design the left-hand side is a partial alternating sum of binomial coefficients, and partial alternating binomial sums telescope beautifully:
$$\sum_{j=0}^{d} (-1)^j \binom{m+1}{j} \;=\; (-1)^d \binom{m}{d}.$$
Feeding this in gives a closed formula.

**Euler Characteristic of the Design.** *For $1 \le d \le n$, the complete design on $n$ theorems with bibliographies of size $d$ has*
$$\chi \;=\; 1 - (-1)^d \binom{n-1}{d}.$$

Two sanity checks. For $n = 3$ and $d = 2$ the design is the hollow triangle: three vertices, three edges, and $\chi = 1 - (+1)\binom{2}{2} = 0$, exactly as $3 - 3$ demands. For $n = 5$ and $d = 3$ the design is the $2$-skeleton of the $4$-simplex: five vertices, ten edges, ten triangles, $\chi = 5 - 10 + 10 = 5$, and the formula returns $1 - (-1)^3\binom{4}{3} = 1 + 4 = 5$.

Now the punchline. The Euler characteristic of the design is of size roughly $n^d/d!$ — enormous. But by the Support Theorem, only $d$ Betti numbers are allowed to be nonzero at all. An alternating sum of $d$ numbers cannot be huge unless one of the numbers is huge. Dividing the pigeonhole:

**Concentration Theorem.** *In any $d$-bounded corpus, some Betti number in a dimension below $d$ satisfies $|\chi| \le d \cdot \beta_k$. For the complete design this yields*
$$(n-d)^d \;\le\; d!\cdot d\cdot \beta_k + d!$$
*for some $k < d$: the extremal number of holes grows like $n^d$.*

And one can do better than "some dimension". Every Betti number below the top is capped by its own face count, and those face counts are of order $n^{d-1}$ — a whole factor of $n$ smaller than the Euler characteristic. So the small dimensions cannot absorb the mass, and it all has to sit at the top:
$$(n-d)^d \;\le\; d!\left(\beta_{d-1} + (d-1)n^{d-1} + 1\right).$$

**The extremal topology is localised.** In the maximally rich corpus, the holes are not spread across dimensions. They pile up in the single dimension $d-1$, one below the ceiling, in quantity of order $n^d$ — while every other dimension carries at most $O(n^{d-1})$. The classical Betti sequence of the design, $\beta_0 = 1$ and $\beta_{d-1} = \binom{n-1}{d}$ with everything else zero, is a genuine witness that this bound is attained.

So the folklore power law is *half* right, and in an instructive way. Polynomial growth of the $k$-th Betti number is possible — but only in the single dimension immediately below the bibliography bound, and only with a fantastically artificial corpus.

---

## Real corpora are nowhere near the ceiling

That last caveat can be made precise, and it is the most practically useful result in the story. The complete design needs $\binom{n}{d}$ documents: a literature with more papers than theorems by an astronomical factor. Real corpora are *sparse*. What does sparsity buy?

**Document Budget.** *In a $d$-bounded corpus with $N$ documents, the number of faces with $q$ vertices is at most $N\binom{d}{q}$ — a bound that does not mention the number of theorems at all. Consequently every Betti number obeys $\beta_k \le N \binom{d}{k+1}$.*

The proof is a change of accounting: instead of counting faces by scanning subsets of theorems, count them by scanning documents. Each document of size at most $d$ can donate at most $\binom{d}{q}$ faces of size $q$, and every face comes from some document.

This single inequality replaces the ambient binomial ceiling $\binom{n}{q}$ — a quantity about the *universe of possible* co-citations — by a budget determined by how much has actually been written. As soon as the number of documents grows more slowly than $n^{k+1}$, the normalised Betti number $\beta_k/\binom{n}{k+1}$ is forced to zero. The starkest small case is completely explicit: on $n \ge 4$ theorems, a corpus of pairwise co-citations with at most $n$ documents has
$$\beta_1 < \binom{n}{2},$$
missing the ceiling by an order of magnitude — $n$ against $n^2$ — even though dimension $1$ is the *only* dimension a pairwise corpus can support. Turned around: to reach the ceiling you need at least $\binom nq/\binom dq$ documents. There is no cheap route to a topologically rich literature.

---

## The pairwise shadow lies, and it lies at every level

There is a second, entirely separate way that the folklore goes wrong, and it concerns how the shape is built in the first place. Most software does not have access to the bibliographies as *sets*. It has a graph: an edge between two theorems whenever some paper cited both. From the graph one builds the *flag complex* — fill in every clique. Is the flag complex the same as the true complex?

Not always, and the standard counterexample is charming: three theorems, three papers, each citing exactly one pair. Pairwise, everything is connected; the graph is a triangle. But no document ever contains all three, so the true complex is a hollow triangle with a genuine hole, while the flag complex fills it in. The pairwise shadow has invented a face that no author ever wrote.

The literature treats this as *the* obstruction, the one exceptional pattern to watch for. It is not.

**Hierarchy Theorem.** *For every level $m \ge 2$ there is a corpus in which every clique of at most $m$ theorems has a common witnessing document, and yet some clique of $m+1$ theorems has none. Consequently no fixed amount of local checking can certify that the pairwise shadow is faithful.*

The witnesses are, once again, the complete designs. In the design with bibliographies of size $d \ge 2$, every pair of theorems is co-cited, so the co-citation graph is *complete* — the pairwise projection has destroyed all information whatsoever. Every group of $d$ or fewer theorems does have a common document; no group of $d+1$ does. The three-theorem example is precisely the case $d=2$, $n=3$: the bottom rung of an infinite ladder. And the correction is quantitatively brutal: the flag complex of the design has all $2^n$ subsets as faces, against the true count of $\sum_{q\le d}\binom nq$.

There is a clean structural statement lurking here. For a $d$-bounded corpus, faithfulness of the pairwise shadow splits into exactly two conditions: no clique larger than $d$, and a common witness for every clique of size at most $d$. The second is checkable locally; the first is irreducibly global, and the hierarchy theorem shows that no amount of local work will ever supply it. In the design family, faithfulness is an all-or-nothing event that occurs only when $d = n$, at which point the corpus is a single all-encompassing document and the shape is contractible.

---

## What the holes are not

Finally, the application that motivated much of this: can one read off research communities — schools, subfields, semantic clusters — from the topology?

**Non-Identifiability Theorem.** *Call a labelling rule* uniform *if renaming the theorems renames its output correspondingly — that is, if the rule uses only the incidence pattern and no external information about individual theorems. Then on any corpus whose incidence pattern is symmetric enough that some renaming carries any chosen theorem to any other, every uniform rule outputs the same label for every theorem. It therefore disagrees with every ground-truth labelling that distinguishes even two results.*

The proof is three lines of symmetry-chasing, and its force lies in the choice of witness. One might hope the obstruction only bites on degenerate, structureless corpora. The complete designs are exactly the opposite: they are the *maximally symmetric* corpora, invariant under every permutation of theorems, and by the extremal results above they are simultaneously the *most topologically rich* corpora available. For the pairwise design on $n$ theorems, $\beta_1 = \binom{n-1}{2}$, which is positive as soon as there are three results. So here is a corpus dripping with holes, and not one of them knows anything about what its theorems mean.

The moral is stated best in the negative direction. A rule that *does* recover a non-constant labelling on a symmetric corpus — say the rule that simply looks up the metadata — is provably not uniform. This is not a defect; it is a proof that vertex metadata carries genuine information that cannot be repackaged as incidence data. Community detection from citation topology alone is not merely hard. On the richest examples, it is impossible, and the impossibility is a symmetry, not a shortage of signal.

---

## What is left

A cycle in a citation complex is an incidence pattern, not a semantic object. Once that is accepted, the honest programme comes into focus. The support of the topology is set by bibliography length. Its maximum size is set by an extremal design and concentrated one dimension below the ceiling. Its realistic size is set by a document budget that ignores the theorem count entirely. Its faithfulness under pairwise projection is a graded hierarchy of conditions rather than a single exception. And its semantic content, absent outside information, is zero.

The remaining questions are now sharp enough to be attacked probabilistically: what is the limiting normalised Betti number of a sparse random corpus; at what density does every clique acquire a witness; can persistent homology of a growing corpus detect the moment when a genuine higher-order cavity opens? Those are questions with answers. The vaguer versions never were.

The shape of a library is real. It is just considerably smaller, considerably more constrained, and considerably less talkative than we had hoped.
