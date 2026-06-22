# A Formal Treatment of the Schnorr Identification Protocol over a Prime Field

## Abstract

We present a self-contained formal development of the Schnorr identification
protocol, the canonical example of a $\Sigma$-protocol, modeled over the
additive group of a prime field $\mathbb{Z}_p$. We give precise definitions of
the public parameters, key generation, transcripts, and the verifier's
acceptance relation, and we establish the three defining security properties of
an honest-verifier zero-knowledge proof of knowledge. **Completeness** states
that honestly generated transcripts always satisfy the verifier.
**Special soundness** states that any two accepting transcripts sharing a
commitment but using distinct challenges yield an explicit closed-form
extraction of the secret key, $x = (c_1 - c_2)^{-1}(s_1 - s_2)$; this is the
quantitative core of the proof-of-knowledge guarantee and pins the soundness
error at $1/p$. **Perfect honest-verifier zero knowledge (HVZK)** is witnessed
by an explicit bijection between honest randomness/challenge pairs and simulator
response/challenge pairs, under which each honest transcript is *literally
equal* to the corresponding simulated transcript, proving that the honest and
simulated transcript distributions coincide exactly. We discuss the Fiat–Shamir
transformation to a non-interactive signature, the random-oracle model, and a
program of conjectures generalizing these results to $n$-special-soundness,
AND/OR composition, and quantitative knowledge error.

**Keywords.** Schnorr protocol, $\Sigma$-protocol, zero-knowledge proof,
special soundness, witness extraction, honest-verifier zero knowledge,
Fiat–Shamir heuristic, discrete logarithm.

---

## 1. Introduction

A *zero-knowledge proof* allows a prover to convince a verifier that a statement
is true while revealing nothing beyond the validity of the statement itself.
When the statement is "I know a secret witness $x$ for the public value
$\text{pk}$," the protocol is a *proof of knowledge*. The Schnorr
identification protocol (Schnorr, 1989/1991) is the archetypal such protocol and
the template for a vast family of constructions in modern cryptography,
including the widely deployed Schnorr and EdDSA digital signatures.

This paper formalizes the protocol over the additive group of a prime field,
which is the cleanest mathematical skeleton that retains all the algebraic
structure responsible for security. We model the underlying cyclic group
*additively*: a fixed nonzero element $g \in \mathbb{Z}_p$ plays the role of the
group generator, and the "scalar action" of a scalar on a group element is
simply field multiplication. The public key of a secret $x$ is the element
$\text{pk} = x \cdot g$. The substantive security assumption — that recovering
$x$ from $(g, \text{pk})$ is computationally hard — is the discrete logarithm
assumption, which is *external* to the algebraic correctness, completeness,
soundness, and zero-knowledge statements proved here.

### 1.1 Background and context

Interactive proof systems were introduced by Goldwasser, Micali, and Rackoff,
who also defined the zero-knowledge property: the verifier's *view* of the
interaction can be reconstructed ("simulated") without access to the prover's
secret. A $\Sigma$-protocol is a particularly clean three-move instance of this
idea, consisting of a commitment, a public-coin challenge, and a response, and
satisfying three properties — completeness, special soundness, and special (or
honest-verifier) honest zero knowledge. The Schnorr protocol is the prototypical
$\Sigma$-protocol for the relation
$$R = \{(\text{pk}, x) : \text{pk} = x \cdot g\},$$
i.e. "$x$ is the discrete logarithm of $\text{pk}$ to base $g$."

The importance of the Schnorr protocol is twofold. First, it is *practically*
central: applying the Fiat–Shamir transform turns it into the Schnorr signature
scheme, which is the basis of EdDSA (Ed25519) and was adopted into Bitcoin via
the Taproot upgrade in 2021. Second, it is *pedagogically and theoretically*
central: nearly every modern zero-knowledge construction — range proofs,
proofs of correct shuffles, anonymous credentials, and many SNARK building
blocks — descends from the commitment/challenge/response template and the
rewinding-based extraction argument that the Schnorr protocol exhibits in its
purest form.

We stress a separation of concerns maintained throughout this paper. The
statements proved here — completeness, special soundness, and HVZK — are
*unconditional* algebraic facts about the field $\mathbb{Z}_p$; they hold with no
computational assumption whatsoever. What makes the protocol *secure* in
practice is the additional, external assumption that computing $x$ from
$(g, \text{pk})$ is infeasible (the discrete logarithm assumption). Our results
are precisely the components a security reduction combines with that assumption;
they are not themselves conditional on it.

