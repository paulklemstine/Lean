import Mathlib

/-!
# The complete binary inverse tree of the logistic map

For the parameter-four logistic map, every target strictly between zero and one has
`2^n` explicitly indexed, pairwise distinct real seeds that produce it after `n`
updates.  The index is an `n`-bit word.  Each bit selects one of the two inverse
branches, exposing a precise cryptographic ambiguity behind the chaotic dynamics.
-/

noncomputable section

namespace LogisticBinaryTree

open Set

/-- The parameter-four logistic map. -/
def logistic (x : ℝ) : ℝ := 4 * x * (1 - x)

/-- The lower inverse branch. -/
def lower (y : ℝ) : ℝ := (1 - Real.sqrt (1 - y)) / 2

/-- The upper inverse branch, reflected about `1/2`. -/
def upper (y : ℝ) : ℝ := (1 + Real.sqrt (1 - y)) / 2

/-- Select an inverse branch with one bit. -/
def branch (b : Bool) (y : ℝ) : ℝ := if b then upper y else lower y

/-- Decode an `n`-bit word as a depth-`n` preimage of `y`. -/
def inverseSeed : (n : ℕ) → (Fin n → Bool) → ℝ → ℝ
  | 0, _, y => y
  | n + 1, bits, y =>
      branch (bits 0) (inverseSeed n (fun i => bits i.succ) y)

/-
Both explicit branches are genuine preimages.
-/
theorem logistic_branch (b : Bool) {y : ℝ} (hy : y ≤ 1) :
    logistic (branch b y) = y := by
      cases b <;> simp [logistic, branch, lower, upper] <;> ring; all_goals rw [ Real.sq_sqrt ] <;> linarith

