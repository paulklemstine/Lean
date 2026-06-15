# Single-Peaked Preferences are Flat: Black's Theorem as Vanishing Condorcet Curvature

## Abstract

We develop a geometric reformulation of two pillars of social choice theory —
Arrow's impossibility theorem and Black's median-voter theorem — in which the
majority relation of a preference profile is treated as a discrete connection on
the space of alternatives, and Condorcet cycles play the role of curvature
(holonomy). Within this framework we define the **Condorcet curvature** of a
preference profile as the number of directed majority 3-cycles it contains, a
nonnegative integer that vanishes precisely when majority rule is acyclic. Our
main theorem is a geometric form of Black's 1948 theorem: *the single-peaked
preference domain is flat*, i.e. every single-peaked profile has Condorcet
curvature zero. This strengthens the classical observation that a unanimous
(single-point) profile is flat from a point to an entire submanifold of disagreeing
profiles. The proof proceeds through Amartya Sen's value-restriction condition and
a single transfer-of-decisiveness lemma, which we identify as the discrete analogue
of parallel transport with trivial holonomy. We show that acyclicity requires no
parity hypothesis on the electorate; oddness enters only when one wishes to upgrade
acyclicity to a strict linear social order via a tie-broken tournament. All results
have been formally verified in the Lean 4 proof assistant. We close with a program
of falsifiable conjectures connecting voting rules to Riemannian invariants on the
probability simplex.

**Keywords:** social choice, Black's theorem, single-peaked preferences, Condorcet
paradox, value restriction, discrete curvature, holonomy, Arrow's theorem.

---

## 1. Introduction

The Condorcet paradox shows that pairwise majority rule applied to three voters
with rankings `a≻b≻c`, `b≻c≻a`, `c≻a≻b` yields a cyclic social relation:
`a` beats `b`, `b` beats `c`, and `c` beats `a` by majority. Arrow's impossibility
theorem (1951) elevates this local pathology to a structural impossibility: no
social welfare function on three or more alternatives can simultaneously satisfy
unrestricted domain, the Pareto principle, independence of irrelevant alternatives
(IIA), and non-dictatorship.

Black's theorem (1948) is the canonical *positive* counterweight. If preferences
are **single-peaked** along a common axis, majority rule is well-behaved: the
social relation is transitive and the median voter's peak is a Condorcet winner.
The aim of this paper is to give both theorems a common geometric home.

### 1.1 The curvature dictionary

We treat the majority relation as a discrete connection on the set of alternatives.
Walking a closed loop `a → b → c → a` through the alternatives and asking whether
the majority verdicts are consistent is the discrete analogue of parallel-transporting
a vector around a loop on a manifold. A *consistent* (acyclic) verdict corresponds
to **trivial holonomy** (flatness); a *cyclic* verdict corresponds to nontrivial
holonomy (**curvature**). We make this precise by defining the Condorcet curvature
as the cycle count, and we obtain the dictionary:

| Social choice                          | Differential geometry              |
|----------------------------------------|------------------------------------|
| Majority relation                      | Discrete connection                |
| Condorcet 3-cycle                      | Holonomy around a loop             |
| Condorcet curvature (cycle count)      | Curvature scalar                   |
| Acyclic / transitive majority          | Flatness                           |
| Unanimous profile                      | Single point (trivially flat)      |
| Single-peaked domain                   | Flat submanifold                   |
| Sen value restriction                  | Local flatness condition           |
| Transfer of decisiveness               | Parallel transport, no holonomy    |

### 1.2 Contributions

1. A geometric statement and full formal proof of Black's theorem as **vanishing
   Condorcet curvature** on the single-peaked submanifold (Theorem 5.3), upgrading
   the single-point flatness result to a positive-dimensional submanifold.
2. Isolation of Sen value restriction as a *local flatness* lemma derivable
   directly from single-peakedness (Lemma 4.1).
3. A single transfer-of-decisiveness lemma, `cross_beats` (Lemma 4.2), shown to
   carry the entire proof and identified as discrete parallel transport.
4. The observation that **acyclicity is parity-free**: no oddness of the electorate
   is required for flatness (Remark 5.4); oddness enters only for the strict-order
   refinement.

---

## 2. Preliminaries and definitions

Throughout, alternatives are indexed by `Fin n` (the integers `0, 1, …, n-1`),
whose natural linear order `<` serves as the fixed **axis**. Voters are indexed by
`Fin k`.

