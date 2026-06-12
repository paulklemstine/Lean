/-
# Strict Irreversibility Cost of Non-Injective Computation

This file complements `Computation.TightAncillaBound` and builds directly on the
thermodynamic infrastructure of `Computation.ReversibleSortingBennett`
(`infoErased`, `landauerCost`, `landauerGap`, `landauer_gap_nonneg`).

The catalog proves `landauer_gap_nonneg`: irreversible computation costs *at
least* as much as reversible computation. Here we sharpen the inequality to a
**strict** one exactly in the irreversible regime: a function loses a positive
amount of information — and hence incurs a strictly positive Landauer cost —
**iff** it is non-injective. Combined with
`TightAncilla.maxFiberSize_le_one_iff_injective`, this closes the conceptual
loop: a function needs more than one ancilla state ⇔ it is non-injective ⇔ it
erases information ⇔ its Landauer gap is strictly positive.

## Main results

* `image_card_lt_of_not_injective` — a non-injective map on a finite type has
  strictly fewer image points than domain points.
* `infoErased_pos_iff_not_injective` — positive information erasure characterises
  non-injectivity.
* `landauerGap_pos_of_not_injective` — strict positivity of the Landauer gap for
  every non-injective map (at positive temperature).
-/

import Mathlib
import Computation.ReversibleSortingBennett
import Computation.TightAncillaBound

open Finset Function

namespace IrreversibilityCost

/-
!-- Lab Notebook --!--
Hypothesis: `landauer_gap_nonneg` should be an equality `= 0` exactly for
injective maps, and a strict inequality `> 0` exactly otherwise. The
discriminating quantity is whether the image shrinks.
Result: Proved `infoErased f > 0 ↔ ¬Injective f` and the strict Landauer gap.
Insight: `infoErased = logb 2 |α| - logb 2 |image f|` is positive precisely
when `|image f| < |α|`, which by `Finset.card_image_iff` is exactly failure
of injectivity. `Real.logb` strict monotonicity does the rest.
Failure analysis: Watch the degenerate cases — `Real.logb` is only well behaved
for positive arguments. Non-injectivity forces `|α| ≥ 2` and `|image f| ≥ 1`,
so both logs are taken at strictly positive integers and monotonicity applies.
!-- end Lab Notebook --!--

!-- sketch: `card (image f) ≤ card α` always; equality would mean `InjOn` on
univ (`Finset.card_image_iff`), i.e. `f` injective, contradiction. --!--

A non-injective function on a finite type hits strictly fewer points than its
domain has.
-/
theorem image_card_lt_of_not_injective {α β : Type*}
    [Fintype α] [DecidableEq β]
    (f : α → β) (h : ¬ Function.Injective f) :
    (Finset.image f Finset.univ).card < Fintype.card α := by
  refine' lt_of_le_of_ne _ _;
  · exact Finset.card_image_le.trans_eq ( Finset.card_univ );
  · contrapose! h;
    exact fun x y hxy => by have := Finset.card_image_iff.mp ( by aesop : Finset.card ( Finset.image f Finset.univ ) = Finset.card Finset.univ ) ; aesop;

/-
!-- sketch: `infoErased f = logb 2 |α| - logb 2 |image f|`; this is `> 0` iff
`|image f| < |α|` by strict monotonicity of `logb 2`, which by
`image_card_lt_of_not_injective` is equivalent to non-injectivity. --!--

**Information erasure characterises irreversibility.** The information erased
by `f` (in bits) is strictly positive iff `f` is non-injective.
-/
theorem infoErased_pos_iff_not_injective {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β) :
    0 < infoErased f ↔ ¬ Function.Injective f := by
  constructor <;> intro h;
  · intro hf;
    unfold infoErased at h; simp_all +decide [ Finset.card_image_of_injective ] ;
  · exact sub_pos_of_lt ( Real.logb_lt_logb ( by norm_num ) ( Nat.cast_pos.mpr ( Finset.card_pos.mpr ⟨ _, Finset.mem_image_of_mem f ( Finset.mem_univ ( Classical.arbitrary α ) ) ⟩ ) ) ( by exact_mod_cast image_card_lt_of_not_injective f h ) )

/-
!-- sketch: `landauerGap = kT·log 2·infoErased`; with `kT > 0` and
`infoErased > 0` (from `infoErased_pos_iff_not_injective`) the product is
strictly positive. --!--

**Strict Landauer cost.** At positive temperature, every non-injective
computation has a strictly positive Landauer gap — irreversibility is never free.
-/
theorem landauerGap_pos_of_not_injective {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β) (kT : ℝ) (hkT : 0 < kT) (h : ¬ Function.Injective f) :
    0 < landauerGap f kT := by
  exact mul_pos ( mul_pos hkT ( Real.log_pos ( by norm_num ) ) ) ( infoErased_pos_iff_not_injective f |>.2 h )

end IrreversibilityCost