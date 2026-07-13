# The Order Theory of Abstract Argumentation: The Fundamental Lemma and the Identity of Preferred and Maximal Complete Extensions

## Abstract

We develop the maximal-extension theory of Dung-style abstract
argumentation frameworks with no finiteness and no well-foundedness
hypothesis on the attack relation. Starting from the classical
definitions of conflict-freedom, defense, admissibility, completeness,
stability, and preferredness, we isolate a single structural engine — the
**Fundamental Lemma** — asserting that an admissible set stays admissible
when any argument it defends is added. From this we derive, uniformly and
unconditionally, that every preferred (maximal admissible) extension is
complete; that every stable extension is complete and indeed preferred;
that unions of chains of admissible sets are admissible; and hence, via a
maximality principle, that every admissible set (in particular the empty
set) extends to a preferred extension, so preferred extensions always
exist. These combine into a clean structural characterization: **a set is
preferred if and only if it is a maximal complete extension.** Together
with the companion theory of the grounded (least complete) extension, this
organizes the complete extensions of any framework into a *pointed poset*
whose least element is the grounded extension and whose maximal elements
are exactly the preferred extensions. We give full proof sketches,
algorithmic counterparts, worked numerical examples, and a program of
future directions toward a semilattice structure, a stability dichotomy,
and a topological reflection of the extension poset.

**Keywords.** abstract argumentation, attack relation, admissible set,
complete extension, preferred extension, stable extension, grounded
extension, Fundamental Lemma, Zorn's lemma, pointed poset.

---

## 1. Introduction

Dung's theory of abstract argumentation reduces defeasible reasoning to
its combinatorial core. One fixes a set of *arguments* and a binary
*attack relation* over them, discarding the internal content of each
argument, and studies which sets of arguments can be rationally accepted
together. Four *semantics* dominate the classical picture — complete,
grounded, preferred, and stable extensions — each formalizing a different
standard of collective acceptability.

Two extremes anchor the theory. The **grounded extension** is the
*least* complete extension: the cautious, skeptical verdict, accepting
only what one is forced to accept. The **preferred extensions** are the
*maximal* admissible sets: the boldest self-defensible stances. A
companion development treats the grounded extreme (least complete
extension, uniqueness under well-foundedness). The present paper treats
the maximal extreme, and does so with **no finiteness and no
well-foundedness hypothesis** on the framework.

Our organizing thesis is that the entire completeness-and-existence theory
of preferred extensions flows from a single lemma. The **Fundamental
Lemma** states that admissibility grows freely along defended arguments.
Once this is available: maximality forces closure under defense (so
preferred implies complete); chain-unions of admissible sets are
admissible (so a maximality principle applies); and the two facts fuse
into the identity *preferred = maximal complete*. The result is an
order-theoretic portrait of the semantics: a pointed poset of complete
extensions.

---

## 2. Definitions

Throughout, $A$ is a set of *arguments* and $R \subseteq A \times A$ is
the *attack relation*; we write $R\,a\,b$ for "$a$ attacks $b$." A pair
$(A, R)$ is an **argumentation framework**. No cardinality or acyclicity
assumption is made. Subsets $S \subseteq A$ are the objects of interest.

**Definition 2.1 (Conflict-free).** $S$ is *conflict-free* if
$$\forall a \in S,\ \forall b \in S,\ \neg\, R\,a\,b.$$
No member of $S$ attacks another member.

**Definition 2.2 (Defense).** $S$ *defends* $a$ if every attacker of $a$
is counterattacked from within $S$:
$$\forall b,\ R\,b\,a \ \Rightarrow\ \exists c \in S,\ R\,c\,b.$$

**Definition 2.3 (Characteristic operator).** The *characteristic* (or
*defense*) operator sends $S$ to the set of arguments it defends:
$$F(S) = \{\, a \in A \mid S \text{ defends } a \,\}.$$
$F$ is the engine of the fixed-point theory; note $a \in F(S)$ iff $S$
defends $a$.

**Definition 2.4 (Admissible).** $S$ is *admissible* if it is
conflict-free and defends each of its members:
$$\text{ConflictFree}(S)\ \wedge\ \big(\forall a \in S,\ S \text{ defends } a\big).$$
Equivalently, $S$ is conflict-free and $S \subseteq F(S)$.

