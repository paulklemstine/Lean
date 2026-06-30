# Bilinear Pairings, BLS Signatures, and the Quantifier Boundary of Nondegeneracy

**Author:** Aristotle
**Date:** 2026-06-30

## Abstract

Bilinear pairings are the algebraic foundation of some of the most compact constructions in public-key cryptography: signatures consisting of a single group element, aggregate signatures whose size is independent of the number of signers, and the Menezes–Okamoto–Vanstone (MOV) reduction translating elliptic-curve discrete logarithms into finite-field discrete logarithms. We develop the theory of pairings from a minimal axiomatic core — biadditivity into a multiplicative target group — and show that this single property suffices to derive (i) completeness of the Boneh–Lynn–Shacham (BLS) signature scheme, (ii) completeness and compression of aggregate BLS, and (iii) the MOV reduction with an *exact* faithfulness statement. Adding a single nondegeneracy hypothesis yields the binding/uniqueness property and, with it, a tight and fully deterministic reduction showing that existential forgery of BLS is equivalent to solving Computational Diffie–Hellman (CDH). We then construct a concrete, fully provable instance of the abstract interface: the determinant form $e((a,b),(c,d)) = \zeta^{\,ad-bc}$ on the rank-two torsion module $(\mathbb{Z}/n\mathbb{Z})^2$, the coordinate model of the Weil pairing, and prove it is alternating and nondegenerate. Finally we isolate a structural boundary: nondegeneracy *as a bilinear form* (quantified over all partners) and nondegeneracy *against a fixed generator* (quantified over one partner) are governed by different quantifiers, and the alternating law preserves the first while destroying the second. This gives a one-line algebraic obstruction explaining why a symmetric single-group pairing cannot supply the binding hypothesis used in BLS unforgeability, formally motivating the use of asymmetric pairings.

## 1. Introduction

A *bilinear pairing* is a map $e : G \times G \to T$ from an additive abelian group $G$ to a multiplicative abelian group $T$ that is additive in each argument. The canonical instances are the Weil and Tate pairings on the torsion subgroup of an elliptic curve, mapping into the group of roots of unity of a finite field. The construction of these pairings is analytically substantial, but — and this is the organizing observation of the present paper — the cryptographic protocols that *consume* pairings never use anything beyond bilinearity and, for soundness, nondegeneracy.

We therefore separate the algebra from the analysis. We axiomatize the pairing by its characteristic property and derive every downstream cryptographic guarantee from it, then exhibit a concrete instance proving the axioms (including nondegeneracy) are non-vacuous. The contributions are:

1. **A minimal pairing interface** and the complete bilinear calculus it generates (Section 3).
2. **BLS completeness and aggregate compression** from biadditivity alone (Section 4).
3. **The MOV reduction** with an exact faithfulness statement: discrete-log values are pinned modulo the target order (Section 5).
4. **Binding and a tight CDH reduction** for existential unforgeability (Section 6).
5. **A concrete nondegenerate alternating pairing**, the determinant form on $(\mathbb{Z}/n\mathbb{Z})^2$ (Section 7).
6. **The quantifier boundary**: an algebraic impossibility result for symmetric single-group binding (Section 8).

The development is deliberately modular. The protocol layer (Sections 4–5) consumes only the additivity axioms; the soundness layer (Section 6) adds a single nondegeneracy hypothesis; and the concrete realization (Section 7) discharges that hypothesis for an explicit pairing. This stratification mirrors how pairing-based cryptography is used in practice: implementers fix a curve and a pairing once, and every protocol thereafter manipulates only the algebraic interface. By proving the protocol guarantees at the level of the interface, we make them simultaneously valid for *every* instance satisfying the axioms — the Weil pairing, the Tate pairing, optimal Ate pairings, and the toy determinant model alike — and we localize the curve-specific content to a single nondegeneracy fact.

A further benefit of the axiomatic treatment is that it exposes exactly which hypotheses each guarantee requires. Completeness and aggregation need only biadditivity; the MOV reduction needs biadditivity plus the order of one target element; binding and unforgeability need biadditivity plus nondegeneracy against the fixed generator. Tracking these dependencies is what makes the impossibility result of Section 8 visible: the unforgeability layer depends on a *fixed-generator* form of nondegeneracy that the alternating Weil pairing, although nondegenerate as a form, cannot supply on a single group.

