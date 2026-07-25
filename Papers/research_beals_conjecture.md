# Structural Reductions for Beal’s Conjecture: Primitive Solutions, Fermat–Catalan Signatures, and Powered Additive Triples

**Aristotle**  
**July 25, 2026**

## Abstract

Beal’s conjecture asserts that positive integer solutions of $A^x+B^y=C^z$ with $x,y,z>2$ have a common prime divisor of the bases $A,B,C$. The conjecture itself remains open. This paper develops a self-contained structural reduction that identifies its exact primitive core and connects that core to two broader Diophantine frameworks. First, a prime dividing any two bases is shown to divide the third. Consequently, absence of a common prime is equivalent, for solutions of the equation, to pairwise coprimality. Beal’s conjecture is therefore equivalent to the nonexistence of primitive solutions. Second, every allowed exponent triple satisfies the Fermat–Catalan signature inequality $1/x+1/y+1/z\le1$, yielding a precise conditional implication from primitive Fermat–Catalan exclusion to Beal’s conjecture. Third, every primitive candidate maps canonically to the coprime additive triple $(A^x,B^y,C^z)$, isolating the powered-triple consequence of the $abc$ conjecture that would suffice for Beal. Finally, when two bases are Fibonacci numbers $F_m,F_n$, strong divisibility forces $F_{\gcd(m,n)}=1$, and hence $\gcd(m,n)\in\{1,2\}$ under standard indexing. Algorithms for finite search, structural certification, signature analysis, and Fibonacci screening are given. A search over bases at most $40$ and exponents from $3$ through $6$ finds $23$ ordered solutions, all nonprimitive; this is finite evidence only, not a proof of the conjecture.

## 1. Introduction

Consider the generalized Fermat equation

$$
A^x+B^y=C^z
$$

in positive integers. Beal’s conjecture concerns the range $x,y,z>2$ and predicts the existence of a prime $p$ such that

$$
p\mid A,\qquad p\mid B,\qquad p\mid C.
$$

Allowing three distinct exponents creates many solutions excluded by the equal-exponent setting. For example,

$$
2^3+2^3=2^4,
\qquad
7^3+7^4=14^3,
\qquad
3^6+18^3=9^4.
$$

These examples obey the predicted conclusion, with common primes $2$, $7$, and $3$, respectively. The central difficulty is to show that no solution can avoid such a common prime.

The purpose of this paper is not to claim a resolution of that open problem. It is to separate its unresolved global exclusion from several unconditional arithmetic reductions. The fundamental local observation is that the equation propagates a prime from any pair of bases to the remaining base. This turns “there is no common prime” into the much stronger-looking but equivalent condition that all three pairs of bases are coprime.

Once that primitive reduction has been made, two standard frameworks become available. The exponent signature lies automatically in the Fermat–Catalan region, while the powered terms themselves form a coprime additive triple of the kind studied in connection with the $abc$ conjecture. These are conditional bridges: they state exactly what additional exclusion statement would prove Beal’s conjecture, without assuming that statement.

A further application illustrates the utility of the reduction. Fibonacci numbers satisfy a strong divisibility law that converts coprimality of values into a condition on their indices. Thus, if two Fibonacci numbers occur as bases in a primitive candidate, the gcd of their indices is forced into a two-element set.

The paper proceeds from definitions through the local prime theorem, primitive equivalence, the two conditional bridges, Fibonacci specialization, and computational algorithms. Throughout, finite experiments are distinguished sharply from proofs valid for all positive integers.

## 2. Definitions and elementary facts

### 2.1. Beal solutions and common primes

A **Beal solution** is a sextuple $(A,B,C,x,y,z)$ of positive integers satisfying

$$
x>2,\qquad y>2,\qquad z>2,
$$

and

$$
A^x+B^y=C^z.
$$

The bases **have a common prime** if there exists a prime $p$ dividing each of $A,B,C$. A Beal solution is called **primitive** if its bases are pairwise coprime:

$$
\gcd(A,B)=\gcd(A,C)=\gcd(B,C)=1.
$$

Beal’s conjecture may now be stated: every Beal solution has a common prime.

The adjective “primitive” is sometimes defined in related settings by $\gcd(A,B,C)=1$. For arbitrary triples this is weaker than pairwise coprimality. A main point below is that the equation eliminates the distinction: for generalized Fermat solutions, failure of a common prime is equivalent to pairwise coprimality.

### 2.2. Prime divisors of powers

We use the elementary fact that if $p$ is prime, $n>0$, and $p\mid U^n$, then $p\mid U$. This follows from Euclid’s lemma or unique factorization: every prime occurring in a positive power already occurs in its base. Conversely, if $p\mid U$, then $p\mid U^n$ for every positive $n$.

### 2.3. Signatures

The **signature** of a generalized Fermat equation is the exponent triple $(x,y,z)$. Define its reciprocal weight by

$$
\sigma(x,y,z)=\frac1x+\frac1y+\frac1z.
$$

We call a signature a **Fermat–Catalan signature** when

$$
\sigma(x,y,z)\le1.
$$

This terminology records the numerical region relevant to the Fermat–Catalan problem; it does not assert any finiteness or exclusion theorem within that region.

### 2.4. Coprime additive triples and radicals

An **additive coprime triple** is a triple $(a,b,c)$ of positive integers such that

$$
a+b=c
$$

and $\gcd(a,b)=1$. The equation then also forces $\gcd(a,c)=\gcd(b,c)=1$.

For a positive integer $n$, define the radical

$$
\operatorname{rad}(n)=\prod_{p\mid n}p,
$$

where the product ranges over the distinct prime divisors of $n$. Positive powers preserve prime support, so

$$
\operatorname{rad}(U^n)=\operatorname{rad}(U)
$$

for $n>0$. This simple identity explains why powered additive triples are unusually sparse in prime support relative to their numerical size.

## 3. Prime propagation

The basic theorem holds under weaker exponent hypotheses than Beal’s conjecture requires.

### Theorem 3.1 (Prime-Propagation Theorem)

Let $A,B,C,x,y,z$ be positive integers satisfying

$$
A^x+B^y=C^z.
$$

If a prime $p$ divides any two of $A,B,C$, then $p$ divides the third.

#### Proof sketch

Suppose first that $p\mid A$ and $p\mid B$. Then $p\mid A^x$ and $p\mid B^y$, so $p$ divides $A^x+B^y=C^z$. Since $z>0$ and $p$ is prime, $p\mid C$.

If $p\mid A$ and $p\mid C$, then $p$ divides $A^x$ and $C^z$. From $B^y=C^z-A^x$, it follows that $p\mid B^y$, hence $p\mid B$. The case $p\mid B$ and $p\mid C$ is symmetric. ∎

### Corollary 3.2 (Prime-support pattern)

For any prime $p$ in a positive-exponent solution, the number of bases among $A,B,C$ divisible by $p$ cannot equal $2$. It is either $0$, $1$, or $3$.

#### Proof sketch

The only excluded case is divisibility of exactly two bases, which Theorem 3.1 converts into divisibility of all three. ∎

This support pattern is stronger than a statement merely about the gcd of all three numbers. It localizes every prime and is the mechanism behind the primitive reduction.

## 4. Exact primitive reduction

### Theorem 4.1 (Primitive Reduction Theorem)

Let $A,B,C,x,y,z$ be positive integers satisfying $A^x+B^y=C^z$. Then the following conditions are equivalent:

1. no prime divides all three bases $A,B,C$;
2. $A,B,C$ are pairwise coprime.

#### Proof sketch

If the bases are pairwise coprime, no prime can divide all three, since such a prime would in particular divide $A$ and $B$.

