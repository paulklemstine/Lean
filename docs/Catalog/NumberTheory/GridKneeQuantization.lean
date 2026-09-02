/-
# Grid quantization of a knee: measurement is grid-rounding

NET-62 reports a *fine-grid* re-measurement of an attention-budget knee: on the coarse
sweep grid the knee at `ctx = 1024` read `32`, on the fine grid `{4, 8, 12, 20, 24}` it
reads `20`.  The claim attached to that datum ("the coarse reading was an artifact, the
knee lands exactly ON the fine grid") is, stripped of the machine learning, a purely
arithmetic statement about *sampling a monotone threshold on a subset of `ℕ`*.

This file isolates and proves that statement.

## Contents

* `GridKnee.Grid` — an unbounded set of admissible sweep points, and
  `GridKnee.read G k` — what a sweep restricted to `G` reports when the true threshold
  is `k`, namely the least grid point `≥ k`.
* `GridKnee.read` is a **closure operator**: inflationary (`le_read`), monotone
  (`read_mono`), idempotent (`read_read`), with fixed points exactly the grid
  (`read_eq_self_iff`), and *antitone in refinement* (`read_le_read_of_subset`).
* `GridKnee.measured_knee_eq_read` — **the measurement theorem**: for any monotone
  score `f` and gate `bar`, the knee measured by a sweep over `G` is exactly the
  `G`-rounding of the true knee.  So a grid reading is never wrong by accident: it is
  always the rounding, and it is exact iff the true knee lies on the grid.
* `GridKnee.read_dyadGrid` — on the dyadic (power-of-two) grid the reading is
  `2 ^ Nat.clog 2 k`, and `GridKnee.dyad_exact_iff_binary_weight_one` characterises
  exactness by the **base-two digit sum**: a dyadic sweep resolves `k` iff `k` has a
  single one bit.  `GridKnee.arith_exact_iff_dvd` /
  `GridKnee.arith_four_exact_iff_two_le_val` do the same for the step-`d` arithmetic
  grid, exactness there being a lower bound on the `2`-adic valuation when `d = 4`.
* `GridKnee.read_collapse` and `GridKnee.dyad_collapse_of_lt` — **why a coarse grid
  destroys a monotone chain**: two distinct true knees inside one grid gap are reported
  as equal, so strict monotonicity of a knee chain can only ever be *lost*, never
  created, by coarsening (`read_strictMono_reflect`).
* `GridKnee.attentionBudget_grid_reading` — the instantiation on the catalog's
  `AttentionBudget.retained` profile from `Catalog/Shared/AttentionBudgetKnee.lean`:
  a top-`k` sweep restricted to a grid reports `read G (kstar w n τ)`.
-/

import Mathlib
import Shared.AttentionBudgetKnee

namespace GridKnee

/-! ## 1.  Grids and the reading operator -/

/-- A **sweep grid**: an unbounded set of admissible measurement points. -/
structure Grid where
  /-- The set of points at which the experiment is actually run. -/
  carrier : Set ℕ
  /-- A sweep can always be pushed further out. -/
  unbounded : ∀ n : ℕ, ∃ m ∈ carrier, n ≤ m

namespace Grid

/-- The set of grid points that already clear the level `k`. -/
def above (G : Grid) (k : ℕ) : Set ℕ := {g | g ∈ G.carrier ∧ k ≤ g}

theorem above_nonempty (G : Grid) (k : ℕ) : (G.above k).Nonempty := by
  obtain ⟨m, hm, hkm⟩ := G.unbounded k
  exact ⟨m, hm, hkm⟩

end Grid

/-- **The grid reading of `k`**: the value a sweep restricted to `G` reports for a
threshold whose true location is `k`, i.e. the least grid point `≥ k`. -/
noncomputable def read (G : Grid) (k : ℕ) : ℕ := sInf (G.above k)

theorem read_mem (G : Grid) (k : ℕ) : read G k ∈ G.above k :=
  Nat.sInf_mem (G.above_nonempty k)

theorem read_mem_carrier (G : Grid) (k : ℕ) : read G k ∈ G.carrier := (read_mem G k).1

/-- The reading is **inflationary**: a sweep never reports a budget below the truth. -/
theorem le_read (G : Grid) (k : ℕ) : k ≤ read G k := (read_mem G k).2

theorem read_le_of_mem {G : Grid} {k g : ℕ} (hg : g ∈ G.carrier) (hkg : k ≤ g) :
    read G k ≤ g := Nat.sInf_le ⟨hg, hkg⟩

/-- Fixed points of the reading operator are exactly the grid points: *the reading is
exact iff the knee lands on the grid*. -/
theorem read_eq_self_iff {G : Grid} {k : ℕ} : read G k = k ↔ k ∈ G.carrier := by
  constructor
  · intro h; simpa [h] using read_mem_carrier G k
  · intro h; exact le_antisymm (read_le_of_mem h le_rfl) (le_read G k)

theorem read_mono (G : Grid) : Monotone (read G) := by
  intro a b hab
  exact read_le_of_mem (read_mem_carrier G b) (hab.trans (le_read G b))

/-- The reading operator is **idempotent**: re-reading a reported value changes nothing. -/
@[simp] theorem read_read (G : Grid) (k : ℕ) : read G (read G k) = read G k :=
  read_eq_self_iff.2 (read_mem_carrier G k)

/-- **Refinement never inflates.**  If `H ⊆ G` (i.e. `H` is the coarser sweep), every
`H`-reading is at least the `G`-reading. -/
theorem read_le_read_of_subset {G H : Grid} (hsub : H.carrier ⊆ G.carrier) (k : ℕ) :
    read G k ≤ read H k :=
  read_le_of_mem (hsub (read_mem_carrier H k)) (le_read H k)

/-- **Collapse.**  Two true knees inside one grid gap are reported identically: a coarse
sweep cannot separate them. -/
theorem read_collapse {G : Grid} {k k' : ℕ} (h1 : k ≤ k') (h2 : k' ≤ read G k) :
    read G k = read G k' :=
  le_antisymm ((read_mono G) h1) (read_le_of_mem (read_mem_carrier G k) h2)

/-- Consequently a strict increase *in the readings* is genuine: it can only come from a
strict increase of the underlying knees.  Coarsening loses resolution, it never invents
it. -/
theorem read_strictMono_reflect {G : Grid} {k k' : ℕ} (h : read G k < read G k') : k < k' := by
  by_contra hcon
  exact absurd ((read_mono G) (not_lt.1 hcon)) (not_le.2 h)

/-- **Rounding is the only consistent read-out.**  Any measurement map `M` that is
inflationary, monotone, idempotent, and whose fixed points are exactly the grid points,
*is* the grid-rounding operator.  No cleverer read-out of a grid sweep exists without
extra hypotheses on the profile. -/
theorem read_unique {G : Grid} {M : ℕ → ℕ} (hinf : ∀ k, k ≤ M k) (hmono : Monotone M)
    (hidem : ∀ k, M (M k) = M k) (hfix : ∀ k, M k = k ↔ k ∈ G.carrier) (k : ℕ) :
    M k = read G k := by
  have h1 : read G k ≤ M k := read_le_of_mem ((hfix (M k)).1 (hidem k)) (hinf k)
  have h2 : M k ≤ read G k := by
    have hfixed : M (read G k) = read G k := (hfix _).2 (read_mem_carrier G k)
    calc M k ≤ M (read G k) := hmono (le_read G k)
      _ = read G k := hfixed
  omega

/-! ## 2.  The measurement theorem -/

section Measurement

variable {α : Type*} [LinearOrder α]

/-- **Measurement theorem.**  Let `f` be a monotone score (retained mass as a function of
the budget) and `bar` a gate that is cleared somewhere.  Then the knee obtained by
sweeping only over the grid `G` is *exactly* the `G`-rounding of the true knee.

Two corollaries follow at once and are the content of the NET-62 verdict:
the reading is exact iff the true knee is a grid point (`read_eq_self_iff`), and a finer
grid can only lower the reading (`read_le_read_of_subset`). -/
theorem measured_knee_eq_read (G : Grid) {f : ℕ → α} (hf : Monotone f) {bar : α}
    (hne : ∃ k, bar ≤ f k) :
    sInf {g | g ∈ G.carrier ∧ bar ≤ f g} = read G (sInf {k | bar ≤ f k}) := by
  set K := sInf {k | bar ≤ f k} with hK
  have hne' : {k | bar ≤ f k}.Nonempty := hne
  have hKmem : bar ≤ f K := Nat.sInf_mem hne'
  have hset : {g | g ∈ G.carrier ∧ bar ≤ f g} = G.above K := by
    ext g
    constructor
    · rintro ⟨hg, hbar⟩
      exact ⟨hg, Nat.sInf_le hbar⟩
    · rintro ⟨hg, hKg⟩
      exact ⟨hg, hKmem.trans (hf hKg)⟩
  rw [hset, read]

/-- The sweep reading is exact precisely when the true knee lies on the sweep grid. -/
theorem measured_knee_exact_iff (G : Grid) {f : ℕ → α} (hf : Monotone f) {bar : α}
    (hne : ∃ k, bar ≤ f k) :
    sInf {g | g ∈ G.carrier ∧ bar ≤ f g} = sInf {k | bar ≤ f k} ↔
      sInf {k | bar ≤ f k} ∈ G.carrier := by
  rw [measured_knee_eq_read G hf hne, read_eq_self_iff]

/-- A finer sweep never reports a larger knee. -/
theorem measured_knee_mono_refine {G H : Grid} (hsub : H.carrier ⊆ G.carrier) {f : ℕ → α}
    (hf : Monotone f) {bar : α} (hne : ∃ k, bar ≤ f k) :
    sInf {g | g ∈ G.carrier ∧ bar ≤ f g} ≤ sInf {g | g ∈ H.carrier ∧ bar ≤ f g} := by
  rw [measured_knee_eq_read G hf hne, measured_knee_eq_read H hf hne]
  exact read_le_read_of_subset hsub _

end Measurement

/-! ## 3.  The two grids of the experiment -/

/-- The **arithmetic grid** of step `d`: all multiples of `d`.  The NET-62 fine grid is
`arithGrid 4`. -/
def arithGrid (d : ℕ) (hd : 0 < d) : Grid where
  carrier := {n | d ∣ n}
  unbounded n := ⟨d * n, ⟨n, rfl⟩, Nat.le_mul_of_pos_left n hd⟩

/-- The **dyadic grid**: powers of two, the coarse doubling sweep `4, 8, 16, 32, …`. -/
def dyadGrid : Grid where
  carrier := {n | ∃ e : ℕ, n = 2 ^ e}
  unbounded n := ⟨2 ^ n, ⟨n, rfl⟩, Nat.le_of_lt (Nat.lt_two_pow_self)⟩

@[simp] theorem mem_arithGrid {d : ℕ} {hd : 0 < d} {n : ℕ} :
    n ∈ (arithGrid d hd).carrier ↔ d ∣ n := Iff.rfl

@[simp] theorem mem_dyadGrid {n : ℕ} : n ∈ dyadGrid.carrier ↔ ∃ e : ℕ, n = 2 ^ e := Iff.rfl

/-- On the arithmetic grid the reading is exact iff the step divides the knee. -/
theorem arith_exact_iff_dvd {d : ℕ} (hd : 0 < d) (k : ℕ) :
    read (arithGrid d hd) k = k ↔ d ∣ k := read_eq_self_iff

/-- For the fine grid of step `4`, exactness is a statement about the `2`-adic valuation:
the sweep resolves `k` iff `4 ∣ k`, i.e. iff `k` has at least two trailing zero bits. -/
theorem arith_four_exact_iff_two_le_val {k : ℕ} (hk : k ≠ 0) :
    read (arithGrid 4 (by norm_num)) k = k ↔ 2 ≤ k.factorization 2 := by
  rw [arith_exact_iff_dvd]
  constructor
  · intro h
    have : (2:ℕ) ^ 2 ∣ k := by simpa using h
    exact (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hk).1 this
  · intro h
    have : (2:ℕ) ^ 2 ∣ k := (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hk).2 h
    simpa using this

/-- **The dyadic reading is `2 ^ ⌈log₂ k⌉`.** -/
theorem read_dyadGrid (k : ℕ) : read dyadGrid k = 2 ^ Nat.clog 2 k := by
  refine le_antisymm (read_le_of_mem ⟨Nat.clog 2 k, rfl⟩ (Nat.le_pow_clog (by norm_num) k)) ?_
  obtain ⟨e, he⟩ := read_mem_carrier dyadGrid k
  have hle : k ≤ 2 ^ e := he ▸ le_read dyadGrid k
  have : Nat.clog 2 k ≤ e := (Nat.clog_le_iff_le_pow (by norm_num)).2 hle
  calc (2:ℕ) ^ Nat.clog 2 k ≤ 2 ^ e := Nat.pow_le_pow_right (by norm_num) this
  _ = read dyadGrid k := he.symm

/-- The dyadic sweep is exact exactly at the powers of two. -/
theorem dyad_exact_iff_pow_two {k : ℕ} : read dyadGrid k = k ↔ ∃ e : ℕ, k = 2 ^ e :=
  read_eq_self_iff

/-- The base-two digit sum of a nonzero natural number is positive: its leading digit is
nonzero. -/
theorem sum_digits_pos {b n : ℕ} (hn : n ≠ 0) : 0 < (Nat.digits b n).sum := by
  have hne : Nat.digits b n ≠ [] := Nat.digits_ne_nil_iff_ne_zero.2 hn
  have hlast : (Nat.digits b n).getLast hne ≠ 0 := Nat.getLast_digit_ne_zero b hn
  have hmem : (Nat.digits b n).getLast hne ∈ Nat.digits b n := List.getLast_mem hne
  have := List.single_le_sum (l := Nat.digits b n) (fun _ _ => Nat.zero_le _) _ hmem
  omega

/-- Binary weight one forces a power of two. -/
theorem pow_two_of_sum_digits_eq_one :
    ∀ n : ℕ, n ≠ 0 → (Nat.digits 2 n).sum = 1 → ∃ e : ℕ, n = 2 ^ e := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro hn hsum
    rcases Nat.even_or_odd n with hev | hod
    · obtain ⟨t, ht⟩ := hev
      have ht2 : n = 2 * t := by omega
      have htne : t ≠ 0 := by omega
      have hdig : Nat.digits 2 n = 0 :: Nat.digits 2 t := by
        rw [Nat.digits_def' (by norm_num) (by omega)]
        congr 1
        · omega
        · congr 1; omega
      rw [hdig] at hsum
      simp only [List.sum_cons, Nat.zero_add] at hsum
      obtain ⟨e, he⟩ := ih t (by omega) htne hsum
      exact ⟨e + 1, by rw [ht2, he, pow_succ]; ring⟩
    · have hm1 : n % 2 = 1 := Nat.odd_iff.1 hod
      have hdig : Nat.digits 2 n = 1 :: Nat.digits 2 (n / 2) := by
        rw [Nat.digits_def' (by norm_num) (by omega), hm1]
      rw [hdig] at hsum
      simp only [List.sum_cons] at hsum
      have hq : n / 2 = 0 := by
        by_contra hcon
        have := sum_digits_pos (b := 2) (n := n / 2) hcon
        omega
      exact ⟨0, by omega⟩

/-- **Exactness of a doubling sweep is a base-two digit-sum condition**: a dyadic grid
resolves `k > 0` iff the binary expansion of `k` has a single one.  Every knee of binary
weight `≥ 2` — such as `20 = 10100₂` and `24 = 11000₂` — is necessarily misread. -/
theorem dyad_exact_iff_binary_weight_one {k : ℕ} (hk : k ≠ 0) :
    read dyadGrid k = k ↔ (Nat.digits 2 k).sum = 1 := by
  rw [dyad_exact_iff_pow_two]
  constructor
  · rintro ⟨e, rfl⟩
    have : (2:ℕ) ^ e = 2 ^ e * 1 := by ring
    rw [this, Nat.digits_base_pow_mul (by norm_num) (by norm_num)]
    simp
  · exact pow_two_of_sum_digits_eq_one k hk

/-- **The coarse-grid artifact, in general form.**  If the true knee `k` is strictly
between two consecutive powers of two, the doubling sweep reports the upper one, which is
strictly larger: the report overstates the budget by `2 ^ (e+1) - k`. -/
theorem dyad_overstates {k e : ℕ} (hlo : 2 ^ e < k) (hhi : k ≤ 2 ^ (e + 1)) :
    read dyadGrid k = 2 ^ (e + 1) := by
  refine le_antisymm (read_le_of_mem ⟨e + 1, rfl⟩ hhi) ?_
  obtain ⟨j, hj⟩ := read_mem_carrier dyadGrid k
  have hkle : k ≤ 2 ^ j := hj ▸ le_read dyadGrid k
  have hej : e < j := by
    by_contra hcon
    have : (2:ℕ) ^ j ≤ 2 ^ e := Nat.pow_le_pow_right (by norm_num) (by omega)
    omega
  calc (2:ℕ) ^ (e + 1) ≤ 2 ^ j := Nat.pow_le_pow_right (by norm_num) (by omega)
  _ = read dyadGrid k := hj.symm

/-- Two knees in the same dyadic gap are reported identically — the mechanism by which a
strictly monotone knee chain is flattened by a doubling sweep. -/
theorem dyad_collapse_of_lt {k k' e : ℕ} (h1 : 2 ^ e < k) (h2 : k ≤ k')
    (h3 : k' ≤ 2 ^ (e + 1)) : read dyadGrid k = read dyadGrid k' :=
  (dyad_overstates h1 (h2.trans h3)).trans (dyad_overstates (h1.trans_le h2) h3).symm

/-! ## 4.  Instantiation on the catalog's attention-budget profile -/

open AttentionBudget in
/-- A top-`k` sweep of the retained-attention profile of
`Catalog/Shared/AttentionBudgetKnee.lean`, restricted to a grid `G`, reports exactly the
`G`-rounding of the true knee `kstar w n τ`. -/
theorem attentionBudget_grid_reading (G : Grid) (w : ℕ → ℝ) {n : ℕ} {τ : ℝ}
    (hw : ∀ i, 0 < w i) (hn : 0 < n) (hτ : τ ≤ 1) :
    sInf {g | g ∈ G.carrier ∧ τ ≤ retained w n g} = read G (kstar w n τ) :=
  measured_knee_eq_read G (retained_mono hw n) (gateSet_nonempty hw hn hτ)

end GridKnee