import Mathlib

/-!
# Base `i - 1`: Unique Representation of the Gaussian Integers

This file develops arithmetic in the **complex base** `β = i - 1` and proves the
central structural theorem of the system (a theorem of W. Penney, 1965):

> **Every Gaussian integer has a unique representation in base `i - 1` using the
> digits `0` and `1`.**

This is the two–dimensional analogue of the negabinary phenomenon: a *single*
radix `β = i - 1`, with the *two* real digits `{0, 1}` and **no sign and no
imaginary digit**, names every element of `ℤ[i]` — every `a + b·i` with
`a, b ∈ ℤ` — exactly once.

A representation is a finite list of bits `l : List Bool` (least–significant digit
first).  Its value is the Horner evaluation
`cvalue (b :: bs) = digit b + β · cvalue bs`, i.e. `∑ᵢ dᵢ · βⁱ`.

The canonical representations are those with no leading zero in the top position
(`Canonical`: the list does not end in `false`).  The main theorem
`complexBase_unique_rep` states that the value map from canonical bit lists to
`GaussianInt` is a bijection.

## Contrarian note

The naive termination measure "the Gaussian norm strictly decreases at every
digit step" is **false**: `complexBase_naive_measure_fails` exhibits a nonzero
Gaussian integer whose base-`(i-1)` successor has the *same* norm.  The genuine
subtlety of a complex base lives precisely in this finite set of five exceptional
points `{i, -i, -1, -2+i, -2-i}`, which is why existence is not a one–line norm
induction but requires isolating those points explicitly.
-/

namespace ComplexBaseIMinusOne

open scoped Classical

/-- The complex radix `β = i - 1`, as a Gaussian integer `⟨-1, 1⟩`. -/
def beta : GaussianInt := ⟨-1, 1⟩

/-- The Gaussian value of a single digit `b ∈ {0, 1}`. -/
def digit (b : Bool) : GaussianInt := if b then 1 else 0

/-- The value of a base-`(i-1)` bit list (least–significant digit first), evaluated
by Horner's rule with radix `β = i - 1`:
`cvalue (b :: bs) = digit b + β * cvalue bs`. -/
def cvalue : List Bool → GaussianInt
  | [] => 0
  | b :: bs => digit b + beta * cvalue bs

/-- A bit list is **canonical** if it does not end in a `false` (leading-zero-free
in the most significant position). The empty list is canonical. -/
def Canonical (l : List Bool) : Prop := l.getLast? ≠ some false

/-- The integer measure `re² + im²` (the Gaussian norm), used as a termination
measure for the existence proof. -/
def gnorm (z : GaussianInt) : ℤ := z.re ^ 2 + z.im ^ 2

/-- The forced least–significant bit of `z`: the parity of `re + im`. -/
def bitOf (z : GaussianInt) : Bool := decide ((z.re + z.im) % 2 = 1)

/-- The integer value (`0` or `1`) of the forced digit `bitOf z`. -/
def dz (z : GaussianInt) : ℤ := if bitOf z then 1 else 0

/-- The base-`(i-1)` successor: `nextGI z = (z - digit (bitOf z)) / β`. -/
def nextGI (z : GaussianInt) : GaussianInt :=
  ⟨(z.im - (z.re - dz z)) / 2, -((z.re - dz z) + z.im) / 2⟩

@[simp] theorem cvalue_nil : cvalue [] = 0 := rfl

theorem cvalue_cons (b : Bool) (bs : List Bool) :
    cvalue (b :: bs) = digit b + beta * cvalue bs := rfl

/-
Multiplication by `β = i - 1`: `β * ⟨x, y⟩ = ⟨-x - y, x - y⟩`.
-/
theorem beta_mul_re (w : GaussianInt) : (beta * w).re = -w.re - w.im := by
  have h_mul : beta * w = ⟨-w.re - w.im, w.re - w.im⟩ := by
    exact Zsqrtd.ext ( by simp +decide [ beta ] ; ring ) ( by simp +decide [ beta ] ; ring )
  exact h_mul ▸ rfl

