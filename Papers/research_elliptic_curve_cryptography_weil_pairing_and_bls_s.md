# Weil Pairings, the Algebraic Security Core of BLS Signatures, and Short Aggregation

## Abstract

We present a self-contained algebraic account of pairing-based BLS signatures over an elliptic-curve torsion subgroup. A Weil pairing is specified by biadditivity into a commutative multiplicative group, alternation, target torsion, and left and right nondegeneracy. From these assumptions we derive identity laws, scalar bilinearity, full bilinearity, and skew-symmetry. After fixing a generator against which pairing is injective, we define BLS key generation, signing in the hash-to-curve abstraction, and verification. We prove correctness and the stronger statement that, under an honestly generated key, verification accepts exactly the honest signature. We then isolate the deterministic algebraic core of the existential-unforgeability reduction: when a fresh message is programmed to a computational Diffie–Hellman challenge point, every valid forgery is precisely the Diffie–Hellman target. Consequently, if that target is outside a specified class of attainable outputs, no attainable fresh-message forgery exists. Finally, we define finite signature aggregation by elliptic-curve addition and prove both the product verification law and constant group-element representation. Algorithms, examples, applications, limitations, and directions toward a quantitative random-oracle treatment are included.

## 1. Introduction

Digital signatures normally attach one authenticator to one message. In systems with many signers or many events, this creates a communication burden: a certificate, consensus vote, or audit log may carry a list whose length grows linearly with participation. Pairing-based signatures offer an unusual alternative. Individual signatures are points in an elliptic-curve subgroup, and any finite collection can be added into one point. A bilinear pairing then checks this aggregate against a product of individual public-key terms.

Three mathematical ideas drive the construction. First, elliptic-curve points form an additive abelian group. Second, a Weil pairing transports addition in either argument to multiplication in a target group. Third, an injectivity condition ensures that equality after pairing against a fixed generator implies equality of the original points. The same mechanism establishes honest verification, extracts a computational Diffie–Hellman solution from a fresh-message forgery, and verifies a sum of signatures.

The purpose of this paper is to state that core with explicit assumptions and no hidden probabilistic claims. The security result is conditional: computational Diffie–Hellman hardness is represented by exclusion of the target from a chosen class of attainable outputs. The random-oracle programming event is also explicit. Thus the conclusions distinguish algebraic facts from computational assumptions.

Section 2 introduces elliptic-curve torsion and the pairing axioms. Section 3 derives the pairing laws. Section 4 defines BLS signatures and proves correctness and uniqueness. Section 5 gives the fresh-message reduction to computational Diffie–Hellman. Section 6 establishes aggregation and constant group-element size. Sections 7–10 discuss algorithms, numerical illustrations, applications, limitations, and future work.

## 2. Algebraic setting

### 2.1 Elliptic-curve torsion

Let $F$ be a field and let $E$ be a nonsingular elliptic curve over $F$. Its rational points, together with the point at infinity, form an abelian group written additively. The identity is $0$, addition is written $P+Q$, and repeated addition by a nonnegative integer $a$ is written $aP$.

Fix a positive integer $n$. The **$n$-torsion subgroup** is

$$
E[n]=\{P\in E:nP=0\}.
$$

This set is closed under the group operations. Indeed, if $nP=0$ and $nQ=0$, then

$$
n(P+Q)=nP+nQ=0,
$$

and

$$
n(-P)=-(nP)=0.
$$

Hence $E[n]$ is an additive subgroup. All curve points below lie in this subgroup.

### 2.2 Pairing axioms

Let $\mu$ be a commutative multiplicative group with identity $1$. A **Weil pairing interface of level $n$** is a map

$$
e:E[n]\times E[n]\to\mu
$$

satisfying the following conditions for all $P,Q,R\in E[n]$.

1. **Additivity in the first argument:**
   $$
   e(P+Q,R)=e(P,R)e(Q,R).
   $$
2. **Additivity in the second argument:**
   $$
   e(P,Q+R)=e(P,Q)e(P,R).
   $$
3. **Alternation:**
   $$
   e(P,P)=1.
   $$
4. **Image torsion:**
   $$
   e(P,Q)^n=1.
   $$
5. **Left nondegeneracy:** if $e(P,Q)=1$ for every $Q\in E[n]$, then $P=0$.
6. **Right nondegeneracy:** if $e(P,Q)=1$ for every $P\in E[n]$, then $Q=0$.

The terminology “interface” emphasizes that subsequent results require only these laws. A concrete construction may realize $e$ through divisors, Miller functions, and a final exponentiation, but those details are independent of the algebraic arguments developed here.

