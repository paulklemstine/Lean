# Proof Strategy Mining: The Primitive Divisor Schema for Strong Divisibility Sequences

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty / Number Theory

---

## Abstract

The classical primitive-divisor theorems of Carmichael (for Fibonacci numbers)
and Zsygmondy (for the sequences $a^n - 1$) are usually presented as separate
results with separate proofs, one resting on properties of the Fibonacci
recurrence and the other on the multiplicative order of $a$ modulo a prime. We
*mine* the common proof strategy from these two arguments and isolate the single
hypothesis on which it depends: the **strong divisibility identity**
$\gcd(u_m, u_n) = u_{\gcd(m,n)}$. We package the strategy as a reusable,
domain-agnostic schema over an abstract **strong divisibility sequence** and
re-derive, from this one hypothesis alone, the entire structural theory of
primitive divisors: a meet law, rigidity (uniqueness) of primitive indices, the
**pinning law** that a primitive divisor appears exactly at the multiples of its
index, a **join law** for simultaneous apparition governed by least common
multiples, and exact counting/density formulas for apparition indices. We then
introduce the **rank of apparition** as a canonical construction of the primitive
index from a prime alone, yielding the self-contained **strong primitive-divisor
criterion** $p \mid u_m \iff \operatorname{rank}(p) \mid m$. Finally we instantiate
the schema to both the Fibonacci sequence and the family $n \mapsto a^n - 1$,
recovering the Fibonacci law of apparition and the multiplicative-order law as two
specializations of a single abstract theorem. Every result has been formally
verified. The contribution is methodological as much as mathematical: it
demonstrates that a celebrated proof strategy can be reverse-engineered into a
precise higher-order schema and reused across domains with zero duplicated
argument.

---

## 1. Introduction

### 1.1 Motivation: strategies as objects

Mathematical proofs are routinely described by their *strategy* — "a descent," "a
counting argument," "a primitive divisor argument" — yet these strategies are
rarely written down as precise, reusable objects. A strategy lives in the folklore;
each new application reconstructs it from scratch around new data. This paper is a
case study in the opposite discipline, which we call **proof strategy mining**:
take a celebrated argument, identify the *minimal* hypothesis that makes it run,
and repackage the entire chain of consequences as a schema parametrized over that
hypothesis. The payoff is that new instances become corollaries, and structurally
identical theorems from different fields are revealed as one.

### 1.2 The two source theorems

Our source material is two classical primitive-divisor theorems.

**Carmichael's theorem (Fibonacci).** Let $F_n$ denote the Fibonacci numbers. A
prime $p$ is a *primitive divisor* of $F_n$ if $p \mid F_n$ but $p \nmid F_k$ for
$0 < k < n$. Carmichael's theorem states that $F_n$ has a primitive divisor for all
$n$ outside a small finite exceptional set. The structural backbone of the proof is
the **law of apparition**: $p \mid F_n$ if and only if the rank of apparition of
$p$ divides $n$.

**Zsygmondy's theorem ($a^n - 1$).** For the sequence $u_n = a^n - 1$, the
analogous statement holds: $a^n - 1$ has a primitive prime divisor for all $n$
outside a small exceptional set. The backbone here is that $p \mid a^n - 1$ if and
only if $\operatorname{ord}_p(a) \mid n$.

The two backbones are visibly the same statement. The thesis of this paper is that
this is not a coincidence but a theorem about an abstract structure.

### 1.3 The mined hypothesis

Auditing the Fibonacci argument reveals that it uses exactly one property of $F$,
namely
$$\gcd(F_m, F_n) = F_{\gcd(m,n)}.$$
The sequence $a^n - 1$ satisfies the identical identity
$\gcd(a^m - 1, a^n - 1) = a^{\gcd(m,n)} - 1$. We therefore abstract both into the
hypothesis of a **strong divisibility sequence** and develop the entire theory from
it.

### 1.4 Contributions

