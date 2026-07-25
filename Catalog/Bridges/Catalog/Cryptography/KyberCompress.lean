/-
# Kyber Compression Fiber Structure

This file formalizes the fiber structure of the CRYSTALS-Kyber compression map,
proving that modular rounding creates a balanced partition governed by
the remainder q mod d.

## Main Results

* `kyberCompress` — The Kyber compression function mapping Fin q → Fin d
* `fiber_partition_sum` — Fibers partition the domain (sum of fiber sizes = q)
* `kyberFiber_card_le` — Each fiber has size at most q/d + 1
* `kyberFiber_card_ge` — Each fiber has size at least q/d
* `kyber_large_fiber_count` — Exactly q%d fibers have size q/d+1
* `kyber_params_verification` — Concrete verification for NIST parameters
* `kyber_prime_3329` — 3329 is prime
* `dpi_deterministic` — Data Processing Inequality for deterministic maps
-/
import Mathlib

open Finset

/-! ## Core Definitions -/

/-- The Kyber compression function: maps x ∈ {0,...,q-1} to ⌊d·x/q⌋.
    This is the deterministic rounding map used in CRYSTALS-Kyber. -/
def kyberCompress (q d : ℕ) (hd : 0 < d) (x : Fin q) : Fin d where
  val := d * x.val / q
  isLt := by
    apply Nat.div_lt_of_lt_mul
    have : x.val < q := x.isLt
    nlinarith

/-- The fiber of the compression map over output y:
    the set of inputs mapping to y. -/
def kyberFiber (q d : ℕ) (hd : 0 < d) (y : Fin d) : Finset (Fin q) :=
  Finset.univ.filter (fun x => kyberCompress q d hd x = y)

/-! ## NIST Parameter Verification -/

/-- 3329 is prime — the defining property of the Kyber modulus. -/
theorem kyber_prime_3329 : Nat.Prime 3329 := by native_decide

/-- The Kyber modulus is coprime with both compression moduli. -/
theorem kyber_coprime_1024 : Nat.Coprime 3329 1024 := by native_decide
theorem kyber_coprime_2048 : Nat.Coprime 3329 2048 := by native_decide

/-- Concrete verification of Kyber compression parameters.
    For q = 3329:
    - d₁ = 1024 (2¹⁰): 3329 mod 1024 = 257, giving 257 fibers of size 4 and 767 of size 3
    - d₂ = 2048 (2¹¹): 3329 mod 2048 = 1281, giving 1281 fibers of size 2 and 767 of size 1 -/
theorem kyber_params_verification :
    let q := 3329; let d₁ := 1024; let d₂ := 2048
    (q % d₁ = 257) ∧ (q % d₂ = 1281) ∧
    (q / d₁ = 3) ∧ (q / d₂ = 1) ∧
    (257 * 4 + 767 * 3 = q) ∧
    (1281 * 2 + 767 * 1 = q) := by
  native_decide

/-- Full parameter verification including primality and coprimality. -/
theorem kyber_full_params :
    let q := 3329
    let d₁ := 1024
    let d₂ := 2048
    Nat.Prime q ∧
    Nat.Coprime q d₁ ∧ Nat.Coprime q d₂ ∧
    q % d₁ = 257 ∧ q % d₂ = 1281 ∧
    q / d₁ = 3 ∧ q / d₂ = 1 ∧
    d₁ = 2^10 ∧ d₂ = 2^11 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

/-! ## General Fiber Structure -/

/-- Fibers of any function f : Fin n → Fin m partition the domain:
    the sum of fiber sizes equals n. -/
theorem fiber_partition_sum {n m : ℕ} (f : Fin n → Fin m) :
    ∑ y : Fin m, (Finset.univ.filter (fun x : Fin n => f x = y)).card = n := by
  have hdisj : Set.PairwiseDisjoint (↑(Finset.univ : Finset (Fin m)))
      (fun y => Finset.univ.filter (fun x : Fin n => f x = y)) := by
    intro i _ j _ hij
    exact Finset.disjoint_filter.mpr (fun x _ h1 h2 => hij (h1 ▸ h2))
  rw [← Finset.card_biUnion hdisj]
  have : Finset.biUnion Finset.univ
      (fun y : Fin m => Finset.univ.filter (fun x : Fin n => f x = y)) = Finset.univ := by
    ext x; simp [Finset.mem_biUnion]
  rw [this, Finset.card_fin]

