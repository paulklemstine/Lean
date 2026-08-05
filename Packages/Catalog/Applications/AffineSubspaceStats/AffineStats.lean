/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Affine subspace statistics in `𝔽₂ⁿ` : parity bounds

Motivated by the *affine subspace statistics problem* (the maximum, over `A ⊆ 𝔽₂ⁿ`, of
`P[|F ∩ A| = s]` for a uniformly random `d`-flat `F`), this file develops a fully finite,
self-contained model of the problem and proves sharp bounds for the *parity* statistic.

## The model

Instead of sampling a `d`-flat directly we sample an affine map `𝔽₂^d → 𝔽₂ⁿ`: a base point
`c` and direction vectors `v₀, …, v_{d-1}`, all uniform and independent. The associated
"affine `d`-cube" is the multiset `{c + ∑ yᵢ vᵢ : y ∈ 𝔽₂^d}` and
`cnt A c v = #{y : c + ∑ yᵢ vᵢ ∈ A}` is the number of its points (with multiplicity) in `A`.
When `v₀, …, v_{d-1}` are linearly independent — which happens with probability
`1 - O(2^{d-n})` — the cube is exactly a `d`-flat and `cnt A c v = |F ∩ A|`. Hence all
`n → ∞` limits of the two models agree, and this model is the convenient one for finite
combinatorial arguments.

## Main results

* `AffineStats.sum_cnt` : the first moment, `E[cnt] = 2^d · |A| / 2ⁿ`.
* `AffineStats.flatProb_compl` : the duality `λ(d, s) = λ(d, 2^d - s)` obtained by
  complementing `A`.
* `AffineStats.oddProb_le_half` : **the parity bound.** For every `n`, every `d ≥ 1` and
  every `A ⊆ 𝔽₂ⁿ`, the probability that a random affine `d`-cube meets `A` in an odd
  number of points is at most `1/2`.
* `AffineStats.flatProb_le_half_of_odd` : consequently `λ(d, s) ≤ 1/2` for every *odd* `s`.
* `AffineStats.exists_oddProb_ge` : the bound `1/2` is asymptotically attained; averaging
  over all `A` produces a set with odd-intersection probability `≥ 1/2 - (2^d-1)/2^{n+1}`.
* `AffineStats.tendsto_maxOddProb` : hence `maxₐ P[|F ∩ A| odd] → 1/2` as `n → ∞`.
* `AffineStats.hyperplane_flatProb` : for the hyperplane `A = {x : x₀ = 0}` one has
  `P[|F ∩ A| = 2^{d-1}] = 1 - 2^{-d}` *exactly*; this is the `k = d-1` case of the
  standard lower-bound construction `λ*(d, j·2^k) ≥ 1 - 2^{-k}`.
* `AffineStats.exists_flatProb_gt_half` : the parity bound does **not** extend to even `s`.
* `AffineStats.tendsto_maxFlatProb_one` : `λ*(1, 1) = 1/2`, the `d = 1` instance of the
  exact determination of `λ*(d, 1)`.
* `AffineStats.flatProb_univ` : at `s = 2^d` the value is `1`, so the regime `s < 2^d` is
  essential in the formula `λ*(d, j·2^k) = 1 - 2^{-k}`.
* `AffineStats.maxOddProb_dim2_lt_half` : at `n = d = 2` the bound `1/2` is not attained,
  so `1/2` is a genuine limit rather than a finite-`n` maximum.
-/

namespace AffineStats

open Finset

/-- The ambient space `𝔽₂ⁿ`. -/
abbrev Vec (n : ℕ) : Type := Fin n → ZMod 2

/-- The parameter space of affine `d`-cubes: a base point together with `d` directions. -/
abbrev Param (n d : ℕ) : Type := Vec n × (Fin d → Vec n)

/-- The point of the affine cube with base point `c` and directions `v` indexed by
`y ∈ 𝔽₂^d`. -/
def pt {n d : ℕ} (c : Vec n) (v : Fin d → Vec n) (y : Fin d → ZMod 2) : Vec n :=
  c + ∑ i, y i • v i

/-- The number of points of the affine cube `(c, v)` lying in `A`. -/
def cnt {n d : ℕ} (A : Finset (Vec n)) (c : Vec n) (v : Fin d → Vec n) : ℕ :=
  (univ.filter fun y : Fin d → ZMod 2 => pt c v y ∈ A).card

/-- The set of parameters whose cube meets `A` in exactly `s` points. -/
def hitSet (n d : ℕ) (A : Finset (Vec n)) (s : ℕ) : Finset (Param n d) :=
  univ.filter fun p => cnt A p.1 p.2 = s

/-- The set of parameters whose cube meets `A` in an odd number of points. -/
def oddSet (n d : ℕ) (A : Finset (Vec n)) : Finset (Param n d) :=
  univ.filter fun p => ¬ (2 ∣ cnt A p.1 p.2)

/-- `P[|F ∩ A| = s]` for a uniformly random affine `d`-cube `F` in `𝔽₂ⁿ`. -/
def flatProb (n d : ℕ) (A : Finset (Vec n)) (s : ℕ) : ℚ :=
  ((hitSet n d A s).card : ℚ) / 2 ^ (n * (d + 1))

/-- `P[|F ∩ A| is odd]` for a uniformly random affine `d`-cube `F` in `𝔽₂ⁿ`. -/
def oddProb (n d : ℕ) (A : Finset (Vec n)) : ℚ :=
  ((oddSet n d A).card : ℚ) / 2 ^ (n * (d + 1))

section Basic

variable {n d : ℕ}

lemma card_Vec (n : ℕ) : Fintype.card (Vec n) = 2 ^ n := by
  simp [Vec, ZMod.card]

lemma card_Param (n d : ℕ) : Fintype.card (Param n d) = 2 ^ (n * (d + 1)) := by
  simp [Param, ← pow_mul, ← pow_add, Nat.mul_succ, Nat.add_comm]

lemma cnt_le (A : Finset (Vec n)) (c : Vec n) (v : Fin d → Vec n) : cnt A c v ≤ 2 ^ d := by
  refine le_trans (card_filter_le _ _) ?_
  simp

lemma flatProb_nonneg (A : Finset (Vec n)) (s : ℕ) : 0 ≤ flatProb n d A s := by
  unfold flatProb; positivity

/-- Every vector of `𝔽₂ⁿ` has order dividing `2`. -/
lemma vadd_self (w : Vec n) : w + w = 0 := by
  funext i; exact CharTwo.add_self_eq_zero _

lemma cnt_eq_sum (A : Finset (Vec n)) (c : Vec n) (v : Fin d → Vec n) :
    cnt A c v = ∑ y : Fin d → ZMod 2, if pt c v y ∈ A then 1 else 0 := by
  rw [cnt, Finset.card_filter]

/-- Translation is a bijection of `𝔽₂ⁿ`. -/
lemma card_translate (c : Vec n) (T : Finset (Vec n)) :
    (univ.filter fun u : Vec n => c + u ∈ T).card = T.card := by
  refine Finset.card_nbij' (fun u => c + u) (fun a => c + a) ?_ ?_ ?_ ?_ <;>
    intro a ha <;> simp_all [← add_assoc, vadd_self]

