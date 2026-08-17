# Tangled Hierarchies: Proof Systems That Reference Their Own Soundness

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

We give a complete frame-theoretic account of what it costs a formal system to contain its own soundness predicate. Working in the semantics of arbitrary Kripke frames — deliberately *not* assuming well-foundedness, since well-foundedness is precisely what is at stake — we prove that a world validates the reflection (soundness) schema $\Box\varphi\to\varphi$ uniformly in the valuation **if and only if** it accesses itself. Internalised soundness *is* a strange loop, in the exact sense of an edge from a vantage point to itself.

Four sharpenings follow. (i) **The schema cannot be weakened**: reflection for propositional variables alone already forces the loop and hence the full schema. (ii) **The loop cannot be avoided but can be isolated**: every frame extends, by one new top world, to a frame with an internally sound world; the extension preserves the truth of every formula at every old world, has exactly one self-loop and exactly one sound world; iterating gives a tower whose $n$-th stage has exactly $n$ sound worlds and still contains an unsound one, so stratification never converges. (iii) **The loop can be stretched, not removed**: a world validates the $n$-fold principle $\Box^{n}\varphi\to\varphi$ iff it lies on a closed walk of length exactly $n$; cycle frames on $n$ worlds realise degree $n$ while refuting all smaller positive degrees and having no self-loops, yet remain tangled in the transitive closure, and no provability frame admits any positive degree. (iv) **The boundary is at reflection, not consistency**: internal consistency $\neg\Box\bot$ is seriality, is validated on a loop-free converse-well-founded two-world chain, and costs nothing — while every *finite* frame sound for a system that proves its own consistency must be tangled, the infinite $\omega$-chain showing that finiteness is essential.

At the level of proof systems we prove a trichotomy: the system of validities of well-founded provability frames is consistent and Löbian but does not prove its own soundness schema or its own consistency; the system of formulas true at the single self-accessing world is consistent and proves both its soundness schema and its consistency statement, but refutes Löb's axiom; and *no* system closed under modus ponens and necessitation can be consistent while proving both. There are exactly two coherent regimes for a system that reasons about itself: well founded and silent, or self-certifying and tangled.

**Keywords:** provability logic, reflection principle, Löb's theorem, Kripke frames, strange loops, self-reference, Alexandrov topology, modal fixed points.

---

## 1. Introduction

### 1.1 The stratified picture and its discontents

The standard hygiene of metamathematics is stratification. Statements about a theory live one floor above the theory; statements about those statements live one floor above that; the "is about" relation is well founded and the tower never bends back on itself. Tarski's theorem on the undefinability of truth and Gödel's second incompleteness theorem are the classical reasons for the discipline: a system strong enough to talk about itself cannot in general certify itself.

