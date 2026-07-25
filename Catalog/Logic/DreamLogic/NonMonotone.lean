import Logic.DreamLogic.Paraconsistent

/-!
# Dream Logic II: Structural Meta-Theory of Paraconsistent Consequence

Where `Logic.DreamLogic.Paraconsistent` studied how `LP` behaves on *individual formulas*,
this file studies the *consequence relation itself*.  The central finding is a sharp
dichotomy:

> **Structural rules survive paraconsistency; connective rules die.**

Concretely, `LP`-consequence `entails` is a genuine **Tarskian closure operator** — it
satisfies reflexivity (`entails_refl`), monotonicity (`entails_monotone`) and **Cut**
(`entails_cut`) — and it validates the *monotone* connective introductions adjunction
(`entails_and_intro`) and addition (`entails_or_intro_left`).  Yet it *rejects* the
*eliminative* connective inferences: disjunctive syllogism / modus ponens fail
(`disjunctive_syllogism_fails`, and `mp_fails` in the companion file).

The two value-level lemmas `desig_conj` and `desig_disj_left` isolate exactly the
monotonicity of designation under `min`/`max` powering the surviving introductions; the
*absence* of any disjointness law between a value and its negation (the glut `bb` designates
together with `neg bb = bb`) is what kills the eliminations.

Finally we relate `LP` to classical logic.  **Priest's validity characterization**
`lp_validity_eq_classical` is proved in full: a formula is `LP`-valid iff it is classically
valid.  The forward inclusion is trivial (`LPvalid_imp_classicallyValid`); the converse goes
through the **Collapsing Lemma** `collapse_preserve`, which shows a single classical collapse
(`bb ↦ tt`) preserves every classical output of `eval`.  We also pin down the precise sense
in which the non-monotone `LPm` *improves* on `LP`: on a consistent premise set it
**recovers** the very modus-ponens conclusion that `LP` discards (`entailsMin_recovers_mp`).

-- !-- Lab Notebook -- !--
Hypothesis: The Tarski structural rules (reflexivity, monotonicity, Cut) are orthogonal to
  paraconsistency and should survive verbatim, while the explosive connective rules should
  fail; the dividing line should be expressible at the level of single truth values.
Result: Confirmed. All three structural rules go through by elementary model-quantifier
  manipulation; adjunction/addition reduce to `desig_conj`/`desig_disj_left`; DS/MP fail on
  the single glut valuation `p ↦ bb, q ↦ ff`.
Insight: The monotone connectives (∧,∨ introductions) need only that designation is closed
  under `min`/`max`; the eliminative ones additionally need a value to be *disjoint* from its
  negation, which the glut `bb` violates. One value, `bb`, simultaneously explains LEM/LNC
  validity and DS/MP failure.
Failure analysis: The full Priest equivalence `LPvalid ↔ ClassicallyValid` does NOT close by
  a naive ≤-squeeze, because negation is *antitone* and flips the squeeze direction. The fix
  was the asymmetric **Collapsing Lemma**: a *single* classical collapse `bb ↦ tt` preserves
  both classical outputs simultaneously (`collapse_preserve`), so the negation case (which
  swaps `tt`/`ff`) and the binary cases (which need one refinement for both subformulas) all
  go through. The earlier two-collapse attempt failed precisely on negation.
-/

namespace DreamLogic

/-! ### Value-level designation lemmas (the engine of the surviving rules) -/

-- !-- `conj = min`: designated unless some conjunct is `ff`, so two designated values stay
--    designated. Proof by the 3×3 case table. -- !--
/-- Designation is closed under conjunction (`min`) — the engine of **adjunction**. -/
theorem desig_conj {a b : LPval} (ha : a.desig) (hb : b.desig) : (LPval.conj a b).desig := by
  cases a <;> cases b <;> simp_all [LPval.conj, LPval.desig]

-- !-- `disj = max ≥ a`, so a designated left disjunct is preserved. -- !--
/-- Designation is closed under (left) disjunction (`max`) — the engine of **addition**. -/
theorem desig_disj_left {a b : LPval} (ha : a.desig) : (LPval.disj a b).desig := by
  cases a <;> cases b <;> simp_all [LPval.disj, LPval.desig]

