import Mathlib

/-!
# The round-43 boundary is the NFS route: columns governed by the field `d`, not by `N`

Round 43 showed that every quadratic-sieve "decoupling channel" is closed because the QS
split set is slaved to `N`.  This file machine-checks the mechanism and the one escape.

## Set-up
* `oddFactorBase B` — the odd primes `r ≤ B`.
* `Splits a r` — a computable predicate: `r ∤ a` and `a` is a square mod `r`.
  (`splits_iff_legendre`: for an odd prime this is exactly `(a/r) = +1`.)
* `qsColumns N B`, `nfsColumns d B` — the odd factor-base primes split by the parameter.

## Results
1. **QS columns are governed by `N`** (`mem_qsColumns_iff`, `qs_relation_forces_column`):
   an odd prime `r ∤ N` divides some sieve value `x² − N` iff `r ∈ qsColumns N B`, and every
   homogeneous QS relation `r ∣ x² − N y²`, `r ∤ y` forces `N` to be a square mod `r`.
2. **NFS columns are degree-one prime ideals of `ℤ[√d]`** (`card_ringHom_zsqrtd`):
   for an odd prime `r`, the number of ring homomorphisms `ℤ[√d] → 𝔽_r` (= degree-one primes
   above `r`, `ker_injective`, `ker_isMaximal`) is exactly `1 + (d/r)`.  Hence `r` yields a
   *pair* of such ideals iff `(d/r) = +1` (`mem_nfsColumns_iff`), and an NFS relation
   `x + y√d` with `r ∣ x² − d y²`, `r ∤ y` lies in one of them (`nfs_relation_localises`,
   with converse `ideal_vanishing_divides_norm`).
3. **The decoupling theorem** (`nfs_columns_free`, `attainable_nfs_patterns`): fix the
   integer `N` to be factored and even the root `m`.  Among all quadratic fields `d` that are
   valid for `N` (i.e. `x² − d` has the root `m` modulo `N`), the NFS column set restricted to
   the factor-base primes coprime to `N` takes **every one** of the `2^|S|` possible values.
   By contrast the QS column set is a single set determined by `N`.  The QS is precisely the
   member `d = N`, `m = 0` of this family — the one member the attacker does not choose.
4. **Yield cancellation** (`sum_card_ringHom_zsqrtd`): summed over `d = 0, …, r−1` the
   degree-one prime count above `r` is exactly `r` — choosing the field redistributes split
   primes but does not raise their average.
5. **Residual coupling** (`valid_field_splits_at_factors`, `valid_field_iff_splits_prime`):
   the tie to `N` does not vanish, it *moves*: validity forces `(d/p) = +1` at the hidden prime
   factors `p ∣ N` (with `p ∤ d`), and nowhere on the factor base.
6. **Lab data** (`lab_*`, kernel `decide`): for `d = −7`, `B = 200`: `21` odd split primes
   (`22` counting `r = 2`, which also splits since `−7 ≡ 1 mod 8`; `2` is outside this file's
   odd factor base).  The same field is valid for `N = 11` and `N = 23`, while
   `qsColumns 11 200` (20 primes) and `qsColumns 23 200` (19 primes) differ; `qsColumns 15 200`
   and `qsColumns 47 200` have 21 and 25 primes.

Scope: this concerns the *quadratic* NFS (`ℤ[√d]`) as a model of the ideal sieve; it is a
structural statement about which parameter controls the column set, not a running-time claim.
The definitions mirror `QSDimension.admissiblePrimes` (Catalog `Shared.QSFactorBaseDimension`),
restricted to odd primes and with `r ∤ N` made explicit; the file imports only Mathlib so that
it compiles standalone.
-/

namespace Logic.NFSFieldColumns

open Finset

/-- The odd primes `r ≤ B` (the factor base without the prime `2`). -/
def oddFactorBase (B : ℕ) : Finset ℕ :=
  (range (B + 1)).filter (fun r => r.Prime ∧ r ≠ 2)

