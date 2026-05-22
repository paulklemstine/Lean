/-
# Ramsey Theory: Recursive Bounds

This module proves the fundamental recursive inequality for Ramsey numbers
and derives the Erdős–Szekeres upper bound R(s,t) ≤ C(s+t-2, s-1).

## Main results

* `RamseyProp_recursion` — if `RamseyProp a s' t` and `RamseyProp b s t'` hold,
  then `RamseyProp (a + b) s t` holds (the neighborhood dichotomy argument)
* `RamseyProp_le_choose` — R(s,t) ≤ C(s+t-2, s-1), the Erdős–Szekeres bound
-/
import Mathlib
import Algebra.Ramsey.Defs

open Finset

/-! ## The Fundamental Recursive Inequality

The key insight: fix a vertex v in a 2-coloring of K_{a+b}. The remaining
a+b-1 vertices split into red-neighbors and blue-neighbors of v. By
pigeonhole, either there are ≥ a red neighbors or ≥ b blue neighbors.
In the first case, the red neighborhood contains a red K_{s-1} or blue K_t
by hypothesis; adjoining v to the red clique gives red K_s.
Similarly for the second case.
-/

/-- Restriction of a `TwoColoring` to a subset, re-indexed by `Fin m`. -/
def TwoColoring.restrict (C : TwoColoring n) (f : Fin m → Fin n)
    (hf : Function.Injective f) : TwoColoring m where
  color i j := C.color (f i) (f j)
  symm i j := C.symm (f i) (f j)
  irrefl i := by simp [C.irrefl (f i)]

/-- The image of a red clique under an injection is a red clique. -/
theorem IsRedClique_map {C : TwoColoring n} {f : Fin m → Fin n}
    {hf : Function.Injective f} {S : Finset (Fin m)}
    (hS : IsRedClique (C.restrict f hf) S) :
    IsRedClique C (S.map ⟨f, hf⟩) := by
  intro i hi j hj hij
  simp [Finset.mem_map] at hi hj
  obtain ⟨a, ha, rfl⟩ := hi
  obtain ⟨b, hb, rfl⟩ := hj
  exact hS a ha b hb (fun h => hij (congrArg f h))

/-- The image of a blue clique under an injection is a blue clique. -/
theorem IsBlueClique_map {C : TwoColoring n} {f : Fin m → Fin n}
    {hf : Function.Injective f} {S : Finset (Fin m)}
    (hS : IsBlueClique (C.restrict f hf) S) :
    IsBlueClique C (S.map ⟨f, hf⟩) := by
  intro i hi j hj hij
  simp [Finset.mem_map] at hi hj
  obtain ⟨a, ha, rfl⟩ := hi
  obtain ⟨b, hb, rfl⟩ := hj
  exact hS a ha b hb (fun h => hij (congrArg f h))

/-- If a set has `a + b` elements (as `Fin (a+b)` minus one vertex), and we
    partition it by a predicate, then one part has ≥ a elements or the other
    has ≥ b elements. This is the pigeonhole step. -/
theorem pigeonhole_partition {a b : ℕ} (S : Finset (Fin (a + b)))
    (hS : S.card = a + b - 1) (P : Fin (a + b) → Bool) :
    (S.filter (fun x => P x = true)).card ≥ a ∨
    (S.filter (fun x => P x = false)).card ≥ b := by
  by_contra h
  push_neg at h
  have h1 := h.1
  have h2 := h.2
  have := Finset.filter_card_add_filter_neg_card_eq_card (s := S) (p := fun x => P x = true)
  simp only [Bool.not_eq_true] at this
  omega

/-
**Ramsey recursion**: if `RamseyProp a (s-1) t` and `RamseyProp b s (t-1)` hold,
    then `RamseyProp (a + b) s t` holds (for `s, t ≥ 2`).

    This is the fundamental recursive inequality underlying all upper bounds.
    The proof uses the neighborhood dichotomy: fix a vertex v, partition the
    remaining vertices by color to v, apply pigeonhole, then invoke the
    inductive hypotheses.