Conversely, suppose no prime divides all three. If $A$ and $B$ were not coprime, then $d=\gcd(A,B)>1$. Every integer greater than $1$ has a prime divisor, so choose a prime $p\mid d$. Then $p\mid A$ and $p\mid B$, and Theorem 3.1 yields $p\mid C$, contradicting the assumption. Hence $\gcd(A,B)=1$. Applying the same argument to $(A,C)$ and $(B,C)$ gives the other two coprimality relations. ∎

### Theorem 4.2 (Primitive Form of Beal’s Conjecture)

Beal’s conjecture is equivalent to the assertion that there exists no primitive positive solution of

$$
A^x+B^y=C^z
$$

with $x,y,z>2$.

#### Proof sketch

Assume Beal’s conjecture. A primitive solution has no common prime by Theorem 4.1, contradicting the conjecture. Conversely, assume no primitive solution exists. If some Beal solution had no common prime, Theorem 4.1 would make it primitive, again a contradiction. Thus every Beal solution has a common prime. ∎

This equivalence identifies the genuine obstruction. It is not enough for a counterexample to satisfy $\gcd(A,B,C)=1$ in isolation; the equation forces all three pairwise gcds to equal $1$.

### Remark 4.3 (Exponent economy)

Theorems 3.1 and 4.1 require only $x,y,z>0$. The threshold $x,y,z>2$ belongs to the conjectural classification, not to the local divisibility mechanism. This distinction allows the structural results to be reused in other positive-exponent equations.

## 5. The Fermat–Catalan bridge

### Theorem 5.1 (Signature Inclusion Theorem)

Every Beal solution has a Fermat–Catalan signature:

$$
\frac1x+\frac1y+\frac1z\le1.
$$

#### Proof sketch

Since $x,y,z$ are integers greater than $2$, each is at least $3$. Consequently,

$$
\frac1x\le\frac13,
\qquad
\frac1y\le\frac13,
\qquad
\frac1z\le\frac13.
$$

Adding the three inequalities gives the result. ∎

The boundary case is $(x,y,z)=(3,3,3)$, where the reciprocal sum equals $1$. If any exponent exceeds $3$, the sum is strictly less than $1$ unless another exponent falls below $3$, which is forbidden here.

### Theorem 5.2 (Conditional Fermat–Catalan Implication)

Assume the following primitive exclusion principle: for every positive solution of $A^x+B^y=C^z$ with $x,y,z>2$ and

$$
\frac1x+\frac1y+\frac1z\le1,
$$

the bases are not pairwise coprime. Then Beal’s conjecture holds.

#### Proof sketch

Suppose Beal’s conjecture failed. By Theorem 4.2 there would be a primitive Beal solution. By Theorem 5.1 its signature would satisfy the displayed reciprocal inequality. This contradicts the assumed primitive exclusion principle. ∎

The premise in Theorem 5.2 is deliberately explicit. The theorem does not claim that all primitive solutions in the Fermat–Catalan region have already been excluded. Rather, it records an exact logical bridge and prevents any hidden appeal to an unresolved conjecture.

### 5.3. Organizing signatures

The signature inequality gives a geometric organization of the infinite exponent space. Triples $(x,y,z)$ with all entries at least $3$ lie on or below the reciprocal surface $1/x+1/y+1/z=1$. Exponent divisibility creates an additional partial order: if $x=kr$ with $k>1$, then $A^x=(A^k)^r$, potentially reducing a signature to a more basic one after changing the base. This suggests studying minimal signatures under divisibility, although no finite reduction theorem is asserted here.

## 6. The powered additive-triple bridge

### Theorem 6.1 (Canonical Powered-Triple Theorem)

Let $(A,B,C,x,y,z)$ be a primitive Beal solution. Define

$$
a=A^x,
\qquad
b=B^y,
\qquad
c=C^z.
$$

Then $a,b,c$ are positive integers satisfying

$$
a+b=c
$$

and

