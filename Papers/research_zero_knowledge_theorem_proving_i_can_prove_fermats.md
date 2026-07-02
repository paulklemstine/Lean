# Local Checkability and Multi-Round Soundness Amplification for Zero-Knowledge Certification

## Abstract

We isolate and prove the soundness core of zero-knowledge certification protocols in a form that is entirely independent of the internal structure of the verifier's check. A *locally checkable certificate* over a finite challenge space $\Omega$ is a Boolean predicate assigning to each challenge a pass/fail verdict; the certificate is *globally valid* when every challenge passes. Our first result, **Single-Round Soundness**, shows that if a certificate is invalid — some challenge fails — then the set of passing challenges has at most $|\Omega| - 1$ elements, so a verifier sampling a uniformly random challenge rejects with probability at least $1/|\Omega|$. This holds with no assumption whatsoever on the checker. Our main result, **Multi-Round Soundness Amplification**, lifts this to $k$ independent rounds: a prover forced to commit to an invalid certificate in each round survives all rounds with probability at most $\big((|\Omega|-1)/|\Omega|\big)^k$, which decays geometrically to $0$. We prove a companion **Strict Soundness Gap** showing the per-round accepting fraction of an invalid certificate is strictly below $1$. Finally we instantiate the abstract machinery at the classical Goldreich–Micali–Wigderson zero-knowledge protocol for graph $3$-colourability, obtaining a fully amplified soundness bound $\big((|E|-1)/|E|\big)^k$ for a prover committing to improper colourings, where $|E|$ is the number of edges. This upgrades the classical single-round soundness gap to a statement with vanishing error, and exposes the tight round complexity: reaching error $2^{-k}$ requires $\Theta(|\Omega|\cdot k)$ rounds, not the folklore $O(k)$.

**Keywords:** zero-knowledge proofs, local checkability, soundness amplification, probabilistically checkable proofs, graph 3-colouring, Goldreich–Micali–Wigderson protocol, commitment schemes.

## 1. Introduction

A zero-knowledge proof convinces a verifier that a statement is true while revealing nothing beyond its truth. Since their introduction in the 1980s, such protocols have become foundational to cryptography and, increasingly, to the certification of mathematical and computational claims: one can certify that a theorem has a valid proof, or that a computation was performed correctly, without disclosing the proof or the computation. The intuition driving many such systems is that of *probabilistically checkable proofs* (PCPs): a claimed proof can be re-encoded so that a small number of random spot-checks suffices to detect any flaw with constant probability, and repetition amplifies confidence to certainty.

This paper distills the *soundness* half of that intuition into its logical minimum and proves it rigorously. We deliberately separate two concerns that are often entangled in concrete protocols:

- **Local checkability** — the structural property that an invalid certificate must fail at least one local check. We treat this as a hypothesis about the certificate and prove exactly what soundness it buys, *with no assumption on the checker's internals*.
- **Amplification** — the probabilistic consequence of running many independent rounds. We prove the exact geometric decay of the survival probability and identify the tight base of the exponential.

The payoff is twofold. First, the abstract results apply to *any* protocol whose acceptance reduces to a uniform random local check, giving a reusable soundness template. Second, specializing to the Goldreich–Micali–Wigderson (GMW) protocol for graph $3$-colourability produces a genuinely new statement: whereas the classical analysis establishes only a single-round gap of $1/|E|$, we obtain a full $k$-round bound $\big((|E|-1)/|E|\big)^k$ with vanishing error.

### 1.1 Contributions

1. A definition of *locally checkable certificate* over a finite challenge space and a formulation of single- and multi-round verifiers as uniform sampling procedures (§2).
2. **Single-Round Soundness** (Theorem 3.1): an invalid certificate has at most $|\Omega|-1$ passing challenges. The proof is a one-line counting argument via set erasure (§3).
3. **Strict Soundness Gap** (Theorem 3.3): the accepting fraction of an invalid certificate over a nonempty challenge space is strictly below $1$ (§3).
4. **Multi-Round Soundness Amplification** (Theorem 4.1): a product bound $\big((|\Omega|-1)/|\Omega|\big)^k$ on the survival probability across $k$ independent invalid rounds, proved by a monotone product inequality (§4).
5. **Three-Colouring Amplified Soundness** (Theorem 5.1): the abstract bound instantiated at the GMW $3$-colouring verifier, yielding $\big((|E|-1)/|E|\big)^k$ (§5).
6. A discussion of **tight round complexity** ($\Theta(|\Omega|\cdot k)$) and its correction of the folklore $O(k)$ (§6), and future directions toward constant-gap PCP-style boosts and binding commitments (§7).

