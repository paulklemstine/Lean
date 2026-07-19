# Factorial Information in Sorting: Decision Trees, Reversible History, and Landauer Work

**Aristotle**  
**July 19, 2026**

## Abstract

Sorting $n$ distinct labeled objects begins with $n!$ possible input permutations and produces a canonical ordered output. This paper develops a self-contained account of the factorial invariant linking three resources: binary comparison depth, information erased by ordinary many-to-one sorting, and auxiliary history required by a reversible implementation. A binary comparison tree of height $h$ has at most $2^h$ leaves, so any tree capable of distinguishing all $n!$ orders satisfies $h\ge\lceil\log_2(n!)\rceil$. When sorting is regarded as the constant map from the permutation space to one canonical output, it erases exactly $\log_2(n!)$ bits and has ideal Landauer scale $kT\log(n!)$. Conversely, any bijective realization that retains the sorted output must have at least $n!$ auxiliary history states. These statements combine into a three-way factorial principle, but they do not identify comparison count with dissipated work. We prove this separation by a padding construction that adds arbitrarily many redundant comparison levels without changing the sorting map or its erased information. Numerical algorithms are given for factorial entropy, decision-tree bounds, history capacity, and ideal work. The resulting framework distinguishes combinatorial lower bounds from physical reset costs and identifies conditional transcript entropy as the appropriate target for more detailed thermodynamic models.

## 1. Introduction

A sorting algorithm acts on information represented by physical degrees of freedom. This makes sorting a natural meeting point for combinatorics, information theory, reversible computation, and thermodynamics. The elementary counting fact that $n$ distinct objects have $n!$ possible orders yields the familiar comparison lower bound of order $n\log n$. The same count also measures how much information is absent from the ordinary sorted output, and how much history must be retained if the computation is to remain reversible.

These parallels can encourage an overstrong conclusion: that every comparison necessarily dissipates the energy associated with erasing one bit, so an algorithm making $C(n)$ comparisons has work proportional to $C(n)kT$. That conclusion does not follow. A comparison outcome can be retained rather than erased; repeated outcomes can be correlated; temporary records can be reversibly uncomputed; and redundant comparisons can be added without changing the computed input-output map. A physically meaningful work statement must identify the logical information that is reset and specify the implementation of that reset.

The purpose of this paper is to state precisely what can be concluded from the finite combinatorics alone. The principal conclusions are:

1. an adequate binary comparison tree has worst-case depth at least $\lceil\log_2(n!)\rceil$;
2. ordinary sorting, modeled as forgetting the input permutation after producing the canonical order, erases exactly $\log_2(n!)$ bits;
3. a reversible realization with the same visible output requires at least $n!$ history states;
4. the corresponding ideal Landauer baseline is $kT\log(n!)$;
5. comparison count can be increased arbitrarily while this logical-erasure baseline remains unchanged.

The paper is organized as follows. Section 2 introduces finite information loss and reversible witnesses. Section 3 develops the binary-tree counting argument. Section 4 applies the definitions to sorting. Section 5 combines the results and proves the padding separation. Section 6 gives computational algorithms and examples. Sections 7 and 8 discuss applications, limitations, and future directions.

## 2. Finite information loss and reversible realization

### 2.1. Input spaces, images, and fibers

Let $A$ and $B$ be finite sets and let $f:A\to B$ be a function. Its image is

$$
\operatorname{im}(f)=\{f(a):a\in A\}.
$$

For each $b\in B$, the fiber over $b$ is

$$
f^{-1}(b)=\{a\in A:f(a)=b\}.
$$

The nonempty fibers partition $A$, and therefore

$$
\sum_{b\in B}|f^{-1}(b)|=|A|.
$$

This identity is the basic counting law behind reversible history. If several inputs share one output, additional information is needed to identify which member of the fiber occurred.

### Definition 2.1 (Finite-set erased information)

For a function $f:A\to B$ between finite sets, define the information erased by $f$, in bits, as

$$
I_{\mathrm{erase}}(f)=\log_2|A|-\log_2|\operatorname{im}(f)|.
$$

This cardinality-based definition corresponds to uniform uncertainty over the input space and counts the contraction in the number of possible logical states. It is not a distribution-sensitive conditional entropy. If $f$ is a bijection from $A$ to itself, its image has size $|A|$ and the erased information is zero. If $f$ is constant and $A$ is nonempty, the image has size one and the erased information is $\log_2|A|$.

### Proposition 2.2 (Nonnegativity of finite-set erasure)

For every function $f:A\to B$ between finite sets,

$$
I_{\mathrm{erase}}(f)\ge 0.
$$

