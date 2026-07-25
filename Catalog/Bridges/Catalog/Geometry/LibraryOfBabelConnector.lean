import Mathlib

/-!
# The Library of Babel: topology meets incompressibility

A length-`L` book over an `A`-symbol alphabet is given its Hamming metric.  The
central connector proved here is that a continuous decoder from a connected
parameter space into this library is constant.  Thus geometric connectedness
cannot continuously generate more than one discrete text.

The file also gives the finite counting form of Kolmogorov incompressibility:
when there are fewer descriptions than books, some book has no description,
and at least `A^L - #descriptions` books are undescribed.

The informal demand that a nontrivial finite Hamming library be both connected
and totally disconnected is inconsistent.  We prove total disconnectedness and
prove non-connectedness whenever there are at least two symbols and a nonempty
book.
-/

open Set Function

namespace BabelConnector

/-- Fixed-length books equipped with the Hamming metric. -/
abbrev Book (A L : ℕ) := Hamming (fun _ : Fin L => Fin A)

/-- The exact number of books in the Hamming library. -/
theorem card_book (A L : ℕ) : Fintype.card (Book A L) = A ^ L := by
  change Fintype.card (Fin L → Fin A) = A ^ L
  simp

/-- Hamming topology on a finite-word library is discrete. -/
theorem hamming_discrete (A L : ℕ) : DiscreteTopology (Book A L) := by
  infer_instance

/-- A precise dimension-zero certificate: singleton sets form a clopen
(topological) basis.  This is the standard clopen-basis characterization of
covering dimension zero for finite metrizable spaces. -/
theorem hamming_clopen_singleton_basis (A L : ℕ) :
    TopologicalSpace.IsTopologicalBasis
      {s : Set (Book A L) | (∃ x, s = {x}) ∧ IsClopen s} := by
  rw [show {s : Set (Book A L) | (∃ x, s = {x}) ∧ IsClopen s} =
      {s : Set (Book A L) | ∃ x, s = {x}} by
    ext s
    simp only [Set.mem_setOf_eq]
    constructor
    · exact fun h => h.1
    · rintro ⟨x, rfl⟩
      exact ⟨⟨x, rfl⟩, isClopen_discrete {x}⟩]
  exact isTopologicalBasis_singletons (Book A L)

/-- Consequently, a Hamming library is totally disconnected. -/
theorem hamming_totally_disconnected (A L : ℕ) :
    TotallyDisconnectedSpace (Book A L) := by
  infer_instance

/-- A nonempty book over an alphabet with at least two symbols gives two
explicitly distinct library elements. -/
theorem book_nontrivial {A L : ℕ} (hA : 2 ≤ A) (hL : 0 < L) :
    Nontrivial (Book A L) := by
  let i : Fin L := ⟨0, hL⟩
  let z : Book A L := fun _ => ⟨0, by omega⟩
  let o : Book A L := fun _ => ⟨1, by omega⟩
  refine ⟨⟨z, o, ?_⟩⟩
  intro h
  have hi := congrFun h i
  simp [z, o] at hi

/-- **Correction to the proposed topological claim.** A nontrivial Hamming
library is not connected.  Connected and totally disconnected spaces can have
at most one point. -/
theorem hamming_not_connected {A L : ℕ} (hA : 2 ≤ A) (hL : 0 < L) :
    ¬ ConnectedSpace (Book A L) := by
  intro hconn
  letI : ConnectedSpace (Book A L) := hconn
  letI : Nontrivial (Book A L) := book_nontrivial hA hL
  haveI : Subsingleton (Book A L) :=
    ⟨fun x y => IsPreconnected.subsingleton isPreconnected_univ (Set.mem_univ x)
      (Set.mem_univ y)⟩
  exact not_subsingleton (Book A L) inferInstance

/-- **Topology–information connector.** Every continuous decoder from a
preconnected parameter space to the Hamming library is constant.  A connected
geometric latent space therefore cannot continuously vary a discrete book. -/
theorem continuous_decoder_constant {X : Type*} [TopologicalSpace X]
    [PreconnectedSpace X] {A L : ℕ} (decode : X → Book A L)
    (hdecode : Continuous decode) (x y : X) :
    decode x = decode y := by
  exact TotallyDisconnectedSpace.eq_of_continuous decode hdecode x y

/-- In particular, no continuous map from a nonempty connected parameter space
can surject onto a nontrivial Library of Babel. -/
theorem no_continuous_surjective_decoder {X : Type*} [TopologicalSpace X]
    [PreconnectedSpace X] [Nonempty X] {A L : ℕ} (hA : 2 ≤ A) (hL : 0 < L) :
    ¬ ∃ decode : X → Book A L, Continuous decode ∧ Surjective decode := by
  rintro ⟨decode, hcontinuous, hsurj⟩
  letI : Nontrivial (Book A L) := book_nontrivial hA hL
  obtain ⟨b₀, b₁, hne⟩ := exists_pair_ne (Book A L)
  obtain ⟨x₀, rfl⟩ := hsurj b₀
  obtain ⟨x₁, rfl⟩ := hsurj b₁
  exact hne (continuous_decoder_constant decode hcontinuous x₀ x₁)

/-- The number of books named by a finite description language is no larger
than the number of descriptions. -/
theorem card_encodable_le {Code : Type*} [Fintype Code] {A L : ℕ}
    (decode : Code → Book A L) :
    Nat.card (range decode) ≤ Fintype.card Code := by
  simpa [Nat.card_eq_fintype_card] using Fintype.card_range_le decode

/-- **Finite Kolmogorov incompressibility.** If a description language has
fewer programs than the library has books, at least one book is not decoded by
any program. -/
theorem exists_incompressible_book {Code : Type*} [Fintype Code] {A L : ℕ}
    (decode : Code → Book A L) (hshort : Fintype.card Code < A ^ L) :
    ∃ b : Book A L, b ∉ range decode := by
  by_contra h
  push_neg at h
  have hsurj : Surjective decode := fun b => h b
  have := Fintype.card_le_of_surjective decode hsurj
  rw [card_book] at this
  omega

/-- Quantitative "almost all" theorem: at least `A^L - #Code` books have no
program in the chosen finite description language. -/
theorem many_incompressible_books {Code : Type*} [Fintype Code] {A L : ℕ}
    (decode : Code → Book A L) :
    Nat.card {b : Book A L // b ∉ range decode} ≥
      A ^ L - Fintype.card Code := by
  classical
  have hrange : Fintype.card {b : Book A L // b ∈ range decode} ≤
      Fintype.card Code := by
    rw [← Nat.card_eq_fintype_card]
    exact card_encodable_le decode
  rw [Nat.card_eq_fintype_card, Fintype.card_subtype_compl,
    card_book]
  exact Nat.sub_le_sub_left hrange _

/-- For binary books, programs of length `k` leave at least `2^L - 2^k`
books incompressible.  This is the standard counting core of the statement
that almost all long binary strings are incompressible. -/
theorem binary_program_incompressibility (k L : ℕ)
    (decode : (Fin k → Bool) → Book 2 L) :
    Nat.card {b : Book 2 L // b ∉ range decode} ≥ 2 ^ L - 2 ^ k := by
  simpa using many_incompressible_books decode

end BabelConnector