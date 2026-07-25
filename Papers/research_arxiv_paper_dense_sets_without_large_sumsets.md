# Finite First-Moment Criteria for Dense Sets Avoiding Prescribed Sumsets

**Aristotle**  
**July 25, 2026**

## Abstract

Let $U$ be a finite set and let $\mathcal F$ be a finite family of configurations contained in $U$. We develop an exact finite first-moment framework for finding a large subset $S\subseteq U$ that contains no member of $\mathcal F$. A fixed configuration $T\subseteq U$ is contained in exactly $2^{|U|-|T|}$ subsets of $U$, so a union bound controls all forbidden containment events. Combining this estimate with the exact lower-cardinality tail of the power set gives a deterministic dense-avoidance criterion. We then specialize to integer sumsets. The sharp inequality $|A+B|\geq |A|+|B|-1$ implies that a family of pairs with $|A|,|B|\geq k$ has total first-moment cost at most the number of pairs times $2^{|U|-(2k-1)}$. Consequently, whenever this cost plus the number of subsets smaller than a prescribed density threshold is less than $2^{|U|}$, a dense set exists that contains none of the prescribed sumsets. We give constructive exhaustive-search algorithms, numerical diagnostics, and extensions to biased random subsets. The framework isolates structural compression of candidate sumsets as the remaining obstacle to sharp logarithmic asymptotics.

## 1. Introduction

For finite integer sets $A$ and $B$, write

$$
A+B=\{a+b:a\in A,\ b\in B\}.
$$

A dense subset of a finite interval typically contains many individual sums. It is much more demanding, however, for it to contain every element of a large sumset $A+B$. This distinction motivates a finite avoidance problem: given an ambient set $U$, a cardinality threshold $d$, and a prescribed collection of additive configurations, when can one guarantee a subset $S\subseteq U$ with $|S|\geq d$ that does not contain any complete prescribed sumset?

The answer separates into three independent components. First, containment of a fixed finite configuration can be counted exactly. Second, a finite union bound combines the costs of all forbidden configurations without any independence or disjointness assumptions. Third, additive growth over the integers supplies a lower bound on the size of each forbidden sumset. The resulting theorem is elementary but flexible: it applies to arbitrary finite universes and arbitrary finite families of prescribed pairs.

This finite formulation also clarifies the asymptotic problem of constructing dense subsets of $[n]=\{1,\ldots,n\}$ without large sumsets. The probability calculation itself is exact and uncomplicated. The quantitative difficulty is the number of candidate pairs. A direct union bound charges every pair separately, although many pairs may generate the same sumset or share a much smaller structural witness. Sharp asymptotic results therefore require a fingerprint or container mechanism that compresses candidate pairs before the finite criterion is applied.

The paper proceeds as follows. Section 2 fixes notation and introduces the relevant classes of subsets. Section 3 proves exact containment counting and the finite union bound. Section 4 combines these facts with a lower-cardinality tail. Section 5 develops the additive specialization. Section 6 gives algorithms and examples. Section 7 discusses probabilistic variants, limitations, and structural compression. Sections 8 and 9 present applications and future directions.

## 2. Definitions and notation

Throughout, all sets and families are finite unless explicitly stated otherwise. Let $U$ be a finite universe and put $N=|U|$. Its power set is denoted $2^U$; thus $|2^U|=2^N$.

### Definition 2.1 (Lower-cardinality class)

For a nonnegative integer $d$, define

$$
\mathcal L(U,d)=\{S\subseteq U:|S|<d\}.
$$

Its cardinality depends only on $N$ and $d$ and is

$$
|\mathcal L(U,d)|=
\sum_{j=0}^{\min(d-1,N)}\binom Nj.
$$

When $d=0$, the sum is empty and equals $0$. If $d>N$, every subset is lower-cardinality and the displayed quantity equals $2^N$.

### Definition 2.2 (Forbidden-containment class)

For a family $\mathcal F\subseteq 2^U$, define

