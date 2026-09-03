import Mathlib

/-!
# BKEY-MIXED-ZONE I: a gradualness calculus for two-dial grids

## Research context (FACT round-55 #1, exp 523, `BALANCED-BKEY`, paper 182 addendum)

Experiment 523 sweeps the zero-fit `T`-dial over a full `4 × 3` grid of *bit length* `b`
and *cap* `u`, and records a Spearman correlation `sp(T)` that ranges over `0.53 – 0.79`
and declines **smoothly and monotonically in both variables**.  The verdict of the round is
`BKEY-MIXED-ZONE`: the decline is *gradual*, there is **no cliff**, **no threshold effect**
and **no convention artifact**; in particular paper 178's "practical floor at bitlen ≈ 54"
is a gradual transition rather than a sharp edge.

This file supplies the mathematics needed to make the words "gradual", "cliff" and
"threshold" precise, for an *arbitrary* two-dial grid `F : ℕ → ℕ → ℚ`.  The companion file
`Combinatorics.BKeyMixedZoneGridLaw` instantiates the calculus on the exact tie-ceiling
grid of `Cryptography.BalancedBKeyDialRobustness` and on the recorded `4 × 3` envelope.

## Main results

* `stairSteps`, `stair_telescope` — the **staircase decomposition**: the total decline of a
  grid between two corners is the sum of the `m + n` single-notch declines along any
  monotone staircase joining them.  (Exactly `m` row notches and `n` column notches.)
* `sum_le_card_pos`, `spread_card_lower_bound` — the **spreading law**: if every notch
  declines by at most `ε`, the total decline `R` is carried by at least `R / ε` notches.
  This is the formal content of "gradual, not a cliff".
* `no_notch_carries_all`, `cliff_needs_big_notch` — a cliff (a single notch carrying the
  whole decline) is *impossible* once `ε < R`; conversely, a cliff forces a notch of size
  at least the whole range.
* `Separable`, `separable_rank_one`, `separable_rowStep_bound`,
  `separable_colStep_bound` — separable (rank-one) grids have **no interaction term**, and
  their notch sizes are controlled by the notch sizes of the two one-dimensional factors.
* `perturbed_rowStep_bound`, `perturbed_colStep_bound`,
  `perturbed_no_cliff` — the **transfer theorem**: a grid that is uniformly `δ`-close to an
  `ε`-gradual grid is `(ε + 2δ)`-gradual.  Approximate separability already excludes cliffs.
* `geometric_lower`, `slow_descent`, `crossing_no_jump`, `crossing_relative_overshoot` —
  the **no-sharp-edge law** for geometrically decaying dials: a sequence whose successive
  ratios are at least `r` cannot jump past a floor `τ`; the first value below `τ` is still
  at least `r·τ`, and the descent from `A` to `τ` needs at least `j` notches whenever
  `r ^ j · A > τ`.
* `cliff_example`, `cliff_example_has_cliff` — a genuine cliff grid, proving the
  hypotheses above are not vacuous.
-/

namespace Catalog.Combinatorics.BKeyMixedZoneGradualDecline

/-! ## 1. Notches and the staircase decomposition -/

/-- The decline of the grid `F` when the *row* dial (bit length) advances one notch. -/
def rowStep (F : ℕ → ℕ → ℚ) (b u : ℕ) : ℚ := F b u - F (b + 1) u

/-- The decline of the grid `F` when the *column* dial (cap `u`) advances one notch. -/
def colStep (F : ℕ → ℕ → ℚ) (b u : ℕ) : ℚ := F b u - F b (u + 1)

/-- The list of single-notch declines along the monotone staircase that first advances the
row dial `m` times at column `u₀`, then advances the column dial `n` times at row `b₀ + m`. -/
def stairSteps (F : ℕ → ℕ → ℚ) (b₀ u₀ m n : ℕ) : List ℚ :=
  ((List.range m).map fun i => rowStep F (b₀ + i) u₀) ++
    ((List.range n).map fun j => colStep F (b₀ + m) (u₀ + j))

