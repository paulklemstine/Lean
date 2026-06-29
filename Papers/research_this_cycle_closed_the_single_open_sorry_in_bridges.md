# Arrow's Theorem as Curvature of Preference Space

## A Discrete-Geometric Formalization of Condorcet Cycles, Majority Holonomy, and the Cohomological Obstruction to Social Welfare

---

### Abstract

We develop and fully formalize a discrete-geometric theory of preference
aggregation in which the Condorcet paradox of majority voting is identified with
**curvature**, and a coherent collective preference order corresponds to
**flatness**. For a profile of *k* strict rankings over *n* alternatives we define
the *Condorcet curvature* as the number of directed 3-cycles in the strict-majority
tournament. We prove the fundamental equivalence that a tournament is transitive
**iff** it is acyclic (3-cycle-free) — a discrete Ambrose–Singer principle linking
holonomy (cycles) to curvature (non-transitivity) — and specialize it to profiles:
Condorcet curvature vanishes **iff** the majority relation has no cycle **iff** the
majority tournament is transitive. We prove that unanimity forces zero curvature
(the flat limit), that the classical Condorcet paradox realizes strictly positive
curvature, and — the central structural discovery — that the hypothesis "every
profile has positive curvature" is **unsatisfiable**, because a unanimous (flat)
profile is always reachable. Consequently the naive "Arrow–curvature conjecture"
(positive curvature everywhere ⟹ dictatorship) is *vacuously* true; the genuine
content is the obstruction theorem. We give the cohomological reading: a tournament
is transitive **iff** its `beats` relation is the strict order of an integer
potential (the Copeland score), so a 3-cycle is exactly the obstruction to writing
the majority margin as a coboundary. We also formalize the Kendall tau metric on
rankings (symmetry, self-distance zero) as the discrete geodesic distance on the
preference manifold. All results are machine-checked. We close with a research
program: domain-relative curvature, quantitative (margin-weighted) curvature
bounds, Black's single-peaked flatness theorem, and the enumeration/probability of
flat profiles.

**Keywords:** social choice, Arrow's theorem, Condorcet paradox, tournaments,
discrete curvature, holonomy, cohomology, Copeland score, Kendall distance,
single-peaked preferences, formal verification.

---

## 1. Introduction

Arrow's impossibility theorem (1951) states that no social welfare function over
three or more alternatives can simultaneously satisfy unrestricted domain, Pareto
efficiency, independence of irrelevant alternatives (IIA), and non-dictatorship.
Its engine is the **Condorcet paradox** (1785): majority rule applied pairwise can
produce a cyclic collective preference (A beats B beats C beats A) even when every
individual preference is a strict total order.

This paper takes seriously a geometric reading of that phenomenon. In differential
geometry, **curvature** measures the failure of parallel transport to be trivial:
on a curved surface, transporting a vector around a closed loop returns it rotated
(**holonomy**), whereas on a flat space round trips change nothing. We argue — and
prove — that the Condorcet cycle is *exactly* a holonomy phenomenon: traversing the
loop A → B → C → A by majority rule "twists" the collective preference, and the
discrete curvature that produces this twist is the **count of majority 3-cycles**.

Our contributions are:

1. A precise definitional dictionary (Section 3): rankings, profiles, majority
   margin/tournament, and **Condorcet curvature** as 3-cycle count.
2. A discrete Ambrose–Singer theorem (Section 4): transitivity ⟺ acyclicity,
   hence flatness ⟺ existence of a coherent social order.
3. The two-sided nature of curvature (Section 5): unanimity ⟹ flat; the Condorcet
   paradox ⟹ curved.
4. The **central structural result** (Section 6): "positive curvature everywhere"
   is unsatisfiable, so the global Arrow–curvature premise is vacuous; the honest
   content is the obstruction theorem. Curvature is a property of *reachable*
   configurations, not of the axioms.
5. The **cohomological reading** (Section 7): transitivity ⟺ existence of an
   integer potential (Copeland score); a 3-cycle is the coboundary obstruction.
6. The **Kendall metric** (Section 8) as discrete geodesic distance.
7. A structured research program (Section 11).

Everything below is formalized and machine-verified; we present full mathematical
statements with proof sketches rather than proof scripts.

---

