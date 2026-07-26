# Random Openings, Geometric Soundness, and Perfect Hiding in Private Theorem Certification

## Abstract

We analyze the finite information-theoretic core of a proposed method for certifying mathematical proofs without revealing their contents. The naive protocol commits to the lines of a proof, challenges a uniformly random line, opens that line, and repeats. Three logically distinct properties are isolated: witness privacy of local openings, soundness amplification under independent repetition, and hiding of committed values. We prove that opening every possible coordinate is perfectly witness-private exactly when each public statement has at most one valid witness; thus random line opening is generally not zero knowledge. We establish the exact counting law for repetition: if at most $e$ among $n$ challenges accept in each round, then $k$ independent rounds accept with probability at most $(e/n)^k$. The frequently asserted bound $2^{-k}$ requires the additional one-round condition $2e\le n$. In the tight single-defect case, the escape probability is $((n-1)/n)^k$; with four checks it is $(3/4)^k>(1/2)^k$ for every positive $k$, and for every fixed $k$ a challenge space of size $2k+2$ keeps the escape probability above one half. Finally, we prove that additive masking by a uniform element of $\mathbb Z/q\mathbb Z$ produces an exactly uniform, secret-independent commitment distribution. These results delineate what a complete private theorem-certification protocol must add: a locally testable encoding with a constant rejection gap, a globally binding commitment, and a simulator for opened local constraints.

## 1. Introduction

A zero-knowledge proof allows a prover to convince a verifier that a public statement is true while revealing no information beyond that truth. Applied to mathematics, this suggests a striking possibility: one might certify possession of a derivation of a theorem while withholding the derivation and its strategic ideas.

A natural proposal represents a proof as a list of locally checkable steps. The prover commits to every step. The verifier selects one step at random, asks the prover to open it, and checks that it is an axiom or follows correctly from preceding material. Repetition is intended to suppress cheating. If commitments hide their messages, it may appear that the verifier sees too little to learn the proof.

That reasoning conflates three properties.

* **Privacy:** does the opened information depend on which valid proof is used?
* **Soundness:** how likely is an invalid certificate to survive the sampled checks?
* **Commitment security:** are unopened values hidden, and is the prover bound to one global certificate?

This paper gives exact finite statements for the first two questions and an information-theoretic construction for the hiding half of the third. The conclusions are both negative and constructive. Raw coordinate opening is witness-private only in the exceptional case of witness uniqueness. Repetition does amplify soundness, but according to the actual accepting fraction rather than a universal binary rate. Uniform additive masking gives perfect hiding, but does not supply binding or protect plaintexts after they are opened.

The resulting picture is a specification for a credible protocol rather than a complete realization of one. A proof must be encoded so that false certificates fail a constant fraction of local tests; commitments must bind all answers to one encoded proof; and the distribution of opened constraints must admit simulation without the witness.

## 2. Finite model

### 2.1 Statements, witnesses, and views

Let $S$ be a set of public statements, $A$ an alphabet, and $n$ a positive integer. A witness is a function

$$
w:\{0,1,\ldots,n-1\}\to A.
$$

A relation $R(s,w)$ specifies whether $w$ is a valid witness for statement $s\in S$. In the intended application, $w$ is a proof or an encoding of a proof.

A deterministic verifier view is a function $V(s,w)$ taking values in some view space. We use the following strong information-theoretic notion.

**Definition 2.1 (perfect witness privacy).** A view $V$ is perfectly witness-private for $R$ if, for every statement $s$ and every pair of valid witnesses $w_1,w_2$,

$$
R(s,w_1)\land R(s,w_2)\quad\Longrightarrow\quad V(s,w_1)=V(s,w_2).
$$

This definition isolates witness independence. It says that the transcript reveals no distinction among valid witnesses for the same public statement. For randomized views, the analogous requirement would be equality of distributions; the deterministic coordinate view below is enough to expose the obstruction.

For a challenge coordinate $i\in\{0,\ldots,n-1\}$, define the opening view by

$$
V_i(s,w)=w(i).
$$

The challenge index is regarded as public. Random selection of $i$ therefore creates a distribution over pairs consisting of the index and its opened value; it does not erase dependence of the value on the witness.

### 2.2 Challenge sets and acceptance

