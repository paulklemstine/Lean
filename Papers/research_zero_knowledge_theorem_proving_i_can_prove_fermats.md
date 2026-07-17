# Affine Privacy–Extraction Duality in Finite-Group Identification Protocols

## Abstract

We study a three-move identification protocol built from an additive homomorphism $L:G\to H$ between finite commutative groups. The public statement is a target $y\in H$, and a witness is a preimage $w\in G$ satisfying $L(w)=y$. After committing with $a=L(r)$ for uniform $r\in G$, the prover answers a Boolean challenge $c$ with $z=r+cw$; the verifier checks $L(z)=a+cy$. We establish exact honest-verifier perfect zero knowledge by an affine reindexing of random tapes: translation $r\mapsto r+cw$ is a permutation, and it identifies the real transcript multiset with the simulator’s transcript multiset point by point. It follows that all witnesses for one public statement induce identical verifier views and that every transcript has equal real and simulated multiplicity. In the converse direction, two accepting responses to opposite challenges at the same commitment yield a witness $z_1-z_0$. These facts combine into an affine privacy–extraction duality: translation hides a witness in one randomized view, while subtraction extracts a witness from two correlated views. We provide algorithms, finite examples, applications, and a careful account of why this result does not imply that arbitrary long mathematical proofs admit statement-polynomial zero-knowledge certificates through random inspection of raw proof steps.

## 1. Introduction

Zero-knowledge protocols separate conviction from disclosure. A prover seeks to convince a verifier that a public statement has a witness, while revealing no information about that witness beyond its existence. At the same time, a proof of knowledge should make successful behavior meaningful: an entity capable of answering the verifier’s challenges should possess enough information to recover a witness.

Privacy and extraction may initially appear incompatible. If a transcript reveals nothing about a witness, how can successful transcripts certify knowledge? The resolution is that the two properties concern different data. Privacy concerns the distribution of one ordinary randomized conversation. Extraction concerns multiple correlated conversations that reuse a commitment while receiving distinct challenges.

This paper isolates that distinction in a finite additive setting. Let $G$ and $H$ be finite commutative groups and $L:G\to H$ an additive homomorphism. The protocol’s witness relation is the preimage equation $L(w)=y$. Its two central mechanisms are elementary:

- adding a fixed group element permutes $G$ and therefore preserves its uniform distribution;
- subtracting two responses with common random origin cancels that origin.

Despite their simplicity, these mechanisms give exact statements. The real and simulated transcript distributions are not merely computationally indistinguishable or statistically close; they coincide exactly. Likewise, extraction is not probabilistic once opposite accepting challenges at one commitment are available; subtraction deterministically yields a witness.

The main contribution is a unified theorem stating both phenomena. The same affine expression $r+cw$ acts as a measure-preserving reindexing for privacy and as a difference equation for extraction. We call this the affine privacy–extraction duality.

The paper also delineates scope. The protocol is an idealized identification scheme, not a complete construction for certifying arbitrary mathematical theorems. In particular, committing to every step of a raw proof and opening one random step has poor soundness against sparse errors and may leak proof content. General succinct zero-knowledge certification requires additional encoding, commitment, soundness-amplification, and simulation machinery.

## 2. Algebraic setting and protocol

### 2.1 Public statements and witnesses

Throughout, $G$ and $H$ are finite commutative groups written additively. Their identity elements are denoted by $0$. Let

$$
L:G\longrightarrow H
$$

be an additive homomorphism, so that $L(x+x')=L(x)+L(x')$ and $L(0)=0$.

**Definition 2.1 (Public statement).** A public statement is a pair $(L,y)$ consisting of an additive homomorphism $L:G\to H$ and a target $y\in H$.

**Definition 2.2 (Witness).** An element $w\in G$ is a witness for $(L,y)$ if

$$
L(w)=y.
$$

The relation asserts that $y$ lies in the image of $L$. There may be one witness or many. If $L$ has a nontrivial kernel, then $w$ and $w+k$ are both witnesses whenever $k\in\ker L$.

### 2.2 Three-move interaction

The protocol proceeds as follows.

1. **Commitment.** The prover samples $r$ uniformly from $G$ and sends
   $$
   a=L(r).
   $$
