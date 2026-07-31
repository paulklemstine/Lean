# Perfect Privacy, Exact Thresholds, and Algebraic Verification in Polynomial Secret Sharing

**Aristotle**  
**31 July 2026**

## Abstract

Threshold secret sharing distributes a field element among participants so that sufficiently large coalitions can reconstruct it while smaller coalitions obtain no information. This paper develops the algebraic core of Shamir secret sharing and an abstract additive formulation of Feldman verifiable secret sharing. Over an arbitrary field $F$, a secret is the value at zero of a polynomial of degree less than a threshold $t$, and shares are evaluations at distinct nonzero locations. We prove an exact interpolation theorem: after fixing arbitrary observations at $t-1$ nonzero locations, every candidate secret extends those observations in exactly one polynomial of degree less than $t$. Over a finite field with uniform coefficient sampling, this bijection gives information-theoretic privacy. We then prove that the reconstruction threshold for degree-at-most-$d$ polynomials is exactly $d+1$: that many distinct evaluations force equality, whereas $d$ nonzero evaluations can agree for polynomials having different values at zero. Finally, given an injective additive commitment homomorphism, we formulate Feldman’s verification equation, prove completeness for honest shares and perfect algebraic detection of altered shares, and show that $d+1$ accepted evaluations determine the unique committed polynomial. Explicit algorithms, complexity bounds, and examples illustrate reconstruction, privacy witnesses, and verification.

## 1. Introduction

A conventional secret is controlled by whoever possesses a single representation of it. Threshold secret sharing instead distributes control. For an integer $t\ge 1$, the intended policy is that any authorized collection of at least $t$ suitable shares can reconstruct the secret, while an unauthorized collection of at most $t-1$ shares cannot distinguish one possible secret from another.

Shamir’s construction realizes this policy with polynomial interpolation. Let $F$ be a field and let $s\in F$ be the secret. A dealer chooses coefficients $a_1,\ldots,a_{t-1}\in F$ and forms

$$
p(X)=s+a_1X+\cdots+a_{t-1}X^{t-1}.
$$

Each participant is assigned a distinct nonzero location $x_i\in F$ and receives $p(x_i)$. The secret is $p(0)$. The construction is linear, conceptually economical, and information-theoretic.

Three claims must be distinguished. First, **privacy** asks what an undersized coalition can infer. Second, **reconstruction** asks whether enough consistent values determine the secret. Third, **verifiability** asks whether distributed values are consistent with one polynomial selected by the dealer. Basic Shamir sharing provides the first two under honest distribution. Feldman-style coefficient commitments address the third.

The central results established below are these.

1. For any prescribed values at $t-1$ distinct nonzero points and any prescribed secret, exactly one polynomial of degree less than $t$ realizes all the data.
2. Consequently, in the finite uniform model, the distribution of any $t-1$ shares is independent of the secret.
3. Degree-at-most-$d$ polynomials require exactly $d+1$ evaluations for unconditional unique reconstruction: $d+1$ suffice, and $d$ nonzero evaluations can fail to determine even the value at zero.
4. For an injective additive coefficient-commitment map, an honest share always verifies and every altered share is rejected.
5. If evaluations of a degree-at-most-$d$ candidate pass against a degree-at-most-$d$ committed polynomial at $d+1$ distinct points, the candidate equals the committed polynomial.

The assumptions are deliberately explicit. The privacy and threshold arguments require only field algebra. The verification argument treats commitments through an additive homomorphism and requires injectivity for unconditional soundness. In practical Feldman systems the conventional notation is multiplicative, and the relevant security interpretation is normally computational; the abstract theorem here isolates the exact algebraic implication of injectivity.

## 2. Algebraic setting and definitions

### 2.1 Fields and polynomials

Let $F$ be a field. All polynomial coefficients, evaluation locations, shares, and secrets lie in $F$. For $p\in F[X]$, write $\deg p$ for its degree, with the zero polynomial treated in the usual way as having degree below every natural degree bound. A finite set of locations is always understood to contain distinct elements because it is a set.

