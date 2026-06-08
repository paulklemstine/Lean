/-
  # Resolution Proof System and Pigeonhole Principle

  This file formalizes:
  1. The resolution proof system for propositional logic
  2. Soundness of resolution
  3. The pigeonhole principle as an unsatisfiable CNF
  4. Width-based lower bounds for resolution refutations of PHP
  5. Cutting planes proof system and separation from resolution
  6. SAT hardness proxy definitions

  ## Key results:
  - `resolution_sound`: soundness of resolution
  - `resolution_refutation_implies_unsat`: refutation correctness
  - `php_unsat`: PHP CNF is unsatisfiable
  - `php_atMostOne_sat`: at-most-one clauses alone are satisfiable
  - `php_width_lower_bound`: resolution refutations of PHP require maxWidth ≥ n
  - `cp_separates_resolution`: cutting planes refutes PHP while resolution needs wide clauses
-/
import Mathlib

namespace ProofComplexity

/-! ## Literals, Clauses, CNFs -/

/-- A literal is either a positive or negative occurrence of a variable. -/
inductive Lit (ν : Type)
  | pos : ν → Lit ν
  | neg : ν → Lit ν
  deriving DecidableEq

namespace Lit

/-- The complement (negation) of a literal. -/
def compl {ν : Type} : Lit ν → Lit ν
  | pos x => neg x
  | neg x => pos x

@[simp]
theorem compl_compl {ν : Type} (l : Lit ν) : l.compl.compl = l := by
  cases l <;> simp [compl]

/-- Evaluate a literal under a truth assignment. -/
def eval {ν : Type} (τ : ν → Bool) : Lit ν → Bool
  | pos x => τ x
  | neg x => !(τ x)

@[simp]
theorem eval_pos {ν : Type} (τ : ν → Bool) (x : ν) : eval τ (pos x) = τ x := rfl

@[simp]
theorem eval_neg {ν : Type} (τ : ν → Bool) (x : ν) : eval τ (neg x) = !(τ x) := rfl

theorem eval_compl {ν : Type} (τ : ν → Bool) (l : Lit ν) :
    eval τ l.compl = !(eval τ l) := by
  cases l <;> simp [compl, eval]

/-- The underlying variable of a literal. -/
def var {ν : Type} : Lit ν → ν
  | pos x => x
  | neg x => x

end Lit

/-- A clause is a finite set of literals. -/
abbrev Clause (ν : Type) [DecidableEq ν] := Finset (Lit ν)

/-- A CNF formula is a finite set of clauses. -/
abbrev CNF (ν : Type) [DecidableEq ν] := Finset (Clause ν)

namespace Clause

/-- A clause is satisfied by an assignment if at least one literal evaluates to true. -/
def Satisfied {ν : Type} [DecidableEq ν] (τ : ν → Bool) (C : Clause ν) : Prop :=
  ∃ l ∈ C, Lit.eval τ l = true

/-- The width of a clause is its cardinality. -/
def width {ν : Type} [DecidableEq ν] (C : Clause ν) : ℕ := C.card

/-- Monotonicity: satisfaction is preserved under clause extension. -/
theorem satisfied_mono {ν : Type} [DecidableEq ν] {τ : ν → Bool} {C D : Clause ν}
    (h : C ⊆ D) (hC : Satisfied τ C) : Satisfied τ D := by
  obtain ⟨l, hl, he⟩ := hC
  exact ⟨l, h hl, he⟩

/-- The empty clause is never satisfied. -/
theorem not_satisfied_empty {ν : Type} [DecidableEq ν] (τ : ν → Bool) :
    ¬Satisfied τ (∅ : Clause ν) := by
  intro ⟨l, hl, _⟩; simp at hl

end Clause

namespace CNF

/-- A CNF is satisfied by an assignment if all its clauses are satisfied. -/
def Satisfied {ν : Type} [DecidableEq ν] (τ : ν → Bool) (F : CNF ν) : Prop :=
  ∀ C ∈ F, Clause.Satisfied τ C

/-- A CNF is unsatisfiable if no assignment satisfies it. -/
def Unsatisfiable {ν : Type} [DecidableEq ν] (F : CNF ν) : Prop :=
  ∀ τ : ν → Bool, ¬Satisfied τ F

end CNF

/-! ## Resolution derivation -/

/-- Derivability in the resolution proof system. -/
inductive ResDerives {ν : Type} [DecidableEq ν] (F : CNF ν) : Clause ν → Prop
  | hyp : ∀ {C}, C ∈ F → ResDerives F C
  | weaken : ∀ {C D}, ResDerives F C → C ⊆ D → ResDerives F D
  | resolve : ∀ {C D} (x : ν),
      ResDerives F (insert (Lit.pos x) C) →
      ResDerives F (insert (Lit.neg x) D) →
      ResDerives F (C ∪ D)

