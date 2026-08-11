# Zero-Knowledge Proofs of Provability: Privacy, Extraction, and the Exact Boundaries of Conviction in Affine Σ-Protocols

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We develop, in full rigour and in an information-theoretic (unbounded-adversary) model, the theory of a three-move commitment protocol over abelian groups and apply it to the question of *zero-knowledge theorem proving*: convincing a verifier that a theorem is provable in a fixed formal system, without transmitting any information about which proof one holds.

The protocol is the affine Σ-protocol attached to a homomorphism $f : G \to H$ of abelian groups and a target $T \in H$; a witness is a solution of $f(w) = T$. We prove four groups of results.

**(i) Privacy is exact and quantitative.** The honest prover's view and the simulator's output coincide as multisets (perfect zero knowledge), and more sharply, for *every* statement — true or false, with or without a witness — and every challenge, the set of accepting transcripts is *exactly* the range of the simulator, hence has cardinality exactly $|G|$. The verifier's view carries exactly $\log_2|G|$ bits, all drawn from the prover's tape.

**(ii) The folklore explanation of privacy is false.** The witness set of a statement is exactly a coset of $\ker f$, so it is a singleton precisely when $f$ is injective. We show that perfect zero knowledge persists verbatim in the unique-witness case: privacy arises from translation symmetry of the tape group, not from ambiguity of the witness.

**(iii) Conviction is exponential and structurally rigid.** A prover committed in advance and holding no witness can answer at most *one* of the $2^n$ challenge vectors of the $n$-fold parallel repetition, whereas a witness-holding prover answers all $2^n$; there is nothing in between. Compiled to a formal proof system through a faithful encoding, this yields: identical views for all proofs of the same theorem, simulability of the common view, and certified provability from any double answer — with soundness error $2^{-n}$ for unprovable theorems.

**(iv) Two sharp negative results.** First, the *Fiat–Shamir inversion*: in the information-theoretic model, a forgery-free hash exists for a statement if and only if the statement is **false**; if the statement is true, *every* hash admits an accepted non-interactive proof. Interaction is therefore not removable without a computational assumption. Second, *compiler vacuity*: with $f = 0$ every group element is a witness, so all conviction the protocol transfers is conviction the encoding already assumed.

We further show that the whole theory lifts to $\mathbb{F}_q$-linear statements with soundness $q^{-n}$ and extraction by the linear solve $w = (c-c')^{-1}(z-z')$, that the Boolean protocol is the case $q=2$, and that OR-composition hides *which* of two theorems the prover can prove while certifying the disjunction. Explicit finite instances over $\mathbb{Z}/12$ and $\mathbb{F}_5$ certify non-vacuity of every hypothesis.

**Keywords:** Σ-protocol, zero knowledge, special soundness, provability, Fiat–Shamir, parallel repetition, OR-composition, abelian group homomorphism.

---

## 1. Introduction

### 1.1 The question

A zero-knowledge proof lets a prover convince a verifier that a statement is true without revealing *why*. The classical instances concern arithmetic secrets: a discrete logarithm, a graph colouring, a Hamiltonian cycle. This paper takes the idea to its natural reflexive limit and asks about *mathematics itself*: can one convince a verifier that a theorem $T$ is provable in a fixed formal system, without leaking anything about the proof?

The question is not idle. A referee wants assurance that a submitted argument closes; an author may wish to establish priority without publishing; a computational agent may wish to certify that a search terminated successfully without exposing the certificate. In each case, "I hold a proof" and "here is the proof" are very different transmissions, and the gap between them is exactly the subject of zero knowledge.

### 1.2 What is actually true, and what is folklore

The engineering literature is full of statements that are true in a computational model and false in an information-theoretic one, and of intuitive explanations of privacy that turn out to be non-explanations. This paper is deliberately structured to separate the three:

* **What the protocol really gives.** Exact simulability, exact view cardinality, exact soundness error.
* **What is folklore and false.** That privacy requires witness ambiguity (§5); that hashing away the interaction preserves soundness (§7).
* **What the protocol cannot give.** Any mathematical content not already installed by the encoding (§6.4).

### 1.3 Model

Throughout, the adversary is computationally unbounded. Every distributional claim is a claim of *equality of multisets over a finite index set*, not of computational indistinguishability. Every soundness claim is a claim about the cardinality of a set of challenges, not about a success probability under a hardness assumption. This is the strongest possible setting for positive results and the harshest for negative ones — which is why the Fiat–Shamir inversion of §7 is stated as a limitation of the *model*, not as a criticism of practical deployments.

### 1.4 Contributions and organisation

§2 fixes the protocol and states completeness, special soundness and perfect zero knowledge. §3 analyses the geometry of the verifier's view and proves the view-size theorem. §4 determines the witness set as a kernel coset. §5 refutes the witness-ambiguity folklore. §6 introduces the provability compiler and proves the transfer theorems and their boundaries. §7 proves the Fiat–Shamir inversion. §8 lifts everything to $\mathbb{F}_q$-linear statements. §9 gives OR-composition. §10 gives fully explicit finite instances. §11 discusses applications, limitations and open problems.

---

## 2. The affine Σ-protocol

### 2.1 Definitions

**Definition 2.1 (Statement).** Let $G$ and $H$ be abelian groups. A *statement* is a pair $s = (f, T)$ where $f : G \to H$ is a group homomorphism and $T \in H$. We read $s$ as the assertion $\exists w \in G,\ f(w) = T$.

**Definition 2.2 (Witness).** An element $w \in G$ is a *witness* for $s = (f,T)$ if $f(w) = T$. We write $W(s) = \{w \in G : f(w) = T\}$. The statement is *true* if $W(s) \neq \varnothing$ and *false* otherwise.

