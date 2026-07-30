# A Period-36 Covering Certificate for the Sierpiński Number 78557

**Aristotle**  
**July 30, 2026**

## Abstract

For a positive odd integer $k$, the Sierpiński property requires every number $k2^n+1$, with $n\ge 0$, to be composite. This paper gives a self-contained covering-system proof that $78557$ has this property. Seven congruence classes of exponents,

$$
0\pmod2,\quad 1\pmod4,\quad 1\pmod3,\quad 11\pmod{12},\quad
15\pmod{18},\quad 27\pmod{36},\quad 3\pmod9,
$$

cover all nonnegative integers. Their associated primes are respectively

$$
3,\quad5,\quad7,\quad13,\quad19,\quad37,\quad73.
$$

For every exponent in a given class, the associated prime is a proper divisor of $78557\cdot2^n+1$. We formulate the periodicity and divisor-transfer lemmas underlying this construction, prove a general finite-certificate theorem, exhibit the complete period-$36$ certificate, and discuss algorithms for checking and discovering such certificates. We also state compatibility results for congruence classes derived from the Chinese remainder theorem. The conclusion is that $78557$ is a Sierpiński number. No minimality assertion is made: whether it is the smallest Sierpiński number remains unresolved.

## 1. Introduction

Sequences of the form

$$
N_n(k)=k2^n+1
$$

occupy a distinctive place in elementary number theory. Their terms grow rapidly, but their residues modulo a fixed prime are periodic. This tension makes it possible for finite modular data to control an infinite family.

A **Sierpiński number** is conventionally a positive odd integer $k$ such that $k2^n+1$ is composite for every nonnegative integer $n$. The purpose of this paper is to prove the following result.

**Main Theorem.** The integer $78557$ is positive and odd, and $78557\cdot2^n+1$ is composite for every nonnegative integer $n$. More precisely, every such term has a proper prime divisor in the set $\{3,5,7,13,19,37,73\}$.

The proof does not factor every term. Instead, it partitions all exponents into congruence classes. For each class, one small prime divides all terms whose exponents lie in that class. The least common period of the classes is $36$, reducing universal compositeness to $36$ finite modular checks.

This result is sometimes discussed in connection with the question of whether $78557$ is the smallest Sierpiński number. The distinction is essential. The theorem established here proves that $78557$ is *a* Sierpiński number. The minimality question requires excluding every smaller positive odd integer and remains open; in particular, several smaller candidates have not been eliminated.

The paper proceeds from elementary modular periodicity to a general certificate theorem, then applies it to $78557$. It concludes with compatibility theory, algorithms, applications, limitations, and future directions.

## 2. Definitions and elementary facts

All variables in this paper denote nonnegative integers unless stated otherwise.

**Definition 2.1 (Universal non-primality property).** An integer $k$ has the universal non-primality property if

$$
\text{for every }n\ge0,\quad k2^n+1\text{ is not prime}.
$$

**Definition 2.2 (Composite integer).** An integer $m$ is composite if $m>1$ and $m$ is not prime.

**Definition 2.3 (Sierpiński number).** A positive odd integer $k$ is a Sierpiński number if $k2^n+1$ is composite for every $n\ge0$.

The distinction between non-primality and compositeness merely records the lower bound $m>1$. For positive $k$, every $k2^n+1$ exceeds $1$, so the two formulations coincide in the present application.

**Definition 2.4 (Normalized congruence class).** A normalized congruence class is a pair $(a,m)$ with $m>0$ and $0\le a<m$. It contains $n$ when

$$
n\equiv a\pmod m,
$$

or equivalently $n\bmod m=a$.

**Definition 2.5 (Compatibility).** Two normalized classes $(a_1,m_1)$ and $(a_2,m_2)$ are compatible if there exists a nonnegative integer $x$ satisfying both congruences.

**Definition 2.6 (Covering system).** A finite list of normalized congruence classes is a covering system if every nonnegative integer belongs to at least one class in the list. Overlap is allowed.

The principal mechanism is periodicity of powers.

**Lemma 2.7 (Periodicity of powers of two).** Let $M>0$ and $p>0$. If

$$
2^M\equiv1\pmod p,
$$

then for every $n\ge0$,

$$
2^n\equiv2^{n\bmod M}\pmod p.
$$

**Proof sketch.** By Euclidean division, write $n=qM+r$ where $r=n\bmod M$ and $0\le r<M$. Then

$$
2^n=2^{qM+r}=(2^M)^q2^r\equiv1^q2^r=2^r\pmod p.
$$

This proves the claim. $\square$

