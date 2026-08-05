# Last-Occurrence Normal Forms and the Geometry of Signed-Literal Revision

**Author:** Aristotle

**Date:** 2026-08-05

---

## Abstract

We develop the global theory of iterated *signed-literal revision* on unrestricted sets of signed atoms ("states"), a minimal syntactic model of belief change that tolerates local contradiction without explosion. The single-step operator is $\mathrm{rev}(B,\ell) = (B \setminus \{\overline{\ell}\}) \cup \{\ell\}$: assert the literal $\ell$ and retract only its complement.

Two local rewriting laws are isolated and proved: revisions at *distinct* atoms commute, and revisions at the *same* atom obey **last write wins** — an earlier revision at an atom leaves no trace after a later one. These two laws are shown to determine the entire theory of finite revision histories.

Our main result is the **Last-Occurrence Normalization Theorem**: for any state $B$, any finite history $L$, and any literal $p = (a,s)$,
$$p \in \mathrm{rev}^*(B;L) \iff \mathrm{last}_L(a) = s \ \ \text{or} \ \ \bigl(\mathrm{last}_L(a) \text{ undefined and } p \in B\bigr),$$
where $\mathrm{last}_L$ records the sign of the last occurrence of each atom in $L$. A history therefore acts as *overwrite on the atoms it mentions, identity elsewhere*.

Five consequences follow. (i) **Extensional rigidity**: two histories act identically on all states iff they act identically on the empty state iff they have equal last-occurrence records — a single test input decides behavioural equivalence. (ii) **Normal form and uniqueness**: deleting each literal superseded later yields a history mentioning each atom at most once with the same action, and any such history with the same action is a permutation of it; permutation is the sharpest possible conclusion because distinct-atom revisions commute. (iii) **Frame property and persistent non-explosion**: literals over atoms untouched by a history retain their initial status, so a state contradictory at one atom cannot, by any amount of revision at that atom, come to accept a previously rejected literal over a different atom. (iv) **Consistency as partial assignment**: a state is consistent iff it is the graph of a partial function from atoms to signs. (v) **Component classification**: among finite consistent states, mutual reachability under revision histories holds exactly when the sets of assigned atoms coincide, so the strongly connected components of the oriented revision graph are indexed by supports, and the condensation is ordered like the subset lattice.

We give algorithms (normalization, receipt computation, reachability, minimal steering histories), numerical demonstrations, and applications to last-write-wins replicated registers, log compaction, and paraconsistent data integration. We close with a list of sharply falsifiable open conjectures.

**Keywords.** belief revision, signed literals, last write wins, normal form, confluence, paraconsistency, frame property, reachability, hypercube graph, conflict-free complex.

---

## 1. Introduction

### 1.1 Motivation

Consider any system that maintains a body of elementary factual commitments and updates them one fact at a time by overwriting. Examples are ubiquitous: a key–value store receiving writes; a configuration cache; a sensor fusion buffer; a knowledge base fed by a stream of assertions; the shifting commitments of a dreaming mind, which asserts and retracts elementary propositions without ever experiencing a contradiction as a crisis.

Such systems share three features that classical logical modelling handles poorly.

1. **They tolerate contradiction locally.** A merged record may assert both "the patient is allergic to penicillin" and "the patient is not allergic to penicillin" without thereby asserting everything. Classical consequence explodes; these systems do not.

2. **Their updates are syntactically local.** An update names one atom and touches only that atom's two possible signs.

3. **Their histories are long but their effects are short.** After a million writes to five keys, the state depends on at most five of them.

The purpose of this paper is to make (1)–(3) precise and to prove that, in the minimal model capturing them, feature (3) is a *theorem with a complete converse*: the effect of a history is exactly its last-occurrence record, this record is testable against a single state, the corresponding compressed history is unique up to a permutation forced by genuine commutativity, and the reachability structure of the whole state space is completely classified.

### 1.2 Contributions

- Two local rewriting laws (Theorems 3.1, 3.2) for the revision operator, covering the commuting and the last-write-wins cases exhaustively.
- The Last-Occurrence Normalization Theorem (Theorem 4.4) and its set-level and empty-state forms (Corollaries 4.5, 4.6).
- Extensional rigidity (Theorem 5.2): behavioural equivalence of histories is decided by the empty state alone.
- An explicit normal form with a uniqueness-up-to-permutation theorem (Theorems 6.3, 6.6).
- A frame property and the persistent non-explosion theorem (Theorems 7.1, 7.2).
- A structural characterisation of consistency as partial assignment (Theorem 8.1), monotonicity of support (Theorem 8.2), and the classification of strongly connected components of the revision graph (Theorem 8.7).
- Algorithms with complexity analysis (Section 9), applications (Section 11), and falsifiable conjectures (Section 12).

### 1.3 Relation to other frameworks

The operator studied here is the extreme *syntactic* end of the belief-revision spectrum: it is closed under no inference at all, and its "minimal change" postulate is realised literally as "delete exactly the complement". This purity is what makes a complete algebraic description possible. Nothing in what follows requires a consequence relation, a selection function, or an entrenchment ordering; conversely, everything proved here specialises to any richer setting in which the underlying store of commitments is a set of signed atoms updated by overwrite.

---

## 2. The framework

Throughout, $A$ is a set of **atoms**, whose elements are written $a,b,c,\dots$. In several results we assume equality of atoms is decidable; this is automatic for the finite and countable atom sets of interest.

**Definition 2.1 (Literal).** A **literal** is a pair $\ell = (a,s)$ with $a \in A$ and $s \in \{\mathrm{T},\mathrm{F}\}$. We write $\mathrm{at}(\ell) = a$ for its **atom** and $\mathrm{sg}(\ell) = s$ for its **sign**. The set of literals is $\mathcal{L} = A \times \{\mathrm{T},\mathrm{F}\}$.

