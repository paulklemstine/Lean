# The Interleaving Distance is the Sup-Distance of Weights: An Isometry, a Functor, and a Representation Theorem for Finite Filtrations

## Abstract

We study the metric theory of *filtrations* in their most economical combinatorial
form: a filtration on a vertex type α is a monotone, grounded real weight function
on the finite subsets (simplices) of α. The natural metric is the **extended
interleaving distance** `d(F,G)`, the infimum of all shifts δ ≥ 0 for which the
sublevel families of F and G shift into one another. We prove that this distance
admits an exact closed form: it equals the supremum, over all simplices σ, of the
absolute gap of birth times,
$$ d(F,G) = \sup_{\sigma} \mathrm{ofReal}\,|w_F(\sigma) - w_G(\sigma)|, $$
taken in the extended nonnegative reals. The single engine is a relational
characterization — **interleaving is exactly uniform weight-closeness** — whose
hard direction is the converse of the classical stability theorem and is proved by
evaluating sublevel inclusions at the two birth times. The closed form is an
*isometry*: filtrations embed distance-preservingly into weight functions under the
sup-distance. We then exploit the formula structurally. First, vertex maps induce a
**contravariant pullback functor** on filtrations that is **1-Lipschitz** for the
interleaving distance, and an **isometry when the map is surjective** (correcting a
prior conjecture that named injectivity). Second, the weight map is a **bijection**
onto the monotone, grounded functions — a **representation theorem** that, together
with the isometry, completely classifies the persistence emetric as the order
interval of monotone functions under the sup-emetric. All results are formalized
and machine-checked with no remaining gaps, depending only on the standard
foundational axioms.

**Keywords:** persistent homology, topological data analysis, interleaving
distance, stability theorem, isometry, functoriality, representation theorem,
sup-norm.

---

## 1. Introduction

Persistent homology summarizes the multiscale topology of data by tracking the
births and deaths of homological features as a scale parameter increases. The
robustness of these summaries — the bedrock of *topological data analysis* (TDA) —
is expressed through the **interleaving distance** between filtrations and the
**stability theorem**, which guarantees that perturbing the input perturbs the
summary by no more.

The stability theorem is classically a one-sided estimate: it bounds the
interleaving distance *above* by the perturbation of the underlying data. The
present work establishes that, in a clean finite-combinatorial model, the estimate
is *two-sided and exact*. The interleaving distance is not merely controlled by the
sup-norm gap of the birth-time functions; it *equals* it. Persistence in this model
is an isometry, not merely a contraction.

We then develop two structural consequences that the closed form makes elementary:
a **functoriality** result (relabeling vertices is a short map, and an isometry
exactly under surjectivity), and a **representation theorem** (the weight map is a
bijection onto monotone grounded functions), which together classify the entire
metric space.

### 1.1 Contributions

1. **Relational characterization (§3).** `Interleaved F G δ ↔ δ ≥ 0 ∧ ∀σ,
   |w_F(σ) − w_G(σ)| ≤ δ`. The forward direction (the converse of stability) is the
   sole nontrivial input.
2. **Isometry formula (§4).** `d(F,G) = ⨆_σ ofReal|w_F(σ) − w_G(σ)|`, proved by two
   matching inequalities, with the upper half realizing an *attained* infimum.
3. **T0 separation (§4.3).** `d(F,G) = 0 ↔ F = G`, recovered as a one-line
   corollary.
4. **Functoriality and Lipschitz/isometry behavior (§5).** A contravariant
   pullback functor, 1-Lipschitz for d, and isometric for surjective maps;
   including a correction to a published conjecture about injective maps.
5. **Representation theorem (§6).** The weight map is a bijection onto monotone,
   grounded functions; combined with the isometry, this classifies the space.

---

## 2. Definitions

Throughout, α, β, γ are types of vertices and `Finset α` denotes the type of finite
subsets (simplices) of α. We write `ℝ≥0∞` for the extended nonnegative reals and
`ofReal : ℝ → ℝ≥0∞` for the truncation-at-zero coercion (`ofReal x = max(x,0)` as an
extended real).

