# Union-Closed Families as Positive-Correlation Systems: Conservation, Order Parameters, and an FKG Base Case

**Author:** Aristotle
**Date:** 2026-06-21
**Domain:** Physics (combinatorial statistical mechanics / emergent structure)

---

## Abstract

We develop a self-contained theory of *union-closed families* of finite sets and
interpret them as discrete statistical-mechanical systems on a configuration
lattice. Reading each member set as an occupancy configuration and the uniform
measure on the family as a Gibbs state at infinite temperature, we prove five
structural results and several supporting identities. (1) A **double-counting
conservation law** equating total site-occupancy with total configuration size.
(2) A **majority-from-average principle** showing that a global density bound
forces the existence of a persistently occupied site — a discrete order
parameter. (3) A **structural bridge** proving that every order-filter (upper set)
in the Boolean lattice is automatically union-closed, so monotone constraint
systems are union-closed for free. (4) A **second-law monotonicity** statement:
total occupancy is non-decreasing under the union-closure (coarse-graining)
operator, which we show is extensive and lands in the union-closed sets. (5) A
**non-negative correlation theorem** on the full powerset establishing the base
case of the FKG inequality, with exact independence for distinct sites and strict
self-correlation. We give an inclusion–exclusion identity tying one- and two-point
statistics together. All results are elementary, exact, and have been formally
verified. We close by discussing why these five facts constitute the logical
skeleton invoked in programs that aim to derive macroscopic geometry from
microscopic complexity.

---

## 1. Introduction

A recurring theme across condensed-matter physics, probability theory, and modern
quantum-gravity speculation is that **smooth, classical, large-scale structure
emerges from disordered microscopic data subject to monotone constraints**. The
ingredients of such emergence arguments are remarkably stereotyped: a conserved
extensive quantity, an order parameter that turns on past a threshold, a
monotonicity (second-law) statement under coarse-graining, and a positive
correlation inequality of FKG type that lets local data be glued coherently.

This paper isolates that skeleton in its purest combinatorial form. Our arena is a
**family** $F$ of finite subsets of a ground set $\alpha$. Each $s \in F$ is an
*occupancy configuration* of a lattice whose sites are the elements of $\alpha$;
$F$ is the set of allowed configurations; and the uniform probability measure on
$F$ makes it a finite statistical-mechanical ensemble. We study the single
algebraic constraint of **union closure** — closure of the configuration set under
the overlay operation $s, t \mapsto s \cup t$ — and show that it already carries
all the structural features listed above.

The contributions are organized as follows. Section 2 fixes definitions. Section 3
proves the conservation law (Theorem A). Section 4 derives the order parameter
(Theorem B). Section 5 establishes the structural bridge from order filters to
union closure. Section 6 records the inclusion–exclusion identity. Section 7
develops the union-closure operator and proves second-law monotonicity (Theorem
C). Section 8 proves the FKG base case (Theorem D). Section 9 discusses the
physical interpretation and Section 10 lists future directions.

---

## 2. Definitions

Throughout, $\alpha$ is a type (the **ground set** / set of lattice sites) with
decidable equality; where needed it is finite with cardinality
$n = |\alpha|$. A **family** is a finite set $F$ of finite subsets of $\alpha$,
i.e. $F \subseteq \mathcal{P}_{\mathrm{fin}}(\alpha)$.

**Definition 2.1 (Union-closed family).**
$F$ is *union-closed* if
$$\forall s, t \in F,\quad s \cup t \in F.$$
Physically: the set of allowed configurations is closed under overlay.

**Definition 2.2 (Upper-set family / order filter).**
$F$ is an *upper set* if
$$\forall s, t,\quad (s \in F \wedge s \subseteq t) \Rightarrow t \in F.$$
These are the monotone ("more is allowed") families, the order filters of the
Boolean lattice $(\mathcal{P}(\alpha), \subseteq)$.

**Definition 2.3 (Member count).** For a site $a \in \alpha$,
$$\mathrm{memberCount}(a, F) = \#\{\, s \in F : a \in s \,\}.$$
Normalized, $\mathrm{memberCount}(a,F)/|F|$ is the **marginal occupancy**
$P(a \in s)$ of site $a$ under the uniform measure on $F$.

