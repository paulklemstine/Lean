# Stable Extensions in Abstract Argumentation: The Semantic Hierarchy, the Symmetric Collapse, and an Euler Correspondence

## Abstract

We develop, from first principles, the theory of *stable extensions* in Dung's
abstract argumentation frameworks and locate them precisely within the classical
lattice of extension-based semantics. We prove that every stable extension is
simultaneously preferred, complete, admissible, and conflict-free, forming the
implication chain
$$\text{stable} \implies \text{preferred} \implies \text{complete} \implies \text{admissible} \implies \text{conflict-free},$$
and that every stable extension is a *facet* — a maximal conflict-free set — of
the *coexistence complex* $K(\mathrm{AF})$. We show that the grounded (skeptical)
extension is contained in every stable extension. For **symmetric, irreflexive**
frameworks we establish an exact collapse of the top of the hierarchy: a set is
stable if and only if it is preferred if and only if it is a facet of
$K(\mathrm{AF})$. Finally, specialising to the complete conflict graph on $n$
arguments, we prove that its stable extensions are exactly the $n$ singletons and
that the Euler characteristic of $K(\mathrm{AF})$ equals the number of stable
extensions, giving a clean bridge between a combinatorial-logical count and a
topological invariant.

## 1. Introduction

An *abstract argumentation framework* in the sense of Dung is a pair
$(\mathrm{Ar}, R)$ consisting of a set $\mathrm{Ar}$ of arguments and a binary
*attack* relation $R$ on $\mathrm{Ar}$; we read $R\,a\,b$ as "$a$ attacks $b$".
Remarkably, essentially the whole theory of rational acceptance can be phrased in
terms of these two ingredients alone, by singling out the sets of arguments that
may reasonably be accepted together. Such sets are called *extensions*, and
different standards of reasonableness give rise to different *semantics*.

This paper concentrates on the strongest of the classical extension-based
semantics, the **stable extension**, and develops three interlocking themes:

1. **Placement in the hierarchy.** We give self-contained proofs that stable
   extensions occupy the top of the semantic hierarchy, dominating the preferred,
   complete, admissible, and conflict-free semantics, and coinciding with the
   facets of a naturally associated simplicial complex.
2. **The symmetric collapse.** For symmetric irreflexive frameworks — the model
   of two-sided incompatibility — the stable, preferred, and facet notions
   coincide exactly.
3. **An Euler correspondence.** For the complete conflict graph the number of
   stable extensions equals the Euler characteristic of the coexistence complex,
   linking a logical count to a topological invariant.

Throughout we work with an arbitrary type $A$ of arguments and an arbitrary
relation $R : A \to A \to \mathrm{Prop}$, specialising to finite frameworks only
where cardinalities and Euler characteristics are computed.

## 2. Definitions

Fix a framework $(A, R)$. We work with sets $S \subseteq A$ of arguments.

**Definition 2.1 (Conflict-free).** $S$ is *conflict-free* if no member attacks
another:
$$\mathrm{ConflictFree}(S) \iff \forall a \in S,\ \forall b \in S,\ \neg\, R\,a\,b.$$

**Definition 2.2 (Defense).** $S$ *defends* an argument $a$ if every attacker of
$a$ is counter-attacked from within $S$:
$$\mathrm{Defends}(S, a) \iff \forall b,\ R\,b\,a \implies \exists c \in S,\ R\,c\,b.$$

**Definition 2.3 (Admissible).** $S$ is *admissible* if it is conflict-free and
defends each of its members:
$$\mathrm{Admissible}(S) \iff \mathrm{ConflictFree}(S) \wedge \forall a \in S,\ \mathrm{Defends}(S, a).$$

**Definition 2.4 (Characteristic operator).** The *characteristic (defense)
operator* $F$ maps a set to the set of arguments it defends:
$$F(S) = \{\, a \mid \mathrm{Defends}(S, a) \,\}.$$

**Definition 2.5 (Complete).** $S$ is a *complete extension* if it is admissible
and closed under defense:
$$\mathrm{Complete}(S) \iff \mathrm{Admissible}(S) \wedge F(S) \subseteq S.$$

