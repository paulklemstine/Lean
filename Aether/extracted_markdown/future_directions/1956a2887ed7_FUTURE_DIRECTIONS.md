# Future Directions — Landauer's Principle for Proof Compression

## Synthesis

This cycle turned the slogan *"compressing a proof erases information, and erasing
information costs heat"* into theorems. The carrier of the argument is a single,
deliberately minimal model: a length-`n` proof found by search is a path of `n`
binary decisions, hence the *uniform distribution on the `2^n` leaves* of a complete
binary tree. Its Shannon entropy is exactly `n · ln 2` nats
(`entropy_uniformProb_pow_two`). A compression to at most `2^m` configurations is an
arbitrary map `f : Fin (2^n) → Fin (2^m)`, which pushes that distribution forward.

The decisive structural observation is that the lower bound needs **no**
data-processing inequality and **no** concavity machinery. It rests on exactly two
facts that pull in opposite directions:

* the source entropy is pinned *exactly* at `n · ln 2`; and
* the image lives on `≤ 2^m` points, so the one-sided **Gibbs / maximum-entropy**
  bound `shannonEntropy_le_log_card` caps its entropy at `m · ln 2`.

Subtracting gives an erased-information floor of `(n − m) · ln 2`, hence a dissipated
heat of at least `k·T·(n − m)·ln 2` (`landauer_compression_lower_bound`) — a bound
*independent of `f`*, and therefore independent of the proof system. The bound is not
slack: the residue map `i ↦ i mod 2^m` equalizes all fibers, pushes uniform to
uniform, and attains it exactly (`landauer_compression_tight`). The worked example
(`compression_cost_1000_to_100`) instantiates the floor as `900 · k·T·ln 2` for a
1000-step proof compressed to 100 steps.

The Gibbs lemma itself was factored to its irreducible core: `log x ≤ x − 1` summed
against the distribution is relative entropy `≥ 0`, with the only subtlety being the
`0·log 0` convention handled by a case split. This is the reusable building block.

## Results Summary

| Theorem | Statement |
|---|---|
| `shannonEntropy_uniformProb` | `H(uniform on N points) = log N` |
| `shannonEntropy_le_log_card` | Gibbs bound: any distribution on `N` points has `H ≤ log N` |
| `entropy_uniformProb_pow_two` | an `n`-bit proof tree has entropy `n · ln 2` |
| `landauer_compression_lower_bound` | any compression `2^n → 2^m` dissipates `≥ k·T·(n−m)·ln 2` |
| `landauer_compression_tight` | the residue map attains the bound exactly |
| `compression_cost_1000_to_100` | worked instance: `≥ 900·k·T·ln 2` |
| `residueMap_fiber_card` | each residue fiber has exactly `2^(n−m)` points |
| `residueMap_pushforward_uniform` | the residue map sends uniform to uniform |

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`. The development extends `Catalog.Computation.LandauerLowerBound` (the
deterministic data-processing inequality `H(f∗p) ≤ H(p)`) by supplying the matching
*upper* bound (Gibbs) and pinning the extremal constants for the proof-tree case.

## Research Directions

### 1. Strict-loss refinement: compression is *strictly* dissipative unless trivial
The current floor is tight only for fiber-balanced maps. Conjecture: for any
*non-injective* compression `f` with image of size `s`, the dissipated heat is at
least `k·T·(log(2^n) − log s)`, and strictly above the naive `(n−m)·ln 2` floor
whenever the fibers are *unequal*, with the gap equal to `k·T` times the
Kullback–Leibler divergence of the pushforward from uniform. **The key insight is**
that the slack in Gibbs' inequality is *exactly* `D(f∗p ‖ uniform)`, so measuring
fiber imbalance measures wasted-versus-recoverable heat. **Why now?** We already have
`shannonEntropy_le_log_card` whose proof literally computes `log N − H = D(p‖u)`;
exposing that intermediate quantity as a named lemma turns a one-sided bound into an
equality and is a small, self-contained next step.

### 2. Sub-additivity of erasure cost under sequential compression
Model a two-stage compression `2^n → 2^m → 2^ℓ` and conjecture that the total
dissipated heat is *at least* that of the direct compression `2^n → 2^ℓ`, with
equality iff each stage is fiber-balanced. **The key insight is** that pushforward is
functorial (`pushforward (g ∘ f) = pushforward g ∘ pushforward f` on distributions),
so entropy drops telescope and never under-count the single-shot erasure. **Why now?**
The `pushforward` operator and `dissipatedHeat` are already defined; proving the
composition law for `pushforward` is a clean combinatorial lemma (fiber-of-fiber
regrouping) that immediately yields the telescoping inequality.

### 3. Beyond binary trees: `d`-ary proof search and the `ln d` quantum
Replace the branching factor `2` by an arbitrary `d ≥ 2`: a depth-`n` `d`-ary search
tree carries `n · ln d` nats, and compressing to depth `m` should dissipate
`≥ k·T·(n−m)·ln d`. **The key insight is** that every theorem here used only
`Real.log_pow` and `Fintype.card_fin (d^n)`, never the value `2`, so the entire
development generalizes by replacing `Nat.two_pow_pos` with `pow_pos`. **Why now?**
This is the cheapest possible generalization that materially broadens scope (it covers
`k`-SAT branching, tableau calculi, and resolution with `d` clauses), and it isolates
`ln d` as the proof-theoretic analogue of the Landauer quantum `kT ln 2`.

### 4. A reversibility dividend: Bennett-style uncomputation of proof search
Conjecture that the lower bound can be *evaded* exactly when the compression is
implemented reversibly, i.e. by retaining a `Fin (2^(n−m))` "garbage" register so the
combined map `Fin (2^n) → Fin (2^m) × Fin (2^(n−m))` is injective; then dissipated
heat is `0`, recovering Bennett's logical reversibility in the proof-compression
setting. **The key insight is** that `residueMap` paired with the quotient map
`i ↦ i / 2^m` is *exactly* the bijection witnessing `Fin (2^n) ≃ Fin (2^m) × Fin (2^(n−m))`
already implicit in `residueMap_fiber_card`. **Why now?** The fiber-counting bijection
is built; promoting it to a stated `Equiv` and feeding it through
`landauer_lower_bound_zero_of_injective` from the catalog closes the loop between the
*lower bound* (irreversible) and the *zero-cost* (reversible) regimes.

### 5. From bits to time: a Margolus–Levitin speed limit on proof compression
Pair the *energetic* floor with a *temporal* one: if compression dissipates at least
`E = k·T·(n−m)·ln 2`, then a physical compressor operating at average energy `E` needs
at least `π ħ / (2 E)` seconds, giving a temperature-independent *time* lower bound
`≥ π ħ / (2 k T (n−m) ln 2)` per compression. **The key insight is** that the same
erased-bit count `(n−m)` that lower-bounds heat also lower-bounds elapsed time once an
energy budget is fixed, linking Landauer (energy) to Margolus–Levitin (time) through a
single combinatorial invariant of the proof. **Why now?** The energetic quantity
`(n−m)·ln 2` is now a proved, named expression; multiplying through by the
Margolus–Levitin constant is a self-contained real-analysis lemma that produces a
genuinely new, falsifiable physical prediction about automated proof compression.
