# Packing Rigidity and Canonical Colorings of Stable Kneser Graphs

**Aristotle**  
**July 16, 2026**

## Abstract

A cyclically $s$-stable subset of $[n]=\{0,1,\ldots,n-1\}$ is a set whose distinct elements have separation at least $s$ along both arcs of the cyclic order. The associated stable Kneser graph has these sets as vertices and joins two vertices when the corresponding sets are disjoint. This paper develops the elementary packing theory underlying the predicted chromatic number $n-sk+s$. We prove that a linearly $s$-stable set of $k$ integers has span at least $s(k-1)$ and classify the equality case as an arithmetic progression. This rigidity yields an explicit proper coloring with $r$ colors whenever $n=r+s(k-1)$: color a set by its minimum, capped at $r-1$. As cyclic stability implies linear stability, this establishes the general upper bound $\chi\le n-sk+s$. We then determine the exact chromatic number for cyclically $3$-stable triples on nine points. Three residue-class triples form a clique, forcing three colors, while the canonical construction provides three colors. Finally, we exhibit two disjoint linearly $3$-stable pairs that receive the same capped-minimum color when the sharp parameter relation is omitted, demonstrating that the packing threshold is essential. Algorithms for enumerating stable sets, constructing the graph, applying the canonical coloring, and checking the nine-point certificate are presented together with complexity estimates.

## 1. Introduction

Kneser-type graphs encode intersection questions as coloring problems. Fix a ground set and a family of its subsets. Regard every member of the family as a vertex, and join two vertices precisely when the corresponding subsets are disjoint. A proper color class must then be an intersecting family. The chromatic number measures how many intersecting subfamilies are needed to partition the original family.

Stable Kneser graphs impose geometric spacing on the allowed subsets. Arrange $n$ labeled points around a circle. A set is admissible when its chosen points remain separated by at least $s$ positions in both cyclic directions. If every admissible set has size $k$, the expected chromatic number in the feasible range $n\ge sk$ is

$$
n-sk+s.
$$

The formula is notable because it is linear in $n$, despite the potentially large number of vertices. Its upper-bound half admits a direct construction, but that construction depends on a sharp packing phenomenon that deserves to be isolated.

The first goal of this paper is to develop that phenomenon from first principles. On a line, $k$ points with consecutive spacing at least $s$ occupy span at least $s(k-1)$. When equality holds, every gap is forced to equal $s$, and the set is an arithmetic progression. This equality characterization is then used to prove the correctness of a capped-minimum coloring. Ordinary colors identify sets by their least element. The final color gathers all sets with large minima; the available tail interval has exactly minimum possible span, so rigidity forces all sets in that color to coincide.

The second goal is to combine this construction with a concrete lower-bound certificate at the tight instance $(n,s,k)=(9,3,3)$. The sets $\{0,3,6\}$, $\{1,4,7\}$, and $\{2,5,8\}$ are cyclically stable and pairwise disjoint. They form a triangle and therefore demand three colors. The upper coloring uses three colors, proving exactness.

The third goal is diagnostic. The capped-minimum rule may look robust enough to survive beyond its original numerical setting. It does not. The disjoint pairs $\{1,4\}$ and $\{2,5\}$ are both linearly $3$-stable but collapse to the same color under a two-color cap. This counterexample identifies the precise source of correctness: not the syntax of the coloring map alone, but the equality case of the packing bound.

## 2. Stable sets and disjointness graphs

### 2.1 Linear stability

Let $A$ be a finite subset of the nonnegative integers, and let $s$ be a nonnegative integer.

**Definition 2.1 (Linear stability).** The set $A$ is **linearly $s$-stable** if, for every $x,y\in A$ with $x<y$,

$$
x+s\le y.
$$

Equivalently, every pair of distinct elements differs by at least $s$. For an ordered list

$$
a_0<a_1<\cdots<a_{k-1}
$$

of the elements of $A$, it is enough to require $a_{i+1}-a_i\ge s$ for every consecutive pair.

The **span** of a nonempty finite set $A$ is

$$
\operatorname{span}(A)=\max A-\min A.
$$

### 2.2 Cyclic stability

Write

$$
[n]=\{0,1,\ldots,n-1\}
$$

with its natural cyclic order. For $0\le x<y<n$, the two directed arc lengths between $x$ and $y$ are $y-x$ and $n+x-y$.

**Definition 2.2 (Cyclic stability).** A subset $A\subseteq[n]$ is **cyclically $s$-stable** if, for every $x,y\in A$ with $x<y$,

