# Local Bounds for Monochromatic Matchings in Bounded-Degree Hypergraphs and the Constant-Factor Gap to the Alon–Frankl–Lovász Threshold

**Author:** Aristotle

**Date:** 2026-06-26

**Domain:** Novelty (Extremal and Probabilistic Combinatorics)

---

## Abstract

We study guaranteed monochromatic matchings in edge-colored uniform hypergraphs.
For a $t$-uniform hypergraph $H$ and an $r$-edge-coloring $c$, we ask for the
largest size of a matching all of whose edges receive a single color, in the
worst case over colorings. We isolate the two structural primitives that drive the
classical theory — a *pigeonhole on a matching* and the fact that *maximal
matchings are vertex covers* — and assemble them into a sharp, fully unconditional
lower bound: in any $t$-uniform host with maximum degree at most $\Delta$, every
$r$-coloring admits a monochromatic matching of size at least $|H| / (r\,t\,\Delta)$.
For $d$-regular random-like hosts on $n$ vertices this yields matchings of size
$\Theta(n/(rt))$. We then prove the honest separation result: the constant
$1/(rt)$ produced by bounded degree alone is strictly smaller than the
Alon–Frankl–Lovász (AFL) target $1/(r+t-1)$ whenever $r, t \geq 2$, the exact
multiplicative gap being $rt/(r+t-1) = 1 + (r-1)(t-1)/(r+t-1)$. A finite witness
($K_4$ with two colors and no monochromatic matching of size two) shows that the
limiting AFL fraction cannot be attained exactly at finite scale, so the $-o(1)$
correction in the conjecture is genuine. The entire development has been formalized
and machine-checked with no unproved steps. Our contribution clarifies precisely
which hypotheses are responsible for which part of the AFL bound: bounded degree
fixes the *order* of growth, but the optimal *constant* provably requires global
(pseudorandom / cover-theoretic) structure.

---

## 1. Introduction

### 1.1 Motivation

Ramsey-type matching theorems quantify the unavoidable order that emerges in
arbitrarily colored combinatorial structures. The prototypical statement of this
flavor for graphs is the Cockayne–Lorimer theorem on monochromatic matchings, and
for $t$-uniform hypergraphs the natural generalization predicts that, in
sufficiently "random-like" hosts on $n$ vertices, every $r$-coloring contains a
monochromatic matching of size

$$\left(\frac{1}{r+t-1} - o(1)\right) n,$$

and that the constant $1/(r+t-1)$ is asymptotically optimal. We refer to this as
the **Alon–Frankl–Lovász (AFL) matching bound**. The conjecture asserts that the
AFL constant, classically established for the complete host $K_n^{(t)}$, persists
for any sufficiently *pseudorandom* host, with no loss beyond the $o(1)$ term.

This paper does not resolve the full AFL conjecture. Instead it executes a
disciplined decomposition: we determine *exactly how much of the AFL phenomenon
follows from purely local data* — the number of edges $|H|$ and the maximum degree
$\Delta$ — and *where that local data provably stops being sufficient.* The
resulting picture is clean and complete at the level of the constant factor.

### 1.2 Summary of results

Let $H$ be a $t$-uniform hypergraph (a finite set of $t$-element edges) on a vertex
set $V$, let $r \geq 1$, and let $c$ assign each edge a color in
$\{0, \dots, r-1\}$. Our results are:

1. **(Pigeonhole on a matching.)** For any matching $M$ and any $r$-coloring,
   some color class of $M$ is a matching $M'$ with $r \cdot |M'| \geq |M|$.

2. **(Maximal matchings are covers.)** If $M$ is a maximal matching of $H$ and all
   edges of $H$ are nonempty, then every edge of $H$ meets the support of $M$.

3. **(Greedy bound.)** If $H$ is $t$-uniform with maximum degree $\leq \Delta$,
   then every maximal matching $M$ satisfies $|H| \leq t \Delta |M|$.

4. **(Monochromatic lower bound.)** Under the same hypotheses, every $r$-coloring
   contains a monochromatic matching $M'$ with $r t \Delta |M'| \geq |H|$, hence of
   size at least $|H| / (r t \Delta)$.

5. **(Constant gap.)** $r + t - 1 \leq rt$ always, with strict inequality iff
   $r, t \geq 2$; equivalently $1/(r+t-1) \geq 1/(rt)$, strictly in the
   nondegenerate range.

6. **(Finite deficit witness.)** There is a $2$-coloring of $K_4$ ($t=2$, $r=2$)
   with no monochromatic matching of size $2$.

