import Logic.PosetTheory.TemporalGLSyntax

/-!
# Temporal Gödel–Löb logic: derivations from finite hypothesis lists

Working towards completeness of the calculus `TemporalGLDeep.Derivable`, this file sets
up the usual "sequent-like" interface on top of the Hilbert calculus:

`Der Γ X` means `⊢ x₁ ⟹ x₂ ⟹ ⋯ ⟹ xₙ ⟹ X` for `Γ = [x₁, …, xₙ]`.

Because the calculus takes *all* classical propositional tautologies as axioms, all the
propositional bookkeeping (weakening, cut, modus ponens, case analysis) reduces to the
single evaluation lemma `evalProp_implFold`, which is what `Der_taut_conseq` and
`Der_of_Der_taut` package.  The genuinely modal content is in

* `Der_box` : `Der Δ X → Der (Δ.map ◻) (◻X)` — necessitation plus iterated `K`,
* `Der_glob` : the temporal analogue,

both obtained from the distribution lemmas `boxDistrib` / `globDistrib`, proved by
induction on the hypothesis list.
-/

namespace TemporalGLDeep

/-! ## 1. Hypothesis lists -/

/-- `implFold [x₁,…,xₙ] X` is the formula `x₁ ⟹ ⋯ ⟹ xₙ ⟹ X`. -/
def implFold : List TForm → TForm → TForm
  | [], X => X
  | B :: Γ, X => B ⟹ implFold Γ X

/-- `Der Γ X`: `X` is derivable in TGL from the hypotheses `Γ`. -/
def Der (Γ : List TForm) (X : TForm) : Prop := Derivable (implFold Γ X)

theorem evalProp_implFold (v : TForm → Prop) (Γ : List TForm) (X : TForm) :
    evalProp v (implFold Γ X) ↔ ((∀ x ∈ Γ, evalProp v x) → evalProp v X) := by
  induction Γ with
  | nil => simp [implFold]
  | cons B Γ ih =>
      constructor
      · intro h hall
        exact (ih.1 (h (hall B (by simp)))) (fun x hx => hall x (by simp [hx]))
      · intro h hB
        refine ih.2 (fun hall => h (fun x hx => ?_))
        rcases List.mem_cons.1 hx with rfl | hx
        · exact hB
        · exact hall x hx

/-- Every tautological consequence of `Γ` is derivable from `Γ`. -/
theorem Der_taut_conseq {Γ : List TForm} {X : TForm}
    (h : ∀ v : TForm → Prop, (∀ x ∈ Γ, evalProp v x) → evalProp v X) : Der Γ X :=
  Derivable.taut (fun v => (evalProp_implFold v Γ X).2 (h v))

/-- One derivation may be transformed along any tautological implication between the
corresponding sequents. -/
theorem Der_of_Der_taut {Γ₁ Γ₂ : List TForm} {X Y : TForm}
    (h : ∀ v : TForm → Prop, ((∀ x ∈ Γ₁, evalProp v x) → evalProp v X) →
      ((∀ x ∈ Γ₂, evalProp v x) → evalProp v Y))
    (hd : Der Γ₁ X) : Der Γ₂ Y := by
  refine Derivable.mp (Derivable.taut (fun v => ?_)) hd
  show evalProp v (implFold Γ₁ X) → evalProp v (implFold Γ₂ Y)
  intro h1
  exact (evalProp_implFold v Γ₂ Y).2 (h v ((evalProp_implFold v Γ₁ X).1 h1))

theorem Der_of_mem {Γ : List TForm} {X : TForm} (h : X ∈ Γ) : Der Γ X :=
  Der_taut_conseq (fun _ hv => hv X h)

theorem Der_of_derivable {Γ : List TForm} {X : TForm} (h : Derivable X) : Der Γ X := by
  refine Derivable.mp (Derivable.taut (fun v => ?_)) h
  show evalProp v X → evalProp v (implFold Γ X)
  intro hX
  exact (evalProp_implFold v Γ X).2 (fun _ => hX)