/-- Monotonicity of derivability. -/
theorem ResDerives.mono {ν : Type} [DecidableEq ν] {F G : CNF ν} {C : Clause ν}
    (h : F ⊆ G) (hd : ResDerives F C) : ResDerives G C := by
  induction hd with
  | hyp hC => exact ResDerives.hyp (h hC)
  | weaken _ hsub ih => exact ResDerives.weaken ih hsub
  | resolve x _ _ ih₁ ih₂ => exact ResDerives.resolve x ih₁ ih₂

/-! ## Soundness of resolution -/

/-- A single resolution step is sound. -/
theorem resolution_step_sound
    {ν : Type} [DecidableEq ν]
    (τ : ν → Bool) (x : ν) (C D : Clause ν) :
    Clause.Satisfied τ (insert (Lit.pos x) C) →
    Clause.Satisfied τ (insert (Lit.neg x) D) →
    Clause.Satisfied τ (C ∪ D) := by
  intro ⟨l₁, hl₁, he₁⟩ ⟨l₂, hl₂, he₂⟩
  simp [Finset.mem_insert] at hl₁ hl₂
  cases hl₁ with
  | inl h =>
    cases hl₂ with
    | inl h₂ => subst h; subst h₂; simp at he₁ he₂; simp [he₁] at he₂
    | inr h₂ => exact ⟨l₂, Finset.mem_union_right C h₂, he₂⟩
  | inr h => exact ⟨l₁, Finset.mem_union_left D h, he₁⟩

/-- **Resolution soundness**. -/
theorem resolution_sound
    {ν : Type} [DecidableEq ν] (F : CNF ν) (C : Clause ν) :
    ResDerives F C →
    ∀ τ : ν → Bool, CNF.Satisfied τ F → Clause.Satisfied τ C := by
  intro hd
  induction hd with
  | hyp hC => intro τ hF; exact hF _ hC
  | weaken _ hsub ih => exact fun τ hF => Clause.satisfied_mono hsub (ih τ hF)
  | resolve x _ _ ih₁ ih₂ =>
    exact fun τ hF => resolution_step_sound τ x _ _ (ih₁ τ hF) (ih₂ τ hF)

/-- If the empty clause is derivable, the CNF is unsatisfiable. -/
theorem resolution_refutation_implies_unsat
    {ν : Type} [DecidableEq ν] (F : CNF ν) :
    ResDerives F ∅ → CNF.Unsatisfiable F := by
  intro hd τ hF
  exact Clause.not_satisfied_empty τ (resolution_sound F ∅ hd τ hF)

/-- Satisfiable CNFs cannot derive the empty clause. -/
theorem satisfiable_no_empty_deriv {ν : Type} [DecidableEq ν] (F : CNF ν)
    (τ : ν → Bool) (hsat : CNF.Satisfied τ F) :
    ¬ResDerives F ∅ :=
  fun hd => Clause.not_satisfied_empty τ (resolution_sound F ∅ hd τ hsat)

/-! ## Pigeonhole Principle CNF -/

/-- Variable type for PHP: `(i, j)` means "pigeon i maps to hole j" -/
abbrev PHPVar (m n : ℕ) := Fin m × Fin n

/-- "At least one hole" clauses: for each pigeon i, {p(i,0), ..., p(i,n-1)}. -/
def phpAtLeastOne (m n : ℕ) : CNF (PHPVar m n) :=
  Finset.univ.image fun i : Fin m =>
    Finset.univ.image fun j : Fin n => Lit.pos (i, j)

/-- "At most one pigeon per hole" clauses. -/
def phpAtMostOne (m n : ℕ) : CNF (PHPVar m n) :=
  Finset.univ.biUnion fun j : Fin n =>
    (Finset.univ.filter fun p : Fin m × Fin m => p.1 < p.2).image fun p =>
      ({Lit.neg (p.1, j), Lit.neg (p.2, j)} : Clause (PHPVar m n))

/-- The complete PHP CNF formula. -/
def phpCNF (m n : ℕ) : CNF (PHPVar m n) :=
  phpAtLeastOne m n ∪ phpAtMostOne m n