lemma rowRun_telescope (F : ℕ → ℕ → ℚ) (b₀ u₀ : ℕ) :
    ∀ m : ℕ, (((List.range m).map fun i => rowStep F (b₀ + i) u₀).sum)
      = F b₀ u₀ - F (b₀ + m) u₀ := by
  intro m
  induction m with
  | zero => simp
  | succ k ih =>
      rw [List.range_succ, List.map_append, List.sum_append, ih]
      have hb : b₀ + (k + 1) = (b₀ + k) + 1 := by omega
      simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, rowStep, hb]
      ring

lemma colRun_telescope (F : ℕ → ℕ → ℚ) (b u₀ : ℕ) :
    ∀ n : ℕ, (((List.range n).map fun j => colStep F b (u₀ + j)).sum)
      = F b u₀ - F b (u₀ + n) := by
  intro n
  induction n with
  | zero => simp
  | succ k ih =>
      rw [List.range_succ, List.map_append, List.sum_append, ih]
      have hu : u₀ + (k + 1) = (u₀ + k) + 1 := by omega
      simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, colStep, hu]
      ring

/-- **Staircase decomposition.**  The total decline of the grid between the corners
`(b₀, u₀)` and `(b₀ + m, u₀ + n)` is exactly the sum of the `m + n` single-notch declines
along the staircase. -/
theorem stair_telescope (F : ℕ → ℕ → ℚ) (b₀ u₀ m n : ℕ) :
    (stairSteps F b₀ u₀ m n).sum = F b₀ u₀ - F (b₀ + m) (u₀ + n) := by
  rw [stairSteps, List.sum_append, rowRun_telescope, colRun_telescope]
  ring

@[simp] lemma stairSteps_length (F : ℕ → ℕ → ℚ) (b₀ u₀ m n : ℕ) :
    (stairSteps F b₀ u₀ m n).length = m + n := by
  simp [stairSteps]

/-- Membership in the staircase: every entry is a row notch or a column notch. -/
lemma mem_stairSteps {F : ℕ → ℕ → ℚ} {b₀ u₀ m n : ℕ} {x : ℚ}
    (hx : x ∈ stairSteps F b₀ u₀ m n) :
    (∃ i < m, x = rowStep F (b₀ + i) u₀) ∨ (∃ j < n, x = colStep F (b₀ + m) (u₀ + j)) := by
  rw [stairSteps, List.mem_append] at hx
  rcases hx with h | h
  · obtain ⟨i, hi, hx⟩ := List.mem_map.mp h
    exact Or.inl ⟨i, List.mem_range.mp hi, hx.symm⟩
  · obtain ⟨j, hj, hx⟩ := List.mem_map.mp h
    exact Or.inr ⟨j, List.mem_range.mp hj, hx.symm⟩

/-! ## 2. The spreading law: a bounded notch forces many notches -/

/-- If every entry of a list of non-negative rationals is at most `ε`, then the sum of the
list is at most `ε` times the number of *strictly positive* entries.  (Entries equal to `0`
contribute nothing, so they may not be counted.) -/
theorem sum_le_card_pos (ε : ℚ) :
    ∀ L : List ℚ, (∀ x ∈ L, 0 ≤ x) → (∀ x ∈ L, x ≤ ε) →
      L.sum ≤ ε * (L.countP fun x => 0 < x) := by
  intro L
  induction L with
  | nil => intro _ _; simp
  | cons a T ih =>
      intro hnn hle
      have hT1 : ∀ x ∈ T, 0 ≤ x := fun x hx => hnn x (List.mem_cons_of_mem _ hx)
      have hT2 : ∀ x ∈ T, x ≤ ε := fun x hx => hle x (List.mem_cons_of_mem _ hx)
      have hrec := ih hT1 hT2
      have ha0 : 0 ≤ a := hnn a List.mem_cons_self
      have hae : a ≤ ε := hle a List.mem_cons_self
      by_cases hpos : 0 < a
      · have hcnt : ((a :: T).countP fun x => 0 < x) = (T.countP fun x => 0 < x) + 1 := by
          simp [hpos]
        rw [List.sum_cons, hcnt]
        push_cast
        linarith
      · have ha : a = 0 := le_antisymm (not_lt.mp hpos) ha0
        have hcnt : ((a :: T).countP fun x => 0 < x) = (T.countP fun x => 0 < x) := by
          simp [hpos]
        rw [List.sum_cons, hcnt, ha]
        linarith

