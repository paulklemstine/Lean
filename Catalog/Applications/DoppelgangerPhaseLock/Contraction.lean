/-
# Doppelgänger Phase-Lock — the analytic (contractive) mechanism

The combinatorial theory of `Applications.DoppelgangerPhaseLock.Finite` answers *when*
identical agents can phase-lock.  This file supplies a *mechanism*: if each stimulus acts
on the internal state space as a `k`-Lipschitz map with `k < 1` — a "damped" or
"dissipative" agent — then the two separated copies converge towards each other
exponentially fast, at a rate that does not depend on the stimulus stream at all.

The last theorem is the bridge between analysis and combinatorics: in a state space that
is *quantized* (distinct states are at distance at least `ε`) and bounded, exponential
convergence forces **exact** phase-lock after finitely many stimuli, i.e. every
sufficiently long stimulus word is a locking word in the sense of the core file.  For a
finite metric state space, both hypotheses are automatic.

## Main results

* `Doppelganger.dist_drive_le` — `dist (drive δ w s) (drive δ w t) ≤ k ^ |w| * dist s t`.
* `Doppelganger.tendsto_dist_drive_zero` — asymptotic phase-lock along any stimulus stream.
* `Doppelganger.exists_lock_of_contraction_of_separated` — quantization upgrades
  asymptotic to exact phase-lock, uniformly in the stimulus stream.
* `Doppelganger.phaseLocking_of_contraction_finite` — every contractive agent with a
  finite metric state space is phase-locking.
* `Doppelganger.no_contractive_metric_of_bijective_stimulus` — the converse fails: an agent
  with a reversible stimulus admits no contractive metric at all.
-/
import Applications.DoppelgangerPhaseLock.Core

namespace Doppelganger

variable {S I : Type*}

section Contraction

variable [PseudoMetricSpace S]

/-- **Exponential contraction of the doppelgänger gap.**  Under a uniform `k`-contraction
per stimulus, the distance between the two agents shrinks by a factor `k` per observation,
independently of *which* stimuli are observed. -/
theorem dist_drive_le (δ : S → I → S) {k : ℝ} (hk : 0 ≤ k)
    (hcontract : ∀ (i : I) (s t : S), dist (δ s i) (δ t i) ≤ k * dist s t) (w : List I) (s t : S) :
    dist (drive δ w s) (drive δ w t) ≤ k ^ w.length * dist s t := by
  induction w generalizing s t with
  | nil => simp
  | cons i v ih =>
      have h1 : dist (drive δ v (δ s i)) (drive δ v (δ t i))
          ≤ k ^ v.length * dist (δ s i) (δ t i) := ih _ _
      have h2 : k ^ v.length * dist (δ s i) (δ t i) ≤ k ^ v.length * (k * dist s t) :=
        mul_le_mul_of_nonneg_left (hcontract i s t) (pow_nonneg hk _)
      calc dist (drive δ (i :: v) s) (drive δ (i :: v) t) ≤ k ^ v.length * (k * dist s t) :=
            le_trans h1 h2
        _ = k ^ (i :: v).length * dist s t := by
            simp only [List.length_cons, pow_succ]; ring

/-- **Asymptotic phase-lock.**  Along *every* shared stimulus stream the gap between the
two separated agents tends to zero. -/
theorem tendsto_dist_drive_zero (δ : S → I → S) {k : ℝ} (hk : 0 ≤ k) (hk1 : k < 1)
    (hcontract : ∀ (i : I) (s t : S), dist (δ s i) (δ t i) ≤ k * dist s t)
    (x : ℕ → I) (s t : S) :
    Filter.Tendsto (fun n => dist (drive δ (pre x n) s) (drive δ (pre x n) t))
      Filter.atTop (nhds 0) := by
  apply squeeze_zero (fun _ => dist_nonneg) (g := fun n => k ^ n * dist s t)
  · intro n; simpa using dist_drive_le δ hk hcontract (pre x n) s t
  · simpa using (tendsto_pow_atTop_nhds_zero_of_lt_one hk hk1).mul_const (dist s t)

