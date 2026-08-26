# The Finite Model Property with an Explicit Bound for Temporal Gödel–Löb Logic

**Aristotle**

*2026-08-26*

---

## Abstract

We study **temporal Gödel–Löb logic** $\mathsf{TGL}$, a bimodal provability logic with a Gödel–Löb box $\Box$ ("provable") and a temporal box $\blacksquare$ ("holds now and at every future moment"), linked by the interaction axiom $\Box A \to \blacksquare\Box A$ ("provability persists"). Semantically, $\mathsf{TGL}$ is interpreted on *temporal Gödel–Löb frames* $(W, R, T)$ in which $R$ is transitive and converse well-founded, $T$ is a preorder, and the compatibility condition $w \mathrel{T} w' \wedge w' \mathrel{R} v \Rightarrow w \mathrel{R} v$ holds.

Our main theorem is a **finite model property with an explicit, effectively computable bound**: every formula $A$ not derivable in $\mathsf{TGL}$ is refuted at some world of a temporal Gödel–Löb model with at most $2^{\mathrm{sub}(A)}$ worlds, where $\mathrm{sub}(A)$ is the number of distinct subformulas of $A$; a fortiori the bound $2^{2\,\mathrm{sub}(A)}$ holds. Consequently derivability in $\mathsf{TGL}$ is decidable by exhaustive bounded model search, and $\mathsf{TGL}$ is sound and weakly complete for its frame class.

The proof combines two constructions that share a single pair of relations. The first is a **converse-well-foundedness-preserving filtration** whose accessibility relation strictly increases a counting measure — the number of realised boxed subformulas — thereby recovering Löb's condition on the quotient; and whose temporal relation carries an additional $\Box$-persistence clause, without which the compatibility condition provably fails to survive quotienting. The second is a **finite canonical model over the subformula closure**, needed because Gödel–Löb logic admits no legal infinite canonical frame. Its two existence lemmas are the mathematical core: the $\Box$-lemma runs the classical Löb argument, and the $\blacksquare$-lemma consumes $\blacksquare$-necessitation, transitivity of $\blacksquare$, and the interaction axiom.

