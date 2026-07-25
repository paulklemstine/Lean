# Period Divisibility under Dynamically Consistent Observation

## Abstract

We study the transport of pointwise recurrence through an observation map between discrete dynamical systems. Let $f:X\to X$ and $g:Y\to Y$ be arbitrary self-maps and let $h:X\to Y$ satisfy the semiconjugacy equation $h\circ f=g\circ h$. We prove that the minimal period of every observed state divides the minimal period of its source state. Thus a dynamically consistent observation may collapse a cycle only to a cycle whose length is an arithmetic divisor of the original length. No topology, metric, compactness, continuity, cardinality condition, or finite-fiber hypothesis is needed. If $h$ is injective, every periodicity equation is reflected from the observed system to the source system, so minimal periods and exact-period strata are preserved pointwise. For a source state of prime minimal period $p$, divisor rigidity yields a sharp dichotomy: its observation has minimal period $p$ or $1$. We give elementary proofs, finite-cycle realizations showing sharpness, algorithms for auditing recurrence under observation, and applications to coarse-grained models, sensor design, symbolic dynamics, and cognitive observation. We conclude by separating these pointwise algebraic results from global questions involving period spectra, entropy, metric scrambling, and quantitative observability.

## 1. Introduction

Discrete dynamics describes a state repeatedly updated by a fixed rule. Recurrence is among its simplest invariants: a state is periodic when it eventually returns exactly to itself after a positive number of updates. In applications, however, the full state is rarely observed. Measurement, categorization, feature extraction, and coarse-graining replace a hidden state with a reduced description. The resulting observation can identify distinct phases of an orbit and thereby make recurrence appear faster than it is.

The purpose of this paper is to identify the exact restriction on that apparent acceleration. When an observation respects the dynamics, the observed minimal period is not arbitrary: it divides the hidden minimal period. This converts information loss into an arithmetic statement.

The relevant consistency condition is semiconjugacy. Given self-maps $f:X\to X$ and $g:Y\to Y$, an observation $h:X\to Y$ is dynamically consistent when

$$
h(f(x))=g(h(x))
$$

for every $x\in X$. The equation means that updating before observation gives the same answer as observation before updating. It ensures that the observed variable evolves autonomously according to $g$.

Our first result states that if $x$ has minimal period $n$, then $h(x)$ has minimal period dividing $n$. Our second result identifies injectivity as a sufficient condition for equality: if $h$ distinguishes all source states, every observed return is a source return. The exact-period strata are consequently transported pointwise. Finally, when $n=p$ is prime, the only divisors are $1$ and $p$, so an observed prime cycle either remains intact or collapses to a fixed point.

These conclusions are algebraic. They do not require that $X$ or $Y$ be finite, compact, metric, measurable, or topological spaces, nor that the maps be continuous. This generality is useful conceptually: topological assumptions become necessary for global invariants such as entropy, but not for the arithmetic of a single orbit.

The paper is organized as follows. Section 2 develops the definitions and iteration identities. Section 3 proves period divisibility. Section 4 proves reflection and exact preservation under injectivity. Section 5 treats prime periods. Section 6 constructs sharp examples. Section 7 gives computational algorithms. Sections 8 and 9 discuss applications, limitations, and future directions.

## 2. Dynamical and arithmetic preliminaries

### 2.1 Discrete dynamical systems and iterates

A **discrete dynamical system** on a set $X$ is a self-map $f:X\to X$. Define the iterates recursively by

$$
f^0=\operatorname{id}_X,\qquad f^{k+1}=f\circ f^k.
$$

For a state $x\in X$, its forward orbit is the sequence $(f^k(x))_{k\geq 0}$. Iterates obey the additive law

$$
f^{a+b}=f^a\circ f^b
$$

for all nonnegative integers $a$ and $b$.

A state $x$ is **periodic with return time $n$** when $n>0$ and $f^n(x)=x$. If at least one positive return time exists, the **minimal period** of $x$, denoted $\operatorname{per}_f(x)$, is the least positive integer $n$ satisfying $f^n(x)=x$. We say that $x$ has **exact period $n$** when $\operatorname{per}_f(x)=n$.

A point of exact period $1$ is a fixed point. If $x$ has exact period $n$, then the states

$$
x,f(x),\ldots,f^{n-1}(x)
$$

