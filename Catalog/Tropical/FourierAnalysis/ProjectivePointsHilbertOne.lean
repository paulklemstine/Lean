/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Canonical Tropical Fourier Expansions for Projective Point Sets under `h = 1`

## What this file is (and an honest note on the framing)

The phrase "canonical tropical Fourier expansions for projective point sets under
`h = 1`" is *not* a standard named theorem in the literature.  To turn it into a
precise mathematical statement we fix the following interpretation, made fully
explicit so that the formal content is unambiguous:

* **Tropical Fourier expansion.**  We work over the max-plus (tropical) semiring,
  modelled here on `WithBot M` for a `LinearOrder`ed additive commutative monoid
  `M` (tropical "addition" `⊕ = max`, tropical "multiplication" `⊙ = +`, additive
  unit `⊥ = -∞`).  The *canonical tropical basis* is the family of tropical delta
  functions `tropDelta k x = 0` if `x = k`, else `⊥`.  A *tropical Fourier
  expansion* of a signal `f : α → M` over a finite index set `α` is a max-plus
  combination `x ↦ ⨆ₖ (c k ⊙ tropDelta k x)` of the basis functions; it is
  *canonical* when the coefficients `c` are the tropical Fourier coefficients
  `tropFourierCoeff f k = ↑(f k)`.

* **Projective point set / Hilbert function.**  A finite set of points
  `X ⊆ ℙⁿ` has a Hilbert function `h_X(d) = dim_k (R/I_X)_d`.  We abstract a single
  graded piece by its monomial/coordinate basis, an index type `α` whose
  cardinality is the Hilbert-function value `h`.  The *special setting `h = 1`*
  (a single reduced point, whose Hilbert function is identically `1`, or any
  graded piece that is one-dimensional) is modelled by `Fintype.card α = 1`.

Under this interpretation we prove:

1. `tropExpansion_eq` — the delta basis is genuinely a basis: any max-plus
   combination collapses, `tropExpansion c x = c x`.
2. `tropExpansion_reconstruct` — **existence** of the canonical expansion: the
   canonical coefficients reconstruct `f` exactly.
3. `tropExpansion_unique` — **canonicity/uniqueness**: the canonical coefficients
   are the *only* coefficients reconstructing `f`.
4. `tropFourierCoeff_injective` — distinct signals have distinct expansions.
5. The `h = 1` rigidity results (`hilbertOne_*`): the expansion has a single
   term, every signal/coefficient solution is forced, and the spectrum is
   necessarily full (no missing frequencies) — the new constraint that arises in
   this special setting.
6. `tropExpansion_reconstruct_compute` / `hilbertOne_reconstruct_compute` —
   machine-checked computational verifications of the reconstruction identity on
   explicit instances over `ℚ` (modern kernel-reduction based verification).

We do not claim novelty or significance for this construction; it is the standard
idempotent/tropical "inversion in the delta basis", specialised to a
one-dimensional graded piece.
-/

import Mathlib

open Finset

variable {M : Type*} [LinearOrder M] [AddCommMonoid M]

/-! ## Core definitions: the canonical tropical (max-plus) basis -/

/-- **Tropical delta basis**: `tropDelta k x = 0` (tropical unit of `⊙`) if `x = k`,
and `⊥ = -∞` (tropical unit of `⊕`) otherwise.  This is the canonical basis in
which tropical Fourier expansions are taken. -/
def tropDelta {α : Type*} [DecidableEq α] (k x : α) : WithBot M :=
  if x = k then (0 : M) else ⊥

/-- **Tropical Fourier expansion** of a coefficient function `c` in the delta
basis: `x ↦ ⨆ₖ (c k ⊙ tropDelta k x)`, with `⊕ = max` realised by `Finset.sup`
and `⊙ = +`. -/
def tropExpansion {α : Type*} [Fintype α] [DecidableEq α]
    (c : α → WithBot M) (x : α) : WithBot M :=
  univ.sup (fun k => c k + tropDelta (M := M) k x)

/-- **Canonical tropical Fourier coefficients** of a signal `f : α → M`:
`ĉ(k) = ↑(f k)`. -/
def tropFourierCoeff {α : Type*} (f : α → M) (k : α) : WithBot M := (f k : WithBot M)

/-! ## Basis property and the canonical expansion -/

/-
The delta family is a genuine basis: every max-plus combination collapses to
its own coefficient, `tropExpansion c x = c x`.
-/
theorem tropExpansion_eq {α : Type*} [Fintype α] [DecidableEq α]
    (c : α → WithBot M) (x : α) : tropExpansion c x = c x := by
  refine' le_antisymm ( Finset.sup_le _ ) ( Finset.le_sup ( f := fun k => c k + tropDelta k x ) ( Finset.mem_univ x ) |> le_trans _ );
  · intro y hy; unfold tropDelta; aesop;
  · simp +decide [ tropDelta ]

