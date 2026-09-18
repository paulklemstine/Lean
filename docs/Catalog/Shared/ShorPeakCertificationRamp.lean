import Mathlib

/-!
# The certification ramp of Shor peaks: `P₁ = (2⌊q/2r⌋+1)/r ≈ q/r²`

*(FACT round-25 #1 — QUBIT-TRADE2, "one register bit is worth one sample",
paper 85.  Companion of `Shared.QubitTradeResourceSurface` / paper 87.)*

Shor's period-finding routine with a register of width `t` measures an outcome
`k ∈ [0, q)`, `q = 2^t`, whose probability mass concentrates on the `r`
**peaks** `k ≈ j·q/r` (`j = 0, …, r-1`), where `r` is the unknown period.
Post-processing can only succeed from a sample `k` whose continued-fraction
expansion produces `j/r`; by the classical convergent criterion this requires

  `|k/q - j/r| ≤ 1/(2r²)`.

This file studies the **certification set**: the set of peaks `j` for which
some grid point `k` satisfies that inequality, i.e. for which the peak is close
enough to the measurement grid `(1/q)·ℤ` to be certifiable at all.  Clearing
denominators by `2qr²` turns the condition into

  `PeakCertifies q r j ↔ ∃ k : ℤ, 2r·|jq - kr| ≤ q`  (`peakCertifies_iff`).

## Pre-registered hypothesis and its refutation

The round's pre-stated hypothesis was a **vertical wall**: for odd `r` and
`q < r²`, certification should fail *deterministically*.  It is refuted here in
the sharpest possible form:

* `subwall_certificate` — as soon as `q ≥ 2r` (exponentially below the wall
  `q = r²`) there is a peak `j` with `0 < j < r` and `gcd(j, r) = 1` that
  certifies.  A coprime numerator means the recovered fraction has denominator
  exactly `r`, so the certificate is informative, not spurious.

## The ramp

* `card_certPeaks` — the **exact count**: for `gcd(q, r) = 1` and
  `2⌊q/(2r)⌋ < r`, exactly `2⌊q/(2r)⌋ + 1` of the `r` peaks certify.
* `ramp_lower`, `ramp_upper` — hence the per-sample certification rate lies in
  `(q/r² - 1/r, q/r² + 1/r]`: a **ramp of unit slope in `q/r²`**, not a wall.
* `certPeaks_saturated` — the wall position `q = r²` is exactly where the ramp
  *saturates* (all `r` peaks certify), which is why it looked like a threshold.
* `card_certPeaks_of_dvd` — the degenerate family `r ∣ q` (the pure powers of
  two of the experiment) is flat-saturated at every width: every peak sits
  exactly on a grid point.

Together these are the formal content of measurement 1 of the round.
-/

namespace ShorPeakRamp

open Finset

/-! ## 1. The certification predicate -/

/-- The residue of the `j`-th peak position `j·q/r` on the measurement grid:
`j·q = (j·q / r)·r + peakRes q r j`. -/
def peakRes (q r j : ℕ) : ℕ := j * q % r

/-- Decidable form of the certification condition: the distance from the peak
`j·q/r` to the nearest grid point is `peakRes/r` (rounding down) or
`(r - peakRes)/r` (rounding up), and one of them must be at most `q/(2r²)`. -/
def CertRes (q r j : ℕ) : Prop :=
  2 * r * peakRes q r j ≤ q ∨ 2 * r * (r - peakRes q r j) ≤ q

instance (q r : ℕ) : DecidablePred (CertRes q r) := fun j => by
  unfold CertRes; infer_instance

/-- **The certification statistic.**  Peak `j` certifies when some grid point
`k` satisfies `|k/q - j/r| ≤ 1/(2r²)`, the continued-fraction convergent
criterion with denominator bound `b = r`. -/
def PeakCertifies (q r j : ℕ) : Prop :=
  ∃ k : ℤ, 2 * (r : ℤ) * |(j : ℤ) * (q : ℤ) - k * (r : ℤ)| ≤ (q : ℤ)

