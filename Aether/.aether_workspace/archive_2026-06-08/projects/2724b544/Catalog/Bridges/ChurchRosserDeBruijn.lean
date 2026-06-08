/-
# Church-Rosser via de Bruijn Indices: Quantitative Confluence Engine

This file develops a complete proof of the Church-Rosser theorem for the untyped
λ-calculus using de Bruijn indices, including uniqueness of normal forms and
abstract metric hub bounds.
-/

import Mathlib

/-! ## De Bruijn Term Syntax -/

/-- Lambda calculus terms with de Bruijn indices. -/
inductive DBTerm : Type where
  | var : Nat → DBTerm
  | app : DBTerm → DBTerm → DBTerm
  | lam : DBTerm → DBTerm
  deriving DecidableEq, Repr

namespace DBTerm

/-- Shift free variables ≥ cutoff `c` by amount `d`. -/
def shift (d : Nat) (c : Nat) : DBTerm → DBTerm
  | var k => if k < c then var k else var (k + d)
  | app t u => app (shift d c t) (shift d c u)
  | lam t => lam (shift d (c + 1) t)

/-- Substitute term `s` for variable `j` in `t`.
    Variables above `j` are decremented. -/
def subst (s : DBTerm) (j : Nat) : DBTerm → DBTerm
  | var k => if k = j then s
             else if k < j then var k
             else var (k - 1)
  | app t u => app (subst s j t) (subst s j u)
  | lam t => lam (subst (shift 1 0 s) (j + 1) t)