### 1.2 Contributions

1. A precise, parameterized formalization of the Schnorr protocol's syntax:
   public parameters, key generation, honest transcript generation, and the
   acceptance relation (§2).
2. A proof of **completeness** by direct algebraic verification (§3).
3. A proof of **special soundness** that *extracts* the witness in closed form
   from two transcripts, leveraging the field structure of $\mathbb{Z}_p$ — the
   invertibility of a nonzero generator and of nonzero challenge differences
   (§4).
4. A proof of **perfect honest-verifier zero knowledge** via an explicit
   bijection on the randomness spaces, demonstrating equality of the honest and
   simulated transcript distributions (§5).
5. A discussion of the Fiat–Shamir transformation, the random oracle model, and
   five concrete conjectures for future formal work (§§6–7).

---

## 2. Definitions

Throughout, $p$ is a prime and $\mathbb{Z}_p$ denotes the field of integers
modulo $p$. We work additively in the group $(\mathbb{Z}_p, +)$ and use field
multiplication as the scalar action.

### 2.1 Public parameters

> **Definition 2.1 (Public parameters).** A set of Schnorr public parameters
> consists of a prime modulus $p$, a proof that $p$ is prime, a *generator*
> $g \in \mathbb{Z}_p$, and a proof that $g \neq 0$.

The hypothesis $g \neq 0$ is the only structural requirement on the generator
needed for the results below; it guarantees that $g$ is a unit in the field
$\mathbb{Z}_p$ and hence can be cancelled from equations.

### 2.2 Key generation

> **Definition 2.2 (Public key).** For a secret $x \in \mathbb{Z}_p$, the public
> key is
> $$\text{pk}(x) = x \cdot g.$$

### 2.3 Transcripts and acceptance

> **Definition 2.3 (Transcript).** A *transcript* is a triple
> $(t, c, s) \in \mathbb{Z}_p \times \mathbb{Z}_p \times \mathbb{Z}_p$, where
> $t$ is the *commitment*, $c$ the *challenge*, and $s$ the *response*.

> **Definition 2.4 (Acceptance relation).** Against a public value
> $Y \in \mathbb{Z}_p$, the verifier *accepts* a transcript $(t, c, s)$ iff
> $$s \cdot g = t + c \cdot Y.$$

### 2.4 The honest prover and the simulator

> **Definition 2.5 (Honest transcript).** Given a secret $x$, commitment
> randomness $r$, and challenge $c$, the honest transcript is
> $$\textsf{honest}(x, r, c) = (r \cdot g,\; c,\; r + c \cdot x).$$

> **Definition 2.6 (Simulated transcript).** Given $x$ (used only to compute the
> public landmark), a challenge $c$, and a freely chosen response $s$, the
> simulated transcript is
> $$\textsf{sim}(x, c, s) = (s \cdot g - c \cdot \text{pk}(x),\; c,\; s).$$
> By construction the commitment is *solved for* so that the acceptance
> equation holds.

---

## 3. Completeness

> **Theorem 3.1 (`completeness`).** For all $x, r, c \in \mathbb{Z}_p$, the
> honest transcript is accepted against the public key $\text{pk}(x)$:
> $$\textsf{accept}\big(\text{pk}(x),\; \textsf{honest}(x, r, c)\big).$$

**Proof.** Unfold the definitions. The transcript is
$(r g,\, c,\, r + c x)$ and the public key is $x g$. The acceptance equation
requires $(r + c x)\, g = r g + c (x g)$. Expanding the left-hand side,
$$(r + c x)\, g = r g + (c x) g = r g + c (x g),$$
which equals the right-hand side. The identity holds in any commutative ring, so
no use of primality is needed; it is pure distributivity and associativity. $\qquad\blacksquare$

Completeness guarantees *perfect correctness*: there are no false rejections of
honest provers, for any choice of randomness and any challenge.

---

## 4. Special Soundness and Witness Extraction

The defining feature of a proof of *knowledge* is an **extractor**: an algorithm
that, given a prover able to answer multiple challenges on the same commitment,
recovers the witness. For $\Sigma$-protocols this is captured by *special
soundness*.

