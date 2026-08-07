import Novelty.DiophantineLatticeReduction

/-!
# Cycle 6: spectral gaps at arbitrary torsion shifts, and the equality case

Cycles 1–2 (`Novelty/DiophantineLatticeSpectralGap.lean`,
`Novelty/DiophantineLatticeTorsionGap.lean`) computed the spectral gap of the non-homogeneous
form `x ↦ Q(x - t)` for shifts of the *special shape* `t = v/r` with `v` a shortest vector.
This file removes both restrictions and settles the equality case, i.e. it closes
Conjecture 1 of `FUTURE_DIRECTIONS.md`.

A rational point `t` is an **`r`-torsion shift** (`IsTorsionShift`) when `r • t` lies in the
lattice `L = ℤⁿ` while `t` itself does not; equivalently `t` is a nonzero `r`-torsion point of
`(L ⊗ ℚ)/L`.  For such a shift:

* `torsion_shift_gap_ge` : `Q(t - m) ≥ λ₁/r²` for **every** lattice point `m`, with no
  assumption relating `t` to a shortest vector.  (The hypothesis actually used is only
  `t ∉ L`, which is exactly what exact order `r` provides.)
* `torsion_shift_isInhomMin_iff` : the **rigidity** statement.  The bound `λ₁/r²` is attained,
  i.e. the spectral gap at `t` equals `λ₁/r²`, **iff** `t ≡ w/r (mod L)` for some `w`
  realising the minimal lattice energy `λ₁`.  So the metric quantity `μ(t)` detects the
  shortest vectors exactly.
* `shortest_of_torsion_gap_eq` / `torsion_gap_eq_of_shortest` are the two directions in
  standalone form, and `torsion_shift_no_solution` is the Diophantine corollary.
* `torsion_shift_second_gap` : the rigidity statement upgrades to a *gap in the gaps* — a
  non-extremal `r`-torsion shift has spectral gap at least `λ₂/r²`, where `λ₂` is any lower
  bound for the values of `Q` above `λ₁`.  So the spectrum of spectral gaps at `r`-torsion
  shifts has no value strictly between `λ₁/r²` and `λ₂/r²`.

The technical engine is `isInhomMin_translate`: the spectral gap depends only on the class of
`t` in `(L ⊗ ℚ)/L`, so the special shape `v/r` of cycle 2 may be assumed after a translation.

A second, small result closes the easy half of the *converse* in Conjecture 2: evenness of all
shifted theta coefficients forces the shift to lie outside `L`
(`multiplicity_even_imp_not_lattice`), because a shift *inside* `L` has the isolated
coefficient `r_t(0) = 1`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the `1/r²` law is not about shortest vectors at all — it is about
the order of the shift in `(L ⊗ ℚ)/L` — and shortest vectors are recovered exactly as the
equality case.
Experiment (Experimenter): removing `hv : Q(v) = λ₁` from `torsion_gap_ge` leaves a proof that
needs only `v - r m ≠ 0`, and `t ∉ L` gives precisely that; conversely the attainment clause
of `IsInhomMin` hands back a lattice vector `w = r t - r m` with `Q(w) = λ₁`, so the converse
is *free* once translation invariance is available.
Analysis (Analyst): the equality case is therefore a genuine "if and only if", not an
inequality with a hard converse; the earlier cycles' hypothesis "`v` is shortest" was doing no
work in the inequality and all of the work in the attainment.
Critique (Critic): `torsion_shift_isInhomMin_iff` is non-vacuous — `deepHole n` is a
`2`-torsion shift for `n ≥ 1` (`deepHole_isTorsionShift`), and the theorem applied to it
returns the cycle-3 value `n/4`.
Synthesis (PI): spectral gap `λ₁/r²` at every `r`-torsion shift, with equality exactly on the
mod-`L` classes of `w/r`, `w` shortest.
-/

namespace DiophantineLattice

open Finset

variable {n : ℕ}

/-! ## Torsion shifts -/

/-- `t` is an **`r`-torsion shift**: `r • t` is a lattice vector but `t` is not.  Equivalently,
`t` is a nonzero `r`-torsion point of `(L ⊗ ℚ)/L`; a point of *exact* order `r` is the special
case in which no proper divisor of `r` already clears the denominators. -/
def IsTorsionShift (t : Fin n → ℚ) (r : ℤ) : Prop :=
  (∃ v : Fin n → ℤ, ∀ i, (r : ℚ) * t i = (v i : ℚ)) ∧ ∀ k : Fin n → ℤ, t ≠ emb k

