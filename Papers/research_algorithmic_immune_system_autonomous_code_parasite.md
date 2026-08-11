# Algorithmic Immune Systems: Containment, Reflexive Undecidability, and an Uncertainty Principle for Code Attestation

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We develop a complete mathematical theory of *algorithmic immune systems*: runtime monitors that must guarantee safety of a program that arbitrarily and adaptively rewrites its own abstract syntax tree. Working in a minimal *parasite calculus* containing exactly the three ingredients that make self-modifying malware possible — a self register that supplies a program with its own source code, invocation of subprograms, and one observable forbidden effect — we establish a sharp and complete picture of what such a monitor can and cannot achieve.

On the negative side we prove a **diagonal identity**: for every harmless detector program $d$, the program that consults $d$ about its own attestation tag and attacks exactly when cleared is malicious if and only if $d$ fails to flag it. From this single identity we derive that no harmless detector is both sound and complete; that every harmless detector admits an explicitly constructible witness on which it errs; that a sound detector misses at least $2^n$ genuinely malicious programs of size at most $|d| + 3n + 5$ for every $n$; that finite ensembles of detectors under any monotone voting rule are defeated *unanimously* by a single program; and that no finite blacklist ever terminates the arms race. We then remove all computational assumptions: extending the calculus with a query primitive to an arbitrary function $O : \mathbb{N} \to \mathbb{N}$, we prove that **no function whatsoever** — computable or not — correctly classifies the behaviour of programs that may query it, while a correct oracle provably *does* exist for programs that do not. Reflexivity, not computational power, is the barrier.

On the positive side we show that a purely *syntactic* monitor succeeds where behavioural analysis cannot. Attestation via a Gödel numbering of syntax trees is collision-free, so tag verification is exactly membership in the sanctioned set; quarantine (accept a sanctioned mutant, else roll back to a trusted baseline) is an idempotent retraction onto that set; and consequently, for **every** unknown, time-dependent, adaptive self-modifying adversary and at **every** time step, the running program is sanctioned, and hence harmless whenever the sanctioned set is. The alarm is complete and rollback immediate.

Finally we quantify the price. Since attestation is syntactic and behaviour is semantic, and since a single semantic equivalence class contains at least $2^n$ programs of size $\le 3n+1$, we obtain the **immune uncertainty principle**
$$2^n \le |S| + \bigl|\,\mathcal{P}_n \setminus S\,\bigr|,$$
where $S$ is the whitelist and $\mathcal{P}_n$ the $n$-bit family of behaviourally trivial variants: *memory plus rigidity is at least exponential*. A monitor can be small or permissive, never both. Complementing this, we show that on any bounded code universe (size $\le N$, literals $< L$) perfect immunity — total containment *and* zero false positives — is attainable, and that every such monitor requires at least $2^{(N-1)/3}$ attestation tags. The impossibility theorems are precisely the $N \to \infty$ limit of this trade-off. We also determine the exact cost of sampled monitoring: continuous verification is necessary and sufficient, and with period $k \ge 2$ an adversary keeps the system compromised for a $(k-1)/k$ fraction of the run.

**Keywords:** self-modifying code, attestation, reflexive undecidability, diagonal argument, quarantine, semantic equivalence class, immune uncertainty principle, monitoring frequency.

---

## 1. Introduction

### 1.1 The problem

A program that modifies its own code is not a curiosity. Just-in-time compilers synthesise machine code at runtime; dynamic loaders splice modules into a running image; autonomous agents patch their own logic; and polymorphic malware regenerates its own body on each infection so that no two instances share a byte. In every case a supervisor is asked to make the same guarantee: *whatever this process turns itself into, it will never perform the forbidden action.*

Two architectural answers dominate practice.

- **Behavioural analysis.** Determine, by static or dynamic examination, what the code will do, and block it if that includes the forbidden action.
- **Structural attestation.** Ignore what the code does. Maintain a whitelist of sanctioned code, fingerprint the running image after each modification, and roll back if the fingerprint is unrecognised. This is the logic of signed binaries, secure boot, and remote attestation.

Folklore holds that the first is "undecidable by Rice's theorem" and the second "works but is inflexible". This paper replaces both slogans with theorems, and in doing so uncovers structure that the slogans miss. In particular:

1. The obstruction to behavioural analysis here is **not** undecidability in the usual sense. In our setting maliciousness is a *decidable* predicate: an external interpreter simply runs the program on its own fingerprint. What fails is the *internal* problem, in which the detector is a citizen of the world it must describe. Accordingly the impossibility survives unlimited computational power (Theorem 5.3).
2. The inflexibility of attestation is not an engineering defect but a *conservation law* with an exact exponential rate (Theorem 7.2), and there is a regime — bounded code universes — in which attestation is provably perfect at a computable exponential cost (Theorems 8.2, 8.3).

### 1.2 Contributions and organisation

Section 2 introduces the parasite calculus and proves that its Gödel numbering is injective, which is the licence for fingerprint-based monitoring. Section 3 gives a total two-layer semantics (value and effect) and proves the positive baseline: on self-reference-free programs, static scanning is sound and complete. Section 4 constructs the diagonal parasite and derives the impossibility results, including quantitative exponential escape. Section 5 removes computational assumptions via the reflexive oracle barrier and locates the exact frontier. Section 6 develops the positive theory: attestation, quarantine, containment, neutralization, alarms and rollback. Section 7 develops the algebra of mutations, semantic equivalence, and the uncertainty principle. Section 8 treats bounded universes: perfect immunity and its exact price. Section 9 treats monitoring frequency. Section 10 gives algorithms, Section 11 applications, Section 12 discussion, Section 13 open problems.

---

## 2. The Parasite Calculus and Structural Attestation

### 2.1 Syntax

**Definition 2.1 (Parasite calculus).** The set $\mathsf{PAst}$ of *program syntax trees* is generated inductively by

- $\mathrm{inp}$ — the **self register**;
- $\mathrm{attack}$ — the single observable **forbidden effect**;
- $\mathrm{lit}\,n$ for $n \in \mathbb{N}$ — constants;
- $\mathrm{ite}(c,a,b)$ — branching;
- $\mathrm{call}(f,a)$ — invocation of the subprogram $f$ on the value computed by $a$.