We also record structural corollaries: transitivity $\Box A \to \Box\Box A$ is derivable from Löb's axiom (no transitivity axiom is postulated); Löb's rule is admissible; the object-language consistency statement $\Box\bot \to \bot$ is not a theorem (Gödel's second incompleteness theorem); and the two modalities do not collapse in either direction. Finally we quantify the slack in the bound: on $\Box\bot \to \bot$ and $\blacksquare p \to \Box p$ the minimal countermodels have $1$ and $2$ worlds against permitted bounds of $64$ and $256$, and we isolate the reason — the exponential factor is entirely *width*, whereas *depth* is already linearly bounded by the counting measure.

**Keywords.** Provability logic; Gödel–Löb logic; temporal logic; Löb's theorem; filtration; finite model property; canonical model; decidability.

---

## 1. Introduction

### 1.1 Provability as a modality

Gödel's arithmetisation of syntax makes a sufficiently strong arithmetical theory capable of expressing a provability predicate $\mathrm{Prov}(x)$. The Hilbert–Bernays–Löb derivability conditions isolate three properties of this predicate that suffice for the incompleteness phenomena, and *provability logic* abstracts them into a modal operator $\Box$:

1. **Distribution.** $\vdash \Box(A \to B) \to (\Box A \to \Box B)$.
2. **Necessitation.** $\vdash A$ implies $\vdash \Box A$.
3. **Löb's axiom.** $\vdash \Box(\Box A \to A) \to \Box A$.

The resulting system is **Gödel–Löb logic** $\mathsf{GL}$. Its Kripke semantics is exceptionally clean: $\mathsf{GL}$ is sound and complete for the class of frames whose accessibility relation is transitive and converse well-founded (no infinite ascending chain $w_0 \mathrel{R} w_1 \mathrel{R} \cdots$). On a finite carrier, transitivity plus converse well-foundedness is equivalent to transitivity plus irreflexivity.

### 1.2 Adding a temporal dimension

A provability predicate is attached to a *fixed* theory. When the theory grows — new axioms, new lemmas, an evolving corpus — one wants a second modality tracking time. We write $\blacksquare A$ for "$A$ holds now and at every future moment", interpreted along a preorder $T$.

The interesting content is in how the two operators interact. We adopt the frame condition

$$w \mathrel{T} w' \ \text{and}\ w' \mathrel{R} v \implies w \mathrel{R} v,$$

read as: *the provability horizon does not widen with time*. Its syntactic counterpart is the axiom $\Box A \to \blacksquare\Box A$: **what is provable now remains provable forever.** This axiom is not an ornament. It is the pivot on which both halves of our main proof turn.

### 1.3 The problem and the result

For a modal logic, the *finite model property* asserts that every non-theorem is refuted in some finite model. An *explicitly bounded* finite model property additionally names a computable function $f$ such that a countermodel with at most $f(A)$ worlds always exists; this is what converts semantic search into an algorithm.

Let $\mathrm{sub}(A)$ be the number of distinct subformulas of $A$ (including $A$ itself).

> **Main Theorem.** If $A$ is not derivable in $\mathsf{TGL}$, then there is a temporal Gödel–Löb model $N$ with a finite world set, $|N| \le 2^{\mathrm{sub}(A)}$, and a world $v$ of $N$ at which $A$ fails. In particular $|N| \le 2^{2\,\mathrm{sub}(A)}$.

Two obstacles stand in the way, and both are genuine.

**Obstacle 1 (filtration and compatibility).** The standard method for bounding countermodel size is filtration through the subformulas of $A$. For $\mathsf{GL}$ this is classical, using Segerberg's strictness clause. But the *naive* filtration of the temporal relation does **not** preserve the compatibility condition. The repair is to strengthen the filtered temporal relation with a $\Box$-persistence clause; this is sound precisely because compatibility holds upstream. This was the only genuine definitional obstruction we encountered.

**Obstacle 2 (no infinite canonical model).** Filtration shrinks an *existing* countermodel. To pass from "not derivable" to "has a countermodel" one needs completeness, and the standard canonical model of maximal consistent sets is illegal for $\mathsf{GL}$: its accessibility relation is not converse well-founded. We therefore build a **finite canonical model over the subformula closure of a single formula**, using the *same* filtration relations, and prove the two existence lemmas directly.

### 1.4 Organisation

Section 2 fixes the language, frames and calculus, and proves soundness. Section 3 develops the filtration and the counting measure. Section 4 constructs the finite canonical model and proves completeness. Section 5 assembles the main theorem and the decision procedure. Section 6 records structural corollaries and non-degeneracy. Section 7 gives the algorithms explicitly. Section 8 quantifies the slack in the bound. Section 9 discusses future directions.

---

## 2. The system $\mathsf{TGL}$

### 2.1 Syntax

**Definition 2.1 (Formulas).** The set of formulas is generated by
$$A ::= p_n \ \mid\ \bot \ \mid\ (A \to A) \ \mid\ \Box A \ \mid\ \blacksquare A, \qquad n \in \mathbb{N}.$$
We abbreviate $\lnot A := A \to \bot$, $A \wedge B := \lnot(A \to \lnot B)$, $A \vee B := \lnot A \to B$.

**Definition 2.2 (Subformulas).** $\mathrm{Sub}(A)$ is defined by recursion:
$$\mathrm{Sub}(p) = \{p\},\quad \mathrm{Sub}(\bot) = \{\bot\},\quad \mathrm{Sub}(B \to C) = \{B \to C\} \cup \mathrm{Sub}(B) \cup \mathrm{Sub}(C),$$
$$\mathrm{Sub}(\Box B) = \{\Box B\} \cup \mathrm{Sub}(B),\qquad \mathrm{Sub}(\blacksquare B) = \{\blacksquare B\} \cup \mathrm{Sub}(B).$$
We put $\mathrm{sub}(A) := |\mathrm{Sub}(A)|$.

**Lemma 2.3.** $A \in \mathrm{Sub}(A)$; if $B \in \mathrm{Sub}(A)$ then $\mathrm{Sub}(B) \subseteq \mathrm{Sub}(A)$; and $1 \le \mathrm{sub}(A) \le |A|$, where $|A|$ is the number of nodes of the syntax tree.

*Proof.* Induction on $A$. The middle claim gives the three immediate-subformula facts used constantly below: from $(B \to C) \in \mathrm{Sub}(A)$ infer $B, C \in \mathrm{Sub}(A)$; from $\Box B \in \mathrm{Sub}(A)$ infer $B \in \mathrm{Sub}(A)$; from $\blacksquare B \in \mathrm{Sub}(A)$ infer $B \in \mathrm{Sub}(A)$. The size bound follows from $|X \cup Y| \le |X| + |Y|$ and $|\{a\} \cup X| \le |X| + 1$. $\square$

Because $\mathrm{sub}(A) \le |A|$, every bound stated with $\mathrm{sub}$ also holds with syntactic size, so nothing is lost by using the sharper parameter.

### 2.2 Frames and models

**Definition 2.4 (Temporal Gödel–Löb frame).** A **temporal Gödel–Löb frame** is a triple $F = (W, R, T)$ with $W$ a set and $R, T \subseteq W \times W$ such that:

- **(R-trans)** $R$ is transitive;
- **(R-wf)** $R$ is converse well-founded: there is no infinite chain $w_0 \mathrel{R} w_1 \mathrel{R} w_2 \mathrel{R} \cdots$; equivalently every non-empty subset of $W$ has an $R$-maximal element;
- **(T-refl)** $T$ is reflexive;
- **(T-trans)** $T$ is transitive;
- **(compat)** if $w \mathrel{T} w'$ and $w' \mathrel{R} v$ then $w \mathrel{R} v$.

A **model** $M = (F, V)$ adds a valuation $V : \mathbb{N} \to \mathcal{P}(W)$.

**Definition 2.5 (Satisfaction).**
$$M, w \Vdash p \iff w \in V(p); \qquad M, w \nVdash \bot;$$
$$M, w \Vdash B \to C \iff (M, w \Vdash B \Rightarrow M, w \Vdash C);$$
$$M, w \Vdash \Box B \iff \forall v\,(w \mathrel{R} v \Rightarrow M, v \Vdash B);$$
$$M, w \Vdash \blacksquare B \iff \forall v\,(w \mathrel{T} v \Rightarrow M, v \Vdash B).$$
$A$ is **valid**, written $\models A$, when $M, w \Vdash A$ for every model $M$ and world $w$.

Observe that (R-wf) forbids $w \mathrel{R} w$: a reflexive point would generate an infinite chain. Hence on a finite carrier, (R-trans) and (R-wf) together say exactly that $R$ is a strict partial order.

### 2.3 Propositional tautologies of the object language

**Definition 2.6.** For $v : \mathrm{Form} \to \{0,1\}$ define $\mathrm{ev}_v$ by treating atoms and *every* formula of the shape $\Box B$ or $\blacksquare B$ as unanalysed propositional letters:
$$\mathrm{ev}_v(p) = v(p),\quad \mathrm{ev}_v(\bot) = 0,\quad \mathrm{ev}_v(B \to C) = \mathrm{ev}_v(B) \Rightarrow \mathrm{ev}_v(C),$$
$$\mathrm{ev}_v(\Box B) = v(\Box B),\qquad \mathrm{ev}_v(\blacksquare B) = v(\blacksquare B).$$
$A$ is a **tautology** if $\mathrm{ev}_v(A) = 1$ for all $v$.

**Lemma 2.7.** For every model $M$ and world $w$, $M, w \Vdash A$ iff $\mathrm{ev}_{v_w}(A) = 1$, where $v_w(B) := [M, w \Vdash B]$. Consequently every tautology is valid.

*Proof.* Induction on $A$; the modal cases are definitional identities. $\square$

### 2.4 The calculus

**Definition 2.8 ($\mathsf{TGL}$).** $\vdash A$ is generated by:

| | |
|---|---|
| **Taut** | every propositional tautology in the sense of Definition 2.6 |
| **MP** | from $\vdash A \to B$ and $\vdash A$ infer $\vdash B$ |
| **K$_\Box$** | $\vdash \Box(A \to B) \to (\Box A \to \Box B)$ |
| **Löb** | $\vdash \Box(\Box A \to A) \to \Box A$ |
| **K$_\blacksquare$** | $\vdash \blacksquare(A \to B) \to (\blacksquare A \to \blacksquare B)$ |
| **T$_\blacksquare$** | $\vdash \blacksquare A \to A$ |
| **4$_\blacksquare$** | $\vdash \blacksquare A \to \blacksquare\blacksquare A$ |
| **Int** | $\vdash \Box A \to \blacksquare\Box A$ |
| **Nec$_\Box$** | from $\vdash A$ infer $\vdash \Box A$ |
| **Nec$_\blacksquare$** | from $\vdash A$ infer $\vdash \blacksquare A$ |

No transitivity axiom for $\Box$ is postulated.

**Theorem 2.9 (Soundness).** If $\vdash A$ then $\models A$.

*Proof.* Induction on the derivation. **Taut** is Lemma 2.7. **MP** is immediate. **K$_\Box$**, **K$_\blacksquare$** are pointwise. **T$_\blacksquare$** uses (T-refl), **4$_\blacksquare$** uses (T-trans), **Int** uses (compat): if $M, w \Vdash \Box A$, $w \mathrel{T} w'$ and $w' \mathrel{R} v$, then $w \mathrel{R} v$ by (compat), so $M, v \Vdash A$; hence $M, w' \Vdash \Box A$ and thus $M, w \Vdash \blacksquare\Box A$. Both necessitation rules are immediate from the induction hypothesis.

For **Löb**, suppose $M, w \Vdash \Box(\Box A \to A)$ but $M, w \nVdash \Box A$. The set $X = \{v : w \mathrel{R} v,\ M, v \nVdash A\}$ is non-empty, so by (R-wf) it has an $R$-maximal element $m$. For any $y$ with $m \mathrel{R} y$ we have $w \mathrel{R} y$ by (R-trans), and maximality of $m$ forces $M, y \Vdash A$; hence $M, m \Vdash \Box A$. Since $w \mathrel{R} m$ and $M, w \Vdash \Box(\Box A \to A)$, we get $M, m \Vdash \Box A \to A$, so $M, m \Vdash A$, contradicting $m \in X$. $\square$

**Corollary 2.10 (Consistency and non-triviality).** Let $P$ be the one-world frame with $R = \emptyset$ and $T = \{(\ast,\ast)\}$, with the atom-empty valuation. Then $P$ is a temporal Gödel–Löb frame, and $\nvdash \bot$ and $\nvdash p$ for every atom $p$.

### 2.5 Derivations from hypothesis lists

For the completeness argument we need a sequent-style interface. For a finite list $\Gamma = [x_1,\dots,x_n]$ put $\Gamma \Rightarrow X := x_1 \to (\cdots \to (x_n \to X))$ and define $\Gamma \vdash X$ to mean $\vdash (\Gamma \Rightarrow X)$.

**Lemma 2.11 (Propositional interface).** Because *all* tautologies are axioms, the following hold, each by a single application of **Taut** and **MP** after unwinding the fold:

- (*tautological consequence*) if $\mathrm{ev}_v(x) = 1$ for all $x \in \Gamma$ implies $\mathrm{ev}_v(X) = 1$, for all $v$, then $\Gamma \vdash X$;
- (*assumption*) $x \in \Gamma$ implies $\Gamma \vdash x$;
- (*weakening*) $\Gamma_1 \subseteq \Gamma_2$ and $\Gamma_1 \vdash X$ imply $\Gamma_2 \vdash X$;
- (*modus ponens*) $\Gamma \vdash X \to Y$ and $\Gamma \vdash X$ imply $\Gamma \vdash Y$;
- (*cut*) if $\Gamma \vdash x$ for every $x \in \Delta$ and $\Delta \vdash X$, then $\Gamma \vdash X$;
- (*case analysis*) $B :: \Gamma \vdash X$ and $\lnot B :: \Gamma \vdash X$ imply $\Gamma \vdash X$.

**Lemma 2.12 (Modal distribution over lists).** For every list $\Delta$ and formula $X$,
$$\vdash \Box(\Delta \Rightarrow X) \to (\Box\Delta \Rightarrow \Box X), \qquad \vdash \blacksquare(\Delta \Rightarrow X) \to (\blacksquare\Delta \Rightarrow \blacksquare X),$$
where $\Box\Delta$ is $\Delta$ with $\Box$ prefixed to each member. Consequently:
$$\Delta \vdash X \implies \Box\Delta \vdash \Box X, \qquad \Delta \vdash X \implies \blacksquare\Delta \vdash \blacksquare X.$$

*Proof.* Induction on $\Delta$, the step being one application of **K** composed inside the implication. The consequences follow by **Nec** and **MP**. $\square$

**Definition 2.13.** $\Gamma$ is **consistent** if $\Gamma \nvdash \bot$.

**Lemma 2.14 (Finite Lindenbaum).** For every finite list $L$ and consistent $\Gamma$ there is a consistent $\Gamma' \supseteq \Gamma$ such that for every $B \in L$, either $B \in \Gamma'$ or $\lnot B \in \Gamma'$.

*Proof.* Induction on $L$. At the step $B :: L$: if $B :: \Gamma$ is inconsistent then $\lnot B :: \Gamma$ is consistent by case analysis (Lemma 2.11), and we recurse on that; otherwise recurse on $B :: \Gamma$. $\square$

---

## 3. Filtration

Throughout this section fix a finite set $\mathrm{Cl}$ of formulas. In the application $\mathrm{Cl} = \mathrm{Sub}(A)$.

### 3.1 The two filtered relations

**Definition 3.1.** For $S, S' \subseteq \mathrm{Cl}$ define:

$$S \mathrel{R_{\mathrm{Cl}}} S' \iff \underbrace{\forall B\ \big(\Box B \in \mathrm{Cl} \wedge \Box B \in S \Rightarrow B \in S' \wedge \Box B \in S'\big)}_{\text{(forth)}} \ \wedge\ \underbrace{\exists B\ \big(\Box B \in \mathrm{Cl} \wedge \Box B \in S' \wedge \Box B \notin S\big)}_{\text{(strict)}}$$