### 2.3 Cryptographic parameters

Fix a point $G\in E[n]$. For signature verification we assume that

$$
\phi_G:E[n]\to\mu,\qquad \phi_G(P)=e(P,G),
$$

is injective on the subgroup used by the protocol. Thus

$$
e(P,G)=e(Q,G)\quad\Longrightarrow\quad P=Q.
$$

This condition is stronger in form than bare nondegeneracy against all possible second inputs. In a suitable prime-order cyclic setting it can often be derived from nondegeneracy and $G\ne0$, but here it is kept explicit.

## 3. Structural laws of the pairing

We first collect the consequences of the pairing axioms used later.

### Lemma 1: Pairing with zero

For every $P,Q\in E[n]$,

$$
e(0,Q)=1,\qquad e(P,0)=1.
$$

**Proof sketch.** Additivity gives $e(0,Q)=e(0+0,Q)=e(0,Q)^2$. Cancellation in the target group yields $e(0,Q)=1$. The second identity follows symmetrically. Equivalently, each partial map is a group homomorphism and therefore preserves the identity. $\square$

### Theorem 2: Scalar bilinearity

For all nonnegative integers $a,b$ and all $P,Q\in E[n]$,

$$
e(aP,Q)=e(P,Q)^a
$$

and

$$
e(P,bQ)=e(P,Q)^b.
$$

**Proof sketch.** Induct on $a$. The base case is Lemma 1. For the successor step,

$$
\begin{aligned}
e((a+1)P,Q)
&=e(aP+P,Q)\\
&=e(aP,Q)e(P,Q)\\
&=e(P,Q)^a e(P,Q)\\
&=e(P,Q)^{a+1}.
\end{aligned}
$$

The second identity follows by the same induction in the second argument. $\square$

### Corollary 3: Full bilinearity

For all nonnegative integers $a,b$ and all $P,Q\in E[n]$,

$$
e(aP,bQ)=e(P,Q)^{ab}.
$$

**Proof sketch.** Apply scalar bilinearity first in one argument and then the other:

$$
e(aP,bQ)=e(P,bQ)^a=(e(P,Q)^b)^a=e(P,Q)^{ab}.
$$

$\square$

### Theorem 4: Skew-symmetry

For every $P,Q\in E[n]$,

$$
e(P,Q)=e(Q,P)^{-1}.
$$

**Proof sketch.** Alternation gives $e(P+Q,P+Q)=1$. Expanding by additivity in both arguments yields

$$
1=e(P,P)e(P,Q)e(Q,P)e(Q,Q).
$$

Both diagonal terms equal $1$, so $e(P,Q)e(Q,P)=1$, which is equivalent to the claimed inverse relation. $\square$

The image-torsion assumption ensures every output lies among the $n$th roots of unity in $\mu$. Nondegeneracy ensures that the map retains information. Neither property is needed for every elementary identity, but both belong to the standard structural description and become important when selecting cryptographic subgroups.

## 4. BLS signatures in the hash-to-curve abstraction

Let the public parameters be $(E[n],\mu,e,G)$ with $\phi_G$ injective. Let $\mathcal M$ be a message space, and let

$$
H:\mathcal M\to E[n]
$$

be a hash-to-curve map. The abstract treatment assumes only its codomain; cryptographic implementations additionally require domain separation, a specified encoding, subgroup membership, and random-oracle-style behavior.

### 4.1 Algorithms

**Key generation.** Choose a secret scalar $x$ and publish

$$
X=xG.
$$

**Signing.** For a message $m$, compute $H(m)$ and return

$$
\sigma=xH(m).
$$

**Verification.** Given $(X,m,\sigma)$, accept exactly when

$$
e(\sigma,G)=e(H(m),X).
$$

### Theorem 5: BLS correctness

Every honestly generated signature verifies. More precisely, for every secret scalar $x$ and every message $m$, if $X=xG$ and $\sigma=xH(m)$, then

$$
e(\sigma,G)=e(H(m),X).
$$

**Proof sketch.** Scalar bilinearity gives

$$
e(xH(m),G)=e(H(m),G)^x=e(H(m),xG).
$$

The leftmost term is the verification left side and the rightmost term is the verification right side. $\square$

### Theorem 6: Exact characterization of accepted signatures

Fix an honestly generated public key $X=xG$. For every message $m$ and candidate signature $\tau\in E[n]$,

$$
e(\tau,G)=e(H(m),X)
\quad\Longleftrightarrow\quad
\tau=xH(m).
$$

