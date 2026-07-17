# Exact Zero Knowledge and Special Soundness for a Three-Move Homomorphism Protocol

**Aristotle**  
**17 July 2026**

## Abstract

We study a three-move identification protocol for a public homomorphism $\varphi:G\to H$ between additive commutative groups. The public statement is an element $y\in H$, and a witness is a preimage $w\in G$ satisfying $\varphi(w)=y$. An honest prover commits with $\varphi(r)$ for random $r\in G$, receives a Boolean challenge $c$, and responds with $r+[c]w$. We establish perfect completeness, unconditional acceptance of simulated transcripts, exact perfect honest-verifier zero knowledge over finite $G$, and special soundness. The zero-knowledge argument is distributional rather than heuristic: translation by the challenge-dependent witness term gives an explicit bijection between real and simulated random tapes, proving equality of transcript multisets. The soundness argument is extractive: accepted responses to both challenges for one commitment yield the witness $z_1-z_0$. Consequently, when no witness exists, a fixed commitment cannot answer both challenges. We give executable finite cyclic-group algorithms, numerical examples, and a careful account of the boundary between this result and broader claims about zero-knowledge certification of arbitrary mathematical proofs.

## 1. Introduction

A proof ordinarily persuades by disclosure: the verifier inspects the argument. A zero-knowledge protocol separates persuasion from disclosure. It allows a prover to demonstrate possession of a witness while ensuring that the verifier's view contains no information beyond what can be generated without that witness.

The phrase “contains no information” requires a mathematical definition. It is not enough that the transcript omits the witness, nor that extracting the witness appears difficult. The standard simulation paradigm asks for an algorithm that produces the verifier's view without access to the witness. In the strongest finite setting, the simulated and real distributions agree exactly. Such *perfect* zero knowledge rules out every statistical distinguisher, without any restriction on computational power.

This paper presents an elementary protocol in which completeness, privacy, and knowledge extraction all reduce to transparent group identities. Let $G$ and $H$ be additive commutative groups and let $\varphi:G\to H$ be a homomorphism. The public target is $y\in H$; the prover's witness is a preimage $w\in G$ with $\varphi(w)=y$. The prover masks $w$ with a random group element. A Boolean challenge asks the prover to reveal either the mask or the mask shifted by the witness.

The protocol supports four exact results.

1. **Perfect completeness:** every honest execution with a valid witness is accepted.
2. **Simulator acceptance:** a simulator can generate an accepted transcript for either challenge without a witness.
3. **Perfect honest-verifier zero knowledge:** when $G$ is finite and randomness is uniform, the real and simulated transcript distributions are exactly equal.
4. **Special soundness:** two accepted responses to opposite challenges for the same commitment reveal a witness by subtraction.

These properties illuminate the central balance of a sigma protocol. A single transcript reveals no witness information because it can be simulated. Two compatible transcripts demonstrate knowledge because they enable extraction.

The result should be interpreted precisely. It is an information-theoretic analysis of a homomorphic preimage identification protocol. It does not, by itself, establish a succinct zero-knowledge protocol for arbitrary formal theorems. That broader objective requires encodings, commitments, general zero-knowledge transformations, complexity bounds, and protection against malicious verifiers. We return to these distinctions in the discussion.

## 2. Algebraic setting and definitions

### 2.1 Public statements and witnesses

Let $(G,+,0,-)$ and $(H,+,0,-)$ be commutative groups. Let

$$
\varphi:G\longrightarrow H
$$

be a group homomorphism, so that for all $x,x'\in G$,

$$
\varphi(x+x')=\varphi(x)+\varphi(x').
$$

It follows that $\varphi(0)=0$ and $\varphi(x-x')=\varphi(x)-\varphi(x')$.

**Definition 2.1 (Public statement).** A public statement is a pair $(\varphi,y)$ consisting of a homomorphism $\varphi:G\to H$ and a target $y\in H$.

