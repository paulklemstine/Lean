# Counterfactual Number Theory: Random Prime Events and Nonunique Factorization

**Aristotle**  
**July 19, 2026**

## Abstract

We study two precise counterfactual models that separate the statistical and multiplicative roles of prime numbers. In the probabilistic model, the candidate integer $n+2$ is represented by an event with benchmark probability $1/\log(n+2)$. We prove that the benchmark series diverges, that its restriction to every fixed nonconstant arithmetic progression also diverges, and that independent events bounded below by these probabilities occur infinitely often almost surely. Conversely, any event sequence with summable probabilities occurs only finitely often almost surely. This gives a sharp qualitative divergence–convergence dichotomy and a random analogue of the infinitude conclusion in Dirichlet’s theorem, without asserting the arithmetic content of that theorem. In the algebraic model, we consider the multiplicative monoid $H=\{n\in\mathbb N:n\equiv1\pmod4\}$ and define its primes as irreducible nonunits. We prove that $9$, $21$, and $49$ are irreducible in $H$, while $441=9\cdot49=21\cdot21$, so unique factorization fails. Nevertheless, every ordinary prime congruent to $1$ modulo $4$ remains irreducible in $H$, yielding infinitely many such irreducibles. We provide numerical algorithms and examples illustrating both models. We also delimit the conclusions: a prime-number-theorem analogue requires concentration and expectation asymptotics not established here, while an almost-sure Riemann-hypothesis analogue is not meaningful until a specific random analytic function and its continuation have been defined.

## 1. Introduction

Prime numbers play at least two conceptually different roles. Statistically, they form a sparse subset of the positive integers with local density near $1/\log x$. Algebraically, they are the irreducible building blocks in the unique factorization of positive integers. Their irregular spacing invites probabilistic models, but their definition is rigidly multiplicative. A counterfactual theory should therefore distinguish two questions.

First, which infinitude phenomena follow merely from assigning independent prime-like probabilities? Second, which factorization phenomena follow merely from retaining infinitely many irreducible elements in a multiplicative system?

We answer these questions in two models. The **random-event model** does not redefine divisibility. Instead, it introduces events $E_n$ indicating that $n+2$ is selected and compares their probabilities with

$$
p_n=\frac{1}{\log(n+2)}.
$$

The central analytic fact is the divergence of $\sum_n p_n$, including after restriction to indices in any arithmetic progression. Standard limsup-event principles then convert this divergence, under independence, into almost-sure infinite occurrence. A complementary convergence result shows that summable probabilities imply only finitely many occurrences, without independence.

The **Hilbert-monoid model** changes the available factors. Its universe is

$$
H=\{n\in\mathbb N:n\equiv1\pmod4\},
$$

with ordinary multiplication. Irreducibility is internal to $H$. Some ordinarily composite numbers become irreducible because their proper factors lie outside $H$. This permits two different irreducible factorizations of $441$, even though $H$ still has infinitely many irreducibles.

These models deliberately establish less than the most ambitious analogies might suggest. Infinite recurrence along progressions is not a full prime number theorem, and it is not classical Dirichlet’s theorem because no coprimality condition or divisibility obstruction enters the random mechanism. Likewise, neither a random set of integers nor a nonfactorial monoid automatically supplies a zeta function suitable for a Riemann-hypothesis statement. Making these boundaries explicit is part of the mathematical result.

## 2. Preliminaries

### 2.1. Extended sums and limsup events

All probabilities take values in $[0,1]$. For a sequence of events $(E_n)_{n\ge0}$ in a probability space $(\Omega,\mathcal F,\mathbb P)$, define the limsup event

$$
\limsup_{n\to\infty}E_n
=\bigcap_{N=0}^{\infty}\bigcup_{n\ge N}E_n.
$$

An outcome belongs to this event exactly when it belongs to infinitely many $E_n$.

We use the following two probabilistic principles.

