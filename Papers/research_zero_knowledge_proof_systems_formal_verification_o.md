# A Complete Analysis of the Zero-Knowledge Proof System for Graph 3-Colourability

## Abstract

We give a self-contained, rigorous treatment of the interactive zero-knowledge
proof system for graph 3-colourability, establishing all three of its defining
properties — completeness, soundness, and zero knowledge — together with a
quantitative analysis of soundness amplification under sequential repetition. The
protocol is the classical edge-challenge scheme: a prover commits to a randomly
recoloured proper 3-colouring, and a verifier challenges a single random edge and
checks that its endpoints reveal distinct colours. We prove that (i) an honest
prover is always accepted; (ii) a prover committed to an improper colouring is
rejected in a single round with probability at least $1/|E|$, equivalently is
accepted with probability at most $1 - 1/|E|$; (iii) the $k$-round acceptance
probability of a cheating prover is exactly the $k$-th power of the one-round
probability and hence converges to zero, so any target soundness error is
achievable with finitely many rounds; and (iv) for a challenged edge with distinct
endpoint colours, the map sending a colour permutation to the revealed ordered
pair is a bijection onto the set of ordered pairs of distinct colours, so the
verifier's real view is distributed *exactly* like a colouring-independent uniform
sample — establishing *perfect* honest-verifier zero knowledge. We highlight that
the perfect (rather than merely statistical) simulability is a numerical
coincidence special to a palette of three colours.

**Keywords:** zero-knowledge proof, graph 3-colouring, simulation paradigm,
completeness, soundness, soundness amplification, honest-verifier zero knowledge,
symmetric group, commitment.

---

## 1. Introduction

A zero-knowledge proof allows one party, the *prover*, to convince another, the
*verifier*, that a statement is true, while conveying no information beyond the
truth of the statement itself. Since their introduction, such proofs have become a
central tool of modern cryptography, enabling privacy-preserving authentication,
verifiable computation, and confidential transactions.

The canonical illustration is a proof system for **graph 3-colourability**: given a
graph, prove that its vertices can be coloured with three colours so that adjacent
vertices differ, without revealing the colouring. This problem is NP-complete, so a
zero-knowledge proof for it is, by reduction, a template for a zero-knowledge proof
of any NP statement. The scheme we analyse is the classical edge-challenge
protocol built on a commitment primitive.

This paper provides a complete and precise account of the protocol's guarantees.
We prove completeness and soundness, give a sharp quantitative soundness bound,
analyse soundness amplification under sequential repetition, and establish perfect
honest-verifier zero knowledge via an exact distributional identity. Every result
is stated inline in full mathematical detail with a proof sketch.

## 2. Definitions

Throughout, let $V$ be a finite set of **vertices** and let
$E \subseteq V \times V$ be a finite set of **edges**, represented as a finite
collection of ordered pairs. Colours are drawn from the three-element palette
$\{0, 1, 2\}$, which we identify with the cyclic set of residues modulo $3$.

**Definition 2.1 (Colouring).** A *3-colouring* is a function
$c : V \to \{0, 1, 2\}$ assigning a colour to each vertex.

**Definition 2.2 (Proper colouring).** A 3-colouring $c$ is *proper* for the edge
set $E$ if the endpoints of every edge receive distinct colours:

$$\mathrm{Proper}(E, c) \;\iff\; \forall (u, v) \in E,\ c(u) \neq c(v).$$

**Definition 2.3 (Colour permutation).** A *colour permutation* is a bijection
$\pi : \{0, 1, 2\} \to \{0, 1, 2\}$. The set of all such permutations forms the
symmetric group $S_3$, which has exactly $|S_3| = 3! = 6$ elements. Given a
colouring $c$ and a permutation $\pi$, the *recoloured* colouring is
$\pi \circ c$, i.e. the map $v \mapsto \pi(c(v))$.

**Definition 2.4 (Revealed view).** For an edge with endpoint colours $a$ and $b$,
and a colour permutation $\pi$, the verifier's *revealed view* is the ordered pair
of opened colours

$$\mathrm{view}(a, b, \pi) = (\pi(a), \pi(b)) \in \{0,1,2\} \times \{0,1,2\}.$$

