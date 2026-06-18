# Future Directions: A Conserved-Quantity View of Cryptographic Reductions

## Synthesis

This cycle isolated the **two quantitative engines** that drive every
provable-security argument and the **one structural engine** that drives every
black-box separation, and proved each as a standalone, axiom-clean Lean theorem.

The unifying conceptual thread is **conservation**. Each quantitative result is a
conservation law of a single real coordinate — the *advantage* — and the
structural result is a conserved scalar — the *rank* of a primitive.

* On the *quantitative* side (`Cryptography/AdvantageMetric.lean`), computational
  indistinguishability behaves like a pseudo-metric coordinate. The hybrid
  argument is sub-additivity of advantage along a path of games (an *additive*
  conservation law), and reduction composition is multiplicativity of
  advantage-loss (a *multiplicative* conservation law).
* On the *structural* side (`Cryptography/ImpagliazzoWorlds.lean`), a black-box
  separation is a conserved scalar (`rank`) preserved by every constructor of the
  construction calculus `CryptoImplies`. Once the separation is recast as an
  invariant, the proof is a single numeric step.

### Results Summary (all `sorry`-free, standard axioms only)

`Cryptography/AdvantageMetric.lean` — advantage as a pseudo-metric:

1. `advantage_triangle` — triangle inequality `|a−c| ≤ |a−b| + |b−c|`.
2. `hybrid_argument` — telescoping bound `|d 0 − d n| ≤ Σ_{i<n} |d i − d (i+1)|`.
3. `hybrid_averaging` — pigeonhole: total gap `≥ ε` forces a single step `≥ ε/n`.
4. `reduction_composition` — advantage losses multiply: `advC ≤ (l₂·l₁)·advA`.
5. `prg_stretch_amplification` — uniform per-step `ε` over `n` hybrids gives `n·ε`.

`Cryptography/ImpagliazzoWorlds.lean` — separations as invariants:

6. `cryptoImplies_rank_mono` — the rank invariant for the construction calculus.
7. `enc_not_implies_owf` — strictly stronger `ENC` cannot derive the strictly
   weaker `OWF` inside the rank-increasing calculus.
8. `prf_not_implies_prg` — a `PRF` does not collapse downward to a `PRG`.
9. `owf_implies_enc` — non-triviality: the full tower `OWF ⟹ ENC` is derivable.

---

## Direction 1 — The factor-2 resource coordinate of the indistinguishability pseudo-metric

`advantage_triangle` proves sub-additivity of the *advantage* coordinate, but
real computational indistinguishability lives on a *two-coordinate* space
`(advantage, running-time)`, where chaining two distinguishers costs a factor of
2 (or `+O(1)`) in the time coordinate. Conjecture: there is a faithful
`PseudoMetricSpace` instance on `ℕ → (ℝ × ℝ)` such that the triangle inequality
holds in the advantage coordinate exactly (`advantage_triangle`) while the time
coordinate accumulates additively, and Mathlib's `PseudoMetricSpace` API then
yields a completion whose points are the "indistinguishability classes" of game
families.

The key insight is that the seemingly cryptographic factor-2 loss is a *product
pseudo-metric* phenomenon: the advantage and resource coordinates obey different
but individually clean conservation laws, and only their product is the object
cryptographers informally call "the metric." **Why now?** `advantage_triangle`
already nails the hard coordinate; the remaining work is bookkeeping that
Mathlib's `Prod` pseudo-metric instances can absorb, bridging `AdvantageMetric`
to `Topology.MetricSpace`.

## Direction 2 — Tightness lower bounds: a forced linear blow-up in the rank gap

`reduction_composition` shows losses multiply and `prg_stretch_amplification`
shows a chain of length `n` incurs loss `n·ε`. Conjecture: in the `CryptoImplies`
calculus, any derivation `CryptoImplies X Y` of minimal length has length exactly
`rank Y − rank X`, so any quantitative realization through
`prg_stretch_amplification` incurs advantage loss at least `(rank Y − rank X)·ε`
— a *provable lower bound* on tightness driven purely by the rank gap.