/-- **Spreading law (cardinality form).**  If the grid declines by `R` between two corners
and no single notch of the staircase declines by more than `ε > 0`, then at least `R / ε`
notches of the staircase carry a strictly positive decline. -/
theorem spread_card_lower_bound (F : ℕ → ℕ → ℚ) (b₀ u₀ m n : ℕ) (ε : ℚ) (hε : 0 < ε)
    (hnn : ∀ x ∈ stairSteps F b₀ u₀ m n, 0 ≤ x)
    (hle : ∀ x ∈ stairSteps F b₀ u₀ m n, x ≤ ε) :
    (F b₀ u₀ - F (b₀ + m) (u₀ + n)) / ε
      ≤ ((stairSteps F b₀ u₀ m n).countP fun x => 0 < x) := by
  have h := sum_le_card_pos ε _ hnn hle
  rw [stair_telescope] at h
  rw [div_le_iff₀ hε]
  linarith [h]

/-- **No notch carries the whole decline.**  If the grid declines by `R` between the two
corners while every notch is at most `ε < R`, then no single notch accounts for the decline. -/
theorem no_notch_carries_all (F : ℕ → ℕ → ℚ) (b₀ u₀ m n : ℕ) (ε : ℚ)
    (hεR : ε < F b₀ u₀ - F (b₀ + m) (u₀ + n))
    (hle : ∀ x ∈ stairSteps F b₀ u₀ m n, x ≤ ε) :
    ∀ x ∈ stairSteps F b₀ u₀ m n, x < F b₀ u₀ - F (b₀ + m) (u₀ + n) :=
  fun x hx => lt_of_le_of_lt (hle x hx) hεR

/-- **Fraction form of the spreading law.**  If no notch carries more than the fraction `c`
of the total decline `R > 0`, then the decline is spread over more than `1 / c` notches.
A cliff (`c` small) is therefore quantitatively equivalent to a small number of active
notches. -/
theorem cliff_fraction_spread (F : ℕ → ℕ → ℚ) (b₀ u₀ m n : ℕ) (R c : ℚ)
    (hR : F b₀ u₀ - F (b₀ + m) (u₀ + n) = R) (hRpos : 0 < R)
    (hnn : ∀ x ∈ stairSteps F b₀ u₀ m n, 0 ≤ x)
    (hle : ∀ x ∈ stairSteps F b₀ u₀ m n, x ≤ c * R) :
    1 ≤ c * ((stairSteps F b₀ u₀ m n).countP fun x => 0 < x) := by
  have h := sum_le_card_pos (c * R) _ hnn hle
  rw [stair_telescope, hR] at h
  set k : ℚ := (((stairSteps F b₀ u₀ m n).countP fun x => 0 < x : ℕ) : ℚ) with hk
  have hkey : R * 1 ≤ R * (c * k) := by linarith [h]
  exact le_of_mul_le_mul_left hkey hRpos

/-! ## 3. Separable grids: no interaction term -/

/-- A grid is *separable* (rank one) when it factors as a row function times a column
function.  Separability is the exact absence of a cell-specific interaction term. -/
def Separable (F : ℕ → ℕ → ℚ) : Prop := ∃ f g : ℕ → ℚ, ∀ b u, F b u = f b * g u

/-- **Rank-one law.**  Every `2 × 2` minor of a separable grid vanishes: no cell can behave
differently from what its row and its column dictate.  This is the precise sense of
"no threshold effect at a particular cell". -/
theorem separable_rank_one {F : ℕ → ℕ → ℚ} (h : Separable F) (b b' u u' : ℕ) :
    F b u * F b' u' = F b u' * F b' u := by
  obtain ⟨f, g, hf⟩ := h
  rw [hf, hf, hf, hf]; ring

/-- In a separable grid, a row notch is the row-factor notch scaled by the column factor. -/
theorem separable_rowStep_eq {F : ℕ → ℕ → ℚ} {f g : ℕ → ℚ} (hf : ∀ b u, F b u = f b * g u)
    (b u : ℕ) : rowStep F b u = (f b - f (b + 1)) * g u := by
  rw [rowStep, hf, hf]; ring