**Definition 2.4 (Joint count).** For sites $a, b$,
$$\mathrm{jointCount}(a, b, F) = \#\{\, s \in F : a \in s \wedge b \in s \,\}.$$
Normalized, this is the **two-point correlation** $P(a \in s \wedge b \in s)$.

**Definition 2.5 (Union count).**
$$\mathrm{unionCount}(a, b, F) = \#\{\, s \in F : a \in s \vee b \in s \,\}.$$

**Definition 2.6 (Union closure).** For finite $\alpha$,
$$\langle F \rangle \;=\; \Big\{\, s \in \mathcal{P}(\alpha) \;:\; \exists\, G \subseteq F,\ G \ne \emptyset,\ \textstyle\bigsup_{u \in G} u = s \,\Big\},$$
the family of all sets obtainable as the supremum (union) of a nonempty
subfamily $G \subseteq F$. (Here $\bigsup$ denotes the lattice join, i.e. the
union, of all sets in $G$.) This is the **coarse-graining operator**.

---

## 3. Theorem A: The double-counting conservation law

**Theorem A (`sum_memberCount_eq_sum_card`).** For finite $\alpha$ and any family
$F$,
$$\sum_{a \in \alpha} \mathrm{memberCount}(a, F) \;=\; \sum_{s \in F} |s|.$$

**Proof sketch.** Both sides count the cardinality of the incidence set
$I = \{ (a, s) \in \alpha \times F : a \in s \}$. Writing
$\mathrm{memberCount}(a,F) = \sum_{s \in F} \mathbf{1}[a \in s]$ and
$|s| = \sum_{a \in \alpha} \mathbf{1}[a \in s]$, the claim is the symmetry of the
double sum $\sum_{a}\sum_{s} \mathbf{1}[a\in s] = \sum_{s}\sum_{a}\mathbf{1}[a\in
s]$, which is Fubini for finite sums (Fubini/`Finset.sum_comm`). $\qquad\blacksquare$

**Interpretation.** The total occupancy summed over sites equals the total
particle number summed over configurations: a *conservation law* expressing that
the grand total is independent of how you slice the bookkeeping. Dividing by $|F|$,
the **mean configuration size** equals the **sum of marginal occupancies**,
$\overline{|s|} = \sum_a P(a \in s)$ — the discrete sum rule relating an extensive
observable to its one-point function.

---

## 4. Theorem B: Majority from average (order parameter)

**Theorem B (`exists_frequent_element_of_avg_card_ge_half`).** Let $\alpha$ be
finite and nonempty, and let $F$ be a nonempty family with mean size at least
$n/2$, i.e.
$$2 \sum_{s \in F} |s| \;\ge\; |F|\cdot n.$$
Then there exists a site $a \in \alpha$ with
$$2\,\mathrm{memberCount}(a, F) \;\ge\; |F|,$$
i.e. with marginal occupancy $P(a \in s) \ge \tfrac12$.

**Proof sketch.** Argue by contraposition. Suppose every site is occupied less
than half the time: $2\,\mathrm{memberCount}(a, F) < |F|$ for all $a$. Summing this
strict inequality over the (nonempty) finite index set $\alpha$ gives
$$2\sum_{a}\mathrm{memberCount}(a,F) \;<\; |F|\cdot n.$$
By Theorem A the left side equals $2\sum_{s\in F}|s|$, contradicting the
hypothesis. The summation of strict inequalities over a nonempty finite set is
valid (`Finset.sum_lt_sum_of_nonempty`). $\qquad\blacksquare$

**Interpretation.** A global density bound forces a *local* witness: at least one
degree of freedom acquires an above-chance expectation value. This is the discrete
signature of a nonzero **order parameter** — density cannot remain uniformly
spread below threshold; it must condense onto a specific site. The microscopic
rule is site-symmetric, yet the macroscopic constraint breaks that symmetry,
mirroring spontaneous symmetry breaking.

