import Computation.CyclicTypeDeterminism

/-!
# Reproducibility by construction: relabeling invariance of the type-channel record

An audit that re-runs a pipeline and lands on the recorded number is evidence, not proof.  The
stronger statement — *reproducible by construction* — is that the recorded numbers do not depend
on the arbitrary choices made when the pipeline was set up.  For the cyclic splitting-type channel
of `Catalog.Computation.CyclicTypeChannel` there is exactly one such choice: the identification of
the Galois group `Gal(ℚ(ζ_f)/ℚ)` with `ℤ/n`, i.e. the choice of a generator.  Changing the
generator multiplies every residue by a unit `u` of `ℤ/n`.

This file proves that the entire record is invariant under such a change, in two stages.

## Stage 1: any relabeling of the sample space (`Section 1`)

For an arbitrary readout `t : Fin n → ℕ` and an arbitrary permutation `e` of the sample space:

* `CyclicType.Audit.countsOf_comp_perm` : the occupation-number list of `t ∘ e` is a permutation
  of that of `t` — the histogram is invariant up to the order of the bins;
* `CyclicType.Audit.countsOf_sum` : occupation numbers always sum to `n`, so they really do define
  a probability distribution;
* `CyclicType.Audit.entropyOf_comp_perm` : the entropy of the readout is *equal*, not merely
  close, after relabeling.

## Stage 2: the unit action on `ℤ/n` (`Section 2`)

* `CyclicType.Audit.typNat_unit_mul` : `T(u·a) = T(a)` for every unit `u` — the splitting type is
  a class function for the unit action, because `gcd(n, u·a) = gcd(n, a)`;
* `CyclicType.Audit.typ_unitPerm` : the same statement for the induced permutation `unitPerm`;
* `CyclicType.Audit.typeCounts_generator_independent`,
  `CyclicType.Audit.HT_generator_independent` : the type histogram and `H(T)` are literally
  unchanged by a change of generator;
* `CyclicType.Audit.keyOf_unitPerm` : the semiprime type pair is unchanged as well, so the pair
  channel sees the same key list;
* `CyclicType.Audit.HpairGivenN_row_relabel` : the conditional table's rows are permuted by any
  relabeling of the norm classes, and the averaged conditional entropy — hence `Ipair` — is
  unchanged.

Consequently every headline number in the type-channel record is a Galois-invariant of the field,
not an artefact of the coordinates: a re-run that picks a different generator reproduces the
record exactly.
-/

namespace CyclicType.Audit

open List

/-! ## 1. Relabeling invariance of an arbitrary finite readout -/

/-- The distinct output values of a readout `t` on `Fin n`. -/
def valueList (n : ℕ) (t : Fin n → ℕ) : List ℕ := ((List.finRange n).map t).dedup

/-- Occupation numbers of a readout `t`, one per distinct output value. -/
def countsOf (n : ℕ) (t : Fin n → ℕ) : List ℕ :=
  (valueList n t).map (fun d => ((List.finRange n).filter (fun x => t x = d)).length)

/-- Shannon entropy of a readout, computed from its occupation numbers. -/
noncomputable def entropyOf (n : ℕ) (t : Fin n → ℕ) : ℝ := Hlist n (countsOf n t)

lemma typeCounts_eq_countsOf (n : ℕ) : typeCounts n = countsOf n (typ n) := rfl

lemma HT_eq_entropyOf (n : ℕ) : HT n = entropyOf n (typ n) := rfl

/-- Counting a fibre of the readout is the same as counting the value in the output list. -/
lemma count_eq_filter_length (n : ℕ) (t : Fin n → ℕ) (d : ℕ) :
    ((List.finRange n).map t).count d = ((List.finRange n).filter (fun x => t x = d)).length := by
  rw [List.count, List.countP_map, ← List.countP_eq_length_filter]
  apply List.countP_congr
  intro x _
  simp

/-- **The occupation numbers are a genuine distribution**: they sum to the size of the sample
space. -/
theorem countsOf_sum (n : ℕ) (t : Fin n → ℕ) : (countsOf n t).sum = n := by
  have h : countsOf n t
      = ((List.finRange n).map t).dedup.map (fun d => ((List.finRange n).map t).count d) := by
    rw [countsOf, valueList]
    exact List.map_congr_left (fun d _ => (count_eq_filter_length n t d).symm)
  rw [h, List.sum_map_count_dedup_eq_length]
  simp