are pairwise distinct, and $f$ cyclically permutes them.

The following standard arithmetic lemma is central.

**Lemma 2.1 (Return-time divisibility).** If $x$ has minimal period $d$ under $f$ and $f^n(x)=x$ for some positive integer $n$, then $d\mid n$.

**Proof sketch.** Apply Euclidean division to write $n=qd+r$ with $0\leq r<d$. Since $f^d(x)=x$, repeated use of the iterate law gives $f^{qd}(x)=x$. Hence

$$
x=f^n(x)=f^{qd+r}(x)=f^r(f^{qd}(x))=f^r(x).
$$

If $r>0$, this contradicts the minimality of $d$. Therefore $r=0$, so $d\mid n$. $\square$

In particular, the positive return times of a periodic state are exactly the positive multiples of its minimal period.

### 2.2 Observation and semiconjugacy

Let $(X,f)$ be a source system and $(Y,g)$ an observed system. An **observation map** is a function $h:X\to Y$. We call it **dynamically consistent**, or a **semiconjugacy**, if

$$
h\circ f=g\circ h.
$$

No injectivity or surjectivity is included in this definition. Thus $h$ may forget information, and some states of $Y$ may never occur as observations.

If $h$ is injective, we call it a **faithful observation**. If $h$ is bijective, it is a change of coordinates between the two systems; the inverse then also respects the dynamics. The pointwise preservation result below needs only injectivity, not surjectivity.

The one-step consistency equation propagates to all times.

**Lemma 2.2 (Iteration of semiconjugacy).** If $h\circ f=g\circ h$, then for every nonnegative integer $k$ and every $x\in X$,

$$
h(f^k(x))=g^k(h(x)).
$$

**Proof sketch.** Induct on $k$. At $k=0$, both sides equal $h(x)$. If the identity holds at $k$, then

$$
h(f^{k+1}(x))=h(f(f^k(x)))=g(h(f^k(x)))=g(g^k(h(x)))=g^{k+1}(h(x)).
$$

This completes the induction. $\square$

The lemma states that the complete observed trajectory is obtained by applying $h$ pointwise to the source trajectory.

## 3. The observation divisibility theorem

We now prove the main result.

**Theorem 3.1 (Observation Divisibility Theorem).** Let $f:X\to X$ and $g:Y\to Y$ be self-maps, and let $h:X\to Y$ satisfy $h\circ f=g\circ h$. If $x\in X$ is periodic, then

$$
\operatorname{per}_g(h(x))\mid \operatorname{per}_f(x).
$$

**Proof sketch.** Let $n=\operatorname{per}_f(x)$. By definition, $f^n(x)=x$. Applying Lemma 2.2 gives

$$
g^n(h(x))=h(f^n(x))=h(x).
$$

Thus $n$ is a return time of $h(x)$. If $d=\operatorname{per}_g(h(x))$, Lemma 2.1 implies $d\mid n$. $\square$

The proof separates into two elementary facts. First, semiconjugacy transports every source return to an observed return. Second, the minimal observed return divides every observed return. Their combination yields the arithmetic constraint.

**Corollary 3.2 (No incompatible observed periods).** A source state of exact period $n$ cannot be observed with exact period $d$ unless $d$ is a positive divisor of $n$.

For example, an exact period-$12$ state may be observed with period $1$, $2$, $3$, $4$, $6$, or $12$, but not period $5$, $7$, or $8$.

**Corollary 3.3 (Fixed points remain fixed).** If $f(x)=x$, then $g(h(x))=h(x)$.

This follows either directly from semiconjugacy or from Theorem 3.1, since the only positive divisor of $1$ is $1$.

**Remark 3.4 (Absence of regularity hypotheses).** Theorem 3.1 is valid for arbitrary sets and functions. Compactness, metrizability, continuity, finite fibers, and measurability play no role. In particular, finite-to-one observation is not required. The result is an orbitwise consequence of functional composition.

**Remark 3.5 (One-sided inference).** Observing period $d$ implies only that the hidden period is a multiple of $d$, provided the observation is dynamically consistent. Equality cannot be inferred without an additional faithfulness condition.

## 4. Faithful observations and exact-period transport

The loss permitted by Theorem 3.1 is entirely due to identification of source states. Injectivity eliminates it.

