# Scan Schemes: Honest Uniqueness Decoding, Exact Cost Accounting, and the $1/(2\varepsilon)$ Compression Barrier

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

We give a complete, exact analysis of the simplest and most widely deployed lookup
structure: a *scan scheme*, in which $N$ totally ordered keys are distributed among
$m$ labelled buckets and a key is retrieved by scanning its bucket linearly. Two
foundational facts anchor the model. First, **honest uniqueness decoding**: the pair
consisting of a key's bucket label and its *intra-bucket index* is a uniquely
decodable code for that key — it decodes back to the key, and it is the only pair
that does — so no ambiguity is hidden inside the cost model. Second, **exact cost
accounting**: the total decoding cost of a scheme equals, identically, the sum over
buckets of the triangular number of the bucket's size.

These reduce the optimisation of scan schemes to a purely arithmetic problem, which
we solve exactly. Using an integral tangent-line inequality for the triangular
function $T(k)=k(k+1)/2$ with the upper slope $q+1$, we prove that the least
achievable total cost of $N$ keys in $m$ buckets is
$$\mathrm{Opt}(N,m) = r\,T(q+1) + (m-r)\,T(q), \qquad q = \lfloor N/m\rfloor,\quad r = N \bmod m,$$
attained by the residue scheme $x \mapsto x \bmod m$; that the optimum is **rigid**,
i.e. a scheme is optimal *if and only if* every bucket has size $q$ or $q+1$; that
the total cost is invariant under the natural symmetry action
$\mathrm{Sym}(\text{keys}) \times \mathrm{Sym}(\text{buckets})$, so that the optimal locus is a single group
orbit; that unit cost everywhere is equivalent to injectivity of the bucket map
(perfect hashing), whence any compressing scheme has a key of cost at least two; that
the greatest achievable cost is $T(N)$, attained by the one-bucket scheme; and that
the mean decoding cost of every scheme is at least $\tfrac12(N/m + 1)$, giving the
**$\varepsilon$-compression barrier**: a scheme using $m \le \varepsilon N$ buckets
has mean decoding cost at least $1/(2\varepsilon)$, with the constant $1/2$ sharp,
since the residue scheme attains it whenever $m \mid N$.

Finally we determine the structure of the achievable cost set. It lies in the window
$[\mathrm{Opt}(N,m),\,T(N)]$ with both endpoints attained, but it is *not* the full
integer interval: it is exactly the set of sums $\sum_i T(k_i)$ over partitions of
$N$ into at most $m$ parts, a sparse set which for $(N,m) = (5,3)$ equals
$\{7,8,9,11,15\}$.

**Keywords:** scan scheme, bucket map, intra-bucket index, uniquely decodable code,
triangular number, discrete convexity, tangent-line inequality, pigeonhole optimum,
rigidity, perfect hashing, space–time trade-off.

---

## 1. Introduction

### 1.1 The problem

Bucketed lookup is the workhorse of practical data structures. One fixes a map from a
key universe into a set of bucket labels; keys landing in the same bucket collide and
are resolved by a linear scan. The classical analysis of this arrangement is
probabilistic and asymptotic: assume the bucket map behaves like a random function,
conclude that the expected chain length is $O(N/m)$, and stop.

This paper takes the opposite stance. We fix no randomness, make no distributional
assumption on the keys, and prove statements that are *exact*: identities where an
identity is available, and inequalities that are attained, with the attaining objects
identified. The resulting picture is a complete description — floor, ceiling, optimal
locus, symmetry group, and trade-off constant — of the deterministic combinatorics
underlying bucketed lookup.

### 1.2 Contributions

1. A precise formulation of what it means for the cost model to be *honest*: the scan
   code (bucket label, intra-bucket index) is a uniquely decodable code
   (Theorems 3.1 and 3.2).
2. An exact accounting identity converting total decode cost into a sum of triangular
   numbers of bucket sizes (Theorem 3.5).
3. The exact pigeonhole optimum with its attaining scheme (Theorems 4.4 and 5.2), via
   an integral tangent-line inequality (Lemma 4.1).
4. Rigidity: the optimal locus is exactly the set of balanced profiles (Theorem 6.1),
   with symmetry invariance (Theorem 6.4) identifying it as a single orbit.
5. Perfect hashing characterised, and a pigeonhole failure analysis (Theorems 6.2, 6.3).
6. The exact maximum $T(N)$ and the cost window (Theorems 7.2, 7.3), together with the
   exact description of the achievable set as sums of triangular numbers over
   partitions (Proposition 7.4), which shows the window is porous.