**Definition 2.3 (Challenge selector).** For a bit $c \in \{0,1\}$ and $x$ in an abelian group, put
$$\chi(c, x) = \begin{cases} 0 & c = 0,\\ x & c = 1.\end{cases}$$
(Over an $\mathbb{F}_2$-vector space this is exactly $c \cdot x$; see Theorem 8.7.)

**Definition 2.4 (Transcript, acceptance).** A *transcript* is a triple $t = (a, c, z) \in H \times \{0,1\} \times G$, called the commitment, the challenge and the response. The verifier *accepts* $t$ for the statement $s = (f,T)$ if
$$f(z) = a + \chi(c, T). \tag{V}$$

**Definition 2.5 (Honest prover and simulator).** For a witness $w$, a tape $r \in G$ and a challenge $c$, the *honest transcript* is
$$\mathrm{Real}_s(w, r, c) = \bigl(f(r),\; c,\; r + \chi(c, w)\bigr).$$
For a response $z \in G$ and challenge $c$, the *simulated transcript* is
$$\mathrm{Sim}_s(z, c) = \bigl(f(z) - \chi(c, T),\; c,\; z\bigr).$$

The interactive protocol is: prover samples $r$ uniformly and sends $f(r)$; verifier samples $c$ uniformly and sends it; prover sends $r + \chi(c,w)$; verifier checks (V).

### 2.2 The three basic properties

**Theorem 2.6 (Completeness).** If $f(w) = T$ then $\mathrm{Real}_s(w,r,c)$ is accepted, for every tape $r$ and challenge $c$.

*Proof.* For $c = 0$ the claim is $f(r) = f(r) + 0$. For $c = 1$ it is $f(r + w) = f(r) + T$, which holds since $f(r+w) = f(r) + f(w) = f(r) + T$. $\square$

**Theorem 2.7 (Simulator validity).** $\mathrm{Sim}_s(z,c)$ is accepted for every $z$ and $c$, with no hypothesis on $s$ whatsoever.

*Proof.* The verification equation reads $f(z) = (f(z) - \chi(c,T)) + \chi(c,T)$. $\square$

Theorem 2.7 already contains the seed of every negative result in this paper: acceptance of a *single* transcript is a triviality available to anyone, true statement or not. All conviction must therefore come from answering *several* challenges.

**Theorem 2.8 (Special soundness / extraction).** Let $a \in H$ and suppose $(a, 0, z_0)$ and $(a, 1, z_1)$ are both accepted for $s = (f,T)$. Then $z_1 - z_0$ is a witness for $s$.

*Proof.* Acceptance gives $f(z_0) = a$ and $f(z_1) = a + T$. Subtracting and using additivity, $f(z_1 - z_0) = f(z_1) - f(z_0) = T$. $\square$

**Theorem 2.9 (Perfect zero knowledge).** Let $G$ be finite, $w$ a witness for $s$, and $c$ a challenge. Then, as multisets indexed by $G$,
$$\bigl\{\!\!\bigl\{\, \mathrm{Real}_s(w,r,c) \;:\; r \in G \,\bigr\}\!\!\bigr\} \;=\; \bigl\{\!\!\bigl\{\, \mathrm{Sim}_s(z,c) \;:\; z \in G \,\bigr\}\!\!\bigr\}.$$

*Proof.* The translation $\tau : r \mapsto r + \chi(c,w)$ is a bijection of $G$, with inverse $z \mapsto z - \chi(c,w)$. It suffices to show $\mathrm{Real}_s(w,r,c) = \mathrm{Sim}_s(\tau(r), c)$ pointwise, since re-indexing a multiset along a bijection does not change it. The challenge and response components agree by definition. For the commitment, we must check $f(r + \chi(c,w)) - \chi(c,T) = f(r)$, which for $c=0$ reads $f(r) - 0 = f(r)$ and for $c=1$ reads $f(r) + f(w) - T = f(r)$, true since $f(w) = T$. $\square$

**Corollary 2.10 (Witness indistinguishability).** If $w_1, w_2$ are both witnesses for $s$, the multisets of honest transcripts they generate coincide for each challenge. Consequently the verifier's view is a function of the public statement alone.

*Proof.* Both equal the simulator's multiset by Theorem 2.9. $\square$

---

## 3. Geometry and entropy of the verifier's view

Theorem 2.9 compares two distributions. The results of this section are sharper: they identify the *set* on which the view is supported, intrinsically, with no reference to a witness.

**Theorem 3.1 (Injectivity of the two generators).** For fixed $s, w, c$, the map $r \mapsto \mathrm{Real}_s(w,r,c)$ is injective; for fixed $s, c$, the map $z \mapsto \mathrm{Sim}_s(z,c)$ is injective.

*Proof.* In the first case, equal transcripts have equal responses, so $r_1 + \chi(c,w) = r_2 + \chi(c,w)$, and cancellation in $G$ gives $r_1 = r_2$. In the second, the response *is* $z$. $\square$

**Corollary 3.2 (Uniformity).** Every transcript occurs at most once in the honest execution: the verifier's view is the uniform distribution on its support.

**Theorem 3.3 (Support characterisation).** Let $w$ be a witness for $s$ and $c$ a challenge. A transcript $t$ lies in the support of the honest execution if and only if $t$ has challenge $c$ and is accepted:
$$\{\mathrm{Real}_s(w,r,c) : r \in G\} = \{t : t.\mathrm{challenge} = c \ \wedge\ t \text{ accepted}\}.$$