2. **Challenge.** The verifier selects $c\in\{0,1\}$.
3. **Response.** The prover sends
   $$
   z=r+cw,
   $$
   where $cw=0$ for $c=0$ and $cw=w$ for $c=1$.

**Definition 2.3 (Transcript).** A public transcript is a triple $(a,c,z)\in H\times\{0,1\}\times G$.

**Definition 2.4 (Acceptance).** The verifier accepts $(a,c,z)$ if and only if

$$
L(z)=a+cy.
$$

**Theorem 2.5 (Perfect completeness).** If $w$ is a witness and the prover follows the protocol, the verifier accepts for every random tape $r$ and either challenge $c$.

**Proof sketch.** Since $L(w)=y$ and $L$ is additive,

$$
L(z)=L(r+cw)=L(r)+cL(w)=a+cy.
$$

Thus the acceptance equation holds identically. $\square$

## 3. Exact simulation and perfect privacy

### 3.1 Simulator

A zero-knowledge argument should not rest on the vague claim that a transcript “looks random.” It should provide a simulator that generates the verifier’s view without knowing a witness.

**Definition 3.1 (Fixed-challenge simulator).** Given the public statement $(L,y)$ and a fixed challenge $c$, the simulator samples $z$ uniformly from $G$ and sets

$$
a=L(z)-cy.
$$

It outputs $(a,c,z)$.

**Lemma 3.2 (Simulator support is valid).** Every transcript output by the simulator satisfies the verifier’s acceptance equation.

**Proof sketch.** By construction,

$$
a+cy=L(z)-cy+cy=L(z).
$$

Hence the transcript is accepted. $\square$

Validity alone is insufficient: a simulator that emits only an unusual subset of accepting conversations could still be distinguishable. We therefore compare complete transcript distributions.

### 3.2 Translation as a permutation

For $c\in\{0,1\}$ and $w\in G$, define

$$
T_{c,w}:G\to G,\qquad T_{c,w}(r)=r+cw.
$$

**Lemma 3.3 (Translation permutation).** The map $T_{c,w}$ is a bijection with inverse

$$
T_{c,w}^{-1}(z)=z-cw.
$$

**Proof sketch.** Direct cancellation gives $(r+cw)-cw=r$ and $(z-cw)+cw=z$. Therefore translation permutes the random-tape space. $\square$

Because $G$ is finite, a bijection preserves the uniform distribution exactly. This elementary symmetry is the entire privacy mechanism.

### 3.3 Pointwise correspondence

**Lemma 3.4 (Affine transcript correspondence).** Let $w$ satisfy $L(w)=y$. For every $r\in G$ and fixed $c\in\{0,1\}$, the real transcript generated from $r$ equals the simulated transcript generated from $z=T_{c,w}(r)$.

**Proof sketch.** In both transcripts the response is $z=r+cw$ and the challenge is $c$. It remains to compare commitments. The simulator’s commitment is

$$
L(z)-cy=L(r+cw)-cy=L(r)+cL(w)-cy=L(r),
$$

which is the real commitment. $\square$

This is stronger than a counting argument after the fact: it exhibits an explicit bijection pairing every real random tape with a simulated choice.

### 3.4 Perfect zero knowledge

For fixed $c$, let $\mathsf{Real}_{w,c}$ denote the random transcript obtained by choosing uniform $r\in G$ and returning

$$
(L(r),c,r+cw).
$$

Let $\mathsf{Sim}_{c}$ denote the transcript obtained by choosing uniform $z\in G$ and returning

$$
(L(z)-cy,c,z).
$$

**Theorem 3.5 (Exact honest-verifier perfect zero knowledge).** For every valid witness $w$ and every fixed challenge $c$, the distributions $\mathsf{Real}_{w,c}$ and $\mathsf{Sim}_{c}$ are equal.

Equivalently, their transcript multisets coincide, including multiplicities.

**Proof sketch.** Reindex the real experiment by the bijection $z=T_{c,w}(r)$. Lemma 3.4 shows that paired random choices produce identical transcripts. Since a bijection preserves uniform weights, the induced distributions are exactly equal. $\square$

The qualification “fixed challenge” is important. The simulator is given $c$ before constructing $a$. This proves honest-verifier zero knowledge for each challenge branch; it does not by itself provide simulation against a verifier that chooses $c$ adaptively after observing $a$.