7. The mean-cost bound and the $\varepsilon$-compression barrier with a matching
   equality case (Theorems 8.2, 8.3, 8.4).

### 1.3 Notation

Throughout, $\mathbb{N} = \{0,1,2,\dots\}$; $\alpha$ denotes a finite totally ordered
set of *keys* with $|\alpha| = N$, and $\beta$ a finite set of *bucket labels* with
$|\beta| = m$. For $k \in \mathbb{N}$ we write
$$T(k) = \frac{k(k+1)}{2} = 1 + 2 + \cdots + k$$
for the $k$-th triangular number, and we set $q = \lfloor N/m\rfloor$ and
$r = N \bmod m$ whenever $m \ge 1$, so that $N = mq + r$ with $0 \le r < m$.

---

## 2. The model

**Definition 2.1 (Scan scheme).** A *scan scheme* on keys $\alpha$ with bucket labels
$\beta$ is a function $b : \alpha \to \beta$. We write $S$ for the scheme and
$b_S$ for its bucket map.

**Definition 2.2 (Fibre, scan list).** For $\ell \in \beta$, the *fibre* is the finite
set $F_S(\ell) = \{x \in \alpha : b_S(x) = \ell\}$, and the *scan list*
$L_S(\ell)$ is the list of the elements of $F_S(\ell)$ arranged in increasing order
with respect to the total order on $\alpha$. It is a duplicate-free list of length
$|F_S(\ell)|$ whose underlying set is $F_S(\ell)$.

**Definition 2.3 (Intra-bucket index, decoding cost).** The *intra-bucket index* of a
key $x$ is
$$i_S(x) = \text{the (0-based) position of } x \text{ in } L_S(b_S(x)),$$
and the *decoding cost* is $c_S(x) = i_S(x) + 1$, the $1$-based number of comparisons
a linear scan of $x$'s bucket performs before locating $x$.

**Definition 2.4 (Scan code; encoding and decoding).** The *scan code* of $x$ is the
pair
$$\mathrm{enc}_S(x) = \bigl(b_S(x),\, i_S(x)\bigr) \in \beta \times \mathbb{N},$$
and the partial decoding map
$\mathrm{dec}_S : \beta \times \mathbb{N} \to \alpha \cup \{\bot\}$
sends $(\ell, i)$ to the $i$-th entry of $L_S(\ell)$ if
$i < |F_S(\ell)|$ and to $\bot$ otherwise.

**Definition 2.5 (Total and mean cost).** The *total decoding cost* is
$C(S) = \sum_{x \in \alpha} c_S(x)$, and the *mean decoding cost* is $C(S)/N$. The
total cost is $N$ times the average lookup cost under the uniform distribution on
keys, and equals the cost of one complete pass in which every key is retrieved
exactly once.

Two design choices deserve comment. Using the canonical increasing order inside each
bucket is not a restriction: the total cost is unaffected by re-ordering a bucket,
since a scan of a bucket of size $k$ retrieves its $k$ keys at costs
$1, 2, \dots, k$ in some order regardless. And costing a lookup by comparisons
(rather than, say, cache lines) is the standard atomic model; all our statements
scale linearly under a change of unit.

---

## 3. Honesty of the model: unique decodability and exact accounting

A lower bound on lookup cost is only as meaningful as the guarantee that the
"addresses" being counted actually identify keys. We make this explicit.

**Theorem 3.1 (Honest decoding).** *For every scan scheme $S$ and every key $x$,*
$$\mathrm{dec}_S\bigl(\mathrm{enc}_S(x)\bigr) = x.$$

*Proof sketch.* By construction $x$ belongs to $F_S(b_S(x))$, hence occurs in the list
$L_S(b_S(x))$. For any list, the entry at the position of the first occurrence of an
element is that element; here $i_S(x)$ is precisely that position. $\square$

**Theorem 3.2 (Uniqueness of decoding).** *For every scan scheme $S$, every pair
$(\ell, i) \in \beta \times \mathbb{N}$ and every key $x$,*
$$\mathrm{dec}_S(\ell, i) = x \iff (\ell, i) = \mathrm{enc}_S(x).$$
*Consequently $\mathrm{enc}_S : \alpha \to \beta \times \mathbb{N}$ is injective: the
scan code is a uniquely decodable code for the keys.*

