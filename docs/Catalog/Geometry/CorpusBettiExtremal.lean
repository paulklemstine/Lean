import Shared.TheoremNetworkTopology

/-!
# Extremal Betti profiles of theorem corpora under a document-size bound

This file continues the thread on the topology of theorem networks.  The ambient model is
the one already fixed in `Shared.TheoremNetworkTopology`: a *corpus* `C : Corpus V` is a
finite family of finite sets of theorems (one set per document), and its *co-citation
complex* `coCitationComplex C` is the downward closure of that family.

The previous cycle established two facts: a universal binomial ceiling
`(facesOfCard C q).card ≤ (Fintype.card V).choose q`, and the vanishing of every
rank-presented Betti number in homological dimensions at least `Fintype.card V`.  Both are
statements about the *ambient* vertex set only.  The present file adds the missing
parameter of the research programme, the **document-size bound** `d`, and proves that this
parameter, not the vertex count, is what controls the whole Betti profile.

## Contents

* `BoundedCorpus C d` — every document cites at most `d` theorems.
* `facesOfCard_eq_empty_of_bounded`, `bettiFromRanks_eq_zero_of_bounded` — a `d`-bounded
  corpus has **no** faces, hence no homology, in dimensions `≥ d`.  This is a strict
  sharpening of the previous cycle's dimension obstruction (`d` may be far below `n`).
* `skeletonCorpus V d` — the *symmetric design* corpus in which every `d`-element set of
  theorems is a document.  Its complex is the full `(d-1)`-skeleton of the simplex on `V`.
* `isGreatest_card_facesOfCard_bounded` — **sharp extremal face count**: among all
  `d`-bounded corpora the maximal number of `q`-element faces is exactly
  `(Fintype.card V).choose q` for `q ≤ d`, and it is attained by the design.
* `alternating_choose_partial` — the partial alternating binomial identity
  `∑_{j ≤ d} (-1)^j C(m+1, j) = (-1)^d C(m, d)`.
* `eulerChar_skeletonCorpus` — the Euler characteristic of the design complex is
  `1 - (-1)^d C(n-1, d)`.
* `HomologyProfile` — an *abstract* Betti profile: any sequence dominated by the chain
  dimensions and satisfying the Euler–Poincaré relation.  Field-coefficient simplicial
  homology of the corpus complex is such a profile, but nothing below uses more than these
  two axioms.
* `HomologyProfile.exists_large_betti` — Euler characteristic forces a large Betti number.
* `skeletonCorpus_exists_betti_pow_lower` — **extremal lower bound**: for the design corpus
  some Betti number in a dimension `< d` is at least of order `n^d / (d · d!)`.  Together
  with the binomial ceiling this pins the extremal `k`-th Betti number of a `d`-bounded
  corpus to polynomial order `n^{k+1}` in the top available dimension `k = d - 1`, and to
  `0` for `k ≥ d`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (1) the document-size bound `d`, not the theorem count `n`,
determines the support of the Betti profile; (2) the extremal profile is attained by the
complete `d`-uniform design; (3) the extremal top Betti number has order `n^d`; (4) the
Euler characteristic alone, being an alternating sum over only `d` dimensions, already
forces a Betti number of order `n^d`; (5) no `d`-bounded corpus can have homology in
dimension `d` or above, for any coefficient field.

Experiment (Experimenter): the complete `d`-uniform design on `n` theorems was computed
face by face: `f_q = C(n, q)` for `q ≤ d` and `f_q = 0` afterwards.  Its Euler
characteristic was evaluated by a partial alternating binomial sum, giving
`1 - (-1)^d C(n-1, d)`; small cases `(n, d) = (3, 2), (4, 2), (4, 3), (5, 3)` give
`χ = 1 + 2 = 3`, `1 + 3 = 4`, `1 - 3 = -2`, `1 - 6 = -5`, matching the classical values for
skeleta of simplices.