1. A precise schema (Section 3–5) deriving the full primitive-divisor theory from
   the single hypothesis $\gcd(u_m, u_n) = u_{\gcd(m,n)}$: the meet law, rigidity,
   the pinning law, the join law, and counting/density formulas.
2. A canonical **rank of apparition** construction (Section 6) that manufactures the
   primitive index from a prime alone, yielding a self-contained criterion
   $p \mid u_m \iff \operatorname{rank}(p) \mid m$ and a rank-form join law.
3. Two instantiations (Section 7): Fibonacci ($F$) and Mersenne-type ($a^n - 1$),
   recovering both classical laws of apparition as specializations of one theorem.
4. A methodological template (Section 9) for mining proof strategies into reusable
   schemata, with discussion of what the schema does *not* trivialize (the growth
   estimate at the heart of the existence theorems).

---

## 2. Definitions

Throughout, $u : \mathbb{N} \to \mathbb{N}$ is a sequence of natural numbers, and
all divisibility is in $\mathbb{N}$.

**Definition 2.1 (Strong divisibility sequence).** The sequence $u$ is a *strong
divisibility sequence* if
$$u_{\gcd(m,n)} = \gcd(u_m, u_n) \qquad \text{for all } m, n \in \mathbb{N}.$$
We write this predicate $\mathrm{IsStrongDivSeq}(u)$.

**Definition 2.2 (Primitive divisor / primitive index).** A number $p$ is a
*primitive divisor* of $u_n$, written $\mathrm{IsPrimitive}(u, p, n)$, if
$$p \mid u_n \quad\text{and}\quad \forall k,\ 0 < k < n \Rightarrow p \nmid u_k.$$
We then call $n$ a *primitive index* for $p$.

**Definition 2.3 (Apparition).** The number $p$ *appears* in $u$, written
$\mathrm{Appears}(u, p)$, if there exists $k$ with $0 < k$ and $p \mid u_k$.

**Definition 2.4 (Rank of apparition).** The *rank of apparition* of $p$ in $u$ is
$$\operatorname{rank}(u, p) = \inf\{\, k \in \mathbb{N} : 0 < k \ \wedge\ p \mid u_k \,\},$$
with the convention that the infimum of the empty set is $0$.

We remark that Definition 2.2 makes no positivity assumption on $n$; index $0$
behaves as a degenerate case (see Lemma 3.3) and is excluded in the substantive
results by the hypothesis $0 < n$.

---

## 3. Elementary consequences of the strong-divisibility law

The first two results show that the gcd identity already contains the weak
divisibility law and the sharp meet law.

**Lemma 3.1 (Strong implies weak; `IsStrongDivSeq.dvd_of_dvd`).**
If $\mathrm{IsStrongDivSeq}(u)$ and $m \mid n$, then $u_m \mid u_n$.

*Proof sketch.* From $m \mid n$ we have $\gcd(m,n) = m$, so the hypothesis gives
$u_m = u_{\gcd(m,n)} = \gcd(u_m, u_n)$, and $\gcd(u_m, u_n) \mid u_n$. $\qquad\blacksquare$

**Lemma 3.2 (Meet law; `IsStrongDivSeq.dvd_gcd_index_iff`).**
If $\mathrm{IsStrongDivSeq}(u)$ then for every $d, m, n$,
$$d \mid u_{\gcd(m,n)} \iff d \mid u_m \ \wedge\ d \mid u_n.$$

*Proof sketch.* Rewrite the left side using $u_{\gcd(m,n)} = \gcd(u_m, u_n)$ and
apply the universal property $d \mid \gcd(x,y) \iff d \mid x \wedge d \mid y$.
$\qquad\blacksquare$

Lemma 3.2 is the lattice-theoretic heart of the schema: divisibility *into* the
sequence is a meet-preserving map from the index lattice $(\mathbb{N}, \mid)$.

**Lemma 3.3 (Degenerate index zero; `isPrimitive_zero_everything`).**
If $u_0 = 0$ then every $p$ is a primitive divisor of $u_0$. (Membership holds
because $p \mid 0$; the minimality clause is vacuous.)

