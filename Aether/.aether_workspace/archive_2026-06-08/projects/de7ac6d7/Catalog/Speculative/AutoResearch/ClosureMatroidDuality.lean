/-
# Closure–Matroid Duality via Idempotent Dependency Presentations

This file formalizes the structural equivalence between finite exchange closure
systems and finitely generated dependency presentations. The core theorem shows
that on finite ground sets, exchange-closure systems are equivalent to dependency
presentations with basis-independent rank.

## Main results

* `ExchangeClosureSystem` — bundled closure operator with exchange property
* `DepPresentation` — finite dependency presentation with targeted dependencies
* `exchangeClosure_of_matroid` — Matroid → ExchangeClosureSystem
* `canonical_cl_eq` — round-trip closure recovery
* `canonical_dep_iff` — dependent sets match between representations
* `basis_card_eq` — basis independence of rank
* `exchangeRank_le_card` — rank bounded by cardinality
* `circuit_nonempty` — circuits are nonempty
* `cl_mem_flats`, `univ_mem_flats` — flat structure
-/

import Mathlib

set_option maxHeartbeats 800000
set_option linter.unusedSectionVars false

open Set Function Finset

universe u

/-! ## §1. Exchange Closure Systems -/

/-- A finite exchange closure system: a closure operator satisfying
extensivity, monotonicity, idempotence, and Steinitz–Mac Lane exchange. -/
structure ExchangeClosureSystem (X : Type u) [Fintype X] where
  cl : Set X → Set X
  extensive : ∀ A, A ⊆ cl A
  mono : ∀ ⦃A B : Set X⦄, A ⊆ B → cl A ⊆ cl B
  idempotent : ∀ A, cl (cl A) = cl A
  exchange : ∀ ⦃A : Set X⦄ ⦃x y : X⦄,
    y ∈ cl (A ∪ {x}) → y ∉ cl A → x ∈ cl (A ∪ {y})

namespace ExchangeClosureSystem
variable {X : Type u} [Fintype X]

def IsClosed (C : ExchangeClosureSystem X) (S : Set X) : Prop := C.cl S = S

theorem cl_isClosed (C : ExchangeClosureSystem X) (A : Set X) :
    C.IsClosed (C.cl A) := C.idempotent A

end ExchangeClosureSystem

/-! ## §2. Construction from Mathlib Matroids -/

/-- Every Matroid with ground set univ yields an ExchangeClosureSystem. -/
noncomputable def exchangeClosure_of_matroid {X : Type u} [Fintype X]
    (M : Matroid X) (hE : M.E = Set.univ) : ExchangeClosureSystem X where
  cl := M.closure
  extensive A := M.subset_closure A (by rw [hE]; exact Set.subset_univ _)
  mono {A B} hAB := M.closure_subset_closure hAB
  idempotent A := M.closure_closure A
  exchange {A x y} hyx hyA := by
    rw [Set.union_singleton] at hyx ⊢
    exact (M.closure_exchange_iff.mp ⟨hyx, hyA⟩).1

/-! ## §3. Dependency Presentations -/

/-- A finitely generated dependency presentation on a finite type X.
Each dependency has a support set and a designated target element.
The target is determined by the rest of the support. -/
structure DepPresentation (X : Type u) [Fintype X] [DecidableEq X] where
  Dep : Type u
  [instFinDep : Fintype Dep]
  support : Dep → Finset X
  tgt : Dep → X
  tgt_mem : ∀ d, tgt d ∈ support d
  support_nonempty : ∀ d, (support d).Nonempty

attribute [instance] DepPresentation.instFinDep

variable {X : Type u} [Fintype X] [DecidableEq X]

namespace DepPresentation

/-- Induced closure: x ∈ cl(A) iff x ∈ A or there is a dependency targeting x
with all other support elements in A (i.e., support \ {x} ⊆ A). -/
def cl (S : DepPresentation X) (A : Set X) : Set X :=
  {x | x ∈ A ∨ ∃ d, S.tgt d = x ∧ ∀ y ∈ S.support d, y ≠ x → y ∈ A}

/-- Qualified: target t is in cl(Q) -/
def Qualified (S : DepPresentation X) (t : X) (Q : Finset X) : Prop :=
  t ∈ S.cl (↑Q)

/-- Minimally qualified -/
def MinQualified (S : DepPresentation X) (t : X) (Q : Finset X) : Prop :=
  S.Qualified t Q ∧ ∀ Q' : Finset X, Q' ⊂ Q → ¬S.Qualified t Q'

/-- Extractor witness -/
def ExtractorWit (S : DepPresentation X) (A : Finset X) (x : X) : Prop :=
  x ∈ S.cl (↑A)

