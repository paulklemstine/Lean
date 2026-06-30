# The Algebraic Core of Schnorr Identification over Abstract Groups of Prime Order

## Abstract

We give a self-contained treatment of the security-relevant algebraic core of
the Schnorr identification protocol, working over an **abstract** finite
commutative group $G$ of prime order $q$ rather than over a concrete modular
field. The central observation is that Schnorr's soundness is not a mere
polynomial identity in a ring; it is a statement about the interaction between
group exponentiation $G \to G$ and the *field* structure of the exponent ring
$\mathbb{Z}/q\mathbb{Z}$. We make this precise by introducing a field-scalar
scalar exponentiation map $(x,a)\mapsto x^{a}$ on $G \times \mathbb{Z}/q\mathbb{Z}$
that is well defined because every element satisfies $x^q = 1$. We then prove
three results: (1) for any nonzero scalar $k$, the power map $x \mapsto x^k$ is
a group automorphism of $G$ (the **power automorphism**); (2) two accepting
transcripts that share a commitment but differ in challenge yield the discrete
logarithm of the public key via an explicit extraction formula (**extraction
correctness**); and (3) a witness-free prover accepts on at most one challenge,
so the soundness error over a uniform challenge is at most $1/q$ (**soundness
error bound**). We connect these to completeness, honest-verifier
zero-knowledge, and the Fiat–Shamir transform, and discuss the structural
principles — coupling, forking, and collision transfer — that govern the wider
family of $\Sigma$-protocols.

## 1. Introduction

The Schnorr identification protocol is the archetypal $\Sigma$-protocol and the
algebraic ancestor of Schnorr signatures, EdDSA, and a large family of
zero-knowledge and threshold systems. Its security is usually presented over a
concrete cyclic group such as the multiplicative group of a prime field or an
elliptic curve group of prime order. In such presentations it is tempting to
treat the key manipulations as ring algebra. This obscures the real source of
security.

In this paper we isolate the algebraic heart of Schnorr and prove it over an
*arbitrary* finite commutative group $G$ whose order $q = |G|$ is prime. Two
features of this setting carry all the weight:

1. **Lagrange triviality.** Every $x \in G$ satisfies $x^{q} = 1$, so
   exponentiation descends to an action of the residues modulo $q$.
2. **Field structure of exponents.** Because $q$ is prime,
   $\mathbb{Z}/q\mathbb{Z}$ is a field, so nonzero challenge differences are
   *invertible*. Division in the exponent is what converts the accident "two
   challenges accepted" into the catastrophe "the secret is revealed."

We emphasize that "raising to the $k$-th power is a bijection" and "two
accepting transcripts reveal the secret" are *not* ring identities: they fail
in groups of composite order. Prime order is essential, and our development
makes the dependence explicit.

## 2. Setting and definitions

Throughout, $G$ is a finite commutative (multiplicative) group, and we write
$$ q := |G| $$
for its order, which we assume is **prime**. Consequently
$\mathbb{Z}/q\mathbb{Z}$ is a finite field. We denote by $\mathrm{val}(a) \in
\{0, 1, \dots, q-1\}$ the canonical representative of $a \in
\mathbb{Z}/q\mathbb{Z}$.

**Definition 2.1 (field-scalar exponentiation).** For $x \in G$ and a scalar
$a \in \mathbb{Z}/q\mathbb{Z}$, define
$$ x^{a} := x^{\mathrm{val}(a)}. $$
This is exponentiation of a group element by a *field scalar*.

**Lemma 2.2 (Lagrange triviality).** For all $x \in G$, $x^{q} = 1$.

*Proof.* The order of $x$ divides $|G| = q$ by Lagrange's theorem, so $x^q =
1$. $\square$

Lemma 2.2 is what makes Definition 2.1 a genuine *field* action rather than a
mere choice of representative: although the power is defined using the
representative $\mathrm{val}(a)$, all the algebraic laws below hold *as
identities in $\mathbb{Z}/q\mathbb{Z}$*, with the reduction modulo $q$ absorbed
harmlessly by $x^q = 1$.

**Lemma 2.3 (basic laws of scalar exponentiation).** For all $x, y \in G$ and $a, b
\in \mathbb{Z}/q\mathbb{Z}$:

- (zero) $x^{0} = 1$ and (one) $x^{1} = x$;
- (cast) $x^{(n \bmod q)} = x^{n}$ for every natural number $n$, via the
  canonical map $\mathbb{Z} \to \mathbb{Z}/q\mathbb{Z}$;
- (additivity in exponent) $x^{a+b} = x^{a}\, x^{b}$;
- (multiplicativity in base) $(x y)^{a} = x^{a}\, y^{a}$;
- (composition) $(x^{a})^{b} = x^{a b}$;
- (subtraction) $x^{a-b} = x^{a}\,(x^{b})^{-1}$.

*Proof sketch.* Each law follows by reducing the field scalars to their natural
representatives, applying the corresponding law for ordinary integer powers
($x^{m+n} = x^m x^n$, $(xy)^n = x^n y^n$, $(x^m)^n = x^{mn}$), and then using
Lemma 2.2 ($x^q = 1$) to absorb the discrepancy between $\mathrm{val}(a) +
\mathrm{val}(b)$ and $\mathrm{val}(a+b)$, which differ by a multiple of $q$.
The composition law uses that the natural-number product $\mathrm{val}(a)\cdot
\mathrm{val}(b)$ reduces to $ab$ in $\mathbb{Z}/q\mathbb{Z}$. Multiplicativity
in the base is the commutative-group identity $(xy)^n = x^n y^n$. $\square$

These laws say exactly that for each fixed $x$, the map $a \mapsto x^a$ is a
homomorphism from $(\mathbb{Z}/q\mathbb{Z}, +)$ into $G$, and for each fixed
$a$, the map $x \mapsto x^a$ is an endomorphism of $G$.

## 3. The power automorphism

The first main theorem is that exponentiation by any *nonzero* scalar is not
merely an endomorphism but an automorphism.

**Theorem 3.1 (power automorphism).** Let $k \in \mathbb{Z}/q\mathbb{Z}$ with
$k \neq 0$. Then the power map
$$ \pi_k : G \to G, \qquad \pi_k(x) = x^{k} $$
is a group automorphism of $G$.

*Proof.* By Lemma 2.3, $\pi_k$ is an endomorphism ($\pi_k(xy) = \pi_k(x)
\pi_k(y)$ and $\pi_k(1) = 1$). It remains to show $\pi_k$ is bijective; since
$G$ is finite, injectivity suffices.

Suppose $x^{k} = y^{k}$. Then $z := x y^{-1}$ satisfies $z^{\mathrm{val}(k)} =
1$. The order of $z$ divides $\mathrm{val}(k)$, and it also divides $|G| = q$
(Lemma 2.2). Because $q$ is prime, the only divisors of $q$ are $1$ and $q$, so
$\mathrm{ord}(z) \in \{1, q\}$. If $\mathrm{ord}(z) = q$, then $q \mid
\mathrm{val}(k)$; but $0 < \mathrm{val}(k) < q$ since $k \neq 0$, a
contradiction. Hence $\mathrm{ord}(z) = 1$, i.e. $z = 1$, i.e. $x = y$. Thus
$\pi_k$ is injective and therefore bijective. $\square$

The hypothesis $k \neq 0$ and the *primality* of $q$ are both indispensable: in
a group of composite order, raising to a power sharing a common factor with the
order is not injective. We package the result as a multiplicative equivalence
$\pi_k : G \xrightarrow{\sim} G$, which lets us "divide in the exponent" by
applying $\pi_{k^{-1}}$ — the cornerstone of extraction.

## 4. The protocol and its acceptance predicate

Fix a generator $g \in G$ (an element with $\mathrm{ord}(g) = q$; in a group of
prime order every non-identity element is a generator) and a public key $Y \in
G$. The Schnorr identification protocol proceeds in three moves:

1. **Commitment.** The prover samples $r \in \mathbb{Z}/q\mathbb{Z}$ uniformly
   and sends $A := g^{r}$.
2. **Challenge.** The verifier samples $c \in \mathbb{Z}/q\mathbb{Z}$ uniformly
   and sends it.
3. **Response.** The prover sends $s := r + c\,x$, where $x$ is the secret with
   $Y = g^{x}$.

