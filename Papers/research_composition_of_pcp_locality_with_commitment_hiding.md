# Composing Locality with Hiding: An Exact Factorization of Perfect Zero Knowledge for Committed Local-Oracle Protocols

**Author:** Aristotle

**Date:** 2026-08-26

---

## Abstract

We isolate, in a finite combinatorial setting, the exact mechanism by which the standard "probabilistically checkable proof plus commitment" compiler yields zero knowledge. We introduce the notion of a *committed local-oracle protocol*: a randomized proof string $\mathrm{proof} : P \to (I \to A)$ over a coordinate set $I$ and alphabet $A$, a commitment scheme $(\mathrm{com}, \mathrm{open})$ with randomness space $R_c$, and an honest verifier who, on coins $r \in R_v$, opens a query set $Q(r) \subseteq I$ of size at most a constant $q$. The transcript of an execution is the quadruple (commitment, verifier coins, opened partial assignment, opening data).

Our main theorem states that two *independent* hypotheses compose exactly. The first, **perfect hiding of unopened coordinates**, requires that any two messages agreeing on a set $T$ be carried into one another by a bijection of the commitment randomness preserving both the commitment and the openings on $T$. The second, **perfect simulation of the opened coordinates**, requires that for each fixing of the verifier's coins the distribution of the opened partial assignment be reproduced exactly by a witness-free simulator. Under these hypotheses the *full* transcript distribution of the real interaction coincides with the simulator's, transcript by transcript: the protocol is **perfect honest-verifier zero knowledge**. Consequently every event has equal probability under the two distributions and every (computationally unbounded) distinguisher has advantage exactly zero.

The proof is a fibrewise counting argument over the restriction map $u \mapsto u|_{Q(r)}$: hiding shows that the number of commitment randomnesses consistent with a given (commitment, opening) pair depends on the message only through its restriction to the opened set, and simulation then matches the two counting measures fibre by fibre. All statements are integral (cross-multiplied), so no division is performed until the final step.

We supply a proved instance of hiding — the coordinate-wise one-time pad over an arbitrary finite abelian group — and an end-to-end instance of the full theorem: the committed $2$-query probabilistically checkable proof for graph $3$-colourability is perfect honest-verifier zero knowledge, the simulation resource being exactly the *sharp $2$-transitivity* of the symmetric group on three letters. Finally we delimit the theorem: each hypothesis is necessary (explicit minimal counterexamples at query complexity one), and mere transitivity of the rerandomization group is provably insufficient — cyclic recolouring admits **no** simulator over any randomness space.

**Keywords:** zero knowledge, probabilistically checkable proofs, commitment schemes, query complexity, sharp 2-transitivity, graph 3-colouring, perfect simulation.

---

## 1. Introduction

### 1.1 The problem

A zero-knowledge proof lets a prover convince a verifier of a statement while transferring no information beyond the statement's truth. The canonical construction for $\mathsf{NP}$ combines two ingredients:

* a **local verifier** — a verifier that reads only a constant number $q$ of symbols of a (possibly enormous) proof string;
* a **commitment scheme** — a cryptographic envelope allowing the prover to fix the proof string in advance and later reveal selected symbols.

The soundness of the resulting protocol is a statement about the local verifier alone: if the statement is false, no proof string satisfies too many of the local constraints, so a random query set catches a cheat with constant probability. Soundness is well understood and is not our subject.

Zero knowledge is subtler. The verifier genuinely receives data — $q$ symbols per round, plus a commitment and the corresponding openings — and the claim that this data is "nothing" is a claim about *distributions*, formalized by requiring that a witness-free simulator reproduce the transcript distribution.

Textbook treatments of this argument tend to interleave three distinct concerns: the algebra of the commitment, the symmetry of the alphabet, and the smallness of the query set. Our purpose here is to *separate* them, and to show that the separation is exact rather than approximate.

### 1.2 Contributions

1. **A definition.** The notion of a *committed local-oracle protocol* (Section 2), a finite combinatorial object packaging commitment, opening, query pattern, query bound, and randomized proof string, together with an explicit transcript space in which unopened coordinates are formally absent.

2. **Two resources.** *Perfect hiding of unopened coordinates* (Definition 3.2) and *perfect simulation of the opened coordinates* (Definition 3.4), stated as finite counting/bijection statements requiring no measure theory.

3. **An exact composition theorem** (Theorem 5.1): the two resources compose to perfect honest-verifier zero knowledge with no statistical slack, together with the corollaries of event-wise equality and zero distinguishing advantage (Corollaries 5.2, 5.3).

4. **A proved hiding instance** (Theorem 6.1): the coordinate-wise one-time pad over any finite abelian group perfectly hides unopened coordinates, while openings genuinely reveal the pad — so the opening data is a real component of the transcript, not a formal placeholder.

5. **An end-to-end instance** (Theorem 7.5): the committed $2$-query probabilistically checkable proof for graph $3$-colourability is perfect honest-verifier zero knowledge, with the zero-knowledge content identified as the sharp $2$-transitivity of the symmetric group on three letters (Theorem 7.3).

6. **Tightness** (Section 8): each hypothesis fails to be droppable, witnessed by protocols with query complexity one; and mere transitivity of the alphabet symmetry group is insufficient, witnessed by an impossibility result quantifying over *all* simulators (Theorem 8.3).

### 1.3 Organization

Section 2 introduces the model. Section 3 states the two resources. Section 4 develops the counting machinery. Section 5 proves the composition theorem. Section 6 treats the one-time pad. Section 7 gives the $3$-colouring instance. Section 8 establishes tightness. Section 9 discusses algorithmic content, Section 10 applications and future directions.

---

## 2. The model

Throughout, all index sets, alphabets, message spaces and randomness spaces are finite, and all distributions are uniform on their randomness spaces. Fix finite types:

* $I$ — the **coordinate set** of the proof string;
* $A$ — the **alphabet**;
* $C$ — the space of **commitment messages**;
* $O$ — the space of **opening data**;
* $R_c$ — the **commitment randomness**;
* $R_v$ — the **verifier randomness**;
* $P$ — the **prover randomness**;
* $S$ — the **simulator randomness**.

### 2.1 Partial views

**Definition 2.1 (Restriction).** For $T \subseteq I$ and $f : I \to A$, the *restriction of $f$ to $T$* is the partial assignment
$$f|_T : I \to A \cup \{\bot\}, \qquad f|_T(i) = \begin{cases} f(i) & i \in T,\\ \bot & i \notin T.\end{cases}$$

Two elementary facts are used constantly.

**Lemma 2.2 (Restrictions agree iff functions agree pointwise on $T$).** $f|_T = g|_T$ if and only if $f(i) = g(i)$ for all $i \in T$.

*Proof.* If the restrictions are equal, evaluating at $i \in T$ gives $f(i) = g(i)$. Conversely, define both sides pointwise and split on $i \in T$. $\square$

**Lemma 2.3 (Only opened coordinates are defined).** If $f|_T(i) \ne \bot$ then $i \in T$.

*Proof.* Immediate from the definition. $\square$

Lemma 2.3 is what makes the transcript space *honest*: unopened coordinates leave no trace in the recorded partial assignment.

### 2.2 Committed local-oracle protocols

**Definition 2.4 (Committed local-oracle protocol).** A *committed local-oracle protocol* over $(I, A, C, O, R_c, R_v, P)$ consists of:

* a **commitment map** $\mathrm{com} : (I \to A) \times R_c \to C$;
* an **opening map** $\mathrm{open} : (I \to A) \times R_c \times \mathcal{P}(I) \to O$;
* a **query pattern** $Q : R_v \to \mathcal{P}(I)$;
* a **query bound** $q \in \mathbb{N}$ with $|Q(r)| \le q$ for all $r \in R_v$;
* a **randomized proof string** $\mathrm{proof} : P \to (I \to A)$.

The intended semantics: the prover samples $p \in P$ and $\rho \in R_c$ uniformly, publishes $\mathrm{com}(\mathrm{proof}(p), \rho)$; the verifier samples $r \in R_v$ uniformly and announces the query set $Q(r)$; the prover reveals the symbols of $\mathrm{proof}(p)$ on $Q(r)$ together with the opening data $\mathrm{open}(\mathrm{proof}(p), \rho, Q(r))$.

**Definition 2.5 (Transcript).** The *transcript space* is
$$\mathcal{T} = C \times R_v \times \bigl(I \to A \cup \{\bot\}\bigr) \times O.$$
The *real transcript* on randomness $(p, \rho, r)$ is
$$\mathrm{Real}(p,\rho,r) = \bigl(\mathrm{com}(\mathrm{proof}(p),\rho),\ r,\ \mathrm{proof}(p)|_{Q(r)},\ \mathrm{open}(\mathrm{proof}(p),\rho,Q(r))\bigr).$$
Given a *simulator* $\mathrm{sim} : R_v \times S \to (I \to A)$, the *simulated transcript* on randomness $(s, \rho, r)$ is
$$\mathrm{Sim}(s,\rho,r) = \bigl(\mathrm{com}(\mathrm{sim}(r,s),\rho),\ r,\ \mathrm{sim}(r,s)|_{Q(r)},\ \mathrm{open}(\mathrm{sim}(r,s),\rho,Q(r))\bigr).$$

Note that the simulator commits and opens *honestly*; its only freedom is which string to commit to. This is the strongest and cleanest form of simulation for this compiler, and it is what the $3$-colouring instance provides.

**Proposition 2.6 (Constant-query locality of the transcript).** For every $p \in P$ and $r \in R_v$,
$$\bigl|\{\, i \in I : \mathrm{proof}(p)|_{Q(r)}(i) \ne \bot \,\}\bigr| \le q.$$

*Proof.* By Lemma 2.3 the set on the left is contained in $Q(r)$, whose cardinality is at most $q$ by hypothesis. $\square$

Thus, no matter how large $|I|$ is, a transcript exposes at most $q$ symbols of the proof string.

---

## 3. The two resources

### 3.1 Hiding

**Definition 3.1 (Fibre count).** For $u : I \to A$, $T \subseteq I$, $c \in C$, $o \in O$, set
$$\mathrm{fib}(u, T, c, o) = \bigl|\{\, \rho \in R_c : \mathrm{com}(u,\rho) = c \ \text{and}\ \mathrm{open}(u,\rho,T) = o \,\}\bigr|.$$

This is the number of commitment coin sequences consistent with the observable pair $(c, o)$ when the committed message is $u$ and the opened set is $T$.

**Definition 3.2 (Perfect hiding of unopened coordinates).** A committed local-oracle protocol *perfectly hides unopened coordinates* if for every $T \subseteq I$ and all $u, v : I \to A$ with $u(i) = v(i)$ for all $i \in T$, there exists a bijection $e : R_c \to R_c$ such that for all $\rho \in R_c$,
$$\mathrm{com}(u,\rho) = \mathrm{com}(v, e(\rho)) \qquad\text{and}\qquad \mathrm{open}(u,\rho,T) = \mathrm{open}(v,e(\rho),T).$$

**Remarks.** (i) The condition is a *re-labelling principle*: messages indistinguishable on the opened set are indistinguishable in the transcript, uniformly in the commitment randomness. (ii) One could instead demand equality of pushforward measures on $C \times O$; for finite randomness spaces the two formulations are equivalent up to Lemma 4.1 below, and the bijection form is what concrete schemes actually supply (Section 6). (iii) The definition quantifies over *all* $T$, including $T = \emptyset$ (pure hiding) and $T = I$ (which then forces $u = v$, so the condition is vacuous there).

