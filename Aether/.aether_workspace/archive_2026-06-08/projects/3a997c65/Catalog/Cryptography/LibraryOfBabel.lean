import Mathlib

/-!
# The Library of Babel: Combinatorics of Universal Information Spaces

Borges' Library of Babel contains every possible book of a fixed length over a fixed alphabet.
We formalize the Library and prove fundamental combinatorial results about catalogs,
information capacity, and the impossibility of universal self-description.

## Main Results

* `volume_card` — The Library contains exactly `A^L` volumes
* `catalog_scheme_card` — The number of possible catalog schemes is `D^(A^L)`
* `catalog_impossibility` — More catalog schemes exist than volumes (when D ≥ 2)
* `no_catalog_embedding` — No injection from catalog schemes to volumes
* `prefix_fiber_card` — Exactly `A^(L-k)` volumes share a given k-length prefix
* `search_complexity_singleton` — Finding a specific volume requires examining `A^L` on average
* `exists_hamming_neighbor` — Every volume has a neighbor differing in exactly one position

## Key Definitions

* `Volume A L` — A volume: a function `Fin L → Fin A`
* `CatalogScheme A L D` — An assignment of `D`-valued descriptions to volumes
* `BabelConfig` — Configuration parameters for a universal library
* `searchComplexity` — Expected samples to find a volume satisfying a property
* `hammingDist` — Hamming distance between volumes
-/

namespace LibraryOfBabel

open Fintype Finset Function

/-! ## Core Definitions -/

/-- A volume in the Library of Babel: a string of length `L` over an alphabet of `A` symbols.
    Each volume is a function from positions to alphabet symbols. -/
abbrev Volume (A L : ℕ) := Fin L → Fin A

/-- A catalog scheme assigns a description from `Fin D` to each volume in the Library.
    This represents any attempt to label, classify, or index the Library's contents. -/
abbrev CatalogScheme (A L D : ℕ) := Volume A L → Fin D

/-- Configuration for a Library of Babel, bundling the alphabet size and volume length
    with the constraint that the alphabet is nonempty. -/
structure BabelConfig where
  /-- Number of symbols in the alphabet -/
  alphabetSize : ℕ
  /-- Length of each volume (number of character positions) -/
  volumeLength : ℕ
  /-- The alphabet must contain at least one symbol -/
  alphabet_pos : 0 < alphabetSize

/-! ## Cardinality Results -/

/-- The Library contains exactly `A^L` distinct volumes. -/
theorem volume_card (A L : ℕ) : Fintype.card (Volume A L) = A ^ L := by
  simp [Fintype.card_fun, Fintype.card_fin]

/-- The number of possible catalog schemes with `D`-valued descriptions is `D^(A^L)`. -/
theorem catalog_scheme_card (A L D : ℕ) :
    Fintype.card (CatalogScheme A L D) = D ^ (A ^ L) := by
  simp [Fintype.card_fun, Fintype.card_fin]

/-! ## Catalog Impossibility -/

/-
For `D ≥ 2` and `n ≥ 1`, we have `n < D^n`. The space of D-valued functions on
    an n-element set always exceeds n. This is the engine of the catalog impossibility.
-/
theorem pow_gt_self (n D : ℕ) (hD : 2 ≤ D) (_hn : 1 ≤ n) : n < D ^ n := by
  exact Nat.recOn n ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; nlinarith;

/-- **Catalog Impossibility Theorem**: When descriptions have at least 2 values
    and the Library is nonempty, there are strictly more catalog schemes than volumes.
    Most ways of cataloging the Library cannot be encoded in a single volume. -/
theorem catalog_impossibility (A L D : ℕ) (hD : 2 ≤ D) (hAL : 1 ≤ A ^ L) :
    Fintype.card (Volume A L) < Fintype.card (CatalogScheme A L D) := by
  rw [volume_card, catalog_scheme_card]
  exact pow_gt_self (A ^ L) D hD hAL

/-
**No Catalog Embedding**: There is no injection from catalog schemes into
    the Library. The Library cannot contain a distinct volume for every possible
    way of cataloging itself — a finite analog of Cantor's theorem.
-/
theorem no_catalog_embedding (A L D : ℕ) (hD : 2 ≤ D) (hAL : 1 ≤ A ^ L)
    (f : CatalogScheme A L D → Volume A L) : ¬ Injective f := by
  -- The injectivity assumption gives an injection from a larger set to a smaller one, violating card.
  by_contra h_contra; exact (by
  exact absurd ( Fintype.card_le_of_injective f h_contra ) ( by simpa [ volume_card, catalog_scheme_card ] using catalog_impossibility A L D hD hAL ))

/-! ## Cantor-style Surjection Impossibility -/

