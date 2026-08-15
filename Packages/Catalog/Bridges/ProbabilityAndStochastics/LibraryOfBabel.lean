import Mathlib
import EML.KolmogorovComplexityBound
/-!
# The Library of Babel: finite information capacity

A library with alphabet size `q` and volume length `n` is the function space
`Fin n → Fin q`.  The results below separate three issues often conflated in
informal accounts: enumeration, exact-match probability, and catalog capacity.
They establish exact cardinalities, a constructive finite index, sharp storage
obstructions, and an incompressibility bridge to bounded expression languages.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): finite libraries admit exact numerical catalogs, but a
catalog containing one independent address for every volume cannot itself fit in
one volume over the same alphabet.  A distributed catalog has a sharp capacity
threshold, while exact semantic probabilities depend on the chosen acceptance
predicate rather than proof length alone.
Experiment (Experimenter): model volumes as fixed-length words, count them, equip
them with a canonical finite index, count exact matches, and compare the cardinal
of all address tables with the cardinal of available storage words.
Analysis (Analyst): enumeration and self-description are distinct.  A volume can
name any one book, yet a full table is a function on the entire library and thus
requires one address-sized block per book.  The same finite-counting principle
also yields bounded-description incompressibility for real functions.
Critique (Critic): no semantic claim about “meaningful proof” is inferred from
length.  The exact formula is stated for an explicit decidable acceptance set;
the singleton result applies only when a unique byte-for-byte text is accepted.
The mini-library result is an indexing catalog, not an unsupported de Bruijn
runtime claim.
Synthesis (Principal Investigator): exact counting, probability, finite indexing,
distributed capacity, and bounded-language incompressibility form one coherent
information-theoretic account.
-- !-- end Lab Notes -- !--
-/

open scoped BigOperators

namespace LibraryOfBabel

/-- Words of exactly `n` symbols over an alphabet with `q` symbols. -/
abbrev Word (q n : ℕ) := Fin n → Fin q

/-- Uniform probability of a decidable property of volumes. -/
noncomputable def uniformProbability (q n : ℕ) (P : Word q n → Prop)
    [DecidablePred P] : ℚ :=
  (Finset.univ.filter P).card / Fintype.card (Word q n)

/-
The library has exactly `q^n` volumes.
-/
theorem library_card (q n : ℕ) : Fintype.card (Word q n) = q ^ n := by
  norm_num

/-- Borges' 25-symbol, 1,312,000-position library contains exactly the
advertised number of volumes. -/
theorem borges_library_card :
    Fintype.card (Word 25 1312000) = 25 ^ 1312000 := by
  exact library_card 25 1312000

/-
A fixed byte-for-byte volume has exactly uniform mass `1/q^n`.
-/
theorem exact_volume_probability (q n : ℕ) (w : Word q n) :
    uniformProbability q n (fun x => x = w) = 1 / (q ^ n : ℚ) := by
  convert congr_arg _ ?_;
  rotate_left;
  exact fun a => Classical.dec ( a = w );
  · congr! 1;
  · unfold uniformProbability;
    rw [ Finset.card_filter ] ; norm_num [ library_card ]

/-
For any explicit proof checker, the exact success probability is the number
of accepted texts divided by the number of volumes.  This is the appropriate
exact replacement for a complexity-only heuristic.
-/
theorem exact_checker_probability (q n : ℕ) (Accepts : Word q n → Prop)
    [DecidablePred Accepts] :
    uniformProbability q n Accepts =
      (Finset.univ.filter Accepts).card / (q ^ n : ℚ) := by
  unfold uniformProbability; aesop;

/-
Every finite library has a lossless numerical catalog: each word has a unique
index below the exact library cardinality.
-/
theorem numerical_catalog (q n : ℕ) :
    ∃ index : Word q n → Fin (q ^ n), Function.Bijective index := by
  by_contra! h_contra;
  obtain ⟨index, hindex⟩ : ∃ index : Fin (q^n) ≃ Word q n, True := by
    exact ⟨ Fintype.equivOfCardEq (by simp), trivial ⟩;
  exact h_contra ( index.symm ) ( Equiv.bijective _ )

/-
The four-symbol, length-sixteen mini-library has exactly `2^32` books and a
lossless 32-bit numerical catalog.
-/
theorem mini_library_catalog :
    Fintype.card (Word 4 16) = 2 ^ 32 ∧
      ∃ index : Word 4 16 → Fin (2 ^ 32), Function.Bijective index := by
  exact ⟨ library_card 4 16, numerical_catalog 4 16 ⟩

/-
A single `n`-symbol volume cannot injectively store the complete address table
whose one address entry is itself an `n`-symbol volume, provided the library has
at least two books.  The table space is `Library → Library`, vastly larger than
one volume.
-/
theorem no_single_volume_complete_catalog (q n : ℕ) (hbooks : 2 ≤ q ^ n) :
    ¬ ∃ encode : (Word q n → Word q n) → Word q n, Function.Injective encode := by
  contrapose! hbooks; have := Fintype.card_le_of_injective _ hbooks.choose_spec; simp_all +decide ;
  contrapose! this;
  exact lt_self_pow₀ ( by linarith ) ( by linarith )

/-
`N` storage volumes have exactly `q^(n*N)` possible states.  This is the sharp
raw capacity law behind distributed catalogs.
-/
theorem distributed_storage_card (q n N : ℕ) :
    Fintype.card (Fin N → Word q n) = q ^ (n * N) := by
  simp [pow_mul]

/-
If an object class injects into `N` storage volumes, its cardinality cannot
exceed the distributed capacity `q^(n*N)`.
-/
theorem distributed_catalog_capacity {C : Type*} [Fintype C]
    (q n N : ℕ) (encode : C → (Fin N → Word q n))
    (hinj : Function.Injective encode) :
    Fintype.card C ≤ q ^ (n * N) := by
  convert Fintype.card_le_of_injective encode hinj using 1;
  simp +decide [ pow_mul', Fintype.card_pi ];
  ring

/-
A complete address table needs at least one volume-sized block per library
volume.  Thus fewer than `q^n` storage volumes cannot encode every possible
address table when the library has at least two books.  This sharpens a mere bit
count into a structural lower bound for distributed catalogs.
-/
theorem no_short_distributed_complete_catalog (q n N : ℕ)
    (hbooks : 2 ≤ q ^ n) (hshort : N < q ^ n) :
    ¬ ∃ encode : (Word q n → Word q n) → (Fin N → Word q n),
      Function.Injective encode := by
  contrapose! hshort;
  obtain ⟨ encode, hinj ⟩ := hshort;
  have := Fintype.card_le_of_injective encode hinj; simp_all +decide [ Fintype.card_pi ] ;
  rw [ pow_le_pow_iff_right₀ ] at this <;> linarith

/-
Cross-domain incompressibility: even when the description budget equals the
number of books in a finite library, some real function is not denoted by any
constant-free expression of that size.
-/
theorem library_scale_incompressibility (q n : ℕ) :
    ∃ f : ℝ → ℝ, f ∉ EMLKolmogorov.computableLE (q ^ n) := by
  convert EMLKolmogorov.exists_incompressible ( q ^ n ) using 1

end LibraryOfBabel