import Mathlib

/-!
# Depth decay of the magnitude channel on the Berggren / Pythagorean tree

## Setting

Primitive Pythagorean triples are in bijection with *admissible pairs* `(m, n)` of
naturals: `0 < n < m`, `gcd m n = 1`, `m + n` odd.  Berggren's ternary tree on
primitive triples becomes, in these coordinates, the ternary tree on admissible
pairs with children

* `A : (m, n) ↦ (2m - n, m)`,
* `B : (m, n) ↦ (2m + n, m)`,
* `C : (m, n) ↦ (m + 2n, n)`,

rooted at `(2,1)` (the triple `(3,4,5)`).  Inverting, every non-root admissible
pair has a unique *parent*, and which of the three inverse branches applies is
decided purely by the position of the **ratio** `r = m/n` relative to the two
cut points `2` and `3`:

* `r < 2`     → letter `A`, parent `(n, 2n - m)` (parent ratio `1/(2-r)`),
* `2 < r < 3` → letter `B`, parent `(n, m - 2n)` (parent ratio `1/(r-2)`),
* `3 < r`     → letter `C`, parent `(m - 2n, n)` (parent ratio `r - 2`).

This is a Gauss-map style digit expansion of the ratio `r`.

## The sensor model

A *W-window sensor* is the computable functional `probe W (m,n) = ⌊2^W · m / n⌋`:
it reads the magnitude of the ratio to `W` binary places and nothing else, with
a budget independent of the depth of the state in the tree.  This file proves
exactly how far down the descent such a sensor can see.

## Main results (this file)

* `letterOf_eq_letterFromProbe` : the **first** letter is an explicit function of
  the one-bit probe `⌊2m/n⌋`.  The magnitude channel really exists at depth 1.
* `probe_one_parent_of_C` : along a `C`-step the probe merely shifts by `4`.
* `letterAt_eq_of_probe_one_of_prefix_C` : if two admissible states share the
  one-bit probe, then all of their letters agree up to *and including* the first
  non-`C` letter.  The readable prefix is the leading `C`-run plus one inversion
  letter.
* `cRun_letters_C`, `cRun_letterAt_ne_C` : the length of that leading `C`-run is
  the single integer division `(m - n) / (2n)`; depth itself is therefore visible
  to the magnitude channel.

The complementary **null** result — no fixed window can read the letter
immediately after the first inversion, at any prescribed depth — is
`Cryptography.DepthDecay.NullBeyondInversion`.
-/

namespace DepthDecay

/-- The three Berggren descent letters. -/
inductive Letter
  | A : Letter
  | B : Letter
  | C : Letter
  deriving DecidableEq, Repr

/-- Admissible pairs: the `(m,n)` coordinates of primitive Pythagorean triples. -/
def Adm (s : ℕ × ℕ) : Prop :=
  0 < s.2 ∧ s.2 < s.1 ∧ Nat.gcd s.1 s.2 = 1 ∧ (s.1 + s.2) % 2 = 1

/-- The root of the Berggren tree, corresponding to the triple `(3,4,5)`. -/
def root : ℕ × ℕ := (2, 1)

/-- Which inverse Berggren branch a state came from: decided by the ratio `m/n`
against the cut points `2` and `3`. -/
def letterOf (s : ℕ × ℕ) : Letter :=
  if s.1 < 2 * s.2 then Letter.A else if s.1 < 3 * s.2 then Letter.B else Letter.C

/-- The descent (parent) map on admissible pairs. -/
def parent (s : ℕ × ℕ) : ℕ × ℕ :=
  if s.1 < 2 * s.2 then (s.2, 2 * s.2 - s.1)
  else if s.1 < 3 * s.2 then (s.2, s.1 - 2 * s.2)
  else (s.1 - 2 * s.2, s.2)

/-- The `k`-th letter of the descent path of `s` (letter `0` is the first step). -/
def letterAt (k : ℕ) (s : ℕ × ℕ) : Letter := letterOf (parent^[k] s)