Three of these are load-bearing. The self register is a genuine quine primitive: the runtime always executes a program on its own attestation tag (Definition 3.4), so a program can read, and branch on, its own source. Invocation lets a parasite run a detector on itself. And $\mathrm{attack}$ is the single bit of observable behaviour we must control; every result below transfers verbatim to any single designated effect.

**Definition 2.2 (Size).** $\operatorname{size}(\mathrm{inp}) = \operatorname{size}(\mathrm{attack}) = \operatorname{size}(\mathrm{lit}\,n) = 1$, $\operatorname{size}(\mathrm{ite}(c,a,b)) = 1 + \operatorname{size}(c) + \operatorname{size}(a) + \operatorname{size}(b)$, and $\operatorname{size}(\mathrm{call}(f,a)) = 1 + \operatorname{size}(f) + \operatorname{size}(a)$.

**Lemma 2.3.** $\operatorname{size}(t) > 0$ for every $t$. *(Immediate induction.)*

### 2.2 Attestation tags

**Definition 2.4 (Attestation tag).** Let $\langle \cdot,\cdot\rangle : \mathbb{N}^2 \to \mathbb{N}$ be the Cantor pairing bijection. Define $\operatorname{code} : \mathsf{PAst} \to \mathbb{N}$ by
$$
\operatorname{code}(\mathrm{inp}) = 0,\quad
\operatorname{code}(\mathrm{attack}) = 1,\quad
\operatorname{code}(\mathrm{lit}\,n) = 5n + 2,
$$
$$
\operatorname{code}(\mathrm{ite}(c,a,b)) = 5\,\bigl\langle \langle \operatorname{code} c, \operatorname{code} a\rangle, \operatorname{code} b\bigr\rangle + 3,
\qquad
\operatorname{code}(\mathrm{call}(f,a)) = 5\,\langle \operatorname{code} f, \operatorname{code} a\rangle + 4 .
$$

The residue mod $5$ records the head constructor; the quotient packs the children.

**Theorem 2.5 (Faithfulness of attestation).** $\operatorname{code}$ is injective; equivalently $\operatorname{code}(s) = \operatorname{code}(t) \iff s = t$.

*Proof sketch.* Induct on $s$ and case on $t$. If the head constructors differ, the tags differ mod $5$ (the values $0$ and $1$ are handled directly, being below $2$). If they agree, cancel the additive constant and the factor $5$, then apply injectivity of pairing to recover equality of the children's tags, and conclude by the induction hypotheses. $\square$

Theorem 2.5 is the whole justification for fingerprint-based monitoring: a tag comparison is *exactly* an AST comparison, with no possibility of a collision, hence no possibility of a forged attestation. Everything positive in Sections 6–8 rests on it.

---

## 3. Semantics, Self-Execution, and the Non-Reflexive Baseline

### 3.1 Values and effects

We give a *total* denotational semantics in two layers. The value layer is standard; the effect layer is the point of interest, because it tracks only *executed* behaviour.

**Definition 3.1 (Value semantics).** $\operatorname{eval} : \mathsf{PAst} \times \mathbb{N} \to \mathbb{N}$ is defined by
$$\operatorname{eval}(\mathrm{inp}, x) = x,\qquad \operatorname{eval}(\mathrm{attack}, x) = 1,\qquad \operatorname{eval}(\mathrm{lit}\,n, x) = n,$$
$$\operatorname{eval}(\mathrm{ite}(c,a,b), x) = \begin{cases}\operatorname{eval}(a,x) & \text{if } \operatorname{eval}(c,x) \ne 0\\ \operatorname{eval}(b,x) & \text{otherwise}\end{cases},
\qquad \operatorname{eval}(\mathrm{call}(f,a),x) = \operatorname{eval}(f, \operatorname{eval}(a,x)).$$

**Definition 3.2 (Effect semantics).** $\operatorname{effect} : \mathsf{PAst} \times \mathbb{N} \to \{\mathrm{true},\mathrm{false}\}$ is defined by
$$\operatorname{effect}(\mathrm{inp},x) = \operatorname{effect}(\mathrm{lit}\,n,x) = \mathrm{false}, \qquad \operatorname{effect}(\mathrm{attack},x) = \mathrm{true},$$
$$\operatorname{effect}(\mathrm{ite}(c,a,b),x) = \operatorname{effect}(c,x) \ \vee\ \begin{cases}\operatorname{effect}(a,x) & \text{if } \operatorname{eval}(c,x)\ne 0\\ \operatorname{effect}(b,x) & \text{otherwise}\end{cases},$$
$$\operatorname{effect}(\mathrm{call}(f,a),x) = \operatorname{effect}(a,x)\ \vee\ \operatorname{effect}(f, \operatorname{eval}(a,x)).$$

The essential clause is branching: only the branch actually selected contributes. **Dead code is genuinely dead.** A program containing $\mathrm{attack}$ inside an unreachable branch is behaviourally harmless, and this is exactly the gap that Sections 4 and 7 exploit — from opposite sides.

### 3.2 Self-execution

**Definition 3.3 (Self-execution and maliciousness).** $\operatorname{run}(t) := \operatorname{effect}(t, \operatorname{code}(t))$. A program $t$ is **malicious** when $\operatorname{run}(t) = \mathrm{true}$.

The runtime always feeds a program its own attestation tag. This is the formal counterpart of the ability of real self-modifying code to inspect its own image, and it is what makes the world reflexive. Note that $\operatorname{run}$ is a total computable function, so maliciousness is a *decidable* predicate — externally. Theorem 4.5 shows the internal problem is nonetheless unsolvable.

### 3.3 The non-reflexive baseline: the immune system wins

**Definition 3.4.** A program is **self-reference free** if $\mathrm{inp}$ does not occur in it.

**Lemma 3.5 (Input-obliviousness).** If $t$ is self-reference free then $\operatorname{eval}(t,x) = \operatorname{eval}(t,y)$ and $\operatorname{effect}(t,x) = \operatorname{effect}(t,y)$ for all $x,y$.

*Proof sketch.* Simultaneous structural induction. The leaves are constant by definition. For $\mathrm{ite}$, the induction hypothesis on the guard shows the same branch is taken at $x$ and $y$, so the branch hypotheses apply. For $\mathrm{call}$, the argument's value is the same at $x$ and $y$, so $f$ is invoked at the same point. $\square$