/-
Every branch maps the open unit interval back into it.
-/
theorem branch_mem_Ioo (b : Bool) {y : ℝ} (hy : y ∈ Ioo (0 : ℝ) 1) :
    branch b y ∈ Ioo (0 : ℝ) 1 := by
      cases b <;> simp_all +decide [ branch ];
      · exact ⟨ div_pos ( sub_pos.mpr <| by rw [ Real.sqrt_lt' ] <;> linarith ) zero_lt_two, div_lt_one zero_lt_two |>.2 <| sub_lt_iff_lt_add'.mpr <| by nlinarith [ Real.sqrt_nonneg ( 1 - y ), Real.sq_sqrt <| show 0 ≤ 1 - y by linarith ] ⟩;
      · exact ⟨ div_pos ( by nlinarith [ Real.sqrt_nonneg ( 1 - y ), Real.sq_sqrt ( show 0 ≤ 1 - y by linarith ) ] ) zero_lt_two, by rw [ upper ] ; nlinarith [ Real.sqrt_nonneg ( 1 - y ), Real.sq_sqrt ( show 0 ≤ 1 - y by linarith ) ] ⟩

/-
The two branches occupy disjoint halves of the unit interval.
-/
theorem branch_side (b : Bool) {y : ℝ} (hy : y ∈ Ioo (0 : ℝ) 1) :
    if b then (1 / 2 : ℝ) < branch b y else branch b y < 1 / 2 := by
      split_ifs <;> cases b <;> unfold branch <;> norm_num at *;
      · unfold upper; nlinarith [ Real.sqrt_nonneg ( 1 - y ), Real.sq_sqrt ( by linarith : 0 ≤ 1 - y ) ] ;
      · unfold lower; nlinarith [ Real.sqrt_nonneg ( 1 - y ), Real.sq_sqrt ( by linarith : 0 ≤ 1 - y ) ]

/-
Each individual inverse branch is injective on the open unit interval.
-/
theorem branch_injective_on (b : Bool) :
    Set.InjOn (branch b) (Ioo (0 : ℝ) 1) := by
      intro x hx y hy hxy;
      grind +locals

/-
Every decoded seed remains strictly inside the unit interval.
-/
theorem inverseSeed_mem_Ioo (n : ℕ) (bits : Fin n → Bool) {y : ℝ}
    (hy : y ∈ Ioo (0 : ℝ) 1) : inverseSeed n bits y ∈ Ioo (0 : ℝ) 1 := by
      induction' n with n ih generalizing y <;> simp_all +decide [inverseSeed];
      exact branch_mem_Ioo _ ( ih _ hy.1 hy.2 )

/-
Applying `n` logistic updates to a depth-`n` decoded seed recovers the target.
-/
theorem logistic_iterate_inverseSeed (n : ℕ) (bits : Fin n → Bool) {y : ℝ}
    (hy : y ∈ Ioo (0 : ℝ) 1) :
    logistic^[n] (inverseSeed n bits y) = y := by
      induction' n with n ih generalizing y;
      · rfl;
      · -- By definition of `inverseSeed`, we have:
        have h_invSeed : inverseSeed (n + 1) bits y = branch (bits 0) (inverseSeed n (fun i => bits i.succ) y) := by
          rfl;
        simp_all +decide [ Function.iterate_add_apply ];
        rw [ logistic_branch ];
        · exact ih _ hy.1 hy.2;
        · exact le_of_lt ( inverseSeed_mem_Ioo _ _ hy |>.2 )

/-
Distinct bit words decode to distinct seeds.  Thus no two paths in the inverse
binary tree merge before reaching their common target.
-/
theorem inverseSeed_injective (n : ℕ) {y : ℝ} (hy : y ∈ Ioo (0 : ℝ) 1) :
    Function.Injective (fun bits : Fin n → Bool => inverseSeed n bits y) := by
      intro a b hab;
      induction' n with n ih;
      · exact Subsingleton.elim _ _;
      · -- By definition of `inverseSeed`, we have:
        have h_eq : branch (a 0) (inverseSeed n (fun i => a i.succ) y) = branch (b 0) (inverseSeed n (fun i => b i.succ) y) := by
          exact hab;
        -- By definition of `branch`, we know that if `branch (a 0) (inverseSeed n (fun i => a i.succ) y) = branch (b 0) (inverseSeed n (fun i => b i.succ) y)`, then `a 0 = b 0`.
        have h_head : a 0 = b 0 := by
          cases h : a 0 <;> cases h' : b 0 <;> simp_all +decide [ branch ];
          · unfold lower upper at h_eq;
            linarith [ Real.sqrt_pos.2 ( show 0 < 1 - inverseSeed n ( fun i => a i.succ ) y from sub_pos.2 <| by linarith [ Set.mem_Ioo.mp <| inverseSeed_mem_Ioo n ( fun i => a i.succ ) hy ] ), Real.sqrt_nonneg ( 1 - inverseSeed n ( fun i => b i.succ ) y ) ];
          · unfold upper lower at h_eq;
            linarith [ Real.sqrt_pos.2 ( show 0 < 1 - inverseSeed n ( fun i => a i.succ ) y from sub_pos.2 <| by linarith [ Set.mem_Ioo.mp <| inverseSeed_mem_Ioo n ( fun i => a i.succ ) hy ] ), Real.sqrt_nonneg ( 1 - inverseSeed n ( fun i => b i.succ ) y ) ];
        simp_all +decide [ funext_iff, Fin.forall_fin_succ ];
        exact ih ( by simpa [ h_head, branch ] using branch_injective_on ( b 0 ) ( inverseSeed_mem_Ioo n _ hy ) ( inverseSeed_mem_Ioo n _ hy ) h_eq )

/-
**Exponential preimage ambiguity.** For every interior target and every depth
`n`, there is an explicit injection from the `n`-bit key space into seeds in the
open unit interval, and every one of those seeds yields the target after exactly
`n` updates.
-/
theorem exponential_preimage_family (n : ℕ) {y : ℝ} (hy : y ∈ Ioo (0 : ℝ) 1) :
    ∃ decode : (Fin n → Bool) → ℝ,
      Function.Injective decode ∧
      (∀ bits, decode bits ∈ Ioo (0 : ℝ) 1) ∧
      (∀ bits, logistic^[n] (decode bits) = y) := by
        exact ⟨ _, inverseSeed_injective n hy, fun bits => inverseSeed_mem_Ioo n bits hy, fun bits => logistic_iterate_inverseSeed n bits hy ⟩

/-
Once a decoded seed reaches its target, its entire future orbit is the target's
future orbit. Hence all indexed seeds have identical keystream suffixes from sample
`n` onward.
-/
theorem inverseSeed_suffix_collision (n k : ℕ) (bits : Fin n → Bool) {y : ℝ}
    (hy : y ∈ Ioo (0 : ℝ) 1) :
    logistic^[n + k] (inverseSeed n bits y) = logistic^[k] y := by
      rw [ add_comm, Function.iterate_add_apply, logistic_iterate_inverseSeed ];
      exact hy

/-- The indexed family contains exactly `2^n` seeds. -/
theorem binary_keyspace_card (n : ℕ) : Fintype.card (Fin n → Bool) = 2 ^ n := by
  norm_num

/-
For positive depth, every interior target has at least two distinct interior
seeds which produce that target after exactly `n` updates.
-/
theorem two_distinct_colliding_seeds {n : ℕ} (hn : 0 < n) {y : ℝ}
    (hy : y ∈ Ioo (0 : ℝ) 1) :
    ∃ x₀ x₁, x₀ ∈ Ioo (0 : ℝ) 1 ∧ x₁ ∈ Ioo (0 : ℝ) 1 ∧
      x₀ ≠ x₁ ∧ logistic^[n] x₀ = y ∧ logistic^[n] x₁ = y := by
        obtain ⟨decode, h_decode⟩ := exponential_preimage_family n hy;
        exact ⟨ decode ( fun _ => Bool.true ), decode ( fun _ => Bool.false ), h_decode.2.1 _, h_decode.2.1 _, h_decode.1.ne fun h => by simpa using congr_fun h ⟨ 0, hn ⟩, h_decode.2.2 _, h_decode.2.2 _ ⟩

end LogisticBinaryTree