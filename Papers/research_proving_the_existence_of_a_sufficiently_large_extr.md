# A Fixed-Point Bridge for Intersecting Families of Permutations and a Large Extremal $t$-Intersecting Family

## Abstract

We develop the elementary combinatorial infrastructure behind the theory of intersecting families of permutations — the permutation analogue of the Erdős–Ko–Rado and Complete Intersection theorems of extremal set theory. Two permutations of an $n$-element set *agree* at a position when they send it to the same value; a family of permutations is *intersecting* if every pair agrees somewhere, and $t$-*intersecting* if every pair agrees in at least $t$ positions. Our central structural observation is the **fixed-point bridge**: the set of positions on which two permutations $\sigma$ and $\tau$ agree is exactly the set of fixed points of the quotient permutation $\sigma^{-1}\tau$. Consequently a family is intersecting if and only if none of its pairwise quotients is a derangement, and the number of agreements between $\sigma$ and $\tau$ equals $n$ minus the size of the support of $\sigma^{-1}\tau$. Using this reformulation we give a fully constructive proof of the lower-bound half of the permutation Complete Intersection Theorem: for every $t$ and $m$, the *prefix stabilizer* — the family of all permutations of $t+m$ points fixing each of the first $t$ points — is $t$-intersecting and has exactly $m! = (n-t)!$ members. The count is obtained by identifying the prefix stabilizer with the group of permutations preserving a coloring whose classes are $t$ singletons and one block of size $m$, whose cardinality is the product of the factorials of the class sizes. We discuss algorithms, numerical illustrations, and directions toward the matching upper bound and its variants.

**Keywords:** intersecting family, permutation, derangement, fixed point, Deza–Frankl theorem, Complete Intersection Theorem, extremal combinatorics, symmetric group, prefix stabilizer.

## 1. Introduction

Extremal set theory begins with a deceptively simple question: how large can a family of $k$-element subsets of an $n$-set be if every two of them intersect? The Erdős–Ko–Rado theorem answers it, and the Complete Intersection Theorem of Ahlswede and Khachatrian gives the sharp answer to the $t$-wise variant, in which every two sets must share at least $t$ elements. Replacing subsets with permutations produces an equally natural and, in several respects, richer theory. Here the objects are the bijections of a finite set, two of them "intersect" when they agree in a coordinate, and the extremal question — first studied by Deza and Frankl in 1977 and sharpened by Kupavskii and collaborators — asks for the largest family in which every pair agrees.

The purpose of this paper is twofold. First, we isolate and prove a small structural principle, the *fixed-point bridge*, that converts every statement about coordinate-agreement of permutations into a statement about the fixed points (equivalently, the support) of a single derived permutation. This dissolves the set-system bookkeeping that clutters the classical formulations. Second, we use it to give a clean, constructive proof of the lower-bound half of the permutation Complete Intersection Theorem: a $t$-intersecting family of permutations of $n = t+m$ points of size exactly $(n-t)! = m!$ exists, realized by the prefix stabilizer.

Throughout, we work with permutations of the set $\{0, 1, \dots, n-1\}$, written $\operatorname{Sym}(n)$, and we adopt the convention that products act on the right: $(\sigma\tau)(i) = \tau(\sigma(i))$ is not assumed; we use standard function composition $(\sigma\tau)(i) = \sigma(\tau(i))$. The choice of convention is immaterial to the results, which we phrase in a form invariant under it.

## 2. Definitions

Let $n$ be a nonnegative integer and let $\operatorname{Sym}(n)$ denote the group of all permutations (bijections) of $\{0, 1, \dots, n-1\}$.

**Definition 2.1 (Agreement set).** For permutations $\sigma, \tau \in \operatorname{Sym}(n)$, the *agreement set* is
$$\operatorname{Agr}(\sigma, \tau) = \{\, i \in \{0,\dots,n-1\} : \sigma(i) = \tau(i) \,\}.$$
Its cardinality $|\operatorname{Agr}(\sigma,\tau)|$ is the number of positions at which $\sigma$ and $\tau$ agree.

