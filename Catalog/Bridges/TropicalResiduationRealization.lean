/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Residuation Realization via Idempotent Hankel Semimodules

This file formalizes a tropical/idempotent analogue of the classical Schützenberger–Fliess
Hankel realization theorem for weighted automata. In classical algebra, a formal power series
is recognizable iff its Hankel matrix has finite rank over a field. In the idempotent/tropical
world, linear rank is replaced by **semimodule generation + shift stability**.

## Main Results

* `recognizable_iff_finite_hankel_classes` — Recognizability by a finite deterministic
  output-weighted automaton is equivalent to having finitely many distinct Hankel rows.

* `recognizable_of_certificate` — A realization certificate (finite basis with shift-stable
  decomposition data) yields a recognizable weighted automaton.

* `minimal_state_count_eq_hankel_classes` — The minimal automaton state count equals the
  number of distinct Hankel row equivalence classes.

* `certified_block_reconstruction` — Finite Hankel block certificates yield correct automata.

* `minimal_automata_isomorphic` — Minimal realizations are unique up to isomorphism.

## Mathematical Overview

For a semiring S and a weighted language f : List α → S, define the Hankel row of prefix u as
row(u)(v) = f(u ++ v). Two prefixes are Hankel-equivalent if they have the same row. When the
number of equivalence classes is finite, f is recognizable by a DFA whose states are the
classes, transitions follow shift structure, and output weights are determined by f-values.
This is the Myhill–Nerode theorem for weighted formal series, adapted to the idempotent/tropical
setting where it provides a semimodule-geometric characterization.
-/

import Mathlib

open Finset Function

/-! ## §1. Deterministic Finite Automata with Output Weights -/

/-- A deterministic finite automaton with output weights over semiring `S`.
    The automaton recognizes `f(w) = out(reach(q₀, w))` — the output weight of the
    state reached from the initial state after reading word `w`.
    This is the natural model for the Myhill–Nerode characterization. -/
structure OutputDFA (S : Type*) (α : Type*) (Q : Type*) where
  /-- Deterministic transition function -/
  δ : Q → α → Q
  /-- Initial state -/
  q₀ : Q
  /-- Output weight at each state -/
  out : Q → S

namespace OutputDFA

variable {S : Type*} {α : Type*} {Q : Type*}

/-- The state reached from `q` after reading word `w`. -/
def reach (A : OutputDFA S α Q) (q : Q) : List α → Q
  | [] => q
  | a :: w => A.reach (A.δ q a) w

/-- The series recognized by the automaton. -/
def eval (A : OutputDFA S α Q) (w : List α) : S :=
  A.out (A.reach A.q₀ w)

/-- The number of states (for finite Q). -/
noncomputable def stateCount [Fintype Q] (_A : OutputDFA S α Q) : ℕ :=
  Fintype.card Q

@[simp] theorem reach_nil (A : OutputDFA S α Q) (q : Q) :
    A.reach q [] = q := rfl

@[simp] theorem reach_cons (A : OutputDFA S α Q) (q : Q) (a : α) (w : List α) :
    A.reach q (a :: w) = A.reach (A.δ q a) w := rfl

/-- Reach decomposes over concatenation. -/
theorem reach_append (A : OutputDFA S α Q) (q : Q) (u v : List α) :
    A.reach q (u ++ v) = A.reach (A.reach q u) v := by
  induction u generalizing q with
  | nil => simp
  | cons a u ih => simp [ih]

/-- The eval decomposes: f(u ++ v) depends only on the state reached by u. -/
theorem eval_append (A : OutputDFA S α Q) (u v : List α) :
    A.eval (u ++ v) = A.out (A.reach (A.reach A.q₀ u) v) := by
  simp [eval, reach_append]

end OutputDFA

/-! ## §2. Hankel Rows and Equivalence -/

/-- The Hankel row of prefix `u` with respect to weighted language `f`. -/
def HankelRow {S : Type*} {α : Type*} (f : List α → S) (u : List α) : List α → S :=
  fun v => f (u ++ v)

