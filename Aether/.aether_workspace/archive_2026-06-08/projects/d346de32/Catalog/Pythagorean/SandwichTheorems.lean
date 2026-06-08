import Mathlib
import Pythagorean.SandwichDefs

/-!
# Theorems on Certified Sandwich Families

## Main Results

### Theorem 1: Lower Bound from Sandwich Completeness
`no_small_circuit_of_sandwichCompleteUpTo` — if a certified sandwich family is complete
against all circuits of size ≤ s, then no circuit of size ≤ s computes f.

### Theorem 2: Transport via Order Embeddings
`SandwichCompleteUpTo_pullback` — sandwich completeness transfers along order embeddings.

### Theorem 3: Finite Duality
`exists_certifiedSandwichFamily_of_finite_cover` — given a finite set of circuits none
of which computes f, there exists a sandwich family that hits all of them.

### Theorem 4: Equivalence (Finite Completeness Characterization)
`sandwichCompleteUpTo_iff_no_small_circuit` — on finite domains, sandwich completeness
up to size s is equivalent to the non-existence of a size-s circuit computing f.
-/

noncomputable section
open Classical

namespace SandwichUniversality

/-! ## Theorem 1: From Sandwich Completeness to Lower Bound -/

/-
**The Engine Theorem.** If a certified sandwich family `S` is complete against all
    monotone circuits of size ≤ `s`, then no monotone circuit of size ≤ `s` computes `f`.

    The proof proceeds by contradiction: assume a circuit `C` of size ≤ `s` computes `f`.
    By completeness, `S` hits `C`, meaning there exists a witness where `C` disagrees
    with `f`. But `C` computes `f` everywhere — contradiction.
-/
theorem no_small_circuit_of_sandwichCompleteUpTo
    {α : Type*} [Preorder α] [Fintype α]
    (f : α → Bool)
    (S : CertifiedSandwichFamily α f)
    (s : ℕ)
    (hcomplete : SandwichCompleteUpTo f S s) :
    ¬ ∃ C : MonoCircuitProfile α, C.size ≤ s ∧ ∀ x, C.eval x = f x := by
  intro ⟨ C, hs, hC ⟩;
  cases hcomplete C hs <;> simp_all +decide [ SandwichHitsCircuit ]

/-! ## Theorem 2: Transport Along Order Embeddings -/

/-
**Transport Theorem.** If `S` is a sandwich family on `β` that is complete up to
    size `s`, and `e : α ↪o β` is an order embedding with `fα = fβ ∘ e`, then the
    pullback family `S.pullback e fα` is complete up to size `s` on `α`.

    The proof constructs, for each circuit `C` on `α`, a restricted circuit on `β`
    (via composition with `e`), applies completeness of `S`, and transfers the
    disagreement witness back to `α`.