/-- The geometric certification condition is exactly the residue condition. -/
theorem peakCertifies_iff (q r j : ℕ) (hr : 0 < r) :
    PeakCertifies q r j ↔ CertRes q r j := by
  have hm : j * q % r < r := Nat.mod_lt _ hr
  have hsplit : (j : ℤ) * q = ((j * q / r : ℕ) : ℤ) * r + ((j * q % r : ℕ) : ℤ) := by
    have h : (j * q / r) * r + (j * q) % r = j * q := by
      rw [Nat.mul_comm]; exact Nat.div_add_mod (j * q) r
    exact_mod_cast h.symm
  have hr' : (0 : ℤ) < (r : ℤ) := by exact_mod_cast hr
  constructor
  · rintro ⟨k, hk⟩
    set m : ℕ := j * q % r with hmdef
    set d : ℕ := j * q / r with hddef
    have hval : (j : ℤ) * q - k * r = ((d : ℤ) - k) * r + (m : ℤ) := by
      rw [hsplit]; ring
    have hmr : m ≤ r := le_of_lt hm
    rcases le_or_gt 0 ((d : ℤ) - k) with ht | ht
    · left
      have h1 : (m : ℤ) ≤ |(j : ℤ) * q - k * r| := by
        have hnn : (0 : ℤ) ≤ ((d : ℤ) - k) * r := by positivity
        rw [hval]
        calc (m : ℤ) ≤ ((d : ℤ) - k) * r + (m : ℤ) := by linarith
          _ ≤ |((d : ℤ) - k) * r + (m : ℤ)| := le_abs_self _
      have hgoal : 2 * (r : ℤ) * (m : ℤ) ≤ (q : ℤ) := by nlinarith
      exact_mod_cast hgoal
    · right
      have htle : (d : ℤ) - k ≤ -1 := by omega
      have h1 : ((r : ℤ) - (m : ℤ)) ≤ |(j : ℤ) * q - k * r| := by
        have hneg : ((d : ℤ) - k) * r ≤ -(r : ℤ) := by nlinarith
        rw [hval]
        have hna : -(((d : ℤ) - k) * r + (m : ℤ)) ≤ |((d : ℤ) - k) * r + (m : ℤ)| :=
          neg_le_abs _
        linarith
      have hgoal : 2 * (r : ℤ) * ((r : ℤ) - (m : ℤ)) ≤ (q : ℤ) := by nlinarith
      have hcast : ((r - m : ℕ) : ℤ) = (r : ℤ) - (m : ℤ) := by
        push_cast [hmr]; ring
      rw [← hcast] at hgoal
      exact_mod_cast hgoal
  · intro h
    set m : ℕ := j * q % r with hmdef
    set d : ℕ := j * q / r with hddef
    have hmr : m ≤ r := le_of_lt hm
    have hcast : ((r - m : ℕ) : ℤ) = (r : ℤ) - (m : ℤ) := by push_cast [hmr]; ring
    rcases h with h | h
    · refine ⟨(d : ℤ), ?_⟩
      have hval : (j : ℤ) * q - (d : ℤ) * r = (m : ℤ) := by rw [hsplit]; ring
      rw [hval, abs_of_nonneg (by positivity)]
      exact_mod_cast h
    · refine ⟨(d : ℤ) + 1, ?_⟩
      have hval : (j : ℤ) * q - ((d : ℤ) + 1) * r = (m : ℤ) - (r : ℤ) := by
        rw [hsplit]; ring
      have habs : |(m : ℤ) - (r : ℤ)| = (r : ℤ) - (m : ℤ) := by
        rw [abs_sub_comm, abs_of_nonneg]
        have : (m : ℤ) ≤ (r : ℤ) := by exact_mod_cast hmr
        linarith
      have hgoal : 2 * (r : ℤ) * ((r - m : ℕ) : ℤ) ≤ (q : ℤ) := by exact_mod_cast h
      rw [hcast] at hgoal
      rw [hval, habs]
      exact hgoal

/-! ## 2. The certification set and its exact cardinality -/

/-- The set of certifying peaks among `j = 0, …, r-1`. -/
def certPeaks (q r : ℕ) : Finset ℕ := (range r).filter (CertRes q r)

/-- The same condition read directly on residues. -/
def resPeaks (q r : ℕ) : Finset ℕ :=
  (range r).filter (fun m => 2 * r * m ≤ q ∨ 2 * r * (r - m) ≤ q)

/-- Multiplication by a modular inverse is an involution-like bijection of the
residues `[0, r)`. -/
theorem inv_key {r u v : ℕ} (h : u * v % r = 1) {x : ℕ} (hx : x < r) :
    (x * u % r) * v % r = x := by
  have h1 : (x * u % r) * v % r = (x * (u * v)) % r := by rw [Nat.mod_mul_mod]; ring_nf
  rw [h1, Nat.mul_mod, h, Nat.mod_eq_of_lt hx]
  simp [Nat.mod_eq_of_lt hx]