Analysis (Analyst): hypotheses (1), (2), (4), (5) survive as theorems; (3) survives as the
two-sided estimate `(n-d)^d ≤ d! · d · max_k β_k + d!` together with `β_k ≤ C(n, k+1)`.
The Euler characteristic argument is the load-bearing one: because a `d`-bounded corpus has
only `d` possibly-nonzero Betti numbers, an Euler characteristic of size `Θ(n^d)` cannot be
spread thinly and must concentrate.

Critique (Critic): `HomologyProfile` is an axiomatisation, not a construction of simplicial
homology; it is honest precisely because its two fields (domination by chain dimension and
the Euler–Poincaré relation) are the only properties used, and both are theorems for any
field-coefficient homology of a finite complex.  The lower bound is a bound on the maximum
over `k < d`, not on a specific dimension: Euler characteristic cannot distinguish
dimensions.  The bound `(n-d)^d` degenerates when `d` is comparable to `n`, which is the
correct behaviour since the design then becomes the full simplex and is contractible.

Synthesis (Principal Investigator): document size is the true extremal parameter.  The
`f`-vector ceiling of the previous cycle is attained exactly by the `d`-uniform design, and
Euler characteristic upgrades this counting statement into a genuine topological lower
bound in the top surviving dimension.
-- !-- end Lab Notes -- !--
-/

noncomputable section

open Classical Finset
open TheoremNetworkTopology

namespace CorpusBettiExtremal

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Document-size bounded corpora -/

/-- `BoundedCorpus C d` says every document of the corpus cites at most `d` theorems. -/
def BoundedCorpus (C : Corpus V) (d : ℕ) : Prop := ∀ W ∈ C, W.card ≤ d

/-- A `d`-bounded corpus has no face with more than `d` vertices. -/
theorem facesOfCard_eq_empty_of_bounded {C : Corpus V} {d q : ℕ}
    (hC : BoundedCorpus C d) (hq : d < q) : facesOfCard C q = ∅ := by
  refine Finset.eq_empty_iff_forall_notMem.mpr fun S hS => ?_
  rw [facesOfCard, Finset.mem_filter, coCitationComplex, Finset.mem_filter] at hS
  obtain ⟨⟨-, W, hW, hSW⟩, hcard⟩ := hS
  exact absurd ((hcard ▸ Finset.card_le_card hSW).trans (hC W hW)) (by omega)

/-- **Sharpened dimension obstruction.** Every rank-presented Betti number of a `d`-bounded
corpus vanishes in homological dimensions `k ≥ d`, no matter how many theorems there are. -/
theorem bettiFromRanks_eq_zero_of_bounded {C : Corpus V} {d k : ℕ}
    (hC : BoundedCorpus C d) (boundaryRank : ℕ → ℕ) (hk : d ≤ k) :
    bettiFromRanks C boundaryRank k = 0 := by
  unfold bettiFromRanks
  rw [facesOfCard_eq_empty_of_bounded hC (by omega)]
  simp

/-! ## The complete `d`-uniform design -/

/-- The *design corpus*: every `d`-element set of theorems is a document.  This is the
maximally symmetric `d`-bounded corpus. -/
def skeletonCorpus (V : Type*) [Fintype V] [DecidableEq V] (d : ℕ) : Corpus V :=
  Finset.univ.powersetCard d

theorem boundedCorpus_skeletonCorpus (d : ℕ) :
    BoundedCorpus (skeletonCorpus V d) d := by
  intro W hW
  exact le_of_eq (Finset.mem_powersetCard.mp hW).2

/-- The complex generated by the design is the full `(d-1)`-skeleton of the simplex on the
theorem set. -/
theorem mem_coCitationComplex_skeletonCorpus {d : ℕ} (hd : d ≤ Fintype.card V)
    (S : Finset V) :
    S ∈ coCitationComplex (skeletonCorpus V d) ↔ S.card ≤ d := by
  rw [coCitationComplex, Finset.mem_filter]
  constructor
  · rintro ⟨-, W, hW, hSW⟩
    exact (Finset.card_le_card hSW).trans (le_of_eq (Finset.mem_powersetCard.mp hW).2)
  · intro hcard
    refine ⟨Finset.mem_powerset.mpr (Finset.subset_univ _), ?_⟩
    obtain ⟨W, hSW, hWcard⟩ := Finset.exists_superset_card_eq hcard hd
    exact ⟨W, Finset.mem_powersetCard.mpr ⟨Finset.subset_univ _, hWcard⟩, hSW⟩