$$
y-x\ge s
\qquad\text{and}\qquad
n+x-y\ge s.
$$

Thus neither of the two arcs joining selected points is shorter than $s$. The definition includes the wrap-around restriction between the largest and smallest selected elements.

**Lemma 2.3 (Cyclic-to-linear implication).** Every cyclically $s$-stable subset of $[n]$ is linearly $s$-stable.

**Proof sketch.** For $x<y$ in a cyclically stable set, the first inequality in Definition 2.2 is $y-x\ge s$, which is exactly the linear stability condition. The second cyclic inequality imposes an additional wrap-around constraint and is not needed for the implication. $\square$

### 2.3 Stable Kneser graphs

**Definition 2.4 (Stable Kneser graph).** For positive integers $n,s,k$, let $G(n,s,k)$ be the graph whose vertices are the cyclically $s$-stable $k$-subsets of $[n]$. Two vertices $A$ and $B$ are adjacent if and only if

$$
A\cap B=\varnothing.
$$

A coloring with $q$ colors is a map

$$
c:V(G(n,s,k))\longrightarrow\{0,1,\ldots,q-1\}.
$$

It is **proper** if $c(A)\ne c(B)$ whenever $A$ and $B$ are disjoint. The chromatic number $\chi(G(n,s,k))$ is the least $q$ for which a proper coloring exists.

Equivalently, each color fiber must be an intersecting family: any two sets of the same color must share an element.

## 3. Packing and extremal rigidity

The central elementary fact is a sharp lower bound on the span occupied by stable points.

**Theorem 3.1 (Stable Packing Bound).** Let $A$ be a nonempty linearly $s$-stable finite set with $|A|=k$. Then

$$
s(k-1)\le \max A-\min A.
$$

**Proof sketch.** Enumerate the elements increasingly as

$$
a_0<a_1<\cdots<a_{k-1}.
$$

Linear stability gives $a_{i+1}-a_i\ge s$ for $0\le i<k-1$. Summing these inequalities telescopes:

$$
a_{k-1}-a_0
=\sum_{i=0}^{k-2}(a_{i+1}-a_i)
\ge\sum_{i=0}^{k-2}s
=s(k-1).
$$

Since $a_0=\min A$ and $a_{k-1}=\max A$, the conclusion follows. $\square$

An interval formulation follows immediately.

**Corollary 3.2 (Interval Packing Bound).** If a nonempty linearly $s$-stable set $A$ lies in the integer interval $[a,b]$, then

$$
s(|A|-1)\le b-a.
$$

**Proof sketch.** Theorem 3.1 gives $s(|A|-1)\le\max A-\min A$. Since $a\le\min A\le\max A\le b$, the span is at most $b-a$. $\square$

The equality case provides the rigidity needed later.

**Theorem 3.3 (Extremal Rigidity).** Let $s>0$ and $k>0$. If a linearly $s$-stable set $A$ has $k$ elements and is contained in

$$
[a,a+s(k-1)],
$$

then

$$
A=\{a,a+s,a+2s,\ldots,a+s(k-1)\}.
$$

**Proof sketch.** Write $A=\{a_0<a_1<\cdots<a_{k-1}\}$. Since $a_0\ge a$ and every consecutive gap is at least $s$, induction gives

$$
a_i\ge a+si.
$$

In particular, $a_{k-1}\ge a+s(k-1)$. But containment in the stated interval gives the reverse inequality, so $a_{k-1}=a+s(k-1)$. If $a_0>a$ or any gap exceeded $s$, the sum of the gaps would force $a_{k-1}>a+s(k-1)$, a contradiction. Hence $a_0=a$ and every gap equals $s$, proving the formula. $\square$

**Corollary 3.4 (Extremal Intersection).** Let $s>0$ and $k>0$. If $A$ and $B$ are linearly $s$-stable $k$-sets contained in the same interval $[a,a+s(k-1)]$, then $A=B$. In particular,

$$
A\cap B\ne\varnothing.
$$

**Proof sketch.** Theorem 3.3 identifies both sets with the same arithmetic progression. $\square$

The distinction between the inequality and its equality case is important. The span bound says stable sets need room. Rigidity says that when no extra room is available, there is only one possible arrangement.

## 4. The canonical capped-minimum coloring

Let $r>0$, and suppose the parameters satisfy

$$
n=r+s(k-1).
$$

For every nonempty subset $A\subseteq[n]$, define