**Proof sketch.** If $\tau=xH(m)$, Theorem 5 proves verification. Conversely, suppose $\tau$ verifies. Theorem 5 also gives

$$
e(xH(m),G)=e(H(m),X).
$$

Thus $e(\tau,G)=e(xH(m),G)$. Injectivity of $\phi_G$ implies $\tau=xH(m)$. $\square$

This theorem is stronger than correctness. It rules out a distinct curve point that happens to satisfy the same verification equation, under the explicit injectivity assumption.

## 5. The algebraic EUF-CMA-to-CDH reduction

### 5.1 Computational Diffie–Hellman challenge

In additive notation, a computational Diffie–Hellman challenge consists of points

$$
A=xG\qquad\text{and}\qquad B\in E[n],
$$

where $x$ is the secret scalar associated with $A$. The target is

$$
T=xB.
$$

The computational Diffie–Hellman assumption states, relative to a specified computational model and distribution, that producing $T$ from public challenge data is infeasible.

For a purely algebraic statement, let $\mathcal A\subseteq E[n]$ denote a class of outputs attainable by a given adversarial procedure. We say that the challenge is **CDH-hard for $\mathcal A$** when

$$
T\notin\mathcal A.
$$

This formulation exposes rather than hides the computational premise.

### 5.2 Fresh-message programming event

Let $m^\star$ be a target message, and let $Q$ be the finite set of messages queried previously. The event required by the reduction has two parts:

$$
m^\star\notin Q
$$

and

$$
H(m^\star)=B.
$$

The first is freshness. The second is random-oracle programming at the fresh point. Because the target was not queried earlier, the reduction can consistently associate it with the CDH challenge point in the standard idealized model.

### Theorem 7: A valid fresh-message forgery solves CDH

Assume $A=xG$, $H(m^\star)=B$, and that a candidate $\sigma^\star$ is valid for public key $A$ and target message $m^\star$. Then

$$
\sigma^\star=xB=T.
$$

**Proof sketch.** Validity gives

$$
e(\sigma^\star,G)=e(H(m^\star),A).
$$

Substitute the programmed hash and public key:

$$
e(\sigma^\star,G)=e(B,xG)=e(xB,G).
$$

Injectivity of pairing against $G$ yields $\sigma^\star=xB$. Equivalently, Theorem 6 applied to secret $x$ and hash point $B$ identifies the only accepted signature. $\square$

### Theorem 8: Conditional existential unforgeability

Let $\mathcal A\subseteq E[n]$ be the class of outputs attainable by an adversary. Under the fresh-message programming event, if the CDH target $T=xB$ is not in $\mathcal A$, then there exists no $\sigma^\star\in\mathcal A$ that verifies for public key $A=xG$ and target message $m^\star$.

**Proof sketch.** Suppose such an attainable valid signature existed. Theorem 7 would imply $\sigma^\star=T$. Since $\sigma^\star\in\mathcal A$, this would put $T$ in $\mathcal A$, contradicting CDH hardness for that class. $\square$

The theorem captures the deterministic extraction step of an existential-unforgeability-under-chosen-message-attack reduction. It does not by itself quantify the probability that a simulator guesses which hash query to program, nor does it specify a runtime model. Those are separate probabilistic layers. What is established here is exact: conditioned on freshness and correct programming, a valid forgery is the CDH target, not merely a related value.

## 6. Finite aggregation

Let $I$ be a finite index set. For each $i\in I$, let $\sigma_i\in E[n]$ be a signature. Define the aggregate signature by

$$
\Sigma_I=\sum_{i\in I}\sigma_i.
$$

Because $E[n]$ is a subgroup, $\Sigma_I$ is again one point of $E[n]$.

### Theorem 9: Pairing law for an aggregate

For every finite $I$ and every family $(\sigma_i)_{i\in I}$,

$$
e(\Sigma_I,G)=\prod_{i\in I}e(\sigma_i,G).
$$

**Proof sketch.** Induct on the finite set $I$. For $I=\varnothing$, the aggregate is $0$, so the left side is $e(0,G)=1$, equal to the empty product. For an insertion $I'=I\cup\{j\}$ with $j\notin I$,

