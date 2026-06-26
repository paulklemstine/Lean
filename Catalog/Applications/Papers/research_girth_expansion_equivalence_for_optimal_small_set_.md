# The Girth–Expansion Bridge for Optimal Small-Set Expanders: A One-Directional Equivalence and Its Correct Replacements

**Author:** Aristotle

**Domain:** Bridges (combinatorics ↔ expansion / coding theory)

**Date:** 2026-06-26

---

## Abstract

Expander graphs and high-girth graphs are two of the most fertile structural
ideas in combinatorics and coding theory, and folklore has long linked them:
graphs that "look locally like trees" (high girth) tend to spread small sets
well (good expansion). We make this link mathematically precise for the
extremal regime, modeling a left-$d$-regular bipartite graph by a neighbor
function $N : L \to \mathrm{Finset}\,R$ with $|N(u)| = d$ for all $u$. We
study the conjectured equivalence

$$\text{$N$ is an $s$-optimal small-set expander} \iff \operatorname{girth}(N) \ge 2s+2,$$

where *$s$-optimal small-set expander* means $|N(X)| = d\,|X|$ for every left
set $X$ with $|X| \le s$ (maximal possible neighborhood size), and girth is
measured combinatorially through the absence of $2k$-cycles for $2 \le k \le s$.

Our main findings are: **(1)** the forward implication is true in full
generality — optimal expansion implies high girth (`optimal_imp_girth`); **(2)**
the converse is false for every $s \ge 2$, witnessed by an explicit
$3$-vertex counterexample (`converse_false`); and **(3)** the failed converse
is replaced by two exact structural characterizations: optimal expansion is
equivalent to pairwise-disjoint neighborhoods for all $s \ge 2$
(`optimal_iff_disjoint`), and girth $\ge 6$ is equivalent to every two left
vertices sharing at most one neighbor (`no_four_cycle_iff`). The diagnostic
heart is a cycle-extraction lemma (`cycle_shared_neighbor`) showing that any
cycle of length $\ge 4$ yields two adjacent left vertices with a common
neighbor, reducing every "no short cycle" statement to a local disjointness
statement. The corrected picture exposes a precise "exchange rate": high girth
controls overlap *multiplicity* (share at most one), while optimal expansion
controls overlap *existence* (share none), the latter being strictly stronger
and equivalent to a vertex-disjoint union of stars.

**Keywords:** small-set expander, girth, bipartite graph, left-regular, neighborhood, disjoint neighborhoods, unique-neighbor expander, expander codes.

---

## 1. Introduction

### 1.1 Motivation

A bipartite graph between a left vertex set $L$ and a right vertex set $R$ is
the natural model for many objects in theoretical computer science: the
Tanner graph of a linear code, the bipartite double cover of a graph, a
hypergraph incidence structure, or a sampler/disperser. When the graph is
*left-regular* of degree $d$ — every left vertex has exactly $d$ right
neighbors — the central quality measure is **expansion**: the rate at which
the neighborhood $N(X) = \bigcup_{u\in X} N(u)$ of a left set $X$ grows with
$|X|$. The strongest conceivable form is *optimal small-set expansion*, where
$|N(X)|$ attains its information-theoretic maximum $d\,|X|$ for all small $X$.

A second, ostensibly unrelated measure is **girth**, the length of the
shortest cycle. High girth means no short closed walks; locally the graph is
tree-like. Both high expansion and high girth are "tree-like" virtues, and a
substantial body of folklore treats them as nearly interchangeable. Low-density
parity-check (LDPC) and expander codes are routinely designed for high girth
precisely *because* it is believed to promote good expansion and good
unique-neighbor behavior.

This paper asks whether the two notions are *literally equivalent* in the
extremal regime, and answers with a precise dichotomy.

### 1.2 The proposed bridge

> **Conjecture (naive bridge).** A left-$d$-regular bipartite graph $N$ is an
> $s$-optimal small-set expander if and only if its girth is at least $2s+2$.