theorem beta_mul_im (w : GaussianInt) : (beta * w).im = w.re - w.im := by
  -- By definition of multiplication in Gaussian integers, we have:
  have h_mul : beta * w = ⟨-w.re - w.im, w.re - w.im⟩ := by
    exact Zsqrtd.ext ( by simp +decide [ beta ] ; ring ) ( by simp +decide [ beta ] ; ring );
  exact h_mul ▸ rfl

/-
The parity of `re + im` recovers the least–significant digit.
-/
theorem par_cvalue_cons (b : Bool) (bs : List Bool) :
    ((cvalue (b :: bs)).re + (cvalue (b :: bs)).im) % 2 = (if b then 1 else 0) := by
  induction' b with b <;> simp_all +decide [ cvalue_cons ];
  · unfold digit beta; norm_num; ring_nf; norm_num [ ← even_iff_two_dvd, parity_simps ] ;
  · unfold digit beta; norm_num;
    grind

theorem digit_inj {a b : Bool} (h : digit a = digit b) : a = b := by
  decide +revert

@[simp] theorem canonical_nil : Canonical [] := by
  simp [Canonical]

/-
Every tail of a canonical list is canonical.
-/
theorem canonical_tail {a : Bool} {as : List Bool} (h : Canonical (a :: as)) :
    Canonical as := by
  cases as <;> simp_all +decide [ Canonical ]

/-
A canonical list with value `0` must be empty: the value map is injective at
`0`.
-/
theorem cvalue_eq_zero_of_canonical :
    ∀ {l : List Bool}, Canonical l → cvalue l = 0 → l = [] := by
  intros l hl hcvalue_zero
  induction' l with a l ih;
  · rfl;
  · rcases a with ( _ | _ ) <;> simp_all +decide;
    · -- Since $cvalue (false :: l) = 0$, we have $beta * cvalue l = 0$. Given that $beta \neq 0$, it follows that $cvalue l = 0$.
      have h_cvalue_l_zero : cvalue l = 0 := by
        simp_all +decide [ cvalue_cons, digit ];
      cases l <;> simp_all +decide [ Canonical ];
    · have := par_cvalue_cons true l; simp_all +decide ;

/-
**Uniqueness.** Two canonical bit lists with equal base-`(i-1)` value are
equal.
-/
theorem cvalue_injective :
    ∀ {l₁ l₂ : List Bool}, Canonical l₁ → Canonical l₂ →
      cvalue l₁ = cvalue l₂ → l₁ = l₂ := by
  intros l₁ l₂ h₁ h₂ h₃; induction' l₁ with a as ih generalizing l₂ <;> induction' l₂ with b bs ih' <;> simp_all +decide ;
  · exact absurd ( cvalue_eq_zero_of_canonical h₂ h₃.symm ) ( by aesop );
  · exact absurd ( cvalue_eq_zero_of_canonical h₁ h₃ ) ( by aesop );
  · -- By the properties of the digit function and the induction hypothesis, we can deduce that `a = b`.
    have h_eq : a = b := by
      apply_fun fun z => ( z.re + z.im ) % 2 at h₃; simp_all +decide [ par_cvalue_cons ] ;
      grind +qlia;
    simp_all +decide [ cvalue_cons ];
    grind +locals

/-
`dz z` is exactly the parity residue `(z.re + z.im) % 2`.
-/
theorem dz_eq_emod (z : GaussianInt) : dz z = (z.re + z.im) % 2 := by
  unfold dz bitOf; split_ifs <;> simp_all +decide ; omega;

/-
The coordinate differences used in `nextGI` are even.
-/
theorem nextGI_even (z : GaussianInt) : ((z.re - dz z) + z.im) % 2 = 0 := by
  norm_num [ dz_eq_emod ] ; omega;

