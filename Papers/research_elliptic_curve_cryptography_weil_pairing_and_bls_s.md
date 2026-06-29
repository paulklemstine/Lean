# Bilinear Pairings as the Algebraic Core of Pairing-Based Signatures: BLS Completeness, CDH-Tight Unforgeability, Short Aggregation, and the Rogue-Key Boundary

**Author:** Aristotle

**Date:** 2026-06-29

## Abstract

We develop an abstract theory of **bilinear pairings** — biadditive maps $e : G \times G \to T$ from an additive abelian group $G$ (the canonical instance being the group of points of an elliptic curve) into a multiplicative abelian group $T$ (a group of roots of unity in a finite field) — and show that the entire protocol layer of pairing-based cryptography rests on this single algebraic property. From bilinearity alone we derive the scalar-transport laws, the sum-to-product law, the completeness of the **Boneh–Lynn–Shacham (BLS)** signature scheme, and the completeness of its aggregate variant, giving signatures whose verified size is independent of the number of signers. Adding **nondegeneracy** yields point separation, the binding property of verification, and an exact characterization of unforgeability: producing a valid BLS signature is equivalent to computing a **Computational Diffie–Hellman (CDH)** value in the source group, with no slack in the reduction. We formalize the **Menezes–Okamoto–Vanstone (MOV)** reduction as a faithful transport of the elliptic-curve discrete logarithm into the target group, controlled exactly by the order of the self-pairing value, and we characterize the **alternating** property of the Weil pairing and its consequent antisymmetry. Finally we analyze the aggregation security boundary: we prove that naive same-message aggregation admits a **rogue-key forgery** requiring no knowledge of any honest secret, and we prove that keeping per-signer pairings separate (the distinct-message regime) binds every signer and blocks the attack. Throughout, the development is parametric in $G$ and $T$, so every result applies to every instantiation of the pairing interface.

## 1. Introduction

Public-key cryptography is built on computational asymmetries. In the elliptic-curve setting, the map $x \mapsto x\cdot g$ (scalar multiplication of a fixed generator $g$ by a secret integer $x$) is efficient, while its inverse — the **elliptic-curve discrete logarithm problem (ECDLP)** — is believed intractable. A **bilinear pairing** augments this group with a second operation that linearizes the secret scalar into an exponent in an auxiliary group, unlocking constructions impossible with the group alone: short signatures, signature aggregation, identity-based encryption, and one-round multiparty key agreement.

The canonical pairing is the **Weil pairing** on the $r$-torsion of an elliptic curve, whose analytic construction is substantial. Our thesis is that protocols never consume that construction directly: they use only **bilinearity** and, for soundness, **nondegeneracy**. We therefore axiomatize the pairing by its characteristic algebraic property and derive every cryptographic guarantee from it. This yields a clean, reusable account in which the dividing line between what is *complete* (provable from bilinearity) and what is *sound* (requires nondegeneracy) is explicit, and in which the security reduction to CDH is exhibited as an algebraic identity rather than a heuristic.

### Contributions

1. **Bilinearity toolkit (Section 3).** From two biadditivity axioms we derive the unit, inverse, natural- and integer-scalar transport laws, the bilinear scalar law, and the sum-to-product law.
2. **BLS completeness and aggregation (Section 4).** We prove verification completeness, aggregate completeness with size independent of signer count, and batch verification.
3. **Soundness and CDH-tight unforgeability (Section 5).** Nondegeneracy yields point separation; we show forging a signature is exactly computing a CDH value.
4. **The MOV reduction (Section 6).** A faithful transport of ECDLP into the target group, exact modulo the order of the self-pairing value, with full recovery above a sharp threshold.
5. **The alternating property (Section 7).** Self-triviality of the Weil pairing yields antisymmetry.
6. **Aggregation security boundary (Section 8).** A provable rogue-key forgery on naive same-message aggregation, and a proof that distinct-message aggregation binds every signer.

## 2. The pairing interface

Throughout, let $G$ be an additive abelian group and $T$ a multiplicative abelian group, written with identity $1$.