> **Theorem 4.1 (`special_soundness`).** Let $x \in \mathbb{Z}_p$ and let
> $(t, c_1, s_1)$ and $(t, c_2, s_2)$ be two transcripts sharing the commitment
> $t$, both accepted against $\text{pk}(x)$, with $c_1 \neq c_2$. Then the
> witness is recovered explicitly as
> $$x = (c_1 - c_2)^{-1}\,(s_1 - s_2).$$

**Proof.** Acceptance of the two transcripts gives
$$s_1 g = t + c_1\, (x g), \qquad s_2 g = t + c_2\, (x g).$$
Subtracting eliminates the shared commitment $t$:
$$(s_1 - s_2)\, g = (c_1 - c_2)\,(x g) = \big((c_1 - c_2)\, x\big)\, g.$$
Because $g \neq 0$ in the field $\mathbb{Z}_p$, it is a unit and may be cancelled
on the right (right cancellation by a nonzero element):
$$s_1 - s_2 = (c_1 - c_2)\, x.$$
Because $c_1 \neq c_2$, the difference $c_1 - c_2$ is nonzero, hence invertible
in the field. Multiplying by $(c_1 - c_2)^{-1}$ yields
$$x = (c_1 - c_2)^{-1}\,(s_1 - s_2),$$
as claimed. $\qquad\blacksquare$

**Remark 4.2 (Two field facts, two cancellations).** The proof uses exactly the
two places where the field structure of $\mathbb{Z}_p$ is essential: cancelling
the nonzero generator $g$, and inverting the nonzero challenge gap $c_1 - c_2$.
Both fail over a general ring; both succeed over a field, which is why the prime
modulus is indispensable here even though completeness (Theorem 3.1) is not.

**Corollary 4.3 (Soundness error $1/p$, informal).** A prover who does *not*
know the witness can produce an accepting response for at most one challenge per
commitment: if it could answer two distinct challenges, Theorem 4.1 would
extract the witness, contradicting ignorance. Since the verifier draws the
challenge uniformly from $\mathbb{Z}_p$ (which has $p$ elements), the probability
that a witness-free prover succeeds is at most $1/p$. Formalizing this counting
bound — that the set of answerable challenges for a fixed commitment has
cardinality at most $1$ — is conjecture C4 of §7.

---

## 5. Honest-Verifier Zero Knowledge

We now show the protocol reveals nothing about $x$ to an honest verifier. The
proof strategy is the standard *simulation* paradigm: we exhibit a simulator
that, given only public information, produces transcripts identically
distributed to the honest ones. Equal distribution is the gold standard
(*perfect* HVZK), stronger than statistical or computational indistinguishability.

### 5.1 The randomness translation

The honest transcript is parameterized by a pair $(r, c)$ of commitment
randomness and challenge; the simulated transcript is parameterized by a pair
$(s, c)$ of response and challenge. We relate them by an explicit bijection.

> **Definition 5.1 (Forward map `honestToSim`).**
> $$\Phi_x(r, c) = (r + x \cdot c,\; c).$$

> **Definition 5.2 (Inverse map `simToHonest`).**
> $$\Psi_x(s, c) = (s - x \cdot c,\; c).$$

> **Lemma 5.3 (`honestSimEquiv` is a bijection).** For every $x \in \mathbb{Z}_p$,
> the maps $\Phi_x$ and $\Psi_x$ are mutually inverse, so
> $$\Phi_x : \mathbb{Z}_p \times \mathbb{Z}_p \;\xrightarrow{\;\sim\;}\; \mathbb{Z}_p \times \mathbb{Z}_p$$
> is a bijection.

**Proof.** Both composites are the identity by direct computation: the second
coordinate $c$ is untouched, and in the first coordinate
$\Psi_x(\Phi_x(r,c)) = (r + xc) - xc = r$ and
$\Phi_x(\Psi_x(s,c)) = (s - xc) + xc = s$. $\qquad\blacksquare$

### 5.2 Transcript equality

> **Theorem 5.4 (`hvzk_bijection`).** For all $x, r, c \in \mathbb{Z}_p$, the
> honest transcript on $(r, c)$ equals the simulated transcript on its image
> under the bijection:
> $$\textsf{honest}(x, r, c) = \textsf{sim}\big(x,\; (\Phi_x(r,c))_2,\; (\Phi_x(r,c))_1\big).$$
> Concretely, writing $\Phi_x(r,c) = (s, c)$ with $s = r + xc$, the right-hand
> side is $\textsf{sim}(x, c, s)$.

**Proof.** Compute both sides coordinate by coordinate.

