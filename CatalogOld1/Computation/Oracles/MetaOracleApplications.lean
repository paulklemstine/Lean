import Mathlib

/-!
# Meta Oracle Applications: Experiments and Data Analysis

## Research Team Experiments

This file contains the experimental results from applying the Meta Oracle
framework to concrete mathematical problems. Each section represents a
different research team's experiments, with machine-verified results.

## Experiment Log

- **Experiment 1**: Oracle composition algebra on finite types
- **Experiment 2**: Information compression ratios
- **Experiment 3**: Convergence speed of oracle towers
- **Experiment 4**: The crystallization operator on ℤ/nℤ
- **Experiment 5**: Oracle fixed point counting
- **Experiment 6**: Meta oracle guidance — partition into fixed/interesting
-/

open Set Function Finset

noncomputable section

/-! ═══════════════════════════════════════════════════════════════════════
    EXPERIMENT 1: Oracle Algebra on Finite Types
    Team Alpha — Algebraic Structure

    DATA: Number of idempotent functions on Fin n
    n=1: 1, n=2: 3, n=3: 10 (OEIS A000248)

    The sequence 1, 3, 10, 41, 196, ... counts idempotent endomorphisms.
    Formula: a(n) = ∑_{k=0}^{n} C(n,k) · k^(n-k)
    ═══════════════════════════════════════════════════════════════════════ -/

/-- On Fin 2, there are exactly 3 idempotent functions (oracles). -/
theorem oracle_count_fin2 :
    (Finset.univ.filter (fun f : Fin 2 → Fin 2 => ∀ x, f (f x) = f x)).card = 3 := by
  decide

/-- On Fin 1, there is exactly 1 oracle (the identity). -/
theorem oracle_count_fin1 :
    (Finset.univ.filter (fun f : Fin 1 → Fin 1 => ∀ x, f (f x) = f x)).card = 1 := by
  decide

/-- On Fin 3, there are exactly 10 idempotent functions. -/
theorem oracle_count_fin3 :
    (Finset.univ.filter (fun f : Fin 3 → Fin 3 => ∀ x, f (f x) = f x)).card = 10 := by
  native_decide

/-! ═══════════════════════════════════════════════════════════════════════
    EXPERIMENT 2: Information Compression
    Team Beta — Compression Ratios

    DATA: The compression ratio of an idempotent on Fin n is |Im(f)|/n.
    Identity: ratio = 1.  Constant: ratio = 1/n.
    ═══════════════════════════════════════════════════════════════════════ -/

/-- The identity has full image. -/
theorem identity_image_full (n : ℕ) :
    (Finset.univ.image (id : Fin n → Fin n)).card = n := by
  simp [Finset.image_id, Finset.card_univ, Fintype.card_fin]

/-- A constant function has image size 1 (when n > 0). -/
theorem constant_image_size {n : ℕ} (_hn : 0 < n) (c : Fin n) :
    (Finset.univ.image (fun _ : Fin n => c)).card = 1 := by
  have : Nonempty (Fin n) := ⟨c⟩
  rw [Finset.image_const Finset.univ_nonempty, Finset.card_singleton]

/-! ═══════════════════════════════════════════════════════════════════════
    EXPERIMENT 3: Oracle Tower Convergence
    Team Gamma — Dynamical Systems

    KEY RESULT: Every oracle tower converges in at most 1 step.
    This is because O^n = O for all n ≥ 1 when O is idempotent.
    ═══════════════════════════════════════════════════════════════════════ -/