**Lemma 2.8 (Divisor transfer).** Suppose $2^M\equiv1\pmod p$ and $p\mid k2^r+1$. If $n\equiv r\pmod M$, then

$$
p\mid k2^n+1.
$$

**Proof sketch.** The periodicity lemma gives $2^n\equiv2^r\pmod p$. Multiplication by $k$ and addition of $1$ preserve congruence, yielding

$$
k2^n+1\equiv k2^r+1\equiv0\pmod p.
$$

Thus $p$ divides the term at exponent $n$. $\square$

These two lemmas explain how a single finite check propagates through infinitely many exponents.

## 3. Finite covering certificates

A period table packages all information needed for a universal proof.

**Definition 3.1 (Finite covering certificate).** Let $k$ and $M$ be positive integers. A finite covering certificate of period $M$ assigns to every residue $r$ with $0\le r<M$ a prime $p_r$ such that:

1. $2^M\equiv1\pmod{p_r}$;
2. $p_r\mid k2^r+1$;
3. $p_r\ne k2^r+1$.

Because $p_r$ is positive and divides $k2^r+1$, the third condition says that $p_r$ is a proper divisor.

**Theorem 3.2 (Finite certificate theorem).** If a positive integer $k$ admits a finite covering certificate of period $M$, then $k2^n+1$ is not prime for every $n\ge0$. If $k$ is also odd, then $k$ is a Sierpiński number.

**Proof sketch.** Fix $n$ and put $r=n\bmod M$. The certificate supplies a prime $p_r$. By the divisor-transfer lemma,

$$
p_r\mid k2^n+1.
$$

At the representative exponent, divisibility and inequality imply

$$
p_r<k2^r+1.
$$

Since $r=n\bmod M\le n$, monotonicity of exponentiation and multiplication gives

$$
k2^r+1\le k2^n+1.
$$

Therefore $p_r<k2^n+1$. A number with a prime divisor strictly between $1$ and itself cannot be prime. Since $n$ was arbitrary, universal non-primality follows. Positivity gives $k2^n+1>1$, and oddness completes the conventional Sierpiński definition. $\square$

A class-indexed certificate is often more concise than a residue table. Suppose finitely many triples $(a_i,m_i,p_i)$ satisfy:

- the classes $n\equiv a_i\pmod{m_i}$ cover all $n\ge0$;
- $2^{m_i}\equiv1\pmod{p_i}$;
- $p_i\mid k2^{a_i}+1$;
- $p_i$ is a proper divisor of every covered term.

Taking a common multiple $M$ of all $m_i$ converts this data into a period table: for each residue modulo $M$, choose any covering class and assign its prime. Because each $m_i$ divides $M$, the relation $2^{m_i}\equiv1\pmod{p_i}$ implies $2^M\equiv1\pmod{p_i}$.

## 4. The seven-class covering for 78557

Consider the following classes and primes:

| Class of exponent $n$ | Prime $p$ |
|---|---:|
| $n\equiv0\pmod2$ | $3$ |
| $n\equiv1\pmod4$ | $5$ |
| $n\equiv1\pmod3$ | $7$ |
| $n\equiv11\pmod{12}$ | $13$ |
| $n\equiv15\pmod{18}$ | $19$ |
| $n\equiv27\pmod{36}$ | $37$ |
| $n\equiv3\pmod9$ | $73$ |

**Lemma 4.1 (Coverage).** The seven displayed congruence classes cover every nonnegative integer.

**Proof sketch.** Every modulus in the list divides $36$. Consequently, membership in every class depends only on the residue modulo $36$. It suffices to inspect the $36$ residues from $0$ through $35$. The even residues belong to the first class. Residues $1,5,9,13,17,21,25,29,33$ belong to the second. Residues $7,19,31$ belong to the third. Residues $11,23,35$ belong to the fourth. Residue $15$ belongs to the fifth, residue $27$ to the sixth, and residues $3$ and any already covered equivalents satisfying the condition belong to the seventh. Thus no residue modulo $36$ is omitted. $\square$

For transparency, the chosen prime for each residue is displayed below:

$$
\begin{array}{c|rrrrrrrrrrrr}
r&0&1&2&3&4&5&6&7&8&9&10&11\\
\hline
p_r&3&5&3&73&3&5&3&7&3&5&3&13
\end{array}
$$

$$
\begin{array}{c|rrrrrrrrrrrr}
r&12&13&14&15&16&17&18&19&20&21&22&23\\
\hline
p_r&3&5&3&19&3&5&3&7&3&5&3&13
\end{array}
$$

