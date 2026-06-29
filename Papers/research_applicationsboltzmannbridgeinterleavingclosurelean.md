# The Interleaving Distance of Sublevel Filtrations is the Sup-Distance of Weights

## Abstract

We study the interleaving distance between sublevel-set filtrations of monotone weight
functions on simplices — the standard combinatorial model underlying persistent homology
and its stability theory. The classical Cohen–Steiner–Edelsbrunner–Harer (CESH) stability
theorem provides a one-sided Lipschitz bound: a uniform `D`-perturbation of the weights
yields a `D`-interleaving, hence interleaving distance at most `D`. We prove the converse
quantitatively and thereby close the inequality into an exact identity. The central lemma
states that two filtrations are `δ`-interleaved if and only if `δ ≥ 0` and their weight
functions are uniformly within `δ` in sup-norm. Consequently the extended `[0, ∞]`-valued
interleaving distance equals the extended sup-distance of the weight functions,

> `eInterleavingDist(F, G) = sup over σ of ENNReal.ofReal | w_F(σ) − w_G(σ) |`,

with the defining infimum *attained* at the realized worst-case gap. This exhibits the
space of filtrations under the interleaving distance as isometric to a subspace of the
sup-normed space of weight functions: persistence is an isometry, not merely a `1`-Lipschitz
contraction. As an immediate corollary the interleaving distance separates points
(`distance = 0 ⟺ equality`), recovering the `T0` / metric-separation result of the
preceding development directly from the closed form. All results are fully formalized and
machine-checked, with axiom dependence limited to `propext`, `Classical.choice`, and
`Quot.sound`.

**Keywords:** persistent homology, topological data analysis, interleaving distance,
stability theorem, isometry, sublevel filtration, Vietoris–Rips complex, extended metric
space.

---

## 1. Introduction

Persistent homology turns a finite data set into a one-parameter nested family of
simplicial complexes — a *filtration* — and reads the data's shape off the topological
features that persist across the parameter. The theoretical foundation that makes this
useful in practice is *stability*: small perturbations of the input produce small
perturbations of the output. The output is compared in the **interleaving distance**
(equivalently, by the isometry theorem of Bubenik–Lesnick et al., the bottleneck distance
on persistence diagrams), and the classical stability theorem of Cohen, Steiner,
Edelsbrunner, and Harer (CESH) gives the foundational guarantee:

> uniform `D`-closeness of two filtrations' defining functions ⟹ interleaving distance ≤ `D`.

This is a *one-sided* statement: an upper bound. It is exactly what is needed to trust the
pipeline, and historically it is where the quantitative theory rested. It leaves open the
question of *tightness*: could the interleaving distance be strictly smaller than the
worst-case perturbation, with the shape-extraction quietly damping the data's noise?

This paper answers the question in the negative, in the sharpest possible form, for the
combinatorial model of sublevel-set filtrations of monotone weight functions. We prove the
exact converse of the CESH bound and conclude that the interleaving distance *equals* the
sup-distance of the weights. The proof is short and structural: it isolates the entire
quantitative content into one biconditional and then performs an attained-infimum argument.

### 1.1 Relationship to prior development

This work is the culmination of a sequence ("the Boltzmann Bridge arc") that built the
machinery in stages:

- **Filtration calculus.** The structure `Filtration`, its sublevel sets, monotonicity,
  and the Vietoris–Rips diameter weight.
- **Relational interleaving.** The predicate `Interleaved F G δ` and its preorder
  structure (reflexivity, symmetry, monotonicity in the shift, and additive transitivity),
  together with the CESH bound `stability_supDist`.
- **The extended metric.** The `[0, ∞]`-valued `eInterleavingDist`, the unconditional
  triangle inequality, and the representation as a pseudo-extended-metric space.
- **Metric separation.** The result that the defining infimum is attained at `0`, hence
  `eInterleavingDist(F, G) = 0 ⟺ F = G`, so the structure is a genuine extended metric
  space and no separation quotient is needed.

The present contribution generalizes the last item from the boundary value `0` to *every*
value, yielding the closed-form isometry. We restate all needed prior definitions and
results inline (Section 2) so the development is self-contained.

---

## 2. Preliminaries and definitions

Throughout, `α` is an arbitrary vertex type and `Finset α` denotes finite sets of vertices
(simplices). All weight functions are real-valued; distances live in the extended
non-negative reals `ℝ≥0∞ = [0, ∞]`, with `ENNReal.ofReal : ℝ → ℝ≥0∞` sending negatives to
`0`.

### Definition 2.1 (Filtration)

