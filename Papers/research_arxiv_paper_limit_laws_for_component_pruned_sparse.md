# Eventual Periodicity, Saturated Component Counts, and the Limits of Arbitrary Pruning

**Aristotle**  
**July 17, 2026**

## Abstract

Component pruning is a central reduction in the study of sparse random graphs and percolation models: components below a size threshold are deleted, leaving a disjoint union of larger pieces. This paper isolates two deterministic arithmetic mechanisms that support finite-state limit-law arguments and proves a sharp obstruction to extending them to arbitrary cutoffs. First, we represent one-dimensional semilinear order spectra by eventual periodicity and prove closure under complement, intersection, union, finite indexed union, and modification of a finite prefix. Second, for a threshold $q$, we identify multiplicities that agree exactly below $q$ and collapse all multiplicities at least $q$ into a single saturated state. This relation is an equivalence relation and a congruence for addition, both for individual counts and coordinatewise component profiles. These facts express the arithmetic core of disjoint-union composition. Finally, we define variable-cutoff shifts $S_f=\{n:n-f(n)\in S\}$ and show that unrestricted input-dependent cutoffs can encode any prescribed positive tail into the shifted singleton spectrum $S=\{0\}$. Taking the target to be the powers of two, which are proved not eventually periodic, gives an explicit eventually periodic spectrum whose shifted spectrum is not eventually periodic. Thus semilinearity of an unpruned spectrum alone cannot guarantee semilinearity after pruning; regularity assumptions on the cutoff are logically necessary. We discuss the relevance of these results to sparse Erdős–Rényi graphs, logical composition, and future probabilistic limit laws, while carefully separating the deterministic theorems established here from the additional probabilistic ingredients those applications require.

## 1. Introduction

Sparse random structures often decompose into many connected components. In the Erdős–Rényi model with edge probability $p_n=c_n/n$ and $c_n\to0$, the graph is extremely sparse, and its connected components are predominantly small and tree-like. A common operation deletes all components below a threshold $f(n)$. The resulting pruned structure retains only the components considered large enough to matter.

Limit-law arguments for such structures require a bridge between three kinds of information. The first is probabilistic: how many components of each relevant type occur? The second is logical: how does a sentence evaluate on a disjoint union? The third is arithmetic: for which orders can a component type or a finite combination of types occur? The present paper focuses exclusively on the deterministic arithmetic layer. Its purpose is twofold: to establish a finite-state calculus that is stable under the operations used in disjoint-union reasoning, and to determine how far that calculus can be pushed through a variable pruning shift.

For a set $S\subseteq\mathbb N$, interpreted as an order spectrum, eventual periodicity means that beyond a finite threshold, membership in $S$ repeats after a fixed positive translation. In one dimension this is the relevant form of semilinearity up to a finite prefix. We show that eventually periodic spectra are closed under the finite Boolean constructions naturally induced by logical case analysis. We also show that eventual periodicity depends only on the tail of a set.

To model repeated components, we introduce a saturation threshold $q$. Counts below $q$ are remembered exactly; all counts at least $q$ are identified. This finite quotient of $\mathbb N$ behaves well under addition. Consequently, component-count profiles can be combined coordinatewise without leaving the quotient. This is the arithmetic content needed when disjoint union adds multiplicities.

The final result is deliberately contrarian. One might conjecture that shifting an eventually periodic spectrum by any component-pruning cutoff preserves eventual periodicity. We disprove this in the strongest possible way. For every target set $A\subseteq\mathbb N$, there is an input-dependent cutoff that transforms the singleton spectrum $\{0\}$ into $A$ at every positive input. Choosing $A$ to be the powers of two yields an explicit failure of eventual periodicity.

This counterexample is not a defect in the finite-state theory. Rather, it locates its boundary. Fixed Boolean operations and count addition are finite-state transformations. An unrestricted function $f(n)$ may carry arbitrary information about $n$ and can therefore destroy every finite-state pattern. Positive pruning theorems must constrain the cutoff, for example through eventual affine or periodic behavior.

