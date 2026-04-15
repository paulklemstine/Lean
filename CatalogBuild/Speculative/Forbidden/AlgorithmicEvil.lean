/-! # CatalogBuild.Speculative.Forbidden.AlgorithmicEvil

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 6
-/

import Mathlib

theorem ackermann_gt_right (m n : ℕ) : ackermann m n > n := by
  induction' n with n ih generalizing m;
  · induction' m with m ih <;> simp +arith +decide [ * ];
    · native_decide +revert;
    · -- By definition of ackermann, we have ackermann (m + 1) 0 = ackermann m 1.
      rw [ackermann];
      exact Nat.one_le_iff_ne_zero.mpr ( by linarith [ ackermann_strict_mono_right m ( show 0 < 1 from by decide ) ] );
  · -- By the strict monotonicity of the Ackermann function in its second argument, we have ackermann m (n + 1) > ackermann m n.
    have h_mono : ackermann m (n + 1) > ackermann m n := by
      exact ackermann_strict_mono_right m ( Nat.lt_succ_self _ );
    linarith [ ih m ]


theorem ackermann_zero (n : ℕ) : ackermann 0 n = n + 1 := by
  -- By definition, we have `ackermann 1 m = ackermann (0+1) m = ackermann 0 1`.
  rw [ackermann]


theorem ackermann_one (n : ℕ) : ackermann 1 n = n + 2 := by
  induction' n with n ih <;> simp +arith +decide [ *, ackermann ]


theorem pigeonhole_evil (n : ℕ) (f : Fin (n + 2) → Fin (n + 1)) :
    ¬ Injective f := by
  exact fun h => absurd ( Fintype.card_le_of_injective f h ) ( by simp +arith +decide )


theorem infinite_pigeonhole (n : ℕ) (f : ℕ → Fin (n + 1)) :
    ∃ c : Fin (n + 1), ∀ N : ℕ, ∃ m : ℕ, m ≥ N ∧ f m = c := by
  by_contra h_contra;
  -- By assumption, each value in Fin (n+1) is hit finitely often by f.
  have h_finite : ∀ c : Fin (n + 1), Set.Finite {m : ℕ | f m = c} := by
    exact fun c => Set.not_infinite.mp fun hi => h_contra ⟨ c, fun N => by rcases hi.exists_gt N with ⟨ m, hm₁, hm₂ ⟩ ; exact ⟨ m, hm₂.le, hm₁ ⟩ ⟩;
  exact Set.infinite_univ <| Set.Finite.subset ( Set.Finite.biUnion ( Set.toFinite ( Finset.univ : Finset ( Fin ( n + 1 ) ) ) ) fun c _ => h_finite c ) fun x hx => by aesop;


theorem involution_odd_fixed_point (n : ℕ) (f : Fin (2 * n + 1) → Fin (2 * n + 1))
    (hf : ∀ x, f (f x) = x) : ∃ x, f x = x := by
  by_contra h;
  -- Since $f$ is an involution on a finite set, it must have an even number of elements in its domain.
  have h_even : Even (Finset.card (Finset.univ : Finset (Fin (2 * n + 1)))) := by
    -- Since $f$ is an involution, the set $Fin (2 * n + 1)$ can be partitioned into pairs $\{x, f(x)\}$.
    have h_partition : ∃ S : Finset (Finset (Fin (2 * n + 1))), (∀ s ∈ S, Finset.card s = 2) ∧ (∀ s ∈ S, ∀ t ∈ S, s ≠ t → Disjoint s t) ∧ (Finset.univ : Finset (Fin (2 * n + 1))) = Finset.biUnion S id := by
      refine' ⟨ Finset.image ( fun x => { x, f x } ) Finset.univ, _, _, _ ⟩ <;> simp_all +decide [ Finset.disjoint_left ];
      · exact fun x => Finset.card_pair ( Ne.symm ( h x ) );
      · grind +ring;
      · ext x; aesop;
    obtain ⟨ S, hS₁, hS₂, hS₃ ⟩ := h_partition; rw [ hS₃, Finset.card_biUnion ] <;> aesop;
  simp_all +decide [ Finset.card_univ ]

