/-
# The dihedral group `D₆` as the Galois group of `x⁶ - 2`

Group-theoretic core of the *DEGREE-6-NONABELIAN* experiment (paper 122).

The splitting field of `x⁶ - 2` over `ℚ` is `ℚ(2^{1/6}, ζ₆) = ℚ(2^{1/6}, √-3)`, of
degree `12`, and its Galois group acts on the six roots `ζ₆^j 2^{1/6}` exactly as
the dihedral group `D₆` (order `12`) acts on the vertices `ZMod 6` of a hexagon:

* the rotation `r i` (`2^{1/6} ↦ ζ₆^i 2^{1/6}`, fixing `√-3`) acts by `j ↦ i + j`;
* the reflection `sr i` (the composite with complex conjugation, moving `√-3`)
  acts by `j ↦ -i - j`.

The *splitting type* of an unramified prime `p` is the number of roots of `x⁶ - 2`
in `𝔽_p`, which by Chebotarev is distributed as the number of fixed vertices of a
uniformly random element of `D₆`.  This file proves:

* `vertexAct` really is an action of `D_n` on `ZMod n` (`vertexAct_one`,
  `vertexAct_mul`);
* the exact fixed-point law of `D_n` for **every even `n`**
  (`fixCount_r`, `fixCount_sr_of_even`): rotations fix `n` or `0` vertices,
  reflections fix `2` or `0` vertices according to the parity of the axis;
* the resulting `D₆` type distribution `{0 : 8, 2 : 3, 6 : 1}` out of `12`, i.e.
  `{0 : 2/3, 2 : 1/4, 6 : 1/12}` (`typeCounts_D6`);
* the two characters that the conductor dials see: the rotation character
  `rotSign` (the quadratic character of `ℚ(√-3)`, i.e. `p mod 3`) and the full
  abelianisation map `abMap : D_n → ZMod 2 × ZMod 2` for even `n` (the biquadratic
  field `ℚ(√-3, √2)`, i.e. `p mod 24`), both homomorphisms;
* the commutator `⁅r 1, sr 0⁆ = r 2`, so the kernel `{r 0, r 2, r 4}` of `abMap`
  in `D₆` lies in the commutator subgroup (`abMap_eq_iff_of_eq`).
-/
import Mathlib

namespace D6TypeChannel

open DihedralGroup Finset

/-! ## 1. The vertex action -/

/-- The action of `D_n` on the vertices `ZMod n` of the regular `n`-gon
(equivalently, on the roots `ζ_n^j α` of `x^n - a`). -/
def vertexAct {n : ℕ} : DihedralGroup n → ZMod n → ZMod n
  | r i, x => i + x
  | sr i, x => -i - x

@[simp] lemma vertexAct_r {n : ℕ} (i x : ZMod n) : vertexAct (r i) x = i + x := rfl

@[simp] lemma vertexAct_sr {n : ℕ} (i x : ZMod n) : vertexAct (sr i) x = -i - x := rfl

theorem vertexAct_one {n : ℕ} (x : ZMod n) : vertexAct (1 : DihedralGroup n) x = x := by
  change (0 : ZMod n) + x = x
  exact zero_add x

theorem vertexAct_mul {n : ℕ} (g h : DihedralGroup n) (x : ZMod n) :
    vertexAct (g * h) x = vertexAct g (vertexAct h x) := by
  cases g <;> cases h <;> simp [r_mul_r, r_mul_sr, sr_mul_r, sr_mul_sr] <;> ring

/-- The vertex action packaged as a `MulAction`. -/
def vertexMulAction (n : ℕ) : MulAction (DihedralGroup n) (ZMod n) where
  smul := vertexAct
  one_smul := vertexAct_one
  mul_smul := vertexAct_mul

/-! ## 2. The fixed-point (splitting-type) statistic -/

/-- Number of vertices fixed by `g`; for `g = Frob_p` in `Gal(x⁶-2)` this is the
number of roots of `x⁶ - 2` in `𝔽_p`. -/
def fixCount {n : ℕ} [NeZero n] (g : DihedralGroup n) : ℕ := #{x : ZMod n | vertexAct g x = x}

/-- Rotations: the identity fixes everything, every non-trivial rotation is
fixed-point free. -/
theorem fixCount_r {n : ℕ} [NeZero n] (i : ZMod n) :
    fixCount (r i) = if i = 0 then n else 0 := by
  unfold fixCount
  split_ifs with hi
  · subst hi
    have h0 : ∀ x : ZMod n, vertexAct (r 0) x = x := fun x => zero_add x
    simp only [h0, filter_true, card_univ, ZMod.card]
  · rw [card_eq_zero, filter_eq_empty_iff]
    intro x _ hx
    apply hi
    simpa using hx

