# Never Turn Around: A Guided Tour of the Non-Backtracking Trace Formula

> **What you will learn.** How a single prohibition — *never immediately retrace the edge
> you just crossed* — turns a graph into a matrix whose traces count its cycles. By the end
> you will be able to look at a list of integers and read off whether a graph is a forest,
> what its girth is, how many shortest cycles it has, and how many triangles it contains.

---

## 1. The rule

Take a graph: dots joined by lines. Walk on it. One rule: **when you arrive at a vertex,
you may leave by any edge except the one you just arrived on.**

That is the whole idea. A walk obeying it is called *non-backtracking*.

It sounds like a triviality. It is not. An ordinary walk on a sparse graph spends much of
its life dithering — step out, step back, step out again. Those wasted moves dominate every
count you might want to make. Forbid them, and what is left are walks that genuinely go
somewhere, and closed walks that genuinely go *around* something.

Before any formalism, let us just look at the object. Choose a graph in the laboratory
below and press the play button; you will see a closed non-backtracking walk traced one
step at a time, with the forbidden U-turn greyed out at each step.

{{interactive_demo:0}}

Come back to this panel repeatedly as you read — every claim below is a column, a row or a
sentence somewhere in it.

---

## 2. Why vertices are not enough: darts

Here is the first real idea, and it is worth pausing on.

The no-U-turn rule is **not a rule about where you are**. Standing at a vertex tells you
nothing about which edge is forbidden. It is a rule about *how you arrived*.

So we change the state. Instead of vertices, use **darts**.

> **Definition.** A *dart* of a graph $G$ is an ordered pair $(u,v)$ where $u$ and $v$ are
> joined by an edge. Every edge yields exactly two darts, one per direction, so a graph
> with $|E|$ edges has $2|E|$ darts. The *reversal* of $d = (u,v)$ is $d^{-1} = (v,u)$.

Now the rule becomes a condition on **consecutive** states, which is exactly what a matrix
can express:

> **Definition.** The dart $e = (x,y)$ *may follow* the dart $d = (u,v)$, written
> $d \to e$, if
> $$v = x \qquad\text{and}\qquad y \neq u.$$
> The first condition says the arrows compose; the second says $e \neq d^{-1}$, i.e. no
> U-turn.

<details>
<summary><b>Why this asymmetry matters more than it looks</b> (click to expand)</summary>

The relation $\to$ is not symmetric. In fact it is *strongly* asymmetric: if $d \to e$ then
$e \not\to d$, always. (If $d = (u,v) \to e = (v,y)$ with $y \ne u$, then for $e \to d$ we
would need the head of $d$ to differ from the tail of $e$… unwinding the definitions gives
$y = u$, a contradiction.) And $d \not\to d$ for every dart, since that would need $u = v$.

This is why the familiar theorem *"the $(u,v)$ entry of $A^n$ counts walks of length $n$"*
cannot simply be quoted. That theorem is usually developed for the symmetric adjacency
matrix of an undirected graph. Here we are dealing with an honest **digraph on darts**, and
the counting theory has to be redone at that level of generality: for an arbitrary binary
relation $r$ on a finite set, with $M_{ij} = 1$ exactly when $r(i,j)$.

The good news is that at that level it is still true, and the proof is a clean induction:
$(M^{n+1})_{ab} = \sum_c M_{ac} (M^n)_{cb}$, and prepending $a$ to a walk from $c$ to $b$
is a bijection onto the walks of length $n+1$ from $a$ to $b$ whose second entry is $c$.
</details>

> **Definition.** The **Hashimoto matrix** $B$ of $G$ is the $2|E| \times 2|E|$ zero–one
> matrix indexed by darts with $B_{d,e} = 1$ exactly when $d \to e$.

The algorithm that builds it, in both a dense and a sparse form, is below. Notice line 11
of the pseudocode: the row of the dart $(u,v)$ has exactly $\deg(v) - 1$ entries. That
number will reappear as the branching factor of the walk.

{{algorithm:0}}

---

## 3. The theorem