**Lemma 4.1 (Reflection of periodicity equations).** Let $h\circ f=g\circ h$, and suppose $h$ is injective. If

$$
g^n(h(x))=h(x)
$$

for some nonnegative integer $n$, then $f^n(x)=x$.

**Proof sketch.** By Lemma 2.2,

$$
h(f^n(x))=g^n(h(x))=h(x).
$$

Injectivity of $h$ yields $f^n(x)=x$. $\square$

Thus, under faithful observation, the source and observed states have exactly the same return-time equations.

**Theorem 4.2 (Faithful Observation Theorem).** Let $f:X\to X$ and $g:Y\to Y$ be self-maps, and let $h:X\to Y$ be an injective map satisfying $h\circ f=g\circ h$. For every periodic state $x\in X$,

$$
\operatorname{per}_g(h(x))=\operatorname{per}_f(x).
$$

**Proof sketch.** Let $n=\operatorname{per}_f(x)$ and $d=\operatorname{per}_g(h(x))$. Theorem 3.1 gives $d\mid n$. Since $d$ is an observed return time, Lemma 4.1 makes it a source return time. By minimality of $n$, Lemma 2.1 gives $n\mid d$. Positive integers dividing one another are equal, so $d=n$. Equivalently, one may note that Lemma 2.2 and Lemma 4.1 show that source and observed return-time sets coincide. $\square$

**Corollary 4.3 (Pointwise transport of exact-period strata).** Under the hypotheses of Theorem 4.2, for every positive integer $n$ and every $x\in X$,

$$
\operatorname{per}_f(x)=n
\quad\Longleftrightarrow\quad
\operatorname{per}_g(h(x))=n.
$$

This statement is pointwise: every state retains its exact period. Surjectivity of $h$ is unnecessary because the conclusion concerns observed states in the image $h(X)$. If $h$ is also surjective, then the entire exact-period spectrum is shared by the two systems.

Define the **exact-period spectrum** of $f$ by

$$
\Sigma(f)=\{n\in\mathbb{N}_{>0}:\text{there exists }x\in X\text{ with }\operatorname{per}_f(x)=n\}.
$$

**Corollary 4.4 (Spectrum equality under bijective semiconjugacy).** If $h$ is bijective and $h\circ f=g\circ h$, then

$$
\Sigma(f)=\Sigma(g).
$$

**Proof sketch.** Injectivity transports the exact period of each $x$ to $h(x)$. Surjectivity ensures every $y\in Y$ is of the form $h(x)$, so no period in the observed system lies outside the transported image. $\square$

For a noninjective semiconjugacy, Theorem 3.1 gives the weaker pointwise statement that each realized observed period divides a corresponding source period. If $h$ is surjective, this implies that $\Sigma(g)$ is contained in the divisor closure of $\Sigma(f)$.

## 5. Prime-period rigidity

Prime numbers make Theorem 3.1 especially sharp.

**Theorem 5.1 (Prime-Period Observation Dichotomy).** Let $h\circ f=g\circ h$. If $x$ has exact period $p$ under $f$, where $p$ is prime, then

$$
\operatorname{per}_g(h(x))=1
\quad\text{or}\quad
\operatorname{per}_g(h(x))=p.
$$

**Proof sketch.** Theorem 3.1 says that the observed minimal period divides $p$. The only positive divisors of a prime are $1$ and $p$. $\square$

**Corollary 5.2 (Faithful preservation of prime periods).** Under the assumptions of Theorem 5.1, if $h$ is injective, then

$$
\operatorname{per}_g(h(x))=p.
$$

This follows immediately from Theorem 4.2. More locally, it suffices for $h$ to be injective on the source orbit of $x$.

The dichotomy can also be understood through invariant equivalence relations. Restrict attention to a prime cycle

$$
C=\{x,f(x),\ldots,f^{p-1}(x)\}.
$$

The observation induces an equivalence relation on $C$ by declaring two phases equivalent when they have the same image. Semiconjugacy makes this relation invariant under cyclic rotation. On a cycle of prime size, a rotation-invariant equivalence relation is either discrete or universal. In the discrete case all phases remain distinct and the observed period is $p$; in the universal case all phases coincide and the observed state is fixed.

## 6. Sharpness and finite-cycle constructions

