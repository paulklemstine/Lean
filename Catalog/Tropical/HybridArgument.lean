import Mathlib
import Tropical.OrbitPRG.StatDist

/-!
# Hybrid Argument for Orbit PRG

This file proves that conditional extraction at each orbit step implies
global pseudorandomness. The proof is decomposed into:

1. An abstract error accumulation lemma (pure induction)
2. Distribution definitions and basic properties
3. The one-step chain rule
4. The main orbit PRG theorem

## Main Results

* `error_accumulation` — If err(0) ≤ ε and err(n+1) ≤ err(n) + ε, then err(n) ≤ (n+1)*ε.
* `pushfwdDist_sum` — Pushforward distribution sums to 1.
* `tropical_orbit_prg` — The main PRG theorem.
-/

noncomputable section

open Finset BigOperators

namespace OrbitPRG

/-! ## §1. Abstract Error Accumulation -/

/-
If an error sequence starts at most ε and grows by at most ε per step,
    then after n steps the error is at most (n+1)*ε.
-/
theorem error_accumulation (err : ℕ → ℝ) (ε : ℝ) (hε : 0 ≤ ε)
    (h0 : err 0 ≤ ε)
    (hstep : ∀ n, err (n + 1) ≤ err n + ε) :
    ∀ n, err n ≤ (n + 1 : ℝ) * ε := by
  exact fun n => Nat.recOn n ( by norm_num; linarith ) fun n ihn => by norm_num; linarith [ hstep n ] ;

/-! ## §2. Distributions -/

/-- Pushforward distribution via counting measure on a finset. -/
def pushfwdDist {S α : Type*} [DecidableEq α]
    (seed : Finset S) (f : S → α) : α → ℝ :=
  fun a => ((seed.filter (fun s => f s = a)).card : ℝ) / seed.card

/-- Uniform distribution on a finite type. -/
def uniformDist (α : Type*) [Fintype α] : α → ℝ :=
  fun _ => (1 : ℝ) / Fintype.card α

theorem pushfwdDist_nonneg {S α : Type*} [DecidableEq α]
    (seed : Finset S) (f : S → α) (a : α) :
    0 ≤ pushfwdDist seed f a :=
  div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)

theorem pushfwdDist_sum {S α : Type*} [Fintype α] [DecidableEq α]
    (seed : Finset S) (f : S → α) (hS : seed.Nonempty) :
    ∑ a : α, pushfwdDist seed f a = 1 := by
  unfold pushfwdDist;
  rw [ ← Finset.sum_div, div_eq_iff ] <;> norm_cast <;> simp +decide [ Finset.nonempty_iff_ne_empty, hS.ne_empty ];
  simp +decide only [card_filter];
  rw [ Finset.sum_comm ] ; aesop

/-! ## §3. Orbit Hash and Conditional Extraction -/

/-- The orbit hash map: seed → sequence of hashed orbit states. -/
def orbitHash {S M β : Type*} (powTrop : S → ℕ → M) (h : M → β) (T : ℕ) :
    S → (Fin (T + 1) → β) :=
  fun s i => h (powTrop s i.val)

/-- The orbit hash distribution on `Fin (T+1) → β`. -/
def orbitHashDist {S M β : Type*} [DecidableEq β] [Fintype β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β) (T : ℕ) :
    (Fin (T + 1) → β) → ℝ :=
  pushfwdDist seed (orbitHash powTrop h T)

/-- The prefix fiber: seeds whose hashed orbit prefix matches `p`. -/
def prefixFiber {S M β : Type*} [DecidableEq β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β) (i : ℕ)
    (p : Fin i → β) : Finset S :=
  seed.filter (fun s => ∀ j : Fin i, h (powTrop s j.val) = p j)

/-- Conditional extraction: for each prefix, the next hash is ε-close to uniform. -/
def condExtract {S M β : Type*} [Fintype β] [DecidableEq β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β)
    (i : ℕ) (ε : ℝ) : Prop :=
  ∀ p : Fin i → β,
    let fiber := prefixFiber seed powTrop h i p
    fiber.Nonempty →
    statDist
      (fun b => ((fiber.filter (fun s => h (powTrop s i) = b)).card : ℝ) / fiber.card)
      (uniformDist β) ≤ ε

/-! ## §4. One-Step Chain Rule -/