The organization is as follows. Section 2 defines spectra and eventual periodicity. Section 3 proves the closure calculus. Section 4 develops saturated component counts and profiles. Section 5 introduces variable-cutoff shifts and proves arbitrary-tail encoding. Section 6 establishes nonperiodicity of the powers of two and the concrete pruning counterexample. Section 7 gives finite algorithms illustrating the results. Section 8 explains applications and limitations. Section 9 proposes further directions.

## 2. Spectra and eventual periodicity

Throughout, $\mathbb N=\{0,1,2,\ldots\}$. A **spectrum** is a subset $S\subseteq\mathbb N$. Depending on the application, $n\in S$ may mean that a finite tree of order $n$ satisfies a given property, that a component of order $n$ belongs to a designated class, or that a disjoint union of total order $n$ is admissible.

### Definition 2.1 (Eventual periodicity)

A spectrum $S\subseteq\mathbb N$ is **eventually periodic** if there exist a threshold $N\in\mathbb N$ and a period $q\in\mathbb N$ with $q>0$ such that, for every $n\ge N$,

$$
n\in S\quad\Longleftrightarrow\quad n+q\in S.
$$

The pair $(N,q)$ is called an eventual-periodicity certificate. No condition is imposed on membership below $N$.

The definition gives a translation-invariance statement rather than an explicit residue-class representation, but the two viewpoints agree. Once membership is invariant under addition of $q$, every integer beyond $N$ can be reduced by multiples of $q$ to one of finitely many representatives in $[N,N+q-1]$. Thus the tail is determined by finitely many bits.

### Proposition 2.2 (Trivial spectra)

The empty spectrum $\varnothing$ and the universal spectrum $\mathbb N$ are eventually periodic.

**Proof sketch.** For each set take $N=0$ and $q=1$. Membership is constantly false for the empty spectrum and constantly true for the universal spectrum, so translation changes nothing. $\square$

Every finite spectrum is also eventually periodic: take $N$ larger than all its elements and period $1$. Cofinite spectra follow by complementation, proved below.

## 3. Closure of eventually periodic spectra

The closure results in this section show that eventual periodicity supports finite logical combinations.

### Theorem 3.1 (Complement closure)

If $S\subseteq\mathbb N$ is eventually periodic, then its complement $S^c=\mathbb N\setminus S$ is eventually periodic.

**Proof sketch.** Let $(N,q)$ certify eventual periodicity of $S$. For $n\ge N$, the equivalence $n\in S\Longleftrightarrow n+q\in S$ remains true after negating both sides. Hence $n\in S^c\Longleftrightarrow n+q\in S^c$, with the same threshold and period. $\square$

### Lemma 3.2 (Iteration of a period)

If $(N,q)$ certifies eventual periodicity of $S$, then for every $n\ge N$ and every $k\in\mathbb N$,

$$
n\in S\quad\Longleftrightarrow\quad n+kq\in S.
$$

**Proof sketch.** Induct on $k$. The case $k=0$ is immediate. For the inductive step, apply the one-period equivalence at $n+kq$, which is still at least $N$, and compose it with the induction hypothesis. $\square$

### Theorem 3.3 (Intersection closure)

If $S,T\subseteq\mathbb N$ are eventually periodic, then $S\cap T$ is eventually periodic.

**Proof sketch.** Suppose $(N_S,q_S)$ and $(N_T,q_T)$ are certificates. Set

$$
N=\max(N_S,N_T),\qquad q=q_Sq_T.
$$

The period $q$ is positive. For $n\ge N$, Lemma 3.2 applied with $k=q_T$ shows that membership in $S$ is unchanged by adding $q_Tq_S=q$. Applied to $T$ with $k=q_S$, it shows that membership in $T$ is unchanged by the same translation. Therefore the conjunction defining $S\cap T$ is unchanged. $\square$

The product period is convenient and entirely elementary. The least common multiple would generally give a smaller certificate, but minimality is irrelevant to closure.

### Theorem 3.4 (Union closure)

If $S,T\subseteq\mathbb N$ are eventually periodic, then $S\cup T$ is eventually periodic.

**Proof sketch.** By De Morgan's identity,