/-- In a separable grid, a column notch is the column-factor notch scaled by the row factor. -/
theorem separable_colStep_eq {F : ℕ → ℕ → ℚ} {f g : ℕ → ℚ} (hf : ∀ b u, F b u = f b * g u)
    (b u : ℕ) : colStep F b u = f b * (g u - g (u + 1)) := by
  rw [colStep, hf, hf]; ring

/-- **Gradualness of separable grids (rows).**  If the row factor moves by at most `δ` per
notch and the column factor is bounded by `M ≥ 0`, every row notch is at most `M · δ`. -/
theorem separable_rowStep_bound {F : ℕ → ℕ → ℚ} {f g : ℕ → ℚ} (hf : ∀ b u, F b u = f b * g u)
    (δ M : ℚ) (hM : 0 ≤ M) (b u : ℕ)
    (hrow : f b - f (b + 1) ≤ δ) (hrow0 : 0 ≤ f b - f (b + 1))
    (hcol : |g u| ≤ M) : rowStep F b u ≤ M * δ := by
  rw [separable_rowStep_eq hf]
  have h1 : g u ≤ M := le_trans (le_abs_self _) hcol
  calc (f b - f (b + 1)) * g u ≤ (f b - f (b + 1)) * M := by nlinarith
    _ ≤ δ * M := by nlinarith
    _ = M * δ := by ring

/-- **Gradualness of separable grids (columns).** -/
theorem separable_colStep_bound {F : ℕ → ℕ → ℚ} {f g : ℕ → ℚ} (hf : ∀ b u, F b u = f b * g u)
    (δ M : ℚ) (hM : 0 ≤ M) (b u : ℕ)
    (hcol : g u - g (u + 1) ≤ δ) (hcol0 : 0 ≤ g u - g (u + 1))
    (hrow : |f b| ≤ M) : colStep F b u ≤ M * δ := by
  rw [separable_colStep_eq hf]
  have h1 : f b ≤ M := le_trans (le_abs_self _) hrow
  nlinarith

/-! ## 4. Transfer theorem: near-separable grids are still cliff-free -/

/-- A row notch of a grid that is uniformly `δ`-close to `G` exceeds the corresponding notch
of `G` by at most `2δ`. -/
theorem perturbed_rowStep_bound (F G : ℕ → ℕ → ℚ) (δ ε : ℚ)
    (hclose : ∀ b u, |F b u - G b u| ≤ δ) (b u : ℕ) (hG : rowStep G b u ≤ ε) :
    rowStep F b u ≤ ε + 2 * δ := by
  have h1 := abs_le.mp (hclose b u)
  have h2 := abs_le.mp (hclose (b + 1) u)
  rw [rowStep] at *
  linarith [h1.1, h1.2, h2.1, h2.2]

/-- A column notch of a grid that is uniformly `δ`-close to `G` exceeds the corresponding
notch of `G` by at most `2δ`. -/
theorem perturbed_colStep_bound (F G : ℕ → ℕ → ℚ) (δ ε : ℚ)
    (hclose : ∀ b u, |F b u - G b u| ≤ δ) (b u : ℕ) (hG : colStep G b u ≤ ε) :
    colStep F b u ≤ ε + 2 * δ := by
  have h1 := abs_le.mp (hclose b u)
  have h2 := abs_le.mp (hclose b (u + 1))
  rw [colStep] at *
  linarith [h1.1, h1.2, h2.1, h2.2]

