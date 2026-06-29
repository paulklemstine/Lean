# A Verified Account of the Schnorr Σ-Protocol: Completeness, Knowledge Soundness, Exact Soundness Error, Perfect HVZK, and Fiat–Shamir

**Author:** Aristotle
**Domain:** Novelty (Cryptography / Zero-Knowledge Proofs)
**Date:** 2026-06-28

## Abstract

We give a complete, self-contained mathematical treatment of the Schnorr
identification protocol — a canonical three-move Σ-protocol — together with its
non-interactive Fiat–Shamir transform. Working over the additive group of a prime
field $\mathbb{Z}/p\mathbb{Z}$, we model the group additively, taking a fixed
nonzero generator $g$ and public keys of the form $Y = x\cdot g$. We establish the
three defining security properties of an identification Σ-protocol and several
refinements. *Completeness*: honest transcripts always verify. *Knowledge
soundness*: from any two accepting transcripts sharing a commitment but with
distinct challenges, an explicit extractor returns a genuine discrete logarithm of
an **arbitrary** public key — strictly generalizing classical special soundness,
which presupposes the public key is well-formed. *Exact soundness error*: for a
fixed commitment, exactly one challenge admits an accepting response, so a cheating
prover succeeds with probability exactly $1/p$. *Perfect honest-verifier zero
knowledge (HVZK)*: an explicit measure-preserving bijection between the honest and
simulated randomness spaces shows that, for **every** event on transcripts, the
honest and simulated transcript distributions assign identical probabilities — the
strongest, exact form of zero knowledge. Finally, we lift each property across the
*Fiat–Shamir transform*, obtaining non-interactive completeness, the
verification-equivalence to the interactive protocol with an oracle-fixed
challenge, forking extraction (the algebraic core of the Forking Lemma), and
uniqueness of accepting responses. All results have been formalized and
machine-checked; this paper presents the underlying mathematics with full proof
sketches.

## 1. Introduction

A *zero-knowledge proof of knowledge* lets a prover convince a verifier that the
prover possesses a secret witness, while revealing nothing beyond the validity of
the claim. The Schnorr identification protocol (Schnorr, 1989/1991) is the
archetype: a three-move *Σ-protocol* whose witness is the discrete logarithm of a
public key. Its non-interactive form, obtained via the Fiat–Shamir transform,
yields the Schnorr signature scheme, which underlies EdDSA and the Bitcoin Taproot
upgrade, among many deployments.

This paper develops the protocol and its security from first principles. Our
contributions, beyond a clean exposition, are several sharpenings of the textbook
account that emerge naturally once one insists on exactness:

- **Knowledge soundness for arbitrary public keys.** The familiar "special
  soundness" lemma assumes the public key already has the form $Y = x\cdot g$ and
  concludes that the extractor recovers *that* $x$. We prove the logically prior
  statement: for an arbitrary group element $Y$ (no secret assumed to exist), the
  extractor's output $x^\star$ satisfies $x^\star\cdot g = Y$. This is the property
  actually demanded by the proof-of-knowledge / Forking-Lemma definitions, and it
  implies the classical lemma as a corollary.

- **Exact soundness error.** We pin the soundness error to *exactly* $1/p$ by a
  counting argument: for a fixed commitment, the set of "winning" challenges is a
  singleton.

- **Perfect HVZK as equality of event probabilities.** We upgrade the pointwise
  identity "the simulator can reproduce each honest transcript" to its statistical
  content "the simulator reproduces each transcript with the same probability,"
  via a measure-preserving bijection. The resulting statement quantifies over
  *every* event, so it bounds the advantage of *every* (even adaptive)
  distinguisher by zero.

- **Fiat–Shamir lifting.** Each property transfers to the non-interactive setting,
  with the random oracle modeled at the syntactic level as a free function.

Throughout, "$\cdot$" denotes scalar multiplication of a scalar by a group
element, which in our additive prime-field model is field multiplication.

## 2. Setup and Definitions

### 2.1 Public parameters

> **Definition 2.1 (Schnorr parameters).** A *Schnorr parameter set* consists of a
> prime $p$, the field $\mathbb{Z}/p\mathbb{Z}$ regarded as the additive group
> $G = (\mathbb{Z}/p\mathbb{Z}, +)$, and a fixed generator $g \in G$ with
> $g \ne 0$.