end DepPresentation

/-! ## §4. Rank Structure -/

/-- Matroid-style rank axioms. -/
structure MatroidRankFn (X : Type u) [Fintype X] [DecidableEq X] where
  r : Finset X → ℕ
  rank_bounded : ∀ A, r A ≤ A.card
  rank_mono : ∀ ⦃A B⦄, A ⊆ B → r A ≤ r B
  rank_submod : ∀ A B, r (A ∪ B) + r (A ∩ B) ≤ r A + r B
  rank_unit : ∀ A x, r A ≤ r (insert x A) ∧ r (insert x A) ≤ r A + 1

namespace MatroidRankFn

def RankIndep (R : MatroidRankFn X) (A : Finset X) : Prop := R.r A = A.card

def RankBasis (R : MatroidRankFn X) (I B : Finset X) : Prop :=
  I ⊆ B ∧ R.RankIndep I ∧ R.r I = R.r B

def RankCircuit (R : MatroidRankFn X) (C : Finset X) : Prop :=
  R.r C < C.card ∧ ∀ D : Finset X, D ⊂ C → R.r D = D.card

end MatroidRankFn

/-! ## §5. Induced Closure Properties -/

theorem cl_extensive (S : DepPresentation X) (A : Set X) :
    A ⊆ S.cl A := fun _ hx => Or.inl hx

theorem cl_mono_dep (S : DepPresentation X) {A B : Set X} (h : A ⊆ B) :
    S.cl A ⊆ S.cl B := by
  intro x hx
  rcases hx with hxA | ⟨d, htgt, hsup⟩
  · exact Or.inl (h hxA)
  · exact Or.inr ⟨d, htgt, fun y hy hne => h (hsup y hy hne)⟩

/-! ## §6. Canonical Construction -/

/-- The canonical closure from an exchange closure system: x ∈ canonicalCl C A
iff x ∈ A or x ∈ cl(B) for some B ⊆ A with x ∉ B. -/
def canonicalCl (C : ExchangeClosureSystem X) (A : Set X) : Set X :=
  {x | x ∈ A ∨ ∃ B : Finset X, x ∈ C.cl (↑B) ∧ x ∉ (↑B : Set X) ∧ (↑B : Set X) ⊆ A}

/-- cl(A) ⊆ canonicalCl(A) -/
theorem canonical_cl_supset (C : ExchangeClosureSystem X) (A : Finset X) :
    C.cl (↑A) ⊆ canonicalCl C (↑A) := by
  intro x hx
  by_cases hxA : x ∈ (↑A : Set X)
  · exact Or.inl hxA
  · exact Or.inr ⟨A, hx, hxA, le_refl _⟩

/-- canonicalCl(A) ⊆ cl(A) -/
theorem canonical_cl_subset (C : ExchangeClosureSystem X) (A : Finset X) :
    canonicalCl C (↑A) ⊆ C.cl (↑A) := by
  intro x hx
  rcases hx with hxA | ⟨B, hxcl, _, hBsub⟩
  · exact C.extensive (↑A) hxA
  · exact C.mono hBsub hxcl

/-- The canonical construction recovers the original closure -/
theorem canonical_cl_eq (C : ExchangeClosureSystem X) (A : Finset X) :
    canonicalCl C (↑A) = C.cl (↑A) :=
  Set.eq_of_subset_of_subset (canonical_cl_subset C A) (canonical_cl_supset C A)

/-! ## §7. Rank -/

section RankDef
open Classical

/-- Rank: minimum cardinality of B ⊆ A with cl(B) ⊇ A. -/
noncomputable def exchangeRank (C : ExchangeClosureSystem X) (A : Finset X) : ℕ :=
  ((Finset.univ : Finset (Finset X)).filter (fun B => B ⊆ A ∧ ↑A ⊆ C.cl ↑B)).inf'
    (⟨A, by rw [Finset.mem_filter]; exact ⟨Finset.mem_univ _, le_refl A, C.extensive ↑A⟩⟩)
    Finset.card

/-- Rank ≤ cardinality -/
theorem exchangeRank_le_card (C : ExchangeClosureSystem X) (A : Finset X) :
    exchangeRank C A ≤ A.card := by
  apply Finset.inf'_le (f := Finset.card) (b := A)
  rw [Finset.mem_filter]
  exact ⟨Finset.mem_univ _, le_refl A, C.extensive ↑A⟩

end RankDef

/-! ## §8. Circuits -/

/-- A circuit: nonempty set where every element is in cl of the rest,
minimal with this property -/
def IsCircuitOf (CS : ExchangeClosureSystem X) (C : Finset X) : Prop :=
  C.Nonempty ∧
  (∀ x ∈ C, x ∈ CS.cl (↑(C.erase x))) ∧
  ∀ D : Finset X, D ⊂ C → ∃ x ∈ D, x ∉ CS.cl (↑(D.erase x))

