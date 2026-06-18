# Future Directions: Iteration & Semigroup Theory for Set-Local Distortion of Hausdorff Dimension

## Synthesis

This cycle built, from scratch, the *set-local distortion* programme for Hausdorff
dimension in two Lean files under `Catalog/Geometry/`:

* `QuasiSymmetricComposition.lean` introduces the predicate
  `AntilipschitzOnWith K f s` — the genuinely new object, since Mathlib only has
  the *global* `AntilipschitzWith` and the global lower bound
  `AntilipschitzWith.le_dimH_image`. The file proves the set-local lower bound
  `AntilipschitzOnWith.le_dimH_image` (`dimH s ≤ dimH (f '' s)`), the injectivity
  `AntilipschitzOnWith.injOn`, closure under composition
  `AntilipschitzOnWith.comp`, the bi-Lipschitz invariance `dimH_image_eq`, the
  composite invariance `dimH_image_comp_eq`, and the product-exponent Hölder
  bound `dimH_image_comp_holder_le`.
* `QuasiSymmetricIterate.lean` specialises composition to the self-map / iteration
  setting on an invariant piece `s` (`MapsTo f s s`):
  `lipschitzOnWith_iterate` / `antilipschitzOnWith_iterate` (the constant of
  `f^[n]` is `K^n`), `holderOnWith_iterate` (the exponent of `f^[n]` is `r^n`),
  the **main** theorem `dimH_image_iterate_eq` (`dimH (f^[n] '' s) = dimH s` for
  every iterate), its restatement `dimH_image_iterate_const` (the orbit-piece
  dimension is a constant sequence — a fixed point of the iteration), and the
  iterated Hölder bound `dimH_image_iterate_le` (`dimH (f^[n] '' s) ≤ dimH s / r^n`).

The set-local lower bound is the conceptual keystone: it is *not* new geometry but
the Mathlib upper bound `LipschitzOnWith.dimH_image_le` applied to the Lipschitz
left inverse `Function.invFunOn f s`. With it, a genuine *semigroup* theory of
set-local distortion is now in place. The directions below are concrete,
falsifiable next steps.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `AntilipschitzOnWith.le_dimH_image` | `dimH s ≤ dimH (f '' s)` for set-local antilipschitz `f` | proved, axioms = {propext, Classical.choice, Quot.sound} |
| `AntilipschitzOnWith.comp` | set-local antilipschitz closed under composition | proved |
| `dimH_image_comp_eq` | bi-Lipschitz maps compose to a dimension-preserving map | proved |
| `dimH_image_iterate_eq` (main) | `dimH (f^[n] '' s) = dimH s` for set-local bi-Lipschitz self-maps | proved |
| `dimH_image_iterate_le` | `dimH (f^[n] '' s) ≤ dimH s / r^n` | proved |

---

## Direction 1 — From discrete iterates to the monoid of distortion exponents

`dimH_image_iterate_le` lives over `ℕ`: one map iterated `n` times. The natural
object is the free monoid on a finite family `{f_1, …, f_m}` of maps each
bi-Hölder on a common invariant `s`, indexed by words `w ∈ {1,…,m}^*`. Conjecture:
for every word the composite `f_w := f_{w_1} ∘ ⋯ ∘ f_{w_k}` satisfies
`dimH (f_w '' s) ≤ dimH s / ∏ r_{w_i}`, i.e. the distortion exponents form a
multiplicative homomorphism from the free monoid into `(ℝ≥0, ·)`, with
`dimH_image_iterate_le` the single-generator restriction.

**The key insight is** that `HolderOnWith.comp` (and the already-proved
`dimH_image_comp_holder_le`) multiplies exponents at each composition step, so the
only new content is bookkeeping a `List.prod` over the word and an induction on
word length — the per-letter invariance hypothesis is exactly what the iterate
lemmas already package per step.

**Why now?** The single-generator case `holderOnWith_iterate` is proved and its
induction is structurally identical to a `List.foldr`/`List.prod` induction; the
generalisation is reachable in one cycle rather than requiring new geometry.

---

## Direction 2 — Invariant-set dimension as a fixed point: the attractor bound

