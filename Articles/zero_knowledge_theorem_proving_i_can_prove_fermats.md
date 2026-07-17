# Proving You Know a Secret Without Revealing It

## A mathematical conversation with a locked door

Imagine a city built around a circular subway line. You announce that you know a sequence of stops that leads from a public station to another public station under a peculiar rule, but you refuse to reveal the sequence. How could anyone distinguish genuine knowledge from bluffing?

Zero-knowledge protocols answer that question by changing the shape of evidence. Instead of handing over the secret, the prover and verifier conduct a short randomized conversation. The verifier receives enough evidence to reject an impostor with substantial probability, yet the conversation discloses nothing that the verifier could not have generated alone.

That last clause is the startling one. Privacy does not merely mean that reconstructing the secret is computationally expensive. In a *perfect* zero-knowledge protocol, the verifier's view has exactly the same probability distribution as an artificial transcript generated without the secret. There is literally no statistical test—not even one with unlimited computing power—that distinguishes the real conversation from the imitation.

Here we develop a clean model of this phenomenon. It applies to a public homomorphism between finite commutative groups. The protocol has only three moves: commitment, challenge, response. Yet from these ingredients emerge three complementary guarantees: honest provers always succeed; simulated conversations are distributed exactly like real ones; and anyone who can answer both possible challenges has implicitly revealed enough information to reconstruct a witness.

## The hidden preimage

Let $G$ and $H$ be commutative groups written additively, and let

$$
\varphi:G\longrightarrow H
$$

be a homomorphism, meaning that $\varphi(x+x')=\varphi(x)+\varphi(x')$. A public statement consists of $\varphi$ and an element $y\in H$. A witness is an element $w\in G$ satisfying

$$
\varphi(w)=y.
$$

Thus the prover claims to know a preimage of $y$. In a concrete cryptographic setting, $G$ might be a finite cyclic group, and recovering such a preimage might encode a discrete-logarithm problem. The mathematics below does not depend on that computational assumption; it isolates the exact algebraic structure behind the conversation.

For a Boolean challenge $c\in\{0,1\}$, define the challenge term

$$
[c]w=\begin{cases}
0,&c=0,\\
w,&c=1.
\end{cases}
$$

The protocol proceeds as follows.

1. **Commitment.** The prover chooses a uniformly random $r\in G$ and sends $a=\varphi(r)$.
2. **Challenge.** The verifier chooses a random bit $c\in\{0,1\}$.
3. **Response.** The prover returns $z=r+[c]w$.
4. **Verification.** The verifier accepts exactly when

$$
\varphi(z)=a+[c]y.
$$

The commitment is a one-time mask. If the challenge is $0$, the prover opens the mask itself. If the challenge is $1$, the prover opens the mask shifted by the witness. The verifier can check either answer through the homomorphism, but sees only one of them in an ordinary run.

## Why an honest prover never fails

The first guarantee is perfect completeness.

**Perfect Completeness Theorem.** If $w$ is a valid witness, so that $\varphi(w)=y$, then every honest transcript is accepted for every random tape $r$ and either challenge bit $c$.

The proof is one line of algebra, split according to the challenge. If $c=0$, then $z=r$, and

$$
\varphi(z)=\varphi(r)=a.
$$

If $c=1$, then $z=r+w$, and

$$
\varphi(z)=\varphi(r+w)=\varphi(r)+\varphi(w)=a+y.
$$

There are no bad random choices and no probability of accidental rejection. Randomness protects privacy; it does not compromise correctness.

## The simulator: a forgery that proves privacy

Ordinary security arguments often try to list what an observer fails to learn. Zero knowledge takes a stronger route: build a simulator that creates the observer's entire view without knowing the witness.

Fix a challenge $c$. The simulator chooses a response $z\in G$ uniformly at random and works backward, defining

$$
a=\varphi(z)-[c]y.
$$

It outputs the transcript $(a,c,z)$. This transcript always passes verification because

$$
a+[c]y=\varphi(z)-[c]y+[c]y=\varphi(z).
$$

Acceptance alone is not enough. A simulator could conceivably produce accepted transcripts with the wrong statistical pattern. The decisive fact is an exact change of variables. Given a genuine random tape $r$, set

$$
z=r+[c]w.
$$

Translation by $[c]w$ is a bijection of $G$, with inverse $z\mapsto z-[c]w$. Consequently, if $r$ is uniform, then $z$ is uniform. Moreover, the simulator's commitment is

$$
\varphi(z)-[c]y
=\varphi(r+[c]w)-[c]\varphi(w)
=\varphi(r).
$$

So the simulated transcript is not merely similar to the real transcript. Under this bijective relabeling of random choices, it is point-for-point identical.

**Perfect Honest-Verifier Zero-Knowledge Theorem.** Suppose $G$ is finite and $w$ satisfies $\varphi(w)=y$. For either fixed challenge $c$, the multiset of real transcripts obtained as $r$ ranges over $G$ is exactly equal to the multiset of simulated transcripts obtained as $z$ ranges over $G$. Therefore the two uniform transcript distributions are identical.