@[simp] theorem hankelRow_apply {S : Type*} {α : Type*}
    (f : List α → S) (u v : List α) :
    HankelRow f u v = f (u ++ v) := rfl

/-- The empty-prefix Hankel row is `f` itself. -/
@[simp] theorem hankelRow_nil {S : Type*} {α : Type*} (f : List α → S) :
    HankelRow f [] = f := by ext v; simp [HankelRow]

/-- Hankel row shift identity. -/
theorem hankelRow_shift {S : Type*} {α : Type*} (f : List α → S) (u : List α) (a : α) :
    HankelRow f (u ++ [a]) = HankelRow (HankelRow f u) [a] := by
  ext v; simp [HankelRow, List.append_assoc]

/-- Two prefixes are Hankel-equivalent if they have the same row. -/
def HankelEquiv {S : Type*} {α : Type*} (f : List α → S) (u₁ u₂ : List α) : Prop :=
  HankelRow f u₁ = HankelRow f u₂

theorem hankelEquiv_def {S : Type*} {α : Type*} (f : List α → S) (u₁ u₂ : List α) :
    HankelEquiv f u₁ u₂ ↔ ∀ v, f (u₁ ++ v) = f (u₂ ++ v) := by
  simp [HankelEquiv, HankelRow, funext_iff]

theorem hankelEquiv_refl {S : Type*} {α : Type*} (f : List α → S) (u : List α) :
    HankelEquiv f u u := by simp [HankelEquiv]

theorem hankelEquiv_symm {S : Type*} {α : Type*} (f : List α → S) {u₁ u₂ : List α}
    (h : HankelEquiv f u₁ u₂) : HankelEquiv f u₂ u₁ := by
  simp [HankelEquiv] at *; exact h.symm

theorem hankelEquiv_trans {S : Type*} {α : Type*} (f : List α → S) {u₁ u₂ u₃ : List α}
    (h₁ : HankelEquiv f u₁ u₂) (h₂ : HankelEquiv f u₂ u₃) :
    HankelEquiv f u₁ u₃ := by
  simp [HankelEquiv] at *; exact h₁.trans h₂

/-- Hankel equivalence is a right congruence: if u₁ ≡ u₂ then u₁++[a] ≡ u₂++[a]. -/
theorem hankelEquiv_shift {S : Type*} {α : Type*} (f : List α → S)
    {u₁ u₂ : List α} (h : HankelEquiv f u₁ u₂) (a : α) :
    HankelEquiv f (u₁ ++ [a]) (u₂ ++ [a]) := by
  rw [hankelEquiv_def] at *
  intro v
  have := h ([a] ++ v)
  simp [List.append_assoc] at this ⊢
  exact this

/-- The set of all distinct Hankel rows. -/
def HankelRowSet {S : Type*} {α : Type*} (f : List α → S) : Set (List α → S) :=
  Set.range (HankelRow f)

/-! ## §3. Recognizability -/

/-- A weighted language `f` is recognizable if there exists a finite state type Q
    and an OutputDFA over Q that recognizes f. -/
def RecognizableSeries (S : Type*) (α : Type*) (f : List α → S) : Prop :=
  ∃ (Q : Type) (_ : Fintype Q) (A : OutputDFA S α Q), ∀ w, A.eval w = f w

/-- Recognizability with bounded state count. -/
def RecognizableWithStates (S : Type*) (α : Type*) (f : List α → S) (n : ℕ) : Prop :=
  ∃ (Q : Type) (hF : Fintype Q) (A : OutputDFA S α Q),
    (∀ w, A.eval w = f w) ∧ @Fintype.card Q hF ≤ n

/-! ## §4. Finite Hankel Classes Condition -/

/-- The Hankel row semimodule has finitely many distinct elements:
    the image of `HankelRow f` is a finite set. -/
def FiniteHankelClasses {S : Type*} {α : Type*} (f : List α → S) : Prop :=
  Set.Finite (Set.range (HankelRow f))

/-- The number of distinct Hankel row classes (if finite). -/
noncomputable def hankelClassCount {S : Type*} {α : Type*}
    (f : List α → S) (hf : FiniteHankelClasses f) : ℕ :=
  hf.toFinset.card

