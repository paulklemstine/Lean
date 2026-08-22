/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality IX: the memoryless price is *strictly* subadditive

Ninth instalment of the thread.  Part VII proved that the Shtarkov sum of the
memoryless class is submultiplicative in the block length,
`Cₛ(n₁ + n₂) ≤ Cₛ(n₁) · Cₛ(n₂)`, which is exactly what Fekete's lemma needs.
Part VIII turned the *equality case* of that induction into a checkable
criterion (`shtarkovSum_tiedProdClass_eq_iff`): equality holds iff every pair of
block outcomes admits a **common maximum-likelihood parameter**.

Here that criterion is cashed in.  For an alphabet with at least two letters the
two constant strings `aaa…a` and `bbb…b` have *no* common maximiser — the
maximiser of the first block is the point mass at `a`, that of the second the
point mass at `b`, and a probability vector cannot put mass `1` on two distinct
letters.  Hence the inequality of Part VII is **strict at every split**.

## Central Idea

Combining
* `shtarkovSum_iidClass_eq_card_one` : `Cₛ(1) = #A` (the length-one memoryless
  class is the point-mass class in disguise, sitting at the *upper* rigidity
  endpoint of Part VIII), and
* strictness at every split,

induction gives `Cₛ(n) < (#A)^n` for `n ≥ 2`: universal coding of a memoryless
source is *strictly* cheaper than coding each symbol with its own free
parameter, and the deficit compounds with every block.  This is the qualitative
content behind the `O(log n)` upper bound of Part II — the exponential price
`(#A)^n` of "one parameter per symbol" collapses to a polynomial one because the
blocks are *tied*.

## Main Results

* `deltaSimplex`, `prob_iidClass_const_eq_one`, `maxLik_iidClass_const` — point
  masses saturate the likelihood of a constant string
* `prob_eq_one_iff_coord`, `maxLik_tied_const_le_quarter` — a parameter that
  maximises a constant string must be the point mass, so two constant strings on
  distinct letters leave the tied envelope below `1/4`
* `shtarkovSum_iidClass_eq_card_one` — `Cₛ(1) = #A`
* `shtarkovSum_iidClass_eq_tied` — the length-`n₁+n₂` class *is* the tied
  product of its two blocks (the relabelling of Part VII is an isomorphism)
* `shtarkovSum_iidClass_strict_submultiplicative` — `Cₛ(n₁+n₂) < Cₛ(n₁)·Cₛ(n₂)`
  for `#A ≥ 2` and `n₁, n₂ ≥ 1`
* `iid_price_strictly_subadditive` — the bit form
* `shtarkovSum_iidClass_lt_pow` — `Cₛ(n) < (#A)^n` for `n ≥ 2`

## Application Keywords

universal coding, Shtarkov sum, memoryless sources, strict subadditivity,
Fekete's lemma, method of types
-/

import MachineLearning.UniversalRedundancy.Rigidity

open Finset Real

namespace UniversalRedundancy

variable {A : Type*} [Fintype A] [DecidableEq A] [Nonempty A]

/-! ## Point masses inside the simplex -/

/-- The point mass at `a`, as a member of the memoryless parameter simplex. -/
def deltaSimplex (a : A) : Simplex A :=
  ⟨fun b => if b = a then 1 else 0, fun b => by by_cases h : b = a <;> simp [h], by simp⟩

omit [DecidableEq A] [Nonempty A] in
/-- Every simplex coordinate is at most `1`. -/
lemma simplex_le_one (θ : Simplex A) (a : A) : θ.1 a ≤ 1 := by
  have h := Finset.single_le_sum (f := fun b => θ.1 b)
    (fun b _ => θ.2.1 b) (Finset.mem_univ a)
  rw [θ.2.2] at h
  exact h