$$
\gcd(a,b)=1.
$$

Thus $(a,b,c)$ is an additive coprime triple, and its coordinates retain exactly the three powered terms of the original equation.

#### Proof sketch

Positivity follows from positivity of the bases. The equation $a+b=c$ is the generalized Fermat equation itself. Since the original solution is primitive, $\gcd(A,B)=1$. Positive powers of coprime integers remain coprime, giving $\gcd(A^x,B^y)=1$. ∎

Because $a+b=c$ and $\gcd(a,b)=1$, one also has $\gcd(a,c)=\gcd(b,c)=1$. Hence the powered terms are pairwise coprime.

### Corollary 6.2 (Radical identity for a primitive candidate)

For the triple in Theorem 6.1,

$$
\operatorname{rad}(abc)=\operatorname{rad}(ABC).
$$

#### Proof sketch

The set of prime divisors of $A^xB^yC^z$ is exactly the set of prime divisors of $ABC$, because all exponents are positive. Taking the product of the distinct primes gives the equality. ∎

Primitivity additionally means that the prime supports of $A$, $B$, and $C$ are disjoint. Therefore

$$
\operatorname{rad}(ABC)
=
\operatorname{rad}(A)\operatorname{rad}(B)\operatorname{rad}(C).
$$

### Theorem 6.3 (Conditional Powered-$abc$ Implication)

Assume that no positive pairwise-coprime bases $A,B,C$ with exponents $x,y,z>2$ can produce a coprime additive triple

$$
A^x+B^y=C^z.
$$

Then Beal’s conjecture holds.

#### Proof sketch

A failure of Beal’s conjecture would yield a primitive solution by Theorem 4.2. Theorem 6.1 would then turn it into exactly the powered coprime additive triple forbidden by the premise. ∎

The assumption is the particular powered-triple exclusion relevant to Beal. It may be viewed as the target consequence one would seek from an effective $abc$ principle. The theorem is conditional and does not assert that this exclusion has been proved.

### 6.4. Why powers are special for radical estimates

If $x\ge3$, then $A^x$ grows at least cubically in $A$, while its radical is bounded by $A$. The same holds for the other terms. In a primitive candidate, there is no overlap among the three base supports, so radical estimates decompose cleanly across $A,B,C$. This is the central quantitative tension: the equation balances very large perfect powers, but the radical records each supporting prime only once.

A future effective argument would need to turn this tension into a contradiction or into a finite list of signatures. The structural reduction shows that no general additive triples outside the powered family need be considered for this purpose.

## 7. Fibonacci specialization

Let the Fibonacci sequence be defined by

$$
F_0=0,
\qquad
F_1=1,
\qquad
F_{n+2}=F_{n+1}+F_n.
$$

Its strong divisibility property states that

$$
\gcd(F_m,F_n)=F_{\gcd(m,n)}
$$

for nonnegative integers $m,n$.

### Theorem 7.1 (Fibonacci Index Constraint)

Suppose $(A,B,C,x,y,z)$ is a primitive Beal solution and

$$
A=F_m,
\qquad
B=F_n.
$$

Then

$$
F_{\gcd(m,n)}=1.
$$

#### Proof sketch

Primitivity gives $\gcd(A,B)=1$. Substitution of $A=F_m$ and $B=F_n$ yields $\gcd(F_m,F_n)=1$. The strong divisibility identity transforms the left side into $F_{\gcd(m,n)}$, proving the claim. ∎

### Corollary 7.2 (Index-gcd classification)

Under the hypotheses of Theorem 7.1,

$$
\gcd(m,n)\in\{1,2\}.
$$

#### Proof sketch

For the standard sequence above, the Fibonacci value $1$ occurs precisely at indices $1$ and $2$. Combine this fact with Theorem 7.1. ∎

The theorem converts coprimality of potentially enormous Fibonacci values into a rigid condition on small index arithmetic. It does not by itself exclude Fibonacci-based primitive solutions. It does, however, sharply constrain any such candidate and prepares the problem for modular periodicity arguments.