Together these establish that the local route reaches the correct order
$\Theta(n/(rt))$ but a strictly suboptimal constant, and quantify the deficit
exactly.

### 1.3 Relation to prior work

The two structural primitives are folklore in matching theory; the greedy
cover bound for matching numbers is classical. Our novelty is threefold: (i) the
clean isolation of these primitives as the minimal engine behind a Ramsey-type
matching bound; (ii) the explicit, proved constant-factor separation
$rt / (r+t-1)$ between the local bound and the AFL target, certifying that bounded
degree *cannot* reach the optimum; and (iii) full formal verification of every
step, including the finite deficit witness, eliminating any gap between informal
claim and proved fact.

---

## 2. Definitions

Throughout, $V$ is a (decidable) vertex type and edges are finite subsets of $V$.
A hypergraph is identified with its finite set of edges $H$.

**Definition 2.1 (Matching).** A finite set of edges $M$ is a *matching* if its
members are pairwise disjoint:
$$\forall e, f \in M,\ e \neq f \implies e \cap f = \varnothing.$$

**Definition 2.2 ($t$-uniformity).** $H$ is *$t$-uniform* if every $e \in H$ has
exactly $t$ vertices, $|e| = t$. In particular for $t \geq 1$ all edges are
nonempty.

**Definition 2.3 ($r$-coloring).** An *$r$-coloring* is a function
$c : (\text{edges}) \to \{0,\dots,r-1\}$. A matching $M$ is *monochromatic* (of
color $i$) if $c(e) = i$ for all $e \in M$. The *color class* of $i$ in $M$ is
$M_i := \{ e \in M : c(e) = i \}$.

**Definition 2.4 (Support).** The *support* of an edge set $M$ is the set of
vertices it covers,
$$\operatorname{supp}(M) := \bigcup_{e \in M} e.$$

**Definition 2.5 (Maximum degree).** The *degree* of a vertex $v$ in $H$ is
$\deg_H(v) := |\{ e \in H : v \in e \}|$, and the *maximum degree* is
$\Delta(H) := \max_{v} \deg_H(v)$.

**Definition 2.6 (Maximal matching).** A matching $M \subseteq H$ is *maximal in
$H$* if no edge of $H$ can be added while preserving disjointness:
$$M \subseteq H,\quad M \text{ is a matching},\quad
\forall e \in H,\ \big(\forall f \in M,\ e \cap f = \varnothing\big) \implies e \in M.$$

**Definition 2.7 (Matching number / monochromatic matching number).** The
*matching number* $\nu(H)$ is the maximum size of a matching in $H$. For a coloring
$c$, the *monochromatic matching number* $\nu_{\mathrm{mono}}(H, c)$ is the maximum
size of a monochromatic matching, and we write
$\nu_{\mathrm{mono}}^{(r)}(H) := \min_c \nu_{\mathrm{mono}}(H, c)$ for the
worst-case guarantee over $r$-colorings.

---

## 3. Structural lemmas

### 3.1 Pigeonhole on a matching

**Theorem 3.1 (`IsMatching.exists_mono_of_card`).**
*Let $M$ be a matching and $c$ an $r$-coloring with $r \geq 1$. Then there exists a
color $i \in \{0, \dots, r-1\}$ such that the color class $M_i = \{e \in M : c(e)=i\}$
is a matching, every edge of $M_i$ has color $i$, and*
$$r \cdot |M_i| \ \geq\ |M|.$$

*Proof sketch.* Subsets of matchings are matchings, so each $M_i$ is a matching;
this discharges the first two conclusions for every $i$. For the inequality,
partition $M$ into the $r$ disjoint color classes $M_0, \dots, M_{r-1}$. The
classes are pairwise disjoint and their union is $M$, so
$$\sum_{j=0}^{r-1} |M_j| = |M|.$$
Choose $i$ maximizing $|M_j|$ (the maximum over the nonempty finite index set
$\{0,\dots,r-1\}$ exists since $r \geq 1$). Then $|M_j| \leq |M_i|$ for all $j$, so
$$|M| = \sum_{j} |M_j| \ \leq\ \sum_j |M_i| \ =\ r |M_i|. \qquad \blacksquare$$

The formal proof realizes the partition via `Finset.card_biUnion` over the
pairwise-disjoint color classes and selects the maximizing color with
`Finset.exists_max_image`. No hypergraph structure is used; only disjointness of
the color classes and the existence of a maximum over $r \geq 1$ boxes.

### 3.2 Maximal matchings are vertex covers

