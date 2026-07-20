# The Shape of Shared Ideas: What Co-Citation Can—and Cannot—Tell Us

A mathematical paper rarely stands alone. It cites definitions, techniques, and theorems scattered across decades. If we imagine each theorem as a point and each document as a thread gathering several points together, an enormous fabric appears. Topological data analysis offers an appealing question: does this fabric have a shape?

The answer is yes, but with an important warning. The shape of co-citation is a precise combinatorial object; the meaning assigned to that shape is not automatic. A loop may reveal a genuine gap in higher-order citation, but it does not, by itself, name a “school of mathematics.” A cavity may mark a structural transition, but it does not prove that a paradigm shifted. The mathematics developed here separates what the network guarantees from what an interpretation must supply.

## From documents to a simplicial complex

Let $V$ be a finite collection of theorems. A **corpus** $C$ is a finite family of subsets of $V$. Each member $W\in C$ records all the theorems cited by one document. Such a member is sometimes called a hyperedge because it can join more than two vertices at once.

The **co-citation complex** $K(C)$ contains a finite set $S\subseteq V$ precisely when some document cites every theorem in $S$:

$$
S\in K(C) \quad\Longleftrightarrow\quad \text{there is a }W\in C\text{ with }S\subseteq W.
$$

Thus a theorem is a vertex, a co-cited pair is an edge, a jointly cited triple is a filled triangle, and a jointly cited quadruple is a solid tetrahedron. Every subset of a witnessed set is witnessed by the same document. Consequently, if $S\in K(C)$ and $T\subseteq S$, then $T\in K(C)$. This downward-closure property is exactly what makes $K(C)$ a simplicial complex.

There is also a simpler object: the **pairwise co-citation graph** $G(C)$. Two distinct theorems are adjacent when some document cites them both. Graphs are familiar, compact, and easy to visualize. Yet compressing documents to pairs may invent higher-dimensional structure that was never present.

## The smallest illusion

Consider three theorems $a$, $b$, and $c$, and three documents with citation sets

$$
\{a,b\},\qquad \{a,c\},\qquad \{b,c\}.
$$

Every pair occurs, so the pairwise graph is a triangle. Its **clique complex**—the simplicial complex obtained by filling every complete graph—contains the filled triangle $\{a,b,c\}$. But no document cites all three theorems together. The genuine co-citation complex contains the three boundary edges and not the triangular face.

Topologically, the distinction is dramatic. The boundary triangle has one independent one-dimensional loop, so over any field its first Betti number is $\beta_1=1$. Filling the triangle kills that loop, giving $\beta_1=0$. Pairwise projection has erased a genuine higher-order absence.

This is not a technical corner case. It identifies the exact question that must be asked whenever a graph is used to infer group interaction: do all pairwise relationships come from one common witness?

## When pairwise information is enough

A set of vertices is a **clique** if every two distinct vertices in it are adjacent. Call a corpus **conformal** when every clique $S$ in its pairwise graph fits inside at least one document $W\in C$.

The central reconstruction result is exact:

> **Conformality Criterion.** The genuine co-citation complex $K(C)$ equals the clique complex of the pairwise graph $G(C)$ if and only if the corpus is conformal—that is, every graph clique is contained in one common document.

The proof has two short directions. Every genuine face lies in a document, so every pair of its vertices is co-cited; hence every genuine face is a graph clique. Conversely, if every clique has a common witness, then each face inserted by clique completion is contained in a document and therefore already belongs to $K(C)$.

The three-theorem example fails precisely this criterion. Its three pairs have three different witnesses, but the triple has none. At the opposite extreme, if a single document cites every theorem in $V$, then $K(C)$ is the full simplex of all subsets of $V$, the pairwise graph is complete, and conformality holds automatically.

The criterion is useful because it converts a vague concern about “lost higher-order information” into a testable condition. Pairwise data never omits a genuine face when one passes to clique completion; instead, it may add spurious faces. Conformality says exactly when it adds none.

## Growing corpora and persistence

Real corpora develop over time. Suppose $C_t$ denotes all documents available by time $t$. If $s\le t$, then $C_s\subseteq C_t$. Adding documents can only add witnessed sets, so

$$
K(C_s)\subseteq K(C_t).
$$

This **filtration theorem** supplies the basic structure required for persistent homology. A loop may appear when several pairwise co-citations accumulate, then disappear when a later document jointly cites the entire set and fills the gap. A two-dimensional cavity may likewise be born from witnessed triangles and die when suitable tetrahedra arrive.

