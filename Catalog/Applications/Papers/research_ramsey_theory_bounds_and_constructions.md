# Finite Two-Colour Ramsey Theory: The Erdős–Szekeres Bound and the Exact Value $R(3,3)=6$

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Applications (Combinatorics / Graph Theory)

## Abstract

We present a self-contained, formally verified development of the elementary theory
of finite two-colour Ramsey numbers. Working with a single `SimpleGraph` to encode a
red/blue edge colouring of a complete graph — red edges being those of the graph and
blue edges those of its complement — we define the *arrow relation* $n \to (s,t)$ and
establish three pillars of the theory. First, the relation is monotone in the number
of vertices. Second, we prove the Erdős–Szekeres inductive step
$m \to (s,t+1)$ and $n \to (s+1,t)$ imply $(m+n) \to (s+1,t+1)$, and from it the
binomial upper bound $\binom{s+t}{s} \to (s+1,t+1)$, equivalently
$R(s+1,t+1) \le \binom{s+t}{s}$. Third, we determine the first nontrivial Ramsey
number exactly: $\binom{4}{2}=6$ gives $6 \to (3,3)$, while the pentagon (the cycle
$C_5$) gives an explicit colouring of $K_5$ with no monochromatic triangle, so
$\lnot(5 \to (3,3))$. Together these yield $R(3,3)=6$. All statements correspond to
machine-checked theorems; we give their full mathematical statements and proof
sketches. We close with the asymptotic landscape and a programme of future
extensions (exact off-diagonal values, the probabilistic diagonal lower bound, and a
reusable `RamseyNumber` object).

## 1. Introduction

Ramsey theory studies the inevitability of order in large structures: sufficiently
large systems necessarily contain highly organized substructures, regardless of how
they are built. Its prototypical statement concerns edge colourings of complete
graphs. Given two "colours", any sufficiently large complete graph contains a
monochromatic clique of prescribed size. The least size at which this becomes
unavoidable is the **Ramsey number** $R(s,t)$.

### 1.1 Historical context

The subject grew out of Frank Ramsey's 1930 paper *On a problem of formal logic*,
where a finite combinatorial lemma was extracted to settle a decision problem about
logical formulas. Ramsey's lemma — in its two-colour graph form, that for every $s,t$
there is a finite $N$ with $N \to (s,t)$ — was rediscovered and dramatically amplified
by Paul Erdős and George Szekeres in their 1935 work on convex polygons in the plane,
where the same recursion that we formalize here (Theorem 6) appears as the engine
behind the *happy ending problem*. Erdős's 1947 probabilistic lower bound for the
diagonal numbers $R(s,s)$ launched the probabilistic method as a pervasive tool in
combinatorics. The interplay these three contributions established — an explicit
recursion bounding Ramsey numbers from above, and probabilistic or constructive
arguments bounding them from below — remains the template for the entire field. The
present development formalizes the upper-bound recursion in full generality and
closes the smallest nontrivial case, $R(3,3)$, exactly, by supplying the matching
constructive lower bound.

### 1.2 Why formalize, and what is formalized

Ramsey-theoretic arguments are notorious for hiding subtle off-by-one errors in the
bookkeeping of clique sizes, vertex counts, and the colour bookkeeping of "red versus
blue". Encoding the entire argument so that a proof assistant checks every inference
removes this class of error. Two design decisions make the formalization clean. First,
a *single* simple graph $G$ encodes the whole two-colouring: red edges are the edges of
$G$, blue edges are the edges of the complement $G^{c}$. This avoids carrying a separate
data structure for the colouring and makes "red clique" and "blue clique" literally
"clique of $G$" and "clique of $G^{c}$". Second, the arrow relation is quantified over an
arbitrary vertex type and an arbitrary finite subset $W$, rather than over a fixed
complete graph on exactly $n$ labelled vertices. As we explain in Section 3, this single
choice makes monotonicity in the number of vertices a one-line consequence and lets the
two recursive calls in the Erdős–Szekeres step operate on subsets of one fixed ambient
vertex set, sidestepping the need to transport cliques across different index types.

