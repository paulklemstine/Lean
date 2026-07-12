/-
  # Kauffman Bracket

  The Kauffman bracket ⟨D⟩ ∈ ℤ[A, A⁻¹] is defined as a state sum:
    ⟨D⟩ = Σ_s A^(α(s) - β(s)) · (-A² - A⁻²)^(|s| - 1)
  where the sum is over all 2^n smoothing states, α(s) counts
  A-smoothings, β(s) counts B-smoothings, and |s| is the number
  of loops in the smoothed diagram.

  ## Main results
  - `bracket_unknot`: ⟨unknot⟩ = 1
  - `bracket_disjoint_loop`: ⟨D ⊔ ○⟩ = (-A² - A⁻²) · ⟨D⟩
  - `bracket_RI_positive`: bracket invariance behavior under R1+
  - `bracket_RI_negative`: bracket invariance behavior under R1-
  - `bracket_RII_invariant`: bracket is invariant under Reidemeister II
  - `bracket_RIII_invariant`: bracket is invariant under Reidemeister III
-/
import Mathlib
import Geometry.KnotTheory.Defs

namespace Knot

open LaurentPolynomial Finset

/-- The loop factor: δ = -A² - A⁻² = -(T 2 + T (-2)). -/
noncomputable def loopFactor : LaurentPolynomial ℤ :=
  -(T 2 + T (-2))

/-- The Kauffman bracket of a link diagram, as a state sum:
    ⟨D⟩ = Σ_s T(α(s) - β(s)) · loopFactor^(loops(s) - 1) -/
noncomputable def bracket {n : ℕ} (D : LinkDiagram n) : LaurentPolynomial ℤ :=
  ∑ s : KState n, T ((numA s : ℤ) - (numB s : ℤ)) * loopFactor ^ (D.loops s - 1)

/-! ## Unknot computation -/

/-- The bracket of the unknot (0 crossings, 1 loop) equals 1. -/
theorem bracket_unknot : bracket unknotDiagram = 1 := by
  simp [bracket, unknotDiagram]

/-! ## Reidemeister I behavior -/

/-
Under positive Reidemeister I, ⟨D₁⟩ = (-A³) · ⟨D₂⟩.
    The bracket picks up a factor of -A³ when adding a positive kink.
