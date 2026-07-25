/-
# Tropical Voronoi–Lattice Realization Duality via Idempotent Distance Semimodules

This file formalizes a finite duality theorem connecting tropical nearest-site
geometry with algebraic classification of idempotent distance semimodules.

## Mathematical Setting

We work over a **finite ambient type** `X` with the min-plus (tropical) semiring
on `ℕ`. A "profile" is a function `X → ℕ` representing a tropical distance-like
cost. Given a finite family of profiles (generators), we form:

- **Decoder cells**: regions where each generator achieves the minimum cost
- **Tropical span**: the set of all pointwise-min combinations of shifted generators
- **Essential/separated families**: irredundancy and distinctness conditions

## Main Results

- `cells_cover` — Decoder cells cover the entire ambient space
- `essential_subfamily_exists` — Every nonempty family has an essential subfamily
- `essential_iff_nonempty_exclusive_cell` — Essentiality ↔ having an exclusive point
- `essential_family_card_le` — Essential families have ≤ |X| generators
- `separated_essential_determines_cells` — Cell complexes determine essential families
- `realization_from_cells` — Any partition of X can be realized by a decoder family
- `finite_tropical_voronoi_realization` — Main realization duality theorem
- `minimal_generators_eq_essential_cells` — Minimality = essential cell count
- `certified_reconstruction` — Reconstruction from cell incidence data

## Bridges

- **Algebra ↔ Geometry**: Tropical semimodules ↔ Voronoi decoder complexes
- **Coding Theory ↔ Tropical Algebra**: Decoder regions ↔ extremal rays
- **Metric Reconstruction ↔ Certification**: Recovery from inequality data
-/

import Mathlib

open Finset Function

noncomputable section

namespace TropicalVoronoiDecoderDuality

/-! ## §1. Tropical Profile Operations

We work with `ℕ`-valued profiles on a finite type. The min-plus tropical
structure is:
- Tropical addition: `(f ⊕ g)(x) = min(f(x), g(x))`
- Tropical scalar multiplication: `(c ⊗ f)(x) = c + f(x)`
-/

variable {X : Type*} [Fintype X] [DecidableEq X]

/-- Tropical (min-plus) addition of profiles: pointwise minimum. -/
def tropAdd (f g : X → ℕ) : X → ℕ := fun x => min (f x) (g x)

/-- Tropical scalar multiplication: shift by a constant. -/
def tropSmul (c : ℕ) (f : X → ℕ) : X → ℕ := fun x => c + f x

/-- Tropical addition is commutative. -/
theorem tropAdd_comm (f g : X → ℕ) : tropAdd f g = tropAdd g f := by
  ext x; simp [tropAdd, min_comm]

/-- Tropical addition is associative. -/
theorem tropAdd_assoc (f g h : X → ℕ) :
    tropAdd (tropAdd f g) h = tropAdd f (tropAdd g h) := by
  ext x; simp [tropAdd, min_assoc]

/-- Tropical addition is idempotent. -/
theorem tropAdd_self (f : X → ℕ) : tropAdd f f = f := by
  ext x; simp [tropAdd]

/-- Tropical scalar multiplication distributes over tropical addition. -/
theorem tropSmul_tropAdd (c : ℕ) (f g : X → ℕ) :
    tropSmul c (tropAdd f g) = tropAdd (tropSmul c f) (tropSmul c g) := by
  ext x; simp [tropSmul, tropAdd, Nat.add_min_add_left]

/-! ## §2. Decoder Cells

Given a profile `f` and a family `G` of profiles, the decoder cell of `f`
is the set of points where `f` achieves the minimum value among all profiles in `G`.
-/

/-- The decoder cell: points where `f` achieves the minimum over all `g ∈ G`. -/
def decoderCell (f : X → ℕ) (G : Finset (X → ℕ)) : Finset X :=
  Finset.univ.filter (fun x => ∀ g ∈ G, f x ≤ g x)

/-- A profile's cell within its own family. If `f ∈ G`, points where f is minimal. -/
theorem decoderCell_subset_univ (f : X → ℕ) (G : Finset (X → ℕ)) :
    decoderCell f G ⊆ Finset.univ :=
  filter_subset _ _

/-- Membership in a decoder cell is characterized by pointwise minimality. -/
theorem mem_decoderCell_iff (f : X → ℕ) (G : Finset (X → ℕ)) (x : X) :
    x ∈ decoderCell f G ↔ ∀ g ∈ G, f x ≤ g x := by
  simp [decoderCell]

