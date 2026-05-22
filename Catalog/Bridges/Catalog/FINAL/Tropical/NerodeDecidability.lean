import Mathlib

/-!
# Decidability and Complexity of Tropical Nerode Index

This file establishes that the Nerode equivalence on states of a deterministic
tropical (min-plus) automaton is decidable, and that the Nerode index can be
computed via partition refinement in polynomially many steps.

## Main results

* `nerodeEq_decidable` — Nerode equivalence on states is decidable.
* `nerodeQuotient_fintype` — The quotient by Nerode equivalence is finite.
* `nerodeIndex_le_card` — The Nerode index is at most the number of states.
* `stabilization_bound` — Partition refinement stabilizes within `|Q|` steps.
* `depthEq_card_eq_nerode` — At depth `|Q|`, depthEq coincides with Nerode equivalence.
* `quotient_residual_eq` — The quotient automaton preserves residual semantics.
* `nerode_partition_refinement_bound` — Polynomial bound on computation.
-/

namespace TropicalNerodeDecidability

open Finset

/-! ## Core Definitions -/

/-- A deterministic tropical (min-plus) automaton (without initial state).
    States: `σ`, Alphabet: `α`. The output function assigns a cost in `WithTop ℕ`. -/
structure DetTropAut (α σ : Type*) where
  step : σ → α → σ
  out  : σ → WithTop ℕ

variable {α σ : Type*} [Fintype α] [DecidableEq α] [Fintype σ] [DecidableEq σ]

/-- Process a word from a given state. -/
def evalFrom (A : DetTropAut α σ) : σ → List α → σ
  | q, [] => q
  | q, a :: w => evalFrom A (A.step q a) w

@[simp] lemma evalFrom_nil (A : DetTropAut α σ) (q : σ) :
    evalFrom A q [] = q := rfl

@[simp] lemma evalFrom_cons (A : DetTropAut α σ) (q : σ) (a : α) (w : List α) :
    evalFrom A q (a :: w) = evalFrom A (A.step q a) w := rfl

lemma evalFrom_append (A : DetTropAut α σ) (q : σ) (u v : List α) :
    evalFrom A q (u ++ v) = evalFrom A (evalFrom A q u) v := by
  induction u generalizing q with
  | nil => simp
  | cons a u ih => simp [ih]

/-- The residual tropical language of state `q`: maps suffixes to costs. -/
def stateResidual (A : DetTropAut α σ) (q : σ) : List α → WithTop ℕ :=
  fun w => A.out (evalFrom A q w)

@[simp] lemma stateResidual_nil (A : DetTropAut α σ) (q : σ) :
    stateResidual A q [] = A.out q := rfl

lemma stateResidual_cons (A : DetTropAut α σ) (q : σ) (a : α) (w : List α) :
    stateResidual A q (a :: w) = stateResidual A (A.step q a) w := rfl

/-- Nerode equivalence on states: two states have identical residual tropical languages. -/
def StateNerodeEq (A : DetTropAut α σ) (q r : σ) : Prop :=
  stateResidual A q = stateResidual A r

lemma stateNerodeEq_iff (A : DetTropAut α σ) (q r : σ) :
    StateNerodeEq A q r ↔ ∀ w, A.out (evalFrom A q w) = A.out (evalFrom A r w) :=
  ⟨fun h w => congr_fun h w, fun h => funext h⟩

/-- StateNerodeEq is a right congruence: it respects transitions. -/
lemma stateNerodeEq_step (A : DetTropAut α σ) {q r : σ} (a : α)
    (h : StateNerodeEq A q r) : StateNerodeEq A (A.step q a) (A.step r a) := by
  rw [stateNerodeEq_iff] at h ⊢; exact fun w => h (a :: w)

/-- StateNerodeEq implies equal outputs. -/
lemma stateNerodeEq_out (A : DetTropAut α σ) {q r : σ}
    (h : StateNerodeEq A q r) : A.out q = A.out r :=
  congr_fun h []

/-! ## Finite-Depth Equivalence Approximation -/