**Proof sketch.** The image of a function contains no more elements than its domain, so $|\operatorname{im}(f)|\le |A|$. Monotonicity of $\log_2$ gives the result. If the domain is empty, both cardinalities relevant to the realized map are zero and the convention can be handled separately; the sorting application below has a one-element permutation space even when $n=0$.

### 2.2. Reversible witnesses and fiber labels

A logically reversible computation is one-to-one on its complete logical state. A function $f:A\to B$ that is not injective can be embedded in a reversible transformation by appending auxiliary history.

### Definition 2.3 (Reversible realization)

A reversible realization of $f:A\to B$ consists of a finite auxiliary set $H$ and a bijection

$$
E:A\longrightarrow B\times H
$$

such that the first component of $E(a)$ equals $f(a)$ for every $a\in A$.

The product form requires the cardinalities to fit exactly. A universally available, output-dependent form instead maps $A$ bijectively to the disjoint union

$$
\bigsqcup_{b\in B}\{b\}\times f^{-1}(b).
$$

The mapping sends $a$ to $(f(a),a)$, where $a$ is viewed as a labeled member of its fiber. This is bijective because the output and fiber member together recover the input.

### Theorem 2.4 (Fiber-history lower bound)

If $E:A\to B\times H$ is a reversible realization of $f$, then

$$
\max_{b\in B}|f^{-1}(b)|\le |H|.
$$

**Proof sketch.** Fix an output $b$. For every $a\in f^{-1}(b)$, write $E(a)=(b,h_a)$. If two members of the fiber had the same history value, their complete encoded outputs would coincide, contradicting injectivity of $E$. Thus $a\mapsto h_a$ is an injection from the fiber into $H$. Taking the largest fiber proves the bound.

This theorem captures the operational meaning of a history register: it labels alternatives that the visible output alone cannot distinguish.

### Proposition 2.5 (Composition of reversible histories)

Suppose $f:A\to B$ has a reversible realization with history set $H_f$, and $g:B\to C$ has one with history set $H_g$. Then $g\circ f$ has a reversible realization with history set $H_f\times H_g$, whose cardinality is

$$
|H_f\times H_g|=|H_f||H_g|.
$$

**Proof sketch.** Encode the input under the realization of $f$, then encode its visible $B$ component under the realization of $g$. Retain both histories. Decoding reverses these steps in the opposite order. The product rule follows from finite cardinality.

## 3. Binary comparison trees

### 3.1. Tree model

A binary comparison tree is recursively either a leaf or a branch with a left and right subtree. Each branch represents a comparison with two possible outcomes.

### Definition 3.1 (Leaves and height)

The number of leaves $L(T)$ and the height $H(T)$ are defined recursively by

$$
L(\text{leaf})=1,\qquad H(\text{leaf})=0,
$$

and

$$
L(\operatorname{branch}(T_0,T_1))=L(T_0)+L(T_1),
$$

$$
H(\operatorname{branch}(T_0,T_1))=1+\max\{H(T_0),H(T_1)\}.
$$

The height is the worst-case number of binary comparisons along any execution path. The leaves count possible terminal transcripts in the tree shape.

### Lemma 3.2 (Binary leaf bound)

Every binary comparison tree satisfies

$$
L(T)\le 2^{H(T)}.
$$

**Proof sketch.** Proceed by structural induction. A leaf has $1=2^0$ leaf. For a branch, apply the induction hypotheses to the two subtrees. If their heights are $h_0$ and $h_1$, then

$$
L(T)\le 2^{h_0}+2^{h_1}\le 2^{m}+2^{m}=2^{m+1},
$$

where $m=\max\{h_0,h_1\}$. Since the branch has height $m+1$, the result follows.

### Definition 3.3 (Transcript capacity for sorting)

A tree has enough transcript capacity to distinguish all orderings of $n$ distinct objects if

$$
n!\le L(T).
$$

This is a necessary capacity condition for comparison sorting. It abstracts away the semantics of which pair is compared at each branch. Consequently, it establishes a lower bound for every correct comparison sorter but does not assert that every tree satisfying the inequality implements a sorter.

### Theorem 3.4 (Exact binary comparison lower bound)

If a binary comparison tree has enough transcript capacity for all orderings of $n$ distinct objects, then

$$
H(T)\ge \left\lceil\log_2(n!)\right\rceil.
$$

Equivalently, if $\operatorname{clog}_2(m)$ denotes the least integer $h$ such that $m\le 2^h$, then

$$
\operatorname{clog}_2(n!)\le H(T).
$$

**Proof sketch.** Capacity and Lemma 3.2 give