### Definition 2.1 (Filtration).
A **filtration** on α is a structure carrying a weight function and two proofs:
$$
\texttt{weight} : \mathrm{Finset}\,\alpha \to \mathbb{R}, \qquad
\texttt{weight\_empty} : w(\varnothing) \le 0, \qquad
\texttt{weight\_mono} : \sigma \subseteq \tau \Rightarrow w(\sigma) \le w(\tau).
$$
We write `w_F` for the weight of F. Intuitively `w_F(σ)` is the scale at which the
simplex σ is *born*.

### Definition 2.2 (Sublevel family).
For t ∈ ℝ, the **sublevel set** of F at scale t is
$$ \mathrm{sublevelFaces}_F(t) = \{\sigma : w_F(\sigma) \le t\}. $$
By monotonicity it is nested in t: `t₁ ≤ t₂ ⇒ sublevelFaces_F(t₁) ⊆
sublevelFaces_F(t₂)`. (For t ≥ 0 it is moreover a downward-closed abstract
simplicial complex, the *sublevel complex*.)

### Definition 2.3 (Interleaving relation).
For δ ∈ ℝ, F and G are **δ-interleaved**, written `Interleaved F G δ`, when
$$
\delta \ge 0 \ \wedge\
\bigl(\forall t,\ \mathrm{sublevelFaces}_F(t) \subseteq \mathrm{sublevelFaces}_G(t+\delta)\bigr)
\ \wedge\
\bigl(\forall t,\ \mathrm{sublevelFaces}_G(t) \subseteq \mathrm{sublevelFaces}_F(t+\delta)\bigr).
$$
The relation is reflexive, symmetric, monotone in δ, and additive under
composition (a δ-interleaving and an ε-interleaving compose to a (δ+ε)-one).

### Definition 2.4 (Extended interleaving distance).
$$ d(F,G) \;=\; \inf_{\{\delta\,:\,\mathrm{Interleaved}\,F\,G\,\delta\}} \mathrm{ofReal}(\delta) \ \in\ \mathbb{R}_{\ge 0}^{\infty}. $$
The infimum is taken over the subtype of admissible shifts; when no interleaving
exists it is the empty infimum ⊤, which is the correct value (an ℝ-valued
formulation would erroneously return 0). The basic bound is

> **(Witness bound)** `Interleaved F G δ ⇒ d(F,G) ≤ ofReal δ`.

The structure `(Filtration α, d)` is a pseudo-extended-metric space.

### Definition 2.5 (Uniform weight-closeness).
For D ∈ ℝ,
$$ \mathrm{WeightCloseBy}\ F\ G\ D \ :\equiv\ \forall \sigma,\ |w_F(\sigma) - w_G(\sigma)| \le D. $$

### Definition 2.6 (Weight sup-distance).
$$ \mathrm{weightSupEDist}(F,G) \;=\; \bigsqcup_{\sigma\,:\,\mathrm{Finset}\,\alpha} \mathrm{ofReal}\,|w_F(\sigma) - w_G(\sigma)| \ \in\ \mathbb{R}_{\ge 0}^{\infty}, $$
the supremum (in ℝ≥0∞) of the pointwise extended gaps. The index type `Finset α` is
nonempty (it contains ∅), so this is well defined.

### Definition 2.7 (Diameter / Vietoris–Rips filtration).
Given a bare distance matrix `d : α → α → ℝ` (no metric axioms required), the
**diameter weight** of a simplex is
$$ \mathrm{diamWeightOf}\ d\ \sigma \;=\; \max\Bigl(0,\ \max_{x,y \in \sigma} d(x,y)\Bigr), $$
and `diamFiltrationOf d` is the filtration with this weight (nonnegative, grounded,
monotone). This is the Vietoris–Rips construction in weight-function form.

---

## 3. The relational characterization

The technical heart is that the interleaving relation *is* uniform weight-closeness.

### Theorem 3.1 (`interleaved_iff_weightCloseBy`).
For all filtrations F, G and all δ ∈ ℝ,
$$ \mathrm{Interleaved}\ F\ G\ \delta \iff \delta \ge 0 \ \wedge\ \forall \sigma,\ |w_F(\sigma) - w_G(\sigma)| \le \delta. $$