**Lemma 2.1 (First Borel–Cantelli principle).**  
Let $(E_n)_{n\ge0}$ be measurable events. If

$$
\sum_{n=0}^{\infty}\mathbb P(E_n)<\infty,
$$

then

$$
\mathbb P\!\left(\limsup_{n\to\infty}E_n\right)=0.
$$

Thus only finitely many $E_n$ occur almost surely. Independence is not required.

*Proof sketch.* For each $N$, the union bound gives

$$
\mathbb P\!\left(\bigcup_{n\ge N}E_n\right)
\le \sum_{n\ge N}\mathbb P(E_n).
$$

The tail on the right tends to $0$. The sets on the left decrease with $N$, and their intersection is the limsup event. Continuity from above therefore gives probability $0$.

**Lemma 2.2 (Independent divergence principle).**  
Let $(E_n)_{n\ge0}$ be measurable independent events. If

$$
\sum_{n=0}^{\infty}\mathbb P(E_n)=\infty,
$$

then

$$
\mathbb P\!\left(\limsup_{n\to\infty}E_n\right)=1.
$$

*Proof sketch.* Independence implies that the probability of avoiding all events from $N$ through $M$ is

$$
\prod_{n=N}^{M}\bigl(1-\mathbb P(E_n)\bigr).
$$

Using $1-x\le e^{-x}$, this is at most

$$
\exp\!\left(-\sum_{n=N}^{M}\mathbb P(E_n)\right),
$$

which tends to $0$ as $M\to\infty$. Hence with probability $1$ at least one event occurs after every $N$, equivalently infinitely many events occur.

### 2.2. The benchmark density

**Definition 2.3 (Cramér benchmark density).**  
For each $n\in\mathbb N$, define

$$
p_n=\frac{1}{\log(n+2)}.
$$

The index shift ensures $n+2\ge2$, so $\log(n+2)>0$. The model may use exact probabilities $p_n$, or more generally probabilities bounded below by $p_n$. The latter formulation makes the recurrence results monotone and robust.

Strictly speaking, $p_0=1/\log2>1$ and hence is not itself a valid probability. This causes no difficulty for the lower-bound event formulation only when such hypotheses are satisfiable; for exact Bernoulli simulation one caps the value at $1$ or begins at a sufficiently large index. All divergence and asymptotic conclusions are unaffected by changing finitely many initial terms. In the theorems below, an assumed inequality $p_n\le\mathbb P(E_n)$ implicitly requires consistency; one may equivalently state it beyond a finite initial index.

### 2.3. Arithmetic progressions

For integers $q>0$ and $a\ge0$, the sequence $qn+a$ is a nonconstant arithmetic progression of indices. The corresponding candidate integers are $qn+a+2$, and their benchmark masses are

$$
p_{qn+a}=\frac{1}{\log(qn+a+2)}.
$$

No coprimality hypothesis appears because the random model does not encode divisibility exclusions.

## 3. Divergence of prime-like density

We begin with a comparison to the harmonic series.

**Lemma 3.1 (Harmonic lower bound).**  
For every $n\ge0$,

$$
\frac{1}{n+2}\le\frac{1}{\log(n+2)}.
$$

*Proof.* For every $x>0$, $\log x\le x$. Taking $x=n+2$ gives $0<\log(n+2)\le n+2$. Reciprocation of positive quantities reverses the inequality and proves the claim.

**Lemma 3.2 (Shifted harmonic divergence).**  
The series

$$
\sum_{n=0}^{\infty}\frac{1}{n+2}
$$

diverges.

*Proof sketch.* It is the harmonic series with its first two indexing positions removed. Deleting finitely many terms cannot change divergence.

**Theorem 3.3 (Cramér density divergence).**  
The benchmark density has infinite total mass:

$$
\sum_{n=0}^{\infty}\frac{1}{\log(n+2)}=\infty.
$$

*Proof.* Lemma 3.1 bounds every term below by the corresponding term of the divergent series in Lemma 3.2. The comparison test gives divergence.

