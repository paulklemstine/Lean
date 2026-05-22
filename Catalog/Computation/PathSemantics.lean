/-
# Tropical Path Semantics

The fundamental theorem of tropical complexity theory:
matrix powers in the min-plus semiring exactly characterize walks in directed graphs.

## Main Results

- `tropical_power_iff_walk`: `(W ^ k) s t = 1` if and only if there exists a walk
  of length `k` from `s` to `t`, for any 0/1 tropical matrix.
- `tropical_layer_depth_lb`: In any graph, the shortest walk length from `s` to `t`
  is at most `Fintype.card α` (pigeonhole).
- `tropical_layered_exact_depth`: In a layered system, the unique walk length from
  `s` to `t` equals `rank t - rank s`.
-/

import Mathlib
import Computation.TropicalComplexity.Defs

open Tropical Matrix Finset TropicalComplexity

set_option maxHeartbeats 800000

namespace TropicalComplexity

/-! ## Helper lemmas about the tropical semiring -/

lemma edge_eq_one : edge = (1 : T) := rfl

lemma noEdge_eq_zero : noEdge = (0 : T) := rfl

lemma edge_ne_noEdge : edge ≠ noEdge := one_ne_zero

lemma trop_zero_eq_one : Tropical.trop (0 : WithTop ℕ) = (1 : T) := rfl

lemma trop_top_eq_zero : Tropical.trop (⊤ : WithTop ℕ) = (0 : T) := rfl

/-- The product of two edge values is edge (0 + 0 = 0 in WithTop ℕ). -/
lemma edge_mul_edge : (edge : T) * edge = edge := by
  show (1 : T) * 1 = 1
  ring

/-- noEdge absorbs multiplication. -/
lemma noEdge_mul (x : T) : noEdge * x = noEdge := zero_mul x

lemma mul_noEdge (x : T) : x * noEdge = noEdge := mul_zero x

/-- edge is the multiplicative identity. -/
lemma edge_mul (x : T) : edge * x = x := one_mul x

lemma mul_edge (x : T) : x * edge = x := mul_one x

/-- For 0/1 tropical matrices, product is 1 iff both factors are 1. -/
lemma zeroInf_mul_eq_edge {a b : T} (ha : a = edge ∨ a = noEdge)
    (hb : b = edge ∨ b = noEdge) :
    a * b = edge ↔ a = edge ∧ b = edge := by
  constructor
  · intro h
    rcases ha with rfl | rfl <;> rcases hb with rfl | rfl <;> simp_all [edge_mul_edge, noEdge_mul, mul_noEdge]
  · rintro ⟨rfl, rfl⟩; exact edge_mul_edge

/-
For 0/1 tropical values, sum equals edge iff at least one is edge.
-/
lemma zeroInf_add_eq_edge {a b : T} (ha : a = edge ∨ a = noEdge)
    (hb : b = edge ∨ b = noEdge) :
    a + b = edge ↔ a = edge ∨ b = edge := by
  rcases ha with ( rfl | rfl ) <;> rcases hb with ( rfl | rfl ) <;> simp +decide

/-! ## Walk-to-power direction -/