**The protocol.** The prover holds a proper colouring $c$. In one round:

1. The prover samples $\pi \in S_3$ uniformly at random and commits to the
   recoloured colouring $\pi \circ c$ (one commitment per vertex).
2. The verifier samples an edge $(u, v) \in E$ uniformly at random and sends it as
   a challenge.
3. The prover opens the two committed colours $(\pi(c(u)), \pi(c(v)))$.
4. The verifier accepts iff the two opened colours differ.

The commitment is assumed *binding* (the prover cannot change committed values
after step 1) and *hiding* (unopened commitments reveal nothing). Our analysis is
information-theoretic given these commitment properties; it isolates the
combinatorial and probabilistic core of the proof system.

## 3. Completeness

**Theorem 3.1 (Permutations preserve properness).** If $c$ is a proper colouring
for $E$ and $\pi \in S_3$ is any colour permutation, then $\pi \circ c$ is also a
proper colouring for $E$.

*Proof.* Let $(u, v) \in E$. Suppose for contradiction that
$\pi(c(u)) = \pi(c(v))$. Since $\pi$ is a bijection, it is injective, so
$c(u) = c(v)$, contradicting properness of $c$ on the edge $(u, v)$. Hence
$\pi(c(u)) \neq \pi(c(v))$ for every edge, i.e. $\pi \circ c$ is proper. $\qquad\blacksquare$

**Corollary 3.2 (Completeness).** An honest prover holding a proper colouring is
accepted with probability $1$ in every round, for every choice of permutation and
every challenged edge.

*Proof.* By Theorem 3.1 the committed colouring $\pi \circ c$ is proper, so for the
challenged edge $(u, v)$ the opened pair $(\pi(c(u)), \pi(c(v)))$ consists of
distinct colours, and the verifier accepts. $\qquad\blacksquare$

## 4. Soundness

