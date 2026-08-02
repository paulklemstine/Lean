# Unique Error-Correcting Reconstruction of Polynomial Secret Shares

**Aristotle**  
**August 2, 2026**

## Abstract

Polynomial secret sharing encodes a secret as the constant coefficient of a low-degree polynomial and distributes evaluations of that polynomial at distinct field elements. This paper establishes the uniqueness core of error-correcting reconstruction. Given received values at $n$ distinct locations, there is at most one polynomial of degree at most $d$ that disagrees with those values in at most $e$ positions whenever $n\ge d+2e+1$. Consequently, the encoded secret is uniquely determined under the same condition. The proof isolates the union of the disagreement sets of two candidate polynomials, leaving at least $d+1$ locations where both candidates agree; polynomial interpolation then forces equality. We relate the result to the minimum distance $n-d$ of Reed–Solomon evaluation codes, distinguish uniqueness from decoding existence, give exhaustive finite-field algorithms for demonstration and validation, and discuss applications to robust secret sharing, distributed storage, and coded computation.

## 1. Introduction

Secret sharing replaces a single vulnerable copy of a secret with several distributed shares. In Shamir’s polynomial construction, a dealer works over a field $F$, chooses a polynomial whose constant coefficient is the secret, and gives different participants evaluations at distinct nonzero field elements. A sufficiently large collection of shares determines the polynomial by interpolation and hence reveals the secret, while smaller collections do not determine its constant term.

The elementary reconstruction statement assumes that all supplied shares are correct. In practice, shares may be corrupted by hardware failure, transmission errors, stale state, or malicious behavior. Reconstruction must then answer two logically separate questions:

1. **Existence:** is there a low-degree polynomial that fits all but a bounded number of received values?
2. **Uniqueness:** if such a polynomial exists, can there be another one within the same error budget?

This paper addresses the second question. The result is the standard unique-decoding threshold expressed directly in the language of polynomial shares. For degree at most $d$ and at most $e$ adversarial errors, $d+2e+1$ distinct received locations suffice for uniqueness.

The argument is short but structurally informative. If two candidates each disagree with the received word at at most $e$ positions, then at most $2e$ positions are rejected by one candidate or the other. At every remaining position, both candidates equal the same received value. With at least $d+1$ such positions, the candidates must be the same polynomial. This makes transparent why an unknown error costs twice as much redundancy as an ordinary interpolation point: two competing explanations may locate their errors in disjoint places.

The result is relevant wherever low-degree polynomial evaluation is used as an integrity-preserving representation, including verifiable and robust secret sharing, Reed–Solomon storage, secure multiparty computation, coded distributed linear algebra, and fault-tolerant aggregation in distributed learning.

## 2. Algebraic setting

### 2.1 Fields, polynomials, and degree

Let $F$ be a field and let $F[X]$ denote the ring of univariate polynomials over $F$. For $p\in F[X]$ and $x\in F$, write $p(x)$ for evaluation at $x$.

Fix a nonnegative integer $d$. A *degree-at-most-$d$ polynomial* is a polynomial $p$ satisfying $\deg p\le d$. The zero polynomial is included under the usual convention that its degree lies below every natural degree bound.

The fundamental rigidity fact is the following.

**Lemma 2.1 (Root bound).** If a nonzero polynomial $h\in F[X]$ has degree at most $d$, then it has at most $d$ distinct roots in $F$.

**Proof sketch.** The factor theorem shows that every distinct root contributes a distinct linear factor. A product of $m$ such factors has degree $m$ and divides $h$, so $m\le\deg h\le d$.

An immediate interpolation consequence will be used throughout.

**Lemma 2.2 (Agreement determines a bounded-degree polynomial).** If $p,q\in F[X]$ have degree at most $d$ and agree at $d+1$ distinct field elements, then $p=q$.

**Proof sketch.** The difference $h=p-q$ has degree at most $d$. Every agreement location is a root of $h$. If $p\ne q$, then $h$ is nonzero and Lemma 2.1 permits at most $d$ roots, contradicting the presence of $d+1$ distinct roots.

### 2.2 Polynomial secret sharing