/-- Relabeling the sample space does not change how many points a fibre contains. -/
lemma filter_length_comp (n : ℕ) (e : Equiv.Perm (Fin n)) (p : Fin n → Bool) :
    ((List.finRange n).filter (fun x => p (e x))).length
      = ((List.finRange n).filter p).length := by
  rw [← List.countP_eq_length_filter, ← List.countP_eq_length_filter]
  have h : countP p ((List.finRange n).map e) = countP (fun x => p (e x)) (List.finRange n) :=
    List.countP_map ..
  rw [← h]
  exact (e.map_finRange_perm).countP_eq p

/-- Relabeling permutes the list of realised output values. -/
lemma valueList_comp_perm (n : ℕ) (t : Fin n → ℕ) (e : Equiv.Perm (Fin n)) :
    valueList n (t ∘ e) ~ valueList n t := by
  have h : (List.finRange n).map (t ∘ e) ~ (List.finRange n).map t := by
    rw [← List.map_map]
    exact (e.map_finRange_perm).map t
  exact h.dedup

/-- **Histogram invariance.**  Relabeling the sample space permutes the bins of the histogram but
changes no occupation number. -/
theorem countsOf_comp_perm (n : ℕ) (t : Fin n → ℕ) (e : Equiv.Perm (Fin n)) :
    countsOf n (t ∘ e) ~ countsOf n t := by
  have h2 : (fun d => ((List.finRange n).filter (fun x => (t ∘ e) x = d)).length)
      = (fun d => ((List.finRange n).filter (fun x => t x = d)).length) := by
    funext d
    exact filter_length_comp n e (fun x => decide (t x = d))
  rw [countsOf, h2]
  exact (valueList_comp_perm n t e).map _

/-- Entropy only depends on the multiset of occupation numbers. -/
theorem Hlist_of_perm {tot : ℕ} {cs ds : List ℕ} (h : cs ~ ds) : Hlist tot cs = Hlist tot ds := by
  unfold Hlist
  rw [(h.map _).sum_eq]

/-- **Entropy invariance.**  The entropy of a readout is unchanged by any relabeling of the
sample space. -/
theorem entropyOf_comp_perm (n : ℕ) (t : Fin n → ℕ) (e : Equiv.Perm (Fin n)) :
    entropyOf n (t ∘ e) = entropyOf n t :=
  Hlist_of_perm (countsOf_comp_perm n t e)

/-! ## 2. The unit action: changing the generator of the cyclic group -/

/-- **The splitting type is a class function for the unit action.**  Multiplying a residue by a
unit `u` of `ℤ/n` does not change its type, because `gcd(n, u·a) = gcd(n, a)`. -/
theorem typNat_unit_mul {n u a : ℕ} (hu : Nat.Coprime u n) : typNat n (u * a) = typNat n a := by
  unfold typNat
  rw [Nat.Coprime.gcd_mul_left_cancel_right a hu]

/-- Multiplication by a unit is injective on `Fin n`. -/
lemma unitMul_injective {n u : ℕ} (hn : 0 < n) (hu : Nat.Coprime u n) :
    Function.Injective (fun x : Fin n => (⟨(u * x.val) % n, Nat.mod_lt _ hn⟩ : Fin n)) := by
  intro x y hxy
  have h : u * x.val ≡ u * y.val [MOD n] := by
    simpa [Nat.ModEq, Fin.ext_iff] using congrArg Fin.val hxy
  have h2 : x.val ≡ y.val [MOD n] :=
    Nat.ModEq.cancel_left_of_coprime (by simpa [Nat.Coprime, Nat.gcd_comm] using hu) h
  unfold Nat.ModEq at h2
  rw [Nat.mod_eq_of_lt x.isLt, Nat.mod_eq_of_lt y.isLt] at h2
  exact Fin.ext h2

/-- The change-of-generator permutation of `ℤ/n` attached to a unit `u`. -/
noncomputable def unitPerm (n u : ℕ) (hn : 0 < n) (hu : Nat.Coprime u n) : Equiv.Perm (Fin n) :=
  Equiv.ofBijective _ (Finite.injective_iff_bijective.mp (unitMul_injective hn hu))

