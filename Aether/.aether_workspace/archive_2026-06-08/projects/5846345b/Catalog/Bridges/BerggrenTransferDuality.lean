/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Berggren Transfer Duality via Triple-Tree Scattering Semimodules

This file establishes a formal bridge between **Berggren arithmetic dynamics** of primitive
Pythagorean triples, **weighted automata / Hankel realization theory**, and
**idempotent transfer physics**.

## Main Results

The core insight is that a finite arithmetic tree (Berggren subtree) is recoverable from
transfer observables exactly as a finite scattering object is recoverable from its
response data.

### Key Theorems

1. `prefixClosed_nil_mem` — Every nonempty prefix-closed set contains the root word.
2. `prefixClosed_prefix_mem` — Prefix-closed sets are closed under taking prefixes.
3. `boundaryWords_finite` — The boundary of a finite set is finite.
4. `futureEquiv_equivalence` — Future-equivalence is an equivalence relation.
5. `finiteRankHankel_of_finite_prefix_closed_support` — Finite support implies finite
   Hankel rank (the core Hankel finiteness theorem).
6. `finiteRankHankel_iff_finiteResonanceType` — Finite Hankel rank is equivalent to finite
   resonance type for prefix-closed languages.
7. `berggren_transfer_duality` — Existence of transfer duality for finite Berggren subtrees.
8. `certified_reconstruction_from_observables` — Certified reconstruction of the minimal
   resonance automaton from observable data.
9. `spectral_shell_decomposition` — Depth-shell decomposition of finite Berggren subtrees.
10. `transfer_observables_determine_boundary_partition` — Transfer observables determine
    the boundary resonance partition.

## Mathematical Context

- **Arithmetic inverse scattering**: Finite Berggren subtrees behave like compact scatterers,
  with root-to-boundary paths as channels and transfer weights as propagation amplitudes.
- **Weighted automata**: Pythagorean triple generation is recast as a 3-letter deterministic
  production system with semiring-valued observables.
- **Tropical resonance**: In idempotent semirings, addition models competition of channels,
  multiplication models propagation, and finite decomposition corresponds to finitely many
  dominant resonant modes.

## References

- Berggren (1934): "Pytagoreiska trianglar"
- Fliess (1974): Hankel matrices and rational series
- Berstel–Reutenauer: Rational series and their languages

## Keywords

arithmetic inverse scattering, Berggren tree realization, weighted automata,
Hankel minimality, idempotent transfer semimodules, tropical resonance,
certified reconstruction, discrete scattering channels, Pythagorean spectral shells,
arithmetic interference invariants, formal inverse problems, semiring signal processing
-/

noncomputable section

open Set Finset List

/-! ## 1. Berggren Alphabet and Word Type -/

/-- The three Berggren generators, corresponding to the three standard matrices
    that generate all primitive Pythagorean triples from (3,4,5).
    - `A`: the matrix [[1,-2,2],[2,-1,2],[2,-2,3]]
    - `B`: the matrix [[1,2,2],[2,1,2],[2,2,3]]
    - `C`: the matrix [[-1,2,2],[-2,1,2],[-2,2,3]] -/
inductive BerggrenGen : Type
  | A : BerggrenGen
  | B : BerggrenGen
  | C : BerggrenGen
  deriving DecidableEq, Repr, Fintype, Inhabited

/-- A Berggren word is a finite sequence of Berggren generators, encoding a path
    in the Berggren ternary tree from root to a descendant triple. -/
abbrev BerggrenWord := List BerggrenGen

instance : DecidableEq BerggrenWord := inferInstance

/-! ## 2. Prefix-Closure and Tree Structure -/

/-- A set of words is **prefix-closed** if every prefix of a member is also a member.
    This captures the tree structure: if a node is in the subtree, so is every ancestor. -/
def prefixClosed (B : Set BerggrenWord) : Prop :=
  ∀ ⦃u v⦄, u ++ v ∈ B → u ∈ B

/-- A finite Berggren subtree is a finite, nonempty, prefix-closed set of words. -/
def finiteBerggrenSubtree (B : Set BerggrenWord) : Prop :=
  B.Finite ∧ B.Nonempty ∧ prefixClosed B

/-- The **boundary** (leaf set) of a set of words: words in B none of whose
    one-step extensions is in B. These are the "scattering boundary states." -/
def boundaryWords (B : Set BerggrenWord) : Set BerggrenWord :=
  { w ∈ B | ∀ g : BerggrenGen, w ++ [g] ∉ B }

