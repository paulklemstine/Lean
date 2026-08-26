import Cryptography.DepthDecay.WindowSensor

/-!
# The magnitude channel is null beyond the first inversion

`Cryptography.DepthDecay.WindowSensor` shows that a one-bit magnitude probe of an
admissible pair `(m,n)` already determines the whole leading `C`-run of the
Berggren descent *and* the inversion letter that terminates it.  Here we prove
the matching negative statement, which is the formal content of the observed
depth decay of the magnitude channel:

> **No fixed window budget `W` determines the letter that follows the first
> inversion, at any prescribed depth.**

For every window budget `W`, every depth `k` and every admissible scale `q` we
construct two admissible pairs `sP q k` and `sM q k` whose `2^W`-window probes are
*equal*, whose descent paths agree on the whole prefix of length `k+1` (namely
`C^k B`), and which nevertheless differ at depth `k+1`.

The construction is the two sides of the non-dyadic branch boundary `r = 7/3` of
the second Gauss digit:

* `sP q k = ((7+6k)q + 1, 3q)`, ratio `7/3 + 2k + 1/(3q)`,
* `sM q k = ((7+6k)q - 1, 3q)`, ratio `7/3 + 2k - 1/(3q)`.

As soon as `2^W < q` both ratios lie in the same dyadic interval of width `2^{-W}`
— the sensor cannot separate them — yet after the `k` translations `r ↦ r-2` and
the inversion `r ↦ 1/(r-2)` the images straddle the cut point `3`, and the next
letters are `B` and `C` respectively.  The information the sensor would need is
the *fine* Gauss digit of the ratio, which no fixed-precision window supplies.

Because `q` is free, the counterexamples occur at arbitrarily large denominators:
see `depth_null_unbounded`.
-/

namespace DepthDecay

/-! ### The straddling pair -/

/-- The state just above the boundary `7/3 + 2k`, at scale `q`. -/
def sP (q k : ℕ) : ℕ × ℕ := ((7 + 6 * k) * q + 1, 3 * q)

/-- The state just below the boundary `7/3 + 2k`, at scale `q`. -/
def sM (q k : ℕ) : ℕ × ℕ := ((7 + 6 * k) * q - 1, 3 * q)

/-- The canonical scale for window budget `W`: `q = 6·2^W`. -/
def qOf (W : ℕ) : ℕ := 6 * 2 ^ W

/-- A scale exceeding any prescribed size `N`, still adapted to budget `W`. -/
def qOfN (W N : ℕ) : ℕ := 6 * 2 ^ W * (N + 1)

/-- The canonical straddling states for budget `W` and depth `k`. -/
def sPlus (W k : ℕ) : ℕ × ℕ := sP (qOf W) k

/-- The canonical straddling states for budget `W` and depth `k`. -/
def sMinus (W k : ℕ) : ℕ × ℕ := sM (qOf W) k

theorem six_le_qOf (W : ℕ) : 6 ≤ qOf W := by
  have h : 1 ≤ 2 ^ W := Nat.one_le_two_pow
  simp only [qOf]; omega

theorem two_dvd_qOf (W : ℕ) : 2 ∣ qOf W := ⟨3 * 2 ^ W, by simp only [qOf]; ring⟩

theorem three_dvd_qOf (W : ℕ) : 3 ∣ qOf W := ⟨2 * 2 ^ W, by simp only [qOf]; ring⟩

theorem pow_lt_qOf (W : ℕ) : 2 ^ W < qOf W := by
  have h : 1 ≤ 2 ^ W := Nat.one_le_two_pow
  simp only [qOf]; omega

theorem six_le_qOfN (W N : ℕ) : 6 ≤ qOfN W N := by
  have h : 1 ≤ 2 ^ W := Nat.one_le_two_pow
  have : 6 * 1 * 1 ≤ 6 * 2 ^ W * (N + 1) :=
    Nat.mul_le_mul (Nat.mul_le_mul_left 6 h) (by omega)
  simpa [qOfN] using this

theorem two_dvd_qOfN (W N : ℕ) : 2 ∣ qOfN W N := ⟨3 * 2 ^ W * (N + 1), by simp only [qOfN]; ring⟩

theorem three_dvd_qOfN (W N : ℕ) : 3 ∣ qOfN W N := ⟨2 * 2 ^ W * (N + 1), by simp only [qOfN]; ring⟩

