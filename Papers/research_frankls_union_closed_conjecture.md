# Structural and Finite Results for Union-Closed Families, with an Information-Theoretic Companion Identity

**Aristotle**  
**July 30, 2026**

## Abstract

A finite family of sets is union-closed if it contains the union of every pair of its members. Frankl's union-closed sets conjecture asserts that every such family with a nonempty member has an element occurring in at least half its members. We develop a self-contained account of several rigorous results around this conjecture. First, every nonempty finite union-closed family has a greatest member under inclusion: the union of all members belongs to the family. Second, the presence of a singleton forces its unique element to be abundant by an explicit injection. Combining this structural reduction with an exhaustive residual analysis establishes Frankl's property for every family on a three-element universe. Third, for the full Boolean lattice on $n$ points, we prove the exact identities $|\mathcal P([n])|=2^n$ and $\sum_{A\subseteq[n]}|A|=n2^{n-1}$, hence $2\sum_A|A|=n|\mathcal P([n])|$; every coordinate is abundant, and the average member size is exactly $n/2$. This gives the exact Boolean-cube equality pattern for the average-size bound associated with Reimer's theorem, without invoking entropy. We also present algorithms for finite verification and incidence counting. Finally, as a companion bridge to information theory, we prove that the Euler--Mascheroni constant is the accumulated Kullback--Leibler divergence between exponential distributions of successive integer rates. The unrestricted Frankl conjecture is not claimed and remains open.

## 1. Introduction

Let $\mathcal F$ be a finite family of finite sets. The family is **union-closed** when

$$
A,B\in\mathcal F\implies A\cup B\in\mathcal F.
$$

Frankl's union-closed sets conjecture predicts that if at least one member of $\mathcal F$ is nonempty, then some element occurs in at least half the members. Despite the elementary statement, the unrestricted conjecture remains unresolved. Its difficulty comes from a tension between local and global information. Union-closure constrains pairs of members, while the desired conclusion concerns a single coordinate's frequency across the entire family.

This paper isolates several situations in which that tension can be resolved exactly. The first is structural: repeated union produces a greatest member. The second is an injection principle: a singleton in the family certifies an abundant element. The third is finite: on a universe of three points, the singleton principle and an exhaustive residual classification establish the conjectured conclusion. The fourth is extremal and enumerative: the full Boolean lattice exhibits exact coordinate balance and exact average set size.

The Boolean-cube calculation is related to the average-size inequality customarily associated with Reimer's theorem. We use that relationship only to contextualize the equality pattern. The general entropy inequality is not proved here. The result established here is the exact integer identity for the cube.

A final section develops an independent but thematically related information-theoretic identity. The Kullback--Leibler divergence between successive exponential laws gives the standard nonnegative summands converging to the Euler--Mascheroni constant. This illustrates a recurring principle: a global quantity can be reconstructed from a sequence of local nonnegative discrepancies.

## 2. Definitions and notation

### 2.1. Families, frequencies, and abundance

Let $U$ be a finite universe and let $\mathcal F\subseteq\mathcal P(U)$. For $x\in U$, define the **frequency class**

$$
\mathcal F_x=\{A\in\mathcal F:x\in A\}
$$

and the **frequency**

$$
d_{\mathcal F}(x)=|\mathcal F_x|.
$$

An element $x$ is **abundant in $\mathcal F$** when

$$
|\mathcal F|\le 2d_{\mathcal F}(x).
$$

Equivalently, $x$ belongs to at least half the members of $\mathcal F$. We say that $\mathcal F$ has **Frankl's property** if some element occurring in at least one member of $\mathcal F$ is abundant.

The qualification that the element occurs is relevant for degenerate formulations. If $\mathcal F$ has a nonempty member, its active universe

$$
U(\mathcal F)=\bigcup_{A\in\mathcal F}A
$$

is nonempty, and witnesses are naturally sought in $U(\mathcal F)$.

### 2.2. Union closure and the induced order

A family $\mathcal F$ is **union-closed** if $A\cup B\in\mathcal F$ whenever $A,B\in\mathcal F$. Ordered by inclusion, a union-closed family has binary joins: the join of $A$ and $B$ is $A\cup B$. Thus it is a finite join-semilattice whenever it is nonempty. We shall show that it also has a top element.

### 2.3. Boolean lattices

For a finite set $S$, the power set $\mathcal P(S)$ is called the **Boolean lattice** on $S$. If $|S|=n$, its members correspond to binary vectors of length $n$. Inclusion is coordinatewise order, union is coordinatewise maximum, and intersection is coordinatewise minimum.

## 3. The greatest-member theorem