$$
S\cup T=(S^c\cap T^c)^c.
$$

Apply complement closure, intersection closure, and complement closure once more. Equivalently, one may use the same common threshold and product period as in Theorem 3.3 and preserve the defining disjunction directly. $\square$

### Theorem 3.5 (Finite indexed-union closure)

Let $I$ be a finite index set, and let $S_i\subseteq\mathbb N$ be eventually periodic for every $i\in I$. Then

$$
\bigcup_{i\in I}S_i
$$

is eventually periodic.

**Proof sketch.** Induct on the number of indices. The union over no indices is empty and hence eventually periodic by Proposition 2.2. Adding one index reduces the claim to Theorem 3.4. $\square$

Finite intersections follow similarly, either by induction or by complements. Consequently every finite Boolean combination of eventually periodic spectra is eventually periodic.

### Theorem 3.6 (Tail invariance)

Let $S,T\subseteq\mathbb N$. Suppose $S$ is eventually periodic and there exists $M\in\mathbb N$ such that

$$
\forall n\ge M,
\qquad n\in S\Longleftrightarrow n\in T.
$$

Then $T$ is eventually periodic.

**Proof sketch.** Let $(N,q)$ certify eventual periodicity of $S$, and choose the new threshold $N'=\max(N,M)$. For $n\ge N'$, both $n$ and $n+q$ lie beyond $M$, so membership in $T$ agrees with membership in $S$ at both points. The periodic equivalence for $S$ transfers to $T$. $\square$

This theorem permits arbitrary changes to a finite prefix. It also allows two spectra with the same tail to share all eventual-periodicity conclusions even when their small elements differ substantially.

## 4. Saturated multiplicities and disjoint union

A disjoint union adds the number of components of each type. A finite-state description cannot remember unbounded exact counts, so it records small multiplicities exactly and collapses sufficiently large ones.

### Definition 4.1 (Saturated count equivalence)

Fix $q\in\mathbb N$. For $a,b\in\mathbb N$, define

$$
a\sim_q b
\quad\Longleftrightarrow\quad
(a=b)\ \text{or}\ (q\le a\ \text{and}\ q\le b).
$$

Thus the equivalence classes are

$$
\{0\},\{1\},\ldots,\{q-1\},\{q,q+1,q+2,\ldots\}
$$

when $q>0$. If $q=0$, all natural numbers are equivalent. The corresponding saturated representative is $\min(a,q)$.

### Theorem 4.2 (Equivalence relation)

For every $q\in\mathbb N$, the relation $\sim_q$ is reflexive, symmetric, and transitive.

**Proof sketch.** Reflexivity follows from the equality alternative. Symmetry follows because both equality and the conjunction “both at least $q$” are symmetric. For transitivity, suppose $a\sim_q b$ and $b\sim_q c$. If either relation is witnessed by equality, substitute and use the other relation. Otherwise $a,b\ge q$ and $b,c\ge q$, hence $a,c\ge q$, so $a\sim_q c$. $\square$

### Theorem 4.3 (Additive congruence)

For all $a,b,c,d,q\in\mathbb N$, if $a\sim_q b$ and $c\sim_q d$, then

$$
a+c\sim_q b+d.
$$

**Proof sketch.** If $a=b$ and $c=d$, then the sums are exactly equal. Otherwise at least one comparison is in the saturated case. If $a,b\ge q$, then $a+c\ge q$ and $b+d\ge q$ because $c,d\ge0$. If instead $c,d\ge q$, the same conclusion follows. Thus unequal resulting sums, if any, are both in the saturated class. $\square$

The theorem says that addition is well defined on the finite quotient $\mathbb N/{\sim_q}$. In saturated representatives, the induced operation is

$$
x\oplus_q y=\min(x+y,q),
$$

for $x,y\in\{0,1,\ldots,q\}$. The element $q$ represents “at least $q$” and is absorbing for addition: $q\oplus_q x=q$.

### Definition 4.4 (Component-count profile)