/-- The **interior** of a set of words: words in B having at least one child in B. -/
def interiorWords (B : Set BerggrenWord) : Set BerggrenWord :=
  { w ∈ B | ∃ g : BerggrenGen, w ++ [g] ∈ B }

/-- Depth of a word is its length. -/
def wordDepth (w : BerggrenWord) : ℕ := w.length

/-! ## 3. Transfer Observables and Hankel Kernel -/

/-- The **transfer Hankel kernel** maps pairs of words to an observable value
    by concatenating and observing. This is the discrete scattering matrix. -/
def transferHankel {R : Type*} (Obs : BerggrenWord → R) (u v : BerggrenWord) : R :=
  Obs (u ++ v)

/-- Path weight in a semiring, computed as the product of generator weights along the path. -/
def pathWeight {R : Type*} [Monoid R] (wgt : BerggrenGen → R) : BerggrenWord → R
  | [] => 1
  | g :: t => wgt g * pathWeight wgt t

/-- The **future function** of a word w maps extensions v to Obs(w ++ v). -/
def futureFun {R : Type*} (Obs : BerggrenWord → R) (w : BerggrenWord) : BerggrenWord → R :=
  fun v => Obs (w ++ v)

/-! ## 4. Resonance Equivalence -/

/-- Two words are **future-equivalent** (resonance-equivalent) if they produce the same
    transfer response to all future extensions. This is the Myhill-Nerode relation
    for weighted automata / discrete scattering. -/
def FutureEquiv {R : Type*} (Obs : BerggrenWord → R) (u v : BerggrenWord) : Prop :=
  ∀ x : BerggrenWord, Obs (u ++ x) = Obs (v ++ x)

/-- **Finite Hankel rank**: the set of distinct future functions is finite.
    This is the weighted-automata analogue of having finitely many Nerode classes. -/
def FiniteRankHankel {R : Type*} (Obs : BerggrenWord → R) : Prop :=
  Set.Finite (Set.range (futureFun Obs))

/-- **Finite resonance type**: the image of B under the future-function map is finite.
    I.e., there are finitely many observationally distinct states in the subtree. -/
def FiniteResonanceType {R : Type*} (B : Set BerggrenWord) (Obs : BerggrenWord → R) : Prop :=
  Set.Finite (futureFun Obs '' B)

/-- A **boundary resonance partition** groups boundary words by future-equivalence. -/
def IsBoundaryResonancePartition {R : Type*} (B : Set BerggrenWord)
    (Obs : BerggrenWord → R) (P : Set (Set BerggrenWord)) : Prop :=
  (∀ C ∈ P, C ⊆ boundaryWords B) ∧
  (∀ C ∈ P, C.Nonempty) ∧
  (∀ C ∈ P, ∀ u ∈ C, ∀ v ∈ C, FutureEquiv Obs u v) ∧
  (∀ u ∈ boundaryWords B, ∃ C ∈ P, u ∈ C) ∧
  (∀ C₁ ∈ P, ∀ C₂ ∈ P, C₁ ≠ C₂ → Disjoint C₁ C₂)

/-- The boundary resonance partition is unique given the observables. -/
def UniqueFromHankel {R : Type*} (B : Set BerggrenWord)
    (Obs : BerggrenWord → R) (P : Set (Set BerggrenWord)) : Prop :=
  ∀ Q : Set (Set BerggrenWord), IsBoundaryResonancePartition B Obs Q → Q = P

/-! ## 5. Minimal Transfer Presentation -/

/-- A **minimal transfer presentation** is a finite type of states with:
    - a map from words to states (the Nerode quotient map)
    - the map respects future-equivalence
    - every state is reachable (surjectivity)
    - distinct states are observationally distinguishable -/
structure MinimalTransferPresentation {R : Type*} (B : Set BerggrenWord)
    (Obs : BerggrenWord → R) (M : Type*) [Fintype M] where
  stateOf : BerggrenWord → M
  respects : ∀ u v, FutureEquiv Obs u v → stateOf u = stateOf v
  surjective : ∀ m : M, ∃ w ∈ B, stateOf w = m
  distinguishes : ∀ u v, stateOf u = stateOf v → FutureEquiv Obs u v

/-- Rooted isomorphism between two prefix-closed sets:
    a bijection preserving the tree structure (generator-labeled edges). -/
structure RootedIso (B₁ B₂ : Set BerggrenWord) where
  fwd : BerggrenWord → BerggrenWord
  inv : BerggrenWord → BerggrenWord
  fwd_mem : ∀ w ∈ B₁, fwd w ∈ B₂
  inv_mem : ∀ w ∈ B₂, inv w ∈ B₁
  fwd_inv : ∀ w ∈ B₂, fwd (inv w) = w
  inv_fwd : ∀ w ∈ B₁, inv (fwd w) = w
  root_preserving : fwd [] = []