## 2. Related context

The link between Arrow's theorem and tournament theory is classical: McGarvey's
theorem shows every tournament is the majority tournament of some profile, and the
"probability of a Condorcet cycle" is a well-studied quantity. Single-peaked
domains (Black 1948) are the canonical Arrow escape route. Topological approaches
to social choice (Chichilnisky; Baryshnikov's homological proof of Arrow) connect
aggregation to algebraic topology at the level of preference *spaces* rather than
finite tournaments. Our framework is deliberately *finite and constructive*: we
recast the obstruction as an integer (the 3-cycle count) and as a coboundary
condition over a finite alternative set, which makes every statement decidable and
amenable to exhaustive verification.

---

## 3. Definitions

Throughout, alternatives are indexed by `Fin n` and voters by `Fin k`.

**Definition 3.1 (Strict ranking).** A *strict ranking* of *n* alternatives is a
permutation `ranking ∈ Sym(Fin n)`; `ranking a` is the position of alternative *a*
(lower = more preferred). Voter prefers *a* to *b*, written `prefers a b`, iff
`ranking a < ranking b`. This relation is irreflexive, asymmetric, transitive, and
total (any two distinct alternatives are comparable). All four properties are
proved.

**Definition 3.2 (Preference profile).** A *preference profile* is a map
`P : Fin k → StrictRanking n`, i.e. *k* voters each with a strict ranking.

**Definition 3.3 (Support count and majority margin).** For alternatives *a, b*,
$$\mathrm{supportCount}(a,b) = \#\{\, i : P_i \text{ prefers } a \text{ to } b \,\},\qquad
\mathrm{margin}(a,b) = \mathrm{supportCount}(a,b) - \mathrm{supportCount}(b,a) \in \mathbb{Z}.$$
We say *a* **beats** *b* by majority, `majorityBeats a b`, iff
`supportCount(a,b) > supportCount(b,a)`.

**Definition 3.4 (Tournament).** A *tournament* on `Fin n` is a relation `beats`
that is decidable, irreflexive (`¬ beats a a`), complete (`a ≠ b ⟹ beats a b ∨
beats b a`), and asymmetric (`beats a b ⟹ ¬ beats b a`). It is *transitive* if
`beats a b ∧ beats b c ⟹ beats a c`, and has a *3-cycle* if
`∃ a b c, beats a b ∧ beats b c ∧ beats c a`.

**Definition 3.5 (Majority tournament).** When *k* is odd and `1 < n`, the majority
relation `majorityBeats` is a tournament `majorityTournament P`. Oddness rules out
ties, giving completeness; irreflexivity and asymmetry are immediate from the
counts. (We prove `supportCount(a,b) + supportCount(b,a) = k` for `a ≠ b`, the
partition lemma underlying completeness.)

**Definition 3.6 (Condorcet curvature).** The *Condorcet curvature* of a profile
*P* is the number of directed majority 3-cycles:
$$\kappa(P) = \#\{\,(a,b,c) \in (\mathrm{Fin}\,n)^3 : a \text{ beats } b,\ b \text{ beats } c,\ c \text{ beats } a\,\}.$$
Equivalently, $\kappa(P)$ is the `cycleCount` of `majorityTournament P` when *k* is
odd. $\kappa(P) = 0$ is **flat**; $\kappa(P) > 0$ is **curved**.

**Definition 3.7 (Social welfare function and axioms).** A *social welfare function*
(SWF) is a map `F : PreferenceProfile n k → StrictRanking n`. It is:
- **Pareto** if `(∀ i, P_i prefers a b) ⟹ (F P) prefers a b`;
- **IIA** if the social order of *a* vs *b* depends only on individual orders of
  *a* vs *b*: whenever every voter ranks *a*,*b* the same way in *P* and *Q*, then
  `(F P) prefers a b ↔ (F Q) prefers a b`;
- **dictatorial** if some fixed voter *d* always gets their way:
  `∃ d, ∀ P a b, (P_d) prefers a b ⟹ (F P) prefers a b`.

**Definition 3.8 (Single-peaked).** A ranking is *single-peaked* with peak *p* on
the standard order of `Fin n` if *p* is top-ranked and, on each side of *p*,
closeness to *p* implies preference. A profile is single-peaked if every voter's
ranking is single-peaked (at some, possibly voter-dependent, peak).

**Definition 3.9 (Kendall tau distance).** For rankings $r_1, r_2$,
$$d_K(r_1, r_2) = \#\{\,(a,b) : r_1 \text{ prefers } a \text{ to } b \text{ and } r_2 \text{ prefers } b \text{ to } a\,\},$$
the number of pairwise disagreements — a discrete geodesic distance on the
preference manifold.

---

## 4. Flatness ⟺ Transitivity: a discrete Ambrose–Singer theorem

**Theorem 4.1 (Acyclicity ⟺ transitivity).** *For any tournament `T`,*
$$T \text{ is transitive} \iff T \text{ has no 3-cycle}.$$

*Proof sketch.* (⟹) If `T` is transitive and `beats a b, beats b c, beats c a`,
then `beats a c` by transitivity, contradicting asymmetry with `beats c a`. So no
3-cycle exists. (⟸) Suppose `T` has no 3-cycle and `beats a b, beats b c`. If
`¬ beats a c`, then by completeness `beats c a` (the three are distinct because
`beats` is irreflexive/asymmetric), producing the cycle `a → b → c → a`, a
contradiction. Hence `beats a c`, i.e. transitivity. ∎

Theorem 4.1 is the combinatorial heart of the paper: in a tournament, **all**
intransitivity is generated by 3-cycles. There are no "higher" obstructions —
exactly the discrete analogue of Ambrose–Singer, where holonomy is generated by
curvature on infinitesimal loops, here the smallest nontrivial loops being
triangles.

**Theorem 4.2 (Curvature zero ⟺ no majority cycle).** *For any profile `P`,*
$$\kappa(P) = 0 \iff \neg\,\exists\, a\,b\,c,\ \text{majorityBeats } a\,b \wedge \text{majorityBeats } b\,c \wedge \text{majorityBeats } c\,a.$$

*Proof sketch.* $\kappa(P)$ is the cardinality of the finite set of cyclic triples;
a cardinality is zero iff the set is empty, which is precisely the negation of the
existence of a majority 3-cycle. Decidability of `majorityBeats` makes this an
identity of decidable predicates. ∎

**Theorem 4.3 (Flatness enables consensus).** *If `k` is odd, `1 < n`, and
`κ(P) = 0`, then `majorityTournament P` is transitive.*

*Proof sketch.* Combine Theorem 4.2 (no majority cycle) with Theorem 4.1 applied to
`majorityTournament P` (acyclic ⟹ transitive). ∎

Theorem 4.3 is the constructive converse to Arrow within this framework: on a flat
profile, **majority rule itself** is a valid, transitive, manifestly
non-dictatorial aggregation. Impossibility is a curvature phenomenon, not a
universal verdict.

**Theorem 4.4 (Curvature obstruction principle).** *If `κ(P) > 0`, there exist
explicit `a, b, c` with `majorityBeats a b ∧ majorityBeats b c ∧ majorityBeats c
a`.*

*Proof sketch.* Contrapositive of Theorem 4.2: positivity of the count forces the
defining set nonempty, exhibiting a witnessing cyclic triple. ∎

**Cycle-count corollaries.** We also prove, at the tournament level:
`transitive_cycleCount_zero` (a transitive tournament has `cycleCount = 0`) and
`cycleCount_pos_of_has3cycle` (a 3-cycle witnesses `0 < cycleCount`). Together with
Theorem 4.1 these give the clean trichotomy *transitive ⟺ cycleCount 0 ⟺ no
3-cycle*.

---

## 5. Curvature is two-sided: unanimity is flat, paradox is curved

**Theorem 5.1 (Unanimity ⟹ flat).** *If `P` is unanimous (all voters share one
ranking), then `κ(P) = 0`.*

*Proof sketch.* In a unanimous profile, `supportCount(a,b) ∈ {0, k}` for every pair
(lemma `unanimous_support_extreme`: either no one prefers *a* to *b*, or everyone
does). Hence `majorityBeats` coincides with the common ranking's `prefers`, which is
transitive; by Theorem 4.2 no majority cycle exists, so $\kappa(P)=0$. ∎

Geometrically: a single shared opinion is a single point, and a point has no
curvature. Unanimity is the perfectly flat limit of preference space.

**Theorem 5.2 (Existence of a flat profile).** *Every profile space (any `n, k`)
contains a unanimous, hence flat, profile.*

*Proof sketch.* Take the constant profile assigning every voter the identity
ranking; it is unanimous by construction, and flat by Theorem 5.1. ∎

**Theorem 5.3 (Existence of a curved profile — the Condorcet paradox).** *For
`n ≥ 3` and a suitable odd `k`, there is a profile `P` with `κ(P) > 0`.*

*Proof sketch.* The three-voter profile `A>B>C`, `B>C>A`, `C>A>B` yields
`majorityBeats A B`, `majorityBeats B C`, `majorityBeats C A` (each by a 2–1
margin), a 3-cycle; by Theorem 4.4's converse `κ(P) > 0`. (Our enumeration finds
$\kappa = 3$ for this profile, counting the three cyclic rotations of the same
triangle.) ∎

