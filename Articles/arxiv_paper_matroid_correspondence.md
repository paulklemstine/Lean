# A Calculus of Mathematical Correspondence

## How one relation can transport entire theories of forbidden structures

Many mathematical constructions begin with a deceptively simple verb: *relate*. A smaller network is related to a larger one by deletion; a geometric configuration is related to another by projection; a matroid is related to the structures obtained by removing or contracting elements. Yet the relation is often not a function. One object may have many images, and choosing only one destroys precisely the information that matters.

The central idea developed here is that such many-valued constructions can still behave like a disciplined calculus. The decisive ingredient is an **extension law**. Once that law holds, correspondences compose, act contravariantly on downward-closed properties, preserve arbitrary intersections, and—under a well-quasi-ordering hypothesis—turn those properties into finite lists of forbidden obstructions.

This is particularly natural for matroids. A matroid abstracts independence: the same pattern governing linearly independent vectors also describes forests in a graph and many resource-selection systems. Matroid minors, obtained through deletion and contraction, play the role of simplified descendants. A class of matroids is **minor-closed** when every minor of an admitted matroid is also admitted. Such classes are often understood through their excluded minors: the minimal structures that fail membership.

The striking point is that much of this obstruction theory does not depend on coordinates, fields, or polynomial formulas. It follows from order alone.

## The upward-extension rule

Let $A$ and $B$ be preordered sets. Write $a_0\leq a_1$ when $a_1$ lies above $a_0$ in the source order, and similarly in $B$. An **order correspondence** from $A$ to $B$ is a relation $R(a,b)$ satisfying the following extension law:

> If $a_0\leq a_1$ and $R(a_0,b_0)$, then there exists $b_1$ such that $b_0\leq b_1$ and $R(a_1,b_1)$.

In symbols,

$$
a_0\leq a_1\ \text{and}\ R(a_0,b_0)
\quad\Longrightarrow\quad
\exists b_1\geq b_0\text{ with }R(a_1,b_1).
$$

Imagine lifting the source object from $a_0$ to $a_1$. The law says that every target witness attached to $a_0$ can be lifted along with it. The correspondence may branch, but no existing witness becomes stranded.

This modest rule is exactly what is needed to transport hereditary properties. A subset $C\subseteq B$ is a **lower class** if $b_0\leq b_1$ and $b_1\in C$ imply $b_0\in C$. Instead of asking whether *some* target related to $a$ lies in $C$, define the universal pullback by asking whether *every* related target does:

$$
R^*C=\{a\in A: \text{for every }b,\ R(a,b)\Rightarrow b\in C\}.
$$

This universal quantifier is essential. It says that $a$ passes the test only when all its possible outcomes pass.

## Why hereditary properties survive

The first main result is the **Lower-Class Pullback Theorem**:

> For any order correspondence $R$ and any lower class $C\subseteq B$, the universal pullback $R^*C$ is a lower class in $A$.

The proof is short enough to see as a moving picture. Suppose $a_1$ passes the universal test and $a_0\leq a_1$. Choose any $b_0$ related to $a_0$. The extension law produces $b_1\geq b_0$ related to $a_1$. Since $a_1$ passes, $b_1$ belongs to $C$. Since $C$ is lower, $b_0$ belongs to $C$. Every possible $b_0$ passes, so $a_0$ passes.

This argument explains the variance. An existential image generally points the wrong way for hereditary classes: one favorable outcome says nothing about the others. Universal inverse image is the robust construction.

There is also a clean calculus. The identity correspondence relates each object only to itself. If $R$ relates $A$ to $B$ and $S$ relates $B$ to $D$, their composite relates $a$ to $d$ whenever some intermediate $b$ satisfies both relations:

$$
(S\circ R)(a,d)\quad\Longleftrightarrow\quad
\exists b\,[R(a,b)\ \text{and}\ S(b,d)].
$$

The extension laws for $R$ and $S$ lift the intermediate and final witnesses in succession, so the composite is again an order correspondence. Relational composition is associative: the statements “there exist $b$ and $c$ with $R(a,b)$, $S(b,c)$, and $T(c,d)$” are unchanged by parentheses.

The associated pullbacks obey the reverse-order rule

$$
(S\circ R)^*C=R^*(S^*C),
$$

while the identity has $\operatorname{id}^*C=C$. Thus a many-valued relation acts on classes with the same contravariant discipline familiar from ordinary inverse images.

## Combining infinitely many requirements

Suppose a system must satisfy not one target condition but a whole family $\{C_i\}_{i\in I}$. Universal pullback commutes with their intersection:

$$
R^*\left(\bigcap_{i\in I}C_i\right)
=
\bigcap_{i\in I}R^*C_i.
$$