lemma oddProb_nonneg (A : Finset (Vec n)) : 0 ≤ oddProb n d A := by
  unfold oddProb; positivity

lemma pt_apply (c : Vec n) (v : Fin d → Vec n) (y : Fin d → ZMod 2) (j : Fin n) :
    pt c v y j = c j + ∑ i, y i * v i j := by
  simp [pt, Finset.sum_apply]

/-- If an involution swaps a predicate with its negation, the predicate holds on exactly
half of the (finite) type. -/
lemma card_filter_involutive {α : Type*} [Fintype α] [DecidableEq α] (P : α → Prop)
    [DecidablePred P] (g : α → α) (hg : Function.Involutive g) (h : ∀ x, P (g x) ↔ ¬ P x) :
    2 * (univ.filter P).card = Fintype.card α := by
  have hcompl : (univ.filter P).card = (univ.filter (fun x => ¬ P x)).card := by
    refine Finset.card_nbij' g g ?_ ?_ ?_ ?_ <;> intro a ha <;> simp_all [hg a]
  have h2 := Finset.card_filter_add_card_filter_not (s := (univ : Finset α)) (p := P)
  rw [Finset.card_univ] at h2
  omega

/-- Flipping one coordinate of a vector of `𝔽₂^d` is an involution. -/
lemma flip_involutive (i₀ : Fin d) :
    Function.Involutive (fun y : Fin d → ZMod 2 => Function.update y i₀ (y i₀ + 1)) := by
  intro y
  funext i
  by_cases hii : i = i₀ <;>
    simp [hii, Function.update_apply, add_assoc, show (1 + 1 : ZMod 2) = 0 from rfl]

/-- Flipping the `i₀`-th coordinate changes a linear form by its `i₀`-th coefficient. -/
lemma sum_update_flip (y : Fin d → ZMod 2) (i₀ : Fin d) (f : Fin d → ZMod 2) :
    ∑ i, (Function.update y i₀ (y i₀ + 1)) i * f i = (∑ i, y i * f i) + f i₀ := by
  have hfun : (fun i => (Function.update y i₀ (y i₀ + 1)) i * f i)
      = Function.update (fun i => y i * f i) i₀ ((y i₀ + 1) * f i₀) := by
    funext i
    by_cases h : i = i₀ <;> simp [h, Function.update_apply]
  rw [show (∑ i, (Function.update y i₀ (y i₀ + 1)) i * f i)
      = ∑ i, Function.update (fun i => y i * f i) i₀ ((y i₀ + 1) * f i₀) i from by rw [hfun]]
  rw [Finset.sum_update_of_mem (mem_univ i₀)]
  rw [← Finset.sum_erase_add univ (fun i => y i * f i) (mem_univ i₀)]
  have h3 : (univ : Finset (Fin d)) \ {i₀} = univ.erase i₀ := by
    ext x; simp [Finset.mem_erase, and_comm]
  rw [h3]
  ring

end Basic

section FirstMoment

variable {n d : ℕ}

/-- Translating the base point is a bijection of `𝔽₂ⁿ`, so every single cube point is
uniform: for fixed directions `v` and index `y`, exactly `|A|` base points `c` put the
`y`-th cube point into `A`. -/
lemma card_base_hit (A : Finset (Vec n)) (v : Fin d → Vec n) (y : Fin d → ZMod 2) :
    (univ.filter fun c : Vec n => pt c v y ∈ A).card = A.card := by
  refine Finset.card_nbij' (fun c => c + ∑ i, y i • v i) (fun a => a + ∑ i, y i • v i)
    ?_ ?_ ?_ ?_ <;> intro a ha <;> simp_all [pt, add_assoc, vadd_self]

/-- **First moment.** Summed over all parameters, the intersection count is
`2^d · |A| · 2^{nd}`; i.e. `E[|F ∩ A|] = 2^d · |A| / 2ⁿ`. -/
theorem sum_cnt (A : Finset (Vec n)) :
    ∑ p : Param n d, cnt A p.1 p.2 = 2 ^ d * A.card * 2 ^ (n * d) := by
  have key : ∀ v : Fin d → Vec n, ∑ c : Vec n, cnt A c v = 2 ^ d * A.card := by
    intro v
    simp only [cnt, Finset.card_filter]
    rw [Finset.sum_comm]
    have h2 : ∀ y : Fin d → ZMod 2, ∑ c : Vec n, (if pt c v y ∈ A then 1 else 0) = A.card := by
      intro y; rw [← card_base_hit A v y, Finset.card_filter]
    rw [Finset.sum_congr rfl (fun y (_ : y ∈ univ) => h2 y)]
    simp [Finset.card_univ]
  rw [Fintype.sum_prod_type, Finset.sum_comm]
  rw [Finset.sum_congr rfl (fun v (_ : v ∈ univ) => key v)]
  simp [Finset.card_univ, ZMod.card, ← pow_mul, mul_comm]

end FirstMoment

section Duality

variable {n d : ℕ}

lemma cnt_compl (A : Finset (Vec n)) (c : Vec n) (v : Fin d → Vec n) :
    cnt Aᶜ c v + cnt A c v = 2 ^ d := by
  have h := Finset.card_filter_add_card_filter_not
    (s := (univ : Finset (Fin d → ZMod 2))) (p := fun y => pt c v y ∈ A)
  have h2 : (univ.filter fun y : Fin d → ZMod 2 => pt c v y ∈ Aᶜ)
      = univ.filter fun y : Fin d → ZMod 2 => ¬ (pt c v y ∈ A) := by
    apply Finset.filter_congr; intro y _; simp
  rw [cnt, cnt, h2, Nat.add_comm]
  simpa using h

/-- **Duality.** Replacing `A` by its complement turns the statistic `s` into `2^d - s`. -/
theorem flatProb_compl (A : Finset (Vec n)) {s : ℕ} (hs : s ≤ 2 ^ d) :
    flatProb n d Aᶜ (2 ^ d - s) = flatProb n d A s := by
  have hset : hitSet n d Aᶜ (2 ^ d - s) = hitSet n d A s := by
    apply Finset.filter_congr
    intro p _
    have h := cnt_compl A p.1 p.2
    constructor
    · intro h1; omega
    · intro h1; omega
  rw [flatProb, flatProb, hset]

end Duality

section Parity

variable {n d : ℕ}

/-- Splitting the affine `(d+1)`-cube into the two parallel `d`-cubes obtained by fixing
the first coordinate of `y`. -/
lemma cnt_succ (A : Finset (Vec n)) (c : Vec n) (v : Fin (d + 1) → Vec n) :
    cnt A c v = cnt A c (fun i => v i.succ) + cnt A (c + v 0) (fun i => v i.succ) := by
  simp only [cnt_eq_sum]
  rw [← Fintype.sum_equiv (Fin.consEquiv (fun _ : Fin (d + 1) => ZMod 2))
      (fun q => if pt c v (Fin.cons q.1 q.2) ∈ A then 1 else 0)
      (fun y => if pt c v y ∈ A then 1 else 0) (fun q => by rfl)]
  rw [Fintype.sum_prod_type]
  have h2 : (univ : Finset (ZMod 2)) = {0, 1} := by decide
  rw [h2]
  simp [pt, Fin.sum_univ_succ, add_assoc]

