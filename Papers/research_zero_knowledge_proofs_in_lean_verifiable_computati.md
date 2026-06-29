# Zero-Knowledge Proofs and Constant-Query Local Verification: A Formal Study of Graph 3-Colourability

## Abstract

We present a self-contained formal development of the classical Goldreich–Micali–Wigderson (GMW) zero-knowledge proof system for graph 3-colourability, together with a bridge connecting it to the constant-query backbone of the PCP theorem ($\mathrm{NP} \subseteq \mathrm{PCP}(\mathrm{poly}, O(1))$). Working over a finite vertex type $V$ and an explicit edge set $E$, we model a 3-colouring as a map $c : V \to \mathbb{F}_3$ (where $\mathbb{F}_3 = \{0,1,2\}$ is the three-element colour alphabet) and the protocol's randomization as a uniformly chosen permutation $\pi \in S_3$ of the colours. We establish four pillars: **perfect completeness** (colour permutations preserve properness, so honest provers always succeed); a **soundness gap** (against a non-3-colourable instance, every claimed proof is rejected on a uniformly random edge with probability at least $1/|E|$); **perfect honest-verifier zero knowledge** (the real opened view is *identically* distributed to a uniform random ordered pair of distinct colours, via an explicit bijection $S_3 \cong \{(a,b) : a \neq b\}$); and a **constant-query local-verifier** reading at most two proof symbols per random challenge. The last result reinterprets the GMW protocol as a $2$-query probabilistically checkable proof for an NP-complete language, isolating *gap amplification* as the sole remaining ingredient of the full PCP theorem. All results have been formally verified.

**Keywords:** zero-knowledge proof, graph 3-colourability, GMW protocol, honest-verifier zero knowledge, soundness gap, probabilistically checkable proofs, PCP theorem, constant-query verifier, sigma protocol, verifiable computation.

---

## 1. Introduction

A zero-knowledge proof allows a *prover* to convince a *verifier* that a statement is true while revealing nothing beyond the truth of the statement itself. Since their introduction by Goldwasser, Micali, and Rackoff, and the subsequent demonstration by Goldreich, Micali, and Wigderson (GMW) that *every* NP statement admits such a proof, zero-knowledge proofs have become a cornerstone of modern cryptography, powering anonymous credentials, privacy-preserving cryptocurrencies, and the rapidly growing field of *verifiable computation*.

The GMW result rests on a single, beautifully concrete protocol: a zero-knowledge proof for **graph 3-colourability**. Because 3-colourability is NP-complete, a zero-knowledge proof for it lifts (via NP-reductions) to a zero-knowledge proof for any NP statement. This paper develops that protocol formally and in full, and then draws a precise line from it to the **PCP theorem**, the celebrated result that every NP language has proofs checkable by reading only a constant number of symbols.

Our contributions are:

1. A formal model of the GMW 3-colouring protocol over a finite vertex type and explicit edge set (Section 3).
2. A proof of **perfect completeness** via invariance of properness under colour permutations (Theorem 4.1).
3. A quantitative **soundness gap**: a clean rational lower bound of $1/|E|$ on the single-round rejection probability against non-3-colourable instances (Theorems 4.2–4.4).
4. A proof of **perfect honest-verifier zero knowledge** through an explicit bijection between the symmetric group $S_3$ and the set of ordered pairs of distinct colours (Theorems 4.5–4.7).
5. A **bridge to the PCP theorem**: a reinterpretation of the protocol as a $2$-query local verifier with constant query complexity, perfect completeness, and a positive soundness gap (Section 5), isolating gap amplification as the only missing ingredient of $\mathrm{NP} \subseteq \mathrm{PCP}(\mathrm{poly}, O(1))$.

Everything below is stated inline and is self-contained; no external references are required to follow the development.

---

## 2. Background and Notation

### 2.1 Graphs and colourings

