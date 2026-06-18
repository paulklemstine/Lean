# Future Directions — Tropical Height on Berggren Words

## Synthesis

This cycle built a new quantitative invariant — the **tropical (logarithmic, max-plus)
height** `tropHeight t = log₂ (max |a| |b| |c|)` — on top of the existing Berggren
infrastructure (`actGen`, `evalWord`, `evalAtRoot`, `tripleHeight`, `GoodTriple`) from
`Cryptography/BerggrenLatticeReduction.lean`, and connected it to the arithmetic-height
philosophy of `ratArithHeight` in `Bridges/ArithmeticVCDimension.lean`. The central
discovery is that *tropicalizing* the coordinate norm is exactly what is needed to make
the Berggren dynamics behave additively: each generator is a linear map whose row
coefficient magnitudes sum to at most `7`, so the raw coordinate norm grows
multiplicatively by `≤ 7` per step (`maxCoord_actGen_le_seven`); taking `log₂` converts
this into a clean additive Lipschitz bound `+3` per generator (`tropHeight_actGen_le`).
From this single per-generator fact everything else cascades: an affine depth bound
`2 + 3n` (`tropHeight_evalAtRoot_le`), a concatenation/triangle bound
(`tropHeight_concat_le`), prepend-monotonicity (`tropHeight_mono_prepend`), a constant
lower bound (`tropHeight_evalAtRoot_lower`), and the payoff — a *finite-search
certificate* (`finite_bounded_tropHeight`): a tropical (logarithmic) budget `H` confines
the search to words of length `< 2^(H+1)`, hence finitely many.

What failed — instructively — is the *symmetric* subadditivity
`tropHeight(u++v) ≤ tropHeight u + tropHeight v + C`. Two independent obstructions were
identified. First, the catalog's only available lower bound on `tripleHeight (evalAtRoot u)`
is *linear* in `|u|` (`5 + |u| ≤ c`), so its `log₂` is only *logarithmic* in `|u|`, while
the increment from concatenation is *linear* in `|u|`; the additive-log form therefore
cannot follow from the depth/length bound alone. Second, and more interestingly, the
underlying multiplicative statement `c_{u++v} ≤ c_u · c_v` *is* true experimentally
(0 violations among all 65536 word pairs with `|u|,|v| ≤ 4`), but a clean algebraic proof
is blocked: the third row `(p,q,r)` of any word-matrix satisfies the Lorentzian relation
`p²+q²+1 = r²` (verified for all words up to length 5), yet the relaxation using only this
relation together with `a²+b²=c²` is genuinely *false* (a grid analysis shows the
quantity is unbounded below when the row is allowed to tilt freely). So the truth of
sub-multiplicativity depends on the *reachability* of the word-matrix from the root — i.e.
on the hyperbolic geometry of the O(2,1;ℤ) orbit, not just the pointwise form relation.

The structural insight that ties the cycle together: the Berggren tree carries a hidden
*tropical semiring shadow*. Multiplicative matrix growth ↦ additive tropical cost, and the
exponential `7^n` raw bound ↦ the affine `3n` tropical bound. This is precisely the
Bridges↔Tropical and Algebra↔Tropical connection the catalog flagged as missing, and it
is now realized with sorry-free quantitative inequalities plus a finite-search payoff.

## Results Summary

