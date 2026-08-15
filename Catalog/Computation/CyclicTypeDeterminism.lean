import Computation.CyclicTypeChannelLaws

/-!
# Determinism and the general Euler-φ entropy law for the cyclic type channel

This file completes the analysis of `Catalog.Computation.CyclicTypeChannel` with two
statements that hold for *every* cyclic order `n`, not just the computed instances.

* `CyclicType.Ires_eq_HT` : the residue → type channel is **exact**.  The splitting type
  is a deterministic function of the residue, so the joint variable `(x, T(x))` carries
  exactly `log₂ n` bits and the mutual information `I(x ; T) = H(x) + H(T) - H(x,T)`
  collapses to `H(T)`.  This is the "`I(p mod f ; T) = H(T)` exactly" statement.

* `CyclicType.HT_divisor_formula` : the closed form
  `H(T) = log₂ n - (1/n) Σ_{d ∣ n} φ(d) log₂ φ(d)`,
  i.e. the type distribution is the Euler-φ law over the divisor lattice of `n`.

* `CyclicType.typ_thickening` : refining the observation modulus from `n` to `n^2`
  (or any multiple of `n`) adds nothing: the type is a function of the residue mod `n`.
-/

namespace CyclicType

open scoped BigOperators

/-! ## The joint (residue, type) variable -/

/-- The list of joint outcomes `(x, T(x))`. -/
def jointList (n : ℕ) : List (Fin n × ℕ) := (List.finRange n).map (fun x => (x, typ n x))

/-- Occupation numbers of the joint variable `(x, T(x))`. -/
def jointCounts (n : ℕ) : List ℕ :=
  (jointList n).dedup.map
    (fun q => ((List.finRange n).filter (fun x => (x, typ n x) = q)).length)

/-- Entropy of the uniform residue. -/
noncomputable def HX (n : ℕ) : ℝ := Hlist n (List.replicate n 1)

/-- Entropy of the joint variable `(residue, type)`. -/
noncomputable def HXT (n : ℕ) : ℝ := Hlist n (jointCounts n)

/-- Mutual information between the residue and its splitting type. -/
noncomputable def Ires (n : ℕ) : ℝ := HX n + HT n - HXT n

lemma jointList_nodup (n : ℕ) : (jointList n).Nodup := by
  have hinj : Function.Injective (fun x : Fin n => (x, typ n x)) := by
    intro a b h
    exact congrArg Prod.fst h
  exact (List.nodup_finRange n).map hinj

lemma filter_joint_length (n : ℕ) (a : Fin n) :
    ((List.finRange n).filter (fun x => (x, typ n x) = (a, typ n a))).length = 1 := by
  have hcongr : ∀ x ∈ List.finRange n,
      (decide ((x, typ n x) = (a, typ n a)) = true ↔ (x == a) = true) := by
    intro x _
    by_cases h : x = a
    · subst h; simp
    · simp [h, Prod.ext_iff]
  rw [← List.countP_eq_length_filter, List.countP_congr hcongr,
    ← List.count_eq_countP]
  exact List.count_eq_one_of_mem (List.nodup_finRange n) (List.mem_finRange a)

/-- The joint variable `(x, T(x))` is uniform on `n` outcomes: the type carries no
extra randomness beyond the residue. -/
theorem jointCounts_eq_replicate (n : ℕ) : jointCounts n = List.replicate n 1 := by
  rw [jointCounts, List.dedup_eq_self.mpr (jointList_nodup n), jointList, List.map_map]
  rw [List.eq_replicate_iff]
  constructor
  · simp
  · intro b hb
    simp only [List.mem_map, Function.comp_apply] at hb
    obtain ⟨a, _, rfl⟩ := hb
    exact filter_joint_length n a

lemma Hlist_replicate_one (n : ℕ) (hn : 0 < n) :
    Hlist n (List.replicate n 1) = Real.logb 2 n := by
  have hsum : (List.replicate n 1).sum = n := by simp
  rw [Hlist_eq_SL n _ hsum hn, SL]
  have : ((List.replicate n 1).map (fun c : ℕ => (c : ℝ) * Real.logb 2 c)).sum = 0 := by
    rw [List.map_replicate]
    simp
  rw [this]
  ring