*Proof sketch.* ($\Leftarrow$) is Theorem 3.1. For ($\Rightarrow$), suppose
$\mathrm{dec}_S(\ell,i) = x$. Then $x$ occurs in $L_S(\ell)$, so $b_S(x) = \ell$; and
$i$ is a legal index with $L_S(\ell)[i] = x$. Since $L_S(\ell)$ is duplicate-free, the
position of an element is uniquely determined by the element, so $i = i_S(x)$; thus
$(\ell,i) = \mathrm{enc}_S(x)$. Injectivity follows: if
$\mathrm{enc}_S(x) = \mathrm{enc}_S(y)$ then applying $\mathrm{dec}_S$ gives $x = y$.
$\square$

**Corollary 3.3 (Index range).** *For every key $x$ we have
$i_S(x) < |F_S(b_S(x))|$, hence $1 \le c_S(x) \le |F_S(b_S(x))|$: the decoding cost of
a key lies between one and the size of its own bucket.*

Restricted to a single bucket, Theorem 3.2 says that $i_S$ is injective on
$F_S(\ell)$ — no two keys in a bucket share an index — which is the combinatorial
content of "the index is a genuine address".

The second pillar is the accounting identity. Its list-level core is:

**Lemma 3.4 (List cost).** *For every duplicate-free list $L$ of length $k$,*
$$\sum_{x \in L} \bigl(\mathrm{pos}_L(x) + 1\bigr) = T(k),$$
*where $\mathrm{pos}_L(x)$ is the position of $x$ in $L$.*

*Proof sketch.* Induction on $L$. For $L = a :: L'$ with $a \notin L'$: the head
contributes $1$, and every $x \in L'$ has $\mathrm{pos}_L(x) = \mathrm{pos}_{L'}(x)+1$,
so the tail contributes
$\sum_{x \in L'}(\mathrm{pos}_{L'}(x)+1) + |L'| = T(k-1) + (k-1)$.
Summing gives $T(k-1) + k = T(k)$ by the recursion $T(k) = T(k-1)+k$.
$\square$

**Theorem 3.5 (Exact cost accounting).** *For every scan scheme $S$,*
$$C(S) \;=\; \sum_{x \in \alpha} c_S(x) \;=\; \sum_{\ell \in \beta} T\bigl(|F_S(\ell)|\bigr).$$

*Proof sketch.* Partition the sum over keys along the fibres of $b_S$. The inner sum
over $F_S(\ell)$ is, by definition of $i_S$ and Lemma 3.4 applied to $L_S(\ell)$,
exactly $T(|L_S(\ell)|) = T(|F_S(\ell)|)$. $\square$

**Corollary 3.6 (Load conservation).** $\sum_{\ell \in \beta} |F_S(\ell)| = N$.

Theorem 3.5 is the decisive structural fact of the theory: the total cost depends on
$S$ only through the multiset of bucket sizes $\{|F_S(\ell)|\}_{\ell\in\beta}$, called
the *size profile* of $S$. Optimising over schemes is therefore optimising over
compositions of $N$ into $m$ non-negative parts.

---

## 4. The arithmetic core: an integral tangent line

**Lemma 4.1 (Integral tangent-line inequality).** *For all $k, q \in \mathbb{N}$,*
$$T(q) + (q+1)(k-q) \;\le\; T(k),$$
*computed over $\mathbb{Z}$, with*
$$T(k) - \bigl[T(q) + (q+1)(k-q)\bigr] \;=\; \frac{(k-q)(k-q-1)}{2} \;\ge\; 0 .$$

*Proof sketch.* Multiply by $2$ and use $2T(n) = n(n+1)$. The claim becomes
$k(k+1) - q(q+1) - 2(q+1)(k-q) \ge 0$, and expansion shows the left side equals
$(k-q)(k-q-1)$. Setting $d = k - q \in \mathbb{Z}$, the product $d(d-1)$ of two
consecutive integers is non-negative for every integer $d$. $\square$

Two features distinguish this from the real-analytic tangent line to
$t \mapsto t(t+1)/2$ at $t=q$, whose slope is $q + \tfrac12$. First, the slope
$q+1$ is an *integer*, which keeps the summed bound in $\mathbb{Z}$. Second, the
slack is $\binom{d}{2}$ with $d = k-q$, and

**Lemma 4.2 (Zero locus of the slack).** *For $d \in \mathbb{Z}$, $d(d-1) = 0$ if and
only if $d \in \{0, 1\}$.*

This double zero — not the single zero of a genuine tangency — is the source of the
rigidity theorem in §6: a bucket incurs no slack precisely when its size is $q$ or
$q+1$.

**Definition 4.3 (The optimum function).** For $m \ge 1$ set
$$\mathrm{Opt}(N,m) \;=\; r\,T(q+1) + (m-r)\,T(q), \qquad q = \lfloor N/m\rfloor,\ r = N \bmod m .$$
Equivalently, $\mathrm{Opt}(N,m) = m\,T(q) + r\,(q+1)$.