We model the cyclic group additively. Scalar multiplication of a scalar
$a \in \mathbb{Z}/p\mathbb{Z}$ by the generator is the field product $a\cdot g$.
Because $p$ is prime, $\mathbb{Z}/p\mathbb{Z}$ is a field; in particular every
nonzero scalar is invertible, a fact used decisively in extraction.

> **Definition 2.2 (Public key).** For a secret $x \in \mathbb{Z}/p\mathbb{Z}$,
> the *public key* is $\mathrm{pk}(x) = x\cdot g$.

### 2.2 Transcripts and acceptance

> **Definition 2.3 (Transcript).** A *transcript* is a triple
> $(t, c, s) \in (\mathbb{Z}/p\mathbb{Z})^3$ of *commitment* $t$, *challenge* $c$,
> and *response* $s$.

> **Definition 2.4 (Verifier acceptance).** Against a public key $Y$, the verifier
> *accepts* a transcript $(t, c, s)$ iff
> $$\mathrm{accepts}(Y, (t,c,s)) \iff s\cdot g = t + c\cdot Y.$$

### 2.3 Honest prover and simulator

> **Definition 2.5 (Honest transcript).** With commitment randomness $r$ and
> challenge $c$, the honest prover (knowing $x$) produces
> $$\mathrm{honest}(x, r, c) = (\,r\cdot g,\; c,\; r + c\,x\,).$$

> **Definition 2.6 (Simulator).** With chosen challenge $c$ and response $s$, the
> simulator (knowing no secret) produces
> $$\mathrm{sim}(Y, c, s) = (\,s\cdot g - c\cdot Y,\; c,\; s\,).$$

The simulator runs the verification equation backwards: it picks $(c, s)$ first
and *defines* the commitment so that acceptance holds by construction.

## 3. Completeness

> **Theorem 3.1 (Completeness).** For all $x, r, c$,
> $\mathrm{accepts}(\mathrm{pk}(x), \mathrm{honest}(x, r, c))$ holds.

*Proof.* The honest transcript is $(r\cdot g,\, c,\, r + cx)$ and
$\mathrm{pk}(x) = x\cdot g$. Compute the left side of the verification equation:
$$ (r + cx)\cdot g = r\cdot g + c\,(x\cdot g) = (r\cdot g) + c\cdot \mathrm{pk}(x). $$
This is exactly the right side $t + c\cdot Y$ with $t = r\cdot g$ and
$Y = \mathrm{pk}(x)$. The identity holds in the ring $\mathbb{Z}/p\mathbb{Z}$ by
distributivity and associativity; no genericity or probabilistic slack is needed.
$\qquad\blacksquare$

Honest provers thus pass with certainty (probability $1$), not merely with high
probability.

## 4. Soundness

### 4.1 Extraction and knowledge soundness

> **Definition 4.1 (Extractor).** For two transcripts sharing a commitment, with
> challenges $c_1, c_2$ and responses $s_1, s_2$, define
> $$\mathrm{extract}(c_1, s_1, c_2, s_2) = (c_1 - c_2)^{-1}\,(s_1 - s_2).$$

> **Theorem 4.2 (Knowledge soundness; extractor correctness for arbitrary keys).**
> Let $Y$ be an *arbitrary* element of $\mathbb{Z}/p\mathbb{Z}$. If
> $\mathrm{accepts}(Y, (t, c_1, s_1))$ and $\mathrm{accepts}(Y, (t, c_2, s_2))$
> with $c_1 \ne c_2$, then
> $$\mathrm{extract}(c_1, s_1, c_2, s_2)\cdot g = Y.$$

*Proof sketch.* The two acceptance equations read
$$ s_1\cdot g = t + c_1\cdot Y, \qquad s_2\cdot g = t + c_2\cdot Y. $$
Subtracting eliminates the shared commitment $t$:
$$ (s_1 - s_2)\cdot g = (c_1 - c_2)\cdot Y. $$
Since $c_1 \ne c_2$, the scalar $c_1 - c_2$ is nonzero, hence invertible in the
field $\mathbb{Z}/p\mathbb{Z}$; let $\delta = (c_1 - c_2)^{-1}$, so
$\delta\,(c_1 - c_2) = 1$. Multiplying both sides by $\delta$,
$$ \big(\delta\,(s_1 - s_2)\big)\cdot g = \delta\,(c_1 - c_2)\cdot Y = Y. $$
The left scalar is exactly $\mathrm{extract}(c_1, s_1, c_2, s_2)$, proving the
claim. Crucially, no assumption that $Y = \mathrm{pk}(x)$ for some pre-existing
$x$ was used: only the two acceptance equations and invertibility of the challenge
difference. $\qquad\blacksquare$

