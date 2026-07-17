# Affine Zero-Knowledge Protocols for Hidden Mathematical Witnesses

**Aristotle**  
**July 17, 2026**

## Abstract

We study a three-move protocol for proving knowledge of a preimage under a homomorphism of finite abelian groups. Given finite abelian groups $W$ and $V$, a homomorphism $L:W\to V$, and a public element $y\in V$, the prover claims knowledge of $w\in W$ such that $L(w)=y$. The prover commits with $L(r)$ for a uniform mask $r$, receives a Boolean challenge $e$, and answers with $r+ew$. We prove perfect completeness, exact honest-verifier zero knowledge for each fixed challenge, witness independence of transcript distributions, and special soundness: two accepting responses to opposite challenges with the same commitment reveal a witness by subtraction. We give explicit simulation and extraction algorithms, finite cyclic examples, and computational demonstrations. We also explain precisely why these algebraic results do not by themselves establish a succinct zero-knowledge proof system for arbitrary mathematical theorems. Extending the construction to confidential theorem certification requires a sound locally testable proof encoding, hiding and binding commitments, an explicit adversarial probability model, and complexity accounting that includes proof length and security parameters.

## 1. Introduction

A proof normally serves two purposes at once. It convinces a reader that a statement is true, and it communicates the reason. Cryptographic zero knowledge separates these roles: a prover can demonstrate possession of a witness while revealing no information about the witness beyond what the public statement already implies.

This separation suggests an appealing application to mathematics. A derivation in a fixed deductive system is finite data, and its correctness is a decidable relation between a theorem statement and a purported derivation. In principle, therefore, “I know a proof of this theorem” is a proof-of-knowledge statement. The prospect is a confidential certificate: conviction without disclosure of the mathematical method.

Such a prospect must be treated carefully. A one-step opening of a committed derivation does not imply global validity, and arithmetizing a proof does not imply communication complexity independent of proof length. Before addressing those global issues, it is useful to isolate a small protocol in which the central privacy and extraction claims can be stated exactly and proved transparently.

The protocol considered here is affine. Its public relation is defined by a homomorphism $L:W\to V$ between finite abelian groups. A witness $w$ maps to the public statement $y$. Random translation by a mask $r$ makes either challenged response uniform and hence witness-independent. Conversely, subtracting responses to opposite challenges eliminates the common mask and extracts a witness. The construction is elementary, but it contains the basic “one transcript hides, two transcripts reveal” mechanism underlying a broad class of identification arguments.

Our contributions are four concrete results.

1. **Perfect completeness.** Every transcript generated from a valid witness is accepted.
2. **Perfect fixed-challenge simulation.** For either challenge bit, an explicit simulator using only public data produces exactly the real transcript distribution.
3. **Witness independence.** Any two witnesses for the same public statement induce identical fixed-challenge transcript distributions.
4. **Special soundness.** Two accepting transcripts sharing a commitment and carrying opposite challenges yield a valid witness by subtraction.

The first three results are information-theoretic. They do not invoke computational limitations. The fourth is an algebraic extraction guarantee. Together they provide a precise base layer for more elaborate cryptographic systems.

## 2. Algebraic setting

### 2.1 Finite abelian groups and the public relation

Let $W$ and $V$ be finite abelian groups, written additively, and let

$$
L:W\longrightarrow V
$$

be a group homomorphism. Thus, for all $u,v\in W$,

$$
L(u+v)=L(u)+L(v),\qquad L(0)=0,
$$

and consequently $L(-u)=-L(u)$.

A **public statement** is an element $y\in V$. A **witness** for $y$ is an element $w\in W$ satisfying

$$
L(w)=y.
$$

The associated relation is

$$
R_L=\{(y,w)\in V\times W:L(w)=y\}.
$$

No injectivity assumption is imposed. A statement may have multiple witnesses. No surjectivity assumption is imposed either; some $y\in V$ may have no witness.

The finiteness of $W$ supplies a uniform distribution. If $r$ is uniform on $W$ and $a\in W$ is fixed, then $r+a$ is also uniform because translation $r\mapsto r+a$ is a bijection. This elementary fact drives the privacy argument.

### 2.2 Protocol definition

For public input $(W,V,L,y)$ and witness $w$ satisfying $L(w)=y$, define the following three-move protocol.

1. **Commitment.** The prover samples $r\leftarrow W$ uniformly and sends

   $$
   t=L(r).
   $$

2. **Challenge.** The verifier sends $e\in\{0,1\}$.