This paper records a rigorous, formalized account of the first quantitative results of
the theory:

1. **Monotonicity** of the arrow relation (Proposition 4).
2. The **Erdős–Szekeres recursion** (Theorem 6) and the resulting **binomial upper
   bound** (Theorem 7, Corollary 8).
3. The **exact value $R(3,3)=6$** (Theorem 9), via the binomial bound for the upper
   half and the pentagon construction for the lower half.

Each result below is stated in full and accompanied by a proof sketch faithful to the
underlying formal proof. We are careful to claim only what is proved: the
off-diagonal values $R(3,4)=9$, $R(4,4)=18$, the diagonal probabilistic lower bound,
and the Hales–Jewett theorem are discussed as context and future work, not as results
established here.

## 2. The colouring model

**Definition 1 (Two-colouring as a graph).** A red/blue colouring of the complete
graph on a vertex type $V$ is a simple graph $G$ on $V$. An edge $\{u,v\}$ is *red* if
$u \sim_G v$ and *blue* if $u \sim_{G^{c}} v$, where $G^{c}$ is the complement graph.
Thus the red subgraph is $G$ and the blue subgraph is $G^{c}$, and every (non-loop)
pair is exactly one colour.

**Definition 2 (Ambient type).** For the canonical setting on $s+t$ vertices we write
`ArrowsType s t := SimpleGraph (Fin (s+t))`, the type of red/blue colourings of
$K_{s+t}$.

A *red $s$-clique* is a set $S$ with $G$.`IsNClique` $s\,S$: an $s$-element vertex set
all of whose pairs are red. A *blue $t$-clique* is a set $S$ with $G^{c}$.`IsNClique`
$t\,S$.

**Definition 3 (Arrow relation).** For $n,s,t \in \mathbb{N}$, define $n \to (s,t)$,
formally `Arrows n s t`, to hold iff: for every vertex type $V$, every colouring
$G : \mathrm{SimpleGraph}\,V$, and every finite vertex set $W$ with $|W| \ge n$, there
exists $S \subseteq W$ that is a red $s$-clique, or there exists $S \subseteq W$ that
is a blue $t$-clique. Symbolically,
$$
n \to (s,t) \;:\equiv\; \forall V\,\forall G\,\forall W\,\bigl(|W|\ge n \Rightarrow
(\exists S\subseteq W,\ G.\mathrm{IsNClique}\,s\,S)\ \lor\
(\exists S\subseteq W,\ G^{c}.\mathrm{IsNClique}\,t\,S)\bigr).
$$

Quantifying over an arbitrary vertex type together with a finite subset $W$ has two
benefits: it bakes monotonicity in the vertex count directly into the definition, and
it lets the Erdős–Szekeres recursion operate on subsets of a fixed vertex set, so the
two recursive calls land in the same ambient type.

**Definition (Ramsey number).** $R(s,t) := \min\{\, n : n \to (s,t)\,\}$, the least
threshold at which the arrow relation holds. By monotonicity this minimum exists
whenever the predicate is ever satisfied.

## 3. Monotonicity

**Proposition 4 (`Arrows.mono`).** If $n \to (s,t)$ and $n \le n'$, then
$n' \to (s,t)$.

*Proof sketch.* Let $W$ be a vertex set with $|W| \ge n'$. Then $|W| \ge n' \ge n$, so
the hypothesis $n \to (s,t)$ applies to $W$ directly and produces the required
monochromatic clique. $\qquad\blacksquare$

This says the predicate $N \mapsto (N \to (s,t))$ is upward closed: the set of valid
thresholds is an up-set in $\mathbb{N}$, which is precisely what guarantees that
$R(s,t)$, defined as an infimum, is attained and satisfies
$n \to (s,t) \iff R(s,t) \le n$.

## 4. Base cases

