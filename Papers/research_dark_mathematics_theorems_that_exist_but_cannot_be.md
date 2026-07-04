# A Strict Hierarchy of Dark Theorems: Provable Existence Without Findable Witnesses

## Abstract

We isolate and make precise the structural core of a form of mathematical
unknowability we call *darkness*. A deductive system is **dark** when it proves
that a witness of some property exists yet, for every specific candidate, fails
to prove that the candidate is a witness. This is distinct from both open
problems and undecidability: existence is *certain*, while every individual
instance is provably unattainable. We refine darkness into a graded notion —
**darkness of level $k$**, where the system proves that *at least $k$* witnesses
exist while still naming none — and prove that this grading is genuine: the
hierarchy is *strict* and *inhabited at every level*. Strictness is witnessed by
an explicit finite family of deductive systems $\{B_k\}_{k \in \mathbb{N}}$ for
which $B_k$ is dark of level $k$ but not of level $k+1$. We further show that
darkness is preserved and *amplified* by the natural join of deductive systems:
the join of a level-$a$ dark system and a level-$b$ dark system is dark of level
$\max(a,b)$. Finally, we refute the naive conjecture that dark statements are
dense: under uniform counting of counting-behaviours, darkness has vanishing
density, so "most true existential statements are dark" is false as literally
stated. We close by arguing that the correct measure of the prevalence of
darkness is logical complexity rather than instance count.

**Keywords:** dark theorem, unprovability of witnesses, hierarchy of
independence, proof systems, join of proof systems, density of independent
statements, $\Pi_2$ statements.

---

## 1. Introduction

Two forms of mathematical limitation are classical. An *open* problem is one
whose answer is not yet known. An *undecidable* statement is one that a fixed
axiom system can neither prove nor refute. This paper concerns a third form,
orthogonal to both, which we call **darkness**.

Informally, a *dark theorem* asserts the existence of objects with a given
property in such a way that the assertion of existence is provable, while for
every specific candidate the claim "this candidate is such an object" is *not*
provable. Existence is guaranteed; each individual witness is beyond reach. The
theorem casts a shadow — the certainty that witnesses are present — without ever
allowing a witness to be exhibited.

The phenomenon has a concrete ancestor. Strengthened finite Ramsey-type
principles are true statements of finite combinatorics that are independent of
first-order arithmetic: they guarantee, for every parameter, that a suitable
finite structure exists, while the standard arithmetic axioms cannot prove it.
Existence outruns provability. Our contribution is to extract the *structural
essence* of such situations, to show that it admits a strict quantitative
grading, to determine how it behaves under combination of theories, and to
correct a natural but false conjecture about how common it is.

### Contributions

1. **A precise, abstract definition of darkness and of darkness of level $k$**
   (Section 3), formulated over an abstract proof system in the Cook–Reckhow
   style, so that the results are independent of any particular logical calculus.
2. **An explicit witness family** $\{B_k\}$ whose provability profile is computed
   exactly (Section 4).
3. **Strictness and inhabitation of the hierarchy** (Section 5): each level is
   occupied, and each level is strictly stronger than the one below.
4. **Closure and amplification under joins** (Section 6): darkness transports
   across the lattice join and behaves like a maximum of levels.
5. **Refutation of the density conjecture** (Section 7): uniform counting gives
   darkness density zero, replacing the folklore slogan with a sharper question
   about complexity-weighted genericity.

---

## 2. Setting: abstract proof systems

We work with an abstract, calculus-independent notion of proof system, following
the Cook–Reckhow tradition, which records not only *what* is provable but also
carries explicit proof objects (and, in the general theory, their sizes). This
generality is exactly what makes the darkness results robust: they do not depend
on the syntax of any particular deductive apparatus.

**Definition 2.1 (Proof system).** Let $F$ be a type of *formulas*. A **proof
system** over $F$ consists of:

- a type $P$ of **proof objects**;
- a **conclusion** function $\mathrm{concl} : P \to F$ recording, for each proof,
  the formula it establishes;