We confirm one direction, refute the other with an explicit construction, and
replace the broken equivalence with two provable characterizations that
together delineate exactly how girth and optimal expansion relate.

### 1.3 Contributions

1. **Forward bridge (true).** `optimal_imp_girth`: optimal expansion $\Rightarrow$ girth $\ge 2s+2$, for general $s$.
2. **Counterexample (converse false).** `converse_false`: an explicit left-$2$-regular graph with girth $\ge 6$ that is not $2$-optimal.
3. **Disjointness characterization.** `optimal_iff_disjoint`: for $s \ge 2$, optimal expansion $\iff$ pairwise-disjoint neighborhoods; hence the parameter $s$ collapses to $s=2$.
4. **Girth-$6$ characterization.** `no_four_cycle_iff`: no $4$-cycle $\iff$ every two left vertices share at most one neighbor.
5. **Structural pivot.** `cycle_shared_neighbor` and `disjoint_imp_no_cycle`: cycles localize to shared neighbors; disjointness yields infinite girth.

All results are stated and proved over a self-contained combinatorial model;
no external graph library or renamed gadget is used to encode girth.

---

## 2. The model and definitions

Throughout, $L$ and $R$ are types with decidable equality (the left and right
vertex sets), and $N : L \to \mathrm{Finset}\,R$ is a **neighbor function**:
$N(u)$ is the finite set of right neighbors of the left vertex $u$.

**Definition 2.1 (Neighborhood).** For a finite set $X \subseteq L$,
$$N(X) \;:=\; \bigcup_{u \in X} N(u) \qquad (\texttt{nbhd}).$$

**Definition 2.2 (Left-regularity).** $N$ is *left-$d$-regular* if
$$|N(u)| = d \quad \text{for all } u \in L \qquad (\texttt{LeftRegular}).$$

**Definition 2.3 ($s$-optimal small-set expander).** $N$ is an *$s$-optimal
small-set expander* if every left set of size at most $s$ has the maximal
possible neighborhood,
$$|N(X)| = d\,|X| \quad \text{for all } X \text{ with } |X| \le s
\qquad (\texttt{OptimalExpander}).$$
The bound $|N(X)| \le d\,|X|$ always holds (a union of $|X|$ sets of size
$d$); optimality is its saturation.

**Definition 2.4 (Combinatorial $2k$-cycle).** $N$ *has a $2k$-cycle*
(`HasCycle N k`) if there exist injections $u : \mathbb{Z}/k \to L$ and
$w : \mathbb{Z}/k \to R$ such that for every $i$,
$$w_i \in N(u_i) \quad\text{and}\quad w_i \in N(u_{\sigma(i)}),$$
where $\sigma$ is the cyclic successor (rotation) on $\mathbb{Z}/k$. Thus the
$k$ distinct left vertices $u_0,\dots,u_{k-1}$ and the $k$ distinct right
vertices $w_0,\dots,w_{k-1}$ form a closed alternating ring of length $2k$,
with $w_i$ joining consecutive left vertices $u_i$ and $u_{i+1}$.

**Definition 2.5 (Short cycle, girth).** $N$ *has a short cycle* (relative to
$s$) if there is $k$ with $2 \le k \le s$ and a $2k$-cycle (`HasShortCycle`).
$N$ has **girth $\ge 2s+2$** if it has no short cycle (`GirthGe`):
$$\operatorname{girth}(N) \ge 2s+2 \;:\Longleftrightarrow\; \neg\,\mathtt{HasShortCycle}(N,s).$$
Equivalently, $N$ contains no cycle of length in $\{4, 6, \dots, 2s\}$.

**Definition 2.6 (Pairwise disjointness).** $N$ has *all pairs disjoint*
(`AllPairsDisjoint`) if
$$u \ne v \;\Longrightarrow\; N(u) \cap N(v) = \varnothing.$$
A graph satisfying this is a vertex-disjoint union of stars.