**Lemma 5a (`arrows_one_red`).** For every $b$, $\;1 \to (1,b)$.

*Proof sketch.* If $|W| \ge 1$, pick $v \in W$. The singleton $\{v\}$ is a red
$1$-clique (a one-vertex set is vacuously a clique and has cardinality $1$). Hence the
left disjunct holds. $\qquad\blacksquare$

**Lemma 5b (`arrows_one_blue`).** For every $a$, $\;1 \to (a,1)$.

*Proof sketch.* Symmetric: a singleton $\{v\}$ is a blue $1$-clique in $G^{c}$, giving
the right disjunct. $\qquad\blacksquare$

These two facts seed the double induction of Section 5.

## 5. The Erdős–Szekeres recursion and the binomial bound

**Theorem 6 (Inductive step, `arrows_step`).** Let $m,n \ge 1$. If
$$ m \to (s,\,t+1) \qquad\text{and}\qquad n \to (s+1,\,t), $$
then
$$ (m+n) \to (s+1,\,t+1). $$

*Proof sketch.* Let $W$ be a colouring domain with $|W| \ge m+n$. Since
$m+n \ge 1$, choose a vertex $v \in W$. Partition the remaining vertices $W\setminus\{v\}$
by the colour of their edge to $v$:
$$ R := \{x \in W\setminus\{v\} : x \sim_G v\}, \qquad
   B := \{x \in W\setminus\{v\} : x \not\sim_G v\}. $$
Every non-$v$ vertex lies in exactly one part, so $|R| + |B| = |W| - 1 \ge m+n-1$.
By pigeonhole, $|R| \ge m$ or $|B| \ge n$.

*Case $|R| \ge m$.* Apply $m \to (s,t+1)$ to $R$. Either we obtain a blue
$(t+1)$-clique $S \subseteq R \subseteq W$ — and the right disjunct of the goal holds
immediately — or we obtain a red $s$-clique $S \subseteq R$. Every vertex of $R$ is
red-adjacent to $v$, and $v \notin S$, so $S \cup \{v\}$ is a red clique of size
$s+1$, giving the left disjunct.

*Case $|B| \ge n$.* Symmetric. Apply $n \to (s+1,t)$ to $B$. Either a red
$(s+1)$-clique appears (left disjunct), or a blue $t$-clique $S \subseteq B$ appears;
since every vertex of $B$ is blue-adjacent to $v$, $S \cup \{v\}$ is a blue
$(t+1)$-clique (right disjunct). $\qquad\blacksquare$

**Theorem 7 (Binomial upper bound, `arrows_recursion`).** For all $s,t \in
\mathbb{N}$,
$$ \binom{s+t}{s} \to (s+1,\,t+1). $$

*Proof sketch.* Double induction on $s$ and $t$.

- *Base $s=0$:* $\binom{t}{0}=1$ and the claim is $1 \to (1,t+1)$, which is Lemma 5a.
- *Base $t=0$ (within the inductive step on $s$):* $\binom{s+1}{s+1}=1$ and the claim
  is $1 \to (s+2,1)$, which is Lemma 5b.
- *Inductive step:* Assume $\binom{(s)+(t+1)}{s} \to (s+1,t+2)$ and
  $\binom{(s+1)+t}{s+1} \to (s+2,t+1)$. By Theorem 6 (with both thresholds positive,
  as binomial coefficients of valid arguments are $\ge 1$),
  $$ \Bigl(\tbinom{s+t+1}{s} + \tbinom{s+t+1}{s+1}\Bigr) \to (s+2,\,t+2). $$
  By **Pascal's rule** $\binom{s+t+1}{s} + \binom{s+t+1}{s+1} = \binom{s+t+2}{s+1}$,
  the threshold is exactly $\binom{(s+1)+(t+1)}{s+1}$, completing the induction.
  $\qquad\blacksquare$

