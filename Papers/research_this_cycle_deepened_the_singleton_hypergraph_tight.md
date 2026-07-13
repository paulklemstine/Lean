# A Combinatorics–Analysis Bridge for the Isolation Lemma: Exact Counts and Asymptotic Density of Strict-Minimum Assignments

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

The Isolation Lemma asserts that random weights on the elements of a combinatorial
structure single out a unique minimum-weight member with good probability. We study
its sharpest special case — the **singleton hypergraph** on $n$ vertices — where an
assignment is *isolating* precisely when one vertex is a strict minimum. We prove an
exact enumerative identity: among the $d^n$ weight assignments valued in
$\{0,\dots,d-1\}$, the number that are isolating equals $n\sum_{j=0}^{d-1} j^{\,n-1}$,
matching the Faber–Harris lower bound term for term. We then build a bridge from this
combinatorial identity to real analysis, showing that the **density** of isolating
assignments,
$R(n,d)=n\sum_{j<d}j^{\,n-1}/d^{\,n}$, tends to $1$ as $d\to\infty$ for every fixed
$n\ge 1$. The proof is elementary and quantitative: a discrete Mean-Value inequality
$(k+1)x^{k}\le (x+1)^{k+1}-x^{k+1}\le (k+1)(x+1)^{k}$, summed telescopically, traps the
power sum in the two-sided fence $d^{\,n}-n\,d^{\,n-1}\le n\sum_{j<d}j^{\,n-1}\le d^{\,n}$,
whence $1-n/d\le R(n,d)\le 1$ and a squeeze yields the limit. Probabilistically: when the
$n$ weights are drawn independently and uniformly, the probability of a strict minimum
tends to $1$, so ties are asymptotically negligible and the singleton Isolation Lemma is
"almost surely for free" in the large-alphabet limit. We record a min$\leftrightarrow$max
duality producing a second symmetric extremal witness (the co-singleton family), delimit
the failure of a naive general tightness conjecture, and outline sharpenings toward a
quantitative Berry–Esseen form.

**Keywords:** Isolation Lemma, singleton hypergraph, strict minimum, Faber–Harris bound,
power sums, Faulhaber, telescoping, discrete mean value theorem, asymptotic density,
tie-breaking.

## 1. Introduction

### 1.1 Background

The **Isolation Lemma** of Mulmuley, Vazirani and Vazirani is a workhorse of randomized
computation. In its usual form, one is given a nonempty family $\mathcal{F}$ of subsets of
a ground set of $n$ elements; assigning each element an independent uniform weight from
$\{1,\dots,W\}$, with probability at least $1-n/W$ there is a *unique* member of
$\mathcal{F}$ of minimum total weight. Randomness breaks ties among exponentially many
competing structures using only polynomially many random bits. This mechanism underlies
randomized parallel algorithms for matching, the Valiant–Vazirani reduction from general to
unique satisfiability, and numerous derandomization and hardness results.

A natural quantitative question is how *tight* the isolation guarantee is: for which families
does the success probability meet the lower bound exactly, and how does it behave as the
weight range grows? We isolate (so to speak) the sharpest and most transparent case, the
**singleton hypergraph**, and answer both questions completely — first with an exact finite
count, then with an asymptotic density that connects the combinatorics to real analysis.

### 1.2 Contributions

1. **Exact count (Theorem 3.1).** For the singleton hypergraph on $n$ vertices with weights
   in $\{0,\dots,d-1\}$ and zero offset, the number of isolating assignments is exactly
   $n\sum_{j=0}^{d-1} j^{\,n-1}$.
2. **Asymptotic density bridge (Theorem 4.4).** For every fixed $n\ge 1$, the density of
   isolating assignments tends to $1$ as $d\to\infty$; equivalently the probability of a
   strict minimum under uniform i.i.d. weights tends to $1$.
3. **Quantitative fence (Proposition 4.3).** $1-n/d \le R(n,d)\le 1$, an explicit,
   non-asymptotic guarantee.
4. **Structural remarks (Section 5).** A min$\leftrightarrow$max duality yields the
   co-singleton family as a second symmetric extremal witness; a single all-encompassing edge
   shows that a naive "every antichain is extremal for some offset" conjecture is false.

All arguments are elementary and self-contained.

## 2. Definitions