/-- **Quantization turns approximate telepathy into exact telepathy.**  If distinct
internal states are separated by at least `ε > 0` and the state space has diameter at most
`D`, a contractive agent phase-locks *exactly* after `N` stimuli, for an `N` that depends
only on `k, ε, D` — never on the stimuli actually observed. -/
theorem exists_lock_of_contraction_of_separated [Nonempty S] (δ : S → I → S) {k ε D : ℝ}
    (hk : 0 ≤ k) (hk1 : k < 1)
    (hcontract : ∀ (i : I) (s t : S), dist (δ s i) (δ t i) ≤ k * dist s t)
    (hε : 0 < ε) (hsep : ∀ s t : S, s ≠ t → ε ≤ dist s t)
    (hD : ∀ s t : S, dist s t ≤ D) :
    ∃ N : ℕ, ∀ w : List I, N ≤ w.length → Locks δ w := by
  have hD0 : 0 ≤ D := le_trans dist_nonneg (hD (Classical.arbitrary S) (Classical.arbitrary S))
  have hpos : 0 < ε / (D + 1) := div_pos hε (by linarith)
  obtain ⟨N, hN⟩ := exists_pow_lt_of_lt_one hpos hk1
  refine ⟨N, fun w hw s t => ?_⟩
  by_contra hne
  have h1 : ε ≤ dist (drive δ w s) (drive δ w t) := hsep _ _ hne
  have h2 : dist (drive δ w s) (drive δ w t) ≤ k ^ w.length * dist s t :=
    dist_drive_le δ hk hcontract w s t
  have h3 : k ^ w.length ≤ k ^ N := pow_le_pow_of_le_one hk hk1.le hw
  have h4 : k ^ w.length * dist s t ≤ k ^ N * D :=
    mul_le_mul h3 (hD s t) dist_nonneg (pow_nonneg hk N)
  have h5 : k ^ N * D < ε := by
    have hlt : k ^ N * (D + 1) < (ε / (D + 1)) * (D + 1) :=
      mul_lt_mul_of_pos_right hN (by linarith)
    have h6 : (ε / (D + 1)) * (D + 1) = ε := by field_simp
    nlinarith [pow_nonneg hk N]
  linarith

end Contraction

section FiniteMetric

variable [MetricSpace S] [Fintype S] [Nonempty S]