Theorems 5.1–5.3 establish that curvature is a genuine, non-degenerate invariant:
both flat and curved profiles exist. The interest is entirely in *which* profiles
are which, i.e. in the *quantifier*.

**Boundary geometry.** Two further proved facts pin down the "metric scale":
`majority_margin_bounded` (`|margin(a,b)| ≤ k`, bounded curvature) and
`pareto_margin` (if all voters prefer *a* to *b* then `margin(a,b) = k`, maximal
gradient). And `two_alternatives_always_flat` shows `κ(P) = 0` whenever `n = 2`:
cycles need three alternatives, just as curvature needs at least two dimensions.

---

## 6. The central result: "curved everywhere" is unsatisfiable

A tempting way to recover Arrow's impossibility theorem in curvature language is:

> **(Naive Arrow–curvature statement.)** For `n ≥ 3`, `k ≥ 2`, if `F` is Pareto and
> IIA and *every* profile has positive curvature (`∀ P, 0 < κ(P)`), then `F` is
> dictatorial.

**Theorem 6.1 (Unrestricted domain impossible).** *For all `n, k`, the hypothesis
`∀ P : PreferenceProfile n k, 0 < κ(P)` is false.*

*Proof sketch.* By Theorem 5.2 there is a unanimous profile `P₀`, and by Theorem
5.1 `κ(P₀) = 0`. The hypothesis applied to `P₀` would give `0 < 0`, a
contradiction. ∎