omit [Nonempty A] in
/-- Two distinct simplex coordinates sum to at most `1`. -/
lemma simplex_pair_le_one {θ : Simplex A} {a b : A} (hab : a ≠ b) :
    θ.1 a + θ.1 b ≤ 1 := by
  classical
  have h2 : ∑ c ∈ ({a, b} : Finset A), θ.1 c ≤ ∑ c, θ.1 c :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) fun c _ _ => θ.2.1 c
  rw [Finset.sum_pair hab, θ.2.2] at h2
  exact h2

omit [Nonempty A] in
/-- The point mass at `a` gives the constant string `aa…a` likelihood `1`. -/
lemma prob_iidClass_const_eq_one (n : ℕ) (a : A) :
    (iidClass A n).prob (deltaSimplex a) (fun _ => a) = 1 := by
  show ∏ _i : Fin n, (deltaSimplex a).1 a = 1
  simp [deltaSimplex]

/-- Hence the maximum-likelihood envelope of a constant string is `1`. -/
lemma maxLik_iidClass_const (n : ℕ) (a : A) :
    (iidClass A n).maxLik (fun _ => a) = 1 :=
  le_antisymm ((iidClass A n).maxLik_le_one _)
    (by
      have := (iidClass A n).le_maxLik (deltaSimplex a) (fun _ => a)
      rwa [prob_iidClass_const_eq_one n a] at this)

omit [Nonempty A] in
/-- Only the point mass at `a` maximises the likelihood of `aa…a` (`n ≥ 1`):
a maximising parameter must put all its mass on `a`. -/
lemma prob_eq_one_iff_coord (n : ℕ) (hn : 1 ≤ n) (a : A) (θ : Simplex A)
    (h : (iidClass A n).prob θ (fun _ => a) = 1) : θ.1 a = 1 := by
  have hconst : (iidClass A n).prob θ (fun _ => a) = θ.1 a ^ n := by
    show ∏ _i : Fin n, θ.1 a = θ.1 a ^ n
    simp
  rw [hconst] at h
  by_contra hne
  have hlt : θ.1 a < 1 := lt_of_le_of_ne (simplex_le_one θ a) hne
  have := pow_lt_one₀ (θ.2.1 a) hlt (by omega : n ≠ 0)
  linarith

/-! ## The length-one class sits at the upper rigidity endpoint -/

/-- `Cₛ(1) = #A`: with a single symbol the memoryless class is as expensive as
naming the symbol — the maximal price of Part VIII. -/
theorem shtarkovSum_iidClass_eq_card_one :
    (iidClass A 1).shtarkovSum = (Fintype.card A : ℝ) := by
  classical
  have hmax : ∀ x : Fin 1 → A, (iidClass A 1).maxLik x = 1 := by
    intro x
    have hx : x = fun _ => x 0 := by
      funext i
      have : i = 0 := Subsingleton.elim i 0
      rw [this]
    rw [hx]
    exact maxLik_iidClass_const 1 (x 0)
  unfold SourceClass.shtarkovSum
  rw [Finset.sum_congr rfl fun x _ => hmax x]
  simp

/-! ## The block decomposition is an isomorphism -/

/-- The memoryless class of length `n₁ + n₂` and the tied product of its two
blocks have the *same* Shtarkov sum: the relabelling used in Part VII is a
bijection, so no information is lost in either direction. -/
theorem shtarkovSum_iidClass_eq_tied (n₁ n₂ : ℕ) :
    (iidClass A (n₁ + n₂)).shtarkovSum
      = (tiedProdClass (iidClass A n₁) (iidClass A n₂)).shtarkovSum := by
  classical
  set e := (Equiv.arrowCongr finSumFinEquiv.symm (Equiv.refl A)).trans
    (Equiv.sumArrowEquivProdArrow (Fin n₁) (Fin n₂) A) with he
  refine le_antisymm ?_ ?_
  · exact shtarkovSum_le_of_relabel (iidClass A (n₁ + n₂))
      (tiedProdClass (iidClass A n₁) (iidClass A n₂)) e id
      (fun θ x => prob_iidClass_split n₁ n₂ θ x)
  · refine shtarkovSum_le_of_relabel
      (tiedProdClass (iidClass A n₁) (iidClass A n₂)) (iidClass A (n₁ + n₂))
      e.symm id (fun θ y => ?_)
    have := prob_iidClass_split (A := A) n₁ n₂ θ (e.symm y)
    rw [show e (e.symm y) = y from e.apply_symm_apply y] at this
    exact this.symm