## 2. Preliminaries and notation

Throughout, $G$ is an additive abelian group (the elliptic-curve point group, written additively, with secret keys acting by $\mathbb{Z}$- or $\mathbb{N}$-scalar multiplication $x \cdot g$), and $T$ is a multiplicative abelian group (the group $\mu_r$ of $r$-th roots of unity in a finite field, written multiplicatively). We write $1$ for the identity of $T$ and $0$ for the identity of $G$.

## 3. The pairing interface and its bilinear calculus

**Definition 3.1 (Pairing).** A *pairing* from $G$ to $T$ is a map $e : G \times G \to T$ satisfying, for all $a,b,p,q \in G$,
$$e(a+b,\,q) = e(a,q)\,e(b,q), \qquad e(p,\,a+b) = e(p,a)\,e(p,b).$$

From these two axioms the entire bilinear calculus follows.

**Lemma 3.2 (Degenerate identities).** $e(0, q) = 1$ and $e(p, 0) = 1$ for all $p,q$.

*Proof.* Setting $a = b = 0$ in the first axiom gives $e(0,q) = e(0,q)\,e(0,q)$; since $T$ is a group, cancellation yields $e(0,q)=1$. The second identity is symmetric. ∎

(Note that a commutative *monoid* target is insufficient: the step $e(0,q) = e(0,q)^2 \Rightarrow e(0,q)=1$ requires cancellation, hence a group.)

**Lemma 3.3 (Scalar laws).** For all $n \in \mathbb{N}$, $p,q\in G$,
$$e(n\cdot p,\,q) = e(p,q)^n, \qquad e(p,\,n\cdot q) = e(p,q)^n,$$
and consequently $e(a\cdot p,\,b\cdot q) = e(p,q)^{ab}$.

*Proof.* Induction on $n$: the base case is Lemma 3.2, the inductive step is the additivity axiom together with $e(p,q)^{k+1} = e(p,q)^k\,e(p,q)$. The bilinear form combines the two single-slot laws and $\,x^a)^b = x^{ab}$. ∎

**Lemma 3.4 (Inverse and $\mathbb{Z}$-grading).** If $G$ is a group then $e(-p,\,q) = e(p,q)^{-1}$, and for all $n\in\mathbb{Z}$, $e(n\cdot p,\,q) = e(p,q)^{n}$.

*Proof.* From $e(p,q)\,e(-p,q) = e(p + (-p),\,q) = e(0,q) = 1$ we get $e(-p,q) = e(p,q)^{-1}$. The $\mathbb{Z}$-graded law splits $n$ into a natural number or its negation and reduces to Lemma 3.3. ∎

**Lemma 3.5 (Sum–product law).** For a finite index set $s$ and $f : s \to G$,
$$e\!\left(\sum_{i\in s} f(i),\; q\right) = \prod_{i\in s} e(f(i),\,q).$$

*Proof.* Induction over the finite set: the empty case is Lemma 3.2, the insertion step is the additivity axiom. ∎

Lemma 3.5 is the engine of aggregate-signature compression (Section 4).

## 4. BLS signatures: completeness and aggregation

**Scheme.** Public parameters fix a generator $g \in G$. A signer holds secret key $x \in \mathbb{N}$ and publishes public key $X = x\cdot g$. To sign a message whose hash-to-curve value is $H \in G$, the signer outputs the single group element $\sigma = x\cdot H$. A verifier with $(g,X,H,\sigma)$ accepts iff $e(\sigma, g) = e(H, X)$.

**Theorem 4.1 (Completeness).** For all $g, H \in G$ and $x \in \mathbb{N}$,
$$e(x\cdot H,\; g) = e(H,\; x\cdot g).$$

*Proof.* By Lemma 3.3, both sides equal $e(H,g)^x$. ∎

**Theorem 4.2 (Aggregate completeness / compression).** For a finite signer set $s$, generator $g$, message hashes $H_i$, and secrets $x_i$,
$$e\!\left(\sum_{i\in s} x_i\cdot H_i,\; g\right) = \prod_{i\in s} e(H_i,\; x_i\cdot g).$$

*Proof.* Apply the sum–product law (Lemma 3.5) to move the sum out of the left slot, then apply Theorem 4.1 factor-by-factor. ∎

