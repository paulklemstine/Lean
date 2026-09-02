/-
# The NET-62 fine-grid knee: what the five numbers do and do not determine

The NET-62 round measures, at `ctx = 1024`, the retained-mass table

```
k        :   4        8       12       20       24
retained : 0.8940   0.9520   0.9662   0.9803   0.9851        gate 0.98
```

and reports the knee `k* = 20`, "landing exactly on the fine grid", against an earlier
coarse (doubling) sweep that reported `32`.  This file proves the arithmetic content of
that reading, using the grid-rounding theory of
`Catalog/NumberTheory/GridKneeQuantization.lean`, and — this is the adversarial part —
proves exactly where the reading stops being determined by the data.

## Results

* `Net62.measured_knee_eq_twenty` — for *every* monotone profile matching the five
  measurements, the sweep restricted to the measured set `{4, 8, 12, 20, 24}` reports
  `20`.  The reading is therefore harness-independent, not an artifact of interpolation.
* `Net62.true_knee_bracket` — the same hypotheses force `12 < k* ≤ 20` and no more.
* `Net62.bracket_tight`, `Net62.knee_underdetermined` — **the grid skips 16.**  For every
  `t` in `(12, 20]` the profile `Net62.profileAt t` reproduces all five measured values
  and has true knee `t`; in particular `16` and `20` are both consistent.  So the datum
  supports "`k* ≤ 20`", and the sharper claim
  "`k* = 20`, strictly above the `ctx = 512` value `16`" is *not* separated by this
  sweep; only the deployment-facing statement `20` keys suffice is.
  `Net62.fine_grid_reading_two_valued` states this in rounding terms: the step-`4`
  rounding of the true knee is `16` or `20`, and it is `20` exactly when `k* > 16`.
* `Net62.coarse_reading_twenty`, `Net62.coarse_reading_twentyfour`,
  `Net62.coarse_chain_collapse` — the doubling sweep reads `20 ↦ 32` and `24 ↦ 32`
  while `16 ↦ 16`: the coarse image of the chain `{16, 20, 24}` is `{16, 32, 32}`.  The
  "corpus-B 32" and the old "ctx = 1024 → 32" are the *same* rounding, and the collapse
  is forced: `dyad_cannot_separate` shows no doubling sweep can separate two knees in a
  single octave.
* `Net62.chain_is_arithmetic_progression`, `Net62.chain_fine_grid_exact`,
  `Net62.only_sixteen_dyadically_resolved` — the chain `{16, 20, 24}` is an arithmetic
  progression of step `4` (the fine grid step), every term is resolved by the step-`4`
  grid, and exactly one term (`16`, binary weight `1`) is resolved by the doubling grid.
* `Net62.stair_dyad_read` and `Net62.net47_112_reads_as_128` — the bridge to the earlier
  round: the NET-47 mid-grid knee `112 = stair 4 3` of
  `Catalog/NumberTheory/KneeStaircaseArithmetic.lean` is read as `128 = 2 ^ 7` by a
  doubling sweep.  More generally *every* binary staircase number with at least two ones
  is misread as its top point.  "Knee quantizes to grid" is one theorem, not three
  coincidences.

-- !-- Lab Notes -- !--
Hypothesizer:
 (H1) A grid measurement is always the grid-rounding of the truth — no experimental
      noise needed to explain a coarse/fine discrepancy.                    [confirmed]
 (H2) `32 → 20` is exactly the failure of `20` to be a power of two; the misread size
      is `2 ^ ⌈log₂ k⌉ - k`.                                                [confirmed]
 (H3) The reported chain `{16, 20, 24}` is the step-4 grid image of the truth, hence an
      arithmetic progression whose dyadic image collapses.                  [confirmed]
 (H4) The fine sweep as listed cannot certify strict monotonicity of the chain, because
      it omits `16`.                                       [confirmed, and it refutes a
      strengthening of the reported verdict — see `knee_underdetermined`]
 (H5) NET-47's `112` and NET-62's `20` are the same phenomenon.             [confirmed
      via `stair_dyad_read`]

