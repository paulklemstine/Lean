# Complementation as a Free Involution: Exact Transport, Parity, and the Complete Spectrum of Framed-Puzzle Assembly Spaces

**Author:** Aristotle

**Date:** 2026-08-24

---

## Abstract

We study *framed puzzles*: mechanical interlock systems on $n$ variables in which a variable is realised by a matched pair of pieces (a *true* piece and a *false* piece), a clause piece exposes finitely many input notches each milled for a specific variable and polarity, and an *assembly* is a choice of one variable piece per variable that lets every clause piece snap into place. Global *tab–blank complementation* re-mills every notch for the opposite polarity.

Our first result upgrades the classical observation that complementation preserves solvability into an exact statement about complete solution spaces: complementation transports the assembly space of a puzzle onto that of its complement by Boolean negation, so the two spaces are equinumerous via an explicit bijection. Because a Boolean vector is never its own negation, the induced involution on the Boolean cube is fixed-point free whenever $n \geq 1$; consequently the *untagged* union of the two assembly spaces has even cardinality. We show that this settles the conjectured parity law in a strictly stronger form: no non-self-duality hypothesis is required, self-dual puzzles have an even number of assemblies rather than being fixed configurations, and the unique fixed configuration in the entire theory is the empty assembly on zero variables — which is precisely where the parity conclusion fails.

We then replace parity by an explicit orbit decomposition: fixing the polarity of the first variable yields a computable section of the orbit map, so any complement-stable set of assemblies has cardinality exactly twice its gauge. As a by-product, complementation, viewed as a permutation of the $2^n$-element cube, has sign $(-1)^{2^{n-1}}$, hence is odd exactly when $n = 1$.

Finally we prove that the parity constraint is the *only* constraint. A single *exclusion piece* forbids exactly one assembly; consequently every subset of the Boolean cube is exactly the assembly space of a framed puzzle, realisable with $2^n - |S|$ clause pieces. This complete expressiveness gives: the single-puzzle assembly spectrum is all of $\{0,1,\dots,2^n\}$ (so odd counts occur); the combined spectrum for $n \geq 1$ is exactly the even numbers $\le 2^n$; self-dual assembly spaces occur in every even size $\le 2^n$; and there are exactly $2^{2^{n-1}}$ complement-stable assembly spaces, the square root of the total $2^{2^n}$. We close with a cyclic generalisation: with $d$ interlock depths, the combined assembly space of the $d$ depth-shifts has cardinality exactly $d$ times its gauge, so $d$ divides it; tab–blank parity is the $d = 2$ slice.

**Keywords:** free involution, tab–blank complementation, Boolean cube, assembly space, orbit decomposition, polarity gauge, constraint expressiveness, spectrum, cyclic symmetry.

---

## 1. Introduction

### 1.1 The phenomenon

Interlock systems — jigsaw puzzles, dovetail joints, snap-fit assemblies — encode their combinatorics in a binary alphabet of complementary shapes. A tab mates with a blank; a tab does not mate with a tab. The mating relation is *anti-symmetric in shape*: what matters is not which shape is present but that the two shapes at a joint are opposite.

This has an immediate structural consequence. Reverse the polarity of *every* interlock simultaneously, and every joint that used to mate still mates. Solvability is invariant under global complementation. This observation is old and is usually presented as a curiosity.

The present work asks what the observation is a shadow *of*, and answers the question completely. The invariance of solvability is the $\pi_0$-level statement of a much finer fact: complementation is an order-two **transport of complete solution spaces**, and because that transport is *free* — no configuration is fixed — it imposes an arithmetic constraint on solution counts. The constraint is exactly one bit: parity. And that bit is *all* it imposes: every even count compatible with the size of the configuration space is realised.

### 1.2 The conjecture and its correction

The problem was posed in the following hedged form.

> **Conjecture (as posed).** For every framed puzzle not isomorphic to its global tab–blank complement, complementation acts freely on the disjoint union of the two assembly spaces, forcing their combined cardinality to be even.

The hedge — "not isomorphic to its complement" — anticipates that a *self-dual* puzzle might be a fixed point of the symmetry and so escape the parity law.

We prove the conjecture (Theorem 5.5) and simultaneously show that its hypothesis is misdirected. Freeness of the action is a property of the **configuration space**, not of the puzzle: a Boolean vector is never its own complement, so the involution has no fixed points as soon as $n \geq 1$, whatever the puzzle. Self-duality does not create a fixed point; it merely collapses the two assembly spaces onto one, on which the involution *still* acts freely. The conclusion for self-dual puzzles is therefore *stronger* than in the general case: such a puzzle has an even number of assemblies (Theorem 5.4). The hypothesis in the conjecture does exactly one thing: it excludes $n = 0$, where every puzzle is vacuously self-complementary, and where the parity law genuinely fails (Section 6).

### 1.3 Contributions