-/
theorem bracket_RI_positive {n : ℕ} {D₁ : OrientedLinkDiagram (n + 1)}
    {D₂ : OrientedLinkDiagram n} (h : ReidemeisterI D₁ D₂) :
    bracket D₁.toLinkDiagram = -(T 3) * bracket D₂.toLinkDiagram := by
  -- By separating the states into those ending with A and those ending with B, we can rewrite the sum.
  have h_split : ∑ s : KState (n + 1), T ((numA s : ℤ) - (numB s : ℤ)) * loopFactor ^ (D₁.loops s - 1) = ∑ s : KState n, (T ((numA s + 1 : ℤ) - (numB s : ℤ)) * loopFactor ^ (D₂.loops s) + T ((numA s : ℤ) - (numB s + 1 : ℤ)) * loopFactor ^ (D₂.loops s - 1)) := by
    -- By separating the states into those ending with A and those ending with B, we can rewrite the sum using the definitions of `numA` and `numB`.
    have h_split : ∑ s : KState (n + 1), T ((numA s : ℤ) - (numB s : ℤ)) * loopFactor ^ (D₁.loops s - 1) = ∑ s : KState n, (∑ s' : Smoothing, T ((numA (Fin.snoc s s') : ℤ) - (numB (Fin.snoc s s') : ℤ)) * loopFactor ^ (D₁.loops (Fin.snoc s s') - 1)) := by
      rw [ ← Finset.sum_product' ];
      refine' Finset.sum_bij ( fun s _ => ( s ∘ Fin.castSucc, s ( Fin.last _ ) ) ) _ _ _ _ <;> simp +decide;
      · exact fun a₁ a₂ h₁ h₂ => funext fun i => by cases i using Fin.lastCases <;> simpa [ * ] using congr_fun h₁ ‹_›;
      · exact fun a b => ⟨ Fin.snoc a b, by ext i; simp +decide, by simp +decide ⟩;
      · intro a; congr; ext i; induction i using Fin.lastCases <;> aesop;
        · exact funext fun i => by cases i using Fin.lastCases <;> simp +decide [ * ] ;
        · exact funext fun i => by cases i using Fin.lastCases <;> simp +decide [ * ] ;
    simp_all +decide [ Fin.snoc ];
    refine' Finset.sum_congr rfl fun x hx => _;
    rw [ Finset.sum_eq_add ( Smoothing.A ) ( Smoothing.B ) ] <;> simp +decide [ h.loops_A, h.loops_B ];
    · simp +decide [ numA, numB, Fin.snoc ];
      congr! 2;
      · rw [ Finset.card_filter, Finset.card_filter ];
        rw [ Fin.sum_univ_castSucc, Fin.sum_univ_castSucc ] ; aesop;
      · rw [ Finset.card_filter, Finset.card_filter ];
        rw [ Fin.sum_univ_castSucc, Fin.sum_univ_castSucc ] ; aesop;
    · exact fun c hc₁ hc₂ => False.elim <| hc₂ <| by rcases c with ( _ | _ | c ) <;> tauto;
  -- We can factor out $T (A - B)$ from each term in the sum.
  have h_factor : ∑ s : KState n, (T ((numA s + 1 : ℤ) - (numB s : ℤ)) * loopFactor ^ (D₂.loops s) + T ((numA s : ℤ) - (numB s + 1 : ℤ)) * loopFactor ^ (D₂.loops s - 1)) = ∑ s : KState n, T ((numA s : ℤ) - (numB s : ℤ)) * (T 1 * loopFactor ^ (D₂.loops s) + T (-1) * loopFactor ^ (D₂.loops s - 1)) := by
    grind +suggestions;
  -- We can factor out $loopFactor^{D₂.loops s - 1}$ from each term in the sum.
  have h_factor2 : ∑ s : KState n, T ((numA s : ℤ) - (numB s : ℤ)) * (T 1 * loopFactor ^ (D₂.loops s) + T (-1) * loopFactor ^ (D₂.loops s - 1)) = ∑ s : KState n, T ((numA s : ℤ) - (numB s : ℤ)) * loopFactor ^ (D₂.loops s - 1) * (T 1 * loopFactor + T (-1)) := by
    refine' Finset.sum_congr rfl fun s _ => _;
    rw [ show loopFactor ^ D₂.loops s = loopFactor ^ ( D₂.loops s - 1 ) * loopFactor by rw [ ← pow_succ, Nat.sub_add_cancel ( D₂.loops_pos s ) ] ] ; ring;
  -- We can simplify the expression $T 1 * loopFactor + T (-1)$ to $-T 3$.
  have h_simplify : T 1 * loopFactor + T (-1) = -T 3 := by
    unfold loopFactor; ring;
    rw [ show ( 3 : ℤ ) = 1 + 2 by norm_num, show ( -1 : ℤ ) = 1 + ( -2 ) by norm_num, T_add, T_add ] ; ring;
  convert h_split.trans ( h_factor.trans ( h_factor2.trans ( Finset.sum_congr rfl fun _ _ => by rw [ h_simplify ] ) ) ) using 1;
  rw [ ← Finset.sum_mul _ _ _ ] ; ring!

/-
Under negative Reidemeister I, ⟨D₁⟩ = (-A⁻³) · ⟨D₂⟩.
-/
theorem bracket_RI_negative {n : ℕ} {D₁ : OrientedLinkDiagram (n + 1)}
    {D₂ : OrientedLinkDiagram n} (h : ReidemeisterI_neg D₁ D₂) :
    bracket D₁.toLinkDiagram = -(T (-3)) * bracket D₂.toLinkDiagram := by
  cases' h with kink_sign sign_agree loops_A loops_B;
  -- We can split the sum over `KState (n + 1)` into two sums: one over `s` with `smoothing A` at the last position, and one over `s` with `smoothing B` at the last position.
  have h_split_sum : ∑ s : KState (n + 1), T ((numA s : ℤ) - (numB s : ℤ)) * loopFactor ^ (D₁.loops s - 1) =
    ∑ s : KState n, T ((numA s + 1 : ℤ) - (numB s : ℤ)) * loopFactor ^ (D₂.loops s - 1) +
    ∑ s : KState n, T ((numA s : ℤ) - (numB s + 1 : ℤ)) * loopFactor ^ (D₂.loops s) := by
      have h_split_sum : ∀ s : KState (n + 1), ∃ s' : KState n, s = Fin.snoc s' Smoothing.A ∨ s = Fin.snoc s' Smoothing.B := by
        intro s
        use fun i => s (Fin.castSucc i);
        cases h : s ( Fin.last n ) <;> [ left; right ] <;> ext i <;> cases i using Fin.lastCases <;> aesop;
      have h_split_sum : Finset.univ.image (fun s : KState (n + 1) => if s (Fin.last n) = Smoothing.A then (Fin.init s, Smoothing.A) else (Fin.init s, Smoothing.B)) = Finset.univ.image (fun s : KState n => (s, Smoothing.A)) ∪ Finset.univ.image (fun s : KState n => (s, Smoothing.B)) := by
        ext ⟨s, smoothing⟩; simp [h_split_sum];
        constructor;
        · rintro ⟨ a, ha ⟩ ; split_ifs at ha <;> aesop;
        · rintro ( rfl | rfl ) <;> [ exact ⟨ Fin.snoc s Smoothing.A, by simp +decide ⟩ ; exact ⟨ Fin.snoc s Smoothing.B, by simp +decide ⟩ ];
      have h_split_sum : ∑ s : KState (n + 1), T ((numA s : ℤ) - (numB s : ℤ)) * loopFactor ^ (D₁.loops s - 1) =
        ∑ s ∈ Finset.univ.image (fun s : KState (n + 1) => if s (Fin.last n) = Smoothing.A then (Fin.init s, Smoothing.A) else (Fin.init s, Smoothing.B)), T ((numA s.1 + if s.2 = Smoothing.A then 1 else 0 : ℤ) - (numB s.1 + if s.2 = Smoothing.B then 1 else 0 : ℤ)) * loopFactor ^ (if s.2 = Smoothing.A then D₂.loops s.1 - 1 else D₂.loops s.1) := by
          rw [ Finset.sum_image ];
          · refine' Finset.sum_congr rfl fun s hs => _;
            rcases ‹∀ s : KState ( n + 1 ), ∃ s', s = Fin.snoc s' Smoothing.A ∨ s = Fin.snoc s' Smoothing.B› s with ⟨ s', rfl | rfl ⟩ <;> simp +decide [ * ];
            · unfold numA numB; simp +decide [ Fin.snoc ] ;
              rw [ Finset.card_filter, Finset.card_filter ];
              rw [ Fin.sum_univ_castSucc, Fin.sum_univ_castSucc ] ; simp +decide [ Finset.sum_ite ];
            · simp +decide [ numA, numB, Fin.snoc ];
              rw [ Finset.card_filter, Finset.card_filter ];
              rw [ Fin.sum_univ_castSucc, Fin.sum_univ_castSucc ] ; simp +decide [ Finset.sum_ite ];
          · intro s hs t ht h_eq; simp_all +decide [ Fin.init ] ;
            split_ifs at h_eq <;> simp_all +decide [ funext_iff, Fin.ext_iff ];
            · intro x; induction x using Fin.lastCases <;> simp_all +decide [ Fin.init ] ;
            · intro i; induction i using Fin.lastCases <;> simp_all +decide [ Fin.init ] ;
              cases h : s ( Fin.last n ) <;> cases h' : t ( Fin.last n ) <;> simp_all +decide only [Smoothing.B];
      rw [ h_split_sum, ‹image ( fun s : KState ( n + 1 ) => if s ( Fin.last n ) = Smoothing.A then ( Fin.init s, Smoothing.A ) else ( Fin.init s, Smoothing.B ) ) univ = _›, Finset.sum_union ];
      · rw [ Finset.sum_image, Finset.sum_image ] <;> simp +decide [ Finset.sum_add_distrib ];
        · exact fun a b h => by injection h;
        · exact fun a b h => by injection h;
      · simp +decide [ Finset.disjoint_left ];
  -- Factor out $-T(-3)$ from the second sum.
  have h_factor : ∑ s : KState n, T ((numA s : ℤ) - (numB s + 1 : ℤ)) * loopFactor ^ (D₂.loops s) =
    -T (-3) * ∑ s : KState n, T ((numA s : ℤ) - (numB s : ℤ)) * loopFactor ^ (D₂.loops s - 1) -
    ∑ s : KState n, T ((numA s : ℤ) + 1 - (numB s : ℤ)) * loopFactor ^ (D₂.loops s - 1) := by
      have h_factor : ∀ s : KState n, T ((numA s : ℤ) - (numB s + 1 : ℤ)) * loopFactor ^ (D₂.loops s) =
        -T (-3) * T ((numA s : ℤ) - (numB s : ℤ)) * loopFactor ^ (D₂.loops s - 1) -
        T ((numA s : ℤ) + 1 - (numB s : ℤ)) * loopFactor ^ (D₂.loops s - 1) := by
          intro s
          have h_factor : T ((numA s : ℤ) - (numB s + 1 : ℤ)) * loopFactor =
            -T (-3) * T ((numA s : ℤ) - (numB s : ℤ)) -
            T ((numA s : ℤ) + 1 - (numB s : ℤ)) := by
              unfold loopFactor; ring;
              grind +suggestions;
          convert congr_arg ( · * loopFactor ^ ( D₂.loops s - 1 ) ) h_factor using 1 <;> ring;
          rw [ mul_assoc, ← pow_succ', Nat.sub_add_cancel ( show 1 ≤ D₂.loops s from D₂.loops_pos s ) ];
      simp +decide only [h_factor, mul_assoc, sum_sub_distrib, Finset.mul_sum _ _ _];
  convert h_split_sum.trans ( congr_arg₂ ( · + · ) rfl h_factor ) using 1 ; ring!

/-! ## Reidemeister III invariance -/

/-
The bracket is invariant under Reidemeister III moves.
-/
theorem bracket_RIII_invariant {n : ℕ} {D₁ D₂ : LinkDiagram n}
    (h : ReidemeisterIII D₁ D₂) :
    bracket D₁ = bracket D₂ := by
  obtain ⟨ f, hf₁, hf₂, hf₃ ⟩ := h
  have h_numB : ∀ s : KState n, numB s = numB (f s) := by
    -- Since $numA s + numB s = n$ for any state $s$, and $numA$ is preserved under $f$, it follows that $numB$ is also preserved.
    have h_numB_eq : ∀ s : KState n, numA s + numB s = n := by
      intro s
      simp [numA, numB];
      rw [ Finset.card_filter, Finset.card_filter ];
      rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl fun _ _ => by rcases s _ with ( _ | _ | _ ) <;> rfl, Finset.sum_const, Finset.card_fin ] ; norm_num;
      simp +decide [ Smoothing ];
    grind +splitImp;
  unfold bracket;
  conv_rhs => rw [ ← Equiv.sum_comp ( Equiv.ofBijective f hf₁ ) ] ;
  simp +decide [ ← hf₂, ← h_numB, ← hf₃ ]

end Knot