Throughout, $n$ (the number of vertices) and $d$ (the size of the weight range) are natural
numbers. A **weight assignment** is a function $w:\{0,\dots,n-1\}\to\{0,\dots,d-1\}$; there are
$d^n$ of them.

**Definition 2.1 (Hypergraph, inclusion-free).** A *hypergraph* on $n$ vertices is a finite
family $H$ of subsets (edges) of the vertex set $\{0,\dots,n-1\}$. It is *inclusion-free*
(a Sperner family / antichain) if no edge is a proper subset of another: for all
$S,T\in H$ with $S\subseteq T$ we have $S=T$.

**Definition 2.2 (Singleton hypergraph).** The *singleton hypergraph* is the family of all
one-element edges $\{\{i\}: 0\le i<n\}$. It is inclusion-free.

**Definition 2.3 (Strict minimum / isolating).** A weight assignment $w$ **has a strict
minimum** if there is a vertex $i$ with $w(i)<w(j)$ for all $j\ne i$. For the singleton
hypergraph, each edge's weight is a single vertex's weight, so the minimum-weight edge is
unique exactly when $w$ has a strict minimum; such assignments are called **isolating**. We
write
$$
\mathrm{Iso}(n,d)=\{\,w:\{0,\dots,n-1\}\to\{0,\dots,d-1\}\ \mid\ w \text{ has a strict minimum}\,\},
\qquad I(n,d)=\#\mathrm{Iso}(n,d).
$$

**Definition 2.4 (Strict-min-at-$i$ set).** For a vertex $i$, let
$$
\mathrm{Min}_i(n,d)=\{\,w \mid \forall j\ne i,\ w(i)<w(j)\,\}
$$
be the set of assignments for which $i$ is *the* strict minimum.

**Definition 2.5 (Isolation density).** The *isolation density* is
$$
R(n,d)=\frac{I(n,d)}{d^{\,n}}\in[0,1].
$$
Interpreting $w$ as $n$ independent uniform draws from $\{0,\dots,d-1\}$, $R(n,d)$ is exactly
the probability that $w$ has a strict minimum.

## 3. The exact count

**Lemma 3.1 (Fiber count).** Fix a vertex $i$ and a value $m\in\{0,\dots,d-1\}$. The number of
assignments with $w(i)=m$ and $w(j)>m$ for all $j\ne i$ is $(d-1-m)^{\,n-1}$.

*Proof.* The value at $i$ is fixed to $m$. Each of the remaining $n-1$ vertices must take a value
strictly greater than $m$; the number of admissible values in $\{0,\dots,d-1\}$ strictly above
$m$ is $d-1-m$. The choices at distinct vertices are independent, giving a product of $n-1$
factors, i.e. $(d-1-m)^{\,n-1}$. $\qquad\blacksquare$

**Lemma 3.2 (Per-vertex count).** For every vertex $i$,
$$
\#\mathrm{Min}_i(n,d)=\sum_{m=0}^{d-1}(d-1-m)^{\,n-1}=\sum_{j=0}^{d-1} j^{\,n-1},
$$
independent of $i$.

*Proof.* Partition $\mathrm{Min}_i(n,d)$ according to the value $m=w(i)\in\{0,\dots,d-1\}$. By
Lemma 3.1 the block for value $m$ has size $(d-1-m)^{\,n-1}$. Summing over $m$ and reindexing
$j=d-1-m$ (a bijection of $\{0,\dots,d-1\}$ with itself) gives $\sum_{j=0}^{d-1} j^{\,n-1}$. The
result is manifestly independent of $i$. $\qquad\blacksquare$

**Lemma 3.3 (Disjoint decomposition).** The sets $\mathrm{Min}_i(n,d)$, $0\le i<n$, are pairwise
disjoint and their union is $\mathrm{Iso}(n,d)$; hence
$I(n,d)=\sum_{i=0}^{n-1}\#\mathrm{Min}_i(n,d)$.

*Proof.* A strict minimum, when it exists, is unique: if both $i$ and $i'$ ($i\ne i'$) were strict
minima then $w(i)<w(i')$ and $w(i')<w(i)$, a contradiction. Hence the $\mathrm{Min}_i$ are pairwise
disjoint. An assignment lies in some $\mathrm{Min}_i$ iff it has a strict minimum, i.e. iff it lies
in $\mathrm{Iso}(n,d)$; so the union is exactly $\mathrm{Iso}(n,d)$. Cardinality of a disjoint union
is the sum of cardinalities. $\qquad\blacksquare$

