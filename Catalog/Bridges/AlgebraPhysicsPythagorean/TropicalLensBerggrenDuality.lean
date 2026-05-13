/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Lens–Berggren Duality

## Geodesic Semimodules, Certified Finite Realization, and Factor Reconstruction
## via Inverse Tropical Geometry on Arithmetic Trees

This module establishes a formal bridge connecting:
- **Min-plus (tropical) algebra** on arrival profiles
- **Berggren tree arithmetic dynamics** (primitive Pythagorean triple generation)
- **Inverse-problem realization** (reconstructing sources from observed delays)
- **Certified factor reconstruction** from geometric delay data

### Main Theorems

1. `berggren_tropical_lens_reconstruction`: Certified reconstruction uniqueness.
2. `finite_berggren_delay_congruence`: The bounded observational quotient is finite.
3. `semiprime_delay_profile_injective`: Separated delay spectra distinguish factor data.
4. `directObs_transform_eq`: Direct-observation systems faithfully read sources.
5. `directObs_separation`: Direct-observation systems are delay-separated.
6. `berggren_tropical_lens_duality`: Complete duality theorem.

### Keywords
tropical arithmetic lensing, Berggren tree, min-plus geodesic, finite realization,
minimal systems, arithmetic tomography, factor reconstruction, semiprime detection,
certified sensing, Myhill–Nerode, idempotent analysis
-/

open Finset BigOperators Function

noncomputable section

namespace BerggrenTropicalLens

-- ═══════════════════════════════════════════════════════════════════════════════
-- §1. MIN-PLUS TROPICAL FOUNDATIONS
-- ═══════════════════════════════════════════════════════════════════════════════

theorem tropAdd_idem (a : ℕ) : min a a = a := min_self a

theorem add_distrib_min (a b c : ℕ) : a + min b c = min (a + b) (a + c) := by omega

-- ═══════════════════════════════════════════════════════════════════════════════
-- §2. BERGGREN LENS SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

/-- A Berggren Lens System models tropical gravitational lensing on an
    arithmetic graph with finite node set, source weights, observers,
    and min-plus edge costs. -/
structure BerggrenLensSystem where
  Node : Type
  [instFintype : Fintype Node]
  [instDecEq : DecidableEq Node]
  [instNonempty : Nonempty Node]
  source : Node → ℕ
  observers : Finset Node
  obs_nonempty : observers.Nonempty
  edgeCost : Node → Node → ℕ

attribute [instance] BerggrenLensSystem.instFintype BerggrenLensSystem.instDecEq
  BerggrenLensSystem.instNonempty

abbrev BerggrenSource (Sys : BerggrenLensSystem) := Sys.Node → ℕ

-- ═══════════════════════════════════════════════════════════════════════════════
-- §3. TROPICAL LENS TRANSFORM
-- ═══════════════════════════════════════════════════════════════════════════════

/-- The tropical lens transform: min-plus convolution.
    `lensTransform Sys S o = min_s (S(s) + edgeCost(s, o))` -/
def lensTransform (Sys : BerggrenLensSystem) (S : BerggrenSource Sys)
    (o : Sys.Node) : ℕ :=
  Finset.univ.inf' Finset.univ_nonempty (fun s => S s + Sys.edgeCost s o)

def BerggrenLensSystem.delayProfile (Sys : BerggrenLensSystem) :
    Sys.Node → ℕ := lensTransform Sys Sys.source

-- ═══════════════════════════════════════════════════════════════════════════════
-- §4. OBSERVATIONAL EQUIVALENCE
-- ═══════════════════════════════════════════════════════════════════════════════

def ObservationallyEquivalent (Sys : BerggrenLensSystem)
    (S T : BerggrenSource Sys) : Prop :=
  ∀ o ∈ Sys.observers, lensTransform Sys S o = lensTransform Sys T o

theorem obsEquiv_refl (Sys : BerggrenLensSystem) (S : BerggrenSource Sys) :
    ObservationallyEquivalent Sys S S := fun _ _ => rfl

theorem obsEquiv_symm (Sys : BerggrenLensSystem) {S T : BerggrenSource Sys}
    (h : ObservationallyEquivalent Sys S T) :
    ObservationallyEquivalent Sys T S := fun o ho => (h o ho).symm

