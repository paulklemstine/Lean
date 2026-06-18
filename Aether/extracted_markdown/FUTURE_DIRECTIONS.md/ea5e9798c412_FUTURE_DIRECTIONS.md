# Future Directions — Arithmetic Height ↔ Rips Filtrations via Valuation-Depth Profiles

## Synthesis

`Catalog/Bridges/ArithmeticHeightRipsBridge.lean` fuses three previously
disconnected strands of the catalog into one pipeline
`ℚ → (ℕ →₀ ℤ) → pseudometric → Rips filtration`:

* the **arithmetic height** `ArithmeticVCDim.ratArithHeight` (Bridges),
* the **non-archimedean / valuation-depth** philosophy of
  `Computation/PadicValuationDepth.lean` (`ValuationDepthMeasure`, `vdepth_sum_le`), and
* the **Rips monotonicity engine** `ripsGraph` / `ripsGraph_mono`
  (`Applications/PoincareData/MetricFiltration.lean`).

The central object is the **valuation vector** `valVec q : ℕ →₀ ℤ`, `valVec q p = padicValRat p q`,
whose ℓ¹ length is the **profile mass** `profileMass q = ∑_p |v_p(q)|`. We proved four
load-bearing facts that make the bridge real rather than cosmetic:

1. `profileMass_le_height` — **height control**: `profileMass q ≤ ratArithHeight q`.
2. `profileMass_mul_le` — **multiplicative subadditivity** `M(q·r) ≤ M(q)+M(r)`,
   the non-expansiveness that turns `profileDist` into a genuine pseudometric
   (instance `PseudoMetricSpace RatVal`).
3. `arithHeight_rips_adj` — **height controls the Rips scale**: every `q ≠ 1` is
   Rips-adjacent to the unit `1` at scale `ratArithHeight q`.
4. `denProfile_add_le_sup` — **ultrametric `⊔`-subadditivity under addition**
   `Filt(q+r) ≤ Filt(q) ⊔ Filt(r)`, the non-archimedean analogue of `vdepth_sum_le`.

## Results Summary

The bridge converts number-theoretic complexity (height) into a topological/combinatorial
pipeline with certified bounds, exactly as conjectured: bounded height ⇒ bounded profile
mass ⇒ controlled Rips scale; multiplication is 1-Lipschitz; addition is ultrametric. All
main theorems are `sorry`-free and depend only on `propext`, `Classical.choice`, `Quot.sound`.

---

## Direction 1 — The profile pseudometric is the word metric on `ℚˣ`, and `valVec` is an isometric isomorphism `ℚˣ/{±1} ≃ ⊕_p ℤ`

**Conjecture.** The map `q ↦ valVec q` restricts to a group isomorphism
`ℚˣ / {±1} ≃ ⊕_p ℤ` (the free abelian group on primes), under which `profileDist`
is *exactly* the ℓ¹ (word) metric on `⊕_p ℤ`. Consequently the connected components of
`ripsGraph RatVal t` at integer scale `t` are precisely the ℓ¹-balls of radius `⌊t⌋`
in the valuation lattice, and `π₀(ripsGraph RatVal t)` is infinite for every `t ≥ 0`
but *locally finite per height stratum*.

**The key insight is** that `profileMass` is not an ad-hoc size function but the canonical
ℓ¹ norm pulled back along the fundamental theorem of arithmetic, so every statement about
the Rips filtration is secretly a statement about lattice geometry in `⊕_p ℤ` — making the
whole filtration explicitly computable rather than abstract.

**Why now?** We already have `valVec_mul` (homomorphism property) and the verified
`PseudoMetricSpace RatVal` instance; the only missing pieces are surjectivity onto finitely
supported vectors (build a rational from a prescribed valuation vector) and the
kernel computation `{±1}`. Both are finite, constructive, and within reach of the existing
`Nat.factorization_prod_pow_eq_self` machinery used in `factorization_sum_le`.

**Falsifiable:** if some finitely supported `v : ℕ →₀ ℤ` is *not* `valVec` of any rational,
or if `profileDist` differs from the ℓ¹ metric on a single example, the conjecture dies.

---

## Direction 2 — A Northcott-style degree bound: bounded height ⇒ bounded Rips degree and finite VC dimension

**Conjecture.** For each scale `t` and height bound `H`, the number of rationals `r` with
`ratArithHeight r ≤ H` that are Rips-adjacent to a fixed `q` at scale `t` is bounded by an
explicit polynomial in `H` and `t` (a "local Northcott" estimate). Moreover the set system
`{ {r : profileDist q r ≤ t} : q }` restricted to a height stratum has VC dimension
bounded by the number of primes below `H`.

