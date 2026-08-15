import Mathlib

/-!
# Collective use of a boundary block: the Chinese-Remainder layer

## Context (NET-31, mechanism axis)

The companion file `BoundaryBlockInternalization.lean` models the boundary block
additively: a threshold compared with the aggregate drive `∑ i, w i`.  That layer
explains the sign-sensitivity marker, but it does not explain *why* a block of
`k` exclusive dimensions can carry an answer at all, nor why the round's rule of
thumb is stated in terms of **exclusive** dimensions.

This file supplies the arithmetic layer.  A boundary block of `k` exclusive
dimensions is modelled by `k` **pairwise coprime moduli** `m i ≥ 2`; the answer
path *resolves* a range `A` when the residues `x mod m i`, `i` ranging over the
surviving dimensions, determine `x` on `[0, A)`.  This is the Chinese Remainder
Theorem read as a statement about ablations:

* `BoundaryBlockCRT.resolves_of_le_prod` — the block resolves everything below
  its **capacity** `∏ i ∈ S, m i` (CRT).
* `BoundaryBlockCRT.two_pow_card_le_prod` — `k` exclusive dimensions have
  capacity at least `2 ^ k`; dropping one leaves at least `2 ^ (k-1)`
  (`two_pow_card_sub_one_le_prod_erase`).
* `BoundaryBlockCRT.single_drop_resolves` — hence **`zero1` is a no-op**: with
  `A ≤ 2 ^ (k-1)` every single-dimension ablation still resolves.
* `BoundaryBlockCRT.resolves_empty_iff` — but **`zeroN` is fatal**: with no
  dimensions left the block resolves only ranges with at most one element.
* `BoundaryBlockCRT.collective_use` — the two facts together are precisely the
  round's mechanism claim: *the block is used collectively*.
* `BoundaryBlockCRT.exists_collective_block` — the configuration is realised at
  every width `k ≥ 2` by the Fermat numbers `2 ^ 2 ^ i + 1`, which are pairwise
  coprime, so the mechanism is not an artefact of a lucky modulus choice.
* `BoundaryBlockCRT.single_drop_can_break_without_margin` — an honest boundary:
  the `zero1` no-op needs the capacity margin.  With `(2, 3, 5)` and `A = 30` the
  block resolves, yet dropping the modulus `5` destroys resolution.  So "≥ 3
  exclusive dims" buys redundancy only up to the margin `2 ^ (k-1)`.
* `BoundaryBlockCRT.resolves_neg` — sign flips of a modulus are *always* free at
  this layer.  Sign sensitivity, observed only at `k = 2`, therefore cannot be a
  capacity phenomenon: it belongs to the additive gate layer.
-/

namespace BoundaryBlockCRT

open Finset

variable {ι : Type*} [DecidableEq ι]

/-- The surviving dimensions `S` of a boundary block with moduli `m` **resolve**
the answer range `A` when residues mod the surviving moduli separate every two
answers in `[0, A)`. -/
def Resolves (S : Finset ι) (m : ι → ℤ) (A : ℤ) : Prop :=
  ∀ x y : ℤ, 0 ≤ x → x < A → 0 ≤ y → y < A → (∀ i ∈ S, m i ∣ x - y) → x = y

/-- Pairwise coprimality of the surviving moduli. -/
def PairwiseCoprime (S : Finset ι) (m : ι → ℤ) : Prop :=
  (S : Set ι).Pairwise (Function.onFun IsCoprime m)

/-! ## 1.  Capacity: the Chinese Remainder Theorem as an ablation statement -/

omit [DecidableEq ι] in
/-- **CRT.**  A pairwise coprime block resolves every range below its capacity
`∏ i ∈ S, m i`. -/
theorem resolves_of_le_prod {S : Finset ι} {m : ι → ℤ} {A : ℤ}
    (hcop : PairwiseCoprime S m) (hA : A ≤ ∏ i ∈ S, m i) : Resolves S m A := by
  intro x y hx hxA hy hyA hdvd
  have hdvd' : (∏ i ∈ S, m i) ∣ x - y := Finset.prod_dvd_of_coprime hcop hdvd
  have habs : |x - y| < ∏ i ∈ S, m i := by
    rcases abs_cases (x - y) with ⟨h, _⟩ | ⟨h, _⟩ <;> rw [h] <;> linarith
  have := Int.eq_zero_of_abs_lt_dvd hdvd' habs
  linarith

omit [DecidableEq ι] in
/-- `k` exclusive dimensions, each of modulus at least `2`, have capacity at
least `2 ^ k`. -/
theorem two_pow_card_le_prod {S : Finset ι} {m : ι → ℤ} (hm : ∀ i ∈ S, 2 ≤ m i) :
    (2 : ℤ) ^ S.card ≤ ∏ i ∈ S, m i := by
  calc (2 : ℤ) ^ S.card = ∏ _i ∈ S, (2 : ℤ) := by rw [Finset.prod_const]
  _ ≤ ∏ i ∈ S, m i := Finset.prod_le_prod (fun i _ => by norm_num) hm

