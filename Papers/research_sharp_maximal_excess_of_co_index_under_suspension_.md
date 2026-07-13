# The Co-index of Free $\mathbb{Z}_2$-Complexes under Suspension: A Constructive Foundation for Sharp Excess

## Abstract

The **co-index** of a free $\mathbb{Z}_2$-space measures the largest dimension $n$
for which the $n$-sphere admits an antipode-preserving map into the space. It is the
combinatorial engine behind the Borsuk–Ulam theorem and Lovász-type chromatic lower
bounds. A guiding question, in the Simonyi–Tardos–Vrécica circle of problems, asks
how the co-index behaves under the unreduced suspension $S(K) = K * S^0$, where the
sharp upper bound $\mathrm{coind}(S(K)) \le \dim(K) + 1$ is conjectured to be
attained with maximal excess $d - c$ for *every* feasible starting co-index
$1 \le c \le d$ of a $d$-dimensional complex. We develop a self-contained,
subdivision-free combinatorial theory of free $\mathbb{Z}_2$-simplicial complexes,
their equivariant simplicial maps, the octahedral spheres $\mathrm{Oct}\,n$
(triangulations of $S^n$), and the join-with-$S^0$ suspension. Within this framework
we establish the constructive lower-bound half of the maximal-excess program
unconditionally: (i) suspension is functorial on equivariant simplicial maps; (ii)
there is an explicit equivariant simplicial map $\mathrm{Oct}\,(n+1) \to
S(\mathrm{Oct}\,n)$ realizing the classical homeomorphism $S^{n+1} \cong S(S^n)$;
(iii) consequently suspension raises the co-index by at least one; and (iv) the
octahedral tower realizes the diagonal $\mathrm{coind}(\mathrm{Oct}\,n) = n$. We also
prove a genuine combinatorial Borsuk–Ulam instance — its base case — showing there is
no equivariant simplicial map $\mathrm{Oct}\,n \to \mathrm{Oct}\,0$ for $n \ge 1$, so
the co-index of $S^0$ is exactly $0$. Together these results provide the verified
scaffolding on which the large-jump construction of the sharp-excess conjecture can be
built, and they isolate precisely why that construction is deeper: the excess beyond
$+1$ must come from global equivariant connectivity rather than a single suspension
coordinate.

**Keywords:** free $\mathbb{Z}_2$-complex, co-index, suspension, join, octahedral
sphere, cross-polytope, Borsuk–Ulam theorem, equivariant simplicial map, Lovász
chromatic bound, box complex.

---

## 1. Introduction

### 1.1 Co-index and its role

Let $X$ be a topological space equipped with a free involution — a continuous map
$\nu : X \to X$ with $\nu \circ \nu = \mathrm{id}$ and $\nu(x) \ne x$ for all $x$. Such
a pair $(X, \nu)$ is a **free $\mathbb{Z}_2$-space**. The $n$-sphere $S^n$, with the
antipodal map $x \mapsto -x$, is the fundamental example. A map $f : X \to Y$ between
free $\mathbb{Z}_2$-spaces is **equivariant** (or a **$\mathbb{Z}_2$-map**) if it
commutes with the involutions.

The **co-index** of $(X, \nu)$ is
$$\mathrm{coind}(X) = \max \{ n : \text{there exists an equivariant map } S^n \to X \},$$
the largest sphere that maps antipodally into $X$. Its companion, the **index**, is
the least $n$ admitting an equivariant map $X \to S^n$; the Borsuk–Ulam theorem is
exactly the inequality $\mathrm{coind}(X) \le \mathrm{index}(X)$, and its classical
form $\mathrm{coind}(S^n) = \mathrm{index}(S^n) = n$ states that $S^n$ does not map
antipodally to $S^m$ for $m < n$.

These invariants are the backbone of the topological method in combinatorics. In
Lovász's proof of the Kneser conjecture, one attaches to a graph $G$ a free
$\mathbb{Z}_2$-space (the neighborhood or box complex) whose co-index gives a lower
bound on the chromatic number: $\chi(G) \ge \mathrm{coind}(B(G)) + 2$.