The verified object on the left is a *single* group element $\sigma_{\text{agg}} = \sum_i \sigma_i$, whose size is independent of $|s|$. This is the precise sense in which pairings yield *short* aggregate signatures.

**Theorem 4.3 (Batch verification).** If $e(\sigma_i, g) = e(H_i, X_i)$ for each $i\in s$, then $\prod_{i\in s} e(\sigma_i, g) = \prod_{i\in s} e(H_i, X_i)$.

*Proof.* Immediate from factorwise equality of products. ∎

## 5. The MOV reduction: ECDLP into target-group DLP

The Menezes–Okamoto–Vanstone reduction transports the elliptic-curve discrete logarithm problem (ECDLP) in $G$ into the discrete logarithm problem (DLP) in $T$.

**Theorem 5.1 (MOV map).** $e(x\cdot g,\; g) = e(g,g)^x$. ∎ (Lemma 3.3.)

**Theorem 5.2 (Faithfulness).** For $a, b \in \mathbb{N}$,
$$e(a\cdot g,\; g) = e(b\cdot g,\; g) \iff a \equiv b \pmod{\operatorname{ord}(e(g,g))}.$$

*Proof.* Both sides of the left equation are powers of $e(g,g)$; equality of powers of a group element is equivalent to congruence of exponents modulo its order. ∎

**Corollary 5.3 (Exact recovery).** If $\operatorname{ord}(e(g,g)) \ge n$ and $0 \le a, b < n$, then $e(a\cdot g, g) = e(b\cdot g, g)$ implies $a = b$.

*Proof.* The congruence of Theorem 5.2 together with $a,b$ both below the modulus forces $a = b$. ∎

Corollary 5.3 is the rigorous statement of why curves with small embedding degree are cryptographically broken: a DLP solver in $T$ base $e(g,g)$ returns the secret modulo $\operatorname{ord}(e(g,g))$, which equals the secret outright once that order dominates the order of $g$.

## 6. Binding and existential unforgeability under CDH

The soundness of BLS rests on one further hypothesis.

**Definition 6.1 (Left nondegeneracy against $g$).** The pairing is *nondegenerate against the generator $g$* if the only $a\in G$ with $e(a, g) = 1$ is $a = 0$.

**Theorem 6.2 (Binding / signature uniqueness).** Under Definition 6.1, the verification equation $e(\sigma, g) = e(H,\, x\cdot g)$ has the unique solution $\sigma = x\cdot H$.

*Proof.* Rewriting the right side via Lemma 3.3 gives $e(\sigma, g) = e(x\cdot H,\, g)$, hence $e(\sigma - x\cdot H,\, g) = 1$ by Lemma 3.4. Nondegeneracy forces $\sigma - x\cdot H = 0$. ∎

**Definition 6.3 (CDH solution).** Given $g$ and $A = a\cdot g$, $B = b\cdot g$, a *CDH solution* is $S = (a b)\cdot g$.

**Theorem 6.4 (A forgery is a CDH solution).** Suppose the hash is programmed to $H = c\cdot g$ and the key is $X = x\cdot g$. Any $\sigma$ passing $e(\sigma, g) = e(c\cdot g,\, x\cdot g)$ satisfies $\sigma = (x c)\cdot g$.

*Proof.* Theorem 6.2 gives $\sigma = x\cdot(c\cdot g)$, and $x\cdot(c\cdot g) = (xc)\cdot g$. ∎

**Theorem 6.5 (Black-box reduction).** Let $\mathrm{adv} : G\times G \to G$ be any adversary that on input $(A, B)$ outputs a value passing $e(\mathrm{adv}(A,B),\, g) = e(B, A)$. Then for every instance $(g,\, a\cdot g,\, b\cdot g)$, the output $\mathrm{adv}(a\cdot g, b\cdot g)$ is a correct CDH solution.

*Proof.* Specialize Theorem 6.4. ∎

**Theorem 6.6 (Existential unforgeability under CDH).** If CDH is hard at $(g, a\cdot g, b\cdot g)$ in the sense that no group element equals the DH value, then no $\sigma$ satisfies $e(\sigma, g) = e(b\cdot g,\, a\cdot g)$.

*Proof.* The contrapositive of Theorem 6.4: a winning $\sigma$ would be the DH value, contradicting hardness. ∎

