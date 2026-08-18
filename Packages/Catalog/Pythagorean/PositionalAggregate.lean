import Pythagorean.AggregateDichotomy

/-!
# The positional (base `B`) interleaved aggregate in `ℤ[i]`

The interleaved aggregate of `Pythagorean.AggregateDichotomy` is injective, but it leaves the
arithmetic world: it is a Gödel-style pairing into `ℕ`.  This file provides an aggregate that
lives in the *same algebraic universe as the product*, namely the Gaussian integers:

`gaggr B f = ∑ i, z_i · B ^ i`,  where `z_i` is the Gaussian integer of the `i`-th member.

The dichotomy then becomes sharply algebraic.  Both aggregates are built from the very same
data inside `ℤ[i]`; the multiplicative one `∏ z_i` forgets the labels of the family, whereas
the additive positional one `∑ z_i B^i` retains them — as soon as the base `B` is larger than
twice the size of every coordinate.

## Main results

* `Pythagorean.int_digits_unique` : uniqueness of balanced base-`B` digit expansions over `ℤ`
  (the arithmetic engine; proved by induction on the length).
* `Pythagorean.gaggr_eq_sum_pow` : the coordinatewise definition of `gaggr` agrees with the
  intrinsic polynomial `∑ i, toGaussian (f i) * B ^ i` in `ℤ[i]`.
* `Pythagorean.gaggr_injOn` : **the positional aggregate is injective** on families whose
  coordinates are balanced-bounded by the base.
* `Pythagorean.gaggr_separates_swap` : an explicit pair of families that the product
  identifies and the positional aggregate separates.
-/

namespace Pythagorean

open PTriple

/-! ## Uniqueness of balanced digit expansions -/

/-- Splitting off the least significant digit of a base-`B` value. -/
private lemma sum_succ_split {n : ℕ} (B : ℤ) (x : Fin (n + 1) → ℤ) :
    (∑ i : Fin (n + 1), x i * B ^ (i : ℕ)) = x 0 + B * ∑ i : Fin n, x i.succ * B ^ (i : ℕ) := by
  rw [Fin.sum_univ_succ, Finset.mul_sum]
  simp only [Fin.val_zero, pow_zero, mul_one, Fin.val_succ, pow_succ]
  congr 1
  exact Finset.sum_congr rfl fun i _ => by ring

/-- **Balanced base-`B` expansions are unique.**  If two integer strings of length `n` have
all their entries bounded in absolute value by `B/2`, then they are equal as soon as the
associated base-`B` values agree.  This is the arithmetic heart of the positional aggregate. -/
theorem int_digits_unique : ∀ {n : ℕ} {B : ℤ}, 0 < B → ∀ x y : Fin n → ℤ,
    (∀ i, 2 * |x i| < B) → (∀ i, 2 * |y i| < B) →
    (∑ i, x i * B ^ (i : ℕ)) = (∑ i, y i * B ^ (i : ℕ)) → x = y
  | 0, _, _, x, y, _, _, _ => by
      funext i
      exact absurd i.isLt (by omega)
  | n + 1, B, hB, x, y, hx, hy, h => by
      have hxsplit := sum_succ_split B x
      have hysplit := sum_succ_split B y
      set X := ∑ i : Fin n, x i.succ * B ^ (i : ℕ) with hX
      set Y := ∑ i : Fin n, y i.succ * B ^ (i : ℕ) with hY
      rw [hxsplit, hysplit] at h
      -- the leading digits agree
      have hdiff : x 0 - y 0 = B * (Y - X) := by linarith
      have hbound : |x 0 - y 0| < B := by
        have h1 := hx 0
        have h2 := hy 0
        calc |x 0 - y 0| ≤ |x 0| + |y 0| := abs_sub _ _
          _ < B := by linarith [abs_nonneg (x 0), abs_nonneg (y 0)]
      have htail : Y - X = 0 := by
        by_contra hne
        have h1 : 1 ≤ |Y - X| := Int.one_le_abs (by omega)
        have h2 : B ≤ |B * (Y - X)| := by
          rw [abs_mul, abs_of_pos hB]
          nlinarith [abs_nonneg (Y - X)]
        rw [← hdiff] at h2
        linarith
      have hhead : x 0 = y 0 := by
        rw [htail, mul_zero] at hdiff
        linarith
      have hXY : X = Y := by linarith
      have hrec : (fun i : Fin n => x i.succ) = (fun i : Fin n => y i.succ) :=
        int_digits_unique hB _ _ (fun i => hx i.succ) (fun i => hy i.succ) (by
          simpa [hX, hY] using hXY)
      funext i
      refine Fin.cases ?_ ?_ i
      · exact hhead
      · intro j
        exact congrFun hrec j

/-! ## The positional aggregate -/

/-- The **positional (base `B`) interleaved aggregate**: the members of the family are placed
at successive powers of `B` inside the Gaussian integers. -/
def gaggr {n : ℕ} (B : ℤ) (f : Fin n → PTriple) : GaussianInt :=
  ⟨∑ i, (f i).a * B ^ (i : ℕ), ∑ i, (f i).b * B ^ (i : ℕ)⟩

private lemma re_sum {ι : Type*} (s : Finset ι) (g : ι → GaussianInt) :
    (∑ i ∈ s, g i).re = ∑ i ∈ s, (g i).re := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih => simp [Finset.sum_insert ha, ih]

