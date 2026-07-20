# Coherent Composition Loops: Strictification, Reassociation, and Hybrid Bounds

**Aristotle**  
**20 July 2026**

## Abstract

We study a minimal algebraic model in which composition is not associative as equality but is associative up to a specified proposition-valued invertible transformation. A controlled composition consists of a setoid of arrows, a binary operation, a weak unit, compatibility with the equivalence relation, an associator, and left and right unitors. Because transformations are proposition-valued, the model is locally thin: parallel transformations are unique, so the pentagon, triangle, and all higher coherence diagrams commute automatically. This identifies the construction as the locally thin, one-object fragment of bicategory theory, rather than as an unrestricted characterization of bicategories.

We prove soundness of a structural reassociation calculus, construct the strict quotient and prove strict associativity and strict unit laws there, and exhibit an explicit three-arrow unital operation whose two triple composites are unequal but coherently equivalent. We also prove that bounded right-continuation traces separate bounded atomic words. Finally, we connect coherent reassociation to the cryptographic hybrid method: if an observer changes by at most $\delta$ across each coherent step, then a chain of $k+1$ steps changes its endpoint score by at most $(k+1)\delta$. Together, these results separate strict syntax from coherent semantics and quantify the observational cost of moving between parenthesizations.

## 1. Introduction

Associativity permits an unambiguous reading of an iterated product. In a monoid, category, or algebra of functions, the equality

$$
(x\circ y)\circ z=x\circ(y\circ z)
$$

allows parentheses to be omitted. Yet equality is often stronger than the intended semantics. Different evaluation trees can retain different operational histories while being interchangeable through a reversible comparison. Examples arise in staged protocols, transformations of computation graphs, compositional semantics, and cryptographic hybrid proofs.

The appropriate weakening is not arbitrary nonassociativity. One asks instead for an invertible transformation

$$
\alpha_{x,y,z}:(x\circ y)\circ z\Longrightarrow x\circ(y\circ z),
$$

together with weak unit laws and coherence among all such transformations. In full bicategory theory, transformations between arrows form categories, and the pentagon and triangle equations are substantive axioms. Here we isolate a tractable boundary case: the transformation relation is proposition-valued. There is at most one transformation between fixed endpoints. This **local thinness** makes every pair of parallel coherence paths equal.

The resulting model retains a genuine distinction between equality and coherent equivalence. It also supports two complementary views. The high-resolution view remembers arrows, parentheses, and transformations. The low-resolution view identifies coherently equivalent arrows; its induced composition is an ordinary associative unital operation. This quotient is a strictification at the level of equivalence classes.

A second theme is observational. Parenthesizations form vertices of the associahedron, and elementary associator moves form its edges. A real-valued observer on evaluated arrows can be compared along an edge path. The triangle inequality then becomes a hybrid argument: local stability accumulates linearly along a chain. This supplies a precise bridge to cryptographic game hopping.

The paper makes five contributions. First, it defines controlled composition and explains its bicategorical scope. Second, it proves structural reassociation soundness and automatic coherence. Third, it constructs and analyzes a minimal three-arrow witness of strict nonassociativity. Fourth, it proves strictification and bounded trace separation. Fifth, it derives a quantitative endpoint bound for coherent hybrid chains.

## 2. Controlled composition

### 2.1. Basic definition

A **setoid** is a set $M$ equipped with an equivalence relation $\sim$. A **controlled composition** on $(M,\sim)$ consists of:

- a binary operation $\circ:M\times M\to M$;
- a distinguished element $e\in M$;
- compatibility of composition with equivalence: if $a\sim a'$ and $b\sim b'$, then $a\circ b\sim a'\circ b'$;
- for every $a,b,c\in M$, an associator relation

$$
(a\circ b)\circ c\sim a\circ(b\circ c);
$$

- for every $a\in M$, left and right unitor relations

$$
e\circ a\sim a,
\qquad
a\circ e\sim a.
$$

A **2-cell** from $a$ to $b$ is a witness of $a\sim b$. Since this assertion is proposition-valued, any two 2-cells with the same source and target coincide. Reflexivity gives identity 2-cells, symmetry gives inverses, and transitivity gives vertical composition. Compatibility of $\circ$ gives horizontal composition.

