# Exact Coverings by Distinct Unit Fractions: Structure, Obstructions, and Finitisation

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

An *exact Egyptian covering* is a finite set $S$ of integers, each at least $2$, with $\sum_{n\in S} 1/n = 1$. The Erdős–Graham problem asks whether every finite colouring of the integers $\ge 2$ admits a monochromatic exact covering — a question answered affirmatively by Croot in 2003 via a hard analytic argument. This paper develops the combinatorial and arithmetic anatomy of the problem, independently of the analytic proof.

We determine the cardinality spectrum of exact coverings exactly: coverings of size $k$ exist precisely for $k \ge 3$, with the lower bound coming from a sharp two-term inequality and the upper unboundedness from the splitting identity $1/m = 1/(m+1) + 1/(m(m+1))$. We prove that the unique three-term covering is $\{2,3,6\}$, and that every covering $S$ contains an element $\le |S|$ and an element $\ge |S|$.

On the colouring side we isolate the standard first step — every finite colouring has a colour class of divergent reciprocal sum — and prove it from a purely rational dyadic estimate $\sum_{n=2}^{2^k} 1/n \ge k/2$, requiring no real analysis. We then prove that this step can *never* be completed by mass considerations alone: we exhibit a set of divergent reciprocal sum containing no exact covering, namely the primes. The mechanism is a local $p$-adic obstruction: in any exact covering, the maximal power of a prime $p$ dividing a denominator is attained at least twice. Consequently every $p$-adically separated set — in particular every pairwise coprime family, the primes, and the prime powers — is covering-free.

A second, independent obstruction arises from a duality with classical divisor arithmetic: for $N>0$, $N$ is pseudoperfect if and only if some exact covering consists of divisors of $N$, the correspondence being $d \mapsto N/d$. Deficiency of $N$ therefore makes the divisors of $N$ covering-free, a *global* mass obstruction invisible to the $p$-adic argument. The weird number $70$ shows that neither obstruction subsumes the other and that together they are not exhaustive: its divisor set is covering-free, abundant, and not $p$-adically separated.

Finally we prove a compactness finitisation: for each $r$, the Erdős–Graham property for $r$ colours is equivalent to the existence of a bound $N$ such that every $r$-colouring admits a monochromatic exact covering with all denominators $\le N$. The proof takes an ultrafilter limit of bad colourings; the finiteness of the palette is exactly what makes the diagonalisation uniform. The equivalence is structural but not quantitative: it produces no bound. For one colour the optimal bound is $N=6$; for two colours we exhibit an explicit colouring of $\{2,\dots,55\}$, both of whose classes have reciprocal mass above $1.7$, in which neither class contains an exact covering, so the least two-colour bound exceeds $55$.

**Keywords:** Egyptian fractions, unit fractions, Erdős–Graham conjecture, Ramsey theory, $p$-adic valuation, pseudoperfect numbers, weird numbers, compactness.

---

## 1. Introduction

### 1.1 The object of study

Egyptian fraction representations — sums of distinct reciprocals of positive integers — are among the oldest surviving mathematical formalisms, and they remain a persistent source of hard elementary problems. The particular object studied here is the exact decomposition of unity.

**Definition 1.1 (Exact Egyptian covering).** A finite set $S \subseteq \mathbb{N}$ is an *exact Egyptian covering*, or simply a *covering*, if

1. every $n \in S$ satisfies $n \ge 2$, and
2. $\displaystyle\sum_{n \in S} \frac{1}{n} = 1$.

Because $S$ is a set, the denominators are automatically distinct; the condition $n \ge 2$ excludes the degenerate representations $1 = 1/1$ and any appeal to $1/0$. The archetype is
$$1 = \tfrac12 + \tfrac13 + \tfrac16, \qquad S = \{2,3,6\}.$$

**Definition 1.2 (Covering-free set).** A set $A \subseteq \mathbb{N}$ is *covering-free* (equivalently, *Egyptian-free*) if no finite subset of $A$ is an exact covering.

**Definition 1.3 (Divergent reciprocals).** A set $A \subseteq \mathbb{N}$ *has divergent reciprocals* if for every rational $M$ there is a finite $F \subseteq A$ with $\sum_{n\in F} 1/n > M$.

We phrase divergence in this finite-partial-sum form deliberately: it is a purely rational, purely combinatorial condition, and the entire development below stays inside $\mathbb{Q}$.

**Definition 1.4 (The colouring property).** For $r \in \mathbb{N}$, the *Erdős–Graham property for $r$ colours*, written $\mathrm{EG}(r)$, asserts: for every map $c$ from the integers to a palette of $r$ colours there exist an exact covering $S$ and a colour $i$ with $c(n) = i$ for all $n \in S$. The $i$-th *colour class* of $c$ is $C_i = \{ n \ge 2 : c(n) = i\}$.

**The Erdős–Graham conjecture** is the assertion that $\mathrm{EG}(r)$ holds for every finite $r$. It was proved by Croot (2003) using estimates on smooth numbers; the argument is genuinely analytic. Our aim is orthogonal: to describe the combinatorial structure of the objects involved, to prove the elementary parts unconditionally, and to identify precisely which obstructions rule out the elementary routes.