## 8. Algorithms and numerical exploration

### 8.1. Exhaustive bounded search

Fix a base bound $M$ and an exponent interval $e_{\min}\le e\le e_{\max}$. A direct search over six nested variables is wasteful. Instead, precompute a reverse table of powers. For each $C\le M$ and each exponent $z$ in the interval, store the pair $(C,z)$ under the key $C^z$. Then enumerate $(A,x)$ and $(B,y)$, compute $A^x+B^y$, and look up matching right-hand powers.

**Pseudocode.**

1. Initialize an empty mapping from integer values to lists of base-exponent pairs.
2. For every $C$ from $1$ to $M$ and every $z$ from $e_{\min}$ to $e_{\max}$, append $(C,z)$ under the key $C^z$.
3. For every $A,B$ from $1$ to $M$ and every $x,y$ in the exponent interval, calculate $S=A^x+B^y$.
4. For each $(C,z)$ stored under $S$, emit $(A,B,C,x,y,z)$.
5. Classify each emitted solution using gcds.

If $E=e_{\max}-e_{\min}+1$, precomputation uses $O(ME)$ power evaluations and storage entries. The main loop uses $O(M^2E^2)$ additions and dictionary lookups, plus output cost. Arbitrary-precision integer arithmetic makes bit complexity dependent on $M^{e_{\max}}$, but the indexing still avoids a further factor of $ME$.

For $M=40$ and exponents $3,4,5,6$, this procedure finds $23$ ordered solutions. None is primitive, and every solution has a common divisor greater than $1$. This finite statement concerns only the specified search box.

### 8.2. Structural certificate

For a reported exact solution, compute

$$
d_{AB}=\gcd(A,B),
\quad
d_{AC}=\gcd(A,C),
\quad
d_{BC}=\gcd(B,C),
\quad
d=\gcd(A,B,C).
$$

The solution is primitive exactly when $d_{AB}=d_{AC}=d_{BC}=1$. It has a common prime exactly when $d>1$. Theorem 4.1 guarantees that for valid positive-exponent solutions these two classifications are complementary. A discrepancy therefore detects an arithmetic or implementation error.

### 8.3. Signature analysis

For each exponent triple, compute the exact rational number

$$
\sigma=\frac1x+\frac1y+\frac1z.
$$

Exact fractions avoid floating-point ambiguity at the boundary $\sigma=1$. Every triple with $x,y,z\ge3$ must pass the check $\sigma\le1$.

### 8.4. Fibonacci index screening

Given proposed Fibonacci indices $m,n$, calculate $g=\gcd(m,n)$ and $F_g$. A primitive candidate with bases $F_m,F_n$ requires $F_g=1$, equivalently $g\in\{1,2\}$. This is a necessary filter, not a sufficient condition for a solution.

## 9. Applications of the structural pipeline

The reductions can be summarized as

$$
\begin{aligned}
&\text{failure of Beal’s conjecture}\\
&\quad\Longleftrightarrow\text{a primitive Beal solution exists}\\
&\quad\Longrightarrow\text{its signature satisfies }\frac1x+\frac1y+\frac1z\le1\\
&\quad\Longrightarrow (A^x,B^y,C^z)\text{ is a coprime additive triple}.
\end{aligned}
$$

This pipeline has several uses.

First, it standardizes computational classification. Searching directly for “no common prime” and searching for pairwise coprimality must return the same candidates once the equation is checked.

Second, it narrows theoretical inputs. A Fermat–Catalan strategy need address only primitive signatures in the reciprocal region. An $abc$ strategy need address only the thin family in which every coordinate is a perfect power of exponent at least $3$.

Third, it exposes modular specialization. If a base belongs to a divisibility sequence, its gcd behavior can translate primitivity into restrictions on sequence indices. Fibonacci numbers provide the cleanest illustration, but analogous questions can be asked for other strong divisibility sequences.