**Corollary 6.2 (The naive statement is vacuously true).** *The naive
Arrow–curvature statement holds, but only because its premise can never be
satisfied.*

*Proof sketch.* Instantiate the premise at the unanimous profile to derive `0 < 0`;
the conclusion (dictatoriality) follows ex falso. The implication is therefore
logically valid but devoid of content. ∎

We regard Theorem 6.1 / Corollary 6.2 as the paper's principal conceptual
contribution. The naive recovery of Arrow fails not because curvature is the wrong
invariant, but because **"positive curvature everywhere" is the wrong quantifier.**
The unanimous (flat) profile is *always reachable*; demanding curvature on all
profiles is self-contradictory. This mirrors the geometric fact that holonomy is
measured over loops that actually bound a region of the configuration space, not
over every conceivable loop. The correct Arrow-style statement must quantify
curvature over a **restricted admissible domain** `D ⊆ PreferenceProfile n k`, and
ask whether positive curvature throughout `D` forces dictatoriality of every
Pareto+IIA SWF defined on `D`. Theorem 6.1 is precisely the obstruction theorem
that makes the domain-relative reformulation the well-posed next target
(Section 11).

---

## 7. Cohomological reading: curvature as a coboundary obstruction

A conservative (curl-free) vector field is the gradient of a potential, and round
trips cost nothing. The discrete analogue characterizes flatness of tournaments.

**Theorem 7.1 (Transitivity ⟺ integer potential).** *A tournament `T` on `Fin n`
is transitive **iff** there is an integer potential `f : Fin n → ℤ` such that*
$$\text{beats } a\, b \iff f(a) > f(b) \quad \text{for all } a \ne b.$$