- *Challenge.* Both transcripts carry $c$. Equal.
- *Response.* The honest response is $r + cx$; the simulated response is
  $s = r + xc$. Equal by commutativity.
- *Commitment.* The honest commitment is $r g$. The simulated commitment is
  $$s\,g - c\,\text{pk}(x) = (r + xc)\,g - c(x g) = r g + (xc) g - c (x g) = r g.$$
  Equal.

All three coordinates agree, so the transcripts are identical. $\qquad\blacksquare$

### 5.3 Distributional consequence

> **Corollary 5.5 (Perfect HVZK).** Fix the secret $x$ and a challenge $c$. As
> $r$ ranges uniformly over $\mathbb{Z}_p$, the honest transcripts
> $\textsf{honest}(x, r, c)$ are identically distributed to the simulated
> transcripts $\textsf{sim}(x, c, s)$ as $s$ ranges uniformly over
> $\mathbb{Z}_p$.

**Proof.** By Theorem 5.4 each honest transcript equals a unique simulated
transcript, and by Lemma 5.3 the assignment $(r, c) \mapsto (s, c)$ with
$s = r + xc$ is a bijection of $\mathbb{Z}_p \times \mathbb{Z}_p$ that fixes the
second coordinate. Hence for fixed $c$ the map $r \mapsto s = r + xc$ is a
bijection of $\mathbb{Z}_p$, carrying the uniform distribution on $r$ to the
uniform distribution on $s$. Equal images under equal-probability inputs give
equal output distributions. Since the simulator uses no knowledge of $x$ beyond
the public landmark, the verifier's view leaks nothing about $x$. $\qquad\blacksquare$

---

## 6. From Identification to Signatures: Fiat–Shamir and the Random Oracle Model

The protocol of §§2–5 is *interactive*: it needs a live verifier to supply a
fresh, unpredictable challenge $c$. The **Fiat–Shamir heuristic** removes the
interaction by deriving the challenge from a cryptographic hash function $H$
applied to the public data and the commitment (and, for signatures, the message
$m$):
$$c = H(g,\, \text{pk},\, t,\, m).$$
The prover can now compute the challenge itself, producing a non-interactive
transcript $(t, c, s)$ — a *Schnorr signature*. Verification recomputes $c$ from
the hash and checks $s g = t + c\,\text{pk}$.

In the **random oracle model**, $H$ is idealized as a truly random function that
all parties may query. Two facts make security arguments transfer:

1. **Completeness is unchanged.** The honest signer still satisfies the
   acceptance equation regardless of how $c$ was produced (Theorem 3.1 makes no
   assumption on the origin of $c$).
2. **Extraction survives.** If a forger produces two accepting transcripts with
   the *same* commitment $t$ but *different* oracle challenges $c_1 \neq c_2$ —
   the situation engineered by the *forking lemma*, which reruns the forger with
   a reprogrammed oracle — then Theorem 4.1 extracts the witness via the
   identical formula $x = (c_1 - c_2)^{-1}(s_1 - s_2)$.

Thus the algebraic results proved here are exactly the components a
random-oracle security reduction needs. Conjecture C1 of §7 proposes
formalizing this transfer by parameterizing the verifier over an arbitrary
challenge function and re-deriving extraction from challenge distinctness alone.

---

## 7. Discussion and Future Directions

The development isolates a striking economy: three security guarantees, each a
few lines of field arithmetic. Completeness is ring distributivity; special
soundness is two cancellations in a field; zero knowledge is one bijection. The
prime modulus is needed precisely for the two cancellations in soundness and for
the bijection's invertibility — not for completeness.

We record the following program of conjectures for subsequent formal work.

**C1. Fiat–Shamir collapses interaction without losing extraction.** Model the
non-interactive Schnorr signature by fixing the challenge as an abstract oracle
value $c = H(g, \text{pk}, a)$ for a free function $H$. Then completeness and the
two-transcript special-soundness/extraction theorems carry over verbatim: from
two accepting $(a, H_1, z_1)$, $(a, H_2, z_2)$ with $H_1 \not\equiv H_2 \pmod q$
the same field formula $(z_1 - z_2)(H_1 - H_2)^{-1}$ extracts the witness.
*Test:* parameterize `Verify` over an arbitrary challenge function and re-derive
the extractor with no new hypotheses beyond challenge distinctness.