### 1.2 Summary of results

- §2: the cardinality spectrum is exactly $\{k : k \ge 3\}$ (Theorems 2.2, 2.6, 2.7), the three-term covering is unique (Theorem 2.3), and every covering brackets its own size (Theorem 2.1).
- §3: the pigeonhole step, from a rational dyadic bound (Theorems 3.1, 3.3).
- §4: the local $p$-adic obstruction (Theorem 4.1) and its consequences: pairing (Corollaries 4.2, 4.3), the separation criterion (Theorem 4.5), covering-freeness of the primes and prime powers (Corollaries 4.7, 4.8), and the failure of "divergence implies covering" (Theorem 4.9).
- §5: explicit coverings evading the obstructions, and two unconditional two-colour theorems (Theorems 5.1, 5.2, 5.3, 5.4).
- §6: the pseudoperfect duality (Theorem 6.2), the global mass obstruction (Theorem 6.6), and the incompleteness of the two-obstruction picture via the weird number $70$ (Theorem 6.8).
- §7: the compactness finitisation (Theorem 7.3), the one-colour bound (Proposition 7.4), and a computational two-colour lower bound (Observation 7.5).
- §8: algorithms. §9: discussion and open problems.

---

## 2. The structure of exact coverings

### 2.1 Bracketing the cardinality

**Theorem 2.1 (Bracketing).** Let $S$ be an exact covering. Then $S \ne \varnothing$, and

1. there exists $n \in S$ with $n \le |S|$;
2. there exists $n' \in S$ with $n' \ge |S|$.

*Proof.* Nonemptiness is immediate: the empty sum is $0 \ne 1$.

(1) Let $m = \min S$. Then $m \ge 2$, and for every $n \in S$ we have $1/n \le 1/m$. Hence
$$1 = \sum_{n\in S}\frac1n \le \sum_{n \in S}\frac1m = \frac{|S|}{m},$$
so $m \le |S|$.

(2) Let $M = \max S$. Then for every $n \in S$, $1/n \ge 1/M$, so
$$1 = \sum_{n\in S}\frac1n \ge \frac{|S|}{M},$$
whence $|S| \le M$. $\square$

Both halves are equalities exactly when $S$ is constant, which a set cannot be unless $|S|=1$; so both inequalities are strict for $|S| \ge 2$. The bracketing has a practical corollary: a covering whose denominators all exceed $K$ must have more than $K$ elements. In particular the $23$-element covering of Theorem 5.3, with minimum $10$, is not far from optimal in size for its constraint.

### 2.2 No short coverings

**Theorem 2.2 (Minimum size).** Every exact covering has at least three elements.

*Proof.* Nonemptiness gives $|S| \ge 1$. If $|S| = 1$, say $S = \{a\}$ with $a \ge 2$, then $1/a = 1$ forces $a=1$, a contradiction. If $|S| = 2$, say $S = \{a,b\}$ with $a \ne b$ and both $\ge 2$, then one of the two — say $b$ after relabelling — satisfies $b \ge 3$. Hence
$$\frac1a + \frac1b \le \frac12 + \frac13 = \frac56 < 1,$$
contradicting $\sum = 1$. $\square$

The key inequality is elementary but must be applied carefully: it is not enough that both denominators be $\ge 2$; distinctness is what forces the larger to be $\ge 3$.

### 2.3 The unique smallest covering

**Theorem 2.3 (Classification in size three).** If $S$ is an exact covering with $|S| = 3$, then $S = \{2,3,6\}$.

*Proof.* Write $S = \{a,b,c\}$ with $a<b<c$; all are $\ge2$ and $1/a+1/b+1/c = 1$.

*Step 1: $a=2$.* Since $1/b < 1/a$ and $1/c < 1/a$, we get $1 < 3/a$, i.e. $a < 3$. With $a \ge 2$, $a = 2$.

*Step 2: $b=3$.* Now $1/b + 1/c = 1/2$, and $1/c < 1/b$, so $1/2 < 2/b$, i.e. $b < 4$. Since $b > a = 2$, $b = 3$.

*Step 3: $c=6$.* Then $1/c = 1/2 - 1/3 = 1/6$, so $c = 6$. $\square$

An unordered $3$-element covering reduces to the sorted case by trichotomy on the three pairwise comparisons; the classification is therefore complete.

### 2.4 The splitting operator

**Lemma 2.4 (Splitting identity).** For every $m \ge 1$,
$$\frac1m = \frac{1}{m+1} + \frac{1}{m(m+1)}.$$

*Proof.* $\dfrac{1}{m+1}+\dfrac{1}{m(m+1)} = \dfrac{m + 1}{m(m+1)} = \dfrac1m$. $\square$

**Theorem 2.5 (Splitting operator).** Let $S$ be an exact covering, let $m \in S$ satisfy $n \le m$ for all $n\in S$ (i.e. $m = \max S$), and set
$$T = \bigl(S\setminus\{m\}\bigr) \cup \{\,m+1,\; m(m+1)\,\}.$$
Then $T$ is an exact covering, $|T| = |S| + 1$, and $m(m+1) = \max T$.