/-
Each fiber of kyberCompress has size at most q/d + 1.
-/
theorem kyberFiber_card_le (q d : ℕ) (hq : 0 < q) (hd : 0 < d) (hdq : d ≤ q) (y : Fin d) :
    (kyberFiber q d hd y).card ≤ q / d + 1 := by
  refine' le_of_not_gt fun h => _;
  -- If there are more than $q/d + 1$ elements in the fiber, then there must be at least two elements $x_1$ and $x_2$ in the fiber such that $x_1 < x_2$ and $x_2 - x_1 \geq q/d + 1$.
  obtain ⟨x1, x2, hx1, hx2, h_diff⟩ : ∃ x1 x2 : Fin q, x1 ∈ kyberFiber q d hd y ∧ x2 ∈ kyberFiber q d hd y ∧ x1 < x2 ∧ x2.val - x1.val ≥ q / d + 1 := by
    -- Since there are more than $q/d + 1$ elements in the fiber, we can select $q/d + 2$ distinct elements from the fiber.
    obtain ⟨xs, hxs⟩ : ∃ xs : Fin (q / d + 2) → Fin q, (∀ i, xs i ∈ kyberFiber q d hd y) ∧ StrictMono xs := by
      obtain ⟨s, hs⟩ : ∃ s : Finset (Fin q), s.card = q / d + 2 ∧ ∀ x ∈ s, x ∈ kyberFiber q d hd y := by
        exact Exists.elim ( Finset.exists_subset_card_eq h ) fun s hs => ⟨ s, hs.2, fun x hx => hs.1 hx ⟩;
      exact ⟨ fun i => s.orderEmbOfFin ( by aesop ) i, fun i => hs.2 _ <| by aesop, fun i j hij => by simpa using hij ⟩;
    refine' ⟨ xs 0, xs ( Fin.last _ ), hxs.1 _, hxs.1 _, hxs.2 ( Nat.zero_lt_succ _ ), _ ⟩;
    have h_diff : ∀ i j : Fin (q / d + 2), i < j → (xs j).val ≥ (xs i).val + (j - i) := by
      intro i j hij; induction' j using Fin.inductionOn with j ih ih; aesop;
      grind +suggestions;
    exact le_tsub_of_add_le_left ( by have := h_diff 0 ( Fin.last _ ) ( Nat.zero_lt_succ _ ) ; norm_num at * ; linarith );
  unfold kyberFiber at hx1 hx2;
  simp_all +decide [ Fin.ext_iff, kyberCompress ];
  rw [ Nat.div_lt_iff_lt_mul <| by positivity ] at h_diff;
  nlinarith [ Nat.div_add_mod ( d * x2 ) q, Nat.mod_lt ( d * x2 ) hq, Nat.div_mul_le_self ( d * x1 ) q, Nat.sub_add_cancel ( show ( x1 : ℕ ) ≤ x2 from le_of_lt h_diff.1 ) ]