/-- One-step β-reduction. -/
inductive Beta : DBTerm → DBTerm → Prop where
  | redex (body arg : DBTerm) :
      Beta (app (lam body) arg) (subst arg 0 body)
  | appLeft {t t' : DBTerm} (u : DBTerm) (h : Beta t t') :
      Beta (app t u) (app t' u)
  | appRight (t : DBTerm) {u u' : DBTerm} (h : Beta u u') :
      Beta (app t u) (app t u')
  | lamBody {t t' : DBTerm} (h : Beta t t') :
      Beta (lam t) (lam t')

/-- Multi-step β-reduction. -/
inductive DBMultiBeta : DBTerm → DBTerm → Prop where
  | refl (t : DBTerm) : DBMultiBeta t t
  | step {t u v : DBTerm} (h₁ : Beta t u) (h₂ : DBMultiBeta u v) : DBMultiBeta t v

theorem DBMultiBeta.single {t u : DBTerm} (h : Beta t u) : DBMultiBeta t u :=
  .step h (.refl u)

theorem DBMultiBeta.trans' {t u v : DBTerm} (h₁ : DBMultiBeta t u) (h₂ : DBMultiBeta u v) :
    DBMultiBeta t v := by
  induction h₁ with
  | refl => exact h₂
  | step h₁ _ ih => exact .step h₁ (ih h₂)

theorem DBMultiBeta.appLeft {t t' u : DBTerm} (h : DBMultiBeta t t') :
    DBMultiBeta (app t u) (app t' u) := by
  induction h with
  | refl => exact .refl _
  | step h₁ _ ih => exact .step (.appLeft u h₁) ih

theorem DBMultiBeta.appRight {t u u' : DBTerm} (h : DBMultiBeta u u') :
    DBMultiBeta (app t u) (app t u') := by
  induction h with
  | refl => exact .refl _
  | step h₁ _ ih => exact .step (.appRight t h₁) ih

theorem DBMultiBeta.lamBody {t t' : DBTerm} (h : DBMultiBeta t t') :
    DBMultiBeta (lam t) (lam t') := by
  induction h with
  | refl => exact .refl _
  | step h₁ _ ih => exact .step (.lamBody h₁) ih

/-- Parallel β-reduction: contracts zero or more redexes simultaneously. -/
inductive ParBeta : DBTerm → DBTerm → Prop where
  | var (n : Nat) : ParBeta (var n) (var n)
  | app {t t' u u' : DBTerm} (ht : ParBeta t t') (hu : ParBeta u u') :
      ParBeta (app t u) (app t' u')
  | lam {t t' : DBTerm} (ht : ParBeta t t') :
      ParBeta (lam t) (lam t')
  | beta {body body' arg arg' : DBTerm}
      (hb : ParBeta body body') (ha : ParBeta arg arg') :
      ParBeta (app (lam body) arg) (subst arg' 0 body')

theorem ParBeta.refl : ∀ (t : DBTerm), ParBeta t t
  | DBTerm.var n => ParBeta.var n
  | DBTerm.app t u => ParBeta.app (refl t) (refl u)
  | DBTerm.lam t => ParBeta.lam (refl t)

theorem Beta.toParBeta {t u : DBTerm} (h : Beta t u) : ParBeta t u := by
  induction h with
  | redex body arg => exact .beta (.refl body) (.refl arg)
  | appLeft u _ ih => exact .app ih (.refl u)
  | appRight t _ ih => exact .app (.refl t) ih
  | lamBody _ ih => exact .lam ih

theorem ParBeta.toMultiBeta {t u : DBTerm} (h : ParBeta t u) : DBMultiBeta t u := by
  induction h with
  | var => exact .refl _
  | app _ _ ih₁ ih₂ => exact (ih₁.appLeft).trans' ih₂.appRight
  | lam _ ih => exact ih.lamBody
  | beta _ _ ihb iha =>
    exact ((ihb.lamBody).appLeft).trans' (iha.appRight |>.trans' (.single (.redex _ _)))

/-! ## Structural Lemmas for shift and subst -/

theorem shift_zero (c : Nat) (t : DBTerm) : shift 0 c t = t := by
  induction t generalizing c with
  | var k => unfold shift; split <;> simp
  | app t u iht ihu => simp [shift, iht, ihu]
  | lam t ih => simp [shift, ih]

/-
Commutation of two shifts: when c₁ ≤ c₂,
    `shift d₂ (c₂ + d₁) (shift d₁ c₁ t) = shift d₁ c₁ (shift d₂ c₂ t)`.
-/
theorem shift_shift_comm (d₁ d₂ c₁ c₂ : Nat) (t : DBTerm) (h : c₁ ≤ c₂) :
    shift d₂ (c₂ + d₁) (shift d₁ c₁ t) = shift d₁ c₁ (shift d₂ c₂ t) := by
  induction' t with k t u ihk ihu generalizing c₁ c₂ d₁ d₂;
  · simp +arith +decide [ shift ];
    unfold shift; split_ifs <;> simp +arith +decide [ * ] ;
    · bv_omega;
    · grind;
    · exact fun h => False.elim <| by linarith;
  · simp_all +decide [ DBTerm.shift ];
  · simp +arith +decide [ *, shift ];
    convert ‹∀ ( d₁ d₂ c₁ c₂ : ℕ ), c₁ ≤ c₂ → shift d₂ ( c₂ + d₁ ) ( shift d₁ c₁ _ ) = shift d₁ c₁ ( shift d₂ c₂ _ ) › d₁ d₂ ( c₁ + 1 ) ( c₂ + 1 ) ( by linarith ) using 1 ; ring

/-
Key shift-subst interaction: for j ≤ c,
    `shift d c (subst s j t) = subst (shift d c s) j (shift d (c + 1) t)`.
-/
theorem shift_subst_comm (d c j : Nat) (t s : DBTerm) (h : j ≤ c) :
    shift d c (subst s j t) = subst (shift d c s) j (shift d (c + 1) t) := by
  have h_ind_gen : ∀ (t : DBTerm) (d c j : Nat) (s : DBTerm) (h : j ≤ c),
    shift d c (subst s j t) = subst (shift d c s) j (shift d (c + 1) t) := by
      intros t d c j s h;
      induction' t with k t u ih generalizing d c j s;
      · cases lt_or_ge k j <;> simp_all +decide [ subst, shift ];
        · split_ifs <;> simp_all +decide [ shift, subst ];
          · grind;
          · linarith;
        · split_ifs <;> simp_all +decide [ shift, subst ];
          · grind;
          · linarith;
          · grind;
          · grind;
      · exact congr_arg₂ DBTerm.app ( ih d c j s h ) ( by solve_by_elim );
      · simp_all +decide [ DBTerm.subst, DBTerm.shift ];
        rw [ shift_shift_comm ];
        norm_num;
  exact h_ind_gen t d c j s h

/-! ## Key Lemma: shift preserves ParBeta -/

theorem shift_parBeta (d c : Nat) {t t' : DBTerm} (h : ParBeta t t') :
    ParBeta (shift d c t) (shift d c t') := by
  induction h generalizing c with
  | var n => simp [shift]; split_ifs <;> exact ParBeta.var _
  | app _ _ iht ihu => exact ParBeta.app (iht c) (ihu c)
  | lam _ ih => exact ParBeta.lam (ih (c + 1))
  | beta hb ha ihb iha =>
    simp [shift]
    rw [shift_subst_comm d c 0 _ _ (Nat.zero_le _)]
    exact ParBeta.beta (ihb (c + 1)) (iha c)

/-! ## Additional shift-subst interaction lemmas -/

/-
Cancellation: substituting after shifting cancels out.
-/
theorem subst_shift_cancel (r : DBTerm) (j : Nat) (t : DBTerm) :
    subst r j (shift 1 j t) = t := by
  -- We'll use induction on $t$.
  induction' t with t ih generalizing r j;
  · grind +locals;
  · exact congr_arg₂ _ ( ‹∀ ( r : DBTerm ) ( j : ℕ ), r.subst j ( shift 1 j ih ) = ih› _ _ ) ( ‹∀ ( r : DBTerm ) ( j : ℕ ), r.subst j ( shift 1 j _ ) = _› _ _ );
  · simp_all +decide [ DBTerm.subst, DBTerm.shift ]

/-
Shift-subst interaction when cutoff ≤ index.
    shift d c (subst s j t) = subst (shift d c s) (j+d) (shift d c t) when c ≤ j
-/
theorem shift_subst_below (d c j : Nat) (t s : DBTerm) (h : c ≤ j) :
    shift d c (subst s j t) = subst (shift d c s) (j + d) (shift d c t) := by
  induction' t with k t u ih generalizing c j s;
  · simp +decide [ DBTerm.subst, DBTerm.shift ];
    split_ifs <;> simp_all +decide [ DBTerm.shift, DBTerm.subst ];
    · grind +splitImp;
    · grind;
    · grind;
    · grind;
  · convert congr_arg₂ DBTerm.app ( ih c j s h ) ( ‹∀ ( c j : ℕ ) ( s : DBTerm ), c ≤ j → shift d c ( s.subst j u ) = ( shift d c s ).subst ( j + d ) ( shift d c u ) › c j s h ) using 1;
  · rename_i t ih;
    convert congr_arg DBTerm.lam ( ih ( c + 1 ) ( j + 1 ) ( shift 1 0 s ) ( by linarith ) ) using 1;
    rw [ show shift d c t.lam = lam ( shift d ( c + 1 ) t ) from rfl ];
    rw [ show shift d ( c + 1 ) ( shift 1 0 s ) = shift 1 0 ( shift d c s ) from ?_ ];
    · ac_rfl;
    · convert shift_shift_comm 1 d 0 c s ( Nat.zero_le c ) using 1

/-! ## Substitution composition lemma -/

/-
Generalized substitution composition: for k ≤ j,
    subst s j (subst t k body) = subst (subst s j t) k (subst (shift 1 k s) (j+1) body).
    The proof uses shift_subst_below and shift_shift_comm in the lam case.
-/
theorem subst_subst_gen (s t body : DBTerm) (j k : Nat) (h : k ≤ j) :
    subst s j (subst t k body) = subst (subst s j t) k (subst (shift 1 k s) (j + 1) body) := by
  have h_subst_comp : ∀ (body : DBTerm) (j k : ℕ) (s t : DBTerm), k ≤ j → subst s j (subst t k body) = subst (subst s j t) k (subst (shift 1 k s) (j + 1) body) := by
    intros body j k s t h
    induction' body with body ih generalizing j k s t;
    · -- By definition of substitution, we can break down the left-hand side and right-hand side of the equation.
      simp [DBTerm.subst];
      split_ifs <;> simp_all +decide [ DBTerm.subst ];
      any_goals omega;
      · grind;
      · grind +suggestions;
      · grind;
      · grind;
    · simp_all +decide [ DBTerm.subst ];
    · simp +arith +decide [ *, DBTerm.subst ];
      congr! 1;
      · convert shift_subst_below 1 0 j t s ( Nat.zero_le j ) |> Eq.symm using 1;
      · rw [ shift_shift_comm 1 1 0 k s ( Nat.zero_le k ) ];
  grind

/-- Substitution composition at index 0 (special case of subst_subst_gen with k=0). -/
theorem subst_subst_zero (s t body : DBTerm) (j : Nat) :
    subst s j (subst t 0 body) = subst (subst s j t) 0 (subst (shift 1 0 s) (j + 1) body) :=
  subst_subst_gen s t body j 0 (Nat.zero_le j)

/-! ## Key Lemma: substitution preserves ParBeta -/

/-
**Core Substitution Theorem**: Parallel reduction is preserved under substitution.
-/
theorem parBeta_subst {t t' s s' : DBTerm} {j : Nat}
    (ht : ParBeta t t') (hs : ParBeta s s') :
    ParBeta (subst s j t) (subst s' j t') := by
  -- By definition of substitution, we can rewrite the goal using the induction hypotheses.
  have h_subst_def : s.subst j t = subst s j t ∧ s'.subst j t' = subst s' j t' := by
    exact ⟨ rfl, rfl ⟩;
  -- By induction on $t$, we can show that $subst s j t$ is parallel reducible to $subst s' j t'$.
  have h_ind : ∀ t t' : DBTerm, ParBeta t t' → ∀ s s' : DBTerm, ParBeta s s' → ∀ j : Nat, ParBeta (subst s j t) (subst s' j t') := by
    intros t t' ht s s' hs j;
    induction' ht with t t' ht ih generalizing s s' j;
    · by_cases h : t = j <;> simp +decide [ h, DBTerm.subst ];
      · assumption;
      · split_ifs <;> [ exact ParBeta.var _; exact ParBeta.var _ ];
    · exact ParBeta.app ( by solve_by_elim ) ( by solve_by_elim );
    · rename_i k hk ih ht'' ht''';
      convert ParBeta.lam ( ht''' ( shift 1 0 s ) ( shift 1 0 s' ) ( shift_parBeta 1 0 hs ) ( j + 1 ) ) using 1;
    · rename_i hb ha ih₁ ih₂;
      convert ParBeta.beta ( ih₁ ( shift 1 0 s ) ( shift 1 0 s' ) ( shift_parBeta 1 0 hs ) ( j + 1 ) ) ( ih₂ s s' hs j ) using 1;
      grind +suggestions;
  grind +splitImp

/-! ## Complete Development (Takahashi's ⋆-translation) -/

/-- The complete development: contracts all β-redexes simultaneously. -/
def completeDev : DBTerm → DBTerm
  | var n => var n
  | app (lam body) arg => subst (completeDev arg) 0 (completeDev body)
  | app t u => app (completeDev t) (completeDev u)
  | lam t => lam (completeDev t)

/-
Every parallel reduct further reduces to the source's complete development.
-/
theorem ParBeta.to_completeDev {t u : DBTerm} (h : ParBeta t u) :
    ParBeta u (completeDev t) := by
  revert h;
  induction' t with t₁ t₂ ih₁ ih₂ generalizing u;
  · rintro ⟨ ⟩;
    constructor;
  · intro h;
    cases h;
    · rename_i t' u' ht hu;
      by_cases h : ∃ body, t₂ = DBTerm.lam body;
      · obtain ⟨ body, rfl ⟩ := h;
        -- Since $t'$ is a parallel reduct of $body.lam$, we have $t' = lam body'$ for some $body'$.
        obtain ⟨body', rfl⟩ : ∃ body', t' = DBTerm.lam body' := by
          grind +splitIndPred;
        have := ih₂ ht;
        cases this;
        convert ParBeta.beta ‹_› ( ‹∀ { u : DBTerm }, ih₁.ParBeta u → u.ParBeta ih₁.completeDev› hu ) using 1;
      · cases t₂ <;> tauto;
    · apply_rules [ ParBeta.beta, parBeta_subst ];
      rename_i h₁ h₂;
      rename_i h₃ h₄ h₅;
      contrapose! ih₂;
      use h₄.lam;
      exact ⟨ ParBeta.lam h₁, fun h => ih₂ <| by cases h; tauto ⟩;
  · rename_i t ih;
    rintro ( h | h );
    exact ParBeta.lam ( ih ‹_› )

/-- **Diamond Property**: Parallel β-reduction has the diamond property. -/
theorem parBeta_diamond {t u v : DBTerm}
    (hu : ParBeta t u) (hv : ParBeta t v) :
    ∃ w, ParBeta u w ∧ ParBeta v w :=
  ⟨completeDev t, hu.to_completeDev, hv.to_completeDev⟩

/-! ## Confluence pipeline -/

inductive ParBetaStar : DBTerm → DBTerm → Prop where
  | refl (t : DBTerm) : ParBetaStar t t
  | step {t u v : DBTerm} (h₁ : ParBeta t u) (h₂ : ParBetaStar u v) : ParBetaStar t v

theorem ParBetaStar.trans' {t u v : DBTerm}
    (h₁ : ParBetaStar t u) (h₂ : ParBetaStar u v) : ParBetaStar t v := by
  induction h₁ with
  | refl => exact h₂
  | step h₁ _ ih => exact .step h₁ (ih h₂)

theorem ParBetaStar.toMultiBeta {t u : DBTerm} (h : ParBetaStar t u) : DBMultiBeta t u := by
  induction h with
  | refl => exact .refl _
  | step h₁ _ ih => exact h₁.toMultiBeta.trans' ih

theorem DBMultiBeta.toParBetaStar {t u : DBTerm} (h : DBMultiBeta t u) : ParBetaStar t u := by
  induction h with
  | refl => exact .refl _
  | step h₁ _ ih => exact .step h₁.toParBeta ih

theorem strip_lemma {t u v : DBTerm}
    (hu : ParBeta t u) (hv : ParBetaStar t v) :
    ∃ w, ParBetaStar u w ∧ ParBeta v w := by
  induction hv generalizing u with
  | refl => exact ⟨u, .refl u, hu⟩
  | step h₁ _ ih =>
    obtain ⟨w₁, hw₁u, hw₁m⟩ := parBeta_diamond hu h₁
    obtain ⟨w₂, hw₂, hw₂v⟩ := ih hw₁m
    exact ⟨w₂, .step hw₁u hw₂, hw₂v⟩

theorem parBetaStar_confluence {t u v : DBTerm}
    (hu : ParBetaStar t u) (hv : ParBetaStar t v) :
    ∃ w, ParBetaStar u w ∧ ParBetaStar v w := by
  induction hu generalizing v with
  | refl => exact ⟨v, hv, .refl v⟩
  | step h₁ _ ih =>
    obtain ⟨w₁, hw₁, hw₁v⟩ := strip_lemma h₁ hv
    obtain ⟨w₂, hw₂u, hw₂w₁⟩ := ih hw₁
    exact ⟨w₂, hw₂u, (ParBetaStar.step hw₁v (.refl _)).trans' hw₂w₁⟩

/-! ## β-equivalence -/

inductive DBBetaEq : DBTerm → DBTerm → Prop where
  | refl (t : DBTerm) : DBBetaEq t t
  | step {t u : DBTerm} (h : Beta t u) : DBBetaEq t u
  | symm {t u : DBTerm} (h : DBBetaEq t u) : DBBetaEq u t
  | trans {t u v : DBTerm} (h₁ : DBBetaEq t u) (h₂ : DBBetaEq u v) : DBBetaEq t v

/-! ## Church-Rosser Theorem -/

/-- **Church-Rosser Theorem**: β-equivalent de Bruijn terms have a common reduct. -/
theorem db_church_rosser {t u : DBTerm}
    (h : DBBetaEq t u) : ∃ v, DBMultiBeta t v ∧ DBMultiBeta u v := by
  induction h with
  | refl t' => exact ⟨t', .refl t', .refl t'⟩
  | step h => exact ⟨_, .single h, .refl _⟩
  | symm _ ih => obtain ⟨v, h1, h2⟩ := ih; exact ⟨v, h2, h1⟩
  | trans _ _ ih₁ ih₂ =>
    obtain ⟨v₁, hv₁t, hv₁u⟩ := ih₁
    obtain ⟨v₂, hv₂u, hv₂w⟩ := ih₂
    obtain ⟨v₃, hv₃₁, hv₃₂⟩ := parBetaStar_confluence
      hv₁u.toParBetaStar hv₂u.toParBetaStar
    exact ⟨v₃, hv₁t.trans' hv₃₁.toMultiBeta, hv₂w.trans' hv₃₂.toMultiBeta⟩

/-! ## Normal Forms and Uniqueness -/

def DBNormalForm (t : DBTerm) : Prop := ∀ u, ¬ Beta t u

theorem DBNormalForm.no_multibeta {t u : DBTerm}
    (hnf : DBNormalForm t) (h : DBMultiBeta t u) : t = u := by
  induction h with
  | refl => rfl
  | step h₁ _ _ => exact absurd h₁ (hnf _)

/-- **Uniqueness of Normal Forms**: β-equivalent normal forms are identical. -/
theorem db_normalForm_unique {t u : DBTerm}
    (h : DBBetaEq t u) (ht : DBNormalForm t) (hu : DBNormalForm u) : t = u := by
  obtain ⟨v, htv, huv⟩ := db_church_rosser h
  rw [ht.no_multibeta htv, hu.no_multibeta huv]

end DBTerm

/-! ## Confluent Cost System: Abstract Metric Hub Framework -/

/-- A normalizing equivalence in an abstract rewriting system. -/
def NormalizingEquivalent {α : Type} (step : α → α → Prop) (nf : α → Prop) (t u : α) : Prop :=
  Relation.EqvGen step t u ∧ (∃ v, nf v ∧ Relation.ReflTransGen step t v) ∧
                     (∃ w, nf w ∧ Relation.ReflTransGen step u w)

/-- **Confluent Cost System**: abstracts the pattern where confluence + normalization
    yield metric bounds. -/
structure ConfluentCostSystem (α : Type) where
  /-- One-step reduction -/
  step : α → α → Prop
  /-- Normal form predicate -/
  nf : α → Prop
  /-- Confluence: equivalent terms have a common reduct -/
  confluence : ∀ {t u}, Relation.EqvGen step t u →
    ∃ v, Relation.ReflTransGen step t v ∧ Relation.ReflTransGen step u v
  /-- Normal forms don't reduce -/
  nf_stuck : ∀ {t u}, nf t → ¬ step t u

/-
A normal form that is reachable cannot reduce further.
-/
theorem nf_rtc_eq {α : Type} {step : α → α → Prop} {nf_pred : α → Prop}
    (nf_stuck : ∀ {t u : α}, nf_pred t → ¬ step t u)
    {t u : α} (hnf : nf_pred t) (h : Relation.ReflTransGen step t u) : t = u := by
  induction h <;> aesop

/-
Normal form is unique up to reachability in a confluent system.
-/
theorem ConfluentCostSystem.nf_unique (ccs : ConfluentCostSystem α)
    {t nf₁ nf₂ : α}
    (h₁ : ccs.nf nf₁) (h₂ : ccs.nf nf₂)
    (r₁ : Relation.ReflTransGen ccs.step t nf₁)
    (r₂ : Relation.ReflTransGen ccs.step t nf₂) : nf₁ = nf₂ := by
  have := ccs.confluence ( show Relation.EqvGen ccs.step nf₁ nf₂ from ?_ );
  · obtain ⟨ v, hv₁, hv₂ ⟩ := this;
    have := @nf_rtc_eq α ccs.step ccs.nf ccs.nf_stuck nf₁ v h₁ hv₁; have := @nf_rtc_eq α ccs.step ccs.nf ccs.nf_stuck nf₂ v h₂ hv₂; aesop;
  · have h_trans : ∀ {t u v : α}, Relation.ReflTransGen ccs.step t u → Relation.ReflTransGen ccs.step t v → Relation.EqvGen ccs.step u v := by
      intros t u v hu hv
      induction' hu with t' u' htu' ih generalizing v;
      · induction hv;
        · exact Relation.EqvGen.refl _;
        · exact Relation.EqvGen.trans _ _ _ ‹_› ( Relation.EqvGen.rel _ _ ‹_› );
      · rename_i h;
        exact Relation.EqvGen.trans _ _ _ ( Relation.EqvGen.symm _ _ ( Relation.EqvGen.rel _ _ ih ) ) ( h hv );
    exact h_trans r₁ r₂

/-
**Metric Hub Theorem**: In a confluent cost system, normalizing equivalent
    terms share a unique common normal form.
-/
theorem ConfluentCostSystem.hub_theorem (ccs : ConfluentCostSystem α)
    {t u : α} (h : NormalizingEquivalent ccs.step ccs.nf t u) :
    ∃ v, ccs.nf v ∧ Relation.ReflTransGen ccs.step t v ∧
         Relation.ReflTransGen ccs.step u v := by
  obtain ⟨ nft, hnft, rtft ⟩ := h.2.1
  obtain ⟨ nfu, hnfu, rtfu ⟩ := h.2.2;
  -- By confluence, there exists a common reduct $w$ such that $nft \rightarrow^* w$ and $nfu \rightarrow^* w$.
  obtain ⟨w, hw1, hw2⟩ : ∃ w, Relation.ReflTransGen ccs.step nft w ∧ Relation.ReflTransGen ccs.step nfu w := by
    -- Since $t$ and $u$ are equivalent, their normal forms $nft$ and $nfu$ must also be equivalent.
    have h_nf_equiv : Relation.EqvGen ccs.step nft nfu := by
      have h_cgs : Relation.EqvGen ccs.step t u := by
        exact h.1;
      have h_cgs : ∀ {x y : α}, Relation.EqvGen ccs.step x y → ∀ {z : α}, Relation.ReflTransGen ccs.step x z → ∀ {w : α}, Relation.ReflTransGen ccs.step y w → Relation.EqvGen ccs.step z w := by
        intros x y hxy z hxz w hyw;
        induction hxz;
        · induction hyw;
          · assumption;
          · exact Relation.EqvGen.trans _ _ _ ‹_› ( Relation.EqvGen.rel _ _ ‹_› );
        · rename_i b c hb hc ih;
          exact Relation.EqvGen.trans _ _ _ ( Relation.EqvGen.symm _ _ ( Relation.EqvGen.rel _ _ hc ) ) ih;
      exact h_cgs ‹_› rtft rtfu;
    exact ccs.confluence h_nf_equiv;
  have := @nf_rtc_eq α ccs.step ccs.nf ccs.nf_stuck nft w hnft hw1; ( have := @nf_rtc_eq α ccs.step ccs.nf ccs.nf_stuck nfu w hnfu hw2; aesop; )