**Theorem 3.1 (Exact isolation count).** For all $n,d$,
$$
I(n,d)=n\sum_{j=0}^{d-1} j^{\,n-1}.
$$

*Proof.* Combine Lemmas 3.2 and 3.3: $I(n,d)=\sum_{i=0}^{n-1}\#\mathrm{Min}_i(n,d)
=\sum_{i=0}^{n-1}\sum_{j=0}^{d-1}j^{\,n-1}=n\sum_{j=0}^{d-1}j^{\,n-1}$. $\qquad\blacksquare$

**Remark 3.2 (Faber–Harris tightness).** The right-hand side $n\sum_{j<d}j^{\,n-1}$ is precisely
the Faber–Harris lower bound term for the number of isolating assignments. Theorem 3.1 shows the
singleton hypergraph meets this bound *with equality*: it is an exact extremal witness, not merely
a lower-bound instance.

**Example 3.3.** With $n=d=2$: $I(2,2)=2(0^1+1^1)=2$, out of $2^2=4$ assignments — the two
strict orderings $(0,1)$ and $(1,0)$. With $n=3,d=4$:
$I(3,4)=3(0^2+1^2+2^2+3^2)=3\cdot 14=42$ out of $4^3=64$.

## 4. The analytic bridge: density tends to one

We now pass from the exact finite count to its large-$d$ asymptotics. The heart of the argument
is a discrete Mean-Value inequality.

**Lemma 4.1 (Discrete Mean-Value bounds).** For every real $x\ge 0$ and every integer $k\ge 0$,
$$
(k+1)\,x^{k}\ \le\ (x+1)^{k+1}-x^{k+1}\ \le\ (k+1)\,(x+1)^{k}.
$$

*Proof (sketch).* Both inequalities follow by induction on $k$, or directly from the binomial
theorem. Writing $(x+1)^{k+1}=\sum_{r=0}^{k+1}\binom{k+1}{r}x^{r}$, the difference
$(x+1)^{k+1}-x^{k+1}=\sum_{r=0}^{k}\binom{k+1}{r}x^{r}$ has all nonnegative terms; retaining only
the top term $r=k$ (namely $(k+1)x^{k}$) gives the lower bound. For the upper bound, the same
difference equals $\sum_{r=0}^{k}\binom{k+1}{r}x^{r}\le (k+1)\sum_{r=0}^{k}\binom{k}{r}x^{r}
=(k+1)(x+1)^{k}$, using $\binom{k+1}{r}\le (k+1)\binom{k}{r}$ for $0\le r\le k$. These are the
discrete analogues of $\frac{d}{dt}t^{k+1}=(k+1)t^{k}$ evaluated at the two endpoints of the unit
step. $\qquad\blacksquare$

**Proposition 4.2 (Telescoping sum fence).** For all integers $d\ge 0$ and $k\ge 0$ (over $\mathbb R$),
$$
(k+1)\sum_{j=0}^{d-1} j^{\,k}\ \le\ d^{\,k+1}
\qquad\text{and}\qquad
d^{\,k+1}\ \le\ (k+1)\sum_{j=0}^{d-1} j^{\,k}+(k+1)\,d^{\,k}.
$$

*Proof.* Telescoping gives $d^{\,k+1}=\sum_{j=0}^{d-1}\big((j+1)^{k+1}-j^{k+1}\big)$. Applying the
lower bound of Lemma 4.1 at $x=j$ to each summand yields
$d^{\,k+1}\ge \sum_{j=0}^{d-1}(k+1)j^{\,k}=(k+1)\sum_{j<d}j^{\,k}$, the first inequality. Applying
the upper bound of Lemma 4.1 gives
$d^{\,k+1}\le \sum_{j=0}^{d-1}(k+1)(j+1)^{k}=(k+1)\sum_{j=1}^{d}j^{\,k}
=(k+1)\sum_{j<d}j^{\,k}+(k+1)d^{\,k}$, the second. $\qquad\blacksquare$

**Proposition 4.3 (Quantitative fence for the density).** Writing $n=k+1$, for all $d\ge 1$,
$$
d^{\,n}-n\,d^{\,n-1}\ \le\ n\sum_{j=0}^{d-1} j^{\,n-1}\ \le\ d^{\,n},
\qquad\text{equivalently}\qquad
1-\frac{n}{d}\ \le\ R(n,d)\ \le\ 1.
$$