The key insight is that the rank invariant `cryptoImplies_rank_mono` is not just
an obstruction (separations) but a *metric*: the rank difference lower-bounds
derivation length, hence the unavoidable hybrid count, hence the advantage loss.
**Why now?** Both halves already exist in this cycle — `cryptoImplies_rank_mono`
gives the structural distance and `prg_stretch_amplification` converts hybrid
count to advantage loss; the missing lemma is "minimal derivation length = rank
gap," a finite induction on `CryptoImplies`.

## Direction 3 — A two-dimensional invariant separating Minicrypt from Cryptomania

The current `rank` is one-dimensional and totally orders the symmetric-key
primitives; it cannot witness the Impagliazzo separation of *Minicrypt* (OWF, no
public-key) from *Cryptomania* (public-key exists), because public-key crypto is
*incomparable* to, not weaker than, a PRF. Conjecture: extending `Primitive` with
a `PKE` (public-key encryption) constructor and replacing `rank : Primitive → ℕ`
with a *two-dimensional* invariant `rank₂ : Primitive → ℕ × ℕ` (symmetric
strength, key asymmetry), ordered by the product order, makes
`¬ CryptoImplies OWF PKE` provable by the identical invariant-then-`omega`
pattern as `enc_not_implies_owf`.

The key insight is that black-box separations are exactly the *incomparabilities*
of the right partial order on primitives, and the Minicrypt/Cryptomania gap is a
second, orthogonal coordinate — so the proof technique of this cycle generalizes
verbatim once the invariant has the correct dimension. **Why now?**
`cryptoImplies_rank_mono` is structurally parametric in the invariant; swapping
`ℕ` for `ℕ × ℕ` with `Prod.le` reuses the whole induction, turning a famous
separation into a finite check.

## Direction 4 — GGM as a tree-indexed hybrid with logarithmic, not linear, loss

`prg_stretch_amplification` handles a *linear* chain of `n` hybrids with loss
`n·ε`. The GGM PRF construction instead evaluates a *balanced binary tree* of
depth `n` with `2^n` leaves, yet its security loss is the *depth* `n`, not the
leaf count `2^n`. Conjecture: there is a tree-indexed analogue
`ggm_tree_amplification` stating that for a distinguisher walking root-to-leaf in
a depth-`n` tree whose every internal edge has gap `≤ ε`, the root-to-leaf
advantage is `≤ n·ε`, provable by the *same* telescoping `hybrid_argument`
applied along the unique path, never enumerating leaves.

The key insight is that the GGM "exponentially many hybrids but logarithmic loss"
phenomenon is just `hybrid_argument` applied to a *path in a tree* rather than the
whole index set: the averaging principle is path-local, so the loss tracks path
length (depth), not tree size. **Why now?** `hybrid_argument` is already stated
over an arbitrary `ℕ`-indexed sequence; instantiating that sequence at the nodes
along one tree path is a definitional move with no missing prerequisites.

## Direction 5 — Goldreich–Levin as a correlation-to-rank bridge

The Goldreich–Levin hardcore-bit theorem says a predictor with advantage `ε` on
`⟨x,r⟩ mod 2` yields an inverter succeeding with probability `poly(ε)`; its core
is the Fourier fact that a Boolean function significantly correlated with a
*linear* function can be list-decoded. Conjecture: the list-decoding bound is an
instance of `hybrid_averaging` — the `ε`-correlation, summed over `r`, forces (by
pigeonhole) a single heavy Fourier coefficient, exactly the `∃ i, i < n ∧ ε/n ≤ a i`
shape — so a Lean GL reduction can be assembled from `hybrid_averaging`
(heavy-coefficient extraction) and `reduction_composition` (predictor-to-inverter
loss multiplication).

The key insight is that "significant correlation forces a heavy linear
coefficient" is the *averaging principle in the Fourier basis*: the same
pigeonhole that powers the hybrid argument, transported through the orthonormal
characters of `BitVec n`. **Why now?** This cycle delivers both ingredients —
`hybrid_averaging` for the extraction and `reduction_composition` for the
quantitative bound — so the remaining gap is the concrete list-decoding algorithm
over `BitVec n`, a self-contained Lean construction with no missing analytic
prerequisites.