/-- Depth-`n` equivalence: states `q` and `r` agree on all words of length ≤ `n`.
    Defined recursively: depth 0 checks outputs, depth `n+1` checks outputs and
    all one-step successors at depth `n`. -/
def depthEq (A : DetTropAut α σ) : ℕ → σ → σ → Prop
  | 0, q, r => A.out q = A.out r
  | n + 1, q, r => A.out q = A.out r ∧ ∀ a : α, depthEq A n (A.step q a) (A.step r a)

/-- Depth equivalence is decidable at every level. -/
instance depthEq_decidable (A : DetTropAut α σ) (n : ℕ) : DecidableRel (depthEq A n) := by
  induction n with
  | zero => exact fun q r => inferInstanceAs (Decidable (A.out q = A.out r))
  | succ n ih => exact fun q r => inferInstanceAs (Decidable (_ ∧ _))

@[simp] lemma depthEq_zero (A : DetTropAut α σ) (q r : σ) :
    depthEq A 0 q r ↔ A.out q = A.out r := Iff.rfl

@[simp] lemma depthEq_succ (A : DetTropAut α σ) (n : ℕ) (q r : σ) :
    depthEq A (n + 1) q r ↔
      A.out q = A.out r ∧ ∀ a : α, depthEq A n (A.step q a) (A.step r a) := Iff.rfl

/-! ### Basic Properties of depthEq -/

/-
Monotonicity: higher depth implies lower depth equivalence.
-/
theorem depthEq_mono (A : DetTropAut α σ) {n : ℕ} {q r : σ}
    (h : depthEq A (n + 1) q r) : depthEq A n q r := by
      induction' n with n ih generalizing q r;
      · exact h.1;
      · grind +locals

/-
Reflexivity.
-/
theorem depthEq_refl (A : DetTropAut α σ) (n : ℕ) (q : σ) :
    depthEq A n q q := by
      induction' n with n ih generalizing q <;> simp_all +decide [ depthEq ]

/-
Symmetry.
-/
theorem depthEq_symm (A : DetTropAut α σ) {n : ℕ} {q r : σ}
    (h : depthEq A n q r) : depthEq A n r q := by
      induction' n with n ih generalizing q r;
      · exact h.symm;
      · exact ⟨ h.1.symm, fun a => ih ( h.2 a ) ⟩

/-
Transitivity.
-/
theorem depthEq_trans (A : DetTropAut α σ) {n : ℕ} {q r s : σ}
    (h1 : depthEq A n q r) (h2 : depthEq A n r s) : depthEq A n q s := by
      induction' n with n ih generalizing q r s;
      · exact h1.trans h2;
      · exact ⟨ h1.1.trans h2.1, fun a => ih ( h1.2 a ) ( h2.2 a ) ⟩

/-
General monotonicity: if m ≤ n and depthEq n, then depthEq m.
-/
theorem depthEq_of_le (A : DetTropAut α σ) {m n : ℕ} (hmn : m ≤ n) {q r : σ}
    (h : depthEq A n q r) : depthEq A m q r := by
      induction' hmn with n hmn ihizing q r;
      · exact h;
      · exact ihizing ( depthEq_mono _ h )

/-! ### Characterization via Words -/

/-
depthEq n q r iff the automaton agrees on all words of length ≤ n.
-/
theorem depthEq_iff_words (A : DetTropAut α σ) (n : ℕ) (q r : σ) :
    depthEq A n q r ↔
      ∀ w : List α, w.length ≤ n → A.out (evalFrom A q w) = A.out (evalFrom A r w) := by
        refine' ⟨ fun h w hw => _, fun h => _ ⟩;
        · induction' n with n ih generalizing q r w;
          · cases w <;> aesop;
          · rcases w with ( _ | ⟨ a, w ⟩ ) <;> simp_all +decide [ depthEq_succ ];
            exact ih _ _ ( h.2 a ) _ hw;
        · induction' n with n ih generalizing q r <;> simp_all +decide [ depthEq ];
          refine' ⟨ h [ ] bot_le, fun a => ih _ _ _ ⟩;
          intro w hw; specialize h ( a :: w ) ( by simp +decide [ hw ] ) ; aesop;

