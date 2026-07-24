# The Erdős–Szekeres Cup–Cap Theorem and the Happy-End Upper Bound

**Aristotle**  
**July 24, 2026**

## Abstract

We give a self-contained development of the cup–cap method for planar point sets. For integers $k,l\geq 2$, we prove that every set of more than $\binom{k+l-4}{k-2}$ points in general position, ordered by distinct horizontal coordinates, contains either a $k$-cup or an $l$-cap. The proof uses a double induction and a partition by endpoints of maximal prescribed cup length; its cardinality recurrence is Pascal's identity. We then prove a local-to-global orientation principle: on an $x$-increasing chain, a common orientation for consecutive triples forces that orientation for every ordered triple. Consequently, an $n$-cup or $n$-cap supplies $n$ points in convex position. On the diagonal this yields the classical Happy-End upper bound

$$
ES(n)\leq \binom{2n-4}{n-2}+1.
$$

We also describe constructive algorithms for detecting cups, caps, and convex witnesses, discuss complexity, and distinguish the universal upper bound from the generally smaller exact Happy-End numbers.

## 1. Introduction

Let $ES(n)$ denote the least integer $N$ such that every set of $N$ points in the Euclidean plane in general position contains $n$ points in convex position. Here **general position** means that no three points are collinear, and **convex position** means that every selected point is a vertex of the convex hull of the selected set. The Happy-End Problem asks for the behavior, and where possible the exact value, of $ES(n)$.

The classical existence proof passes through a more structured statement. After ordering points by horizontal coordinate, one searches for a chain that bends consistently upward or consistently downward. Such chains are called cups and caps. The asymmetric version, allowing a $k$-cup or an $l$-cap, has the exact binomial threshold needed for the inductive method:

$$
N>\binom{k+l-4}{k-2}.
$$

The proof illustrates a recurring principle in extremal geometry: encode geometry by a finite sign pattern, identify a recursively meaningful subset, and let a combinatorial recurrence control cardinality. Here the sign is the orientation of a triple, the recursively meaningful subset consists of endpoints of cups, and the recurrence is the Pascal recurrence.

This paper develops all components required for the conclusion. Section 2 defines orientation, cups, caps, and convex position. Section 3 establishes local extension facts. Section 4 proves the cup–cap theorem by endpoint decomposition. Section 5 proves that local turning conditions become global convexity. Section 6 derives the Happy-End upper bound. Section 7 presents witness-finding algorithms, and the final sections discuss numerical behavior, applications, limitations, and future directions.

## 2. Geometric definitions

### 2.1 Orientation

For points $A=(x_A,y_A)$, $B=(x_B,y_B)$, and $C=(x_C,y_C)$ in $\mathbb{R}^2$, define

$$
\Delta(A,B,C)
=(x_B-x_A)(y_C-y_A)-(y_B-y_A)(x_C-x_A).
$$

The quantity $\Delta(A,B,C)$ is twice the signed area of triangle $ABC$. The ordered triple makes a **left turn** if $\Delta(A,B,C)>0$, a **right turn** if $\Delta(A,B,C)<0$, and is collinear if $\Delta(A,B,C)=0$.

A finite point family is in **general position** if $\Delta(A,B,C)\neq 0$ for every three distinct points. We additionally choose a horizontal direction for which all point coordinates are distinct and index the points so that

$$
x_1<x_2<\cdots<x_N.
$$

For an arbitrary finite set in general position, such a direction always exists: only finitely many projection directions make a pair of points tie, so a direction outside that finite exceptional set can be chosen. A rigid rotation then makes this direction horizontal. Rotation preserves collinearity, orientation sign, and convex position.

### 2.2 Cups and caps

Let $i_1<i_2<\cdots<i_r$. The chain

$$
P_{i_1},P_{i_2},\ldots,P_{i_r}
$$

is an **$r$-cup** if every consecutive triple turns left:

$$
\Delta(P_{i_j},P_{i_{j+1}},P_{i_{j+2}})>0
\quad\text{for }1\leq j\leq r-2.
$$

It is an **$r$-cap** if every consecutive triple turns right:

$$
\Delta(P_{i_j},P_{i_{j+1}},P_{i_{j+2}})<0
\quad\text{for }1\leq j\leq r-2.
$$

For chains of length zero, one, or two, the turn condition is vacuous. In particular, any pair of distinct points, listed from left to right, is both a $2$-cup and a $2$-cap.

