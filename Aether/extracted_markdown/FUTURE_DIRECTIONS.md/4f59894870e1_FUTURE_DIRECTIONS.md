# Future Directions — Expected Rademacher Complexity over the Boolean Hypercube

## Synthesis

This cycle replaced *fixed* Rademacher sign vectors with the genuinely **expected**
empirical Rademacher complexity, realised as a finite average over the Boolean
hypercube `Fin n → Bool` (cardinality `2^n`). No measure theory is invoked: the
expectation is an arithmetic mean over `Finset.univ`. The conceptual spine is a
**duality**: a Rademacher sign vector is a character of `(ℤ/2)^n`, and averaging over
signs is a pairing against the uniform measure on the dual group. The decisive
structural fact is the **sign-flip involution** `b ↦ ¬b`, which negates every
correlation and therefore forces the *raw* correlation to average to zero
(`sum_rademacherCorrelation_eq_zero`). Every downstream estimate — the singleton
collapse, nonnegativity, monotonicity, and the Massart-type upper bound — is an
elementary consequence of either this involution or the pointwise `|·| ≤ B` bound
transported through `Finset.sup'`.

## Results Summary (file: `Catalog/MachineLearning/RademacherExpectation.lean`)

- `rademacher_correlation_bounded` — `|corr(σ, h)| ≤ B` whenever each `|hᵢ| ≤ B`.
- `sum_rademacherCorrelation_eq_zero` — **the duality identity**: the correlation of
  any fixed hypothesis, summed over all `2^n` sign patterns, is exactly `0`.
- `expectedRademacher_singleton_eq_zero` — a singleton class has exactly zero
  expected complexity; it cannot fit random sign labels.
- `expectedRademacher_nonneg` — classes containing `0` have nonnegative complexity.
- `expectedRademacher_mono` — complexity is monotone in the hypothesis class.
- `expectedRademacher_le_bound` — the basic upper bound `R_n(H) ≤ B`.

All proofs are complete (`sorry = 0`) and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

---

## Direction 1 — Massart's logarithmic refinement of the upper bound

The current upper bound `expectedRademacher H hne ≤ B` is tight for a single
hypothesis only in the worst case; for a finite class of cardinality `m` the truth
is dramatically smaller: `R_n(H) ≤ B · √(2 ln m) / √n`. Conjecture: replacing the
crude `Finset.sup'_le ≤ B` step with an exponential-moment (Hoeffding) argument
yields exactly this `√(ln m)` dependence, and the bound is asymptotically tight on
the class of all `±B` label vectors. **The key insight is** that the supremum over a
finite class, after passing through `exp(λ·)`, turns into a *sum* over the class, so
the union bound becomes `Finset.sum_le_card_nsmul` and the only analytic input is the
sub-Gaussian MGF of a single `±1`-weighted coordinate. **Why now?**
`rademacher_correlation_bounded` already supplies the coordinatewise `B`-bound that
Hoeffding's lemma consumes, and `sum_rademacherCorrelation_eq_zero` shows the mean is
zero, which is the centring hypothesis Hoeffding requires.

## Direction 2 — Lipschitz contraction (Talagrand) on the hypercube

For a `1`-Lipschitz map `φ : ℝ → ℝ` with `φ(0) = 0`, the expected complexity of
`φ ∘ H` should not exceed that of `H`: `R_n(φ ∘ H) ≤ R_n(H)`. Conjecture: a fully
finite, hypercube-indexed contraction principle holds, and ReLU (`x ↦ max x 0`) is the
canonical instance with constant `1`. **The key insight is** that the contraction can
be proved one coordinate at a time using the *same* sign-flip involution already
formalised: pairing `b` with the bit-flip of a single coordinate reduces the Lipschitz
inequality to the scalar fact `|φ(a) − φ(a')| ≤ |a − a'|`. **Why now?** The involution
machinery in `sum_rademacherCorrelation_eq_zero` is exactly the per-coordinate symmetry
the contraction proof needs, and `expectedRademacher_mono` shows the supremum-based
quantity behaves monotonically under the class operations involved.

## Direction 3 — Inductive multi-layer (spectral) composition bound

For an `L`-layer linear network with per-layer operator-norm bounds `C₁,…,C_L` and
`1`-Lipschitz activations between layers, conjecture that the sum of squared output
correlations is bounded by `(∏ₗ Cₗ²)` times the sum of squared input correlations.
**The key insight is** that this is a clean induction on `L` mapping onto `Nat.rec`:
each step composes a single spectral bound with the Direction-2 contraction, so the
product `∏ Cₗ²` accumulates multiplicatively with no cross terms. **Why now?** Direction
2 supplies the activation step and the single-layer correlation bound is the `L = 1`
base case; the only missing piece is a Cauchy–Schwarz packaging of correlations into an
`ℓ²` quantity, which is purely `Finset.inner_mul_le_norm_mul_norm`.

## Direction 4 — Generalization gap via symmetrization

Define empirical and ghost-sample risks over a finite data distribution and conjecture
the symmetrization inequality `E[sup_{h∈H} |R(h) − R̂(h)|] ≤ 2 · R_n(H)`. **The key
insight is** that, for a *finitely supported* data law, swapping a real sample point
with its independent ghost copy is literally the action of one coordinate of the
sign-flip involution already formalised — so the classical measure-theoretic
symmetrization collapses to a re-indexing of a finite sum. **Why now?** The duality
identity `sum_rademacherCorrelation_eq_zero` is precisely the `H = {h}` shadow of the
symmetrization bound, and the pointwise bound `rademacher_correlation_bounded` gives the
two-sided control needed to pass from `sup` of a difference to `2 · R_n(H)`.

## Direction 5 — PAC-Bayes bridge through KL divergence on the hypercube

Bridge the present Rademacher framework to the existing `MachineLearning.PACBayes`
results by defining KL divergence of two distributions over a finite hypothesis set
via `Finset.sum` and `Real.log`, and conjecture `E_Q[R(h)] ≤ E_Q[R̂(h)] +
√((KL(Q‖P) + ln(n/δ)) / (2(n−1)))`. **The key insight is** that the `ln m` term of
Massart's lemma (Direction 1) is the special case `KL(uniform‖uniform) = ln m`, so the
finite-class bound and the PAC-Bayes bound are two evaluations of one divergence
functional. **Why now?** The catalog already contains the McAllester/Catoni
variational inequalities (`pac_bayes_mcallester_bound`), and the expected-complexity
scaffolding here provides the empirical-risk side those bounds quantify over a *finite*
hypothesis set, making the two formalizations directly composable.