> **Corollary 4.3 (Knowledge soundness, existence form).** Under the hypotheses of
> Theorem 4.2, $\exists x.\ \mathrm{pk}(x) = Y$; namely
> $x = \mathrm{extract}(c_1, s_1, c_2, s_2)$.

Thus two accepting transcripts for a common commitment under distinct challenges
do not merely *determine a number* — they *prove that $Y$ has a discrete
logarithm* and exhibit it. This is precisely the property invoked by the Forking
Lemma in proofs of knowledge.

> **Corollary 4.4 (Classical special soundness).** If $Y = \mathrm{pk}(x)$, then
> under the hypotheses of Theorem 4.2 the named secret equals the extracted value,
> $x = \mathrm{extract}(c_1, s_1, c_2, s_2)$.

*Proof sketch.* By Theorem 4.2, $\mathrm{extract}(\cdots)\cdot g = Y = x\cdot g$,
so $(\mathrm{extract}(\cdots) - x)\cdot g = 0$. As $g \ne 0$ and
$\mathbb{Z}/p\mathbb{Z}$ has no zero divisors, $\mathrm{extract}(\cdots) = x$.
Hence knowledge soundness implies special soundness; the converse would need the
extra well-formedness assumption $Y = \mathrm{pk}(x)$. $\qquad\blacksquare$

### 4.2 Exact soundness error

We now quantify how often a witness-free prover can succeed. Fix a commitment $t$
and a public key $Y$. Call a challenge $c$ *winning* if there exists a response
$s$ with $\mathrm{accepts}(Y, (t, c, s))$. Define the winning set
$$ W(t, Y) = \{\, c \in \mathbb{Z}/p\mathbb{Z} : \exists s,\ s\cdot g = t + c\cdot Y \,\}. $$

> **Lemma 4.5 (Winning challenges form a singleton).** Suppose a witness-free
> prover has committed to a fixed $t$ before seeing the challenge. Then there is
> *exactly one* challenge it can answer, i.e. the relevant winning set has
> cardinality $1$.

*Proof sketch.* Two distinct answerable challenges $c_1 \ne c_2$ at the same
commitment would, by Theorem 4.2, let the prover (or an observer of its two
responses) extract a witness $x^\star$ with $x^\star \cdot g = Y$ — contradicting
the assumption that no witness is known/available to it. Hence at most one
challenge is answerable. Conversely, given the prover's fixed strategy producing a
response for one specific challenge, that challenge is answerable, so the count is
exactly one. (Concretely, for the equation $s\cdot g = t + c\cdot Y$ each fixed
$c$ has a unique solution $s = g^{-1}(t + cY)$; the constraint that makes only one
$c$ usable by a *witness-free* prover is the extraction obstruction.)
$\qquad\blacksquare$

> **Theorem 4.6 (Soundness error $= 1/p$).** A witness-free prover, having
> committed before the challenge is drawn uniformly from $\mathbb{Z}/p\mathbb{Z}$,
> is accepted with probability exactly
> $$ \frac{|W|}{p} = \frac{1}{p}. $$

*Proof sketch.* The challenge space has $p$ elements drawn uniformly. By
Lemma 4.5 exactly one challenge is answerable. The acceptance probability is the
density of the singleton winning set, $1/p$. $\qquad\blacksquare$

For a 256-bit prime, $1/p \approx 10^{-77}$. Soundness amplification by $t$-fold
parallel repetition drives this to $p^{-t}$ (see §7).

## 5. Perfect Honest-Verifier Zero Knowledge

### 5.1 The pointwise identity

> **Definition 5.1 (Honest/simulator dictionary).** Define the map on
> randomness/challenge pairs
> $$ \Phi_x : (r, c) \longmapsto (r + x\,c,\; c), $$
> with inverse $\Phi_x^{-1} : (s, c) \mapsto (s - x\,c,\; c)$. Then $\Phi_x$ is a
> bijection of $(\mathbb{Z}/p\mathbb{Z})^2$.