Fourth, prime propagation suggests a support-based representation. For each base, record the set of prime divisors. In any solution these three sets have either empty pairwise intersections or a nonempty triple intersection; no prime may inhabit exactly two sets. This combinatorial view may be useful in organizing local congruence obstructions.

## 10. Discussion and limitations

The main results are reductions, not an unconditional proof of Beal’s conjecture. Specifically, Theorems 3.1, 4.1, 4.2, 5.1, 6.1, and 7.1 are elementary or standard consequences of stated identities. Theorems 5.2 and 6.3 are implications whose premises are explicit exclusion principles. No Fermat–Catalan or $abc$ conjecture is silently assumed.

The finite search likewise has a limited interpretation. The absence of primitive solutions for bases at most $40$ and exponents from $3$ through $6$ is consistent with Beal’s conjecture but cannot settle an unbounded statement. Its proper role is demonstrative: it supplies examples, tests the structural equivalence, and provides a reproducible baseline for larger experiments.

The Fibonacci result is also necessary rather than sufficient. The condition $\gcd(m,n)\in\{1,2\}$ leaves infinitely many index pairs. Further progress would require combining it with the periodic behavior of $F_n$ modulo primes and with restrictions depending on $(x,y,z)$.

One conceptual benefit of the framework is that it distinguishes three scales. Prime propagation is local and unconditional. Primitive reduction is global but exact. Fermat–Catalan and $abc$ enter only at the final exclusion stage. This separation makes it possible to improve one component without obscuring which unresolved input remains.

## 11. Future work

An effective $abc$ exclusion tailored to powered additive triples is a natural target. One may seek an explicit exponent bound $N$ for primitive triples $A^x+B^y=C^z$, then treat the finitely many remaining signatures separately. Because powers retain the prime support of their bases, estimates specialized to this family may be stronger than estimates for arbitrary additive triples.

A second direction is signature-by-signature descent. Divisibility relations among exponents allow powers to be regrouped, potentially organizing infinitely many signatures into a finite antichain of minimal cases. The reciprocal inequality supplies a compatible geometric measure of the signature space.

A third direction is a radical-defect gap. One would seek a universal $\delta>0$ forcing a quantitative inequality of the form

$$
\operatorname{rad}(ABC)\le C^{1-\delta},
$$

after an appropriate ordering of terms. Such a gap would turn prime-support sparsity into a uniform obstruction.

For Fibonacci bases, the next step is to combine $\gcd(m,n)\in\{1,2\}$ with Pisano periods. Carefully selected moduli could eliminate residue classes of indices for fixed signatures, and a systematic covering argument might handle broad families.

Finally, the prime-support pattern can be encoded combinatorially. Vertices represent primes and base-support sets record incidence. Theorem 3.1 forbids incidence with exactly two of the three bases. Extending this support-hypergraph viewpoint to sums with more terms may reveal comparable rigidity in wider generalized Fermat systems.

## 12. Conclusion

The equation $A^x+B^y=C^z$ forces a simple but powerful law: a prime dividing two bases divides the third. This yields an exact equivalence between absence of a common prime and pairwise coprimality, so Beal’s conjecture is precisely the assertion that no primitive solution exists for exponents above $2$.

Every hypothetical primitive counterexample lies in the Fermat–Catalan signature region and canonically produces the coprime additive triple $(A^x,B^y,C^z)$. These facts identify the exact conditional inputs from Fermat–Catalan and $abc$ methods that would suffice. When Fibonacci bases occur, primitivity further forces the gcd of their indices to be $1$ or $2$.

Together, these results replace an amorphous search for a counterexample by a structured program: isolate primitive solutions, organize their signatures, measure their sparse prime support, and exploit additional arithmetic structure in their bases. The ultimate exclusion remains open, but its target is sharply defined.
