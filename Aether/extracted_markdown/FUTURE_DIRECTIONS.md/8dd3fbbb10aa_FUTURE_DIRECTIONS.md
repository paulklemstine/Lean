# Future Directions — Theorems as Phase Transitions in Proof Space

Companion file: `Catalog/Pythagorean/ProofSpacePhaseTransition.lean`

## Synthesis

This cycle turned a purely metaphorical slogan — "major theorems are phase transitions in
proof space" — into a small but fully rigorous, `sorry`-free Lean theory. The move that made
the metaphor tractable was to stop trying to formalize *which* statements are provable and
instead formalize only the **counting asymmetry** between the two populations: the full
statement space over a `k`-symbol alphabet grows exponentially (`totalStmts k n = ∑_{i≤n} k^i`,
with closed form `totalStmts·(k-1)+1 = k^{n+1}`), while the *provable* population is assumed
only to grow polynomially. Defining the order parameter `ρ(n) = P(n)/totalStmts k n` as the
provability density, the whole "phase transition" reduces to the elementary fact that a
polynomial divided by an exponential vanishes. We proved `ρ(n) → 0` (`orderParameter_tendsto_zero`),
extracted the explicit critical cutoff `n_c(ε)` (`godel_threshold_exists`), and — the most
informative result — showed the collapse is **super-polynomial** (`transition_super_polynomial`):
`(n+1)^m · ρ(n) → 0` for *every* `m`.

The structural insight that emerged is a sharp dichotomy between two notions of "power law"
that the original concept conflated. The *order parameter* (provability density) does **not**
follow a power law — its decay beats every polynomial, the signature of a first-order-like
transition rather than a critical one. Yet a power law *can* live in a different object: the
**length spectrum** itself. We proved (`length_spectrum_powerlaw_critical`) that a power-law
length distribution `n^{-s}` is normalizable iff `s > 1`, pinning the critical exponent at
`s_c = 1`, the natural "Hausdorff-dimension-like" boundary of the spectrum. So the concept's
two predictions — a sharp transition and a power-law spectrum — are not the same phenomenon;
they are governed by two different critical objects, and conflating them was the latent error.

What failed / was deliberately weakened: we do not (and provably cannot, with these
hypotheses alone) obtain a *non-trivial* limiting value for `ρ` — once the provable count is
sub-exponential, the only fixed point is `0`. A genuine "two-phase" picture with a non-zero
high-temperature density requires the provable population to be a *constant fraction* of the
total, i.e. exponential provable growth. That boundary case (below) is exactly where the
present proof breaks and is the most promising lever for the next cycle.

## Results Summary

- `totalStmts_closed_form`: proved — the statement space has the exact geometric size `k^{n+1}` (via `(k-1)`), the exponential growth that drives everything else.
- `totalStmts_ge_pow` / `totalStmts_pos`: proved — supporting growth/positivity facts isolating `k^n ≤ totalStmts k n`.
- `aux_poly_exp`: proved — the analytic engine: `C·(n+1)^d / k^n → 0` (polynomial over exponential), reduced to Mathlib's `tendsto_pow_const_div_const_pow_of_one_lt` via an index shift.
- `orderParameter_le`: proved — uniform squeeze bound `ρ(n) ≤ C·(n+1)^d / k^n`.
- `orderParameter_tendsto_zero`: proved — **the phase transition**: provability density collapses to `0` under any polynomial provability bound.
- `godel_threshold_exists`: proved — existence of the explicit critical cutoff `n_c(ε)` (Gödel threshold) past which `ρ < ε`.
- `transition_super_polynomial`: proved — **sharpness**: `(n+1)^m·ρ(n) → 0` for all `m`, so the transition is faster than any power law (not a critical/power-law transition).
- `length_spectrum_powerlaw_critical`: proved — a power-law length spectrum `n^{-s}` is normalizable iff `s > 1`; critical exponent `s_c = 1`.

## Research Directions

### Direction 1: The genuine two-phase order parameter (exponential provable growth)
**Hypothesis**: If the provable count satisfies `α·a^n ≤ P(n) ≤ β·a^n` with `1 < a < k`, then
`ρ(n) → 0` still, but if `a = k` (provable density a constant fraction), then `ρ(n)` converges
to a strictly positive limit `ρ_∞ ∈ (0,1]`, giving a true two-phase diagram with the transition
located at the *growth rate* `a`, not at a cutoff length.
**Test**: Replace the polynomial bound in `orderParameter_le` by a two-sided exponential bound
and compute `lim ρ`; disprove the positive-limit claim for `a < k` and prove it for `a = k`.
**Why now**: This cycle already isolated the exact pressure point — `totalStmts ~ k^{n+1}` and
the squeeze through `k^n` — so swapping the numerator's growth class is a localized edit to one
lemma. The key insight is that the *ratio of exponential rates* `a/k`, not the polynomial degree,
is the real control parameter, and our current theorems are the `a/k → 0` corner of that diagram.
**If true**: Yields a Lean-verified order parameter with a nontrivial critical point, matching
the physics analogy far more faithfully than the present (degenerate) collapse.
**If false**: Tells us proof-space density is *always* degenerate (only `0` or `1`), i.e. there is
no intermediate phase — itself a strong structural statement about provability counting.