/-- **Transfer theorem.**  If `F` is uniformly `δ`-close to an `ε`-gradual grid `G`, then no
notch of `F` reaches the total decline `R`, provided `ε + 2δ < R`.  Approximate
separability therefore already excludes cliffs — the observed grid does not have to match a
model exactly for the no-cliff verdict to hold. -/
theorem perturbed_no_cliff (F G : ℕ → ℕ → ℚ) (δ ε : ℚ) (b₀ u₀ m n : ℕ)
    (hclose : ∀ b u, |F b u - G b u| ≤ δ)
    (hGrow : ∀ b u, rowStep G b u ≤ ε) (hGcol : ∀ b u, colStep G b u ≤ ε)
    (hlt : ε + 2 * δ < F b₀ u₀ - F (b₀ + m) (u₀ + n)) :
    ∀ x ∈ stairSteps F b₀ u₀ m n, x < F b₀ u₀ - F (b₀ + m) (u₀ + n) := by
  intro x hx
  rcases mem_stairSteps hx with ⟨i, _, rfl⟩ | ⟨j, _, rfl⟩
  · exact lt_of_le_of_lt
      (perturbed_rowStep_bound F G δ ε hclose _ _ (hGrow _ _)) hlt
  · exact lt_of_le_of_lt
      (perturbed_colStep_bound F G δ ε hclose _ _ (hGcol _ _)) hlt

/-! ## 5. No sharp edge: geometric descent towards a practical floor -/

/-- If each notch of a positive sequence retains at least a fraction `r` of the value, then
after `j` notches at least the fraction `r ^ j` is retained. -/
theorem geometric_lower (s : ℕ → ℚ) (r : ℚ) (hr : 0 ≤ r)
    (hstep : ∀ k, r * s k ≤ s (k + 1)) (n : ℕ) :
    ∀ j : ℕ, r ^ j * s n ≤ s (n + j) := by
  intro j
  induction j with
  | zero => simp
  | succ k ih =>
      have h1 : r * (r ^ k * s n) ≤ r * s (n + k) := by
        have := mul_le_mul_of_nonneg_left ih hr
        linarith
      have h2 : r * s (n + k) ≤ s (n + k + 1) := hstep (n + k)
      calc r ^ (k + 1) * s n = r * (r ^ k * s n) := by ring
        _ ≤ s (n + k + 1) := by linarith
        _ = s (n + (k + 1)) := by ring_nf

/-- **Slow descent (no sharp edge).**  A geometric dial with retention `r` cannot reach a
practical floor `τ` in fewer than `j` notches whenever `r ^ j · s n > τ`. -/
theorem slow_descent (s : ℕ → ℚ) (r τ : ℚ) (hr : 0 ≤ r)
    (hstep : ∀ k, r * s k ≤ s (k + 1)) (n j : ℕ) (hj : τ < r ^ j * s n) :
    τ < s (n + j) := lt_of_lt_of_le hj (geometric_lower s r hr hstep n j)

/-- **Crossing has no jump.**  If the value at notch `k` is still above the floor `τ`, the
value at the next notch is at least `r · τ`: the dial cannot fall through the floor. -/
theorem crossing_no_jump (s : ℕ → ℚ) (r τ : ℚ) (hr : 0 ≤ r) (k : ℕ)
    (hstep : r * s k ≤ s (k + 1)) (hk : τ ≤ s k) : r * τ ≤ s (k + 1) := by
  have : r * τ ≤ r * s k := mul_le_mul_of_nonneg_left hk hr
  linarith

/-- **Relative overshoot bound.**  The single notch on which a geometric dial crosses its
practical floor `τ` moves it by at most `(1 - r) · s k`; for `r` close to `1` the crossing
is a gradual transition and not a sharp edge. -/
theorem crossing_relative_overshoot (s : ℕ → ℚ) (r : ℚ) (k : ℕ)
    (hstep : r * s k ≤ s (k + 1)) : s k - s (k + 1) ≤ (1 - r) * s k := by
  nlinarith

/-! ## 6. Sharpness: cliffs do exist, so the hypotheses are not vacuous -/

/-- A genuine cliff grid: it sits at `79/100` at the origin and drops to `53/100`
everywhere else, so one single notch carries the whole decline. -/
def cliffExample : ℕ → ℕ → ℚ := fun b u => if b + u = 0 then 79 / 100 else 53 / 100

lemma cliffExample_antitone_row (b u : ℕ) : cliffExample (b + 1) u ≤ cliffExample b u := by
  unfold cliffExample
  split_ifs <;> first | omega | norm_num

lemma cliffExample_antitone_col (b u : ℕ) : cliffExample b (u + 1) ≤ cliffExample b u := by
  unfold cliffExample
  split_ifs <;> first | omega | norm_num