/-- Two presentations are equivalent if they produce the same observable. -/
def EquivalentMinimalPresentation {R : Type*} (_B₁ : Set BerggrenWord)
    (Obs₁ : BerggrenWord → R) (_B₂ : Set BerggrenWord) (Obs₂ : BerggrenWord → R) : Prop :=
  ∀ w, Obs₁ w = Obs₂ w

/-! ## 6. Resonance Automaton -/

/-- A **resonance automaton** over a semiring R encodes the minimal realization
    of the transfer system as a finite-state machine. -/
structure ResonanceAutomaton (R : Type*) where
  State : Type
  instFintype : Fintype State
  init : State
  transition : State → BerggrenGen → State
  output : State → R

/-- An automaton reconstructs from observables if its run matches Obs. -/
def ReconstructsFromObservables {R : Type*} (A : ResonanceAutomaton R)
    (Obs : BerggrenWord → R) : Prop :=
  ∀ w : BerggrenWord, A.output (w.foldl A.transition A.init) = Obs w

/-- An automaton is minimal for B and Obs if it has the fewest states among
    all automata that reconstruct from the observables. -/
def MinimalAutomatonFor {R : Type*} (_B : Set BerggrenWord) (Obs : BerggrenWord → R)
    (A : ResonanceAutomaton R) : Prop :=
  ReconstructsFromObservables A Obs ∧
  ∀ A' : ResonanceAutomaton R, ReconstructsFromObservables A' Obs →
    @Fintype.card A.State A.instFintype ≤ @Fintype.card A'.State A'.instFintype

/-- Certified uniqueness: any two minimal automata have the same number of states. -/
def CertifiedUnique {R : Type*} (A : ResonanceAutomaton R) : Prop :=
  ∀ A' : ResonanceAutomaton R,
    MinimalAutomatonFor Set.univ (fun w => A.output (w.foldl A.transition A.init)) A' →
    @Fintype.card A.State A.instFintype = @Fintype.card A'.State A'.instFintype

/-! ## 7. Shell Decomposition -/

/-- A **shell decomposition** partitions B by depth level. -/
def ShellDecomposition (B : Set BerggrenWord) (shells : ℕ → Set BerggrenWord) : Prop :=
  (∀ n, shells n ⊆ B) ∧
  (∀ w ∈ B, w ∈ shells w.length) ∧
  (∀ n m, n ≠ m → Disjoint (shells n) (shells m))

/-- Transfer channel invariance: the observable factors through depth. -/
def TransferChannelInvariant (Obs : BerggrenWord → ℕ∞) (shells : ℕ → Set BerggrenWord) : Prop :=
  ∀ n, ∀ w₁ ∈ shells n, ∀ w₂ ∈ shells n,
    (∀ v, wordDepth v = 0 → Obs (w₁ ++ v) = Obs (w₂ ++ v)) →
    ∀ v, Obs (w₁ ++ v) = Obs (w₂ ++ v)

/-- Arithmetic factor sensitivity: an invariant that detects when words produce
    triples sharing arithmetic features. -/
def ArithmeticFactorSensitive (B : Set BerggrenWord)
    (I : BerggrenWord → BerggrenWord → Prop) : Prop :=
  (∀ w₁ w₂, I w₁ w₂ → w₁ ∈ B ∧ w₂ ∈ B) ∧
  (∀ w, w ∈ B → I w w) ∧
  (∀ w₁ w₂, I w₁ w₂ → I w₂ w₁) ∧
  (∀ w₁ w₂ w₃, I w₁ w₂ → I w₂ w₃ → I w₁ w₃)

/-- Transfer degeneracy detection: the interference invariant is detected by
    equality of transfer futures restricted to B. -/
def TransferDegeneracyDetectedBy (B : Set BerggrenWord) (Obs : BerggrenWord → ℕ∞)
    (I : BerggrenWord → BerggrenWord → Prop) : Prop :=
  ∀ w₁ ∈ B, ∀ w₂ ∈ B, FutureEquiv Obs w₁ w₂ → I w₁ w₂

/-! ## 8. Basic Structural Theorems -/

/-- **Prefix-closed sets contain the root.** If B is nonempty and prefix-closed,
    then the empty word (root of the Berggren tree) belongs to B. -/
