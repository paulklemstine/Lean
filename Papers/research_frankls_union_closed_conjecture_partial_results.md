# Structural and Enumerative Results for Frankl’s Union-Closed Sets Conjecture

**Aristotle**  
**July 29, 2026**

## Abstract

A finite family of finite sets is union-closed when it contains the union of every pair of its members. Frankl’s conjecture asserts that every such family with a nonempty member has an element occurring in at least half of its members. This paper develops a self-contained collection of partial results and complementary viewpoints. First, an explicit injection proves the conjecture whenever the family contains a singleton. Second, combining that injection with a finite residual classification proves the conjecture for every family on a three-element universe. Third, every nonempty finite union-closed family is shown to contain the union of all its members, giving a finite join-semilattice with a greatest element. Finally, exact double counting on the Boolean cube establishes that the sum of all subset sizes is $n2^{n-1}$ and hence that the average subset size is $n/2$. This identifies the full Boolean lattice as an equality example for the benchmark $\tfrac12\log_2|\mathcal F|$ in Reimer’s average-size inequality. Algorithms for testing union-closure, abundance, the three-point theorem, and the cube identities are stated explicitly, together with their complexity. The results separate structural arguments from bounded enumeration and provide a foundation for higher-dimensional, lattice-theoretic, and entropy-based investigations.

## 1. Introduction

Let $U$ be a finite set and let $\mathcal F\subseteq\mathcal P(U)$ be a finite family. The family is **union-closed** if

$$
A,B\in\mathcal F\implies A\cup B\in\mathcal F.
$$

Frankl’s union-closed sets conjecture states that if at least one member of $\mathcal F$ is nonempty, then some element of $U$ belongs to at least half the members of $\mathcal F$. In frequency notation, if

$$
d_{\mathcal F}(x)=|\{A\in\mathcal F:x\in A\}|,
$$

then the conjecture asks for an element $x$ occurring in a member of $\mathcal F$ such that

$$
d_{\mathcal F}(x)\ge \frac{|\mathcal F|}{2}.
$$

Because frequencies are integral, it is often preferable to avoid division and write the equivalent condition

$$
2d_{\mathcal F}(x)\ge |\mathcal F|.
$$

The conjecture is simple to state but structurally subtle. Union-closure controls upward combinations, not deletions or intersections. A family may omit the empty set, singletons, and many intermediate subsets. Consequently, the symmetry of a full power set cannot be assumed in general.

This paper establishes four groups of results. The first is a direct injection theorem: the presence of a singleton $\{a\}$ forces $a$ to be abundant. The second settles the conjecture on a three-element universe by splitting into a singleton branch and a finite no-singleton residue. The third gives the lattice-theoretic structure common to all nonempty finite union-closed families: the union of all members is itself a member and is greatest under inclusion. The fourth studies the full Boolean lattice, proving exact cardinality and incidence identities and deriving its average member size.

The scope is intentionally precise. The general Frankl conjecture is not claimed. Nor is a proof of Reimer’s average-size inequality supplied. Instead, the Boolean-cube equality underlying its sharpness is proved by elementary double counting. Likewise, the three-point theorem is complete, while larger-universe and bounded-family results remain future objectives.

## 2. Definitions and elementary counting

### 2.1. Union-closed families and abundance

**Definition 2.1 (Union-closed family).** A finite family $\mathcal F$ of finite subsets of a universe $U$ is union-closed if, for all $A,B\in\mathcal F$, the set $A\cup B$ also belongs to $\mathcal F$.

**Definition 2.2 (Containing subfamily and frequency).** For $x\in U$, define

$$
\mathcal F_x=\{A\in\mathcal F:x\in A\},
\qquad d_{\mathcal F}(x)=|\mathcal F_x|.
$$

Also define the avoiding subfamily

$$
\mathcal F_{\bar x}=\{A\in\mathcal F:x\notin A\}.
$$

**Definition 2.3 (Abundant element).** An element $x$ is abundant in $\mathcal F$ if

$$
|\mathcal F|\le 2|\mathcal F_x|.
$$

**Definition 2.4 (Frankl property).** A family $\mathcal F$ has the Frankl property if there exists an element $x$ lying in at least one member of $\mathcal F$ and abundant in $\mathcal F$.

Requiring $x$ to occur in some member prevents irrelevant points outside the effective universe $\bigcup\mathcal F$ from serving as witnesses.

**Lemma 2.5 (Frequency partition).** For every finite family $\mathcal F$ and every element $x$,

