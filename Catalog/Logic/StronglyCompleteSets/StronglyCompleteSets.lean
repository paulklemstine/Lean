import Mathlib

/-!
# Strongly complete sets of natural numbers

This file formalizes the basic deletion-stability framework used in the study of
complete and strongly complete sets.  A set is complete when every sufficiently
large natural number is a sum of distinct members of the set.  The main result
below characterizes strong completeness using only tails of the set.  This is a
useful reduction: arbitrary finite deletions may be replaced by deletion of an
initial interval.
-/

namespace StronglyCompleteSets

/-- `n` is representable as a sum of distinct elements of `A`. -/
def IsSubsetSum (A : Set ℕ) (n : ℕ) : Prop :=
  ∃ s : Finset ℕ, (↑s : Set ℕ) ⊆ A ∧ ∑ a ∈ s, a = n

/-- Every sufficiently large natural number is a sum of distinct elements of `A`. -/
def Complete (A : Set ℕ) : Prop :=
  ∃ N : ℕ, ∀ n ≥ N, IsSubsetSum A n

/-- Completeness survives deletion of an arbitrary finite set. -/
def StronglyComplete (A : Set ℕ) : Prop :=
  ∀ F : Set ℕ, F.Finite → Complete (A \ F)

lemma isSubsetSum_mono {A B : Set ℕ} (hAB : A ⊆ B) {n : ℕ}
    (h : IsSubsetSum A n) : IsSubsetSum B n := by
  exact ⟨ h.choose, Set.Subset.trans h.choose_spec.1 hAB, h.choose_spec.2 ⟩

lemma complete_mono {A B : Set ℕ} (hAB : A ⊆ B) (hA : Complete A) : Complete B := by
  exact ⟨ hA.choose, fun n hn => isSubsetSum_mono hAB ( hA.choose_spec n hn ) ⟩

/-
Strong completeness is upward-closed under inclusion.
-/
theorem stronglyComplete_mono {A B : Set ℕ} (hAB : A ⊆ B)
    (hA : StronglyComplete A) : StronglyComplete B := by
  intro F hF
  have h_subset : A \ F ⊆ B \ F := by
    exact Set.diff_subset_diff hAB Set.Subset.rfl
  apply complete_mono h_subset (hA F hF)

/-
Deleting finitely many elements preserves strong completeness.
-/
theorem stronglyComplete_diff_finite {A F : Set ℕ} (hA : StronglyComplete A)
    (hF : F.Finite) : StronglyComplete (A \ F) := by
  intro G hG;
  convert hA ( F ∪ G ) ( hF.union hG ) using 1 ; ext ; aesop

/-
Adding or removing finitely many elements does not affect strong completeness.
-/
theorem stronglyComplete_iff_of_symmDiff_finite {A B : Set ℕ}
    (h : ((A \ B) ∪ (B \ A)).Finite) : StronglyComplete A ↔ StronglyComplete B := by
  refine' ⟨ fun hA => _, fun hB => _ ⟩;
  · convert stronglyComplete_mono ?_ ( stronglyComplete_diff_finite hA ?_ );
    rotate_left;
    exacts [ A \ B, h.subset fun x hx => by simp_all +decide, fun x hx => by simp_all +decide ];
  · convert stronglyComplete_mono ?_ ( stronglyComplete_diff_finite hB ?_ );
    rotate_left;
    exacts [ B \ A, h.subset fun x hx => by by_cases hx' : x ∈ A <;> simp_all +decide [ Set.diff_eq ], fun x hx => by by_cases hx' : x ∈ A <;> simp_all +decide [ Set.diff_eq ] ]