/-! ### Structural rules: `entails` is a Tarskian closure operator -/

-- !-- Reflexivity: a premise holds in every model of the premise set, by definition. -- !--
/-- **Reflexivity.** Any premise is a consequence of the premise set. -/
theorem entails_refl {Γ : Set Form} {A : Form} (hA : A ∈ Γ) : entails Γ A := by
  intro v hv; exact hv A hA

-- !-- Monotonicity: a model of the larger set is a model of the smaller set. -- !--
/-- **Monotonicity (weakening).** Enlarging the premise set preserves consequence.
The non-monotone relation `entailsMin` deliberately breaks this (`retraction_nonmonotone`). -/
theorem entails_monotone {Γ Δ : Set Form} {A : Form} (hsub : Γ ⊆ Δ) (h : entails Γ A) :
    entails Δ A :=
  fun v hv => h v (fun B hB => hv B (hsub hB))

-- !-- Cut: a model of Γ already models `insert A Γ` because `A` is entailed by Γ. -- !--
/-- **Cut.** If `Γ ⊢ A` and `Γ, A ⊢ B` then `Γ ⊢ B`. Together with reflexivity and
monotonicity this makes `entails` a genuine Tarskian closure operator. -/
theorem entails_cut {Γ : Set Form} {A B : Form} (hA : entails Γ A)
    (hB : entails (insert A Γ) B) : entails Γ B := by
  intro v hv
  apply hB v
  intro C hC
  rcases Set.mem_insert_iff.mp hC with rfl | h
  · exact hA v hv
  · exact hv C h

/-! ### Surviving connective rules: the *introductions* -/

-- !-- Adjunction follows pointwise from `desig_conj`. -- !--
/-- **Adjunction (∧-introduction).** `LP` validates conjunction introduction. -/
theorem entails_and_intro {Γ : Set Form} {A B : Form} (hA : entails Γ A) (hB : entails Γ B) :
    entails Γ (Form.conj A B) := by
  intro v hv; exact desig_conj (hA v hv) (hB v hv)

-- !-- Addition follows pointwise from `desig_disj_left`. -- !--
/-- **Addition (∨-introduction, left).** `LP` validates left disjunction introduction. -/
theorem entails_or_intro_left {Γ : Set Form} {A B : Form} (hA : entails Γ A) :
    entails Γ (Form.disj A B) := by
  intro v hv; exact desig_disj_left (hA v hv)

/-! ### Dying connective rule: the *elimination* -/

-- !-- The glut valuation `p ↦ bb, q ↦ ff` designates `p` and `¬p ∨ q` but not `q`. -- !--
/-- **Disjunctive syllogism fails.** `{p, ¬p ∨ q} ⊭ q` — the signature paraconsistent
invalidity, the dual of `mp_fails`. -/
theorem disjunctive_syllogism_fails :
    ¬ entails {Form.atom 0, Form.disj (Form.neg (Form.atom 0)) (Form.atom 1)} (Form.atom 1) := by
  intro h
  have key := h (fun n => if n = 0 then LPval.bb else LPval.ff) (by
    intro B hB
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hB
    rcases hB with rfl | rfl <;> (simp only [Holds]; decide))
  exact (by simp only [Holds]; decide :
    ¬ Holds (fun n => if n = 0 then LPval.bb else LPval.ff) (Form.atom 1)) key

/-! ### Recapture: the non-monotone `LPm` recovers MP on consistent premises -/

