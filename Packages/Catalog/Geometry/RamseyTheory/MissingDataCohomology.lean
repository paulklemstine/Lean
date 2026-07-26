import Mathlib
import Geometry.RamseyTheory.FlagComplex

/-!
# Cohomological obstructions to patching incomplete data

Local observations and their overlap discrepancies form a two-step cochain
complex.  Degree-zero cocycles are globally compatible observations, while the
first cohomology is the quotient of locally consistent discrepancies by those
arising from changing local observations.  The results below give a rank formula,
a patchability criterion, and sharp boundary cases.  They also identify the
nerve's flag condition as the precise passage from pairwise overlap consistency
to higher-order faces.

-- !-- Lab Notes -- !--
Hypothesis: the obstruction space is controlled by two independent rank losses,
not by the missing rate alone; pairwise overlap data determines all higher overlap
patterns exactly when the nerve is flag.
Experiment: zero differentials give obstruction dimension `dim C¹`, whereas a
surjective first coboundary gives dimension zero at the same ambient degree.
Analysis: rank-nullity and the quotient dimension formula show
`dim H¹ = dim C¹ - rank δ⁰ - rank δ¹`.  Thus no universal function of a scalar
missing rate can determine obstruction dimension without assumptions on overlap
incidence and restriction-map ranks.
Critique: these are deterministic finite-dimensional results.  They do not justify
a probabilistic asymptotic law, a likelihood interpretation, or comparisons with
particular statistical estimators; each requires an explicit generative model.
Synthesis: the rank formula separates the two sources of information loss, the
vanishing theorem characterizes exact patchability, and the imported clique-complex
construction links pairwise consistency to the topology of the data nerve.
-- !-- Lab Notes -- !--
-/

open Finset

namespace MissingDataCohomology

variable (𝕜 : Type*) [Field 𝕜]

/-- A finite two-step cochain complex modelling local observations (`C⁰`), overlap
residuals (`C¹`), and triple-overlap consistency checks (`C²`). -/
structure DataComplex where
  C0 : Type*
  C1 : Type*
  C2 : Type*
  [addC0 : AddCommGroup C0]
  [addC1 : AddCommGroup C1]
  [addC2 : AddCommGroup C2]
  [modC0 : Module 𝕜 C0]
  [modC1 : Module 𝕜 C1]
  [modC2 : Module 𝕜 C2]
  [finC0 : FiniteDimensional 𝕜 C0]
  [finC1 : FiniteDimensional 𝕜 C1]
  [finC2 : FiniteDimensional 𝕜 C2]
  d0 : C0 →ₗ[𝕜] C1
  d1 : C1 →ₗ[𝕜] C2
  d_sq : d1.comp d0 = 0

attribute [instance] DataComplex.addC0 DataComplex.addC1 DataComplex.addC2
  DataComplex.modC0 DataComplex.modC1 DataComplex.modC2 DataComplex.finC0
  DataComplex.finC1 DataComplex.finC2

variable {𝕜}

/-
Every coboundary is a cocycle.
-/
lemma DataComplex.range_d0_le_ker_d1 (D : DataComplex 𝕜) : D.d0.range ≤ D.d1.ker := by
  exact fun x hx => by obtain ⟨ y, rfl ⟩ := hx; exact LinearMap.mem_ker.2 ( LinearMap.congr_fun D.d_sq y ) ;

/-- Boundaries viewed as a subspace of the cocycle space. -/
def DataComplex.boundaries (D : DataComplex 𝕜) : Submodule 𝕜 D.d1.ker :=
  D.d0.range.comap D.d1.ker.subtype

/-- Degree-zero cohomology: globally compatible local observations. -/
abbrev DataComplex.H0 (D : DataComplex 𝕜) := D.d0.ker

/-- First cohomology: locally consistent overlap residuals modulo changes of
local observations. -/
abbrev DataComplex.H1 (D : DataComplex 𝕜) := D.d1.ker ⧸ D.boundaries

/-- The boundary subspace has the same dimension as the range of the first
coboundary. -/
lemma DataComplex.finrank_boundaries (D : DataComplex 𝕜) :
    Module.finrank 𝕜 D.boundaries = Module.finrank 𝕜 D.d0.range := by
  have hmap : Submodule.map D.d1.ker.subtype D.boundaries = D.d0.range := by
    ext x
    constructor
    · rintro ⟨y, hy, rfl⟩
      exact hy
    · intro hx
      let y : D.d1.ker := ⟨x, D.range_d0_le_ker_d1 hx⟩
      exact ⟨y, hx, rfl⟩
  rw [← hmap, Submodule.finrank_map_subtype_eq]

/-
**Cohomological information-loss formula.**  The obstruction dimension is
ambient overlap dimension minus the ranks of patch generation and consistency
checking.
-/
theorem DataComplex.finrank_H1_formula (D : DataComplex 𝕜) :
    Module.finrank 𝕜 D.H1 + Module.finrank 𝕜 D.d0.range +
        Module.finrank 𝕜 D.d1.range = Module.finrank 𝕜 D.C1 := by
  have := Submodule.finrank_quotient_add_finrank ( D.boundaries );
  have := LinearMap.finrank_range_add_finrank_ker ( D.d1 );
  linarith! [ D.finrank_boundaries ]