lemma unitPerm_val {n u : ℕ} (hn : 0 < n) (hu : Nat.Coprime u n) (x : Fin n) :
    (unitPerm n u hn hu x).val = (u * x.val) % n := rfl

/-- **Generator independence, pointwise.**  The type of a residue is unchanged by the change of
generator. -/
theorem typ_unitPerm {n u : ℕ} (hn : 0 < n) (hu : Nat.Coprime u n) (x : Fin n) :
    typ n (unitPerm n u hn hu x) = typ n x := by
  have h1 : typ n (unitPerm n u hn hu x) = typNat n ((u * x.val) % n) := rfl
  rw [h1, typ_congr (Nat.mod_modEq (u * x.val) n), typNat_unit_mul hu]
  rfl

/-- **Generator independence of the type histogram.** -/
theorem typeCounts_generator_independent {n u : ℕ} (hn : 0 < n) (hu : Nat.Coprime u n) :
    countsOf n (typ n ∘ unitPerm n u hn hu) = typeCounts n := by
  have : (typ n ∘ unitPerm n u hn hu) = typ n := funext (typ_unitPerm hn hu)
  rw [this, typeCounts_eq_countsOf]

/-- **Generator independence of the type entropy `H(T)`.** -/
theorem HT_generator_independent {n u : ℕ} (hn : 0 < n) (hu : Nat.Coprime u n) :
    entropyOf n (typ n ∘ unitPerm n u hn hu) = HT n := by
  have : (typ n ∘ unitPerm n u hn hu) = typ n := funext (typ_unitPerm hn hu)
  rw [this, HT_eq_entropyOf]

/-- **Generator independence of the semiprime observable.**  The unordered type pair of a
semiprime is unchanged by the change of generator. -/
theorem keyOf_unitPerm {n u : ℕ} (hn : 0 < n) (hu : Nat.Coprime u n) (w : Fin n × Fin n) :
    keyOf n (unitPerm n u hn hu w.1, unitPerm n u hn hu w.2) = keyOf n w := by
  simp [keyOf, typ_unitPerm hn hu]

/-- Summing a real-valued quantity over the sample space is relabeling-invariant. -/
lemma sum_map_comp_perm (n : ℕ) (g : Fin n → ℝ) (e : Equiv.Perm (Fin n)) :
    (((List.finRange n).map (fun c => g (e c))).sum) = (((List.finRange n).map g).sum) := by
  have h : (List.finRange n).map (fun c => g (e c)) = ((List.finRange n).map e).map g := by
    rw [List.map_map]
    rfl
  rw [h]
  exact ((e.map_finRange_perm).map g).sum_eq

/-- **Relabeling the norm classes permutes the rows of the conditional table** and leaves the
averaged conditional entropy — hence the channel capacity `Ipair` — unchanged. -/
theorem HpairGivenN_row_relabel (n : ℕ) (e : Equiv.Perm (Fin n)) :
    HpairGivenN n
      = (1 / (n : ℝ)) * (((List.finRange n).map (fun c => Hlist n (condCounts n (e c)))).sum) := by
  rw [HpairGivenN, condTable, List.map_map]
  rw [sum_map_comp_perm n (fun c => Hlist n (condCounts n c)) e]
  rfl

/-- **The audit verdict, structurally.**  For every change of generator the recorded type
histogram, the recorded type entropy and the recorded semiprime observable are reproduced
exactly. -/
theorem record_generator_invariant {n u : ℕ} (hn : 0 < n) (hu : Nat.Coprime u n) :
    countsOf n (typ n ∘ unitPerm n u hn hu) = typeCounts n
      ∧ entropyOf n (typ n ∘ unitPerm n u hn hu) = HT n
      ∧ ∀ w : Fin n × Fin n,
          keyOf n (unitPerm n u hn hu w.1, unitPerm n u hn hu w.2) = keyOf n w :=
  ⟨typeCounts_generator_independent hn hu, HT_generator_independent hn hu,
    keyOf_unitPerm hn hu⟩

end CyclicType.Audit