*Proof.* Since $m \ge 2$ we have $m < m+1 < m(m+1)$, and both new elements strictly exceed $\max S = m$, so neither lies in $S\setminus\{m\}$ and the two are distinct. Hence $|T| = (|S|-1) + 2 = |S|+1$. All elements of $T$ are $\ge 2$: the inherited ones by hypothesis, and $m+1 \ge 3$, $m(m+1) \ge 6$. For the sum, writing $\Sigma' = \sum_{n \in S\setminus\{m\}} 1/n = 1 - 1/m$,
$$\sum_{n\in T}\frac1n = \frac{1}{m+1} + \frac{1}{m(m+1)} + \Sigma' = \frac1m + \left(1 - \frac1m\right) = 1$$
by Lemma 2.4. Finally every inherited element is $\le m < m(m+1)$, and $m+1 < m(m+1)$, so $\max T = m(m+1)$. $\square$

The maximality hypothesis on $m$ is not cosmetic. Splitting a non-maximal element can reintroduce a denominator already present, and the "set" structure would silently absorb the duplicate, destroying the sum. Because the operator returns a covering with a *known* maximum, it can be iterated indefinitely.

**Theorem 2.6 (Existence in every size $\ge 3$).** For every $k \ge 3$ there is an exact covering with exactly $k$ elements.

*Proof.* By induction we prove the stronger statement: for every $j \ge 0$ there is an exact covering $S_j$ with $|S_j| = j+3$ possessing a maximum. Base: $S_0 = \{2,3,6\}$, with maximum $6$. Step: apply Theorem 2.5 to $S_j$ and its maximum, obtaining $S_{j+1}$ of size $j+4$ with maximum $m(m+1)$. Taking $j = k-3$ finishes. $\square$

The concrete ladder from $\{2,3,6\}$ is
$$\{2,3,6\},\quad \{2,3,7,42\},\quad \{2,3,7,43,1806\},\quad \{2,3,7,43,1807,3263442\},\ \dots$$
whose maxima follow Sylvester's sequence. (Many other ladders exist; splitting the maximum is only the most convenient choice for a uniform proof.)

**Theorem 2.7 (Cardinality spectrum).** There exists an exact covering of cardinality $k$ if and only if $k \ge 3$.

*Proof.* Combine Theorems 2.2 and 2.6. $\square$

---

## 3. The pigeonhole step

Every known approach to the colouring problem begins by locating a "large" colour class. We make this precise and prove it without any analysis.

**Theorem 3.1 (Dyadic harmonic lower bound).** For every $k \ge 0$,
$$\sum_{n=2}^{2^{k}} \frac1n \;\ge\; \frac k2$$
as an inequality of rational numbers.

*Proof.* Induction on $k$. For $k=0$ the sum is empty and the bound is $0$. Assume the bound for $k$. Split
$$\sum_{n=2}^{2^{k+1}} \frac1n = \sum_{n=2}^{2^{k}}\frac1n + \sum_{n = 2^k+1}^{2^{k+1}}\frac1n .$$
The second block has exactly $2^{k+1}-2^k = 2^k$ terms, each at least $1/2^{k+1}$, so it is at least $2^k/2^{k+1} = 1/2$. Adding to the inductive hypothesis gives $\ge k/2 + 1/2 = (k+1)/2$. $\square$

**Corollary 3.2.** The set $\{n : n \ge 2\}$ has divergent reciprocals: given $M \in \mathbb{Q}$, choose $k > 2M+1$ and take $F = \{2,\dots,2^k\}$.

**Theorem 3.3 (Some colour class is reciprocally large).** For every $r$ and every colouring $c$ of the integers $\ge 2$ with $r$ colours, some colour class $C_i$ has divergent reciprocals.

*Proof.* Suppose not. Then for each colour $i$ there is $M_i \in \mathbb{Q}$ with $\sum_{n\in F} 1/n \le M_i$ for every finite $F \subseteq C_i$. Put $M = \sum_{i} M_i$. By Corollary 3.2 there is a finite $F$ of integers $\ge 2$ with $\sum_{n\in F} 1/n > M$. Partitioning $F$ into fibres $F_i = \{n \in F : c(n) = i\}$ and summing fibrewise,
$$\sum_{n \in F}\frac1n = \sum_{i}\sum_{n\in F_i}\frac1n \le \sum_i M_i = M,$$
a contradiction. $\square$

Theorem 3.3 is where the finiteness of the palette first enters, and it enters only through the finite sum $\sum_i M_i$.

---

## 4. The local obstruction

We now show that Theorem 3.3 can never be upgraded to a proof of the conjecture, because reciprocal largeness carries no information about exact representability.

Throughout, $v_p(n)$ denotes the $p$-adic valuation of a positive integer $n$: the exponent of $p$ in its factorisation. We extend it to rationals by $v_p(x/y) = v_p(x) - v_p(y)$; recall the ultrametric inequality $v_p(x+y) \ge \min(v_p(x), v_p(y))$, with equality when $v_p(x) \ne v_p(y)$.