$$S \mathrel{T_{\mathrm{Cl}}} S' \iff \underbrace{\forall B\ \big(\blacksquare B \in \mathrm{Cl} \wedge \blacksquare B \in S \Rightarrow B \in S' \wedge \blacksquare B \in S'\big)}_{\text{(forth)}} \ \wedge\ \underbrace{\forall B\ \big(\Box B \in \mathrm{Cl} \wedge \Box B \in S \Rightarrow \Box B \in S'\big)}_{\text{($\Box$-persistence)}}$$

The clause **(strict)** is Segerberg's device; it is what will yield converse well-foundedness. The clause **($\Box$-persistence)** is the repair for Obstacle 1.

**Lemma 3.2.** $R_{\mathrm{Cl}}$ and $T_{\mathrm{Cl}}$ are transitive.

*Proof.* For $R_{\mathrm{Cl}}$: (forth) composes because (forth) delivers not only $B$ but also $\Box B$ at the successor; (strict) is inherited from the *first* step, whose witness $\Box B$ is carried forward to $S_3$ by (forth) of the second step. For $T_{\mathrm{Cl}}$: both clauses compose in the same way. $\square$

**Lemma 3.3 (Compatibility survives).** If $S \mathrel{T_{\mathrm{Cl}}} S_1$ and $S_1 \mathrel{R_{\mathrm{Cl}}} S_2$ then $S \mathrel{R_{\mathrm{Cl}}} S_2$.

*Proof.* (forth): if $\Box B \in \mathrm{Cl} \cap S$, then $\Box B \in S_1$ by ($\Box$-persistence), whence $B, \Box B \in S_2$ by (forth) of $R_{\mathrm{Cl}}$. (strict): take the witness $\Box B \in S_2 \setminus S_1$ supplied by $S_1 \mathrel{R_{\mathrm{Cl}}} S_2$. Then $\Box B \notin S$, for otherwise ($\Box$-persistence) would place $\Box B$ in $S_1$. $\square$

This lemma is exactly where the extra clause pays for itself. Without ($\Box$-persistence) the argument breaks in both parts, and compatibility genuinely fails on the quotient.

### 3.2 The counting measure

**Definition 3.4.** Let $\mathrm{Box}(\mathrm{Cl}) := \{C \in \mathrm{Cl} : C \text{ is of the form } \Box D\}$ and, for $S \subseteq \mathrm{Cl}$,
$$\beta(S) := |\{C \in \mathrm{Box}(\mathrm{Cl}) : C \in S\}| \ \le\ |\mathrm{Box}(\mathrm{Cl})|.$$

**Theorem 3.5 (Strict growth).** If $S \mathrel{R_{\mathrm{Cl}}} S'$ then $\beta(S) < \beta(S')$.

*Proof.* By (forth), every $\Box D \in \mathrm{Box}(\mathrm{Cl})$ lying in $S$ also lies in $S'$, so the counted set for $S$ is a subset of that for $S'$. By (strict) there is $\Box B \in \mathrm{Box}(\mathrm{Cl})$ in $S'$ but not $S$, so the inclusion is proper, and cardinality strictly increases. $\square$

**Corollary 3.6 (Converse well-foundedness by counting).** For any type $\alpha$ and any map $f : \alpha \to \mathcal{P}(\mathrm{Cl})$, the relation $a \prec b :\iff f(b) \mathrel{R_{\mathrm{Cl}}} f(a)$ is well-founded.

*Proof.* $a \prec b$ implies $|\mathrm{Box}(\mathrm{Cl})| - \beta(f(a)) < |\mathrm{Box}(\mathrm{Cl})| - \beta(f(b))$ by Theorem 3.5 and $\beta \le |\mathrm{Box}(\mathrm{Cl})|$. So $\prec$ embeds into $<$ on $\mathbb{N}$. $\square$