**Definition 2.6 (Preferred).** $S$ is a *preferred extension* if it is a maximal
admissible set:
$$\mathrm{Preferred}(S) \iff \mathrm{Admissible}(S) \wedge \big(\forall T,\ \mathrm{Admissible}(T) \wedge S \subseteq T \implies T = S\big).$$

**Definition 2.7 (Maximal conflict-free / facet).** $S$ is *maximal
conflict-free* if it is conflict-free and no strictly larger set is:
$$\mathrm{MaximalConflictFree}(S) \iff \mathrm{ConflictFree}(S) \wedge \big(\forall T,\ \mathrm{ConflictFree}(T) \wedge S \subseteq T \implies T = S\big).$$

**Definition 2.8 (Stable).** $S$ is a *stable extension* if it is conflict-free
and attacks every argument it does not contain:
$$\mathrm{Stable}(S) \iff \mathrm{ConflictFree}(S) \wedge \big(\forall a \notin S,\ \exists b \in S,\ R\,b\,a\big).$$

**Definition 2.9 (Coexistence complex $K(\mathrm{AF})$).** The *coexistence
complex* of the framework has as its faces exactly the finite conflict-free sets
of arguments. Because conflict-freeness is inherited by subsets, this is a genuine
abstract simplicial complex: vertices are compatible single arguments, edges are
compatible pairs, and $k$-faces are compatible $(k+1)$-element sets. The facets
(maximal faces) are precisely the maximal conflict-free sets of Definition 2.7.

We record two elementary monotonicity facts used repeatedly.

**Lemma 2.10 (Monotonicity of defense).** If $S \subseteq T$ and $S$ defends $a$,
then $T$ defends $a$. Consequently $F$ is monotone: $S \subseteq T$ implies
$F(S) \subseteq F(T)$.

*Proof.* If every attacker $b$ of $a$ has a counter-attacker $c \in S$, that same
$c$ lies in $T \supseteq S$. $\square$

## 3. The Stable Hierarchy

Our first group of results establishes that stability implies every weaker
semantic standard, and moreover that a stable set is a facet of $K(\mathrm{AF})$.

**Lemma 3.1 (Stable sets are self-defending).** If $S$ is stable and $a \in S$,
then $S$ defends $a$.

*Proof.* Let $b$ attack $a$. If $b \in S$, then $S$ contains both $b$ and $a$
with $b$ attacking $a$, contradicting conflict-freeness; so $b \notin S$. By
stability there is $c \in S$ with $c$ attacking $b$, which is exactly a defense of
$a$ against $b$. $\square$

**Theorem 3.2 (Stable $\implies$ admissible).** Every stable extension is
admissible.

*Proof.* Immediate from conflict-freeness (part of stability) and Lemma 3.1.
$\square$

**Theorem 3.3 (Stable $\implies$ complete).** Every stable extension is complete.

*Proof.* By Theorem 3.2 it is admissible, so it remains to show $F(S) \subseteq
S$. Suppose $a \in F(S)$ but $a \notin S$. By stability there is $b \in S$
attacking $a$. Since $S$ defends $a$ (as $a \in F(S)$), there is $c \in S$
attacking $b$. Now $b, c \in S$ with $c$ attacking $b$ contradicts
conflict-freeness. Hence $a \in S$. $\square$

**Theorem 3.4 (Stable $\implies$ preferred).** Every stable extension is
preferred.

*Proof.* By Theorem 3.2 the set $S$ is admissible. Let $T$ be admissible with $S
\subseteq T$; we show $T \subseteq S$. Take $a \in T$. If $a \notin S$, stability
provides $b \in S \subseteq T$ attacking $a$, so $T$ contains both $b$ and $a$
with $b$ attacking $a$, contradicting the conflict-freeness of $T$. Hence $a \in
S$, so $T = S$. $\square$

**Theorem 3.5 (Stable sets are facets).** Every stable extension is maximal
conflict-free, i.e. a facet of $K(\mathrm{AF})$.

*Proof.* $S$ is conflict-free by definition. Let $T$ be conflict-free with $S
\subseteq T$ and take $a \in T$. If $a \notin S$, stability provides $b \in S
\subseteq T$ attacking $a$, contradicting conflict-freeness of $T$. Hence $T = S$.
$\square$