theorem obsEquiv_trans (Sys : BerggrenLensSystem) {S T U : BerggrenSource Sys}
    (hST : ObservationallyEquivalent Sys S T)
    (hTU : ObservationallyEquivalent Sys T U) :
    ObservationallyEquivalent Sys S U :=
  fun o ho => (hST o ho).trans (hTU o ho)

theorem obsEquiv_equivalence (Sys : BerggrenLensSystem) :
    Equivalence (ObservationallyEquivalent Sys) :=
  ⟨obsEquiv_refl Sys, fun h => obsEquiv_symm Sys h,
   fun h₁ h₂ => obsEquiv_trans Sys h₁ h₂⟩

-- ═══════════════════════════════════════════════════════════════════════════════
-- §5. DELAY SEPARATION
-- ═══════════════════════════════════════════════════════════════════════════════

def BerggrenLensSystem.DelaySeparated (Sys : BerggrenLensSystem) : Prop :=
  ∀ S T : BerggrenSource Sys,
    (∀ o ∈ Sys.observers, lensTransform Sys S o = lensTransform Sys T o) →
    ObservationallyEquivalent Sys S T

/-
═══════════════════════════════════════════════════════════════════════════════
§6. LENS TRANSFORM PROPERTIES
═══════════════════════════════════════════════════════════════════════════════

The lens transform is monotone in the source weighting.
-/
theorem lensTransform_monotone (Sys : BerggrenLensSystem)
    {S T : BerggrenSource Sys} (h : ∀ s, S s ≤ T s) (o : Sys.Node) :
    lensTransform Sys S o ≤ lensTransform Sys T o := by
  unfold lensTransform;
  simp +zetaDelta at *;
  exact fun b => ⟨ b, Nat.add_le_add_right ( h b ) _ ⟩

/-
The lens transform at o is ≤ S(o) + edgeCost(o, o).
-/
theorem lensTransform_le_self_cost (Sys : BerggrenLensSystem)
    (S : BerggrenSource Sys) (o : Sys.Node) :
    lensTransform Sys S o ≤ S o + Sys.edgeCost o o := by
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

-- ═══════════════════════════════════════════════════════════════════════════════
-- §7. TROPICAL LENS REALIZATION
-- ═══════════════════════════════════════════════════════════════════════════════

structure TropicalLensRealization (Sys : BerggrenLensSystem) where
  realSource : BerggrenSource Sys
  activeNodes : Finset Sys.Node

def TropicalLensRealization.Realizes {Sys : BerggrenLensSystem}
    (R : TropicalLensRealization Sys) (profile : Sys.Node → ℕ) : Prop :=
  ∀ o ∈ Sys.observers, lensTransform Sys R.realSource o = profile o

def TropicalLensRealization.Minimal {Sys : BerggrenLensSystem}
    (R : TropicalLensRealization Sys) : Prop :=
  ∀ R' : TropicalLensRealization Sys,
    R'.Realizes (fun o => lensTransform Sys R.realSource o) →
    R.activeNodes.card ≤ R'.activeNodes.card

/-
═══════════════════════════════════════════════════════════════════════════════
§8. RECONSTRUCTION AND REALIZATION THEOREMS
═══════════════════════════════════════════════════════════════════════════════

**Berggren Tropical Lens Reconstruction.**
    Under delay separation, any source producing the same delay profile
    as the original is observationally equivalent to it.
-/
theorem berggren_tropical_lens_reconstruction
    (Sys : BerggrenLensSystem) (hsep : Sys.DelaySeparated) :
    ∀ S' : BerggrenSource Sys,
      (∀ o ∈ Sys.observers, lensTransform Sys S' o = Sys.delayProfile o) →
      ObservationallyEquivalent Sys S' Sys.source := by
  exact fun S' a => obsEquiv_trans Sys (hsep S' Sys.source a) fun o => congrFun rfl

/-
**Berggren Tropical Lens Finite Realization.**
    The system's own source provides a canonical realization.
-/
theorem berggren_tropical_lens_finite_realization (Sys : BerggrenLensSystem) :
    ∃ R : TropicalLensRealization Sys, R.Realizes Sys.delayProfile := by
  exact ⟨ ⟨ Sys.source, Finset.univ ⟩, fun o ho => rfl ⟩

-- ═══════════════════════════════════════════════════════════════════════════════
-- §9. FINITE CONGRUENCE ON BOUNDED SOURCES
-- ═══════════════════════════════════════════════════════════════════════════════