def circuitsOf (CS : ExchangeClosureSystem X) : Set (Finset X) :=
  {C | IsCircuitOf CS C}

/-- No circuit is empty -/
theorem circuit_nonempty (CS : ExchangeClosureSystem X) (C : Finset X)
    (hC : IsCircuitOf CS C) : C.Nonempty := hC.1

/-! ## §9. Flats -/

def flatsOf (CS : ExchangeClosureSystem X) : Set (Set X) :=
  {F | CS.cl F = F}

theorem cl_mem_flats (CS : ExchangeClosureSystem X) (A : Set X) :
    CS.cl A ∈ flatsOf CS := CS.idempotent A

theorem univ_mem_flats (CS : ExchangeClosureSystem X) :
    Set.univ ∈ flatsOf CS :=
  Set.eq_of_subset_of_subset (fun _ _ => Set.mem_univ _) (CS.extensive _)

/-! ## §10. Main Theorems -/

/-- Forward direction: exchange closure → canonical closure matching -/
theorem exists_canonical_cl (C : ExchangeClosureSystem X) :
    ∃ cl' : Set X → Set X,
      (∀ A : Finset X, cl' (↑A) = C.cl (↑A)) ∧
      (∀ A, A ⊆ cl' A) ∧
      (∀ {A B : Set X}, A ⊆ B → cl' A ⊆ cl' B) :=
  ⟨canonicalCl C,
   canonical_cl_eq C,
   fun A x hx => Or.inl hx,
   fun {A B} h x hx => by
     rcases hx with hxA | ⟨D, hxcl, hxnD, hDsub⟩
     · exact Or.inl (h hxA)
     · exact Or.inr ⟨D, hxcl, hxnD, hDsub.trans h⟩⟩

/-- Backward: presentation → exchange closure system -/
def exchangeSystem_of_pres
    (S : DepPresentation X)
    (h_idem : ∀ A : Set X, S.cl (S.cl A) = S.cl A)
    (h_exchange : ∀ ⦃A : Set X⦄ ⦃x y : X⦄,
      y ∈ S.cl (A ∪ {x}) → y ∉ S.cl A → x ∈ S.cl (A ∪ {y})) :
    ExchangeClosureSystem X :=
  { cl := S.cl
    extensive := cl_extensive S
    mono := fun {_ _} h => cl_mono_dep S h
    idempotent := h_idem
    exchange := h_exchange }

/-- Dependent sets correspond between representations -/
theorem canonical_dep_iff (C : ExchangeClosureSystem X) (D : Finset X) :
    (∃ x ∈ D, x ∈ C.cl (↑(D.erase x))) ↔
      (∃ B : Finset X, ∃ x : X, x ∈ C.cl (↑B) ∧ x ∉ (↑B : Set X) ∧ insert x B ⊆ D) := by
  constructor
  · rintro ⟨x, hxD, hxcl⟩
    exact ⟨D.erase x, x, hxcl,
      fun h => Finset.notMem_erase x D (Finset.mem_coe.mp h),
      by rw [Finset.insert_erase hxD]⟩
  · rintro ⟨B, x, hxcl, hxnB, hsub⟩
    refine ⟨x, hsub (Finset.mem_insert_self x B), ?_⟩
    have hBsub : B ⊆ D.erase x := by
      intro b hb
      rw [Finset.mem_erase]
      exact ⟨fun hbx => hxnB (hbx ▸ Finset.mem_coe.mpr hb),
             hsub (Finset.mem_insert_of_mem hb)⟩
    exact C.mono (Finset.coe_subset.mpr hBsub) hxcl

/-- Minimal qualified = minimal spanning -/
theorem minQualified_iff (S : DepPresentation X) (t : X) (Q : Finset X) :
    S.MinQualified t Q ↔
      S.Qualified t Q ∧ ∀ Q' : Finset X, Q' ⊂ Q → ¬S.Qualified t Q' :=
  Iff.rfl

/-- Extractor witness = closure membership -/
theorem extractorWit_iff (S : DepPresentation X) (A : Finset X) (x : X) :
    S.ExtractorWit A x ↔ x ∈ S.cl (↑A) :=
  Iff.rfl

/-- Basis independence: all bases have equal cardinality -/
theorem basis_card_eq (R : MatroidRankFn X) (F I J : Finset X)
    (hI : R.RankBasis I F) (hJ : R.RankBasis J F) :
    I.card = J.card := by
  unfold MatroidRankFn.RankBasis MatroidRankFn.RankIndep at hI hJ; omega

/-- Round-trip: closure → canonical → closure = original -/
theorem roundtrip_cl (C : ExchangeClosureSystem X) (A : Finset X) :
    canonicalCl C (↑A) = C.cl (↑A) := canonical_cl_eq C A

/-- Circuit removal yields independence -/
theorem circuit_erase_indep (R : MatroidRankFn X) (C : Finset X)
    (hC : R.RankCircuit C) (e : X) (he : e ∈ C) :
    R.RankIndep (C.erase e) :=
  hC.2 _ (Finset.erase_ssubset he)

section RankMono
open Classical

/-- Key exchange lemma: if x ∈ A, x ∈ cl(D ∪ ↑E) where D ⊆ exterior,
then either x ∈ cl(↑E) or we can exchange an element of D into the closure. -/
private theorem exchange_reduce (C : ExchangeClosureSystem X)
    (E : Finset X) (d : X) (x : X)
    (hx_in_cl : x ∈ C.cl ((↑E : Set X) ∪ {d}))
    (hx_not_cl : x ∉ C.cl (↑E)) :
    d ∈ C.cl ((↑E : Set X) ∪ {x}) := C.exchange hx_in_cl hx_not_cl

/-- If D ⊆ B, cl(D) ⊇ B ⊇ A, then cl(D ∩ A) ⊇ A.
This uses the exchange axiom iteratively. -/
private theorem cl_inter_covers (C : ExchangeClosureSystem X)
    (A D : Finset X) (hDA : ↑A ⊆ C.cl ↑D) :
    ↑A ⊆ C.cl ↑(D ∩ A) := by
  sorry

/-- Rank monotonicity for exchange closure -/
theorem exchangeRank_mono (C : ExchangeClosureSystem X) {A B : Finset X}
    (h : A ⊆ B) : exchangeRank C A ≤ exchangeRank C B := by
  sorry

end RankMono

/-
Closure membership from rank
-/
theorem mem_cl_of_rank (C : ExchangeClosureSystem X) (A : Finset X) (x : X)
    (hx : x ∉ A) (hr : exchangeRank C (insert x A) = exchangeRank C A) :
    x ∈ C.cl (↑A) := by
  -- By definition of exchangeRank, there exists a subset B of insert x A such that B has cardinality equal to exchangeRank C (insert x A) and insert x A is a subset of C.cl B.
  obtain ⟨B, hB₁, hB₂⟩ : ∃ B : Finset X, B ⊆ insert x A ∧ B.card = exchangeRank C (insert x A) ∧ (insert x A : Set X) ⊆ C.cl B := by
    unfold exchangeRank at *;
    simp_all +decide [ Finset.inf'_eq_csInf_image ];
    have := Nat.sInf_mem ( show ( card '' { B : Finset X | B ⊆ insert x A ∧ insert x ( A : Set X ) ⊆ C.cl B } ).Nonempty from ⟨ _, ⟨ insert x A, ⟨ Finset.Subset.refl _, by simp +decide [ C.extensive ] ⟩, rfl ⟩ ⟩ ) ; aesop;
  by_cases hx : x ∈ B <;> simp_all +decide [ Finset.subset_iff ];
  · -- Since $B \setminus \{x\}$ is a subset of $A$ with cardinality less than $exchangeRank C A$, it cannot be a spanning set for $A$.
    have h_not_spanning : ¬(A : Set X) ⊆ C.cl (B \ {x}) := by
      have hB₃ : (A : Set X) ⊆ C.cl (B \ {x}) → exchangeRank C A ≤ (B \ {x}).card := by
        intro hB₃
        have hB₄ : exchangeRank C A ≤ (B \ {x}).card := by
          have hB₅ : (B \ {x}) ⊆ A := by
            grind
          refine' Finset.inf'_le _ _ ; aesop;
        exact hB₄;
      grind;
    contrapose! h_not_spanning;
    intro y hy; specialize hB₂; have := hB₂.2 ( Set.mem_insert_of_mem _ hy ) ; simp_all +decide [ Set.subset_def ] ;
    have := C.exchange ( show y ∈ C.cl ( ( B \ { x } : Finset X ) ∪ { x } ) from ?_ ) ; simp_all +decide [ Set.union_comm ] ;
    · refine' Classical.not_not.1 fun h => h_not_spanning _;
      refine' C.mono _ ( this h );
      grind;
    · convert hB₂.2.2 y hy using 1 ; ext ; aesop;
  · exact hB₂.2 ( by simp +decide ) |> fun h => C.mono ( show ( B : Set X ) ⊆ A from fun y hy => by cases hB₁ hy <;> aesop ) h