*Remark 2.7 (the smallest cycle).* For $k=2$ the rotation $\sigma$ swaps the
two indices, so a $4$-cycle is precisely a pair of distinct left vertices
$u_0 \ne u_1$ together with two distinct right vertices $w_0 \ne w_1$ both in
$N(u_0) \cap N(u_1)$. Hence "$N$ has a $4$-cycle" $\iff$ "some two left
vertices share at least two neighbors." This elementary observation drives
Theorem 6.1.

---

## 3. Foundational lemmas

**Lemma 3.1 (Monotonicity of neighborhood size, `nbhd_card_mono`).** If
$X \subseteq Y$ then $|N(X)| \le |N(Y)|$.

*Proof sketch.* $N(X) = \bigcup_{u\in X} N(u) \subseteq \bigcup_{u\in Y} N(u)
= N(Y)$ by monotonicity of the indexed union in its index set, and cardinality
is monotone under set inclusion (the catalog lemma
`CombinatorialBridge.subset_card_le`). $\qquad\blacksquare$

**Lemma 3.2 (Cycle extraction, `cycle_shared_neighbor`).** If $k \ge 2$ and
$N$ has a $2k$-cycle, then there exist distinct left vertices $a \ne b$ with
$N(a) \cap N(b) \ne \varnothing$.

*Proof sketch.* Write $k = m+2$ and take the cycle data $(u, w)$. Set
$a := u_0$ and $b := u_1$. Injectivity of $u$ gives $a \ne b$ (the indices
$0$ and $1$ are distinct in $\mathbb{Z}/k$ since $k \ge 2$). The cycle
condition at $i = 0$ gives $w_0 \in N(u_0)$ and $w_0 \in N(u_{\sigma(0)}) =
N(u_1)$, so $w_0 \in N(a) \cap N(b)$, witnessing nonemptiness. $\qquad\blacksquare$

This lemma is the structural pivot of the paper: it converts the global,
index-laden cycle hypothesis into a purely local statement about two
neighborhoods intersecting. Every subsequent "no short cycle" argument routes
through it.

**Lemma 3.3 (Disjointness kills all cycles, `disjoint_imp_no_cycle`).** If
$N$ has all pairs disjoint and $k \ge 2$, then $N$ has no $2k$-cycle. In
particular a vertex-disjoint union of stars has infinite girth.

*Proof sketch.* If a $2k$-cycle existed, Lemma 3.2 would supply $a \ne b$ with
$N(a) \cap N(b) \ne \varnothing$, contradicting $N(a) \cap N(b) = \varnothing$
from `AllPairsDisjoint`. $\qquad\blacksquare$

---

## 4. The forward bridge (true)

**Theorem 4.1 (`optimal_imp_girth`).** Let $N$ be left-$d$-regular. If $N$ is
an $s$-optimal small-set expander, then $\operatorname{girth}(N) \ge 2s+2$.

*Proof sketch.* Suppose toward contradiction $N$ has a short cycle: some $k$
with $2 \le k \le s$ and a $2k$-cycle. From $2 \le k \le s$ we get $2 \le s$,
so optimality applies to all left sets of size $\le 2$.

We first show optimality forces *pairwise disjointness*. Take any two distinct
left vertices $u \ne v$ and consider $X = \{u, v\}$, of size $2 \le s$. On one
hand $N(X) = N(u) \cup N(v)$, so optimality gives
$$|N(u) \cup N(v)| = d \cdot 2 = d + d.$$
On the other hand, inclusion–exclusion gives
$$|N(u) \cup N(v)| + |N(u) \cap N(v)| = |N(u)| + |N(v)| = d + d,$$
using left-regularity. Subtracting, $|N(u) \cap N(v)| = 0$, i.e.
$N(u) \cap N(v) = \varnothing$. As $u, v$ were arbitrary, $N$ has all pairs
disjoint.