**Theorem 4.4 (Exact pigeonhole lower bound).** *Let $m \ge 1$ and let
$f : \{1,\dots,m\} \to \mathbb{N}$ satisfy $\sum_i f(i) = N$. Then*
$$\mathrm{Opt}(N,m) \;\le\; \sum_{i=1}^{m} T\bigl(f(i)\bigr).$$

*Proof sketch.* Apply Lemma 4.1 to each $f(i)$ with the fixed tangent point $q$ and
sum:
$$\sum_i T(f(i)) \;\ge\; \sum_i \Bigl[T(q) + (q+1)\bigl(f(i)-q\bigr)\Bigr]
 = m\,T(q) + (q+1)\Bigl(\sum_i f(i) - mq\Bigr) = m\,T(q) + (q+1)r,$$
using $\sum_i f(i) = N$ and $N - mq = r$. The right-hand side is $\mathrm{Opt}(N,m)$.
$\square$

The key point is that the *sum* of the tangent lower bounds is independent of $f$: the
linear term sees only the total $N$. This is what makes the bound sharp rather than
merely valid.

**Definition 4.5 (Balanced profile).** The *balanced profile* is
$$f^{\mathrm{bal}}(i) = q + [\,i \le r\,] \quad (1 \le i \le m),$$
i.e. $r$ buckets of size $q+1$ and $m-r$ of size $q$; it satisfies
$\sum_i f^{\mathrm{bal}}(i) = mq + r = N$.

**Theorem 4.6 (Attainment).** $\displaystyle \sum_{i=1}^m T\bigl(f^{\mathrm{bal}}(i)\bigr) = \mathrm{Opt}(N,m)$.

*Proof sketch.* The sum splits into $r$ terms equal to $T(q+1)$ and $m - r$ terms
equal to $T(q)$, which is the definition of $\mathrm{Opt}(N,m)$. $\square$

---

## 5. The exact optimum for scan schemes

**Theorem 5.1 (Universal lower bound).** *Every scan scheme $S$ on $N$ keys with
$m \ge 1$ bucket labels satisfies $C(S) \ge \mathrm{Opt}(N,m)$.*

*Proof sketch.* By Theorem 3.5, $C(S) = \sum_\ell T(|F_S(\ell)|)$; by Corollary 3.6 the
sizes sum to $N$; apply Theorem 4.4 after transporting the index set $\beta$ to
$\{1,\dots,m\}$ along any bijection. $\square$

**Definition (Residue scheme).** For key set $\{0,1,\dots,N-1\}$ and $m \ge 1$, the
*residue scheme* $R_{N,m}$ is the scan scheme with bucket map $x \mapsto x \bmod m$.

**Lemma 5.2 (Residue counts).** *For $m \ge 1$ and $0 \le j < m$, the number of
$x \in \{0,\dots,N-1\}$ with $x \equiv j \pmod m$ equals $q + [\,j < r\,]$.*

*Proof sketch.* Induct on $N$. Adding the key $N$ increments exactly the class
$j = N \bmod m$; the update matches the change in $q + [\,j<r\,]$ in both cases
(whether or not $N+1$ is a multiple of $m$). $\square$

Thus the size profile of $R_{N,m}$ is exactly the balanced profile, and combining with
Theorem 4.6:

**Theorem 5.3 (Residue scheme attains the optimum).** $C(R_{N,m}) = \mathrm{Opt}(N,m)$.

**Theorem 5.4 (Exact optimum).** *For $m \ge 1$, $\mathrm{Opt}(N,m)$ is the least
element of the set of achievable total costs*
$$\bigl\{\,C(S)\;:\;S \text{ a scan scheme on } N \text{ keys with } m \text{ buckets}\,\bigr\}.$$

*Proof.* Membership is Theorem 5.3; minimality is Theorem 5.1. $\square$

**Example 5.5.** $N=5$, $m=3$: $q=1$, $r=2$, so
$\mathrm{Opt} = 2T(2) + 1\cdot T(1) = 6+1 = 7$. Exhaustive enumeration of all
$3^5 = 243$ schemes returns minimum $7$, maximum $T(5) = 15$.

---

## 6. Rigidity, perfect hashing, and symmetry

