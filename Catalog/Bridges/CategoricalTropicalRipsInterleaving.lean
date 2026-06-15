/-
  # Categorical Tropical Rips Interleaving
  ## Persistence modules, interleaving distance, the min-plus (tropical) triangle law,
  ## and Vietoris–Rips stability.

  Bridge: connects **categorical persistence theory** (functors out of `(ℝ, ≤)` and their
  interleavings) ↔ **tropical / min-plus algebra** (composition of interleavings is tropical
  multiplication, the optimal interleaving is tropical addition) ↔ **geometry / TDA**
  (Vietoris–Rips filtrations of a dissimilarity and their stability under perturbation of the
  metric).

  **Core principle.** A persistence module is a monotone functor `M : ℝ → α` into a preorder.
  Two modules are `ε`-interleaved when each is dominated by an `ε`-shift of the other. The
  resulting interleaving distance is a genuine `ℝ≥0∞`-valued pseudometric whose triangle
  inequality is *exactly* a statement in the tropical semiring `Tropical ℝ≥0∞`: the
  composition of an `ε`- and a `δ`-interleaving is an `(ε+δ)`-interleaving, and `ε + δ` is
  tropical multiplication. The Vietoris–Rips construction turns a dissimilarity on a fixed
  point set into such a module, and sup-close dissimilarities give interleaved modules
  (algebraic / geometric stability).

  -- !-- Lab Notes -- !--
  -- HYPOTHESIS H1: In a *preorder*-valued model, interleavings carry no extra naturality
  --   data (every square commutes by proof irrelevance), so `Interleaved` reduces to a pair
  --   of shifted pointwise inequalities. This should make all categorical lemmas (reflexivity,
  --   symmetry, monotone weakening, composition) elementary while remaining faithful.
  -- HYPOTHESIS H2: Composition of interleavings is additive in the shift; lifting to
  --   `Tropical ℝ≥0∞` turns the triangle inequality into tropical submultiplicativity.
  -- HYPOTHESIS H3: For Vietoris–Rips, modeling the scale-`t` complex by its edge set
  --   `{(x,y) | d x y ≤ t} ⊆ X × X` inside the complete lattice `Set (X × X)` keeps the
  --   stability proof to one-line metric estimates.
-/

import Mathlib

open scoped ENNReal
open Tropical

noncomputable section

namespace CategoricalTropicalRipsInterleaving

universe u

/-! ## §1. Persistence modules as monotone functors `ℝ → α`. -/

/-- A persistence module valued in a preorder `α`: a monotone map from the parameter line. -/
structure PersMod (α : Type u) [Preorder α] where
  obj : ℝ → α
  mono : Monotone obj

variable {α : Type u} [Preorder α]

/-- `ε`-interleaving of two persistence modules. In a preorder the naturality squares of the
    two interleaving transformations commute automatically, so an interleaving is exactly a
    pair of `ε`-shifted dominations. -/
def Interleaved (ε : ℝ) (M N : PersMod α) : Prop :=
  (∀ t, M.obj t ≤ N.obj (t + ε)) ∧ (∀ t, N.obj t ≤ M.obj (t + ε))

/-
Every module is `0`-interleaved with itself.
-/
theorem interleaved_refl (M : PersMod α) : Interleaved 0 M M := by
  exact ⟨ fun t => by simp, fun t => by simp ⟩

/-
Interleaving is symmetric.
-/
theorem Interleaved.symm {ε : ℝ} {M N : PersMod α} (h : Interleaved ε M N) :
    Interleaved ε N M := by
      exact ⟨ h.2, h.1 ⟩

/-
An `ε`-interleaving is also a `δ`-interleaving for any larger nonnegative shift `δ`.
-/
theorem Interleaved.weaken {ε δ : ℝ} {M N : PersMod α}
    (h : Interleaved ε M N) (hεδ : ε ≤ δ) : Interleaved δ M N := by
      obtain ⟨h1, h2⟩ := h;
      exact ⟨ fun t => le_trans ( h1 t ) ( N.mono ( by linarith ) ), fun t => le_trans ( h2 t ) ( M.mono ( by linarith ) ) ⟩

