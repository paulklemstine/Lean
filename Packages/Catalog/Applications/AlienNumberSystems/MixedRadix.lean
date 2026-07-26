import Mathlib

/-!
# Alien Number Systems: the general mixed-radix (variable-base) positional system

`Nat.digits b` formalizes the *uniform* base-`b` positional system: every position
carries the same base `b`.  This file develops the strictly more general
**mixed-radix** (a.k.a. *variable-base* or *alien*) positional system, in which each
position `i` may carry its **own** base `bᵢ`.

The system is specified by a finite list of bases `bs = [b₀, b₁, …, b_{k-1}]`.  A digit
list `ds = [d₀, d₁, …, d_{k-1}]` (least significant first) denotes the value

`mval bs ds = d₀ + b₀·(d₁ + b₁·(d₂ + ⋯))`,

a Horner evaluation.  The digit-extraction map `mdigits bs n` peels off `n % b₀`, then
recurses on `n / b₀` with the remaining bases.

## Main results

* `mval_mdigits` : `mval bs (mdigits bs n) = n % bs.prod` — the master reconstruction law.
* `mval_mdigits_of_lt` : numbers below the *capacity* `bs.prod` round-trip exactly.
* `mdigits_forall₂_lt` : extracted digits are *valid* (`dᵢ < bᵢ`) when every base is positive.
* `mval_lt_prod` : a valid digit list denotes a value `< bs.prod`.
* `mdigits_mval` : valid digit lists round-trip the other way — **uniqueness** of digits.
* `mixedRadixEquiv` : the crowning bijection `Fin bs.prod ≃ {ds // valid digit list}`.

## Specializations ("beyond base-N")

* `MixedRadix.uniformBase` : with `bs = replicate k b` the capacity is `bᵏ`, recovering the
  ordinary uniform base-`b` system as a special case; `mval_replicate_eq_ofDigits` shows the
  alien evaluation literally restricts to Mathlib's `Nat.ofDigits`, and `uniform_roundtrip`
  recovers the classical positional-system theorem.
* `MixedRadix.Factorial` : with `bs = [2, 3, …, k+1]` the capacity is `(k+1)!` and the
  digit bound is `dᵢ ≤ i+1` — the **factorial number system** (factoradic), the canonical
  example of an "alien", genuinely non-uniform, base.

-- !-- Lab Notes -- !--
-- Hypothesis: `Nat.digits` is the uniform shadow of a one-line-more-general object where
--   the per-position base is allowed to vary; existence/uniqueness of representations
--   should be a clean structural induction on the *list of bases* (no well-founded
--   recursion, unlike `Nat.digits`).
-- Experiment: defined `mval`/`mdigits` by structural recursion on the base list and
--   computed factoradic [0,2,0,4] for 100 (= 2·2!+4·4!) and base-10 [3,2,7] for 723.
-- Result: the master law `mval bs (mdigits bs n) = n % bs.prod` reduces, in the inductive
--   step, to exactly `Nat.mod_mul`; everything else (bounds, uniqueness, the bijection)
--   follows from it plus `List.Forall₂`.
-- Insight: the *capacity* of an alien base is the **product** of its digits' bases, the
--   direct generalization of `bᵏ`; the factorial system is the instance `bᵢ = i+2` whose
--   capacity telescopes to `(k+1)!`.
-- Failure analysis: stating digit validity via indexed `dᵢ < bᵢ` is painful; phrasing it
--   as `List.Forall₂ (· < ·) ds bs` makes both round-trips fall out by induction.
-- Iteration 2 (bridge): hypothesized the alien `mval` should *restrict* to Mathlib's
--   `Nat.ofDigits` on uniform bases.  Confirmed by `mval_replicate_eq_ofDigits` (length
--   side-condition `ds.length ≤ k`), establishing the system as a conservative extension
--   of the existing base-N library rather than a parallel reimplementation.
-- !-- End Lab Notes -- !--
-/

namespace MixedRadix