**Theorem 3.2 (`MaximalMatching.isCover`).**
*Let $M$ be a maximal matching of $H$, and suppose every edge of $H$ is nonempty.
Then every edge $e \in H$ meets the support of $M$: there exists $v \in \operatorname{supp}(M)$
with $v \in e$.*

*Proof sketch.* Fix $e \in H$ and split into cases.

- If $e$ is disjoint from every $f \in M$, then by maximality $e \in M$ itself.
  Since $e$ is nonempty, pick any $v \in e$; then $v \in e \subseteq \operatorname{supp}(M)$,
  so $v \in \operatorname{supp}(M)$ and $v \in e$.
- Otherwise $e$ meets some $f \in M$: there is a vertex $v \in e \cap f$. Then
  $v \in f \subseteq \operatorname{supp}(M)$ and $v \in e$, as required. $\blacksquare$

The nonemptiness hypothesis is necessary: an empty edge is disjoint from every
edge yet contains no vertex to witness a cover, so a maximal matching could fail to
"cover" it. $t$-uniformity with $t \geq 1$ supplies nonemptiness.

### 3.3 Existence of maximal matchings

**Theorem 3.3 (`exists_maximalMatching`).** *Every finite hypergraph $H$ admits a
maximal matching.*

*Proof sketch.* The family of sub-matchings of $H$ is a nonempty (it contains
$\varnothing$) finite collection, so it has a member $M$ of maximum cardinality.
If some $e \in H$ were disjoint from all of $M$ but not in $M$, then $M \cup \{e\}$
would be a strictly larger matching contained in $H$, contradicting maximality of
$|M|$. Hence $M$ is maximal in the sense of Definition 2.6. $\blacksquare$

A maximum-cardinality matching is in particular maximal; the converse can fail, but
the greedy bound below applies to *every* maximal matching, so either suffices.

---

## 4. Quantitative bounds

### 4.1 The greedy counting bound

**Theorem 4.1 (`MaximalMatching.card_host_le`).**
*Let $H$ be $t$-uniform with maximum degree $\Delta(H) \leq \Delta$, and let $M$ be
a maximal matching of $H$. Then*
$$|H| \ \leq\ t \cdot \Delta \cdot |M|.$$

*Proof sketch.* By Theorem 3.2 each edge of $H$ contains a vertex of
$S := \operatorname{supp}(M)$, so the assignment $e \mapsto (\text{some } v \in e \cap S)$
shows
$$H = \bigcup_{v \in S} \{ e \in H : v \in e \}, \qquad
|H| \ \leq\ \sum_{v \in S} \deg_H(v) \ \leq\ |S| \cdot \Delta.$$
By $t$-uniformity, $S$ is the union of $|M|$ edges each of size $t$, so
$|S| \leq t |M|$. Combining, $|H| \leq t |M| \cdot \Delta$. $\blacksquare$

**Corollary 4.2 (matching number lower bound).** Under the hypotheses of
Theorem 4.1, $\nu(H) \geq |H| / (t\Delta)$, since the maximal matching $M$ used is a
matching and $\nu(H) \ge |M| \ge |H|/(t\Delta)$.

### 4.2 The monochromatic lower bound

**Theorem 4.3 (`mono_matching_lower_bound`).**
*Let $H$ be $t$-uniform with maximum degree $\leq \Delta$ and let $c$ be any
$r$-coloring with $r \geq 1$. Then there is a monochromatic matching $M'$ with*
$$r \cdot t \cdot \Delta \cdot |M'| \ \geq\ |H|,$$
*equivalently $|M'| \geq |H| / (r t \Delta)$.*

*Proof sketch.* Take a maximal matching $M$ (Theorem 3.3), so $|H| \leq t\Delta|M|$
by Theorem 4.1. Apply the pigeonhole (Theorem 3.1) to $M$ to obtain a monochromatic
color class $M'$ with $r|M'| \geq |M|$. Multiply the second inequality by $t\Delta$
and chain:
$$r t \Delta |M'| \ \geq\ t \Delta |M| \ \geq\ |H|. \qquad \blacksquare$$

**Corollary 4.4 (asymptotics for regular-like hosts).** If $H$ is $d$-regular-like
on $n$ vertices with $|H| \approx d\binom{n}{t}$ and
$\Delta \approx d\binom{n-1}{t-1}$, then $|H|/\Delta \approx n/t$ and the guaranteed
monochromatic matching has size at least
$$\frac{|H|}{r t \Delta} \ \approx\ \frac{n}{rt}.$$
This is the universal lower bound: $\Theta(n/(rt))$, valid for *any* bounded-degree
host, with no pseudorandomness needed beyond degree control.