**Definition 2.1 (Strict ranking).** A *strict ranking* on `n` alternatives is a
permutation `ranking : Perm (Fin n)`, where `ranking a` is the position (rank) of
alternative `a`; smaller rank means more preferred. Voter `r` *prefers* `a` to `b`,
written `r.prefers a b`, iff `(ranking a : ℕ) < (ranking b : ℕ)`.

Because ranks are images of a permutation, `prefers` is irreflexive, asymmetric,
transitive, and total on distinct alternatives:

- `prefers_asymm`: `r.prefers a b → ¬ r.prefers b a`.
- `prefers_trans`: `r.prefers a b → r.prefers b c → r.prefers a c`.
- `prefers_total`: `a ≠ b → r.prefers a b ∨ r.prefers b a`.

**Definition 2.2 (Preference profile).** A *preference profile* is a function
`P : Fin k → StrictRanking n` assigning a strict ranking to each voter.

**Definition 2.3 (Support count and majority).** For alternatives `a, b`:

- The *support count* is `supportCount P a b = #{ i : (P i).prefers a b }`.
- `a` *beats* `b` by majority, `P.majorityBeats a b`, iff
  `supportCount P a b > supportCount P b a`.

The support counts partition the electorate on each distinct pair:

**Lemma 2.4 (Support partition).** For `a ≠ b`,
`supportCount P a b + supportCount P b a = k`.

*Proof.* The voters preferring `a` to `b` and those preferring `b` to `a` are
disjoint (asymmetry) and, by totality on distinct alternatives, cover all `k`
voters. ∎

**Definition 2.5 (Tournament).** A *tournament* on `Fin n` is a relation `beats`
that is irreflexive, complete (for `a ≠ b`, `beats a b` or `beats b a`), and
asymmetric. A tournament is *transitive* if `beats a b → beats b c → beats a c`,
and has a *3-cycle* if there exist `a, b, c` with `beats a b ∧ beats b c ∧ beats c a`.

When `k` is odd and `n > 1`, `majorityBeats` is complete (no ties), so it defines
the *majority tournament* `majorityTournament P`.

**Definition 2.6 (Condorcet curvature).** The *Condorcet curvature* of a profile is
the number of directed majority 3-cycles:
```
CondorcetCurvature P =
  #{ (a,b,c) : supportCount P a b > supportCount P b a
             ∧ supportCount P b c > supportCount P c b
             ∧ supportCount P c a > supportCount P a c }.
```

---

## 3. Foundational facts: curvature is holonomy

We record the structural facts (established in the foundational layer of this
project) that justify reading the cycle count as curvature.

**Proposition 3.1 (Flatness ⇔ trivial holonomy).** A tournament is transitive iff
it has no 3-cycle:
`T.IsTransitive ↔ ¬ T.Has3Cycle`.

*Proof sketch.* (⇒) A 3-cycle `beats a b, beats b c, beats c a` together with
transitivity gives `beats a c`, contradicting asymmetry with `beats c a`. (⇐) If
not transitive, there exist `a, b, c` with `beats a b`, `beats b c`, but not
`beats a c`; completeness gives `beats c a`, producing a 3-cycle. ∎

**Proposition 3.2 (Curvature detects cycles).**
`CondorcetCurvature P = 0` iff there is **no** triple `a, b, c` with
`P.majorityBeats a b ∧ P.majorityBeats b c ∧ P.majorityBeats c a`. Consequently,
`0 < CondorcetCurvature P` iff a majority cycle exists.

*Proof sketch.* The curvature is the cardinality of the finset of cyclic triples;
a finset has cardinality zero iff it is empty. ∎

**Proposition 3.3 (Flatness enables consensus).** If `k` is odd, `n > 1`, and
`CondorcetCurvature P = 0`, then `majorityTournament P` is transitive.

*Proof sketch.* Combine Proposition 3.2 (no majority cycle) with Proposition 3.1
(no 3-cycle ⇒ transitive). ∎

**Proposition 3.4 (The single point is flat).** If `P` is unanimous (all voters
share the same strict ranking), then `CondorcetCurvature P = 0`.

*Proof sketch.* Under unanimity, `supportCount P a b ∈ {0, k}`. A majority cycle
would require all voters to simultaneously rank `a≻b`, `b≻c`, `c≻a`, contradicting
transitivity of the common ranking. ∎

Proposition 3.4 is the geometric baseline: total agreement is a single flat point.
The remainder of the paper flattens an entire submanifold around it.