$$
n!\le L(T)\le 2^{H(T)}.
$$

By the definition of the ceiling logarithm, the least exponent sufficient to reach $n!$ cannot exceed $H(T)$.

### 3.2. Asymptotic interpretation

Stirling’s formula states

$$
n!=\sqrt{2\pi n}\left(\frac{n}{e}\right)^n(1+o(1)).
$$

Taking logarithms gives

$$
\log(n!)=n\log n-n+\frac12\log(2\pi n)+o(1),
$$

and hence

$$
\log_2(n!)=n\log_2n-(\log_2e)n+\frac12\log_2(2\pi n)+o(1).
$$

The comparison lower bound is therefore $\Omega(n\log n)$. Algorithms with worst-case comparison count $O(n\log n)$ match the leading asymptotic order, though they need not use exactly $\lceil\log_2(n!)\rceil$ comparisons for every $n$ or every input.

## 4. Sorting entropy and reversible history

### 4.1. Sorting as a map on permutations

Let $S_n$ be the set of permutations of $n$ labeled positions. Its cardinality is

$$
|S_n|=n!.
$$

To isolate loss of order information, model ordinary sorting by the map

$$
s_n:S_n\to\{\star\},
$$

which sends every input permutation to the unique canonical sorted output $\star$. This model assumes distinct keys and treats the multiset of values as fixed; the only unknown information is their initial order.

### Theorem 4.1 (Exact information erased by sorting)

For every nonnegative integer $n$,

$$
I_{\mathrm{erase}}(s_n)=\log_2(n!).
$$

**Proof sketch.** The domain has cardinality $n!$, while the image of the constant sorting map has cardinality $1$. Substitution into Definition 2.1 gives

$$
I_{\mathrm{erase}}(s_n)=\log_2(n!)-\log_2 1=\log_2(n!).
$$

The formula includes $n=0$ because $0!=1$, so there is one permutation of the empty set and no erased information.

### Theorem 4.2 (Sorting history lower bound)

Let $H$ be the history set of any reversible realization

$$
E:S_n\longrightarrow\{\star\}\times H
$$

whose visible component is ordinary sorting. Then

$$
|H|\ge n!.
$$

**Proof sketch.** The sorting map has a single fiber, namely all of $S_n$, of size $n!$. Apply the fiber-history lower bound. Equivalently, because the visible component is constant, injectivity of $E$ forces the history components of all permutations to be distinct.

The bound is tight at the level of state counting: choose $H=S_n$ and retain the original permutation as history. Thus reversible sorting exchanges logical erasure for storage. The minimum number of equiprobable history bits is at least $\log_2(n!)$.

### 4.2. Landauer scale

Let $k$ be Boltzmann’s constant, $T$ the absolute temperature, and abbreviate their product by $kT$. Landauer’s principle assigns the ideal quasistatic work scale

$$
W=kT\log 2\, I
$$

to erasure of $I$ bits of unbiased logical information.

### Theorem 4.3 (Exact Landauer scale for irreversible sorting)

If the unknown input permutation is discarded by ordinary sorting, its ideal logical-erasure work is

$$
W_{\mathrm{sort}}=kT\log(n!).
$$

**Proof sketch.** By Theorem 4.1 the erased information is $\log_2(n!)$ bits. Change of base gives

$$
kT\log 2\,\log_2(n!)=kT\log(n!).
$$

For positive temperature this quantity is nonnegative because $n!\ge1$.

The theorem identifies a baseline associated with the logical map. It is not a prediction that a practical machine consumes exactly this work. Finite-time operation, error correction, friction, leakage, communication, and reset of unrelated workspace can all increase dissipation.

## 5. The factorial synthesis and the failure of per-comparison accounting

### Theorem 5.1 (Three-way factorial principle)

For any binary comparison tree with enough leaves to distinguish all $n!$ input permutations, and for any reversible realization of ordinary sorting with finite history set $H$, the following hold simultaneously:

$$
\left\lceil\log_2(n!)\right\rceil\le H(T),
$$

$$
I_{\mathrm{erase}}(s_n)=\log_2(n!),
$$

and

$$
n!\le |H|.
$$

**Proof sketch.** The first statement is Theorem 3.4, the second is Theorem 4.1, and the third is Theorem 4.2. Their common source is the cardinality $|S_n|=n!$, but their meanings differ: decision depth, lost information, and retained auxiliary capacity.

### 5.1. Redundant padding

To distinguish comparison count from logical erasure, define a padding operation on binary trees. Given a tree $T$, create one redundant level by making a new root whose two subtrees are identical copies of $T$. Repeat this operation $r$ times to obtain $P_r(T)$.