**Definition 4.1 (acceptance).** A transcript $(A, c, s) \in G \times
\mathbb{Z}/q\mathbb{Z} \times \mathbb{Z}/q\mathbb{Z}$ is **accepting** against
public key $Y$ iff
$$ g^{s} = A \cdot Y^{c}. $$

**Proposition 4.2 (completeness).** If $Y = g^{x}$ and the prover follows the
protocol, the transcript $(g^{r}, c, r + cx)$ is accepting for every $r$ and
$c$.

*Proof.* Using additivity and composition (Lemma 2.3),
$$ g^{r + cx} = g^{r}\, g^{cx} = g^{r}\,(g^{x})^{c} = A \cdot Y^{c}. \qquad\square $$

## 5. Extraction and special soundness

**Theorem 5.1 (extraction correctness).** Let $(A, c_1, s_1)$ and $(A, c_2,
s_2)$ be two accepting transcripts (against the same $Y$) sharing the
commitment $A$, with $c_1 \neq c_2$. Then
$$ Y = g^{(s_1 - s_2)(c_1 - c_2)^{-1}}. $$
In particular $x^{*} := (s_1 - s_2)(c_1 - c_2)^{-1}$ is a discrete logarithm of
$Y$ base $g$.

*Proof.* From the two acceptance equations $g^{s_1} = A\,Y^{c_1}$ and $g^{s_2}
= A\,Y^{c_2}$, divide to cancel $A$:
$$ g^{s_1}(g^{s_2})^{-1} = Y^{c_1}(Y^{c_2})^{-1}. $$
By the subtraction law (Lemma 2.3) this is
$$ g^{\,s_1 - s_2} = Y^{\,c_1 - c_2}. $$
Since $c_1 \neq c_2$, the scalar $c_1 - c_2$ is nonzero, hence invertible in
the field $\mathbb{Z}/q\mathbb{Z}$. Apply the automorphism $\pi_{(c_1 -
c_2)^{-1}}$ (Theorem 3.1) to both sides and use composition:
$$ \big(g^{\,s_1 - s_2}\big)^{(c_1 - c_2)^{-1}} = \big(Y^{\,c_1 -
c_2}\big)^{(c_1 - c_2)^{-1}} = Y^{\,(c_1 - c_2)(c_1 - c_2)^{-1}} = Y^{1} = Y. $$
The left side equals $g^{(s_1 - s_2)(c_1 - c_2)^{-1}}$ by composition. $\square$

**Theorem 5.2 (uniqueness of the discrete logarithm).** If $g$ is a generator,
then $a \mapsto g^{a}$ is injective on $\mathbb{Z}/q\mathbb{Z}$. Consequently
the extracted value $x^{*}$ of Theorem 5.1 is *the* discrete logarithm of $Y$:
if $Y = g^{x}$ then $x^{*} = x$.

*Proof.* If $g^{a} = g^{b}$ then $g^{a - b} = 1$, so $\mathrm{ord}(g) = q$
divides $\mathrm{val}(a - b) < q$, forcing $a = b$. Uniqueness of the exponent
gives $x^{*} = x$. $\square$

Theorems 5.1 and 5.2 are the **special soundness** of Schnorr: any two
accepting transcripts that fork at the challenge expose the witness. Crucially,
Theorem 5.1 assumes *nothing* about $Y$ — it does not presuppose that a secret
exists. This is the **knowledge soundness** strengthening: a fork does not
merely determine a number, it *proves the existence of a discrete logarithm of
$Y$*, namely $\exists x,\; Y = g^{x}$.

## 6. The soundness error is at most $1/q$

Special soundness has a sharp quantitative counterpart.

**Theorem 6.1 (at most one accepting challenge).** Fix a commitment $A$ and a
response $s$, and suppose the prover does not know a discrete logarithm of $Y$
(equivalently, never produces one). Then the set of challenges $c$ for which
$(A, c, s)$ is accepting has at most one element.

*Proof.* Assume $Y \neq 1$ (otherwise no secret is hidden). The acceptance
equation $g^{s} = A\,Y^{c}$, viewed as a condition on the challenge $c$ with the
pre-committed $A, s$ fixed, rearranges to $Y^{c} = A^{-1} g^{s}$. Since $Y \neq
1$ is a generator of the prime-order group, the map $c \mapsto Y^{c}$ is a
bijection (Theorems 3.1 and 5.2), so there is at most one $c$ solving the
equation. Hence at most one challenge accepts. $\square$

