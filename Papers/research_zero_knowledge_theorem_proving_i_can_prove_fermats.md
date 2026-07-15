# Raw Coordinate Openings in Private Verification: Exact Privacy Criteria, Soundness Limits, and Boolean Masking

## Abstract

A natural proposal for privately verifying a mathematical witness is to commit to its coordinates and answer random challenges by opening individual coordinates. This paper gives a self-contained finite analysis of that proposal. Perfect witness privacy for opening a fixed coordinate is shown to be equivalent to agreement of all valid witnesses at that coordinate. Privacy under every possible coordinate challenge is therefore equivalent to uniqueness of the valid witness. A one-bit relation gives the minimal privacy counterexample. On the soundness side, if exactly one among $n$ uniformly sampled checks detects malformed evidence, then $k$ independent repetitions have false-acceptance probability exactly $((n-1)/n)^k$. For $n=4$ this is $(3/4)^k$, strictly larger than $2^{-k}$ for every positive $k$; more generally, no fixed repetition count gives a statement-size-independent one-half error bound against a single bad location. Standard binary soundness amplification is recovered once a genuine one-round bound $p\le1/2$ is assumed. As a positive privacy primitive, uniform Boolean one-time-pad masking is analyzed by exact fiber counting: every ciphertext has one preimage mask for either message, so transcript distributions coincide, and opening recovers the message. These results separate commitments, robust encoding, repetition, and masking, and identify the additional ingredients required for a sound zero-knowledge protocol.

## 1. Introduction

Zero-knowledge verification asks whether one party can demonstrate possession of valid evidence without revealing that evidence. In mathematical applications, the public statement could be a theorem in a specified deductive system and the private witness could be a derivation. In combinatorial applications, the statement might assert that a graph is colorable and the witness might be a coloring. The intended security property is stronger than merely withholding most of the witness: the transcript should disclose no witness-dependent information beyond what follows from the public statement.

A tempting protocol has three steps. The prover first commits separately to every coordinate of a witness. The verifier then selects a random coordinate. Finally, the prover opens the selected commitment and demonstrates that the local data are consistent with the relevant rule. Repeating this experiment is often informally claimed both to hide the proof and to drive soundness error down to $2^{-k}$ after $k$ rounds.

Neither conclusion follows from random opening alone. Commitments may hide unopened coordinates, but an opened coordinate appears in the transcript and can distinguish valid witnesses. Likewise, repetition amplifies the actual one-round detection probability. If only one among many locations exposes a defect, then a random local query is unlikely to find it.

This paper isolates these issues in a finite model. The model intentionally avoids computational assumptions and therefore studies perfect, information-theoretic witness privacy. This permits exact characterizations rather than asymptotic claims. The main results are:

1. opening coordinate $i$ is perfectly witness-private exactly when all valid witnesses agree at $i$;
2. privacy for every coordinate is equivalent to uniqueness of each valid witness;
3. a relation accepting both Boolean witnesses violates privacy when the bit is opened;
4. sparse-error checking has exact false-acceptance probability $((n-1)/n)^k$;
5. no fixed number of repetitions guarantees a uniform one-half error bound as witness length grows;
6. the familiar $2^{-k}$ amplification follows conditionally from a one-round error at most $1/2$; and
7. uniform Boolean masking has message-independent transcript fibers and correct opening.

The conclusions are diagnostic rather than a rejection of zero knowledge. They show why robust encodings, hiding mechanisms, binding mechanisms, and transcript-level privacy definitions must be treated as separate components.

## 2. Finite model and definitions

Let $S$ be a set of public statements, $W$ a set of witnesses, and

$$
R\subseteq S\times W
$$

a validity relation. We write $R(s,w)$ when $w$ is a valid witness for statement $s$. Let $V$ be the set of possible verifier views. A deterministic view function is a map

$$
\mathsf{View}:S\times W\to V.
$$

### Definition 2.1 (Perfect witness privacy)

The view function has **perfect witness privacy** relative to $R$ if, for every $s\in S$ and every pair $w_1,w_2\in W$,

$$
R(s,w_1)\land R(s,w_2)
\quad\Longrightarrow\quad
\mathsf{View}(s,w_1)=\mathsf{View}(s,w_2).
$$

Thus the view is constant on the set of valid witnesses for a fixed statement. For randomized protocols, the corresponding requirement is equality of view distributions; the deterministic definition is the appropriate specialization when the challenge is fixed.