**Theorem 6.1 (Rigidity of the optimum).** *Let $m \ge 1$ and $\sum_i f(i) = N$. Then*
$$\sum_{i=1}^m T\bigl(f(i)\bigr) = \mathrm{Opt}(N,m) \iff \forall i,\ q \le f(i) \le q+1 .$$
*Consequently a scan scheme $S$ satisfies $C(S) = \mathrm{Opt}(N,m)$ if and only if
every bucket has size $\lfloor N/m\rfloor$ or $\lceil N/m\rceil$.*

*Proof sketch.* ($\Rightarrow$) Write the difference between the two sides of Theorem
4.4 as $\sum_i \tfrac12 (f(i)-q)(f(i)-q-1)$, a sum of non-negative integers (Lemma
4.1). If the total is $0$, each term is $0$, and by Lemma 4.2 each $f(i) - q$ lies in
$\{0,1\}$. ($\Leftarrow$) If every $f(i) \in \{q, q+1\}$, then
$T(f(i)) = T(q) + (f(i)-q)(q+1)$ exactly, and $\sum_i (f(i)-q) = N - mq = r$, so the
sum telescopes to $m T(q) + r(q+1) = \mathrm{Opt}(N,m)$. The scheme statement follows
via Theorem 3.5. $\square$

Rigidity upgrades optimisation to classification: the optimal locus is exactly the set
of balanced schemes, no more and no less.

**Theorem 6.2 (Perfect hashing).** *For a scan scheme $S$, the following are
equivalent: (i) $c_S(x) = 1$ for every key $x$; (ii) the bucket map $b_S$ is
injective.*

*Proof sketch.* (i)$\Rightarrow$(ii): $c_S(x) = 1$ means $i_S(x) = 0$ for all $x$, so
$\mathrm{enc}_S(x) = (b_S(x), 0)$; injectivity of $\mathrm{enc}_S$ (Theorem 3.2) then
forces injectivity of $b_S$. (ii)$\Rightarrow$(i): if $b_S$ is injective, every fibre
containing $x$ equals $\{x\}$, so $|F_S(b_S(x))| = 1$ and Corollary 3.3 gives
$c_S(x) = 1$. $\square$

**Corollary 6.3 (No collision-free compression).** *If $m < N$ then some key has
$c_S(x) \ge 2$.* Indeed otherwise all costs are $1$, hence $b_S$ is injective by
Theorem 6.2, forcing $N \le m$.

**Theorem 6.4 (Pigeonhole failure analysis).** *If $N \ge 1$ and $\beta$ is nonempty,
then some key $x$ satisfies $N \le m \cdot c_S(x)$; i.e. some key costs at least the
average bucket load $N/m$.*

*Proof sketch.* Some bucket $\ell$ has $N \le m\,|F_S(\ell)|$ (else summing
$m|F_S(\ell)| \le N-1$ over $\ell$ contradicts Corollary 3.6). That bucket is
nonempty, and its last-scanned key has cost exactly $|F_S(\ell)|$ (its index is
$|F_S(\ell)|-1$, by duplicate-freeness of the scan list). $\square$

**Theorem 6.5 (Symmetry invariance).** *For any permutation $\sigma$ of the keys, the
scheme with bucket map $b_S \circ \sigma$ has the same total cost as $S$; and for any
bijection $e : \beta \to \beta'$, the scheme with bucket map $e \circ b_S$ has the same
total cost as $S$.*

*Proof sketch.* By Theorem 3.5 the cost is a function of the size profile alone. Pre-
composition with $\sigma$ replaces each fibre by its $\sigma$-preimage, a set of the
same cardinality; post-composition with $e$ permutes the fibres. $\square$

Thus $C$ is a class function for the natural action of
$\mathrm{Sym}(\alpha) \times \mathrm{Sym}(\beta)$ on schemes, and the optimal locus of
Theorem 6.1 is a union of orbits — in fact a single orbit, since any two balanced
profiles differ by a permutation of buckets and any two schemes with the same profile
differ by a permutation of keys.

**Remark 6.6 (Counting the optimal locus).** Orbit–stabiliser then predicts the number
of cost-optimal maps $\{1,\dots,N\}\to\{1,\dots,m\}$ to be
$$\binom{m}{r} \cdot \frac{N!}{\bigl((q+1)!\bigr)^{r} (q!)^{m-r}},$$
choosing which $r$ buckets are overloaded and then distributing the keys. For
$(N,m)=(5,3)$ this gives $3 \cdot 30 = 90$, matching exhaustive enumeration; for
$(N,m)=(7,4)$ it gives $2520$, again matching. We record this as a conjecture in §10.

---

## 7. The ceiling and the achievable set