/-- For a fixed subset `S ⊆ 𝔽₂ⁿ`, the number of pairs `(c, u)` for which exactly one of
`c`, `c + u` lies in `S` equals `2 |S| (2ⁿ - |S|)`. -/
lemma card_sym_diff_pairs (S : Finset (Vec n)) :
    (univ.filter fun p : Vec n × Vec n => ¬ ((p.1 ∈ S) ↔ (p.1 + p.2 ∈ S))).card
      = 2 * (S.card * (2 ^ n - S.card)) := by
  have hcardV : Fintype.card (Vec n) = 2 ^ n := card_Vec n
  rw [Finset.card_filter, Fintype.sum_prod_type]
  have inner : ∀ c : Vec n, (∑ u : Vec n, if ¬ ((c ∈ S) ↔ (c + u ∈ S)) then 1 else 0)
      = if c ∈ S then Sᶜ.card else S.card := by
    intro c
    rw [← Finset.card_filter]
    by_cases hc : c ∈ S
    · have h1 : (univ.filter fun u : Vec n => ¬ ((c ∈ S) ↔ (c + u ∈ S)))
          = univ.filter fun u : Vec n => c + u ∈ Sᶜ := by
        apply Finset.filter_congr; intro u _; simp [hc]
      rw [h1, card_translate, if_pos hc]
    · have h1 : (univ.filter fun u : Vec n => ¬ ((c ∈ S) ↔ (c + u ∈ S)))
          = univ.filter fun u : Vec n => c + u ∈ S := by
        apply Finset.filter_congr; intro u _; simp [hc]
      rw [h1, card_translate, if_neg hc]
  rw [Finset.sum_congr rfl (fun c _ => inner c)]
  rw [Finset.sum_ite]
  simp only [Finset.sum_const, smul_eq_mul, Finset.filter_univ_mem]
  rw [Finset.card_compl, hcardV]
  have h3 : (univ.filter fun c : Vec n => c ∉ S) = Sᶜ := by ext x; simp
  rw [h3, Finset.card_compl, hcardV]
  ring

/-- The elementary inequality `4 m (M - m) ≤ M²` behind the parity bound. -/
lemma four_mul_mul_le (M m : ℕ) (h : m ≤ M) : 4 * (m * (M - m)) ≤ M * M := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le h
  simp only [Nat.add_sub_cancel_left]
  zify
  nlinarith [sq_nonneg ((m : ℤ) - k)]

/-- Key step: for fixed directions `w`, at most half of the pairs `(c, u)` give an odd
count for the cube spanned by `u, w` based at `c`. -/
lemma key_pair_bound (A : Finset (Vec n)) (w : Fin d → Vec n) :
    2 * (univ.filter fun p : Vec n × Vec n =>
          ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w))).card ≤ 2 ^ (2 * n) := by
  classical
  set S : Finset (Vec n) := univ.filter fun c : Vec n => ¬ (2 ∣ cnt A c w) with hS
  have hset : (univ.filter fun p : Vec n × Vec n => ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w)))
      = univ.filter fun p : Vec n × Vec n => ¬ ((p.1 ∈ S) ↔ (p.1 + p.2 ∈ S)) := by
    apply Finset.filter_congr
    intro p _
    simp only [hS, Finset.mem_filter, Finset.mem_univ, true_and]
    omega
  rw [hset, card_sym_diff_pairs, ← mul_assoc]
  have hle : S.card ≤ 2 ^ n := by
    rw [← card_Vec n]; exact Finset.card_le_univ S
  calc 2 * 2 * (S.card * (2 ^ n - S.card)) = 4 * (S.card * (2 ^ n - S.card)) := by ring
    _ ≤ 2 ^ n * 2 ^ n := four_mul_mul_le _ _ hle
    _ = 2 ^ (2 * n) := by rw [two_mul, pow_add]

/-- **The parity bound.** For every subset `A ⊆ 𝔽₂ⁿ` and every `d ≥ 1`, a uniformly random
affine `d`-cube meets `A` in an odd number of points with probability at most `1/2`. -/
theorem oddProb_le_half (n d : ℕ) (A : Finset (Vec n)) : oddProb n (d + 1) A ≤ 1 / 2 := by
  classical
  set f : Vec n → Vec n → (Fin d → Vec n) → ℕ :=
    fun c a w => if ¬ (2 ∣ (cnt A c w + cnt A (c + a) w)) then 1 else 0 with hf
  have hL : (oddSet n (d + 1) A).card
      = ∑ c : Vec n, ∑ a : Vec n, ∑ w : Fin d → Vec n, f c a w := by
    simp only [oddSet, Finset.card_filter]
    rw [Fintype.sum_prod_type]
    refine Finset.sum_congr rfl ?_
    intro c _
    rw [← Fintype.sum_equiv (Fin.consEquiv (fun _ : Fin (d + 1) => Vec n))
        (fun q => if ¬ (2 ∣ cnt A c (Fin.cons q.1 q.2)) then 1 else 0)
        (fun v => if ¬ (2 ∣ cnt A c v) then 1 else 0) (fun q => by rfl)]
    rw [Fintype.sum_prod_type]
    refine Finset.sum_congr rfl (fun a _ => Finset.sum_congr rfl (fun w _ => ?_))
    rw [cnt_succ]
    simp [hf]
  have hsum : (oddSet n (d + 1) A).card = ∑ w : Fin d → Vec n,
      (univ.filter fun p : Vec n × Vec n =>
        ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w))).card := by
    rw [hL]
    rw [show (∑ c : Vec n, ∑ a : Vec n, ∑ w : Fin d → Vec n, f c a w)
        = ∑ c : Vec n, ∑ w : Fin d → Vec n, ∑ a : Vec n, f c a w from
      Finset.sum_congr rfl (fun c _ => Finset.sum_comm)]
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl (fun w _ => ?_)
    rw [Finset.card_filter, Fintype.sum_prod_type]
  have hbound : 2 * (oddSet n (d + 1) A).card ≤ 2 ^ (n * (d + 2)) := by
    rw [hsum, Finset.mul_sum]
    calc ∑ w : Fin d → Vec n, 2 * (univ.filter fun p : Vec n × Vec n =>
            ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w))).card
        ≤ ∑ _w : Fin d → Vec n, 2 ^ (2 * n) :=
          Finset.sum_le_sum (fun w _ => key_pair_bound A w)
      _ = 2 ^ (n * d) * 2 ^ (2 * n) := by
          simp [Finset.card_univ, ZMod.card, ← pow_mul, mul_comm]
      _ = 2 ^ (n * (d + 2)) := by rw [← pow_add]; ring_nf
  rw [oddProb, div_le_iff₀ (by positivity : (0 : ℚ) < 2 ^ (n * (d + 1 + 1)))]
  have h2 : ((2 : ℚ) * (oddSet n (d + 1) A).card) ≤ 2 ^ (n * (d + 2)) := by
    exact_mod_cast hbound
  have h3 : n * (d + 1 + 1) = n * (d + 2) := by ring
  rw [h3]
  linarith