3. **Response.** The prover sends

   $$
   z=r+ew,
   $$

   where $0w=0$ and $1w=w$.

The verifier accepts if and only if

$$
L(z)=t+ey.
$$

A transcript is a triple $(t,e,z)\in V\times\{0,1\}\times W$. For a fixed challenge $e$, the real transcript map associated with witness $w$ is

$$
\operatorname{Real}_{w,e}(r)=\bigl(L(r),e,r+ew\bigr).
$$

Sampling $r$ uniformly induces a uniform multiset, equivalently a probability distribution, over transcripts.

### 2.3 Security notions used here

The protocol has **perfect completeness** if every honest transcript formed from a valid witness is accepted.

For fixed $e$, it has **perfect honest-verifier zero knowledge** if there exists a randomized simulator using only $(L,y,e)$ whose output distribution equals the real transcript distribution exactly. “Perfect” means equality of distributions, not merely computational indistinguishability.

It has **special soundness** if any two accepting transcripts $(t,0,z_0)$ and $(t,1,z_1)$ with the same commitment yield an efficiently computable witness for $y$.

These definitions deliberately concern a fixed-challenge honest-verifier view and a two-transcript extraction experiment. They do not quantify over arbitrary malicious verifier strategies.

## 3. Completeness and exact simulation

### Theorem 1 (Perfect Completeness)

Let $w\in W$ satisfy $L(w)=y$. For every $r\in W$ and every $e\in\{0,1\}$, the transcript

$$
\bigl(L(r),e,r+ew\bigr)
$$

is accepted.

**Proof sketch.** By homomorphism linearity and the witness equation,

$$
L(r+ew)=L(r)+eL(w)=L(r)+ey.
$$

The right-hand side is exactly $t+ey$ for $t=L(r)$. Hence the verification equation always holds. $\square$

Completeness has no error probability: honest execution succeeds for every random mask and either challenge.

### 3.1 The public simulator

Fix a challenge bit $e$. Define a simulator as follows:

1. sample $z\leftarrow W$ uniformly;
2. set

   $$
   t=L(z)-ey;
   $$

3. output $(t,e,z)$.

The simulator requires no witness. Its transcript is automatically accepting since

$$
L(z)=\bigl(L(z)-ey\bigr)+ey=t+ey.
$$

The remaining question is whether the simulator merely creates plausible transcripts or reproduces the real distribution exactly.

### Lemma 2 (Translation Preserves Uniformity)

For every fixed $a\in W$, if $r$ is uniform on $W$, then $r+a$ is uniform on $W$.

**Proof sketch.** The translation map $\tau_a(r)=r+a$ has inverse $\tau_{-a}(z)=z-a$. Therefore it is a permutation of the finite set $W$. A permutation preserves the number of preimages of every point and hence preserves the uniform distribution. $\square$

### Theorem 3 (Perfect Fixed-Challenge Simulation)

Let $w\in W$ satisfy $L(w)=y$, and fix $e\in\{0,1\}$. The real transcript

$$
\bigl(L(r),e,r+ew\bigr),\qquad r\leftarrow W,
$$

has exactly the same distribution as the simulated transcript

$$
\bigl(L(z)-ey,e,z\bigr),\qquad z\leftarrow W.
$$

**Proof sketch.** Set $z=r+ew$. By Lemma 2, $z$ is uniform when $r$ is uniform. Moreover,

$$
L(r)=L(z-ew)=L(z)-eL(w)=L(z)-ey.
$$

Thus the real transcript after the bijective change of variables $r\mapsto z$ is pointwise identical to the simulator’s transcript. Because the change of variables is a permutation, transcript multiplicities and probabilities agree exactly. $\square$

This theorem is stronger than saying that the response alone is uniform. It identifies the joint distribution of commitment, challenge, and response. Although $t$ and $z$ are correlated, the simulator reproduces that correlation using the public verification equation.

### Corollary 4 (Witness Independence)

Let $w_0,w_1\in W$ satisfy $L(w_0)=L(w_1)=y$. For either fixed challenge $e$, the transcript distributions generated using $w_0$ and $w_1$ are identical.

**Proof sketch.** By Theorem 3, each real distribution equals the same simulator distribution, which depends only on $L$, $y$, and $e$. Therefore the two real distributions equal one another. $\square$

Witness independence is meaningful when $L$ has a nontrivial kernel. If $w$ is a witness, then every $w+k$ with $k\in\ker L$ is another witness. The transcript cannot reveal which representative of the fiber $L^{-1}(y)$ was used.

