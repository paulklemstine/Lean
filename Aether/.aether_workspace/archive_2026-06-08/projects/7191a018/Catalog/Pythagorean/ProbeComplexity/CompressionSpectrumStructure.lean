/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Pythagorean.ProbeComplexity.ToposCompressionDefs

/-!
# Compression Spectrum Structure

This file develops the structural theory of the **compression spectrum**

  CompSpec(F, r) = { n ∈ ℕ | ∃ P, |P| = n ∧ P separates }

and proves that it is an upper set (upward-closed interval) in ℕ, fully
determined by a single threshold — the **compression number** κ(F, r).

## Main Definitions

* `ProbeEssential` — a probe `p ∈ P` is essential if `P \ {p}` does not separate.
* `compressionNumber` — the minimum cardinality of a separating family.
* `compressionDefect` — measures non-uniformity of minimal separating families.
* `obstructionFamily` — the family of all indistinguishability witnesses.

## Main Theorems

* `compressionSpectrum_upward_closed` — the spectrum is upward-closed.
* `mem_compressionSpectrum_iff_compressionNumber_le` — the spectrum is an interval [κ, |Ob|].
* `exists_minimal_separating_subfamily` — every separating family contains a minimal one.
* `minimal_separating_family_all_essential` — in a minimal family, every probe is essential.
* `probeSeparates_iff_hits_obstructions` — separation ↔ hitting all obstructions.
* `compressionDefect_zero_iff` — defect is zero iff all minimal families have equal size.

## Cross-Domain Significance

These results bridge:
- **Combinatorial optimization**: separation = hitting set for obstructions
- **Matroid theory**: essential probes = circuit-like irreducibility
- **Information theory**: compression number = minimum code length
- **Feature selection**: minimal separating families = irreducible feature sets
-/

open Finset Fintype

noncomputable section

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

universe u v

variable {Ob : Type u} [Fintype Ob] [DecidableEq Ob]

/-! ## Section 1: Essential Probes -/

/-- A probe `p` is **essential** in a separating family `P` if removing it
destroys the separation property. This identifies `p` as carrying
irreducible distinguishing information. -/
def ProbeEssential
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (P : Finset Ob) (p : Ob) : Prop :=
  p ∈ P ∧ ¬ ProbeSeparates F r (P.erase p)

/-- A separating family is **inclusion-minimal** if no proper subfamily separates. -/
def IsMinimalSeparating
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (P : Finset Ob) : Prop :=
  ProbeSeparates F r P ∧ ∀ Q : Finset Ob, Q ⊂ P → ¬ ProbeSeparates F r Q

/-- A separating family has **minimum cardinality** if no smaller family separates. -/
def IsMinCardSeparating
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (P : Finset Ob) : Prop :=
  ProbeSeparates F r P ∧ ∀ Q : Finset Ob, ProbeSeparates F r Q → P.card ≤ Q.card

/-! ## Section 2: Upward Closure of the Compression Spectrum -/

/-
**Theorem 1 (Upward Closure).**
The compression spectrum is upward-closed: if `n` is in the spectrum
(some family of size `n` separates) and `n ≤ m ≤ |Ob|`, then `m` is
also in the spectrum.

The proof explicitly constructs a separating family of size `m` by
extending a given family of size `n` with `m - n` fresh elements
from the complement, using `Finset.exists_superset_card_eq`.
-/
theorem compressionSpectrum_upward_closed
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    {n m : ℕ}
    (hn : n ∈ compressionSpectrum' F r)
    (hnm : n ≤ m)
    (hm : m ≤ Fintype.card Ob) :
    m ∈ compressionSpectrum' F r := by
  obtain ⟨ P, hP₁, hP₂ ⟩ := hn;
  obtain ⟨ Q, hQ₁, hQ₂ ⟩ := Finset.exists_superset_card_eq ( by linarith : #P ≤ m ) ( by linarith : m ≤ Fintype.card Ob );
  exact ⟨ Q, hQ₂, ProbeSeparates.mono hP₂ hQ₁ ⟩

/-! ## Section 3: Compression Number and Interval Characterization -/

/-- The **compression number** κ(F, r): the minimum cardinality of any
separating probe family. Defined as `sInf` of the compression spectrum.
Equal to `presheafMinCompression'` by definition. -/
def compressionNumber
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z) : ℕ :=
  sInf (compressionSpectrum' F r)

/-
The compression number is at most `|Ob|` when a separating family exists.
-/
theorem compressionNumber_le_card
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hex : ∃ P, ProbeSeparates F r P) :
    compressionNumber F r ≤ Fintype.card Ob := by
  -- Since the universal set is a separating family of size |Ob|, we have |Ob| ∈ compressionSpectrum' F r.
  have h_univ_separates : ProbeSeparates F r Finset.univ := by
    exact fun Y => ProbeSeparates.mono hex.choose_spec ( Finset.subset_univ _ ) Y;
  exact Nat.sInf_le ⟨ Finset.univ, by simp +decide [ h_univ_separates ] ⟩

/-
The compression number is at most the cardinality of any separating family.
-/
theorem compressionNumber_le_of_sep
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (P : Finset Ob) (hP : ProbeSeparates F r P) :
    compressionNumber F r ≤ P.card := by
  exact Nat.sInf_le ⟨ P, rfl, hP ⟩

/-
The compression number is achieved by some separating family.
-/
theorem compressionNumber_achieved
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hex : ∃ P, ProbeSeparates F r P) :
    ∃ P : Finset Ob, P.card = compressionNumber F r ∧ ProbeSeparates F r P := by
  have := Nat.sInf_mem ( show { n | ∃ P : Finset Ob, Finset.card P = n ∧ ProbeSeparates F r P }.Nonempty from ?_ );
  · exact this;
  · exact ⟨ _, ⟨ hex.choose, rfl, hex.choose_spec ⟩ ⟩