Let $I$ index component types. A **component-count profile** is a function $a:I\to\mathbb N$, where $a(i)$ is the number of components of type $i$. Profiles $a$ and $b$ are **coordinatewise $q$-equivalent** if

$$
\forall i\in I,
\qquad a(i)\sim_q b(i).
$$

Disjoint union adds profiles pointwise: $(a+c)(i)=a(i)+c(i)$.

### Theorem 4.5 (Profile congruence)

Let $a,b,c,d:I\to\mathbb N$. If $a(i)\sim_q b(i)$ and $c(i)\sim_q d(i)$ for every $i\in I$, then

$$
a(i)+c(i)\sim_q b(i)+d(i)
$$

for every $i\in I$.

**Proof sketch.** Fix an arbitrary coordinate $i$ and apply Theorem 4.3 to the four counts at that coordinate. Since $i$ was arbitrary, the result holds throughout the profile. $\square$

This coordinatewise congruence is the deterministic arithmetic core of a Feferman–Vaught-style disjoint-union decomposition. A full logical theorem requires a syntax and semantics for formulas, a finite collection of component types at bounded quantifier rank, and a proof that sufficiently large multiplicities are logically indistinguishable. Once such a threshold is available, Theorem 4.5 guarantees that the finite summaries compose correctly under disjoint union.

## 5. Variable-cutoff shifts

We now test whether eventual periodicity survives a pruning-inspired shift.

### Definition 5.1 (Shifted spectrum)

For a spectrum $S\subseteq\mathbb N$ and a cutoff function $f:\mathbb N\to\mathbb N$, define

$$
S_f=\{n\in\mathbb N:n\mathbin{\dot-}f(n)\in S\},
$$

where $n\mathbin{\dot-}m=\max(n-m,0)$ denotes truncated natural subtraction.

When $f(n)\le n$, this is ordinary subtraction. The definition asks whether the residual order after removing $f(n)$ belongs to the base spectrum.

### Definition 5.2 (Target-encoding cutoff)

Given any set $A\subseteq\mathbb N$, define

$$
f_A(n)=
\begin{cases}
n,&n\in A,\\
n-1,&n\notin A.
\end{cases}
$$

At $n=0$, truncated subtraction creates an unavoidable boundary coincidence. For positive inputs, the residual is exact and separates the two cases.

### Theorem 5.3 (Arbitrary-tail encoding)

Let $A\subseteq\mathbb N$ be arbitrary, let $S=\{0\}$, and let $f_A$ be the target-encoding cutoff. Then for every $n>0$,

$$
n\in S_{f_A}\quad\Longleftrightarrow\quad n\in A.
$$

**Proof sketch.** If $n\in A$, then $f_A(n)=n$, so $n-f_A(n)=0\in S$. If $n\notin A$, then positivity gives $f_A(n)=n-1$ and $n-f_A(n)=1\notin S$. These implications are reversible, proving the equivalence. $\square$

### Corollary 5.4 (Universality of unrestricted pruning shifts)

Up to the single boundary point $0$, shifted singleton spectra under unrestricted input-dependent cutoffs realize every subset of $\mathbb N$.

The result is stronger than the existence of one pathological cutoff. It says that the transformation $S\mapsto S_f$ has no general regularity-preservation property when $f$ is unrestricted: the cutoff itself can contain the full characteristic function of the target.

### Proposition 5.5 (The base singleton is eventually periodic)

The spectrum $\{0\}$ is eventually periodic.

**Proof sketch.** Take threshold $N=1$ and period $q=1$. Every $n\ge1$ lies outside $\{0\}$, and so does $n+1$. $\square$

Thus any irregularity produced by Theorem 5.3 comes entirely from the cutoff, not from the base spectrum.

## 6. A concrete nonperiodic target

Let

$$
P_2=\{2^k:k\in\mathbb N\}
$$

be the spectrum of powers of two.

### Theorem 6.1 (Powers of two are not eventually periodic)

The spectrum $P_2$ is not eventually periodic.

**Proof sketch.** Assume that $(N,q)$ is an eventual-periodicity certificate, with $q>0$. Powers of two are unbounded, so choose $m$ such that