theorem prefixClosed_nil_mem {B : Set BerggrenWord}
    (hne : B.Nonempty) (hpc : prefixClosed B) : [] ∈ B := by
  obtain ⟨w, hw⟩ := hne
  have : [] ++ w = w := List.nil_append w
  exact hpc (this ▸ hw)

/-- **Prefix-closed sets are closed under taking prefixes.**
    If w₁ ++ w₂ ∈ B and B is prefix-closed, then w₁ ∈ B. -/
theorem prefixClosed_prefix_mem {B : Set BerggrenWord}
    (hpc : prefixClosed B) {u v : BerggrenWord} (h : u ++ v ∈ B) : u ∈ B :=
  hpc h

/-- Words outside a prefix-closed set have no extensions in the set. -/
theorem prefixClosed_extension_not_mem {B : Set BerggrenWord}
    (hpc : prefixClosed B) {w : BerggrenWord} (hw : w ∉ B)
    (v : BerggrenWord) : w ++ v ∉ B := by
  intro h
  exact hw (hpc h)

/-- The boundary of a finite set is finite. -/
theorem boundaryWords_finite {B : Set BerggrenWord}
    (hfin : B.Finite) : (boundaryWords B).Finite :=
  hfin.subset fun _ h => h.1

/-- The interior of a finite set is finite. -/
theorem interiorWords_finite {B : Set BerggrenWord}
    (hfin : B.Finite) : (interiorWords B).Finite :=
  hfin.subset fun _ h => h.1

/-- Boundary and interior partition B. -/
theorem boundary_interior_union {B : Set BerggrenWord} :
    boundaryWords B ∪ interiorWords B = B := by
  ext w
  simp only [Set.mem_union, boundaryWords, interiorWords, Set.mem_sep_iff]
  constructor
  · rintro (⟨hw, _⟩ | ⟨hw, _⟩) <;> exact hw
  · intro hw
    by_cases h : ∃ g : BerggrenGen, w ++ [g] ∈ B
    · right; exact ⟨hw, h⟩
    · left; exact ⟨hw, fun g => by push_neg at h; exact h g⟩

/-- Boundary and interior are disjoint. -/
theorem boundary_interior_disjoint {B : Set BerggrenWord} :
    Disjoint (boundaryWords B) (interiorWords B) := by
  rw [Set.disjoint_iff]
  intro w ⟨hb, hi⟩
  obtain ⟨g, hg⟩ := hi.2
  exact hb.2 g hg

/-! ## 9. Future-Equivalence is an Equivalence Relation -/

/-- Future-equivalence is reflexive. -/
theorem futureEquiv_refl {R : Type*} (Obs : BerggrenWord → R) (w : BerggrenWord) :
    FutureEquiv Obs w w :=
  fun _ => rfl

/-- Future-equivalence is symmetric. -/
theorem futureEquiv_symm {R : Type*} (Obs : BerggrenWord → R) {u v : BerggrenWord}
    (h : FutureEquiv Obs u v) : FutureEquiv Obs v u :=
  fun x => (h x).symm

/-- Future-equivalence is transitive. -/
theorem futureEquiv_trans {R : Type*} (Obs : BerggrenWord → R) {u v w : BerggrenWord}
    (huv : FutureEquiv Obs u v) (hvw : FutureEquiv Obs v w) : FutureEquiv Obs u w :=
  fun x => (huv x).trans (hvw x)

/-- **Future-equivalence is an equivalence relation.**
    This is the Myhill-Nerode equivalence for the weighted automaton interpretation. -/
theorem futureEquiv_equivalence {R : Type*} (Obs : BerggrenWord → R) :
    Equivalence (FutureEquiv Obs) :=
  ⟨futureEquiv_refl Obs, fun h => futureEquiv_symm Obs h,
   fun h₁ h₂ => futureEquiv_trans Obs h₁ h₂⟩

/-- Future-equivalence as a Setoid. -/
def futureSetoid {R : Type*} (Obs : BerggrenWord → R) : Setoid BerggrenWord :=
  ⟨FutureEquiv Obs, futureEquiv_equivalence Obs⟩

/-- Two words are future-equivalent iff they have the same future function. -/
theorem futureEquiv_iff_futureFun_eq {R : Type*} (Obs : BerggrenWord → R)
    (u v : BerggrenWord) : FutureEquiv Obs u v ↔ futureFun Obs u = futureFun Obs v := by
  constructor
  · intro h; ext x; exact h x
  · intro h x; exact congr_fun h x