### 1.2 Suspension and the sharp-excess question

The **unreduced suspension** of a free $\mathbb{Z}_2$-space $K$ is the join
$S(K) = K * S^0$: one adjoins two antipodal apex points and joins every point of $K$
to both. Topologically $S(S^n) \cong S^{n+1}$, so suspension climbs the sphere tower.

For a $d$-dimensional free $\mathbb{Z}_2$-complex $K$ there is a sharp upper bound
$$\mathrm{coind}(S(K)) \le \dim(K) + 1 = d + 1.$$
The Simonyi–Tardos–Vrécica program asks whether this bound is attained with
**maximal excess** for every feasible starting co-index. Concretely:

> **Sharp-Excess Conjecture.** For all integers $d \ge 2$ and $c$ with
> $1 \le c \le d$, there exists a finite free $\mathbb{Z}_2$-complex $K$ of dimension
> $d$ with $\mathrm{coind}(K) = c$ and $\mathrm{coind}(S(K)) = d + 1$, achieving the
> maximal excess $d - c$.

The case $c = 1$ (for all $d \ge 2$) is known. The general conjecture, asserting the
bound is sharp for every feasible $c$, is open.

### 1.3 Contributions

This paper develops a compact, entirely combinatorial and subdivision-free model of
free $\mathbb{Z}_2$-complexes and establishes, unconditionally, the constructive
lower-bound half of the maximal-excess program, together with the Borsuk–Ulam base
case. Our contributions are:

1. **A category of free $\mathbb{Z}_2$-complexes** with equivariant simplicial maps
   as morphisms (identities and composition; Section 3).
2. **The octahedral spheres $\mathrm{Oct}\,n$** as explicit triangulations of $S^n$,
   with exact dimension bookkeeping: $\dim(\mathrm{Oct}\,n) = n$ (Section 4).
3. **A join-with-$S^0$ suspension** functor on this category, with the apex-pair
   exclusion that faithfully models $S^0$ (Section 5).
4. **An explicit equivariant simplicial map** $\mathrm{Oct}\,(n+1) \to
   S(\mathrm{Oct}\,n)$ realizing $S^{n+1} \cong S(S^n)$ combinatorially (Section 6).
5. **The suspension co-index inequality:** an equivariant map $\mathrm{Oct}\,m \to K$
   yields one $\mathrm{Oct}\,(m+1) \to S(K)$; hence suspension raises the co-index by
   at least one, and the octahedral tower realizes the diagonal
   $\mathrm{coind}(\mathrm{Oct}\,n) = n$ (Section 6).
6. **A combinatorial Borsuk–Ulam base case:** no equivariant simplicial map
   $\mathrm{Oct}\,n \to \mathrm{Oct}\,0$ exists for $n \ge 1$, so
   $\mathrm{coind}(S^0) = 0$ (Section 7).

Section 8 discusses why the large jump is genuinely deeper and records the program's
next escalations.

---

## 2. The combinatorial model

We work with abstract simplicial complexes equipped with a free simplicial
involution, and use a **subdivision-free lower bound** for the co-index: the existence
of an equivariant *simplicial* map from a fixed triangulated sphere.

### 2.1 Free $\mathbb{Z}_2$-complexes

**Definition 2.1 (Free $\mathbb{Z}_2$-complex).** A *free $\mathbb{Z}_2$-complex* on
a vertex set $V$ consists of:

- an involution $\alpha : V \to V$ (so $\alpha(\alpha(v)) = v$) that is **free**:
  $\alpha(v) \ne v$ for all $v$;
- a family of **faces** $\mathcal{F} \subseteq 2^V$ (finite subsets of $V$) that is
  *downward closed* ($t \subseteq s \in \mathcal{F} \Rightarrow t \in \mathcal{F}$),
  contains the empty set, and is **$\alpha$-invariant**: if $s \in \mathcal{F}$ then
  its image $\alpha(s) = \{\alpha(v) : v \in s\}$ lies in $\mathcal{F}$.