$$
c_r(A)=\min\{\min A,r-1\}.
$$

The image lies in $\{0,1,\ldots,r-1\}$. The colors below $r-1$ record the exact minimum. The last color merges all sets whose minimum is at least $r-1$.

**Theorem 4.1 (Canonical Coloring Theorem for Linear Stability).** Let $s,k,r$ be positive integers and let $n=r+s(k-1)$. If $A,B\subseteq[n]$ are linearly $s$-stable $k$-sets and

$$
c_r(A)=c_r(B),
$$

then

$$
A\cap B\ne\varnothing.
$$

Consequently, disjoint linearly $s$-stable $k$-sets receive different colors.

**Proof sketch.** There are two principal cases.

First suppose the common color is less than $r-1$. Capping has not occurred, so

$$
\min A=c_r(A)=c_r(B)=\min B.
$$

The shared minimum belongs to both sets, proving intersection.

Now suppose the common color is $r-1$ and both minima are at least $r-1$. Then both $A$ and $B$ lie in the interval

$$
[r-1,n-1].
$$

Its length is

$$
(n-1)-(r-1)=n-r=s(k-1).
$$

By Corollary 3.4, both stable $k$-sets equal the same arithmetic progression, so they intersect. The remaining apparent mixed possibilities—one minimum below the cap and the other at or above it—cannot produce equal capped values except at the boundary, where the same conclusion applies. $\square$

The circle now enters only through Lemma 2.3.

**Theorem 4.2 (Canonical Coloring Theorem for Cyclic Stability).** Let $s,k,r$ be positive integers and $n=r+s(k-1)$. The map

$$
c_r(A)=\min\{\min A,r-1\}
$$

is a proper $r$-coloring of $G(n,s,k)$.

**Proof sketch.** Every vertex is cyclically $s$-stable and therefore linearly $s$-stable by Lemma 2.3. If two disjoint vertices had the same color, Theorem 4.1 would force them to intersect, a contradiction. $\square$

**Corollary 4.3 (General Constructive Upper Bound).** Under the hypotheses of Theorem 4.2,

$$
\chi(G(n,s,k))\le r=n-sk+s.
$$

**Proof sketch.** Theorem 4.2 supplies a proper coloring with $r$ colors. Algebraically,

$$
r=n-s(k-1)=n-sk+s.
$$

Therefore the chromatic number is at most the predicted quantity. $\square$

The proof explains why the final color is safe. It does not rely on all sets with large minima automatically intersecting. Instead, the numerical relation makes the tail interval exactly as short as possible, and Theorem 3.3 leaves only one stable $k$-set there.

## 5. Exact chromatic number for cyclically stable triples on nine points

We now specialize to

$$
(n,s,k)=(9,3,3).
$$

The graph $G(9,3,3)$ has as vertices the cyclically $3$-stable triples in $[9]$. Consider the residue-class triples

$$
R_0=\{0,3,6\},\qquad
R_1=\{1,4,7\},\qquad
R_2=\{2,5,8\}.
$$

**Lemma 5.1 (Residue Triple Certificate).** Each of $R_0,R_1,R_2$ is cyclically $3$-stable, and the three sets are pairwise disjoint.

**Proof sketch.** Within each $R_i$, the points appear at cyclic gaps $3,3,3$. Thus both arcs between any pair have length at least $3$. Distinct residue classes modulo $3$ share no elements, so the triples are pairwise disjoint. $\square$

**Theorem 5.2 (Three-Color Lower Bound).** The graph $G(9,3,3)$ cannot be properly colored with two colors.

**Proof sketch.** By Lemma 5.1, the vertices $R_0,R_1,R_2$ are pairwise adjacent, so they form a clique of size $3$. In a proper coloring, pairwise adjacent vertices must receive pairwise distinct colors. Two colors cannot color three pairwise adjacent vertices. Hence $\chi(G(9,3,3))\ge3$. $\square$

**Theorem 5.3 (Three-Color Upper Bound).** The graph $G(9,3,3)$ admits a proper coloring with three colors.

**Proof sketch.** The parameter identity is

$$
9=3+3(3-1).
$$

Apply Theorem 4.2 with $r=3$. Explicitly, color a stable triple $A$ by

$$
c_3(A)=\min\{\min A,2\}.
$$

This is a proper coloring with colors $0,1,2$. $\square$

**Theorem 5.4 (Exact Nine-Point Theorem).** The chromatic number of the cyclic $3$-stable Kneser graph on triples from nine points is