/-
The canonical Fourier coefficient is never `⊥`: every frequency is present in
the spectrum of `f`.
-/
omit [LinearOrder M] [AddCommMonoid M] in
theorem tropFourierCoeff_ne_bot {α : Type*} (f : α → M) (k : α) :
    tropFourierCoeff f k ≠ (⊥ : WithBot M) := by
  exact WithBot.coe_ne_bot

/-
**Existence of the canonical tropical Fourier expansion.**  The canonical
coefficients reconstruct the signal exactly.
-/
theorem tropExpansion_reconstruct {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → M) (x : α) :
    tropExpansion (tropFourierCoeff f) x = (f x : WithBot M) := by
  convert tropExpansion_eq _ _

/-
**Canonicity (uniqueness) of the expansion.**  Any coefficient function whose
expansion reconstructs `f` must be the canonical Fourier coefficient function.
-/
theorem tropExpansion_unique {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → M) (c : α → WithBot M)
    (hc : ∀ x, tropExpansion c x = (f x : WithBot M)) :
    c = tropFourierCoeff f := by
  ext x;
  exact tropExpansion_eq c x ▸ hc x

/-
Distinct signals have distinct canonical expansions (the Fourier coefficient
map is injective).
-/
omit [LinearOrder M] [AddCommMonoid M] in
theorem tropFourierCoeff_injective {α : Type*} :
    Function.Injective (tropFourierCoeff (α := α) (M := M)) := by
  intro f g hfg;
  exact funext fun x => WithBot.coe_inj.mp ( congr_fun hfg x )

/-! ## The special setting `h = 1`

`Fintype.card α = 1` models a single projective point (Hilbert function `≡ 1`) or
a one-dimensional graded piece.  In this setting the canonical tropical Fourier
expansion becomes completely rigid. -/

/-
Under `h = 1` there is a single index (the unique projective point / the unique
basis monomial of the one-dimensional graded piece).
-/
theorem hilbertOne_unique_index {α : Type*} [Fintype α] (h1 : Fintype.card α = 1) :
    ∃ o : α, ∀ x : α, x = o := by
  exact Fintype.card_eq_one_iff.mp h1

/-
**`h = 1` rigidity: single-term expansion.**  When `h = 1` the expansion has
no genuine maximum — it reduces to one tropical term, so its value at any point
equals the coefficient at any (necessarily equal) index.
-/
theorem hilbertOne_single_term {α : Type*} [Fintype α] [DecidableEq α]
    (h1 : Fintype.card α = 1) (c : α → WithBot M) (x y : α) :
    tropExpansion c x = c y := by
  have := Fintype.card_eq_one_iff.mp h1;
  convert tropExpansion_eq c x;
  obtain ⟨ z, hz ⟩ := this; rw [ hz x, hz y ] ;

/-
**`h = 1` rigidity, combined.**  In the one-dimensional setting the whole
expansion collapses onto a single forced frequency: there is a unique index `o`,
its canonical Fourier coefficient is necessarily finite (`≠ ⊥`, the spectrum
cannot degenerate), and the canonical expansion is constantly equal to this one
coefficient.  This is the new structural constraint that `h = 1` imposes — beyond
the general existence (`tropExpansion_reconstruct`) and uniqueness
(`tropExpansion_unique`) of the canonical expansion, which hold for any `h`.
-/
theorem hilbertOne_rigid {α : Type*} [Fintype α] [DecidableEq α]
    (h1 : Fintype.card α = 1) (f : α → M) :
    ∃ o : α, (∀ x, x = o) ∧ tropFourierCoeff f o ≠ (⊥ : WithBot M) ∧
      ∀ x, tropExpansion (tropFourierCoeff f) x = tropFourierCoeff f o := by
  obtain ⟨o, ho⟩ := hilbertOne_unique_index (α := α) h1
  refine ⟨o, ho, WithBot.coe_ne_bot, fun x => ?_⟩
  rw [tropExpansion_eq, ho x]

/-! ## Computational verification (modern kernel-reduction methods)

The reconstruction identity is decidable on any explicit finite instance over a
computable ordered monoid; we verify it by kernel evaluation over `ℚ`. -/

/-- A concrete signal on three indices, over `ℚ`. -/
def fEx : Fin 3 → ℚ := ![3, -1, 5]

/-- Machine-checked verification that the canonical expansion reconstructs `fEx`. -/
theorem tropExpansion_reconstruct_compute :
    ∀ x : Fin 3, tropExpansion (M := ℚ) (tropFourierCoeff fEx) x = (fEx x : WithBot ℚ) := by
  native_decide

/-- A concrete `h = 1` instance: a single index, over `ℚ`. -/
def fOne : Fin 1 → ℚ := ![7]

/-- Machine-checked verification of the rigid single-term reconstruction at `h = 1`. -/
theorem hilbertOne_reconstruct_compute :
    ∀ x : Fin 1, tropExpansion (M := ℚ) (tropFourierCoeff fOne) x = (fOne x : WithBot ℚ) := by
  native_decide