/-- `j ↦ j·q mod r` transports the peak set onto the residue set; for
`gcd(q, r) = 1` it is a bijection of `[0, r)`.  This is the step where
coprimality of the register size and the period enters: the peaks are
*equidistributed* over the grid residues. -/
theorem card_certPeaks_eq_card_resPeaks (q r : ℕ) (hr : 0 < r)
    (hco : Nat.Coprime q r) : (certPeaks q r).card = (resPeaks q r).card := by
  rcases Nat.lt_or_ge r 2 with hr1 | hr2
  · interval_cases r
    · have h1 : CertRes q 1 0 := Or.inl (by simp [peakRes])
      simp [certPeaks, resPeaks, Finset.filter_singleton, h1]
  obtain ⟨a, -, ha⟩ := Nat.exists_mul_mod_eq_one_of_coprime hco hr2
  have ha' : a * q % r = 1 := by rw [Nat.mul_comm]; exact ha
  refine Finset.card_bij' (fun j _ => j * q % r) (fun m _ => m * a % r) ?_ ?_ ?_ ?_
  · intro j hj
    simp only [certPeaks, resPeaks, mem_filter, mem_range] at hj ⊢
    exact ⟨Nat.mod_lt _ hr, hj.2⟩
  · intro m hm
    simp only [certPeaks, resPeaks, mem_filter, mem_range] at hm ⊢
    refine ⟨Nat.mod_lt _ hr, ?_⟩
    have hkey : peakRes q r (m * a % r) = m := inv_key ha' hm.1
    simpa [CertRes, hkey] using hm.2
  · intro j hj
    simp only [certPeaks, mem_filter, mem_range] at hj
    exact inv_key ha hj.1
  · intro m hm
    simp only [resPeaks, mem_filter, mem_range] at hm
    exact inv_key ha' hm.1

/-- The residue count: below saturation exactly `2⌊q/(2r)⌋ + 1` residues are
within `q/(2r)` of a multiple of `r`. -/
theorem card_resPeaks (q r : ℕ) (hr : 0 < r) (h : 2 * (q / (2 * r)) < r) :
    (resPeaks q r).card = 2 * (q / (2 * r)) + 1 := by
  set B := q / (2 * r) with hB
  have hiff : ∀ x : ℕ, 2 * r * x ≤ q ↔ x ≤ B := by
    intro x
    rw [hB, Nat.le_div_iff_mul_le (by omega)]
    constructor <;> intro h' <;> nlinarith
  have hset : resPeaks q r = range (B + 1) ∪ Ico (r - B) r := by
    ext m
    simp only [resPeaks, mem_filter, mem_range, mem_union, mem_Ico, hiff]
    omega
  have hdisj : Disjoint (range (B + 1)) (Ico (r - B) r) := by
    rw [Finset.disjoint_left]
    intro x hx hx2
    simp only [mem_range] at hx
    simp only [mem_Ico] at hx2
    omega
  rw [hset, Finset.card_union_of_disjoint hdisj, Finset.card_range, Nat.card_Ico]
  omega

/-- **The exact certification count.**  For a register size `q` coprime to the
period `r`, below saturation exactly `2⌊q/(2r)⌋ + 1` of the `r` peaks are
certifiable. -/
theorem card_certPeaks (q r : ℕ) (hr : 0 < r) (hco : Nat.Coprime q r)
    (h : 2 * (q / (2 * r)) < r) :
    (certPeaks q r).card = 2 * (q / (2 * r)) + 1 := by
  rw [card_certPeaks_eq_card_resPeaks q r hr hco, card_resPeaks q r hr h]

/-! ## 3. The ramp: the count is `q/r²·r`, up to one peak -/

