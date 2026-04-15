/-! # CatalogBuild.Speculative.Forbidden.AlgorithmicEvil

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7
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

/-
PROBLEM
Ackermann base case computes correctly.

PROVIDED SOLUTION
Unfold ackermann. By definition, ackermann 0 n = n + 1.
-/

theorem ackermann_zero (n : ℕ) : ackermann 0 n = n + 1 := by
  -- By definition, we have `ackermann 1 m = ackermann (0+1) m = ackermann 0 1`.
  rw [ackermann]

/-
PROBLEM
A(1, n) = n + 2. Level 1 evil is just addition.

PROVIDED SOLUTION
By induction on n. Base: ackermann 1 0 = ackermann 0 1 = 2 = 0+2. Step: ackermann 1 (n+1) = ackermann 0 (ackermann 1 n) = ackermann 1 n + 1 = (n+2) + 1 = (n+1)+2 by IH.
-/

theorem ackermann_one (n : ℕ) : ackermann 1 n = n + 2 := by
  induction' n with n ih <;> simp +arith +decide [ *, ackermann ]

/-! ### The Pigeonhole Apocalypse

Any function from a larger finite type to a smaller one must have collisions.
This innocent fact powers: the birthday attack (cryptography), the pumping

lemma (formal languages), and Ramsey theory (combinatorics). -/

/-
PROBLEM
**The Pigeonhole Principle of Evil:**
    Inject n+2 pigeons into n+1 holes? Impossible. Someone shares a room.

PROVIDED SOLUTION
No injection from Fin (n+2) to Fin (n+1) because cardinality n+2 > n+1. Use Fintype.card_le_of_injective or Fin.injective_iff.
-/

theorem pigeonhole_evil (n : ℕ) (f : Fin (n + 2) → Fin (n + 1)) :
    ¬ Injective f := by
  exact fun h => absurd ( Fintype.card_le_of_injective f h ) ( by simp +arith +decide )

/-
PROBLEM
**The Birthday Paradox Setup:**
    In a group of n+1 people with only n possible birthdays,
    two people must share a birthday. Evil party planning.

PROVIDED SOLUTION
Since Fin (n+1) has n+1 elements and Fin n has n elements, f cannot be injective by pigeonhole. So there exist i ≠ j with f i = f j. Use Fintype.exists_ne_map_eq_of_card_lt or Function.not_injective.
-/

theorem infinite_pigeonhole (n : ℕ) (f : ℕ → Fin (n + 1)) :
    ∃ c : Fin (n + 1), ∀ N : ℕ, ∃ m : ℕ, m ≥ N ∧ f m = c := by
  by_contra h_contra;
  -- By assumption, each value in Fin (n+1) is hit finitely often by f.
  have h_finite : ∀ c : Fin (n + 1), Set.Finite {m : ℕ | f m = c} := by
    exact fun c => Set.not_infinite.mp fun hi => h_contra ⟨ c, fun N => by rcases hi.exists_gt N with ⟨ m, hm₁, hm₂ ⟩ ; exact ⟨ m, hm₂.le, hm₁ ⟩ ⟩;
  exact Set.infinite_univ <| Set.Finite.subset ( Set.Finite.biUnion ( Set.toFinite ( Finset.univ : Finset ( Fin ( n + 1 ) ) ) ) fun c _ => h_finite c ) fun x hx => by aesop;

/-! ### The Fixed Point Inevitability

Some maps MUST have fixed points. You cannot escape yourself. -/

/-
PROBLEM
**Involutions Have Fixed Points on Odd Sets:**
    An involution on `Fin (2*n+1)` must fix at least one element.
    If the universe has an odd number of elements and every element
    is paired, someone is left alone. Existential horror via parity.

PROVIDED SOLUTION
An involution partitions the set into fixed points and 2-cycles. Since 2*n+1 is odd and 2-cycles contribute even elements, the number of fixed points must be odd, hence nonzero.
-/

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