Fix a positive witness length $n$ and an alphabet $A$. A coordinate witness is a function

$$
w:\{0,1,\ldots,n-1\}\to A.
$$

For a fixed coordinate $i$, define the opening view by

$$
\mathsf{Open}_i(s,w)=w_i.
$$

The public statement is an input but does not alter the returned coordinate.

### Definition 2.2 (All-opening privacy)

A coordinate-witness relation has **all-opening privacy** if $\mathsf{Open}_i$ has perfect witness privacy for every coordinate $i$.

For soundness, consider an object with $n$ equally likely local checks, exactly one of which detects an error. In one round the verifier samples one check uniformly. Independent repetition means that the $k$ sampled indices are independent and uniformly distributed.

### Definition 2.3 (Sparse-error false-acceptance probability)

For positive $n$ and nonnegative integer $k$, define

$$
F(n,k)=\left(\frac{n-1}{n}\right)^k.
$$

This quantity is the probability that all $k$ checks miss the unique bad location.

Finally, for Boolean masking let $m\in\{0,1\}$ be a message, $r\in\{0,1\}$ a random mask, and define

$$
\mathsf{Mask}(m,r)=m\oplus r,
$$

where $\oplus$ is exclusive OR.

## 3. Exact privacy characterization for coordinate opening

### Theorem 3.1 (Single-Opening Privacy Theorem)

Fix a coordinate $i$. The opening view $\mathsf{Open}_i$ has perfect witness privacy if and only if, for every statement $s$ and all valid witnesses $w_1,w_2$ for $s$,

$$
(w_1)_i=(w_2)_i.
$$

#### Proof sketch

By definition, the view obtained from witness $w$ is exactly $w_i$. Perfect witness privacy says that the views produced by any two valid witnesses coincide. Substituting the definition of the view gives precisely $(w_1)_i=(w_2)_i$. Both implications are therefore direct instances of the same equality. $\square$

The theorem is elementary, but it rules out a common intuition: revealing only one coordinate is not automatically zero knowledge. Information leakage is not measured by the fraction of the witness disclosed. If a single coordinate varies among valid witnesses, its disclosure distinguishes those witnesses perfectly.

### Corollary 3.2 (Distinguishing witnesses destroy privacy)

Suppose $w_1$ and $w_2$ are valid witnesses for the same statement and $(w_1)_i\ne(w_2)_i$. Then opening coordinate $i$ is not perfectly witness-private.

#### Proof sketch

The two witnesses produce unequal views, contradicting the equality required by perfect witness privacy. Equivalently, this is the contrapositive of the forward direction of Theorem 3.1. $\square$

### Theorem 3.3 (All-Openings Privacy Theorem)

All coordinate openings are perfectly witness-private if and only if every two valid witnesses for the same statement are equal as coordinate functions. Explicitly,

$$
\bigl(\forall i,\ \mathsf{Open}_i\text{ is perfectly witness-private}\bigr)
$$

holds if and only if

$$
\forall s,w_1,w_2,
\quad R(s,w_1)\land R(s,w_2)\Longrightarrow w_1=w_2.
$$

#### Proof sketch

Assume every opening is private. Given two valid witnesses, Theorem 3.1 shows that they agree at every coordinate. Extensional equality of functions then yields $w_1=w_2$. Conversely, if valid witnesses are unique, any two valid witnesses are equal and hence have equal values at every challenged coordinate. Every opening view is therefore private. $\square$

This result says that randomizing the challenged coordinate does not remove the obstruction. Since the selected index is part of the transcript, conditional privacy for that challenge requires agreement at that index. Supporting every challenge requires coordinatewise agreement everywhere, which is witness uniqueness.

### Example 3.4 (One-bit privacy failure)

Let the statement space contain a single public statement and let both Boolean witnesses be valid:

$$
R(s,0)=R(s,1)=\text{true}.
$$

The witness has one coordinate. Opening it produces view $0$ from one valid witness and view $1$ from the other.

### Proposition 3.5 (Minimal raw-opening leak)

The one-bit relation of Example 3.4 does not have perfect witness privacy under coordinate opening.

#### Proof sketch

Both witnesses are valid and differ at the only coordinate. Corollary 3.2 applies. $\square$

This example separates commitment hiding from opening privacy. Even if an unopened commitment is ideally hiding, an opening discloses the committed value. A commitment mechanism can prevent premature access to coordinates; it cannot make the disclosed coordinate independent of the witness.