This lemma records why the substantive statements require $0 < n$: index $0$ is
universally primitive when $u_0 = 0$, as for both Fibonacci ($F_0 = 0$) and
$a^0 - 1 = 0$.

---

## 4. Rigidity and the pinning law

**Theorem 4.1 (Uniqueness of primitive index; `isPrimitive_unique`).**
For any $u$ (no strong-divisibility hypothesis needed), if $0 < m$, $0 < n$, and $p$
is a primitive divisor of both $u_m$ and $u_n$, then $m = n$.

*Proof sketch.* Suppose without loss of generality $m < n$. Primitivity at $n$
forbids $p \mid u_m$ for $0 < m < n$, contradicting $p \mid u_m$ from primitivity at
$m$. Hence $m = n$. The argument uses only the definition of primitivity, exhibiting
its rigidity. $\qquad\blacksquare$

**Theorem 4.2 (Pinning law; `dvd_iff_index_dvd_of_primitive`).**
If $\mathrm{IsStrongDivSeq}(u)$, $0 < n$, and $p$ is a primitive divisor of $u_n$,
then for all $m$,
$$p \mid u_m \iff n \mid m.$$

*Proof sketch.*
*($\Leftarrow$)* If $n \mid m$ then $u_n \mid u_m$ by Lemma 3.1, and $p \mid u_n$,
so $p \mid u_m$.
*($\Rightarrow$)* Suppose $p \mid u_m$. With $p \mid u_n$, the meet law (Lemma 3.2)
gives $p \mid u_{\gcd(n,m)}$. Since $\gcd(n,m) \mid n$ we have $\gcd(n,m) \le n$, and
$\gcd(n,m) > 0$; primitivity of $p$ at $n$ forbids $p \mid u_k$ for $0 < k < n$, so
$\gcd(n,m)$ cannot be strictly less than $n$. Hence $\gcd(n,m) = n$, i.e. $n \mid m$.
$\qquad\blacksquare$

Theorem 4.2 is the abstract law of apparition. It upgrades the order-theoretic
notion of primitivity to a concrete arithmetic test and is the precise common
generalization of the Fibonacci and Mersenne laws.

---

## 5. The join law and counting

**Theorem 5.1 (Simultaneous apparition; `simultaneous_apparition`).**
If $\mathrm{IsStrongDivSeq}(u)$, $0 < a$, $0 < b$, $p$ is primitive for $u_a$ and
$q$ is primitive for $u_b$, then for all $n$,
$$(p \mid u_n) \wedge (q \mid u_n) \iff \operatorname{lcm}(a,b) \mid n.$$

*Proof sketch.* Apply Theorem 4.2 to each conjunct, reducing to $a \mid n$ and
$b \mid n$, then use $a \mid n \wedge b \mid n \iff \operatorname{lcm}(a,b) \mid n$.
$\qquad\blacksquare$

**Theorem 5.2 (Finite-family join; `simultaneous_apparition_finset`).**
Let $S$ be a finite index set with, for each $i \in S$, a primitive divisor $f_i$ of
$u_{g_i}$ and $0 < g_i$. Then for all $n$,
$$\Big(\forall i \in S,\ f_i \mid u_n\Big) \iff \Big(\operatorname{lcm}_{i \in S} g_i\Big) \mid n.$$

*Proof sketch.* Induct on $S$ with the empty case $\operatorname{lcm}\emptyset = 1
\mid n$, using Theorem 4.2 and $\operatorname{lcm}$ of an inserted element at each
step. $\qquad\blacksquare$

**Theorem 5.3 (Apparition density; `apparition_count`).**
If $\mathrm{IsStrongDivSeq}(u)$, $0 < n$, and $p$ is primitive for $u_n$, then for
all $N$,
$$\#\{\, e \in \{0,\dots,N-1\} : p \mid u_{e+1} \,\} = \left\lfloor \frac{N}{n} \right\rfloor.$$
In particular the natural density of apparition indices of $p$ is $1/n$.