---

## 4. Local flatness: value restriction and decisiveness transfer

We fix the axis order on `Fin n` and study single-peaked rankings.

**Definition 4.0 (Single-peaked ranking).** A strict ranking `r` is
*single-peaked at* peak `p`, written `r.IsSinglePeakedAt p`, if:

1. **Peak is top:** for all `a ≠ p`, `r.prefers p a`.
2. **Left-monotone:** for all `a, b`, if `a < b ≤ p` then `r.prefers b a`.
3. **Right-monotone:** for all `a, b`, if `p ≤ a < b` then `r.prefers a b`.

A profile `P` is *single-peaked*, `P.IsSinglePeaked`, if each voter `P i` is
single-peaked at some peak `p_i`.

### 4.1 Value restriction

**Lemma 4.1 (Single-peaked ⇒ middle is never worst).** Let `r` be single-peaked at
`p`, and let `a < b < c` in axis order. Then `r.prefers b a` or `r.prefers b c`;
that is, the axis-middle alternative `b` is never ranked last among `{a, b, c}`.

*Proof.* Consider where the peak lies relative to `b`.

- If `p < b`, then `p < b < c`, so by right-monotonicity (clause 3 with the pair
  `b < c` and `p ≤ b`) we get `r.prefers b c`.
- If `b ≤ p`, then `a < b ≤ p`, so by left-monotonicity (clause 2 with the pair
  `a < b` and `b ≤ p`) we get `r.prefers b a`.

In either case `b` beats one of its flanks, hence is not last. ∎

This is exactly Sen's value-restriction condition specialized to single-peakedness:
on every axis-sorted triple, the middle is *not-worst* for every voter. In the
curvature dictionary, Lemma 4.1 is the **local flatness condition** — it forbids,
voter by voter, the only ranking pattern that can generate twisting.

### 4.2 Transfer of decisiveness

**Lemma 4.2 (`cross_beats` — decisiveness crosses a never-worst middle).** Let
`m, L, R` be alternatives with `L ≠ m` and `L ≠ R`. Suppose:

- (value restriction at `m`) for every voter `i`, `(P i).prefers m L` or
  `(P i).prefers m R`; and
- `P.majorityBeats L m`.

Then `P.majorityBeats L R`.

*Proof.* We show the inclusion of voter sets
`{ i : (P i).prefers L m } ⊆ { i : (P i).prefers L R }`.
Take a voter `i` with `(P i).prefers L m`. By the value-restriction hypothesis,
`(P i).prefers m L` or `(P i).prefers m R`. The first is impossible by asymmetry
(it contradicts `(P i).prefers L m`), so `(P i).prefers m R`. Transitivity then
gives `(P i).prefers L R`. Hence the inclusion holds, and by monotonicity of `card`,
`supportCount P L m ≤ supportCount P L R`.

Now use the support partition (Lemma 2.4) twice. From `P.majorityBeats L m` we have
`supportCount P L m > supportCount P m L`, equivalently `2·supportCount P L m > k`.
Since `supportCount P L R ≥ supportCount P L m`, also `2·supportCount P L R > k`,
i.e. `supportCount P L R > supportCount P R L`, which is `P.majorityBeats L R`. ∎

Lemma 4.2 is the engine of the whole theory. Geometrically it is **parallel
transport with trivial holonomy**: the verdict "`L` is decisive" is carried *across*
the protected middle `m` and arrives, unchanged, as "`L` is decisive over `R`." The
classical four-class census of the six linear orders on a triple is replaced by a
single `Finset.card_le_card` (set inclusion) — the algebraic shadow of flatness.

---

## 5. Global flatness: Black's theorem

### 5.1 No cycle on a sorted triple

**Lemma 5.1 (`median_no_cycle`).** Let `P` be single-peaked and `a < b < c` in axis
order. Then **neither** cyclic orientation occurs:
```
¬ (P.majorityBeats a b ∧ P.majorityBeats b c ∧ P.majorityBeats c a)   and
¬ (P.majorityBeats a c ∧ P.majorityBeats c b ∧ P.majorityBeats b a).
```

*Proof.* By Lemma 4.1, the middle `b` is never worst, so every voter prefers `b` to
`a` or `b` to `c`; equivalently the value-restriction hypothesis of Lemma 4.2 holds
with `m = b`.