**Corollary 8 (`arrows_binomial_bound`).** For all $s,t$,
$\binom{s+t}{s} \to (s+1,t+1)$; equivalently $R(s+1,t+1) \le \binom{s+t}{s}$. In the
classical shifted indices, $R(s,t) \le \binom{s+t-2}{s-1}$.

*Proof.* Restatement of Theorem 7. $\qquad\blacksquare$

## 6. The exact value $R(3,3)=6$

**Theorem 9 (Upper half, `arrows_three_three`).** $6 \to (3,3)$.

*Proof sketch.* Specialize Theorem 7 to $s=t=2$: $\binom{2+2}{2}=\binom{4}{2}=6$, so
$6 \to (3,3)$. Hence every red/blue colouring of $K_6$ contains a monochromatic
triangle, giving $R(3,3) \le 6$. $\qquad\blacksquare$

For the matching lower bound we exhibit an extremal colouring of $K_5$.

**Definition 10 (Pentagon, `pentagon`).** On the vertex set $\mathbb{Z}/5\mathbb{Z}
\cong \mathrm{Fin}\,5$, let `pentagon` be the symmetric closure of the relation
$a+1=b$; that is, $a \sim b$ iff $a+1=b$ or $b+1=a$ (indices mod 5). This is the
$5$-cycle $C_5$, taken as the red subgraph. Its complement is the "pentagram", which
is again a $5$-cycle.

**Lemma 11a (`pentagon_no_triangle`).** There is no $S$ with `pentagon`.`IsNClique`
$3\,S$: the pentagon contains no red triangle.

*Proof sketch.* A finite exhaustive check over all $3$-subsets of $\mathrm{Fin}\,5$.
A $5$-cycle is triangle-free: any three of its vertices include a non-adjacent pair.
$\qquad\blacksquare$

**Lemma 11b (`pentagon_compl_no_triangle`).** There is no $S$ with
`pentagon`$^{c}$.`IsNClique` $3\,S$: the complement contains no blue triangle.

*Proof sketch.* The complement of $C_5$ on five vertices is again a $5$-cycle, hence
triangle-free by the same exhaustive check. $\qquad\blacksquare$

**Theorem 9 (Lower half, `not_arrows_five_three_three`).** $\lnot(5 \to (3,3))$, i.e.
$R(3,3) > 5$.

*Proof sketch.* Suppose $5 \to (3,3)$. Apply it to the pentagon colouring on the full
vertex set of $\mathrm{Fin}\,5$ ($|{\rm univ}| = 5$). It would yield a red triangle or
a blue triangle, contradicting Lemmas 11a and 11b respectively. $\qquad\blacksquare$

**Corollary (Exact value).** Combining the two halves,
$$ R(3,3) = 6. $$
Theorem 9 (upper) gives $R(3,3) \le 6$ and Theorem 9 (lower) gives $R(3,3) \ge 6$.

## 6b. A worked example: the direct pigeonhole argument for $K_6$

It is instructive to see how Theorem 6 specializes, at $s=t=2$, to the classical
one-vertex argument for $K_6$, because the general inductive step is exactly this
argument with the two recursive calls abstracted away.

Fix any red/blue colouring of $K_6$ and a vertex $v$. The five edges from $v$ are each
red or blue, so by pigeonhole at least $\lceil 5/2 \rceil = 3$ of them share a colour;
say (after swapping colours if necessary) three are red, joining $v$ to $a,b,c$. This is
the step "$|R| \ge 3$" of Theorem 6 with $m=3$: it uses $3 \to (2,3)$, which holds
because among any three vertices either two are joined by a red edge or all three pairs
are blue. Concretely, examine the triangle on $\{a,b,c\}$:

- If any one of the edges $ab,ac,bc$ is red, say $ab$, then $\{v,a,b\}$ is a red triangle
  — the red $s$-clique $\{a,b\}$ inside $R$ extended by $v$, exactly the
  "$S \cup \{v\}$" construction of the proof of Theorem 6.
