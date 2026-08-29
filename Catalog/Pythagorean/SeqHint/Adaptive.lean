import Mathlib

/-!
# Sequential hint pricing II: adaptive hints compound *geometrically*, up to a hard ceiling

Companion to `Pythagorean/SeqHint/Battery.lean`, which showed that a **fixed**
battery of `k` comparison hints prices linearly (`speedup ≤ k + 1`).  Here we
formalise the other face of the same pricing structure: hints that are chosen
**adaptively** — each threshold computed from the answers already received —
compound geometrically, `speedup = 2 ^ k`, and saturate *exactly* at the
isolation ceiling `k = ⌈log₂ W⌉`, never beyond it.

Main results.

* `Window.step_width_le`, `halfIter_bisect` — the **width-halving law**.  One
  adaptive query at the *lower* median takes a window of width `w` to a window
  of width at most `⌈w / 2⌉`, on either answer, and the true candidate is
  retained (`bisect_mem`).

* `naive_upper_median_stalls` — the ledger catch: with the *upper* median the
  same scheme **stalls forever** on an even-width window.  This is why the
  lower-median convention above is not cosmetic.

* `bisection_isolates` — after `k = ⌈log₂ w⌉` adaptive queries the window is the
  singleton `{x}`: the adaptive arm reaches the isolation ceiling exactly.

* `isolation_ceiling` — the matching **lower bound over all adaptive
  strategies**, not just bisection: a `k`-query adaptive strategy produces at
  most `2 ^ k` distinct transcripts, so if `2 ^ k < #W` some pair of candidates
  is provably indistinguishable.  Together with `bisection_isolates` this pins
  the saturation point at `k = ⌈log₂ #W⌉` and shows no strategy can beat it:
  external position information is priced at one bit per query, no more
  (barriers 4/8 upheld and priced).

* `premium`, `premium_one`, `premium_strict_mono`, `premium_superlinear` — the
  adaptivity premium `r(k) = 2 ^ k / (k + 1)`, the ratio of the geometric
  adaptive law to the linear fixed-battery law.  It equals `1` **exactly** at
  `k = 0, 1` (nothing to adapt to at one query — the experiment's
  `r(1) = 1.00 EXACTLY`), is strictly increasing from `k = 1` on, and outgrows
  every linear function.  `premium_twelve_ge_measured` records that the measured
  premium `239.5` at `k = 12` sits below the idealized ceiling `4096 / 13`.
-/

namespace Pythagorean.SeqHint

open Finset

/-! ## Windows and the lower-median bisection step -/

/-- A half-open search window `[lo, hi)` for the unknown factor. -/
structure Window where
  lo : ℕ
  hi : ℕ
  deriving DecidableEq

namespace Window

/-- Number of candidates left in the window. -/
def width (I : Window) : ℕ := I.hi - I.lo

/-- The candidate set of the window. -/
def carrier (I : Window) : Finset ℕ := Finset.Ico I.lo I.hi

/-- The **lower median** threshold: the query `p ≤ mid?` asked by the adaptive
arm.  Using the lower median (rather than `lo + width / 2`) is what makes the
width strictly decrease on both answers. -/
def mid (I : Window) : ℕ := I.lo + (I.width - 1) / 2

/-- One adaptive step, given the oracle answer `b` to `p ≤ mid?`. -/
def step (I : Window) (b : Bool) : Window :=
  if b then ⟨I.lo, I.mid + 1⟩ else ⟨I.mid + 1, I.hi⟩

/-- The **width-halving law**: one adaptive query at the lower median takes a
nonempty window of width `w` to a window of width at most `⌈w / 2⌉`, whichever
answer comes back. -/
theorem step_width_le (I : Window) (b : Bool) (h : 0 < I.width) :
    (I.step b).width ≤ (I.width + 1) / 2 := by
  unfold step
  cases b
  · show I.hi - (I.mid + 1) ≤ (I.width + 1) / 2
    unfold Window.mid Window.width at *
    omega
  · show I.mid + 1 - I.lo ≤ (I.width + 1) / 2
    unfold Window.mid Window.width at *
    omega

/-- The true candidate is never discarded. -/
theorem mem_step {I : Window} {x : ℕ} (hx : x ∈ I.carrier) :
    x ∈ (I.step (decide (x ≤ I.mid))).carrier := by
  rw [carrier, mem_Ico] at hx
  by_cases hb : x ≤ I.mid <;>
    simp only [hb, step, decide_true, decide_false, Bool.false_eq_true, if_true, if_false,
      carrier, mem_Ico] <;>
    omega

end Window