**Theorem 4.1 (Local obstruction).** Let $S$ be an exact covering, let $p$ be prime, and let $m \in S$ satisfy $v_p(m) > 0$. Then there is $n \in S$ with $n \ne m$ and $v_p(n) \ge v_p(m)$.

*Proof.* Suppose not: $v_p(n) < v_p(m) =: e \ge 1$ for all $n \in S \setminus \{m\}$. For each $n$, $v_p(1/n) = -v_p(n)$. Hence $v_p(1/m) = -e$ while $v_p(1/n) > -e$ for every other term. The minimum of the valuations over the terms of the sum is therefore attained uniquely, at $m$. By the ultrametric equality case (applied inductively over the terms),
$$v_p\Bigl(\sum_{n\in S}\frac1n\Bigr) = -e < 0 .$$
But the sum equals $1$ and $v_p(1) = 0$. Contradiction. $\square$

Equivalently: *in an exact covering, the maximal power of any prime dividing a denominator is attained at least twice.* The verification on $\{2,3,6\}$ is instructive: for $p=2$ the maximum $v_2 = 1$ is attained at $2$ and $6$; for $p=3$ the maximum $v_3 = 1$ at $3$ and $6$.

**Corollary 4.2 (Pairing).** For every prime $p$ and every exact covering $S$, the number of elements of $S$ divisible by $p$ is never exactly $1$.

*Proof.* If $m$ were the unique multiple of $p$ in $S$, then $v_p(m) \ge 1 > 0$, and Theorem 4.1 provides $n \ne m$ in $S$ with $v_p(n) \ge v_p(m) \ge 1$, so $p \mid n$ — a second multiple. $\square$

**Corollary 4.3 (Parity).** An exact covering never contains exactly one even number. $\square$

### 4.1 $p$-adic separation

**Definition 4.4.** A set $A \subseteq \mathbb{N}$ is *$p$-adically separated* if for every prime $p$ and all distinct $m, n \in A$, the equality $v_p(m) = v_p(n)$ forces $v_p(m) = 0$. Equivalently: no two distinct members of $A$ share the same positive valuation at any prime.

**Theorem 4.5 (Separation criterion).** Every $p$-adically separated set is covering-free.

*Proof.* Let $A$ be $p$-adically separated and suppose $S \subseteq A$ is an exact covering. Pick $x \in S$; then $x \ge 2$, so some prime $p$ divides $x$ and $v_p(x) \ge 1$. Let $m \in S$ maximise $v_p$; then $v_p(m) \ge v_p(x) > 0$. By Theorem 4.1 there is $n \in S$, $n \ne m$, with $v_p(n) \ge v_p(m)$; maximality forces $v_p(n) = v_p(m) > 0$. But $m,n$ are distinct members of $A$ with the same positive valuation, contradicting separation. $\square$

**Lemma 4.6.** A pairwise coprime family of integers is $p$-adically separated.

*Proof.* If distinct $m,n \in A$ had $v_p(m) = v_p(n) > 0$, then $p \mid m$ and $p \mid n$, so $p \mid \gcd(m,n) = 1$ — impossible for a prime. $\square$

**Corollary 4.7.** Every pairwise coprime set of integers $\ge 2$ is covering-free. In particular the set of primes is covering-free. $\square$

**Corollary 4.8.** The set of prime powers $\{p^e : p \text{ prime},\, e \ge 1\}$ is covering-free.

*Proof.* Let $x \ne y$ be prime powers with $v_p(x) = v_p(y) > 0$ for some prime $p$. Positive valuation at $p$ forces $p \mid x$ and $p \mid y$; a prime power divisible by $p$ is a power of $p$. So $x = p^a$, $y = p^b$ with $a = v_p(x) = v_p(y) = b$, whence $x = y$ — contradiction. Thus the prime powers are $p$-adically separated, and Theorem 4.5 applies. $\square$

### 4.2 Divergence is not sufficient

**Theorem 4.9 (Insufficiency of mass).** There exists a set $A$ of integers $\ge 2$ that has divergent reciprocals and is covering-free.

*Proof.* Take $A$ to be the set of primes. Divergence is Euler's theorem on $\sum_p 1/p$ (in the finite-partial-sum form of Definition 1.3), and covering-freeness is Corollary 4.7. $\square$

**Consequence.** The pigeonhole step of Theorem 3.3 cannot, by itself, prove the Erdős–Graham conjecture: it produces a reciprocally large colour class, and reciprocal largeness is provably compatible with the total absence of exact coverings. Any proof must exploit arithmetic structure of the colour class beyond its size — which is exactly what Croot's analytic argument, working with smooth numbers, supplies.

---

## 5. Explicit coverings that evade the obstructions

The obstructions of §4 identify sets that *cannot* contain coverings. It is equally important to know that the complements of those sets *do*.

