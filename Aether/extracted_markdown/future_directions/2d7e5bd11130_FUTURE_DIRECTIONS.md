# Future Directions: The Thermodynamic Proof System (TPS)

## Synthesis

This cycle turned the slogan "a proof is the erasure of uncertainty" into formal
mathematics. Building directly on the catalog's sorry-free Shannon-entropy layer
(`Speculative.AutoResearch.ShannonEntropy`: `entropy`, `entropy_uniform`,
`entropy_le_log_card`), the new module
`MachineLearning.ThermodynamicProofSystem` models a proposition's possible answers
as a finite type `α` of *epistemic microstates*, a belief state as a probability
distribution `p : α → ℝ`, and a *proof* as a transition `p ⇝ q` that lowers Shannon
entropy. The energy such a transition must dissipate at temperature `T` is the
**Landauer cost** `landauerCost T p q = T·(H(p) − H(q))`.

Three classically separate worlds collapse onto one inequality, the
maximum-entropy theorem `H(p) ≤ log n`:

* **Information theory** reads it as "a distribution on `n` outcomes carries at most
  `log n` nats".
* **Thermodynamics** reads it as **Landauer's bound** `tps_landauer_bound`: proving
  any proposition over an `n`-world space costs at most `T·log n`, attained from the
  uniform prior (`tps_landauer_tight`) and counted in bits by `tps_landauer_bits`.
* **Proof complexity** reads it as a *capacity*: a decision over `n` worlds cannot
  extract more than `log₂ n` bits of certainty, the irreducible work of resolving it.

The dual principle — **Bennett's** observation that logically reversible computation
is free — appears as `reversible_entropy_invariant` / `reversible_free`: relabelling
microstates by *any* permutation leaves entropy, hence cost, exactly zero.
Reversible steps live precisely on the boundary `ΔH = 0`, separating "free"
bookkeeping from genuinely dissipative inference.

## Results Summary

`MachineLearning/ThermodynamicProofSystem.lean` — 8 theorems, `sorry = 0`,
standard axioms only:

1. `pointMass_isProbDist` — a determined (proven) state is a probability distribution.
2. `entropy_pointMass` — a proven proposition carries zero entropy (the proof endpoint).
3. `reversible_entropy_invariant` — Bennett, entropy form: bijections preserve entropy.
4. `reversible_free` — Bennett, energy form: a reversible step costs nothing.
5. `landauerCost_nonneg` — second-law flavour: uncertainty-reducing proofs never return energy.
6. `tps_landauer_bound` — Landauer capacity bound: cost ≤ `T·log n`.
7. `tps_landauer_tight` — the bound is sharp from the uniform prior: cost `= T·log n`.
8. `tps_landauer_bits` — the same cost is exactly `log₂ n` bits.

Infrastructure note: the project's root `lakefile.toml` was pointed at the actual
source root (`srcDir = "Catalog"`), so the catalog now elaborates and builds.

## Research Directions

### 1. Conditional entropy and the cost of partial proofs (data-processing law)

A real proof rarely jumps to a point mass; it *coarse-grains*, mapping the world type
`α` onto a smaller type `β` via some `f : α → β` (a lemma that "forgets" irrelevant
distinctions). Conjecture: for the pushforward distribution `f∗p`, entropy can only
drop, and the drop is exactly the conditional entropy `H(p) − H(f∗p) = H(p | f)`,
which is non-negative; equivalently `landauerCost T p (f∗p) ≥ 0` for every `f` and
`T ≥ 0`. **The key insight is** that the data-processing inequality is the *local*
form of the global Landauer bound already proved here — `entropy_le_log_card` is its
special case where `β` is a singleton. **Why now?** All the moving parts exist:
`reversible_entropy_invariant` already handles the bijective (entropy-preserving)
case, so only the genuinely many-to-one case remains, and Mathlib's
`Finset.sum_fiberwise` plus `Real.negMulLog` concavity should discharge it. This is
falsifiable: a single `f` and `p` with `H(f∗p) > H(p)` would refute it.