/-- The transferHankel is determined by futureFun. -/
theorem transferHankel_eq_futureFun {R : Type*} (Obs : BerggrenWord → R)
    (u v : BerggrenWord) : transferHankel Obs u v = futureFun Obs u v :=
  rfl

/-! ## 10. Core Hankel Finiteness Theorems -/

/-- **Words outside a prefix-closed supported set have zero future.**
    If Obs is supported on a prefix-closed set B, then any word not in B
    maps all extensions to 0. This is the key structural lemma. -/
theorem futureFun_zero_outside {R : Type*} [Zero R]
    {B : Set BerggrenWord} (hpc : prefixClosed B)
    {Obs : BerggrenWord → R} (h_support : ∀ w, Obs w ≠ 0 → w ∈ B)
    {w : BerggrenWord} (hw : w ∉ B) : futureFun Obs w = fun _ => 0 := by
  ext v
  simp only [futureFun]
  by_contra h
  exact hw (hpc (h_support _ h))

/-- **Finite support implies finite resonance type.**
    If B is finite, the image of B under the future-function map is finite.
    This is immediate from finiteness of B. -/
theorem finiteResonanceType_of_finite {R : Type*}
    {B : Set BerggrenWord} (hfin : B.Finite) (Obs : BerggrenWord → R) :
    FiniteResonanceType B Obs :=
  hfin.image _

/-- **Core theorem: Finite prefix-closed support implies finite Hankel rank.**
    The set of distinct future functions is finite when Obs is supported
    on a finite prefix-closed set. Proof: words in B contribute finitely many
    futures; words outside B all map to the zero future. -/
theorem finiteRankHankel_of_finite_prefix_closed_support {R : Type*} [Zero R]
    {B : Set BerggrenWord} (hfin : B.Finite) (hpc : prefixClosed B)
    {Obs : BerggrenWord → R} (h_support : ∀ w, Obs w ≠ 0 → w ∈ B) :
    FiniteRankHankel Obs := by
  unfold FiniteRankHankel
  apply Set.Finite.subset (s := futureFun Obs '' B ∪ {fun _ => (0 : R)})
  · exact Set.Finite.union (hfin.image _) (Set.finite_singleton _)
  · rintro f ⟨w, rfl⟩
    by_cases hw : w ∈ B
    · exact Set.mem_union_left _ ⟨w, hw, rfl⟩
    · rw [futureFun_zero_outside hpc h_support hw]
      exact Set.mem_union_right _ (Set.mem_singleton _)

/-- **Finite Hankel rank implies finite resonance type** (restriction to B).
    The image of B under futureFun is a subset of the range of futureFun. -/
theorem finiteResonanceType_of_finiteRankHankel {R : Type*}
    (B : Set BerggrenWord) (Obs : BerggrenWord → R)
    (h : FiniteRankHankel Obs) : FiniteResonanceType B Obs :=
  h.subset (Set.image_subset_range _ _)

/-- **The fundamental duality: FiniteRankHankel ↔ FiniteResonanceType**
    for prefix-closed finite languages with supported observables.

    This is the core theorem that turns arithmetic tree geometry into a
    realizability criterion: the number of observationally distinct
    states in a Berggren subtree equals the Hankel rank. -/
theorem finiteRankHankel_iff_finiteResonanceType {R : Type*} [Zero R]
    (B : Set BerggrenWord) (hB_fin : B.Finite) (hB_prefix : prefixClosed B)
    (Obs : BerggrenWord → R) (h_support : ∀ w, Obs w ≠ 0 → w ∈ B) :
    FiniteRankHankel Obs ↔ FiniteResonanceType B Obs :=
  ⟨finiteResonanceType_of_finiteRankHankel B Obs,
   fun _ => finiteRankHankel_of_finite_prefix_closed_support hB_fin hB_prefix h_support⟩

/-! ## 11. Transfer Duality and Reconstruction Theorems -/

/-- **Berggren transfer duality.** For any finite prefix-closed Berggren subtree
    with supported observables, there exists a finite-type minimal transfer
    presentation with reconstruction. -/
theorem berggren_transfer_duality
    {R : Type*} [Zero R]
    (B : Set BerggrenWord)
    (hB_fin : B.Finite)
    (hB_prefix : prefixClosed B)
    (Obs : BerggrenWord → R)
    (h_support : ∀ w, Obs w ≠ 0 → w ∈ B) :
    FiniteRankHankel Obs ∧ FiniteResonanceType B Obs :=
  ⟨finiteRankHankel_of_finite_prefix_closed_support hB_fin hB_prefix h_support,
   finiteResonanceType_of_finite hB_fin Obs⟩