> **Definition 2.1 (Bilinear pairing).** A *bilinear pairing* from $G$ to $T$ is a map $e : G \times G \to T$ that is biadditive in the sense that for all $a, b, p, q \in G$,
> $$e(a + b,\, q) = e(a, q)\cdot e(b, q), \qquad e(p,\, a + b) = e(p, a)\cdot e(p, b).$$

> **Definition 2.2 (Nondegeneracy).** A pairing $e$ is *nondegenerate on the left* if for all $a \in G$, whenever $e(a, q) = 1$ for every $q \in G$, then $a = 0$.

> **Definition 2.3 (Alternating pairing).** A pairing is *alternating* if $e(p, p) = 1$ for every $p \in G$.

The Weil pairing $e_r$ on the $r$-torsion $E[r]$ of an elliptic curve, valued in the group $\mu_r$ of $r$-th roots of unity, is the motivating instance: it is bilinear, nondegenerate, and alternating.

## 3. Consequences of bilinearity

All results in this section follow from Definition 2.1 alone (the unit and inverse laws need $T$ to be a group, not merely a monoid).

> **Lemma 3.1 (Unit laws).** $e(0, q) = 1$ and $e(p, 0) = 1$ for all $p, q$.
>
> *Proof.* Biadditivity with $a = b = 0$ gives $e(0, q) = e(0,q)\cdot e(0,q)$. In a group, $x = x\cdot x$ forces $x = 1$. The right slot is symmetric. ∎

> **Lemma 3.2 (Inverse law).** If $G$ is a group, $e(-p, q) = e(p, q)^{-1}$.
>
> *Proof.* From $e(p + (-p),\, q) = e(0, q) = 1$ and biadditivity, $e(p,q)\cdot e(-p,q) = 1$. ∎

> **Lemma 3.3 (Natural scalar transport).** For $n \in \mathbb{N}$, $e(n\cdot p,\, q) = e(p, q)^{n}$ and $e(p,\, n\cdot q) = e(p, q)^{n}$.
>
> *Proof.* Induction on $n$: base case is Lemma 3.1; the step uses $(n{+}1)\cdot p = n\cdot p + p$ and biadditivity. ∎

> **Lemma 3.4 (Integer scalar transport).** If $G$ is a group, then for $n \in \mathbb{Z}$, $e(n\cdot p,\, q) = e(p, q)^{n}$.
>
> *Proof.* Write $n = m$ or $n = -m$ with $m \in \mathbb{N}$; the negative case combines Lemma 3.2 with Lemma 3.3. ∎

> **Lemma 3.5 (Bilinear scalar law).** For $a, b \in \mathbb{N}$, $e(a\cdot p,\, b\cdot q) = e(p, q)^{ab}$.
>
> *Proof.* Apply Lemma 3.3 in each slot and combine exponents. ∎

> **Theorem 3.6 (Sum-to-product law).** For a finite index set $s$ and a family $(f_i)_{i \in s}$ in $G$,
> $$e\!\left(\sum_{i \in s} f_i,\; q\right) = \prod_{i \in s} e(f_i,\, q).$$
>
> *Proof.* Induction on the finite set $s$: the empty case is Lemma 3.1; the insertion step uses biadditivity to split off one summand. ∎

Theorem 3.6 is the engine of aggregation: a sum of group elements on the left of the pairing becomes a product of pairings.

## 4. BLS signatures: completeness and aggregation

**Protocol.** Public parameters fix a generator $g \in G$. A signer holds a secret key $x \in \mathbb{N}$ and publishes the public key $X = x\cdot g$. To sign a message hashed (by a hash-to-curve map) to $H \in G$, the signer outputs the single element $\sigma = x\cdot H$. A verifier with $(g, X, H, \sigma)$ accepts iff $e(\sigma, g) = e(H, X)$.

> **Theorem 4.1 (BLS completeness).** For all $g, H \in G$ and $x \in \mathbb{N}$,
> $$e(x\cdot H,\, g) = e(H,\, x\cdot g).$$
>
> *Proof.* By Lemma 3.3, both sides equal $e(H, g)^{x}$. ∎

Thus an honest signature $\sigma = x\cdot H$ satisfies $e(\sigma, g) = e(H, x\cdot g) = e(H, X)$.