$$
\begin{aligned}
e(\Sigma_{I'},G)
&=e(\sigma_j+\Sigma_I,G)\\
&=e(\sigma_j,G)e(\Sigma_I,G)\\
&=e(\sigma_j,G)\prod_{i\in I}e(\sigma_i,G).
\end{aligned}
$$

This is the required product over $I'$. $\square$

### Theorem 10: Aggregate verification

For each $i\in I$, let $x_i$ be a secret scalar, let $X_i=x_iG$ be its public key, let $H_i\in E[n]$ be a message hash point, and let $\sigma_i=x_iH_i$. Then the aggregate $\Sigma_I=\sum_{i\in I}\sigma_i$ satisfies

$$
e(\Sigma_I,G)=\prod_{i\in I}e(H_i,X_i).
$$

**Proof sketch.** Theorem 9 gives

$$
e(\Sigma_I,G)=\prod_{i\in I}e(\sigma_i,G).
$$

Apply individual correctness to every factor: $e(\sigma_i,G)=e(H_i,X_i)$. Replacing equal factors in the finite product proves the result. $\square$

### Corollary 11: Constant group-element representation

Every finite family of signatures has an aggregate represented by exactly one element of the original subgroup $E[n]$, and this element retains the full product verification law of Theorem 9. Consequently, if subgroup elements have a fixed-size encoding, aggregate-signature communication is one fixed-size encoding, independent of $|I|$.

**Proof sketch.** Choose $\Sigma_I=\sum_{i\in I}\sigma_i$. By closure, $\Sigma_I\in E[n]$; Theorem 9 supplies the verification identity. The statement concerns signature representation, not total verifier input or computational cost: public keys, messages, or hash points may still scale with $|I|$. $\square$

## 7. Algorithms and complexity

### 7.1 Individual signing and verification

Signing performs one hash-to-curve operation and one scalar multiplication. Verification evaluates two pairings and compares target-group elements, though practical libraries may combine the terms in a multi-pairing computation.

**Pseudocode.**

```text
SIGN(x, m):
    Hm <- HASH_TO_CURVE(m)
    return SCALAR_MULTIPLY(x, Hm)

VERIFY(X, m, sigma):
    Hm <- HASH_TO_CURVE(m)
    return PAIR(sigma, G) = PAIR(Hm, X)
```

If scalar multiplication costs $S$ and one pairing evaluation costs $P$, signing costs one hash-to-curve plus $S$, while the direct verification equation costs one hash-to-curve plus approximately $2P$.

### 7.2 Aggregation and aggregate verification

Aggregation adds $k$ signatures. A straightforward summation needs $k-1$ curve additions for $k>0$ and stores one resulting point.

```text
AGGREGATE(sigma[1..k]):
    Sigma <- 0
    for i from 1 to k:
        Sigma <- Sigma + sigma[i]
    return Sigma

AGGREGATE_VERIFY(Sigma, H[1..k], X[1..k]):
    left <- PAIR(Sigma, G)
    right <- 1
    for i from 1 to k:
        right <- right * PAIR(H[i], X[i])
    return left = right
```

The elementary version performs $k$ curve additions, one left pairing, $k$ right pairings, and $k$ target multiplications. Thus arithmetic work is linear in $k$, while the aggregate itself remains one group element. Multi-pairing implementations can share work, but no specific optimized cost is required for the algebraic theorem.

## 8. Numerical exponent model

A compact model illustrates every identity without implementing an actual elliptic curve. Let $r$ be prime, represent the additive source group by $\mathbb Z/r\mathbb Z$, and choose an element $g$ of multiplicative order $r$ modulo a prime $p$ with $r\mid p-1$. Define

$$
e(P,Q)=g^{PQ}\pmod p.
$$

Then

$$
e(P+P',Q)=g^{(P+P')Q}=g^{PQ}g^{P'Q}=e(P,Q)e(P',Q),
$$

and similarly in the second argument. Scalar bilinearity becomes

$$
e(aP,bQ)=g^{abPQ}=e(P,Q)^{ab}.
$$

For example, take $r=11$, $p=23$, and $g=2$, which has order $11$ modulo $23$. Let $G=1$, secret $x=7$, and hash point $H=4$. Then $X=7$ and $\sigma=7\cdot4\equiv6\pmod{11}$. Verification compares

$$
e(6,1)=2^6\pmod{23}
$$

with

$$
e(4,7)=2^{28}\equiv2^6\pmod{23},
$$

so both sides agree.

For two signatures, take $(x_1,H_1)=(3,5)$ and $(x_2,H_2)=(8,7)$. Their signature exponents are $4$ and $1$ modulo $11$, hence the aggregate exponent is $5$. The aggregate pairing exponent is $5$, while the product of individual verification terms has exponent $3\cdot5+8\cdot7=71\equiv5\pmod{11}$. This mirrors the general aggregate theorem.

The model is pedagogical, not a secure deployment. It exposes exponents directly and omits elliptic-curve encodings, subgroup checks, Miller loops, and security parameters.

## 9. Protocol interpretation and edge cases

The finite-family statements include useful boundary cases. For an empty signer set, the aggregate is the curve identity $0$ and the target-side product is the multiplicative identity $1$; the aggregate law becomes $e(0,G)=1$. For a singleton family, aggregation returns the original signature and aggregate verification reduces to ordinary verification. These cases ensure that an implementation can use one fold operation without special mathematical exceptions.

The uniqueness theorem also clarifies malformed-candidate handling at the algebraic level. Once all inputs are known to lie in the selected subgroup and the public key is honestly generated, there is exactly one accepted source point for a fixed message. This does not eliminate the need to reject invalid encodings or points outside the subgroup before evaluating the equation. Rather, subgroup validation establishes the domain on which the uniqueness theorem applies.

Aggregation can be interpreted as a homomorphism from finite signature families under concatenation to the source group under addition. Pairing against $G$ then maps this additive summary into a multiplicative summary. If $S$ and $T$ are disjoint signer sets, their aggregates satisfy

$$
\Sigma_{S\cup T}=\Sigma_S+\Sigma_T
$$

and consequently

$$
e(\Sigma_{S\cup T},G)=e(\Sigma_S,G)e(\Sigma_T,G).
$$

This compositionality supports hierarchical collection: local aggregators may combine signatures independently, after which their partial aggregates can themselves be added. The final point is the same as if every signature had been summed centrally. No ordering is required because the source group is abelian.

Communication and computation should remain separate in performance claims. If one encoded source point uses $s$ bytes, then $k$ individual signatures require $ks$ bytes while their aggregate requires $s$ bytes. On the other hand, the elementary product verification equation contains $k$ right-hand factors. The theorem therefore proves constant signature representation and linear elementary verification work, not constant total protocol size or constant-time verification.

## 10. Applications, assumptions, and limitations

Aggregate signatures are useful whenever many parties attest to related data and bandwidth is scarce. Candidate settings include consensus certificates, distributed key infrastructures, software transparency logs, and networks of constrained devices. The constant-size claim applies specifically to the aggregate signature point. A verifier may still need the participating public keys, the messages or their hashes, and membership information.

The security theorem assumes a fresh target message and an explicitly programmed hash value. A complete random-oracle reduction must account for the probability of selecting the relevant query and for all abort events. The theorem also assumes injectivity of $P\mapsto e(P,G)$ on the operational subgroup. Concrete systems must justify this from subgroup structure and parameter selection.

Naive aggregation is vulnerable to rogue-key strategies if malicious participants may choose public keys as functions of honest keys. Proof-of-possession registration, distinct-message variants, or augmented hashing can address this issue, but aggregate correctness alone does not establish rogue-key-resistant unforgeability.

Finally, concrete pairings require careful construction. The characteristic of the base field, embedding degree, torsion structure, cofactor clearing, serialization, and final exponentiation all affect correctness and security. The abstract laws provide a clean boundary: any concrete realization satisfying them inherits the theorems above.

## 11. Discussion and future work

The development reveals one algebraic invariant behind three different claims. Honest verification follows because scalar multiplication may move from one pairing input to an exponent and then to the other input. Forgery extraction follows because injectivity turns equality of pairing values into equality of curve points. Aggregation follows because addition of source points becomes multiplication of target values.

Several extensions would connect this algebraic core more tightly to deployed systems. A divisor-theoretic Miller-function construction would instantiate the pairing for concrete nonsingular curves over finite fields. A prime-order criterion could derive generator-pairing injectivity from nondegeneracy and $G\ne0$. A probabilistic analysis could show an explicit success bound in terms of the number of hash queries. Proof-of-possession could support rogue-key-resistant aggregation. Finally, a Miller-loop cost model could quantify the advantage of shared final exponentiation in multi-pairing verification.

## 12. Conclusion

On an elliptic-curve torsion subgroup, an alternating, nondegenerate biadditive pairing satisfies scalar bilinearity and skew-symmetry. With a generator that induces an injective pairing map, BLS verification is correct and accepts exactly the honest signature. Under fresh-message oracle programming, every valid forgery equals the computational Diffie–Hellman target; excluding that target from attainable outputs therefore excludes existential forgery. Any finite signature family aggregates by curve addition into one subgroup element, and its pairing equals the product of the individual verification terms. These statements separate algebraic certainty from computational assumptions while explaining, in a single framework, why BLS signatures verify, why fresh-message forgery yields a hard-problem solution, and why many signatures can travel as one point.