/-
Vanishing of first cohomology is equivalent to every cocycle being generated
by a degree-zero correction.
-/
theorem DataComplex.h1_vanishes_iff_exact (D : DataComplex 𝕜) :
    Module.finrank 𝕜 D.H1 = 0 ↔ D.d1.ker = D.d0.range := by
  constructor <;> intro h;
  · -- If the finrank of H1 is zero, then the boundaries are equal to the cocycles.
    have h_eq : D.boundaries = ⊤ := by
      exact Submodule.eq_top_of_finrank_eq ( by simpa [ h ] using Submodule.finrank_quotient_add_finrank D.boundaries );
    refine' le_antisymm _ _;
    · intro x hx;
      replace h_eq := SetLike.ext_iff.mp h_eq ⟨ x, hx ⟩ ; aesop;
    · exact DataComplex.range_d0_le_ker_d1 D;
  · convert Submodule.finrank_eq_zero.mpr _;
    rotate_left;
    exact 𝕜;
    exact D.H1;
    all_goals try infer_instance;
    exact ⊤;
    · infer_instance;
    · ext x;
      obtain ⟨ y, hy ⟩ := Submodule.mkQ_surjective _ x;
      simp +decide [← hy];
      exact Submodule.mem_comap.mpr ( h ▸ y.2 );
    · simp +decide [ DataComplex.H1 ]

/-
A strict rank deficit forces a nonzero patching obstruction.
-/
theorem DataComplex.h1_positive_of_rank_deficit (D : DataComplex 𝕜)
    (h : Module.finrank 𝕜 D.d0.range + Module.finrank 𝕜 D.d1.range <
      Module.finrank 𝕜 D.C1) :
    0 < Module.finrank 𝕜 D.H1 := by
  linarith [ D.finrank_H1_formula ]

/-
If the first coboundary is surjective, every locally consistent discrepancy
is patchable and first cohomology vanishes.
-/
theorem DataComplex.h1_vanishes_of_surjective_d0 (D : DataComplex 𝕜)
    (h : Function.Surjective D.d0) : Module.finrank 𝕜 D.H1 = 0 := by
  -- Since the range of $D.d0$ is the entire space $D.C1$, the kernel of $D.d1$ must also be the entire space $D.C1$.
  have h_ker : D.d1.ker = ⊤ := by
    have := D.d_sq; simp_all +decide [ LinearMap.ext_iff, SetLike.ext_iff ] ;
    exact fun x => by obtain ⟨ y, rfl ⟩ := h x; exact this y;
  rw [ D.h1_vanishes_iff_exact ];
  rw [ h_ker, LinearMap.range_eq_top.mpr h ]

/-
For zero differentials, every overlap residual survives as an obstruction.
This boundary case shows that ambient dimensions or a missing-rate scalar alone
cannot determine cohomology.
-/
theorem DataComplex.h1_full_of_zero_maps (D : DataComplex 𝕜)
    (h0 : D.d0 = 0) (h1 : D.d1 = 0) :
    Module.finrank 𝕜 D.H1 = Module.finrank 𝕜 D.C1 := by
  have := D.finrank_H1_formula; simp_all +decide [ Module.finrank ] ;
  rw [ ← this, h0 ] ; simp +decide [ h1 ] ;

/-
**Non-identifiability from a scalar rate.**  Two data complexes can have
identically sized overlap spaces but different obstruction dimensions: zero
restriction maps retain every residual, while a surjective patch map removes
every obstruction.
-/
theorem DataComplex.obstruction_not_determined_by_overlap_dimension
    (D E : DataComplex 𝕜)
    (hd0 : D.d0 = 0) (hd1 : D.d1 = 0)
    (he : Function.Surjective E.d0)
    (hdim : Module.finrank 𝕜 D.C1 = Module.finrank 𝕜 E.C1)
    (hpos : 0 < Module.finrank 𝕜 D.C1) :
    Module.finrank 𝕜 D.H1 ≠ Module.finrank 𝕜 E.H1 := by
  rw [ DataComplex.h1_full_of_zero_maps, DataComplex.h1_vanishes_of_surjective_d0 ] <;> simp_all +decide;
  linarith

section Nerve

variable {α : Type*} [DecidableEq α]

/-- In a flag data nerve, pairwise-compatible local charts span a genuine
higher-order overlap face.  This anchors the obstruction complex in the clique
complex of its overlap graph. -/
theorem pairwise_compatible_forms_overlap_face (K : ASC α) (hK : IsFlag K)
    (s : Finset α)
    (hpair : ∀ ⦃a⦄, a ∈ s → ∀ ⦃b⦄, b ∈ s → a ≠ b → (oneSkel K).Adj a b) :
    s ∈ K.faces := by
  exact hK s hpair

/-- Equivalently, a flag nerve is recovered exactly from pairwise overlap data. -/
theorem flag_nerve_recovered_from_pairwise_overlaps (K : ASC α) (hK : IsFlag K) :
    K.faces = (cliqueComplex (oneSkel K)).faces := by
  exact IsFlag.eq_cliqueComplex K hK

end Nerve

end MissingDataCohomology