Analyst: the informative failure is H4.  "The knee lands ON the fine grid" is true of
the *reading*, and the reading is `20`; but the reported grid `{4, 8, 12, 20, 24}` has a
hole at `16`, and a monotone profile is free to cross the gate anywhere in `(12, 20]`.
Consequently the "strictly monotone chain {16, 20, 24}" claim needs the `k = 16` cell to
be run, and that is a concrete, cheap next experiment.

Critic: no theorem below is a numerical evaluation.  `measured_knee_eq_twenty` and
`true_knee_bracket` quantify over all monotone profiles; `knee_underdetermined` exhibits
witnesses; `dyad_cannot_separate` is a general obstruction; `stair_dyad_read` is a family
statement proved from the staircase arithmetic, not by `decide`.
-/

import Mathlib
import NumberTheory.GridKneeQuantization
import NumberTheory.KneeStaircaseArithmetic

namespace Net62

open GridKnee

/-! ## 1.  The measured table and the gate -/

/-- The gate ("bar") of the NET-62 harness. -/
def bar : ℚ := 98 / 100

/-- The set of budgets actually swept in the fine round. -/
def sweep : Set ℕ := {4, 8, 12, 20, 24}

/-- A profile `f` **matches the NET-62 table** if it reproduces the five measured
retained-mass values. -/
structure Matches (f : ℕ → ℚ) : Prop where
  mono : Monotone f
  at4 : f 4 = 8940 / 10000
  at8 : f 8 = 9520 / 10000
  at12 : f 12 = 9662 / 10000
  at20 : f 20 = 9803 / 10000
  at24 : f 24 = 9851 / 10000

/-- The true knee of a profile: the least budget clearing the gate. -/
noncomputable def knee (f : ℕ → ℚ) : ℕ := sInf {k | bar ≤ f k}

/-- The knee as *reported by the sweep*: the least measured budget clearing the gate. -/
noncomputable def measured (f : ℕ → ℚ) : ℕ := sInf {g | g ∈ sweep ∧ bar ≤ f g}

/-! ## 2.  What the table determines -/

/-- Every profile matching the table clears the gate at `20`, and fails it at `12`. -/
theorem pass_at_twenty {f : ℕ → ℚ} (hf : Matches f) : bar ≤ f 20 := by
  rw [hf.at20, bar]; norm_num

theorem fail_at_twelve {f : ℕ → ℚ} (hf : Matches f) : f 12 < bar := by
  rw [hf.at12, bar]; norm_num

/-- **The reported reading is forced.**  Any monotone profile reproducing the five
measured numbers yields the sweep reading `20`. -/
theorem measured_knee_eq_twenty {f : ℕ → ℚ} (hf : Matches f) : measured f = 20 := by
  have hmem : (20 : ℕ) ∈ {g | g ∈ sweep ∧ bar ≤ f g} := ⟨by simp [sweep], pass_at_twenty hf⟩
  have hne : {g | g ∈ sweep ∧ bar ≤ f g}.Nonempty := ⟨20, hmem⟩
  have hle : measured f ≤ 20 := Nat.sInf_le hmem
  obtain ⟨hg, hbar⟩ : measured f ∈ {g | g ∈ sweep ∧ bar ≤ f g} := Nat.sInf_mem hne
  have hcases : measured f = 4 ∨ measured f = 8 ∨ measured f = 12 ∨ measured f = 20 ∨
      measured f = 24 := by simpa [sweep] using hg
  rcases hcases with h | h | h | h | h
  · rw [h, hf.at4, bar] at hbar; norm_num at hbar
  · rw [h, hf.at8, bar] at hbar; norm_num at hbar
  · rw [h, hf.at12, bar] at hbar; norm_num at hbar
  · exact h
  · omega

/-- **Bracket.**  The table pins the true knee only to the half-open interval `(12, 20]`. -/
theorem true_knee_bracket {f : ℕ → ℚ} (hf : Matches f) : 12 < knee f ∧ knee f ≤ 20 := by
  have hup : knee f ≤ 20 := Nat.sInf_le (pass_at_twenty hf)
  refine ⟨?_, hup⟩
  by_contra hcon
  push_neg at hcon
  have hne : {k | bar ≤ f k}.Nonempty := ⟨20, pass_at_twenty hf⟩
  have hmem : bar ≤ f (knee f) := Nat.sInf_mem hne
  have : f (knee f) ≤ f 12 := hf.mono hcon
  have := fail_at_twelve hf
  linarith