The foundational fact is the root bound: a nonzero polynomial of degree at most $d$ has at most $d$ distinct roots. Equivalently, if two polynomials of degree at most $d$ agree at $d+1$ distinct points, they are equal.

### 2.2 Shamir sharing

**Definition 2.1 (Share).** For a polynomial $p\in F[X]$ and a location $x\in F$, the share value at $x$ is

$$
\operatorname{Share}_p(x)=p(x).
$$

**Definition 2.2 (Valid threshold polynomial).** Given a threshold $t\in\mathbb N$ and a secret $s\in F$, a polynomial $p$ is valid when

$$
\deg p<t
\qquad\text{and}\qquad
p(0)=s.
$$

Participant locations are required to be nonzero when privacy relative to the secret is discussed. A share at $0$ would reveal $p(0)=s$ directly.

For randomized Shamir sharing over a finite field, the dealer fixes $a_0=s$ and samples $a_1,\ldots,a_{t-1}$ independently and uniformly from $F$. This selects uniformly from the $|F|^{t-1}$ valid coefficient vectors.

### 2.3 Lagrange interpolation

For distinct points $z_1,\ldots,z_m\in F$, define the Lagrange basis polynomials

$$
L_i(X)=\prod_{\substack{1\le j\le m\\j\ne i}}
\frac{X-z_j}{z_i-z_j}.
$$

They satisfy $L_i(z_j)=1$ if $i=j$ and $L_i(z_j)=0$ otherwise. Therefore prescribed values $w_1,\ldots,w_m$ have the interpolant

$$
I(X)=\sum_{i=1}^{m}w_iL_i(X),
$$

which has degree less than $m$ and obeys $I(z_i)=w_i$. Uniqueness follows because the difference of two such interpolants has $m$ roots but degree less than $m$.

### 2.4 Additive coefficient commitments

Let $G$ be an abelian group written additively, and let

$$
C:F\longrightarrow G
$$

be an additive homomorphism. Thus $C(u+v)=C(u)+C(v)$ and $C(0)=0_G$. The additive notation abstracts the usual multiplicative notation $g^a$: group sums correspond to products of conventional commitments.

If

$$
p(X)=\sum_{i=0}^{d}a_iX^i,
$$

the public coefficient commitments are $C(a_0),\ldots,C(a_d)$. For a location $x$ and a claimed value $y$, define the verification condition by

$$
C(y)=\sum_{i=0}^{d}C(a_ix^i).
$$

Zero coefficients can be omitted from the finite sum without changing it.

The soundness results assume that $C$ is injective: $C(u)=C(v)$ implies $u=v$. This assumption precisely identifies the algebraic property used to turn equality of commitments into equality of field elements.

## 3. Perfect privacy below the threshold

### 3.1 Unique extension theorem

**Theorem 3.1 (Perfect Privacy Extension Theorem).** Let $A\subset F$ consist of exactly $t-1$ distinct nonzero elements. Let $v:A\to F$ prescribe an arbitrary observed value at every point of $A$, and let $s\in F$ be any candidate secret. Then there exists exactly one polynomial $p\in F[X]$ such that

$$
\deg p<t,
\qquad p(0)=s,
\qquad p(x)=v(x)\quad\text{for every }x\in A.
$$

**Proof sketch.** Since $0\notin A$, the enlarged set $A\cup\{0\}$ contains exactly $t$ distinct points. Prescribe value $s$ at $0$ and value $v(x)$ at each $x\in A$. Lagrange interpolation on these $t$ points produces a polynomial of degree less than $t$ satisfying all conditions. If $p$ and $q$ both satisfy them, then $p-q$ has all $t$ points as roots and has degree less than $t$, unless it is zero. The root bound forces $p-q=0$, proving uniqueness. $\square$

This statement is stronger than bare existence. For each fixed observation transcript, candidate secrets and compatible low-degree polynomials are in one-to-one correspondence. The secret can vary freely, but once it is selected, the entire polynomial is fixed.

**Corollary 3.2 (No candidate secret is excluded).** Under the hypotheses of Theorem 3.1, for any two secrets $s_1,s_2\in F$, there exist valid threshold polynomials $p_1,p_2$ satisfying

