# Zero-Knowledge Certification of Proofs: Independence, Soundness Amplification, and Perfect Hiding

## Abstract

We develop the probabilistic core of a zero-knowledge proof-checking protocol, in
which a prover convinces a verifier that a statement is provable while revealing
nothing about the proof itself. Three results form the backbone of the analysis.
First, an **independence identity**: under the uniform product measure over $k$
independent challenge rounds, the number of challenge sequences on which a prover
survives every round equals the product of the per-round accepting-set sizes.
This yields **soundness amplification** — the probability of surviving all $k$
rounds is at most $(e/n)^k$ when each round accepts at most an $e/n$ fraction of
the $n$ possible challenges, and at most $2^{-k}$ when $2e \le n$. Second, a
**single-round soundness** bound: against an invalid certificate with $n$ steps
(equivalently, an improper $3$-colouring of a graph with $m$ edges), a uniformly
random challenge catches the cheater with probability at least $1/n$ (resp.
$1/m$), and this is tight. Third, a **perfect-hiding** theorem for the
Goldreich–Micali–Wigderson graph-$3$-colouring protocol: the view map sending a
random colour permutation to the opened pair is a bijection from the symmetric
group $S_3$ onto the six ordered pairs of distinct colours, so the verifier's real
transcript distribution is *exactly equal* to that of a colouring-oblivious
simulator, with every distinct pair opened with probability precisely $1/6$. We
give full definitions, statements, and proof sketches, together with algorithms
and numerical illustrations. The synthesis is a self-contained account of why
interactive proof-checking can be simultaneously *complete* (truth always
passes), *sound* (lies are caught with error decaying as $2^{-k}$), and *perfectly
zero-knowledge* (the transcript is information-theoretically independent of the
secret).

**Keywords:** zero-knowledge proof, soundness amplification, product measure,
graph 3-colouring, perfect honest-verifier zero knowledge, interactive proof
systems.

---

## 1. Introduction

A *proof* traditionally serves two purposes at once: it certifies that a statement
is true, and it explains *why*. Zero-knowledge proofs, introduced by Goldwasser,
Micali, and Rackoff, separate these functions. A zero-knowledge proof of a
statement $T$ convinces a verifier that $T$ is provable while leaking no
information beyond that single bit of validity. Applied to mathematics, this
suggests a provocative possibility: one could certify possession of a correct
proof of a theorem — say a formal derivation in Peano Arithmetic — without
revealing any step of the derivation.

The mechanism that makes this work is the same one that underlies interactive
proofs for NP-complete problems. Encode the proof as a combinatorial object whose
validity can be checked locally; have the prover commit to that object; let the
verifier open a small, randomly chosen part and check it. A valid object always
passes; an invalid object fails a random local check with some fixed probability;
and randomizing the commitment ensures the opened part reveals nothing.

This paper isolates and proves the three quantitative facts on which such a
protocol rests. We work throughout with the canonical NP-complete carrier, graph
$3$-colourability, and its classical zero-knowledge protocol due to Goldreich,
Micali, and Wigderson (GMW), while stating the amplification machinery in a
protocol-independent form so that it composes with any single-round soundness
bound.

### Contributions

1. **Independence and amplification (Section 3).** We prove that the $k$-round
   survival event, modeled as a product set in the product challenge space,
   has cardinality equal to the product of per-round accepting-set sizes, and
   derive the geometric soundness bounds $(e/n)^k$ and $2^{-k}$.
2. **Single-round soundness (Section 4).** We prove that an improper $3$-colouring
   is caught by a random-edge verifier with probability at least $1/m$, and that
   the acceptance probability is at most $1 - 1/m$; combined with amplification,
   the $k$-round cheating probability tends to $0$.
3. **Perfect hiding (Section 5).** We prove that the GMW view map is a bijection
   $S_3 \to \{\text{distinct ordered pairs}\}$, deduce that the real transcript
   distribution equals the simulator's exactly, and conclude colour-independence
   and the closed-form probability $1/6$.

