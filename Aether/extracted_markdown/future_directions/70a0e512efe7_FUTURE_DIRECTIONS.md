# Future Directions — Tropical Valuation ↔ Ultrametric ↔ Arithmetic Height

## Synthesis

The new file `Catalog/Bridges/TropicalUltrametricBridge.lean` realises, in fully
machine-checked Lean 4, a single conceptual bridge that the catalog previously held
only as two disconnected halves: **min-plus (tropical) valuations** on one side and
**arithmetic height measures** (`padicNorm`) on the other. The connecting tissue is the
abstract object `NonArchNorm` — a real-valued non-archimedean norm — whose induced
distance is shown to be a (pseudo-)ultrametric. The order-isomorphism `t ↦ exp(-t)`,
which carries `(ℝ, min, +)` onto `(ℝ_{>0}, max, ·)`, is what makes the tropical
"min-superadditivity" of a valuation *equivalent* to the ultrametric "strong triangle
inequality" of a norm. The capstone identity

> `padicNorm p q = exp(-(v_p q) · log p)`   for `q ≠ 0`

pins the bridge down pointwise: the `p`-adic *height* is literally the exponential of the
negative `p`-adic *tropical valuation*.

## Results Summary

Four main results (axioms: only `propext`, `Classical.choice`, `Quot.sound`; zero `sorry`):

1. **`NonArchNorm.dist_strong_triangle`** — the induced distance satisfies the ultrametric
   (strong triangle) inequality `d(x,z) ≤ max(d(x,y), d(y,z))`.
2. **`NonArchNorm.dist_isosceles`** — "all triangles are isosceles": if two side lengths
   differ, the third equals their maximum. Notably this needs only symmetry + the strong
   triangle inequality, **not** positive-definiteness, so it survives the pseudometric setting.
3. **`TropicalValuation.toNorm`** — the bridge map: every tropical valuation (guarded
   ultrametric axiom away from the kernel) induces a `NonArchNorm` via `exp(-v)` patched at `0`.
4. **`padicHeightNorm`** + **`padic_norm_eq_exp`** — the `p`-adic norm is a `NonArchNorm`
   (hence yields an ultrametric on `ℚ`), and the capstone identity exhibits it as the
   exponential of the negative `p`-adic valuation.

A documented *failure boundary*: the naive valuation axiom `∀ x y, min (v x) (v y) ≤ v(x+y)`
is **false** for `padicValRat` at the zero locus (`q=p, r=-p` gives `min=1 ≤ v(0)=0`), which
is exactly why the formalised axiom is guarded by `x + y ≠ 0` and the norm is patched at `0`.

## Research Directions

### 1. Completeness and the spherically-complete hull of the tropical metric
Extend `NonArchNorm` to its induced `UniformSpace`/`MetricSpace` (where positive-definite)
and prove that the `padicHeightNorm` completion recovers Mathlib's `ℚ_[p]`.
**The key insight is** that the bridge map `exp(-v)` is a uniform isomorphism onto its image,
so Cauchy-ness in the tropical valuation filtration is *definitionally* Cauchy-ness in the
arithmetic height — completeness can be transported across the bridge rather than re-proved.
**Why now?** `NonArchNorm.dist_strong_triangle` already supplies the only nontrivial axiom a
Mathlib `PseudoMetricSpace` instance needs in the ultrametric case; the completion API
(`UniformSpace.Completion`, `PadicInt`) is mature, so the remaining work is interface glue.
*Falsifiable:* if the completion of `padicHeightNorm` failed to be isometric to `ℚ_[p]`, the
bridge identity would be wrong.

### 2. Height filtration stability under perturbation
Define the sublevel filtration `F_t = {x : N x ≤ t}` of a `NonArchNorm` and prove it is a
descending chain of subgroups with `F_s ⊆ F_t` for `s ≤ t`, and that the strong triangle
inequality makes each `F_t` an honest subgroup (the "ultrametric balls are subgroups" fact).
**The key insight is** that `dist_isosceles` forces balls to be *either nested or disjoint*,
so the filtration is a tree, not just a chain — this is the order-theoretic skeleton behind
Berkovich-style trees. **Why now?** `norm_add_eq_max_of_ne` (already proved) is precisely the
lemma that turns `F_t` into a subgroup. *Falsifiable:* exhibit a `NonArchNorm` whose `F_t` is
not a subgroup ⇒ the strong triangle inequality must have been violated.

### 3. Cross-prime product / adelic norm
Combine the per-prime `padicHeightNorm p` into a single object over a finite set `S` of primes
via `N_S q = max_{p ∈ S} padicNorm p q` and prove it is again a `NonArchNorm`.
**The key insight is** that `NonArchNorm` is closed under finite `max` (the max of strong
triangle inequalities is a strong triangle inequality), giving a clean algebra of
ultrametric norms mirroring the adelic product formula. **Why now?** With `padicHeightNorm`
established, the closure proof is a `Finset.max'` induction using only the already-proved
`ultra` field. *Falsifiable:* if `max` of two `NonArchNorm`s ever failed `ultra`, the closure
claim collapses.

### 4. Sharp `exp`-bridge for general valued fields
Generalise `padic_norm_eq_exp` to any `Valued K Γ` with a real-embeddable value group:
`‖x‖ = exp(-(ι ∘ v) x)` for an order embedding `ι : Γ → ℝ`.
**The key insight is** that the bridge depends only on `ι` being an order embedding turning the
group operation into `+` and the valuation order into `≤`; the prime `p` and `log p` are mere
normalisation. **Why now?** Mathlib's `Valuation`/`Valued` API is rich, and our abstract
`TropicalValuation.toNorm` already isolates exactly the order-theoretic content, so only the
`ι`-transport remains. *Falsifiable:* a value group with no order embedding into `ℝ` (e.g. a
non-archimedean ordered group of rank ≥ 2) would break the real-valued bridge — pinpointing
exactly where rank-1 is essential.

### 5. Quantitative isosceles defect as an arithmetic invariant
Define the *isosceles defect* `δ(x,y,z) = max side − median side` of a triangle and prove it is
identically `0` away from the equal-norm locus, then study the codimension-1 "degenerate"
locus where all three are equal.
**The key insight is** that `dist_isosceles` says the defect vanishes *off* a measure-zero
set, so the degenerate locus is exactly the equaliser `{N(x−y) = N(y−z)}` — an arithmetic
hypersurface (e.g. equal `p`-adic valuations of differences). **Why now?** The defect is
definable directly from the four proved theorems; making it an explicit `ℝ`-valued function
and proving `δ = 0 ↔ two sides differ` is a short corollary that opens a measurable/geometric
line of attack. *Falsifiable:* find a triangle with nonzero defect and two unequal sides ⇒
contradicts `dist_isosceles`.