The divisor conclusion cannot be strengthened. Every divisor of a cycle length can occur as the exact observed period.

Let $n$ be a positive integer and let $d\mid n$. Define

$$
X=\mathbb{Z}/n\mathbb{Z},\qquad Y=\mathbb{Z}/d\mathbb{Z}.
$$

Let both dynamics advance by one residue:

$$
f([k]_n)=[k+1]_n,\qquad g([j]_d)=[j+1]_d.
$$

Define the observation by reduction modulo $d$:

$$
h([k]_n)=[k]_d.
$$

This is well-defined because $d\mid n$: changing $k$ by a multiple of $n$ also changes it by a multiple of $d$. Moreover,

$$
h(f([k]_n))=[k+1]_d=g([k]_d)=g(h([k]_n)),
$$

so $h$ is a semiconjugacy. Every source state has exact period $n$, while every observed state has exact period $d$.

**Proposition 6.1 (Sharp realization of every divisor).** For every pair of positive integers $d,n$ with $d\mid n$, there exist finite dynamical systems and a surjective semiconjugacy carrying an exact period-$n$ state to an exact period-$d$ state.

**Proof sketch.** Use the residue-cycle construction above. The translation by one on $\mathbb{Z}/m\mathbb{Z}$ has exact period $m$ at every point, and reduction modulo $d$ commutes with translation. $\square$

For $n=6$, this realizes observed periods $1$, $2$, $3$, and $6$. Reduction modulo $3$ identifies phases separated by three source steps; reduction modulo $2$ identifies phases separated by two source steps; reduction modulo $1$ identifies all phases.

This construction also quantifies fiber size. Every observed phase has exactly $n/d$ source phases above it. Nevertheless, Theorem 3.1 does not depend on fibers being finite or equally sized. The finite model is an illustration, not a restriction.

## 7. Algorithms and numerical demonstrations

The theorems lead to straightforward procedures for finite systems represented by arrays. Suppose $X=\{0,\ldots,N-1\}$ and $Y=\{0,\ldots,M-1\}$. Store $f$, $g$, and $h$ as arrays whose entries are successor or image indices.

### 7.1 Semiconjugacy audit

For each $x\in X$, compare $h(f(x))$ with $g(h(x))$. If any comparison fails, the observed variable does not define a closed deterministic factor with update $g$.

The audit uses $N$ comparisons, so its time complexity is $O(N)$ and its auxiliary space complexity is $O(1)$ beyond the input arrays.

### 7.2 Minimal-period detection

Starting from $x$, repeatedly apply $f$ until returning to $x$. If a different state repeats first, then $x$ is not periodic within its eventual component and has no positive return to itself. In a finite system, storing first-visit times detects either event within at most $N+1$ visited states. The procedure runs in $O(N)$ time and $O(N)$ space; Floyd’s cycle algorithm can reduce auxiliary space to $O(1)$ when only cycle structure is needed.

For a known cyclic permutation, direct iteration until the first return is sufficient.

### 7.3 Period-transport audit

After verifying semiconjugacy, compute $n=\operatorname{per}_f(x)$ and $d=\operatorname{per}_g(h(x))$. Confirm $n\bmod d=0$. If $h$ is injective on the orbit of $x$, confirm $n=d$. Across all initial states, this direct method is at most quadratic in the number of states, although strongly connected components and cycle decomposition can compute all periods in linear time.

The supplied numerical examples instantiate residue cycles, enumerate all divisors of several source periods, demonstrate faithful relabelings, and verify the prime-period dichotomy.

## 8. Applications and interpretation

### 8.1 Coarse-grained dynamical models

A coarse-graining groups detailed states into macrostates. When the partition is compatible with the update rule, the macrostate evolves deterministically and the quotient map is a semiconjugacy. Theorem 3.1 then says that coarse-graining may speed up apparent recurrence only by an integer factor dividing the true period.

This provides a validation test. If a proposed deterministic coarse model maps a hidden exact $n$-cycle to an observed exact $d$-cycle with $d\nmid n$, then at least one modeling assumption is wrong: the observation may not commute with the dynamics, the periods may have been misidentified, or the observed evolution may not be deterministic.

### 8.2 Cognitive and behavioral observation