**Definition 3.6 (Static scanner).** $\operatorname{staticScan}(t) := \operatorname{effect}(t, 0)$: symbolically execute on the neutral input.

**Theorem 3.7 (Perfect detection without quining).** For every self-reference-free $t$, $\operatorname{staticScan}(t) = \mathrm{true} \iff t$ is malicious. Consequently maliciousness restricted to self-reference-free programs is decidable by an explicit linear-time procedure.

*Proof.* By Lemma 3.5, $\operatorname{effect}(t,0) = \operatorname{effect}(t,\operatorname{code} t) = \operatorname{run}(t)$. $\square$

Theorem 3.7 matters because it localises the difficulty exactly. Detection is not intrinsically hard; it becomes hard the moment the analysed program can read itself.

### 3.4 The padding family

**Definition 3.8 (Padding).** For a list of bits $l$ define $\operatorname{pad}([\,]) = \mathrm{lit}\,0$ and $\operatorname{pad}(b :: l) = \mathrm{ite}\bigl(\mathrm{lit}\,0,\ \mathrm{lit}\,[b],\ \operatorname{pad}(l)\bigr)$, where $[b] \in \{0,1\}$.

**Lemma 3.9.** For every bit list $l$ and every $x$: $\operatorname{eval}(\operatorname{pad}(l),x) = 0$ and $\operatorname{effect}(\operatorname{pad}(l),x) = \mathrm{false}$. Moreover $\operatorname{size}(\operatorname{pad}(l)) = 3|l| + 1$ and $\operatorname{pad}$ is injective.

*Proof sketch.* The guard $\mathrm{lit}\,0$ evaluates to $0$, so the else-branch is always taken and the recursion applies; the true-branch is dead. Size and injectivity follow by induction, injectivity because the head bit is recoverable from the true-branch literal and the tail from the else-branch. $\square$

So $\{\operatorname{pad}(l)\}_l$ is an **injective encoding of bit strings into a single semantic equivalence class**. This one object plays two opposite roles: in Section 4 it inflates the space of undetectable attacks, and in Section 7 it inflates the space of falsely rejected benign programs. It is the hinge of the whole theory.

---

## 4. The Diagonal Parasite and Immune Escape

### 4.1 Detectors

**Definition 4.1.** A program $d$ is **pure** (harmless) if $\operatorname{effect}(d,x) = \mathrm{false}$ for all $x$ — the immune system must not itself be a parasite. Detector $d$ **flags** $t$, written $\operatorname{Flags}(d,t)$, when $\operatorname{eval}(d, \operatorname{code} t) \ne 0$. Then $d$ is **sound** if every flagged program is malicious (no false alarms) and **complete** if every malicious program is flagged (no misses).

**Lemma 4.2 (Consultation is free).** If $d$ is pure then $\operatorname{effect}(\mathrm{call}(d,\mathrm{inp}), x) = \mathrm{false}$ for all $x$, and consequently, for all $A, B$,
$$\operatorname{effect}\bigl(\mathrm{ite}(\mathrm{call}(d,\mathrm{inp}), A, B), x\bigr) = \begin{cases}\operatorname{effect}(A,x) & \text{if } \operatorname{eval}(d,x) \ne 0\\ \operatorname{effect}(B,x)&\text{otherwise.}\end{cases}$$

*Proof.* Unfold the clauses for $\mathrm{call}$ and $\mathrm{ite}$ and use purity of $d$. $\square$

### 4.2 The construction

**Definition 4.3 (Diagonal parasite).** For a detector $d$ and a bit list $l$,
$$\operatorname{parasite}(d, l) := \mathrm{ite}\bigl(\mathrm{call}(d,\mathrm{inp}),\ \operatorname{pad}(l),\ \mathrm{attack}\bigr).$$
Its size is $\operatorname{size}(d) + 3|l| + 5$, and $l \mapsto \operatorname{parasite}(d,l)$ is injective.

*Semantics in words:* ask the detector about my own tag; if accused, execute dead code; if cleared, attack.

**Theorem 4.4 (The diagonal identity).** For every pure $d$ and every $l$,
$$\operatorname{parasite}(d,l) \text{ is malicious} \iff \neg\,\operatorname{Flags}\bigl(d, \operatorname{parasite}(d,l)\bigr).$$

*Proof.* Write $p = \operatorname{parasite}(d,l)$. By Definition 3.3, $p$ is malicious iff $\operatorname{effect}(p, \operatorname{code} p) = \mathrm{true}$. By Lemma 4.2 this equals $\operatorname{effect}(\operatorname{pad}(l),\operatorname{code} p)$ if $\operatorname{eval}(d,\operatorname{code} p) \ne 0$, and $\operatorname{effect}(\mathrm{attack},\operatorname{code} p)$ otherwise. By Lemma 3.9 the first is $\mathrm{false}$; the second is $\mathrm{true}$. Since $\operatorname{Flags}(d,p)$ is by definition $\operatorname{eval}(d, \operatorname{code} p) \ne 0$, we are done. $\square$

Every impossibility result of this paper is a corollary of Theorem 4.4.

### 4.3 Consequences

**Theorem 4.5 (No perfect detector).** There is no pure $d$ that is both sound and complete.

*Proof.* Let $p = \operatorname{parasite}(d, [\,])$. If $\operatorname{Flags}(d,p)$, soundness makes $p$ malicious, so Theorem 4.4 gives $\neg\operatorname{Flags}(d,p)$ — contradiction. If $\neg\operatorname{Flags}(d,p)$, Theorem 4.4 makes $p$ malicious, so completeness gives $\operatorname{Flags}(d,p)$ — contradiction. $\square$

**Theorem 4.6 (Detector dilemma).** For every pure $d$ there is an explicitly constructible $p$ with either ($\operatorname{Flags}(d,p)$ and $p$ harmless) or ($\neg\operatorname{Flags}(d,p)$ and $p$ malicious). The construction takes $d$'s source as its only input.

**Theorem 4.7 (Two horns).** Let $d$ be pure. (i) If $d$ is sound then for *every* bit list $l$, $\operatorname{parasite}(d,l)$ is malicious and unflagged. (ii) If $d$ is complete then for every $l$, $\operatorname{parasite}(d,l)$ is harmless and flagged.