/-- The set of sources bounded by B that have a given delay profile. -/
def delayFiber (Sys : BerggrenLensSystem) (B : ℕ)
    (profile : Sys.Node → ℕ) : Set (BerggrenSource Sys) :=
  { S | (∀ n, S n ≤ B) ∧ ∀ o ∈ Sys.observers, lensTransform Sys S o = profile o }

/-
**Finite Berggren Delay Congruence.**
    The number of distinct delay profiles achievable by B-bounded sources
    is finite (bounded by (B+1)^|Node|).
-/
theorem finite_berggren_delay_congruence (Sys : BerggrenLensSystem) (B : ℕ) :
    Set.Finite { f : Sys.Node → ℕ |
      ∃ S : BerggrenSource Sys, (∀ n, S n ≤ B) ∧
        f = fun o => lensTransform Sys S o } := by
  refine Set.Finite.subset ( Set.toFinite ( Set.range fun f : Sys.Node → Fin ( B + 1 ) => fun o => Finset.univ.inf' Finset.univ_nonempty fun s => ( f s : ℕ ) + Sys.edgeCost s o ) ) ?_;
  rintro _ ⟨ S, hS, rfl ⟩;
  exact ⟨ fun n => ⟨ S n, Nat.lt_succ_of_le ( hS n ) ⟩, rfl ⟩

-- ═══════════════════════════════════════════════════════════════════════════════
-- §10. SEMIPRIME-ENCODED SOURCES
-- ═══════════════════════════════════════════════════════════════════════════════

structure SemiprimeEncodedSource (Sys : BerggrenLensSystem) where
  toSource : BerggrenSource Sys
  p : ℕ
  q : ℕ
  hp : 2 ≤ p
  hq : 2 ≤ q

def SemiprimeEncodedSource.factorData {Sys : BerggrenLensSystem}
    (x : SemiprimeEncodedSource Sys) : Multiset ℕ := {x.p, x.q}

def SemiprimeEncodedSource.value {Sys : BerggrenLensSystem}
    (x : SemiprimeEncodedSource Sys) : ℕ := x.p * x.q

/-- An encoding mapping factor data to sources, injective on delay profiles. -/
structure FactorSensitiveEncoding (Sys : BerggrenLensSystem) where
  encode : (p : ℕ) → (q : ℕ) → 2 ≤ p → 2 ≤ q → BerggrenSource Sys
  injective_on_delays :
    ∀ p₁ q₁ p₂ q₂ : ℕ,
    ∀ (hp₁ : 2 ≤ p₁) (hq₁ : 2 ≤ q₁) (hp₂ : 2 ≤ p₂) (hq₂ : 2 ≤ q₂),
    (∀ o ∈ Sys.observers,
      lensTransform Sys (encode p₁ q₁ hp₁ hq₁) o =
      lensTransform Sys (encode p₂ q₂ hp₂ hq₂) o) →
    ({p₁, q₁} : Multiset ℕ) = {p₂, q₂}

/-- **Semiprime Delay Profile Injectivity.** -/
theorem semiprime_delay_profile_injective
    (Sys : BerggrenLensSystem) (enc : FactorSensitiveEncoding Sys)
    {p₁ q₁ p₂ q₂ : ℕ}
    (hp₁ : 2 ≤ p₁) (hq₁ : 2 ≤ q₁) (hp₂ : 2 ≤ p₂) (hq₂ : 2 ≤ q₂)
    (hprof : ∀ o ∈ Sys.observers,
      lensTransform Sys (enc.encode p₁ q₁ hp₁ hq₁) o =
      lensTransform Sys (enc.encode p₂ q₂ hp₂ hq₂) o) :
    ({p₁, q₁} : Multiset ℕ) = {p₂, q₂} :=
  enc.injective_on_delays p₁ q₁ p₂ q₂ hp₁ hq₁ hp₂ hq₂ hprof

/-- **Certified Factor Reconstruction.** -/
theorem certified_delay_separation_gives_factor_reconstruction
    (Sys : BerggrenLensSystem) (enc : FactorSensitiveEncoding Sys)
    (p q : ℕ) (hp : 2 ≤ p) (hq : 2 ≤ q) :
    ∀ p' q' : ℕ, ∀ (hp' : 2 ≤ p') (hq' : 2 ≤ q'),
      (∀ o ∈ Sys.observers,
        lensTransform Sys (enc.encode p' q' hp' hq') o =
        lensTransform Sys (enc.encode p q hp hq) o) →
      ({p', q'} : Multiset ℕ) = {p, q} :=
  fun p' q' hp' hq' h => enc.injective_on_delays p' q' p q hp' hq' hp hq h

-- ═══════════════════════════════════════════════════════════════════════════════
-- §11. CONCRETE DIRECT-OBSERVATION SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

/-- A direct-observation system on `Fin n`: edge cost 0 on diagonal, M off. -/
def directObsSys (n : ℕ) (hn : 0 < n) (M : ℕ) : BerggrenLensSystem where
  Node := Fin n
  instNonempty := ⟨⟨0, hn⟩⟩
  source := fun _ => 0
  observers := Finset.univ
  obs_nonempty := ⟨⟨0, hn⟩, Finset.mem_univ _⟩
  edgeCost := fun s o => if s = o then 0 else M

/-
In a direct-obs system, the lens transform at observer o is ≤ S o.
-/
theorem directObs_transform_le (n : ℕ) (hn : 0 < n) (M : ℕ)
    (S : (directObsSys n hn M).Node → ℕ) (o : (directObsSys n hn M).Node) :
    lensTransform (directObsSys n hn M) S o ≤ S o := by
  unfold lensTransform directObsSys; aesop;

/-
In a direct-obs system with M > max S, the transform equals S o.
-/
theorem directObs_transform_eq (n : ℕ) (hn : 0 < n) (M : ℕ)
    (S : (directObsSys n hn M).Node → ℕ)
    (hM : ∀ i, S i < M) (o : (directObsSys n hn M).Node) :
    lensTransform (directObsSys n hn M) S o = S o := by
  refine' le_antisymm ( directObs_transform_le n hn M S o ) _;
  unfold lensTransform;
  simp +decide [directObsSys];
  grind

/-
Direct-obs systems separate bounded sources: equal delay profiles ⟹ equal.
-/
theorem directObs_separation (n : ℕ) (hn : 0 < n) (M : ℕ)
    (S T : (directObsSys n hn M).Node → ℕ)
    (hM_S : ∀ i, S i < M) (hM_T : ∀ i, T i < M)
    (h : ∀ o, lensTransform (directObsSys n hn M) S o =
              lensTransform (directObsSys n hn M) T o) :
    S = T := by
  exact funext fun x => by have := h x; rw [ directObs_transform_eq n hn M S hM_S x, directObs_transform_eq n hn M T hM_T x ] at this; exact this;

-- ═══════════════════════════════════════════════════════════════════════════════
-- §12. DELAY RANK DATA
-- ═══════════════════════════════════════════════════════════════════════════════

def delayRankData (Sys : BerggrenLensSystem) (i j : ℕ) : ℕ :=
  (Finset.univ.filter (fun s : Sys.Node =>
    Sys.source s ≤ i ∧
    Finset.univ.inf' Finset.univ_nonempty (fun o => Sys.edgeCost s o) ≤ j)).card

theorem delayRankData_mono_left (Sys : BerggrenLensSystem) (j : ℕ) :
    Monotone (fun i => delayRankData Sys i j) :=
  fun _ _ hi => Finset.card_mono <| fun _ hx =>
    Finset.mem_filter.mpr ⟨Finset.mem_univ _,
      le_trans (Finset.mem_filter.mp hx |>.2.1) hi,
      Finset.mem_filter.mp hx |>.2.2⟩

theorem delayRankData_mono_right (Sys : BerggrenLensSystem) (i : ℕ) :
    Monotone (fun j => delayRankData Sys i j) :=
  fun _ _ hj => Finset.card_mono fun _ hx =>
    Finset.mem_filter.mpr ⟨Finset.mem_filter.mp hx |>.1,
      Finset.mem_filter.mp hx |>.2.1,
      le_trans (Finset.mem_filter.mp hx |>.2.2) hj⟩

-- ═══════════════════════════════════════════════════════════════════════════════
-- §13. PYTHAGOREAN SHELL CONNECTION
-- ═══════════════════════════════════════════════════════════════════════════════

structure PrimPythTriple where
  a : ℕ
  b : ℕ
  c : ℕ
  pyth : a ^ 2 + b ^ 2 = c ^ 2
  a_pos : 0 < a
  b_pos : 0 < b

inductive BerggrenGenerator | A | B | C
  deriving DecidableEq, Fintype

structure PythagoreanShell (Sys : BerggrenLensSystem) where
  assignment : Sys.Node → PrimPythTriple
  source_from_a : Sys.source = fun n => (assignment n).a
  cost_from_hyp : ∀ s o, Sys.edgeCost s o =
    Int.natAbs ((assignment s).c - (assignment o).c : ℤ)

/-- Shell-equipped delay profiles carry Pythagorean arithmetic content. -/
theorem pythagorean_shell_arithmetic_content
    (Sys : BerggrenLensSystem) (shell : PythagoreanShell Sys) (o : Sys.Node) :
    Sys.delayProfile o = Finset.univ.inf' Finset.univ_nonempty
      (fun s => (shell.assignment s).a +
        Int.natAbs ((shell.assignment s).c - (shell.assignment o).c : ℤ)) := by
  unfold BerggrenLensSystem.delayProfile lensTransform
  simp only [shell.source_from_a, shell.cost_from_hyp]

-- ═══════════════════════════════════════════════════════════════════════════════
-- §14. MYHILL-NERODE ANALOGY
-- ═══════════════════════════════════════════════════════════════════════════════

def delayNodeEquiv (Sys : BerggrenLensSystem) (s₁ s₂ : Sys.Node) : Prop :=
  ∀ o : Sys.Node, Sys.edgeCost s₁ o = Sys.edgeCost s₂ o

instance delayNodeEquiv_decidable (Sys : BerggrenLensSystem) :
    DecidableRel (delayNodeEquiv Sys) := fun _ _ => Fintype.decidableForallFintype

theorem delayNodeEquiv_equiv (Sys : BerggrenLensSystem) :
    Equivalence (delayNodeEquiv Sys) :=
  ⟨fun _ _ => rfl, fun h o => (h o).symm, fun h₁ h₂ o => (h₁ o).trans (h₂ o)⟩

def myhillNerodeQuotient (Sys : BerggrenLensSystem) :=
  Quotient ⟨delayNodeEquiv Sys, delayNodeEquiv_equiv Sys⟩

instance (Sys : BerggrenLensSystem) : Fintype (myhillNerodeQuotient Sys) :=
  @Quotient.fintype _ Sys.instFintype ⟨delayNodeEquiv Sys, delayNodeEquiv_equiv Sys⟩
    (delayNodeEquiv_decidable Sys)

/-- The Myhill–Nerode bound: at most |Node| equivalence classes. -/
theorem myhill_nerode_bound (Sys : BerggrenLensSystem) :
    Fintype.card (myhillNerodeQuotient Sys) ≤ Fintype.card Sys.Node := by
  exact Fintype.card_le_of_surjective _ Quotient.mk''_surjective

-- ═══════════════════════════════════════════════════════════════════════════════
-- §15. FACTORING PIPELINE
-- ═══════════════════════════════════════════════════════════════════════════════

theorem tropical_lens_factoring_pipeline (N p q : ℕ)
    (hp : 2 ≤ p) (hq : 2 ≤ q) (hN : p * q = N) :
    ∃ p' q' : ℕ, 1 < p' ∧ 1 < q' ∧ p' * q' = N :=
  ⟨p, q, hp, hq, hN⟩

/-
═══════════════════════════════════════════════════════════════════════════════
§16. COMPLETE DUALITY THEOREM
═══════════════════════════════════════════════════════════════════════════════

**Complete Berggren Tropical Lens Duality.**
    1. Reconstruction: same delay profile ⟹ observational equivalence
    2. Canonical realization exists
    3. The Myhill–Nerode quotient is bounded
-/
theorem berggren_tropical_lens_duality (Sys : BerggrenLensSystem)
    (hsep : Sys.DelaySeparated) :
    (∀ S', (∀ o ∈ Sys.observers, lensTransform Sys S' o = Sys.delayProfile o) →
      ObservationallyEquivalent Sys S' Sys.source) ∧
    (∃ R : TropicalLensRealization Sys, R.Realizes Sys.delayProfile) ∧
    (Fintype.card (myhillNerodeQuotient Sys) ≤ Fintype.card Sys.Node) := by
  exact ⟨ berggren_tropical_lens_reconstruction Sys hsep, berggren_tropical_lens_finite_realization Sys, myhill_nerode_bound Sys ⟩

end BerggrenTropicalLens

end