### Corollary 5 (Zero Information in the Information-Theoretic Sense)

For a fixed challenge $e$, every statistical test applied to the transcript has the same output distribution whether the transcript is real or simulated. In particular, no unbounded observer can distinguish the two with nonzero advantage.

**Proof sketch.** Applying any deterministic or randomized post-processing operation to identically distributed inputs yields identically distributed outputs. The claim follows directly from Theorem 3. $\square$

## 4. Special soundness and extraction

Simulation explains why one accepting view is harmless. Extraction explains why answering both challenges for one commitment is decisive.

### Theorem 6 (Special Soundness by Affine Subtraction)

Suppose $(t,0,z_0)$ and $(t,1,z_1)$ are accepting transcripts with the same commitment $t$. Then

$$
w^*=z_1-z_0
$$

is a witness for $y$; that is,

$$
L(w^*)=y.
$$

**Proof sketch.** Acceptance for challenge $0$ gives

$$
L(z_0)=t.
$$

Acceptance for challenge $1$ gives

$$
L(z_1)=t+y.
$$

Subtracting in $V$ and using the homomorphism property,

$$
L(z_1-z_0)=L(z_1)-L(z_0)=(t+y)-t=y.
$$

Thus $z_1-z_0$ belongs to the witness fiber $L^{-1}(y)$. $\square$

The extractor is deterministic and requires one subtraction in $W$. It does not assume that either response was generated honestly. It uses only their acceptance and shared commitment.

### Corollary 7 (Honest Responses Recover the Original Witness)

If the common commitment was generated from a mask $r$ and the two honest responses are $z_0=r$ and $z_1=r+w$, then the extractor outputs $w$ exactly.

**Proof sketch.** Directly,

$$
z_1-z_0=(r+w)-r=w.
$$

$\square$

### 4.1 The role of commitment consistency

The shared-commitment condition is essential. If the transcripts use commitments $t_0$ and $t_1$, acceptance gives

$$
L(z_0)=t_0,\qquad L(z_1)=t_1+y,
$$

so

$$
L(z_1-z_0)=y+(t_1-t_0).
$$

This equals $y$ only when $t_1=t_0$. Any application to an adversarial prover must therefore ensure that the commitment is fixed before the challenge and cannot be changed afterward.

### 4.2 From local extraction to repetition

Suppose a prover, for a fixed commitment, can answer at most one challenge unless it possesses enough information to yield a witness. If the verifier chooses a uniform challenge bit, a prover prepared for only one branch succeeds with probability at most $1/2$. With $k$ independent repetitions and commitments fixed before challenges, the probability of guessing every challenge is at most

$$
2^{-k}.
$$

This familiar amplification statement is not a consequence of group algebra alone. It additionally requires a probabilistic adversary model, challenge independence, and a binding or fixed-commitment condition. The extraction theorem provides the key structural fact—both answers imply a witness—but a complete soundness theorem must state the operational assumptions.

## 5. Concrete cyclic instantiation

Let $q\ge 2$, take

$$
W=V=\mathbb{Z}/q\mathbb{Z},
$$

and choose $a\in\mathbb{Z}/q\mathbb{Z}$. Define

$$
L(x)=ax\pmod q.
$$

The public statement is $y=aw\pmod q$. The prover samples $r$ uniformly modulo $q$, sends $t=ar\pmod q$, receives $e\in\{0,1\}$, and replies

$$
z=r+ew\pmod q.
$$

The verifier checks

$$
az\equiv t+ey\pmod q.
$$

For example, take $q=11$, $a=3$, and $y=7$. Both $w=6$ and, modulo $11$, only its congruent representatives satisfy $3w\equiv7$. If instead $a$ is not invertible modulo a composite modulus, multiple incongruent witnesses may exist. With $q=12$, $a=4$, and $y=8$, the witnesses are $2$, $5$, $8$, and $11$. For either challenge, all four witnesses induce the same transcript distribution.

Consider $q=12$, $a=4$, $w=5$, and $r=7$. Then $y=8$ and $t=4$. The challenge-$0$ response is $z_0=7$, and indeed $4z_0\equiv4=t$. The challenge-$1$ response is $z_1=0$, since $7+5\equiv0$. Verification gives $4z_1\equiv0\equiv4+8=t+y$. Extraction returns

$$
z_1-z_0\equiv0-7\equiv5\pmod{12},
$$