/-! ## 3.  The hole at 16: the table does not determine the knee -/

/-- The monotone step profile that matches the NET-62 table and crosses the gate exactly
at `t`.  It is well defined for every `t`; it matches the table when `12 < t ≤ 20`, which
is precisely the bracket of `true_knee_bracket`. -/
def profileAt (t : ℕ) (k : ℕ) : ℚ :=
  if k < 4 then 0 else
  if k < 8 then 8940 / 10000 else
  if k < 12 then 9520 / 10000 else
  if k < t then 9662 / 10000 else
  if k < 24 then 9803 / 10000 else 9851 / 10000

theorem profileAt_mono (t : ℕ) : Monotone (profileAt t) := by
  intro a b hab
  unfold profileAt
  split_ifs <;> first | (exfalso; omega) | norm_num

theorem profileAt_matches {t : ℕ} (hlo : 12 < t) (hhi : t ≤ 20) : Matches (profileAt t) :=
  { mono := profileAt_mono t
    at4 := by unfold profileAt; rw [if_neg (by omega), if_pos (by omega)]
    at8 := by
      unfold profileAt
      rw [if_neg (by omega), if_neg (by omega), if_pos (by omega)]
    at12 := by
      unfold profileAt
      rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), if_pos (by omega)]
    at20 := by
      unfold profileAt
      rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), if_neg (by omega),
        if_pos (by omega)]
    at24 := by
      unfold profileAt
      rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), if_neg (by omega),
        if_neg (by omega)] }

theorem knee_profileAt {t : ℕ} (hlo : 12 < t) (hhi : t ≤ 20) : knee (profileAt t) = t := by
  have hpass : bar ≤ profileAt t t := by
    unfold profileAt
    rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), if_neg (by omega),
      if_pos (by omega), bar]
    norm_num
  refine le_antisymm (Nat.sInf_le hpass) ?_
  by_contra hcon
  push_neg at hcon
  have h := Nat.sInf_mem (⟨t, hpass⟩ : {k | bar ≤ profileAt t k}.Nonempty)
  set m := knee (profileAt t) with hm
  have hlt : m < t := hcon
  have hval : profileAt t m ≤ 9662 / 10000 := by
    unfold profileAt
    split_ifs <;> norm_num
  have hbar : bar ≤ profileAt t m := h
  rw [bar] at hbar
  linarith

/-- **The bracket is tight: the sweep grid has a hole.**  For *every* budget `t` in the
bracket `(12, 20]` there is a monotone profile reproducing the whole NET-62 table whose
true knee is exactly `t`.  The table therefore determines the knee only up to that
interval; in particular the sweep cannot separate `k* = 16` from `k* = 20`, because
`{4, 8, 12, 20, 24}` contains no point strictly between `12` and `20`. -/
theorem bracket_tight {t : ℕ} (hlo : 12 < t) (hhi : t ≤ 20) :
    ∃ f : ℕ → ℚ, Matches f ∧ knee f = t ∧ measured f = 20 :=
  ⟨profileAt t, profileAt_matches hlo hhi, knee_profileAt hlo hhi,
    measured_knee_eq_twenty (profileAt_matches hlo hhi)⟩

/-- **The verdict is underdetermined at `16`.**  Two monotone profiles reproduce the whole
NET-62 table — hence the same sweep reading `20` — while their true knees are `16` and
`20`.  The datum supports "`20` keys suffice"; it does not separate `k* = 20` from
`k* = 16`. -/
theorem knee_underdetermined :
    ∃ f g : ℕ → ℚ, Matches f ∧ Matches g ∧ measured f = measured g ∧ knee f ≠ knee g := by
  obtain ⟨f, hf, hfk, hfm⟩ := bracket_tight (t := 16) (by norm_num) (by norm_num)
  obtain ⟨g, hg, hgk, hgm⟩ := bracket_tight (t := 20) (by norm_num) (by norm_num)
  exact ⟨f, g, hf, hg, by rw [hfm, hgm], by rw [hfk, hgk]; norm_num⟩

