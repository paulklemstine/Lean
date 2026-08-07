import Mathlib

/-!
# Box-Counting Dimension of Theories of Binary Strings

This module supplies the infrastructure that
`Pythagorean.ProofSearchFractalDimension` imports: a *theory* of binary strings
records, at each depth `n`, the finite set of admissible words of length `n`
(encoded as functions `Fin n → Bool`).  Its normalized logarithmic growth rate

`dimEstimate S n = log₂ (#level n) / n`,  `boxDim S = limsup dimEstimate S`,

is the entropy (box-counting) dimension of the corresponding subset of the
binary tree.

## Main results

* `boxDim_le_one` — the ambient bound: no theory of binary strings has
  dimension above `1`.
* `densityTheory m R` — the *periodically pruned* theory that leaves both
  branches free exactly at the depths whose residue mod `m` lies in `R`.
* `freeCount_mul` — over a whole number of periods the number of free levels is
  exactly `#R * k`.
* `dimEstimate_densityTheory` — the finite-depth estimate of a periodic theory
  is the density of free levels seen so far.
* `boxDim_densityTheory` — its dimension is exactly `#R / m`.
* `rational_dimension_realized` — every rational number in `[0,1]` is the
  dimension of some theory.
-/

open Filter Finset

namespace TruthFractalDimensionDeepening

/-- A theory of binary strings: at each depth `n` it records the finite set of
admissible words of length `n`. -/
structure Theory where
  /-- The admissible words of each length. -/
  level : (n : ℕ) → Finset (Fin n → Bool)

/-- The number of admissible words of length `n`. -/
def Theory.count (S : Theory) (n : ℕ) : ℕ := (S.level n).card

theorem count_le_two_pow (S : Theory) (n : ℕ) : S.count n ≤ 2 ^ n := by
  have := Finset.card_le_univ (S.level n)
  simpa [Theory.count, Finset.card_univ] using this

/-- The finite-depth (Monte-Carlo) estimate of the dimension: the normalized
logarithmic count of admissible words at depth `n`. -/
noncomputable def dimEstimate (S : Theory) (n : ℕ) : ℝ :=
  Real.logb 2 (S.count n) / n

/-- The box-counting dimension of a theory. -/
noncomputable def boxDim (S : Theory) : ℝ := Filter.limsup (dimEstimate S) Filter.atTop

theorem dimEstimate_nonneg (S : Theory) (n : ℕ) : 0 ≤ dimEstimate S n := by
  unfold dimEstimate
  rcases Nat.eq_zero_or_pos (S.count n) with h | h
  · simp [h]
  · apply div_nonneg _ (Nat.cast_nonneg n)
    apply Real.logb_nonneg (by norm_num)
    exact_mod_cast h

theorem dimEstimate_le_one (S : Theory) (n : ℕ) : dimEstimate S n ≤ 1 := by
  unfold dimEstimate
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  · rw [div_le_one (by exact_mod_cast hn)]
    have h1 : (S.count n : ℝ) ≤ (2:ℝ) ^ n := by exact_mod_cast count_le_two_pow S n
    have hpow : Real.logb 2 ((2:ℝ)^n) = n := by
      rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num)]; ring
    have hlog : Real.logb 2 (S.count n) ≤ Real.logb 2 ((2:ℝ)^n) := by
      rcases Nat.eq_zero_or_pos (S.count n) with h | h
      · rw [h, hpow]
        simp only [Nat.cast_zero, Real.logb_zero]
        positivity
      · exact Real.logb_le_logb_of_le (by norm_num) (by exact_mod_cast h) h1
    exact hlog.trans_eq hpow

/-- **Ambient bound.** Every theory of binary strings has dimension at most `1`. -/
theorem boxDim_le_one (S : Theory) : boxDim S ≤ 1 := by
  apply Filter.limsup_le_of_le ?_ (Filter.Eventually.of_forall (dimEstimate_le_one S))
  exact ⟨0, fun a ha => by
    obtain ⟨n, hn⟩ := (Filter.eventually_map.1 ha).exists
    exact le_trans (dimEstimate_nonneg S n) hn⟩

