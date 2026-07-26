# The Sealed Proof: What It Would Take to Verify a Theorem Without Seeing Why

Imagine receiving a message containing only the final line of an extraordinary theorem, followed by a short digital conversation. At the end of the conversation you are convinced that the sender possesses a valid derivation, yet you have learned none of its decisive ideas. The situation resembles a sealed-bid auction: validity becomes public while strategy remains private.

This is the promise of zero-knowledge theorem proving. It is also easy to oversell. A tempting protocol says: hide every line of a proof, let a verifier choose a random line, and reveal only that line together with evidence that it is locally correct. Repeat the procedure until cheating seems implausible. The proposal has an appealing simplicity, but three different questions are entangled inside it.

First, does opening a random line conceal the witness—the proof itself? Second, how rapidly does repetition suppress the chance that an invalid proof slips through? Third, can the hidden lines be committed in a way that actually conceals their contents? The answers are unexpectedly sharp. Random opening is generally not private. Repetition obeys an exact geometric law, but not automatically the often-quoted binary law. Uniform additive masking is perfectly hiding, although hiding alone does not make the whole protocol sound or zero knowledge.

## A clean model of privacy

Fix a public statement $s$. A witness $w$ is a finite sequence of $n$ symbols, written $w(0),\ldots,w(n-1)$, and a validity relation specifies which witnesses establish $s$. If the verifier challenges coordinate $i$, the simplest possible view is just the opened value $w(i)$.

Call this view **perfectly witness-private** if any two valid witnesses for the same statement produce exactly the same view. This definition demands more than concealing most information: the verifier's observation must be independent of which valid witness the prover used.

The first result completely characterizes privacy at one coordinate.

**Coordinate Privacy Theorem.** Opening coordinate $i$ is perfectly witness-private if and only if every pair of valid witnesses for each public statement agrees at coordinate $i$.

The reason is immediate but consequential. The view is the coordinate itself, so two witnesses induce the same view precisely when their values there coincide. Applying this observation to every possible challenge gives a global characterization.

**All-Openings Characterization.** If every coordinate may be challenged, then all coordinate openings are perfectly witness-private if and only if each public statement has at most one valid witness.

Indeed, privacy at all coordinates forces two valid witnesses to agree everywhere, hence to be identical. Conversely, uniqueness makes every view identical because there is no alternative witness to distinguish.

This theorem exposes the flaw in the slogan “the verifier sees only one random line.” A tiny disclosure can still be a disclosure. Randomness in the choice of the line does not erase the information carried by the line, because the challenge index is part of the transcript. Consider the smallest example: one public statement has two valid one-bit witnesses, one containing $0$ and the other $1$. Opening the sole coordinate reveals the witness completely. The statement remains valid in either case, yet the verifier learns which witness was used.

For mathematical proofs, multiple derivations are the rule rather than the exception. Two proofs can differ in notation, intermediate lemmas, order of argument, or the central creative idea. Raw line opening therefore cannot generally support the strongest privacy claim.

## The arithmetic of catching a cheat

Privacy is only half the story. Suppose there are $n$ possible challenges and at most $e$ of them let an invalid certificate pass. In one round the acceptance probability is at most

$$
\frac{e}{n}.
$$

If $k$ challenges are sampled independently and every round must pass, then accepting challenge vectors form a Cartesian product. Their count is at most $e^k$ out of $n^k$ possible vectors. This yields the exact amplification theorem.

**Independent Repetition Theorem.** If no more than $e$ of $n$ challenges accept in each round, the probability that all $k$ independent rounds accept is at most

$$
\left(\frac{e}{n}\right)^k.
$$

This is genuine exponential decay, but its base matters. The popular bound $2^{-k}$ follows only under the additional half-soundness condition $2e\le n$, meaning that one round catches cheating with probability at least one half.

Now consider a proof with exactly one defective line. Then $e=n-1$, and its escape probability is

$$
\left(\frac{n-1}{n}\right)^k.
$$

With four possible checks this becomes $(3/4)^k$. For every positive $k$,

$$
\left(\frac12\right)^k<\left(\frac34\right)^k.
$$

The difference is not cosmetic. At $k=10$, binary decay predicts about $0.00098$, whereas the actual one-bad-line escape probability is about $0.0563$—more than fifty times larger.

There is an even stronger warning.