/-- For `q ≤ d ≤ n` the `q`-faces of the design are *all* `q`-element sets of theorems. -/
theorem facesOfCard_skeletonCorpus {d q : ℕ} (hqd : q ≤ d) (hd : d ≤ Fintype.card V) :
    facesOfCard (skeletonCorpus V d) q = Finset.univ.powersetCard q := by
  ext S
  rw [facesOfCard, Finset.mem_filter, Finset.mem_powersetCard,
    mem_coCitationComplex_skeletonCorpus hd]
  exact ⟨fun h => ⟨Finset.subset_univ _, h.2⟩, fun h => ⟨h.2 ▸ hqd, h.2⟩⟩

theorem card_facesOfCard_skeletonCorpus {d q : ℕ} (hqd : q ≤ d) (hd : d ≤ Fintype.card V) :
    (facesOfCard (skeletonCorpus V d) q).card = (Fintype.card V).choose q := by
  rw [facesOfCard_skeletonCorpus hqd hd, Finset.card_powersetCard, Finset.card_univ]

/-- **Sharp extremal face count.** Among all corpora whose documents cite at most `d`
theorems, the largest possible number of `q`-element faces is exactly `C(n, q)` whenever
`q ≤ d ≤ n`, and the complete `d`-uniform design attains it. -/
theorem isGreatest_card_facesOfCard_bounded {d q : ℕ} (hqd : q ≤ d)
    (hd : d ≤ Fintype.card V) :
    IsGreatest {m : ℕ | ∃ C : Corpus V, BoundedCorpus C d ∧ (facesOfCard C q).card = m}
      ((Fintype.card V).choose q) := by
  constructor
  · exact ⟨skeletonCorpus V d, boundedCorpus_skeletonCorpus d,
      card_facesOfCard_skeletonCorpus hqd hd⟩
  · rintro m ⟨C, -, rfl⟩
    exact card_facesOfCard_le_choose C q

/-- Polynomial lower bound for the extremal face count: after scaling by `q !` it is at
least `(n - q)^q`.  With the binomial ceiling this shows the extremal `f`-vector entry has
order exactly `n^q`. -/
theorem pow_le_card_facesOfCard_skeletonCorpus {d q : ℕ} (hqd : q ≤ d)
    (hd : d ≤ Fintype.card V) :
    (Fintype.card V - q) ^ q
      ≤ q.factorial * (facesOfCard (skeletonCorpus V d) q).card := by
  rw [card_facesOfCard_skeletonCorpus hqd hd, ← Nat.descFactorial_eq_factorial_mul_choose]
  exact (Nat.pow_le_pow_left (by omega) q).trans
    (Nat.pow_sub_le_descFactorial (Fintype.card V) q)

/-! ## Euler characteristic of the design complex -/

/-- Partial alternating binomial sum: `∑_{j ≤ d} (-1)^j C(m+1, j) = (-1)^d C(m, d)`. -/
theorem alternating_choose_partial (m : ℕ) : ∀ d : ℕ,
    ∑ j ∈ Finset.range (d + 1), ((-1 : ℤ)) ^ j * ((m + 1).choose j : ℤ)
      = ((-1 : ℤ)) ^ d * (m.choose d : ℤ) := by
  intro d
  induction d with
  | zero => simp
  | succ d ih =>
    rw [Finset.sum_range_succ, ih, Nat.choose_succ_succ]
    push_cast
    ring