---

## 2. Definitions and setup

### 2.1 Graphs, colourings, and the GMW protocol

Let $V$ be a finite set of vertices and $E \subseteq V \times V$ a finite set of
edges. A **$3$-colouring** is a function $c : V \to \{0,1,2\}$, where we identify
the three colours with the elements of $\mathbb{Z}/3\mathbb{Z}$.

**Definition 2.1 (Proper colouring).** A colouring $c$ is *proper* for edge set
$E$ if the endpoints of every edge receive distinct colours:
$$\text{Proper}_E(c) \iff \forall e \in E,\ c(e_1) \ne c(e_2).$$

The GMW zero-knowledge protocol for $3$-colourability proceeds in rounds. In each
round:

1. The prover, holding a proper colouring $c$, samples a uniformly random
   permutation $\pi \in S_3$ of the three colours and commits (via a hiding,
   binding commitment) to the recoloured colouring $\pi \circ c$.
2. The verifier challenges a uniformly random edge $(u,v) \in E$.
3. The prover opens the two committed colours $(\pi(c(u)), \pi(c(v)))$.
4. The verifier accepts the round iff the two opened colours differ.

### 2.2 The abstract challenge model

For the amplification analysis we abstract away the protocol. A single round has a
finite **challenge space** $\Omega$ of size $n$ (the edges, or more generally the
steps of an arithmetized proof), modeled as $\{0,1,\dots,n-1\}$. A cheating prover
in round $i$ is characterized by its **accepting set** $A_i \subseteq \Omega$ —
the challenges on which it survives without exposing its inconsistency. Over $k$
rounds the challenge space is the product $\Omega^k$, equipped with the uniform
product measure, and the "survive all rounds" event is the product set
$$\mathcal{A} = \{\,\omega \in \Omega^k : \omega_i \in A_i \text{ for all } i\,\}
= A_1 \times A_2 \times \cdots \times A_k.$$