**Lemma 7.1 (Superadditivity).** *For all $a,b \in \mathbb{N}$,
$T(a) + T(b) \le T(a+b)$, with slack $ab$.*

*Proof sketch.* $2T(a+b) - 2T(a) - 2T(b) = (a+b)(a+b+1) - a(a+1) - b(b+1) = 2ab \ge 0$.
$\square$

By induction, $\sum_i T(f(i)) \le T(\sum_i f(i))$ for any finite family — merging
buckets never decreases cost.

**Theorem 7.2 (Universal upper bound and exact maximum).** *Every scan scheme on $N$
keys satisfies $C(S) \le T(N)$; and the degenerate scheme placing every key in a
single bucket achieves $C = T(N)$. Hence $T(N)$ is the greatest achievable total
cost.*

*Proof sketch.* The bound is Lemma 7.1 plus Corollary 3.6 plus Theorem 3.5. For
attainment, the one-bucket scheme has a single nonempty fibre of size $N$, so its cost
is $T(N)$ by Theorem 3.5. $\square$

**Theorem 7.3 (Cost window).** *For $m \ge 1$, every scan scheme on $N$ keys with $m$
buckets satisfies*
$$\mathrm{Opt}(N,m) \;\le\; C(S) \;\le\; T(N),$$
*and both endpoints are attained (by the residue scheme and by the one-bucket scheme
respectively).*

The window is tight at its endpoints, but its interior is *not* full.

**Proposition 7.4 (Exact achievable set).** *The set of achievable total costs of scan
schemes on $N$ keys with $m$ buckets is exactly*
$$\Bigl\{\textstyle\sum_{i} T(k_i)\ :\ (k_i) \text{ a partition of } N \text{ into at most } m \text{ parts}\Bigr\}.$$

*Proof sketch.* By Theorem 3.5 the cost depends only on the size profile, and by
Theorem 6.5 the profile can be taken up to reordering, i.e. as a partition of $N$ into
at most $m$ parts. Conversely, every such partition is realised by some bucket map.
$\square$

**Example 7.5 (The window is porous).** For $(N,m)=(5,3)$ the partitions of $5$ into
at most $3$ parts are $2{+}2{+}1$, $3{+}1{+}1$, $3{+}2$, $4{+}1$, $5$, with costs
$7, 8, 9, 11, 15$ respectively. Exhaustive enumeration over all $243$ schemes returns
exactly $\{7,8,9,11,15\}$: the values $10, 12, 13, 14$ inside the window $[7,15]$ are
*not* achievable. For $(N,m)=(6,3)$ the achievable set is $\{9,10,12,13,16,21\}$, and
for $(N,m)=(7,3)$ it is $\{12,13,14,16,17,18,22,28\}$. Hence any claim that the cost
spectrum is a gapless integer interval is false; the correct statement is Proposition
7.4.

---

## 8. The mean cost and the $\varepsilon$-compression barrier

We now convert the exact optimum into a space–time trade-off. The floor
$\mathrm{Opt}(N,m)$ involves $\lfloor N/m\rfloor$; the following division-free
inequality removes the floor.

**Theorem 8.1 (Division-free averaged optimum).** *For $m \ge 1$ and $N \ge 0$,*
$$N\,(N + m) \;\le\; 2m\,\mathrm{Opt}(N,m).$$

*Proof sketch.* Write $N = mq + r$ with $0 \le r < m$. Using
$\mathrm{Opt}(N,m) = m\,T(q) + r(q+1)$ and $2T(q) = q(q+1)$,
$$2m\,\mathrm{Opt}(N,m) = m^2 q(q+1) + 2mr(q+1) = m(q+1)\bigl(mq + 2r\bigr),$$
while $N(N+m) = (mq+r)(mq+r+m)$. Expanding both and subtracting, all terms of degree
two in $q$ cancel and one is left with
$$2m\,\mathrm{Opt}(N,m) - N(N+m) \;=\; 2mr - r^2 - mr \;=\; r\,(m-r) \;\ge\; 0 . \qquad \square$$

*(The defect is exactly $r(m-r)$, which vanishes precisely when $r = 0$, i.e. when
$m \mid N$ — the source of the sharpness in Theorem 8.4. For $N=5$, $m=3$:
$2m\,\mathrm{Opt} = 42$, $N(N+m) = 40$, defect $2 = 2\cdot 1$.)*

**Theorem 8.2 (Mean-cost lower bound).** *For $N \ge 1$, $m \ge 1$ and any scan scheme
$S$,*
$$\frac{C(S)}{N} \;\ge\; \frac{1}{2}\left(\frac{N}{m} + 1\right),$$
*with real division.*

