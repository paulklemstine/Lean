/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib

/-!
# Spectral Decomposition of Compression via Filtrations

This file establishes that sheaf compression numbers are controlled by
filtration data: given a finite chain of presheaves where each step satisfies
an extension inequality, the compression of the total presheaf is bounded by
the sum of compressions of the graded pieces. This is the sheaf-theoretic
analogue of entropy chain rules and Jordan–Hölder complexity bounds.

## Main Definitions

* `PresheafSeparatedByProbes` — separation of presheaf sections by a probe family.
* `TopologyCompatibleProbes` — topology compatibility of a probe family.
* `sheafCompressionNumber` — the sheaf compression number `κ_sh(J, F)`.
* `PresheafCoprod` — pointwise coproduct of presheaves.
* `FinCoprod` — finite coproduct of presheaves indexed by `Fin n`.
* `FiltrationChain` — a finite chain of presheaves with extension bounds at each step.
* `GroundedFiltration` — a filtration with trivial bottom level.
* `SplitDecomposition` — a decomposition witnessing compression additivity.

## Main Theorems

* `compression_extension_le` — **one-step extension inequality**:
  `κ(F ⊕ G) ≤ κ(F) + κ(G)`.
* `compression_finCoprod_le` — **iterated coproduct subadditivity**:
  `κ(∐ᵢ Fᵢ) ≤ ∑ᵢ κ(Fᵢ)`.
* `compression_filtration_chain_le` — **filtration subadditivity**:
  `κ(Fₙ) ≤ κ(F₀) + ∑ᵢ κ(grᵢ)`.
* `compression_grounded_filtration_le` — when the bottom is trivial:
  `κ(F) ≤ ∑ᵢ κ(grᵢ)`.
* `compression_eq_of_sep_equiv` — compression respects isomorphisms.
* `compression_le_of_sep_implies` — monotonicity under separation weakening.
* `compression_split_le` — split decomposition upper bound.
* `compressionDefect_nonneg` — nonnegativity of compression defect.

## Cross-Domain Significance

- **Information theory**: filtration bound = entropy chain rule for non-independent sources.
- **Representation theory**: Jordan–Hölder-style complexity bound from composition factors.
- **Algebraic K-theory**: compression as an additive invariant on split exact sequences.
-/

open CategoryTheory Finset Opposite

noncomputable section

universe u v

namespace CompressionFiltration

set_option linter.unusedSectionVars false

variable {C : Type u} [Category.{v} C] [DecidableEq C]

/-! ## Core Definitions -/

/-- A finset of objects `P` **separates** a presheaf `F` if for every object `X`
and every pair of sections, agreement under all restriction maps from probe objects
implies equality. -/
def PresheafSeparatedByProbes (P : Finset C) (F : Cᵒᵖ ⥤ Type v) : Prop :=
  ∀ (X : C) (s t : F.obj (Opposite.op X)),
    (∀ Z ∈ P, ∀ (f : Z ⟶ X), F.map f.op s = F.map f.op t) → s = t

/-- A probe family `P` is **topology-compatible** with `J` if every covering sieve
contains a morphism from some probe object. -/
def TopologyCompatibleProbes (J : GrothendieckTopology C) (P : Finset C) : Prop :=
  ∀ (X : C) (S : Sieve X), S ∈ J X → ∃ Z ∈ P, ∃ (f : Z ⟶ X), S.arrows f

/-- Cardinalities of topology-compatible separating probe families. -/
def sheafCompressionCards (J : GrothendieckTopology C) (F : Cᵒᵖ ⥤ Type v) : Set ℕ :=
  {n | ∃ P : Finset C, P.card = n ∧ PresheafSeparatedByProbes P F ∧
    TopologyCompatibleProbes J P}

/-- **Sheaf compression number** `κ_sh(J, F)`: the minimum size of a
topology-compatible separating probe family. -/
def sheafCompressionNumber [Fintype C] (J : GrothendieckTopology C)
    (F : Cᵒᵖ ⥤ Type v) : ℕ :=
  sInf (sheafCompressionCards J F)

/-! ## Monotonicity -/

theorem PresheafSeparatedByProbes.mono {P Q : Finset C} {F : Cᵒᵖ ⥤ Type v}
    (hPQ : P ⊆ Q) (hP : PresheafSeparatedByProbes P F) :
    PresheafSeparatedByProbes Q F :=
  fun X s t hall => hP X s t (fun Z hZ f => hall Z (hPQ hZ) f)