The reduction is *deterministic and tight*: the forger's output is not merely correlated with the CDH answer, it is literally equal to it. The only assumption beyond biadditivity is nondegeneracy against the fixed generator. Notably, this is the *minimal* form of nondegeneracy — its scope is exactly one partner, $g$ — and Section 8 shows this scope is the source of a subtle but decisive obstruction.

## 7. A concrete nondegenerate alternating pairing

To show the interface and its nondegeneracy hypothesis are non-vacuous, we exhibit an explicit instance: the coordinate model of the Weil pairing on the $n$-torsion of an elliptic curve, where $E[n] \cong (\mathbb{Z}/n\mathbb{Z})^2$.

**Definition 7.1 (Determinant form).** On $\mathrm{Tor}(n) := (\mathbb{Z}/n\mathbb{Z})^2$, set
$$\operatorname{wdet}\big((a,b),(c,d)\big) = ad - bc \in \mathbb{Z}/n\mathbb{Z}.$$
The pairing into $T = \text{Multiplicative}(\mathbb{Z}/n\mathbb{Z}) \cong \mu_n$ is $e(p,q) = \zeta^{\,\operatorname{wdet}(p,q)}$, where $\zeta$ generates $T$ and corresponds to the additive element $1$.

**Proposition 7.2 (Bilinearity).** $e$ is a pairing.

*Proof.* The determinant is additive in each argument: $\operatorname{wdet}(a+b, q) = \operatorname{wdet}(a,q) + \operatorname{wdet}(b,q)$ by distributivity, and likewise in the second slot; the exponential turns these sums into products. ∎

**Proposition 7.3 (Alternating).** $e(p, p) = 1$ for all $p$.

*Proof.* $\operatorname{wdet}((a,b),(a,b)) = ab - ba = 0$, so $e(p,p) = \zeta^0 = 1$. ∎

Consequently (by the antisymmetry of any alternating pairing) $e(q,p) = e(p,q)^{-1}$: expanding $1 = e(p+q,\,p+q)$ by bilinearity and cancelling the two self-pairings gives $e(p,q)\,e(q,p) = 1$.

**Theorem 7.4 (Full nondegeneracy).** If $e(p, q) = 1$ for *every* $q$, then $p = 0$.

*Proof.* Write $p = (a,b)$. Pairing against $(0,1)$ gives $\operatorname{wdet}(p,(0,1)) = a = 0$; pairing against $(1,0)$ gives $\operatorname{wdet}(p,(1,0)) = -b = 0$. Hence both coordinates vanish, so $p = 0$. The right-slot version is symmetric. ∎

**Proposition 7.5 (Image generator).** $e((1,0),(0,1)) = \zeta^{1}$, an element of additive order $n$; thus the pairing surjects onto $\mu_n$.

By Theorem 7.4 and the abstract binding lemma, the concrete pairing *separates points*: if $e(p_1, q) = e(p_2, q)$ for all $q$, then $p_1 = p_2$. This is the unconditional form of the binding property that makes verification meaningful, and it turns every conditional result of Sections 4–6 into an unconditional statement about an explicit pairing.

## 8. The quantifier boundary

We now isolate the structural phenomenon that organizes the whole development.

**Theorem 8.1 (Fixed-slot degeneracy of an alternating pairing).** Let $e$ be alternating on a group $G$, and let $g \ne 0$. Then there exists a nonzero $a$ with $e(a, g) = 1$ — namely $a = g$ itself, since $e(g,g) = 1$.

*Proof.* Immediate from the alternating law. ∎

**Corollary 8.2 (Symmetric single-group binding is impossible).** No alternating pairing on a single group is nondegenerate against any fixed nonzero generator (Definition 6.1). Consequently the binding hypothesis used in the BLS unforgeability reduction (Section 6) cannot be supplied by a symmetric, single-group, alternating pairing.

This is the crux. Two notions that share the name *nondegeneracy* are governed by different quantifiers:

- **As a form** (Theorem 7.4): *for all* partners $q$, $e(p,q)=1$ implies $p = 0$. This holds for the Weil pairing.
- **Against a fixed generator** (Definition 6.1): *for one* partner $g$, $e(a,g) = 1$ implies $a = 0$. This *fails* for any alternating pairing, with $a = g$ as an explicit witness.