Together, Theorems 3.2–3.5 realise the implication chain announced in the
abstract:
$$\text{stable} \implies \text{preferred} \implies \text{complete} \implies \text{admissible} \implies \text{conflict-free},$$
with the additional fact that stable extensions are exactly facets of the
coexistence complex.

## 4. The Grounded Extension Lies Below Every Stable Extension

The *grounded extension* is the least complete extension — the skeptical position
one obtains by iterating the defense operator from the empty set. Because $F$ is
monotone on the complete lattice of subsets of $A$ (Lemma 2.10), the
Knaster–Tarski theorem guarantees a least fixed point.

**Definition 4.1 (Grounded extension).** The *grounded extension*
$\mathrm{GE}$ is the least fixed point of the monotone operator $F$,
$\mathrm{GE} = \mathrm{lfp}(F)$.

**Lemma 4.2 (Least prefixed point).** If $F(S) \subseteq S$ then
$\mathrm{GE} \subseteq S$.

*Proof.* This is the defining property of the least fixed point of a monotone map:
the least fixed point is below every prefixed point. $\square$

**Theorem 4.3 (Grounded $\subseteq$ every stable).** The grounded extension is
contained in every stable extension.

*Proof.* Let $S$ be stable. By Theorem 3.3 it is complete, so $F(S) \subseteq S$;
that is, $S$ is a prefixed point of $F$. By Lemma 4.2, $\mathrm{GE} \subseteq S$.
$\square$

Thus the skeptical core common to all reasoning is contained in every "no
abstention" verdict — the cautious and the committed always agree on the grounded
part.

## 5. The Symmetric Collapse

We now specialise to **symmetric** frameworks, where $R\,a\,b$ implies $R\,b\,a$,
and **irreflexive** ones, where $\neg R\,a\,a$ for all $a$. This models pure
mutual incompatibility with no self-defeat, and it collapses the top of the
hierarchy.

**Lemma 5.1 (Free self-defense).** In a symmetric framework, if $a \in S$ then
$S$ defends $a$.

*Proof.* If $b$ attacks $a$, then by symmetry $a$ attacks $b$, and $a \in S$
witnesses the required counter-attacker. $\square$

**Corollary 5.2.** In a symmetric framework every conflict-free set is
admissible.

*Proof.* Conflict-freeness is assumed, and Lemma 5.1 supplies defense of every
member. $\square$

**Proposition 5.3 (Preferred $=$ facet, symmetric case).** In a symmetric
framework, $S$ is preferred if and only if it is maximal conflict-free.

*Proof.* If $S$ is preferred it is admissible, hence conflict-free; and maximality
among admissible sets, together with Corollary 5.2 (which makes every
conflict-free extension a competitor), yields maximality among conflict-free sets.
Conversely, a maximal conflict-free set is admissible by Corollary 5.2, and its
maximality among conflict-free sets a fortiori gives maximality among the
(admissible, hence conflict-free) competitors. $\square$

**Proposition 5.4 (Facets are stable, symmetric irreflexive case).** In a
symmetric irreflexive framework, every maximal conflict-free set is stable.

*Proof.* Let $S$ be maximal conflict-free and suppose, for contradiction, that
some $a \notin S$ is attacked by no member of $S$. We claim $S \cup \{a\}$ is
conflict-free. Indeed, consider a potential conflict between $x, y \in S \cup
\{a\}$. If $x = y = a$, irreflexivity forbids $R\,a\,a$. If $x = a$ and $y \in S$,
a conflict $R\,a\,y$ would give (by symmetry) $R\,y\,a$ with $y \in S$, contrary
to our assumption; the case $x \in S$, $y = a$ is the same by symmetry; and if
$x, y \in S$ there is no conflict because $S$ is conflict-free. So $S \cup \{a\}$
is a strictly larger conflict-free set, contradicting maximality of $S$. Hence
every $a \notin S$ is attacked from $S$, i.e. $S$ is stable. $\square$

**Theorem 5.5 (The symmetric collapse).** In a symmetric irreflexive framework,
for every set $S$,
$$\mathrm{Stable}(S) \iff \mathrm{Preferred}(S) \iff \mathrm{MaximalConflictFree}(S).$$