/-- **Composition law (the tropical multiplication of interleavings).**
    An `ε`-interleaving followed by a `δ`-interleaving yields an `(ε+δ)`-interleaving. -/
theorem Interleaved.trans {ε δ : ℝ} {M N L : PersMod α}
    (h₁ : Interleaved ε M N) (h₂ : Interleaved δ N L) : Interleaved (ε + δ) M L := by
  refine ⟨fun t => ?_, fun t => ?_⟩
  · calc M.obj t ≤ N.obj (t + ε) := h₁.1 t
      _ ≤ L.obj (t + ε + δ) := h₂.1 (t + ε)
      _ = L.obj (t + (ε + δ)) := by rw [add_assoc]
  · calc L.obj t ≤ N.obj (t + δ) := h₂.2 t
      _ ≤ M.obj (t + δ + ε) := h₁.2 (t + δ)
      _ = M.obj (t + (ε + δ)) := by rw [show t + δ + ε = t + (ε + δ) by ring]

/-! ## §2. The interleaving distance in `ℝ≥0∞`. -/

/-- The set of (nonnegative, real) shifts at which `M` and `N` are interleaved, embedded into
    `ℝ≥0∞`. -/
def interleavingSet (M N : PersMod α) : Set ℝ≥0∞ :=
  {x | ∃ ε : ℝ, 0 ≤ ε ∧ Interleaved ε M N ∧ x = ENNReal.ofReal ε}

/-- The interleaving distance: the infimum of all interleaving shifts. Empty infimum is `⊤`
    (no finite interleaving exists). -/
def interleavingDist (M N : PersMod α) : ℝ≥0∞ := sInf (interleavingSet M N)

/-
The distance from a module to itself is `0`.
-/
theorem interleavingDist_self (M : PersMod α) : interleavingDist M M = 0 := by
  refine' le_antisymm ( csInf_le _ _ ) ( zero_le _ );
  · exact ⟨ 0, fun x hx => by rcases hx with ⟨ ε, hε, hε', rfl ⟩ ; exact zero_le _ ⟩;
  · exact ⟨ 0, le_rfl, interleaved_refl M, by simp +decide ⟩

/-
The interleaving distance is symmetric.
-/
theorem interleavingDist_comm (M N : PersMod α) :
    interleavingDist M N = interleavingDist N M := by
      refine' le_antisymm _ _ <;> simp +decide [ interleavingDist ];
      · intro b hb; obtain ⟨ ε, hε, hI, rfl ⟩ := hb; exact csInf_le' ⟨ ε, hε, hI.symm, rfl ⟩ ;
      · intro b hb; obtain ⟨ ε, hε, hMN, rfl ⟩ := hb; exact csInf_le ⟨ 0, by rintro x ⟨ δ, hδ, hNM, rfl ⟩ ; positivity ⟩ ⟨ ε, hε, hMN.symm, rfl ⟩ ;

/-
If `M, N` are `ε`-interleaved with `ε ≥ 0`, the distance is at most `ENNReal.ofReal ε`.
-/
theorem interleavingDist_le_ofReal {ε : ℝ} {M N : PersMod α} (hε : 0 ≤ ε)
    (h : Interleaved ε M N) : interleavingDist M N ≤ ENNReal.ofReal ε := by
      exact csInf_le ⟨ 0, fun x hx => by aesop ⟩ ⟨ ε, hε, h, rfl ⟩

/-
**Triangle inequality.** This is the tropical/min-plus law for the interleaving distance:
    composing interleavings adds shifts, and the infimum distributes.
-/
theorem interleavingDist_triangle (M N L : PersMod α) :
    interleavingDist M L ≤ interleavingDist M N + interleavingDist N L := by
      have h_dist : ∀ x ∈ interleavingSet M N, ∀ y ∈ interleavingSet N L, interleavingDist M L ≤ x + y := by
        -- By definition of interleaving distance, if $x \in \text{interleavingSet } M N$ and $y \in \text{interleavingSet } N L$, then there exist $\varepsilon, \delta \geq 0$ such that $M \leq N[\varepsilon]$ and $N \leq L[\delta]$.
        intro x hx y hy
        obtain ⟨ε, hε_nonneg, hε⟩ := hx
        obtain ⟨δ, hδ_nonneg, hδ⟩ := hy;
        convert interleavingDist_le_ofReal ( add_nonneg hε_nonneg hδ_nonneg ) ( hε.1.trans hδ.1 ) using 1 ; rw [ hε.2, hδ.2, ENNReal.ofReal_add hε_nonneg hδ_nonneg ];
      unfold interleavingDist at *;
      rw [ ENNReal.sInf_add ];
      refine' le_iInf₂ fun x hx => _;
      rw [ ENNReal.add_sInf ];
      exact le_iInf₂ fun y hy => h_dist x hx y hy