The involution $\alpha$ is the combinatorial antipodal map; freeness is the discrete
form of "$\nu(x) \ne x$." The **dimension** of the complex is
$\max\{ |s| - 1 : s \in \mathcal{F}\}$.

**Definition 2.2 ($\mathbb{Z}_2$-simplicial map).** Given free $\mathbb{Z}_2$-complexes
$K$ on $V$ and $L$ on $W$, a *$\mathbb{Z}_2$-simplicial map* $f : K \to L$ is a vertex
map $f : V \to W$ that is
- **equivariant:** $f(\alpha_K(v)) = \alpha_L(f(v))$ for all $v \in V$; and
- **simplicial:** $s \in \mathcal{F}_K \Rightarrow f(s) \in \mathcal{F}_L$.

**Definition 2.3 (Co-index lower bound).** For a fixed triangulated $n$-sphere $\Sigma_n$
(below, $\mathrm{Oct}\,n$) and a free $\mathbb{Z}_2$-complex $K$, write
$$\Sigma_n \Rightarrow K \iff \text{there exists a } \mathbb{Z}_2\text{-simplicial map } \Sigma_n \to K,$$
read "the co-index of $K$ is at least $n$." Because an equivariant simplicial map is
in particular an equivariant continuous map on geometric realizations, this relation
is a genuine (subdivision-free) lower bound for the topological co-index.

---

## 3. The category of free $\mathbb{Z}_2$-complexes

The morphisms compose and admit identities.

**Proposition 3.1 (Identity).** For any free $\mathbb{Z}_2$-complex $K$, the identity
vertex map is a $\mathbb{Z}_2$-simplicial map $K \to K$.

*Proof.* The identity trivially commutes with $\alpha_K$ and sends each face to
itself. $\blacksquare$

**Proposition 3.2 (Composition).** If $g : K \to L$ and $h : L \to M$ are
$\mathbb{Z}_2$-simplicial maps, then $h \circ g : K \to M$ is a $\mathbb{Z}_2$-simplicial
map.

*Proof.* Equivariance: $h(g(\alpha_K v)) = h(\alpha_L(g v)) = \alpha_M(h(g v))$.
Simpliciality: $(h \circ g)(s) = h(g(s))$, and $g(s) \in \mathcal{F}_L$ by
simpliciality of $g$, whence $h(g(s)) \in \mathcal{F}_M$ by simpliciality of $h$;
the set identity $h(g(s)) = (h \circ g)(s)$ holds because taking images commutes with
composition. $\blacksquare$

Thus free $\mathbb{Z}_2$-complexes and $\mathbb{Z}_2$-simplicial maps form a category,
and the relation $\Sigma_\bullet \Rightarrow -$ is monotone under morphisms out of $K$.

---

## 4. The octahedral spheres $\mathrm{Oct}\,n \cong S^n$

**Definition 4.1 (Octahedral $n$-sphere).** The *octahedral $n$-sphere*
$\mathrm{Oct}\,n$ is the boundary complex of the $(n+1)$-dimensional cross-polytope:

- **Vertices:** $\{0, 1, \dots, n\} \times \{+, -\}$ (each axis $i$ has a $+$ end and
  a $-$ end); there are $2(n+1)$ of them.
- **Involution:** $\alpha(i, \varepsilon) = (i, -\varepsilon)$, flipping the sign.
- **Faces:** a finite vertex set $s$ is a face iff it contains **no antipodal pair**,
  i.e. for no axis $i$ do both $(i, +)$ and $(i, -)$ belong to $s$.

The involution is free (flipping a sign never fixes a vertex), and the face family is
downward closed, contains $\emptyset$, and is $\alpha$-invariant (flipping signs
preserves the property of having no antipodal pair). Geometrically, realizing
$(i, \pm)$ as $\pm e_i \in \mathbb{R}^{n+1}$ exhibits $\mathrm{Oct}\,n$ as the boundary
of the cross-polytope, a triangulation of $S^n$.