A **filtration** on `α` is a structure `F` consisting of a weight function
`w_F : Finset α → ℝ` satisfying
1. `w_F(∅) ≤ 0` (the empty simplex is born by scale `0`), and
2. monotonicity: `σ ⊆ τ ⟹ w_F(σ) ≤ w_F(τ)` (a face is born no later than any simplex
   containing it).

Intuitively `w_F(σ)` is the *birth time* of the simplex `σ`.

### Definition 2.2 (Sublevel family)

For a filtration `F` and a scale `t ∈ ℝ`, the **sublevel faces** are
`F.sublevelFaces t = { σ : w_F(σ) ≤ t }`. Monotonicity of `w_F` makes each sublevel family
an abstract simplicial complex, and `t₁ ≤ t₂ ⟹ F.sublevelFaces t₁ ⊆ F.sublevelFaces t₂`
(`sublevel_mono`). The membership criterion is `σ ∈ F.sublevelFaces t ⟺ w_F(σ) ≤ t`.

### Definition 2.3 (Vietoris–Rips weight)

Given a distance matrix `d : α → α → ℝ`, the **diameter weight** of `σ` is
`diamWeightOf(d, σ) = max ( {0} ∪ { d(x, y) : x, y ∈ σ } )`,
the largest pairwise distance among the vertices of `σ` (with `0` adjoined so the empty
simplex and singletons get weight `0`). This is monotone and packages into a filtration
`diamFiltrationOf(d)`; it is the canonical filtration built from a finite metric data set.

### Definition 2.4 (Interleaving)

Two filtrations `F, G` are **`δ`-interleaved** (for `δ ∈ ℝ`), written `Interleaved F G δ`,
when
`0 ≤ δ`  and  `∀ t, F.sublevelFaces t ⊆ G.sublevelFaces (t + δ)`  and
`∀ t, G.sublevelFaces t ⊆ F.sublevelFaces (t + δ)`.
Each sublevel family, shifted by `δ`, contains the other's. The relation is reflexive
(`Interleaved F F 0`), symmetric, monotone in the shift (`Interleaved F G δ, δ ≤ δ' ⟹
Interleaved F G δ'`), and additively transitive (`Interleaved F G δ, Interleaved G H δ' ⟹
Interleaved F H (δ + δ')`).

### Definition 2.5 (Uniform weight closeness)

For `D ∈ ℝ`, write `WeightCloseBy F G D` for `∀ σ, | w_F(σ) − w_G(σ) | ≤ D`: the weight
functions agree to within `D` uniformly over all simplices.

### Definition 2.6 (Extended interleaving distance)

The **extended interleaving distance** is the infimum, in `ℝ≥0∞`, of `ENNReal.ofReal δ`
over the subtype of admissible shifts:
`eInterleavingDist F G = ⨅ (δ : {x : ℝ // Interleaved F G x}), ENNReal.ofReal δ`.
When no interleaving exists, the index subtype is empty and the infimum is `⊤ = ∞`, the
correct value. The distance is symmetric, vanishes on the diagonal, and satisfies the
unconditional triangle inequality, making `Filtration α` a pseudo-extended-metric space;
prior work shows it is in fact a genuine extended metric space.

### Theorem 2.7 (CESH stability — the prior one-sided bound)

`stability_supDist`: if `0 ≤ D` and `WeightCloseBy F G D`, then `Interleaved F G D`.
Consequently `eInterleavingDist F G ≤ ENNReal.ofReal D` whenever `0 ≤ D` and
`WeightCloseBy F G D` (`eInterleavingDist_le_supDist`). This is the only-upper-bound
guarantee that the present work converts into an equality.

We also use the basic principle that any admissible shift bounds the distance:
`Interleaved F G δ ⟹ eInterleavingDist F G ≤ ENNReal.ofReal δ` (`eInterleavingDist_le`).

---

## 3. Main results

### 3.1 The quantitative characterization of interleaving

The engine of the entire development is the following biconditional, which says that the
*relational* notion of interleaving coincides exactly with the *metric* notion of uniform
weight closeness.

#### Theorem 3.1 (`interleaved_iff_weightCloseBy`)

For all filtrations `F, G` and all `δ ∈ ℝ`,
> `Interleaved F G δ  ⟺  0 ≤ δ  ∧  WeightCloseBy F G δ`,
i.e. `F` and `G` are `δ`-interleaved iff `δ ≥ 0` and `∀ σ, |w_F(σ) − w_G(σ)| ≤ δ`.