A degree-$d$ polynomial sharing instance selects

$$
p(X)=s+a_1X+\cdots+a_dX^d,
$$

where the secret is $s=p(0)$. For pairwise distinct locations $x_1,\ldots,x_n\in F$, the distributed shares are the labeled pairs

$$
(x_i,p(x_i)),\qquad 1\le i\le n.
$$

Locations are part of the data. Distinctness is essential because repeated evaluation at one location does not provide another independent interpolation constraint. Traditional Shamir sharing often chooses all $x_i$ nonzero so that no individual share is the secret itself. The uniqueness theorem below does not require nonzero locations; it requires only that the finite collection of locations be distinct.

### 2.3 Received words and disagreement sets

Let $L\subseteq F$ be a finite set of locations, and let

$$
r:L\to F
$$

assign a received value to each location. It is harmless to regard $r$ as a function on all of $F$ because only its values on $L$ are used.

**Definition 2.3 (Disagreement set).** For a candidate polynomial $p\in F[X]$, its disagreement set relative to $L$ and $r$ is

$$
D_{L,r}(p)=\{x\in L:p(x)\ne r(x)\}.
$$

The disagreement count $|D_{L,r}(p)|$ is the Hamming distance between the evaluation vector of $p$ and the received vector. We say that $p$ is an *$e$-consistent candidate* if

$$
|D_{L,r}(p)|\le e.
$$

No assumption is made that an $e$-consistent candidate exists. The central theorem says that under the stated size condition, at most one exists among polynomials of degree at most $d$.

## 3. The combinatorial agreement principle

The central argument uses a local observation and a cardinality estimate.

**Lemma 3.1 (Agreement outside two disagreement sets).** Let $p,q\in F[X]$. If $x\in L$ lies in neither $D_{L,r}(p)$ nor $D_{L,r}(q)$, then $p(x)=q(x)$.

**Proof.** Since $x\notin D_{L,r}(p)$, one has $p(x)=r(x)$. Similarly, $q(x)=r(x)$. Therefore $p(x)=q(x)$.

For two candidates, define the jointly bad and jointly good locations by

$$
B=D_{L,r}(p)\cup D_{L,r}(q),
\qquad
G=L\setminus B.
$$

If each candidate has at most $e$ disagreements, then

$$
|B|\le |D_{L,r}(p)|+|D_{L,r}(q)|\le 2e.
$$

Because $B\subseteq L$, finite-set subtraction gives

$$
|G|=|L|-|B|.
$$

Thus, if $|L|\ge d+2e+1$, then

$$
|G|\ge |L|-2e\ge d+1.
$$

By Lemma 3.1, the two candidate polynomials agree at every location in $G$. This is the bridge from finite error counting to polynomial rigidity.

## 4. Main results

**Theorem 4.1 (Unique error-correcting reconstruction).** Let $F$ be a field, let $L\subseteq F$ be a finite set of distinct locations, and let $r:L\to F$ be a received vector. Let $d,e$ be nonnegative integers satisfying

$$
|L|\ge d+2e+1.
$$

If $p,q\in F[X]$ each have degree at most $d$ and satisfy

$$
|D_{L,r}(p)|\le e
\quad\text{and}\quad
|D_{L,r}(q)|\le e,
$$

then $p=q$.

**Proof.** Form

$$
B=D_{L,r}(p)\cup D_{L,r}(q)
$$

and $G=L\setminus B$. The union bound gives $|B|\le2e$, so

$$
|G|=|L|-|B|\ge d+1.
$$

For every $x\in G$, neither polynomial disagrees with the received value. Hence

$$
p(x)=r(x)=q(x).
$$

The candidates therefore agree at at least $d+1$ distinct locations. Lemma 2.2 implies $p=q$.

**Corollary 4.2 (Uniqueness of the reconstructed secret).** Under the hypotheses of Theorem 4.1, the constant coefficient of an $e$-consistent degree-at-most-$d$ candidate is unique. In particular, if $p$ and $q$ are two such candidates, then

$$
p(0)=q(0).
$$