This is information-theoretic privacy. No hardness conjecture is needed to prove it. It is called *honest-verifier* zero knowledge because the simulation fixes the challenge in the same manner as the specified verifier. A verifier that chooses challenges in a malicious, transcript-dependent way requires additional ideas.

## Two answers unlock the secret

Privacy might sound incompatible with evidence of knowledge. The resolution is that one transcript hides the witness, while two suitably related transcripts reveal it.

Suppose the same commitment $a$ has an accepted response $z_0$ to challenge $0$ and an accepted response $z_1$ to challenge $1$. Acceptance gives

$$
\varphi(z_0)=a
$$

and

$$
\varphi(z_1)=a+y.
$$

Subtracting the first equation from the second yields

$$
\varphi(z_1-z_0)=y.
$$

Thus $z_1-z_0$ is a witness.

**Special Soundness Theorem.** From accepting answers to both Boolean challenges for one common commitment, the witness $w'=z_1-z_0$ can be extracted, and it satisfies $\varphi(w')=y$.

This theorem gives the protocol its teeth. A cheating prover who prepares one commitment before seeing a uniformly random challenge faces a dilemma. If the public statement has no witness, then no commitment can possess valid answers to both challenges. At most one challenge can be covered, so a single-round impostor succeeds with probability at most $1/2$.

Repeating the protocol with independent challenges suggests an error of $2^{-k}$ after $k$ rounds: the impostor must guess every challenge. Establishing that sequential result requires an explicit repeated protocol and an independence argument; it is a natural extension rather than part of the single-round theorem proved here.

## A small numerical world

Take $G=H=\mathbb{Z}/11\mathbb{Z}$ and define $\varphi(x)=3x\pmod{11}$. Let the witness be $w=4$, so the public target is

$$
y=\varphi(4)=12\equiv1\pmod{11}.
$$

If the prover chooses $r=7$, the commitment is

$$
a=\varphi(7)=21\equiv10\pmod{11}.
$$

For challenge $0$, the response is $z_0=7$, and the verifier checks $3\cdot7\equiv10\pmod{11}$. For challenge $1$, the response is

$$
z_1=7+4\equiv0\pmod{11},
$$

and the verifier checks

$$
3\cdot0\equiv10+1\equiv0\pmod{11}.
$$

If both responses become available, extraction gives

$$
z_1-z_0\equiv0-7\equiv4\pmod{11},
$$

which recovers a valid witness.

The simulation is equally concrete. For challenge $1$, choose any response $z$, say $z=5$. The simulator sets

$$
a=3\cdot5-1\equiv3\pmod{11}.
$$

The transcript is accepted because $3\cdot5\equiv3+1\pmod{11}$. As $z$ runs through all eleven residues, these simulated transcripts match the genuine transcripts exactly after the translation $z=r+4$.

## What this says—and what it does not

The dream suggested by zero knowledge is audacious: perhaps a mathematician could certify possession of a proof without disclosing the argument. The three-move protocol captures the central paradox in a precise setting, but it is not by itself a protocol for arbitrary theorems or for Peano Arithmetic. Its secret is a group element, its public claim is a homomorphic preimage relation, and its privacy theorem assumes the prescribed challenge behavior.

Moving from hidden group witnesses to hidden mathematical proofs requires several additional layers: an encoding of proofs as finite witnesses, an efficiently checkable relation, commitment schemes with rigorously proved hiding and binding properties, and a general zero-knowledge compiler. Merely revealing a random line of a committed proof is not automatically safe; a single line could contain the crucial idea or even the secret itself. Likewise, arithmetizing proofs and invoking probabilistically checkable proofs does not alone guarantee communication polynomial only in the theorem statement rather than in the hidden proof. Succinctness is a separate demand.

This distinction is not a disappointment. It is what makes the present protocol valuable: every promise is visible in the algebra. Completeness comes from homomorphic addition. Privacy comes from a bijection of random tapes. Knowledge comes from subtracting two accepted equations. Soundness comes from the impossibility of answering both challenges without creating a witness.

## The broader landscape

The same pattern appears throughout privacy-preserving technology. Identification systems let a user demonstrate possession of a credential without sending the credential. Confidential transactions can establish conservation laws without exposing amounts. Distributed systems can authenticate participants while reducing the information placed on public ledgers. In each case, the goal is not secrecy instead of trust, but trust engineered to consume as little information as possible.

The protocol also offers a conceptual lesson for mathematics. Evidence need not be a static object handed from one person to another. It can be an interaction whose randomized structure separates three roles: truth, knowledge, and disclosure. The verifier becomes confident not because the witness was displayed, but because a prover who could consistently survive incompatible challenges would necessarily determine one.

That is the locked door at the heart of zero knowledge. One view can be simulated and therefore reveals nothing. Two views fit together like pieces of a key and expose the witness. Between those facts lies a rigorous form of selective revelation: enough structure to justify confidence, but no more information than the protocol intends to release.
