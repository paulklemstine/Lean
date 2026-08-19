/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality IX: the price *in bits* is submodular

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A.

`Cryptography.UniversalRedundancyLibrary` proved that the Shtarkov sum
`C(A) = ∑ₓ maxᵢ∈A P i x` is a monotone submodular set function on libraries of
models, and deduced the `(1 − 1/e)` guarantee for greedy library design.  That
is submodularity of the *multiplicative* redundancy factor.  The quantity a
compression engineer actually pays is its logarithm, `log₂ C(A)` bits, and
submodularity is not preserved by arbitrary transformations.

Here we show that it *is* preserved in this case, by proving the sharper
**multiplicative submodularity**

`C(A ∪ B) · C(A ∩ B) ≤ C(A) · C(B)`,

an inequality that follows from the additive one together with monotonicity via
the identity `(a − i)(b − i) ≥ 0`.  Taking logarithms gives submodularity of the
price in bits, which is exactly what makes greedy design of a *library of
decompressors* meaningful in bit terms.

The Critic's boundary case is also formalised: the bit-level inequality *fails*
for libraries with empty intersection (`price_not_submodular_of_disjoint`), so
the positivity hypothesis on `C(A ∩ B)` cannot be dropped — mathematically,
`log 0 = −∞` restores the inequality, but any implementation working with real
numbers must respect the guard.

## Main results

* `Library.shtarkov_mul_submodular` — `C(A ∪ B) · C(A ∩ B) ≤ C(A) · C(B)`;
* `Library.price_submodular` — the bit-level submodularity of the price;
* `Library.price_not_submodular_of_disjoint` — the boundary case;
* `Library.price_greedy_ge` — greedy library design is within
  `log₂ e/(e−1) < 0.67` bits of the optimal library of the same size;
* `Library.one_le_shtarkov` — a nonempty library of genuine sources has
  `C ≥ 1`;
* `Library.shtarkov_pair` — two-model libraries: `C = 1 + ‖p − q‖_TV`,
  connecting the library calculus to the total-variation diversity bound of
  `NumberTheory.UniversalRedundancyDiversity`;
* `Library.shtarkov_lt_insert_iff` — strictness of the marginal value.

## Application keywords

universal compression, Shtarkov sum, submodularity, total variation,
greedy approximation, price of universality
-/

import Cryptography.UniversalRedundancyLibrary

open Finset Real

namespace UniversalRedundancy

namespace Library

variable {X : Type*} [Fintype X] {ι : Type*} [DecidableEq ι] (P : ι → X → ℝ)

/-! ## Multiplicative submodularity -/

/-- **Multiplicative submodularity of the Shtarkov sum.**  The redundancy
*factors* satisfy `C(A ∪ B) · C(A ∩ B) ≤ C(A) · C(B)`; this is strictly stronger
than the additive form when the values exceed `1`, and it is precisely what
makes the price in bits submodular. -/
theorem shtarkov_mul_submodular (A B : Finset ι) :
    shtarkov P (A ∪ B) * shtarkov P (A ∩ B) ≤ shtarkov P A * shtarkov P B := by
  have hadd := shtarkov_submodular P A B
  have hiA : shtarkov P (A ∩ B) ≤ shtarkov P A :=
    shtarkov_mono P Finset.inter_subset_left
  have hiB : shtarkov P (A ∩ B) ≤ shtarkov P B :=
    shtarkov_mono P Finset.inter_subset_right
  have hi0 : 0 ≤ shtarkov P (A ∩ B) := shtarkov_nonneg P _
  nlinarith [mul_nonneg (sub_nonneg.2 hiA) (sub_nonneg.2 hiB)]