*Proof.* ($\subseteq$) is Theorem 2.6. For ($\supseteq$), let $t = (a, c, z)$ be accepted, and set $r := z - \chi(c,w)$. Then $r + \chi(c,w) = z$, and $f(r) = a$: for $c = 0$ this is the verification equation directly; for $c=1$, $f(z - w) = f(z) - f(w) = (a + T) - T = a$. Hence $t = \mathrm{Real}_s(w,r,c)$. $\square$

The next theorem strengthens this by *deleting the hypothesis that a witness exists*.

**Theorem 3.4 (Geometry of acceptance).** For every statement $s = (f,T)$ — true or false — and every challenge $c$,
$$\{t : t.\mathrm{challenge} = c \ \wedge\ t \text{ accepted}\} \;=\; \{\mathrm{Sim}_s(z,c) : z \in G\}.$$

*Proof.* ($\supseteq$) is Theorem 2.7. For ($\subseteq$), let $t = (a,c,z)$ be accepted. The verification equation gives $a = f(z) - \chi(c,T)$, so $t = \mathrm{Sim}_s(z,c)$ literally. $\square$

Theorem 3.4 is the structural heart of the privacy analysis: the accepting set is *derived from the verification equation alone*. The designer has no freedom here; the affine form of (V) forces the answer.

**Theorem 3.5 (View size).** Let $G$ be finite. For every statement $s$ and every challenge $c$,
$$\bigl|\{t : t.\mathrm{challenge}=c \ \wedge\ t \text{ accepted}\}\bigr| = |G|.$$
Equivalently, the verifier's view is uniform on a set of exactly $|G|$ elements and carries exactly $\log_2|G|$ bits of Shannon entropy.

*Proof.* By Theorem 3.4 the set is the image of $G$ under $z \mapsto \mathrm{Sim}_s(z,c)$, which is injective by Theorem 3.1; hence its cardinality is $|G|$. Uniformity is Corollary 3.2, and the entropy of the uniform distribution on $N$ points is $\log_2 N$. $\square$

**Corollary 3.6 (Challenge-independence).** The two accepting sets, for $c = 0$ and $c = 1$, have the same cardinality $|G|$. The challenge bit reveals nothing about the statement.

The interpretive weight of Theorem 3.5 is considerable. The *quantity* of information the verifier receives is a constant of the group, independent of the target, of the truth of the statement, and of the witness. Every bit of the view originates in the prover's random tape; none originates in the secret. Privacy is therefore not a matter of degree, and it cannot be tuned — improved or degraded — by any choice a protocol designer can make within this affine framework.

---

## 4. The witness set is a kernel coset

**Lemma 4.1.** If $w_1, w_2$ are witnesses for $s = (f,T)$ then $w_1 - w_2 \in \ker f$.

*Proof.* $f(w_1 - w_2) = f(w_1) - f(w_2) = T - T = 0$. $\square$

**Theorem 4.2 (Coset structure).** If $w_0$ is a witness for $s$, then $W(s) = w_0 + \ker f$.

*Proof.* If $w$ is a witness, $w = w_0 + (w - w_0)$ with $w - w_0 \in \ker f$ by Lemma 4.1. Conversely, if $k \in \ker f$ then $f(w_0 + k) = f(w_0) + f(k) = T + 0 = T$. $\square$

**Corollary 4.3 (Witness count).** If $s$ is true then $|W(s)| = |\ker f|$.

*Proof.* Translation by $w_0$ is a bijection $\ker f \to W(s)$. $\square$

**Corollary 4.4 (Extraction resolution).** Special soundness determines the witness only modulo $\ker f$. The extracted element $z_1 - z_0$ lies in $W(s)$, and any element of $W(s)$ differs from it by a kernel element.

Corollary 4.4 is the precise statement of what an extractor can and cannot achieve. It also sets up the refutation of the next section: it is tempting to conclude that $|\ker f|$ *measures* privacy, with $\ker f = 0$ meaning no privacy at all.

---

## 5. Privacy does not come from witness ambiguity

**Theorem 5.1 (Unique witness).** If $f$ is injective and $s$ is true, then $|W(s)| = 1$.

*Proof.* Injectivity of a group homomorphism is equivalent to $\ker f = 0$; apply Corollary 4.3. $\square$

**Theorem 5.2 (Perfect zero knowledge with a unique witness).** Let $G$ be finite, $f$ injective, and $w$ the (unique) witness of $s$. Then for each challenge $c$ the honest view and the simulated view are equal as multisets:
$$\bigl\{\!\!\bigl\{\mathrm{Real}_s(w,r,c) : r \in G\bigr\}\!\!\bigr\} = \bigl\{\!\!\bigl\{\mathrm{Sim}_s(z,c) : z \in G\bigr\}\!\!\bigr\},$$
and simultaneously $|W(s)| = 1$.

*Proof.* Combine Theorem 5.1 with Theorem 2.9; the proof of the latter used only that $\tau : r \mapsto r + \chi(c,w)$ is a bijection of $G$ and that $f(w) = T$, neither of which is affected by injectivity. $\square$

**Discussion.** A widespread informal account holds that a Σ-protocol hides the witness because many witnesses are consistent with the public statement, so the verifier cannot tell which one the prover used. Theorem 5.2 refutes this in the sharpest possible form: in the unique-witness case there is *nothing to be ambiguous about*, and yet the view is still exactly the simulator's — a simulator that has never seen the witness. The operative mechanism is the transitive action of $G$ on itself by translation. Ambiguity of the witness (Corollary 4.4) governs the resolution of *extraction*; symmetry of the tape space governs *privacy*. Conflating the two is a category error, even though both are indexed by the same subgroup $\ker f$ in the sense of the conjecture in §11.3.

---

## 6. Amplification and the provability compiler

### 6.1 Parallel repetition

