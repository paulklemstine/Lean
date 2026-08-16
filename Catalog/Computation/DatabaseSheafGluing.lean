import Mathlib

/-!
# When does a database with missing entries glue?

A database with missing entries is a *partial section* of the constant data
sheaf on the cover of the column set by the observed supports of its rows.
This file makes that statement precise for finite databases and proves:

* `gluable_iff_pairwise` — the sheaf (gluing) condition holds **iff** the rows
  agree pairwise on their overlaps: for the constant data sheaf there is no
  higher obstruction, the Čech `H¹`-type obstruction is entirely pairwise;
* `card_sections` — when the database glues, the space of global sections has
  exactly `q ^ (#unobserved columns)` elements, so the sheaf-theoretic degrees of
  freedom are located precisely at the fully unobserved columns;
* `masked_gluable` — a database obtained by masking a ground-truth row always
  glues, whatever the mask: under an MCAR generative model the sheaf condition
  holds with probability one, contradicting any law of the shape `(1-r)^{C}`
  with `C > 0`;
* `sheaf_imputation_exact` — sheaf imputation recovers the ground truth exactly
  when every column is observed at least once;
* `mean_imputation_eq_sheaf_imputation` — for a real-valued gluable database,
  column-mean imputation returns *the same* value as sheaf imputation. Hence the
  conjectured strict superiority of sheaf imputation over mean imputation is
  false for the constant sheaf; any advantage must come from nontrivial
  restriction maps.

-- !-- Lab Notes -- !--
Hypothesis (assignment): `P(sheaf) = (1-r)^{C(n,k)}`, and sheaf imputation beats
mean imputation for `r < 1/2`, `n > 10`.
Experiment: formalise the database sheaf, characterise gluability, count global
sections, and evaluate the two imputation rules on gluable data.
Analysis: gluability is a purely *columnwise, pairwise* condition; the section
space is a torsor of size `q ^ (unobserved columns)`. Masking a ground truth can
never destroy gluability, so the conjectured decay in the missing rate has the
wrong sign already at the deterministic level. On gluable real data the observed
entries of a column are all equal, so their mean *is* the sheaf value: the two
imputation rules coincide identically.
Critique: these results concern the constant sheaf `c ↦ values`. They do not
refute superiority claims for sheaves with nontrivial restriction maps; they
delimit exactly where such a claim could live.
Synthesis: gluing = pairwise columnwise agreement; obstruction = a disagreeing
pair; freedom = unobserved columns; and for the constant sheaf the sheaf-optimal
imputation is classical mean imputation.
-- !-- Lab Notes -- !--
-/

open Finset

namespace DatabaseSheaf

variable {k n q : ℕ}

/-- A partial database with `k` rows and `n` columns, entries in `Fin q`;
`none` marks a missing entry. -/
abbrev PartialDB (k n q : ℕ) := Fin k → Fin n → Option (Fin q)

/-- `g` is a global section of the database `D`: a complete row restricting to
every observed entry of every row. -/
def IsSection (D : PartialDB k n q) (g : Fin n → Fin q) : Prop :=
  ∀ j c v, D j c = some v → g c = v

/-- The sheaf (gluing) condition: the partial section extends to a global one. -/
def Gluable (D : PartialDB k n q) : Prop := ∃ g, IsSection D g

/-- Rows agree pairwise on overlaps. -/
def PairwiseConsistent (D : PartialDB k n q) : Prop :=
  ∀ j j' c v v', D j c = some v → D j' c = some v' → v = v'

/-- The columns that are observed by at least one row. -/
def observed (D : PartialDB k n q) : Finset (Fin n) :=
  {c | ∃ j, (D j c).isSome}

lemma mem_observed {D : PartialDB k n q} {c : Fin n} :
    c ∈ observed D ↔ ∃ j v, D j c = some v := by
  simp [observed, Option.isSome_iff_exists]