Throughout, $V$ is a finite type of **vertices** and $E$ is a finite set of **edges**, modelled as a finite set of ordered pairs $E \subseteq V \times V$ (an ordered model is convenient and harmless: the verifier's accept predicate is symmetric in the endpoints). We write $|E|$ for the number of edges and $|V|$ for the number of vertices.

A **3-colouring** is a function
$$c : V \to \mathbb{F}_3, \qquad \mathbb{F}_3 = \{0, 1, 2\},$$
assigning one of three colours to each vertex.

**Definition 2.1 (Proper colouring).** A colouring $c$ is *proper* for the edge set $E$, written $\mathrm{IsProperColoring}(E, c)$, when every edge has differently coloured endpoints:
$$\mathrm{IsProperColoring}(E, c) \;\iff\; \forall\, e \in E,\; c(e_1) \neq c(e_2),$$
where $e = (e_1, e_2)$. A graph is **3-colourable** when some proper colouring exists.

Deciding 3-colourability is NP-complete; a proper colouring is the canonical NP-witness, and verifying a claimed witness amounts to checking the inequality $c(e_1) \neq c(e_2)$ on each edge.

### 2.2 The symmetric group on colours

Let $S_3 = \mathrm{Sym}(\mathbb{F}_3)$ denote the group of permutations (bijections) of the three colours; $|S_3| = 3! = 6$. For $\pi \in S_3$ and a colouring $c$, the **recoloured** map $\pi \circ c$ sends $v \mapsto \pi(c(v))$.

---

## 3. The GMW 3-Colouring Protocol

We model the interactive protocol between a prover $P$ (holding a proper colouring $c$) and a verifier $\mathcal V$.

**Protocol (GMW 3-colouring, one round).**
1. **Commit.** $P$ samples $\pi \in S_3$ uniformly at random and commits to the recoloured colouring $\pi \circ c$ — conceptually, sealing each vertex's recoloured value $\pi(c(v))$ in an individual locked box.
2. **Challenge.** $\mathcal V$ samples an edge $e = (u, v) \in E$ uniformly at random.
3. **Open.** $P$ opens the two committed values at the endpoints, revealing the pair
$$\mathrm{revealedView}(\pi, c, e) = \big(\pi(c(u)),\, \pi(c(v))\big).$$
4. **Decide.** $\mathcal V$ **accepts** iff the two revealed colours differ.

**Definition 3.1 (Verifier accept predicate).** For a (committed) colouring $c$ and challenge edge $e$, the verifier's single-round accept predicate is
$$\mathrm{accept}(c, e) \;\iff\; c(e_1) \neq c(e_2).$$

The three desiderata of a proof system are completeness (honest provers convince), soundness (cheating provers are caught), and zero knowledge (the verifier learns nothing). We address each formally.

---

## 4. Main Results

### 4.1 Perfect completeness

**Theorem 4.1 (completeness).** *If $c$ is a proper colouring of $E$, then for every permutation $\pi \in S_3$ the recoloured colouring $\pi \circ c$ is also proper:*
$$\mathrm{IsProperColoring}(E, c) \;\Longrightarrow\; \mathrm{IsProperColoring}(E,\, \pi \circ c).$$
*Consequently the honest prover's revealed pair $(\pi(c(u)), \pi(c(v)))$ consists of distinct colours on every edge, and the verifier accepts with probability $1$.*

*Proof sketch.* Fix an edge $e = (u,v) \in E$. Properness gives $c(u) \neq c(v)$. Since $\pi$ is injective (a bijection), $\pi(c(u)) \neq \pi(c(v))$. As $e$ was arbitrary, $\pi \circ c$ is proper, and the revealed pair has distinct entries on every challenge, so the verifier always accepts. $\square$

The essential content is that injectivity of $\pi$ transports the inequality $c(u) \neq c(v)$ to the recoloured values; permuting colour *names* never collapses two distinct colours.

### 4.2 Soundness gap

We now bound the probability that a cheating prover survives a single round when the instance is unsatisfiable. The key combinatorial object is the set of **catching edges** of a colouring $c$:
$$\mathrm{Catch}(E, c) \;=\; \{\, e \in E : c(e_1) = c(e_2)\,\} \;=\; E \cap \{e : \neg\,\mathrm{accept}(c,e)\}.$$

**Theorem 4.2 (existence of a catching edge — soundness\_exists\_catch).** *If $c$ is not a proper colouring of $E$, then there exists an edge $e \in E$ with $c(e_1) = c(e_2)$.*

*Proof sketch.* Negate Definition 2.1: $\neg\,\mathrm{IsProperColoring}(E,c)$ unfolds to $\neg\,\forall e \in E,\ c(e_1) \neq c(e_2)$, i.e. $\exists e \in E,\ c(e_1) = c(e_2)$. $\square$

**Theorem 4.3 (catching set is nonempty — soundness\_catch\_card).** *If $c$ is not proper, then $|\mathrm{Catch}(E, c)| \geq 1$.*

*Proof sketch.* Theorem 4.2 exhibits a member of $\mathrm{Catch}(E,c)$; a finite set with a member has cardinality at least $1$. $\square$

**Theorem 4.4 (soundness gap — soundness\_prob).** *Let $|E| > 0$. If $c$ is not a proper colouring of $E$, then the fraction of catching edges is at least $1/|E|$:*
$$\frac{1}{|E|} \;\le\; \frac{|\mathrm{Catch}(E, c)|}{|E|}.$$
*Equivalently, when the verifier challenges a uniformly random edge, it rejects the proof $c$ with probability at least $1/|E|$.*

*Proof sketch.* By Theorem 4.3, $|\mathrm{Catch}(E,c)| \ge 1$. Dividing the inequality $1 \le |\mathrm{Catch}(E,c)|$ by the positive integer $|E|$ (cast into the rationals) gives the claim. The probability interpretation follows because the challenge is uniform over $E$, so the rejection probability is exactly $|\mathrm{Catch}(E,c)|/|E|$. $\square$

**Corollary 4.4.1 (soundness for unsatisfiable instances).** If the graph is *not* 3-colourable — i.e. *no* proper colouring exists — then the hypothesis of Theorem 4.4 holds for *every* claimed colouring $c$, so the verifier rejects any prover with probability at least $1/|E|$ per round.

**Amplification (discussion).** A single round leaves a cheater an acceptance probability of at most $1 - 1/|E|$. Running $m$ independent rounds and accepting only if all succeed reduces the cheating probability to at most $(1 - 1/|E|)^m$; choosing $m \ge |E|\,\ln(1/\varepsilon)$ drives it below any target $\varepsilon$, since $(1 - 1/|E|)^{|E|} \le e^{-1}$. This standard amplification is not formalized here but is a self-contained probability argument built directly on Theorem 4.4 (see Future Directions).

### 4.3 Perfect honest-verifier zero knowledge

The protocol's privacy is captured by analyzing the distribution of the revealed view on a fixed challenged edge. Fix an edge with *true* endpoint colours $a, b \in \mathbb{F}_3$, $a \neq b$ (which holds for the honest prover by properness). As $\pi$ ranges over $S_3$, the revealed view is $(\pi(a), \pi(b))$. Let
$$\mathrm{DistinctPairs} = \{(x,y) \in \mathbb{F}_3 \times \mathbb{F}_3 : x \neq y\}, \qquad |\mathrm{DistinctPairs}| = 3 \cdot 2 = 6.$$

**Theorem 4.5 (revealed view is well-formed — revealedView\_distinct).** *For an honest prover with proper colouring $c$ and any edge $e = (u,v)$ with $c(u) \neq c(v)$, and any $\pi \in S_3$, the revealed pair consists of distinct colours: $\pi(c(u)) \neq \pi(c(v))$.* In particular $\mathrm{revealedView}(\pi, c, e) \in \mathrm{DistinctPairs}$.

*Proof sketch.* Injectivity of $\pi$ applied to $c(u) \neq c(v)$. $\square$

**Theorem 4.6 (injectivity — hvzk\_view\_injective).** *Fix $a, b \in \mathbb{F}_3$ with $a \neq b$. The view map*
$$\Phi_{a,b} : S_3 \to \mathrm{DistinctPairs}, \qquad \Phi_{a,b}(\pi) = (\pi(a), \pi(b))$$
*is injective.*

*Proof sketch.* Suppose $\Phi_{a,b}(\pi) = \Phi_{a,b}(\rho)$, i.e. $\pi(a) = \rho(a)$ and $\pi(b) = \rho(b)$. Then $\rho^{-1}\pi$ fixes both $a$ and $b$. In $S_3$, a permutation fixing two of the three points must fix the third as well (the remaining point has nowhere else to go), hence $\rho^{-1}\pi = \mathrm{id}$ and $\pi = \rho$. $\square$

**Theorem 4.7 (bijection — hvzk\_bijection).** *Fix $a, b \in \mathbb{F}_3$ with $a \neq b$. The view map $\Phi_{a,b} : S_3 \to \mathrm{DistinctPairs}$ is a bijection. Consequently, pushing the uniform distribution on $S_3$ forward along $\Phi_{a,b}$ yields the uniform distribution on $\mathrm{DistinctPairs}$.*

*Proof sketch.* By Theorem 4.6, $\Phi_{a,b}$ is injective. Both finite sets have cardinality $6$ ($|S_3| = 3! = 6$ and $|\mathrm{DistinctPairs}| = 3 \cdot 2 = 6$), so an injection between them is automatically a bijection. Since $\Phi_{a,b}$ is a bijection and $\pi$ is uniform on $S_3$, each of the six distinct pairs is hit by exactly one $\pi$, hence occurs with probability $1/6$ — the uniform law on $\mathrm{DistinctPairs}$, independent of $(a,b)$. $\square$

**Interpretation: perfect zero knowledge.** Theorem 4.7 is the crux of privacy. The real view on a challenged edge — under the honest prover's random colour shuffle — is *exactly* a uniform random ordered pair of distinct colours, with a distribution that does not depend on the actual colours $a, b$ or on the rest of the colouring $c$. Therefore a trivial **simulator** that simply outputs a uniformly random element of $\mathrm{DistinctPairs}$ reproduces the verifier's view *perfectly* (zero statistical distance), without any access to the witness $c$. This is **perfect honest-verifier zero knowledge**: the verifier provably learns nothing about $c$ beyond what it could have generated alone. The exact-bijection phenomenon is special to $k = 3$, where the fibre size $(k-2)! = 1$; for $k > 3$ the same conclusion holds via uniform fibres rather than a bijection (see Future Directions).

---

## 5. Bridge to the PCP Theorem

The PCP theorem states $\mathrm{NP} \subseteq \mathrm{PCP}(\mathrm{poly}, O(1))$: every NP language has membership proofs checkable by a randomized verifier that reads only a *constant* number of proof symbols, accepting valid proofs and rejecting invalid ones with constant probability. We make the *constant-query local-verifiability* content concrete on 3-colourability.

**Model.** A PCP-style proof is a colouring $c : V \to \mathbb{F}_3$ — a proof string indexed by vertices over the constant-size alphabet $\mathbb{F}_3$. The verifier's randomness is a single edge $e \in E$; it queries exactly the two endpoint symbols $c(e_1), c(e_2)$ and accepts iff they differ.

**Definition 5.1 (local verifier).** $\mathrm{pcpVerifier}(c, e) \iff c(e_1) \neq c(e_2)$.

**Definition 5.2 (query positions).** $\mathrm{queryPositions}(e) = \{e_1, e_2\}$, the (multiset-collapsed) set of proof positions read on challenge $e$.

**Theorem 5.1 (constant query complexity — query\_count\_le\_two).** *For every challenge edge $e$, $|\mathrm{queryPositions}(e)| \le 2$, independent of $|V|$.*

*Proof sketch.* $\mathrm{queryPositions}(e) = \{e_1, e_2\}$ is built by inserting one element into a singleton, so its cardinality is at most $1 + 1 = 2$ by the inequality $|\{x\} \cup S| \le |S| + 1$. $\square$

This is precisely the $O(1)$ in $\mathrm{PCP}(\mathrm{poly}, O(1))$: the verifier inspects at most two proof symbols regardless of instance size.

**Theorem 5.2 (local checks $=$ global witness — pcp\_accepts\_all\_iff\_proper).** *For all $E$ and $c$,*
$$\big(\forall e \in E,\ \mathrm{pcpVerifier}(c, e)\big) \;\iff\; \mathrm{IsProperColoring}(E, c).$$

*Proof sketch.* Both sides unfold definitionally to $\forall e \in E,\ c(e_1) \neq c(e_2)$; the equivalence is an identity. $\square$

The two-symbol local tests, quantified over all edges, are *exactly* the global NP-witness predicate. This honest definitional bridge is what makes "local checkability" equivalent to "global correctness" for this problem.

**Theorem 5.3 (perfect completeness — pcp\_perfect\_completeness).** *If $c$ is a proper colouring of $E$, then for every $\pi \in S_3$ the honest randomized proof $\pi \circ c$ is accepted on every edge: $\forall e \in E,\ \mathrm{pcpVerifier}(\pi \circ c, e)$.*

*Proof sketch.* Combine Theorem 4.1 (properness preserved by $\pi$) with Theorem 5.2 (acceptance-on-all-edges equals properness). $\square$

**Theorem 5.4 (existence of a rejecting query — pcp\_soundness\_exists\_reject).** *If the graph is not 3-colourable (no proper colouring exists), then for every proof $c$ there is an edge $e \in E$ on which the verifier rejects: $\exists e \in E,\ \neg\,\mathrm{pcpVerifier}(c, e)$.*

*Proof sketch.* Non-3-colourability implies $c$ is not proper (else it would be a witness), so Theorem 4.2 yields a catching edge $e$ with $c(e_1) = c(e_2)$, i.e. $\neg\,\mathrm{pcpVerifier}(c, e)$. $\square$

**Theorem 5.5 (soundness gap for proof-checking — pcp\_soundness\_gap).** *Let $|E| > 0$. If the graph is not 3-colourable, then against any proof $c$ the verifier rejects with probability at least $1/|E|$ over a uniform random edge:*
$$\frac{1}{|E|} \;\le\; \frac{|\{e \in E : c(e_1) = c(e_2)\}|}{|E|}.$$

*Proof sketch.* Non-3-colourability makes every $c$ improper; apply Theorem 4.4. $\square$

**What is and isn't captured.** The bridge formally captures the *constant-query* aspect (Theorem 5.1), the equivalence of local checks with the global witness (Theorem 5.2), *perfect completeness* (Theorem 5.3), and a *positive soundness gap* (Theorems 5.4–5.5). What it does **not** capture — and what constitutes the genuine depth of the PCP theorem — is **gap amplification**: boosting the instance-dependent gap $1/|E|$ to a *universal constant* across all of NP, while keeping the query count constant. That amplification, together with the NP-hardness of the resulting constant-gap problem, is supplied by the full PCP machinery (gap-preserving reductions and proof composition) and is deliberately outside the present scope.

---

## 6. Algorithms

We summarize the procedures implied by the formal development; full type-hinted implementations appear in the accompanying demonstration code.

**Algorithm A (Proper-colouring verification / local check).** Given $E$ and $c$, return *accept* iff $c(e_1) \neq c(e_2)$ for all $e \in E$. Complexity $O(|E|)$ for the global check; the *single-round local check* is $O(1)$, reading two symbols. This realizes Definitions 3.1/5.1 and Theorem 5.2.

**Algorithm B (Honest prover round).** Sample $\pi \in S_3$ uniformly; on verifier challenge $e = (u,v)$, output $(\pi(c(u)), \pi(c(v)))$. By Theorem 4.1 the output is always a distinct pair. Complexity $O(1)$ per round after an $O(|V|)$ commitment.

**Algorithm C (Soundness search / catching edge).** Given an improper $c$, scan $E$ to find an edge with $c(e_1) = c(e_2)$; such an edge exists by Theorem 4.2 and the catching fraction is $\ge 1/|E|$ by Theorem 4.4. Complexity $O(|E|)$.

**Algorithm D (Perfect simulator for HVZK).** Without access to $c$, output a uniformly random element of $\mathrm{DistinctPairs}$. By Theorem 4.7 this matches the real view distribution exactly. Complexity $O(1)$.

**Algorithm E (Soundness amplification).** Repeat Algorithm B/local-check over $m$ independent challenges; accept iff all rounds accept. Against an unsatisfiable instance the cheating probability is $\le (1 - 1/|E|)^m$; $m = \lceil |E|\,\ln(1/\varepsilon)\rceil$ suffices for error $\le \varepsilon$.

---

## 7. Applications

- **Zero-knowledge proofs for all of NP.** Because 3-colourability is NP-complete, the GMW protocol composes with NP-reductions to give zero-knowledge proofs for arbitrary NP statements — the foundational result of the area.
- **Verifiable computation and zk-SNARKs.** Commit-challenge-open structure with a few cheap verifier queries is the template behind succinct non-interactive arguments (SNARKs) used in privacy-preserving ledgers and rollups, where a verifier checks a short certificate instead of re-executing a computation.
- **Anonymous credentials and identification.** Sigma protocols of this shape let a party prove possession of a secret (a colouring, a discrete log, a signature) without disclosing it, enabling privacy-preserving authentication.
- **Probabilistically checkable proofs and hardness of approximation.** The constant-query verifier viewpoint connects directly to the PCP theorem and, through it, to inapproximability results for optimization problems.

---

## 8. Discussion

The development isolates *what is easy and what is hard* with unusual clarity. Completeness, the soundness gap, and perfect HVZK for $k = 3$ are clean, finite, and fully provable from first principles — the HVZK statement reducing to a cardinality coincidence ($|S_3| = |\mathrm{DistinctPairs}| = 6$) and the simple fact that a permutation of three points fixing two fixes the third. The constant-query PCP reframing is likewise immediate. By contrast, the genuinely deep content — amplifying a $1/|E|$ gap to a universal constant across NP — is honestly flagged as outside scope, and is exactly the part the PCP theorem supplies.

A subtlety worth emphasizing is the *perfection* of the zero-knowledge guarantee here: not statistical, not computational, but a literal equality of distributions, witnessed by an explicit bijection. This is a feature of the small alphabet; it degrades gracefully (to uniform-fibre arguments) as the number of colours grows.

---

## 9. Future Directions

1. **Perfect HVZK for $k$-colouring via a transitive symmetric-group action.** Conjecture: for every $k \ge 3$, the GMW protocol over $\mathbb{F}_k$ is perfectly HVZK. For $k > 3$ the map $\pi \mapsto (\pi(a), \pi(b))$ from $S_k$ is no longer a bijection onto distinct pairs ($k!$ vs $k(k-1)$), but the action of $S_k$ on ordered distinct pairs is transitive with uniform fibres of size $(k-2)!$, so the pushforward of the uniform measure on $S_k$ is still uniform on distinct pairs. The $k = 3$ case is the degenerate fibre-size-$1$ instance.

2. **Soundness amplification by independent repetition.** Conjecture: running the verifier on $m$ independent edges drives the soundness error of a non-3-colourable instance from $1 - 1/|E|$ to $(1 - 1/|E|)^m < \varepsilon$ once $m \ge |E|\,\ln(1/\varepsilon)$. The single-edge rejecting set has density $\ge 1/|E|$, and independence makes per-round acceptance probabilities multiply.

3. **Gap-preserving reduction certifies a constant-query PCP for 3-colouring.** Conjecture: there is a polynomial-time, gap-preserving reduction from any constant-gap NP problem to graph 3-colouring such that the 2-query local verifier inherits a *universal constant* soundness gap (independent of $|E|$), formally instantiating the constant-query, constant-gap content of $\mathrm{NP} \subseteq \mathrm{PCP}(\mathrm{poly}, O(1))$. Constant query complexity is already achieved; the remaining difficulty is amplifying the gap to a constant while keeping queries constant.

---

## 10. Conclusion

We have given a complete, self-contained formal account of the GMW zero-knowledge proof for graph 3-colourability — perfect completeness, a clean $1/|E|$ soundness gap, and *perfect* honest-verifier zero knowledge via an explicit $S_3 \cong \mathrm{DistinctPairs}$ bijection — and bridged it to the constant-query backbone of the PCP theorem through a 2-query local verifier. The result is a transparent map of the territory: the local, finite, perfectly analyzable structure of zero-knowledge proof-checking on one side, and the single deep ingredient of gap amplification on the other.