/-
**One-step chain rule**: If the orbit hash at time T is δ-close to uniform,
    and conditional extraction holds at step T+1 with error ε, then the
    orbit hash at time T+1 is (δ+ε)-close to uniform.
-/
set_option maxHeartbeats 800000 in
theorem orbit_extension_statDist
    {S M β : Type*} [Fintype S] [Fintype β] [DecidableEq S] [DecidableEq β]
    [DecidableEq M] [Nonempty β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β)
    (T : ℕ) (δ ε : ℝ) (hε : 0 ≤ ε) (hδ : 0 ≤ δ)
    (h_seed : seed.Nonempty)
    (h_prev : statDist (orbitHashDist seed powTrop h T) (uniformDist (Fin (T + 1) → β)) ≤ δ)
    (h_extract : condExtract seed powTrop h (T + 1) ε) :
    statDist (orbitHashDist seed powTrop h (T + 1))
      (uniformDist (Fin (T + 2) → β)) ≤ δ + ε := by
  simp +decide [ statDist, orbitHashDist ] at *;
  simp +decide [ pushfwdDist, uniformDist, orbitHash ] at *;
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ x : Fin (T + 2) → β, |((seed.filter (fun s => orbitHash powTrop h (T + 1) s = x)).card : ℝ) / seed.card - (1 / (Fintype.card β) ^ (T + 2))| = ∑ p : Fin (T + 1) → β, ∑ b : β, |((seed.filter (fun s => orbitHash powTrop h T s = p ∧ h (powTrop s (T + 1)) = b)).card : ℝ) / seed.card - (1 / (Fintype.card β) ^ (T + 2))| := by
    rw [ ← Finset.sum_product' ];
    refine' Finset.sum_bij ( fun x _ => ( fun i => x i.castSucc, x ( Fin.last _ ) ) ) _ _ _ _ <;> simp +decide [ Fin.ext_iff, orbitHash ];
    · exact fun a₁ a₂ h₁ h₂ => funext fun i => by cases i using Fin.lastCases <;> simp_all +decide [ funext_iff ] ;
    · exact fun a b => ⟨ Fin.snoc a b, by ext i; simp +decide, by simp +decide ⟩;
    · intro a; congr; ext s; simp +decide [ funext_iff, Fin.ext_iff, orbitHash ] ;
      exact ⟨ fun h => ⟨ fun i => h ( Fin.castSucc i ), h ( Fin.last _ ) ⟩, fun h i => by cases i using Fin.lastCases <;> simp +decide [ * ] ⟩;
  -- Apply the triangle inequality to each term in the sum.
  have h_triangle : ∀ p : Fin (T + 1) → β, ∑ b : β, |((seed.filter (fun s => orbitHash powTrop h T s = p ∧ h (powTrop s (T + 1)) = b)).card : ℝ) / seed.card - (1 / (Fintype.card β) ^ (T + 2))| ≤ ∑ b : β, |((seed.filter (fun s => orbitHash powTrop h T s = p ∧ h (powTrop s (T + 1)) = b)).card : ℝ) / ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) - (1 / (Fintype.card β))| * ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) / seed.card + |((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) / seed.card - (1 / (Fintype.card β) ^ (T + 1))| := by
    intro p
    have h_triangle : ∀ b : β, |((seed.filter (fun s => orbitHash powTrop h T s = p ∧ h (powTrop s (T + 1)) = b)).card : ℝ) / seed.card - (1 / (Fintype.card β) ^ (T + 2))| ≤ |((seed.filter (fun s => orbitHash powTrop h T s = p ∧ h (powTrop s (T + 1)) = b)).card : ℝ) / ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) - (1 / (Fintype.card β))| * ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) / seed.card + |((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) / seed.card - (1 / (Fintype.card β) ^ (T + 1))| * (1 / (Fintype.card β)) := by
      intro b
      by_cases h_card : (seed.filter (fun s => orbitHash powTrop h T s = p)).card = 0;
      · simp_all +decide [ Finset.ext_iff ];
        simp_all +decide [ Finset.filter_eq_empty_iff.mpr ];
        rw [ ← mul_inv, pow_succ ];
      · have h_triangle : |((seed.filter (fun s => orbitHash powTrop h T s = p ∧ h (powTrop s (T + 1)) = b)).card : ℝ) / seed.card - (1 / (Fintype.card β) ^ (T + 2))| ≤ |((seed.filter (fun s => orbitHash powTrop h T s = p ∧ h (powTrop s (T + 1)) = b)).card : ℝ) / ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) - (1 / (Fintype.card β))| * ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) / seed.card + |((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) / seed.card - (1 / (Fintype.card β) ^ (T + 1))| * (1 / (Fintype.card β)) := by
          have h_eq : ((seed.filter (fun s => orbitHash powTrop h T s = p ∧ h (powTrop s (T + 1)) = b)).card : ℝ) / seed.card = ((seed.filter (fun s => orbitHash powTrop h T s = p ∧ h (powTrop s (T + 1)) = b)).card : ℝ) / ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) * ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) / seed.card := by
            rw [ div_mul_cancel₀ _ ( Nat.cast_ne_zero.mpr h_card ) ]
          rw [ h_eq ];
          have h_triangle : ∀ x y z w : ℝ, 0 ≤ x → 0 ≤ y → 0 ≤ z → 0 ≤ w → |x * y - z * w| ≤ |x - z| * y + |y - w| * z := by
            intro x y z w hx hy hz hw; rw [ abs_le ] ; constructor <;> cases abs_cases ( x - z ) <;> cases abs_cases ( y - w ) <;> nlinarith;
          convert h_triangle ( ( # ( { s ∈ seed | orbitHash powTrop h T s = p ∧ h ( powTrop s ( T + 1 ) ) = b } ) : ℝ ) / # ( { s ∈ seed | orbitHash powTrop h T s = p } ) ) ( ( # ( { s ∈ seed | orbitHash powTrop h T s = p } ) : ℝ ) / #seed ) ( 1 / ( Fintype.card β : ℝ ) ) ( 1 / ( Fintype.card β : ℝ ) ^ ( T + 1 ) ) ( by positivity ) ( by positivity ) ( by positivity ) ( by positivity ) using 1 ; ring;
          ring;
        exact h_triangle;
    refine' le_trans ( Finset.sum_le_sum fun _ _ => h_triangle _ ) _;
    simp +decide [ Finset.sum_add_distrib, mul_div_assoc ];
    rw [ mul_left_comm, mul_inv_cancel₀ ( Nat.cast_ne_zero.mpr <| Fintype.card_ne_zero ), mul_one ];
  -- Apply the hypothesis `h_extract` to each term in the sum.
  have h_extract_sum : ∀ p : Fin (T + 1) → β, (seed.filter (fun s => orbitHash powTrop h T s = p)).Nonempty → ∑ b : β, |((seed.filter (fun s => orbitHash powTrop h T s = p ∧ h (powTrop s (T + 1)) = b)).card : ℝ) / ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) - (1 / (Fintype.card β))| ≤ 2 * ε := by
    intro p hp_nonempty
    specialize h_extract (fun i => p ⟨i.val, by
      exact i.2⟩) (by
    all_goals generalize_proofs at *;
    obtain ⟨ s, hs ⟩ := hp_nonempty; use s; simp_all +decide [ prefixFiber, orbitHash ] ;
    exact fun j => congr_fun hs.2 j ▸ rfl);
    all_goals generalize_proofs at *;
    convert mul_le_mul_of_nonneg_left h_extract zero_le_two using 1;
    unfold statDist uniformDist; simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, abs_mul, abs_div, abs_of_nonneg, hε, hδ ] ;
    congr! 3;
    congr! 2;
    · congr! 1;
      ext; simp [prefixFiber];
      simp +decide [ orbitHash, funext_iff, Fin.forall_fin_succ ];
      tauto;
    · congr! 1;
      ext; simp [orbitHash, prefixFiber];
      exact fun _ => ⟨ fun h j => congr_fun h j, fun h => funext fun j => h j ⟩;
  -- Apply the hypothesis `h_extract_sum` to each term in the sum.
  have h_extract_sum_apply : ∀ p : Fin (T + 1) → β, ∑ b : β, |((seed.filter (fun s => orbitHash powTrop h T s = p ∧ h (powTrop s (T + 1)) = b)).card : ℝ) / ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) - (1 / (Fintype.card β))| * ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) / seed.card ≤ 2 * ε * ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) / seed.card := by
    intro p
    by_cases hp : (seed.filter (fun s => orbitHash powTrop h T s = p)).Nonempty;
    · simpa only [ ← Finset.sum_div, ← Finset.sum_mul ] using div_le_div_of_nonneg_right ( mul_le_mul_of_nonneg_right ( h_extract_sum p hp ) ( Nat.cast_nonneg _ ) ) ( Nat.cast_nonneg _ );
    · simp_all +decide [ Finset.ext_iff ];
      simp_all +decide [ Finset.filter_eq_empty_iff.mpr hp ];
  -- Apply the hypothesis `h_extract_sum_apply` to each term in the sum.
  have h_extract_sum_apply_sum : ∑ p : Fin (T + 1) → β, ∑ b : β, |((seed.filter (fun s => orbitHash powTrop h T s = p ∧ h (powTrop s (T + 1)) = b)).card : ℝ) / ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) - (1 / (Fintype.card β))| * ((seed.filter (fun s => orbitHash powTrop h T s = p)).card : ℝ) / seed.card ≤ 2 * ε := by
    refine' le_trans ( Finset.sum_le_sum fun p _ => h_extract_sum_apply p ) _;
    rw [ ← Finset.sum_div _ _ _, ← Finset.mul_sum _ _ _ ];
    rw [ div_le_iff₀ ( Nat.cast_pos.mpr h_seed.card_pos ) ];
    rw [ ← Nat.cast_sum ];
    rw [ ← Finset.card_biUnion ];
    · exact mul_le_mul_of_nonneg_left ( mod_cast Finset.card_le_card ( Finset.biUnion_subset.mpr fun _ _ => Finset.filter_subset _ _ ) ) ( mul_nonneg zero_le_two hε );
    · exact fun x _ y _ hxy => Finset.disjoint_left.mpr fun s hsx hsy => hxy <| by aesop;
  simp +zetaDelta at *;
  rw [ h_fubini ];
  refine' le_trans ( mul_le_mul_of_nonneg_left ( Finset.sum_le_sum fun p _ => h_triangle p ) ( by norm_num ) ) _;
  rw [ Finset.sum_add_distrib ] ; linarith