This **Arbitrary-Intersection Theorem** is stronger than a finite compatibility statement. It follows directly by rearranging universal quantifiers: every related target lies in every $C_i$ exactly when, for every $i$, every related target lies in $C_i$.

In applications, this means independently specified safety rules, structural restrictions, or forbidden-pattern conditions can be transported one by one or all at once. The answer is identical. Modularity is therefore not an engineering convenience added afterward; it is built into the logic of correspondence.

## The matroid case and forbidden minors

Now order matroids so that $N\leq_m M$ means that $N$ is a minor of $M$. A **matroid correspondence** is simply an order correspondence between two such minor orders. A target class $C$ is minor-closed precisely when it is lower in this order. The Lower-Class Pullback Theorem immediately yields:

> The universal pullback of a minor-closed target class along any matroid correspondence is a minor-closed source class.

There is a basic correspondence that relates each matroid $M$ to every minor $N\leq_m M$. Its universal pullback fixes every minor-closed class. Indeed, if all minors of $M$ lie in $C$, then $M$ itself lies in $C$ because $M$ is its own minor. Conversely, if $M\in C$, minor-closure puts every minor of $M$ in $C$.

The deeper payoff concerns obstructions. For a class $D$ of matroids, an **excluded minor** is a matroid $E\notin D$ all of whose proper minors belong to $D$. These are the minimal counterexamples. Two distinct excluded minors cannot be comparable by the minor relation: if $E_1$ were a minor of $E_2$, then minimality of $E_2$ would force the proper minor $E_1$ into $D$, contradicting its exclusion. Hence excluded minors form an antichain.

Assume now that the source minor order is **well-quasi-ordered**: every infinite sequence contains indices $i<j$ with $M_i\leq_m M_j$. Equivalently for the present purpose, there are no infinite antichains and no infinite strictly descending pathologies. Since excluded minors form an antichain, only finitely many can occur.

This gives the **Finite Excluded-Minor Pullback Theorem**:

> Let $R$ be a matroid correspondence and let $C$ be a minor-closed target class. If the source matroids are well-quasi-ordered by minors, then the excluded minors of $R^*C$ form a finite set. Moreover, a source matroid $M$ belongs to $R^*C$ exactly when none of those excluded minors is a minor of $M$.

Thus an apparently global requirement—every target related to $M$ must lie in $C$—admits a finite obstruction certificate. There are finitely many minimal forbidden source patterns $E_1,\dots,E_k$, and

$$
M\in R^*C
\quad\Longleftrightarrow\quad
E_i\not\leq_m M\ \text{for every }i=1,\dots,k.
$$

The antichain conclusion itself needs no well-quasi-ordering and no assumption that $C$ is minor-closed: excluded minors of any correspondence pullback are pairwise incomparable. Well-quasi-ordering is used only to turn that antichain into a finite list.

## From abstraction to algorithms

For a finite data set, the theory suggests a direct procedure. Record the source and target orders, record the correspondence relation, and test the extension law. Given a target class $C$, retain exactly those source objects whose entire relation fibre lies in $C$. Then scan the failures and keep only the minimal ones. These are the obstructions.

A small example uses divisibility as the order. Let the source be $\{1,2,3,6\}$, the target $\{1,2,4,8\}$, and relate $a$ to $b$ when $b$ divides $2^a$. Divisibility upward in the source allows enough powers of two upward in the target, so witnesses extend. If $C=\{1,2,4\}$, the universal pullback contains exactly those source values whose complete fibres avoid $8$. Its complement has minimal elements, and those minima generate every later failure inside the finite order.

The same computational pattern appears in reliability analysis. Source objects can be designs ordered by simplification, target objects can be operating scenarios ordered by severity, and the relation can encode scenarios compatible with each design. A downward-closed safety class then pulls back to a simplification-stable class of designs. Under a suitable finiteness principle, a finite obstruction list replaces an unbounded universal test.

## The boundary of the result

Order theory is powerful, but it does not do everything. The theorems above establish the relational and obstruction-theoretic core of matroid correspondences. They do not by themselves show that a correspondence preserves representability over a field, algebraicity, multisymmetric lifts of polymatroids, or supports associated with Lorentzian polynomials. Those questions require additional linear, algebraic-geometric, combinatorial, or analytic data.

That boundary is productive. By isolating the exact work performed by the extension law, the theory separates universal order-theoretic reasoning from specialized structure. Future developments can ask a focused question: does a proposed linear, geometric, or polynomial construction supply the required extending witnesses? If it does, the entire pullback calculus and its obstruction consequences arrive automatically.

A relation, then, need not choose a single future to be mathematically manageable. It only needs to let every witness travel upward. From that one mobility principle comes a compositional language, a robust treatment of hereditary properties, and—where well-quasi-ordering holds—a finite dictionary of everything that can go minimally wrong.