*Proof.* (i) If $d$ flagged the parasite, soundness would make it malicious, contradicting Theorem 4.4; hence it is unflagged, hence by Theorem 4.4 malicious. (ii) Dual. $\square$

The second horn deserves emphasis: a complete detector does not merely raise occasional false alarms. It raises false alarms *on the entire exponential family of its own diagonal parasites* — programs that are harmless **precisely because** the detector accused them. The alarm is self-fulfilling and self-defeating at once.

**Theorem 4.8 (Exponential immune escape).** Let $d$ be pure and sound. For every $n$ there is a set of exactly $2^n$ distinct programs, each of size at most $\operatorname{size}(d) + 3n + 5$, each malicious and each unflagged by $d$.

*Proof.* Take $\{\operatorname{parasite}(d, l) : l \in \{0,1\}^n\}$. Cardinality follows from injectivity of $l \mapsto \operatorname{parasite}(d,l)$; the properties from Theorem 4.7(i); the size bound from Definition 4.3. $\square$

**Corollary 4.9 (Infinite escape).** For pure sound $d$, the set of malicious programs that $d$ misses is infinite.

The escape set therefore has *exponential density in program size*: evasion is not a rare accident requiring exotic engineering, but the generic case.

### 4.4 Non-vacuity and the shape of the obstruction

The theorem is not vacuous: pure detectors exist in abundance, and each requirement is separately achievable. The *silent* detector $\mathrm{lit}\,0$ never flags, hence is trivially sound, but misses $\mathrm{attack}$, which is malicious. The *paranoid* detector $\mathrm{lit}\,1$ flags everything, hence is complete, but flags the harmless constant program. Only the conjunction is impossible. Concretely, $\operatorname{parasite}(\mathrm{lit}\,0, [\,])$ genuinely attacks and $\operatorname{parasite}(\mathrm{lit}\,1, [\,])$ genuinely does not — the two horns, instantiated and executable.

**Theorem 4.10 (Internal/external gap).** Maliciousness is decidable as a mathematical predicate — the external interpreter $\operatorname{run}$ decides it — yet no pure program of the calculus decides it.

So the obstruction is **not** a lack of computational power. It is reflexivity: the detector is part of the world it must describe. Section 5 makes this precise by removing computational limits entirely.

**Theorem 4.11 (Immune dichotomy).** Detection of maliciousness is perfectly solvable on self-reference-free code (Theorem 3.7) and unsolvable in general (Theorem 4.5). Self-reference is exactly the frontier.

### 4.5 Ensembles: defence in depth fails

**Definition 4.12.** For a list of detectors $d_1,\dots,d_m$ define their disjunction *inside the calculus*: $\mathrm{Ens}([\,]) = \mathrm{lit}\,0$ and $\mathrm{Ens}(d :: ds) = \mathrm{ite}(d, \mathrm{lit}\,1, \mathrm{Ens}(ds))$.

**Lemma 4.13.** If every $d_i$ is pure then $\mathrm{Ens}(ds)$ is pure; and $\operatorname{Flags}(\mathrm{Ens}(ds), t) \iff \exists i,\ \operatorname{Flags}(d_i,t)$. Consequently if every $d_i$ is sound then $\mathrm{Ens}(ds)$ is sound.

*Proof sketch.* Induction on the list. Purity: consulting a pure guard has no effect and both branches are pure. The flag characterisation is the one-step disjunction $\operatorname{Flags}(\mathrm{ite}(d,\mathrm{lit}\,1,e),t) \iff \operatorname{Flags}(d,t) \vee \operatorname{Flags}(e,t)$, obtained by case-splitting on $\operatorname{eval}(d,\operatorname{code} t)$. $\square$

**Theorem 4.14 (Defence in depth fails).** For any finite ensemble of pure sound detectors there is a single malicious program that *every* member clears. Moreover, for every $n$ there are at least $2^n$ such programs of size at most $\operatorname{size}(\mathrm{Ens}(ds)) + 3n + 5$, and on each of them the number of members that raise an alarm is exactly $0$.

*Proof.* $\mathrm{Ens}(ds)$ is itself pure and sound (Lemma 4.13), so Theorem 4.7(i) supplies parasites of $\mathrm{Ens}(ds)$ that it misses; by the flag characterisation, missing by the ensemble means missing by every member. Cardinality from Theorem 4.8. $\square$

Because the vote is *unanimously* wrong, no aggregation rule — majority, threshold, unanimity, weighted, or any monotone function of the members' verdicts — can rescue the ensemble.

**Theorem 4.15 (The arms race never ends).** For every pure sound $d$ and every finite blacklist $B$ of known parasites, there is a malicious program outside $B$ that $d$ misses.

*Proof.* The escape set is infinite (Corollary 4.9), so it is not contained in the finite $B$. $\square$

---

## 5. The Reflexive Oracle Barrier

The natural objection to Section 4 is that a detector is a *program*, hence computationally limited. We now grant the immune system arbitrary — including hypercomputational — power, and the impossibility persists.

**Definition 5.1 (Reflexive calculus).** $\mathsf{OAst}$ is generated by $\mathrm{inp}$, $\mathrm{attack}$, $\mathrm{lit}\,n$, $\mathrm{ite}(c,a,b)$, and $\mathrm{ask}(a)$: a query to an **arbitrary** function $O : \mathbb{N}\to\mathbb{N}$ on the computed tag. Tags $\operatorname{code}_O$ are defined as in Definition 2.4 with $\operatorname{code}_O(\mathrm{ask}\,a) = 5\operatorname{code}_O(a) + 4$; injectivity holds by the same argument as Theorem 2.5. The semantics $\operatorname{eval}_O$, $\operatorname{effect}_O$ mirror Definitions 3.1–3.2 with $\operatorname{eval}_O(\mathrm{ask}\,a, x) = O(\operatorname{eval}_O(a,x))$ and $\operatorname{effect}_O(\mathrm{ask}\,a,x) = \operatorname{effect}_O(a,x)$: *consulting the immune system is itself harmless*. Maliciousness is $\operatorname{effect}_O(t, \operatorname{code}_O t) = \mathrm{true}$.

**Definition 5.2 (Correct oracle).** $O$ is **correct** if for every $t \in \mathsf{OAst}$, $O(\operatorname{code}_O t) \ne 0$ holds exactly when $t$ is malicious *in the world containing $O$ itself*.

