# Future Directions — Persistent-Homology Stability (Boltzmann Bridge IV)

## Synthesis

`Applications/BoltzmannBridge/BottleneckStability.lean` closes the catalog's
persistent-homology arc. The earlier files built the filtration calculus
(`HigherPersistence`: `Filtration`, `sublevelFaces`, `sublevel_mono`, the
Vietoris–Rips `diamWeight`) and the relational interleaving lemmas
(`PersistenceStability`: `stability_interleaving`, `stability_compose`,
`stability_two_sided`). This cycle turns those scattered inequalities into a
single coherent metric theory:

* a named, symmetric, additively-composable interleaving relation
  `Interleaved F G δ` (`Interleaved_refl/symm/mono/trans`);
* a real-valued `interleavingDist` — nonnegative, `= 0` on the diagonal,
  symmetric, and bounded by any admissible shift
  (`interleavingDist_nonneg/le/self/comm`);
* the Cohen-Steiner–Edelsbrunner–Harer sublevel stability theorem in sharp
  `1`-Lipschitz form (`stability_supDist`, `interleavingDist_le_supDist`);
* a Gromov–Hausdorff / correspondence-distortion layer over *explicit* distance
  matrices `d : α → α → ℝ` (`diamWeightOf`, `diamFiltrationOf`), with the single
  load-bearing estimate `diamWeightOf_dist_le` (the diameter is `1`-Lipschitz in
  the data) yielding `vr_stability_interleaved` / `vr_stability_dist`;
* an end-to-end concrete verification on two `3`-point clouds
  (`cloud_distortion`, `cloud_stability`, `cloud_interleavingDist_le`).

The whole stability phenomenon collapses onto one inequality: *the simplex weight
is `1`-Lipschitz in the input metric*. Everything downstream is monotonicity
bookkeeping. Deliberate adversarial probing exposed exactly one fault line: the
`sInf`-based distance is honest only up to the `sInf ∅ = 0` convention, which is
where the next cycle should push.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `Interleaved_{refl,symm,mono,trans}` | interleaving is a graded preorder | ✅ proved |
| `interleavingDist_{nonneg,le,self,comm}` | a symmetric, grounded pre-distance | ✅ proved |
| `stability_supDist` / `interleavingDist_le_supDist` | CESH sublevel stability, sharp `1`-Lipschitz | ✅ proved |
| `diamWeightOf_dist_le` | VR diameter is `1`-Lipschitz in the distance matrix | ✅ proved |
| `vr_stability_interleaved` / `vr_stability_dist` | distortion `≤ ε` ⇒ `ε`-interleaving ⇒ bottleneck `≤ ε` | ✅ proved |
| `cloud_{distortion,stability,interleavingDist_le}` | concrete point-cloud certificate | ✅ proved |