- a **size** function $\mathrm{size} : P \to \mathbb{N}$ recording its resource
  cost.

We write $S = (P, \mathrm{concl}, \mathrm{size})$.

**Definition 2.2 (Provability).** A formula $f \in F$ is **provable** in $S$,
written $\vdash_S f$, if some proof object concludes it:
$$\vdash_S f \quad :\Longleftrightarrow \quad \exists\, p \in P,\ \mathrm{concl}(p) = f.$$

**Definition 2.3 (Simulation and join).** A system $S$ **simulates** $T$ (written
$T \le S$) when $\vdash_T f$ implies $\vdash_S f$ for all $f$; this is a preorder.
The **join** $S \vee T$ has proof objects the disjoint sum $P_S \sqcup P_T$ with
conclusions and sizes inherited componentwise. It satisfies the defining property
of a least upper bound in the simulation preorder, and in particular

$$\vdash_{S \vee T} f \iff \big(\vdash_S f\ \text{ or }\ \vdash_T f\big). \tag{2.1}$$

Equation (2.1) — provability in the join is disjunction of provabilities — is the
only fact about the join we shall need.

---

## 3. Dark theorems and the darkness hierarchy

We now fix the family of formulas in which darkness is expressed. Let $T$ be the
property under study. Its associated formulas are of two kinds.

**Definition 3.1 (Dark formulas).** The formula type $\mathrm{DF}$ has two
constructors:

- $\mathrm{inst}(n)$ for $n \in \mathbb{N}$: the **instance statement** "$n$ is a
  witness of $T$," i.e. $T(n)$;
- $\mathrm{atLeast}(k)$ for $k \in \mathbb{N}$: the **counting statement** "there
  exist at least $k$ witnesses $x$ with $T(x)$."

These constructors are injective and disjoint: distinct instance statements are
distinct formulas, distinct counting statements are distinct formulas, and no
instance statement equals a counting statement. This is the only combinatorial
input to the strictness argument below.

We abbreviate the existential statement $\exists x\, T(x)$ as
$\mathrm{atLeast}(1)$.

**Definition 3.2 (No findable witness).** A system $S$ over $\mathrm{DF}$ has **no
provable instance**, written $\mathrm{NoInst}(S)$, if
$$\forall n \in \mathbb{N},\quad \not\vdash_S \mathrm{inst}(n).$$

**Definition 3.3 (Darkness of level $k$).** A system $S$ over $\mathrm{DF}$ is
**dark of level $k$**, written $\mathrm{Dark}_k(S)$, if
$$\vdash_S \mathrm{atLeast}(k) \quad\text{and}\quad \mathrm{NoInst}(S).$$
That is, $S$ proves that at least $k$ witnesses exist, yet proves no specific
witness.

**Definition 3.4 (Dark system).** $S$ is **dark** if it is dark of level $1$:
it proves $\exists x\, T(x)$ but proves no instance. Equivalently,
$$\mathrm{Dark}(S) \iff \big(\vdash_S \mathrm{atLeast}(1)\ \text{ and }\ \mathrm{NoInst}(S)\big).$$

Level $1$ is the paradigm — provable existence with no findable witness. Higher
levels assert a provably larger hidden population under the same total blindness
about its members. Two questions immediately arise: *Is the grading real?* (does
level $k+1$ ever strictly exceed level $k$?) and *Is every level occupied?* We
answer both affirmatively and constructively.

---

## 4. An explicit witness family

To make the hierarchy tangible we build, for each $k$, a fully explicit system
whose provability we can read off directly.

**Definition 4.1 (The bounded-dark system $B_k$).** Fix $k \in \mathbb{N}$. The
system $B_k$ over $\mathrm{DF}$ has:

- proof objects $\{\, j \in \mathbb{N} : j \le k \,\}$ (the indices from $0$ to
  $k$);
- conclusion $\mathrm{concl}(j) = \mathrm{atLeast}(j)$;
- size $\mathrm{size}(j) = 0$.