$$
\mathcal B(U,\mathcal F)=
\{S\subseteq U:\text{there exists }T\in\mathcal F\text{ with }T\subseteq S\}.
$$

A set outside $\mathcal B(U,\mathcal F)$ avoids $\mathcal F$: it contains no forbidden configuration in full.

### Definition 2.3 (Sumset family)

Let $\mathcal P$ be a finite family of ordered pairs $(A,B)$ of finite integer sets. Its associated family of sumsets is

$$
\Sigma(\mathcal P)=\{A+B:(A,B)\in\mathcal P\}.
$$

Different pairs are allowed to generate the same sumset. Hence $|\Sigma(\mathcal P)|\leq |\mathcal P|$, sometimes with a substantial inequality.

### Definition 2.4 (Containment cost)

For $T\subseteq U$, define its uniform containment cost by

$$
w_U(T)=2^{N-|T|}.
$$

For a family $\mathcal F\subseteq 2^U$, define

$$
W_U(\mathcal F)=\sum_{T\in\mathcal F}w_U(T)
=\sum_{T\in\mathcal F}2^{N-|T|}.
$$

After normalization by $2^N$, the cost is $\sum_{T\in\mathcal F}2^{-|T|}$.

## 3. Exact containment counting

The first result identifies the exact cost of one configuration.

### Theorem 3.1 (Exact superset count)

Let $T\subseteq U$. Then

$$
\bigl|\{S\subseteq U:T\subseteq S\}\bigr|=2^{N-|T|}.
$$

#### Proof sketch

Every set $S$ containing $T$ has a unique representation

$$
S=T\cup R,
$$

where $R\subseteq U\setminus T$. Conversely, every such $R$ determines a unique superset $S$. Since $|U\setminus T|=N-|T|$, there are $2^{N-|T|}$ choices for $R$.

The theorem has an immediate probabilistic interpretation. Under the uniform distribution on $2^U$, each element is included independently with probability $1/2$, and

$$
\Pr(T\subseteq S)=2^{-|T|}.
$$

### Theorem 3.2 (Finite containment union bound)

Let $\mathcal F$ be a finite family of subsets of $U$. Then

$$
|\mathcal B(U,\mathcal F)|
\leq \sum_{T\in\mathcal F}2^{N-|T|}.
$$

#### Proof sketch

For each $T\in\mathcal F$, let

$$
\mathcal C_T=\{S\subseteq U:T\subseteq S\}.
$$

By definition, $\mathcal B(U,\mathcal F)=\bigcup_{T\in\mathcal F}\mathcal C_T$. The cardinality of a finite union is at most the sum of the cardinalities of its members. Theorem 3.1 gives $|\mathcal C_T|=2^{N-|T|}$, yielding the claim.

No disjointness is asserted. Indeed, if $S$ contains several forbidden configurations, it is counted several times in the sum. Nor is probabilistic independence needed. Thus the bound remains valid for highly overlapping additive configurations.

### Corollary 3.3 (Uniform-size estimate)

If every $T\in\mathcal F$ has $|T|\geq r$, then

$$
|\mathcal B(U,\mathcal F)|
\leq |\mathcal F|\,2^{N-r}.
$$

#### Proof sketch

For each $T$, the inequality $|T|\geq r$ implies $N-|T|\leq N-r$ and hence $2^{N-|T|}\leq 2^{N-r}$. Sum this uniform bound over $\mathcal F$.

## 4. Dense finite avoidance

Containment avoidance alone is vacuous for nonempty configurations because the empty set succeeds. The next result incorporates an arbitrary cardinality threshold.

### Theorem 4.1 (Dense finite avoidance criterion)

Let $U$ be a finite set of size $N$, let $\mathcal F$ be a finite family of subsets of $U$, and let $d$ be a nonnegative integer. If

$$
|\mathcal L(U,d)|+
\sum_{T\in\mathcal F}2^{N-|T|}<2^N,
$$

then there exists $S\subseteq U$ satisfying

$$
|S|\geq d
$$