**C2. $n$-special-soundness for the general linear $\Sigma$-protocol.** For a
witness vector $x \in (\mathbb{Z}_q)^k$ and public key
$\text{pk} = g^{\langle m, x\rangle}$ with public coefficient vector $m$, any
$k+1$ accepting transcripts with an invertible challenge Vandermonde matrix
uniquely determine $x$. *Test:* generalize special soundness from a scalar
challenge $c$ to a family of $k+1$ challenges and reduce extraction to
invertibility of a Vandermonde matrix over $\mathbb{Z}_q$.

**C3. AND/OR composition preserves the $\Sigma$-properties.** The parallel
AND-composition of two Schnorr instances (shared challenge) and the CDS
OR-composition (split challenge $c = c_1 + c_2$) each yield a $\Sigma$-protocol:
completeness and special soundness compose, and HVZK simulators combine. *Test:*
define a composed verifier as the conjunction/disjunction of two verifiers and
prove composed completeness, extraction, and simulator acceptance; the OR case
should use the response bijection to argue the simulated challenge split is
uniform.

**C4. Soundness error equals the inverse field size.** A prover not knowing the
witness can answer at most one challenge per commitment; hence the cheating
success probability over a uniform challenge in $\mathbb{Z}_q$ is exactly $1/q$.
*Test:* formalize "for fixed commitment $a$, at most one $c$ admits an accepting
$z$ unless the prover knows $x$" as a counting statement, bound the accepting
set's cardinality by $1$, and conclude probability $1/q$.

**C5. Extraction $\Leftrightarrow$ challenge-gap invertibility.** Witness
extraction from two transcripts succeeds *iff* $c_1 - c_2$ is a unit in
$\mathbb{Z}_q$. The forward direction is Theorem 4.1; the converse is an
obstruction theorem: if $c_1 \equiv c_2$ (or, over composite-order $g$, the gap
shares a factor), extraction is impossible.

---

## 8. A Fully Worked Numerical Example

To make the abstractions concrete, we trace the protocol over the small prime
$p = 23$ with generator $g = 5$ and secret $x = 9$, giving public key
$\text{pk} = 9 \cdot 5 = 45 \equiv 22 \pmod{23}$.

*Completeness.* The prover draws randomness $r = 7$, sends commitment
$t = 7 \cdot 5 = 35 \equiv 12$. The verifier replies with challenge $c = 4$. The
prover responds $s = r + c x = 7 + 4 \cdot 9 = 43 \equiv 20$. The verifier checks
$s g = 20 \cdot 5 = 100 \equiv 8$ against $t + c\,\text{pk} = 12 + 4 \cdot 22 =
12 + 88 = 100 \equiv 8$. They agree; the transcript $(12, 4, 20)$ is accepted.

*Special soundness.* Suppose the same commitment $t = 12$ is reused with two
challenges $c_1 = 4$ and $c_2 = 10$, yielding responses $s_1 = 20$ and
$s_2 = r + 10 \cdot 9 = 97 \equiv 5$. The extractor computes the gap
$c_1 - c_2 = -6 \equiv 17$, whose inverse modulo $23$ is $19$ (since
$17 \cdot 19 = 323 = 14 \cdot 23 + 1$), and the response gap
$s_1 - s_2 = 15$. Then $x = 19 \cdot 15 = 285 \equiv 9 \pmod{23}$, recovering the
secret exactly.

*Zero knowledge.* The simulator, knowing only $\text{pk} = 22$, picks (say)
$c = 4$ and $s = 20$ and solves $t = s g - c\,\text{pk} = 100 - 88 = 12$,
reproducing precisely the honest transcript $(12, 4, 20)$. The bijection
$r \mapsto s = r + xc$ here is $r \mapsto r + 36 \equiv r + 13 \pmod{23}$, a
shift, hence a bijection of $\mathbb{Z}_{23}$.

---

## 9. Conclusion

We have given a complete and self-contained formal account of the Schnorr
identification protocol over a prime field, establishing its three foundational
properties: perfect completeness, special soundness with explicit witness
extraction (and the resulting $1/p$ knowledge error), and perfect
honest-verifier zero knowledge witnessed by an explicit bijection of randomness
spaces. These results are the algebraic core from which the security of the
non-interactive Schnorr signature follows in the random oracle model via
Fiat–Shamir. The proofs are short, transparent, and modular, and the conjectures
of §7 chart a path toward formalizing the wider landscape of $\Sigma$-protocol
theory — linear generalizations, AND/OR composition, quantitative soundness, and
sharp extraction characterizations.