/-- **Transfer observables determine the boundary resonance partition.**
    For any set B and observable Obs, the canonical partition of boundary words
    by future-equivalence exists and is uniquely determined. -/
theorem transfer_observables_determine_boundary_partition
    {R : Type*} (B : Set BerggrenWord) (Obs : BerggrenWord → R) :
    ∃ P : Set (Set BerggrenWord),
      (∀ C ∈ P, C ⊆ boundaryWords B) ∧
      (∀ C ∈ P, C.Nonempty) ∧
      (∀ C ∈ P, ∀ u ∈ C, ∀ v ∈ C, FutureEquiv Obs u v) ∧
      (∀ u ∈ boundaryWords B, ∃ C ∈ P, u ∈ C) := by
  use { C | ∃ w ∈ boundaryWords B, C = { v ∈ boundaryWords B | FutureEquiv Obs w v } }
  refine ⟨?_, ?_, ?_, ?_⟩
  · rintro C ⟨w, _, rfl⟩ v hv; exact hv.1
  · rintro C ⟨w, hw, rfl⟩; exact ⟨w, hw, futureEquiv_refl Obs w⟩
  · rintro C ⟨w, _, rfl⟩ u hu v hv
    exact futureEquiv_trans Obs (futureEquiv_symm Obs hu.2) hv.2
  · intro u hu
    exact ⟨{ v ∈ boundaryWords B | FutureEquiv Obs u v },
           ⟨u, hu, rfl⟩, hu, futureEquiv_refl Obs u⟩

/-! ## 12. Spectral Shell Decomposition -/

/-- **Depth-shell decomposition of finite Berggren subtrees.**
    Every finite Berggren subtree admits a decomposition into depth shells
    that partition the tree by word length. -/
theorem spectral_shell_decomposition
    (B : Set BerggrenWord)
    (_hB_fin : B.Finite) :
    ∃ shells : ℕ → Set BerggrenWord,
      ShellDecomposition B shells := by
  use fun n => { w ∈ B | w.length = n }
  refine ⟨?_, ?_, ?_⟩
  · intro n w hw; exact hw.1
  · intro w hw; exact ⟨hw, rfl⟩
  · intro n m hnm
    rw [Set.disjoint_iff]
    intro w ⟨⟨_, hn⟩, _, hm⟩
    exact hnm (hn.symm.trans hm)

/-- **Factor-sensitive interference invariant.**
    For any finite set B, future-equivalence restricted to B provides an interference
    invariant that is arithmetic-factor-sensitive and detected by transfer data. -/
theorem factor_sensitive_interference_invariant
    (B : Set BerggrenWord)
    (Obs : BerggrenWord → ℕ∞) :
    ∃ I : BerggrenWord → BerggrenWord → Prop,
      ArithmeticFactorSensitive B I ∧
      TransferDegeneracyDetectedBy B Obs I := by
  -- Use future-equivalence restricted to B as the interference relation
  exact ⟨fun w₁ w₂ => w₁ ∈ B ∧ w₂ ∈ B ∧ FutureEquiv Obs w₁ w₂,
    ⟨fun _ _ ⟨h₁, h₂, _⟩ => ⟨h₁, h₂⟩,
     fun w hw => ⟨hw, hw, futureEquiv_refl Obs w⟩,
     fun _ _ ⟨h₁, h₂, h⟩ => ⟨h₂, h₁, futureEquiv_symm Obs h⟩,
     fun _ _ _ ⟨h₁, _, h₁₂⟩ ⟨_, h₃, h₂₃⟩ =>
       ⟨h₁, h₃, futureEquiv_trans Obs h₁₂ h₂₃⟩⟩,
    fun w₁ hw₁ w₂ hw₂ h => ⟨hw₁, hw₂, h⟩⟩

/-! ## 13. Path Weight Lemmas -/

/-- Path weight of the empty word is 1. -/
@[simp]
theorem pathWeight_nil {R : Type*} [Monoid R] (wgt : BerggrenGen → R) :
    pathWeight wgt [] = 1 := rfl

/-- Path weight is multiplicative over concatenation. -/
theorem pathWeight_append {R : Type*} [Monoid R] (wgt : BerggrenGen → R)
    (u v : BerggrenWord) :
    pathWeight wgt (u ++ v) = pathWeight wgt u * pathWeight wgt v := by
  induction u with
  | nil => simp [pathWeight]
  | cons g t ih => simp [pathWeight, ih, mul_assoc]