- If none of $ab,ac,bc$ is red, then $\{a,b,c\}$ is a blue triangle — the blue
  $(t)$-clique that the recursion returns directly without attaching $v$.

Either way a monochromatic triangle exists, so $6 \to (3,3)$, matching
`arrows_three_three`. The same colour-counting at a single vertex, applied with the
general thresholds $m,n$ instead of the constant $3$, is the entire content of
`arrows_step`. The numerical demonstration accompanying this paper verifies the
statement the hard way as well, by exhaustively confirming that all $2^{15}=32768$
colourings of $K_6$ contain a monochromatic triangle while the pentagon colouring of
$K_5$ does not.

## 6c. Numerical landscape of the binomial bound

The table below lists the binomial ceilings $\binom{s+t-2}{s-1}$ produced by
Corollary 8 next to the true Ramsey numbers (the latter taken from the literature; only
$R(3,3)=6$ is established in this development). It shows both the strength of the bound
for the diagonal-adjacent small cases and how it loosens as the indices grow.

| $(s,t)$ | bound $\binom{s+t-2}{s-1}$ | true $R(s,t)$ |
|---|---|---|
| $(2,2)$ | $2$ | $2$ |
| $(3,3)$ | $6$ | $6$ (proved here) |
| $(3,4)$ | $10$ | $9$ |
| $(4,4)$ | $20$ | $18$ |
| $(3,5)$ | $15$ | $14$ |
| $(4,5)$ | $35$ | $25$ |

The bound is tight at $(2,2)$ and $(3,3)$ and within a small additive gap for the next
few off-diagonal cases, but the gap widens quickly, foreshadowing the exponential
separation discussed in Section 9.

## 7. Algorithms

The verified statements correspond to two natural algorithms.

**Algorithm A — Erdős–Szekeres recursive upper-bound evaluator.** Compute an upper
bound for $R(s,t)$ by the recursion $f(s,t) = f(s-1,t) + f(s,t-1)$ with base cases
$f(1,t)=f(s,1)=1$, which evaluates to $\binom{s+t-2}{s-1}$. Memoized, it runs in
$O(st)$ arithmetic operations and reproduces $f(3,3)=6$, $f(3,4)=10$, $f(4,4)=20$
(valid ceilings; the true values $9$ and $18$ require constructions beyond the bound).

**Algorithm B — Exhaustive monochromatic-triangle certifier.** Given an explicit
colouring of $K_n$ (e.g. the pentagon on $K_5$), enumerate all $\binom{n}{3}$ vertex
triples and test each for being monochromatic. This certifies the two pentagon lemmas
($C_5$ and its complement are triangle-free) and, dually, confirms that every
colouring of $K_6$ contains a monochromatic triangle.

## 8. Applications

Ramsey-type guarantees appear throughout mathematics, computer science, and beyond:

- **Social networks:** any group of six people contains three mutual acquaintances or
  three mutual strangers — the friendship theorem folklore form of $R(3,3)=6$.
- **Data and coincidences:** large datasets necessarily contain repeated patterns;
  Ramsey bounds quantify how large is "large enough".
- **Sequences:** the Erdős–Szekeres monotone-subsequence theorem (a sibling of the
  bound proved here) underlies algorithms in sorting and patience-style games.
- **Lower bounds in complexity:** Ramsey arguments produce unavoidable structure that
  features in communication-complexity and circuit lower bounds.

## 9. Discussion and the asymptotic landscape

The binomial bound shows $R(s,s) \le \binom{2s-2}{s-1} = O(4^s)$. Erdős's
probabilistic argument gives $R(s,s) > 2^{s/2}$ for large $s$. Despite ninety years of
effort the base of the exponential is unknown; only marginal improvements to the
constants are known. Exact values are extraordinarily scarce: $R(3,3)=6$,
$R(3,4)=9$, $R(4,4)=18$, with $R(5,5)$ known only to lie in $[43,48]$. The present
development supplies the verified foundation — model, recursion, binomial ceiling, and
the first exact value — on which sharper results can be built.