**Theorem 5.3 (Reflexive oracle barrier).** No function $O : \mathbb{N} \to \mathbb{N}$ whatsoever — computable or not, of any complexity or logical strength — is correct.

*Proof.* Let $r := \mathrm{ite}(\mathrm{ask}(\mathrm{inp}), \mathrm{lit}\,0, \mathrm{attack})$. Running $r$ on its own tag, the guard evaluates to $O(\operatorname{code}_O r)$, and consulting is effect-free, so $r$ is malicious iff $O(\operatorname{code}_O r) = 0$. Correctness says $r$ is malicious iff $O(\operatorname{code}_O r) \ne 0$. Both cases are contradictory. $\square$

No cardinality, computability or definability assumption is used: the argument is a fixed-point failure, not a diagonalisation over a countable list.

**Lemma 5.4 (Oracle-independence).** If $t$ contains no $\mathrm{ask}$, then $\operatorname{eval}_O(t,x)$ and $\operatorname{effect}_O(t,x)$ do not depend on $O$; hence neither does maliciousness of $t$.

**Theorem 5.5 (Perfect oracle for non-reflexive code).** There exists $O^\ast$ such that for every $O'$ and every $\mathrm{ask}$-free $t$, $O^\ast(\operatorname{code}_O t) \ne 0 \iff t$ is malicious under $O'$.

*Proof sketch.* Define $O^\ast(n) = 1$ if there exists an $\mathrm{ask}$-free $t$ with $\operatorname{code}_O(t) = n$ that is malicious under the constant-zero oracle, and $O^\ast(n) = 0$ otherwise. This is unrestricted comprehension; no computability is claimed and none is needed. Injectivity of $\operatorname{code}_O$ makes the witness unique, and Lemma 5.4 transfers maliciousness from the constant-zero oracle to $O'$. $\square$

**Theorem 5.6 (Reflexive dichotomy).** A perfect immune oracle exists for programs that never consult it, and none exists once programs may observe it.

The immune system can be omniscient about code that ignores it and is *necessarily* wrong about code that watches it. This is a security-theoretic instance of the liar paradox, and it explains why "just use a stronger analyser" is not a research programme.

---

## 6. Attestation, Quarantine, and Neutralization

We now build the positive theory. The monitor never asks what a program means.

**Definition 6.1 (Attestation monitor).** Fix a finite **sanctioned set** $S \subseteq \mathsf{PAst}$ and a trusted **baseline** $b \in S$. The attestation database is $\operatorname{tags}(S) = \{\operatorname{code}(t) : t \in S\}$, and verification is $\operatorname{verify}_S(t) :\iff \operatorname{code}(t) \in \operatorname{tags}(S)$.

**Theorem 6.2 (Collision-freedom of verification).** $\operatorname{verify}_S(t) \iff t \in S$.

*Proof.* Immediate from Theorem 2.5: a tag in the image comes from a unique program. $\square$

So tag lookup is *exactly* set membership. There is no soundness gap between the fingerprint world and the program world.

**Definition 6.3 (Quarantine).** $Q_{S,b}(t) := t$ if $t \in S$, else $b$.

**Lemma 6.4.** If $b \in S$: (i) $Q_{S,b}(t) \in S$ for all $t$; (ii) $Q_{S,b} \circ Q_{S,b} = Q_{S,b}$; (iii) $Q_{S,b}(t) = t \iff t \in S$. Thus $Q_{S,b}$ is an idempotent retraction of $\mathsf{PAst}$ onto $S$.

**Definition 6.5 (Guarded trace).** Let $\mathrm{adv} : \mathbb{N} \times \mathsf{PAst} \to \mathsf{PAst}$ be an **arbitrary, unknown, time-dependent, adaptive** self-modification. Define
$$T_0 = b, \qquad T_{n+1} = Q_{S,b}\bigl(\mathrm{adv}(n, T_n)\bigr).$$

No restriction whatsoever is placed on $\mathrm{adv}$: it may depend on the entire current program, on the clock, and on the monitor's own definition.

**Theorem 6.6 (Containment).** If $b \in S$ then $T_n \in S$ for every adversary and every $n$.

*Proof.* Induction: $T_0 = b \in S$; $T_{n+1} \in S$ by Lemma 6.4(i). $\square$

**Theorem 6.7 (Neutralization).** If $b \in S$ and every $t \in S$ is harmless, then for every adversary and every $n$, $T_n$ is harmless: the forbidden action is never executed.

*Proof.* Immediate from Theorem 6.6. $\square$

This is the headline positive result, and its strength lies in what it does *not* assume: no bound on adversary power, no model of its strategy, no signature database, no heuristic, and — critically — no ability to decide maliciousness, which Section 4 forbids.

**Definition 6.8 (Alarm).** $\mathrm{alarm}(n) :\iff \neg\,\operatorname{verify}_S(\mathrm{adv}(n, T_n))$.

**Theorem 6.9 (Detection completeness and immediate rollback).** $\mathrm{alarm}(n)$ holds exactly when $\mathrm{adv}(n,T_n) \notin S$. If $\mathrm{alarm}(n)$ then $T_{n+1} = b$; if not, $T_{n+1} = \mathrm{adv}(n,T_n)$.

So *every* unsanctioned mutation, however novel, is detected at the step it occurs and reverted within that step, and no sanctioned mutation triggers a false alarm. The monitor is transparent to legitimate updates: if $\mathrm{adv}$ only ever produces sanctioned variants, the trace is the plain unguarded iteration.

---

## 7. The Algebra of Mutations and the Immune Uncertainty Principle

### 7.1 Mutations as a monoid

Self-modifications are endomorphisms of $\mathsf{PAst}$; under composition they form the monoid $\operatorname{End}(\mathsf{PAst})$.

**Definition 7.1.** $\operatorname{San}(S) := \{ m \in \operatorname{End}(\mathsf{PAst}) : m(S) \subseteq S \}$, the **sanctioned submonoid** (it contains the identity and is closed under composition). The **immunisation** of $m$ is $G(m) := Q_{S,b} \circ m$.

**Proposition 7.2 (Immunisation is a retraction).** For $b \in S$: (i) $G(m) \in \operatorname{San}(S)$ for every $m$, indeed $G(m)$ has all values in $S$; (ii) $G(G(m)) = G(m)$; (iii) $G(m) = m$ iff $m$ takes all values in $S$.