$$
p_1(0)=s_1,
\qquad p_2(0)=s_2,
\qquad p_1(x)=p_2(x)=v(x)
$$

for all $x\in A$.

**Proof sketch.** Apply Theorem 3.1 separately to $s_1$ and $s_2$. $\square$

This corollary captures privacy without probability language: the transcript logically rules out no field element as the secret.

### 3.2 Distributional consequence over finite fields

**Theorem 3.3 (Information-theoretic privacy).** Let $F$ be finite, let $t>0$, and fix $t-1$ distinct nonzero locations. For each secret $s\in F$, choose the remaining $t-1$ coefficients of a degree-less-than-$t$ sharing polynomial independently and uniformly from $F$. Then the resulting vector of $t-1$ shares is uniformly distributed over $F^{t-1}$, and its distribution is independent of $s$.

**Proof sketch.** Fix a share vector $v\in F^{t-1}$. Theorem 3.1 says that for each fixed secret $s$, exactly one degree-less-than-$t$ polynomial has constant term $s$ and produces $v$. Equivalently, exactly one coefficient tuple $(a_1,\ldots,a_{t-1})$ maps to $v$. There are $|F|^{t-1}$ equally likely tuples, so the probability of $v$ is $|F|^{-(t-1)}$ for every $s$. Thus every transcript has the same probability under every secret. $\square$

The independence is unconditional. It does not depend on a computational hardness assumption, and an adversary with unlimited computation gains no statistical advantage from the observed shares.

### 3.3 Why the nonzero condition is necessary

The restriction $0\notin A$ is structural. If $0\in A$, the observation at that location is $p(0)=s$, so the secret is revealed. In the interpolation proof, attempting to adjoin $(0,s)$ would duplicate an already observed location, and arbitrary prescribed data could be inconsistent. Thus nonzero participant identifiers are not a cosmetic convention.

## 4. Reconstruction and the exact threshold

### 4.1 Sufficiency of $d+1$ values

**Theorem 4.1 (Unique reconstruction from degree plus one).** Let $p,q\in F[X]$ have degree at most $d$. If they agree at $d+1$ distinct locations, then $p=q$.

**Proof sketch.** Let $r=p-q$. Its degree is at most $d$. Every agreement location is a root of $r$, so $r$ has at least $d+1$ distinct roots. The root bound implies that $r$ cannot be nonzero. Hence $p=q$. $\square$

It follows that $d+1$ shares of a degree-at-most-$d$ polynomial determine the polynomial and its secret. Reconstruction can be performed by Lagrange interpolation. If the points are $(x_i,y_i)$ for $1\le i\le d+1$, then

$$
p(X)=\sum_{i=1}^{d+1}y_i
\prod_{j\ne i}\frac{X-x_j}{x_i-x_j}.
$$

If only the secret is required, one evaluates at zero without explicitly expanding the polynomial:

$$
p(0)=\sum_{i=1}^{d+1}y_i
\prod_{j\ne i}\frac{-x_j}{x_i-x_j}.
$$

A direct implementation uses $O(d^2)$ field operations and $O(d)$ auxiliary storage. Faster multipoint interpolation is available for large instances, but the quadratic method is transparent and adequate for demonstrating the theorem.

### 4.2 Necessity: $d$ values can fail

**Theorem 4.2 (Failure of reconstruction from only $d$ nonzero values).** Let $A\subset F$ contain exactly $d$ distinct nonzero locations. Then there exist distinct polynomials $p,q\in F[X]$, each of degree at most $d$, such that

$$
p(x)=q(x)\quad\text{for every }x\in A,
$$

but

$$
p(0)\ne q(0).
$$

**Proof sketch.** Define

$$
r(X)=\prod_{a\in A}(X-a).
$$

Take $p=r$ and $q=0$. The polynomial $r$ has degree $d$ and vanishes on $A$, so $p$ and $q$ agree at all supplied locations. Yet

$$
r(0)=\prod_{a\in A}(-a)\ne 0
$$