theorem mem_oddFactorBase {B r : ℕ} : r ∈ oddFactorBase B ↔ r ≤ B ∧ r.Prime ∧ r ≠ 2 := by
  simp [oddFactorBase]

/-- `r` *splits* the parameter `a`: `r ∤ a` and `a` is a square modulo `r`
(in computable form: some `x < r` has `r ∣ x² − a`). -/
def Splits (a : ℤ) (r : ℕ) : Prop :=
  ¬ (r : ℤ) ∣ a ∧ ∃ x ∈ range r, (r : ℤ) ∣ (x : ℤ) ^ 2 - a

instance (a : ℤ) : DecidablePred (Splits a) := fun r => by
  unfold Splits; infer_instance

/-- The quadratic-sieve column set for the modulus `N`. -/
def qsColumns (N : ℤ) (B : ℕ) : Finset ℕ := (oddFactorBase B).filter (Splits N)

/-- The number-field-sieve (ideal-sieve) column set for the field `ℚ(√d)`. -/
def nfsColumns (d : ℤ) (B : ℕ) : Finset ℕ := (oddFactorBase B).filter (Splits d)

/-! ## The split predicate is the Legendre condition -/

theorem splits_iff_isSquare {a : ℤ} {r : ℕ} (hr : r.Prime) :
    Splits a r ↔ (a : ZMod r) ≠ 0 ∧ IsSquare (a : ZMod r) := by
  haveI : NeZero r := ⟨hr.ne_zero⟩
  unfold Splits
  rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
  refine and_congr_right fun _ => ?_
  constructor
  · rintro ⟨x, -, hx⟩
    refine ⟨(x : ZMod r), ?_⟩
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd _ r).2 hx
    push_cast at this
    linear_combination -this
  · rintro ⟨s, hs⟩
    refine ⟨s.val, mem_range.2 (ZMod.val_lt s), ?_⟩
    rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
    push_cast
    rw [ZMod.natCast_zmod_val, hs]
    ring

/-- The split predicate depends only on the residue of the parameter modulo `r`. -/
theorem splits_congr {a b : ℤ} {r : ℕ} (hr : r.Prime) (h : (r : ℤ) ∣ b - a) :
    Splits a r ↔ Splits b r := by
  rw [splits_iff_isSquare hr, splits_iff_isSquare hr,
    (ZMod.intCast_eq_intCast_iff_dvd_sub a b r).2 h]

/-- For an odd prime `r`, `Splits a r` is exactly the Legendre condition `(a/r) = +1`. -/
theorem splits_iff_legendre {a : ℤ} {r : ℕ} [Fact r.Prime] :
    Splits a r ↔ legendreSym r a = 1 := by
  rw [splits_iff_isSquare (Fact.out : r.Prime)]
  by_cases ha : (a : ZMod r) = 0
  · have : legendreSym r a = 0 := (legendreSym.eq_zero_iff r a).2 ha
    simp [ha, this]
  · rw [legendreSym.eq_one_iff r ha]
    simp [ha]

/-! ## QS: the column set is governed by `N` -/

/-- Some integer `x` has `r ∣ x² − a` iff `a` is a square modulo `r`. -/
theorem exists_int_dvd_iff_isSquare {a : ℤ} {r : ℕ} (hr : 0 < r) :
    (∃ x : ℤ, (r : ℤ) ∣ x ^ 2 - a) ↔ IsSquare (a : ZMod r) := by
  haveI : NeZero r := ⟨hr.ne'⟩
  constructor
  · rintro ⟨x, hx⟩
    refine ⟨(x : ZMod r), ?_⟩
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd _ r).2 hx
    push_cast at this
    linear_combination -this
  · rintro ⟨s, hs⟩
    refine ⟨(s.val : ℤ), ?_⟩
    rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
    push_cast
    rw [ZMod.natCast_zmod_val, hs]
    ring

