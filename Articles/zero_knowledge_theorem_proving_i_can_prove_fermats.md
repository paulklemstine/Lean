# The Sealed Proof: What It Takes to Reveal That a Theorem Is True Without Revealing Why

Imagine that a mathematician announces a spectacular theorem but refuses to show the argument. Instead, she offers an unusual bargain: she will convince a skeptical referee that she possesses a valid proof while revealing nothing about the proof itself. The referee may ask carefully controlled questions, but should learn no lemma, trick, intermediate construction, or strategic idea beyond the bare fact that a valid proof exists.

This is the mathematical analogue of a sealed-bid auction. A bidder can establish that a bid obeys the rules without exposing its amount. A password system can establish that a user knows a secret without transmitting the secret. Could proof itself be treated in the same way?

The idea belongs to **zero-knowledge cryptography**, where truth and explanation are deliberately separated. Yet a tempting protocol—commit to every line and open randomly requested lines—contains two subtle failures. One concerns privacy: an opened line can leak the witness. The other concerns soundness: checking a random location is weak when only a few locations are wrong. Understanding these failures reveals what a genuine zero-knowledge proof of mathematical knowledge must accomplish.

## Statements, witnesses, and views

A public statement is something both parties know, such as “this graph has a three-coloring” or “this formula is satisfiable.” A **witness** is private data establishing the statement, such as a particular coloring or satisfying assignment. For theorem proving, the statement could be the theorem together with a fixed deductive system, and the witness could be a derivation.

A verifier does not necessarily see the witness. It sees a **view**: the complete transcript available during the interaction, including challenges, answers, and public randomness. In the strongest information-theoretic sense, a protocol has perfect witness privacy if any two valid witnesses for the same statement produce exactly the same verifier view—or, in a randomized protocol, exactly the same distribution of views.

Consider a witness with $n$ coordinates,

$$
w=(w_0,w_1,\ldots,w_{n-1}).
$$

Suppose the verifier chooses an index $i$ and receives the raw value $w_i$. The first result is an exact characterization:

**Single-Opening Privacy Theorem.** Opening coordinate $i$ is perfectly witness-private if and only if every two valid witnesses for the same public statement agree at coordinate $i$.

The reason is immediate but decisive. The verifier’s view is precisely the opened value. If valid witnesses $w$ and $w'$ satisfy $w_i\ne w'_i$, their views differ, so the transcript reveals which witness was used. Conversely, if every valid witness has the same value at $i$, the opening cannot distinguish them.

Randomizing the index does not erase this problem, because the verifier knows which index was requested. Requiring privacy for every possible opening gives an even sharper conclusion:

**All-Openings Privacy Theorem.** Every raw coordinate opening is perfectly witness-private if and only if each public statement has at most one valid witness, up to equality of all coordinates.

Indeed, privacy at every coordinate forces two valid witnesses to agree coordinate by coordinate, hence to be identical. The converse is automatic. Thus the naive protocol’s privacy is not a generic consequence of commitments or random challenges. It is essentially a uniqueness condition.

## The one-bit alarm bell

The smallest counterexample is also the clearest. Let the public statement accept either one-bit witness. One valid witness is $0$ and another is $1$. If the protocol opens that bit, the verifier learns it exactly. There is no complicated attack, no need to combine many transcripts, and no computational ingenuity. The message itself is the leak.

A commitment can hide unopened coordinates, but it does not make an opened coordinate harmless. Think of a row of sealed envelopes. Sealing the envelopes protects those that remain closed. It says nothing about the privacy of the letter in an envelope that is opened.

This distinction matters in mathematical practice. Two proofs of the same theorem may differ at almost every line. Opening even one raw line can reveal whether the author used algebraic geometry or analytic number theory, whether a certain auxiliary lemma appears, or whether the proof follows one rival strategy rather than another. Repetition compounds the exposure; it does not repair it.

## Why one bad line is hard to catch

Privacy is only half the story. The verifier must also reject false or malformed evidence with high probability. Suppose there are $n$ equally likely checks and exactly one detects the defect. One round misses the defect with probability

$$
1-\frac{1}{n}=\frac{n-1}{n}.
$$

After $k$ independent rounds, the verifier accepts falsely precisely when every round misses the bad location. The exact false-acceptance probability is

$$
\left(\frac{n-1}{n}\right)^k.
$$

This formula overturns a common but unjustified claim that $k$ repetitions automatically produce error $2^{-k}$. With four possible checks, the true error is

$$
\left(\frac{3}{4}\right)^k,
$$

which is strictly larger than

$$
\left(\frac{1}{2}\right)^k
$$