theorem pow_lt_qOfN (W N : ℕ) : 2 ^ W < qOfN W N := by
  have hpow : 0 < 2 ^ W := Nat.two_pow_pos W
  have h : 2 ^ W * 1 < 2 ^ W * (6 * (N + 1)) :=
    (Nat.mul_lt_mul_left hpow).2 (by omega)
  have he : 2 ^ W * (6 * (N + 1)) = qOfN W N := by simp only [qOfN]; ring
  omega

theorem lt_three_mul_qOfN (W N : ℕ) : N < 3 * qOfN W N := by
  have hpow : 1 ≤ 2 ^ W := Nat.one_le_two_pow
  have h : 1 * (N + 1) ≤ 2 ^ W * (N + 1) := Nat.mul_le_mul_right _ hpow
  have he : 3 * qOfN W N = 18 * (2 ^ W * (N + 1)) := by simp only [qOfN]; ring
  omega

/-! ### Admissibility of the straddling pair -/

theorem adm_add_one {q K : ℕ} (hq6 : 6 ≤ q) (h2 : 2 ∣ q) (h3 : 3 ∣ q) (hK : 7 ≤ K) :
    Adm (K * q + 1, 3 * q) := by
  obtain ⟨u, hu⟩ := h2
  have hKq : 7 * q ≤ K * q := Nat.mul_le_mul_right q hK
  have hKu : K * q = 2 * (K * u) := by rw [hu]; ring
  refine ⟨by simp; omega, by simp; omega, ?_, by simp; omega⟩
  simp only []
  set g := Nat.gcd (K * q + 1) (3 * q) with hgdef
  have hg1 : g ∣ K * q + 1 := Nat.gcd_dvd_left _ _
  have hg2 : g ∣ 3 * q := Nat.gcd_dvd_right _ _
  have h3Kq : 3 ∣ K * q := Dvd.dvd.mul_left h3 K
  have hg3 : g ∣ 3 := by
    have ha : g ∣ 3 * (K * q + 1) := hg1.mul_left 3
    have hb : g ∣ K * (3 * q) := hg2.mul_left K
    have e : 3 * (K * q + 1) = K * (3 * q) + 3 := by ring
    rw [e] at ha
    simpa using Nat.dvd_sub ha hb
  rcases (Nat.prime_three).eq_one_or_self_of_dvd g hg3 with h | h
  · exact h
  · exfalso
    rw [h] at hg1
    have : (3 : ℕ) ∣ 1 := by simpa using Nat.dvd_sub hg1 h3Kq
    omega

theorem adm_sub_one {q K : ℕ} (hq6 : 6 ≤ q) (h2 : 2 ∣ q) (h3 : 3 ∣ q) (hK : 7 ≤ K) :
    Adm (K * q - 1, 3 * q) := by
  obtain ⟨u, hu⟩ := h2
  have hKq : 7 * q ≤ K * q := Nat.mul_le_mul_right q hK
  have hKu : K * q = 2 * (K * u) := by rw [hu]; ring
  refine ⟨by simp; omega, by simp; omega, ?_, by simp; omega⟩
  simp only []
  set g := Nat.gcd (K * q - 1) (3 * q) with hgdef
  have hg1 : g ∣ K * q - 1 := Nat.gcd_dvd_left _ _
  have hg2 : g ∣ 3 * q := Nat.gcd_dvd_right _ _
  have h3Kq : 3 ∣ K * q := Dvd.dvd.mul_left h3 K
  have hg3 : g ∣ 3 := by
    have ha : g ∣ 3 * (K * q - 1) := hg1.mul_left 3
    have hb : g ∣ K * (3 * q) := hg2.mul_left K
    have e : K * (3 * q) = 3 * (K * q - 1) + 3 := by
      have : K * (3 * q) = 3 * (K * q) := by ring
      omega
    rw [e] at hb
    simpa using Nat.dvd_sub hb ha
  rcases (Nat.prime_three).eq_one_or_self_of_dvd g hg3 with h | h
  · exact h
  · exfalso
    rw [h] at hg1
    have : (3 : ℕ) ∣ 1 := by
      have h := Nat.dvd_sub h3Kq hg1
      rw [show K * q - (K * q - 1) = 1 by omega] at h
      exact h
    omega