The same phenomenon persists on every fixed arithmetic progression.

**Theorem 3.4 (Arithmetic-progression divergence).**  
For all integers $q>0$ and $a\ge0$,

$$
\sum_{n=0}^{\infty}\frac{1}{\log(qn+a+2)}=\infty.
$$

*Proof sketch.* Since $qn+a+2>1$, the logarithm is positive. The inequality $\log x\le x-1$ for $x>0$ gives

$$
\frac{1}{\log(qn+a+2)}
\ge \frac{1}{qn+a+1}.
$$

The series on the right diverges. Indeed, for a sufficiently large constant $C$ depending on $q$ and $a$,

$$
qn+a+1\le C(n+1),
$$

so $1/(qn+a+1)\ge C^{-1}/(n+1)$, a constant multiple of the harmonic series. Comparison proves the result.

The theorem says more than the divergence of the full sequence: fixed periodic thinning does not remove enough probability mass to make the series summable.

## 4. Almost-sure recurrence

**Theorem 4.1 (Almost-sure infinitude of independent prime-like events).**  
Let $(E_n)_{n\ge0}$ be measurable independent events in a probability space. Suppose that, for every relevant $n$,

$$
\mathbb P(E_n)\ge\frac{1}{\log(n+2)}.
$$

Then

$$
\mathbb P\!\left(\limsup_{n\to\infty}E_n\right)=1.
$$

Equivalently, infinitely many prime-like events occur almost surely.

*Proof.* By monotonicity of nonnegative series and Theorem 3.3,

$$
\sum_{n=0}^{\infty}\mathbb P(E_n)
\ge\sum_{n=0}^{\infty}\frac{1}{\log(n+2)}
=\infty.
$$

Lemma 2.2 applies.

**Theorem 4.2 (Random Dirichlet-type recurrence).**  
Fix integers $q>0$ and $a\ge0$. Let $(E_n)_{n\ge0}$ be measurable independent events satisfying

$$
\mathbb P(E_n)\ge\frac{1}{\log(qn+a+2)}.
$$

Then

$$
\mathbb P\!\left(\limsup_{n\to\infty}E_n\right)=1.
$$

Thus the corresponding random set meets the fixed progression infinitely often almost surely.

*Proof.* Theorem 3.4 shows that the lower bounds have divergent sum. Hence the event probabilities also have divergent sum, and Lemma 2.2 proves the claim.

The phrase “Dirichlet-type” records a resemblance of conclusion, not an identity of content. Classical Dirichlet theory restricts to residue classes coprime to the modulus because genuine primes are constrained by divisibility. Here any fixed $q>0$ and $a\ge0$ are allowed, because selection events do not know whether all members of a progression share a divisor.

**Theorem 4.3 (Summable probabilities imply finite occurrence).**  
Let $(F_n)_{n\ge0}$ be measurable events. If

$$
\sum_{n=0}^{\infty}\mathbb P(F_n)<\infty,
$$

then

$$
\mathbb P\!\left(\limsup_{n\to\infty}F_n\right)=0.
$$

*Proof.* This is Lemma 2.1.

Combining the two regimes gives the central qualitative boundary.

**Theorem 4.4 (Divergence–convergence dichotomy).**  
Let $(E_n)$ be measurable independent events with divergent total probability, and let $(F_n)$ be measurable events with convergent total probability. Then

$$
\mathbb P\!\left(\limsup E_n\right)=1,
\qquad
\mathbb P\!\left(\limsup F_n\right)=0.
$$

*Proof.* Apply Lemma 2.2 to $(E_n)$ and Lemma 2.1 to $(F_n)$.

The dichotomy is qualitative. It identifies whether infinitely many occurrences survive, but does not determine the asymptotic number of occurrences below $N$.

## 5. A multiplicative counterfactual

We now isolate the algebraic role of primes by restricting the admissible factors.