$$
\chi(G(9,3,3))=3.
$$

**Proof sketch.** Theorem 5.2 gives the lower bound $3$, and Theorem 5.3 gives the upper bound $3$. $\square$

The result matches the predicted formula:

$$
9-3\cdot3+3=3.
$$

It also displays a general boundary pattern. At $n=sk$, residue classes modulo $s$ naturally produce $s$ pairwise disjoint stable $k$-sets. A full boundary classification would need to show that every stable set has this form, not merely that these examples exist.

## 6. Necessity of the sharp threshold

The canonical map can fail when detached from the relation $n=r+s(k-1)$.

**Theorem 6.1 (Threshold Counterexample).** In $[7]=\{0,1,\ldots,6\}$, let

$$
A=\{1,4\},\qquad B=\{2,5\}.
$$

Then $A$ and $B$ are disjoint linearly $3$-stable $2$-sets, but the two-color capped-minimum map

$$
c_2(X)=\min\{\min X,1\}
$$

satisfies

$$
c_2(A)=c_2(B)=1.
$$

Therefore this map is not a proper coloring of the corresponding disjointness graph.

**Proof sketch.** The unique gap in each pair equals $3$, so both are linearly $3$-stable. Their elements are distinct, hence they are disjoint. Their minima are $1$ and $2$, and both cap to $1$. $\square$

For these parameters, $s=3$, $k=2$, and $r=2$, the sharp identity would require

$$
n=r+s(k-1)=2+3=5,
$$

not $n=7$. The last-color interval is consequently longer than the minimum span $3$. It can accommodate multiple stable pairs, and rigidity no longer forces intersection.

This counterexample does not say that the capped-minimum map fails for every parameter choice outside the equality. It says that properness cannot be asserted without a condition relating $n$, $s$, $k$, and $r$. Classifying all successful parameter quadruples remains a natural problem.

## 7. Algorithms and complexity

### 7.1 Enumeration of cyclically stable sets

For small and medium instances, stable sets can be generated by scanning all $k$-subsets of $[n]$.

**Algorithm 7.1 (Stable-set enumeration).**

1. Generate each increasing tuple $(a_0,\ldots,a_{k-1})$ from $[n]$.
2. Compute the cyclic gaps
   $$
   a_{i+1}-a_i\quad(0\le i<k-1),
   $$
   together with the wrap-around gap
   $$
   n+a_0-a_{k-1}.
   $$
3. Retain the tuple exactly when every gap is at least $s$.

There are $\binom{n}{k}$ candidates. Testing the $k$ cyclic gaps costs $O(k)$ time, giving total time

$$
O\!\left(k\binom{n}{k}\right).
$$

The output space is proportional to the number $v$ of stable sets, with $O(kv)$ integers stored.

Checking consecutive cyclic gaps is sufficient. If every consecutive gap is at least $s$, every arc between nonconsecutive selected points is a sum of one or more such gaps and is therefore also at least $s$.

### 7.2 Construction of the disjointness graph

Given the list of $v$ stable sets, compare every unordered pair and add an edge when their intersection is empty. With hash-set representations, each disjointness test costs expected $O(k)$ time, so direct construction costs

$$
O(v^2k)
$$

and uses $O(v+e)$ graph storage, where $e$ is the number of disjoint pairs.

### 7.3 Canonical coloring

Under $n=r+s(k-1)$, assign

$$
c_r(A)=\min\{\min A,r-1\}.
$$

If sets are stored as sorted tuples, the minimum is the first entry and coloring costs $O(1)$ per vertex. For an unsorted representation, finding the minimum costs $O(k)$. Coloring all vertices therefore costs $O(v)$ or $O(vk)$, respectively.

The proof of properness is structural, but a numerical demonstration may verify every disjoint pair. Such a check costs $O(v^2k)$ by the direct method.

### 7.4 Boundary certificate

For $(n,s,k)=(9,3,3)$, construct the three residue classes modulo $3$. Stability requires only the three cyclic gap checks per set, and pairwise disjointness requires three comparisons. This provides a constant-size lower-bound certificate. Combined with the canonical coloring, it yields an independently inspectable numerical demonstration of the exact chromatic number.

## 8. Applications and interpretation

### 8.1 Scheduling with exclusion windows

A cyclically stable set models recurring choices on a periodic timetable, such as maintenance windows, communication slots, or rotating inspections. The separation parameter $s$ is a safety buffer. Vertices represent feasible schedules, while edges identify schedules that share no slot. A coloring partitions schedules into intersecting classes, ensuring that schedules with the same label share at least one common event.