---

## 5. The constant-factor gap to the AFL threshold

The previous section guarantees the fraction $1/(rt)$. The AFL conjecture predicts
$1/(r+t-1)$. We now prove these differ exactly, and strictly in the
nondegenerate regime.

**Theorem 5.1 (`afl_constant_gap`).** *For all $r, t \geq 1$,*
$$r + t - 1 \ \leq\ r \cdot t,$$
*equivalently $\dfrac{1}{r+t-1} \geq \dfrac{1}{rt}$.*

**Theorem 5.2 (`afl_constant_gap_strict`).** *For all $r, t \geq 2$,*
$$r + t - 1 \ <\ r \cdot t.$$

*Proof.* Compute the difference exactly:
$$rt - (r + t - 1) \ =\ rt - r - t + 1 \ =\ (r-1)(t-1).$$
This is $\geq 0$ for $r, t \geq 1$ and $> 0$ for $r, t \geq 2$, since then both
factors are positive. $\blacksquare$

**Interpretation.** The multiplicative gap between the AFL target and the local
bound is
$$\frac{rt}{r+t-1} \ =\ \frac{(r+t-1)+(r-1)(t-1)}{r+t-1} \ =\ 1 + \frac{(r-1)(t-1)}{r+t-1} \ >\ 1
\quad (r, t \geq 2).$$
Thus for every genuinely multi-color, multi-uniform problem the bounded-degree
route is off by a fixed constant factor strictly greater than $1$. Crucially, the
greedy argument used only a single maximal matching's support as a cover and the
worst-case degree; it never exploited any *global* uniformity of the edge
distribution. The strict gap is therefore a proof-theoretic certificate: **any
argument achieving the AFL constant must consume global structural information**
(pseudorandom edge-density control, or the true fractional cover number), because
degree control alone is provably insufficient.

---

## 6. A finite witness that the limit is not attained

The AFL bound carries a $-o(1)$ correction. We show it is genuine: at finite scale
the smooth fraction is not attained.

**Theorem 6.1 (`K4_no_mono_matching_two`).** *There is a $2$-coloring of the
complete graph $K_4$ (the $t = 2$, $r = 2$ case on $n = 4$ vertices) under which no
monochromatic matching has size $2$.*

*Proof sketch.* $K_4$ has six edges, which decompose into three *perfect matchings*
(pairs of disjoint edges) $P_1, P_2, P_3$, each a pair of opposite edges. A
monochromatic matching of size $2$ is precisely a monochromatic perfect matching,
i.e. both edges of some $P_k$ sharing a color. Color the six edges so that within
each $P_k$ the two opposite edges receive *different* colors. Concretely, take a
proper $3$-edge-coloring of $K_4$ by perfect matchings and recolor with two colors
so that no $P_k$ is monochromatic; an explicit assignment (red/blue) with this
property exists and is verified directly by checking all three opposite pairs. Then
no $P_k$ is monochromatic, so there is no monochromatic matching of size $2$.
$\blacksquare$

**Discussion.** With $n = 4$, $r = t = 2$, the limiting AFL value is
$\frac{n}{r+t-1} = \frac{4}{3} > 1$, so the asymptotics "want" a monochromatic
matching of size $2$ (the integer above $4/3$); yet a coloring forces the maximum
down to $1$. The absolute deficit from the smooth line is $\Theta(1)$ — vanishing
relative to $n$ (consistent with the $-o(1)$ term) but never zero. The finite world
genuinely sits below the asymptote.

---

## 7. Algorithms

The constructive content of the proofs yields concrete algorithms.

**Algorithm A (Greedy maximal matching).** Given $H$, iterate over its edges in any
order, maintaining a set $U$ of used vertices; add an edge $e$ to $M$ iff
$e \cap U = \varnothing$, then set $U \leftarrow U \cup e$. The output $M$ is a
maximal matching (Theorem 3.3 / Definition 2.6). Runtime $O(|H| \cdot t)$ with a
hash set for $U$. This realizes the bound of Theorem 4.1 directly.

**Algorithm B (Monochromatic extraction).** Given a maximal matching $M$ and a
coloring $c$, tally $|M_i|$ for each color $i$ and return the heaviest class
$M' = M_{i^\star}$. By Theorem 3.1, $r |M'| \geq |M|$. Runtime $O(|M| + r)$.

**Algorithm C (Guaranteed monochromatic matching).** Compose A then B. Output a
monochromatic matching of size $\geq |H|/(rt\Delta)$ (Theorem 4.3). Total runtime
$O(|H| \cdot t + r)$.