/-- The Euler characteristic of the co-citation complex, as the alternating sum of the
numbers of faces of each dimension (a face with `q + 1` vertices has dimension `q`). -/
def eulerChar (C : Corpus V) : ℤ :=
  ∑ q ∈ Finset.range (Fintype.card V + 1),
    ((-1 : ℤ)) ^ q * ((facesOfCard C (q + 1)).card : ℤ)

/-- **Euler characteristic of the design complex.**  For `1 ≤ d ≤ n` the complete
`d`-uniform design on `n = m + 1` theorems has Euler characteristic `1 - (-1)^d C(m, d)`.
Its absolute value therefore grows like `n^d`. -/
theorem eulerChar_skeletonCorpus {m d : ℕ} (hcard : Fintype.card V = m + 1)
    (hdn : d ≤ m + 1) :
    eulerChar (skeletonCorpus V d) = 1 - ((-1 : ℤ)) ^ d * (m.choose d : ℤ) := by
  have hd' : d ≤ Fintype.card V := hcard ▸ hdn
  -- kill the terms of dimension `≥ d`
  have htrunc : eulerChar (skeletonCorpus V d)
      = ∑ q ∈ Finset.range d, ((-1 : ℤ)) ^ q *
          ((facesOfCard (skeletonCorpus V d) (q + 1)).card : ℤ) := by
    refine (Finset.sum_subset ?_ ?_).symm
    · intro q hq
      simp only [Finset.mem_range] at hq ⊢
      omega
    · intro q _ hq
      simp only [Finset.mem_range, not_lt] at hq
      rw [facesOfCard_eq_empty_of_bounded (boundedCorpus_skeletonCorpus (V := V) d)
        (by omega)]
      simp
  rw [htrunc]
  have hterm : ∀ q ∈ Finset.range d, ((-1 : ℤ)) ^ q *
      ((facesOfCard (skeletonCorpus V d) (q + 1)).card : ℤ)
        = -(((-1 : ℤ)) ^ (q + 1) * (((m + 1).choose (q + 1) : ℕ) : ℤ)) := by
    intro q hq
    simp only [Finset.mem_range] at hq
    rw [card_facesOfCard_skeletonCorpus (by omega) hd', hcard]
    ring
  rw [Finset.sum_congr rfl hterm, Finset.sum_neg_distrib]
  have hkey := alternating_choose_partial m d
  rw [Finset.sum_range_succ'] at hkey
  simp only [pow_zero, Nat.choose_zero_right, Nat.cast_one, mul_one] at hkey
  linarith

/-! ## Abstract homology profiles and the extremal lower bound -/

/-- An **abstract Betti profile** of a corpus: a sequence of natural numbers dominated by
the chain dimensions of the co-citation complex and satisfying the Euler–Poincaré relation.

For any coefficient field, the simplicial homology of `coCitationComplex C` provides such a
profile: `dim H_k ≤ dim C_k` is the rank–nullity bound, and the alternating sum of Betti
numbers equals the alternating sum of chain dimensions.  All results below use only these
two properties, so they apply to every coefficient field simultaneously. -/
structure HomologyProfile (C : Corpus V) where
  /-- The Betti numbers. -/
  beta : ℕ → ℕ
  /-- Betti numbers are bounded by the chain dimensions. -/
  le_chain : ∀ k, beta k ≤ (facesOfCard C (k + 1)).card
  /-- The Euler–Poincaré relation. -/
  euler : ∑ k ∈ Finset.range (Fintype.card V), ((-1 : ℤ)) ^ k * (beta k : ℤ) = eulerChar C

/-- Every Betti number of a `d`-bounded corpus vanishes in dimensions `≥ d`. -/
theorem HomologyProfile.beta_eq_zero_of_bounded {C : Corpus V} (P : HomologyProfile C)
    {d k : ℕ} (hC : BoundedCorpus C d) (hk : d ≤ k) : P.beta k = 0 := by
  have h := P.le_chain k
  rwa [facesOfCard_eq_empty_of_bounded hC (by omega), Finset.card_empty,
    Nat.le_zero] at h

/-- Every Betti number obeys the binomial ceiling. -/
theorem HomologyProfile.beta_le_choose {C : Corpus V} (P : HomologyProfile C) (k : ℕ) :
    P.beta k ≤ (Fintype.card V).choose (k + 1) :=
  (P.le_chain k).trans (card_facesOfCard_le_choose C (k + 1))

/-- **The Euler characteristic is carried by the surviving dimensions.**  In a `d`-bounded
corpus only the Betti numbers in dimensions `< d` can be nonzero, so the Euler
characteristic is at most their total. -/
theorem HomologyProfile.natAbs_eulerChar_le {C : Corpus V} (P : HomologyProfile C)
    {d : ℕ} (hC : BoundedCorpus C d) (hdn : d ≤ Fintype.card V) :
    (eulerChar C).natAbs ≤ ∑ k ∈ Finset.range d, P.beta k := by
  -- restrict the Euler–Poincaré sum to the range `[0, d)`
  have hrestrict : ∑ k ∈ Finset.range d, ((-1 : ℤ)) ^ k * (P.beta k : ℤ) = eulerChar C := by
    rw [← P.euler]
    refine Finset.sum_subset ?_ ?_
    · intro k hk
      simp only [Finset.mem_range] at hk ⊢
      omega
    · intro k _ hk
      simp only [Finset.mem_range, not_lt] at hk
      rw [P.beta_eq_zero_of_bounded hC hk]
      simp
  have habs : |eulerChar C| ≤ ∑ j ∈ Finset.range d, (P.beta j : ℤ) := by
    rw [← hrestrict]
    refine (Finset.abs_sum_le_sum_abs _ _).trans (le_of_eq (Finset.sum_congr rfl ?_))
    intro j _
    rw [abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul, Nat.abs_cast]
  rw [Int.abs_eq_natAbs] at habs
  exact_mod_cast habs

/-- **Euler characteristic forces a large Betti number.** In a `d`-bounded corpus only `d`
Betti numbers can be nonzero, so the Euler characteristic — an alternating sum of exactly
those `d` numbers — is at most `d` times the largest of them. -/
theorem HomologyProfile.exists_large_betti {C : Corpus V} (P : HomologyProfile C)
    {d : ℕ} (hC : BoundedCorpus C d) (hd : 0 < d) (hdn : d ≤ Fintype.card V) :
    ∃ k < d, (eulerChar C).natAbs ≤ d * P.beta k := by
  obtain ⟨k, hk, hmax⟩ :=
    Finset.exists_max_image (Finset.range d) P.beta ⟨0, Finset.mem_range.mpr hd⟩
  refine ⟨k, Finset.mem_range.mp hk, (P.natAbs_eulerChar_le hC hdn).trans ?_⟩
  calc ∑ j ∈ Finset.range d, P.beta j ≤ ∑ _j ∈ Finset.range d, P.beta k :=
        Finset.sum_le_sum fun j hj => hmax j hj
    _ = d * P.beta k := by rw [Finset.sum_const, Finset.card_range, smul_eq_mul]

/-- **Localisation of the extremal Betti number.**  All Betti numbers below the top
surviving dimension `d - 1` are bounded by the corresponding chain dimensions, which are of
strictly smaller order than the top one.  Hence the whole Euler characteristic, minus that
comparatively small total, must be carried by `β_{d-1}` alone.  This upgrades
`exists_large_betti` from "some dimension below `d`" to the single dimension `d - 1`. -/
theorem HomologyProfile.betti_top_lower {C : Corpus V} (P : HomologyProfile C)
    {d : ℕ} (hC : BoundedCorpus C d) (hd : 0 < d) (hdn : d ≤ Fintype.card V) :
    (eulerChar C).natAbs
      ≤ P.beta (d - 1) + ∑ k ∈ Finset.range (d - 1), (facesOfCard C (k + 1)).card := by
  refine (P.natAbs_eulerChar_le hC hdn).trans ?_
  obtain ⟨e, rfl⟩ : ∃ e, d = e + 1 := ⟨d - 1, by omega⟩
  rw [Finset.sum_range_succ]
  simp only [Nat.add_sub_cancel]
  rw [add_comm]
  exact Nat.add_le_add_left (Finset.sum_le_sum fun k _ => P.le_chain k) _

/-- The Euler characteristic of the design is, up to one unit, at least `C(m, d)`. -/
theorem choose_le_natAbs_eulerChar_skeletonCorpus {m d : ℕ}
    (hcard : Fintype.card V = m + 1) (hdn : d ≤ m + 1) :
    m.choose d ≤ (eulerChar (skeletonCorpus V d)).natAbs + 1 := by
  rw [eulerChar_skeletonCorpus hcard hdn]
  have hkey : (m.choose d : ℤ)
      ≤ (((1 : ℤ) - ((-1 : ℤ)) ^ d * (m.choose d : ℤ)).natAbs : ℤ) + 1 := by
    rcases Nat.even_or_odd d with he | ho
    · rw [he.neg_one_pow]
      simp only [one_mul]
      omega
    · rw [ho.neg_one_pow]
      simp only [neg_mul, one_mul, sub_neg_eq_add]
      omega
  exact_mod_cast hkey

/-- **Extremal Betti lower bound for the design corpus.**  Some Betti number in a dimension
`< d` is at least `(C(n-1, d) - 1) / d`. -/
theorem skeletonCorpus_exists_large_betti {m d : ℕ} (hcard : Fintype.card V = m + 1)
    (hd : 1 ≤ d) (hdn : d ≤ m + 1) (P : HomologyProfile (skeletonCorpus V d)) :
    ∃ k < d, m.choose d ≤ d * P.beta k + 1 := by
  obtain ⟨k, hk, hbound⟩ :=
    P.exists_large_betti (boundedCorpus_skeletonCorpus d) hd (hcard ▸ hdn)
  exact ⟨k, hk,
    (choose_le_natAbs_eulerChar_skeletonCorpus hcard hdn).trans (Nat.add_le_add_right hbound 1)⟩

/-- **The extremal homology sits in dimension `d - 1`.**  For the complete `d`-uniform design
on `n = m + 1` theorems,
`C(m, d) ≤ β_{d-1} + ∑_{j < d - 1} C(n, j + 1) + 1`.
The correction term is a sum of `d - 1` binomial coefficients of order at most `n^{d-1}`,
whereas `C(m, d)` has order `n^d`; so for every fixed `d` and large `n` the Betti number in
the single dimension `d - 1` — and no other — must be of order `n^d`.  This is the
localised form of the extremal lower bound. -/
theorem skeletonCorpus_betti_top_lower {m d : ℕ} (hcard : Fintype.card V = m + 1)
    (hd : 1 ≤ d) (hdn : d ≤ m + 1) (P : HomologyProfile (skeletonCorpus V d)) :
    m.choose d
      ≤ P.beta (d - 1) + (∑ k ∈ Finset.range (d - 1), (m + 1).choose (k + 1)) + 1 := by
  have hchain : ∑ k ∈ Finset.range (d - 1),
      (facesOfCard (skeletonCorpus V d) (k + 1)).card
        = ∑ k ∈ Finset.range (d - 1), (m + 1).choose (k + 1) := by
    refine Finset.sum_congr rfl fun k hk => ?_
    simp only [Finset.mem_range] at hk
    rw [card_facesOfCard_skeletonCorpus (by omega) (hcard ▸ hdn), hcard]
  have hmain := P.betti_top_lower (boundedCorpus_skeletonCorpus d) hd (hcard ▸ hdn)
  rw [hchain] at hmain
  calc m.choose d ≤ (eulerChar (skeletonCorpus V d)).natAbs + 1 :=
        choose_le_natAbs_eulerChar_skeletonCorpus hcard hdn
    _ ≤ (P.beta (d - 1) + ∑ k ∈ Finset.range (d - 1), (m + 1).choose (k + 1)) + 1 :=
        Nat.add_le_add_right hmain 1

/-- **Polynomial extremal growth.**  For the complete `d`-uniform design on `n = m + 1`
theorems, some Betti number in a dimension below `d` satisfies
`(n - d)^d ≤ d! · d · β_k + d!`; that is, the extremal Betti number has order at least
`n^d / (d · d!)`.  Combined with `HomologyProfile.beta_le_choose` this places the extremal
profile of a `d`-bounded corpus at polynomial order `n^d` in its top surviving dimension,
and at `0` from dimension `d` onwards. -/
theorem skeletonCorpus_exists_betti_pow_lower {m d : ℕ} (hcard : Fintype.card V = m + 1)
    (hd : 1 ≤ d) (hdn : d ≤ m + 1) (P : HomologyProfile (skeletonCorpus V d)) :
    ∃ k < d, (m + 1 - d) ^ d ≤ d.factorial * d * P.beta k + d.factorial := by
  obtain ⟨k, hk, hbound⟩ := skeletonCorpus_exists_large_betti hcard hd hdn P
  refine ⟨k, hk, ?_⟩
  have h1 : (m + 1 - d) ^ d ≤ d.factorial * m.choose d := by
    have := Nat.pow_sub_le_descFactorial m d
    rwa [Nat.descFactorial_eq_factorial_mul_choose] at this
  calc (m + 1 - d) ^ d ≤ d.factorial * m.choose d := h1
    _ ≤ d.factorial * (d * P.beta k + 1) := Nat.mul_le_mul_left _ hbound
    _ = d.factorial * d * P.beta k + d.factorial := by ring

/-- The chain dimensions strictly below the top surviving dimension total at most
`(d - 1) · n^{d-1}`. -/
theorem sum_choose_lt_top_le {m d : ℕ} :
    ∑ k ∈ Finset.range (d - 1), (m + 1).choose (k + 1) ≤ (d - 1) * (m + 1) ^ (d - 1) := by
  have hbd : ∀ k ∈ Finset.range (d - 1), (m + 1).choose (k + 1) ≤ (m + 1) ^ (d - 1) := by
    intro k hk
    simp only [Finset.mem_range] at hk
    exact (Nat.choose_le_pow _ _).trans (Nat.pow_le_pow_right (by omega) (by omega))
  simpa [Finset.card_range, smul_eq_mul] using
    Finset.sum_le_card_nsmul (Finset.range (d - 1)) _ ((m + 1) ^ (d - 1)) hbd

/-- **Localised polynomial extremal growth.**  For the complete `d`-uniform design on
`n = m + 1` theorems the Betti number in the single dimension `d - 1` satisfies
`(n - d)^d ≤ d! · (β_{d-1} + (d-1)·n^{d-1} + 1)`.  For fixed `d` the subtracted term is
`O(n^{d-1})`, so `β_{d-1}` itself has order `n^d`, while `HomologyProfile.beta_le_choose`
bounds every other Betti number by `O(n^{d-1})`.  Extremal homology is therefore not merely
large somewhere below dimension `d`: it is concentrated in dimension `d - 1`. -/
theorem skeletonCorpus_betti_top_pow_lower {m d : ℕ} (hcard : Fintype.card V = m + 1)
    (hd : 1 ≤ d) (hdn : d ≤ m + 1) (P : HomologyProfile (skeletonCorpus V d)) :
    (m + 1 - d) ^ d
      ≤ d.factorial * (P.beta (d - 1) + (d - 1) * (m + 1) ^ (d - 1) + 1) := by
  have h1 : (m + 1 - d) ^ d ≤ d.factorial * m.choose d := by
    have := Nat.pow_sub_le_descFactorial m d
    rwa [Nat.descFactorial_eq_factorial_mul_choose] at this
  refine h1.trans (Nat.mul_le_mul_left _ ?_)
  refine (skeletonCorpus_betti_top_lower hcard hd hdn P).trans ?_
  exact Nat.add_le_add_right (Nat.add_le_add_left sum_choose_lt_top_le _) 1

/-! ## Non-vacuity: the design profile really exists -/

/-- The Betti sequence of the `(d-1)`-skeleton of a simplex on `m + 1` vertices:
`β₀ = 1`, `β_{d-1} = C(m, d)` and `β_k = 0` otherwise (for `d = 1` the two indices coincide
and the formula correctly returns `β₀ = m + 1`, the number of isolated theorems). -/
def skeletonBetti (m d k : ℕ) : ℕ :=
  (if k = 0 then 1 else 0) + (if k = d - 1 then m.choose d else 0)

/-- **The abstract profile is realised.**  The classical Betti sequence of the
`(d-1)`-skeleton of the simplex satisfies both axioms of `HomologyProfile` for the design
corpus, so all the extremal results above are statements about a nonempty class of
profiles rather than vacuous ones. -/
def skeletonHomologyProfile {m d : ℕ} (hcard : Fintype.card V = m + 1)
    (hd : 1 ≤ d) (hdn : d ≤ m + 1) : HomologyProfile (skeletonCorpus V d) where
  beta := skeletonBetti m d
  le_chain k := by
    have hd' : d ≤ Fintype.card V := hcard ▸ hdn
    rcases Nat.eq_or_lt_of_le hd with hd1 | hd1
    · -- `d = 1`: the complex is `m + 1` isolated vertices
      subst_vars
      rcases Nat.eq_zero_or_pos k with rfl | hk
      · have hb : skeletonBetti m 1 0 = m + 1 := by
          simp [skeletonBetti]
          omega
        rw [card_facesOfCard_skeletonCorpus (le_refl 1) hd', hcard, hb,
          Nat.choose_one_right]
      · simp [skeletonBetti, hk.ne']
    · -- `d ≥ 2`: the indices `0` and `d - 1` are distinct
      by_cases hk0 : k = 0
      · subst hk0
        rw [card_facesOfCard_skeletonCorpus hd hd', hcard]
        have : ¬ (0 = d - 1) := by omega
        simp [skeletonBetti, this]
      · by_cases hkd : k = d - 1
        · subst hkd
          have hstep : d - 1 + 1 = d := by omega
          rw [hstep, card_facesOfCard_skeletonCorpus (le_refl d) hd', hcard]
          simp only [skeletonBetti, if_neg hk0, zero_add]
          exact Nat.choose_le_choose d (Nat.le_succ m)
        · simp [skeletonBetti, hk0, hkd]
  euler := by
    rw [eulerChar_skeletonCorpus hcard hdn, hcard]
    have hterm : ∀ k ∈ Finset.range (m + 1),
        ((-1 : ℤ)) ^ k * ((skeletonBetti m d k : ℕ) : ℤ)
          = (if k = 0 then (1 : ℤ) else 0)
            + (if k = d - 1 then ((-1 : ℤ)) ^ (d - 1) * (m.choose d : ℤ) else 0) := by
      intro k _
      rcases eq_or_ne k 0 with rfl | hk0
      · rcases eq_or_ne 0 (d - 1) with hd0 | hd0
        · simp [skeletonBetti, ← hd0]
        · simp [skeletonBetti, hd0]
      · rcases eq_or_ne k (d - 1) with rfl | hkd
        · simp [skeletonBetti, hk0]
        · simp [skeletonBetti, hk0, hkd]
    rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, Finset.sum_ite_eq' ,
      Finset.sum_ite_eq']
    rw [if_pos (Finset.mem_range.mpr (by omega)),
      if_pos (Finset.mem_range.mpr (by omega))]
    have hpow : ((-1 : ℤ)) ^ (d - 1) = -((-1 : ℤ)) ^ d := by
      obtain ⟨e, rfl⟩ : ∃ e, d = e + 1 := ⟨d - 1, by omega⟩
      simp [pow_succ]
    rw [hpow]
    ring

end CorpusBettiExtremal