The consecutive-triple definition is crucial. Appending a point to a cup creates only one new condition, and prepending a point to a cap likewise creates only one new condition. Global convexity will be recovered later from the horizontal ordering.

### 2.3 Convex cup and cap position

A selected set is in **convex cup position** if every triple of its points, listed in increasing horizontal order, has positive orientation. It is in **convex cap position** if every such triple has negative orientation. Either condition implies that all selected points are extreme points of their convex hull and hence are in convex position.

This orientation-based description is stronger than merely asking consecutive triples to turn consistently. Section 5 proves that, for horizontally ordered points, the local and global descriptions agree for cups and caps.

## 3. Local geometric lemmas

The induction requires only elementary extension facts.

**Lemma 3.1 (Cup extension).** Suppose

$$
P_{i_1},\ldots,P_{i_r}
$$

is an $r$-cup with $r\geq 2$, and let $Q$ lie to the right of $P_{i_r}$. If

$$
\Delta(P_{i_{r-1}},P_{i_r},Q)>0,
$$

then appending $Q$ produces an $(r+1)$-cup.

**Proof sketch.** Every old consecutive triple retains positive orientation. The only new consecutive triple is $(P_{i_{r-1}},P_{i_r},Q)$, positive by assumption. The indices remain increasing because $Q$ lies to the right. $\square$

**Lemma 3.2 (Cap extension).** Suppose

$$
P_{i_1},\ldots,P_{i_r}
$$

is an $r$-cap with $r\geq 2$, and let $C$ lie to the left of $P_{i_1}$. If

$$
\Delta(C,P_{i_1},P_{i_2})<0,
$$

then prepending $C$ produces an $(r+1)$-cap.

**Proof sketch.** Again, only the first triple is new. Its orientation is negative by hypothesis, while every old consecutive triple remains negative. $\square$

**Lemma 3.3 (Orientation dichotomy).** For three distinct points in a general-position set, exactly one of the inequalities $\Delta(A,B,C)>0$ and $\Delta(A,B,C)<0$ holds.

**Proof sketch.** The determinant is nonzero by general position, and every nonzero real number is either positive or negative. $\square$

These lemmas are local: no claim about nonconsecutive triples is needed in the cup–cap induction.

## 4. The cup–cap theorem

### 4.1 Extremal formulation

For nonnegative integers $a$ and $b$, consider a finite horizontally ordered point set $S$ in general position that contains neither an $(a+2)$-cup nor a $(b+2)$-cap. We prove

$$
|S|\leq \binom{a+b}{a}.
$$

Replacing $a$ by $k-2$ and $b$ by $l-2$ gives the standard threshold.

### 4.2 Endpoint decomposition

For a positive integer $r$, define $E_r(S)$ to be the set of points in $S$ that are the rightmost endpoint of some $r$-cup contained in $S$.

This set has two structural properties.

**Lemma 4.1 (Endpoint removal).** If $r\geq 1$, then $S\setminus E_r(S)$ contains no $r$-cup.

**Proof.** If an $r$-cup were contained in $S\setminus E_r(S)$, its rightmost point would, by the definition of $E_r(S)$, belong to $E_r(S)$. That point would simultaneously lie outside and inside $E_r(S)$, a contradiction. $\square$

The second property is the geometric heart of the argument.

**Lemma 4.2 (Endpoint caps force an extension).** Let $a',b'\geq 0$. Suppose $S$ contains neither an $(a'+3)$-cup nor a $(b'+3)$-cap. Then $E_{a'+2}(S)$ contains no $(b'+2)$-cap.

**Proof.** Assume for contradiction that

