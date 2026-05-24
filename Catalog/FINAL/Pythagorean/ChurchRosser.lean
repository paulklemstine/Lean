import DeBruijn.SubstAlgebra

/-!
# Church-Rosser Theorem via Parallel Reduction (De Bruijn Indices)

This file proves the confluence of beta-reduction for the untyped lambda calculus
with de Bruijn indices, using the standard Tait–Martin-Löf parallel reduction
method with Takahashi's complete development.

## Main Results

* `substEnv_parBeta` — substitution respects parallel reduction
* `subst_parBeta` / `subst_parBeta_gen` — unary substitution compatibility
* `ParBetaDB.to_star` — parallel reduction embeds into beta-star
* `parBeta_diamond` — diamond property of parallel reduction
* `church_rosser_db` — Church-Rosser / confluence of beta reduction
* `diamond_of_completeDevelopment` — generic diamond from complete developments
-/

namespace DeBruijn

open LamDB

/-! ## Reduction Relations -/

/-- One-step beta reduction in de Bruijn indexed lambda calculus. -/
inductive BetaDB : LamDB → LamDB → Prop where
  | beta (body arg : LamDB) :
      BetaDB (.app (.lam body) arg) (subst0 arg body)
  | appL {t t' : LamDB} (u : LamDB) :
      BetaDB t t' → BetaDB (.app t u) (.app t' u)
  | appR (t : LamDB) {u u' : LamDB} :
      BetaDB u u' → BetaDB (.app t u) (.app t u')
  | lam {t t' : LamDB} :
      BetaDB t t' → BetaDB (.lam t) (.lam t')

/-- Parallel beta reduction: contracts zero or more redexes simultaneously. -/
inductive ParBetaDB : LamDB → LamDB → Prop where
  | var (k : Nat) : ParBetaDB (.var k) (.var k)
  | app {t t' u u' : LamDB} :
      ParBetaDB t t' → ParBetaDB u u' →
      ParBetaDB (.app t u) (.app t' u')
  | lam {t t' : LamDB} :
      ParBetaDB t t' → ParBetaDB (.lam t) (.lam t')
  | beta {body body' arg arg' : LamDB} :
      ParBetaDB body body' → ParBetaDB arg arg' →
      ParBetaDB (.app (.lam body) arg) (subst0 arg' body')

/-! ## Basic Properties of Parallel Reduction -/

/-
Parallel reduction is reflexive.
-/
theorem ParBetaDB.refl : ∀ (t : LamDB), ParBetaDB t t := by
  intro t; induction t <;> tauto;

/-
One-step beta embeds into parallel reduction.
-/
theorem BetaDB.to_parBeta {t u : LamDB} (h : BetaDB t u) : ParBetaDB t u := by
  induction h;
  · exact ParBetaDB.beta ( ParBetaDB.refl _ ) ( ParBetaDB.refl _ );
  · exact .app ‹_› ( ParBetaDB.refl _ );
  · exact ParBetaDB.app ( ParBetaDB.refl _ ) ‹_›;
  · exact ParBetaDB.lam ‹_›

/-! ## Substitution Preserves Parallel Reduction -/