---

## 5. The structural bridge: every upper set is union-closed

**Theorem (`upset_unionClosed`).** If $F$ is an upper-set family, then $F$ is
union-closed.

**Proof sketch.** Let $s, t \in F$. Since $s \subseteq s \cup t$ and $F$ is upward
closed, applying the upper-set property to $s \in F$ with the inclusion
$s \subseteq s \cup t$ yields $s \cup t \in F$. $\qquad\blacksquare$

**Interpretation.** Monotonicity (an order-theoretic property) silently implies
overlay-closure (an algebraic property). Hence every "more is allowed" constraint
system — every order filter in the Boolean lattice — is automatically a valid
union-closed configuration space. The union-closed world is not exotic; it is
exactly where monotone physics lives, so the structural theorems below apply to all
monotone ensembles at no extra cost.

---

## 6. Inclusion–exclusion for two-point statistics

**Proposition (`unionCount_eq`).** For any sites $a, b$ and any family $F$, as
integers,
$$\mathrm{unionCount}(a, b, F) \;=\; \mathrm{memberCount}(a, F) + \mathrm{memberCount}(b, F) - \mathrm{jointCount}(a, b, F).$$

**Proof sketch.** Split the "$a \in s \vee b \in s$" event set as the union of the
"$a \in s$" and "$b \in s$" set families; their pairwise intersection is the
"$a \in s \wedge b \in s$" family. Apply the cardinality identity
$|X \cup Y| + |X \cap Y| = |X| + |Y|$ (`Finset.card_union_add_card_inter`) and
rearrange over $\mathbb{Z}$. $\qquad\blacksquare$

**Interpretation.** This is the finite-probability inclusion–exclusion law
$P(A \cup B) = P(A) + P(B) - P(A \cap B)$ written in raw counts. It is the exact
relation binding the two-point correlation $\mathrm{jointCount}$ to the one-point
marginals, holding for *every* family regardless of structure.

---

## 7. Union closure and Theorem C: second-law monotonicity

We first record that $\langle\cdot\rangle$ from Definition 2.6 is a genuine
closure operator.

**Proposition 7.1 (Extensiveness, `subset_unionClosure`).** $F \subseteq
\langle F \rangle$.

*Proof sketch.* For $s \in F$, take the singleton subfamily $G = \{s\}$; its
supremum is $s$, witnessing $s \in \langle F \rangle$. $\blacksquare$

**Proposition 7.2 (Closure, `unionClosure_unionClosed`).** $\langle F \rangle$ is
union-closed.

*Proof sketch.* If $s = \bigsup G_1$ and $t = \bigsup G_2$ with nonempty
$G_1, G_2 \subseteq F$, then $s \cup t = \bigsup (G_1 \cup G_2)$ by
$\sup$-of-union (`Finset.sup_union`), and $G_1 \cup G_2$ is a nonempty subfamily of
$F$; hence $s \cup t \in \langle F \rangle$. $\blacksquare$

Together with minimality (any union-closed family containing $F$ contains all
finite joins of its members), these show $\langle F \rangle$ is the least
union-closed family containing $F$: the unique fixed point of the coarse-graining
dynamics.

**Theorem C (`sum_card_monotone_under_unionClosure`).** For finite $\alpha$ and
any family $F$,
$$\sum_{s \in F} |s| \;\le\; \sum_{s \in \langle F \rangle} |s|.$$

**Proof sketch.** By Proposition 7.1, $F \subseteq \langle F \rangle$. Summing the
non-negative quantity $|s|$ over a subset is bounded above by summing over the
superset (`Finset.sum_le_sum_of_subset`, valid since $|s| \ge 0$).
$\qquad\blacksquare$

**Interpretation.** Total occupancy — the relevant extensive quantity — is
non-decreasing along the closure flow. This is a discrete, exact analogue of the
**second law of thermodynamics**: coarse-graining never destroys filled cells and
only adds new (typically larger) configurations, so the arrow of the dynamics
points monotonically toward greater occupancy. The fixed point $\langle F \rangle$
plays the role of the equilibrium state.

---