### 2. Subadditivity of cost over composed proofs (a proof-length metric)

Model a multi-step proof as a chain `p₀ ⇝ p₁ ⇝ … ⇝ p_k` and define its total cost as
the sum of step costs. Conjecture: total cost telescopes, `Σ landauerCost T pᵢ pᵢ₊₁ =
landauerCost T p₀ p_k`, and is therefore *path-independent* — only the entropy of the
endpoints matters. **The key insight is** that Landauer cost is an exact differential
(a potential difference in `H`), so proof "effort" is a state function, not a path
integral; clever and clumsy proofs of the same theorem dissipate the same energy.
**Why now?** With `landauerCost` and `entropy` already defined, this is a finite
telescoping sum over `List`/`Fin k` and is immediately provable; it then becomes the
base case for studying *irreversibility overhead* when steps are constrained to be
reversible. Falsifiable by exhibiting a chain whose summed cost differs from the
endpoint cost.

### 3. A spectral gap ⇒ fast entropy decay bridge to the expander catalog

The catalog already contains expander-graph machinery
(`Algebra.ClassicalGroupExpanders`, `Algebra.ExpanderWalk.Amplification`). Model a
randomized proof search as a random walk on an `n`-state expander; conjecture that a
spectral gap `1 − λ` forces the belief-state entropy to approach `log n`
geometrically, `|H(pₜ) − log n| ≤ C·λ^t`, so the Landauer cost of reaching
near-uniform mixing decays at the spectral rate. **The key insight is** that mixing
(an analytic/spectral phenomenon) and entropy production (a thermodynamic one) are the
same exponential, linking `tps_landauer_tight` to the expander amplification lemmas.
**Why now?** Both endpoints already exist in this repository — the entropy/Landauer
layer here and the expander spectral bounds in `Algebra` — so this is a *bridge*
theorem rather than new theory. Falsifiable: a gapped walk whose entropy gap fails to
contract by `λ` per step.

### 4. The reversibility frontier: minimum irreversible steps = ⌈log₂ n⌉

`reversible_free` shows permutations are free; `tps_landauer_bits` shows resolving `n`
worlds needs `log₂ n` bits. Conjecture the integer bridge: any proof that collapses
`n` equiprobable worlds to one, using only single-bit-erasing irreversible steps
interleaved with free reversible relabelling, requires at least `⌈log₂ n⌉` irreversible
steps, and this is achievable. **The key insight is** that the *continuous* Landauer
bound quantizes into a *combinatorial* lower bound on irreversible gate count — the
thermodynamic analogue of a decision-tree depth bound. **Why now?** The continuous
bound (`tps_landauer_bits`) is in hand, so the remaining work is purely a
`Nat.log 2` / `Nat.clog` counting argument against the entropy budget, well within
reach. Falsifiable by a construction using fewer than `⌈log₂ n⌉` erasures.

### 5. Thermodynamic lower bounds for the catalog's primality and Fibonacci tests

Connect TPS to the catalog's number-theoretic testers (the Miller–Rabin development in
`Speculative.PrimalityTesting`, the Fibonacci primitive-divisor / Carmichael line in
`Shared` and `Applications`). A primality test resolves the one-bit proposition
"`n` prime?"; its randomized version starts from a prior over `n−1` candidate
witnesses. Conjecture: the witness-density bound `4·|liars| ≤ n−1` is *equivalent* to
a Landauer statement — each Miller–Rabin round dissipates at least `log₂(4/3)` bits of
witness-uncertainty toward certainty, so `k` rounds buy `≥ k·log₂(4/3)` bits.
**The key insight is** that the `1/4` error constant is an entropy budget in disguise,
recasting Monier–Rabin as a thermodynamic accounting identity. **Why now?** The TPS
cost calculus is established and the Miller–Rabin liar-set definitions already exist in
the catalog (currently with open density-bound `sorry`s), so framing the bound
thermodynamically may suggest the missing counting argument. Falsifiable: a composite
`n` and round budget `k` for which the certainty gained exceeds the entropy the rounds
can supply.