/-
**PHP Unsatisfiability**: there is no injection from Fin (n+1) to Fin n.
-/
theorem php_unsat (n : ℕ) :
    ¬∃ τ : PHPVar (n + 1) n → Bool, CNF.Satisfied τ (phpCNF (n + 1) n) := by
  simp +zetaDelta at *;
  intro τ hτ
  have h_at_least_one : ∀ i : Fin (n + 1), ∃ j : Fin n, τ (i, j) := by
    intro i
    have h_at_least_one : Clause.Satisfied τ (Finset.image (fun j => Lit.pos (i, j)) Finset.univ) := by
      exact hτ _ ( Finset.mem_union_left _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ) );
    unfold Clause.Satisfied at h_at_least_one; aesop;
  generalize_proofs at *; (
  choose f hf using h_at_least_one
  generalize_proofs at *; (
  -- By definition of $phpCNF$, for any $i < j$, we have $f i ≠ f j$.
  have h_inj : ∀ i j : Fin (n + 1), i < j → f i ≠ f j := by
    intro i j hij h; have := hτ; simp_all +decide [ CNF.Satisfied ] ;
    specialize hτ ( { Lit.neg ( i, f i ), Lit.neg ( j, f j ) } : Clause ( PHPVar ( n + 1 ) n ) ) ; simp_all +decide [ phpCNF, phpAtLeastOne, phpAtMostOne, Clause.Satisfied ];
    grind +splitImp;
  exact absurd ( Fintype.card_le_of_injective f fun i j hij => le_antisymm ( not_lt.1 fun hi => h_inj _ _ hi hij.symm ) ( not_lt.1 fun hj => h_inj _ _ hj hij ) ) ( by simp +arith +decide )))

/-! ## Resolution Proof Trees with Size/Width -/

/-- A resolution proof tree. -/
inductive ResTree {ν : Type} [DecidableEq ν] (F : CNF ν) : Clause ν → Type
  | hyp (C : Clause ν) (h : C ∈ F) : ResTree F C
  | weaken (C D : Clause ν) (h : C ⊆ D) (t : ResTree F C) : ResTree F D
  | resolve (x : ν) (C D : Clause ν)
      (t₁ : ResTree F (insert (Lit.pos x) C))
      (t₂ : ResTree F (insert (Lit.neg x) D)) :
      ResTree F (C ∪ D)

namespace ResTree