*Proof sketch.* (`⟸`) This is exactly the CESH stability theorem 2.7: nonnegativity of `δ`
plus uniform `δ`-closeness yields a `δ`-interleaving.

(`⟹`) Assume `Interleaved F G δ`; then `δ ≥ 0` by definition, and we must bound each
birth-time gap. Fix a simplex `σ`. Evaluate the first inclusion of the interleaving at the
scale `t = w_F(σ)`: since `σ ∈ F.sublevelFaces (w_F(σ))` (because `w_F(σ) ≤ w_F(σ)`), the
inclusion `F.sublevelFaces t ⊆ G.sublevelFaces (t + δ)` forces
`σ ∈ G.sublevelFaces (w_F(σ) + δ)`, i.e. `w_G(σ) ≤ w_F(σ) + δ`. Symmetrically, evaluating
the second inclusion at `t = w_G(σ)` gives `w_F(σ) ≤ w_G(σ) + δ`. The two inequalities are
exactly `|w_F(σ) − w_G(σ)| ≤ δ` (`abs_sub_le_iff`). As `σ` was arbitrary, `WeightCloseBy
F G δ` holds. ∎

The decisive feature is that the inclusions are evaluated precisely at the two *birth
times*, where membership is forced by reflexivity of `≤`. At `δ = 0` Theorem 3.1
specializes to the prior boundary result `Interleaved F G 0 ⟺ w_F = w_G`, so Theorem 3.1
is a genuine generalization of metric separation, not a reproof of it.

### 3.2 The extended sup-distance of weights

#### Definition 3.2 (`weightSupEDist`)

The **extended sup-distance** of the weight functions of `F` and `G` is
> `weightSupEDist F G = ⨆ (σ : Finset α), ENNReal.ofReal | w_F(σ) − w_G(σ) |`,
the supremum over all simplices of the `ℝ≥0∞`-valued birth-time gap. The index type
`Finset α` is always nonempty (it contains `∅`), so the supremum is well-defined; it equals
`⊤` exactly when the gaps are unbounded.

### 3.3 The two halves of the isometry

#### Theorem 3.3 (lower half, `weightSupEDist_le_eInterleavingDist`)

`weightSupEDist F G ≤ eInterleavingDist F G`.

*Proof sketch.* It suffices, by the definition of `eInterleavingDist` as an infimum over
the subtype of shifts, to show `weightSupEDist F G ≤ ENNReal.ofReal δ` for every admissible
shift `δ` (`le_iInf`). Fix such a `δ`; by Theorem 3.1 we have `WeightCloseBy F G δ`, i.e.
`|w_F(σ) − w_G(σ)| ≤ δ` for all `σ`. Monotonicity of `ENNReal.ofReal` gives
`ENNReal.ofReal |w_F(σ) − w_G(σ)| ≤ ENNReal.ofReal δ` for each `σ`, and taking the
supremum over `σ` (`iSup_le`) yields `weightSupEDist F G ≤ ENNReal.ofReal δ`. ∎

Conceptually: *every* admissible shift dominates *every* birth-time gap, so the supremum of
the gaps lies below the infimum of the shifts.

#### Theorem 3.4 (upper half / attained infimum, `eInterleavingDist_le_weightSupEDist`)

`eInterleavingDist F G ≤ weightSupEDist F G`.

*Proof sketch.* If `weightSupEDist F G = ⊤` the bound is trivial. Otherwise let
`c = weightSupEDist F G ≠ ⊤` and write `c.toReal` for its real value (`0 ≤ c.toReal`). For
each simplex `σ`, the term `ENNReal.ofReal |w_F(σ) − w_G(σ)|` is below the supremum `c`
(`le_iSup`); since `c ≠ ⊤`, passing to real parts gives `|w_F(σ) − w_G(σ)| ≤ c.toReal`.
Thus `WeightCloseBy F G (c.toReal)` holds. By CESH stability (Theorem 2.7) with the
nonnegative shift `c.toReal`, we obtain `Interleaved F G (c.toReal)`, so `c.toReal` is an
*admissible shift*. Therefore `eInterleavingDist F G ≤ ENNReal.ofReal (c.toReal)`
(`eInterleavingDist_le`), and since `c ≠ ⊤`, `ENNReal.ofReal (c.toReal) = c`
(`ENNReal.ofReal_toReal`). Hence `eInterleavingDist F G ≤ c = weightSupEDist F G`. ∎

The key phrase is *the worst gap is itself an admissible shift*: this is precisely where the
infimum defining the distance is shown to be **attained**, removing the only obstruction to
the reverse inequality.

