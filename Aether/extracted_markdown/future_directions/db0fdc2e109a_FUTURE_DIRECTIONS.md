# Future Directions — Rademacher Complexity of Neural Networks

## Synthesis of this cycle

This cycle built a self-contained, fully formal core of statistical learning
theory in `Catalog/MachineLearning/RademacherNeuralNet.lean`: the **empirical
Rademacher complexity** `empRad` of a finite hypothesis class, modelled by the
behaviour vectors `v : Fin n → ℝ` of its members on an `n`-point sample, averaged
over all `2^n` sign patterns. Every result is proved with no `sorry` and depends
only on the standard axioms `propext, Classical.choice, Quot.sound`.

The development deliberately threads together three different mathematical
registers and connects to the project's existing PAC-Bayes file
(`MachineLearning/PACBayes/Bounds.lean`, lemmas `mcAllester_*` / `catoni_*`),
which bounds the true risk by *empirical risk + complexity*; this file bounds the
complexity term those theorems take for granted.

### Results summary

* `empRad_singleton` — a single hypothesis has complexity exactly `0` (pure sign
  symmetry: each coordinate's contribution cancels over the `2^n` patterns).
* `empRad_mono` — complexity is monotone under class inclusion.
* `empRad_smul` — **positive homogeneity**: scaling every hypothesis by `c ≥ 0`
  scales the complexity by *exactly* `c`. This equality is the algebraic engine
  behind a single linear layer's spectral-norm bound.
* `empRad_depth` — **depth scaling**: `L` linear layers each of spectral norm
  `≤ C` multiply complexity by `C^L` (a corollary of `empRad_smul`).
* `empRad_mgf_bound` — the moment-generating-function inequality `avg ≤ log M / λ
  + λ B² / 2`, valid for every inverse-temperature `λ > 0` (Jensen + Fubini
  factorisation + the sub-Gaussian `cosh` bound `Real.cosh_le_exp_half_sq`).
* `empRad_massart` — **Massart's finite-class lemma**: `empRad V ≤ B · √(2 log |V|) / n`
  for behaviour vectors of Euclidean norm `≤ B`. Through a covering-number scaling
  `log |V| ≍ C² L`, this is exactly the advertised `O(C · √L / √n)` rate.

A boundary observation worth recording: the `n > 0` hypothesis turned out to be
*unnecessary* for `empRad_massart` — at `n = 0` both sides collapse to `0` because
the `2^n · n` normaliser vanishes — so it was dropped, yielding a strictly more
general statement.

---

## Direction 1 — Talagrand contraction in the discrete model

**Conjecture.** For any `1`-Lipschitz `φ : ℝ → ℝ` with `φ 0 = 0`, the class
`V.image (fun v => fun i => φ (v i))` satisfies
`empRad (φ ∘ V) ≤ empRad V`; more generally an `L`-Lipschitz `φ` gives the factor
`L`. This is the missing ingredient that turns the linear `empRad_smul` /
`empRad_depth` chain into a genuine *nonlinear* (ReLU) network bound.

The key insight is that contraction does **not** need probability: in the
`2^n`-average model it reduces to a purely combinatorial pairing inequality on
sign-flips of two coordinates, exactly the discrete shadow of the classical
comparison lemma — so it should be provable by the same `Finset.sum_bij`
involution that powered `empRad_singleton`.

Why now? We already have the homogeneity backbone (`empRad_smul`) and the
sign-symmetry toolkit; contraction is the one structural lemma that upgrades the
*linear* `C^L` story to actual ReLU networks, and it is the standard next theorem
in every textbook treatment, so the payoff is immediate and the scaffolding is in
place.

## Direction 2 — The `√L` depth improvement (Golowich–Rakhlin–Shamir)

**Conjecture.** The naive `empRad_depth` bound `C^L` is *not tight*: for an
`L`-layer network with per-layer spectral norm `≤ C`, the complexity actually
obeys `empRad ≤ c · C^L · √L / √n` rather than carrying any extra exponential in
`L`, and the `√L` (not `L`) exponent is sharp.

The key insight is that the exponential blow-up in the layer-peeling argument is
an artefact of applying the contraction bound `L` times *before* taking the
expectation; pushing the expectation inside via a single Jensen step on the whole
network's MGF — precisely the technique already encapsulated in
`empRad_mgf_bound` — replaces `L` peelings by one, trading `(·)^L` for `√L`.

Why now? `empRad_mgf_bound` is exactly the one-shot MGF device the improved proof
needs; we have it formalized and verified, so the refinement is a recombination
of existing parts rather than new analytic infrastructure.

## Direction 3 — Tightness of Massart: a matching lower bound

**Conjecture.** Massart's `empRad_massart` upper bound is order-optimal: there is
a family of classes `V` with `|V| = M`, every vector of norm `B`, for which
`empRad V ≥ c · B · √(log M) / n` for an absolute constant `c > 0`. A natural
candidate is the rows of a Hadamard matrix (mutually orthogonal `±1` vectors).

The key insight is that for an orthogonal `±1` design the supremum
`max_v ⟨σ, v⟩` concentrates at `≍ √(n log M)`, so the average over sign patterns
cannot be much smaller than the upper bound — meaning the `√log` factor in
`empRad_massart` is genuine and not a proof artefact.

Why now? An adversarial-ground-truth cycle should always pair an upper bound with
its lower bound; the discrete `2^n`-average model makes "for a specific `V`"
lower bounds *computable*, so the conjecture is directly falsifiable by `#eval`
on small Hadamard classes before any proof is attempted.

## Direction 4 — Bridging `empRad` into the PAC-Bayes risk bounds

**Conjecture.** The complexity term in `mcAllesterBound`
(`MachineLearning/PACBayes/Bounds.lean`) can be *instantiated* by `empRad`:
there is a formal theorem of the form `trueRisk ≤ empRisk + empRad V + lower-order`,
closing the loop between the two files so that the PAC-Bayes `h_change_of_measure`
hypothesis is *discharged*, not merely assumed, for finite classes.

The key insight is that both files secretly compute the same object — a uniform
deviation of empirical from true risk — and the symmetrization identity
`E[sup (R̂ − R)] ≤ 2 · empRad` is the exact hinge that converts our concrete
`empRad` bound into the abstract `h_change_of_measure` premise the PAC-Bayes
theorems currently take as input.

Why now? The PAC-Bayes theorems already exist but stand on an *unproved*
probabilistic hypothesis; we now have a fully proved complexity bound to feed
them, so this is the cross-domain synthesis that makes the project's ML stack
end-to-end rigorous rather than conditional.

## Direction 5 — Massart over arbitrary semirings / `ℤ`-modules

**Conjecture.** The homogeneity and monotonicity half of this theory
(`empRad_smul`, `empRad_mono`, `empRad_singleton`) transfers verbatim to the
algebraic hypothesis classes of `MachineLearning/Foundations.lean`
(`AlgebraicHypothesisClass` over a module `M`), while Massart's `√log` bound
requires *exactly* an order-Archimedean and a sub-Gaussian valuation — and fails
over a non-Archimedean (e.g. `p`-adic) valuation.

The key insight is that of the five core results, only `empRad_massart` and
`empRad_mgf_bound` use analysis (the `cosh`/`exp` convexity); the rest are
order-theoretic and module-linear, so the *exact* boundary between "what survives
abstraction" and "what needs ℝ" is the convexity of `exp` — making this a clean
falsifiable demarcation.

Why now? `Foundations.lean` already poses algebraic learning theory but proves no
generalization bound; we can now state precisely which of our theorems lift and
construct the `p`-adic counterexample that shows the analytic ones do not,
turning a vague "more general framework" into a sharp theorem-with-counterexample.