/-! ## §5. Main Theorem -/

/-
**Tropical Orbit PRG Theorem.**
    If conditional extraction holds at each step with error ε,
    then the full orbit hash is `(T+1)*ε`-close to uniform.

    The proof uses induction: the base case follows from condExtract at step 0,
    and the inductive step applies the one-step chain rule.
-/
theorem tropical_orbit_prg
    {S M β : Type*} [Fintype S] [Fintype β] [DecidableEq S] [DecidableEq β]
    [DecidableEq M] [Nonempty β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β)
    (T : ℕ) (ε : ℝ) (hε : 0 ≤ ε)
    (h_extract : ∀ i, i ≤ T → condExtract seed powTrop h i ε)
    (h_seed : seed.Nonempty) :
    statDist (orbitHashDist seed powTrop h T)
      (uniformDist (Fin (T + 1) → β)) ≤ (T + 1 : ℝ) * ε := by
  convert error_accumulation _ ε hε _ _ T using 1;
  rotate_left;
  use fun n => if n ≤ T then statDist ( orbitHashDist seed powTrop h n ) ( uniformDist ( Fin ( n + 1 ) → β ) ) else 0;
  · convert h_extract 0 bot_le ( fun _ => Classical.arbitrary β ) _ using 1;
    · unfold orbitHashDist;
      unfold pushfwdDist orbitHash prefixFiber; simp +decide [ Finset.sum_ite ] ;
      unfold statDist uniformDist; simp +decide [ funext_iff, Fin.forall_fin_one ] ;
      refine' Finset.sum_bij ( fun x _ => x 0 ) _ _ _ _ <;> simp +decide;
      · exact fun a₁ a₂ h => funext fun i => by fin_cases i; exact h;
      · exact fun b => ⟨ fun _ => b, rfl ⟩;
    · exact h_seed.mono fun x hx => Finset.mem_filter.mpr ⟨ hx, by simp +decide ⟩;
  · intro n
    by_cases hn : n ≤ T;
    · split_ifs;
      · apply orbit_extension_statDist;
        · exact hε;
        · exact statDist_nonneg _ _;
        · exact h_seed;
        · rfl;
        · exact h_extract _ ‹_›;
      · exact add_nonneg ( statDist_nonneg _ _ ) hε;
    · split_ifs <;> linarith;
  · simp +decide

end OrbitPRG