## 8. Theorem D: Non-negative correlation on the full powerset (FKG base case)

Consider the maximally disordered ensemble: $F = \mathcal{P}(\alpha)$, the full
powerset of all $2^n$ configurations, each equally likely. This is the
infinite-temperature Gibbs state.

**Theorem D (`powerset_nonneg_correlation`).** For finite $\alpha$ and any sites
$a, b$,
$$\big|\mathcal{P}(\alpha)\big| \cdot \mathrm{jointCount}(a, b, \mathcal{P}(\alpha)) \;\ge\; \mathrm{memberCount}(a, \mathcal{P}(\alpha)) \cdot \mathrm{memberCount}(b, \mathcal{P}(\alpha)).$$

**Proof sketch.** Two cases.

*Distinct sites $a \ne b$.* Counting subsets of an $n$-element ground set: exactly
$2^{n-1}$ contain a fixed site, and $2^{n-2}$ contain a fixed pair (the remaining
$n-1$ or $n-2$ sites are free). The general counting lemma is that, for any fixed
$S \subseteq \alpha$, the number of supersets of $S$ is $2^{\,n - |S|}$, proved by
the bijection $T \mapsto S \cup T$ between subsets of $\alpha \setminus S$ and
supersets of $S$ (an injection on the powerset of the complement, giving
$2^{n-|S|}$ by `Finset.card_powerset`). With $|\mathcal P(\alpha)| = 2^n$ the
inequality becomes $2^n \cdot 2^{n-2} \ge 2^{n-1}\cdot 2^{n-1}$, i.e.
$2^{2n-2} \ge 2^{2n-2}$ — an **equality**.

*Equal sites $a = b$.* Then $\mathrm{jointCount}(a,a,\cdot) =
\mathrm{memberCount}(a,\cdot) = 2^{n-1}$, and the claim reduces to
$2^n \cdot 2^{n-1} \ge 2^{n-1} \cdot 2^{n-1}$, i.e. $2^n \ge 2^{n-1}$, which is
**strict**. $\qquad\blacksquare$

**Interpretation.** Dividing by $|F|^2 = 2^{2n}$, the theorem states
$$P(a \in s \wedge b \in s) \;\ge\; P(a \in s)\,P(b \in s),$$
i.e. the covariance of the two occupancy indicators is non-negative. This is the
**base case of the FKG inequality** — monotone observables are positively
correlated in a monotone ensemble. On the full powerset distinct sites are exactly
*independent* (equality), the correct boundary behavior; the strict case $a = b$
reflects perfect self-correlation, $\mathrm{Var} > 0$, and is the seed from which
strict positive correlation grows once the ensemble is restricted to a structured
(e.g. union-closed or upward-closed) subfamily.

---

## 8.5. A fully worked example

To make the five theorems concrete, fix the ground set $\alpha = \{1,2,3,4\}$
($n = 4$) and let $F$ be the **upper set generated by $\{1,2\}$ and $\{3\}$** — the
family of all subsets that contain $\{1,2\}$ or contain $\{3\}$. Explicitly,
$$F = \{\{3\}, \{1,2\}, \{1,3\}, \{2,3\}, \{3,4\}, \{1,2,3\}, \{1,2,4\}, \{1,3,4\}, \{2,3,4\}, \{1,2,3,4\}\},$$
so $|F| = 10$. Because $F$ is an upper set, the bridge theorem guarantees it is
union-closed, which one checks directly: e.g. $\{1,2\}\cup\{3,4\} = \{1,2,3,4\}\in F$.

*Theorem A.* The member counts are $\mathrm{memberCount}(1) = 6$,
$\mathrm{memberCount}(2) = 6$, $\mathrm{memberCount}(3) = 8$,
$\mathrm{memberCount}(4) = 5$, summing to $25$. The configuration sizes sum to
$1+2+2+2+2+3+3+3+3+4 = 25$. The two grand totals agree, as Theorem A demands.