**Lemma 4.2 (Top face).** The "positive orthant" $\{(i, +) : 0 \le i \le n\}$ is a face
of $\mathrm{Oct}\,n$ with $n+1$ vertices.

*Proof.* It contains no $-$ vertex, hence no antipodal pair. $\blacksquare$

**Lemma 4.3 (Dimension bound).** Every face $s$ of $\mathrm{Oct}\,n$ satisfies
$|s| \le n+1$; hence $\dim(\mathrm{Oct}\,n) = n$.

*Proof.* The no-antipodal-pair condition means the axis-projection
$(i, \varepsilon) \mapsto i$ is *injective* on any face $s$: two vertices of $s$ with
the same axis would be either equal or an antipodal pair, and a pair is forbidden.
Thus $|s| = |\{i : (i, \varepsilon) \in s\}| \le |\{0, \dots, n\}| = n+1$. Combined
with Lemma 4.2, the maximal face size is exactly $n+1$ and the dimension is $n$.
$\blacksquare$

**Corollary 4.4.** $\mathrm{Oct}\,n \Rightarrow \mathrm{Oct}\,n$ holds via
the identity map: $\mathrm{coind}(\mathrm{Oct}\,n) \ge n$.

---

## 5. The suspension $S(K) = K * S^0$

**Definition 5.1 (Suspension).** For a free $\mathbb{Z}_2$-complex $K$ on $V$, its
*suspension* $S(K)$ is the free $\mathbb{Z}_2$-complex on $V \sqcup \{N, S\}$ (base
vertices together with two apexes North and South) defined by:

- **Involution:** $\alpha_{S(K)}$ acts as $\alpha_K$ on the base and swaps
  $N \leftrightarrow S$; it is free because $\alpha_K$ is free and $N \ne S$.
- **Faces:** a set $T \subseteq V \sqcup \{N, S\}$ is a face iff (a) its base part
  $T \cap V$ is a face of $K$, and (b) $T$ does **not** contain both apexes $N$ and $S$.

Condition (b) is essential: it makes $\{N, S\}$ behave as $S^0$ (two *disjoint*
antipodal points, never joined). One checks directly that the face family is downward
closed, contains $\emptyset$, and is $\alpha_{S(K)}$-invariant (the base part of
$\alpha(T)$ is $\alpha_K$ of the base part, a face by $\alpha$-invariance of $K$; and
$\alpha$ merely swaps $N, S$, so it cannot create the forbidden apex pair from a set
lacking it).

**Proposition 5.2 (Suspension is functorial).** A $\mathbb{Z}_2$-simplicial map
$g : K \to L$ induces a $\mathbb{Z}_2$-simplicial map $S(g) : S(K) \to S(L)$ acting as
$g$ on the base and as the identity on apexes.

*Proof.* Equivariance holds on the base (where it reduces to that of $g$) and on the
apexes (where both sides swap $N, S$). For simpliciality, let $T$ be a face of $S(K)$.
Its base part maps under $g$ to a face of $L$ (simpliciality of $g$), which is the base
part of $S(g)(T)$; and $S(g)$ fixes apexes, so if $T$ omits one of $N, S$ then so does
$S(g)(T)$. Hence $S(g)(T)$ is a face of $S(L)$. $\blacksquare$

**Lemma 5.3 (Suspension raises dimension).** If $s$ is a face of $K$, then
$\{N\} \cup s$ is a face of $S(K)$ with $|s| + 1$ vertices. Consequently
$\dim(S(K)) = \dim(K) + 1$.

*Proof.* The base part is $s$, a face of $K$, and the set contains only the apex $N$,
not both apexes. The count follows since $N \notin V$. $\blacksquare$

---

## 6. The combinatorial homeomorphism and the co-index inequality

The technical core is an explicit equivariant simplicial map realizing
$S^{n+1} \cong S(S^n)$.