theorem adm_sP {q : ℕ} (hq6 : 6 ≤ q) (h2 : 2 ∣ q) (h3 : 3 ∣ q) (k : ℕ) : Adm (sP q k) :=
  adm_add_one hq6 h2 h3 (by omega)

theorem adm_sM {q : ℕ} (hq6 : 6 ≤ q) (h2 : 2 ∣ q) (h3 : 3 ∣ q) (k : ℕ) : Adm (sM q k) :=
  adm_sub_one hq6 h2 h3 (by omega)

theorem adm_sPlus (W k : ℕ) : Adm (sPlus W k) :=
  adm_sP (six_le_qOf W) (two_dvd_qOf W) (three_dvd_qOf W) k

theorem adm_sMinus (W k : ℕ) : Adm (sMinus W k) :=
  adm_sM (six_le_qOf W) (two_dvd_qOf W) (three_dvd_qOf W) k

/-! ### The window sensor cannot separate the pair -/

/-- **Probe collision.**  The two straddling states have the *same* `W`-window
magnitude probe as soon as the scale exceeds the window resolution: their ratios
differ by `2/(3q) < 2^{-W}`, and `7/3` is not a dyadic rational, so no `W`-bit
truncation separates them. -/
theorem probe_sP_eq_sM {W q : ℕ} (hqpos : 0 < q) (hMq : 2 ^ W < q) (k : ℕ) :
    probe W (sP q k) = probe W (sM q k) := by
  set M := 2 ^ W with hM
  set K := 7 + 6 * k with hK
  have hMpos : 0 < M := Nat.one_le_two_pow
  -- the residue of `M*K` mod 3 is nonzero
  have h3M : ¬ (3 ∣ M) := by
    intro h
    have := (Nat.prime_three).dvd_of_dvd_pow (n := W) (by simpa [hM] using h)
    omega
  have hK3 : K % 3 = 1 := by omega
  have hMK3 : (M * K) % 3 ≠ 0 := by
    rw [Nat.mul_mod, hK3]
    have : M % 3 ≠ 0 := fun h => h3M (Nat.dvd_of_mod_eq_zero h)
    have : M % 3 < 3 := Nat.mod_lt _ (by norm_num)
    omega
  set t := (M * K) / 3 with ht
  set r := (M * K) % 3 with hr
  have hdm : 3 * t + r = M * K := by rw [ht, hr]; exact Nat.div_add_mod _ _
  have hrlt : r < 3 := Nat.mod_lt _ (by norm_num)
  have hr0 : r ≠ 0 := hMK3
  -- expansion of both numerators around the common quotient `t`
  have hbase : M * (K * q) = 3 * q * t + r * q := by
    calc M * (K * q) = (M * K) * q := by ring
      _ = (3 * t + r) * q := by rw [hdm]
      _ = 3 * q * t + r * q := by ring
  have hKq1 : 1 ≤ K * q := by
    have : 7 * q ≤ K * q := Nat.mul_le_mul_right q (by omega)
    omega
  have hsub : M * (K * q - 1) = M * (K * q) - M := by
    rw [Nat.mul_sub, Nat.mul_one]
  have hlt1 : r * q + M < 3 * q := by
    have h2 : r * q ≤ 2 * q := Nat.mul_le_mul_right q (by omega)
    omega
  have hge : M ≤ r * q := by
    have h1 : 1 * q ≤ r * q := Nat.mul_le_mul_right q (by omega)
    omega
  have hplus : M * ((K * q) + 1) = (r * q + M) + 3 * q * t := by
    have : M * (K * q + 1) = M * (K * q) + M := by ring
    omega
  have hminus : M * (K * q - 1) = (r * q - M) + 3 * q * t := by omega
  have h3q : 0 < 3 * q := by omega
  have e1 : ((r * q + M) + 3 * q * t) / (3 * q) = t := by
    rw [Nat.add_mul_div_left _ _ h3q, Nat.div_eq_of_lt hlt1, Nat.zero_add]
  have e2 : ((r * q - M) + 3 * q * t) / (3 * q) = t := by
    rw [Nat.add_mul_div_left _ _ h3q, Nat.div_eq_of_lt (by omega), Nat.zero_add]
  simp only [probe, sP, sM, ← hM, ← hK]
  rw [hplus, hminus, e1, e2]

/-! ### The common prefix `C^k B` -/