## 9b. Related results and the formalization landscape

The arrow relation and the binomial bound sit at the head of a large family of
Ramsey-type theorems. The *infinite* Ramsey theorem guarantees a monochromatic infinite
clique in any finite colouring of the edges of a countable complete graph, and implies
the finite version by a compactness argument. The *hypergraph* Ramsey theorem replaces
edges by $k$-element sets and underlies the Erdős–Szekeres geometric application. Van
der Waerden's theorem and the Hales–Jewett theorem are the arithmetic and combinatorial
"density" cousins, asserting unavoidable monochromatic arithmetic progressions and
combinatorial lines, respectively. All share the moral that sufficiently large structures
cannot be globally disordered.

Within the present formalization, the deliberate genericity of `Arrows` over an arbitrary
vertex type means the same statements specialize without change to any concrete host
graph; for instance the application to the full vertex set of $\mathrm{Fin}\,5$ in the
proof of Theorem 9 (lower) is just one instance of the universally quantified definition.
The two finite `decide` checks (`pentagon_no_triangle` and `pentagon_compl_no_triangle`)
illustrate a general technique: for explicit small graphs with a decidable adjacency
relation, clique-freeness is a decidable proposition, so the lower-bound half of an exact
Ramsey value reduces to a terminating finite computation. This is precisely the lever the
future directions exploit to attack $R(3,4)$ and $R(4,4)$ via circulant and Paley graphs.

## 10. Future directions

**A reusable `RamseyNumber` object.** Package exactness via
$\mathrm{RamseyNumber}\,s\,t := \inf\{N : N \to (s,t)\}$ together with an `IsLeast`
characterization. Because monotonicity already shows $N \mapsto (N \to (s,t))$ is
upward closed, the infimum is attained and $N \to (s,t) \iff \mathrm{RamseyNumber}\,s\,t
\le N$ becomes a single bridge lemma. Concrete values then read uniformly as
$\mathrm{RamseyNumber}\,s\,t = c$, and the recursion becomes
$\mathrm{RamseyNumber}(s{+}1,t{+}1) \le \mathrm{RamseyNumber}(s,t{+}1) +
\mathrm{RamseyNumber}(s{+}1,t)$.

**Diagonal lower bound $R(s,s) > 2^{s/2}$ by counting.** Make the probabilistic step
finitary: over `SimpleGraph (Fin n)` as a `Fintype`, if the number of graphs
containing a monochromatic $s$-clique is strictly less than the total number of
graphs, a clique-avoiding colouring exists. Both counts are explicit binomial
expressions, so the historically probabilistic result becomes a finite arithmetic
inequality reusing the existing `IsNClique`/complement vocabulary.

**Off-diagonal exact values $R(3,4)=9$ and $R(4,4)=18$.** The recursion supplies upper
bounds; the matching lower bounds need explicit constructions. The decidable-clique
infrastructure used for the pentagon scales to circulant graphs: $R(3,4)=9$ is
witnessed by a specific graph on $\mathrm{Fin}\,8$ and $R(4,4)=18$ by the Paley graph
on $\mathrm{Fin}\,17$, both circulant and hence `decide`-friendly.

**The Hales–Jewett theorem.** A density/colouring cornerstone of Ramsey theory whose
formalization would generalize the combinatorial-line phenomenon underlying van der
Waerden's theorem.

## Appendix: Index of formal results

- `Arrows` — Definition 3.
- `Arrows.mono` — Proposition 4.
- `arrows_one_red`, `arrows_one_blue` — Lemmas 5a, 5b.
- `arrows_step` — Theorem 6.
- `arrows_recursion`, `arrows_binomial_bound` — Theorem 7, Corollary 8.
- `arrows_three_three` — Theorem 9 (upper).
- `pentagon`, `pentagon_no_triangle`, `pentagon_compl_no_triangle`,
  `not_arrows_five_three_three` — Definition 10, Lemmas 11a/11b, Theorem 9 (lower).