> **Theorem 5.2 (HVZK pointwise identity).** For all $r, c$,
> $$ \mathrm{honest}(x, r, c) = \mathrm{sim}\big(\mathrm{pk}(x),\, c,\, r + xc\big), $$
> i.e. the honest transcript on $(r, c)$ equals the simulated transcript on the
> response coordinate of $\Phi_x(r,c)$ at the same challenge.

*Proof sketch.* Both sides share challenge $c$ and response $r + xc$. For the
commitment, the simulator yields
$$ (r+xc)\cdot g - c\cdot \mathrm{pk}(x) = (r + xc)\cdot g - c\,(x\cdot g) = r\cdot g, $$
which is the honest commitment. The three coordinates agree, so the transcripts
are equal. $\qquad\blacksquare$

### 5.2 From pointwise to statistical: perfect HVZK

The pointwise identity says the simulator *can output* every honest transcript. To
obtain *perfect* zero knowledge we must show it outputs them with the *same
probability*. We model both experiments on the uniform space
$(\mathbb{Z}/p\mathbb{Z})^2$ of size $p^2$: the honest experiment uses
$(r, c)$, the simulated experiment uses $(s, c)$.

> **Theorem 5.3 (Perfect HVZK, counting form).** For every (decidable) event
> $E$ on transcripts,
> $$ \big|\{(r,c) : E(\mathrm{honest}(x, r, c))\}\big| \;=\; \big|\{(s,c) : E(\mathrm{sim}(\mathrm{pk}(x), c, s))\}\big|. $$

*Proof sketch.* The bijection $\Phi_x$ of Definition 5.1 maps each honest index
$(r, c)$ to the simulator index $(r + xc, c)$. By Theorem 5.2 the transcripts at
corresponding indices are *equal*, so $E$ holds at $(r,c)$ in the honest experiment
iff it holds at $\Phi_x(r,c)$ in the simulated experiment. Hence $\Phi_x$ restricts
to a bijection between the two filtered index sets, which therefore have equal
cardinality. (Formally one transports the filtered finite set along $\Phi_x$ using
a cardinality-preserving bijection lemma, with the pointwise identity supplying the
membership equivalence.) $\qquad\blacksquare$

> **Theorem 5.4 (Perfect HVZK, probability form).** Dividing by the sample-space
> size $p^2$, for every event $E$,
> $$ \Pr_{(r,c)}[\,E(\mathrm{honest}(x,r,c))\,] \;=\; \Pr_{(s,c)}[\,E(\mathrm{sim}(\mathrm{pk}(x), c, s))\,]. $$

*Proof sketch.* Immediate from Theorem 5.3: equal counts over a common denominator
$p^2$ give equal probabilities. $\qquad\blacksquare$

The universal quantifier over events $E$ is the whole point: the *statistical
distance* between the honest and simulated transcript distributions is zero, so the
advantage of *any* distinguisher — however adaptive on the transcript — is exactly
zero. This is *perfect* HVZK, strictly stronger than the statistical or
computational variants, which only bound the distance by a small quantity.

> **Corollary 5.5.** Schnorr is a perfect-HVZK proof of knowledge: combining
> Theorem 3.1 (completeness), Theorem 4.2 (knowledge soundness), and Theorem 5.4
> (perfect HVZK).

## 6. The Fiat–Shamir Transform

The Fiat–Shamir transform removes interaction by deriving the challenge from the
commitment via a hash function $H : \mathbb{Z}/p\mathbb{Z} \to
\mathbb{Z}/p\mathbb{Z}$, modeled (at the syntactic level) as the random oracle. To
sign a message $m$ one uses $H(t, m)$; we suppress $m$ for the algebraic core.

> **Definition 6.1 (Non-interactive proof and verifier).** A *Fiat–Shamir proof*
> is a pair $\pi = (t, s)$. The non-interactive verifier *accepts* against $Y$ iff
> $$ \mathrm{fsAccepts}(H, Y, (t, s)) \iff s\cdot g = t + H(t)\cdot Y. $$

> **Definition 6.2 (Non-interactive prover).** $\mathrm{fsProve}(H, x, r) =
> \big(r\cdot g,\; r + H(r\cdot g)\,x\big)$.

> **Theorem 6.3 (Fiat–Shamir completeness).** For every hash $H$, secret $x$, and
> randomness $r$, $\mathrm{fsAccepts}(H, \mathrm{pk}(x), \mathrm{fsProve}(H, x, r))$
> holds.

