# Future Directions: Reversible Computing and Thermodynamic Efficiency

## Synthesis of this cycle

This cycle closed the conceptual loop relating the *combinatorial* invariant of
a finite function (its fiber structure) to the *thermodynamic* cost of computing
it. Building on the catalog file `Computation.ReversibleSortingBennett` (which
gave Bennett's reversible-witness theorem for the special case of a genuine
bijection `α ≃ β × Aux`, plus the `landauer_gap_nonneg` non-strict cost bound),
we delivered two new files.

`Computation.TightAncillaBound` introduces the right notion for *arbitrary*
(possibly non-surjective) functions — a **reversible simulation**, i.e. an
*injection* `g : α → β × Aux` with `(g a).1 = f a` — and proves the ancilla
size is tightly pinned by the largest fiber:

* `maxFiberSize_le_card_of_revSim` — every simulation needs `≥ maxFiberSize f`
  ancilla states (pigeonhole on one fiber);
* `exists_revSim_fin_maxFiber` — `Fin (maxFiberSize f)` always suffices
  (via `Equiv.sigmaFiberEquiv` and per-fiber embeddings);
* `tight_ancilla_bound` — the two combine: `maxFiberSize f` is *exactly* minimal,
  and `Fin (maxFiberSize f - 1)` is impossible once a nontrivial fiber exists;
* `maxFiberSize_le_one_iff_injective` — one ancilla state ⇔ injectivity.

`Computation.IrreversibilityCost` sharpens `landauer_gap_nonneg` into a strict
dichotomy, reusing the catalog's `infoErased`/`landauerGap`:

* `infoErased_pos_iff_not_injective` — positive information erasure characterises
  non-injectivity;
* `landauerGap_pos_of_not_injective` — at positive temperature, every
  non-injective map costs a strictly positive amount of work.

Together: *more than one ancilla state* ⇔ *non-injective* ⇔ *erases information*
⇔ *strictly positive Landauer gap*. The fiber invariant `maxFiberSize` is the
single quantity governing the entire chain.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `maxFiberSize_le_card_of_revSim` | TightAncillaBound | lower ancilla bound |
| `exists_revSim_fin_maxFiber` | TightAncillaBound | matching upper bound |
| `tight_ancilla_bound` | TightAncillaBound | exact minimality |
| `maxFiberSize_le_one_iff_injective` | TightAncillaBound | injective ⇔ 1 ancilla |
| `image_card_lt_of_not_injective` | IrreversibilityCost | image strictly shrinks |
| `infoErased_pos_iff_not_injective` | IrreversibilityCost | erasure ⇔ non-injective |
| `landauerGap_pos_of_not_injective` | IrreversibilityCost | strict Landauer cost |

## Research directions for the next cycle

### 1. Optimal ancilla measured in *bits*, not *states*

We pinned the minimal ancilla *cardinality* at `maxFiberSize f`. Physically the
relevant cost is the number of *bits*, i.e. `⌈log₂ (maxFiberSize f)⌉`. The
conjecture is that `RevSim` realised over a *binary* ancilla `Fin 2 ^ m`
requires and admits exactly `m = ⌈log₂ (maxFiberSize f)⌉`, and that this equals
the catalog's `infoErased` on the worst-case uniform input. **The key insight
is** that the cardinality bound `maxFiberSize f` and the entropy bound
`infoErased` are the same quantity viewed multiplicatively versus additively, so
the ceiling-log is the unique reconciling functor between `(ℕ, ×)` and `(ℝ, +)`.
**Why now?** Both endpoints are already formalized in this project
(`maxFiberSize`, `infoErased`); only the `Nat.log2`/`Nat.clog`-bridge lemma is
missing, and Mathlib's `Nat.clog` API supplies it directly.

### 2. Composition is sub-additive in ancilla, additive only on independent stages

The catalog's `compose_aux_card` shows witness ancilla multiplies under
composition. For *simulations* the sharp statement should be
`maxFiberSize (g ∘ f) ≤ maxFiberSize f · maxFiberSize g`, with equality iff `g`
is injective on `range f` after each fiber of `f`. **The key insight is** that a
fiber of `g ∘ f` is a disjoint union of `f`-fibers indexed by a single `g`-fiber,
so the max is controlled by the product but is usually strictly smaller — the
"wasted ancilla" of naive Bennett composition is exactly this gap. **Why now?**
`maxFiberSize` and the fiber sigma-equivalence are in place; the only new tool is
`Finset.sup` of a product, available as `Finset.sup_mul_le` style lemmas.

### 3. Strict entropy decrease under non-injective pushforward

`Computation.ReversibleTropicalThermodynamics` already proves Shannon entropy is
*invariant* under bijections (`tropical_iso_entropy_invariant`). The open half is
the **strict** decrease: for every non-injective `f` there is a distribution `p`
with `H(f_* p) < H(p)`. **The key insight is** that collapsing a fiber of size
`≥ 2` merges probability mass, and `-x log x` is *strictly* concave, so any `p`
positive on a nontrivial fiber strictly loses entropy; the witnessing `p` can be
taken uniform on a single size-2 fiber and a point mass elsewhere. **Why now?**
The existing `shannonEntropy` definition plus our `maxFiberSize_le_one_iff_injective`
(which produces an explicit colliding pair) hand you the fiber and the witness;
Mathlib's `Real.add_pow_le_pow_mul_pow_of_sq_le_sq` / strict-concavity lemmas for
`Real.negMulLog` finish it.

### 4. Reversible simulation as a functor to `Equiv.Perm`

A reversible simulation embeds `α` into `β × Aux`; padding to equal cardinality
turns it into a genuine permutation of a power-of-two cube, connecting to the
Toffoli/Fredkin universality story. **The conjecture**: the assignment
`f ↦ (minimal padded permutation)` is functorial up to conjugacy, and the number
of Toffoli gates needed is `Θ(card α · log maxFiberSize f)`. **The key insight
is** that `tight_ancilla_bound` fixes the *width* of the reversible circuit
(ancilla bits), and circuit *depth* is then a separate, decoupled resource — the
two-parameter trade-off is exactly the fiber-size/gate-count Pareto frontier.
**Why now?** With the ancilla width now proven tight, gate-count is the only
remaining free parameter, making a clean lower-bound counting argument tractable
against `Fintype.card (Equiv.Perm _)`.

### 5. The fiber invariant is monotone under refinement (a data-processing law)

Define `f ⪯ g` when `f` factors through `g` (`f = h ∘ g`). **Conjecture**:
`maxFiberSize` and `infoErased` are both monotone for `⪯` — post-processing can
only coarsen fibers, never refine them, so it can only *increase* erasure. This
is a finite, exact analogue of the information-theoretic data-processing
inequality. **The key insight is** that our two invariants (`maxFiberSize`,
`infoErased`) are order-preserving functionals on the lattice of partitions of
`α` induced by functions, so the whole reversible-cost theory is really a
statement about that partition lattice. **Why now?** Both invariants are
formalized and proven equivalent on the injective/non-injective boundary; lifting
that to the full refinement order needs only `Finset.sup`/`logb` monotonicity,
already in Mathlib.
