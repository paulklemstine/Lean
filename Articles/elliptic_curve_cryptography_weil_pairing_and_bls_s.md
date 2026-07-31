# One Point, Many Voices: Pairings and the Mathematics of Short Signatures

A city may need to authenticate a million sensor reports before breakfast. A distributed ledger may need hundreds of validators to approve the same block. A software archive may need to preserve decades of endorsements without allowing its certificate files to grow without bound. In each case, the engineering question hides a mathematical one: can many independent statements of trust be compressed without destroying the ability to check them?

Pairing-based cryptography answers yes. Its central mechanism is a map that takes two points from an elliptic-curve group and produces an element of a multiplicative group. The map is not merely a hash or a change of notation. It transports addition into multiplication so rigidly that a secret multiplication performed on one input can be recognized from public data on the other. That bridge supports BLS signatures: short signatures whose sums remain verifiable as a whole.

This article develops the complete algebraic story. It defines the relevant curve subgroup and pairing, derives the pairing laws, explains signature correctness and uniqueness, isolates the computational Diffie–Hellman assumption behind unforgeability, and proves why any finite family of signatures can be represented by a single curve point.

## The stage: torsion points on an elliptic curve

An elliptic curve over a field carries an abelian group law. Its points can be added, there is an identity point $0$, and every point has an inverse. Repeated addition is written $aP$, where $a$ is a nonnegative integer and $P$ is a point.

Fix a positive integer $n$. The $n$-torsion subgroup is

$$
E[n]=\{P\in E:nP=0\}.
$$

It really is a subgroup: $n(P+Q)=nP+nQ$, and $n(-P)=-(nP)$. Thus sums and inverses of $n$-torsion points remain in $E[n]$. Cryptographic constructions normally work in a carefully selected finite, often prime-order, subgroup of this kind.

Now let $\mu$ be a commutative multiplicative group. A Weil pairing for this discussion is a map

$$
e:E[n]\times E[n]\longrightarrow \mu
$$

with four structural properties.

First, it is additive-to-multiplicative in each input:

$$
e(P+Q,R)=e(P,R)e(Q,R),\qquad
e(P,Q+R)=e(P,Q)e(P,R).
$$

Second, it is alternating:

$$
e(P,P)=1.
$$

Third, every value is $n$-torsion in the target:

$$
e(P,Q)^n=1.
$$

Finally, it is nondegenerate on both sides: if $e(P,Q)=1$ for every $Q$, then $P=0$, and if $e(P,Q)=1$ for every $P$, then $Q=0$. Nondegeneracy says the pairing does not erase a nonzero input in every comparison.

These axioms pack remarkable leverage. Pairing with the identity gives $e(0,Q)=e(P,0)=1$. Repeatedly applying the addition laws yields bilinearity:

$$
e(aP,Q)=e(P,Q)^a,\qquad e(P,bQ)=e(P,Q)^b,
$$

and therefore

$$
e(aP,bQ)=e(P,Q)^{ab}.
$$

The proof is simple induction, but the consequence is profound: the product $ab$, hidden in the curve point $abP$, becomes visible as an exponent in the target group.

Alternation adds another symmetry. Since $e(P+Q,P+Q)=1$, expanding both inputs gives

$$
e(P,Q)e(Q,P)=1,
$$

so

$$
e(P,Q)=e(Q,P)^{-1}.
$$

This skew-symmetry is not an extra assumption; it follows from alternation and the two addition laws.

## Turning bilinearity into a signature

Choose a public generator $G\in E[n]$. We require one additional operational condition: the map

$$
P\longmapsto e(P,G)
$$

must be injective on the subgroup in use. In other words, two curve points that pair identically with $G$ must be equal. This is the exact condition that makes the verification equation identify one signature rather than merely a class of indistinguishable points.

A secret key is a scalar $x$, and the public key is

$$
X=xG.
$$

A hash-to-curve procedure sends a message $m$ to a point $H(m)\in E[n]$. The signature is

$$
\sigma=xH(m).
$$

Verification checks the pairing equation

$$
e(\sigma,G)=e(H(m),X).
$$

Why does an honest signature pass? Bilinearity makes both sides equal to the same target-group element:

$$
e(xH(m),G)=e(H(m),G)^x=e(H(m),xG).
$$

This equality is the heartbeat of BLS.

There is also a stronger uniqueness theorem. For an honest public key $X=xG$, a candidate $\tau$ verifies for $m$ if and only if

$$
\tau=xH(m).
$$

The forward direction uses injectivity: verification says that $e(\tau,G)$ equals $e(xH(m),G)$, so $\tau=xH(m)$. The reverse direction is ordinary correctness. Thus verification does not merely accept the intended signature; under the stated injectivity condition, it accepts exactly that curve point.

## Where security enters

Algebra proves correctness, but security is computational. The relevant hard problem is computational Diffie–Hellman in additive notation. Given

$$
A=xG\qquad\text{and}\qquad B,
$$

the challenge is to compute

$$
xB.
$$

The public point $A$ reveals the action of the secret $x$ on $G$; the challenge asks for its action on an independently supplied point $B$.