### 3.2 Simulation

**Definition 3.3 (Local view distributions).** For $r \in R_v$ and a partial assignment $t : I \to A \cup \{\bot\}$, write
$$N_{\mathrm{real}}(r,t) = \bigl|\{\, p \in P : \mathrm{proof}(p)|_{Q(r)} = t \,\}\bigr|, \qquad N_{\mathrm{sim}}(r,t) = \bigl|\{\, s \in S : \mathrm{sim}(r,s)|_{Q(r)} = t \,\}\bigr|.$$

**Definition 3.4 (Perfect simulation of the opened coordinates).** A simulator $\mathrm{sim}$ *perfectly simulates the opened coordinates* if for all $r \in R_v$ and all partial assignments $t$,
$$N_{\mathrm{real}}(r,t)\cdot |S| \;=\; N_{\mathrm{sim}}(r,t)\cdot |P|.$$

Dividing, this says $N_{\mathrm{real}}(r,t)/|P| = N_{\mathrm{sim}}(r,t)/|S|$ — the two local view distributions coincide. The cross-multiplied form is preferred because it is an identity of natural numbers; performing the division prematurely loses information when carried through the subsequent algebra, and the rational statement follows at the end in one step.

The following criterion converts a structural symmetry into a simulation guarantee and is the workhorse for concrete instances.

**Theorem 3.5 (Bijection criterion).** Suppose for each $r \in R_v$ there is a bijection $\Phi_r : P \to S$ with
$$\mathrm{proof}(p)|_{Q(r)} = \mathrm{sim}\bigl(r, \Phi_r(p)\bigr)\big|_{Q(r)} \qquad \text{for all } p \in P.$$
Then $\mathrm{sim}$ perfectly simulates the opened coordinates.

*Proof.* Fix $r$. Since $\Phi_r$ is a bijection, $|P| = |S|$. Moreover $\Phi_r$ restricts to a bijection between $\{p : \mathrm{proof}(p)|_{Q(r)} = t\}$ and $\{s : \mathrm{sim}(r,s)|_{Q(r)} = t\}$: it maps the former into the latter by the view-preservation hypothesis, it is injective, and it is surjective onto the latter because any $s$ in the latter has a preimage $p$ whose view equals that of $s$. Hence $N_{\mathrm{real}}(r,t) = N_{\mathrm{sim}}(r,t)$, and multiplying by the equal cardinalities gives the claim. $\square$

Theorem 3.5 is the abstract form of the statement "the prover's rerandomization group acts sharply transitively on the set of admissible local views".

---

## 4. Counting machinery

**Definition 4.1 (Transcript counts and probabilities).** For $\tau \in \mathcal{T}$ put
$$\mathrm{RC}(\tau) = \bigl|\{ (p,\rho,r) \in P\times R_c\times R_v : \mathrm{Real}(p,\rho,r) = \tau \}\bigr|,$$
$$\mathrm{SC}(\tau) = \bigl|\{ (s,\rho,r) \in S\times R_c\times R_v : \mathrm{Sim}(s,\rho,r) = \tau \}\bigr|,$$
and define the transcript probabilities
$$\Pr_{\mathrm{real}}(\tau) = \frac{\mathrm{RC}(\tau)}{|P|\,|R_c|\,|R_v|}, \qquad \Pr_{\mathrm{sim}}(\tau) = \frac{\mathrm{SC}(\tau)}{|S|\,|R_c|\,|R_v|},$$
with the convention $x/0 = 0$ (so that empty randomness spaces are handled without case distinctions).

**Lemma 4.2 (Hiding makes the fibre count depend only on the opened part).** Assume perfect hiding of unopened coordinates. If $u(i) = v(i)$ for all $i \in T$, then for all $c \in C$, $o \in O$,
$$\mathrm{fib}(u,T,c,o) = \mathrm{fib}(v,T,c,o).$$

*Proof.* Let $e$ be the bijection supplied by Definition 3.2 for $(T,u,v)$. If $\rho$ satisfies $\mathrm{com}(u,\rho)=c$ and $\mathrm{open}(u,\rho,T)=o$, then $\mathrm{com}(v,e(\rho)) = \mathrm{com}(u,\rho) = c$ and $\mathrm{open}(v,e(\rho),T) = \mathrm{open}(u,\rho,T) = o$, so $e$ maps the first fibre into the second. The inverse map $\sigma \mapsto e^{-1}(\sigma)$ maps the second into the first, by applying the defining identities at $\rho = e^{-1}(\sigma)$. The two maps are mutually inverse, so the fibres are in bijection. $\square$

**Lemma 4.3 (Fibrewise decomposition of the real count).** For all $c \in C$, $r_0 \in R_v$, $t : I \to A\cup\{\bot\}$, $o \in O$,
$$\mathrm{RC}(c,r_0,t,o) \;=\; \sum_{p \in P} \bigl[\, \mathrm{proof}(p)|_{Q(r_0)} = t \,\bigr]\cdot \mathrm{fib}\bigl(\mathrm{proof}(p), Q(r_0), c, o\bigr),$$
where $[\,\cdot\,]$ is the indicator.

*Proof.* Expand $\mathrm{RC}$ as a triple sum of indicators over $(p,\rho,r)$. The transcript records $r$ verbatim in its second component, so for fixed $(p,\rho)$ the inner sum over $r$ collapses to the single term $r = r_0$; the surviving indicator is that of the conjunction
$$\mathrm{com}(\mathrm{proof}(p),\rho) = c, \quad \mathrm{proof}(p)|_{Q(r_0)} = t, \quad \mathrm{open}(\mathrm{proof}(p),\rho,Q(r_0)) = o.$$
The middle conjunct does not involve $\rho$, so it factors out of the sum over $\rho$; the remaining sum over $\rho$ is exactly $\mathrm{fib}(\mathrm{proof}(p), Q(r_0), c, o)$. $\square$

