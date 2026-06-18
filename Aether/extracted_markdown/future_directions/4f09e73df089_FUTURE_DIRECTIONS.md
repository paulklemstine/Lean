# FUTURE DIRECTIONS — Tropicalized binary weight enumerator profiles

Follow-up conjectures for the `SmoothPoincare` tropical-code thread. Each builds on the
verified results in `TropicalWeightEnumerator.lean` (cycles 1–2: `twe`, `twePlus`,
additivity, `minDist` min-law, Hamming closed forms) and `TropicalProfile.lean`
(cycles 3–4: the covering-radius collapse `twe = min(0, maxWt·t)`, the recovery theorem
`twe (C.erase 0) = minDist·t`, the universal self-duality `twe+twePlus = n·t` for
self-complementary codes). All conjectures are stated to be falsifiable by either a
`native_decide` computation on a concrete code or a general `le_antisymm`-style proof.

---

## Conjecture 1 (Replication power law) — *strong, likely provable*

Let `C^{⊕k}` denote the `k`-fold direct sum (coordinate concatenation) of a code
`C ⊆ (ZMod 2)ⁿ`, a code of length `k·n`. Then for every `k` and every real `t`,
```
twe (C^{⊕k}) t = k · twe C t,     twePlus (C^{⊕k}) t = k · twePlus C t,
maxWt (C^{⊕k}) = k · maxWt C,     minDist (C^{⊕k}) = minDist C.
```
*Basis*: proved for `k = 2` on Hamming (`hamming16_twe`, `hamming16_minDist`) and the
single-step laws `twe_append`, `twePlus_append`, `maxWt_append`, `minDist_append`.
*Test*: induction on `k` using the cycle-3 append laws; the only obstacle is the `Fin`
re-association `Fin ((k·n)+n) ≃ Fin (k·n + n)`, soluble with `Fin.append` /
`finCongr`. Falsifiable: any failure of `maxWt (C^{⊕k}) = k·maxWt C` on a small code.

## Conjecture 2 (Tropical profile rigidity / inverse problem) — *bold*

Two codes `C, D` both containing `0` have *identical full-code tropical profiles*
(`twe C = twe D` and `twePlus C = twePlus D` as functions of `t`) **iff**
`maxWt C = maxWt D`. Consequently the pair `(twe, twePlus)` on the *full* code is a
complete invariant of the single number `maxWt`, and is *blind* to everything else
(length, dimension, minimum distance, the entire interior weight spectrum).
*Basis*: the collapse theorems `twe_eq_min_zero_maxWt`, `twePlus_eq_max_zero_maxWt`
make this immediate in one direction; the converse is `min(0,at)=min(0,bt) ∀t ⟹ a=b`.
*Test*: a short real-analysis lemma (evaluate at `t = -1`). Falsifiable by exhibiting
two `0`-containing codes with equal `maxWt` but different `twe` — the conjecture
predicts this is impossible.

## Conjecture 3 (Punctured profile reconstructs the convex hull) — *bold, central*

For a code `C` containing `0`, define the **doubly-punctured** enumerator on
`C.erase 0 \ {maxWt-attaining words}`. Iterating the puncture-and-recover operation of
`twe_erase_eq_minDist_mul` peels off the weight spectrum from both ends, and the full
ordered sequence of distinct slopes obtained equals exactly the **vertices of the lower
convex hull** of the weight-multiset `{wt c : c ∈ C}`. Equivalently: the tropical
enumerator family `{ twe(C minus its current extreme words) }` is a complete encoding of
the Newton polygon of the weight spectrum.
*Basis*: cycle-2 "information loss" insight + `twe_erase_eq_minDist_mul` (the `minDist`
slope) + the `maxWt` slope. *Test*: define `slopes C := image wt C` and prove the
recovered slopes are precisely its convex-hull vertices; verify on Hamming that the
recovered slopes are `{0,4,8}` with hull `{0,8}` and the punctured slope `4`.
Falsifiable on any code whose interior weight is a hull vertex.

## Conjecture 4 (Tropical Singleton / Gleason envelope) — *speculative, high-value*

For every binary doubly-even self-dual code of length `n` (length `8 ∣ n` by
`GleasonLength.doublyEven_selfDual_length_div_eight`), the tropical "gap" between the
covering radius and packing radius obeys
```
maxWt C + minDist C ≤ n + 4,
```
with equality for the extended Hamming `[8,4,4]` code (`8 + 4 = 8 + 4`). More boldly,
`minDist C ≤ 4·⌊n/24⌋ + 4` (the tropical shadow of the Mallows–Sloane bound), and the
extremal codes are exactly those whose tropical profile pair `(twe, twe∘erase)` has
slope set `{0, 4·⌊n/24⌋+4, n}`.
*Basis*: Hamming endpoints `maxWt = 8`, `minDist = 4`, `n = 8`; `selfDual_even_weight`
forces even weights. *Test*: prove the additive bound from `wt_add_overlap` and
self-orthogonality; check `native_decide` on the `[24,12,8]` Golay code if encodable.
Falsifiable by any doubly-even self-dual code violating `maxWt + minDist ≤ n + 4`.

## Conjecture 5 (Tropical MacWilliams duality) — *speculative, deepest*

Define the **dual-code tropical enumerator** `twe (C⊥) t`. Conjecture a tropical
MacWilliams relation: for every linear code `C ⊆ (ZMod 2)ⁿ` and every `t ≤ 0`,
```
twe (C⊥) t = (n · t) − maxWt C · t  =  (n − maxWt C) · t,
```
i.e. the covering radius of `C` controls the minimum distance of `C⊥` through
`minDist(C⊥) = n − maxWt C` whenever `0 ∈ C` (a tropicalized "dual distance =
co-covering radius"). For self-dual `C` this degenerates to the fixed point
`maxWt C = n − minDist(C)`, predicting `maxWt hamming = 8 − 4 = 4`? — **NB this last
numerical check fails for Hamming (`maxWt = 8 ≠ 4`), so the precise constant is part of
what must be discovered**; the robust, testable core is the *linear-in-`t`* form of
`twe(C⊥)` for `t ≤ 0` and its dependence only on a single dual invariant.
*Basis*: classical MacWilliams `W_{C⊥} = |C|⁻¹ W_C(x+y, x−y)`, whose tropicalization
turns the Hadamard transform into an inf-convolution. *Test*: formalize the tropical
(inf-plus) MacWilliams transform and verify additivity under direct sum mirrors
`twe_append`. Falsifiable: compute `twe(hamming⊥) = twe(hamming)` (self-dual) and check
against the conjectured linear form.