/-- Value of a digit list `ds` in the mixed-radix system with bases `bs`
(least significant first): `d₀ + b₀·(d₁ + b₁·(d₂ + ⋯))`. -/
def mval : List ℕ → List ℕ → ℕ
  | _, [] => 0
  | [], d :: _ => d
  | b :: bs', d :: ds' => d + b * mval bs' ds'

/-- Digit list of `n` in the mixed-radix system with bases `bs` (least significant
first), obtained greedily: `n % b₀ :: mdigits (rest) (n / b₀)`. -/
def mdigits : List ℕ → ℕ → List ℕ
  | [], _ => []
  | b :: bs', n => (n % b) :: mdigits bs' (n / b)

@[simp] lemma mval_nil_right (bs : List ℕ) : mval bs [] = 0 := by
  cases bs <;> rfl

@[simp] lemma mdigits_nil (n : ℕ) : mdigits [] n = [] := rfl

@[simp] lemma mdigits_cons (b : ℕ) (bs : List ℕ) (n : ℕ) :
    mdigits (b :: bs) n = (n % b) :: mdigits bs (n / b) := rfl

/-
The digit list always has exactly as many entries as there are bases.
-/
lemma mdigits_length (bs : List ℕ) (n : ℕ) : (mdigits bs n).length = bs.length := by
  induction bs generalizing n <;> aesop

/-
**Master reconstruction law.** The value of the extracted digits equals `n` reduced
modulo the system's capacity `bs.prod`.
-/
lemma mval_mdigits (bs : List ℕ) (n : ℕ) : mval bs (mdigits bs n) = n % bs.prod := by
  induction' bs with b bs ih generalizing n;
  · simp +arith +decide [ mdigits ];
    rw [ Nat.mod_one ];
  · convert congr_arg ( fun x => n % b + b * x ) ( ih ( n / b ) ) using 1;
    cases b <;> simp_all +decide [ Nat.mod_mul ]

/-
Numbers below the capacity `bs.prod` are reconstructed exactly.
-/
lemma mval_mdigits_of_lt {bs : List ℕ} {n : ℕ} (h : n < bs.prod) :
    mval bs (mdigits bs n) = n := by
  rw [ mval_mdigits, Nat.mod_eq_of_lt h ]

/-
Extracted digits are **valid**: each is strictly below its position's base,
provided every base is positive.
-/
lemma mdigits_forall₂_lt {bs : List ℕ} (hpos : ∀ b ∈ bs, 0 < b) (n : ℕ) :
    List.Forall₂ (· < ·) (mdigits bs n) bs := by
  induction' bs with b bs ih generalizing n;
  · exact List.Forall₂.nil;
  · simp_all +decide [ mdigits ];
    exact Nat.mod_lt _ hpos.1

/-
A valid digit list denotes a value strictly below the capacity.
-/
lemma mval_lt_prod {bs ds : List ℕ} (h : List.Forall₂ (· < ·) ds bs) :
    mval bs ds < bs.prod := by
  induction' h with b bs ds ih;
  · decide +revert;
  · simp +arith +decide [ mval ];
    nlinarith

/-
**Uniqueness of digits.** A valid digit list is recovered exactly by `mdigits`
from the value it denotes.
-/
lemma mdigits_mval {bs ds : List ℕ} (h : List.Forall₂ (· < ·) ds bs) :
    mdigits bs (mval bs ds) = ds := by
  induction' ds with d ds ih generalizing bs;
  · cases bs <;> trivial;
  · rcases bs with ( _ | ⟨ b, bs ⟩ ) <;> simp_all +decide [ mval ];
    rw [ Nat.add_mul_div_left _ _ ( by linarith ) ];
    exact ⟨ Nat.mod_eq_of_lt h.1, by rw [ Nat.div_eq_of_lt h.1, zero_add, ih h.2 ] ⟩