In a cognitive model, a full state may include latent memory, context, neural activation, and environmental variables, while an experiment records only a response category. If response categories evolve autonomously under a deterministic rule, they form an observed factor. A repeated behavioral response can then conceal a longer latent cycle, but its period must divide the latent period.

This distinction prevents a fixed observed response from being mistaken for a fixed hidden state. A constant output may sit above any hidden cycle if the observation identifies all its phases. Conversely, a faithful code on the relevant orbit certifies exact preservation.

### 8.3 Sensor design and state encoding

The Faithful Observation Theorem gives a qualitative design principle: distinguish all phases of any orbit whose exact recurrence matters. Global injectivity is stronger than necessary; injectivity restricted to the target orbit suffices. For a finite family of relevant cycles, a sensor can therefore be designed to separate only states lying on those cycles.

Prime cycles are particularly useful calibration objects. Because a prime cycle admits no intermediate observed period, a nonconstant dynamically consistent signal on that cycle necessarily exhibits the full prime rhythm.

### 8.4 Symbolic dynamics and logging

A log or symbolic code maps detailed states to labels. If the next label is determined solely by the current label and the coding commutes with the update, the code defines a factor system. Period divisibility then applies. If identical labels can have different successor labels, no single-valued $g$ exists, and the deterministic semiconjugacy framework must be replaced by a nondeterministic or history-dependent model.

### 8.5 Distinguishing topology from probability

The present results concern exact pointwise recurrence. They do not assign probabilities to periodic states or infer population incidence from topological density. A dense set may have measure zero, while a nondense basin may have positive measure. Applications involving lifetime recurrence or prevalence require a probability measure and an explicitly defined event. Period divisibility remains valid orbitwise but does not by itself provide percentages.

## 9. Discussion, limitations, and future work

The observation divisibility law isolates an elementary algebraic core of recurrence transport. Its strength is exactness and generality; its limitation is locality. It describes the minimal period of a particular observed state, not the full complexity of an infinite system.

A first extension is spectrum-level transport. For a surjective semiconjugacy, the observed exact-period spectrum should lie in the divisor closure of the source spectrum. Under bijective semiconjugacy, Corollary 4.4 gives equality. Explicit quotient cycles show that divisor closure is the best general target.

A second extension concerns topological entropy. Entropy measures exponential orbit complexity rather than exact return time. In compact metric systems it is invariant under topological conjugacy, while factor maps generally lead to an inequality rather than equality. Such results require continuity, compactness, and the selected definition of entropy—hypotheses intentionally absent from the pointwise theorem.

A third direction concerns Li–Yorke chaos. Proximality and repeated separation are metric properties. Their transport requires control stronger than a set-theoretic semiconjugacy, such as a uniform equivalence for two-way preservation. Injectivity alone does not provide quantitative distortion bounds.

A fourth direction is quantitative observability. Period three is classically associated with rich interval dynamics, but a lossy observation can erase the forced structure. If the three orbit phases are separated by a positive observational margin and the maps have controlled moduli of continuity, one may seek exponential lower bounds on distinguishable observation words of length $n$.

A fifth direction concerns robust recurrence in parametrized systems. For families such as the logistic maps, exact periodic points, attracting basins, and parameter windows should be distinguished. Robust observed recurrence is naturally measured by basin measure and stability, not by the cardinality or density of periodic points.

Finally, tropical dynamics offers an analogue in which an eigenvalue represents additive drift. Ordinary periodicity requires vanishing drift, while passage to projective space quotients out global additive offsets. This resembles observation-induced collapse: a motion that is nonperiodic in the full state may become fixed after a quotient.

## 10. Conclusion

A dynamically consistent observation transforms recurrence according to a simple arithmetic rule. If a source state has minimal period $n$, its observed minimal period divides $n$. Injectivity reflects all periodicity equations and forces equality, yielding exact pointwise transport of period strata. For prime $n=p$, every observation faces a rigid alternative: preserve the $p$-cycle or collapse it to a fixed point. Finite residue cycles realize every permitted divisor, proving that the law is sharp.

These results supply a clean baseline for the mathematics of observation. Before invoking topology, probability, entropy, or chaos, one can ask whether the observation commutes with time evolution and whether it distinguishes the relevant states. Those two structural questions determine the exact fate of a periodic rhythm: faithful observation keeps the beat, while information loss can shorten it only by divisibility.