/-- Iterating the `C`-branch on states with denominator `3q`. -/
theorem iterate_parent_bigC {q : ℕ} (hq : 0 < q) :
    ∀ (j m : ℕ), 9 * q + 6 * j * q < m + 6 * q →
      parent^[j] (m, 3 * q) = (m - 6 * j * q, 3 * q) := by
  intro j
  induction j with
  | zero => intro m _; simp
  | succ j ih =>
    intro m hm
    have hexp : 6 * (j + 1) * q = 6 * j * q + 6 * q := by ring
    have h9 : 9 * q < m := by omega
    have hA : ¬ m < 2 * (3 * q) := by omega
    have hB : ¬ m < 3 * (3 * q) := by omega
    have harith : m - 2 * (3 * q) = m - 6 * q := by omega
    have hstep : parent (m, 3 * q) = (m - 6 * q, 3 * q) := by
      simp only [parent, hA, hB, if_false, harith]
    rw [Function.iterate_succ_apply, hstep, ih (m - 6 * q) (by omega)]
    have hfin : m - 6 * q - 6 * j * q = m - 6 * (j + 1) * q := by omega
    rw [hfin]

/-- A state with denominator `3q` whose numerator is still above `9q` has letter `C`. -/
theorem letterAt_C_of_big {q : ℕ} (hq : 0 < q) {m j : ℕ}
    (hm : 9 * q + 6 * j * q < m) : letterAt j (m, 3 * q) = Letter.C := by
  have hiter := iterate_parent_bigC hq j m (by omega)
  have hA : ¬ (m - 6 * j * q) < 2 * (3 * q) := by omega
  have hB : ¬ (m - 6 * j * q) < 3 * (3 * q) := by omega
  simp [letterAt, hiter, letterOf, hA, hB]

theorem iter_k_sP {q : ℕ} (hq : 0 < q) (k : ℕ) : parent^[k] (sP q k) = (7 * q + 1, 3 * q) := by
  have hring : (7 + 6 * k) * q = 7 * q + 6 * k * q := by ring
  have hiter := iterate_parent_bigC hq k ((7 + 6 * k) * q + 1) (by omega)
  have hfin : (7 + 6 * k) * q + 1 - 6 * k * q = 7 * q + 1 := by omega
  rw [sP, hiter, hfin]

theorem iter_k_sM {q : ℕ} (hq : 0 < q) (k : ℕ) : parent^[k] (sM q k) = (7 * q - 1, 3 * q) := by
  have hring : (7 + 6 * k) * q = 7 * q + 6 * k * q := by ring
  have hiter := iterate_parent_bigC hq k ((7 + 6 * k) * q - 1) (by omega)
  have hfin : (7 + 6 * k) * q - 1 - 6 * k * q = 7 * q - 1 := by omega
  rw [sM, hiter, hfin]

/-- Both straddling states have letter `C` at every depth below `k`. -/
theorem letters_prefix_C {q : ℕ} (hq : 0 < q) (k : ℕ) :
    ∀ j < k, letterAt j (sP q k) = Letter.C ∧ letterAt j (sM q k) = Letter.C := by
  intro j hj
  have hring : (7 + 6 * k) * q = 7 * q + 6 * k * q := by ring
  have hmul : 6 * (j + 1) * q ≤ 6 * k * q := Nat.mul_le_mul_right _ (by omega)
  have hexp : 6 * (j + 1) * q = 6 * j * q + 6 * q := by ring
  exact ⟨letterAt_C_of_big hq (m := (7 + 6 * k) * q + 1) (by omega),
         letterAt_C_of_big hq (m := (7 + 6 * k) * q - 1) (by omega)⟩

/-- At depth `k` both states perform the same inversion, letter `B`. -/
theorem letters_at_k {q : ℕ} (hq6 : 6 ≤ q) (k : ℕ) :
    letterAt k (sP q k) = Letter.B ∧ letterAt k (sM q k) = Letter.B := by
  have hq : 0 < q := by omega
  constructor
  · rw [letterAt, iter_k_sP hq]
    have hA : ¬ (7 * q + 1) < 2 * (3 * q) := by omega
    have hB : (7 * q + 1) < 3 * (3 * q) := by omega
    simp [letterOf, hA, hB]
  · rw [letterAt, iter_k_sM hq]
    have hA : ¬ (7 * q - 1) < 2 * (3 * q) := by omega
    have hB : (7 * q - 1) < 3 * (3 * q) := by omega
    simp [letterOf, hA, hB]