This definition deliberately distinguishes equality $=$ from equivalence $\sim$. The former records strict identity of arrows. The latter records invertible semantic comparison.

### 2.2. Scope and bicategorical interpretation

A controlled composition is the one-object, locally thin shadow of a bicategory. Its elements behave as 1-cells of the single object, and its equivalence witnesses behave as invertible 2-cells. The associator and unitors provide the expected weak structural laws. Local thinness supplies coherence.

It is important not to overstate this conclusion. Merely specifying a binary operation that is associative “up to some isomorphism” does not produce a bicategory. In a non-thin setting one must provide typed 2-cells, functorial horizontal composition, natural associators and unitors, and explicit pentagon and triangle laws. The present model packages exactly the thin case, in which those diagrams commute because their parallel sides cannot be distinct.

### 2.3. Automatic coherence

**Theorem 2.1 (Uniqueness of parallel 2-cells).** For any $a,b\in M$, any two 2-cells from $a$ to $b$ are equal.

**Proof sketch.** A 2-cell is a proof of the proposition $a\sim b$. Proposition-valued witnesses are subsingletons, so two witnesses of the same proposition coincide. $\square$

**Theorem 2.2 (Associator pentagon).** Let $a,b,c,d\in M$. Any two composite 2-cells from

$$
(((a\circ b)\circ c)\circ d)
$$

to

$$
a\circ(b\circ(c\circ d))
$$

are equal. In particular, the upper and lower routes around the associator pentagon agree.

**Proof sketch.** Both routes are parallel 2-cells with the displayed source and target. Theorem 2.1 identifies them. The same argument applies to triangle diagrams and all higher pasting diagrams whose boundary 2-cells are parallel. $\square$

The proof is short because the structural restriction is strong. It does not make coherence unimportant; it makes coherence a consequence of local thinness.

## 3. A calculus of parenthesized expressions

### 3.1. Expressions and evaluation

A **composition expression** over $M$ is a finite binary tree defined recursively. An atom $[a]$ is an expression for every $a\in M$. If $x$ and $y$ are expressions, then $(x\,y)$ is an expression. Its evaluation is

$$
\operatorname{ev}([a])=a,
$$

$$
\operatorname{ev}((x\,y))=\operatorname{ev}(x)\circ\operatorname{ev}(y).
$$

This syntax retains parentheses explicitly. Different binary trees with the same ordered leaves can evaluate to unequal arrows.

### 3.2. Structural reassociation

Define a relation $x\rightsquigarrow y$, called **structural reassociation**, as the least relation generated by the following rules:

1. **Reflexivity:** $x\rightsquigarrow x$.
2. **Symmetry:** if $x\rightsquigarrow y$, then $y\rightsquigarrow x$.
3. **Transitivity:** if $x\rightsquigarrow y$ and $y\rightsquigarrow z$, then $x\rightsquigarrow z$.
4. **Left context:** if $x\rightsquigarrow y$, then $(x\,z)\rightsquigarrow(y\,z)$.
5. **Right context:** if $y\rightsquigarrow z$, then $(x\,y)\rightsquigarrow(x\,z)$.
6. **Associator move:** $((x\,y)\,z)\rightsquigarrow(x\,(y\,z))$.

Rules 4 and 5 are often called whiskering or contextual closure. They allow a local tree rotation at any depth.

**Theorem 3.1 (Reassociation soundness).** If $x\rightsquigarrow y$, then

$$
\operatorname{ev}(x)\sim\operatorname{ev}(y).
$$

**Proof sketch.** Induct on the derivation of $x\rightsquigarrow y$. Reflexivity uses reflexivity of $\sim$. Symmetry inverts a 2-cell. Transitivity vertically composes two 2-cells. Left and right contextual rules use compatibility of $\circ$ with $\sim$, pairing the inductive 2-cell with an identity 2-cell on the unchanged argument. The generating rotation uses the associator. These cases exhaust the construction. $\square$

The theorem gives every syntactic path through the associahedron a semantic interpretation. In the locally thin setting, any two paths with common endpoints yield the same 2-cell.

### 3.3. Associahedral geometry

For a fixed ordered word of $n$ atoms, binary parenthesizations are vertices of the $(n-2)$-dimensional associahedron. Elementary rotations are edges. The soundness theorem says that evaluation maps every edge to an invertible 2-cell. The pentagon for four atoms is the two-dimensional face expressing agreement of alternative reassociation paths.