**Definition 2.5 (Complete).** $S$ is a *complete extension* if it is
admissible and accepts everything it defends:
$$\text{Admissible}(S)\ \wedge\ F(S) \subseteq S.$$
Complete extensions are precisely the conflict-free fixed points of $F$
that contain their own defended arguments; equivalently, admissible sets
with $S = F(S)$ restricted to their conflict-free closure.

**Definition 2.6 (Stable).** $S$ is a *stable extension* if it is
conflict-free and attacks every outside argument:
$$\text{ConflictFree}(S)\ \wedge\ \big(\forall a \notin S,\ \exists b \in S,\ R\,b\,a\big).$$

**Definition 2.7 (Preferred).** $S$ is a *preferred extension* if it is a
*maximal* admissible set:
$$\text{Admissible}(S)\ \wedge\ \big(\forall T,\ \text{Admissible}(T) \wedge S \subseteq T \Rightarrow T = S\big).$$

**Definition 2.8 (Grounded).** The *grounded extension* is the least
complete extension under inclusion (developed in the companion theory; it
is the least fixed point of $F$ obtained by iterating $F$ from $\emptyset$).

The following inclusions of *classes* of sets will be established:
$$\text{stable} \subseteq \text{preferred} \subseteq \text{complete} \subseteq \text{admissible}.$$

---

## 3. Monotonicity

**Lemma 3.1 (Monotonicity of defense).** If $S \subseteq T$ and $S$
defends $a$, then $T$ defends $a$.

*Proof.* Any attacker $b$ of $a$ is counterattacked by some $c \in S \subseteq T$. $\square$

**Corollary 3.2 (Monotonicity of $F$).** $S \subseteq T$ implies
$F(S) \subseteq F(T)$.

Monotonicity of $F$ is what allows both the least-fixed-point (grounded)
construction from below and the chain arguments below; it is used
implicitly throughout.

---

## 4. The Fundamental Lemma

**Theorem 4.1 (Fundamental Lemma).** *If $S$ is admissible and $S$
defends $a$, then $S \cup \{a\}$ is admissible.*

*Proof sketch.* Write $S' = S \cup \{a\}$. Two things must be checked.

*Conflict-freedom of $S'$.* Since $S$ is conflict-free, the only possible
new conflicts involve $a$. Two cases.

1. Suppose $a$ attacks some $b \in S$, i.e. $R\,a\,b$. Then $a$ is an
   attacker of the member $b$ of $S$; as $S$ defends $b$, some $c \in S$
   satisfies $R\,c\,a$. But $S$ defends $a$ (hypothesis), so some
   $d \in S$ satisfies $R\,d\,c$. Now $c, d \in S$ with $R\,d\,c$
   contradicts conflict-freedom of $S$.
2. Suppose some $b \in S$ attacks $a$, i.e. $R\,b\,a$. As $S$ defends
   $a$, some $c \in S$ satisfies $R\,c\,b$. Then $b, c \in S$ with
   $R\,c\,b$ contradicts conflict-freedom of $S$.

   The remaining possibility, $R\,a\,a$, is subsumed by case 1 with
   $b = a$ once $a$ is treated as a member of $S'$: an attack on $a$ from
   $S'$ would again be counterattacked into a conflict. Hence $S'$ is
   conflict-free.

*Defense of every member of $S'$.* Members of $S$ are still defended by
$S \subseteq S'$ (Lemma 3.1), and $a$ is defended by $S \subseteq S'$ by
hypothesis. Thus $S'$ defends all its members and is admissible. $\square$

**Remark 4.2 (Conflict avoidance).** The load-bearing content is the slogan
*an admissible set can neither attack nor be attacked by any argument it
defends.* Defense and hostility are mutually exclusive within an
admissible set. This is precisely what keeps $S \cup \{a\}$
conflict-free and is the sole reason admissibility is a *growing*, rather
than fragile, property.

---

## 5. Preferred extensions are complete

**Theorem 5.1.** *Every preferred extension is complete.*

*Proof.* Let $S$ be preferred: admissible and maximal admissible. To show
completeness it remains to prove $F(S) \subseteq S$. Suppose $S$ defends
$a$. By the Fundamental Lemma, $S \cup \{a\}$ is admissible and contains
$S$. Maximality gives $S \cup \{a\} = S$, so $a \in S$. Hence
$F(S) \subseteq S$ and $S$ is complete. $\square$