because a product of nonzero field elements is nonzero. Thus $p(0)\ne q(0)$ and $p\ne q$. $\square$

**Theorem 4.3 (Exact Reconstruction Threshold).** For the class of polynomials of degree at most $d$, the unconditional reconstruction threshold is exactly $d+1$: evaluations at any $d+1$ distinct locations uniquely determine the polynomial, while for every set of $d$ distinct nonzero locations there are two admissible polynomials agreeing there and encoding different secrets at zero.

**Proof sketch.** Combine Theorems 4.1 and 4.2. $\square$

This theorem explains both sides of Shamir’s threshold $t=d+1$. The threshold is not selected merely because interpolation happens to work there; it is minimal in the strongest general sense.

## 5. Verifiable sharing through coefficient commitments

### 5.1 The evaluation identity

**Lemma 5.1 (Committed evaluation identity).** Let $C:F\to G$ be an additive homomorphism and let $p(X)=\sum_i a_iX^i$. For every $x\in F$,

$$
C(p(x))=\sum_i C(a_ix^i).
$$

**Proof sketch.** Polynomial evaluation gives $p(x)=\sum_i a_ix^i$. Apply $C$ and repeatedly use preservation of finite sums. $\square$

The identity is the algebraic engine of Feldman verification. It permits a participant to compare a commitment to a claimed evaluation with a public combination derived from coefficient commitments.

**Theorem 5.2 (Completeness for honest shares).** Every genuine share $y=p(x)$ satisfies the verification equation

$$
C(y)=\sum_i C(a_ix^i).
$$

**Proof sketch.** Substitute $y=p(x)$ and invoke Lemma 5.1. $\square$

Thus honest distribution never causes rejection in the exact algebraic model.

### 5.2 Detection of altered shares

**Theorem 5.3 (Cheating Detection Theorem).** Suppose $C:F\to G$ is injective. If a claimed share $y$ at location $x$ satisfies

$$
C(y)=\sum_i C(a_ix^i),
$$

then $y=p(x)$. Equivalently, every claim $y\ne p(x)$ fails verification.

**Proof sketch.** By Lemma 5.1, the right side equals $C(p(x))$. Hence acceptance gives $C(y)=C(p(x))$. Injectivity of $C$ yields $y=p(x)$. Taking the contrapositive proves rejection of every altered value. $\square$

The theorem is exact under its assumption: no error probability appears. It is important, however, to distinguish the abstract injective model from concrete group encodings. If the exponent representation identifies multiple field elements, injectivity must be interpreted on an appropriate domain or replaced by the computational binding statement supplied by the application.

### 5.3 Global consistency from accepted shares

**Theorem 5.4 (Accepted-Share Reconstruction Theorem).** Let $p$ be the committed polynomial and $q$ a candidate polynomial, both of degree at most $d$. Suppose $C$ is injective and there is a set $A$ of $d+1$ distinct locations such that, for every $x\in A$, the candidate value $q(x)$ passes verification against the coefficient commitments of $p$. Then

$$
q=p.
$$

**Proof sketch.** At each $x\in A$, Theorem 5.3 turns acceptance into $q(x)=p(x)$. The two degree-at-most-$d$ polynomials therefore agree at $d+1$ distinct points. Theorem 4.1 gives $q=p$. $\square$

This combines local verification and global reconstruction. Verification certifies each accepted point; interpolation then certifies the entire curve. In particular, $q(0)=p(0)$, so the reconstructed secret is the secret fixed by the public coefficient commitments.

## 6. Algorithms

### 6.1 Modular arithmetic model

For numerical work, take $F=\mathbb F_p$, where $p$ is prime. Addition and multiplication are reduced modulo $p$, and division by nonzero $a$ means multiplication by $a^{p-2}\bmod p$. Locations must be distinct modulo $p$, and participant locations must be nonzero.

### 6.2 Share generation

Given $p$, threshold $t$, secret $s$, distinct nonzero locations, and optional coefficients $a_1,\ldots,a_{t-1}$, form