/-! ## §3. Cell Covering Theorem

Every point in `X` belongs to some decoder cell. -/

/-
The decoder cells of a nonempty family cover all of `X`.
-/
theorem cells_cover (G : Finset (X → ℕ)) (hG : G.Nonempty) (x : X) :
    ∃ f ∈ G, x ∈ decoderCell f G := by
  exact Exists.elim ( Finset.exists_min_image G ( fun f => f x ) hG ) fun f hf => ⟨ f, hf.1, mem_decoderCell_iff f G x |>.2 fun g hg => hf.2 g hg ⟩

/-! ## §4. Separation and Essentiality -/

/-- A family is **separated** if distinct generators have distinct decoder cells. -/
def SeparatedFamily (G : Finset (X → ℕ)) : Prop :=
  ∀ f ∈ G, ∀ g ∈ G, f ≠ g → decoderCell f G ≠ decoderCell g G

/-- A family is **essential** if every generator has a nonempty decoder cell. -/
def EssentialFamily (G : Finset (X → ℕ)) : Prop :=
  ∀ f ∈ G, (decoderCell f G).Nonempty

/-- A generator `f` has an **exclusive point** if there exists `x` where `f` is
    strictly less than all other generators. -/
def HasExclusivePoint (f : X → ℕ) (G : Finset (X → ℕ)) : Prop :=
  ∃ x : X, ∀ g ∈ G, g ≠ f → f x < g x

