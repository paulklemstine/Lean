# Future Directions: Tropicalization of Berggren Word Evaluation

The file `Catalog/Bridges/BerggrenTropicalValuation.lean` builds the first half of a
valuation–monoid bridge over the existing Berggren machinery in
`Cryptography.BerggrenLatticeReduction`: a logarithmic-height valuation `tropHeight`
on Pythagorean triples that turns matrix-word concatenation into an additive
(degenerate max-plus) subadditive calculus. We proved a sharp factor-6 generator
inequality, a functorial upper bound `c(evalWord w t) ≤ 6^{|w|}·c(t)`, the
concatenation law `tropHeight(eval(u++v)) ≤ |u| + tropHeight(eval v)`, and a two-sided
length ⇆ height certificate. The following directions extend this into a full
ordered-semiring homomorphism and an algorithmic pruning pipeline.

## Direction 1: A per-generator refined valuation vector (anisotropic certificate)

The current bound collapses all three generators to a single worst-case factor 6.
But the matrices A, B, C expand the hypotenuse by genuinely different ratios: B is the
expansive branch (sup ratio 3+2√2 ≈ 5.83), while A and C are tamer. The conjecture is
that there is a *vector-valued* tropical certificate `μ : BerggrenWord → ℕ^3` recording
per-letter contributions such that `c(evalWord w t)` is sandwiched by a max-plus product
weighted by the letter multiplicities, strictly sharper than `6^{|w|}`.

**The key insight is** that the abelianized generator profile `abelianCount`
(from `BerggrenFingerprintRigidity`) already determines a multiset of expansion factors,
so the log-height factors through abelianization up to a bounded order-dependent error —
making the *commutative* image of the word monoid carry most of the growth information.

**Why now?** The catalog already has `abelianCount`, `abelianCount_append`, and the
fingerprint rigidity theorems; combining them with the new `tropHeight_eval_le` gives an
immediate target where the tropical certificate is provably *between* the abelian lower
and the ordered upper bound, a falsifiable sharpening of the present factor-6 estimate.

## Direction 2: Closing the gap to the sharp irrational factor 3+2√2

We proved 6 is the best *integer* constant and that 5 fails at the root. Over ℝ the true
supremum of the per-step ratio is 3+2√2. The conjecture is that for every ε>0 there is a
good triple on which generator B exceeds (3+2√2−ε)·c, while no good triple ever reaches
or exceeds (3+2√2)·c — i.e. the bound is approached but never attained on the integer
light cone.

**The key insight is** that the ratio (2a+2b+3c)/c is maximized as (a,b)→(c/√2, c/√2),
which is irrational, so the integer Pythagorean triples form a sequence approaching but
never hitting the optimum — a Diophantine-approximation phenomenon on the light cone.

**Why now?** The Lorentz-form infrastructure (`lorentzQ`, light-cone classification in
`BerggrenLatticeCryptography` and `BerggrenLorentz/Core`) lets one parametrize good
triples by the Gaussian-integer generators (m,n), turning the supremum claim into an
explicit limit of m,n → ∞ that is directly formalizable.

## Direction 3: An honest ordered-semiring homomorphism into max-plus

`tropHeight` is currently a *sub*-homomorphism (inequality only). The conjecture is that
the exact log-height is an additive homomorphism *up to a uniformly bounded defect*:
there is a constant K with `|tropHeight(eval(u++v)) − tropHeight(eval u) − growth(v)| ≤ K`
for all words, so that after quotienting by the bounded-defect equivalence, `tropHeight`
becomes a genuine monoid homomorphism `(BerggrenWord,++) → (ℕ,+)` and extends to a
semiring homomorphism into the tropical semiring `(ℕ ∪ {−∞}, max, +)`.

**The key insight is** that the multiplicative lower bound (each step multiplies c by at
least a fixed factor >1, provable from `hyp_strictly_increases` strengthened) pairs with
the factor-6 upper bound to pin the log-height within an additive constant of |w|,
yielding bounded defect rather than mere subadditivity.

**Why now?** The additive lower bound `height_lower_bound_length` and the new
multiplicative upper bound already sandwich the height; only a matching *multiplicative
lower* bound is missing, and proving `c(actGen g t) ≥ 2·c(t)` (or the sharp constant) is a
single nlinarith-style lemma analogous to `two_legs_le_three_hyp`.

## Direction 4: A no-collision search-pruning pipeline with certified speedup

The two-sided `word_length_certificate` already lets one reject candidate words whose
length is incompatible with an observed hypotenuse. The conjecture is that the tropical
certificate yields a branch-and-bound pruning rule that is *sound* (never discards the
true word) and gives a provable exponential reduction in the search frontier compared to
naive enumeration, strengthening `prune_prepend_sound` from
`BerggrenLatticeReduction` with a quantitative bound.

**The key insight is** that `tropHeight_append_le` makes the log-height a *monotone
potential* under prefixing, so any partial word already exceeding the target's log-height
can be pruned, and the number of surviving prefixes at each depth is bounded by the
certificate window width `[Nat.log 6 (c/5), c−5]`.

**Why now?** `candidateWordSet_finite`, `prune_prepend_sound`, and `finite_nearby_words`
are already proven; the tropical potential supplies exactly the monotone bounding function
those branch-and-bound soundness theorems were designed to consume, so the speedup theorem
is a quantitative corollary rather than new infrastructure.

## Direction 5: p-adic depth profile as a second, independent valuation

The hypotenuse log-height is an archimedean valuation. The conjecture is that a *p-adic*
valuation depth — e.g. `v_p(c)` for fixed small primes p — gives a second, independent
tropical invariant that distinguishes words the archimedean height cannot, so that the
*pair* (log-height, p-adic depth) strictly increases the separating power of
`tropHeight_separates`.

**The key insight is** that the Berggren generators have fixed reductions mod small primes,
so the p-adic depth of the hypotenuse evolves by an ultrametric `max`-law (exactly the
`UltrametricCompositionLaw` of `Computation.PadicValuationDepth`) rather than an additive
one — giving genuinely orthogonal information from the archimedean height.

**Why now?** `Computation.PadicValuationDepth` already supplies `ValuationDepthMeasure`,
`vdepth_sum_le`, and the ultrametric composition law; instantiating that typeclass on the
Berggren hypotenuse map directly bridges the two catalog modules and makes the
two-valuation separation theorem a concrete, falsifiable target.