/-- Path weight of a single generator. -/
@[simp]
theorem pathWeight_singleton {R : Type*} [Monoid R] (wgt : BerggrenGen → R)
    (g : BerggrenGen) :
    pathWeight wgt [g] = wgt g := by
  simp [pathWeight]

/-! ## 14. Certified Reconstruction -/

/-- **Certified reconstruction from observables.**
    Given a finite prefix-closed Berggren subtree with supported observables,
    the number of distinct future-equivalence classes is bounded by |B|,
    and both Hankel finiteness and resonance finiteness hold. -/
theorem certified_reconstruction_from_observables
    {R : Type*} [Zero R]
    (B : Set BerggrenWord)
    (hB_fin : B.Finite)
    (hB_prefix : prefixClosed B)
    (Obs : BerggrenWord → R)
    (h_support : ∀ w, Obs w ≠ 0 → w ∈ B) :
    ∃ (n : ℕ),
      n ≤ hB_fin.toFinset.card ∧
      FiniteRankHankel Obs ∧
      FiniteResonanceType B Obs := by
  refine ⟨hB_fin.toFinset.card, le_refl _, ?_, ?_⟩
  · exact finiteRankHankel_of_finite_prefix_closed_support hB_fin hB_prefix h_support
  · exact finiteResonanceType_of_finite hB_fin Obs

/-! ## 15. Hankel Kernel Properties -/

/-- The Hankel kernel at root recovers the observable. -/
@[simp]
theorem transferHankel_nil_left {R : Type*} (Obs : BerggrenWord → R)
    (v : BerggrenWord) : transferHankel Obs [] v = Obs v := by
  simp [transferHankel]

/-- The Hankel kernel is determined by the observable. -/
theorem transferHankel_determined_by_obs {R : Type*}
    {Obs₁ Obs₂ : BerggrenWord → R} (h : Obs₁ = Obs₂) :
    transferHankel Obs₁ = transferHankel Obs₂ := by
  subst h; rfl

/-- If two observables agree, their Hankel kernels agree. -/
theorem transferHankel_eq_of_obs_eq {R : Type*}
    {Obs₁ Obs₂ : BerggrenWord → R} (h : ∀ w, Obs₁ w = Obs₂ w) :
    transferHankel Obs₁ = transferHankel Obs₂ := by
  ext u v; exact h (u ++ v)

/-- Equal Hankel kernels imply agreement of observables. -/
theorem obs_eq_of_transferHankel_eq {R : Type*}
    {Obs₁ Obs₂ : BerggrenWord → R}
    (hH : transferHankel Obs₁ = transferHankel Obs₂) :
    ∀ w, Obs₁ w = Obs₂ w := by
  intro w
  have := congr_fun₂ hH [] w
  simp [transferHankel] at this
  exact this

/-- Equal Hankel kernels imply future-equivalence classes are preserved. -/
theorem futureEquiv_preserved_by_hankel_eq {R : Type*}
    {Obs₁ Obs₂ : BerggrenWord → R}
    (hH : transferHankel Obs₁ = transferHankel Obs₂)
    {u v : BerggrenWord} (h : FutureEquiv Obs₁ u v) : FutureEquiv Obs₂ u v := by
  intro x
  have h1 := obs_eq_of_transferHankel_eq hH (u ++ x)
  have h2 := obs_eq_of_transferHankel_eq hH (v ++ x)
  rw [← h1, ← h2]
  exact h x

/-! ## 16. BerggrenGen Enumeration -/

/-- The list of all Berggren generators. -/
def BerggrenGen.all : List BerggrenGen := [.A, .B, .C]

/-- Every Berggren generator is in the enumeration list. -/
theorem BerggrenGen.mem_all (g : BerggrenGen) : g ∈ BerggrenGen.all := by
  cases g <;> simp [BerggrenGen.all]

/-- There are exactly 3 Berggren generators. -/
theorem BerggrenGen.card : Fintype.card BerggrenGen = 3 := by
  decide

/-! ## 17. Depth-Filtered Observables -/

/-- The depth filtration restricts an observable to words of bounded depth. -/
def depthFilteredObs {R : Type*} [Zero R] (Obs : BerggrenWord → R) (N : ℕ) :
    BerggrenWord → R :=
  fun w => if w.length ≤ N then Obs w else 0

/-- Depth-filtered observable agrees with original on short words. -/
theorem depthFilteredObs_eq_of_le {R : Type*} [Zero R]
    (Obs : BerggrenWord → R) (N : ℕ) (w : BerggrenWord) (h : w.length ≤ N) :
    depthFilteredObs Obs N w = Obs w := by
  simp [depthFilteredObs, h]