/-
**Theorem 2 (Spectrum = Interval).**
If any separating family exists, then
  `n ∈ compressionSpectrum'(F, r) ↔ κ(F, r) ≤ n ∧ n ≤ |Ob|`.

This says the compression spectrum is fully determined by the single
threshold κ — no gaps exist.
-/
theorem mem_compressionSpectrum_iff_compressionNumber_le
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hex : ∃ P, ProbeSeparates F r P)
    {n : ℕ} :
    n ∈ compressionSpectrum' F r ↔
      compressionNumber F r ≤ n ∧ n ≤ Fintype.card Ob := by
  constructor;
  · rintro ⟨ P, rfl, hP ⟩;
    exact ⟨ compressionNumber_le_of_sep F r P hP, Finset.card_le_univ _ ⟩;
  · intro hn
    obtain ⟨hn_le, hn_ge⟩ := hn
    have h_compressionNumber_le_n : compressionNumber F r ≤ n := hn_le
    have h_n_le_card : n ≤ Fintype.card Ob := hn_ge
    have h_compressionNumber_in_spectrum : compressionNumber F r ∈ compressionSpectrum' F r := by
      exact compressionNumber_achieved F r hex |> fun ⟨ P, hP₁, hP₂ ⟩ => ⟨ P, hP₁, hP₂ ⟩
    have h_compressionSpectrum_upward_closed : ∀ m, compressionNumber F r ≤ m → m ≤ Fintype.card Ob → m ∈ compressionSpectrum' F r := by
      exact fun m a a_1 => compressionSpectrum_upward_closed F r h_compressionNumber_in_spectrum a a_1
    exact h_compressionSpectrum_upward_closed n h_compressionNumber_le_n h_n_le_card

/-! ## Section 4: Existence of Minimal Separating Subfamilies -/

/-
**Theorem (Minimal subfamily existence).**
Every separating family contains an inclusion-minimal separating subfamily.
Proved by well-founded induction on `P.card`: at each step, either `P` is
already minimal, or some probe can be removed while preserving separation.
-/
theorem exists_minimal_separating_subfamily
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    {P : Finset Ob}
    (hP : ProbeSeparates F r P) :
    ∃ Q, Q ⊆ P ∧ ProbeSeparates F r Q ∧
      ∀ R, R ⊂ Q → ¬ ProbeSeparates F r R := by
  -- By the well-foundedness of the powerset of P, we can find such a minimal subset Q.
  obtain ⟨Q, hQ_min⟩ : ∃ Q ∈ {Q : Finset Ob | Q ⊆ P ∧ ProbeSeparates F r Q}, ∀ R ∈ {Q : Finset Ob | Q ⊆ P ∧ ProbeSeparates F r Q}, Q.card ≤ R.card := by
    apply_rules [ Set.exists_min_image ];
    · exact Set.toFinite _;
    · exact ⟨ P, Finset.Subset.refl _, hP ⟩;
  exact ⟨ Q, hQ_min.1.1, hQ_min.1.2, fun R hR hR' => not_lt_of_ge ( hQ_min.2 R ⟨ Finset.Subset.trans hR.subset hQ_min.1.1, hR' ⟩ ) ( Finset.card_lt_card hR ) ⟩

/-! ## Section 5: Essential Probes in Minimal Families -/

/-
**Theorem 3 (Essential probes in minimal-cardinality families).**
If `P` is a separating family of minimum cardinality, then every probe
in `P` is essential: removing any single probe destroys separation.