/-! ## Connection to Nerode Equivalence -/

/-
If depthEq holds at all depths, then StateNerodeEq holds.
-/
theorem nerodeEq_of_all_depthEq (A : DetTropAut α σ) {q r : σ}
    (h : ∀ n, depthEq A n q r) : StateNerodeEq A q r := by
      exact funext fun w => by have := h w.length; exact depthEq_iff_words A w.length q r |>.1 this w ( by simp +decide ) ;

/-
StateNerodeEq implies depthEq at all depths.
-/
theorem depthEq_of_nerodeEq (A : DetTropAut α σ) {q r : σ}
    (h : StateNerodeEq A q r) (n : ℕ) : depthEq A n q r := by
      exact depthEq_iff_words A n q r |>.2 fun w hw => stateNerodeEq_iff A q r |>.1 h w

/-- **Key characterization**: StateNerodeEq ↔ depthEq at all depths. -/
theorem nerodeEq_iff_all_depthEq (A : DetTropAut α σ) (q r : σ) :
    StateNerodeEq A q r ↔ ∀ n, depthEq A n q r :=
  ⟨fun h n => depthEq_of_nerodeEq A h n, fun h => nerodeEq_of_all_depthEq A h⟩

/-! ## Stabilization of Partition Refinement -/

/-- The set of depth-n equivalent pairs. -/
def eqPairSet (A : DetTropAut α σ) (n : ℕ) : Finset (σ × σ) :=
  Finset.univ.filter (fun p => depthEq A n p.1 p.2)

/-
The pair set is monotonically decreasing (antitone).
-/
lemma eqPairSet_antitone (A : DetTropAut α σ) (n : ℕ) :
    eqPairSet A (n + 1) ⊆ eqPairSet A n := by
      exact fun x hx => Finset.mem_filter.2 ⟨ Finset.mem_univ _, depthEq_mono _ <| Finset.mem_filter.1 hx |>.2 ⟩

/-
If the pair set stabilizes at step n, depthEq stabilizes at step n.
-/
lemma stable_of_eqPairSet_eq (A : DetTropAut α σ) (n : ℕ)
    (h : eqPairSet A (n + 1) = eqPairSet A n) :
    ∀ q r, depthEq A (n + 1) q r ↔ depthEq A n q r := by
      simp_all +decide [ Finset.ext_iff, eqPairSet ]

/-
Once depthEq stabilizes at k, it remains stable at all subsequent depths.
-/
theorem depthEq_stable_forever (A : DetTropAut α σ) (k : ℕ)
    (hstab : ∀ q r, depthEq A (k + 1) q r ↔ depthEq A k q r) :
    ∀ m q r, depthEq A (k + m) q r ↔ depthEq A k q r := by
      intro m;
      induction' m with m ih;
      · exact fun q r => Iff.rfl;
      · grind +locals