### Direction 2: Finite-size scaling and the width of the Gödel threshold
**Hypothesis**: The "transition width" `w(ε) = n_c(ε) − n_c(1−ε)` grows like `Θ(log(1/ε)/log k)`,
i.e. the threshold from `godel_threshold_exists` is logarithmically sharp in the alphabet size.
**Test**: Prove explicit two-sided bounds on `n_c(ε)` from `ρ(n) ≍ C·n^d/k^n` and compare upper
(`godel_threshold_exists`) with a matching lower bound built from `orderParameter` lower estimates.
**Why now**: We have a closed-form statement count and an explicit upper squeeze, so both an
upper and a lower bound on `n_c` are within reach without new analytic machinery. The key insight
is that finite-size scaling exponents are *computable* from the geometric closed form alone.
**If true**: Converts the qualitative "threshold exists" into a quantitative scaling law — the
proof-theoretic analogue of a correlation-length exponent.
**If false**: Indicates the polynomial prefactor `n^d` materially distorts the threshold location,
flagging the prefactor (not just the exponential) as physically relevant.

### Direction 3: Spectrum ↔ density bridge via Abelian/Tauberian summation
**Hypothesis**: If the *increment* spectrum `p(n) = P(n) − P(n−1)` is asymptotically power-law,
`p(n) ≍ n^{-s}`, then the order parameter cannot vanish super-polynomially; conversely
super-polynomial decay of `ρ` forces the increment spectrum to be sub-power-law summable.
**Test**: Relate `transition_super_polynomial` to `length_spectrum_powerlaw_critical` by an
Abel-summation lemma connecting `∑ p(n)` to `P(N)`; prove the contrapositive bridge in Lean.
**Why now**: This cycle proved *both* endpoints (super-polynomial density decay and the `s_c=1`
spectrum threshold) but left them logically disjoint. The key insight is that the density and the
spectrum are Abel/Tauberian transforms of each other, so a single summation-by-parts lemma should
fuse the two main theorems into one bridge result.
**If true**: Unifies the two critical objects (`density` and `spectrum`) into a single transform
pair, the conceptual payoff the original concept was groping toward.
**If false**: Demonstrates the two "power laws" are genuinely independent invariants of proof
space, which would itself refine the concept.

### Direction 4: Multi-symbol / weighted alphabets and entropy as the control field
**Hypothesis**: Replacing the uniform `k`-symbol count by a weighted statement measure with
Shannon entropy `H` makes `totalStmts` grow like `e^{Hn}`, and the transition is governed by the
sign of `H − h_prov`, where `h_prov` is the exponential growth rate of the provable measure.
**Test**: Generalize `totalStmts` to `∑_{i≤n} e^{H i}` (or a weighted Finset sum) and re-derive
`orderParameter_tendsto_zero` with `H` in place of `log k`; locate the transition at `H = h_prov`.
**Why now**: Every proof in this cycle used `k` only through `1 < (k:ℝ)` and `k^n`, so abstracting
to an entropy rate `H > 0` is a faithful generalization with the same skeleton. The key insight is
that the alphabet size is a stand-in for an *entropy*, and entropy is the true thermodynamic field
conjugate to the order parameter.
**If true**: Recasts the whole theory in information-theoretic terms, connecting to the catalog's
`CategoricalShannon` / entropy work and opening cross-domain bridges.
**If false**: Reveals that uniformity (not mere positive entropy) is essential, narrowing the
class of "proof spaces" for which the transition picture holds.

### Direction 5: From counting bounds to a concrete proof system (making `P` real)
**Hypothesis**: For a fixed decidable proof system, the count `P(n)` of statements with a proof
of Gödel-length `≤ n` is itself polynomially bounded in `n` for bounded-depth fragments, so
`orderParameter_tendsto_zero` applies *unconditionally* to those fragments.
**Test**: Instantiate `P` with the counting function of a small explicit system (e.g. a bounded
propositional fragment) and discharge the hypothesis `∀ n, P n ≤ C·(n+1)^d` by a constructive
counting argument, removing it as an assumption.
**Why now**: The present theorems are parametric in `P`; this cycle deliberately kept `P` abstract,
so the natural next step is to *supply* a real `P` and verify the polynomial bound. The key insight
is that the abstraction boundary we drew (an arbitrary polynomially-bounded profile) is exactly the
interface a concrete proof system must meet.
**If true**: Yields an end-to-end, assumption-free instance of "provability density → 0" for an
actual formal system — the strongest possible vindication of the concept.
**If false**: The failure (a fragment whose provable count grows super-polynomially) would be a
concrete, valuable counterexample localizing where the phase-transition picture stops applying.
