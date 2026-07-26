import Mathlib

/-!
# Chromatic Darkness: Partition Duality and Extremal Structure

We develop the **chromatic theory of dark witness families** — a framework connecting
dark witness families to partition structures through "rejection sets."

## Key Insight

Every dark witness family has a **dual rejection perspective**: the rejection sets
must cover all candidates, and the *balance* of this covering determines extremal behavior.

## Novel Definitions

* `DarkFamily` — Dark witness family over `Fin m` worlds with candidates from `Fin N`.
* `rejection` — Rejection set of a world: candidates it does NOT accept.
* `spectrum` / `antiSpectrum` — Worlds accepting/rejecting each candidate.
* `defect` — Number of worlds rejecting each candidate (≥ 1 always).
* `IsBalanced` — Every candidate rejected by exactly one world.

## Main Results

* `rejection_covers` — Rejection sets cover all candidates.
* `spectrum_plus_defect` — Spectrum and defect are complementary.
* `double_count_identity` — Duality identity.
* `total_rejection_ge_N` — Total rejection ≥ N.
* `balanced_iff_partition` — Balanced families ↔ partition structure.
* `balanced_total_rejection` — Balanced families have total defect = N.
* `darkness_level_bound` — Level × m ≤ N × (m - 1).
* `witness_intersection_bound` — Overlap bound for balanced equitable families.
-/

namespace ChromaticDarkness

open Finset Fintype

/-! ### Core Structure -/

/-- A `DarkFamily m N` is a dark witness family with `m` worlds and candidates from `Fin N`. -/
structure DarkFamily (m N : ℕ) where
  witnesses : Fin m → Finset (Fin N)
  level : ℕ
  level_pos : 0 < level
  has_enough : ∀ a : Fin m, level ≤ (witnesses a).card
  no_universal : ∀ n : Fin N, ∃ a : Fin m, n ∉ witnesses a

variable {m N : ℕ}

/-! ### Rejection Perspective -/

/-- The **rejection set** of world `a`: candidates that world `a` does NOT accept. -/
def rejection (D : DarkFamily m N) (a : Fin m) : Finset (Fin N) :=
  Finset.univ \ D.witnesses a

/-- The **spectrum** of candidate `n`: worlds that accept `n` as a witness. -/
def spectrum (D : DarkFamily m N) (n : Fin N) : Finset (Fin m) :=
  Finset.univ.filter (fun a => n ∈ D.witnesses a)

/-- The **anti-spectrum** of candidate `n`: worlds that reject `n`. -/
def antiSpectrum (D : DarkFamily m N) (n : Fin N) : Finset (Fin m) :=
  Finset.univ.filter (fun a => n ∉ D.witnesses a)

/-- The **defect** of candidate `n`: the number of worlds that reject it. -/
def defect (D : DarkFamily m N) (n : Fin N) : ℕ :=
  (antiSpectrum D n).card

/-! ### Basic Lemmas -/

theorem mem_rejection_iff (D : DarkFamily m N) (a : Fin m) (n : Fin N) :
    n ∈ rejection D a ↔ n ∉ D.witnesses a := by
  simp [rejection, Finset.mem_sdiff]

theorem mem_spectrum_iff (D : DarkFamily m N) (n : Fin N) (a : Fin m) :
    a ∈ spectrum D n ↔ n ∈ D.witnesses a := by
  simp [spectrum]

theorem mem_antiSpectrum_iff (D : DarkFamily m N) (n : Fin N) (a : Fin m) :
    a ∈ antiSpectrum D n ↔ n ∉ D.witnesses a := by
  simp [antiSpectrum]

/-! ### Theorem 1: Rejection Cover -/

/-- Every candidate is rejected by at least one world. -/
theorem rejection_covers (D : DarkFamily m N) (n : Fin N) :
    ∃ a : Fin m, n ∈ rejection D a := by
  obtain ⟨a, ha⟩ := D.no_universal n
  exact ⟨a, (mem_rejection_iff D a n).mpr ha⟩

/-! ### Theorem 2: Spectrum-Defect Complement -/

theorem antiSpectrum_eq_compl (D : DarkFamily m N) (n : Fin N) :
    antiSpectrum D n = Finset.univ \ spectrum D n := by
  ext a; simp [antiSpectrum, spectrum]

