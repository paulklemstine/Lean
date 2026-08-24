import Cryptography.DepthDecay.WindowSensor

/-!
# Every rational-scale magnitude sensor is null beyond the first inversion

`Cryptography.DepthDecay.NullBeyondInversion` defeats the dyadic window sensor
`⌊2^W · m/n⌋`.  One might hope that the failure is an artefact of *binary*
truncation — after all, the offending boundary `7/3` is invisible to base `2` but
plainly visible to base `3`.  This file shows that no change of scale helps.

For arbitrary positive integers `a, b` consider the sensor

  `gprobe a b (m,n) = ⌊(a/b) · (m/n)⌋`,

i.e. any monotone rational rescaling of the magnitude followed by truncation
(`gprobe (2^W) 1 = probe W`).  We prove: **for every scale `a/b` and every depth
`k` the sensor confuses two admissible states which agree on the whole prefix
`C^k B` and differ at depth `k+1`.**

The mechanism is different from — and stronger than — the `7/3` straddle.  Here
the boundary `5/2 + 2k` is *attained* by the admissible state `(4k+5, 2)`, whose
inversion lands exactly on the root; states just above it invert to ratios below
`2` and take the letter `A`.  Since `⌊·⌋` is right-continuous, no truncation
sensor of any scale can separate an attained boundary from its right neighbours.
-/

namespace DepthDecay

/-- A magnitude sensor of arbitrary rational scale: `⌊(a/b)·(m/n)⌋`. -/
def gprobe (a b : ℕ) (s : ℕ × ℕ) : ℕ := a * s.1 / (b * s.2)

/-- The dyadic window sensor is the case `a = 2^W`, `b = 1`. -/
theorem gprobe_pow_one (W : ℕ) (s : ℕ × ℕ) : gprobe (2 ^ W) 1 s = probe W s := by
  simp [gprobe, probe]

/-- The boundary state: ratio exactly `5/2 + 2k`, whose inversion hits the root. -/
def tBoundary (k : ℕ) : ℕ × ℕ := (4 * k + 5, 2)

/-- A state just above the boundary, at resolution `1/(2u)`. -/
def tAbove (k u : ℕ) : ℕ × ℕ := ((4 * k + 5) * u + 1, 2 * u)

/-! ### Admissibility -/

theorem adm_tBoundary (k : ℕ) : Adm (tBoundary k) := by
  refine ⟨by norm_num [tBoundary], ?_, ?_, ?_⟩
  · show (2 : ℕ) < 4 * k + 5
    omega
  · show Nat.gcd (4 * k + 5) 2 = 1
    have h : (4 * k + 5) % 2 = 1 := by omega
    rw [Nat.gcd_comm, Nat.gcd_rec, h]
    simp
  · show (4 * k + 5 + 2) % 2 = 1
    omega

theorem adm_tAbove {k u : ℕ} (hu : 2 ≤ u) (hue : u % 2 = 0) : Adm (tAbove k u) := by
  have hmul : 2 ∣ (4 * k + 5) * u := Dvd.dvd.mul_left (Nat.dvd_of_mod_eq_zero hue) _
  obtain ⟨v, hv⟩ := hmul
  have hbig : 3 * u ≤ (4 * k + 5) * u := Nat.mul_le_mul_right u (by omega)
  refine ⟨by simp [tAbove]; omega, by simp [tAbove]; omega, ?_, by simp [tAbove]; omega⟩
  show Nat.gcd ((4 * k + 5) * u + 1) (2 * u) = 1
  set g := Nat.gcd ((4 * k + 5) * u + 1) (2 * u) with hgdef
  have hg1 : g ∣ (4 * k + 5) * u + 1 := Nat.gcd_dvd_left _ _
  have hg2 : g ∣ 2 * u := Nat.gcd_dvd_right _ _
  have hg2' : g ∣ 2 := by
    have ha : g ∣ 2 * ((4 * k + 5) * u + 1) := hg1.mul_left 2
    have hb : g ∣ (4 * k + 5) * (2 * u) := hg2.mul_left _
    have e : 2 * ((4 * k + 5) * u + 1) = (4 * k + 5) * (2 * u) + 2 := by ring
    rw [e] at ha
    simpa using Nat.dvd_sub ha hb
  have hodd : ((4 * k + 5) * u + 1) % 2 = 1 := by omega
  rcases (Nat.prime_two).eq_one_or_self_of_dvd g hg2' with h | h
  · exact h
  · exfalso
    rw [h] at hg1
    omega