*Proof sketch.* Theorem 4.2 rewrites the predicate $p \mid u_{e+1}$ as $n \mid
(e+1)$; the count of multiples of $n$ in the first $N$ shifted indices is
$\lfloor N/n \rfloor$. $\qquad\blacksquare$

**Theorem 5.4 (Joint density; `simultaneous_apparition_count`).**
Under the hypotheses of Theorem 5.1, for all $N$,
$$\#\{\, e \in \{0,\dots,N-1\} : p \mid u_{e+1} \wedge q \mid u_{e+1} \,\} = \left\lfloor \frac{N}{\operatorname{lcm}(a,b)} \right\rfloor.$$

*Proof sketch.* Theorem 5.1 rewrites the joint predicate as
$\operatorname{lcm}(a,b) \mid (e+1)$; count as in Theorem 5.3. $\qquad\blacksquare$

These four results show the schema reaches beyond pure structure into quantitative,
analytic-flavored statements: the apparition lattice is reflected exactly in natural
densities.

---

## 6. The rank of apparition: a self-contained criterion

The pinning law (Theorem 4.2) requires a primitive index to be supplied. We now
construct it canonically from $p$ via the rank (Definition 2.4), turning the theory
into a criterion phrased purely in terms of $\operatorname{rank}$.

**Lemma 6.1 (Rank membership; `rank_mem`, `rank_pos`, `rank_dvd`).**
If $\mathrm{Appears}(u, p)$ then $0 < \operatorname{rank}(u,p)$ and
$p \mid u_{\operatorname{rank}(u,p)}$.

*Proof sketch.* The appearance set is nonempty; the infimum of a nonempty set of
naturals is a member, and the defining predicate carries both conjuncts.
$\qquad\blacksquare$

**Lemma 6.2 (Rank minimality; `rank_le`).**
If $0 < k$ and $p \mid u_k$ then $\operatorname{rank}(u,p) \le k$.

*Proof sketch.* The infimum is a lower bound of the set containing $k$.
$\qquad\blacksquare$

**Theorem 6.3 (Rank is a primitive index; `rank_primitive`).**
If $\mathrm{Appears}(u, p)$ then $p$ is a primitive divisor of
$u_{\operatorname{rank}(u,p)}$.

*Proof sketch.* Membership (Lemma 6.1) gives $p \mid u_{\operatorname{rank}}$;
minimality (Lemma 6.2, contrapositive) forbids $p \mid u_k$ for any positive
$k < \operatorname{rank}$. Together these are exactly primitivity. $\qquad\blacksquare$

**Theorem 6.4 (Uniqueness via rank; `isPrimitive_iff_eq_rank`).**
For $0 < n$,
$$\mathrm{IsPrimitive}(u, p, n) \iff n = \operatorname{rank}(u, p).$$

*Proof sketch.* ($\Leftarrow$) Theorem 6.3. ($\Rightarrow$) Primitivity at $n$
makes $p$ appear, so the rank is a primitive index by Theorem 6.3; uniqueness
(Theorem 4.1) forces $n = \operatorname{rank}$. $\qquad\blacksquare$

**Theorem 6.5 (Strong primitive-divisor criterion; `dvd_iff_rank_dvd`).**
If $\mathrm{IsStrongDivSeq}(u)$ and $\mathrm{Appears}(u, p)$, then for all $m$,
$$p \mid u_m \iff \operatorname{rank}(u,p) \mid m.$$

*Proof sketch.* By Theorem 6.3 the rank is a primitive index for $p$; apply the
pinning law (Theorem 4.2) at $n = \operatorname{rank}(u,p)$. $\qquad\blacksquare$

Theorem 6.5 is the polished, self-contained form of the apparition law: the
divisibility set of $p$ is *exactly* the set of multiples of its rank, with no
external data.