**Definition 2.2 (Witness).** An element $w\in G$ is a witness for $(\varphi,y)$ if

$$
\varphi(w)=y.
$$

The associated language is the image of $\varphi$: a statement is true precisely when $y\in\operatorname{im}(\varphi)$.

### 2.2 Boolean challenge terms

For a Boolean challenge $c\in\{0,1\}$ and any element $x$ of an additive group, define

$$
[c]x=\begin{cases}
0,&c=0,\\
x,&c=1.
\end{cases}
$$

This notation obeys $\varphi([c]x)=[c]\varphi(x)$, since the assertion is immediate in each of the two cases.

### 2.3 Transcripts and acceptance

**Definition 2.3 (Transcript).** A transcript is a triple

$$
t=(a,c,z)\in H\times\{0,1\}\times G,
$$

where $a$ is the commitment, $c$ is the challenge, and $z$ is the response.

**Definition 2.4 (Acceptance).** The verifier accepts a transcript $(a,c,z)$ exactly when

$$
\varphi(z)=a+[c]y.
$$

The definition is public and deterministic. All randomness belongs to transcript generation.

## 3. The three-move protocol

Given a statement $(\varphi,y)$ and witness $w$, the protocol is:

1. The prover samples $r\in G$ uniformly and sends the commitment

$$
a=\varphi(r).
$$

2. The verifier samples $c\in\{0,1\}$ uniformly and sends $c$.

3. The prover sends

$$
z=r+[c]w.
$$

4. The verifier accepts if and only if

$$
\varphi(z)=a+[c]y.
$$

For fixed $w,r,c$, call

$$
T_{\mathrm{real}}(w,r,c)
=\bigl(\varphi(r),c,r+[c]w\bigr)
$$

the real transcript.

The order of messages matters. The commitment is fixed before the challenge is known. If a prover could choose $a$ after seeing $c$, accepted transcripts would be trivial to construct and would provide no evidence of prior commitment.

## 4. Completeness

**Theorem 4.1 (Perfect Completeness).** Let $(\varphi,y)$ be a public statement and let $w\in G$ satisfy $\varphi(w)=y$. For every $r\in G$ and every $c\in\{0,1\}$, the real transcript $T_{\mathrm{real}}(w,r,c)$ is accepted.

**Proof sketch.** The response is $z=r+[c]w$. By homomorphicity,

$$
\varphi(z)=\varphi(r)+\varphi([c]w)
=\varphi(r)+[c]\varphi(w)
=\varphi(r)+[c]y.
$$

Since the commitment is $a=\varphi(r)$, this is exactly the acceptance equation $\varphi(z)=a+[c]y$. Equivalently, one may inspect the two cases: challenge $0$ checks $\varphi(r)=\varphi(r)$, while challenge $1$ checks $\varphi(r+w)=\varphi(r)+y$. $\square$

Completeness is perfect because it holds for every random tape and challenge, not merely with high probability.

## 5. Simulation

### 5.1 Backward transcript generation

A simulator must generate the verifier's view without a witness. For a fixed challenge $c$, it chooses the response first and derives a compatible commitment.

**Definition 5.1 (Simulated transcript).** For $z\in G$ and $c\in\{0,1\}$, define

$$
T_{\mathrm{sim}}(z,c)
=\bigl(\varphi(z)-[c]y,c,z\bigr).
$$

This construction uses only public information.

**Theorem 5.2 (Universal Simulator Acceptance).** Every simulated transcript is accepted. More precisely, for every public statement $(\varphi,y)$, every $z\in G$, and either challenge $c$, the transcript $T_{\mathrm{sim}}(z,c)$ satisfies the verifier's acceptance equation.

**Proof sketch.** Its commitment is $a=\varphi(z)-[c]y$. Therefore

$$
a+[c]y=\varphi(z)-[c]y+[c]y=\varphi(z),
$$

which is the required equation. No witness-existence assumption is used. $\square$