/-- **Ramp, upper rail.**  The certification rate never exceeds `q/r² + 1/r`. -/
theorem ramp_upper (q r : ℕ) (hr : 0 < r) (hco : Nat.Coprime q r)
    (h : 2 * (q / (2 * r)) < r) :
    ((certPeaks q r).card : ℝ) / r ≤ (q : ℝ) / r ^ 2 + 1 / r := by
  have hcard := card_certPeaks q r hr hco h
  set B := q / (2 * r) with hB
  have hBq : 2 * r * B ≤ q := by
    rw [hB]
    have := Nat.div_mul_le_self q (2 * r)
    calc 2 * r * (q / (2 * r)) = (q / (2 * r)) * (2 * r) := by ring
      _ ≤ q := this
  have hr0 : (0 : ℝ) < r := by exact_mod_cast hr
  have hBq' : 2 * (r : ℝ) * B ≤ (q : ℝ) := by exact_mod_cast hBq
  rw [hcard]
  push_cast
  rw [div_le_iff₀ hr0]
  have hRHS : ((q : ℝ) / r ^ 2 + 1 / r) * r = (q : ℝ) / r + 1 := by
    field_simp
  have h2 : (2 : ℝ) * B ≤ (q : ℝ) / r := by
    rw [le_div_iff₀ hr0]; nlinarith
  rw [hRHS]
  linarith

/-- **Ramp, lower rail.**  The certification rate always exceeds `q/r² - 1/r`.
In particular it is *strictly positive* at every register width: the ramp has
no wall. -/
theorem ramp_lower (q r : ℕ) (hr : 0 < r) (hco : Nat.Coprime q r)
    (h : 2 * (q / (2 * r)) < r) :
    (q : ℝ) / r ^ 2 - 1 / r < ((certPeaks q r).card : ℝ) / r := by
  have hcard := card_certPeaks q r hr hco h
  set B := q / (2 * r) with hB
  have hdm : 2 * r * B + q % (2 * r) = q := by
    rw [hB]; exact Nat.div_add_mod q (2 * r)
  have hmodlt : q % (2 * r) < 2 * r := Nat.mod_lt _ (by omega)
  have hr0 : (0 : ℝ) < r := by exact_mod_cast hr
  have hdm' : 2 * (r : ℝ) * B + ((q % (2 * r) : ℕ) : ℝ) = (q : ℝ) := by exact_mod_cast hdm
  have hmodlt' : ((q % (2 * r) : ℕ) : ℝ) < 2 * r := by exact_mod_cast hmodlt
  rw [hcard]
  push_cast
  rw [lt_div_iff₀ hr0]
  have hLHS : ((q : ℝ) / r ^ 2 - 1 / r) * r = (q : ℝ) / r - 1 := by
    field_simp
  have h2 : (q : ℝ) / r < 2 * (B : ℝ) + 2 := by
    rw [div_lt_iff₀ hr0]; nlinarith
  rw [hLHS]
  linarith

/-! ## 4. No wall: sub-wall certificates exist -/

/-- Peak `0` always certifies, so the certification set is never empty. -/
theorem zero_mem_certPeaks (q r : ℕ) (hr : 0 < r) : 0 ∈ certPeaks q r := by
  simp only [certPeaks, mem_filter, mem_range]
  exact ⟨hr, Or.inl (by simp [peakRes])⟩

/-- **Refutation of the vertical wall.**  For a register size `q` coprime to
the period `r` with merely `q ≥ 2r` — exponentially below the putative wall
`q = r²` — there is a *nontrivial, informative* certifying peak: an index `j`
with `0 < j < r` and `gcd(j, r) = 1`, so the fraction `j/r` returned by the
continued-fraction step has denominator exactly `r`.

Certification below the wall is therefore not merely possible, it is
constructive; the round-14 "deterministic failure" was the deep-ramp limit
`q/r² ≈ 0`, not a hard boundary. -/
theorem subwall_certificate (q r : ℕ) (hr : 2 ≤ r) (hco : Nat.Coprime q r)
    (hq : 2 * r ≤ q) :
    ∃ j : ℕ, 0 < j ∧ j < r ∧ Nat.Coprime j r ∧ PeakCertifies q r j := by
  obtain ⟨a, halt, ha⟩ := Nat.exists_mul_mod_eq_one_of_coprime hco hr
  have hr0 : 0 < r := by omega
  have hres : peakRes q r a = 1 := by
    rw [peakRes, Nat.mul_comm]; exact ha
  have hapos : 0 < a := by
    rcases Nat.eq_zero_or_pos a with h0 | h
    · exfalso; rw [h0] at ha; simp at ha
    · exact h
  have hcop : Nat.Coprime a r := by
    have hdvd1 : Nat.gcd a r ∣ a * q := Dvd.dvd.mul_right (Nat.gcd_dvd_left a r) q
    have hdvd2 : Nat.gcd a r ∣ r * (a * q / r) :=
      Dvd.dvd.mul_right (Nat.gcd_dvd_right a r) _
    have hmod : a * q % r = a * q - r * (a * q / r) := by
      have h := Nat.div_add_mod (a * q) r
      omega
    have hone : Nat.gcd a r ∣ 1 := by
      have : Nat.gcd a r ∣ a * q % r := by
        rw [hmod]; exact Nat.dvd_sub hdvd1 hdvd2
      rwa [← peakRes, hres] at this
    exact Nat.dvd_one.mp hone
  refine ⟨a, hapos, halt, hcop, ?_⟩
  rw [peakCertifies_iff q r a hr0]
  exact Or.inl (by rw [hres]; omega)