/-! ## Strictness -/

/-- **Quantitative failure of a common maximiser.**  For two distinct letters,
no memoryless parameter can give both constant strings `aa…a` and `bb…b` more
than a quarter of the likelihood they achieve separately: the tied envelope at
that pair is at most `1/4`, while the product of the block envelopes is `1`. -/
lemma maxLik_tied_const_le_quarter {n₁ n₂ : ℕ} (hn₁ : 1 ≤ n₁) (hn₂ : 1 ≤ n₂)
    {a b : A} (hab : a ≠ b) :
    (tiedProdClass (iidClass A n₁) (iidClass A n₂)).maxLik
        ((fun _ => a : Fin n₁ → A), (fun _ => b : Fin n₂ → A)) ≤ 1 / 4 := by
  classical
  refine SourceClass.maxLik_le _ fun θ => ?_
  have hprob : (tiedProdClass (iidClass A n₁) (iidClass A n₂)).prob θ
      ((fun _ => a : Fin n₁ → A), (fun _ => b : Fin n₂ → A))
      = θ.1 a ^ n₁ * θ.1 b ^ n₂ := by
    show (∏ _i : Fin n₁, θ.1 a) * ∏ _j : Fin n₂, θ.1 b = θ.1 a ^ n₁ * θ.1 b ^ n₂
    simp
  rw [hprob]
  have ha : θ.1 a ^ n₁ ≤ θ.1 a := by
    calc θ.1 a ^ n₁ ≤ θ.1 a ^ 1 :=
          pow_le_pow_of_le_one (θ.2.1 a) (simplex_le_one θ a) hn₁
      _ = θ.1 a := pow_one _
  have hb : θ.1 b ^ n₂ ≤ θ.1 b := by
    calc θ.1 b ^ n₂ ≤ θ.1 b ^ 1 :=
          pow_le_pow_of_le_one (θ.2.1 b) (simplex_le_one θ b) hn₂
      _ = θ.1 b := pow_one _
  have hsum : θ.1 a + θ.1 b ≤ 1 := simplex_pair_le_one hab
  have hpa : 0 ≤ θ.1 a ^ n₁ := pow_nonneg (θ.2.1 a) _
  have hpb : 0 ≤ θ.1 b ^ n₂ := pow_nonneg (θ.2.1 b) _
  nlinarith [θ.2.1 a, θ.2.1 b, sq_nonneg (θ.1 a - θ.1 b)]

/-- **Strict submultiplicativity of the memoryless price.**  For an alphabet
with at least two letters, splitting a message into two non-empty blocks is
*strictly* cheaper than treating the blocks as independently parametrised:
`Cₛ(n₁+n₂) < Cₛ(n₁) · Cₛ(n₂)`. -/
theorem shtarkovSum_iidClass_strict_submultiplicative (hA : 2 ≤ Fintype.card A)
    {n₁ n₂ : ℕ} (hn₁ : 1 ≤ n₁) (hn₂ : 1 ≤ n₂) :
    (iidClass A (n₁ + n₂)).shtarkovSum
      < (iidClass A n₁).shtarkovSum * (iidClass A n₂).shtarkovSum := by
  classical
  obtain ⟨a, b, hab⟩ := Fintype.exists_pair_of_one_lt_card (α := A) (by omega)
  rw [shtarkovSum_iidClass_eq_tied n₁ n₂]
  refine shtarkovSum_tiedProdClass_lt_of_maxLik_lt (iidClass A n₁) (iidClass A n₂)
    (x₁ := fun _ => a) (x₂ := fun _ => b) ?_
  have hq := maxLik_tied_const_le_quarter (A := A) hn₁ hn₂ hab
  rw [maxLik_iidClass_const n₁ a, maxLik_iidClass_const n₂ b]
  linarith

