/-! # CatalogBuild.Physics.Classical.RepulsorTheory

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 33
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Physics.Classical.RepulsorTheory
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 33] -/
theorem diagonal_evasion (enum : ℕ → (ℕ → ℕ)) :
    ∃ g : ℕ → ℕ, ∀ n, g n ≠ enum n n := by
  exact ⟨ fun n => enum n n + 1, fun n => by simp +decide ⟩



/-- **Diagonal Evasion with Constructive Witness.**
We can explicitly construct the evading function: at position n,
simply differ from enum(n)(n) by adding 1. -/
def diagonal_evader (enum : ℕ → (ℕ → ℕ)) : ℕ → ℕ :=
  fun n => enum n n + 1



theorem diagonal_evader_evades (enum : ℕ → (ℕ → ℕ)) :
    ∀ n, diagonal_evader enum n ≠ enum n n := by
  exact fun n => Nat.succ_ne_self _



/-- **Iterated Diagonal Evasion.**
Even if you add the evader back to the enumeration and re-diagonalize,
you get a *new* evader. The evasion never terminates — this is the
"search-hardening" property at its most fundamental. -/
def iterated_evader : ℕ → (ℕ → (ℕ → ℕ)) → (ℕ → ℕ)
  | 0, enum => diagonal_evader enum
  | n + 1, enum =>
    let prev := iterated_evader n enum
    -- Extend the enumeration with the previous evader
    let extended : ℕ → (ℕ → ℕ) := fun k =>
      if k = 0 then prev else enum (k - 1)
    diagonal_evader extended



theorem iterated_evaders_all_distinct (enum : ℕ → (ℕ → ℕ)) :
    ∀ i j, i ≠ j → iterated_evader i enum ≠ iterated_evader j enum := by
  intros i j hij h_eq; contrapose! hij; (
  have h_diff : ∀ n, iterated_evader (n + 1) enum 0 ≠ iterated_evader n enum 0 := by
    intro n
    simp [iterated_evader];
    exact Nat.succ_ne_self _;
  -- By induction on $n$, we can show that $iterated\_evader n enum 0$ is strictly increasing.
  have h_inc : StrictMono (fun n => iterated_evader n enum 0) := by
    refine' strictMono_nat_of_lt_succ fun n => _;
    induction' n with n ih <;> simp_all +decide [ iterated_evader ];
    · exact Nat.lt_succ_self _;
    · exact Nat.succ_lt_succ ih;
  exact h_inc.injective ( congr_fun h_eq 0 ))



theorem cantor_evasion (α : Type*) (f : α → Set α) :
    ∃ S : Set α, ∀ a, f a ≠ S := by
  exact ⟨ { a | a∉ f a }, fun a ha => by simpa using Set.ext_iff.mp ha a ⟩



/-- **The Evading Set**: explicitly constructed via diagonalization. -/
def evading_set {α : Type*} (f : α → Set α) : Set α :=
  {a : α | a ∉ f a}



theorem evading_set_evades {α : Type*} (f : α → Set α) :
    ∀ a, f a ≠ evading_set f := by
  intro a ha; have := Set.ext_iff.mp ha a; simp +decide [ evading_set ] at this;



/-- A search game on a finite universe of size n.
The target is hidden; the searcher queries positions one at a time.
After k queries that all miss, the evader's remaining hiding places. -/
def remaining_positions (n : ℕ) (queries : Finset (Fin n)) : Finset (Fin n) :=
  Finset.univ \ queries



theorem remaining_positions_card (n : ℕ) (queries : Finset (Fin n)) :
    (remaining_positions n queries).card = n - queries.card := by
  unfold remaining_positions; simp +decide [ Finset.card_sdiff ] ;



theorem evader_survives_linear (n : ℕ) (hn : 2 ≤ n) :
    ∀ pursuer_strategy : Fin (n - 1) → Fin n,
    ∃ evader_pos : Fin (n - 1) → Fin n,
    ∀ round : Fin (n - 1), evader_pos round ≠ pursuer_strategy round := by
  intros pursuer_strategy
  have h_exists : ∀ r : Fin (n - 1), ∃ y : Fin n, y ≠ pursuer_strategy r := by
    exact fun r => ⟨ if pursuer_strategy r = ⟨ 0, by linarith ⟩ then ⟨ 1, by linarith ⟩ else ⟨ 0, by linarith ⟩, by aesop ⟩;
  exact ⟨ fun r => Classical.choose ( h_exists r ), fun r => Classical.choose_spec ( h_exists r ) ⟩