$$
f(X)=s+\sum_{j=1}^{t-1}a_jX^j
$$

and return $(x_i,f(x_i))$ for each participant. Horner evaluation costs $O(t)$ field operations per share, so $n$ shares cost $O(nt)$ operations. Random coefficients must be sampled with a cryptographically secure source in production.

### 6.3 Secret reconstruction

For any $t$ shares, compute

$$
s=\sum_{i=1}^{t}y_i\lambda_i,
\qquad
\lambda_i=\prod_{j\ne i}\frac{-x_j}{x_i-x_j}.
$$

The straightforward nested-loop algorithm costs $O(t^2)$ field operations and uses $O(t)$ space. It should reject duplicate locations, because then a denominator vanishes.

### 6.4 Constructing privacy witnesses

Given $t-1$ observed pairs and a proposed secret $s$, interpolate through those pairs together with $(0,s)$. The resulting unique degree-less-than-$t$ polynomial is a witness that the observations are compatible with $s$. Repeating this for every $s\in\mathbb F_p$ displays the full privacy fiber. Using direct Lagrange interpolation, constructing one expanded coefficient vector costs $O(t^2)$ to $O(t^3)$ depending on polynomial multiplication strategy; for educational small instances, the simple quadratic polynomial-arithmetic approach is sufficient.

### 6.5 Feldman-style verification

For the abstract additive commitment map $C$, compute

$$
L=C(y),
\qquad
R=\sum_i C(a_ix^i),
$$

and accept exactly when $L=R$. A direct implementation uses $O(d)$ field and group operations. In conventional multiplicative notation with commitments $A_i=g^{a_i}$, the check is usually written

$$
g^y=\prod_i A_i^{x^i}.
$$

The additive formulation makes the homomorphism used in the proof explicit.

## 7. Numerical example

Work in $\mathbb F_{17}$ with threshold $t=3$ and polynomial

$$
p(X)=5+7X+3X^2.
$$

The secret is $p(0)=5$. Evaluating gives

$$
p(1)=15,
\qquad p(2)=14,
\qquad p(3)=2
\pmod {17}.
$$

Using the first three shares, the Lagrange weights at zero are

$$
\lambda_1=3,
\qquad \lambda_2=14,
\qquad \lambda_3=1
\pmod {17}.
$$

Therefore

$$
p(0)=15\cdot3+14\cdot14+2\cdot1
=243
\equiv 5\pmod {17}.
$$

Now expose only $(1,15)$ and $(2,14)$. For every $s\in\mathbb F_{17}$, interpolation through $(0,s)$, $(1,15)$, and $(2,14)$ produces exactly one polynomial of degree at most two. Thus all seventeen candidate secrets fit the same two observed shares.

For an elementary injective commitment demonstration, take $G$ to be the additive group of $\mathbb F_{17}$ and define

$$
C(a)=4a\pmod {17}.
$$

Since $4\ne0$, multiplication by $4$ is injective. At $x=2$, the true share is $14$. Its commitment is $C(14)=5$. The right side of the verification equation is

$$
C(5)+C(7\cdot2)+C(3\cdot2^2)
=3+5+14
=22
\equiv5\pmod {17}.
$$

The share passes. A modified claim $15$ has commitment $C(15)=9$, so it fails. This toy commitment is intended to reveal the algebra, not to supply a deployed cryptographic commitment.

## 8. Applications and interpretation

Threshold sharing can distribute recovery credentials, certification authority, escrow capability, or control of cryptographic keys. Its security benefit is the removal of a single point of disclosure: compromising fewer than $t$ participants reveals no information about the secret in the ideal model. Its availability benefit is that reconstruction does not require every participant, only an authorized threshold.

Verifiable secret sharing matters when the dealer may be faulty or malicious. Without verification, inconsistent shares can cause different authorized coalitions to interpolate different polynomials. Public coefficient commitments let each participant test whether a received value lies on the committed curve. The Accepted-Share Reconstruction Theorem then guarantees agreement among reconstructions based on sufficiently many accepted shares.