- `maxCoord_good`: proved — for a good triple the max-plus norm equals the hypotenuse, linking the new invariant to the catalog's `tripleHeight`.
- `tropHeight_good`: proved — tropical height of a good triple is `log₂` of its hypotenuse.
- `maxCoord_actGen_le_seven`: proved — each generator scales the coordinate norm by at most `7` (multiplicative Lipschitz).
- `log2_seven_mul_le`: proved — `log₂(7m) ≤ log₂ m + 3`, the arithmetic core of tropicalization.
- `tropHeight_actGen_le`: proved — **generator tropical Lipschitz** `tropHeight (actGen g t) ≤ tropHeight t + 3`.
- `tropHeight_evalWord_le`: proved — word bound `tropHeight (evalWord w t) ≤ tropHeight t + 3|w|`.
- `tropHeight_root`: proved — `tropHeight (3,4,5) = 2`.
- `tropHeight_evalAtRoot_le`: proved — **depth bound**: a node at depth `n` has tropical height `≤ 2 + 3n`.
- `tropHeight_concat_le`: proved — **concatenation control** `tropHeight (evalWord (u++v) t) ≤ tropHeight (evalWord v t) + 3|u|`.
- `tropHeight_mono`: proved — monotonicity in the coordinate norm.
- `tropHeight_evalAtRoot_lower`: proved — every generated node has tropical height `≥ 2`.
- `tropHeight_mono_prepend`: proved — tropical height is monotone under prepending generators (soundness of tropical pruning).
- `finite_bounded_tropHeight`: proved — **algorithmic certificate**: only finitely many words have tropical height `≤ H`.
- `hyp_submultiplicative`: conjecture — `c_{u++v} ≤ c_u · c_v`; 0/65536 violations, proof needs O(2,1) reachability geometry.
- `tropHeight_subadditive`: conjecture — `tropHeight(u++v) ≤ tropHeight u + tropHeight v + 1`; the `log₂` of the sub-multiplicative conjecture.

## Research Directions

### Direction 1: Prove hypotenuse sub-multiplicativity via the Lorentz orbit
**Hypothesis**: For all Berggren words `u, v`,
`tripleHeight (evalAtRoot (u++v)) ≤ tripleHeight (evalAtRoot u) · tripleHeight (evalAtRoot v)`.
**Test**: Formalize the matrix realization `evalWord w t = M_w · t` (bridging to
`Algebra/BerggrenLorentz/Core.lean`), prove that the third row of every reachable `M_w`
is a *future-pointing* vector `f = M_w⁻¹ e₃` with `f₁²+f₂²+1 = f₃²` AND `5f₃ - 3f₁ - 4f₂ ≥ f₃`
(a reachability inequality), then discharge the resulting polynomial inequality
`f₁(3c-a) + f₂(4c-b) ≤ 4c f₃` by `nlinarith`/`polyrith`. The cycle already verified
`p²+q²+1=r²` computationally for all words up to length 5.
**Why now**: This cycle isolated the *exact* missing ingredient — reachability, not the
form relation — and reduced the whole conjecture to one scalar polynomial inequality on
the inverse third row. The key insight is that the failure of the unconstrained
relaxation pinpoints the single extra reachability constraint that must be carried through
the induction.
**If true**: `tropHeight_subadditive` follows immediately via `Nat.log_mul_le`, completing
the tropical-semiring picture and giving a genuine sub-multiplicative complexity measure.
**If false**: a counterexample word pair would refute the Lorentzian heuristic and force a
different (e.g. anisotropic, per-coordinate-weighted) tropical height.

### Direction 2: A two-sided (sandwich) tropical height
**Hypothesis**: There is a constant `κ` and an explicit slow-growth word family `w_n`
(skewed triples) with `tropHeight (evalAtRoot w_n) ≤ log₂(5 + n) + κ`, so the depth lower
bound `tropHeight ≥ log₂(5+|w|)` is tight up to `κ`, while generic words achieve the upper
bound `2 + 3n`.
**Test**: Exhibit `w_n` (conjecturally the all-`A` or all-`C` path on a maximally skewed
branch), compute `tripleHeight (evalAtRoot w_n)` in closed form, and prove the matching
`O(log n)` upper bound; separately prove a generic `Ω(n)` lower bound along a balanced path.
**Why now**: The proof of `finite_bounded_tropHeight` already exposes both the linear
hypotenuse lower bound and the `7^n` upper bound. The key insight is that tropical height
is *not* a function of depth alone — the `log n`-to-`3n` gap between branches is itself the
interesting invariant, governing how aggressively tropical pruning can prune.
**If true**: it quantifies the variance of tropical height across the tree and sharpens the
search certificate to depth-adaptive bounds.
**If false** (height essentially determined by depth): the tree would be tropically
"rigid", which would itself be a strong and surprising structural statement.

