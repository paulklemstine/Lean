import Mathlib

/-!
# A prefix-fractal language of truth values

A mathematical statement is represented only by its truth value, and an infinite theory by a
binary stream.  The predicate `LocallyConsistent` forbids two consecutive positive answers.
This is the golden-mean subshift, a canonical nontrivial closed subset of Cantor space.

Rather than importing a large theory of Hausdorff dimension, this file proves its decisive
combinatorial content: the number of inhabited cylinders at depth `n` is exactly `fib (n+2)`.
It also proves explicit exponential upper and lower bounds, certifying growth strictly between
constant and the full binary tree.
-/

namespace FractalTruth

/-- Finite truth patterns admitted by the local consistency rule. -/
def truthWords : ℕ → Finset (List Bool)
  | 0 => {[]}
  | 1 => {[false], [true]}
  | n + 2 =>
      (truthWords (n + 1)).image (fun w => false :: w) ∪
      (truthWords n).image (fun w => true :: false :: w)

/-
Every generated word has the advertised length.
-/
theorem length_mem_truthWords {n : ℕ} {w : List Bool} (h : w ∈ truthWords n) :
    w.length = n := by
  induction' n using Nat.strong_induction_on with n ih generalizing w;
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ truthWords ];
  · aesop;
  · grind

/-
The two branches in the recursive construction are disjoint.
-/
theorem truthWords_branch_disjoint (n : ℕ) :
    Disjoint
      ((truthWords (n + 1)).image (fun w => false :: w))
      ((truthWords n).image (fun w => true :: false :: w)) := by
  -- The lists in the first image start with `false`, while those in the second image start with `true`. Hence, they can't be the same list, so their intersection is empty.
  simp [Finset.disjoint_left, Finset.mem_image]