theorem Der_mono {Γ₁ Γ₂ : List TForm} {X : TForm} (hs : ∀ x ∈ Γ₁, x ∈ Γ₂) (h : Der Γ₁ X) :
    Der Γ₂ X :=
  Der_of_Der_taut (fun _ h1 hv => h1 (fun x hx => hv x (hs x hx))) h

theorem Der_mp {Γ : List TForm} {X Y : TForm} (h₁ : Der Γ (X ⟹ Y)) (h₂ : Der Γ X) :
    Der Γ Y := by
  have ht : Taut ((implFold Γ (X ⟹ Y)) ⟹ ((implFold Γ X) ⟹ implFold Γ Y)) := by
    intro v
    show evalProp v (implFold Γ (X ⟹ Y)) → evalProp v (implFold Γ X) →
      evalProp v (implFold Γ Y)
    intro ha hb
    exact (evalProp_implFold v Γ Y).2 (fun hv =>
      ((evalProp_implFold v Γ (X ⟹ Y)).1 ha hv) ((evalProp_implFold v Γ X).1 hb hv))
  exact Derivable.mp (Derivable.mp (Derivable.taut ht) h₁) h₂

/-- **Cut**: if every hypothesis of `Δ` is derivable from `Γ`, then anything derivable
from `Δ` is derivable from `Γ`. -/
theorem Der_cut {Γ Δ : List TForm} {X : TForm} (h : ∀ x ∈ Δ, Der Γ x) (hd : Der Δ X) :
    Der Γ X := by
  have main : ∀ (Δ : List TForm) (X : TForm), (∀ x ∈ Δ, Der Γ x) →
      Der Γ (implFold Δ X) → Der Γ X := by
    intro Δ
    induction Δ with
    | nil => intro X _ h; exact h
    | cons B Δ ih =>
        intro X hmem hfold
        refine ih X (fun x hx => hmem x (by simp [hx])) ?_
        exact Der_mp hfold (hmem B (by simp))
  exact main Δ X h (Der_of_derivable hd)

/-- **Case analysis** on a formula and its negation. -/
theorem Der_case {Γ : List TForm} {B X : TForm} (h₁ : Der (B :: Γ) X)
    (h₂ : Der (B.neg :: Γ) X) : Der Γ X := by
  have ht : Taut ((implFold (B :: Γ) X) ⟹ ((implFold (B.neg :: Γ) X) ⟹ implFold Γ X)) := by
    intro v
    show evalProp v (implFold (B :: Γ) X) → evalProp v (implFold (B.neg :: Γ) X) →
      evalProp v (implFold Γ X)
    intro ha hb
    refine (evalProp_implFold v Γ X).2 (fun hv => ?_)
    by_cases hB : evalProp v B
    · refine (evalProp_implFold v (B :: Γ) X).1 ha (fun x hx => ?_)
      rcases List.mem_cons.1 hx with rfl | hx
      · exact hB
      · exact hv x hx
    · refine (evalProp_implFold v (B.neg :: Γ) X).1 hb (fun x hx => ?_)
      rcases List.mem_cons.1 hx with rfl | hx
      · exact fun hc => (hB hc).elim
      · exact hv x hx
  exact Derivable.mp (Derivable.mp (Derivable.taut ht) h₁) h₂

/-! ## 2. Modal distribution over hypothesis lists -/

/-- Composition inside a two-premise implication. -/
theorem derivable_comp2 {P Q R S : TForm} (h₁ : Derivable (P ⟹ (Q ⟹ R)))
    (h₂ : Derivable (R ⟹ S)) : Derivable (P ⟹ (Q ⟹ S)) := by
  have ht : Derivable ((P ⟹ (Q ⟹ R)) ⟹ ((R ⟹ S) ⟹ (P ⟹ (Q ⟹ S)))) :=
    Derivable.taut (fun _ a b c d => b (a c d))
  exact Derivable.mp (Derivable.mp ht h₁) h₂