$$
\begin{array}{c|rrrrrrrrrrrr}
r&24&25&26&27&28&29&30&31&32&33&34&35\\
\hline
p_r&3&5&3&37&3&5&3&7&3&5&3&13.
\end{array}
$$

**Lemma 4.2 (Classwise divisibility).** If $n$ lies in one of the seven classes, then the prime paired with that class divides $78557\cdot2^n+1$.

**Proof sketch.** Each row follows from a period congruence and one base divisibility. The required data are

$$
\begin{array}{c|c|c|c}
a&m&p&\text{base and period conditions}\\
\hline
0&2&3&2^2\equiv1\pmod3,\quad3\mid78557\cdot2^0+1\\
1&4&5&2^4\equiv1\pmod5,\quad5\mid78557\cdot2^1+1\\
1&3&7&2^3\equiv1\pmod7,\quad7\mid78557\cdot2^1+1\\
11&12&13&2^{12}\equiv1\pmod{13},\quad13\mid78557\cdot2^{11}+1\\
15&18&19&2^{18}\equiv1\pmod{19},\quad19\mid78557\cdot2^{15}+1\\
27&36&37&2^{36}\equiv1\pmod{37},\quad37\mid78557\cdot2^{27}+1\\
3&9&73&2^9\equiv1\pmod{73},\quad73\mid78557\cdot2^3+1.
\end{array}
$$

The divisor-transfer lemma applies to each row. For example, if $n\equiv1\pmod3$, then $2^n\equiv2\pmod7$. Since $78557\equiv3\pmod7$, one obtains

$$
78557\cdot2^n+1\equiv3\cdot2+1=7\equiv0\pmod7.
$$

The other six rows are identical in structure. $\square$

The use of period $36$ can also be verified directly. For every prime in the set,

$$
2^{36}\equiv1\pmod p.
$$

Indeed, the smaller periods $2,4,3,12,18,36,9$ all divide $36$. The classwise data therefore induce the period-$36$ table above.

**Lemma 4.3 (Properness).** For every $n\ge0$, any assigned prime from the period-$36$ table is strictly smaller than $78557\cdot2^n+1$.

**Proof sketch.** Every assigned prime is at most $73$, whereas

$$
78557\cdot2^n+1\ge78557\cdot1+1=78558>73.
$$

Thus the assigned divisor is proper. $\square$

**Theorem 4.4 (Proper prime divisor theorem).** For every nonnegative integer $n$, there exists

$$
p\in\{3,5,7,13,19,37,73\}
$$

such that $p$ is prime,

$$
p\mid78557\cdot2^n+1,
$$

and

$$
p<78557\cdot2^n+1.
$$

**Proof sketch.** Reduce $n$ modulo $36$ and select the corresponding entry $p_r$ in the table. Lemma 4.2 gives divisibility, and Lemma 4.3 gives strict inequality. Every table entry belongs to the stated seven-prime set. $\square$

**Corollary 4.5 (Universal compositeness).** For every $n\ge0$, the integer $78557\cdot2^n+1$ is composite.

**Proof sketch.** The term is greater than $1$ and has a proper prime divisor by Theorem 4.4. $\square$

**Corollary 4.6 (Sierpiński property).** The integer $78557$ is a Sierpiński number.

**Proof sketch.** It is positive and odd, and Corollary 4.5 establishes universal compositeness. $\square$

## 5. Congruence compatibility and the Chinese remainder theorem

Although the certificate above is verified through a common period, the design of covering systems benefits from general compatibility criteria.

**Theorem 5.1 (Coprime compatibility).** Let $(a_1,m_1)$ and $(a_2,m_2)$ be normalized congruence classes. If

$$
\gcd(m_1,m_2)=1,
$$

then there exists a nonnegative integer $x$ satisfying

$$
x\equiv a_1\pmod{m_1},\qquad x\equiv a_2\pmod{m_2}.
$$

**Proof sketch.** Since $m_1$ and $m_2$ are coprime, Bézout’s identity supplies integers $u,v$ with $um_1+vm_2=1$. The integer

$$
x=a_1vm_2+a_2um_1
$$

has residue $a_1$ modulo $m_1$ and residue $a_2$ modulo $m_2$. Replacing it by its residue modulo $m_1m_2$ gives a nonnegative solution. $\square$

**Theorem 5.2 (Generalized compatibility).** Let $(a_1,m_1)$ and $(a_2,m_2)$ be normalized congruence classes. If

$$
a_1\equiv a_2\pmod{\gcd(m_1,m_2)},
$$

then the two classes are compatible.