-- !-- Every minimal model is glut-free (the all-`tt` model has empty glut set ⊂ any
--    nonempty one), and a glut-free model of `{p, ¬p∨q}` forces `p = q = tt`. -- !--
/-- **Recapture of modus ponens.** On the *consistent* premise set `{p, p ⊃ q}` the
non-monotone relation `LPm` recovers the modus-ponens conclusion `q` that `LP` discards
(`mp_fails`). Hence `LPm` is strictly stronger than `LP` exactly where no impossible
object is forced. -/
theorem entailsMin_recovers_mp :
    entailsMin {Form.atom 0, Form.imp (Form.atom 0) (Form.atom 1)} (Form.atom 1) := by
  intro v hv
  obtain ⟨hmod, hminl⟩ := hv
  set c : Valuation := fun _ => LPval.tt with hc
  have hcmod : Models {Form.atom 0, Form.imp (Form.atom 0) (Form.atom 1)} c := by
    intro B hB
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hB
    rcases hB with rfl | rfl <;> (simp only [Holds]; decide)
  have hcempty : GlutSet c = ∅ := by ext n; simp [GlutSet, hc]
  have hvempty : GlutSet v = ∅ := by
    by_contra hne
    apply hminl c hcmod
    rw [hcempty]
    exact Set.empty_ssubset.mpr (Set.nonempty_iff_ne_empty.mpr hne)
  have hglutfree : ∀ n, v n ≠ LPval.bb := by
    intro n hcon
    have : n ∈ GlutSet v := by simp [GlutSet, hcon]
    rw [hvempty] at this; exact this
  have hv0 : v 0 = LPval.tt := by
    have hd := hmod (Form.atom 0) (by simp)
    simp only [Holds, eval] at hd
    have := hglutfree 0
    cases hcx : v 0 <;> simp_all [LPval.desig]
  have hv1 : v 1 = LPval.tt := by
    have hd := hmod (Form.imp (Form.atom 0) (Form.atom 1)) (by simp [Form.imp])
    simp only [Holds, eval, Form.imp, hv0, LPval.neg] at hd
    have := hglutfree 1
    cases hcx : v 1 <;> simp_all [LPval.desig, LPval.disj]
  simp only [Holds, eval, hv1]; decide

/-! ### Bridge to classical logic -/

/-- A boolean valuation embedded as a glut-free `LP` valuation. -/
def embed (w : ℕ → Bool) : Valuation := fun n => if w n then LPval.tt else LPval.ff

/-- **Classical validity**: holding under every glut-free (boolean) valuation. -/
def ClassicallyValid (A : Form) : Prop := ∀ w : ℕ → Bool, Holds (embed w) A

-- !-- Trivial: a glut-free valuation is in particular an `LP` valuation. -- !--
/-- **Easy half of Priest's theorem.** `LP`-validity implies classical validity. -/
theorem LPvalid_imp_classicallyValid {A : Form} (h : LPvalid A) : ClassicallyValid A :=
  fun w => h (embed w)

/-- The **glut collapse** of a valuation `v`: resolve every glut `bb` to `tt` (and keep
classical atoms), yielding a boolean (classical) valuation. -/
def collapse (v : Valuation) : ℕ → Bool := fun n => decide (v n ≠ LPval.ff)

-- !-- Embedding a boolean valuation can only ever produce the classical values `tt`/`ff`;
--    `min`/`max`/`neg` preserve two-valuedness. Induction on `A`. -- !--
/-- A boolean (embedded) valuation evaluates every formula to a **classical** value. -/
theorem eval_embed_classical (w : ℕ → Bool) (A : Form) :
    eval (embed w) A = LPval.tt ∨ eval (embed w) A = LPval.ff := by
  induction A with
  | atom n => simp only [eval, embed]; by_cases h : w n <;> simp [h]
  | neg A ih => rcases ih with h | h <;> simp [eval, h, LPval.neg]
  | conj A B ihA ihB =>
      rcases ihA with hA | hA <;> rcases ihB with hB | hB <;> simp [eval, hA, hB, LPval.conj]
  | disj A B ihA ihB =>
      rcases ihA with hA | hA <;> rcases ihB with hB | hB <;> simp [eval, hA, hB, LPval.disj]