/-- Bit form: the price of universality of the memoryless class is *strictly*
subadditive in the message length. -/
theorem iid_price_strictly_subadditive (hA : 2 ≤ Fintype.card A)
    {n₁ n₂ : ℕ} (hn₁ : 1 ≤ n₁) (hn₂ : 1 ≤ n₂) :
    logb 2 (iidClass A (n₁ + n₂)).shtarkovSum
      < logb 2 (iidClass A n₁).shtarkovSum + logb 2 (iidClass A n₂).shtarkovSum := by
  rw [← Real.logb_mul (ne_of_gt (iidClass A n₁).shtarkovSum_pos)
    (ne_of_gt (iidClass A n₂).shtarkovSum_pos)]
  refine Real.logb_lt_logb (by norm_num) (iidClass A (n₁ + n₂)).shtarkovSum_pos ?_
  exact shtarkovSum_iidClass_strict_submultiplicative hA hn₁ hn₂

/-- **Compounding gain.**  For `n ≥ 2` the memoryless price is strictly below the
"one free parameter per symbol" price `(#A)^n`: tying the parameter across
symbols always wins, and the gain is genuine at every length. -/
theorem shtarkovSum_iidClass_lt_pow (hA : 2 ≤ Fintype.card A) :
    ∀ n : ℕ, 2 ≤ n → (iidClass A n).shtarkovSum < (Fintype.card A : ℝ) ^ n := by
  intro n hn
  induction n, hn using Nat.le_induction with
  | base =>
      have h := shtarkovSum_iidClass_strict_submultiplicative (A := A) hA
        (n₁ := 1) (n₂ := 1) le_rfl le_rfl
      rw [shtarkovSum_iidClass_eq_card_one] at h
      calc (iidClass A 2).shtarkovSum
          < (Fintype.card A : ℝ) * (Fintype.card A : ℝ) := h
        _ = (Fintype.card A : ℝ) ^ 2 := by ring
  | succ n hn ih =>
      have hstep := shtarkovSum_iidClass_strict_submultiplicative (A := A) hA
        (n₁ := n) (n₂ := 1) (by omega) le_rfl
      rw [shtarkovSum_iidClass_eq_card_one] at hstep
      have hcard : (0 : ℝ) < (Fintype.card A : ℝ) := by
        have : (0 : ℕ) < Fintype.card A := by omega
        exact_mod_cast this
      calc (iidClass A (n + 1)).shtarkovSum
          < (iidClass A n).shtarkovSum * (Fintype.card A : ℝ) := hstep
        _ < (Fintype.card A : ℝ) ^ n * (Fintype.card A : ℝ) := by
            exact mul_lt_mul_of_pos_right ih hcard
        _ = (Fintype.card A : ℝ) ^ (n + 1) := by ring

end UniversalRedundancy

/-! ## Lab notes (exact Bernoulli Shtarkov sums)

`Cₛ(n) = ∑_k C(n,k) (k/n)^k ((n-k)/n)^{n-k}` for the binary memoryless class,
evaluated exactly in `ℚ`:

| `n` | 1 | 2   | 3    | 4      | 5        |
|-----|---|-----|------|--------|----------|
| `Cₛ`| 2 | 5/2 | 26/9 | 103/32 | 2194/625 |

Against `Cₛ(1)^n = 2^n = 2, 4, 8, 16, 32` the deficit is already a factor `1.6`
at `n = 2` and grows to a factor `9.1` at `n = 5`: the strict inequality proved
in `shtarkovSum_iidClass_lt_pow` is far from tight, which is what
Direction 3 of `FUTURE_DIRECTIONS.md` proposes to quantify.
-/