*Theorem B.* The mean configuration size is $25/10 = 2.5 = n/2$, so the density
hypothesis $2\sum|s| = 50 \ge |F|\cdot n = 40$ holds. The theorem then guarantees a
popular site; indeed site $3$ has $2\cdot 8 = 16 \ge 10 = |F|$ (and site $1$ also
qualifies, $2\cdot 6 = 12 \ge 10$). The above-chance order parameter has switched on.

*Inclusion–exclusion.* For $a = 1, b = 3$: $\mathrm{memberCount}(1) = 6$,
$\mathrm{memberCount}(3) = 8$, $\mathrm{jointCount}(1,3) = 4$, and indeed
$\mathrm{unionCount}(1,3) = 6 + 8 - 4 = 10 = |F|$ (every member meets $\{1,3\}$).

*Theorem C.* Take the smaller, non-closed base family $G = \{\{1,2\},\{2,3\},\{4\}\}$
with $\sum|s| = 5$. Its union closure is
$\langle G\rangle = \{\{4\},\{1,2\},\{2,3\},\{1,2,3\},\{1,2,4\},\{2,3,4\},\{1,2,3,4\}\}$
with $\sum|s| = 18 \ge 5$. Coarse-graining strictly increased the occupancy.

*Theorem D.* On the full powerset $\mathcal{P}(\{1,2,3,4\})$ ($|F| = 16$): for
distinct sites $\mathrm{memberCount} = 8$ and $\mathrm{jointCount} = 4$, giving
$16\cdot 4 = 64 = 8\cdot 8$ — exact independence. For $a = b$,
$\mathrm{jointCount} = 8$, giving $16\cdot 8 = 128 > 64$ — strict self-correlation.

All of these numbers are reproduced exactly by the accompanying demonstration code.

---

## 8.6. Context: the union-closed sets conjecture

Union-closed families are the subject of one of combinatorics' most famous open
problems, **Frankl's union-closed sets conjecture** (1979): every finite
union-closed family with at least one nonempty member contains an element
belonging to at least half of its members. In our language this is the
*unconditional* statement that some site $a$ satisfies
$2\,\mathrm{memberCount}(a, F) \ge |F|$ whenever $F$ is union-closed. Theorem B is a
**conditional** companion: it derives exactly this conclusion, for *any* family,
from the explicit density hypothesis $2\sum_{s}|s| \ge |F|\,n$. The two statements
are logically independent — Theorem B neither assumes nor proves union closure;
it trades the structural hypothesis of Frankl's conjecture for an averaged
density hypothesis, and the proof is elementary double counting. We make no claim
about Frankl's conjecture itself, which remains open; we record the connection
only to situate the order-parameter result within its natural combinatorial
landscape, where ``a popular element exists'' is the recurring theme. Recent
entropy-based progress on Frankl's conjecture (establishing a positive constant
fraction) underscores that the bridge between counting, density, and the
existence of a heavy coordinate is exactly the locus of current interest.

---

## 9. Discussion: the combinatorial skeleton of emergence

The five results assemble into the standard toolkit of emergence arguments:

| Physics ingredient | Combinatorial theorem |
|---|---|
| Conservation of extensive charge | Theorem A (double counting) |
| Order parameter past a threshold | Theorem B (majority from average) |
| Naturalness of monotone constraints | Bridge: upset ⇒ union-closed |
| Second law under coarse-graining | Theorem C (occupancy monotone) |
| FKG positive correlation | Theorem D (powerset base case) |
| Two-point/one-point bookkeeping | Inclusion–exclusion identity |

Programs that seek to derive macroscopic geometry from microscopic complexity —
for instance, the proposal that spacetime curvature condenses out of the
entanglement structure of a random tensor network past a critical bond dimension —
rely on exactly this logical scaffolding: a monotone resource obeying conservation
and inequality constraints, an order parameter switching on at a threshold, and
positive correlations that glue local cuts into a coherent bulk. The union-closed
family is a minimal, fully rigorous laboratory in which each of these moves is an
exact theorem rather than an asymptotic hope. The take-away is structural: *the
logical skeleton of emergence is combinatorial*, and any discrete model that
aspires to reproduce smooth physics must first satisfy these humble, exact
identities.