### 3.4 The isometry formula

#### Theorem 3.5 (`eInterleavingDist_eq_weightSupEDist` — main result, Direction 1)

For all filtrations `F, G`,
> **`eInterleavingDist F G = ⨆ (σ : Finset α), ENNReal.ofReal | w_F(σ) − w_G(σ) |`.**

*Proof.* Antisymmetry of `≤` applied to Theorems 3.3 and 3.4. ∎

**Interpretation.** Consider the map `Φ : Filtration α → (Finset α → ℝ)` sending each
filtration to its weight function, with the target carried by the extended sup-distance
`(f, g) ↦ ⨆_σ ENNReal.ofReal |f(σ) − g(σ)|`. Theorem 3.5 states that `Φ` is *distance
preserving*: `eInterleavingDist F G = supEDist(Φ F, Φ G)`. Since a filtration is determined
by its weight function, `Φ` is injective, so `Filtration α` embeds **isometrically** into
the sup-normed space of weight functions. Persistence (in this model) is an isometry onto
its image, not merely a `1`-Lipschitz contraction. The CESH inequality is recovered as one
half of this equality, and is seen to be *tight*.

### 3.5 Metric separation as a corollary

#### Theorem 3.6 (`weightSupEDist_eq_zero_iff_eq`)

`weightSupEDist F G = 0 ⟺ F = G`; equivalently, via Theorem 3.5,
`eInterleavingDist F G = 0 ⟺ F = G`.

*Proof sketch.* The supremum `⨆_σ ENNReal.ofReal |w_F(σ) − w_G(σ)|` is `0` iff every
summand is `0` iff `|w_F(σ) − w_G(σ)| ≤ 0` for all `σ` iff `w_F = w_G` (pointwise), iff
`F = G` (a filtration is determined by its weight function, the remaining fields being
propositions). ∎

Thus the point-separation (`T0`) property — established in prior work via an attained-at-`0`
argument — falls out instantly from the closed form. The closed form does more than
separate points: it pins the *entire* metric to a sup-norm.

---

## 4. Algorithmic consequences

The isometry formula converts an optimization into a direct computation.

### 4.1 Direct computation of the interleaving distance

By definition `eInterleavingDist` is an infimum over a continuum of candidate shifts — not
directly computable by enumeration. Theorem 3.5 replaces it with a single supremum of
birth-time gaps. For filtrations on a finite vertex set `V` (so there are `2^{|V|}`
simplices), the interleaving distance is computed exactly by:

```
INTERLEAVING-DISTANCE(F, G):
    best ← 0
    for each subset σ of V:                  # 2^{|V|} simplices
        best ← max(best, |w_F(σ) − w_G(σ)|)
    return best
```

This is a single linear pass over the simplices: `O(2^{|V|})` weight evaluations, with no
search over shifts and no persistence-diagram matching. For the Vietoris–Rips case each
`w_F(σ) = diamWeightOf(d, σ)` costs `O(|σ|^2)` distance look-ups.

### 4.2 Realizing the optimal interleaving

Theorem 3.4 is constructive: the value `D = sup_σ |w_F(σ) − w_G(σ)|` is itself an
admissible shift, and CESH stability provides the witnessing `D`-interleaving explicitly
(the two sublevel inclusions hold at shift `D`). Thus one not only computes the distance but
exhibits an optimal alignment, certifying optimality by Theorem 3.3 (no smaller shift can
work, since `D` is realized as a gap).

### 4.3 Tight stability certificates

For Vietoris–Rips filtrations of two distance matrices `d₁, d₂` on a common vertex set, the
prior one-sided bound `vr_eStability` gives `eInterleavingDist(diamFiltrationOf d₁,
diamFiltrationOf d₂) ≤ sup_{x,y} |d₁(x, y) − d₂(x, y)|`. Theorem 3.5 turns the right-hand
side of the stability pipeline into an *exact* value `sup_σ |diamWeightOf(d₁, σ) −
diamWeightOf(d₂, σ)|`, so a stability claim can be certified as tight by exhibiting a single
simplex achieving the worst diameter gap.

---

## 5. Applications

**Topological data analysis.** The interleaving distance is the theoretical yardstick for
comparing persistence outputs. Theorem 3.5 makes it computable in closed form for the
sublevel model and certifies that the standard stability guarantee is not pessimistic: the
output distance is exactly the worst input distortion, so practitioners can read tightness
directly off the data.

**Metric geometry of the space of filtrations.** The isometric embedding into a sup-normed
function space transfers structural properties for free. Sup-normed spaces of bounded
functions are complete; the embedding therefore opens a direct route to completeness of the
filtration metric (a stated future direction), with limits taken pointwise on weights.

