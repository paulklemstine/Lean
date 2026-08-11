# The Shape of a Network, Heard Through Two Drums

## Can you hear the shape of a graph?

In 1966 Mark Kac asked whether one can hear the shape of a drum: does the list of frequencies at which a membrane vibrates determine its geometry? The answer, famously, is no — there exist differently shaped drums that sound exactly alike.

Networks have their own version of this question, and it is far more than a curiosity. A network — a graph $G$ with vertex set $V$ and edges joining some pairs of vertices — has a natural "vibration operator": its **adjacency matrix** $A$, the $|V| \times |V|$ array whose entry $A_{uv}$ is $1$ when $u$ and $v$ are joined by an edge and $0$ otherwise. Physically, $A$ is the hopping term of a tight-binding Hamiltonian: an electron sitting at vertex $u$ can tunnel to any neighbour. Its eigenvalues, the *spectrum* of the graph, govern how heat diffuses, how epidemics spread, how quantum walks interfere, and how random walks mix.

And here too the answer is no. Non-isomorphic graphs can have identical spectra — they are called **cospectral**, and they are embarrassingly common. Almost all trees, for instance, have a cospectral partner. So the spectrum alone cannot serve as a fingerprint.

But a physicist would object that a bare hopping term is an impoverished model. Real lattices have an on-site potential too. The most canonical potential a graph provides for free is the **degree** of a vertex — the number of edges meeting it. Collect the degrees into a diagonal matrix $D$, so that $D_{vv} = d_v$ and $D_{uv} = 0$ for $u \neq v$. Now we have two operators, a hopping term and a potential, and we can ask a richer question:

> If you know the spectrum of *every* polynomial expression built from $A$ and $D$, do you know the graph?

In 1977 Brendan McKay proved a beautiful partial answer: **yes, for trees.** No two non-isomorphic trees can agree on all these spectra. Adding the degree potential to the hopping term is enough to break every cospectrality among trees.

This article is about a sharpening of McKay's theorem — a "principal" version in which the full spectra are replaced by a single number per expression — and about the precise limits of how far it can be pushed.

## From spectra to moments

Working with whole spectra is heavy. There is a lighter invariant hiding inside.

Let $\mathbf{1}$ be the all-ones vector, the state in which every vertex is equally occupied. For any word $w$ in the two letters $A$ and $D$ — say $w = ADDA$, meaning the matrix product $A \cdot D \cdot D \cdot A$ — form the single real number
$$m_G(w) \;=\; \mathbf{1}^{\mathsf T}\, w(A_G, D_G)\, \mathbf{1}.$$
This is the total amplitude for the uniform state to return to the uniform state after the operator $w$ has acted. We call it a **word moment**. There is one such number for each finite word, and together they form the *moment data* of the graph.

Two things are immediate and both are important. First, the moment data is a genuine isomorphism invariant: relabelling the vertices of a graph permutes rows and columns of $A$ and $D$ simultaneously, and sandwiching between all-ones vectors washes the permutation out. So if two graphs are isomorphic, all their moments agree. Second, moments are drastically cheaper than spectra — each one is a single number, computable by a handful of matrix-vector multiplications.

The first surprise is that so little is lost. The moments already pin down a great deal.

## What the moments already know

**They know the size of the graph.** The empty word gives $w = I$, and $\mathbf{1}^{\mathsf T} I \mathbf{1} = |V|$.

**They know the number of edges.** The one-letter word $A$ gives $\mathbf{1}^{\mathsf T} A \mathbf{1} = \sum_v d_v = 2|E|$.

**They know the entire degree distribution.** The pure-degree words give the power sums
$$\mathbf{1}^{\mathsf T} D^k \mathbf{1} \;=\; \sum_{v \in V} d_v^{\,k}, \qquad k = 0, 1, 2, \ldots$$
Every degree of a graph on $n$ vertices is one of the $n$ integers $0, 1, \ldots, n-1$, so these power sums are the moments of a measure supported on a *known finite set*. Lagrange interpolation on those nodes converts them back into the individual multiplicities: for each $d$, the number of vertices of degree exactly $d$ is recovered as $\sum_v \ell_d(d_v)$, where $\ell_d$ is the interpolating polynomial that is $1$ at $d$ and $0$ at the other candidate degrees. So:

> **Theorem (Degree distribution).** If two finite simple graphs have the same adjacency-degree word moments, they have the same number of vertices, the same number of edges, and, for every $d$, the same number of vertices of degree $d$.

**They know the joint degree distribution.** For each pair $(a,b)$ let $N_{a,b}$ count the ordered adjacent pairs $(u,v)$ with $d_u = a$ and $d_v = b$ — the *degree assortativity* data beloved of network scientists, which controls whether hubs attach to hubs or to leaves. The moments of the words $D^i A D^j$ are exactly
$$\mathbf{1}^{\mathsf T} D^i A D^j \mathbf{1} \;=\; \sum_{u \sim v} d_u^{\,i}\, d_v^{\,j},$$
and running the same interpolation trick in both slots extracts each $N_{a,b}$.

> **Theorem (Joint degree distribution).** Graphs with equal word moments have $N_{a,b}(G) = N_{a,b}(G')$ for all $a, b$.

## The normal form: caterpillars

Why did $D^i A D^j$ appear so naturally? Because of a normal form.

The matrix $D$ is diagonal, so words in $A$ and $D$ do not collapse arbitrarily — but every word can be *written* in the shape
$$W(a) \;=\; D^{a_0} A\, D^{a_1} A \cdots A\, D^{a_n},$$
with $n$ copies of $A$ separated by powers of $D$. We call these **caterpillar words**, and the reason is combinatorial. Expanding the product entry by entry:

> **Theorem (Caterpillar expansion).** For every $n$ and every exponent vector $a = (a_0, \ldots, a_n)$,
> $$\mathbf{1}^{\mathsf T} D^{a_0} A D^{a_1} A \cdots A D^{a_n} \mathbf{1} \;=\; \sum_{p_0 \sim p_1 \sim \cdots \sim p_n} \ \prod_{i=0}^{n} d_{p_i}^{\,a_i},$$
> the sum ranging over all walks $p_0 p_1 \cdots p_n$ of length $n$ in $G$.

Read the right-hand side as a weighted count of homomorphic images of a **caterpillar**: a path (the spine, contributed by the $A$'s) with legs hanging off its vertices (the powers of $D$ — since $d_v^{a}$ is precisely the number of ways to attach $a$ ordered legs at $v$). The moment of a word is a caterpillar subgraph-count in disguise. Setting all exponents to zero recovers the plain count of walks of length $n$, i.e. $\mathbf{1}^{\mathsf T} A^n \mathbf{1}$.

This translation is not just picturesque; it is an exact equivalence. Define the **degree-decorated walk count** $c_G(n; b)$ for a prescribed degree pattern $b = (b_0, \ldots, b_n)$ to be the number of walks $p_0 p_1 \cdots p_n$ with $d_{p_i} = b_i$ for every $i$. Then:

> **Theorem (Equivalence).** Two graphs with the same number of vertices have the same adjacency-degree word moments **if and only if** they have the same degree-decorated walk counts $c_G(n; b)$ for every length $n$ and every pattern $b$.

One direction is interpolation again, applied at every position of the spine simultaneously: any weighting of the walk by arbitrary functions of the degrees at each step is a finite linear combination of caterpillar moments. The other direction is bookkeeping: grouping walks by their degree pattern turns the decorated sum back into $\sum_b c_G(n;b) \prod_i b_i^{a_i}$.

So the linear-algebraic invariant and the combinatorial one are literally the same invariant, viewed through two lenses. That is the technical heart of the story: it converts a question about operator algebras into a question about reconstructing a graph from decorated walk statistics.

## Modules: what the algebra sees

Behind the moments sits a cleaner object. Let $\mathcal A(G) = \langle I, A, D\rangle$ be the algebra of all polynomial expressions in $A$ and $D$, and let
$$M_G \;=\; \mathcal A(G)\,\mathbf{1}$$
be the **cyclic module** it generates from the uniform state: the space of all vectors reachable from $\mathbf{1}$ by applying hops and potentials. Every moment is an inner product of $\mathbf{1}$ with a vector in $M_G$, so $M_G$ is exactly the state space the moment data can explore.

How big is it? There is a hard ceiling. Let $U_G$ be the **orbit module**, the space of vectors that are constant on the orbits of the automorphism group of $G$ — vertices that the graph itself cannot distinguish.

> **Theorem (Ceiling).** For every finite simple graph, $M_G \subseteq U_G$.

The proof is a one-line symmetry argument once set up correctly: $A$ and $D$ are both invariant under simultaneous relabelling by an automorphism, the invariant matrices form an algebra, so *every* element of $\mathcal A(G)$ is invariant, and an invariant matrix applied to the (invariant) all-ones vector yields an invariant vector. Symmetric vertices are invisible to the algebra — as they must be.

At the other extreme, the module can collapse entirely:

> **Theorem (Floor).** $M_G$ is the one-dimensional line spanned by $\mathbf{1}$ **if and only if** $G$ is regular.

If every vertex has the same degree $k$, then $D = kI$ contributes nothing new and $A\mathbf{1} = k\mathbf{1}$, so nothing ever escapes the line. Conversely, if $M_G$ is that line then $D\mathbf{1}$ is a multiple of $\mathbf{1}$, which says all degrees are equal.

That floor immediately produces the sharpest possible negative result:

> **Theorem (Regular blindness).** If $G$ is $k$-regular on $n$ vertices, then for *every* word $w$,
> $$\mathbf{1}^{\mathsf T} w(A, D)\, \mathbf{1} \;=\; k^{|w|}\, n,$$
> a number depending only on $k$, $n$, and the length of $w$. Hence any two $k$-regular graphs of the same order are moment-indistinguishable.

The hexagon $C_6$ and the disjoint union of two triangles are both $2$-regular on six vertices, so all their moments coincide — yet $C_6$ contains no triangle and the other graph obviously does. The tree hypothesis in McKay's theorem is not a technical artefact; it is the whole point.

## How far can the failure reach?

One might hope that the regular examples are the only obstruction — that connectivity and irregularity rescue the invariant. They do not.

The reason is **colour refinement**, the workhorse heuristic of graph isomorphism testing (also known as one-dimensional Weisfeiler–Leman). Colour the vertices by degree, then repeatedly refine: two vertices keep the same colour only if, for each colour class, they have the same number of neighbours in it. The stable colouring is *equitable*, and its quotient records the class sizes together with the matrix $B$ of neighbour counts between classes.

> **Theorem (Quotient formula).** If $c$ is an equitable colouring of $G$ with quotient matrix $B$ and class-degree vector $\Delta$, then for every word $w$,
> $$\mathbf{1}^{\mathsf T} w(A_G, D_G)\, \mathbf{1} \;=\; \sum_{\kappa} |\kappa| \cdot \bigl(w(B, \Delta)\,\mathbf{1}\bigr)_\kappa,$$
> the sum over colour classes weighted by their sizes. Consequently $M_G$ is contained in the space of functions constant on the colour classes, and two graphs carrying equitable colourings with equal class sizes and equal quotient data have *identical* moments — isomorphic or not.

This locates the invariant exactly: moment rigidity lives strictly inside the colour-refinement hierarchy. It can never distinguish two graphs that colour refinement fails to distinguish. And the failures start early and are not degenerate. Consider the two six-vertex graphs
$$H_1: \{03,\,04,\,05,\,13,\,15,\,23,\,24\}, \qquad H_2: \{01,\,02,\,05,\,15,\,23,\,24,\,34\}.$$
Both are connected. Both have degree sequence $(3,3,2,2,2,2)$, hence neither is regular. Both admit the equitable two-colouring "degree $3$ / degree $2$" with class sizes $2$ and $4$ and the same quotient matrix $B = \begin{pmatrix} 1 & 2 \\ 1 & 1\end{pmatrix}$. By the quotient formula, *every* moment of $H_1$ equals the corresponding moment of $H_2$. But $H_1$ is bipartite and triangle-free while $H_2$ contains the triangle $2\!-\!3\!-\!4$. They are not isomorphic.

By the equivalence theorem, these two graphs also have identical degree-decorated walk counts of every length and every pattern. Two connected, irregular, six-vertex networks agree on every decorated caterpillar statistic and still differ.

## Enlarging the algebra doesn't help

A natural repair suggests itself. Add the all-ones matrix $J = \mathbf{1}\mathbf{1}^{\mathsf T}$ — a global, non-local interaction — and work with the ideal $\mathcal A(G)\, J\, \mathcal A(G)$. On the module $M_G$ this ideal is enormous; for connected graphs it acts as the full endomorphism algebra. But at the level of scalars it is a mirage:

> **Theorem (Ideal factorisation).** For any matrices $X, Y$,
> $$\mathbf{1}^{\mathsf T} X J Y \mathbf{1} \;=\; \bigl(\mathbf{1}^{\mathsf T} X \mathbf{1}\bigr)\bigl(\mathbf{1}^{\mathsf T} Y \mathbf{1}\bigr).$$

Because $J = \mathbf{1}\mathbf{1}^{\mathsf T}$ simply cuts the expression in two, every moment of the enlarged ideal is a *product* of word moments. Nothing new. The principal moment data is exactly the word data — which is why the sharpened, single-number version of McKay's theorem is the right statement to aim at.

## Where the positive results bite

On the other side of the ledger, the module can reach its ceiling. Two clean sufficient conditions:

> **Theorem (Degree-transitive criterion).** If any two vertices of equal degree are exchanged by some automorphism, then $M_G = U_G$.

The mechanism is again interpolation, now applied to the operator rather than to the numbers: since $D$ is diagonal with integer entries in a known range, the Lagrange polynomial $\ell_d(D)$ applied to $\mathbf{1}$ is the *indicator vector of the degree-$d$ class*. So every function of the degree lies in $M_G$ — the module always contains the full degree-partition module. When the degree partition already is the orbit partition, we are done.

> **Corollary.** Every star $K_{1,n}$ satisfies $M_G = U_G$, and stars are determined by their moments: if all word moments of $K_{1,n}$ and $K_{1,m}$ agree, then $n = m$.

Stars form an infinite family of trees for which the McKay-type determination is now unconditional. Together with the negative results this frames the picture exactly: **on the star family the moments determine the graph; on $2$-regular graphs of a given order they never do; and even for connected non-regular graphs they fail already at six vertices.**

## What remains

Two crisp conjectures sit at the end of the road, and both are now purely combinatorial thanks to the caterpillar equivalence.

**Moments determine every tree.** If two trees have equal word moments — equivalently, equal degree-decorated walk counts — they are isomorphic. This is the principal form of McKay's theorem. Exhaustive search finds no counterexample among trees on at most twelve vertices — and among those, plain undecorated walk counts already fail, so the degree decoration is doing real work. The natural attack is a leaf-peeling induction: identify the leaves by their decorated pattern multiplicities, strip them, and recurse. No analysis is needed — only the counts that are already proven invariant.

**Forests reach the ceiling.** For every forest $F$, $M_F = U_F$. Here the expected mechanism is that in a forest the iterated degree refinement stabilises exactly at the automorphism-orbit partition, collapsing the gap between the two modules. It is known for stars and for degree-transitive graphs; the general case is open.

## Why anyone should care

Beyond the reconstruction question, the moments are a practical fingerprint. They are computable in a few sparse matrix-vector products, they are strictly stronger than the degree sequence and strictly stronger than plain walk counts, and they are exactly as strong as degree-decorated caterpillar counts — which is precisely the class of features that message-passing graph neural networks compute in their first rounds. The statement "moment rigidity lies inside colour refinement" is, in that language, the statement that no amount of degree-and-hopping algebra will ever exceed the expressive power of one-dimensional Weisfeiler–Leman. The six-vertex pair $H_1, H_2$ is a compact certificate of that ceiling: two connected, irregular networks that a whole infinite family of natural physical measurements cannot tell apart.

You cannot always hear the shape of a graph. But if you strike two drums at once — the hopping and the potential — you hear a great deal more, and the trees, at least, appear to sing distinctly.