/-
The tails-only characterization of strong completeness.
-/
theorem stronglyComplete_iff_complete_tails (A : Set ℕ) :
    StronglyComplete A ↔ ∀ k : ℕ, Complete (A ∩ Set.Ici k) := by
  constructor;
  · intro h k;
    convert h ( Set.Iio k ) ( Set.finite_Iio k ) using 1;
    grind;
  · intro h F hF
    obtain ⟨k, hk⟩ : ∃ k : ℕ, ∀ x ∈ F, x < k := by
      exact ⟨ hF.bddAbove.some + 1, fun x hx => Nat.lt_succ_of_le ( hF.bddAbove.choose_spec hx ) ⟩;
    exact h k |> fun ⟨ N, hN ⟩ => ⟨ N, fun n hn => by rcases hN n hn with ⟨ s, hs₁, hs₂ ⟩ ; exact ⟨ s, fun x hx => ⟨ hs₁ hx |>.1, fun hx' => not_lt_of_ge ( hs₁ hx |>.2 ) ( hk x hx' ) ⟩, hs₂ ⟩ ⟩

/-
It is enough that all sufficiently late tails are complete.
-/
theorem stronglyComplete_iff_eventually_complete_tails (A : Set ℕ) :
    StronglyComplete A ↔ ∃ k₀ : ℕ, ∀ k ≥ k₀, Complete (A ∩ Set.Ici k) := by
  constructor <;> intro h1;
  · exact ⟨ 0, fun k hk => stronglyComplete_iff_complete_tails A |>.1 h1 k ⟩;
  · convert stronglyComplete_iff_complete_tails A |>.2 _;
    intro k
    obtain ⟨k₀, hk₀⟩ := h1
    have h_tail : A ∩ Set.Ici (max k k₀) ⊆ A ∩ Set.Ici k := by
      exact Set.inter_subset_inter_right _ ( Set.Ici_subset_Ici.mpr ( le_max_left _ _ ) );
    exact complete_mono h_tail ( hk₀ _ ( le_max_right _ _ ) )

/-
A cofinite-subset formulation of strong completeness.
-/
theorem stronglyComplete_iff_cofinite_subsets (A : Set ℕ) :
    StronglyComplete A ↔
      ∀ B : Set ℕ, B ⊆ A → (A \ B).Finite → Complete B := by
  refine' ⟨ fun h B hB hB' => _, fun h F hF => _ ⟩;
  · convert h ( A \ B ) hB' using 1 ; aesop;
  · contrapose! h;
    exact ⟨ A \ F, by aesop_cat, by simpa using hF.subset fun x hx => by aesop_cat, h ⟩

/-
Every natural-number tail is complete: represent `n ≥ k` by the singleton `{n}`.
-/
theorem complete_Ici (k : ℕ) : Complete (Set.Ici k) := by
  exact ⟨ k, fun n hn => ⟨ { n }, by aesop ⟩ ⟩

/-
Any set containing a tail of the natural numbers is strongly complete.
-/
theorem stronglyComplete_of_Ici_subset {A : Set ℕ} (k : ℕ)
    (h : Set.Ici k ⊆ A) : StronglyComplete A := by
  by_contra;
  exact this ( stronglyComplete_iff_complete_tails A |>.2 fun j => complete_mono ( show A ∩ Set.Ici j ⊇ Set.Ici ( Max.max k j ) from fun x hx => ⟨ h <| by aesop, by aesop ⟩ ) ( complete_Ici <| Max.max k j ) )

/-
In particular, every cofinite set of natural numbers is strongly complete.
-/
theorem stronglyComplete_of_compl_finite {A : Set ℕ} (hA : Aᶜ.Finite) :
    StronglyComplete A := by
  convert stronglyComplete_of_Ici_subset ( hA.bddAbove.choose + 1 ) _;
  exact fun x hx => Classical.not_not.1 fun hx' => not_lt_of_ge ( hA.bddAbove.choose_spec hx' ) ( Nat.lt_of_succ_le hx )

/-
The full set of natural numbers is strongly complete.
-/
theorem stronglyComplete_univ : StronglyComplete (Set.univ : Set ℕ) := by
  exact stronglyComplete_of_Ici_subset 0 ( by simp +decide )

end StronglyCompleteSets