**Theorem 5.1 (A covering avoiding all prime powers).** The $21$-element set
$$S_{\mathrm{npp}} = \{6, 10, 12, 14, 15, 18, 20, 21, 22, 24, 28, 30, 33, 36, 40, 42, 44, 45, 55, 60, 63\}$$
is an exact covering, and no member of $S_{\mathrm{npp}}$ is a prime power.

*Proof (verification).* Every listed number divides $27720 = 2^3\cdot3^2\cdot5\cdot7\cdot11$; writing each $1/n$ as $(27720/n)/27720$ and summing the numerators gives exactly $27720$. Each member has at least two distinct prime factors — e.g. $6 = 2\cdot3$, $55 = 5\cdot 11$, $63 = 3^2 \cdot 7$ — hence is not a prime power. $\square$

**Theorem 5.2 (Unconditional two-colour instance, prime-power version).** Let $c$ be a $2$-colouring of the integers $\ge 2$ such that colour $0$ is used only on prime powers. Then $c$ admits a monochromatic exact covering.

*Proof.* $S_{\mathrm{npp}}$ of Theorem 5.1 contains no prime powers, so no member receives colour $0$; with only two colours, every member receives colour $1$. $\square$

**Theorem 5.3 (A covering avoiding all small denominators).** The $23$-element set
$$S_{\ge 10} = \{10, 11, 12, 14, 15, 16, 18, 20, 21, 22, 24, 28, 30, 33, 36, 40, 42, 45, 48, 55, 60, 63, 66\}$$
is an exact covering with $\min S_{\ge 10} = 10$. $\square$

**Theorem 5.4 (Unconditional two-colour instance, small-denominator version).** Let $c$ be a $2$-colouring of the integers $\ge 2$ using colour $0$ only on integers $< 10$. Then $c$ admits a monochromatic exact covering, namely $S_{\ge 10}$ in colour $1$. $\square$

By Theorem 2.1, any covering with minimum $\ge 10$ must have at least $11$ elements, so $S_{\ge 10}$ is within a factor of about two of the theoretical minimum size for its constraint. More generally, the existence of coverings with arbitrarily large minimum — see §9, Conjecture C1 — would immediately settle Erdős–Graham for every colouring possessing a cofinite colour class.

---

## 6. The global obstruction: duality with pseudoperfect numbers

### 6.1 The duality

**Definition 6.1.** A positive integer $N$ is *pseudoperfect* (semiperfect) if some set of distinct **proper** divisors of $N$ sums to $N$. It is *perfect* if the set of *all* proper divisors sums to $N$; *deficient* if that sum is $< N$; *abundant* if $> N$; and *weird* if it is abundant but not pseudoperfect.

**Theorem 6.2 (Divisor duality).** For $N > 0$: $N$ is pseudoperfect if and only if there is an exact covering all of whose elements divide $N$.

*Proof.* Divisor complementation $\delta: d \mapsto N/d$ is an involution on the divisors of $N$, hence injective on any set of divisors.

($\Rightarrow$) Let $D$ be a set of distinct proper divisors with $\sum_{d\in D} d = N$. Put $S = \delta(D)$. Then $|S| = |D|$ and, dividing the sum by $N$,
$$\sum_{d \in D}\frac{d}{N} = 1, \qquad\text{i.e.}\qquad \sum_{s\in S}\frac1s = 1 ,$$
since $d/N = 1/(N/d)$. Each $s = N/d$ divides $N$; and $s \ge 2$ because $d$ proper means $d < N$, hence $N/d > 1$.

($\Leftarrow$) Let $S$ be an exact covering with every $s \mid N$. Put $D = \delta(S)$; the elements are distinct divisors of $N$, and each is proper because $s \ge 2$ gives $N/s < N$. Multiplying $\sum_{s\in S} 1/s = 1$ by $N$ gives $\sum_{d\in D} d = N$. $\square$

**Corollary 6.3.** The least common multiple of any exact covering is pseudoperfect. (Every member divides the lcm; apply Theorem 6.2 backwards.) For $\{2,3,6\}$ the lcm is $6$, which is perfect. $\square$

**Corollary 6.4.** Every perfect number $N$ carries an exact covering by its divisors. For $N=6$: $1 = \frac16+\frac13+\frac12$. For $N=28$: $1 = \frac{1}{28}+\frac{1}{14}+\frac17+\frac14+\frac12$. $\square$

Also worth recording, as the divisor-side shadow of Theorem 2.2:

**Proposition 6.5.** Any set $D$ of distinct proper divisors of $N>0$ with $\sum_{d\in D} d = N$ has $|D| \ge 3$. (Apply $\delta$ and Theorem 2.2.) $\square$

### 6.2 Deficiency as a mass obstruction

**Theorem 6.6 (Mass obstruction).** If $N > 0$ is deficient, then $\{n : n \mid N,\ n \ge 2\}$ is covering-free.

*Proof.* If some exact covering consisted of divisors of $N$, then $N$ would be pseudoperfect by Theorem 6.2; but a pseudoperfect number has a subset of its proper divisors summing to $N$, hence its full proper-divisor sum is at least $N$, contradicting deficiency. $\square$