/-
Spectrum size and defect sum to the total number of worlds.
-/
theorem spectrum_plus_defect (D : DarkFamily m N) (n : Fin N) :
    (spectrum D n).card + defect D n = m := by
  simp +arith +decide [ spectrum, defect, antiSpectrum ];
  convert Finset.card_add_card_compl ( Finset.filter ( fun a => n ∈ D.witnesses a ) Finset.univ ) using 1 ; simp +decide [ Finset.filter_not, Finset.card_sdiff ];
  · ring;
  · norm_num

/-- Every candidate has positive defect. -/
theorem defect_pos (D : DarkFamily m N) (n : Fin N) :
    0 < defect D n := by
  unfold defect antiSpectrum
  rw [Finset.card_pos]
  obtain ⟨a, ha⟩ := D.no_universal n
  exact ⟨a, Finset.mem_filter.mpr ⟨Finset.mem_univ a, ha⟩⟩

/-
Each candidate's spectrum is strictly smaller than the total number of worlds.
-/
theorem spectrum_card_lt (D : DarkFamily m N) (n : Fin N) :
    (spectrum D n).card < m := by
  -- From spectrum_plus_defect and defect_pos, we get (spectrum D n).card + defect D n = m with defect > 0, hence spectrum < m.
  have h_spectrum_lt : (spectrum D n).card + defect D n = m ∧ 0 < defect D n := by
    exact ⟨ spectrum_plus_defect D n, defect_pos D n ⟩;
  linarith

/-! ### Rejection Size -/

/-- Rejection set size equals N minus the witness set size. -/
theorem rejection_card (D : DarkFamily m N) (a : Fin m) :
    (rejection D a).card = N - (D.witnesses a).card := by
  simp [rejection, Finset.card_sdiff]

/-- Rejection set size is bounded above by N - level. -/
theorem rejection_card_le (D : DarkFamily m N) (a : Fin m) :
    (rejection D a).card ≤ N - D.level := by
  rw [rejection_card]
  exact Nat.sub_le_sub_left (D.has_enough a) N

/-! ### Theorem 3: Double Counting Identity -/

/-
**Double Counting Identity**: Total rejections by world = total defects by candidate.

Both sides count the same set of (world, candidate) pairs where the world rejects
the candidate. This is the fundamental duality of chromatic darkness theory.
-/
theorem double_count_identity (D : DarkFamily m N) :
    ∑ a : Fin m, (rejection D a).card = ∑ n : Fin N, defect D n := by
  unfold rejection defect;
  simp +decide only [card_univ, inter_univ, antiSpectrum];
  simp +decide only [card_filter];
  rw [ Finset.sum_comm ];
  simp +decide [ Finset.sum_ite, Finset.filter_not ]

/-! ### Theorem 4: Total Rejection Bound -/

/-
**Total Rejection Lower Bound**: The sum of all defects is at least N.
Since every candidate must be rejected by at least one world, total rejections ≥ N.
-/
theorem total_rejection_ge_N (D : DarkFamily m N) :
    N ≤ ∑ n : Fin N, defect D n := by
  exact le_trans ( by norm_num ) ( Finset.sum_le_sum fun _ _ => Nat.succ_le_of_lt ( defect_pos D _ ) )

/-! ### Balanced Dark Families -/

/-- A dark family is **balanced** if every candidate is rejected by exactly one world. -/
def IsBalanced (D : DarkFamily m N) : Prop :=
  ∀ n : Fin N, defect D n = 1

/-
In a balanced family, spectrum size is exactly m - 1.
-/
theorem balanced_spectrum_card (D : DarkFamily m N) (hb : IsBalanced D)
    (n : Fin N) (hm : 0 < m) :
    (spectrum D n).card = m - 1 := by
  exact eq_tsub_of_add_eq ( by have := spectrum_plus_defect D n; have := hb n; linarith )

/-! ### Theorem 5: Balanced Partition -/

/-
Balanced dark families' rejection sets form a partition: each candidate belongs
to exactly one rejection set.
-/
theorem balanced_iff_partition (D : DarkFamily m N) (hb : IsBalanced D) :
    ∀ n : Fin N, ∃! a : Fin m, n ∈ rejection D a := by
  intro n;
  have h_defect_one : (antiSpectrum D n).card = 1 := by
    exact hb n;
  obtain ⟨ a, ha ⟩ := Finset.card_eq_one.mp h_defect_one;
  simp_all +decide [ Finset.ext_iff, mem_rejection_iff, mem_antiSpectrum_iff ]