## 4. Exact soundness under sparse corruption

Suppose a malformed object has exactly one bad location among $n$ possible checks. A round catches the defect with probability $1/n$ and misses it with probability $(n-1)/n$. Under independent sampling, false acceptance occurs exactly when every round misses.

### Theorem 4.1 (Exact Sparse-Error Formula)

After $k$ independent uniformly random checks, the false-acceptance probability is

$$
F(n,k)=\left(\frac{n-1}{n}\right)^k.
$$

#### Proof sketch

Each round misses the unique bad location with probability $(n-1)/n$. Independence makes the probability of missing in every round the product of the $k$ identical one-round probabilities. $\square$

### Proposition 4.2 (Four-check failure probability)

With four possible checks and one bad location,

$$
F(4,k)=\left(\frac34\right)^k.
$$

#### Proof sketch

Substitute $n=4$ into Theorem 4.1. $\square$

### Theorem 4.3 (Failure of automatic binary soundness)

For every positive integer $k$,

$$
\left(\frac12\right)^k<F(4,k)=\left(\frac34\right)^k.
$$

#### Proof sketch

The base inequality $1/2<3/4$ is strict and both quantities are nonnegative. Raising both sides to a positive integer power preserves strict order. $\square$

Thus $k$ repetitions do not intrinsically imply error $2^{-k}$. That rate is available only if the actual one-round error is no greater than $1/2$.

The dependence on $n$ is more severe than the four-check example suggests.

### Theorem 4.4 (No Fixed-Repetition Half Bound)

For every nonnegative integer $k$, choosing

$$
n=2k+2
$$

gives

$$
\frac12<F(2k+2,k).
$$

Consequently, no fixed repetition count ensures false-acceptance probability at most $1/2$ uniformly over all witness lengths when only one location detects the error.

#### Proof sketch

For $k=0$, the false-acceptance probability is $1$. For positive $k$, write

$$
F(2k+2,k)=\left(1-\frac{1}{2k+2}\right)^k.
$$

Bernoulli’s inequality states that $(1-x)^k\ge1-kx$ for $0\le x\le1$. With $x=1/(2k+2)$,

$$
F(2k+2,k)
\ge 1-\frac{k}{2k+2}
=\frac{k+2}{2k+2}
>\frac12.
$$

The strict final inequality follows because $k+2>k+1$. $\square$

For a target error $\varepsilon\in(0,1)$, Theorem 4.1 also yields the repetition requirement

$$
k\ge \frac{\log \varepsilon}{\log((n-1)/n)}.
$$

Since $\log((n-1)/n)\sim-1/n$ for large $n$, sparse-error detection requires on the order of $n\log(1/\varepsilon)$ queries. This asymptotic observation explains why constant-query verification requires a robust encoding: malformed objects must fail a constant fraction of checks, not merely one check.

## 5. Conditional soundness amplification

### Theorem 5.1 (Binary Soundness Amplification)

Let $p$ be the one-round false-acceptance probability, with

$$
0\le p\le\frac12.
$$

After $k$ independent repetitions in which acceptance requires every round to accept, the false-acceptance probability satisfies

$$
p^k\le\left(\frac12\right)^k=2^{-k}.
$$

#### Proof sketch

Independence gives false acceptance probability $p^k$. Since exponentiation by a nonnegative integer is monotone on nonnegative numbers, $p\le1/2$ implies $p^k\le(1/2)^k$. $\square$

This theorem clarifies the logical order of protocol analysis. One must first prove a one-round soundness estimate. Repetition then amplifies that estimate. In a local-checking protocol, a constant one-round estimate usually comes from a distance property: every false or malformed candidate violates a constant fraction $\delta$ of checks. Uniform sampling then catches the error with probability at least $\delta$, yielding one-round false acceptance at most $1-\delta$. If $\delta\ge1/2$, Theorem 5.1 applies directly. Other positive constants also yield exponential decay, but with base $1-\delta$.

A raw derivation does not generally have such distance. Altering one critical line can produce an invalid object that differs from locally plausible data in only one position. Arithmetically representing a derivation does not by itself spread that error. A probabilistically checkable encoding is valuable precisely because it introduces redundancy and robustness.

## 6. Uniform Boolean masking

Raw opening fails because the view equals a witness-dependent value. A simple random transformation can instead make the view distribution independent of the message.

