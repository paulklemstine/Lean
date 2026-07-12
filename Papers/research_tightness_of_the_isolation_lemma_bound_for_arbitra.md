# Tightness of the Isolation Lemma Bound for Arbitrary Edge Offsets

## Abstract

The Isolation Lemma of Mulmuley, Vazirani, and Vazirani (1987) guarantees that a
random weighting of the elements of a set system isolates a unique
minimum-weight member with high probability. Its refined counting form, studied
by Faber and Harris (2018), establishes the sharp global lower bound

$$\#\{\text{isolating weight assignments}\} \;\ge\; n \cdot \sum_{j=0}^{d-1} j^{\,n-1}$$

for every inclusion-free (Sperner) hypergraph on $n$ vertices whose vertices are
weighted from $\{0, 1, \dots, d-1\}$. We prove the exact combinatorial identity
that underlies the tightness of this bound. For the *singleton hypergraph*
$\{\{v\} : v \in V\}$ equipped with the zero edge offset, an assignment is
isolating exactly when a single vertex attains the strict minimum weight, and we
establish that the number of such assignments equals *exactly*
$n \cdot \sum_{j=0}^{d-1} j^{\,n-1}$. Consequently the Faber–Harris bound is
globally tight, and the singleton hypergraph is an explicit extremal witness
attaining it term for term. We present the full argument via a fiberwise
decomposition over the argmin vertex and the minimum value, verify the identity
numerically over a grid of parameters, analyze its boundary behavior, and
formulate a family of conjectures on per-hypergraph tightness under nonzero
offsets.

**Keywords:** Isolation Lemma, inclusion-free hypergraph, Sperner family,
isolating weight assignment, extremal combinatorics, power-sum identity,
minimum-weight uniqueness.

---

## 1. Introduction

### 1.1 Background

The Isolation Lemma is one of the most versatile probabilistic tools in
theoretical computer science. In its original form, given a set system — a
family $\mathcal{F}$ of subsets of a ground set $V$ of size $n$ — and a random
weighting $w : V \to \{1, \dots, N\}$ of the ground set, the minimum-weight
member of $\mathcal{F}$ (where the weight of a set is the sum of its elements'
weights) is unique with probability at least $1 - n/N$. This "isolation" of a
unique optimum is the linchpin of parallel algorithms for perfect matching, of
the Valiant–Vazirani reduction from `SAT` to `UniqueSAT`, and of numerous
derandomization and complexity-theoretic constructions.

Behind the probabilistic statement lies a purely combinatorial *counting*
question: exactly how many weight assignments isolate a unique minimum-weight
member? Faber and Harris (2018) sharpened the picture by proving a tight *lower
bound* on this count that holds uniformly across all inclusion-free hypergraphs.
Their result raises an immediate extremal question: is the lower bound ever
attained exactly, and if so, by what structure? This paper answers that question
completely for the canonical case.

### 1.2 Contributions

1. We give an exact closed-form count of the isolating assignments for the
   singleton hypergraph with zero offset, showing it equals
   $n \cdot \sum_{j=0}^{d-1} j^{\,n-1}$ (Theorem 4.1).
2. We prove that the informal "$\exists!$ minimum" notion of isolation and the
   "strict minimum" formulation coincide (Proposition 3.2), so the count is not a
   weakening of the intended definition.
3. We establish global tightness of the Faber–Harris lower bound: the singleton
   hypergraph is an explicit extremal witness (Corollary 4.2).
4. We verify the identity numerically, analyze its degenerate boundaries
   ($n = 0$, $n = 1$, $d \le 1$), and formulate precise conjectures for the
   general per-hypergraph tightness problem (Section 7).

---

## 2. Definitions

Throughout, $n$ (the number of vertices) and $d$ (the number of allowed weight
values) are natural numbers. We identify the vertex set with
$[n] = \{0, 1, \dots, n-1\}$ and the weight alphabet with
$[d] = \{0, 1, \dots, d-1\}$.

**Definition 2.1 (Weight assignment).** A *weight assignment* is a function
$w : [n] \to [d]$. There are exactly $d^n$ such assignments.

**Definition 2.2 (Hypergraph).** A *hypergraph* on $[n]$ is a finite family
$H$ of subsets ("edges") of $[n]$.

**Definition 2.3 (Inclusion-free / Sperner).** A hypergraph $H$ is
*inclusion-free* (equivalently, a *Sperner family* or *antichain*) if no edge is
a subset of another distinct edge: whenever $S, T \in H$ and $S \subseteq T$, we
have $S = T$.

**Definition 2.4 (Edge offset and edge weight).** An *edge offset* is a function
$f : H \to \mathbb{R}$. Under an assignment $w$, the *weight* of an edge
$S \in H$ is
$$\operatorname{wt}_{w,f}(S) \;=\; f(S) + \sum_{v \in S} w(v).$$
The *zero offset* is $f \equiv 0$, giving $\operatorname{wt}_{w,0}(S) = \sum_{v\in S} w(v)$.