**Proof sketch.** *(⇐)* This is the classical stability theorem
(`stability_supDist`): if all gaps are ≤ δ ≥ 0, then for any t and any σ with
w_F(σ) ≤ t we have w_G(σ) ≤ w_F(σ) + δ ≤ t + δ, giving the inclusion
`sublevelFaces_F(t) ⊆ sublevelFaces_G(t+δ)`, and symmetrically. *(⇒)* Assume the
interleaving. Fix σ. Evaluate the first inclusion at the birth time `t = w_F(σ)`:
since σ ∈ sublevelFaces_F(w_F(σ)) (with weight ≤ itself), the inclusion places
σ ∈ sublevelFaces_G(w_F(σ) + δ), i.e. `w_G(σ) ≤ w_F(σ) + δ`. Evaluate the second
inclusion at `t = w_G(σ)` to get `w_F(σ) ≤ w_G(σ) + δ`. Together with `abs_sub_le_iff`
these give `|w_F(σ) − w_G(σ)| ≤ δ`. ∎

The proof uses no analysis beyond the order structure of ℝ; the only place the
*Archimedean* nature of ℝ enters is the `abs_sub_le_iff` repackaging. At δ = 0 the
theorem specializes to the boundary case `Interleaved F G 0 ↔ w_F = w_G`, so it is a
genuine generalization of that fact rather than a reproof.

---

## 4. The isometry formula

We now show `d = weightSupEDist` via two inequalities.

### Theorem 4.1 (Lower half, `weightSupEDist_le_eInterleavingDist`).
$$ \mathrm{weightSupEDist}(F,G) \le d(F,G). $$

**Proof sketch.** `d(F,G)` is an infimum over admissible shifts δ. Fix such a δ. By
Theorem 3.1, `|w_F(σ) − w_G(σ)| ≤ δ` for every σ, hence `ofReal|w_F(σ)−w_G(σ)| ≤
ofReal δ`. Taking the supremum over σ (`iSup_le`) gives `weightSupEDist(F,G) ≤
ofReal δ`; taking the infimum over δ (`le_iInf`) gives the claim. ∎

### Theorem 4.2 (Upper half, `eInterleavingDist_le_weightSupEDist`).
$$ d(F,G) \le \mathrm{weightSupEDist}(F,G). $$

**Proof sketch.** If `weightSupEDist(F,G) = ⊤`, the bound is `le_top`. Otherwise let
`c = weightSupEDist(F,G) < ⊤`. For each σ, `ofReal|w_F(σ)−w_G(σ)| ≤ c` (it is a
term of the supremum, `le_iSup`), so `|w_F(σ)−w_G(σ)| ≤ c.toReal`. Thus
`WeightCloseBy F G c.toReal` with `c.toReal ≥ 0`. By stability (Theorem 3.1, ⇐) we
obtain `Interleaved F G c.toReal`, so the witness bound gives `d(F,G) ≤ ofReal
c.toReal = c` (using `ofReal_toReal` for finite c). ∎

The asymmetry between the two halves is the conceptual content: the upper half is an
**attained-infimum** argument. The candidate shift `c.toReal` — the real value of
the supremum of gaps — is *itself admissible*. The optimum is realized, not merely
approached.

### Theorem 4.3 (Isometry formula, `eInterleavingDist_eq_weightSupEDist`).
$$ \boxed{\,d(F,G) \;=\; \bigsqcup_{\sigma} \mathrm{ofReal}\,|w_F(\sigma) - w_G(\sigma)|\,} $$

**Proof.** `le_antisymm` of Theorems 4.1 and 4.2. ∎

Consequently the assignment `F ↦ w_F` is an isometric embedding of `(Filtration α,
d)` into `(Finset α → ℝ)` under the sup-emetric `edist f g = ⨆_σ ofReal|f(σ)−g(σ)|`.

### 4.3 T0 separation

### Corollary 4.4 (`weightSupEDist_eq_zero_iff_eq`).
$$ \mathrm{weightSupEDist}(F,G) = 0 \iff F = G. $$

**Proof.** Rewrite by Theorem 4.3 and apply the boundary case `d(F,G) = 0 ↔ F = G`
(itself: a vanishing supremum of nonnegative terms forces every gap to vanish, so
w_F = w_G, and a filtration is its weight). ∎

---