/-- Dropping one dimension leaves capacity at least `2 ^ (k-1)`. -/
theorem two_pow_card_sub_one_le_prod_erase {S : Finset ι} {m : ι → ℤ} {j : ι}
    (hj : j ∈ S) (hm : ∀ i ∈ S, 2 ≤ m i) :
    (2 : ℤ) ^ (S.card - 1) ≤ ∏ i ∈ S.erase j, m i := by
  have hcard : (S.erase j).card = S.card - 1 := Finset.card_erase_of_mem hj
  have := two_pow_card_le_prod (S := S.erase j) (m := m)
    (fun i hi => hm i (Finset.mem_of_mem_erase hi))
  rwa [hcard] at this

/-! ## 2.  `zero1` is a no-op, `zeroN` is fatal -/

/-- **`zero1` is a no-op.**  With `k` pairwise coprime exclusive dimensions of
modulus `≥ 2` and an answer range within the single-drop margin `2 ^ (k-1)`, the
block still resolves after any one dimension is ablated. -/
theorem single_drop_resolves {S : Finset ι} {m : ι → ℤ} {A : ℤ} {j : ι}
    (hj : j ∈ S) (hm : ∀ i ∈ S, 2 ≤ m i) (hcop : PairwiseCoprime S m)
    (hA : A ≤ (2 : ℤ) ^ (S.card - 1)) : Resolves (S.erase j) m A := by
  refine resolves_of_le_prod ?_ (le_trans hA (two_pow_card_sub_one_le_prod_erase hj hm))
  exact hcop.mono (by
    intro i hi
    exact Finset.mem_of_mem_erase hi)

omit [DecidableEq ι] in
/-- **`zeroN` is fatal.**  With every dimension ablated the block resolves only
degenerate ranges. -/
theorem resolves_empty_iff {m : ι → ℤ} {A : ℤ} :
    Resolves (∅ : Finset ι) m A ↔ A ≤ 1 := by
  constructor
  · intro h
    by_contra hA
    push_neg at hA
    have := h 0 1 le_rfl (by linarith) zero_le_one hA (by simp)
    exact absurd this (by norm_num)
  · intro hA x y hx hxA _ _ _
    omega

/-- **Collective use.**  For a block of `k ≥ 2` pairwise coprime exclusive
dimensions and a non-degenerate answer range inside the single-drop margin: the
intact block resolves, *every* single-dimension ablation is a no-op, and the
whole-block ablation is fatal.  This is the round's mechanism statement. -/
theorem collective_use {S : Finset ι} {m : ι → ℤ} {A : ℤ}
    (hm : ∀ i ∈ S, 2 ≤ m i) (hcop : PairwiseCoprime S m)
    (h2 : 2 ≤ A) (hA : A ≤ (2 : ℤ) ^ (S.card - 1)) :
    Resolves S m A ∧ (∀ j ∈ S, Resolves (S.erase j) m A) ∧ ¬ Resolves (∅ : Finset ι) m A := by
  refine ⟨?_, fun j hj => single_drop_resolves hj hm hcop hA, ?_⟩
  · refine resolves_of_le_prod hcop (le_trans hA ?_)
    refine le_trans (pow_le_pow_right₀ (by norm_num) (Nat.sub_le _ 1)) ?_
    exact two_pow_card_le_prod hm
  · rw [resolves_empty_iff]
    omega

/-! ## 3.  The configuration is realised at every width: Fermat blocks

The Fermat numbers `F i = 2 ^ 2 ^ i + 1` are pairwise coprime and exceed `2`, so
`{F 0, …, F (k-1)}` is a legitimate `k`-dimensional exclusive boundary block for
every `k`.  Nothing about the mechanism depends on a lucky choice of moduli. -/

/-- The Fermat block: `k` pairwise coprime exclusive dimensions. -/
def fermatBlock : ℕ → ℤ := fun i => (Nat.fermatNumber i : ℤ)

theorem two_le_fermatBlock (i : ℕ) : 2 ≤ fermatBlock i := by
  have h : 2 ≤ Nat.fermatNumber i := by
    have : 1 ≤ 2 ^ 2 ^ i := Nat.one_le_two_pow
    simp only [Nat.fermatNumber]
    omega
  unfold fermatBlock
  exact_mod_cast h

theorem pairwiseCoprime_fermatBlock (S : Finset ℕ) : PairwiseCoprime S fermatBlock := by
  intro i _ j _ hij
  have h : Nat.Coprime (Nat.fermatNumber i) (Nat.fermatNumber j) :=
    Nat.coprime_fermatNumber_fermatNumber hij
  exact (Nat.isCoprime_iff_coprime).2 h