/-- **The price of universality is a submodular set function on model
libraries.**  In bits:
`price(A ∪ B) + price(A ∩ B) ≤ price(A) + price(B)`.
The hypothesis is that the common part `A ∩ B` of the two libraries is already
nontrivial (`C(A ∩ B) > 0`), which holds as soon as `A ∩ B` contains one genuine
source. -/
theorem price_submodular {A B : Finset ι} (hAB : 0 < shtarkov P (A ∩ B)) :
    logb 2 (shtarkov P (A ∪ B)) + logb 2 (shtarkov P (A ∩ B))
      ≤ logb 2 (shtarkov P A) + logb 2 (shtarkov P B) := by
  have hA : 0 < shtarkov P A :=
    lt_of_lt_of_le hAB (shtarkov_mono P Finset.inter_subset_left)
  have hB : 0 < shtarkov P B :=
    lt_of_lt_of_le hAB (shtarkov_mono P Finset.inter_subset_right)
  have hU : 0 < shtarkov P (A ∪ B) :=
    lt_of_lt_of_le hA (shtarkov_mono P Finset.subset_union_left)
  have hmul := shtarkov_mul_submodular P A B
  have := Real.logb_le_logb_of_le (b := 2) (by norm_num) (mul_pos hU hAB) hmul
  rwa [Real.logb_mul (ne_of_gt hU) (ne_of_gt hAB),
    Real.logb_mul (ne_of_gt hA) (ne_of_gt hB)] at this

/-! ## Libraries of genuine sources -/

section Sources

variable {hP0 : ∀ i, ∀ x, 0 ≤ P i x} {hP1 : ∀ i, ∑ x, P i x = 1}

omit [DecidableEq ι] in
include hP1 in
/-- A nonempty library of genuine probabilistic models has Shtarkov sum at
least `1`: universality never helps. -/
theorem one_le_shtarkov {A : Finset ι} (hA : A.Nonempty) : 1 ≤ shtarkov P A := by
  obtain ⟨i, hi⟩ := hA
  calc (1 : ℝ) = ∑ x, P i x := (hP1 i).symm
    _ ≤ shtarkov P A := Finset.sum_le_sum fun x _ => le_envelope P hi x

include hP1 in
/-- With genuine sources, submodularity in bits only needs the common part of
the two libraries to be nonempty. -/
theorem price_submodular_of_inter_nonempty {A B : Finset ι} (hAB : (A ∩ B).Nonempty) :
    logb 2 (shtarkov P (A ∪ B)) + logb 2 (shtarkov P (A ∩ B))
      ≤ logb 2 (shtarkov P A) + logb 2 (shtarkov P B) :=
  price_submodular P (lt_of_lt_of_le zero_lt_one (one_le_shtarkov (hP1 := hP1) P hAB))

include hP0 hP1 in
/-- **Two-model libraries.**  For a library consisting of two sources the price
functional is exactly `1 + ‖p − q‖_TV`, recovering the total-variation diversity
bound of `NumberTheory.UniversalRedundancyDiversity` as the two-element case of
the library calculus. -/
theorem shtarkov_pair (i j : ι) :
    shtarkov P {i, j} = 1 + totalVariation (P i) (P j) := by
  have henv : ∀ x, envelope P {i, j} x = max (P i x) (P j x) := by
    intro x
    rw [show ({i, j} : Finset ι) = insert i {j} from rfl, envelope_insert]
    congr 1
    rw [show ({j} : Finset ι) = insert j ∅ from rfl, envelope_insert]
    exact max_eq_left (by simpa using hP0 j x)
  calc shtarkov P {i, j} = ∑ x, max (P i x) (P j x) :=
        Finset.sum_congr rfl fun x _ => henv x
    _ = 1 + totalVariation (P i) (P j) :=
        sum_max_eq_one_add_totalVariation (hP1 i) (hP1 j)

end Sources

/-- **Greedy library design costs less than `0.67` bits over optimal.**  In bit
terms the `(1 − 1/e)` guarantee says the greedy library's price of universality
is at least `price(best library) + log₂(1 − 1/e)`, i.e. it falls short of the
optimal library by at most `log₂ e/(e−1) < 0.67` bits — for *every* candidate
pool of sources and every target size. -/
theorem price_greedy_ge [Fintype ι] [Nonempty ι]
    (hP1 : ∀ i, ∑ x, P i x = 1) {B : Finset ι} (hB : B.Nonempty) :
    logb 2 (shtarkov P B) + logb 2 (1 - Real.exp (-1))
      ≤ logb 2 (shtarkov P (greedySeq P B.card)) := by
  have hC : 1 ≤ shtarkov P B := one_le_shtarkov (hP1 := hP1) P hB
  have hCpos : 0 < shtarkov P B := lt_of_lt_of_le zero_lt_one hC
  have hfac : 0 < 1 - Real.exp (-1) := by
    have h1 : Real.exp (-1) < 1 := by
      rw [Real.exp_lt_one_iff]; norm_num
    linarith
  have hmain := greedySeq_one_sub_inv_exp_le P hB
  have := Real.logb_le_logb_of_le (b := 2) (by norm_num) (mul_pos hfac hCpos) hmain
  rwa [Real.logb_mul (ne_of_gt hfac) (ne_of_gt hCpos), add_comm] at this