/-- The fixed points of the reflection `sr i` are the halves of `-i`. -/
lemma fixCount_sr_eq {n : ℕ} [NeZero n] (i : ZMod n) :
    fixCount (sr i) = #{x : ZMod n | 2 * x = -i} := by
  unfold fixCount
  congr 1
  ext x
  simp only [mem_filter, mem_univ, true_and, vertexAct_sr]
  constructor <;> intro h <;> linear_combination -h

/-- The doubling map of `ZMod n` as an additive homomorphism. -/
def dbl (n : ℕ) : ZMod n →+ ZMod n := nsmulAddMonoidHom 2

lemma dbl_apply {n : ℕ} (x : ZMod n) : dbl n x = 2 * x := by
  simp [dbl, two_mul]

/-- For even `n` the doubling map of `ZMod n` has exactly two elements in its kernel. -/
lemma card_dbl_ker {n : ℕ} [NeZero n] (hn : 2 ∣ n) : #{x : ZMod n | 2 * x = 0} = 2 := by
  have h := IsAddCyclic.card_nsmulAddMonoidHom_ker (ZMod n) 2
  rw [Nat.card_zmod, Nat.gcd_eq_right hn] at h
  rw [← h, Nat.card_eq_fintype_card, ← Fintype.card_coe]
  refine Fintype.card_congr (Equiv.subtypeEquivRight ?_)
  intro x
  simp [AddMonoidHom.mem_ker, two_mul]

/-- For even `n`, `-i` is a double iff `i` has even representative. -/
lemma exists_half_iff {n : ℕ} [NeZero n] (hn : 2 ∣ n) (i : ZMod n) :
    (∃ x : ZMod n, 2 * x = -i) ↔ Even i.val := by
  constructor
  · rintro ⟨x, hx⟩
    have hc := congrArg (ZMod.castHom hn (ZMod 2)) hx
    simp only [map_mul, map_neg, map_ofNat] at hc
    have h2 : (2 : ZMod 2) = 0 := rfl
    rw [h2, zero_mul, zero_eq_neg] at hc
    rw [ZMod.castHom_apply, ZMod.cast_eq_val, ZMod.natCast_eq_zero_iff_even] at hc
    exact hc
  · rintro ⟨t, ht⟩
    refine ⟨-(t : ZMod n), ?_⟩
    have : i = ((i.val : ℕ) : ZMod n) := (ZMod.natCast_zmod_val i).symm
    rw [this, ht]; push_cast; ring

/-- **The reflection law for even `n`**: a reflection of the `n`-gon fixes exactly
two vertices if its axis passes through vertices (`i` even) and none otherwise. -/
theorem fixCount_sr_of_even {n : ℕ} [NeZero n] (hn : 2 ∣ n) (i : ZMod n) :
    fixCount (sr i) = if Even i.val then 2 else 0 := by
  rw [fixCount_sr_eq]
  split_ifs with he
  · obtain ⟨y, hy⟩ := (exists_half_iff hn i).2 he
    have hfib := AddMonoidHom.card_fiber_eq_of_mem_range (dbl n)
      (x := -i) (y := 0) ⟨y, by rw [dbl_apply, hy]⟩ ⟨0, by simp⟩
    simp only [dbl_apply] at hfib
    rw [hfib, card_dbl_ker hn]
  · rw [card_eq_zero, filter_eq_empty_iff]
    intro x _ hx
    exact he ((exists_half_iff hn i).1 ⟨x, hx⟩)

/-- The splitting types occurring in `D_n` (`n` even, `n ≥ 4`) are exactly
`{0, 2, n}`. -/
theorem fixCount_mem {n : ℕ} [NeZero n] (hn : 2 ∣ n) (g : DihedralGroup n) :
    fixCount g = 0 ∨ fixCount g = 2 ∨ fixCount g = n := by
  cases g with
  | r i => rw [fixCount_r]; split_ifs <;> simp
  | sr i => rw [fixCount_sr_of_even hn]; split_ifs <;> simp

/-! ## 3. The `D₆` type distribution -/

set_option maxRecDepth 100000 in
/-- **The `D₆` type distribution**: out of the `12` elements of `D₆`, eight fix no
root, three fix two roots, one fixes all six: `{0 : 2/3, 2 : 1/4, 6 : 1/12}`. -/
theorem typeCounts_D6 :
    #{g : DihedralGroup 6 | fixCount g = 0} = 8 ∧
    #{g : DihedralGroup 6 | fixCount g = 2} = 3 ∧
    #{g : DihedralGroup 6 | fixCount g = 6} = 1 := by
  refine ⟨?_, ?_, ?_⟩ <;> decide