This geometric view is useful computationally. A reassociation algorithm is a path-search procedure on a finite graph. Its path length controls both runtime and, under an observational stability hypothesis, cumulative drift.

## 4. A finite nonassociative witness

### 4.1. The composition table

Let

$$
L=\{e,a,b\}
$$

and define composition by the table

$$
\begin{array}{c|ccc}
\circ & e & a & b\\ \hline
e & e & a & b\\
a & a & b & a\\
b & b & e & b
\end{array}.
$$

The first row and first column show that $e$ is a strict two-sided identity. The remaining equations are

$$
a\circ a=b,\qquad a\circ b=a,
$$

$$
b\circ a=e,\qquad b\circ b=b.
$$

Equip $L$ with the indiscrete equivalence relation: $x\sim y$ for all $x,y\in L$. It is an equivalence relation, composition respects it, and every required associator and unitor exists. Since each relation is proposition-valued, parallel 2-cells are unique.

**Theorem 4.1 (Strict nonassociativity with coherent comparison).** In the preceding controlled composition,

$$
(a\circ a)\circ a=e,
$$

while

$$
a\circ(a\circ a)=a.
$$

Hence $(a\circ a)\circ a\ne a\circ(a\circ a)$, but an invertible 2-cell relates the two composites.

**Proof sketch.** The table gives $a\circ a=b$. Therefore the left-associated result is $b\circ a=e$, whereas the right-associated result is $a\circ b=a$. The symbols $e$ and $a$ are distinct. The indiscrete relation nevertheless gives $e\sim a$, and that witness is the associator for this triple. $\square$

This example proves that coherent associativity need not collapse into strict associativity. Three arrows suffice for the separation exhibited here. The example is intentionally maximally thin: it witnesses unequal 1-cells but not distinct parallel 2-cells.

## 5. Strictification by quotient

Let $M/{\sim}$ denote the set of equivalence classes, and write $[x]$ for the class of $x$. Define

$$
[x]\star[y]=[x\circ y].
$$

**Lemma 5.1 (Well-defined quotient composition).** The operation $\star$ does not depend on the choice of representatives.

**Proof sketch.** If $x\sim x'$ and $y\sim y'$, compatibility gives $x\circ y\sim x'\circ y'$. Thus the two composites determine the same equivalence class. $\square$

**Theorem 5.2 (Strict Quotient Theorem).** For all $[x],[y],[z]\in M/{\sim}$,

$$
([x]\star[y])\star[z]=[x]\star([y]\star[z]).
$$

Moreover, $[e]$ is a strict two-sided identity:

$$
[e]\star[x]=[x],
\qquad
[x]\star[e]=[x].
$$

**Proof sketch.** The left side of associativity is the class of $(x\circ y)\circ z$ and the right side is the class of $x\circ(y\circ z)$. The associator places these representatives in the same class. The left and right unitor relations similarly identify $e\circ x$ and $x\circ e$ with $x$. $\square$

**Corollary 5.3 (Strictification of the three-arrow witness).** In the quotient of the three-arrow example,

$$
[(a\circ a)\circ a]=[a\circ(a\circ a)].
$$

**Proof sketch.** Theorem 4.1 supplies the equivalence between the representatives, so their classes agree. In fact, the indiscrete relation makes this particular quotient a singleton. $\square$

The quotient theorem precisely locates the obstruction to strictness. Before quotienting, the operation can remember implementation-level distinctions. After quotienting, associators and unitors become equality.

## 6. Bounded traces as strict fingerprints

Let $A$ be any alphabet and let $A^*$ be its finite words. For a radius $R\in\mathbb N$ and a word $w\in A^*$, define the **bounded right-continuation trace**

$$
T_R(w)=\{z\in A^*: |z|\le R\text{ and }z=w\,t\text{ for some }t\in A^*\}.
$$

Thus $T_R(w)$ is the portion, within the length bound $R$, of the principal right ideal generated by $w$. It records every admissible continuation of $w$.

**Lemma 6.1 (Self-membership).** If $|w|\le R$, then $w\in T_R(w)$.

**Proof sketch.** Choose the continuation $t$ to be the empty word. Then $w=w\,t$, and the length condition holds by assumption. $\square$