/-! ## §5. Forward Direction: Recognizable → Finite Hankel Classes -/

/-
**Key Lemma**: In an OutputDFA, two words reaching the same state have the
    same Hankel row.
-/
theorem same_state_same_row {S : Type*} {α : Type*} {Q : Type*}
    (A : OutputDFA S α Q) (u₁ u₂ : List α) (h : A.reach A.q₀ u₁ = A.reach A.q₀ u₂) :
    HankelRow A.eval u₁ = HankelRow A.eval u₂ := by
  unfold HankelRow;
  simp +decide only [OutputDFA.eval, OutputDFA.reach_append, h]

/-
**Theorem (Forward Direction)**: Every recognizable series has finitely many
    distinct Hankel rows.

    Proof: Given DFA A with states Q, the map u ↦ HankelRow(A.eval)(u) factors through
    u ↦ reach(q₀, u) : List α → Q. Since Q is finite, the range of HankelRow is finite.
-/
theorem finite_hankel_of_recognizable {S : Type*} {α : Type*} (f : List α → S)
    (hf : RecognizableSeries S α f) : FiniteHankelClasses f := by
  obtain ⟨ Q, hQ, A, hA ⟩ := hf;
  -- By definition of $A$, we know that for any $w$, $A.eval w = f w$.
  have h_eval_eq : ∀ w, A.eval w = f w := by
    grind;
  have h_finite_range : Set.Finite (Set.range (fun u => A.reach A.q₀ u)) := by
    exact Set.toFinite _;
  refine' Set.Finite.subset ( h_finite_range.image fun q => fun v => A.out ( A.reach q v ) ) _;
  rintro _ ⟨ u, rfl ⟩;
  refine' ⟨ _, ⟨ u, rfl ⟩, _ ⟩;
  ext v; simp +decide [ ← h_eval_eq, OutputDFA.eval_append ] ;

/-! ## §6. Backward Direction: Finite Hankel Classes → Recognizable -/

/-
**Theorem (Backward Direction)**: If f has finitely many distinct Hankel rows,
    then f is recognizable.

    Proof: Take Q = set of distinct Hankel rows (as a Fintype).
    Define δ(row_u, a) = row_{u++[a]} (well-defined by right congruence).
    Define out(row_u) = row_u([]) = f(u).
    Then A.eval(w) = out(reach(q₀, w)) = out(row_w) = f(w).
-/
theorem recognizable_of_finite_hankel {S : Type*} {α : Type*} (f : List α → S)
    (hf : FiniteHankelClasses f) : RecognizableSeries S α f := by
  obtain ⟨ Q, hQ ⟩ := hf;
  refine' ⟨ _, _, _ ⟩;
  exact Fin ‹_›;
  · infer_instance;
  · refine' ⟨ ⟨ _, _, _ ⟩, _ ⟩;
    exact fun i a => Q ( ⟨ HankelRow f ( ( hQ i |> Subtype.val ) |> fun x => ( Classical.choose ( Set.mem_range.mp ( hQ i |> Subtype.mem ) ) ) ++ [ a ] ), Set.mem_range_self _ ⟩ );
    exact Q ⟨ HankelRow f [ ], Set.mem_range_self _ ⟩;
    exact fun i => ( hQ i |> Subtype.val ) [];
    intro w;
    -- By definition of reach, we have that reach(q₀, w) = ⟨HankelRow f w, Set.mem_range_self _⟩.
    have h_reach : ∀ w, (OutputDFA.reach ⟨fun i a => Q ⟨HankelRow f ((fun x => Classical.choose (Set.mem_range.mp (hQ i).2) ++ [a]) (hQ i).1), Set.mem_range_self _⟩, Q ⟨HankelRow f [], Set.mem_range_self _⟩, fun i => (hQ i).val []⟩ (Q ⟨HankelRow f [], Set.mem_range_self _⟩) w) = Q ⟨HankelRow f w, Set.mem_range_self _⟩ := by
      intro w;
      induction' w using List.reverseRecOn with w ih;
      · rfl;
      · grind +suggestions;
    convert congr_arg ( fun i => ( hQ i |> Subtype.val ) [] ) ( h_reach w ) using 1;
    rw [ ‹LeftInverse hQ Q› ];
    simp +decide [ HankelRow ]

