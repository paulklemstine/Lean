import Mathlib
import Shared.GrassmannJq2LineCounts

/-! # Arithmetic core of the Bruen–Drudge construction on `J_q(4,2)`

A *Cameron–Liebler line class* of `PG(3,q)` (equivalently a Boolean degree-one function
on the Grassmann scheme `J_q(4,2)`) carries an integer *parameter* `x` with
`0 ≤ x ≤ q^2 + 1`.  Taking the set-theoretic complement of a class with parameter `x`
yields a class with parameter `q^2 + 1 - x`, so a class is *self-complementary* exactly
when `x = (q^2 + 1)/2`.

The Bruen–Drudge construction produces, for odd `q`, a Cameron–Liebler line class with
this self-complementary parameter
`bdParam q = (q^2 + 1)/2`.

This file isolates the **number-theoretic core** of that construction, which can be
proved unconditionally:

* `bdParam_two_mul` / `bdParam_self_complement`: `bdParam q` really is the half of
  `q^2 + 1` (an integer, using that `q` is odd), and it is self-complementary.
* `bdParam_gt_two` / `bdParam_lt`: for `q ≥ 3` the parameter lies strictly between the
  trivial values, `2 < bdParam q < q^2 - 1`.

The **geometric realizability** (that such a class actually exists) is *not* assumed and
*not* proved here.  Instead we record the conditional consequence: *if* a Cameron–Liebler
class with parameter `bdParam q` exists, *then* the corresponding Boolean degree-one
function is non-trivial (non-constant).  This is the content of
`CLClass.toFun_not_constant`.
-/

namespace BruenDrudge

open Shared.GrassmannJq2

/-- The self-complementary Bruen–Drudge parameter `(q^2 + 1)/2` (natural-number
division; it is a genuine integer precisely when `q` is odd, see `bdParam_two_mul`). -/
def bdParam (q : ℕ) : ℕ := (q ^ 2 + 1) / 2

/-! ## Part 1 — `bdParam q` is an integer (`q` odd) -/

/-- For odd `q`, `q^2 + 1` is even, so `bdParam q` is a genuine integer:
`2 * bdParam q = q^2 + 1`. -/
theorem bdParam_two_mul {q : ℕ} (hq : Odd q) : 2 * bdParam q = q ^ 2 + 1 := by
  -- Since $q$ is odd, $q^2$ is also odd, and hence $q^2 + 1$ is even.
  have h_even : Even (q^2 + 1) := by
    grind;
  exact Nat.mul_div_cancel' ( even_iff_two_dvd.mp h_even ) ▸ rfl

/-! ## Part 3 — self-complementarity -/

/-- Self-complementary property: `bdParam q + bdParam q = q^2 + 1`. -/
theorem bdParam_self_complement {q : ℕ} (hq : Odd q) :
    bdParam q + bdParam q = q ^ 2 + 1 := by
  convert bdParam_two_mul hq using 1 ; ring

/-! ## Part 2 — non-triviality bounds `2 < bdParam q < q^2 - 1` -/

/-- Lower bound: for `q ≥ 3` we have `2 < bdParam q` (indeed `4 < bdParam q`). -/
theorem bdParam_gt_two {q : ℕ} (hq : 3 ≤ q) : 2 < bdParam q := by
  exact Nat.le_div_iff_mul_le zero_lt_two |>.2 ( by nlinarith )

/-- Sharper lower bound used in the original write-up: `4 < bdParam q` for `q ≥ 3`. -/
theorem bdParam_gt_four {q : ℕ} (hq : 3 ≤ q) (ho : Odd q) : 4 < bdParam q := by
  rcases ho with ⟨ k, rfl ⟩;
  unfold bdParam; rw [ Nat.lt_iff_add_one_le ] ; rw [ Nat.le_div_iff_mul_le ] <;> rcases k with ( _ | _ | k ) <;> norm_num at * ; nlinarith;

/-- Upper bound: for `q ≥ 3` we have `bdParam q < q^2 - 1`. -/
theorem bdParam_lt {q : ℕ} (hq : 3 ≤ q) : bdParam q < q ^ 2 - 1 := by
  rw [ lt_tsub_iff_right, bdParam ];
  nlinarith [ Nat.div_mul_le_self ( q ^ 2 + 1 ) 2 ]