**Definition 2.5 (Isolating assignment).** An assignment $w$ is *isolating* for
$(H, f)$ if a unique edge $S \in H$ attains the minimum edge weight
$\min_{T \in H} \operatorname{wt}_{w,f}(T)$.

**Definition 2.6 (Singleton hypergraph).** The *singleton hypergraph* on $[n]$ is
$$H_n^{\mathrm{sing}} = \{\{v\} : v \in [n]\}.$$

For the singleton hypergraph with zero offset, the weight of the edge $\{v\}$ is
$\operatorname{wt}_{w,0}(\{v\}) = w(v)$. Hence an assignment is isolating for
$(H_n^{\mathrm{sing}}, 0)$ exactly when a unique *vertex* attains the minimum
vertex weight. This reduction is the reason the singleton case is the cleanest
model of the general lemma.

---

## 3. Two formulations of isolation and their equivalence

For the singleton hypergraph we phrase the isolating condition in two ways.

**Definition 3.1.** For $w : [n] \to [d]$:

- $w$ *has a unique argmin* if
  $\exists!\, i \in [n]$ such that $w(i) \le w(j)$ for all $j \in [n]$.
- $w$ *has a strict minimum* if
  $\exists\, i \in [n]$ such that $w(i) < w(j)$ for all $j \neq i$.

**Proposition 3.2 (Equivalence).** For every assignment $w$, $w$ has a unique
argmin if and only if $w$ has a strict minimum.

*Proof.* ($\Rightarrow$) Suppose $i$ is the unique argmin: $w(i) \le w(j)$ for all
$j$, and $i$ is the only index with this property. For any $j \neq i$, either
$w(i) < w(j)$ (done) or $w(i) = w(j)$. In the latter case $w(j) \le w(k)$ for all
$k$ as well (since $w(j) = w(i) \le w(k)$), so $j$ would also be an argmin,
contradicting uniqueness. Hence $w(i) < w(j)$ for all $j \neq i$, i.e. $i$ is a
strict minimum.

($\Leftarrow$) Suppose $i$ is a strict minimum: $w(i) < w(j)$ for all $j \neq i$.
Then $w(i) \le w(j)$ for all $j$ (trivially for $j = i$), so $i$ is an argmin. For
uniqueness, suppose $k$ is also an argmin, i.e. $w(k) \le w(j)$ for all $j$. If
$k \neq i$, then the strict-minimum property gives $w(i) < w(k)$, contradicting
$w(k) \le w(i)$. Hence $k = i$. $\blacksquare$

Because of Proposition 3.2 we work exclusively with the strict-minimum
formulation, which is combinatorially convenient. We define the counting objects:

- $\mathrm{Iso}(n,d) = \{\, w : [n] \to [d] \mid w \text{ has a strict minimum}\,\}$;
- for a fixed vertex $i \in [n]$,
  $\mathrm{SM}_i(n,d) = \{\, w : [n] \to [d] \mid w(i) < w(j)\ \forall j \neq i \,\}$,
  the assignments for which $i$ is the strict minimum.

---

## 4. Main results

**Theorem 4.1 (Exact count).** For all natural numbers $n, d$,
$$|\mathrm{Iso}(n,d)| \;=\; n \cdot \sum_{j=0}^{d-1} j^{\,n-1},$$
where the exponent $n-1$ is the truncated natural-number subtraction (so
$0^{n-1} = 1$ when $n = 0$, but the leading factor $n$ then nullifies the sum).

**Corollary 4.2 (Global tightness of the Faber–Harris bound).** The universal
lower bound $|\{\text{isolating assignments}\}| \ge n \cdot \sum_{j=0}^{d-1} j^{n-1}$,
valid for every inclusion-free hypergraph on $n$ vertices under every offset, is
attained with equality by the singleton hypergraph $H_n^{\mathrm{sing}}$ under
the zero offset. In particular the bound cannot be improved.

*Proof of Corollary 4.2.* The singleton hypergraph is inclusion-free: distinct
singletons are incomparable, and $\{v\} \subseteq \{w\}$ forces $v = w$. By the
reduction of Section 2, its isolating assignments under zero offset are exactly
$\mathrm{Iso}(n,d)$, whose cardinality is the bound value by Theorem 4.1. $\square$

The remainder of this section proves Theorem 4.1 in three lemmas.

### 4.1 Counting values above a threshold

**Lemma 4.3 (Tail count).** For a fixed value $m \in [d]$, the number of values in
$[d]$ strictly greater than $m$ is $d - 1 - m$.