/-
**Babel-Cantor Theorem**: No surjection from the Library onto the space of
    catalog schemes exists. This is the dual of `no_catalog_embedding` and
    directly mirrors Cantor's theorem for finite sets.

    The Library is its own universe of discourse, yet it cannot surject onto
    its own power-like structure.
-/
theorem babel_cantor (A L D : ℕ) (hD : 2 ≤ D) (hAL : 1 ≤ A ^ L)
    (f : Volume A L → CatalogScheme A L D) : ¬ Surjective f := by
  exact fun h => absurd ( Fintype.card_le_of_surjective f h ) ( by simpa [ Fintype.card_fun, catalog_scheme_card, volume_card ] using catalog_impossibility A L D hD hAL )

/-! ## Prefix Analysis -/

/-- Extract the first `k` characters of a volume as a prefix. -/
def takePrefix {A L : ℕ} (k : ℕ) (hk : k ≤ L) (v : Volume A L) : Fin k → Fin A :=
  fun i => v (Fin.castLE hk i)

/-- Extend a prefix with a suffix to form a complete volume. -/
def extendPrefix {A L k : ℕ} (hk : k ≤ L) (p : Fin k → Fin A)
    (s : Fin (L - k) → Fin A) : Volume A L :=
  fun i => if h : i.val < k then p ⟨i.val, h⟩ else s ⟨i.val - k, by omega⟩

/-
The extension map is injective in the suffix: different suffixes yield different volumes.
-/
theorem extendPrefix_injective {A L k : ℕ} (hk : k ≤ L) (p : Fin k → Fin A) :
    Injective (extendPrefix hk p) := by
  intro s₁ s₂ h_eq;
  ext i; have := congr_fun h_eq ⟨ k + i.val, by linarith [ Fin.is_lt i, Nat.sub_add_cancel hk ] ⟩ ; simp_all +decide [ extendPrefix ] ;

/-
The extension map preserves the prefix.
-/
theorem extendPrefix_takePrefix {A L k : ℕ} (hk : k ≤ L) (p : Fin k → Fin A)
    (s : Fin (L - k) → Fin A) : takePrefix k hk (extendPrefix hk p s) = p := by
  exact funext fun i => by unfold takePrefix extendPrefix; aesop;

/-
Every volume with a given prefix can be decomposed into that prefix and a suffix.
-/
theorem exists_suffix_of_takePrefix {A L k : ℕ} (hk : k ≤ L) (p : Fin k → Fin A)
    (v : Volume A L) (hv : takePrefix k hk v = p) :
    ∃ s : Fin (L - k) → Fin A, extendPrefix hk p s = v := by
  use fun i => v (Fin.mk (k + i.val) (by
  lia))
  generalize_proofs at *;
  -- By definition of extendPrefix, we have that extendPrefix hk p s = v for any s.
  ext i
  simp [extendPrefix];
  split_ifs <;> simp_all +decide [ ← hv, takePrefix ];
  congr ; simp +decide [ *, add_tsub_cancel_of_le ( le_of_not_gt ‹_› ) ]

/-
**Prefix Fiber Cardinality**: Exactly `A^(L-k)` volumes share a given k-character prefix.
    Fixing k characters leaves L-k positions free, each with A choices.