*Proof.* By Theorem 3.5 stability implies facet; by Proposition 5.4 facet implies
stability; and by Proposition 5.3 facet is equivalent to preferred. Chaining the
equivalences gives the result. $\square$

In the symmetric irreflexive world, then, the three notions of "strongest
verdict" (stable), "boldest defensible verdict" (preferred), and "most economical
verdict" (facet) coincide exactly.

## 6. The Complete Conflict Graph and the Euler Bridge

We now make everything concrete on the most contentious framework of all.

**Definition 6.1 (Complete conflict graph).** The *complete conflict graph* on
$n$ arguments is $(\mathrm{Fin}\,n, R)$ where $R\,a\,b \iff a \neq b$: every two
distinct arguments attack each other.

**Lemma 6.2.** The complete conflict graph is symmetric and irreflexive.

*Proof.* $a \neq b$ implies $b \neq a$ (symmetry), and $a \neq a$ is false
(irreflexivity). $\square$

**Lemma 6.3 (Conflict-free $=$ subsingleton).** In the complete conflict graph, a
set $S$ is conflict-free if and only if $S$ has at most one element.

*Proof.* If $S$ is conflict-free and $a, b \in S$, then $\neg R\,a\,b$ means
$\neg(a \neq b)$, i.e. $a = b$; so $S$ is a subsingleton. Conversely, a
subsingleton contains no two distinct elements, hence no attack. $\square$

**Theorem 6.4 (Stable $=$ singleton).** For $n \geq 1$, the stable extensions of
the complete conflict graph are exactly the singletons $\{a\}$.

*Proof.* By Lemma 6.2 and Theorem 5.5, stable coincides with maximal
conflict-free. By Lemma 6.3 the conflict-free sets are the subsingletons; the
maximal such sets are precisely the singletons (the empty set is not maximal since
$n \geq 1$ provides an argument to adjoin, and no set of size $\geq 2$ is
conflict-free). Directly: a singleton $\{a\}$ is conflict-free, and every
$b \neq a$ is attacked by $a$, so $\{a\}$ is stable; conversely a stable set is
conflict-free hence a subsingleton, and it cannot be empty because an empty set
leaves every argument unattacked. $\square$

**Theorem 6.5 (Count of stable extensions).** For $n \geq 1$, the complete
conflict graph has exactly $n$ stable extensions.

*Proof.* By Theorem 6.4 the stable extensions are the singletons, and the map
$a \mapsto \{a\}$ is an injection from the $n$-element index set onto them. Hence
their number equals $n$. $\square$

### 6.1 Euler characteristic of the coexistence complex

For a finite framework we compute the Euler characteristic of $K(\mathrm{AF})$
combinatorially. If $\mathcal{F}$ denotes the finite family of faces
(conflict-free finite sets), then
$$\chi = \sum_{\substack{s \in \mathcal{F} \\ s \neq \varnothing}} (-1)^{\,|s| - 1} = f_0 - f_1 + f_2 - \cdots,$$
where $f_k$ counts the faces with $k+1$ elements (the $k$-dimensional faces). This
is the standard (unreduced) Euler characteristic of a simplicial complex, written
as an alternating sum over nonempty faces by dimension.

**Lemma 6.6 (Faces of the complete conflict graph).** The faces of the complete
conflict graph on $n$ arguments are exactly the finite sets of cardinality at
most one.

*Proof.* Immediate from Lemma 6.3: the conflict-free finite sets are those with
$\le 1$ element. $\square$

**Theorem 6.7 (Euler characteristic).** The Euler characteristic of the
coexistence complex of the complete conflict graph on $n$ arguments is $n$.

*Proof.* By Lemma 6.6 the complex consists of $n$ vertices and no higher faces —
it is $n$ isolated points. Only the singletons contribute to the alternating sum,
each with sign $(-1)^{1-1} = +1$, and there are $n$ of them, so $\chi = n$.
$\square$

**Theorem 6.8 (The stable Euler bridge).** For the complete conflict graph on
$n \geq 1$ arguments,
$$\chi\big(K(\mathrm{AF})\big) = \#\{\text{stable extensions}\} = n.$$

