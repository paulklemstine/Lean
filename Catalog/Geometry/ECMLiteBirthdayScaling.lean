import Mathlib
import Shared.BirthdayBoundHierarchy

/-!
# ECM-lite: the exact detection window of sequential multiples, and its scaling law

This file gives a rigorous group-theoretic model of the **"ECM-lite"** factoring
arm: on a random elliptic curve `E` over `ℤ/N` one picks a base point `P` and
walks the *sequential* multiples `2P, 3P, …, B·P` (explicitly **not** the
lcm-based ladder `lcm(1,…,B)·P` of true ECM), hoping that one of the modular
inversions performed along the way fails, which reveals a factor of `N`.

Everything that matters happens inside the group `E(𝔽_p)` for the hidden prime
`p`, so we model a curve by a finite abelian (here: cyclic) group `G`, the base
point by `P : G`, and the geometry of the `x`-coordinate by the elliptic
involution `Q ↦ -Q`: two affine points of a Weierstrass curve share an
`x`-coordinate exactly when they are equal or opposite.

## Main results

* `liteHit_iff_addOrderOf_le` — the lite arm annihilates `P` iff `addOrderOf P ≤ B`.
* `ecmHit_iff_addOrderOf_dvd` — true ECM succeeds iff the order is `B`-smooth
  (divides `lcm(1,…,B)`), a vastly weaker requirement.
* `liteHit_imp_ecmHit`, `ecm_beats_lite_at_96` — lite success implies ECM
  success, strictly: order `96` is `50`-smooth but far outside the lite window.
* `xCollision_iff_addOrderOf_le` — **the sharp detection window.**  A repeated
  `x`-coordinate among `P, 2P, …, B·P` occurs **iff** `addOrderOf P ≤ 2B - 1`
  (for `B ≥ 3`), and order exactly `2B` is invisible
  (`no_xCollision_of_addOrderOf_eq_two_mul`): both endpoints are sharp.
* `degenerate_iff_two_torsion` — the formal shape of the v1 implementation bug.
* `card_lowOrder_le_pow`, `card_lowOrder_le_sq`, `card_lowOrder_eq_sum_totient` —
  the visible set of the lite arm has at most `B^{k+1}` elements whenever
  `d • a = 0` has at most `d^k` solutions (`k = 1` cyclic, `k = 2` for a general
  `E(𝔽_p) ≅ ℤ/m ⊕ ℤ/n`), with the exact cyclic value `∑_{d ∣ |G|, d ≤ B} φ(d)`.
  A *polynomial* window, not a birthday window.
* `ecm_lite_detection_gap` — a concrete cyclic group where true ECM sees all
  `1058400` points and the lite arm sees at most `2500` of them.
* `curve_budget_lower_bound`, `fixed_bound_refutes_sqrt_scaling` — with `B`
  fixed, any curve budget reaching success probability `1/2` is `≥ p/(2B²)`,
  which is **not** `O(√p)`.
* `quarter_power_bound_gives_sqrt_budget` — a `√p` budget is exactly what a
  stage-one bound `B ≈ p^{1/4}` produces.
* `lite_matches_rho_iff_bound_large` — ECM-lite can match Pollard rho's `√p`
  work only if the bound `B` is itself of order `√p`, i.e. only if the arm has
  abandoned smoothness entirely.
* `lite_budget_gt_sqrt` — bridge to `Shared.BirthdayBoundHierarchy`: a
  *guaranteed* lite hit still costs more than `√N` inspected points.

## Lab notes (experimental input: exp 487, seed 20260921)

Sequential multiples `j = 3..B₁ = 50` over random curves factored `1200/1200`
targets at `k = 16` bits and `1163/1200` at `k = 20` (3.1% censoring); the
across-`k` slope of the curve budget was `0.48` per `log₂ p`, giving the
four-method plane td `0.84` / rho `0.52` / Fermat `0.50` / ECM-lite `0.48` on
one population.  Ledger: the v1 run was degenerate because the running point at
`j = 2` equalled the base point, so every denominator vanished instantly; the
fix was an explicit doubling.

