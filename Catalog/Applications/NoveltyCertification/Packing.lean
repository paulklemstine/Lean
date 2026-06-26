import Applications.NoveltyCertification.EmbeddingSpace

/-!
# Certified Novelty Detection — separation, composition, and the novelty budget

Building on `EmbeddingSpace.lean`, this file studies *whole catalogs* that are certified
novel.  A catalog `C` is **`ε`-separated** when every two distinct entries are at distance at
least `ε`; equivalently, each entry is an `ε`-novelty certificate against all the others.

The two main results are:

* `Separated.insert_of_cert` — **certificate composition**: if `C` is `ε`-separated and the
  new output `a` carries an `ε`-novelty certificate against `C`, then `insert a C` is again
  `ε`-separated.  Novelty certificates *compose*: the certified catalog stays well-formed as
  the research engine grows it one verified theorem at a time.
* `Separated.card_le_of_cells` — **the novelty budget (packing ≤ covering)**: if the
  embedding space admits a finite partition into cells of diameter `< ε` (a finite
  `ε`-cover), then *no* `ε`-separated catalog can have more entries than there are cells.
  The number of genuinely-novel theorems certifiable at resolution `ε` is bounded by the
  `ε`-covering number of the embedding space.

-- !-- Lab Notes -- !--
-- !-- Hypothesis: certified novelty is closed under catalog growth, and in a bounded
--     embedding space there is a hard, finite ceiling on how many `ε`-novel results can
--     ever be certified (a "novelty budget"). -- !--
-- !-- Experiment: defined `Separated`, proved closure under insertion of a certified point
--     (`insert_of_cert`, via `cert_separation`), and proved the packing bound
--     `card_le_of_cells` by a pigeonhole: the cell map is injective on an `ε`-separated set
--     because same-cell points are `< ε` apart while distinct entries are `≥ ε` apart. -- !--
-- !-- Analysis: the budget theorem is the quantitative heart — it converts the *geometry*
--     of the embedding (its covering number) into a *bound on creativity*. Distinguish:
--     unbounded spaces (e.g. discrete prime space, see `FibonacciNoveltyStream`) admit
--     unbounded budgets; totally bounded spaces force saturation. -- !--
-- !-- Critique: `insert_of_cert` needs neither `a ∉ C` nor `ε > 0` as side conditions —
--     `cert_separation` already delivers the distance bound, so the statement is clean.
--     Initially we guarded `card_le_of_cells` with `0 < ε`; the formal proof revealed the
--     hypothesis is *unnecessary* — when `ε ≤ 0` the cell condition `dist a b < ε` (with
--     `dist ≥ 0`) silently forces the cell map to be globally injective, so the bound still
--     holds. We dropped the redundant hypothesis, strengthening the theorem. -- !--
-/

namespace NoveltyCertification

open Finset

variable {X : Type*} [PseudoMetricSpace X]
variable {C : Finset X} {a : X} {ε : ℝ}

/-- A catalog is **`ε`-separated** if every two distinct entries are at least `ε` apart. -/
def Separated (ε : ℝ) (C : Finset X) : Prop :=
  ∀ a ∈ C, ∀ b ∈ C, a ≠ b → ε ≤ dist a b

theorem separated_empty (ε : ℝ) : Separated ε (∅ : Finset X) := by
  intro a ha; simp at ha

theorem separated_singleton (ε : ℝ) (a : X) : Separated ε ({a} : Finset X) := by
  intro x hx y hy hxy
  simp only [Finset.mem_singleton] at hx hy
  subst hx hy; exact absurd rfl hxy

/-- A subset of an `ε`-separated catalog is `ε`-separated. -/
theorem Separated.subset {C D : Finset X} (h : Separated ε D) (hCD : C ⊆ D) :
    Separated ε C := fun a ha b hb hab => h a (hCD ha) b (hCD hb) hab

/-- **Certificate composition**: inserting a point that is `ε`-novel against `C` into an
`ε`-separated catalog keeps it `ε`-separated. -/
theorem Separated.insert_of_cert [DecidableEq X] (hC : C.Nonempty)
    (hsep : Separated ε C) (hcert : ε ≤ novelty C hC a) :
    Separated ε (insert a C) := by
  have hsep_a : ∀ c ∈ C, ε ≤ dist a c := cert_separation hC hcert
  intro u hu v hv huv
  simp only [Finset.mem_insert] at hu hv
  rcases hu with rfl | hu <;> rcases hv with rfl | hv
  · exact absurd rfl huv
  · exact hsep_a v hv
  · rw [dist_comm]; exact hsep_a u hu
  · exact hsep u hu v hv huv

/-- **Novelty budget (packing ≤ covering)**: if `q : X → β` maps every catalog entry into a
finite set `K` of cells, and any two points sharing a cell are strictly within `ε`, then an
`ε`-separated catalog has at most `K.card` entries.  No sign hypothesis on `ε` is needed: if
`ε ≤ 0` the cell condition forces `q` to be injective, and the bound holds a fortiori. -/
theorem Separated.card_le_of_cells {β : Type*}
    (q : X → β) (K : Finset β)
    (hcell : ∀ a b : X, q a = q b → dist a b < ε)
    (hmaps : ∀ c ∈ C, q c ∈ K)
    (hsep : Separated ε C) :
    C.card ≤ K.card := by
  apply Finset.card_le_card_of_injOn q
  · intro c hc; exact hmaps c hc
  · intro x hx y hy hxy
    simp only [Finset.mem_coe] at hx hy
    by_contra hne
    have h1 := hsep x hx y hy hne
    have h2 := hcell x y hxy
    linarith

end NoveltyCertification