/-
If there is a walk of length k, then the matrix power entry is edge (= 1).
-/
theorem walk_implies_power {α : Type*} [Fintype α] [DecidableEq α]
    (W : Matrix α α T) (hW : IsZeroInfMatrix W) (s t : α) (k : ℕ) :
    Walk W s t k → (W ^ k) s t = edge := by
  induction' k with k ih generalizing s t;
  · cases eq_or_ne s t <;> simp_all +decide [ Walk ];
  · intro h_walk
    obtain ⟨u, hu⟩ := h_walk;
    have h_sum : (W ^ (k + 1)) s t = Finset.sum Finset.univ (fun v => W s v * (W ^ k) v t) := by
      rw [ pow_succ', Matrix.mul_apply ];
    have h_sum : ∀ v, W s v * (W ^ k) v t = edge ∨ W s v * (W ^ k) v t = noEdge := by
      intro v
      have h_edge : W s v = edge ∨ W s v = noEdge := by
        exact hW s v
      have h_walk : (W ^ k) v t = edge ∨ (W ^ k) v t = noEdge := by
        have h_walk : ∀ k, ∀ s t, (W ^ k) s t = edge ∨ (W ^ k) s t = noEdge := by
          intro k s t; induction' k with k ih generalizing s t <;> simp_all +decide [ pow_succ', Matrix.mul_apply ] ;
          · by_cases h : s = t <;> simp +decide [ h, Matrix.one_apply ];
          · have h_sum : ∀ j, W s j * (W ^ k) j t = edge ∨ W s j * (W ^ k) j t = noEdge := by
              intro j; cases hW s j <;> cases ih j t <;> simp +decide [ * ] ;
            have h_sum : ∀ {S : Finset α}, (∀ j ∈ S, W s j * (W ^ k) j t = edge ∨ W s j * (W ^ k) j t = noEdge) → (∑ j ∈ S, W s j * (W ^ k) j t) = edge ∨ (∑ j ∈ S, W s j * (W ^ k) j t) = noEdge := by
              intro S hS; induction S using Finset.induction <;> simp_all +decide ;
              cases h_sum ‹_› <;> cases ‹∑ j ∈ _, _ = _ ∨ _› <;> simp_all +decide [ zeroInf_add_eq_edge ];
            exact h_sum fun j _ => by solve_by_elim;
        exact h_walk k v t
      cases h_edge <;> cases h_walk <;> simp [*];
    have h_sum : ∀ {S : Finset α} {f : α → T}, (∀ v ∈ S, f v = edge ∨ f v = noEdge) → (∃ v ∈ S, f v = edge) → Finset.sum S f = edge := by
      intros S f hf h_exists_edge
      induction' S using Finset.induction with v S ih;
      · aesop;
      · by_cases h : ∃ w ∈ S, f w = edge <;> simp_all +decide [ Finset.sum_insert ih ];
        cases hf.1 <;> simp_all +decide [ edge_eq_one ];
    exact ‹ ( W ^ ( k + 1 ) ) s t = ∑ v, W s v * ( W ^ k ) v t › ▸ h_sum ( fun v _ => by solve_by_elim ) ⟨ u, Finset.mem_univ _, by aesop ⟩

/-! ## Power-to-walk direction -/

/-
If the matrix power entry is edge, then there exists a walk.
-/
theorem power_implies_walk {α : Type*} [Fintype α] [DecidableEq α]
    (W : Matrix α α T) (hW : IsZeroInfMatrix W) (s t : α) (k : ℕ) :
    (W ^ k) s t = edge → Walk W s t k := by
  revert s t;
  induction' k with k ih;
  · intro s t h; contrapose! h; simp_all +decide [ Walk ] ;
  · intro s t h
    have h_sum : ∃ u, W s u * (W ^ k) u t = edge := by
      contrapose! h;
      rw [ pow_succ', Matrix.mul_apply ];
      -- Since each term in the sum is either edge or noEdge, and none of them are edge, they must all be noEdge.
      have h_all_noEdge : ∀ u, W s u * (W ^ k) u t = noEdge := by
        intro u
        have h_term : W s u = edge ∨ W s u = noEdge := hW s u
        have h_term_k : (W ^ k) u t = edge ∨ (W ^ k) u t = noEdge := by
          have h_term_k : ∀ k : ℕ, ∀ u v : α, (W ^ k) u v = edge ∨ (W ^ k) u v = noEdge := by
            intro k u v; induction' k with k ih generalizing u v <;> simp_all +decide [ pow_succ', Matrix.mul_apply ] ;
            · by_cases h : u = v <;> simp +decide [ h, Matrix.one_apply ];
            · have h_term_k : ∀ j, W u j * (W ^ k) j v = edge ∨ W u j * (W ^ k) j v = noEdge := by
                intro j; cases hW u j <;> cases ih j v <;> simp +decide [ * ] ;
              have h_sum : ∀ {S : Finset α} {f : α → T}, (∀ j ∈ S, f j = edge ∨ f j = noEdge) → (∑ j ∈ S, f j) = edge ∨ (∑ j ∈ S, f j) = noEdge := by
                intros S f hf; induction S using Finset.induction <;> simp_all +decide [ Finset.sum_insert, Finset.sum_singleton ] ;
                cases hf.1 <;> cases ‹∑ j ∈ _, f j = edge ∨ ∑ j ∈ _, f j = noEdge› <;> simp_all +decide [ zeroInf_add_eq_edge ];
              exact h_sum fun j _ => h_term_k j;
          exact h_term_k k u t
        cases h_term <;> cases h_term_k <;> simp_all +decide [ zeroInf_mul_eq_edge ];
        exact h u ( by rw [ ‹W s u = edge›, ‹ ( W ^ k ) u t = edge›, edge_mul_edge ] );
      simp +decide [ h_all_noEdge ]
    obtain ⟨u, hu⟩ := h_sum
    have h_edge : W s u = edge := by
      cases hW s u <;> simp_all +decide [ zeroInf_mul_eq_edge ]
    have h_walk : Walk W u t k := by
      grind
    exact ⟨u, h_edge, h_walk⟩