**Corollary 6.7.** For any prime $p$ and any $k$, the divisors of $p^k$ that are $\ge 2$ form a covering-free set, since prime powers are deficient ($\sum_{i<k} p^i = (p^k-1)/(p-1) < p^k$). $\square$

Corollary 6.7 re-derives part of Corollary 4.8 by a completely different route. The two obstructions are of genuinely different type:

- The **local** obstruction (§4) inspects one prime at a time and is insensitive to total mass;
- The **global** obstruction (Theorem 6.6) counts total mass and is insensitive to individual primes.

### 6.3 The two obstructions are not exhaustive

**Theorem 6.8 (Incompleteness of the two-obstruction picture).** There exists a set $A$ of integers $\ge 2$ that is covering-free, is *not* $p$-adically separated, and is *not* mass-deficient.

*Proof.* Take $A = \{n : n \mid 70,\ n \ge 2\} = \{2,5,7,10,14,35,70\}$.

*Covering-free:* $70$ is weird — its proper divisors $1,2,5,7,10,14,35$ sum to $74$, so it is abundant, but no sub-collection sums to exactly $70$ (a finite check over $2^7$ subsets). Hence $70$ is not pseudoperfect, and Theorem 6.2 gives covering-freeness of $A$.

*Not separated:* $2$ and $10$ both lie in $A$, are distinct, and have $v_2(2) = v_2(10) = 1 > 0$.

*Not deficient:* the proper divisor sum $74$ exceeds $70$. $\square$

So a third mechanism operates, and $70$ is its smallest instance: enough mass, no separation, and yet no exact representation. The phenomenon is precisely *weirdness* — abundance without pseudoperfectness — and Conjecture C2 in §9 asks whether weirdness is the only residual mechanism.

### 6.4 A colouring consequence

**Theorem 6.9.** Let $c$ be an $r$-colouring and suppose there are a colour $i$ and a pseudoperfect $N$ such that every divisor $n \ge 2$ of $N$ receives colour $i$. Then $c$ has a monochromatic exact covering.

*Proof.* By Theorem 6.2 there is an exact covering $S$ of divisors of $N$; every member is $\ge 2$ and divides $N$, hence has colour $i$. $\square$

An adversary must therefore break up the divisor lattice of every pseudoperfect number — a strong constraint, since pseudoperfect numbers have positive density.

---

## 7. Finitisation by compactness

The Erdős–Graham property quantifies over colourings of an infinite set. We now show it is equivalent to a finite statement.

**Definition 7.1.** For $r, N \in \mathbb{N}$, the *finite Erdős–Graham property* $\mathrm{EG}(r,N)$ asserts: for every $r$-colouring $c$ of the integers there exist an exact covering $S$ and a colour $i$ with $n \le N$ for all $n \in S$ and $c(n) = i$ for all $n \in S$.

**Proposition 7.2.** $\mathrm{EG}(r,N)$ is monotone in $N$ (if $N \le M$ and $\mathrm{EG}(r,N)$ holds then so does $\mathrm{EG}(r,M)$), and $\mathrm{EG}(r,N)$ implies $\mathrm{EG}(r)$. $\square$

**Theorem 7.3 (Compactness).** For every $r$:
$$\mathrm{EG}(r) \iff \exists N,\ \mathrm{EG}(r,N).$$

*Proof.* ($\Leftarrow$) Proposition 7.2.

($\Rightarrow$) Assume $\mathrm{EG}(r)$ and suppose, for contradiction, that $\mathrm{EG}(r,N)$ fails for every $N$. Then for each level $N$ there is a *bad colouring* $g_N$: for every exact covering $S$ with $\max S \le N$ and every colour $i$, some $n \in S$ has $g_N(n) \ne i$; i.e. $S$ is not monochromatic for $g_N$.

The naive diagonal — "take $g_N$ for large $N$" — fails, because different candidate coverings require different levels, and no single $g_N$ is bad against all of them simultaneously. We instead form a *limit colouring* along a fixed non-principal ultrafilter $\mathcal{U}$ on the set of levels.

*Construction.* Fix $n$. The map $N \mapsto g_N(n)$ takes values in a set of $r$ colours. Since a finite union of the fibres $\{N : g_N(n) = i\}$, over the finitely many colours $i$, is all of $\mathbb{N}$ and $\mathcal{U}$ is an ultrafilter, exactly one fibre lies in $\mathcal{U}$. Define $c(n)$ to be that colour, so that
$$\{ N : g_N(n) = c(n) \} \in \mathcal{U} \qquad \text{for every } n. \tag{$\ast$}$$
(Here finiteness of the palette is essential; for infinitely many colours no fibre need be large.)

*Application of the hypothesis.* By $\mathrm{EG}(r)$ applied to $c$, there are an exact covering $S$ and a colour $i$ with $c(n) = i$ for all $n \in S$.

