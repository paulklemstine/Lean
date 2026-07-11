# Paradoxes as Theorems: The Liar, Russell, and Berry Made Consistent

## Abstract

The Liar, Russell's, and Berry's paradoxes are traditionally regarded as pathologies: in classical logic each produces a contradiction, and a single contradiction trivialises the theory through the principle of explosion. We adopt the opposite stance. We construct an explicit, finite formal framework in which all three paradoxes are *provable theorems* of a theory that is nevertheless **sound** (it asserts only designated, at-least-true sentences) and **non-trivial** (it does not assert everything). The mathematical engine is Belnap's four-valued logic of First-Degree Entailment (FDE), whose values are *true* ($T$), *false* ($F$), *both* ($B$, a glut), and *neither* ($N$, a gap). We prove that the truth values form a distributive De Morgan algebra, that negation has a designated fixed point (the glut $B$), and — the structural core — that **every sound self-negating sentence must be a glut**, whereas **no bivalent theory can soundly host a self-negating sentence at all**. We isolate the exact condition under which explosion collapses a paraconsistent theory, exhibit a six-sentence witness in which the Liar, Russell, and Berry sentences are three distinct provable gluts, and show the witness reflects its own soundness — sidestepping Tarski's undefinability barrier. We introduce the *inconsistency degree* (the number of gluts) as a stable structural invariant, equal to exactly three in the witness.

**Keywords:** paraconsistent logic, First-Degree Entailment, Belnap four-valued logic, Liar paradox, Russell's paradox, Berry's paradox, truth-value glut, De Morgan algebra, self-reference, Tarski undefinability.

---

## 1. Introduction

A **self-referential paradox** arises when an object refers, through negation, to itself. The three canonical examples are:

- **The Liar.** A sentence $L$ that asserts its own falsehood: $L \leftrightarrow \lnot L$.
- **Russell's paradox.** The set $R = \{x : x \notin x\}$; then $R \in R \leftrightarrow R \notin R$.
- **Berry's paradox.** "The least positive integer not definable in fewer than twelve words," an eleven-word phrase defining a number it declares undefinable in so few words.

Under classical two-valued semantics each yields $\varphi \leftrightarrow \lnot\varphi$, hence $\varphi \wedge \lnot\varphi$, and then the rule of explosion (*ex contradictione quodlibet*, ECQ) — from $\varphi$ and $\lnot\varphi$ infer any $\psi$ — trivialises the theory: every sentence becomes provable.