Two of the theorems below speak directly to that data.
`xCollision_iff_addOrderOf_le` explains the bug structurally: the run detects
*exactly* the base points of order `≤ 2B - 1`, and the `j = 2` comparison is the
`2`-torsion end of that window (`degenerate_iff_two_torsion`).
`fixed_bound_refutes_sqrt_scaling` shows that a *fixed* `B₁ = 50` window has
curve-count exponent `1`, not `1/2`; so the measured `0.48` cannot be a property
of the fixed-window lite structure in the asymptotic regime, and must be
attributed to the narrow measured range (`k = 16, 20`), to the 3.1% censoring,
or to an effective bound that grows with `p` — `p^{1/4}` being the exact
crossover (`quarter_power_bound_gives_sqrt_budget`).
-/

namespace ECMLite

open Finset

variable {G : Type*} [AddGroup G]

/-! ## The two arms -/

/-- **ECM-lite hit.**  The sequential-multiple arm annihilates the base point:
some multiple `j·P` with `2 ≤ j ≤ B` vanishes in `E(𝔽_p)`. -/
def LiteHit (P : G) (B : ℕ) : Prop := ∃ j ∈ Finset.Icc 2 B, j • P = 0

/-- The stage-one exponent of *true* ECM: `lcm(1, …, B)`. -/
def smoothExp (B : ℕ) : ℕ := (Finset.Icc 1 B).lcm id

/-- **True ECM hit.**  The lcm ladder annihilates the base point. -/
def EcmHit (P : G) (B : ℕ) : Prop := (smoothExp B) • P = 0

/-- Two affine points of a Weierstrass curve share an `x`-coordinate exactly
when they are equal or opposite; this is the group-level shadow of that
geometry. -/
def XEq (a b : G) : Prop := a = b ∨ a = -b

/-- A repeated `x`-coordinate inside the sequential run `P, 2P, …, B·P`.  This
is the event that makes a modular inversion fail, i.e. the event that the lite
arm actually detects. -/
def XCollision (P : G) (B : ℕ) : Prop :=
  ∃ i ∈ Finset.Icc 1 B, ∃ j ∈ Finset.Icc 1 B, i < j ∧ XEq (i • P) (j • P)

/-! ## The lite window is the *order* window -/

/-- Every `n` with `1 ≤ n ≤ B` divides the stage-one exponent. -/
theorem dvd_smoothExp {n B : ℕ} (h1 : 1 ≤ n) (h2 : n ≤ B) : n ∣ smoothExp B :=
  Finset.dvd_lcm (f := id) (Finset.mem_Icc.mpr ⟨h1, h2⟩)

/-- The stage-one exponent is positive. -/
theorem smoothExp_pos (B : ℕ) : 0 < smoothExp B := by
  refine Nat.pos_of_ne_zero fun h => ?_
  obtain ⟨x, hx, hx0⟩ := Finset.lcm_eq_zero_iff.mp h
  rw [Finset.mem_Icc] at hx
  simp only [id] at hx0
  omega