## 5. Functoriality: the pullback is a short map

The closed form turns structural questions into supremum bookkeeping. We record the
behavior under vertex relabeling.

### Definition 5.1 (Pullback).
For `f : α → β` (with decidable equality on β so images compute), the **pullback**
`pullback f : Filtration β → Filtration α` is
$$ (\mathrm{pullback}\ f\ F).\mathtt{weight}\ \sigma \;=\; w_F(\sigma.\mathrm{image}\,f). $$
It is a filtration: grounded because `(∅).image f = ∅`, and monotone because
`σ ⊆ τ ⇒ σ.image f ⊆ τ.image f` (`Finset.image_subset_image`) composed with
`weight_mono` of F.

### Proposition 5.2 (Functoriality, `pullback_id`, `pullback_comp`).
`pullback id = id`, and (contravariantly) `pullback (g ∘ f) = pullback f ∘
pullback g`.

**Proof sketch.** Both reduce by `ext_weight` (a filtration is determined by its
weight, §6) to identities on images: `σ.image id = σ`, and `(σ.image f).image g =
σ.image (g ∘ f)` (`Finset.image_image`). ∎

### Theorem 5.3 (Pullback is 1-Lipschitz, `eInterleavingDist_pullback_le`).
$$ d(\mathrm{pullback}\ f\ F,\ \mathrm{pullback}\ f\ G) \le d(F,G). $$

**Proof sketch.** Rewrite both sides by Theorem 4.3. The left side is `⨆_σ
ofReal|w_F(σ.image f) − w_G(σ.image f)|`. Each term equals the upstairs term at
`τ = σ.image f`, hence is `≤ ⨆_τ ofReal|w_F(τ) − w_G(τ)|` by `le_iSup`. Taking the
supremum over σ gives the bound: the downstairs supremum ranges over a *subimage* of
the upstairs index set. ∎

Packaged with the pseudo-emetric instance, this is the Mathlib predicate
`LipschitzWith 1 (pullback f)` (`pullback_lipschitzWith_one`): persistence is a
functor into the category of short maps.

### Theorem 5.4 (Isometry under surjections, `eInterleavingDist_pullback_eq_of_surjective`).
If f is surjective then
$$ d(\mathrm{pullback}\ f\ F,\ \mathrm{pullback}\ f\ G) = d(F,G). $$

**Proof sketch.** `le_antisymm` with Theorem 5.3 for ≤. For ≥, rewrite by Theorem
4.3; every τ : Finset β equals σ.image f for some σ (take `σ = τ.image (surjInv f)`
and use `image_image` with `surjInv_eq`), so each upstairs term at τ is realized by a
downstairs term, giving `⨆_τ ≤ ⨆_σ` by `le_iSup`. ∎

### Remark 5.5 (Correction of a prior conjecture).
An earlier formulation claimed equality for *injective* f. This is false. If
`f : α ↪ β` is injective but not surjective, simplices of β outside the image of
`·.image f` are never indexed downstairs; on those simplices F and G may differ
arbitrarily, so the left supremum omits arbitrarily large terms and the pullback
distance can strictly undercut d(F,G). The closed form localizes the issue: what
matters is whether `σ ↦ σ.image f` *covers* `Finset β`, which holds iff f is onto.
Surjectivity is the correct hypothesis.

---

## 6. The representation theorem

### Theorem 6.1 (Injectivity, `ext_weight`).
If `w_F = w_G` then `F = G`. (A filtration's two non-data fields are propositions;
proof-irrelevance closes the equality.)

### Definition 6.2 (Constructor, `ofWeight`).
Given `w : Finset α → ℝ` with `w(∅) ≤ 0` and `Monotone w`, `ofWeight w` is the
filtration with weight w (the two hypotheses are exactly its required proofs).
By construction `(ofWeight w).weight = w`.

### Theorem 6.3 (Surjectivity, `weight_surjective`).
Every monotone, grounded `w : Finset α → ℝ` is the weight of a (unique) filtration,
namely `ofWeight w`.