**Lemma 4.4 (Fibrewise decomposition of the simulated count).** Identically,
$$\mathrm{SC}(c,r_0,t,o) \;=\; \sum_{s \in S} \bigl[\, \mathrm{sim}(r_0,s)|_{Q(r_0)} = t \,\bigr]\cdot \mathrm{fib}\bigl(\mathrm{sim}(r_0,s), Q(r_0), c, o\bigr).$$

*Proof.* Verbatim the proof of Lemma 4.3 with $\mathrm{proof}(p)$ replaced by $\mathrm{sim}(r_0,s)$. $\square$

Note the crucial structural feature of Lemmas 4.3 and 4.4: **the right-hand sides never mention any coordinate outside $Q(r_0)$.** The count factors into a *horizontal* term (which randomness produces the visible view $t$) and a *vertical* term (how many commitment coins are consistent with $(c,o)$).

---

## 5. The composition theorem

**Theorem 5.1 (Exact composition; perfect honest-verifier zero knowledge).** Let a committed local-oracle protocol perfectly hide unopened coordinates, and let $\mathrm{sim}$ perfectly simulate the opened coordinates. Assume $P$ and $S$ are non-empty. Then for every transcript $\tau \in \mathcal{T}$,
$$\Pr_{\mathrm{real}}(\tau) = \Pr_{\mathrm{sim}}(\tau).$$

Moreover, without any non-emptiness assumption on $R_c$ or $R_v$, the integral identity
$$\mathrm{RC}(\tau)\cdot |S| = \mathrm{SC}(\tau)\cdot |P|$$
holds (assuming only $P \ne \emptyset$).

*Proof.* Write $\tau = (c, r_0, t, o)$ and abbreviate $T = Q(r_0)$.

**Step 1 (Decompose).** By Lemmas 4.3 and 4.4,
$$\mathrm{RC}(\tau) = \sum_{p \in F_{\mathrm{real}}} \mathrm{fib}(\mathrm{proof}(p), T, c, o), \qquad \mathrm{SC}(\tau) = \sum_{s \in F_{\mathrm{sim}}} \mathrm{fib}(\mathrm{sim}(r_0,s), T, c, o),$$
where $F_{\mathrm{real}} = \{p : \mathrm{proof}(p)|_T = t\}$ and $F_{\mathrm{sim}} = \{s : \mathrm{sim}(r_0,s)|_T = t\}$, so $|F_{\mathrm{real}}| = N_{\mathrm{real}}(r_0,t)$ and $|F_{\mathrm{sim}}| = N_{\mathrm{sim}}(r_0,t)$.

**Step 2 (Empty fibre).** Suppose $F_{\mathrm{real}} = \emptyset$. Then $N_{\mathrm{real}}(r_0,t) = 0$, so by Definition 3.4, $N_{\mathrm{sim}}(r_0,t)\cdot|P| = 0$; since $P \ne \emptyset$ we get $|P| > 0$, hence $N_{\mathrm{sim}}(r_0,t) = 0$ and $F_{\mathrm{sim}} = \emptyset$. Both sums are empty and both counts vanish; the integral identity holds trivially. (This is the one place non-emptiness of $P$ is used.)

**Step 3 (Non-empty fibre: hiding flattens the summand).** Otherwise choose $p_0 \in F_{\mathrm{real}}$ and set
$$N := \mathrm{fib}\bigl(\mathrm{proof}(p_0), T, c, o\bigr).$$
For any $p \in F_{\mathrm{real}}$ we have $\mathrm{proof}(p)|_T = t = \mathrm{proof}(p_0)|_T$, hence by Lemma 2.2 the two strings agree pointwise on $T$, hence by Lemma 4.2 their fibre counts agree:
$$\mathrm{fib}(\mathrm{proof}(p),T,c,o) = N.$$
The same argument applies to any $s \in F_{\mathrm{sim}}$: $\mathrm{sim}(r_0,s)|_T = t = \mathrm{proof}(p_0)|_T$, so $\mathrm{sim}(r_0,s)$ agrees with $\mathrm{proof}(p_0)$ pointwise on $T$, so its fibre count is also $N$. Crucially, Lemma 4.2 is indifferent to the provenance of the message: the *same* constant $N$ governs both sides. Therefore
$$\mathrm{RC}(\tau) = N_{\mathrm{real}}(r_0,t)\cdot N, \qquad \mathrm{SC}(\tau) = N_{\mathrm{sim}}(r_0,t)\cdot N.$$

**Step 4 (Simulation matches the fibre sizes).** Multiplying the first identity by $|S|$ and applying Definition 3.4,
$$\mathrm{RC}(\tau)\cdot|S| = \bigl(N_{\mathrm{real}}(r_0,t)\cdot|S|\bigr)\cdot N = \bigl(N_{\mathrm{sim}}(r_0,t)\cdot|P|\bigr)\cdot N = \mathrm{SC}(\tau)\cdot |P|.$$

**Step 5 (Divide).** If $|R_c| = 0$ or $|R_v| = 0$ both probabilities are $0$ by the convention $x/0 = 0$. Otherwise $|P|, |S|, |R_c|, |R_v| > 0$ and, cross-multiplying,
$$\mathrm{RC}(\tau)\cdot \bigl(|S|\,|R_c|\,|R_v|\bigr) = \bigl(\mathrm{RC}(\tau)|S|\bigr)|R_c||R_v| = \bigl(\mathrm{SC}(\tau)|P|\bigr)|R_c||R_v| = \mathrm{SC}(\tau)\cdot\bigl(|P|\,|R_c|\,|R_v|\bigr),$$
which is exactly $\Pr_{\mathrm{real}}(\tau) = \Pr_{\mathrm{sim}}(\tau)$. $\square$