Let the challenge space have $n$ elements. In round $j$, let $A_j$ be the set of challenges on which the prover is accepted. Suppose

$$
|A_j|\le e
$$

for every round. Uniform independent challenges produce a vector in the Cartesian product of $k$ copies of the challenge space. Acceptance in every round means that this vector belongs to

$$
A_0\times A_1\times\cdots\times A_{k-1}.
$$

This product structure is the entire source of soundness amplification.

### 2.3 Additive masking

Let $q\ge 1$ and write $G=\mathbb Z/q\mathbb Z$. For a secret $s\in G$, sample a mask $r$ uniformly from $G$ and publish

$$
C=s+r.
$$

We call the law of $C$ the additive masking distribution for $s$. This is a one-time-pad commitment only in the informal sense of a hidden published value; as discussed later, it is not binding.

## 3. Privacy of local openings

The first theorem is a pointwise characterization.

**Theorem 3.1 (coordinate privacy).** Fix a coordinate $i$. The opening view $V_i(s,w)=w(i)$ is perfectly witness-private if and only if, for every statement $s$ and every two valid witnesses $w_1,w_2$,

$$
w_1(i)=w_2(i).
$$

**Proof sketch.** By definition, perfect witness privacy requires equality of the two views for every pair of valid witnesses. Since the view at coordinate $i$ is exactly the symbol at coordinate $i$, equality of views is precisely $w_1(i)=w_2(i)$. The converse is the same implication read in reverse. $\square$

A direct contrapositive is useful.

**Corollary 3.2 (local leakage criterion).** If there are a statement $s$, two valid witnesses $w_1,w_2$, and a coordinate $i$ such that $w_1(i)\ne w_2(i)$, then opening coordinate $i$ is not perfectly witness-private.

The characterization becomes especially restrictive when any coordinate may be opened.

**Theorem 3.3 (all-openings characterization).** Every coordinate-opening view is perfectly witness-private if and only if each statement has at most one valid witness. Equivalently,

$$
\bigl(\forall i,\ V_i\text{ is perfectly witness-private}\bigr)
\quad\Longleftrightarrow\quad
\forall s,w_1,w_2,\ R(s,w_1)\land R(s,w_2)\Rightarrow w_1=w_2.
$$

**Proof sketch.** Assume privacy for every coordinate. For valid $w_1,w_2$, Theorem 3.1 gives $w_1(i)=w_2(i)$ for every $i$, hence the functions are equal. Conversely, if a statement has at most one valid witness, any two valid witnesses coincide, so every coordinate view coincides. $\square$

**Example 3.4 (one-bit leakage).** Let there be one public statement and let both one-bit witnesses be valid. Thus $w_0(0)=0$ and $w_1(0)=1$ both establish the same statement. Opening the only coordinate distinguishes the witnesses with certainty. It follows from Corollary 3.2 that the opening is not perfectly witness-private.

The example is deliberately minimal. It shows that leakage does not require many rounds, a complicated proof language, or a malicious verifier. It arises whenever the opened value varies among valid witnesses.

### 3.1 Why randomization does not cure the problem

Suppose the verifier samples $I$ uniformly and observes $(I,w(I))$. If two witnesses differ at coordinate $i$, then the event $(I,w(I))=(i,w_1(i))$ may have a different probability under $w_1$ and $w_2$. In the one-bit example, the transcript distributions have disjoint support. The fact that the verifier does not choose in advance which proof feature to learn is irrelevant to whether information is learned.

This does not imply that local-query zero knowledge is impossible. It implies that raw local values cannot simply be exposed. Successful protocols randomize encodings, reveal relations invariant under witness-preserving symmetries, or otherwise arrange that a simulator can reproduce each opened view without possessing the witness.

## 4. Exact soundness amplification

We next count accepting challenge vectors.

**Lemma 4.1 (product count).** Let $A_j$ be a finite accepting set in round $j$. The number of challenge vectors accepted in all $k$ rounds is

$$
\left|\prod_{j=0}^{k-1}A_j\right|=\prod_{j=0}^{k-1}|A_j|.
$$

**Proof sketch.** Each accepted vector is formed by independently choosing one element from each $A_j$. The finite multiplication principle gives the product of cardinalities. $\square$