**Shape comparison and clustering.** Because the distance is now a maximum of coordinatewise
gaps, comparing many datasets reduces to comparing their birth-time vectors under the
`ℓ^∞` metric — a setting with mature nearest-neighbor and clustering tooling.

---

## 6. Discussion

The methodological lesson refines the one from the immediately preceding result. There, the
key was that an infimum *attained at the boundary value `0`* suffices to separate points.
Here, the same attained-infimum phenomenon holds at *every* value, and the consequence is
stronger: it pins the entire metric to a closed sup-norm form. The conceptual content of the
whole stability arc compresses to one biconditional, `interleaved_iff_weightCloseBy`, whose
forward direction is a two-line evaluation of the interleaving inclusions at birth times and
whose backward direction is the classical CESH theorem. Everything downstream — the
isometry, point separation, computability, tight certificates — is bookkeeping over that
single equivalence.

The result is sharp and falsifiable: any filtration pair whose interleaving distance
strictly undercut the worst birth-time gap would refute Theorem 3.5. None can exist, by the
proof; but the statement is concrete enough that a single counterexample would break it,
which is the hallmark of a useful quantitative theorem.

### Scope and load-bearing hypotheses

The collapse rests on two facts about the codomain `ℝ` of weights: the CESH stability
direction (which is general), and the attained-infimum argument, which uses that a bounded
nonempty set of reals has a real supremum and that `ENNReal.ofReal ∘ toReal` is the identity
below `⊤`. The forward direction of Theorem 3.1 uses only reflexivity of `≤` at the birth
times. The single genuinely order-theoretic ingredient — the Archimedean/completeness
behaviour of `ℝ` — is what makes the infimum attained; replacing the weight codomain by a
non-Archimedean or non-densely-ordered ordered structure would be expected to break the
attainment and reopen a genuine pseudometric kernel (a stated future direction).

---

## 7. Future work

1. **Functoriality and `1`-Lipschitz pushforward.** A weight-nonincreasing (e.g.
   simplicial) map `f : α → β` should induce a pushforward `f# : Filtration α → Filtration β`
   that is `1`-Lipschitz for `eInterleavingDist`, making the filtration construction a
   functor into extended metric spaces and short maps. With a genuine extended metric in
   hand, "short map" is now literally `LipschitzWith 1`, dischargeable by monotonicity
   bookkeeping on sublevel sets, transported through `f#` using attained witnesses rather
   than approximation.

2. **Completeness.** Conjecturally `(Filtration α, eInterleavingDist)` is a complete
   extended metric space, with Cauchy sequences converging to the filtration whose weight is
   the pointwise limit of the weights. The isometric embedding of Theorem 3.5 reduces this to
   completeness of the sup-norm weight metric; this only became a well-posed question once
   points were separated.

3. **Where the collapse fails: non-Archimedean weights.** Replacing the weight codomain `ℝ`
   by a non-densely-ordered or non-Archimedean ordered structure (e.g. a tropical/min-plus
   semiring or an ultrametric value group) should make the attained-infimum step fail, so
   that distinct filtrations sit at distance `0` and the space degenerates to a genuine
   pseudometric. The kernel would then measure the order-theoretic completeness of the weight
   space rather than the topology — a single load-bearing hypothesis, surgically removable.

4. **Quantitative Vietoris–Rips embedding.** The assignment `d ↦ diamFiltrationOf d` from
   distance matrices (sup-norm) to filtrations (interleaving distance) is `1`-Lipschitz; on
   symmetric hollow matrices it is conjecturally an isometry, sharpening `vr_eStability` to an
   equality and making the persistence pipeline distortion-preserving end to end.

---

## 8. Conclusion

We proved that the interleaving distance between sublevel filtrations of monotone weight
functions equals, exactly, the extended sup-distance of those weight functions. The proof
isolates the quantitative content into a single biconditional identifying interleaving with
uniform weight closeness, then attains the defining infimum at the realized worst-case gap.
The classical CESH stability bound is recovered as one half of the resulting equality and is
shown to be tight; point separation follows as a corollary. The space of filtrations under
the interleaving distance is thereby revealed to be an isometric copy of a piece of a
sup-normed function space — a clean, computable, closed-form description of a yardstick that
was previously known only through an optimization. Persistence is an isometry.

All statements are formalized and machine-verified, depending only on the standard
foundational axioms `propext`, `Classical.choice`, and `Quot.sound`, with no `sorry`.
