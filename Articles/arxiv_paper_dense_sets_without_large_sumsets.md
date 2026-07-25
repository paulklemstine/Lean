# Dense Sets That Dodge Additive Patterns

## How counting the shadows of sums creates room for structure-free density

A set can be crowded without containing everything one expects. That tension lies at the heart of additive combinatorics. Imagine choosing many integers from a finite interval. Density suggests abundance: many chosen numbers, many pairs, many possible sums. Yet abundance does not automatically force the chosen set to contain an entire *sumset*.

Given two finite sets of integers $A$ and $B$, their sumset is

$$
A+B=\{a+b:a\in A,\ b\in B\}.
$$

The distinction between containing a few sums and containing all of $A+B$ is decisive. A dense set may capture countless individual sums while still missing one strategically placed element from every sumset in a prescribed family. The central question is therefore not simply how many elements can be selected, but whether density and systematic avoidance can coexist.

A clean finite theory answers that question through three ideas: count exactly how expensive one forbidden configuration is; combine those costs without assuming independence; and use the growth of integer sumsets to turn information about $A$ and $B$ into a uniform estimate. The result is a reusable existence criterion for dense sets that avoid entire families of additive patterns.

## One forbidden pattern has an exact price

Let $U$ be a finite universe with $N=|U|$ elements. There are exactly $2^N$ subsets of $U$. Fix a configuration $T\subseteq U$ with $t=|T|$. How many subsets $S\subseteq U$ contain every element of $T$?

Once $T$ is required, its $t$ elements are no longer choices. Each of the remaining $N-t$ elements may independently be included or excluded. Consequently,

$$
\bigl|\{S\subseteq U:T\subseteq S\}\bigr|=2^{N-t}.
$$

This elementary identity is the engine of the entire argument. Relative to all $2^N$ subsets, the proportion containing $T$ is $2^{-t}$. Large configurations are exponentially expensive to contain. Every additional required element halves the population of possible supersets.

The same calculation has a probabilistic reading. If a subset of $U$ is chosen uniformly at random, the chance that it contains $T$ is exactly $2^{-t}$. No asymptotic approximation is involved.

## Many patterns: overlap helps rather than hurts

Now let $\mathcal F$ be a finite family of forbidden configurations, each lying in $U$. Call a subset $S$ bad if it contains at least one member of $\mathcal F$. Adding the individual counts gives

$$
\bigl|\{S\subseteq U:\text{some }T\in\mathcal F\text{ satisfies }T\subseteq S\}\bigr|
\leq \sum_{T\in\mathcal F}2^{N-|T|}.
$$

This is the finite union bound. It does not say that the containment events are disjoint, and it does not require them to be independent. A single set $S$ may contain several forbidden configurations and therefore be counted several times on the right. That only makes the upper bound more generous. Overlap among bad events helps the avoidance argument.

This observation matters because additive patterns overlap heavily. Two different pairs $(A,B)$ can produce the same sumset, and distinct sumsets can share most of their elements. The elementary bound remains valid despite all of that entanglement.

## Density has a cost too

Avoidance by itself is easy: the empty set avoids every nonempty forbidden configuration. To obtain a meaningful result, we must simultaneously demand density.

Fix an integer threshold $d$. Call a subset small when its cardinality is less than $d$. The exact number of small subsets is

$$
L(N,d)=\sum_{j=0}^{d-1}\binom Nj.
$$

There are now two kinds of unacceptable subsets: those that are too small and those that contain a forbidden configuration. Their total number is at most

$$
L(N,d)+\sum_{T\in\mathcal F}2^{N-|T|}.
$$

If this quantity is strictly less than $2^N$, unacceptable subsets cannot exhaust the entire power set. At least one acceptable set remains.

### Dense finite avoidance theorem

Let $U$ be a finite set of size $N$, let $\mathcal F$ be a finite family of subsets of $U$, and let $d$ be a nonnegative integer. If

$$
\sum_{j=0}^{d-1}\binom Nj+
\sum_{T\in\mathcal F}2^{N-|T|}<2^N,
$$

then there exists $S\subseteq U$ such that $|S|\geq d$ and no $T\in\mathcal F$ is contained in $S$.

The proof is a one-page counting argument. Partition failure into “too small” and “contains a forbidden set.” Bound the first class exactly by the binomial tail and the second by the union bound. Their union has fewer than $2^N$ members, so some subset fails neither test.

The theorem is deterministic even though its logic resembles the probabilistic method. Random choice supplies intuition; counting supplies existence.

## Why sumsets carry extra weight

To apply the theorem to additive patterns, we need to estimate the size of $A+B$. Integer addition provides a sharp answer.

### Integer sumset growth theorem

If $A$ and $B$ are nonempty finite sets of integers, then

$$
|A+B|\geq |A|+|B|-1.
$$

One way to see the mechanism is to list the elements increasingly:

$$
a_1<a_2<\cdots<a_r,
\qquad
b_1<b_2<\cdots<b_s.
$$