**Definition 5.1 (Hilbert multiplicative monoid).**  
Let

$$
H=\{n\in\mathbb N:n\equiv1\pmod4\}.
$$

Multiplication is inherited from the natural numbers, and $1$ is the identity.

**Lemma 5.2 (Multiplicative closure).**  
If $a,b\in H$, then $ab\in H$.

*Proof.* The hypotheses give $a\equiv1\pmod4$ and $b\equiv1\pmod4$. Therefore $ab\equiv1\cdot1\equiv1\pmod4$.

**Definition 5.3 (Hilbert prime).**  
An integer $h$ is a Hilbert prime if $h\in H$, $h\ge2$, and every factorization $h=ab$ with $a,b\in H$ has $a=1$ or $b=1$. Thus “Hilbert prime” means irreducible nonunit in the monoid $H$; it does not mean prime in the ordinary natural numbers.

**Proposition 5.4 (Three composite irreducibles).**  
The integers $9$, $21$, and $49$ are Hilbert primes.

*Proof sketch.* Each is congruent to $1$ modulo $4$. Their ordinary proper factorizations are

$$
9=3\cdot3,\qquad 21=3\cdot7,\qquad 49=7\cdot7.
$$

Both $3$ and $7$ are congruent to $3$ modulo $4$, so none belongs to $H$. More generally, inspection of the positive divisors shows that no factorization of any of these three numbers uses two nonunit factors from $H$. Hence each is irreducible in $H$.

**Theorem 5.5 (Failure of unique factorization).**  
Factorization into Hilbert primes is not unique in $H$. In particular,

$$
441=9\cdot49=21\cdot21,
$$

and the irreducible multisets $\{9,49\}$ and $\{21,21\}$ are distinct.

*Proof.* Proposition 5.4 shows that all factors displayed are Hilbert primes. Direct multiplication gives both products equal to $441$. One multiset contains $9$ and $49$, while the other contains two copies of $21$, so they are unequal. Thus $441$ has two genuinely different irreducible factorizations.

This example distinguishes irreducibility from ordinary primality. It also shows that closure under multiplication and the existence of irreducibles do not force factoriality.

**Theorem 5.6 (Ordinary primes in the class $1$ modulo $4$ remain irreducible).**  
If $p$ is an ordinary prime and $p\equiv1\pmod4$, then $p$ is a Hilbert prime.

*Proof.* Certainly $p\in H$ and $p\ge2$. If $p=ab$ with $a,b\in H$, ordinary primality implies that $a=1$ or $b=1$. Therefore $p$ is irreducible in $H$.

**Theorem 5.7 (Infinitely many Hilbert primes).**  
The monoid $H$ contains infinitely many Hilbert primes.

*Proof sketch.* There are infinitely many ordinary primes congruent to $1$ modulo $4$. By Theorem 5.6, every such prime is a Hilbert prime. Therefore the set of Hilbert primes is infinite.

Theorems 5.5 and 5.7 form the algebraic contrast: infinitude of irreducibles survives, while uniqueness of factorization fails.

## 6. Computational illustrations

The mathematical results are infinite statements, but finite computations make their mechanisms visible.

### 6.1. Partial density sums

For a cutoff $N$, compute

$$
S(N)=\sum_{n=0}^{N-1}\frac{1}{\log(n+2)}
$$

and, for fixed $q>0$ and $a\ge0$,

$$
S_{q,a}(N)=\sum_{n=0}^{N-1}\frac{1}{\log(qn+a+2)}.
$$

Both sequences increase with $N$. Their growth is slow but unbounded. A direct algorithm takes $O(N)$ time and $O(1)$ auxiliary space by maintaining a running sum.

### 6.2. Bernoulli simulation

For numerical simulation, define valid probabilities by

$$
\widetilde p_n=\min\!\left(1,\frac{1}{\log(n+2)}\right).
$$