*Proof sketch.* (⟸) If `beats` is the strict order of `f`, transitivity of `>` on
ℤ transports to `beats`. (⟹) A transitive tournament is a strict total order on a
finite set; take `f` to be (a monotone reindexing of) the **Copeland score**
`f(a) = #{b : beats a b} − #{b : beats b a}`. For a transitive tournament the
Copeland score is injective and order-reversing-free, so `beats a b ⟺ f(a) > f(b)`.
∎

**Theorem 7.2 (Zero curvature yields a social potential).** *If `k` is odd,
`1 < n`, and `κ(P) = 0`, then there is `f : Fin n → ℤ` with
`majorityBeats a b ⟺ f(a) > f(b)`.* 

*Proof sketch.* By Theorem 4.3 the majority tournament is transitive; apply Theorem
7.1 to extract the Copeland potential of `majorityTournament P`. ∎

**Interpretation.** Treat the majority margin as a 1-cochain on the complete graph
of alternatives. Theorem 7.2 says: *zero curvature ⟹ the margin sign field is a
coboundary*, i.e. there is a node potential `f` whose differences reproduce the
order — society behaves as if maximizing one "social utility" `f`. Conversely a
3-cycle is exactly the obstruction to such a potential: around `a → b → c → a` the
strict inequalities `f(a) > f(b) > f(c) > f(a)` are unsatisfiable. **Condorcet
curvature is the discrete curl that no gradient can produce**, and Arrow's
impossibility — the non-existence of a single coherent social-welfare ordering — is
the statement that this cohomology class need not vanish. Exhaustive enumeration of
all 216 profiles with `n = k = 3` confirms the equivalence *`κ = 0` ⟺ transitive ⟺
the Copeland potential reproduces the majority order* with no exceptions.

---

## 8. The Kendall metric on preference space

**Theorem 8.1 (Symmetry).** `d_K(r₁, r₂) = d_K(r₂, r₁)`.