Now invoke Lemma 3.3: pairwise disjointness implies no $2k$-cycle for any
$k \ge 2$, contradicting the assumed short cycle. Hence no short cycle exists
and $\operatorname{girth}(N) \ge 2s+2$. $\qquad\blacksquare$

*Remark 4.2.* The proof reveals more than the statement: optimality already
forces the *global* disjointness property, from which the girth bound is a
corollary. This over-supply is exactly why the converse cannot hold — see §5.

---

## 5. The converse fails

**Theorem 5.1 (`converse_false`).** There is a left-$2$-regular bipartite
graph $N$ with $\operatorname{girth}(N) \ge 6$ (i.e. `GirthGe N 2`) that is
*not* a $2$-optimal small-set expander.

*Construction and proof sketch.* Let $L = \{0,1\}$, $R = \{0,1,2\}$, $d=2$, and
$$N(0) = \{0,1\}, \qquad N(1) = \{1,2\}.$$
Each left vertex has exactly $2$ neighbors, so $N$ is left-$2$-regular.

*Girth $\ge 6$.* By Remark 2.7, a $4$-cycle would require two left vertices
sharing two neighbors; but $N(0) \cap N(1) = \{1\}$ has a single element. With
only two left vertices there is no room for any longer cycle either. Hence no
short cycle: `GirthGe N 2` holds.

*Not optimal.* Take $X = \{0,1\}$, $|X| = 2 \le s = 2$. Then
$$N(X) = \{0,1\} \cup \{1,2\} = \{0,1,2\}, \qquad |N(X)| = 3 \ne 4 = d\cdot|X|.$$
So `OptimalExpander N 2 2` fails. $\qquad\blacksquare$

**Diagnosis.** The single shared neighbor $1$ is a *collision* but not a
*cycle*: $u_0, u_1$ meeting at one common right vertex form an open path
("$\vee$"), which girth does not forbid, yet which already costs one unit of
neighborhood and destroys optimality. Girth forbids *closed loops*; optimal
expansion forbids *all overlap*. The latter is strictly stronger, so the
implication is genuinely one-directional.

---

## 6. The correct replacements

The two theorems below recover exact equivalences, repairing the broken bridge.

**Theorem 6.1 (Girth-$6$ characterization, `no_four_cycle_iff`).** $N$ has no
$4$-cycle (equivalently $\operatorname{girth}(N) \ge 6$) if and only if every
two distinct left vertices share at most one neighbor:
$$\neg\,\mathtt{HasCycle}(N,2) \iff \big(\forall u \ne v,\ |N(u)\cap N(v)| \le 1\big).$$

*Proof sketch.* ($\Rightarrow$) Contrapositive: if some $u \ne v$ share two
distinct neighbors $w_0 \ne w_1 \in N(u)\cap N(v)$, define the cycle data
$u_0 = u, u_1 = v$ and $w_0, w_1$; both injectivity conditions hold and the
incidence conditions are exactly $w_i \in N(u_0), N(u_1)$, giving a $4$-cycle.
($\Leftarrow$) Contrapositive: a $4$-cycle (Remark 2.7) yields two left
vertices with two distinct common neighbors, so some pair shares more than one
neighbor. $\qquad\blacksquare$

**Theorem 6.2 (Optimal $\equiv$ disjoint, `optimal_iff_disjoint`).** For every
$s \ge 2$, $N$ is an $s$-optimal small-set expander if and only if $N$ has all
pairs disjoint:
$$\mathtt{OptimalExpander}(N,d,s) \iff \mathtt{AllPairsDisjoint}(N) \qquad (s \ge 2).$$

*Proof sketch.* ($\Rightarrow$) This is the disjointness extraction inside the
proof of Theorem 4.1: for $u \ne v$, applying optimality to $\{u,v\}$ and
inclusion–exclusion forces $N(u) \cap N(v) = \varnothing$.

