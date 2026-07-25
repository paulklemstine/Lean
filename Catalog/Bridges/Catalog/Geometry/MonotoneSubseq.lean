/-
# Erdős–Szekeres Monotone Subsequence Theorem

The classical Erdős–Szekeres theorem (1935) states that any sequence of more than
(r-1)(s-1) distinct real numbers contains either an increasing subsequence of
length r or a decreasing subsequence of length s.

The proof uses the pigeonhole principle via the Seidenberg/Hammersley labeling.
-/
import Mathlib

open Finset Function

namespace ErdosSzekeres

/-! ## Monotone Subsequence Definitions -/

/-- A sequence has a strictly increasing subsequence of length k. -/
def HasIncreasingSubseq {m : ℕ} (a : Fin m → ℝ) (k : ℕ) : Prop :=
  ∃ f : Fin k → Fin m, StrictMono f ∧ StrictMono (a ∘ f)

/-- A sequence has a strictly decreasing subsequence of length k. -/
def HasDecreasingSubseq {m : ℕ} (a : Fin m → ℝ) (k : ℕ) : Prop :=
  ∃ f : Fin k → Fin m, StrictMono f ∧ StrictAnti (a ∘ f)

/-- Monotonicity: if there is an increasing subsequence of length k,
there is one of any length k' ≤ k. -/
theorem HasIncreasingSubseq.mono {m : ℕ} {a : Fin m → ℝ} {k k' : ℕ}
    (h : HasIncreasingSubseq a k) (hle : k' ≤ k) :
    HasIncreasingSubseq a k' := by
  obtain ⟨f, hf_mono, hf_inc⟩ := h
  exact ⟨fun i => f ⟨i.val, by omega⟩,
    fun i j hij => hf_mono (Fin.mk_lt_mk.mpr (by omega)),
    fun i j hij => hf_inc (Fin.mk_lt_mk.mpr (by omega))⟩

theorem HasDecreasingSubseq.mono {m : ℕ} {a : Fin m → ℝ} {k k' : ℕ}
    (h : HasDecreasingSubseq a k) (hle : k' ≤ k) :
    HasDecreasingSubseq a k' := by
  obtain ⟨f, hf_mono, hf_dec⟩ := h
  exact ⟨fun i => f ⟨i.val, by omega⟩,
    fun i j hij => hf_mono (Fin.mk_lt_mk.mpr (by omega)),
    fun i j hij => hf_dec (Fin.mk_lt_mk.mpr (by omega))⟩

/-- A sequence of length 0 has an increasing subsequence of length 0. -/
theorem hasIncreasingSubseq_zero {m : ℕ} (a : Fin m → ℝ) :
    HasIncreasingSubseq a 0 :=
  ⟨Fin.elim0, isEmptyElim, isEmptyElim⟩

/-- A sequence of length 0 has a decreasing subsequence of length 0. -/
theorem hasDecreasingSubseq_zero {m : ℕ} (a : Fin m → ℝ) :
    HasDecreasingSubseq a 0 :=
  ⟨Fin.elim0, isEmptyElim, isEmptyElim⟩

/-! ## The Erdős–Szekeres Theorem via Pigeonhole -/

/-
**Erdős–Szekeres Monotone Subsequence Theorem.**
Every sequence of more than (r-1)(s-1) distinct real numbers contains
either an increasing subsequence of length r or a decreasing subsequence
of length s.
-/
theorem erdos_szekeres_monotone
    (r s m : ℕ)
    (hr : 1 ≤ r)
    (hs : 1 ≤ s)
    (hm : (r - 1) * (s - 1) < m)
    (a : Fin m → ℝ)
    (hinj : Injective a) :
    HasIncreasingSubseq a r ∨ HasDecreasingSubseq a s := by
  by_contra h;
  -- Define the map i → (inc_i, dec_i) for each i.
  set inc := fun i : Fin m => sSup (Set.image (fun f : Finset (Fin m) => Finset.card f) {f : Finset (Fin m) | i ∈ f ∧ (∀ x ∈ f, x ≤ i) ∧ (∀ x ∈ f, ∀ y ∈ f, x < y → a x < a y)}) with hinc
  set dec := fun i : Fin m => sSup (Set.image (fun f : Finset (Fin m) => Finset.card f) {f : Finset (Fin m) | i ∈ f ∧ (∀ x ∈ f, x ≤ i) ∧ (∀ x ∈ f, ∀ y ∈ f, x < y → a x > a y)}) with hdec;
  -- By definition of $inc$ and $dec$, we know that $inc_i \leq r-1$ and $dec_i \leq s-1$ for all $i$.
  have h_inc_le_r_minus_1 : ∀ i : Fin m, inc i ≤ r - 1 := by
    intro i
    by_contra h_contra
    have h_inc_ge_r : ∃ f : Finset (Fin m), i ∈ f ∧ (∀ x ∈ f, x ≤ i) ∧ (∀ x ∈ f, ∀ y ∈ f, x < y → a x < a y) ∧ Finset.card f ≥ r := by
      have := Nat.sSup_mem ( show ( Set.Nonempty ( Set.image ( fun f : Finset ( Fin m ) => Finset.card f ) { f : Finset ( Fin m ) | i ∈ f ∧ ( ∀ x ∈ f, x ≤ i ) ∧ ∀ x ∈ f, ∀ y ∈ f, x < y → a x < a y } ) ) from ?_ );
      · exact Exists.elim ( this ⟨ m, Set.forall_mem_image.2 fun f hf => le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ⟩ ) fun f hf => ⟨ f, hf.1.1, hf.1.2.1, hf.1.2.2, by linarith [ Nat.sub_add_cancel hr ] ⟩;
      · exact ⟨ _, ⟨ { i }, ⟨ Finset.mem_singleton_self _, fun x hx => by aesop, fun x hx y hy hxy => by aesop ⟩, rfl ⟩ ⟩;
    obtain ⟨ f, hf₁, hf₂, hf₃, hf₄ ⟩ := h_inc_ge_r;
    -- Since $f$ is a finite set of indices, we can order them as $i_1 < i_2 < \cdots < i_r$.
    obtain ⟨g, hg⟩ : ∃ g : Fin r → Fin m, StrictMono g ∧ ∀ j : Fin r, g j ∈ f := by
      exact ⟨ fun j => f.orderEmbOfFin rfl ⟨ j, by linarith [ Fin.is_lt j ] ⟩, by simp +decide [ StrictMono ], fun j => by simp +decide ⟩;
    exact h <| Or.inl ⟨ g, hg.1, fun x y hxy => hf₃ _ ( hg.2 x ) _ ( hg.2 y ) <| hg.1 hxy ⟩
  have h_dec_le_s_minus_1 : ∀ i : Fin m, dec i ≤ s - 1 := by
    intro i
    have h_dec_le_s_minus_1_i : ∀ f : Finset (Fin m), i ∈ f → (∀ x ∈ f, x ≤ i) → (∀ x ∈ f, ∀ y ∈ f, x < y → a x > a y) → Finset.card f ≤ s - 1 := by
      intro f hi hf₁ hf₂; contrapose! h;
      -- Since $f$ is a decreasing subsequence of length $s$, we can construct a strictly decreasing subsequence of length $s$.
      obtain ⟨g, hg⟩ : ∃ g : Fin s → Fin m, StrictMono g ∧ ∀ j : Fin s, g j ∈ f ∧ ∀ k : Fin s, j < k → a (g j) > a (g k) := by
        have h_decreasing_subseq : ∃ g : Fin s → Fin m, StrictMono g ∧ ∀ j : Fin s, g j ∈ f := by
          exact ⟨ fun j => f.orderEmbOfFin rfl ⟨ j, by linarith [ Fin.is_lt j, Nat.sub_add_cancel hs ] ⟩, by simp +decide [ StrictMono ], fun j => by simp +decide ⟩;
        exact ⟨ h_decreasing_subseq.choose, h_decreasing_subseq.choose_spec.1, fun j => ⟨ h_decreasing_subseq.choose_spec.2 j, fun k hk => hf₂ _ ( h_decreasing_subseq.choose_spec.2 j ) _ ( h_decreasing_subseq.choose_spec.2 k ) ( h_decreasing_subseq.choose_spec.1 hk ) ⟩ ⟩;
      exact Or.inr ⟨ g, hg.1, fun j k hjk => hg.2 j |>.2 k hjk ⟩;
    exact csSup_le' fun x hx => by rcases hx with ⟨ f, hf, rfl ⟩ ; exact h_dec_le_s_minus_1_i f hf.1 hf.2.1 hf.2.2;
  -- By definition of $inc$ and $dec$, the map $i \mapsto (inc_i, dec_i)$ is injective.
  have h_inj : Function.Injective (fun i : Fin m => (inc i, dec i)) := by
    intro i j hij;
    nontriviality;
    -- By definition of $inc$ and $dec$, if $i < j$, then $inc_j \geq inc_i + 1$ or $dec_j \geq dec_i + 1$.
    have h_inc_dec : ∀ i j : Fin m, i < j → inc j ≥ inc i + 1 ∨ dec j ≥ dec i + 1 := by
      intros i j hij
      by_cases h_cases : a i < a j;
      · left;
        refine' le_csSup _ _;
        · exact Set.Finite.bddAbove <| Set.Finite.image _ <| Set.finite_iff_bddAbove.mpr ⟨ Finset.univ, fun f hf => Finset.le_iff_subset.mpr fun x hx => Finset.mem_univ x ⟩;
        · -- Let $f$ be a subset of $\{0, 1, ..., i\}$ such that $i \in f$ and $f$ is strictly increasing.
          obtain ⟨f, hf⟩ : ∃ f : Finset (Fin m), i ∈ f ∧ (∀ x ∈ f, x ≤ i) ∧ (∀ x ∈ f, ∀ y ∈ f, x < y → a x < a y) ∧ f.card = inc i := by
            have h_inc_def : ∃ f ∈ {f : Finset (Fin m) | i ∈ f ∧ (∀ x ∈ f, x ≤ i) ∧ (∀ x ∈ f, ∀ y ∈ f, x < y → a x < a y)}, ∀ g ∈ {f : Finset (Fin m) | i ∈ f ∧ (∀ x ∈ f, x ≤ i) ∧ (∀ x ∈ f, ∀ y ∈ f, x < y → a x < a y)}, f.card ≥ g.card := by
              apply_rules [ Set.exists_max_image ];
              · exact Set.toFinite _;
              · exact ⟨ { i }, by aesop ⟩;
            obtain ⟨ f, hf₁, hf₂ ⟩ := h_inc_def;
            exact ⟨ f, hf₁.1, hf₁.2.1, hf₁.2.2, le_antisymm ( le_csSup ⟨ _, Set.forall_mem_image.2 fun g hg => hf₂ g hg ⟩ ⟨ f, hf₁, rfl ⟩ ) ( csSup_le ⟨ _, ⟨ f, hf₁, rfl ⟩ ⟩ <| Set.forall_mem_image.2 fun g hg => hf₂ g hg ) ⟩;
          use Insert.insert j f;
          grind;
      · -- Since $a i > a j$, we can extend the decreasing subsequence ending at $i$ to include $j$, thus increasing its length by 1.
        have h_dec_ext : ∀ f : Finset (Fin m), i ∈ f ∧ (∀ x ∈ f, x ≤ i) ∧ (∀ x ∈ f, ∀ y ∈ f, x < y → a x > a y) → ∃ g : Finset (Fin m), j ∈ g ∧ (∀ x ∈ g, x ≤ j) ∧ (∀ x ∈ g, ∀ y ∈ g, x < y → a x > a y) ∧ g.card = f.card + 1 := by
          intros f hf
          use insert j f;
          grind;
        have h_dec_ext : ∀ f : Finset (Fin m), i ∈ f ∧ (∀ x ∈ f, x ≤ i) ∧ (∀ x ∈ f, ∀ y ∈ f, x < y → a x > a y) → dec j ≥ f.card + 1 := by
          intros f hf
          obtain ⟨g, hg⟩ := h_dec_ext f hf;
          exact hg.2.2.2 ▸ le_csSup ( by exact Set.Finite.bddAbove ( Set.toFinite _ ) ) ( Set.mem_image_of_mem _ ⟨ hg.1, hg.2.1, hg.2.2.1 ⟩ );
        have h_dec_ext : dec j ≥ dec i + 1 := by
          have h_dec_ext : ∃ f : Finset (Fin m), i ∈ f ∧ (∀ x ∈ f, x ≤ i) ∧ (∀ x ∈ f, ∀ y ∈ f, x < y → a x > a y) ∧ f.card = dec i := by
            have h_dec_ext : ∃ f ∈ {f : Finset (Fin m) | i ∈ f ∧ (∀ x ∈ f, x ≤ i) ∧ (∀ x ∈ f, ∀ y ∈ f, x < y → a x > a y)}, ∀ g ∈ {f : Finset (Fin m) | i ∈ f ∧ (∀ x ∈ f, x ≤ i) ∧ (∀ x ∈ f, ∀ y ∈ f, x < y → a x > a y)}, f.card ≥ g.card := by
              apply_rules [ Set.exists_max_image ];
              · exact Set.toFinite _;
              · exact ⟨ { i }, by simp +decide ⟩;
            obtain ⟨ f, hf₁, hf₂ ⟩ := h_dec_ext;
            exact ⟨ f, hf₁.1, hf₁.2.1, hf₁.2.2, le_antisymm ( le_csSup ⟨ _, Set.forall_mem_image.2 fun g hg => hf₂ g hg ⟩ ⟨ f, hf₁, rfl ⟩ ) ( csSup_le ⟨ _, ⟨ f, hf₁, rfl ⟩ ⟩ <| Set.forall_mem_image.2 fun g hg => hf₂ g hg ) ⟩;
          grind;
        exact Or.inr h_dec_ext;
    exact le_antisymm ( le_of_not_gt fun hi => by cases h_inc_dec _ _ hi <;> norm_num at hij <;> linarith ) ( le_of_not_gt fun hj => by cases h_inc_dec _ _ hj <;> norm_num at hij <;> linarith );
  have h_card : Finset.card (Finset.image (fun i : Fin m => (inc i, dec i)) Finset.univ) ≤ (r - 1) * (s - 1) := by
    exact le_trans ( Finset.card_le_card <| Finset.image_subset_iff.mpr fun i _ => Finset.mem_product.mpr ⟨ Finset.mem_Icc.mpr ⟨ Nat.succ_le_of_lt <| show 0 < inc i from by
                                                                                                                                                        refine' lt_of_lt_of_le _ ( le_csSup _ <| Set.mem_image_of_mem _ <| show { i } ∈ { f : Finset ( Fin m ) | i ∈ f ∧ ( ∀ x ∈ f, x ≤ i ) ∧ ∀ x ∈ f, ∀ y ∈ f, x < y → a x < a y } from _ ) <;> norm_num;
                                                                                                                                                        exact Set.Finite.bddAbove <| Set.Finite.image _ <| Set.finite_iff_bddAbove.mpr ⟨ Finset.Iic i, fun f hf => Finset.le_iff_subset.mpr fun x hx => Finset.mem_Iic.mpr <| hf.2.1 x hx ⟩, h_inc_le_r_minus_1 i ⟩, Finset.mem_Icc.mpr ⟨ Nat.succ_le_of_lt <| show 0 < dec i from by
                                                                                                                                                                                                                                                        refine' lt_of_lt_of_le _ ( le_csSup _ <| Set.mem_image_of_mem _ <| show { i } ∈ { f : Finset ( Fin m ) | i ∈ f ∧ ( ∀ x ∈ f, x ≤ i ) ∧ ∀ x ∈ f, ∀ y ∈ f, x < y → a x > a y } from _ ) <;> norm_num;
                                                                                                                                                                                                                                                        exact Set.Finite.bddAbove <| Set.Finite.image _ <| Set.finite_iff_bddAbove.mpr ⟨ Finset.univ, fun f hf => Finset.le_iff_subset.mpr fun x hx => Finset.mem_univ x ⟩, h_dec_le_s_minus_1 i ⟩ ⟩ ) ( by norm_num [ mul_comm ] );
  rw [ Finset.card_image_of_injective _ h_inj ] at h_card ; norm_num at h_card ; linarith

/-- **Corollary**: any sequence of n²+1 distinct reals contains a monotone
subsequence of length n+1. -/
theorem erdos_szekeres_square
    (n m : ℕ)
    (hm : n * n < m)
    (a : Fin m → ℝ)
    (hinj : Injective a) :
    HasIncreasingSubseq a (n + 1) ∨ HasDecreasingSubseq a (n + 1) := by
  apply erdos_szekeres_monotone (n + 1) (n + 1) m (by omega) (by omega) _ a hinj
  simp; exact hm

end ErdosSzekeres