/-! ### Descent letters of the two states -/

theorem crun_tBoundary (k : ℕ) : ((tBoundary k).1 - (tBoundary k).2) / (2 * (tBoundary k).2) = k := by
  show (4 * k + 5 - 2) / (2 * 2) = k
  omega

theorem crun_tAbove {k u : ℕ} (hu : 2 ≤ u) :
    ((tAbove k u).1 - (tAbove k u).2) / (2 * (tAbove k u).2) = k := by
  show ((4 * k + 5) * u + 1 - 2 * u) / (2 * (2 * u)) = k
  have hd : 2 * (2 * u) = 4 * u := by ring
  have he : (4 * k + 5) * u + 1 - 2 * u = (3 * u + 1) + (4 * u) * k := by
    have : (4 * k + 5) * u = 4 * u * k + 5 * u := by ring
    omega
  rw [hd, he, Nat.add_mul_div_left _ _ (by omega : 0 < 4 * u),
    Nat.div_eq_of_lt (by omega), Nat.zero_add]

theorem iter_tBoundary (k : ℕ) : parent^[k] (tBoundary k) = (5, 2) := by
  have h := iterate_parent_C_run (adm_tBoundary k) k (by rw [crun_tBoundary])
  rw [h]
  show ((4 * k + 5 - 2 * k * 2 : ℕ), (2 : ℕ)) = (5, 2)
  congr 1
  omega

theorem iter_tAbove {k u : ℕ} (hu : 2 ≤ u) (hue : u % 2 = 0) :
    parent^[k] (tAbove k u) = (5 * u + 1, 2 * u) := by
  have h := iterate_parent_C_run (adm_tAbove hu hue) k (by rw [crun_tAbove hu])
  rw [h]
  show (((4 * k + 5) * u + 1 - 2 * k * (2 * u) : ℕ), (2 * u : ℕ)) = (5 * u + 1, 2 * u)
  congr 1
  have : (4 * k + 5) * u = 2 * k * (2 * u) + 5 * u := by ring
  omega

theorem letters_prefix_eq {k u : ℕ} (hu : 2 ≤ u) (hue : u % 2 = 0) :
    ∀ j ≤ k, letterAt j (tBoundary k) = letterAt j (tAbove k u) := by
  intro j hj
  rcases lt_or_eq_of_le hj with h | h
  · rw [cRun_letters_C (adm_tBoundary k) j (by rw [crun_tBoundary]; exact h),
      cRun_letters_C (adm_tAbove hu hue) j (by rw [crun_tAbove hu]; exact h)]
  · subst h
    rw [letterAt, letterAt, iter_tBoundary, iter_tAbove hu hue]
    have h1 : ¬ (5 : ℕ) < 2 * 2 := by omega
    have h2 : (5 : ℕ) < 3 * 2 := by omega
    have h3 : ¬ (5 * u + 1) < 2 * (2 * u) := by omega
    have h4 : (5 * u + 1) < 3 * (2 * u) := by omega
    simp [letterOf, h1, h2, h3, h4]

