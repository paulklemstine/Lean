/-
# The type entropy separates the two abelian groups of degree 12

Second research cycle.  The measured quantity at this rung is a single real
number, `H(T) = 1.7296` bits.  Is that number *informative* about the Galois
group, or is it an accident of the degree?

At degree 12 there are exactly two abelian groups, `C₁₂` and `C₆ × C₂`.  We compute
the order-profile (type) entropy of both in closed form:

* `orderEntropy_C12`     : `H(C₁₂)     = 5/6 + log₂ 3 = 2.41830...`
* `orderEntropy_C6xC2`   : `H(C₆ × C₂) = 4/3 + (log₂ 3)/4 = 1.72957...`

and prove `entropy_separates`: the two values are different, with the clean
threshold `2` between them (`orderEntropy_C12_gt_two`, `orderEntropy_C6xC2_lt_two`).

Consequence (`noncyclic_of_entropy_lt_two`): for a degree-12 abelian rung, the
measured entropy alone certifies non-cyclicity — the value `1.7296 < 2` could not
have come from `C₁₂`.  Finally `entropy_transfer` checks that the *arithmetic*
channel (`p mod 56 ↦ resDeg p`, computed on the 24 reduced residues) and the
*group* channel (order profile of `C₆ × C₂`) carry exactly the same entropy.
-/
import Mathlib
import Pythagorean.Degree12Composite
import Pythagorean.Degree12CompositeEntropy

set_option maxRecDepth 40000

namespace Catalog.Pythagorean.Degree12Composite

open Finset

/-! ## Element orders in `C₁₂` -/

/-- The order function of `ZMod 12`, in decidable form. -/
def ord12 (x : ZMod 12) : ℕ :=
  if (1 : ℕ) • x = 0 then 1
  else if (2 : ℕ) • x = 0 then 2
  else if (3 : ℕ) • x = 0 then 3
  else if (4 : ℕ) • x = 0 then 4
  else if (6 : ℕ) • x = 0 then 6
  else 12

private theorem ord12_spec : ∀ x : ZMod 12,
    (ord12 x) • x = 0 ∧ ∀ k < ord12 x, 0 < k → k • x ≠ 0 := by decide

private theorem ord12_pos : ∀ x : ZMod 12, 0 < ord12 x := by decide

theorem addOrderOf_eq_ord12 (x : ZMod 12) : addOrderOf x = ord12 x := by
  obtain ⟨h1, h2⟩ := ord12_spec x
  exact (addOrderOf_eq_iff (ord12_pos x)).2 ⟨h1, fun m hm hm0 => h2 m hm hm0⟩

/-- The order function of `C₆ × C₂`, in decidable form (via the conductor-56 model). -/
def ordG (g : ZMod 6 × ZMod 2) : ℕ := resDeg (cls g)

theorem addOrderOf_eq_ordG (g : ZMod 6 × ZMod 2) : addOrderOf g = ordG g :=
  addOrderOf_eq_resDeg_cls g

/-! ## The two order-profile entropies -/

/-- The order-profile entropy of a finite additive group: the Shannon entropy of the
order of a uniformly random element. -/
noncomputable def orderEntropy (A : Type*) [AddGroup A] [Fintype A] [DecidableEq A] : ℝ :=
  entropyOut (Finset.univ : Finset A) addOrderOf

private theorem image_ord12 : (Finset.univ : Finset (ZMod 12)).image ord12
    = ({1, 2, 3, 4, 6, 12} : Finset ℕ) := by decide

private theorem card_fiber12 :
    (fiber (Finset.univ : Finset (ZMod 12)) ord12 1).card = 1 ∧
    (fiber (Finset.univ : Finset (ZMod 12)) ord12 2).card = 1 ∧
    (fiber (Finset.univ : Finset (ZMod 12)) ord12 3).card = 2 ∧
    (fiber (Finset.univ : Finset (ZMod 12)) ord12 4).card = 2 ∧
    (fiber (Finset.univ : Finset (ZMod 12)) ord12 6).card = 2 ∧
    (fiber (Finset.univ : Finset (ZMod 12)) ord12 12).card = 4 := by decide

private theorem card_univ12 : (Finset.univ : Finset (ZMod 12)).card = 12 := by decide

/-- **Order-profile entropy of the cyclic group `C₁₂`**: `5/6 + log₂ 3`. -/
theorem orderEntropy_C12 : orderEntropy (ZMod 12) = 5 / 6 + Real.logb 2 3 := by
  have hfun : (addOrderOf : ZMod 12 → ℕ) = ord12 := funext addOrderOf_eq_ord12
  obtain ⟨c1, c2, c3, c4, c6, c12⟩ := card_fiber12
  rw [orderEntropy, hfun, entropyOut, image_ord12]
  rw [show ({1, 2, 3, 4, 6, 12} : Finset ℕ)
      = insert 1 (insert 2 (insert 3 (insert 4 (insert 6 {12})))) from rfl]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_singleton]
  have p : ∀ (d k : ℕ) (r : ℝ), (fiber (Finset.univ : Finset (ZMod 12)) ord12 d).card = k →
      (k : ℝ) / 12 = r → prob (Finset.univ : Finset (ZMod 12)) ord12 d = r := by
    intro d k r hk hr
    rw [prob, hk, card_univ12, ← hr]
    norm_num
  rw [p 1 1 (1/12) c1 (by norm_num), p 2 1 (1/12) c2 (by norm_num),
    p 3 2 (1/6) c3 (by norm_num), p 4 2 (1/6) c4 (by norm_num),
    p 6 2 (1/6) c6 (by norm_num), p 12 4 (1/3) c12 (by norm_num)]
  simp only [nlog2_one_div]
  rw [logb2_twelve, logb2_six]
  ring

