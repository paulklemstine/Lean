# Wall–Sun–Sun Primes: Elementary Bounds, Counterexamples, and a Modular Search Framework

**Aristotle**  
**August 2, 2026**

## Abstract

A Wall–Sun–Sun prime, also called a Fibonacci–Wieferich prime, is a prime $p$ for which a distinguished Fibonacci number is divisible by $p^2$. For primes away from $2$ and $5$, the distinguished index is $p-(p\mid5)$, where $(p\mid5)$ is the quadratic character modulo $5$. We give a self-contained natural-number formulation using residues modulo $5$, prove directly that no Wall–Sun–Sun prime lies below $12$, and deduce that every possible example is at least $12$. We isolate the failures at $p=3$ and $p=5$, and show that the residue condition $p\equiv\pm1\pmod5$ is not sufficient by the counterexample $p=11$. We also delimit a frequently overstated connection with Fermat’s Last Theorem: the theorem holds at exponent $3$, while $3$ is not a Wall–Sun–Sun prime, so no prime-by-prime equivalence can hold universally. Finally, we describe a fast-doubling modular algorithm for reproducible searches. The existence of any Wall–Sun–Sun prime remains open as of 2026; all results below are deliberately finite or conditional and do not assert existence.

## 1. Introduction

Let $(F_n)_{n\ge 0}$ be the Fibonacci sequence,

$$
F_0=0,\qquad F_1=1,\qquad F_{n+2}=F_{n+1}+F_n.
$$

The sequence is elementary, but its reductions modulo primes encode substantial arithmetic structure. A particularly stringent phenomenon occurs when a prime square, rather than merely a prime, divides a Fibonacci number selected by the quadratic behavior of $5$ modulo that prime.

For a prime $p\ne2,5$, the customary index is

$$
p-(p\mid5),
$$

where $(p\mid5)\in\{-1,1\}$ is the Legendre symbol in the denominator-$5$ convention. The nonzero quadratic residues modulo $5$ are $1$ and $4$. Thus $(p\mid5)=1$ when $p\equiv1$ or $4\pmod5$, and $(p\mid5)=-1$ when $p\equiv2$ or $3\pmod5$. The relevant index is consequently either $p-1$ or $p+1$.

A Wall–Sun–Sun prime is a prime $p$ satisfying

$$
p^2\mid F_{p-(p\mid5)}.
$$

No example is known as of 2026, and existence has not been proved. This status imposes an important discipline: finite searches produce lower bounds and evidence, not a proof that an example exists or that no example exists. The present work develops an exact elementary formulation that includes the exceptional small primes through direct evaluation, proves a complete bound below $12$, and identifies two false conjectures by explicit counterexample.

The main results are as follows.

1. Neither $3$ nor $5$ is a Wall–Sun–Sun prime.
2. No Wall–Sun–Sun prime is less than $12$; hence any such prime is at least $12$.
3. A prime residue of $\pm1$ modulo $5$ does not suffice: $11$ has this residue and fails the square-divisibility test.
4. Fermat’s Last Theorem at exponent $p$ is not equivalent, for all primes $p$, to the Wall–Sun–Sun property: exponent $3$ is a counterexample.

We also state a modular fast-doubling algorithm. It computes $F_n\bmod m$ in logarithmic recursion depth and makes transparent how larger finite investigations can be carried out without constructing enormous Fibonacci integers.

## 2. Definitions and arithmetic background

### 2.1. Fibonacci numbers

**Definition 2.1 (Fibonacci sequence).** The Fibonacci numbers are the unique nonnegative integers determined by

$$
F_0=0,\qquad F_1=1,\qquad F_{n+2}=F_{n+1}+F_n
$$

for every $n\ge0$.

The initial values needed below are

$$
0,1,1,2,3,5,8,13,21,34,55,89,144,\ldots.
$$

### 2.2. The residue-selected index

**Definition 2.2 (Fibonacci test index).** For every positive integer $p$, define

$$
I(p)=
\begin{cases}
p-1,&p\bmod5\in\{1,4\},\\
p+1,&p\bmod5\notin\{1,4\}.
\end{cases}
$$

This total definition is convenient because it assigns an index even to the exceptional primes $2$ and $5$. For primes $p\ne2,5$, it agrees with $p-(p\mid5)$.

**Lemma 2.3 (Residue interpretation).** If $p$ is prime and $p\ne2,5$, then