/-
**Reconstruction.** `digit (bitOf z) + β * nextGI z = z`, i.e. `nextGI` really
is the quotient in the base-`(i-1)` division step.
-/
theorem reconstruct (z : GaussianInt) : digit (bitOf z) + beta * nextGI z = z := by
  apply Zsqrtd.ext;
  · unfold digit beta nextGI;
    split_ifs <;> simp_all +decide [ bitOf, dz ];
    · grind;
    · split_ifs <;> simp_all +decide [ Int.emod_eq_zero_of_dvd ] ; omega;
  · unfold digit beta nextGI;
    split_ifs <;> simp +decide [ * ];
    · grind;
    · grind +splitImp

/-- The measure is nonnegative. -/
theorem gnorm_nonneg (z : GaussianInt) : 0 ≤ gnorm z := by
  unfold gnorm; positivity

/-
Twice the successor's measure equals `(re - d)² + im²`.
-/
theorem two_gnorm_nextGI (z : GaussianInt) :
    2 * gnorm (nextGI z) = (z.re - dz z) ^ 2 + z.im ^ 2 := by
  obtain ⟨ k, hk ⟩ := Int.modEq_zero_iff_dvd.mp ( nextGI_even z );
  obtain ⟨ m, hm ⟩ := Int.modEq_zero_iff_dvd.mp ( show z.im - ( z.re - dz z ) ≡ 0 [ZMOD 2] from Int.modEq_zero_iff_dvd.mpr ⟨ k - ( z.re - dz z ), by linarith ⟩ );
  unfold gnorm nextGI; norm_num [ show z.re - dz z = k - m by linarith, show z.im = k + m by linarith ] ; ring_nf;
  norm_num [ Int.neg_ediv_of_dvd, dvd_mul_of_dvd_right ]

/-
**Key dispatch lemma.** For a nonzero Gaussian integer, either it is one of the
five exceptional points, or its base-`(i-1)` successor has strictly smaller
measure.
-/
theorem decrease_or_special (z : GaussianInt) (hz : z ≠ 0) :
    (z = ⟨0, 1⟩ ∨ z = ⟨0, -1⟩ ∨ z = ⟨-1, 0⟩ ∨ z = ⟨-2, 1⟩ ∨ z = ⟨-2, -1⟩) ∨
      gnorm (nextGI z) < gnorm z := by
  by_cases h : ( z.re - dz z ) ^ 2 + z.im ^ 2 < 2 * ( z.re ^ 2 + z.im ^ 2 );
  · exact Or.inr ( by linarith [ two_gnorm_nextGI z, show gnorm z = z.re ^ 2 + z.im ^ 2 from rfl ] );
  · -- From ¬(strict), we have |r| ≤ 2 and |s| ≤ 1.
    have hr_bound : -2 ≤ z.re ∧ z.re ≤ 2 := by
      constructor <;> nlinarith [ sq_nonneg ( z.re - 1 ), sq_nonneg ( z.re + 1 ), dz_eq_emod z, Int.emod_nonneg ( z.re + z.im ) two_ne_zero, Int.emod_lt_of_pos ( z.re + z.im ) two_pos ]
    have hs_bound : -1 ≤ z.im ∧ z.im ≤ 1 := by
      constructor <;> nlinarith [ show dz z ≥ 0 by exact ( by unfold dz; split_ifs <;> norm_num ), show dz z ≤ 1 by exact ( by unfold dz; split_ifs <;> norm_num ) ];
    rcases hr_bound with ⟨ hr₁, hr₂ ⟩ ; rcases hs_bound with ⟨ hs₁, hs₂ ⟩ ; interval_cases _ : z.re <;> interval_cases _ : z.im <;> simp_all +decide only [] ;
    all_goals simp_all +decide only [dz, bitOf];
    all_goals simp_all +decide [ Zsqrtd.ext_iff ]

