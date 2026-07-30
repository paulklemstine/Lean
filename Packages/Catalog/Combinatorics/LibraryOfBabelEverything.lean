import Mathlib

/-!
# Borges' Library of Babel: finite topology and incompressibility

A book of length `L` over an alphabet of size `A` is a function
`Fin L → Fin A`, equipped here with Mathlib's Hamming metric.

The proposed assertion that this space is both connected and totally
 disconnected is false for a genuine library: its Hamming topology is discrete,
so it is totally disconnected and zero-dimensional, but it is not connected
as soon as `2 ≤ A` and `0 < L`.  The last part of the file gives the precise
finite counting theorem behind the phrase “almost all books are
incompressible”.  Exact Kolmogorov complexity depends on a choice of universal
machine, so the formal result is deliberately uniform in an arbitrary decoder.
-/

open Set Function

namespace LibraryOfBabelEverything

/-- A fixed-length book, carrying the Hamming metric. -/
abbrev Book (A L : ℕ) := Hamming (fun _ : Fin L => Fin A)

/-- The library contains exactly `A ^ L` books. -/
theorem card_book (A L : ℕ) : Fintype.card (Book A L) = A ^ L := by
  change Fintype.card (Fin L → Fin A) = A ^ L
  simp

/-- Borges' conventional parameters (25 symbols and 1,312,000 positions)
give the advertised finite cardinality. -/
theorem card_borges_library :
    Fintype.card (Book 25 1312000) = 25 ^ 1312000 := by
  exact card_book 25 1312000

/-- The Hamming topology of the library is discrete. -/
theorem hamming_discrete (A L : ℕ) : DiscreteTopology (Book A L) := by
  have _ := card_book A L
  infer_instance

/-- Singletons form a clopen topological basis.  This is a concrete
zero-dimensionality certificate (and, for this finite metrizable space, the
usual covering-dimension-zero characterization). -/
theorem clopen_singleton_basis (A L : ℕ) :
    TopologicalSpace.IsTopologicalBasis
      {s : Set (Book A L) | (∃ x, s = {x}) ∧ IsClopen s} := by
  letI : DiscreteTopology (Book A L) := hamming_discrete A L
  rw [show {s : Set (Book A L) | (∃ x, s = {x}) ∧ IsClopen s} =
      {s : Set (Book A L) | ∃ x, s = {x}} by
    ext s
    simp only [Set.mem_setOf_eq]
    constructor
    · exact fun h => h.1
    · rintro ⟨x, rfl⟩
      exact ⟨⟨x, rfl⟩, isClopen_discrete {x}⟩]
  exact isTopologicalBasis_singletons (Book A L)

/-- Every Hamming library is totally disconnected. -/
theorem hamming_totally_disconnected (A L : ℕ) :
    TotallyDisconnectedSpace (Book A L) := by
  have _ := clopen_singleton_basis A L
  infer_instance

/-- With at least two symbols and at least one position, the library has two
explicitly different books. -/
theorem book_nontrivial {A L : ℕ} (hA : 2 ≤ A) (hL : 0 < L) :
    Nontrivial (Book A L) := by
  have _ := hamming_totally_disconnected A L
  let i : Fin L := ⟨0, hL⟩
  let z : Book A L := fun _ => ⟨0, by omega⟩
  let o : Book A L := fun _ => ⟨1, by omega⟩
  refine ⟨⟨z, o, ?_⟩⟩
  intro h
  have hi := congrFun h i
  simp [z, o] at hi

/-- Correction to the proposed connectedness claim: every genuine finite
Hamming library is disconnected. -/
theorem hamming_not_connected {A L : ℕ} (hA : 2 ≤ A) (hL : 0 < L) :
    ¬ ConnectedSpace (Book A L) := by
  letI : TotallyDisconnectedSpace (Book A L) :=
    hamming_totally_disconnected A L
  letI : Nontrivial (Book A L) := book_nontrivial hA hL
  intro hconn
  letI : ConnectedSpace (Book A L) := hconn
  haveI : Subsingleton (Book A L) :=
    ⟨fun x y => IsPreconnected.subsingleton isPreconnected_univ
      (Set.mem_univ x) (Set.mem_univ y)⟩
  exact not_subsingleton (Book A L) inferInstance