**No Fixed-Repetition Half-Bound.** For every nonnegative integer $k$, a certificate with $2k+2$ possible checks and only one bad location has escape probability greater than one half after $k$ rounds:

$$
\frac12<\left(\frac{2k+1}{2k+2}\right)^k.
$$

Thus no fixed number of raw line checks gives a statement-size-independent half-error guarantee. When a single bad location is hidden among many good ones, the verifier must make a number of queries that grows with the challenge space. To obtain error at most $2^{-\lambda}$ from one bad line among $n$, one needs roughly $n\lambda\log 2$ independent checks, not merely $\lambda$ checks.

This is why locally testable proof encodings matter. A sophisticated encoding spreads a single logical defect into many detectable local inconsistencies. If a constant fraction of local tests reject every invalid encoded proof, then the base $e/n$ stays bounded away from $1$, and a number of repetitions proportional to the security parameter is enough. Raw derivations do not automatically have that property.

## A commitment that really hides

The privacy failure of openings should not obscure a positive result: it is possible to hide an individual value perfectly. Work modulo a positive integer $q$. Let a secret be $s\in\mathbb Z/q\mathbb Z$, choose a mask $r$ uniformly at random from the same finite group, and publish

$$
C=s+r\pmod q.
$$

For any fixed $s$, addition by $s$ permutes the group. Consequently $C$ is uniform, regardless of the secret.

**Uniform Masking Theorem.** For every secret $s\in\mathbb Z/q\mathbb Z$, the distribution of $s+r$ with uniform $r$ is exactly uniform on $\mathbb Z/q\mathbb Z$.

An immediate corollary is perfect hiding.

**Perfect Hiding Theorem.** For any two secrets $s$ and $t$, the commitment distributions $s+r$ and $t+r$ are identical when $r$ is uniform.

There is no approximation and no unproved computational assumption here. Every observed commitment has exactly one compatible mask for each possible secret. Before an opening, the commitment contains no statistical evidence favoring one secret over another.

But a one-time pad is not a complete commitment scheme. Perfect hiding says the verifier cannot read the secret. Binding asks whether the prover can later open the same published value as two different secrets. With additive masking alone, the answer is yes: for any desired opening $t$, choose the corresponding mask $C-t$. Hiding and binding are distinct requirements, and a useful protocol needs both in compatible security models.

Likewise, opening a commitment reveals its plaintext. Perfectly hiding unopened lines does not prove that the opened local constraints reveal nothing about the global witness. A full zero-knowledge argument needs a simulator: an algorithm able to generate a transcript with the same distribution as the verifier’s real view without access to the witness. The coordinate characterization shows exactly why such simulation cannot be obtained merely by declaring the other coordinates hidden.

## From a seductive sketch to a credible architecture

The corrected architecture has several layers. A proof must first be transformed into a locally testable encoding in which every false claim causes a substantial fraction of local checks to fail. The prover must then commit to one global encoding using a binding structure, so answers to different challenges cannot come from inconsistent imaginary proofs. The values and openings must be arranged so that the verifier’s transcript can be simulated without the witness. Finally, repetition must be analyzed using the actual one-round rejection probability.

These layers correspond to different guarantees:

1. **Local testability** supplies a constant soundness gap.
2. **Binding** ties all answers to one certificate.
3. **Hiding and simulation** protect the witness.
4. **Independent repetition** converts the one-round gap into geometric error reduction.

Only after these pieces are present does the grand vision become plausible: certifying a difficult theorem while withholding its proof strategy. General results from probabilistically checkable proofs and cryptographic zero knowledge suggest routes toward that vision, but they do not justify the raw-step protocol by themselves. In particular, communication polynomial only in the theorem statement, independent of the original derivation length, requires a precise encoding theorem and careful accounting of proof length, query complexity, setup assumptions, and prover resources.

The deepest lesson is methodological. Cryptographic protocols often sound convincing when described as stories: “commit, challenge, open, repeat.” Mathematics forces us to ask what each verb guarantees. Opening can leak. Repetition amplifies only the gap already present. Hiding need not bind. A protocol becomes trustworthy not when its story is intuitive, but when privacy, soundness, and commitment security are separated and quantified.

A sealed mathematical proof remains a compelling ambition. The path to it is not a single clever curtain placed over an ordinary derivation. It is an engineered object in which errors are dispersed, commitments are globally consistent, transcripts are simulatable, and probabilities are counted exactly. That more careful vision is less magical than the slogan—and far more powerful.