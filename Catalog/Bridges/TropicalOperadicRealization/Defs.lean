import Mathlib

/-! # Tropical Operadic Realization Duality: Definitions

This file defines the core algebraic structures for the tropical operadic
realization duality theory. We formalize:

* **Operadic evaluation tables** — tropical cost matrices indexed by
  contexts and observables
* **Realizations** — factorizations of evaluation tables through finite state types
* **Tropical (min-plus) factorizations** — decompositions via min-plus matrix product
* **Idempotent composition semimodules** — the algebraic setting for response profiles
* **Nerode equivalence and canonical realizations** — the reduced quotient construction

## Cross-Domain Connections
- **Weighted automata**: evaluation tables = Hankel matrices of rational series
- **Control theory**: realizations = state-space models, minimality = observability
- **Tannaka reconstruction**: architecture recovered from its evaluation invariant
- **Tropical geometry**: operators are piecewise-linear, rank = tropical matrix rank
-/

noncomputable section

namespace TropicalOperadicRealization

open Finset Function

/-! ## §1. Evaluation Tables -/

/-- An operadic evaluation table maps (context, observable) pairs to integer costs.
    This is the tropical analogue of a Hankel matrix in weighted automata theory. -/
abbrev EvalTable (C O : Type) := C → O → ℤ

/-! ## §2. Realizations: Finite-State Factorizations -/

/-- A realization of an evaluation table through a finite state type.
    The state type represents the internal architecture of a tropical neural network.
    The `encode` map sends contexts to states, and `decode` extracts observables.

    In control theory, this is a state-space realization.
    In automata theory, this is a weighted automaton. -/
structure Realization (C O : Type) where
  /-- Internal state type -/
  State : Type
  /-- States form a finite type -/
  instFintype : Fintype State
  /-- State equality is decidable -/
  instDecEq : DecidableEq State
  /-- Context-to-state encoding -/
  encode : C → State
  /-- State-to-observable decoding -/
  decode : State → O → ℤ

attribute [instance] Realization.instFintype Realization.instDecEq

/-- The evaluation table realized by a realization system -/
def Realization.realized {C O : Type} (R : Realization C O) : EvalTable C O :=
  fun c o => R.decode (R.encode c) o

/-- A realization `R` realizes a table `M` if they agree on all entries -/
def Realizes {C O : Type} (R : Realization C O) (M : EvalTable C O) : Prop :=
  R.realized = M

/-- The state count of a realization -/
def Realization.stateCount {C O : Type} (R : Realization C O) : ℕ :=
  @Fintype.card R.State R.instFintype

/-- A realization is minimal if no other realization has fewer states -/
def IsMinimalRealization {C O : Type} (R : Realization C O) (M : EvalTable C O) : Prop :=
  Realizes R M ∧
  ∀ R' : Realization C O, Realizes R' M → R.stateCount ≤ R'.stateCount

/-- Two realizations are isomorphic via a bijection preserving encode/decode -/
def RealizationIso {C O : Type} (R₁ R₂ : Realization C O) : Prop :=
  ∃ (f : R₁.State → R₂.State),
    Bijective f ∧
    (∀ c, f (R₁.encode c) = R₂.encode c) ∧
    (∀ s o, R₁.decode s o = R₂.decode (f s) o)

/-! ## §3. Nerode Equivalence -/

/-- The Nerode equivalence: two contexts are equivalent iff they produce
    identical responses on all observables. -/
def NerodeEquiv {C O : Type} (M : EvalTable C O) (c₁ c₂ : C) : Prop :=
  ∀ o : O, M c₁ o = M c₂ o

/-- The Nerode equivalence reformulated as function equality -/
theorem nerodeEquiv_iff_eq {C O : Type} (M : EvalTable C O) (c₁ c₂ : C) :
    NerodeEquiv M c₁ c₂ ↔ M c₁ = M c₂ := by
  constructor
  · intro h; ext o; exact h o
  · intro h o; exact congr_fun h o