> **Definition.** A *rooted closed non-backtracking walk of length $n$* is a list of darts
> $d_0, d_1, \dots, d_n$ with $d_i \to d_{i+1}$ for every $i$, and $d_n = d_0$.

"Rooted" means the starting dart is remembered: the same loop begun at a different arrow is
a different walk.

> ### The Non-Backtracking Trace Formula
> For every finite simple graph and every $n \ge 0$,
> $$\operatorname{trace}(B^n) \;=\; \#\{\text{rooted closed non-backtracking walks of length } n\}.$$

<details>
<summary><b>Proof sketch</b> (click to reveal)</summary>

Two steps.

**Step 1 — entries count walks.** For an arbitrary relation $r$ on a finite set with
matrix $M$, one shows $(M^n)_{ab} = \#\{\text{walks of length } n \text{ from } a \text{ to
} b\}$ by induction on $n$. The base case is $M^0 = I$. For the step, expand
$(M^{n+1})_{ab} = \sum_c M_{ac} (M^n)_{cb}$: the summand is the number of walks from $c$ to
$b$ when $r(a,c)$ holds and zero otherwise, and prepending $a$ is a bijection from the
disjoint union of those walk sets onto the walks of length $n+1$ from $a$ to $b$.

**Step 2 — the trace collects the closed ones.** Summing the diagonal,
$\operatorname{trace}(M^n) = \sum_a (M^n)_{aa}$ counts walks that return to their starting
point, each remembered together with that starting point. Apply this with the index set
$D(G)$ and the relation $\to$. $\blacksquare$

The whole content was Step 1 at the right level of generality; the theorem itself is then
one line.
</details>

You can watch the theorem being true. In the laboratory above, the column **trace(Bⁿ)** is
computed by exact integer matrix powers, and the column **enumerated** is computed by a
completely separate depth-first search over walks. They never disagree.

---

## 4. Three faces of the same count

The theorem has two further shapes, and each is the right one for a different purpose.

**Cyclic dart words.** The last entry of a closed walk repeats the first, so drop it. What
remains is a list $c_1,\dots,c_n$ of darts with $c_i \to c_{i+1}$ *and* a seam condition
$c_n \to c_1$. Deletion is a bijection, so $\operatorname{trace}(B^n)$ also counts these.
This form is the one to use for symmetry arguments, because rotation and reversal act on
it.

**Cyclic vertex words.** Eliminate darts entirely. A cyclic dart word is the same thing as
a cyclic sequence of vertices $u_1,\dots,u_n$ with
$$u_i \sim u_{i+1} \quad\text{and}\quad u_{i+2} \neq u_i \qquad (\text{indices mod } n).$$
So
$$\operatorname{trace}(B^n) = \#\{\text{cyclic vertex sequences with consecutive adjacency and no return at distance two}\}.$$

<details>
<summary><b>Why the vertex form is conceptually the important one</b></summary>

It says: *a closed non-backtracking walk is an ordinary closed walk avoiding one local
forbidden pattern*, namely $u_{i+2} = u_i$.

That reframing is what makes further progress plausible. If the constraint is a single
pattern at distance two, inclusion–exclusion on it ought to close up after two correction
terms rather than spawning an infinite hierarchy — which is exactly the content of the
conjectured three-term recursion $A_{m+1} = A A_m - q A_{m-1}$ for the matrices counting
non-backtracking walks between vertices on a $(q+1)$-regular graph.

It also explains why we cannot simply *work* with vertices: the condition $u_{i+2} \ne u_i$
is not a condition on consecutive terms, so no matrix indexed by vertices can encode it.
Darts are the price of locality.
</details>

---

## 5. Reading the sequence: the bottom of the ladder

Let's harvest. Fix a graph and look at the integers
$\operatorname{trace}(B^0), \operatorname{trace}(B^1), \operatorname{trace}(B^2), \dots$

**$n = 0$.** $B^0 = I$, so the trace is the number of darts, $2|E| = \sum_v \deg(v)$. Even
the trivial case says something: walks of length zero *are* the darts.