**Definition 2.2 (Round acceptance probability).** For a committed colouring $c'$
on edge set $E$ with $m = |E| > 0$, the **one-round acceptance probability** is the
fraction of edges whose endpoints receive distinct colours,
$$p(E, c') = \frac{|\{e \in E : c'(e_1) \ne c'(e_2)\}|}{|E|}.$$
These are exactly the edges on which the verifier fails to catch the prover.

---

## 3. Independence and soundness amplification

The engine of the entire construction is that independent rounds *multiply*
survival probabilities. In the finite uniform model this is a clean counting
identity.

**Theorem 3.1 (Independence identity).** Let $A : \{1,\dots,k\} \to
\mathcal{P}(\Omega)$ assign to each round an accepting set $A_i \subseteq \Omega$.
Then the number of $k$-round challenge sequences on which the prover survives every
round is the product of the per-round sizes:
$$|A_1 \times \cdots \times A_k| = \prod_{i=1}^{k} |A_i|.$$

*Proof sketch.* This is the cardinality of a finite dependent product: a sequence
lies in the product set iff each coordinate independently lies in the
corresponding $A_i$, and the count of such sequences is the product of the
coordinate counts. This equality — not merely a bound — is the precise statement
that the rounds are independent under the uniform product measure. $\square$

**Corollary 3.2 (Uniform accepting bound).** If every round accepts at most $e$
challenges, $|A_i| \le e$ for all $i$, then the number of surviving sequences is at
most $e^k$:
$$|A_1 \times \cdots \times A_k| = \prod_{i=1}^k |A_i| \le \prod_{i=1}^k e = e^k.$$

*Proof sketch.* Monotonicity of finite products under termwise inequalities of
nonnegative integers, followed by evaluation of a constant product. $\square$

**Theorem 3.3 (Soundness amplification).** With $n = |\Omega|$, if every round
accepts at most an $e/n$ fraction of challenges ($|A_i| \le e$), then the uniform
probability that the prover survives all $k$ rounds satisfies
$$\Pr[\text{survive all }k] = \frac{|A_1 \times \cdots \times A_k|}{n^k}
\ \le\ \left(\frac{e}{n}\right)^{k}.$$

*Proof sketch.* By Corollary 3.2 the numerator is at most $e^k$; dividing by
$n^k$ and using $(e/n)^k = e^k/n^k$ gives the bound by monotonicity of division by
the positive quantity $n^k$. $\square$

**Theorem 3.4 (Soundness error $2^{-k}$).** If each round catches the cheater with
probability at least $1/2$ — equivalently $2e \le n$, so the accepting fraction is
at most $1/2$ — then
$$\Pr[\text{survive all }k] \ \le\ \left(\frac{1}{2}\right)^{k} = 2^{-k}.$$

*Proof sketch.* From $2e \le n$ and $n > 0$ we get $e/n \le 1/2$. Substituting into
Theorem 3.3 and using monotonicity of $x \mapsto x^k$ on nonnegative reals yields
$(e/n)^k \le (1/2)^k$. $\square$

This matches the target soundness error of the mission: independent repetition
turns a per-round catch probability of one-half into an exponentially small escape
probability.

**Theorem 3.5 (Real product composition).** Let $p_1,\dots,p_k \in [0,1]$ be
per-round survival probabilities and suppose each round is caught with probability
at least $1-q$, i.e. $p_i \le q$ for all $i$ with $0 \le p_i$. Then the joint
survival probability is bounded by $q^k$:
$$\prod_{i=1}^{k} p_i \le q^{k}.$$

*Proof sketch.* Termwise the nonnegative factors satisfy $p_i \le q$, so
monotonicity of the finite product gives $\prod p_i \le \prod q = q^k$. This is the
composition tool that imports per-round soundness bounds arising from *other*
protocols (for example the GMW bound of Section 4) into the $k$-round setting
without re-deriving independence. $\square$

---

## 4. Single-round soundness of the colouring protocol

We now instantiate the abstract model with the GMW protocol and quantify the
one-round soundness gap.

**Theorem 4.1 (Existence of a catching edge).** If the committed colouring $c'$ is
not proper for $E$, then there exists an edge $e \in E$ with $c'(e_1) = c'(e_2)$.

*Proof sketch.* Negating the universally quantified properness predicate produces
an existential witness — an edge whose endpoints share a colour. $\square$

**Theorem 4.2 (At least one catch).** If $c'$ is improper for $E$, then the number
of catching edges is at least one:
$$|\{e \in E : c'(e_1) = c'(e_2)\}| \ge 1.$$

*Proof sketch.* The witness edge of Theorem 4.1 belongs to the filtered set, which
is therefore nonempty, hence has cardinality at least one. $\square$

**Theorem 4.3 (Single-round soundness bound).** If $c'$ is improper for $E$ and
$m = |E| > 0$, then a verifier choosing a uniformly random edge rejects with
probability at least $1/m$:
$$\frac{1}{|E|} \ \le\ \frac{|\{e \in E : c'(e_1) = c'(e_2)\}|}{|E|}.$$

*Proof sketch.* Divide the inequality of Theorem 4.2 by the positive integer
$|E|$; monotonicity of division preserves the bound. $\square$

**Theorem 4.4 (Quantitative acceptance gap).** With the round acceptance
probability $p(E,c')$ of Definition 2.2, if $c'$ is improper and $m = |E| > 0$
then
$$p(E, c') \ \le\ 1 - \frac{1}{|E|} \ < \ 1.$$

*Proof sketch.* The accepting (distinct-endpoint) edges and the catching
(equal-endpoint) edges partition $E$, so their counts sum to $|E|$. Since there is
at least one catching edge (Theorem 4.2), the accepting count is at most $|E| - 1$;
dividing by $|E|$ gives $p \le 1 - 1/|E|$, and strict positivity of $1/|E|$ gives
$p < 1$. $\square$

**Theorem 4.5 (Amplified colouring soundness).** If $c'$ is improper and
$m = |E| > 0$, the $k$-round cheating probability tends to zero:
$$p(E, c')^{k} \xrightarrow[k \to \infty]{} 0,
\qquad\text{and}\qquad
\forall \varepsilon > 0,\ \exists k,\ p(E,c')^k < \varepsilon.$$
Moreover, this is exactly the specialization of Theorem 3.5 with $q = p(E,c') \le
1 - 1/m$, giving the explicit bound $p(E,c')^k \le (1 - 1/m)^k = ((m-1)/m)^k$.

*Proof sketch.* By Theorem 4.4, $0 \le p(E,c') < 1$; any power sequence of a base
strictly between $0$ and $1$ converges to $0$, which supplies both the limit and,
for each $\varepsilon > 0$, a round count $k$ with $p^k < \varepsilon$. The
explicit bound is Theorem 3.5 with $q = 1 - 1/m$. $\square$

**Remark 4.6 (Tightness and the width law).** The bound $1/m$ is tight: a
colouring with exactly one bad edge is accepted on the other $m-1$ edges, so its
one-round acceptance probability is exactly $(m-1)/m$. Consequently, certifying
validity with confidence $1 - 2^{-k}$ requires $\Theta(m \cdot k)$ rounds when the
per-round catch probability is pinned at $1/m$; confidence is governed by the
*width* $m$ (the number of places a lie can hide), not the depth of the proof. To
recover the clean $2^{-k}$ rate of Theorem 3.4 one instead arranges each round to
catch with probability at least $1/2$ (the hypothesis $2e \le n$).

---

## 5. Perfect honest-verifier zero knowledge

Soundness and completeness make the protocol a *proof*; the following results make
it *zero-knowledge*. We show the verifier's view is information-theoretically
independent of the prover's secret colouring.

### 5.1 Completeness

**Theorem 5.1 (Completeness).** If $c$ is a proper colouring for $E$, then for
every permutation $\pi \in S_3$ the recoloured colouring $\pi \circ c$ is also
proper. Hence the honest prover opens two distinct colours on every challenged
edge and always passes.

*Proof sketch.* Suppose $\pi(c(e_1)) = \pi(c(e_2))$ for some edge $e$. Since $\pi$
is a bijection it is injective, so $c(e_1) = c(e_2)$, contradicting properness of
$c$. $\square$

### 5.2 The view map and its bijectivity

Fix a challenged edge whose (distinct) endpoint colours are $a \ne b$. The
verifier's **view** in that round is the opened pair
$$\text{view}_{a,b}(\pi) = (\pi(a),\ \pi(b)) \in \{0,1,2\}^2.$$

**Lemma 5.2 (Distinct opening).** If $a \ne b$ then $\text{view}_{a,b}(\pi)$
consists of two distinct colours for every $\pi$.

*Proof sketch.* Injectivity of $\pi$: $\pi(a) = \pi(b)$ would force $a = b$.
$\square$

**Lemma 5.3 (Injectivity of the view map).** If $a \ne b$ then
$\pi \mapsto (\pi(a), \pi(b))$ is injective on $S_3$: the opened pair determines
the permutation.

*Proof sketch.* Suppose $\pi$ and $\sigma$ agree at $a$ and at $b$. Any third
point $x \notin \{a,b\}$ is the unique remaining element of $\{0,1,2\}$; since both
permutations are injective, $\pi(x)$ and $\sigma(x)$ must each be the unique colour
distinct from the two already-fixed images, hence equal. So $\pi = \sigma$.
$\square$

**Theorem 5.4 (View bijection).** For $a \ne b$, the map
$$\pi \mapsto (\pi(a), \pi(b))$$
is a **bijection** from $S_3$ onto the set of ordered pairs of distinct colours,
$$D = \{(x,y) \in \{0,1,2\}^2 : x \ne y\}.$$

*Proof sketch.* The map lands in $D$ (Lemma 5.2) and is injective (Lemma 5.3).
Both sets are finite with $|S_3| = 6$ and $|D| = 6$, so an injection between them
is automatically a bijection. $\square$

### 5.3 Perfect simulation

Let $U_X$ denote the uniform probability distribution on a finite nonempty set
$X$. The real transcript and simulator distributions on distinct pairs $D$ are:

- **Real:** $\mathcal{R}_{a,b} = (\text{view}_{a,b})_* U_{S_3}$, the pushforward of
  the uniform distribution on $S_3$ under the view map.
- **Simulated:** $\mathcal{S} = U_D$, a uniformly random distinct ordered pair,
  chosen with no knowledge of any colouring.

**Lemma 5.5 (Pushforward of uniform under a bijection).** If $f : X \to Y$ is a
bijection between finite nonempty sets, then $f_* U_X = U_Y$.

*Proof sketch.* For $y = f(x)$, the pushforward mass at $y$ is the total uniform
mass on the fiber $f^{-1}(y) = \{x\}$, namely $1/|X|$; since $|X| = |Y|$ this
equals $1/|Y|$, the uniform mass at $y$. $\square$

**Theorem 5.6 (Perfect honest-verifier zero knowledge).** For every challenged
edge with distinct endpoint colours $a \ne b$,
$$\mathcal{R}_{a,b} = \mathcal{S}.$$
The real transcript distribution equals the colouring-oblivious simulator's
distribution *exactly*.

*Proof sketch.* Apply Lemma 5.5 to the bijection of Theorem 5.4. The pushforward
of the uniform distribution on $S_3$ under the view map is the uniform distribution
on $D$, which is precisely $\mathcal{S}$. $\square$

**Corollary 5.7 (Colour-independence).** For any two challenged edges with distinct
endpoint colours, $\mathcal{R}_{a,b} = \mathcal{R}_{a',b'}$. The verifier's view
distribution does not depend on the actual colours — the operational statement that
the transcript leaks nothing about the secret colouring.

*Proof sketch.* Both equal $\mathcal{S}$ by Theorem 5.6. $\square$

**Corollary 5.8 (Closed-form transcript probability).** Every distinct opened pair
appears in the (real $=$ simulated) transcript with probability exactly $1/6$:
$$\mathcal{R}_{a,b}(x,y) = \frac{1}{6}\quad\text{for every }(x,y) \in D.$$

*Proof sketch.* By Theorem 5.6 the distribution is uniform on $D$, and $|D| = 6$.
$\square$

The equality in Theorem 5.6 is *exact*, not statistical: there is no negligible
gap for an adversary to exploit. This *perfect* zero knowledge is special to three
colours, where the numerical coincidence $|S_3| = 6 = |D|$ makes the view map a
bijection from a single permutation orbit.

---

## 6. Algorithms

We summarize the three procedures underlying the results. Full type-hinted
implementations appear in the accompanying software.

### 6.1 One round of the colouring protocol

**Input:** graph $(V,E)$, colouring $c$, verifier randomness.
**Output:** ACCEPT / REJECT for the round.

1. Prover samples $\pi \in S_3$ uniformly and commits to $\pi \circ c$.
2. Verifier samples an edge $(u,v) \in E$ uniformly.
3. Prover opens $(\pi(c(u)), \pi(c(v)))$.
4. Verifier accepts iff the two opened colours differ.

Completeness (Theorem 5.1) guarantees acceptance for proper $c$; single-round
soundness (Theorem 4.3) guarantees rejection probability $\ge 1/|E|$ for improper
committed colourings.

### 6.2 Soundness amplification by repetition

**Input:** round count $k$; per-round accepting fraction bound.
**Output:** overall soundness error.

Run $k$ independent rounds; accept iff all pass. By Theorem 3.3 the survival
probability is $\prod_i (|A_i|/n) \le (e/n)^k$, and under $2e \le n$ it is
$\le 2^{-k}$ (Theorem 3.4). To achieve target error $\varepsilon$ with per-round
catch probability $1/2$, set $k = \lceil \log_2(1/\varepsilon) \rceil$.

### 6.3 Transcript simulation

**Input:** the public statement (the graph), no secret colouring.
**Output:** a transcript identically distributed to the honest prover's.

Sample a uniformly random distinct ordered pair $(x,y) \in D$ and output it. By
Theorem 5.6 this reproduces the real per-round transcript exactly, certifying that
the verifier learns nothing.

---

## 7. Applications

- **Password-free authentication.** A user proves knowledge of a secret (modeled
  as a colouring / witness) without transmitting it; a wiretapper's transcript is
  pure noise (Corollary 5.7).
- **Privacy-preserving verification.** One can certify that a large computation or
  a batch of transactions is valid while revealing none of its contents, with
  soundness error driven to $2^{-k}$ by repetition (Theorem 3.4).
- **Certifying proofs of theorems.** An arithmetized formal proof is a locally
  checkable certificate; the protocol certifies its existence while the masked
  openings reveal no step (Sections 3–5 applied to the proof-step challenge
  space).

---

## 8. Discussion and future work

The analysis cleanly separates three concerns. The **combinatorial** content —
that an invalid certificate always contains a catching challenge — lives in
Section 4 and is protocol-specific. The **probabilistic** content — that
independent repetition multiplies survival probabilities — lives in Section 3 and
is protocol-agnostic; the product-measure identity (Theorem 3.1) is an *equality*,
which is what makes the amplification tight. The **information-theoretic** content
— that a uniformly masked opening reveals nothing — lives in Section 5 and hinges
on the exact size coincidence $|S_3| = |D| = 6$.

Three directions extend these findings.

1. **The repetition–revelation tradeoff is governed by proof width, not length.**
   For a certificate with $n$ steps of which at most one is faulty, the number of
   independent random-step challenges required to certify validity with confidence
   $1 - 2^{-k}$ grows like $n \cdot k$, and no verifier opening fewer than a
   constant fraction of $n\cdot k$ step-values can achieve that confidence. The
   single-round catch probability is exactly $1/n$, so the per-round error factor
   is pinned at $(n-1)/n$; confidence is a function of the *width* $n$ (how many
   places a lie can hide), not the depth. The tightness result (Remark 4.6) shows
   the geometric decay cannot be beaten by cleverer single-step verifiers, so the
   only remaining lever is the number of rounds, making the $n\cdot k$ scaling law
   precise and falsifiable.

2. **Perfect hiding survives adaptive, correlated challenges.** If every committed
   step is masked by an independent uniform pad over a finite abelian group, then
   even an adaptive verifier who chooses each new challenge as an arbitrary
   function of all previously opened values learns nothing beyond the single bit
   "valid / invalid"; the joint distribution of the entire transcript is a fixed
   function of that bit alone. A uniform pad turns each opened value into an
   independent uniform group element, so conditioning on earlier openings cannot
   skew later ones. The exact preimage-count equality of Section 5 (a single
   commitment) is the base case; the coupling $\text{mask} \mapsto (s - s') +
   \text{mask}$ transports it across secrets, suggesting a product-coupling
   induction over the whole transcript.

3. **Amplification is optimal: no sub-multiplicative soundness protocol exists.**
   Among all protocols whose rounds use independent uniform challenges and a
   memoryless accept/reject rule, the product law $\text{survival} = \prod
   \text{per-round survival}$ is optimal: no such protocol can drive $k$-round
   soundness error below the product of its per-round errors. The product-measure
   identity (Theorem 3.1) is an equality, not merely a bound, which pins the
   achievable rate exactly.

---

## 9. Conclusion

We have assembled the probabilistic backbone of zero-knowledge proof-checking into
three theorems and their corollaries: independent repetition multiplies survival
probabilities and drives soundness error to $2^{-k}$; a single random challenge
catches an invalid certificate with probability at least $1/n$, tightly; and a
uniformly masked opening makes the transcript *perfectly* independent of the
secret, with every distinct pair opened with probability exactly $1/6$. Together
these show that certainty about a fact and knowledge of its proof can travel
separately — that one can, in a precise and provable sense, prove a theorem without
showing the proof.