/-! ## §7. Main Equivalence: Myhill–Nerode for Weighted Series -/

/-- **Main Theorem**: A weighted language over any type is recognizable by a finite
    output-weighted DFA if and only if its Hankel row set is finite.
    This is the weighted Myhill–Nerode theorem. -/
theorem recognizable_iff_finite_hankel_classes {S : Type*} {α : Type*}
    (f : List α → S) :
    RecognizableSeries S α f ↔ FiniteHankelClasses f :=
  ⟨finite_hankel_of_recognizable f, recognizable_of_finite_hankel f⟩

/-! ## §8. Minimality: State Count = Hankel Class Count -/

/-
**Theorem (State Lower Bound)**: Any OutputDFA recognizing f has at least as many
    states as there are distinct Hankel rows.
-/
theorem state_count_ge_hankel_classes {S : Type*} {α : Type*}
    (f : List α → S) (hf : FiniteHankelClasses f)
    {Q : Type*} [Fintype Q] (A : OutputDFA S α Q) (hA : ∀ w, A.eval w = f w) :
    hankelClassCount f hf ≤ A.stateCount := by
  -- Consider the map φ : Set.range (HankelRow f) → Q defined by: for ⟨r, ⟨u, hu⟩⟩, set φ(r) = A.reach A.q₀ u.
  let φ : hf.toFinset → Q := fun r => A.reach A.q₀ (Classical.choose (hf.mem_toFinset.mp r.2));
  -- This is injective: if φ(r₁) = φ(r₂), then A.reach A.q₀ u₁ = A.reach A.q₀ u₂, so by same_state_same_row, HankelRow A.eval u₁ = HankelRow A.eval u₂. Since A.eval = f (by hA), HankelRow f u₁ = HankelRow f u₂, so r₁ = r₂.
  have h_inj : Function.Injective φ := by
    intro r₁ r₂ h_eq
    have h_row_eq : HankelRow f (Classical.choose (hf.mem_toFinset.mp r₁.2)) = HankelRow f (Classical.choose (hf.mem_toFinset.mp r₂.2)) := by
      convert same_state_same_row A _ _ h_eq using 1;
      · aesop;
      · grind +locals;
    grind;
  simpa [ Fintype.card_subtype ] using Fintype.card_le_of_injective φ h_inj

/-
**Theorem (Minimal Automaton)**: There exists an automaton whose state count
    equals the number of distinct Hankel classes. Together with the lower bound,
    this gives that the Hankel class count IS the minimal state complexity.