/-- **Realisation at every width `k ≥ 2`.**  A genuine `k`-dimensional block,
collectively used: intact resolution, single-drop no-op, whole-block failure. -/
theorem exists_collective_block (k : ℕ) (hk : 2 ≤ k) :
    ∃ (S : Finset ℕ) (m : ℕ → ℤ) (A : ℤ),
      S.card = k ∧ 2 ≤ A ∧
      Resolves S m A ∧ (∀ j ∈ S, Resolves (S.erase j) m A) ∧
      ¬ Resolves (∅ : Finset ℕ) m A := by
  refine ⟨Finset.range k, fermatBlock, (2 : ℤ) ^ (k - 1), Finset.card_range k, ?_, ?_⟩
  · have h1 : 1 ≤ k - 1 := by omega
    calc (2 : ℤ) = 2 ^ 1 := by norm_num
    _ ≤ 2 ^ (k - 1) := pow_le_pow_right₀ (by norm_num) h1
  · have hcard : (Finset.range k).card = k := Finset.card_range k
    have h2 : (2 : ℤ) ≤ (2 : ℤ) ^ (k - 1) := by
      have h1 : 1 ≤ k - 1 := by omega
      calc (2 : ℤ) = 2 ^ 1 := by norm_num
      _ ≤ 2 ^ (k - 1) := pow_le_pow_right₀ (by norm_num) h1
    have := collective_use (S := Finset.range k) (m := fermatBlock) (A := (2 : ℤ) ^ (k - 1))
      (fun i _ => two_le_fermatBlock i) (pairwiseCoprime_fermatBlock _) h2
      (by rw [hcard])
    exact this

/-! ## 4.  Honest boundaries -/

/-- **The `zero1` no-op needs the margin.**  The block `(2, 3, 5)` resolves the
range `30`, but ablating the dimension `5` destroys resolution (`0` and `6` become
indistinguishable).  Redundancy of `k ≥ 3` exclusive dimensions is therefore a
statement *relative to the answer range*, exactly as the design rule's
per-instance verification caveat demands. -/
theorem single_drop_can_break_without_margin :
    ∃ (S : Finset ℕ) (m : ℕ → ℤ) (A : ℤ) (j : ℕ),
      PairwiseCoprime S m ∧ j ∈ S ∧ Resolves S m A ∧ ¬ Resolves (S.erase j) m A := by
  classical
  refine ⟨{0, 1, 2}, fun i => if i = 0 then 2 else if i = 1 then 3 else 5, 30, 2, ?_, ?_, ?_, ?_⟩
  · intro i hi j hj hij
    simp only [Finset.coe_insert, Set.mem_insert_iff, Finset.coe_singleton,
      Set.mem_singleton_iff] at hi hj
    rcases hi with rfl | rfl | rfl <;> rcases hj with rfl | rfl | rfl <;>
      simp_all [Function.onFun, Int.isCoprime_iff_gcd_eq_one] <;> decide
  · decide
  · refine resolves_of_le_prod ?_ ?_
    · intro i hi j hj hij
      simp only [Finset.coe_insert, Set.mem_insert_iff, Finset.coe_singleton,
        Set.mem_singleton_iff] at hi hj
      rcases hi with rfl | rfl | rfl <;> rcases hj with rfl | rfl | rfl <;>
        simp_all [Function.onFun, Int.isCoprime_iff_gcd_eq_one] <;> decide
    · decide
  · intro h
    have h6 : (0 : ℤ) = 6 := by
      refine h 0 6 le_rfl (by norm_num) (by norm_num) (by norm_num) ?_
      intro i hi
      fin_cases hi <;> norm_num
    norm_num at h6

/-- **Sign flips are free at the capacity layer.**  Negating any subset of the
moduli changes nothing, because divisibility is sign-blind.  The `k = 2` sign
sensitivity found in the round is therefore *not* a capacity effect: it lives in
the additive gate (`BoundaryBlockInternalization.flip1_breaks_of_width_two`). -/
theorem resolves_neg {S : Finset ι} {m : ι → ℤ} {A : ℤ} (T : Finset ι) :
    Resolves S (fun i => if i ∈ T then -(m i) else m i) A ↔ Resolves S m A := by
  constructor <;> intro h x y hx hxA hy hyA hdvd <;>
    refine h x y hx hxA hy hyA (fun i hi => ?_)
  · by_cases hiT : i ∈ T <;> simp [hiT, (neg_dvd).2 (hdvd i hi), hdvd i hi]
  · have := hdvd i hi
    by_cases hiT : i ∈ T
    · simpa [hiT, neg_dvd] using this
    · simpa [hiT] using this

end BoundaryBlockCRT