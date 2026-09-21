/-
# THE-SUM-DIFFERENCE-SPLIT, part I: the algebra of factor residues

Round-29 experiment #1 (paper 99) reads a battery of labels through three "views" of a
pair of factor residues `(p, q)` modulo a fixed modulus `m`:

* the **sum view**      `s = p + q`,
* the **gap view**      `d = q - p`,
* the **product view**  `N = p q`   (the hint-free channel: all one can read off `N` itself),

and against the **joint residue view** `(s, d)`.  The reported table (`m = 31`) is

| view                        | bits   |
|-----------------------------|--------|
| product view (hint-free)    | 1.0012 |
| sum view alone              | 0.0391 |
| gap view alone              | 0.0387 |
| joint residue view `(s,d)`  | 1.5201 |

so the pre-stated reconstruction hypothesis `I(s,d) = I(N)` failed *upward*, by
`+0.5189` bits.

This file isolates the **algebra** that makes that outcome not an accident but a theorem,
and does so over an arbitrary commutative ring in which `2` is invertible:

* `SumDiffSplit.sd` — the sum/difference coordinates `(p,q) ↦ (p+q, q-p)`;
* `SumDiffSplit.prodOf` — the product *recovered* from the pair `(s,d)`, via `4pq = s² - d²`;
* `SumDiffSplit.prodOf_sd` — the recovery identity: the product view **factors through** the
  joint residue view.  This is the structural reason the joint row can never fall below the
  product row;
* `SumDiffSplit.sdEquiv` — `(p,q) ↦ (s,d)` is a bijection of `R × R`, so the joint residue
  view is *exactly* the "both factors mod `m`" view, no more and no less;
* `SumDiffSplit.sd_swap`, `prodOf_neg_snd` — the `p ↔ q` symmetry: swapping the factors flips
  `d ↦ -d` and leaves the recovered product fixed;
* `SumDiffSplit.sum_view_not_injective`, `gap_view_not_injective` — at `m = 31`, **neither**
  single coordinate determines the product: each view alone is strictly coarser;
* `SumDiffSplit.joint_view_strictly_finer` — conversely the joint view is *strictly* finer
  than the product view: two pairs with equal product and different `(s,d)`;
* `SumDiffSplit.logb_card_sd_lt_ten` — the size of the hint: the pair `(p mod 31, q mod 31)`
  ranges over `961 < 2^10` values, i.e. the factor-residue hint is a genuine 10-bit hint.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the refutation of `I(s,d) = I(N)` observed in round 29 is forced by
  algebra, not by the particular battery: `(s,d)` refines `N` because `4N = s² - d²`, while
  `N` cannot refine `(s,d)` because the product map has fibres of size > 1.
Experiment (Stage 2): formalised the recovery identity over an arbitrary `CommRing` with
  `Invertible 2` (so `ZMod m`, `m` odd, is a special case) and searched `ZMod 31` for the
  witnesses of strictness.  Found `(1,2)` vs `(0,3)` (equal sums, products `2 ≠ 0`),
  `(1,2)` vs `(0,1)` (equal gaps, products `2 ≠ 0`), and `(1,6)` vs `(2,3)` (equal products
  `6`, distinct sums `7 ≠ 5`).
Analysis (Stage 3): the asymmetry is exactly the failure of `2`-torsion to matter: over any
  ring with `1/2` the sum/difference change of coordinates is invertible, so the joint view
  *is* the factor pair; the product view is the image of a genuinely non-injective quadratic
  map `(s,d) ↦ (s² - d²)/4`.  One direction is a bijection, the other a 2-to-1-or-worse
  collapse: hence `I(joint) ≥ I(product)` with the inequality generically strict.
Critique (Stage 4): the identity `4pq = s² - d²` needs `2` invertible only for the *recovery*
  of `pq` from `(s,d)`; the identity itself is characteristic-free, and is stated separately
  as `four_mul_prod_eq` so the even-modulus boundary is visible.  At `m` even the recovery
  genuinely fails: `p = 0, q = 0` and `p = 1, q = 1` have the same `(s,d)` mod `2`? — no, they
  differ; the real failure mod `2` is that `sd` is not surjective, which is why we keep
  `Invertible 2` as an explicit hypothesis rather than hiding it.