Corollary 3.6 is the combinatorial heart of the entire development. It says that *any* structure whose accessibility relation is pulled back from $R_{\mathrm{Cl}}$ automatically validates Löb's axiom, and it simultaneously bounds the **depth** of such a structure by $|\mathrm{Box}(\mathrm{Cl})|$: no $R$-chain has more than $|\mathrm{Box}(\mathrm{Cl})|$ steps. We return to this in Section 8.

### 3.3 The filtered model

Fix a model $M$ and a formula $A$; put $\mathrm{Cl} := \mathrm{Sub}(A)$.

**Definition 3.7.** For $u \in W$ let the **subformula theory** be
$$\theta(u) := \{B \in \mathrm{Sub}(A) : M, u \Vdash B\} \subseteq \mathrm{Sub}(A).$$
Let $W^\ast := \{\theta(u) : u \in W\}$, and define the filtered frame $F^\ast := (W^\ast, R_{\mathrm{Cl}}, T_{\mathrm{Cl}})$ with valuation $V^\ast(p) := \{S \in W^\ast : p \in S\}$.

**Theorem 3.8.** $F^\ast$ is a temporal Gödel–Löb frame.

*Proof.* (R-trans), (T-trans) are Lemma 3.2; (compat) is Lemma 3.3; (R-wf) is Corollary 3.6 applied to the inclusion $W^\ast \hookrightarrow \mathcal{P}(\mathrm{Cl})$. For (T-refl), let $S = \theta(u)$ and check both clauses of $T_{\mathrm{Cl}}$ with $S' = S$: if $\blacksquare B \in \mathrm{Sub}(A) \cap S$ then $M, u \Vdash \blacksquare B$, so $M, u \Vdash B$ by (T-refl) upstream, and $B \in \mathrm{Sub}(A)$ by Lemma 2.3, so $B \in S$; ($\Box$-persistence) is trivial for $S' = S$. $\square$

**Theorem 3.9 (Filtration lemma).** For every $B \in \mathrm{Sub}(A)$ and every $u \in W$,
$$F^\ast, V^\ast, \theta(u) \Vdash B \iff M, u \Vdash B.$$

*Proof.* Induction on $B$.

*Atoms:* $\theta(u) \in V^\ast(p)$ iff $p \in \theta(u)$ iff $M, u \Vdash p$ (using $p \in \mathrm{Sub}(A)$). *Falsity:* both sides false. *Implication:* immediate from the induction hypotheses at the two immediate subformulas, which lie in $\mathrm{Sub}(A)$ by Lemma 2.3.

*Box, right-to-left ($\Leftarrow$):* assume $M, u \Vdash \Box B$, so $\Box B \in \theta(u)$. Let $\theta(u) \mathrel{R_{\mathrm{Cl}}} S'$, and choose $v$ with $S' = \theta(v)$. By (forth), $B \in \theta(v)$, i.e. $M, v \Vdash B$; apply the induction hypothesis.

*Box, left-to-right ($\Rightarrow$):* assume $\theta(u) \Vdash \Box B$ in the quotient but $M, u \nVdash \Box B$. Then $X := \{x : u \mathrel{R} x,\ M, x \nVdash B\} \ne \emptyset$; by (R-wf) upstream choose $m$ $R$-maximal in $X$. Maximality plus (R-trans) give $M, m \Vdash \Box B$. We claim $\theta(u) \mathrel{R_{\mathrm{Cl}}} \theta(m)$. For (forth): if $\Box D \in \mathrm{Sub}(A) \cap \theta(u)$ then $M, u \Vdash \Box D$; since $u \mathrel{R} m$ we get $M, m \Vdash D$, and for any $y$ with $m \mathrel{R} y$ we get $u \mathrel{R} y$ by transitivity, so $M, m \Vdash \Box D$; both $D$ and $\Box D$ lie in $\mathrm{Sub}(A)$. For (strict): $\Box B \in \theta(m)$ by the claim above, while $\Box B \notin \theta(u)$ by assumption. Hence $\theta(m)$ is an $R_{\mathrm{Cl}}$-successor of $\theta(u)$, so $\theta(m) \Vdash B$ in the quotient, so $M, m \Vdash B$ by induction hypothesis, contradicting $m \in X$.

*Temporal box, $\Leftarrow$:* as in the box case, using (forth) of $T_{\mathrm{Cl}}$.

*Temporal box, $\Rightarrow$:* assume $\theta(u) \Vdash \blacksquare B$ but $M, u \nVdash \blacksquare B$; pick $x$ with $u \mathrel{T} x$ and $M, x \nVdash B$. We check $\theta(u) \mathrel{T_{\mathrm{Cl}}} \theta(x)$. (forth): if $\blacksquare D \in \mathrm{Sub}(A) \cap \theta(u)$ then $M, x \Vdash D$ since $u \mathrel{T} x$, and $M, x \Vdash \blacksquare D$ by (T-trans). ($\Box$-persistence): if $\Box D \in \mathrm{Sub}(A) \cap \theta(u)$ and $x \mathrel{R} y$, then $u \mathrel{R} y$ by **(compat)**, so $M, y \Vdash D$; hence $M, x \Vdash \Box D$. Therefore $\theta(x) \Vdash B$ in the quotient, so $M, x \Vdash B$ by induction hypothesis — contradiction. $\square$

Note where each frame condition is spent: (R-wf) upstream in the $\Box$ case, (T-trans) and **(compat)** upstream in the $\blacksquare$ case. The clause ($\Box$-persistence) is *available* exactly because (compat) holds in $M$.

**Theorem 3.10 (Small model property).** If $M, w \nVdash A$ then there is a temporal Gödel–Löb model $N$ with $|N| \le 2^{\mathrm{sub}(A)}$ and a world $v$ with $N, v \nVdash A$.

*Proof.* Take $N = (F^\ast, V^\ast)$ and $v = \theta(w)$. Since $W^\ast \subseteq \mathcal{P}(\mathrm{Sub}(A))$ we have $|W^\ast| \le 2^{\mathrm{sub}(A)}$, and $A \in \mathrm{Sub}(A)$, so Theorem 3.9 transfers the failure. $\square$

**Corollary 3.11 (Bounded semantic test).** $\models A$ if and only if $A$ holds at every world of every temporal Gödel–Löb model with at most $2^{2\,\mathrm{sub}(A)}$ worlds.

*Proof.* Left to right is trivial. Right to left: if $A$ fails somewhere, Theorem 3.10 produces a failure in a model of size at most $2^{\mathrm{sub}(A)} \le 2^{2\,\mathrm{sub}(A)}$. $\square$

Corollary 3.11 already justifies reading a *successful* exhaustive bounded search as a proof of validity — and, via Theorem 2.9, of non-derivability whenever a countermodel is found. What it does not yet give is the converse packaging: that a *non-derivable* formula must have a small countermodel. For that we need completeness.

---

## 4. Completeness via a finite canonical model

### 4.1 Why the usual canonical model fails

The classical route to completeness builds a model whose worlds are all maximal consistent sets, with $\Gamma \mathrel{R} \Delta$ iff $\{B, \Box B : \Box B \in \Gamma\} \subseteq \Delta$. For $\mathsf{GL}$ this relation is transitive but **not** converse well-founded, so the canonical frame is not a member of the frame class and the argument collapses. The standard remedy is to work over a finite closure. We do so, and — economically — we reuse the relations of Section 3, so that Corollary 3.6 hands us (R-wf) for free.

### 4.2 Closures, decided subsets, worlds