**Theorem 6.6 (Join law in ranks; `joint_dvd_iff_lcm_rank_dvd`).**
If $\mathrm{IsStrongDivSeq}(u)$, $\mathrm{Appears}(u, p)$, and
$\mathrm{Appears}(u, q)$, then for all $n$,
$$(p \mid u_n) \wedge (q \mid u_n) \iff \operatorname{lcm}\big(\operatorname{rank}(u,p),\, \operatorname{rank}(u,q)\big) \mid n.$$

*Proof sketch.* Rewrite each conjunct via Theorem 6.5 and apply
$x \mid n \wedge y \mid n \iff \operatorname{lcm}(x,y) \mid n$. $\qquad\blacksquare$

---

## 7. Instantiations

The abstract schema is now exercised against the two canonical examples by
verifying only the gcd identity in each case.

**Proposition 7.1 (Fibonacci; `fib_isStrongDivSeq`).**
$\mathrm{IsStrongDivSeq}(F)$, where $F$ is the Fibonacci sequence.

*Proof sketch.* Immediate from the classical identity $\gcd(F_m, F_n) =
F_{\gcd(m,n)}$. $\qquad\blacksquare$

**Proposition 7.2 (Mersenne-type; `mersenne_isStrongDivSeq`).**
For every base $a$, $\mathrm{IsStrongDivSeq}(n \mapsto a^n - 1)$.

*Proof sketch.* Immediate from $\gcd(a^m - 1, a^n - 1) = a^{\gcd(m,n)} - 1$
(the base case $a = 0$ is handled directly). $\qquad\blacksquare$

Specializing Theorem 6.5 yields the two laws of apparition as corollaries of a
single theorem:

**Corollary 7.3 (Fibonacci law of apparition; `fib_dvd_iff_rank_dvd`).**
If $p$ appears in $F$, then $p \mid F_m \iff \operatorname{rank}(F, p) \mid m$.

**Corollary 7.4 (Mersenne law of apparition; `mersenne_dvd_iff_rank_dvd`).**
If $p$ appears in $n \mapsto a^n - 1$, then
$p \mid a^m - 1 \iff \operatorname{rank}(\,\cdot\,, p) \mid m$, where the rank is the
multiplicative order of $a$ modulo $p$ when $\gcd(a,p)=1$.

Corollary 7.4 makes the bridge explicit: the abstract rank, for $a^n - 1$, *is* the
multiplicative order of $a$ modulo $p$, so the abstract criterion is the
order-theoretic law of apparition that underlies Zsygmondy's theorem.

---

## 8. Worked numerical examples

We illustrate the criteria with small data; the `demo.py` companion computes these.

**Fibonacci, $p = 11$.** The Fibonacci numbers are $0,1,1,2,3,5,8,13,21,34,55,\dots$,
so $11 \mid F_{10} = 55$ and $11 \nmid F_k$ for $0 < k < 10$. Hence
$\operatorname{rank}(F, 11) = 10$, and by Theorem 6.5, $11 \mid F_m$ exactly when
$10 \mid m$: indeed $F_{20} = 6765 = 3 \cdot 5 \cdot 11 \cdot 41$.

**Fibonacci, two primes.** $\operatorname{rank}(F, 2) = 3$ (since $F_3 = 2$) and
$\operatorname{rank}(F, 11) = 10$. By Theorem 6.6, both $2$ and $11$ divide $F_n$
exactly when $\operatorname{lcm}(3,10) = 30 \mid n$. The first such index is $30$.

**Mersenne, $a = 2$, $p = 7$.** The sequence $2^n - 1$ is $1,3,7,15,31,63,\dots$, so
$7 \mid 2^3 - 1 = 7$ and $7$ divides no earlier term; $\operatorname{rank} = 3 =
\operatorname{ord}_7(2)$. By Theorem 6.5, $7 \mid 2^m - 1 \iff 3 \mid m$.