*Proof sketch.* Theorem 5.1 gives $C(S) \ge \mathrm{Opt}(N,m)$, and Theorem 8.1 gives
$2m\,\mathrm{Opt}(N,m) \ge N(N+m)$. Hence $2mN \cdot C(S)/N = 2m\,C(S) \ge N(N+m)$,
i.e. $C(S)/N \ge (N+m)/(2m) = \tfrac12(N/m + 1)$. $\square$

**Theorem 8.3 ($\varepsilon$-compression barrier).** *Let $\varepsilon > 0$ and suppose
the scheme's bucket count satisfies $m \le \varepsilon N$. Then*
$$\frac{C(S)}{N} \;\ge\; \frac{1}{2\varepsilon}.$$

*Proof sketch.* From $m \le \varepsilon N$ we get $N/m \ge 1/\varepsilon$, so
Theorem 8.2 yields $C(S)/N \ge \tfrac12(1/\varepsilon + 1) \ge 1/(2\varepsilon)$.
$\square$

**Theorem 8.4 (Sharpness).** *If $m \mid N$ and $m \ge 1$, the residue scheme satisfies*
$$2m\,C(R_{N,m}) = N(N+m),$$
*i.e. it meets the bound of Theorem 8.2 with equality, so the constant $1/2$ in
Theorem 8.3 cannot be improved.*

*Proof sketch.* If $N = mq$ then $r = 0$ and $\mathrm{Opt}(N,m) = m\,T(q)$; hence
$2m\,C(R_{N,m}) = 2m^2 T(q) = m^2 q(q+1) = (mq)(mq + m) = N(N+m)$. $\square$

**Interpretation.** Space and time multiply. Using an $\varepsilon$ fraction as many
buckets as keys forces an average of at least $1/(2\varepsilon)$ comparisons per
lookup; equivalently, the product (space fraction) $\times$ (mean lookup cost) is at
least $1/2$, uniformly over all schemes, all key sets and all orderings. With
$N = 4096$ and $m = 256$ ($\varepsilon = 1/16$) the barrier gives $8$, the exact bound
gives $8.5$, and the residue scheme achieves exactly $8.5$.

---

## 9. Algorithms

Three procedures underlie the numerical companion to this paper.

**Algorithm A (Exact optimum).** Given $N, m \ge 1$, compute $q = \lfloor N/m\rfloor$,
$r = N \bmod m$, and return $r\,T(q+1) + (m-r)\,T(q)$. Cost: $O(1)$ arithmetic
operations. Correctness: Theorem 5.4.

**Algorithm B (Optimality test by rigidity).** Given a bucket map on $N$ keys with $m$
buckets, compute the size profile in $O(N + m)$ time and accept iff every size lies in
$\{\lfloor N/m\rfloor, \lceil N/m\rceil\}$. This decides cost-optimality without
computing the cost, and correctness is exactly Theorem 6.1. The naive alternative —
compute $C(S)$ and compare with $\mathrm{Opt}$ — is also $O(N+m)$ via Theorem 3.5, but
the rigidity test additionally *localises* the failure: it names an offending bucket.

**Algorithm C (Achievable-cost enumeration).** Enumerate the partitions of $N$ into at
most $m$ parts and record $\sum_i T(k_i)$ for each. By Proposition 7.4 this produces
the exact achievable cost set, at cost proportional to the number of such partitions —
vastly cheaper than the $m^N$ brute-force enumeration over schemes, which is only
feasible for the smallest cases used here as an independent cross-check.

---

## 10. Discussion, applications and future work

### 10.1 What is gained by exactness

The classical treatment of bucketed lookup replaces the bucket map with a random
function and reports expectations. That is the right tool for predicting the behaviour
of a *typical* hash function, but it cannot answer adversarial or design questions:
what is the best a scheme could possibly do, which schemes achieve it, how many are
there, and what does compression cost in the worst case? Every result above is
deterministic and exact, and answers one of those questions. In particular the
compression barrier is not an average-case heuristic: it holds for every scheme, every
key set and every scan order.

### 10.2 Applications

*Cache and index sizing.* Theorem 8.3 gives an immediate design rule: if a lookup
budget of $c$ comparisons on average is required, then at least $N/(2c)$ buckets must
be provisioned, no matter how clever the bucket assignment. Conversely, Theorem 8.4
says the naive residue assignment already meets that budget when it divides evenly, so
sophistication buys nothing at the level of total cost.

*Load-balancing certificates.* Algorithm B turns "is my hash table optimally
balanced?" into an $O(N+m)$ certificate check with a precise failure witness, rather
than a statistical goodness-of-fit test.