**Definition 4.1.** A finite set $\mathrm{Cl}$ of formulas is **closed** if: $(B \to C) \in \mathrm{Cl}$ implies $B, C \in \mathrm{Cl}$; $\Box B \in \mathrm{Cl}$ implies $B \in \mathrm{Cl}$; $\blacksquare B \in \mathrm{Cl}$ implies $B \in \mathrm{Cl}$.

**Lemma 4.2.** $\mathrm{Sub}(A)$ is closed. *(Lemma 2.3.)*

**Definition 4.3.** For $t \subseteq \mathrm{Cl}$ let
$$\gamma(t) := \big[\,\text{$B$ for each $B \in t$}\,\big] \ ^\frown\ \big[\,\lnot B \text{ for each } B \in \mathrm{Cl}\setminus t\,\big]$$
(formally: the list obtained from an enumeration of $\mathrm{Cl}$ by mapping $B \mapsto B$ if $B \in t$ and $B \mapsto \lnot B$ otherwise). Say $t$ is a **world of $\mathrm{Cl}$** when $\gamma(t)$ is consistent. Write $\mathcal{W}(\mathrm{Cl})$ for the (finite) set of worlds.

**Lemma 4.4 (Closure under derivation inside $\mathrm{Cl}$).** If $t \in \mathcal{W}(\mathrm{Cl})$, $B \in \mathrm{Cl}$ and $\gamma(t) \vdash B$, then $B \in t$.

*Proof.* If $B \notin t$ then $\lnot B \in \gamma(t)$, so $\gamma(t) \vdash \bot$ by modus ponens, contradicting consistency. $\square$

**Lemma 4.5 (Lindenbaum for a finite closure).** If $\Gamma$ is consistent then there is $t \in \mathcal{W}(\mathrm{Cl})$ with $x \in t$ for every $x \in \Gamma \cap \mathrm{Cl}$, and $B \notin t$ whenever $\lnot B \in \Gamma$.

*Proof.* Apply Lemma 2.14 with $L$ an enumeration of $\mathrm{Cl}$, obtaining a consistent $\Gamma' \supseteq \Gamma$ deciding every member of $\mathrm{Cl}$. Put $t := \{B \in \mathrm{Cl} : B \in \Gamma'\}$. Every member of $\gamma(t)$ belongs to $\Gamma'$ — positively by construction, negatively because $\Gamma'$ decides $\mathrm{Cl}$ — so weakening shows $\gamma(t)$ consistent. The two stated properties are immediate, the second because a consistent list cannot contain both $B$ and $\lnot B$. $\square$

$|\mathcal{W}(\mathrm{Cl})| \le 2^{|\mathrm{Cl}|}$, since worlds are subsets of $\mathrm{Cl}$. That inequality is where the final bound comes from.

### 4.3 The two existence lemmas

These are the mathematical core. Fix a closed $\mathrm{Cl}$ and $t \in \mathcal{W}(\mathrm{Cl})$.

**Theorem 4.6 (Existence lemma for $\Box$; the Löb argument).** If $\Box B \in \mathrm{Cl}$ and $\Box B \notin t$, then there is $s \in \mathcal{W}(\mathrm{Cl})$ with $t \mathrel{R_{\mathrm{Cl}}} s$ and $B \notin s$.

*Proof.* Let $D_0 := [\Box D : \Box D \in \mathrm{Cl} \cap t]$ be the list of boxed members of $t$, let
$$D_1 := [D : \Box D \in D_0] \ ^\frown\ D_0, \qquad D_2 := D_1 \ ^\frown\ [\Box B,\ \lnot B].$$

*Claim: $D_2$ is consistent.* Suppose $D_2 \vdash \bot$. Since $D_2 = D_1 ^\frown [\Box B, \lnot B]$, tautological reasoning (Lemma 2.11) converts this into
$$D_1 \vdash \Box B \to B.$$
Apply $\Box$-distribution over lists (Lemma 2.12):
$$\Box D_1 \vdash \Box(\Box B \to B),$$
and then **Löb's axiom** with modus ponens:
$$\Box D_1 \vdash \Box B .$$
Now every member of $\Box D_1$ is derivable from $\gamma(t)$:

- the first half of $D_1$ consists of the un-boxed $D$'s, so boxing yields $\Box D$ with $\Box D \in \mathrm{Cl} \cap t$: this is literally an assumption of $\gamma(t)$;
- the second half of $D_1$ is $D_0$ itself, so boxing yields $\Box\Box D$: here we use the **derived transitivity** $\vdash \Box D \to \Box\Box D$ (Theorem 6.1 below) applied to the assumption $\Box D \in \gamma(t)$.

By **cut** (Lemma 2.11), $\gamma(t) \vdash \Box B$, so $\Box B \in t$ by Lemma 4.4 — contradicting the hypothesis. This proves the claim.

By Lemma 4.5 there is $s \in \mathcal{W}(\mathrm{Cl})$ containing every member of $D_2 \cap \mathrm{Cl}$ and omitting $B$ (since $\lnot B \in D_2$). Then:

- (forth) for $t \mathrel{R_{\mathrm{Cl}}} s$: if $\Box E \in \mathrm{Cl} \cap t$ then both $\Box E$ and $E$ occur in $D_2$, and both lie in $\mathrm{Cl}$ (using closedness for $E$), hence both lie in $s$;
- (strict): $\Box B \in D_2 \cap \mathrm{Cl}$ so $\Box B \in s$, while $\Box B \notin t$.

Finally $B \notin s$. $\square$

The shape of this argument is worth emphasising. Löb's axiom, which makes the *infinite* canonical model illegal, is precisely the tool that makes the *finite* one work: it is what licenses adding $\Box B$ itself to the successor's hypothesis list, which is in turn what supplies the (strict) clause.

**Theorem 4.7 (Existence lemma for $\blacksquare$).** If $\blacksquare B \in \mathrm{Cl}$ and $\blacksquare B \notin t$, then there is $s \in \mathcal{W}(\mathrm{Cl})$ with $t \mathrel{T_{\mathrm{Cl}}} s$ and $B \notin s$.

*Proof.* Let $G_0 := [\blacksquare D : \blacksquare D \in \mathrm{Cl} \cap t]$ and $B_0 := [\Box D : \Box D \in \mathrm{Cl} \cap t]$, and set
$$D_1 := [D : \blacksquare D \in G_0] \ ^\frown\ G_0 \ ^\frown\ B_0, \qquad D_2 := D_1 \ ^\frown\ [\lnot B].$$

*Claim: $D_2$ is consistent.* If $D_2 \vdash \bot$ then tautologically $D_1 \vdash B$, hence by $\blacksquare$-distribution $\blacksquare D_1 \vdash \blacksquare B$. Each member of $\blacksquare D_1$ is derivable from $\gamma(t)$:

- $\blacksquare D$ where $\blacksquare D \in \mathrm{Cl} \cap t$: an assumption of $\gamma(t)$;
- $\blacksquare\blacksquare D$ where $\blacksquare D \in \mathrm{Cl} \cap t$: from **4$_\blacksquare$**;
- $\blacksquare\Box D$ where $\Box D \in \mathrm{Cl} \cap t$: from the **interaction axiom** $\Box D \to \blacksquare\Box D$.

By cut, $\gamma(t) \vdash \blacksquare B$, so $\blacksquare B \in t$ by Lemma 4.4 — contradiction.