**Definition 2.2 (Support and derangement).** The *support* of a permutation $\pi$ is $\operatorname{supp}(\pi) = \{\, i : \pi(i) \neq i \,\}$, the set of points it moves. A permutation is a *derangement* if $\operatorname{supp}(\pi) = \{0,\dots,n-1\}$, i.e. it has no fixed point.

**Definition 2.3 (Intersecting and $t$-intersecting families).** A family $F \subseteq \operatorname{Sym}(n)$ is *intersecting* if $\operatorname{Agr}(\sigma,\tau) \neq \varnothing$ for all $\sigma, \tau \in F$. For an integer $t \geq 0$, it is $t$-*intersecting* if $|\operatorname{Agr}(\sigma,\tau)| \geq t$ for all $\sigma, \tau \in F$. (Thus "intersecting" is "$1$-intersecting".)

We emphasize that the intersecting condition is imposed on *all* ordered pairs, including $\sigma = \tau$; the diagonal case is automatic since $\operatorname{Agr}(\sigma,\sigma) = \{0,\dots,n-1\}$.

**Definition 2.4 (Prefix stabilizer).** For $t, m \geq 0$ and $n = t+m$, the *prefix stabilizer* $\operatorname{Fix}_t \subseteq \operatorname{Sym}(n)$ is the set of all permutations fixing each of the first $t$ points:
$$\operatorname{Fix}_t = \{\, \sigma \in \operatorname{Sym}(t+m) : \sigma(i) = i \text{ for all } i < t \,\}.$$

## 3. The fixed-point bridge

The following pointwise identity is the technical heart of the paper.

**Lemma 3.1 (Fixed-point bridge, pointwise).** For all $\sigma, \tau \in \operatorname{Sym}(n)$ and every position $i$,
$$\sigma(i) = \tau(i) \quad\Longleftrightarrow\quad (\sigma^{-1}\tau)(i) = i.$$

*Proof.* If $\sigma(i) = \tau(i)$, apply $\sigma^{-1}$ to both sides: $i = \sigma^{-1}(\sigma(i)) = \sigma^{-1}(\tau(i)) = (\sigma^{-1}\tau)(i)$. Conversely, if $(\sigma^{-1}\tau)(i) = i$, apply $\sigma$: $\sigma(i) = \sigma((\sigma^{-1}\tau)(i)) = \tau(i)$. $\qquad\blacksquare$

Lifting the pointwise equivalence to sets and then to cardinalities is immediate.

**Theorem 3.2 (Fixed-point bridge, as sets).** For all $\sigma, \tau \in \operatorname{Sym}(n)$,
$$\operatorname{Agr}(\sigma,\tau) = \{\, i : (\sigma^{-1}\tau)(i) = i \,\} = \operatorname{Fix}(\sigma^{-1}\tau),$$
the fixed-point set of the quotient $\sigma^{-1}\tau$.

*Proof.* An element belongs to $\operatorname{Agr}(\sigma,\tau)$ iff $\sigma(i) = \tau(i)$, which by Lemma 3.1 holds iff $(\sigma^{-1}\tau)(i) = i$, i.e. iff $i$ is a fixed point of $\sigma^{-1}\tau$. $\qquad\blacksquare$

**Corollary 3.3 (Agreement count).** For all $\sigma, \tau \in \operatorname{Sym}(n)$,
$$|\operatorname{Agr}(\sigma,\tau)| = n - \big|\operatorname{supp}(\sigma^{-1}\tau)\big|.$$

*Proof.* The fixed-point set of any $\pi \in \operatorname{Sym}(n)$ is the complement of its support in $\{0,\dots,n-1\}$, so $|\operatorname{Fix}(\pi)| = n - |\operatorname{supp}(\pi)|$. Apply this to $\pi = \sigma^{-1}\tau$ and use Theorem 3.2. $\qquad\blacksquare$

The reformulation of the intersecting property is now purely group-theoretic.

**Theorem 3.4 (Intersecting $\Leftrightarrow$ no derangement quotient).** A family $F \subseteq \operatorname{Sym}(n)$ is intersecting if and only if for every $\sigma, \tau \in F$ the quotient $\sigma^{-1}\tau$ has a fixed point; equivalently, if and only if no pairwise quotient is a derangement.

