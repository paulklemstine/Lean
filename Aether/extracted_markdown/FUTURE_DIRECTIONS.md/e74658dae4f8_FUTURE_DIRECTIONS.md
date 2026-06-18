# Future Directions: Entropy-Bounded Computation (EBC)

## Synthesis

This cycle treated the catalog's `Computation/EntropyBridge.lean` not as a finished
artifact but as an *axiom system for a computation theory*. EntropyBridge had
already distilled the source-coding and data-processing inequalities into their
finite combinatorial skeletons (`EntropyBound`, `support_entropy_comp_monotone`,
`support_entropy_monotone_under_map`, `card_range_le_card_codomain`). The missing
piece was *dynamics*: what happens to entropy when a deterministic update map is
**iterated**, and how the static entropy budget behaves as an algebra.

We closed that gap in `Computation/EntropyBoundedComputation.lean`. The central new
result, `reachable_entropy_nonincreasing`, promotes the catalog's one-step data
processing inequality to the iterated statement `|range f^[n+1]| ≤ |range f^[n]|`:
a deterministic computation can never increase reachable-state entropy. Around it
we built the *budget algebra* (`entropyBound_mono`, plus `entropyBound_sum` — the
coproduct companion to EntropyBridge's product law) and a genuinely cross-domain
bridge, `fib_residue_entropy_le_log`, showing the Fibonacci recurrence mod `m`
carries at most `log₂ m` bits of state entropy — connecting the
`Speculative/AutoResearch` Fibonacci entry-point line to the `Computation`
framework with zero number theory.

In parallel we discharged the open `sorry` in
`Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`:
`fibEntryPt_mul_coprime`, the **lcm law** `α(a·b) = lcm(α a, α b)` for coprime
moduli. This is the multiplicative engine that lets entry points of composite
moduli be reconstructed from those of prime powers, and it completes the
entry-point characterization package.

## Results Summary

- `reachable_entropy_nonincreasing` — iterated data-processing inequality for any
  `f : α → α` (sorry = 0).
- `reachable_entropy_le_card`, `reachable_entropyBound` — the reachable set never
  exceeds the state space and inherits its entropy budget (sorry = 0).
- `entropyBound_mono`, `entropyBound_sum` — the entropy budget is monotone and
  disjoint-union-subadditive (sorry = 0).
- `fib_residue_range_card_le`, `fib_residue_entropy_le_log` — the Fibonacci-residue
  dynamical system obeys an EBC entropy bound (sorry = 0).
- `fibEntryPt_mul_coprime` — the lcm law for Fibonacci entry points, previously an
  open `sorry`, now fully proved (sorry = 0).

All results were verified to use only `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Strict entropy collapse and the eventual-image plateau

`reachable_entropy_nonincreasing` is a *weak* (non-strict) monotonicity. The
conjecture is sharper: for `f : α → α` on a finite type, the sequence
`n ↦ |range f^[n]|` is strictly decreasing **until** it hits the cardinality of the
eventual image `⋂ₙ range f^[n]`, after which it is constant, and the plateau is
reached by step `n = |α|`. Falsifiable: exhibit an `f` whose reachable-cardinality
sequence drops *after* step `|α|`, or one that decreases then increases.
*The key insight is* that on a finite set the restriction of `f` to its eventual
image is a bijection (a permutation of the recurrent states), so entropy can only
be lost during the transient and never on the periodic core. *Why now?* We already
have the monotone scaffold and the catalog's `card_range_le_card_codomain`; the
only new ingredient is the eventual-image fixed point, which Mathlib supports via
`Function.iterate` lemmas — making this an incremental, high-confidence extension.

### 2. A quantitative (logarithmic) Landauer bound per irreversible step

Upgrade the qualitative `reachable_entropy_nonincreasing` to a *budgeted* form:
each step that is not injective on the current reachable set strictly lowers the
log-cardinality, so the number of genuinely irreversible steps in `f^[n]` is at
most `Nat.log 2 |α|`. Falsifiable: produce an `f` and `n` with more than
`log₂ |α|` strictly-collapsing steps among the first `n`. *The key insight is*
that every strict drop at least halves nothing in general — but each *distinct*
log-floor value can be occupied only once by a strictly decreasing integer
sequence bounded below, capping the count by the initial log-cardinality.
*Why now?* `entropyBound_mono` and `Nat.log_mono_right` (already used in
`fib_residue_entropy_le_log`) give exactly the discrete-log machinery needed to
count level crossings.

### 3. Pisano-period entropy: the Fibonacci bridge made exact

`fib_residue_entropy_le_log` bounds the Fibonacci-residue entropy by `log₂ m`, but
the true number of distinct residues is governed by the **Pisano period** `π(m)`
and, via the now-proved `fibEntryPt_mul_coprime`, by the entry point `α(m)`.
Conjecture: the count of distinct Fibonacci residues mod `m` equals
`min(π(m), N)` over a window `Fin N`, and for `N ≥ π(m)` the exact state entropy is
`log₂ |{F(k) mod m}|`, which is multiplicative over coprime `m` exactly as
`α` is (`α(ab) = lcm(α a, α b)`). Falsifiable: find coprime `a, b` where the residue
count mod `ab` differs from the product/lcm prediction. *The key insight is* that
the lcm law for entry points is the additive-order shadow of a CRT decomposition of
the residue dynamics, so the entropy of the product system should decompose along
the same lcm. *Why now?* `fibEntryPt_mul_coprime` was the missing multiplicative
lemma; with it proved this cycle, the exact-entropy refinement becomes reachable.

### 4. Entropy of products under correlated (non-coprime) coupling

EntropyBridge's `entropyBound_prod_of_entropyBound` and our `entropyBound_sum` are
both *worst-case* (they assume independence/disjointness). Conjecture a *strict
subadditivity* witness: when two finite systems share state (a surjection
`α → γ` and `β → γ` onto a common quotient), the joint reachable entropy is
strictly below `H(α) + H(β)` by at least `log₂ |γ|`, the mutual-information
analogue. Falsifiable: a coupled pair whose joint log-cardinality exceeds
`H(α) + H(β) − log₂ |γ|`. *The key insight is* that the fiber product
`{(a,b) | q a = q b}` has cardinality controlled by `card_range_le_card_codomain`
applied to the shared quotient, turning correlation into a measurable cardinality
deficit. *Why now?* The product and coproduct budget laws are both in hand, so the
correlated case is the natural — and currently missing — third corner.

### 5. EBC for compressors: a dynamical strengthening of the bridge theorem

The catalog's `complexity_bound_implies_finite_entropy_bound` is static. Conjecture
its dynamical form: if an `InvertibleCompressor` `C` certifies compressed length
`≤ k` for the reachable set of a deterministic system `f : α → α`, then *every*
iterate's reachable set stays within the `k`-bit budget, and the certificate need
only be checked on the eventual image (direction 1). Falsifiable: a compressor and
system where some iterate escapes the certified budget. *The key insight is* that
`reachable_entropyBound` already shows entropy budgets are forward-invariant under
`f`, so a compression certificate, being an entropy upper bound, must be
forward-invariant too. *Why now?* This cycle proved exactly the forward-invariance
lemma (`reachable_entropyBound`) that the compressor certificate needs, closing the
loop between the EntropyBridge compressor layer and the new EBC dynamics layer.