Draw independent uniform random variables $U_n$ on $[0,1)$ and select $n+2$ when $U_n<\widetilde p_n$. Repeating the experiment visualizes the noisy accumulation of selected candidates. Capping changes only finitely many initial terms and therefore does not affect the divergence mechanism.

The simulation is illustrative rather than a proof of almost-sure behavior. For $N$ candidates and $T$ trials it uses $O(TN)$ time. Counts alone require $O(T)$ storage; retaining all selected positions may require $O(TN)$ storage in the worst case.

### 6.3. Enumerating Hilbert primes

To test whether $h\le B$ is a Hilbert prime, first require $h\ge2$ and $h\equiv1\pmod4$. Then search divisors $d$ from $2$ through $\lfloor\sqrt h\rfloor$. If $d\mid h$ and both $d$ and $h/d$ are congruent to $1$ modulo $4$, then $h$ is reducible in $H$; otherwise it is irreducible.

Testing all candidates through $B$ by trial division takes $O(B^{3/2})$ arithmetic steps in a simple implementation and $O(1)$ auxiliary space apart from the output. This procedure identifies $9$, $21$, and $49$ as Hilbert primes and confirms the two factorizations of $441$.

## 7. Structural comparison of the two models

The probabilistic and multiplicative constructions answer different counterfactual questions, so their vocabularies must be kept separate. In the random model, “prime-like” means selected by an event; it does not imply irreducibility. In the Hilbert model, “prime” means irreducible; it involves no randomness. This separation prevents three tempting but invalid inferences.

First, statistical density does not imply a factorization law. A random set selected at logarithmic rate need not generate the natural numbers multiplicatively, and nothing in the event model gives unique decomposition. Second, infinitely many irreducibles do not determine their counting density. The infinitude proof for Hilbert primes imports an infinite subfamily—ordinary primes congruent to $1$ modulo $4$—but gives no asymptotic formula for all Hilbert primes. Third, recurrence in every fixed arithmetic progression does not recover congruence-sensitive primality. The random theorem permits progressions whose terms share a common divisor because the events ignore divisibility.

These observations can be summarized by four independent axes:

1. **Mass:** whether the assigned local weights form a divergent series.
2. **Dependence:** whether event occurrence is sufficiently independent for divergent mass to force recurrence.
3. **Irreducibility:** whether an element admits a nontrivial product decomposition inside the chosen universe.
4. **Factoriality:** whether every element has a unique multiset of irreducible factors.

The random model directly controls the first two axes. The Hilbert model demonstrates that the third can be abundant while the fourth fails. Ordinary prime theory links all four through additional arithmetic structure, but the counterfactuals show that none of these links should be presumed.

There is also a useful stability distinction. Divergence and limsup recurrence are unchanged by modifying finitely many initial probabilities, which is why capping the exceptional benchmark values is harmless. Factoriality, by contrast, can be destroyed by a single finite witness: the element $441$ and its two factorizations suffice. One model’s conclusions are tail properties; the other model’s failure is certified locally.

## 8. Interpretation and applications

The random-event theorems clarify how much “prime-like infinitude” follows from coarse density. The lower bound $1/\log n$ is nonsummable, so independence repeatedly converts small local chances into almost-sure global recurrence. The arithmetic-progression theorem shows that any fixed linear thinning retains infinite mass. Similar reasoning applies in randomized search, reliability, and rare-event sampling: when independent success probabilities are nonsummable, eventual successes recur almost surely.

The convergence half is equally important. If probabilities decay too quickly—for example on the order of $1/n^{1+\varepsilon}$—their sum is finite, and only finitely many successes occur almost surely. Thus the summability threshold separates persistent from transient event sequences.

The Hilbert monoid illustrates a different lesson relevant to algebraic number theory and factorization algorithms. Irreducibility depends on the ambient multiplicative system. Removing admissible factors can turn composite integers into atoms, but this does not preserve the uniqueness properties of the original system. A factorization algorithm that assumes unique output would therefore be ill-posed in $H$: it must return one factorization, enumerate alternatives, or specify a normalization not provided by the algebra itself.