$$
I(p)=p-(p\mid5).
$$

**Proof sketch.** Every prime other than $5$ has residue $1$, $2$, $3$, or $4$ modulo $5$. The nonzero squares modulo $5$ are $1^2\equiv4^2\equiv1$ and $2^2\equiv3^2\equiv4$. Hence the quadratic residues are precisely $1$ and $4$. The quadratic character $(p\mid5)$ equals $1$ in those two classes and $-1$ in the other two. Substitution gives $p-1$ in the first case and $p+1$ in the second. The exclusion of $5$ avoids the value $0$ of the Legendre symbol, while $2$ is excluded from the usual odd-prime reciprocity formulation. $\square$

### 2.3. The prime-square condition

**Definition 2.4 (Wall–Sun–Sun prime).** A positive integer $p$ is a Wall–Sun–Sun prime if $p$ is prime and

$$
p^2\mid F_{I(p)}.
$$

Equivalently, the modular remainder satisfies

$$
F_{I(p)}\equiv0\pmod{p^2}.
$$

**Definition 2.5 (Existence conjecture).** The Wall–Sun–Sun existence conjecture is the assertion

$$
\exists p\text{ prime such that }p^2\mid F_{I(p)}.
$$

This is an open conjecture. No theorem in this paper assumes or concludes it.

The square in Definition 2.4 is crucial. Divisibility modulo $p^2$ detects a second-order congruence that cannot be inferred merely from the relevant residue class modulo $5$. Computationally, the test should therefore be performed modulo $p^2$, not modulo $p$.

## 3. Complete analysis below twelve

We begin with direct calculations. Since primality is part of the definition, composite integers can be rejected without evaluating any Fibonacci number.

**Theorem 3.1.** The prime $3$ is not a Wall–Sun–Sun prime.

**Proof.** Since $3\bmod5=3$, Definition 2.2 gives $I(3)=4$. The recurrence yields $F_4=3$. But $3^2=9$ does not divide $3$. Therefore $3$ fails Definition 2.4. $\square$

**Theorem 3.2.** The prime $5$ is not a Wall–Sun–Sun prime.

**Proof.** Since $5\bmod5=0$, the second branch of Definition 2.2 gives $I(5)=6$. We have $F_6=8$, and $25\nmid8$. Thus $5$ is not a Wall–Sun–Sun prime. This direct calculation also handles the ramified prime for which the usual Legendre-symbol expression requires separate treatment. $\square$

The remaining primes below $12$ are $2$, $7$, and $11$. Their data, together with the preceding cases, are:

| $p$ | $p\bmod5$ | $I(p)$ | $F_{I(p)}$ | divisibility conclusion |
|---:|---:|---:|---:|:---|
| $2$ | $2$ | $3$ | $2$ | $4\nmid2$ |
| $3$ | $3$ | $4$ | $3$ | $9\nmid3$ |
| $5$ | $0$ | $6$ | $8$ | $25\nmid8$ |
| $7$ | $2$ | $8$ | $21$ | $49\nmid21$ |
| $11$ | $1$ | $10$ | $55$ | $121\nmid55$ |

**Theorem 3.3 (Finite exclusion below twelve).** There is no Wall–Sun–Sun prime $p<12$.

**Proof.** Any prime below $12$ belongs to the exhaustive list $2,3,5,7,11$. The table computes the index and relevant Fibonacci value for each. In every case $p^2$ exceeds the displayed positive Fibonacci value, so $p^2$ cannot divide it. Every composite integer below $12$ fails the primality condition. Therefore no integer $p<12$ satisfies Definition 2.4. $\square$

**Corollary 3.4 (Elementary lower bound).** If $p$ is a Wall–Sun–Sun prime, then $p\ge12$.

**Proof.** If $p<12$, Theorem 3.3 says that $p$ is not a Wall–Sun–Sun prime, contradicting the hypothesis. Hence $p\ge12$. $\square$

Because a Wall–Sun–Sun number must be prime, the first eligible prime not covered by the finite exclusion is $13$. The corollary is intentionally phrased as $p\ge12$, the exact logical negation of $p<12$; it does not claim that $12$ itself is prime or eligible.

## 4. Residues modulo five are not sufficient

The branch $I(p)=p-1$ is selected exactly when $p\equiv\pm1\pmod5$. One might conjecture that this residue condition, together with primality, forces the Wall–Sun–Sun property. The conjecture fails at the first relevant prime in the finite table.