-/
theorem SandwichCompleteUpTo_pullback
    {α β : Type*} [Preorder α] [Preorder β] [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (e : α ↪o β)
    (fα : α → Bool) (fβ : β → Bool)
    (S : CertifiedSandwichFamily β fβ)
    (s : ℕ)
    (hfun : ∀ x, fα x = fβ (e x))
    (hcomp : SandwichCompleteUpTo fβ S s)
    /- We require that every witness in `S` that lies in the range of `e`
       has a preimage. This is automatic when `e` is surjective, or when
       `S` only uses elements in the range. -/
    (hrange : ∀ x ∈ S.Pos ∪ S.Neg, x ∈ Set.range e) :
    SandwichCompleteUpTo fα (S.pullback e fα hfun) s := by
  intro C hC
  obtain ⟨D, hDsize, hD⟩ : ∃ D : MonoCircuitProfile β, D.size ≤ s ∧ ∀ x, D.eval (e x) = C.eval x := by
    -- Let's choose any β-circuit D that agrees with C on the range of e.
    obtain ⟨D, hD⟩ : ∃ D : β → Bool, (∀ x, D (e x) = C.eval x) ∧ Monotone D := by
      refine' ⟨ fun y => if h : ∃ x, e x = y then C.eval ( Classical.choose h ) else if ∃ x, e x ≤ y ∧ C.eval x = true then true else false, _, _ ⟩ <;> simp +decide [ Monotone ];
      intro a b hab
      by_cases ha : ∃ x, e x = a
      by_cases hb : ∃ x, e x = b
      all_goals generalize_proofs at *;
      · have := Classical.choose_spec ha; have := Classical.choose_spec hb; simp_all +decide [ e.le_iff_le ] ;
        exact C.mono_eval ( by simpa [ * ] using e.le_iff_le.mp ( by simp [ * ] ) );
      · by_cases h : ∃ x, e x ≤ b ∧ C.eval x = true <;> simp_all +decide [ le_of_lt ];
        rw [ h _ ( by simpa [ ha.choose_spec ] using hab ) ] ; simp +decide [ hb ] ;
      · split_ifs <;> simp_all +decide [ Monotone ];
        · by_cases h : ∃ x, e x ≤ a ∧ C.eval x = true <;> simp_all +decide [ Monotone ];
          · have := Classical.choose_spec h; have := C.mono_eval ( show Classical.choose h ≤ Classical.choose ‹∃ x, e x = b› from ?_ ) ; aesop;
            exact e.le_iff_le.mp ( le_trans this.1 hab |> le_trans <| by aesop );
          · rw [ decide_eq_false ] <;> simp_all +decide [ Monotone ];
        · by_cases h : ∃ x, e x ≤ a ∧ C.eval x = true <;> simp_all +decide [ Monotone ];
          · exact decide_eq_true ( by obtain ⟨ x, hx₁, hx₂ ⟩ := h; exact ⟨ x, le_trans hx₁ hab, hx₂ ⟩ ) |> fun h => h.symm ▸ by simp +decide ;
          · simp_all +decide [ decide_eq_false ];
    exact ⟨ ⟨ s, D, hD.2 ⟩, le_rfl, hD.1 ⟩;
  specialize hcomp D hDsize;
  cases' hcomp with h h <;> simp_all +decide [ SandwichHitsCircuit, CertifiedSandwichFamily.pullback ];
  · rcases h with ⟨ x, hx₁, hx₂, hx₃ ⟩ ; rcases hrange x ( Or.inl hx₁ ) with ⟨ y, rfl ⟩ ; exact Or.inl ⟨ y, by simpa [ hfun ] using hx₁, by simpa [ hD ] using hx₂, by simpa [ hfun ] using hx₃ ⟩ ;
  · obtain ⟨ x, hx₁, hx₂, hx₃ ⟩ := h; obtain ⟨ y, rfl ⟩ := hrange x ( Or.inr hx₁ ) ; exact Or.inr ⟨ y, by simpa using hx₁, by simpa [ hD ] using hx₂, by simpa using hx₃ ⟩ ;

/-! ## Theorem 3: Finite Duality (Existence from Finite Cover) -/

/-
**Finite Duality Theorem.** Given a finite set `Circs` of monotone circuits, none
    of which computes `f`, there exists a certified sandwich family that hits every
    circuit in `Circs`.

    The proof enumerates circuits, chooses a disagreement point for each, and collects
    them into positive and negative families.
-/
theorem exists_certifiedSandwichFamily_of_finite_cover
    {α : Type*} [Preorder α] [Fintype α] [DecidableEq α]
    (f : α → Bool)
    (Circs : Finset (MonoCircuitProfile α))
    (hbad : ∀ C ∈ Circs, ∃ x, C.eval x ≠ f x) :
    ∃ S : CertifiedSandwichFamily α f,
      ∀ C ∈ Circs, SandwichHitsCircuit f S C := by
  refine' ⟨ _, _ ⟩;
  use Finset.univ.filter (fun x => f x = true), Finset.univ.filter (fun x => f x = false);
  all_goals simp +decide [ SandwichHitsCircuit ];
  grind

/-! ## Theorem 4: Equivalence (Iff Characterization) -/

/-
**Finite Completeness Characterization.** On a finite domain, the existence
    of a complete sandwich family up to size `s` is equivalent to the
    non-existence of a size-`s` circuit computing `f`.
-/
theorem sandwichCompleteUpTo_iff_no_small_circuit
    {α : Type*} [Preorder α] [Fintype α] [DecidableEq α]
    (f : α → Bool)
    (s : ℕ) :
    (∃ S : CertifiedSandwichFamily α f, SandwichCompleteUpTo f S s) ↔
    (¬ ∃ C : MonoCircuitProfile α, C.size ≤ s ∧ ∀ x, C.eval x = f x) := by
  refine ⟨ fun ⟨ S, hS ⟩ ⟨ C, hC₁, hC₂ ⟩ ↦ ?_, fun h ↦ ?_ ⟩;
  · exact no_small_circuit_of_sandwichCompleteUpTo f S s hS ⟨ C, hC₁, hC₂ ⟩;
  · refine' ⟨ ⟨ Finset.univ.filter ( fun x => f x = true ), Finset.univ.filter ( fun x => f x = false ), _, _ ⟩, _ ⟩ <;> simp +decide [ SandwichCompleteUpTo ];
    intro C hC;
    contrapose! h;
    refine' ⟨ C, hC, fun x => _ ⟩;
    cases h' : f x <;> simp_all +decide [ SandwichHitsCircuit ]

/-! ## Corollary: Minimal Sandwich Families -/

/-- A sandwich family is **minimal** if removing any element from `Pos ∪ Neg`
    breaks completeness. -/
def SandwichMinimal {α : Type*} [Preorder α] [Fintype α]
    (f : α → Bool) (S : CertifiedSandwichFamily α f) (s : ℕ) : Prop :=
  SandwichCompleteUpTo f S s ∧
  (∀ x ∈ S.Pos, ∃ C : MonoCircuitProfile α, C.size ≤ s ∧
    (∀ y ∈ S.Pos, y ≠ x → C.eval y = f y) ∧
    (∀ y ∈ S.Neg, C.eval y = f y) ∧
    C.eval x ≠ f x)

/-! ## Connection to Hypergraph Transversals -/

/-- The **circuit-refutation hypergraph**: for each input `x`, the hyperedge
    is the set of circuits that `x` refutes (disagrees with `f` on `x`). -/
def refutationHyperedge {α : Type*} [Preorder α] [Fintype α]
    (f : α → Bool) (x : α)
    (Circs : Finset (MonoCircuitProfile α)) : Finset (MonoCircuitProfile α) :=
  Circs.filter (fun C => C.eval x ≠ f x)

/-
A complete sandwich family is a **transversal** of the circuit-refutation
    hypergraph: every circuit is hit by some witness in the family.
-/
theorem sandwich_is_transversal
    {α : Type*} [Preorder α] [Fintype α] [DecidableEq α]
    (f : α → Bool)
    (S : CertifiedSandwichFamily α f)
    (Circs : Finset (MonoCircuitProfile α))
    (s : ℕ)
    (hCircs : ∀ C ∈ Circs, C.size ≤ s)
    (hcomplete : SandwichCompleteUpTo f S s) :
    ∀ C ∈ Circs,
      ∃ x ∈ S.Pos ∪ S.Neg,
        C ∈ refutationHyperedge f x Circs := by
  intro C hC;
  specialize hcomplete C (hCircs C hC);
  cases hcomplete <;> simp_all +decide [ refutationHyperedge ];
  · grind;
  · grind

end SandwichUniversality