/-- **The lite arm sees exactly the orders `≤ B`.**  Sequential multiples
annihilate `P` iff the order of `P` is at most `B`: no smoothness whatsoever is
exploited. -/
theorem liteHit_iff_addOrderOf_le {P : G} {B : ℕ} (hB : 2 ≤ B)
    (hP : 0 < addOrderOf P) : LiteHit P B ↔ addOrderOf P ≤ B := by
  constructor
  · rintro ⟨j, hj, hjP⟩
    rw [Finset.mem_Icc] at hj
    have hdvd : addOrderOf P ∣ j := addOrderOf_dvd_iff_nsmul_eq_zero.mpr hjP
    exact le_trans (Nat.le_of_dvd (by omega) hdvd) hj.2
  · intro h
    rcases le_or_gt (addOrderOf P) 1 with h1 | h1
    · have h1' : addOrderOf P = 1 := by omega
      exact ⟨2, Finset.mem_Icc.mpr ⟨le_rfl, hB⟩,
        addOrderOf_dvd_iff_nsmul_eq_zero.mp (by rw [h1']; exact one_dvd 2)⟩
    · exact ⟨addOrderOf P, Finset.mem_Icc.mpr ⟨h1, h⟩,
        addOrderOf_dvd_iff_nsmul_eq_zero.mp dvd_rfl⟩

/-- **True ECM sees exactly the `B`-smooth orders.** -/
theorem ecmHit_iff_addOrderOf_dvd {P : G} {B : ℕ} :
    EcmHit P B ↔ addOrderOf P ∣ smoothExp B :=
  addOrderOf_dvd_iff_nsmul_eq_zero.symm

/-- Every lite hit is an ECM hit. -/
theorem liteHit_imp_ecmHit {P : G} {B : ℕ} (hB : 2 ≤ B) (hP : 0 < addOrderOf P)
    (h : LiteHit P B) : EcmHit P B := by
  rw [ecmHit_iff_addOrderOf_dvd]
  exact dvd_smoothExp hP ((liteHit_iff_addOrderOf_le hB hP).mp h)

/-- `96 = 2^5 · 3` is `50`-smooth. -/
theorem ninetySix_dvd_smoothExp_fifty : 96 ∣ smoothExp 50 := by
  have h32 : (32 : ℕ) ∣ smoothExp 50 := dvd_smoothExp (by norm_num) (by norm_num)
  have h3 : (3 : ℕ) ∣ smoothExp 50 := dvd_smoothExp (by norm_num) (by norm_num)
  have hc : Nat.Coprime 32 3 := by norm_num
  simpa using hc.mul_dvd_of_dvd_of_dvd h32 h3

/-- **The separation is strict.**  In `ℤ/96` the generator has order `96`: true
ECM with `B = 50` annihilates it (because `96 = 2^5·3` is `50`-smooth) while the
lite arm, whose window stops at `50`, never sees it. -/
theorem ecm_beats_lite_at_96 :
    EcmHit (1 : ZMod 96) 50 ∧ ¬ LiteHit (1 : ZMod 96) 50 := by
  have hord : addOrderOf (1 : ZMod 96) = 96 := ZMod.addOrderOf_one 96
  refine ⟨?_, ?_⟩
  · rw [ecmHit_iff_addOrderOf_dvd, hord]
    exact ninetySix_dvd_smoothExp_fifty
  · rw [liteHit_iff_addOrderOf_le (by norm_num) (by rw [hord]; norm_num), hord]
    norm_num

/-! ## The sharp `x`-coordinate detection window -/

/-- Equality of `x`-coordinates inside the run, in terms of the order: either
the two multiples coincide (`ord ∣ j - i`) or they are opposite under the
elliptic involution (`ord ∣ i + j`). -/
theorem xEq_iff_dvd {P : G} {i j : ℕ} (hij : i ≤ j) :
    XEq (i • P) (j • P) ↔ addOrderOf P ∣ (j - i) ∨ addOrderOf P ∣ (i + j) := by
  have hneg : (i • P = -(j • P)) ↔ (i + j) • P = 0 := by
    rw [add_nsmul]
    exact ⟨fun h => by rw [h]; simp, fun h => eq_neg_of_add_eq_zero_left h⟩
  have hpow : (i • P = j • P) ↔ addOrderOf P ∣ (j - i) := by
    rw [nsmul_eq_nsmul_iff_modEq, Nat.modEq_iff_dvd' hij]
  rw [XEq, hneg, ← addOrderOf_dvd_iff_nsmul_eq_zero, hpow]

/-- **The detection window of the sequential run is exactly `[1, 2B-1]`.**
Walking `P, 2P, …, B·P` produces a repeated `x`-coordinate — the event whose
failed inversion reveals the factor — if and only if the order of the base point
is at most `2B - 1`.  The lower half of the window comes from genuine repetition
(`jP = iP` with `ord ∣ j - i`), the upper half from the elliptic involution
(`iP = -(jP)` with `ord ∣ i + j`). -/
theorem xCollision_iff_addOrderOf_le {P : G} {B : ℕ} (hB : 3 ≤ B)
    (hP : 0 < addOrderOf P) :
    XCollision P B ↔ addOrderOf P ≤ 2 * B - 1 := by
  set d := addOrderOf P with hd
  constructor
  · rintro ⟨i, hi, j, hj, hij, hx⟩
    rw [Finset.mem_Icc] at hi hj
    rcases (xEq_iff_dvd (le_of_lt hij)).mp hx with h | h
    · have := Nat.le_of_dvd (show 0 < j - i by omega) h
      omega
    · have := Nat.le_of_dvd (show 0 < i + j by omega) h
      omega
  · intro hle
    rcases le_or_gt d (B - 1) with hsmall | hbig
    · -- short orders: the repetition `1·P = (1 + d)·P`
      exact ⟨1, Finset.mem_Icc.mpr ⟨le_rfl, by omega⟩, 1 + d,
        Finset.mem_Icc.mpr ⟨by omega, by omega⟩, by omega,
        (xEq_iff_dvd (by omega)).mpr (Or.inl ⟨1, by omega⟩)⟩
    · rcases eq_or_lt_of_le (show B ≤ d by omega) with heq | hgt
      · -- `d = B`: the involution pair `1 + (B - 1) = d`
        exact ⟨1, Finset.mem_Icc.mpr ⟨le_rfl, by omega⟩, B - 1,
          Finset.mem_Icc.mpr ⟨by omega, by omega⟩, by omega,
          (xEq_iff_dvd (by omega)).mpr (Or.inr ⟨1, by omega⟩)⟩
      · -- `B < d ≤ 2B - 1`: the involution pair `(d - B) + B = d`
        exact ⟨d - B, Finset.mem_Icc.mpr ⟨by omega, by omega⟩, B,
          Finset.mem_Icc.mpr ⟨by omega, le_rfl⟩, by omega,
          (xEq_iff_dvd (by omega)).mpr (Or.inr ⟨1, by omega⟩)⟩

/-- **Sharpness at the top of the window.**  A base point of order exactly `2B`
is invisible to a run of length `B`: the window `[1, 2B-1]` cannot be widened. -/
theorem no_xCollision_of_addOrderOf_eq_two_mul {P : G} {B : ℕ} (hB : 3 ≤ B)
    (hP : addOrderOf P = 2 * B) : ¬ XCollision P B := by
  intro h
  have hpos : 0 < addOrderOf P := by omega
  have := (xCollision_iff_addOrderOf_le hB hpos).mp h
  omega

/-- **The `j = 2` degeneracy (formal form of the v1 ledger bug).**  The very
first comparison of the run is informative only when the base point is not
`2`-torsion; a running point that already equals (plus or minus) the base point
at `j = 2` is exactly a base point of order `≤ 2`.  If a buggy implementation
compares the base point with itself, it manufactures this event for *every*
curve, which is precisely the observed instant-degeneracy. -/
theorem degenerate_iff_two_torsion {P : G} (hP : 0 < addOrderOf P) :
    (2 • P = 0) ↔ addOrderOf P ≤ 2 := by
  rw [← addOrderOf_dvd_iff_nsmul_eq_zero]
  constructor
  · intro h; exact Nat.le_of_dvd (by norm_num) h
  · intro h
    have h2 : addOrderOf P = 1 ∨ addOrderOf P = 2 := by omega
    rcases h2 with h1 | h1 <;> simp [h1]

/-! ## Counting: the lite window is quadratic, not birthday-sized -/

open scoped Classical in
/-- **General visible-set bound.**  Suppose every equation `d • a = 0` has at
most `d ^ k` solutions in `G` — true with `k = 1` for cyclic groups and with
`k = 2` for every elliptic-curve group `E(𝔽_p) ≅ ℤ/m ⊕ ℤ/n`.  Then at most
`B ^ (k + 1)` points are visible to the lite arm. -/
theorem card_lowOrder_le_pow {G : Type*} [AddGroup G] [Fintype G] (B k : ℕ)
    (hsol : ∀ d, 0 < d → (Finset.univ.filter (fun a : G => d • a = 0)).card ≤ d ^ k) :
    (Finset.univ.filter (fun a : G => addOrderOf a ≤ B)).card ≤ B ^ (k + 1) := by
  have hfib : (Finset.univ.filter (fun a : G => addOrderOf a ≤ B)).card
      = ∑ d ∈ Finset.Icc 1 B,
        ((Finset.univ.filter (fun a : G => addOrderOf a ≤ B)).filter
          (fun a => addOrderOf a = d)).card :=
    Finset.card_eq_sum_card_fiberwise (fun a ha =>
      Finset.mem_Icc.mpr ⟨addOrderOf_pos a, (Finset.mem_filter.mp ha).2⟩)
  have hbound : ∀ d ∈ Finset.Icc 1 B,
      ((Finset.univ.filter (fun a : G => addOrderOf a ≤ B)).filter
        (fun a => addOrderOf a = d)).card ≤ B ^ k := by
    intro d hd
    rw [Finset.mem_Icc] at hd
    have hsub : ((Finset.univ.filter (fun a : G => addOrderOf a ≤ B)).filter
        (fun a => addOrderOf a = d)) ⊆ Finset.univ.filter (fun a : G => d • a = 0) := by
      intro a ha
      have h2 := (Finset.mem_filter.mp ha).2
      exact Finset.mem_filter.mpr ⟨Finset.mem_univ a,
        addOrderOf_dvd_iff_nsmul_eq_zero.mp (h2 ▸ dvd_rfl)⟩
    calc _ ≤ (Finset.univ.filter (fun a : G => d • a = 0)).card := Finset.card_le_card hsub
      _ ≤ d ^ k := hsol d (by omega)
      _ ≤ B ^ k := Nat.pow_le_pow_left hd.2 k
  rw [hfib]
  calc ∑ d ∈ Finset.Icc 1 B,
        ((Finset.univ.filter (fun a : G => addOrderOf a ≤ B)).filter
          (fun a => addOrderOf a = d)).card
      ≤ ∑ _d ∈ Finset.Icc 1 B, B ^ k := Finset.sum_le_sum hbound
    _ = B * B ^ k := by rw [Finset.sum_const, Nat.card_Icc]; simp
    _ = B ^ (k + 1) := by ring

open scoped Classical in
/-- **At most `B²` points are visible to the lite arm** in a cyclic group,
because for each `d ≤ B` the equation `d • a = 0` has at most `d` solutions. -/
theorem card_lowOrder_le_sq {G : Type*} [AddGroup G] [Fintype G] [IsAddCyclic G]
    (B : ℕ) :
    (Finset.univ.filter (fun a : G => addOrderOf a ≤ B)).card ≤ B ^ 2 :=
  card_lowOrder_le_pow B 1 (fun d hd => by
    simpa using IsAddCyclic.card_nsmul_eq_zero_le (α := G) hd)

open scoped Classical in
/-- **Exact size of the lite-visible set.**  In a cyclic group the points the
lite arm can ever detect are counted by `∑_{d ∣ |G|, d ≤ B} φ(d)`.  Only the
divisors of the group order below the bound contribute: no smoothness, no
`lcm`, just the truncated divisor sum. -/
theorem card_lowOrder_eq_sum_totient {G : Type*} [AddGroup G] [Fintype G]
    [IsAddCyclic G] (B : ℕ) :
    (Finset.univ.filter (fun a : G => addOrderOf a ≤ B)).card
      = ∑ d ∈ (Finset.Icc 1 B).filter (fun d => d ∣ Fintype.card G), d.totient := by
  have hfib : (Finset.univ.filter (fun a : G => addOrderOf a ≤ B)).card
      = ∑ d ∈ Finset.Icc 1 B,
        ((Finset.univ.filter (fun a : G => addOrderOf a ≤ B)).filter
          (fun a => addOrderOf a = d)).card :=
    Finset.card_eq_sum_card_fiberwise (fun a ha =>
      Finset.mem_Icc.mpr ⟨addOrderOf_pos a, (Finset.mem_filter.mp ha).2⟩)
  have hinner : ∀ d ∈ Finset.Icc 1 B,
      ((Finset.univ.filter (fun a : G => addOrderOf a ≤ B)).filter
        (fun a => addOrderOf a = d)).card
      = (Finset.univ.filter (fun a : G => addOrderOf a = d)).card := by
    intro d hd
    rw [Finset.mem_Icc] at hd
    congr 1
    ext a
    constructor
    · intro ha; exact Finset.mem_filter.mpr ⟨Finset.mem_univ a, (Finset.mem_filter.mp ha).2⟩
    · intro ha
      have h2 := (Finset.mem_filter.mp ha).2
      exact Finset.mem_filter.mpr
        ⟨Finset.mem_filter.mpr ⟨Finset.mem_univ a, by rw [h2]; exact hd.2⟩, h2⟩
  rw [hfib, Finset.sum_congr rfl hinner]
  rw [← Finset.sum_filter_of_ne (p := fun d => d ∣ Fintype.card G) ?zero]
  · refine Finset.sum_congr rfl ?_
    intro d hd
    have hdvd := (Finset.mem_filter.mp hd).2
    simpa using IsAddCyclic.card_addOrderOf_eq_totient (α := G) hdvd
  · intro d _ hne
    by_contra hcon
    apply hne
    rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
    intro a _ hord
    exact hcon (hord ▸ addOrderOf_dvd_card)

/-- `1058400 = 2^5 · 3^3 · 5^2 · 7^2` is `50`-smooth. -/
theorem big_dvd_smoothExp_fifty : 1058400 ∣ smoothExp 50 := by
  have h32 : (32 : ℕ) ∣ smoothExp 50 := dvd_smoothExp (by norm_num) (by norm_num)
  have h27 : (27 : ℕ) ∣ smoothExp 50 := dvd_smoothExp (by norm_num) (by norm_num)
  have h25 : (25 : ℕ) ∣ smoothExp 50 := dvd_smoothExp (by norm_num) (by norm_num)
  have h49 : (49 : ℕ) ∣ smoothExp 50 := dvd_smoothExp (by norm_num) (by norm_num)
  have c1 : Nat.Coprime 32 27 := by norm_num
  have h1 : (32 * 27 : ℕ) ∣ smoothExp 50 := c1.mul_dvd_of_dvd_of_dvd h32 h27
  have c2 : Nat.Coprime (32 * 27) 25 := by norm_num
  have h2 : (32 * 27 * 25 : ℕ) ∣ smoothExp 50 := c2.mul_dvd_of_dvd_of_dvd h1 h25
  have c3 : Nat.Coprime (32 * 27 * 25) 49 := by norm_num
  have h3 : (32 * 27 * 25 * 49 : ℕ) ∣ smoothExp 50 := c3.mul_dvd_of_dvd_of_dvd h2 h49
  simpa using h3

/-- The stage-one exponent of true ECM dwarfs the lite window: at `B = 50` the
lcm ladder exceeds `B²` by more than two orders of magnitude. -/
theorem smoothExp_fifty_gt_window : 50 ^ 2 < smoothExp 50 :=
  lt_of_lt_of_le (by norm_num)
    (Nat.le_of_dvd (smoothExp_pos 50) big_dvd_smoothExp_fifty)

open scoped Classical in
/-- **The detection gap, concretely.**  On a cyclic curve group of order
`1058400 = 2^5·3^3·5^2·7^2` — a perfectly ordinary `50`-smooth order — true ECM
at `B = 50` annihilates *every* point, while the lite arm at the same bound sees
at most `2500` of them: a factor `> 400` loss caused purely by replacing the lcm
ladder with sequential multiples. -/
theorem ecm_lite_detection_gap :
    (∀ x : ZMod 1058400, EcmHit x 50) ∧
      (Finset.univ.filter (fun a : ZMod 1058400 => addOrderOf a ≤ 50)).card ≤ 2500 ∧
      2500 * 400 < 1058400 := by
  refine ⟨?_, ?_, by norm_num⟩
  · intro x
    rw [ecmHit_iff_addOrderOf_dvd]
    have hcard : addOrderOf x ∣ Fintype.card (ZMod 1058400) := addOrderOf_dvd_card
    rw [ZMod.card] at hcard
    exact hcard.trans big_dvd_smoothExp_fifty
  · simpa using card_lowOrder_le_sq (G := ZMod 1058400) 50

/-! ## Scaling: a fixed bound `B` forces a linear, not a square-root, budget -/

/-- Bernoulli / union bound: the probability that at least one of `C`
independent curves with per-curve success probability `q` succeeds is at most
`C · q`. -/
theorem success_prob_le (q : ℝ) (hq1 : q ≤ 1) (C : ℕ) :
    1 - (1 - q) ^ C ≤ C * q := by
  have h := one_add_mul_le_pow (a := -q) (by linarith) C
  rw [show (1 : ℝ) + -q = 1 - q from by ring] at h
  ring_nf at h ⊢
  linarith

/-- **Curve-budget lower bound.**  If each curve succeeds with probability at
most `B²/p` — which `card_lowOrder_le_sq` shows is the truth for the lite arm,
whose visible set has size `≤ B²` inside a group of size `≈ p` — then a budget of
fewer than `p/(2B²)` curves cannot reach success probability `1/2`. -/
theorem curve_budget_lower_bound {p B C : ℕ} (hp : 0 < p) (hB : 0 < B) (q : ℝ)
    (hq1 : q ≤ 1) (hq : q ≤ (B : ℝ) ^ 2 / p)
    (hC : (C : ℝ) < p / (2 * (B : ℝ) ^ 2)) :
    1 - (1 - q) ^ C < 1 / 2 := by
  have hp' : (0 : ℝ) < p := by exact_mod_cast hp
  have hB0 : (0 : ℝ) < (B : ℝ) := by exact_mod_cast hB
  have hB' : (0 : ℝ) < (B : ℝ) ^ 2 := by positivity
  have h1 : 1 - (1 - q) ^ C ≤ (C : ℝ) * q := success_prob_le q hq1 C
  have h2 : (C : ℝ) * q ≤ (C : ℝ) * ((B : ℝ) ^ 2 / p) :=
    mul_le_mul_of_nonneg_left hq (Nat.cast_nonneg C)
  have h3 : (C : ℝ) * ((B : ℝ) ^ 2 / p) < (p / (2 * (B : ℝ) ^ 2)) * ((B : ℝ) ^ 2 / p) :=
    mul_lt_mul_of_pos_right hC (by positivity)
  have h4 : (p / (2 * (B : ℝ) ^ 2)) * ((B : ℝ) ^ 2 / p) = 1 / 2 := by
    field_simp
  linarith

/-- **A fixed window cannot produce a square-root slope.**  For every fixed
bound `B` and every constant `c`, the budget `p/(2B²)` eventually exceeds
`c·√p`: fixed-`B` ECM-lite has curve-count exponent `1`, not `1/2`.  Hence a
measured slope `≈ 0.48` per `log₂ p` is not an asymptotic property of the
fixed-window lite structure. -/
theorem fixed_bound_refutes_sqrt_scaling (B : ℕ) (hB : 0 < B) (c : ℝ) :
    ∃ p : ℕ, 0 < p ∧ c * Real.sqrt p < (p : ℝ) / (2 * (B : ℝ) ^ 2) := by
  obtain ⟨m, hm⟩ := exists_nat_gt (max 1 (2 * c * (B : ℝ) ^ 2))
  have hm1 : (1 : ℝ) < (m : ℝ) := lt_of_le_of_lt (le_max_left _ _) hm
  have hm2 : 2 * c * (B : ℝ) ^ 2 < (m : ℝ) := lt_of_le_of_lt (le_max_right _ _) hm
  have hmpos : 0 < m := by exact_mod_cast (by linarith : (0 : ℝ) < (m : ℝ))
  refine ⟨m ^ 2, pow_pos hmpos 2, ?_⟩
  have hB0 : (0 : ℝ) < (B : ℝ) := by exact_mod_cast hB
  have hcast : ((m ^ 2 : ℕ) : ℝ) = (m : ℝ) ^ 2 := by push_cast; ring
  rw [hcast, Real.sqrt_sq (by linarith), lt_div_iff₀ (by positivity)]
  nlinarith [mul_lt_mul_of_pos_left hm2 (show (0 : ℝ) < (m : ℝ) by linarith)]

/-- **Reconciliation.**  A `√p` curve budget is exactly what a bound growing
like `p^{1/4}` produces: for `p = m⁴` and `B = m` the bound `p/(2B²)` equals
`√p / 2`.  So a birthday-looking slope `1/2` is a statement about a *scaled*
stage-one bound, not about a fixed `B₁ = 50`. -/
theorem quarter_power_bound_gives_sqrt_budget (m : ℕ) (hm : 0 < m) :
    ((m ^ 4 : ℕ) : ℝ) / (2 * (m : ℝ) ^ 2) = Real.sqrt ((m ^ 4 : ℕ) : ℝ) / 2 := by
  have hm' : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hcast : ((m ^ 4 : ℕ) : ℝ) = ((m : ℝ) ^ 2) ^ 2 := by push_cast; ring
  rw [hcast, Real.sqrt_sq (by positivity)]
  field_simp

/-- **ECM-lite versus Pollard rho.**  Reaching a constant success probability
costs the lite arm about `p/(4B²)` curves, i.e. about `p/(4B)` point operations,
while rho costs `√p`.  The lite arm therefore matches rho **iff** its stage-one
bound is already of order `√p` — at which point the "smoothness" bound has
degenerated into a birthday search and the lite structure buys nothing. -/
theorem lite_matches_rho_iff_bound_large {p B : ℕ} (hp : 0 < p) (hB : 0 < B) :
    (p : ℝ) / (4 * B) ≤ Real.sqrt p ↔ Real.sqrt p ≤ 4 * B := by
  have hp' : (0 : ℝ) < p := by exact_mod_cast hp
  have hB' : (0 : ℝ) < 4 * B := by
    have : (0 : ℝ) < (B : ℝ) := by exact_mod_cast hB
    linarith
  have hs : (0 : ℝ) < Real.sqrt p := Real.sqrt_pos.mpr hp'
  have hsq : Real.sqrt p * Real.sqrt p = p := Real.mul_self_sqrt hp'.le
  rw [div_le_iff₀ hB']
  exact ⟨fun h => by nlinarith, fun h => by nlinarith⟩

/-! ## Bridge to the catalog birthday hierarchy -/

/-- **The guaranteed-hit barrier survives.**  Model a lite campaign by the
finite set `S` of inspected points (at most `C` curves × `B` multiples each).  If
the campaign is *guaranteed* to see a collision of residues modulo the hidden
prime `p` of `N = p·q` (`q ≤ p`), then `C·B > √N`: the sequential-multiple
structure buys nothing against the birthday barrier of
`Shared.BirthdayBoundHierarchy`. -/
theorem lite_budget_gt_sqrt {α : Type*} {p q C B : ℕ} {S : Finset α} (hp : 0 < p)
    (hqp : q ≤ p) (hcard : S.card ≤ C * B)
    (h : ∀ f : α → ℕ, (∀ x, f x < p) → ∃ x ∈ S, ∃ y ∈ S, x ≠ y ∧ f x = f y) :
    Nat.sqrt (p * q) < C * B :=
  lt_of_lt_of_le (BirthdayHierarchy.cost_gt_sqrt hp hqp h) hcard

end ECMLite