and

$$
T\nsubseteq S\qquad\text{for every }T\in\mathcal F.
$$

Equivalently, using the binomial tail, it suffices that

$$
\sum_{j=0}^{\min(d-1,N)}\binom Nj+
\sum_{T\in\mathcal F}2^{N-|T|}<2^N.
$$

#### Proof sketch

Every unsuccessful subset lies in

$$
\mathcal L(U,d)\cup\mathcal B(U,\mathcal F).
$$

The cardinality of this union is at most

$$
|\mathcal L(U,d)|+|\mathcal B(U,\mathcal F)|.
$$

Apply Theorem 3.2 to the second term. Under the strict inequality in the hypothesis, fewer than all $2^N$ subsets are unsuccessful. Therefore at least one subset is neither too small nor bad, which is the desired $S$.

### Corollary 4.2 (Uniform forbidden size)

If each forbidden configuration has size at least $r$ and

$$
\sum_{j=0}^{\min(d-1,N)}\binom Nj+
|\mathcal F|2^{N-r}<2^N,
$$

then a subset $S\subseteq U$ exists with $|S|\geq d$ and no forbidden configuration contained in $S$.

#### Proof sketch

Combine Corollary 3.3 with Theorem 4.1.

### Remark 4.3 (First-moment form)

Dividing the hypothesis of Theorem 4.1 by $2^N$ gives

$$
\Pr(|S|<d)+\sum_{T\in\mathcal F}2^{-|T|}<1
$$

for a uniformly random subset $S$. The first term is exact, while the second is a union-bound estimate. This proves positive probability of simultaneous density and avoidance. The theorem itself is deterministic: positive probability merely certifies existence.

### Remark 4.4 (Why strict inequality is natural)

The proof excludes the possibility that all subsets are unsuccessful by showing that the number of unsuccessful subsets is strictly smaller than $2^N$. Equality in the upper bound gives no information because the union bound may or may not be sharp.

## 5. Additive specialization over the integers

The general criterion becomes useful for sumsets once their cardinalities are controlled.

### Theorem 5.1 (Sharp growth of integer sumsets)

If $A$ and $B$ are nonempty finite subsets of $\mathbb Z$, then

$$
|A+B|\geq |A|+|B|-1.
$$

#### Proof sketch

Write

$$
A=\{a_1<a_2<\cdots<a_r\},
\qquad
B=\{b_1<b_2<\cdots<b_s\}.
$$

The following sequence lies in $A+B$:

$$
a_1+b_1<a_2+b_1<\cdots<a_r+b_1
<a_r+b_2<\cdots<a_r+b_s.
$$

It contains $r+s-1$ strictly increasing terms, proving the lower bound. If $A$ and $B$ are arithmetic progressions with the same common difference, equality may hold, so the constant is optimal.

### Corollary 5.2 (Threshold form)

If $A$ and $B$ are nonempty and $|A|\geq k$, $|B|\geq k$, then

$$
|A+B|\geq 2k-1.
$$

Equivalently,

$$
2k\leq |A+B|+1.
$$

#### Proof sketch

Apply Theorem 5.1 and substitute the two cardinality lower bounds.

### Proposition 5.3 (Uniform first-moment cost for prescribed sumsets)

Let $U\subseteq\mathbb Z$ be finite with $N=|U|$, and let $\mathcal P$ be a finite family of ordered pairs $(A,B)$ of nonempty finite integer sets. Suppose $|A|,|B|\geq k$ for every $(A,B)\in\mathcal P$. Then

$$
\sum_{(A,B)\in\mathcal P}
2^{N-|A+B|}
\leq
|\mathcal P|\,2^{N-(2k-1)}.
$$

#### Proof sketch

Corollary 5.2 gives $|A+B|\geq 2k-1$ for each pair. Hence every summand is at most $2^{N-(2k-1)}$. Summing the common upper bound over $|\mathcal P|$ pairs proves the result.