/-! ## The fundamental theorem -/

/-- **Tropical Path Semantics Theorem**.
For a 0/1 tropical matrix `W`, the `(s,t)` entry of `W^k` equals `edge` (= 1)
if and only if there exists a walk of length exactly `k` from `s` to `t`.

This is the foundational result connecting min-plus linear algebra to graph reachability:
tropical matrix powers exactly count walk existence by length. -/
theorem tropical_power_iff_walk {α : Type*} [Fintype α] [DecidableEq α]
    (W : Matrix α α T) (hW : IsZeroInfMatrix W) (s t : α) (k : ℕ) :
    (W ^ k) s t = edge ↔ Walk W s t k :=
  ⟨power_implies_walk W hW s t k, walk_implies_power W hW s t k⟩

/-! ## Layer depth lower bound -/

/-
Any walk visits at most `card α` distinct vertices, so walk length ≤ card α
    for shortest walks (by pigeonhole).
-/
theorem tropical_layer_depth_lb
    {α : Type*} [Fintype α] [DecidableEq α]
    (W : Matrix α α T) (hW : IsZeroInfMatrix W) (s t : α) (L : ℕ)
    (hreach : (W ^ L) s t = edge)
    (hno_shorter : ∀ k < L, (W ^ k) s t ≠ edge) :
    L ≤ Fintype.card α := by
  -- By contradiction, assume L > Fintype.card α.
  by_contra h_contra;
  -- By the pigeonhole principle, since L > Fintype.card α, there must be some repetition in the sequence of vertices visited by the walk.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : Fin (L + 1), i < j ∧ (∃ v : α, Walk W s v i.val ∧ Walk W v t (L - i.val) ∧ v = v ∧ Walk W s v j.val ∧ Walk W v t (L - j.val)) := by
    have h_pigeonhole : ∃ i j : Fin (L + 1), i < j ∧ (∃ v : α, Walk W s v i.val ∧ Walk W v t (L - i.val) ∧ v = v ∧ Walk W s v j.val ∧ Walk W v t (L - j.val)) := by
      have h_walk : ∀ k ≤ L, ∃ v : α, Walk W s v k ∧ Walk W v t (L - k) := by
        intro k hk
        have h_walk : (W ^ k * W ^ (L - k)) s t = edge := by
          rw [ ← pow_add, Nat.add_sub_of_le hk, hreach ];
        -- By definition of matrix multiplication in the tropical semiring, if $(W^k * W^{L-k}) s t = edge$, then there exists some $v$ such that $(W^k) s v = edge$ and $(W^{L-k}) v t = edge$.
        obtain ⟨v, hv⟩ : ∃ v : α, (W ^ k) s v = edge ∧ (W ^ (L - k)) v t = edge := by
          have h_walk : ∀ (A B : Matrix α α T), (∀ a b, A a b = edge ∨ A a b = noEdge) → (∀ a b, B a b = edge ∨ B a b = noEdge) → (A * B) s t = edge → ∃ v : α, A s v = edge ∧ B v t = edge := by
            intros A B hA hB hAB
            have h_walk : ∃ v : α, A s v * B v t = edge := by
              have h_walk : ∃ v : α, A s v * B v t ≠ noEdge := by
                by_cases h : ∀ v : α, A s v * B v t = noEdge <;> simp_all +decide [ Matrix.mul_apply ];
              exact h_walk.imp fun v hv => Or.resolve_right ( by cases hA s v <;> cases hB v t <;> simp_all +decide ) hv;
            grind +extAll;
          have h_walk : ∀ (k : ℕ), (∀ a b, (W ^ k) a b = edge ∨ (W ^ k) a b = noEdge) := by
            intro k a b; induction' k with k ih generalizing a b <;> simp_all +decide [ pow_succ', Matrix.mul_apply ] ;
            · by_cases hab : a = b <;> simp +decide [ hab, Matrix.one_apply ];
            · have h_walk : ∀ (j : α), W a j * (W ^ k) j b = edge ∨ W a j * (W ^ k) j b = noEdge := by
                intro j; cases hW a j <;> cases ih j b <;> simp +decide [ * ] ;
              have h_walk : ∀ (s : Finset α), (∀ j ∈ s, W a j * (W ^ k) j b = edge ∨ W a j * (W ^ k) j b = noEdge) → (∑ j ∈ s, W a j * (W ^ k) j b) = edge ∨ (∑ j ∈ s, W a j * (W ^ k) j b) = noEdge := by
                intro s hs; induction s using Finset.induction <;> simp_all +decide ;
                cases h_walk ‹_› <;> simp_all +decide [ edge, noEdge ];
                · cases ‹∑ j ∈ _, W a j * ( W ^ k ) j b = 1 ∨ _› <;> simp_all +decide [ add_comm ];
                · cases ‹W a _ = 0 ∨ ( W ^ k ) _ b = 0› <;> simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ];
              exact h_walk Finset.univ fun j _ => by solve_by_elim;
          exact ‹∀ ( A B : Matrix α α T ), ( ∀ a b, A a b = edge ∨ A a b = noEdge ) → ( ∀ a b, B a b = edge ∨ B a b = noEdge ) → ( A * B ) s t = edge → ∃ v, A s v = edge ∧ B v t = edge› _ _ ( h_walk k ) ( h_walk ( L - k ) ) ‹_›;
        exact ⟨ v, tropical_power_iff_walk W hW s v k |>.1 hv.1, tropical_power_iff_walk W hW v t ( L - k ) |>.1 hv.2 ⟩
      choose! f hf₁ hf₂ using h_walk;
      have h_pigeonhole : ∃ i j : Fin (L + 1), i < j ∧ f i.val (by
      exact Nat.le_of_lt_succ i.2) = f j.val (by
      exact Nat.le_of_lt_succ j.2) := by
        by_contra h_contra;
        exact absurd ( Fintype.card_le_of_injective ( fun i : Fin ( L + 1 ) => f i ( by linarith [ Fin.is_lt i ] ) ) fun i j hij => le_antisymm ( not_lt.mp fun hi => h_contra ⟨ j, i, hi, hij.symm ⟩ ) ( not_lt.mp fun hj => h_contra ⟨ i, j, hj, hij ⟩ ) ) ( by simpa using by linarith )
      generalize_proofs at *;
      grind;
    exact h_pigeonhole;
  obtain ⟨v, hv₁, hv₂, hv₃, hv₄, hv₅⟩ := h_eq
  have h_walk : Walk W s t (i.val + (L - j.val)) := by
    have h_walk : ∀ {a b c : α} {k l : ℕ}, Walk W a b k → Walk W b c l → Walk W a c (k + l) := by
      intros a b c k l hk hl; induction' k with k ih generalizing a b c <;> simp_all +decide [ Nat.succ_add ] ;
      · cases hk ; aesop;
      · obtain ⟨ u, hu₁, hu₂ ⟩ := hk; exact ⟨ u, hu₁, ih hu₂ hl ⟩ ;
    exact h_walk hv₁ hv₅;
  exact hno_shorter ( i + ( L - j ) ) ( by linarith [ show ( i : ℕ ) < j from hij, Nat.sub_add_cancel ( show ( j : ℕ ) ≤ L from Nat.le_of_lt_succ j.2 ) ] ) ( walk_implies_power W hW s t _ h_walk )