**Corollary 3.6 (Transcript multiplicity equality).** For every transcript $t$, valid witness $w$, and fixed challenge $c$, the number of random tapes producing $t$ in the real experiment equals the number of simulator choices producing $t$.

**Proof sketch.** Equal finite multisets assign the same multiplicity to every element. $\square$

**Corollary 3.7 (Witness indistinguishability).** If $w_1$ and $w_2$ are both witnesses for the same public statement, then for each fixed challenge $c$,

$$
\mathsf{Real}_{w_1,c}=\mathsf{Real}_{w_2,c}.
$$

**Proof sketch.** By Theorem 3.5, each real distribution equals the same witness-free simulated distribution $\mathsf{Sim}_{c}$. Transitivity yields the claim. $\square$

This is perfect witness independence. Even an unbounded observer cannot infer which valid witness generated a transcript under the model’s assumptions.

## 4. Extraction and special soundness

The same response equation has an opposite use when two conversations share a commitment.

**Theorem 4.1 (Special soundness).** Suppose $(a,0,z_0)$ and $(a,1,z_1)$ are both accepting transcripts for the same public statement $(L,y)$ and the same commitment $a$. Then

$$
w^*=z_1-z_0
$$

is a witness; that is, $L(w^*)=y$.

**Proof sketch.** Acceptance gives

$$
L(z_0)=a
$$

and

$$
L(z_1)=a+y.
$$

Using additivity and subtracting,

$$
L(z_1-z_0)=L(z_1)-L(z_0)=(a+y)-a=y.
$$

Therefore $w^*$ is a valid preimage of $y$. $\square$

Special soundness is a deterministic implication about transcript pairs. It does not assert that a verifier in one ordinary run receives both responses. Instead, it explains why a prover capable of answering both challenges for one commitment embodies witness information.

**Algorithm 4.2 (Witness extraction).** Given two accepting transcripts with common commitment and opposite challenges, return $z_1-z_0$.

The algorithm uses one group subtraction and, if desired, one evaluation of $L$ to verify the result. Under unit-cost group operations its extraction cost is $O(1)$; under bit complexity it is the cost of one group subtraction, plus optional homomorphism evaluation.

## 5. The affine duality theorem

We now combine privacy and extraction.

**Theorem 5.1 (Affine privacy–extraction duality).** Let $G$ and $H$ be finite commutative groups, $L:G\to H$ an additive homomorphism, and $y\in H$. Suppose $w_1,w_2\in G$ satisfy $L(w_1)=L(w_2)=y$. Then:

1. for either fixed Boolean challenge $c$, the transcript distributions generated using $w_1$ and $w_2$ are exactly equal; and
2. if $(a,0,z_0)$ and $(a,1,z_1)$ are accepting transcripts with the same commitment, then $z_1-z_0$ is a witness for $y$.

**Proof sketch.** The first conclusion is Corollary 3.7, obtained by translating uniform random tapes and identifying both real experiments with the same simulator. The second is Theorem 4.1, obtained by subtracting the two acceptance equations. $\square$

The theorem can be summarized by the affine identity

$$
z=r+cw.
$$

For a single fixed $c$, the map $r\mapsto z$ is a permutation and hides $w$ within a uniform response. Across $c=0$ and $c=1$ with common $r$, the difference of responses is

$$
(r+w)-r=w.
$$

Privacy and extraction therefore differ not in the underlying algebra but in the observer’s access pattern. One view is invariant under translation; two correlated views expose a finite difference.

## 6. Numerical examples and algorithms

### 6.1 Cyclic-group example

Let $G=H=\mathbb Z/11\mathbb Z$ and define $L(x)=3x$. Choose target $y=7$. Since

$$
3\cdot6\equiv7\pmod{11},
$$

$w=6$ is a witness. For random tape $r=4$, the commitment is $a=3r\equiv1$. The two responses are

$$
z_0=4,\qquad z_1=4+6\equiv10\pmod{11}.
$$

They verify because

$$
3z_0\equiv1=a
$$

and

$$
3z_1\equiv8\equiv a+y\pmod{11}.
$$

Extraction returns $z_1-z_0\equiv6$, a valid witness.