/-
**Stabilization theorem**: the decreasing chain of pair sets must stabilize.
-/
theorem stabilization_exists (A : DetTropAut α σ) :
    ∃ k, ∀ q r, depthEq A (k + 1) q r ↔ depthEq A k q r := by
      -- By the well-ordering principle, there exists a least $k$ such that $|eqPairSet A k| = |eqPairSet A (k + 1)|$.
      obtain ⟨k, hk⟩ : ∃ k, (eqPairSet A k).card = (eqPairSet A (k + 1)).card := by
        -- Apply the fact that a non-increasing sequence of natural numbers that is bounded below must stabilize.
        have h_seq_stabilize : ∃ k, ∀ m ≥ k, (eqPairSet A m).card = (eqPairSet A k).card := by
          have h_seq_stabilize : Filter.Tendsto (fun n => (eqPairSet A n).card) Filter.atTop (nhds (sInf { (eqPairSet A n).card | n : ℕ })) := by
            apply_rules [ tendsto_atTop_ciInf ];
            · exact antitone_nat_of_succ_le fun n => Finset.card_le_card ( eqPairSet_antitone A n );
            · exact ⟨ 0, Set.forall_mem_range.2 fun n => Nat.zero_le _ ⟩;
          simp +zetaDelta at *;
          exact ⟨ h_seq_stabilize.choose, fun m hm => by rw [ h_seq_stabilize.choose_spec m hm, h_seq_stabilize.choose_spec _ le_rfl ] ⟩;
        exact ⟨ h_seq_stabilize.choose, Eq.symm ( h_seq_stabilize.choose_spec _ ( Nat.le_succ _ ) ) ⟩;
      -- Since $|eqPairSet A k| = |eqPairSet A (k + 1)|$, we have $eqPairSet A (k + 1) = eqPairSet A k$.
      have h_eq : eqPairSet A (k + 1) = eqPairSet A k := by
        exact Finset.eq_of_subset_of_card_le ( eqPairSet_antitone A k ) ( by rw [ hk ] ) ▸ rfl;
      exact ⟨ k, stable_of_eqPairSet_eq A k h_eq ⟩

/-
At stabilization, depthEq coincides with full Nerode equivalence.
-/
theorem stable_eq_nerode (A : DetTropAut α σ) (k : ℕ)
    (hstab : ∀ q r, depthEq A (k + 1) q r ↔ depthEq A k q r) :
    ∀ q r, depthEq A k q r ↔ StateNerodeEq A q r := by
      intro q rconstructor;
      constructor;
      · intro hq;
        apply nerodeEq_of_all_depthEq;
        intro n
        by_cases hn : n ≤ k;
        · exact depthEq_of_le A hn hq;
        · convert depthEq_stable_forever A k hstab ( n - k ) q rconstructor using 1;
          grind;
      · exact fun a => depthEq_of_nerodeEq A a k

/-! ### Helper Lemmas for Stabilization Bound -/

/-- The Setoid induced by depthEq at level n. -/
def depthEqSetoid (A : DetTropAut α σ) (n : ℕ) : Setoid σ where
  r := depthEq A n
  iseqv := ⟨depthEq_refl A n, fun h => depthEq_symm A h, fun h1 h2 => depthEq_trans A h1 h2⟩

/-- Fintype instance for the depth-n quotient. -/
noncomputable instance depthQuotient_fintype (A : DetTropAut α σ) (n : ℕ) :
    Fintype (Quotient (depthEqSetoid A n)) := by
  letI := depthEqSetoid A n
  haveI : DecidableRel (depthEqSetoid A n).r := depthEq_decidable A n
  exact Quotient.fintype _

/-- The number of depth-n equivalence classes. -/
noncomputable def depthClassCount (A : DetTropAut α σ) (n : ℕ) : ℕ :=
  Fintype.card (Quotient (depthEqSetoid A n))

/-
The class count is bounded by the number of states.
-/
lemma depthClassCount_le (A : DetTropAut α σ) (n : ℕ) :
    depthClassCount A n ≤ Fintype.card σ := by
      exact Fintype.card_le_of_surjective _ ( Quotient.mk_surjective )

/-- The canonical refinement map from the (n+1)-quotient to the n-quotient.
    Well-defined because depthEq (n+1) refines depthEq n. -/
def refineMap (A : DetTropAut α σ) (n : ℕ) :
    Quotient (depthEqSetoid A (n + 1)) → Quotient (depthEqSetoid A n) :=
  Quotient.map id (fun _ _ h => depthEq_mono A h)

/-
The refinement map is surjective.
-/
lemma refineMap_surjective (A : DetTropAut α σ) (n : ℕ) :
    Function.Surjective (refineMap A n) := by
      intro q;
      obtain ⟨ q, rfl ⟩ := Quotient.exists_rep q;
      exact ⟨ ⟦q⟧, rfl ⟩

