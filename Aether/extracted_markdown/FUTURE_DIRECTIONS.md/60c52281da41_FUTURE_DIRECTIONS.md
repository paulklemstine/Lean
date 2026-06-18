# Future Directions: Tropical weight enumerator profiles for binary linear codes

This cycle introduced `TropicalWeightEnumerator.lean`, the **min-plus tropicalization**
of the classical Hamming weight enumerator on top of the catalog's `SmoothPoincare`
code primitives. The headline results were:

* `twe_append` — **tropical additivity**: `twe (C ⊕ D) = twe C + twe D`, the min-plus
  shadow of the classical multiplicativity `W_{C⊕D} = W_C · W_D`.
* `minDist_append` — **the minimum distance is a tropical-`min` invariant**:
  `minDist (C ⊕ D) = min (minDist C) (minDist D)`.
* `hamming_twe` — `twe hamming t = min(0, 8·t)`, exhibiting **information loss**: the
  weight-`4` stratum (the minimum distance) is invisible to `twe` because `4` is not a
  vertex of the convex hull of the weight spectrum `{0, 4, 8}`.

The conjectures below are concrete, falsifiable, and each comes with a suggested Lean
shape so a follow-up cycle can attack them directly.

---

## Conjecture 1 (Tropical hull recovery — the profile is exactly the lower convex hull)

**Claim.** For any nonempty binary code `C ⊆ (ZMod 2)ⁿ`, the slopes realized by the
piecewise-linear function `t ↦ twe C t` are *exactly* the weights of `C` that are
vertices of the lower convex hull of the weight-multiplicity set
`{(wt c, 1) : c ∈ C}`. Equivalently, a weight `w` present in `C` is realized as the
minimizer of `twe C t` for some `t` **iff** `w` is a hull vertex.

**Why it is bold.** It makes precise *exactly* how much the tropicalization forgets:
the `hamming` computation (`twe hamming = min(0,8t)` despite spectrum `{0,4,8}`) becomes
a special case of a general "hull recovery" theorem.

**Suggested Lean shape.**
```
def realizedSlope (C) (hC) (w : ℕ) : Prop := ∃ t : ℝ, ∀ c ∈ C, (w:ℝ)*t ≤ (wt c:ℝ)*t ∧ ...
theorem twe_slopes_eq_hull_vertices (C) (hC) :
    {w | realizedSlope C hC w} = hullVertices (weightSpectrum C)
```
**First test.** Recompute for the `[6,3,?]` shortened code and the repetition code
`{0…0, 1…1}`, where the hull is the full spectrum, and verify against `hamming`.

---

## Conjecture 2 (Tropical Gleason / Mallows–Sloane bound)

**Claim.** Every binary doubly-even self-dual code of length `n` satisfies
`minDist C ≤ 4 · ⌊n / 24⌋ + 4`. The tropical-`min` law `minDist_append` shows the
right-hand side is *not* additive (stacking two `[8,4,4]` codes keeps `d = 4`), so the
bound is genuinely a global obstruction, the distance-side analogue of Gleason's length
divisibility (`GleasonLength.doublyEven_selfDual_length_div_eight`).

**Suggested Lean shape.**
```
theorem doublyEven_selfDual_minDist_le
    (C : Finset (Fin n → ZMod 2)) (hDE : ∀ v ∈ C, DoublyEven v)
    (hSD : ∀ x, x ∈ C ↔ ∀ y ∈ C, ip x y = 0) (hne : (C.erase 0).Nonempty) :
    minDist C hne ≤ 4 * (n / 24) + 4
```
**First test.** `n = 8` (`hamming`, bound `= 4`, tight) and `n = 24` (the extended Golay
code, bound `= 8`); a follow-up cycle can build the Golay generator and `native_decide`
the spectrum to check tightness.

---

## Conjecture 3 (Tropical indecomposability criterion)

**Claim.** If `twe C` is **not** expressible as `twe C₁ + twe C₂` for codes `Cᵢ` of
strictly smaller length, then `C` is indecomposable (not a direct sum). The converse of
`twe_append` should detect block structure: `twe C` additively splitting is a
*necessary* condition for `C ≅ C₁ ⊕ C₂`.

**Suggested Lean shape.**
```
theorem indecomposable_of_twe_not_additive (C) (hC) :
    (¬ ∃ (m k : ℕ) (h : m + k = n) C₁ C₂ hC₁ hC₂,
        ∀ t, twe C hC t = twe C₁ hC₁ t + twe C₂ hC₂ t) →
    Indecomposable C
```
**First test.** Show the cyclic `[7,4]` Hamming code (non-extended) is indecomposable by
exhibiting a slope where its `twe` fails to split.

---

## Conjecture 4 (Max-plus dual recovers the covering radius envelope)

**Claim.** Replacing `min` by `max` (the max-plus tropical semiring) gives a dual
enumerator `twe⁺ C t = max_{c∈C} (wt c · t)` whose negative-`t` slope is the **maximum
weight** `W(C)`, and for self-complementary codes (`ones n ∈ C`) one has
`twe⁺ C t + twe C t = n · t` for all `t` — a clean tropical "self-duality of the
profile". For `hamming` this predicts `twe⁺ hamming t = max(0, 8t)` and
`twe⁺ + twe = 8t`.

**Suggested Lean shape.**
```
noncomputable def twePlus (C) (hC) (t : ℝ) : ℝ := C.sup' hC (fun c => (wt c:ℝ) * t)
theorem twePlus_add_twe_eq (C) (hC) (hones : ones n ∈ C)
    (hcompl : ∀ c ∈ C, (fun i => 1 + c i) ∈ C) (t : ℝ) :
    twePlus C hC t + twe C hC t = n * t
```
**First test.** Verify on `hamming` (self-complementary, since `ones 8 ∈ hamming` and
the code is closed under complement), recovering `twe⁺ hamming = max(0, 8t)`.

---

## Conjecture 5 (Tropical–ultrametric transfer to the catalog Bridge)

**Claim.** The tropical weight enumerator `twe` is a `TropicalValuationObject` morphism
target in the sense of `Bridges/CategoricalTropicalUltrametric`: the map
`C ↦ (t ↦ twe C t)` is a *functor* from the (direct-sum monoidal) category of binary
codes to the min-plus valuation semiring, sending `⊕` to `+`. Consequently the
ultrametric seminorm reconstructed from `twe` (via the Bridge's valuation
reconstruction) is exactly the Hamming-distance ultrametric on codewords, giving a
quantitative certified-bound transfer `d_Hamming(c, c') = twe`-derived valuation gap.

**Suggested Lean shape.**
```
theorem twe_is_tropical_hom :
    -- twe ∘ appendCode = (+) ∘ (twe × twe), packaged as a monoid hom into the
    -- min-plus object of CategoricalTropicalUltrametric
    ...
theorem reconstructed_ultrametric_eq_hamming (C) :
    CategoricalTropicalUltrametric.reconstruct (twe C) = hammingUltrametric C
```
**First test.** Check the triangle inequality numerically on the `16` Hamming codewords,
then formalize the reconstruction equality for the `[8,4,4]` code.