Two corollaries are immediate from pointwise equality of the distributions.

**Corollary 5.2 (No event distinguishes).** Under the hypotheses of Theorem 5.1, for every finite set $E \subseteq \mathcal{T}$ of transcripts,
$$\sum_{\tau \in E} \Pr_{\mathrm{real}}(\tau) = \sum_{\tau \in E} \Pr_{\mathrm{sim}}(\tau).$$

**Corollary 5.3 (Zero distinguishing advantage).** Under the hypotheses of Theorem 5.1, for every finite $E \subseteq \mathcal{T}$ and every scoring function $f : \mathcal{T} \to \mathbb{Q}$ — with no restriction whatsoever on the computational resources used to compute $f$ —
$$\sum_{\tau \in E} f(\tau)\Pr_{\mathrm{real}}(\tau) \;-\; \sum_{\tau \in E} f(\tau)\Pr_{\mathrm{sim}}(\tau) \;=\; 0.$$

The advantage is exactly zero, not negligible; there is no security parameter and no asymptotics anywhere in the argument.

### 5.1 What the proof reveals

The architecture of the proof is a $2 \times 2$ separation of concerns:

| | controls | mechanism |
|---|---|---|
| **Vertical** ($R_c$) | unopened coordinates | hiding: bijection of commitment randomness, flattening the fibre count to a constant $N$ |
| **Horizontal** ($P$ vs. $S$) | opened coordinates | simulation: equality of fibre cardinalities $N_{\mathrm{real}} \leftrightarrow N_{\mathrm{sim}}$ |

Locality enters not as a hypothesis of Theorem 5.1 but as the reason the horizontal direction is tractable: the fibre of the restriction map is determined by at most $q$ symbols, so a witness-free simulator only has to reproduce a $q$-dimensional marginal. If $q = |I|$, "reproducing the marginal" is reproducing the entire proof distribution, and the second hypothesis becomes as hard as the original problem.

---

## 6. A proved hiding instance: the one-time pad

Let $A$ be a finite abelian group (written additively). Define a committed local-oracle protocol with commitment randomness $R_c = (I \to A)$ by

$$\mathrm{com}(u, \rho) = u + \rho \quad \text{(coordinate-wise)}, \qquad \mathrm{open}(u,\rho,T) = \rho|_T,$$

together with any query pattern $Q$ satisfying $|Q(r)| \le q$ and any randomized proof string.

Openings are informative: from the commitment $u+\rho$ and the revealed pad $\rho|_T$, the verifier recovers $u|_T$ exactly, so the protocol really does communicate the queried symbols. It is precisely because the openings are informative that hiding must be established *jointly* for the commitment and the openings, as in Definition 3.2 — and it is.

**Theorem 6.1 (The one-time pad perfectly hides unopened coordinates).** The protocol above perfectly hides unopened coordinates.

*Proof.* Let $T \subseteq I$ and let $u, v : I \to A$ agree on $T$. Take
$$e(\rho) = \rho + (u - v),$$
translation by the fixed element $u - v$ of the group $I \to A$; translation is a bijection with inverse translation by $v - u$.

*Commitment.* For all $i \in I$,
$$\bigl(v + e(\rho)\bigr)(i) = v(i) + \rho(i) + u(i) - v(i) = u(i) + \rho(i) = \bigl(u + \rho\bigr)(i),$$
so $\mathrm{com}(u,\rho) = \mathrm{com}(v, e(\rho))$.

*Openings.* For $i \in T$ we have $u(i) = v(i)$, hence $e(\rho)(i) = \rho(i) + u(i) - v(i) = \rho(i)$. Therefore $e(\rho)|_T = \rho|_T$, i.e. $\mathrm{open}(u,\rho,T) = \mathrm{open}(v, e(\rho), T)$. (Off $T$ both restrictions are $\bot$.) $\square$

Combining Theorem 6.1 with Theorem 5.1 reduces perfect honest-verifier zero knowledge of *any* one-time-padded local-oracle protocol to a single question about the alphabet: **is the $q$-symbol local view witness-independent?** We answer this for $3$-colouring next.

---

## 7. End-to-end instance: the committed $2$-query proof for graph $3$-colouring

### 7.1 The protocol

Let $V$ be a finite vertex set and $E \subseteq V \times V$ a finite set of (directed, for bookkeeping) edges. The alphabet is $A = \mathbb{Z}/3$, the colours.

**Definition 7.1.** A colouring $c : V \to \mathbb{Z}/3$ is *proper* for $E$ if $c(e_1) \ne c(e_2)$ for every $e = (e_1,e_2) \in E$.

The committed local-oracle protocol $\mathcal{P}_{E,c}$ is:

* **Coordinates** $I = V$; **alphabet** $A = \mathbb{Z}/3$.
* **Prover randomness** $P = \mathrm{Sym}(\mathbb{Z}/3)$, the six permutations of the palette; **proof string** $\mathrm{proof}(\pi) = \pi \circ c$.
* **Commitment** the coordinate-wise one-time pad of Section 6, with $R_c = (V \to \mathbb{Z}/3)$.
* **Verifier randomness** $R_v = E$, a uniformly chosen edge; **query pattern** $Q(e) = \{e_1, e_2\}$, whence $q = 2$.

**Proposition 7.2 (Query bound).** $|Q(e)| \le 2$ for every $e$, so the protocol has query complexity two; and by Proposition 2.6, a transcript exposes at most two symbols of the (arbitrarily long) proof string.

### 7.2 The simulation resource: sharp $2$-transitivity of $S_3$