### Theorem 6.4 (Representation, `weightEquiv`).
The weight map is a bijection
$$ \mathrm{weightEquiv} : \mathrm{Filtration}\ \alpha \ \simeq\ \{\,w : \mathrm{Finset}\,\alpha \to \mathbb{R}\ \mid\ w(\varnothing) \le 0\ \wedge\ \mathrm{Monotone}\ w\,\}, $$
with inverse `ofWeight`. Combined with Theorem 4.3 (`eInterleavingDist_ofWeight`),
this is a distance-preserving identification: `(Filtration α, d)` is, up to the
explicit bijection, the order interval of monotone, grounded functions under the
sup-emetric `edist f g = ⨆_σ ofReal|f(σ) − g(σ)|`.

**Proof sketch.** Theorems 6.1 and 6.3 give injectivity and surjectivity; the
roundtrips `ofWeight ∘ weight = id` and `weight ∘ ofWeight = id` hold by `ext_weight`
and definitional unfolding. Distance preservation is Theorem 4.3 read on the image.
∎

---

## 7. Algorithms

The closed form is constructive over a finite simplex set S (e.g. all subsets of a
finite vertex set, or an explicit complex).

### 7.1 Interleaving distance by worst-gap scan.
By Theorem 4.3, `d(F,G)` restricted to a finite S is `max_{σ∈S} |w_F(σ) − w_G(σ)|`.
A single pass over S computes it in O(|S|) weight evaluations. No search over shifts
is needed.

### 7.2 Decision of δ-interleaving.
By Theorem 3.1, `Interleaved F G δ` holds iff `δ ≥ 0` and `max_{σ} |w_F(σ) −
w_G(σ)| ≤ δ` — i.e. compare the worst gap against δ. O(|S|).

### 7.3 Pullback evaluation.
`(pullback f F).weight σ = w_F(f(σ))`: map each vertex of σ through f, deduplicate,
and read off w_F. The pullback distance (Theorem 5.3/5.4) is then the worst-gap scan
applied to the reindexed weights.

### 7.4 Vietoris–Rips weights.
`diamWeightOf d σ = max(0, max_{x,y∈σ} d(x,y))`: a double loop over the vertices of
σ. Feeding two distance matrices into the worst-gap scan certifies VR stability
numerically.

---

## 8. A worked example

We illustrate every result on the vertex set α = {a, b, c}, whose simplices are
∅, {a}, {b}, {c}, {a,b}, {a,c}, {b,c}, {a,b,c}.

Let F be the Vietoris–Rips-style filtration with vertex weights 0, edge weights
w_F({a,b}) = 1, w_F({a,c}) = 2, w_F({b,c}) = 3, and w_F({a,b,c}) = 3, and let G
agree with F except w_G({a,c}) = 2.7 and w_G({b,c}) = 2.5. Both are grounded and
monotone, hence filtrations.

*Isometry (Theorem 4.3).* The per-simplex gaps |w_F − w_G| are 0 on the vertices,
0 on {a,b}, 0.7 on {a,c}, 0.5 on {b,c}, and 0 on {a,b,c}. Their supremum is 0.7,
attained at {a,c}; therefore d(F,G) = 0.7. One checks directly that the shift
δ = 0.7 interleaves the sublevel families (every birth time moves by ≤ 0.7), while
δ = 0.69 does not (the simplex {a,c} fails to shift in), confirming the infimum is
attained exactly at 0.7 — not merely approached.

*T0 separation (Corollary 4.4).* Since the supremum of gaps is 0.7 ≠ 0, F ≠ G,
consistent with d(F,G) > 0; and d(F,F) = 0 because all gaps vanish.

*Functoriality (Theorems 5.3–5.4).* Take β = {A, B} carrying filtrations F′, G′,
and the surjection f : α → β with f(a) = f(b) = A, f(c) = B. The pullback weights
on α are read off the images: e.g. (f*F′).weight({a,b}) = w_{F′}({A}). Because f is
onto, every simplex of β is the f-image of some simplex of α, so the reindexing
covers Finset β and d(f*F′, f*G′) = d(F′, G′). By contrast, the injective
non-surjective g : {0,1} → {A,B,C} with g(0)=A, g(1)=B leaves the vertex {C}
uncovered; placing all of the F′-G′ disagreement on simplices containing C makes
the pullback distance 0 while d(F′,G′) is large — exactly the failure described in
Remark 5.5.