$$
2^m>N\qquad\text{and}\qquad 2^m>q.
$$

Since $2^m\in P_2$ and $2^m\ge N$, periodicity implies $2^m+q\in P_2$. Hence $2^m+q=2^j$ for some $j$. But $0<q<2^m$ gives

$$
2^m<2^j=2^m+q<2^m+2^m=2^{m+1}.
$$

No integral power of two lies strictly between consecutive powers $2^m$ and $2^{m+1}$. Equivalently, strict monotonicity of $2^k$ would force $m<j<m+1$, impossible for an integer $j$. This contradiction proves the claim. $\square$

### Theorem 6.2 (Concrete destruction of eventual periodicity)

There exist an eventually periodic spectrum $S\subseteq\mathbb N$ and a cutoff $f:\mathbb N\to\mathbb N$ such that $S_f$ is not eventually periodic.

More explicitly, take $S=\{0\}$ and

$$
f(n)=
\begin{cases}
n,&n\in P_2,\\
n-1,&n\notin P_2.
\end{cases}
$$

Then $S$ is eventually periodic, while $S_f$ agrees with $P_2$ at every positive integer and is therefore not eventually periodic.

**Proof sketch.** Proposition 5.5 gives eventual periodicity of $S$. Theorem 5.3 gives agreement of $S_f$ and $P_2$ for all $n\ge1$. If $S_f$ were eventually periodic, tail invariance in Theorem 3.6 would transfer eventual periodicity to $P_2$, contradicting Theorem 6.1. $\square$

This theorem precisely refutes unrestricted pruning invariance. It does not refute preservation under regular cutoffs. Indeed, the encoding cutoff is intentionally designed from the target set and oscillates according to its membership pattern.

## 7. Algorithms and numerical illustrations

Although eventual periodicity is an infinite property, certificates and finite windows support useful computations.

### 7.1 Certificate checking on a finite window

Given a Boolean membership predicate for $S$, a proposed threshold $N$, period $q>0$, and endpoint $B$, one may test

$$
S(n)=S(n+q)
$$

for every $N\le n\le B$. This takes $O(B-N+1)$ membership comparisons and $O(1)$ auxiliary space if failures are streamed. Passing the test is evidence within the sampled window, not a proof of eventual behavior unless an independent bound reduces the infinite claim to that window.

For powers of two, every proposed pair $(N,q)$ has an explicit witness of failure. Choose the least $2^m$ exceeding $\max(N,q)$. Then $2^m$ is in the spectrum but $2^m+q$ is strictly between consecutive powers and is not.

### 7.2 Saturated profile composition

Represent each count by $\min(a,q)$. For profiles indexed by a finite set $I$, disjoint union is computed as

$$
h(i)=\min(a(i)+b(i),q).
$$

The operation takes $O(|I|)$ arithmetic operations and $O(|I|)$ output space. Theorem 4.5 guarantees that the result depends only on the saturated input profiles, not on the hidden exact values above $q$.

### 7.3 Constructing encoded shifts

For a finite observation range $1\le n\le B$, evaluate the target predicate $A(n)$ and set $f_A(n)=n$ when true and $f_A(n)=n-1$ otherwise. The residual is then $0$ or $1$, and singleton membership recovers $A(n)$. The construction takes $O(B)$ target-predicate evaluations and linear output space if the full table is retained.

These algorithms illustrate both sides of the theory. Saturation compresses unbounded counts into stable finite summaries; adversarial cutoff construction injects arbitrary information into a seemingly elementary shift.

## 8. Applications, scope, and limitations

### 8.1 Sparse Erdős–Rényi graphs

Consider $G(n,p_n)$ with $p_n=c_n/n$ and $c_n\to0$. In regimes where components are predominantly finite trees, a logical property of the whole graph can be approached through the multiset of component types. Pruning removes components below a threshold $f(n)$, changing both the available types and their multiplicities.

The deterministic results here contribute two ingredients to such an analysis. If the order spectra attached to relevant component classes are eventually periodic, Section 3 permits finite Boolean combinations without losing that property. If a bounded-rank logical analysis identifies multiplicities above some threshold $q$, Section 4 ensures that disjoint union respects the resulting finite summaries.