The chain

$$
a_1+b_1<a_2+b_1<\cdots<a_r+b_1<a_r+b_2<\cdots<a_r+b_s
$$

contains $r+s-1$ distinct sums, all belonging to $A+B$. Thus the stated lower bound follows. Arithmetic progressions show that equality can occur, so the estimate is sharp.

In particular, if $|A|\geq k$ and $|B|\geq k$, then

$$
|A+B|\geq 2k-1.
$$

A prescribed sumset generated by two sets of size at least $k$ therefore costs at most

$$
2^{N-(2k-1)}
$$

among the subsets of an $N$-element universe. The larger the summands, the larger the sumset that must be swallowed whole, and the smaller the collection of subsets capable of swallowing it.

## The additive avoidance criterion

Suppose $\mathcal P$ is a finite collection of pairs $(A,B)$ of nonempty finite integer sets. Assume every associated sumset lies inside the finite universe $U$, and assume

$$
|A|\geq k,
\qquad
|B|\geq k
$$

for every $(A,B)\in\mathcal P$. Repeated pairs may generate identical sumsets; counting pairs rather than distinct sumsets only weakens the estimate and is therefore safe.

If $N=|U|$, then the entire additive containment cost is bounded by

$$
|\mathcal P|\,2^{N-(2k-1)}.
$$

This yields the following concrete theorem.

### Additive dense-avoidance theorem

Under the assumptions above, if

$$
\sum_{j=0}^{d-1}\binom Nj+
|\mathcal P|\,2^{N-(2k-1)}<2^N,
$$

then there exists $S\subseteq U$ with $|S|\geq d$ such that

$$
A+B\nsubseteq S
$$

for every $(A,B)\in\mathcal P$.

The conclusion says that each prescribed sumset has at least one missing element. It does not require $S$ to avoid every individual sum, which would be far stronger and usually incompatible with density.

After dividing the criterion by $2^N$, its meaning becomes especially transparent:

$$
2^{-N}\sum_{j=0}^{d-1}\binom Nj+|\mathcal P|\,2^{-(2k-1)}<1.
$$

The first term is the probability that a uniformly random subset has fewer than $d$ elements. The second is an upper bound for the probability that it contains at least one prescribed large sumset. If the two failure probabilities add to less than one, success has positive probability—and hence a successful set exists.

## A small numerical window

Take a universe of size $N=20$ and ask for at least $d=5$ selected elements. The number of undersized subsets is

$$
\binom{20}{0}+\binom{20}{1}+\binom{20}{2}+\binom{20}{3}+\binom{20}{4}=6196.
$$

Suppose we prescribe $100$ pairs, each with both summands of size at least $k=6$, and all their sumsets lie in the universe. Each sumset has at least $11$ elements, so their combined cost is at most

$$
100\cdot 2^{20-11}=51200.
$$

The total cost is $57396$, well below $2^{20}=1048576$. Therefore a subset with at least five elements exists that contains none of those hundred sumsets.

The estimate is deliberately conservative. It ignores overlap among sumsets, counts repeated sumsets repeatedly, and replaces actual sumset sizes by the worst-case lower bound $2k-1$. Any additional structure can only improve the conclusion.

## Where the real difficulty begins

For a modest prescribed family, the criterion is powerful and explicit. But the grand asymptotic problem asks to avoid sumsets generated by an enormous universe of possible pairs. A raw count of all pairs can overwhelm the exponential discount earned from sumset size. The obstacle is no longer probability; it is description.

Many pairs may have the same additive “fingerprint.” If one could compress structurally similar pairs into a much smaller collection of witnesses $T\subseteq A+B$, then the union bound would charge each fingerprint once rather than each pair separately. This is the path toward logarithmic thresholds: not a different containment calculation, but a sharper census of genuinely different additive obstructions.

That separation is conceptually valuable. The finite theory identifies a complete probabilistic kernel:

1. a fixed $t$-element pattern has containment weight $2^{-t}$;
2. forbidden weights add by the union bound;
3. density failure is a binomial lower tail;
4. integer sumsets contribute at least $|A|+|B|-1$ elements.

What remains is structural compression. Additive combinatorics must explain when millions of candidate pairs cast only thousands of distinct shadows.

## Density without inevitability

Dense sets are often associated with forced patterns. Here the perspective is reversed. Density can survive the systematic deletion of entire additive configurations, provided the collective containment cost stays below the available combinatorial space.

The underlying principle reaches beyond sums. Any finite collection of forbidden configurations can be inserted into the same criterion. Hypergraph edges, local motifs in networks, prescribed blocks in codes, and finite geometric patterns all have a containment price determined by their size. The art lies in finding a compact family of witnesses whose total price is small.

A crowded universe still has room to maneuver. Exact counting tells us how much room. Sumset growth tells us how expensive additive rigidity is. And the union bound—simple, robust, indifferent to overlap—turns those facts into a dense object that dodges every prescribed additive trap.