*Proof.* $F$ is intersecting iff for all $\sigma,\tau \in F$ we have $\operatorname{Agr}(\sigma,\tau) \neq \varnothing$. By Theorem 3.2 this is equivalent to $\operatorname{Fix}(\sigma^{-1}\tau) \neq \varnothing$, i.e. to the existence of a fixed point of $\sigma^{-1}\tau$, i.e. to $\sigma^{-1}\tau$ not being a derangement. $\qquad\blacksquare$

More generally, combining Corollary 3.3 with the definitions gives a uniform restatement of $t$-intersection: $F$ is $t$-intersecting iff $|\operatorname{supp}(\sigma^{-1}\tau)| \leq n - t$ for every pair — the pairwise quotients must all have "small" support.

**Remark 3.5 (Robustness and non-vacuity).** The bridge requires no size, uniformity, or nonemptiness hypotheses on $F$, and remains meaningful when $n = 0$, where $\operatorname{Sym}(0)$ is trivial and every statement holds vacuously-but-correctly. The intersecting property is phrased through nonemptiness of a concrete finite set rather than a bare existential, so it does not degenerate.

## 4. A large extremal $t$-intersecting family

We now construct and analyze the extremal witness. Fix $t, m \geq 0$ and write $n = t + m$.

### 4.1 The prefix stabilizer is $t$-intersecting

**Proposition 4.1.** The prefix stabilizer $\operatorname{Fix}_t$ is $t$-intersecting.

*Proof.* Let $\sigma, \tau \in \operatorname{Fix}_t$. For every $i < t$ we have $\sigma(i) = i$ and $\tau(i) = i$, hence $\sigma(i) = \tau(i)$, so each of the $t$ positions $0, 1, \dots, t-1$ lies in $\operatorname{Agr}(\sigma,\tau)$. Therefore $|\operatorname{Agr}(\sigma,\tau)| \geq t$. $\qquad\blacksquare$

Equivalently, through the fixed-point bridge, if $\sigma, \tau \in \operatorname{Fix}_t$ then $\sigma^{-1}\tau$ fixes each point below $t$, so its support is contained in the last $m$ points and $|\operatorname{Agr}(\sigma,\tau)| = n - |\operatorname{supp}(\sigma^{-1}\tau)| \geq n - m = t$.

### 4.2 Counting the prefix stabilizer

The size computation is where the fixed-point viewpoint pays a structural dividend: fixing a prefix is the same as *preserving a coloring*.

**Definition 4.2 (Collapse map).** Define $c : \{0,\dots,t+m-1\} \to \{0,\dots,t\}$ by
$$c(i) = \begin{cases} i, & i < t, \\ t, & i \geq t. \end{cases}$$
Thus $c$ assigns to each of the first $t$ points its own distinct color $0,1,\dots,t-1$, and paints all of the remaining $m$ points with the single shared color $t$.

**Lemma 4.3 (Prefix stabilizer = coloring stabilizer).** A permutation $\sigma \in \operatorname{Sym}(t+m)$ fixes each of the first $t$ points if and only if it preserves the coloring $c$, i.e. $c(\sigma(i)) = c(i)$ for all $i$.

*Proof.* ($\Rightarrow$) Suppose $\sigma(i) = i$ for all $i < t$. For $i < t$, $c(\sigma(i)) = c(i)$ trivially. For $i \geq t$, note $\sigma(i) \geq t$: otherwise $\sigma(i) = j$ for some $j < t$, but $\sigma(j) = j$ already and $\sigma$ is injective, forcing $i = j < t$, a contradiction. Hence $c(\sigma(i)) = t = c(i)$.

($\Leftarrow$) Suppose $\sigma$ preserves $c$. For $i < t$, $c(\sigma(i)) = c(i) = i$. Since the color $i < t$ is attained by the unique point $i$, this forces $\sigma(i) = i$. $\qquad\blacksquare$