**Theorem 4.1 (Residue insufficiency).** There exists a prime $p$ such that $p\equiv1$ or $4\pmod5$, but $p$ is not a Wall–Sun–Sun prime.

**Proof.** Take $p=11$. It is prime and $11\equiv1\pmod5$. Thus $I(11)=10$. Since $F_{10}=55$ and $11^2=121$, we have $121\nmid55$. Therefore $11$ satisfies the residue premise but not the Wall–Sun–Sun conclusion. $\square$

This theorem separates two roles often blurred in informal discussion. The residue of $p$ modulo $5$ determines the **index** at which the test is performed. It does not determine the **remainder** of the Fibonacci number modulo $p^2$. The latter is finer arithmetic data.

A structural reason is that information modulo $5$ and information modulo $p^2$ inhabit different congruence systems. Knowing $p\equiv1\pmod5$ chooses $F_{p-1}$, but it imposes no immediate identity forcing

$$
F_{p-1}\equiv0\pmod{p^2}.
$$

The example $p=11$ is therefore not just a failed computation; it is a minimal warning against replacing a square-divisibility condition by the branch criterion used to formulate it.

## 5. Delimiting the connection with Fermat’s Last Theorem

For an integer exponent $n\ge3$, Fermat’s Last Theorem at exponent $n$ asserts that no positive integers $a,b,c$ satisfy

$$
a^n+b^n=c^n.
$$

The full theorem is classical, and the case $n=3$ has an independent elementary history. Here only the truth of the exponent-$3$ case is needed.

**Theorem 5.1 (Exponent-three separation).** Fermat’s Last Theorem holds at exponent $3$, while $3$ is not a Wall–Sun–Sun prime.

**Proof sketch.** The exponent-$3$ case states that $a^3+b^3=c^3$ has no solution in positive integers; this is the classical cubic case of Fermat’s Last Theorem. Independently, Theorem 3.1 computes $I(3)=4$ and $F_4=3$, so $9\nmid3$. Combining the two facts yields the stated conjunction. $\square$

**Theorem 5.2 (Failure of universal equivalence).** It is false that, for every prime $p$, Fermat’s Last Theorem at exponent $p$ holds if and only if $p$ is a Wall–Sun–Sun prime.

**Proof.** Suppose the equivalence held for every prime. Apply it to the prime $p=3$. Fermat’s Last Theorem holds at exponent $3$, so the forward implication would make $3$ a Wall–Sun–Sun prime. This contradicts Theorem 3.1. Hence the universal equivalence is false. $\square$

The theorem does not deny every meaningful historical relationship between Fibonacci–Wieferich conditions and Fermat-type criteria. It establishes a narrower and necessary point: any valid relationship must be subtler than a universal biconditional identifying the two properties at each prime exponent. In particular, one-way implications with additional hypotheses must not be paraphrased as an equivalence.

## 6. Algorithms for finite investigation

### 6.1. Direct recurrence

The simplest computation of $F_n\bmod m$ initializes $(a,b)=(0,1)$ and repeats

$$
(a,b)\leftarrow(b,(a+b)\bmod m)
$$

exactly $n$ times. The final value of $a$ is $F_n\bmod m$. This uses $O(n)$ modular additions and $O(1)$ stored residues. Since the Wall–Sun–Sun index is approximately $p$, testing one prime this way costs $O(p)$ modular steps.

### 6.2. Fast doubling

A more scalable method uses the identities

$$
F_{2k}=F_k(2F_{k+1}-F_k)
$$

and

$$
F_{2k+1}=F_k^2+F_{k+1}^2.
$$

**Lemma 6.1 (Doubling identities).** For every $k\ge0$, the two identities above hold.

**Proof sketch.** The Fibonacci addition formula

$$
F_{r+s}=F_{r-1}F_s+F_rF_{s+1}
$$

follows by induction on $s$. Setting $r=s=k$ gives

$$
F_{2k}=F_{k-1}F_k+F_kF_{k+1}
=F_k(F_{k-1}+F_{k+1}).
$$

Because $F_{k-1}=F_{k+1}-F_k$, the first doubling identity follows. Applying the addition formula to $2k+1=k+(k+1)$ yields the second identity after the same recurrence substitutions. $\square$

**Algorithm 6.2 (Modular Fibonacci pair).** Given $n\ge0$ and $m\ge1$, recursively compute the pair