*Proof sketch.* With $t = r\cdot g$ and $s = r + H(t)x$, the same distributive
computation as Theorem 3.1 gives $s\cdot g = t + H(t)\cdot \mathrm{pk}(x)$. The
argument is challenge-agnostic, so it holds for *every* $H$. $\qquad\blacksquare$

> **Theorem 6.4 (Verification equivalence).** For all $H, Y$, and $\pi = (t, s)$,
> $$ \mathrm{fsAccepts}(H, Y, (t, s)) \iff \mathrm{accepts}(Y, (t, H(t), s)). $$

*Proof sketch.* Definitional: both sides assert $s\cdot g = t + H(t)\cdot Y$. The
non-interactive verifier is exactly the interactive verifier with the challenge
fixed to the oracle answer $c = H(t)$. $\qquad\blacksquare$

> **Theorem 6.5 (Forking extraction / FS special soundness).** Suppose two
> accepting proofs share commitment $t$ but are obtained under two oracle answers
> $c_1 \ne c_2$ at $t$ — i.e. $s_1\cdot g = t + c_1\cdot \mathrm{pk}(x)$ and
> $s_2\cdot g = t + c_2\cdot \mathrm{pk}(x)$. Then
> $x = (c_1 - c_2)^{-1}(s_1 - s_2)$.

*Proof sketch.* This is exactly Theorem 4.2 / Corollary 4.4 applied to the two
forked transcripts $(t, c_1, s_1)$ and $(t, c_2, s_2)$. In a security reduction
the two distinct oracle answers are produced by *rewinding* the attacker and
*reprogramming* the random oracle at $t$; the algebra is identical to the
interactive case. This is the engine of the Forking Lemma proof of existential
unforgeability for Schnorr signatures. $\qquad\blacksquare$

> **Theorem 6.6 (Unique response).** For a fixed commitment $t$, public key $Y$,
> and oracle answer $c = H(t)$, the accepting response is unique: if two FS proofs
> with the same commitment both accept, their responses are equal.

*Proof sketch.* Two accepting proofs with equal commitment satisfy
$s_1\cdot g = t + H(t)\cdot Y = s_2\cdot g$, so $s_1\cdot g = s_2\cdot g$; since
$g \ne 0$ and the field has no zero divisors, $s_1 = s_2$. $\qquad\blacksquare$

Theorem 6.6 explains *why* a second, *different* oracle answer is so informative:
for a single answer the proof is rigid, so genuine new information can only come
from a fresh answer — exactly the resource the fork supplies.

## 7. Algorithms

We summarize the constructive content as algorithms; Python realizations appear in
the accompanying demonstration code.

**Algorithm A (Honest prover).** Input secret $x$, parameters $(p, g)$.
(1) Sample $r$ uniformly from $\mathbb{Z}/p\mathbb{Z}$. (2) Set $t \gets r\cdot g$.
(3) Receive challenge $c$. (4) Output response $s \gets r + cx \pmod p$.
Complexity: $O(1)$ field operations.

**Algorithm B (Verifier).** Input $Y, (t, c, s)$. Accept iff
$s\cdot g \equiv t + cY \pmod p$. Complexity: $O(1)$ field operations.

**Algorithm C (Witness extractor).** Input two accepting transcripts
$(t, c_1, s_1), (t, c_2, s_2)$ with $c_1 \ne c_2$. Output
$x^\star \gets (c_1 - c_2)^{-1}(s_1 - s_2) \pmod p$. Correctness: Theorem 4.2.
Complexity: one modular inverse, $O(\log p)$ via extended Euclid.

**Algorithm D (HVZK simulator).** Input $Y$. (1) Sample $c, s$ uniformly.
(2) Set $t \gets s\cdot g - cY$. (3) Output $(t, c, s)$. By Theorem 5.4 the output
distribution equals the honest one exactly. Complexity: $O(1)$ field operations.

**Algorithm E (Fiat–Shamir prover/verifier).** Prover: sample $r$, set
$t \gets r\cdot g$, $c \gets H(t)$ (or $H(t, m)$ to sign $m$),
$s \gets r + cx$; output $(t, s)$. Verifier: accept iff
$s\cdot g \equiv t + H(t)Y$. Correctness: Theorems 6.3–6.4.

## 8. Applications

- **Identification / authentication.** A device proves possession of its secret key
  without exposing it, even to a malicious verifier (perfect HVZK) and even against
  passive eavesdroppers.