*Code design.* Theorem 3.2 identifies (bucket, index) as a uniquely decodable code of
size $m \cdot \lceil N/m\rceil$ symbols; the cost model counts, exactly, the decoding
work of the induced sequential decoder. This is the deterministic analogue of the
familiar coding-theoretic trade-off between codeword length and decoding effort.

### 10.3 Future directions

**Conjecture 1 (Enumerative rigidity).** The number of cost-optimal bucket maps
$\{1,\dots,N\}\to\{1,\dots,m\}$ is exactly
$$\binom{m}{r}\cdot\frac{N!}{\bigl((q+1)!\bigr)^{r}(q!)^{m-r}},\qquad q=\lfloor N/m\rfloor,\ r=N\bmod m.$$
The ingredients are in place: Theorem 6.1 identifies the optimal locus with the
balanced profiles, and Theorem 6.5 shows the symmetry group acts, so the count should
follow from orbit–stabiliser. Confirmed by exhaustive enumeration for $(N,m)=(5,3)$
($3 \cdot 30 = 90$), $(6,3)$ ($90$) and $(7,4)$ ($2520$).

**Problem 2 (Structure of the achievable set).** Proposition 7.4 identifies the
achievable costs with sums of triangular numbers over partitions of $N$ into at most
$m$ parts, and Example 7.5 shows this set has gaps: for $(N,m)=(5,3)$ it is
$\{7,8,9,11,15\}$, not the interval $[7,15]$. The natural refinement is to determine
the gap structure exactly. A single move — transferring one key from a bucket of size
$a$ to a bucket of size $b$ — changes the cost by exactly $b + 1 - a$, so the
achievable set is the orbit of the balanced profile under these unit moves; the
question is which integers in the window arise. A plausible precise statement: the
achievable set is *gapless in an initial segment* $[\mathrm{Opt}(N,m),\,B(N,m)]$ for an
explicit threshold $B(N,m)$, and sparse above it.

**Conjecture 3 (Two-level schemes and the barrier).** Iterating the construction — a
bucket map into $m_1$ buckets followed by a second bucket map into $m_2$ sub-buckets
inside each — cannot beat the one-level barrier at equal total space: for every
two-level scheme with $m_1 m_2 \le \varepsilon N$ sub-buckets, the mean decoding cost
is at least $1/(2\varepsilon)$. The reason to expect this is that Theorem 3.5 applies
verbatim at each level: the cost of the refined structure is again a sum of triangular
numbers over the finest fibres, whose count is bounded by $m_1 m_2$. Establishing it
would show hierarchy does not evade the space–time product.

**Problem 4 (Weighted keys).** Replace the uniform access distribution by weights
$w(x) \ge 0$ and minimise $\sum_x w(x) c_S(x)$. Within a bucket, the optimal scan order
is by decreasing weight (an exchange argument), so the problem becomes a weighted
partition problem; the convexity mechanism above should be replaced by a majorisation
argument, and it is unclear whether an exact closed-form optimum survives.

**Problem 5 (Beyond linear scan).** Replace the intra-bucket linear scan by binary
search, giving per-key cost $\lceil \log_2(\text{position}+1)\rceil$ or similar. The
bucket cost function becomes $\sum_{j<k}(1+\lfloor \log_2 j\rfloor)$, still convex but
no longer polynomial; the tangent-line method should still yield an exact optimum with
a modified balanced profile, and the corresponding barrier would degrade from
$1/(2\varepsilon)$ to $\Theta(\log(1/\varepsilon))$.

---

## 11. Conclusion

Bucketed lookup, analysed exactly rather than asymptotically, is a small and complete
theory. An honest cost model — one in which the pair (bucket label, intra-bucket index)
is proved to be a uniquely decodable address — reduces, by an exact accounting
identity, to the minimisation of $\sum_i T(k_i)$ over compositions of $N$ into $m$
parts. A single integral tangent line with slope $\lfloor N/m\rfloor + 1$ then
delivers the exact optimum
$r\,T(q+1) + (m-r)\,T(q)$; the double zero of its slack delivers rigidity; the
resulting symmetry orbit delivers a counting formula; superadditivity delivers the
ceiling $T(N)$; and averaging delivers the space–time barrier
$1/(2\varepsilon)$ with the sharp constant $1/2$. The remaining open questions —
counting the optimal locus, describing the gaps in the achievable set, and extending
the barrier to hierarchical schemes — are all reachable from the same two facts:
costs are triangular, and triangles are convex.