All main results are `sorry`-free and depend only on `propext`,
`Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The `EReal` interleaving distance is a true extended pseudometric
The current `interleavingDist` quietly breaks the triangle inequality because
Lean evaluates `sInf ∅ = 0`: two filtrations that are *never* interleaved are
reported at distance `0` rather than `+∞`. Replace the codomain by `EReal` (or
`ℝ≥0∞`), defining `interleavingEDist F G = sInf {(δ : EReal) | Interleaved F G δ}`,
and prove the full pseudometric axioms — crucially
`interleavingEDist F H ≤ interleavingEDist F G + interleavingEDist G H` — using
`Interleaved_trans` as the additive engine. **The key insight is** that
`Interleaved_trans` is already the entire triangle inequality at the relational
level, so the only missing ingredient is an order-complete codomain that records
"no interleaving exists" as `⊤` instead of collapsing to `0`. **Why now?** The
relational composition lemma is proved and the failure mode is documented in the
file's Lab Notebook; the remaining work is purely a change of codomain plus
`EReal` `sInf` API, with no new mathematics required. *Falsifiable:* if the
triangle inequality still fails in `EReal`, the conjecture is refuted by an
explicit three-filtration counterexample.

### 2. Combinatorial isometry theorem: bottleneck `=` interleaving
We currently bound the bottleneck distance via interleaving and *cite* the
Bauer–Lesnick isometry `d_B = d_I`. Formalize a finite multiset model of a
persistence diagram (`Multiset (ℝ × ℝ)` over the diagonal), define the bottleneck
distance through partial matchings, and prove the easy inequality `d_B ≤ d_I`
directly from `Interleaved`, then attack the converse for the restricted class of
diagrams arising from `diamFiltrationOf` on finite clouds. **The key insight is**
that for *finite* point clouds every persistence diagram has finitely many
off-diagonal points, so the matching infimum is attained and the converse reduces
to a finite combinatorial optimization rather than the full measure-theoretic
argument. **Why now?** Our filtrations are finite by construction (`Finset α`
simplices), so the hard analytic part of the general isometry theorem is absent
and a self-contained finite proof is in reach. *Falsifiable:* exhibit a finite
cloud where the matching-defined `d_B` strictly exceeds `interleavingDist`.

### 3. The sharp factor-two Gromov–Hausdorff bound
Promote the correspondence-distortion estimate to the genuine Gromov–Hausdorff
distance: define `dGH` between two finite distance matrices as the infimum over
correspondences of half the metric distortion, and prove
`interleavingDist (diamFiltrationOf d₁) (diamFiltrationOf d₂) ≤ 2 * dGH d₁ d₂`,
the Chazal–Cohen-Steiner–Guibas–Mémoli–Oudot bound. **The key insight is** that
`diamWeightOf_dist_le` already gives the per-correspondence bound; upgrading to
`dGH` only requires taking an infimum over the (finite) set of correspondences
and tracking the factor `2` coming from the symmetric distortion definition.
**Why now?** The per-correspondence inequality — historically the technical heart
— is fully proved here, so the generalization is an `sInf`-monotonicity wrapper.
*Falsifiable:* a pair of clouds with `interleavingDist > 2 * dGH` would refute the
constant.

### 4. Interleaving controls every numerical invariant (Euler/Betti stability)
The catalog already has `euler_char_full_simplex` (and the f-vector layer in
`FaceVector.lean`, `eulerChar_eq_alt_fVector`). Conjecture: the Euler
characteristic curve `t ↦ χ(sublevelComplex t)` and the persistent Betti numbers
are themselves stable — uniformly close filtrations produce Euler curves that
agree except on a set of total length `≤ 2δ`. **The key insight is** that an
`Interleaved F G δ` sandwiches each sublevel complex of `F` between two sublevel
complexes of `G` at scales `t ± δ`, so any monotone-in-inclusion invariant is
trapped in a `δ`-window and inherits stability for free. **Why now?** Both the
interleaving sandwich (`sublevel_mono`, `Interleaved`) and a computed Euler
invariant exist in the catalog; combining them needs only a monotonicity lemma
for `χ` under `ASC.Sub`. *Falsifiable:* a `δ`-interleaved pair whose Euler curves
differ on a set longer than `2δ`.

### 5. Functoriality / data-processing inequality for filtrations
Conjecture a contraction principle: if `Φ` transforms weight functions and is
itself `1`-Lipschitz in sup-norm (e.g. pushforward along a `1`-Lipschitz map of
vertices, or smoothing), then
`interleavingDist (Φ F) (Φ G) ≤ interleavingDist F G`. **The key insight is** that
`interleavingDist_le_supDist` already shows persistence is `1`-Lipschitz in the
weight, so any `1`-Lipschitz preprocessing composes to a non-expansive map on
persistence — a topological "data-processing inequality". **Why now?** The
sup-norm Lipschitz bound is the proved cornerstone; functoriality is its closure
under composition, and it directly justifies the common TDA pipeline step of
denoising before computing diagrams. *Falsifiable:* a `1`-Lipschitz `Φ` and a
pair `F, G` with `interleavingDist (Φ F) (Φ G) > interleavingDist F G`.