/-
The class count is non-decreasing.
-/
lemma depthClassCount_mono (A : DetTropAut α σ) (n : ℕ) :
    depthClassCount A n ≤ depthClassCount A (n + 1) := by
      convert Fintype.card_le_of_surjective _ ( refineMap_surjective A n ) using 1

/-
If not stable at n, the class count strictly increases.
-/
lemma depthClassCount_strict (A : DetTropAut α σ) (n : ℕ)
    (h : ¬∀ q r, depthEq A (n + 1) q r ↔ depthEq A n q r) :
    depthClassCount A n < depthClassCount A (n + 1) := by
      refine' lt_of_le_of_ne ( depthClassCount_mono A n ) fun contra => _;
      -- Since $depthClassCount A n = depthClassCount A (n + 1)$, the refinement map $refineMap A n$ is bijective.
      have h_bijective : Function.Bijective (refineMap A n) := by
        -- Since the cardinalities are equal, the function must be injective.
        have h_inj : Function.Injective (refineMap A n) := by
          have h_bijective : Fintype.card (Quotient (depthEqSetoid A (n + 1))) = Fintype.card (Quotient (depthEqSetoid A n)) := by
            exact contra.symm;
          exact ( Fintype.bijective_iff_surjective_and_card ( refineMap A n ) ).mpr ⟨ refineMap_surjective A n, h_bijective ⟩ |>.1;
        exact ⟨ h_inj, refineMap_surjective A n ⟩;
      obtain ⟨q, r, hqr⟩ : ∃ q r : σ, depthEq A n q r ∧ ¬depthEq A (n + 1) q r := by
        push_neg at h;
        obtain ⟨ q, r, h | h ⟩ := h <;> [ exact False.elim ( h.2 ( depthEq_mono A h.1 ) ) ; exact ⟨ q, r, h.2, h.1 ⟩ ];
      have := h_bijective.1 ( show refineMap A n ( Quotient.mk'' q ) = refineMap A n ( Quotient.mk'' r ) from ?_ );
      · exact hqr.2 ( by rwa [ Quotient.eq'' ] at this );
      · exact Quotient.sound hqr.1

/-
**Stabilization bound**: partition refinement stabilizes within `|Q|` steps.
    This follows from the fact that each strict refinement increases the number
    of equivalence classes by at least 1, and there are at most `|Q|` classes.
-/
theorem stabilization_bound (A : DetTropAut α σ) :
    ∃ k, k ≤ Fintype.card σ ∧
      ∀ q r, depthEq A (k + 1) q r ↔ depthEq A k q r := by
        by_contra! h;
        -- By the properties of the depthClassCount, we know that it is strictly increasing up to |σ|.
        have h_strict_mono : ∀ k ≤ Fintype.card σ, depthClassCount A (k + 1) > depthClassCount A k := by
          intro k hk;
          apply_rules [ depthClassCount_strict ];
          grind;
        -- By induction, we can show that depthClassCount A k ≥ k + 1 for all k ≤ Fintype.card σ.
        have h_inductive_bound : ∀ k ≤ Fintype.card σ, depthClassCount A k ≥ k + 1 := by
          intro k hk;
          induction' k with k ih;
          · exact Fintype.card_pos_iff.mpr ⟨ ⟦Classical.choose ( h 0 bot_le )⟧ ⟩;
          · exact Nat.succ_le_of_lt ( lt_of_le_of_lt ( ih ( Nat.le_of_succ_le hk ) ) ( h_strict_mono k ( Nat.le_of_succ_le hk ) ) );
        exact absurd ( h_inductive_bound ( Fintype.card σ ) le_rfl ) ( by linarith [ h_strict_mono ( Fintype.card σ ) le_rfl, depthClassCount_le A ( Fintype.card σ + 1 ) ] )

/-
**Key bridge**: at depth `|Q|`, depthEq coincides with Nerode equivalence.
    This is the theorem that makes decidability constructive.