**Definition 2.2 (Complement).** The **complement** of $\ell = (a,s)$ is $\overline{\ell} = (a, \neg s)$, where $\neg \mathrm{T} = \mathrm{F}$ and $\neg \mathrm{F} = \mathrm{T}$. Note $\mathrm{at}(\overline{\ell}) = \mathrm{at}(\ell)$ and $\overline{\overline{\ell}} = \ell$.

**Definition 2.3 (State).** A **state** is an arbitrary subset $B \subseteq \mathcal{L}$. We say $B$ **accepts** $\ell$, written $B \Vdash \ell$, when $\ell \in B$. No closure is imposed.

**Definition 2.4 (Contradiction, consistency).** $B$ is **contradictory at $a$** if $(a,\mathrm{T}) \in B$ and $(a,\mathrm{F}) \in B$. $B$ is **consistent** if it is contradictory at no atom.

Observe carefully: a contradictory state is a perfectly legitimate object of the theory and does not accept every literal. This is the sense in which the framework is paraconsistent: acceptance is membership, and membership does not propagate.

**Definition 2.5 (Revision).** For a state $B$ and literal $\ell$,
$$\mathrm{rev}(B,\ell) \;=\; \bigl(B \setminus \{\overline{\ell}\}\bigr) \cup \{\ell\}.$$

Three basic properties are immediate from the definition and are used freely below.

**Lemma 2.6 (Success).** $\ell \in \mathrm{rev}(B,\ell)$.

**Lemma 2.7 (Consistency preservation).** If $B$ is consistent then so is $\mathrm{rev}(B,\ell)$.

*Proof sketch.* Suppose $\mathrm{rev}(B,\ell)$ is contradictory at $b$. If $b \ne \mathrm{at}(\ell)$, both signs of $b$ already lay in $B$, contradicting consistency of $B$. If $b = \mathrm{at}(\ell)$, then $\overline{\ell} \in \mathrm{rev}(B,\ell)$, which is impossible since $\overline{\ell}$ is explicitly deleted and $\overline{\ell} \ne \ell$. $\square$

**Lemma 2.8 (Finiteness preservation).** If $B$ is finite then so is $\mathrm{rev}(B,\ell)$.

The following elementary dichotomy is used repeatedly.

**Lemma 2.9 (Same-atom dichotomy).** If $\mathrm{at}(\ell) = \mathrm{at}(k)$ then $\ell = k$ or $\ell = \overline{k}$.

*Proof.* Writing $\ell = (a,s)$, $k = (a,t)$, either $s = t$ or $s = \neg t$. $\square$

**Lemma 2.10 (Uniqueness of sign in consistent states).** If $B$ is consistent and $(a,s), (a,t) \in B$, then $s = t$.

*Proof.* Otherwise $\{s,t\} = \{\mathrm{T},\mathrm{F}\}$ and $B$ is contradictory at $a$. $\square$

---

## 3. Two local rewriting laws

The entire global theory is generated by the following pair of statements, which exhaustively cover the two ways adjacent revisions can interact.

**Theorem 3.1 (Independence of distinct atoms).** *If $\mathrm{at}(\ell) \ne \mathrm{at}(k)$ then for every state $B$,*
$$\mathrm{rev}(\mathrm{rev}(B,\ell),k) \;=\; \mathrm{rev}(\mathrm{rev}(B,k),\ell).$$

*Proof sketch.* From $\mathrm{at}(\ell) \ne \mathrm{at}(k)$ we get $\ell \ne \overline{k}$ and $k \ne \overline{\ell}$, since complementation preserves atoms. Expanding both sides, membership of $x$ in the left-hand side unfolds to
$$x = k \ \ \text{or}\ \ \bigl(\,(x = \ell \ \text{or}\ (x \in B \wedge x \ne \overline{\ell}))\ \wedge\ x \ne \overline{k}\,\bigr),$$
and symmetrically on the right. Case analysis on which disjunct holds transfers each case to the corresponding case on the other side, using $\ell \ne \overline{k}$ and $k \ne \overline{\ell}$ to discharge the side conditions. $\square$

**Theorem 3.2 (Last write wins).** *If $\mathrm{at}(\ell) = \mathrm{at}(k)$ then for every state $B$,*
$$\mathrm{rev}(\mathrm{rev}(B,\ell),k) \;=\; \mathrm{rev}(B,k).$$

*Proof sketch.* ($\subseteq$) Let $x \in \mathrm{rev}(\mathrm{rev}(B,\ell),k)$. If $x = k$ we are done. Otherwise $x \ne \overline{k}$ and either $x = \ell$ or $x \in B$ with $x \ne \overline{\ell}$. In the first case Lemma 2.9 gives $\ell = k$ or $\ell = \overline{k}$; the latter is excluded by $x \ne \overline{k}$, so $x = k$. In the second, $x \in B \setminus \{\overline{k}\}$.

($\supseteq$) Let $x \in \mathrm{rev}(B,k)$. Again the case $x = k$ is trivial, so assume $x \in B$, $x \ne \overline{k}$. If $x = k$ we are done; otherwise Lemma 2.9 (contrapositive) shows $\mathrm{at}(x) \ne \mathrm{at}(k) = \mathrm{at}(\ell)$, hence $x \ne \overline{\ell}$, and $x$ survives both revisions. $\square$

Theorem 3.2 subsumes idempotence ($\ell = k$) and the contrary case ($\ell = \overline{k}$) simultaneously. It is the formal expression of the fact that revision at an atom *completely determines* that atom's status, wiping whatever came before.

---

## 4. Histories and the Normalization Theorem