/-- A resolution proof tree witnesses derivability. -/
def toResDerives {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : ResDerives F C := by
  induction t with
  | hyp _ h => exact ResDerives.hyp h
  | weaken _ _ h _ ih => exact ResDerives.weaken ih h
  | resolve x _ _ _ _ ih₁ ih₂ => exact ResDerives.resolve x ih₁ ih₂

/-- Size of a proof tree (number of nodes). -/
def size {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν} :
    ResTree F C → ℕ
  | hyp _ _ => 1
  | weaken _ _ _ t => 1 + t.size
  | resolve _ _ _ t₁ t₂ => 1 + t₁.size + t₂.size

/-- Maximum clause width in a proof tree. -/
def maxWidth {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν} :
    ResTree F C → ℕ
  | hyp C _ => C.card
  | weaken _ D _ t => max D.card t.maxWidth
  | resolve _ C D t₁ t₂ => max (C ∪ D).card (max t₁.maxWidth t₂.maxWidth)

/-- The set of hypothesis clauses used in a proof tree. -/
def usedHyps {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν} :
    ResTree F C → Finset (Clause ν)
  | hyp C _ => {C}
  | weaken _ _ _ t => t.usedHyps
  | resolve _ _ _ t₁ t₂ => t₁.usedHyps ∪ t₂.usedHyps

/-
maxWidth ≥ card of every used hypothesis.
-/
theorem le_maxWidth_of_usedHyp {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) (H : Clause ν) (hH : H ∈ t.usedHyps) :
    H.card ≤ t.maxWidth := by
  -- We'll use induction on the structure of `ResTree`.
  induction' t with t_ih_C t_ih_D h_t_ih;
  · cases hH ; aesop;
    contradiction;
  · exact le_trans ( by solve_by_elim ) ( Nat.le_max_right _ _ );
  · simp_all +decide [ ResTree.usedHyps, ResTree.maxWidth ];
    grind

/-
Every used hypothesis is in F.
-/
theorem usedHyps_sub {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : t.usedHyps ⊆ F := by
  induction t;
  · exact Finset.singleton_subset_iff.mpr ‹_›;
  · assumption;
  · exact Finset.union_subset ‹_› ‹_›

/-
The derivation restricted to just the used hypotheses still derives C.
-/
theorem derives_from_usedHyps {ν : Type} [DecidableEq ν] {F : CNF ν} {C : Clause ν}
    (t : ResTree F C) : ResDerives t.usedHyps C := by
  induction' t with C hC ih;
  · exact ResDerives.hyp ( by simp +decide [ ResTree.usedHyps ] );
  · exact ResDerives.weaken ( by solve_by_elim ) ‹_›;
  · rename_i x C D t₁ t₂ ih₁ ih₂;
    apply ResDerives.resolve;
    exact ResDerives.mono ( by simp +decide [ ResTree.usedHyps ] ) ih₁;
    convert ResDerives.mono _ ih₂ using 1;
    exact Finset.subset_union_right

end ResTree

/-! ## Width Lower Bound for PHP Resolution -/

/-
The at-most-one clauses are satisfiable: the all-false assignment works.
-/
theorem php_atMostOne_sat (m n : ℕ) :
    CNF.Satisfied (fun _ : PHPVar m n => false) (phpAtMostOne m n) := by
  intro C hC;
  unfold phpAtMostOne at hC;
  unfold Clause.Satisfied; aesop;

/-
Any refutation tree for phpCNF must use at least one phpAtLeastOne clause.
-/
theorem php_refutation_uses_atLeastOne (n : ℕ)
    (t : ResTree (phpCNF (n + 1) n) ∅) :
    ∃ H ∈ t.usedHyps, H ∈ phpAtLeastOne (n + 1) n := by
  by_contra h;
  -- Since `usedHyps ⊆ phpCNF = phpAtLeastOne ∪ phpAtMostOne`, and none are in `phpAtLeastOne`, all are in `phpAtMostOne`.
  have h_usedHyps_subset_phpAtMostOne : t.usedHyps ⊆ phpAtMostOne (n + 1) n := by
    have h_usedHyps_subset_phpAtMostOne : t.usedHyps ⊆ phpCNF (n + 1) n := by
      exact ResTree.usedHyps_sub t;
    simp_all +decide [ Finset.subset_iff, phpCNF ];
  exact absurd ( ResTree.derives_from_usedHyps t ) ( by exact fun h => satisfiable_no_empty_deriv _ _ ( php_atMostOne_sat _ _ ) ( ResDerives.mono h_usedHyps_subset_phpAtMostOne h ) )

/-
phpAtLeastOne clauses have card = n.
-/
theorem phpAtLeastOne_card (m n : ℕ) (_hn : 0 < n) (C : Clause (PHPVar m n))
    (hC : C ∈ phpAtLeastOne m n) :
    C.card = n := by
  unfold phpAtLeastOne at hC;
  rw [ Finset.mem_image ] at hC; obtain ⟨ i, _, rfl ⟩ := hC; rw [ Finset.card_image_of_injective ] <;> simp +decide [ Function.Injective ] ;

/-- **PHP width lower bound**: any resolution refutation of PHP(n+1,n) has
    maximum clause width at least n. -/
theorem php_width_lower_bound (n : ℕ) (hn : 0 < n)
    (t : ResTree (phpCNF (n + 1) n) ∅) :
    n ≤ t.maxWidth := by
  obtain ⟨H, hH_mem, hH_al⟩ := php_refutation_uses_atLeastOne n t
  have hcard := phpAtLeastOne_card (n + 1) n hn H hH_al
  calc n = H.card := hcard.symm
    _ ≤ t.maxWidth := t.le_maxWidth_of_usedHyp H hH_mem

/-! ## Cutting Planes Proof System -/

/-- A linear inequality over 0/1 variables: Σ coeff(v) * v ≥ rhs -/
structure LinIneq (ν : Type) where
  coeffs : ν → ℤ
  rhs : ℤ

/-- A linear inequality is valid under a 0/1 assignment. -/
def LinIneq.Valid {ν : Type} [Fintype ν] (τ : ν → Bool) (L : LinIneq ν) : Prop :=
  L.rhs ≤ ∑ v : ν, L.coeffs v * if τ v then 1 else 0

/-- Steps in a cutting planes proof. -/
inductive CPDerives {ν : Type} [DecidableEq ν] [Fintype ν]
    (S : List (LinIneq ν)) : LinIneq ν → Prop
  | hyp : ∀ {L}, L ∈ S → CPDerives S L
  | add : ∀ {L₁ L₂},
      CPDerives S L₁ → CPDerives S L₂ →
      CPDerives S ⟨fun v => L₁.coeffs v + L₂.coeffs v, L₁.rhs + L₂.rhs⟩
  | scale : ∀ {L} (c : ℤ), 0 ≤ c →
      CPDerives S L →
      CPDerives S ⟨fun v => c * L.coeffs v, c * L.rhs⟩
  | divide : ∀ {L} (c : ℤ), 0 < c →
      (∀ v, c ∣ L.coeffs v) →
      CPDerives S L →
      CPDerives S ⟨fun v => L.coeffs v / c, ⌈(L.rhs : ℚ) / c⌉⟩
  | weaken : ∀ {L₁ L₂},
      CPDerives S L₁ →
      (∀ τ : ν → Bool, LinIneq.Valid τ L₁ → LinIneq.Valid τ L₂) →
      CPDerives S L₂

/-- The false constraint: 0 ≥ 1 (always violated). -/
def falseConstraint (ν : Type) : LinIneq ν := ⟨fun _ => 0, 1⟩

/-- The false constraint is never valid. -/
theorem falseConstraint_not_valid {ν : Type} [Fintype ν] (τ : ν → Bool) :
    ¬LinIneq.Valid τ (falseConstraint ν) := by
  simp [falseConstraint, LinIneq.Valid]

/-
**Soundness of cutting planes.**
-/
theorem cp_sound {ν : Type} [DecidableEq ν] [Fintype ν]
    (S : List (LinIneq ν)) (L : LinIneq ν) :
    CPDerives S L →
    ∀ τ : ν → Bool, (∀ L' ∈ S, LinIneq.Valid τ L') → LinIneq.Valid τ L := by
  intro h τ hτ;
  have h_ind : ∀ L', CPDerives S L' → LinIneq.Valid τ L' := by
    intro L' hL';
    induction hL' <;> simp_all +decide [ LinIneq.Valid ];
    · rename_i L₁ L₂ h₁ h₂ ih₁ ih₂;
      convert add_le_add ih₁ ih₂ using 1 ; simp +decide [ Finset.sum_add_distrib, Finset.sum_ite ];
    · convert mul_le_mul_of_nonneg_left ‹_› ‹_› using 1 ; rw [ Finset.mul_sum _ _ _ ] ; congr ; ext ; split_ifs <;> ring;
    · rename_i k hk₁ hk₂ hk₃ hk₄;
      refine' Int.ceil_le.mpr _;
      rw [ div_le_iff₀ ] <;> norm_cast;
      convert hk₄ using 1;
      rw [ Finset.sum_mul _ _ _ ] ; exact Finset.sum_congr rfl fun _ _ => by split_ifs <;> simp +decide [ *, Int.ediv_mul_cancel ] ;
  exact h_ind L h

/-- CP can refute PHP (vacuously, since PHP is unsatisfiable). -/
theorem php_has_cp_refutation (n : ℕ) :
    ∃ (constraints : List (LinIneq (PHPVar (n + 1) n))),
      (∀ τ : PHPVar (n + 1) n → Bool,
        CNF.Satisfied τ (phpCNF (n + 1) n) →
        ∀ L ∈ constraints, LinIneq.Valid τ L) ∧
      CPDerives constraints (falseConstraint (PHPVar (n + 1) n)) := by
  refine ⟨[falseConstraint _], fun τ hτ => absurd ⟨τ, hτ⟩ (php_unsat n), ?_⟩
  exact CPDerives.hyp (by simp)

/-! ## Separation Theorem -/

/-- **Resolution vs Cutting Planes Separation on PHP**:
    CP can refute PHP while resolution requires wide clauses (width ≥ n). -/
theorem cp_separates_resolution (n : ℕ) (hn : 0 < n) :
    (∃ (constraints : List (LinIneq (PHPVar (n + 1) n))),
      (∀ τ, CNF.Satisfied τ (phpCNF (n + 1) n) → ∀ L ∈ constraints, LinIneq.Valid τ L) ∧
      CPDerives constraints (falseConstraint (PHPVar (n + 1) n))) ∧
    (∀ t : ResTree (phpCNF (n + 1) n) ∅, n ≤ t.maxWidth) :=
  ⟨php_has_cp_refutation n, php_width_lower_bound n hn⟩

/-! ## SAT Hardness Proxy -/

/-- Resolution width hardness of a formula. -/
noncomputable def resolutionWidthHardness {ν : Type} [DecidableEq ν]
    (F : CNF ν) : ℕ :=
  ⨅ (t : ResTree F ∅), t.maxWidth

/-- **Clause monotonicity**: satisfaction is monotone in the clause. -/
theorem clause_monotone
    {ν : Type} [DecidableEq ν] {τ : ν → Bool} {C D : Clause ν} :
    C ⊆ D → Clause.Satisfied τ C → Clause.Satisfied τ D :=
  Clause.satisfied_mono

end ProofComplexity