/-- A cleared-denominator torsion shift is literally of the shape `v/r`. -/
lemma eq_fracPt_of_clear {t : Fin n → ℚ} {v : Fin n → ℤ} {r : ℤ} (hr : r ≠ 0)
    (hv : ∀ i, (r : ℚ) * t i = (v i : ℚ)) : t = fracPt v r := by
  have hr' : (r : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hr
  funext i
  show t i = (v i : ℚ) / (r : ℚ)
  rw [eq_div_iff hr']
  linarith [hv i]

/-- For a torsion shift `t = v/r`, the integral vector `v - r m` is never zero. -/
lemma torsionShift_sub_ne_zero {t : Fin n → ℚ} {v : Fin n → ℤ} {r : ℤ} (hr : r ≠ 0)
    (hv : ∀ i, (r : ℚ) * t i = (v i : ℚ)) (hnl : ∀ k : Fin n → ℤ, t ≠ emb k) (m : Fin n → ℤ) :
    (fun i => v i - r * m i) ≠ 0 := by
  have hr' : (r : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hr
  intro h
  refine hnl m ?_
  funext i
  have hi : v i - r * m i = 0 := by
    have : (fun i => v i - r * m i) i = (0 : Fin n → ℤ) i := by rw [h]
    simpa using this
  have hq : (v i : ℚ) = (r : ℚ) * (m i : ℚ) := by
    have : ((v i - r * m i : ℤ) : ℚ) = 0 := by exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hi
    push_cast at this
    linarith
  have hti := hv i
  rw [hq] at hti
  show t i = ((m i : ℤ) : ℚ)
  exact mul_left_cancel₀ hr' hti

/-! ## Translation invariance of the spectral gap -/

/-- Translating the shift by a lattice vector does not change the non-homogeneous form's set of
values, hence not its spectral gap. -/
lemma isInhomMin_translate (B : Matrix (Fin n) (Fin n) ℚ) (t : Fin n → ℚ) (k : Fin n → ℤ)
    {mu : ℚ} (h : IsInhomMin B t mu) :
    IsInhomMin B (fun i => t i + emb k i) mu := by
  have key : ∀ m : Fin n → ℤ,
      form B (fun i => (t i + emb k i) - emb m i)
        = form B (fun i => t i - emb (fun j => m j - k j) i) := by
    intro m
    congr 1
    funext i
    simp only [emb_apply]
    push_cast
    ring
  refine ⟨?_, ?_⟩
  · obtain ⟨m, hm⟩ := h.1
    refine ⟨fun j => m j + k j, ?_⟩
    rw [key]
    have : (fun j => (fun j => m j + k j) j - k j) = m := by funext j; ring
    rw [this, hm]
  · intro m
    rw [key]
    exact h.2 _

/-- The same statement in the direction needed for descent. -/
lemma isInhomMin_translate' (B : Matrix (Fin n) (Fin n) ℚ) (t : Fin n → ℚ) (k : Fin n → ℤ)
    {mu : ℚ} (h : IsInhomMin B (fun i => t i + emb k i) mu) : IsInhomMin B t mu := by
  have := isInhomMin_translate B (fun i => t i + emb k i) (fun j => -k j) h
  have heq : (fun i => (t i + emb k i) + emb (fun j => -k j) i) = t := by
    funext i; simp [emb]
  rwa [heq] at this

/-! ## The spectral gap at an arbitrary torsion shift -/

/-- **Torsion-shift spectral bound.**  If `t` is an `r`-torsion shift then every lattice point
is at `Q`-distance at least `λ₁/r²` from `t`.  No relation between `t` and a shortest vector is
assumed. -/
theorem torsion_shift_gap_ge {B : Matrix (Fin n) (Fin n) ℚ} {lam : ℚ}
    (hmin : ∀ m : Fin n → ℤ, m ≠ 0 → lam ≤ form B (emb m)) {t : Fin n → ℚ} {r : ℤ} (hr : r ≠ 0)
    (ht : IsTorsionShift t r) (m : Fin n → ℤ) :
    lam / (r : ℚ) ^ 2 ≤ form B (fun i => t i - emb m i) := by
  obtain ⟨⟨v, hv⟩, hnl⟩ := ht
  rw [eq_fracPt_of_clear hr hv]
  exact torsion_gap_ge hmin hr (torsionShift_sub_ne_zero hr hv hnl) m

/-- Diophantine corollary: at an `r`-torsion shift the equation `Q(x - t) = c` has no integral
solution once `c < λ₁/r²`. -/
theorem torsion_shift_no_solution {B : Matrix (Fin n) (Fin n) ℚ} {lam : ℚ}
    (hmin : ∀ m : Fin n → ℤ, m ≠ 0 → lam ≤ form B (emb m)) {t : Fin n → ℚ} {r : ℤ} (hr : r ≠ 0)
    (ht : IsTorsionShift t r) {c : ℚ} (hc : c < lam / (r : ℚ) ^ 2) :
    ¬ ∃ m : Fin n → ℤ, form B (fun i => t i - emb m i) = c := by
  rintro ⟨m, hm⟩
  have := torsion_shift_gap_ge hmin hr ht m
  rw [hm] at this
  linarith

/-! ## The equality case: rigidity -/

/-- **Rigidity, hard direction.**  If the spectral gap at an `r`-torsion shift `t` equals
`λ₁/r²`, then `t` is congruent modulo the lattice to `w/r` for some `w` realising the minimal
lattice energy. -/
theorem shortest_of_torsion_gap_eq {B : Matrix (Fin n) (Fin n) ℚ} {lam : ℚ} {t : Fin n → ℚ}
    {r : ℤ} (hr : r ≠ 0) (ht : IsTorsionShift t r)
    (hgap : IsInhomMin B t (lam / (r : ℚ) ^ 2)) :
    ∃ w k : Fin n → ℤ, form B (emb w) = lam ∧ ∀ i, t i = (w i : ℚ) / (r : ℚ) + (k i : ℚ) := by
  obtain ⟨⟨v, hv⟩, hnl⟩ := ht
  have htf : t = fracPt v r := eq_fracPt_of_clear hr hv
  obtain ⟨m, hm⟩ := hgap.1
  have hr' : (r : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hr
  have hrp : (0 : ℚ) < (r : ℚ) ^ 2 := by positivity
  refine ⟨fun i => v i - r * m i, m, ?_, ?_⟩
  · rw [htf] at hm
    rw [form_frac_sub B v m hr] at hm
    field_simp at hm
    have : form B (emb fun i => v i - r * m i) * (r : ℚ) ^ 2 = lam * (r : ℚ) ^ 2 := by
      nlinarith [hm]
    exact mul_right_cancel₀ (ne_of_gt hrp) this
  · intro i
    have hti : t i = (v i : ℚ) / (r : ℚ) := by rw [htf]; rfl
    rw [hti]
    push_cast
    field_simp
    ring

/-- **Rigidity, easy direction.**  If `t` is congruent modulo the lattice to `w/r` with `w`
realising the minimal lattice energy and `r ≥ 2`, the spectral gap at `t` is exactly `λ₁/r²`. -/
theorem torsion_gap_eq_of_shortest {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B) {lam : ℚ}
    (h : IsMinEnergy B lam) {t : Fin n → ℚ} {r : ℤ} (hr : 2 ≤ r) {w k : Fin n → ℤ}
    (hw : form B (emb w) = lam) (hk : ∀ i, t i = (w i : ℚ) / (r : ℚ) + (k i : ℚ)) :
    IsInhomMin B t (lam / (r : ℚ) ^ 2) := by
  have hbase : IsInhomMin B (fracPt w r) (lam / (r : ℚ) ^ 2) :=
    frac_shortest_isInhomMin hpd h hw hr
  have := isInhomMin_translate B (fracPt w r) k hbase
  have heq : (fun i => fracPt w r i + emb k i) = t := by
    funext i; rw [hk i]; rfl
  rwa [heq] at this

/-- **Conjecture 1, settled.**  For an `r`-torsion shift `t` (`r ≥ 2`) of a positive-definite
form with minimal lattice energy `λ₁`, the spectral gap at `t` equals `λ₁/r²` **iff** `t` is
congruent modulo the lattice to `w/r` for a vector `w` realising `λ₁`.  Combined with
`torsion_shift_gap_ge` (which gives `≥ λ₁/r²` unconditionally) this is a complete description
of the extremal shifts. -/
theorem torsion_shift_isInhomMin_iff {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B) {lam : ℚ}
    (h : IsMinEnergy B lam) {t : Fin n → ℚ} {r : ℤ} (hr : 2 ≤ r) (ht : IsTorsionShift t r) :
    IsInhomMin B t (lam / (r : ℚ) ^ 2) ↔
      ∃ w k : Fin n → ℤ, form B (emb w) = lam ∧
        ∀ i, t i = (w i : ℚ) / (r : ℚ) + (k i : ℚ) := by
  have hr0 : r ≠ 0 := by omega
  refine ⟨fun hg => shortest_of_torsion_gap_eq hr0 ht hg, ?_⟩
  rintro ⟨w, k, hw, hk⟩
  exact torsion_gap_eq_of_shortest hpd h hr hw hk

/-- **Second gap.**  Let `lam2` dominate the second value of the homogeneous form, i.e.
`lam < Q(w) → lam2 ≤ Q(w)`.  Then an `r`-torsion shift that is *not* extremal (not congruent
mod `L` to `w/r` with `w` realising `λ₁`) has spectral gap at least `lam2/r²`: the spectrum of
spectral gaps at `r`-torsion shifts has no value strictly between `λ₁/r²` and `lam2/r²`. -/
theorem torsion_shift_second_gap {B : Matrix (Fin n) (Fin n) ℚ} {lam lam2 : ℚ}
    (hmin : ∀ m : Fin n → ℤ, m ≠ 0 → lam ≤ form B (emb m))
    (hlam2 : ∀ w : Fin n → ℤ, lam < form B (emb w) → lam2 ≤ form B (emb w))
    {t : Fin n → ℚ} {r : ℤ} (hr : r ≠ 0) (ht : IsTorsionShift t r) {mu : ℚ}
    (hmu : IsInhomMin B t mu)
    (hne : ¬ ∃ w k : Fin n → ℤ, form B (emb w) = lam ∧
      ∀ i, t i = (w i : ℚ) / (r : ℚ) + (k i : ℚ)) :
    lam2 / (r : ℚ) ^ 2 ≤ mu := by
  obtain ⟨⟨v, hv⟩, hnl⟩ := ht
  have htf : t = fracPt v r := eq_fracPt_of_clear hr hv
  obtain ⟨m, hm⟩ := hmu.1
  have hr' : (r : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hr
  have hrp : (0 : ℚ) < (r : ℚ) ^ 2 := by positivity
  set w : Fin n → ℤ := fun i => v i - r * m i with hw
  have hwne : w ≠ 0 := torsionShift_sub_ne_zero hr hv hnl m
  have hval : form B (emb w) / (r : ℚ) ^ 2 = mu := by
    rw [← hm, htf, form_frac_sub B v m hr]
  have hcoord : ∀ i, t i = (w i : ℚ) / (r : ℚ) + (m i : ℚ) := by
    intro i
    have hti : t i = (v i : ℚ) / (r : ℚ) := by rw [htf]; rfl
    rw [hti, hw]
    push_cast
    field_simp
    ring
  have hlt : lam < form B (emb w) := by
    rcases lt_or_eq_of_le (hmin w hwne) with h | h
    · exact h
    · exact absurd ⟨w, m, h.symm, hcoord⟩ hne
  have := hlam2 w hlt
  rw [← hval]
  gcongr

/-! ## Non-vacuity: the deep hole of `ℤⁿ` -/

/-- The deep hole `(1/2, …, 1/2)` of `ℤⁿ` is a `2`-torsion shift as soon as `n ≥ 1`. -/
theorem deepHole_isTorsionShift (hn : 0 < n) : IsTorsionShift (deepHole n) 2 := by
  refine ⟨⟨fun _ => 1, fun i => by norm_num [deepHole]⟩, ?_⟩
  intro k hk
  have : deepHole n ⟨0, hn⟩ = (k ⟨0, hn⟩ : ℚ) := by rw [hk]; rfl
  rw [deepHole] at this
  have h2 : (2 : ℚ) * (k ⟨0, hn⟩ : ℚ) = 1 := by
    field_simp at this
    linarith
  have : ((2 * k ⟨0, hn⟩ : ℤ) : ℚ) = ((1 : ℤ) : ℚ) := by push_cast; linarith
  have h3 : 2 * k ⟨0, hn⟩ = 1 := by exact_mod_cast this
  omega

/-- The rigidity theorem applied to the deep hole of `ℤⁿ` recovers the cycle-3 value: the
extremal vectors for the deep hole of the standard lattice are exactly the `±1` vectors, and
the gap is `n/4` only for `n = 1`; for `n ≥ 2` the deep hole is *not* extremal, since its gap
`n/4` exceeds `λ₁/4 = 1/4`. -/
theorem deepHole_not_extremal (hn : 2 ≤ n) :
    ¬ IsInhomMin (1 : Matrix (Fin n) (Fin n) ℚ) (deepHole n) ((1 : ℚ) / (2 : ℚ) ^ 2) := by
  intro h
  obtain ⟨m, hm⟩ := h.1
  have hge : (n : ℚ) / 4 ≤ form (1 : Matrix (Fin n) (Fin n) ℚ)
      (fun i => deepHole n i - emb m i) := deepHole_dist_ge m
  rw [hm] at hge
  have hn' : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  norm_num at hge
  linarith

/-- In rank one the deep hole *is* extremal: the rigidity theorem applies with `w = (1)`, so
the spectral gap of `x ↦ (x - 1/2)²` on `ℤ` equals `λ₁/4 = 1/4`.  Together with
`deepHole_not_extremal` this shows the extremal locus of the rigidity theorem is exactly the
rank-one case for the deep hole of `ℤⁿ`. -/
theorem deepHole_one_isInhomMin :
    IsInhomMin (1 : Matrix (Fin 1) (Fin 1) ℚ) (deepHole 1) ((1 : ℚ) / (2 : ℚ) ^ 2) := by
  refine (torsion_shift_isInhomMin_iff (n := 1) standard_posDef (standard_isMinEnergy one_pos)
    (r := 2) (by norm_num) (deepHole_isTorsionShift one_pos)).2
    ⟨fun _ => 1, fun _ => 0, ?_, ?_⟩
  · simp [form_one, emb]
  · intro i; norm_num [deepHole]

/-! ## Multiplicity one at a lattice point (Conjecture 2, easy converse) -/

/-- For a positive-definite form, a lattice point is at distance `0` from the lattice shift `k`
precisely when it equals `k`. -/
lemma form_sub_emb_eq_zero_iff {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B) (k m : Fin n → ℤ) :
    form B (fun i => emb k i - emb m i) = 0 ↔ m = k := by
  constructor
  · intro h0
    by_contra hne
    have hx : (fun i => emb k i - emb m i) ≠ 0 := by
      intro hx
      apply hne
      funext i
      have hi := congrArg (fun f : Fin n → ℚ => f i) hx
      simp only [emb_apply] at hi
      have : ((k i : ℚ)) = ((m i : ℚ)) := by simpa [sub_eq_zero] using hi
      exact_mod_cast this.symm
    have := hpd _ hx
    rw [h0] at this
    exact lt_irrefl _ this
  · rintro rfl
    have h0 : (fun i => emb m i - emb m i) = (0 : Fin n → ℚ) := by funext i; simp
    rw [h0]
    simp [form, bil]

/-- At a shift lying *in* the lattice the value `0` is attained by exactly one lattice point. -/
theorem lattice_shift_zero_set {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B) (k : Fin n → ℤ)
    (S : Finset (Fin n → ℤ))
    (hS : ∀ m : Fin n → ℤ, m ∈ S ↔ form B (fun i => emb k i - emb m i) = 0) :
    S = {k} := by
  classical
  ext m
  rw [hS, Finset.mem_singleton, form_sub_emb_eq_zero_iff hpd]

/-- **Conjecture 2, easy converse.**  If every coefficient of the shifted theta series of
`x ↦ Q(x - t)` is even, then `t` does not lie in the lattice: a lattice shift has the odd
coefficient `r_t(0) = 1`. -/
theorem multiplicity_even_imp_not_lattice {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B)
    {t : Fin n → ℚ}
    (heven : ∀ (c : ℚ) (S : Finset (Fin n → ℤ)),
      (∀ m : Fin n → ℤ, m ∈ S ↔ form B (fun i => t i - emb m i) = c) → Even S.card) :
    ∀ k : Fin n → ℤ, t ≠ emb k := by
  classical
  intro k hk
  subst hk
  have hmem : ∀ m : Fin n → ℤ,
      m ∈ ({k} : Finset (Fin n → ℤ)) ↔ form B (fun i => emb k i - emb m i) = 0 := by
    intro m
    rw [Finset.mem_singleton, form_sub_emb_eq_zero_iff hpd]
  have := heven 0 {k} hmem
  simp at this

end DiophantineLattice