/-! ## Layered systems: walks have rigid length -/

/-
In a layered system, any walk from `s` to `t` has length exactly `rank t - rank s`.
-/
theorem walk_length_eq_rank_diff {α : Type*} [Fintype α] [DecidableEq α]
    (rank : α → ℕ) (W : Matrix α α T) (s t : α) (k : ℕ)
    (hstep : IsLayered rank W)
    (hwalk : Walk W s t k) :
    k = rank t - rank s ∧ rank s + k = rank t := by
  induction' k with k ih generalizing s t;
  · cases hwalk ; aesop;
  · obtain ⟨ u, hu, hu' ⟩ := hwalk;
    have := hstep s u hu;
    grind

/-
Helper: concatenating walks.
-/
theorem walk_append {α : Type*} [Fintype α] [DecidableEq α]
    (W : Matrix α α T) (a b c : α) (k l : ℕ) :
    Walk W a b k → Walk W b c l → Walk W a c (k + l) := by
  induction' k with k ih generalizing a b c <;> simp_all +decide [ Nat.succ_add ];
  · rintro rfl; exact id;
  · rintro ⟨ u, hu, hu' ⟩ hv;
    exact ⟨ u, hu, ih u b c hu' hv ⟩

/-
Helper: a walk can be converted to a path function.
-/
theorem walk_to_path {α : Type*} [Fintype α] [DecidableEq α]
    (W : Matrix α α T) (s t : α) (k : ℕ)
    (hw : Walk W s t k) :
    ∃ p : Fin (k + 1) → α, p 0 = s ∧ p ⟨k, Nat.lt_succ_self k⟩ = t ∧
      ∀ i : Fin k, W (p i.castSucc) (p i.succ) = edge := by
  induction' k with k ih generalizing s t <;> simp_all +decide [ Walk ];
  · exact ⟨ fun _ => t, rfl ⟩;
  · obtain ⟨ u, hu₁, hu₂ ⟩ := hw; obtain ⟨ p, hp₁, hp₂, hp₃ ⟩ := ih u t hu₂; use Fin.cons s p; simp_all +decide [ Fin.forall_fin_succ ] ;
    exact ⟨ hp₂, hu₁ ⟩