-/
import Mathlib

namespace SumDiffSplit

/-! ## 1. Sum/difference coordinates and the recovery identity -/

section CommRing

variable {R : Type*} [CommRing R]

/-- The **sum/difference coordinates** of a factor pair: `(p, q) ↦ (p + q, q - p)`. -/
def sd (p q : R) : R × R := (p + q, q - p)

@[simp] theorem sd_fst (p q : R) : (sd p q).1 = p + q := rfl

@[simp] theorem sd_snd (p q : R) : (sd p q).2 = q - p := rfl

/-- **The characteristic-free half of the recovery identity**: `4 p q = s² - d²`.  No
invertibility of `2` is needed to state or prove this; it is needed only to divide by `4`. -/
theorem four_mul_prod_eq (p q : R) :
    4 * (p * q) = (p + q) * (p + q) - (q - p) * (q - p) := by ring

variable [Invertible (2 : R)]

/-- The product **recovered** from a sum/difference pair: `N = (s² - d²)/4`. -/
def prodOf (v : R × R) : R := ⅟(2 : R) * ⅟(2 : R) * (v.1 * v.1 - v.2 * v.2)

/-- **The product view factors through the joint residue view.**  Knowing `p + q` and `q - p`
determines `p q`; this single identity is what forbids the joint row of the round-29 routing
table from ever falling below the product row. -/
theorem prodOf_sd (p q : R) : prodOf (sd p q) = p * q := by
  have h : (2 : R) * ⅟(2 : R) = 1 := mul_invOf_self 2
  simp only [prodOf, sd_fst, sd_snd]
  linear_combination (p * q * (2 * ⅟(2 : R) + 1)) * h

/-- Two factor pairs with the same sum/difference coordinates have the same product. -/
theorem prod_eq_of_sd_eq {p q p' q' : R} (h : sd p q = sd p' q') : p * q = p' * q' := by
  rw [← prodOf_sd p q, ← prodOf_sd p' q', h]

/-- Halving: the first factor is recovered from `(s, d)`. -/
theorem fst_of_sd (p q : R) : ⅟(2 : R) * ((p + q) - (q - p)) = p := by
  have h : (2 : R) * ⅟(2 : R) = 1 := mul_invOf_self 2
  linear_combination p * h

/-- Halving: the second factor is recovered from `(s, d)`. -/
theorem snd_of_sd (p q : R) : ⅟(2 : R) * ((p + q) + (q - p)) = q := by
  have h : (2 : R) * ⅟(2 : R) = 1 := mul_invOf_self 2
  linear_combination q * h

/-- **The sum/difference change of coordinates is a bijection** whenever `2` is invertible:
the joint residue view is exactly the factor-pair view, carrying neither more nor less
information than "`p` and `q`, separately, mod `m`". -/
def sdEquiv : R × R ≃ R × R where
  toFun v := sd v.1 v.2
  invFun w := (⅟(2 : R) * (w.1 - w.2), ⅟(2 : R) * (w.1 + w.2))
  left_inv := by
    rintro ⟨p, q⟩
    simp only [sd_fst, sd_snd, Prod.mk.injEq]
    exact ⟨fst_of_sd p q, snd_of_sd p q⟩
  right_inv := by
    rintro ⟨s, d⟩
    have h : (2 : R) * ⅟(2 : R) = 1 := mul_invOf_self 2
    simp only [sd, Prod.mk.injEq]
    constructor
    · linear_combination s * h
    · linear_combination d * h

@[simp] theorem sdEquiv_apply (v : R × R) : sdEquiv v = sd v.1 v.2 := rfl

/-- The joint residue view is injective in the factor pair. -/
theorem sd_injective : Function.Injective fun v : R × R => sd v.1 v.2 :=
  sdEquiv.injective

/-! ## 2. The `p ↔ q` symmetry -/