- *First orientation.* Suppose `P.majorityBeats a b`, `P.majorityBeats b c`,
  `P.majorityBeats c a`. Apply `cross_beats` with `m = b`, `L = a`, `R = c`: from
  `P.majorityBeats a b` (the flank `a` beats the middle) we obtain
  `P.majorityBeats a c`. But `P.majorityBeats c a` says
  `supportCount c a > supportCount a c`, while `P.majorityBeats a c` says the
  reverse — contradiction.
- *Second orientation.* Suppose `P.majorityBeats a c`, `P.majorityBeats c b`,
  `P.majorityBeats b a`. Apply `cross_beats` with `m = b`, `L = c`, `R = a`: from
  `P.majorityBeats c b` we obtain `P.majorityBeats c a`, contradicting
  `P.majorityBeats a c`.

Hence no cyclic orientation of the sorted triple can occur. ∎

### 5.2 No Condorcet cycle anywhere

**Theorem 5.2 (`single_peaked_no_majority_cycle`).** If `P` is single-peaked, there
is no majority cycle: there exist no `a, b, c` with
`P.majorityBeats a b ∧ P.majorityBeats b c ∧ P.majorityBeats c a`.

*Proof sketch.* A majority cycle forces `a, b, c` to be pairwise distinct (a cycle
through a repeated alternative would contradict irreflexivity/asymmetry). Sort the
three distinct alternatives by their axis positions into `x < y < z`. A 3-cycle on
`{a,b,c}` is, up to rotation, one of the two cyclic orientations of `x < y < z`,
both of which are excluded by Lemma 5.1. ∎

### 5.3 Black's theorem, geometric and classical forms

**Theorem 5.3 (`single_peaked_curvature_zero` — Black's theorem, geometric form).**
If `P` is single-peaked, then `CondorcetCurvature P = 0`. *The single-peaked domain
is flat.*

*Proof.* By Proposition 3.2, `CondorcetCurvature P = 0` is equivalent to the
absence of a majority cycle, which is Theorem 5.2. ∎

**Theorem 5.3′ (`single_peaked_majority_transitive` — Black's theorem, classical
form).** If `P` is single-peaked, `k` is odd, and `n > 1`, then the majority
tournament `majorityTournament P` is transitive — majority rule yields a coherent
social ordering.

*Proof.* Theorem 5.3 gives zero curvature; Proposition 3.3 converts zero curvature
into transitivity of the (well-defined, tie-free) majority tournament. ∎

**Remark 5.4 (Acyclicity is parity-free).** Theorems 5.2 and 5.3 make **no** use of
oddness of `k`. Flatness — the geometric statement — holds for every electorate
size. Oddness is invoked only in Theorem 5.3′, and solely to guarantee that
`majorityBeats` is complete (no ties), so that the tie-broken `majorityTournament`
is defined and acyclicity can be promoted to a strict transitive order. This cleanly
separates the *geometric* content (flatness, parity-free) from the *order-theoretic*
packaging (a strict social order, parity-sensitive).

---

## 6. Algorithms

The theory is fully computational on finite profiles. We summarize the key
procedures (full Python in the accompanying demo).

**Algorithm A — Condorcet curvature.** Given a profile as a `k × n` rank matrix,
compute `supportCount(a,b)` for all ordered pairs, then count triples `(a,b,c)`
forming a directed majority cycle. Complexity: `O(k·n² + n³)`.

**Algorithm B — Single-peakedness test.** For each voter, test whether some axis
position `p` makes the ranking single-peaked (peak-top, left-monotone,
right-monotone). Complexity: `O(k·n²)` (each candidate peak checked in `O(n)`, or
directly recover the peak as the top-ranked alternative and verify monotonicity).

**Algorithm C — Median-voter winner.** On a single-peaked profile with odd `k`,
collect the voters' peaks, take their axis-median `m*`, and (by the now-transitive
tournament) return `m*` as the Condorcet winner; verify by checking
`P.majorityBeats m* b` for all `b ≠ m*`. Complexity: `O(k·n + k log k)`.

---

## 7. Worked example

Three voters, three alternatives on axis `0 < 1 < 2`.

*Cyclic (not single-peaked).* Voter rankings (most to least preferred):
`(0,1,2)`, `(1,2,0)`, `(2,0,1)`. Majority: `0≻1`, `1≻2`, `2≻0`.
`CondorcetCurvature = 1` (one directed 3-cycle): the space is **curved**, no winner.
Voter 3's ranking `2≻0≻1` ranks the axis-middle `1` last — value restriction is
violated, the local flatness condition fails.