The alternating law $e(g,g)=1$ is itself a certificate of degeneracy against $g$: the generator collides with the very element it is meant to pin down. The failure is not incidental but forced by the algebra. The practical consequence is that secure deployments require an *asymmetric* (type-3) pairing $e : G_1 \times G_2 \to T$ with independent groups, or equivalently two independent generators, so that the fixed-slot partner is never the element being constrained. What is usually stated as engineering folklore is thus revealed as a one-line algebraic theorem.

## 9. A worked numerical example

To make the abstract development concrete, we exhibit a fully explicit computation in the determinant model with $n = 23$ and generator $g = (1,0)$, target $T = \mu_{23}$ written additively as exponents of $\zeta$ modulo $23$.

*Signing and verification.* Let the secret key be $x = 9$, so the public key is $X = 9\cdot(1,0) = (9,0)$. Let the message hash to $H = (5,8)$. The signature is the single point
$$\sigma = 9\cdot(5,8) = (45 \bmod 23,\; 72 \bmod 23) = (22, 3).$$
Verification computes $e(\sigma, g) = \operatorname{wdet}((22,3),(1,0)) = 22\cdot 0 - 3\cdot 1 = -3 \equiv 20$ and $e(H, X) = \operatorname{wdet}((5,8),(9,0)) = 5\cdot 0 - 8\cdot 9 = -72 \equiv 20 \pmod{23}$. The two exponents agree, so verification accepts, exactly as Theorem 4.1 predicts. Tampering with $\sigma$ in the second coordinate, say $\sigma' = (22,4)$, gives $e(\sigma',g) = -4 \equiv 19 \ne 20$, and verification rejects.

*Aggregation.* With $n = 29$, generator $g=(1,0)$, four signers with secrets $(4,11,7,24)$ and hashes $((2,3),(5,1),(8,6),(9,9))$, the individual signatures are $4\cdot(2,3)=(8,12)$, $11\cdot(5,1)=(26,11)$, $7\cdot(8,6)=(27,13)$, $24\cdot(9,9)=(13,13)$. Their sum is the single aggregate point $(8+26+27+13,\;12+11+13+13) = (74,49) \equiv (16,20) \pmod{29}$. Its pairing against $g$ is $e((16,20),(1,0)) = -20 \equiv 9$, while the product of per-signer pairings $\prod_i e(H_i, X_i)$ has exponent $\sum_i (-H_{i,2}\,x_i) = -(3\cdot4 + 1\cdot11 + 6\cdot7 + 9\cdot24) = -281 \equiv 9 \pmod{29}$. The aggregate of four signatures verifies as a single group element, illustrating Theorem 4.2.

*The rogue-key attack.* With $n=31$, honest key $X_1 = 13\cdot(1,0) = (13,0)$, shared hash $H = (6,5)$, and adversarial choice $w = 20$, the rogue key is $X_2 = 20\cdot(1,0) - (13,0) = (7,0)$. The combined key telescopes to $X_1 + X_2 = (20,0) = 20\cdot g$, and the forged contribution $\sigma = 20\cdot(6,5) = (120,100) \equiv (27,7)$ satisfies $e(\sigma,g) = -7 \equiv 24$ and $e(H, X_1+X_2) = \operatorname{wdet}((6,5),(20,0)) = -100 \equiv 24 \pmod{31}$. The forgery passes with no knowledge of the honest secret, confirming the necessity of distinct messages.

*The quantifier boundary.* With $n=13$, an exhaustive check confirms that the only point pairing trivially against all of $(\mathbb{Z}/13\mathbb{Z})^2$ is $(0,0)$ — full nondegeneracy. Yet for the nonzero point $g=(3,7)$ we have $e(g,g) = 3\cdot7 - 7\cdot3 = 0$, so $g$ is a nonzero self-collision: the pairing is degenerate against the fixed generator $g$, exactly as Theorem 8.1 asserts.

## 10. Algorithms

The constructions above are directly computable on the determinant model. We highlight three algorithms (with full implementations in the accompanying demonstration code):

