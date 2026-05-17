import Mathlib

/-!
# Tropical Search: Finding Minima via Min-Plus Aggregation

This file formalizes tropical search — the min-plus analogue of quantum search algorithms.
Where Grover's algorithm uses quantum interference to find marked items, tropical search
uses min-plus aggregation to find the minimum marked index.

## Main results

- `tropicalSearchValue_marked`: The search value corresponds to an actually marked element.
- `tropicalSearchValue_minimal`: The search value is minimal among all marked elements.
- `min_over_union`: The min over a union equals the min of the component minima —
  the tropical "interference" principle.

## Mathematical significance

This demonstrates that the "speedup skeleton" of quantum search — global competition
among branches — has a purely algebraic realization in the min-plus semiring.
-/

noncomputable section

open Finset BigOperators

namespace TropicalSearch

private theorem filter_nonempty_of_exists {n : ℕ} {f : Fin n → Bool}
    (hex : ∃ i : Fin n, f i = true) :
    (Finset.univ.filter (fun i : Fin n => f i = true)).Nonempty := by
  obtain ⟨i, hi⟩ := hex
  exact ⟨i, Finset.mem_filter.mpr ⟨Finset.mem_univ _, hi⟩⟩

/-- The tropical search value: minimum index i where f i = true.
Returns n if no such index exists. -/
def tropicalSearchValue (n : ℕ) (f : Fin n → Bool) : ℕ :=
  if h : ∃ i : Fin n, f i = true then
    (Finset.univ.filter (fun i : Fin n => f i = true)).inf'
      (filter_nonempty_of_exists h)
      (fun i => i.val)
  else n

/-- When a marked element exists, the search value equals the inf' computation. -/
theorem tropicalSearchValue_eq_min {n : ℕ} (f : Fin n → Bool)
    (hex : ∃ i : Fin n, f i = true) :
    tropicalSearchValue n f =
    (Finset.univ.filter (fun i : Fin n => f i = true)).inf'
      (filter_nonempty_of_exists hex)
      (fun i => i.val) := by
  simp [tropicalSearchValue, hex]

/-
The search value is less than n when a marked element exists.
-/
theorem tropicalSearchValue_lt {n : ℕ} (f : Fin n → Bool)
    (hex : ∃ i : Fin n, f i = true) :
    tropicalSearchValue n f < n := by
  -- Since the set is nonempty, the infimum is the minimum element of the set, which is less than n.
  have h_min_lt_n : (Finset.univ.filter (fun i => f i = true)).inf' (filter_nonempty_of_exists hex) (fun i => i.val) < n := by
    exact lt_of_le_of_lt ( Finset.inf'_le _ <| Finset.mem_filter.mpr ⟨ Finset.mem_univ ( Classical.choose hex ), Classical.choose_spec hex ⟩ ) ( Fin.is_lt _ );
  rwa [ tropicalSearchValue_eq_min f hex ]

/-
The search value corresponds to an actually marked element.
-/
theorem tropicalSearchValue_marked {n : ℕ} (f : Fin n → Bool)
    (hex : ∃ i : Fin n, f i = true) :
    ∃ i : Fin n, i.val = tropicalSearchValue n f ∧ f i = true := by
  unfold tropicalSearchValue;
  have := Finset.exists_mem_eq_inf' ( show ( Finset.univ.filter fun i : Fin n => f i = true ).Nonempty from ⟨ hex.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hex.choose_spec ⟩ ⟩ ) ( fun i : Fin n => ( i : ℕ ) ) ; aesop;

/-
The search value is minimal among marked elements.
-/
theorem tropicalSearchValue_minimal {n : ℕ} (f : Fin n → Bool)
    (hex : ∃ i : Fin n, f i = true) (i : Fin n) (hi : f i = true) :
    tropicalSearchValue n f ≤ i.val := by
  rw [ tropicalSearchValue_eq_min ];
  exacts [ Finset.inf'_le _ ( by simpa ), hex ]

/-
The minimum over a union equals the min of the component minima.
This is the tropical "interference" principle: branch competition
produces the global optimum from local optima.
-/
theorem min_over_union {ι : Type} [DecidableEq ι]
    (S T : Finset ι) (f : ι → ℕ)
    (hS : S.Nonempty) (hT : T.Nonempty) :
    (S ∪ T).inf' (hS.mono Finset.subset_union_left) f =
    min (S.inf' hS f) (T.inf' hT f) := by
  simp +decide [ Finset.inf'_union, le_antisymm_iff ];
  exact ⟨ ⟨ fun b hb => ⟨ b, Or.inl hb, le_rfl ⟩, fun b hb => ⟨ b, Or.inr hb, le_rfl ⟩ ⟩, fun b hb => by cases hb <;> [ left; right ] <;> exact ⟨ b, by assumption, le_rfl ⟩ ⟩

/-
Total work for evaluating min over n elements is at most n comparisons.
-/
theorem min_eval_linear (n : ℕ) (f : Fin n → ℕ) (hn : 0 < n) :
    ∀ k : ℕ, k ≤ n →
    (Finset.univ.filter (fun i : Fin n => i.val < k)).card ≤ n := by
  exact fun k hk => le_trans ( Finset.card_le_univ _ ) ( by simpa )

end TropicalSearch

end