*Proof.* Put $k=n-1$ in Proposition 4.2. The first inequality there gives the upper wall
$n\sum_{j<d}j^{\,n-1}\le d^{\,n}$. The second gives
$d^{\,n}\le n\sum_{j<d}j^{\,n-1}+n\,d^{\,n-1}$, i.e. the lower wall
$d^{\,n}-n\,d^{\,n-1}\le n\sum_{j<d}j^{\,n-1}$. Dividing the two walls by $d^{\,n}$ and invoking
Theorem 3.1 (so that $I(n,d)=n\sum_{j<d}j^{\,n-1}$) yields $1-n/d\le R(n,d)\le 1$. The upper wall is
of course also immediate from $I(n,d)\le d^{\,n}$. $\qquad\blacksquare$

**Theorem 4.4 (Isolation density tends to one).** For every fixed integer $n\ge 1$,
$$
R(n,d)=\frac{I(n,d)}{d^{\,n}}=\frac{n\sum_{j=0}^{d-1} j^{\,n-1}}{d^{\,n}}\ \xrightarrow[d\to\infty]{}\ 1.
$$
Equivalently, when the $n$ weights are drawn independently and uniformly from $\{0,\dots,d-1\}$, the
probability that the assignment has a strict minimum tends to $1$: ties become asymptotically
negligible.

*Proof.* With $n$ fixed, the lower fence $1-n/d\to 1$ and the upper fence $1\to 1$ as $d\to\infty$.
By Proposition 4.3, $R(n,d)$ lies between them for all $d\ge 1$; the squeeze theorem forces
$R(n,d)\to 1$. $\qquad\blacksquare$

**Corollary 4.5 (Explicit guarantees).** For $n=5$, $d=1000$: $R(5,1000)\ge 1-5/1000=0.995$. For
$n=5$, $d=10^6$: at least $1-5\times10^{-6}$ of all assignments are isolating.

**Remark 4.6 (The analytic value $1/n$).** Theorem 4.4 pins the normalized power sum
$\tfrac{1}{d^n}\sum_{j<d}j^{\,n-1}\to \tfrac1n$, the Riemann-sum limit
$\int_0^1 x^{\,n-1}\,dx=1/n$. The exact combinatorial identity of Theorem 3.1 thus becomes, in the
limit, a statement of elementary analysis; this is the "bridge" of the title.

## 5. Structural remarks and the limits of tightness

**Min–max duality and a second extremal witness.** Reflecting the weight order $v\mapsto (d-1)-v$
exchanges strict minima with strict maxima. Consequently the **co-singleton hypergraph** — whose
edges are the $n$ sets of size $n-1$, so that a "minimum-weight edge" corresponds to a strictly
*largest* vertex — also attains the Faber–Harris bound exactly with zero offset, and its density
likewise tends to $1$. Thus the bound has (at least) two symmetric extremal witnesses: the
singletons ($1$-uniform) and their complements ($(n-1)$-uniform).

**Failure of naive general tightness.** One might conjecture that every inclusion-free hypergraph
attains the bound $n\sum_{j<d}j^{\,n-1}$ for *some* real offset assignment. This is false. Consider
the single-edge hypergraph whose one edge is the entire vertex set. Every weight assignment has a
minimum-weight edge (there is only one edge), so *every* assignment is isolating and the count is
the full $d^{\,n}$, for *all* offsets. Already at $n=d=2$ this gives $4>2$, strictly above the
bound. Offset freedom cannot repair an over-counting family. Even genuinely covering antichains
such as $\{\{0,1\},\{0,2\}\}$ overshoot the bound for every offset. A fully general theorem
quantifying failure over the continuum of real offsets requires reducing that continuum to the
finite set of order-types — an appealing next step.

**Toward a characterization.** Computation for $n=3$ shows that exactly the singletons and the
co-singletons (all-pairs) reach the bound in the offset-free problem. A tempting conjecture is
that an antichain attains the bound iff it is vertex-transitive and "sum-symmetric" (e.g. suitable
$k$-uniform complete designs), but a clean criterion — and the status of intermediate $k$-uniform
complete families — remains open.

## 6. Algorithms

We record the direct computational counterparts of the theory.