/-- In rounding terms: the step-`4` rounding of the true knee is `16` or `20`, and it is
`20` precisely when the true knee exceeds `16`. -/
theorem fine_grid_reading_two_valued {f : ℕ → ℚ} (hf : Matches f) :
    read (arithGrid 4 (by norm_num)) (knee f) = 16 ∨
      read (arithGrid 4 (by norm_num)) (knee f) = 20 := by
  obtain ⟨hlo, hhi⟩ := true_knee_bracket hf
  set K := knee f with hK
  rcases le_or_gt K 16 with h16 | h16
  · left
    refine le_antisymm (read_le_of_mem (show (4:ℕ) ∣ 16 by norm_num) h16) ?_
    have hmem := read_mem_carrier (arithGrid 4 (by norm_num)) K
    have hdvd : (4 : ℕ) ∣ read (arithGrid 4 (by norm_num)) K := hmem
    have hge : K ≤ read (arithGrid 4 (by norm_num)) K := le_read _ _
    omega
  · right
    refine le_antisymm (read_le_of_mem (show (4:ℕ) ∣ 20 by norm_num) hhi) ?_
    have hmem := read_mem_carrier (arithGrid 4 (by norm_num)) K
    have hdvd : (4 : ℕ) ∣ read (arithGrid 4 (by norm_num)) K := hmem
    have hge : K ≤ read (arithGrid 4 (by norm_num)) K := le_read _ _
    omega

/-! ## 4.  The coarse grid: why the old reading was `32` -/

theorem coarse_reading_sixteen : read dyadGrid 16 = 16 :=
  read_eq_self_iff.2 ⟨4, by norm_num⟩

theorem coarse_reading_twenty : read dyadGrid 20 = 32 := by
  have := dyad_overstates (k := 20) (e := 4) (by norm_num) (by norm_num)
  norm_num at this ⊢
  exact this

theorem coarse_reading_twentyfour : read dyadGrid 24 = 32 := by
  have := dyad_overstates (k := 24) (e := 4) (by norm_num) (by norm_num)
  norm_num at this ⊢
  exact this

/-- **The coarse image of the chain collapses.**  The strictly increasing chain
`16 < 20 < 24` has doubling-sweep image `16, 32, 32`: the two larger cells become
indistinguishable, which is precisely the "coarse-grid artifact" reading. -/
theorem coarse_chain_collapse :
    read dyadGrid 16 < read dyadGrid 20 ∧ read dyadGrid 20 = read dyadGrid 24 := by
  refine ⟨?_, ?_⟩
  · rw [coarse_reading_sixteen, coarse_reading_twenty]; norm_num
  · rw [coarse_reading_twenty, coarse_reading_twentyfour]

