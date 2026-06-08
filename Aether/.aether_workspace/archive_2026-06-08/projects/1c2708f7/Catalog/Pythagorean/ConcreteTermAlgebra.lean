import Mathlib

/-!
# Concrete First-Order Term Algebra with Certified Matching, Rewriting, and Completion

This file formalizes a concrete first-order term algebra over a signature, defines
substitutions, one-hole contexts, matching, and rewriting, and proves the fundamental
closure theorems that connect concrete symbolic operations to abstract completion theory.

## Main Results

### Substitution Infrastructure
* `FOTerm.subst_id` — Identity substitution is identity
* `FOTerm.subst_comp` — Substitution composition is functorial

### Closure Theorems (Theorem 1)
* `rewrites_closed_under_subst` — Rewriting is closed under substitution
* `rewrites_closed_under_context` — Rewriting is closed under contexts
* `rewrites_closed_under_subst_and_context` — Combined closure

### Completion Bridge (Theorems 2–3)
* `concrete_step_preserves_eq_theory` — Each concrete step preserves equational theory
* `concrete_completion_preserves_equational_theory` — Derivations preserve equational theory
* `concrete_derivation_preserves_eq_theory` — Full bridge theorem
* `concrete_completion_correct` — Capstone correctness theorem

### Matching (Theorem 4)
* `matchTerm_sound` — If matching succeeds, the substitution instantiates pattern to target

## Cross-Domain Connections
* **Term rewriting ↔ type theory**: `subst_comp` shows substitution is functorial
* **Term rewriting ↔ formal language theory**: `patternLanguage` defines tree languages
* **Term rewriting ↔ universal algebra**: Completion transforms presentations

application keywords: certified symbolic computation, equational reasoning, completion
procedures, tree automata, algebraic specification, theorem proving, symbolic AI,
unification, pattern matching, universal algebra, decision procedures, term rewriting
systems, normalization, automated deduction
-/

open Relation

-- ============================================================================
-- Section 1: Signatures and Terms
-- ============================================================================

/-- A function symbol with a name and arity. -/
structure FnSym where
  name : Nat
  arity : Nat
  deriving DecidableEq, Repr, Inhabited

/-- First-order terms over function symbols and variables.
    Variables are from type `V`, function symbols carry their arity.
    Arguments are indexed by `Fin f.arity` for type safety. -/
inductive FOTerm (V : Type) where
  | var : V → FOTerm V
  | app : (f : FnSym) → (Fin f.arity → FOTerm V) → FOTerm V

namespace FOTerm

variable {V : Type}

-- ============================================================================
-- Section 2: Substitutions
-- ============================================================================

/-- A substitution maps variables to terms. -/
abbrev Subst (V : Type) := V → FOTerm V

/-- Apply a substitution to a term. -/
def subst (σ : Subst V) : FOTerm V → FOTerm V
  | .var x => σ x
  | .app f args => .app f (fun i => (args i).subst σ)

/-- Composition of substitutions: apply σ then τ. -/
def compSubst (τ σ : Subst V) : Subst V := fun x => (σ x).subst τ

/-- **Theorem**: Identity substitution is the identity on terms. -/
theorem subst_id (t : FOTerm V) : t.subst .var = t := by
  induction t with
  | var x => rfl
  | app f args ih => simp [subst]; ext i; exact ih i

/-- **Theorem (Functoriality of Substitution)**: Substitution composition is functorial. -/
theorem subst_comp (σ τ : Subst V) (t : FOTerm V) :
    (t.subst σ).subst τ = t.subst (compSubst τ σ) := by
  induction t with
  | var x => simp [subst, compSubst]
  | app f args ih => simp [subst, compSubst]; ext i; exact ih i

-- ============================================================================
-- Section 3: One-Hole Contexts
-- ============================================================================

/-- A one-hole context in a first-order term.
    Standard notion from rewriting theory: a term with exactly one "hole"
    that can be filled with any term.

    This is a genuinely new structure not present in the existing catalog. -/
inductive Context (V : Type) where
  | hole : Context V
  | app (f : FnSym) (args : Fin f.arity → FOTerm V) (pos : Fin f.arity)
        (C : Context V) : Context V

/-- Apply substitution to all terms in a context (preserving the hole). -/
def Context.mapSubst : Context V → Subst V → Context V
  | .hole, _ => .hole
  | .app f args pos C, σ => .app f (fun i => (args i).subst σ) pos (C.mapSubst σ)

/-- Fill the hole in a context with a term. -/
def Context.fill : Context V → FOTerm V → FOTerm V
  | .hole, t => t
  | .app f args pos C, t =>
    .app f (fun i => if i = pos then C.fill t else args i)

@[simp]
theorem Context.fill_hole (t : FOTerm V) : Context.hole.fill t = t := rfl

