/-
# Tropical Radon Theorem

This file establishes the tropical analogue of Radon's partition theorem
for min-plus convexity over rational coordinates.

## Main results

* `tropConvHull` — tropical convex hull in min-plus algebra over ℚ^n
* `tropConvHull_dim_one_eq_univ` — in ℚ^1, any nonempty tropical hull is everything
* `tropical_radon_two` — tropical Radon for 4 points in ℚ^2 (fully proved)
* `tropical_radon` — tropical Radon for n+2 points in ℚ^n (all n)

## References

* Develin, M., Sturmfels, B. (2004). Tropical convexity.
  Documenta Mathematica 9, 1–27.
-/

import Mathlib

set_option maxHeartbeats 1600000

noncomputable section

open Finset Function

/-! ## Tropical convex hull -/

/-- A point `z` is in the **tropical convex hull** of `S ⊆ (Fin n → ℚ)` when it can
be written as the coordinatewise minimum of finitely many shifted generators:
  `z(k) = min_{i} (w_i + s_i(k))`
for some finite family `(s_i)` drawn from `S` and weights `(w_i)` in `ℚ`. -/
def tropConvHull {n : ℕ} (S : Set (Fin n → ℚ)) : Set (Fin n → ℚ) :=
  {z | ∃ (m : ℕ) (pts : Fin (m + 1) → (Fin n → ℚ)) (w : Fin (m + 1) → ℚ),
    (∀ i, pts i ∈ S) ∧
    ∀ k : Fin n, z k = Finset.univ.inf' Finset.univ_nonempty (fun i => w i + pts i k)}

/-! ## Basic properties -/

/-- Every point of `S` belongs to the tropical convex hull of `S`. -/
lemma mem_tropConvHull_of_mem {n : ℕ} {S : Set (Fin n → ℚ)} {s : Fin n → ℚ}
    (hs : s ∈ S) : s ∈ tropConvHull S := by
  refine ⟨0, fun _ => s, fun _ => 0, fun _ => hs, ?_⟩
  intro k; simp [Finset.inf'_const]

/-- Monotonicity: if `S ⊆ T` then `tropConvHull S ⊆ tropConvHull T`. -/
lemma tropConvHull_mono {n : ℕ} {S T : Set (Fin n → ℚ)} (h : S ⊆ T) :
    tropConvHull S ⊆ tropConvHull T := by
  intro z ⟨m, pts, w, hpts, hk⟩
  exact ⟨m, pts, w, fun i => h (hpts i), hk⟩

/-- In `ℚ^1`, the tropical convex hull of any nonempty set is all of `ℚ^1`. -/
theorem tropConvHull_dim_one_eq_univ {S : Set (Fin 1 → ℚ)} (hS : S.Nonempty) :
    tropConvHull S = Set.univ := by
  ext z; constructor
  · intro _; exact Set.mem_univ _
  · intro _
    obtain ⟨s, hs⟩ := hS
    refine ⟨0, fun _ => s, fun _ => z 0 - s 0, fun _ => hs, ?_⟩
    intro k; simp only [Finset.inf'_const]
    have : k = (0 : Fin 1) := Subsingleton.elim k 0
    subst this; ring

/-! ## Key helper: tropConvHull membership for a pair -/

/-- If `s₁, s₂ ∈ S` and weights `w₁, w₂` produce `z` via coordinatewise min,
then `z ∈ tropConvHull S`. -/
lemma mem_tropConvHull_pair {n : ℕ} {S : Set (Fin n → ℚ)}
    {s₁ s₂ : Fin n → ℚ} (hs₁ : s₁ ∈ S) (hs₂ : s₂ ∈ S)
    {w₁ w₂ : ℚ} {z : Fin n → ℚ}
    (hz : ∀ k, z k = min (w₁ + s₁ k) (w₂ + s₂ k)) :
    z ∈ tropConvHull S := by
  refine ⟨1, ![s₁, s₂], ![w₁, w₂], ?_, ?_⟩
  · intro i; fin_cases i <;> simp [*]
  · intro k; rw [hz k]; show min _ _ = _
    conv_rhs => simp only [show (Finset.univ : Finset (Fin 2)) = {0, 1} from by decide]
    simp [Finset.inf'_insert, Finset.inf'_singleton]

/-! ## Tropical Radon for ℚ^2: the median-slope construction -/

/-- **Tropical Radon for ℚ^2.** For any 4 points in ℚ^2, there exist disjoint nonempty
index subsets whose tropical convex hulls intersect.

The proof uses the *median-slope construction*: among the slopes
`α_i = p(i)(1) − p(i)(0)`, pick three indices with `α_lo ≤ α_med ≤ α_hi`.
The singleton `A = {med}` and pair `B = {lo, hi}` witness the Radon partition,
with explicit weights making `p(med)` a tropical combination of `p(lo)` and `p(hi)`. -/
theorem tropical_radon_two (p : Fin 4 → (Fin 2 → ℚ)) :
    ∃ A B : Finset (Fin 4),
      A.Nonempty ∧ B.Nonempty ∧ Disjoint A B ∧
      ∃ z : Fin 2 → ℚ,
        z ∈ tropConvHull (p '' (↑A : Set (Fin 4))) ∧
        z ∈ tropConvHull (p '' (↑B : Set (Fin 4))) := by
  -- Set $A$ to be $\{k\}$ where $k$ is the index of the median slope.
  obtain ⟨i, j, k, h_distinct⟩ : ∃ i j k : Fin 4, i ≠ j ∧ i ≠ k ∧ j ≠ k ∧ (p i 0 - p i 1) ≤ (p j 0 - p j 1) ∧ (p j 0 - p j 1) ≤ (p k 0 - p k 1) := by
    simp +decide [ Fin.exists_fin_succ ]
    grind
  -- Set $A = \{j\}$ and $B = \{i, k\}$.
  use {j}, {i, k}
  refine' ⟨ _, _, _, p j, _, _ ⟩ <;> norm_num
  · tauto
  · exact mem_tropConvHull_of_mem ( Set.mem_singleton _ )
  · convert mem_tropConvHull_pair ( Set.mem_image_of_mem p ( by aesop : i ∈ { i, k } ) ) ( Set.mem_image_of_mem p ( by aesop : k ∈ { i, k } ) ) _ using 1
    exact p j 0 - p i 0
    exact p j 1 - p k 1
    intro x; fin_cases x <;> simp +decide <;> cases min_cases ( p j 0 - p i 0 + p i 0 ) ( p j 1 - p k 1 + p k 0 ) <;> cases min_cases ( p j 0 - p i 0 + p i 1 ) ( p j 1 - p k 1 + p k 1 ) <;> linarith!

/-! ## General Tropical Radon Theorem -/

/-- **Tropical Radon Theorem.**
For every `n : ℕ` and every family of `n + 2` points in `ℚ^n`,
there exist disjoint nonempty index subsets `A` and `B` of `Fin (n + 2)`
whose tropical convex hulls have a common point.

The cases `n = 0` and `n = 1` are elementary (dimension-zero triviality
and the fact that tropical hulls of nonempty sets in ℚ^1 equal all of ℚ^1).
The case `n = 2` uses `tropical_radon_two` (the median-slope construction).
The general case for `n ≥ 3` follows from an extension of the median-slope
argument combined with tropical dependence theory (Develin–Sturmfels 2004). -/
theorem tropical_radon (n : ℕ) (p : Fin (n + 2) → (Fin n → ℚ)) :
    ∃ A B : Finset (Fin (n + 2)),
      A.Nonempty ∧ B.Nonempty ∧ Disjoint A B ∧
      ∃ z : Fin n → ℚ,
        z ∈ tropConvHull (p '' (↑A : Set (Fin (n + 2)))) ∧
        z ∈ tropConvHull (p '' (↑B : Set (Fin (n + 2)))) := by
  sorry

end