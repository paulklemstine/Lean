/-
# Derivability and Closure Completeness

This file defines inference rules, the one-step consequence operator `stepRules`,
inductive derivability, and proves the fundamental completeness theorem:
a formula belongs to the closure iff it is derivable from the axioms.
-/
import Mathlib
import Algebra.IdempotentClosure.Basic

open Finset Function

/-! ## Rule systems and consequence operators -/

/-- An inference rule with a finite set of premises and a single conclusion. -/
structure Rule (σ : Type) where
  premises : Finset σ
  conclusion : σ
  deriving DecidableEq

/-- The one-step consequence operator: adjoin all conclusions of rules
whose premises are contained in `S`. -/
def stepRules {σ : Type} [DecidableEq σ]
    (rules : Finset (Rule σ)) (S : Finset σ) : Finset σ :=
  S ∪ rules.biUnion (fun r =>
    if r.premises ⊆ S then {r.conclusion} else ∅)

/-
`stepRules` is monotone.
-/
lemma stepRules_mono {σ : Type} [DecidableEq σ]
    (rules : Finset (Rule σ)) {S T : Finset σ} (hST : S ⊆ T) :
    stepRules rules S ⊆ stepRules rules T := by
  refine Finset.union_subset_union hST ?_;
  grind

/-
`stepRules` is extensive (S ⊆ stepRules rules S).
-/
lemma stepRules_extensive {σ : Type} [DecidableEq σ]
    (rules : Finset (Rule σ)) (S : Finset σ) :
    S ⊆ stepRules rules S := by
  exact Finset.subset_union_left

/-! ## Inductive derivability -/

/-- Inductive derivability from axioms `A` using inference `rules`. -/
inductive Derivable {σ : Type} (rules : Finset (Rule σ))
    (A : Finset σ) : σ → Prop where
  | axiom_ (φ : σ) (h : φ ∈ A) : Derivable rules A φ
  | rule_ (r : Rule σ) (hr : r ∈ rules)
      (hprem : ∀ p ∈ r.premises, Derivable rules A p) :
      Derivable rules A r.conclusion

/-! ## Soundness and completeness -/