/-- **Contractive finite agents always phase-lock.**  On a finite metric state space the
separation and diameter hypotheses are automatic, so any per-stimulus contraction with
factor `k < 1` yields genuine doppelgänger phase-lock: all sufficiently long shared
stimulus words are locking words. -/
theorem exists_lock_of_contraction_finite (δ : S → I → S) {k : ℝ} (hk : 0 ≤ k) (hk1 : k < 1)
    (hcontract : ∀ (i : I) (s t : S), dist (δ s i) (δ t i) ≤ k * dist s t) :
    ∃ N : ℕ, ∀ w : List I, N ≤ w.length → Locks δ w := by
  classical
  by_cases hsub : ∀ s t : S, s = t
  · exact ⟨0, fun w _ s t => by rw [hsub s t]⟩
  push_neg at hsub
  obtain ⟨a, b, hab⟩ := hsub
  set P : Finset (S × S) := (Finset.univ : Finset (S × S)).filter (fun p => p.1 ≠ p.2) with hP
  have hPne : P.Nonempty := ⟨(a, b), by simp [hP, hab]⟩
  set ε := P.inf' hPne (fun p => dist p.1 p.2) with hεdef
  set D := (Finset.univ : Finset (S × S)).sup' Finset.univ_nonempty
    (fun p => dist p.1 p.2) with hDdef
  have hε : 0 < ε := by
    rw [hεdef, Finset.lt_inf'_iff]
    intro p hp
    have hne : p.1 ≠ p.2 := by simpa [hP] using hp
    exact dist_pos.mpr hne
  have hsep : ∀ s t : S, s ≠ t → ε ≤ dist s t := fun s t hst =>
    Finset.inf'_le (f := fun p : S × S => dist p.1 p.2) (b := (s, t)) (by simp [hP, hst])
  have hD : ∀ s t : S, dist s t ≤ D := fun s t =>
    Finset.le_sup' (f := fun p : S × S => dist p.1 p.2) (Finset.mem_univ (s, t))
  exact exists_lock_of_contraction_of_separated δ hk hk1 hcontract hε hsep hD

/-- Contractive finite agents are phase-locking in the sense of the core file. -/
theorem phaseLocking_of_contraction_finite [Nonempty I] (δ : S → I → S) {k : ℝ}
    (hk : 0 ≤ k) (hk1 : k < 1)
    (hcontract : ∀ (i : I) (s t : S), dist (δ s i) (δ t i) ≤ k * dist s t) :
    PhaseLocking δ := by
  obtain ⟨N, hN⟩ := exists_lock_of_contraction_finite δ hk hk1 hcontract
  exact ⟨List.replicate N (Classical.arbitrary I), hN _ (by simp)⟩

end FiniteMetric

section Obstruction

/-! ### Contractivity is strictly stronger than phase-lock

The contraction mechanism is *sufficient* for phase-lock but not necessary: an agent that
has a single reversible stimulus can never be contractive in any metric, because iterating
that stimulus around its (finite) orbit would force all distances to vanish.  Combined
with `Applications.DoppelgangerPhaseLock.Sharpness`, where a phase-locking agent with a
reversible stimulus is exhibited, this separates the analytic mechanism from the
combinatorial phenomenon. -/

lemma drive_replicate (δ : S → I → S) (i : I) (n : ℕ) (s : S) :
    drive δ (List.replicate n i) s = (fun x => δ x i)^[n] s := by
  induction n generalizing s with
  | zero => simp
  | succ m ih => rw [List.replicate_succ, drive_cons, ih, Function.iterate_succ_apply]

/-- **No contractive metric in the presence of a reversible stimulus.**  If some stimulus
acts bijectively on a finite state space, then no metric can make every stimulus a uniform
`k`-contraction with `k < 1` unless the state space is a single point. -/
theorem no_contractive_metric_of_bijective_stimulus [Fintype S] [MetricSpace S]
    (δ : S → I → S) (i₀ : I) (hbij : Function.Bijective (δ · i₀)) {k : ℝ}
    (hk : 0 ≤ k) (hk1 : k < 1)
    (hcontract : ∀ (i : I) (s t : S), dist (δ s i) (δ t i) ≤ k * dist s t) (s t : S) : s = t := by
  classical
  set e : Equiv.Perm S := Equiv.ofBijective _ hbij with he
  have hpow : ∀ (n : ℕ) (x : S), (e ^ n) x = (fun y => δ y i₀)^[n] x := by
    intro n
    induction n with
    | zero => intro x; simp
    | succ j ih =>
        intro x
        rw [pow_succ, Equiv.Perm.mul_apply, ih, Function.iterate_succ_apply]
        rfl
  have hid : ∀ x : S, (fun y => δ y i₀)^[orderOf e] x = x := by
    intro x
    rw [← hpow (orderOf e) x, pow_orderOf_eq_one]
    rfl
  have hdist := dist_drive_le δ hk hcontract (List.replicate (orderOf e) i₀) s t
  rw [drive_replicate, drive_replicate, hid, hid] at hdist
  simp only [List.length_replicate] at hdist
  have hm0 : 0 < orderOf e := orderOf_pos e
  have hkm : k ^ orderOf e < 1 := pow_lt_one₀ hk hk1 (by omega)
  have hzero : dist s t ≤ 0 := by nlinarith [dist_nonneg (x := s) (y := t)]
  exact dist_le_zero.mp hzero

end Obstruction

end Doppelganger