**$n = 1$ and $n = 2$: always zero.** A closed walk of length $1$ needs $d \to d$; a closed
walk of length $2$ needs $d \to f$ and $f \to d$. Both are impossible. So
$$\operatorname{trace}(B) = \operatorname{trace}(B^2) = 0 \qquad \text{for every graph.}$$
Compare the ordinary adjacency matrix, where $\operatorname{trace}(A^2) = 2|E|$: the entire
length-two closed-walk count of a graph consists of backtracks, and non-backtracking has
swept all of it away.

**$n = 3$: triangles.** A cyclic vertex word of length three is $(a,b,c)$ with $a \sim b$,
$b \sim c$, $c \sim a$ — an *ordered triangle*, and the three adjacencies force the three
vertices distinct. Hence
$$\operatorname{trace}(B^3) = 6 \cdot \#\{\text{triangles}\},$$
the six being three rotations times two orientations. Try $K_4$ in the laboratory: four
triangles, and $\operatorname{trace}(B^3) = 24$.

**Row sums and growth.** How many darts may follow $(u,v)$? All the darts leaving $v$
except $(v,u)$: exactly $\deg(v) - 1$. On a $(q+1)$-regular graph every row sums to $q$,
so every row of $B^n$ sums to $q^n$, and
$$\operatorname{trace}(B^n) \le 2|E| \cdot q^n .$$
The rate is $q$, not $q+1$: one option is always burned on the road you came in by. This
$q$ — and its square root — will return in the spectra below.

---

## 6. Every trace is even

> **Theorem.** $\operatorname{trace}(B^n)$ is an even integer, for every graph and every
> $n$.

The proof is a pairing you can see. Reverse a closed non-backtracking walk: read the darts
backwards and flip each arrow.

<details>
<summary><b>Why the pairing works, and its algebraic shadow</b></summary>

Reversal maps closed non-backtracking walks to closed non-backtracking walks, because
$d \to e$ if and only if $e^{-1} \to d^{-1}$: both statements say "these two arrows compose
and do not undo each other". It is an involution, since flipping twice and reversing twice
are both the identity.

And it has **no fixed point**. If a walk equalled its own reversal, comparing first entries
would give $d_0 = d_n^{-1} = d_0^{-1}$; but a dart never equals its reverse in a loopless
graph. A fixed-point-free involution partitions a finite set into pairs, so the count is
even.

The algebraic statement behind this is elegant. Let $J$ be the permutation matrix of
$d \mapsto d^{-1}$. Then
$$J B J = B^{\mathsf T}.$$
Dart reversal conjugates the Hashimoto matrix into its own transpose — so $B$, though not
symmetric, is similar to its transpose *by an explicit involution*. That is the structural
source of the parity, and of the symmetry visible in the spectra plotted later.
</details>

The demonstration below exhibits the pairing walk by walk and verifies $JBJ = B^{\mathsf
T}$ entrywise.

{{demo:2}}

---

## 7. The sequence sees the cycles, and only the cycles

Now the two theorems that make the trace sequence a genuine diagnostic tool.

> ### Acyclicity Criterion
> A finite simple graph is a **forest** if and only if $\operatorname{trace}(B^n) = 0$ for
> every $n \ge 1$.

> ### Girth Criterion
> If the graph contains a cycle, then
> $$\operatorname{girth}(G) = \min\{\,n \ge 1 : \operatorname{trace}(B^n) \ne 0\,\},$$
> and moreover $2\,\operatorname{girth}(G) \le \operatorname{trace}(B^{\operatorname{girth}(G)})$.

<details>
<summary><b>Proof sketches for both</b></summary>

**Cycles force positive traces.** A cycle of length $m \ge 3$ has pairwise distinct
vertices $u_1,\dots,u_m$, cyclically adjacent. Distinctness gives $u_{i+2} \ne u_i$ for
free, so the vertex form produces at least one admissible word:
$\operatorname{trace}(B^m) \ge 1$.