/-- Iterating an oracle and then applying it again is redundant. -/
theorem oracle_absorbs {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (f : X → X) (x : X) :
    O (O (f x)) = O (f x) := hO _

/-- Oracle iteration stabilizes: O^n = O for all n ≥ 1. -/
theorem oracle_iterate_const {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (n : ℕ) (hn : 1 ≤ n) : O^[n] = O := by
  induction n with
  | zero => omega
  | succ k ih =>
    rw [Function.iterate_succ']
    simp only [Function.comp_def]
    cases k with
    | zero => rfl
    | succ m =>
      rw [ih (by omega)]
      ext x; exact hO x

/-! ═══════════════════════════════════════════════════════════════════════
    EXPERIMENT 4: Crystallization on ℤ/nℤ
    Team Delta — Modular Arithmetic Oracles
    ═══════════════════════════════════════════════════════════════════════ -/

/-- The zero oracle on ZMod n: projects everything to 0. -/
def zeroOracle (n : ℕ) : ZMod n → ZMod n := fun _ => 0

/-- The zero oracle is idempotent. -/
theorem zeroOracle_idem (n : ℕ) : ∀ x, zeroOracle n (zeroOracle n x) = zeroOracle n x :=
  fun _ => rfl

/-- The squaring map on ZMod 2 is idempotent. -/
theorem zmod2_square_idem : ∀ x : ZMod 2, x * x * (x * x) = x * x := by decide

/-! ═══════════════════════════════════════════════════════════════════════
    EXPERIMENT 5: Oracle Fixed Point Counting
    Team Epsilon — Information Theory

    KEY INSIGHT: For an idempotent f, the number of fixed points equals
    the image size. This is because Im(f) = Fix(f) for idempotents.
    ═══════════════════════════════════════════════════════════════════════ -/

/-- An oracle on Fin n has image size at most n. -/
theorem oracle_image_bound {n : ℕ} (f : Fin n → Fin n) :
    (Finset.univ.image f).card ≤ n := by
  calc (Finset.univ.image f).card ≤ Finset.univ.card := Finset.card_image_le
    _ = n := by simp [Fintype.card_fin]

/-- For an idempotent f on Fin n, Im(f) ⊆ Fix(f). -/
theorem oracle_image_subset_fixed {n : ℕ} (f : Fin n → Fin n) (hf : ∀ x, f (f x) = f x) :
    ∀ y ∈ Finset.univ.image f, f y = y := by
  intro y hy
  simp [Finset.mem_image] at hy
  obtain ⟨x, _, rfl⟩ := hy
  exact hf x

/-- For an idempotent f on Fin n, Fix(f) ⊆ Im(f). -/
theorem oracle_fixed_subset_image {n : ℕ} (f : Fin n → Fin n) :
    ∀ y, f y = y → y ∈ Finset.univ.image f := by
  intro y hy
  exact Finset.mem_image.mpr ⟨y, Finset.mem_univ y, hy⟩

/-
PROBLEM
The number of fixed points of an idempotent equals its image size.

PROVIDED SOLUTION
The key insight is that for an idempotent f, Im(f) = Fix(f). Forward: if y = f(x), then f(y) = f(f(x)) = f(x) = y. Backward: if f(y) = y, then y = f(y) ∈ Im(f). So the filter set and the image set contain the same elements, hence have the same cardinality. Use Finset.card_bij or show that Finset.univ.filter (fun x => f x = x) = Finset.univ.image f as Finsets and use congr_arg card.
-/
theorem oracle_fixed_eq_image {n : ℕ} (f : Fin n → Fin n) (hf : ∀ x, f (f x) = f x) :
    (Finset.univ.filter (fun x => f x = x)).card = (Finset.univ.image f).card := by
  exact congr_arg _ ( by ext x; aesop )

/-! ═══════════════════════════════════════════════════════════════════════
    EXPERIMENT 6: Meta Oracle Guidance — Optimal Decompositions

    The meta oracle tells us: the interesting questions are the non-fixed
    points. For an oracle with k fixed points on Fin n, there are n - k
    interesting questions.
    ═══════════════════════════════════════════════════════════════════════ -/

/-- The set of "interesting questions" — the non-fixed points. -/
def interestingQueries {n : ℕ} (f : Fin n → Fin n) : Finset (Fin n) :=
  Finset.univ.filter (fun x => f x ≠ x)

/-
PROBLEM
Fixed points and interesting queries partition the universe.

PROVIDED SOLUTION
This follows from Finset.filter_card_add_filter_neg_card_eq_card (or the newer name card_filter_add_card_filter_not). The two sets partition univ: one filters by f x = x, the other (interestingQueries) filters by f x ≠ x. Together they cover all of Finset.univ which has card n. Use Finset.card_filter_add_card_filter_not or the deprecated Finset.filter_card_add_filter_neg_card_eq_card, applied to Finset.univ with predicate (fun x => f x = x).
-/
theorem partition_queries {n : ℕ} (f : Fin n → Fin n) :
    (Finset.univ.filter (fun x => f x = x)).card +
    (interestingQueries f).card = n := by
  -- The sum of the cardinalities of the fixed points and the interesting queries equals the cardinality of the universal set.
  have h_sum : (Finset.univ.filter (fun x => f x = x)).card + (Finset.univ.filter (fun x => f x ≠ x)).card = Finset.card (Finset.univ : Finset (Fin n)) := by
    rw [ Finset.card_filter_add_card_filter_not ];
  aesop

/-- For an oracle with k fixed points, there are n - k interesting questions. -/
theorem interesting_count {n : ℕ} (f : Fin n → Fin n) :
    (interestingQueries f).card =
    n - (Finset.univ.filter (fun x => f x = x)).card := by
  have h := partition_queries f
  omega

end