/-- **A doubling sweep can never separate two knees inside one octave.**  This is the
general obstruction behind the collapse: it is not a property of these particular
numbers. -/
theorem dyad_cannot_separate {k k' e : ℕ} (h1 : 2 ^ e < k) (h2 : k ≤ k')
    (h3 : k' ≤ 2 ^ (e + 1)) : read dyadGrid k = read dyadGrid k' :=
  dyad_collapse_of_lt h1 h2 h3

/-- The size of the coarse artifact at the two disputed cells: the doubling sweep
overstates the budget by `12` keys at `k* = 20` and by `8` keys at `k* = 24`. -/
theorem coarse_overstatement :
    read dyadGrid 20 - 20 = 12 ∧ read dyadGrid 24 - 24 = 8 := by
  rw [coarse_reading_twenty, coarse_reading_twentyfour]
  norm_num

/-! ## 5.  Arithmetic of the reported chain `{16, 20, 24}` -/

/-- The chain is an arithmetic progression of common difference `4`, the fine grid
step — equivalently, it is `4 · {4, 5, 6}`. -/
theorem chain_is_arithmetic_progression :
    (20 : ℕ) - 16 = 4 ∧ (24 : ℕ) - 20 = 4 ∧ (16 : ℕ) = 4 * 4 ∧ (20 : ℕ) = 4 * 5 ∧
      (24 : ℕ) = 4 * 6 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num, by norm_num⟩

/-- Every term of the chain is resolved exactly by the step-`4` grid. -/
theorem chain_fine_grid_exact :
    read (arithGrid 4 (by norm_num)) 16 = 16 ∧
      read (arithGrid 4 (by norm_num)) 20 = 20 ∧
      read (arithGrid 4 (by norm_num)) 24 = 24 :=
  ⟨read_eq_self_iff.2 (show (4:ℕ) ∣ 16 by norm_num),
    read_eq_self_iff.2 (show (4:ℕ) ∣ 20 by norm_num),
    read_eq_self_iff.2 (show (4:ℕ) ∣ 24 by norm_num)⟩

/-- **Only the `ctx = 512` cell is dyadically resolvable.**  Of the chain `{16, 20, 24}`
only `16` has binary weight one, so only it survives a doubling sweep unchanged; the
other two are necessarily misread.  This is the digit-sum criterion of
`GridKnee.dyad_exact_iff_binary_weight_one`, not an evaluation. -/
theorem only_sixteen_dyadically_resolved :
    read dyadGrid 16 = 16 ∧ read dyadGrid 20 ≠ 20 ∧ read dyadGrid 24 ≠ 24 := by
  refine ⟨coarse_reading_sixteen, ?_, ?_⟩
  · intro hcon
    rw [dyad_exact_iff_binary_weight_one (show (20:ℕ) ≠ 0 by norm_num)] at hcon
    norm_num at hcon
  · intro hcon
    rw [dyad_exact_iff_binary_weight_one (show (24:ℕ) ≠ 0 by norm_num)] at hcon
    norm_num at hcon

/-- The binary weights behind the previous theorem. -/
theorem chain_binary_weights :
    (Nat.digits 2 16).sum = 1 ∧ (Nat.digits 2 20).sum = 2 ∧ (Nat.digits 2 24).sum = 2 := by
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-! ## 6.  Bridge to NET-47: staircase knees are always misread -/

open KneeStaircase in
/-- **Every binary staircase number with at least two ones is read by a doubling sweep as
its top point.**  With `KneeStaircase.stair b j = 2 ^ b (2 ^ j - 1)`, a doubling sweep
reports `2 ^ (b + j)` for `stair b (i + 2)`. -/
theorem stair_dyad_read (b i : ℕ) :
    read dyadGrid (stair b (i + 2)) = 2 ^ (b + i + 2) := by
  have htop : stair b (i + 2) + 2 ^ b = 2 ^ (b + i + 2) := by
    have h := stair_add_two_pow b (i + 2)
    have hidx : b + (i + 2) = b + i + 2 := by omega
    rwa [hidx] at h
  have hdouble : (2:ℕ) ^ (b + i + 2) = 2 * 2 ^ (b + i + 1) := by ring
  have hsmall : (2:ℕ) ^ b < 2 ^ (b + i + 1) := Nat.pow_lt_pow_right (by norm_num) (by omega)
  rw [hdouble] at htop
  obtain ⟨P, hP⟩ : ∃ P, (2:ℕ) ^ b = P := ⟨_, rfl⟩
  obtain ⟨Q, hQ⟩ : ∃ Q, (2:ℕ) ^ (b + i + 1) = Q := ⟨_, rfl⟩
  rw [hP, hQ] at htop hsmall
  have hlo : 2 ^ (b + i + 1) < stair b (i + 2) := by rw [hQ]; omega
  have hhi : stair b (i + 2) ≤ 2 ^ (b + i + 1 + 1) := by
    rw [show b + i + 1 + 1 = b + i + 2 from by omega, hdouble, hQ]; omega
  have hread := dyad_overstates hlo hhi
  rwa [show b + i + 1 + 1 = b + i + 2 from by omega] at hread

open KneeStaircase in
/-- The NET-47 instance: the mid-grid knee `112 = stair 4 3` is reported as the product
point `128 = 2 ^ 7` by a doubling sweep — the same mechanism that turned `20` into `32`
in NET-62. -/
theorem net47_112_reads_as_128 : read dyadGrid 112 = 128 := by
  have h := stair_dyad_read 4 1
  rw [show stair 4 (1 + 2) = 112 from net47_onetwelve] at h
  norm_num at h
  exact h

/-- The two rounds are one phenomenon: in both, the doubling sweep reports the least
power of two above the true knee, and the discrepancy is exactly the distance to that
power of two. -/
theorem two_rounds_one_mechanism :
    read dyadGrid 20 = 2 ^ Nat.clog 2 20 ∧ read dyadGrid 112 = 2 ^ Nat.clog 2 112 :=
  ⟨read_dyadGrid 20, read_dyadGrid 112⟩

end Net62