**Definition 6.1 (Committed parallel prover).** For $n \ge 1$, a *committed prover* is a pair $P = (a, \rho)$ where $a : \{1,\dots,n\} \to H$ is a vector of commitments fixed in advance and $\rho : \{0,1\}^n \to G^n$ is an arbitrary response function. The parallel verifier accepts the challenge vector $c \in \{0,1\}^n$ if every round accepts:
$$\forall i,\quad f(\rho(c)_i) = a_i + \chi(c_i, T).$$
The *cheat set* $\mathrm{Ch}(P) \subseteq \{0,1\}^n$ is the set of accepted challenge vectors.

Note that $\rho$ may depend on the *whole* challenge vector — the model grants the adversary full adaptivity across rounds — and is subject to no computational restriction.

**Theorem 6.2 (Rigidity).** If $s$ is false, then $|\mathrm{Ch}(P)| \le 1$ for every committed prover $P$.

*Proof.* Suppose $c, c' \in \mathrm{Ch}(P)$ with $c \ne c'$; pick $i$ with $c_i \ne c'_i$. Then at the single commitment $a_i$ the prover has produced accepting responses for both challenge values, so Theorem 2.8 yields a witness for $s$ — contradicting falsity. Hence $\mathrm{Ch}(P)$ has at most one element. $\square$

**Theorem 6.3 (Soundness error).** If $s$ is false then for every committed prover,
$$\frac{|\mathrm{Ch}(P)|}{|\{0,1\}^n|} \;\le\; \left(\tfrac12\right)^{n}.$$

*Proof.* $|\{0,1\}^n| = 2^n$ and $|\mathrm{Ch}(P)| \le 1$ by Theorem 6.2. $\square$

**Definition 6.4 (Honest parallel prover).** Given a witness $w$ and tapes $r \in G^n$, put $a_i = f(r_i)$ and $\rho(c)_i = r_i + \chi(c_i, w)$.

**Theorem 6.5 (Full completeness).** For an honest parallel prover with witness $w$, $\mathrm{Ch}(P) = \{0,1\}^n$; the prover answers all $2^n$ challenge vectors.

*Proof.* Round-wise application of Theorem 2.6. $\square$

**Theorem 6.6 (Amplified dichotomy).** For every committed prover $P$, either $|\mathrm{Ch}(P)| \le 1$, or $s$ has a witness $w$ and the honest prover built from $w$ satisfies $|\mathrm{Ch}| = 2^n$ for every choice of tapes. There is no intermediate regime.

*Proof.* Case on whether $W(s) = \varnothing$; apply Theorem 6.2 in one case and Theorem 6.5 in the other. $\square$

### 6.2 Compiling a formal system

**Definition 6.7 (Provability compilation).** Let $\mathsf{Thm}$ be a set of theorem statements, $\mathsf{Prf}$ a set of candidate proof objects, and $\mathrm{Chk} \subseteq \mathsf{Thm} \times \mathsf{Prf}$ a checking relation. A *provability compilation* of $T_0 \in \mathsf{Thm}$ consists of

* a public statement $s = (f, \mathrm{target})$ over $(G, H)$,
* an encoding $E : \mathsf{Prf} \to G$,

satisfying two faithfulness axioms:

1. **(soundness of the encoding)** $\mathrm{Chk}(T_0, p) \implies f(E(p)) = \mathrm{target}$;
2. **(completeness of the encoding)** $f(w) = \mathrm{target}$ for some $w \in G$ $\implies$ $\exists p,\ \mathrm{Chk}(T_0, p)$.

**Theorem 6.8 (Provability equivalence).** For a provability compilation of $T_0$: $T_0$ is provable (i.e. $\exists p,\ \mathrm{Chk}(T_0,p)$) if and only if $s$ is true.

*Proof.* Forward: axiom 1 applied to a checking proof produces a witness. Backward: axiom 2 verbatim. $\square$

### 6.3 Transfer theorems

**Theorem 6.9 (Conviction).** Suppose a prover exhibits a commitment $a$ and responses $z_0, z_1$ such that $(a,0,z_0)$ and $(a,1,z_1)$ are both accepted for the compiled statement. Then $T_0$ is provable in the underlying formal system.

*Proof.* Theorem 2.8 yields a witness $z_1 - z_0$ for $s$; axiom 2 converts it into a checking proof. $\square$

Note what Theorem 6.9 does *not* say. The extracted object is a group element, not a proof. The verifier learns the *existence* of a proof, mediated entirely by the faithfulness of the encoding.

**Theorem 6.10 (Nothing is revealed).** For any checking proof $p$ of $T_0$ and any challenge $c$, the honest view generated from $E(p)$ equals the simulator's output multiset.

*Proof.* $E(p)$ is a witness by axiom 1; apply Theorem 2.9. $\square$

**Theorem 6.11 (Zero-knowledge provability transfer).** Let $G$ be finite and fix a provability compilation of $T_0$. Then:

1. for any two checking proofs $p_1, p_2$ of $T_0$ and any challenge $c$, the honest views generated from $E(p_1)$ and $E(p_2)$ are equal as multisets;
2. that common view equals the simulator's output, which is computed from the public statement alone;
3. any double answer at one commitment certifies that $T_0$ is provable.

*Proof.* (2) is Theorem 6.10; (1) follows by applying (2) to $p_1$ and to $p_2$; (3) is Theorem 6.9. $\square$

**Theorem 6.12 (Unprovability is exponentially hard to fake).** If $T_0$ is not provable, then for every $n$ and every committed prover, the fraction of answerable challenge vectors is at most $2^{-n}$.

*Proof.* By Theorem 6.8, non-provability makes $s$ false; apply Theorem 6.3. $\square$