/-
Each fiber of kyberCompress has size at least q/d.
-/
theorem kyberFiber_card_ge (q d : ℕ) (hq : 0 < q) (hd : 0 < d) (hdq : d ≤ q) (y : Fin d) :
    q / d ≤ (kyberFiber q d hd y).card := by
  -- By definition of $kyberFiber$, we know that every element in $Fin d$ corresponds to a unique element in $Fin q$.
  have h_fiber_def : kyberFiber q d hd y = Finset.filter (fun x => y.val * q ≤ d * x.val ∧ d * x.val < (y.val + 1) * q) (Finset.univ : Finset (Fin q)) := by
    ext x;
    simp +decide [ kyberFiber, kyberCompress ];
    constructor <;> intro h <;> rw [ Fin.ext_iff ] at *;
    · exact ⟨ by nlinarith [ Nat.div_mul_le_self ( d * x ) q ], by nlinarith [ Nat.div_add_mod ( d * x ) q, Nat.mod_lt ( d * x ) hq ] ⟩;
    · exact Nat.le_antisymm ( Nat.le_of_lt_succ <| Nat.div_lt_of_lt_mul <| by linarith ) ( Nat.le_div_iff_mul_le hq |>.2 <| by linarith );
  -- The set of integers $x$ satisfying $y.val * q ≤ d * x$ and $d * x < (y.val + 1) * q$ forms an interval.
  have h_interval : Finset.card (Finset.Ico (Nat.ceil (y.val * q / d : ℚ)) (Nat.ceil ((y.val + 1) * q / d : ℚ))) ≤ Finset.card (Finset.filter (fun x : Fin q => y.val * q ≤ d * x.val ∧ d * x.val < (y.val + 1) * q) (Finset.univ : Finset (Fin q))) := by
    have h_interval : Finset.Ico (Nat.ceil (y.val * q / d : ℚ)) (Nat.ceil ((y.val + 1) * q / d : ℚ)) ⊆ Finset.image (fun x : Fin q => x.val) (Finset.filter (fun x : Fin q => y.val * q ≤ d * x.val ∧ d * x.val < (y.val + 1) * q) (Finset.univ : Finset (Fin q))) := by
      intro x hx;
      simp +zetaDelta at *;
      rw [ Nat.lt_ceil, lt_div_iff₀ ] at hx <;> norm_cast at *;
      exact ⟨ ⟨ x, by nlinarith [ Fin.is_lt y ] ⟩, ⟨ by rw [ div_le_iff₀ ( by positivity ) ] at hx; norm_cast at hx; linarith, by linarith ⟩, rfl ⟩;
    exact le_trans ( Finset.card_le_card h_interval ) ( Finset.card_image_le );
  -- The length of the interval is at least $q/d$.
  have h_interval_length : Nat.ceil ((y.val + 1) * q / d : ℚ) - Nat.ceil (y.val * q / d : ℚ) ≥ q / d := by
    refine' Nat.le_sub_of_add_le' _;
    refine Nat.le_of_lt_succ ?_ ; rw [ ← @Nat.cast_lt ℚ ] ; push_cast ; ring_nf;
    nlinarith [ Nat.ceil_lt_add_one ( show 0 ≤ ( y : ℚ ) * q * ( d : ℚ ) ⁻¹ by positivity ), Nat.le_ceil ( ( y : ℚ ) * q * ( d : ℚ ) ⁻¹ + q * ( d : ℚ ) ⁻¹ ), show ( q : ℚ ) * ( d : ℚ ) ⁻¹ ≥ ↑ ( q / d ) by rw [ ← div_eq_mul_inv ] ; rw [ ge_iff_le ] ; rw [ le_div_iff₀ ( by positivity ) ] ; norm_cast ; linarith [ Nat.div_mul_le_self q d ], mul_inv_cancel₀ ( by positivity : ( d : ℚ ) ≠ 0 ) ];
  simp_all +decide [ Nat.card_Ico ];
  refine le_trans h_interval_length ?_;
  exact Nat.sub_le_of_le_add <| Nat.ceil_le.mpr <| by simpa using h_interval;

/-
The number of fibers of size q/d + 1 equals q % d.
    This is the fundamental fiber structure theorem:
    by the division algorithm, q = d·(q/d) + (q%d),
    so exactly q%d fibers must be "oversized" to account for
    all q elements in the domain.