/-
Soundness: every derivable formula belongs to some iterate of `stepRules`.
-/
lemma derivable_mem_iterate {σ : Type} [DecidableEq σ]
    (rules : Finset (Rule σ)) (A : Finset σ) (φ : σ)
    (hd : Derivable rules A φ) :
    ∃ n, φ ∈ (stepRules rules)^[n] A := by
  -- By induction on the derivation of `φ`, we can find a natural number `n` such that `φ` is in the `n`th iterate of `stepRules` applied to `A`.
  have h_ind : ∀ {φ : σ}, Derivable rules A φ → ∃ n, φ ∈ (stepRules rules)^[n] A := by
    intro φ hφ
    induction' hφ with φ hφ ih;
    · exact ⟨ 0, hφ ⟩;
    · rename_i hprem hprem_ih;
      -- Let $N$ be the maximum of the indices $n_p$ for all premises $p$ of $ih$.
      obtain ⟨N, hN⟩ : ∃ N, ∀ p ∈ ih.premises, p ∈ (stepRules rules)^[N] A := by
        choose! n hn using hprem_ih;
        use Finset.sup ih.premises n;
        intro p hp;
        exact Nat.le_induction ( by aesop ) ( fun k hk ih => by simpa only [ Function.iterate_succ_apply' ] using stepRules_extensive _ _ |> fun h => h ih ) _ ( show n p ≤ Finset.sup ih.premises n from Finset.le_sup ( f := n ) hp );
      use N + 1;
      simp_all +decide [ Function.iterate_succ_apply', stepRules ];
      grind +suggestions;
  exact h_ind hd

/-
Completeness: every element of an iterate is derivable.
-/
lemma mem_iterate_derivable {σ : Type} [DecidableEq σ]
    (rules : Finset (Rule σ)) (A : Finset σ) (φ : σ) (n : ℕ)
    (hm : φ ∈ (stepRules rules)^[n] A) :
    Derivable rules A φ := by
  induction' n with n ih generalizing φ <;> simp_all +decide [ Function.iterate_succ_apply' ];
  · exact Derivable.axiom_ φ hm;
  · unfold stepRules at hm;
    simp +zetaDelta at *;
    -- If φ is in the biUnion, then there exists a rule r in rules such that r.premises ⊆ stepRules^[n] A and φ = r.conclusion.
    obtain h | ⟨r, hr, hprem⟩ := hm;
    · exact ih φ h;
    · split_ifs at hprem <;> simp_all +decide [ Finset.subset_iff ];
      exact Derivable.rule_ r hr fun p hp => ih p <| by solve_by_elim;

/-- Noncomputable closure: the least fixed point of `stepRules` above `A`. -/
noncomputable def ruleClosure {σ : Type} [DecidableEq σ] [Fintype σ]
    (rules : Finset (Rule σ)) (A : Finset σ) : Finset σ :=
  (closure_is_least_fixed_point (stepRules rules)
    (fun h => stepRules_mono rules h) (stepRules_extensive rules) A).choose

lemma ruleClosure_spec {σ : Type} [DecidableEq σ] [Fintype σ]
    (rules : Finset (Rule σ)) (A : Finset σ) :
    A ⊆ ruleClosure rules A ∧
    stepRules rules (ruleClosure rules A) = ruleClosure rules A ∧
    ∀ D : Finset σ, A ⊆ D → stepRules rules D = D → ruleClosure rules A ⊆ D :=
  (closure_is_least_fixed_point (stepRules rules)
    (fun h => stepRules_mono rules h) (stepRules_extensive rules) A).choose_spec

/-
A formula belongs to the closure iff it belongs to some iterate.
-/
lemma mem_ruleClosure_iff_mem_iterate {σ : Type} [DecidableEq σ] [Fintype σ]
    (rules : Finset (Rule σ)) (A : Finset σ) (φ : σ) :
    φ ∈ ruleClosure rules A ↔ ∃ n, φ ∈ (stepRules rules)^[n] A := by
  constructor <;> intro h;
  · -- By the definition of closure, if φ is in the closure, then there exists some n such that φ is in the nth iterate of stepRules on A.
    have h_iter : ∃ n, ruleClosure rules A ⊆ (stepRules rules)^[n] A := by
      have := finite_monotone_closure_stabilizes ( stepRules rules ) ( fun h => stepRules_mono rules h ) ( stepRules_extensive rules ) A;
      obtain ⟨ N, hN ⟩ := this;
      have := ruleClosure_spec rules A;
      exact ⟨ N, this.2.2 _ ( iterate_above_start _ ( stepRules_extensive rules ) _ _ ) ( by simpa only [ Function.iterate_succ_apply' ] using hN.symm ) ⟩;
    exact ⟨ h_iter.choose, h_iter.choose_spec h ⟩;
  · cases' h with n hn
    have h_sub : (stepRules rules)^[n] A ⊆ ruleClosure rules A := by
      grind +suggestions
    exact h_sub hn

/-
**Derivability–Closure Completeness**: A formula is derivable from
axioms `A` using `rules` if and only if it belongs to the closure of `A`
under the consequence operator. This identifies emergent closure with
proof-theoretic derivability.
-/
theorem derivable_iff_mem_closure
    {σ : Type} [DecidableEq σ] [Fintype σ]
    (rules : Finset (Rule σ)) (A : Finset σ) (φ : σ) :
    Derivable rules A φ ↔ φ ∈ ruleClosure rules A := by
  constructor;
  · exact fun h => mem_ruleClosure_iff_mem_iterate rules A φ |>.2 ( derivable_mem_iterate rules A φ h );
  · exact fun h => by obtain ⟨ n, hn ⟩ := ( mem_ruleClosure_iff_mem_iterate rules A φ ).mp h; exact mem_iterate_derivable rules A φ n hn;