The proposition deliberately sums over pairs rather than distinct sumsets. If several pairs have the same sumset, the same event is charged repeatedly. Deduplicating can only improve the estimate.

### Theorem 5.4 (Additive dense-avoidance theorem)

Let $U\subseteq\mathbb Z$ be finite with $N=|U|$. Let $\mathcal P$ be a finite family of ordered pairs $(A,B)$ of nonempty finite integer sets such that

$$
A+B\subseteq U
$$

and

$$
|A|\geq k,
\qquad
|B|\geq k
$$

for every $(A,B)\in\mathcal P$. Let $d$ be a nonnegative integer. If

$$
\sum_{j=0}^{\min(d-1,N)}\binom Nj+
|\mathcal P|\,2^{N-(2k-1)}<2^N,
$$

then there exists $S\subseteq U$ such that $|S|\geq d$ and

$$
A+B\nsubseteq S
$$

for every $(A,B)\in\mathcal P$.

#### Proof sketch

Form the family of distinct forbidden sumsets

$$
\mathcal F=\Sigma(\mathcal P)=\{A+B:(A,B)\in\mathcal P\}.
$$

Every member of $\mathcal F$ lies in $U$. Its exact containment cost is $2^{N-|A+B|}$. Summing over distinct sumsets costs no more than summing over all generating pairs. Proposition 5.3 bounds the latter by $|\mathcal P|2^{N-(2k-1)}$. The assumed inequality therefore implies the hypothesis of Theorem 4.1. The resulting set $S$ has at least $d$ elements and contains no member of $\mathcal F$, exactly as required.

### Remark 5.5 (Nonemptiness is essential)

If $A=\varnothing$ or $B=\varnothing$, then $A+B=\varnothing$. The inequality $|A+B|\geq |A|+|B|-1$ is not meaningful as a useful positive growth estimate in that case, and every set contains the empty set. The nonemptiness hypothesis prevents this degeneracy.

### Remark 5.6 (Ambient containment is essential)

The event $A+B\subseteq S$ can occur for $S\subseteq U$ only if $A+B\subseteq U$. Sumsets extending outside $U$ are automatically avoided, but excluding them from the prescribed family keeps the cost formula and conclusion exact.

## 6. Algorithms and numerical diagnostics

The theorems are existential, but finite instances admit direct computation.

### 6.1 Computing the certificate

Given $N$, $d$, a family size $m=|\mathcal P|$, and a summand threshold $k$, compute

$$
C(N,d,m,k)=
\sum_{j=0}^{\min(d-1,N)}\binom Nj+
m\,2^{\max(N-(2k-1),0)}.
$$

When all sumsets genuinely lie in $U$ and have size at least $2k-1\leq N$, the theorem applies if $C(N,d,m,k)<2^N$. In exact implementations it is preferable to use actual sumset cardinalities and deduplicate the sumsets, producing the sharper cost

$$
C_{\mathrm{exact}}=
\sum_{j=0}^{\min(d-1,N)}\binom Nj+
\sum_{T\in\Sigma(\mathcal P)}2^{N-|T|}.
$$

Computing the binomial tail takes $O(d)$ arithmetic operations when binomial coefficients are updated recursively. Constructing one sumset naïvely costs $O(|A||B|)$ insertions into a hash set. Deduplication then uses a canonical immutable representation.

### 6.2 Exhaustive witness search

To find an actual witness, enumerate subsets of $U$ in nondecreasing cardinality beginning at $d$. Reject a candidate $S$ if any forbidden sumset $T$ satisfies $T\subseteq S$. The worst-case search is exponential, examining at most $2^N$ candidates. With bit masks, containment is the constant-time operation

$$
T\subseteq S\quad\Longleftrightarrow\quad T\mathbin{\&}S=T.
$$

The criterion is useful computationally because it can certify existence before search begins. Moreover, large forbidden configurations are cheap to test and rare to contain.

### 6.3 Example

Let $N=20$, $d=5$, $k=6$, and $m=100$. The lower tail is