$$
|\mathcal F|=|\mathcal F_x|+|\mathcal F_{\bar x}|.
$$

**Proof sketch.** Every member either contains $x$ or avoids $x$, and no member does both. Thus the two subfamilies form a disjoint partition of $\mathcal F$. $\square$

**Lemma 2.6 (Abundance in a nonempty family produces a witness).** If $\mathcal F$ is nonempty and $x$ is abundant, then some member of $\mathcal F$ contains $x$.

**Proof sketch.** If no member contained $x$, then $|\mathcal F_x|=0$. Abundance would imply $|\mathcal F|\le 0$, contradicting nonemptiness. $\square$

This lemma is useful when abundance is obtained numerically before membership of the witness has been recorded explicitly.

## 3. The singleton injection

The strongest general structural result considered here is triggered by the presence of a singleton.

**Theorem 3.1 (Singleton Injection Theorem).** Let $\mathcal F$ be a finite union-closed family. If $\{a\}\in\mathcal F$, then $a$ is abundant:

$$
|\mathcal F|\le 2|\mathcal F_a|.
$$

**Proof.** Partition $\mathcal F$ into

$$
\mathcal S=\mathcal F_{\bar a}
\quad\text{and}\quad
\mathcal T=\mathcal F_a.
$$

Define a map $\Phi:\mathcal S\to\mathcal T$ by

$$
\Phi(A)=A\cup\{a\}.
$$

For $A\in\mathcal S$, both $A$ and $\{a\}$ belong to $\mathcal F$. Union-closure therefore gives $A\cup\{a\}\in\mathcal F$, and this image contains $a$, so it lies in $\mathcal T$.

The map is injective. If $A,B\in\mathcal S$ and

$$
A\cup\{a\}=B\cup\{a\},
$$

then $a\notin A$ and $a\notin B$. Removing $a$ from both sides yields $A=B$. Hence

$$
|\mathcal S|\le |\mathcal T|.
$$

By Lemma 2.5,

$$
|\mathcal F|=|\mathcal S|+|\mathcal T|
\le 2|\mathcal T|
=2|\mathcal F_a|.
$$

Thus $a$ is abundant. $\square$

**Corollary 3.2 (Frankl property in the singleton case).** If a union-closed family contains a singleton, then it has the Frankl property.

**Proof sketch.** The element of that singleton belongs to a member of the family and is abundant by Theorem 3.1. $\square$

The proof gives more than a frequency inequality: it supplies an explicit matching of all members avoiding $a$ into distinct members containing $a$. The condition that $A$ avoids $a$ is exactly what makes adjoining $a$ reversible.

**Example 3.3.** Let

$$
\mathcal F=\{\varnothing,\{a\},\{b,c\},\{a,b,c\}\}.
$$

This family is union-closed. The sets avoiding $a$ are $\varnothing$ and $\{b,c\}$; adjoining $a$ maps them respectively to $\{a\}$ and $\{a,b,c\}$. Hence $a$ occurs in exactly half the family.

A tempting generalization would replace the singleton by an arbitrary smallest member and attempt to adjoin one of its elements. Such a map need not be injective: adding a point to two sets may erase their distinction when one already contains related elements. Thus the singleton hypothesis captures a genuinely stable mechanism and should not be weakened without additional structure.

## 4. The three-element universe

Let $U$ be a set with exactly three elements. Up to relabeling, take $U=\{0,1,2\}$. There are $2^3=8$ subsets of $U$ and therefore $2^8=256$ families of subsets.

### 4.1. Residual finite lemma

**Lemma 4.1 (No-singleton three-point lemma).** Let $\mathcal F\subseteq\mathcal P(U)$, where $|U|=3$. Suppose that:

1. $\mathcal F$ is union-closed;
2. $\mathcal F$ contains a nonempty member; and
3. $\mathcal F$ contains no singleton.

Then some $x\in U$ satisfies

$$
|\mathcal F|\le 2|\mathcal F_x|.
$$

**Proof sketch.** The claim is a finite exhaustive statement. Enumerate the eight subsets of $U$ by masks from $0$ to $7$, and enumerate a candidate family by a mask from $0$ to $255$. For each candidate, test all ordered pairs of selected subset masks $A,B$ and require the bit corresponding to $A\cup B$ to be selected. Reject candidates without a nonempty member or with any of the three singleton masks selected. For every remaining candidate, count selected masks containing each coordinate and verify that the maximum frequency $m$ satisfies $2m\ge |\mathcal F|$. This exhausts every family on the labeled three-point universe. Relabeling preserves union-closure and frequencies, so it also covers any three-element universe. $\square$

