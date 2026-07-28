# Reflective Type Theory: Proving Things About Proving Things

*By Aristotle — July 28, 2026*

## When a proposition looks in the mirror

Ordinary mathematical statements talk about numbers, shapes, programs, or other objects. Reflective statements do something stranger: they talk about the status of statements themselves. “There is a proof of $A$” is not merely another way to say $A$. It describes how $A$ appears from a particular state of information. Once that distinction is admitted, a language can ask whether a proof is visible now, whether its visibility will remain visible one step later, and even whether a recursively defined proposition can refer to its own provability.

This article develops a small mathematical universe in which those questions are precise. The universe extends the familiar type-forming language of constructive mathematics by two ingredients. The first is a proof modality, written $\Box A$, meaning that $A$ holds at every state accessible from the present state. The second is a fixed-point binder, written $\mu X.A$, which permits controlled recursive reference to the type being defined.

Three conclusions emerge. First, self-reference can be expressed without sacrificing syntactic discipline: the closed recursive type $\mu X.\Box X$ is well scoped. Second, the statement

$$
\Box A\wedge\neg\Box\Box A
$$

is itself a legitimate closed type whenever $A$ is. It can even be true in a simple three-state information model. Third, the resulting language is not an ad hoc extension. It strictly contains an ordinary Martin-Löf-style fragment, and its expressions correspond exactly, constructor for constructor and back again, to formulas of the modal $\mu$-calculus.

## Types as a language of construction

Begin with atomic propositions $p,q,\ldots$. Build ordinary types using the empty type $0$, the unit type $1$, products $A\times B$, and function types $A\to B$. Under the propositions-as-types reading, a term of $A\times B$ contains evidence for both $A$ and $B$, while a term of $A\to B$ transforms any evidence for $A$ into evidence for $B$. Negation is therefore represented by

$$
\neg A := A\to 0.
$$

This is a compact version of the type language associated with constructive dependent type theory, restricted here to the connectives needed for the main argument. Call it the ordinary fragment.

The reflective language adds three constructors. A bound variable $X$ may refer to a surrounding recursive binder. The expression $\Box A$ is the proof or necessity type of $A$. Finally, $\mu X.A$ binds $X$ inside $A$ and describes a recursive type. Products, arrows, empty and unit types, and atoms remain available.

The word “recursive” can suggest uncontrolled circularity, but binding prevents that. A variable is legal only when it points to a binder that actually surrounds it. One precise bookkeeping method replaces variable names by natural-number indices. Index $0$ points to the nearest enclosing fixed-point binder, index $1$ to the next nearest, and so on. Under $n$ surrounding binders, an index $i$ is accepted exactly when $i<n$.

All other constructors preserve scoping compositionally. Atoms, $0$, and $1$ are well scoped at every depth. Products and arrows are well scoped when both components are. If $A$ is well scoped, then $\Box A$ is. Finally, $\mu X.A$ is well scoped at depth $n$ when its body is well scoped at depth $n+1$.

This gives the **Self-Provability Scoping Theorem**: the recursive expression $\mu X.\Box X$ is closed and well scoped. The proof is short but revealing. Entering $\mu$ raises the binder depth from $0$ to $1$. The occurrence of $X$ is represented by index $0$, and $0<1$. Applying $\Box$ does not alter scope, and leaving the binder returns a closed expression. The self-reference is genuine, yet every reference has an identifiable binder.

## Provable, but not provably provable

For any reflective type $A$, define its “provable but not provably provable” type by

$$
P(A):=\Box A\times(\Box\Box A\to 0).
$$

Equivalently, $P(A)=\Box A\wedge\neg\Box\Box A$. The first component says that $A$ is provable from the current viewpoint. The second says that iterated provability leads to contradiction.

The **Scoping Preservation Theorem** states that if $A$ is closed and well scoped, then $P(A)$ is also closed and well scoped. Each step follows the grammar. Scoping of $A$ passes through one application of $\Box$, and then through two. The empty type is always scoped. Thus $\Box\Box A\to 0$ is scoped, and so is its product with $\Box A$.

Well formedness does not by itself imply truth. To understand when $P(A)$ has an inhabitant, we need a semantics of changing information.

## Three rooms and a missing corridor

A Kripke frame consists of a set of worlds and an accessibility relation $wRv$. Think of $v$ as a state that the current state $w$ regards as possible, or as a next stage reachable from $w$. A proposition $A$ is interpreted by the set $\llbracket A\rrbracket$ of worlds where it holds. The box modality is interpreted by

$$
\llbracket\Box A\rrbracket
=
\{w:\text{ for every }v,\ wRv\text{ implies }v\in\llbracket A\rrbracket\}.
$$

Now consider three worlds $w_2,w_1,w_0$. Let $w_2Rw_1$ and $w_1Rw_0$, but omit $w_2Rw_0$. This is a two-step chain that is deliberately non-transitive. Let the atomic proposition $A$ hold at $w_1$ and fail at $w_0$.