theorem HX_eq (n : ℕ) (hn : 0 < n) : HX n = Real.logb 2 n :=
  Hlist_replicate_one n hn

theorem HXT_eq (n : ℕ) (hn : 0 < n) : HXT n = Real.logb 2 n := by
  rw [HXT, jointCounts_eq_replicate, Hlist_replicate_one n hn]

/-- **Exactness of the residue → type channel.**  Because the splitting type is a
deterministic function of the residue, the mutual information between the residue and the
type equals the full type entropy: `I(x ; T) = H(T)`. -/
theorem Ires_eq_HT (n : ℕ) (hn : 0 < n) : Ires n = HT n := by
  rw [Ires, HX_eq n hn, HXT_eq n hn]
  ring

/-- Thickening the modulus adds no information: the type mod `n` is unchanged by
observing the residue modulo any multiple `n * m` of `n`. -/
theorem typ_thickening (n m a : ℕ) : typNat n (a % (n * m)) = typNat n a := by
  refine typ_congr ?_
  rw [Nat.ModEq]
  conv_rhs => rw [← Nat.mod_mod_of_dvd a (Dvd.intro m rfl)]

/-! ## The Euler-φ closed form for the type entropy -/

lemma typeList_nodup (n : ℕ) : (typeList n).Nodup := List.nodup_dedup _

lemma mem_typeList_iff {n d : ℕ} (hn : 0 < n) : d ∈ typeList n ↔ d ∈ n.divisors := by
  rw [typeList, List.mem_dedup, List.mem_map, Nat.mem_divisors]
  constructor
  · rintro ⟨x, _, rfl⟩
    exact ⟨typNat_dvd n x.val, hn.ne'⟩
  · rintro ⟨hd, -⟩
    have hdpos : 0 < d := Nat.pos_of_dvd_of_pos hd hn
    refine ⟨⟨n / d % n, Nat.mod_lt _ hn⟩, List.mem_finRange _, ?_⟩
    show typ n ⟨n / d % n, _⟩ = d
    rw [typ_eq_typNat]
    have hmod : typNat n (n / d % n) = typNat n (n / d) :=
      typ_congr (by simp [Nat.ModEq])
    rw [hmod]
    exact (typNat_eq_iff hn hd).2 (Nat.gcd_eq_right (Nat.div_dvd_of_dvd hd))

lemma typeList_toFinset {n : ℕ} (hn : 0 < n) : (typeList n).toFinset = n.divisors := by
  ext d
  rw [List.mem_toFinset]
  exact mem_typeList_iff hn

/-- The occupation number of the type state `d` is `φ(d)`. -/
theorem typeCount_list_eq_totient {n d : ℕ} (hn : 0 < n) (hd : d ∣ n) :
    ((List.finRange n).filter (fun x => typ n x = d)).length = Nat.totient d := by
  rw [← typeCount_eq_totient hn hd, ← List.countP_eq_length_filter]
  have h1 : (List.finRange n).countP (fun x => decide (typ n x = d))
      = ((List.finRange n).map Fin.val).countP (fun k => decide (typNat n k = d)) := by
    rw [List.countP_map]
    rfl
  rw [h1, List.map_coe_finRange_eq_range]
  simp [List.countP_eq_length_filter, Finset.range, Finset.filter, Multiset.range,
    Multiset.filter_coe]