The packing theorem quantifies the minimum temporal span required for $k$ events. The rigidity theorem describes saturated schedules: at maximum density, the pattern must be periodic with exact spacing $s$.

### 8.2 Frequency assignment and channel plans

Positions around a circle can represent cyclic frequency bands or phases. Stable subsets enforce guard bands, and disjoint configurations represent nonoverlapping channel plans. The canonical coloring gives a compact classification based only on the first occupied position, with one terminal class controlled by extremal rigidity.

### 8.3 Constant-weight codes with circular separation

A $k$-subset of $[n]$ may be identified with a binary word of length $n$ and weight $k$. Cyclic stability imposes a run-length constraint between ones. Disjointness means the supports have no common coordinate. Packing and rigidity then describe the densest allowable words, while graph coloring organizes the codewords into support-intersecting classes.

These interpretations do not change the mathematics, but they emphasize why explicit colorings matter: they are efficient labels for large families of constrained configurations.

## 9. Discussion

The main upper-bound argument has three layers. First, stability creates a packing inequality. Second, equality in that inequality creates uniqueness. Third, the coloring map is designed so that its exceptional fiber lies exactly in the equality regime. This structure is more informative than a direct pairwise verification because it identifies which assumption does the work.

The nine-point theorem adds a lower-bound mechanism of a different kind. A clique immediately forces distinct colors. The residue triples are especially natural because they partition the circle and saturate all cyclic gaps. The exact result arises where an explicit coloring and an explicit obstruction meet.

The counterexample is equally informative. It separates the map from its theorem: the formula $c_r(A)=\min\{\min A,r-1\}$ is always definable, but it is not always proper. Once the tail interval exceeds minimum span, multiple disjoint stable sets can occupy it. Any extension of the method must either restore a suitable interval bound or modify the treatment of the final color.

The broad equality for cyclically $3$-stable Kneser graphs requires lower bounds beyond the boundary example. Such bounds cannot generally come from the canonical construction, which only proves existence of a coloring. They must constrain arbitrary colorings. Since every color fiber is intersecting, structural theorems about large nontrivial intersecting families are a plausible combinatorial route. Topological obstruction methods offer a complementary global route.

## 10. Future work

The first objective is the full $3$-stable equality

$$
\chi(G(n,3,k))=n-3k+3
$$

for all $k\ge1$ and $n\ge3k$. The present upper bound applies throughout this range after setting $r=n-3k+3$; the unresolved component is the matching lower bound away from the exact nine-point instance.

A second objective is **boundary rigidity for arbitrary stability**. At $n=sk$, every cyclically $s$-stable $k$-set is expected to be a residue class modulo $s$. Ordering the selected points and summing all $k$ cyclic gaps should force every gap to equal $s$. This would identify the boundary graph with a complete graph on $s$ vertices and prove the exact boundary value uniformly.

A third direction is a stable Hilton–Milner classification: determine the largest intersecting family of cyclically $3$-stable $k$-sets that is not a star, and characterize equality. Since each color fiber is intersecting, such a theorem could prevent too few fibers from covering all vertices.

A fourth direction is to build topological lower-bound certificates, for example through equivariant indices or Tucker-type combinatorial lemmas. The goal would be a finite, inspectable obstruction showing that a proposed small coloring cannot exist.

Finally, the capped-minimum rule itself deserves classification. Determine all quadruples $(n,s,k,r)$ for which

$$
A\longmapsto\min\{\min A,r-1\}
$$

is proper on the relevant stable family. Theorem 6.1 proves that a genuine relation among interval length, separation, set size, and color count is necessary.

## 11. Conclusion

Stable Kneser coloring is governed, on its constructive side, by an elementary but sharp packing principle. A linearly $s$-stable $k$-set needs span at least $s(k-1)$; at equality it is the unique arithmetic progression of step $s$ in its interval. This rigidity makes the capped-minimum map a proper coloring whenever $n=r+s(k-1)$ and yields

$$
\chi(G(n,s,k))\le n-sk+s.
$$

For cyclically $3$-stable triples on nine points, three residue-class vertices form a clique, while the canonical map supplies three colors. Hence the chromatic number is exactly $3$. The disjoint pairs $\{1,4\}$ and $\{2,5\}$ show that the same map can fail without its sharp threshold. Together, these results isolate a durable principle: optimal coloring constructions often rest not merely on packing inequalities, but on the rigidity of their equality cases.