### Lemma 5.2 (Padding height)

For every nonnegative integer $r$,

$$
H(P_r(T))=r+H(T).
$$

**Proof sketch.** Induct on $r$. The statement is immediate for $r=0$. One more padded branch adds one to the maximum of two equal subtree heights.

### Lemma 5.3 (Padding preserves transcript capacity)

For every nonnegative integer $r$,

$$
L(T)\le L(P_r(T)).
$$

In fact, the recursive construction gives $L(P_r(T))=2^rL(T)$.

**Proof sketch.** Each padding step duplicates the complete set of leaves, so leaf count doubles. The stated inequality follows immediately.

### Theorem 5.4 (Redundant comparisons preserve sorting capacity)

If $T$ has enough transcript capacity for all $n!$ orderings, then $P_r(T)$ also has enough capacity, and

$$
H(P_r(T))=r+H(T).
$$

**Proof sketch.** Capacity is preserved by Lemma 5.3, and the height identity is Lemma 5.2.

### Corollary 5.5 (Comparison count does not determine Landauer work)

There exist tree-shaped computations with arbitrarily different worst-case comparison counts that realize the same ordinary sorting map and therefore have the same erased information $\log_2(n!)$ and the same ideal Landauer scale $kT\log(n!)$.

**Proof sketch.** Begin with any adequate tree and pad it by an arbitrary $r$. The height increases by $r$, while the input-output sorting map remains $s_n$. Since erased information depends on the map’s domain and image, it is unchanged.

This corollary refutes the unconditional law “one comparison equals one erased bit.” Such a law can become meaningful only after adding a physical model in which a comparison writes to a designated register and a specified protocol later resets that register. Even then, the relevant quantity is the entropy actually erased. Repeated or logically dependent outcomes need not carry independent bits.

## 6. Algorithms and numerical demonstrations

### 6.1. Exact factorial entropy

For moderate $n$, one may compute $n!$ as an integer and then evaluate $\log_2(n!)$. For large $n$, direct factorial conversion to floating point overflows. The stable identity

$$
\log(n!)=\log\Gamma(n+1)
$$

provides a robust implementation through a log-gamma routine.

**Algorithm A: Stable factorial-information evaluation**

1. Require $n\ge0$.
2. Compute $\ell=\log\Gamma(n+1)$.
3. Return $\ell/\log2$ as the erased bits.
4. Return $\ell$ as the dimensionless natural-log work $W/(kT)$.
5. Return $\lceil\ell/\log2\rceil$ as the comparison-depth lower bound.

The arithmetic cost of the wrapper is constant, assuming a library implementation of $\log\Gamma$. Exact integer factorial computation instead has growing bit complexity because the output contains $\Theta(n\log n)$ bits.

### 6.2. History-state audit

A reversible implementation advertising $m$ auxiliary states passes the necessary capacity test exactly when

$$
m\ge n!.
$$

Its bit capacity is $\log_2m$. The deficit relative to sorting is

$$
\max\{0,\log_2(n!)-\log_2m\}.
$$

This audit is necessary, not sufficient: enough states do not by themselves guarantee a correct bijective encoding.

### 6.3. Padding experiment

A numerical padding demonstration begins with an abstract adequate tree of height $h$ and records the family of heights $h+r$. The logical quantities remain

$$
I_{\mathrm{erase}}=\log_2(n!),\qquad \frac{W}{kT}=\log(n!)
$$

for every $r$. The experiment does not simulate physical heat. It demonstrates the mathematical non-identifiability of logical-erasure work from raw depth.

### 6.4. Sample values

The first several values illustrate the gap between factorial entropy and simple expressions such as $n\log_2n$:

| $n$ | $n!$ | $\log_2(n!)$ bits | $\lceil\log_2(n!)\rceil$ |
|---:|---:|---:|---:|
| $0$ | $1$ | $0$ | $0$ |
| $1$ | $1$ | $0$ | $0$ |
| $2$ | $2$ | $1$ | $1$ |
| $3$ | $6$ | $2.585$ | $3$ |
| $4$ | $24$ | $4.585$ | $5$ |
| $5$ | $120$ | $6.907$ | $7$ |
| $8$ | $40{,}320$ | $15.299$ | $16$ |
| $10$ | $3{,}628{,}800$ | $21.791$ | $22$ |

At $n=10$, a binary decision tree needs worst-case depth at least $22$. An irreversible map that reports only the canonical sorted order loses approximately $21.791$ bits, while a reversible realization needs at least $3{,}628{,}800$ distinct histories.

## 7. Applications and interpretation