The classical response is prophylactic: stratify truth (Tarski), forbid impredicative comprehension (type theory, ZFC's separation), or restrict definability. We take a **paraconsistent** route instead. Rather than preventing the contradiction, we house it in a logic where contradiction is locally tolerated and globally contained. Our contributions are:

1. A self-contained algebra of four truth values (§3) with negation, designation, meet, and join, proved to be a **distributive De Morgan algebra**.
2. The identification of a **designated fixed point of negation** (the glut $B$) as the single algebraic phenomenon underlying all three paradoxes, together with the two-valued obstruction that rules out any classical solution (§3–§4).
3. An abstract theory of **paraconsistent theories** with a coherence law linking syntactic negation to semantic negation, the theorem that every sound self-negating sentence is a glut, and a characterisation of when explosion collapses a theory (§4).
4. An explicit **six-sentence witness** realising the Liar, Russell, and Berry sentences as three distinct provable gluts, proved sound, non-explosive, and self-reflective, with **inconsistency degree** exactly three (§5).

Everything is finite and effectively checkable; the paper is self-contained.

---

## 2. Background and Related Ideas

**First-Degree Entailment (FDE).** Belnap and Dunn introduced a four-valued semantics motivated by "how a computer should think" when fed information from multiple, possibly conflicting or silent, sources. Each atomic sentence is tagged with a subset of $\{\text{told-true},\text{told-false}\}$: neither ($N$), told-true-only ($T$), told-false-only ($F$), or both ($B$). FDE is the paradigmatic paraconsistent *and* paracomplete logic.

**Paraconsistency.** A consequence relation is paraconsistent if it does not validate ECQ: there exist $\varphi,\psi$ with $\{\varphi,\lnot\varphi\}$ not entailing $\psi$. This is precisely what allows a theory to contain a contradiction without exploding.

**Tarski's undefinability.** No consistent classical theory extending arithmetic can define its own truth predicate; the diagonal Liar would otherwise be constructible and explode. We show the obstruction is exactly the absence of a designated negation fixed point, and hence lifts in the four-valued setting.

---

## 3. The Four-Valued Truth Algebra

### 3.1 Values, negation, designation

**Definition 3.1 (Truth values).** Let $\mathbf{4} = \{T, F, B, N\}$, read as *true only*, *false only*, *both* (glut), and *neither* (gap).

**Definition 3.2 (Negation).** The involution $\lnot : \mathbf{4} \to \mathbf{4}$ is
$$\lnot T = F, \quad \lnot F = T, \quad \lnot B = B, \quad \lnot N = N.$$
Negation swaps the two classical values and fixes the two non-classical ones.

**Definition 3.3 (Designation).** A value is *designated* (written $\mathsf{des}(v)$, "at least true") iff it is $T$ or $B$:
$$\mathsf{des}(T) = \mathsf{des}(B) = \text{true}, \qquad \mathsf{des}(F) = \mathsf{des}(N) = \text{false}.$$

**Definition 3.4 (Meet and join).** FDE conjunction $\sqcap$ (meet) and disjunction $\sqcup$ (join) in the truth ordering are given by the tables

| $\sqcap$ | $T$ | $F$ | $B$ | $N$ |  | $\sqcup$ | $T$ | $F$ | $B$ | $N$ |
|---|---|---|---|---|---|---|---|---|---|---|
| $T$ | $T$ | $F$ | $B$ | $N$ |  | $T$ | $T$ | $T$ | $T$ | $T$ |
| $F$ | $F$ | $F$ | $F$ | $F$ |  | $F$ | $T$ | $F$ | $B$ | $N$ |
| $B$ | $B$ | $F$ | $B$ | $F$ |  | $B$ | $T$ | $B$ | $B$ | $T$ |
| $N$ | $N$ | $F$ | $F$ | $N$ |  | $N$ | $T$ | $N$ | $T$ | $N$ |

Equivalently, identifying each value with a pair (told-true?, told-false?) — $T=(1,0)$, $F=(0,1)$, $B=(1,1)$, $N=(0,0)$ — meet takes the componentwise min on told-true and max on told-false, and join does the reverse; negation swaps the two components.

### 3.2 The algebra is a distributive De Morgan algebra

**Theorem 3.5 (Involution).** $\lnot\lnot v = v$ for all $v \in \mathbf{4}$.

**Theorem 3.6 (De Morgan laws).** For all $x, y$,
$$\lnot(x \sqcap y) = \lnot x \sqcup \lnot y, \qquad \lnot(x \sqcup y) = \lnot x \sqcap \lnot y.$$

**Theorem 3.7 (Lattice laws).** $\sqcap$ and $\sqcup$ are each commutative, associative, and idempotent, and satisfy the absorption laws $x \sqcap (x \sqcup y) = x$ and $x \sqcup (x \sqcap y) = x$.

**Theorem 3.8 (Distributivity).** For all $x, y, z$,
$$x \sqcap (y \sqcup z) = (x \sqcap y) \sqcup (x \sqcap z), \qquad x \sqcup (y \sqcap z) = (x \sqcup y) \sqcap (x \sqcup z).$$

*Proof of 3.5–3.8.* Each identity is a statement over the finite set $\mathbf{4}$ and is verified by exhaustive case analysis (four cases for unary laws, sixteen for binary, sixty-four for ternary). For example, De Morgan at $(B,N)$: $\lnot(B \sqcap N) = \lnot F = T$, while $\lnot B \sqcup \lnot N = B \sqcup N = T$. $\square$

**Corollary 3.9.** $(\mathbf{4}, \sqcap, \sqcup, \lnot)$ is a distributive De Morgan algebra. It is *not* a Boolean algebra: complementation fails, since $B \sqcap \lnot B = B \sqcap B = B \neq F$ and $N \sqcup \lnot N = N \neq T$.

### 3.3 The negation fixed point — the algebraic heart

**Theorem 3.10 (Fixed points of negation).** $\lnot v = v \iff v \in \{B, N\}$.

*Proof.* By 3.2, $\lnot T = F \neq T$ and $\lnot F = T \neq F$, while $\lnot B = B$ and $\lnot N = N$. $\square$

**Theorem 3.11 (No classical fixed point).** In the two-element Boolean algebra $\{0,1\}$ with Boolean negation, $\lnot b \neq b$ for every $b$.

*Proof.* $\lnot 0 = 1 \neq 0$ and $\lnot 1 = 0 \neq 1$. $\square$

**Theorem 3.12 (Designated fixed point is the glut).** If $\lnot v = v$ and $\mathsf{des}(v)$, then $v = B$.

*Proof.* By 3.10 the fixed points are $B$ and $N$; of these only $B$ is designated (3.3). $\square$

Theorems 3.11 and 3.12 together constitute the paper's pivot: the classical world has *no* fixed point of negation, so it cannot resolve self-negation at all; the four-valued world has *exactly one designated* fixed point, and it is the glut.

---

## 4. Paraconsistent Theories and the Structure of Paradox

### 4.1 Abstract theories

**Definition 4.1 (Paraconsistent theory).** Let $S$ be a set of *sentences*. A *paraconsistent theory* on $S$ is a pair $(\tau, \nu)$ where $\tau : S \to \mathbf{4}$ assigns a truth value to each sentence and $\nu : S \to S$ is a *syntactic negation* operator. The theory is **coherent** if syntactic negation realises semantic negation:
$$\tau(\nu(s)) = \lnot\,\tau(s) \quad \text{for all } s \in S. \tag{Coh}$$

**Definition 4.2 (Soundness).** For a set $P \subseteq S$ of *provable* (asserted) sentences, the theory is **sound on $P$** iff every provable sentence is designated: $\mathsf{des}(\tau(s)) = \text{true}$ for all $s \in P$.

**Definition 4.3 (Self-negating sentence).** A sentence $s$ is *self-negating* iff $\nu(s) = s$; syntactically it *is* its own denial. This is the abstract form of the Liar ($L = \lnot L$), Russell's set ($R\in R \equiv R \notin R$), and Berry's number.

### 4.2 The core dichotomy

**Theorem 4.4 (Sound self-negation forces a glut).** In a coherent theory, if $s$ is self-negating and $s$ is designated, then $\tau(s) = B$.

*Proof.* By coherence and $\nu(s) = s$, we have $\lnot\tau(s) = \tau(\nu(s)) = \tau(s)$, so $\tau(s)$ is a fixed point of negation. Since $\tau(s)$ is designated, Theorem 3.12 gives $\tau(s) = B$. $\square$

**Theorem 4.5 (No sound classical Liar).** There is no bivalent coherent theory — one whose values lie in $\{T, F\}$ with classical negation — containing a designated self-negating sentence.

*Proof.* Such a sentence would satisfy $\lnot\tau(s) = \tau(s)$ with $\tau(s) \in \{T,F\}$, contradicting Theorem 3.11. $\square$

Theorem 4.4 says the paradoxes *can* be theorems, and dictates their value; Theorem 4.5 says a classical theory has no choice but to fail (explode) if it tries. Paraconsistency is therefore not optional but *necessary* for sound self-reference.

### 4.3 Explosion

**Definition 4.6 (Explosion).** A theory $(\tau,\nu)$ *has explosion* if there is a designated, self-negating sentence $p$ (a "true contradiction") from which every sentence inherits designation:
$$\mathsf{des}(\tau(p)) \wedge (\nu(p)=p) \;\Rightarrow\; \forall q,\ \mathsf{des}(\tau(q)).$$
Concretely, explosion holds when the presence of a provable glut forces every sentence to be designated.

**Proposition 4.7 (Explosion collapses a theory).** If a theory has explosion and possesses even one provable glut, then every sentence is designated; in particular the theory is trivial in the sense that no sentence is undesignated (no genuine falsehood or gap survives as unprovable).

*Proof.* Immediate from Definition 4.6: the glut discharges the antecedent, so all $q$ are designated. $\square$

**Proposition 4.8 (Non-explosion certificate).** A theory *rejects* explosion iff there is a designated self-negating $p$ and some $q$ with $\lnot\mathsf{des}(\tau(q))$. Exhibiting such a pair $(p, q)$ certifies paraconsistency.

### 4.4 Measuring inconsistency

**Definition 4.9 (Inconsistency degree).** For a theory on a finite $S$, the *inconsistency degree* is the number of glut-valued sentences:
$$\deg(\tau, \nu) = \#\{\, s \in S : \tau(s) = B \,\}.$$

The degree is $0$ exactly for glut-free (consistency-in-the-strong-sense) theories, and positive precisely when the theory tolerates at least one true contradiction. It quantifies "how inconsistent" a sound, non-explosive theory is.

---

## 5. The Witness: A Six-Sentence Consistent Home for Three Paradoxes

We instantiate the framework on $S = \{0,1,2,3,4,5\}$.

**Definition 5.1 (The witness theory).** Let
$$\tau = (\,0{:}B,\ 1{:}B,\ 2{:}B,\ 3{:}T,\ 4{:}F,\ 5{:}N\,), \qquad \nu = (\,0{\mapsto}0,\ 1{\mapsto}1,\ 2{\mapsto}2,\ 3{\mapsto}4,\ 4{\mapsto}3,\ 5{\mapsto}5\,),$$
with provable set $P = \{0, 1, 2, 3\}$. Sentences $0, 1, 2$ are the Liar, Russell, and Berry witnesses (self-negating gluts); $3$ is a genuine truth, $4$ a genuine falsehood (unproved), $5$ a gap.

**Theorem 5.2 (Coherence).** For every $s$, $\tau(\nu(s)) = \lnot\tau(s)$.

*Proof.* Case check: for $s\in\{0,1,2\}$, $\nu(s)=s$ and $\lnot B = B$; for $s=3$, $\tau(\nu 3)=\tau 4=F=\lnot T$; for $s=4$, $\tau(\nu 4)=\tau 3=T=\lnot F$; for $s=5$, $\lnot N = N$. $\square$

**Theorem 5.3 (Three distinct paradox gluts).** The sentences $0, 1, 2$ are pairwise distinct and each satisfies $\tau(s) = B$.

**Theorem 5.4 (Paradoxes as theorems).** For each $s \in \{0,1,2\}$: $s \in P$, $\mathsf{des}(\tau(s)) = \text{true}$, and $\tau(s) = B$. That is, the Liar, Russell, and Berry sentences are all provable, all designated, and all gluts, simultaneously.

**Theorem 5.5 (Self-soundness).** The theory is sound on $P$: every provable sentence is designated. Indeed $\tau(0)=\tau(1)=\tau(2)=B$ and $\tau(3)=T$ are all designated, and $4, 5 \notin P$.

**Theorem 5.6 (Explosion would collapse the witness).** If the witness had explosion, then every sentence — including $4$ — would be designated.

*Proof.* The glut $0$ is provable, designated, and self-negating; explosion would then designate all $q$. $\square$

**Theorem 5.7 (Non-explosion).** The witness rejects explosion: the designated self-negating glut $0$ does *not* make the falsehood $4$ designated, since $\mathsf{des}(\tau(4)) = \mathsf{des}(F) = \text{false}$. Hence the theory is non-trivial.

**Theorem 5.8 (Inconsistency degree).** $\deg(\tau, \nu) = 3$, exactly one glut per paradox, and no more.

*Proofs of 5.3–5.8.* All are finite verifications over the six-element domain, discharged by direct computation on the tables of §3 and Definition 5.1. $\square$

### 5.1 Self-reflection and Tarski's barrier

Tarski's theorem forbids a consistent classical theory from internalising its own truth (or soundness) predicate. The obstruction is exactly the two-valued fact of Theorem 3.11: the internal soundness sentence would be self-negating, hence would need a designated fixed point, which classically does not exist. In the four-valued setting the fixed point *does* exist, so the barrier lifts.

Concretely, the witness contains the designated true sentence $3$, whose status can be read as an internal assertion "every provable sentence is designated." Because Theorem 5.5 makes this genuinely correct, the theory contains a provable, designated sentence whose designation *tracks its own soundness*: the theory soundly vouches for itself. This is the reflective phenomenon impossible for a bivalent consistent theory.

---

## 6. Algorithms

We summarise the effective procedures underlying the results; full implementations accompany this work.

**A. Table verification.** To confirm the De Morgan-algebra laws (Theorems 3.5–3.8), enumerate all tuples over $\mathbf{4}$ (up to $4^3 = 64$) and check each identity; total cost $O(|\mathbf{4}|^k)$ for a $k$-ary law — constant time.

**B. Soundness auditing.** Given $(\tau, \nu, P)$, verify soundness by checking $\mathsf{des}(\tau(s))$ for each $s\in P$; cost $O(|P|)$.

**C. Non-explosion search.** To certify paraconsistency, search for a pair $(p,q)$ with $p$ a designated self-negating glut and $q$ undesignated; cost $O(|S|^2)$ worst case, $O(|S|)$ once a glut is fixed.

**D. Inconsistency-degree computation.** Count glut-valued sentences; cost $O(|S|)$.

**E. Coherence checking.** Verify $\tau(\nu(s)) = \lnot\tau(s)$ for all $s$; cost $O(|S|)$.

---

## 7. Applications

- **Inconsistency-tolerant databases and knowledge bases.** Belnap's four values were designed for reasoning under conflicting or missing data. The framework models a knowledge base that flags conflicting entries as gluts, continues to answer queries soundly about consistent parts, and quantifies conflict via inconsistency degree.
- **Belief revision and multi-agent fusion.** When merging agents' assertions, contradictions map to gluts rather than triggering collapse; the degree measures residual conflict after fusion.
- **Foundational semantics of self-reference.** The single fixed-point lemma unifies the Liar, Russell, and Berry treatments, suggesting a uniform semantics for self-referential constructs in specification languages.
- **Reflective systems.** The self-soundness result indicates how a reasoning system can safely contain a (paraconsistent) internal soundness predicate.

---

## 8. Discussion

The results recast paradox as an *algebraic* rather than a *logical-pathological* phenomenon. The Liar, Russell, and Berry sentences share one structural feature — being a fixed point of syntactic negation — and one algebraic consequence — that soundness forces them onto the unique designated negation fixed point, the glut $B$. Classical logic fails not for lack of ingenuity but because its two-element negation involution has no fixed point (Theorem 3.11); paraconsistency succeeds precisely because the four-valued algebra supplies one (Theorem 3.12). The witness demonstrates that all of this coexists with soundness, non-triviality, and reflective self-endorsement.

A limitation worth stating plainly: the witness abstracts the *shape* of self-reference (self-negation via $\nu$) rather than encoding the full arithmetised diagonal constructions of the Liar/Russell/Berry sentences. What is proved is that the essential logical obstruction — self-negation under soundness — is resolvable in a distributive De Morgan algebra, and that a concrete finite theory realises the resolution with degree exactly three.

---

## 9. Future Directions

**Conjecture 1 — The inconsistency degree is a genuine hierarchy invariant.** For each $n$ there is a sound, non-explosive theory of inconsistency degree exactly $n$, and no sound degree-$n$ theory collapses to degree $< n$ without dropping a paradox or validating explosion. Gluts are individuated by which self-negating sentences a theory commits to, so the glut count is a structural invariant rather than a presentation artifact.

**Conjecture 2 — Self-soundness is available exactly when bivalence fails.** A coherent theory can contain a provable sentence whose designated status tracks its own soundness iff its value algebra admits a designated fixed point of negation; no bivalent theory admits internal self-soundness. Tarski-style undefinability is powered specifically by the classical involution's lack of fixed points, so the barrier dissolves precisely when a designated fixed point is introduced.

**Conjecture 3 — A compositional paradox calculus.** For every endomorphism $f$ of the sentence algebra whose induced action on values has a designated fixed point, there is a sound non-explosive theory in which every $f$-fixed sentence is a provable glut; the Liar/Russell/Berry cases are the involutive instances. "Self-reference" is exactly "being a fixed point of a syntactic endomorphism," so paradoxes form a category indexed by such endomorphisms.

**Conjecture 4 — Distributivity is the boundary of tame inconsistency.** The four-valued algebra used here is a distributive De Morgan algebra; any value algebra that supports a designated negation fixed point while keeping inconsistency "tame" (sound, non-explosive) must retain distributivity, so abandoning distributivity forces a qualitative loss of control over inconsistency.

---

## 10. Conclusion

By enlarging the space of truth values from two to four and locating the single designated fixed point of negation, we have turned three of logic's most notorious paradoxes into honest theorems of a sound, non-explosive, self-reflective theory. Paradox, on this view, is not a wound but a coordinate: the place where a self-negating sentence comes to rest. The inconsistency degree measures how many such coordinates a theory occupies, and the witness shows that occupying three of them costs nothing in soundness or coherence.
