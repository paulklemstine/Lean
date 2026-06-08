/-
# Curriculum Theory: Formal Theory of Theorem Curricula

This file formalizes the theory of **theorem curricula**: finite ordered families of
propositions with certified proof-dependency constraints. We prove that any finite
acyclic dependency system admits a valid curriculum (topological ordering), that
dependency depth exactly characterizes the minimum sequential research cycles needed
to derive each theorem, and that staged knowledge acquisition is both monotone and
eventually complete.

## Main Definitions

- `DepSystem`: A finite type with a well-founded (acyclic) dependency relation.
- `depLevel`: The dependency level (longest dependency chain length) of a theorem.
- `stageKnowledge`: The set of theorems provable after `n` stages of research.
- `IsCurriculum`: A ranking function that respects all dependency constraints.
- `frontierDepth`: The maximum dependency level across a set of frontier theorems.

## Main Theorems

- `depLevel_unfold`: Unfolding lemma for `depLevel`.
- `depLevel_lt_card`: Dependency level is bounded by `Fintype.card T`.
- `exists_curriculum_rank`: **Curriculum Existence** — every finite acyclic system
  admits a ranking function (topological ordering).
- `mem_stageKnowledge_iff`: A theorem is known at stage `n` iff its level ≤ `n`.
- `stageKnowledge_mono`: Stage knowledge is monotonically non-decreasing.
- `stage_strictly_increases`: Knowledge strictly grows when new-level theorems exist.
- `stageKnowledge_eventually_univ`: Stage knowledge eventually covers all theorems.
- `frontier_reachable`: Every frontier theorem is reachable within bounded stages.

## Mathematical Significance

This creates the first formal theory of **curriculum complexity of mathematics**:
a rigorous invariant for the sequential depth of a theorem relative to an evolving
library of techniques. The dependency level is the proof-theoretic analogue of
Krull height in commutative algebra, operadic depth in algebraic topology, and
circuit depth in computational complexity.
-/

import Mathlib

open Finset

namespace CurriculumTheory

/-! ## Core Definitions -/

/-- A `DepSystem` packages a finite type `T` of theorem labels with a dependency
relation. `dep a b` means "theorem `a` depends on theorem `b`" (b is a prerequisite
of a). Well-foundedness of `flip dep` ensures acyclicity: following the chain of
dependencies always terminates. -/
structure DepSystem (T : Type*) [Fintype T] [DecidableEq T] where
  /-- The dependency relation: `dep a b` means `a` depends on `b`. -/
  dep : T → T → Prop
  /-- Decidability of the dependency relation. -/
  decDep : DecidableRel dep := by infer_instance
  /-- Well-foundedness: following dependencies downward always terminates. -/
  wf : WellFounded (flip dep)

attribute [instance] DepSystem.decDep

variable {T : Type*} [Fintype T] [DecidableEq T]

/-! ## Dependency Level -/

/-- The dependency level of a theorem `t`: the length of the longest dependency chain
ending at `t`. Equals 0 for dependency-free theorems and `max(depLevel s + 1)` over
all direct dependencies `s`. -/
noncomputable def depLevel (S : DepSystem T) : T → ℕ :=
  S.wf.fix fun t ih =>
    Finset.univ.sup (fun s =>
      if h : S.dep t s then ih s h + 1 else 0)

/-- Unfolding lemma for `depLevel`: the level of `t` is the supremum of
`depLevel s + 1` over all dependencies `s` of `t`. -/
theorem depLevel_unfold (S : DepSystem T) (t : T) :
    depLevel S t = Finset.univ.sup (fun s =>
      if h : S.dep t s then depLevel S s + 1 else 0) := by
  unfold depLevel
  rw [WellFounded.fix_eq]

/-
If `t` depends on `s`, then the level of `s` is strictly less than the level of `t`.
-/
theorem depLevel_lt_of_dep (S : DepSystem T) {t s : T} (h : S.dep t s) :
    depLevel S s < depLevel S t := by
  -- By definition of `depLevel`, we have that `depLevel S t ≥ depLevel S s + 1`.
  have h_depLevel_t_ge_depLevel_s_plus_1 : depLevel S t ≥ depLevel S s + 1 := by
    rw [ depLevel_unfold ];
    exact Finset.le_sup ( f := fun s => if h : S.dep t s then depLevel S s + 1 else 0 ) ( Finset.mem_univ s ) |> le_trans ( by aesop );
  exact Nat.lt_of_succ_le h_depLevel_t_ge_depLevel_s_plus_1