/-! ## Strictness of the marginal value -/

/-- **A model earns its place iff it beats the incumbent envelope.**  Inserting
`j` strictly raises the price of the library exactly when `j` assigns a strictly
larger likelihood than the whole library `A` to some message. -/
theorem shtarkov_lt_insert_iff (j : ι) (A : Finset ι) :
    shtarkov P A < shtarkov P (insert j A) ↔ ∃ x, envelope P A x < P j x := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    have : shtarkov P (insert j A) - shtarkov P A = 0 := by
      rw [shtarkov_insert_sub]
      exact Finset.sum_eq_zero fun x _ => max_eq_right (by linarith [hcon x])
    linarith
  · rintro ⟨x₀, hx₀⟩
    have hpos : 0 < ∑ x, max (P j x - envelope P A x) 0 := by
      refine Finset.sum_pos' (fun x _ => le_max_right _ _) ⟨x₀, Finset.mem_univ x₀, ?_⟩
      exact lt_of_lt_of_le (by linarith) (le_max_left (P j x₀ - envelope P A x₀) 0)
    have := shtarkov_insert_sub P j A
    linarith

/-! ## The boundary case: bit submodularity fails on disjoint libraries

Two point masses on distinct messages form libraries `A`, `B` with
`C(A) = C(B) = 1` (price `0` bits) but `C(A ∪ B) = 2` (price `1` bit), while the
empty intersection contributes `C(∅) = 0`.  Mathematically the missing term is
`log 0 = −∞`; in the real-valued formalisation it is a genuine counterexample,
so `price_submodular` really does need its positivity guard. -/

/-- The two point masses on `Bool`. -/
def pointMasses : Bool → Bool → ℝ := fun i x => if x = i then 1 else 0

lemma shtarkov_pointMasses_singleton (i : Bool) : shtarkov pointMasses {i} = 1 := by
  have h : ∀ x : Bool, envelope pointMasses {i} x = if x = i then 1 else 0 := by
    intro x
    rw [show ({i} : Finset Bool) = insert i ∅ from rfl, envelope_insert]
    simp only [envelope_empty, pointMasses]
    split <;> simp
  rw [shtarkov, Finset.sum_congr rfl fun x _ => h x]
  cases i <;> simp

lemma shtarkov_pointMasses_univ : shtarkov pointMasses {false, true} = 2 := by
  have h : ∀ x : Bool, envelope pointMasses {false, true} x = 1 := by
    intro x
    rw [show ({false, true} : Finset Bool) = insert false {true} from rfl, envelope_insert,
      show ({true} : Finset Bool) = insert true ∅ from rfl, envelope_insert]
    cases x <;> simp [pointMasses]
  rw [shtarkov, Finset.sum_congr rfl fun x _ => h x]
  simp

/-- **The guard in `price_submodular` is necessary.**  For the two point masses
on `Bool` the bit-level submodularity inequality fails for the disjoint
libraries `{false}` and `{true}`. -/
theorem price_not_submodular_of_disjoint :
    ¬ (logb 2 (shtarkov pointMasses ({false} ∪ {true}))
        + logb 2 (shtarkov pointMasses ({false} ∩ {true}))
      ≤ logb 2 (shtarkov pointMasses {false}) + logb 2 (shtarkov pointMasses {true})) := by
  have hunion : ({false} ∪ {true} : Finset Bool) = {false, true} := rfl
  have hinter : ({false} ∩ {true} : Finset Bool) = ∅ := by decide
  rw [hunion, hinter, shtarkov_empty, shtarkov_pointMasses_univ,
    shtarkov_pointMasses_singleton, shtarkov_pointMasses_singleton]
  have h2 : logb 2 (2 : ℝ) = 1 := Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)
  rw [h2, Real.logb_one, Real.logb_zero]
  norm_num

end Library

end UniversalRedundancy