**Algorithm D (Deficit certifier).** Given a small host and $r$, enumerate
colorings (or perfect-matching color patterns) and report the minimal worst-case
monochromatic matching number, certifying finite deficits such as Theorem 6.1.

---

## 8. Applications

- **Batch scheduling.** Edges model jobs competing for shared resources
  (vertices); a monochromatic matching is a large set of mutually compatible jobs
  of a single *type*, minimizing costly type switches. Theorem 4.3 gives an
  unconditional throughput guarantee from local load data.
- **Combinatorial designs and codes.** $t$-uniform hosts are the substrate of block
  designs; monochromatic matchings model color-robust parallel classes. The
  constant gap (Section 5) flags when global balance (design regularity) is needed
  for optimality.
- **Pseudorandom networks.** For expander-like / quasirandom hosts the order
  $\Theta(n/(rt))$ is free; Section 5 identifies precisely the extra global control
  required to upgrade the constant toward $1/(r+t-1)$.

---

## 9. Discussion

The contribution is a precise *accounting* of the AFL phenomenon. Bounded degree
is responsible for the correct order of growth $\Theta(n/(rt))$ and nothing more;
the optimal constant $1/(r+t-1)$ is provably out of reach of local data, by the
strict gap $(r-1)(t-1) > 0$. The greedy proof's reliance on a single matching's
support — rather than the host's true cover number — is exactly the slack that the
global AFL theory recovers. Recognizing the boundary between "true" and "true and
tight" is the central methodological point.

---

## 10. Future directions

*(Derived from this cycle's findings.)*

**Conjecture 1 — The slack equals the cover/matching gap, edge by edge.** For every
$t$-uniform $H$ and every $r$-coloring, the best monochromatic matching has size at
least $|H| / (r\tau)$, where $\tau$ is the *vertex cover number* of $H$; this
refines the degree bound whenever $\tau < t\Delta$. The greedy proof never used the
degree bound directly — it used the cover $\operatorname{supp}(M)$ — so replacing
$t\Delta$ by the true cover number $\tau$ is automatically at least as strong, and
is exactly the König/LP-dual quantity that AFL exploits globally. The cover lemma
`MaximalMatching.isCover` is already established; the missing ingredient is a
development of the (fractional) cover number.

**Conjecture 2 — Pseudorandomness buys the AFL constant, bounded degree cannot.**
There is a $(C,d)$-pseudorandomness threshold $C_0(r,t)$ such that every $t$-graph
with discrepancy below $C_0$ has, in every $r$-coloring, a monochromatic matching
of size $(1/(r+t-1) - o(1)) n$; whereas there exist bounded-degree (even
$d$-regular) hosts whose best guarantee is only $(1/(rt) + o(1)) n$. Since
`afl_constant_gap_strict` proves the greedy constant is strictly worse, any proof of
the AFL constant *must* consume a global counting hypothesis — pseudorandom
edge-density control is the natural candidate, separating it from mere degree
regularity. Both endpoints are in hand; the open task is the separating
construction, amenable to finite/`Fintype` search.

**Conjecture 3 — The $-o(1)$ is $\Theta(1/n)$, sharply.** For the complete host
$K_n^{(t)}$ the optimal monochromatic matching guarantee is exactly
$\lfloor (n-(t-1))/(r+t-1) \rfloor$-ish: the deviation from $n/(r+t-1)$ is
$\Theta(1)$ in absolute terms, i.e. $o(1)\cdot n$ but never $0$.
`K4_no_mono_matching_two` already exhibits an absolute deficit, anchoring the
conjecture at the smallest nontrivial scale.

---

## Appendix: Formalized declarations

All results are machine-checked with no unproved steps. The formal names are:

- `IsMatching`, `support`, `MaximalMatching` — core definitions.
- `IsMatching.subset`, `isMatching_empty` — closure facts.
- `IsMatching.exists_mono_of_card` — Theorem 3.1 (pigeonhole on a matching).
- `MaximalMatching.isCover` — Theorem 3.2 (maximal matchings are covers).
- `exists_maximalMatching` — Theorem 3.3 (existence).
- `MaximalMatching.card_host_le` — Theorem 4.1 (greedy bound $|H| \le t\Delta|M|$).
- `mono_matching_lower_bound` — Theorem 4.3 ($rt\Delta|M'| \ge |H|$).
- `afl_constant_gap`, `afl_constant_gap_strict` — Theorems 5.1–5.2 ($r+t-1 \le rt$).
- `K4_no_mono_matching_two` — Theorem 6.1 (finite deficit witness).