**Proof.** Theorem 4.1 gives $p=q$; evaluating both sides at $0$ gives the claim.

The corollary is phrased as uniqueness rather than recovery because it does not assert an algorithm or the existence of a candidate. Its content is that the received data cannot support two different secrets through two different low-degree explanations inside the prescribed error radius.

### 4.1 Equivalent numerical forms

Writing $n=|L|$, the threshold

$$
n\ge d+2e+1
$$

is equivalent to

$$
2e<n-d.
$$

For fixed $n$ and $d$, the largest guaranteed unique-decoding radius is

$$
e_{\max}=\left\lfloor\frac{n-d-1}{2}\right\rfloor.
$$

For fixed $d$ and $e$, the theorem requires $d+1$ baseline interpolation locations and $2e$ additional locations. Each additional correctable error consumes two units of redundancy.

### 4.2 Edge cases

When $e=0$, Theorem 4.1 reduces to ordinary interpolation uniqueness from $d+1$ distinct values. When $d=0$, candidates are constant polynomials, and $2e+1$ received locations ensure that two constants cannot each agree with all but $e$ values; this is the algebraic form of strict-majority uniqueness.

The result permits $|L|$ to exceed the threshold. It also permits either disagreement count to be strictly below $e$. The field may be finite or infinite, provided enough distinct locations exist. For a finite field, feasibility requires $|L|\le |F|$.

## 5. Reed–Solomon interpretation

Fix an ordering $L=\{x_1,\ldots,x_n\}$. The evaluation map sends a polynomial $p$ of degree at most $d$ to

$$
\operatorname{ev}_L(p)=(p(x_1),\ldots,p(x_n))\in F^n.
$$

Its image is a Reed–Solomon evaluation code of dimension $d+1$ when $n\ge d+1$. The Hamming distance between vectors $u,v\in F^n$ is the number of coordinates at which they differ.

**Proposition 5.1 (Distance lower bound).** Evaluation vectors of two distinct degree-at-most-$d$ polynomials differ in at least $n-d$ coordinates.

**Proof sketch.** Distinct polynomials $p$ and $q$ can agree only where $p-q$ vanishes. Since $p-q$ is a nonzero polynomial of degree at most $d$, it has at most $d$ roots among the $n$ locations. The evaluation vectors thus disagree in at least $n-d$ coordinates.

When the field has at least $n$ elements and $d<n$, this lower bound is attained: choose a nonzero polynomial with exactly $d$ roots among the locations. Consequently, the minimum distance is $n-d$.

Theorem 4.1 also follows from the triangle inequality for Hamming distance. If a received vector $r$ lies within distance $e$ of both codewords $c_p$ and $c_q$, then

$$
\operatorname{dist}(c_p,c_q)
\le \operatorname{dist}(c_p,r)+\operatorname{dist}(r,c_q)
\le 2e.
$$

But distinct codewords have distance at least $n-d$. Therefore distinct candidates are impossible when $2e<n-d$. The direct disagreement-set proof is the coordinate-level form of this geometric argument.

## 6. Constructive procedures

The theorem is a uniqueness statement, but finite instances permit direct algorithms that expose its content.

### 6.1 Disagreement counting

Given a candidate’s coefficients, evaluate it at every location and count mismatches with the received vector. Horner’s rule evaluates a degree-at-most-$d$ polynomial using $O(d)$ field operations per location, so testing one candidate costs $O(nd)$ field operations and $O(1)$ auxiliary storage beyond the input.

**Algorithm 6.1 (Candidate consistency test).**

1. Initialize a mismatch counter to zero.
2. For each labeled received share $(x_i,r_i)$, evaluate $p(x_i)$ by Horner’s rule.
3. If $p(x_i)\ne r_i$, increment the counter.
4. Reject immediately if the counter exceeds $e$.
5. Otherwise accept after all locations have been processed.

This algorithm certifies that a proposed polynomial lies within the error budget. Under Theorem 4.1’s threshold, two distinct accepted degree-at-most-$d$ candidates cannot exist.

### 6.2 Exhaustive decoding over a finite prime field

For pedagogical examples over $\mathbf F_p$, one may enumerate all coefficient tuples