The exhaustive step is modest but exact: there are only $256$ candidates, each requiring at most $8^2=64$ closure checks and $3\cdot8=24$ incidence tests.

### 4.2. Complete theorem in dimension three

**Theorem 4.2 (Frankl’s conjecture for a three-element universe).** Every union-closed family of subsets of a three-element universe that contains a nonempty member has the Frankl property.

**Proof.** Let $\mathcal F$ satisfy the hypotheses. There are two cases.

If $\mathcal F$ contains a singleton $\{x\}$, Theorem 3.1 shows that $x$ is abundant, and $x$ plainly lies in a member of the family.

If $\mathcal F$ contains no singleton, Lemma 4.1 supplies an abundant element $x$. Since $\mathcal F$ contains a nonempty member, it is nonempty; Lemma 2.6 then shows that some member contains $x$. Thus $x$ witnesses the Frankl property. $\square$

The proof deliberately separates a reusable infinite-pattern argument from bounded enumeration. Families containing singletons are handled uniformly for every universe size; only the no-singleton residue uses the three-point bound.

### 4.3. A small residual example

Consider

$$
\mathcal F=\bigl\{\{0,1\},\{0,2\},\{0,1,2\}\bigr\}.
$$

It contains no singleton and is union-closed. Frequencies are

$$
d_{\mathcal F}(0)=3,
\qquad d_{\mathcal F}(1)=2,
\qquad d_{\mathcal F}(2)=2.
$$

All three elements are abundant because $2d_{\mathcal F}(x)\ge3$. The finite lemma covers less transparent configurations as well, including families containing the empty set and various selections of two-element members.

## 5. Join-semilattice structure and the greatest member

Order the members of a family by inclusion. For any two sets $A$ and $B$, their union is their least upper bound in the ambient power set. When the family is union-closed, this join remains inside the family.

**Definition 5.1 (Finite join-semilattice viewpoint).** A union-closed family $\mathcal F$, ordered by inclusion, is a finite partially ordered set in which every pair has a join given by $A\vee B=A\cup B$.

Finiteness and nonemptiness force a top element.

**Theorem 5.2 (Greatest-Member Theorem).** Let $\mathcal F$ be a nonempty finite union-closed family. Define

$$
T=\bigcup_{A\in\mathcal F}A.
$$

Then $T\in\mathcal F$, and for every $A\in\mathcal F$ one has $A\subseteq T$. Consequently, $T$ is the greatest member of $\mathcal F$.

**Proof.** Enumerate the nonempty finite family as $A_1,\ldots,A_m$. Define successive unions

$$
T_1=A_1,
\qquad
T_{k+1}=T_k\cup A_{k+1}.
$$

By induction, $T_k\in\mathcal F$: the base case is immediate, and the induction step follows from union-closure. Therefore $T_m\in\mathcal F$. Associativity of union gives

$$
T_m=A_1\cup\cdots\cup A_m
=\bigcup_{A\in\mathcal F}A=T.
$$

Each $A_i$ is included in this union, so every member lies below $T$. $\square$

**Corollary 5.3.** Every nonempty finite union-closed family is a finite join-semilattice with a greatest element.

This reformulation suggests translating element frequency into order-theoretic data. For each ground element $x$, the subfamily $\mathcal F_x$ is upward closed inside $\mathcal F$: if $A\in\mathcal F_x$ and $A\subseteq B\in\mathcal F$, then $x\in B$. Frankl’s property asks whether at least one such incidence filter has size at least $|\mathcal F|/2$. Different ground elements may define the same filter; identifying them is a natural separating reduction.

## 6. Boolean lattices and exact average size

Let $U$ be an $n$-element set and consider the full Boolean lattice $\mathcal P(U)$. It is union-closed because the union of two subsets of $U$ is again a subset of $U$.

**Lemma 6.1 (Cardinality of the Boolean lattice).** If $|U|=n$, then

$$
|\mathcal P(U)|=2^n.
$$

**Proof sketch.** Each element of $U$ is independently either included or excluded, giving two choices for each of $n$ coordinates. $\square$

**Lemma 6.2 (Half-cube frequency).** For every $x\in U$,

$$
|\{A\subseteq U:x\in A\}|=2^{n-1}
$$

when $n\ge1$.

**Proof sketch.** Once $x$ is required to be present, the remaining $n-1$ elements can be chosen freely. Equivalently, adjoining $x$ bijects subsets avoiding $x$ with subsets containing $x$. $\square$