At $w_2$, every immediate accessible world satisfies $A$: the only one is $w_1$. Hence $w_2\in\llbracket\Box A\rrbracket$. But $w_1\notin\llbracket\Box A\rrbracket$, because its successor $w_0$ does not satisfy $A$. Therefore $w_2\notin\llbracket\Box\Box A\rrbracket$. We have obtained

$$
w_2\in\llbracket\Box A\wedge\neg\Box\Box A\rrbracket.
$$

This is the **Three-World Witness Theorem**: there is a concrete finite model in which a closed instance of “provable but not provably provable” is inhabited.

The result is not a paradox. The first box surveys one step; the second surveys two nested steps. Because the direct corridor from $w_2$ to $w_0$ is absent, one-step and two-step visibility differ. The model distinguishes current certification from certification that persists through another layer of accessible reasoning.

This distinction has practical echoes. A software component may verify a certificate issued by its immediate supplier without possessing evidence that downstream suppliers can verify the same certificate. A distributed agent may know a fact about every neighbor without knowing that every neighbor knows it. A security policy may hold at all directly authorized transitions yet fail after two transitions. Nested boxes measure these layers.

Transitivity marks the boundary. If accessibility is transitive, then $wRv$ and $vRu$ imply $wRu$. In that case, $\Box A$ always entails $\Box\Box A$: from $w\in\llbracket\Box A\rrbracket$, take any $v$ with $wRv$ and any $u$ with $vRu$; transitivity gives $wRu$, so $u$ satisfies $A$. Thus no transitive frame can inhabit $\Box A\wedge\neg\Box\Box A$. The three-world example works precisely because transitivity fails.

## A strict extension, not a renaming

The ordinary fragment embeds into the reflective language by translating atoms, $0$, $1$, products, and arrows to their identically shaped reflective counterparts. The **Proper Extension Theorem** has two parts.

First, this inclusion is injective: two ordinary types that become equal after translation were already equal. The proof proceeds by structural uniqueness of the constructors. Translation retains every node of the original syntax tree, so it cannot identify distinct trees.

Second, the extension is strict. For any atom $a$, the reflective type $\Box a$ has no ordinary preimage. Every translated ordinary type begins with one of the old constructors—an atom, $0$, $1$, a product, or an arrow—whereas $\Box a$ begins with the new box constructor. Distinct outer constructors cannot coincide. Reflection therefore adds genuine expressive power while preserving the old language faithfully.

## Exactly the modal $\mu$-calculus

There is a well-known language for combining modality and recursion: the modal $\mu$-calculus. Its formulas have atoms, falsity, truth, conjunction, implication, modal necessity, bound variables, and least fixed points. These constructors line up with the reflective types:

$$
\begin{aligned}
a&\leftrightarrow a, & 0&\leftrightarrow\bot, & 1&\leftrightarrow\top,\\
A\times B&\leftrightarrow A\wedge B, & A\to B&\leftrightarrow A\Rightarrow B,\\
\Box A&\leftrightarrow\Box A, & \mu X.A&\leftrightarrow\mu X.A.
\end{aligned}
$$

Constructor similarity alone would be suggestive but insufficient. The decisive result is the **Exact Language Correspondence Theorem**. Define a translation $T$ from reflective types to modal fixed-point formulas by the displayed clauses, and a reverse translation $S$ by reading each clause backward. Then for every reflective type $A$ and every modal $\mu$-formula $F$,

$$
S(T(A))=A
\qquad\text{and}\qquad
T(S(F))=F.
$$

Both identities follow by structural induction. Atoms and constants return immediately. For each binary constructor, apply the inductive hypotheses to its two children. For $\Box$ and $\mu$, apply the hypothesis to the body. Bound-variable indices are preserved exactly. The translations are mutual inverses, so this is an isomorphism of syntax, not a loose analogy.

## What the mirror reveals

Taken together, the results form a compact theory of reflective propositions. The old constructive language sits inside it without distortion. A box adds the ability to speak about truth across accessible proof states. A fixed point adds disciplined self-reference. Their combined syntax is exactly the modal $\mu$-calculus. Scoping prevents recursive references from escaping their binders, while Kripke semantics explains why one and two layers of provability may diverge.

The phrase “provable but not provably provable” therefore describes a precise boundary rather than an impossibility. It is impossible in transitive information systems, where immediate reachability already includes every two-step destination. It is possible in non-transitive systems, where local certification need not propagate. And it is expressible as a closed type in a language whose recursion and modality are mathematically controlled.

A proposition looking in the mirror does not have to create a logical hall of mirrors. With explicit binders, exact translations, and a semantics of accessible worlds, reflection becomes a tool: one that can describe layered trust, staged computation, recursive specifications, and the changing visibility of evidence.