The proof consumes maximality exactly once and is otherwise a direct
application of Theorem 4.1 — a vivid illustration of the lemma's role as
the theory's engine.

---

## 6. Stable extensions

**Theorem 6.1.** *Every stable extension is complete (hence admissible).*

*Proof sketch.* Let $S$ be stable. Conflict-freedom is part of the
definition. For defense: if $b$ attacks a member $a \in S$, then $b \notin S$
(else $S$ would not be conflict-free), so by stability some $c \in S$
attacks $b$; thus $S$ defends $a$, and $S$ is admissible. For closure
under defense, suppose $a \in F(S)$ but $a \notin S$. By stability some
$b \in S$ attacks $a$; since $S$ defends $a$, some $c \in S$ attacks $b$;
then $b, c \in S$ with $R\,c\,b$ violates conflict-freedom. Hence
$F(S) \subseteq S$ and $S$ is complete. $\square$

**Theorem 6.2.** *Every stable extension is preferred.*

*Proof.* Let $S$ be stable, hence admissible (Theorem 6.1). Let $T$ be
admissible with $S \subseteq T$; we show $T = S$. If $a \in T \setminus S$,
then by stability some $b \in S \subseteq T$ attacks $a$; but then
$b, a \in T$ with $R\,b\,a$ contradicts conflict-freedom of $T$. Hence
$T \setminus S = \emptyset$ and $T = S$, so $S$ is maximal admissible. $\square$

Together, Theorems 5.1, 6.1, 6.2 establish the class inclusions
$\text{stable} \subseteq \text{preferred} \subseteq \text{complete} \subseteq \text{admissible}$.

---

## 7. Existence of preferred extensions

**Theorem 7.1 (Chain unions).** *If $\mathcal{S}$ is a chain of admissible
sets (totally ordered by inclusion), then $\bigcup \mathcal{S}$ is
admissible.*

*Proof sketch.* *Conflict-freedom.* If $a, b \in \bigcup\mathcal{S}$ with
$R\,a\,b$, choose $S, T \in \mathcal{S}$ with $a \in S$, $b \in T$. By the
chain property $S \subseteq T$ or $T \subseteq S$; either way $a$ and $b$
lie in a common member, contradicting its conflict-freedom.
*Defense.* If $a \in \bigcup\mathcal{S}$, pick $S \in \mathcal{S}$ with
$a \in S$. For any attacker $b$ of $a$, admissibility of $S$ gives
$c \in S \subseteq \bigcup\mathcal{S}$ with $R\,c\,b$. Hence
$\bigcup\mathcal{S}$ defends all its members. $\square$

**Theorem 7.2 (Extension to a preferred extension).** *Every admissible
set $S$ is contained in some preferred extension.*

*Proof.* Consider the poset $P_S = \{ T : T \text{ admissible},\ S \subseteq T\}$
ordered by inclusion. It is nonempty ($S \in P_S$). By Theorem 7.1 every
chain in $P_S$ has an upper bound (its union, admissible and containing
$S$; the empty chain is bounded by $S$ itself). Zorn's lemma yields a
maximal element $P \in P_S$. Maximality in $P_S$ means: any admissible
$T \supseteq P$ (automatically in $P_S$ since $S \subseteq P \subseteq T$)
equals $P$. Thus $P$ is a maximal admissible set — a preferred extension —
containing $S$. $\square$

**Theorem 7.3 (Existence).** *Every argumentation framework has at least
one preferred extension.*

*Proof.* The empty set is admissible (vacuously conflict-free and defends
nothing). Apply Theorem 7.2 with $S = \emptyset$. $\square$

No finiteness or well-foundedness is used; existence is fully
unconditional, at the cost of the axiom of choice via Zorn's lemma, which
is expected and matches the classical theory.

---

## 8. The structural characterization

**Theorem 8.1 (Preferred = maximal complete).** *A set $S$ is a preferred
extension if and only if $S$ is a maximal complete extension, i.e. $S$ is
complete and every complete $T \supseteq S$ equals $S$.*