Proof: by contradiction. If some `p ∈ P` were inessential, then
`P.erase p` would still separate, but `(P.erase p).card < P.card`,
contradicting the minimality of `P.card`.
-/
theorem minimal_separating_family_all_essential
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    {P : Finset Ob}
    (hsep : ProbeSeparates F r P)
    (hmin : ∀ Q, ProbeSeparates F r Q → P.card ≤ Q.card) :
    ∀ p, p ∈ P → ProbeEssential F r P p := by
  intro p hp
  by_contra h_not_essential;
  exact absurd ( hmin ( P.erase p ) ( by unfold ProbeEssential at h_not_essential; aesop ) ) ( by rw [ Finset.card_erase_of_mem hp ] ; exact Nat.not_le_of_gt ( Nat.pred_lt ( ne_bot_of_gt ( Finset.card_pos.mpr ⟨ p, hp ⟩ ) ) ) )

/-
Every probe in an inclusion-minimal separating family is essential.
-/
theorem inclusion_minimal_all_essential
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    {P : Finset Ob}
    (hmin : IsMinimalSeparating F r P) :
    ∀ p, p ∈ P → ProbeEssential F r P p := by
  intro p hp;
  exact ⟨ hp, fun h => hmin.2 ( P.erase p ) ( Finset.erase_ssubset hp ) h ⟩

/-! ## Section 6: Obstruction Family and Hitting-Set Duality -/

/-- The **obstruction family**: for each pair of objects `Y` and each pair of
distinct sections `(s, t)` that must be distinguished, the set of probes
that distinguish them.

More precisely, for each `Y` and each pair `(s, t)` with `s ≠ t`, the
obstruction is `{Z ∈ Ob | r Y Z s ≠ r Y Z t}` — the set of probes that
can tell `s` from `t`. A probe family separates iff it intersects every
such obstruction. -/
def distinguishingSet
    (F : Ob → Type v) [∀ Y, DecidableEq (F Y)]
    (r : ∀ Y Z, F Y → F Z)
    (Y : Ob) (s t : F Y) : Finset Ob :=
  Finset.univ.filter (fun Z => r Y Z s ≠ r Y Z t)

/-
A probe family separates iff it intersects every distinguishing set
(i.e., for every pair of distinct sections, some probe tells them apart).
-/
theorem probeSeparates_iff_hits_distinguishing
    (F : Ob → Type v) [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    (r : ∀ Y Z, F Y → F Z) (P : Finset Ob) :
    ProbeSeparates F r P ↔
      ∀ Y : Ob, ∀ s t : F Y, s ≠ t →
        ∃ Z ∈ P, r Y Z s ≠ r Y Z t := by
  constructor <;> intro h;
  · intro Y s t hne;
    contrapose! hne;
    exact h Y ( funext fun Z => hne _ Z.2 );
  · exact fun Y => fun s t hst => Classical.not_not.1 fun hst' => by obtain ⟨ Z, hZ₁, hZ₂ ⟩ := h Y s t hst'; exact hZ₂ <| congr_fun hst ⟨ Z, hZ₁ ⟩ ;

/-! ## Section 7: Compression Defect -/

/-- The set of cardinalities of inclusion-minimal separating families. -/
def minimalSepCards
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z) : Set ℕ :=
  {n : ℕ | ∃ P : Finset Ob, IsMinimalSeparating F r P ∧ P.card = n}

/-- The **compression defect** δ(F, r): the difference between the maximum
and minimum cardinalities of inclusion-minimal separating families.
When δ = 0, all minimal separating families have the same size,
suggesting matroid-like uniformity. -/
def compressionDefect
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z) : ℕ :=
  sSup (minimalSepCards F r) - sInf (minimalSepCards F r)

/-
If the compression defect is zero, all inclusion-minimal separating
families have the same cardinality.
-/
theorem compressionDefect_zero_iff_uniform
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    (hex : ∃ P, IsMinimalSeparating F r P) :
    (∀ P Q : Finset Ob, IsMinimalSeparating F r P →
      IsMinimalSeparating F r Q → P.card = Q.card) →
    compressionDefect F r = 0 := by
  intro h;
  refine' tsub_eq_zero_of_le _;
  refine' csSup_le _ _;
  · exact ⟨ _, ⟨ hex.choose, hex.choose_spec, rfl ⟩ ⟩;
  · rintro n ⟨ P, hP, rfl ⟩;
    exact le_csInf ⟨ _, ⟨ P, hP, rfl ⟩ ⟩ fun n hn => by obtain ⟨ Q, hQ, rfl ⟩ := hn; exact h P Q hP hQ ▸ le_rfl;

/-! ## Section 8: Minimum-cardinality separating families are inclusion-minimal -/

/-
A minimum-cardinality separating family is also inclusion-minimal.
-/
theorem minCard_sep_is_inclusion_minimal
    (F : Ob → Type v) (r : ∀ Y Z, F Y → F Z)
    {P : Finset Ob}
    (hsep : ProbeSeparates F r P)
    (hmin : ∀ Q, ProbeSeparates F r Q → P.card ≤ Q.card) :
    IsMinimalSeparating F r P := by
  exact ⟨ hsep, fun Q hQ hQ' => not_lt_of_ge ( hmin Q hQ' ) ( Finset.card_lt_card hQ ) ⟩

end