/-
Renaming preserves parallel reduction.
-/
theorem rename_parBeta {ρ : Renaming} {t t' : LamDB}
    (h : ParBetaDB t t') : ParBetaDB (rename ρ t) (rename ρ t') := by
  induction h generalizing ρ;
  · exact ParBetaDB.refl _;
  · exact ParBetaDB.app ( by solve_by_elim ) ( by solve_by_elim );
  · solve_by_elim;
  · rename_i h₁ h₂ h₃ h₄;
    convert ParBetaDB.beta ( h₃ ) ( h₄ ) using 1;
    exact rename_subst0 ..

/-
**Key theorem**: Simultaneous substitution preserves parallel reduction.
-/
theorem substEnv_parBeta {σ τ : SubstEnv} {t u : LamDB}
    (hσ : ∀ n, ParBetaDB (σ n) (τ n))
    (ht : ParBetaDB t u) :
    ParBetaDB (substEnv σ t) (substEnv τ u) := by
  -- Apply the induction hypothesis to the body and argument.
  have h_ind : ∀ t u, ParBetaDB t u → ∀ σ τ : SubstEnv, (∀ n, ParBetaDB (σ n) (τ n)) → ParBetaDB (substEnv σ t) (substEnv τ u) := by
    intros t u htu σ τ hσ; induction htu generalizing σ τ; all_goals generalize_proofs at *;
    · exact hσ _;
    · exact ParBetaDB.app ( by solve_by_elim ) ( by solve_by_elim );
    · apply ParBetaDB.lam; exact (by
      apply_assumption;
      intro n; induction n <;> simp_all +decide [ SubstEnv.lift ] ;
      · constructor;
      · exact rename_parBeta ( hσ _ ));
    · rename_i h₁ h₂ h₃ h₄;
      convert ParBetaDB.beta ( h₃ _ _ _ ) ( h₄ _ _ _ ) using 1;
      convert substEnv_beta_comm τ _ _ using 1;
      · intro n; induction n <;> simp_all +decide [ SubstEnv.lift ] ;
        · constructor;
        · exact rename_parBeta ( hσ _ );
      · assumption;
  exact h_ind t u ht σ τ hσ

/-! ## Derived Substitution-Compatibility Theorems -/

/-- Substitution at variable 0 respects parallel reduction. -/
theorem subst_parBeta {t t' s s' : LamDB}
    (ht : ParBetaDB t t') (hs : ParBetaDB s s') :
    ParBetaDB (subst0 s t) (subst0 s' t') := by
  apply substEnv_parBeta _ ht
  intro n; cases n with
  | zero => exact hs
  | succ n => exact ParBetaDB.var n

/-- General substitution at any index respects parallel reduction. -/
theorem subst_parBeta_gen {k : Nat} {t t' s s' : LamDB}
    (ht : ParBetaDB t t') (hs : ParBetaDB s s') :
    ParBetaDB (subst k s t) (subst k s' t') := by
  apply substEnv_parBeta _ ht
  intro n
  show ParBetaDB (if n < k then var n else if n = k then s else var (n - 1))
       (if n < k then var n else if n = k then s' else var (n - 1))
  split
  · exact ParBetaDB.var n
  · split
    · exact hs
    · exact ParBetaDB.var (n - 1)

/-! ## Complete Development (Takahashi's ⋆-translation) -/

/-- The complete development: simultaneously contracts all redexes. -/
def develop : LamDB → LamDB
  | .var k => .var k
  | .app (.lam body) arg => subst0 (develop arg) (develop body)
  | .app t u => .app (develop t) (develop u)
  | .lam t => .lam (develop t)

/-
Every term reduces in parallel to its complete development.
-/
theorem develop_reflects (t : LamDB) : ParBetaDB t (develop t) := by
  induction' t using LamDB.recOn with t u ih_t ih_u t ih_t;
  · exact ParBetaDB.var _;
  · cases u <;> simp_all +decide [ develop ];
    · exact ParBetaDB.app ( ParBetaDB.var _ ) t;
    · exact ParBetaDB.app ih_u t;
    · convert ParBetaDB.beta _ t using 1;
      cases ih_u ; tauto;
  · exact ParBetaDB.lam ‹_›

/-
**Triangle property**: every parallel reduct of `t` further reduces
    to the complete development of `t`.
-/
theorem develop_triangle {t u : LamDB}
    (h : ParBetaDB t u) : ParBetaDB u (develop t) := by
  -- Let's prove the auxiliary lemma: if ParBetaDB t u, then ParBetaDB u (develop t).
  have h_aux : ∀ t u : LamDB, ParBetaDB t u → ParBetaDB u (develop t) := by
    intro t u h
    induction' h with t' u' h';
    · exact ParBetaDB.var _;
    · rename_i h'' u''op;
      rename_i h''op aesop;
      cases u' <;> cases ‹LamDB› <;> simp +decide [ *,develop ] at *;
      all_goals try { exact ParBetaDB.app h'' u''op };
      · cases h''op;
        cases ‹ParBetaDB ( var _ ) _› ; tauto;
      · cases h''op;
        cases ‹ParBetaDB _ _›;
        exact ParBetaDB.beta (by assumption) (by assumption);
      · cases h''op;
        apply ParBetaDB.beta;
        · cases h'';
          assumption;
        · assumption;
    · exact ParBetaDB.lam ‹_›;
    · apply subst_parBeta;
      · assumption;
      · assumption;
  exact h_aux t u h

/-! ## Diamond Property and Church-Rosser -/

/-- **Generic diamond from complete development**: any relation that admits
    a complete development operator satisfies the diamond property.
    This is a cross-domain abstraction applicable to any rewriting system. -/
theorem diamond_of_completeDevelopment
    {α : Type*} {P : α → α → Prop} {dev : α → α}
    (_h_dev : ∀ a, P a (dev a))
    (h_tri : ∀ a b, P a b → P b (dev a))
    {a b c : α} (hab : P a b) (hac : P a c) :
    ∃ d, P b d ∧ P c d :=
  ⟨dev a, h_tri a b hab, h_tri a c hac⟩

/-- **Diamond property of parallel beta reduction**. -/
theorem parBeta_diamond {t u v : LamDB}
    (hu : ParBetaDB t u) (hv : ParBetaDB t v) :
    ∃ w, ParBetaDB u w ∧ ParBetaDB v w :=
  diamond_of_completeDevelopment develop_reflects
    (fun _ _ h => develop_triangle h) hu hv

/-
Parallel reduction embeds into beta-star.
-/
theorem ParBetaDB.to_star {t u : LamDB}
    (h : ParBetaDB t u) : Relation.ReflTransGen BetaDB t u := by
  induction' h;
  · grind;
  · rename_i t t' u u' ht hu ih₁ ih₂;
    have h_lift : ∀ {t t' : LamDB}, Relation.ReflTransGen BetaDB t t' → ∀ {u : LamDB}, Relation.ReflTransGen BetaDB (t.app u) (t'.app u) := by
      intros t t' ht u; induction ht; aesop;
      exact Relation.ReflTransGen.tail ‹_› ( BetaDB.appL _ ‹_› );
    have h_lift : ∀ {t : LamDB}, ∀ {u u' : LamDB}, Relation.ReflTransGen BetaDB u u' → Relation.ReflTransGen BetaDB (t.app u) (t.app u') := by
      intros t u u' hu; induction hu; aesop;
      exact Relation.ReflTransGen.trans ‹_› ( Relation.ReflTransGen.single ( BetaDB.appR _ ‹_› ) );
    exact Relation.ReflTransGen.trans ( by solve_by_elim ) ( h_lift ih₂ );
  · rename_i t t' h ih;
    have h_lift : ∀ {t u : LamDB}, Relation.ReflTransGen BetaDB t u → Relation.ReflTransGen BetaDB (LamDB.lam t) (LamDB.lam u) := by
      intros t u h; induction h; aesop;
      exact Relation.ReflTransGen.tail ‹_› ( BetaDB.lam ‹_› );
    exact h_lift ih;
  · rename_i body body' arg arg' h₁ h₂ h₃ h₄;
    -- By the induction hypothesis, we have that `body.lam.app arg` reduces to `body'.lam.app arg'`.
    have h_ind : Relation.ReflTransGen BetaDB (body.lam.app arg) (body'.lam.app arg') := by
      have h_ind : Relation.ReflTransGen BetaDB (body.lam.app arg) (body'.lam.app arg) := by
        have h_ind : ∀ {t t' : LamDB}, Relation.ReflTransGen BetaDB t t' → Relation.ReflTransGen BetaDB (t.lam.app arg) (t'.lam.app arg) := by
          intros t t' h; induction h; aesop;
          exact Relation.ReflTransGen.tail ‹_› ( BetaDB.lam ‹_› |> fun h => BetaDB.appL _ h );
        exact h_ind h₃;
      have h_ind : Relation.ReflTransGen BetaDB (body'.lam.app arg) (body'.lam.app arg') := by
        have h_ind : ∀ {t u : LamDB}, Relation.ReflTransGen BetaDB t u → Relation.ReflTransGen BetaDB (body'.lam.app t) (body'.lam.app u) := by
          intros t u h; induction h; aesop;
          exact Relation.ReflTransGen.tail ‹_› ( BetaDB.appR _ ‹_› );
        exact h_ind h₄;
      exact Relation.ReflTransGen.trans ‹_› ‹_›;
    exact h_ind.tail ( BetaDB.beta _ _ )

/-- Strip lemma. -/
theorem strip_lemma {t u v : LamDB}
    (hu : ParBetaDB t u)
    (hv : Relation.ReflTransGen ParBetaDB t v) :
    ∃ w, Relation.ReflTransGen ParBetaDB u w ∧ ParBetaDB v w := by
  induction hv using Relation.ReflTransGen.head_induction_on generalizing u with
  | refl => exact ⟨u, Relation.ReflTransGen.refl, hu⟩
  | head hstep _ ih =>
    obtain ⟨w₁, hw₁u, hw₁c⟩ := parBeta_diamond hu hstep
    obtain ⟨w₂, hw₂, hw₂v⟩ := ih hw₁c
    exact ⟨w₂, (Relation.ReflTransGen.single hw₁u).trans hw₂, hw₂v⟩

/-- Confluence of the reflexive-transitive closure of parallel reduction. -/
theorem parBetaStar_confluent {t u v : LamDB}
    (hu : Relation.ReflTransGen ParBetaDB t u)
    (hv : Relation.ReflTransGen ParBetaDB t v) :
    ∃ w, Relation.ReflTransGen ParBetaDB u w ∧
         Relation.ReflTransGen ParBetaDB v w := by
  induction hu using Relation.ReflTransGen.head_induction_on generalizing v with
  | refl => exact ⟨v, hv, Relation.ReflTransGen.refl⟩
  | head hstep _ ih =>
    obtain ⟨w₁, hw₁, hw₁v⟩ := strip_lemma hstep hv
    obtain ⟨w₂, hw₂u, hw₂w₁⟩ := ih hw₁
    exact ⟨w₂, hw₂u, (Relation.ReflTransGen.single hw₁v).trans hw₂w₁⟩

/-- Multi-step beta lifts to multi-step parallel beta. -/
theorem betaStar_to_parBetaStar {t u : LamDB}
    (h : Relation.ReflTransGen BetaDB t u) :
    Relation.ReflTransGen ParBetaDB t u :=
  h.lift _ (fun _ _ h => h.to_parBeta)

/-- Multi-step parallel beta lifts to multi-step beta. -/
theorem parBetaStar_to_betaStar {t u : LamDB}
    (h : Relation.ReflTransGen ParBetaDB t u) :
    Relation.ReflTransGen BetaDB t u := by
  induction h using Relation.ReflTransGen.head_induction_on with
  | refl => exact Relation.ReflTransGen.refl
  | head hstep _ ih => exact hstep.to_star.trans ih

/-- **Church-Rosser theorem**: beta reduction is confluent. -/
theorem church_rosser_db {t u v : LamDB}
    (hu : Relation.ReflTransGen BetaDB t u)
    (hv : Relation.ReflTransGen BetaDB t v) :
    ∃ w, Relation.ReflTransGen BetaDB u w ∧ Relation.ReflTransGen BetaDB v w := by
  obtain ⟨w, hw₁, hw₂⟩ := parBetaStar_confluent
    (betaStar_to_parBetaStar hu) (betaStar_to_parBetaStar hv)
  exact ⟨w, parBetaStar_to_betaStar hw₁, parBetaStar_to_betaStar hw₂⟩

/-! ## Computational Properties -/

/-- The size of a de Bruijn term (number of constructors). -/
def LamDB.size : LamDB → Nat
  | .var _ => 1
  | .app t u => 1 + t.size + u.size
  | .lam t => 1 + t.size

/-- Count of beta redexes in a term. -/
def betaRedexCount : LamDB → Nat
  | .var _ => 0
  | .app (.lam body) arg => 1 + betaRedexCount body + betaRedexCount arg
  | .app t u => betaRedexCount t + betaRedexCount u
  | .lam t => betaRedexCount t

/-- A term is in beta normal form iff it has no beta redexes. -/
def isNormalForm (t : LamDB) : Prop := betaRedexCount t = 0

/-
The complete development is the identity on normal forms.
-/
theorem develop_normal {t : LamDB} (h : isNormalForm t) : develop t = t := by
  -- By definition of `isNormalForm`, we know that `betaRedexCount t = 0`.
  have h_betaRedexCount : betaRedexCount t = 0 := by
    exact h;
  induction' t using LamDB.recOn with t u ih_t ih_u;
  · rfl;
  · cases u <;> cases ih_t <;> simp_all +decide [ isNormalForm ];
    all_goals unfold betaRedexCount at h_betaRedexCount; simp_all +decide [develop];
  · grind +locals

/-- **Counterexample**: `develop` does NOT always reduce the redex count.
    `(λ. x (x y)) (λ. x)` has 1 redex but its development has 2. -/
example : betaRedexCount (.app (.lam (.app (.var 0) (.app (.var 0) (.var 1))))
    (.lam (.var 0))) = 1 := by native_decide

example : betaRedexCount (develop (.app (.lam (.app (.var 0) (.app (.var 0) (.var 1))))
    (.lam (.var 0)))) = 2 := by native_decide

/-- Check whether a term is closed at a given binding depth. -/
def LamDB.isClosed (depth : Nat) : LamDB → Bool
  | .var k => k < depth
  | .app t u => t.isClosed depth && u.isClosed depth
  | .lam t => t.isClosed (depth + 1)

/-- Confluence as a property of a relation. -/
def IsConfluent {α : Type*} (r : α → α → Prop) : Prop :=
  ∀ a b c, Relation.ReflTransGen r a b → Relation.ReflTransGen r a c →
    ∃ d, Relation.ReflTransGen r b d ∧ Relation.ReflTransGen r c d

/-- Beta reduction is confluent. -/
theorem beta_confluent : IsConfluent BetaDB :=
  fun _ _ _ hu hv => church_rosser_db hu hv

end DeBruijn