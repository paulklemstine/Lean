import Mathlib
import Geometry.MissingDataCohomology

/-!
# The Čech complex of a database, and its acyclicity

A database with `n` columns whose rows observe the column sets `U j` is a
`0`-cochain of the Čech complex of the cover `U` with coefficients in the data
sheaf `F(V) = {f : columns → 𝕜 | f vanishes off V}`. This file constructs that
complex as an instance of the catalog's `MissingDataCohomology.DataComplex` and
proves:

* `ker_d0_eq_range_glue` and `finrank_H0` — degree-zero cohomology is exactly the
  space of *complete* databases: `H⁰ ≃ (columns → 𝕜)`, of dimension `n`;
* `h1_vanishes` — the first Čech cohomology of the data sheaf vanishes for
  **every** cover: the data sheaf is acyclic (it is flasque), so a family of
  local records that is consistent on overlaps always glues, and the only
  obstruction to imputation is failure of pairwise consistency;
* `finrank_H1_eq_zero` — the same statement in the catalog's rank formalism,
  so the catalog's obstruction formula `dim H¹ = dim C¹ - rank d⁰ - rank d¹`
  specialises to a genuine rank identity for databases.

Combined with `Catalog/Computation/DatabaseSheafGluing.lean` this closes the
sheaf-cohomological picture: gluing has no higher obstruction, hence "data
imputation is a sheaf cohomology problem" is true only in degree `0`; `H¹` is
identically zero, so no cohomological quantity can measure imputation
difficulty for the data sheaf.

-- !-- Lab Notes -- !--
Hypothesis: missing-data imputation is governed by a nonvanishing first sheaf
cohomology.
Experiment: build the ordered Čech complex of an arbitrary finite cover with
coefficients in the data sheaf, inside the catalog's `DataComplex` structure,
and compute `H⁰` and `H¹`.
Analysis: `H⁰` is the space of complete databases (dimension `n`, the number of
columns), and `H¹ = 0` for every cover, because the data sheaf is flasque: an
explicit chosen index `σ c` for each column produces a primitive of any cocycle.
Critique: this is exactly the constant-coefficient (flasque) case. A nonvanishing
`H¹` requires coefficients with nontrivial restriction maps, e.g. quotient or
constraint sheaves, which is where a genuinely cohomological imputation theory
must live.
Synthesis: for databases the Čech obstruction is concentrated in degree zero;
`H¹ = 0` is a theorem, not an assumption.
-- !-- Lab Notes -- !--
-/

open Finset MissingDataCohomology

namespace DatabaseCech

variable {𝕜 : Type*} [Field 𝕜] {n k : ℕ}

/-- Sections of the data sheaf over the column set `V`: functions vanishing off
`V`. -/
def Sec (𝕜 : Type*) [Field 𝕜] {n : ℕ} (V : Finset (Fin n)) : Submodule 𝕜 (Fin n → 𝕜) where
  carrier := {f | ∀ c ∉ V, f c = 0}
  add_mem' := by
    intro f g hf hg c hc
    simp [hf c hc, hg c hc]
  zero_mem' := by intro c _; rfl
  smul_mem' := by
    intro a f hf c hc
    simp [hf c hc]

@[simp] lemma mem_Sec {V : Finset (Fin n)} {f : Fin n → 𝕜} :
    f ∈ Sec 𝕜 V ↔ ∀ c ∉ V, f c = 0 := Iff.rfl

/-- Restriction of a global function to a column set. -/
def restr (𝕜 : Type*) [Field 𝕜] {n : ℕ} (V : Finset (Fin n)) :
    (Fin n → 𝕜) →ₗ[𝕜] Sec 𝕜 V where
  toFun f := ⟨fun c => if c ∈ V then f c else 0, by
    intro c hc; simp [hc]⟩
  map_add' f g := by
    apply Subtype.ext; funext c
    by_cases hc : c ∈ V <;> simp [hc]
  map_smul' a f := by
    apply Subtype.ext; funext c
    by_cases hc : c ∈ V <;> simp [hc]

@[simp] lemma restr_apply (V : Finset (Fin n)) (f : Fin n → 𝕜) (c : Fin n) :
    ((restr 𝕜 V f : Fin n → 𝕜)) c = if c ∈ V then f c else 0 := rfl