**Theorem 6.2 (Bounded Trace Separation).** Let $w,w'\in A^*$ satisfy $|w|\le R$ and $|w'|\le R$. If

$$
T_R(w)=T_R(w'),
$$

then $w=w'$.

**Proof sketch.** By Lemma 6.1, $w\in T_R(w)$; equality of traces gives $w\in T_R(w')$, so $w=w't$ for some $t$. Hence $w'$ is a prefix of $w$. Symmetrically, $w'$ lies in $T_R(w)$, so $w$ is a prefix of $w'$. Finite words that are mutual prefixes are equal. $\square$

**Corollary 6.3 (Atomic-expression separation).** Under the hypotheses of Theorem 6.2, replacing every letter of $w$ and $w'$ by the corresponding atomic composition expression produces equal lists of atoms.

This result concerns strict words, not quotient classes. It therefore complements strictification. The trace recognizes the exact generator sequence within the bound, while coherent equivalence determines which evaluated expressions may later be identified. In cryptographic language, the trace behaves as a complete bounded fingerprint for atomic syntax.

## 7. Coherent reassociation as a hybrid argument

### 7.1. The real telescope

The numerical engine is a standard consequence of the triangle inequality.

**Lemma 7.1 (Finite Hybrid Telescope).** Let $k\in\mathbb N$ and let

$$
p_0,p_1,\ldots,p_{k+1}\in\mathbb R.
$$

Then

$$
|p_0-p_{k+1}|\le\sum_{i=0}^{k}|p_i-p_{i+1}|.
$$

**Proof sketch.** Write

$$
p_0-p_{k+1}=(p_0-p_1)+(p_1-p_2)+\cdots+(p_k-p_{k+1}).
$$

Repeated application of $|u+v|\le |u|+|v|$ yields the result. Equivalently, proceed by induction on $k$, splitting off the last segment. $\square$

### 7.2. Observer stability

Let $s:M\to\mathbb R$ be an observer or score. Fix $\delta\in\mathbb R$. Say that $s$ is **$\delta$-stable under coherent equivalence** if

$$
x\sim y\quad\Longrightarrow\quad |s(x)-s(y)|\le\delta.
$$

In applications, $s(x)$ may be an acceptance probability, a statistical score, a cost, or another real observable. The hypothesis is meaningful only when such local comparisons are available. If coherent equivalence preserves the observer exactly, one may take $\delta=0$.

### 7.3. Endpoint bound

**Theorem 7.2 (Reassociation Hybrid Bound).** Let

$$
E_0,E_1,\ldots,E_{k+1}
$$

be composition expressions such that $E_i\rightsquigarrow E_{i+1}$ for every $0\le i\le k$. If $s$ is $\delta$-stable under coherent equivalence, then

$$
\left|s(\operatorname{ev}(E_0))-s(\operatorname{ev}(E_{k+1}))\right|
\le(k+1)\delta.
$$

**Proof sketch.** Define

$$
p_i=s(\operatorname{ev}(E_i)).
$$

By Theorem 3.1, each adjacent reassociation gives

$$
\operatorname{ev}(E_i)\sim\operatorname{ev}(E_{i+1}).
$$

Stability therefore yields $|p_i-p_{i+1}|\le\delta$. Apply Lemma 7.1 and bound the sum of $k+1$ terms by $(k+1)\delta$. $\square$

The theorem is the familiar hybrid method expressed in coherence language. An elementary reassociation is one game hop. The endpoint distinguishing gap is no larger than the sum of local gaps.

A small numerical illustration uses scores

$$
0.12,\ 0.15,\ 0.19,\ 0.18,\ 0.22.
$$

The four local drifts are $0.03$, $0.04$, $0.01$, and $0.04$, whose sum is $0.12$. The endpoint drift is $0.10$, so the telescope holds. With the uniform local bound $\delta=0.04$, Theorem 7.2 gives the slightly looser estimate $0.16$.

### 7.4. Algorithmic form

Given an explicit path $E_0,\ldots,E_n$ and computed scores $p_0,\ldots,p_n$, one can audit the bound in one pass. Compute every local drift $d_i=|p_i-p_{i+1}|$, their sum $D=\sum_i d_i$, the maximum $\delta=\max_i d_i$, and the endpoint gap $G=|p_0-p_n|$. Then

$$
G\le D\le n\delta.
$$

The procedure takes $O(n)$ time and $O(1)$ auxiliary space if the local values are streamed. Finding a shortest reassociation path is a separate graph problem on parenthesizations. For a fixed word length, breadth-first search gives an unweighted shortest path in time linear in the explored associahedron graph, though the number of vertices is the corresponding Catalan number.

## 8. Applications

### 8.1. Cryptographic game hopping

A security proof often replaces a real experiment by an ideal one through intermediate games. If each replacement changes an adversary's success probability by at most $\delta_i$, then the total distinguishing advantage is at most $\sum_i\delta_i$. Theorem 7.2 shows that changes of parenthesization can be treated in exactly this way whenever each coherent transformation has a local observational guarantee.

This perspective is especially useful when composition order records protocol structure. Strictification says the endpoint semantics is associative after quotienting; the hybrid bound says how much a non-invariant observer may drift before that quotient is taken.

### 8.2. Computation trees and batching

Parallel reductions and compiler rewrites routinely alter binary evaluation trees. Exact arithmetic may make these changes invisible, while floating-point arithmetic, resource accounting, or side-channel observables may not. A controlled composition separates semantic interchangeability from literal execution identity. A weighted extension could attach costs to tree rotations and optimize a reassociation schedule.

### 8.3. Collision analysis

Bounded traces distinguish strict generator words. Quotienting by coherence may identify their evaluations. Secure composition therefore requires a disciplined relationship between syntactic fingerprints and semantic equivalence. The present results identify the two mechanisms cleanly but do not yet prove a general collision-resistance theorem for non-thin bicategories.

## 9. Limitations and discussion

The locally thin hypothesis is both the source of clarity and the main limitation. It collapses all parallel 2-cells, so the pentagon is automatic. Consequently, the three-arrow model cannot display a nontrivial choice between distinct coherence witnesses. A faithful higher-dimensional model must retain multiple 2-cells and verify coherence relations explicitly.

The indiscrete equivalence relation is also extreme. It is ideal for separating strict inequality from coherent equivalence, but its quotient forgets everything. More selective relations would preserve nontrivial quotient structure and make observer stability more informative.

The hybrid estimate is worst-case and path-dependent. The factor $(k+1)\delta$ ignores cancellation and treats all edges uniformly. The sharper telescope $\sum_i\delta_i$ is available when edge-specific bounds are known. A shortest-path formulation with nonnegative edge costs suggests a quantitative geometry of coherence.

Finally, bounded traces classify words only under the explicit length hypotheses. If $|w|>R$, the trace may be empty and cannot identify $w$. The radius is therefore part of the fingerprinting specification, not an incidental parameter.

## 10. Future work

A first direction is a finite non-thin one-object bicategory with genuinely distinct parallel 2-cells, a nonidentity associator, and a decidable rewriting presentation of the pentagon. Such an example would preserve higher-dimensional information erased by local thinness.

A second direction is **quantitative coherence leakage**. Assign a nonnegative subadditive cost to each 2-cell. One may then ask whether the maximal observational drift between parenthesizations equals the minimum path cost and whether this distance descends through pentagon and triangle relations.

A third direction concerns collision resistance under weak composition. If bounded left and right principal-ideal traces separate words, one expects quotient collision resistance precisely when unit-preserving 2-cells introduce no unintended identifications between distinct generator words.

A fourth direction uses sharp rotation-distance bounds in associahedra. If two parenthesizations of a word of length $n$ can always be joined by a controlled number of rotations, then the same diameter estimate bounds the length of the necessary hybrid chain. For sufficiently large $n$, the proposed target is $2n-6$ moves.

## 11. Conclusion

Controlled composition provides a compact model of operations whose parenthesizations are unequal but reversibly comparable. Local thinness yields automatic coherence; structural reassociation interprets every legal tree rotation; quotienting turns weak associativity and units into strict laws; a three-arrow table witnesses genuine nonassociativity; bounded continuation traces recover strict words; and the hybrid theorem converts local stability into a global endpoint bound.

The framework draws a precise line between strict syntax and coherent semantics. Parentheses remain visible where operational history matters and disappear after passage to equivalence classes. Between those views lies a geometry of reassociation paths, and that geometry carries quantitative information relevant to compositional security.