*Proof sketch.* The map `(a,b) ↦ (b,a)` is an involutive bijection from the
disagreement set of `(r₁,r₂)` onto that of `(r₂,r₁)` (since "`r₁` prefers `a` to `b`
and `r₂` prefers `b` to `a`" becomes "`r₂` prefers `b` to `a` and `r₁` prefers `a`
to `b`" under the swap), so the two cardinalities agree. ∎

**Theorem 8.2 (Identity of indiscernibles, base case).** `d_K(r, r) = 0`.

*Proof sketch.* The disagreement set of `(r,r)` is empty: `r` prefers `a` to `b`
and `b` to `a` simultaneously is impossible by asymmetry of `prefers`. ∎

These give the two metric axioms that depend only on the pair structure; together
with the (combinatorially standard) triangle inequality they make `d_K` a genuine
distance. We view `d_K` as the discrete geodesic distance on the preference
manifold, the natural scale against which "polarization" should be measured
(Section 11.3).

---

## 9. Algorithms

All invariants here are **decidable** and computed by finite enumeration over
`Fin n`, which makes exhaustive verification on small instances immediate.

**Algorithm A (Condorcet curvature).** Input: profile `P`, size `n`. For each
ordered triple `(a,b,c)`, test the three majority inequalities; count successes.
Complexity: $O(n^3 k)$ (each `majorityBeats` is an $O(k)$ scan), or $O(n^3)$ given
precomputed support counts. Output: $\kappa(P)$. By Theorems 4.2/4.4, the sign of
the output decides flatness vs. curvedness.

**Algorithm B (Copeland potential & flatness certificate).** Input: profile `P`,
size `n`. Compute Copeland scores `f(a)`; check `majorityBeats a b ⟺ f(a) > f(b)`
for all pairs. If the check passes, `f` is a flatness certificate (Theorem 7.2); if
it fails, the failing pair lies on a cycle. Complexity: $O(n^2 k)$.

**Algorithm C (Flat-profile enumeration / cycle probability).** Input: `n, k`.
Enumerate all $(n!)^k$ profiles; for each, compute $\kappa$; tally the fraction
with $\kappa = 0$. Complexity: $O((n!)^k \cdot n^3 k)$ — feasible for small `n, k`
and used to seed/falsify closed-form conjectures for the flat fraction.

---

## 10. Worked numerical results

Our companion program (`demo.py`) reproduces:

- **Condorcet paradox.** Profile `A>B>C`, `B>C>A`, `C>A>B`: each pairwise margin is
  `+1`, the majority relation cycles, $\kappa = 3$, majority is intransitive
  (Theorem 5.3).
- **Unanimity.** Five voters with the common order `A>B>C>D`: $\kappa = 0$, and the
  Copeland potential reproduces the majority order (Theorems 5.1, 7.2).
- **Unsatisfiability.** For `n = k = 3` the unanimous profile has $\kappa = 0$,
  witnessing Theorem 6.1.
- **Trichotomy.** Over all `216 = (3!)^3` profiles, `κ = 0 ⟺ transitive ⟺ Copeland
  potential reproduces majority order`, no exceptions; `204` flat (≈94.4%), `12`
  curved (≈5.6%).
- **Kendall metric.** `d_K(r,r) = 0`; reversal of a 4-ranking has `d_K = 6` (all
  `C(4,2)` pairs disagree); symmetry holds on samples.
- **Flat fractions.** `n=3`: `k=1 → 100%`, `k=3 → 94.4%`, `k=5 → 93.06%` flat — the
  curvature-language version of the classic "probability of a Condorcet cycle."

---

## 11. Discussion and future directions

The synthesis: this development closed the only open obstruction in the core file
and made the underlying phenomenon explicit. The slogan "Condorcet paradox =
curvature = holonomy = cohomology" is now a chain of theorems, not a metaphor, and
the key lesson is about quantifiers — curvature is a property of *reachable*
configurations, so impossibility must be stated domain-relatively. Concrete,
falsifiable next steps:

**11.1 Domain-relative impossibility.** Replace the unsatisfiable global premise by
quantification over an admissible domain `D ⊆ PreferenceProfile n k`: if every
profile in `D` has positive curvature, is every Pareto+IIA SWF on `D` dictatorial?
With the obstruction theorem (6.1) and the flat-profile witness (5.2) in hand, this
is now a well-posed incremental formalization rather than an open-ended search.

**11.2 Curvature as an exact cohomology class.** `κ(P) = cycleCount` of the
majority tournament invites the full cochain treatment: prove `κ(P) = 0` iff the
margin 1-cochain is a coboundary `margin(a,b) = f(a) − f(b)` (Theorem 7.2 is the
order-level version; the margin-level version is the natural strengthening), and
identify `κ` with the rank of an explicit discrete curl operator.

**11.3 Quantitative flatness.** Define a *weighted* curvature
$\sum_{\text{cycles}} \mathrm{margin}(a,b)\cdot \mathrm{margin}(b,c)\cdot
\mathrm{margin}(c,a)$ and bound it below by (number of strict 3-cycles) × (minimum
positive margin). Conjecture: polarization in the Kendall metric forces large
weighted curvature — a metric inequality linking disagreement to cyclicity, scaled
by the proved bounds `|margin| ≤ k`.

**11.4 Black's theorem, formalized.** Prove that a single-peaked profile with an
odd number of voters has transitive majority rule, hence `κ(P) = 0`. The
single-peaked machinery and the curvature-zero criterion (Theorem 4.3) are present;
only the median-voter extraction lemma is missing — a self-contained, high-value
target establishing single-peakedness as a discrete convexity that flattens the
manifold.

**11.5 Counting flat profiles.** Determine the number of flat profiles among the
$(n!)^k$ profiles and the limiting flat fraction as `k → ∞` for fixed `n` — the
classic Condorcet-cycle probability, recast in curvature language. Since `κ` is a
decidable `Finset.card`, exhaustive small-case computation (Algorithm C) can seed
and falsify candidate closed forms before a general proof is attempted.

---

## 12. Conclusion

We have given a complete, machine-checked, discrete-geometric account of majority
voting in which Condorcet cycles are curvature, transitive consensus is flatness,
and the existence of a coherent social-welfare ordering is the vanishing of a
cohomological obstruction with the Copeland score as potential. The decisive
structural insight is that curvature positivity cannot be a global axiom — the
unanimous profile is always flat and always reachable — so Arrow-style impossibility
is properly a *domain-relative* curvature statement. By rendering every invariant
decidable and every theorem formally verified, the framework turns a venerable
paradox into a computable, geometric, and rigorously certified object, and lays out
a precise program for the quantitative geometry of collective choice.