/-- **`λ(d, s) ≤ 1/2` for odd `s`.** -/
theorem flatProb_le_half_of_odd (n d : ℕ) (A : Finset (Vec n)) {s : ℕ} (hs : Odd s) :
    flatProb n (d + 1) A s ≤ 1 / 2 := by
  have hsub : hitSet n (d + 1) A s ⊆ oddSet n (d + 1) A := by
    intro p hp
    simp only [hitSet, Finset.mem_filter, Finset.mem_univ, true_and] at hp
    simp only [oddSet, Finset.mem_filter, Finset.mem_univ, true_and, hp]
    rw [Nat.odd_iff] at hs
    omega
  have hcard : ((hitSet n (d + 1) A s).card : ℚ) ≤ (oddSet n (d + 1) A).card := by
    exact_mod_cast Finset.card_le_card hsub
  refine le_trans ?_ (oddProb_le_half n d A)
  rw [flatProb, oddProb]
  gcongr

end Parity

section Sharpness

variable {n d : ℕ}

/-- Independence of the directions, stated concretely: no nontrivial `𝔽₂`-combination
vanishes. -/
def Indep {n d : ℕ} (v : Fin d → Vec n) : Prop :=
  ∀ y : Fin d → ZMod 2, y ≠ 0 → ∑ i, y i • v i ≠ 0

instance {n d : ℕ} (v : Fin d → Vec n) : Decidable (Indep v) := by
  unfold Indep; infer_instance

lemma pt_injective (c : Vec n) {v : Fin d → Vec n} (hv : Indep v) :
    Function.Injective (pt c v) := by
  intro y y' h
  by_contra hne
  have hy : y - y' ≠ 0 := sub_ne_zero_of_ne hne
  apply hv (y - y') hy
  have hsub : ∑ i, (y i - y' i) • v i = (∑ i, y i • v i) - ∑ i, y' i • v i := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun i _ => by rw [sub_smul])
  simp only [Pi.sub_apply]
  rw [hsub]
  have h2 : (∑ i, y i • v i) = ∑ i, y' i • v i := by
    simp only [pt] at h
    exact add_left_cancel h
  rw [h2, sub_self]

/-- A nonzero vector of `𝔽₂^k` has a coordinate equal to `1`. -/
lemma exists_coord_one {k : ℕ} {y : Fin k → ZMod 2} (hy : y ≠ 0) : ∃ i, y i = 1 := by
  by_contra h
  push_neg at h
  apply hy
  funext i
  have h2 := h i
  simp only [Pi.zero_apply]
  revert h2
  generalize y i = t
  revert t
  decide

/-- Updating one coordinate of the direction tuple shifts a linear combination whose
coefficient at that coordinate is `1`. -/
lemma sum_smul_update (y : Fin d → ZMod 2) (v : Fin d → Vec n) (i₀ : Fin d)
    (hy : y i₀ = 1) (a : Vec n) :
    ∑ i, y i • (Function.update v i₀ a) i = (∑ i, y i • v i) + (a + v i₀) := by
  have hfun : (fun i => y i • (Function.update v i₀ a) i)
      = Function.update (fun i => y i • v i) i₀ (y i₀ • a) := by
    funext i
    by_cases h : i = i₀ <;> simp [h, Function.update_apply]
  rw [show (∑ i, y i • (Function.update v i₀ a) i)
      = ∑ i, Function.update (fun i => y i • v i) i₀ (y i₀ • a) i from by rw [hfun]]
  rw [Finset.sum_update_of_mem (mem_univ i₀)]
  rw [← Finset.sum_erase_add univ (fun i => y i • v i) (mem_univ i₀)]
  have h3 : (univ : Finset (Fin d)) \ {i₀} = univ.erase i₀ := by
    ext x; simp [Finset.mem_erase, and_comm]
  rw [h3, hy, one_smul, one_smul]
  rw [show (∑ x ∈ univ.erase i₀, y x • v x + v i₀ + (a + v i₀))
      = a + (∑ x ∈ univ.erase i₀, y x • v x) + (v i₀ + v i₀) from by abel]
  rw [vadd_self, add_zero]

/-- For a fixed nonzero coefficient vector, exactly a `2^{-n}` fraction of direction tuples
annihilate it. -/
lemma card_vanishing (n d : ℕ) {y : Fin (d + 1) → ZMod 2} (hy : y ≠ 0) :
    (univ.filter fun v : Fin (d + 1) → Vec n => ∑ i, y i • v i = 0).card * 2 ^ n
      = 2 ^ (n * (d + 1)) := by
  classical
  obtain ⟨i₀, hi₀⟩ := exists_coord_one hy
  set F : Finset (Fin (d + 1) → Vec n) := univ.filter fun v => ∑ i, y i • v i = 0 with hF
  have hbij : (F ×ˢ (univ : Finset (Vec n))).card
      = (univ : Finset (Fin (d + 1) → Vec n)).card := by
    refine Finset.card_nbij' (fun q => Function.update q.1 i₀ (q.1 i₀ + q.2))
      (fun w => (Function.update w i₀ (w i₀ + ∑ i, y i • w i), ∑ i, y i • w i)) ?_ ?_ ?_ ?_
    · intro q hq; simp
    · intro w hw
      simp only [Finset.coe_product, Set.mem_prod, Finset.mem_coe, Finset.mem_filter,
        Finset.mem_univ, true_and, hF]
      refine ⟨?_, trivial⟩
      rw [sum_smul_update y w i₀ hi₀]
      rw [show (w i₀ + ∑ i, y i • w i + w i₀) = (∑ i, y i • w i) + (w i₀ + w i₀) from by abel,
        vadd_self, add_zero]
      exact vadd_self _
    · intro q hq
      simp only [Finset.coe_product, Set.mem_prod, Finset.mem_coe, Finset.mem_filter,
        Finset.mem_univ, true_and, hF] at hq
      obtain ⟨hq1, -⟩ := hq
      dsimp only
      have hs : ∑ i, y i • Function.update q.1 i₀ (q.1 i₀ + q.2) i = q.2 := by
        rw [sum_smul_update y q.1 i₀ hi₀, hq1]
        rw [show (0 + (q.1 i₀ + q.2 + q.1 i₀)) = q.2 + (q.1 i₀ + q.1 i₀) from by abel,
          vadd_self, add_zero]
      rw [hs, Function.update_idem, Function.update_self]
      rw [show (q.1 i₀ + q.2 + q.2) = q.1 i₀ + (q.2 + q.2) from by abel, vadd_self, add_zero]
      rw [Function.update_eq_self]
    · intro w hw
      dsimp only
      rw [Function.update_idem, Function.update_self]
      rw [show (w i₀ + (∑ i, y i • w i) + ∑ i, y i • w i)
          = w i₀ + ((∑ i, y i • w i) + (∑ i, y i • w i)) from by abel, vadd_self, add_zero]
      exact Function.update_eq_self i₀ w
  rw [Finset.card_product] at hbij
  simp only [Finset.card_univ, card_Vec] at hbij
  rw [hbij]
  simp [← pow_mul]

/-- Union bound: all but a `(2^{d+1} - 1)/2ⁿ` fraction of direction tuples are independent. -/
lemma card_indep_ge (n d : ℕ) :
    2 ^ (n * (d + 1)) ≤
      (univ.filter fun v : Fin (d + 1) → Vec n => Indep v).card
        + (2 ^ (d + 1) - 1) * 2 ^ (n * d) := by
  classical
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := (univ : Finset (Fin (d + 1) → Vec n))) (p := fun v => Indep v)
  rw [Finset.card_univ] at hsplit
  have hcard : Fintype.card (Fin (d + 1) → Vec n) = 2 ^ (n * (d + 1)) := by
    simp [← pow_mul]
  rw [hcard] at hsplit
  have hsub : (univ.filter fun v : Fin (d + 1) → Vec n => ¬ Indep v)
      ⊆ (univ.filter fun y : Fin (d + 1) → ZMod 2 => y ≠ 0).biUnion
          (fun y => univ.filter fun v : Fin (d + 1) → Vec n => ∑ i, y i • v i = 0) := by
    intro v hv
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Indep, not_forall] at hv
    obtain ⟨y, hy, hy2⟩ := hv
    simp only [Finset.mem_biUnion, Finset.mem_filter, Finset.mem_univ, true_and]
    exact ⟨y, hy, by simpa using hy2⟩
  have hfiber : ∀ y : Fin (d + 1) → ZMod 2, y ≠ 0 →
      (univ.filter fun v : Fin (d + 1) → Vec n => ∑ i, y i • v i = 0).card = 2 ^ (n * d) := by
    intro y hy
    have h := card_vanishing n d hy
    have h2 : 2 ^ (n * (d + 1)) = 2 ^ (n * d) * 2 ^ n := by rw [← pow_add, Nat.mul_succ]
    rw [h2] at h
    exact Nat.eq_of_mul_eq_mul_right (Nat.two_pow_pos n) h
  have hbound : (univ.filter fun v : Fin (d + 1) → Vec n => ¬ Indep v).card
      ≤ (2 ^ (d + 1) - 1) * 2 ^ (n * d) := by
    refine le_trans (Finset.card_le_card hsub) ?_
    refine le_trans (Finset.card_biUnion_le) ?_
    rw [Finset.sum_congr rfl (fun y hy => hfiber y (by simpa using (Finset.mem_filter.mp hy).2))]
    rw [Finset.sum_const, smul_eq_mul]
    have hnz : (univ.filter fun y : Fin (d + 1) → ZMod 2 => y ≠ 0).card = 2 ^ (d + 1) - 1 := by
      have h1 := Finset.card_filter_add_card_filter_not
        (s := (univ : Finset (Fin (d + 1) → ZMod 2))) (p := fun y => y ≠ 0)
      rw [Finset.card_univ] at h1
      have h2 : (univ.filter fun y : Fin (d + 1) → ZMod 2 => ¬ (y ≠ 0)) = {0} := by
        ext y; simp
      rw [h2] at h1
      simp only [Finset.card_singleton] at h1
      have h3 : Fintype.card (Fin (d + 1) → ZMod 2) = 2 ^ (d + 1) := by simp
      omega
    rw [hnz]
  omega