**Theorem 4.4 (Cardinality of the prefix stabilizer).** $|\operatorname{Fix}_t| = m! = (n-t)!$.

*Proof.* By Lemma 4.3, $\operatorname{Fix}_t$ is exactly the stabilizer of the coloring $c$ under the action of $\operatorname{Sym}(t+m)$ by post-composition. A permutation preserves $c$ if and only if it permutes each color class among itself; hence the stabilizer is the direct product of the symmetric groups on the color classes, and its cardinality is the product of the factorials of the class sizes. The classes of $c$ are the $t$ singletons $\{0\}, \dots, \{t-1\}$ and the single block $\{t, \dots, t+m-1\}$ of size $m$. Therefore
$$|\operatorname{Fix}_t| = \Big(\prod_{k=0}^{t-1} 1!\Big)\cdot m! = m! = (n-t)!. \qquad\blacksquare$$

Combining Proposition 4.1 and Theorem 4.4 yields the main existence result.

**Theorem 4.5 (Large extremal $t$-intersecting family).** For every $t \geq 0$ and $m \geq 0$, on the ground set of $n = t+m$ points there exists a $t$-intersecting family of permutations of size exactly $(n-t)! = m!$, namely the prefix stabilizer $\operatorname{Fix}_t$.

**Corollary 4.6 (Deza–Frankl lower bound, $t=1$).** For every $m \geq 0$ and $n = 1 + m$, there exists an intersecting family of permutations of $\operatorname{Sym}(n)$ of size $m! = (n-1)!$.

*Proof.* Apply Theorem 4.5 with $t = 1$. $\qquad\blacksquare$

**Remark 4.7 (Edge cases).** The argument is uniform in $t$ and $m$. When $m = 0$, the family collapses to $\{\operatorname{id}\}$, of size $0! = 1$. When $t = 0$, the coloring $c$ is constant, its stabilizer is all of $\operatorname{Sym}(m)$, and the count is $(t+m)! = m!$, i.e. every permutation qualifies (the $t=0$ condition is vacuous). No case analysis is needed; a single proof covers all $t, m$.

## 5. Algorithms

The constructive nature of Theorem 4.5 makes every quantity in the theory directly computable.

**Algorithm A (Agreement count via the quotient).** Given two permutations $\sigma, \tau$ as arrays, compute $|\operatorname{Agr}(\sigma,\tau)|$ either by a direct coordinate comparison or, following Corollary 3.3, by forming the quotient $\sigma^{-1}\tau$ and counting its fixed points. Both run in $O(n)$ time; agreement of the two methods is a computational manifestation of the fixed-point bridge.

**Algorithm B (Intersecting test).** Given a family $F$, decide whether it is $t$-intersecting by checking $|\operatorname{Agr}(\sigma,\tau)| \geq t$ for all ordered pairs. This is $O(|F|^2 n)$; the bridge lets each pairwise check be done as a support computation on a single quotient permutation.

**Algorithm C (Prefix-stabilizer enumeration).** Enumerate $\operatorname{Fix}_t$ by generating all $m!$ permutations of the last $m$ points and extending each by the identity on the first $t$ points. This produces exactly $(n-t)!$ permutations, each certified $t$-intersecting with all others by Proposition 4.1.

## 6. Numerical illustrations

Small cases confirm the pattern $|\operatorname{Fix}_t| = (n-t)!$ and the bridge identity.

- $t=1$, $n=3$: the permutations of $\{0,1,2\}$ fixing $0$ are the identity and the transposition $(1\;2)$, giving $2 = 2!$ members, all pairwise agreeing at position $0$.
- $t=2$, $n=4$: the permutations fixing $0$ and $1$ are the identity and $(2\;3)$, giving $2 = 2!$ members.
- $t=3$, $n=3$: only the identity remains, giving $1 = 0!$.
- Bridge check on $\operatorname{Sym}(3)$: for $\sigma = (0\;1\;2)$ and $\tau = (0\;2\;1)$ the quotient $\sigma^{-1}\tau$ is a derangement, and indeed $\sigma, \tau$ disagree everywhere; for $\sigma = \operatorname{id}$ the agreements with any $\tau$ are exactly the fixed points of $\tau$.