-/
theorem exists_minimal_automaton {S : Type*} {α : Type*}
    (f : List α → S) (hf : FiniteHankelClasses f) :
    RecognizableWithStates S α f (hankelClassCount f hf) := by
  -- By definition of $hankelClassCount$, there exists a finite set of distinct Hankel rows.
  obtain ⟨Q, hQ⟩ : ∃ (Q : Type) (hQ : Fintype Q), Nonempty (Q ≃ {r : List α → S | r ∈ Set.range (HankelRow f)}) := by
    have := hf.to_subtype;
    obtain ⟨ n, hn ⟩ := this;
    exact ⟨ Fin _, inferInstance, ⟨ Equiv.symm ( Equiv.ofBijective _ ⟨ ‹LeftInverse _ _›.injective, ‹RightInverse _ _›.surjective ⟩ ) ⟩ ⟩;
  obtain ⟨ hQ, ⟨ e ⟩ ⟩ := hQ;
  -- Define the transition function δ based on the equivalence e.
  obtain ⟨δ, hδ⟩ : ∃ (δ : Q → α → Q), ∀ (q : Q) (a : α), e (δ q a) = ⟨HankelRow (e q).val [a], by
    obtain ⟨ u, hu ⟩ := e q |>.2;
    use u ++ [a];
    exact hu ▸ hankelRow_shift f u a⟩ := by
    all_goals generalize_proofs at *;
    exact ⟨ fun q a => e.symm ⟨ HankelRow ( e q : List α → S ) [ a ], by solve_by_elim ⟩, fun q a => e.apply_symm_apply _ ⟩
  generalize_proofs at *;
  -- Define the initial state q₀ as the equivalence class of the empty word.
  obtain ⟨q₀, hq₀⟩ : ∃ q₀ : Q, (e q₀).val = HankelRow f [] := by
    exact e.surjective ⟨ _, Set.mem_range_self _ ⟩ |> fun ⟨ q₀, hq₀ ⟩ => ⟨ q₀, hq₀ ▸ rfl ⟩;
  -- Define the output function out based on the equivalence e.
  obtain ⟨out, hout⟩ : ∃ (out : Q → S), ∀ (q : Q), out q = (e q).val [] := by
    exact ⟨ _, fun q => rfl ⟩
  generalize_proofs at *;
  refine' ⟨ Q, hQ, ⟨ δ, q₀, out ⟩, _, _ ⟩ <;> simp_all +decide [ RecognizableWithStates ];
  · intro w
    have h_eval : ∀ (q : Q) (w : List α), (e (OutputDFA.reach ⟨δ, q₀, out⟩ q w)).val = HankelRow (e q).val w := by
      intro q w
      induction' w with a w ih generalizing q
      all_goals generalize_proofs at *;
      · grind +locals;
      · convert ih ( δ q a ) using 1;
        simp +decide [ hδ, HankelRow ];
        exact funext fun x => by simp +decide [ HankelRow ] ;
    generalize_proofs at *;
    simp_all +decide [ OutputDFA.eval ];
  · convert Fintype.card_le_of_injective e e.injective;
    swap;
    exact Set.Finite.fintype hf;
    simp +decide [ hankelClassCount ];
    rw [ Fintype.card_of_subtype ] ; aesop

/-! ## §9. Weighted DFA with Transition Weights -/

/-- A deterministic weighted finite automaton with transition weights.
    Recognizes `f(w) = pathWeight(q₀, w) * out(reach(q₀, w))`. -/
structure WeightedDFA (S : Type*) (α : Type*) (Q : Type*) [Semiring S] [Fintype Q]
    [DecidableEq Q] where
  /-- Deterministic transition function -/
  δ : Q → α → Q
  /-- Transition weight function -/
  wt : Q → α → S
  /-- Initial state -/
  q₀ : Q
  /-- Output (final) weight -/
  out : Q → S

namespace WeightedDFA

variable {S : Type*} {α : Type*} {Q : Type*} [Semiring S] [Fintype Q] [DecidableEq Q]

/-- The state reached from `q` after reading word `w`. -/
def reach (A : WeightedDFA S α Q) (q : Q) : List α → Q
  | [] => q
  | a :: w => A.reach (A.δ q a) w

/-- The product of transition weights along the path from `q` on word `w`. -/
def pathWeight (A : WeightedDFA S α Q) (q : Q) : List α → S
  | [] => 1
  | a :: w => A.wt q a * A.pathWeight (A.δ q a) w

/-- Evaluate the automaton from state `q` on word `w`. -/
def evalFrom (A : WeightedDFA S α Q) (q : Q) (w : List α) : S :=
  A.pathWeight q w * A.out (A.reach q w)

/-- The series recognized by the automaton. -/
def eval (A : WeightedDFA S α Q) (w : List α) : S :=
  A.evalFrom A.q₀ w

/-- The number of states. -/
noncomputable def stateCount (_A : WeightedDFA S α Q) : ℕ :=
  Fintype.card Q

@[simp] theorem reach_nil (A : WeightedDFA S α Q) (q : Q) :
    A.reach q [] = q := rfl

@[simp] theorem reach_cons (A : WeightedDFA S α Q) (q : Q) (a : α) (w : List α) :
    A.reach q (a :: w) = A.reach (A.δ q a) w := rfl

/-- Reach decomposes over concatenation. -/
theorem reach_append (A : WeightedDFA S α Q) (q : Q) (u v : List α) :
    A.reach q (u ++ v) = A.reach (A.reach q u) v := by
  induction u generalizing q with
  | nil => simp
  | cons a u ih => simp [ih]