/-! ## 5. Saturation and the degenerate dyadic family -/

/-- **Saturation at the wall.**  Once `q ≥ r²` every peak certifies: the
position that looked like a wall is where the ramp reaches the top. -/
theorem certPeaks_saturated (q r : ℕ) (hr : 0 < r) (hq : r * r ≤ q) :
    certPeaks q r = range r := by
  apply Finset.filter_true_of_mem
  intro j _
  set m := peakRes q r j with hm
  have hmr : m < r := Nat.mod_lt _ hr
  rcases le_or_gt (2 * m) r with h | h
  · exact Or.inl (by nlinarith)
  · exact Or.inr (by have : 2 * (r - m) ≤ r := by omega
                     nlinarith)

/-- **The degenerate flat family.**  If the period divides the register size —
the pure powers of two of the experiment, `r = 2^v`, `q = 2^t`, `v ≤ t` — then
every peak lands exactly on a grid point and the certification rate is
identically `1`, independently of `q/r²`. -/
theorem card_certPeaks_of_dvd (q r : ℕ) (hdvd : r ∣ q) :
    (certPeaks q r).card = r := by
  have : certPeaks q r = range r := by
    apply Finset.filter_true_of_mem
    intro j _
    refine Or.inl ?_
    have hz : peakRes q r j = 0 := by
      rw [peakRes]
      exact Nat.dvd_iff_mod_eq_zero.mp (Dvd.dvd.mul_left hdvd j)
    simp [hz]
  rw [this, Finset.card_range]


/-! ## 6. Lab notes: kernel-checked instances of the ramp

Exact certification counts `#certPeaks (2^t) r`, computed by the kernel
(`decide`) and compared with the closed form `2⌊q/(2r)⌋ + 1` of
`card_certPeaks`.  The three families of the round appear:

| `r`  | `t` | `q = 2^t` | `#certPeaks` | `2⌊q/2r⌋+1` | rate `#/r` | `q/r²` |
|------|-----|-----------|--------------|-------------|-----------|--------|
| 21   |  6  |     64    |      3       |      3      |  0.143    | 0.145  |
| 21   |  7  |    128    |      7       |      7      |  0.333    | 0.290  |
| 21   |  8  |    256    |     13       |     13      |  0.619    | 0.580  |
| 21   |  9  |    512    |     21       |  25 (sat.)  |  1.000    | 1.161  |
| 15   |  5  |     32    |      3       |      3      |  0.200    | 0.142  |
| 15   |  7  |    128    |      9       |      9      |  0.600    | 0.569  |
| 11   |  6  |     64    |      5       |      5      |  0.455    | 0.529  |
|  8   |  2  |      4    |      4       |   (dyadic)  |  0.500    | 0.062  |
|  8   |  3  |      8    |      8       |   (dyadic)  |  1.000    | 0.125  |

The odd/mixed rows track the ramp `q/r²` with unit slope and saturate exactly
where `2⌊q/(2r)⌋ + 1` crosses `r` (the wall position `q ≍ r²`); the dyadic row
`r = 8` is flat-saturated far below the wall, with no wall behaviour at all —
the two experimental families of measurement 1. -/

example : (certPeaks 64 21).card = 3 := by decide
example : (certPeaks 128 21).card = 7 := by decide
example : (certPeaks 256 21).card = 13 := by decide
example : (certPeaks 512 21).card = 21 := by decide
example : (certPeaks 32 15).card = 3 := by decide
example : (certPeaks 128 15).card = 9 := by decide
example : (certPeaks 64 11).card = 5 := by decide
example : (certPeaks 4 8).card = 4 := by decide
example : (certPeaks 8 8).card = 8 := by decide

/-- Kernel check of the closed form at a sub-wall point: `q = 256`, `r = 21`,
`2⌊q/2r⌋ + 1 = 13` while `r² = 441 > q`. -/
example : 2 * (256 / (2 * 21)) + 1 = 13 := by decide

end ShorPeakRamp