private theorem image_ordG : (Finset.univ : Finset (ZMod 6 × ZMod 2)).image ordG
    = ({1, 2, 3, 6} : Finset ℕ) := by decide

private theorem card_fiberG :
    (fiber (Finset.univ : Finset (ZMod 6 × ZMod 2)) ordG 1).card = 1 ∧
    (fiber (Finset.univ : Finset (ZMod 6 × ZMod 2)) ordG 2).card = 3 ∧
    (fiber (Finset.univ : Finset (ZMod 6 × ZMod 2)) ordG 3).card = 2 ∧
    (fiber (Finset.univ : Finset (ZMod 6 × ZMod 2)) ordG 6).card = 6 := by decide

private theorem card_univG : (Finset.univ : Finset (ZMod 6 × ZMod 2)).card = 12 := by decide

/-- **Order-profile entropy of `C₆ × C₂`**: `4/3 + (log₂ 3)/4`, the measured
`1.7296` bits. -/
theorem orderEntropy_C6xC2 :
    orderEntropy (ZMod 6 × ZMod 2) = 4 / 3 + Real.logb 2 3 / 4 := by
  have hfun : (addOrderOf : ZMod 6 × ZMod 2 → ℕ) = ordG := funext addOrderOf_eq_ordG
  obtain ⟨c1, c2, c3, c6⟩ := card_fiberG
  rw [orderEntropy, hfun, entropyOut, image_ordG]
  rw [show ({1, 2, 3, 6} : Finset ℕ) = insert 1 (insert 2 (insert 3 {6})) from rfl]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_singleton]
  have p : ∀ (d k : ℕ) (r : ℝ), (fiber (Finset.univ : Finset (ZMod 6 × ZMod 2)) ordG d).card = k →
      (k : ℝ) / 12 = r → prob (Finset.univ : Finset (ZMod 6 × ZMod 2)) ordG d = r := by
    intro d k r hk hr
    rw [prob, hk, card_univG, ← hr]
    norm_num
  rw [p 1 1 (1/12) c1 (by norm_num), p 2 3 (1/4) c2 (by norm_num),
    p 3 2 (1/6) c3 (by norm_num), p 6 6 (1/2) c6 (by norm_num)]
  simp only [nlog2_one_div]
  rw [logb2_twelve, logb2_four, logb2_six, logb2_two]
  ring

/-! ## Separation -/

theorem orderEntropy_C12_gt_two : 2 < orderEntropy (ZMod 12) := by
  rw [orderEntropy_C12]
  linarith [logb2_three_lower]

theorem orderEntropy_C6xC2_lt_two : orderEntropy (ZMod 6 × ZMod 2) < 2 := by
  rw [orderEntropy_C6xC2]
  linarith [logb2_three_upper]

/-- **Entropy separates the two abelian groups of order 12.**  The order-profile
entropy is a genuine invariant at this degree: `C₁₂` and `C₆ × C₂` are distinguished
by a single real number. -/
theorem entropy_separates : orderEntropy (ZMod 12) ≠ orderEntropy (ZMod 6 × ZMod 2) := by
  have h1 := orderEntropy_C12_gt_two
  have h2 := orderEntropy_C6xC2_lt_two
  intro h
  rw [h] at h1
  linarith

/-- **Entropy certifies non-cyclicity.**  A degree-12 abelian rung whose measured
type entropy is below `2` bits cannot be the cyclic group `C₁₂`; the measured
`1.7296` bits therefore forces the non-cyclic group `C₆ × C₂`. -/
theorem noncyclic_of_entropy_lt_two {H : ℝ} (hH : H < 2) :
    H ≠ orderEntropy (ZMod 12) := by
  intro h
  rw [h] at hH
  linarith [orderEntropy_C12_gt_two]

/-- **Channel transfer.**  The arithmetic channel on the 24 reduced residues mod 56
and the group-theoretic order profile of `C₆ × C₂` carry exactly the same
information: both are `4/3 + (log₂ 3)/4` bits. -/
theorem entropy_transfer :
    entropyOut Units56 resDeg = orderEntropy (ZMod 6 × ZMod 2) := by
  rw [entropyOut_Units56_resDeg, orderEntropy_C6xC2]

end Catalog.Pythagorean.Degree12Composite