/-
In a balanced family, rejection sets are pairwise disjoint.
-/
theorem balanced_rejection_disjoint (D : DarkFamily m N) (hb : IsBalanced D)
    (a b : Fin m) (hab : a ≠ b) :
    Disjoint (rejection D a) (rejection D b) := by
  have := balanced_iff_partition D hb;
  exact Finset.disjoint_left.mpr fun x hx₁ hx₂ => hab <| ExistsUnique.unique ( this x ) hx₁ hx₂

/-! ### Theorem 6: Balanced Total Rejection -/

/-
Total defect in a balanced family is exactly N.
-/
theorem balanced_total_rejection (D : DarkFamily m N) (hb : IsBalanced D) :
    ∑ n : Fin N, defect D n = N := by
  rw [ Finset.sum_congr rfl fun n _ => hb n, Finset.sum_const, Finset.card_fin, smul_eq_mul, mul_one ]

/-! ### Theorem 7: Darkness Level Bound -/

/-
**Darkness Level Bound (Dark Inequality)**: level × m ≤ N × (m - 1).

The proof uses double counting: total rejections ≥ N (covering) and each world
has at most N - level rejections, so total ≤ m × (N - level). Combining:
N ≤ m × (N - level) = mN - m·level, hence m·level ≤ mN - N = N(m-1).
-/
theorem darkness_level_bound (D : DarkFamily m N) (hm : 0 < m)
    (hle : D.level ≤ N) :
    D.level * m ≤ N * (m - 1) := by
  rcases m with ( _ | _ | m ) <;> simp_all +decide;
  · have := D.no_universal;
    simp_all +decide [ Fin.eq_zero ];
    exact absurd ( D.has_enough 0 ) ( by rw [ Finset.card_eq_zero.mpr ( Finset.eq_empty_of_forall_notMem fun n hn => this n hn ) ] ; linarith [ D.level_pos ] );
  · have := double_count_identity D; have := total_rejection_ge_N D; simp_all +decide [ mul_comm ] ;
    have h_sum_rejections : ∑ a : Fin (m + 2), (rejection D a).card ≤ (m + 2) * (N - D.level) := by
      exact le_trans ( Finset.sum_le_sum fun _ _ => rejection_card_le D _ ) ( by simp +decide [ mul_comm ] );
    nlinarith [ Nat.sub_add_cancel hle ]

/-! ### Chromatic Equivalence -/

/-- Two candidates are **chromatically equivalent** if they share the same rejection pattern. -/
def chromaticallyEquivalent (D : DarkFamily m N) (n₁ n₂ : Fin N) : Prop :=
  antiSpectrum D n₁ = antiSpectrum D n₂

theorem chromaticallyEquivalent_equiv (D : DarkFamily m N) :
    Equivalence (chromaticallyEquivalent D) where
  refl := fun _ => rfl
  symm := fun h => h.symm
  trans := fun h₁ h₂ => h₁.trans h₂

/-! ### Theorem 8: Witness Intersection Bound -/

/-
For balanced equitable families, any two distinct worlds share at least
N - 2·(N/m) witnesses. Each world rejects N/m candidates, so two worlds
together reject at most 2·(N/m) candidates (by disjointness), leaving
at least N - 2·(N/m) common witnesses.
-/
theorem witness_intersection_bound (D : DarkFamily m N) (_hb : IsBalanced D)
    (_hm : 0 < m) (_hdvd : m ∣ N)
    (h_equitable : ∀ a : Fin m, (rejection D a).card = N / m)
    (a b : Fin m) (_hab : a ≠ b) :
    N - 2 * (N / m) ≤ (D.witnesses a ∩ D.witnesses b).card := by
  have h_union : (rejection D a ∪ rejection D b).card ≤ 2 * (N / m) := by
    exact le_trans ( Finset.card_union_le _ _ ) ( by linarith [ h_equitable a, h_equitable b ] );
  rw [ show D.witnesses a ∩ D.witnesses b = Finset.univ \ ( rejection D a ∪ rejection D b ) from ?_ ];
  · simp_all +decide [ Finset.card_sdiff ];
    omega;
  · ext n; simp [rejection]

end ChromaticDarkness