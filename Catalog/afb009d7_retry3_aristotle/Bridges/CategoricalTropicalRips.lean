/-
# Bridges — Categorical Tropical Rips: Relabeling & Quotient Transport

This file develops a compact, fully verified package of **transport-compatibility
and invariance lemmas** for the persistent-homology / Vietoris–Rips interleaving
geometry built in the Boltzmann Bridge arc
(`Applications.BoltzmannBridge.HigherPersistence`,
`Applications.BoltzmannBridge.BottleneckStability`,
`Applications.BoltzmannBridge.InterleavingMetric`,
`Applications.BoltzmannBridge.InterleavingQuotient`).

The categorical-tropical reading of that arc is that a `Filtration` is a
tropical (min-plus) weight on simplices, the **shift** functor `shift a` is the
additive smoothing `weight ↦ weight − a`, and **relabeling** a filtration along
an equivalence `e : α ≃ β` is the comap functor `comap e`.  The interleaving
distance is the resulting (extended) pseudmetric.

We prove:

* `shift_comap` — relabeling commutes with shift (the two functors commute).
* `Interleaved_comap_iff` — interleaving is invariant under relabeling.
* `interleavingDist_comap` — the (real) interleaving distance is invariant under
  relabeling.
* `eInterleavingDist_comap` — the same for the `ℝ≥0∞`-valued distance.
* `edist_mk_comap` — the invariance descends to the separation quotient
  (the genuine `EMetricSpace` of `InterleavingQuotient`).
* `selfShiftDist_comap`, `selfShiftDist_transport` — the bundled **transport
  principle**: any exact self-shift-distance statement for a filtration transfers
  verbatim to all of its relabelings (and, via `edist_quotient_mk`, to the
  quotient image).

Everything is proved by unfolding definitions, an extensionality lemma for
`Filtration`, and the existing isometry/pseudometric API; no new theory is
introduced.
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability
import Applications.BoltzmannBridge.BottleneckStability
import Applications.BoltzmannBridge.InterleavingMetric
import Applications.BoltzmannBridge.InterleavingQuotient

open Finset BigOperators
open scoped ENNReal

namespace Bridges.CategoricalTropicalRips

open BoltzmannBridge
open BoltzmannBridge.Filtration

variable {α β : Type*}

/-! ## Extensionality for filtrations -/

/-- **Extensionality.**  Two filtrations are equal as soon as their weight
functions agree; the monotonicity/groundedness fields are propositions. -/
theorem filtration_ext {F G : Filtration α} (h : F.weight = G.weight) : F = G := by
  cases F; cases G; cases h; rfl

/-! ## The shift (smoothing) functor -/

/-- **The shift / smoothing functor.**  `shift a F` lowers every simplex weight by
`a ≥ 0`; equivalently its sublevel family at scale `t` is that of `F` at `t + a`.
Groundedness and monotonicity are preserved because `a ≥ 0`. -/
def shift (a : ℝ) (ha : 0 ≤ a) (F : Filtration α) : Filtration α where
  weight σ := F.weight σ - a
  weight_empty := by have := F.weight_empty; linarith
  weight_mono := fun {σ τ} h => by have := F.weight_mono h; linarith

@[simp] theorem shift_weight (a : ℝ) (ha : 0 ≤ a) (F : Filtration α) (σ : Finset α) :
    (shift a ha F).weight σ = F.weight σ - a := rfl

/-! ## The relabeling (comap) functor -/

/-- **Relabeling along an equivalence.**  Given `e : α ≃ β`, `comap e F` pulls a
filtration on `β` back to a filtration on `α` by relabeling each simplex through
`e` before evaluating the weight. -/
def comap (e : α ≃ β) (F : Filtration β) : Filtration α where
  weight σ := F.weight (σ.map e.toEmbedding)
  weight_empty := by simpa using F.weight_empty
  weight_mono := fun {σ τ} h => F.weight_mono (Finset.map_subset_map.mpr h)

@[simp] theorem comap_weight (e : α ≃ β) (F : Filtration β) (σ : Finset α) :
    (comap e F).weight σ = F.weight (σ.map e.toEmbedding) := rfl

/-! ## Shift commutes with relabeling -/

/-- **`shift_comap`.**  Relabeling commutes with shift: smoothing then relabeling
equals relabeling then smoothing. -/
theorem shift_comap (e : α ≃ β) (a : ℝ) (ha : 0 ≤ a) (F : Filtration β) :
    comap e (shift a ha F) = shift a ha (comap e F) :=
  filtration_ext rfl