/-- Combined non-triviality: `bdParam q` lies strictly between the trivial parameter
values `2` and `q^2 - 1`. -/
theorem bdParam_nontrivial {q : ℕ} (hq : 3 ≤ q) :
    2 < bdParam q ∧ bdParam q < q ^ 2 - 1 :=
  ⟨bdParam_gt_two hq, bdParam_lt hq⟩

/-! ## Part 4 — conditional consequence for the Boolean degree-one function

We model a Cameron–Liebler line class on `J_q(4,2)` as its indicator Boolean function on
the finite set of lines, together with its Cameron–Liebler parameter `param`.  The
defining counting identity is that the number of lines in the class equals
`param * (q^2 + q + 1)` (`param` copies of the number of lines through a point); this is
exactly the property that a Boolean *degree-one* function on the Grassmann scheme
satisfies.  The geometric existence of such a function is **not** assumed: `CLClass` is a
hypothesis to be supplied by the geometric construction. -/

/-- A Cameron–Liebler line class on `J_q(4,2)`, recorded via its Boolean indicator
function on the finite set of `lines`.  The field `card_eq` is the degree-one counting
identity relating the size of the class to its parameter. -/
structure CLClass (q : ℕ) (lines : Type*) [Fintype lines] [DecidableEq lines] where
  /-- The Boolean degree-one function: the indicator of the line class. -/
  toFun : lines → Bool
  /-- The Cameron–Liebler parameter `x`. -/
  param : ℕ
  /-- Degree-one counting identity: the number of lines in the class is `param` times the
  number of lines through a point. -/
  card_eq :
    (Finset.univ.filter (fun l => toFun l = true)).card = param * numLinesThroughPoint q

variable {q : ℕ} {lines : Type*} [Fintype lines] [DecidableEq lines]

/-- If the parameter is positive, the class is non-empty, so the Boolean function takes
the value `true` somewhere. -/
theorem CLClass.exists_true (C : CLClass q lines) (hpos : 0 < C.param) :
    ∃ l, C.toFun l = true := by
  by_contra h_empty;
  have := C.card_eq; simp_all +decide ;
  exact absurd ( this.resolve_left hpos.ne' ) ( by exact ne_of_gt ( Shared.GrassmannJq2.numLinesThroughPoint_pos q ) )

/-- If the parameter is below the maximal value `q^2 + 1` and the ambient line count is
the true Grassmann count `numLines q`, the class is not everything, so the Boolean
function takes the value `false` somewhere. -/
theorem CLClass.exists_false (C : CLClass q lines)
    (hcard : Fintype.card lines = numLines q) (hlt : C.param < q ^ 2 + 1) :
    ∃ l, C.toFun l = false := by
  contrapose! hlt; simp_all +decide [ numLines ] ;
  have := C.card_eq; simp_all +decide [ Finset.filter_true_of_mem, numLinesThroughPoint ] ;
  nlinarith only [ this ]

/-- **Conditional non-triviality.**  If a Cameron–Liebler class with the Bruen–Drudge
parameter `bdParam q` exists on the genuine line set of `J_q(4,2)` (with `q ≥ 3`),
then its associated Boolean degree-one function is non-constant — neither identically
`false` nor identically `true`.  This separates the (unconditional) number theory from the
geometric realizability assumption carried by `CLClass`.  (For odd `q` the parameter
`bdParam q` is moreover a genuine integer, see `bdParam_two_mul`; oddness is not needed
for the non-constancy conclusion itself.) -/
theorem CLClass.toFun_not_constant (C : CLClass q lines)
    (hcard : Fintype.card lines = numLines q)
    (hparam : C.param = bdParam q) (hq : 3 ≤ q) :
    (∃ l, C.toFun l = true) ∧ (∃ l, C.toFun l = false) := by
  refine' ⟨ CLClass.exists_true C _, CLClass.exists_false C _ _ ⟩;
  · exact hparam.symm ▸ bdParam_gt_two hq |> lt_of_le_of_lt ( by norm_num );
  · exact hcard;
  · linarith [ bdParam_lt hq, Nat.sub_add_cancel ( by nlinarith : 1 ≤ q ^ 2 ) ]

end BruenDrudge