**Theorem 6.2 (soundness error bound).** The challenge space
$\mathbb{Z}/q\mathbb{Z}$ has exactly $q$ elements. Therefore, against a
uniformly random challenge, a witness-free prover with pre-committed $(A, s)$
is accepted with probability at most
$$ \frac{\#\{c : (A,c,s)\text{ accepting}\}}{q} \le \frac{1}{q}. $$

*Proof.* Immediate from Theorem 6.1 and $|\mathbb{Z}/q\mathbb{Z}| = q$.
$\square$

When $Y \neq 1$ the bound is in fact an *equality*: exactly one challenge
accepts, so the soundness (knowledge) error is precisely $1/q$. The two
soundness statements are dual: two winning challenges would, by extraction
(Theorem 5.1), reveal the secret, so as long as the secret is hidden, at most
one challenge can win.

## 7. Honest-verifier zero-knowledge

Soundness guards the verifier; zero-knowledge guards the prover.

**Theorem 7.1 (honest-verifier zero-knowledge).** There is a simulator that,
given only the public key $Y$ and a challenge $c$, outputs a transcript $(A, c,
s)$ that is (i) always accepting and (ii) distributed identically to a real
honest transcript with challenge $c$. Concretely: sample $s \in
\mathbb{Z}/q\mathbb{Z}$ uniformly and set $A := g^{s}\,(Y^{c})^{-1}$.

*Proof.* For acceptance, $A \cdot Y^{c} = g^{s}(Y^{c})^{-1} Y^{c} = g^{s}$, so
$(A, c, s)$ satisfies Definition 4.1. For the distribution, the real transcript
is $(g^{r}, c, r + cx)$ with $r$ uniform; the map $r \mapsto s = r + cx$ is a
bijection of $\mathbb{Z}/q\mathbb{Z}$ (translation), and under it $g^{r} =
g^{s - cx} = g^{s}(g^{x})^{-c} = g^{s}(Y^{c})^{-1} = A$. Thus the simulated and
real transcripts coincide as distributions via an explicit bijection on the
randomness. $\square$

Because the verifier can produce the transcript distribution unaided, the
interaction reveals nothing about $x$ beyond the truth of the statement $\exists
x,\ Y = g^x$.

## 8. The Fiat–Shamir transform

The **Fiat–Shamir transform** makes the protocol non-interactive by deriving
the challenge from the commitment through a public hash function $H$ modeled as
a random oracle: set $c := H(A)$ (or $c := H(A, m)$ to bind a message $m$). A
non-interactive proof is a pair $(A, s)$, and the verifier recomputes $c =
H(A)$ and checks $g^{s} = A \cdot Y^{c}$.

**Proposition 8.1 (Fiat–Shamir completeness).** For any hash $H$, the honest
non-interactive prover — who, having committed to $A = g^{r}$, sets $c = H(A)$
and $s = r + cx$ — is accepted.

*Proof.* This is Proposition 4.2 with $c$ instantiated to $H(A)$. $\square$

**Proposition 8.2 (soundness reduces to interactive special soundness).** A
non-interactive proof $(A, s)$ is accepting iff the interactive transcript $(A,
H(A), s)$ is accepting. Hence two accepting non-interactive proofs that share
$A$ but were produced under two *distinct* oracle answers $c_1 \neq c_2$ at $A$
(a **fork**) recover the secret via Theorem 5.1: $x = (s_1 - s_2)(c_1 -
c_2)^{-1}$.

*Proof.* The first claim is definitional: the verifier's check is exactly the
interactive acceptance predicate with $c = H(A)$. The second applies Theorem
5.1 to the two forked transcripts. $\square$

This is the engine of the **forking lemma** proof of existential unforgeability
for Schnorr signatures: a forger run twice with the oracle reprogrammed at the
decisive query yields two forked transcripts, and extraction contradicts the
hardness of discrete logarithms. The *only* place hardness enters is the
hypothesis $c_1 \neq c_2$; the algebra is challenge-agnostic.

## 9. Algorithms

We summarize the constructive content as algorithms over $G$ and
$\mathbb{Z}/q\mathbb{Z}$.

**Algorithm A (honest prover / verifier).**
Prover: sample $r$, send $A = g^r$; on challenge $c$, send $s = r + cx$.
Verifier: accept iff $g^s = A\,Y^c$. Correctness is Proposition 4.2.

**Algorithm B (witness extraction).**
Input: two accepting transcripts $(A, c_1, s_1)$, $(A, c_2, s_2)$ with $c_1
\neq c_2$. Output: $x^{*} = (s_1 - s_2)(c_1 - c_2)^{-1}$, satisfying $Y =
g^{x^{*}}$. Correctness is Theorem 5.1; it runs in a constant number of field
operations plus one inversion.

**Algorithm C (HVZK simulator).**
Input: $Y$, challenge $c$. Output: $(g^s (Y^c)^{-1}, c, s)$ for uniform $s$.
Correctness and perfect simulation are Theorem 7.1.

## 10. Applications

The abstract-group viewpoint applies uniformly to every concrete instantiation
of prime-order Schnorr: prime-field subgroups, elliptic-curve groups of prime
order, and pairing-friendly groups. Downstream, the same algebraic core powers
Schnorr and EdDSA signatures (via Fiat–Shamir), proofs of equality of discrete
logarithms (Chaum–Pedersen) used in verifiable shuffles and verifiable random
functions, OR-proofs and ring signatures, and threshold/multi-signature
schemes. In every case the security guarantee is the same: forging requires
either solving a discrete logarithm or forcing two accepting runs to fork, and
the per-challenge cheating probability is $1/q$.

## 11. Discussion

The development isolates *why* Schnorr is secure: not because of a ring
identity, but because (i) Lagrange triviality $x^q = 1$ turns exponentiation
into a field action, and (ii) primality of $q$ makes nonzero challenge
differences invertible, so a single "extra" accepting challenge is enough to
divide out and recover the secret. The duality between special soundness
(Theorem 5.1) and the $1/q$ error bound (Theorem 6.2) is the quantitative shadow
of this one algebraic fact. Working over an abstract $G$ rather than a fixed
modular model also clarifies that nothing in the argument depends on a chosen
representation — only on prime order and commutativity.

## 12. Future directions

Three structural conjectures extend this work.

**Shared-randomness coupling forces relational soundness.** A proof of equality
of two discrete logarithms succeeds precisely because a *single* response is
reused across both bases; decoupling the response destroys the equality
guarantee while preserving each individual proof. Conjecture: for any finite
family of bases, a $\Sigma$-protocol with one shared response and one shared
randomness is sound for the simultaneous relation ("all logarithms coincide")
if and only if the response variable is shared across every branch, and the
soundness error is independent of the number of bases. Relational soundness is
a property of the *variable-sharing graph* of the protocol, not of the number
of equations: coupling, not multiplicity, upgrades "each statement holds" to
"the statements agree."

**The fork point is the unique source of hardness.** In the message-bound
setting, extraction succeeds exactly when two accepting runs disagree at one
tagged point. Conjecture: across the $\Sigma$-protocol family, the minimal
information an extractor needs is a single pair of accepting transcripts
differing in exactly one challenge coordinate; knowledge soundness is
equivalent to the existence of one such fork, and every additional disagreement
is redundant. Knowledge soundness is *local*: a one-coordinate divergence
already contains the entire witness, so reductions never need more than a single
rewinding step.

**Message binding is a collision-transfer principle.** Cross-message reuse of a
single signature forces the hash to collide at the two message-tagged points.
Conjecture: this is an instance of a general transfer principle — any attack
that reuses one transcript across two distinct contexts converts, with no loss,
into a collision of the context-binding function at those two contexts. Hence
the unforgeability of a binding scheme is equivalent to collision resistance of
its binding function.

## 13. Conclusion

Stripped to essentials, prime-order Schnorr rests on a single luminous fact:
in a finite commutative group of prime order, raising to any nonzero power is a
bijection, so two accepting transcripts that fork at the challenge can be
divided to expose the secret. Completeness, special and knowledge soundness, a
tight $1/q$ error, perfect honest-verifier zero-knowledge, and the Fiat–Shamir
route to signatures all flow from this one algebraic source.