/-! ## Interleaving is invariant under relabeling -/

/-- **`Interleaved_comap_iff`.**  Relabeling along an equivalence does not change
which shifts interleave two filtrations. -/
theorem Interleaved_comap_iff (e : α ≃ β) (F G : Filtration β) (δ : ℝ) :
    Interleaved (comap e F) (comap e G) δ ↔ Interleaved F G δ := by
  simp +decide [ Filtration.sublevelFaces, Filtration.Interleaved, comap ];
  intro hδ;
  constructor <;> intro h;
  · constructor <;> intro t a ha;
    · convert h.1 t ( Finset.map e.symm.toEmbedding a ) _;
      · ext x; simp +decide ;
      · convert ha using 2;
        ext x; simp +decide ;
    · convert h.2 t ( Finset.map e.symm.toEmbedding a ) _;
      · simp +decide [ Finset.map_map ];
      · convert ha using 2 ; aesop;
  · exact ⟨ fun t a ha => h.1 t _ ha, fun t a ha => h.2 t _ ha ⟩

/-- **`interleavingDist_comap`.**  The (real) interleaving distance is invariant
under relabeling by an equivalence. -/
theorem interleavingDist_comap (e : α ≃ β) (F G : Filtration β) :
    interleavingDist (comap e F) (comap e G) = interleavingDist F G := by
  unfold interleavingDist
  congr 1
  ext δ
  exact Interleaved_comap_iff e F G δ

/-- **`eInterleavingDist_comap`.**  The `ℝ≥0∞`-valued interleaving distance is
invariant under relabeling by an equivalence. -/
theorem eInterleavingDist_comap (e : α ≃ β) (F G : Filtration β) :
    eInterleavingDist (comap e F) (comap e G) = eInterleavingDist F G := by
  unfold BoltzmannBridge.Filtration.eInterleavingDist;
  convert rfl; all_goals ext; simp [Interleaved_comap_iff]

/-! ## Quotient transport -/

/-- The pseudo-emetric structure of `InterleavingMetric`, made a file-local
instance so the `SeparationQuotient` machinery applies, exactly as in
`InterleavingQuotient`. -/
noncomputable local instance interleavingPseudoEMetricInst :
    PseudoEMetricSpace (Filtration α) :=
  interleavingPseudoEMetric

/-- **`edist_mk_comap`.**  Relabeling invariance descends to the separation
quotient: the genuine extended distance between the classes of two relabeled
filtrations equals that of the originals. -/
theorem edist_mk_comap (e : α ≃ β) (F G : Filtration β) :
    edist (SeparationQuotient.mk (comap e F)) (SeparationQuotient.mk (comap e G))
      = edist (SeparationQuotient.mk F) (SeparationQuotient.mk G) := by
  rw [SeparationQuotient.edist_mk, SeparationQuotient.edist_mk]
  exact eInterleavingDist_comap e F G

/-! ## The bundled transport principle -/

/-- **Transport principle (relabeling).**  Any exact self-shift-distance statement
for a filtration `F` transfers verbatim to every relabeling `comap e F`. -/
theorem selfShiftDist_comap (e : α ≃ β) (a : ℝ) (ha : 0 ≤ a) (F : Filtration β)
    (h : interleavingDist F (shift a ha F) = a) :
    interleavingDist (comap e F) (shift a ha (comap e F)) = a := by
  rw [← shift_comap e a ha F, interleavingDist_comap]
  exact h

/-- **Transport principle (quotient image).**  Any exact self-shift-distance
statement in the `ℝ≥0∞` interleaving geometry transfers to the
separation-quotient classes of the relabeled filtration. -/
theorem eSelfShiftDist_transport (e : α ≃ β) (a : ℝ) (ha : 0 ≤ a) (F : Filtration β)
    {d : ℝ≥0∞} (h : eInterleavingDist F (shift a ha F) = d) :
    edist (SeparationQuotient.mk (comap e F))
        (SeparationQuotient.mk (shift a ha (comap e F)))
      = d := by
  rw [← shift_comap e a ha F, SeparationQuotient.edist_mk]
  exact (eInterleavingDist_comap e F (shift a ha F)).trans h

end Bridges.CategoricalTropicalRips