**Theorem 6.13 (No double answer for unprovable theorems).** If $T_0$ is unprovable, there exist no $a, z_0, z_1$ with both $(a,0,z_0)$ and $(a,1,z_1)$ accepted.

*Proof.* Such data would certify provability by Theorem 6.9. $\square$

Theorem 6.13 refines the soundness statement qualitatively: the extraction event does not "occur and extract garbage"; it simply never occurs.

**Theorem 6.14 (Provability gap synthesis).** Fix a provability compilation of $T_0$, a round count $n$, and a challenge $c$. Then all three of the following hold simultaneously.

* If $T_0$ is unprovable, every committed prover has $|\mathrm{Ch}(P)| / 2^n \le 2^{-n}$.
* If $p$ is a checking proof of $T_0$, then the honest prover built from $E(p)$ answers all $2^n$ challenge vectors for every choice of tapes, and its view equals the simulator's output.
* Regardless of provability, the set of accepting transcripts with challenge $c$ has exactly $|G|$ elements.

*Proof.* The three clauses are Theorem 6.12, Theorems 6.5 and 6.10, and Theorem 3.5 respectively. $\square$

This is the paper's summary statement. It exhibits an exponential separation between the provable and unprovable cases in the *dynamics* of the protocol, alongside an exact identity in the *statics* of the view.

### 6.4 A boundary: compiler vacuity

**Theorem 6.15 (Vacuity of the zero compilation).** Take $f = 0 : G \to H$ and target $0$, with any encoding $E$ and any theorem $T_0$ possessing at least one checking proof. Then every $w \in G$ is a witness, the axioms of Definition 6.7 hold trivially, extraction always succeeds, and the protocol certifies nothing beyond what the encoding already assumed.

*Proof.* $f(w) = 0 = \mathrm{target}$ for all $w$, so $W(s) = G$; axiom 1 is immediate and axiom 2 is discharged by the assumed checking proof. $\square$

Theorem 6.15 is not a defect of the protocol but a delimitation of its scope. The protocol transports the assertion "the compiled statement is true" with perfect privacy and error $2^{-n}$. That this assertion *means* "$T_0$ is provable" is exactly the content of Definition 6.7's axioms, which are ordinary mathematical assertions about the encoding and must be established outside the protocol. **Cryptography cannot manufacture mathematical content**; it can only move existing content while hiding its shape.

---

## 7. The Fiat–Shamir inversion

In deployment, interaction is expensive. The Fiat–Shamir transform replaces the verifier's coin by a hash of the commitment.

**Definition 7.1.** Let $\mathrm{Hash} : H \to \{0,1\}$ be arbitrary. The pair $(a, z) \in H \times G$ is a *non-interactive proof* for $s$ if the transcript $(a, \mathrm{Hash}(a), z)$ is accepted:
$$f(z) = a + \chi(\mathrm{Hash}(a), T).$$
$\mathrm{Hash}$ is *forgery-free* for $s$ if no non-interactive proof exists.

**Theorem 7.2 (Fixed-point description).** A non-interactive proof for $s$ under $\mathrm{Hash}$ exists if and only if
$$\exists z \in G,\ \exists c \in \{0,1\} : \ \mathrm{Hash}\bigl(f(z) - \chi(c,T)\bigr) = c.$$

*Proof.* ($\Rightarrow$) Given $(a,z)$ accepted, put $c = \mathrm{Hash}(a)$; the verification equation gives $a = f(z) - \chi(c,T)$, so $\mathrm{Hash}(f(z)-\chi(c,T)) = c$. ($\Leftarrow$) Given $z$ and $c$ with that fixed-point property, put $a := f(z) - \chi(c,T)$; then $\mathrm{Hash}(a) = c$ and $a + \chi(c,T) = f(z)$, so $(a,z)$ is accepted. $\square$

So a non-interactive proof is exactly a fixed point of the "hash the simulated commitment" map — and the simulated commitments range over the whole of $\{f(z) : z\} \cup \{f(z) - T : z\}$ regardless of the truth of $s$.

**Theorem 7.3 (Rigidity of forgery-freeness).** $\mathrm{Hash}$ is forgery-free for $s = (f,T)$ if and only if
$$\forall z \in G:\ \mathrm{Hash}(f(z)) = 1 \quad\text{and}\quad \forall z \in G:\ \mathrm{Hash}(f(z) - T) = 0.$$

*Proof.* By Theorem 7.2, forgery-freeness says: for all $z$ and all $c$, $\mathrm{Hash}(f(z) - \chi(c,T)) \ne c$. Taking $c = 0$ gives $\mathrm{Hash}(f(z)) \ne 0$, i.e. $= 1$; taking $c = 1$ gives $\mathrm{Hash}(f(z) - T) \ne 1$, i.e. $= 0$. Conversely those two conditions negate both instances of the fixed-point condition. $\square$

**Theorem 7.4 (Every hash is forgeable on true statements).** If $s$ has a witness $w$, then for *every* $\mathrm{Hash}$ there exists an accepted non-interactive proof.

*Proof.* Consider $\mathrm{Hash}(0)$. If $\mathrm{Hash}(0) = 0$, take $z = 0$, $c = 0$: then $f(z) - \chi(0,T) = 0$ and $\mathrm{Hash}(0) = 0 = c$, so Theorem 7.2 applies. If $\mathrm{Hash}(0) = 1$, take $z = w$, $c = 1$: then $f(w) - T = 0$ and $\mathrm{Hash}(0) = 1 = c$. Either way a fixed point exists. $\square$