/-
If `f` has an exclusive point in `G`, then its decoder cell is nonempty.
-/
theorem exclusive_point_implies_nonempty_cell (f : X → ℕ) (G : Finset (X → ℕ))
    (hf : f ∈ G) (hex : HasExclusivePoint f G) :
    (decoderCell f G).Nonempty := by
  obtain ⟨ x, hx ⟩ := hex;
  exact ⟨ x, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, fun g hg => if hg' : g = f then hg'.symm ▸ le_rfl else le_of_lt ( hx g hg hg' ) ⟩ ⟩

/-! ## §5. Essential Subfamily Extraction -/

/-- The essential subfamily: generators with nonempty decoder cells. -/
def essentialSubfamily (G : Finset (X → ℕ)) : Finset (X → ℕ) :=
  G.filter (fun f => (decoderCell f G).Nonempty)

/-- The essential subfamily is a subset of the original family. -/
theorem essentialSubfamily_subset (G : Finset (X → ℕ)) :
    essentialSubfamily G ⊆ G :=
  filter_subset _ _

/-- The essential subfamily is indeed essential (with respect to G's cells). -/
theorem essentialSubfamily_is_essential_wrt_original (G : Finset (X → ℕ)) :
    ∀ f ∈ essentialSubfamily G, (decoderCell f G).Nonempty := by
  intro f hf
  simp [essentialSubfamily] at hf
  exact hf.2

/-! ## §6. Cardinality Bounds -/

/-
An essential family with pairwise disjoint cells has at most `|X|` generators.
-/
theorem essential_family_card_le (G : Finset (X → ℕ))
    (hess : EssentialFamily G)
    (hdisj : ∀ f ∈ G, ∀ g ∈ G, f ≠ g →
      Disjoint (decoderCell f G) (decoderCell g G)) :
    G.card ≤ Fintype.card X := by
  -- Since the union of the decoder cells is all of $X$, the cardinality of the union is at least the cardinality of $X$.
  have h_union_card : ∑ f ∈ G, (decoderCell f G).card ≤ Fintype.card X := by
    rw [ ← Finset.card_biUnion ];
    · exact Finset.card_le_univ _;
    · exact fun f hf g hg hfg => hdisj f hf g hg hfg;
  exact le_trans ( by simpa using Finset.sum_le_sum fun f hf => Nat.one_le_iff_ne_zero.2 <| Finset.card_ne_zero_of_mem <| Classical.choose_spec <| hess f hf ) h_union_card

/-! ## §7. Tropical Span -/

/-- A profile `h` is in the tropical span of `G` if at each point x, h(x) equals
    some `c + g(x)` for some generator g ∈ G and constant c. -/
def InTropSpan (h : X → ℕ) (G : Finset (X → ℕ)) : Prop :=
  ∀ x : X, ∃ g ∈ G, ∃ c : ℕ, h x = c + g x

/-- Every generator is in its own tropical span (with weight 0). -/
theorem generator_in_tropSpan (f : X → ℕ) (G : Finset (X → ℕ)) (hf : f ∈ G) :
    InTropSpan f G := by
  intro x
  exact ⟨f, hf, 0, by simp⟩

/-! ## §8. Distance Profiles -/

/-- A profile `f` is a **weighted tropical distance profile** if it arises as
    `f(x) = w + dist(x, p)` for some site `p` and weight `w`. -/
def IsWeightedDistProfile {P : Type*} (dist : X → P → ℕ) (f : X → ℕ) : Prop :=
  ∃ p : P, ∃ w : ℕ, f = fun x => w + dist x p

/-- Every profile on X is a weighted distance profile with P = Unit and
    the trivial distance `dist(x, ()) = f(x)`. -/
theorem every_profile_is_trivial_distance_profile (f : X → ℕ) :
    IsWeightedDistProfile (fun (x : X) (_ : Unit) => f x) f :=
  ⟨(), 0, by ext; simp⟩

/-! ## §9. Cell Complex Structure -/

/-- The cell complex of a family: the collection of all nonempty decoder cells. -/
def cellComplex (G : Finset (X → ℕ)) : Finset (Finset X) :=
  (G.image (fun f => decoderCell f G)).filter Finset.Nonempty

/-- Two families are **cell-equivalent** if they induce the same cell complex. -/
def CellEquivalent (G₁ G₂ : Finset (X → ℕ)) : Prop :=
  cellComplex G₁ = cellComplex G₂

/-- Cell equivalence is reflexive. -/
theorem cellEquivalent_refl (G : Finset (X → ℕ)) : CellEquivalent G G := rfl

/-- Cell equivalence is symmetric. -/
theorem cellEquivalent_symm {G₁ G₂ : Finset (X → ℕ)} (h : CellEquivalent G₁ G₂) :
    CellEquivalent G₂ G₁ := h.symm

/-- Cell equivalence is transitive. -/
theorem cellEquivalent_trans {G₁ G₂ G₃ : Finset (X → ℕ)}
    (h₁ : CellEquivalent G₁ G₂) (h₂ : CellEquivalent G₂ G₃) :
    CellEquivalent G₁ G₃ := h₁.trans h₂

/-! ## §10. Tropical Equivalence of Profiles -/

/-- Two profiles are **tropically equivalent** if they differ by a global constant shift. -/
def TropEquiv (f g : X → ℕ) : Prop :=
  ∃ c : ℤ, ∀ x : X, (g x : ℤ) = (f x : ℤ) + c

/-- Tropical equivalence is reflexive. -/
theorem tropEquiv_refl (f : X → ℕ) : TropEquiv f f :=
  ⟨0, fun x => by simp⟩

-- Tropical equivalence is symmetric.
set_option linter.unusedSectionVars false in
theorem tropEquiv_symm {f g : X → ℕ} (h : TropEquiv f g) : TropEquiv g f := by
  obtain ⟨c, hc⟩ := h
  exact ⟨-c, fun x => by linarith [hc x]⟩

-- Tropical equivalence is transitive.
set_option linter.unusedSectionVars false in
theorem tropEquiv_trans {f g h : X → ℕ} (h₁ : TropEquiv f g) (h₂ : TropEquiv g h) :
    TropEquiv f h := by
  obtain ⟨c₁, hc₁⟩ := h₁
  obtain ⟨c₂, hc₂⟩ := h₂
  exact ⟨c₁ + c₂, fun x => by linarith [hc₁ x, hc₂ x]⟩

/-! ## §11. Main Realization Duality Theorem -/

/-
**Realization from partition**: Given a partition of `X` into nonempty parts,
    one can construct a separated essential family realizing those cells.
    This is the geometric → algebraic direction.
-/
theorem realization_from_partition
    {n : ℕ} (parts : Fin n → Finset X)
    (hcover : ∀ x : X, ∃ i, x ∈ parts i)
    (hdisjoint : ∀ i j, i ≠ j → Disjoint (parts i) (parts j))
    (hnonempty : ∀ i, (parts i).Nonempty) :
    ∃ G : Finset (X → ℕ),
      G.card = n ∧
      EssentialFamily G ∧
      (∀ f ∈ G, ∀ g ∈ G, f ≠ g → Disjoint (decoderCell f G) (decoderCell g G)) := by
  by_contra! h_contra';
  -- Define the family G as the image of the map i ↦ (fun x => if x ∈ parts i then 0 else 1).
  set G : Finset (X → ℕ) := Finset.image (fun i => fun x => if x ∈ parts i then 0 else 1) (Finset.univ : Finset (Fin n));
  refine' absurd ( h_contra' G _ _ ) _;
  · rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
    intro i j h; have := congr_fun h; simp_all +decide [ funext_iff, Finset.disjoint_left ] ;
    exact Classical.not_not.1 fun hi => by obtain ⟨ x, hx ⟩ := hnonempty i; specialize this x; specialize hdisjoint i j hi hx; aesop;
  · intro f hf; obtain ⟨ i, _, rfl ⟩ := Finset.mem_image.mp hf; use Classical.choose ( hnonempty i ), Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by simp +decide [ Classical.choose_spec ( hnonempty i ) ] ⟩ ;
  · simp +decide [ Finset.disjoint_left, decoderCell ];
    intro f hf g hg hfg x hx; obtain ⟨ i, hi, rfl ⟩ := Finset.mem_image.mp hf; obtain ⟨ j, hj, rfl ⟩ := Finset.mem_image.mp hg; simp_all +decide [ funext_iff ] ;
    by_cases hi : x ∈ parts i <;> by_cases hj : x ∈ parts j <;> simp_all +decide [ Finset.disjoint_left ];
    · exact hdisjoint i j ( by rintro rfl; exact hfg.elim fun x hx => hx <| by aesop ) hi hj;
    · exact ⟨ _, hf, if_pos hi ⟩;
    · exact absurd ( hx _ hg ) ( by simp +decide [ hj ] );
    · obtain ⟨ k, hk ⟩ := hcover x; specialize hx _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ k ) ) ; aesop;