**Lemma 4.2 (bounded accepting count).** If $|A_j|\le e$ for all $j$, then the number of accepting vectors is at most $e^k$.

**Proof sketch.** Apply Lemma 4.1 and multiply the $k$ inequalities $|A_j|\le e$. $\square$

Uniform sampling from a challenge space of size $n$ yields the main bound.

**Theorem 4.3 (independent repetition).** If each of $k$ independent rounds has $n$ equally likely challenges and at most $e$ accepting challenges, then the probability of acceptance in every round is at most

$$
\left(\frac en\right)^k.
$$

**Proof sketch.** There are $n^k$ equally likely challenge vectors. By Lemma 4.2 at most $e^k$ accept. Their ratio is $e^k/n^k=(e/n)^k$. $\square$

The theorem permits different accepting sets from round to round. It requires only the uniform cardinality bound and independence of challenge sampling.

**Corollary 4.4 (binary soundness under a half-gap).** If $n>0$ and $2e\le n$, then the acceptance probability after $k$ rounds is at most

$$
2^{-k}.
$$

**Proof sketch.** The premise gives $e/n\le 1/2$. Raising nonnegative quantities to the $k$th power preserves the inequality, and Theorem 4.3 applies. $\square$

The premise is essential. Repetition magnifies a one-round soundness gap; it does not create a larger gap than the underlying test possesses.

### 4.1 The single-defect regime

Suppose exactly one of $n$ checks detects invalidity. Then $e=n-1$, and the survival probability is exactly

$$
F(n,k)=\left(\frac{n-1}{n}\right)^k.
$$

**Theorem 4.5 (four-check separation).** For four possible checks with exactly one detecting location,

$$
F(4,k)=\left(\frac34\right)^k.
$$

For every positive integer $k$,

$$
\left(\frac12\right)^k<F(4,k).
$$

**Proof sketch.** Substitution gives the first identity. Since $0<1/2<3/4$ and $k>0$, strict monotonicity of positive integer powers gives the inequality. $\square$

This separation grows operationally important when a desired error target is selected using the wrong base. For $k=10$, $(1/2)^{10}\approx0.0009766$ while $(3/4)^{10}\approx0.05631$.

A family of examples rules out any fixed repetition count as a universal cure.

**Theorem 4.6 (no fixed-repetition half-bound).** For every integer $k\ge0$,

$$
\frac12<F(2k+2,k)=\left(\frac{2k+1}{2k+2}\right)^k.
$$

**Proof sketch.** The case $k=0$ is immediate. For $k>0$, write the base as $1-x$ with $x=1/(2k+2)$. Bernoulli's inequality gives

$$
(1-x)^k\ge 1-kx
=1-\frac{k}{2k+2}
=\frac{k+2}{2k+2}>rac12.
$$

Thus a single bad coordinate can remain hidden with probability above one half when the challenge space grows linearly with the number of repetitions. $\square$

### 4.2 Repetition cost

To reduce a one-bad-line escape probability below $2^{-\lambda}$, one needs

$$
\left(1-\frac1n\right)^k\le 2^{-\lambda}.
$$

Taking logarithms gives

$$
k\ge \frac{\lambda\log 2}{-\log(1-1/n)}.
$$

As $n$ grows, $-\log(1-1/n)\sim1/n$, so the required repetition count is asymptotically

$$
k\sim n\lambda\log 2.
$$

This scaling explains the role of locally testable encodings. If every invalid encoding fails at least a fixed fraction $\delta>0$ of checks, then $e/n\le1-\delta$ and only

$$
k\ge\frac{\lambda\log2}{-\log(1-\delta)}
$$

rounds are needed, independent of the total number of coordinates.

## 5. Perfect hiding by additive masks

We now turn from openings to unopened committed values.

**Lemma 5.1 (translation is a bijection).** For every $s\in\mathbb Z/q\mathbb Z$, the map

$$
T_s(r)=s+r
$$

is a bijection of $\mathbb Z/q\mathbb Z$.

**Proof sketch.** Its inverse is $c\mapsto c-s$. $\square$

**Lemma 5.2 (uniform distributions are translation-invariant).** Mapping the uniform distribution on a finite set through a bijection preserves uniformity.

**Proof sketch.** Every output has exactly one preimage. Hence every output probability remains the reciprocal of the set's cardinality. $\square$