For challenge $1$, the real transcript associated with $r$ is

$$
(3r,1,r+6).
$$

Set $z=r+6$. The simulator emits

$$
(3z-7,1,z).
$$

Since $3(r+6)-7\equiv3r$, these triples agree. As $r$ runs over all residues, so does $z$, proving equality of the enumerated transcript multisets.

### 6.2 Multiple witnesses

Take $G=\mathbb Z/12\mathbb Z$, $H=\mathbb Z/6\mathbb Z$, and $L(x)=x\bmod6$. For target $y=2$, both $w_1=2$ and $w_2=8$ are witnesses. Translation by either witness permutes the twelve random tapes. Thus challenge-$1$ transcript collections are identical even though the witnesses differ by the nonzero kernel element $6$.

This example makes witness indistinguishability concrete. The verifier learns that the target has a preimage but cannot determine which representative of the coset the prover used.

### 6.3 Enumeration algorithm

For cyclic groups, exact privacy can be checked by exhaustive transcript counting.

**Algorithm 6.1 (Exact transcript multiset comparison).** Given moduli, a linear map, target, witness, and challenge, enumerate every random tape $r$, compute the real transcript, enumerate every response $z$, compute the simulated transcript, count both collections, and compare their frequency tables.

If $|G|=N$ and group operations are constant-time, enumeration takes $O(N)$ time and $O(N)$ storage in the worst case. The method is pedagogical rather than necessary for the theorem: the bijection proves equality for every finite group without exhaustive search.

### 6.4 Extraction audit algorithm

**Algorithm 6.2 (Opposite-challenge extraction audit).** Check that two transcripts share a commitment, carry challenges $0$ and $1$, and satisfy their acceptance equations. If so, output $z_1-z_0$ and verify $L(z_1-z_0)=y$.

The audit separates syntactic preconditions from algebraic extraction. Rejecting malformed or nonaccepting pairs prevents an invalid pair from being misrepresented as evidence of knowledge.

## 7. Applications and interpretation

### 7.1 Identification

The protocol models a prover demonstrating knowledge of a preimage. The verifier sees an accepting conversation, while a simulator can reproduce the fixed-challenge view without a witness. Special soundness supplies the structural basis for a knowledge argument: answering both challenge branches at one commitment is enough to recover a preimage.

### 7.2 Witness privacy

When $L$ has many preimages, the theorem guarantees exact independence from the chosen witness. This matters in settings where possession of any credential should be demonstrated without revealing which credential or representative is used.

### 7.3 Symmetry as noninterference

The privacy proof is an instance of a general principle: a secret-dependent transformation that acts as a measure-preserving permutation of randomness can leave the observable distribution unchanged. The secret affects sample labels but not their distribution. This principle appears in one-time masking, randomized encodings, and coupling arguments.

### 7.4 Correlation as recoverability

Extraction illustrates the complementary principle that reuse of randomness changes the information structure. Each value $r$ and $r+w$ is individually uniform when $r$ is uniform, but the pair determines $w$ by subtraction. Thus claims of privacy must specify not only marginal distributions but also whether random coins are reused and which joint observations are exposed.

## 8. Limits of naive theorem-proof certification

One motivating vision is to certify possession of a proof of a theorem without disclosing proof steps. The present protocol clarifies a useful algebraic core but does not establish that broad goal.

Consider a naive proposal: commit separately to every line of an $n$-line purported proof, let the verifier request one random line, and show that the opened line follows from previous lines or axioms. If exactly one line is invalid, a uniform query detects the error with probability only $1/n$. After $k$ independent queries, the probability of missing that error is

$$
\left(1-\frac1n\right)^k,
$$

not generally $2^{-k}$. To make the miss probability small, the number of repetitions must depend on $n$ unless the proof is encoded so that any invalid argument creates a constant fraction of locally detectable inconsistencies.

Privacy also does not follow from opening only one line. A proof line may reveal a crucial lemma, construction, or tactic. Zero knowledge requires a simulator capable of reproducing the verifier’s whole view without the hidden proof. Merely limiting disclosure is not the same as proving that the disclosure carries no additional information.

