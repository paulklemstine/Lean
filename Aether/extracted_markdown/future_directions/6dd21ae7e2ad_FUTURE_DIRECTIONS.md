# Future Directions — Tropical Systolic Distance Bounds for Expander Quantum Codes

## Synthesis

The grand conjecture motivating this cycle — that bounded-degree hypergraph products of
2-dimensional simplicial complexes with sufficient cosystolic expansion have a strictly
positive circuit-level fault-tolerance threshold, bounded below by an explicit monotone
function of the systolic expansion constants — is a multi-stage program: (geometry) ⇒
(distance) ⇒ (decoder) ⇒ (percolation/threshold). This cycle deliberately attacked the
*first arrow* and made it completely rigorous, and it did so inside the tropical / min-plus
semiring rather than in ad-hoc combinatorics.

Concretely, `Distance.lean` proves, sorry-free, that:

1. Hamming distance `d(A,B) = |A ∆ B|` on `𝔽₂` cochains (support model) is a genuine
   **min-plus metric** (`hamming_self_zero`, `hamming_comm`, `hamming_subadditive`,
   `hamming_triangle`). This is the metric whose infima a tropical semiring computes —
   it is the bridge from `Tropical.MinPlusAlgebra`'s `(ℝ, min, +)` theory to coding theory.
2. Codewords are exactly the **cocycles** of the syndrome coboundary map
   (`isCodeword_iff_syndrome_eq_empty`); the empty support is always a codeword
   (`empty_isCodeword`).
3. **Unique-neighbour expansion kills light nonzero codewords** (`codeword_weight_gt`):
   a unique neighbour is a check seeing exactly one (odd!) active bit, contradicting the
   even-parity definition of a codeword. This is the Sipser–Spielman bound in cosystolic
   form — the precise place where *expansion becomes distance*.
4. Hence the **tropical code distance** `tropDistance` (a min-plus infimum in `WithTop ℕ`)
   is `≥ k+1` (`tropDistance_lower_bound`), and the **CSS distance** — realised as the
   tropical *sum* `min` of the two sectors — is `≥ min kX kZ + 1`
   (`cssDistance_lower_bound`).

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `hamming_triangle` | `d(A,C) ≤ d(A,B) + d(B,C)` | proved |
| `hamming_subadditive` | `\|A ∆ B\| ≤ \|A\| + \|B\|` | proved |
| `isCodeword_iff_syndrome_eq_empty` | codeword ⇔ empty syndrome | proved |
| `codeword_weight_gt` | unique-neighbour expansion ⇒ no light codeword | proved |
| `tropDistance_lower_bound` | expansion ⇒ tropical distance `≥ k+1` | proved |
| `cssDistance_lower_bound` | CSS distance `≥ min kX kZ + 1` | proved |

All depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Bold, Falsifiable Research Directions

### Direction 1 — A min-plus *quantitative* Cheeger inequality with an explicit constant

We proved a threshold-scale bound (`card ≤ k ⇒ unique neighbour`). The next step is the
genuine isoperimetric statement: define the coboundary expansion constant
`h = inf_{S ≠ cocycle} |syndrome S| / dist(S, cocycles)` in `ℚ`, and prove a two-sided
linear bound `c₁ · h ≤ (systolic distance / n) ≤ c₂ · h` for an explicit family. **The key
insight is** that `dist(S, cocycles)` is itself a tropical infimum, so both the numerator
and denominator of `h` live in the same min-plus metric and the inequality becomes a
statement about tropical Lipschitz constants of the coboundary map, exactly the
`inf`-Lipschitz machinery already proved in `Tropical.MinPlusAlgebra`. **Why now?** The
metric (`hamming_triangle`) and the cocycle characterisation
(`isCodeword_iff_syndrome_eq_empty`) are in place, so `dist(·, cocycles)` is now a
well-defined `WithTop ℕ`-valued function we can take infima over. Falsifiable: exhibit a
bounded-degree family where the measured `h` stays above a constant but the systolic
distance is sublinear in `n`.