**Theorem 7.3 (Sharp $2$-transitivity).** Let $x \ne y$ and $a \ne b$ in $\mathbb{Z}/3$. Then there is **exactly one** permutation $\pi$ of $\mathbb{Z}/3$ with $\pi(x) = a$ and $\pi(y) = b$.

*Proof.* *Existence.* Let $\pi_1$ be the transposition swapping $x$ and $a$ (the identity if $x = a$), so $\pi_1(x) = a$. Since $\pi_1$ is injective and $y \ne x$, we have $\pi_1(y) \ne a$. Let $\pi_2$ be the transposition swapping $\pi_1(y)$ and $b$, and set $\pi = \pi_2\pi_1$. Then $\pi(y) = \pi_2(\pi_1(y)) = b$, and $\pi(x) = \pi_2(a) = a$, because $a$ is neither $\pi_1(y)$ (shown above) nor $b$ (by hypothesis), so $\pi_2$ fixes $a$.

*Uniqueness.* Suppose $\pi, \sigma$ both send $x \mapsto a$, $y \mapsto b$. Let $z \in \mathbb{Z}/3$. If $z = x$ or $z = y$ then $\pi(z) = \sigma(z)$ by hypothesis. Otherwise, injectivity gives $\pi(z) \notin \{a,b\}$ and $\sigma(z) \notin \{a,b\}$; but in a three-element set there is exactly one element distinct from the two distinct elements $a$ and $b$, hence $\pi(z) = \sigma(z)$. Thus $\pi = \sigma$. $\square$

**Corollary 7.4 (The opened pair is uniform).** Let $c$ be proper for $E$ and $e \in E$. For any ordered pair $(a,b)$ of distinct colours,
$$\bigl|\{\pi \in \mathrm{Sym}(\mathbb{Z}/3) : \pi(c(e_1)) = a,\ \pi(c(e_2)) = b\}\bigr| = 1.$$
Consequently the pair of colours opened on the challenged edge is *exactly uniform* over the six ordered pairs of distinct colours, independently of $c$.

*Proof.* Properness gives $c(e_1) \ne c(e_2)$; apply Theorem 7.3 with $x = c(e_1)$, $y = c(e_2)$. Since $|\mathrm{Sym}(\mathbb{Z}/3)| = 6$ and there are six ordered pairs of distinct colours, each occurring exactly once, the distribution is uniform. $\square$

### 7.3 The simulator and the theorem

Let the simulator randomness be
$$S = \{(a,b) \in (\mathbb{Z}/3)^2 : a \ne b\}, \qquad |S| = 6,$$
and define, for a challenged edge $e$ and $s = (a,b) \in S$,
$$\mathrm{sim}(e, s)(w) = \begin{cases} a & w = e_1,\\ b & w = e_2,\\ 0 & \text{otherwise.}\end{cases}$$
The simulator never inspects $c$.

**Theorem 7.5 (Perfect honest-verifier zero knowledge of the committed $2$-query proof for $3$-colouring).** Let $c$ be proper for $E$. Then for every transcript $\tau$,
$$\Pr_{\mathrm{real}}(\tau) = \Pr_{\mathrm{sim}}(\tau),$$
where the real distribution is induced by uniform palette permutation, uniform pad and uniform edge, and the simulated distribution by uniform distinct colour pair, uniform pad and uniform edge.

*Proof.* We verify the two hypotheses of Theorem 5.1.

*Hiding.* The commitment is the coordinate-wise one-time pad over the abelian group $\mathbb{Z}/3$; apply Theorem 6.1.

*Simulation.* Apply the bijection criterion, Theorem 3.5, with
$$\Phi_e(\pi) = \bigl(\pi(c(e_1)),\ \pi(c(e_2))\bigr) \in S.$$
This is well defined: properness and injectivity of $\pi$ give $\pi(c(e_1)) \ne \pi(c(e_2))$. It is injective: if $\Phi_e(\pi) = \Phi_e(\sigma)$ then $\pi$ and $\sigma$ agree at the two distinct points $c(e_1), c(e_2)$, so $\pi = \sigma$ by the uniqueness half of Theorem 7.3. It is surjective: given distinct $(a,b)$, the existence half of Theorem 7.3 supplies $\pi$ with $\pi(c(e_1)) = a$, $\pi(c(e_2)) = b$. Finally, it preserves the opened view: on $Q(e) = \{e_1, e_2\}$ we have $\mathrm{proof}(\pi)(e_1) = \pi(c(e_1)) = a = \mathrm{sim}(e,\Phi_e(\pi))(e_1)$ and likewise at $e_2$ (using $e_1 \ne e_2$, which follows from properness), so by Lemma 2.2 the restrictions agree.

Both randomness spaces are non-empty ($|P| = |S| = 6$), so Theorem 5.1 applies. $\square$

**Proposition 7.6 (Perfect completeness).** If $c$ is proper for $E$ then for every palette permutation $\pi$ and every edge $e$, the two opened symbols differ: $\pi(c(e_1)) \ne \pi(c(e_2))$. Hence the honest verifier — who accepts iff the two revealed colours differ — accepts with probability $1$.

*Proof.* Properness gives $c(e_1) \ne c(e_2)$; injectivity of $\pi$ preserves this. $\square$

Note that properness is load-bearing in Theorem 7.5, not decoration: for an improper colouring the two opened symbols could coincide on a violated edge, whereas the simulator never outputs equal colours, so the two distributions would differ. Self-loops in $E$ are automatically excluded by properness.

---

## 8. Tightness: each hypothesis is necessary

We exhibit minimal counterexamples showing that neither hypothesis of Theorem 5.1 may be dropped, and that the *sharpness* of $2$-transitivity in Theorem 7.3 is essential.

### 8.1 Hiding is necessary

