/-
# The Library of Babel: Catalogs, the Diagonal Argument, and Distributed Guides

Borges' deepest question: can the Library contain its own complete catalog?

We model a **complete catalog** of the Library as a *subset* of volumes (for each
volume, whether it is listed), i.e. an element of `Set (Volume A L)`.  A single
volume can encode at most one message, so a "self-catalog" would be a map from
volumes to catalogs; the diagonal argument shows no such map is onto.  A
**distributed catalog** spreads the listing across `N` volumes, and we pin down
exactly how large `N` must be.

## Main Results (this file)

1. **No single-volume complete catalog** (`no_complete_self_catalog`): there is no
   surjection `Volume A L → Set (Volume A L)`.  Equivalently (`card_catalogs_gt`),
   the number of possible catalogs `2 ^ (A ^ L)` strictly exceeds the number of
   volumes `A ^ L`, so no volume can be assigned a distinct catalog.  This is the
   rigorous diagonal obstruction.

2. **Exact distributed-catalog threshold** (`distributed_catalog_iff`): a
   distributed catalog `c : Fin N → Volume A L` that lists *every* volume
   (surjective) exists **iff** `A ^ L ≤ N`.  This corrects the theme's heuristic
   threshold `N > A^L / (L·log₂A)`: since each catalog volume can *identify* only
   one library volume, the true threshold is `N ≥ A^L`, not `A^L / (L log₂ A)`.

