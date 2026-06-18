# Future Directions — Stereographic Proof Compression

The file `StereographicProofCompression.lean` formalizes a geometric model of proofs:
a proof is a finite binary step-sequence (`List Bool`), encoded as a point of the
Cantor set on the line via the base-3 address `addr`, then lifted to the unit circle
`S¹` by inverse stereographic projection `P`. The *proof distance* is the chordal
(spherical) distance of the images. The headline theorem `subproof_length_bound`
turns the informal slogan "close on the sphere ⇒ long shared subproof" into the
sharp quantitative statement

> if two proofs diverge at step `k`, then `k ≥ log₃(1/d) − 1`,

flanked by the matching two-sided estimate `(1/3)^(k+1) ≤ d ≤ 2·(1/3)^k` obtained
from the exact chord formula `‖P s − P t‖² = 4(s−t)²/((1+s²)(1+t²))`. The engine is
a genuine **bi-Lipschitz embedding** of the proof-prefix metric: separation
(`addr_sep`) and contraction (`addr_close`) of the Cantor code, transported to the
sphere by `chordSq_lower`/`chordSq_upper`. This connects directly to the catalog's
stereographic line (`InverseStereoResearch.inv_stereo_on_circle`,
`StereographicSheaf`, `StereographicRG`) and to its Cantor/self-similar geometry
(`FractalDimension`).

The directions below are concrete, falsifiable, and each names the Lean object it
would extend.

## 1. The exact metric: proof distance *is* an angle

Promote `proofDist` from a chord to the genuine geodesic angle
`θ(p,q) = 2·arcsin(proofDist p q / 2)` on `S¹`, and prove `θ` is a genuine metric on
`List Bool` (symmetry, triangle inequality, and `θ = 0 ↔ p = q` once distinct proofs
are forced to distinct Cantor addresses). Conjecture: the bi-Lipschitz bounds upgrade
to `(1/3)^(k+1) ≤ θ(p,q) ≤ 3·(1/3)^k`, so `θ` and the prefix-ultrametric are uniformly
equivalent. **The key insight is** that on the unit circle the chord and the arc are
themselves bi-Lipschitz (`x ≤ 2·arcsin(x/2) ≤ (π/2)·x` for `x ∈ [0,√2]`), so the
angular metric inherits the embedding bounds with only a constant loss. **Why now?**
`chordal_sq_formula` and `P_on_circle` already pin the image to `S¹` exactly, and
Mathlib's `Real.arcsin`/`Real.arccos` API is mature, so the only new content is the
elementary chord–arc comparison — a clean next step rather than new theory.

## 2. Injectivity and the discreteness of proof space

Prove `addr` is injective on the *reduced* code (no trailing `false` repetitions that
collapse `[…, true]` against `[…, false, true, true, …]`), hence `proofDist p q = 0 ↔
p = q` for reduced proofs. Conjecture: the image `{addr p : p reduced}` is exactly the
standard middle-thirds Cantor set, so proof space embeds as a closed, totally
disconnected, perfect subset of `S¹`. **The key insight is** that the digit set
`{0,2}` was chosen precisely so addresses never carry, making first-difference position
a complete invariant — the same mechanism that powers `addr_sep`. **Why now?**
`addr_sep` already gives strict separation at the first differing index; injectivity is
the qualitative shadow of that quantitative bound, and the catalog's
`FractalDimension` machinery supplies the Cantor-set vocabulary to state the image
characterization.

## 3. Hausdorff/box dimension of the proof code on the sphere

Conjecture: the set of stereographic proof images has Hausdorff dimension `log 2 / log 3`
(the Cantor dimension), and the number of proofs of length `n` whose images are
`ε`-separated is `Θ(ε^{−log2/log3})`. **The key insight is** that the bi-Lipschitz
bounds `(1/3)^(k+1) ≤ d ≤ 2·(1/3)^k` force the `ε`-covering number of depth-`n` proofs
to track the ternary scale exactly, so a packing/covering count converts the
combinatorial growth `2^n` into a fractal dimension. **Why now?** Both ingredients are
in hand — `proofDist_upper`/`proofDist_lower` give the metric distortion and the
catalog's `FractalDimension.lean` already formalizes box-counting — so this is a
synthesis of two existing pieces rather than a from-scratch development.

## 4. Higher spheres for multi-tactic proofs (S^n, n ≥ 2)

Generalize from a binary alphabet on `S¹` to an alphabet of `m` tactics encoded on
`S^n` via the `n`-dimensional inverse stereographic projection, with `addr` replaced
by a base-`(2m+1)` Cantor vector. Conjecture: the subproof bound becomes
`k ≥ log_{2m+1}(c/d) − 1`, so *richer tactic languages compress proofs into
longer forced common subproofs at a slower logarithmic rate* governed by the alphabet
size. **The key insight is** that the single scalar chord formula generalizes to
`‖Pₙ s − Pₙ t‖² = 4‖s−t‖²/((1+‖s‖²)(1+‖t‖²))`, so the entire one-dimensional argument
transports verbatim with the Euclidean norm in place of `|·|`. **Why now?** Mathlib's
`EuclideanSpace`/`stereographic` chart and `innerSL` API make the vector chord identity
reachable, and `subproof_length_bound` already isolates exactly the one inequality that
needs to be re-derived in higher dimension.

## 5. From distance to a shared *lemma*: turning geometry into proof mining

Conjecture (the applied payoff): there is an extraction map sending any two proofs with
`proofDist p q ≤ (1/3)^{k}` to an explicit common prefix `s` with `s.length ≥ k − 1`,
computable in time `O(k)`, such that `s` is a valid standalone sub-derivation
("lemma"). **The key insight is** that `subproof_length_bound` is *constructive*: the
first-difference index it bounds from below is literally `List.takeWhile (·=·)`, so the
shared lemma is the witnessing prefix, not just an existence statement. **Why now?**
The decomposition `addr_diff_eq` already exhibits the common prefix as the algebraic
object controlling the distance, so the conjecture only asks to read that prefix back
out — a direct route from the proven geometry to automated lemma discovery, which is
the stated impact of this research line.