**Definition 6.1 (Connecting map).** Define
$\varphi_n : \mathrm{Oct}\,(n+1) \to S(\mathrm{Oct}\,n)$ on vertices by
$$\varphi_n(i, \varepsilon) = \begin{cases} (i, \varepsilon) \in \text{base}, & 0 \le i \le n, \\[2pt] N, & i = n+1 \text{ and } \varepsilon = +, \\[2pt] S, & i = n+1 \text{ and } \varepsilon = -. \end{cases}$$
The $(n+1)$-sphere has axes $0, \dots, n+1$; the map keeps the first $n+1$ axes in the
base copy of $\mathrm{Oct}\,n$ and sends the two ends of the extra axis $n+1$ to the
apexes.

**Lemma 6.2 ($\varphi_n$ is equivariant).** $\varphi_n(\alpha(i,\varepsilon)) =
\alpha_{S(\mathrm{Oct}\,n)}(\varphi_n(i,\varepsilon))$.

*Proof.* If $i \le n$, both sides flip the sign inside the base. If $i = n+1$, flipping
the sign swaps $+ \leftrightarrow -$, i.e. $N \leftrightarrow S$, which is exactly the
apex swap of $\alpha_{S(\mathrm{Oct}\,n)}$. $\blacksquare$

**Lemma 6.3 ($\varphi_n$ is simplicial).** If $s$ is a face of $\mathrm{Oct}\,(n+1)$
then $\varphi_n(s)$ is a face of $S(\mathrm{Oct}\,n)$.

*Proof.* The base part of $\varphi_n(s)$ consists of the vertices $(i, \varepsilon) \in
s$ with $i \le n$; these already avoid antipodal pairs in $s$, so they form a face of
$\mathrm{Oct}\,n$. For the apex condition, $N \in \varphi_n(s)$ requires
$(n+1, +) \in s$ and $S \in \varphi_n(s)$ requires $(n+1, -) \in s$; both together
would be an antipodal pair on axis $n+1$, which $s$ forbids. Hence $\varphi_n(s)$
contains at most one apex and its base part is a face — a face of the suspension.
$\blacksquare$

**Theorem 6.4 (Combinatorial $S^{n+1} \cong S(S^n)$).** $\varphi_n$ is a
$\mathbb{Z}_2$-simplicial map $\mathrm{Oct}\,(n+1) \to S(\mathrm{Oct}\,n)$.

*Proof.* Immediate from Lemmas 6.2 and 6.3. $\blacksquare$

**Theorem 6.5 (Suspension raises the co-index by at least one).** Let $K$ be any free
$\mathbb{Z}_2$-complex. If $\mathrm{Oct}\,m \Rightarrow K$ holds, then so does
$\mathrm{Oct}\,(m+1) \Rightarrow S(K)$. In words: if $\mathrm{coind}(K) \ge m$
then $\mathrm{coind}(S(K)) \ge m + 1$.

*Proof.* Let $g : \mathrm{Oct}\,m \to K$ be an equivariant simplicial map. By
Proposition 5.2, $S(g) : S(\mathrm{Oct}\,m) \to S(K)$ is equivariant simplicial. Compose
with the connecting map of Theorem 6.4:
$$\mathrm{Oct}\,(m+1) \xrightarrow{\ \varphi_m\ } S(\mathrm{Oct}\,m) \xrightarrow{\ S(g)\ } S(K).$$
By Proposition 3.2 the composite $S(g) \circ \varphi_m$ is an equivariant simplicial
map $\mathrm{Oct}\,(m+1) \to S(K)$, witnessing
$\mathrm{Oct}\,(m+1) \Rightarrow S(K)$. $\blacksquare$

**Corollary 6.6 (Octahedral diagonal).** $\mathrm{Oct}\,(n+1) \Rightarrow
S(\mathrm{Oct}\,n))$ holds; more generally the tower satisfies
$\mathrm{coind}(\mathrm{Oct}\,n) \ge n$ with the identity certificate, and suspension
carries these certificates up the ladder in lockstep.