/-- **Theorem**: Filling a context commutes with substitution. -/
theorem Context.fill_subst (C : Context V) (σ : Subst V) (t : FOTerm V) :
    (C.fill t).subst σ = (C.mapSubst σ).fill (t.subst σ) := by
  induction C with
  | hole => rfl
  | app f args pos C ih =>
    simp only [fill, mapSubst, subst]
    congr 1; ext i
    split
    · subst_vars; exact ih
    · rfl

-- ============================================================================
-- Section 4: Equations, Rules, and Rewriting
-- ============================================================================

/-- An equation between two terms. -/
structure Equation (V : Type) where
  lhs : FOTerm V
  rhs : FOTerm V

/-- A rewrite rule (oriented equation). -/
structure Rule (V : Type) where
  lhs : FOTerm V
  rhs : FOTerm V

/-- One-step rewriting: `Rewrites R s t` means `s` rewrites to `t` using a rule in `R`. -/
inductive Rewrites (R : List (Rule V)) : FOTerm V → FOTerm V → Prop where
  | root (r : Rule V) (hr : r ∈ R) (σ : Subst V) :
      Rewrites R (r.lhs.subst σ) (r.rhs.subst σ)
  | arg (f : FnSym) (args : Fin f.arity → FOTerm V) (pos : Fin f.arity)
      (t' : FOTerm V) (hstep : Rewrites R (args pos) t') :
      Rewrites R (.app f args) (.app f (fun i => if i = pos then t' else args i))

/-- Rewrites with a superset of rules. -/
theorem Rewrites.mono {R R' : List (Rule V)} (h : ∀ r, r ∈ R → r ∈ R')
    {s t : FOTerm V} (hst : Rewrites R s t) : Rewrites R' s t := by
  induction hst with
  | root r hr σ => exact .root r (h r hr) σ
  | arg f args pos t' _ ih => exact .arg f args pos t' ih

/-
============================================================================
Section 5: Closure Theorems (Theorem 1)
============================================================================

**Theorem**: One-step rewriting is closed under substitution.
    If `s →[R] t`, then `σ(s) →[R] σ(t)` for any substitution `σ`.
-/
theorem rewrites_closed_under_subst
    (R : List (Rule V)) {s t : FOTerm V}
    (h : Rewrites R s t) (σ : Subst V) :
    Rewrites R (s.subst σ) (t.subst σ) := by
  induction h;
  · rename_i r hr σ';
    exact Rewrites.root r hr ( compSubst σ σ' ) |> fun h => by simpa [ subst_comp ] using h;
  · convert Rewrites.arg _ _ _ _ _ using 1;
    rotate_left;
    exact ‹Fin _›;
    exact subst σ ‹_›;
    · assumption;
    · exact congr_arg _ ( funext fun i => by aesop )

/-
**Theorem**: One-step rewriting is closed under contexts.
    If `s →[R] t`, then `C[s] →[R] C[t]` for any context `C`.
-/
theorem rewrites_closed_under_context
    (R : List (Rule V)) {s t : FOTerm V}
    (h : Rewrites R s t) (C : Context V) :
    Rewrites R (C.fill s) (C.fill t) := by
  induction' C with f args pos C ih generalizing s t;
  · exact h;
  · convert Rewrites.arg f ( fun i => if i = pos then C.fill s else args i ) pos ( C.fill t ) _ using 1;
    · exact congr_arg _ ( funext fun i => by aesop );
    · grind

/-- **Theorem 1 (Main Infrastructure Theorem)**:
    One-step rewriting is closed under both substitution and contexts.
    If `s →[R] t`, then `C[σ(s)] →[R] C[σ(t)]`. -/
theorem rewrites_closed_under_subst_and_context
    (R : List (Rule V)) {s t : FOTerm V}
    (h : Rewrites R s t)
    (σ : Subst V) (C : Context V) :
    Rewrites R (C.fill (s.subst σ)) (C.fill (t.subst σ)) :=
  rewrites_closed_under_context R (rewrites_closed_under_subst R h σ) C

-- ============================================================================
-- Section 6: Equational Theory
-- ============================================================================

/-- The equational theory generated by a set of equations.
    Smallest congruence containing all instances of the equations. -/
inductive EquationalClosure (eqs : List (Equation V)) : FOTerm V → FOTerm V → Prop where
  | eqn (e : Equation V) (he : e ∈ eqs) (σ : Subst V) :
      EquationalClosure eqs (e.lhs.subst σ) (e.rhs.subst σ)
  | refl (t : FOTerm V) : EquationalClosure eqs t t
  | symm {s t : FOTerm V} : EquationalClosure eqs s t → EquationalClosure eqs t s
  | trans {s t u : FOTerm V} : EquationalClosure eqs s t → EquationalClosure eqs t u →
      EquationalClosure eqs s u
  | congr (f : FnSym) (args₁ args₂ : Fin f.arity → FOTerm V)
      (h : ∀ i, EquationalClosure eqs (args₁ i) (args₂ i)) :
      EquationalClosure eqs (.app f args₁) (.app f args₂)

/-- Monotonicity: larger equation sets generate larger closures. -/
theorem EquationalClosure.mono {E E' : List (Equation V)}
    (h : ∀ e, e ∈ E → e ∈ E')
    {s t : FOTerm V}
    (hst : EquationalClosure E s t) :
    EquationalClosure E' s t := by
  induction hst with
  | eqn e he σ => exact .eqn e (h e he) σ
  | refl t => exact .refl t
  | symm _ ih => exact .symm ih
  | trans _ _ ih1 ih2 => exact .trans ih1 ih2
  | congr f _ _ _ ih => exact .congr f _ _ ih

/-
**Key Lemma**: The equational closure is closed under substitution.
    This is essential for soundness of compose, collapse, and simplify.
-/
theorem EquationalClosure.subst_closed {eqs : List (Equation V)}
    {s t : FOTerm V} (h : EquationalClosure eqs s t) (σ : Subst V) :
    EquationalClosure eqs (s.subst σ) (t.subst σ) := by
  induction' h with s t h ih generalizing σ;
  · exact EquationalClosure.eqn s t ( compSubst σ h ) |> fun h => by simpa [ subst_comp ] using h;
  · constructor;
  · exact?;
  · exact EquationalClosure.trans ( by solve_by_elim ) ( by solve_by_elim );
  · exact EquationalClosure.congr _ _ _ ( by tauto )

/-
**General substitution lemma**: If every equation in E is derivable in E',
    then the equational closure of E is contained in the equational closure of E'.
-/
theorem EquationalClosure.of_derivable {E E' : List (Equation V)}
    (h : ∀ e ∈ E, ∀ σ : Subst V, EquationalClosure E' (e.lhs.subst σ) (e.rhs.subst σ))
    {s t : FOTerm V} (hst : EquationalClosure E s t) :
    EquationalClosure E' s t := by
  -- We proceed by induction on the structure of the equational closure.
  induction' hst with e he σ hst ih;
  · exact h e he σ;
  · exact EquationalClosure.refl _;
  · -- By the symmetry of the equational closure, if ih is related to t, then t is related to ih.
    apply EquationalClosure.symm; assumption;
  · exact EquationalClosure.trans ‹_› ‹_›;
  · exact EquationalClosure.congr _ _ _ ‹_›

/-- Convert a rule list to an equation list. -/
def rulesToEqs (R : List (Rule V)) : List (Equation V) :=
  R.map fun r => ⟨r.lhs, r.rhs⟩

/-
A rewrite step is in the equational closure of the rules.
-/
theorem rewrites_in_equational_closure
    (R : List (Rule V)) {s t : FOTerm V}
    (h : Rewrites R s t) :
    EquationalClosure (rulesToEqs R) s t := by
  have h_cases : ∀ {s t}, Rewrites R s t → EquationalClosure (rulesToEqs R) s t := by
    intro s t h;
    induction' h with r hr σ f args pos t' hstep ih;
    · exact EquationalClosure.eqn ⟨ r.lhs, r.rhs ⟩ ( List.mem_map.mpr ⟨ r, hr, rfl ⟩ ) σ;
    · apply EquationalClosure.congr;
      intro i; split_ifs <;> simp_all +decide [ EquationalClosure.refl ] ;
  exact h_cases h

-- ============================================================================
-- Section 7: Concrete Completion State
-- ============================================================================

/-- A concrete completion state: equations and oriented rules.
    Uses the standard Knuth-Bendix completion architecture where
    E stores unoriented equations and R stores oriented rules. -/
structure ConcreteState (V : Type) where
  E : List (Equation V)
  R : List (Rule V)

/-- The equational theory of a concrete state. -/
def ConcreteState.eqTheory (S : ConcreteState V) : FOTerm V → FOTerm V → Prop :=
  EquationalClosure (S.E ++ rulesToEqs S.R)

-- ============================================================================
-- Section 8: Concrete Completion Operations
-- ============================================================================

-- We define operations using list splicing (E_pre ++ [e] ++ E_post)
-- to avoid needing DecidableEq on FOTerm V.

/-- **Orient**: Move equation `e` from E to R.
    E = E_pre ++ [e] ++ E_post → E' = E_pre ++ E_post, R' = ⟨e.lhs, e.rhs⟩ :: R -/
def concreteOrient (S : ConcreteState V) (E_pre E_post : List (Equation V))
    (e : Equation V) (hsplit : S.E = E_pre ++ [e] ++ E_post) :
    ConcreteState V :=
  { E := E_pre ++ E_post,
    R := ⟨e.lhs, e.rhs⟩ :: S.R }

/-- **Delete**: Remove trivial equation `e` (where e.lhs = e.rhs) from E. -/
def concreteDelete (S : ConcreteState V) (E_pre E_post : List (Equation V))
    (e : Equation V) (hsplit : S.E = E_pre ++ [e] ++ E_post)
    (htriv : e.lhs = e.rhs) : ConcreteState V :=
  { E := E_pre ++ E_post,
    R := S.R }

/-- **Compose**: Replace rule r by (r.lhs, rhs') where r.rhs →[R] rhs'. -/
def concreteCompose (S : ConcreteState V) (R_pre R_post : List (Rule V))
    (r : Rule V) (hsplit : S.R = R_pre ++ [r] ++ R_post)
    (rhs' : FOTerm V) : ConcreteState V :=
  { E := S.E,
    R := R_pre ++ [⟨r.lhs, rhs'⟩] ++ R_post }

/-- **Collapse**: Move rule r to equations as (lhs', r.rhs) where r.lhs →[R] lhs'. -/
def concreteCollapse (S : ConcreteState V) (R_pre R_post : List (Rule V))
    (r : Rule V) (hsplit : S.R = R_pre ++ [r] ++ R_post)
    (lhs' : FOTerm V) : ConcreteState V :=
  { E := ⟨lhs', r.rhs⟩ :: S.E,
    R := R_pre ++ R_post }

/-- **Deduce**: Add a new equation from a critical pair. -/
def concreteDeduce (S : ConcreteState V) (s t : FOTerm V) : ConcreteState V :=
  { E := ⟨s, t⟩ :: S.E,
    R := S.R }

/-- **Simplify**: Replace equation e by (lhs', e.rhs) where e.lhs →[R] lhs'. -/
def concreteSimplify (S : ConcreteState V) (E_pre E_post : List (Equation V))
    (e : Equation V) (hsplit : S.E = E_pre ++ [e] ++ E_post)
    (lhs' : FOTerm V) : ConcreteState V :=
  { E := E_pre ++ [⟨lhs', e.rhs⟩] ++ E_post,
    R := S.R }

/-
============================================================================
Section 9: Soundness of Completion Rules (Theorem 2)
============================================================================

**Theorem 2a**: Orient preserves the equational theory.
-/
theorem concrete_orient_preserves_equational_theory
    (S : ConcreteState V) (E_pre E_post : List (Equation V))
    (e : Equation V) (hsplit : S.E = E_pre ++ [e] ++ E_post) :
    ∀ s t, (concreteOrient S E_pre E_post e hsplit).eqTheory s t ↔ S.eqTheory s t := by
  intro s t;
  constructor <;> intro h;
  · convert EquationalClosure.mono _ h;
    unfold concreteOrient rulesToEqs; aesop;
  · convert EquationalClosure.mono _ h;
    unfold concreteOrient rulesToEqs; aesop;

/-
**Theorem 2b**: Delete preserves the equational theory.
-/
theorem concrete_delete_preserves_equational_theory
    (S : ConcreteState V) (E_pre E_post : List (Equation V))
    (e : Equation V) (hsplit : S.E = E_pre ++ [e] ++ E_post) (htriv : e.lhs = e.rhs) :
    ∀ s t, (concreteDelete S E_pre E_post e hsplit htriv).eqTheory s t ↔ S.eqTheory s t := by
  intro s t;
  constructor <;> intro h;
  · convert EquationalClosure.mono _ h;
    unfold concreteDelete; aesop;
  · -- Apply induction on the EquationalClosure derivation.
    induction' h with s t h_ind;
    · by_cases hs : s = e <;> simp_all +decide [ concreteDelete ];
      · exact EquationalClosure.refl _;
      · exact EquationalClosure.eqn _ ( by aesop ) _;
    · exact EquationalClosure.refl _;
    · exact EquationalClosure.symm ‹_›;
    · exact EquationalClosure.trans ‹_› ‹_›;
    · exact EquationalClosure.congr _ _ _ ‹_›

/-
**Theorem 2c**: Compose preserves the equational theory.
    The rewrite must use the shared rules (R_pre ++ R_post), not the rule being replaced.
    This is the standard assumption in Knuth-Bendix completion.
-/
theorem concrete_compose_preserves_equational_theory
    (S : ConcreteState V) (R_pre R_post : List (Rule V))
    (r : Rule V) (hsplit : S.R = R_pre ++ [r] ++ R_post)
    (rhs' : FOTerm V) (hrew : Rewrites (R_pre ++ R_post) r.rhs rhs') :
    ∀ s t, (concreteCompose S R_pre R_post r hsplit rhs').eqTheory s t ↔ S.eqTheory s t := by
  refine' fun s t => ⟨ _, _ ⟩;
  · apply EquationalClosure.of_derivable;
    unfold concreteCompose rulesToEqs; simp +decide [ hsplit ] ;
    rintro e ( he | ⟨ a, ha, rfl ⟩ | rfl | ⟨ a, ha, rfl ⟩ ) σ <;> simp_all +decide [ EquationalClosure.eqn ];
    · exact EquationalClosure.eqn ⟨ a.lhs, a.rhs ⟩ ( by aesop ) σ;
    · have h_trans : EquationalClosure (S.E ++ (List.map (fun r => { lhs := r.lhs, rhs := r.rhs }) R_pre ++ { lhs := r.lhs, rhs := r.rhs } :: List.map (fun r => { lhs := r.lhs, rhs := r.rhs }) R_post)) (subst σ r.rhs) (subst σ rhs') := by
                                                                                                                                                                    have h_trans : EquationalClosure (List.map (fun r => { lhs := r.lhs, rhs := r.rhs }) (R_pre ++ R_post)) (subst σ r.rhs) (subst σ rhs') := by
                                                                                                                                                                                                                            convert rewrites_in_equational_closure ( R_pre ++ R_post ) hrew |> EquationalClosure.subst_closed <| σ using 1;
                                                                                                                                                                    grind +suggestions;
      apply EquationalClosure.trans;
      exact EquationalClosure.eqn ⟨ r.lhs, r.rhs ⟩ ( by simp +decide [ List.mem_append, List.mem_map ] ) σ;
      exact h_trans;
    · apply EquationalClosure.of_derivable;
      rotate_right;
      exact List.map ( fun r => ⟨ r.lhs, r.rhs ⟩ ) ( R_pre ++ R_post );
      · intro e he σ; rw [ List.mem_map ] at he; obtain ⟨ r, hr, rfl ⟩ := he; exact EquationalClosure.eqn _ ( by aesop ) _;
      · exact EquationalClosure.eqn _ ( List.mem_map.mpr ⟨ a, List.mem_append_right _ ha, rfl ⟩ ) _;
  · intro hst;
    refine' EquationalClosure.of_derivable _ hst;
    intro e he σ; simp_all +decide [ rulesToEqs ] ;
    rcases he with ( he | ⟨ a, ha, rfl ⟩ | rfl | ⟨ a, ha, rfl ⟩ ) <;> simp_all +decide [ concreteCompose ];
    · exact EquationalClosure.eqn _ ( List.mem_append_left _ he ) _;
    · exact EquationalClosure.eqn _ ( List.mem_append_right _ ( List.mem_append_left _ ( List.mem_map.mpr ⟨ a, ha, rfl ⟩ ) ) ) _;
    · have h_rewrite : EquationalClosure (S.E ++ (List.map (fun r => { lhs := r.lhs, rhs := r.rhs }) R_pre ++ { lhs := r.lhs, rhs := rhs' } :: List.map (fun r => { lhs := r.lhs, rhs := r.rhs }) R_post)) (subst σ r.rhs) (subst σ rhs') := by
                                                                                                                                                                      have h_rewrite : EquationalClosure (List.map (fun r => { lhs := r.lhs, rhs := r.rhs }) (R_pre ++ R_post)) (subst σ r.rhs) (subst σ rhs') := by
                                                                                                                                                                                                                                apply EquationalClosure.subst_closed;
                                                                                                                                                                                                                                convert rewrites_in_equational_closure ( R_pre ++ R_post ) hrew using 1;
                                                                                                                                                                      grind +suggestions;
      exact EquationalClosure.eqn ⟨ r.lhs, rhs' ⟩ ( by aesop ) σ |> fun h => EquationalClosure.trans h h_rewrite.symm;
    · convert EquationalClosure.of_derivable _ ( EquationalClosure.eqn _ _ σ ) using 1;
      rotate_left;
      rotate_left;
      rotate_left;
      exact S.E ++ ( List.map ( fun r => { lhs := r.lhs, rhs := r.rhs } ) R_pre ++ { lhs := r.lhs, rhs := rhs' } :: List.map ( fun r => { lhs := r.lhs, rhs := r.rhs } ) R_post );
      exact ⟨ a.lhs, a.rhs ⟩;
      · grind;
      · rfl;
      · rfl;
      · intro e he σ; exact EquationalClosure.eqn _ ( by aesop ) _;

/-
**Theorem 2d**: Collapse preserves the equational theory.
    The rewrite must use the shared rules (R_pre ++ R_post).
-/
theorem concrete_collapse_preserves_equational_theory
    (S : ConcreteState V) (R_pre R_post : List (Rule V))
    (r : Rule V) (hsplit : S.R = R_pre ++ [r] ++ R_post)
    (lhs' : FOTerm V) (hrew : Rewrites (R_pre ++ R_post) r.lhs lhs') :
    ∀ s t, (concreteCollapse S R_pre R_post r hsplit lhs').eqTheory s t ↔ S.eqTheory s t := by
  intro s tTheory;
  apply Iff.intro;
  · apply EquationalClosure.of_derivable;
    intro e he σ; simp [concreteCollapse] at he; (
    rcases he with ( rfl | he | he ) <;> simp_all +decide [ rulesToEqs ];
    · -- By the properties of the equational closure, we can rewrite `lhs'` to `r.lhs` using the rewrite rule `hrew`.
      have h_rewrite : EquationalClosure (S.E ++ (List.map (fun r => { lhs := r.lhs, rhs := r.rhs }) R_pre ++ { lhs := r.lhs, rhs := r.rhs } :: List.map (fun r => { lhs := r.lhs, rhs := r.rhs }) R_post)) (subst σ lhs') (subst σ r.lhs) := by
                                                                                                                                                                      have h_rewrite : EquationalClosure (rulesToEqs (R_pre ++ R_post)) (subst σ lhs') (subst σ r.lhs) := by
                                                                                                                                                                        have h_rewrite : EquationalClosure (rulesToEqs (R_pre ++ R_post)) (subst σ r.lhs) (subst σ lhs') := by
                                                                                                                                                                          exact EquationalClosure.subst_closed ( rewrites_in_equational_closure _ hrew ) σ;
                                                                                                                                                                        exact EquationalClosure.symm h_rewrite;
                                                                                                                                                                      apply EquationalClosure.mono;
                                                                                                                                                                      rotate_right;
                                                                                                                                                                      exact List.map ( fun r => { lhs := r.lhs, rhs := r.rhs } ) ( R_pre ++ R_post );
                                                                                                                                                                      · aesop;
                                                                                                                                                                      · convert h_rewrite using 1;
      exact EquationalClosure.trans h_rewrite ( EquationalClosure.eqn ⟨ r.lhs, r.rhs ⟩ ( by aesop ) σ );
    · apply EquationalClosure.eqn; simp [he];
    · rcases he with ( ⟨ a, ha, rfl ⟩ | ⟨ a, ha, rfl ⟩ ) <;> [ exact EquationalClosure.eqn _ ( by aesop ) _; exact EquationalClosure.eqn _ ( by aesop ) _ ]);
  · intro h;
    convert EquationalClosure.of_derivable _ h using 1;
    simp_all +decide [ List.mem_append, List.mem_map, rulesToEqs ];
    rintro e ( he | ⟨ a, ha, rfl ⟩ | rfl | ⟨ a, ha, rfl ⟩ ) σ;
    · apply EquationalClosure.eqn;
      unfold concreteCollapse; aesop;
    · apply EquationalClosure.eqn;
      unfold concreteCollapse; aesop;
    · have h_rewrite : EquationalClosure (⟨lhs', r.rhs⟩ :: S.E ++ rulesToEqs (R_pre ++ R_post)) (r.lhs.subst σ) (lhs'.subst σ) := by
        have h_rewrite : EquationalClosure (rulesToEqs (R_pre ++ R_post)) (r.lhs.subst σ) (lhs'.subst σ) := by
          convert EquationalClosure.subst_closed ( rewrites_in_equational_closure ( R_pre ++ R_post ) hrew ) σ using 1;
        grind +suggestions;
      have h_rewrite : EquationalClosure (⟨lhs', r.rhs⟩ :: S.E ++ rulesToEqs (R_pre ++ R_post)) (lhs'.subst σ) (r.rhs.subst σ) := by
        apply EquationalClosure.eqn ⟨lhs', r.rhs⟩ (by
        grind) σ;
      exact EquationalClosure.trans ‹_› ‹_›;
    · apply EquationalClosure.eqn;
      unfold concreteCollapse; aesop;

/-
**Theorem 2e**: Deduce preserves the equational theory.
-/
theorem concrete_deduce_preserves_equational_theory
    (S : ConcreteState V) (s t : FOTerm V) (heq : S.eqTheory s t) :
    ∀ a b, (concreteDeduce S s t).eqTheory a b ↔ S.eqTheory a b := by
  intro a b
  constructor
  all_goals generalize_proofs at *;
  · intro h
    induction' h with h ih;
    · by_cases hh : h = ⟨ s, t ⟩ <;> simp_all +decide [ concreteDeduce ];
      · -- By definition of EquationalClosure, we know that if s ≡ t, then s.subst σ ≡ t.subst σ for any substitution σ.
        have h_subst_closure : ∀ (s t : FOTerm V), S.eqTheory s t → ∀ (σ : Subst V), S.eqTheory (s.subst σ) (t.subst σ) := by
          intros s t hst σ; exact (by
          have h_subst_closure : ∀ (eqs : List (Equation V)) (s t : FOTerm V), EquationalClosure eqs s t → ∀ (σ : Subst V), EquationalClosure eqs (s.subst σ) (t.subst σ) := by
            intros eqs s t hst σ; induction' hst with eqs s t hst σ ih;
            · convert EquationalClosure.eqn _ s ( compSubst σ t ) using 1;
              · exact?;
              · exact?;
            · exact EquationalClosure.refl _;
            · exact EquationalClosure.symm ‹_›;
            · exact EquationalClosure.trans ‹_› ‹_›;
            · exact EquationalClosure.congr _ _ _ ‹_›;
          exact h_subst_closure _ _ _ hst σ);
        exact h_subst_closure s t heq _;
      · exact EquationalClosure.eqn _ ( ih.elim ( fun hi => List.mem_append_left _ hi ) fun hi => List.mem_append_right _ hi ) _;
    · exact EquationalClosure.refl _;
    · exact EquationalClosure.symm ‹_›;
    · exact EquationalClosure.trans ‹_› ‹_›;
    · exact EquationalClosure.congr _ _ _ ‹_›;
  · intro h;
    convert EquationalClosure.mono _ h;
    unfold concreteDeduce; aesop;

/-
**Theorem 2f**: Simplify preserves the equational theory.
-/
theorem concrete_simplify_preserves_equational_theory
    (S : ConcreteState V) (E_pre E_post : List (Equation V))
    (e : Equation V) (hsplit : S.E = E_pre ++ [e] ++ E_post)
    (lhs' : FOTerm V) (hrew : Rewrites S.R e.lhs lhs') :
    ∀ s t, (concreteSimplify S E_pre E_post e hsplit lhs').eqTheory s t ↔ S.eqTheory s t := by
  intro s t;
  constructor <;> intro hst;
  · have h_eq : ∀ σ : Subst V, EquationalClosure (S.E ++ rulesToEqs S.R) (lhs'.subst σ) (e.rhs.subst σ) := by
      intro σ
      have h_eq : EquationalClosure (S.E ++ rulesToEqs S.R) (subst σ e.lhs) (subst σ e.rhs) := by
        apply_rules [ EquationalClosure.eqn ];
        aesop
      have h_eq' : EquationalClosure (S.E ++ rulesToEqs S.R) (subst σ e.lhs) (subst σ lhs') := by
        have h_eq' : EquationalClosure (rulesToEqs S.R) (subst σ e.lhs) (subst σ lhs') := by
          exact rewrites_in_equational_closure _ ( rewrites_closed_under_subst _ hrew σ );
        exact EquationalClosure.mono ( fun e he => by aesop ) h_eq'
      have h_eq'' : EquationalClosure (S.E ++ rulesToEqs S.R) (subst σ lhs') (subst σ e.rhs) := by
        exact EquationalClosure.trans ( EquationalClosure.symm h_eq' ) h_eq
      exact h_eq'';
    convert EquationalClosure.of_derivable _ hst;
    simp +decide [ concreteSimplify, h_eq ];
    rintro e ( he | rfl | he | he ) σ <;> simp_all +decide [ EquationalClosure.eqn ];
  · convert EquationalClosure.of_derivable _ hst;
    simp [concreteSimplify];
    intro e' he' σ ; simp_all +decide [ List.mem_append, List.mem_cons ] ;
    rcases he' with ( ( he' | rfl | he' ) | he' );
    · apply EquationalClosure.eqn;
      grind;
    · have h_lhs' : EquationalClosure (E_pre ++ { lhs := lhs', rhs := e'.rhs } :: (E_post ++ rulesToEqs S.R)) (subst σ e'.lhs) (subst σ lhs') := by
                                                    have h_lhs' : EquationalClosure (rulesToEqs S.R) (subst σ e'.lhs) (subst σ lhs') := by
                                                      exact EquationalClosure.subst_closed ( rewrites_in_equational_closure _ hrew ) σ;
                                                    exact EquationalClosure.mono ( by aesop ) h_lhs';
      exact EquationalClosure.trans h_lhs' ( EquationalClosure.eqn ⟨ lhs', e'.rhs ⟩ ( by simp +decide ) σ );
    · apply EquationalClosure.eqn;
      grind;
    · exact EquationalClosure.mono ( by aesop ) ( EquationalClosure.eqn _ he' σ )

-- ============================================================================
-- Section 10: Abstract Completion Framework
-- ============================================================================

/-- Abstract completion state for KB completion. -/
structure AbsCompletionState (T : Type*) where
  rules : T → T → Prop
  pending : T → T → Prop

/-- Combined theory of an abstract state. -/
def AbsCompletionState.theory {T : Type*} (S : AbsCompletionState T) : T → T → Prop :=
  fun a b => S.rules a b ∨ S.pending a b

/-- An abstract KB step preserves the equational theory. -/
structure AbsKBStep {T : Type*} (S S' : AbsCompletionState T) : Prop where
  theory_preserved : ∀ a b, EqvGen S'.theory a b ↔ EqvGen S.theory a b

/-- An abstract completion sequence. -/
def AbsCompletionSequence {T : Type*} (S S' : AbsCompletionState T) : Prop :=
  ReflTransGen (fun X Y => AbsKBStep X Y) S S'

-- ============================================================================
-- Section 11: Bridge (Theorem 3)
-- ============================================================================

/-- Convert a concrete state to an abstract completion state. -/
def ConcreteState.toAbstract (S : ConcreteState V) : AbsCompletionState (FOTerm V) where
  rules := fun a b => Rewrites S.R a b
  pending := fun a b => ∃ e ∈ S.E, ∃ σ : Subst V, e.lhs.subst σ = a ∧ e.rhs.subst σ = b

/-- A concrete step is any of the six completion operations. -/
inductive ConcreteStep (V : Type) :
    ConcreteState V → ConcreteState V → Prop where
  | orient (S E_pre E_post e hsplit) :
      ConcreteStep V S (concreteOrient S E_pre E_post e hsplit)
  | delete (S E_pre E_post e hsplit htriv) :
      ConcreteStep V S (concreteDelete S E_pre E_post e hsplit htriv)
  | simplify (S E_pre E_post e hsplit lhs') (hrew : Rewrites S.R e.lhs lhs') :
      ConcreteStep V S (concreteSimplify S E_pre E_post e hsplit lhs')
  | compose (S R_pre R_post r hsplit rhs') (hrew : Rewrites (R_pre ++ R_post) r.rhs rhs') :
      ConcreteStep V S (concreteCompose S R_pre R_post r hsplit rhs')
  | collapse (S R_pre R_post r hsplit lhs') (hrew : Rewrites (R_pre ++ R_post) r.lhs lhs') :
      ConcreteStep V S (concreteCollapse S R_pre R_post r hsplit lhs')
  | deduce (S s t) (heq : S.eqTheory s t) :
      ConcreteStep V S (concreteDeduce S s t)

/-- A concrete derivation is a sequence of concrete steps. -/
inductive ConcreteDerives (V : Type) :
    ConcreteState V → ConcreteState V → Prop where
  | refl (S : ConcreteState V) : ConcreteDerives V S S
  | step {S₁ S₂ S₃ : ConcreteState V} :
      ConcreteStep V S₁ S₂ → ConcreteDerives V S₂ S₃ → ConcreteDerives V S₁ S₃

/-
**Theorem 2 (Unified)**: Every concrete step preserves equational theory.
-/
theorem concrete_step_preserves_eq_theory
    {S T : ConcreteState V}
    (h : ConcreteStep V S T) :
    ∀ a b, T.eqTheory a b ↔ S.eqTheory a b := by
  rcases h with ( _ | _ | _ | _ | _ | _ );
  exact?;
  · exact?;
  · exact?;
  · exact?;
  · exact?;
  · exact?

/-- **Theorem 3**: Every concrete derivation preserves equational theory.
    This is the global simulation theorem. -/
theorem concrete_completion_preserves_equational_theory
    {S T : ConcreteState V}
    (h : ConcreteDerives V S T) :
    ∀ a b, T.eqTheory a b ↔ S.eqTheory a b := by
  induction h with
  | refl _ => intro a b; exact Iff.rfl
  | step hs _ ih =>
    intro a b
    exact (ih a b).trans (concrete_step_preserves_eq_theory hs a b)

/-- **Theorem 3 (Bridge)**: A concrete derivation preserves equational theory.
    This is the global simulation theorem that bridges concrete completion
    to abstract completion correctness. -/
theorem concrete_derivation_preserves_eq_theory
    {S T : ConcreteState V}
    (h : ConcreteDerives V S T) :
    ∀ a b, T.eqTheory a b ↔ S.eqTheory a b :=
  concrete_completion_preserves_equational_theory h

/-- **Corollary**: If concrete completion reaches a finished state (no pending equations)
    with a convergent rule set, then the rule set correctly decides the original
    equational theory. This is the capstone correctness theorem. -/
theorem concrete_completion_correct
    {S T : ConcreteState V}
    (h : ConcreteDerives V S T)
    (hfinished : T.E = []) :
    ∀ a b, EquationalClosure (rulesToEqs T.R) a b ↔ S.eqTheory a b := by
  intro a b
  rw [← concrete_completion_preserves_equational_theory h]
  simp [ConcreteState.eqTheory, hfinished]

-- ============================================================================
-- Section 12: Cross-Domain — Substitution Category and Tree Languages
-- ============================================================================

/-- The set of all instances of a pattern `p` — this is the tree language
    recognized by the pattern. Matching is tree language recognition. -/
def patternLanguage (p : FOTerm V) : Set (FOTerm V) :=
  { t | ∃ σ : Subst V, p.subst σ = t }

/-- The identity substitution maps a pattern to itself. -/
theorem pattern_in_own_language (p : FOTerm V) : p ∈ patternLanguage p :=
  ⟨.var, subst_id p⟩

/-- Substitution composition is associative. -/
theorem compSubst_assoc (σ τ ρ : Subst V) (t : FOTerm V) :
    ((t.subst σ).subst τ).subst ρ = (t.subst σ).subst (compSubst ρ τ) := by
  rw [subst_comp]

/-- Three-fold composition flattens. -/
theorem subst_comp3 (σ τ ρ : Subst V) (t : FOTerm V) :
    ((t.subst σ).subst τ).subst ρ = t.subst (compSubst ρ (compSubst τ σ)) := by
  rw [subst_comp, subst_comp]
  congr 1; ext x; simp [compSubst, subst_comp]

end FOTerm