/-- **The Euler-φ entropy law.**  For every cyclic order `n`, the entropy of the splitting
type is `H(T) = log₂ n - (1/n) Σ_{d ∣ n} φ(d) log₂ φ(d)`. -/
theorem HT_divisor_formula {n : ℕ} (hn : 0 < n) :
    HT n = Real.logb 2 n
      - (1 / (n : ℝ)) * ∑ d ∈ n.divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d) := by
  have hcount : ∀ d ∈ typeList n,
      ((List.finRange n).filter (fun x => typ n x = d)).length = Nat.totient d := by
    intro d hd
    exact typeCount_list_eq_totient hn ((Nat.mem_divisors.1 ((mem_typeList_iff hn).1 hd)).1)
  have hTC : typeCounts n = (typeList n).map (fun d => Nat.totient d) := by
    rw [typeCounts]
    exact List.map_congr_left hcount
  have hsum : (typeCounts n).sum = n := by
    rw [hTC, ← List.sum_toFinset _ (typeList_nodup n), typeList_toFinset hn]
    exact Nat.sum_totient n
  rw [HT, Hlist_eq_SL n _ hsum hn, SL, hTC, List.map_map]
  congr 2
  rw [← List.sum_toFinset _ (typeList_nodup n), typeList_toFinset hn]
  rfl

/-- For a prime cyclic order `p` the type entropy collapses to the two-state form
`H(T) = log₂ p - ((p-1)/p) log₂ (p-1)`. -/
theorem HT_prime {p : ℕ} (hp : p.Prime) :
    HT p = Real.logb 2 p - ((p - 1 : ℕ) : ℝ) / p * Real.logb 2 ((p - 1 : ℕ) : ℝ) := by
  have hpos : 0 < p := hp.pos
  rw [HT_divisor_formula hpos, hp.divisors]
  rw [Finset.sum_pair (Ne.symm hp.ne_one)]
  simp only [Nat.totient_one, Nat.cast_one, Real.logb_one, mul_zero, zero_add,
    Nat.totient_prime hp]
  ring

/-! ## The general splits-completely pinning -/

/-- The binary root-count readout has occupation numbers `[1, n-1]`: exactly one residue
(the identity Frobenius) has type `1`. -/
lemma nrCounts_eq {n : ℕ} (hn : 0 < n) : nrCounts n = [1, n - 1] := by
  have h1 : ((List.finRange n).filter (fun x => typ n x = 1)).length = 1 := by
    rw [typeCount_list_eq_totient hn (one_dvd n), Nat.totient_one]
  have hsplit := List.length_eq_countP_add_countP
    (l := List.finRange n) (fun x => decide (typ n x = 1))
  rw [List.length_finRange] at hsplit
  rw [← List.countP_eq_length_filter] at h1
  have hneg : (List.finRange n).countP (fun a => decide ¬ decide (typ n a = 1) = true)
      = (List.finRange n).countP (fun x => decide (typ n x ≠ 1)) := by
    apply List.countP_congr; intro x _; simp
  rw [hneg] at hsplit
  have h2 : ((List.finRange n).filter (fun x => typ n x ≠ 1)).length = n - 1 := by
    rw [← List.countP_eq_length_filter]
    omega
  rw [nrCounts, ← List.countP_eq_length_filter, h1, h2]

/-- **The splits-completely pinning, general form.**  For every cyclic order `n` the
binary "splits completely or not" readout carries exactly the binary entropy of `1/n`:
`H(nr) = log₂ n - ((n-1)/n) log₂ (n-1)`.  For `n = 4` this is the quartic pinning
`2 - (3/4) log₂ 3`. -/
theorem Hnr_eq_binary_entropy {n : ℕ} (hn : 0 < n) :
    Hnr n = Real.logb 2 n - ((n - 1 : ℕ) : ℝ) / n * Real.logb 2 ((n - 1 : ℕ) : ℝ) := by
  have hsum : ([1, n - 1] : List ℕ).sum = n := by simp; omega
  rw [Hnr, nrCounts_eq hn, Hlist_eq_SL n _ hsum hn, SL]
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, Nat.cast_one,
    Real.logb_one, mul_zero, zero_add, add_zero]
  ring

/-- For a prime cyclic order the root-count readout is *not* lossy: the type channel is
itself binary, so `H(nr) = H(T)`.  Losslessness therefore fails exactly when `n` is
composite, which is the structural reason behind `Hnr_lt_HT_four` and `Hnr_lt_HT_six`. -/
theorem Hnr_eq_HT_of_prime {p : ℕ} (hp : p.Prime) : Hnr p = HT p := by
  rw [Hnr_eq_binary_entropy hp.pos, HT_prime hp]

end CyclicType