variable (U : Fin k → Finset (Fin n))

/-- Degree-zero Čech cochains: one local record per row. -/
abbrev C0 := (j : Fin k) → Sec 𝕜 (U j)

/-- Degree-one Čech cochains: one discrepancy per ordered pair of rows. -/
abbrev C1 := (p : Fin k × Fin k) → Sec 𝕜 (U p.1 ∩ U p.2)

/-- Degree-two Čech cochains. -/
abbrev C2 := (p : Fin k × Fin k × Fin k) → Sec 𝕜 (U p.1 ∩ U p.2.1 ∩ U p.2.2)

/-- The Čech coboundary `(d⁰ s)_{jj'} = s_j - s_{j'}` on the overlap. -/
def d0 : C0 (𝕜 := 𝕜) U →ₗ[𝕜] C1 (𝕜 := 𝕜) U :=
  LinearMap.pi fun p =>
    (restr 𝕜 (U p.1 ∩ U p.2)).comp
      ((Sec 𝕜 (U p.1)).subtype.comp (LinearMap.proj p.1)
        - (Sec 𝕜 (U p.2)).subtype.comp (LinearMap.proj p.2))

/-- The Čech coboundary `(d¹ t)_{abc} = t_{bc} - t_{ac} + t_{ab}`. -/
def d1 : C1 (𝕜 := 𝕜) U →ₗ[𝕜] C2 (𝕜 := 𝕜) U :=
  LinearMap.pi fun p =>
    (restr 𝕜 (U p.1 ∩ U p.2.1 ∩ U p.2.2)).comp
      ((Sec 𝕜 (U p.2.1 ∩ U p.2.2)).subtype.comp (LinearMap.proj (p.2.1, p.2.2))
        - (Sec 𝕜 (U p.1 ∩ U p.2.2)).subtype.comp (LinearMap.proj (p.1, p.2.2))
        + (Sec 𝕜 (U p.1 ∩ U p.2.1)).subtype.comp (LinearMap.proj (p.1, p.2.1)))

@[simp] lemma d0_apply (s : C0 (𝕜 := 𝕜) U) (p : Fin k × Fin k) (c : Fin n) :
    ((d0 U s p : Fin n → 𝕜)) c =
      if c ∈ U p.1 ∩ U p.2 then (s p.1 : Fin n → 𝕜) c - (s p.2 : Fin n → 𝕜) c else 0 := rfl

@[simp] lemma d1_apply (t : C1 (𝕜 := 𝕜) U) (p : Fin k × Fin k × Fin k) (c : Fin n) :
    ((d1 U t p : Fin n → 𝕜)) c =
      if c ∈ U p.1 ∩ U p.2.1 ∩ U p.2.2 then
        (t (p.2.1, p.2.2) : Fin n → 𝕜) c - (t (p.1, p.2.2) : Fin n → 𝕜) c
          + (t (p.1, p.2.1) : Fin n → 𝕜) c
      else 0 := rfl

lemma d_sq : (d1 (𝕜 := 𝕜) U).comp (d0 (𝕜 := 𝕜) U) = 0 := by
  apply LinearMap.ext
  intro s
  funext p
  apply Subtype.ext
  funext c
  simp only [LinearMap.comp_apply, LinearMap.zero_apply]
  have hzero : (((0 : C2 (𝕜 := 𝕜) U) p : Fin n → 𝕜)) c = 0 := rfl
  by_cases h : c ∈ U p.1 ∩ U p.2.1 ∩ U p.2.2
  · have h1 : c ∈ U p.1 := (Finset.mem_inter.1 (Finset.mem_inter.1 h).1).1
    have h2 : c ∈ U p.2.1 := (Finset.mem_inter.1 (Finset.mem_inter.1 h).1).2
    have h3 : c ∈ U p.2.2 := (Finset.mem_inter.1 h).2
    rw [d1_apply, if_pos h, d0_apply, d0_apply, d0_apply,
      if_pos (Finset.mem_inter.2 ⟨h2, h3⟩), if_pos (Finset.mem_inter.2 ⟨h1, h3⟩),
      if_pos (Finset.mem_inter.2 ⟨h1, h2⟩), hzero]
    ring
  · rw [d1_apply, if_neg h, hzero]