Yet the temptation to internalise self-certification is permanent. What we would like a trusted system $S$ to contain is the **reflection schema**
$$\Box\varphi\to\varphi \qquad (\varphi \text{ any formula of } S\text{'s own language}),$$
where $\Box$ is $S$'s provability predicate: *whatever I prove is true*. Douglas Hofstadter named the resulting configuration a **tangled hierarchy** — a level structure whose supposedly higher levels reach back down into the levels they were meant to survey.

This paper asks the quantitative question. Granting that the tangle is unavoidable, *how much* tangle is forced? Where exactly does the tangle appear? Can it be weakened, delayed, isolated, or paid off in instalments? We answer all four questions in the Kripke semantics of modal provability logic, where "tangle" becomes a completely concrete graph-theoretic property: a closed walk in the accessibility relation.

### 1.2 Summary of results

Throughout, a *frame* is a pair $(W,R)$ with no assumptions at all, and a world is *internally sound* if every reflection instance holds there under every valuation.

1. **Soundness = Tangle** (Theorem 3.2). $w$ internally sound $\iff R\,w\,w$.
2. **Atomic Reflection** (Theorem 3.4). Reflection for atoms alone $\iff$ full reflection.
3. **Löb forbids the loop** (Theorem 3.6), hence **no world is both sound and Löbian**, and a frame validating both schemas everywhere is empty (Theorem 3.7).
4. **Structural destruction** (Section 4). A sound world admits no natural-number level grading, no well-founded rank of any kind (ordinals included), and lies outside the least fixed point $\mu X.\Box X$, which we identify with the well-founded part of the frame and show equals $W$ iff the frame is converse well founded.
5. **Topological bridge** (Theorem 4.6). The box operator of a frame is the interior operator of its Alexandrov topology iff every world is internally sound and the frame is transitive; on a nonempty provability frame this never happens.
6. **Cost is one loop** (Section 5). The soundness extension, its truth lemma, its exact loop and soundness counts, and the non-convergence of the reflection tower.
7. **The spectrum** (Section 6). $n$-fold reflection $\iff$ closed walk of length $n$; cycle frames realise each degree; the degree set is a submonoid of $(\mathbb{N},+)$; no provability frame has any positive degree.
8. **The boundary** (Section 7). Consistency is seriality and is tangle-free; but finite serial frames contain cycles, so all finite semantics for a self-consistent system are tangled, and the $\omega$-chain shows finiteness cannot be dropped.
9. **The trichotomy for proof systems** (Section 8).

---

## 2. Definitions

### 2.1 Syntax

Fix a set $\mathrm{At}$ of propositional variables. The modal language is generated by
$$\varphi ::= p \mid \bot \mid \varphi\to\varphi \mid \Box\varphi , \qquad p \in \mathrm{At}.$$
Negation is $\neg\varphi := \varphi\to\bot$, and the **consistency statement** is
$$\mathrm{Con} := \neg\Box\bot .$$
Two schemas are central:

* the **reflection instance** $\mathrm{Refl}(\varphi) := \Box\varphi\to\varphi$;
* the **Löb instance** $\mathrm{Loeb}(\varphi) := \Box(\Box\varphi\to\varphi)\to\Box\varphi$.

The $n$-fold box is defined by $\Box^{0}\varphi = \varphi$ and $\Box^{n+1}\varphi = \Box\,\Box^{n}\varphi$.

### 2.2 Frames and satisfaction

**Definition 2.1 (Frame).** A *frame* is a pair $F = (W,R)$ where $W$ is a set of *worlds* and $R\subseteq W\times W$ is the *accessibility relation*. **No** further condition is imposed; in particular neither transitivity nor irreflexivity nor well-foundedness.

**Definition 2.2 (Satisfaction).** A *valuation* is a map $V : \mathrm{At} \to \mathcal{P}(W)$. Satisfaction $w \models_V \varphi$ is defined by recursion:
$$w\models_V p \iff w \in V(p), \qquad w\not\models_V \bot,$$
$$w\models_V \varphi\to\psi \iff (w\models_V\varphi \Rightarrow w\models_V\psi), \qquad w\models_V \Box\varphi \iff \forall v\,(R\,w\,v \Rightarrow v\models_V\varphi).$$

**Definition 2.3 (Provability frame).** A *provability frame* (GL frame) is a frame that is transitive and converse well founded — there is no infinite chain $w_0 R w_1 R w_2 R \cdots$. Converse well-foundedness implies irreflexivity. These are exactly the frames validating Löb's axiom, and they are the intended semantics of formal provability.

### 2.3 Internal soundness

**Definition 2.4 (Internal soundness).** A world $w$ of $F$ is **internally sound** (for the language over $\mathrm{At}$) if
$$\forall V\ \forall\varphi:\quad w\models_V \Box\varphi\to\varphi .$$
The quantifier over valuations is essential: soundness is a property of the *world in the frame*, not of a particular interpretation.

**Definition 2.5 (Atomic soundness).** $w$ is **atomically sound** if $\forall V\ \forall p\in\mathrm{At}:\ w\models_V \Box p \to p$.

**Definition 2.6 ($n$-fold internal soundness).** $w$ has *soundness degree $n$*, written $\mathrm{IS}_n(w)$, if $\forall V\ \forall \varphi:\ w \models_V \Box^{n}\varphi\to\varphi$. Degree $1$ is Definition 2.4.

**Definition 2.7 (Löb world).** $w$ *validates Löb* if $\forall V\,\forall\varphi:\ w\models_V \mathrm{Loeb}(\varphi)$.

**Definition 2.8 ($n$-step accessibility).** $R^{(0)}\,u\,v :\iff u=v$, and $R^{(n+1)}\,u\,v :\iff \exists z\,(R\,u\,z \wedge R^{(n)}\,z\,v)$. Thus $R^{(n)}\,w\,w$ says $w$ lies on a **closed walk of length exactly $n$**.

**Definition 2.9 (Tangled).** A relation $S$ on $W$ is **tangled** if it contains a two-cycle, i.e. there are $a,b$ (possibly equal) with $S\,a\,b$ and $S\,b\,a$. In particular a self-loop makes $S$ tangled. A tangled relation admits no *grading*: no $\mathrm{rank}: W\to\mathbb{N}$ with $S\,a\,b \Rightarrow \mathrm{rank}(a) < \mathrm{rank}(b)$.

---

## 3. Internalised soundness is exactly a self-loop

### 3.1 The easy direction

**Lemma 3.1.** *If $R\,w\,w$ then $w$ is internally sound.*

*Proof.* Suppose $w\models_V\Box\varphi$. By definition $\varphi$ holds at every $R$-successor of $w$; $w$ is such a successor; hence $w\models_V\varphi$. $\square$

### 3.2 The diagonal valuation

**Theorem 3.2 (Soundness = Tangle).** *For every frame $F$ and world $w$:*
$$w \text{ is internally sound} \iff R\,w\,w .$$

*Proof sketch.* ($\Leftarrow$) is Lemma 3.1. For ($\Rightarrow$), fix any atom $p$ and define the **diagonal valuation** $V^{\ast}$ by
$$V^{\ast}(p) := \{ v \in W : R\,w\,v \} \qquad (\text{other atoms arbitrary}).$$
By construction $p$ holds at every successor of $w$, so $w \models_{V^{\ast}} \Box p$. Internal soundness applied to the instance $\Box p \to p$ yields $w\models_{V^{\ast}} p$, i.e. $R\,w\,w$. $\square$

The proof consumes only one atom and one instance of the schema; this is the source of the next result.

**Remark 3.3.** The theorem needs the quantifier over valuations. Relative to a *fixed* valuation, an irreflexive world can accidentally be sound (Section 8.3 discusses a frame in which a valuation names its own soundness set non-vacuously).

**Theorem 3.4 (No safe fragment).** *A world is atomically sound iff it is internally sound.*

*Proof sketch.* Internal soundness trivially implies the atomic fragment. Conversely, the diagonal valuation of Theorem 3.2 uses only an atomic instance, so atomic soundness already gives $R\,w\,w$, and Lemma 3.1 upgrades this to full reflection. $\square$

Theorem 3.4 is a sharpness statement: there is no non-trivial fragment of the soundness schema that a well-founded system can afford. Self-trust does not come in weaker syntactic flavours — only (Section 6) in slower ones.

### 3.3 Löb and the impossibility of coexistence

**Lemma 3.5.** *If $w$ validates Löb, then $\neg R\,w\,w$.*

*Proof sketch.* Take the valuation making an atom $p$ false everywhere and consider $\mathrm{Loeb}(p)$. If $R\,w\,w$ held, $w\models\Box(\Box p\to p)$ would follow from Lemma 3.1 applied at successors — more directly, one checks that with $p$ false everywhere, $\Box(\Box p \to p)$ holds at $w$ exactly when every successor $v$ of $w$ fails $\Box p$; a self-loop plus the Löb instance then forces $w\models\Box p$, hence $w\models p$ by the loop, contradicting the choice of $V$. $\square$

**Theorem 3.6.** *No world is both internally sound and Löb-validating.*

*Proof.* Soundness gives $R\,w\,w$ (Theorem 3.2); Löb gives $\neg R\,w\,w$ (Lemma 3.5). $\square$

**Theorem 3.7 (Semantic second incompleteness).** *A frame in which every world is both internally sound and Löb-validating is empty. In particular, no world of a provability frame is internally sound.*

*Proof.* The first claim is immediate from Theorem 3.6. For the second, a provability frame is irreflexive, so Theorem 3.2 forbids soundness at each of its worlds. $\square$

This is the frame-level content of Gödel's second theorem: the well-founded reading of provability and the internalisation of soundness are jointly unsatisfiable, not merely jointly unproven.

---

## 4. What the tangle destroys

### 4.1 No levels

**Theorem 4.1.** *If a frame has an internally sound world, its accessibility relation is tangled, and consequently there is no $\mathrm{rank}: W\to\mathbb{N}$ with $R\,a\,b \Rightarrow \mathrm{rank}(a)<\mathrm{rank}(b)$.*

*Proof.* Theorem 3.2 gives $R\,w\,w$, a self-loop, so $R$ is tangled; a grading would give $\mathrm{rank}(w)<\mathrm{rank}(w)$. $\square$

**Theorem 4.2 (Absoluteness of the collapse).** *If $w$ is internally sound, then for no well-founded relation $s$ on any set $B$ is there a map $\rho:W\to B$ with $R\,a\,b \Rightarrow s\,\rho(b)\,\rho(a)$; in particular there is no ordinal-valued grading $\rho : W \to \mathrm{Ord}$ strictly decreasing along arrows.*

*Proof sketch.* Such a $\rho$ would give $s\,\rho(w)\,\rho(w)$, and no element of a well-founded relation relates to itself. $\square$

So the failure is not an artefact of counting with $\mathbb{N}$: no hierarchy of metalevels of any ordinal height can accommodate one self-trusting world.

### 4.2 Box as a set operator; Löb induction

Define, for $X\subseteq W$,
$$\Box X := \{ w \in W : \forall v\,(R\,w\,v \Rightarrow v\in X)\} .$$
This is monotone, hence has a least fixed point $\mu X.\Box X$ by Knaster–Tarski.

**Theorem 4.3.** *$\mu X.\Box X$ is exactly the well-founded part of $R$, i.e. the set of worlds $w$ such that $R$ restricted to the worlds reachable from $w$ is converse well founded (equivalently, $w$ is accessible for the converse relation).*

**Theorem 4.4 (Löb's principle as induction).** *The following are equivalent:*
1. *$\Box X \subseteq X$ implies $X = W$, for every $X\subseteq W$;*
2. *$\mu X.\Box X = W$;*
3. *$R$ is converse well founded.*

*Proof sketch.* $(1)\Rightarrow(2)$ apply (1) to the least prefixed point. $(2)\Rightarrow(3)$ by Theorem 4.3. $(3)\Rightarrow(1)$ is transfinite induction along the converse relation: if $\Box X\subseteq X$ and $w\notin X$, then $w$ has a successor outside $X$, generating an infinite ascending chain. $\square$

**Corollary 4.5.** *If $R\,w\,w$, then $w\notin\mu X.\Box X$ and hence $\mu X.\Box X \neq W$. In particular an internally sound world escapes every Löb-style induction.*

Thus the tangle does not merely block a bookkeeping device; it removes the induction principle that makes provability logic work.

### 4.3 The topological bridge

Every frame carries its **Alexandrov topology**: $X\subseteq W$ is open iff it is closed under accessibility ($w\in X$ and $R\,w\,v$ imply $v\in X$). This is a genuine topology (arbitrary unions and finite intersections of $R$-closed sets are $R$-closed).

**Theorem 4.6 (Interior = provability iff everywhere sound and transitive).** *For a frame $F$, the following are equivalent:*
1. *for every $X\subseteq W$, $\operatorname{int}(X) = \Box X$ in the Alexandrov topology;*
2. *every world of $F$ is internally sound, and $R$ is transitive.*

*Proof sketch.* $(2)\Rightarrow(1)$: soundness everywhere gives reflexivity (Theorem 3.2), so $\Box X\subseteq X$; transitivity makes $\Box X$ open; and any open $U\subseteq X$ satisfies $U\subseteq \Box X$ by openness, so $\Box X$ is the largest open subset of $X$. $(1)\Rightarrow(2)$: from $\operatorname{int}(X)=\Box X$ we get $\Box X\subseteq X$ for all $X$; applying this to $X=\{v : R\,w\,v\}$ yields $R\,w\,w$, hence soundness by Theorem 3.2. Idempotence $\Box X\subseteq\Box\Box X$ (also inherited from the interior operator) applied to the same set yields transitivity. $\square$

**Corollary 4.7.** *On a nonempty provability frame the box operator is never the interior operator of the Alexandrov topology.*

Modal soundness-internalisation and topological interior semantics are literally the same hypothesis: the S4/interior picture of $\Box$ presupposes exactly the self-trust that provability logic forbids.

---

## 5. The cost is exactly one loop

### 5.1 The soundness extension

**Definition 5.1.** For a frame $F=(W,R)$, its **soundness extension** $F^{+}$ has worlds $W \sqcup \{\top\}$ and accessibility
$$R^{+}\,\top\,x \text{ for all } x \text{ (including } x=\top), \qquad R^{+}\,u\,v \iff R\,u\,v \ \ (u,v\in W), \qquad \neg R^{+}\,u\,\top \ (u \in W).$$
$\top$ is the system that reasons about $F$ while remaining inside the picture.

**Theorem 5.2 (Truth lemma; conservation).** *Extend a valuation $V$ on $F$ to $F^{+}$ by making every atom false at $\top$. Then for every formula $\varphi$ and every old world $v\in W$,*
$$v \models^{F^{+}} \varphi \iff v \models^{F} \varphi .$$

*Proof sketch.* Induction on $\varphi$. The only non-trivial case is $\Box$, and it is exactly the fact that $W$ is a *generated submodel* of $F^{+}$: no old world accesses $\top$, so the successor set of an old world is unchanged. $\square$

**Theorem 5.3 (Exact cost).** *$\top$ is internally sound in $F^{+}$. If $F$ is irreflexive, then $\top$ is the unique self-accessing world and the unique internally sound world of $F^{+}$. Moreover $F^{+}$ is not converse well founded, and the failure occurs exactly at $\top$.*

*Proof.* $R^{+}\top\top$ holds, so Lemma 3.1 applies. Self-loops of $F^{+}$ are $\{\top\}\cup\{u\in W : R\,u\,u\} = \{\top\}$ under irreflexivity, and Theorem 3.2 converts "self-loop" into "internally sound". $\square$

**Corollary 5.4 (Every well-founded hierarchy tangles minimally).** *For every provability frame $M$: no world of $M$ is internally sound; $M$ embeds into $M^{+}$ with all truths at old worlds preserved; $M^{+}$ has a unique internally sound world; and $M^{+}$ admits no natural-number grading.*

This is the precise sense in which a strange loop need not corrupt the levels it sits above: the tangle is conservative for the old worlds while being fatal to global stratification.

### 5.2 The reflection tower does not converge

**Definition 5.5.** The **reflection tower** over $F$ is $F^{(0)} := F$, $F^{(n+1)} := (F^{(n)})^{+}$. Stage $n+1$ is a system that reasons about — and certifies the soundness of — stage $n$.

**Theorem 5.6 (One loop per stage).** *If $F$ is irreflexive then the set of self-accessing worlds of $F^{(n)}$ is finite of cardinality exactly $n$; equivalently, $F^{(n)}$ has exactly $n$ internally sound worlds — no matter how large $F$ is.*

*Proof sketch.* Induction: the self-loop set of $G^{+}$ is $\{\top\}$ together with the injective image of the self-loop set of $G$, so the count increases by exactly one at each stage. Theorem 3.2 converts loops into sound worlds. $\square$

**Theorem 5.7 (Non-convergence).** *If $F$ is irreflexive and nonempty, then for every $n$ the stage $F^{(n)}$ still contains a world that is not internally sound.*

*Proof.* Any old irreflexive world remains irreflexive at every stage; apply Theorem 3.2. $\square$

**Corollary 5.8 (Tower report).** *For a nonempty provability frame $M$ and any $n$: stage $n$ has exactly $n$ internally sound worlds; stage $n$ still has an unsound world; and every internally sound world of stage $n+1$ lies outside $\mu X.\Box X$ and admits no ordinal grading.*

Adding metalevels buys internal soundness at a rate of exactly one sound world per level and never completes. The tangle can be added, never finished.

---

## 6. The spectrum of tangles: iterated reflection

### 6.1 The characterisation

**Lemma 6.1.** *$w\models_V \Box^{n}\varphi$ iff $\varphi$ holds at every $v$ with $R^{(n)}\,w\,v$.*

*Proof.* Induction on $n$; the successor step decomposes a path of length $n+1$ as an edge followed by a path of length $n$. $\square$

**Theorem 6.2 (Spectrum Theorem).** *For every frame, world $w$ and $n\in\mathbb{N}$:*
$$\mathrm{IS}_n(w) \iff R^{(n)}\,w\,w ,$$
*i.e. $w$ validates $\Box^{n}\varphi\to\varphi$ (uniformly in the valuation) iff $w$ lies on a closed walk of length exactly $n$.*

*Proof sketch.* ($\Leftarrow$) If $R^{(n)}\,w\,w$ and $w\models_V\Box^{n}\varphi$ then Lemma 6.1 gives $w\models_V\varphi$. ($\Rightarrow$) Diagonalise at distance $n$: interpret an atom $p$ as $\{v : R^{(n)}\,w\,v\}$. Then $w\models\Box^{n}p$ by Lemma 6.1, so the instance $\Box^{n}p\to p$ gives $p$ at $w$, i.e. $R^{(n)}\,w\,w$. $\square$

**Corollary 6.3.** *$\mathrm{IS}_1(w)$ iff $R\,w\,w$: the case $n=1$ is Theorem 3.2.*

**Proposition 6.4 (Degrees form a monoid).** *$\mathrm{IS}_0(w)$ always holds, and $\mathrm{IS}_m(w)\wedge \mathrm{IS}_n(w) \Rightarrow \mathrm{IS}_{m+n}(w)$. Hence the *soundness spectrum* $D(w) := \{ n : \mathrm{IS}_n(w)\}$ is a submonoid of $(\mathbb{N},+)$.*

*Proof.* Degree $0$ is the tautology $\varphi\to\varphi$. For addition, concatenate a closed $m$-walk with a closed $n$-walk at $w$ to obtain a closed $(m+n)$-walk, then apply Theorem 6.2 in both directions. $\square$

### 6.2 Every positive degree is tangled

**Lemma 6.5.** *If $n>0$ and $R^{(n)}\,u\,v$ then $u\,R^{+}\,v$ in the transitive closure of $R$.*

**Theorem 6.6.** *If $\mathrm{IS}_n(w)$ for some $n\ge 1$, then the transitive closure of $R$ is tangled and admits no natural-number grading.*

*Proof.* Theorem 6.2 gives a closed walk of positive length at $w$; Lemma 6.5 turns it into a self-loop of the transitive closure. $\square$

**Lemma 6.7.** *On a transitive frame, $R^{(n)}\,u\,v$ with $n\ge 1$ implies $R\,u\,v$.*

**Theorem 6.8 (No degree on a provability frame).** *For every provability frame $M$, every $n\ge 1$ and every world $w$: $\neg\,\mathrm{IS}_n(w)$.*

*Proof.* Theorem 6.2 and Lemma 6.7 give $R\,w\,w$, contradicting irreflexivity. $\square$

Delay does not buy escape: a well-founded provability system cannot internalise soundness even after arbitrarily many boxes.

### 6.3 Realising the spectrum: cycle frames

**Definition 6.9.** The **cycle frame** $C_n$ has worlds $\mathbb{Z}/n\mathbb{Z}$ and $R\,i\,j \iff j = i+1$.

**Lemma 6.10.** *In $C_n$, $R^{(k)}\,i\,j \iff j = i + k \pmod n$.*

**Theorem 6.11 (Degree exactly $n$).** *For $n\ge 2$ the frame $C_n$ satisfies:*
1. *every world validates $\Box^{n}\varphi\to\varphi$;*
2. *no world validates $\Box^{k}\varphi\to\varphi$ for any $0<k<n$;*
3. *no world accesses itself;*
4. *the transitive closure of its accessibility relation is nevertheless tangled.*

*Proof sketch.* (1) $i+n \equiv i$. (2) By Theorem 6.2 and Lemma 6.10, $\mathrm{IS}_k(i)$ would give $k\equiv 0 \bmod n$, i.e. $n\mid k$, impossible for $0<k<n$. (3) is (2) with $k=1$. (4) is Theorem 6.6 applied with $n$. $\square$

So internal soundness comes in a strictly increasing hierarchy of *tangle lengths*. A system can internalise a **delayed** soundness principle — "what I prove that I prove that I prove … is true" — with no world referring to itself in a single step. The self-reference is genuinely spread across $n$ distinct levels; what cannot be spread away is the closed walk itself.

By Proposition 6.4 the spectra $D(w)$ are submonoids of $(\mathbb{N},+)$, and cycle frames realise precisely the principal submonoids $n\mathbb{N}$.

---

## 7. Where the boundary lies: consistency is free

### 7.1 Consistency is seriality

**Theorem 7.1.** *For every frame, valuation and world: $w\models \mathrm{Con}$ (that is, $w \models \neg\Box\bot$) iff $w$ has at least one successor. In particular internal consistency does not depend on the valuation.*

*Proof.* $w\models\Box\bot$ iff $w$ has no successors, since $\bot$ holds nowhere. $\square$

**Definition 7.2.** The **two-chain** is the frame with worlds $\{t,f\}$ and the single edge $t \to f$.

**Theorem 7.3 (Consistency costs nothing).** *The two-chain is loop-free and converse well founded — a bona fide well-founded hierarchy — yet its world $t$ satisfies $\mathrm{Con}$ under every valuation. And $t$ is not internally sound, not even atomically.*

*Proof.* $t$ has the successor $f$, so Theorem 7.1 applies. Internal soundness would force $R\,t\,t$ by Theorem 3.2. $\square$

**Corollary 7.4 (The precise Gödel boundary).** *Internal consistency is compatible with a converse-well-founded, loop-free frame; internal soundness of any positive degree is not (Theorem 6.8). The jump from untangled to tangled happens exactly at reflection.*

### 7.2 Finite semantics of a self-consistent system must tangle

Now move up one level, from a world to a *system* asserting its own consistency.

**Definition 7.5.** A **modal proof system** is a set $\mathrm{Thm}$ of formulas closed under modus ponens ($\mathrm{Thm}(\varphi\to\psi)$ and $\mathrm{Thm}(\varphi)$ give $\mathrm{Thm}(\psi)$) and necessitation ($\mathrm{Thm}(\varphi)$ gives $\mathrm{Thm}(\Box\varphi)$). Nothing else is assumed, so each result below isolates exactly which principle causes a collapse. It is **consistent** if $\bot\notin\mathrm{Thm}$; it is **frame-sound for $F$** if every theorem holds at every world of $F$ under every valuation.

**Theorem 7.6.** *If $S$ proves $\mathrm{Con}$ and $F$ is frame-sound for $S$, then $F$ is serial: every world has a successor. Consequently, if $F$ is also converse well founded then $F$ is empty; in particular no nonempty provability frame is sound for a system that proves its own consistency.*

*Proof.* Seriality is Theorem 7.1 applied at each world. A converse-well-founded serial frame would have a maximal world with a successor — impossible. $\square$

**Lemma 7.7 (Finite + serial $\Rightarrow$ cyclic).** *A finite nonempty serial frame contains a world lying on a cycle of its transitive closure.*

*Proof sketch.* Choose a successor function $f$ and iterate from any world; by finiteness $f^{i}(w) = f^{j}(w)$ for some $i<j$, and the segment between them is a closed walk of positive length. $\square$

**Theorem 7.8 (Unavoidability of the tangle, finite case).** *Every finite nonempty frame that is sound for a proof system asserting its own consistency has a tangled transitive closure, and hence admits no natural-number grading of its reference graph.*

**Theorem 7.9 (Sharpness).** *Finiteness cannot be dropped: the $\omega$-chain $0\to 1\to 2\to\cdots$ is serial and completely loop-free — even in its transitive closure — so an infinite untangled semantics for a self-consistent system does exist.*

The tangle is thus forced by *finiteness plus self-consistency*, not by self-consistency alone. Infinity is the only legitimate way to be self-consistent without tangling.

---

## 8. Proof systems: the trichotomy

### 8.1 Löb's rule and the impossibility

**Definition 8.1.** A system $S$ **proves the Löb axiom** if $\mathrm{Loeb}(\varphi)\in\mathrm{Thm}$ for all $\varphi$; it **contains its own soundness predicate** if $\mathrm{Refl}(\varphi)\in\mathrm{Thm}$ for all $\varphi$.

**Theorem 8.2 (Löb's rule).** *In a system proving the Löb axiom, if $\Box\varphi\to\varphi$ is a theorem then so is $\varphi$.*

*Proof.* From $\mathrm{Thm}(\Box\varphi\to\varphi)$, necessitation gives $\mathrm{Thm}(\Box(\Box\varphi\to\varphi))$; the Löb axiom and modus ponens give $\mathrm{Thm}(\Box\varphi)$; the hypothesis and modus ponens give $\mathrm{Thm}(\varphi)$. $\square$

**Theorem 8.3.** *A system that proves the Löb axiom and contains its own soundness predicate is inconsistent.*

*Proof.* Apply Theorem 8.2 with $\varphi=\bot$: the reflection instance $\Box\bot\to\bot$ is a theorem, hence so is $\bot$. $\square$

**Corollary 8.4 (Second incompleteness, modally).** *A consistent Löbian system proves neither its own consistency statement $\mathrm{Con}$ nor any complete soundness schema. Conversely, a consistent system containing its own soundness predicate cannot be Löbian.*

*Proof.* $\mathrm{Con} = \Box\bot\to\bot$ is exactly the reflection instance for $\bot$, and Theorem 8.2 with $\varphi=\bot$ turns it into $\bot$. $\square$

### 8.2 Two concrete systems

**The well-founded system.** Let $\mathrm{GL}$-validity be the system whose theorems are the formulas valid at every world of every provability frame under every valuation. It is closed under modus ponens and necessitation, it is Löbian (Löb's axiom is valid on exactly these frames), and it is consistent (witness: the one-point irreflexive frame, at whose world $\bot$ fails). By Corollary 8.4 it does **not** contain its own soundness predicate and does **not** prove $\mathrm{Con}$.

**The tangled system.** Let the **tangled system** have as theorems the formulas true, under every valuation, at the world of the one-point *reflexive* frame (a single world accessing itself). It is closed under modus ponens and necessitation. Because the world is self-accessing, Lemma 3.1 shows the system proves every instance of $\Box\varphi\to\varphi$; it proves $\mathrm{Con}$ (the instance at $\bot$); and it is consistent (take the valuation making everything false). By Theorem 8.3 it must **refute** the Löb axiom.

### 8.3 The trichotomy

**Theorem 8.5 (Trichotomy).** *For every propositional signature:*
1. *the $\mathrm{GL}$-validity system is consistent, proves every instance of the Löb axiom, and does not contain its own soundness predicate;*
2. *the tangled system is consistent, contains its own soundness predicate (and proves its own consistency statement), and does not prove the Löb axiom;*
3. *no modal proof system whatsoever is simultaneously consistent, Löbian, and in possession of its own soundness predicate.*

Hence: **a proof system that reasons about its own soundness or consistency is necessarily tangled** — it cannot carry the well-founded Löbian provability discipline — and conversely the well-founded systems are exactly those that must leave their own soundness outside.

**Complement (a genuine internal soundness predicate).** Tangling is not the only phenomenon available; a frame can also carry, non-vacuously, an atom naming its *own* soundness set. On the two-world frame $\{f,t\}$ in which both worlds access $t$ and only $t$, put $V(s) := \{t\}$: then $s$ holds at exactly those worlds that are sound relative to $V$, so $s$ is a genuine modal fixed point, and it is non-vacuous — $t$ is sound, $f$ is not. If instead a system *asserts* such a predicate at every world, then every world must have a successor, and by Theorem 7.6 a converse-well-founded frame realising this is empty. Naming your soundness is safe; asserting it everywhere is not.

---

## 9. Algorithms

All the structural facts above are decidable on finite frames, by design: the modal statements have been converted into reachability statements.

**Algorithm A (Soundness spectrum of a world).** Given a finite frame $(W,R)$ with $|W| = N$ and a world $w$, compute $D(w) \cap [0,K]$, i.e. the set of degrees $n\le K$ with $\mathrm{IS}_n(w)$. By Theorem 6.2 this is just $\{ n \le K : R^{(n)}\,w\,w\}$. Iterating the frontier $S_{n+1} = R[S_n]$ from $S_0 = \{w\}$ costs $O(K\cdot |R|)$ time and $O(N)$ space, versus the hopeless direct approach of quantifying over all valuations and all formulas.

**Algorithm B (Sound-world census and tangle test).** Compute $\{w : \mathrm{IS}_1(w)\} = \{w : R\,w\,w\}$ in $O(N)$; compute the transitive closure (e.g. by repeated reachability, $O(N\cdot|R|)$) and report tangledness as the existence of a diagonal entry. By Theorem 4.1 a non-empty answer certifies that no natural-number grading exists; when the answer is empty, a grading can be produced by topological sort in $O(N+|R|)$, which is precisely the well-founded stratified case.

**Algorithm C (Reflection tower simulation).** Given an irreflexive $F$, construct $F^{(n)}$ by $n$ applications of the soundness extension, each adding one world with edges to everything including itself. The loop count at stage $n$ is exactly $n$ (Theorem 5.6) and at least one world remains unsound (Theorem 5.7); both are verified in $O(N+n)$ per stage. This is the computational form of "stratification never converges."

---

## 10. Discussion

### 10.1 What has been isolated

The classical statements — Tarski, Gödel 2, Löb — say that self-certification is impossible *within* a well-founded system. The results here say something more finely grained, and arguably more useful:

* **Self-certification is a graph property.** Uniform internal soundness of degree $n$ is *identical* to lying on a closed walk of length $n$. Every semantic question about internalised soundness reduces to reachability.
* **It has no weak fragments, only slow ones.** Atomic reflection already yields the whole schema (Theorem 3.4); but $n$-fold reflection genuinely stratifies into a strictly increasing hierarchy of degrees realised by cycle frames (Theorem 6.11).
* **It is conservative where it matters.** The minimal tangling of a hierarchy changes no truth of the original hierarchy (Theorem 5.2), costs exactly one loop, and yields exactly one sound world (Theorem 5.3).
* **It cannot be reached by stratification.** Every finite stage of the reflection tower has an unsound world (Theorem 5.7).
* **It is a property of soundness, not coherence.** Consistency is seriality and is free on well-founded frames (Theorem 7.3); it becomes tangling only in the presence of finiteness (Theorems 7.8, 7.9).

### 10.2 The topological reading

Theorem 4.6 says the S4/interior semantics of $\Box$ — familiar from topological semantics of modal logic, where $\Box$ is interior — is *equivalent* to universal internal soundness plus transitivity. So the choice between "provability" and "interior" readings of the same symbol is exactly the choice between well-foundedness and self-trust. There is no frame on which both readings are available and the frame is nonempty (Corollary 4.7).

### 10.3 Applications and analogies

The formal content transfers wherever a structure certifies its own outputs.

* **Verified toolchains.** A verifier that verifies verifiers, and finally itself, must include itself in its own scope of quantification. The results say: this is achievable, it is conservative over the previously verified components, and it costs exactly one non-well-founded edge — but no finite tower of "meta-verifiers" achieves it, because each stage still has an uncertified top.
* **Reflective agents.** An agent whose model of its own reliability is asserted at every state must be serial (it always sees a next state), and if its state space is finite it must be cyclic: a finite self-trusting agent necessarily revisits its own vantage point.
* **Institutional self-amendment.** A constitution authorising its own amendment is a top world seeing itself. The conservation theorem is the formal counterpart of the observation that self-amendment need not disturb any existing law.

### 10.4 Limits of the analysis

The framework is deliberately austere: propositional modal language, no arithmetic, no coding. The results are therefore statements about *reference structure*, not about arithmetical strength; they explain what shape self-reference must take, not what it can compute. Bridging to arithmetised provability (where $\Box$ is a genuine proof predicate and the correspondence with frames is Solovay's theorem) is a natural next step, and would turn the frame-level costing above into a costing in terms of theories and reflection principles.

---

## 11. Future work

1. **The soundness-degree monoid.** We have shown $D(w) = \{n : \mathrm{IS}_n(w)\}$ is a submonoid of $(\mathbb{N},+)$ containing $0$, equal to $\{0\}$ exactly when $w$ lies on no cycle, and that cycle frames realise the principal submonoids $n\mathbb{N}$. Conjecture: *every* submonoid of $(\mathbb{N},+)$ arises as $D(w)$, so "how self-sound a world is" is a complete numerical-semigroup invariant. The realisation half needs only a wedge of cycles of prescribed lengths glued at a common world.
2. **Global conservativity.** Theorem 5.2 gives conservativity for truth at old worlds. Conjecture: the soundness extension is conservative for *global consequence*, and the same holds for the direct limit of the reflection tower. This would upgrade "the cost is one loop" to "the cost is nothing for the old theory".
3. **A topological trichotomy.** Classify frames by whether the box operator is the interior operator, is merely a monotone operator with $\Box X\subseteq X$ failing everywhere (the provability case), or lies strictly between; Theorem 4.6 pins the two extremes and the intermediate class is unexplored.
4. **Degrees beyond $\omega$.** Transfinite iterations of the reflection tower, and reflection principles indexed by ordinals, should produce an ordinal-valued analogue of the soundness spectrum.
5. **Arithmetical realisation.** Identify which of these frame phenomena are realised by concrete theories with concrete reflection principles, via the arithmetical completeness theory of provability logic.

---

## 12. Conclusion

Internalised soundness is not a subtle syntactic condition; it is a loop, and only a loop. A world trusts itself exactly when it sees itself; it trusts itself with an $n$-step delay exactly when it lies on a closed walk of $n$ steps. This one identification converts the whole subject into graph theory, and every structural consequence follows: no levels, no ordinal ranks, no Löb induction, no coexistence with the well-founded provability discipline, no non-trivial safe fragment, and no convergence of stratification. In compensation, the loop is cheap and clean — one edge, one world, no disturbance to any pre-existing truth — and it is the price of *soundness* alone: mere self-declared consistency remains free on well-founded frames, and becomes unavoidable only when the world of the system is finite.

Tangled hierarchies, in short, are neither pathologies nor accidents. They are the exact and minimal shape that self-certification must take.