-- !-- The Collapsing Lemma. The single collapse `bb ↦ tt` simultaneously preserves both
--    classical outputs `tt` and `ff`; the glut output `bb` is left unconstrained. Because
--    *one* classical valuation works for both polarities, the negation case (which swaps
--    `tt`/`ff`) and the conjunction/disjunction cases (which need a *single* refinement for
--    both subformulas) all go through by structural induction. -- !--
/-- **Collapsing Lemma.** The glut collapse preserves every *classical* output: if `A`
evaluates to `tt` (resp. `ff`) under `v`, it still does under the classical valuation
`embed (collapse v)`. -/
theorem collapse_preserve (v : Valuation) (A : Form) :
    (eval v A = LPval.tt → eval (embed (collapse v)) A = LPval.tt) ∧
    (eval v A = LPval.ff → eval (embed (collapse v)) A = LPval.ff) := by
  induction A with
  | atom n =>
      constructor <;> intro h <;>
        simp only [eval, embed, collapse] at h ⊢ <;> simp [h]
  | neg A ih =>
      obtain ⟨iht, ihf⟩ := ih
      constructor <;> intro h <;> simp only [eval] at h ⊢
      · have : eval v A = LPval.ff := by cases hx : eval v A <;> simp_all [LPval.neg]
        rw [ihf this]; rfl
      · have : eval v A = LPval.tt := by cases hx : eval v A <;> simp_all [LPval.neg]
        rw [iht this]; rfl
  | conj A B ihA ihB =>
      obtain ⟨ihAt, ihAf⟩ := ihA; obtain ⟨ihBt, ihBf⟩ := ihB
      constructor <;> intro h <;> simp only [eval] at h ⊢
      · have hA : eval v A = LPval.tt := by
          cases hx : eval v A <;> cases hy : eval v B <;> simp_all [LPval.conj]
        have hB : eval v B = LPval.tt := by
          cases hx : eval v A <;> cases hy : eval v B <;> simp_all [LPval.conj]
        rw [ihAt hA, ihBt hB]; rfl
      · have : eval v A = LPval.ff ∨ eval v B = LPval.ff := by
          cases hx : eval v A <;> cases hy : eval v B <;> simp_all [LPval.conj]
        rcases this with hA | hB
        · rw [ihAf hA]; cases hz : eval (embed (collapse v)) B <;> simp [LPval.conj]
        · rw [ihBf hB]; cases hz : eval (embed (collapse v)) A <;> simp [LPval.conj]
  | disj A B ihA ihB =>
      obtain ⟨ihAt, ihAf⟩ := ihA; obtain ⟨ihBt, ihBf⟩ := ihB
      constructor <;> intro h <;> simp only [eval] at h ⊢
      · have : eval v A = LPval.tt ∨ eval v B = LPval.tt := by
          cases hx : eval v A <;> cases hy : eval v B <;> simp_all [LPval.disj]
        rcases this with hA | hB
        · rw [ihAt hA]; cases hz : eval (embed (collapse v)) B <;> simp [LPval.disj]
        · rw [ihBt hB]; cases hz : eval (embed (collapse v)) A <;> simp [LPval.disj]
      · have hA : eval v A = LPval.ff := by
          cases hx : eval v A <;> cases hy : eval v B <;> simp_all [LPval.disj]
        have hB : eval v B = LPval.ff := by
          cases hx : eval v A <;> cases hy : eval v B <;> simp_all [LPval.disj]
        rw [ihAf hA, ihBf hB]; rfl

/-- An undesignated value is exactly `ff`. -/
theorem not_desig_eq_ff {x : LPval} (h : ¬ x.desig) : x = LPval.ff := by
  cases x <;> simp_all [LPval.desig]

-- !-- Lab Notebook (now a THEOREM) -- !--
-- Originally posed as a conjecture (the deep half of Priest's characterization). It is
-- discharged here via the Collapsing Lemma: a formula false at some glut valuation is
-- already false at that valuation's classical collapse, so classical validity forces LP
-- validity. The forward direction is the trivial inclusion of classical valuations.
/-- **Priest's validity characterization (`lp_validity_eq_classical`).** A formula is
`LP`-valid iff it is classically valid: gluts add **no** theorems, they only subtract
inferences. Forward is `LPvalid_imp_classicallyValid`; the converse uses the Collapsing
Lemma `collapse_preserve`. -/
theorem lp_validity_eq_classical (A : Form) : LPvalid A ↔ ClassicallyValid A := by
  constructor
  · intro h w; exact h (embed w)
  · intro h v
    by_contra hcon
    have hff : eval v A = LPval.ff := not_desig_eq_ff hcon
    have hkey := (collapse_preserve v A).2 hff
    have hcl := h (collapse v)
    simp only [Holds] at hcl
    rw [hkey] at hcl
    exact hcl

end DreamLogic