-/
theorem prefix_fiber_card {A L k : ℕ} (hk : k ≤ L) (p : Fin k → Fin A) :
    Fintype.card {v : Volume A L // takePrefix k hk v = p} = A ^ (L - k) := by
  rw [ Fintype.card_subtype ];
  rw [ Finset.card_eq_sum_ones, Finset.sum_congr rfl fun x hx => rfl ];
  rw [ show ( Finset.univ.filter fun v : Fin L → Fin A => takePrefix k hk v = p ) = Finset.image ( fun s : Fin ( L - k ) → Fin A => extendPrefix hk p s ) ( Finset.univ : Finset ( Fin ( L - k ) → Fin A ) ) from ?_, Finset.sum_image ];
  · simp +decide [ Finset.card_univ ];
  · exact fun s _ t _ h => by simpa using extendPrefix_injective hk p h;
  · ext v; simp [takePrefix, extendPrefix];
    constructor <;> intro h;
    · exact?;
    · obtain ⟨ a, rfl ⟩ := h; exact extendPrefix_takePrefix hk p a;

/-! ## Hamming Distance -/

/-- The Hamming distance between two volumes: the number of positions where they differ. -/
noncomputable def hammingDist {A L : ℕ} (v w : Volume A L) : ℕ :=
  Fintype.card {i : Fin L // v i ≠ w i}

/-
The Hamming distance from a volume to itself is zero.
-/
theorem hammingDist_self {A L : ℕ} (v : Volume A L) : hammingDist v v = 0 := by
  unfold hammingDist; aesop;

/-
Hamming distance is symmetric.
-/
theorem hammingDist_comm {A L : ℕ} (v w : Volume A L) :
    hammingDist v w = hammingDist w v := by
  -- The Hamming distance is symmetric because the sets of indices where they differ are the same.
  apply Fintype.card_congr; exact Equiv.subtypeEquivRight (by simp [eq_comm])

/-
Hamming distance is bounded by volume length.
-/
theorem hammingDist_le_length {A L : ℕ} (v w : Volume A L) :
    hammingDist v w ≤ L := by
  convert Fintype.card_subtype_le ( fun i => v i ≠ w i );
  norm_num

/-
Two volumes are identical iff their Hamming distance is zero.
-/
theorem hammingDist_eq_zero_iff {A L : ℕ} (v w : Volume A L) :
    hammingDist v w = 0 ↔ v = w := by
  simp +decide [ hammingDist, Fintype.card_eq_zero_iff ];
  rw [ Nat.sub_eq_zero_iff_le, Fintype.card_subtype ];
  exact ⟨ fun h => funext fun i => Classical.not_not.1 fun hi => not_le_of_gt ( lt_of_lt_of_le ( Finset.card_lt_card ( Finset.filter_ssubset.2 ⟨ i, by aesop ⟩ ) ) ( by simpa ) ) h, fun h => by simp +decide [ h ] ⟩

/-! ## Hamming Neighbors -/

/-
**No Isolated Volume**: When `A ≥ 2` and `L ≥ 1`, every volume has a neighbor
    at Hamming distance exactly 1. No book in the Library is alone.
-/
theorem exists_hamming_neighbor {A L : ℕ} (hA : 2 ≤ A) (hL : 1 ≤ L)
    (v : Volume A L) : ∃ w : Volume A L, w ≠ v ∧ hammingDist v w = 1 := by
  obtain ⟨a, ha⟩ : ∃ a : Fin A, a ≠ v ⟨0, hL⟩ := by
    exact ⟨ if v ⟨ 0, hL ⟩ = ⟨ 0, by linarith ⟩ then ⟨ 1, by linarith ⟩ else ⟨ 0, by linarith ⟩, by aesop ⟩;
  refine' ⟨ fun i => if i = ⟨ 0, hL ⟩ then a else v i, _, _ ⟩ <;> simp_all +decide [ funext_iff, hammingDist ];
  rw [ Fintype.card_eq_one_iff ] ; aesop

/-! ## Search Complexity -/

/-- The search complexity of a nonempty target set: the ceiling of `|Library|/|S|`,
    representing the expected number of uniform random samples to find a match. -/
noncomputable def searchComplexity {A L : ℕ} (S : Finset (Volume A L))
    (_hS : S.Nonempty) : ℕ :=
  (A ^ L + S.card - 1) / S.card

/-
Finding a specific volume requires examining the entire library on average.
-/
theorem search_complexity_singleton {A L : ℕ} (v : Volume A L) :
    searchComplexity {v} (singleton_nonempty v) = A ^ L := by
  unfold searchComplexity; aesop;

/-! ## Distributed Catalog -/

/-- A distributed catalog of `N` volumes can represent at most `(A^L)^N` entries. -/
def distributedCatalogCapacity (A L N : ℕ) : ℕ := (A ^ L) ^ N

/-
A single catalog volume suffices to address the entire library (bijectively),
    since the number of states of one volume equals the library size.
-/
theorem single_volume_addresses_library (A L : ℕ) :
    A ^ L ≤ distributedCatalogCapacity A L 1 := by
  unfold distributedCatalogCapacity; norm_num;

/-
Adding catalog volumes strictly increases capacity when the library has ≥ 2 volumes.
-/
theorem distributed_catalog_capacity_strict_mono {A L : ℕ} (hAL : 2 ≤ A ^ L)
    {N M : ℕ} (hNM : N < M) :
    distributedCatalogCapacity A L N < distributedCatalogCapacity A L M := by
  exact Nat.pow_lt_pow_right hAL hNM

/-! ## Substring Density -/

/-
**Substring Density Lower Bound**: For a target pattern of length `m ≤ L`,
    at least `A^(L-m)` volumes contain it at position 0 (as a prefix). This provides
    a lower bound on the total number of volumes containing the pattern at ANY position.
-/
theorem substring_at_position_zero {A L m : ℕ} (_hA : 1 ≤ A) (hm : m ≤ L)
    (t : Fin m → Fin A) :
    A ^ (L - m) ≤ (Finset.univ.filter (fun v : Volume A L =>
      ∀ j : Fin m, v ⟨j.val, by omega⟩ = t j)).card := by
  convert prefix_fiber_card hm t |> ge_of_eq using 1;
  rw [ Fintype.subtype_card ];
  convert rfl;
  exact ⟨ fun h j => congr_fun h j, fun h => funext fun j => h j ⟩

end LibraryOfBabel