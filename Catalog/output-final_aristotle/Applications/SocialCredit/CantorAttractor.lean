import Mathlib

/-!
# Credit Scores Condense onto a Cantor-Set Attractor

We refine the model of `FixedPoint.lean`.  Suppose that at each generation a
member's credit is decided by a binary *verdict* (`true` = commended,
`false` = flagged), and that generation `n` contributes to the final score with
weight `2 / 3^{n+1}` — later verdicts matter less, and the base-`3` gaps encode
the "no man's land" between the commended and flagged basins.  The resulting
score of an infinite verdict history `a : ℕ → Bool` is

`cantorEnc a = ∑' n, (if a n then 2 else 0) / 3^{n+1}`.

This is exactly the standard ternary parametrisation of the **middle-thirds
Cantor set**.  We prove:

* every score lies in `[0,1]` (`cantorEnc_mem_Icc`);
* the **self-similarity / IFS fixed-point equation** of the attractor:
  prefixing a `false` verdict rescales the score by `x ↦ x/3`, prefixing `true`
  by `x ↦ x/3 + 2/3` (`cantorEnc_scons_false`, `cantorEnc_scons_true`), whence
  the set of all attainable scores `C` satisfies `C = (C/3) ∪ (C/3 + 2/3)`
  (`cantorSet_self_similar`);
* the encoding is **injective** (`cantorEnc_injective`): distinct verdict
  histories give distinct scores, so the attractor carries the full information
  of the Cantor space `2^ℕ` and is in particular uncountable.

The disjoint self-similar pieces `[0,1/3]` and `[2/3,1]` are the reason
*infinitesimally small changes* to an early verdict move a score across a gap:
the "phase-transition" theme is developed in `PhaseTransition.lean`.
-/

open Filter Topology

namespace SocialCredit

/-- The ternary weight of the `n`-th verdict. -/
noncomputable def verdictWeight (a : ℕ → Bool) (n : ℕ) : ℝ :=
  (if a n then (2 : ℝ) else 0) / 3 ^ (n + 1)

/-- The credit score of an infinite verdict history. -/
noncomputable def cantorEnc (a : ℕ → Bool) : ℝ := ∑' n, verdictWeight a n

/-- Prepend a verdict `b` to a history `a` (shifting the rest one generation
later). -/
def scons (b : Bool) (a : ℕ → Bool) : ℕ → Bool
  | 0 => b
  | (k + 1) => a k

@[simp] theorem scons_zero (b : Bool) (a : ℕ → Bool) : scons b a 0 = b := rfl

@[simp] theorem scons_succ (b : Bool) (a : ℕ → Bool) (k : ℕ) :
    scons b a (k + 1) = a k := rfl

/-
Every history is its head prepended to its tail.
-/
theorem scons_eta (a : ℕ → Bool) : scons (a 0) (fun n => a (n + 1)) = a := by
  exact funext fun n => by cases n <;> rfl;

/-! ## Basic bounds -/

theorem verdictWeight_summable (a : ℕ → Bool) : Summable (verdictWeight a) := by
  refine' .of_nonneg_of_le ( fun n => _ ) ( fun n => _ ) ( summable_geometric_of_lt_one ( by norm_num ) ( by norm_num : ( 1 : ℝ ) / 3 < 1 ) |> Summable.mul_left 2 );
  · exact div_nonneg ( by split_ifs <;> norm_num ) ( by positivity );
  · unfold verdictWeight; split_ifs <;> ring_nf <;> norm_num

theorem cantorEnc_nonneg (a : ℕ → Bool) : 0 ≤ cantorEnc a := by
  exact tsum_nonneg fun n => by unfold verdictWeight; positivity;

theorem cantorEnc_le_one (a : ℕ → Bool) : cantorEnc a ≤ 1 := by
  -- The sum of the geometric series $\sum_{n=0}^{\infty} \frac{2}{3^{n+1}}$ is $\frac{2}{3} \sum_{n=0}^{\infty} \left(\frac{1}{3}\right)^n = \frac{2}{3} \cdot \frac{1}{1 - \frac{1}{3}} = \frac{2}{3} \cdot \frac{3}{2} = 1$.
  have h_geo_series : ∑' n, (2 : ℝ) / 3^(n+1) = 1 := by
    ring_nf;
    rw [ tsum_mul_right, tsum_geometric_of_lt_one ] <;> norm_num;
  refine' le_trans ( Summable.tsum_le_tsum ( fun n => _ ) ( verdictWeight_summable a ) ( _ ) ) h_geo_series.le;
  · unfold verdictWeight; split_ifs <;> ring_nf <;> norm_num;
  · exact ( by contrapose! h_geo_series; erw [ tsum_eq_zero_of_not_summable h_geo_series ] ; norm_num )