/-! ### Divergence one step later -/

/-- After the inversion the two states are separated: `sP` continues with `B`,
`sM` with `C`.  This is the letter no fixed window can read. -/
theorem letters_at_succ_k {q : ℕ} (hq6 : 6 ≤ q) (k : ℕ) :
    letterAt (k + 1) (sP q k) = Letter.B ∧ letterAt (k + 1) (sM q k) = Letter.C := by
  have hq : 0 < q := by omega
  constructor
  · rw [letterAt, Function.iterate_succ_apply', iter_k_sP hq]
    have hA : ¬ (7 * q + 1) < 2 * (3 * q) := by omega
    have hB : (7 * q + 1) < 3 * (3 * q) := by omega
    have hstep : parent (7 * q + 1, 3 * q) = (3 * q, q + 1) := by
      have harith : 7 * q + 1 - 2 * (3 * q) = q + 1 := by omega
      simp only [parent, hA, hB, if_true, if_false, harith]
    rw [hstep]
    have hA2 : ¬ (3 * q) < 2 * (q + 1) := by omega
    have hB2 : (3 * q) < 3 * (q + 1) := by omega
    simp [letterOf, hA2, hB2]
  · rw [letterAt, Function.iterate_succ_apply', iter_k_sM hq]
    have hA : ¬ (7 * q - 1) < 2 * (3 * q) := by omega
    have hB : (7 * q - 1) < 3 * (3 * q) := by omega
    have hstep : parent (7 * q - 1, 3 * q) = (3 * q, q - 1) := by
      have harith : 7 * q - 1 - 2 * (3 * q) = q - 1 := by omega
      simp only [parent, hA, hB, if_true, if_false, harith]
    rw [hstep]
    have hA2 : ¬ (3 * q) < 2 * (q - 1) := by omega
    have hB2 : ¬ (3 * q) < 3 * (q - 1) := by omega
    simp [letterOf, hA2, hB2]

/-! ### Main theorems -/

/-- The straddling pair at any admissible scale is a `W`-window collision that
diverges exactly one step after the inversion. -/
theorem straddle_collision {W q : ℕ} (hq6 : 6 ≤ q) (h2 : 2 ∣ q) (h3 : 3 ∣ q)
    (hMq : 2 ^ W < q) (k : ℕ) :
    Adm (sP q k) ∧ Adm (sM q k) ∧ probe W (sP q k) = probe W (sM q k) ∧
      (∀ j ≤ k, letterAt j (sP q k) = letterAt j (sM q k)) ∧
      letterAt (k + 1) (sP q k) ≠ letterAt (k + 1) (sM q k) := by
  have hq : 0 < q := by omega
  refine ⟨adm_sP hq6 h2 h3 k, adm_sM hq6 h2 h3 k, probe_sP_eq_sM hq hMq k, ?_, ?_⟩
  · intro j hj
    rcases lt_or_eq_of_le hj with h | h
    · obtain ⟨h1, h2⟩ := letters_prefix_C hq k j h
      rw [h1, h2]
    · subst h
      obtain ⟨h1, h2⟩ := letters_at_k hq6 j
      rw [h1, h2]
  · obtain ⟨h1, h2⟩ := letters_at_succ_k hq6 k
    rw [h1, h2]
    exact fun h => Letter.noConfusion h

/-- **DEPTH-DECAY TO NULL.**  For every window budget `W` and every depth `k`
there are two admissible Berggren states which

* are *indistinguishable* to the `W`-window magnitude sensor (`probe W` agrees),
* have *identical* descent letters at every depth `j ≤ k` (the prefix `C^k B`),
* yet have *different* letters at depth `k+1`.

Hence no fixed-precision magnitude functional of the state carries any
information about the descent letter following the first inversion, at any
depth.  Combined with `readable_prefix_length`, which shows that the one-bit
probe already reads the entire `C`-run and its terminating inversion letter,
this pins the reach of the magnitude channel exactly. -/
theorem depth_null_beyond_first_inversion (W k : ℕ) :
    ∃ s s' : ℕ × ℕ, Adm s ∧ Adm s' ∧ probe W s = probe W s' ∧
      (∀ j ≤ k, letterAt j s = letterAt j s') ∧
      letterAt (k + 1) s ≠ letterAt (k + 1) s' :=
  ⟨sPlus W k, sMinus W k,
    straddle_collision (six_le_qOf W) (two_dvd_qOf W) (three_dvd_qOf W) (pow_lt_qOf W) k⟩

/-- **The counterexamples are unbounded.**  The same collision occurs at
arbitrarily large denominators, so the failure of the magnitude channel is not a
small-state artefact: for every prescribed size `N` there is a colliding pair
with denominator larger than `N`. -/
theorem depth_null_unbounded (W k N : ℕ) :
    ∃ s s' : ℕ × ℕ, N < s.2 ∧ N < s'.2 ∧ Adm s ∧ Adm s' ∧ probe W s = probe W s' ∧
      (∀ j ≤ k, letterAt j s = letterAt j s') ∧
      letterAt (k + 1) s ≠ letterAt (k + 1) s' := by
  refine ⟨sP (qOfN W N) k, sM (qOfN W N) k, lt_three_mul_qOfN W N, lt_three_mul_qOfN W N, ?_⟩
  exact straddle_collision (six_le_qOfN W N) (two_dvd_qOfN W N) (three_dvd_qOfN W N)
    (pow_lt_qOfN W N) k

/-- Restatement: the depth-`(k+1)` letter is **not** a function of the window
probe, for any budget `W` and any depth `k`. -/
theorem letterAt_not_probe_measurable (W k : ℕ) :
    ¬ ∃ f : ℕ → Letter, ∀ s : ℕ × ℕ, Adm s → letterAt (k + 1) s = f (probe W s) := by
  rintro ⟨f, hf⟩
  obtain ⟨s, s', hs, hs', hprobe, _, hne⟩ := depth_null_beyond_first_inversion W k
  exact hne (by rw [hf s hs, hf s' hs', hprobe])

/-! ### Sharp threshold, and the surviving `C`-spine -/

/-- **The threshold is sharp.**  Depth `1` is always readable from a one-bit
probe; depth `2` is already null for every window budget. -/
theorem depth_threshold_sharp :
    (∀ s s' : ℕ × ℕ, Adm s → Adm s' → probe 1 s = probe 1 s' → letterAt 0 s = letterAt 0 s') ∧
      (∀ W : ℕ, ∃ s s' : ℕ × ℕ, Adm s ∧ Adm s' ∧ probe W s = probe W s' ∧
        letterAt 0 s = letterAt 0 s' ∧ letterAt 1 s ≠ letterAt 1 s') := by
  refine ⟨fun s s' h h' hp => by simpa [letterAt] using letterOf_eq_of_probe_one h h' hp,
    fun W => ?_⟩
  obtain ⟨s, s', hs, hs', hprobe, hpre, hne⟩ := depth_null_beyond_first_inversion W 0
  exact ⟨s, s', hs, hs', hprobe, hpre 0 le_rfl, hne⟩

/-- **The decay is about inversions, not about depth.**  Along the all-`C` spine
the one-bit probe reads arbitrarily many letters: the state `(2L+2, 1)` has a
leading `C`-run of length `L`, and every admissible state with the same one-bit
probe reproduces all of `letterAt 0, …, letterAt L`. -/
theorem cSpine_readable (L : ℕ) :
    Adm (2 * L + 2, 1) ∧ (∀ j < L, letterAt j (2 * L + 2, 1) = Letter.C) ∧
      (∀ s' : ℕ × ℕ, Adm s' → probe 1 (2 * L + 2, 1) = probe 1 s' →
        ∀ j ≤ L, letterAt j (2 * L + 2, 1) = letterAt j s') := by
  have hAdm : Adm (2 * L + 2, 1) := by
    refine ⟨by norm_num, ?_, ?_, ?_⟩
    · show (1 : ℕ) < 2 * L + 2
      omega
    · show Nat.gcd (2 * L + 2) 1 = 1
      simp
    · show (2 * L + 2 + 1) % 2 = 1
      omega
  have hrun : ∀ j < L, letterAt j (2 * L + 2, 1) = Letter.C := by
    intro j hj
    exact cRun_letters_C hAdm j (by show j < ((2 * L + 2 : ℕ) - 1) / (2 * 1); omega)
  refine ⟨hAdm, hrun, ?_⟩
  intro s' h' hp j hj
  exact letterAt_eq_of_probe_one_of_prefix_C j hAdm h' hp
    (fun i hi => hrun i (lt_of_lt_of_le hi hj))

end DepthDecay