*Single-peaked.* Peaks at `0, 1, 2` respectively, each voter single-peaked:
`(0,1,2)`, `(1,0,2)` or `(1,2,0)`, `(2,1,0)`. Every voter ranks the middle `1`
above at least one flank — value restriction holds. Majority is transitive,
`CondorcetCurvature = 0`, and the median peak `1` is the Condorcet winner. The space
is **flat**.

---

## 8. Discussion and related work

The result sits at the confluence of three classical strands: Arrow's impossibility
(curved bulk), Black's median-voter theorem (flat submanifold), and Sen's value
restriction (the local obstruction). The novelty is not the mathematical content of
Black's theorem — well over seventy years old — but the *organizing geometric
principle* that makes Arrow and Black two faces of a single curvature phenomenon,
and the reduction of the proof to one inclusion of voter sets (Lemma 4.2).

The curvature dictionary is more than aesthetic. It predicts where positive results
should be available: on any value-restricted domain (single-peaked, single-caved,
single-crossing, or more generally Sen-restricted), the local flatness condition
holds and the same transfer argument should flatten the global curvature. It also
clarifies the role of parity, which is often conflated with acyclicity in textbook
treatments: parity is a tie-breaking convenience, not a source of flatness.

---

## 9. Future directions

The following program (carried from the project's research notes) is deliberately
falsifiable and builds on the now-proven flatness theorems.

**9.1 Median-voter Condorcet winner as the center of the flat submanifold.** Having
proven zero curvature, exhibit the winner: for odd `k`, the axis-median of the
voters' peaks, `m*`, is a Condorcet winner — for every `b ≠ m*`,
`P.majorityBeats m* b` — and is the unique source of the transitive tournament. The
key lever is that `cross_beats` transfers decisiveness *outward* from a never-worst
middle; iterating from the median peak should push decisiveness to the axis boundary,
pinning the winner at the median, with flatness preventing the iteration from looping.

**9.2 Full Arrow's impossibility via decisive ultrafilters.** Close the loop on the
negative side by proving that decisive coalitions under Pareto + IIA on `n ≥ 3`
alternatives form an ultrafilter (for every coalition `S`, either `S` or its
complement is decisive); on finite electorates ultrafilters are principal, giving a
dictator. The hard step is the field-expansion lemma (decisiveness for one pair
implies decisiveness for all), most tractable first in the 3-alternative case.

**9.3 Quantitative Arrow: curvature bounds on near-dictatorships.** Using a metric
structure (Hellinger distance / Bhattacharyya coefficient) on distributions, bound
how close to dictatorial an `ε`-approximately-IIA rule must be, in the spirit of the
Friedgut–Kalai–Naor quantitative Arrow theorem, with a Fisher–Rao spherical-geometry
proof.

**9.4 Single-peaked preferences and zero curvature, Riemannian form.** Model
single-peakedness as voter utility vectors lying in a geodesic arc of the probability
simplex; on this 1-dimensional flat submanifold the Bhattacharyya midpoint relation
holds with equality (no contraction), reflecting zero intrinsic curvature of a great
circle.

**9.5 Gibbard–Satterthwaite via spherical fixed points.** Recast strategy-proofness
as the aggregation map being a retraction `F∘F = F` and use Brouwer/Borsuk–Ulam on
the sphere to force projection onto a single coordinate (dictatorship).

**9.6 Information-geometric characterization of voting rules.** Identify Borda count
with the Fréchet mean (minimizing total squared Hellinger distance) and Condorcet
methods with the metric median, exploiting the sqrt-embedding `H² = ½‖√p − √q‖²` to
reduce the Borda mean to Euclidean averaging on the sphere.

---

## 10. Conclusion

We have shown that single-peaked preference domains are *flat*: their Condorcet
curvature, the number of majority 3-cycles, is identically zero. The proof reduces
to one local condition (the axis-middle is never worst — Sen value restriction) and
one transfer lemma (decisiveness crosses the never-worst middle — discrete parallel
transport). This places Black's positive theorem and Arrow's impossibility on a
single geometric footing: Arrow describes the curved generic opinion-space, Black
the flat single-peaked slice through it. The geometric viewpoint isolates exactly
which structural feature buys acyclicity, shows that acyclicity is parity-free, and
suggests a broad research program connecting voting rules to Riemannian invariants.