## 2. Definitions

Throughout, $\beta$ is a type with decidable equality, and $\Omega : \mathrm{Finset}\,\beta$ is a finite **challenge space**. We write $|\Omega|$ for its cardinality.

**Definition 2.1 (Locally checkable certificate).** A *locally checkable certificate* over $\Omega$ is a function
$$\mathrm{check} : \beta \to \{\texttt{true}, \texttt{false}\}.$$
A challenge $e \in \Omega$ *passes* if $\mathrm{check}(e) = \texttt{true}$ and *fails* otherwise. The **passing set** is
$$P(\mathrm{check}) = \{\, e \in \Omega : \mathrm{check}(e) = \texttt{true} \,\} = \Omega \cap \mathrm{check}^{-1}(\texttt{true}).$$

**Definition 2.2 (Validity).** The certificate is **globally valid** if every challenge in $\Omega$ passes, i.e. $P(\mathrm{check}) = \Omega$. It is **invalid** if some challenge fails: $\exists\, e \in \Omega,\ \mathrm{check}(e) = \texttt{false}$.

**Definition 2.3 (Verifier).** The *single-round verifier* samples $e \in \Omega$ uniformly at random and **accepts** iff $e$ passes. Its **accepting probability** is
$$\Pr[\text{accept}] = \frac{|P(\mathrm{check})|}{|\Omega|}.$$
The *$k$-round verifier* runs $k$ independent single rounds — with certificates $\mathrm{check}_1, \dots, \mathrm{check}_k$ — and accepts iff all $k$ sampled challenges pass. By independence its accepting probability is the product $\prod_{i=1}^k |P(\mathrm{check}_i)|/|\Omega|$.

The modelling choice deserves comment. We identify the "accepting probability" with the *fraction* of passing challenges, which is exactly the probability under uniform sampling. This makes all statements purely combinatorial: cardinalities of finite sets and their ratios, cast into the rationals $\mathbb{Q}$.

## 3. Single-round soundness

**Theorem 3.1 (Single-Round Soundness).** Let $\mathrm{check}$ be a certificate over $\Omega$ and suppose some challenge fails, i.e. there exists $e \in \Omega$ with $\mathrm{check}(e) = \texttt{false}$. Then
$$|P(\mathrm{check})| \le |\Omega| - 1.$$
Equivalently, the single-round verifier rejects with probability at least $1/|\Omega|$.

*Proof.* Fix a failing challenge $e \in \Omega$ with $\mathrm{check}(e) = \texttt{false}$. We claim $P(\mathrm{check}) \subseteq \Omega \setminus \{e\}$. Indeed, take any $x \in P(\mathrm{check})$; then $x \in \Omega$ and $\mathrm{check}(x) = \texttt{true}$. If $x = e$, then $\mathrm{check}(e) = \texttt{true}$, contradicting $\mathrm{check}(e) = \texttt{false}$. Hence $x \ne e$, so $x \in \Omega \setminus \{e\}$. Monotonicity of cardinality gives
$$|P(\mathrm{check})| \le |\Omega \setminus \{e\}| = |\Omega| - 1,$$
the last equality because $e \in \Omega$. $\qquad\blacksquare$

**Remark 3.2.** The proof uses no property of $\mathrm{check}$ beyond the existence of a single failing point. This is the precise sense in which *local checkability alone* yields a soundness gap: one bad location is enough, and the gap is at least $1/|\Omega|$.

**Theorem 3.3 (Strict Soundness Gap).** If $|\Omega| > 0$ and the certificate is invalid, then the accepting fraction is strictly below $1$:
$$\frac{|P(\mathrm{check})|}{|\Omega|} < 1.$$

