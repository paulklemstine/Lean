/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The cumulative weight-threshold count and its tropical convolution law

This file develops the **monotone weight-threshold counting function** of a finite binary
linear code, the invariant announced as the *original direction* of this research line:

  `wcount C t = #{ c ∈ C : wt c ≤ t }`,

the number of codewords whose Hamming weight does not exceed the threshold `t`.  Unlike
the tropical *enumerator* `twe` of `TropicalWeightEnumerator` (which only sees the convex
hull of the weight spectrum and therefore *erases* interior strata such as the minimum
distance), the cumulative count `wcount` records the **entire** weight distribution: it is
the discrete CDF of the weight, and every stratum is visible as a jump.

The headline is that under the **direct sum (coordinate concatenation)** of codes the
cumulative count obeys a genuine **convolution law**, not the naive cardinality product
`|C ⊕ D| = |C|·|D|` of `CodeDirectSum.appendCode_card`:

* `wcount_append` — **exact convolution**:
    `wcount (C ⊕ D) t = ∑_{a ∈ C, wt a ≤ t} wcount D (t − wt a)`.
  This is the combinatorial engine: a concatenation `append a b` has weight `wt a + wt b`
  (`wt_append`), so it is `≤ t` exactly when `b` is below the *sliding* threshold
  `t − wt a`.

* `wcount_append_ge` — **tropical-style supermultiplicative bound**:
    `wcount C s · wcount D r ≤ wcount (C ⊕ D) (s + r)`   for all thresholds `s, r`.
  This is the "convolution inequality rather than mere cardinality" of the mission: the
  block-rectangle `{wt ≤ s} × {wt ≤ r}` injects into `{wt ≤ s + r}` via `append`.  Taking
  logarithms it reads as **subadditivity** of `t ↦ −log wcount`, the tropical fingerprint
  of the additive grading `wt (a ++ b) = wt a + wt b`.

Both improve on cardinality: at `t = m + n` they degenerate to `|C ⊕ D| = |C|·|D|`, but
for interior thresholds the supermultiplicative bound is **strict**.  We exhibit this on
the catalog's extended Hamming `[8,4,4]` code: with `wcount hamming 4 = 15`, the
square `15·15 = 225` is a *strict* lower bound for `wcount (hamming ⊕ hamming) 8 = 227`,
the two extra codewords being the weight-`(8,0)` and `(0,8)` blocks invisible to the
rectangle.  This `225 < 227` gap is the concrete content of "convolution, not product".

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the cumulative count `wcount C t = #{wt c ≤ t}`, a strictly
  finer invariant than `twe` (which only sees the weight hull), should satisfy under
  direct sum a *convolution* identity and a *supermultiplicative* inequality
  `wcount C s · wcount D r ≤ wcount (C⊕D) (s+r)`, the discrete shadow of
  `W_{C⊕D} = W_C·W_D` refined to thresholds instead of the whole polynomial.
Experiment (Experimenter): proved `wcount_mono`, `wcount_le_card`, `wcount_length`
  (saturation `wcount C n = |C|`), `wcount_zero`; the exact convolution `wcount_append`;
  and the supermultiplicative `wcount_append_ge`.  All `sorry`-free.
Analysis (Analyst): the supermultiplicative bound is the load-bearing "tropical" content;
  the exact convolution is what makes it tight only at the endpoint `t = m+n`.  The
  Hamming instantiation `225 = wcount h 4 ^2 < wcount (h⊕h) 8 = 227` certifies the bound
  is a genuine *inequality*, not an equality — i.e. `wcount` is not multiplicative, in
  sharp contrast to `|·|` and to the full enumerator product.
Critique (Critic): adversarial counterexample search — is `wcount` ever multiplicative at
  an interior threshold (which would trivialize the inequality)?  No: the strict gap on
  Hamming kills that.  Is the bound vacuous (e.g. one side `0`)?  No: `wcount C 0 ≥ 1`
  whenever `0 ∈ C`, and both factors are positive on Hamming.  Could `wcount_append`
  hold without the `wt a ≤ t` guard?  No — dropping it double-counts via truncated
  `t − wt a`; the guard via `C.filter` is essential (see `wcount_append`).
Synthesis (PI): `wcount` upgrades the catalog's `twe`/`minDist` tropical dictionary with a
  CDF-level invariant whose direct-sum law is a true convolution; the strict Hamming gap
  is the headline evidence that thresholds carry strictly more than cardinality.
-/

import Mathlib
import Catalog.Applications.SmoothPoincare.TropicalWeightEnumerator

open scoped BigOperators

namespace SmoothPoincare
namespace Codes

variable {m n : ℕ}