$$
\sum_{j=0}^{4}\binom{20}{j}=6196.
$$

The uniform sumset cost is

$$
100\cdot2^{20-11}=51200.
$$

Thus

$$
6196+51200=57396<1048576=2^{20}.
$$

Theorem 5.4 guarantees a subset of $U$ with at least five elements that contains none of the hundred prescribed sumsets. The margin is large because the certificate uses less than six percent of the available power set.

### 6.4 Exact versus uniform cost

Suppose two pairs produce the same sumset $T$ of size $14$, while the threshold only guarantees $2k-1=11$. Pairwise uniform counting charges

$$
2\cdot2^{N-11}.
$$

Deduplicated exact counting charges only

$$
2^{N-14}.
$$

The ratio is $16$. This simple example displays both sources of slack: repeated descriptions and replacement of actual sumset size by its minimum possible size.

## 7. Probabilistic variants and structural bottlenecks

### 7.1 Biased random subsets

The uniform model includes each element with probability $1/2$. If instead each element is included independently with probability $p\in(0,1)$, then

$$
\Pr(T\subseteq S)=p^{|T|}.
$$

For a forbidden family $\mathcal F$,

$$
\Pr(\exists T\in\mathcal F:T\subseteq S)
\leq \sum_{T\in\mathcal F}p^{|T|}.
$$

A simultaneous density guarantee follows whenever a suitable lower-tail estimate satisfies

$$
\Pr(|S|<d)+\sum_{T\in\mathcal F}p^{|T|}<1.
$$

This is the natural form for target density $p$. The finite uniform theorem corresponds to $p=1/2$ and has the advantage that every count is an integer identity.

### 7.2 Why raw pair counting is insufficient asymptotically

For $U=[n]$, there are enormously many candidate pairs $(A,B)$. The estimate

$$
|\mathcal P|2^{-(2k-1)}
$$

is effective only if the logarithm of the candidate count is smaller than the containment exponent. At logarithmic $k$, naïvely counting all pairs usually loses too much information. The issue is not that a fixed sumset is likely to be contained—it is exponentially unlikely—but that the same or similar additive structure can be described by too many pairs.

### 7.3 Fingerprints

A fingerprint scheme assigns to each candidate pair $(A,B)$ a witness

$$
T(A,B)\subseteq A+B
$$

such that containing $A+B$ forces containing $T(A,B)$. If many pairs share a fingerprint, the union bound need only charge the distinct fingerprints. A successful weighted cover seeks

$$
\sum_{T\text{ distinct}}p^{|T|}=o(1)
$$

in an asymptotic regime. The exact finite criterion then applies unchanged.

This observation isolates the principal structural problem: retain enough of each sumset to earn a large containment exponent while using few enough fingerprints to control their number.

### 7.4 Low and high additive growth

Pairs with large $|A+B|$ receive a strong exponential discount directly. Pairs with small $|A+B|$ are more dangerous probabilistically, but they possess additive structure and may admit compact descriptions. This suggests dividing candidates into growth regimes. The finite first-moment kernel treats all regimes uniformly once an appropriate family of witnesses has been found.

## 8. Applications beyond integer sumsets

The dense finite avoidance theorem is not intrinsically additive. It applies whenever forbidden objects are subsets of a finite universe.

In a hypergraph with vertex set $U$, let $\mathcal F$ be the edge set. The theorem gives a sufficiently large vertex subset containing no edge whenever the lower-cardinality tail plus $\sum_{T\in\mathcal F}2^{N-|T|}$ is below $2^N$. Thus it is an independence criterion for nonuniform hypergraphs.

In coding and design problems, $U$ may represent coordinate positions and forbidden configurations may encode local failure patterns. A large selection of coordinates avoiding every failure pattern exists under the same weighted condition.

For finite geometric configurations, each forbidden copy contributes a cost based only on its number of points. Geometry enters through counting or compressing the family of copies, just as additive structure enters through counting sumsets.

These applications share a common architecture: exact local containment, a global union bound, a size constraint, and domain-specific structural compression.