Combining the two gives the central hiding statement.

**Theorem 5.3 (uniform masking).** Let $q\ge1$, let $s\in\mathbb Z/q\mathbb Z$, and choose $R$ uniformly from $\mathbb Z/q\mathbb Z$. Then

$$
C=s+R
$$

is uniformly distributed on $\mathbb Z/q\mathbb Z$.

**Proof sketch.** Apply Lemma 5.2 to the translation bijection in Lemma 5.1. Equivalently, for each $c$ there is exactly one mask $r=c-s$, so $\Pr[C=c]=1/q$. $\square$

**Corollary 5.4 (perfect hiding).** For any secrets $s,t\in\mathbb Z/q\mathbb Z$, the random variables $s+R$ and $t+R$ have identical distributions when $R$ is uniform.

An explicit coupling makes the equality transparent. Given a mask $r$ used with secret $s$, define

$$
r'=(s-t)+r.
$$

Then $r\mapsto r'$ is a permutation of the mask space and

$$
s+r=t+r'.
$$

Thus each outcome under one secret is paired measure-preservingly with the same outcome under the other.

### 5.1 Hiding is not binding

For a fixed published $C$, every proposed secret $s$ has a compatible opening $R=C-s$. Therefore additive masking by itself allows the prover to choose the secret after publishing $C$. It is perfectly hiding and perfectly nonbinding.

A commitment suitable for proof certification must prevent inconsistent openings, usually under an explicit computational assumption or through an information-theoretic tradeoff in a richer model. When many proof coordinates are committed, the verifier also needs assurance that all local openings belong to one globally fixed certificate. An authenticated tree of commitments is a standard architecture: inconsistent openings should imply a collision in the underlying hash mechanism.

### 5.2 Hiding is not transcript simulation

Even a binding, hiding commitment reveals its message when opened. If the message is a raw proof line, Theorem 3.3 applies to the revealed plaintext. A complete zero-knowledge analysis therefore requires a transcript distribution and a simulator that can generate an equal or computationally indistinguishable view without the witness. The commitment theorem establishes privacy before opening, not zero knowledge of the interactive protocol as a whole.

## 6. Algorithms and numerical diagnostics

### 6.1 Exact escape-probability evaluator

Given $n\ge1$, an accepting count $0\le e\le n$, and $k\ge0$, compute

$$
P=(e/n)^k.
$$

Rational arithmetic should be used when possible, because the result is an exact ratio $e^k/n^k$. The algorithm performs exponentiation by squaring and has $O(\log k)$ arithmetic multiplications, with bit complexity governed by integers of size $O(k\log n)$.

For the single-defect model, set $e=n-1$. Comparing this value with $2^{-k}$ immediately diagnoses whether a claimed binary bound is justified.

### 6.2 Minimum-round calculator

Given a target error $\varepsilon\in(0,1)$ and one-round accepting fraction $p\in(0,1)$, the least sufficient repetition count is

$$
k_{\min}=\left\lceil\frac{\log\varepsilon}{\log p}\right\rceil.
$$

Both logarithms are negative, so their ratio is positive. Boundary cases should be handled separately: $p=0$ needs one round for any positive target, while $p=1$ can never reach a target below one.

### 6.3 Exhaustive masking check

For a small modulus $q$, enumerate all pairs $(s,r)$ and count outputs $c=(s+r)\bmod q$. For every fixed $s$, each residue must occur exactly once as $r$ varies. Comparing histograms across secrets illustrates Theorem 5.3 and Corollary 5.4 without statistical approximation.

These computations are demonstrations rather than substitutes for the general counting arguments. Their value is diagnostic: they expose parameter dependence that may be obscured by asymptotic slogans.

## 7. Implications for private theorem certification

The results yield four design requirements.

### 7.1 Encode before testing

A raw proof with one invalid line has rejection probability only $1/n$. To obtain a constant one-round soundness gap, the proof must be encoded so that global invalidity causes many local constraints to fail. This is the essential function of probabilistically checkable encodings. Arithmetizing a proof makes its syntax numerical; it does not by itself guarantee robust local testability.

### 7.2 Bind the entire encoded object

Independent masks can hide coordinates, but they do not ensure that answers across rounds derive from one certificate. A global authenticated commitment is needed. Its security statement must specify that two inconsistent openings lead to a forbidden event, such as finding a collision.