$$
(a_0,a_1,\ldots,a_d)\in\mathbf F_p^{d+1},
$$

form the corresponding polynomial, and retain those with at most $e$ disagreements. The cost is

$$
O(p^{d+1}nd)
$$

field operations, so this is not suitable for cryptographic parameters. It is, however, transparent and useful for small-instance experimentation. If $n\ge d+2e+1$, the output list has size at most one. If the list is empty, the received word is outside every radius-$e$ ball. If it contains one polynomial, its constant coefficient is the uniquely reconstructed secret.

### 6.3 Efficient decoding

Practical decoding calls for an algorithm such as Berlekamp–Welch. Its core idea is to introduce an error-locator polynomial $E$ of degree at most $e$ and a polynomial $Q$ of degree at most $d+e$, with constraints

$$
Q(x_i)=r_iE(x_i)
$$

at every location. These equations are linear in the coefficients of $E$ and $Q$ after a normalization removes scalar ambiguity. If the received word differs from a polynomial $p$ in at most $e$ positions, one expects $Q=Ep$, so division recovers $p$. Establishing the full existence and recovery theorem is beyond the uniqueness result proved here, but Theorem 4.1 guarantees that any successfully recovered degree-at-most-$d$ candidate within the radius is the only one.

## 7. Worked example

Consider the prime field $\mathbf F_{17}$ and the polynomial

$$
p(X)=5+3X+2X^2.
$$

Its degree is $2$, and its constant coefficient encodes the secret $5$. At locations $1,2,3,4,5$, its evaluations modulo $17$ are

$$
(10,2,15,15,2).
$$

Suppose the third share is corrupted to $4$, producing

$$
r=(10,2,4,15,2).
$$

The original polynomial has disagreement set $\{3\}$ and is therefore $1$-consistent. Here $n=5$, $d=2$, and $e=1$, so

$$
n=d+2e+1.
$$

If another quadratic $q$ were also $1$-consistent, the union of the two disagreement sets would contain at most two locations. At the other three or more locations, both $p$ and $q$ would equal the received values. Two quadratics that agree at three distinct locations are equal. Thus $q=p$, and the only possible reconstructed secret inside radius one is $5$.

A contrasting underdetermined example illustrates the threshold. Take $n=4$, $d=2$, and $e=1$, so $n<d+2e+1=5$. Over a sufficiently large field, two distinct quadratics can agree at two locations and differ at the other two. Construct a received vector by choosing the first polynomial’s value at one differing location and the second polynomial’s value at the other. Each polynomial then has one disagreement, producing ambiguity. This demonstrates the mechanism behind sharpness, subject to field-size and parameter feasibility.

## 8. Applications

### 8.1 Robust threshold secret sharing

In a threshold scheme based on degree at most $d$, ordinary reconstruction needs $d+1$ correct shares. If up to $e$ submitted shares may be malicious, collecting at least $d+2e+1$ distinct labeled shares ensures that no two secrets are compatible with the received data through candidates within the error budget. An implementation must still locate or decode the candidate, but the theorem guarantees the target is unambiguous.

### 8.2 Distributed storage

Reed–Solomon storage represents data through polynomial evaluations across storage nodes. When nodes return corrupted symbols, the same threshold ensures unique recovery at the codeword level. The distinction between erasures and errors is operationally important: an erased location is known to be missing, whereas an erroneous value arrives with an apparently valid label. Unknown errors are more costly because their positions must be inferred.

### 8.3 Secure multiparty computation

Many multiparty protocols represent secret state as polynomial shares. Intermediate operations can introduce malformed shares, whether through faults or adversarial deviations. A uniqueness theorem is a foundation for robust reconstruction: once enough shares are collected relative to the degree and corruption budget, there cannot be two valid low-degree outcomes inside that budget.

### 8.4 Coded and private distributed learning

Polynomial codes can distribute matrix operations, aggregation, and private data transformations among workers. Returned values may include stragglers, faults, or Byzantine responses. If the desired result is encoded in a polynomial of known degree, then the condition $n\ge d+2e+1$ specifies the redundancy needed to prevent ambiguous decoding under $e$ erroneous responses. The theorem does not rely on the semantic origin of the polynomial; it applies equally to secrets, coded gradients, and intermediate algebraic computations.