which is the witness.

The fixed-challenge simulator samples $z$ uniformly modulo $q$ and computes

$$
t=az-ey\pmod q.
$$

Enumerating all $q$ choices shows exact equality with the real transcript multiset. This remains true when $a$ is noninvertible and the public statement has multiple witnesses.

## 6. Algorithms and complexity

### 6.1 Real transcript generation

**Input:** modulus or finite-group representation, homomorphism $L$, public statement $y$, witness $w$, challenge $e$.  
**Procedure:** sample uniform $r\in W$; compute $t=L(r)$ and $z=r+ew$; return $(t,e,z)$.

If a group operation costs $C_W$ and evaluating $L$ costs $C_L$, generation costs $O(C_L+C_W)$ beyond random sampling. For integers modulo $q$, using ordinary arithmetic, the bit complexity is polynomial in $\log q$.

### 6.2 Public simulation

**Input:** $L$, $y$, and fixed challenge $e$.  
**Procedure:** sample uniform $z\in W$; compute $t=L(z)-ey$; return $(t,e,z)$.

Its asymptotic cost matches real generation: one evaluation of $L$ and a constant number of group operations. The simulator does not search for a witness and does not invert $L$.

### 6.3 Two-transcript extraction

**Input:** accepting transcripts $(t,0,z_0)$ and $(t,1,z_1)$.  
**Procedure:** verify the shared commitment and both acceptance equations; return $z_1-z_0$.

After verification, extraction itself uses one group subtraction. The verifier may recompute two images under $L$, giving total cost $O(2C_L+C_W)$. In a cyclic group modulo $q$, this is polynomial in $\log q$.

### 6.4 Exhaustive distribution comparison

For small groups, one can enumerate every mask $r$ and every simulated response $z$, count transcripts, and compare the two frequency maps. For a group of size $N=|W|$, each distribution requires $N$ transcript constructions. Hash-table comparison has expected time $O(N)$ and space $O(N)$; sorting-based comparison takes $O(N\log N)$ time. Enumeration is pedagogical rather than cryptographically scalable, since Theorem 3 already proves equality for all finite sizes.

## 7. Toward confidential theorem certification

### 7.1 Derivations as witnesses

Fix a deductive theory with a finite or decidable collection of inference rules. A derivation of a formula $T$ can be encoded as a finite sequence

$$
\pi=(\varphi_1,\ldots,\varphi_m),
$$

where each $\varphi_i$ is either an axiom or follows from designated earlier formulas by an allowed rule, and $\varphi_m=T$. There is then a decidable relation

$$
R(T,\pi)=1
$$

meaning that $\pi$ is a valid derivation of $T$.

This makes a hidden proof a cryptographic witness. It does not, however, make the affine protocol directly applicable: general proof verification is not usually a single homomorphic preimage equation. A reduction or encoding is needed.

### 7.2 Why opening one line is insufficient

Suppose a prover commits separately to each line of a purported derivation, and the verifier asks to inspect one randomly selected line together with its cited premises. If exactly one of $m$ lines is invalid, a single uniform query detects the defect with probability only $1/m$. Repeating a constant number of times leaves substantial soundness error.

A locally testable encoding must amplify global invalidity into many local violations. Probabilistically checkable proof constructions are relevant because they redesign the witness so that a verifier can query a few locations. But local testability, hiding, and succinctness are different properties:

- **Local soundness** ensures that false statements or invalid encodings are caught with noticeable probability.
- **Zero knowledge** ensures that queried views disclose nothing beyond validity.
- **Binding** prevents answers from being changed after queries are known.
- **Succinctness** bounds communication and verifier work in the chosen size parameters.

None follows automatically from the others.

### 7.3 Statement length versus proof length

A claim that communication is polynomial only in the theorem statement length is much stronger than a claim polynomial in the hidden proof length or in a security parameter. Encoding an arbitrarily long derivation as an integer does not make the integer’s bit representation short. Likewise, a generic local-checking transformation may have size polynomial in the original witness length.

A rigorous succinctness theorem must specify at least:

1. the encoding of formulas and derivations;
2. the bit length of the theorem statement;
3. the bit length of the proof witness;
4. the security parameter;
5. prover time, verifier time, randomness, and total communication;
6. the computational assumptions supporting commitments or arguments.

Without this accounting, no statement-length polynomial bound should be inferred.

### 7.4 Honest and malicious verifiers