theorem TopologyCompatibleProbes.mono {J : GrothendieckTopology C}
    {P Q : Finset C} (hPQ : P ⊆ Q)
    (hP : TopologyCompatibleProbes J P) :
    TopologyCompatibleProbes J Q :=
  fun X S hS => let ⟨Z, hZ, f, hf⟩ := hP X S hS; ⟨Z, hPQ hZ, f, hf⟩

theorem sheafCompressionNumber_le_of_witness [Fintype C]
    {J : GrothendieckTopology C} {F : Cᵒᵖ ⥤ Type v}
    (P : Finset C) (hP : PresheafSeparatedByProbes P F)
    (hJ : TopologyCompatibleProbes J P) :
    sheafCompressionNumber J F ≤ P.card :=
  Nat.sInf_le ⟨P, rfl, hP, hJ⟩

/-! ## Topology compatibility implies reachability -/

theorem topologyCompatible_implies_reachable
    {J : GrothendieckTopology C} {P : Finset C}
    (hP : TopologyCompatibleProbes J P) :
    ∀ X : C, ∃ Z ∈ P, Nonempty (Z ⟶ X) := by
  intro X
  obtain ⟨Z, hZ, f, _⟩ := hP X ⊤ (J.top_mem X)
  exact ⟨Z, hZ, ⟨f⟩⟩

/-! ## Section 1: Pointwise Coproduct -/

/-- The **pointwise coproduct** of presheaves `F` and `G`: `X ↦ F(X) ⊕ G(X)`. -/
@[simps]
def PresheafCoprod (F G : Cᵒᵖ ⥤ Type v) : Cᵒᵖ ⥤ Type v where
  obj X := Sum (F.obj X) (G.obj X)
  map f := Sum.map (F.map f) (G.map f)
  map_id X := by ext x; cases x <;> simp
  map_comp f g := by ext x; cases x <;> simp [types_comp]

/-- Union of separating families for the summands separates the coproduct. -/
theorem presheafSeparated_coprod_of_union
    {J : GrothendieckTopology C}
    {P Q : Finset C} {F G : Cᵒᵖ ⥤ Type v}
    (hF : PresheafSeparatedByProbes P F)
    (hG : PresheafSeparatedByProbes Q G)
    (hcompat : TopologyCompatibleProbes J P) :
    PresheafSeparatedByProbes (P ∪ Q) (PresheafCoprod F G) := by
  intro X s t hst
  cases s with
  | inl sF =>
    cases t with
    | inl tF =>
      congr 1; apply hF X sF tF
      intro Z hZ f
      have h := hst Z (Finset.mem_union_left Q hZ) f
      simp [PresheafCoprod] at h; exact h
    | inr _ =>
      exfalso
      obtain ⟨Z, hZ, ⟨f⟩⟩ := topologyCompatible_implies_reachable hcompat X
      have h := hst Z (Finset.mem_union_left Q hZ) f
      simp [PresheafCoprod] at h
  | inr _ =>
    cases t with
    | inl _ =>
      exfalso
      obtain ⟨Z, hZ, ⟨f⟩⟩ := topologyCompatible_implies_reachable hcompat X
      have h := hst Z (Finset.mem_union_left Q hZ) f
      simp [PresheafCoprod] at h
    | inr tG =>
      congr 1; apply hG X _ tG
      intro Z hZ f
      have h := hst Z (Finset.mem_union_right P hZ) f
      simp [PresheafCoprod] at h; exact h

/-! ## Section 2: One-Step Extension Inequality -/

/-- **Theorem 1 (One-Step Extension Inequality).**
`κ_sh(J, F ⊕ G) ≤ κ_sh(J, F) + κ_sh(J, G)`.

This is the engine for all filtration bounds. The proof combines optimal
probe families for each summand via set union. -/
theorem compression_extension_le [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v)
    (hF : (sheafCompressionCards J F).Nonempty)
    (hG : (sheafCompressionCards J G).Nonempty) :
    sheafCompressionNumber J (PresheafCoprod F G) ≤
      sheafCompressionNumber J F + sheafCompressionNumber J G := by
  obtain ⟨PF, hPF_card, hPF_sep, hPF_compat⟩ := Nat.sInf_mem hF
  obtain ⟨PG, hPG_card, hPG_sep, hPG_compat⟩ := Nat.sInf_mem hG
  calc sheafCompressionNumber J (PresheafCoprod F G)
      ≤ (PF ∪ PG).card := by
        apply sheafCompressionNumber_le_of_witness
        · exact presheafSeparated_coprod_of_union hPF_sep hPG_sep hPF_compat
        · exact hPF_compat.mono Finset.subset_union_left
    _ ≤ PF.card + PG.card := Finset.card_union_le PF PG
    _ = sheafCompressionNumber J F + sheafCompressionNumber J G := by
        simp only [sheafCompressionNumber, ← hPF_card, ← hPG_card]