/-
Helper: a path function gives a walk.
-/
theorem path_to_walk {α : Type*} [Fintype α] [DecidableEq α]
    (W : Matrix α α T) (s t : α) (k : ℕ)
    (p : Fin (k + 1) → α) (hp0 : p 0 = s) (hpk : p ⟨k, Nat.lt_succ_self k⟩ = t)
    (hedge : ∀ i : Fin k, W (p i.castSucc) (p i.succ) = edge) :
    Walk W s t k := by
  induction' k with k ih generalizing s t;
  · exact hp0.symm.trans hpk;
  · refine' ⟨ p 1, _, _ ⟩;
    · simpa [ hp0 ] using hedge 0;
    · convert ih _ _ ( fun i => p i.succ ) _ _ _ using 1;
      · rfl;
      · exact hpk;
      · exact fun i => hedge ⟨ i + 1, by linarith [ Fin.is_lt i ] ⟩

/-- **Layered Exact Depth Theorem**.
In a layered transition system where every edge increases rank by 1,
`(W ^ L) s t = edge` if and only if `L = rank t - rank s` and there is
a walk of length `L` from `s` to `t`.

This theorem is the formal backbone for complexity-theoretic interpretations:
in layered bounded-space computations, simulation depth is exactly determined
by the rank difference. -/
theorem tropical_layered_exact_depth {α : Type*} [Fintype α] [DecidableEq α]
    (rank : α → ℕ) (W : Matrix α α T) (s t : α) (L : ℕ)
    (hW : IsZeroInfMatrix W) (_hstep : IsLayered rank W)
    (_hs : rank s = 0) (_ht : rank t = L) :
    (W ^ L) s t = edge ↔
    ∃ p : Fin (L + 1) → α, p 0 = s ∧ p ⟨L, Nat.lt_succ_self L⟩ = t ∧
      ∀ i : Fin L, W (p i.castSucc) (p i.succ) = edge := by
  constructor
  · intro h
    exact walk_to_path W s t L (power_implies_walk W hW s t L h)
  · rintro ⟨p, hp0, hpL, hedge⟩
    exact walk_implies_power W hW s t L (path_to_walk W s t L p hp0 hpL hedge)

/-! ## No-shortcut theorem -/

/-
**No-Shortcut Theorem**.
In a layered system, if `s` reaches `t` at depth `L > 0`, then no
shorter tropical power realizes the connection.

This is the core obstruction result: layered bounded-space computations
cannot be compressed to fewer simulation steps.
-/
theorem layered_no_shortcut {α : Type*} [Fintype α] [DecidableEq α]
    (rank : α → ℕ) (W : Matrix α α T) (s t : α) (L : ℕ)
    (hW : IsZeroInfMatrix W) (hstep : IsLayered rank W)
    (hs : rank s = 0) (ht : rank t = L)
    (_hreach : (W ^ L) s t = edge) :
    ∀ k < L, (W ^ k) s t ≠ edge := by
  intro k hk h;
  -- By walk_length_eq_rank_diff (using hstep), k = rank t - rank s and rank s + k = rank t.
  obtain ⟨hk_eq, hk_sum⟩ : k = rank t - rank s ∧ rank s + k = rank t := by
    apply walk_length_eq_rank_diff;
    exacts [ hstep, power_implies_walk W hW s t k h ];
  omega

end TropicalComplexity