-/
set_option maxHeartbeats 800000 in
theorem RamseyProp_recursion {a b s t : ℕ} (hs : 2 ≤ s) (ht : 2 ≤ t)
    (hred : RamseyProp a (s - 1) t) (hblue : RamseyProp b s (t - 1)) :
    RamseyProp (a + b) s t := by
      have ha : 1 ≤ a := by
        rcases a with ( _ | _ | a ) <;> simp_all +arith +decide [ RamseyProp ];
        rcases s with ( _ | _ | s ) <;> rcases t with ( _ | _ | t ) <;> simp_all +arith +decide [ IsRedClique, IsBlueClique ];
        cases hred ⟨ fun _ _ => Bool.false, by simp +decide, by simp +decide ⟩ <;> obtain ⟨ S, hS ⟩ := ‹_› <;> have := Finset.card_le_univ S <;> simp_all +arith +decide
      have hb : 1 ≤ b := by
        nontriviality;
        rcases b with ( _ | b ) <;> simp_all +decide [ RamseyProp ];
        rcases s with ( _ | _ | s ) <;> rcases t with ( _ | _ | t ) <;> simp_all +decide [ IsRedClique, IsBlueClique ];
        cases hblue ⟨ fun _ _ => Bool.false, by simp +decide, by simp +decide ⟩ <;> obtain ⟨ S, hS ⟩ := ‹_› <;> have := Finset.card_le_univ S <;> simp_all +decide;
      intro C
      by_contra h_contra
      push_neg at h_contra
      obtain ⟨v₀, others, hothers⟩ : ∃ v₀ : Fin (a + b), ∃ others : Finset (Fin (a + b)), others = Finset.univ.erase v₀ ∧ others.card = a + b - 1 := by
        exact ⟨ ⟨ 0, by linarith ⟩, _, rfl, by simp +decide [ Finset.card_erase_of_mem ] ⟩;
      -- By pigeonhole, either |R| ≥ a or |B| ≥ b.
      obtain (hR | hB) : (others.filter (fun w => C.color v₀ w = true)).card ≥ a ∨ (others.filter (fun w => C.color v₀ w = false)).card ≥ b := by
        have h_pigeonhole : (others.filter (fun w => C.color v₀ w = true)).card + (others.filter (fun w => C.color v₀ w = false)).card = a + b - 1 := by
          rw [ ← hothers.2, Finset.card_filter, Finset.card_filter ];
          simpa only [ ← Finset.sum_add_distrib ] using Finset.card_eq_sum_ones _ ▸ by congr; ext; aesop;
        omega;
      · -- Choose an injective function f : Fin a → Fin (a + b) whose image is contained in R.
        obtain ⟨f, hf_inj, hf_image⟩ : ∃ f : Fin a → Fin (a + b), Function.Injective f ∧ ∀ i : Fin a, f i ∈ others.filter (fun w => C.color v₀ w = true) := by
          obtain ⟨ s, hs ⟩ := Finset.exists_subset_card_eq hR;
          exact ⟨ fun i => s.orderEmbOfFin ( by aesop ) i, by aesop_cat, fun i => hs.1 <| by aesop ⟩;
        -- Restrict C to this subset. By hred : RamseyProp a (s-1) t, either:
        -- - There exists a red (s-1)-clique S in the restricted coloring. Then f '' S is a red (s-1)-clique in C, and adding v₀ gives a red s-clique (since v₀ is red-adjacent to all vertices in R).
        -- - There exists a blue t-clique S in the restricted coloring. Then f '' S is a blue t-clique in C.
        obtain (⟨S, hS_card, hS_red⟩ | ⟨S, hS_card, hS_blue⟩) : (∃ S : Finset (Fin a), S.card = s - 1 ∧ IsRedClique (C.restrict f hf_inj) S) ∨ (∃ S : Finset (Fin a), S.card = t ∧ IsBlueClique (C.restrict f hf_inj) S) := by
          exact hred _;
        · refine' h_contra.1 ( Insert.insert v₀ ( S.map ⟨ f, hf_inj ⟩ ) ) _ _ <;> simp_all +decide [ Finset.card_insert_of_notMem, IsRedClique ];
          · rw [ Nat.sub_add_cancel ( by linarith ) ];
          · exact fun i hi => ⟨ by simpa [ C.symm ] using hf_image i |>.2, fun j hj hij => hS_red i hi j hj ( by simpa [ hf_inj.eq_iff ] using hij ) ⟩;
        · refine' h_contra.2 ( S.map ⟨ f, hf_inj ⟩ ) _ _;
          · rw [ Finset.card_map, hS_card ];
          · exact?;
      · -- Choose an injective function f : Fin b → Fin (a+b) whose image is contained in B.
        obtain ⟨f, hf_inj, hf_image⟩ : ∃ f : Fin b → Fin (a + b), Function.Injective f ∧ ∀ i, f i ∈ others.filter (fun w => C.color v₀ w = false) := by
          obtain ⟨ s, hs ⟩ := Finset.exists_subset_card_eq hB;
          exact ⟨ fun i => s.orderEmbOfFin ( by aesop ) i, by aesop_cat, fun i => hs.1 <| by aesop ⟩;
        -- Restrict C to this subset. By hblue : RamseyProp b s (t-1), either:
        -- - There exists a red s-clique S in the restricted coloring. Then f '' S is a red s-clique in C.
        -- - There exists a blue (t-1)-clique S in the restricted coloring. Then f '' S is a blue (t-1)-clique in C, and adding v₀ gives a blue t-clique.
        obtain (h_red | h_blue) : (∃ S : Finset (Fin b), S.card = s ∧ IsRedClique (C.restrict f hf_inj) S) ∨ (∃ S : Finset (Fin b), S.card = t - 1 ∧ IsBlueClique (C.restrict f hf_inj) S) := by
          exact hblue _;
        · obtain ⟨ S, hS₁, hS₂ ⟩ := h_red; specialize h_contra; have := h_contra.1 ( S.map ⟨ f, hf_inj ⟩ ) ; simp_all +decide [ Finset.card_map ] ;
          exact h_contra.1 ( S.map ⟨ f, hf_inj ⟩ ) ( by simpa [ Finset.card_image_of_injective _ hf_inj ] using hS₁ ) ( IsRedClique_map hS₂ );
        · obtain ⟨ S, hS₁, hS₂ ⟩ := h_blue;
          refine' h_contra.2 ( Finset.image f S ∪ { v₀ } ) _ _;
          · rw [ Finset.card_union ] ; simp_all +decide [ Finset.card_image_of_injective _ hf_inj ];
            exact Nat.succ_pred_eq_of_pos ( pos_of_gt ht );
          · intro i hi j hj hij; simp_all +decide [ IsBlueClique ] ;
            rcases hi with ( rfl | ⟨ i, hi, rfl ⟩ ) <;> rcases hj with ( rfl | ⟨ j, hj, rfl ⟩ ) <;> simp_all +decide [ TwoColoring.restrict ];
            · rw [ C.symm, hf_image i |>.2 ];
            · grind