**Construction 8.1 (Leaking protocol).** Take $I = \{0,1\}$, $A = \mathbb{Z}/2$, and a single (trivial) value for each of $R_c$, $R_v$, $P$. Let the proof string be $\mathrm{proof}(i) = 0$ for $i = 0$ and $1$ for $i = 1$; let $Q(r) = \{0\}$ (so $q = 1$); and let the "commitment" be the identity, $\mathrm{com}(u, \rho) = u$, with trivial opening data.

**Proposition 8.2.** For Construction 8.1:

1. The opened coordinate is perfectly simulated by the simulator writing $0$ everywhere. (Both real and simulated views on $Q = \{0\}$ are the constant partial assignment $0 \mapsto 0$.)
2. Unopened coordinates are **not** hidden: the strings $\mathrm{proof}$ and the all-zero string agree on $\{0\}$, so hiding would provide a bijection making their commitments equal; but the commitments are the strings themselves and they differ at coordinate $1$.
3. Perfect honest-verifier zero knowledge fails maximally: the honest transcript occurs with probability $1$ in the real interaction and probability $0$ in the simulation.

The instructive point is (1) together with (3): the leak is **invisible in the opened view**. Simulation of the local view says nothing about what the commitment might be spilling; the composition theorem is genuinely a statement about the commitment as well as about the query pattern.

### 8.2 Simulation is necessary

**Construction 8.3 (Padded protocol with a wrong simulator).** Take $I = \{0\}$, $A = \mathbb{Z}/2$, the one-time-pad commitment (so $R_c = (I \to \mathbb{Z}/2)$ has two elements), proof string constantly $0$, query set $Q(r) = \{0\}$, and the simulator that outputs the constant string $1$.

**Proposition 8.4.** For Construction 8.3: hiding holds (Theorem 6.1), but simulation fails — the real opened view is $0 \mapsto 0$ with probability $1$, the simulated view is $0 \mapsto 1$ with probability $1$ — and perfect honest-verifier zero knowledge fails: the transcript arising from the zero pad occurs with probability $1/2$ in the real interaction and probability $0$ in the simulation.

Both failures occur at query complexity one, the least possible for a non-trivial protocol.

### 8.3 Transitivity is not enough: cyclic rerandomization provably leaks

In Theorem 7.5 the prover rerandomizes by the *full* symmetric group on the palette. Replace it by the cyclic subgroup of colour shifts $c \mapsto c + d$, $d \in \mathbb{Z}/3$ — still transitive on colours. Zero knowledge is destroyed, and not merely for a bad choice of simulator.

**Theorem 8.5 (No simulator for shift rerandomization).** Consider the two-vertex, one-edge instance $V = \{0,1\}$, $Q = \{0,1\}$, with shift rerandomization $\mathrm{proof}(d) = c + d$ and the one-time-pad commitment. Let $c_A = (0,1)$ and $c_B = (0,2)$, both proper. Then for **no** finite non-empty simulator randomness space $S$ and **no** map $\mathrm{sim} : R_v \times S \to (V \to \mathbb{Z}/3)$ does $\mathrm{sim}$ perfectly simulate the opened coordinates of both $\mathcal{P}_{c_A}$ and $\mathcal{P}_{c_B}$.

*Proof.* Consider the opened view $t$ assigning colour $0$ to vertex $0$ and colour $1$ to vertex $1$.

For $c_A = (0,1)$: the shifted colouring is $(d, 1+d)$, which equals $(0,1)$ precisely for $d = 0$. Hence $N_{\mathrm{real}}^{A}(t) = 1$ out of $|P| = 3$.

For $c_B = (0,2)$: the shifted colouring is $(d, 2+d)$, which equals $(0,1)$ only if $d = 0$ and $2 = 1$ in $\mathbb{Z}/3$, impossible. Hence $N_{\mathrm{real}}^{B}(t) = 0$.

If $\mathrm{sim}$ simulated both, Definition 3.4 would give
$$1 \cdot |S| = N_{\mathrm{sim}}(t)\cdot 3 \quad\text{and}\quad 0\cdot |S| = N_{\mathrm{sim}}(t)\cdot 3,$$
with the *same* $N_{\mathrm{sim}}(t)$ (the simulator does not see the colouring, and the query pattern is identical in the two protocols). The second equation forces $N_{\mathrm{sim}}(t) = 0$, whence the first forces $|S| = 0$, contradicting non-emptiness. $\square$

Intuitively, a shift preserves the colour *difference* along the challenged edge, so the opened pair reveals $c(e_2) - c(e_1)$, a genuine function of the witness. Sharp $2$-transitivity is exactly the property that kills every such invariant.

---

## 9. Algorithmic content

Although the results are structural, each carries a concrete algorithm.

**A. Transcript-distribution comparator.** Given a finite committed local-oracle protocol and a simulator, enumerate $P \times R_c \times R_v$ and $S \times R_c \times R_v$, tally transcripts, and compare the two rational distributions. Complexity $O\bigl((|P| + |S|)\,|R_c|\,|R_v|\cdot \kappa\bigr)$, where $\kappa$ is the cost of evaluating a transcript. This is the direct empirical test of Theorem 5.1 and the counterexamples of Section 8.

**B. Fibre-count profiler.** For fixed $(T, c, o)$ compute $\mathrm{fib}(u,T,c,o)$ for all $u$ and verify that it is constant on the classes of the relation "agrees on $T$". Complexity $O(|A|^{|I|}\,|R_c|)$ in the naive form; for the one-time pad, $\mathrm{fib}(u,T,c,o) \in \{0,1\}$ and is computed in $O(|I|)$. This tests Lemma 4.2 and pinpoints hiding failures.

