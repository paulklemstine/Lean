# Future Directions: Compression-Based Generalization Bounds

The file `CompressionGeneralization.lean` proves the analytic/combinatorial
backbone of realizable generalization theory: the inversion from a union-bounded
failure probability `|H|·e^{-εm}` to a sample-complexity guarantee, its exact
tightness at the threshold, and three specializations (cardinality, compression,
parameter counting) culminating in an overparameterization theorem. It deliberately
takes the *per-hypothesis tail* as the probabilistic input and proves everything
downstream exactly — mirroring how `PACBayes/Bounds.lean` isolates its
change-of-measure step and complementing the data-dependent capacity of
`RademacherComplexity.empRad`. The following directions extend that frontier.

## 1. Close the probabilistic gap: derive the per-hypothesis tail in Lean

Right now `occamFailBound` is *postulated* to upper-bound the failure probability;
the per-hypothesis content `P(h consistent | err(h) > ε) ≤ (1-ε)^m ≤ e^{-εm}` and
its aggregation by the union bound are not yet formalized. The next cycle should
build the genuine measure-theoretic statement over an i.i.d. product measure
`MeasureTheory.Measure.pi`, using `measure_biUnion_finset_le` for the union bound
and `(1-ε)^m ≤ e^{-εm}` (which follows from `Real.add_one_le_exp`).
**The key insight is** that the entire ENNReal/real coercion difficulty collapses
once the bound is stated as `(μ.pi).toReal (⋃ h ∈ Bad, consistent h) ≤ |H|·e^{-εm}`,
because every term is a probability in `[0,1]` and `ENNReal.toReal` is monotone there.
**Why now?** `occamFailBound_le_delta` already supplies the analytic endgame, so the
only remaining work is the standalone tail+union lemma — a self-contained probability
exercise whose output plugs directly into the proven inversion, turning the whole
chain into an end-to-end PAC theorem with no hypotheses about probabilities.

## 2. Two-sided uniform convergence (the agnostic/non-realizable bound)

The current results are realizable (zero training error). Extend to the agnostic
setting where the bound becomes `trueRisk ≤ empRisk + √((log|H| + log(1/δ))/(2m))`
via Hoeffding's inequality plus the union bound.
**The key insight is** that the agnostic threshold is the *square* of the realizable
one — the `√` appears precisely because Hoeffding gives `e^{-2mε²}` rather than the
realizable `e^{-εm}` — so the same inversion machinery applies after substituting
`ε ↦ ε²` and `2m ↦ m`, and the result should compose with `McAllester`'s `√(KL/n)`
penalty to show the two bounds coincide when the posterior is a point mass.
**Why now?** Mathlib has `MeasureTheory.measure_ge_le_exp_mul_mgf` and Hoeffding-type
lemmas; pairing them with the already-proven `occamFailBound_*` family is the shortest
path to a fully formal agnostic uniform-convergence theorem in the catalog.

## 3. Optimal compression size and the double-descent threshold

`compression_generalizes` is monotone but does not yet identify the *optimal*
compressed size `k*` minimizing `compSampleComplexity m k ε δ` subject to a
realizability constraint `k ≥ k_min(data)`. Formalize `k* = k_min` and prove the
bound is convex/unimodal in `k`, then connect to the empirical double-descent curve
where test error is non-monotone in model size.
**The key insight is** that double descent is *not* a failure of compression bounds:
the second descent corresponds exactly to the regime where the *effective* compressed
size `k_min` stops growing even as the raw parameter count `p` explodes, so plotting
`compSampleComplexity m (k_min p) ε δ` against `p` reproduces the descent qualitatively.
**Why now?** The catalog already contains `TropicalDoubleDescentPhaseDiagram.lean`;
a rigorous link between that phase diagram and a *proven* compression bound would be a
genuine cross-domain bridge from tropical geometry to statistical learning theory.

## 4. Architecture-aware bounds via Lipschitz composition

Replace the crude `2^{p·b}` parameter count with a margin-normalized capacity that
uses per-layer Lipschitz constants, fusing this file with
`Generalization.composition_perturbation_three` and `architecture_lipschitz`. The
target is a spectral-complexity bound of Bartlett–Foster–Telgarsky type:
`sample complexity ∝ (∏_layers ‖W_i‖) · (Σ_layers (‖W_i‖_{2,1}/‖W_i‖)^{2/3})^{3/2}`.
**The key insight is** that the product-of-norms factor is exactly the telescoping
Lipschitz bound already proven in `composition_perturbation_three`, so the spectral
capacity is obtainable by feeding that telescoping constant into the covering-number
slot of `occamSampleComplexity` (with `log|H|` replaced by a covering-number integral).
**Why now?** Both ingredients — the telescoping composition bound and the cardinality
inversion — are now proven catalog lemmas; only the covering-number bridge between
them is missing, making this a high-leverage synthesis rather than a from-scratch build.

## 5. Lower bounds and minimax optimality

Every result here is an upper bound. The tightness lemma
`occamFailBound_at_threshold_eq` is suggestive but only shows the *union bound* is
tight, not that the *sample complexity* is information-theoretically optimal. Prove a
matching lower bound: there exists a class of size `N` and a data distribution forcing
`m = Ω((log N + log(1/δ))/ε)` samples, via Fano's inequality or a packing argument.
**The key insight is** that the lower bound and upper bound share the same `log N`
factor for a reason — both count the bits needed to identify the target hypothesis —
so a packing of `N` well-separated hypotheses makes the upper-bound constant provably
unimprovable, upgrading `occamFailBound_at_threshold_eq` from "the bound is tight" to
"the *theory* is minimax optimal."
**Why now?** With the upper bound fully formalized and its threshold pinned down
exactly, the lower bound is the missing half needed to claim a complete, machine-checked
minimax characterization of realizable learning — a result that does not yet exist in
any proof assistant library.
