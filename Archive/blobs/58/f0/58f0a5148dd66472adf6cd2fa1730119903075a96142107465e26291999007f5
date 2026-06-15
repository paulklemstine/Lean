# Future Directions — Categorical Tropical Rips Interleaving

This cycle established, in `Catalog/Bridges/CategoricalTropicalRipsInterleaving.lean`, a
self-contained, fully-verified bridge between **categorical persistence theory**,
**tropical / min-plus algebra**, and **geometry / topological data analysis**:

- Persistence modules as monotone functors `ℝ → α` (`PersMod`).
- `ε`-interleavings, with reflexivity, symmetry, monotone weakening, and the **composition
  law** `Interleaved.trans` (`ε`-interleaving ∘ `δ`-interleaving = `(ε+δ)`-interleaving).
- The `ℝ≥0∞`-valued **interleaving distance** `interleavingDist`, proven to be a pseudometric
  (`interleavingDist_self`, `interleavingDist_comm`, `interleavingDist_triangle`).
- The **tropical reformulation** `interleaving_tropical_submul`: the triangle inequality is
  *exactly* submultiplicativity of `trop ∘ interleavingDist` in `Tropical ℝ≥0∞`.
- **Vietoris–Rips stability** (`rips_stability`, `rips_interleavingDist_le`): sup-close
  dissimilarities yield interleaved Rips modules.

The following conjectures are precise, falsifiable targets for the next cycles.

## Conjecture 1 (Isometry / converse stability)
For Rips modules of pseudometrics `d, d'` on a fixed point set, the interleaving distance is
*equal* to (not just bounded by) the sup perturbation:
`interleavingDist (RipsMod d) (RipsMod d') = ENNReal.ofReal (⨆ x y, |d x y - d' x y|)`
whenever the sup is finite. **Test:** prove the `≥` direction by extracting, from any
`ε`-interleaving of edge-set modules, the pointwise bound `|d x y - d' x y| ≤ ε` (evaluate the
interleaving at `t = d x y`). This would upgrade §4 to a genuine isometry theorem.

## Conjecture 2 (Tropical semiring action on the distance lattice)
The map `(M, N) ↦ trop (interleavingDist M N)` is a lax functor into `Tropical ℝ≥0∞`: not only
submultiplicative under composition (proved), but the *self-distance is the tropical unit*
(`trop 0 = 1` in `Tropical ℝ≥0∞`) and constant shifts act by tropical multiplication, i.e.
`interleavingDist (shift c M) (shift c N) = interleavingDist M N` and the shift functor `M ↦
shift c M` satisfies `interleavingDist M (shift c M) ≤ ENNReal.ofReal c`. **Test:** define
`shift c M := ⟨fun t => M.obj (t + c), …⟩` and prove these three identities.

## Conjecture 3 (Stability is 1-Lipschitz / sub-additive in the tropical metric)
Composition of perturbations is tropically multiplicative end-to-end: for dissimilarities
`d, d', d''`,
`trop (interleavingDist (RipsMod d) (RipsMod d''))
   ≤ trop (idist (RipsMod d) (RipsMod d')) * trop (idist (RipsMod d') (RipsMod d''))`,
and moreover this is *tight* when the perturbations are aligned (same sign everywhere).
**Test:** the inequality is immediate from Conjecture-free results already proved; the tightness
clause is the falsifiable content and should be attacked with a 2-point metric space.

## Conjecture 4 (Lattice-valued generalization: persistence in any complete lattice is a
tropical module)
For any complete lattice `α`, the assignment `ε ↦ {(M,N) | Interleaved ε M N}` defines a graded
sub-relation whose graded pieces are closed under min-plus convolution: if `R_ε` and `R_δ` are
the `ε`- and `δ`-interleaving relations then `R_ε ∘ R_δ ⊆ R_{ε+δ}` (proved as
`Interleaved.trans`) and `R = ⋃_ε R_ε` is the relation of *finite* interleaving distance, which
is an equivalence relation refining bisimilarity. **Test:** prove `R` is transitive and that the
quotient `PersMod α / R` carries a well-defined `Tropical ℝ≥0∞`-valued metric.

## Conjecture 5 (Stability of derived invariants: rank/Betti curves are 1-Lipschitz)
Define, for a Rips module over a *finite* point set, the rank curve `r(t) = card {(x,y) | d x y
≤ t}`. Then `t ↦ r(t)` is monotone and any `ε`-interleaving of Rips modules forces
`r_d(t) ≤ r_{d'}(t + ε)` and symmetrically, hence the rank curves are `ε`-interleaved as
ℕ-valued persistence modules. **Test:** prove the rank functor `PersMod (Set (X×X)) → PersMod ℕ`
(for `Fintype X`) sends `ε`-interleavings to `ε`-interleavings, i.e. it is a 1-Lipschitz functor
for the interleaving distance — a baby "algebraic stability of the rank invariant".