/-- The Čech complex of the cover `U` with coefficients in the data sheaf, as an
object of the catalog's `MissingDataCohomology.DataComplex`. -/
def cechComplex : DataComplex 𝕜 where
  C0 := C0 (𝕜 := 𝕜) U
  C1 := C1 (𝕜 := 𝕜) U
  C2 := C2 (𝕜 := 𝕜) U
  d0 := d0 U
  d1 := d1 U
  d_sq := d_sq U

/-! ### Degree zero: compatible families are complete databases -/

/-- The map sending a complete database to its family of local records. -/
def glue : (Fin n → 𝕜) →ₗ[𝕜] C0 (𝕜 := 𝕜) U :=
  LinearMap.pi fun j => restr 𝕜 (U j)

@[simp] lemma glue_apply (g : Fin n → 𝕜) (j : Fin k) (c : Fin n) :
    ((glue U g j : Fin n → 𝕜)) c = if c ∈ U j then g c else 0 := rfl

/-- **Sheaf condition in degree zero.** The kernel of the Čech coboundary is
exactly the image of the complete databases: a family of local records that is
consistent on all overlaps comes from a single global row. -/
theorem ker_d0_eq_range_glue (hU : ∀ c : Fin n, ∃ j, c ∈ U j) :
    LinearMap.ker (d0 (𝕜 := 𝕜) U) = LinearMap.range (glue (𝕜 := 𝕜) U) := by
  classical
  apply le_antisymm
  · intro s hs
    have hs' : ∀ (p : Fin k × Fin k) (c : Fin n), c ∈ U p.1 ∩ U p.2 →
        (s p.1 : Fin n → 𝕜) c = (s p.2 : Fin n → 𝕜) c := by
      intro p c hc
      have h := congrFun (congrArg Subtype.val (congrFun (LinearMap.mem_ker.1 hs) p)) c
      rw [d0_apply, if_pos hc] at h
      have h0 : (((0 : C1 (𝕜 := 𝕜) U) p : Fin n → 𝕜)) c = 0 := rfl
      rw [h0, sub_eq_zero] at h
      exact h
    choose σ hσ using hU
    refine ⟨fun c => (s (σ c) : Fin n → 𝕜) c, ?_⟩
    funext j
    apply Subtype.ext
    funext c
    by_cases hc : c ∈ U j
    · simp only [glue_apply, hc, if_true]
      exact hs' (σ c, j) c (Finset.mem_inter.2 ⟨hσ c, hc⟩)
    · simp only [glue_apply, hc, if_false]
      exact ((s j).2 c hc).symm
  · rintro _ ⟨g, rfl⟩
    apply LinearMap.mem_ker.2
    funext p
    apply Subtype.ext
    funext c
    by_cases hc : c ∈ U p.1 ∩ U p.2
    · have h1 : c ∈ U p.1 := (Finset.mem_inter.1 hc).1
      have h2 : c ∈ U p.2 := (Finset.mem_inter.1 hc).2
      simp [d0_apply, hc, h1, h2]
    · simp [d0_apply, hc]

/-- `glue` is injective when the rows really cover all columns. -/
theorem glue_injective (hU : ∀ c : Fin n, ∃ j, c ∈ U j) :
    Function.Injective (glue (𝕜 := 𝕜) U) := by
  intro g g' h
  funext c
  obtain ⟨j, hj⟩ := hU c
  have := congrFun (congrArg Subtype.val (congrFun h j)) c
  simpa [glue_apply, hj] using this

/-- **`H⁰` is the space of complete databases**: its dimension is the number of
columns, independently of the number of rows and of the cover. -/
theorem finrank_H0 (hU : ∀ c : Fin n, ∃ j, c ∈ U j) :
    Module.finrank 𝕜 (LinearMap.ker (d0 (𝕜 := 𝕜) U)) = n := by
  classical
  rw [ker_d0_eq_range_glue U hU]
  rw [LinearMap.finrank_range_of_inj (glue_injective U hU)]
  simp

/-! ### Degree one: the data sheaf is acyclic -/