/-- The `W`-window magnitude sensor: the ratio `m/n` truncated to `W` binary
places. -/
def probe (W : ℕ) (s : ℕ × ℕ) : ℕ := 2 ^ W * s.1 / s.2

/-- Decoding of the first letter from the one-bit probe. -/
def letterFromProbe (p : ℕ) : Letter :=
  if p ≤ 3 then Letter.A else if p ≤ 5 then Letter.B else Letter.C

/-! ### Basic structure of admissible states -/

/-- For an admissible state, `m = 2n` forces the root. -/
theorem eq_root_of_two_mul {s : ℕ × ℕ} (h : Adm s) (hEq : s.1 = 2 * s.2) : s = root := by
  obtain ⟨hp, _, hg, _⟩ := h
  have hdvd : s.2 ∣ s.1 := ⟨2, by omega⟩
  have : Nat.gcd s.1 s.2 = s.2 := Nat.gcd_eq_right hdvd
  have hn : s.2 = 1 := by omega
  have hm : s.1 = 2 := by omega
  exact Prod.ext (by simpa [root] using hm) (by simpa [root] using hn)

/-- For an admissible state the ratio is never exactly `3`: parity forbids it. -/
theorem ne_three_mul {s : ℕ × ℕ} (h : Adm s) : s.1 ≠ 3 * s.2 := by
  intro hEq
  obtain ⟨hp, _, hg, hpar⟩ := h
  have hdvd : s.2 ∣ s.1 := ⟨3, by omega⟩
  have : Nat.gcd s.1 s.2 = s.2 := Nat.gcd_eq_right hdvd
  have hn : s.2 = 1 := by omega
  omega

/-- More generally, an admissible state never has `m` an odd multiple `(2j+3)n`
of `n`.  This is what keeps the descent away from every branch boundary. -/
theorem ne_odd_mul {s : ℕ × ℕ} (h : Adm s) (j : ℕ) : s.1 ≠ (2 * j + 3) * s.2 := by
  intro hEq
  obtain ⟨hp, _, hg, hpar⟩ := h
  have hdvd : s.2 ∣ s.1 := ⟨2 * j + 3, by rw [hEq]; ring⟩
  have : Nat.gcd s.1 s.2 = s.2 := Nat.gcd_eq_right hdvd
  have hn : s.2 = 1 := by omega
  rw [hn, mul_one] at hEq
  omega