By Lemma 4.5 pick $s \in \mathcal{W}(\mathrm{Cl})$ containing $D_2 \cap \mathrm{Cl}$ and omitting $B$. Then (forth) of $T_{\mathrm{Cl}}$ holds because $D_2$ contains both $\blacksquare E$ and $E$ for each $\blacksquare E \in \mathrm{Cl} \cap t$; and ($\Box$-persistence) holds because $D_2$ contains $B_0$, i.e. every $\Box E \in \mathrm{Cl} \cap t$. $\square$

The three fuels used here — $\blacksquare$-necessitation, **4$_\blacksquare$**, and **Int** — are in exact correspondence with the three demands made by $T_{\mathrm{Cl}}$: transmit $E$, transmit $\blacksquare E$, transmit $\Box E$.

### 4.4 The finite canonical model

**Definition 4.8.** For closed $\mathrm{Cl}$ let $F^{\mathrm{can}} := (\mathcal{W}(\mathrm{Cl}), R_{\mathrm{Cl}}, T_{\mathrm{Cl}})$ with $V^{\mathrm{can}}(p) := \{t : p \in t\}$.

**Theorem 4.9.** $F^{\mathrm{can}}$ is a temporal Gödel–Löb frame.

*Proof.* Transitivity of both relations is Lemma 3.2; (compat) is Lemma 3.3; (R-wf) is Corollary 3.6. For (T-refl) take $t$ and check $t \mathrel{T_{\mathrm{Cl}}} t$: ($\Box$-persistence) is trivial, and for (forth), if $\blacksquare E \in \mathrm{Cl} \cap t$ then $\gamma(t) \vdash E$ by **T$_\blacksquare$** and the assumption $\blacksquare E$, so $E \in t$ by Lemma 4.4 (using $E \in \mathrm{Cl}$ from closedness). $\square$

Notice that (T-refl) is the *only* frame condition here that needs a syntactic argument; everything else is inherited from the abstract properties of $R_{\mathrm{Cl}}, T_{\mathrm{Cl}}$ established in Section 3.

**Theorem 4.10 (Truth lemma).** For every $B \in \mathrm{Cl}$ and $t \in \mathcal{W}(\mathrm{Cl})$:
$$F^{\mathrm{can}}, V^{\mathrm{can}}, t \Vdash B \iff B \in t.$$

*Proof.* Induction on $B$.

*Atoms:* by definition of $V^{\mathrm{can}}$. *Falsity:* $\bot \notin t$, since $\bot \in t$ would put $\bot$ in $\gamma(t)$ and destroy consistency.

*Implication $B \to C$ (with $B, C \in \mathrm{Cl}$ by closedness):* ($\Rightarrow$) Suppose $t \Vdash B \to C$. If $B \in t$ then $t \Vdash B$ by induction hypothesis, so $t \Vdash C$, so $C \in t$; then $\gamma(t) \vdash B \to C$ tautologically from the assumption $C$. If $B \notin t$ then $\lnot B \in \gamma(t)$ and $\gamma(t) \vdash B \to C$ tautologically. Either way Lemma 4.4 gives $B \to C \in t$. ($\Leftarrow$) Suppose $B \to C \in t$ and $t \Vdash B$. Then $B \in t$ by induction hypothesis, so $\gamma(t) \vdash C$ by modus ponens on assumptions, so $C \in t$, so $t \Vdash C$.

*$\Box B$:* ($\Leftarrow$) if $\Box B \in t$ and $t \mathrel{R_{\mathrm{Cl}}} s$, then $B \in s$ by (forth), so $s \Vdash B$ by induction hypothesis. ($\Rightarrow$) contrapositive: if $\Box B \notin t$, Theorem 4.6 supplies $s$ with $t \mathrel{R_{\mathrm{Cl}}} s$ and $B \notin s$; by induction hypothesis $s \nVdash B$, so $t \nVdash \Box B$.

*$\blacksquare B$:* identical, using Theorem 4.7. $\square$

**Theorem 4.11 (Weak completeness).** If $\models A$ then $\vdash A$.

*Proof.* Suppose $\nvdash A$. Then $[\lnot A]$ is consistent: if $[\lnot A] \vdash \bot$, i.e. $\vdash \lnot A \to \bot$, then $\vdash A$ by the tautology $(\lnot A \to \bot) \to A$. Apply Lemma 4.5 with $\mathrm{Cl} = \mathrm{Sub}(A)$ to obtain $t \in \mathcal{W}(\mathrm{Sub}(A))$ with $A \notin t$. By Theorem 4.10, $t \nVdash A$ in the finite canonical model, which is a legal model by Theorem 4.9. Hence $\nvDash A$. $\square$

**Corollary 4.12.** $\vdash A \iff \models A$.

---

## 5. The main theorem

**Theorem 5.1 (Finite model property, sharp form).** If $\nvdash A$ then there is a temporal Gödel–Löb model $N$ with finite world set, $|N| \le 2^{\mathrm{sub}(A)}$, and a world $v$ with $N, v \nVdash A$.

*Proof.* As in Theorem 4.11, obtain $t \in \mathcal{W}(\mathrm{Sub}(A))$ with $A \notin t$; by Theorem 4.10 the finite canonical model over $\mathrm{Sub}(A)$ refutes $A$ at $t$. Its worlds are subsets of $\mathrm{Sub}(A)$, so there are at most $2^{|\mathrm{Sub}(A)|} = 2^{\mathrm{sub}(A)}$ of them. $\square$

**Theorem 5.2 (The bound as conjectured).** If $\nvdash A$ then $A$ has a temporal Gödel–Löb countermodel with at most $2^{2\,\mathrm{sub}(A)}$ worlds.

*Proof.* $2^{\mathrm{sub}(A)} \le 2^{2\,\mathrm{sub}(A)}$. Alternatively: completeness turns $\nvdash A$ into a countermodel, and Theorem 3.10 shrinks it. $\square$

**Theorem 5.3 (Decision procedure).**
$$\vdash A \iff \text{$A$ holds at every world of every temporal Gödel–Löb model with at most } 2^{2\,\mathrm{sub}(A)} \text{ worlds.}$$

*Proof.* Combine Corollary 4.12 with Corollary 3.11. $\square$

Since for a fixed finite carrier there are only finitely many pairs of relations and finitely many valuations of the (finitely many) atoms of $A$, the right-hand side of Theorem 5.3 is a finite, mechanically checkable condition. Hence:

**Corollary 5.4.** Derivability in $\mathsf{TGL}$ is decidable.

**Theorem 5.5 (One-sided soundness of search).** If $A$ has *no* countermodel with at most $2^{2\,\mathrm{sub}(A)}$ worlds, then $\models A$; and if $A$ fails at some world of some model whatsoever, then $\nvdash A$ and $A$ already fails in a model of at most $2^{2\,\mathrm{sub}(A)}$ worlds.

Theorem 5.5 records that the two directions of the search have different logical costs: the "no countermodel $\Rightarrow$ valid" direction is pure filtration and needs no completeness at all, while the "$\nvdash A \Rightarrow$ small countermodel" direction is exactly where completeness enters.

---

## 6. Structural corollaries and non-degeneracy

**Theorem 6.1 (Transitivity from Löb).** $\vdash \Box A \to \Box\Box A$, with no transitivity axiom assumed.