/-- Burnside / orbit-counting consistency: the average number of fixed roots is
`1`, because `D₆` acts transitively on the six roots (`8·0 + 3·2 + 1·6 = 12`). -/
theorem sum_fixCount_D6 : ∑ g : DihedralGroup 6, fixCount g = 12 := by
  decide

/-! ## 4. The characters seen by conductor dials -/

/-- The **rotation character** `D_n → ZMod 2` (`0` on rotations, `1` on reflections).
For `Gal(x⁶-2)` it is the action on `√-3`, i.e. the Frobenius read-out of `p mod 3`. -/
def rotSign {n : ℕ} : DihedralGroup n → ZMod 2
  | r _ => 0
  | sr _ => 1

theorem rotSign_mul {n : ℕ} (g h : DihedralGroup n) :
    rotSign (g * h) = rotSign g + rotSign h := by
  cases g <;> cases h <;> rfl

/-- The **abelianisation map** of `D_n` for even `n`:
`r i ↦ (0, i mod 2)`, `sr i ↦ (1, i mod 2)`.  For `x⁶ - 2` its two coordinates are
the characters of `ℚ(√-3)` and `ℚ(√2)` (together: `p mod 24`). -/
def abMap {n : ℕ} (hn : 2 ∣ n) : DihedralGroup n → ZMod 2 × ZMod 2
  | r i => (0, ZMod.castHom hn (ZMod 2) i)
  | sr i => (1, ZMod.castHom hn (ZMod 2) i)

theorem abMap_mul {n : ℕ} (hn : 2 ∣ n) (g h : DihedralGroup n) :
    abMap hn (g * h) = abMap hn g + abMap hn h := by
  cases g <;> cases h <;>
    simp only [abMap, r_mul_r, r_mul_sr, sr_mul_r, sr_mul_sr, map_add,
      sub_eq_add_neg, map_neg, ZMod.neg_eq_self_mod_two, Prod.mk_add_mk, Prod.ext_iff] <;>
    constructor <;> first | decide | ring

/-- The first coordinate of `abMap` is the rotation character. -/
theorem abMap_fst {n : ℕ} (hn : 2 ∣ n) (g : DihedralGroup n) : (abMap hn g).1 = rotSign g := by
  cases g <;> rfl

/-- `r 2` is a commutator in `D_n`: `⁅r 1, sr 0⁆ = r 2`. -/
theorem commutator_r_one_sr_zero {n : ℕ} :
    ⁅(r 1 : DihedralGroup n), (sr 0 : DihedralGroup n)⁆ = r 2 := by
  simp only [commutatorElement_def, inv_r, inv_sr, r_mul_sr, sr_mul_r, sr_mul_sr]
  congr 1; ring

/-- `abMap` detects exactly the abelianisation of `D₆`: two elements with the
same `abMap`-value have the same image in `Abelianization (D₆)`. -/
theorem abMap_eq_iff_of_eq (g h : DihedralGroup 6) :
    abMap (by norm_num : 2 ∣ 6) g = abMap (by norm_num : 2 ∣ 6) h ↔
      Abelianization.of g = Abelianization.of h := by
  constructor
  · intro hgh
    have hr2 : Abelianization.of (r 2 : DihedralGroup 6) = 1 := by
      rw [← commutator_r_one_sr_zero, map_commutatorElement]
      simp [commutatorElement_def, mul_comm]
    have hr4 : Abelianization.of (r 4 : DihedralGroup 6) = 1 := by
      rw [show (r 4 : DihedralGroup 6) = r 2 * r 2 from by rw [r_mul_r]; rfl, map_mul, hr2,
        one_mul]
    -- `g = k * h` with `k ∈ {r 0, r 2, r 4}`
    have key : ∃ k : ZMod 6, (k = 0 ∨ k = 2 ∨ k = 4) ∧ g = r k * h := by
      revert g h hgh; decide
    obtain ⟨k, hk, rfl⟩ := key
    rw [map_mul]
    rcases hk with rfl | rfl | rfl
    · simp
    · rw [hr2, one_mul]
    · rw [hr4, one_mul]
  · intro hgh
    let φ : Multiplicative (ZMod 2 × ZMod 2) →* Multiplicative (ZMod 2 × ZMod 2) :=
      MonoidHom.id _
    let ψ : DihedralGroup 6 →* Multiplicative (ZMod 2 × ZMod 2) :=
      { toFun := fun g => Multiplicative.ofAdd (abMap (by norm_num : 2 ∣ 6) g)
        map_one' := by rfl
        map_mul' := fun a b => by rw [abMap_mul]; rfl }
    have := congrArg (Abelianization.lift ψ) hgh
    simp only [Abelianization.lift_apply_of] at this
    exact Multiplicative.ofAdd.injective this

end D6TypeChannel