theorem cantorEnc_mem_Icc (a : ℕ → Bool) : cantorEnc a ∈ Set.Icc (0 : ℝ) 1 :=
  ⟨cantorEnc_nonneg a, cantorEnc_le_one a⟩

/-! ## Self-similarity (the IFS fixed-point equation) -/

/-
Prepending a `false` verdict rescales the score by `x ↦ x / 3`.
-/
theorem cantorEnc_scons_false (a : ℕ → Bool) :
    cantorEnc (scons false a) = cantorEnc a / 3 := by
  convert ( Summable.tsum_eq_zero_add ( verdictWeight_summable ( scons false a ) ) ) using 1 ; norm_num [ scons_zero, scons_succ, cantorEnc, verdictWeight ];
  rw [ ← tsum_div_const ] ; congr ; ext n ; ring

/-
Prepending a `true` verdict rescales the score by `x ↦ x / 3 + 2/3`.
-/
theorem cantorEnc_scons_true (a : ℕ → Bool) :
    cantorEnc (scons true a) = cantorEnc a / 3 + 2 / 3 := by
  unfold cantorEnc;
  rw [ Summable.tsum_eq_zero_add ];
  · unfold verdictWeight;
    norm_num [ pow_succ, ← div_div, tsum_div_const ] ; ring!;
  · exact verdictWeight_summable _

/-
**Self-similar attractor.**  The set `C` of all attainable credit scores is
the union of two scaled copies of itself:
`C = (x ↦ x/3)'' C ∪ (x ↦ x/3 + 2/3)'' C`.  This is the defining fixed-point
equation of the middle-thirds Cantor set under its iterated function system.
-/
theorem cantorSet_self_similar :
    Set.range cantorEnc =
      (fun x => x / 3) '' Set.range cantorEnc ∪
      (fun x => x / 3 + 2 / 3) '' Set.range cantorEnc := by
  apply Set.eq_of_subset_of_subset;
  · intro y hy; obtain ⟨ a, rfl ⟩ := hy; by_cases h : a 0 = true <;> simp +decide [ *, Set.mem_union, Set.mem_image ] ;
    · refine Or.inr ⟨ fun n => a ( n + 1 ), ?_ ⟩;
      convert cantorEnc_scons_true ( fun n => a ( n + 1 ) ) |> Eq.symm using 1;
      exact congr_arg _ ( funext fun n => by cases n <;> simp +decide [ h, scons ] );
    · exact Or.inl ⟨ fun n => a ( n + 1 ), by rw [ ← cantorEnc_scons_false ] ; congr; ext n; cases n <;> aesop ⟩;
  · rintro _ ( ⟨ x, ⟨ a, rfl ⟩, rfl ⟩ | ⟨ x, ⟨ a, rfl ⟩, rfl ⟩ ) <;> [ exact ⟨ _, cantorEnc_scons_false a ⟩ ; exact ⟨ _, cantorEnc_scons_true a ⟩ ]

/-! ## Injectivity -/