*Proof.* Combine Theorem 6.7 ($\chi = n$) with Theorem 6.5 (number of stable
extensions $= n$). $\square$

For example, at $n = 4$ both sides equal $4$: four isolated vertices and four
singleton stable extensions.

This is a genuine bridge between two a priori unrelated invariants of a debate: a
purely *logical* count (how many all-or-nothing verdicts it admits) and a purely
*topological* one (the Euler characteristic of the shape encoding which claims can
coexist).

## 7. Algorithms

The results above are constructive and yield direct algorithms on finite
frameworks.

**Algorithm A (Stability test).** Given a finite framework and a candidate set
$S$: (i) verify conflict-freeness by checking no ordered pair in $S \times S$ is
an attack; (ii) verify domination by checking that every argument outside $S$ has
an attacker in $S$. Both checks are quadratic in the number of arguments.

**Algorithm B (Enumerate stable extensions).** Iterate over candidate subsets and
apply Algorithm A. For general frameworks this is exponential (the problem is
$\mathrm{NP}$-hard), but for symmetric irreflexive frameworks Theorem 5.5 lets one
enumerate maximal conflict-free sets — equivalently, maximal independent sets of
the conflict graph — instead.

**Algorithm C (Grounded extension).** Compute the least fixed point of the defense
operator $F$ by the ascending iteration $\varnothing \subseteq F(\varnothing)
\subseteq F(F(\varnothing)) \subseteq \cdots$, which stabilises after finitely
many steps on a finite framework, returning $\mathrm{GE}$.

**Algorithm D (Euler characteristic).** Enumerate the conflict-free finite sets
and sum $(-1)^{|s|-1}$ over the nonempty ones. For the complete conflict graph
this collapses to counting singletons.

## 8. Applications

Abstract argumentation frameworks underlie systems that reason with inconsistent
or conflicting information: legal argumentation, multi-agent negotiation and
persuasion, decision support, and inconsistency-tolerant querying of databases and
knowledge bases. In these settings the choice of semantics governs which
conclusions an agent commits to.

- The stable hierarchy (Section 3) certifies that a stable verdict automatically
  satisfies every weaker acceptability standard, so a system that computes stable
  extensions need not separately verify admissibility or completeness.
- The grounded containment (Theorem 4.3) guarantees a shared skeptical core: any
  conclusion forced by the grounded extension is endorsed by every stable
  position, which is useful when a cautious lower bound on accepted arguments is
  required.
- The symmetric collapse (Theorem 5.5) applies to the common case of mutual
  incompatibility (for instance, mutually exclusive options), where computing
  stable extensions reduces to the well-studied problem of maximal independent
  sets.
- The Euler bridge (Theorem 6.8) turns a counting question about verdicts into a
  topological computation, illustrating how invariants of the coexistence complex
  can encode semantic information.

## 9. Discussion and Future Work

The theory presented here is entirely self-contained and elementary, yet it knits
together three perspectives — order-theoretic (fixed points), combinatorial
(hierarchy and counting), and topological (Euler characteristic). Several
directions invite further work.

- **General symmetric frameworks.** Extend the symmetric collapse and the Euler
  bridge from the complete conflict graph to arbitrary symmetric irreflexive
  frameworks, expressing $\chi(K(\mathrm{AF}))$ through the independence complex of
  the conflict graph.
- **The existence gap.** Unlike preferred extensions, stable extensions need not
  exist. It would be valuable to characterise the frameworks admitting at least
  one stable extension — for instance, to establish that every finite framework
  with a symmetric conflict graph does, via maximal independent sets.
- **Full homology.** Replace the Euler characteristic by the reduced homology of
  the coexistence complex, seeking a homological refinement of the semantics
  count.

## 10. Conclusion

We have placed stable extensions at the apex of the extension-based hierarchy,
shown that they contain the grounded skeptical core, established their exact
coincidence with preferred extensions and facets in symmetric irreflexive
frameworks, and exhibited an exact numerical bridge — for the complete conflict
graph — between the number of stable verdicts and the Euler characteristic of the
coexistence complex. The result is a compact but complete arc from the definition
of a debate to a topological invariant that counts its decisive outcomes.