private lemma im_sum {ι : Type*} (s : Finset ι) (g : ι → GaussianInt) :
    (∑ i ∈ s, g i).im = ∑ i ∈ s, (g i).im := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih => simp [Finset.sum_insert ha, ih]

/-- The positional aggregate is the value at `B` of the Gaussian polynomial whose coefficients
are the members of the family. -/
theorem gaggr_eq_sum_pow {n : ℕ} (B : ℤ) (f : Fin n → PTriple) :
    gaggr B f = ∑ i, toGaussian (f i) * (B : GaussianInt) ^ (i : ℕ) := by
  have hterm : ∀ i : Fin n, toGaussian (f i) * (B : GaussianInt) ^ (i : ℕ)
      = (⟨(f i).a * B ^ (i : ℕ), (f i).b * B ^ (i : ℕ)⟩ : GaussianInt) := by
    intro i
    have hpow : (B : GaussianInt) ^ (i : ℕ) = ((B ^ (i : ℕ) : ℤ) : GaussianInt) := by
      push_cast; ring
    have hre : ((B : GaussianInt) ^ (i : ℕ)).re = B ^ (i : ℕ) := by
      rw [hpow, Zsqrtd.re_intCast]
    have him : ((B : GaussianInt) ^ (i : ℕ)).im = 0 := by
      rw [hpow, Zsqrtd.im_intCast]
    refine Zsqrtd.ext ?_ ?_ <;> simp [hre, him]
  refine Zsqrtd.ext ?_ ?_
  · rw [re_sum]
    show (∑ i, (f i).a * B ^ (i : ℕ)) = _
    exact Finset.sum_congr rfl fun i _ => (congrArg Zsqrtd.re (hterm i)).symm
  · rw [im_sum]
    show (∑ i, (f i).b * B ^ (i : ℕ)) = _
    exact Finset.sum_congr rfl fun i _ => (congrArg Zsqrtd.im (hterm i)).symm

/-- The set of families whose coordinates are balanced-bounded by the base `B`. -/
def Bounded (n : ℕ) (B : ℤ) : Set (Fin n → PTriple) :=
  {f | ∀ i, 2 * |(f i).a| < B ∧ 2 * |(f i).b| < B}

/-- **The positional aggregate is injective on bounded families.**  In contrast with the
multiplicative aggregate `uprod`, the additive positional aggregate — formed from exactly the
same Gaussian integers — recovers the family together with its labels. -/
theorem gaggr_injOn {n : ℕ} {B : ℤ} (hB : 0 < B) :
    Set.InjOn (gaggr (n := n) B) (Bounded n B) := by
  intro f hf g hg h
  have hre : (∑ i, (f i).a * B ^ (i : ℕ)) = ∑ i, (g i).a * B ^ (i : ℕ) :=
    congrArg Zsqrtd.re h
  have him : (∑ i, (f i).b * B ^ (i : ℕ)) = ∑ i, (g i).b * B ^ (i : ℕ) :=
    congrArg Zsqrtd.im h
  have ha : (fun i => (f i).a) = (fun i => (g i).a) :=
    int_digits_unique hB _ _ (fun i => (hf i).1) (fun i => (hg i).1) hre
  have hb : (fun i => (f i).b) = (fun i => (g i).b) :=
    int_digits_unique hB _ _ (fun i => (hf i).2) (fun i => (hg i).2) him
  funext i
  have ha' : (f i).a = (g i).a := congrFun ha i
  have hb' : (f i).b = (g i).b := congrFun hb i
  exact PTriple.ext ha' hb' (c_eq_of_legs ha' hb')

/-! ## A concrete separation -/

/-- An explicit witness of the dichotomy inside `ℤ[i]`: the two orderings of the family
`{(3,4,5), (5,12,13)}` have the same Brahmagupta product but different positional
aggregates in base `100`. -/
theorem gaggr_separates_swap :
    uprod ![t345, t51213] = uprod ![t51213, t345] ∧
      gaggr 100 ![t345, t51213] ≠ gaggr 100 ![t51213, t345] := by
  constructor
  · rw [uprod_two, uprod_two]
    ext <;> simp [t345, t51213]
  · intro h
    have := congrArg Zsqrtd.re h
    simp [gaggr, Fin.sum_univ_two, t345, t51213] at this


/-- **The balanced bound in `gaggr_injOn` cannot be weakened to `≤`.**  In base `B = 2` the two
families `((1,0,1), (0,0,0))` and `((-1,0,1), (1,0,1))`, whose coordinates satisfy
`2 * |·| ≤ B` but not `2 * |·| < B`, have the same positional aggregate.  So the injectivity
statement sits exactly at the balanced-digit threshold. -/
theorem gaggr_bound_sharp :
    gaggr 2 ![1, zeroT] = gaggr 2 ![rotNegOne, 1] ∧
      (![1, zeroT] : Fin 2 → PTriple) ≠ ![rotNegOne, 1] := by
  constructor
  · refine Zsqrtd.ext ?_ ?_ <;>
      simp [gaggr, Fin.sum_univ_two, rotNegOne]
  · intro h
    have h0 : (1 : PTriple) = rotNegOne := by simpa using congrFun h 0
    have : (1 : ℤ) = -1 := by simpa [rotNegOne] using congrArg PTriple.a h0
    norm_num at this

end Pythagorean