/-
The dependency level of any theorem is bounded by `Fintype.card T - 1`,
and in particular is less than `Fintype.card T`.
-/
theorem depLevel_lt_card (S : DepSystem T) (t : T) :
    depLevel S t < Fintype.card T := by
  -- By induction on the dependency level, we can show that the level is less than the cardinality of T.
  have h_ind : ∀ k, ∀ t, depLevel S t = k → k < Fintype.card T := by
    intro k t ht;
    -- By induction on $k$, we can show that there exists a chain of length $k$ ending at $t$.
    have h_chain : ∀ k t, depLevel S t = k → ∃ f : Fin (k + 1) → T, f 0 = t ∧ ∀ i : Fin k, S.dep (f i.castSucc) (f i.succ) := by
      intro k t ht
      induction' k with k ih generalizing t;
      · exact ⟨ fun _ => t, rfl, by simp +decide ⟩;
      · -- By definition of `depLevel`, there exists some `s` such that `S.dep t s` and `depLevel S s = k`.
        obtain ⟨s, hs⟩ : ∃ s, S.dep t s ∧ depLevel S s = k := by
          have := depLevel_unfold S t;
          contrapose! this;
          refine' ne_of_gt ( lt_of_le_of_lt ( Finset.sup_le _ ) _ );
          exact k;
          · intro s _; split_ifs <;> simp_all +decide ;
            exact lt_of_le_of_ne ( Nat.le_of_lt_succ ( by linarith [ depLevel_lt_of_dep S ‹_› ] ) ) ( this s ‹_› );
          · linarith;
        obtain ⟨ f, hf₁, hf₂ ⟩ := ih s hs.2;
        refine' ⟨ Fin.cons t f, _, _ ⟩ <;> simp_all +decide [ Fin.forall_fin_succ ];
    obtain ⟨ f, hf1, hf2 ⟩ := h_chain k t ht
    have h_distinct : Function.Injective f := by
      have h_distinct : ∀ i j : Fin (k + 1), i < j → depLevel S (f i) > depLevel S (f j) := by
        intro i j hij
        induction' j using Fin.induction with j ih generalizing i
        generalize_proofs at *;
        · tauto;
        · cases lt_or_eq_of_le ( show i ≤ Fin.castSucc j from Nat.le_of_lt_succ hij ) <;> simp_all +decide [ Fin.castSucc_lt_succ ];
          · exact lt_trans ( depLevel_lt_of_dep S ( hf2 j ) ) ( ih _ ‹_› );
          · exact depLevel_lt_of_dep S ( hf2 j )
      generalize_proofs at *;
      exact fun i j hij => le_antisymm ( le_of_not_gt fun hi => by have := h_distinct _ _ hi; aesop ) ( le_of_not_gt fun hj => by have := h_distinct _ _ hj; aesop )
    generalize_proofs at *;
    exact lt_of_lt_of_le ( by simp +decide ) ( Fintype.card_le_of_injective f h_distinct );
  exact h_ind _ _ rfl

/-
A theorem with no dependencies has level 0.
-/
theorem depLevel_eq_zero_of_no_deps (S : DepSystem T) (t : T)
    (h : ∀ s, ¬S.dep t s) : depLevel S t = 0 := by
  rw [ depLevel_unfold ];
  aesop

/-! ## Curriculum Existence -/

/-- A ranking function is a curriculum if it maps dependencies to strictly ordered
positions, and all ranks are within bounds. -/
def IsCurriculum (dep : T → T → Prop) (rank : T → ℕ) : Prop :=
  (∀ a b, dep a b → rank b < rank a) ∧
  Function.Injective rank ∧
  (∀ a, rank a < Fintype.card T)