*Proof.*
($\Rightarrow$) Let $S$ be preferred. By Theorem 5.1, $S$ is complete. If
$T$ is complete with $S \subseteq T$, then $T$ is in particular admissible,
so maximality of $S$ among admissible sets gives $T = S$. Thus $S$ is
maximal complete.

($\Leftarrow$) Let $S$ be maximal complete. Then $S$ is admissible. By
Theorem 7.2 there is a preferred $P \supseteq S$. By Theorem 5.1, $P$ is
complete, and $S \subseteq P$ with $S$ maximal complete forces $P = S$.
Hence $S = P$ is preferred. $\square$

**Corollary 8.2 (Pointed poset of complete extensions).** Order the
complete extensions of $(A, R)$ by inclusion. This poset has a least
element — the grounded extension — and its maximal elements are exactly
the preferred extensions, which always exist (Theorem 7.3). Thus the
semantics of $(A, R)$ is faithfully captured by a *pointed poset* spanning
from the grounded verdict at the bottom to the preferred verdicts at the
top.

---

## 9. Algorithms

While the existence results are non-constructive in the infinite case (they
invoke Zorn's lemma), the finite case is fully algorithmic. We record the
core procedures; complexity is stated for a framework with $n = |A|$
arguments and $m = |R|$ attacks.

**9.1 Defense test and the characteristic operator.** Deciding whether
$S$ defends $a$ scans the attackers of $a$ and checks each has an attacker
in $S$: $O(m)$ time. Computing $F(S) = \{a : S \text{ defends } a\}$ costs
$O(nm)$.

**9.2 Grounded extension by least fixed point.** Iterate
$S_0 = \emptyset$, $S_{k+1} = F(S_k)$ until stabilization. Monotonicity of
$F$ (Corollary 3.2) guarantees an increasing sequence converging in at
most $n$ steps; total cost $O(n^2 m)$. The limit is the grounded
extension.

**9.3 Preferred extensions by admissible growth.** The Fundamental Lemma
justifies a greedy/branching search: begin with an admissible set (e.g.
$\emptyset$), repeatedly add any defended argument (each addition preserves
admissibility by Theorem 4.1), and branch when independent extensions are
possible. Maximal admissible sets so reached are exactly the preferred
extensions (Theorem 8.1). Enumerating all preferred extensions is
intractable in the worst case (the problem is coNP-hard in general), but
the growth step itself is cheap and always sound.

**9.4 Stability check.** Given a candidate $S$, verify conflict-freedom
($O(m)$) and that every outside argument has an attacker in $S$
($O(nm)$). By Theorem 6.2 a stable set found this way is automatically
preferred.

---

## 10. Worked examples

**Example 10.1 (Two-cycle).** $A = \{a, b\}$, attacks $R\,a\,b$ and
$R\,b\,a$. Admissible sets: $\emptyset$, $\{a\}$, $\{b\}$. The grounded
extension is $\emptyset$ (neither argument defends itself decisively from
$\emptyset$). Preferred extensions: $\{a\}$ and $\{b\}$ — two maximal
admissible sets. Both are stable (each attacks the excluded argument).
This shows preferred extensions need not be unique and that the pointed
poset can branch to multiple maxima.

**Example 10.2 (Three-cycle).** $A = \{a, b, c\}$ with $R\,a\,b$,
$R\,b\,c$, $R\,c\,a$. The only admissible set is $\emptyset$: any single
argument is attacked by one whose attacker lies outside, so nothing is
defended. Grounded = preferred = $\emptyset$, and there is *no* stable
extension. This exhibits a framework whose preferred extension is empty
and where stability fails — the gap central to Conjecture 2 below.

**Example 10.3 (Defense chain).** $A = \{a, b, c\}$ with $R\,b\,a$ and
$R\,c\,b$ (a path). Here $c$ has no attacker, so $c$ is defended by
$\emptyset$; $\{c\}$ is admissible and defends $a$ (its attacker $b$ is
attacked by $c$). By the Fundamental Lemma $\{a, c\}$ is admissible;
it is maximal, hence preferred, and it is complete and stable. The
grounded extension is also $\{a, c\}$: here the pointed poset collapses to
a single point. This is the well-founded, uniquely-determined case.

---

## 11. Applications

Abstract argumentation frameworks model reasoning under conflict, and the
results here answer their central structural questions.

- **Multi-agent negotiation.** Agents exchange attacking claims; a
  preferred extension is a maximally committed, internally consistent
  negotiating position. Theorem 7.3 guarantees such a position always
  exists.
- **Decision support and explanation.** In systems that weigh pro/con
  considerations, complete extensions are the coherent verdicts and the
  grounded extension is the cautious default; the pointed poset
  (Corollary 8.2) lays out the full spectrum of defensible conclusions
  for a user to inspect.
- **Legal and normative reasoning.** Stable extensions correspond to
  verdicts that leave nothing undecided; Theorems 6.1–6.2 place them at
  the summit of the hierarchy and reduce their search to inspecting
  maximal complete extensions.
- **Explainable AI.** The Fundamental Lemma provides a certified,
  incremental way to build up a justified set of accepted claims one
  defended argument at a time — a natural backbone for step-by-step
  explanations.

---

## 12. Discussion

The development is deliberately hypothesis-free. Classical treatments
often assume the framework is finite or well-founded to secure existence
and completeness of preferred extensions. We show that neither is needed:
the Fundamental Lemma (Theorem 4.1) plus chain-union admissibility
(Theorem 7.1) and Zorn's lemma deliver existence in full generality
(Theorem 7.3), and completeness of preferred extensions (Theorem 5.1) is a
two-line corollary of the lemma and maximality.

Methodologically, the paper argues for routing everything through the
Fundamental Lemma rather than through bespoke fixed-point reasoning. A
direct fixed-point proof of *preferred implies complete* would essentially
re-run the grounded-extension construction and would not generalize
cleanly to the infinite, non-well-founded setting; the conflict-avoidance
argument does, and is shorter.

The final payoff is conceptual. Theorem 8.1 translates a
*growth*-flavored definition (maximal admissible) into an
*order*-flavored one (maximal complete), and Corollary 8.2 packages the
entire semantics as a pointed poset. This bridges argumentation theory and
order theory and sets the stage for the finer structural questions below.

---

## 13. Future directions

*The following program is stated for a framework with attack relation of
arbitrary cardinality.*

**Conjecture 1 — The complete extensions form a complete
meet-semilattice.** Every nonempty family of complete extensions has a
greatest lower bound that is again complete, computed by iterating the
defense operator $F$ from the intersection. The insight: $F$ is monotone
and the grounded construction is its least fixed point started from
$\emptyset$; the same iteration started from an arbitrary intersection of
complete extensions should converge to the largest complete extension below
all of them. The Fundamental Lemma and the pointed-poset characterization
reduce the missing ingredient to a purely order-theoretic
fixed-point-from-below argument.

**Conjecture 2 — A dichotomy for stable existence.** A framework admits a
stable extension if and only if some preferred extension attacks every
argument outside it; equivalently, stable extensions are exactly the
preferred extensions with empty "undecided" region. The insight:
stability is strictly stronger than completeness, yet every stable set is
preferred (Theorem 6.2); the gap between preferred and stable is precisely
the set of arguments neither accepted nor attacked. With *preferred =
maximal complete* proved, the search for stable extensions reduces to a
boundary condition on the maximal elements of a single poset.

**Conjecture 3 — Topological reflection of the extension poset.** The
nerve (order complex) of the poset of complete extensions, ordered by
inclusion, is contractible, reflecting that the grounded extension is a
canonical least element to which the whole family retracts. The insight: a
poset with a least element has a contractible order complex; identifying
the grounded extension as that least element promotes a semantic fact into
a topological one. The pointed-poset structure isolated here is exactly
the hypothesis under which the classical "least element $\Rightarrow$
contractible nerve" principle applies.

---

## 14. Conclusion

From a single conflict-avoidance lemma we recovered, without finiteness or
well-foundedness, the full maximal-extension theory of abstract
argumentation: admissibility grows freely along defended arguments,
maximal admissible sets are complete, stable extensions sit at the summit,
preferred extensions always exist, and — the structural keystone —
preferred extensions coincide exactly with maximal complete extensions.
The complete extensions of any framework thereby form a pointed poset,
anchored below by the grounded extension and above by the preferred
extensions. Reasoning under conflict, stripped to pure structure, has the
shape of an ordered landscape.