### Direction 3: Tropical pruning beats height pruning for nearest-word search
**Hypothesis**: For the certified search of `Cryptography/BerggrenLatticeReduction.lean`
(`candidateWordSet`, `prune_prepend_sound`), replacing the linear height bound by the
tropical bound strictly reduces the explored node count, i.e. there exist targets where the
tropical frontier `{w | tropHeight (evalAtRoot w) ≤ H}` is exponentially smaller than the
hypotenuse frontier `{w | tripleHeight (evalAtRoot w) ≤ 2^H}` actually visited.
**Test**: Formalize a node-count functional over the finite candidate set and prove a strict
inequality between the tropical-pruned and height-pruned counts on a concrete target triple.
**Why now**: `finite_bounded_tropHeight` and the catalog's `prune_prepend_sound` are both in
place, so the comparison is now a finite, decidable statement. The key insight is that
`tropHeight` is monotone under prepend (`tropHeight_mono_prepend`), which is exactly the
soundness condition a branch-and-bound key must satisfy — so the tropical key is a *drop-in*
replacement whose only question is efficiency.
**If true**: it converts the invariant into a concrete algorithmic improvement for
Diophantine/cryptographic word search.
**If false**: it shows the two keys are coarsely equivalent, redirecting effort toward
multi-dimensional tropical keys (Direction 4).

### Direction 4: Anisotropic / vector-valued tropical heights
**Hypothesis**: The two leg-slopes `a/c, b/c` carry a *vector* tropical height
`(log₂(num)+log₂(den))` (via `ratArithHeight`) that is generator-Lipschitz coordinatewise
with distinct constants `C_A ≠ C_B ≠ C_C`, refining the scalar `+3` bound and detecting the
*letter* used at each step.
**Test**: Define the rational leg-slope triple, compute `ratArithHeight` of each slope, and
prove per-generator additive bounds with generator-dependent constants; check whether the
constants distinguish the three generators (a "tropical fingerprint").
**Why now**: `ratArithHeight` already exists in `Bridges/ArithmeticVCDimension.lean` and the
generator action is explicit. The key insight is that the scalar tropical height discards
*directional* information that the rational-slope height retains, potentially yielding an
invariant fine enough to *decode* a word from its height trajectory.
**If true**: it bridges to the VC-dimension/codebook program (height-stratified trace
classes) and gives a height-only word recovery procedure.
**If false**: the generators are tropically indistinguishable at the slope level, implying a
symmetry that constrains any future invariant.

### Direction 5: Tropical height and Rényi-2 entropy of Berggren orbits
**Hypothesis**: The shell-count/collision bounds of `Bridges/BerggrenEntropyExtractor.lean`
can be re-expressed through `tropHeight`: the number of depth-`n` nodes with tropical height
in `[h, h+1)` is bounded, giving a tropical refinement of the Rényi-2 entropy lower bound.
**Test**: Count `{w | w.length = n ∧ tropHeight (evalAtRoot w) = h}` and relate it to the
norm-shell cardinalities used in the extractor's collision-energy bound.
**Why now**: Both the extractor entropy machinery and the tropical depth bound now coexist in
the catalog. The key insight is that tropical height is a *coarse-grained energy* on orbits,
so binning by tropical height is exactly the partition needed to turn collision counts into
entropy estimates.
**If true**: it strengthens the certified-extractor pipeline with an explicit, computable
tropical entropy stratification.
**If false**: it reveals that tropical height is too coarse to capture orbit collisions,
motivating finer (Direction 4) heights for the cryptographic application.