/-- Toggling one cube point changes the intersection parity. -/
lemma cnt_symmDiff (c : Vec n) (v : Fin d → Vec n) (hinj : Function.Injective (pt c v))
    (A : Finset (Vec n)) :
    ∃ T : ℕ, cnt A c v + cnt (symmDiff A {pt c v 0}) c v = 1 + 2 * T := by
  classical
  set y₀ : Fin d → ZMod 2 := 0
  set p₀ := pt c v y₀ with hp₀
  set B := symmDiff A {p₀} with hB
  refine ⟨(univ.erase y₀).filter (fun y => pt c v y ∈ A) |>.card, ?_⟩
  have hA : cnt A c v
      = (∑ y ∈ univ.erase y₀, if pt c v y ∈ A then 1 else 0) + (if p₀ ∈ A then 1 else 0) := by
    rw [cnt_eq_sum]
    exact (Finset.sum_erase_add _ _ (mem_univ y₀)).symm
  have htail : ∀ y ∈ univ.erase y₀, (if pt c v y ∈ B then 1 else 0)
      = (if pt c v y ∈ A then 1 else 0) := by
    intro y hy
    have hne : pt c v y ≠ p₀ := fun h => (Finset.mem_erase.mp hy).1 (hinj h)
    have hiff : (pt c v y ∈ B) ↔ (pt c v y ∈ A) := by
      simp [hB, Finset.mem_symmDiff, hne]
    simp [hiff]
  have hBc : cnt B c v
      = (∑ y ∈ univ.erase y₀, if pt c v y ∈ A then 1 else 0) + (if p₀ ∈ B then 1 else 0) := by
    rw [cnt_eq_sum, ← Finset.sum_erase_add _ _ (mem_univ y₀)]
    rw [Finset.sum_congr rfl htail]
  have hhead : (if p₀ ∈ B then 1 else 0) + (if p₀ ∈ A then 1 else 0) = 1 := by
    by_cases h : p₀ ∈ A
    · have hnB : p₀ ∉ B := by simp [hB, Finset.mem_symmDiff, h]
      simp [hnB, h]
    · have hmB : p₀ ∈ B := by simp [hB, Finset.mem_symmDiff, h]
      simp [hmB, h]
  rw [hA, hBc, ← Finset.card_filter]
  omega

/-- For an injective cube (i.e. a genuine `d`-flat), exactly half of all subsets `A ⊆ 𝔽₂ⁿ`
meet it in an odd number of points. -/
lemma card_subsets_odd (c : Vec n) {v : Fin d → Vec n} (hv : Indep v) :
    2 * (univ.filter fun A : Finset (Vec n) => ¬ (2 ∣ cnt A c v)).card
      = 2 ^ (2 ^ n) := by
  classical
  have key := card_filter_involutive (α := Finset (Vec n))
    (P := fun A => ¬ (2 ∣ cnt A c v))
    (g := fun A => symmDiff A {pt c v 0})
    (by intro A; simp [symmDiff_symmDiff_cancel_right])
    (by
      intro A
      dsimp only
      obtain ⟨T, hT⟩ := cnt_symmDiff c v (pt_injective c hv) A
      omega)
  rw [key]
  simp [Fintype.card_finset]

/-- The number of parameter pairs with independent directions. -/
lemma card_indepParams (n d : ℕ) :
    (univ.filter fun p : Param n (d + 1) => Indep p.2).card
      = 2 ^ n * (univ.filter fun v : Fin (d + 1) → Vec n => Indep v).card := by
  classical
  have hsplit : (univ.filter fun p : Param n (d + 1) => Indep p.2)
      = (univ : Finset (Vec n)) ×ˢ (univ.filter fun v : Fin (d + 1) → Vec n => Indep v) := by
    ext p
    simp
  rw [hsplit, Finset.card_product, Finset.card_univ, card_Vec]