The results also illuminate linear secret-sharing structure. Evaluation is linear in the coefficients, and reconstruction is a fixed linear combination of share values. This makes Shamir shares compatible with many multiparty computations: parties can add shares locally to obtain shares of a sum. Multiplication is subtler because degrees grow, but the polynomial viewpoint remains central.

Several operational concerns lie outside the algebraic model. Implementations must authenticate participant identities, protect private channels, generate coefficients uniformly, erase ephemeral randomness, validate field encodings, and handle absent or malicious participants. Side-channel resistance and robust error correction require additional mechanisms. The present theorems identify the exact mathematical guarantees on which those systems build.

## 9. Discussion

The privacy proof and reconstruction proof are two faces of the same dimension count. A polynomial with $t$ coefficients has $t$ degrees of freedom. Fixing the constant coefficient leaves $t-1$ random degrees of freedom; observing $t-1$ evaluations consumes exactly those, leaving the secret unconstrained. One more evaluation fixes the whole polynomial. The interpolation theorem makes this intuition exact over every field.

The counterexample polynomial

$$
\prod_{a\in A}(X-a)
$$

is especially informative. It vanishes precisely where the undersized coalition looks while remaining nonzero at the secret location. Adding any scalar multiple of it to a candidate polynomial preserves every observed share but changes the secret. For exactly $d$ observations and degree bound $d$, this produces the missing one-dimensional ambiguity.

Feldman verification adds a second linear map: coefficients are sent into a commitment group. The committed evaluation identity follows because both polynomial evaluation at a fixed $x$ and the commitment map respect addition. Injectivity then reflects equality back from the group to the field. The entire soundness argument can therefore be read as a composition of linear or additive maps followed by the polynomial root bound.

There is a conceptual tradeoff. Coefficient commitments support consistency checks, but conventional Feldman commitments are not designed to hide coefficients information-theoretically. Pedersen-style commitments add random blinding to separate hiding from binding. The abstract results here focus on the consistency layer and should not be read as claiming that every commitment realization preserves the perfect hiding property of unaided Shamir shares.

## 10. Future work

Several extensions follow naturally.

First, the exact-counting privacy theorem can be developed into a complete probabilistic treatment over finite fields, including conditional distributions and mutual information. The bijection in Theorem 3.1 already supplies the decisive counting step.

Second, batch soundness can be formulated directly for a vector of accepted claims: interpolate the claims and prove that $d+1$ accepted locations yield exactly the committed degree-at-most-$d$ polynomial. Theorem 5.4 gives the core argument.

Third, robust reconstruction should accommodate errors. Reed–Solomon decoding predicts unique recovery of a degree-at-most-$d$ polynomial from $n$ values containing at most $e$ errors when

$$
n\ge d+2e+1.
$$

Establishing sharpness and implementing decoding would extend threshold reconstruction from erasures to adversarial corruption.

Fourth, Pedersen verifiable sharing should distinguish hiding and binding in a two-generator setting. One seeks perfect hiding of coefficient commitments while preventing inconsistent accepted shares under an appropriate binding assumption.

Finally, proactive refresh protocols add a random degree-less-than-$t$ polynomial with zero constant term. This leaves the secret unchanged while replacing every participant’s share, limiting the value of compromises accumulated across time.

## 11. Conclusion

Polynomial secret sharing derives privacy and access control from exact interpolation. Any $t-1$ observations at nonzero locations are compatible with every secret in exactly one degree-less-than-$t$ polynomial, yielding information-theoretic privacy under uniform sampling. Any $t=d+1$ distinct evaluations determine a degree-at-most-$d$ polynomial, and the vanishing-product construction proves that one fewer can fail to determine even its value at zero. An injective additive commitment homomorphism then makes Feldman’s verification equation complete and sound: genuine shares pass, altered shares fail, and $d+1$ accepted candidate evaluations recover the unique committed polynomial.

The resulting picture is modular. Interpolation supplies privacy witnesses and reconstruction; root counting proves exactness; homomorphic commitments certify consistency. Together these ingredients explain how a secret can be distributed without being exposed and how participants can ensure that their private fragments belong to one public algebraic story.