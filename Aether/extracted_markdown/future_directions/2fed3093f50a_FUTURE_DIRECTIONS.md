# Future Directions — Categorical Tropicalization of Rips Filtrations and Interleaving Stability

This cycle established (in `Catalog/Bridges/CategoricalTropicalRipsInterleaving.lean`,
0 sorries, axioms `propext / Classical.choice / Quot.sound` only) the order-theoretic
core of persistence stability:

- a Rips filtration `ripsOf` of an **arbitrary symmetric distance** `d : α → α → ℝ`
  (generalizing the instance-bound `ripsGraph` of
  `Applications/PoincareData/MetricFiltration.lean`, related by `ripsMetric_eq_ripsOf`);
- the `δ`-**interleaving** relation `Interleaved`, with `interleaved_refl`,
  `interleaved_symm`, `interleaved_mono`, and the **tropical composition law**
  `interleaved_comp` (shifts add: `δ₁ ⊙ δ₂ = δ₁ + δ₂`);
- the **stability theorem** `rips_stability` (`|d − d'| ≤ δ ⇒ δ`-interleaved) and its
  metric form `rips_stability_dist`;
- the **interleaving (pseudo)distance** `interleavingDist` satisfying the tropical
  valuation / pseudometric axioms `interleavingDist_self`, `interleavingDist_comm`,
  `interleavingDist_triangle`.

The conjectures below are concrete, falsifiable next steps. Each is phrased so that a
follow-up cycle can either produce a Lean theorem or a Lean counterexample.

---

## Conjecture 1 — Sharpness of stability (the converse Lipschitz bound)

**Statement.** For finite `α` with two symmetric distances `d, d'`, the interleaving
distance of their Rips filtrations *equals* a tropical "best matching" of edge-birth
scales:
```
interleavingDist (ripsOf d) (ripsOf d') = sInf { δ ≥ 0 | ∀ x y, |d x y − d' x y| ≤ δ on the relevant edge set }.
```
In particular stability is **tight**: there exist `d, d'` with
`interleavingDist (ripsOf d) (ripsOf d') = ‖d − d'‖_∞`. 

**Test.** Prove `interleavingDist (ripsOf d) (ripsOf d') ≥ f(d,d')` for an explicit
lower bound `f`, complementing the upper bound `rips_stability_dist`; or exhibit a
3-point counterexample where the inequality is strict. *Falsifiable:* a single finite
example with strict gap refutes tightness.

## Conjecture 2 — `interleavingDist` is a genuine extended pseudometric on filtrations

**Statement.** Replacing `ℝ` by `ℝ≥0∞` and dropping the nonemptiness hypotheses,
`interleavingDistExt : (ℝ → SimpleGraph α) → (ℝ → SimpleGraph α) → ℝ≥0∞` is a true
`PseudoEMetricSpace` structure on the type of **monotone** filtrations, with
`interleavingDistExt F G = 0 ↔ F = G` on left-continuous filtrations.

**Test.** Build the `ℝ≥0∞`-valued version, prove `edist`-style triangle/symmetry
unconditionally (the `sInf ∅ = ⊤` convention removes the `Nonempty` hypotheses that are
load-bearing in the current `ℝ` version), and register a `PseudoEMetricSpace` instance.
*Falsifiable:* exhibiting two distinct left-continuous monotone filtrations at distance
`0` refutes the separation half.

## Conjecture 3 — Functoriality: 1-Lipschitz maps contract interleaving distance

**Statement.** A `1`-Lipschitz map `φ : (α, d) → (α', d')` (i.e. `d' (φx)(φy) ≤ d x y`)
induces graph homomorphisms `ripsOf d ε → ripsOf d' ε` for all `ε`, and the induced map
on filtrations is **`1`-Lipschitz for `interleavingDist`**. Hence `interleavingDist`
is a functor `(FiniteMetricSpaces, Lipschitz) ⥤ (Filtrations, interleaving)` landing in
the tropical-enriched category of §2.

**Test.** Define the induced filtration map, prove the homomorphism existence, and prove
the contraction `interleavingDist (push φ F) (push φ G) ≤ interleavingDist F G`.
*Falsifiable:* a Lipschitz map increasing some interleaving distance.

## Conjecture 4 — Tropical idempotency: an ultrametric refinement via single-linkage

**Statement.** The **`π₀`/connected-components** functor applied to `ripsOf d` recovers
the single-linkage (sub-)dendrogram, and the associated "merge-scale" distance
`d_SL x y := inf { ε | x, y connected in ripsOf d ε }` is an **ultrametric**, with
```
interleavingDist (ripsOf d) (ripsOf d') ≤ ‖d_SL − d'_SL‖_∞ ≤ ‖d − d'‖_∞,
```
so single-linkage is a tropical-idempotent contraction of the metric. This directly
links this bridge to `Bridges/CategoricalTropicalUltrametric.lean`: `d_SL` is the
ultrametric *reconstructed* from the tropical valuation data of the filtration.

**Test.** Define `d_SL` via `SimpleGraph.Reachable` on `ripsOf d ε`, prove the strong
triangle inequality `d_SL x z ≤ max (d_SL x y) (d_SL y z)`, and prove the chained bound.
*Falsifiable:* a 4-point example violating the ultrametric inequality for `d_SL`.

## Conjecture 5 — Stability of the connectivity (Poincaré) threshold

**Statement.** Define the connectivity threshold `θ(d) := inf { ε | ripsOf d ε is
connected }` (the `MetricFiltration`-level "Poincaré threshold" of the catalog). Then
`θ` is **`1`-Lipschitz** in the `sup`-distance:
```
|θ(d) − θ(d')| ≤ ‖d − d'‖_∞,
```
as a corollary of `rips_stability` plus monotone-connectivity transfer along
interleavings (`δ`-interleaved filtrations have connectivity thresholds within `δ`).

**Test.** Prove "connected at scale `ε` ⇒ connected at scale `ε + δ` for a
`δ`-interleaved filtration" (using `interleaved.fg` and `SimpleGraph.Connected.mono`),
then derive the Lipschitz bound on `θ`. *Falsifiable:* a finite perturbation moving the
connectivity threshold by more than `‖d − d'‖_∞`.