/-- There is a subset whose odd-intersection count is at least the number of parameter
pairs with independent directions. -/
lemma exists_oddSet_ge (n d : ℕ) : ∃ A : Finset (Vec n),
    (univ.filter fun p : Param n (d + 1) => Indep p.2).card
      ≤ 2 * (oddSet n (d + 1) A).card := by
  classical
  by_contra hcon
  push_neg at hcon
  set IP := (univ.filter fun p : Param n (d + 1) => Indep p.2).card with hIP
  have hdc : ∑ A : Finset (Vec n), (oddSet n (d + 1) A).card
      = ∑ p : Param n (d + 1),
          (univ.filter fun A : Finset (Vec n) => ¬ (2 ∣ cnt A p.1 p.2)).card := by
    simp only [oddSet, Finset.card_filter]
    exact Finset.sum_comm
  have hlow : IP * 2 ^ (2 ^ n) ≤ 2 * ∑ p : Param n (d + 1),
      (univ.filter fun A : Finset (Vec n) => ¬ (2 ∣ cnt A p.1 p.2)).card := by
    rw [Finset.mul_sum]
    calc IP * 2 ^ (2 ^ n)
        = ∑ _p ∈ univ.filter (fun p : Param n (d + 1) => Indep p.2), 2 ^ (2 ^ n) := by
          rw [Finset.sum_const, smul_eq_mul, hIP]
      _ ≤ ∑ p ∈ univ.filter (fun p : Param n (d + 1) => Indep p.2),
            2 * (univ.filter fun A : Finset (Vec n) => ¬ (2 ∣ cnt A p.1 p.2)).card := by
          refine Finset.sum_le_sum (fun p hp => ?_)
          have hv : Indep p.2 := (Finset.mem_filter.mp hp).2
          rw [card_subsets_odd p.1 hv]
      _ ≤ ∑ p : Param n (d + 1),
            2 * (univ.filter fun A : Finset (Vec n) => ¬ (2 ∣ cnt A p.1 p.2)).card :=
          Finset.sum_le_sum_of_subset (Finset.filter_subset _ _)
  have hup : 2 * ∑ A : Finset (Vec n), (oddSet n (d + 1) A).card < IP * 2 ^ (2 ^ n) := by
    rw [Finset.mul_sum]
    calc ∑ A : Finset (Vec n), 2 * (oddSet n (d + 1) A).card
        < ∑ _A : Finset (Vec n), IP :=
          Finset.sum_lt_sum_of_nonempty ⟨∅, mem_univ _⟩ (fun A _ => hcon A)
      _ = IP * 2 ^ (2 ^ n) := by
          rw [Finset.sum_const, smul_eq_mul, Finset.card_univ, Fintype.card_finset, card_Vec]
          ring
  rw [hdc] at hup
  omega

/-- **Sharpness of the parity bound.** Averaging over all subsets `A` produces one whose
odd-intersection probability is within `(2^{d+1}-1)/2^{n+1}` of `1/2`. -/
theorem exists_oddProb_ge (n d : ℕ) :
    ∃ A : Finset (Vec n),
      (1 : ℚ) / 2 - (2 ^ (d + 1) - 1) / 2 ^ (n + 1) ≤ oddProb n (d + 1) A := by
  obtain ⟨A, hA⟩ := exists_oddSet_ge n d
  refine ⟨A, ?_⟩
  set X := (oddSet n (d + 1) A).card with hX
  -- the counting inequality
  have hN : 2 ^ (n * (d + 2)) ≤ 2 * X + (2 ^ (d + 1) - 1) * 2 ^ (n * (d + 1)) := by
    have h1 := card_indep_ge n d
    have h2 := card_indepParams n d
    have h3 : 2 ^ n * 2 ^ (n * (d + 1)) ≤ 2 ^ n *
        ((univ.filter fun v : Fin (d + 1) → Vec n => Indep v).card
          + (2 ^ (d + 1) - 1) * 2 ^ (n * d)) := Nat.mul_le_mul_left _ h1
    have h4 : 2 ^ n * 2 ^ (n * (d + 1)) = 2 ^ (n * (d + 2)) := by
      rw [← pow_add]; congr 1; ring
    have h5 : 2 ^ n * ((2 : ℕ) ^ (d + 1) - 1) * 2 ^ (n * d)
        = (2 ^ (d + 1) - 1) * 2 ^ (n * (d + 1)) := by
      rw [show (2 : ℕ) ^ (n * (d + 1)) = 2 ^ (n * d) * 2 ^ n from by
        rw [← pow_add, Nat.mul_succ]]
      ring
    rw [h4] at h3
    rw [h2] at hA
    nlinarith [h3, hA, h5]
  -- convert to the probability statement
  rw [oddProb, ← hX]
  have hone : (1 : ℕ) ≤ 2 ^ (d + 1) := Nat.one_le_two_pow
  have hD : (2 : ℚ) ^ (n * (d + 1 + 1)) = 2 ^ (n * (d + 1)) * 2 ^ n := by
    rw [← pow_add]; congr 1
  have hexp : n * (d + 2) = n * (d + 1 + 1) := by ring
  have hcast : ((2 : ℚ) ^ (d + 1) - 1) * 2 ^ (n * (d + 1)) + 2 * X
      ≥ 2 ^ (n * (d + 1)) * 2 ^ n := by
    have h := (Nat.cast_le (α := ℚ)).mpr hN
    push_cast [Nat.cast_sub hone] at h
    rw [hexp, hD] at h
    linarith
  have hpos : (0 : ℚ) < 2 ^ (n * (d + 1 + 1)) := by positivity
  have hQpos : (0 : ℚ) < 2 ^ n := by positivity
  rw [le_div_iff₀ hpos, hD]
  set P := (2 : ℚ) ^ (n * (d + 1))
  set Q := (2 : ℚ) ^ n
  set K := (2 : ℚ) ^ (d + 1)
  have hQ2 : (2 : ℚ) ^ (n + 1) = Q * 2 := by rw [pow_succ]
  rw [hQ2]
  have key : (1 / 2 - (K - 1) / (Q * 2)) * (P * Q) = P * Q / 2 - (K - 1) * P / 2 := by
    field_simp
  rw [key]
  linarith

/-- The maximum, over subsets `A ⊆ 𝔽₂ⁿ`, of the odd-intersection probability. -/
def maxOddProb (n d : ℕ) : ℚ :=
  (univ : Finset (Finset (Vec n))).sup' ⟨∅, mem_univ _⟩ (fun A => oddProb n d A)

lemma maxOddProb_le_half (n d : ℕ) : maxOddProb n (d + 1) ≤ 1 / 2 := by
  apply Finset.sup'_le
  intro A _
  exact oddProb_le_half n d A