Persistence records the interval between birth and death. Long intervals identify durable incidence patterns; short intervals identify fleeting ones. But persistence does not assign semantics. A persistent loop is a persistent loop in the citation incidence structure. Calling it a research community requires external evidence such as subject labels, author affiliations, textual similarity, or a statistical model linking those features to topology.

This distinction matters. Two corpora can have exactly the same simplicial complex while attaching completely different disciplinary labels to their vertices. No topological statistic can distinguish information that the incidence structure does not contain.

## How large can the topology become?

The original speculative picture suggests that the $k$th Betti number might grow like $n^{k+1}$, where $n=|V|$. There is a valid inequality nearby, but it is an upper bound rather than a universal growth law.

A $k$-dimensional simplex uses $k+1$ vertices. Among $n$ vertices there are only

$$
\binom{n}{k+1}
$$

possible such simplices. Therefore the number $f_k$ of $k$-faces satisfies

$$
f_k\le \binom{n}{k+1}.
$$

Homology is obtained from chains by imposing cycle equations and quotienting by boundaries. It cannot have dimension larger than the chain space that contains it. Hence the **Betti Ceiling Theorem** states

$$
\beta_k\le f_k\le \binom{n}{k+1}\le n^{k+1}.
$$

The last expression is real but coarse. It says only that $n^{k+1}$ is a ceiling. It does not say that $\beta_k$ is close to that ceiling, has the same asymptotic order, or is even positive.

Boundary ranks explain the gap. If $\partial_k$ is the boundary map from $k$-chains to $(k-1)$-chains, then

$$
\beta_k=f_k-\operatorname{rank}(\partial_k)-\operatorname{rank}(\partial_{k+1}).
$$

Simplex counts determine how many generators are available; boundary maps determine how many survive as homology. Two complexes with the same face counts can have different Betti numbers because their faces are attached differently.

There is an even sharper obstruction. No face on $n$ vertices can contain more than $n$ vertices. Thus there are no $k$-simplices when $k\ge n$, and

$$
\beta_k=0\qquad\text{for every }k\ge n.
$$

For a nonempty vertex set, $n^{k+1}>0$. Therefore $\beta_k=n^{k+1}$ is impossible whenever $k\ge n$. Any genuine asymptotic law must specify a fixed-dimensional regime, a random or deterministic corpus model, and quantitative assumptions governing boundary ranks.

## A practical analysis pipeline

The mathematics suggests a disciplined workflow.

First, retain each document as a set of cited theorems rather than immediately flattening it to edges. Generate the downward closure to obtain $K(C)$. Second, build $G(C)$ and its clique complex only as a comparison object. Third, test conformality by searching for cliques that lack a common document witness. Such a clique is a certificate that pairwise projection has inserted a spurious higher-dimensional face.

Fourth, for a temporal corpus, order documents by date and build the nested complexes $K(C_t)$. Compute boundary matrices over a chosen field and use their ranks to obtain Betti numbers or persistence intervals. Finally, compare every computed $\beta_k$ with the sanity bounds

$$
0\le \beta_k\le f_k\le \binom{n}{k+1}.
$$

A violation signals an error in indexing, face generation, or rank computation.

## Shape first, meaning second

The topology of theorem networks is promising precisely because its limitations can be stated cleanly. The co-citation complex preserves common-document witnesses. The pairwise graph preserves only pairs. The Conformality Criterion says when those views agree. Monotonicity turns historical corpora into valid filtrations. Binomial bounds identify the largest possible homological dimensions, while dimension vanishing rules out an unrestricted positive power law.

What remains is empirical and statistical. Under what random model do normalized Betti profiles converge? When does a growing corpus become conformal? Are persistent two-dimensional cavities better indicators of structural change than raw triangle counts? Which metadata makes semantic labels identifiable?

These questions are more interesting after the foundational distinctions are made. A loop is not automatically a school, and a cavity is not automatically a revolution. Yet both are exact records of how pairwise compatibility succeeds—or fails—to assemble into genuine collective witness.

That disciplined viewpoint has applications beyond mathematics. In collaboration data, an edge can mean that two people have worked together, while a filled triangle should mean that all three collaborated on one project—not merely that each pair met separately. In medicine, pairwise co-occurrence of symptoms does not guarantee a single patient exhibiting the whole cluster. In ecology, pairwise species encounters need not imply a jointly observed community. The same conformality question recurs whenever higher-order evidence is compressed into a graph.

By keeping witnesses visible, topology becomes not a machine for attaching dramatic labels, but a language for asking sharper questions. It tells us which assemblies were observed, which were inferred, which gaps persisted, and which claims exceed the data. That is the shape hidden inside shared ideas.