## 9. Limitations and scope

### 9.1 Parameter selection in practice

The threshold can be read as a simple capacity budget. If a deployment fixes $n$ available workers and polynomial degree $d$, then its worst-case adversarial tolerance is

$$
\left\lfloor\frac{n-d-1}{2}\right\rfloor.
$$

Conversely, a target tolerance of $e$ errors requires at least $d+2e+1$ responses. This count concerns responses actually available at reconstruction time, not merely the number of enrolled participants. If some participants fail to respond, those missing evaluations reduce the usable value of $n$. A system designer should therefore budget separately for nonresponses and erroneous responses. The former are identifiable absences; the latter consume additional redundancy because their positions are unknown. The algebra also requires pairwise distinct field locations, so the field and location-allocation policy must support the intended population. Finally, uniqueness is information-theoretic: it does not depend on a probability distribution for failures and remains valid when the erroneous values are chosen adaptively with full knowledge of the honest shares.

### 9.2 Logical scope

The result proves *at most one* candidate, not *at least one*. Existence requires a promise about the corruption process or an independently proved decoding theorem. Likewise, the proof does not identify erroneous locations and does not prescribe an efficient decoder.

Distinct locations and a valid degree bound are indispensable. If locations repeat, the number of received entries may exceed the number of distinct algebraic constraints. If the polynomial degree is unrestricted, finite agreement never determines a unique polynomial.

The result concerns adversarial symbol errors under Hamming distance. Other models—probabilistic noise, soft information, errors in location labels, extension-field symbols, or computationally bounded adversaries—require additional analysis. Cryptographic privacy is also logically separate: uniqueness of reconstruction says nothing by itself about what sub-threshold coalitions learn.

Finally, the theorem identifies the classical half-minimum-distance regime. Beyond it, uniqueness can fail. List decoding may still recover a bounded collection of candidates at larger radii, but that is a different guarantee.

## 10. Future directions

Several natural extensions complete the path from uniqueness to a comprehensive robust reconstruction theory.

**Sharpness of the decoding radius.** Under suitable feasibility assumptions, one should construct, whenever $n\le d+2e$, two distinct degree-at-most-$d$ polynomials and a received vector within $e$ disagreements of each. Such a construction would show that the threshold cannot be improved in general.

**Berlekamp–Welch existence and recovery.** If a received vector at $n\ge d+2e+1$ distinct locations differs from some degree-at-most-$d$ polynomial in at most $e$ positions, the associated error-locator linear system should admit a nontrivial solution from which division recovers the polynomial. Coupled with Theorem 4.1, this yields both existence and uniqueness of decoding under the promised error model.

**Errors and erasures.** If $s$ locations are known to be erased and at most $e$ of the remaining values are erroneous, the expected unique-reconstruction condition is

$$
n\ge d+s+2e+1.
$$

The asymmetry reflects that each known erasure consumes one evaluation, while each unknown error consumes two.

**Failure beyond half distance.** Explicit examples with

$$
2e>n-d-1
$$

should exhibit received vectors with at least two nearby degree-at-most-$d$ candidates, establishing the boundary at which unique decoding gives way to list decoding.

## 11. Conclusion

Error-correcting reconstruction of polynomial shares rests on a compact principle. Two candidates within $e$ errors of one received vector can collectively question no more than $2e$ locations. If at least $d+2e+1$ distinct locations were supplied, at least $d+1$ uncontested locations remain. Both candidates agree there, and the root bound forces them to be the same polynomial.

This proves uniqueness of both the polynomial and its constant term, the shared secret. The theorem is simultaneously a statement about robust secret sharing and the unique-decoding radius of Reed–Solomon codes. Its value lies not only in the threshold itself, but in the clean separation it provides: combinatorial counting supplies enough common agreements, algebraic rigidity converts those agreements into equality, and future decoding algorithms may focus on existence and construction knowing that the answer, when found within the radius, cannot be ambiguous.