lemma maxOddProb_ge (n d : ℕ) :
    (1 : ℚ) / 2 - (2 ^ (d + 1) - 1) / 2 ^ (n + 1) ≤ maxOddProb n (d + 1) := by
  obtain ⟨A, hA⟩ := exists_oddProb_ge n d
  exact le_trans hA (Finset.le_sup' (fun A => oddProb n (d + 1) A) (mem_univ A))

/-- **The parity statistic has limit exactly `1/2`.** -/
theorem tendsto_maxOddProb (d : ℕ) :
    Filter.Tendsto (fun n => ((maxOddProb n (d + 1) : ℚ) : ℝ)) Filter.atTop
      (nhds (1 / 2 : ℝ)) := by
  have hlow : Filter.Tendsto
      (fun n : ℕ => (1 : ℝ) / 2 - (2 ^ (d + 1) - 1) / 2 ^ (n + 1)) Filter.atTop
      (nhds (1 / 2 : ℝ)) := by
    have h0 : Filter.Tendsto (fun n : ℕ => ((2 : ℝ) ^ (d + 1) - 1) / 2 ^ (n + 1))
        Filter.atTop (nhds 0) := by
      have hgeom : Filter.Tendsto (fun n : ℕ => ((1 : ℝ) / 2) ^ n) Filter.atTop (nhds 0) :=
        tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
      have hrw : (fun n : ℕ => ((2 : ℝ) ^ (d + 1) - 1) / 2 ^ (n + 1))
          = fun n : ℕ => (((2 : ℝ) ^ (d + 1) - 1) / 2) * ((1 / 2) ^ n) := by
        funext n
        rw [div_pow, one_pow, pow_succ]
        field_simp
        ring
      rw [hrw]
      simpa using hgeom.const_mul (((2 : ℝ) ^ (d + 1) - 1) / 2)
    simpa using (tendsto_const_nhds (x := (1 : ℝ) / 2) (f := Filter.atTop (α := ℕ))).sub h0
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le hlow tendsto_const_nhds ?_ ?_
  · intro n
    have h1 : ((1 : ℚ) / 2 - (2 ^ (d + 1) - 1) / 2 ^ (n + 1) : ℚ)
        ≤ (maxOddProb n (d + 1) : ℚ) := maxOddProb_ge n d
    have h2 := (Rat.cast_le (K := ℝ)).mpr h1
    push_cast at h2
    linarith
  · intro n
    have h1 := (Rat.cast_le (K := ℝ)).mpr (maxOddProb_le_half n d)
    push_cast at h1
    linarith

end Sharpness

section Hyperplane

/-- The coordinate hyperplane `{x : x₀ = 0}` of `𝔽₂^{n+1}`. -/
def hyp (n : ℕ) : Finset (Vec (n + 1)) := univ.filter fun x => x 0 = 0

/-- If some direction vector leaves the hyperplane, exactly half of the cube lies in it. -/
lemma cnt_hyp_of_exists {n d : ℕ} (c : Vec (n + 1)) (v : Fin (d + 1) → Vec (n + 1))
    (h : ∃ i, v i 0 = 1) : cnt (hyp n) c v = 2 ^ d := by
  obtain ⟨i₀, hi₀⟩ := h
  have key := card_filter_involutive (α := Fin (d + 1) → ZMod 2)
    (P := fun y => pt c v y ∈ hyp n)
    (g := fun y => Function.update y i₀ (y i₀ + 1)) (flip_involutive i₀)
    (by
      intro y
      simp only [hyp, Finset.mem_filter, Finset.mem_univ, true_and, pt_apply]
      rw [sum_update_flip y i₀ (fun i => v i 0), hi₀, ← add_assoc]
      generalize (c 0 + ∑ i, y i * v i 0) = t
      revert t
      decide)
  rw [cnt]
  have hc : Fintype.card (Fin (d + 1) → ZMod 2) = 2 ^ (d + 1) := by simp
  rw [hc] at key
  omega

/-- If all direction vectors lie in the hyperplane, the whole cube is on one side. -/
lemma cnt_hyp_of_forall {n d : ℕ} (c : Vec (n + 1)) (v : Fin (d + 1) → Vec (n + 1))
    (h : ∀ i, v i 0 = 0) : cnt (hyp n) c v = if c 0 = 0 then 2 ^ (d + 1) else 0 := by
  have hpt : ∀ y : Fin (d + 1) → ZMod 2, pt c v y 0 = c 0 := by
    intro y
    rw [pt_apply]
    simp [h]
  by_cases hc : c 0 = 0
  · rw [if_pos hc, cnt]
    have : (univ.filter fun y : Fin (d + 1) → ZMod 2 => pt c v y ∈ hyp n) = univ := by
      apply Finset.filter_true_of_mem
      intro y _
      simp [hyp, hpt y, hc]
    rw [this]
    simp
  · rw [if_neg hc, cnt]
    have : (univ.filter fun y : Fin (d + 1) → ZMod 2 => pt c v y ∈ hyp n) = ∅ := by
      apply Finset.filter_false_of_mem
      intro y _
      simp [hyp, hpt y, hc]
    rw [this]
    simp

/-- The cube meets the hyperplane in exactly `2^d` points precisely when some direction
vector leaves the hyperplane. -/
lemma hitSet_hyp (n d : ℕ) :
    hitSet (n + 1) (d + 1) (hyp n) (2 ^ d)
      = univ.filter fun p : Param (n + 1) (d + 1) => ∃ i, p.2 i 0 = 1 := by
  apply Finset.filter_congr
  intro p _
  constructor
  · intro hcnt
    by_contra hno
    push_neg at hno
    have hall : ∀ i, p.2 i 0 = 0 := by
      intro i
      have := hno i
      revert this
      generalize p.2 i 0 = t
      revert t
      decide
    rw [cnt_hyp_of_forall p.1 p.2 hall] at hcnt
    by_cases hc : p.1 0 = 0
    · rw [if_pos hc] at hcnt
      have : (2 : ℕ) ^ d < 2 ^ (d + 1) := by
        exact Nat.pow_lt_pow_right (by norm_num) (by omega)
      omega
    · rw [if_neg hc] at hcnt
      have : 0 < (2 : ℕ) ^ d := Nat.two_pow_pos d
      omega
  · intro h
    exact cnt_hyp_of_exists p.1 p.2 h

/-- Exactly half of `𝔽₂^{n+1}` lies in the hyperplane. -/
lemma card_hyp (n : ℕ) : (univ.filter fun x : Vec (n + 1) => x 0 = 0).card = 2 ^ n := by
  have key := card_filter_involutive (α := Vec (n + 1)) (P := fun x => x 0 = 0)
    (g := fun x => Function.update x 0 (x 0 + 1))
    (by
      intro x
      funext i
      by_cases hii : i = 0 <;>
        simp [hii, Function.update_apply, add_assoc, show (1 + 1 : ZMod 2) = 0 from rfl])
    (by
      intro x
      simp only [Function.update_apply]
      generalize x 0 = t
      revert t
      decide)
  rw [card_Vec] at key
  omega

/-- The number of parameter pairs all of whose directions lie in the hyperplane. -/
lemma card_bad (n d : ℕ) :
    (univ.filter fun p : Param (n + 1) (d + 1) => ¬ ∃ i, p.2 i 0 = 1).card
      = 2 ^ (n + 1) * 2 ^ (n * (d + 1)) := by
  classical
  have hsplit : (univ.filter fun p : Param (n + 1) (d + 1) => ¬ ∃ i, p.2 i 0 = 1)
      = (univ : Finset (Vec (n + 1))) ×ˢ
        (Fintype.piFinset fun _ : Fin (d + 1) => univ.filter fun x : Vec (n + 1) => x 0 = 0) := by
    ext p
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_product,
      Fintype.mem_piFinset, not_exists]
    constructor
    · intro h i
      have := h i
      revert this
      generalize p.2 i 0 = t
      revert t
      decide
    · intro h i hi
      have := h i
      rw [hi] at this
      exact absurd this (by decide)
  rw [hsplit, Finset.card_product, Fintype.card_piFinset, card_hyp]
  simp [Finset.card_univ, ← pow_mul]

