import Mathlib

/-!
# Packing lemmas for stable Kneser families

A finite set of integers is linearly `s`-stable when consecutive selected points are
at least `s` apart.  The main theorem below is the elementary packing inequality
underlying the numerical threshold `n - s*k + s` in stable Kneser problems.
-/

namespace StableKneser

/-- Linear (non-cyclic) stability for a finite set of natural numbers. -/
def LinearStable (s : ℕ) (A : Finset ℕ) : Prop :=
  ∀ ⦃x y : ℕ⦄, x ∈ A → y ∈ A → x < y → x + s ≤ y

/-
A linearly stable set occupies a span of at least `s * (|A|-1)`.
-/
theorem linearStable_span_bound (s : ℕ) (A : Finset ℕ) (hA : A.Nonempty)
    (hstable : LinearStable s A) :
    s * (A.card - 1) ≤ A.max' hA - A.min' hA := by
  obtain ⟨l, hl⟩ : ∃ l : Fin (A.card) → ℕ, StrictMono l ∧ ∀ i, l i ∈ A := by
    exact ⟨ fun i => A.orderEmbOfFin rfl i, by simp +decide [ StrictMono ], fun i => A.orderEmbOfFin_mem rfl _ ⟩;
  -- By induction on $i$, we show that $l i - l 0 \geq s * i$ for all $i$.
  have h_ind : ∀ i : Fin (A.card), l i - l ⟨0, hA.card_pos⟩ ≥ s * i := by
    intro ⟨ i, hi ⟩ ; induction i <;> simp_all +decide [Nat.mul_succ] ;
    rename_i k hk;
    exact le_tsub_of_add_le_left ( by linarith [ hk ( Nat.lt_of_succ_lt hi ), hstable ( hl.2 ⟨ k, Nat.lt_of_succ_lt hi ⟩ ) ( hl.2 ⟨ k + 1, hi ⟩ ) ( hl.1 ( Nat.lt_succ_self _ ) ), Nat.sub_add_cancel ( show l ⟨ k, Nat.lt_of_succ_lt hi ⟩ ≥ l ⟨ 0, hA.card_pos ⟩ from hl.1.monotone ( Nat.zero_le _ ) ) ] );
  refine' le_trans _ ( le_trans ( h_ind ⟨ A.card - 1, Nat.sub_lt ( Finset.card_pos.2 hA ) zero_lt_one ⟩ ) _ );
  · rfl;
  · exact Nat.sub_le_sub_right ( Finset.le_max' _ _ ( hl.2 _ ) ) _ |> le_trans <| Nat.sub_le_sub_left ( Finset.min'_le _ _ <| hl.2 _ ) _

/-
Interval form of the stable-set packing bound.
-/
theorem linearStable_card_bound (s a b : ℕ) (A : Finset ℕ)
    (hA : A.Nonempty) (hstable : LinearStable s A)
    (hsub : ∀ x ∈ A, x ∈ Finset.Icc a b) :
    s * (A.card - 1) ≤ b - a := by
  refine' le_trans ( StableKneser.linearStable_span_bound s A hA hstable ) _;
  exact Nat.sub_le_sub_right ( Finset.mem_Icc.mp ( hsub _ ( Finset.max'_mem _ hA ) ) |>.2 ) _ |> le_trans <| Nat.sub_le_sub_left ( Finset.mem_Icc.mp ( hsub _ ( Finset.min'_mem _ hA ) ) |>.1 ) _