The fact that a simulator always creates an accepted transcript does not threaten soundness. Simulation chooses the transcript after fixing the challenge. A real prover must commit before learning the challenge.

### 5.2 Reindexing random tapes

Acceptance alone does not establish zero knowledge. We must compare distributions. Let a valid witness $w$ and challenge $c$ be fixed. Define the translation

$$
\tau_{c,w}:G\longrightarrow G,
\qquad
\tau_{c,w}(r)=r+[c]w.
$$

**Lemma 5.3 (Translation Bijection).** The map $\tau_{c,w}$ is a bijection with inverse

$$
\tau_{c,w}^{-1}(z)=z-[c]w.
$$

**Proof sketch.** For all $r,z\in G$,

$$
(r+[c]w)-[c]w=r
$$

and

$$
(z-[c]w)+[c]w=z.
$$

Hence the two maps are mutual inverses. $\square$

This elementary bijection is the measure-preserving change of variables behind perfect zero knowledge.

**Lemma 5.4 (Pointwise Transcript Identity).** If $\varphi(w)=y$, then for every $r\in G$ and $c\in\{0,1\}$,

$$
T_{\mathrm{real}}(w,r,c)
=
T_{\mathrm{sim}}\bigl(\tau_{c,w}(r),c\bigr).
$$

**Proof sketch.** Put $z=r+[c]w$. The challenge and response coordinates are immediately equal. For the commitment coordinate,

$$
\begin{aligned}
\varphi(z)-[c]y
&=\varphi(r+[c]w)-[c]y\\
&=\varphi(r)+[c]\varphi(w)-[c]y\\
&=\varphi(r).
\end{aligned}
$$

Thus all three transcript coordinates coincide. $\square$

### 5.3 Exact distributional equality

Assume now that $G$ is finite. Uniform sampling means that every element of $G$ has probability $1/|G|$. A transcript may have multiple random tapes as preimages, so the clean finite statement compares multisets, preserving multiplicity.

**Theorem 5.5 (Perfect Honest-Verifier Zero Knowledge).** Let $G$ be finite, let $(\varphi,y)$ be a public statement, and let $w$ be a witness. For either fixed challenge $c$, the multiset

$$
\left\{\!\left\{
T_{\mathrm{real}}(w,r,c):r\in G
\right\}\!\right\}
$$

is exactly equal to the multiset

$$
\left\{\!\left\{
T_{\mathrm{sim}}(z,c):z\in G
\right\}\!\right\}.
$$

Consequently, when $r$ and $z$ are sampled uniformly, the real and simulated transcript probability mass functions are identical.

**Proof sketch.** By Lemma 5.3, $r\mapsto\tau_{c,w}(r)$ permutes $G$. Reindexing a multiset by a permutation leaves it unchanged. By Lemma 5.4, each real transcript indexed by $r$ equals the simulated transcript indexed by $\tau_{c,w}(r)$. Therefore the transcript multisets agree with exact multiplicities. Dividing each multiplicity by $|G|$ yields equality of probability mass functions. $\square$

**Corollary 5.6 (Zero Distinguishing Advantage).** Under the hypotheses of Theorem 5.5, for every predicate $D$ on transcripts,

$$
\Pr[D(T_{\mathrm{real}})=1]
=
\Pr[D(T_{\mathrm{sim}})=1].
$$

Thus even an unbounded observer has distinguishing advantage $0$.

**Proof sketch.** Equal probability mass functions assign equal probability to every event, including the set of transcripts on which $D$ returns $1$. $\square$

The qualifier *honest-verifier* is essential. The theorem fixes a challenge and simulates the corresponding view. A malicious verifier may choose challenges as a function of the commitment, maintain auxiliary state, or deviate from the prescribed distribution. Handling such behavior generally requires rewinding arguments, stronger protocol transformations, or additional assumptions.

## 6. Special soundness and extraction

Zero knowledge concerns one transcript. Knowledge extraction concerns a pair of transcripts sharing a commitment but carrying opposite challenges.