The mechanism is transparent: a true statement forces the image of $f$ and its translate by $-T$ to *intersect* (both contain $0$ after translation by the witness), and the two requirements of Theorem 7.3 then contradict each other at the intersection point.

**Theorem 7.5 (Existence of a forgery-free hash on false statements).** If $s$ has no witness, the *image colouring*
$$\mathrm{Hash}^\ast(a) := \begin{cases} 1 & \text{if } a \in \operatorname{im} f,\\ 0 & \text{otherwise},\end{cases}$$
is forgery-free.

*Proof.* The first condition of Theorem 7.3 is immediate. For the second, suppose $f(z) - T \in \operatorname{im} f$, say $f(z) - T = f(y)$. Then $f(z - y) = T$, so $z - y$ is a witness, contradicting falsity. Hence $\mathrm{Hash}^\ast(f(z) - T) = 0$ for all $z$. $\square$

**Theorem 7.6 (Fiat–Shamir inversion).** For any statement $s$: a forgery-free hash exists **iff** $s$ is false.

*Proof.* ($\Rightarrow$) Theorem 7.4 contrapositive. ($\Leftarrow$) Theorem 7.5. $\square$

**Theorem 7.7 (Necessity of interaction).** For every statement $s$ and every $n$:

* if $s$ is false, every committed prover in the $n$-round interactive protocol answers at most a $2^{-n}$ fraction of challenge vectors;
* if $s$ is true, every hash function whatsoever admits an accepted non-interactive proof.

*Proof.* Theorem 6.3 and Theorem 7.4. $\square$

**Discussion.** Theorem 7.6 says that in the information-theoretic model, unconditional non-interactive soundness holds precisely when the statement one wishes to prove is *untrue* — the exact opposite of what a proof system requires. Practical Fiat–Shamir is not thereby refuted: its security is a *computational* statement (typically in the random-oracle model), asserting that although forgeries exist in abundance, none can be *found* in feasible time. Theorem 7.6 delimits what any such argument must be: it cannot be information-theoretic, and it cannot be improved by cleverness in the choice of hash. The verifier's coin is load-bearing, and removing it converts an unconditional guarantee into a conditional one.

---

## 8. Large challenge spaces: $\mathbb{F}_q$-linear statements

Nothing in §2 required the challenge to be a bit. Let $q$ be prime and work over the field $\mathbb{F}_q = \mathbb{Z}/q$.

**Definition 8.1.** A *linear statement* over $\mathbb{F}_q$-vector spaces $V, W$ is a pair $s = (f, T)$ with $f : V \to W$ linear and $T \in W$; a witness is $w$ with $f(w) = T$. A transcript is $(a, c, z) \in W \times \mathbb{F}_q \times V$, accepted iff
$$f(z) = a + c\,T.$$
The honest transcript is $\mathrm{Real}_s(w,r,c) = (f(r),\,c,\,r + c w)$ and the simulated one is $\mathrm{Sim}_s(z,c) = (f(z) - cT,\,c,\,z)$.

**Theorem 8.2 (Simulator validity).** $\mathrm{Sim}_s(z,c)$ is always accepted.

*Proof.* $f(z) = (f(z) - cT) + cT$. $\square$

**Theorem 8.3 (Perfect zero knowledge).** For finite $V$, a witness $w$ and any $c \in \mathbb{F}_q$, the honest and simulated views coincide as multisets.

*Proof.* The map $r \mapsto r + cw$ is a bijection of $V$ (inverse $z \mapsto z - cw$), and $\mathrm{Real}_s(w,r,c) = \mathrm{Sim}_s(r+cw, c)$: the commitment component requires $f(r + cw) - cT = f(r)$, which holds since $f(r+cw) = f(r) + c f(w) = f(r) + cT$. Re-index along the bijection. $\square$

**Theorem 8.4 (Linear special soundness).** Let $a \in W$ and let $c \ne c'$ in $\mathbb{F}_q$. If $(a,c,z)$ and $(a,c',z')$ are both accepted, then
$$w := (c - c')^{-1}(z - z')$$
is a witness.

*Proof.* Subtracting the two verification equations gives $f(z - z') = (c - c')T$. Since $c \neq c'$ and $\mathbb{F}_q$ is a field, $c - c'$ is invertible, and $f\bigl((c-c')^{-1}(z-z')\bigr) = (c-c')^{-1}(c-c')T = T$. $\square$

The Boolean extractor of Theorem 2.8 is the case $c=1, c'=0$.

**Theorem 8.5 (Rigidity and soundness error).** If $s$ has no witness, a committed prover in the $n$-fold parallel repetition with challenges in $\mathbb{F}_q^n$ answers at most one challenge vector; since there are $q^n$ of them, the accepting fraction is at most $q^{-n}$.

*Proof.* As in Theorem 6.2, two distinct accepted vectors differ in some coordinate, and Theorem 8.4 extracts a witness there. The count $|\mathbb{F}_q^n| = q^n$ is standard. $\square$

**Theorem 8.6 (Dichotomy).** For every committed prover, either its cheat set is a single vector, or a witness exists and the honest prover answers all $q^n$ challenge vectors.

**Theorem 8.7 (The Boolean protocol is the case $q = 2$).** Over an $\mathbb{F}_2$-vector space, the Boolean challenge selector coincides with scalar multiplication: $\chi(c, w) = \bar{c}\, w$ where $\bar c \in \mathbb{F}_2$ is the image of the bit $c$.

*Proof.* Check the two cases: $\chi(0,w) = 0 = 0\cdot w$ and $\chi(1,w) = w = 1\cdot w$. $\square$

Thus the theory of §§2–6 is the base of a one-parameter family, with per-round soundness $1/q$ improving as the field grows, at the cost of a challenge of $\log_2 q$ bits rather than one. Since the view size is $|V|$ regardless, larger $q$ buys soundness for free in the information-theoretic model.

