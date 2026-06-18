# Future Directions — Tropicalization of Arithmetic Height on Sparse Rational Sequences

## Synthesis

The new file `Catalog/Bridges/SparseRatSeqTropicalHeight.lean` fuses three
existing catalog strands into one cross-domain object:

* the rational arithmetic height `ratArithHeight q = |num q| + den q` from
  `Bridges/ArithmeticVCDimension.lean`,
* the sequence-valued, max-style subadditive complexity measure paradigm of
  `Computation/PadicValuationDepth.lean` (`vdepth_sum_le`),
* the tropical "addition = max" valuation language of
  `Bridges/CategoricalTropicalUltrametric.lean`.

The central object is `seqArithHeight : (ℕ →₀ ℚ) → ℕ`, the `Finset.sup` of
coordinate heights over the (finite) support. We proved it behaves like a
**tropical max-seminorm whose correction term is multiplicative, not additive**:

* normalization: `seqArithHeight 0 = 0`, `seqArithHeight (single i q) = ratArithHeight q`;
* monotonicity under support refinement: `seqArithHeight_mono`;
* the coordinate bridge lemmas `ratArithHeight_add_le_mul` and
  `ratArithHeight_mul_le_mul` (height is sub-multiplicative under `+` and `*`);
* the **sharp** disjoint-support identity `seqArithHeight_add_disjoint`
  (`seqArithHeight (f+g) = max (...)`, an ultrametric-style equality);
* the general multiplicative triangle bound `seqArithHeight_add_le_mul`;
* scalar control `seqArithHeight_smul_le`;
* a *formal falsification* `additive_scalar_bound_false` showing the naive
  additive law `seqArithHeight (q • x) ≤ ratArithHeight q + seqArithHeight x`
  is false (witness `q = 3`, `x = single 0 3`).

## Results Summary

10 theorems, 0 `sorry`, only the standard axioms `propext`,
`Classical.choice`, `Quot.sound`. The qualitative message: **tropicalization of
arithmetic height is `log`** — under `log`, sub-multiplicativity becomes the
additive tropical triangle inequality, the disjoint-support case becomes the
strict ultrametric equality, and the (false) additive correction is exposed as
the wrong normalization.

## Falsifiable Research Directions

### 1. Exact `log`-tropical seminorm and the `TropicalValuationObject` instance
Define `tropHeight x := Real.log (seqArithHeight x)` (with `log 0 := 0`) and ask
whether `(SparseRatSeq, tropHeight)` populates a *weakened*
`TropicalValuationObject` from `Bridges/CategoricalTropicalUltrametric.lean` in
which the triangle axiom holds up to the additive constant
`log (seqArithHeight x) + log (seqArithHeight y)` and is *exact* on disjoint
supports. The key insight is that the multiplicative bound `H(f+g) ≤ Hf · Hg`
becomes `tropHeight (f+g) ≤ tropHeight f + tropHeight g`, the literal tropical
triangle inequality, so the functor "height ↦ log-height" should land inside the
tropical category up to a controlled defect. Why now? Both endpoints already
exist in-repo (`seqArithHeight_add_le_mul`, `seqArithHeight_add_disjoint`); only
the `log` transport and an axiom-by-axiom structure check remain, so this is a
short, fully falsifiable formalization (it fails iff some bundled axiom cannot be
met even in weakened form).

### 2. Sharpness census: which pairs achieve `H(a+b) = Ha · Hb`?
The coordinate bound `ratArithHeight_add_le_mul` has slack exactly
`|num a| · |num b|`. Conjecture: equality `ratArithHeight (a+b) = ratArithHeight a · ratArithHeight b`
holds iff `a` or `b` is `0`, hence is essentially never tight for nonzero inputs;
and the *best* constant `c` with `H(a+b) ≤ c · max(Ha,Hb)` over all `a,b` of
bounded height grows linearly in that height bound. The key insight is that the
gap `|num a|·|num b|` is precisely the obstruction to a clean additive-correction
tropical law, so quantifying it pins down the "distance from ultrametric." Why
now? The slack term is already isolated inside the proved lemma; a `decide`-backed
finite search over bounded-height rationals can confirm or refute the equality
characterization computationally before any general proof is attempted.

### 3. Northcott finiteness ⇒ VC/pseudo-dimension bound for sparse height classes
Define the height-stratified class `S_{k,d} := {x : ℕ →₀ ℚ | seqArithHeight x ≤ k ∧ |support x| ≤ d}`
and conjecture it is *finite* with `|S_{k,d}| ≤ (2k)^d · (binomial bound on supports)`,
yielding a Sauer–Shelah-style pseudo-dimension surrogate. The key insight is that
bounded `seqArithHeight` forces each coordinate into the finite Northcott set
`{q | ratArithHeight q ≤ k}`, so sparse bounded-height sequences form an explicit
finite arithmetic codebook — exactly the pipeline `ArithmeticVCDimension.lean`
builds for scalars, now lifted to sequences. Why now? It directly composes the
scalar trace-counting machinery already in the catalog with the new sequence
height; falsifiable because the cardinality bound is an explicit inequality that
a counting argument either meets or breaks.

### 4. Disjointness is necessary, not just sufficient, for the max identity
Conjecture: `seqArithHeight (f+g) = max (seqArithHeight f) (seqArithHeight g)`
fails for a *generic* overlapping pair, and more strongly the set of overlapping
pairs achieving the max identity has "measure zero" in any natural enumeration
(e.g. it requires the overlapping coordinates to already realize the max without
cancellation). The key insight is that `seqArithHeight_add_disjoint` used
disjointness only to kill cross terms, so probing overlapping witnesses isolates
whether disjointness is the true boundary of ultrametric behavior. Why now? The
sufficient direction is proved; the converse is a concrete witness hunt
(`q = 1/2`, `q = 1/2` on a shared index gives height `1` collapse) that is
immediately falsifiable by a single explicit `Finsupp`.

### 5. Multiplicative submultiplicativity of the full sequence convolution product
Extend from coordinatewise `*` to the Cauchy/convolution product on
`ℕ →₀ ℚ` (polynomial multiplication) and conjecture
`seqArithHeight (f ⋆ g) ≤ C(deg) · seqArithHeight f · seqArithHeight g` with an
explicit support-size correction `C(deg)` counting the number of colliding index
pairs. The key insight is that the proved coordinate lemmas
`ratArithHeight_add_le_mul` and `ratArithHeight_mul_le_mul` are exactly the two
atoms needed to bound a convolution coefficient (a sum of products), so the
sequence-level bound should follow by `Finset.sup`/triangle bookkeeping. Why now?
It turns the static height seminorm into a genuine height theory for the
polynomial ring `ℚ[X]` viewed as sparse sequences, bridging to Mahler-measure /
Weil-height heuristics; falsifiable via the explicit correction `C(deg)`, which a
small-degree computation can confirm or contradict.