/-- Distribution of `◻` over an implication fold. -/
theorem boxDistrib (Δ : List TForm) (X : TForm) :
    Derivable ((◻(implFold Δ X)) ⟹ implFold (Δ.map TForm.box) (◻X)) := by
  induction Δ generalizing X with
  | nil => exact Derivable.taut (fun _ h => h)
  | cons B Δ ih =>
      show Derivable ((◻(B ⟹ implFold Δ X)) ⟹
        ((◻B) ⟹ implFold (Δ.map TForm.box) (◻X)))
      have hk : Derivable ((◻(B ⟹ implFold Δ X)) ⟹ ((◻B) ⟹ ◻(implFold Δ X))) :=
        Derivable.boxK
      exact derivable_comp2 hk (ih X)

/-- Distribution of `◼` over an implication fold. -/
theorem globDistrib (Δ : List TForm) (X : TForm) :
    Derivable ((◼(implFold Δ X)) ⟹ implFold (Δ.map TForm.glob) (◼X)) := by
  induction Δ generalizing X with
  | nil => exact Derivable.taut (fun _ h => h)
  | cons B Δ ih =>
      show Derivable ((◼(B ⟹ implFold Δ X)) ⟹
        ((◼B) ⟹ implFold (Δ.map TForm.glob) (◼X)))
      have hk : Derivable ((◼(B ⟹ implFold Δ X)) ⟹ ((◼B) ⟹ ◼(implFold Δ X))) :=
        Derivable.globK
      exact derivable_comp2 hk (ih X)

/-- **Boxed necessitation of a sequent.** -/
theorem Der_box {Δ : List TForm} {X : TForm} (h : Der Δ X) : Der (Δ.map TForm.box) (◻X) :=
  Derivable.mp (boxDistrib Δ X) (Derivable.boxNec h)

/-- **Temporal necessitation of a sequent.** -/
theorem Der_glob {Δ : List TForm} {X : TForm} (h : Der Δ X) : Der (Δ.map TForm.glob) (◼X) :=
  Derivable.mp (globDistrib Δ X) (Derivable.globNec h)

/-! ## 3. Consistency bookkeeping -/

/-- A hypothesis list is consistent if it does not derive `⊥`. -/
def ListCons (Γ : List TForm) : Prop := ¬ Der Γ TForm.bot

theorem not_mem_of_neg_mem {Γ : List TForm} (hc : ListCons Γ) {B : TForm}
    (h₁ : B ∈ Γ) (h₂ : B.neg ∈ Γ) : False :=
  hc (Der_mp (Der_of_mem h₂) (Der_of_mem h₁))

/-- **Extension to a decided list.**  Any consistent list can be extended, keeping
consistency, so that every formula of `L` is decided one way or the other. -/
theorem extend_list (L : List TForm) : ∀ (Γ : List TForm), ListCons Γ →
    ∃ Γ', (∀ x ∈ Γ, x ∈ Γ') ∧ (∀ B ∈ L, B ∈ Γ' ∨ B.neg ∈ Γ') ∧ ListCons Γ' := by
  induction L with
  | nil => intro Γ h; exact ⟨Γ, fun _ hx => hx, by simp, h⟩
  | cons B L ih =>
      intro Γ h
      by_cases hB : Der (B :: Γ) TForm.bot
      · have h2 : ListCons (B.neg :: Γ) := fun hc => h (Der_case hB hc)
        obtain ⟨Γ', h1, h2', h3⟩ := ih (B.neg :: Γ) h2
        refine ⟨Γ', fun x hx => h1 x (List.mem_cons_of_mem _ hx), ?_, h3⟩
        intro C hC
        rcases List.mem_cons.1 hC with rfl | hC
        · exact Or.inr (h1 _ (by simp))
        · exact h2' C hC
      · obtain ⟨Γ', h1, h2', h3⟩ := ih (B :: Γ) hB
        refine ⟨Γ', fun x hx => h1 x (List.mem_cons_of_mem _ hx), ?_, h3⟩
        intro C hC
        rcases List.mem_cons.1 hC with rfl | hC
        · exact Or.inl (h1 _ (by simp))
        · exact h2' C hC

end TemporalGLDeep