A complete zero-one law additionally requires probability spaces, uniform estimates for component counts over a growing size window, and a logical composition theorem establishing the appropriate saturation threshold. Those probabilistic and semantic results are not consequences of the arithmetic theorems alone. The counterexample in Section 6 further shows that a positive pruning theorem cannot assume only eventual periodicity of the unshifted spectra; it must exploit regularity or growth control in $f$.

### 8.2 Percolated tori

Bond percolation on a discrete torus also produces random connected components, and first-order limit laws may be studied by local patterns and separated clusters. Saturated counts again provide a natural finite-state abstraction when the logic cannot distinguish all large multiplicities. However, torus geometry introduces spatial dependence and wraparound effects absent from a purely disjoint-union arithmetic model. Establishing percolation limit laws requires geometric and probabilistic estimates beyond the present scope.

### 8.3 Why the negative theorem is structurally useful

Counterexamples can improve theorem design. The target-encoding cutoff identifies the exact missing hypothesis in an overbroad preservation claim: the cutoff must not be allowed to carry arbitrary membership information. Any proposed regularity class for cutoffs should be tested against three criteria:

1. it should exclude target-encoding oscillation;
2. it should be broad enough to include thresholds arising naturally in asymptotic models; and
3. its interaction with the period of $S$ should be analyzable using finitely many residues.

The result therefore turns an informal warning into a precise design constraint.

## 9. Future directions

The first direction is **regular-cutoff preservation**. Suppose $S$ has eventual period $q$ and $f$ is eventually affine modulo $q$. Then membership of $n-f(n)$ in the periodic tail of $S$ should depend eventually on finitely many residues, suggesting that $S_f$ is eventually periodic. Useful subclasses include eventually constant cutoffs, affine cutoffs, periodic cutoffs, and functions with periodic first differences. Boundary cases where $f(n)>n$ infinitely often require explicit treatment because subtraction is truncated.

The second direction is a **full finite-state disjoint-union theorem**. One should define finite relational structures and monadic second-order formulas with quantification over vertex and edge sets, then prove that at each bounded quantifier rank there is a saturation threshold such that the type of a disjoint union depends only on saturated component multiplicities. The profile congruence theorem supplies the necessary arithmetic composition law.

The third direction concerns **tree order spectra**. For a class of finite trees definable in an appropriate monadic second-order language, the target result is semilinearity of its order spectrum; in one dimension this yields eventual periodicity up to a finite prefix. A proof is expected to require tree automata or a structural composition theorem, not arithmetic closure alone.

The fourth direction is **uniform component counting** in $G(n,c_n/n)$. The model, pruning operation, and component isomorphism types must be defined, after which one needs estimates uniform over all tree types in the allowed size range. Such estimates connect deterministic finite-state summaries to limiting probabilities.

A fifth direction is extension to **percolated discrete tori**. Here one must combine local logical descriptions with dependent percolation estimates, distinguish one-sided and two-sided parameter regimes, and control the influence of components that wrap around the torus.

## 10. Conclusion

Eventual periodicity and saturated counting provide two complementary finite-state abstractions for component-based limit-law arguments. Eventual periodic spectra are stable under complement, intersection, union, finite unions, and finite-prefix changes. Saturated multiplicities form an equivalence relation compatible with addition, and this compatibility extends coordinatewise to complete component profiles. These positive results explain why finite logical combinations and disjoint-union composition can preserve bounded arithmetic information.

The variable-cutoff analysis marks the exact boundary of this stability. An unrestricted cutoff can encode any target set into the shifted singleton spectrum. Since the powers of two are not eventually periodic, even the simplest eventually periodic base spectrum can be transformed into a nonperiodic one. Therefore no preservation theorem can rely on the base spectrum alone.

The resulting principle is both mathematical and methodological: finite-state regularity survives operations that themselves use finite-state information, but it can be destroyed by an input-dependent rule with unrestricted expressive power. Future limit-law theorems for pruned random structures must make the regularity of the cutoff an explicit part of their hypotheses.