*Intersecting two large sets.* Since $S$ is finite, ($\ast$) and closure of $\mathcal{U}$ under finite intersections give
$$A = \{ N : \forall n \in S,\ g_N(n) = c(n)\} = \bigcap_{n \in S} \{N : g_N(n) = c(n)\} \in \mathcal{U}.$$
Moreover $B = \{ N : \max S \le N\} \in \mathcal{U}$, because its complement $\{N : N < \max S\}$ is finite and $\mathcal{U}$ is non-principal (so contains all cofinite sets). Hence $A \cap B \in \mathcal U$ is nonempty; pick $N \in A \cap B$.

*Contradiction.* For this $N$: every $n \in S$ has $g_N(n) = c(n) = i$, so $S$ is monochromatic for $g_N$; and every $n \in S$ satisfies $n \le \max S \le N$. This contradicts the badness of $g_N$. $\square$

**Proposition 7.4 (The one-colour bound).** $\mathrm{EG}(1,6)$ holds, witnessed by $\{2,3,6\}$; and $6$ is optimal, since by Theorems 2.2 and 2.3 the unique covering of minimal size is $\{2,3,6\}$, and one checks directly that no subset of $\{2,3,4,5\}$ has reciprocal sum $1$. $\square$

**Observation 7.5 (A computational lower bound for two colours).** Colour $\{2,3,\dots,55\}$ by placing
$$R = \{3, 4, 6, 7, 8, 10, 11, 14, 17, 20, 21, 24, 25, 27, 29, 31, 32, 33, 34, 37, 41, 45, 46, 47, 49, 50, 52\}$$
in one class and the complement $B = \{2,3,\dots,55\}\setminus R$ in the other. An exhaustive exact search — carried out by meet-in-the-middle over the common denominator $\mathrm{lcm}(R)$, and independently by depth-first search with suffix-sum pruning — shows that neither class contains a subset of reciprocal sum $1$. Hence $\mathrm{EG}(2,N)$ fails for every $N \le 55$, and the least valid two-colour bound exceeds $55$. This is a computational finding rather than a proved theorem, but the certificate is small and directly checkable: it consists of the colouring together with the two exhaustive searches.

The striking feature is the mass. The reciprocal sums of the two classes are approximately $1.889$ and $1.704$: each class carries nearly twice the material needed for an exact covering, and still admits none. This is exactly the weird-core phenomenon of Theorem 6.8 at larger scale, and it is direct evidence for Conjecture C2 in §9.3.

**Remark 7.6 (Effective in structure, not in size).** Theorem 7.3 is a pure existence statement: the ultrafilter argument extracts no numerical bound on $N(r)$, because it proceeds by contradiction from an assumed failure at *every* level. Nevertheless, it converts a conjecture about arbitrary colourings of an infinite set into a finite, in-principle-decidable assertion. For $r=2$, verifying $\mathrm{EG}(2,N)$ for a single concrete $N$ would give a wholly finite proof of the two-colour case. The search space is $2^{N-1}$ colourings, prohibitive by brute force, but highly structured: by Theorem 5.4 the adversary cannot confine one colour to $\{2,\dots,9\}$, and by Theorem 6.9 he must break up every pseudoperfect divisor lattice below $N$. These constraints suggest a SAT/ILP formulation rather than enumeration.

---

## 8. Algorithms

Four computational procedures organise the constructive content above.

