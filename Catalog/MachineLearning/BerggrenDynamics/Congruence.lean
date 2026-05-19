import Mathlib
import Speculative.BerggrenDynamics.Defs
import Speculative.BerggrenDynamics.Growth

/-!
# Berggren Tree: Congruence Properties

We prove that all hypotenuses in the Berggren tree satisfy specific congruence
conditions. In particular, all hypotenuses are odd, and more precisely
congruent to 1 modulo 4.

These results are the first steps toward the full residue equidistribution
theory for the Berggren semigroup action modulo arbitrary odd moduli.
-/

set_option maxHeartbeats 800000

namespace BerggrenDynamics

/-! ## Hypotenuse parity -/

/-- The root hypotenuse 5 is odd. -/
theorem root_hyp_odd : Odd (hyp root) := ⟨2, by simp [root, hyp]⟩

/-
Every generator preserves oddness of the hypotenuse when the input triple
    has components with appropriate parity. More precisely, if a²+b²=c² and
    c is odd, then each child's hypotenuse is also odd.
-/
theorem child_hyp_odd {a b c : ℤ} (_hpyth : a ^ 2 + b ^ 2 = c ^ 2)
    (hodd : Odd c) (g : BerggrenGen) :
    Odd (berggrenChild g (a, b, c)).2.2 := by
  unfold berggrenChild;
  grind

/-
All hypotenuses in the Berggren tree are odd.
    Proof: the root has c=5 (odd), and each generator preserves oddness.
-/
theorem word_hyp_odd (w : List BerggrenGen) : Odd (hyp (evalWord w)) := by
  -- By induction on the length of the word w, we can show that the hypotenuse of the evaluated word is odd.
  have h_ind : ∀ w : List BerggrenGen, Odd (hyp (evalWord w)) := by
    intro w
    induction' w using List.reverseRecOn with g w ih;
    · exact root_hyp_odd;
    · -- By definition of `evalWord`, we have `evalWord (g ++ [w]) = berggrenChild w (evalWord g)`.
      have h_evalWord_append : evalWord (g ++ [w]) = berggrenChild w (evalWord g) := by
        unfold evalWord; aesop;
      -- By definition of `child_hyp_odd`, we know that `berggrenChild w (evalWord g)` has an odd hypotenuse.
      have h_child_hyp_odd : Odd (hyp (berggrenChild w (evalWord g))) := by
        apply child_hyp_odd;
        · exact word_bounds ( show 3 ^ 2 + 4 ^ 2 = 5 ^ 2 by decide ) ( by decide ) ( by decide ) ( by decide ) g |>.2.2.2.2.2;
        · exact ih;
      exact h_evalWord_append ▸ h_child_hyp_odd;
  exact h_ind _

/-! ## Hypotenuse modulo 4 -/

/-
For a primitive Pythagorean triple (a,b,c) with a²+b²=c², exactly one of
    a, b is even and c is always odd. If c ≡ 1 mod 4, each Berggren child
    also has c' ≡ 1 mod 4.
-/
theorem child_hyp_mod4 {a b c : ℤ}
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2)
    (hmod : c % 4 = 1) (g : BerggrenGen) :
    (berggrenChild g (a, b, c)).2.2 % 4 = 1 := by
  have := congr_arg ( · % 4 ) hpyth; norm_num [ sq, Int.add_emod, Int.mul_emod, hmod ] at this;
  fin_cases g <;> unfold berggrenChild <;> norm_num [ Int.add_emod, Int.sub_emod, Int.mul_emod, hmod ];
  · have := Int.emod_nonneg a four_pos.ne'; have := Int.emod_nonneg b four_pos.ne'; have := Int.emod_lt_of_pos a four_pos; have := Int.emod_lt_of_pos b four_pos; interval_cases a % 4 <;> interval_cases b % 4 <;> trivial;
  · have := Int.emod_nonneg a four_pos.ne'; have := Int.emod_nonneg b four_pos.ne'; have := Int.emod_lt_of_pos a four_pos; have := Int.emod_lt_of_pos b four_pos; interval_cases a % 4 <;> interval_cases b % 4 <;> trivial;
  · rw [ neg_eq_neg_one_mul, Int.mul_emod ] ; norm_num [ Int.add_emod, Int.mul_emod ] ; have := Int.emod_nonneg a four_ne_zero; have := Int.emod_nonneg b four_ne_zero; have := Int.emod_lt_of_pos a zero_lt_four; have := Int.emod_lt_of_pos b zero_lt_four; interval_cases a % 4 <;> interval_cases b % 4 <;> trivial;

/-- The root hypotenuse satisfies 5 ≡ 1 mod 4. -/
theorem root_hyp_mod4 : hyp root % 4 = 1 := by
  simp [root, hyp]

/-
All hypotenuses in the Berggren tree are ≡ 1 mod 4.
-/
theorem word_hyp_mod4 (w : List BerggrenGen) : hyp (evalWord w) % 4 = 1 := by
  revert w;
  -- By induction on the length of the word, we can show that each step maintains the congruence to 1 modulo 4.
  intros w
  induction' w using List.reverseRecOn with w ih;
  · rfl;
  · convert child_hyp_mod4 _ _ ih;
    rotate_left;
    exact ( evalWord w ).1;
    exact ( evalWord w ).2.1;
    exact ( evalWord w ).2.2;
    · exact word_bounds ( by decide ) ( by decide ) ( by decide ) ( by decide ) w |>.2.2.2.2.2;
    · assumption;
    · unfold evalWord; aesop;

/-! ## Computational verification of congruence patterns -/

/-- Depth-1 verification: all three children of (3,4,5) have hypotenuse ≡ 1 mod 4. -/
theorem depth1_mod4 :
    (hyp (berggrenChild 0 root)) % 4 = 1 ∧
    (hyp (berggrenChild 1 root)) % 4 = 1 ∧
    (hyp (berggrenChild 2 root)) % 4 = 1 := by
  simp [root, berggrenChild, hyp]

/-- Depth-1 verification: all hypotenuses are odd. -/
theorem depth1_odd :
    Odd (hyp (berggrenChild 0 root)) ∧
    Odd (hyp (berggrenChild 1 root)) ∧
    Odd (hyp (berggrenChild 2 root)) := by
  refine ⟨⟨6, ?_⟩, ⟨14, ?_⟩, ⟨8, ?_⟩⟩ <;> simp [root, berggrenChild, hyp]

end BerggrenDynamics