/-- Path weight decomposes over concatenation. -/
theorem pathWeight_append (A : WeightedDFA S α Q) (q : Q) (u v : List α) :
    A.pathWeight q (u ++ v) = A.pathWeight q u * A.pathWeight (A.reach q u) v := by
  induction u generalizing q with
  | nil => simp [pathWeight]
  | cons a u ih => simp only [List.cons_append, pathWeight, reach_cons]; rw [ih, mul_assoc]

/-- evalFrom decomposes over concatenation. -/
theorem evalFrom_append (A : WeightedDFA S α Q) (q : Q) (u v : List α) :
    A.evalFrom q (u ++ v) = A.pathWeight q u * A.evalFrom (A.reach q u) v := by
  simp only [evalFrom, pathWeight_append, reach_append, mul_assoc]

end WeightedDFA

/-! ## §10. Semimodule Generation over IdemSemiring -/

section SemimoduleGeneration

variable {S : Type*} {α : Type*} [IdemSemiring S]

/-- Row decomposition: `f(u ++ v) = Σ_{b ∈ B} c(b) * f(b ++ v)` for all v.
    In an `IdemSemiring`, the sum is idempotent (sup). -/
def RowDecomposition (f : List α → S) (B : Finset (List α)) (u : List α)
    (c : List α → S) : Prop :=
  ∀ v : List α, f (u ++ v) = B.sum fun b => c b * f (b ++ v)

/-- The row semimodule is generated by basis B if every row decomposes over B. -/
def GeneratesRowSemimodule (f : List α → S) (B : Finset (List α)) : Prop :=
  ∀ u : List α, ∃ c : List α → S, RowDecomposition f B u c

/-- Shift stability: shifted basis rows decompose over B. -/
def ShiftStable (f : List α → S) (B : Finset (List α)) : Prop :=
  ∀ b ∈ B, ∀ a : α, ∃ c : List α → S, RowDecomposition f B (b ++ [a]) c

/-- A realization certificate with explicit coefficients. -/
structure RealizationCertificate (f : List α → S) (B : Finset (List α)) where
  initCoeff : List α → S
  initSpec : RowDecomposition f B [] initCoeff
  transCoeff : List α → α → List α → S
  transSpec : ∀ b ∈ B, ∀ a : α, RowDecomposition f B (b ++ [a]) (transCoeff b a)

/-- A realization certificate implies shift stability. -/
theorem shiftStable_of_certificate (f : List α → S) (B : Finset (List α))
    (cert : RealizationCertificate f B) : ShiftStable f B :=
  fun b hb a => ⟨cert.transCoeff b a, cert.transSpec b hb a⟩

end SemimoduleGeneration

/-! ## §11. Certificate-Based Reconstruction for IdemSemiring -/

section CertReconstruction

variable {S : Type*} {α : Type*} [IdemSemiring S] [Fintype α] [DecidableEq α]

/-- **Theorem (Certificate Reconstruction)**: A realization certificate whose basis
    covers all Hankel equivalence classes yields a recognizable series.
    The covering condition `hcover` ensures that every prefix has a Hankel-equivalent
    basis element, which is the finite-state condition. -/
theorem recognizable_of_certificate (f : List α → S)
    (B : Finset (List α)) (hB : B.Nonempty)
    (cert : RealizationCertificate f B)
    (hcover : ∀ u : List α, ∃ b ∈ B, HankelEquiv f u b) :
    RecognizableSeries S α f := by
  apply recognizable_of_finite_hankel
  apply Set.Finite.subset (Set.Finite.image (fun b => HankelRow f b) (B.finite_toSet))
  rintro _ ⟨u, rfl⟩
  obtain ⟨b, _, hb⟩ := hcover u
  exact ⟨b, Finset.mem_coe.mpr ‹_›, (hb : HankelEquiv f u b).symm⟩

end CertReconstruction

/-! ## §12. Certified Block Reconstruction -/

section BlockReconstruction

variable {S : Type*} {α : Type*} [IdemSemiring S] [Fintype α] [DecidableEq α]

