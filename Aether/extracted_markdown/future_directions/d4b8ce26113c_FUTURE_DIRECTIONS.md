# Future Directions — Berggren Tropical Ultrametric

## Synthesis

This cycle built a working bridge between three catalog domains that had only
been connected informally before: the **Berggren/Lorentz arithmetic** of
`Algebra/BerggrenLorentz/Core.lean` (the maps `childA/B/C`, the form `lorentzQ`,
the predicate `IsPythag`), the **tropical valuation objects** of
`Bridges/CategoricalTropicalUltrametric.lean` (`TropicalValuationObject`), and
**nonarchimedean / ultrametric geometry**.

The unifying object is a single `ℕ∞`-valued *content valuation*
`w(a,b,c) = min(v₂ a, v₂ b, v₂ c)` (the 2-adic valuation of `gcd(a,b,c)`).
The new file `Bridges/BerggrenTropicalUltrametric.lean` proves, sorry-free:

* `w_strong_triangle` — `w` is a genuine additive valuation: `min (w u) (w v) ≤ w (u+v)`.
* `w_eq_top_iff` — `w u = ⊤ ↔ u = 0` (faithfulness / separation at the source).
* `bdist_strong_triangle`, `bdist_comm`, `bdist_eq_zero_iff`, `bdist_nonneg` —
  the pullback `bdist x y = (1/2)^{w(x-y)}` is a **real ultrametric** (a metric
  satisfying the strong triangle inequality).
* `cA/cB/cC_weight_monotone` and `cA/cB/cC_nonexpanding` — every Berggren
  successor map is valuation-monotone and `bdist`-nonexpanding.
* `w_le_combo` — the *master lemma*: ANY integer-linear combination of the
  coordinates has valuation `≥ w u`. This is the structural engine; the Berggren
  matrices are merely one instance of integer-linear maps.
* `tropMinPlus` + `weight_tropical_compat` — the min-plus tropical semiring
  `(ℕ∞, min, +)` is an explicit `TropicalValuationObject`, and `w` maps into it
  compatibly (the functorial bridge).

The most important conceptual result is the **failure analysis**: a catalog
`UltraNormObj` (with multiplicative `norm : α → ℕ`) cannot host a *nontrivial*
valuation, because ℕ-valued multiplicative ultranorms on a domain collapse to the
trivial absolute value. The order-valued (`ℕ∞`) formulation is therefore the
correct primitive — exactly the prediction in the research concept.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `w_strong_triangle` | `min (w u)(w v) ≤ w (u+v)` | ✓ proved |
| `w_eq_top_iff` | `w u = ⊤ ↔ u = 0` | ✓ proved |
| `bdist_strong_triangle` | `bdist x z ≤ max (bdist x y)(bdist y z)` | ✓ proved |
| `bdist_eq_zero_iff` | separation | ✓ proved |
| `c{A,B,C}_weight_monotone` | `w u ≤ w (c· u)` | ✓ proved |
| `c{A,B,C}_nonexpanding` | `bdist (c· x)(c· y) ≤ bdist x y` | ✓ proved |
| `tropMinPlus` | `(ℕ∞,min,+)` is a `TropicalValuationObject` | ✓ constructed |
| `weight_tropical_compat` | `w` is a tropical valuation map | ✓ proved |

All depend only on `propext, Classical.choice, Quot.sound`.

## Falsifiable Research Directions

### 1. Strict contraction on a primitive subtree, not mere nonexpansion

We proved the Berggren successors are nonexpanding for `bdist`. The sharper,
falsifiable claim is that on the subspace of **odd-content states** (where
`w u = 0`), at least one successor *strictly increases* the valuation of generic
differences, making the tree map a strict contraction on a positive-measure set
of pairs — which would give a quantitative ultrametric clustering rate for the
Berggren tree. The key insight is that `childA`'s coordinate `a - 2b + 2c` has
`v₂ ≥ 1` whenever `a` is even, so the parity grading (already visible in
`det_matB = -1`) controls valuation jumps. Why now? `w_le_combo` already isolates
the per-term valuation bound, so the strict version only needs a lower bound on
`v₂` of one designated coordinate under an explicit parity hypothesis — a small,
self-contained delta on the existing proof.

### 2. The valuation is a Lorentz invariant modulo the parity generator

Conjecture: `w` is invariant under the *proper* Berggren generators (those with
`det = 1`, i.e. `childA`, `childC`) on primitive Pythagorean states, and changes
in a controlled `ℤ/2`-graded way under `childB` (`det = -1`). The key insight is
that valuation monotonicity proved here is actually an *equality* `w u = w (c· u)`
on primitive triples, because the inverse generators (the `M₁⁻¹, M₃⁻¹` steps in
`EML/LatticeTreeCorrespondence.lean`) are also integer-linear and hence
nonexpanding in both directions. Why now? We have both directions of integrality
in the catalog (`berggren_M₁_inv'`, `berggren_M₃_inv'`) plus `w_le_combo`;
combining them turns the inequality into a two-sided bound, i.e. invariance.

### 3. `bdist` refines the Berggren tree metric / hyperbolic depth

Conjecture: the ultrametric `bdist` is bi-Lipschitz-comparable to `2^{-depth}` on
the Berggren tree, where `depth` is the `O(log c)` generation depth already
bounded in `Core.lean`. The key insight is that each generation step multiplies
the hypotenuse (`hypA/hypB/hypC`) by a bounded factor while the 2-adic content can
only grow, so tree-distance and valuation-distance are squeezed together. Why now?
The hypotenuse growth bounds and depth estimates are already formalized in
`BerggrenLorentz`, so this is a comparison of two already-quantified scales rather
than new analysis.

### 4. Generalize from `v₂` to a global ultrametric over all primes

Conjecture: replacing `w = v₂` by the product/`sup` over all primes yields a
single ultrametric on `ℤ³` that detects equality of *primitive* states exactly,
and for which the Berggren successors remain nonexpanding simultaneously at every
prime. The key insight is that `w_le_combo` is prime-agnostic — it used only
`emultiplicity_mul` and `min_le_emultiplicity_add`, both of which hold for every
prime — so the per-prime proof is literally reusable verbatim. Why now? The proof
already factors through one prime-agnostic lemma; the only new ingredient is
assembling a coherent family `(w_p)_p` and proving the assembled object is still a
`TropicalValuationObject`, for which `tropMinPlus` is a template.

### 5. A `TropHom`/`UltraHom` functor into the catalog's categorical layer

Conjecture: the assignment (Berggren state space, `w`) ⟼ `tropMinPlus` upgrades to
a genuine morphism in the categorical framework of
`CategoricalTropicalUltrametric` (a `TropHom` out of a Berggren `TropObj`, or an
`UltraHom` after a faithful real model), making the valuation reconstruction
*functorial on the Berggren category*. The key insight is that nonexpansiveness
(`c·_nonexpanding`) is exactly the `UltraHom.norm_nonexpansive'` axiom up to the
`φ` rescaling, so the successors themselves become morphisms in the ultrametric
category. Why now? The catalog already provides `TropHom`, `UltraHom`, and their
extensionality lemmas; this cycle supplied the missing object and the
nonexpansion bounds, so only the bundling remains.