---

## 9. OR-composition: hiding which theorem

Given two statements $s_1, s_2$ over the same groups, one can prove "$s_1$ or $s_2$ is true" while hiding which disjunct one can prove. The classical trick: run both protocols, with sub-challenges constrained to XOR to the verifier's challenge, and *simulate* the branch for which no witness is held.

**Definition 9.1.** An *OR-transcript* is a tuple $(a_1, a_2, c_1, c_2, z_1, z_2)$. It is accepted for the challenge $c$ if
$$c_1 \oplus c_2 = c, \quad (a_1,c_1,z_1) \text{ accepted for } s_1, \quad (a_2,c_2,z_2) \text{ accepted for } s_2.$$

**Definition 9.2 (The two strategies).** Randomness is a triple $(r, z, d) \in G \times G \times \{0,1\}$.

* **Left strategy** (prover knows a witness $w_1$ for $s_1$): output
$$\bigl(f_1(r),\; f_2(z) - \chi(d, T_2),\; c \oplus d,\; d,\; r + \chi(c \oplus d, w_1),\; z\bigr).$$
* **Right strategy** (prover knows a witness $w_2$ for $s_2$): output
$$\bigl(f_1(z) - \chi(d, T_1),\; f_2(r),\; d,\; c \oplus d,\; z,\; r + \chi(c\oplus d, w_2)\bigr).$$

**Theorem 9.3 (Completeness of both strategies).** If $w_1$ is a witness for $s_1$, the left strategy's output is accepted for every $c$ and every randomness; symmetrically for the right strategy.

*Proof.* The XOR constraint holds by construction. The honest branch is accepted by Theorem 2.6; the simulated branch by Theorem 2.7. $\square$

**Theorem 9.4 (Which-theorem hiding).** Let $G$ be finite and suppose $w_1$ is a witness for $s_1$ and $w_2$ a witness for $s_2$. Then for every challenge $c$, the left strategy and the right strategy generate *exactly the same multiset* of OR-transcripts as the randomness ranges over $G \times G \times \{0,1\}$.

*Proof.* Define the reparametrisation
$$\sigma(r, z, d) := \bigl(z - \chi(d, w_2),\; r + \chi(c \oplus d, w_1),\; c \oplus d\bigr).$$
It is a bijection of $G \times G \times \{0,1\}$: its inverse is $\sigma'(r,z,e) = (z - \chi(e,w_1),\ r + \chi(c\oplus e, w_2),\ c\oplus e)$, as one checks by composing (the bit component is an involution $d \mapsto c \oplus d$; the group components are translations composed with the swap). A direct computation, using $f_1(w_1) = T_1$ and $f_2(w_2) = T_2$, shows that the left strategy at $(r,z,d)$ equals the right strategy at $\sigma(r,z,d)$, componentwise. Re-indexing a multiset along a bijection leaves it unchanged. $\square$

**Theorem 9.5 (Disjunctive soundness).** Suppose two OR-transcripts $t, t'$ are accepted for challenges $c \ne c'$ and share both commitments, $a_1 = a'_1$ and $a_2 = a'_2$. Then $s_1$ or $s_2$ has a witness.

*Proof.* Since $c_1 \oplus c_2 = c \ne c' = c'_1 \oplus c'_2$, the sub-challenges cannot agree in both coordinates: $c_1 \ne c'_1$ or $c_2 \ne c'_2$. In the first case, the two transcripts supply accepting responses at the shared commitment $a_1$ for both values of the sub-challenge, and Theorem 2.8 extracts a witness for $s_1$; the second case is symmetric. $\square$

**Theorem 9.6 (OR-provability transfer).** Let $T_1, T_2$ be compiled by provability compilations $C_1, C_2$ over the same groups, with checking proofs $p_1$ of $T_1$ and $p_2$ of $T_2$. Then

1. two accepted OR-conversations with the same commitments and different challenges certify that at least one of $T_1, T_2$ is provable; and
2. for each challenge, the view generated by the prover who uses the proof of $T_1$ equals the view generated by the prover who uses the proof of $T_2$.

*Proof.* (1) Theorem 9.5 plus the completeness axiom of Definition 6.7 in the relevant branch. (2) Theorem 9.4 with $w_i = E_i(p_i)$, which are witnesses by the soundness axiom. $\square$

Conviction about the disjunction is transferred; the identity of the provable disjunct is not.

---

## 10. Fully explicit instances

Abstract theorems are worth little if their hypotheses are unsatisfiable. The following finite instances are completely explicit.

### 10.1 The Boolean protocol over $\mathbb{Z}/12$

Let $G = H = \mathbb{Z}/12$ and $f(x) = 4x$, a group homomorphism.

* **A true statement:** $s^{+} = (f, 8)$, i.e. "$4w = 8$ is solvable". Witnesses: $w \in \{2,5,8,11\}$, so $|W(s^+)| = 4$.
* **Kernel:** $\ker f = \{0,3,6,9\}$, of size $4$ — confirming Corollary 4.3 numerically.
* **A false statement:** $s^{-} = (f, 1)$. Since $\operatorname{im} f = \{0,4,8\}$ and $1 \notin \operatorname{im} f$, no witness exists.
* **Concrete extraction:** at commitment $a = 4r$, the responses $z_0 = r$ and $z_1 = r+2$ are both accepted (for $s^+$), and $z_1 - z_0 = 2$, a genuine witness.
* **Concrete soundness:** over $n = 10$ rounds, any committed prover answers at most a $1/1024$ fraction of the $1024$ challenge vectors for $s^-$.
* **Concrete zero knowledge:** the witnesses $2$ and $5$ generate identical transcript multisets for either challenge.
* **Concrete view size:** for either challenge, both $s^+$ and $s^-$ admit exactly $12$ accepting transcripts — the count is blind to truth, as Theorem 3.5 predicts.