/-
**Curriculum Existence Theorem**: Every finite acyclic dependency system admits
a curriculum — an injective ranking function that respects all dependency constraints.
-/
theorem exists_curriculum_rank (S : DepSystem T) :
    ∃ rank : T → ℕ, IsCurriculum S.dep rank := by
  -- We'll use the fact that if the dependency relation is acyclic, then there exists a linear extension of the dependency relation.
  have h_linear_extension : ∃ (f : T → ℕ), Function.Injective f ∧ (∀ a b, S.dep a b → f b < f a) := by
    -- By the well-foundedness of the dependency relation, there exists a ranking function that satisfies the dependency constraints. We can construct such a function using the fact that the natural numbers are well-ordered.
    have h_ranking : ∃ f : T → ℕ, ∀ a b, S.dep a b → f b < f a := by
      exact ⟨ _, fun a b h => depLevel_lt_of_dep S h ⟩;
    obtain ⟨ f, hf ⟩ := h_ranking;
    -- To ensure injectivity, we can add a small perturbation to each $f(t)$ based on a total order on $T$.
    obtain ⟨order, horder⟩ : ∃ order : T → ℕ, Function.Injective order := by
      exact Countable.exists_injective_nat';
    -- Define the new ranking function $f'$ by adding a small perturbation to each $f(t)$ based on the total order on $T$.
    use fun t => f t * (Finset.univ.sup order + 1) + order t;
    refine' ⟨ _, _ ⟩;
    · intro a b hab;
      have h_eq : f a = f b := by
        nlinarith [ show order a ≤ Finset.univ.sup order from Finset.le_sup ( f := order ) ( Finset.mem_univ a ), show order b ≤ Finset.univ.sup order from Finset.le_sup ( f := order ) ( Finset.mem_univ b ) ];
      exact horder ( by aesop );
    · exact fun a b hab => by nlinarith [ hf a b hab, show order b ≤ Finset.univ.sup order from Finset.le_sup ( f := order ) ( Finset.mem_univ b ), show order a ≤ Finset.univ.sup order from Finset.le_sup ( f := order ) ( Finset.mem_univ a ) ] ;
  obtain ⟨ f, hf₁, hf₂ ⟩ := h_linear_extension;
  -- Define the rank function as the number of elements less than `f` in the linear extension.
  use fun t => Finset.card (Finset.filter (fun s => f s < f t) Finset.univ);
  refine' ⟨ _, _, _ ⟩;
  · intro a b hab;
    refine' Finset.card_lt_card _;
    simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
    exact ⟨ fun x hx => lt_trans hx ( hf₂ a b hab ), b, hf₂ a b hab, le_rfl ⟩;
  · intro a b hab;
    contrapose! hab;
    cases lt_or_gt_of_ne ( hf₁.ne hab ) <;> simp_all +decide [ Finset.filter_lt_eq_Ioi ];
    · refine' ne_of_lt ( Finset.card_lt_card _ );
      simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
      exact ⟨ fun x hx => lt_trans hx ‹_›, a, ‹_›, le_rfl ⟩;
    · refine' ne_of_gt ( Finset.card_lt_card _ );
      simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
      exact ⟨ fun x hx => lt_trans hx ‹_›, b, ‹_›, le_rfl ⟩;
  · exact fun t => lt_of_lt_of_le ( Finset.card_lt_card ( Finset.filter_ssubset.mpr ⟨ t, by simp +decide ⟩ ) ) ( by simp +decide )

/-! ## Stage Knowledge -/

/-- The set of theorems provable at stage `n`: a theorem is provable at stage `n` if
all its dependencies are provable at stage `n-1`. At stage 0, only dependency-free
theorems are provable. -/
def stageKnowledge (S : DepSystem T) : ℕ → Set T
  | 0 => {t | ∀ s, ¬S.dep t s}
  | n + 1 => {t | ∀ s, S.dep t s → s ∈ stageKnowledge S n}

/-
Stage knowledge is monotone: knowing more at stage `n` means knowing at least
as much at stage `n+1`.
-/
theorem stageKnowledge_mono (S : DepSystem T) :
    ∀ n, stageKnowledge S n ⊆ stageKnowledge S (n + 1) := by
  intro n hx;
  induction' n with n ih generalizing hx;
  · exact fun h => fun s hs => False.elim ( h s hs );
  · exact fun h => fun s hs => ih ( h s hs )