### 7.1. Reversible algorithm design

A reversible sorting protocol may compute comparison outcomes, use them to route data, copy the desired sorted result to a protected output, and run its internal operations backward to clear temporary workspace. If the final protocol also discards the original permutation, that information must eventually be erased somewhere. If it retains a sufficient history, the complete transformation can remain one-to-one.

The history lower bound quantifies the unavoidable logical alternative: a constant visible output cannot coexist with reversibility unless at least $n!$ complete states remain distinguishable in auxiliary degrees of freedom.

### 7.2. Comparator networks and register resets

In a physical comparator network, each comparator may write an outcome register. Transcript length is then an upper bound on the number of raw binary storage locations used, but not necessarily on independent entropy. The correct reset cost depends on the joint distribution of these registers conditioned on outputs and retained data. If outcomes are correlated, reversible compression can in principle reduce the number of bits that must be reset.

This suggests replacing “number of comparisons” with a conditional entropy such as

$$
H(\text{transcript}\mid\text{sorted output},\text{retained history}).
$$

A complete physical theorem would also specify the reset protocol and thermodynamic regime.

### 7.3. Nonuniform input distributions

The cardinality measure $\log_2(n!)$ assumes a uniform prior over permutations. For a distribution $P$ on $S_n$, the Shannon entropy is

$$
H(P)=-\sum_{\sigma\in S_n}P(\sigma)\log_2P(\sigma).
$$

When the prior is biased, $H(P)$ can be much smaller than $\log_2(n!)$. Distribution-sensitive comparison trees can assign short paths to likely permutations, analogous to prefix coding. Reversible histories can also be compressed on average. The worst-case factorial bounds remain valid as capacity statements when every permutation must be supported.

### 7.4. Multiway queries

If each query has at most $q$ outcomes, a depth-$h$ tree has at most $q^h$ leaves. The same counting proof yields

$$
h\ge\left\lceil\log_q(n!)\right\rceil.
$$

If a fully unknown $q$-state query register is erased at ideal cost $kT\log q$, then multiplying depth by per-register cost suggests the same ideal scale $kT\log(n!)$. As in the binary case, equality requires assumptions about independence, saturation of branching capacity, and actual reset operations.

## 8. Limitations and future work

The tree-capacity condition is necessary but not sufficient for sorting correctness because it does not encode comparison semantics. The Landauer formula is a quasistatic logical baseline, not a complete model of runtime energy. The cardinality definition of erased information is tailored to uniform finite spaces and should be replaced by Shannon or conditional entropy for nonuniform ensembles. Finally, the padding theorem establishes that comparison count alone is insufficient; it does not claim redundant physical operations are free. They may dissipate substantial energy for implementation-specific reasons.

Several research directions follow.

First, comparator networks should be equipped with explicit reversible gates, transcript registers, and reset protocols. The expected minimum work should be governed by the conditional entropy of the transcript given the sorted output and any retained history, rather than transcript length.

Second, entropy-sensitive sorting under nonuniform priors should connect expected decision depth, compressible reversible history, and dissipated work. A natural target is an expected comparison count within an additive term linear in $n$ of the Shannon entropy.

Third, independent sorting tasks suggest a direct-sum theorem. Entropies should add, while minimum history cardinalities multiply as products of block factorials. Equality should characterize implementations without cross-block garbage.

Fourth, finite-time stochastic implementations should exhibit a fluctuation penalty above $kT\log(n!)$. A quantitative excess may be expressible through a divergence between forward and reverse trajectories.

Fifth, multiway comparisons invite optimization over radix. The decision depth decreases as $q$ grows, while the ideal erasure cost of a fully unknown query register grows as $kT\log q$. Their ideal product remains controlled by $\log(n!)$, but realistic devices may have a nontrivial optimal radix.

## 9. Conclusion

Sorting exposes a clean factorial architecture. The $n!$ possible input permutations force a binary decision depth of at least $\lceil\log_2(n!)\rceil$. If the original permutation is discarded, the sorting map erases exactly $\log_2(n!)$ bits and has ideal Landauer scale $kT\log(n!)$. If the computation is made reversible while retaining only one visible sorted result, at least $n!$ history states are required.

These are three manifestations of one cardinality, but they are not the same resource. The padding construction makes the distinction decisive: comparison depth can be increased arbitrarily without changing logical erasure. Thermodynamic analysis must therefore follow the fate of information—what is retained, correlated, compressed, uncomputed, and reset—rather than assign a universal energy price to each comparison. The factorial tells us how many alternatives sorting must confront; the physical protocol determines how, and whether, those alternatives are finally forgotten.