**Theorem 3.1 (Greatest member of a union-closed family).**  
Let $\mathcal F$ be a nonempty finite union-closed family. Then

$$
T=\bigcup_{A\in\mathcal F}A
$$

belongs to $\mathcal F$, and every $A\in\mathcal F$ satisfies $A\subseteq T$. Consequently, $T$ is the greatest member of $\mathcal F$ under inclusion.

**Proof sketch.** Since $\mathcal F$ is finite and nonempty, enumerate it as $A_1,\ldots,A_m$. Set $T_1=A_1$ and recursively set $T_{j+1}=T_j\cup A_{j+1}$. Union-closure implies inductively that each $T_j$ belongs to $\mathcal F$. The final set $T_m$ is exactly $\bigcup_{A\in\mathcal F}A$, hence belongs to $\mathcal F$. Every member is included in this union by definition. $\square$

This theorem gives the promised lattice-theoretic reformulation: a nonempty finite union-closed family, under inclusion, is a finite join-semilattice with top. Notice that the empty set need not belong to the family, so a bottom element is not automatic.

The result also lets one replace an arbitrary ambient universe by the canonical active universe $T$. In particular, irrelevant points outside all members can be discarded without changing any frequency.

## 4. A singleton forces abundance

**Theorem 4.1 (Singleton abundance).**  
Let $\mathcal F$ be union-closed. If $\{x\}\in\mathcal F$, then $x$ is abundant:

$$
|\mathcal F|\le 2|\mathcal F_x|.
$$

**Proof.** Partition $\mathcal F$ into

$$
\mathcal F_x=\{A\in\mathcal F:x\in A\}
$$

and

$$
\mathcal F_{\bar x}=\{A\in\mathcal F:x\notin A\}.
$$

Define $\phi:\mathcal F_{\bar x}\to\mathcal F_x$ by

$$
\phi(A)=A\cup\{x\}.
$$

Because $A$ and $\{x\}$ are members of $\mathcal F$, union-closure places $\phi(A)$ in $\mathcal F$; it clearly contains $x$. If $\phi(A)=\phi(B)$ and neither $A$ nor $B$ contains $x$, deleting $x$ from both sides gives $A=B$. Hence $\phi$ is injective and

$$
|\mathcal F_{\bar x}|\le |\mathcal F_x|.
$$

Therefore

$$
|\mathcal F|=|\mathcal F_{\bar x}|+|\mathcal F_x|
\le 2|\mathcal F_x|.
$$

Thus $x$ is abundant. $\square$

**Corollary 4.2.**  
Every nontrivial union-closed family containing at least one singleton has Frankl's property.

The proof is constructive: the singleton names the abundant element, and the injection pairs every member missing that element with a distinct member containing it.

## 5. The three-element universe

Let $U=\{0,1,2\}$. Since $|\mathcal P(U)|=8$, there are $2^8=256$ possible subfamilies of $\mathcal P(U)$. This small but nontrivial universe permits an exact classification.

**Lemma 5.1 (Residual no-singleton verification).**  
Let $\mathcal F\subseteq\mathcal P(U)$, where $|U|=3$. Suppose:

1. $\mathcal F$ is union-closed;
2. some member of $\mathcal F$ is nonempty; and
3. no singleton belongs to $\mathcal F$.

Then there exists $x\in U$ such that

$$
|\mathcal F|\le 2|\mathcal F_x|.
$$

**Proof sketch.** Encode each subset of $U$ by a three-bit mask, so a family is an eight-bit mask. Enumerate all $256$ family masks. For each family, test all ordered pairs of included subsets and retain it only if the bitwise union of each pair is also included. Then test that at least one included subset is nonempty and that the three singleton masks are absent. For every family satisfying these conditions, count the included masks carrying each of the three coordinate bits. Direct exhaustive evaluation shows that at least one coordinate count $d$ satisfies $2d\ge|\mathcal F|$. Because the search space is finite and every candidate and condition is enumerated exactly, this establishes the universal residual statement. $\square$

The role of this lemma is deliberately limited. It does not substitute finite search for structure everywhere; it handles precisely the branch left after the singleton injection has removed all families containing a singleton.