**Definition 4.1 (Revision history).** A **history** is a finite list $L = (\ell_1,\dots,\ell_n)$ of literals. Its **action** is defined by left fold:
$$\mathrm{rev}^*(B;\,()) = B, \qquad \mathrm{rev}^*(B;\, \ell :: L) = \mathrm{rev}^*(\mathrm{rev}(B,\ell);\,L).$$

**Lemma 4.2 (Concatenation).** $\mathrm{rev}^*(B; L \frown M) = \mathrm{rev}^*(\mathrm{rev}^*(B;L); M)$, where $\frown$ is list concatenation.

Thus $L \mapsto \mathrm{rev}^*(-;L)$ is a monoid action of the free monoid on $\mathcal{L}$ on the set of states.

**Definition 4.3 (Last-occurrence record).** For a history $L$ and atom $a$, define $\mathrm{last}_L(a) \in \{\mathrm{T},\mathrm{F}\} \cup \{\bot\}$ recursively:
$$\mathrm{last}_{()}(a) = \bot, \qquad \mathrm{last}_{\ell :: L}(a) = \begin{cases} \mathrm{last}_L(a) & \text{if } \mathrm{last}_L(a) \ne \bot,\\ \mathrm{sg}(\ell) & \text{if } \mathrm{last}_L(a) = \bot \text{ and } \mathrm{at}(\ell) = a,\\ \bot & \text{otherwise.}\end{cases}$$
Equivalently, $\mathrm{last}_L(a)$ is the sign of the rightmost literal of $L$ based at $a$, and $\bot$ if there is none. We call $\mathrm{last}_L$ the **receipt** of $L$.

Two auxiliary facts about receipts are needed.

**Lemma 4.4a.** $\mathrm{last}_L(a) = \bot$ if and only if no literal of $L$ has atom $a$.

*Proof sketch.* Induction on $L$. For $L = \ell :: L'$: if $\mathrm{last}_L(a) = \bot$ then the defining clauses force $\mathrm{last}_{L'}(a) = \bot$ and $\mathrm{at}(\ell) \ne a$; apply the inductive hypothesis. Conversely if no literal of $L$ has atom $a$, the same two facts hold and the third clause applies. $\square$

**Lemma 4.4b.** If $\mathrm{last}_L(a) = s \ne \bot$, then the literal $(a,s)$ occurs in $L$.

*Proof sketch.* Induction on $L$, tracking which defining clause produced the value: either it came from the tail (apply the inductive hypothesis) or from the head $\ell$, in which case $\ell = (a,s)$ itself. $\square$

We can now state the central theorem.

> **Theorem 4.4 (Last-Occurrence Normalization).** *For every state $B$, every history $L$, and every literal $p = (a,s)$:*
> $$p \in \mathrm{rev}^*(B;L) \quad\Longleftrightarrow\quad \mathrm{last}_L(a) = s \ \ \text{ or } \ \ \bigl(\mathrm{last}_L(a) = \bot \ \wedge\ p \in B\bigr).$$

*Proof sketch.* Induction on $L$, generalising over $B$.

*Base.* $L = ()$: then $\mathrm{rev}^*(B;()) = B$ and $\mathrm{last}_{()}(a) = \bot$, so both sides say $p \in B$.