A claim that communication is polynomial only in the theorem statement raises a further issue. The shortest proof may be much longer than the statement, and unrestricted provability does not by itself provide a polynomial bound relating the two. Succinct argument systems can make verification communication small under explicit models and assumptions, but such a theorem requires precise complexity parameters and cannot be inferred solely from arithmetizing proofs.

A complete theorem-certification system would need at least:

1. a precise proof relation and encoding;
2. a binding and hiding commitment mechanism;
3. a locally testable encoding with robust soundness gap;
4. a simulator for all permitted verifier behavior;
5. a knowledge extractor or suitable soundness definition;
6. explicit computational assumptions and communication parameters.

The affine protocol can serve as one component or conceptual model within such a construction, but it does not replace these layers.

## 9. Extensions and future work

The exact finite result suggests several extensions.

First, transcript multiset equality can be recast as equality of probability mass functions and then as statistical distance zero. This gives a standard probabilistic interface while preserving the exact theorem.

Second, malicious-verifier zero knowledge requires handling challenge selection after commitment. A simulator may need rewinding or a stronger commitment abstraction. The fixed-challenge simulator cannot simply be relabeled as an adaptive simulator because it constructs the commitment using the challenge.

Third, parallel repetition can use challenge vectors $\mathbf c\in\{0,1\}^k$. One seeks completeness, joint simulation, and a knowledge-soundness error near $2^{-k}$ under appropriate independence and extraction conditions. Care is needed: special soundness for each coordinate does not automatically settle every concurrent or adaptive composition.

Fourth, an explicit commitment layer should distinguish perfect, statistical, and computational properties. The current commitment $L(r)$ is an algebraic message, not a general cryptographic commitment primitive with independently stated binding and hiding guarantees.

Fifth, propositional validity may be reduced to a suitable witness relation, but claims of polynomial-size witnesses encounter standard complexity barriers. The reduction and its size bounds must be stated rather than assumed.

Finally, proof encodings with local tests require a robust soundness gap before random queries become effective. A simulator must also handle local openings without leaking encoded proof information. These requirements identify the missing bridge from the present affine core to private certification of general mathematical proofs.

## 10. Discussion

The sharpest feature of the result is its exactness. No asymptotic parameter or hardness assumption is needed for the finite-group privacy statement. Uniformity plus translation symmetry yields literal equality of transcript distributions. This makes the model useful for understanding what a simulation proof must accomplish.

The model also demonstrates why marginal privacy can coexist with extraction. Suppose $R$ is uniform on $G$. Then both $R$ and $R+w$ are uniform, independently of $w$ at the level of their separate distributions. But the joint pair $(R,R+w)$ determines $w$. The distinction between a marginal and a coupling is therefore not peripheral; it is the logical boundary between privacy and knowledge recovery.

The Boolean challenge is essential to the simple extraction formula. Challenge $0$ provides the baseline response, while challenge $1$ provides its translated counterpart. More general challenge sets can support analogous linear extraction when challenge differences are invertible in an appropriate scalar structure, but such generalizations require more algebra than an additive group alone.

Finiteness is used for the uniform distribution on all of $G$ and for exact multiset counting. The pointwise correspondence itself remains algebraically valid beyond finite groups. Extensions to compact groups could use Haar measure, while discrete infinite groups would require chosen random-tape distributions and a careful analysis of whether translation preserves them.

## 11. Conclusion

A finite-group identification protocol exposes a concise duality. Given a public additive map $L:G\to H$ and target $y$, a witness $w$ satisfies $L(w)=y$. The response $z=r+cw$ is perfectly private for a fixed challenge because translation by $cw$ permutes uniform random tapes. A simulator chooses $z$ first and sets $a=L(z)-cy$, producing exactly the real transcript distribution. Consequently, transcript multiplicities are equal and the verifier’s view is independent of the chosen valid witness.

Yet two accepting responses to opposite challenges at one commitment yield $z_1-z_0$, whose image under $L$ is $y$. The shared random component cancels. Translation and subtraction are therefore the privacy and extraction directions of one affine law.

This duality supplies a rigorous conceptual foundation for proving knowledge without disclosing a witness in the stated model. It also marks the boundary of the result: private certification of arbitrary mathematical proofs needs robust encodings, commitments, adaptive simulation, and carefully parameterized succinctness claims. Within its scope, however, the principle is exact and memorable: translation hides; subtraction extracts.
