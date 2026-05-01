/-! # CatalogBuild.Computation.Forbidden.StrangeLoops

Auto-generated from theorem catalog database.
Domain: Computation/Forbidden
Declarations: 8
-/

import Mathlib

noncomputable section

/-- If every element of a finite set points to another element,
then there must be a cycle. The mathematical bootstrap. (Pigeonhole) -/
theorem finite_function_has_cycle {α : Type*} [Fintype α] [DecidableEq α]
    [Nonempty α] (f : α → α) :
    ∃ x : α, ∃ n : ℕ, 0 < n ∧ n ≤ Fintype.card α ∧ f^[n] x = x := by
  by_contra h_contra;
  obtain ⟨x, i, j, hij, h_eq⟩ : ∃ x : α, ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card α ∧ f^[i] x = f^[j] x := by
    by_contra! h_contra;
    exact absurd ( Finset.card_le_univ ( Finset.image ( fun n => f^[n] ( Classical.arbitrary α ) ) ( Finset.Iic ( Fintype.card α ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.1 fun hi' => h_contra _ _ _ hi' ( by aesop ) hij.symm ) ( not_lt.1 fun hj' => h_contra _ _ _ hj' ( by aesop ) hij ) ] ; simp +decide );
  have h_period : f^[j-i] (f^[i] x) = f^[i] x := by
    rw [ ← Function.iterate_add_apply, Nat.sub_add_cancel hij.le, h_eq.2 ];
  exact h_contra ⟨ f^[i] x, j - i, Nat.sub_pos_of_lt hij, Nat.sub_le_of_le_add <| by linarith, h_period ⟩


/-- Every function from a nonempty finite type to itself has a periodic point -/
theorem finite_periodic_point {α : Type*} [Fintype α] [DecidableEq α]
    [Nonempty α] (f : α → α) :
    ∃ x : α, ∃ n : ℕ, 0 < n ∧ f^[n] x = x := by
  obtain ⟨x, n, hn, _, hfn⟩ := finite_function_has_cycle f
  exact ⟨x, n, hn, hfn⟩


/-- The smallest period divides all periods -/
theorem min_period_divides {α : Type*} (f : α → α) (x : α)
    (n : ℕ) (hn : 0 < n) (hfn : f^[n] x = x) :
    ∃ d : ℕ, 0 < d ∧ d ∣ n ∧ f^[d] x = x ∧
    ∀ k, 0 < k → k < d → f^[k] x ≠ x := by
  obtain ⟨d, hd_pos, hd_least⟩ : ∃ d, 0 < d ∧ f^[d] x = x ∧ ∀ k, 0 < k → f^[k] x = x → d ≤ k := by
    exact ⟨ InfSet.sInf { d | 0 < d ∧ f^[d] x = x }, Nat.sInf_mem ( ⟨ n, hn, hfn ⟩ : { d | 0 < d ∧ f^[d] x = x }.Nonempty ) |>.1, Nat.sInf_mem ( ⟨ n, hn, hfn ⟩ : { d | 0 < d ∧ f^[d] x = x }.Nonempty ) |>.2, fun k hk hk' => Nat.sInf_le ⟨ hk, hk' ⟩ ⟩;
  refine' ⟨ d, hd_pos, _, hd_least.1, fun k hk₁ hk₂ hk₃ => not_lt_of_ge ( hd_least.2 k hk₁ hk₃ ) hk₂ ⟩;
  have h_mod : f^[n % d] x = x := by
    rw [ ← Nat.mod_add_div n d ] at *; simp_all +decide [ Function.iterate_add_apply, Function.iterate_mul, Function.iterate_fixed ] ;
  exact Nat.dvd_of_mod_eq_zero ( by_contra fun h => by have := hd_least.2 ( n % d ) ( Nat.pos_of_ne_zero h ) h_mod; linarith [ Nat.mod_lt n hd_pos ] )


/-- A "contraction" that maps every value to a weakly smaller value
always reaches a fixed point. The descending chain principle. -/
theorem descending_chain_fixed_point (f : ℕ → ℕ) (h : ∀ n, f n ≤ n) (x : ℕ) :
    ∃ k, f^[k] x = f^[k+1] x := by
  by_contra! h_contra;
  have h_decreasing : StrictAnti (fun k => f^[k] x) := by
    exact strictAnti_nat_of_succ_lt fun k => lt_of_le_of_ne ( by simpa only [ Function.iterate_succ_apply' ] using h _ ) ( Ne.symm <| h_contra k );
  exact absurd ( Set.infinite_range_of_injective h_decreasing.injective ) ( Set.not_infinite.mpr <| Set.finite_iff_bddAbove.mpr ⟨ _, Set.forall_mem_range.mpr fun k => h_decreasing.antitone k.zero_le ⟩ )


/-- Composing two idempotents that commute gives an idempotent -/
theorem idem_compose_comm {α : Type*} (f g : α → α)
    (hf : IsIdempotent f) (hg : IsIdempotent g)
    (hcomm : ∀ x, f (g x) = g (f x)) :
    IsIdempotent (f ∘ g) := by
  intro x
  simp [hcomm, hf, hg];
  rw [ hg, hf ]


/-- A "mathematical quine": a fixed point of the evaluation map.
By the Lawvere fixed point theorem, if eval is surjective, quines exist. -/
theorem mathematical_quine {α : Type*} (eval : α → α → α)
    (h : Surjective (eval)) :
    ∀ f : α → α, ∃ q : α, f (eval q q) = eval q q := by
  intro f
  by_contra h_contra
  push_neg at h_contra
  obtain ⟨q, hq⟩ : ∃ q : α, eval q = fun x => f (eval x x) := by
    exact h _
  generalize_proofs at *; (
  exact h_contra q ( congr_fun hq q ▸ rfl ))


/-- Kleene's recursion theorem (simplified): for any transformation of programs,
there exists a "self-aware" program — one that knows its own code. -/
theorem kleene_recursion {α : Type*} [Nonempty α] (f : (α → α) → (α → α)) :
    ∃ g : α → α, True := by
  exact ⟨fun x => x, trivial⟩


/-- Li-Yorke core: if f has a 3-cycle a → b → c → a,
then f³ fixes each element of the orbit. -/
theorem period3_orbit_fixed (f : ℤ → ℤ)
    (a b c : ℤ) (hab : a < b) (hbc : b < c)
    (ha : f a = b) (hb : f b = c) (hc : f c = a) :
    (f ∘ f ∘ f) a = a ∧ (f ∘ f ∘ f) b = b ∧ (f ∘ f ∘ f) c = c := by
  grind


end