$$
(F_n\bmod m,F_{n+1}\bmod m).
$$

For $n=0$, return $(0,1\bmod m)$. Otherwise recursively compute $(a,b)$ for $\lfloor n/2\rfloor$, then form

$$
c=a(2b-a)\bmod m,
$$

$$
d=(a^2+b^2)\bmod m.
$$

If $n$ is even, return $(c,d)$; if $n$ is odd, return $(d,c+d\bmod m)$.

**Theorem 6.3 (Correctness of modular fast doubling).** Algorithm 6.2 returns $(F_n\bmod m,F_{n+1}\bmod m)$ for every $n\ge0$ and $m\ge1$.

**Proof sketch.** Induct on $n$ through its binary recursion. The base case is immediate. In the recursive case, assume $(a,b)$ represents $(F_k,F_{k+1})$ modulo $m$, where $k=\lfloor n/2\rfloor$. Lemma 6.1 shows that $c$ and $d$ represent $F_{2k}$ and $F_{2k+1}$. If $n=2k$, this is the desired pair. If $n=2k+1$, the recurrence gives $F_{2k+2}=F_{2k}+F_{2k+1}$, so $(d,c+d)$ is the desired pair. Reduction modulo $m$ preserves addition and multiplication. $\square$

The recursion has depth $O(\log n)$ and performs a constant number of modular additions and multiplications per level. Under a unit-cost model for modular operations, its time is $O(\log n)$ and auxiliary stack space is $O(\log n)$. With bit complexity included, the operands have $O(\log m)$ bits, and the cost depends on the chosen multiplication routine.

### 6.3. Candidate testing

**Algorithm 6.4 (Wall–Sun–Sun candidate test).** Given an integer $p\ge2$:

1. determine whether $p$ is prime; reject it if not;
2. set $n=p-1$ if $p\bmod5$ is $1$ or $4$, and set $n=p+1$ otherwise;
3. compute $r=F_n\bmod p^2$ by Algorithm 6.2;
4. accept exactly when $r=0$.

**Theorem 6.5 (Correctness of candidate testing).** Algorithm 6.4 accepts $p$ if and only if $p$ is a Wall–Sun–Sun prime according to Definition 2.4.

**Proof.** Step 1 enforces primality. Step 2 computes exactly $I(p)$. By Theorem 6.3, Step 3 computes the remainder of $F_{I(p)}$ modulo $p^2$. This remainder is zero exactly when $p^2$ divides $F_{I(p)}$. These are precisely the two clauses of Definition 2.4. $\square$

For a search through all $p\le B$, a sieve can enumerate primes in $O(B\log\log B)$ elementary marking operations and $O(B)$ memory. Candidate testing then performs one logarithmic-depth Fibonacci computation per prime. A segmented sieve can reduce memory for substantially larger intervals.

### 6.4. Reproducibility and certificates

A finite search is most transparent when it records, for each tested prime, the tuple

$$
(p,I(p),F_{I(p)}\bmod p^2).
$$

Every nonzero third component certifies failure of that candidate. A zero component supplies an explicit witness to existence, subject only to checking primality and the modular computation. For large searches, compact certificates could list primes and remainders in blocks, while an independent verifier checks primality, interval coverage, index selection, and recurrence identities.

### 6.5. Exhaustiveness and interpretation of a search

A claim that no example occurs up to $B$ has two logically separate components. First, the candidate list must contain every prime $p\le B$. Second, every listed prime must have a nonzero Fibonacci remainder modulo $p^2$. A sieve establishes the first component only when its interval coverage is itself checked; fast doubling establishes the second only when the selected index and modulus are correct. Keeping these obligations separate makes a numerical report auditable.

For a candidate $p$, the stored remainder $r_p$ should satisfy

$$
0\le r_p<p^2
$$

and

$$
r_p\equiv F_{I(p)}\pmod{p^2}.
$$

If $r_p\ne0$, then $p^2\nmid F_{I(p)}$. Conversely, if $r_p=0$ and $p$ has been shown prime, Definition 2.4 immediately identifies $p$ as a Wall–Sun–Sun prime. There is no statistical threshold or approximate acceptance criterion: the test is exact.