/-- The descent map preserves admissibility away from the root. -/
theorem Adm.parent {s : ℕ × ℕ} (h : Adm s) (hne : s ≠ root) : Adm (DepthDecay.parent s) := by
  obtain ⟨hp, hlt, hg, hpar⟩ := h
  have hAdm : Adm s := ⟨hp, hlt, hg, hpar⟩
  have h2 : s.1 ≠ 2 * s.2 := fun hEq => hne (eq_root_of_two_mul hAdm hEq)
  have h3 : s.1 ≠ 3 * s.2 := ne_three_mul hAdm
  by_cases hA : s.1 < 2 * s.2
  · have hpar' : DepthDecay.parent s = (s.2, 2 * s.2 - s.1) := by
      simp [DepthDecay.parent, hA]
    rw [hpar']
    refine ⟨by simpa using (by omega : 0 < 2 * s.2 - s.1),
            by simpa using (by omega : 2 * s.2 - s.1 < s.2), ?_, by simpa using (by omega :
              (s.2 + (2 * s.2 - s.1)) % 2 = 1)⟩
    have hdvd : Nat.gcd s.2 (2 * s.2 - s.1) ∣ Nat.gcd s.1 s.2 := by
      refine Nat.dvd_gcd ?_ (Nat.gcd_dvd_left _ _)
      have h1 : Nat.gcd s.2 (2 * s.2 - s.1) ∣ 2 * s.2 :=
        Dvd.dvd.mul_left (Nat.gcd_dvd_left _ _) 2
      have h2' : Nat.gcd s.2 (2 * s.2 - s.1) ∣ 2 * s.2 - s.1 := Nat.gcd_dvd_right _ _
      have := Nat.dvd_sub h1 h2'
      simpa [show 2 * s.2 - (2 * s.2 - s.1) = s.1 by omega] using this
    simpa [hg] using Nat.eq_one_of_dvd_one (hg ▸ hdvd)
  · by_cases hB : s.1 < 3 * s.2
    · have hpar' : DepthDecay.parent s = (s.2, s.1 - 2 * s.2) := by
        simp [DepthDecay.parent, hA, hB]
      rw [hpar']
      refine ⟨by simpa using (by omega : 0 < s.1 - 2 * s.2),
              by simpa using (by omega : s.1 - 2 * s.2 < s.2), ?_, by simpa using (by omega :
                (s.2 + (s.1 - 2 * s.2)) % 2 = 1)⟩
      have hdvd : Nat.gcd s.2 (s.1 - 2 * s.2) ∣ Nat.gcd s.1 s.2 := by
        refine Nat.dvd_gcd ?_ (Nat.gcd_dvd_left _ _)
        have h1 : Nat.gcd s.2 (s.1 - 2 * s.2) ∣ 2 * s.2 :=
          Dvd.dvd.mul_left (Nat.gcd_dvd_left _ _) 2
        have h2' : Nat.gcd s.2 (s.1 - 2 * s.2) ∣ s.1 - 2 * s.2 := Nat.gcd_dvd_right _ _
        have := Nat.dvd_add h2' h1
        simpa [show s.1 - 2 * s.2 + 2 * s.2 = s.1 by omega] using this
      simpa [hg] using Nat.eq_one_of_dvd_one (hg ▸ hdvd)
    · have hpar' : DepthDecay.parent s = (s.1 - 2 * s.2, s.2) := by
        simp [DepthDecay.parent, hA, hB]
      rw [hpar']
      refine ⟨by simpa using hp, by simpa using (by omega : s.2 < s.1 - 2 * s.2), ?_,
              by simpa using (by omega : (s.1 - 2 * s.2 + s.2) % 2 = 1)⟩
      have hdvd : Nat.gcd (s.1 - 2 * s.2) s.2 ∣ Nat.gcd s.1 s.2 := by
        refine Nat.dvd_gcd ?_ (Nat.gcd_dvd_right _ _)
        have h1 : Nat.gcd (s.1 - 2 * s.2) s.2 ∣ 2 * s.2 :=
          Dvd.dvd.mul_left (Nat.gcd_dvd_right _ _) 2
        have h2' : Nat.gcd (s.1 - 2 * s.2) s.2 ∣ s.1 - 2 * s.2 := Nat.gcd_dvd_left _ _
        have := Nat.dvd_add h2' h1
        simpa [show s.1 - 2 * s.2 + 2 * s.2 = s.1 by omega] using this
      simpa [hg] using Nat.eq_one_of_dvd_one (hg ▸ hdvd)

/-! ### The channel at depth one: the first letter is a magnitude readout -/

/-- **Depth-1 readability.**  For every admissible state the first descent letter
is an explicit function of the one-bit magnitude probe `⌊2m/n⌋`.  This is the
formal content of "the magnitude channel exists". -/
theorem letterOf_eq_letterFromProbe {s : ℕ × ℕ} (h : Adm s) :
    letterOf s = letterFromProbe (probe 1 s) := by
  obtain ⟨hp, hlt, hg, hpar⟩ := h
  have hAdm : Adm s := ⟨hp, hlt, hg, hpar⟩
  have h3 : s.1 ≠ 3 * s.2 := ne_three_mul hAdm
  have hprobe : probe 1 s = 2 * s.1 / s.2 := by simp [probe, pow_one]
  by_cases hA : s.1 < 2 * s.2
  · have hle : 2 * s.1 / s.2 < 4 := (Nat.div_lt_iff_lt_mul hp).2 (by omega)
    simp [letterOf, letterFromProbe, hprobe, hA, show 2 * s.1 / s.2 ≤ 3 by omega]
  · by_cases hB : s.1 < 3 * s.2
    · have h4 : 4 ≤ 2 * s.1 / s.2 := (Nat.le_div_iff_mul_le hp).2 (by omega)
      have h6 : 2 * s.1 / s.2 < 6 := (Nat.div_lt_iff_lt_mul hp).2 (by omega)
      simp [letterOf, letterFromProbe, hprobe, hA, hB, show ¬ (2 * s.1 / s.2 ≤ 3) by omega,
        show 2 * s.1 / s.2 ≤ 5 by omega]
    · have h6 : 6 ≤ 2 * s.1 / s.2 := (Nat.le_div_iff_mul_le hp).2 (by omega)
      simp [letterOf, letterFromProbe, hprobe, hA, hB, show ¬ (2 * s.1 / s.2 ≤ 3) by omega,
        show ¬ (2 * s.1 / s.2 ≤ 5) by omega]

/-- Two admissible states with the same one-bit probe have the same first letter. -/
theorem letterOf_eq_of_probe_one {s s' : ℕ × ℕ} (h : Adm s) (h' : Adm s')
    (hp : probe 1 s = probe 1 s') : letterOf s = letterOf s' := by
  rw [letterOf_eq_letterFromProbe h, letterOf_eq_letterFromProbe h', hp]

/-- A `C`-step shifts the one-bit probe down by exactly `4`. -/
theorem probe_one_parent_of_C {s : ℕ × ℕ} (h : Adm s) (hC : letterOf s = Letter.C) :
    probe 1 (parent s) + 4 = probe 1 s := by
  have hp := h.1
  have hA : ¬ s.1 < 2 * s.2 := by
    intro hA; rw [letterOf, if_pos hA] at hC; exact Letter.noConfusion hC
  have hB : ¬ s.1 < 3 * s.2 := by
    intro hB; rw [letterOf, if_neg hA, if_pos hB] at hC; exact Letter.noConfusion hC
  have hpar : parent s = (s.1 - 2 * s.2, s.2) := by simp [parent, hA, hB]
  have hsplit : 2 * s.1 = 2 * (s.1 - 2 * s.2) + 4 * s.2 := by omega
  simp only [probe, pow_one, hpar, hsplit]
  rw [show 2 * (s.1 - 2 * s.2) + 4 * s.2 = 2 * (s.1 - 2 * s.2) + s.2 * 4 by ring,
    Nat.add_mul_div_left _ _ hp]

/-- Stepping the path index: `letterAt (k+1) s = letterAt k (parent s)`. -/
theorem letterAt_succ (k : ℕ) (s : ℕ × ℕ) : letterAt (k + 1) s = letterAt k (parent s) := by
  simp [letterAt, Function.iterate_succ_apply]

/-- **The readable prefix.**  If two admissible states share the one-bit probe,
their descent letters agree at every depth up to and including the first non-`C`
letter.  (The hypothesis constrains only `s`: the agreement of the earlier
letters propagates to `s'` automatically.) -/
theorem letterAt_eq_of_probe_one_of_prefix_C :
    ∀ (k : ℕ) {s s' : ℕ × ℕ}, Adm s → Adm s' → probe 1 s = probe 1 s' →
      (∀ j < k, letterAt j s = Letter.C) → letterAt k s = letterAt k s' := by
  intro k
  induction k with
  | zero =>
    intro s s' h h' hp _
    simpa [letterAt] using letterOf_eq_of_probe_one h h' hp
  | succ k ih =>
    intro s s' h h' hp hC
    have hC0 : letterOf s = Letter.C := by simpa [letterAt] using hC 0 (Nat.succ_pos k)
    have hC0' : letterOf s' = Letter.C := by
      rw [← letterOf_eq_of_probe_one h h' hp]; exact hC0
    have hroot : ∀ t : ℕ × ℕ, Adm t → letterOf t = Letter.C → t ≠ root := by
      intro t _ hCt hEq
      rw [hEq] at hCt
      simp [letterOf, root] at hCt
    have hpp : probe 1 (parent s) = probe 1 (parent s') := by
      have e1 := probe_one_parent_of_C h hC0
      have e2 := probe_one_parent_of_C h' hC0'
      omega
    have hprefix : ∀ j < k, letterAt j (parent s) = Letter.C := by
      intro j hj
      have := hC (j + 1) (by omega)
      rwa [letterAt_succ] at this
    have := ih (h.parent (hroot s h hC0)) (h'.parent (hroot s' h' hC0')) hpp hprefix
    rw [letterAt_succ, letterAt_succ]
    exact this

/-! ### Depth itself is visible: the leading `C`-run length is one division -/

/-- Quantitative form of "the ratio is still above the `C` threshold at step `j`". -/
theorem run_bound {s : ℕ × ℕ} (h : Adm s) {j : ℕ} (hj : j < (s.1 - s.2) / (2 * s.2)) :
    2 * j * s.2 + 3 * s.2 < s.1 := by
  obtain ⟨hp, hlt, hg, hpar⟩ := h
  have hAdm : Adm s := ⟨hp, hlt, hg, hpar⟩
  have h2p : 0 < 2 * s.2 := by omega
  have hstep : (j + 1) * (2 * s.2) ≤ s.1 - s.2 := (Nat.le_div_iff_mul_le h2p).1 hj
  have hle : (2 * j + 3) * s.2 ≤ s.1 :=
    calc (2 * j + 3) * s.2 = (j + 1) * (2 * s.2) + s.2 := by ring
      _ ≤ (s.1 - s.2) + s.2 := Nat.add_le_add_right hstep _
      _ = s.1 := Nat.sub_add_cancel (le_of_lt hlt)
  have hne : s.1 ≠ (2 * j + 3) * s.2 := ne_odd_mul hAdm j
  have hexp : (2 * j + 3) * s.2 = 2 * j * s.2 + 3 * s.2 := by ring
  omega

/-- Iterating the `C`-branch of the descent: the first `(m-n)/(2n)` steps are all
translations `r ↦ r - 2` of the ratio. -/
theorem iterate_parent_C_run {s : ℕ × ℕ} (h : Adm s) :
    ∀ j ≤ (s.1 - s.2) / (2 * s.2), parent^[j] s = (s.1 - 2 * j * s.2, s.2) := by
  intro j
  induction j with
  | zero => intro _; simp
  | succ j ih =>
    intro hj
    have hjlt : j < (s.1 - s.2) / (2 * s.2) := by omega
    have hbnd := run_bound h hjlt
    have hexp2 : 2 * (j + 1) * s.2 = 2 * j * s.2 + 2 * s.2 := by ring
    rw [Function.iterate_succ_apply', ih (le_of_lt hjlt)]
    have hA : ¬ (s.1 - 2 * j * s.2) < 2 * s.2 := by omega
    have hB : ¬ (s.1 - 2 * j * s.2) < 3 * s.2 := by omega
    have hsub : s.1 - 2 * j * s.2 - 2 * s.2 = s.1 - 2 * (j + 1) * s.2 := by omega
    simp only [parent, hA, hB, if_false, hsub]

/-- **Depth is visible.**  Every descent letter before index `(m - n) / (2n)`
is `C`; the leading `C`-run length is read off by a single integer division of
the magnitude data. -/
theorem cRun_letters_C {s : ℕ × ℕ} (h : Adm s) :
    ∀ j < (s.1 - s.2) / (2 * s.2), letterAt j s = Letter.C := by
  intro j hj
  have hiter := iterate_parent_C_run h j (le_of_lt hj)
  have hbnd := run_bound h hj
  have hA : ¬ (s.1 - 2 * j * s.2) < 2 * s.2 := by omega
  have hB : ¬ (s.1 - 2 * j * s.2) < 3 * s.2 := by omega
  simp [letterAt, hiter, letterOf, hA, hB]

/-- **The run stops exactly there.**  The letter at index `(m - n) / (2n)` is not
`C`, so the leading `C`-run has length exactly `(m - n) / (2n)`. -/
theorem cRun_letterAt_ne_C {s : ℕ × ℕ} (h : Adm s) :
    letterAt ((s.1 - s.2) / (2 * s.2)) s ≠ Letter.C := by
  obtain ⟨hp, hlt, hg, hpar⟩ := h
  have hAdm : Adm s := ⟨hp, hlt, hg, hpar⟩
  have h2p : 0 < 2 * s.2 := by omega
  set L := (s.1 - s.2) / (2 * s.2) with hL
  have hiter := iterate_parent_C_run hAdm L le_rfl
  have hdm : 2 * s.2 * L + (s.1 - s.2) % (2 * s.2) = s.1 - s.2 := by
    rw [hL]; exact Nat.div_add_mod (s.1 - s.2) (2 * s.2)
  have hmod : (s.1 - s.2) % (2 * s.2) < 2 * s.2 := Nat.mod_lt _ h2p
  have hexp : 2 * s.2 * L = 2 * L * s.2 := by ring
  have hB : s.1 - 2 * L * s.2 < 3 * s.2 := by omega
  by_cases hA : s.1 - 2 * L * s.2 < 2 * s.2
  · simp [letterAt, hiter, letterOf, hA]
  · simp [letterAt, hiter, letterOf, hA, hB]

/-- **Summary of the readable channel.**  For an admissible state, the leading
`C`-run has length exactly `L = (m-n)/(2n)`, and any second admissible state with
the same one-bit magnitude probe reproduces all letters `0, …, L` — the whole
`C`-run *and* the first inversion letter. -/
theorem readable_prefix_length {s s' : ℕ × ℕ} (h : Adm s) (h' : Adm s')
    (hp : probe 1 s = probe 1 s') :
    (∀ j < (s.1 - s.2) / (2 * s.2), letterAt j s = Letter.C) ∧
      letterAt ((s.1 - s.2) / (2 * s.2)) s ≠ Letter.C ∧
      ∀ j ≤ (s.1 - s.2) / (2 * s.2), letterAt j s = letterAt j s' := by
  refine ⟨cRun_letters_C h, cRun_letterAt_ne_C h, ?_⟩
  intro j hj
  exact letterAt_eq_of_probe_one_of_prefix_C j h h' hp
    (fun i hi => cRun_letters_C h i (lt_of_lt_of_le hi hj))

/-- **The price of depth.**  The readable `C`-run length is bounded by a quarter
of the sensor's *reading*: to see depth `L` the one-bit probe must return a value
of size at least `4L`, i.e. `log₂ L` output bits.  Depth is visible, but only
logarithmically cheaply. -/
theorem cRun_le_probe {s : ℕ × ℕ} (h : Adm s) :
    (s.1 - s.2) / (2 * s.2) ≤ probe 1 s / 4 := by
  obtain ⟨hp, hlt, hg, hpar⟩ := h
  have h2p : 0 < 2 * s.2 := by omega
  set L := (s.1 - s.2) / (2 * s.2) with hL
  have hlower : L * (2 * s.2) ≤ s.1 - s.2 := Nat.div_mul_le_self _ _
  have hexp : L * (2 * s.2) = 2 * L * s.2 := by ring
  have hmain : L * 4 * s.2 ≤ 2 * s.1 := by
    have : 2 * (2 * L * s.2) ≤ 2 * (s.1 - s.2) := by omega
    have h4 : L * 4 * s.2 = 2 * (2 * L * s.2) := by ring
    omega
  have hstep : L * 4 ≤ 2 * s.1 / s.2 := (Nat.le_div_iff_mul_le hp).2 hmain
  have : L ≤ (2 * s.1 / s.2) / 4 := (Nat.le_div_iff_mul_le (by norm_num)).2 hstep
  simpa [probe, pow_one] using this

end DepthDecay