/-! ## Section 3: Finite Coproduct -/

/-- The **finite coproduct** of presheaves indexed by `Fin n`:
`X ↦ Σ i, Fᵢ(X)`. -/
def FinCoprod (n : ℕ) (Fs : Fin n → Cᵒᵖ ⥤ Type v) : Cᵒᵖ ⥤ Type v where
  obj X := Σ i : Fin n, (Fs i).obj X
  map {_ _} f := fun ⟨i, s⟩ => ⟨i, (Fs i).map f s⟩
  map_id _ := by funext ⟨_, _⟩; simp
  map_comp _ _ := by funext ⟨_, _⟩; simp

/-- A probe family separating each component and topology-compatible
also separates the finite coproduct. The proof distinguishes between
same-component pairs (use component separation) and cross-component
pairs (derive contradiction via reachability). -/
theorem finCoprod_separated_of_components
    {J : GrothendieckTopology C}
    {n : ℕ}
    {Fs : Fin n → Cᵒᵖ ⥤ Type v}
    {Qs : Fin n → Finset C}
    (h_sep : ∀ i, PresheafSeparatedByProbes (Qs i) (Fs i))
    (h_compat : ∀ i, TopologyCompatibleProbes J (Qs i)) :
    PresheafSeparatedByProbes (Finset.univ.biUnion Qs) (FinCoprod n Fs) := by
  intro X ⟨i, si⟩ ⟨j, sj⟩ hall
  -- Extract the Sigma-level equality from the hypothesis
  have key : ∀ Z ∈ Finset.univ.biUnion Qs, ∀ (f : Z ⟶ X),
      (⟨i, (Fs i).map f.op si⟩ : Σ k, (Fs k).obj (op Z)) =
      ⟨j, (Fs j).map f.op sj⟩ := hall
  by_cases hij : i = j
  · subst hij; congr 1
    apply h_sep i X si sj
    intro Z hZ f
    have h := key Z (Finset.mem_biUnion.mpr ⟨i, Finset.mem_univ _, hZ⟩) f
    exact eq_of_heq (Sigma.mk.inj h).2
  · exfalso
    obtain ⟨Z, hZ, ⟨f⟩⟩ := topologyCompatible_implies_reachable (h_compat i) X
    have h := key Z (Finset.mem_biUnion.mpr ⟨i, Finset.mem_univ _, hZ⟩) f
    exact hij (Sigma.mk.inj h).1

/-! ## Section 4: Iterated Coproduct Subadditivity -/

/-- **Theorem 2 (Iterated Coproduct Subadditivity).**
`κ_sh(J, ∐ᵢ Fᵢ) ≤ ∑ᵢ κ_sh(J, Fᵢ)`.

The proof constructs a combined probe family as a biUnion of optimal
families for each component. -/
theorem compression_finCoprod_le [Fintype C]
    (J : GrothendieckTopology C)
    (n : ℕ) (hn : 0 < n)
    (Fs : Fin n → Cᵒᵖ ⥤ Type v)
    (h_nonempty : ∀ i, (sheafCompressionCards J (Fs i)).Nonempty) :
    sheafCompressionNumber J (FinCoprod n Fs) ≤
      ∑ i : Fin n, sheafCompressionNumber J (Fs i) := by
  -- Extract optimal probe families for each component
  have h_wit : ∀ i, ∃ P : Finset C,
      P.card = sheafCompressionNumber J (Fs i) ∧
      PresheafSeparatedByProbes P (Fs i) ∧
      TopologyCompatibleProbes J P :=
    fun i => Nat.sInf_mem (h_nonempty i)
  choose Qs hQs using h_wit
  -- The combined family
  let Q := Finset.univ.biUnion Qs
  have hQ_sep : PresheafSeparatedByProbes Q (FinCoprod n Fs) :=
    finCoprod_separated_of_components
      (fun i => (hQs i).2.1) (fun i => (hQs i).2.2)
  have hQ_compat : TopologyCompatibleProbes J Q := by
    intro X S hS
    have ⟨i⟩ : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
    obtain ⟨Z, hZ, f, hf⟩ := (hQs i).2.2 X S hS
    exact ⟨Z, Finset.mem_biUnion.mpr ⟨i, Finset.mem_univ _, hZ⟩, f, hf⟩
  calc sheafCompressionNumber J (FinCoprod n Fs)
      ≤ Q.card := sheafCompressionNumber_le_of_witness Q hQ_sep hQ_compat
    _ ≤ ∑ i ∈ Finset.univ, (Qs i).card := Finset.card_biUnion_le
    _ = ∑ i : Fin n, sheafCompressionNumber J (Fs i) := by
        congr 1; ext i; exact (hQs i).1