**(A1) Splitting-ladder generation.** Input: a target size $k \ge 3$. Start with $\{2,3,6\}$; repeatedly replace the maximum $m$ by $m+1$ and $m(m+1)$ until the size is $k$. Cost: $O(k)$ arithmetic operations, but the denominators grow doubly exponentially (Sylvester's sequence), so bignum arithmetic is required beyond about $k = 8$. Correctness: Theorem 2.5.

**(A2) Exact covering search inside a divisor lattice.** Input: $N$. Enumerate the divisors $d \mid N$ with $d \ge 2$, and solve the subset-sum problem $\sum_{d \in D} d = N$ over the *proper* divisors by dynamic programming over $\{0,1,\dots,N\}$; then dualise via $d \mapsto N/d$. Cost: $O(N \cdot \tau(N))$ time with $\tau(N)$ the number of divisors, and $O(N)$ space for the reachability table plus parent pointers. Correctness: Theorem 6.2. This is the practical way to manufacture coverings with prescribed properties: choosing $N = 27720$ and restricting to divisors that are not prime powers reproduces Theorem 5.1; restricting to divisors $\ge 10$ reproduces Theorem 5.3.

**(A3) Obstruction certification.** Input: a finite set $A$. For each prime $p$ dividing some member, tabulate $v_p$ across $A$; report *separated* if no value is repeated at a positive level. If separated, $A$ is covering-free by Theorem 4.5. Cost: $O(|A| \log \max A)$ after factoring. This is a *sound but incomplete* test: it certifies covering-freeness but, by Theorem 6.8, does not detect all instances.

**(A4) Greedy Egyptian expansion (Fibonacci–Sylvester).** Given a rational $0 < x < 1$, repeatedly subtract the largest unit fraction $1/\lceil 1/x\rceil$ not exceeding $x$. The numerator of the remainder strictly decreases, so the algorithm terminates; it demonstrates that every rational in $(0,1)$ has an Egyptian representation, though not necessarily an efficient one. Included for context: it shows why *representability* is easy and why *exactness of $1$ under colour constraints* is the hard part.

---

## 9. Discussion, and directions

### 9.1 What is settled

The elementary theory of exact coverings is now complete in the following sense. The realisable sizes are exactly $\{3,4,5,\dots\}$; the minimal covering is unique; the ladder generating all larger sizes is explicit; and each covering brackets its own cardinality. On the colouring side, the pigeonhole step is unconditional and elementary, and the one-colour case has the optimal finite bound $6$.

### 9.2 Why the elementary route stops

Theorem 4.9 is the sharpest statement of the difficulty: the property produced by pigeonhole (divergence) is strictly weaker than the property needed (containing an exact covering), and the gap is witnessed by the primes. Two structurally different obstructions — local $p$-adic separation and global mass deficiency — explain large families of covering-free sets, and Theorem 6.8 shows that even in combination they are incomplete. The residual mechanism is weirdness.

### 9.3 Future directions

**C1 (Large-minimum coverings).** *For every $K$ there is an exact Egyptian covering all of whose denominators exceed $K$.* Equivalently: every cofinite set of integers $\ge 2$ contains an exact covering, hence the Erdős–Graham conjecture holds for every colouring with a cofinite colour class. Under the divisor duality $d \mapsto N/d$, this is exactly the statement that some $N$ is representable as a sum of distinct divisors *all of which are at most $N/K$* — a "$K$-practical" strengthening of pseudoperfectness — and the mass required, $\sum_{e \mid N,\ e \ge K} 1/e \ge 1$, is available as soon as $\sigma(N)/N > 1 + \log K$. The bridge, the mass obstruction and the deficiency criterion are all in place; the missing ingredient is a practical-number lemma ("every integer up to $\sigma(N)$ is a sum of distinct divisors of $N$, for $N = \mathrm{lcm}(1,\dots,m)$"), which is elementary and inductive. *Falsifiable:* a $K$ with no such covering would contradict the divergence of $\sum_{e \mid \mathrm{lcm}(1..m)} 1/e$.

**C2 (A third mechanism: weird cores).** *Every covering-free set of integers $\ge 2$ that is neither $p$-adically separated nor of bounded reciprocal mass contains a "weird core".* Made precise: for every covering-free $A$ there is a finite $F \subseteq A$ with $\sum_{n\in F} 1/n > 1$ and no subset of $F$ summing to $1$ — i.e. covering-freeness is always witnessed by a *finite* weird configuration. The number $70$ already shows the local criterion is not necessary, and abundance without pseudoperfectness is precisely the weird phenomenon; the conjecture asserts weirdness is the only residual mechanism. The compactness machinery of §7 transfers infinite statements to finite ones, so this is now a statement about finite hypergraphs. *Falsifiable:* a covering-free set whose finite subsets have subset-sums arbitrarily close to $1$ from below but never above would refute it.

**C3 (Erdős–Graham–Rado numbers).** *$\mathrm{EG}(2,N)$ holds for some $N \le 100$.* By Observation 7.5 the least such $N$ is greater than $55$, so if C3 is true the true value lies in a narrow window. By Theorem 7.3 the two-colour case of Erdős–Graham is equivalent to the existence of *some* bound $N$, and the conjecture asserts that the least such bound — the "Erdős–Graham–Rado number" $\mathrm{EGR}(2)$ — is small enough for a structured search (SAT/ILP over $2$-colourings of $\{2,\dots,N\}$, with the covering-hypergraph constraints of §5 and §6 as strong initial clauses) to certify it. A refutation for a given $N$ is a single explicit bad $2$-colouring of $\{2,\dots,N\}$ and is easy to check; the analogous quantity for $r$ colours, $\mathrm{EGR}(r)$, is defined by the same recipe and is finite for every $r$ by Theorem 7.3 together with Croot's theorem.

**Further lines.** (i) Determine $\mathrm{EGR}(2)$ exactly, or good bounds; the bracketing theorem gives a lower bound on covering sizes and hence structural constraints on adversarial colourings. (ii) Quantify the density of pseudoperfect numbers usable in Theorem 6.9, giving colouring restrictions "for free". (iii) Classify the covering-free divisor lattices — by Theorem 6.2 this is exactly the classification of non-pseudoperfect numbers, splitting into the deficient (easy) and the weird (hard). (iv) Explore whether the local obstruction admits a *quantitative* form: bounding, for each prime $p$, how many elements of a covering must share the maximal $p$-power.

---

## 10. Conclusion

Exact Egyptian coverings are simultaneously abundant and rigid. They exist in every size from three upward, they can be built by a single explicit doubling move, they can avoid all prime powers and all small denominators — and yet they are forbidden entirely inside pairwise coprime families, inside the primes, inside the prime powers, and inside the divisor lattice of any deficient or weird number. The colouring conjecture of Erdős and Graham sits exactly at the tension point between these two facts: the easy argument produces mass, and mass provably is not enough. What has been mapped here is the shape of the gap — two independent obstructions, a classical divisor-arithmetic duality, an explicit family of evasive coverings, and a reduction of the whole infinitary question to a finite one.
