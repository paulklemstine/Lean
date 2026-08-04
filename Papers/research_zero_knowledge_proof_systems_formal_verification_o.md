# Exact Completeness, Soundness Amplification, and Perfect Zero Knowledge for the Graph 3-Colouring Protocol

**Author:** Aristotle
**Date:** 2026-08-03

---

## Abstract

We give a fully rigorous, quantitatively exact analysis of the classical interactive proof
system for graph 3-colourability. Working with a finite edge set $E \subseteq V \times V$
and colourings $c : V \to \mathbb{Z}_3$, we define the one-round acceptance and rejection
probabilities of a committed colouring as exact rational fractions of the edge set, and
prove: (i) *complementarity*, $\alpha(E,c) + \rho(E,c) = 1$ whenever $\#E > 0$;
(ii) *perfect completeness*, $\alpha(E,c) = 1$ for every proper colouring $c$; (iii) *sharp
one-round soundness*, $\alpha(E,c') \le 1 - 1/\#E$ for every improper committed colouring
$c'$; and (iv) *soundness amplification*, $\alpha(E,c')^k \le (1 - 1/\#E)^k$ for $k$
independent challenges against a fixed improper commitment. On the privacy side we work
with genuine probability distributions on the six-element set $\mathcal{P}$ of ordered
pairs of distinct colours, and prove (v) *transcript uniformity*, that a real protocol
transcript assigns mass exactly $1/6$ to each element of $\mathcal{P}$; (vi) *colour-and-edge
independence*, that the transcript law is literally identical across all graphs, all
proper colourings, and all challenged edges; (vii) *perfect honest-verifier zero knowledge*,
that the real transcript law equals the law produced by a colouring-oblivious simulator;
and (viii) *zero distinguishing advantage*, that every deterministic Boolean distinguisher
accepts real and simulated transcripts with exactly equal probability, so that both
one-sided advantages vanish identically. The privacy results are information-theoretic:
they hold for all distinguishers with no computational restriction and involve no
security parameter or negligible function. We isolate the group-theoretic mechanism
underlying (v)–(viii) — the simply transitive action of $S_3$ on $\mathcal{P}$ — discuss
algorithmic consequences and parameter choices, and outline the extensions required to
lift the analysis to commitment-scheme semantics, adaptive provers, and general verifiers.

**Keywords:** zero-knowledge proofs, graph 3-colourability, simulation paradigm,
honest-verifier zero knowledge, soundness amplification, perfect completeness,
interactive proof systems, symmetric group action.

---

## 1. Introduction

### 1.1 The problem

An interactive proof system lets a computationally unbounded *prover* convince a
resource-bounded *verifier* of the truth of a statement. It is a *zero-knowledge* proof
system if, additionally, the verifier ends the interaction knowing that the statement is
true and nothing else — in particular, without having gained the ability to convince a
third party, or to reconstruct the prover's witness.

Making the phrase "and nothing else" mathematically precise is the conceptual achievement
of the field, and the answer is the **simulation paradigm**: the interaction leaks nothing
if a machine that does *not* know the witness can produce a transcript with the same
probability law. Anything computable from a real transcript is then computable from a
simulated one, which was manufactured out of coin flips alone.

The canonical vehicle for this idea is the graph 3-colouring protocol. Since 3-colourability
is NP-complete, a zero-knowledge proof for it yields, by reduction, a zero-knowledge proof
for every language in NP.

### 1.2 What this paper contributes

The protocol is textbook material, but the standard treatment is informal in two places
that reward precision. First, the soundness bound is usually stated asymptotically ("with
probability at least $1/|E|$ the cheat is caught"), whereas the exact statement is a
complementary pair of rational numbers whose sum is one, and the conversion between "at
least $1/\#E$ rejection" and "at most $1 - 1/\#E$ acceptance" is exactly where the
bookkeeping must be airtight. Second, the zero-knowledge claim is usually justified by the
sentence "the two revealed colours are a random pair of distinct colours", whereas the
content is an equality of probability distributions, quantified over *all* graphs,
colourings and edges, and it should be stated as such.

We therefore develop:

1. **An exact rational probability model** for the one-round acceptance and rejection
   events, in which every claim is an identity or an inequality between explicit fractions
   of cardinalities, with no asymptotics.
2. **A distributional model of privacy** in which real and simulated transcripts are
   genuine probability distributions on a six-element sample space, and privacy is stated
   as literal equality of distributions and as vanishing of every distinguisher's
   advantage.
3. **A clean isolation of the mechanism**: everything on the privacy side reduces to the
   fact that $S_3$ acts simply transitively on the ordered pairs of distinct elements of a
   three-element set.

### 1.3 Organisation

Section 2 fixes notation and defines the protocol. Section 3 develops the soundness
model and proves complementarity, perfect completeness, one-round soundness, and
amplification. Section 4 develops the privacy model and proves uniformity, independence,
perfect zero knowledge, and zero advantage. Section 5 gives the algorithms and their
complexity. Section 6 discusses parameter selection and applications. Section 7 states
the scope of the model honestly and lists the extensions it invites.

---

## 2. Setting

### 2.1 Graphs and colourings

Throughout, $V$ is a type of *vertices* and $E$ is a **finite set of edges**, each edge an
ordered pair $e = (e_1, e_2) \in V \times V$. We write $\#E$ for the cardinality of $E$
and assume $\#E > 0$ wherever a probability is divided by it. Working with ordered pairs
and an explicit finite edge set (rather than an abstract undirected graph) is deliberate:
it makes the sampling model "choose $e$ uniformly from $E$" completely unambiguous, and it
is exactly the data the verifier needs.

**Definition 2.1 (Colouring).** A *3-colouring* of $V$ is a function $c : V \to \mathbb{Z}_3$,
where $\mathbb{Z}_3 = \{0,1,2\}$ is the three-element colour set.

**Definition 2.2 (Proper colouring).** A colouring $c$ is *proper for $E$*, written
$\mathrm{Proper}(E,c)$, if
$$\forall e \in E,\quad c(e_1) \neq c(e_2).$$
A graph is *3-colourable* if some $c$ is proper for its edge set.

**Definition 2.3 (Distinct pairs).** The *transcript space* is
$$\mathcal{P} \;=\; \{(a,b) \in \mathbb{Z}_3 \times \mathbb{Z}_3 \;:\; a \neq b\},
\qquad \#\mathcal{P} = 6 .$$

### 2.2 The one-round protocol

Fix a graph $(V,E)$. The prover holds a colouring $c$ claimed proper. One round proceeds:

1. **Palette randomisation.** The prover samples $\pi \in S_3$ uniformly at random from
   the six permutations of the colour set and forms $c_\pi = \pi \circ c$.
2. **Commitment.** For each vertex $v$, the prover commits to $c_\pi(v)$, producing
   a per-vertex commitment that is *binding* (the prover cannot later open it to a
   different value) and *hiding* (the verifier learns nothing from an unopened
   commitment).
3. **Challenge.** The verifier samples an edge $e \in E$ uniformly at random and sends it.
4. **Response.** The prover opens the commitments at $e_1$ and $e_2$.
5. **Decision.** The verifier accepts iff the two opened colours are distinct.

The *transcript* observed by the verifier in the idealised model analysed here is the
opened pair $(c_\pi(e_1), c_\pi(e_2)) \in \mathcal{P}$ together with the challenge $e$.
Since $e$ is the verifier's own uniform coin, the informative part of the transcript is
the opened pair, and that is the object whose law we compute.

**Remark 2.4 (Idealisation).** We model the commitment as an ideal locked box: binding is
captured by treating the prover as committing to a *fixed function* $c'$ before seeing the
challenge, and hiding is captured by omitting the commitment strings from the transcript.
This is the standard first-order model; Section 7 discusses lifting it.

### 2.3 The two analyses

The two halves of the analysis look at the same round through different lenses.

- **Soundness lens.** The prover's commitment is a fixed function $c' : V \to \mathbb{Z}_3$,
  possibly improper. The only randomness is the verifier's choice of edge. Probabilities
  are therefore exact rational fractions of $\#E$.
- **Privacy lens.** The colouring $c$ is proper and the challenged edge $e$ is fixed; the
  randomness is the prover's palette permutation $\pi$. Probabilities live on the
  six-element space $\mathcal{P}$.

---

## 3. Completeness, soundness, and amplification

### 3.1 The exact probability model

**Definition 3.1 (Acceptance and rejection probability).** For a finite edge set $E$ with
$\#E > 0$ and a committed colouring $c' : V \to \mathbb{Z}_3$, define
$$\alpha(E, c') \;=\; \frac{\#\{\, e \in E : c'(e_1) \neq c'(e_2) \,\}}{\#E}
\;\in\; \mathbb{Q},$$
$$\rho(E, c') \;=\; \frac{\#\{\, e \in E : c'(e_1) = c'(e_2) \,\}}{\#E}
\;\in\; \mathbb{Q}.$$

These are literally the probabilities of acceptance and rejection in one round, because
the verifier's edge is uniform on $E$ and the decision is a deterministic predicate of the
edge once $c'$ is fixed. Both are exact rationals; nothing is approximated.

**Theorem 3.2 (Complementarity).** *For every finite $E$ with $\#E > 0$ and every
$c' : V \to \mathbb{Z}_3$,*
$$\alpha(E, c') + \rho(E, c') = 1 .$$

*Proof.* The predicates $c'(e_1) \neq c'(e_2)$ and $c'(e_1) = c'(e_2)$ are exact negations
of one another, so the two filtered subsets of $E$ partition $E$ and their cardinalities
satisfy
$$\#\{e \in E : c'(e_1) \neq c'(e_2)\} + \#\{e \in E : c'(e_1) = c'(e_2)\} = \#E$$
as natural numbers. Casting this identity into $\mathbb{Q}$ and dividing by
$\#E \neq 0$ (which is legitimate precisely because $\#E > 0$) gives the claim. $\square$

Theorem 3.2 is elementary but load-bearing: it is the bridge that converts every *lower*
bound on the probability of catching a cheat into an *upper* bound on the cheat's success,
and vice versa. Every subsequent quantitative statement passes through it.

### 3.2 Perfect completeness

**Theorem 3.3 (Perfect completeness).** *Let $\#E > 0$ and let $c$ be proper for $E$.
Then*
$$\alpha(E, c) = 1 .$$

*Proof.* We claim the filtered set of accepting edges is all of $E$. One inclusion is
immediate, since a filtered subset is contained in $E$. For the converse, let $e \in E$;
properness of $c$ gives $c(e_1) \neq c(e_2)$, so $e$ satisfies the filter predicate and
lies in the filtered set. Hence the numerator equals $\#E$, and since $\#E \neq 0$ in
$\mathbb{Q}$, the quotient is $1$. $\square$

This is *perfect* completeness: the honest prover is accepted with probability exactly one,
in every round, with no error term. In particular, by Theorem 3.2, $\rho(E,c) = 0$: an
honest prover is never rejected, so a single rejection anywhere in a repeated execution is
conclusive evidence of cheating. This one-sidedness is a genuine design feature, not a
technicality: it means the verifier's rejection is a *proof of dishonesty*, and it makes
the amplification analysis of Section 3.4 a pure product of per-round bounds.

### 3.3 One-round soundness

We use the following counting fact, which is the entire content of soundness at the
one-round level.

**Lemma 3.4 (Rejection lower bound).** *Let $\#E > 0$ and suppose $c'$ is **not** proper
for $E$. Then*
$$\rho(E, c') \;\geq\; \frac{1}{\#E}.$$

*Proof sketch.* Failure of properness means there exists $e^\star \in E$ with
$c'(e^\star_1) = c'(e^\star_2)$. Hence the rejecting subset
$\{e \in E : c'(e_1) = c'(e_2)\}$ is non-empty, so its cardinality is at least $1$, and
dividing by $\#E > 0$ preserves the inequality. $\square$

**Theorem 3.5 (One-round soundness).** *Let $\#E > 0$ and let $c'$ be a committed
colouring that is not proper for $E$. Then*
$$\alpha(E, c') \;\leq\; 1 - \frac{1}{\#E}.$$

*Proof.* By Theorem 3.2, $\alpha(E,c') = 1 - \rho(E,c')$. By Lemma 3.4,
$\rho(E,c') \geq 1/\#E$. Substituting and rearranging (a linear step) yields the bound.
$\square$

**Remark 3.6 (Sharpness).** The bound is attained. Take any graph with $\#E = m$ that
admits a colouring failing on exactly one edge and correct on the other $m-1$ — for
instance, a path with $m$ edges, properly 2-coloured except that one interior vertex
copies its neighbour. Then $\rho = 1/m$ exactly and $\alpha = 1 - 1/m$ exactly. So no
better one-round bound is available without further assumptions on the graph: the
*minimum number of monochromatic edges over all colourings*, i.e. the "3-cut deficiency"
of the graph, is the true parameter, and it can equal $1$.

### 3.4 Soundness amplification

**Theorem 3.7 (Amplification under independent repetition).** *Let $\#E > 0$, let $c'$ be
improper for $E$, and let $k \in \mathbb{N}$. If $k$ challenges are sampled independently
and the prover is committed to $c'$ throughout, the probability that all $k$ rounds accept
satisfies*
$$\alpha(E, c')^{\,k} \;\leq\; \Bigl(1 - \frac{1}{\#E}\Bigr)^{k}.$$

*Proof.* Independence of the $k$ challenges makes the probability of accepting in all
rounds the $k$-th power of the one-round acceptance probability. It then suffices to
observe that $x \mapsto x^k$ is monotone non-decreasing on $[0,\infty)$ and apply it to the
inequality of Theorem 3.5. The side condition needed for monotonicity is
$\alpha(E,c') \geq 0$, which holds because $\alpha$ is a quotient of a cardinality by a
positive cardinality. $\square$

**Corollary 3.8 (Parameter selection).** *Write $m = \#E$ and let $\varepsilon \in (0,1)$
be a target soundness error. Since $(1 - 1/m)^m \le e^{-1}$ for all $m \ge 1$, choosing*
$$k \;=\; \bigl\lceil m \ln(1/\varepsilon) \bigr\rceil$$
*forces $\alpha(E,c')^{k} \le \varepsilon$ for every improper $c'$.*

*Proof sketch.* $(1-1/m)^k = \bigl((1-1/m)^m\bigr)^{k/m} \le e^{-k/m} \le \varepsilon$ for
$k \ge m\ln(1/\varepsilon)$. $\square$

Thus a *linear-in-$m$* number of rounds buys a *constant-factor-in-the-exponent* security
level: $k = 100m$ rounds gives error below $e^{-100} \approx 10^{-43.4}$. This is the
decisive practical point. A single round is nearly useless — for $m = 1000$ a cheat
survives with probability $0.999$ — yet the protocol as a whole is arbitrarily reliable,
because a stubborn per-round detection probability of $1/m$, compounded $\Theta(m)$ times,
is overwhelming.

**Remark 3.9 (Scope of Theorem 3.7).** As stated, the theorem bounds a prover locked into
a *fixed* $c'$ across all rounds. In a real execution the prover recommits each round and
may vary the committed function; the binding property of the commitment scheme is what
licenses treating each round's commitment as a fixed function *for that round*, after
which the same product bound applies round by round. Section 7 revisits this.

---

## 4. Privacy: uniformity, independence, and perfect zero knowledge

### 4.1 The transcript distributions

Both parties' views in a round are probability distributions on $\mathcal{P}$, the
six-element set of ordered pairs of distinct colours.

**Definition 4.1 (Real transcript law).** Let $a, b \in \mathbb{Z}_3$ with $a \ne b$ be the
secret colours of the two endpoints of the challenged edge. The *real transcript law*
$R_{a,b}$ is the distribution of $(\pi(a), \pi(b))$ where $\pi \in S_3$ is uniform. Since
$a \ne b$ and $\pi$ is injective, $(\pi(a),\pi(b)) \in \mathcal{P}$ always, so $R_{a,b}$ is
supported on $\mathcal{P}$.

**Definition 4.2 (Simulator law).** The *simulator law* $S$ is the uniform distribution on
$\mathcal{P}$: it assigns mass $1/6$ to each of the six pairs. Crucially, $S$ is defined
without reference to any graph, any colouring, or any edge — it is *colouring-oblivious*.
The simulator is the trivial algorithm "output a uniformly random ordered pair of distinct
colours".

**Definition 4.3 (Edge transcript law).** For a graph $E$, a colouring $c$ proper for $E$,
and an edge $e \in E$, the *edge transcript law* is
$$T(E, c, e) \;=\; R_{\,c(e_1),\, c(e_2)} ,$$
which is well defined precisely because properness supplies the hypothesis
$c(e_1) \neq c(e_2)$.

### 4.2 The mechanism: a simply transitive action

**Lemma 4.4 (Simple transitivity).** *The symmetric group $S_3$ acts on $\mathcal{P}$ by
$\pi \cdot (a,b) = (\pi(a), \pi(b))$, and this action is simply transitive: for any
$(a,b), (a',b') \in \mathcal{P}$ there is exactly one $\pi \in S_3$ with
$\pi(a) = a'$ and $\pi(b) = b'$.*

*Proof sketch.* Given $(a,b)$ and $(a',b')$ with $a \ne b$ and $a' \ne b'$, the assignments
$a \mapsto a'$, $b \mapsto b'$ are consistent and injective on $\{a,b\}$; since
$\#\mathbb{Z}_3 = 3$, the remaining element must map to the remaining element, determining
$\pi$ uniquely. Existence and uniqueness are thus simultaneous. Counting confirms it:
$\#S_3 = 6 = \#\mathcal{P}$. $\square$

This single lemma is the source of all privacy in the protocol.

**Theorem 4.5 (Transcript uniformity).** *For every $E$, every $c$ proper for $E$, every
$e \in E$, and every $p \in \mathcal{P}$,*
$$T(E,c,e)(p) \;=\; \tfrac{1}{6}.$$

*Proof.* Write $(a,b) = (c(e_1), c(e_2))$, so $a \ne b$ by properness. By Lemma 4.4,
exactly one $\pi \in S_3$ satisfies $\pi \cdot (a,b) = p$. Since $\pi$ is uniform on a set
of size six, the event $\{(\pi(a),\pi(b)) = p\}$ has probability $1/6$. $\square$

Observe what Theorem 4.5 says and does not say. It does not say the transcript is *nearly*
uniform, or uniform up to a negligible function of a security parameter. It says the mass
is the constant $1/6$, a number in which the pair $(a,b)$ — and hence the secret
colouring — does not appear.

### 4.3 Independence of the secret

**Theorem 4.6 (Colour-and-edge independence).** *Let $(E_1, c_1, e_1)$ and
$(E_2, c_2, e_2)$ be any two valid protocol instances: $c_i$ proper for $E_i$ and
$e_i \in E_i$, for $i = 1,2$. Then the transcript laws coincide:*
$$T(E_1, c_1, e_1) \;=\; T(E_2, c_2, e_2).$$

*Proof.* By Theorem 4.5 both distributions assign mass $1/6$ to every point of the finite
sample space $\mathcal{P}$, hence they are equal as distributions. Equivalently, both
equal $R_{a,b}$ for their respective secret pairs, and $R_{a,b} = R_{a',b'}$ for all
distinct pairs by Lemma 4.4. $\square$

The strength of this statement is worth emphasising: the graphs need not be equal, need not
be isomorphic, need not have the same number of vertices or edges; the colourings need not
be related; the edges need not correspond. The verifier's view is the *same random object*
in all cases.

### 4.4 Perfect honest-verifier zero knowledge

**Theorem 4.7 (Perfect zero knowledge).** *For every $E$, every $c$ proper for $E$, and
every $e \in E$,*
$$T(E, c, e) \;=\; S ,$$
*where $S$ is the colouring-oblivious simulator law of Definition 4.2.*

*Proof.* Both distributions assign mass exactly $1/6$ to each of the six elements of
$\mathcal{P}$ — the left-hand side by Theorem 4.5, the right-hand side by definition —
and a distribution on a finite set is determined by its point masses. $\square$

This is the simulation paradigm instantiated exactly. The simulator is given no colouring,
is not told whether the graph is 3-colourable, and performs no interaction; it flips its
own coins. Its output is *indistinguishable* from a real transcript not in the weak sense
of computational indistinguishability, nor in the intermediate sense of small statistical
distance, but in the strongest possible sense: the two laws are the same law.

### 4.5 Distinguishers have zero advantage

Equality of laws is the mathematician's formulation; the cryptographer's formulation is in
terms of adversaries. We give both and show they agree.

**Definition 4.8 (Distinguisher and its acceptance probability).** A *deterministic
distinguisher* is any function $D : \mathcal{P} \to \{\mathrm{true}, \mathrm{false}\}$. Its
*acceptance probability* under a distribution $\mu$ on $\mathcal{P}$ is
$$\mathrm{Acc}(\mu, D) \;=\; \sum_{p \in \mathcal{P}} \begin{cases} \mu(p) & \text{if } D(p) \\ 0 & \text{otherwise,}\end{cases}$$
i.e. the total mass $\mu$ assigns to the accepting set $D^{-1}(\mathrm{true})$.

No computational restriction is placed on $D$: it ranges over *all* $2^6 = 64$ Boolean
functions on the transcript space, i.e. over all conceivable tests.

**Theorem 4.9 (Zero distinguishing advantage).** *For every $E$, every $c$ proper for $E$,
every $e \in E$, and every deterministic distinguisher $D$,*
$$\mathrm{Acc}\bigl(T(E,c,e), D\bigr) \;=\; \mathrm{Acc}(S, D).$$

*Proof.* By Theorem 4.7 the two distributions are equal; substituting one for the other in
the definition of $\mathrm{Acc}$ gives the identity. $\square$

**Corollary 4.10 (Both one-sided advantages vanish).** *Under the hypotheses of
Theorem 4.9,*
$$\mathrm{Acc}\bigl(T(E,c,e), D\bigr) - \mathrm{Acc}(S, D) = 0
\quad\text{and}\quad
\mathrm{Acc}(S, D) - \mathrm{Acc}\bigl(T(E,c,e), D\bigr) = 0 .$$

*Proof.* Immediate from Theorem 4.9. $\square$

Stating both one-sided differences is not redundant pedantry. Advantage is often measured
in a truncated arithmetic where a negative difference is clipped to zero, so a single
one-sided statement can be vacuously satisfied by a distinguisher that is biased the
"wrong" way. Asserting that *both* differences vanish rules this out and pins the
advantage at exactly zero regardless of the convention. Moreover, since the total variation
distance between $T(E,c,e)$ and $S$ equals $\sup_D \bigl|\mathrm{Acc}(T,D) - \mathrm{Acc}(S,D)\bigr|$
over the $64$ distinguishers, Corollary 4.10 says precisely that the statistical distance is
$0$.

**Remark 4.11 (Randomised distinguishers).** Allowing $D$ to flip coins adds no power:
a randomised distinguisher is a convex combination of deterministic ones, so its advantage
is the corresponding convex combination of zeros. Perfect zero knowledge is therefore
robust across the usual variations of the adversary model.

---

## 5. Algorithms

We record the four computational procedures implicit in the analysis, with complexity in
terms of $n = \#V$, $m = \#E$, and the round count $k$.

### 5.1 One-round execution

**Procedure.** Sample $\pi \in S_3$ uniformly; sample $e \in E$ uniformly; return
$(\pi(c(e_1)), \pi(c(e_2)))$ and the acceptance bit $[\pi(c(e_1)) \ne \pi(c(e_2))]$.

In the idealised model the prover need only apply $\pi$ at the two challenged vertices, so
one round costs $O(1)$ time given random access to $c$ and $E$. In an implementation with
real commitments the prover must commit to all $n$ vertices before seeing $e$, giving
$O(n)$ per round and $O(kn)$ overall, with $O(k)$ openings.

### 5.2 Exact acceptance probability

**Procedure.** Scan $E$, count the edges with $c'(e_1) \ne c'(e_2)$, and return the
rational $\text{count}/m$.

Complexity $O(m)$ with exact rational output; no floating point, no sampling. This computes
$\alpha(E,c')$ of Definition 3.1 exactly, and by Theorem 3.2 also $\rho = 1 - \alpha$.

### 5.3 Round-count selection

**Procedure.** Given $m$ and a target error $\varepsilon$, return
$k = \lceil m \ln(1/\varepsilon)\rceil$, per Corollary 3.8. Complexity $O(1)$. The
guarantee it certifies — $\alpha^k \le (1 - 1/m)^k \le \varepsilon$ — is Theorem 3.7
composed with the exponential bound.

### 5.4 Simulation

**Procedure.** Sample $p$ uniformly from the six-element set $\mathcal{P}$ and output it.

Complexity $O(1)$ per transcript; the simulator reads no graph, no colouring, and no edge.
That its input is empty is the whole point: by Theorem 4.7 its output law is *identical* to
the real one, so a real transcript can carry no information that this input-free procedure
could not have invented. Simulating $k$ rounds costs $O(k)$.

---

## 6. Discussion

### 6.1 Where the difficulty lives

The soundness half of the analysis is arithmetic: a partition of $E$ into accepting and
rejecting edges, a non-emptiness observation, and monotonicity of $x \mapsto x^k$. It is
easy but must be exact, and the complementarity identity of Theorem 3.2 is what makes the
directions of the inequalities line up.

The privacy half is structural, and reduces entirely to Lemma 4.4: $S_3$ acts simply
transitively on $\mathcal{P}$. Because $\#S_3 = \#\mathcal{P} = 6$, a uniform permutation
pushes any distinct pair to the uniform distribution. The secret is not concealed behind
computational hardness; it is *destroyed by symmetry*. The verifier observes a point in an
orbit on which the group acts transitively, and such an observation carries no information
about the orbit representative.

This is why the privacy is perfect while the soundness is only $1 - 1/m$ per round. The two
guarantees have different characters: one is information-theoretic and exact, the other is
combinatorial and must be amplified.

### 6.2 Why a weak per-round bound is acceptable

A protocol that catches cheats only $1/m$ of the time sounds broken. The resolution is
Theorem 3.7 together with the *one-sidedness* supplied by Theorem 3.3: because an honest
prover never fails, the verifier may demand that *all* $k$ rounds accept, with no tolerance
for failures. Under a fixed improper commitment, this multiplies the per-round bounds, and
$O(m)$ rounds suffice for cryptographic-grade error. The cost is linear in the instance
size — entirely acceptable, and the reason the construction is regarded as practical in
principle even though each round leaks so little conviction.

Had completeness been imperfect (say $1 - \delta$ per round), the verifier would have had
to tolerate some failures, the analysis would have required a Chernoff bound with a gap
between the honest and cheating acceptance rates, and the round count would have grown
accordingly. Perfect completeness buys a simpler and tighter analysis.

### 6.3 NP-completeness and universality

Graph 3-colourability is NP-complete. Consequently, for any language $L \in \mathrm{NP}$
there is a polynomial-time reduction taking an instance $x$ to a graph $G_x$ such that
$x \in L$ iff $G_x$ is 3-colourable, and taking a witness for $x$ to a proper colouring of
$G_x$. Composing this reduction with the protocol analysed here yields a zero-knowledge
proof system for $L$: the prover 3-colours $G_x$ using its witness, and the results above
apply verbatim. This is the sense in which the three-colouring protocol is not a special
case but a universal template.

### 6.4 Applications

The simulation paradigm formalised here underlies a broad family of deployed systems:

- **Identification without secret transmission.** A user proves possession of a secret
  without sending it, so a breach of the verifier reveals nothing usable.
- **Confidential ledgers.** Validity of a transaction — well-formedness, sufficient
  balance, absence of double spending — is proved without disclosing amounts or parties.
- **Verifiable outsourced computation.** A server proves that it executed a computation
  faithfully, without the client repeating the work and without revealing proprietary
  internals.
- **Regulatory attestation.** An institution proves that a private dataset satisfies a
  public predicate (a solvency threshold, a fairness constraint) without publishing the
  data.

In each case the design goal is exactly the one proved here: a transcript that a
witness-oblivious simulator could have produced.

### 6.5 Relation to statistical and computational zero knowledge

Three grades of privacy are standard. *Computational* zero knowledge asks that no
polynomial-time distinguisher have non-negligible advantage; *statistical* zero knowledge
asks that the statistical distance be negligible; *perfect* zero knowledge asks that the
distributions be equal. Theorem 4.7 and Corollary 4.10 place the analysis in the strongest
class, for the idealised transcript. This is not an accident of the analysis but a feature
of the object: no computational assumption enters the privacy argument at all, only
Lemma 4.4. Computational assumptions re-enter only through the commitment scheme, discussed
next.

---

## 7. Scope, limitations, and future directions

Precision about what has *not* been established is as valuable as what has.

**(a) Idealised commitments.** The transcript here is the opened colour pair. A full model
includes the commitment strings, and the hiding property then becomes a hypothesis. With a
*perfectly hiding* commitment the perfect-privacy conclusion survives; with a
computationally hiding one, perfect zero knowledge degrades to computational zero
knowledge, and Theorem 4.9 must be re-stated for polynomial-time distinguishers with a
negligible bound.

**(b) Fixed versus adaptive provers.** Theorem 3.7 bounds a prover committed to one fixed
colouring across all rounds. A general cheating prover is an interactive strategy that may
choose each round's commitment adaptively; deriving the per-round fixedness needed for the
product bound is exactly the role of the *binding* property.

**(c) Honest verifier.** The privacy theorems are for a verifier who samples her edge
uniformly and independently of the commitments. Against a general (malicious) verifier the
simulator must use rewinding — guess the challenge, prepare a transcript for it, and retry
on a mismatch — which introduces expected-polynomial running time and requires a separate
argument.

**(d) Single round.** Section 4 computes the law of a single round's transcript. Full
zero knowledge for the repeated protocol requires the *joint* law of $k$ rounds to equal
the product of $k$ simulator draws, including the case of adaptively chosen challenges.

We accordingly record the following programme of extensions.

1. **Commitment scheme semantics.** Add a binding and hiding commitment interface, then
   include commitments and openings in the transcript rather than modelling only the
   opened pair.
2. **Adaptive cheating provers.** Replace a fixed committed colouring by an interactive
   strategy and derive soundness from commitment binding.
3. **Sequential transcript composition.** Define the joint distribution of multiple rounds
   and prove that the simulator's product distribution equals the real joint distribution,
   including adaptive honest-verifier challenges.
4. **General-verifier zero knowledge.** Formalise verifier strategies, rewinding, expected
   running time, and the standard simulation proof beyond honest verifiers.
5. **Witness indistinguishability.** Derive equality of transcript laws for two different
   proper colourings at the level of complete commitment transcripts, under a perfectly
   hiding commitment assumption.
6. **Negligible-error framework.** Introduce security parameters, distribution ensembles,
   statistical distance, computational indistinguishability, and polynomial-time
   adversaries.
7. **Knowledge extraction.** Study special soundness and extraction variants, relating
   accepting responses to a global proper 3-colouring.
8. **Undirected graph bridge.** Connect the finite ordered-pair edge-set presentation used
   here to the standard undirected simple-graph formulation, including looplessness and
   symmetric challenge sampling.

---

## 8. Conclusion

We have given an exact analysis of the graph 3-colouring interactive proof. On the
soundness side, acceptance and rejection probabilities are complementary exact rationals;
a proper colouring is accepted with probability exactly $1$; an improper commitment is
accepted with probability at most $1 - 1/\#E$; and independent repetition drives this to
$(1 - 1/\#E)^k$, so that $O(\#E \cdot \ln(1/\varepsilon))$ rounds achieve any target error
$\varepsilon$. On the privacy side, the real transcript law is uniform on the six ordered
pairs of distinct colours, is independent of the graph, the colouring and the challenged
edge, coincides exactly with the output law of a colouring-oblivious simulator, and gives
every deterministic distinguisher an advantage of exactly zero in both directions.

The two halves have different mathematical characters. Soundness is careful finite
counting; privacy is a group action. It is a pleasant fact about this protocol that its
strongest property — perfect, unconditional, information-theoretic secrecy — is also the
one with the simplest cause: six permutations acting simply transitively on six pairs.