/-! ## Section 5: Telescoping Sum Lemma -/

/-- **Key combinatorial lemma**: a telescoping bound on a sequence controlled
at each step yields a global bound. This is the pure arithmetic engine
behind filtration subadditivity. -/
theorem telescoping_sum_bound
    (n : ℕ)
    (a : Fin (n + 1) → ℕ)
    (b : Fin n → ℕ)
    (h : ∀ i : Fin n, a i.succ ≤ a i.castSucc + b i) :
    a (Fin.last n) ≤ a 0 + ∑ i : Fin n, b i := by
  induction n with
  | zero => simp
  | succ m ih =>
    rw [Fin.sum_univ_castSucc]
    have h_last := h (Fin.last m)
    let a' : Fin (m + 1) → ℕ := fun i => a (Fin.castSucc i)
    let b' : Fin m → ℕ := fun i => b (Fin.castSucc i)
    have h_step' : ∀ i : Fin m, a' i.succ ≤ a' i.castSucc + b' i :=
      fun i => h (Fin.castSucc i)
    have h_ih := ih a' b' h_step'
    -- h_ih : a (castSucc (last m)) ≤ a (castSucc 0) + ∑ b ∘ castSucc
    change a (Fin.castSucc (Fin.last m)) ≤
      a (Fin.castSucc 0) + ∑ i : Fin m, b (Fin.castSucc i) at h_ih
    have hcs0 : Fin.castSucc (0 : Fin (m + 1)) = (0 : Fin (m + 2)) := by
      ext; simp
    have hls : (Fin.last m).succ = Fin.last (m + 1) := by
      ext; simp [Fin.last]
    rw [hcs0] at h_ih
    rw [hls] at h_last
    linarith

/-! ## Section 6: Filtration Chain -/

/-- A **filtration chain** is a sequence of presheaves with an extension bound
at each step. This models a filtration `F₀ ⊆ F₁ ⊆ ⋯ ⊆ Fₙ` where each
successive layer contributes bounded compression.

The key property `step_bound` encodes the extension inequality:
  `κ(Fᵢ₊₁) ≤ κ(Fᵢ) + κ(grᵢ)`. -/
structure FiltrationChain [Fintype C]
    (J : GrothendieckTopology C) where
  /-- Length of the filtration -/
  len : ℕ
  /-- The presheaf at each filtration level -/
  level : Fin (len + 1) → Cᵒᵖ ⥤ Type v
  /-- The graded piece at step `i` (represents `level(i+1)/level(i)`) -/
  graded : Fin len → Cᵒᵖ ⥤ Type v
  /-- Extension bound at each step -/
  step_bound : ∀ i : Fin len,
    sheafCompressionNumber J (level i.succ) ≤
      sheafCompressionNumber J (level i.castSucc) +
      sheafCompressionNumber J (graded i)

/-- The **graded compression bound**: sum of compression numbers of graded pieces. -/
def gradedCompressionBound [Fintype C]
    (J : GrothendieckTopology C)
    (fc : FiltrationChain J) : ℕ :=
  ∑ i : Fin fc.len, sheafCompressionNumber J (fc.graded i)

/-- **Theorem 3 (Filtration Subadditivity).**
For a filtration chain, the compression of the top level is bounded by the
compression of the bottom level plus the sum of graded piece compressions.

`κ(Fₙ) ≤ κ(F₀) + ∑ᵢ κ(grᵢ)`