/-- The admissible values at a single column: those compatible with every
observed entry in that column. -/
def colValues (D : PartialDB k n q) (c : Fin n) : Finset (Fin q) :=
  {v | ∀ j v', D j c = some v' → v = v'}

/-- The finset of all global sections of `D`. It is a product set: the sheaf
condition is *columnwise*. -/
def sections (D : PartialDB k n q) : Finset (Fin n → Fin q) :=
  Fintype.piFinset (colValues D)

lemma mem_colValues {D : PartialDB k n q} {c : Fin n} {v : Fin q} :
    v ∈ colValues D c ↔ ∀ j v', D j c = some v' → v = v' := by
  simp [colValues]

@[simp] lemma mem_sections {D : PartialDB k n q} {g : Fin n → Fin q} :
    g ∈ sections D ↔ IsSection D g := by
  simp only [sections, Fintype.mem_piFinset, mem_colValues, IsSection]
  exact ⟨fun h j c v hv => h c j v hv, fun h c j v hv => h j c v hv⟩

/-! ### Gluing: pairwise consistency is the whole obstruction -/

/-- **Gluing theorem for the database sheaf.** A partial database glues to a
global section iff its rows agree pairwise on overlaps. No higher (triple
overlap) condition appears: for the constant data sheaf the obstruction to
gluing is exactly a disagreeing pair of entries in one column. -/
theorem gluable_iff_pairwise [NeZero q] (D : PartialDB k n q) :
    Gluable D ↔ PairwiseConsistent D := by
  constructor
  · rintro ⟨g, hg⟩ j j' c v v' hv hv'
    rw [← hg j c v hv, hg j' c v' hv']
  · intro h
    classical
    refine ⟨fun c => if hc : ∃ p : Fin k × Fin q, D p.1 c = some p.2 then hc.choose.2
      else default, ?_⟩
    intro j c v hv
    have hc : ∃ p : Fin k × Fin q, D p.1 c = some p.2 := ⟨(j, v), hv⟩
    simp only [dif_pos hc]
    exact h hc.choose.1 j c hc.choose.2 v hc.choose_spec hv

/-- Gluability is equivalent to every column admitting at least one value. -/
theorem gluable_iff_colValues_nonempty (D : PartialDB k n q) :
    Gluable D ↔ ∀ c, (colValues D c).Nonempty := by
  constructor
  · rintro ⟨g, hg⟩ c
    exact ⟨g c, mem_colValues.2 fun j v hv => hg j c v hv⟩
  · intro h
    choose g hg using h
    exact ⟨g, fun j c v hv => (mem_colValues.1 (hg c)) j v hv⟩

/-! ### Counting global sections -/

/-- An unobserved column is completely free. -/
lemma colValues_of_not_observed {D : PartialDB k n q} {c : Fin n}
    (hc : c ∉ observed D) : colValues D c = Finset.univ := by
  ext v
  simp only [mem_colValues, Finset.mem_univ, iff_true]
  intro j v' hv'
  exact absurd (mem_observed.2 ⟨j, v', hv'⟩) hc

/-- An observed column of a gluable database is rigid: exactly one value. -/
lemma card_colValues_of_observed {D : PartialDB k n q} {c : Fin n}
    (hc : c ∈ observed D) (hcons : PairwiseConsistent D) :
    (colValues D c).card = 1 := by
  obtain ⟨j, v, hv⟩ := mem_observed.1 hc
  refine Finset.card_eq_one.2 ⟨v, ?_⟩
  ext w
  simp only [mem_colValues, Finset.mem_singleton]
  exact ⟨fun h => h j v hv, fun h j' v' hv' => h.trans (hcons j j' c v v' hv hv')⟩

/-- **Dimension of the section space.** For a pairwise consistent database the
global sections form a set of size `q ^ (#unobserved columns)`: the sheaf pins
down every observed column and leaves the unobserved ones entirely free. -/
theorem card_sections (D : PartialDB k n q) (hcons : PairwiseConsistent D) :
    (sections D).card = q ^ (n - (observed D).card) := by
  classical
  rw [sections, Fintype.card_piFinset, ← Finset.prod_mul_prod_compl (observed D)]
  have h1 : ∏ c ∈ observed D, (colValues D c).card = 1 :=
    Finset.prod_eq_one fun c hc => card_colValues_of_observed hc hcons
  have h2 : ∏ c ∈ (observed D)ᶜ, (colValues D c).card = q ^ ((observed D)ᶜ).card := by
    rw [Finset.prod_congr rfl (fun c hc => by
      rw [colValues_of_not_observed (Finset.mem_compl.1 hc), Finset.card_univ,
        Fintype.card_fin])]
    simp
  rw [h1, h2, one_mul, Finset.card_compl, Fintype.card_fin]

/-! ### Masking a ground truth, and imputation -/

/-- The database obtained by masking a ground-truth row `g` with an arbitrary
observation pattern `mask`. -/
def masked (g : Fin n → Fin q) (mask : Fin k → Fin n → Bool) : PartialDB k n q :=
  fun j c => if mask j c then some (g c) else none

/-- **Masking never breaks the sheaf condition.** Under any MCAR (indeed any)
missingness mechanism applied to a consistent ground truth, the resulting
database glues with probability one. In particular no law of the form
`P(sheaf) = (1-r)^{C}` with `C > 0` can hold in the masking model. -/
theorem masked_gluable (g : Fin n → Fin q) (mask : Fin k → Fin n → Bool) :
    Gluable (masked g mask) := by
  refine ⟨g, ?_⟩
  intro j c v hv
  by_cases h : mask j c <;> simp [masked, h] at hv
  exact hv

/-- **Sheaf imputation is exact.** If every column of a masked ground truth is
observed at least once, the ground truth is the *unique* global section, so
imputing by the global section recovers the truth on every missing cell. -/
theorem sheaf_imputation_exact (g : Fin n → Fin q) (mask : Fin k → Fin n → Bool)
    (hobs : ∀ c, ∃ j, mask j c = true) :
    sections (masked g mask) = {g} := by
  ext h
  simp only [mem_sections, Finset.mem_singleton]
  constructor
  · intro hh
    funext c
    obtain ⟨j, hj⟩ := hobs c
    exact hh j c (g c) (by simp [masked, hj])
  · rintro rfl
    intro j c v hv
    by_cases hm : mask j c <;> simp [masked, hm] at hv
    exact hv

end DatabaseSheaf

/-! ## Real-valued databases: mean imputation versus sheaf imputation -/

namespace DatabaseSheafReal

open Finset

variable {k n : ℕ}

/-- A real-valued partial database. -/
abbrev RealDB (k n : ℕ) := Fin k → Fin n → Option ℝ

/-- The rows observing column `c`. -/
def observers (D : RealDB k n) (c : Fin n) : Finset (Fin k) :=
  {j | (D j c).isSome}

/-- Column-mean imputation: the mean of the observed entries of the column. -/
noncomputable def meanImpute (D : RealDB k n) (c : Fin n) : ℝ :=
  (∑ j ∈ observers D c, (D j c).getD 0) / (observers D c).card

/-- Sheaf consistency for real-valued databases. -/
def PairwiseConsistentR (D : RealDB k n) : Prop :=
  ∀ j j' c v v', D j c = some v → D j' c = some v' → v = v'

/-- **Mean imputation = sheaf imputation on gluable data.** If the database is a
partial section of the constant sheaf, then in every observed column the mean of
the observed entries equals the unique sheaf value. The conjectured strict
advantage of sheaf imputation over mean imputation therefore fails identically in
this model, for every missing rate and every number of features. -/
theorem mean_imputation_eq_sheaf_imputation (D : RealDB k n)
    (hcons : PairwiseConsistentR D) (c : Fin n) (j₀ : Fin k) (v : ℝ)
    (hj₀ : D j₀ c = some v) :
    meanImpute D c = v := by
  have hmem : ∀ j ∈ observers D c, (D j c).getD 0 = v := by
    intro j hj
    have : (D j c).isSome := by simpa [observers] using hj
    obtain ⟨w, hw⟩ := Option.isSome_iff_exists.1 this
    rw [hw, Option.getD_some]
    exact hcons j j₀ c w v hw hj₀
  have hne : j₀ ∈ observers D c := by simp [observers, hj₀]
  have hcard : 0 < (observers D c).card := Finset.card_pos.2 ⟨j₀, hne⟩
  rw [meanImpute, Finset.sum_congr rfl hmem, Finset.sum_const, nsmul_eq_mul]
  field_simp

end DatabaseSheafReal