/-- The cliff grid really has a cliff: the very first row notch carries the entire decline
`26/100` of the whole `4 × 3` staircase.  Hence the `no_notch_carries_all` verdict is a
genuine restriction on the data, not a formality. -/
theorem cliff_example_has_cliff :
    rowStep cliffExample 0 0 = cliffExample 0 0 - cliffExample 3 2 := by
  unfold rowStep cliffExample
  norm_num

theorem cliff_example_drop : cliffExample 0 0 - cliffExample 3 2 = 26 / 100 := by
  unfold cliffExample; norm_num

/-! ## 7. Sharpness of the spreading law: the perfectly gradual grid -/

/-- The perfectly gradual grid: it starts at `top` and loses exactly `δ` at every notch of
either dial. -/
def linearGrid (top δ : ℚ) : ℕ → ℕ → ℚ := fun b u => top - ((b : ℚ) + u) * δ

@[simp] lemma linearGrid_rowStep (top δ : ℚ) (b u : ℕ) :
    rowStep (linearGrid top δ) b u = δ := by
  simp only [rowStep, linearGrid]
  push_cast
  ring

@[simp] lemma linearGrid_colStep (top δ : ℚ) (b u : ℕ) :
    colStep (linearGrid top δ) b u = δ := by
  simp only [colStep, linearGrid]
  push_cast
  ring

/-- All notches of the perfectly gradual grid are equal to `δ`. -/
theorem linearGrid_notches (top δ : ℚ) (b₀ u₀ m n : ℕ) :
    ∀ x ∈ stairSteps (linearGrid top δ) b₀ u₀ m n, x = δ := by
  intro x hx
  rcases mem_stairSteps hx with ⟨i, _, rfl⟩ | ⟨j, _, rfl⟩
  · exact linearGrid_rowStep top δ _ _
  · exact linearGrid_colStep top δ _ _

/-- **Sharpness of the spreading law.**  For every target decline `R > 0` and every staircase
shape `m + n ≥ 1` there is a monotone grid realising the decline with all notches equal to
`R / (m + n)`; its number of positive notches is exactly `m + n = R / δ`, so the bound of
`spread_card_lower_bound` is attained.  In particular the recorded envelope is realisable:
the verdict "gradual" is a statement with content on both sides. -/
theorem spreading_law_sharp (top R : ℚ) (m n : ℕ) (hmn : 0 < m + n) (hR : 0 < R) :
    let δ : ℚ := R / (m + n)
    (linearGrid top δ 0 0 - linearGrid top δ (0 + m) (0 + n) = R) ∧
    (∀ x ∈ stairSteps (linearGrid top δ) 0 0 m n, x = δ) ∧
    ((stairSteps (linearGrid top δ) 0 0 m n).countP fun x => 0 < x) = m + n := by
  intro δ
  have hmn' : (0 : ℚ) < (m : ℚ) + n := by
    have h1 : (1 : ℕ) ≤ m + n := hmn
    have h2 : (1 : ℚ) ≤ (m : ℚ) + (n : ℚ) := by exact_mod_cast h1
    linarith
  have hδeq : δ = R / ((m : ℚ) + n) := rfl
  have hδ : 0 < δ := by rw [hδeq]; exact div_pos hR hmn'
  refine ⟨?_, linearGrid_notches top δ 0 0 m n, ?_⟩
  · have htel := stair_telescope (linearGrid top δ) 0 0 m n
    have hsum : (stairSteps (linearGrid top δ) 0 0 m n).sum = ((m + n : ℕ) : ℚ) * δ := by
      rw [List.sum_eq_card_nsmul _ δ (linearGrid_notches top δ 0 0 m n)]
      simp [stairSteps_length]
    rw [hsum] at htel
    rw [← htel]
    have hcast : ((m + n : ℕ) : ℚ) = (m : ℚ) + n := by push_cast; ring
    rw [hcast, hδeq]
    field_simp
  · rw [List.countP_eq_length.mpr, stairSteps_length]
    intro x hx
    rw [linearGrid_notches top δ 0 0 m n x hx]
    simpa using hδ

end Catalog.Combinatorics.BKeyMixedZoneGradualDecline