Proved by applying the telescoping sum lemma to the sequence of compression
numbers, with each step controlled by the extension inequality. -/
theorem compression_filtration_chain_le [Fintype C]
    (J : GrothendieckTopology C)
    (fc : FiltrationChain J) :
    sheafCompressionNumber J (fc.level (Fin.last fc.len)) ≤
      sheafCompressionNumber J (fc.level 0) +
      gradedCompressionBound J fc := by
  exact telescoping_sum_bound fc.len
    (fun i => sheafCompressionNumber J (fc.level i))
    (fun i => sheafCompressionNumber J (fc.graded i))
    fc.step_bound

/-! ## Section 7: Grounded Filtration -/

/-- A **grounded filtration** is one where the bottom level has compression 0
(trivial presheaf). This models the case `F₀ = 0`. -/
structure GroundedFiltration [Fintype C]
    (J : GrothendieckTopology C) extends FiltrationChain J where
  /-- The bottom level has compression 0 -/
  bottom_zero : sheafCompressionNumber J (level 0) = 0

/-- **Theorem 4 (Grounded Filtration Bound).**
When the bottom level is trivial, compression of the top is bounded by
the sum of graded piece compressions alone.

`κ(F) ≤ ∑ᵢ κ(grᵢ)` -/
theorem compression_grounded_filtration_le [Fintype C]
    (J : GrothendieckTopology C)
    (gf : GroundedFiltration J) :
    sheafCompressionNumber J (gf.level (Fin.last gf.len)) ≤
      gradedCompressionBound J gf.toFiltrationChain := by
  have h := compression_filtration_chain_le J gf.toFiltrationChain
  linarith [gf.bottom_zero]

/-! ## Section 8: Compression Respects Isomorphisms -/

/-- **Theorem 5 (Isomorphism Invariance).**
If two presheaves have the same separation structure (every probe family
separates one iff it separates the other), they have the same compression
number. This is the analogue of isomorphism invariance of entropy. -/
theorem compression_eq_of_sep_equiv [Fintype C]
    (J : GrothendieckTopology C)
    (F G : Cᵒᵖ ⥤ Type v)
    (h : ∀ P : Finset C, PresheafSeparatedByProbes P F ↔ PresheafSeparatedByProbes P G) :
    sheafCompressionNumber J F = sheafCompressionNumber J G := by
  unfold sheafCompressionNumber sheafCompressionCards
  congr 1; ext n
  constructor <;> rintro ⟨P, hP_card, hP_sep, hP_compat⟩
  · exact ⟨P, hP_card, (h P).mp hP_sep, hP_compat⟩
  · exact ⟨P, hP_card, (h P).mpr hP_sep, hP_compat⟩

/-! ## Section 9: Monotonicity under Separation Weakening -/

/-- **Theorem 6 (Monotonicity).**
If every probe family separating `G` also separates `F`,
then `κ(F) ≤ κ(G)`. This formalizes the principle that "simpler" presheaves
(easier to separate) have smaller compression numbers. -/
theorem compression_le_of_sep_implies [Fintype C]
    (J : GrothendieckTopology C)
    (F G : Cᵒᵖ ⥤ Type v)
    (h : ∀ P : Finset C, PresheafSeparatedByProbes P G → PresheafSeparatedByProbes P F)
    (hG : (sheafCompressionCards J G).Nonempty) :
    sheafCompressionNumber J F ≤ sheafCompressionNumber J G := by
  unfold sheafCompressionNumber
  apply Nat.sInf_le
  have := Nat.sInf_mem hG
  obtain ⟨P, hP_card, hP_sep, hP_compat⟩ := this
  exact ⟨P, hP_card, h P hP_sep, hP_compat⟩

/-! ## Section 10: Split Decomposition -/

/-- A **split decomposition** records that a presheaf decomposes as a
finite coproduct with matching separation structure. -/
structure SplitDecomposition [Fintype C]
    (J : GrothendieckTopology C)
    (F : Cᵒᵖ ⥤ Type v) where
  /-- Number of pieces -/
  nPieces : ℕ
  hPos : 0 < nPieces
  /-- The constituent presheaves -/
  pieces : Fin nPieces → Cᵒᵖ ⥤ Type v
  /-- Each piece has nonempty compression cards -/
  pieces_nonempty : ∀ i, (sheafCompressionCards J (pieces i)).Nonempty
  /-- Separation equivalence: a probe family separates F iff it separates ∐ pieces -/
  sep_equiv : ∀ P : Finset C,
    PresheafSeparatedByProbes P F ↔
    PresheafSeparatedByProbes P (FinCoprod nPieces pieces)