**Proof sketch.** Put $d=\gcd(m_1,m_2)$, write $m_1=du$ and $m_2=dv$, and note that $u$ and $v$ are coprime. The hypothesis gives $a_2-a_1=dt$ for some integer $t$. Seeking $x=a_1+m_1y$, the second congruence becomes

$$
uy\equiv t\pmod v.
$$

Because $u$ and $v$ are coprime, $u$ is invertible modulo $v$, so such a $y$ exists. The resulting $x$ solves both original congruences; adding a common multiple if necessary makes it nonnegative. $\square$

The converse is also elementary: any common solution forces $a_1-a_2$ to be divisible by the gcd. Establishing the full equivalence is a natural extension of the present development.

Compatibility concerns intersections of classes, whereas coverage concerns their union. The distinction matters algorithmically: a collection can have many compatible pairs and still fail to cover some residues.

## 6. Algorithms

### 6.1 Verification of a proposed class certificate

Given $k$ and triples $(a_i,m_i,p_i)$, one can check a certificate as follows.

1. Validate $0\le a_i<m_i$ and primality of $p_i$.
2. Check $2^{m_i}\equiv1\pmod{p_i}$.
3. Check $k2^{a_i}+1\equiv0\pmod{p_i}$.
4. Let $M$ be the least common multiple of all $m_i$.
5. For each $r=0,\dots,M-1$, find at least one $i$ with $r\equiv a_i\pmod{m_i}$.
6. Check that the selected prime is smaller than $k2^r+1$.

Modular exponentiation avoids constructing large powers. If there are $s$ classes, primality checks aside, row validation costs approximately $O(s\log M\log^2 P)$ bit operations for primes bounded by $P$, using repeated squaring and conventional arithmetic. A straightforward coverage scan costs $O(Ms)$ modular comparisons. For the present system, $M=36$ and $s=7$, so the computation is negligible.

### 6.2 Building the period table

For each residue $r$ modulo $M$, scan the classes until one contains $r$, then assign that class’s prime. The resulting table supports constant-time lookup of a guaranteed divisor for any exponent after computing $n\bmod M$. For arbitrary-precision $n$, this lookup takes time linear in the number of machine words used to represent $n$, followed by constant table access.

### 6.3 Discovering candidate coverings

Certificate discovery can be posed as a finite set-cover problem. Candidate rows $(a,m,p)$ cover subsets of residues modulo a chosen common period $M$. One seeks a small collection whose union is all residues. A backtracking or integer-programming solver may minimize the number of classes or distinct primes. Every proposed row must satisfy the modular divisibility constraints. Discovery may be expensive in the worst case—set cover is combinatorially difficult—but verification remains simple and deterministic.

## 7. Numerical examples

The certificate predicts divisors without factoring the whole term:

$$
\begin{array}{c|c|c|c}
n&r=n\bmod36&p_r&78557\cdot2^n+1\pmod{p_r}\\
\hline
0&0&3&0\\
1&1&5&0\\
3&3&73&0\\
7&7&7&0\\
11&11&13&0\\
15&15&19&0\\
27&27&37&0\\
35&35&13&0\\
36&0&3&0\\
63&27&37&0.
\end{array}
$$

The last two rows illustrate periodic transfer: exponent $36$ returns to residue $0$, and exponent $63$ returns to residue $27$. Even when the term itself has many digits, the divisor is obtained from a two-digit residue calculation.

## 8. Applications and broader context

The principal application is a proof of universal compositeness. More generally, finite modular certificates provide an effective interface between infinite mathematical statements and bounded computation. Once the period and local divisors are known, checking the certificate requires no open-ended search.

The construction also illustrates a useful separation between **discovery** and **verification**. Discovering a compact cover may demand experimentation, factorization of selected terms, and combinatorial search. Verifying the final cover uses only primality of small numbers, modular exponentiation, and finite coverage.

In algorithm engineering, this separation permits independent implementations to audit a certificate. In education, the example connects elementary divisibility, periodic sequences, least common multiples, and the Chinese remainder theorem in one argument. In cryptographic parameter selection, it provides a cautionary pattern: exponential-looking numbers may have predictable small divisors when exponent classes align with modular periods.

## 9. Structural interpretation of the certificate

The certificate can be viewed in three equivalent ways. The first is the seven-row class description, which is economical and exposes the different natural periods of the covering primes. The second is the length-$36$ table, which gives a total function from exponent residues to guaranteed divisors. The third is a finite-state process: the state advances from $r$ to $r+1\bmod36$, and each state emits a prime divisor. These descriptions contain the same mathematical content but serve different purposes.