## 7. Applications

The theory of intersecting permutations is the permutation face of the Erdős–Ko–Rado and Complete Intersection theorems and inherits their reach. Constraining how often two arrangements may agree is precisely the setting of **permutation codes**, where a large minimum number of disagreements corresponds to large minimum Hamming distance — a model used for flash memory and powerline communication. Scheduling and seating problems, in which one seeks many arrangements that never fully conflict (or always partly coincide), wear the same combinatorial uniform. Finally, the fixed-point bridge connects the extremal theory to the classical study of **derangements** and to the representation theory of the symmetric group, which supplies the spectral tools used in the sharpest upper-bound arguments.

## 8. Discussion

The value of the fixed-point bridge is compression. The intersecting condition, phrased naively, is a quantifier over all pairs and all coordinates. The bridge replaces the inner coordinate quantifier with a single structural predicate — "the quotient has a fixed point" — turning an extremal set-system problem into a question about the distribution of fixed points, equivalently support sizes, across pairwise quotients. The extremal construction likewise compresses to a single act: fix a prefix and let the remainder run free; the count then follows from the elementary fact that the permutations preserving a partition number the product of the factorials of the block sizes.

Two features are worth stressing. First, the development is entirely uniform: no separate treatment is needed for the degenerate parameters $m=0$ or $t=0$. Second, it is constructive: the extremal family is exhibited explicitly, so Theorem 4.5 provides not merely an existence proof but an algorithm.

## 9. Future directions

**The matching upper bound and uniqueness.** We have shown that fixing $t$ coordinates yields a $t$-intersecting family of size $(n-t)!$. The conjecture is that, once $n$ is large relative to $t$, no $t$-intersecting family can be larger, and the prefix stabilizer is the *unique* extremal family up to relabelling of points and values. Since coordinate-agreement equals the number of fixed points of the quotient $\sigma^{-1}\tau$, a $t$-intersecting family is precisely a set of permutations whose pairwise quotients each fix at least $t$ points; extremality should be forced by how few large-fixed-point elements the symmetric group contains. With the lower bound pinned down and the set-system bookkeeping removed, the remaining work is a clean spectral/counting estimate rather than an ad hoc search.

**A derangement-weighted density threshold.** Replace the all-or-nothing intersection condition with a weighted one: assign to each pair the number of positions on which they disagree, and seek the largest family whose *average* pairwise disagreement stays below a threshold $\theta\cdot n$. Because average disagreement is the average support size of $\sigma^{-1}\tau$ over the family — a single group-theoretic statistic — the problem becomes an optimization over probability distributions on the symmetric group whose typical element has small support, opening a variational treatment unavailable to the classical formulation.

**Cross-intersecting pairs.** Study two families $A$ and $B$ such that every permutation in $A$ agrees in at least $t$ positions with every permutation in $B$, seeking to maximize $|A|\cdot|B|$. Conjecture: for large $n$ the optimum is $((n-t)!)^2$, attained by taking $A = B$ a common prefix stabilizer. Cross-agreement is controlled by the fixed-point counts of the quotients $\sigma^{-1}\tau$ with $\sigma \in A$, $\tau \in B$, so the product bound reduces to a bipartite version of the single-family derangement estimate.

**Fixed-point spectra and forbidden intersection sizes.** Characterize which sets of agreement-counts can occur among the pairwise quotients of a family — the *fixed-point spectrum* — and study families that forbid a prescribed intersection size, the permutation analogue of forbidden-intersection problems for sets.

## 10. Conclusion

We have reduced the coordinate-agreement structure of permutations to the fixed points of a single derived permutation, and used this fixed-point bridge to give a uniform, constructive proof that the prefix stabilizer is a $t$-intersecting family of exactly $(n-t)!$ permutations — the lower-bound half of the permutation Complete Intersection Theorem, with the classical Deza–Frankl $(n-1)!$ bound as the case $t=1$. The reformulation clears the path toward the matching upper bound and its weighted, cross-intersecting, and spectral relatives.