### 10.2 The linear protocol over $\mathbb{F}_5$

Let $V = W = \mathbb{F}_5$.

* **True statement:** $f = \mathrm{id}$, $T = 3$; witness $w = 3$, unique since $\ker(\mathrm{id}) = 0$. This is a live instance of Theorem 5.2: a unique witness with perfect zero knowledge.
* **False statement:** $f = 0$, $T = 1$; no witness, since $0 \ne 1$ in $\mathbb{F}_5$.
* **Concrete extraction:** at challenges $c = 1$ and $c' = 4$, the honest responses are $z = r + 3$ and $z' = r + 12 = r+2$; the linear solve returns $(1-4)^{-1}(z - z') = (-3)^{-1}\cdot 1 = 2^{-1} = 3$, the witness.
* **Concrete soundness:** over $n = 4$ rounds with $q=5$, a committed prover answers at most a $1/625$ fraction of the $625$ challenge vectors for the false statement.

---

## 11. Discussion, applications and open problems

### 11.1 What the theory delivers

Summarising Theorem 6.14: for a faithfully compiled theorem, the interactive protocol transmits **exactly one bit** — "the theorem is provable" — to within error $2^{-n}$ (or $q^{-n}$ in the linear version), while the verifier's entire view is a uniform sample from a set of size $|G|$ that is *the same set* whether the theorem is provable or not. This is as clean a separation between *conviction* and *disclosure* as one could ask for.

Applications suggested by the framework, with appropriate caution about the model:

* **Priority without publication.** An author can establish that a proof exists before disclosing it, in a way that is verifiable by a sceptical community — modulo the encoding.
* **Referee-side assurance.** A checking pipeline can certify closure of an argument without exposing a proprietary certificate.
* **Delegation and audit.** A search agent can prove that a search succeeded without revealing the found object, provided the object is encodable as a witness of a public linear condition.
* **Composable claims.** OR-composition (Theorem 9.6) supports assertions of the form "at least one of these is provable" — a natural fit for disjunctive audit claims.

### 11.2 What it does not deliver

Three limitations deserve emphasis, all of them proved above rather than merely observed.

1. **The encoding is the load-bearing assumption** (Theorem 6.15). The zero compilation satisfies every axiom and certifies nothing.
2. **Interaction cannot be removed for free** (Theorem 7.6). Non-interactive soundness in this model holds exactly when the statement is false.
3. **Privacy is not measured by witness count** (Theorem 5.2). Designers who reason about privacy by counting witnesses are measuring the wrong invariant.

### 11.3 Conjectures

**Conjecture 1 (Entropy rigidity).** For any three-move protocol over a finite abelian group whose verification predicate is affine in the response, the Shannon entropy of the verifier's view equals $\log_2|G|$ exactly, with no slack; and perfect zero knowledge holds if and only if the accepting set is a torsor under the tape group. The evidence is Theorem 3.4, which derives the accepting set from the verification equation alone: entropy is *forced* by the affine form and cannot be tuned by the designer. Only the passage from cardinalities to entropies remains.

**Conjecture 2 (Knowledge error equals the kernel index).** For a linear map $f : V \to W$ over $\mathbb{F}_q$, the probabilistic extractor of the $n$-round protocol has knowledge error exactly $q^{-n}$ and recovers the witness precisely modulo $\ker f$; the privacy margin and the knowledge error are two readings of the same subgroup index. The evidence is Corollary 4.3, identifying the witness set with a coset of $\ker f$ — so that all extraction ambiguity is kernel ambiguity — together with the soundness bound of Theorem 8.5.

### 11.4 Further directions

* **Entropy formulation.** Upgrade Theorem 3.5 from cardinalities to Shannon entropies and prove Conjecture 1.
* **Beyond affine verification.** Characterise the verification predicates for which the analogue of Theorem 3.4 holds. Affinity in the response is clearly sufficient; is some weaker "torsor" condition necessary?
* **Non-abelian and module-theoretic generalisations.** The proofs use only that translation is a bijection and that $f$ is additive. Which parts survive for non-abelian $G$, or for $R$-modules over non-fields (where $c - c'$ need not be invertible and Theorem 8.4 must be replaced by a divisibility argument)?
* **Genuine proof-system encodings.** Construct explicit faithful compilations of concrete proof calculi, so that Definition 6.7's axioms become theorems about a real checker rather than hypotheses.
* **Computational bridge.** Identify the minimal computational assumption under which Theorem 7.6 is circumvented, making explicit which unconditional guarantee is being traded away.

---

## 12. Conclusion

The affine Σ-protocol supports an unusually complete information-theoretic analysis. Its privacy is exact and its source is identified: the translation symmetry of the tape group, not the ambiguity of the secret. Its soundness is not merely small but *rigid*: a committed prover without a witness answers at most one challenge vector out of $2^n$ — or $q^n$ — with the honest prover answering all of them, and no behaviour in between. Its conviction transfers to statements about formal provability, giving a precise sense in which one can convince a sceptic that a theorem has a proof while transmitting no information about which proof one holds.

The negative results are equally precise, and they are the reason to trust the positive ones. Removing the interaction destroys unconditional soundness, in the strongest possible sense: a hash function is forgery-free exactly when the statement is false. And a degenerate encoding renders the whole apparatus vacuous. Together these mark the boundary of the subject: the protocol is a perfect courier of conviction, and never a source of it.