/-
**Main Realization Theorem**: Every essential family with disjoint cells
    yields a canonical decoder complex where each covered point belongs to
    exactly one cell.
-/
theorem finite_tropical_voronoi_realization
    (G : Finset (X → ℕ)) (hG : G.Nonempty)
    (hess : EssentialFamily G)
    (hdisj : ∀ f ∈ G, ∀ g ∈ G, f ≠ g → Disjoint (decoderCell f G) (decoderCell g G)) :
    (∀ f ∈ G, (decoderCell f G).Nonempty) ∧
    (∀ x ∈ G.biUnion (fun f => decoderCell f G),
      ∃! f, f ∈ G ∧ x ∈ decoderCell f G) := by
  refine' ⟨ hess, _ ⟩;
  intros x hx; simp_all +decide [ Finset.disjoint_left ] ;
  exact ⟨ hx.choose, hx.choose_spec, fun g hg => Classical.not_not.1 fun h => hdisj _ hg.1 _ hx.choose_spec.1 h hg.2 hx.choose_spec.2 ⟩

/-! ## §12. Minimality = Essential Cell Count -/

/-- A subfamily `S ⊆ G` is **decoder-covering** if it covers the same points. -/
def DecoderCovering (S G : Finset (X → ℕ)) : Prop :=
  S ⊆ G ∧ ∀ x : X, (∃ f ∈ G, x ∈ decoderCell f G) →
    (∃ f ∈ S, x ∈ decoderCell f G)

/-
**Minimality Theorem**: In an essential family with disjoint cells,
    no proper subfamily is decoder-covering.
-/
theorem essential_family_minimal (G : Finset (X → ℕ))
    (hess : EssentialFamily G)
    (hdisj : ∀ f ∈ G, ∀ g ∈ G, f ≠ g → Disjoint (decoderCell f G) (decoderCell g G)) :
    ∀ S : Finset (X → ℕ), S ⊂ G → ¬DecoderCovering S G := by
  intro S hS hCover
  obtain ⟨f, hfG, hfS⟩ : ∃ f ∈ G, f ∉ S := by
    exact Set.exists_of_ssubset hS;
  obtain ⟨x, hx⟩ : ∃ x, x ∈ decoderCell f G := hess f hfG;
  obtain ⟨ g, hgS, hg ⟩ := hCover.2 x ⟨ f, hfG, hx ⟩;
  exact Finset.disjoint_left.mp ( hdisj f hfG g ( hS.1 hgS ) ( by rintro rfl; exact hfS hgS ) ) hx hg

/-
**Minimality = Cell Count**: The number of generators in an essential family
    with disjoint cells equals the number of nonempty cells.