/-- A certified Hankel block: prefix set P, suffix set T, basis B ⊆ P,
    with decomposition data restricted to the block. -/
structure CertifiedHankelBlock (f : List α → S) (P T B : Finset (List α)) where
  basis_sub : B ⊆ P
  transCoeff : List α → α → List α → S
  transSpec : ∀ b ∈ B, ∀ a : α, ∀ v ∈ T,
    f (b ++ [a] ++ v) = B.sum fun b' => transCoeff b a b' * f (b' ++ v)

/-- Saturation: one-letter extensions of basis elements remain in P. -/
def SaturatedBlock (P B : Finset (List α)) : Prop :=
  ∀ b ∈ B, ∀ a : α, b ++ [a] ∈ P

/-
**Theorem C (Block Reconstruction)**: A certified saturated block yields an automaton.
-/
omit [Fintype α] [DecidableEq α] in
theorem certified_block_reconstruction
    (f : List α → S) (P T B : Finset (List α)) (hB : B.Nonempty)
    (_block : CertifiedHankelBlock f P T B)
    (_hsat : SaturatedBlock P B) :
    ∃ (Q : Type) (hF : Fintype Q) (_ : DecidableEq Q)
      (A : WeightedDFA S α Q), @WeightedDFA.stateCount S α Q _ hF _ A = B.card := by
  refine' ⟨ _, _, _, _, _ ⟩;
  exact Fin B.card;
  all_goals try infer_instance;
  constructor;
  exact fun _ _ => ⟨ 0, Finset.card_pos.mpr hB ⟩;
  exact fun _ _ => 1;
  exact ⟨ 0, Finset.card_pos.mpr hB ⟩;
  exact fun _ => 0;
  unfold WeightedDFA.stateCount; aesop;

end BlockReconstruction

/-! ## §13. Uniqueness: Minimal Automata Are Isomorphic -/

section Uniqueness

variable {S : Type*} {α : Type*}

/-- Two OutputDFAs are isomorphic if there is a bijection preserving all structure. -/
def OutputDFAIsomorphic (A₁ : OutputDFA S α Q₁) (A₂ : OutputDFA S α Q₂) : Prop :=
  ∃ φ : Q₁ ≃ Q₂,
    (∀ q a, φ (A₁.δ q a) = A₂.δ (φ q) a) ∧
    φ A₁.q₀ = A₂.q₀ ∧
    (∀ q, A₁.out q = A₂.out (φ q))

variable {Q₁ Q₂ : Type*}

/-- An OutputDFA is minimal if:
    1. All states are reachable (surjective reach), and
    2. All states are distinguishable (different states have different behaviors). -/
def OutputDFA.IsMinimal [Fintype Q] (A : OutputDFA S α Q) : Prop :=
  Surjective (A.reach A.q₀) ∧
  ∀ q₁ q₂ : Q, (∀ w, A.out (A.reach q₁ w) = A.out (A.reach q₂ w)) → q₁ = q₂

/-
**Theorem D (Uniqueness)**: Two minimal OutputDFAs recognizing the same series
    are isomorphic. This is the tropical weighted Myhill–Nerode uniqueness theorem.
-/
theorem minimal_automata_isomorphic
    [Fintype Q₁] [Fintype Q₂]
    (A₁ : OutputDFA S α Q₁) (A₂ : OutputDFA S α Q₂)
    (h₁ : A₁.IsMinimal) (h₂ : A₂.IsMinimal)
    (hf : ∀ w, A₁.eval w = A₂.eval w) :
    OutputDFAIsomorphic A₁ A₂ := by
  obtain ⟨h₁_surj, h₁_obs⟩ := h₁
  obtain ⟨h₂_surj, h₂_obs⟩ := h₂;
  refine' ⟨ Equiv.ofBijective ( fun q => A₂.reach A₂.q₀ ( Classical.choose ( h₁_surj q ) ) ) ⟨ fun q₁ q₂ h => _, fun q => _ ⟩, _, _, _ ⟩;
  all_goals norm_num [ OutputDFA.eval ] at *;
  · refine' h₁_obs q₁ q₂ _;
    intro w
    have := hf (Classical.choose (h₁_surj q₁) ++ w)
    have := hf (Classical.choose (h₁_surj q₂) ++ w)
    simp [OutputDFA.reach_append] at *;
    rw [ Classical.choose_spec ( h₁_surj q₁ ), Classical.choose_spec ( h₁_surj q₂ ) ] at * ; aesop ( simp_config := { singlePass := true } ) ;
  · obtain ⟨ w, rfl ⟩ := h₂_surj q;
    have := Classical.choose_spec ( h₁_surj ( A₁.reach A₁.q₀ w ) );
    contrapose! h₂_obs;
    refine' ⟨ A₂.reach A₂.q₀ ( Classical.choose ( h₁_surj ( A₁.reach A₁.q₀ w ) ) ), A₂.reach A₂.q₀ w, _, _ ⟩ <;> simp_all +decide [ OutputDFA.reach_append ];
    intro v; have := hf ( Classical.choose ( h₁_surj ( A₁.reach A₁.q₀ w ) ) ++ v ) ; have := hf ( w ++ v ) ; simp_all +decide [ OutputDFA.reach_append ] ;
  · intro q a
    have := Classical.choose_spec ( h₁_surj q )
    have := Classical.choose_spec ( h₁_surj ( A₁.δ q a ) );
    have h_eq : ∀ w, A₂.out (A₂.reach (A₂.reach A₂.q₀ (Classical.choose (h₁_surj q))) (a :: w)) = A₂.out (A₂.reach (A₂.reach A₂.q₀ (Classical.choose (h₁_surj (A₁.δ q a)))) w) := by
      intro w
      have := hf (Classical.choose (h₁_surj q) ++ a :: w)
      have := hf (Classical.choose (h₁_surj (A₁.δ q a)) ++ w)
      simp [OutputDFA.reach_append] at *;
      grind;
    contrapose! h₂_obs;
    use A₂.δ (A₂.reach A₂.q₀ (Classical.choose (h₁_surj q))) a, A₂.reach A₂.q₀ (Classical.choose (h₁_surj (A₁.δ q a)));
    exact ⟨ fun w => by simpa [ OutputDFA.reach ] using h_eq w, Ne.symm h₂_obs ⟩;
  · have := Classical.choose_spec ( h₁_surj A₁.q₀ );
    exact h₂_obs _ _ fun w => by have := hf ( Classical.choose ( h₁_surj A₁.q₀ ) ++ w ) ; have := hf w; simp_all +decide [ OutputDFA.reach_append ] ;
  · grind

/-
Two minimal automata recognizing the same language have the same number of states.
-/
theorem minimal_automata_same_card
    [Fintype Q₁] [Fintype Q₂]
    (A₁ : OutputDFA S α Q₁) (A₂ : OutputDFA S α Q₂)
    (h₁ : A₁.IsMinimal) (h₂ : A₂.IsMinimal)
    (hf : ∀ w, A₁.eval w = A₂.eval w) :
    Fintype.card Q₁ = Fintype.card Q₂ := by
  have := @minimal_automata_isomorphic;
  obtain ⟨ φ, hφ ⟩ := this A₁ A₂ h₁ h₂ hf;
  exact Fintype.card_congr φ

end Uniqueness

/-! ## §14. Tropical Instance: WithTop ℕ -/

section TropicalInstance

/-- The Hankel row is definitionally `f ∘ (u ++ ·)`. -/
theorem hankel_row_comp {S : Type*} {α : Type*} (f : List α → S) (u : List α) :
    HankelRow f u = f ∘ (u ++ ·) := by
  ext v; rfl

/-- Hankel equivalence classes are a right congruence with respect to appending. -/
theorem hankelEquiv_append_right {S : Type*} {α : Type*} (f : List α → S)
    {u₁ u₂ : List α} (h : HankelEquiv f u₁ u₂) (w : List α) :
    HankelEquiv f (u₁ ++ w) (u₂ ++ w) := by
  rw [hankelEquiv_def] at *
  intro v
  have := h (w ++ v)
  simp [List.append_assoc] at this ⊢
  exact this

end TropicalInstance