/-! ## §3. The tropical reformulation.

The triangle inequality, transported to the tropical semiring `Tropical ℝ≥0∞` (where
multiplication is ordinary addition), is exactly *submultiplicativity* of `trop ∘
interleavingDist`. This is the precise sense in which interleaving distances live in the
min-plus world. -/

/-
The interleaving distance is tropically submultiplicative:
    `trop d(M,L) ≤ trop d(M,N) * trop d(N,L)` in `Tropical ℝ≥0∞`, which unfolds to the
    ordinary triangle inequality.
-/
theorem interleaving_tropical_submul (M N L : PersMod α) :
    trop (interleavingDist M L) ≤ trop (interleavingDist M N) * trop (interleavingDist N L) := by
  convert interleavingDist_triangle M N L using 1

/-! ## §4. Vietoris–Rips persistence modules and stability. -/

variable {X : Type u}

/-- The Vietoris–Rips persistence module of a dissimilarity `d : X → X → ℝ`: at scale `t` the
    object is the edge set `{(x,y) | d x y ≤ t}` inside the complete lattice `Set (X × X)`,
    ordered by inclusion. Monotone in `t`. -/
def RipsMod (d : X → X → ℝ) : PersMod (Set (X × X)) where
  obj t := {p | d p.1 p.2 ≤ t}
  mono := fun _ _ hab _ hp => le_trans hp hab

/-
**Vietoris–Rips stability.** If two dissimilarities differ by at most `ε` pointwise, their
    Rips modules are `ε`-interleaved.
-/
theorem rips_stability (d d' : X → X → ℝ) {ε : ℝ}
    (h : ∀ x y, |d x y - d' x y| ≤ ε) : Interleaved ε (RipsMod d) (RipsMod d') := by
      constructor <;> intro t p hp <;> simp_all +decide [ abs_le, RipsMod ]; all_goals linarith [ h p.1 p.2 ]

/-
Consequently the interleaving distance of the Rips modules is controlled by the sup
    perturbation of the dissimilarity.
-/
theorem rips_interleavingDist_le (d d' : X → X → ℝ) {ε : ℝ} (hε : 0 ≤ ε)
    (h : ∀ x y, |d x y - d' x y| ≤ ε) :
    interleavingDist (RipsMod d) (RipsMod d') ≤ ENNReal.ofReal ε := by
      exact le_trans ( interleavingDist_le_ofReal hε ( rips_stability d d' h ) ) le_rfl

-- !-- Lab Notes -- !--
-- OUTCOME (to be confirmed on build):
--  * §1 categorical lemmas: expected trivial from `Monotone` + arithmetic on shifts. The
--    composition law `Interleaved.trans` is the conceptual heart — it is what makes the
--    distance a pseudometric and what becomes tropical multiplication in §3.
--  * §2 distance: `interleavingDist_triangle` is the only nontrivial inf-arithmetic step;
--    it uses `ENNReal.sInf_add`/`ENNReal.add_sInf` to push `sInf` past `+` and then bounds the
--    double infimum by the composition law.
--  * §3: `untrop_le_iff` + `untrop_mul` reduce the tropical statement to §2's triangle ineq.
--  * §4: stability is a one-line `|d - d'| ≤ ε ⇒ d' ≤ d + ε` estimate per inclusion.
-- FAILURE ANALYSIS: a naive ℝ-valued `interleavingDist` (via `Real.sInf`) misbehaves on the
--  empty interleaving set (`sInf ∅ = 0`), wrongly forcing distance `0`. Working in `ℝ≥0∞`,
--  where `sInf ∅ = ⊤`, fixes this and is also where the tropical structure lives.

end CategoricalTropicalRipsInterleaving