/-! ## The cumulative weight-threshold count -/

/-- **Cumulative weight-threshold count.** `wcount C t` is the number of codewords of `C`
whose Hamming weight is at most `t`.  As a function of `t` it is the discrete CDF of the
weight: monotone, starting at `#{0-codewords}` and saturating at `|C|`. -/
def wcount (C : Finset (Fin n → ZMod 2)) (t : ℕ) : ℕ :=
  (C.filter (fun c => wt c ≤ t)).card

/-- A single coordinate's worth: the Hamming weight never exceeds the length. -/
theorem wt_le_length (v : Fin n → ZMod 2) : wt v ≤ n := by
  unfold wt
  calc (Finset.univ.filter (fun i => v i = 1)).card
      ≤ (Finset.univ : Finset (Fin n)).card := Finset.card_filter_le _ _
    _ = n := by simp

/-- **Monotonicity.** The cumulative count is nondecreasing in the threshold. -/
theorem wcount_mono (C : Finset (Fin n → ZMod 2)) {s t : ℕ} (h : s ≤ t) :
    wcount C s ≤ wcount C t := by
  apply Finset.card_le_card
  intro c hc
  rw [Finset.mem_filter] at hc ⊢
  exact ⟨hc.1, le_trans hc.2 h⟩

/-- The cumulative count is bounded by the code size. -/
theorem wcount_le_card (C : Finset (Fin n → ZMod 2)) (t : ℕ) : wcount C t ≤ C.card :=
  Finset.card_filter_le _ _

/-- **Saturation at the length.** At threshold `n` (the length) every codeword qualifies,
so the cumulative count equals the full code size. -/
theorem wcount_length (C : Finset (Fin n → ZMod 2)) : wcount C n = C.card := by
  unfold wcount
  rw [Finset.filter_true_of_mem]
  intro c _
  exact wt_le_length c

/-
**Bottom value.** At threshold `0` the qualifying codewords are exactly those of
weight `0`, i.e. the zero codeword.
-/
theorem wt_eq_zero_iff (v : Fin n → ZMod 2) : wt v = 0 ↔ v = 0 := by
  simp +decide [ wt, funext_iff ];
  exact forall_congr' fun i => by have := Fin.exists_fin_two.mp ⟨ v i, rfl ⟩ ; aesop;

theorem wcount_zero (C : Finset (Fin n → ZMod 2)) :
    wcount C 0 = (C.filter (fun c => c = 0)).card := by
  unfold wcount
  congr 1
  apply Finset.filter_congr
  intro c _
  simp only [Nat.le_zero, wt_eq_zero_iff]

/-! ## The convolution law under direct sum -/