/-- **Vanishing of the first Čech cohomology.** For every cover of the columns
by the observed supports of the rows, every `1`-cocycle of the data sheaf is a
coboundary. Equivalently: pairwise overlap discrepancies never obstruct
imputation beyond their own consistency. -/
theorem h1_vanishes (hU : ∀ c : Fin n, ∃ j, c ∈ U j) :
    LinearMap.ker (d1 (𝕜 := 𝕜) U) = LinearMap.range (d0 (𝕜 := 𝕜) U) := by
  classical
  apply le_antisymm
  · intro t ht
    have hcocyc : ∀ (a b d : Fin k) (c : Fin n), c ∈ U a → c ∈ U b → c ∈ U d →
        (t (b, d) : Fin n → 𝕜) c - (t (a, d) : Fin n → 𝕜) c
          + (t (a, b) : Fin n → 𝕜) c = 0 := by
      intro a b d c ha hb hd
      have hmem : c ∈ U a ∩ U b ∩ U d :=
        Finset.mem_inter.2 ⟨Finset.mem_inter.2 ⟨ha, hb⟩, hd⟩
      have h := congrFun (congrArg Subtype.val
        (congrFun (LinearMap.mem_ker.1 ht) (a, b, d))) c
      rw [d1_apply, if_pos hmem] at h
      exact h
    choose σ hσ using hU
    -- the primitive: `s_j (c) = t_{j, σ c} (c)`
    refine ⟨fun j => ⟨fun c => if c ∈ U j then (t (j, σ c) : Fin n → 𝕜) c else 0, by
      intro c hc; simp [hc]⟩, ?_⟩
    funext p
    apply Subtype.ext
    funext c
    by_cases hc : c ∈ U p.1 ∩ U p.2
    · have h1 : c ∈ U p.1 := (Finset.mem_inter.1 hc).1
      have h2 : c ∈ U p.2 := (Finset.mem_inter.1 hc).2
      have hsc : c ∈ U (σ c) := hσ c
      -- antisymmetry of `t` on overlaps
      have hanti : ∀ a b : Fin k, c ∈ U a → c ∈ U b →
          (t (b, a) : Fin n → 𝕜) c = - (t (a, b) : Fin n → 𝕜) c := by
        intro a b ha hb
        have h₁ := hcocyc a b a c ha hb ha
        have h₂ := hcocyc a a a c ha ha ha
        have h₃ : (t (a, a) : Fin n → 𝕜) c = 0 := by linear_combination h₂
        linear_combination h₁ + h₃
      have hkey := hcocyc p.1 (σ c) p.2 c h1 hsc h2
      have hanti' := hanti (σ c) p.2 hsc h2
      rw [d0_apply, if_pos hc]
      show (if c ∈ U p.1 then (t (p.1, σ c) : Fin n → 𝕜) c else 0)
          - (if c ∈ U p.2 then (t (p.2, σ c) : Fin n → 𝕜) c else 0) = _
      rw [if_pos h1, if_pos h2]
      linear_combination hkey - hanti'
    · rw [d0_apply, if_neg hc]
      exact ((t p).2 c hc).symm
  · rintro _ ⟨s, rfl⟩
    exact LinearMap.mem_ker.2 (LinearMap.congr_fun (d_sq U) s)

/-- The catalog's obstruction dimension vanishes for the database Čech complex:
`dim H¹ = 0` for every cover. -/
theorem finrank_H1_eq_zero (hU : ∀ c : Fin n, ∃ j, c ∈ U j) :
    Module.finrank 𝕜 (cechComplex (𝕜 := 𝕜) U).H1 = 0 :=
  (DataComplex.h1_vanishes_iff_exact _).2 (h1_vanishes U hU)

/-- Consequently the catalog's rank formula becomes a pure rank identity for
databases: the overlap space is exactly the sum of the two coboundary ranks. -/
theorem rank_identity (hU : ∀ c : Fin n, ∃ j, c ∈ U j) :
    Module.finrank 𝕜 (LinearMap.range (d0 (𝕜 := 𝕜) U))
        + Module.finrank 𝕜 (LinearMap.range (d1 (𝕜 := 𝕜) U))
      = Module.finrank 𝕜 (C1 (𝕜 := 𝕜) U) := by
  have h := (cechComplex (𝕜 := 𝕜) U).finrank_H1_formula
  rw [finrank_H1_eq_zero U hU] at h
  simpa using h

end DatabaseCech