For $m,r,c\in\{0,1\}$, define $c=m\oplus r$. For fixed $m$ and $c$, consider the fiber

$$
\mathcal F_{m,c}=\{r\in\{0,1\}:m\oplus r=c\}.
$$

### Lemma 6.1 (Unique Mask Fiber)

For every message $m$ and ciphertext $c$,

$$
|\mathcal F_{m,c}|=1.
$$

#### Proof sketch

The unique solution is $r=m\oplus c$. Equivalently, the four possible pairs $(m,c)$ can be enumerated: equal message and ciphertext require $r=0$, while unequal message and ciphertext require $r=1$. $\square$

### Theorem 6.2 (Uniform-Masking Perfect Privacy)

Let $r$ be uniform on $\{0,1\}$. For any two messages $m_1,m_2$ and every ciphertext $c$,

$$
\Pr[m_1\oplus r=c]=\Pr[m_2\oplus r=c]=\frac12.
$$

Hence the ciphertext distribution is independent of the message.

#### Proof sketch

By Lemma 6.1, exactly one of the two equally likely masks maps each fixed message to $c$. Therefore each probability is $1/2$, and the fiber cardinalities—and thus distributions—agree for all messages. $\square$

### Theorem 6.3 (Mask Opening Correctness)

For every $m,r\in\{0,1\}$,

$$
(m\oplus r)\oplus r=m.
$$

#### Proof sketch

Exclusive OR is associative, $r\oplus r=0$, and $m\oplus0=m$. $\square$

The privacy theorem and correctness theorem illustrate two distinct obligations. Privacy requires that the public value have a message-independent distribution. Correctness requires that the authorized opening recover the message. Both hold for the Boolean one-time pad.

The mask is not by itself a complete commitment: if the prover reveals only $c$ without fixing or authenticating $r$, the prover may later claim either message by choosing the corresponding mask. Thus hiding and binding remain separate requirements. A complete protocol must define both and state whether each is information-theoretic or computational.

## 7. Algorithms and numerical experiments

### 7.1 Exact sparse-error calculator

Given $n>0$ and $k\ge0$, compute

$$
F(n,k)=\left(1-\frac1n\right)^k.
$$

The algorithm performs constant-time arithmetic when exponentiation is treated as a primitive, or $O(\log k)$ multiplications by repeated squaring. It can also compute the detection probability $1-F(n,k)$ and compare it with $2^{-k}$.

### 7.2 Minimal repetitions for a target error

Given $n>1$ and $0<\varepsilon<1$, find the least $k$ with $F(n,k)\le\varepsilon$. A direct loop starts from $k=0$ and repeatedly multiplies by $(n-1)/n$ until the target is reached. Its running time is $O(k)$ and constant space. A logarithmic formula supplies an initial estimate, but exact iteration avoids rounding errors at the threshold.

### 7.3 Exhaustive Boolean masking audit

Enumerate all $m,r\in\{0,1\}$, compute $c=m\oplus r$, count each fiber, and verify opening by checking $(m\oplus r)\oplus r=m$. The state space has four input pairs, so the computation is constant size. The same counting method generalizes to finite one-time pads over a finite group: translation by a message permutes the randomness space.

Numerically, for $n=4$ and $k=10$,

$$
F(4,10)=\left(\frac34\right)^{10}\approx0.0563135,
$$

whereas

$$
2^{-10}\approx0.000976563.
$$

For $k=10$ and $n=22=2k+2$,

$$
F(22,10)=\left(\frac{21}{22}\right)^{10}\approx0.627,
$$

which exceeds $1/2$ as Theorem 4.4 predicts.

## 8. Applications and protocol-design consequences

### 8.1 Confidential mathematical methods

A private theorem-verification service would distinguish a public claim from a hidden derivation. The privacy definition must compare transcripts arising from different valid derivations of the same theorem. Raw line opening generally fails this test because proof lines encode strategy. Masking, commitments, and simulation must ensure that challenge responses reveal no more than a simulator could produce from the theorem alone.

### 8.2 Confidential compliance and audits

The same structure appears when a hidden dataset or computation witnesses compliance with a public rule. Randomly exposing raw records can violate privacy even if most records remain sealed. Robust encodings may improve soundness, but they do not automatically provide privacy; separate randomized response mechanisms are required.

### 8.3 Probabilistically checkable evidence

