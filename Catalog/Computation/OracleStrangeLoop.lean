import Mathlib

/-! # CatalogBuild.Computation.Oracles.OracleStrangeLoop

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16
-/


noncomputable section

/-- The fixed points of a strange loop form the "meaning" set -/
def StrangeLoop.meaningSet {X : Type*} (L : StrangeLoop X) : Set X :=
  {x | (L.down ∘ L.up) x = x}




/-- [Section: # CatalogBuild.Computation.Oracles.OracleStrangeLoop
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16] -/
theorem StrangeLoop.output_in_meaning {X : Type*} (L : StrangeLoop X) (x : X) :
    (L.down ∘ L.up) x ∈ L.meaningSet := by
      exact L.loop_idem x




/-- [Section: # CatalogBuild.Computation.Oracles.OracleStrangeLoop
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16] -/
theorem StrangeLoop.meaning_nonempty {X : Type*} [Nonempty X] (L : StrangeLoop X) :
    L.meaningSet.Nonempty := by
      exact ⟨ _, L.loop_idem ( Classical.arbitrary X ) ⟩




/-- A self-referential system: a system that can represent statements about itself -/
structure SelfRef (X : Type*) where
  encode : X → ℕ  -- Gödel numbering
  decode : ℕ → X  -- decoding
  roundtrip : ∀ x, decode (encode x) = x




theorem selfref_is_oracle {X : Type*} (S : SelfRef X) :
    ∀ x, (S.decode ∘ S.encode) ((S.decode ∘ S.encode) x) = (S.decode ∘ S.encode) x := by
      haveI := S.roundtrip; aesop;




theorem godel_diagonal_abstract {X : Type*} (f : X → X) :
    ∃ S : Set X, ∀ x ∈ S, f x ∈ S := by
      exact ⟨ ∅, by simp +decide ⟩




theorem no_liar_paradox : ¬ ∃ (P : Prop), P ↔ ¬P := by
  tauto




theorem tarski_diagonal {X : Type*} (f : X → (X → Prop)) :
    ∃ g : X → Prop, ∀ x, g ≠ f x := by
      by_contra! h;
      cases' h ( fun x => ¬f x x ) with x hx ; replace hx := congr_fun hx x ; tauto




theorem mu_invariant (k : ℕ) : 2 ^ k % 3 ≠ 0 := by
  exact fun h => by have := Nat.dvd_of_mod_eq_zero h; exact absurd ( Nat.prime_three.dvd_of_dvd_pow this ) ( by decide ) ;




theorem mu_double_preserves (n : ℕ) (h : n % 3 ≠ 0) : (2 * n) % 3 ≠ 0 := by
  omega




theorem mu_subtract_preserves (n : ℕ) (h : n % 3 ≠ 0) (hn : n ≥ 3) :
    (n - 3) % 3 ≠ 0 := by
      omega




/-- A quine is a fixed point of a transformation -/
def IsQuine {X : Type*} (transform : X → X) (q : X) : Prop := transform q = q




theorem idempotent_produces_quines {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (x : X) : IsQuine O (O x) := by
      exact hO x




theorem quines_eq_range {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x) :
    {q | IsQuine O q} = range O := by
      aesop_cat




theorem tangled_hierarchy_collapse {X : Type*} (levels : ℕ → (X → X))
    (h_idem : ∀ n, ∀ x, levels n (levels n x) = levels n x)
    (h_comm : ∀ n m, levels n ∘ levels m = levels m ∘ levels n)
    (n m : ℕ) (x : X) :
    levels n (levels m (levels n x)) = levels n (levels m x) := by
      simp_all +decide [ funext_iff ]




theorem consciousness_fixpoint {X : Type*} (observe : X → X)
    (h_idem : ∀ x, observe (observe x) = observe x) (x : X) :
    observe (observe (observe x)) = observe x := by
      rw [ h_idem, h_idem ]




end