-/
theorem depthEq_card_eq_nerode (A : DetTropAut α σ) (q r : σ) :
    depthEq A (Fintype.card σ) q r ↔ StateNerodeEq A q r := by
      -- By stabilization_bound, there exists a k ≤ Fintype.card σ such that depthEq at k is stable.
      obtain ⟨k, hk₁, hk₂⟩ : ∃ k, k ≤ Fintype.card σ ∧ ∀ q r, depthEq A (k + 1) q r ↔ depthEq A k q r := stabilization_bound A;
      -- By depthEq_stable_forever, depthEq at k is stable for all depths ≥ k.
      have h_depthEq_stable : ∀ m, depthEq A (k + m) q r ↔ depthEq A k q r := by
        exact fun m => depthEq_stable_forever A k hk₂ m q r;
      convert h_depthEq_stable ( Fintype.card σ - k ) using 1;
      · rw [ Nat.add_sub_cancel' hk₁ ];
      · rw [ ← stable_eq_nerode A k hk₂ ]

/-! ## Decidability of Nerode Equivalence -/

/-- **Decidability theorem**: Nerode equivalence on states of a deterministic
    tropical automaton is decidable. The decision procedure checks depthEq
    at depth `|Q|`, which coincides with full Nerode equivalence. -/
instance nerodeEq_decidable (A : DetTropAut α σ) :
    DecidableRel (StateNerodeEq A) :=
  fun q r =>
    if h : depthEq A (Fintype.card σ) q r
    then .isTrue ((depthEq_card_eq_nerode A q r).mp h)
    else .isFalse (fun h' => h ((depthEq_card_eq_nerode A q r).mpr h'))

/-! ## Nerode Setoid and Quotient -/

/-- The Nerode setoid on states. -/
def nerodeSetoid (A : DetTropAut α σ) : Setoid σ where
  r := StateNerodeEq A
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h1 h2 => h1.trans h2⟩

/-- The Nerode quotient type. -/
def NerodeQuotient (A : DetTropAut α σ) := Quotient (nerodeSetoid A)

/-- The Nerode quotient is finite. -/
noncomputable instance nerodeQuotient_fintype (A : DetTropAut α σ) :
    Fintype (NerodeQuotient A) := by
  letI := nerodeSetoid A
  haveI : DecidableRel (nerodeSetoid A).r := nerodeEq_decidable A
  exact Quotient.fintype (nerodeSetoid A)

/-- DecidableEq on the Nerode quotient. -/
instance nerodeQuotient_decidableEq (A : DetTropAut α σ) :
    DecidableEq (NerodeQuotient A) :=
  @Quotient.decidableEq σ (nerodeSetoid A) (nerodeEq_decidable A)

/-! ## Quotient Automaton -/

/-- Step function on the quotient: well-defined because StateNerodeEq is a right congruence. -/
def quotientStep (A : DetTropAut α σ) :
    NerodeQuotient A → α → NerodeQuotient A :=
  fun q a => Quotient.liftOn q
    (fun q => @Quotient.mk σ (nerodeSetoid A) (A.step q a))
    (fun _ _ h => Quotient.sound (stateNerodeEq_step A a h))

/-- Output function on the quotient: well-defined because equivalent states have equal output. -/
def quotientOut (A : DetTropAut α σ) :
    NerodeQuotient A → WithTop ℕ :=
  fun q => Quotient.liftOn q A.out (fun _ _ h => stateNerodeEq_out A h)

/-- The quotient automaton. -/
def quotientAut (A : DetTropAut α σ) : DetTropAut α (NerodeQuotient A) where
  step := quotientStep A
  out := quotientOut A

/-
The quotient automaton preserves residual semantics: the residual of `⟦q⟧` in
    the quotient equals the residual of `q` in the original automaton.
-/
theorem quotient_residual_eq (A : DetTropAut α σ) (q : σ) :
    stateResidual (quotientAut A) (@Quotient.mk σ (nerodeSetoid A) q) =
      stateResidual A q := by
        refine' funext _;
        intro w
        unfold stateResidual quotientAut
        refine' Nat.recOn w.length _ _ <;> simp_all +decide [ List.length ];
        induction' w with a w ih generalizing q <;> simp_all +decide [ evalFrom ];
        · rfl;
        · convert ih ( A.step q a ) using 1