**Density check.** For $p = 11$ in Fibonacci ($\operatorname{rank} = 10$), among the
first $N = 100$ positive indices exactly $\lfloor 100/10 \rfloor = 10$ are
apparition indices, confirming Theorem 5.3 and density $1/10$.

---

## 9. Discussion: what was mined, and what remains hard

### 9.1 The methodological template

The development above is an instance of a repeatable template for **proof strategy
mining**:

1. *Audit.* Trace a celebrated proof line by line and record which properties of the
   concrete objects each step actually consumes.
2. *Isolate.* Identify the minimal hypothesis (here, the single gcd identity) that
   supports the whole chain.
3. *Abstract.* Restate every consequence using only that hypothesis, producing a
   schema parametrized over the abstract structure.
4. *Reinstantiate.* Verify the hypothesis for each concrete object of interest; the
   full theory then transfers with no further argument.

The audit step is where the mathematics happens: the discovery that neither the
Fibonacci recurrence nor Binet's formula is ever used — only the gcd identity — is
the genuine insight, and it is exactly what makes the abstraction possible.

### 9.2 Honest limits of the schema

The schema captures the *structural* core of Carmichael's and Zsygmondy's theorems
— the law of apparition and its consequences — but deliberately not their *existence*
content. Both theorems assert that primitive divisors actually exist for all large
$n$, and that assertion reduces, after the structural reduction, to a single growth
estimate: the primitive part of $u_n$ (the quotient of $u_n$ by the contributions of
proper-divisor indices) must exceed $1$. This is a size inequality, not a divisibility
fact, and no amount of lattice abstraction can supply it. The schema makes precise
*where* the hard analytic work must go, which is itself valuable: it separates the
reusable skeleton from the irreducible residue.

### 9.3 Why the abstraction is faithful

Two safeguards ensure the abstraction is not vacuous. First, every substantive
theorem is guarded by positivity ($0 < n$), reflecting the genuine degeneracy at
index $0$ (Lemma 3.3) where both example sequences vanish. Second, the schema is
exercised on genuine primitive divisors of real sequences (Section 8), so the
biconditionals are non-trivially satisfiable, not vacuously true.

---

## 10. Future work

We record several directions, including conjectures that the present schema brings
within reach.

1. **Universal existence via the schema.** Combine the criterion with a single
   sequence-agnostic growth bound $u_n > \prod_{d \mid n,\, d < n} u_d$ to obtain
   primitive-divisor existence for all large $n$ uniformly across strong
   divisibility sequences — closing the existence content left open in Section 9.2
   without any sequence-specific computation.

2. **A characterization of strong divisibility sequences.** Conjecturally, a
   sequence with $u_1 = 1$ is a strong divisibility sequence iff it is
   multiplicative on coprime indices and satisfies the weak divisibility law; the
   rank would then be exactly the structure making divisibility-into-$u$ an adjoint
   of index divisibility.

3. **Cross-instantiation transfer.** Investigate whether a primitive index for $p$
   in the Fibonacci sequence forces a primitive prime in $2^n - 1$ at the same
   index, giving an explicit correspondence between Fibonacci and Mersenne primitive
   divisors.

4. **Further hosts.** Apply the audit–isolate–abstract–reinstantiate template to
   other strong divisibility sequences (Lucas sequences, elliptic divisibility
   sequences) and to entirely different proof strategies.

---

## 11. Conclusion

We mined the primitive-divisor proof strategy shared by Carmichael's and
Zsygmondy's theorems, isolated its single load-bearing hypothesis — the strong
divisibility identity $\gcd(u_m, u_n) = u_{\gcd(m,n)}$ — and rebuilt the entire
structural theory of primitive divisors as a reusable schema: meet law, rigidity,
pinning law, join law, density formulas, and the self-contained rank criterion. Two
instantiations recover two classical laws of apparition from one abstract theorem.
The exercise demonstrates that proof strategies can be treated as first-class
mathematical objects — reverse-engineered, stated precisely, and reused across
domains — and it pinpoints the irreducible analytic residue (a growth estimate) that
abstraction cannot remove.