**The key insight is** that arithmetic height is simultaneously a Northcott finiteness
gauge *and* an ℓ¹ radius bound, so finiteness of bounded-height rationals (classical number
theory) becomes finiteness of Rips neighborhoods (combinatorics), directly linking to the
catalog's `ArithmeticVCDim` program: height stratification ⇒ bounded shattering.

**Why now?** `profileMass_le_height` already gives the radius bound, and
`Bridges/ArithmeticVCDimension.lean` supplies the VC/pseudo-dimension vocabulary. The merge
is a counting argument over `Nat.factorization` supports, not new analysis.

**Falsifiable:** exhibit a fixed `q`, scale `t`, and height `H` with super-polynomially many
height-`≤H` neighbors, or a shattered set exceeding the prime-count bound.

---

## Direction 3 — Stability of persistent barcodes: the height-to-filtration functor is 1-Lipschitz for interleaving distance

**Conjecture.** The assignment `q ↦ (ripsGraph RatVal · centered at q)` is 1-Lipschitz from
`(ℚ, profileDist)` to the space of `π₀`-persistence modules with the interleaving distance:
`d_interleave(Filt q, Filt r) ≤ profileDist q r ≤ ratArithHeight (q / r)`. In particular,
multiplying a rational by a unit-height factor perturbs its barcode by a bounded amount.

**The key insight is** that `profileDist_triangle` + `profileMass_mul_le` already certify
the metric *non-expansiveness* that classical stability theorems require as a hypothesis;
here the input perturbation is measured by arithmetic operations, so barcode stability is
inherited *for free* from the multiplicative structure of `ℚ`.

**Why now?** The pseudometric and `ripsGraph_mono` (the two ingredients of every interleaving
proof) are in hand; what remains is to port a one-sided interleaving lemma to the
`GeneralizedFiltration` structure already defined in `MetricFiltration.lean`.

**Falsifiable:** a pair `q, r` whose `π₀`-barcodes are farther apart (in interleaving
distance) than `profileDist q r` refutes 1-Lipschitzness.

---

## Direction 4 — Sharp ultrametric law and a full non-archimedean seminorm on `ℚ`

**Conjecture.** The `⊔` inequality `denProfile_add_le_sup` is *sharp with a strict-domination
clause*: at every prime `p` with `v_p(den q) ≠ v_p(den r)` we have equality
`v_p(den(q+r)) = max(v_p(den q), v_p(den r))`, and strict drop can occur only when the two
denominator depths coincide. Consequently `q ↦ denProfile q` is a genuine non-archimedean
(ultrametric) seminorm, and `profileDist` itself satisfies the strong triangle inequality
`profileDist q s ≤ max(profileDist q r, profileDist r s)` on the *denominator sublattice*.

**The key insight is** that the ultrametric strict-equality dichotomy of p-adic valuations
(`padicValRat.add_eq_min_of_ne`-style facts) upgrades our coarse `⊔` bound to an exact
calculus, turning `denProfile` into a bona-fide functor into ultrametric spaces — the precise
realization of the `vdepth_sum_le` "max not sum" slogan from `PadicValuationDepth.lean`.

**Why now?** `den_factorization_eq` already reduces every claim to `padicValRat`; the strict
ultrametric lemmas are present in Mathlib's `padicValRat` API, so the upgrade is a case split,
not new theory.

**Falsifiable:** a prime `p` and rationals `q, r` with distinct denominator depths yet
`v_p(den(q+r)) < max(...)` immediately refutes sharpness.

---

## Direction 5 — Realize `ValuationDepthMeasure` by `profileMass` and separate complexity classes `VAL_k`

**Conjecture.** A `profileMass`-style depth makes the abstract `ValuationDepthMeasure`
axioms (`vdepth_zero`, `vdepth_add ≤ max+1`, `vdepth_mul ≤ max+1`) *tight* on a concrete
family of rational-valued functions, and the induced complexity classes `VAL_k` form a
strict hierarchy witnessed by iterated products of distinct primes (profile mass `k`
requires depth exactly `⌈log₂ k⌉`).

**The key insight is** that `profileMass_mul_le` is the *concrete shadow* of the abstract
`vdepth_mul` law, so the synthetic depth hierarchy of `PadicValuationDepth.lean` can be
*instantiated and separated* by honest arithmetic objects instead of remaining a
free-standing axiomatic skeleton — giving the catalog its first concrete model of `VAL_k`.

**Why now?** The subadditivity theorems proved here are exactly the closure properties the
`ValuationDepthMeasure` class demands; building the instance is bookkeeping, and the
separation witnesses are products of primes whose `profileMass` we can already compute via
`factorization_sum_le`.

**Falsifiable:** if `profileMass` violates any `ValuationDepthMeasure` axiom (e.g. an addition
exceeding `max+1`), or if the hierarchy collapses (two distinct `VAL_k` coincide), the
program fails.