/-
The head verdict is determined by the score: a `false` head keeps the score
in `[0,1/3]`, a `true` head forces it into `[2/3,1]`.
-/
theorem cantorEnc_head_eq {a b : ℕ → Bool} (h : cantorEnc a = cantorEnc b) :
    a 0 = b 0 := by
  cases h' : a 0 <;> cases h'' : b 0 <;> simp_all +decide only;
  · -- By definition of `cantorEnc`, we have `cantorEnc a = cantorEnc (scons false (fun n => a (n + 1)))` and `cantorEnc b = cantorEnc (scons true (fun n => b (n + 1)))`.
    have h_eq : cantorEnc a = cantorEnc (scons false (fun n => a (n + 1))) ∧ cantorEnc b = cantorEnc (scons true (fun n => b (n + 1))) := by
      exact ⟨ congr_arg _ ( scons_eta a ▸ h'.symm ▸ rfl ), congr_arg _ ( scons_eta b ▸ h''.symm ▸ rfl ) ⟩;
    linarith [ cantorEnc_scons_false ( fun n => a ( n + 1 ) ), cantorEnc_scons_true ( fun n => b ( n + 1 ) ), cantorEnc_nonneg ( fun n => a ( n + 1 ) ), cantorEnc_le_one ( fun n => a ( n + 1 ) ), cantorEnc_nonneg ( fun n => b ( n + 1 ) ), cantorEnc_le_one ( fun n => b ( n + 1 ) ) ];
  · -- By definition of $cantorEnc$, we have $cantorEnc a = cantorEnc (scons true (fun n => a (n + 1)))$ and $cantorEnc b = cantorEnc (scons false (fun n => b (n + 1)))$.
    have h_cantorEnc_a : cantorEnc a = cantorEnc (scons true (fun n => a (n + 1))) := by
      exact congr_arg _ ( funext fun n => by cases n <;> simp +decide [ *, scons ] )
    have h_cantorEnc_b : cantorEnc b = cantorEnc (scons false (fun n => b (n + 1))) := by
      exact congr_arg _ ( funext fun n => by cases n <;> simp +decide [ *, scons ] );
    linarith [ cantorEnc_scons_true ( fun n => a ( n + 1 ) ), cantorEnc_scons_false ( fun n => b ( n + 1 ) ), cantorEnc_nonneg ( fun n => a ( n + 1 ) ), cantorEnc_le_one ( fun n => a ( n + 1 ) ), cantorEnc_nonneg ( fun n => b ( n + 1 ) ), cantorEnc_le_one ( fun n => b ( n + 1 ) ) ]

/-
Equal scores with equal heads force equal tails.
-/
theorem cantorEnc_tail_eq {a b : ℕ → Bool} (h : cantorEnc a = cantorEnc b) :
    cantorEnc (fun n => a (n + 1)) = cantorEnc (fun n => b (n + 1)) := by
  -- By `cantorEnc_head_eq h`, `a 0 = b 0`.
  have h_head : a 0 = b 0 := cantorEnc_head_eq h
  cases h : a 0 <;> simp_all +decide;
  · have h_eq : cantorEnc a = cantorEnc (scons false (fun n => a (n + 1))) ∧ cantorEnc b = cantorEnc (scons false (fun n => b (n + 1))) := by
      exact ⟨ congr_arg _ ( scons_eta a ▸ by aesop ), congr_arg _ ( scons_eta b ▸ by aesop ) ⟩;
    linarith [ cantorEnc_scons_false ( fun n => a ( n + 1 ) ), cantorEnc_scons_false ( fun n => b ( n + 1 ) ) ];
  · -- Using `scons_eta`, rewrite `cantorEnc a = cantorEnc (scons (a 0) (fun n => a (n+1)))` and similarly for `b`.
    have h_rewrite : cantorEnc a = cantorEnc (scons true (fun n => a (n + 1))) ∧ cantorEnc b = cantorEnc (scons true (fun n => b (n + 1))) := by
      exact ⟨ congr_arg _ ( scons_eta a ▸ by aesop ), congr_arg _ ( scons_eta b ▸ by aesop ) ⟩;
    linarith [ cantorEnc_scons_true ( fun n => a ( n + 1 ) ), cantorEnc_scons_true ( fun n => b ( n + 1 ) ) ]

/-
Coordinatewise determinacy, proved by induction on the coordinate index.
-/
theorem cantorEnc_coord_eq (n : ℕ) {a b : ℕ → Bool}
    (h : cantorEnc a = cantorEnc b) : a n = b n := by
  induction' n using Nat.case_strong_induction_on with n ih generalizing a b;
  · grind +suggestions;
  · convert ih n le_rfl ( cantorEnc_tail_eq h ) using 1

/-
**The credit encoding is injective.**  Distinct verdict histories yield
distinct scores, so the attractor is in bijection with the Cantor space `2^ℕ`
and hence uncountable.
-/
theorem cantorEnc_injective : Function.Injective cantorEnc := by
  intro a b h;
  exact funext fun n => cantorEnc_coord_eq n h

end SocialCredit