*Proof.* The values strictly greater than $m$ are $m+1, m+2, \dots, d-1$, of which
there are $(d-1) - (m+1) + 1 = d - 1 - m$. $\blacksquare$

### 4.2 The fiber over a fixed minimum value

**Lemma 4.4 (Fiber count).** Fix a vertex $i \in [n]$ and a value $m \in [d]$.
The number of assignments $w$ with $w(i) = m$ and $w(j) > m$ for all $j \neq i$
equals
$$(d - 1 - m)^{\,n-1}.$$

*Proof.* Such an assignment is specified by independent choices coordinatewise.
The value at $i$ is forced to be $m$ (one choice). Each of the remaining $n-1$
coordinates $j \neq i$ must be chosen from the set of values strictly greater than
$m$, which by Lemma 4.3 has $d - 1 - m$ elements, and these choices are
independent. Hence the total is $(d-1-m)^{n-1}$. Formally, the set of such
assignments is the product set $\prod_{j} T_j$ where $T_i = \{m\}$ and
$T_j = \{v \in [d] : v > m\}$ for $j \neq i$; the cardinality of a product of
finite sets is the product of the cardinalities. $\blacksquare$

### 4.3 Counting strict minima at a fixed vertex

**Lemma 4.5 (Per-vertex count).** For every vertex $i \in [n]$,
$$|\mathrm{SM}_i(n,d)| \;=\; \sum_{j=0}^{d-1} j^{\,n-1},$$
independent of $i$.

*Proof.* Partition $\mathrm{SM}_i(n,d)$ according to the value $m = w(i)$ taken by
the (strict) minimum vertex. Each part is exactly the fiber of Lemma 4.4, so
$$|\mathrm{SM}_i(n,d)| = \sum_{m=0}^{d-1} (d-1-m)^{\,n-1}.$$
Re-index by $k = d - 1 - m$: as $m$ ranges over $\{0, \dots, d-1\}$, so does $k$,
and therefore
$$\sum_{m=0}^{d-1} (d-1-m)^{\,n-1} = \sum_{k=0}^{d-1} k^{\,n-1}. \qquad\blacksquare$$

### 4.4 Assembling the total

**Lemma 4.6 (Disjoint decomposition).** The isolating set is the disjoint union
of the per-vertex strict-minimum sets:
$$\mathrm{Iso}(n,d) = \bigsqcup_{i \in [n]} \mathrm{SM}_i(n,d),$$
and hence $|\mathrm{Iso}(n,d)| = \sum_{i \in [n]} |\mathrm{SM}_i(n,d)|$.