theorem countable_search_misses_almost_all (S : Set ℝ) (hS : S.Countable) :
    MeasureTheory.MeasureSpace.volume S = 0 := by
  exact hS.measure_zero MeasureTheory.MeasureSpace.volume



theorem baire_evasion {X : Type*} [TopologicalSpace X] [BaireSpace X] [Nonempty X]
    (searches : ℕ → Set X) (h_closed : ∀ n, IsClosed (searches n))
    (h_nwd : ∀ n, interior (searches n) = ∅) :
    ∃ x : X, ∀ n, x ∉ searches n := by
  -- Each complement is dense.
  have h_dense : ∀ n, Dense (searches n)ᶜ := by
    simp_all +decide [ Dense, Set.ext_iff ];
  -- The intersection of dense open sets is dense.
  have h_inter_dense : Dense (⋂ n, (searches n)ᶜ) := by
    exact dense_iInter_of_isOpen ( fun n => isOpen_compl_iff.mpr ( h_closed n ) ) h_dense;
  exact h_inter_dense.nonempty.imp fun x hx => by aesop;



theorem generic_evasion (targets : ℕ → Set ℝ)
    (h_closed : ∀ n, IsClosed (targets n))
    (h_nwd : ∀ n, interior (targets n) = ∅) :
    Dense (⋂ n, (targets n)ᶜ) := by
  exact dense_iInter_of_isOpen ( fun n => isOpen_compl_iff.mpr ( h_closed n ) ) fun n => by rw [ ← interior_eq_empty_iff_dense_compl ] ; aesop;



theorem remaining_uncertainty_lower_bound (n k : ℕ) (hk : k < n) :
    n - k ≥ 1 := by
  exact Nat.sub_pos_of_lt hk



theorem pigeonhole_evasion (n : ℕ) (queries : Finset (Fin (n + 1)))
    (hq : queries.card ≤ n) :
    ∃ pos : Fin (n + 1), pos ∉ queries := by
  exact Classical.not_forall.1 fun h => by have := Finset.eq_univ_of_forall h; aesop;



theorem adaptive_evader_wins (n : ℕ) (budget : ℕ) (h : budget < n) :
    ∀ queries : Finset (Fin n), queries.card ≤ budget →
    ∃ pos : Fin n, pos ∉ queries := by
  intro queries h_budget
  by_cases h_card : queries.card = n;
  · linarith;
  · exact not_forall.mp fun h' => h_card <| by simp [ show queries = Finset.univ from Finset.eq_univ_of_forall h' ]



theorem existence_of_total_avoider (f : ℕ → ℕ) :
    ∃ g : ℕ → ℕ, ∀ n, g n ≠ f n := by
  exact ⟨ fun n => f n + 1, fun n => Nat.succ_ne_self _ ⟩



theorem no_universal_enumeration :
    ¬ ∃ enum : ℕ → (ℕ → ℕ), Function.Surjective enum := by
  simp +zetaDelta at *;
  exact fun f hf => by rcases hf ( fun n => f n n + 1 ) with ⟨ n, hn ⟩ ; simpa using congr_fun hn n;



theorem infinite_evasion_finite_range (f : ℕ → ℕ) (hf : Set.Finite (Set.range f)) :
    Set.Infinite {n : ℕ | n ∉ Set.range f} := by
  exact hf.infinite_compl



theorem finite_repulsor {n : ℕ} (hn : 0 < n) (f : Fin n → Fin n)
    (hf : ∀ x, f x ≠ x) : ∀ x : Fin n, f x ≠ x := by
  assumption



theorem antitone_fixed_point_unique {α : Type*} [LinearOrder α] [OrderTop α] [OrderBot α]
    (f : α → α) (hf : Antitone f) (hfixed : ∃ x, f x = x) :
    ∃! x, f x = x := by
  obtain ⟨x₀, hx₀⟩ : ∃ x₀, f x₀ = x₀ := by
    exact hfixed
  have h_unique : ∀ x₁ x₂, f x₁ = x₁ → f x₂ = x₂ → x₁ ≤ x₂ → x₂ ≤ x₁ := by
    exact fun x₁ x₂ hx₁ hx₂ h => by simpa [ hx₁, hx₂ ] using hf h;
  have h_unique' : ∀ x₁ x₂, f x₁ = x₁ → f x₂ = x₂ → x₁ ≠ x₂ → False := by
    exact fun x₁ x₂ hx₁ hx₂ hne => hne <| le_antisymm ( by cases le_total x₁ x₂ <;> tauto ) ( by cases le_total x₁ x₂ <;> tauto )
  exact ⟨x₀, hx₀, fun x hx => by
    exact Classical.not_not.1 fun h => h_unique' x x₀ hx hx₀ h⟩