*Proof.* Pointwise from Lemma 6.4. $\square$

So the immune system is an idempotent retraction of the whole mutation monoid onto the sanctioned-valued maps, and a mutation is *invisible to the monitor* precisely when it is already sanctioned-valued.

**Theorem 7.3 (Guarded dynamics is a monoid action).** If $b \in S$ and $m \in \operatorname{San}(S)$, then the guarded trace under the constant mutation $\mathrm{adv}(n,\cdot) = m$ satisfies $T_n = m^{n}(b)$ for all $n$, and stays in $S$ forever.

*Proof.* Induction using $m(S)\subseteq S$ and $Q_{S,b}|_S = \mathrm{id}$. $\square$

Under a sanctioned mutation the immune system is literally invisible: overhead only appears at the moment of a violation.

### 7.2 Semantic equivalence

**Definition 7.4.** $s \sim t$ (**semantic equivalence**) iff $\operatorname{eval}(s,x) = \operatorname{eval}(t,x)$ and $\operatorname{effect}(s,x) = \operatorname{effect}(t,x)$ for every $x$. This is an equivalence relation.

**Lemma 7.5.** $\operatorname{pad}(l) \sim \mathrm{lit}\,0$ for every bit list $l$.

**Theorem 7.6 (Exponential equivalence classes).** Let $\mathcal{P}_n := \{ \operatorname{pad}(l) : l \in \{0,1\}^n \}$. Then $|\mathcal{P}_n| = 2^n$, every element of $\mathcal{P}_n$ is semantically equivalent to $\mathrm{lit}\,0$, and every element has size at most $3n+1$.

A single semantic equivalence class therefore contains at least $2^n$ programs of size $\le 3n+1$. Since attestation is *syntactic*, a monitor confronted with $\mathcal{P}_n$ has exactly two options: **store** those variants, or **reject** them. That dichotomy is a counting inequality.

### 7.3 The uncertainty principle

**Theorem 7.7 (Immune uncertainty principle).** For every whitelist $S$ and every $n$,
$$2^n \ \le\ \underbrace{|S|}_{\textbf{memory}} \ +\ \underbrace{|\mathcal{P}_n \setminus S|}_{\textbf{rigidity}} .$$

*Proof.* $|\mathcal{P}_n \setminus S| \ge |\mathcal{P}_n| - |S| = 2^n - |S|$ by the standard bound on the cardinality of a set difference. $\square$

Rigidity here is a security-relevant quantity: $|\mathcal{P}_n\setminus S|$ counts *behaviourally trivial* programs of size $\le 3n+1$ that the monitor rejects — false positives on a class of programs that provably cannot do anything at all.

**Corollary 7.8 (Permissiveness costs memory).** If $\mathcal{P}_n \subseteq S$ then $|S| \ge 2^n$; equivalently the attestation database carries at least $n$ bits of entropy, $n \le \log_2 |S|$.

One bit of memory per bit of dead code tolerated. Attestation is a *lossless code* for a class on which behaviour is constant, and lossless codes have unavoidable length.

**Theorem 7.9 (Rigidity of finite monitors).** Every finite whitelist containing $\mathrm{lit}\,0$ rejects a program semantically identical to one it accepts. More generally, for every finite $S$ there is a bit list $l$ with $\operatorname{pad}(l)\notin S$, and $\operatorname{pad}(l)$ computes $0$ with no effect.

*Proof.* $\operatorname{pad}$ is injective with infinite domain, so its image is infinite and cannot be contained in a finite set. $\square$

No finite whitelist is closed under semantically-neutral refactoring, because that closure is always infinite. This is a theorem, and it is the precise reason real attestation deployments break on benign rebuilds.

**Theorem 7.10 (Conservation law of algorithmic immunity).** Let $b \in S$ with every element of $S$ harmless. Then simultaneously:
1. *Containment:* for every unknown self-modifying adversary and every time, the forbidden action is never executed;
2. *Rigidity:* the same monitor rejects at least $2^n - |S|$ semantically benign programs of size $\le 3n+1$, for every $n$;
3. *Irreducibility:* this price cannot be avoided by switching to behavioural analysis, since no pure detector is both sound and complete.

Safety is attainable, but only in the syntactic category, and the semantic overshoot is exponentially large.

---

## 8. Bounded Universes: Perfect Immunity and Its Exact Price

Impossibility results are limits. Below the limit, everything works.

**Definition 8.1.** For bounds $N$ (size) and $L$ (literal value), let $\mathcal{U}_{N,L} := \{ t : \operatorname{size}(t)\le N,\ \text{all literals of } t < L \}$, and let the **bounded whitelist** $W_{N,L}$ consist of the harmless programs of $\mathcal{U}_{N,L}$.

$\mathcal{U}_{N,L}$ is finite: one constructs by recursion on $N$ an explicit finite over-approximation containing it (insert $\mathrm{inp}$ and $\mathrm{attack}$, the $L$ literals, and all branchings and calls built from the previous level), and proves by induction on $N$ that every $t$ with $\operatorname{size}(t)\le N$ and literals $<L$ lies in it. Hence $W_{N,L}$ is a well-defined finite set, and membership is decidable (size, literal bound, and $\operatorname{run}(t) = \mathrm{false}$ are all computable).

**Theorem 8.2 (Perfect immunity on a bounded universe).** For $N \ge 1$ and $L \ge 1$: $\mathrm{lit}\,0 \in W_{N,L}$; every member of $W_{N,L}$ is harmless; every harmless program of $\mathcal{U}_{N,L}$ belongs to $W_{N,L}$ (**zero false positives inside the universe**); and consequently, by Theorem 6.7, for every adversary and every time the guarded trace with baseline $\mathrm{lit}\,0$ is harmless.

**Theorem 8.3 (The price: exponential memory).** If $L \ge 2$ and $3n + 1 \le N$ then $|W_{N,L}| \ge 2^n$. Hence perfect immunity up to size $N$ costs at least $2^{\lfloor (N-1)/3 \rfloor}$ attestation tags.

*Proof.* All padded variants have literals $< 2 \le L$, size $3n+1 \le N$, and are harmless, hence $\mathcal{P}_n \subseteq W_{N,L}$; apply Corollary 7.8. $\square$