omit [Invertible (2:R)] in
/-- Swapping the two factors flips the gap coordinate and fixes the sum coordinate. -/
theorem sd_swap (p q : R) : sd q p = ((sd p q).1, -(sd p q).2) := by
  simp only [sd, Prod.mk.injEq]
  constructor <;> ring

/-- The recovered product is invariant under `d ↦ -d`, i.e. under `p ↔ q`. -/
theorem prodOf_neg_snd (s d : R) : prodOf (s, -d) = prodOf (s, d) := by
  simp only [prodOf]
  ring

/-- `p ↔ q` symmetry of the recovered product, in the form used by the routing table. -/
theorem prodOf_sd_swap (p q : R) : prodOf (sd q p) = prodOf (sd p q) := by
  rw [prodOf_sd, prodOf_sd]; ring

end CommRing

/-! ## 3. The modulus of the experiment: `m = 31` -/

instance : Invertible (2 : ZMod 31) := ⟨16, by decide, by decide⟩

instance : Invertible (2 : ZMod 5) := ⟨3, by decide, by decide⟩

/-- **The sum view alone does not determine the product.**  Mod `31`, the pairs `(1,2)` and
`(0,3)` share the sum `3` but have products `2 ≠ 0`.  This is the algebraic content of the
`3.9%` sum-view row: `s` is a strictly coarser statistic than `N`. -/
theorem sum_view_not_injective :
    ∃ p q p' q' : ZMod 31, p + q = p' + q' ∧ p * q ≠ p' * q' :=
  ⟨1, 2, 0, 3, by decide, by decide⟩

/-- **The gap view alone does not determine the product.**  Mod `31`, `(1,2)` and `(0,1)`
share the gap `1` but have products `2 ≠ 0`. -/
theorem gap_view_not_injective :
    ∃ p q p' q' : ZMod 31, q - p = q' - p' ∧ p * q ≠ p' * q' :=
  ⟨1, 2, 0, 1, by decide, by decide⟩

/-- **The joint residue view is strictly finer than the product view.**  Mod `31`, the pairs
`(1,6)` and `(2,3)` have the same product `6` but different sum/difference coordinates.  With
`prod_eq_of_sd_eq` this says: the `(s,d)`-partition refines the `N`-partition, *strictly*. -/
theorem joint_view_strictly_finer :
    ∃ p q p' q' : ZMod 31, p * q = p' * q' ∧ sd p q ≠ sd p' q' :=
  ⟨1, 6, 2, 3, by decide, by decide⟩

/-- Mod `31` the product map is not injective on pairs even up to the `p ↔ q` swap: the
fibre over `6` contains `(1,6)` and `(2,3)`, which are not swaps of each other. -/
theorem product_fibre_not_a_swap_orbit :
    ∃ p q p' q' : ZMod 31,
      p * q = p' * q' ∧ (p, q) ≠ (p', q') ∧ (p, q) ≠ (q', p') :=
  ⟨1, 6, 2, 3, by decide, by decide, by decide⟩

/-! ## 4. The size of the hint -/

theorem card_residue_pairs : Fintype.card (ZMod 31 × ZMod 31) = 961 := by
  simp [ZMod]

/-- **The factor-residue hint is a 10-bit hint.**  The pair `(p mod 31, q mod 31)` ranges
over `961 < 2^10` values, so revealing it costs strictly less than ten bits.  This is the
budget against which the measured `+0.5189` bits of hint value must be compared. -/
theorem logb_card_sd_lt_ten :
    Real.logb 2 (Fintype.card (ZMod 31 × ZMod 31) : ℝ) < 10 := by
  rw [card_residue_pairs]
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hlt : Real.log (961 : ℝ) < Real.log ((2 : ℝ) ^ (10 : ℕ)) :=
    Real.log_lt_log (by norm_num) (by norm_num)
  rw [Real.log_pow] at hlt
  rw [Real.logb, div_lt_iff₀ h2]
  push_cast at hlt ⊢
  linarith

end SumDiffSplit