The class description is best for human discovery. A factor of one selected term suggests a prime $p$; the multiplicative order of $2$ modulo $p$ then determines the progression of exponents for which that factor recurs. The table is best for verification and evaluation because it avoids searching among overlapping classes. The finite-state view makes clear that the size of $n$ is irrelevant after reduction modulo $36$.

The common period need not be minimal. Any positive multiple of $36$ would also work, with the table repeated. Period $36$ is natural because it is the least common multiple of the listed class moduli:

$$
\operatorname{lcm}(2,4,3,12,18,36,9)=36.
$$

Likewise, the assigned prime at a residue need not be unique. If several classes contain the same residue, several primes may be available. The certificate records one witness, not necessarily every prime divisor.

### 9.1 Soundness of finite reduction

The finite reduction rests on two logically separate checks. **Coverage soundness** says that every exponent reduces to a listed residue and receives an assignment. **Arithmetic soundness** says that the assignment really divides the corresponding term and continues to do so after adding a period. Neither check can replace the other. Correct divisibility rules that omit one residue fail to prove a universal result; complete coverage paired with an invalid modular rule is equally insufficient.

For this example, coverage is entirely combinatorial and arithmetic soundness is entirely modular. This separation is useful in implementations: one routine can enumerate residues and another can validate modular identities, reducing the chance that a single shared assumption masks an error.

### 9.2 Certificate complexity

Two elementary size measures are relevant. The **class complexity** is the number of congruence rules, here $7$. The **table complexity** is the common period, here $36$. A short class description can induce a larger table, while a small table may require repeated labels. Optimization can therefore target different goals: few classes for exposition, few distinct primes for arithmetic economy, or a short period for rapid lookup.

The $78557$ certificate performs well under all three measures. It uses seven classes, seven distinct primes, and a two-digit common period. More importantly, every verification operation involves small integers: no factorization of a general term is needed.

## 9. Limitations and the unresolved minimality question

The argument proves that $78557$ is a Sierpiński number. It does not prove that $78557$ is the smallest Sierpiński number. To establish minimality, every smaller positive odd $k$ would need to be excluded. For any candidate $k$, one route to exclusion is to find an exponent $n$ for which $k2^n+1$ is prime and prove that primality.

The outstanding smaller candidates traditionally listed are

$$
21181,\qquad22699,\qquad24737,\qquad55459,\qquad67607.
$$

Unless each is excluded, or one is instead proved to have universal compositeness, the minimality problem remains open. The present certificate offers no implication about those candidates.

A second limitation is structural. Pairwise compatibility of classes does not imply coverage, and a successful covering for one coefficient $k$ need not transfer to another. The modular divisibility condition couples each class tightly to $k$.

## 10. Future work

Several extensions arise naturally.

First, the generalized Chinese remainder criterion can be completed as an equivalence: two normalized congruence classes are compatible if and only if their residues agree modulo the gcd of their moduli.

Second, one can develop systematic operations on certificates, including finite unions of covering systems and automatic conversion from class-indexed certificates to common-period tables. Such operations would support modular construction of larger proofs.

Third, as primality witnesses become available for candidates below $78557$, they can be organized into a finite exclusion record. Such a record would not by itself solve the remaining cases, but it would provide a transparent account of every completed elimination.

Finally, discovery algorithms could search jointly over periods, primes, and residue classes, optimizing certificate size while retaining easy independent verification.

## 11. Reproducibility protocol

A reader can reproduce the central calculation with any system supporting integer modular exponentiation. First record the $36$ table entries. For each residue $r$, test that its entry $p_r$ is one of the seven stated primes, that $2^{36}$ has remainder $1$ modulo $p_r$, and that $78557\cdot2^r+1$ has remainder $0$ modulo $p_r$. Finally confirm $p_r<78557\cdot2^r+1$. Exactly $36$ iterations suffice. For an arbitrary challenge exponent $n$, compute $r=n\bmod36$, retrieve $p_r$, and evaluate $78557\cdot2^n+1$ modulo $p_r$ using repeated squaring. A zero remainder and the bound $p_r\le73<78558\le78557\cdot2^n+1$ reproduce the claimed proper divisor without constructing the full term.

## 11. Conclusion

The infinite family $78557\cdot2^n+1$ is controlled by a finite period-$36$ certificate. Seven congruence classes cover all exponents, and seven small primes provide divisors class by class. Periodicity transfers divisibility from representative exponents to every exponent in the same class. The assigned divisor is always proper, so every term is composite.

Thus $78557$ is a Sierpiński number. The proof is finite, explicit, and algorithmically checkable: reduce the exponent modulo $36$, read a prime from the table, and verify divisibility. The separate assertion that $78557$ is the smallest such number remains an open problem.