**Theorem 8.4 (Bounded-universe trade-off).** On every bounded code universe the immune system is perfect — total containment together with zero false positives — and every such immune system needs exponentially many attestation tags.

Letting $N\to\infty$ recovers the impossibility results of Sections 4, 5 and 7: they are not a separate phenomenon but the limit of a smooth, quantified trade-off.

---

## 9. Monitoring Frequency

Real monitors sample. Let the adversary mutate at every step but apply quarantine only at times divisible by $k$:
$$T^{(k)}_0 = b, \qquad T^{(k)}_{n+1} = \begin{cases} Q_{S,b}\bigl(\mathrm{adv}(n,T^{(k)}_n)\bigr) & \text{if } k \mid n+1,\\ \mathrm{adv}(n,T^{(k)}_n) & \text{otherwise.}\end{cases}$$

**Proposition 9.1.** $T^{(1)}_n = T_n$: period-$1$ sampling is exactly the continuous monitoring of Section 6, so Theorems 6.6–6.9 apply verbatim.

**Theorem 9.2 (Periodic self-healing).** If $b\in S$ then for every adversary and every $n$ divisible by $k$, $T^{(k)}_n \in S$: any compromise is repaired within one monitoring period.

**Theorem 9.3 (The sampling gap).** For every $k \ge 2$, every $S$ and every $b$, there is an adversary and a time at which the forbidden action is executed. Indeed the constant adversary $\mathrm{adv}(n,t) = \mathrm{attack}$ makes $T^{(k)}_{n+1}$ malicious at *every* $n+1$ not divisible by $k$ — a $(k-1)/k$ fraction of the run.

*Proof.* At a non-checkpoint step quarantine is not applied, so the running program is literally $\mathrm{attack}$, which is malicious. $\square$

**Theorem 9.4 (Monitoring frequency dichotomy).** With a harmless sanctioned set, continuous monitoring contains every adversary; with any period $k \ge 2$, some adversary succeeds. Continuous monitoring is therefore necessary and sufficient for total containment.

The moral is that *self-healing is not safety*. A system clean at every checkpoint and compromised in between has repaired itself into an alibi; and the exposure does not shrink gracefully with the sampling rate — it is exactly $(k-1)/k$.

---

## 10. Algorithms

All procedures below operate on syntax trees of size $s$.

**A. Attestation tagging.** Compute $\operatorname{code}(t)$ by a single post-order traversal, $\Theta(s)$ arithmetic operations. By Theorem 2.5 the resulting integer identifies $t$ uniquely; tag comparison decides program equality. (The tag grows doubly exponentially in depth as an integer, so implementations use it as a specification and a collision-resistant hash as the engineering surrogate; Theorem 2.5 is the statement that the *idealised* tag has no collisions.)

**B. Interpretation and self-execution.** Evaluate $\operatorname{eval}$ and $\operatorname{effect}$ by mutual recursion; on the branching clause, evaluate the guard first, then descend only into the selected branch. Self-execution is $\operatorname{effect}(t,\operatorname{code}(t))$. Cost is linear in the number of nodes visited (calls may revisit a subprogram at several arguments).

**C. Guarded execution loop.** Maintain the current program $T$ and the tag set $\operatorname{tags}(S)$ in a hash set. At each step: apply the adversary, compute the mutant's tag, look it up; on a hit accept, on a miss raise the alarm and reset to $b$. Cost per step: one tagging pass plus one $O(1)$ lookup. Theorem 6.6 guarantees the invariant $T \in S$; Theorem 6.9 guarantees alarm completeness.

**D. Diagonal parasite synthesis.** Given the source of a detector $d$ and a bit list $l$, emit $\mathrm{ite}(\mathrm{call}(d,\mathrm{inp}), \operatorname{pad}(l), \mathrm{attack})$, of size $\operatorname{size}(d)+3|l|+5$, in $\Theta(\operatorname{size}(d) + |l|)$ time. By Theorem 4.7, if $d$ is sound this program is a genuine attack that $d$ clears; if $d$ is complete it is a genuine false alarm. This is a *constructive* adversary generator, and it is a useful red-team tool: it converts any detector into its own certified failure.

**E. Bounded whitelist construction.** Enumerate the finite over-approximation of $\mathcal{U}_{N,L}$ level by level, filter by size, literal bound and $\operatorname{run}(t) = \mathrm{false}$. The enumeration is exponential in $N$ — necessarily so, by Theorem 8.3 — but yields a monitor with zero false positives inside the universe.

**F. Uncertainty audit.** Given a whitelist $S$ and a parameter $n$, compute $|S|$ and $|\mathcal{P}_n\setminus S|$ by tagging the $2^n$ padded variants and testing membership; report the slack in $2^n \le |S| + |\mathcal{P}_n\setminus S|$. Cost $\Theta(2^n\cdot n)$. This turns Theorem 7.7 into a deployable diagnostic: it measures how much of a monitor's budget is spent on memory versus on rejecting harmless code.

---

## 11. Applications

**Trusted computing and secure boot.** Theorem 6.2 is the formal content of "measure then compare": collision-freedom of the measurement makes verification exactly equivalent to whitelist membership, and Theorems 6.6–6.9 show that a measure-and-rollback loop contains an *arbitrary* adversary. This is a strong guarantee obtained with no threat model at all — the reason attestation architectures are robust in practice.

**Why signed-binary systems feel brittle.** Theorem 7.9 says every finite whitelist rejects a benign recompilation, and Theorem 7.7 quantifies it. Complaints about attestation breaking on timestamp changes or benign driver updates are not reports of bad engineering; they are observations of a conservation law. The design question is therefore not "how do we eliminate false rejections" but "where on the memory/rigidity curve do we want to sit".

**Antivirus and the signature treadmill.** Theorem 4.15 shows the blacklist update cycle provably never terminates, and Theorem 4.8 shows evasive variants have exponential density in program size — matching the observed economics of polymorphic malware, where variant generation is cheap and enumeration hopeless.

**Ensembles and voting.** Theorem 4.14 removes the hope that combining independent detectors helps against adaptive adversaries: the combination is a detector, so it inherits its own diagonal parasite, and the vote against it is unanimously zero. Ensembles improve *average-case* accuracy against non-adaptive samples; they provide no worst-case guarantee against an adversary that can read the ensemble.