/-- QS columns depend on `N` only through its residues modulo the factor-base primes. -/
theorem qsColumns_congr {N N' : ℤ} {B : ℕ} (h : ∀ r ∈ oddFactorBase B, (r : ℤ) ∣ N' - N) :
    qsColumns N B = qsColumns N' B := by
  unfold qsColumns
  refine filter_congr fun r hr => ?_
  exact splits_congr (mem_oddFactorBase.1 hr).2.1 (h r hr)

/-- **QS columns are slaved to `N`.**  An odd prime `r ≤ B` with `r ∤ N` is a QS column iff it
divides some sieve value `x² − N`. -/
theorem mem_qsColumns_iff {N : ℤ} {B r : ℕ} :
    r ∈ qsColumns N B ↔
      r ∈ oddFactorBase B ∧ ¬ (r : ℤ) ∣ N ∧ ∃ x : ℤ, (r : ℤ) ∣ x ^ 2 - N := by
  constructor
  · intro h
    obtain ⟨hB, hsp⟩ := mem_filter.1 h
    obtain ⟨-, hr, -⟩ := mem_oddFactorBase.1 hB
    rw [splits_iff_isSquare hr] at hsp
    refine ⟨hB, fun hd => hsp.1 ((ZMod.intCast_zmod_eq_zero_iff_dvd _ _).2 hd), ?_⟩
    exact (exists_int_dvd_iff_isSquare hr.pos).2 hsp.2
  · rintro ⟨hB, hN, hx⟩
    obtain ⟨-, hr, -⟩ := mem_oddFactorBase.1 hB
    refine mem_filter.2 ⟨hB, (splits_iff_isSquare hr).2 ⟨?_, ?_⟩⟩
    · rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
    · exact (exists_int_dvd_iff_isSquare hr.pos).1 hx

/-- **Every homogeneous QS relation forces the `N`-Legendre condition.**  If `r` is prime,
`r ∤ N`, `r ∤ y` and `r ∣ x² − N y²`, then `(N/r) = +1`, i.e. `Splits N r`. -/
theorem qs_relation_forces_column {N x y : ℤ} {r : ℕ} (hr : r.Prime) (hN : ¬ (r : ℤ) ∣ N)
    (hy : ¬ (r : ℤ) ∣ y) (hrel : (r : ℤ) ∣ x ^ 2 - N * y ^ 2) : Splits N r := by
  haveI : Fact r.Prime := ⟨hr⟩
  rw [splits_iff_isSquare hr]
  have hN' : (N : ZMod r) ≠ 0 := by rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
  have hy' : (y : ZMod r) ≠ 0 := by rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
  have h := (ZMod.intCast_zmod_eq_zero_iff_dvd _ r).2 hrel
  push_cast at h
  refine ⟨hN', (x : ZMod r) / y, ?_⟩
  field_simp
  linear_combination -h

/-! ## NFS: degree-one prime ideals of `ℤ[√d]` are counted by `1 + (d/r)` -/

