/-! # CatalogBuild.Speculative.Forbidden.BrokenMirror

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 9
-/

import Mathlib

noncomputable section

/-- The set of fixed points of a mirror — where the reflection "sticks" -/
def Mirror.fixedPoints {α : Type*} (m : Mirror α) : Set α :=
  {x | m.reflect x = x}




/-- The set of "shattered" points — those moved by the mirror -/
def Mirror.shatteredPoints {α : Type*} (m : Mirror α) : Set α :=
  {x | m.reflect x ≠ x}




/-- [Section: # CatalogBuild.Speculative.Forbidden.BrokenMirror
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 9] -/
theorem broken_mirror_odd_fixed_point {α : Type*} [Fintype α] [DecidableEq α]
    (m : Mirror α) (h_odd : Odd (Fintype.card α)) :
    ∃ x, m.reflect x = x := by
  by_contra! h_contra;
  -- Since the shattered (non-fixed) points pair up, we can partition the shattered points into pairs.
  obtain ⟨S, hS_partition⟩ : ∃ S : Finset (Finset α), (∀ s ∈ S, s.card = 2) ∧ (∀ s ∈ S, ∀ t ∈ S, s ≠ t → Disjoint s t) ∧ (∀ x, x ∈ Finset.biUnion S id ↔ m.reflect x ≠ x) := by
    refine' ⟨ Finset.image ( fun x => { x, m.reflect x } ) Finset.univ, _, _, _ ⟩ <;> simp_all +decide [ Finset.disjoint_left ];
    · exact fun x => Finset.card_pair ( Ne.symm ( h_contra x ) );
    · simp +contextual [ Finset.Subset.antisymm_iff, Finset.subset_iff ];
      intro a b h; have := m.involution a; have := m.involution b; aesop;
  have h_card_even : Even (Finset.card (Finset.biUnion S id)) := by
    rw [ Finset.card_biUnion ] <;> aesop;
  simp_all +decide [ Finset.ext_iff ];
  exact absurd h_card_even ( by rw [ show ( S.biUnion id : Finset α ) = Finset.univ from Finset.eq_univ_of_forall fun x => by obtain ⟨ s, hs₁, hs₂ ⟩ := hS_partition.2.2 x; exact Finset.mem_biUnion.2 ⟨ s, hs₁, hs₂ ⟩ ] ; simpa using h_odd )




/-- [Section: # CatalogBuild.Speculative.Forbidden.BrokenMirror
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 9] -/
theorem mirror_shattered_even {α : Type*} [Fintype α] [DecidableEq α]
    (m : Mirror α) :
    Even (Finset.card (Finset.univ.filter (fun x => m.reflect x ≠ x))) := by
  -- The set of shattered points can be partitioned into pairs {x, m.reflect x} where x ≠ m.reflect x.
  have h_partition : ∃ S : Finset (Finset α), (∀ s ∈ S, s.card = 2) ∧ (∀ s ∈ S, ∀ t ∈ S, s ≠ t → Disjoint s t) ∧ (Finset.filter (fun x => m.reflect x ≠ x) Finset.univ) = Finset.biUnion S id := by
    refine' ⟨ Finset.image ( fun x => { x, m.reflect x } ) ( Finset.filter ( fun x => m.reflect x ≠ x ) Finset.univ ), _, _, _ ⟩ <;> simp +contextual;
    · exact fun x hx => Finset.card_pair ( Ne.symm hx );
    · simp +contextual [ Finset.Subset.antisymm_iff, Finset.subset_iff ];
      intro a ha b hb hab; have := m.involution a; have := m.involution b; aesop;
    · ext x; simp +decide [ eq_comm ] ;
      exact ⟨ fun hx => ⟨ x, hx, Or.inl rfl ⟩, fun ⟨ a, ha, hx ⟩ => hx.elim ( fun hx => hx.symm ▸ ha ) fun hx => hx.symm ▸ by have := m.involution a; aesop ⟩;
  obtain ⟨ S, hS₁, hS₂, hS₃ ⟩ := h_partition; rw [ hS₃, Finset.card_biUnion ] ; aesop;
  exact fun s hs t ht hst => hS₂ s hs t ht hst




theorem cantor_broken_mirror (α : Type*) : ¬ Surjective (fun (a : α) (b : α) => a = b) := by
  by_contra h_surjective
  obtain ⟨x, hx⟩ : ∃ x : α → Prop, ¬∃ a : α, x = fun b => a = b := by
    by_cases h : Nonempty α <;> simp_all +decide [ funext_iff ];
    exact ⟨ fun _ => False, fun a => ⟨ a, by simp +decide ⟩ ⟩;
  obtain ⟨ a, ha ⟩ := h_surjective x; exact hx ⟨ a, ha.symm ⟩ ;




theorem diagonal_shattering (α : Type*) (f : α → (α → Bool)) : ¬ Surjective f := by
  intro h;
  -- Define a new function g that differs from each f(a) at least at one point.
  set g : α → Bool := fun a => if f a a = Bool.true then Bool.false else Bool.true;
  cases' h g with a ha ; replace ha := congr_fun ha a ; aesop




theorem discrete_ivt (g : ℤ → ℤ) (n : ℕ) (hn : 0 < n)
    (h0 : 0 < g 0) (hn' : g n < 0)
    (h_step : ∀ k : ℤ, |g (k + 1) - g k| ≤ 1) :
    ∃ k : ℤ, 0 ≤ k ∧ k ≤ n ∧ g k = 0 := by
  -- By induction on $k$, we can show that if $g(k) > 0$, then $g(k+1) \geq 0$.
  by_contra h_contra; push_neg at h_contra; (
  -- By induction on $k$, we can show that $g(k) > 0$ for all $k \in \{0, 1, \ldots, n\}$.
  have h_pos : ∀ k ∈ Finset.range (n + 1), 0 < g k := by
    intro k hk; induction' k with k ih <;> norm_num at *;
    · grind;
    · exact lt_of_le_of_ne ( by linarith [ abs_le.mp ( h_step k ), ih ( Nat.le_of_lt hk ) ] ) ( Ne.symm ( h_contra _ ( by linarith ) ( by linarith ) ) );
  linarith [ h_pos n ( Finset.mem_range.mpr ( Nat.lt_succ_self n ) ) ])




theorem no_perfect_self_mirror :
    ¬ ∃ (halt : (ℕ → Bool) → Bool),
      ∀ f : ℕ → Bool, halt f = true ↔ f 0 = halt f := by
  by_contra h;
  cases' h with halt h; have := h ( fun _ => Bool.true ) ; have := h ( fun _ => Bool.false ) ; simp +decide at *;




theorem involution_parity_fixed {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (hf : ∀ x, f (f x) = x) :
    Even (Fintype.card α) ↔
    Even (Finset.card (Finset.univ.filter (fun x => f x = x))) := by
  -- The shattered points always come in pairs (each paired with its image), so their number is even.
  have h_pair : Even (Finset.card (Finset.filter (fun x => f x ≠ x) Finset.univ)) := by
    convert mirror_shattered_even ⟨ f, hf ⟩ using 1;
  simp_all +decide [ Finset.filter_not, Finset.card_sdiff ];
  grind




end