We now analyse a prover committed to an arbitrary colouring $c'$ that is **not**
proper. We call an edge $(u, v)$ a *catching edge* (for $c'$) if $c'(u) = c'(v)$;
challenging such an edge forces the prover to open two equal colours and be
rejected.

**Lemma 4.1 (Existence of a catching edge).** If $c'$ is not a proper colouring for
$E$, then there exists an edge $(u, v) \in E$ with $c'(u) = c'(v)$.

*Proof.* Negating the definition of properness, $\neg\,\mathrm{Proper}(E, c')$
means it is not the case that all edges have distinct endpoint colours; hence some
edge $(u, v) \in E$ satisfies $c'(u) = c'(v)$. $\qquad\blacksquare$

**Lemma 4.2 (At least one catching edge).** If $c'$ is not proper for $E$, then the
number of catching edges is at least one:

$$\big|\{\, (u,v) \in E : c'(u) = c'(v) \,\}\big| \ge 1.$$

*Proof.* By Lemma 4.1 the set of catching edges is nonempty; a nonempty finite set
has cardinality at least $1$. $\qquad\blacksquare$

**Theorem 4.3 (One-round soundness bound).** Suppose $|E| > 0$ and $c'$ is not
proper. Then a verifier challenging a uniformly random edge rejects with
probability at least $1/|E|$:

$$\frac{1}{|E|} \;\le\; \frac{\big|\{(u,v) \in E : c'(u) = c'(v)\}\big|}{|E|}.$$

*Proof.* Divide the inequality of Lemma 4.2 by the positive integer $|E|$. The
right-hand side is exactly the probability that a uniformly random edge is a
catching edge, i.e. the rejection probability. $\qquad\blacksquare$

### 4.1 A quantitative acceptance model for cheating provers

To analyse repetition, we model the one-round *acceptance* probability of a prover
committed to $c'$ as the fraction of edges the verifier fails to catch — the edges
whose endpoints carry distinct colours.

**Definition 4.4 (One-round acceptance probability).** For $c' : V \to \{0,1,2\}$,

$$p(E, c') \;=\; \frac{\big|\{(u,v) \in E : c'(u) \neq c'(v)\}\big|}{|E|}.$$

**Proposition 4.5 (Valid probability).** For every $E$ and $c'$,
$0 \le p(E, c') \le 1$.

*Proof.* Nonnegativity is immediate since both numerator and denominator are
nonnegative. For the upper bound, if $|E| = 0$ the quantity is $0 \le 1$;
otherwise the number of edges with distinct endpoints is at most $|E|$, so the
ratio is at most $1$. $\qquad\blacksquare$

**Theorem 4.6 (Quantitative acceptance gap).** If $|E| > 0$ and $c'$ is not proper,
then

$$p(E, c') \;\le\; 1 - \frac{1}{|E|}.$$

*Proof.* Partition the edges into those with distinct endpoints and those with
equal endpoints (the catching edges); their cardinalities sum to $|E|$. By
Lemma 4.2 there is at least one catching edge, so the number of
distinct-endpoint edges is at most $|E| - 1$. Dividing by $|E|$ gives
$p(E, c') \le (|E| - 1)/|E| = 1 - 1/|E|$. $\qquad\blacksquare$

**Corollary 4.7 (Strict soundness).** If $|E| > 0$ and $c'$ is not proper, then
$p(E, c') < 1$.

*Proof.* Since $|E| > 0$ we have $1/|E| > 0$, so by Theorem 4.6,
$p(E, c') \le 1 - 1/|E| < 1$. $\qquad\blacksquare$

## 5. Soundness Amplification

A single round has a constant, possibly tiny, soundness gap. Sequential repetition
with independent randomness turns this into an arbitrarily strong guarantee.
Running $k$ independent rounds, and accepting only if all rounds accept, multiplies
the per-round acceptance probabilities: a cheating prover is accepted across all
$k$ rounds with probability $p(E, c')^k$.

**Theorem 5.1 (Soundness amplification).** Let $|E| > 0$ and let $c'$ be improper,
with one-round acceptance probability $p = p(E, c')$. Then the $k$-round cheating
acceptance probability tends to zero:

$$\lim_{k \to \infty} p^{\,k} = 0.$$

*Proof.* By Proposition 4.5 and Corollary 4.7 we have $0 \le p < 1$. For any real
$p$ with $0 \le p < 1$, the geometric sequence $p^k$ converges to $0$ as
$k \to \infty$. $\qquad\blacksquare$

**Theorem 5.2 (Achievability of any error target).** Under the hypotheses of
Theorem 5.1, for every $\varepsilon > 0$ there exists a number of rounds $k \in
\mathbb{N}$ such that the $k$-round cheating acceptance probability is below the
target error:

$$p^{\,k} < \varepsilon.$$

*Proof.* Since $0 \le p < 1$, the powers $p^k$ can be made smaller than any
positive $\varepsilon$; formally, this is the statement that for $p < 1$ and
$\varepsilon > 0$ there is $k$ with $p^k < \varepsilon$. (When $p = 0$ any
$k \ge 1$ works; when $0 < p < 1$, taking $k > \log \varepsilon / \log p$
suffices.) $\qquad\blacksquare$

**Remark 5.3 (Round budget).** Combining Theorem 4.6 with Theorem 5.2, using
$p \le 1 - 1/|E|$ and the estimate $-\log(1 - 1/|E|) \ge 1/|E|$, it suffices to run

$$k \;\ge\; |E| \cdot \ln(1/\varepsilon)$$

rounds to guarantee cheating acceptance probability below $\varepsilon$. The round
budget is thus linear in the number of edges and logarithmic in the inverse error.

## 6. Honest-Verifier Zero Knowledge

The zero-knowledge property is formalised via the **simulation paradigm**: the
proof system leaks nothing if there is an efficient *simulator* that, without
access to the prover's secret colouring, produces transcripts distributed
identically to those of a real interaction. Since a simulated transcript can be
generated by the verifier alone, it carries no information about the secret; if the
real transcript has the same distribution, it too carries none.

We analyse the verifier's view on a single challenged edge. Because the prover
holds a proper colouring, the two endpoint colours $a, b$ of any edge are distinct;
we therefore fix $a \neq b$ and study the distribution of the revealed pair
$(\pi(a), \pi(b))$ as $\pi$ ranges uniformly over $S_3$.

**Lemma 6.1 (Reveals are distinct).** If $a \neq b$ then for every $\pi \in S_3$,
$\mathrm{view}(a, b, \pi) = (\pi(a), \pi(b))$ has $\pi(a) \neq \pi(b)$.

*Proof.* If $\pi(a) = \pi(b)$ then injectivity of $\pi$ gives $a = b$, a
contradiction. $\qquad\blacksquare$

**Lemma 6.2 (The view determines the permutation).** For fixed $a \neq b$, the map
$\pi \mapsto (\pi(a), \pi(b))$ is injective on $S_3$.

*Proof.* Suppose $\pi(a) = \sigma(a)$ and $\pi(b) = \sigma(b)$ for two permutations
$\pi, \sigma \in S_3$. We show $\pi = \sigma$ by checking agreement on every point
of $\{0,1,2\}$. On $a$ and $b$ they agree by hypothesis. Let $x$ be the unique
third point, distinct from both $a$ and $b$. Both $\pi(x)$ and $\sigma(x)$ must
differ from the two already-assigned values $\pi(a) = \sigma(a)$ and
$\pi(b) = \sigma(b)$ (again by injectivity), and in a three-element set there is
only one remaining value; hence $\pi(x) = \sigma(x)$. Therefore $\pi = \sigma$.
$\qquad\blacksquare$

**Theorem 6.3 (Perfect honest-verifier zero knowledge).** Fix a challenged edge
with distinct endpoint colours $a \neq b$. Then the map

$$\Phi : S_3 \longrightarrow \{(x, y) \in \{0,1,2\}^2 : x \neq y\}, \qquad
\Phi(\pi) = (\pi(a), \pi(b)),$$

is a **bijection**. Consequently, when $\pi$ is drawn uniformly from $S_3$, the
revealed pair $\Phi(\pi)$ is distributed uniformly over the set of ordered pairs of
distinct colours — a distribution that does not depend on $a$, $b$, or the
underlying colouring.

*Proof.* By Lemma 6.1, $\Phi$ indeed maps into the set of distinct ordered pairs;
by Lemma 6.2 it is injective. Both the domain and codomain are finite of the same
size: $|S_3| = 6$, and the ordered pairs of distinct colours from a three-element
set number $3 \times 2 = 6$. An injective map between finite sets of equal
cardinality is a bijection. Pushing the uniform distribution on $S_3$ through the
bijection $\Phi$ yields the uniform distribution on the codomain. $\qquad\blacksquare$

**Corollary 6.4 (Simulator and perfect simulability).** Define a simulator that,
given a challenged edge, outputs a uniformly random ordered pair of distinct
colours. Then for a real interaction on any edge (whose endpoint colours are
necessarily distinct), the distribution of the verifier's revealed pair is
*exactly equal* to the distribution of the simulator's output. Hence the protocol
is *perfect* honest-verifier zero knowledge on a per-edge challenge.

*Proof.* By Theorem 6.3 the real revealed pair is uniform over the ordered pairs of
distinct colours, which is precisely the simulator's output distribution. The two
distributions are identical — not merely close — so the transcript reveals nothing
about the colouring beyond the distinctness already guaranteed by properness.
$\qquad\blacksquare$

**Remark 6.5 (Why three colours is special).** Theorem 6.3 hinges on the
coincidence $|S_3| = 6 = |\{(x,y) : x \neq y\}|$ over a three-element palette. For a
palette of $q \ge 4$ colours, a single permutation applied to two fixed distinct
colours cannot cover all $q(q-1)$ ordered pairs of distinct colours, so the reveal
from one permutation orbit is *not* uniform. Perfect simulability then requires
either a different opening (revealing the full committed colouring) or an averaging
simulator. The three-colour case is thus the unique palette size for which the
per-edge zero-knowledge argument is a pure bijection rather than an averaging
argument.

## 7. Algorithms

We summarise the constructive content as algorithms; full implementations appear in
the accompanying demonstration code.

**Algorithm A — Honest prover round.** Sample $\pi \in S_3$ uniformly; commit to
$v \mapsto \pi(c(v))$; upon receiving the challenge edge $(u,v)$, open
$(\pi(c(u)), \pi(c(v)))$.

**Algorithm B — Verifier round.** Sample an edge $(u,v) \in E$ uniformly; receive
the opened pair; accept iff the two colours differ.

**Algorithm C — Sequential amplification.** Repeat Algorithms A–B for $k$ rounds
with fresh randomness; accept overall iff all $k$ rounds accept. Choosing
$k \ge |E|\,\ln(1/\varepsilon)$ guarantees cheating acceptance below $\varepsilon$.

**Algorithm D — Simulator.** Given a challenge edge, output a uniformly random
ordered pair of distinct colours from $\{0,1,2\}$. By Corollary 6.4 its output is
distributed identically to a real transcript.

## 8. Applications

Because graph 3-colourability is NP-complete, the analysis above is a universal
blueprint: any statement whose truth admits an efficient certificate can be proved
in zero knowledge by reducing it to 3-colourability and running this protocol.
Practical descendants of this idea include privacy-preserving authentication
(proving possession of a credential without revealing it), confidential
transactions (proving validity without revealing amounts or parties), and
verifiable computation (proving a computation was performed correctly without
re-executing it). The amplification analysis of Section 5 directly governs the cost
of these deployments: the number of repetitions is the security-versus-cost dial,
and Remark 5.3 gives its precise setting.

## 9. Discussion

The treatment separates cleanly into three layers. Completeness (Section 3) is a
one-line consequence of the injectivity of permutations. Soundness (Section 4) is
purely combinatorial — the existence of a single catching edge — and amplification
(Section 5) is purely analytic — geometric decay of independent-round
probabilities. Zero knowledge (Section 6) is a counting coincidence realised as a
bijection. The strength of the design is precisely that these three concerns are
orthogonal: each can be understood, and each proof read, in isolation.

Two features deserve emphasis. First, the zero-knowledge guarantee here is
*perfect*: the real and ideal transcript distributions are equal, not merely
statistically close, so no error term propagates through the analysis. Second, the
soundness guarantee is *sharp*: the worst-case cheating strategy miscolours a
single edge, caught with probability exactly $1/|E|$ per round, so the geometric
rate $(1 - 1/|E|)^k$ is attained and cannot be improved without enlarging the
challenge space.

## 10. Future Directions

Several precise conjectures extend this work.

*Perfect simulability at the boundary case of three colours.* For proofs of proper
$q$-colourability, a per-edge transcript that opens the two permuted endpoint
colours is perfectly simulable — real and simulated transcripts identically
distributed — if and only if $q = 3$; for every $q \ge 4$ the single-permutation
opening is strictly non-uniform on distinct pairs, and perfect simulability
requires opening the entire committed colouring. Perfect equality of the real and
ideal distributions is a coincidence of two counts — the number of colour
symmetries and the number of admissible opened pairs — which agree exactly at three
colours, the smallest nontrivial palette and the unique one where the argument is a
pure bijection rather than an averaging.

*Sequential repetition is soundness-optimal up to the edge count.* For any graph
with $m$ edges, the $k$-round soundness error of the edge-challenge protocol is
exactly $(1 - 1/m)^k$ in the worst case over improper colourings, and no
relabelling or reordering of rounds beats this rate; the bound is attained by
colourings that miscolour a single edge. The worst cheating strategy hides its
single flaw in one edge out of $m$, so each independent round catches it with
probability exactly $1/m$, and multiplicativity of independent rounds turns this
constant gap into a sharp geometric law.

*Parallel challenges preserve the zero-leakage guarantee.* Challenging a batch of
edges simultaneously, each with its own fresh colour permutation, yields a joint
transcript that is still perfectly simulable, provided distinct permutations are
used per edge; sharing a single permutation across edges leaks colour-relationship
information across the batch.

## 11. Conclusion

We have established the three pillars of the zero-knowledge proof system for graph
3-colourability — completeness, soundness, and perfect honest-verifier zero
knowledge — with sharp quantitative bounds and a full amplification analysis. The
honest prover always succeeds; a cheating prover is caught with probability at
least $1/|E|$ per round, driven to certainty by repetition at a cost linear in
$|E|$ and logarithmic in the inverse error; and the verifier provably learns
nothing, because the real transcript on any edge is distributed exactly like a
colouring-independent uniform sample. The perfect zero-knowledge guarantee rests on
a small arithmetic miracle unique to three colours, marking it as the natural and
optimal setting for this classical construction.