**AI safety and self-modifying agents.** An agent permitted to edit its own policy is exactly the object modelled here. Theorem 5.3 says that a supervisor which the agent can query cannot be correct about the agent, *even if the supervisor is computationally unbounded*. The engineering consequence is precise: the supervisor must be either (i) unobservable by the agent (Theorem 5.6's positive half), or (ii) syntactic and rollback-based rather than predictive (Theorem 6.7). "Build a stronger predictor" is not on the list.

**Monitoring policy.** Theorem 9.4 says containment guarantees do not degrade gracefully with sampling rate: with period $k$ the compromised fraction of the run is $(k-1)/k$. Any budget argument that trades monitoring frequency against overhead is trading away the guarantee entirely, not a proportional slice of it.

---

## 12. Discussion

**What the diagonal argument actually needs.** The diagonal identity (Theorem 4.4) uses three ingredients: the detector is *harmless*, so consulting it does not itself change behaviour; the program is executed on *its own* tag; and the branch not taken is *behaviourally inert*. Remove any one and the construction fails. This is a much finer analysis than "by Rice's theorem", and it tells the engineer exactly which lever to pull: make the monitor unobservable (deny ingredient two), or refuse to reason about behaviour at all (Section 6).

**Decidable but internally unsolvable.** Theorem 4.10 is worth restating, because it separates our result from classical undecidability. The predicate "is malicious" is computed by a total, linear-time external procedure. What is impossible is only its *internalisation*. The barrier is therefore structural rather than complexity-theoretic — as Theorem 5.3 confirms by removing computability from the picture altogether.

**One object, two roles.** The padding family is simultaneously the source of exponential evasion (Theorem 4.8) and of exponential rigidity (Theorem 7.7). This is not a coincidence: both are consequences of the fact that a semantic equivalence class is syntactically enormous. Detection must look at semantics and is therefore blind to the class structure; attestation looks at syntax and is therefore maximally sensitive to it. The uncertainty principle is exactly the statement that this class must be paid for, once, in one of two currencies.

**Where the guarantee comes from.** The neutralization theorem is almost trivial to prove and extremely strong to state. That combination is the point: the strength comes from the *weakness of the question asked*. By declining to decide anything semantic, the monitor sidesteps every impossibility result in Sections 4 and 5. This is a general design principle for adversarial settings — an invariant you can check syntactically beats a property you must predict.

**Limitations.** The calculus is deliberately minimal: no loops, no state beyond the self register, a single effect, and a total semantics. Non-termination is therefore absent, and with it the classical halting obstruction — which is a feature, since it isolates *reflexivity* as the sole source of difficulty. The whitelist is finite and the adversary rewrites whole trees. Extending to recursive programs with partial semantics, to graded effects, and to adversaries with partial write access are natural next steps that we expect to preserve every statement here, with the effect layer replaced by a suitable trace semantics.

---

## 13. Open Problems

**1. An exact immune capacity law.** Write $\mathrm{mem}(S) = |S|$ and let $\mathrm{rig}(S,N)$ be the number of behaviourally trivial programs of size $\le N$ that $S$ rejects. Theorem 7.7 gives $\mathrm{mem}(S) + \mathrm{rig}(S,N) \ge 2^{\lfloor (N-1)/3\rfloor}$. Is there a matching upper bound $c_2 \cdot 2^{N/3}\cdot \mathrm{poly}(N)$ for optimal monitors, and is the lower bound attained *only* by the bounded whitelist of Section 8? Both sides are finitary and decidable for fixed $N$, so this is a concrete counting problem over the bounded universe.

**2. A reflexive oracle hierarchy.** Stratify programs by *reflexion depth*: $\mathrm{ask}$-free programs have depth $0$, and a program has depth $\le d+1$ if every query it makes is answered by an oracle correct on all programs of depth $\le d$. Lemma 5.4 and Theorem 5.5 establish level $0$; Theorem 5.3 establishes the global impossibility. Is there, for each $d$, an oracle correct at depth $\le d$, and is the hierarchy strict? Oracle-independence of $\mathrm{ask}$-free behaviour is the base case of an induction on depth, exactly as a Tarskian truth hierarchy escapes the liar by stratification.

**3. No probabilistic escape from the diagonal.** Let $\mu$ be a finitely supported distribution over harmless detectors and let the monitor sample $d \sim \mu$ at runtime. Since the parasite cannot know which detector it will face, randomisation is the last remaining hope. Conjecture: for every such $\mu$ there is a program that is malicious with probability at least $1/2$ and flagged with probability at most $1/2$ — i.e. randomisation buys at most a constant factor, never a guarantee. The finite support means the adversary can diagonalise against the ensemble disjunction (Theorem 4.14) and then rebalance.

**4. Graded effects and quantitative containment.** Replace the single $\mathrm{attack}$ by a lattice of effects with costs. Does the conservation law of Theorem 7.10 become a quantitative trade-off between admitted risk and whitelist size?

**5. Approximate attestation.** Replace exact tag equality by a similarity metric on syntax trees. Theorem 2.5 fails by design in that setting; what is the exact rate at which containment degrades as a function of the metric's tolerance, and does an uncertainty principle survive in the form "tolerance $\times$ memory $\ge$ exponential"?

---

## 14. Conclusion

An algorithmic immune system faces a clean dichotomy. If it tries to *understand* its host — to decide whether a self-modifying program will misbehave — it fails, for every detector, for every ensemble of detectors under every voting rule, and for every oracle of any computational strength whatsoever; and it fails not on rare pathological inputs but on exponentially dense families of small programs that it can be handed constructively, given only its own source code. If instead it refuses to understand anything and merely *recognises* — fingerprinting the running syntax tree and rolling back anything unrecognised — it succeeds completely: containment and neutralization against an arbitrary, unknown, adaptive, self-modifying adversary, with complete detection and same-step rollback, proved in three lines.

The price of that success is exactly an exponential: memory plus rigidity is at least $2^n$, so a monitor may be small or permissive but never both; perfect immunity is available on any bounded code universe at a cost of about $2^{N/3}$ attestation tags; and the guarantee requires verification after *every* mutation, since with period $k$ an adversary owns a $(k-1)/k$ fraction of the run.

Safety against self-modifying code is therefore attainable — but only in the syntactic category, and only by paying, in bits, for every behaviourally irrelevant variation one wishes to tolerate.