Local verification becomes powerful when evidence is encoded so that every invalid candidate is far from acceptance. If at least a fraction $\delta$ of locations detect invalidity, then $k$ independent checks have false-acceptance probability at most

$$
(1-\delta)^k.
$$

The sparse-error model corresponds to $\delta=1/n$, which vanishes as $n$ grows. The distinction between raw and robustly encoded evidence is therefore quantitative and structural.

### 8.4 Succinctness

Communication polynomial in statement length, independent of witness length, is a separate objective from zero knowledge. A local proof system may reduce the number of queried symbols while still relying on commitments to, or preprocessing of, a long encoded witness. Establishing succinct communication requires an explicit succinct argument construction, assumptions supporting it, and careful accounting of setup, prover computation, and uniformity. It does not follow merely from representing derivations arithmetically.

## 9. Discussion

The analysis exposes three category errors that can occur in informal protocol proposals.

First, **commitment hiding is not opening privacy**. A hiding commitment protects a value before opening. Once the value is opened, privacy depends on whether that value itself is safe to reveal or is transformed through a zero-knowledge subprotocol.

Second, **random selection is not random masking**. Selecting a random coordinate changes which witness-dependent datum appears. Masking changes the distribution of the datum that appears. The Boolean one-time pad succeeds because every transcript has equal probability under either message.

Third, **repetition is not a source of baseline soundness**. It converts $p$ into $p^k$. If $p$ approaches $1$ with witness length, a fixed $k$ cannot provide a uniform guarantee. Robust encoding is the missing bridge between local checking and constant one-round detection.

These distinctions also explain why merely revealing “one random step” is not a simulator-based zero-knowledge argument. A simulator given only the statement may not know the distribution of a genuine proof line, particularly when different valid proofs contain different data. The deterministic privacy criterion developed here is intentionally strong, but the one-bit example remains fatal even under ordinary distributional definitions: the transcript distributions are point masses at different bits.

The Boolean masking construction supplies a positive template but not a complete protocol. Its perfect secrecy relies on fresh uniform randomness. Reusing a mask can reveal relations between messages. Moreover, masking alone is malleable and nonbinding. These limitations reinforce the need for modular definitions.

## 10. Future work

A fuller theory should first replace deterministic views and fiber counts with finite probability distributions and transcript ensembles. Perfect zero knowledge can then be stated as equality of real and simulated transcript distributions; computational zero knowledge can be stated through indistinguishability against efficient distinguishers.

Second, commitments should be modeled through explicit games. Hiding asks whether a receiver can distinguish commitments to different messages. Binding asks whether a sender can open one commitment in two inconsistent ways. Collision resistance alone should not be treated as a synonym for either property.

Third, an interactive protocol for a finite or efficiently decidable relation should define completeness, soundness, and zero knowledge separately. This prevents a proof of one property from being mistaken for another.

Fourth, a robust encoded-proof relation should include a distance-to-acceptance theorem: every false candidate must violate a positive fraction of local constraints. That theorem would justify a constant one-round soundness estimate and permit valid repetition bounds.

Fifth, sequential and parallel repetition should be studied under explicit independence and adaptivity assumptions. Transcript leakage can accumulate across rounds even when soundness improves.

Finally, claims of statement-length succinctness require a separate construction and complexity analysis. The relevant questions include setup assumptions, computational hardness, uniformity, prover time, verifier time, total communication, and how each depends on statement and witness lengths.

## 11. Conclusion

Raw coordinate opening admits exact and restrictive privacy criteria. A fixed coordinate can be opened privately only when all valid witnesses agree there; every coordinate can be opened privately only when the valid witness is unique. The one-bit relation demonstrates the failure at the smallest possible scale.

Sparse-error soundness is equally exact. With one detectable defect among $n$ checks, $k$ independent trials fail with probability $((n-1)/n)^k$. This is $(3/4)^k$, not $2^{-k}$, when $n=4$, and no fixed $k$ gives a witness-size-independent one-half bound. Exponential binary amplification is valid only after establishing one-round error at most $1/2$.

Uniform Boolean masking shows what genuine information-theoretic hiding looks like: every ciphertext has equal probability under either message, while the mask opens correctly. The resulting design principles are concise. Do not confuse an unopened commitment with a harmless opening. Do not confuse random sampling with robust encoding. Do not invoke amplification before proving a baseline bound. Privacy, binding, robustness, and succinctness are separate mathematical obligations; a credible private-verification protocol must satisfy each one explicitly.