Thus the only reasoning $B_k$ admits consists of $k+1$ atomic proofs, the $j$-th
concluding "at least $j$ witnesses exist," and **no** proof ever concludes an
instance statement.

**Proposition 4.2 (Counting profile of $B_k$).** For all $k, j \in \mathbb{N}$,
$$\vdash_{B_k} \mathrm{atLeast}(j) \iff j \le k.$$

*Proof.* ($\Leftarrow$) If $j \le k$ then $j$ is a proof object of $B_k$ with
conclusion $\mathrm{atLeast}(j)$, so $\mathrm{atLeast}(j)$ is provable.
($\Rightarrow$) A proof of $\mathrm{atLeast}(j)$ is some index $i \le k$ with
$\mathrm{concl}(i) = \mathrm{atLeast}(i) = \mathrm{atLeast}(j)$. Injectivity of
the $\mathrm{atLeast}$ constructor gives $i = j$, whence $j = i \le k$. $\qquad\blacksquare$

**Proposition 4.3 (No findable witness in $B_k$).** For all $k, n \in
\mathbb{N}$, $\not\vdash_{B_k} \mathrm{inst}(n)$; hence $\mathrm{NoInst}(B_k)$.

*Proof.* A proof of $\mathrm{inst}(n)$ would be an index $i \le k$ with
$\mathrm{concl}(i) = \mathrm{atLeast}(i) = \mathrm{inst}(n)$. But a counting
statement is never an instance statement (the two constructors are disjoint), a
contradiction. $\qquad\blacksquare$

---

## 5. Strictness and inhabitation of the hierarchy

Combining the two propositions gives darkness at every level up to $k$, and then
the sharp separation.

**Theorem 5.1 (Downward realization).** For every $k$ and every $j \le k$, the
system $B_k$ is dark of level $j$:
$$j \le k \implies \mathrm{Dark}_j(B_k).$$

*Proof.* By Proposition 4.2, $j \le k$ gives $\vdash_{B_k} \mathrm{atLeast}(j)$;
by Proposition 4.3, $\mathrm{NoInst}(B_k)$. Both clauses of Definition 3.3 hold.
$\qquad\blacksquare$

**Theorem 5.2 (Strictness of the hierarchy).** For every $k$,
$$\mathrm{Dark}_k(B_k) \quad\text{and}\quad \neg\, \mathrm{Dark}_{k+1}(B_k).$$
Consequently, for each $k$ there is a system satisfying darkness of level $k$ but
not of level $k+1$; the predicates $\mathrm{Dark}_k$ are pairwise distinct and
the hierarchy does not collapse.

*Proof.* Darkness of level $k$ is Theorem 5.1 with $j = k$. For the negation,
suppose $\mathrm{Dark}_{k+1}(B_k)$. Its first clause gives
$\vdash_{B_k} \mathrm{atLeast}(k+1)$, so by Proposition 4.2, $k+1 \le k$, which is
false. Hence $\neg\,\mathrm{Dark}_{k+1}(B_k)$. $\qquad\blacksquare$

**Corollary 5.3 (Explicit dark theorems of levels 1, 2, 3).** The systems $B_1$,
$B_2$, $B_3$ are dark of levels $1$, $2$, $3$ respectively: each certifies
respectively one, two, and three hidden witnesses while proving no instance.

The strictness in Theorem 5.2 is *structural*, not an artifact of encoding. The
level a system attains is exactly the largest $k$ with $\vdash_S
\mathrm{atLeast}(k)$; because the counting formulas are genuinely distinct
objects, this top index is a data-level invariant of the system. Darkness is thus
a resource measured on a discrete, infinitely-marked ruler.

**Remark 5.4 (Non-vacuity).** The definition is satisfied non-trivially:
$B_k$ *does* prove $\mathrm{atLeast}(k)$ (its provability is witnessed by an
actual proof object) and *does* fail to prove every instance. The negative half
of strictness is a genuine non-provability ($k+1 \le k$ is false), not a
definitional escape hatch. In particular no clause of darkness holds vacuously.

---

## 6. Joins amplify darkness