*Step.* $L = \ell :: L'$. By definition $\mathrm{rev}^*(B;L) = \mathrm{rev}^*(\mathrm{rev}(B,\ell); L')$, and by the inductive hypothesis applied to the state $\mathrm{rev}(B,\ell)$,
$$p \in \mathrm{rev}^*(B;L) \iff \mathrm{last}_{L'}(a) = s \ \text{ or } \ \bigl(\mathrm{last}_{L'}(a) = \bot \wedge p \in \mathrm{rev}(B,\ell)\bigr).$$
Case (i): $\mathrm{last}_{L'}(a) \ne \bot$. Then $\mathrm{last}_L(a) = \mathrm{last}_{L'}(a)$ by Definition 4.3, and both sides reduce to $\mathrm{last}_{L'}(a) = s$.

Case (ii): $\mathrm{last}_{L'}(a) = \bot$ and $\mathrm{at}(\ell) = a$. Then $\mathrm{last}_L(a) = \mathrm{sg}(\ell)$, which is not $\bot$, so the right-hand side reads $\mathrm{sg}(\ell) = s$. The left-hand side reduces to $p \in \mathrm{rev}(B,\ell)$, i.e. $p = \ell$ or ($p \in B$ and $p \ne \overline{\ell}$). Since $\mathrm{at}(p) = a = \mathrm{at}(\ell)$, Lemma 2.9 gives $p = \ell$ or $p = \overline{\ell}$; the second disjunct is excluded in the second case, so in both cases the left-hand side is equivalent to $p = \ell$, which (atoms already equal) is equivalent to $\mathrm{sg}(\ell) = s$. The two sides agree.

Case (iii): $\mathrm{last}_{L'}(a) = \bot$ and $\mathrm{at}(\ell) \ne a$. Then $\mathrm{last}_L(a) = \bot$, and since $p \ne \ell$ and $p \ne \overline{\ell}$ (their atoms differ), $p \in \mathrm{rev}(B,\ell) \iff p \in B$. Both sides reduce to $p \in B$. $\square$

**Corollary 4.5 (Set form).**
$$\mathrm{rev}^*(B;L) \;=\; \{p \in \mathcal{L} : \mathrm{last}_L(\mathrm{at}(p)) = \mathrm{sg}(p)\} \;\cup\; \{p \in \mathcal{L} : \mathrm{last}_L(\mathrm{at}(p)) = \bot \ \wedge\ p \in B\}.$$

The first set is the *overwritten* part, entirely determined by $L$; the second is the *passed-through* part, the restriction of $B$ to atoms $L$ never mentions.

**Corollary 4.6 (Empty state).** $\mathrm{rev}^*(\varnothing; L) = \{p : \mathrm{last}_L(\mathrm{at}(p)) = \mathrm{sg}(p)\}$. In particular, from the empty state a history yields precisely the graph of its own receipt.

**Corollary 4.7.** $\mathrm{rev}^*(B;L)$ is consistent whenever $B$ is, and finite whenever $B$ is; both follow by induction from Lemmas 2.7 and 2.8, and both are also visible directly from Corollary 4.5 (the overwritten part is the graph of a partial function; the passed-through part is a subset of $B$ on disjoint atoms).

---

## 5. Extensional rigidity

Corollary 4.6 says the empty state faithfully records the receipt. Consequently a single test input suffices to determine a history's behaviour everywhere.

**Lemma 5.1.** $\mathrm{rev}^*(\varnothing;L) = \mathrm{rev}^*(\varnothing;M)$ if and only if $\mathrm{last}_L = \mathrm{last}_M$ pointwise.

*Proof sketch.* ($\Leftarrow$) Immediate from Corollary 4.6. ($\Rightarrow$) Fix $a$. By Corollary 4.6 applied at the two literals $(a,\mathrm{T})$ and $(a,\mathrm{F})$, we obtain for each sign $s$ that $\mathrm{last}_L(a) = s \iff \mathrm{last}_M(a) = s$. If $\mathrm{last}_L(a) = s$ for some sign, then $\mathrm{last}_M(a) = s$; if $\mathrm{last}_L(a) = \bot$, then $\mathrm{last}_M(a)$ cannot be a sign (else the equivalence would force $\mathrm{last}_L(a)$ to be that sign), so it is $\bot$. $\square$

> **Theorem 5.2 (Extensional rigidity).** *For histories $L$ and $M$ the following are equivalent:*
> 1. *$\mathrm{rev}^*(B;L) = \mathrm{rev}^*(B;M)$ for every state $B$;*
> 2. *$\mathrm{rev}^*(\varnothing;L) = \mathrm{rev}^*(\varnothing;M)$;*
> 3. *$\mathrm{last}_L(a) = \mathrm{last}_M(a)$ for every atom $a$.*

*Proof.* (1) $\Rightarrow$ (2) is instantiation at $B = \varnothing$. (2) $\Leftrightarrow$ (3) is Lemma 5.1. (3) $\Rightarrow$ (1): given (3), Theorem 4.4 gives for each $p$ and each $B$ that $p \in \mathrm{rev}^*(B;L)$ and $p \in \mathrm{rev}^*(B;M)$ are literally the same condition. $\square$

This is a strong finiteness-of-testing statement: the space of states is $2^{|\mathcal{L}|}$, yet behavioural equivalence of two histories is decided by one designated input.

We call the map $L \mapsto \mathrm{last}_L$ the **semantic quotient**. Theorem 5.2 says it is exactly the quotient by behavioural equivalence: the monoid of history-actions is isomorphic to the image of the semantic quotient, which is the set of finitely-supported partial maps $A \to \{\mathrm{T},\mathrm{F}\}$ under right-biased overwrite.

---

## 6. The normal form and its uniqueness

**Definition 6.1 (Normal form).** Define $\mathrm{nf}$ on histories by
$$\mathrm{nf}(()) = (), \qquad \mathrm{nf}(\ell :: L) = \begin{cases} \mathrm{nf}(L) & \text{if some literal of } L \text{ has atom } \mathrm{at}(\ell),\\ \ell :: \mathrm{nf}(L) & \text{otherwise.}\end{cases}$$
In words: scan left to right, deleting every literal superseded by a later revision of the same atom.

**Lemma 6.2.** $\mathrm{nf}(L)$ is a sublist of $L$; in particular every literal of $\mathrm{nf}(L)$ occurs in $L$.

*Proof sketch.* Induction on $L$; each recursive clause either drops the head (giving a sublist of the tail, hence of $L$) or keeps it in front of a sublist of the tail. $\square$

> **Theorem 6.3 (Normal form).** *For every history $L$:*
> 1. *(Receipt preservation) $\mathrm{last}_{\mathrm{nf}(L)}(a) = \mathrm{last}_L(a)$ for all $a$;*
> 2. *(Action preservation) $\mathrm{rev}^*(B;\mathrm{nf}(L)) = \mathrm{rev}^*(B;L)$ for every state $B$;*
> 3. *(Atom-distinctness) the atoms occurring in $\mathrm{nf}(L)$ are pairwise distinct.*

*Proof sketch.* (1) Induction on $L = \ell :: L'$. If some literal of $L'$ has atom $\mathrm{at}(\ell)$, then $\mathrm{nf}(L) = \mathrm{nf}(L')$; by the inductive hypothesis its receipt is $\mathrm{last}_{L'}$, and one checks $\mathrm{last}_{\ell::L'} = \mathrm{last}_{L'}$: the only atom at which they could differ is $\mathrm{at}(\ell)$, and there $\mathrm{last}_{L'}$ is not $\bot$ by Lemma 4.4a, so the head clause is inert. If no literal of $L'$ has atom $\mathrm{at}(\ell)$, then $\mathrm{nf}(L) = \ell :: \mathrm{nf}(L')$ and the recursive clauses of Definition 4.3 match on both sides by the inductive hypothesis.

(2) Immediate from (1) and Theorem 4.4.

(3) Induction on $L$: in the retaining case, the head atom $\mathrm{at}(\ell)$ does not occur in $L'$, hence *a fortiori* not in the sublist $\mathrm{nf}(L')$ (Lemma 6.2). $\square$

**Lemma 6.4 (Atom-distinct histories are their own receipts).** If the atoms of $M$ are pairwise distinct, then for every literal $p$,
$$p \in M \iff \mathrm{last}_M(\mathrm{at}(p)) = \mathrm{sg}(p).$$

*Proof sketch.* ($\Rightarrow$) If $p \in M$, then by Lemma 4.4a $\mathrm{last}_M(\mathrm{at}(p)) = s$ for some sign $s$, and by Lemma 4.4b the literal $(\mathrm{at}(p),s)$ occurs in $M$. Since atoms in $M$ are distinct, $M$ has at most one literal at that atom, so $(\mathrm{at}(p),s) = p$ and $s = \mathrm{sg}(p)$. ($\Leftarrow$) Lemma 4.4b directly. $\square$

**Corollary 6.5.** For atom-distinct $M$, $\mathrm{rev}^*(\varnothing;M) = \{$literals of $M\}$: the history *is* the state it creates.

> **Theorem 6.6 (Uniqueness up to permutation).** *Let $L$ be any history and let $M$ be a history whose atoms are pairwise distinct and whose receipt equals that of $L$, i.e. $\mathrm{last}_M(a) = \mathrm{last}_L(a)$ for all $a$. Then $M$ is a permutation of $\mathrm{nf}(L)$.*

*Proof sketch.* Both $M$ and $\mathrm{nf}(L)$ are duplicate-free as lists of literals (atom-distinctness implies literal-distinctness). Two duplicate-free lists are permutations of each other iff they have the same members. By Lemma 6.4 applied to $M$ and to $\mathrm{nf}(L)$ (atom-distinct by Theorem 6.3(3)), membership in each is equivalent to agreeing with the respective receipt; the receipts agree by hypothesis and Theorem 6.3(1). $\square$

**Remark 6.7 (Sharpness).** Permutation cannot be improved to equality. If $\mathrm{at}(\ell) \ne \mathrm{at}(k)$, the histories $(\ell,k)$ and $(k,\ell)$ are atom-distinct with equal receipts, and by Theorem 3.1 they act identically — yet they are distinct lists. Thus the residual permutation ambiguity is *exactly* the commutativity of Theorem 3.1 and no more. Combining Theorems 5.2 and 6.6: the behavioural equivalence class of a history contains a unique *set* of literals, namely the graph of its receipt, and this set is realised by any ordering.

**Corollary 6.8 (Optimal compression bound).** Every history over a set of $n$ distinct atoms is behaviourally equivalent to one of length at most $n$, and to none shorter than the number of atoms whose final sign differs from the initial state's (see Conjecture 12.3 for the sharpened metric statement).

---

## 7. Locality: frame property and persistent non-explosion

> **Theorem 7.1 (Frame property).** *Let $L$ be a history none of whose literals has atom $a$. Then for both signs $s$ and every state $B$,*
> $$(a,s) \in \mathrm{rev}^*(B;L) \iff (a,s) \in B.$$

*Proof.* By Lemma 4.4a, $\mathrm{last}_L(a) = \bot$; apply Theorem 4.4. $\square$

The frame property is the formal content of "revision is local to one complementary pair". Its dramatic consequence is that contradiction cannot propagate.

> **Theorem 7.2 (Persistent non-explosion).** *Let $B$ be a state that is contradictory at an atom $a$, and let $\ell$ be a literal with $\mathrm{at}(\ell) \ne a$ such that $B \nVdash \ell$. Then for **every** history $L$ none of whose literals has atom $\mathrm{at}(\ell)$,*
> $$\mathrm{rev}^*(B;L) \nVdash \ell.$$
> *In particular, the atom $a$ may be revised arbitrarily often, in any pattern of signs, and $\ell$ remains rejected.*

*Proof.* Suppose $\ell \in \mathrm{rev}^*(B;L)$. Applying Theorem 7.1 at the atom $\mathrm{at}(\ell)$ and sign $\mathrm{sg}(\ell)$ — legitimate because $L$ avoids that atom — yields $\ell \in B$, contradicting $B \nVdash \ell$. $\square$

**Remark 7.3.** The contradiction hypothesis is not used in the proof. This is the substantive point rather than an oversight: non-explosion in this framework is not obtained by any special handling of inconsistency, but is a *free consequence of locality*. The hypothesis is retained in the statement because it identifies the situation the theorem is about — one in which classical consequence would license $\ell$ immediately.

**Remark 7.4 (Contrast with classical closure).** In a classically closed theory, $\{(a,\mathrm{T}),(a,\mathrm{F})\}$ entails every literal, so the analogue of Theorem 7.2 fails for the empty history. The framework here decouples "holding both sides of one question" from "holding everything", and Theorem 7.2 shows the decoupling survives arbitrary further revision.

---

## 8. The geometry of the revision graph

### 8.1 Consistent states are partial assignments

> **Theorem 8.1 (Consistency as partial assignment).** *A state $B$ is consistent if and only if there exists $f : A \to \{\mathrm{T},\mathrm{F}\} \cup \{\bot\}$ with*
> $$B = \{(a,s) \in \mathcal{L} : f(a) = s\}.$$

*Proof sketch.* ($\Rightarrow$) Define $f(a) = \mathrm{T}$ if $(a,\mathrm{T}) \in B$; else $f(a) = \mathrm{F}$ if $(a,\mathrm{F}) \in B$; else $f(a) = \bot$. For $(a,\mathrm{T})$: membership in $B$ gives $f(a) = \mathrm{T}$ immediately, and conversely $f(a) = \mathrm{T}$ can only arise from the first clause. For $(a,\mathrm{F})$: if $(a,\mathrm{F}) \in B$ then by consistency $(a,\mathrm{T}) \notin B$, so the first clause fails and $f(a) = \mathrm{F}$; conversely $f(a) = \mathrm{F}$ forces the second clause, i.e. $(a,\mathrm{F}) \in B$.

($\Leftarrow$) If $B$ is the graph of $f$ and both $(a,\mathrm{T}),(a,\mathrm{F}) \in B$, then $f(a) = \mathrm{T}$ and $f(a) = \mathrm{F}$, absurd. $\square$

Geometrically: place, over each atom $a$, a pair of complementary vertices $\{(a,\mathrm{T}),(a,\mathrm{F})\}$. A state is consistent iff it selects at most one vertex from each pair — that is, iff it is a *conflict-free set* in the graph whose edges join complementary literals, equivalently a face of the corresponding independence complex. Consistent states with support $S$ are exactly the total selections over $S$: there are $2^{|S|}$ of them for finite $S$.

### 8.2 Support is monotone

**Definition 8.1a (Support).** $\mathrm{asg}(B) = \{a \in A : \exists s,\ (a,s) \in B\}$, the set of atoms **assigned** by $B$.

> **Theorem 8.2 (Support of a revision).** $\mathrm{asg}(\mathrm{rev}(B,\ell)) = \mathrm{asg}(B) \cup \{\mathrm{at}(\ell)\}$.

*Proof sketch.* ($\subseteq$) A literal of $\mathrm{rev}(B,\ell)$ is either $\ell$ (contributing $\mathrm{at}(\ell)$) or lies in $B$. ($\supseteq$) $\ell \in \mathrm{rev}(B,\ell)$ gives $\mathrm{at}(\ell)$. If $(a,s) \in B$: either $(a,s) = \overline{\ell}$, in which case $a = \mathrm{at}(\ell)$ and $\ell$ itself witnesses $a \in \mathrm{asg}(\mathrm{rev}(B,\ell))$; or $(a,s)$ survives. $\square$

**Corollary 8.3.** $\mathrm{asg}(B) \subseteq \mathrm{asg}(\mathrm{rev}^*(B;L))$ for every history $L$; indeed $\mathrm{asg}(\mathrm{rev}^*(B;L)) = \mathrm{asg}(B) \cup \{\mathrm{at}(\ell) : \ell \in L\}$.

Revision never *un-decides* an atom. Information about *which* questions have been answered accumulates monotonically, while information about *how* they were answered is overwritten freely. This is precisely the tension that produces the component structure below.

### 8.3 Reachability

**Definition 8.4 (Reachability).** $C$ is **reachable** from $B$, written $B \rightsquigarrow C$, if $\mathrm{rev}^*(B;L) = C$ for some history $L$.

**Lemma 8.5.** $\rightsquigarrow$ is reflexive (take $L = ()$) and transitive (concatenate, by Lemma 4.2). If $B \rightsquigarrow C$ then $\mathrm{asg}(B) \subseteq \mathrm{asg}(C)$ (Corollary 8.3).

> **Theorem 8.6 (Sufficiency of equal support).** *Let $C$ be a finite consistent state and $B$ any state with $\mathrm{asg}(B) = \mathrm{asg}(C)$. Then $B \rightsquigarrow C$; indeed the history $L_C$ obtained by listing the literals of $C$ in any order satisfies $\mathrm{rev}^*(B; L_C) = C$.*

*Proof sketch.* Apply Theorem 4.4 to $L_C$ and a literal $p=(a,s)$.

If $p \in \mathrm{rev}^*(B;L_C)$: either $\mathrm{last}_{L_C}(a) = s$, whence by Lemma 4.4b $p$ occurs in $L_C$, i.e. $p \in C$; or $\mathrm{last}_{L_C}(a) = \bot$ and $p \in B$ — but then $a \in \mathrm{asg}(B) = \mathrm{asg}(C)$, so $C$ has some literal at $a$, so $L_C$ mentions $a$, contradicting Lemma 4.4a.

Conversely if $p \in C$: then $L_C$ mentions $a$, so $\mathrm{last}_{L_C}(a) = s'$ for some sign $s'$, and by Lemma 4.4b $(a,s') \in C$. Consistency of $C$ and Lemma 2.10 give $s' = s$, so the first disjunct of Theorem 4.4 holds and $p \in \mathrm{rev}^*(B;L_C)$. $\square$

> **Theorem 8.7 (Classification of strongly connected components).** *Let $B$ and $C$ be finite consistent states. Then*
> $$\bigl(B \rightsquigarrow C \ \wedge\ C \rightsquigarrow B\bigr) \iff \mathrm{asg}(B) = \mathrm{asg}(C).$$

*Proof.* ($\Rightarrow$) Two applications of Lemma 8.5 and antisymmetry of $\subseteq$. ($\Leftarrow$) Two applications of Theorem 8.6. $\square$

**Corollary 8.8 (Structure of the revision graph).** Consider the directed graph $\mathcal{G}$ whose vertices are the finite consistent states and whose edges are single revisions $B \to \mathrm{rev}(B,\ell)$. Then:

- the strongly connected components of $\mathcal{G}$ are exactly the fibres of the support map $B \mapsto \mathrm{asg}(B)$;
- the component with support $S$ has $2^{|S|}$ vertices, one for each total sign assignment on $S$;
- every edge either stays inside a component (when $\mathrm{at}(\ell) \in \mathrm{asg}(B)$) or moves to the component with support $\mathrm{asg}(B) \cup \{\mathrm{at}(\ell)\}$, strictly larger;
- consequently the condensation of $\mathcal{G}$ — the acyclic quotient by strong connectivity — is order-isomorphic to the poset of finite subsets of $A$ under inclusion.

Within a component, the intra-component edges are precisely the sign flips at single already-assigned atoms, which is the edge set of the $|S|$-dimensional hypercube $Q_{|S|}$ together with self-loops (revising an atom to the sign it already has). Conjecture 12.2 below asks for the resulting metric statement.

---

## 9. Algorithms

All algorithms below take a history $L$ of length $n$ over a set of $m$ distinct atoms, with $m \le n$. We assume hashing of atoms in expected $O(1)$.

### 9.1 Receipt computation

Scan $L$ left to right, writing each literal's sign into a dictionary keyed by its atom, overwriting any previous value. The final dictionary is $\mathrm{last}_L$ restricted to mentioned atoms. Cost: $O(n)$ time, $O(m)$ space. Correctness: the dictionary invariant after processing a prefix is exactly the receipt of that prefix, by Definition 4.3 read left-to-right.

### 9.2 Normalization (log compaction)

Compute the receipt; then produce the surviving literals. Two variants:

- **Order-preserving:** traverse $L$ right to left, emitting a literal iff its atom has not been emitted, then reverse. This yields exactly $\mathrm{nf}(L)$ as in Definition 6.1.
- **Canonical:** emit the receipt's entries in a fixed order of atoms. By Theorem 6.6, this is a permutation of $\mathrm{nf}(L)$ and hence behaviourally identical.

Cost: $O(n)$ time, $O(m)$ space. Output length is exactly $m$. By Theorem 6.3 and Corollary 6.8 this is optimal among histories with the same action on all states, and by Theorem 6.6 the output is unique up to permutation.

### 9.3 History application

Given a state $B$ (as a set of literals) and a history $L$: compute $\mathrm{last}_L$; then output
$$\{(a,s) \in B : a \notin \mathrm{dom}(\mathrm{last}_L)\} \cup \{(a,\mathrm{last}_L(a)) : a \in \mathrm{dom}(\mathrm{last}_L)\}.$$
Cost: $O(n + |B|)$, versus $O(n\cdot|B|)$ for naive step-by-step simulation. Correctness is Corollary 4.5. This is the practical payoff of Normalization: histories can be applied in a single pass with no intermediate states materialised.

### 9.4 Behavioural equivalence testing

To decide whether two histories act identically on all states, compute both receipts and compare dictionaries: $O(n_1 + n_2)$. Correctness is Theorem 5.2. Note that no quantification over states is required — this is exactly the algorithmic content of rigidity.

### 9.5 Reachability and steering

Given finite consistent $B, C$: $B \rightsquigarrow C$ and $C \rightsquigarrow B$ iff $\mathrm{asg}(B) = \mathrm{asg}(C)$ (Theorem 8.7), decidable in $O(|B| + |C|)$. To steer $B$ to $C$ when $\mathrm{asg}(B) \subseteq \mathrm{asg}(C)$, emit the literals of $C \setminus B$ in any order; by Theorem 4.4 the resulting state is $C$ (each mentioned atom is overwritten to $C$'s sign, and each unmentioned atom of $C$ already agrees with $B$). This produces a history of length $|C \setminus B|$, conjecturally optimal (Conjecture 12.3).

---

## 10. Worked examples

**Example 10.1 (Collapse of a long history).** Atoms $\{a,b\}$. Take
$$L = \bigl((a,\mathrm{T}),(a,\mathrm{F}),(b,\mathrm{T}),(a,\mathrm{T}),(b,\mathrm{F}),(a,\mathrm{F})\bigr).$$
Its receipt is $\mathrm{last}_L(a) = \mathrm{F}$, $\mathrm{last}_L(b) = \mathrm{F}$. Hence $\mathrm{nf}(L) = ((b,\mathrm{F}),(a,\mathrm{F}))$, of length $2$, and for *every* state $B$,
$$\mathrm{rev}^*(B;L) = \{(a,\mathrm{F}),(b,\mathrm{F})\} \cup \{p \in B : \mathrm{at}(p) \notin \{a,b\}\}.$$
A six-step history compresses to two.

**Example 10.2 (Non-commutativity of contrary revisions, and its resolution).** With $\ell = (a,\mathrm{T})$, $k = (a,\mathrm{F})$ and $B = \varnothing$: $\mathrm{rev}^*(\varnothing;(\ell,k)) = \{(a,\mathrm{F})\}$ while $\mathrm{rev}^*(\varnothing;(k,\ell)) = \{(a,\mathrm{T})\}$. Order matters at a shared atom — but only through the last element, which is exactly Theorem 3.2.

**Example 10.3 (Persistent non-explosion in action).** Let $B = \{(a,\mathrm{T}),(a,\mathrm{F})\}$, contradictory at $a$, and $\ell = (b,\mathrm{T})$ with $b \ne a$; note $B \nVdash \ell$. Take any history $L$ over the single atom $a$, say $L$ alternating $(a,\mathrm{T}),(a,\mathrm{F}),(a,\mathrm{T}),\dots$ of length $10^6$. By Theorem 7.1, $(b,\mathrm{T}) \notin \mathrm{rev}^*(B;L)$, and indeed $\mathrm{rev}^*(B;L) = \{(a, \mathrm{last}_L(a))\}$: the contradiction is even *repaired* at $a$ and never touches $b$.

**Example 10.4 (Component structure on three atoms).** With $A = \{a,b,c\}$ the finite consistent states number $3^3 = 27$ (each atom is $\mathrm{T}$, $\mathrm{F}$, or unassigned). Grouping by support gives $\binom{3}{0}\cdot 1 + \binom{3}{1}\cdot 2 + \binom{3}{2}\cdot 4 + \binom{3}{3}\cdot 8 = 1 + 6 + 12 + 8 = 27$ states in $2^3 = 8$ components of sizes $1,2,2,2,4,4,4,8$. The condensation is the Boolean lattice on $\{a,b,c\}$.

---

## 11. Applications

**11.1 Last-write-wins replicated registers.** In distributed data stores, "LWW" resolution is standard engineering practice for concurrent updates to independent keys. Theorem 4.4 gives its exact semantics: the state after applying a log is the log's receipt overlaid on the initial state. Theorem 3.1 is the formal justification for reordering writes to distinct keys — the basis of batching, sharding, and out-of-order delivery — while Theorem 3.2 is the justification for dropping superseded writes. Theorem 5.2 supplies an $O(n)$ decision procedure for "will these two logs ever be distinguishable?" that requires no exploration of the state space.

**11.2 Log compaction with an optimality guarantee.** Section 9.2 is the standard compaction algorithm, but now with proofs: the compacted log has the same effect on *every* initial state (Theorem 6.3), it is of minimum possible length among atom-distinct equivalents, and it is unique up to reordering (Theorem 6.6). The residual reordering freedom is not an artefact — it is exactly the set of genuine commutations (Remark 6.7), so a compactor is free to emit any order it likes, e.g. sorted by key for deterministic output.

**11.3 Paraconsistent data integration.** When records from multiple sources are merged, contradictions at individual fields are routine. Theorem 7.2 guarantees that such a contradiction is *quarantined*: any field not itself the target of an update retains its status, so downstream queries about unrelated fields are unaffected, no matter how much churn occurs at the conflicted field. This is a formal soundness property for "keep serving, resolve later" architectures.

**11.4 Provenance and audit.** Corollary 4.6 says the empty state is a *universal probe*: replaying a log against an empty store reconstructs the log's full observable effect. An auditor need not know the production state to characterise what a log does.

**11.5 Planning over belief states.** Theorem 8.7 with Section 9.5 gives a complete and trivially efficient planner for the question "can I get from belief state $B$ to belief state $C$, and how?" — answerable by comparing supports and emitting a difference list, rather than by search.

---

## 12. Open problems and future directions

**Conjecture 12.1 (Completeness of the two-law rewrite system).** The map sending a history to its action is a monoid homomorphism from the free monoid on literals onto the monoid of finitely-supported partial sign assignments under right-biased overwrite, and its kernel congruence is generated by exactly the two local rules of Theorems 3.1 and 3.2. *Falsifiable content:* exhibit two histories with the same action that cannot be connected by a finite chain of the two rewrites. Theorem 5.2 already shows the action is determined by the receipt, so the open half is completeness of the rewriting system; Theorem 6.6 supplies the confluence target.

**Conjecture 12.2 (Component geometry).** For a finite atom set $A$, the strongly connected component indexed by support $S \subseteq A$ is isomorphic, after deleting self-loops, to the hypercube graph $Q_{|S|}$: it has $2^{|S|}$ vertices and diameter $|S|$. The full revision graph is the disjoint union of these cubes together with the strictly monotone edges enlarging $S$, and its condensation is order-isomorphic to the Boolean lattice $2^A$. *Falsifiable content:* a component that is not a cube, or two states in one component at revision distance exceeding $|S|$. Theorem 8.7 fixes the vertex sets; the metric statement is open.

**Conjecture 12.3 (Optimal steering length).** For finite consistent $B, C$ with $\mathrm{asg}(B) \subseteq \mathrm{asg}(C)$, the minimum length of a history $L$ with $\mathrm{rev}^*(B;L) = C$ equals $|C \setminus B|$, and every minimal history is a permutation of the list of literals of $C \setminus B$. *Falsifiable content:* a pair $B,C$ steerable by a strictly shorter history. Section 9.5 gives the upper bound; the matching lower bound and the rigidity of minimisers are open.

**Conjecture 12.4 (Locality characterises the operator).** Among all operators $r$ mapping a state and a literal to a state and satisfying *success* ($\ell \in r(B,\ell)$), the operator $\mathrm{rev}$ is the unique one satisfying the frame law of Theorem 7.1, namely $\mathrm{at}(p) \ne \mathrm{at}(\ell) \Rightarrow (p \in r(B,\ell) \iff p \in B)$. Equivalently, frame plus success characterises $\mathrm{rev}$ outright, with consistency preservation (Lemma 2.7) a consequence rather than an assumption. *Falsifiable content:* a second operator with success and the frame law. (Note that frame plus success leaves only the two literals over $\mathrm{at}(\ell)$ undetermined, and success fixes one of them; the conjecture asserts that consistency-at-the-revised-atom is then forced, which requires a further principle to be identified.)

**Conjecture 12.5 (Compact completion of infinitary states).** The ideal completion of the poset of finite states, under a natural Scott topology, is homeomorphic to the space of arbitrary states, and consistent ideals correspond exactly to globally consistent states. The key point is that arbitrary states are directed unions of finite fragments, even though finite fragments are not closed under arbitrary unions; ideal completion is the canonical repair rather than an ad hoc enlargement.

**Conjecture 12.6 (What downward closure forgets).** For finite complementary-conflict frameworks, the maximal faces of the conflict-free complex (Theorem 8.1) determine all total consistent states, while the face poset *together with* the revision orientation determines the partition of literals into complementary pairs up to relabelling. Topology alone records compatibility; oriented revision records which incompatibilities arise from paired signs of a single atom. Adding dynamics may thus recover the semantic information that downward closure forgets.

---

## 13. Conclusion

Signed-literal revision is about as simple a model of belief change as one can write down: states are arbitrary sets of signed atoms, and the single update rule asserts a literal while retracting only its complement. We have shown that this simplicity is not poverty but completeness. Two local laws — commutation at distinct atoms, last-write-wins at a shared atom — determine everything. The action of an arbitrary finite history is exactly its last-occurrence receipt overlaid on the initial state; behavioural equivalence of histories is decided by the single empty state; the compressed history is unique up to precisely the permutations that genuine commutativity licenses; contradiction at one atom is quarantined from all others by pure locality; and the reachability structure of the entire state space is classified by the set of atoms one has bothered to decide, yielding a stack of cubes ordered like a Boolean lattice.

The picture that emerges is that overwrite-based revision is *path-independent in effect, though not in appearance*. What looks like a tangled history is, provably, a short receipt. The remaining questions — completeness of the rewrite system, the exact metric of the components, the optimality of steering, and the characterisation of the operator by locality — are all sharply falsifiable, and each is a natural next step from the results established here.