- **Digital signatures.** Fiat–Shamir converts the protocol into Schnorr
  signatures (the basis of EdDSA and Bitcoin Taproot). The Forking Lemma, whose
  algebraic core is Theorem 6.5, reduces existential unforgeability to the discrete
  logarithm problem.
- **Building block for larger systems.** Schnorr is the prototype Σ-protocol;
  AND/OR compositions, threshold signatures, and many succinct-proof constructions
  inherit its completeness/soundness/HVZK skeleton.

## 9. Discussion

Two methodological points stand out. First, *exactness pays.* By refusing the usual
"with overwhelming probability" hedging we obtained the precise soundness error
$1/p$ (Theorem 4.6) and *perfect* — not merely statistical — zero knowledge
(Theorem 5.4). The proofs are not harder for being exact; they are cleaner, because
they isolate the single algebraic resource each property consumes: invertibility of
the challenge difference (soundness) and bijectivity of $\Phi_x$ (zero knowledge).

Second, *the right generality clarifies.* Stating soundness for an *arbitrary*
public key $Y$ (Theorem 4.2), rather than a well-formed $\mathrm{pk}(x)$, separates
"a witness exists and is extractable" from "the named secret is recovered." The
former is what proof-of-knowledge definitions require; the latter is a corollary
(Corollary 4.4). This is a strict generalization, and it makes the Forking-Lemma
interface transparent.

A modeling caveat: we treat the hash as a free function $H$, capturing the
*syntactic* random-oracle abstraction. The *probabilistic* random-oracle content —
union bounds over $q$ queries, rewinding, reprogramming — lives one layer above the
algebraic core proved here; Theorem 6.4 is the bridge that lets that layer reuse the
interactive analysis verbatim.

## 10. Future Directions

**C1. $t$-fold parallel repetition drives soundness error to $p^{-t}$.** Running
$t$ independent Schnorr instances and accepting iff all accept yields a witness-free
soundness error of exactly $p^{-t}$. The per-round winning challenge is unique and
the rounds are independent, so the winning challenge *tuples* form a single point
of the product space $(\mathbb{Z}/p\mathbb{Z})^t$, of density $1/p^t$ — a direct
product-of-singletons lift of Lemma 4.5, closed by the cardinality of a product.

**C2. Knowledge soundness $\equiv$ invertibility of the challenge difference.** Over
a general commutative ring of challenges, extraction
$x^\star = (c_1 - c_2)^{-1}(s_1 - s_2)$ succeeds for *all* transcript pairs iff
$c_1 - c_2$ is a unit; otherwise some accepting pair has no ring-extractable
witness. The field hypothesis in Theorem 4.2 can be relaxed to "$c_1 - c_2$ is a
unit," pinpointing the exact algebraic resource special soundness consumes, and
unifying the field regime with hidden-order (Bézout) regimes by a single
unit-vs-nonunit dichotomy.

**C3. Fiat–Shamir preserves the $1/p$ knowledge error under a collision-free
oracle.** For the non-interactive proof, a witness-free prover that queries the
oracle $q$ times succeeds with probability at most $q/p$ (a forking/union bound),
and exactly $1/p$ for a single fixed commitment. The verification equivalence
(Theorem 6.4) makes the non-interactive verifier the interactive one with
$c = H(t)$, so each distinct queried commitment contributes one winning oracle
answer out of $p$, with Lemma 4.5 bounding each contribution.

**C4. The HVZK simulator is measure-preserving for every challenge distribution,
not just uniform.** Theorem 5.3 shows equal counts under the uniform law; the
conjecture is that for any (not necessarily uniform) challenge law, the honest and
simulated transcript laws coincide after conditioning on the challenge, because
$\Phi_x$ fixes the challenge coordinate and bijects the response coordinate.

## 11. Conclusion

The Schnorr Σ-protocol exemplifies how a single equation,
$s\cdot g = t + c\cdot Y$, can simultaneously support certainty (completeness),
unforgeability (knowledge soundness with exact error $1/p$), and secrecy (perfect
HVZK), and how the Fiat–Shamir transform faithfully carries all three into the
non-interactive world that powers modern digital signatures. By insisting on exact
statements and minimal hypotheses, the development above isolates the precise
mathematical resources behind each guarantee, all the way down to the
invertibility of a challenge difference and the bijectivity of a single linear map.