-/
theorem kyber_large_fiber_count (q d : ℕ) (hq : 0 < q) (hd : 0 < d) (hdq : d ≤ q) :
    (Finset.univ.filter (fun y : Fin d =>
      (kyberFiber q d hd y).card = q / d + 1)).card = q % d := by
  -- Let S = univ.filter (size = q/d+1), T = univ.filter (size = q/d).
  set S := Finset.univ.filter (fun y : Fin d => (kyberFiber q d hd y).card = q / d + 1)
  set T := Finset.univ.filter (fun y : Fin d => (kyberFiber q d hd y).card = q / d);
  -- By the properties of the fibers, we know that $|S| + |T| = d$ and $|S| \cdot (q / d + 1) + |T| \cdot (q / d) = q$.
  have h_sum : S.card + T.card = d := by
    rw [ ← Finset.card_union_of_disjoint, Finset.filter_union_right ];
    · convert Finset.card_fin d ; ext x ; simp +decide [ Finset.mem_union, Finset.mem_filter ];
      exact Classical.or_iff_not_imp_left.2 fun h => le_antisymm ( Nat.le_of_lt_succ <| lt_of_le_of_ne ( kyberFiber_card_le q d hq hd hdq x ) h ) ( kyberFiber_card_ge q d hq hd hdq x );
    · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;
  have h_eq : S.card * (q / d + 1) + T.card * (q / d) = q := by
    have h_eq : ∑ y : Fin d, (kyberFiber q d hd y).card = q := by
      convert fiber_partition_sum ( kyberCompress q d hd );
    have h_eq : ∑ y : Fin d, (kyberFiber q d hd y).card = ∑ y ∈ S, (q / d + 1) + ∑ y ∈ T, (q / d) := by
      rw [ Finset.sum_filter, Finset.sum_filter ];
      rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl ];
      intro y hy; split_ifs <;> simp_all +decide ;
      exact False.elim <| ‹¬#(kyberFiber q d hd y) = q / d + 1› <| le_antisymm ( kyberFiber_card_le q d hq hd hdq y ) <| Nat.succ_le_of_lt <| lt_of_le_of_ne ( kyberFiber_card_ge q d hq hd hdq y ) <| Ne.symm ‹_›;
    aesop;
  nlinarith [ Nat.mod_add_div q d ]

/-! ## Decision Advantage (Total Variation Distance) -/

/-- Decision advantage (total variation distance) between two PMFs on a finite type. -/
noncomputable def decisionAdvantage {α : Type*} [Fintype α] (p q : PMF α) : ℝ :=
  (1 / 2) * ∑ x : α, |(p x).toReal - (q x).toReal|

/-- Decision advantage is nonnegative. -/
theorem decisionAdvantage_nonneg {α : Type*} [Fintype α] (p q : PMF α) :
    0 ≤ decisionAdvantage p q := by
  unfold decisionAdvantage
  positivity

/-
The Data Processing Inequality: deterministic maps cannot increase
    decision advantage.
-/
theorem dpi_deterministic {α β : Type*} [Fintype α] [Fintype β]
    (f : α → β) (p q : PMF α) :
    decisionAdvantage (PMF.map f p) (PMF.map f q) ≤ decisionAdvantage p q := by
  refine' mul_le_mul_of_nonneg_left ( le_trans _ ( Finset.sum_le_sum fun y hy => _ ) ) ( by norm_num );
  convert Finset.sum_le_sum fun y _ => Finset.abs_sum_le_sum_abs ( fun x => ( if f x = y then ( p x |> ENNReal.toReal ) - ( q x |> ENNReal.toReal ) else 0 ) ) ( Finset.univ : Finset α ) using 1;
  rotate_left 1;
  rw [ Finset.sum_comm ];
  exact Finset.univ;
  exact fun _ _ => Classical.dec _;
  · rw [ Finset.sum_eq_single ( f y ) ] <;> aesop;
  · simp +decide [ Finset.sum_ite, PMF.map_apply ];
    congr! 3;
    · rw [ ENNReal.toReal_sum ] ; congr ; ext ; aesop;
      exact fun x _ => p.apply_ne_top x;
    · rw [ ENNReal.toReal_sum ] ; congr ; ext ; aesop;
      exact fun x _ => q.apply_ne_top x

/-! ## FiberContraction Structure -/

/-- A fiber contraction certificate for a map between finite types.
    Records the fiber geometry and proves balance between fiber sizes. -/
structure FiberContraction (α β : Type*) [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) where
  /-- The size of each fiber -/
  fiberSizes : β → ℕ
  /-- Each fiber has the declared size -/
  fiber_card : ∀ y, (Finset.univ.filter (fun x => f x = y)).card = fiberSizes y
  /-- Each fiber size is either ⌊|α|/|β|⌋ or ⌈|α|/|β|⌉ -/
  fiber_balance : ∀ y, fiberSizes y = Fintype.card α / Fintype.card β ∨
                       fiberSizes y = Fintype.card α / Fintype.card β + 1