### 7.3 Simulate what is opened

The privacy target concerns the whole verifier view, including challenges, openings, authentication paths, and verifier randomness. A simulator must reproduce that distribution without a witness. Theorems about unopened commitments are necessary ingredients but not a substitute for simulation.

### 7.4 State the soundness premise explicitly

The exact repetition law is $(e/n)^k$. A bound of $2^{-k}$ is legitimate only after proving $e/n\le1/2$. More generally, protocol descriptions should state a rejection fraction $\delta$, yielding error at most $(1-\delta)^k$.

## 8. Scope of the statement-length communication conjecture

The motivating conjecture claims that every theorem provable in Peano Arithmetic has a zero-knowledge proof with communication polynomial in the length of the theorem statement rather than the length of its derivation. The finite results above do not establish this conjecture. They identify prerequisites that any precise version must address.

First, the protocol needs an explicit locally testable representation of arbitrary derivations, with quantitative proof length and query complexity. Second, communication includes commitments, authentication data, responses, and repetition, not merely the number of queried symbols. Third, computational zero knowledge requires a security parameter and explicit assumptions. Fourth, the resources of the prover matter: a proof system and an argument system make different commitments about computationally unbounded cheating. Finally, uniformity and setup assumptions must be stated.

The conjecture may be understood as a research program linking arithmetization, robust proof encodings, succinct commitments, and zero-knowledge compilation. The present analysis supplies elementary tests that any candidate construction must pass.

## 9. Discussion

The negative privacy theorem and positive hiding theorem are not contradictory. They concern different stages. Before opening, additive masking makes a value statistically independent of its secret. After opening, a raw coordinate may identify the witness. Similarly, the repetition theorem is strong but conditional: it preserves the actual per-round acceptance fraction through exponentiation.

This separation is useful beyond theorem proving. Many cryptographic errors arise from transferring a guarantee across an interface where it no longer applies. Encryption privacy is mistaken for safe declassification; commitment hiding is mistaken for protocol zero knowledge; repeated weak tests are described using the parameters of strong tests. Exact finite formulations prevent these category errors.

The results also clarify what “learns nothing beyond validity” must mean. It cannot merely mean that most proof lines remain unopened. It should mean that the entire transcript can be generated, exactly or approximately in the relevant computational sense, using only the public statement and the fact that it is valid. Witness-independence of deterministic views is a stringent special case of that principle, and its failure for raw openings is decisive.

## 10. Future work

Several steps are required to turn the abstract architecture into a complete protocol.

1. **Authenticated local openings.** Define a global commitment structure and show that inconsistent local openings imply a collision or another explicit security violation.
2. **Simulation of opened constraints.** Specify transcript distributions and construct a simulator with exact equality or computational indistinguishability from the verifier’s real view.
3. **Adaptive-prover soundness.** Replace fixed accepting sets by interactive probabilistic strategies and prove repetition under carefully stated independence conditions.
4. **Concrete propositional proof relations.** Encode a proof calculus, establish decidability of local inference, and prove that accepted complete certificates imply semantic tautologicity.
5. **Robust proof composition.** Supply an explicit locally testable encoding with constant rejection probability and account for proof length, query complexity, and total communication.
6. **Complexity assumptions.** Introduce a security parameter and commitment primitive satisfying both hiding and binding in the chosen model.
7. **Conjecture refinement.** Distinguish proofs from arguments, identify setup and uniformity assumptions, and state prover-time and communication bounds precisely.

## 11. Conclusion

A random-line protocol does not become zero knowledge merely because each round reveals little. Opening all possible coordinates is perfectly witness-private exactly when valid witnesses are unique. Independent repetition reduces soundness error exactly as $(e/n)^k$, and binary decay requires a proven half-soundness gap. Uniform additive masking does provide exact secret-independent hiding, but it neither binds the prover nor protects opened plaintexts.

Together these results replace an informal “commit, challenge, open, repeat” narrative with quantitative design obligations. Private certification of mathematical proofs remains possible in principle, but it requires robust local encoding, global commitment consistency, simulatable openings, and parameter-aware amplification. Those ingredients—not the small size of any single disclosure—are what can make a sealed proof both convincing and private.