/-! ## The Erdős–Szekeres Bound -/

/-
`RamseyProp` holds with the binomial coefficient bound:
    `RamseyProp (Nat.choose (s + t) (s)) (s + 1) (t + 1)`.

    This is the Erdős–Szekeres theorem, proved by induction using Pascal's identity
    and the recursive Ramsey inequality.
-/
theorem RamseyProp_choose (s t : ℕ) :
    RamseyProp (Nat.choose (s + t) s) (s + 1) (t + 1) := by
      induction' s with s hs generalizing t;
      · exact RamseyProp_one_left _ ( by norm_num ) _;
      · induction' t with t ht;
        · exact RamseyProp_one_right _ ( by norm_num ) _;
        · convert RamseyProp_recursion ( show 2 ≤ s + 1 + 1 from by linarith ) ( show 2 ≤ t + 1 + 1 from by linarith ) ( hs _ ) ht using 1;
          simp +arith +decide [ Nat.choose ]

/-- **Erdős–Szekeres bound**: For all `s, t ≥ 1`,
    `R(s, t) ≤ C(s + t - 2, s - 1)`.

    More precisely, `RamseyProp (Nat.choose (s+t-2) (s-1)) s t` holds
    whenever `s, t ≥ 1`. -/
theorem RamseyProp_le_choose' {s t : ℕ} (hs : 1 ≤ s) (ht : 1 ≤ t) :
    RamseyProp (Nat.choose (s + t - 2) (s - 1)) s t := by
  obtain ⟨s, rfl⟩ := Nat.exists_eq_add_of_le hs
  obtain ⟨t, rfl⟩ := Nat.exists_eq_add_of_le ht
  have h1 : 1 + s + (1 + t) - 2 = s + t := by omega
  have h2 : 1 + s - 1 = s := by omega
  rw [h1, h2, show 1 + s = s + 1 from by omega, show 1 + t = t + 1 from by omega]
  exact RamseyProp_choose s t