To connect a signature forgery to this problem, consider a fresh target message $m^\star$: it was not among the messages for which the adversary previously requested signatures. In the random-oracle model, the reduction programs its hash value as

$$
H(m^\star)=B
$$

and uses $A=xG$ as the public key. If an adversary produces a valid signature $\sigma^\star$ on $m^\star$, verification gives

$$
e(\sigma^\star,G)=e(B,A)=e(B,xG)=e(xB,G).
$$

Injectivity of pairing against $G$ forces

$$
\sigma^\star=xB.
$$

The forgery is therefore exactly the Diffie–Hellman solution.

This yields the algebraic unforgeability consequence. Suppose a stated class of adversarially attainable outputs does not contain the target $xB$—the explicit computational Diffie–Hellman hardness assumption for that class. Then no attainable output can be a valid signature for the fresh programmed message. Otherwise the reduction above would identify that output with $xB$, contradicting the assumption.

The qualification matters. This argument isolates the deterministic core of a standard security reduction: freshness, oracle programming, validation, and extraction of the hard-problem solution. A complete quantitative treatment also measures probabilities, query counts, and the reduction’s loss. The algebra tells us exactly what any successful fresh-message forgery must be.

## Many signatures collapse into one

The most visually striking property appears when signatures are aggregated. Let a finite collection of signers have secrets $x_i$, public keys $X_i=x_iG$, message hash points $H_i$, and signatures

$$
\sigma_i=x_iH_i.
$$

Define their aggregate by curve addition:

$$
\Sigma=\sum_i\sigma_i.
$$

Because $E[n]$ is a group, $\Sigma$ is still one element of the same subgroup. It does not become a tuple or a growing list. Bilinearity gives

$$
e(\Sigma,G)
=e\!\left(\sum_i\sigma_i,G\right)
=\prod_i e(\sigma_i,G)
=\prod_i e(H_i,X_i).
$$

This is the Aggregate Verification Theorem. The left side contains one transmitted curve point, while the right side checks the contribution of every signer and message. The theorem applies to any finite index set, including the empty family, for which the sum is $0$ and the product is $1$.

The compression is algebraic, not conventional. If a curve point has a fixed-size encoding, then the aggregate signature has that same fixed group-element size regardless of how many signatures were added. Verification work still depends on the number of signers—the product on the right must be assembled—but communication of the signature itself stays constant.

A small exponent model makes the mechanism easy to see. Imagine representing a curve point by a scalar modulo a prime $r$, and let $g$ generate a multiplicative group of order $r$. Define

$$
e(P,Q)=g^{PQ}.
$$

Then $e(aP,bQ)=g^{abPQ}=e(P,Q)^{ab}$. A signature has exponent $xH$, and the verification exponents are $xH$ on both sides. Aggregating signatures adds their exponents, while multiplying pairing values also adds exponents modulo $r$. Real elliptic-curve pairings are richer and require careful encoding and subgroup checks, but this toy model exposes the exact identities being used.

## A compression law with practical consequences

Why does saving group elements matter? In a consensus network, a block may be endorsed by hundreds or thousands of participants. Sending each signature separately makes the certificate grow with the committee. An aggregate changes the signature portion of that certificate from a list into one curve point. In a sensor network, the same principle allows an upstream collector to combine attestations before forwarding them across a narrow radio link. In a transparency system, it can compactly record that many witnesses observed the same event.

The gain is specifically in representation. Suppose one encoded subgroup point occupies $s$ bytes. Then $k$ separate signatures occupy $ks$ bytes, whereas their aggregate occupies $s$ bytes. The theorem does not make the identities of the signers disappear, nor does it make every verification operation constant-time. A verifier still needs enough information to reconstruct the right-hand product $\prod_i e(H_i,X_i)$. What disappears is the linear list of signature points.

This distinction is healthy: mathematics tells us exactly which resource is compressed. The aggregate is a sufficient algebraic representative for the pairing equation, because the pairing of a sum remembers the product of all the individual pairing values. It is not a general-purpose compression of messages, keys, or participant metadata.

## What the theorem does—and does not—promise

Short aggregation is powerful, but it is not a license to ignore protocol design. If signers may choose public keys maliciously, a rogue-key attack can let one key cancel another. Practical multi-signer systems therefore use proof of possession or other defenses. Messages must be mapped securely into the intended subgroup, inputs must be validated, domains must be separated, and secret scalars must be generated safely. None of these engineering obligations is replaced by bilinearity.

Within its assumptions, however, the mathematical pipeline is crisp. The pairing turns addition into multiplication. That identity proves signature correctness. Injectivity turns a valid equation into uniqueness. Fresh-message programming turns a forgery into $xB$, the computational Diffie–Hellman target. Finally, the same addition law turns a sum of signatures into a product of verification terms.

The result is a rare cryptographic design in which the reason for correctness, the core of the security reduction, and the source of compression are all manifestations of one equation. Many voices add on the curve; one point carries their combined statement; and the pairing lets everyone hear the individual harmonies inside it.