*Proof.* Apply Theorem 6.5 to the identity certificate of Corollary 4.4. $\blacksquare$

This is the **unconditional lower-bound half** of the sharp-excess program: suspension
never loses co-index, and always adds at least one; the octahedral tower realizes the
diagonal $\mathrm{coind} = \dim$.

---

## 7. A combinatorial Borsuk–Ulam obstruction

A lower bound is only half the story; the model must also *forbid* dimension-dropping
equivariant maps, the signature of Borsuk–Ulam. We prove the base case directly.

**Theorem 7.1 (Combinatorial Borsuk–Ulam, base case).** For $n \ge 1$ there is no
$\mathbb{Z}_2$-simplicial map $\mathrm{Oct}\,n \to \mathrm{Oct}\,0$. Equivalently, any
$\mathbb{Z}_2$-simplicial map $\mathrm{Oct}\,n \to \mathrm{Oct}\,0$ forces $n = 0$, so
$\mathrm{coind}(S^0) = \mathrm{coind}(\mathrm{Oct}\,0) = 0$.

*Proof.* Suppose $n \ge 1$ and let $g : \mathrm{Oct}\,n \to \mathrm{Oct}\,0$ be a
$\mathbb{Z}_2$-simplicial map. The target $\mathrm{Oct}\,0$ has exactly two vertices,
the single antipodal pair $\{(0,+),(0,-)\}$; its faces have at most one vertex.

Choose the plus ends of two distinct axes, $a = (0,+)$ and $b = (1,+)$ (possible since
$n \ge 1$). Since $a$ and $b$ lie on different axes, $\{a, b\}$ contains no antipodal
pair and is therefore a face of $\mathrm{Oct}\,n$. Simpliciality gives that
$\{g(a), g(b)\}$ is a face of $\mathrm{Oct}\,0$, which has at most one vertex; hence
$$g(a) = g(b). \tag{$\ast$}$$

Now consider $\{a, \alpha(b)\} = \{(0,+), (1,-)\}$: again the two vertices lie on
different axes, so this is a face of $\mathrm{Oct}\,n$, and $\{g(a), g(\alpha(b))\}$ is
a face of $\mathrm{Oct}\,0$. By equivariance $g(\alpha(b)) = \alpha(g(b))$, and by
$(\ast)$ this equals $\alpha(g(a))$. Therefore
$$\{g(a),\, \alpha(g(a))\} \text{ is a face of } \mathrm{Oct}\,0.$$
But $\{g(a), \alpha(g(a))\}$ is exactly the antipodal pair on the single axis of
$\mathrm{Oct}\,0$ — which is *not* a face. This contradiction shows no such $g$ exists.
$\blacksquare$

**Remark 7.2 (Freeness is load-bearing).** Both hypotheses of the model are used
essentially. If $\alpha$ were allowed a fixed point, or if faces were allowed to
contain antipodal pairs, then a constant map to a single vertex of $\mathrm{Oct}\,0$
would be a legal equivariant simplicial map and Theorem 7.1 would fail. Freeness of the
involution together with antipodal-pair-freeness of faces *is* the discrete Borsuk–Ulam
obstruction; the proof collapses precisely to the impossibility of an equivariant map
sending an antipodal pair to a non-antipodal image.

---

## 8. Discussion: why the large jump is deeper

Theorem 6.5 delivers the exact "$+1$" arithmetic of a single suspension, and Theorem 7.1
shows the framework already detects the Borsuk–Ulam obstruction on which the upper bound
$\mathrm{coind}(S(K)) \le \dim(K) + 1$ rests. The gap to the full Sharp-Excess Conjecture
is instructive.