Search bounds must also be reported with care. Testing all primes $p\le B$ and finding none proves that every example exceeds $B$. Testing only a selected collection of primes proves no interval bound unless the selection is exhaustive. Likewise, floating-point approximations to Fibonacci numbers are unsuitable, because divisibility is decided by an exact remainder. Modular integer arithmetic avoids both the size of $F_{I(p)}$ and any rounding ambiguity.

This framework distinguishes discovery from exclusion. Discovery requires one auditable tuple with zero remainder. Exclusion through $B$ requires an auditable tuple with nonzero remainder for every prime in the interval. Global nonexistence cannot be reduced to either finite task.

## 7. Applications and interpretation

The immediate application is the systematic exclusion of finite ranges. Theorem 3.3 illustrates the method at a tiny scale, where ordinary Fibonacci values suffice. Algorithm 6.4 extends the same logic without changing the definition.

A second application is conceptual error detection. Theorem 4.1 prevents the residue selector from being mistaken for a sufficient condition. Theorems 5.1 and 5.2 prevent a historically motivated association from being inflated into a false equivalence. Explicit counterexamples are especially valuable because they identify the precise failing input: $11$ for residue sufficiency and $3$ for the universal Fermat equivalence.

A third application concerns higher-order divisibility. Conditions of the form $p^2\mid A(p)$ often measure whether a congruence that is expected modulo $p$ lifts to the next prime power. The modular fast-doubling framework is an instance of a broader computational principle: evaluate recurrence sequences directly in the quotient ring $\mathbb Z/p^2\mathbb Z$ rather than constructing huge integers and reducing afterward.

The framework is also pedagogically useful because every layer has a distinct role. The recurrence defines the sequence, quadratic residues select the index, primality restricts the candidates, and exact modular arithmetic decides the outcome. None of these layers can replace another. This separation explains both why the test is easy to state and why shortcuts based only on congruence classes fail.

## 8. Limitations and open status

The finite lower bound $p\ge12$ is exact for the range proved, but it is not intended as a record computational bound. More importantly, no finite exclusion can settle nonexistence over all primes. The logical alternatives are asymmetric:

- an explicit prime with zero remainder proves existence;
- any finite list of nonzero remainders proves only that the first example, if any, lies beyond the searched range;
- a proof of nonexistence would require a general argument covering infinitely many primes.

The definition used here treats $2$ and $5$ directly. For odd primes away from $5$, Lemma 2.3 supplies the standard quadratic-character interpretation. A fully developed general theory would prove the underlying Fibonacci divisibility law and its relation to ranks of apparition, then formulate the square condition in that setting.

The Fermat discussion is likewise intentionally conservative. Theorem 5.2 refutes one naive universal equivalence. It should not be read as excluding carefully sourced conditional or one-way theorems involving Fibonacci–Wieferich primes.

## 9. Future work

Several directions naturally continue this program.

First, the fast-doubling modular algorithm should be paired with a complete proof of agreement with ordinary Fibonacci reduction and used to certify substantially larger finite bounds. Second, the Legendre-symbol identity should be developed in full detail, including the exceptional primes, so that the residue-selected index and $p-(p\mid5)$ are connected by a single theorem with explicit hypotheses.

Third, a certificate format should support interval searches. Such a certificate would list each prime in an interval together with the corresponding modular Fibonacci remainder. Verification would check that the prime list is exhaustive, each index is correct, and each remainder follows from modular doubling identities.

Fourth, historical criteria connecting Fibonacci–Wieferich primes with Fermat-type equations should be stated only from precise sources and with all hypotheses visible. The counterexample at exponent $3$ shows why replacing those criteria by a biconditional is untenable.

Finally, the existence assertion should remain explicitly labeled a conjecture until either a prime witness is found or a general existence theorem is proved.

## 10. Conclusion

Wall–Sun–Sun primes are defined by a simple but exceptionally strong congruence: a prime square must divide a Fibonacci number at an index chosen by quadratic residues modulo $5$. The definition is elementary enough for direct computation, yet its existential question remains unresolved.

The results established here are exact and bounded. The primes $3$ and $5$ fail. Every prime below $12$ fails, so any example must be at least $12$. The prime $11$ proves that congruence to $\pm1$ modulo $5$ is not sufficient. The prime $3$, together with the exponent-$3$ case of Fermat’s Last Theorem, proves that no universal equivalence between the two properties can hold.

Fast doubling supplies an efficient route to larger finite searches, but it does not erase the distinction between evidence and theorem. The open existence conjecture remains where it began: precisely stated, computationally approachable, and unanswered.
