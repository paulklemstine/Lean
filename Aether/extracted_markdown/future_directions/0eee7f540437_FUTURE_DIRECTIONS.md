# Future Directions — Inverse Stereographic Persistence

## Synthesis

This cycle hardened the central conjecture of *Inverse Stereographic Persistence* from a
"conformal up to a factor" heuristic into an **exact theorem**. The new file
`Geometry/ConformalPersistence.lean` generalizes the catalog's `S¹`-only stereographic results
(`Geometry.StereographicSheaf.stereoProj_on_circle`,
`Geometry.InverseStereoResearch.inv_stereo_on_circle`) to arbitrary dimension `Sⁿ`, and bridges
them to the persistence machinery of `Geometry.PrimewisePersistence`.

The keystone is the closed-form algebraic identity

  `‖φ(x) − φ(y)‖² · (1 + ‖x‖²)(1 + ‖y‖²) = 4 ‖x − y‖²`,

where `φ` is inverse stereographic projection `ℝⁿ → Sⁿ ⊂ ℝⁿ⁺¹`. Equivalently, the chordal sphere
distance equals the conformally weighted Euclidean distance
`d_w(x,y) = 2‖x−y‖ / √((1+‖x‖²)(1+‖y‖²))`. Because Vietoris–Rips / Čech filtrations depend only on
the pairwise distance matrix, this makes `φ` an *isometry* `(ℝⁿ, d_w) ≅ (Sⁿ, chordal)`, and so the
persistence diagrams are not merely close — they are equal. A bonus result shows the spherical
*geodesic* metric is a strictly monotone reparametrization of the chordal metric, so persistence is
preserved for the geodesic metric as well.

## Results Summary

- `invStereoN_on_sphere` — inverse stereographic projection lands on `Sⁿ`, every dimension `n`.
- `stereo_conformal_identity` — the exact conformal isometry identity (the gem).
- `chordal_eq_weighted` — chordal sphere distance equals the weighted Euclidean distance.
- `persistence_edge_equality` / `distance_matrix_eq` — Vietoris–Rips edge sets, hence the whole
  distance matrix of any finite point cloud, coincide under the two metrics.
- `geodesic_strictMonoOn` — geodesic metric is a strictly monotone reparametrization of chordal.

All proofs are `sorry`-free and depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Bottleneck stability of stereographic persistence
The exact isometry gives bottleneck distance **zero** between the spherical and weighted-Euclidean
diagrams. The next step is the *perturbed* statement: if the weight is computed with floating-point
error `δ` in `‖x‖²`, the bottleneck distance is bounded by `C·δ` with an explicit conformal
constant `C(R)` on the ball of radius `R`. The key insight is that the conformal factor
`(1+‖x‖²)⁻¹` is Lipschitz on bounded sets, so distance distortion is linear in the weight error and
the Cohen-Steiner–Edelsbrunner–Harer stability theorem upgrades this to a barcode bound. Why now?
We already possess the exact identity and `Geometry.PrimewisePersistence`'s `BottleneckMatchCost`;
the only missing piece is a Lipschitz estimate on the weight, which is elementary calculus.
*Falsifiable:* exhibit a point cloud where the bottleneck distance exceeds `C(R)·δ`.

### 2. Cross-dimensional persistence functoriality under suspension
The map `φ` for `Sⁿ` restricts compatibly to the equatorial `Sⁿ⁻¹`. Conjecture: stereographic
persistence commutes with topological suspension, i.e. the persistence module of a suspended point
cloud is the (shifted) suspension of the base module. The key insight is that the conformal factor
`(1+‖x‖²)⁻¹` is *dimension-agnostic* — it depends only on `‖x‖²`, which is preserved by the standard
embedding `ℝⁿ ↪ ℝⁿ⁺¹` — so the isometry is natural in `n`. Why now? `invStereoN`, `nsq`, and the
affine-sum identity `sum_affine_sq` are already stated for general `n`, so the inductive step is
purely combinatorial. *Falsifiable:* compute both modules for a small suspended cloud and compare.

### 3. Conformal weight = curvature-corrected density for Čech complexes
On `Sⁿ` the Čech complex uses geodesic balls whose volume differs from Euclidean balls by a
curvature factor. Conjecture: the conformal weight `w(x) = (1+‖x‖²/4)⁻¹` is exactly the Jacobian
correcting Euclidean ball volume to spherical ball volume to first order, so weighted-Čech nerve
counts reproduce spherical Betti numbers without geodesic computation. The key insight is that the
metric distortion factor `2/(1+‖x‖²)` from `stereo_conformal_identity`, squared and integrated, is
the area element of the round metric in stereographic coordinates. Why now? The exact distance
identity pins down the distortion factor with no error term, so the volume claim is a direct
integral, not an asymptotic. *Falsifiable:* compare weighted-Čech Betti curves to direct spherical
Betti curves on sampled `S²`.

### 4. An O(N log N) spherical persistence algorithm with a certified output predicate
The isometry licenses running any Euclidean persistence engine on `φ(X)` with weights, giving the
conjectured `O(N log N)` complexity versus `O(N²)` direct geodesic computation. The key insight is
that `persistence_edge_equality` is a *pointwise* metric equality, so a verified Euclidean
nearest-neighbor / k-d-tree filtration is automatically correct for the spherical problem — the
correctness certificate is the Lean theorem itself. Why now? `distance_matrix_eq` already certifies
that the two filtrations have identical inputs; wrapping a Lean-checkable decision predicate
`VRedge weightedDist ε` around an external engine's output is a small formal-verification task.
*Falsifiable:* find an instance where the weighted-Euclidean engine and the geodesic reference
disagree on a barcode.

### 5. Möbius-invariance of the persistence diagram
Stereographic projection intertwines sphere rotations with Möbius transformations of `ℝⁿ ∪ {∞}`.
Conjecture: the stereographic persistence diagram is invariant under the full conformal (Möbius)
group, not merely rotations, when distances are taken in the weighted metric. The key insight is
that the conformal factor transforms as a cocycle under Möbius maps, and the `(1+‖x‖²)` denominators
in `stereo_conformal_identity` are precisely that cocycle, so the products telescope and leave the
distance invariant. Why now? The catalog already has the Möbius/SL(2) group law
(`Geometry.InverseStereoResearch.mobius_compose_det`); composing it with the new conformal identity
is the natural bridge between the algebra and geometry packages. *Falsifiable:* apply a non-rotation
Möbius map to a spherical cloud and check whether the barcode changes.
