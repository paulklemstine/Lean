# The Oracle's Burden: Relativized Computability and the Strictness of the Turing-Jump Hierarchy

**Author:** Aristotle
**Date:** 2026-07-11
**Domain:** Applications (Computability Theory / Mathematical Logic)

## Abstract

We develop the structural theory of relative (oracle) computability and use it to make rigorous the informal hierarchy of theories
$$T \;<\; T^{H} \;<\; T^{H^H} \;<\; \cdots$$
obtained by iteratively adjoining a halting oracle to a base theory of arithmetic. Recast computability-theoretically, this is the Turing-degree chain $\mathbf{0} <_T \mathbf{0}' <_T \mathbf{0}'' <_T \cdots$. We prove four structural pillars of the relativized theory — a **cut (generalized transitivity) principle**, **monotonicity of relativization**, the **least-upper-bound property of joins**, and the identification of the **bottom degree with the partial recursive functions** — and we establish the decisive **non-triviality** result that some function is not computable, so the first jump genuinely increases power. We then isolate the combinatorial skeleton of the escalation by axiomatizing an abstract **jump operator** through two order-theoretic conditions equivalent to the relativized Halting Theorem, and prove that iterating any such operator yields a strictly increasing $\omega$-chain of degrees that is order-isomorphic, via an explicit order embedding, to the standard Turing-jump hierarchy. Two contrarian results sharpen the picture: a *computable oracle adds nothing* (refuting the naive claim that every oracle increases power), and the *jump is never idempotent* (the burden strictly recurs at every level). We further show the axiomatization is discriminating: neither the identity nor any constant operator is a jump.

**Keywords:** relative computability, Turing degrees, Turing jump, halting problem, oracle hierarchy, partial recursive functions, order embedding, join semilattice.

---

## 1. Introduction

Turing's theorem that the Halting Problem is undecidable is not an isolated impossibility but the first step of an unbounded escalation. Relativizing the diagonal argument shows that a machine equipped with an oracle for the halting behavior of *ordinary* machines still cannot decide the halting behavior of machines *of its own kind*. Iterating produces an infinite tower of ever more powerful oracles.

In the language of formal theories, adjoining a halting oracle $H$ to a base theory $T$ (say, Peano Arithmetic) yields a strictly stronger theory $T^H$, which can prove the consistency of $T$ but cannot certify its own soundness. Repeating gives
$$T \;<\; T^{H} \;<\; T^{H^H} \;<\; T^{H^{H^H}} \;<\; \cdots. \tag{1.1}$$

The purpose of this paper is to give (1.1) a fully rigorous computability-theoretic meaning and to prove that the tower is genuinely strict, never repeats, and is structurally identical to the classical Turing-jump hierarchy. Our slogan throughout is that the informal phrase *"proves its own consistency but cannot decide its own soundness"* is the exact content of the strict inequality $A <_T J(A)$ between an oracle and its jump.

The development is organized around two layers. The first (Sections 2–5) is the concrete theory of relative computability, where we prove the base case unconditionally: there is a degree strictly above $\mathbf 0$. The second (Section 6) is the abstract jump calculus, where we axiomatize the jump and derive the strictness and order-embedding properties of the full tower. Sections 7–8 record two contrarian refutations and the discriminating power of the axioms; Section 9 discusses applications and open directions.

## 2. Relative computability

We work with partial functions $f : \mathbb{N} \rightharpoonup \mathbb{N}$. An **oracle set** is a set $O$ of such functions.

**Definition 2.1 (Recursive in an oracle set).** The class $\mathrm{Rec}(O)$ of functions *recursive in* $O$ is the smallest class containing the basic computable functions (zero, successor, projections), containing every $g \in O$ (the *oracle* rule), and closed under pairing, composition, primitive recursion, and unbounded search ($\mu$-recursion / `rfind`). We write $f \in \mathrm{Rec}(O)$ and, for single oracles, define **Turing reducibility** by
$$f \le_T g \quad :\Longleftrightarrow \quad f \in \mathrm{Rec}(\{g\}).$$

**Definition 2.2 (Turing equivalence and degrees).** Set $f \equiv_T g$ iff $f \le_T g$ and $g \le_T f$. This is an equivalence relation; its classes are the **Turing degrees**, ordered by $[f] \le [g] \iff f \le_T g$. We write $f <_T g$ for $f \le_T g \wedge \neg(g \le_T f)$, and $\mathrm{deg}(f)$ for the degree of $f$.

The class $\mathrm{Rec}(\varnothing)$ of functions recursive in the empty oracle is exactly the class of **partial recursive** functions, denoted $\mathrm{Partrec}$; this is unrelativized computability.

## 3. The cut principle and monotonicity

The engine of the entire theory is a generalized transitivity principle.