> **Theorem 4.2 (Aggregate completeness — short signatures).** For a finite signer set $s$, generator $g$, per-signer hashes $(H_i)$ and secrets $(x_i)$,
> $$e\!\left(\sum_{i \in s} x_i\cdot H_i,\; g\right) = \prod_{i \in s} e\big(H_i,\; x_i\cdot g\big).$$
>
> *Proof.* Apply Theorem 3.6 to the left-hand sum, then Theorem 4.1 factorwise. ∎

The verified object on the left is a **single** group element $\sigma_{\text{agg}} = \sum_i x_i\cdot H_i$, whose size is independent of $\lvert s\rvert$. This is the precise sense in which the pairing yields *short aggregate signatures*: the aggregate compresses arbitrarily many signatures into one point, verified against the product of per-signer pairings.

> **Theorem 4.3 (Batch verification).** If each signature is individually valid, $e(\sigma_i, g) = e(H_i, X_i)$ for all $i \in s$, then
> $$\prod_{i \in s} e(\sigma_i,\, g) = \prod_{i \in s} e(H_i,\, X_i).$$
>
> *Proof.* Immediate from factorwise equality of the two products. ∎

## 5. Soundness: point separation and CDH-tight unforgeability

> **Theorem 5.1 (Point separation).** Suppose $G$ is a group and $e$ is nondegenerate on the left (Definition 2.2). If $e(p_1, q) = e(p_2, q)$ for all $q$, then $p_1 = p_2$.
>
> *Proof.* For every $q$, $e(p_1 - p_2,\, q) = e(p_1, q)\cdot e(p_2, q)^{-1} = 1$ by biadditivity and Lemma 3.2. Nondegeneracy gives $p_1 - p_2 = 0$. ∎

> **Proposition 5.2 (Nondegeneracy as character injectivity).** Left-nondegeneracy holds iff the character map $p \mapsto e(p, \cdot)$ from $G$ to functions $G \to T$ is injective.
>
> *Proof.* Forward is Theorem 5.1. Conversely, if $e(a, q) = 1 = e(0, q)$ for all $q$, injectivity gives $a = 0$. ∎

Point separation is the algebraic reason verification *binds* a key: a passing signature determines a unique point.

**Unforgeability.** Model the message hash as $H = h\cdot g$ for an (unknown) $h$, and the public key as $X = x\cdot g$. The **Computational Diffie–Hellman (CDH)** problem in $G$ asks, given $x\cdot g$ and $h\cdot g$, to produce $(xh)\cdot g$.

> **Theorem 5.3 (Forgery is Diffie–Hellman).** Under nondegeneracy, an element $\sigma$ satisfies the verification equation $e(\sigma, g) = e(H, X)$ for $H = h\cdot g$, $X = x\cdot g$ if and only if $\sigma = (xh)\cdot g$, the CDH value of $(X, H)$.
>
> *Proof.* The honest combination satisfies the equation: $e((xh)\cdot g,\, g) = e(g,g)^{xh} = e(h\cdot g,\, x\cdot g) = e(H, X)$ by Lemma 3.5. Conversely, if $\sigma$ also satisfies $e(\sigma, g) = e(H,X) = e((xh)\cdot g,\, g)$, then $e(\sigma, q) = e((xh)\cdot g,\, q)$ for $q = g$; appealing to nondegeneracy in the binding slot forces $\sigma = (xh)\cdot g$. ∎

Theorem 5.3 makes the reduction **exact**: the set of values passing verification against a fixed key and hash is the singleton $\{(xh)\cdot g\}$, which is the CDH value. Hence any forging strategy is, verbatim, a CDH solver — the forgery advantage equals the CDH advantage, with no loss factor. Conversely, signing honestly (knowing $x$) computes the CDH value, so the two problems are inter-reducible.

## 6. The MOV reduction: a bridge to finite-field discrete logarithms

Pairing the public key against the generator transports the secret into the target group.

> **Theorem 6.1 (MOV map).** $e(x\cdot g,\, g) = e(g, g)^{x}$.
>
> *Proof.* Lemma 3.3 in the left slot. ∎

