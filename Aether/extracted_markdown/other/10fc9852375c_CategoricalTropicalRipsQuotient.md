# The Zero-Distance Quotient Metric for Categorical Tropical Rips Interleavings

**A correction and its formalization.**
Companion note to `Catalog/Bridges/CategoricalTropicalRipsQuotient.lean`.

## Summary

The interleaving distance `interleavingDist` on persistence modules
(`Bridges.CategoricalTropicalRipsInterleaving`) is a genuine `ℝ≥0∞`-valued
*pseudometric*: it is symmetric, reflexive (`interleavingDist_self`), and satisfies
the tropical / min-plus triangle inequality (`interleavingDist_triangle`). Its only
defect as a metric is that distinct modules can sit at distance `0`.

An earlier development (`Bridges.CategoricalTropicalRipsShift`) proposed to repair
this by quotienting modules by the relation `FinInterleaved` — having *some* finite
interleaving distance (`interleavingDist ≠ ⊤`). This note states and formally proves
the **correction**: the `FinInterleaved` quotient does **not** carry a separating
metric, and indeed the interleaving distance does not even descend to a well-defined
function on it. The mathematically correct replacement is the quotient by the
**zero-distance** relation.

## The correction, precisely

Let `M ~ M'` denote `FinInterleaved M M'` (equivalently `interleavingDist M M' ≠ ⊤`).
For a quotient distance `d̄([M],[N]) := interleavingDist M N` to be *well-defined* one
needs

> whenever `M ~ M'` and `N ~ N'`, `interleavingDist M N = interleavingDist M' N'`.

This **fails**. The obstruction is the triangle inequality itself: finite interleaving
only gives the *bound*

```
|interleavingDist M N − interleavingDist M' N'| ≤ interleavingDist M M' + interleavingDist N N',
```

and a finite right-hand side does not force the left-hand side to vanish.

Formally (in the Lean file):

* `constancy_forces_distZero` — if `interleavingDist M · = interleavingDist M' ·` as
  functions of the third module, then necessarily `interleavingDist M M' = 0`. So any
  relation along which the interleaving distance is constant must already be **finer**
  than the zero-distance relation; mere finiteness cannot suffice.

* `finInterleaved_not_distZero` — a concrete witness over `ℝ`: the identity persistence
  module `t ↦ t` and its unit shift `t ↦ t + 1` are `1`-interleaved (hence
  `FinInterleaved`) but lie at interleaving distance exactly bounded below by `1`, so
  they are **not** at distance `0`.

* `finInterleaved_dist_not_welldefined` — using that witness with the common third
  module `L := M`, two `FinInterleaved` modules `M, N` satisfy
  `interleavingDist M L ≠ interleavingDist N L`. Hence `interleavingDist` is genuinely
  non-constant on `FinInterleaved` classes and **no** `Quotient.lift₂` over
  `FinInterleaved` can recover it.

## The correct object: the zero-distance quotient

Define the kernel relation

```
DistZero M N : Prop := interleavingDist M N = 0.
```

The catalog facts make this an equivalence relation:

* reflexive — `interleavingDist_self` (`distZero_refl`),
* symmetric — `interleavingDist_comm` (`distZero_symm`),
* transitive — `interleavingDist_triangle` (`distZero_trans`),

packaged as `distZeroSetoid : Setoid (PersMod α)`.

The decisive technical step is the **four-point descent lemma**

* `interleavingDist_eq_of_dist_zero` — if `DistZero M M'` and `DistZero N N'`, then
  `interleavingDist M N = interleavingDist M' N'`.

This is exactly the well-definedness hypothesis of `Quotient.lift₂`, so we obtain

```
quotDist : Quotient distZeroSetoid → Quotient distZeroSetoid → ℝ≥0∞
```

with `quotDist ⟦M⟧ ⟦N⟧ = interleavingDist M N`, and the full metric laws:

* `quotDist_self` — `quotDist q q = 0`;
* `quotDist_comm` — `quotDist q q' = quotDist q' q`;
* `quotDist_triangle` — `quotDist q r ≤ quotDist q q' + quotDist q' r`;
* `quotDist_eq_zero_iff` — **point separation**: `quotDist q q' = 0 ↔ q = q'`.

The last law is precisely what `FinInterleaved` could not deliver: on the zero-distance
quotient the pseudometric becomes a genuine point-separating (extended) metric.

## Functoriality of an invariant

The construction is compatible with the catalog's 1-Lipschitz invariants. For the rank
(edge-count / Betti-0) functor `rankMod : PersMod (Set β) → PersMod ℕ` over a finite
type `β`:

* `rankMod_distZero` — zero-distance modules have zero-distance rank curves, so the
  invariant descends to a map `rankModQuot` between the corresponding zero-distance
  quotients;
* `rankMod_descends_to_quotient` — this induced map is **1-Lipschitz** for the quotient
  metrics: `quotDist (rankModQuot q) (rankModQuot q') ≤ quotDist q q'`.

## Status

All statements above are formalized with complete proofs and no `sorry`, depending only
on the standard axioms `propext`, `Classical.choice`, `Quot.sound`. The development
reuses the existing catalog infrastructure (`interleavingDist`, its triangle inequality
and commutativity, `FinInterleaved`, and `rankMod`) rather than re-proving it.