*Proof.* Since $|\Omega| > 0$, its rational image is positive and dividing preserves the inequality direction, so it suffices to show $|P(\mathrm{check})| < |\Omega|$ over $\mathbb{Q}$. By Theorem 3.1, $|P(\mathrm{check})| \le |\Omega| - 1$ as naturals; casting to $\mathbb{Q}$ (valid because $|\Omega| \ge 1$) gives $|P(\mathrm{check})| \le |\Omega| - 1 < |\Omega|$. Dividing by $|\Omega| > 0$ yields the claim. $\qquad\blacksquare$

Theorem 3.3 certifies that the soundness gap is genuine and not an artifact of rounding: there is strict separation between a cheating prover's best acceptance probability and certainty.

## 4. Multi-round soundness amplification

We now amplify the single-round gap by independent repetition. The key structural fact is that each round's accepting fraction is bounded by the *same* constant $r := (|\Omega|-1)/|\Omega|$, so their product is bounded by $r^k$.

**Theorem 4.1 (Multi-Round Soundness Amplification).** Let $|\Omega| > 0$ and let $\mathrm{check}_1, \dots, \mathrm{check}_k$ be certificates over $\Omega$, each invalid (for every $i$ there exists $e \in \Omega$ with $\mathrm{check}_i(e) = \texttt{false}$). Then the $k$-round survival probability satisfies
$$\prod_{i=1}^{k} \frac{|P(\mathrm{check}_i)|}{|\Omega|} \;\le\; \left( \frac{|\Omega| - 1}{|\Omega|} \right)^{k}.$$
In particular, since $0 \le (|\Omega|-1)/|\Omega| < 1$, the right-hand side decays geometrically to $0$ as $k \to \infty$.

*Proof.* Work in $\mathbb{Q}$. For each $i$, the factor $|P(\mathrm{check}_i)|/|\Omega|$ is nonnegative. By Theorem 3.1 applied to $\mathrm{check}_i$ we have, as naturals, $|P(\mathrm{check}_i)| \le |\Omega| - 1$; casting to $\mathbb{Q}$ (using $|\Omega| \ge 1$) gives $|P(\mathrm{check}_i)| \le |\Omega| - 1$, hence
$$\frac{|P(\mathrm{check}_i)|}{|\Omega|} \le \frac{|\Omega| - 1}{|\Omega|}.$$
Since all factors are nonnegative and each is bounded above by the constant $r = (|\Omega|-1)/|\Omega|$, the monotone product inequality gives
$$\prod_{i=1}^{k} \frac{|P(\mathrm{check}_i)|}{|\Omega|} \le \prod_{i=1}^{k} r = r^{k},$$
where the last equality is the value of a constant product over $k$ indices. $\qquad\blacksquare$

**Corollary 4.2 (Error target).** To force the survival probability below a target $2^{-k}$, it suffices to run $R$ rounds with $r^R \le 2^{-k}$, i.e.
$$R \ge \frac{k \ln 2}{\ln\!\big(|\Omega|/(|\Omega|-1)\big)}.$$
Since $\ln\!\big(|\Omega|/(|\Omega|-1)\big) \approx 1/|\Omega|$ for large $|\Omega|$, this is $R = \Theta(|\Omega|\cdot k)$.

Corollary 4.2 makes precise the round cost that the informal "repeat $O(k)$ times" slogan hides; we return to its optimality in §6.

## 5. Instantiation: zero-knowledge proof of graph 3-colourability

We now bridge the abstract theory to a concrete, classical protocol. Let $V$ be a finite type of vertices with decidable equality and let $E : \mathrm{Finset}(V \times V)$ be a finite edge set. A **$3$-colouring** is a map $c : V \to \{0,1,2\}$.

**Definition 5.1 (Proper colouring).** A colouring $c$ is *proper* for $E$ if the endpoints of every edge receive distinct colours:
$$\forall\, e \in E,\quad c(e_1) \ne c(e_2).$$
It is *improper* otherwise.

**The GMW protocol (one round).** The prover holds a proper colouring $c$, samples a uniformly random permutation $\pi$ of the three colours, and commits to $\pi \circ c$. The verifier challenges a uniformly random edge $(u,v) \in E$; the prover opens the committed colours $\big(\pi(c(u)), \pi(c(v))\big)$; the verifier accepts iff they differ.

Two classical properties frame the protocol and motivate our soundness contribution:

- **Completeness.** Applying any colour permutation to a proper colouring yields a proper colouring (since permutations are injective, distinct colours stay distinct). Hence an honest prover always opens two distinct colours and is accepted with probability $1$.
- **Perfect honest-verifier zero knowledge.** For a fixed challenged edge with distinct endpoint colours $a \ne b$, the map $\pi \mapsto (\pi(a), \pi(b))$ is a bijection from the six permutations of $\{0,1,2\}$ onto the six ordered pairs of distinct colours. Thus the opened view is distributed exactly like a uniform random ordered pair of distinct colours — independent of the underlying colouring — so the verifier learns nothing about $c$. (This perfect equidistribution is special to three colours, where the number of permutations, $6$, equals the number of ordered distinct pairs.)

Our contribution is the **soundness** side. The single-round soundness of GMW is classical: if the committed colouring is improper, at least one edge has equal endpoint colours, so a random-edge verifier catches the prover with probability at least $1/|E|$. We record this as an instance of Theorem 3.1 and then amplify it.

To connect to §2–4, set the challenge space $\Omega := E$ and, for a colouring $c$, define the check
$$\mathrm{check}_c(e) := \big[\, c(e_1) \ne c(e_2)\,\big] \in \{\texttt{true},\texttt{false}\}.$$
The passing set $P(\mathrm{check}_c)$ is exactly the set of edges with distinct endpoint colours, and $\mathrm{check}_c$ is invalid precisely when $c$ is improper: an improper colouring produces an edge with equal endpoints, i.e. a failing challenge. This is the content of the classical "some edge catches the prover" lemma, which supplies the hypothesis of Theorem 3.1.

**Theorem 5.2 (Three-Colouring Amplified Soundness).** Suppose $|E| > 0$. Let $c_1, \dots, c_k$ be colourings, each *improper* for $E$, representing a cheating prover's commitment in each of $k$ independent rounds. Then the probability the prover survives all $k$ random-edge challenges satisfies
$$\prod_{i=1}^{k} \frac{|\{ e \in E : c_i(e_1) \ne c_i(e_2)\}|}{|E|} \;\le\; \left( \frac{|E| - 1}{|E|} \right)^{k},$$
which decays geometrically to $0$.

*Proof.* For each $i$, since $c_i$ is improper there is an edge $e \in E$ with $c_i(e_1) = c_i(e_2)$, i.e. $\mathrm{check}_{c_i}(e) = \texttt{false}$; thus $\mathrm{check}_{c_i}$ is an invalid certificate over $\Omega = E$. Its passing set is $\{ e \in E : c_i(e_1) \ne c_i(e_2)\}$. Apply Theorem 4.1 with $\Omega = E$ and $\mathrm{check}_i = \mathrm{check}_{c_i}$; the constant base is $(|E|-1)/|E|$. $\qquad\blacksquare$

Theorem 5.2 upgrades the classical single-round gap ($k=1$) to a full amplification statement with error tending to $0$. The genuine novelty is (a) recognizing the single-round gap as one instance of the assumption-free local-check principle of Theorem 3.1, and (b) multiplying it across independent rounds via Theorem 4.1, from which the classical statement is precisely the $k=1$ shadow.

## 6. Tight round complexity

The base of the exponential in Theorems 4.1 and 5.2 is $(|\Omega|-1)/|\Omega|$, not a fixed constant. This has a sharp consequence.

**Proposition 6.1 (Tightness).** The bound of Theorem 4.1 is achieved. For any $\Omega$ with $|\Omega| = n \ge 1$, consider a prover who, in each round, corrupts exactly one location — a certificate with $\mathrm{check}$ failing on a single challenge and passing on the other $n-1$. Then the per-round accepting fraction is exactly $(n-1)/n$, and over $k$ independent such rounds the survival probability is exactly $\big((n-1)/n\big)^k$.

*Proof.* A single-failure certificate has passing set of size $n-1$, so its accepting fraction is $(n-1)/n$, meeting the bound of Theorem 3.1 with equality. Independence multiplies these to $\big((n-1)/n\big)^k$. $\qquad\blacksquare$