**Theorem 6.1 (Special Soundness).** Let $a\in H$ and $z_0,z_1\in G$. Suppose both transcripts $(a,0,z_0)$ and $(a,1,z_1)$ are accepted. Then

$$
w'=z_1-z_0
$$

is a witness; that is, $\varphi(w')=y$.

**Proof sketch.** Acceptance gives

$$
\varphi(z_0)=a
$$

and

$$
\varphi(z_1)=a+y.
$$

Using preservation of subtraction,

$$
\begin{aligned}
\varphi(z_1-z_0)
&=\varphi(z_1)-\varphi(z_0)\\
&=(a+y)-a\\
&=y.
\end{aligned}
$$

Hence $z_1-z_0$ is a preimage of $y$. $\square$

**Corollary 6.2 (Two-Challenge Knowledge).** Suppose there is a commitment $a$ and a response rule $A:\{0,1\}\to G$ such that $(a,c,A(c))$ is accepted for both challenge values. Then the public statement has a witness.

**Proof sketch.** Apply Theorem 6.1 to $z_0=A(0)$ and $z_1=A(1)$; the extracted witness is $A(1)-A(0)$. $\square$

**Corollary 6.3 (Challenge Exclusivity Without a Witness).** If no $w\in G$ satisfies $\varphi(w)=y$, then for every commitment $a$ and responses $z_0,z_1$, it is impossible for both $(a,0,z_0)$ and $(a,1,z_1)$ to be accepted.

**Proof sketch.** If both were accepted, Theorem 6.1 would construct the forbidden witness $z_1-z_0$. $\square$

**Corollary 6.4 (Single-Round Knowledge Error).** Assume the statement has no witness. Consider any prover that fixes a commitment and its available response behavior before receiving a uniformly random Boolean challenge. It can be accepted for at most one challenge and therefore succeeds with probability at most $1/2$.

**Proof sketch.** Challenge exclusivity permits acceptance on at most one element of the two-element challenge space. A uniform challenge selects that element with probability at most $1/2$. $\square$

This is an information-theoretic statement about false instances. It does not assert that finding a witness for a true instance is computationally hard; that property depends on the chosen group and homomorphism.

## 7. Algorithms

### 7.1 Honest transcript generation

**Input:** a modulus or finite group implementation, a homomorphism $\varphi$, target $y$, witness $w$, random tape $r$, and challenge $c$.  
**Output:** $(a,c,z)$.

Compute $a=\varphi(r)$ and $z=r+[c]w$. In a cyclic group $\mathbb{Z}/n\mathbb{Z}$ with $\varphi(x)=kx\bmod n$, this requires a constant number of modular arithmetic operations. Under the standard bit model, modular addition is $O(\log n)$ and schoolbook modular multiplication is $O((\log n)^2)$.

### 7.2 Transcript simulation

Given public data and fixed $c$, sample $z$ uniformly and compute $a=\varphi(z)-[c]y$. The algorithm has the same asymptotic arithmetic cost as honest generation and does not access $w$.

### 7.3 Verification

Compute $\varphi(z)$ and $a+[c]y$, reduce to canonical group representatives, and compare. This is deterministic. For multiplication homomorphisms modulo $n$, verification uses one modular multiplication, one modular addition, and one equality test.

### 7.4 Special-soundness extraction

Given accepted $(a,0,z_0)$ and $(a,1,z_1)$ with the same $a$, output

$$
w'=z_1-z_0.
$$

The extractor should first check equal commitments, opposite challenges, and acceptance of both transcripts. Its algebraic core is one group subtraction. In $\mathbb{Z}/n\mathbb{Z}$, the arithmetic cost is $O(\log n)$.

### 7.5 Exact finite-distribution comparison

For a finite group of size $N$, enumerate all $N$ real random tapes and all $N$ simulator responses, tally the resulting transcripts, and compare the two frequency maps. This direct diagnostic requires $O(N)$ transcript generations and $O(N)$ storage in the worst case. It illustrates Theorem 5.5 but is unnecessary for cryptographically large groups, where the bijection proves equality symbolically.

## 8. Numerical examples

### 8.1 A true statement modulo $11$

Let

$$
G=H=\mathbb{Z}/11\mathbb{Z},
\qquad
\varphi(x)=3x\pmod{11}.
$$

Choose $w=4$. Then $y=3\cdot4\equiv1\pmod{11}$. With random tape $r=7$, the commitment is $a=3\cdot7\equiv10\pmod{11}$.

For $c=0$, the response is $z_0=7$, and verification checks

$$
3z_0\equiv10=a\pmod{11}.
$$

For $c=1$, the response is $z_1=7+4\equiv0\pmod{11}$, and verification checks

$$
3z_1\equiv0\equiv10+1=a+y\pmod{11}.
$$

Given both responses, extraction returns

$$
z_1-z_0\equiv0-7\equiv4\pmod{11},
$$

which is the original witness.

For simulation at challenge $1$, choose $z=5$. Then

$$
a=3z-y\equiv15-1\equiv3\pmod{11}.
$$

The verifier checks $3z\equiv4$ and $a+y\equiv4$ modulo $11$.

### 8.2 A false statement modulo $8$

Let $G=H=\mathbb{Z}/8\mathbb{Z}$ and $\varphi(x)=2x\pmod8$. The image consists of the even residues. Choose target $y=1$, which has no witness.

For any fixed commitment $a$, a challenge-$0$ response would require $2z_0\equiv a\pmod8$, while a challenge-$1$ response would require $2z_1\equiv a+1\pmod8$. The left sides are both even, whereas $a$ and $a+1$ have opposite parity. Thus at most one equation can be solvable. This concrete parity obstruction is Corollary 6.3 in action.

Note that the simulator can still generate an accepted transcript after fixing either challenge: choose $z$ and define the appropriate $a$. This does not create a single commitment answerable both ways.

## 9. Applications and interpretation

### 9.1 Identification

The protocol models challenge-response identification. A public key specifies $(\varphi,y)$; the private credential is $w$. The user demonstrates responsiveness to a fresh random challenge without directly transmitting $w$. For practical security, one chooses algebraic settings in which recovering a preimage is computationally difficult and addresses active attacks, composition, and implementation leakage.

### 9.2 Privacy-preserving credentials

The simulator theorem explains why an honest verifier's transcript cannot later serve as unique evidence that the prover participated: the verifier could have generated an identically distributed transcript alone. This deniability-like feature is useful conceptually, though real credential systems require richer statements and adversarial models.

### 9.3 Confidential computation and ledgers

Homomorphic witness relations are building blocks for proving consistency of hidden values. A participant may need to show that secret data satisfy a public algebraic relation. The present protocol isolates one linear relation; practical systems combine many such constraints and use commitments to bind hidden values across checks.

### 9.4 Hidden mathematical proofs

A mathematical proof can be treated abstractly as a witness for an efficiently checkable relation: the public input is a theorem statement, and the witness is a derivation accepted by a proof checker. General zero-knowledge results can then, under appropriate conditions and assumptions, hide the witness while certifying the relation.

However, the current homomorphism protocol cannot be identified directly with “opening a random proof step.” Revealing a randomly selected line may leak content, and checking one local line does not by itself guarantee global validity. A rigorous construction needs a commitment scheme, a local or encoded proof system with quantified soundness, and a zero-knowledge transformation that masks every opened view. Furthermore, communication polynomial only in statement length is a succinctness requirement; it does not follow solely from arithmetization or the existence of probabilistically checkable proofs. The hidden proof may be enormously longer than the statement, and suppressing that dependence requires additional machinery and assumptions.

## 10. Discussion

Three equations organize the entire protocol:

$$
z=r+[c]w,
$$

$$
a=\varphi(z)-[c]y,
$$

and

$$
w'=z_1-z_0.
$$

The first produces honest responses, the second produces simulated commitments, and the third extracts knowledge. Their compatibility is not accidental. Translation masks the witness in one view, while subtraction cancels the common mask across two views.

Perfect zero knowledge and special soundness therefore coexist without contradiction. The simulator controls the challenge before constructing its commitment. The extractor receives two accepted transcripts tied to one commitment. These are different informational situations. A single branch can be fabricated from public data; the ability to span both branches forces a witness.

The finite-group assumption enters only in the exact uniform-distribution statement. The pointwise identity and translation bijection hold for arbitrary additive commutative groups. For infinite groups, one would need a specified probability measure and a proof that translation preserves it. Finite uniform sampling avoids measure-theoretic complications and gives literal equality of transcript multisets.

The commutativity assumption provides a simple additive presentation. Closely related protocols exist in noncommutative or multiplicative settings, but equation order must then be tracked carefully. Generalizing the challenge from a bit to a larger finite field can improve the one-round knowledge error and leads toward linear-response sigma protocols.

## 11. Limitations

The theorem package has deliberately narrow scope.

First, zero knowledge is proved for the honest verifier and a fixed challenge. It does not cover arbitrary challenge-selection strategies or auxiliary-input attacks.

Second, the protocol is interactive. Turning it into a noninteractive argument by deriving challenges from hashes requires a separate model and security analysis.

Third, no computational hardness claim is made. If $\varphi$ is easy to invert, the protocol remains complete and perfectly simulatable, but the witness is not cryptographically protected by the public statement.

Fourth, single-round soundness error is only bounded by $1/2$. Independent repetition is expected to reduce this to $2^{-k}$, but a complete theorem must define the repeated transcript, adversarial strategy, and probability space.

Fifth, arbitrary proof certification is not obtained merely by treating proof lines as commitments. General proof relations and succinct communication introduce substantial additional requirements.

## 12. Future work

A first extension is to replace the Boolean challenge by a finite field. Responses of the form $z=r+cw$ permit extraction from distinct challenges by dividing their difference, provided the scalar action and invertibility conditions are explicit. This should yield an exact knowledge error reciprocal to the challenge-space size.

A second direction is probability-theoretic: express transcript equality directly as equality of probability mass functions, define sequential and parallel repetition, and prove that independent repetition reduces false-instance success from $1/2$ to $2^{-k}$.

Third, concrete instantiations in finite cyclic groups can connect the abstract witness relation to discrete logarithms and make computational assumptions explicit.

Fourth, malicious-verifier zero knowledge should be developed. The simulator must handle challenges that depend on commitments and auxiliary state rather than merely reindex a fixed-challenge random tape.

Fifth, commitment schemes should be specified through explicit hiding and binding games. Such infrastructure is necessary before any commit-and-open proof-certificate protocol can claim zero knowledge.

Finally, one can formalize propositional syntax, proof certificates, and polynomial-time verification, then connect this relation to a general zero-knowledge proof for nondeterministic polynomial time. Extending the vision to arithmetic theories requires exact encodings and careful complexity parameters. Achieving communication polynomial only in the statement length demands succinct-proof machinery beyond arithmetization and local checking alone.

## 13. Conclusion

The three-move homomorphism protocol provides a complete miniature of zero-knowledge reasoning. Honest responses always verify. Simulated responses also verify. Over finite uniform randomness, a translation of random tapes pairs every genuine transcript with an identical simulated transcript, yielding perfect honest-verifier zero knowledge. Conversely, two accepted responses to opposite challenges under one commitment expose a witness by subtraction. If no witness exists, no commitment can cover both challenges, giving single-round soundness error at most $1/2$.

The mathematical mechanism is exact and economical: homomorphic addition proves completeness, translation proves privacy, and subtraction proves knowledge. These results provide a rigorous foundation for studying richer challenge spaces, repetition, concrete hard groups, malicious verifiers, commitments, and eventually privacy-preserving certification of general computational and mathematical claims.