/-! ## Counting words supported on a set of free positions -/

/-- The number of binary words of length `n` that vanish outside `s` is `2 ^ #s`. -/
theorem card_words_supported (n : ℕ) (s : Finset (Fin n)) :
    (Finset.univ.filter (fun f : Fin n → Bool => ∀ i, i ∉ s → f i = false)).card
      = 2 ^ s.card := by
  classical
  have h1 : (Finset.univ.filter (fun f : Fin n → Bool => ∀ i, i ∉ s → f i = false)).card
      = Fintype.card {f : Fin n → Bool // ∀ i, i ∉ s → f i = false} := by
    simp [Fintype.card_subtype]
  have e : {f : Fin n → Bool // ∀ i, i ∉ s → f i = false} ≃ (s → Bool) :=
    { toFun := fun f i => f.1 i.1
      invFun := fun g => ⟨fun i => if h : i ∈ s then g ⟨i, h⟩ else false, by
        intro i hi; simp [hi]⟩
      left_inv := by
        intro f
        ext i
        by_cases h : i ∈ s
        · simp [h]
        · simp [h, f.2 i h]
      right_inv := by
        intro g
        funext i
        simp }
  rw [h1, Fintype.card_congr e]
  simp

/-! ## Periodically pruned theories -/

/-- The number of *free* levels below `n`: those whose residue mod `m` lies in `R`. -/
def freeCount (m : ℕ) (R : Finset ℕ) (n : ℕ) : ℕ :=
  ((Finset.range n).filter (fun i => i % m ∈ R)).card

/-- The free positions among the first `n` levels. -/
def freeIdx (m : ℕ) (R : Finset ℕ) (n : ℕ) : Finset (Fin n) :=
  Finset.univ.filter (fun i : Fin n => i.val % m ∈ R)

theorem card_freeIdx (m : ℕ) (R : Finset ℕ) (n : ℕ) :
    (freeIdx m R n).card = freeCount m R n := by
  unfold freeIdx freeCount
  apply Finset.card_nbij (i := fun i : Fin n => i.val)
  · intro a ha
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at ha
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range]
    exact ⟨a.isLt, ha⟩
  · intro a _ b _ h; exact Fin.val_injective h
  · intro b hb
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at hb
    exact ⟨⟨b, hb.1⟩, by simpa using hb.2, rfl⟩

/-- The periodically pruned theory: at level `i` both branches are available
exactly when `i % m ∈ R`; otherwise the branch is forced. -/
def densityTheory (m : ℕ) (R : Finset ℕ) : Theory where
  level n := Finset.univ.filter
    (fun f : Fin n → Bool => ∀ i, i ∉ freeIdx m R n → f i = false)

theorem count_densityTheory (m : ℕ) (R : Finset ℕ) (n : ℕ) :
    (densityTheory m R).count n = 2 ^ freeCount m R n := by
  unfold Theory.count densityTheory
  simpa [card_freeIdx] using card_words_supported n (freeIdx m R n)

/-- The finite-depth estimate of a periodic theory is the density of free levels. -/
theorem dimEstimate_densityTheory (m : ℕ) (R : Finset ℕ) (n : ℕ) :
    dimEstimate (densityTheory m R) n = (freeCount m R n : ℝ) / (n : ℝ) := by
  unfold dimEstimate
  rw [count_densityTheory]
  congr 1
  rw [show ((2 ^ freeCount m R n : ℕ) : ℝ) = (2:ℝ) ^ freeCount m R n by push_cast; ring,
    Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
  ring

/-! ## Exact counts over whole periods -/

theorem card_block (m : ℕ) (R : Finset ℕ) (hR : R ⊆ Finset.range m) (k : ℕ) :
    ((Finset.Ico (m*k) (m*k+m)).filter (fun i => i % m ∈ R)).card = R.card := by
  have hmod : ∀ t : ℕ, t < m → (m * k + t) % m = t := by
    intro t ht
    rw [Nat.add_comm, Nat.add_mul_mod_self_left]
    exact Nat.mod_eq_of_lt ht
  refine Finset.card_bij' (fun a _ => a % m) (fun r _ => m * k + r) ?_ ?_ ?_ ?_
  · intro a ha
    simp only [Finset.mem_filter] at ha
    exact ha.2
  · intro r hr
    have hrm : r < m := Finset.mem_range.1 (hR hr)
    simp only [Finset.mem_filter, Finset.mem_Ico]
    exact ⟨⟨by omega, by omega⟩, by rw [hmod r hrm]; exact hr⟩
  · intro a ha
    simp only [Finset.mem_filter, Finset.mem_Ico] at ha
    obtain ⟨⟨h1, h2⟩, _⟩ := ha
    show m * k + a % m = a
    obtain ⟨t, rfl⟩ : ∃ t, a = m * k + t := ⟨a - m * k, by omega⟩
    rw [hmod t (by omega)]
  · intro r hr
    exact hmod r (Finset.mem_range.1 (hR hr))

/-- Over `k` whole periods the number of free levels is exactly `#R * k`. -/
theorem freeCount_mul (m : ℕ) (R : Finset ℕ) (hR : R ⊆ Finset.range m) (k : ℕ) :
    freeCount m R (m * k) = R.card * k := by
  induction k with
  | zero => simp [freeCount]
  | succ k ih =>
      have hsplit : Finset.range (m * (k+1))
          = Finset.range (m*k) ∪ Finset.Ico (m*k) (m*k+m) := by
        rw [Finset.range_eq_Ico, Finset.Ico_union_Ico_eq_Ico (by omega) (by omega)]
        congr 1
      have hdisj : Disjoint (Finset.range (m*k)) (Finset.Ico (m*k) (m*k+m)) := by
        rw [Finset.range_eq_Ico]
        exact Finset.Ico_disjoint_Ico_consecutive 0 (m*k) (m*k+m)
      unfold freeCount
      rw [hsplit, Finset.filter_union,
        Finset.card_union_of_disjoint
          (hdisj.mono (Finset.filter_subset _ _) (Finset.filter_subset _ _)),
        card_block m R hR k]
      unfold freeCount at ih
      rw [ih]
      ring

theorem freeCount_mono (m : ℕ) (R : Finset ℕ) {n n' : ℕ} (h : n ≤ n') :
    freeCount m R n ≤ freeCount m R n' := by
  unfold freeCount
  exact Finset.card_le_card (Finset.filter_subset_filter _ (Finset.range_subset_range.2 h))

theorem card_le_of_subset_range {m : ℕ} {R : Finset ℕ} (hR : R ⊆ Finset.range m) :
    R.card ≤ m := by
  simpa using Finset.card_le_card hR

/-! ## The dimension of a periodically pruned theory -/

theorem freeCount_sandwich (m : ℕ) (R : Finset ℕ) (hR : R ⊆ Finset.range m)
    (hm : 1 ≤ m) (n : ℕ) :
    R.card * (n / m) ≤ freeCount m R n ∧
      freeCount m R n ≤ R.card * (n / m) + R.card := by
  have hdm : m * (n / m) + n % m = n := Nat.div_add_mod n m
  have hmod : n % m < m := Nat.mod_lt _ (by omega)
  have h1 : m * (n / m) ≤ n := by omega
  have h3 : n ≤ m * (n / m + 1) := by
    have : m * (n / m + 1) = m * (n / m) + m := by ring
    omega
  constructor
  · calc R.card * (n / m) = freeCount m R (m * (n / m)) := (freeCount_mul m R hR _).symm
      _ ≤ freeCount m R n := freeCount_mono m R h1
  · calc freeCount m R n ≤ freeCount m R (m * (n / m + 1)) := freeCount_mono m R h3
      _ = R.card * (n / m + 1) := freeCount_mul m R hR _
      _ = R.card * (n / m) + R.card := by ring

theorem abs_freeCount_sub_density_le (m : ℕ) (R : Finset ℕ) (hR : R ⊆ Finset.range m)
    (hm : 1 ≤ m) (n : ℕ) (hn : 1 ≤ n) :
    |(freeCount m R n : ℝ) / n - (R.card : ℝ) / m| ≤ (m : ℝ) / n := by
  obtain ⟨hlow, hhigh⟩ := freeCount_sandwich m R hR hm n
  set k := n / m with hk
  set c := R.card with hc
  set F := freeCount m R n with hF
  have hcm : c ≤ m := card_le_of_subset_range hR
  have hdm : m * k + n % m = n := Nat.div_add_mod n m
  have hmod : n % m < m := Nat.mod_lt _ (by omega)
  have h1 : m * k ≤ n := by omega
  have h2 : n < m * k + m := by omega
  have hmR : (0:ℝ) < m := by exact_mod_cast hm
  have hnR : (0:ℝ) < n := by exact_mod_cast hn
  have hF1 : (c:ℝ) * k ≤ F := by exact_mod_cast hlow
  have hF2 : (F:ℝ) ≤ c * k + c := by exact_mod_cast hhigh
  have hn1 : (m:ℝ) * k ≤ n := by exact_mod_cast h1
  have hn2 : (n:ℝ) ≤ m * k + m := by exact_mod_cast Nat.le_of_lt_succ (by omega : n < m*k+m+1)
  have hcmR : (c:ℝ) ≤ m := by exact_mod_cast hcm
  have hc0 : (0:ℝ) ≤ c := Nat.cast_nonneg c
  have key : |(m : ℝ) * F - c * n| ≤ (m : ℝ) * m := by
    rw [abs_le]
    constructor <;> nlinarith
  have hrewrite : (F : ℝ) / n - (c : ℝ) / m = ((m : ℝ) * F - c * n) / (n * m) := by
    field_simp
  rw [hrewrite, abs_div, abs_of_pos (by positivity : (0:ℝ) < n * m),
    div_le_div_iff₀ (by positivity) hnR]
  nlinarith

/-- **The dimension of a periodically pruned theory is the density of its free
levels.** -/
theorem tendsto_dimEstimate_densityTheory (m : ℕ) (R : Finset ℕ)
    (hR : R ⊆ Finset.range m) (hm : 1 ≤ m) :
    Filter.Tendsto (dimEstimate (densityTheory m R)) Filter.atTop
      (nhds ((R.card : ℝ) / m)) := by
  have h0 : Filter.Tendsto
      (fun n : ℕ => (freeCount m R n : ℝ) / n - (R.card : ℝ) / m)
      Filter.atTop (nhds 0) := by
    apply squeeze_zero_norm' (a := fun n : ℕ => (m:ℝ)/n)
    · filter_upwards [Filter.eventually_ge_atTop 1] with n hn
      simpa using abs_freeCount_sub_density_le m R hR hm n hn
    · exact tendsto_const_div_atTop_nhds_zero_nat _
  have h1 := h0.add_const ((R.card : ℝ)/m)
  simp only [sub_add_cancel, zero_add] at h1
  refine h1.congr fun n => ?_
  rw [dimEstimate_densityTheory]

theorem boxDim_densityTheory (m : ℕ) (R : Finset ℕ) (hR : R ⊆ Finset.range m)
    (hm : 1 ≤ m) : boxDim (densityTheory m R) = (R.card : ℝ) / m :=
  (tendsto_dimEstimate_densityTheory m R hR hm).limsup_eq

/-- **Every rational dimension in `[0,1]` is realized** by a periodically pruned
theory. -/
theorem rational_dimension_realized (p q : ℕ) (hpq : p ≤ q) (hq : 1 ≤ q) :
    ∃ S : Theory, boxDim S = (p : ℝ) / q := by
  refine ⟨densityTheory q (Finset.range p), ?_⟩
  rw [boxDim_densityTheory q (Finset.range p) (Finset.range_subset_range.2 hpq) hq,
    Finset.card_range]

end TruthFractalDimensionDeepening