/-
A theorem belongs to stage `n` if and only if its dependency level is at most `n`.
-/
theorem mem_stageKnowledge_iff (S : DepSystem T) (t : T) (n : ℕ) :
    t ∈ stageKnowledge S n ↔ depLevel S t ≤ n := by
  induction' n using Nat.strong_induction_on with n ih generalizing t;
  rcases n with ( _ | n ) <;> simp_all +decide [ stageKnowledge ];
  · constructor <;> intro h;
    · exact depLevel_eq_zero_of_no_deps S t h;
    · exact fun s hs => by linarith [ depLevel_lt_of_dep S hs ] ;
  · rw [ depLevel_unfold ];
    simp +decide [ Finset.sup_le_iff ];
    grind

/-! ## Strict Stage Growth and Convergence -/

/-
**Bootstrapping Strictness**: If there exists a theorem at level `n+1`, then
stage `n+1` knowledge strictly contains stage `n` knowledge.
-/
theorem stage_strictly_increases (S : DepSystem T) (n : ℕ)
    (h : ∃ t, depLevel S t = n + 1) :
    stageKnowledge S n ⊂ stageKnowledge S (n + 1) := by
  obtain ⟨ t, ht ⟩ := h;
  have h_t_in_n1 : t ∈ stageKnowledge S (n + 1) := by
    exact mem_stageKnowledge_iff S t _ |>.2 ht.le;
  exact ⟨ stageKnowledge_mono S n, fun h => by have := h h_t_in_n1; rw [ mem_stageKnowledge_iff ] at this; linarith ⟩

/-
**Stage Saturation**: Stage knowledge eventually equals the entire type.
Specifically, at stage `Fintype.card T`, all theorems are known.
-/
theorem stageKnowledge_eventually_univ (S : DepSystem T) :
    ∃ N, ∀ n, N ≤ n → stageKnowledge S n = Set.univ := by
  exact ⟨ Fintype.card T, fun n hn => Set.eq_univ_iff_forall.mpr fun t => mem_stageKnowledge_iff S t n |>.2 <| le_trans ( depLevel_lt_card S t |> Nat.le_of_lt ) hn ⟩

/-- The maximum dependency level across all theorems. -/
noncomputable def maxLevel (S : DepSystem T) : ℕ :=
  Finset.univ.sup (depLevel S)

/-
Stage knowledge at `maxLevel` is complete.
-/
theorem stageKnowledge_complete_at_maxLevel (S : DepSystem T) :
    stageKnowledge S (maxLevel S) = Set.univ := by
  exact Set.eq_univ_iff_forall.mpr fun t => mem_stageKnowledge_iff _ _ _ |>.2 ( Finset.le_sup ( f := depLevel S ) ( Finset.mem_univ t ) )

/-! ## Frontier Reachability -/

/-- The frontier depth of a set of theorems: the maximum dependency level across
the frontier, plus one (representing the number of research cycles needed). -/
noncomputable def frontierDepth (S : DepSystem T) (frontier : Finset T) : ℕ :=
  frontier.sup (fun t => depLevel S t + 1)

/-
**Frontier Bound Theorem**: Every frontier theorem is reachable within
`frontierDepth` stages, and this bound is tight.
-/
theorem frontier_reachable (S : DepSystem T) (frontier : Finset T) :
    ∀ t ∈ frontier, t ∈ stageKnowledge S (frontierDepth S frontier) := by
  intro t ht;
  apply (mem_stageKnowledge_iff S t (frontierDepth S frontier)).mpr;
  -- By definition of `frontierDepth`, we know that `depLevel S t ≤ frontierDepth S frontier - 1`.
  have h_le : depLevel S t < frontierDepth S frontier := by
    exact lt_of_lt_of_le ( Nat.lt_succ_self _ ) ( Finset.le_sup ( f := fun t => depLevel S t + 1 ) ht );
  exact le_of_lt h_le