/-
In an interval of exactly the minimum possible span, every gap is forced.
This is the rigidity statement used at the exceptional color in the standard
upper coloring of a stable Kneser graph.
-/
theorem linearStable_extremal_unique (s k a : ℕ) (hs : 0 < s) (hk : 0 < k)
    (A : Finset ℕ) (hcard : A.card = k) (hstable : LinearStable s A)
    (hsub : ∀ x ∈ A, x ∈ Finset.Icc a (a + s * (k - 1))) :
    A = Finset.image (fun i : ℕ => a + s * i) (Finset.range k) := by
  -- Let's enumerate the elements of $A$ in increasing order as $a_1 < a_2 < \ldots < a_k$.
  obtain ⟨a_seq, ha_seq⟩ : ∃ a_seq : Fin k → ℕ, StrictMono a_seq ∧ ∀ i, a_seq i ∈ A ∧ a_seq i ∈ Finset.Icc a (a + s * (k - 1)) := by
    exact ⟨ fun i => A.orderEmbOfFin ( by aesop ) i, by aesop_cat, fun i => ⟨ by aesop, hsub _ <| by aesop ⟩ ⟩;
  -- By induction on $i$, we show that $a_seq i = a + s * i$ for all $i$.
  have h_ind : ∀ i, a_seq i = a + s * i := by
    intro ⟨ i, hi ⟩ ; induction' i with i ih;
    · by_contra h_contra;
      -- If $a_seq ⟨0, hi⟩ > a$, then since $a_seq$ is strictly increasing, we have $a_seq i > a + s * i$ for all $i$.
      have h_gt : ∀ i : Fin k, a_seq i > a + s * i := by
        intro ⟨ i, hi ⟩ ; induction i <;> simp_all +decide [ Nat.mul_succ, Finset.mem_Icc ] ;
        · exact lt_of_le_of_ne ( ha_seq.2 _ |>.2.1 ) ( Ne.symm h_contra );
        · rename_i n hn;
          linarith! [ hn ( Nat.lt_of_succ_lt hi ), hstable ( ha_seq.2 ⟨ n, Nat.lt_of_succ_lt hi ⟩ |>.1 ) ( ha_seq.2 ⟨ n + 1, hi ⟩ |>.1 ) ( ha_seq.1 ( Nat.lt_succ_self _ ) ) ];
      rcases k with ( _ | _ | k ) <;> simp_all +decide [ Finset.mem_Icc ];
      exact absurd ( h_gt ( Fin.last _ ) ) ( by norm_num; linarith [ ha_seq.2 ( Fin.last _ ) ] );
    · have := hstable ( ha_seq.2 ⟨ i, by linarith ⟩ |>.1 ) ( ha_seq.2 ⟨ i + 1, hi ⟩ |>.1 ) ( ha_seq.1 ( Nat.lt_succ_self _ ) ) ; simp_all +decide [ Nat.mul_succ ] ;
      by_contra h_contra;
      -- If $a_seq ⟨i + 1, hi⟩ > a + s * (i + 1)$, then by induction, $a_seq ⟨j, hj⟩ > a + s * j$ for all $j \geq i + 1$.
      have h_induct : ∀ j : Fin k, i + 1 ≤ j.val → a_seq j > a + s * j.val := by
        intro j hj; induction j; simp_all +decide;
        induction hj <;> simp_all +decide [ Nat.mul_succ ];
        · grobner;
        · rename_i m hm ih;
          linarith! [ ih ( by linarith ), hstable ( ha_seq.2 ⟨ _, by linarith ⟩ |>.1 ) ( ha_seq.2 ⟨ _, by linarith ⟩ |>.1 ) ( ha_seq.1 ( Nat.lt_succ_self _ ) ) ];
      exact absurd ( h_induct ⟨ k - 1, Nat.sub_lt hk zero_lt_one ⟩ ( Nat.le_sub_one_of_lt hi ) ) ( by norm_num; linarith [ ha_seq.2 ⟨ k - 1, Nat.sub_lt hk zero_lt_one ⟩ ] );
  refine' Finset.eq_of_subset_of_card_le ( fun x hx => _ ) _;
  · obtain ⟨ i, hi ⟩ := Finset.mem_image.mp ( show x ∈ Finset.image a_seq Finset.univ from by { rw [ Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr fun i _ => ha_seq.2 i |>.1 ) ( by simp +decide [ Finset.card_image_of_injective _ ha_seq.1.injective, * ] ) ] ; aesop } ) ; aesop;
  · exact Finset.card_image_le.trans (by simp [hcard])

/-
Consequently, two extremal stable sets in the same shortest interval meet
(in fact, both are the same arithmetic progression).
-/
theorem linearStable_extremal_intersect (s k a : ℕ) (hs : 0 < s) (hk : 0 < k)
    (A B : Finset ℕ) (hcardA : A.card = k) (hcardB : B.card = k)
    (hstableA : LinearStable s A) (hstableB : LinearStable s B)
    (hsubA : ∀ x ∈ A, x ∈ Finset.Icc a (a + s * (k - 1)))
    (hsubB : ∀ x ∈ B, x ∈ Finset.Icc a (a + s * (k - 1))) :
    (A ∩ B).Nonempty := by
  obtain ⟨A_eq, B_eq⟩ : A = Finset.image (fun i : ℕ => a + s * i) (Finset.range k) ∧ B = Finset.image (fun i : ℕ => a + s * i) (Finset.range k) := by
    exact ⟨ linearStable_extremal_unique s k a hs hk A hcardA hstableA hsubA, linearStable_extremal_unique s k a hs hk B hcardB hstableB hsubB ⟩;
  exact ⟨ _, Finset.mem_inter_of_mem ( A_eq.symm ▸ Finset.mem_image_of_mem _ ( Finset.mem_range.mpr hk ) ) ( B_eq.symm ▸ Finset.mem_image_of_mem _ ( Finset.mem_range.mpr hk ) ) ⟩

end StableKneser