The two models should not be conflated. The random model is additive and probabilistic in its indexing; the Hilbert model is deterministic and multiplicative. Their joint value lies in separating properties often bundled together under the word “prime.”

## 9. Limitations: prime-number and Riemann-hypothesis analogues

Let

$$
X_N=\sum_{n=0}^{N-1}\mathbf 1_{E_n}
$$

be the random counting function. Under exact independent Bernoulli probabilities, its expectation is

$$
\mathbb E[X_N]=\sum_{n=0}^{N-1}\frac{1}{\log(n+2)},
$$

up to any finite initial adjustment needed to keep probabilities at most $1$. This suggests growth comparable to $N/\log N$. However, the almost-sure infinitude theorem only states that $X_N\to\infty$ almost surely. It does not prove

$$
X_N\sim\frac{N}{\log N}.
$$

A full prime-number-theorem analogue requires a concentration theorem showing that $X_N$ is asymptotic to its expectation, together with an asymptotic evaluation of that expectation.

An almost-sure Riemann-hypothesis statement requires even more structure. Selection events alone do not canonically define a random zeta function. One might attempt a random Dirichlet series or Euler product, but then one must specify the coefficients or factors, prove convergence in an initial half-plane, establish an analytic or meromorphic continuation, and define the relevant critical line. Only after those tasks does a zero-location conjecture become meaningful.

In the Hilbert monoid, nonunique factorization blocks the naive transfer of an Euler product. Euler products encode multiplicative decomposition into primes; when irreducible factorizations are nonunique, product expansions require additional justification and may not represent the intended counting function.

## 10. Future work

Three conclusions are robust in the present models: the Cramér density series diverges on every fixed nonconstant arithmetic progression; independent events with these lower-bounded probabilities occur infinitely often almost surely, including along progressions; and replacing ordinary primes by irreducibles of the Hilbert monoid preserves infinitude but destroys unique factorization.

The next probabilistic objective is a full counting theorem. For independent Bernoulli variables with probabilities $1/\log(n+2)$ after a finite initial adjustment, one should prove almost-sure concentration of $X_N$ around $\mathbb E[X_N]$, then establish

$$
\mathbb E[X_N]\sim\frac{N}{\log N}.
$$

A second direction is simultaneous recurrence over countably many arithmetic progressions. Since a countable intersection of probability-one events still has probability one, an appropriately unified independent model should permit a statement that every fixed progression in a countable family is visited infinitely often almost surely, provided the event indexing and dependence structure are specified consistently.

For analytic questions, future work must first choose a random zeta object. Candidate definitions should be compared according to convergence, multiplicativity, continuation, and whether their zeros are stable under finite changes to the random set. Only then should one formulate zero-free regions or critical-line assertions.

Finally, the Hilbert example invites a classification problem: determine which elements of $H$ have unique irreducible factorization, quantify the number or lengths of distinct factorizations, and study analogous monoids $\{n:n\equiv1\pmod m\}$ for other moduli $m$.

## 11. Conclusion

Prime-like density, almost-sure recurrence, irreducible infinitude, and unique factorization are distinct mathematical properties. The benchmark probabilities $1/\log(n+2)$ have divergent total mass, even on every fixed arithmetic progression. Under independence this forces infinitely many occurrences almost surely, while summable event masses force only finitely many. In the deterministic monoid of integers congruent to $1$ modulo $4$, infinitely many irreducibles remain, yet $441=9\cdot49=21\cdot21$ destroys uniqueness.

These counterfactuals preserve selected shadows of ordinary prime theory while exposing the hypotheses behind them. Probability explains recurrence from nonsummable density. Multiplicative structure governs factorization. Analytic statements about zeros require still more. The exercise therefore does not replace the primes by randomness; it identifies precisely which parts of their behavior randomness can reproduce, and which parts depend on arithmetic architecture.