**Theorem 6.3 (Boolean-Cube Incidence Identity).** For an $n$-element universe,

$$
\sum_{A\subseteq U}|A|=n2^{n-1},
$$

where for $n=0$ the right-hand side is interpreted as $0$.

**Proof.** Count the incidence set

$$
I=\{(x,A):x\in U,\ A\subseteq U,\ x\in A\}
$$

in two ways. Fixing $A$ gives $|A|$ possible first coordinates, hence

$$
|I|=\sum_{A\subseteq U}|A|.
$$

For $n\ge1$, fixing $x$ gives $2^{n-1}$ subsets containing it by Lemma 6.2. Summing over $n$ elements gives $|I|=n2^{n-1}$. If $n=0$, the only subset is empty and both sides are zero. $\square$

**Theorem 6.4 (Exact Cube Average and Reimer Equality Benchmark).** For the full Boolean lattice on an $n$-element universe,

$$
2\sum_{A\subseteq U}|A|=n|\mathcal P(U)|.
$$

Consequently its average member size is $n/2$.

**Proof.** By Theorem 6.3 and Lemma 6.1, the two sides are respectively

$$
2n2^{n-1}
\quad\text{and}\quad
n2^n,
$$

which are equal. Dividing by $2|\mathcal P(U)|$ gives the average $n/2$. $\square$

Reimer’s average-size inequality states that a finite union-closed family $\mathcal F$ has average member size at least

$$
\frac12\log_2|\mathcal F|.
$$

For $\mathcal F=\mathcal P(U)$, Lemma 6.1 gives $\log_2|\mathcal F|=n$, while Theorem 6.4 gives average size $n/2$. Thus the Boolean cube realizes equality in that benchmark. The present argument proves the equality computation for the cube; it does not supply the general entropy inequality.

**Corollary 6.5 (Frankl property for nontrivial Boolean lattices).** If $U$ is nonempty, then every $x\in U$ is abundant in $\mathcal P(U)$, and hence $\mathcal P(U)$ has the Frankl property.

**Proof.** Lemmas 6.1 and 6.2 give

$$
2d_{\mathcal P(U)}(x)=2\cdot2^{n-1}=2^n=|\mathcal P(U)|.
$$

Thus every point is exactly abundant. Alternatively, each singleton belongs to the power set, so Theorem 3.1 gives abundance directly. $\square$

## 7. Algorithms and computational demonstrations

### 7.1. Bit-mask representation

For a universe $U=\{0,\ldots,n-1\}$, represent a subset $A$ by the integer

$$
\operatorname{mask}(A)=\sum_{i\in A}2^i.
$$

Then set union is bitwise OR, membership of $i$ is detected by the $i$th bit, and cardinality is the population count. A family may be stored as a list or set of subset masks.

### 7.2. Testing union-closure

**Algorithm 7.1 (Pairwise Union-Closure Test).** Given a family of $m$ subset masks, store them in a hash set. For every ordered pair $(A,B)$, compute $A\mathbin{\mathrm{OR}}B$ and test membership in the hash set. Return false on the first missing union and true if all tests pass.

The running time is $O(m^2)$ expected time with constant-time fixed-width bit operations and hash lookup, and the storage is $O(m)$. With arbitrary-length masks, bit-operation costs introduce a factor depending on $n$.

### 7.3. Finding an abundant element

**Algorithm 7.2 (Incidence Frequency Scan).** Initialize $n$ counters to zero. For each member $A$ and each coordinate $x$, increment the $x$th counter if $x\in A$. Return all $x$ satisfying $2d_{\mathcal F}(x)\ge m$.

The direct running time is $O(nm)$ and storage is $O(n)$. Iterating only over set bits can improve performance on sparse families.

### 7.4. Exhausting the three-point universe

**Algorithm 7.3 (Three-Point Residual Enumerator).** Enumerate all $256$ family masks. Decode each into selected subset masks among $0,1,2,3,4,5,6,7$; test union-closure; require a nonempty member; optionally separate candidates containing singleton masks $1$, $2$, or $4$; and apply the frequency scan. The theorem is confirmed when no qualifying family lacks an abundant point.

More generally, exhaustive enumeration on an $n$-element universe examines $2^{2^n}$ families, so its worst-case complexity is doubly exponential in $n$. This explains why structural reductions become essential already at $n=4$, where there are $2^{16}=65{,}536$ candidate families.

### 7.5. Verifying cube identities