*Proof.* An assignment lies in $\mathrm{Iso}(n,d)$ iff it has a strict minimum at
*some* vertex $i$, i.e. iff it lies in $\mathrm{SM}_i(n,d)$ for some $i$; this
gives the union. The union is disjoint: if $w \in \mathrm{SM}_i \cap
\mathrm{SM}_{i'}$ with $i \neq i'$, then $w(i) < w(i')$ (as $i$ is the strict min)
and $w(i') < w(i)$ (as $i'$ is the strict min), a contradiction. $\blacksquare$

*Proof of Theorem 4.1.* Combining Lemma 4.6 and Lemma 4.5,
$$|\mathrm{Iso}(n,d)| = \sum_{i \in [n]} |\mathrm{SM}_i(n,d)| = \sum_{i \in [n]} \sum_{j=0}^{d-1} j^{\,n-1} = n \cdot \sum_{j=0}^{d-1} j^{\,n-1}. \qquad\blacksquare$$

---

## 5. Algorithms

We describe two algorithms: a direct enumerator (ground truth) and the
closed-form evaluator (the theorem in action).

**Algorithm A — Direct enumeration.** Iterate over all $d^n$ assignments; for each,
compute the minimum value and test whether it is attained by exactly one vertex.
Time complexity $\Theta(n \cdot d^n)$; exponential, used for verification on small
parameters.

**Algorithm B — Closed-form evaluation.** Return $n \cdot \sum_{j=0}^{d-1}
j^{\,n-1}$ directly. Using fast exponentiation, this runs in $O(d \log n)$
arithmetic operations (or $O(d)$ multiplications with naive powering) —
exponentially faster than enumeration and independent of the astronomically large
sample space.

The agreement of Algorithms A and B on a grid of parameters is the empirical
signature of Theorem 4.1.

---

## 6. Numerical verification and boundary analysis

Direct enumeration matches the closed form for all $(n, d)$ with
$0 \le n \le 4$ and $1 \le d \le 5$. Some representative values with $n = 3$:

| $d$ | $\sum_{j<d} j^2$ | $|\mathrm{Iso}(3,d)| = 3\sum_{j<d} j^2$ | total $d^3$ |
|----:|------------------:|---------------------------------------:|-----------:|
| 1   | 0                | 0                                      | 1          |
| 2   | 1                | 3                                      | 8          |
| 3   | 5                | 15                                     | 27         |
| 4   | 14               | 42                                     | 64         |
| 5   | 30               | 90                                     | 125        |

**Boundary cases.**

- **$n = 0$ (no vertices).** There is no vertex to attain a minimum, so
  $|\mathrm{Iso}(0,d)| = 0$; the leading factor $n = 0$ makes the closed form
  vanish, in agreement.
- **$n = 1$ (single vertex).** The lone vertex is vacuously a strict minimum
  (there is no $j \neq i$ to violate the inequality), so every one of the $d$
  assignments is isolating. The closed form gives
  $1 \cdot \sum_{j<d} j^0 = d$, matching.
- **$d = 1$, $n \ge 2$.** All vertices are forced to the single value $0$, so no
  strict minimum exists and the count is $0$. The closed form gives
  $n \cdot 0^{\,n-1} = 0$. This certifies that the count is genuine and never
  vacuously inflated.

---

## 7. Discussion and future directions

The exact count of Theorem 4.1 shows that the Faber–Harris lower bound
$n \cdot \sum_{j<d} j^{n-1}$ is attained on the nose by a concrete inclusion-free
hypergraph. This pins down the extremal value and its combinatorial meaning: the
factor $n$ enumerates the unique argmin vertex, the summand $j^{\,n-1}$ is the
fiber size over a fixed argmin (the $n-1$ losers each choosing a strictly larger
value), and the sum ranges over the minimum value. Several bold, testable
conjectures follow.

**Conjecture 1 (Per-hypergraph tightness under offsets).** For every
inclusion-free hypergraph $H$ on $n$ vertices there is an edge offset function
$f$ so that the number of isolating assignments in $[d]^n$ equals exactly
$n \cdot \sum_{j=0}^{d-1} j^{\,n-1}$. The guiding intuition is that a generic
offset flattens the hypergraph's internal comparisons so that isolation is
governed solely by a single controlling vertex per assignment, reproducing the
singleton-hypergraph count. The exact singleton identity supplies both the precise
target value and the vertex-argmin decomposition needed to transport the count to
arbitrary Sperner families.

**Conjecture 2 (Rigidity of the extremizers).** The offsets $f$ achieving the
exact minimum count form a positive-measure, polyhedrally described region of
offset space, and every extremizer induces the same argmin-partition statistics as
the singleton hypergraph. Attaining the bound should force a unique-minimum
structure almost everywhere, which is a closed linear condition on the offsets,
turning "is the bound tight?" into a concrete polytope-nonemptiness question.

**Conjecture 3 (A strict gap away from Sperner families).** If $H$ fails to be
inclusion-free, then for every offset $f$ the number of isolating assignments is
strictly less than $n \cdot \sum_{j=0}^{d-1} j^{n-1}$ for all sufficiently large
$d$. A containment $S \subsetneq T$ permanently couples two edges' weights,
destroying the independence the extremal count relies on; the proved identity
isolates incomparability as exactly the structural feature the extremal count
uses.

**Conjecture 4 (Refined power-sum decomposition).** For every $n$, the extremal
count $n \cdot \sum_{j<d} j^{n-1}$, viewed as a polynomial in $d$, has its
nonnegative-integer roots at $d = 0, 1$, and its leading behavior reflects a clean
bijective decomposition of isolating assignments by (argmin vertex, minimum
value). The term $\sum_{j<d} j^{n-1}$ being the exact fiber size over a fixed
argmin makes this polynomial identity a direct corollary of the fiberwise count
rather than a numerical coincidence.

---

## 8. Conclusion

We have established the exact number of isolating weight assignments for the
singleton hypergraph under zero offset,
$n \cdot \sum_{j=0}^{d-1} j^{\,n-1}$, thereby proving that the sharp Faber–Harris
lower bound on isolating assignments for inclusion-free hypergraphs is globally
tight and exhibiting an explicit extremal witness. The proof is a transparent
fiberwise decomposition over the argmin vertex and the minimum value, and it
explains each factor in the extremal formula combinatorially. The result converts
the qualitative "the bound is sharp" into the quantitative "the bound is attained
term for term," and it lays out a concrete program — Conjectures 1–4 — for
understanding tightness across all inclusion-free hypergraphs under arbitrary edge
offsets.

## References

- K. Mulmuley, U. V. Vazirani, and V. V. Vazirani. *Matching is as easy as matrix
  inversion.* Combinatorica, 7(1):105–113, 1987.
- V. Faber and D. G. Harris. *Isolation of the minimum weight assignment and
  counting isolating weightings* (2018).
- L. G. Valiant and V. V. Vazirani. *NP is as easy as detecting unique solutions.*
  Theoretical Computer Science, 47:85–93, 1986.