### Direction 2 — Tropical multiplicativity of distance under the hypergraph (tensor) product

We modelled CSS distance as a tropical *sum* (`min`) of two independently-given sectors.
The deeper structural claim is that for the *hypergraph product* `C₁ × C₂` the X- and
Z-sector distances are governed by the factor distances via min-plus arithmetic:
`d_X(C₁ × C₂) = d(C₁) ⊙ 1` and `d_Z = 1 ⊙ d(C₂)` (tropical product = ordinary `+` of
log-weights), so the overall distance is `min(d(C₁), d(C₂))`. **The key insight is** that
the tensor structure of the chain complex turns the *additive* combinatorics of supports
into *tropical multiplication*, so distance behaves like a tropical determinant/permanent of
the factor data. **Why now?** `cssDistance` already packages the two sectors as a min-plus
combination; the only missing ingredient is a Lean model of the product incidence
`nbhd₁ ⊗ nbhd₂`, which can reuse `Finset` products directly. Falsifiable: a product family
whose measured distance deviates from `min(d₁, d₂)` by more than a constant factor.

### Direction 3 — Decoder correctness from expansion (the flip/peeling decoder)

Turn the *existence* bound (`codeword_weight_gt`) into a *constructive* one: prove that the
bit-flip decoder corrects every error of weight `< k/2` whenever the Tanner graph has
`(k, 3/4)`-expansion, by showing each flip strictly decreases an unsatisfied-check potential.
**The key insight is** that the potential function (number of unsatisfied checks) is again a
tropical/min-plus quantity, and unique-neighbour expansion guarantees a *frustrated* bit at
every non-codeword configuration, giving a monotone descent — a discrete tropical gradient
flow. **Why now?** The syndrome map and its cocycle kernel are already formalised, so the
"unsatisfied check set" is literally `syndrome nbhd (error ∆ guess)`. Falsifiable: a family
satisfying the expansion hypothesis on which greedy flipping stalls above weight `k/2`.

### Direction 4 — From distance to a positive threshold under independent bit-flip noise

With a correct decoder (Direction 3), prove the *logical* error probability decays:
`P_fail(p) ≤ (c·p)^{k/2}` for `p` below an explicit `p*`, under i.i.d. bit-flip noise, so the
threshold is bounded below by an explicit monotone function of the expansion constant. **The
key insight is** that the failure event requires an error pattern of weight `≥ k/2` that
fools the decoder, and a union bound over such patterns is controlled precisely by the
distance lower bound proved here — distance enters the exponent. **Why now?** `WithTop ℕ`
distance bounds make the exponent `k/2` a verified quantity; combining with Mathlib's
existing binomial/`tsum` tail estimates closes the analytic step. Falsifiable: a family with
the expansion hypothesis whose simulated logical error rate fails to decay with `n` below the
predicted `p*`.

### Direction 5 — Lifting to genuine 2-dimensional cosystolic expanders (the topology)

Replace the abstract Tanner incidence with the boundary maps `∂₂, ∂₁` of an actual
2-dimensional simplicial complex, and prove that *cosystolic* expansion (in the sense of
Linial–Meshulam / Kaufman–Kazhdan–Lubotzky) implies the unique-neighbour-style hypothesis
used here, so that all four downstream theorems apply to the standard high-dimensional
expander constructions. **The key insight is** that the parity obstruction
(`codeword_weight_gt`) is the `𝔽₂`-Bockstein shadow of the real-valued cosystolic norm, so
the same Even/Odd contradiction is the combinatorial core of the analytic expansion estimate.
**Why now?** With the `𝔽₂` chain-level theory verified, the remaining work is to connect a
Mathlib `SimplicialComplex`/chain-complex boundary map to our `syndrome` map — a definitional
bridge rather than new mathematics. Falsifiable: a bounded-degree 2-complex family with
cosystolic expansion `≥ c` whose induced code has sublinear distance.