1. **Exact transport** (Theorem 4.3): $A(P^{*}) = \sigma(A(P))$, hence $|A(P^{*})| = |A(P)|$, with an explicit bijection of solution spaces. This refines solvability invariance.
2. **Untagged parity** (Theorem 5.3): $|A(P) \cup A(P^{*})|$ is even for $n \geq 1$, with no non-self-duality hypothesis. The intersection is likewise even.
3. **Refutation of the self-duality boundary** (Theorem 5.4, Section 6): self-dual puzzles have an even assembly count; the unique fixed configuration in the theory is the empty assembly on zero variables, and $n = 0$ is the exact sharp boundary.
4. **Orbit decomposition with a computable section** (Theorem 7.2): a complement-stable set of assemblies has cardinality exactly twice its polarity gauge.
5. **Sign of complementation** (Theorem 7.5): as a permutation of the cube its sign is $(-1)^{2^{n-1}}$; it is odd exactly when $n = 1$.
6. **Complete expressiveness** (Theorem 8.3): every subset of the cube is exactly an assembly space, realised with $2^n - |S|$ clause pieces.
7. **Exact spectra** (Theorems 9.1, 9.3, 9.5): single counts fill $\{0,\dots,2^n\}$; combined counts for $n \geq 1$ are exactly the even numbers $\le 2^n$; self-dual spaces occur in every even size $\le 2^n$.
8. **Density of self-duality** (Theorem 10.3): exactly $2^{2^{n-1}}$ complement-stable assembly spaces, the square root of the total $2^{2^n}$.
9. **Cyclic generalisation** (Theorem 11.4): with $d$ interlock depths, $d$ divides the combined assembly count.

---

## 2. The framed-puzzle model

### 2.1 Edges, polarity, and mating

We work over a two-element alphabet of interlock shapes with a fixed-point-free complementation $e \mapsto e^{\mathrm{c}}$, and we say that two edges **mate** when each is the complement of the other. A truth value is encoded as an edge shape by an injective encoding $\mathrm{enc} : \{\texttt{true},\texttt{false}\} \to \text{Edges}$.

The only property of this encoding that we use is the following dictionary, which is a direct consequence of the injectivity of both $\mathrm{enc}$ and complementation.

**Lemma 2.1 (Local dictionary).** *Let $a$ be a choice of variable pieces and let $(i, p)$ be a notch milled for variable $i$ and polarity $p$. Then the notch interlocks with the installed variable-$i$ piece if and only if $a_i = p$.*

*Proof.* The installed piece exposes the edge $\mathrm{enc}(a_i)$; the notch presents the edge $\mathrm{enc}(p)^{\mathrm{c}}$. Mating means $\mathrm{enc}(a_i) = \mathrm{enc}(p)$, which by injectivity of $\mathrm{enc}$ is equivalent to $a_i = p$. $\square$

From here on we work with the dictionary rather than the physical alphabet.

### 2.2 Puzzles and assemblies

Fix $n \in \mathbb{N}$.

**Definition 2.2 (Literal input, clause piece, framed puzzle).**
A **literal input** (notch) is a pair $\ell = (i, p) \in \{1,\dots,n\} \times \{\texttt{true},\texttt{false}\}$: a variable index together with the polarity that the input edge is milled for. A **clause piece** is a finite list $c$ of literal inputs. A **framed puzzle on $n$ variables** is a finite list $P$ of clause pieces. The frame and the $n$ matched pairs of variable pieces are implicit in the variable set.

**Definition 2.3 (Assembly).**
An **assembly** (or *commitment*) is a point $a$ of the Boolean cube $\{\texttt{true},\texttt{false}\}^n$: a choice of one of the two variable pieces for each variable. The literal input $\ell = (i,p)$ **fits** under $a$ if $a_i = p$ (Lemma 2.1). A clause piece $c$ **snaps into place** under $a$ if some $\ell \in c$ fits under $a$. The assembly $a$ **assembles** $P$, written $a \models P$, if every clause piece of $P$ snaps into place under $a$.

**Definition 2.4 (Assembly space).**
$$A(P) \;=\; \{\, a \in \{\texttt{true},\texttt{false}\}^n \;:\; a \models P \,\} .$$

Assembly is decidable by finite enumeration, and $A(P)$ is a finite set of size at most $2^n$. Note that $A$ is not injective: puzzles differing by repetition or reordering of clause pieces, or of notches within a piece, have the same assembly space. All our "self-dual" statements are at the level of assembly spaces, which is the invariant level.

**Remark 2.5 (Relation to propositional logic).** Under Definition 2.3, a notch is a literal, a clause piece is a disjunction, a puzzle is a CNF formula, and an assembly is a satisfying assignment. The framed model is a faithful mechanical presentation of Boolean constraint satisfaction; the point of the presentation is that the symmetry studied below is a physical operation on the hardware (re-milling), not an artefact of a syntax.

### 2.3 Complementation

**Definition 2.6.** The **complement** of a clause piece $c$ is $c^{*} = \{(i, \lnot p) : (i,p) \in c\}$ (pointwise on the list), and the complement of a puzzle $P$ is $P^{*} = \{c^{*} : c \in P\}$. **Complementation of assemblies** is
$$\sigma : \{\texttt{true},\texttt{false}\}^n \to \{\texttt{true},\texttt{false}\}^n, \qquad \sigma(a)_i = \lnot a_i .$$

**Lemma 2.7.** $c \mapsto c^{*}$, $P \mapsto P^{*}$ and $\sigma$ are involutions. In particular $\sigma$ is a bijection.

*Proof.* Immediate from $\lnot\lnot p = p$, applied pointwise and then list-wise. $\square$

**Lemma 2.8 (Freeness on the cube).** *If $n \geq 1$ then $\sigma(a) \neq a$ for every $a$.*

*Proof.* Evaluate at coordinate $1$: $\sigma(a)_1 = \lnot a_1 \neq a_1$. $\square$

Lemma 2.8 is the entire engine of the parity results, and it is worth emphasising what it does and does not depend on: it depends only on $n \geq 1$, and not at all on $P$.