/-- **The lower-bound construction, exactly.** For the hyperplane `A = {x : x₀ = 0}`,
a random affine `(d+1)`-cube meets `A` in exactly `2^d` points with probability
`1 - 2^{-(d+1)}`. This is the `k = d` case of the construction giving
`λ*(d, j·2^k) ≥ 1 - 2^{-k}`. -/
theorem hyperplane_flatProb (n d : ℕ) :
    flatProb (n + 1) (d + 1) (hyp n) (2 ^ d) = 1 - (1 / 2) ^ (d + 1) := by
  classical
  have hcards : (hitSet (n + 1) (d + 1) (hyp n) (2 ^ d)).card
      + 2 ^ (n + 1) * 2 ^ (n * (d + 1)) = 2 ^ ((n + 1) * (d + 1 + 1)) := by
    rw [hitSet_hyp, ← card_bad n d]
    have h := Finset.card_filter_add_card_filter_not
      (s := (univ : Finset (Param (n + 1) (d + 1))))
      (p := fun p : Param (n + 1) (d + 1) => ∃ i, p.2 i 0 = 1)
    rw [Finset.card_univ, card_Param] at h
    convert h using 2
  have hT : (0 : ℚ) < 2 ^ ((n + 1) * (d + 1 + 1)) := by positivity
  have hQ : ((hitSet (n + 1) (d + 1) (hyp n) (2 ^ d)).card : ℚ)
      = 2 ^ ((n + 1) * (d + 1 + 1)) - 2 ^ (n + 1) * 2 ^ (n * (d + 1)) := by
    have := congrArg (fun m : ℕ => (m : ℚ)) hcards
    push_cast at this
    linarith
  rw [flatProb, hQ, sub_div]
  rw [div_self (ne_of_gt hT)]
  congr 1
  rw [div_eq_iff (ne_of_gt hT), one_div, inv_pow, inv_mul_eq_div, eq_div_iff (by positivity),
    ← pow_add, ← pow_add]
  congr 1
  ring

/-- **Contrarian corollary: the parity bound does not extend to even `s`.**
For `d ≥ 1` there are sets `A` and even values `s` with `P[|F ∩ A| = s| > 1/2`, so the
bound `λ(d, s) ≤ 1/2` genuinely requires `s` odd. -/
theorem exists_flatProb_gt_half (n d : ℕ) :
    1 / 2 < flatProb (n + 1) (d + 2) (hyp n) (2 ^ (d + 1)) := by
  rw [hyperplane_flatProb n (d + 1)]
  have h : ((1 : ℚ) / 2) ^ (d + 2) ≤ (1 / 2) ^ 2 := by
    apply pow_le_pow_of_le_one (by norm_num) (by norm_num) (by omega)
  norm_num at h ⊢
  linarith

end Hyperplane

section ExactCases

/-- The maximum of `P[|F ∩ A| = s]` over all `A ⊆ 𝔽₂ⁿ`. -/
def maxFlatProb (n d s : ℕ) : ℚ :=
  (univ : Finset (Finset (Vec n))).sup' ⟨∅, mem_univ _⟩ (fun A => flatProb n d A s)

/-- For `d = 1` a cube has two points, so an odd intersection means exactly one point. -/
lemma oddProb_eq_flatProb_one (n : ℕ) (A : Finset (Vec n)) :
    oddProb n 1 A = flatProb n 1 A 1 := by
  unfold oddProb flatProb oddSet hitSet
  congr 3
  apply Finset.filter_congr
  intro p _
  have h := cnt_le A p.1 p.2
  simp only [pow_one] at h
  omega

lemma maxFlatProb_one_eq (n : ℕ) : maxFlatProb n 1 1 = maxOddProb n 1 := by
  unfold maxFlatProb maxOddProb
  exact Finset.sup'_congr _ rfl (fun A _ => (oddProb_eq_flatProb_one n A).symm)

/-- **`λ*(1, 1) = 1/2` exactly.** This is the `d = 1` instance of the exact determination
of `λ*(d, 1)`: the random construction (here obtained by averaging over all subsets)
is optimal, and the value `(1 - 2^{-d})^{2^d - 1}` equals `1/2` when `d = 1`. -/
theorem tendsto_maxFlatProb_one :
    Filter.Tendsto (fun n => ((maxFlatProb n 1 1 : ℚ) : ℝ)) Filter.atTop
      (nhds (1 / 2 : ℝ)) := by
  have h := tendsto_maxOddProb 0
  simpa only [maxFlatProb_one_eq] using h

/-- **The formula `λ*(d, j·2^k) = 1 - 2^{-k}` breaks down at `s = 2^d`**: taking
`A = 𝔽₂ⁿ` gives probability `1`, not `1 - 2^{-d}`. So the regime `s < 2^d` is essential. -/
theorem flatProb_univ (n d : ℕ) : flatProb n d univ (2 ^ d) = 1 := by
  have hcnt : ∀ p : Param n d, cnt (univ : Finset (Vec n)) p.1 p.2 = 2 ^ d := by
    intro p
    simp [cnt, Finset.filter_true_of_mem]
  unfold flatProb hitSet
  rw [Finset.filter_true_of_mem (fun p _ => hcnt p)]
  rw [Finset.card_univ, card_Param]
  push_cast
  field_simp

set_option maxRecDepth 10000 in
/-- A finite check: for `n = d = 2` no subset attains the parity bound `1/2`. -/
lemma card_oddSet_dim2 : ∀ A : Finset (Vec 2), 2 * (oddSet 2 2 A).card < 2 ^ (2 * 3) := by
  decide

lemma oddProb_dim2_lt (A : Finset (Vec 2)) : oddProb 2 2 A < 1 / 2 := by
  have h := card_oddSet_dim2 A
  rw [oddProb, div_lt_div_iff₀ (by positivity) (by norm_num)]
  have hcast : ((2 * (oddSet 2 2 A).card : ℕ) : ℚ) < ((2 ^ (2 * 3) : ℕ) : ℚ) := by
    exact_mod_cast h
  push_cast at hcast
  norm_num at hcast ⊢
  linarith

/-- **The supremum `1/2` is not attained at finite `n`** (contrary to what the sharp
constant might suggest): for `n = d = 2` the maximum is strictly below `1/2`. Together
with `tendsto_maxOddProb` this shows the value `1/2` is a genuine limit. -/
theorem maxOddProb_dim2_lt_half : maxOddProb 2 2 < 1 / 2 := by
  rw [maxOddProb, Finset.sup'_lt_iff]
  intro A _
  exact oddProb_dim2_lt A

end ExactCases

end AffineStats