($\Leftarrow$) Suppose all pairs are disjoint and $|X| \le s$. Then
$\{N(u)\}_{u \in X}$ is a pairwise-disjoint family, so the cardinality of the
union is the sum of cardinalities:
$$|N(X)| = \Big|\bigcup_{u\in X} N(u)\Big| = \sum_{u \in X} |N(u)| = \sum_{u\in X} d = d\,|X|,$$
using left-regularity. This is exactly optimality. $\qquad\blacksquare$

**Corollary 6.3 (Threshold collapse).** For all $s \ge 2$,
$$\mathtt{OptimalExpander}(N,d,s) \iff \mathtt{OptimalExpander}(N,d,2) \iff \mathtt{AllPairsDisjoint}(N).$$
The parameter $s$ is informationless beyond $s = 2$: optimal small-set
expansion is a purely *pairwise* condition.

*Proof.* Both equivalences are instances of Theorem 6.2 at $s$ and at $2$,
chained through `AllPairsDisjoint`. $\qquad\blacksquare$

**Corollary 6.4 (Strictness).** Optimal expansion implies, but is not implied
by, girth $\ge 2s+2$. Indeed by Lemma 3.3 an optimal expander (being a
disjoint union of stars) has *infinite* girth, while Theorem 5.1 exhibits a
finite-girth-clearing graph that is not optimal.

---

## 7. The exchange rate between girth and expansion

Collecting the results yields a clean dictionary, with the key correction
highlighted.

| Property | Forbids | Local meaning |
|---|---|---|
| No $4$-cycle (girth $\ge 6$) | two vertices sharing **two** neighbors | every pair shares **$\le 1$** neighbor |
| Optimal expansion ($s \ge 2$) | two vertices sharing **any** neighbor | every pair shares **$0$** neighbors |

The naive conjecture conflated the bottom two cells: it read "girth $\ge 2s+2$"
as "share none" when it actually means "share at most one (and no longer
tangles)." That one-vertex gap — invisible to cycles, fatal to optimality —
is the entire reason the equivalence is one-directional. Optimal expansion is
the *infinite-girth* extreme (disjoint stars), strictly inside the finite-girth
condition.

This refines the LDPC/expander-code folklore: high girth buys *bounded overlap
multiplicity*, which is exactly the input to unique-neighbor arguments, but not
the *zero overlap* of a perfect packing.

---

## 8. Algorithms

We summarize the decision procedures implicit in the proofs; all run in time
polynomial in $|L|$, $|R|$, and $d$.

**Algorithm 8.1 (Optimal-expander test via disjointness).** By Theorem 6.2,
to decide $s$-optimality for $s \ge 2$ it suffices to test pairwise
disjointness:
```
for each unordered pair {u, v} of left vertices:
    if N(u) ∩ N(v) ≠ ∅: return "not optimal"
return "optimal"
```
Complexity $O(|L|^2 d)$, independent of $s$ — the algorithmic face of the
threshold collapse (Corollary 6.3).

**Algorithm 8.2 (Girth-$\ge 6$ test).** By Theorem 6.1, test pairwise
intersection multiplicity:
```
for each unordered pair {u, v} of left vertices:
    if |N(u) ∩ N(v)| ≥ 2: return "has 4-cycle (girth < 6)"
return "girth ≥ 6"
```
Complexity $O(|L|^2 d)$.

**Algorithm 8.3 (Direct neighborhood-optimality check).** Compute
$N(X) = \bigcup_{u\in X} N(u)$ for the candidate set $X$ and compare $|N(X)|$
with $d|X|$. This is the literal definition and is used to certify the
counterexample of Theorem 5.1.

---

## 9. Applications

- **Code design.** For Tanner graphs of LDPC/expander codes, Algorithm 8.2
  gives an $O(|L|^2 d)$ girth-$6$ certificate, and §7 clarifies precisely what
  guarantee that certificate does (bounded overlap) and does not (zero overlap)
  provide.
