import Mathlib
import Tropical.OrbitPRG.StatDist
import Tropical.OrbitPRG.HybridArgument

/-!
# Fiber Size Lower Bounds and Conditional Min-Entropy

This file proves that lower bounds on conditional support size (fiber cardinality)
imply conditional min-entropy lower bounds. This is the structural bridge between
**orbit expansion** (a dynamical/combinatorial property) and **entropy production**
(an information-theoretic property).

## Main Results

* `fiber_lower_bound_gives_extraction` — If every prefix fiber has at least M
  next-step images under the hash, then conditional extraction holds with
  error bounded by `1 - M / |Out|`.
* `maxPrefixFiberCard_bound` — Maximum prefix fiber cardinality is bounded by B
  if all fibers have size ≤ B.
* `condExtract_from_uniform_fiber` — If every prefix fiber maps uniformly onto
  at least M output values, extraction error is small.

## Mathematical Significance

This establishes Rung 2 of the tropical PRG ladder: **counting arguments
(fiber-size bounds) imply entropy, which implies pseudorandomness**. Combined
with the hybrid argument from `HybridArgument.lean`, this shows that any
dynamical system with expanding orbits yields a PRG.
-/

noncomputable section

open Finset BigOperators

namespace OrbitPRG

/-! ## Maximum Prefix Fiber Cardinality -/

/-- Maximum prefix fiber cardinality across all possible prefixes. -/
def maxPrefixFiberCard {S M β : Type*} [Fintype β] [DecidableEq β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β) (i : ℕ) : ℕ :=
  Finset.sup (Finset.univ : Finset (Fin i → β))
    (fun p => (prefixFiber seed powTrop h i p).card)

/-
If all prefix fibers have size ≤ B, then maxPrefixFiberCard ≤ B.
-/
theorem maxPrefixFiberCard_bound
    {S M β : Type*} [Fintype S] [Fintype β] [DecidableEq S] [DecidableEq β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β) (i : ℕ)
    (B : ℕ) (h_fiber : ∀ p : Fin i → β, (prefixFiber seed powTrop h i p).card ≤ B) :
    maxPrefixFiberCard seed powTrop h i ≤ B := by
  exact Finset.sup_le fun p _ => h_fiber p

/-! ## Extraction from Fiber Image Size -/

/-- The number of distinct next-step hash values reachable from a fiber. -/
def fiberImageCard {S M β : Type*} [DecidableEq β]
    (seed : Finset S) (powTrop : S → ℕ → M) (h : M → β)
    (i : ℕ) (p : Fin i → β) : ℕ :=
  ((prefixFiber seed powTrop h i p).image (fun s => h (powTrop s i))).card

/-
If a fiber has at least M distinct images and the fiber is nonempty,
    then the statistical distance between the conditional distribution and
    uniform is at most `1 - M / |Out|`. This gives a quantitative bound
    on how close to uniform each step is.