**Forests kill everything.** Suppose a cyclic non-backtracking word exists. Two
observations. First, a list of darts whose consecutive members compose is the dart list of
a genuine walk in the graph — reassemble it by prepending one edge at a time — and the seam
condition makes that walk *closed*, of length $n \ge 1$. Second, if $d \to e$ then the
underlying **edges** of $d$ and $e$ differ (equality of $\{u,v\}$ and $\{v,y\}$ would force
$u = v$, excluded, or $y = u$, excluded by no-U-turn). So we have a closed walk with
distinct consecutive edges. In a forest, such a walk is a *path* — no repeated vertices —
and a closed path has length $0$. Contradiction.

**Nothing below the girth.** The same reassembly, applied to a word of length $n$, gives a
closed walk of length $n$ with distinct consecutive edges. Let $H$ be the subgraph spanned
by its edges. $H$ cannot be acyclic, by the argument just given, so $H$ contains a cycle of
length at most $|E(H)| \le n$, and that cycle lives in $G$. Hence $\operatorname{girth}(G)
\le n$ whenever the trace at $n$ is nonzero.

**Multiplicity $2m$.** A cycle of length $m$ yields not one word but $2m$: the $m$
rotations of its dart word and the $m$ rotations of its reversal. All $2m$ are distinct,
because the darts of a cycle are pairwise distinct (so rotations separate) and the two
orientations use disjoint dart sets.
</details>

Run the demonstration below: for ten graphs it computes the girth twice — by breadth-first
search and as the first nonzero trace — and confirms they agree, then decomposes the words
at the girth into rotation–reversal orbits and finds every orbit of full size $2g$, one per
shortest cycle.

{{demo:1}}

And here is the same story as a picture: each curve sits on the baseline until its girth,
then jumps to $2g \times (\text{number of shortest cycles})$.

{{visualization:0}}

<details>
<summary><b>The orbit machinery, in code</b></summary>

The orbit decomposition used above is worth seeing in its own right: rotation and reversal
generate a dihedral group of order $2n$ acting on cyclic non-backtracking words, and the
words coming from a cycle form a single free orbit. This is the engine behind the bound
$2g \le \operatorname{trace}(B^g)$, and the evidence for the conjecture that the bound is
an equality once multiplied by the number of shortest cycles.

{{algorithm:2}}
</details>

---

## 8. Adding edges never hurts

> **Theorem (Monotonicity).** If $H$ is a subgraph of $G$ on the same vertices, then
> $\operatorname{trace}(B_H^{\,n}) \le \operatorname{trace}(B_G^{\,n})$ for every $n$.

The reason is one sentence: every dart of $H$ is a dart of $G$, and the non-backtracking
relation depends only on the endpoints of darts, not on the ambient edge set — so every
closed non-backtracking walk of $H$ is one of $G$, and distinct ones stay distinct.

<details>
<summary><b>Why this is not a matrix statement</b></summary>

$B_H$ and $B_G$ do not even have the same size, and for non-symmetric matrices entrywise
domination of a submatrix does not imply domination of the traces of powers. The
combinatorial reading of the trace is what makes the statement accessible at all — a good
illustration of the theorem earning its keep.

You can watch monotonicity in the laboratory: start with $C_5$, then apply the edge list
with one chord added, then two, then the complete graph $K_5$. Every column of the trace
table only goes up.
</details>

---

## 9. The whole dictionary, and the algorithm

| Feature of the sequence | What it says about the graph |
|---|---|
| $\operatorname{trace}(B^0) = 2\lvert E\rvert$ | the number of darts |
| $\operatorname{trace}(B^1) = \operatorname{trace}(B^2) = 0$ | holds for every graph |
| $\operatorname{trace}(B^3)$ | six times the number of triangles |
| every term even | dart reversal pairs walks; $JBJ = B^{\mathsf T}$ |
| identically zero | the graph is a forest |
| index of the first nonzero term | the girth |
| its value, $\ge 2g$ | shortest cycles, each counted $2g$ times |
| monotone under adding edges | more edges, more closed walks |