For a contraction `f` (`LipschitzOnWith K f s` with `K < 1`) mapping `s` into
itself, the orbit pieces `f^[n] '' s` are nested. Conjecture (self-similarity
dimension): if `s` is the attractor (`f '' s = s` up to closure), then
`dimH_image_iterate_const` forces `n ↦ dimH (f^[n] '' s)` to be a constant
sequence, and combined with a Moran-type open-set condition the common value is
pinned to the similarity dimension `log m / log (1/K)` for an `m`-map system.

**The key insight is** that `dimH_image_iterate_const` already proves the sequence
is *constant* whenever `f` is set-local bi-Lipschitz, so the attractor's dimension
is a genuine fixed point of the iteration — the only missing ingredient is the
lower bound from a separation/open-set condition.

**Why now?** Constancy under iteration is exactly `dimH_image_iterate_const`,
proved this cycle; the open-set condition is a *combinatorial* hypothesis
(disjointness of images) that can be stated and consumed without new analysis.

---

## Direction 3 — Quantitative corridor for genuinely Hölder iterates

`dimH_image_iterate_le` gives only an upper wall `dimH s / r^n` (informative when
`r < 1`). A companion *lower* wall — via a Hölder left inverse of exponent `r'`,
mirroring how `AntilipschitzOnWith.le_dimH_image` builds a Lipschitz left inverse
— would squeeze `dimH (f^[n] '' s)` into a geometric corridor. Falsifiable claim:
there exist explicit snowflake maps `x ↦ x^a` on `[0,1]` for which both iterated
bounds are tight, so the corridor cannot be narrowed without extra hypotheses.

**The key insight is** that `le_dimH_image` already shows "antilipschitz = the
inverse is Lipschitz"; the Hölder analogue is "Hölder-invertible = the inverse is
Hölder", and iterating its exponent `r'` in parallel with `r` yields the lower
corridor wall by the same induction as `holderOnWith_iterate`.

**Why now?** The forward wall (`dimH_image_iterate_le`) and the left-inverse
technique (`le_dimH_image`) both exist in this cycle's files; assembling the lower
wall reuses them, and the tightness witness is a `Real.rpow` computation Mathlib
supports directly.

---

## Direction 4 — Topological-entropy lower bound from antilipschitz iteration

`antilipschitzOnWith_iterate` says distances are recovered up to `K^n` after `n`
steps. In dynamics this is the separation rate that lower-bounds topological
entropy: an `(n, ε)`-separated set survives iteration because the antilipschitz
constant keeps images apart. Conjecture: `h_top(f|_s) ≥ log(1/K)` whenever `f` is
set-local antilipschitz with constant `K < 1` on a compact invariant `s`.

**The key insight is** that set-local antilipschitz with `K < 1` is exactly an
*expansivity* certificate, and `antilipschitzOnWith_iterate` turns one-step
expansivity into the `K^n` separation needed for the standard Bowen entropy lower
bound — the dynamical content is already proved, only the entropy definition needs
wiring in.

**Why now?** Mathlib has compactness and the metric machinery; the bridge from the
newly-proved iterate separation to a separated-set count is a finite combinatorial
counting argument, not new analysis.

---

## Direction 5 — Dimension-agnostic iteration via a `SetLocalDimension` typeclass

`dimH_image_iterate_eq` is stated for Hausdorff dimension because that is what
Mathlib supports, but its proof factors through exactly two interface facts:
monotonicity under set-local Lipschitz images (`LipschitzOnWith.dimH_image_le`)
and bi-Lipschitz invariance (`dimH_image_eq`). Conjecture: abstracting these into
a `SetLocalDimension` typeclass makes `dimH_image_iterate_eq` a one-line corollary
for *every* conforming dimension — box-counting and Assouad dimension included —
so e.g. `boxDim (f^[n] '' s) = boxDim s` follows by the identical skeleton once a
minimal set-local box dimension is formalised.

**The key insight is** that the entire iteration argument is *dimension-agnostic*:
it uses only monotonicity under set-local Lipschitz images and invariance under
set-local bi-Lipschitz maps. The current proof already isolates these two
ingredients, so the refactor is mechanical.

**Why now?** The two interface lemmas are exactly the ones used in this cycle's
proof; extracting them into a class is a refactor that pays off immediately the
moment any second dimension is formalised in the project.