*Proof.* Put $C := A \wedge \Box A$. Both $C \to \Box A$ and $C \to A$ are tautologies (in the sense of Definition 2.6, with $\Box A$ read as an atom), hence theorems; boxing them via $\mathrm{Nec}_\Box$ and $\mathrm{K}_\Box$ gives
$$\vdash \Box C \to \Box\Box A \qquad\text{and}\qquad \vdash \Box C \to \Box A .$$
From the second, propositional reasoning yields $\vdash A \to (\Box C \to C)$ — indeed if $A$ and $\Box C$ hold then $\Box A$ holds by the second theorem, so $A \wedge \Box A = C$ holds. Boxing this gives $\vdash \Box A \to \Box(\Box C \to C)$, and **Löb** turns the consequent into $\Box C$:
$$\vdash \Box A \to \Box C.$$
Chaining with $\vdash \Box C \to \Box\Box A$ gives the result. $\square$

**Theorem 6.2 (Löb's rule).** If $\vdash \Box A \to A$ then $\vdash A$.

*Proof.* From $\vdash \Box A \to A$, necessitation gives $\vdash \Box(\Box A \to A)$, Löb's axiom gives $\vdash \Box A$, and modus ponens on the hypothesis gives $\vdash A$. $\square$

**Theorem 6.3 (Gödel's second incompleteness theorem, object-language form).** $\nvdash \Box\bot \to \bot$.

*Proof.* Take the one-world frame $P$ of Corollary 2.10, with $R = \emptyset$ and $T$ the identity. Then $\Box\bot$ holds vacuously at the unique world and $\bot$ does not; soundness (Theorem 2.9) finishes. $\square$

**Corollary 6.4.** The consistency statement therefore possesses a countermodel of at most $2^{2\cdot 3} = 64$ worlds; in fact one world suffices, as the proof above exhibits.

**Theorem 6.5 (The modalities do not collapse).** $\nvdash \blacksquare p \to \Box p$ and $\nvdash \Box p \to \blacksquare p$.

*Proof.* For the first, take $W = \{0,1\}$ with $R = \{(1,0)\}$ and $T$ the identity. All frame conditions hold: $R$ is transitive and irreflexive on a two-element set, $T$ is a preorder, and (compat) holds since $w \mathrel{T} w'$ forces $w = w'$. Let $p$ be true exactly at $1$. Then $\blacksquare p$ holds at $1$ (the only future of $1$ is $1$), but $\Box p$ fails at $1$ because $1 \mathrel{R} 0$ and $p$ is false at $0$.

For the second, use the one-world frame $P$ with $p$ false: $\Box p$ holds vacuously, $\blacksquare p$ fails since $\ast \mathrel{T} \ast$. $\square$

Thus $\mathsf{TGL}$ is a genuinely bimodal logic: the interaction axiom links the two boxes without identifying them.

---

## 7. Algorithms

We record the three procedures implicit in the results above.

### 7.1 Exhaustive bounded model search

**Input.** A formula $A$ and a bound $m$ (take $m = 2^{2\,\mathrm{sub}(A)}$ for completeness).
**Output.** A countermodel to $A$ of size $\le m$, or the verdict "valid up to $m$".

```
for n = 1 .. m:
    for each relation R on {0..n-1} that is transitive and irreflexive:
        for each preorder T on {0..n-1}:
            if not compat(R, T): continue
            for each valuation V of the atoms of A over {0..n-1}:
                for each world w:
                    if not sat(R, T, V, A, w): return (R, T, V, w)
return "valid up to m"
```

By Theorem 5.3, with $m = 2^{2\,\mathrm{sub}(A)}$ the verdict "valid up to $m$" is equivalent to $\vdash A$. The cost is dominated by the frame enumeration: $2^{\Theta(n^2)}$ candidates per size, so the procedure is doubly exponential in $\mathrm{sub}(A)$ if run naively at the full bound. It is nevertheless a *correct* algorithm, which is the point of an explicit bound; in practice one runs it at small $n$ and almost always finds a countermodel immediately (Section 8).

### 7.2 Filtration

**Input.** A finite model $M$ and a formula $A$.
**Output.** A model of at most $2^{\mathrm{sub}(A)}$ worlds agreeing with $M$ on all subformulas of $A$.

```
Cl  := Sub(A)
for each world u of M:  theta(u) := { B in Cl : M,u |= B }
W*  := { theta(u) : u in M }                 # de-duplicated
R*  := { (S,S') in W* x W* : FILT-R(Cl,S,S') }
T*  := { (S,S') in W* x W* : FILT-T(Cl,S,S') }
V*(p) := { S in W* : p in S }
return (W*, R*, T*, V*)
```

Complexity: $O(|M| \cdot \mathrm{sub}(A))$ to compute the theories (with memoised satisfaction), then $O(|W^\ast|^2 \cdot \mathrm{sub}(A))$ to build the relations. The output is guaranteed legal by Theorem 3.8 and faithful by Theorem 3.9.

### 7.3 Finite canonical model construction

**Input.** A closed finite set $\mathrm{Cl}$ (typically $\mathrm{Sub}(A)$).
**Output.** The finite canonical model over $\mathrm{Cl}$.

```
worlds := []
for each subset t of Cl:
    if consistent(gamma(Cl,t)):  worlds.append(t)
R := { (t,s) : FILT-R(Cl,t,s) }
T := { (t,s) : FILT-T(Cl,t,s) }
V(p) := { t : p in t }
```

The outer loop is over $2^{|\mathrm{Cl}|}$ subsets, which is exactly where the bound $2^{\mathrm{sub}(A)}$ comes from. The consistency test `consistent` is a derivability question; it can be approximated from above by cheap *coherence* filters that prune most subsets immediately:

- $\bot \notin t$;
- for $(B \to C) \in \mathrm{Cl}$ with $B, C \in \mathrm{Cl}$: $(B \to C) \in t \iff (B \notin t \text{ or } C \in t)$;
- for $\blacksquare B \in \mathrm{Cl}$: $\blacksquare B \in t \Rightarrow B \in t$ (from **T$_\blacksquare$**).

These are necessary conditions; the last is precisely what (T-refl) of Theorem 4.9 needs, and dropping it makes the constructed frame illegal, as one can verify on the closure of $\blacksquare p \to \Box p$.

---

## 8. How tight is the bound?

Explicit bounds invite the question of tightness. We record concrete measurements.

| formula | $\mathrm{sub}$ | sharp bound $2^{\mathrm{sub}}$ | stated bound $2^{2\,\mathrm{sub}}$ | minimal countermodel |
|---|---|---|---|---|
| $\Box\bot \to \bot$ | $3$ | $8$ | $64$ | $1$ world |
| $\blacksquare p \to \Box p$ | $4$ | $16$ | $256$ | $2$ worlds |
| $\Box p \to \blacksquare p$ | $4$ | $16$ | $256$ | $1$ world |

Ratios of $64:1$, $128:1$ and $256:1$ between the stated bound and reality. Where does the slack come from?

The bound is a product of two quantities: the **depth** of the canonical countermodel — the length of the longest $R$-chain — and its **width** — the number of worlds available at each level. Theorem 3.5 pins the depth exactly: the measure $\beta$ strictly increases along every accessibility step, and $\beta$ is bounded by the number of *boxed* subformulas of $A$. Hence

$$\text{depth of any } R_{\mathrm{Cl}}\text{-chain} \ \le\ |\{\Box D \in \mathrm{Sub}(A)\}| \ \le\ \mathrm{sub}(A),$$

a *linear* bound. The entire exponential factor $2^{\mathrm{sub}(A)}$ is therefore pure width, and width is spent only on realising distinct propositional theories over the closure. But the completeness proof never *needs* all of them: it needs only the worlds actually produced by iterating Theorems 4.6 and 4.7 from the single refuting world. That reachable subset is what a *selective* canonical model would keep, and its size is governed by the recursion depth — which is linear — times the branching factor at each step, which is at most the number of boxed (respectively temporally boxed) subformulas not yet realised.

This is exactly the shape of a plausible sharpening: for every non-derivable $A$ there is a countermodel whose world count is polynomial in $\mathrm{sub}(A)$, and equal to $\mathrm{sub}(A) + 1$ for formulas containing no nested implications beneath a $\Box$. The three data points above are consistent with it; a proof would replace the full world set $\mathcal{W}(\mathrm{Sub}(A))$ by the sub-collection reachable from the refuting world under repeated application of the two existence lemmas, and bound its cardinality by the recursion depth.

A second, independent source of slack is the factor $2$ in the exponent of the stated bound: the construction actually delivers $2^{\mathrm{sub}(A)}$, so $2^{2\,\mathrm{sub}(A)}$ is a square too generous before any of the above is taken into account.

---

## 9. Discussion and future directions

### 9.1 What the proof teaches

Three things stand out.

**(i) Löb's axiom is both the obstruction and the engine.** It is the reason the infinite canonical model is illegal — the canonical accessibility relation has infinite ascending chains — and it is the reason the finite one works, since it licenses the strictness clause that makes the successor construction go through. In the filtration it appears in a third guise, as the *counting* Theorem 3.5: converse well-foundedness is recovered not by a semantic argument but by observing that a bounded integer cannot increase forever.

**(ii) The interaction axiom is load-bearing.** $\Box A \to \blacksquare\Box A$ is not a convenience. It is what makes ($\Box$-persistence) a *legitimate* clause of the filtered temporal relation (Theorem 3.9, the $\blacksquare$ case), and it is what supplies the corresponding hypotheses in the temporal existence lemma (Theorem 4.7). Removing it would break the construction at both ends simultaneously.

**(iii) Sharing the relations is an economy, not a coincidence.** Both models — the filtration of an arbitrary countermodel, and the canonical model built from consistent decided subsets — use *the same* pair $R_{\mathrm{Cl}}, T_{\mathrm{Cl}}$. Everything frame-theoretic (transitivity, converse well-foundedness, compatibility) is therefore proved once, abstractly, in Section 3, and only reflexivity of time needs a separate syntactic argument in the canonical case. This is why the completeness proof is short.

### 9.2 Future directions

**Polynomial width collapse for temporal Löb countermodels.** *Conjecture:* for every non-derivable $A$ there is a countermodel whose world count is bounded by a polynomial in $\mathrm{sub}(A)$ — in fact by $\mathrm{sub}(A) + 1$ when $A$ contains no nested implications under $\Box$.

The key insight is that the filtration measure $\beta$ strictly increases along every step of the accessibility relation, so the *depth* of any canonical countermodel is at most the number of boxed subformulas; the exponential factor in the proved bound is pure width, and width is only ever used to realise distinct propositional theories, which a *selective* (rather than exhaustive) canonical model never needs all of.

The empirical evidence is strong: the two non-derivable sample formulas above show gaps of $64:1$ and $128:1$ between the permitted and the actual minimal countermodel. The bound is nowhere near tight, and the machinery for measuring it — the strict-growth theorem and the cardinality estimate for the canonical world set — is already in place.

*Test.* Replace the full canonical world set by the sub-collection of worlds actually reachable from the refuting world by iterated application of the two existence lemmas, and bound its cardinality by the recursion depth. If this succeeds, the sharp finite model property improves from exponential to polynomial.

**Further avenues.**

- *Complexity.* $\mathsf{GL}$-satisfiability is PSPACE-complete. Determining the exact complexity of $\mathsf{TGL}$-satisfiability, and whether the interaction axiom pushes it beyond PSPACE, is open here.
- *Weaker interaction.* One may replace (compat) by the converse condition, or by a two-sided commutation, and ask which combinations retain the finite model property with an explicit bound. The counting argument of Theorem 3.5 is robust; what varies is whether the temporal relation admits a persistence clause that preserves the frame condition.
- *Branching time.* Replacing the preorder $T$ by a tree order, or adding an "eventually" dual with its own fixed-point behaviour, would move the system towards a temporal provability logic of $\mathsf{CTL}$ type.
- *Arithmetical interpretation.* $\mathsf{GL}$ is arithmetically complete for the provability predicate of Peano arithmetic (Solovay). The natural question for $\mathsf{TGL}$ is whether it is arithmetically complete for a *growing* sequence of theories $T_0 \subseteq T_1 \subseteq \cdots$, with $\blacksquare$ interpreted as "at every later stage" and $\Box$ as provability in the current stage. The interaction axiom is exactly the formal counterpart of monotonicity of the sequence.
- *Fixed points.* $\mathsf{GL}$ enjoys the de Jongh–Sambin fixed point theorem: every formula $A(p)$ in which $p$ occurs only inside a $\Box$ has a unique explicit fixed point. Whether the bimodal analogue holds for $\mathsf{TGL}$ — with $p$ guarded by either box — is a natural next question, and would give a syntactic normal form for self-referential temporal statements.

---

## 10. Summary of results

1. **Soundness.** Every theorem of $\mathsf{TGL}$ is valid on every temporal Gödel–Löb frame. (Theorem 2.9)
2. **Strict growth of the box measure.** Every step of the filtered accessibility relation strictly increases the number of realised boxed subformulas; hence any frame built on that relation is converse well-founded, and its depth is at most the number of boxed subformulas. (Theorem 3.5, Corollary 3.6)
3. **Compatibility-preserving filtration.** The filtered temporal relation, strengthened by a $\Box$-persistence clause, preserves the interaction condition; the resulting quotient is a legal temporal Gödel–Löb frame and satisfies the filtration lemma on all subformulas. (Lemma 3.3, Theorems 3.8, 3.9)
4. **Small model property.** Every countermodel to $A$ can be shrunk to one with at most $2^{\mathrm{sub}(A)}$ worlds. (Theorem 3.10)
5. **Existence lemmas.** In the finite canonical model, unrealised $\Box$'s and $\blacksquare$'s have witnessing successors; the $\Box$ case is the Löb argument, the $\blacksquare$ case consumes $\blacksquare$-necessitation, $\mathbf{4}_\blacksquare$ and the interaction axiom. (Theorems 4.6, 4.7)
6. **Weak completeness.** Validity implies derivability; hence derivability and validity coincide. (Theorem 4.11, Corollary 4.12)
7. **Finite model property with an explicit bound.** Every non-derivable $A$ has a countermodel with at most $2^{\mathrm{sub}(A)}$, a fortiori at most $2^{2\,\mathrm{sub}(A)}$, worlds. (Theorems 5.1, 5.2)
8. **Decidability.** Derivability is equivalent to validity on all models of at most $2^{2\,\mathrm{sub}(A)}$ worlds, so exhaustive bounded model search is a correct decision procedure. (Theorem 5.3, Corollary 5.4)
9. **Transitivity from Löb; Löb's rule.** $\Box A \to \Box\Box A$ is derivable without a transitivity axiom, and Löb's rule is admissible. (Theorems 6.1, 6.2)
10. **Gödel's second theorem and non-collapse.** $\Box\bot \to \bot$ is not a theorem, and neither box implies the other. (Theorems 6.3, 6.5)