/-- The operational rank: number of distinct response profiles -/
def operationalRank {C O : Type} [Fintype C] [DecidableEq O]
    (M : EvalTable C O) [DecidableEq (O → ℤ)] : ℕ :=
  (Finset.univ.image M).card

/-! ## §4. Tropical Min-Plus Factorization -/

/-- A tropical (min-plus) factorization of matrix M through Fin r.
    Decomposes: `M(c,o) = min_{s ∈ Fin r} (left(c,s) + right(s,o))` -/
structure TropFactorization {C O : Type}
    (M : EvalTable C O) (r : ℕ) [NeZero r] where
  /-- Left factor -/
  left : C → Fin r → ℤ
  /-- Right factor -/
  right : Fin r → O → ℤ
  /-- The factorization identity -/
  factorizes : ∀ c o,
    M c o = Finset.univ.inf' (Finset.univ_nonempty (α := Fin r)) (fun s => left c s + right s o)

/-- An evaluation table has tropical rank r -/
def hasTropRank {C O : Type} (M : EvalTable C O) (r : ℕ) [NeZero r] : Prop :=
  Nonempty (TropFactorization M r)

/-- An evaluation table has finite tropical rank -/
def HasFiniteTropRank {C O : Type} (M : EvalTable C O) : Prop :=
  ∃ r : ℕ, ∃ _ : NeZero r, hasTropRank M r

/-! ## §5. Reduced and Canonical Realizations -/

/-- A realization is reduced if encode is surjective (every state is reachable) -/
def IsReducedRealization {C O : Type} (R : Realization C O) : Prop :=
  Surjective R.encode

/-- A realization has separation if distinct states have distinct decode profiles -/
def HasSeparation {C O : Type} (R : Realization C O) : Prop :=
  ∀ s₁ s₂ : R.State, (∀ o : O, R.decode s₁ o = R.decode s₂ o) → s₁ = s₂

/-- A realization is canonical if both reduced and separated -/
def IsCanonicalRealization {C O : Type} (R : Realization C O) : Prop :=
  IsReducedRealization R ∧ HasSeparation R

/-! ## §6. Idempotent Composition Semimodule -/

/-- An idempotent composition semimodule: the algebraic setting for
    tropical response profiles under min-plus superposition. -/
structure IdempotentCompSemimodule where
  /-- Carrier type -/
  Carrier : Type
  /-- Carrier is finite -/
  instFintype : Fintype Carrier
  /-- Tropical addition (min/meet) -/
  tropAdd : Carrier → Carrier → Carrier
  /-- Idempotent: x ⊕ x = x -/
  tropAdd_idem : ∀ x, tropAdd x x = x
  /-- Commutative -/
  tropAdd_comm : ∀ x y, tropAdd x y = tropAdd y x
  /-- Associative -/
  tropAdd_assoc : ∀ x y z, tropAdd (tropAdd x y) z = tropAdd x (tropAdd y z)
  /-- Composition operation -/
  comp : Carrier → Carrier → Carrier
  /-- Composition is associative -/
  comp_assoc : ∀ x y z, comp (comp x y) z = comp x (comp y z)

/-- A semimodule has composition length filtration ≤ d -/
def HasCompLengthFiltration (S : IdempotentCompSemimodule) (d : ℕ) : Prop :=
  ∃ (gens : Finset S.Carrier),
    ∀ x : S.Carrier, ∃ (seq : List S.Carrier),
      seq.length ≤ d ∧ (∀ g ∈ seq, g ∈ gens) ∧
      seq.foldl S.comp x = x

/-! ## §7. Certified Reconstruction -/

/-- A certified reconstruction from a finite response table:
    the architecture provably reproduces the table entries. -/
structure CertifiedReconstruction {C O : Type}
    (M : EvalTable C O) where
  /-- The reconstructed realization -/
  realization : Realization C O
  /-- It correctly realizes the table -/
  correct : Realizes realization M
  /-- It is canonical (reduced + separated) -/
  canonical : IsCanonicalRealization realization

end TropicalOperadicRealization