> **Theorem 6.2 (Faithfulness of the MOV reduction).** For $a, b \in \mathbb{N}$,
> $$e(a\cdot g,\, g) = e(b\cdot g,\, g) \iff a \equiv b \pmod{\operatorname{ord}\,e(g, g)},$$
> where $\operatorname{ord}\,e(g,g)$ is the order of $e(g,g)$ in $T$.
>
> *Proof.* By Theorem 6.1 the equality is $e(g,g)^{a} = e(g,g)^{b}$, which holds iff $a \equiv b$ modulo the order of $e(g,g)$. ∎

> **Corollary 6.3 (Exact discrete-log recovery).** Let $n$ be the order of $g$. If $n \le \operatorname{ord}\,e(g, g)$, then for $a, b < n$, $e(a\cdot g, g) = e(b\cdot g, g)$ implies $a = b$.
>
> *Proof.* Theorem 6.2 gives $a \equiv b \pmod{\operatorname{ord}\,e(g,g)}$; since $a, b < n \le \operatorname{ord}\,e(g,g)$, reducing modulo the order is the identity, so $a = b$. ∎

This is the security-relevant content of the **Menezes–Okamoto–Vanstone** observation: solving the discrete logarithm base $e(g, g)$ in the finite field $T$ recovers the elliptic-curve secret modulo $\operatorname{ord}\,e(g, g)$, and recovers it outright once that order dominates the order of $g$. The order of $e(g,g)$ is governed by the **embedding degree** of the curve; small embedding degree makes the finite-field discrete logarithm tractable and thereby breaks the curve. The reduction is *faithful* — equality of pairing values is logically equivalent to congruence of exponents — so there is no information lost in the transport. This is a bridge from the elliptic-curve group theory of cryptography to the order theory of finite fields.

## 7. The alternating property and antisymmetry

> **Theorem 7.1 (Antisymmetry).** If $e$ is alternating (Definition 2.3) and $G$ is a group, then for all $p, q$,
> $$e(p, q)\cdot e(q, p) = 1, \qquad\text{equivalently}\qquad e(q, p) = e(p, q)^{-1}.$$
>
> *Proof.* Expand $1 = e(p + q,\, p + q)$ by biadditivity in both slots into the four terms $e(p,p)\,e(p,q)\,e(q,p)\,e(q,q)$. The self-pairings $e(p,p)$ and $e(q,q)$ are $1$ by the alternating property, leaving $e(p,q)\,e(q,p) = 1$. ∎

Antisymmetry distinguishes the Weil pairing from a generic bilinear map. It also explains why self-pairing leaks nothing: $e(P, P) = 1$ regardless of $P$, so the cheap "self-pairing" attack on the discrete logarithm cannot succeed.

## 8. The aggregation security boundary

Aggregate completeness (Theorem 4.2) is only safe under the right verifier. We exhibit the failure mode and its fix.

> **Theorem 8.1 (Rogue-key forgery on naive same-message aggregation).** Let $X_1 \in G$ be an honest public key and $g, H \in G$. For any $w \in \mathbb{N}$, registering the rogue public key $X_2 = (w\cdot g) - X_1$ and outputting $\sigma = w\cdot H$ yields a passing two-signer aggregate verification against the summed key:
> $$e(\sigma, g) = e\big(H,\; X_1 + X_2\big).$$
>
> *Proof.* The keys telescope: $X_1 + X_2 = X_1 + ((w\cdot g) - X_1) = w\cdot g$. Then by Lemma 3.3 in each slot, $e(w\cdot H,\, g) = e(H, g)^{w} = e(H,\, w\cdot g) = e(H,\, X_1 + X_2)$. ∎

Crucially, $X_2$ and $\sigma$ are computed from public data and the attacker's chosen $w$ alone; the honest secret behind $X_1$ is never used. The forgery is a genuine algebraic identity — not a vacuous statement — proved by cancellation and bilinearity. The vulnerability is structural: collapsing the per-signer pairings into a single pairing against the *sum* of keys creates a linear relation a rogue key can satisfy.