/-
**Existence.** Every Gaussian integer is the value of some canonical bit
list.
-/
theorem exists_canonical (z : GaussianInt) :
    ∃ l : List Bool, Canonical l ∧ cvalue l = z := by
  -- By induction on the norm of $z$, we can construct such a canonical list.
  have h_ind : ∀ n : ℕ, (∀ z : GaussianInt, gnorm z = n → ∃ l : List Bool, Canonical l ∧ cvalue l = z) := by
    intro n;
    induction' n using Nat.strong_induction_on with n ih generalizing z;
    intro z hz
    by_cases hz_zero : z = 0;
    · exact ⟨ [ ], by simp +decide [ hz_zero, Canonical ] ⟩;
    · by_cases hz_special : z = ⟨0, 1⟩ ∨ z = ⟨0, -1⟩ ∨ z = ⟨-1, 0⟩ ∨ z = ⟨-2, 1⟩ ∨ z = ⟨-2, -1⟩;
      · rcases hz_special with rfl | rfl | rfl | rfl | rfl
        · exact ⟨[true, true], by unfold Canonical; decide, by decide⟩
        · exact ⟨[true, true, true], by unfold Canonical; decide, by decide⟩
        · exact ⟨[true, false, true, true, true], by unfold Canonical; decide, by decide⟩
        · exact ⟨[true, true, true, true, true], by unfold Canonical; decide, by decide⟩
        · exact ⟨[true, true, false, true, false, true, true, true], by unfold Canonical; decide, by decide⟩
      · obtain ⟨l', hl'⟩ : ∃ l' : List Bool, Canonical l' ∧ cvalue l' = nextGI z := by
          have h_decrease : gnorm (nextGI z) < n := by
            have := decrease_or_special z hz_zero; aesop;
          exact ih ( Int.toNat ( gnorm ( nextGI z ) ) ) ( by linarith [ Int.toNat_of_nonneg ( show 0 ≤ gnorm ( nextGI z ) from by exact add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ) ) ] ) ( nextGI z ) ( nextGI z ) ( by rw [ Int.toNat_of_nonneg ( show 0 ≤ gnorm ( nextGI z ) from by exact add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ) ) ] );
        use bitOf z :: l';
        cases l' <;> simp_all +decide [ Canonical ];
        · rw [ eq_comm ] at hl';
          have := reconstruct z; simp_all +decide [ cvalue_cons, cvalue_nil ] ;
          cases h : bitOf z <;> simp_all +decide [ digit ];
        · simp_all +decide [ cvalue_cons ];
          exact reconstruct z;
  exact h_ind ( Int.toNat ( gnorm z ) ) z ( by rw [ Int.toNat_of_nonneg ( gnorm_nonneg z ) ] )

/-- **Main theorem: unique representation in base `i - 1` (Penney's theorem).**
Every Gaussian integer is the base-`(i-1)` value of exactly one canonical bit
list.  Thus the digits `{0, 1}` of the complex base `i - 1` name every Gaussian
integer — real, imaginary, and everything in between — uniquely and without a
sign. -/
theorem complexBase_unique_rep (z : GaussianInt) :
    ∃! l : List Bool, Canonical l ∧ cvalue l = z := by
  obtain ⟨l, hcanon, hv⟩ := exists_canonical z
  refine ⟨l, ⟨hcanon, hv⟩, ?_⟩
  rintro y ⟨hy, hy'⟩
  exact cvalue_injective hy hcanon (hy'.trans hv.symm)

/-
**Contrarian result (disproof).** The naive termination measure "the Gaussian
norm strictly decreases at every base-`(i-1)` digit step" is *false*: the point
`i = ⟨0,1⟩` is nonzero yet its successor `⟨1,0⟩` has the *same* norm.
-/
theorem complexBase_naive_measure_fails :
    ∃ z : GaussianInt, z ≠ 0 ∧ gnorm (nextGI z) = gnorm z := by
  exists ⟨ 0, 1 ⟩

end ComplexBaseIMinusOne