**Algorithm 7.4 (Boolean-Cube Incidence Counter).** Enumerate the $2^n$ masks, add each population count, and compare the result with $n2^{n-1}$, treating $n=0$ separately. Simultaneously count each coordinate frequency and compare it with $2^{n-1}$.

The running time is $O(2^n)$ if population count is treated as constant time on machine words, or $O(n2^n)$ with elementary bit inspection. The algorithm is illustrative rather than necessary for the proof, which follows directly from double counting.

## 8. Applications and interpretation

Union-closed families arise whenever admissible states are stable under aggregation. In a capability system, a set may list permissions and union may combine two roles. In a distributed knowledge model, a set may record facts held by an agent and union may represent merged information. In feature engineering, sets may encode active features and closure may express availability of combined profiles. Frankl’s property then predicts a feature occurring in at least half the admissible states.

The greatest-member theorem has an immediate interpretation: repeated aggregation reaches a state containing every feature that appears anywhere in the system, and that state is itself admissible. The singleton theorem says that if an isolated capability is admissible, then that capability must occur in at least half the admissible aggregate states. The Boolean cube represents independent binary features; exact half-frequency and average size $n/2$ are then the expected symmetry laws.

These interpretations should not be mistaken for a proof of the general conjecture in applications. They instead clarify which hypotheses supply which conclusions. Closure supplies the top state. A singleton supplies an injection and abundance. Full independence supplies exact balance. Three coordinates permit complete classification.

## 9. Discussion

The results expose three proof paradigms.

First, **injection** converts algebraic closure into a cardinal comparison. Its strength lies in being explicit and dimension-free. Searching for other reversible maps remains attractive, but the singleton case warns that adding multiple elements can destroy recoverability.

Second, **structural decomposition followed by enumeration** isolates the part of a small theorem that is conceptually uniform. The three-point proof does not hide all reasoning inside exhaustive search: it removes every singleton-containing family by a general theorem and searches only the no-singleton residue.

Third, **double counting** connects coordinate frequencies with average set size. On the Boolean cube it yields an exact identity. In a general family,

$$
\sum_{A\in\mathcal F}|A|=\sum_{x\in U}d_{\mathcal F}(x),
$$

so a lower bound on average size constrains the total frequency. Translating such aggregate information into one frequency of at least $|\mathcal F|/2$ is the central difficulty.

The order-theoretic formulation may organize this translation. Each coordinate determines an upward-closed subfamily, and coordinates with identical containing subfamilies are indistinguishable. Quotienting these duplicate incidence columns preserves member frequencies while reducing the effective universe. Such separating reductions are natural prerequisites for larger finite bounds.

## 10. Future work

Several concrete extensions follow from the present foundation.

1. **Universe size four.** The singleton/residual decomposition remains available. There are $65{,}536$ candidate families before reductions, suggesting classification under permutations, separation of duplicate incidence columns, and complement-based pruning.

2. **Families with at most fifty members.** A treatment of the Bošnjak–Marković bound would require separating reductions, frequency constraints, and certified finite classification of the remaining configurations. No such bound is asserted here.

3. **Abstract semilattices.** One can package the family directly as a finite join-subsemilattice with top and formulate frequencies through principal incidence filters.

4. **Entropy infrastructure.** A self-contained route to the general average-size inequality would develop finite Shannon entropy, the chain rule, an appropriate form of Shearer’s inequality, and the connection between incidence-vector entropy and average member size.

5. **Equality and stability.** The cube identities hold for every finite universe, not merely a chosen labeling. A deeper question is whether families whose average size is close to the Boolean-cube benchmark must resemble a Boolean subcube.

6. **Controlled minimal-member injections.** The singleton map suggests studying small minimal members under additional hypotheses strong enough to retain injectivity. Any such extension must avoid the false unrestricted smallest-member heuristic.

## 11. Conclusion

A finite union-closed family always has a greatest member. If it contains a singleton, an explicit injection proves that the singleton’s element occurs in at least half the family. On a three-element universe, this structural case plus a finite no-singleton classification proves Frankl’s property completely. For the full Boolean lattice, every coordinate occurs exactly half the time, the total subset size is $n2^{n-1}$, and the average size is $n/2$, realizing the equality benchmark associated with Reimer’s inequality.

Together these results give exact answers in several natural regimes and distinguish the mechanisms responsible for them: closure under repeated joins, reversible singleton adjunction, bounded classification, and Boolean symmetry. The general conjecture asks for a mechanism that persists when none of the special features is present.