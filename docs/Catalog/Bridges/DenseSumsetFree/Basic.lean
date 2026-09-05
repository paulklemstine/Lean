/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Dense sets without large sumsets: basic notions

Fix `n` and consider the interval `[n] = {0, 1, …, n-1}`.  We are interested in
subsets `S ⊆ [n]` which are *dense* (`|S| ≥ δ n`) but which nevertheless contain
no sumset `A + B` with both summands large.

This file sets up the vocabulary:

* `AvoidsSumsets S k` — no sumset `A + B` with `|A|, |B| ≥ k` is contained in `S`;
* `subset_range_of_add_subset_range` — if `A + B ⊆ [n]` and `B ≠ ∅` then `A ⊆ [n]`
  (this is special to `ℕ`, where all elements are nonnegative);
* `card_add_ge` — the Cauchy–Davenport lower bound `|A| + |B| - 1 ≤ |A + B|`
  transported from `ℤ` to `ℕ`;
* `avoidsSumsets_of_card_lt` — the *baseline* (deterministic, linear) avoidance
  result: a set of size `< 2k - 1` avoids all `k`-sumsets;
* `DistinctSums A B` and `card_add_of_distinctSums` — the opposite extreme, where
  the `|A| · |B|` sums are pairwise different, so that `|A + B| = |A| · |B|`.

The main theorem of the development (in `Main.lean`) upgrades the baseline linear
threshold `k ≈ n/2` all the way down to a **polylogarithmic** threshold
`k = O((log n)^3)`, for sets of any fixed density `δ < 1`.
-/
import Mathlib

open Finset Pointwise

namespace DenseSumsetFree

/-- `S` avoids `k`-sumsets: no sumset `A + B` with both `|A| ≥ k` and `|B| ≥ k`
is contained in `S`. -/
def AvoidsSumsets (S : Finset ℕ) (k : ℕ) : Prop :=
  ∀ A B : Finset ℕ, k ≤ A.card → k ≤ B.card → ¬ A + B ⊆ S