/-- `k` iterations of `w ↦ ⌈w / 2⌉`: the worst-case width after `k` adaptive
queries. -/
def halfIter : ℕ → ℕ → ℕ
  | 0, w => w
  | (k + 1), w => halfIter k ((w + 1) / 2)

lemma halfIter_mono (k : ℕ) : ∀ {w₁ w₂ : ℕ}, w₁ ≤ w₂ → halfIter k w₁ ≤ halfIter k w₂ := by
  induction k with
  | zero => intro w₁ w₂ h; exact h
  | succ k ih =>
      intro w₁ w₂ h
      exact ih (by omega)

/-- If the window fits in `2 ^ k` candidates, `k` halvings isolate it. -/
lemma halfIter_le_one : ∀ (k w : ℕ), w ≤ 2 ^ k → halfIter k w ≤ 1 := by
  intro k
  induction k with
  | zero => intro w h; simpa [halfIter] using h
  | succ k ih =>
      intro w h
      have hpow : (2 : ℕ) ^ (k + 1) = 2 * 2 ^ k := by ring
      exact ih _ (by omega)

/-- On exact powers the halving law is exact: `k` queries divide a window of
`2 ^ m` candidates by exactly `2 ^ k`. -/
lemma halfIter_pow : ∀ (k m : ℕ), k ≤ m → halfIter k (2 ^ m) = 2 ^ (m - k) := by
  intro k
  induction k with
  | zero => intro m _; simp [halfIter]
  | succ k ih =>
      intro m hm
      obtain ⟨m', rfl⟩ : ∃ m', m = m' + 1 := ⟨m - 1, by omega⟩
      have hpow : (2 : ℕ) ^ (m' + 1) = 2 * 2 ^ m' := by ring
      have : (2 ^ (m' + 1) + 1) / 2 = 2 ^ m' := by omega
      rw [halfIter, this, ih m' (by omega)]
      congr 1
      omega

/-! ## The adaptive (bisection) arm -/

/-- The adaptive arm: `k` bisection queries against the truthful oracle for the
hidden value `x`. -/
def bisect (x : ℕ) : ℕ → Window → Window
  | 0, I => I
  | (k + 1), I => bisect x k (I.step (decide (x ≤ I.mid)))

/-- The hidden value stays in the window: the adaptive arm is sound. -/
theorem bisect_mem (x : ℕ) : ∀ (k : ℕ) (I : Window), x ∈ I.carrier →
    x ∈ (bisect x k I).carrier := by
  intro k
  induction k with
  | zero => intro I h; simpa [bisect] using h
  | succ k ih => intro I h; exact ih _ (Window.mem_step h)

/-- **Geometric compounding.**  After `k` adaptive queries the residual window
has width at most `⌈w / 2 ^ k⌉`: each query halves the uncertainty, so the
speedups multiply instead of adding. -/
theorem bisect_width_le (x : ℕ) : ∀ (k : ℕ) (I : Window), x ∈ I.carrier →
    (bisect x k I).width ≤ halfIter k I.width := by
  intro k
  induction k with
  | zero => intro I _; simp [bisect, halfIter]
  | succ k ih =>
      intro I h
      have hw : 0 < I.width := by
        rw [Window.carrier, mem_Ico] at h
        simp only [Window.width]; omega
      have hstep := Window.step_width_le I (decide (x ≤ I.mid)) hw
      calc (bisect x (k + 1) I).width
          = (bisect x k (I.step (decide (x ≤ I.mid)))).width := rfl
        _ ≤ halfIter k (I.step (decide (x ≤ I.mid))).width := ih _ (Window.mem_step h)
        _ ≤ halfIter k ((I.width + 1) / 2) := halfIter_mono k hstep
        _ = halfIter (k + 1) I.width := rfl

/-- **Saturation at the isolation ceiling.**  As soon as `k ≥ log₂ w`, the
adaptive arm has pinned the hidden value exactly: the residual window is the
singleton `{x}`.  Further queries buy nothing, so the speedup curve is flat at
its maximum from `k = ⌈log₂ w⌉` on. -/
theorem bisection_isolates (x : ℕ) (k : ℕ) (I : Window) (hx : x ∈ I.carrier)
    (hk : I.width ≤ 2 ^ k) : (bisect x k I).carrier = {x} := by
  have hmem := bisect_mem x k I hx
  have hw : (bisect x k I).width ≤ 1 :=
    le_trans (bisect_width_le x k I hx) (halfIter_le_one k I.width hk)
  set J := bisect x k I with hJ
  rw [Window.carrier, mem_Ico] at hmem
  have hwidth : J.width = J.hi - J.lo := rfl
  have hxlo : x = J.lo := by omega
  have hhi : J.hi = J.lo + 1 := by omega
  ext y
  simp only [Window.carrier, mem_Ico, mem_singleton]
  omega

/-! ## The ledger catch: the upper median stalls -/

/-- The naive step, querying the **upper** median `lo + w / 2`. -/
def stepUp (I : Window) (b : Bool) : Window :=
  if b then ⟨I.lo, I.lo + I.width / 2 + 1⟩ else ⟨I.lo + I.width / 2 + 1, I.hi⟩

/-- The naive adaptive arm built from `stepUp`. -/
def bisectUp (x : ℕ) : ℕ → Window → Window
  | 0, I => I
  | (k + 1), I => bisectUp x k (stepUp I (decide (x ≤ I.lo + I.width / 2)))

/-- **The even-median stall (ledger catch).**  On the width-`2` window `[0, 2)`
with hidden value `0`, the upper-median rule returns the *same* window forever:
no number of adaptive queries makes any progress.  The lower-median convention
of `Window.step` is exactly the fix. -/
theorem naive_upper_median_stalls : ∀ k : ℕ, bisectUp 0 k ⟨0, 2⟩ = ⟨0, 2⟩ := by
  intro k
  induction k with
  | zero => rfl
  | succ k ih =>
      have hstep : stepUp ⟨0, 2⟩ (decide ((0 : ℕ) ≤ 0 + (Window.width ⟨0, 2⟩) / 2)) = ⟨0, 2⟩ := by
        rfl
      rw [bisectUp, hstep, ih]

/-! ## The isolation ceiling for *arbitrary* adaptive strategies -/

/-- An adaptive strategy: the next threshold as a function of the answers so
far. -/
def Strategy := List Bool → ℕ

/-- The transcript of `k` adaptive queries against the hidden value `x`. -/
def transcript (S : Strategy) (x : ℕ) : ℕ → List Bool
  | 0 => []
  | (k + 1) => (transcript S x k) ++ [decide (x ≤ S (transcript S x k))]

/-- A `k`-query adaptive strategy has at most `2 ^ k` transcripts: each query
carries one bit, and adaptivity does not create bits. -/
theorem card_image_transcript_le (S : Strategy) (W : Finset ℕ) :
    ∀ k : ℕ, (W.image (fun x => transcript S x k)).card ≤ 2 ^ k := by
  intro k
  induction k with
  | zero =>
      simp only [transcript, pow_zero]
      exact card_le_one.2 (by intro a ha b hb; simp_all)
  | succ k ih =>
      have hsub : W.image (fun x => transcript S x (k + 1)) ⊆
          (W.image (fun x => transcript S x k)).biUnion
            (fun l => {l ++ [false], l ++ [true]}) := by
        intro l hl
        rw [mem_image] at hl
        obtain ⟨x, hx, rfl⟩ := hl
        rw [mem_biUnion]
        refine ⟨transcript S x k, mem_image_of_mem _ hx, ?_⟩
        rcases Bool.eq_false_or_eq_true (decide (x ≤ S (transcript S x k))) with hb | hb <;>
          simp [transcript, hb]
      calc (W.image (fun x => transcript S x (k + 1))).card
          ≤ ((W.image (fun x => transcript S x k)).biUnion
              (fun l => {l ++ [false], l ++ [true]})).card := card_le_card hsub
        _ ≤ ∑ _l ∈ W.image (fun x => transcript S x k), 2 := by
              refine le_trans (card_biUnion_le) (sum_le_sum ?_)
              intro l _
              exact le_trans (card_insert_le _ _) (by simp)
        _ = 2 * (W.image (fun x => transcript S x k)).card := by
              rw [sum_const, smul_eq_mul, mul_comm]
        _ ≤ 2 * 2 ^ k := Nat.mul_le_mul_left 2 ih
        _ = 2 ^ (k + 1) := by ring

/-- **The isolation ceiling (barrier pricing).**  No adaptive strategy, however
clever, can isolate the hidden value with fewer than `⌈log₂ #W⌉` queries: if
`2 ^ k < #W` there are two distinct candidates with identical transcripts, so
the external channel really is worth exactly one bit per query. -/
theorem isolation_ceiling (S : Strategy) (W : Finset ℕ) (k : ℕ) (hk : 2 ^ k < W.card) :
    ∃ x ∈ W, ∃ y ∈ W, x ≠ y ∧ transcript S x k = transcript S y k := by
  refine Finset.exists_ne_map_eq_of_card_lt_of_maps_to
    (t := W.image (fun x => transcript S x k))
    (lt_of_le_of_lt (card_image_transcript_le S W k) hk) ?_
  intro x hx
  exact mem_coe.2 (mem_image_of_mem _ hx)

/-- The two bounds meet: on a window of `2 ^ m` candidates, bisection isolates
with `m` queries and **no** strategy isolates with fewer.  The saturation point
of the speedup curve is exactly `k = ⌈log₂ W⌉`. -/
theorem ceiling_is_exact (m : ℕ) :
    (∀ x ∈ (Window.mk 0 (2 ^ m)).carrier, (bisect x m ⟨0, 2 ^ m⟩).carrier = {x}) ∧
    (∀ S : Strategy, ∀ k < m, ∃ x ∈ (Window.mk 0 (2 ^ m)).carrier,
        ∃ y ∈ (Window.mk 0 (2 ^ m)).carrier, x ≠ y ∧ transcript S x k = transcript S y k) := by
  constructor
  · intro x hx
    exact bisection_isolates x m ⟨0, 2 ^ m⟩ hx (by simp [Window.width])
  · intro S k hk
    refine isolation_ceiling S _ k ?_
    have hcard : ((Window.mk 0 (2 ^ m)).carrier).card = 2 ^ m := by
      simp [Window.carrier]
    rw [hcard]
    exact Nat.pow_lt_pow_right (by norm_num) hk

/-! ## The adaptivity premium `r(k) = 2 ^ k / (k + 1)` -/

/-- The **adaptivity premium**: the ratio of the geometric adaptive speedup
`2 ^ k` to the linear fixed-battery ceiling `k + 1`. -/
def premium (k : ℕ) : ℚ := 2 ^ k / (k + 1)

@[simp] lemma premium_zero : premium 0 = 1 := by norm_num [premium]

/-- `r(1) = 1.00 EXACTLY`: with a single query there is nothing to adapt to, so
adaptivity buys precisely nothing. -/
@[simp] lemma premium_one : premium 1 = 1 := by norm_num [premium]

lemma premium_pos (k : ℕ) : 0 < premium k := by
  unfold premium
  positivity

/-- From the second query on, the premium **strictly** increases: this is the
compounding effect. -/
theorem premium_strict_mono (k : ℕ) (hk : 1 ≤ k) : premium k < premium (k + 1) := by
  unfold premium
  rw [div_lt_div_iff₀ (by positivity) (by positivity)]
  have hk' : (1 : ℚ) ≤ (k : ℚ) := by exact_mod_cast hk
  have h2 : (2 : ℚ) ^ (k + 1) = 2 * 2 ^ k := by ring
  push_cast
  rw [h2]
  nlinarith [pow_pos (show (0:ℚ) < 2 by norm_num) k, hk']

/-- The premium outgrows every linear function: `2 ^ k ≥ k (k + 1)` for
`k ≥ 5`, i.e. `r(k) ≥ k`.  Fixed batteries pay linearly, adaptive hints pay
geometrically, and the gap itself is superlinear. -/
theorem premium_superlinear : ∀ k : ℕ, 5 ≤ k → (k : ℚ) ≤ premium k := by
  have key : ∀ k : ℕ, 5 ≤ k → k * (k + 1) ≤ 2 ^ k := by
    intro k hk
    induction k with
    | zero => omega
    | succ n ih =>
        rcases Nat.lt_or_ge n 5 with hn | hn
        · interval_cases n <;> simp_all
        · have hn' := ih (by omega)
          have h2 : 2 ^ (n + 1) = 2 * 2 ^ n := by ring
          nlinarith
  intro k hk
  have hkey := key k hk
  have hcast : (k : ℚ) * (k + 1) ≤ 2 ^ k := by exact_mod_cast hkey
  unfold premium
  rw [le_div_iff₀ (by positivity)]
  exact hcast

/-- Consistency with the measurement: the premium observed at `k = 12`
(`239.5×`, CI `[220.1, 261.0]`) lies below the idealized ceiling
`r(12) = 4096 / 13 ≈ 315.08`. -/
theorem premium_twelve_ge_measured : (2395 : ℚ) / 10 ≤ premium 12 := by
  norm_num [premium]

/-- **Compounding beats linear pricing, quantitatively.**  On a window of
`2 ^ m` candidates the adaptive residual shrinks by a factor `2 ^ 9 = 512`
between `k = 3` and `k = 12`, whereas the fixed-battery bound only improves by a
factor `13 / 4 = 3.25`.  (Linear pricing would predict `4`.) -/
theorem compounding_beats_linear (m : ℕ) (hm : 12 ≤ m) :
    halfIter 3 (2 ^ m) = 2 ^ 9 * halfIter 12 (2 ^ m) ∧ premium 12 / premium 3 = 512 / (13 / 4) := by
  constructor
  · rw [halfIter_pow 3 m (by omega), halfIter_pow 12 m (by omega), ← pow_add]
    congr 1
    omega
  · norm_num [premium]

end Pythagorean.SeqHint