## 9. Discussion and future work

The finite theory establishes four concrete facts. First, a $t$-element configuration in an $N$-element universe belongs to exactly $2^{N-t}$ subsets. Second, the total number of subsets containing some forbidden configuration is bounded by the sum of these exact costs. Third, subtracting the complete lower-cardinality tail yields a deterministic dense-avoidance criterion. Fourth, integer sumset growth converts lower bounds on $|A|$ and $|B|$ into the uniform exponent $2k-1$.

The bounds are intentionally robust rather than universally sharp. They ignore overlap among bad events, multiplicity in the representation of sumsets, and all additive structure beyond the minimal growth inequality. Each ignored feature can improve the estimate. This makes the criterion a stable endpoint for stronger structural arguments.

Several directions emerge. A weighted fingerprint cover at the logarithmic threshold would compress pairs with similar sumsets. A finite Freiman-type dimension theorem for asymmetric pairs could produce small witnesses retaining most distinct sums. Random avoidance constants may improve if the large-growth regime is counted more efficiently. For iterated sumsets $A_1+\cdots+A_t$, repeated integer sumset growth supplies a deterministic backbone, while higher-order fingerprints should govern the threshold. Finally, binary-entropy estimates for the lower-cardinality tail can sharpen density requirements when $d$ is proportional to $N$.

## 10. Boundary cases and sharpness of the finite kernel

The counting statements admit several useful checks. If $\mathcal F$ is empty, Theorem 4.1 reduces to the assertion that a subset of size at least $d$ exists whenever fewer than all subsets have size below $d$; this is equivalent to $d\leq N$. If $d=0$, the lower-tail cost vanishes, and the theorem becomes pure avoidance. If the empty set belongs to $\mathcal F$, its containment cost is $2^N$, so the strict criterion cannot hold; correctly, no subset avoids containing the empty set.

The exact superset count cannot be improved: for one forbidden configuration, precisely $2^{N-|T|}$ candidates fail. The union bound can be sharp when the relevant containment classes are disjoint, although for nonempty configurations they commonly overlap. In additive applications, the growth estimate is also individually sharp. For example, if

$$
A=\{0,1,\ldots,r-1\},
\qquad
B=\{0,1,\ldots,s-1\},
$$

then

$$
A+B=\{0,1,\ldots,r+s-2\}
$$

and $|A+B|=r+s-1$. Thus no universally stronger exponent can be obtained from the cardinalities of $A$ and $B$ alone.

The overall additive criterion may nevertheless have considerable slack because it combines several worst cases that need not occur simultaneously. Sumsets of minimum cardinality are highly structured; a large family of such structured sets may be easier to encode than an arbitrary family. Conversely, unstructured pairs generally have larger sumsets and therefore much smaller containment weights. Exploiting this tradeoff is precisely the role of structural fingerprints.

A second useful distinction concerns certification and construction. The inequality in Theorem 5.4 is a certificate that some witness exists, computable without searching all subsets. Producing the witness by exhaustive enumeration still takes exponential time in the worst case. More sophisticated constructive methods may use conditional expectations: process the elements of $U$ one at a time, choosing inclusion or exclusion so that an upper bound on the remaining expected failure cost does not increase. Developing such a method with a hard cardinality constraint is a natural algorithmic refinement of the present existence argument.

## 11. Conclusion

Dense avoidance is governed by a competition between two populations: subsets too small to meet the density target and subsets forced to contain a forbidden configuration. Exact containment counting assigns a transparent exponential price to each configuration. Integer sumset growth guarantees that prescribed sums generated by large summands carry a correspondingly large price. If the combined price does not exhaust the power set, a dense avoiding subset must exist.

The resulting theorem is finite, explicit, and algorithmically testable. More importantly, it separates universal probability from additive structure. The first-moment mechanism is complete; sharper asymptotic thresholds depend on compressing the family of additive obstructions. That separation provides a clear foundation for further work on dense sets without large sumsets.