**Algorithm A (Exact isolation count).** Given $n,d$, return $I(n,d)=n\sum_{j=0}^{d-1}j^{\,n-1}$ by
summing $d$ power terms. Time $O(d\log n)$ arithmetic operations (or $O(d)$ with repeated squaring
amortized); space $O(1)$. This is exponentially faster than the $O(n\,d^n)$ brute-force enumeration
of all assignments and is exact via Theorem 3.1.

**Algorithm B (Brute-force verification).** Enumerate all $d^n$ assignments, test each for a strict
minimum, and count. Time $O(n\,d^n)$; used to cross-check Algorithm A on small inputs.

**Algorithm C (Density fence and convergence certificate).** Given $n$ and a target error
$\varepsilon>0$, return the smallest $d$ with $n/d\le\varepsilon$, i.e. $d=\lceil n/\varepsilon\rceil$;
by Proposition 4.3 this certifies $R(n,d)\ge 1-\varepsilon$ without enumeration.

## 7. Applications

- **Sizing random tie-breaking.** Proposition 4.3 converts a desired isolation confidence
  $1-\varepsilon$ into a concrete weight range $d\ge n/\varepsilon$, a design rule for the
  singleton (and co-singleton) case with no hidden constants.
- **Sanity oracle for isolation heuristics.** The exact count $n\sum_{j<d}j^{\,n-1}$ is a closed-form
  ground truth against which empirical estimates of isolation probability can be validated.
- **Extremal benchmark.** As an exact extremal witness for the Faber–Harris bound, the singleton
  family calibrates how far more complex families sit above the bound (the "excess").

## 8. Discussion

The value of the result lies in its bridge structure: an *exact* enumerative identity in finite
combinatorics is transported, by a two-line telescoping sandwich, into a *limit* theorem of analysis
and a *probability* statement. The tools are deliberately minimal — a discrete Mean-Value inequality,
telescoping, and a squeeze — yet they yield both an asymptotic ($R\to 1$) and a non-asymptotic
($1-n/d\le R\le 1$) conclusion. The min–max duality and the single-edge counterexample sharply mark
the boundary of the phenomenon: the clean formula is a feature of the extreme uniform families, not a
universal law.

## 9. Future directions

- **Rate of convergence / second-order term.** The fence $1-n/d\le R(n,d)\le 1$ can be sharpened: the
  excess $1-R(n,d)$ behaves like $(n-1)/(2d)+O(1/d^2)$ via the Euler–Maclaurin correction to
  Faulhaber's formula. A precise $1-R(n,d)=(n-1)/(2d)+O(1/d^2)$ would upgrade the bridge to a
  quantitative, Berry–Esseen-style statement.
- **General hypergraphs.** Does an analogous density limit hold for the isolating count of an
  arbitrary inclusion-free hypergraph (with a fixed or optimal offset)? Singletons and co-singletons
  both give density $\to 1$; whether *every* Sperner family isolates almost surely as $d\to\infty$ is
  open and would connect Sperner theory to a $0$–$1$ law.
- **Probabilistic formalization.** Recast Theorem 4.4 directly in terms of uniform product measures so
  that "the probability of a strict minimum tends to $1$" is literal rather than a ratio of
  cardinalities.
- **Joint limit in $(n,d)$.** For scaling regimes $n=n(d)\to\infty$, when does the density still tend
  to $1$ versus degenerate to $0$? The fence $1-n/d$ suggests a phase transition near $n\asymp d$; a
  precise threshold is open.
- **Extremal characterization.** Characterize the antichains attaining the offset-free bound
  (conjecturally vertex-transitive, sum-symmetric families), and resolve which intermediate
  $k$-uniform complete families are extremal. Develop the invariant
  $\mathrm{excess}(H)=\min_f \#\mathrm{isolating}(H,f)-B(n,d)\ge 0$ (monotonicity, additivity under
  disjoint unions).

## 10. Conclusion

For the singleton hypergraph, the number of isolating weight assignments in $\{0,\dots,d-1\}^n$ is
exactly $n\sum_{j=0}^{d-1}j^{\,n-1}$, meeting the Faber–Harris bound with equality; and the density of
such assignments is trapped in $[1-n/d,\,1]$ and converges to $1$ as $d\to\infty$. The passage from
the exact count to the limit is a self-contained telescoping sandwich built on a discrete Mean-Value
inequality — a compact bridge from finite combinatorics to real analysis, with a clean probabilistic
reading: give randomness enough room, and ties disappear.