theorem displacement_repulsor (f : ℕ → ℕ) (hf : StrictMono f) (h0 : 0 < f 0) :
    ∀ n, f n ≠ n := by
  -- We proceed by induction on $n$.
  intro n
  induction' n with n ih;
  · linarith;
  · contrapose! ih with ih;
    exact le_antisymm ( Nat.le_of_lt_succ <| by linarith [ hf <| Nat.lt_succ_self n ] ) ( Nat.recOn n ( by linarith ) fun n ihn => by linarith [ hf <| Nat.lt_succ_self n ] )



theorem search_asymmetry (n : ℕ) (hn : 0 < n) :
    -- Any n queries suffice to find the target
    (∀ target : Fin n, ∃ queries : Finset (Fin n), queries.card ≤ n ∧ target ∈ queries) ∧
    -- But n-1 queries are never enough (evader survives)
    (∀ queries : Finset (Fin n), queries.card < n → ∃ target : Fin n, target ∉ queries) := by
  constructor;
  · exact fun x => ⟨ { x }, by simpa ⟩;
  · exact fun queries hqueries => by simpa using Finset.exists_of_ssubset ( Finset.ssubset_iff_subset_ne.mpr ⟨ Finset.subset_univ queries, fun h => by have := Finset.card_le_univ queries; aesop ⟩ ) ;



/-- **The Repulsor Hierarchy.**
Repulsors form a strict hierarchy: a Level-k repulsor evades all searches
of depth k, but not necessarily depth k+1.
Here we model this: a function evades an enumeration at level k if it
differs from the first k functions. -/
def evades_at_level (g : ℕ → ℕ) (enum : ℕ → (ℕ → ℕ)) (k : ℕ) : Prop :=
  ∀ i, i < k → g i ≠ enum i i



theorem level_k_evader_exists (enum : ℕ → (ℕ → ℕ)) (k : ℕ) :
    ∃ g : ℕ → ℕ, evades_at_level g enum k := by
  exact ⟨ fun n => enum n n + 1, fun i hi => by simp +decide ⟩



theorem level_hierarchy_strict (enum : ℕ → (ℕ → ℕ)) :
    ∀ k, (∃ g, evades_at_level g enum (k + 1)) →
         (∃ g, evades_at_level g enum k) := by
  exact fun k ⟨ g, hg ⟩ => ⟨ g, fun i hi => hg i ( Nat.lt_succ_of_lt hi ) ⟩



theorem infinite_repulsor_exists (enum : ℕ → (ℕ → ℕ)) :
    ∃ g : ℕ → ℕ, ∀ k, evades_at_level g enum k := by
  exact ⟨ fun n => enum n n + 1, fun k i hi => by simp +decide ⟩



theorem prob_evasion_bound (n k : ℕ) (hk : k ≤ n) (hn : 0 < n) :
    n - k ≤ n := by
  exact Nat.sub_le _ _



theorem repulsor_completion (enum : ℕ → (ℕ → ℕ)) (g_partial : ℕ → ℕ)
    (k : ℕ) (hk : evades_at_level g_partial enum k) :
    ∃ g_total : ℕ → ℕ, (∀ i, i < k → g_total i = g_partial i) ∧
    evades_at_level g_total enum (k + 1) := by
  -- Define the complete repulsor function g_total by extending g_partial to all natural numbers.
  use fun i => if i < k then g_partial i else enum i i + 1;
  unfold evades_at_level at *; aesop;



theorem negation_is_repulsor : ∀ n : ℤ, n ≠ 0 → -n ≠ n := by
  grind



theorem successor_is_repulsor : ∀ n : ℕ, n + 1 ≠ n := by
  exact fun n => Nat.succ_ne_self n



theorem mutual_repulsion_exists :
    ∃ (f g : ℕ → ℕ), (∀ n, f n ≠ n) ∧ (∀ n, g n ≠ n) ∧
    (∀ n, f (g n) ≠ n) := by
  simp +zetaDelta at *;
  exact ⟨ fun n => n + 1, fun n => by linarith, fun n => n + 2, fun n => by linarith, fun n => by linarith ⟩



end