**Theorem 5.2 (Frankl's property on three points).**  
Let $U$ be a three-element set, and let $\mathcal F\subseteq\mathcal P(U)$ be union-closed with at least one nonempty member. Then there exists an element $x$ occurring in a member of $\mathcal F$ such that

$$
|\mathcal F|\le 2|\mathcal F_x|.
$$

**Proof.** If $\mathcal F$ contains a singleton $\{x\}$, Theorem 4.1 proves that $x$ is abundant, and $x$ plainly occurs in a member. Otherwise, the hypotheses of Lemma 5.1 hold, and its exhaustive conclusion supplies an abundant coordinate. Since the family has a nonempty member, the successful coordinate can be taken from the active universe of $\mathcal F$, so it occurs in at least one member. $\square$

The theorem is invariant under relabeling, so proving it for $\{0,1,2\}$ proves it for every three-element universe.

### 5.1. Why the decomposition matters

A direct search over $256$ families is possible, but the split conveys mathematical information. The singleton branch explains abundance through an injection valid on universes of every size. Only the no-singleton branch is intrinsically bounded. This pattern suggests a scalable strategy: prove broad structural reductions, then enumerate the smaller irreducible residue.

The residual hypothesis also changes the shape of the search. On three points, excluding singletons leaves only the empty set, the three two-element sets, and the full three-element set as possible members. Unions of distinct two-element sets equal the full set, so union-closure immediately links the middle layer to the top. This makes the remaining incidence patterns highly constrained: each two-element member contributes two coordinate occurrences, while the top contributes one occurrence to every coordinate. Exhaustive evaluation certifies all edge cases, including families that do or do not contain the empty set. The empty set changes the denominator $|\mathcal F|$ without contributing to any frequency, so it cannot simply be ignored; this is one reason exact enumeration is useful even when the broad combinatorial picture is transparent.

## 6. Exact enumeration on the Boolean cube

Let $S$ be an $n$-element set. The family $\mathcal P(S)$ is union-closed and contains every singleton whenever $n>0$. We now derive sharper exact statements.

**Lemma 6.1 (Cardinality of the power set).**  
For every finite $S$ with $|S|=n$,

$$
|\mathcal P(S)|=2^n.
$$

**Proof sketch.** Each subset is determined independently by deciding, for each of the $n$ elements, whether it is absent or present. There are two choices per coordinate and therefore $2^n$ subsets. $\square$

**Lemma 6.2 (Exact coordinate frequency).**  
If $x\in S$ and $n\ge1$, then exactly $2^{n-1}$ subsets of $S$ contain $x$.

**Proof.** The map $A\mapsto A\cup\{x\}$ is a bijection from subsets missing $x$ to subsets containing $x$, with inverse $B\mapsto B\setminus\{x\}$. The remaining $n-1$ elements can be chosen arbitrarily, producing $2^{n-1}$ subsets in either class. $\square$

**Corollary 6.3 (Abundance in the Boolean lattice).**  
Every $x\in S$ belongs to exactly half the members of $\mathcal P(S)$ and is therefore abundant. If $S$ is nonempty, $\mathcal P(S)$ has Frankl's property.

**Theorem 6.4 (Total subset-size identity).**  
For an $n$-element set $S$,

$$
\sum_{A\subseteq S}|A|=n2^{n-1}
$$

for $n\ge1$. Equivalently, in a form valid without division and including $n=0$,

$$
2\sum_{A\subseteq S}|A|=n2^n.
$$

**Proof.** Count the incidence set

$$
I=\{(x,A):x\in S,\ A\subseteq S,\ x\in A\}
$$

in two ways. Grouping by $A$ gives

$$
|I|=\sum_{A\subseteq S}|A|.
$$

Grouping by $x$ and applying Lemma 6.2 gives

$$
|I|=\sum_{x\in S}2^{n-1}=n2^{n-1}
$$

when $n\ge1$. Multiplying by $2$ and using Lemma 6.1 gives the division-free identity. For $n=0$, both sides of that identity are $0$. $\square$

**Corollary 6.5 (Exact average size).**  
The average size of a member of $\mathcal P(S)$ is $n/2$:

$$
\frac{1}{2^n}\sum_{A\subseteq S}|A|=\frac n2.
$$

A standard average-size bound for union-closed families has the scale $\frac12\log_2|\mathcal F|$. On the Boolean cube,

$$
\frac12\log_2|\mathcal P(S)|=\frac12\log_2(2^n)=\frac n2,
$$

which equals the average just computed. Thus the cube realizes the exact equality pattern. The claim here is the cube identity, not a proof of the general average-size inequality.

## 7. Algorithms and numerical demonstrations

### 7.1. Exhaustive verification on a fixed universe

For a universe of size $n$, represent subsets by integers from $0$ to $2^n-1$. Bitwise OR computes union. Represent a family by a bit mask of length $2^n$.

**Algorithm 7.1 (Finite union-closed verifier).**

1. Enumerate all family masks $M$ from $0$ to $2^{2^n}-1$.
2. Decode the included subset masks.
3. Skip $M$ unless it includes a nonempty subset.
4. For every included pair $A,B$, check that $A\mathbin{\mathrm{OR}}B$ is included.
5. For each coordinate $x$, count included subsets whose $x$-bit is $1$.
6. Report a counterexample if every count $d_x$ satisfies $2d_x<|\mathcal F|$.

For fixed $n$, a straightforward implementation takes

$$
O\!\left(2^{2^n}4^n\right)
$$

time in the worst case: there are $2^{2^n}$ families and at most $4^n$ ordered pairs of subsets per family. Space is $O(2^n)$. This double-exponential growth limits naive use to very small universes. The singleton reduction can skip all families containing a singleton and certify them structurally.

For $n=3$, the algorithm visits $256$ family masks. It confirms Theorem 5.2 and can also count how many families satisfy each filter.

### 7.2. Boolean-cube incidence counter

To demonstrate Theorem 6.4 numerically, enumerate all $2^n$ subsets, sum their bit counts, and tally coordinate frequencies. This takes $O(n2^n)$ time and $O(n)$ auxiliary space if subsets are streamed. The expected output is total incidence $n2^{n-1}$ for $n\ge1$ and coordinate frequencies all equal to $2^{n-1}$.

### 7.3. Testing the top member

Given a finite family, compute the union of all members in $O(n|\mathcal F|)$ bit operations. If the family is nonempty and union-closed, Theorem 3.1 says that this union must already appear as a member. This is both a structural certificate and a useful preliminary consistency check.

## 8. An information-theoretic companion: Euler's constant

The remaining results concern a distinct bridge between analysis and information theory. They are included because they exhibit another exact decomposition into nonnegative local terms.

For positive rates $\lambda$ and $\mu$, define the exponential divergence

$$
D_{\mathrm{Exp}}(\lambda\|\mu)
=\log\frac{\lambda}{\mu}+\frac{\mu}{\lambda}-1.
$$

This is the Kullback--Leibler divergence from the exponential distribution of rate $\lambda$ to that of rate $\mu$.

**Theorem 8.1 (Nonnegativity).**  
For all $\lambda,\mu>0$,

$$
D_{\mathrm{Exp}}(\lambda\|\mu)\ge0.
$$

**Proof.** Set $t=\mu/\lambda>0$. The classical inequality $\log t\le t-1$ is equivalent to $-\log t+t-1\ge0$. Since

$$
D_{\mathrm{Exp}}(\lambda\|\mu)
=-\log t+t-1,
$$

the result follows. $\square$

Define

$$
g_k=\frac1{k+1}-\log\frac{k+2}{k+1}
$$

for $k\ge0$. The same logarithmic inequality shows $g_k\ge0$.

**Lemma 8.2 (Consecutive-rate identity).**  
For every integer $k\ge0$,

$$
D_{\mathrm{Exp}}(k+1\|k+2)=g_k.
$$

**Proof.** Substitute $\lambda=k+1$ and $\mu=k+2$:

$$
D_{\mathrm{Exp}}(k+1\|k+2)
=\log\frac{k+1}{k+2}+\frac{k+2}{k+1}-1.
$$

Use $\log((k+1)/(k+2))=-\log((k+2)/(k+1))$ and $(k+2)/(k+1)-1=1/(k+1)$. $\square$

Let $H_n=\sum_{j=1}^n1/j$ denote the $n$th harmonic number.

**Theorem 8.3 (Finite accumulated divergence).**  
For every $n\ge0$,

$$
\sum_{k=0}^{n-1}D_{\mathrm{Exp}}(k+1\|k+2)
=H_n-\log(n+1).
$$

**Proof.** By Lemma 8.2, the left-hand side is

$$
\sum_{k=0}^{n-1}\frac1{k+1}
-
\sum_{k=0}^{n-1}\log\frac{k+2}{k+1}.
$$

The first sum is $H_n$. The second telescopes under the logarithm:

$$
\sum_{k=0}^{n-1}\log\frac{k+2}{k+1}
=\log\prod_{k=0}^{n-1}\frac{k+2}{k+1}
=\log(n+1).
$$

This proves the identity. $\square$

Define the Euler--Mascheroni constant by

$$
\gamma=\lim_{n\to\infty}\bigl(H_n-\log(n+1)\bigr).
$$

This indexing is equivalent to the usual definition.

**Theorem 8.4 (Euler--Mascheroni information identity).**  
The series of consecutive exponential divergences converges, and

$$
\sum_{k=0}^{\infty}D_{\mathrm{Exp}}(k+1\|k+2)=\gamma.
$$

**Proof.** Every summand is nonnegative by Theorem 8.1. By Theorem 8.3, the $n$th partial sum is $H_n-\log(n+1)$, which converges to $\gamma$ by definition. $\square$

This identity interprets $\gamma$ as cumulative information loss along the chain of exponential rates $1,2,3,\ldots$. The partial sums are monotone because each divergence is nonnegative.

## 9. Applications and interpretation

### 9.1. Structural preprocessing

The greatest-member theorem supplies a canonical ground set. Any finite union-closed problem can be normalized to the top member $T$, eliminating irrelevant ambient elements. In computational searches, checking that $T$ belongs to the family is also a rapid necessary condition for nonempty union-closed input.

### 9.2. Certificate-based search

The singleton theorem gives a short certificate of Frankl's property: exhibit $\{x\}\in\mathcal F$, then use the map $A\mapsto A\cup\{x\}$. Search procedures should remove this entire class before expensive enumeration. Similar certificates based on generators or other small members could reduce larger universes.

### 9.3. Benchmarking average-size inequalities

The Boolean cube is an exact calibration object. Any proposed strengthening of an average-size lower bound must respect

$$
\operatorname{avg}_{A\subseteq S}|A|=\frac n2
$$

and $|\mathcal P(S)|=2^n$. The division-free identity

$$
2\sum_{A\subseteq S}|A|=n|\mathcal P(S)|
$$

is particularly useful in discrete computations because it avoids floating-point logarithms and rational arithmetic.

### 9.4. Information accumulation

The exponential-divergence identity supplies an interpretation of the Euler--Mascheroni constant and a stable sequence of lower approximations. Computing the first $n$ divergences yields $H_n-\log(n+1)$, and nonnegativity ensures monotonicity. This is useful pedagogically and for comparing analytic and information-theoretic quantities.

### 9.5. Reproducibility of finite claims

A finite verification is most informative when its encoding is explicit. The bit-mask model has no hidden sampling step: each integer from $0$ through $2^{2^n}-1$ names exactly one family, and every family has exactly one name. Bitwise OR agrees exactly with set union. Frequency is a bit count restricted to included masks. Thus an independent implementation can reproduce the three-point calculation from the definitions alone. It should separately report the number of all families, the number satisfying union closure and nontriviality, the no-singleton residue, and whether any retained family lacks an abundant coordinate. These intermediate counts guard against omitted cases or an incorrectly interpreted threshold.

## 10. Limitations and future work

The unrestricted union-closed sets conjecture is not established here. The three-point result is complete but finite, while the singleton theorem covers only families containing a singleton. The Boolean-cube identities concern a highly symmetric family and do not by themselves force abundance in arbitrary union-closed families.

Several concrete next problems arise.

1. **Four-point universe.** Prove that every nontrivial union-closed subfamily of a four-point power set has Frankl's property. Exhaustive search remains finite, but a structural decomposition would be preferable.

2. **Five-point families without singletons.** The singleton theorem already handles one branch. Isolating and verifying the no-singleton residue would settle the five-point case in the same conceptual style.

3. **Two-generator families.** Analyze the union-closure generated by two finite sets $A$ and $B$. Points in $A\cap B$ are natural abundance candidates; when $A\cap B=\varnothing$, one seeks a witness in $A\cup B$.

4. **Exact Boolean-cube frequency.** The identity $|\mathcal P(S)_x|=2^{|S|-1}$ for $x\in S$ sharpens abundance from an inequality to equality and should remain a standard reusable counting lemma.

5. **Adjoining the top member.** Determine precise conditions under which an abundant element remains abundant after adding the union of all members. Cardinality parity may affect the threshold.

Algorithmically, symmetry reduction under permutations of the universe, canonical representatives, and branch-and-bound pruning are natural ways to move beyond naive double-exponential enumeration. Mathematically, the central challenge remains to discover injections or order-theoretic constraints that survive without singleton assumptions.

## 11. Conclusion

Three complementary mechanisms govern the results in this paper. Iterated union creates a greatest member and reveals a finite lattice with top. Union with a singleton creates an injection from sets missing an element to sets containing it. Coordinate toggling in the Boolean cube creates a bijection and exact incidence balance. On a three-point universe, the injection handles the structural branch and exhaustive finite analysis closes the residue.

These results establish concrete pieces of the union-closed landscape without overstating the unresolved general case. They also show why the problem remains compelling: an elementary closure operation repeatedly generates strong global structure, yet a universal abundance mechanism is still missing. The companion information identity reinforces the broader lesson that global constants and inequalities can emerge from well-chosen nonnegative local increments. Finding the corresponding universal increment, pairing, or lattice certificate for union-closed families remains an open direction.