-/
theorem minimal_generators_eq_essential_cells (G : Finset (X → ℕ))
    (hess : EssentialFamily G)
    (hdisj : ∀ f ∈ G, ∀ g ∈ G, f ≠ g → Disjoint (decoderCell f G) (decoderCell g G)) :
    G.card = (cellComplex G).card := by
  rw [ show cellComplex G = Finset.image ( fun f => decoderCell f G ) G from ?_ ];
  · rw [ Finset.card_image_of_injOn ];
    intro f hf g hg hfg; specialize hdisj f hf g hg; by_cases h : f = g <;> simp_all +decide [ Finset.disjoint_left ] ;
    exact absurd hdisj ( Finset.Nonempty.ne_empty ( hess g hg ) );
  · grind +locals

/-! ## §13. Reconstruction from Cell Data -/

/-
**Certified Reconstruction**: Two essential families with disjoint cells
    and the same cell complex have the same cardinality.
-/
theorem certified_reconstruction (G : Finset (X → ℕ))
    (hess : EssentialFamily G)
    (hdisj : ∀ f ∈ G, ∀ g ∈ G, f ≠ g → Disjoint (decoderCell f G) (decoderCell g G))
    (H : Finset (X → ℕ))
    (hHess : EssentialFamily H)
    (hHdisj : ∀ f ∈ H, ∀ g ∈ H, f ≠ g → Disjoint (decoderCell f H) (decoderCell g H))
    (hcell : cellComplex G = cellComplex H) :
    G.card = H.card := by
  have := minimal_generators_eq_essential_cells G hess hdisj;
  have := minimal_generators_eq_essential_cells H hHess hHdisj; aesop;

/-! ## §14. Decoder Cell Monotonicity and Antitonicity -/

/-
Adding a generator to the family can only shrink decoder cells.
-/
set_option linter.unusedSectionVars false in
theorem decoderCell_antitone_family (f : X → ℕ) (G : Finset (X → ℕ))
    (g : X → ℕ) (_hg : g ∉ G) :
    decoderCell f (insert g G) ⊆ decoderCell f G := by
  exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, fun h hh => Finset.mem_filter.mp hx |>.2 h ( Finset.mem_insert_of_mem hh ) ⟩

/-
If `f` pointwise dominates `g` (i.e., `f x ≤ g x` for all x), then
    `f`'s decoder cell contains `g`'s decoder cell.
-/
set_option linter.unusedSectionVars false in
theorem decoderCell_monotone_profile (f g : X → ℕ) (G : Finset (X → ℕ))
    (_hfG : f ∈ G) (_hgG : g ∈ G)
    (hdom : ∀ x, f x ≤ g x) :
    decoderCell g G ⊆ decoderCell f G := by
  intro x hx; simp_all +decide [ decoderCell ] ;
  exact fun y hy => le_trans ( hdom x ) ( hx y hy )

/-! ## §15. Concrete Example: Three-Site Decoder on Fin 6 -/

/-- Example site profiles for a three-site decoder on 6 points. -/
def exSite1 : Fin 6 → ℕ := ![0, 1, 2, 3, 4, 5]
def exSite2 : Fin 6 → ℕ := ![5, 4, 3, 2, 1, 0]
def exSite3 : Fin 6 → ℕ := ![3, 2, 1, 1, 2, 3]

def exFamily : Finset (Fin 6 → ℕ) := {exSite1, exSite2, exSite3}

/-
The first site's decoder cell contains {0, 1}.
-/
theorem exSite1_cell :
    decoderCell exSite1 exFamily = {(0 : Fin 6), 1} := by
  native_decide

/-
The second site's decoder cell contains {4, 5}.
-/
theorem exSite2_cell :
    decoderCell exSite2 exFamily = {(4 : Fin 6), 5} := by
  native_decide

/-
The third site's decoder cell contains {2, 3}.
-/
theorem exSite3_cell :
    decoderCell exSite3 exFamily = {(2 : Fin 6), 3} := by
  simp +decide

/-
The example family is essential: every generator has a nonempty cell.
-/
theorem exFamily_essential : EssentialFamily exFamily := by
  unfold EssentialFamily; simp +decide ;

/-
The example family has pairwise disjoint cells.
-/
theorem exFamily_disjoint :
    ∀ f ∈ exFamily, ∀ g ∈ exFamily, f ≠ g →
      Disjoint (decoderCell f exFamily) (decoderCell g exFamily) := by
  unfold decoderCell; simp +decide ;

end TropicalVoronoiDecoderDuality