/-- The number of square roots of `a` in `𝔽_r` (`r` odd prime) is `1 + (a/r)`. -/
theorem card_sqrt_zmod {r : ℕ} [Fact r.Prime] (hr2 : r ≠ 2) (a : ℤ) :
    (Nat.card {s : ZMod r // s * s = (a : ZMod r)} : ℤ) = legendreSym r a + 1 := by
  rw [legendreSym, ← quadraticChar_card_sqrts (by rwa [ZMod.ringChar_zmod_n]) ((a : ZMod r))]
  congr 1
  rw [Nat.card_eq_fintype_card, Set.toFinset_card]
  exact Fintype.card_congr (Equiv.subtypeEquivRight fun s => by simp [sq])

/-- **Degree-one prime count.**  For an odd prime `r`, the number of ring homomorphisms
`ℤ[√d] → 𝔽_r` is exactly `1 + (d/r)`. -/
theorem card_ringHom_zsqrtd {r : ℕ} [Fact r.Prime] (hr2 : r ≠ 2) (d : ℤ) :
    (Nat.card (ℤ√d →+* ZMod r) : ℤ) = legendreSym r d + 1 := by
  rw [← card_sqrt_zmod hr2 d, Nat.card_congr Zsqrtd.lift.symm]

/-- Distinct homomorphisms `ℤ[√d] → 𝔽_r` have distinct kernels: the homomorphisms *are* the
degree-one prime ideals above `r`. -/
theorem ker_injective {r : ℕ} [Fact r.Prime] (d : ℤ) :
    Function.Injective (fun f : ℤ√d →+* ZMod r => RingHom.ker f) := by
  intro f g h
  simp only at h
  apply Zsqrtd.hom_ext
  set s := f Zsqrtd.sqrtd
  have hz : Zsqrtd.sqrtd - (((s.val : ℤ)) : ℤ√d) ∈ RingHom.ker f := by
    rw [RingHom.mem_ker, map_sub, map_intCast]
    simp [s]
  rw [h, RingHom.mem_ker, map_sub, map_intCast] at hz
  have : ((s.val : ℤ) : ZMod r) = s := by simp
  rw [this] at hz
  exact (sub_eq_zero.1 hz).symm

/-- Each such kernel is a maximal ideal (of residue field `𝔽_r`). -/
theorem ker_isMaximal {r : ℕ} [Fact r.Prime] {d : ℤ} (f : ℤ√d →+* ZMod r) :
    (RingHom.ker f).IsMaximal := by
  apply RingHom.ker_isMaximal_of_surjective
  intro z
  refine ⟨((z.val : ℤ) : ℤ√d), ?_⟩
  simp

/-- **NFS columns are exactly the primes with a pair of degree-one prime ideals.** -/
theorem mem_nfsColumns_iff {d : ℤ} {B r : ℕ} :
    r ∈ nfsColumns d B ↔ r ∈ oddFactorBase B ∧ Nat.card (ℤ√d →+* ZMod r) = 2 := by
  unfold nfsColumns
  rw [mem_filter]
  refine and_congr_right fun hB => ?_
  obtain ⟨-, hr, hr2⟩ := mem_oddFactorBase.1 hB
  haveI : Fact r.Prime := ⟨hr⟩
  rw [splits_iff_legendre]
  have := card_ringHom_zsqrtd hr2 d
  omega

/-- **An NFS relation localises at a degree-one prime ideal.**  If `r ∣ x² − d y²`
(the norm of `x + y√d`) and `r ∤ y`, some homomorphism `ℤ[√d] → 𝔽_r` kills `x + y√d`. -/
theorem nfs_relation_localises {d x y : ℤ} {r : ℕ} [Fact r.Prime]
    (hy : ¬ (r : ℤ) ∣ y) (hrel : (r : ℤ) ∣ x ^ 2 - d * y ^ 2) :
    ∃ f : ℤ√d →+* ZMod r, f ⟨x, y⟩ = 0 := by
  have hy' : (y : ZMod r) ≠ 0 := by rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
  have h := (ZMod.intCast_zmod_eq_zero_iff_dvd _ r).2 hrel
  push_cast at h
  have hs : (-(x : ZMod r) / y) * (-(x : ZMod r) / y) = (d : ZMod r) := by
    field_simp
    linear_combination h
  refine ⟨Zsqrtd.lift ⟨-(x : ZMod r) / y, hs⟩, ?_⟩
  simp [Zsqrtd.lift]
  field_simp
  ring

/-- Converse: if a degree-one prime ideal above `r` contains `x + y√d`, then `r` divides the
norm `x² − d y²`. -/
theorem ideal_vanishing_divides_norm {d x y : ℤ} {r : ℕ} (f : ℤ√d →+* ZMod r)
    (hf : f ⟨x, y⟩ = 0) : (r : ℤ) ∣ x ^ 2 - d * y ^ 2 := by
  have hn := congrArg f (Zsqrtd.norm_eq_mul_conj (⟨x, y⟩ : ℤ√d))
  rw [map_intCast, map_mul, hf, zero_mul, Zsqrtd.norm_def] at hn
  rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
  push_cast at hn ⊢
  linear_combination hn

/-! ## The decoupling theorem -/

/-- The factor-base primes coprime to `N` (those on which a column pattern can be read). -/
def coprimeBase (N : ℤ) (B : ℕ) : Finset ℕ :=
  (oddFactorBase B).filter (fun r => ¬ (r : ℤ) ∣ N)

/-- Every split/inert pattern is realised by some residue modulo an odd prime. -/
theorem exists_residue_pattern {r : ℕ} (hr : r.Prime) (hr2 : r ≠ 2) (b : Prop) :
    ∃ t : ℤ, (Splits t r ↔ b) := by
  haveI : Fact r.Prime := ⟨hr⟩
  by_cases hb : b
  · refine ⟨1, ?_⟩
    simp only [hb, iff_true]
    rw [splits_iff_isSquare hr]
    exact ⟨by simp, ⟨1, by simp⟩⟩
  · obtain ⟨ns, hns⟩ := FiniteField.exists_nonsquare (F := ZMod r) (by rwa [ZMod.ringChar_zmod_n])
    refine ⟨(ns.val : ℤ), ?_⟩
    simp only [hb, iff_false]
    rw [splits_iff_isSquare hr]
    have : (((ns.val : ℤ)) : ZMod r) = ns := by simp
    rw [this]
    exact fun h => hns h.2

/-- **Decoupling theorem.**  Fix the integer `N` being factored and a root `m`.  For every
target pattern `T` of factor-base primes coprime to `N`, some quadratic field `d` is valid for
`N` (`N ∣ m² − d`, so `x² − d` has the root `m` modulo `N`) and has NFS column set exactly `T`
on those primes. -/
theorem nfs_columns_free (N m : ℤ) (B : ℕ) (T : Finset ℕ) (hT : T ⊆ coprimeBase N B) :
    ∃ d : ℤ, N ∣ m ^ 2 - d ∧ nfsColumns d B ∩ coprimeBase N B = T := by
  classical
  have hS : ∀ r ∈ coprimeBase N B, r.Prime ∧ r ≠ 2 ∧ ¬ (r : ℤ) ∣ N := by
    intro r hr
    obtain ⟨hB, hN⟩ := mem_filter.1 hr
    obtain ⟨-, hp, h2⟩ := mem_oddFactorBase.1 hB
    exact ⟨hp, h2, hN⟩
  have ht : ∀ r : coprimeBase N B, ∃ t : ℤ, (Splits t r ↔ (r : ℕ) ∈ T) := fun r =>
    exists_residue_pattern (hS r r.2).1 (hS r r.2).2.1 _
  choose t ht using ht
  let I : Option (coprimeBase N B) → Ideal ℤ :=
    fun i => Option.elim i (Ideal.span {N}) (fun r => Ideal.span {((r : ℕ) : ℤ)})
  have hcop : Pairwise (Function.onFun IsCoprime I) := by
    have key : ∀ r : coprimeBase N B, IsCoprime ((r : ℕ) : ℤ) N := fun r =>
      (Irreducible.coprime_iff_not_dvd
        (Nat.prime_iff_prime_int.mp (hS r r.2).1).irreducible).2 (hS r r.2).2.2
    rintro (_ | r) (_ | r') hne
    · exact absurd rfl hne
    · exact (Ideal.isCoprime_span_singleton_iff _ _).2 (key r').symm
    · exact (Ideal.isCoprime_span_singleton_iff _ _).2 (key r)
    · refine (Ideal.isCoprime_span_singleton_iff _ _).2 (Nat.isCoprime_iff_coprime.2 ?_)
      refine (Nat.coprime_primes (hS r r.2).1 (hS r' r'.2).1).2 ?_
      intro h
      exact hne (congrArg some (Subtype.ext h))
  obtain ⟨d, hd⟩ := Ideal.exists_forall_sub_mem_ideal hcop (fun i => Option.elim i (m ^ 2) t)
  refine ⟨d, ?_, ?_⟩
  · have h0 := hd none
    simp only [I, Option.elim, Ideal.mem_span_singleton] at h0
    exact (dvd_sub_comm).1 h0
  · ext r
    simp only [mem_inter, nfsColumns, mem_filter]
    constructor
    · rintro ⟨⟨-, hsp⟩, hrS⟩
      have h1 := hd (some ⟨r, hrS⟩)
      simp only [I, Option.elim, Ideal.mem_span_singleton] at h1
      exact (ht ⟨r, hrS⟩).1 ((splits_congr (hS r hrS).1 h1).2 hsp)
    · intro hrT
      have hrS := hT hrT
      have h1 := hd (some ⟨r, hrS⟩)
      simp only [I, Option.elim, Ideal.mem_span_singleton] at h1
      exact ⟨⟨(mem_filter.1 hrS).1, (splits_congr (hS r hrS).1 h1).1 ((ht ⟨r, hrS⟩).2 hrT)⟩,
        hrS⟩

/-- **Attainable NFS column patterns for a fixed `N`.**  The set of column patterns over all
fields valid for `N` (with root `m`) is the full power set of the coprime factor base. -/
theorem attainable_nfs_patterns (N m : ℤ) (B : ℕ) :
    {C : Finset ℕ | ∃ d : ℤ, N ∣ m ^ 2 - d ∧ nfsColumns d B ∩ coprimeBase N B = C} =
      ↑(coprimeBase N B).powerset := by
  ext C
  simp only [Set.mem_setOf_eq, coe_powerset, Set.mem_preimage, Set.mem_powerset_iff, coe_subset]
  constructor
  · rintro ⟨d, -, rfl⟩
    exact inter_subset_right
  · intro hC
    exact nfs_columns_free N m B C hC

/-- **Counting the patterns.**  For a fixed `N` the NFS family attains exactly `2 ^ |S|`
column patterns on the coprime factor base `S`. -/
theorem ncard_attainable_nfs_patterns (N m : ℤ) (B : ℕ) :
    {C : Finset ℕ | ∃ d : ℤ, N ∣ m ^ 2 - d ∧ nfsColumns d B ∩ coprimeBase N B = C}.ncard =
      2 ^ (coprimeBase N B).card := by
  rw [attainable_nfs_patterns, Set.ncard_coe_finset, card_powerset]

/-- **The QS is the one point the attacker does not choose.**  The QS column pattern is the
pattern of the member `d = N`, `m = 0` of the valid NFS family; and, unlike the NFS family, it
is pinned by `N`: any two moduli agreeing modulo every factor-base prime have the same QS
columns. -/
theorem qs_is_one_point (N : ℤ) (B : ℕ) :
    qsColumns N B ∩ coprimeBase N B ∈
      {C : Finset ℕ | ∃ d : ℤ, N ∣ 0 ^ 2 - d ∧ nfsColumns d B ∩ coprimeBase N B = C} ∧
    ∀ N' : ℤ, (∀ r ∈ oddFactorBase B, (r : ℤ) ∣ N' - N) → qsColumns N' B = qsColumns N B :=
  ⟨⟨N, by simp, rfl⟩, fun _ h => (qsColumns_congr h).symm⟩

/-! ## Yield cancellation: choosing the field redistributes, never creates, ideal columns -/

/-- **Ideal-sieve yield cancellation.**  Summed over a full period of fields `d = 0, …, r−1`,
the number of degree-one primes of `ℤ[√d]` above an odd prime `r` is exactly `r`: on average one
per field.  Choosing `d` moves split primes around (`nfs_columns_free`) but cannot raise the
average count — the NFS analogue of the QS relation-pool cancellation. -/
theorem sum_card_ringHom_zsqrtd {r : ℕ} [Fact r.Prime] (hr2 : r ≠ 2) :
    ∑ d ∈ range r, (Nat.card (ℤ√(d : ℤ) →+* ZMod r) : ℤ) = r := by
  have hrc : ringChar (ZMod r) ≠ 2 := by rwa [ZMod.ringChar_zmod_n]
  have hsum : ∑ i ∈ range r, quadraticChar (ZMod r) (i : ZMod r) =
      ∑ x : ZMod r, quadraticChar (ZMod r) x := by
    refine Finset.sum_nbij' (fun i => (i : ZMod r)) (fun x => x.val) ?_ ?_ ?_ ?_ ?_
    · intro i _; simp
    · intro x _; simp [ZMod.val_lt]
    · intro i hi; simp [ZMod.val_natCast, Nat.mod_eq_of_lt (Finset.mem_range.1 hi)]
    · intro x _; simp
    · intro i _; rfl
  have hterm : ∀ d ∈ range r, (Nat.card (ℤ√(d : ℤ) →+* ZMod r) : ℤ) =
      quadraticChar (ZMod r) (d : ZMod r) + 1 := by
    intro d _
    rw [card_ringHom_zsqrtd hr2, legendreSym]
    push_cast
    rfl
  rw [sum_congr rfl hterm, sum_add_distrib, hsum, quadraticChar_sum_zero hrc]
  simp

/-! ## Where the coupling to `N` goes: the hidden primes of `N` -/

/-- **Residual coupling (critic's boundary).**  Validity of the field does tie `d` to `N` — but
only at the prime factors of `N` itself: if `N ∣ m² − d`, then every prime `p ∣ N` with
`p ∤ d` *splits* `d`.  The factor-base primes (coprime to `N`) carry no such constraint
(`nfs_columns_free`). -/
theorem valid_field_splits_at_factors {N m d : ℤ} {p : ℕ} (hp : p.Prime)
    (hval : N ∣ m ^ 2 - d) (hpN : (p : ℤ) ∣ N) (hpd : ¬ (p : ℤ) ∣ d) : Splits d p := by
  rw [splits_iff_isSquare hp]
  refine ⟨by rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd], ?_⟩
  exact (exists_int_dvd_iff_isSquare hp.pos).1 ⟨m, hpN.trans hval⟩

/-- For a prime modulus `p ∤ d`, a root `m` of `x² − d` modulo `p` exists iff `p` splits `d`:
the residual coupling is exactly a Legendre condition at the hidden prime. -/
theorem valid_field_iff_splits_prime {d : ℤ} {p : ℕ} (hp : p.Prime) (hpd : ¬ (p : ℤ) ∣ d) :
    (∃ m : ℤ, (p : ℤ) ∣ m ^ 2 - d) ↔ Splits d p := by
  rw [splits_iff_isSquare hp, exists_int_dvd_iff_isSquare hp.pos]
  constructor
  · intro h
    exact ⟨by rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd], h⟩
  · exact fun h => h.2

/-! ## Lab data (kernel-checked finite computations, `B = 200`) -/

/-- **Lab: one field, two moduli.**  The field `d = −7` is valid for both `N = 11`
(`2² + 7 = 11`) and `N = 23` (`4² + 7 = 23`); its NFS column set (21 odd primes) is the same
object for both, while the QS column sets of `11` and `23` differ (20 vs 19 primes). -/
theorem lab_one_field_two_moduli :
    (11 : ℤ) ∣ 2 ^ 2 - (-7) ∧ (23 : ℤ) ∣ 4 ^ 2 - (-7) ∧
    (nfsColumns (-7) 200).card = 21 ∧
    (qsColumns 11 200).card = 20 ∧ (qsColumns 23 200).card = 19 ∧
    qsColumns 11 200 ≠ qsColumns 23 200 := by
  refine ⟨by norm_num, by norm_num, ?_, ?_, ?_, ?_⟩ <;> decide +kernel

/-- **Lab: the brief's QS spread.**  `qsColumns 15 200` has 21 primes, `qsColumns 47 200`
has 25. -/
theorem lab_qs_spread : (qsColumns 15 200).card = 21 ∧ (qsColumns 47 200).card = 25 := by
  constructor <;> decide +kernel

end Logic.NFSFieldColumns