We emphasize what is **not** claimed: we do not assert that finite set systems are
spacetime, nor that any specific quantum-gravity threshold follows from these
lemmas. The contribution is to make the *form* of the emergence argument
mathematically airtight in a setting simple enough to verify completely.

---

## 9.5. Robustness and the role of each hypothesis

A virtue of working at this level of abstraction is that one can see precisely
which hypotheses are load-bearing. Theorem A requires only that $\alpha$ be
finite; it holds for *arbitrary* families and does not use union closure at all,
because it is a pure statement about the incidence relation between sites and
configurations. This is why it can serve as the engine for downstream results:
it is a conservation law with no structural prerequisites.

Theorem B inherits the finiteness of $\alpha$ and additionally needs $\alpha$
nonempty (so that the index set of the summed strict inequalities is nonempty)
and $F$ nonempty (so that ``mean size'' is meaningful and the conclusion
$2\,\mathrm{memberCount}(a,F) \ge |F|$ is non-vacuous). The density hypothesis is
sharp in the sense that lowering the threshold below $n/2$ would no longer force a
site above half-occupancy: the uniform-spread configuration in which every site
sits at exactly occupancy just under one half saturates the bound. The order
parameter appears precisely at the symmetric point, the hallmark of a critical
threshold.

The bridge theorem uses neither finiteness nor a measure — it is a purely
order-theoretic implication, valid for any family in any Boolean lattice. This is
what makes union closure the ``right'' algebraic shadow of monotonicity: it is
implied by the weakest reasonable structural assumption (upward closure) and is
preserved by the natural dynamics (Propositions 7.1–7.2).

Theorem C needs finiteness (to define $\langle F\rangle$ inside the powerset) and
nothing else; its proof is monotonicity of summation over the inclusion
$F \subseteq \langle F\rangle$, so the only arithmetic fact used is
non-negativity of cardinality. Theorem D is the most computational: it relies on
the exact superset-counting identity $\#\{T : S \subseteq T\} = 2^{\,n-|S|}$, which
is itself a clean bijection argument. The fact that the FKG inequality degenerates
to equality on the full powerset is not a weakness but a feature: it pins the
boundary of the inequality at the maximally disordered state, exactly where
independence should hold, so any nontrivial positive correlation must come from
structure imposed *beyond* the powerset.

---

## 10. Future directions

A natural program is to upgrade the equality in Theorem D to a *strict* positive
correlation theorem on restricted families (upward-closed ensembles), making the
full FKG inequality the central object; to quantify the rate of occupancy increase
in Theorem C as a discrete entropy-production functional; and to relate the order
parameter of Theorem B to thresholds in random ensembles. The physics-facing
extensions — entanglement-cut submodularity as the order parameter of a geometric
phase, the separation of curvature saturation from bulk reconstructibility, and
the logarithmic sharpness of a critical bond dimension — are discussed in the
package's Future Directions.

---

## Appendix: Summary of formalized statements

- `sum_memberCount_eq_sum_card`: $\sum_a \mathrm{memberCount}(a,F) = \sum_{s\in F}|s|$.
- `exists_frequent_element_of_avg_card_ge_half`: $2\sum|s| \ge |F|\,n \Rightarrow \exists a,\ 2\,\mathrm{memberCount}(a,F)\ge|F|$.
- `upset_unionClosed`: upper set $\Rightarrow$ union-closed.
- `unionCount_eq`: $\mathrm{unionCount} = \mathrm{memberCount}_a + \mathrm{memberCount}_b - \mathrm{jointCount}$ (in $\mathbb Z$).
- `subset_unionClosure`, `unionClosure_unionClosed`: $\langle\cdot\rangle$ is an extensive closure into the union-closed sets.
- `sum_card_monotone_under_unionClosure`: $\sum_{F}|s| \le \sum_{\langle F\rangle}|s|$.
- `powerset_nonneg_correlation`: $2^n\,\mathrm{jointCount} \ge \mathrm{memberCount}_a\,\mathrm{memberCount}_b$ on $\mathcal P(\alpha)$.