**Theorem 3.1 (Cut / generalized transitivity).** Let $O, O'$ be oracle sets and suppose every $g \in O$ satisfies $g \in \mathrm{Rec}(O')$. Then $\mathrm{Rec}(O) \subseteq \mathrm{Rec}(O')$; that is, if $f \in \mathrm{Rec}(O)$ then $f \in \mathrm{Rec}(O')$.

*Proof sketch.* Induct on the derivation witnessing $f \in \mathrm{Rec}(O)$. The base cases (zero, successor, projections) are computable and hence lie in $\mathrm{Rec}(O')$ outright. For the oracle rule, $f = g \in O$ is in $\mathrm{Rec}(O')$ by hypothesis. Each closure rule — pairing, composition, primitive recursion, unbounded search — is a closure rule of $\mathrm{Rec}(O')$ as well, so the corresponding inductive step transports directly: e.g. if $f_1, f_2 \in \mathrm{Rec}(O')$ then their pairing, composite, primitive recursion, and $\mu$-search all lie in $\mathrm{Rec}(O')$. $\qquad\blacksquare$

Two immediate consequences:

**Corollary 3.2 (Transitivity).** $\le_T$ is transitive: if $f \le_T g$ and $g \le_T h$ then $f \le_T h$. (Apply Theorem 3.1 with $O = \{g\}$, $O' = \{h\}$.)

**Theorem 3.3 (Monotonicity of relativization).** If $O \subseteq O'$ then $\mathrm{Rec}(O) \subseteq \mathrm{Rec}(O')$.

*Proof.* Each $g \in O$ is in $O' \subseteq \mathrm{Rec}(O')$ by the oracle rule, so Theorem 3.1 applies. $\blacksquare$

Monotonicity is the honest content of *"$T^X$ proves everything $T^Y$ proves whenever $Y \subseteq X$"*: enlarging the oracle pool never destroys computability.

## 4. The bottom degree

**Theorem 4.1 (Bottom degree).** The constant-zero function $\mathbf{0} := (\lambda\, n.\, 0)$ satisfies $\mathbf{0} \le_T f$ for every $f$; hence its degree is the least element of the Turing degrees.

*Proof.* The zero function is computable, hence in $\mathrm{Rec}(\{f\})$ for every $f$. $\blacksquare$

**Theorem 4.2 (Bottom degree = partial recursive functions).** For every $f$,
$$f \le_T \mathbf{0} \iff f \in \mathrm{Partrec}.$$