/-- A continuous decoder from a preconnected parameter space into the library
is constant. -/
theorem continuous_decoder_constant {X : Type*} [TopologicalSpace X]
    [PreconnectedSpace X] {A L : ℕ} (decode : X → Book A L)
    (hdecode : Continuous decode) (x y : X) :
    decode x = decode y := by
  letI : TotallyDisconnectedSpace (Book A L) :=
    hamming_totally_disconnected A L
  exact TotallyDisconnectedSpace.eq_of_continuous decode hdecode x y

/-- Consequently, no continuous map from a nonempty preconnected space can
surject onto a genuine library. -/
theorem no_continuous_surjective_decoder {X : Type*} [TopologicalSpace X]
    [PreconnectedSpace X] [Nonempty X] {A L : ℕ} (hA : 2 ≤ A) (hL : 0 < L) :
    ¬ ∃ decode : X → Book A L, Continuous decode ∧ Surjective decode := by
  have _ := hamming_not_connected hA hL
  rintro ⟨decode, hcontinuous, hsurj⟩
  letI : Nontrivial (Book A L) := book_nontrivial hA hL
  obtain ⟨b₀, b₁, hne⟩ := exists_pair_ne (Book A L)
  obtain ⟨x₀, rfl⟩ := hsurj b₀
  obtain ⟨x₁, rfl⟩ := hsurj b₁
  exact hne (continuous_decoder_constant decode hcontinuous x₀ x₁)

/-- A finite description language names no more books than it has codes. -/
theorem card_described_le {Code : Type*} [Fintype Code] {A L : ℕ}
    (decode : Code → Book A L) :
    Nat.card (range decode) ≤ Fintype.card Code := by
  have _ := card_book A L
  simpa [Nat.card_eq_fintype_card] using Fintype.card_range_le decode

/-- If there are fewer short descriptions than books, some book is
incompressible relative to the decoder. -/
theorem exists_incompressible_book {Code : Type*} [Fintype Code] {A L : ℕ}
    (decode : Code → Book A L) (hshort : Fintype.card Code < A ^ L) :
    ∃ b : Book A L, b ∉ range decode := by
  have hrange := card_described_le decode
  by_contra h
  push_neg at h
  have hall : range decode = Set.univ := Set.eq_univ_of_forall h
  rw [hall] at hrange
  simp [Nat.card_eq_fintype_card, card_book] at hrange
  omega

/-- Quantitative incompressibility: at least `A^L - #Code` books have no
available description. -/
theorem many_incompressible_books {Code : Type*} [Fintype Code] {A L : ℕ}
    (decode : Code → Book A L) :
    Nat.card {b : Book A L // b ∉ range decode} ≥
      A ^ L - Fintype.card Code := by
  classical
  have hrange : Fintype.card {b : Book A L // b ∈ range decode} ≤
      Fintype.card Code := by
    rw [← Nat.card_eq_fintype_card]
    exact card_described_le decode
  rw [Nat.card_eq_fintype_card, Fintype.card_subtype_compl, card_book]
  exact Nat.sub_le_sub_left hrange _

/-- For binary books, all programs of exactly `k` bits can describe at most
`2^k` books; hence at least `2^L - 2^k` books remain incompressible. -/
theorem binary_program_incompressibility (k L : ℕ)
    (decode : (Fin k → Bool) → Book 2 L) :
    Nat.card {b : Book 2 L // b ∉ range decode} ≥ 2 ^ L - 2 ^ k := by
  simpa using many_incompressible_books decode

/-- A deficit of `c` bits leaves at least `2^L - 2^(L-c)` binary books
undecodable.  For fixed `c`, this is the finite counting meaning of “almost
all”: the exceptional proportion is at most `2⁻ᶜ`. -/
theorem deficit_incompressibility (c L : ℕ)
    (decode : (Fin (L - c) → Bool) → Book 2 L) :
    Nat.card {b : Book 2 L // b ∉ range decode} ≥
      2 ^ L - 2 ^ (L - c) := by
  exact binary_program_incompressibility (L - c) L decode

end LibraryOfBabelEverything