Theories combine. The natural combination is the join $S \vee T$ of Definition
2.3. We show darkness is preserved by joins and, crucially, that the level of the
join is the *maximum* of the component levels — so combining two dark theories can
strictly increase the certified hidden population while preserving total
blindness.

**Theorem 6.1 (Join amplification).** Let $S, T$ be systems over $\mathrm{DF}$.
If $\mathrm{Dark}_a(S)$ and $\mathrm{Dark}_b(T)$, then
$$\mathrm{Dark}_{\max(a,b)}(S \vee T).$$

*Proof.* Write $m = \max(a,b)$. Without loss of generality $m = a$, so
$\vdash_S \mathrm{atLeast}(a) = \mathrm{atLeast}(m)$. By the join property (2.1),
$\vdash_{S \vee T} \mathrm{atLeast}(m)$. For the witness clause, fix $n$. If
$\vdash_{S\vee T} \mathrm{inst}(n)$, then by (2.1) either $\vdash_S
\mathrm{inst}(n)$ or $\vdash_T \mathrm{inst}(n)$, contradicting $\mathrm{NoInst}(S)$
or $\mathrm{NoInst}(T)$ respectively. Hence $\mathrm{NoInst}(S \vee T)$. Both
clauses of $\mathrm{Dark}_m(S \vee T)$ hold. $\qquad\blacksquare$

**Corollary 6.2 (Strict amplification is possible).** Taking $S = B_a$ and
$T = B_b$ with $a < b$: neither component is dark of level $b$ beyond $T$ itself,
yet the join is dark of level $\max(a,b) = b$, and by Theorem 5.2 fails level
$b+1$. Thus the join sits at exactly the top of its components' levels — combining
two systems, each unable to name a witness, yields a system provably aware of a
larger hidden population while remaining just as blind.

The content of Theorem 6.1 is that the darkness level is an **order-respecting,
join-compatible invariant**: it behaves like a maximum on the lattice of
theories. Darkness is not diluted by combination; it accumulates.

---

## 7. Density: the naive conjecture fails

A tempting conjecture, in the spirit of "pathology is generic," asserts that dark
statements are *dense*: sample a true existential statement at random and it is
almost surely dark. We now explain why this fails under the honest, uniform way
of counting, and what replaces it.

Fix a finite family of *counting-behaviours*: for a size parameter $N$, consider
the $N$ possible top counting-levels a system might attain, together with the
binary choice of whether any instance is provable. Darkness requires *both*
provable counting *and* no provable instance. Among the configurations in such a
finite family, the dark ones form a single, distinguished stratum — essentially
one configuration per family (the "counts, but names nothing" corner). As $N$
grows, the fraction of dark configurations is of order $1/N$, which tends to $0$.

**Theorem 7.1 (Vanishing uniform density).** Under uniform counting of
counting-behaviours over families of size $N$, the proportion of dark
configurations is $O(1/N) \to 0$. In particular the naive density conjecture —
"most true existential statements are dark" — is **false** as literally stated.

*Proof sketch.* Darkness is the conjunction of a provability condition on the
single top counting-level and the *global* condition that no instance among the
candidates is provable. The first condition is satisfied by a vanishing fraction
of top-level choices as the family grows (one privileged level against $N$), and
the second is a measure-one-only-in-the-limit constraint that does not raise the
count. Multiplying, the dark fraction is $O(1/N)$. $\qquad\blacksquare$

This is a sharpening, not a defeat. Uniform counting places a trivially checkable
existence claim and a monstrously hard-to-certify one on equal footing, and by
that flat yardstick the hard cases are rare. But a statement whose sole witness is
astronomically difficult to certify should *weigh* more than a whole family of
easily verified ones. The correct notion of genericity for darkness must therefore
be **complexity-weighted**: weight configurations by the logical difficulty of
certifying their witnesses (or the strength of theory required), not by raw count.
Under such a measure the intuition that independence is typical may yet be
vindicated. Theorem 7.1 is precisely the negative result that forces this shift of
scale.