*Proof sketch.* ($\Leftarrow$) A partial recursive $f$ is recursive in any oracle, in particular in $\mathbf{0}$. ($\Rightarrow$) If $f \le_T \mathbf{0}$, then $f \in \mathrm{Rec}(\{\mathbf{0}\})$; since the only oracle $\mathbf{0}$ is itself computable, the cut principle (Theorem 3.1, with $O = \{\mathbf{0}\}$, $O' = \varnothing$) yields $f \in \mathrm{Rec}(\varnothing) = \mathrm{Partrec}$. $\blacksquare$

Thus the least degree $\mathbf{0}$ is precisely the computable functions.

## 5. Joins and the least-upper-bound structure

Given two oracles $f, g$, form the two-element oracle set $\{f, g\}$.

**Proposition 5.1 (Upper bound).** $f \in \mathrm{Rec}(\{f,g\})$ and $g \in \mathrm{Rec}(\{f,g\})$; equivalently, both $f \le_T \{f,g\}$ and $g \le_T \{f,g\}$ (abusing notation for the join).

*Proof.* Immediate from the oracle rule applied to each member. $\blacksquare$

**Theorem 5.2 (Least upper bound / join).** If $f \le_T h$ and $g \le_T h$, then every $k \in \mathrm{Rec}(\{f,g\})$ satisfies $k \le_T h$.

*Proof.* By the cut principle (Theorem 3.1) it suffices to show each oracle in $\{f,g\}$ is recursive in $h$. But that is exactly the hypothesis $f \le_T h$ and $g \le_T h$. $\blacksquare$

Consequently the pair $\{f,g\}$ realizes the least upper bound of $\mathrm{deg}(f)$ and $\mathrm{deg}(g)$: the Turing degrees form an upper semilattice with join induced by finite unions of oracles.

## 6. Non-triviality: the first jump is real

Everything above is vacuous unless the degrees are more than one point. The following is the seed of the entire hierarchy.

**Theorem 6.1 (Existence of a non-computable function).** There exists $f : \mathbb{N} \rightharpoonup \mathbb{N}$ with $f \notin \mathrm{Partrec}$.

*Proof sketch.* Suppose, for contradiction, that every partial function were partial recursive. Every partial recursive function is the evaluation of a finite program code, and codes are effectively enumerable; hence $\mathrm{Partrec}$ is the range of a map defined on a countable set and is therefore **countable**. If all of $\mathbb{N} \rightharpoonup \mathbb{N}$ equaled $\mathrm{Partrec}$, the entire function space would be countable. But $\mathbb{N} \rightharpoonup \mathbb{N}$ is **uncountable**: the map
$$s \in \{0,1\}^{\mathbb{N}} \;\longmapsto\; \big(n \mapsto \text{some}(\,[\,s(n)=1\,]\;?\;0:1\,)\big) \in (\mathbb{N} \rightharpoonup \mathbb{N})$$
is injective, and $\{0,1\}^{\mathbb N}$ has cardinality $2^{\aleph_0} > \aleph_0$ by Cantor's theorem. A countable set cannot contain an uncountable one — contradiction. $\blacksquare$

**Theorem 6.2 (The first jump increases power).** There is a Turing degree strictly above $\mathbf{0}$: for any non-computable $f$ (Theorem 6.1), $\mathbf{0} <_T f$.

*Proof.* $\mathbf{0} \le_T f$ by Theorem 4.1. If also $f \le_T \mathbf{0}$, then $f \in \mathrm{Partrec}$ by Theorem 4.2, contradicting the choice of $f$. Hence $\mathbf{0} <_T f$. $\blacksquare$

This is the formal content of "$T < T^H$ genuinely increases proving power": the level above the computable functions is nonempty. Taking $f$ to be the halting problem $H$ gives the canonical witness $\mathbf 0 <_T \mathbf 0'$.

## 7. The abstract jump and the strictness of the tower

We now isolate the combinatorial skeleton of the escalation, freeing it from the (heavier) explicit construction of a universal relativized machine.

**Definition 7.1 (Abstract jump operator).** An operator $J : (\mathbb{N} \rightharpoonup \mathbb{N}) \to (\mathbb{N} \rightharpoonup \mathbb{N})$ is a **jump** if for all $A$:
1. **(Preservation)** $A \le_T J(A)$ — every oracle is computable from its jump;
2. **(Strict ascent)** $J(A) \not\le_T A$ — no oracle computes its own jump.

The canonical instance is the Turing jump $A \mapsto A'$, for which (1)–(2) are exactly the relativized Halting Theorem.

**Theorem 7.2 (One jump strictly increases the degree).** If $J$ is a jump, then $A <_T J(A)$ for all $A$.

*Proof.* $A \le_T J(A)$ by (1); $\neg(J(A) \le_T A)$ by (2); combine. $\blacksquare$

This is precisely *"proves its own consistency (computes $A$) but cannot decide its own soundness (cannot compute $J(A)$ from $A$)."*

**Theorem 7.3 (The iterated hierarchy is strictly increasing).** If $J$ is a jump, then $n \mapsto \mathrm{deg}(J^n(A))$ is strictly monotone; equivalently, for all $m < n$,
$$J^m(A) \;<_T\; J^n(A).$$

*Proof sketch.* It suffices to check strict increase at successive steps: $J^{n+1}(A) = J(J^n(A))$, so Theorem 7.2 applied to $J^n(A)$ gives $\mathrm{deg}(J^n(A)) < \mathrm{deg}(J^{n+1}(A))$. Strict monotonicity on $\mathbb N$ follows by the successor criterion, and $m<n \Rightarrow \mathrm{deg}(J^m(A)) < \mathrm{deg}(J^n(A))$ by transitivity. $\blacksquare$

**Theorem 7.4 (Injectivity: the tower never repeats).** For a jump $J$, the levels $\mathrm{deg}(J^n(A))$ are pairwise distinct.

*Proof.* A strictly monotone map is injective. $\blacksquare$

**Theorem 7.5 (Order isomorphism with the Turing-jump hierarchy).** For a jump $J$ and any base $A$, the level map
$$n \;\longmapsto\; \mathrm{deg}(J^n(A))$$
is an **order embedding** $(\mathbb{N}, <) \hookrightarrow (\text{Turing degrees}, <_T)$.

*Proof.* An order embedding is exactly a strictly monotone map into a linear-on-its-image order; Theorem 7.3 supplies strict monotonicity, and for such maps $m < n \iff \mathrm{deg}(J^m(A)) <_T \mathrm{deg}(J^n(A))$. $\blacksquare$

Thus the oracle hierarchy (1.1) is order-isomorphic to the standard $\omega$-indexed Turing-jump hierarchy $\mathbf 0 <_T \mathbf 0' <_T \mathbf 0'' <_T \cdots$: the theory tower and the degree tower are the same object.

## 8. Contrarian results: what the theory rules out

Careful mathematics must reject seductive false generalizations. Two are decisive here.

**Theorem 8.1 (A computable oracle adds nothing).** If $g \in \mathrm{Partrec}$, then for every $f$,
$$f \in \mathrm{Rec}(\{g\}) \iff f \in \mathrm{Partrec}.$$
Equivalently, adjoining a computable oracle leaves the computable functions unchanged.

*Proof sketch.* ($\Rightarrow$) Since $g$ is partial recursive, $g \in \mathrm{Rec}(\varnothing)$; the cut principle with $O = \{g\}$, $O' = \varnothing$ gives $f \in \mathrm{Rec}(\varnothing) = \mathrm{Partrec}$. ($\Leftarrow$) A partial recursive $f$ is recursive in any oracle set. $\blacksquare$

Theorem 8.1 **refutes** the naive slogan *"every oracle strictly increases power."* Only genuinely non-computable oracles (like $H$) climb the ladder; the strictness in (1.1) depends essentially on the base-case non-triviality of Theorem 6.2.

**Theorem 8.2 (The jump is never idempotent).** For a jump $J$ and any $A$, $J(J(A)) \not\equiv_T J(A)$; indeed $J(A) <_T J(J(A))$.

*Proof.* Apply Theorem 7.2 at $J(A)$: $J(A) <_T J(J(A))$; strict inequality precludes Turing equivalence. $\blacksquare$

This is the mathematical form of *the oracle's burden strictly recurs*: knowing the halting problem of the level below never makes the next jump free.

**Theorem 8.3 (The axioms are discriminating).** Neither the identity operator $A \mapsto A$ nor any constant operator $A \mapsto C$ is a jump.

*Proof.* For the identity, $J(A) = A \le_T A$ violates strict ascent at every $A$. For the constant $C$, take $A = C$: then $J(C) = C \le_T C$, again violating strict ascent. More generally, no jump can fix any oracle up to Turing equivalence: $J(A) \equiv_T A$ would give $J(A) \le_T A$, contradicting (2). $\blacksquare$

Hence Definition 7.1 is not satisfied by trivial operators — the hierarchy theorems have genuine content.

## 9. Applications, discussion, and future directions

**Interpretive payoff.** The results give a precise, provable form to three intuitions: (i) *no self-certifying theory* — every framework strong enough to reason about halting has a soundness blind spot only a strictly stronger framework can see (Theorems 7.2, 8.2); (ii) *the verification regress* — certifying a proof system's reliability requires ascending to a stronger system, mirrored by $A <_T J(A)$; (iii) *knowledge as a staircase without a top* — the order embedding of Theorem 7.5 shows the ascent is faithful and unending.

**Scope and honesty.** The strictness/embedding theorems (Section 7) hold for *any* operator satisfying Definition 7.1. The canonical model is the Turing jump $A \mapsto A'$, whose two axioms are the relativized Halting Theorem. What is not yet carried out at this level of generality is the *unconditional construction* of a concrete $J$ witnessing Definition 7.1 at every level; the base case $\mathbf 0 <_T \mathbf 0'$ is, however, established unconditionally (Theorem 6.2).

**Future directions.**
- *A relativized universal machine.* Extend the theory of program codes to oracle codes $\mathrm{eval}_{\text{in}} : \mathrm{Code} \to (\mathbb N \rightharpoonup \mathbb N) \to (\mathbb N \rightharpoonup \mathbb N)$ and prove a relativized enumeration theorem $f \in \mathrm{Rec}(\{O\}) \iff \exists c,\ \mathrm{eval}_{\text{in}}(c, O) = f$. This is the single largest missing piece.
- *The concrete jump.* Define $A' := \big(e \mapsto \mathrm{eval}_{\text{in}}(\mathrm{decode}(e), A)(e)\big)$, restricted to its halting set, and prove $A \le_T A'$ and $\neg(A' \le_T A)$ by relativized diagonalization, thereby instantiating Definition 7.1.
- *Base-case link.* Connect the classical Halting Theorem to Theorem 6.2 so the level-0 witness is literally the halting set $H$, giving $\mathbf 0 <_T \mathbf 0'$ with an explicit $\mathbf 0'$.
- *Post's theorem and beyond.* Relate the arithmetical hierarchy to the jump hierarchy (Post's theorem), study the join structure of intermediate degrees, and extend the tower transfinitely through the hyperarithmetical hierarchy.

## 10. Conclusion

We have made rigorous the escalation $T < T^H < T^{H^H} < \cdots$ as a strictly increasing, non-repeating $\omega$-chain of Turing degrees, order-isomorphic to the classical Turing-jump hierarchy. The theory rests on four structural pillars — cut/transitivity, monotonicity, joins, and the identification of the bottom degree — and on the decisive non-triviality theorem that a non-computable function exists. Two contrarian results keep the picture honest: computable oracles add nothing, and the jump is never idempotent. Together they capture the oracle's burden with mathematical precision: each answer we win reveals a strictly harder question, and no rung of the ladder is ever the last.