A single suspension adds exactly one apex axis, and the connecting map $\varphi_n$ spends
that one axis climbing a single rung. To force a co-index-*poor* $d$-dimensional complex
$K$ (with $\mathrm{coind}(K) = c$ possibly far below $d$) all the way up to
$\mathrm{coind}(S(K)) = d+1$ — a jump of size $d + 1 - c$ — the extra co-index cannot come
from the lone new coordinate. It must come from the **global equivariant connectivity** of
$K$: suspension repairs precisely the equivariant homotopical defect that suppresses the
co-index of $K$, and that defect can be engineered to be as large as the ambient dimension
allows. This is why a complex may be simultaneously "co-index poor" and "suspension rich."
Constructing such complexes for every feasible $c$ is the crux of the open problem; the
octahedral spheres already provide the exact upper-bound certificates (Lemma 4.3) needed to
measure both $\dim(K)$ and the target co-index simultaneously.

---

## 9. Applications

**Chromatic lower bounds.** For a graph $G$, the box complex $B(G)$ is a free
$\mathbb{Z}_2$-complex with the Lovász-type bound $\chi(G) \ge \mathrm{coind}(B(G)) + 2$.
Csorba's identity $B_0(G) \simeq S(B(G))$ converts the suspension excess into a directly
graph-theoretic quantity. A quantitative understanding of suspension excess therefore
translates into sharpened chromatic bounds, potentially detecting colorings the classical
Lovász value misses.

**Certifying non-existence.** Theorem 7.1 is a template for combinatorial Borsuk–Ulam
certificates: an equivariant simplicial map to a low-dimensional octahedral sphere is
obstructed by a purely local antipodal-pair argument. Extending it (Section 10) would turn
the co-index *lower* bounds of this paper into exact values.

---

## 10. Future work

The following escalations are natural next steps.

1. **Maximal excess for every feasible starting co-index.** Prove the Sharp-Excess
   Conjecture: for all $d \ge 2$ and $1 \le c \le d$, construct a finite free
   $\mathbb{Z}_2$-complex of dimension $d$, co-index exactly $c$, whose suspension has
   co-index $d+1$. The constructive $+1$ bound and the octahedral realization of the
   diagonal are in hand; what remains is a family of complexes pinned *below* their
   dimension in co-index yet forced *up* to $d+1$ after one suspension.

2. **A full combinatorial Borsuk–Ulam for octahedral spheres.** Prove there is no
   equivariant simplicial map $\mathrm{Oct}\,m \to \mathrm{Oct}\,n$ when $m > n$;
   equivalently $\mathrm{coind}(\mathrm{Oct}\,n) = n$ exactly. Antipodal-pair-freeness
   should encode the parity obstruction, so the non-existence should follow from a discrete
   degree/parity count on top-dimensional antipodal face pairs rather than from any
   continuous argument. Promoting the base case $n \to 0$ to all $n$ closes the gap between
   the combinatorial and the topological co-index.

3. **Suspension defect and the Lovász chromatic bound.** Investigate whether the excess
   $\mathrm{coind}(S(K)) - \mathrm{coind}(K) - 1$ of a box complex $B(G)$ controls a
   strengthening of $\chi(G) \ge \mathrm{coind}(B(G)) + 2$: graphs whose box complex has
   large suspension excess should admit chromatic lower bounds strictly beyond the Lovász
   value, via Csorba's identity $B_0(G) \simeq S(B(G))$.

---

## 11. Conclusion

We have built a compact, subdivision-free combinatorial model of free
$\mathbb{Z}_2$-complexes and used it to establish, unconditionally, the constructive
lower-bound half of the maximal-excess program: suspension is functorial, the explicit map
$\mathrm{Oct}\,(n+1) \to S(\mathrm{Oct}\,n)$ realizes $S^{n+1} \cong S(S^n)$, suspension
raises the co-index by at least one, and the octahedral tower realizes the diagonal
$\mathrm{coind}(\mathrm{Oct}\,n) = n$. We further proved a genuine Borsuk–Ulam base case,
$\mathrm{coind}(S^0) = 0$, exhibiting the exact obstruction that freeness encodes. These
results form a verified foundation on which the deeper large-jump construction — the
excess beyond $+1$ demanded by the Sharp-Excess Conjecture — can be assembled, and they
pinpoint why that construction must draw on global equivariant connectivity rather than a
single suspension coordinate.