/-- Avoidance is monotone in the threshold: if `S` avoids `k`-sumsets and
`k ≤ k'` then `S` avoids `k'`-sumsets. -/
lemma AvoidsSumsets.mono {S : Finset ℕ} {k k' : ℕ} (h : AvoidsSumsets S k)
    (hk : k ≤ k') : AvoidsSumsets S k' :=
  fun A B hA hB => h A B (hk.trans hA) (hk.trans hB)

/-- A sumset is the image of the product under addition. -/
lemma add_eq_image (A B : Finset ℕ) :
    A + B = (A ×ˢ B).image (fun p : ℕ × ℕ => p.1 + p.2) := rfl

/-- In `ℕ`, if `A + B` is contained in the initial interval `[n]` and `B` is
nonempty, then already `A ⊆ [n]`. -/
lemma subset_range_of_add_subset_range {A B : Finset ℕ} {n : ℕ} (hB : B.Nonempty)
    (h : A + B ⊆ Finset.range n) : A ⊆ Finset.range n := by
  obtain ⟨b, hb⟩ := hB
  intro a ha
  have hsum : a + b ∈ Finset.range n := h (Finset.add_mem_add ha hb)
  simp only [Finset.mem_range] at hsum ⊢
  omega

/-- In `ℕ`, if `A + B` is contained in the initial interval `[n]` and `A` is
nonempty, then already `B ⊆ [n]`. -/
lemma snd_subset_range_of_add_subset_range {A B : Finset ℕ} {n : ℕ} (hA : A.Nonempty)
    (h : A + B ⊆ Finset.range n) : B ⊆ Finset.range n := by
  obtain ⟨a, ha⟩ := hA
  intro b hb
  have hsum : a + b ∈ Finset.range n := h (Finset.add_mem_add ha hb)
  simp only [Finset.mem_range] at hsum ⊢
  omega

/-- **Cauchy–Davenport for `ℕ`.** For nonempty finite sets of naturals,
`|A| + |B| - 1 ≤ |A + B|`. -/
lemma card_add_ge {A B : Finset ℕ} (hA : A.Nonempty) (hB : B.Nonempty) :
    A.card + B.card - 1 ≤ (A + B).card := by
  classical
  set f : ℕ → ℤ := (Nat.cast : ℕ → ℤ) with hf
  have hinj : Function.Injective f := fun a b hab => by
    rw [hf] at hab; exact_mod_cast hab
  have himg : (A.image f) + (B.image f) = (A + B).image f :=
    (Finset.image_add (Nat.castRingHom ℤ)).symm
  have h := cauchy_davenport_of_isAddTorsionFree (s := A.image f) (t := B.image f)
    (hA.image f) (hB.image f)
  rwa [himg, Finset.card_image_of_injective _ hinj,
    Finset.card_image_of_injective _ hinj, Finset.card_image_of_injective _ hinj] at h

/-- **Baseline avoidance (deterministic, linear threshold).** Any set of size
less than `2k - 1` avoids all `k`-sumsets.  This is the elementary consequence of
the Cauchy–Davenport growth bound; the point of the rest of the development is
that random sets do enormously better. -/
theorem avoidsSumsets_of_card_lt {S : Finset ℕ} {k : ℕ} (hk : 1 ≤ k)
    (hS : S.card < 2 * k - 1) : AvoidsSumsets S k := by
  intro A B hA hB hsub
  have hAne : A.Nonempty := Finset.card_pos.1 (lt_of_lt_of_le hk hA)
  have hBne : B.Nonempty := Finset.card_pos.1 (lt_of_lt_of_le hk hB)
  have h1 := card_add_ge hAne hBne
  have h2 : (A + B).card ≤ S.card := Finset.card_le_card hsub
  omega

/-- `A` and `B` have *distinct sums* if the `|A| · |B|` sums `a + b` are pairwise
different. -/
def DistinctSums (A B : Finset ℕ) : Prop :=
  ∀ a₁ ∈ A, ∀ b₁ ∈ B, ∀ a₂ ∈ A, ∀ b₂ ∈ B, a₁ + b₁ = a₂ + b₂ → a₁ = a₂ ∧ b₁ = b₂

/-- If `A` and `B` have distinct sums then `|A + B| = |A| · |B|`. -/
lemma card_add_of_distinctSums {A B : Finset ℕ} (h : DistinctSums A B) :
    (A + B).card = A.card * B.card := by
  classical
  rw [add_eq_image, Finset.card_image_of_injOn, Finset.card_product]
  intro p hp q hq hpq
  simp only [Finset.coe_product, Set.mem_prod, Finset.mem_coe] at hp hq
  obtain ⟨h1, h2⟩ := h p.1 hp.1 p.2 hp.2 q.1 hq.1 q.2 hq.2 hpq
  exact Prod.ext h1 h2

/-- Distinct sums is inherited by subsets. -/
lemma DistinctSums.subset {A B A' B' : Finset ℕ} (h : DistinctSums A B)
    (hA : A' ⊆ A) (hB : B' ⊆ B) : DistinctSums A' B' :=
  fun a₁ ha₁ b₁ hb₁ a₂ ha₂ b₂ hb₂ he =>
    h a₁ (hA ha₁) b₁ (hB hb₁) a₂ (hA ha₂) b₂ (hB hb₂) he

/-- An elementary analytic bound used by the scale computations:
`(log x)² ≤ 16 √x` for `x ≥ 1`.  (Supplied here: the development used it but the
statement was missing from the repository.)  The proof applies `log t ≤ t - 1` to
`t = x^{1/4}`. -/
theorem log_sq_le_sqrt {x : ℝ} (hx : 1 ≤ x) : (Real.log x) ^ 2 ≤ 16 * Real.sqrt x := by
  have hx0 : (0:ℝ) ≤ x := by linarith
  have hs0 : 0 ≤ Real.sqrt x := Real.sqrt_nonneg x
  have hss : Real.sqrt (Real.sqrt x) ^ 2 = Real.sqrt x := Real.sq_sqrt hs0
  have hlogss : Real.log (Real.sqrt (Real.sqrt x)) = Real.log x / 4 := by
    rw [Real.log_sqrt hs0, Real.log_sqrt hx0]
    ring
  have hlt : Real.log (Real.sqrt (Real.sqrt x)) ≤ Real.sqrt (Real.sqrt x) - 1 := by
    have hpos : 0 < Real.sqrt (Real.sqrt x) :=
      Real.sqrt_pos.mpr (Real.sqrt_pos.mpr (by linarith))
    exact Real.log_le_sub_one_of_pos hpos
  have hlognn : 0 ≤ Real.log x := Real.log_nonneg hx
  have hkey : Real.log x ≤ 4 * Real.sqrt (Real.sqrt x) := by
    rw [hlogss] at hlt
    linarith [Real.sqrt_nonneg (Real.sqrt x)]
  nlinarith [Real.sqrt_nonneg (Real.sqrt x), hss]

end DenseSumsetFree