That table is an algorithm specification, and here is the algorithm: the sparse computation
of the trace prefix, girth detection from it, and the brute-force enumerator used to
cross-check.

{{algorithm:1}}

Finally, the full verification suite — the trace formula and every corollary, exercised on
a library of graphs with exact integer arithmetic and independent enumeration:

{{demo:0}}

---

## 10. Where this leads

The non-backtracking matrix is not a curiosity; it is the pivot of three modern stories.

**Graph zeta functions.** The [Ihara zeta function](https://en.wikipedia.org/wiki/Ihara_zeta_function)
of a graph is an Euler product over primitive closed non-backtracking cycles,
$$\zeta_G(u) = \prod_{[\gamma]}\left(1 - u^{\ell(\gamma)}\right)^{-1},$$
a direct analogue of Euler's product over primes. Taking logarithms turns that product into
a sum over closed non-backtracking walks — which, by the trace formula, is
$\sum_{n\ge1}\operatorname{trace}(B^n)u^n/n = -\log\det(I - uB)$. Ihara's theorem then
collapses the $2|E| \times 2|E|$ determinant to a $|V| \times |V|$ one for regular graphs:
$$\det(I - uB) = (1-u^2)^{|E|-|V|}\det\!\left(I - uA + qu^2 I\right).$$

**Detecting communities in sparse networks.** The top eigenvectors of the adjacency matrix
of a sparse graph localise on high-degree hubs — noise, not signal. A non-backtracking
walker cannot loiter on a hub by oscillating across one edge, so the spectrum of $B$ is
clean, and [non-backtracking spectral methods](https://en.wikipedia.org/wiki/Stochastic_block_model)
detect planted communities in the stochastic block model down to the information-theoretic
threshold, where adjacency-based methods fail outright.

**Expanders.** A $(q+1)$-regular graph is
[Ramanujan](https://en.wikipedia.org/wiki/Ramanujan_graph) — as well-connected as a graph
can be — exactly when the nontrivial spectrum of $B$ lies on the circle of radius
$\sqrt{q}$. That $\sqrt q$ is the square root of the branching factor we met in the row-sum
computation, and the circle is the graph-theoretic critical line:

{{visualization:1}}

---

## 11. What is still open

Three precise conjectures, each testable with the tools on this page.

1. **A Chebyshev recursion.** On a $(q+1)$-regular graph, let $A_m$ count non-backtracking
   walks of length $m$ between vertices. Conjecturally $A_1 = A$, $A_2 = A^2 - (q+1)I$, and
   $A_{m+1} = A A_m - q A_{m-1}$, so that $A_m = P_m(A)$ for a Chebyshev-like polynomial
   and $\operatorname{trace}(B^m)$ is a fixed linear combination of the
   $\operatorname{trace}(A^k)$. The vertex form and the row-sum identity are exactly the
   ingredients such a recursion consumes.
2. **The Ihara identity, combinatorially.** That
   $\sum_n \operatorname{trace}(B^n)u^n/n = -\log\det(I - uB)$ should follow from a
   bijection between cyclic non-backtracking words and multisets of primitive cycles. The
   rotation and reversal stability proved above is precisely the group action such a
   decomposition needs; what remains is orbit–stabiliser bookkeeping.
3. **Exact multiplicity at the girth.** Conjecturally
   $\operatorname{trace}(B^{g}) = 2g \cdot \#\{\text{cycles of length } g\}$ exactly. The
   inequality $\ge$ is a theorem; the converse needs every cyclic word of length exactly
   $g$ to be the dart word of a cycle, which minimality of $g$ ought to force. The orbit
   enumeration above confirms the identity on the pentagon, $K_4$, $K_5$, $K_{3,3}$, the
   cube and the Petersen graph.

---

## 12. One sentence to remember

*A global rule that is not a function of where you are can often be made local by
remembering how you got there.* Darts are that memory; the Hashimoto matrix is what
locality buys; and the trace of its $n$-th power is a graph counting its own cycles.

Go back to the laboratory one more time. Type in a graph of your own. Watch the zeros end.