theorem letters_diverge {k u : ℕ} (hu : 2 ≤ u) (hue : u % 2 = 0) :
    letterAt (k + 1) (tBoundary k) ≠ letterAt (k + 1) (tAbove k u) := by
  have hb : letterAt (k + 1) (tBoundary k) = Letter.B := by
    rw [letterAt, Function.iterate_succ_apply', iter_tBoundary]
    have h1 : (5 : ℕ) - 2 * 2 = 1 := by omega
    have hstep : parent (5, 2) = (2, 1) := by
      have hA : ¬ (5 : ℕ) < 2 * 2 := by omega
      have hB : (5 : ℕ) < 3 * 2 := by omega
      simp only [parent, hA, hB, if_true, if_false, h1]
    rw [hstep]
    simp [letterOf]
  have ha : letterAt (k + 1) (tAbove k u) = Letter.A := by
    rw [letterAt, Function.iterate_succ_apply', iter_tAbove hu hue]
    have hA : ¬ (5 * u + 1) < 2 * (2 * u) := by omega
    have hB : (5 * u + 1) < 3 * (2 * u) := by omega
    have harith : 5 * u + 1 - 2 * (2 * u) = u + 1 := by omega
    have hstep : parent (5 * u + 1, 2 * u) = (2 * u, u + 1) := by
      simp only [parent, hA, hB, if_true, if_false, harith]
    rw [hstep]
    have hA2 : (2 * u) < 2 * (u + 1) := by omega
    simp [letterOf, hA2]
  rw [hb, ha]
  exact fun h => Letter.noConfusion h

/-! ### The sensor cannot separate them -/

/-- **Right-continuity collision.**  For any rational scale `a/b`, once the
resolution parameter `u` exceeds `a`, the sensor gives the boundary state and its
right neighbour the same reading. -/
theorem gprobe_collision {a b k u : ℕ} (ha : 0 < a) (hb : 0 < b) (hau : a < u) :
    gprobe a b (tBoundary k) = gprobe a b (tAbove k u) := by
  set D := 2 * b with hD
  have hDpos : 0 < D := by omega
  have hDu : 0 < D * u := Nat.mul_pos hDpos (by omega)
  set A := a * (4 * k + 5) with hA
  set I := A / D with hI
  set p := A % D with hp
  have hdm : D * I + p = A := by rw [hI, hp]; exact Nat.div_add_mod _ _
  have hplt : p < D := Nat.mod_lt _ hDpos
  have hleft : gprobe a b (tBoundary k) = I := by
    show a * (4 * k + 5) / (b * 2) = I
    rw [show b * 2 = D by rw [hD]; ring, ← hA, hI]
  have hright : gprobe a b (tAbove k u) = I := by
    show a * ((4 * k + 5) * u + 1) / (b * (2 * u)) = I
    have he : a * ((4 * k + 5) * u + 1) = (p * u + a) + (D * u) * I := by
      have h1 : a * ((4 * k + 5) * u + 1) = A * u + a := by rw [hA]; ring
      have h2 : A * u = (D * I + p) * u := by rw [hdm]
      have h3 : (D * I + p) * u = (D * u) * I + p * u := by ring
      omega
    have hlt : p * u + a < D * u := by
      have h1 : p * u + u ≤ D * u := by
        have : (p + 1) * u ≤ D * u := Nat.mul_le_mul_right u (by omega)
        nlinarith [this]
      omega
    rw [show b * (2 * u) = D * u by rw [hD]; ring, he,
      Nat.add_mul_div_left _ _ hDu, Nat.div_eq_of_lt hlt, Nat.zero_add]
  rw [hleft, hright]

/-! ### Main theorem -/

/-- **UNIVERSAL DEPTH-NULL.**  For every rational scale `a/b` of the magnitude
sensor and every depth `k` there are two admissible Berggren states with the same
reading, the same descent letters at every depth `j ≤ k` (the prefix `C^k B`),
and different letters at depth `k+1`.

This subsumes the dyadic statement `depth_null_beyond_first_inversion`: no
rescaling of the magnitude — binary, ternary, or any other — recovers a single
letter past the first inversion. -/
theorem universal_depth_null (a b k : ℕ) (ha : 0 < a) (hb : 0 < b) :
    ∃ s s' : ℕ × ℕ, Adm s ∧ Adm s' ∧ gprobe a b s = gprobe a b s' ∧
      (∀ j ≤ k, letterAt j s = letterAt j s') ∧
      letterAt (k + 1) s ≠ letterAt (k + 1) s' := by
  refine ⟨tBoundary k, tAbove k (2 * a + 2), adm_tBoundary k,
    adm_tAbove (by omega) (by omega), gprobe_collision ha hb (by omega),
    letters_prefix_eq (by omega) (by omega), letters_diverge (by omega) (by omega)⟩

/-- No function of a rational-scale magnitude reading computes the descent letter
at depth `k+2` (index `k+1`). -/
theorem letterAt_not_gprobe_measurable (a b k : ℕ) (ha : 0 < a) (hb : 0 < b) :
    ¬ ∃ f : ℕ → Letter, ∀ s : ℕ × ℕ, Adm s → letterAt (k + 1) s = f (gprobe a b s) := by
  rintro ⟨f, hf⟩
  obtain ⟨s, s', hs, hs', hprobe, _, hne⟩ := universal_depth_null a b k ha hb
  exact hne (by rw [hf s hs, hf s' hs', hprobe])

end DepthDecay