/-
**Exact convolution under direct sum.** A concatenation `append a b` has weight
`wt a + wt b`, so it falls below the threshold `t` exactly when `b` falls below the
*sliding* threshold `t − wt a` (and `wt a ≤ t`). Summing the per-`a` contributions:
`wcount (C ⊕ D) t = ∑_{a ∈ C, wt a ≤ t} wcount D (t − wt a)`.
-/
theorem wcount_append (C : Finset (Fin m → ZMod 2)) (D : Finset (Fin n → ZMod 2))
    (t : ℕ) :
    wcount (C ⊕c D) t
      = ∑ a ∈ C.filter (fun a => wt a ≤ t), wcount D (t - wt a) := by
  unfold wcount; simp +decide [ Finset.sum_filter ] ;
  rw [ show ( Finset.filter ( fun c => wt c ≤ t ) ( C ⊕c D ) ) = Finset.image ( fun p : ( Fin m → ZMod 2 ) × ( Fin n → ZMod 2 ) => Fin.append p.1 p.2 ) ( Finset.filter ( fun p : ( Fin m → ZMod 2 ) × ( Fin n → ZMod 2 ) => wt p.1 + wt p.2 ≤ t ) ( C ×ˢ D ) ) from ?_, Finset.card_image_of_injOn ];
  · rw [ Finset.card_filter, Finset.sum_product ];
    refine' Finset.sum_congr rfl fun x hx => _;
    split_ifs <;> simp_all +decide [ Nat.le_sub_iff_add_le' ];
    exact fun y hy => lt_add_of_lt_of_nonneg ‹_› ( Nat.zero_le _ );
  · intro p hp q hq h_eq; simp_all +decide [ Fin.append ] ;
    simp_all +decide [ funext_iff, Fin.addCases ];
    exact Prod.ext ( funext fun i => by simpa using h_eq ( Fin.castAdd n i ) ) ( funext fun i => by simpa using h_eq ( Fin.natAdd m i ) );
  · ext; simp [Codes.appendCode];
    constructor;
    · rintro ⟨ ⟨ a, b, ⟨ ha, hb ⟩, rfl ⟩, ht ⟩ ; exact ⟨ a, b, ⟨ ⟨ ha, hb ⟩, by simpa [ wt_append ] using ht ⟩, rfl ⟩ ;
    · rintro ⟨ a, b, ⟨ ⟨ ha, hb ⟩, hab ⟩, rfl ⟩ ; exact ⟨ ⟨ a, b, ⟨ ha, hb ⟩, rfl ⟩, by simpa [ wt_append ] using hab ⟩

/-
**Tropical-style supermultiplicative bound.** The block-rectangle
`{wt ≤ s} × {wt ≤ r}` injects into `{wt ≤ s + r}` via concatenation, so
`wcount C s · wcount D r ≤ wcount (C ⊕ D) (s + r)`. Taking logarithms this is
subadditivity of `t ↦ −log wcount`, the tropical fingerprint of the additive grading
`wt (a ++ b) = wt a + wt b`. This is a *convolution inequality*, strictly stronger than
the cardinality product `|C ⊕ D| = |C|·|D|` at interior thresholds.
-/
theorem wcount_append_ge (C : Finset (Fin m → ZMod 2)) (D : Finset (Fin n → ZMod 2))
    (s r : ℕ) :
    wcount C s * wcount D r ≤ wcount (C ⊕c D) (s + r) := by
  convert Finset.card_le_card _ using 1;
  rotate_left;
  exact Finset.image ( fun p : ( Fin m → ZMod 2 ) × ( Fin n → ZMod 2 ) => Fin.append p.1 p.2 ) ( Finset.filter ( fun a => wt a ≤ s ) C ×ˢ Finset.filter ( fun b => wt b ≤ r ) D );
  · simp +decide [ Finset.subset_iff, Finset.mem_image ];
    rintro _ a b ha ha' hb hb' rfl; exact ⟨ Finset.mem_image.mpr ⟨ ( a, b ), Finset.mem_product.mpr ⟨ ha, hb ⟩, rfl ⟩, by simpa [ wt_append ] using add_le_add ha' hb' ⟩ ;
  · rw [ Finset.card_image_of_injective ];
    · unfold wcount; aesop;
    · intro p q h; simp_all +decide [ funext_iff, Fin.append ] ;
      exact Prod.ext ( funext fun i => by simpa using h ( Fin.castAdd n i ) ) ( funext fun i => by simpa using h ( Fin.natAdd m i ) )

/-! ## Instantiation on the extended Hamming `[8,4,4]` code -/

/-- `wcount hamming 3 = 1`: only the zero codeword has weight `≤ 3` (the minimum distance
is `4`). -/
theorem hamming_wcount_three : wcount hamming 3 = 1 := by
  unfold wcount; native_decide

/-- `wcount hamming 4 = 15`: the zero codeword plus the fourteen weight-`4` codewords. -/
theorem hamming_wcount_four : wcount hamming 4 = 15 := by
  unfold wcount; native_decide

/-- `wcount hamming 8 = 16`: every codeword qualifies (length saturation). -/
theorem hamming_wcount_eight : wcount hamming 8 = 16 := by
  unfold wcount; native_decide

/-- `wcount (hamming ⊕ hamming) 8 = 227`: the weight-`≤ 8` codewords of the length-`16`
direct sum. -/
theorem hamming16_wcount_eight : wcount (hamming ⊕c hamming) 8 = 227 := by
  unfold wcount; native_decide

/-- **The convolution bound is STRICT on Hamming.** The block-rectangle gives
`wcount hamming 4 · wcount hamming 4 = 225`, but the true count of weight-`≤ 8`
codewords of `hamming ⊕ hamming` is `227`: the two extra codewords are the weight
`(8,0)` and `(0,8)` blocks, invisible to the `{wt ≤ 4} × {wt ≤ 4}` rectangle. This
`225 < 227` gap is the concrete proof that `wcount` obeys a genuine *convolution*, not
the cardinality product. -/
theorem hamming16_wcount_strict :
    wcount hamming 4 * wcount hamming 4 < wcount (hamming ⊕c hamming) 8 := by
  rw [hamming_wcount_four, hamming16_wcount_eight]; norm_num

/-- The supermultiplicative bound, verified on Hamming as a sanity instance:
`225 ≤ 227`. -/
theorem hamming16_wcount_bound :
    wcount hamming 4 * wcount hamming 4 ≤ wcount (hamming ⊕c hamming) (4 + 4) := by
  exact wcount_append_ge hamming hamming 4 4

end Codes
end SmoothPoincare