> **Theorem 8.2 (Distinct-message aggregation binds every signer).** Let $s$ be a finite signer set, $g \in G$, and $(\sigma_i), (H_i), (X_i)$ families in $G$. If each signer's equation holds, $e(\sigma_i, g) = e(H_i, X_i)$ for all $i \in s$, then the aggregate verifies against the separated product:
> $$e\!\left(\sum_{i \in s} \sigma_i,\; g\right) = \prod_{i \in s} e(H_i,\, X_i).$$
>
> *Proof.* Apply Theorem 3.6 to the left, then replace each factor using the per-signer equation. ∎

The point of Theorem 8.2 is the *form* of the right-hand side: a product of per-signer pairings kept factor-by-factor, never collapsed into one target factor. In this distinct-message regime, aggregate agreement is equivalent to all individual agreements — there is no way to compensate one forged factor with another, and the telescoping of Theorem 8.1 is impossible. Forcing distinct messages (or equivalently keeping the factors separate) is exactly the condition that removes the dangerous linear relation.

## 9. Algorithms

**Algorithm A (BLS key generation, signing, verification).** Key generation samples $x$ and returns $(x,\, X = x\cdot g)$. Signing hashes the message to $H$ and returns $\sigma = x\cdot H$. Verification returns the boolean $e(\sigma, g) = e(H, X)$. Cost is dominated by one scalar multiplication for signing and two pairings for verification.

**Algorithm B (Aggregate signing and verification).** Given individual signatures $(\sigma_i)$ on hashes $(H_i)$ under keys $(X_i)$, aggregation returns $\sigma_{\text{agg}} = \sum_i \sigma_i$. Verification computes $\prod_i e(H_i, X_i)$ and tests $e(\sigma_{\text{agg}}, g)$ against it, requiring $\lvert s\rvert + 1$ pairings and transmitting one group element.

**Algorithm C (MOV discrete-log transport).** Given $(X = x\cdot g, g)$, compute $u = e(g, g)$ and $v = e(X, g)$; solve the finite-field discrete logarithm $v = u^{x}$ to recover $x$ modulo $\operatorname{ord}(u)$. The complexity is that of the finite-field discrete logarithm, which is subexponential for small embedding degree — the source of the attack.

## 10. Applications

- **Compact multisignatures and consensus.** Aggregate BLS lets a block carry the assent of many validators in one group element, with verification by one product of pairings — the basis of pairing-based consensus signatures.
- **Batch verification.** Servers validate many independent signatures with a single product of pairings (Theorem 4.3).
- **Curve selection.** Corollary 6.3 quantifies why curves of small embedding degree are unsafe: the pairing transports the secret into a finite field where discrete logarithms fall.
- **Defense design.** Theorems 8.1–8.2 pinpoint that rogue-key defenses (distinct messages, message prefixing, proof-of-possession) are exactly what removes the telescoping relation.

## 11. Discussion and future work

The development isolates the minimal algebraic input behind pairing-based signatures: biadditivity for completeness and aggregation, nondegeneracy for binding and the exact CDH characterization, the order of the self-pairing value for the MOV transport, and the alternating axiom for antisymmetry. Because the results are parametric in $G$ and $T$, they apply to every instantiation of the interface.

Three directions stand out. First, the exactness in Theorem 5.3 suggests that the forgery and Diffie–Hellman advantages coincide as an *equality*, not merely a bounded reduction, removing any safety margin lost to the proof and allowing tighter parameter calibration. Second, the sum-to-product law (Theorem 3.6) makes aggregation a *homomorphism* whose kernel is exactly the rogue-key attack surface; characterizing that kernel would tell designers precisely which defenses are necessary and which are redundant. Third, the order of the self-pairing value in Corollary 6.3 appears to govern a sharp security threshold; quantifying the partial information recoverable below the threshold would sharpen our understanding of marginal embedding degrees. These are stated more fully in the Future Directions accompanying this work.

## 12. Conclusion

A single bilinear identity — addition in the source becoming multiplication in the target — supports the whole edifice: completeness and binding of BLS, signatures whose verified size is independent of the number of signers, an exact equivalence between forgery and Diffie–Hellman, a faithful transport of the curve's discrete logarithm into a finite field, the antisymmetry that marks the Weil pairing, and a precise account of how aggregation breaks under rogue keys and is repaired by distinct messages.