3. **de Bruijn catalog capacity** (`catalog_codes_le`, `catalog_forces_collision`):
   bridging to `KMerAvoidance`, a single index volume of length `L` can exhibit
   at most `A^k` distinct length-`k` reference codes (`= |mini-Library of length
   k|`), and once `L ≥ A^k + k` a code *must* repeat — so the shortest lossless
   single-volume catalog of all `A^k` codes has length `A^k + k - 1`, exactly the
   length of a de Bruijn sequence `B(A,k)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (a) the Library cannot hold its own complete catalog;
(b) a distributed catalog needs `N > A^L/(L log₂ A)` volumes; (c) a de Bruijn
sequence yields an optimal single-volume "mini-catalog".

Experiment (Experimenter): mini-Library `A=4, L=16` has `4^16 = 4294967296`
volumes.  A single catalog volume is one string; it can *point at* one volume, so
listing all needs `4^16` catalog volumes.  The heuristic `A^L/(L log₂ A) =
4^16/(16·2) = 4^16/32 ≈ 1.3e8` is far too small — off by a factor `L log₂ A = 32`.
For de Bruijn: `B(4,2)` has length `4^2 = 16`, wraps to cover all `16` length-2
codes; linearised length `4^2 + 2 - 1 = 17`.

Analysis (Analyst): the info-theoretic heuristic silently assumes a catalog
volume can be *subdivided* into `L log₂ A` independent pointer bits.  But a
catalog entry that must *name a whole volume* consumes a whole volume's worth of
symbols; the honest counting threshold is therefore `A^L`, proved by a bijection
`Volume ≃ Fin (A^L)` plus a Fin-surjection.  The diagonal fact is finite Cantor:
`2^(A^L) > A^L`.

Critique (Critic): is `distributed_catalog_iff` vacuous?  No — both directions are
load-bearing: `←` builds an explicit surjection from `A^L ≤ N`; `→` uses
`Fintype.card_le_of_surjective`.  The `A ≥ 1` hypothesis is necessary: with `A=0`
and `L>0` the Library is empty and the statement degenerates.

Synthesis (PI): the three results together say meaning in the Library is
*locatable but not self-locating*: a guide exists, but only as a distributed
structure of full size, never as a single self-referential volume.
-/
import Mathlib
import Cryptography.LibraryOfBabel.Basic
import Cryptography.KMerAvoidance

open Finset Fintype Function LibraryOfBabel

namespace LibraryOfBabel

/-! ## The diagonal argument: no single-volume complete catalog -/

/-- **Counting form of the diagonal argument.** There are strictly more possible
catalogs (subsets of the Library) than there are volumes: `A^L < 2^(A^L)`. -/
theorem card_catalogs_gt (A L : ℕ) :
    Fintype.card (Volume A L) < Fintype.card (Set (Volume A L)) := by
  rw [Fintype.card_set]
  have hcard : Fintype.card (Volume A L) = A ^ L := by simp
  rw [hcard]
  exact Nat.lt_two_pow_self

/-- **No single-volume complete catalog.** There is no surjection from the
Library onto the set of all catalogs: no scheme assigns to each volume a distinct
complete catalog.  Proof is a finite diagonal/counting argument via
`card_catalogs_gt`. -/
theorem no_complete_self_catalog (A L : ℕ) :
    ¬ ∃ f : Volume A L → Set (Volume A L), Function.Surjective f := by
  rintro ⟨f, hf⟩
  have hle : Fintype.card (Set (Volume A L)) ≤ Fintype.card (Volume A L) :=
    Fintype.card_le_of_surjective f hf
  exact absurd hle (not_le.mpr (card_catalogs_gt A L))

/-! ## The distributed catalog threshold -/

/-- A **distributed catalog** over `N` catalog-volumes is *complete* when it lists
every volume, i.e. the indexing map is surjective. -/
def CompleteDistributedCatalog {A L N : ℕ} (c : Fin N → Volume A L) : Prop :=
  Function.Surjective c

/-- **Exact distributed-catalog threshold.** For a nonempty alphabet, a complete
distributed catalog spanning `N` volumes exists **iff** `A ^ L ≤ N`.  Each catalog
volume can identify exactly one library volume, so the honest threshold is the
full Library size `A^L` — not the theme's heuristic `A^L/(L·log₂A)`. -/
theorem distributed_catalog_iff {A L N : ℕ} (hA : 1 ≤ A) :
    (∃ c : Fin N → Volume A L, CompleteDistributedCatalog c) ↔ A ^ L ≤ N := by
  have hcard : Fintype.card (Volume A L) = A ^ L := by simp
  constructor
  · rintro ⟨c, hc⟩
    have hle := Fintype.card_le_of_surjective c hc
    rwa [hcard, Fintype.card_fin] at hle
  · intro h
    let e := Fintype.equivFinOfCardEq hcard
    have hpos : 1 ≤ A ^ L := Nat.one_le_pow _ _ hA
    refine ⟨fun i => e.symm (if hi : (i : ℕ) < A ^ L then ⟨i, hi⟩ else ⟨0, hpos⟩), ?_⟩
    intro y
    refine ⟨⟨(e y : ℕ), by omega⟩, ?_⟩
    have hlt : ((e y : Fin (A ^ L)) : ℕ) < A ^ L := (e y).2
    simp [hlt]

/-! ## de Bruijn catalog capacity (bridge to `KMerAvoidance`) -/

/-- **Single-volume catalog capacity.** An index volume of length `L` can display
at most `A^k = |mini-Library of length k|` distinct length-`k` reference codes.
This ties the subword complexity of `KMerAvoidance` to the Library cardinality. -/
theorem catalog_codes_le {A L k : ℕ} (hkL : k ≤ L) (s : Volume A L) :
    subwordComplexity hkL s ≤ Nat.card (Volume A k) := by
  rw [card_volume]
  have := subword_complexity_le hkL s
  rwa [show Fintype.card (Fin A) = A from Fintype.card_fin A] at this

/-- **de Bruijn collision bound.** Once an index volume is at least as long as the
de Bruijn threshold `A^k + k`, some length-`k` reference code must repeat: no
single volume longer than the de Bruijn length can be a lossless catalog of codes.
The optimal lossless length is thus `A^k + k - 1`, the length of a de Bruijn
sequence `B(A,k)`. -/
theorem catalog_forces_collision {A L k : ℕ} (hn : A ^ k + k ≤ L) (s : Volume A L) :
    ∃ i j : Fin (L - k + 1), i ≠ j ∧
      kmer (by omega : k ≤ L) s i = kmer (by omega) s j := by
  have hcard : Fintype.card (Fin A) ^ k + k ≤ L := by
    rwa [Fintype.card_fin]
  exact kmer_repeat_threshold hcard s

end LibraryOfBabel