Consequently, reaching soundness error $2^{-k}$ by independent uniform single-location challenges requires $\Theta(n \cdot k)$ rounds (Corollary 4.2), and Proposition 6.1 shows no schedule of such queries beats $\big((n-1)/n\big)^{\text{rounds}}$. The folklore "$O(k)$ rounds" holds only when the per-round gap is a constant fraction — which requires each query to inspect a constant fraction of the certificate, not a single location. This distinction is exactly the gap that PCP-style re-encodings are designed to close (see §7).

## 7. Discussion, applications, and future work

### 7.1 Why an assumption-free soundness core matters

Concrete zero-knowledge protocols differ wildly in their commitment machinery, arithmetization, and simulator constructions. Yet their soundness almost always reduces to the same combinatorial skeleton: a uniform random local check with a guaranteed failing location. By proving that skeleton once, with no hypothesis on the checker, we obtain a template instantiable across protocols — as demonstrated by the GMW specialization. The robustness is notable: because Theorem 3.1 ignores the checker's internals, adversarial structure in the certificate cannot erode the $1/|\Omega|$ gap.

### 7.2 The full certify-without-revealing picture

Soundness is one of two pillars. The other is a *binding commitment* that ties the prover to an entire proof with a single short digest, openable one step at a time with each opening itself binding (as in hash-tree / Merkle commitments). Composed with the amplified soundness proved here, one obtains the complete architecture: the commitment forces the prover to fix the certificate before challenges are drawn (so the "invalid in each round" hypothesis is enforced), while the local-check amplification drives the probability of an undetected falsehood to $0$. Applications include certifying that a theorem admits a valid proof while withholding the proof itself — a sealed-bid auction for proof strategies — and verifying program correctness or large computations without revealing source or trace, as already deployed in succinct blockchain validity proofs.

### 7.3 Future directions

**Binding is free; only uniqueness costs security.** For any tree-structured commitment built from a two-argument compression function, the map from committed data to root digest should be *binding in the constructive sense* — any two openings that agree on the digest but disagree on content yield two distinct inputs with the same compressed value — with no algebraic hypothesis on the compression function; the security assumption (collision resistance) is needed only to turn this into *uniqueness* of the committed content. Ambiguity must surface as a collision at the *first* node where two committed datasets diverge, so the extractor is a purely structural recursion that never inspects the compression function's internals. This sharply poses the question of exactly which security notion each tree shape supports.

**Tight round complexity: $\Theta(n\cdot k)$, not $O(k)$.** Certifying an $n$-location proof to soundness error $2^{-k}$ by independent single-location challenges requires $\Theta(n\cdot k)$ rounds, and this is optimal: a cheater corrupting a single location survives each round with probability exactly $(n-1)/n$, so no schedule of independent uniform single queries beats $((n-1)/n)^{\text{rounds}}$. The per-round soundness gap of a local checker is exactly $1/n$ in the worst case, so the naive $2^{-k}$ bound silently assumes a constant-fraction gap that only holds when the query already inspects a constant fraction of the proof.

**Constant soundness gap via correlated queries (a PCP-style boost).** There should be a re-encoding of any $n$-location certificate into a new certificate of size $\mathrm{poly}(n)$ whose local checker enjoys a *constant* per-round soundness gap $\ge 1/2$, so that only $O(k)$ rounds — independent of $n$ — reach error $2^{-k}$; equivalently, the gap can be amplified from $1/n$ to a constant by querying a small constant number of *correlated* locations of a suitably encoded proof. This is the algorithmic heart of the PCP theorem, recast in the local-checkability language of this paper.

## 8. Conclusion

We have reduced the soundness of zero-knowledge certification to two elementary but sharp facts. Single-Round Soundness shows that a single failing location caps the accepting fraction at $(|\Omega|-1)/|\Omega|$, with no assumption on the checker. Multi-Round Soundness Amplification multiplies this across independent rounds to $\big((|\Omega|-1)/|\Omega|\big)^k$, a bound that is tight and that, when specialized to graph $3$-colourability, yields $\big((|E|-1)/|E|\big)^k$ — a full upgrade of the classical single-round guarantee. The tightness sharpens the folklore round count to $\Theta(|\Omega|\cdot k)$ and points precisely to where PCP-style re-encodings must intervene to recover a constant gap. Together with binding commitments, these results form the soundness backbone of protocols that certify truth while revealing nothing about the proof.