- **Sampler/packing verification.** Optimal small-set expansion is exactly a
  disjoint packing of stars; Algorithm 8.1 verifies such packings in quadratic
  time regardless of the claimed parameter $s$.
- **Pedagogy of expansion.** The dichotomy is a sharp teaching example that an
  attractive "iff" can be half-true, and that diagnosing the failure
  (collision vs. cycle) is more instructive than the original guess.

---

## 10. Discussion

The investigation followed an adversarial loop: a bold equivalence was
hypothesized, the forward half proved, the converse stress-tested and broken
by a minimal explicit graph, and the rubble reorganized into two exact
characterizations plus a collapse corollary. The mathematical content is
modest in size but sharp in consequence: it pins the *exact* exchange rate
between girth and optimal expansion, replacing folklore with a theorem.

A subtle point worth emphasizing is that optimality is *parameter-free* beyond
$s=2$ (Corollary 6.3), whereas girth is genuinely parameterized by $s$.
This asymmetry is itself a proof that the two cannot be equivalent: an
$s$-graded family on one side cannot match a collapsing family on the other.

---

## 11. Future directions

**C1. Forest characterization of girth $\ge 2s+2$.** Conjecture:
$\mathtt{GirthGe}(N,s)$ holds iff every set $X$ of $\le s$ left vertices
induces an *acyclic* subgraph on $X \cup N(X)$. A $2k$-cycle lives entirely
inside the subgraph induced by its $k$ left vertices, so forbidding short
cycles should be exactly forbidding induced cycles on small left-sets — the
correct expansion statement is acyclicity, not maximal expansion. The
cycle-extraction pivot `cycle_shared_neighbor` and the model `HasCycle` are in
hand; promoting "shares a neighbor" to "contains an induced cycle" needs a
`SimpleGraph.IsAcyclic` bridge.

**C2. Quantitative expansion floor from girth.** Conjecture: if
$\mathtt{GirthGe}(N,s)$ then every $X$ with $|X|\le s$ satisfies
$(d-1)|X| + 1 \le |N(X)|$, tight for a single tree component. An induced
forest on $t$ left vertices with $dt$ edges must have at least $dt - t + 1$
right vertices, converting the qualitative girth hypothesis into a
quantitative lower bound on $\alpha_G(t)$. The matching upper bound
$|N(X)| \le d|X|$ is already available via `nbhd_card_mono`.

**C3. Threshold collapse of optimal expansion.** Conjecture: for $s \ge 2$,
$\mathtt{OptimalExpander}(N,d,s)$ is independent of $s$ — equivalent to
$\mathtt{OptimalExpander}(N,d,2)$ and to $\mathtt{AllPairsDisjoint}(N)$.
Maximal expansion is a *pairwise* condition: once any two neighborhoods must
be disjoint, every larger union is automatically disjoint. This is recorded
above as Corollary 6.3; `optimal_iff_disjoint` supplies both endpoints.

**C4. Spielman–Tanner unique-neighbor refinement.** Conjecture: the correct
coding-theoretic analogue is that girth $\ge 2s+2$ iff every $X$ with
$|X| \le s$ has a *unique-neighbor* vertex (a right vertex adjacent to exactly
one element of $X$), connecting the girth condition to the unique-neighbor
expansion that drives the Spielman–Tanner analysis of expander codes $B(G)$.

---

## 12. Conclusion

The literal girth–expansion bridge for optimal small-set expanders is
one-directional: `optimal_imp_girth` holds for general $s$, but the converse
fails (`converse_false`) because "exactly $d|X|$ neighbors" forces
pairwise-disjoint neighborhoods (`optimal_iff_disjoint`), strictly stronger
than excluding short cycles. The genuine girth-$6$ statement is
`no_four_cycle_iff`. Together these results convert a plausible but false
equivalence into an exact, quantitative account of how reach and loops relate.