**C. Local-view marginal checker.** For each $r$, tabulate $N_{\mathrm{real}}(r,\cdot)$ and $N_{\mathrm{sim}}(r,\cdot)$ and verify the cross-multiplied identity of Definition 3.4. Complexity $O\bigl((|P| + |S|)\cdot q\bigr)$ per verifier coin — cheap, because only $q$ symbols matter. This is where locality pays off computationally as well as conceptually.

**D. Sharp-transitivity certifier.** Given an alphabet $A$, a subgroup $G \le \mathrm{Sym}(A)$ and a constraint (a set of admissible ordered tuples), build the bipartite incidence between $G$ and admissible tuples and test whether every tuple has exactly one (transitive: at least one; sharply transitive: exactly one) preimage. For $|A| = 3$, $|G| = 6$ this is a $6\times 6$ permanent-free check. This certifies the simulation resource in Theorem 7.5 and refutes it for the cyclic subgroup.

---

## 10. Discussion, applications and future directions

### 10.1 What the factorization buys

The value of Theorem 5.1 is modularity. Designing a perfectly zero-knowledge committed local-oracle protocol reduces to two independent engineering tasks:

* choose a commitment whose randomness space admits the re-labelling bijection of Definition 3.2 — the one-time pad does, and so does any scheme whose commitment-and-opening map is equivariant under a group acting freely on the unopened coordinates;
* choose a rerandomization of the proof string making the $q$-symbol local view uniform on the admissible configurations.

Neither task needs to know anything about the other. In particular, the second task is purely about the alphabet's symmetry group and the constraint predicate — a finite group-theoretic question independent of the size of the instance.

### 10.2 Relation to standard treatments

The classical argument for the $3$-colouring protocol is usually presented as a single monolithic simulation. Our decomposition identifies precisely which step uses which resource, and yields two dividends: the *exactness* of the composition (no hybrid argument, no statistical slack), and the *tightness* results of Section 8, which show that the decomposition is not an artifact.

### 10.3 Future directions

*Derived from the analysis of committed local-oracle protocols developed above.*

**What this work established.** Perfect honest-verifier zero knowledge of the compiled protocol factorizes exactly into two orthogonal resources: hiding of the unopened coordinates (a bijection on commitment randomness) and perfect simulability of the opened coordinates (an equality of fibre cardinalities). The proof is a fibrewise counting argument over the restriction map $u \mapsto u|_{Q(r)}$; constant query complexity is what makes the fibre of opened views small. For $3$-colouring the second resource is exactly the sharp $2$-transitivity of the symmetric group on three letters, and mere transitivity (the cyclic subgroup) is provably insufficient.

**1. Locality-graded leakage: a $q$-query protocol leaks at most a $q$-local functional.** The key insight is that the fibrewise decomposition
$$\mathrm{count}(\tau) = \bigl|\{p : \mathrm{proof}(p)|_{Q} = t\}\bigr|\cdot \mathrm{fib}(t)$$
never mentions the coordinates outside $Q$, so any leakage must be a function of the $q$-marginal of the proof distribution — a *graded* statement interpolating between perfect zero knowledge ($q$-marginal witness-independent) and total leakage ($q = |I|$). Why now? The counting lemma already isolates the marginal; turning it into a quantitative statistical-distance bound needs only an $\ell^1$ version of the integral composition identity.

**2. Group-theoretic characterization of alphabet rerandomization.** The key insight is that the simulation argument for $3$-colouring used nothing about colourings except that a group $G \le \mathrm{Sym}(A)$ acts sharply transitively on the set of admissible opened views; conversely the cyclic counterexample shows that failure of that hypothesis kills simulation. Why now? Both halves are established here for $A = \mathbb{Z}/3$, $q = 2$; the general conjecture is that a $q$-query constraint proof system over alphabet $A$ with prover rerandomization by $G$ is perfect honest-verifier zero knowledge **iff** $G$ is transitive on each constraint's satisfying-assignment set — an exact biconditional, provable with the same fibre machinery.

**3. Zero knowledge is preserved by parallel repetition, exactly.** The key insight is that the product of two committed local-oracle protocols has transcript counts equal to the product of the counts, so the counting proof composes without any hybrid argument or slack. Why now? Exact parallel repetition for *soundness* is already available in product form; pairing it with the transcript-count product would give an exact parallel-repetition theorem for zero knowledge as well.

### 10.4 Limitations

The framework is finite and information-theoretic. Perfect hiding in the sense of Definition 3.2 is incompatible with perfect binding, so the compiled protocols here are *arguments* in any computational instantiation; the theorem should be read as isolating the information-theoretic core, with computational hiding replacing the bijection by an indistinguishability assumption and perfect equality by a negligible statistical distance. Second, only the *honest*-verifier case is addressed: a malicious verifier who chooses $Q$ adaptively after seeing the commitment is outside the model, though the standard coin-fixing transformations apply. Third, the simulator here commits and opens honestly, which is the natural form for this compiler but is stronger than the general definition allows.

---

## 11. Conclusion

Zero knowledge for the "local verifier plus commitment" compiler is not one argument but two, meeting at right angles. Hiding governs the vertical direction — the commitment randomness — and guarantees that the number of coin sequences consistent with an observed (commitment, opening) pair depends on the message only through its opened part. Simulation governs the horizontal direction — the prover's own randomness — and guarantees that the opened part is itself witness-independent. Locality is what makes the horizontal direction small enough for the second guarantee to be achievable at all.

When both hold, they multiply, and the arithmetic is exact: real and simulated transcript distributions are equal, every event has the same probability under both, and every distinguisher, however powerful, has advantage exactly zero. For graph $3$-colouring the horizontal resource is the sharp $2$-transitivity of the symmetric group on three letters — a fact about six permutations and six ordered pairs — and we have shown both that this suffices and that weakening it to mere transitivity provably fails.