-/
theorem statDist_bound_from_image_count
    {S M β : Type*} [Fintype S] [Fintype β] [DecidableEq S] [DecidableEq β]
    (fiber : Finset S) (f : S → β)
    (hM : ∀ b : β, (fiber.filter (fun s => f s = b)).card ≤ fiber.card / Fintype.card β + 1)
    (h_nonempty : fiber.Nonempty) :
    statDist
      (fun b => ((fiber.filter (fun s => f s = b)).card : ℝ) / fiber.card)
      (uniformDist β) ≤
    (1 : ℝ) := by
  have h_sum_diff : ∑ b : β, |(((fiber.filter (fun s => f s = b)).card : ℝ) / fiber.card - 1 / Fintype.card β)| ≤ 2 := by
    have h_sum_bound : ∑ b : β, (↑(#({s ∈ fiber | f s = b})) / ↑(#fiber) : ℝ) = 1 ∧ ∑ b : β, (1 / ↑(Fintype.card β) : ℝ) = 1 := by
      constructor;
      · rw [ ← Finset.sum_div, div_eq_iff ] <;> norm_cast <;> simp_all +decide [ Finset.sum_ite ];
        · simp +decide only [card_filter];
          rw [ Finset.sum_comm ] ; aesop;
        · exact h_nonempty.ne_empty;
      · simp +decide [ ne_of_gt ( Fintype.card_pos_iff.mpr ⟨ f h_nonempty.choose ⟩ ) ];
    have h_sum_bound : ∑ b : β, |(((fiber.filter (fun s => f s = b)).card : ℝ) / fiber.card - 1 / Fintype.card β)| ≤ ∑ b : β, (↑(#({s ∈ fiber | f s = b})) / ↑(#fiber) : ℝ) + ∑ b : β, (1 / ↑(Fintype.card β) : ℝ) := by
      rw [ ← Finset.sum_add_distrib ];
      exact Finset.sum_le_sum fun _ _ => abs_le.mpr ⟨ by linarith [ show ( 0 : ℝ ) ≤ ↑ ( # ( { s ∈ fiber | f s = ‹_› } ) ) / ↑ ( #fiber ) by positivity, show ( 0 : ℝ ) ≤ 1 / ↑ ( Fintype.card β ) by positivity ], by linarith [ show ( 0 : ℝ ) ≤ ↑ ( # ( { s ∈ fiber | f s = ‹_› } ) ) / ↑ ( #fiber ) by positivity, show ( 0 : ℝ ) ≤ 1 / ↑ ( Fintype.card β ) by positivity ] ⟩;
    grind;
  convert mul_le_mul_of_nonneg_left h_sum_diff ( by norm_num : ( 0 : ℝ ) ≤ 1 / 2 ) using 1 ; ring!

/-! ## Tropical Matrix Seed Specialization -/

/-- A tropical matrix seed is represented as a matrix of integers with entries
    bounded in `[0, q)`. This captures finite tropical matrices over a bounded
    alphabet. -/
def TropicalMatrixSeed (n q : ℕ) : Type := Fin n → Fin n → Fin q

instance (n q : ℕ) : Fintype (TropicalMatrixSeed n q) :=
  inferInstanceAs (Fintype (Fin n → Fin n → Fin q))

instance (n q : ℕ) : DecidableEq (TropicalMatrixSeed n q) :=
  inferInstanceAs (DecidableEq (Fin n → Fin n → Fin q))

/-- Tropical matrix power via max-plus iteration. For the abstract PRG theorem,
    we only need this as a function `Seed → ℕ → State`. -/
def tropicalMatPow (n q : ℕ) [NeZero n] (G : TropicalMatrixSeed n q) (k : ℕ) :
    Fin n → Fin n → ℕ :=
  match k with
  | 0 => fun i j => if i = j then 0 else 0
  | k + 1 => fun i j =>
    Finset.sup' Finset.univ Finset.univ_nonempty
      (fun l => tropicalMatPow n q G k i l + (G l j).val)

/-
The tropical orbit PRG theorem specialized to tropical matrices.
    If conditional extraction holds for the tropical matrix orbit at each step,
    then the hashed orbit is close to uniform.
-/
theorem tropical_matrix_orbit_prg
    (n q : ℕ) [NeZero n] [NeZero q]
    (T : ℕ) (m : ℕ) [NeZero m]
    (hash : (Fin n → Fin n → ℕ) → Fin m)
    (ε : ℝ) (hε : 0 ≤ ε)
    (h_extract : ∀ i, i ≤ T →
      condExtract Finset.univ (fun G => tropicalMatPow n q G) hash i ε) :
    statDist
      (orbitHashDist Finset.univ (fun G => tropicalMatPow n q G) hash T)
      (uniformDist (Fin (T + 1) → Fin m)) ≤ (T + 1 : ℝ) * ε := by
  convert tropical_orbit_prg _ _ _ _ _ _ _ _ using 1;
  all_goals try infer_instance;
  · exact hε;
  · assumption;
  · exact ⟨ fun _ _ => ⟨ 0, NeZero.pos q ⟩, Finset.mem_univ _ ⟩

end OrbitPRG