/-
Exact cylinder-count recurrence for the truth language.
-/
theorem card_truthWords_rec (n : ℕ) :
    (truthWords (n + 2)).card = (truthWords (n + 1)).card + (truthWords n).card := by
  rw [ show truthWords ( n + 2 ) = ( truthWords ( n + 1 ) |> Finset.image ( fun w => false :: w ) ) ∪ ( truthWords n |> Finset.image ( fun w => true :: false :: w ) ) by rfl, Finset.card_union_of_disjoint ];
  · rw [ Finset.card_image_of_injective, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
  · -- The two branches in the recursive construction are disjoint because they start with different truth values.
    apply truthWords_branch_disjoint

/-
Main theorem: the number of depth-`n` truth cylinders is Fibonacci.
-/
theorem card_truthWords (n : ℕ) : (truthWords n).card = Nat.fib (n + 2) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
  rw [ card_truthWords_rec, ih _ ( Nat.le_succ _ ), ih _ ( Nat.le_refl _ ) ] ; simp +arith +decide [ Nat.fib_add_two ]

/-- Prefix agreement is the scale relation underlying the usual Cantor ultrametric. -/
def AgreeTo (n : ℕ) (x y : ℕ → Bool) : Prop := ∀ k < n, x k = y k

@[refl] theorem agreeTo_refl (n : ℕ) (x : ℕ → Bool) : AgreeTo n x x := by
  exact fun k hk => rfl

@[symm] theorem agreeTo_symm {n : ℕ} {x y : ℕ → Bool} (h : AgreeTo n x y) :
    AgreeTo n y x := by
  exact fun k hk => Eq.symm ( h k hk )

@[trans] theorem agreeTo_trans {n : ℕ} {x y z : ℕ → Bool}
    (hxy : AgreeTo n x y) (hyz : AgreeTo n y z) : AgreeTo n x z := by
  exact fun k hk => hxy k hk ▸ hyz k hk ▸ rfl

/-
Agreement balls are nested as their depth increases.
-/
theorem agreeTo_anti {m n : ℕ} (hmn : m ≤ n) {x y : ℕ → Bool}
    (h : AgreeTo n x y) : AgreeTo m x y := by
  exact fun k hk => h k <| lt_of_lt_of_le hk hmn

/-- A stream satisfying the local truth rule. -/
def LocallyConsistent (x : ℕ → Bool) : Prop := ∀ k, ¬(x k = true ∧ x (k + 1) = true)

/-
A finite generated word extends to an infinite locally consistent stream.
-/
theorem truthWord_has_consistent_extension {n : ℕ} {w : List Bool}
    (hw : w ∈ truthWords n) :
    ∃ x : ℕ → Bool, LocallyConsistent x ∧
      ∀ (k : ℕ) (hk : k < n), x k = w[k]'(by rw [length_mem_truthWords hw]; exact hk) := by
  revert hw;
  induction' n using Nat.strong_induction_on with n ih generalizing w;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ truthWords ];
  · exact fun h => ⟨ fun _ => Bool.false, fun _ => by simp +decide ⟩;
  · rintro ( rfl | rfl ) <;> [ exact ⟨ fun _ => false, fun k => by aesop, fun k hk => by aesop ⟩ ; exact ⟨ fun n => if n = 0 then true else false, fun n => by aesop, fun n hn => by aesop ⟩ ];
  · rintro ( ⟨ a, ha, rfl ⟩ | ⟨ a, ha, rfl ⟩ );
    · obtain ⟨ x, hx₁, hx₂ ⟩ := ih _ le_rfl ha;
      refine' ⟨ fun k => if k = 0 then false else x ( k - 1 ), _, _ ⟩ <;> simp_all +decide [ LocallyConsistent ];
      · grind;
      · rintro ( _ | k ) <;> simp +decide;
    · obtain ⟨ x, hx₁, hx₂ ⟩ := ih n ( by linarith ) ha;
      refine' ⟨ fun k => if k = 0 then true else if k = 1 then false else x ( k - 2 ), _, _ ⟩ <;> simp_all +decide [ LocallyConsistent ]; all_goals grind

/-
Fibonacci growth is at most that of all binary words.
-/
theorem fib_two_le_pow_two (n : ℕ) : Nat.fib (n + 2) ≤ 2 ^ n := by
  induction' n with n ih;
  · decide +revert;
  · simp +arith +decide [ Nat.fib_add_two, pow_succ' ] at * ; linarith

/-
After the first level, the truth language is genuinely sparse among all binary words.
-/
theorem card_truthWords_lt_full {n : ℕ} (hn : 2 ≤ n) :
    (truthWords n).card < 2 ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases hn with ( _ | _ | n ) <;> simp_all +arith +decide [ card_truthWords_rec ];
  grind

/-
The language is nevertheless exponentially large: its count dominates `2^(n/2)`.
-/
theorem pow_half_le_fib (n : ℕ) : 2 ^ (n / 2) ≤ Nat.fib (n + 2) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp +arith +decide [ Nat.pow_succ', Nat.fib_add_two ] at *;
  grind

/-
A fully explicit certificate that truth-pattern growth is sparse but non-negligible.
-/
theorem intermediate_fractal_growth {n : ℕ} (hn : 2 ≤ n) :
    2 ^ (n / 2) ≤ (truthWords n).card ∧ (truthWords n).card < 2 ^ n := by
  exact ⟨ by simpa only [ card_truthWords ] using pow_half_le_fib n, by simpa only [ card_truthWords ] using card_truthWords_lt_full hn ⟩

/-
The density among all depth-`n` cylinders contracts by a fixed factor every two levels.
-/
theorem two_step_density_contraction (n : ℕ) :
    2 ^ n * (truthWords (n + 2)).card ≤ 3 * (2 ^ n * (truthWords n).card) := by
  rw [ card_truthWords, card_truthWords ];
  induction n <;> norm_num [ Nat.fib_add_two, pow_succ' ] at * ; nlinarith [ pow_pos ( zero_lt_two' ℕ ) ‹_› ]

/-- The entropy (and standard box dimension) of the golden-mean truth language. -/
noncomputable def truthDimension : ℝ := Real.log Real.goldenRatio / Real.log 2

/-
The truth language has dimension strictly between zero and one.
-/
theorem truthDimension_strict : 0 < truthDimension ∧ truthDimension < 1 := by
  unfold truthDimension;
  exact ⟨ div_pos ( Real.log_pos ( by rw [ Real.goldenRatio ] ; nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ) ) ( Real.log_pos ( by norm_num ) ), by rw [ div_lt_one ( Real.log_pos ( by norm_num ) ) ] ; exact Real.log_lt_log ( by rw [ Real.goldenRatio ] ; nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ) ( by rw [ Real.goldenRatio ] ; nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ) ⟩

end FractalTruth