/-- **Theorem 7 (Split Decomposition Upper Bound).**
Under a split decomposition, compression of the whole is bounded by
the sum of compressions of the pieces. -/
theorem compression_split_le [Fintype C]
    (J : GrothendieckTopology C)
    (F : Cᵒᵖ ⥤ Type v)
    (dec : SplitDecomposition J F) :
    sheafCompressionNumber J F ≤
      ∑ i : Fin dec.nPieces, sheafCompressionNumber J (dec.pieces i) := by
  have h_eq : sheafCompressionNumber J F =
      sheafCompressionNumber J (FinCoprod dec.nPieces dec.pieces) :=
    compression_eq_of_sep_equiv J F _ dec.sep_equiv
  rw [h_eq]
  exact compression_finCoprod_le J dec.nPieces dec.hPos dec.pieces dec.pieces_nonempty

/-! ## Section 11: Filtration Upper Bound (Computational) -/

/-- The **filtration upper bound**: total compression estimate from a filtration chain.
This is the key computational quantity: given explicit filtration data, one computes
this bound to estimate the compression of the top-level presheaf. -/
def filtrationUpperBound [Fintype C]
    (J : GrothendieckTopology C)
    (fc : FiltrationChain J) : ℕ :=
  sheafCompressionNumber J (fc.level 0) + gradedCompressionBound J fc

/-- **Theorem 8 (Filtration Upper Bound Validity).**
The filtration upper bound is always a valid upper bound on the compression
of the top-level presheaf. -/
theorem compression_le_filtrationUpperBound [Fintype C]
    (J : GrothendieckTopology C)
    (fc : FiltrationChain J) :
    sheafCompressionNumber J (fc.level (Fin.last fc.len)) ≤
      filtrationUpperBound J fc :=
  compression_filtration_chain_le J fc

/-! ## Section 12: Compression Defect (Mutual Information Analogue) -/

/-- The **compression defect** measures how much the subadditivity inequality
is not tight. Defined over `ℤ` to avoid truncation. This is the
sheaf-theoretic analogue of mutual information `I(X;Y) = H(X) + H(Y) - H(X,Y)`. -/
def compressionDefect [Fintype C] (J : GrothendieckTopology C)
    (F G : Cᵒᵖ ⥤ Type v) : ℤ :=
  (sheafCompressionNumber J F : ℤ) + (sheafCompressionNumber J G : ℤ) -
  (sheafCompressionNumber J (PresheafCoprod F G) : ℤ)

/-- **Theorem 9 (Nonnegativity of Compression Defect).**
The compression defect is nonnegative, establishing it as a valid
information-theoretic quantity. This is the `I(X;Y) ≥ 0` analogue. -/
theorem compressionDefect_nonneg [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v)
    (hF : (sheafCompressionCards J F).Nonempty)
    (hG : (sheafCompressionCards J G).Nonempty) :
    0 ≤ compressionDefect J F G := by
  unfold compressionDefect
  have h := compression_extension_le J F G hF hG
  omega

/-! ## Section 13: Three-Piece Filtration -/

/-- **Theorem 10 (Three-Piece Filtration Bound).**
For a filtration of length 2 (three levels), the compression of the top
is bounded by the sum of the bottom plus two graded pieces. This is a
concrete instance of the general filtration bound, useful as a building
block for inductive arguments. -/
theorem compression_three_piece [Fintype C]
    (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v)
    (hF : (sheafCompressionCards J F).Nonempty)
    (hG : (sheafCompressionCards J G).Nonempty)
    (hH : (sheafCompressionCards J H).Nonempty)
    (hFG : (sheafCompressionCards J (PresheafCoprod F G)).Nonempty) :
    sheafCompressionNumber J (PresheafCoprod (PresheafCoprod F G) H) ≤
      sheafCompressionNumber J F + sheafCompressionNumber J G +
      sheafCompressionNumber J H := by
  calc sheafCompressionNumber J (PresheafCoprod (PresheafCoprod F G) H)
      ≤ sheafCompressionNumber J (PresheafCoprod F G) + sheafCompressionNumber J H :=
        compression_extension_le J (PresheafCoprod F G) H hFG hH
    _ ≤ (sheafCompressionNumber J F + sheafCompressionNumber J G) +
        sheafCompressionNumber J H := by
        linarith [compression_extension_le J F G hF hG]

end CompressionFiltration

end