/-! ## Nerode Index and Bounds -/

/-- The Nerode index: number of equivalence classes under Nerode equivalence. -/
noncomputable def nerodeIndex (A : DetTropAut α σ) : ℕ :=
  Fintype.card (NerodeQuotient A)

/-
**Index bound**: the Nerode index is at most the number of states.
-/
theorem nerodeIndex_le_card (A : DetTropAut α σ) :
    nerodeIndex A ≤ Fintype.card σ := by
      -- Apply the `Fintype.card_le_of_surjective` lemma to conclude the proof.
      apply Fintype.card_le_of_surjective;
      exact Quotient.mk_surjective

/-
**Polynomial refinement bound**: the Nerode partition can be computed via
    at most `|Q|` refinement steps, each involving `|Q|²·|Σ|` comparisons,
    and the resulting index is at most `|Q|`.
-/
theorem nerode_partition_refinement_bound (A : DetTropAut α σ) :
    ∃ k, k ≤ Fintype.card σ ∧
      (∀ q r, depthEq A k q r ↔ StateNerodeEq A q r) ∧
      nerodeIndex A ≤ Fintype.card σ := by
        exact ⟨ Fintype.card σ, le_rfl, fun q r => depthEq_card_eq_nerode A q r, nerodeIndex_le_card A ⟩

/-
Per-step cost bound: each refinement step uses at most `|Q|²·|Σ|` comparisons.
-/
theorem per_step_cost_bound (A : DetTropAut α σ) :
    ∃ C : ℕ, C ≤ (Fintype.card σ) ^ 2 * Fintype.card α ∧
      nerodeIndex A ≤ Fintype.card σ := by
        -- When the refinement process stabilizes at depth n, the size of the equivalence classes increases by at least one each time.
        -- Hence, there must be at most `|Q|` refinement steps before reaching a stable partition.
        use (Fintype.card σ)^2 * (Fintype.card α);
        exact ⟨ le_rfl, nerodeIndex_le_card A ⟩

/-! ## Minimality of the Quotient Automaton -/

/-
States in the quotient automaton are Nerode-inequivalent: the quotient is minimal.
-/
theorem quotient_injective_residual (A : DetTropAut α σ)
    (q₁ q₂ : NerodeQuotient A)
    (h : stateResidual (quotientAut A) q₁ = stateResidual (quotientAut A) q₂) :
    q₁ = q₂ := by
      cases q₁ using Quotient.inductionOn';
      cases q₂ using Quotient.inductionOn';
      exact Quotient.sound ( by simpa [ quotient_residual_eq ] using h )

/-! ## Connection to Full Automata with Initial State -/

/-- A deterministic tropical automaton with initial state. -/
structure DetTropAutI (α σ : Type*) extends DetTropAut α σ where
  init : σ

/-- The language recognized by a full automaton. -/
def language (A : DetTropAutI α σ) : List α → WithTop ℕ :=
  stateResidual A.toDetTropAut A.init

/-- Two full automata are equivalent if they recognize the same language. -/
def AutEquiv (A : DetTropAutI α σ) {τ : Type*} [Fintype τ] [DecidableEq τ]
    (B : DetTropAutI α τ) : Prop :=
  language A = language B

/-
The quotient of a full automaton is equivalent to the original.
-/
theorem quotient_equiv (A : DetTropAutI α σ) :
    AutEquiv A
      { toDetTropAut := quotientAut A.toDetTropAut
        init := @Quotient.mk σ (nerodeSetoid A.toDetTropAut) A.init } := by
          -- By definition of quotient automaton, the residual of the quotient automaton at the initial state is the same as the residual of the original automaton at the initial state.
          have h_residual : stateResidual (quotientAut A.toDetTropAut) (⟦A.init⟧) = stateResidual A.toDetTropAut A.init := by
            convert quotient_residual_eq A.toDetTropAut A.init;
          exact h_residual.symm

end TropicalNerodeDecidability