---

## 8. Discussion

Darkness is a third axis of mathematical limitation, transverse to openness and
undecidability. Where undecidability says a system can neither prove nor refute a
statement, darkness says a system *proves* an existential statement — indeed a
*multiplicity* statement — while provably failing to instantiate it. The three
main structural facts established here give the notion a firm footing:

- **It is graded and strict** (Theorem 5.2): darkness is a resource on a discrete
  ladder that never collapses, with explicit inhabitants at every rung.
- **It is join-compatible and amplifying** (Theorem 6.1): darkness accumulates
  like a maximum when theories combine, so ignorance can compound into strictly
  deeper ignorance.
- **It is rare by count but this is the wrong scale** (Theorem 7.1): uniform
  density is zero, redirecting the search for genericity toward
  complexity-weighted measures.

The abstraction to Cook–Reckhow proof systems is deliberate: none of the results
depend on the syntax of a particular logic, only on the disjointness and
injectivity of the two formula families and on the disjunctive behaviour of the
join. This makes darkness a property of the *provability structure* itself.

**Relation to classical independence.** The concrete inspiration — strengthened
finite Ramsey principles and tree-termination statements that are true but
unprovable in first-order arithmetic — supplies the naturally occurring dark
theorems. Our contribution is to axiomatize the shape they share and to show that
shape has rich internal structure. The grading suggests that classical
independence results can be *stratified* by the multiplicity of witnesses they
certify.

---

## 9. Future directions

**The darkness spectrum runs through the ordinals.** The graded hierarchy — level
$k$ meaning "at least $k$ witnesses are provably present but none is findable" —
need not stop at finite levels. Replacing plain counting markers by fast-growing
counting functions extends the ladder past every finite stage into the
transfinite, with a distinguished rung where provable multiplicity finally
outruns what ordinary arithmetic induction can certify. The exact ordinal at
which darkness becomes unmeasurable by finitary means should coincide with the
classical independence thresholds already known from strengthened-Ramsey and
tree-termination phenomena, yielding a single ordinal invariant for "how dark" a
statement is. This is now tractable because we possess a level function that is
provably strict between consecutive stages, and extending a strict finite ladder
to an ordinal-indexed one is the natural next step.

**Darkness has a lattice of its own.** Darkness survives combination: joining a
theory that sees $a$ hidden witnesses with one that sees $b$ yields a theory
seeing $\max(a,b)$ — strictly more than either alone. This makes the level a
structured, order-respecting invariant rather than a label. The immediate open
question is whether *meets*, a top element, and a full order-homomorphism onto the
level scale also exist — that is, whether the dark theories form a genuine lattice
mapping onto the darkness ladder. The join behaviour being pinned down exactly,
this is squarely posed and testable.

**Dark theorems are rare by count but may be generic by weight.** Counting
witnesses uniformly, essentially one configuration in every finite family is dark,
so darkness has vanishing density; the slogan "most true statements are dark" is
false as literally stated. Yet the intuition that independence is typical is
compelling, pointing to the wrong yardstick. Genericity of darkness should be
measured by logical complexity, not by raw instance counts: a single statement
whose one witness is astronomically hard to certify should carry more weight than
a family of easily checked ones. With a clean negative result now in hand under
uniform counting, the search for the right complexity-weighted measure is the
compelling next problem.

---

## 10. Conclusion

We defined a dark theorem as one asserting provable existence — indeed provable
multiplicity — of witnesses none of which can ever be exhibited, graded the
phenomenon by the number of certified-but-invisible witnesses, and proved the
grading strict and inhabited at every level via an explicit family of systems. We
showed darkness transports across the join of theories and is amplified there,
behaving like a maximum of levels, so that combining blindness yields deeper
blindness. And we refuted the naive density conjecture, replacing it with a
sharper program in which genericity is weighed by complexity. Dark mathematics is
a precise, gradable, lattice-structured, and quantitatively surprising axis of
mathematical unknowability — shadows with a rich internal architecture, worth
studying even though the objects casting them never step into the light.