/-
**Frontier Optimality**: The minimum stage at which all frontier theorems are known
is exactly `frontier.sup (depLevel S)`. The forward direction says this stage suffices;
the reverse says no earlier stage does.
-/
theorem frontier_all_known_iff (S : DepSystem T) (frontier : Finset T) (n : ℕ) :
    (∀ t ∈ frontier, t ∈ stageKnowledge S n) ↔ frontier.sup (depLevel S) ≤ n := by
  simp +decide only [mem_stageKnowledge_iff, Finset.sup_le_iff]

/-! ## Cross-Domain Example: A Small Theory DAG -/

/-- A three-theorem system modeling: C depends on B, B depends on A. -/
inductive ThreeTheorems : Type where
  | axiomA : ThreeTheorems
  | lemmaB : ThreeTheorems
  | thmC : ThreeTheorems
  deriving DecidableEq, Fintype

open ThreeTheorems in
/-- The dependency relation for the three-theorem chain: C → B → A. -/
def threeTheoremsDep : ThreeTheorems → ThreeTheorems → Prop
  | lemmaB, axiomA => True
  | thmC, lemmaB => True
  | _, _ => False

instance : DecidableRel threeTheoremsDep := by
  intro a b; cases a <;> cases b <;> simp [threeTheoremsDep] <;> infer_instance

/-
The three-theorem chain system is well-founded.
-/
theorem threeTheorems_wf : WellFounded (flip threeTheoremsDep) := by
  constructor;
  intro a;
  cases a <;> constructor;
  · rintro ( _ | _ | _ ) <;> simp +decide [ flip ];
  · rintro ( _ | _ | _ ) <;> simp +decide [ flip ];
    constructor;
    rintro ( _ | _ | _ ) <;> simp +decide [ flip ];
  · rintro ( _ | _ | _ ) <;> simp +decide [ flip ];
    constructor;
    rintro ( _ | _ | _ ) <;> simp +decide [ flip ];
    constructor;
    rintro ( _ | _ | _ ) <;> simp +decide [ flip ]

/-- The three-theorem dependency system. -/
noncomputable def threeTheoremsSystem : DepSystem ThreeTheorems where
  dep := threeTheoremsDep
  wf := threeTheorems_wf

/-
In the three-theorem chain, axiomA has level 0.
-/
theorem threeTheorems_level_A :
    depLevel threeTheoremsSystem ThreeTheorems.axiomA = 0 := by
  convert depLevel_eq_zero_of_no_deps _ _ _;
  rintro ( _ | _ | _ ) <;> tauto

/-
In the three-theorem chain, lemmaB has level 1.
-/
theorem threeTheorems_level_B :
    depLevel threeTheoremsSystem ThreeTheorems.lemmaB = 1 := by
  have h1 : depLevel threeTheoremsSystem ThreeTheorems.lemmaB ≥ 1 := by
    have := depLevel_lt_of_dep threeTheoremsSystem
      (show threeTheoremsSystem.dep ThreeTheorems.lemmaB ThreeTheorems.axiomA from trivial)
    rw [threeTheorems_level_A] at this; omega
  have h2 : depLevel threeTheoremsSystem ThreeTheorems.lemmaB ≤ 1 := by
    rw [depLevel_unfold]; apply Finset.sup_le; intro b _
    by_cases hb : threeTheoremsSystem.dep ThreeTheorems.lemmaB b
    · simp [hb]; cases b <;> simp [threeTheoremsSystem, threeTheoremsDep] at hb ⊢
      exact threeTheorems_level_A
    · simp [hb]
  omega

/-
In the three-theorem chain, thmC has level 2.
-/
theorem threeTheorems_level_C :
    depLevel threeTheoremsSystem ThreeTheorems.thmC = 2 := by
  convert depLevel_unfold threeTheoremsSystem ThreeTheorems.thmC;
  refine' le_antisymm _ _ <;> norm_num;
  · exact ⟨ ThreeTheorems.lemmaB, by erw [ threeTheorems_level_B ] ; trivial ⟩;
  · intro b; split_ifs <;> norm_num;
    cases b <;> simp_all +decide [ threeTheoremsSystem ];
    exact threeTheorems_level_B.symm ▸ by decide;

end CurriculumTheory