/-- **Crowning bijection.** For a positive base list, the residues `Fin bs.prod` are in
bijection with the valid digit lists of the mixed-radix system. -/
noncomputable def mixedRadixEquiv (bs : List ℕ) (hpos : ∀ b ∈ bs, 0 < b) :
    Fin bs.prod ≃ {ds : List ℕ // List.Forall₂ (· < ·) ds bs} where
  toFun n := ⟨mdigits bs n.1, mdigits_forall₂_lt hpos n.1⟩
  invFun ds := ⟨mval bs ds.1, mval_lt_prod ds.2⟩
  left_inv n := by
    apply Fin.ext
    simpa using mval_mdigits_of_lt n.2
  right_inv ds := by
    apply Subtype.ext
    simpa using mdigits_mval ds.2

/-! ### Specialization 1: the ordinary uniform base-`b` system -/

namespace uniformBase

/-
With `k` copies of the base `b`, the capacity is `bᵏ`: the uniform base-`b`
system is the special case of all bases equal.
-/
lemma prod_replicate (b k : ℕ) : (List.replicate k b).prod = b ^ k := by
  rw [ List.prod_replicate ]

/-
**Bridge to Mathlib.** On a uniform base list, the mixed-radix evaluation `mval`
agrees with Mathlib's base-`b` evaluation `Nat.ofDigits`, provided the digit list is no
longer than the supply of bases.  Thus the alien system strictly extends `Nat.ofDigits`.
-/
lemma mval_replicate_eq_ofDigits (b : ℕ) (ds : List ℕ) (k : ℕ) (h : ds.length ≤ k) :
    mval (List.replicate k b) ds = Nat.ofDigits b ds := by
  induction ds generalizing k <;> simp_all +arith +decide [ Nat.ofDigits ];
  induction k <;> simp_all +arith +decide [ List.replicate ];
  cases h.eq_or_lt <;> simp_all +arith +decide [ mval ]

/-
**Uniform round-trip.** A number below `bᵏ` is reconstructed exactly from its
length-`k` uniform base-`b` digits — the classical positional-system theorem recovered
as the uniform instance of the alien framework.
-/
lemma uniform_roundtrip {b k n : ℕ} (h : n < b ^ k) :
    mval (List.replicate k b) (mdigits (List.replicate k b) n) = n := by
  convert mval_mdigits_of_lt _;
  simpa [ List.prod_replicate ] using h

end uniformBase

/-! ### Specialization 2: the factorial number system (factoradic) -/

namespace Factorial

/-- Bases of the factorial number system for numbers below `(k+1)!`:
`[2, 3, …, k+1]`. -/
def bases (k : ℕ) : List ℕ := (List.range k).map (· + 2)

/-
The capacity of the length-`k` factorial system telescopes to `(k+1)!`.
-/
lemma prod_bases (k : ℕ) : (bases k).prod = Nat.factorial (k + 1) := by
  induction' k with k ih;
  · rfl;
  · simp_all +decide [ bases, List.range_succ ];
    exact Nat.factorial_succ _ ▸ mul_comm _ _

/-
Every factorial base is positive (in fact `≥ 2`).
-/
lemma bases_pos (k : ℕ) : ∀ b ∈ bases k, 0 < b := by
  exact fun b hb => Nat.pos_of_ne_zero ( by obtain ⟨ m, hm, rfl ⟩ := List.mem_map.mp hb; positivity )

/-
The factorial system represents exactly `{0, 1, …, (k+1)! - 1}`: numbers below
`(k+1)!` round-trip through their factoradic digits.
-/
lemma factoradic_roundtrip {k n : ℕ} (h : n < Nat.factorial (k + 1)) :
    mval (bases k) (mdigits (bases k) n) = n := by
  convert mval_mdigits_of_lt _;
  exact h.trans_le ( by rw [ prod_bases ] )

/-- The factoradic digits are valid, i.e. the `i`-th digit is `< i + 2` (`≤ i + 1`). -/
lemma factoradic_digits_valid (k n : ℕ) :
    List.Forall₂ (· < ·) (mdigits (bases k) n) (bases k) :=
  mdigits_forall₂_lt (bases_pos k) n

end Factorial

end MixedRadix