$$
Q_1<Q_2<\cdots<Q_{b'+2}
$$

is a $(b'+2)$-cap contained in $E_{a'+2}(S)$. Since $Q_1$ belongs to the endpoint set, an $(a'+2)$-cup ends at $Q_1$. Because this cup has at least two points, let $C$ be its penultimate point. Then $C<Q_1<Q_2$.

By general position, the orientation of $(C,Q_1,Q_2)$ is nonzero. If

$$
\Delta(C,Q_1,Q_2)>0,
$$

Lemma 3.1 appends $Q_2$ to the cup ending at $Q_1$, creating an $(a'+3)$-cup in $S$. If instead

$$
\Delta(C,Q_1,Q_2)<0,
$$

Lemma 3.2 prepends $C$ to the displayed cap, creating a $(b'+3)$-cap in $S$. Both alternatives contradict the assumptions. Therefore the endpoint set contains no such cap. $\square$

The proof uses only the first two points of the hypothetical cap and the last two points of one cup. This locality is why the decomposition remains clean.

### 4.3 Double induction

**Theorem 4.3 (Reparametrized Cup–Cap Bound).** Let $a,b\geq 0$. If a finite point set $S$ in general position contains no $(a+2)$-cup and no $(b+2)$-cap, then

$$
|S|\leq \binom{a+b}{a}.
$$

**Proof.** We use induction on the pair $(a,b)$.

If $a=0$, the set has no $2$-cup. Since every pair is a $2$-cup, $|S|\leq 1$, and

$$
1=\binom{b}{0}.
$$

The case $b=0$ is symmetric.

Now assume $a,b\geq 1$ and that the theorem holds whenever either parameter is smaller. Let

$$
E=E_{a+1}(S).
$$

By Lemma 4.1, $S\setminus E$ has no $(a+1)$-cup. It also has no $(b+2)$-cap, because it is a subset of $S$. Applying the inductive hypothesis with parameters $(a-1,b)$ gives

$$
|S\setminus E|\leq \binom{a+b-1}{a-1}.
$$

The endpoint set $E$ has no $(a+2)$-cup because it is a subset of $S$. By Lemma 4.2, with $a'=a-1$ and $b'=b-1$, it has no $(b+1)$-cap. Applying the inductive hypothesis with parameters $(a,b-1)$ gives

$$
|E|\leq \binom{a+b-1}{a}.
$$

Since $S$ is the disjoint union of $E$ and $S\setminus E$,

$$
\begin{aligned}
|S|
&=|E|+|S\setminus E|\\
&\leq \binom{a+b-1}{a}+\binom{a+b-1}{a-1}\\
&=\binom{a+b}{a},
\end{aligned}
$$

where the last equality is Pascal's identity. $\square$

**Corollary 4.4 (Cup–Cap Theorem).** Let $k,l\geq 2$. Every set of more than

$$
\binom{k+l-4}{k-2}
$$

points in general position with distinct horizontal coordinates contains either a $k$-cup or an $l$-cap.

**Proof.** If neither chain existed, Theorem 4.3 with $a=k-2$ and $b=l-2$ would bound the cardinality by the displayed binomial coefficient. $\square$

**Corollary 4.5 (Diagonal Cup–Cap Bound).** For $n\geq 2$, every set of at least

$$
\binom{2n-4}{n-2}+1
$$

points in general position with distinct horizontal coordinates contains an $n$-cup or an $n$-cap.

**Proof.** Put $k=l=n$ in Corollary 4.4 and rewrite strict cardinality as addition of one. $\square$

## 5. From consecutive turns to global convexity

The diagonal result gives a locally monotone chain. We now show that it gives convex position.

For points $A$ and $B$ with $x_A<x_B$, define the slope

$$
m(A,B)=\frac{y_B-y_A}{x_B-x_A}.
$$

A direct calculation shows that for $x_A<x_B<x_C$,

$$
\Delta(A,B,C)>0
\quad\Longleftrightarrow\quad
m(A,B)<m(B,C),
$$

and similarly negative orientation corresponds to the reverse inequality.

**Lemma 5.1 (Four-point propagation).** Let $x_A<x_B<x_C<x_D$.

1. If $\Delta(A,B,C)>0$ and $\Delta(B,C,D)>0$, then both $\Delta(A,B,D)>0$ and $\Delta(A,C,D)>0$.
2. If the two given orientations are negative, then both resulting orientations are negative.

**Proof sketch.** In the positive case, the consecutive slopes satisfy

$$
m(A,B)<m(B,C)<m(C,D).
$$

The chord slope $m(A,C)$ is a positive weighted average of $m(A,B)$ and $m(B,C)$, while $m(B,D)$ is a positive weighted average of $m(B,C)$ and $m(C,D)$. Hence

$$
m(A,B)<m(B,D)
\quad\text{and}\quad
m(A,C)<m(C,D),
$$

which are equivalent to the two desired positive orientations. Reversing all inequalities proves the negative case. $\square$

**Theorem 5.2 (Local-to-Global Convexity).** Let

$$
P_1,P_2,\ldots,P_r
$$

have strictly increasing horizontal coordinates.

1. If every consecutive triple has positive orientation, then every triple $P_i,P_j,P_k$ with $i<j<k$ has positive orientation.
2. If every consecutive triple has negative orientation, then every such triple has negative orientation.

**Proof sketch.** Induct on the chain length. Removing the first point leaves a chain to which the induction hypothesis applies. For triples containing the first point, repeatedly apply the four-point propagation lemma to extend a positive or negative orientation across intervening vertices. One first obtains a fan of consistently oriented triples based at the first edge, then collapses intermediate vertices to reach any prescribed pair $j<k$. The cap case repeats the same argument with all signs reversed. $\square$

**Corollary 5.3.** The vertices of every cup or cap are in convex position.

**Proof sketch.** By Theorem 5.2, every ordered triple of a cup has positive orientation and every ordered triple of a cap has negative orientation. Such a set forms a strictly convex monotone chain: no selected point can lie in the convex hull of the others. Closing the chain by the segment joining its extreme points yields a convex polygon whose vertices are exactly the selected points. $\square$

## 6. The Happy-End upper bound

**Theorem 6.1 (Happy-End Upper-Bound Theorem).** For every integer $n\geq 2$, any set of at least

$$
\binom{2n-4}{n-2}+1
$$

points in the plane in general position contains $n$ points in convex position.

**Proof.** Choose a projection direction in which all point projections are distinct, rotate that direction to horizontal, and order the points by horizontal coordinate. Corollary 4.5 supplies an $n$-cup or an $n$-cap. Corollary 5.3 shows that the selected $n$ points are in convex position. Rotation back to the original coordinates preserves convexity. $\square$

Thus

$$
ES(n)\leq \binom{2n-4}{n-2}+1.
$$

The theorem proves finiteness of $ES(n)$ and provides an explicit universal bound. It does not assert that the bound is the exact minimum. Indeed, for small $n$ the distinction is visible:

| $n$ | Classical guarantee $\binom{2n-4}{n-2}+1$ | Exact $ES(n)$ where stated |
|---:|---:|---:|
| $3$ | $3$ | $3$ |
| $4$ | $7$ | $5$ |
| $5$ | $21$ | $9$ |
| $6$ | $71$ | $17$ |

Asymptotically, the central binomial coefficient gives

$$
\binom{2n-4}{n-2}
\sim \frac{4^{n-2}}{\sqrt{\pi(n-2)}}.
$$

Accordingly, the classical argument is exponential with base approximately $4$. Sharper methods improve this scale, but the cup–cap theorem remains a fundamental combinatorial engine.

## 7. Constructive algorithms

### 7.1 Computing the threshold

The numerical guarantee can be computed directly as

$$
G(n)=\binom{2n-4}{n-2}+1.
$$

An exact multiplicative computation of $\binom{r}{s}$ uses $O(s)$ arithmetic operations, with integer bit complexity determined by the $O(n)$-bit output.

For asymmetric targets, use

$$
G(k,l)=\binom{k+l-4}{k-2}+1.
$$

Pascal's recurrence also permits a dynamic-programming table. This table makes the proof's recursive structure visible: each interior threshold is one greater than a binomial coefficient obtained by adding the two neighboring extremal bounds.

### 7.2 Longest cup or cap by dynamic programming

Given $N$ points with distinct horizontal coordinates, sort them from left to right. For every ordered pair $i<j$, let $U[i,j]$ be the maximum length of a cup ending with $P_i,P_j$, and let $D[i,j]$ be the corresponding maximum cap length. Initialize both values to $2$.

For every triple $h<i<j$:

- if $\Delta(P_h,P_i,P_j)>0$, update

$$
U[i,j]\leftarrow \max\bigl(U[i,j],U[h,i]+1\bigr);
$$

- if $\Delta(P_h,P_i,P_j)<0$, update

$$
D[i,j]\leftarrow \max\bigl(D[i,j],D[h,i]+1\bigr).
$$

Predecessor pointers reconstruct a witness chain. Sorting costs $O(N\log N)$ time. The triple loop costs $O(N^3)$ time, and the tables use $O(N^2)$ memory. The algorithm works for arbitrary input sizes; when the cup–cap threshold applies, the theorem guarantees that one returned maximum reaches the requested length.

### 7.3 Checking a proposed witness

A proposed chain of length $r$ can be checked in $O(r)$ orientation evaluations: verify increasing horizontal coordinates and inspect its $r-2$ consecutive triples. If global convex cup or cap position is desired directly, all $\binom{r}{3}$ triples may be checked in $O(r^3)$ time. The Local-to-Global Convexity Theorem explains why the linear local check already suffices under strict horizontal ordering.

## 8. Applications and interpretation

The orientation determinant used here is central to planar computation. Convex-hull procedures use orientation signs to remove inward turns. Polygon algorithms use them for winding and containment tests. Motion-planning systems use sidedness predicates to reason about obstacles and routes. The cup–cap theorem adds an extremal interpretation: sufficiently many nondegenerate planar samples force a large, coherently curved subsequence.

The endpoint decomposition has a broader algorithmic meaning. Each point is classified by whether it can terminate a chain of prescribed complexity. Removing those endpoints destroys one type of witness, while the endpoints themselves cannot contain too much of the opposing type. This resembles state compression in dynamic programming: the full history of a chain is discarded, but its endpoint and length retain enough information for extension.

The appearance of Pascal's identity reflects a lattice-path geometry behind the induction. The quantity $\binom{a+b}{a}$ counts monotone paths from $(0,0)$ to $(a,b)$. The recurrence splits such paths according to their final step. Likewise, the endpoint proof splits a point set according to whether a point carries the potential to end a long cup. The two child problems reduce one of the two parameters, exactly matching the two predecessor cells in Pascal's triangle.

## 9. Scope and limitations

Three distinctions are important.

First, the cup–cap bound and the Happy-End bound play different roles. The former controls monotone chains with specified turn signs. The latter follows only after proving local-to-global convexity.

Second, distinct horizontal coordinates are a coordinate convenience, not an intrinsic restriction. For a finite general-position set, a generic projection resolves all ties. Nevertheless, any implementation must either choose such a direction or handle ties explicitly.

Third, the theorem gives a sufficient number of points. It does not settle exact Happy-End numbers for general $n$, nor does it establish the optimality of the cup–cap threshold by constructing configurations of exactly $\binom{k+l-4}{k-2}$ points with neither forbidden chain. Such lower constructions require a separate argument.

Numerical predicates also deserve care. With floating-point coordinates, values of $\Delta$ near zero can be misclassified. Exact integer or rational arithmetic is preferable when coordinates permit it; otherwise robust adaptive predicates should replace naive floating-point sign tests.

## 10. Future work

A natural first direction is the complementary lower construction

$$
ES(n)\geq 2^{n-2}+1,
$$

which would place the upper bound in a two-sided framework. Exact small values, including $ES(4)=5$, $ES(5)=9$, and $ES(6)=17$, invite explicit configuration certificates and exhaustive search methods.

For the asymmetric theorem, one may prove sharpness by constructing $\binom{k+l-4}{k-2}$ points with neither a $k$-cup nor an $l$-cap. On the geometric side, it is useful to connect the orientation characterization directly to convex-hull definitions and to make the generic-rotation reduction entirely explicit.

Sharper upper bounds require additional structure beyond the elementary diagonal argument. Other directions include higher-dimensional convex-position problems, positive-fraction and partition variants, and empty-convex-polygon questions, where selected vertices must enclose no other points of the original configuration.

## 10.1 Reproducible numerical experiments

The formulas and algorithms above support three complementary experiments. A threshold table displays the Pascal recurrence and the rapid growth of the diagonal bound. A chain detector applied to deterministic point clouds returns explicit cup and cap witnesses. Finally, an orientation visualization colors triples or chain segments by turn sign, making the local-to-global transition visible. These experiments illustrate the theorem but do not replace its universal quantifiers: sampling many configurations cannot establish a guarantee over all configurations, whereas the endpoint induction does.

## 11. Conclusion

The Happy-End upper bound emerges from a concise chain of ideas. General position turns every triple into a binary left-or-right decision. Cups and caps encode consistent local curvature. Endpoint marking splits an extremal set into two smaller extremal sets. Pascal's identity counts the split. Finally, horizontal order propagates consecutive turn signs to all triples, converting a local chain into a globally convex configuration.

The resulting statement is explicit: for every $n\geq 2$, at least $\binom{2n-4}{n-2}+1$ points in general position force $n$ points in convex position. Its proof is a model of interaction between Euclidean geometry, extremal combinatorics, and constructive computation.