---

## 3. A parity principle for free involutions

**Theorem 3.1 (Free-involution parity).** *Let $S$ be a finite set and $g : S \to S$ satisfy $g(g(a)) = a$ and $g(a) \neq a$ for all $a \in S$. Then $|S|$ is even.*

*Proof.* Two proofs, both used below.

*(i) Signed product.* Consider $\prod_{a \in S} (-1)$ in $\mathbb{Z}$. Pairing $a$ with $g(a)$ is an involution of the index set without fixed points under which the constant factor $-1$ satisfies $(-1)\cdot(-1) = 1$; telescoping over the pairs gives $\prod_{a\in S}(-1) = 1$. But the product equals $(-1)^{|S|}$, so $(-1)^{|S|} = 1$, and were $|S|$ odd we would get $-1 = 1$, a contradiction.

*(ii) Orbit partition.* The orbits of $\langle g\rangle$ on $S$ have size $1$ or $2$; size $1$ is excluded by freeness; the orbits partition $S$; hence $|S| = 2 \cdot (\#\text{orbits})$. $\square$

Proof (ii) will be refined in Section 7 to an *explicit* orbit count with a computable section.

---

## 4. Exact transport of assembly spaces

**Lemma 4.1 (Literal level).** *For every assembly $a$ and literal input $\ell = (i,p)$, the complemented notch $(i, \lnot p)$ fits under $\sigma(a)$ if and only if $\ell$ fits under $a$.*

*Proof.* $\sigma(a)_i = \lnot p \iff \lnot a_i = \lnot p \iff a_i = p$. $\square$

**Lemma 4.2 (Clause level).** *For every assembly $a$ and clause piece $c$, the piece $c^{*}$ snaps into place under $\sigma(a)$ if and only if $c$ snaps into place under $a$.*

*Proof.* $c \mapsto c^{*}$ is a bijection of the notch list of $c$ onto that of $c^{*}$ carrying $\ell$ to its complement; combine with Lemma 4.1 and quantify existentially over notches. $\square$

**Theorem 4.3 (Exact transport).** *For every framed puzzle $P$ on $n$ variables and every assembly $a$,*
$$\sigma(a) \models P^{*} \iff a \models P .$$
*Consequently*
$$A(P^{*}) \;=\; \sigma\bigl(A(P)\bigr) \quad\text{and}\quad |A(P^{*})| = |A(P)| ,$$
*and $\sigma$ restricts to an explicit bijection $A(P) \to A(P^{*})$.*

*Proof.* The clause pieces of $P^{*}$ are exactly the complements of those of $P$, so the biconditional follows from Lemma 4.2 quantified universally over pieces. For the set identity: if $b \models P^{*}$, apply the biconditional to $a = \sigma(b)$, using $\sigma(\sigma(b)) = b$, to get $\sigma(b) \models P$, whence $b = \sigma(\sigma(b)) \in \sigma(A(P))$; conversely if $b = \sigma(a)$ with $a \models P$ then $b \models P^{*}$ directly. Cardinality equality holds because $\sigma$ is injective. $\square$

**Corollary 4.4 (Solvability invariance).** $A(P) \neq \emptyset \iff A(P^{*}) \neq \emptyset$.

Corollary 4.4 is the classical statement. Theorem 4.3 shows it is the image of the transport theorem under the functor "is the space nonempty?", i.e. its $\pi_0$.

**Corollary 4.5 (Equivalence of solution spaces).** The assignment $a \mapsto \sigma(a)$ is an explicit isomorphism of the solution space of $P$ with that of $P^{*}$, self-inverse under the identification $P^{**} = P$.

---

## 5. The untagged parity theorem

**Definition 5.1 (Combined assembly space).**
$$C(P) \;=\; A(P) \cup A(P^{*}) \subseteq \{\texttt{true},\texttt{false}\}^n .$$

We stress the word *untagged*. One may instead form the disjoint (tagged) union $A(P) \sqcup A(P^{*})$; there the involution "swap the tag and apply $\sigma$" is free for trivial reasons and its parity conclusion carries no information about the puzzle's combinatorics. The untagged union is the substantive object: elements of $A(P) \cap A(P^{*})$ are counted once, and one must argue that no collapse creates a fixed point.

**Lemma 5.2 (Stability).** $C(P)$ is $\sigma$-stable: $a \in C(P) \Rightarrow \sigma(a) \in C(P)$.

*Proof.* If $a \models P$ then $\sigma(a) \models P^{*}$ by Theorem 4.3. If $a \models P^{*}$ then, writing $a = \sigma(\sigma(a))$ and applying Theorem 4.3 in the direction $\sigma(b)\models P^{*} \Rightarrow b \models P$ with $b = \sigma(a)$, we get $\sigma(a) \models P$. $\square$

**Theorem 5.3 (Untagged parity).** *For every framed puzzle $P$ on $n \geq 1$ variables, $|C(P)|$ is even. The same holds for $|A(P) \cap A(P^{*})|$.*

*Proof.* By Lemma 5.2 the set $C(P)$ is stable under $\sigma$; by Lemma 2.7 the restriction is an involution; by Lemma 2.8 it is fixed-point free. Apply Theorem 3.1. The intersection is $\sigma$-stable by the same two implications used in Lemma 5.2 taken conjunctively, so the same argument applies. $\square$

**Theorem 5.4 (Self-dual parity).** *Let $P$ be a framed puzzle on $n \geq 1$ variables with $A(P^{*}) = A(P)$ (a self-dual assembly space; in particular this holds if $P^{*} = P$). Then $|A(P)|$ is even.*

*Proof.* $C(P) = A(P) \cup A(P) = A(P)$; apply Theorem 5.3. $\square$

Theorem 5.4 is the precise sense in which the conjecture's hedge was inverted: self-duality *strengthens* the conclusion. It is not a case to be excluded but the case in which the free involution acts on a single space rather than exchanging two.

**Theorem 5.5 (The conjecture as posed).** *If $P^{*} \neq P$, then $|C(P)|$ is even.*

*Proof.* If $n \geq 1$, apply Theorem 5.3, ignoring the hypothesis. If $n = 0$, then every clause piece is the empty list (there is no variable index to mill for), so $P^{*} = P$, contradicting the hypothesis; the case is vacuous. $\square$

The proof exhibits the hypothesis as a disguised dimension condition.

---

## 6. Sharpness: the boundary is $n = 0$

**Proposition 6.1.** *Every framed puzzle on zero variables satisfies $P^{*} = P$.*

*Proof.* A notch carries a variable index in the empty set, so every clause piece is the empty list, and complementation is the identity on it. $\square$

**Proposition 6.2.** *On zero variables the cube has exactly one point, the empty assembly $\varepsilon$, and $\sigma(\varepsilon) = \varepsilon$. The empty puzzle $P = \emptyset$ satisfies $A(P) = \{\varepsilon\}$, hence $|C(P)| = 1$, which is odd.*

*Proof.* There are no coordinates, so $\sigma$ is the identity and the cube is a singleton. The empty puzzle has no clause pieces, so the universal quantification in Definition 2.3 is vacuous and $\varepsilon \models P$. $\square$

**Corollary 6.3 (Unique fixed configuration).** The empty assembly on zero variables is the unique fixed point of complementation anywhere in the theory, and it is exactly where the parity conclusion fails.

Propositions 6.1 and 6.2 combine to explain Theorem 5.5 completely: the hypothesis "$P^{*}\neq P$" is *unsatisfiable* at $n = 0$ and *automatic in effect* at $n\ge1$ (in the sense that the conclusion holds there regardless). The hedge is a dimension filter wearing a symmetry costume.

**Worked examples.** Let $n = 2$.

* $P_1 = (x_1) \wedge (x_2)$, i.e. two clause pieces each with one notch, milled for $\texttt{true}$. Then $A(P_1) = \{(\texttt{T},\texttt{T})\}$ and $A(P_1^{*}) = \{(\texttt{F},\texttt{F})\}$, so $|C(P_1)| = 2$: one free orbit. $P_1^{*} \neq P_1$, so $P_1$ is an instance of the conjecture as posed.
* $P_2 = (x_1 \vee \lnot x_1)$, a single tautological clause piece with two notches. Then $A(P_2^{*}) = A(P_2)$ is the whole cube, of size $4$ — even, as Theorem 5.4 predicts, and comprising two free orbits.

---

## 7. Orbit structure, gauge fixing, and sign

Parity is a one-bit shadow of a decomposition. We now make the decomposition explicit, with a *computable* section of the orbit map.

**Definition 7.1 (Polarity gauge).** For $n \geq 1$ and $S \subseteq \{\texttt{true},\texttt{false}\}^n$,
$$\Gamma(S) \;=\; \{\, a \in S : a_1 = \texttt{true} \,\}.$$

**Theorem 7.2 (Orbit decomposition).** *Let $n \geq 1$ and let $S$ be $\sigma$-stable. Then*
$$S \;=\; \Gamma(S) \;\sqcup\; \sigma\bigl(\Gamma(S)\bigr), \qquad\text{hence}\qquad |S| \;=\; 2\,|\Gamma(S)| .$$

*Proof.* *Disjointness:* every element of $\Gamma(S)$ has first coordinate $\texttt{true}$, every element of $\sigma(\Gamma(S))$ has first coordinate $\texttt{false}$. *Covering:* let $a \in S$. If $a_1 = \texttt{true}$ then $a \in \Gamma(S)$. If $a_1 = \texttt{false}$ then $\sigma(a) \in S$ by stability and $\sigma(a)_1 = \texttt{true}$, so $\sigma(a) \in \Gamma(S)$ and $a = \sigma(\sigma(a)) \in \sigma(\Gamma(S))$. *Reverse inclusion:* $\Gamma(S) \subseteq S$ by definition and $\sigma(\Gamma(S)) \subseteq S$ by stability. *Cardinality:* $\sigma$ is injective, so $|\sigma(\Gamma(S))| = |\Gamma(S)|$; add over the disjoint union. $\square$

**Corollary 7.3.** For $n \geq 1$, $|C(P)| = 2\,|\Gamma(C(P))|$, and for a self-dual space $|A(P)| = 2\,|\Gamma(A(P))|$. In particular Theorem 5.3 is recovered with a witnessing section rather than an existence argument, and $|\Gamma(S)|$ *is* the number of orbits.

**Corollary 7.4 (Gauge of the cube).** $|\Gamma(\{\texttt{T},\texttt{F}\}^n)| = 2^{n-1}$. Hence no framed puzzle on $n$ variables has more than $2^{n-1}$ complementation orbits of assemblies.

The gauge depends on the choice of the distinguished variable; any variable serves, and the resulting gauges are in canonical bijection (compose with $\sigma$ on the appropriate half).

**Theorem 7.5 (Sign of complementation).** *Regard $\sigma$ as a permutation of the $2^n$-element cube. For $n \geq 1$,*
$$\operatorname{sgn}(\sigma) = (-1)^{2^{\,n-1}} .$$
*Hence $\sigma$ is an odd permutation exactly when $n = 1$, and even for all $n \geq 2$.*

*Proof.* $\sigma^2 = \mathrm{id}$ and $\sigma$ has no fixed points (Lemma 2.8), so $\sigma$ is a product of disjoint transpositions covering the whole cube; there are $2^n / 2 = 2^{n-1}$ of them, and each contributes $-1$ to the sign. For $n = 1$ the exponent is $1$, giving $-1$; for $n \geq 2$ the exponent $2^{n-1}$ is even, giving $+1$. $\square$

Thus the order-two edge symmetry has nontrivial image in $S_{2^n}/A_{2^n} \cong \mathbb{Z}/2$ in exactly one dimension. (At $n = 0$ the involution is the identity, consistent with Corollary 6.3.)

---

## 8. Complete expressiveness

Everything so far is a *constraint*. We now show the constraint side is fully expressive, which is what converts the parity law into a sharp characterisation.

**Definition 8.1 (Exclusion piece).** For $b \in \{\texttt{T},\texttt{F}\}^n$, let
$$E_b \;=\; \bigl[\,(1, \lnot b_1),\, (2, \lnot b_2),\, \dots,\, (n, \lnot b_n)\,\bigr],$$
the single clause piece exposing, for each variable, the input notch milled for the *opposite* of $b$'s choice at that variable.

**Lemma 8.2 (Exclusion).** *$E_b$ snaps into place under $a$ if and only if $a \neq b$.*

*Proof.* ($\Rightarrow$) If a notch $(i, \lnot b_i)$ of $E_b$ fits under $a$ then $a_i = \lnot b_i \neq b_i$, so $a \neq b$. ($\Leftarrow$) If $a \neq b$ then $a_i \neq b_i$ for some $i$, i.e. $a_i = \lnot b_i$ over the two-element polarity set, so the notch $(i, \lnot b_i)$ fits. $\square$

So one clause piece forbids exactly one assembly and permits all others.

**Theorem 8.3 (Complete expressiveness).** *For every $S \subseteq \{\texttt{T},\texttt{F}\}^n$ let*
$$P_S \;=\; \bigl[\, E_b \;:\; b \notin S \,\bigr].$$
*Then $A(P_S) = S$, and $P_S$ has exactly $2^n - |S|$ clause pieces. Consequently the map $P \mapsto A(P)$ is surjective onto the subsets of the Boolean cube.*

*Proof.* If $a \in S$ then for each clause piece $E_b$ of $P_S$ we have $b \notin S$, so $b \neq a$, so $E_b$ snaps into place by Lemma 8.2; hence $a \models P_S$. Conversely if $a \notin S$ then $E_a$ is one of the clause pieces, and by Lemma 8.2 it does *not* snap into place under $a$, so $a \not\models P_S$. The piece count is the number of excluded points, $2^n - |S|$. $\square$

**Remark 8.4 (Redundancy and complexity).** $P_S$ is maximally redundant: it uses one piece per *excluded* assembly, which is exponential in $n$ when $S$ is small. Nothing here bounds the *minimal* number of clause pieces realising a given $S$; the results below are therefore statements about framed puzzles of unbounded description size. For puzzles of bounded description size, counting assemblies is a $\#\mathrm{P}$-hard problem via the standard parsimonious reduction from satisfiability, so no comparably clean spectrum theorem should be expected there.

---

## 9. Exact spectra

**Theorem 9.1 (Single-puzzle spectrum).** *For every $k \leq 2^n$ there is a framed puzzle $P$ on $n$ variables with $|A(P)| = k$.*

*Proof.* Choose any $S$ with $|S| = k$ (possible since the cube has $2^n$ points) and take $P_S$ (Theorem 8.3). $\square$

**Corollary 9.2 (Odd counts occur).** For every $n$ there is a puzzle with an odd number of assemblies (take $k=1$).

Corollary 9.2 shows that the parity theorem could not have been about a single assembly space: it is intrinsically a statement about the complement-stable union.

**Lemma 9.3 (Stable sets of prescribed even size).** *Let $n \geq 1$ and $2k \leq 2^n$. Then there exists a $\sigma$-stable $S \subseteq \{\texttt{T},\texttt{F}\}^n$ with $|S| = 2k$.*

*Proof.* The gauge of the whole cube has $2^{n-1} \geq k$ elements (Corollary 7.4), so choose $T$ a $k$-element subset of it and put $S = T \cup \sigma(T)$. Stability: $\sigma(T) \subseteq S$ and $\sigma(\sigma(T)) = T \subseteq S$. Disjointness of $T$ and $\sigma(T)$: elements of $T$ have first coordinate $\texttt{true}$, elements of $\sigma(T)$ have first coordinate $\texttt{false}$. Hence $|S| = |T| + |\sigma(T)| = 2k$. $\square$

**Theorem 9.4 (Combined spectrum).** *Let $n \geq 1$ and $2k \leq 2^n$. Then some framed puzzle on $n$ variables has $|C(P)| = 2k$.*

*Proof.* Take $S$ as in Lemma 9.3 and $P = P_S$. Then $A(P) = S$ by Theorem 8.3, and $A(P^{*}) = \sigma(A(P)) = \sigma(S) = S$ by Theorem 4.3 and stability. So $C(P) = S \cup S = S$ has $2k$ elements. $\square$

**Theorem 9.5 (Exact characterisation of combined counts).** *Let $n \geq 1$. A natural number $m$ satisfies $m = |C(P)|$ for some framed puzzle $P$ on $n$ variables **if and only if** $m$ is even and $m \leq 2^n$.*

*Proof.* ($\Rightarrow$) Evenness is Theorem 5.3; the bound holds because $C(P)$ is a subset of the $2^n$-point cube. ($\Leftarrow$) Write $m = 2k$ and apply Theorem 9.4. $\square$

This is the sharp boundary the programme sought: **freeness forces evenness; expressiveness forces nothing else.** Complementation contributes exactly one bit of global information about a framed puzzle.

**Theorem 9.6 (Self-dual spectrum).** *Let $n \geq 1$ and $2k \leq 2^n$. Then there is a framed puzzle $P$ on $n$ variables with $A(P^{*}) = A(P)$ and $|A(P)| = 2k$.*

*Proof.* The puzzle $P_S$ of Theorem 9.4 has $A(P_S^{*}) = \sigma(S) = S = A(P_S)$. $\square$

So self-dual assembly spaces exist in every admissible size; self-duality is generic rather than degenerate, and it never produces a fixed configuration.

---

## 10. The density of self-duality

Because every subset of the cube is an assembly space (Theorem 8.3), *counting assembly spaces is counting subsets*, and counting self-dual assembly spaces is counting $\sigma$-stable subsets. The gauge computes this exactly.

**Definition 10.1.** $\mathcal{S}_n \;=\; \{\, S \subseteq \{\texttt{T},\texttt{F}\}^n \;:\; \sigma(S) \subseteq S \,\}$, the family of complement-stable subsets.

**Lemma 10.2 (Gauge parameterisation).** *Let $n \geq 1$ and write $G = \Gamma(\{\texttt{T},\texttt{F}\}^n)$ for the gauge of the full cube, $|G| = 2^{n-1}$. The maps*
$$S \;\longmapsto\; S \cap G, \qquad T \;\longmapsto\; T \cup \sigma(T)$$
*are mutually inverse bijections between $\mathcal{S}_n$ and the powerset of $G$.*

*Proof.* *Well-definedness.* $S \cap G \subseteq G$ trivially; and $T \cup \sigma(T)$ is stable because $\sigma(T \cup \sigma(T)) = \sigma(T) \cup T$.

*Reconstruction ($S \mapsto S\cap G \mapsto S$).* One inclusion is stability of $S$. For the other, let $a \in S$: if $a_1 = \texttt{true}$ then $a \in S \cap G$; otherwise $\sigma(a) \in S \cap G$ by stability, and $a = \sigma(\sigma(a))$.

*Section ($T \mapsto T\cup\sigma(T) \mapsto T$).* Let $T \subseteq G$. Elements of $T$ lie in $G$, so $T \subseteq (T\cup\sigma(T))\cap G$. Conversely an element of $\sigma(T)$ has first coordinate $\texttt{false}$ and so is not in $G$; hence $(T\cup\sigma(T))\cap G = T$. $\square$

**Theorem 10.3 (Exact count of self-dual assembly spaces).** *For $n \geq 1$,*
$$|\mathcal{S}_n| \;=\; 2^{\,2^{\,n-1}} , \qquad |\mathcal{S}_n|^2 \;=\; 2^{\,2^{\,n}} \;=\; \#\{\text{all assembly spaces}\}.$$
*In particular $|\mathcal{S}_n| < 2^{2^n}$ strictly.*

*Proof.* By Lemma 10.2, $|\mathcal{S}_n| = 2^{|G|} = 2^{2^{n-1}}$. Squaring, $2^{2^{n-1}}\cdot 2^{2^{n-1}} = 2^{2^{n-1}+2^{n-1}} = 2^{2^n}$. The total number of subsets of the cube is $2^{2^n}$, and every subset is an assembly space by Theorem 8.3. Strictness holds because $2^{n-1} < 2^n$ for $n \geq 1$. $\square$

**Interpretation.** Self-duality is exactly a *square-root condition*: the self-dual assembly spaces are, in count, the square root of all assembly spaces — doubly-exponentially rare. Yet by Theorem 9.6 they occur in every admissible size. Rarity in the family combined with ubiquity across sizes is the signature of a symmetry class, not a degeneracy.

Small cases: $|\mathcal{S}_1| = 2$ of $4$; $|\mathcal{S}_2| = 4$ of $16$; $|\mathcal{S}_3| = 16$ of $256$; $|\mathcal{S}_4| = 256$ of $65536$.

**Remark 10.4.** This counts stable *assembly spaces*, not self-dual puzzles as syntactic objects, of which there are infinitely many (pieces may be repeated and reordered). Each stable space has a canonical realising puzzle, namely $P_S$.

---

## 11. Cyclic generalisation: $d$ interlock depths

The number two entered only through the order of the involution. We now replace tab/blank by $d$ distinct **interlock depths**.

**Definition 11.1.** A $d$-ary literal input is a pair $(i, t) \in \{1,\dots,n\} \times \mathbb{Z}/d$: a variable index and a required milling depth. A $d$-ary clause piece is a list of such inputs, a $d$-ary framed puzzle a list of clause pieces, and a $d$-ary assembly a map $a : \{1,\dots,n\} \to \mathbb{Z}/d$. The input $(i,t)$ fits under $a$ iff $a_i = t$; assembly is defined as before. Write $A_d(P)$ for the assembly space inside $(\mathbb{Z}/d)^n$.

**Definition 11.2 (Depth shift).** For $t \in \mathbb{Z}/d$, deepen every mill by $t$: on pieces, $(i,s)\mapsto(i,s+t)$, giving $P^{+t}$; on assemblies, $\tau_t(a)_i = a_i + t$.

**Lemma 11.3 (Exact transport, cyclic form).** *$\tau_t(a) \models P^{+t}$ if and only if $a \models P$.*

*Proof.* At the input level, $\tau_t(a)_i = s+t \iff a_i + t = s + t \iff a_i = s$; the shift is a bijection of inputs of $c$ onto inputs of $c^{+t}$, so the equivalence lifts to pieces and then to puzzles. $\square$

Define the **combined space of all depth shifts**,
$$C_d(P) \;=\; \bigcup_{t \in \mathbb{Z}/d} A_d\bigl(P^{+t}\bigr) \subseteq (\mathbb{Z}/d)^n .$$
It is shift-stable: if $a \models P^{+s}$ then $\tau_t(a) \models P^{+(s+t)}$ by Lemma 11.3 and $(P^{+s})^{+t} = P^{+(s+t)}$.

**Definition 11.4 (Depth gauge).** For $n\ge1$, $\Gamma_d(S) = \{a \in S : a_1 = 0\}$.

**Theorem 11.5 (Cyclic orbit decomposition).** *Let $n \geq 1$ and let $S \subseteq (\mathbb{Z}/d)^n$ be shift-stable. Then the map*
$$\Gamma_d(S)\times \mathbb{Z}/d \longrightarrow S, \qquad (g,t)\longmapsto \tau_t(g)$$
*is a bijection, so $|S| = d \cdot |\Gamma_d(S)|$.*

*Proof.* *Surjectivity:* given $a \in S$, put $t = a_1$ and $g = \tau_{-t}(a)$; then $g \in S$ by stability, $g_1 = 0$ so $g \in \Gamma_d(S)$, and $\tau_t(g) = a$. *Injectivity:* if $\tau_t(g) = \tau_{t'}(g')$ with $g_1 = g'_1 = 0$, then evaluating at coordinate $1$ gives $t = t'$, and cancelling $t$ coordinatewise gives $g = g'$. $\square$

**Theorem 11.6 (Cyclic divisibility).** *For $n \geq 1$ and any $d$-ary framed puzzle $P$, $\;|C_d(P)| = d\cdot|\Gamma_d(C_d(P))|$; in particular $d \mid |C_d(P)|$.*

*Proof.* $C_d(P)$ is shift-stable; apply Theorem 11.5. $\square$

For $d = 2$ this is the tab–blank parity theorem, expressed additively. At $n = 0$ the cube is a single point fixed by every shift and $|C_d(P)| = 1$, so $n \geq 1$ remains the exact boundary for every $d$: the obstruction is dimensional, not symmetry-theoretic.

**Interpretation.** The constraint on solution counts is *the order of the group acting freely on the configuration space*. Parity is the $d=2$ slice of a divisibility law valid for every interlock alphabet carrying a transitive cyclic mill symmetry.

---

## 12. Algorithms

The theory is entirely constructive, and each theorem corresponds to a short algorithm.

**(A) Assembly enumeration.** Given $P$ with $m$ clause pieces of total notch count $L$, iterate over all $2^n$ assignments and test each piece; cost $O(2^n \cdot L)$. Returns $A(P)$ explicitly.

**(B) Combined-space computation and parity check.** Compute $A(P)$ and $A(P^{*})$ by (A) and union them; by Theorem 5.3 the count must be even for $n \geq 1$. Cost $O(2^n L)$. This is the empirical test of the parity theorem.

**(C) Gauge/orbit extraction.** Given a stable $S$, output $\Gamma(S) = \{a\in S: a_1 = \texttt{true}\}$ and the orbit list $\{(g,\sigma g)\}_{g\in\Gamma(S)}$. Cost $O(|S|)$, and by Theorem 7.2 the orbits partition $S$. This is the *witness* form of parity.

**(D) Prescribed-space realisation.** Given $S$, output $P_S = [E_b : b \notin S]$. Cost $O((2^n - |S|)\cdot n)$; correctness is Theorem 8.3. Composing (D) with (A) is a round-trip test of complete expressiveness.

**(E) Even-count synthesis.** Given $2k \leq 2^n$, take the first $k$ gauge points, adjoin complements to get $S$ with $|S| = 2k$, and output $P_S$. By Theorem 9.4, $|C(P_S)| = 2k$ exactly. This realises the "if" half of the spectrum theorem.

**(F) Stable-space census.** Enumerate subsets $T$ of the $2^{n-1}$-element gauge and output $T \cup \sigma(T)$; by Lemma 10.2 this enumerates $\mathcal{S}_n$ without repetition, in $2^{2^{n-1}}$ steps — optimal, since that is the size of the output.

**(G) Cyclic divisibility check.** For a $d$-ary puzzle, enumerate $(\mathbb{Z}/d)^n$ for each of the $d$ shifts, union, and verify divisibility by $d$; cost $O(d\cdot d^n \cdot L)$.

---

## 13. Discussion

### 13.1 Where the symmetry lives

The single conceptual correction supplied by this work is that the complementation symmetry does not act on puzzles; it acts on the **configuration space**, and on assembly spaces only by transport. Once that is seen, three things follow at once:

* freeness is a property of the cube ($n \geq 1$), independent of the puzzle;
* self-duality is not a fixed-point condition but a *collapse* of two transported spaces onto one, which strengthens rather than weakens the parity conclusion;
* the exceptional case is dimensional ($n = 0$), and the conjecture's hypothesis excluded it by accident.

### 13.2 Constraint versus expressiveness

The results split cleanly into a constraint half (Theorems 4.3, 5.3, 5.4, 7.2, 7.5, 11.6) and an expressiveness half (Theorems 8.3, 9.1, 9.4, 9.6, 10.3). Theorem 9.5 is the unique point where the two meet, and they meet exactly: the achievable combined counts are precisely the even numbers $\le 2^n$, no more and no fewer. Neither half is definitionally implied by the other — the forward direction uses free-involution parity, the backward direction uses gauge-based synthesis and exclusion pieces.

### 13.3 Layers of shadow

The results form a tower of increasingly coarse invariants of one decomposition:

$$\text{orbit decomposition} \;\Rightarrow\; \text{exact count } 2|\Gamma| \;\Rightarrow\; \text{parity} \;\Rightarrow\; \text{equinumerosity} \;\Rightarrow\; \text{solvability invariance}.$$

Solvability invariance — the classical curiosity — is the bottom of the tower, obtained by remembering only whether the space is empty.

### 13.4 Limitations

* All spectrum and census results concern puzzles of unbounded description size; the realising puzzles use $2^n - |S|$ clause pieces. For bounded-size puzzles, counting assemblies is $\#\mathrm{P}$-hard, and no analogous spectrum theorem is claimed.
* Self-duality is used throughout at the level of assembly *spaces*. A puzzle may be self-dual in this sense while its complement differs syntactically (e.g. by reordering notches).
* The gauge depends on a chosen distinguished variable. Any variable gives a valid gauge, and the resulting gauges are canonically bijective, but no canonical *choice* is made.
* The cyclic model of Section 11 is developed additively over $\mathbb{Z}/d$; for $d = 2$ it reproduces the Boolean statement through the identification $\{\texttt{T},\texttt{F}\}\cong\mathbb{Z}/2$, giving a parallel rather than a literal generalisation.
* The divisibility in Theorem 11.6 is by the order of the shift group only; no finer arithmetic constraint (in the number of pieces or variables) is claimed, and none is known.

---

## 14. Future directions

**Minimal piece count of a prescribed assembly space.** The realisation $P_S$ uses $2^n - |S|$ pieces, which is maximally redundant. We conjecture that the minimum number of clause pieces in a framed puzzle with assembly space exactly $S$ equals the minimum number of clauses in a CNF representation of the indicator of $S$, and that for complement-stable $S$ this minimum is attained by a complement-stable multiset of pieces. The point is that complementation acts on the *space of realisations*, so a minimal realisation of a stable space should be symmetrisable at no cost.

**Symmetric complexity.** More generally, one may ask for the cost of imposing symmetry: is there a stable $S$ whose smallest symmetric realisation is strictly larger than its smallest realisation? A negative answer would say that symmetry is free in this constraint language.

**Bounded-size spectra.** Fix a piece budget $m$. What is the set of achievable combined counts for puzzles with at most $m$ pieces? Parity persists, but expressiveness does not, so a genuinely new — and presumably arithmetic-geometric — spectrum should appear.

**Non-abelian mill symmetries.** Section 11 uses a cyclic group acting by translation. Which finite groups $G$ act freely on a configuration space of the form $X^n$ by "re-milling" operations, and does the divisibility conclusion $|G| \mid |C|$ persist? Freeness, not commutativity, is what the argument needs.

**Refined invariants beyond parity.** Theorem 9.5 shows parity is the only *cardinality* constraint. Is there additional structure on the combined space itself — as a graph under Hamming adjacency, say — that complementation constrains and cardinality does not see?

**Weighted and probabilistic versions.** Assign weights to assemblies and ask when complementation forces a weighted count to vanish or to be divisible; this connects the present orbit argument to signed-enumeration and sign-reversing-involution techniques in enumerative combinatorics.

---

## 15. Conclusion

Global tab–blank complementation is an order-two transport of complete assembly spaces whose freeness is a property of the Boolean cube rather than of any puzzle. From that one fact descend: equinumerosity of the two assembly spaces; evenness of their untagged union for $n \geq 1$ without any non-self-duality hypothesis; evenness of the assembly count of any self-dual puzzle; an explicit orbit decomposition with a computable polarity gauge; and the identification of the unique fixed configuration in the theory as the empty assembly on zero variables — precisely the case where parity fails.

Against this, framed puzzles are completely expressive: one exclusion piece forbids exactly one assembly, so every subset of the Boolean cube is an assembly space. The two halves meet exactly. For $n \geq 1$, the achievable combined assembly counts are precisely the even numbers at most $2^n$; single counts fill the whole interval; self-dual spaces occur in every even size and number exactly $2^{2^{n-1}}$, the square root of all $2^{2^n}$ assembly spaces. Replacing tab and blank by $d$ interlock depths replaces parity by divisibility by $d$.

Complementation therefore contributes to a framed puzzle exactly one bit of global information — the parity of its combined assembly count — and, provably, not one bit more.
