/-
# Frankl's Conjecture: Small Universe and Small Family Cases

This file proves Frankl's conjecture for:
- Families over universes of size ≤ 3
- Families with few members

The standard formulation requires the family to contain at least one
nonempty set (otherwise {∅} is a trivial counterexample).
-/
import Mathlib
import Speculative.Frankl.Defs

open Finset

/-! ## Helper: Frankl for families where every set contains a fixed element -/

/-
If every set in a nonempty family contains element x, then x is abundant.
-/
theorem frankl_of_all_contain {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (x : α)
    (hne : F.Nonempty)
    (h : ∀ s ∈ F, x ∈ s) :
    FranklProperty F := by
  exact ⟨ x, by rw [ abundance_eq_sum ] ; rw [ Finset.sum_congr rfl fun s hs => if_pos ( h s hs ) ] ; simp +decide [ hne ] ⟩

/-! ## Frankl's conjecture for Fin n, n ≤ 3

Note: We include the hypothesis that the family contains a nonempty member,
since {∅} is a trivial counterexample to the unguarded statement. -/

/-
Frankl's conjecture for families over Fin 1 containing a nonempty member.
-/
theorem frankl_fin_one
    (F : Finset (Finset (Fin 1)))
    (hUC : UnionClosed F)
    (hne : F.Nonempty)
    (hnonempty : ∃ s ∈ F, s.Nonempty) :
    FranklProperty F := by
  fin_cases F <;> simp_all +decide;
  · exact ⟨ 0, by simp +decide [ abundance ] ⟩;
  · exists 0

/-
Frankl's conjecture for families over Fin 2 containing a nonempty member.
-/
theorem frankl_fin_two
    (F : Finset (Finset (Fin 2)))
    (hUC : UnionClosed F)
    (hne : F.Nonempty)
    (hnonempty : ∃ s ∈ F, s.Nonempty) :
    FranklProperty F := by
  -- By examining all possible nonempty union-closed families over Fin 2, we can verify that each one satisfies the Frankl property.
  have h_cases : ∀ (F : Finset (Finset (Fin 2))), F.Nonempty → (∃ s ∈ F, s.Nonempty) → (∀ A ∈ F, ∀ B ∈ F, A ∪ B ∈ F) → ∃ x : Fin 2, 2 * (F.filter (x ∈ ·)).card ≥ F.card := by
    native_decide +revert;
  convert h_cases F hne hnonempty hUC

/-
Frankl's conjecture for families over Fin 3 containing a nonempty member.
-/
theorem frankl_fin_three
    (F : Finset (Finset (Fin 3)))
    (hUC : UnionClosed F)
    (hne : F.Nonempty)
    (hnonempty : ∃ s ∈ F, s.Nonempty) :
    FranklProperty F := by
  -- By examining all possible families over Fin 3, we can verify that each one satisfies Frankl's property.
  have h_all_families : ∀ F : Finset (Finset (Fin 3)), F.Nonempty → (∃ s ∈ F, s.Nonempty) → (∀ s ∈ F, ∀ t ∈ F, s ∪ t ∈ F) → ∃ v : Fin 3, 2 * (Finset.filter (fun s => v ∈ s) F).card ≥ F.card := by
    native_decide;
  exact h_all_families F hne hnonempty fun s hs t ht => hUC hs ht

/-! ## Transport to arbitrary small universes -/

/-
Frankl's conjecture for any universe of cardinality ≤ 3.
-/
theorem frankl_universe_card_le_three
    {α : Type*} [Fintype α] [DecidableEq α]
    (hα : Fintype.card α ≤ 3)
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (hne : F.Nonempty)
    (hnonempty : ∃ s ∈ F, s.Nonempty) :
    FranklProperty F := by
  -- We use the equivalence between α and Fin n for some n ≤ 3.
  obtain ⟨n, hn⟩ : ∃ n, Fintype.card α = n ∧ n ≤ 3 := by
    use Fintype.card α;
  -- We use the equivalence between α and Fin n for some n ≤ 3 to transport the problem.
  obtain ⟨e, he⟩ : ∃ e : α ≃ Fin n, True := by
    exact ⟨ Fintype.equivOfCardEq ( by simp +decide [ hn ] ), trivial ⟩;
  -- We use the equivalence between α and Fin n for some n ≤ 3 to transport the problem to Fin n.
  have h_transport : FranklProperty (F.image (fun s => s.map e.toEmbedding)) := by
    rcases hn with ⟨ hn₁, hn₂ ⟩ ; interval_cases n <;> simp_all +decide ;
    · exact False.elim ( hnonempty.elim fun s hs => hs.2.ne_empty <| Finset.eq_empty_of_forall_notMem fun x hx => Fin.elim0 <| e x );
    · convert frankl_fin_one _ _ _ _;
      · intro A hA B hB;
        grind;
      · exact ⟨ _, Finset.mem_image_of_mem _ hne.choose_spec ⟩;
      · obtain ⟨ s, hs₁, hs₂ ⟩ := hnonempty; use s.map e.toEmbedding; aesop;
    · apply frankl_fin_two;
      · intro A hA B hB;
        rw [ Finset.mem_image ] at hA hB ⊢; obtain ⟨ s, hs, rfl ⟩ := hA; obtain ⟨ t, ht, rfl ⟩ := hB; use s ∪ t; aesop;
      · exact ⟨ _, Finset.mem_image_of_mem _ hne.choose_spec ⟩;
      · obtain ⟨ s, hs₁, hs₂ ⟩ := hnonempty; use s.map e.toEmbedding; aesop;
    · apply frankl_fin_three;
      · intro A hA B hB; obtain ⟨ s, hs, rfl ⟩ := Finset.mem_image.mp hA; obtain ⟨ t, ht, rfl ⟩ := Finset.mem_image.mp hB; simp_all +decide [ UnionClosed ] ;
        exact ⟨ s ∪ t, hUC hs ht, by ext; aesop ⟩;
      · exact ⟨ _, Finset.mem_image_of_mem _ hne.choose_spec ⟩;
      · obtain ⟨ s, hs₁, hs₂ ⟩ := hnonempty; use s.map e.toEmbedding; aesop;
  obtain ⟨ x, hx ⟩ := h_transport; use e.symm x; simp_all +decide [ abundance ] ;
  rw [ Finset.card_image_of_injective _ fun s t h => by simpa using Finset.map_injective e.toEmbedding h ] at hx;
  convert hx using 2;
  refine' Finset.card_bij ( fun s hs => s.map e.toEmbedding ) _ _ _ <;> simp +decide [ Finset.mem_image ];
  exact fun s hs hs' => ⟨ hs, hs' ⟩

/-! ## Small family size cases -/

/-
A three-element union-closed family with a nonempty member satisfies
    Frankl's property.
-/
theorem frankl_card_three {α : Type*} [DecidableEq α]
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (hcard : F.card = 3)
    (hnonempty : ∃ s ∈ F, s.Nonempty) :
    FranklProperty F := by
  -- By assumption, $F$ has exactly 3 sets, and is union-closed.
  -- Thus, $F$ must contain a nonempty member $M$.
  obtain ⟨s, hs⟩ : ∃ s ∈ F, s.Nonempty := hnonempty;
  -- Let $M = \text{familyUniverse } F$. Since $F$ is union-closed and has exactly 3 elements, $M$ must be one of the sets in $F$.
  obtain ⟨M, hM⟩ : ∃ M ∈ F, M = familyUniverse F := by
    exact ⟨ _, unionClosed_contains_universe F hUC ⟨ s, hs.1 ⟩, rfl ⟩;
  -- Since $M$ is in $F$ and $F$ has exactly 3 elements, there must be at least one nonempty set in $F$ that is not equal to $M$.
  obtain ⟨s, hs⟩ : ∃ s ∈ F, s ≠ M ∧ s.Nonempty := by
    contrapose! hcard;
    exact ne_of_lt ( lt_of_le_of_lt ( Finset.card_le_card ( show F ⊆ { M, ∅ } from fun x hx => by by_cases h : x = M <;> aesop ) ) ( lt_of_le_of_lt ( Finset.card_insert_le _ _ ) ( by norm_num ) ) );
  -- Since $s$ is a nonempty set in $F$ and $s \neq M$, there must be an element $x \in s$ that is not in $M$.
  obtain ⟨x, hx⟩ : ∃ x ∈ s, x ∈ M := by
    exact Exists.elim hs.2.2 fun x hx => ⟨ x, hx, hM.2.symm ▸ Finset.mem_biUnion.mpr ⟨ s, hs.1, hx ⟩ ⟩;
  refine' ⟨ x, _ ⟩;
  have h_abundance : (F.filter (x ∈ ·)).card ≥ 2 := by
    exact Finset.one_lt_card.2 ⟨ s, by aesop, M, by aesop ⟩;
  exact le_trans ( by linarith ) ( Nat.mul_le_mul_left 2 h_abundance )