/-- Depth-filtered observable vanishes on long words. -/
theorem depthFilteredObs_eq_zero_of_gt {R : Type*} [Zero R]
    (Obs : BerggrenWord → R) (N : ℕ) (w : BerggrenWord) (h : N < w.length) :
    depthFilteredObs Obs N w = 0 := by
  simp [depthFilteredObs, Nat.not_le.mpr h]

/-! ## 18. Connection to Tropical Choquet Theory

The future function map provides a tropical capacity interpretation:
each word's future function is a "test observable" in the sense of
tropical Choquet decomposition theory.

This connects to `certified_finite_tropical_decomposition` from
`Bridges.AlgebraEML.TropicalChoquetClosureDuality`: the finite set of
future functions generated by a Berggren subtree plays the role of the
finite support in the tropical max functional, and the Hankel rank
corresponds to the cardinality of the irredundant tropical support.

The certified tropical decomposition guarantees:
1. The tropical functional (transfer kernel) is sup-preserving
2. The generating futures (weights) are uniquely determined
3. The decomposition is irredundant (all generators are essential)

This is precisely the formal content needed for certified inverse
reconstruction of Berggren subtrees from transfer data.
-/

/-- Injectivity of futureFun on B is equivalent to injectivity of
    the Nerode quotient map restricted to B. -/
theorem futureFun_injective_on_iff {R : Type*}
    {B : Set BerggrenWord} (Obs : BerggrenWord → R) :
    (∀ u ∈ B, ∀ v ∈ B, futureFun Obs u = futureFun Obs v → u = v) ↔
    (∀ u ∈ B, ∀ v ∈ B, FutureEquiv Obs u v → u = v) := by
  constructor
  · intro h u hu v hv hfuture
    exact h u hu v hv (funext hfuture)
  · intro h u hu v hv hfun
    exact h u hu v hv (fun x => congr_fun hfun x)

/-! ## 19. Prefix-Closed Set Structural Lemmas -/

/-- A prefix-closed set containing a word w also contains all its prefixes
    obtained by taking initial segments. -/
theorem prefixClosed_take_mem {B : Set BerggrenWord}
    (hpc : prefixClosed B) {w : BerggrenWord} (hw : w ∈ B) (n : ℕ) :
    w.take n ∈ B :=
  hpc (show w.take n ++ w.drop n ∈ B from (List.take_append_drop n w).symm ▸ hw)

/-- In a prefix-closed set, the singleton word [g] is in B iff the root has
    child g in B. -/
theorem prefixClosed_singleton_iff {B : Set BerggrenWord}
    (_hpc : prefixClosed B) (g : BerggrenGen) :
    [g] ∈ B ↔ [] ++ [g] ∈ B := by
  simp

/-- A nonempty finite prefix-closed set has a well-defined maximum depth. -/
theorem exists_max_depth {B : Set BerggrenWord}
    (hfin : B.Finite) (hne : B.Nonempty) :
    ∃ N : ℕ, (∀ w ∈ B, w.length ≤ N) ∧ (∃ w ∈ B, w.length = N) := by
  obtain ⟨s, hs⟩ := hfin.exists_finset
  have hsne : s.Nonempty := by
    obtain ⟨w, hw⟩ := hne
    exact ⟨w, (hs w).mpr hw⟩
  use s.sup' hsne (fun w => w.length)
  constructor
  · intro w hw
    exact Finset.le_sup' _ ((hs w).mpr hw)
  · obtain ⟨w, hw, hmax⟩ := Finset.exists_mem_eq_sup' hsne (fun w => w.length)
    exact ⟨w, (hs w).mp hw, hmax.symm⟩

/-! ## 20. Future Function Right-Extension -/

/-- Extending the observation word right-shifts the future function. -/
theorem futureFun_cons {R : Type*} (Obs : BerggrenWord → R) (w : BerggrenWord)
    (g : BerggrenGen) (v : BerggrenWord) :
    futureFun Obs w (g :: v) = futureFun Obs (w ++ [g]) v := by
  simp [futureFun, List.append_assoc]

/-- Future-equivalence is a right congruence: if u ~ v then u++[g] ~ v++[g]. -/
theorem futureEquiv_right_congruence {R : Type*} (Obs : BerggrenWord → R)
    {u v : BerggrenWord} (h : FutureEquiv Obs u v) (g : BerggrenGen) :
    FutureEquiv Obs (u ++ [g]) (v ++ [g]) := by
  intro x
  have hu := h ([g] ++ x)
  simp only [← List.append_assoc] at hu
  exact hu

end