1. **Pairing evaluation** on $(\mathbb{Z}/n\mathbb{Z})^2$: compute $ad - bc \bmod n$, returning the exponent of $\zeta$. Complexity $O(1)$ ring operations.
2. **BLS sign / verify / aggregate**: signing is one scalar multiplication; verification is two pairing evaluations and an equality test; aggregation is a group sum followed by a product of per-signer pairings. Aggregate verification is $O(k)$ pairing evaluations for $k$ signers, but transmits one group element.
3. **MOV recovery**: given $e(x\cdot g, g)$, solve the target-group DLP base $e(g,g)$ to recover $x$ modulo $\operatorname{ord}(e(g,g))$; exact when that order dominates $\operatorname{ord}(g)$.

## 11. Applications

- **Short signatures.** A signature is one group element; verification is publicly checkable from group elements alone, the feature that distinguishes pairing-based signatures from ECDSA and enables aggregation.
- **Aggregate and multi-signatures.** Theorem 4.2 compresses any number of distinct-message signatures into one fixed-size object — used to shrink blockchain blocks and certificate chains.
- **Cryptanalysis (MOV).** Section 5 is a bridge result equating ECDLP hardness with finite-field DLP hardness, and the explicit criterion (small embedding degree breaks the curve) for parameter selection.
- **Security guidance.** Corollary 8.2 gives a precise, provable reason to prefer asymmetric pairings, and the rogue-key analysis (below) pins down the safe aggregation regime.

**Rogue-key attack (security boundary).** Naive *same-message* aggregation is insecure: against an honest key $X_1$, an adversary registers the rogue key $X_2 = (w\cdot g) - X_1$ (no honest secret needed) and outputs $\sigma = w\cdot H$. Then $X_1 + X_2 = w\cdot g$ telescopes and $e(\sigma, g) = e(H,\, X_1+X_2)$ verifies. The defense is to forbid the telescoping by enforcing **distinct messages** (equivalently, keeping per-signer pairing factors separate): then aggregate agreement is equivalent to all individual agreements, with no way to compensate one forged factor with another.

## 12. Discussion and future work

The development cleanly separates the *protocol layer* (which needs only bilinearity) from the *soundness layer* (which needs nondegeneracy) and the *concrete model* (which proves both are realizable). The recurring structural lesson is the quantifier boundary of Section 8: nondegeneracy as a form and nondegeneracy against a fixed generator are not the same property, and the alternating law separates them.

Three directions stand out.

**A symmetric pairing on one group cannot bind a fixed key.** Conjecture: for *every* alternating pairing on a single finite abelian group into a cyclic target, every nonzero generator admits a nonzero trivially-pairing partner; hence no signature scheme whose binding rests on a single fixed generator is secure under a symmetric pairing. The insight is that $e(g,g)=1$ is itself the degeneracy witness — the failure is forced, not incidental. This sharpens deployed folklore into an impossibility statement.

**The determinant form is the only nondegenerate alternating pairing.** Conjecture: on $(\mathbb{Z}/n\mathbb{Z})^2$, every nondegenerate alternating pairing into $\mu_n$ equals the determinant pairing precomposed with a single automorphism of the source, for a unique primitive root $\zeta$; equivalently, the space of such pairings is a torsor under the source automorphisms. The insight is that alternation plus nondegeneracy pins the Gram matrix to the standard symplectic form up to change of basis. This settles whether distinct curve models yield genuinely inequivalent pairings or mere reparametrizations.

**Full-order self-pairing characterizes the broken curves.** Conjecture: for a non-alternating pairing on a prime-order group, the discrete logarithm transports faithfully into the target — recovering the secret exactly — if and only if the self-pairing of the generator has order equal to the group size; over a prime field this holds for every nonzero generator. This is the quantitative refinement of the MOV faithfulness statement of Section 5.

## 13. Conclusion

From a single axiom — biadditivity into a multiplicative group — we obtained the complete bilinear calculus, BLS completeness, aggregate compression, the MOV reduction with exact faithfulness, and a tight deterministic reduction of forgery to CDH. A concrete determinant pairing on $(\mathbb{Z}/n\mathbb{Z})^2$ realizes the interface and proves its nondegeneracy hypothesis. Most importantly, the quantifier boundary between two senses of nondegeneracy — preserved and destroyed, respectively, by the alternating law — gives a one-line algebraic explanation of why secure pairing-based signatures must be asymmetric. The same determinant that measures the area of a parallelogram draws the line between secure and broken cryptography.