for every positive $k$. Ten checks give about $5.63\%$ false acceptance under the first formula, compared with less than $0.1\%$ under the second. The difference is not cosmetic.

There is a stronger size-dependence obstruction. For any fixed repetition count $k$, choose $n=2k+2$. Then

$$
\left(\frac{n-1}{n}\right)^k
=
\left(1-\frac{1}{2k+2}\right)^k
>
\frac{1}{2}.
$$

**No-Fixed-Repetition Theorem.** If a malformed witness differs from an acceptable one in only a single detectable location, no fixed number $k$ of random coordinate checks guarantees false-acceptance probability at most $1/2$ independently of witness length.

One way to see the inequality is Bernoulli’s estimate: for $0\le x\le1$,

$$
(1-x)^k\ge 1-kx.
$$

Taking $x=1/(2k+2)$ gives a lower bound greater than $1/2$.

## Amplification needs something to amplify

Repetition is still powerful—but only after a genuine one-round bound has been established.

**Soundness Amplification Theorem.** If one execution has false-acceptance probability $p$ with $0\le p\le1/2$, then $k$ independent executions all accept falsely with probability $p^k$, and therefore

$$
p^k\le\left(\frac12\right)^k=2^{-k}.
$$

The theorem is elementary: raising nonnegative numbers to a natural power preserves their order. Its lesson is methodological. Repetition multiplies an existing error bound; it does not manufacture the bound. If one round has error $1-1/n$, then repetition yields $(1-1/n)^k$, not $2^{-k}$.

Modern probabilistic proof systems solve this by encoding a proof so that false claims are not merely one line away from passing. A robust encoding spreads inconsistency across many locations. If every false object fails a constant fraction of possible checks, then a random query catches cheating with constant probability. That distance property—not random sampling by itself—is the engine of constant soundness.

## A bit of privacy done correctly

The negative results do not say that private verification is impossible. They identify missing ingredients. The smallest positive model is the Boolean one-time pad.

Let a secret bit be $m$ and choose an independent uniform random bit $r$. Publish the masked bit

$$
c=m\oplus r,
$$

where $\oplus$ denotes exclusive OR. For each fixed message $m$ and each possible ciphertext $c$, exactly one randomness bit satisfies $m\oplus r=c$. Because $r$ is uniform, both ciphertexts occur with probability $1/2$, regardless of $m$.

**Uniform-Masking Privacy Theorem.** For either secret bit and either observed ciphertext, the number of random masks producing that ciphertext is exactly one. Consequently the ciphertext distribution is identical for secret $0$ and secret $1$.

The mask is also correct to open:

$$
(m\oplus r)\oplus r=m.
$$

This works because $r\oplus r=0$. Randomization has transformed a witness-dependent value into a message-independent transcript distribution while retaining recoverability for someone who knows the mask.

The example is tiny, but it captures the essential difference between hiding and merely selecting. Choosing a random coordinate determines *which* secret-dependent value is exposed. Masking randomizes *what the verifier sees* so that its distribution no longer depends on the secret.

## Toward sealed mathematical arguments

A serious zero-knowledge theorem protocol must coordinate several distinct ideas.

First, it needs a precise relation between public theorem statements and valid derivations. Second, it needs commitments with separately articulated hiding and binding properties: hiding protects private data, while binding prevents the prover from changing answers after seeing a challenge. Third, the proof should be robustly encoded so that invalid evidence is far from acceptance and random local checks have constant detection probability. Fourth, privacy must be expressed through simulation or equality of transcript distributions, not through the hope that a small glimpse reveals little. Finally, any claim of communication depending only on statement length requires a genuinely succinct argument construction; ordinary proof encoding does not make a long witness disappear.

There remains a compelling dream here. Mathematicians may someday certify proprietary computations, security-sensitive analyses, or strategically valuable proof methods without publishing their witnesses. Similar techniques could allow a pharmaceutical company to establish that a trial analysis followed a preregistered rule without exposing patient records, or let a safety auditor certify a hidden model against public requirements.

But cryptography rewards exact bookkeeping. What is hidden? What is opened? How often can cheating escape? Which probability is being amplified? The raw-opening protocol answers these questions incorrectly: privacy collapses whenever valid witnesses differ at an opened coordinate, and soundness deteriorates with witness length when corruption is sparse.

The path to a sealed proof therefore begins with two warnings and one constructive clue. Opening is not hiding. Sampling is not robustness. Proper random masking can make a transcript independent of a secret. Once those lessons are built into the design—from encoded proof to final transcript—the separation of truth from explanation becomes not a paradox, but a precise mathematical possibility.