*Representation (Theorem 6.4).* The function w with w(σ) = max over the vertices of
σ of a base value (and w(∅) = 0) is monotone and grounded, hence equals
(ofWeight w).weight for a unique filtration; conversely F above is recovered from
its own weight by ext_weight. The weight map is a bijection onto such functions.

---

## 9. Applications

- **Robust comparison of TDA summaries.** The interleaving distance — the canonical
  yardstick for persistence — is computed exactly by a one-pass maximum of birth-time
  differences, with no interleaving search.
- **Vietoris–Rips stability certificates.** Comparing two distance matrices over the
  same points produces a provable, exact bound on the persistence distance via the
  diameter weights.
- **Data aggregation guarantees.** Relabeling/coarsening vertices (a vertex map) is a
  short map (Theorem 5.3); faithful (surjective) aggregation preserves distances
  exactly (Theorem 5.4). This is the precise robustness one wants from pooling
  operations.
- **Model identification.** The representation theorem (Theorem 6.4) reduces all
  metric reasoning about filtrations to sup-norm reasoning about monotone functions,
  a far better understood setting.

---

## 10. Discussion

The arc from a one-sided stability inequality to a two-sided isometry is driven by a
single observation (Theorem 3.1): the sublevel order encodes the weight order
*exactly*, so an interleaving of shift δ is *literally* uniform δ-closeness of
weights. Everything else is the ⨆/⨅ duality, made unconditional by working in
ℝ≥0∞ so the unbounded (⊤) case is automatic. The lone analytic input is the
attainment step in Theorem 4.2, which uses order-completeness of ℝ (via
`ofReal_toReal`); this is exactly the hypothesis whose removal (§ Future Directions)
breaks the isometry.

Once the metric is a sup-norm on functions, structure follows by bookkeeping:
functoriality and the Lipschitz/isometry dichotomy (§5) are `iSup`-monotonicity over
a reindexing, and the classification (§6) is the trivial constructor `ofWeight`
matched against `ext_weight`. The closed form converts geometry into combinatorics.

All statements are formally verified with zero remaining `sorry`s, depending only on
the standard foundational axioms (`propext`, `Classical.choice`, `Quot.sound`).

---

## 11. Future work

We outline a program for future work. In brief: (1)
sharpening Vietoris–Rips stability to an *edge-indexed* isometry by collapsing the
simplex-supremum to a vertex-pair supremum; (2) **completeness** of `(Filtration α,
d)` via closedness of the monotone, grounded constraint set under uniform limits;
(3) the functor/short-map packaging (largely realized in §5); (4) identifying where
the isometry *breaks* — non-Archimedean / non-densely-ordered weight codomains (e.g.
min-plus tropical semirings) retain Theorem 3.1 but lose the attainment step of
Theorem 4.2, degenerating the metric back to a pseudometric; and (5) the
representation theorem (§6), now a black box that downstream homology-stability
results can cite.

---

## Appendix A. Result index

| Name | Statement |
|---|---|
| `interleaved_iff_weightCloseBy` | `Interleaved F G δ ↔ δ ≥ 0 ∧ ∀σ, |w_F(σ)−w_G(σ)| ≤ δ` |
| `weightSupEDist` | `⨆_σ ofReal|w_F(σ)−w_G(σ)|` |
| `weightSupEDist_le_eInterleavingDist` | `weightSupEDist ≤ d` |
| `eInterleavingDist_le_weightSupEDist` | `d ≤ weightSupEDist` (attained infimum) |
| `eInterleavingDist_eq_weightSupEDist` | **`d(F,G) = ⨆_σ ofReal|w_F(σ)−w_G(σ)|`** |
| `weightSupEDist_eq_zero_iff_eq` | `weightSupEDist = 0 ↔ F = G` |
| `pullback`, `pullback_id`, `pullback_comp` | contravariant persistence functor |
| `eInterleavingDist_pullback_le` / `pullback_lipschitzWith_one` | pullback is 1-Lipschitz |
| `eInterleavingDist_pullback_eq_of_surjective` | isometry for surjective maps |
| `ofWeight`, `weight_surjective`, `weightEquiv` | representation theorem |
| `eInterleavingDist_ofWeight` | emetric in explicit weight-function form |
