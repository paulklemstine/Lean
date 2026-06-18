# Future Directions — Information-Theoretic Limits of Proof Search

These conjectures extend `Catalog/Computation/ProofSearchLimits.lean`, which proves
that the set of theorems certifiable within a proof-length budget `L` over an
alphabet of size `a` has size `Θ(aᴸ)`, yielding a counting limit, an
incompressibility theorem, a logarithmic proof-length lower bound, vanishing
provability density, and matching tightness. The following are bold, falsifiable
targets for the next cycle. Each is stated so a Lean formalization can either prove
it or exhibit a counterexample.

## C1. Two-sided length spectrum (`Θ`-law for theorem counts)
**Conjecture.** Define `N(a, L)` = the maximum number of distinct statements a
budget-`L` verifier can certify. Then for all `a ≥ 2`, `L ≥ 0`,
`aᴸ ≤ N(a, L) = (a^(L+1) − 1)/(a − 1) < a^(L+1)`, and moreover the *minimum* budget
to certify `N` distinct theorems is exactly `⌈log_a(N(a−1)+1)⌉ − 1`. The current file
proves the bounds and tightness up to the geometric factor; this sharpens
`length_lower_bound` to an exact identity via `Nat.geomSum_eq`.
*Falsifier:* a verifier certifying `≥ a^(L+1)` statements within budget `L`.

## C2. Compositional budget superadditivity
**Conjecture.** If statement `s₁` needs budget `L₁` and `s₂` needs budget `L₂` under a
fixed verifier closed under a binary "combine" rule, then the conjunction `s₁ ∧ s₂`
needs budget `≤ L₁ + L₂ + c` for a constant `c` independent of the statements, but
there exist families where it needs `≥ max(L₁, L₂)`. Formalize "combine-closed"
verifiers and prove the additive upper bound; conjecture the lower bound is generally
*not* additive (no `Ω(L₁ + L₂)` lower bound), i.e. proof search can amortize.
*Falsifier:* a combine-closed family with conjunction budget `> L₁ + L₂ + c` for every `c`.

## C3. No-free-lunch for verifiers (averaging bound)
**Conjecture.** Averaged uniformly over all verifiers `check : BoundedProof a L → S`
with `|S| = M`, the expected number of distinct certified statements is
`M·(1 − (1 − 1/M)^K)` where `K = card (BoundedProof a L) = Θ(aᴸ)`, hence `≈ M` once
`K ≳ M ln M` (coupon-collector regime) and `≈ K` when `K ≪ M`. Consequence: *no*
verifier-design strategy beats the counting limit on average — cleverness only helps
on structured statement spaces. Formalize via `Finset` expectation over the function
space `(BoundedProof a L → Fin M)`.
*Falsifier:* an averaged count exceeding `min(M, K)` asymptotically.

## C4. Robustness of the wall under nondeterministic/parallel search
**Conjecture.** Allowing `w` parallel verifier passes (a "width-`w`" search) multiplies
the reachable theorem count by at most `w`: `N_w(a, L) ≤ w · N(a, L)`, so width gives
only polynomial savings while budget gives exponential — the wall is in `L`, not in
parallelism. Formalize width-`w` search as `Fin w → BoundedProof a L` and prove the
image-count bound `≤ w · (a^(L+1) − 1)/(a − 1)`.
*Falsifier:* a width-`w` scheme certifying `> w · N(a, L)` statements.

## C5. Density phase transition vs. statement length
**Conjecture.** If statements are themselves strings of length `≤ m` over an alphabet
of size `b` (so `|S| = Θ(bᵐ)`), the provable fraction within budget `L` is
`Θ(aᴸ / bᵐ)`. Hence there is a sharp threshold: for `L < (m log b)/(log a)` almost no
statement is provable (density → 0), and the regime `L ≈ (m log b)/(log a)` is the
critical line where provability density is `Θ(1)`. Formalize the length-indexed
statement universe and prove the `aᴸ/bᵐ` density law, then locate the threshold.
*Falsifier:* nonvanishing density below the critical line, or vanishing density above it.