The simulator in Theorem 3 handles a prescribed challenge. General zero knowledge quantifies over potentially malicious verifier strategies and asks for a simulator of their complete view, including adaptive messages and internal randomness. Such simulation may require rewinding or a different protocol transformation. Perfect fixed-challenge simulation is a strong local fact, but it is not a full malicious-verifier theorem.

## 8. Applications

The immediate application is privacy-preserving identification for linear relations in finite groups. A party can demonstrate knowledge of a preimage without identifying which preimage it holds. This is especially relevant when $L$ has a nontrivial kernel and witness anonymity is important.

A second application is conceptual modularity in larger protocols. The affine core supplies a sigma-protocol-like component with completeness, simulation, and extraction. A surrounding system can provide commitments, repetition, and compilation against malicious verifiers.

A third application is confidential certification. Engineering designs, optimization solutions, and mathematical derivations can all be regarded as witnesses to public predicates. The present construction does not solve those general relations directly, but it clarifies the exact obligations any solution must meet: simulated views, binding commitments, global soundness, and explicit complexity bounds.

There are also limitations of purpose. A zero-knowledge certificate establishes confidence without explanation. Mathematics as a communicative discipline values proofs because they reveal structure, permit reuse, and generate new ideas. Confidential certification is therefore complementary to exposition, not a substitute for it.

## 9. Discussion

The protocol’s geometry is summarized by two maps. For privacy, the map

$$
r\longmapsto r+ew
$$

is a permutation. For extraction, the map

$$
(z_0,z_1)\longmapsto z_1-z_0
$$

cancels a shared affine offset. The same structure creates both concealment and accountability.

Perfect simulation is possible because the verifier’s acceptance equation uniquely determines the commitment from $(e,z)$:

$$
t=L(z)-ey.
$$

The simulator samples the free coordinate $z$ and reconstructs the constrained coordinate $t$. In a real execution, the response is already uniform after translation. This is why simulation requires neither inversion of $L$ nor knowledge of a preimage.

Special soundness is possible because opposite challenges produce equations whose difference is exactly the public relation. This algebraic cancellation also explains the fragility of the result: if commitments differ, if challenges are not genuinely distinct, or if acceptance tolerates uncontrolled errors, extraction must be reconsidered.

The finite setting avoids measure-theoretic complications. Uniform distributions can be understood as normalized multiplicities over all group elements. The theorem therefore states literal equality of transcript counts. Recasting the result directly in probability-mass-function language would make sequential and parallel composition more convenient, but would not alter the argument.

## 10. Future work

A first extension is to express transcript equality directly as equality of probability mass functions and then prove closure under product distributions. This would support a clean treatment of $k$ independent challenges.

A second direction is a full repetition theorem. It should distinguish extraction from probability amplification and explicitly model adversarial commitment strategies, independence, and binding. Under appropriate assumptions, the target soundness error is exponential in the repetition count.

A third direction is to encode propositional derivations as locally checkable objects. The development must separately prove global soundness of the encoding, privacy of sampled openings, and commitment security. Simply opening random proof lines is insufficient.

A fourth direction is to instantiate the additive construction in concrete cyclic groups and relate it to identification protocols expressed multiplicatively. Care is needed when translating additive witness equations into exponentiation statements.

A fifth direction is complexity-aware confidential theorem certification. Any broad claim about proofs in arithmetic must represent algorithms and bit lengths explicitly and must not confuse arithmetization with compression. Genuinely succinct argument systems, rather than elementary encoding alone, are needed for communication bounds detached from proof length.

Finally, malicious-verifier zero knowledge remains open for this presentation. The fixed-challenge simulator should be replaced or compiled into a simulator that handles arbitrary verifier strategies and their full views, with running time and any rewinding procedure analyzed explicitly.

## 11. Conclusion

For a homomorphic preimage relation over finite abelian groups, a three-move affine protocol achieves four exact properties: honest transcripts always verify; fixed-challenge views can be simulated perfectly from public data; transcript distributions do not depend on the choice of witness; and two accepting answers to opposite challenges under one commitment reveal a witness by subtraction.

These results provide a mathematically complete account of a foundational zero-knowledge mechanism. They also identify what remains outside that mechanism. Confidential certification of arbitrary theorems requires globally sound local encodings, hiding and binding commitments, adversarial simulation, repetition analysis, and honest complexity accounting. The affine protocol is therefore neither a proof of universal succinct theorem certification nor merely a toy. It is the precise algebraic core on which such systems can be built: translation hides one answer, and subtraction exposes inconsistency.