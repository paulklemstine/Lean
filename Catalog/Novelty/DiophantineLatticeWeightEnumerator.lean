import Novelty.DiophantineLatticeGapSpectrum

/-!
# Cycle 9: the diagonal covering weight enumerator, and the exact parity criterion

Two open items of `FUTURE_DIRECTIONS.md` are settled here.

**Sub-conjecture D1 (confirmed).**  For a positive diagonal form `Q(x) = Σ aᵢxᵢ²` the spectral
gap at a `2`-torsion shift is the *weighted* Hamming weight of its class in `𝔽₂ⁿ`:

* `diagonal_stepShift_isInhomMin` : the gap at the `0/½` representative supported on `s` is
  exactly `(Σ_{i ∈ s} aᵢ)/4`;
* `diagonal_two_torsion_gap_eq` : for an arbitrary `t` with `2t = v ∈ ℤⁿ` the gap is
  `(Σ_{i : vᵢ odd} aᵢ)/4`;
* `diagonal_gap_spectrum_eq` : the whole `2`-torsion gap spectrum of a diagonal form is
  `{(Σ_{i ∈ s} aᵢ)/4 : s ≠ ∅}`.  Cycle 8 is the case `aᵢ ≡ 1`, where this is `{k/4 : 1 ≤ k ≤ n}`;
* `diagonal_weight_enumerator_extremes` : its minimum is the packing invariant `λ₁/4` and its
  maximum is the covering invariant `(Σ aᵢ)/4`.

**Conjecture A (refuted, and replaced by an exact criterion).**  Conjecture A asserted that
all-even shifted theta coefficients force `2t ∈ L`.  This is **false** already for `ℤ²`:

* `parity_conjecture_false` exhibits `t = (1/2, 1/3)`, for which every coefficient is even
  (flip the first coordinate) while `2t = (1, 2/3) ∉ ℤ²`.

The correct statement, proved here for every positive diagonal form and hence for `ℤⁿ`, is a
*coordinatewise* criterion:

* `diagonal_multiplicity_even_iff` / `standard_multiplicity_even_iff` : all coefficients of the
  shifted theta series are even **iff some single coordinate** `tᵢ` is half-integral.

A general-rank shadow of the criterion is proved for an arbitrary form:
`multiplicity_even_imp_two_minimisers` — even parity of the bottom coefficient forces the
nearest lattice point to `t` to be non-unique.

Sufficiency is the partial reflection `m ↦ (…, 2tᵢ − mᵢ, …)`, which is fixed-point free and
preserves the form because the diagonal form has no coupling between coordinates.  Necessity is
a *minimal shell* count: if no coordinate is half-integral, the nearest lattice point
`round ∘ t` is the **unique** minimiser of `Q(t − ·)`, so the bottom coefficient equals `1`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Conjecture A ("even theta ⟹ `2t ∈ L`") should hold in all ranks,
since the rank-one criterion is exact.
Experiment (Experimenter): the standard theta series factorises over the coordinates,
`θ_t = ∏ θ_{tᵢ}`; a single even factor annihilates the product mod `2`.  Taking
`t = (1/2, 1/3)` gives even coefficients with `2t ∉ ℤ²` — an explicit counterexample, verified
by exhibiting the fixed-point-free involution `(m₁, m₂) ↦ (1 − m₁, m₂)` (`parity_conjecture_false`).
Analysis (Analyst): the failure is "needs a different definition", not "false for a silly
reason": the true invariant is not the order of `t` in `(L ⊗ ℚ)/L` but the existence of *some*
reflection of the lattice fixing `t`.  For a diagonal form the reflections are the coordinate
flips, which is exactly why the corrected criterion is coordinatewise; the rank-one theorem is
the case `n = 1`, where the two formulations coincide.
Critique (Critic): both directions are proved, so `diagonal_multiplicity_even_iff` is an exact
criterion, not a one-sided bound; the necessity direction produces a *specific* odd coefficient
(the minimal shell), so it is constructive; and the counterexample is a theorem, not a
computation.  The minimal-shell argument uses `0 < aᵢ` essentially — for an indefinite form
there is no bottom shell.
Synthesis (PI): the `2`-torsion gap of a diagonal form is its weighted Hamming weight, and the
parity of the shifted theta series detects half-integrality of a single coordinate, not
`2`-torsion of the shift.
-/

namespace DiophantineLattice

open Finset

variable {n : ℕ}

/-! ## Part 1: the covering weight enumerator of a diagonal form -/

/-- The value of a diagonal form at the `0/½` representative supported on `s`, measured from
the origin, is `(Σ_{i ∈ s} aᵢ)/4`. -/
lemma diagonal_form_stepShift_zero (a : Fin n → ℚ) (s : Finset (Fin n)) :
    form (Matrix.diagonal a) (fun i => stepShift s i - emb (0 : Fin n → ℤ) i)
      = (∑ i ∈ s, a i) / 4 := by
  classical
  rw [form_diagonal]
  have h : ∀ i : Fin n, a i * (stepShift s i - emb (0 : Fin n → ℤ) i) ^ 2
      = if i ∈ s then a i / 4 else 0 := by
    intro i
    simp only [stepShift_apply, emb_apply, Pi.zero_apply, Int.cast_zero]
    split_ifs <;> ring
  rw [Finset.sum_congr rfl fun i _ => h i, Finset.sum_ite_mem, Finset.univ_inter,
    ← Finset.sum_div]

/-- **Sub-conjecture D1.**  For a positive diagonal form the spectral gap at the `2`-torsion
shift with coordinates `1/2` exactly on `s` is exactly `(Σ_{i ∈ s} aᵢ)/4`: the weighted Hamming
weight of the class, divided by `4`. -/
theorem diagonal_stepShift_isInhomMin {a : Fin n → ℚ} (ha : ∀ i, 0 < a i) (s : Finset (Fin n)) :
    IsInhomMin (Matrix.diagonal a) (stepShift s) ((∑ i ∈ s, a i) / 4) := by
  classical
  refine ⟨⟨0, diagonal_form_stepShift_zero a s⟩, ?_⟩
  intro m
  rw [form_diagonal]
  have hterm : ∀ i ∈ (univ : Finset (Fin n)),
      (if i ∈ s then a i / 4 else 0) ≤ a i * (stepShift s i - emb m i) ^ 2 := by
    intro i _
    simp only [stepShift_apply, emb_apply]
    split_ifs with hi
    · have h := deepHole_term_ge (m i)
      nlinarith [(ha i).le]
    · have : (0 : ℚ) ≤ a i * (0 - (m i : ℚ)) ^ 2 :=
        mul_nonneg (ha i).le (sq_nonneg _)
      simpa using this
  have hsum := Finset.sum_le_sum hterm
  rwa [Finset.sum_ite_mem, Finset.univ_inter, ← Finset.sum_div] at hsum

/-- **The gap of a diagonal form at an arbitrary `2`-torsion shift.**  If `2t = v` is a lattice
vector, the gap equals the sum of the `aᵢ` over the odd coordinates of `v`, divided by `4`. -/
theorem diagonal_two_torsion_gap_eq {a : Fin n → ℚ} (ha : ∀ i, 0 < a i) {t : Fin n → ℚ}
    {v : Fin n → ℤ} (hv : ∀ i, (2 : ℚ) * t i = (v i : ℚ)) :
    IsInhomMin (Matrix.diagonal a) t
      ((∑ i ∈ Finset.univ.filter (fun i => v i % 2 ≠ 0), a i) / 4) := by
  classical
  have hbase := diagonal_stepShift_isInhomMin ha (Finset.univ.filter fun i => v i % 2 ≠ 0)
  have h := isInhomMin_translate (Matrix.diagonal a) _ (fun i => v i / 2) hbase
  rwa [← eq_stepShift_add hv] at h

/-- Consistency with cycle 2: at the deep hole (`s = univ`) the diagonal gap is `(Σ aᵢ)/4`,
matching the covering radius computed by `diagonal_covering_radius_least`. -/
theorem diagonal_deepHole_isInhomMin {a : Fin n → ℚ} (ha : ∀ i, 0 < a i) :
    IsInhomMin (Matrix.diagonal a) (deepHole n) ((∑ i, a i) / 4) := by
  have h := diagonal_stepShift_isInhomMin ha (Finset.univ : Finset (Fin n))
  rwa [← deepHole_eq_stepShift_univ] at h

/-- **The `2`-torsion gap spectrum of a diagonal form** is the set of weighted Hamming weights
of the nonempty subsets of coordinates, divided by `4`. -/
theorem diagonal_gap_spectrum_eq {a : Fin n → ℚ} (ha : ∀ i, 0 < a i) :
    {mu : ℚ | ∃ t : Fin n → ℚ, IsTorsionShift t 2 ∧ IsInhomMin (Matrix.diagonal a) t mu}
      = {mu : ℚ | ∃ s : Finset (Fin n), s.Nonempty ∧ mu = (∑ i ∈ s, a i) / 4} := by
  classical
  ext mu
  simp only [Set.mem_setOf_eq]
  constructor
  · rintro ⟨t, ⟨⟨v, hv⟩, hnl⟩, hmu⟩
    set s : Finset (Fin n) := Finset.univ.filter fun i => v i % 2 ≠ 0 with hs
    have hgap := diagonal_two_torsion_gap_eq ha hv
    have hmueq : mu = (∑ i ∈ s, a i) / 4 := isInhomMin_unique hmu hgap
    refine ⟨s, ?_, hmueq⟩
    rcases s.eq_empty_or_nonempty with hempty | hne
    · exfalso
      have hall : ∀ i, v i % 2 = 0 := by
        intro i
        by_contra hi
        have : i ∈ s := Finset.mem_filter.mpr ⟨Finset.mem_univ i, hi⟩
        rw [hempty] at this
        exact absurd this (Finset.notMem_empty i)
      refine hnl (fun i => v i / 2) ?_
      funext i
      have hveven : v i = 2 * (v i / 2) := by have := hall i; omega
      have hcast : ((v i : ℚ)) = 2 * ((v i / 2 : ℤ) : ℚ) := by
        exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hveven
      have hti := hv i
      rw [hcast] at hti
      show t i = ((v i / 2 : ℤ) : ℚ)
      linarith
    · exact hne
  · rintro ⟨s, hne, rfl⟩
    refine ⟨stepShift s, ⟨⟨fun i => if i ∈ s then 1 else 0, ?_⟩, ?_⟩, diagonal_stepShift_isInhomMin ha s⟩
    · intro i
      simp only [stepShift_apply]
      split_ifs <;> norm_num
    · intro m hm
      obtain ⟨i, hi⟩ := hne
      have hci := congrFun hm i
      simp only [stepShift_apply, emb_apply, if_pos hi] at hci
      have h2 : ((2 * m i : ℤ) : ℚ) = ((1 : ℤ) : ℚ) := by push_cast; linarith
      have : 2 * m i = 1 := by exact_mod_cast h2
      omega

/-- **The extremes of the weight enumerator.**  The smallest `2`-torsion gap of a positive
diagonal form is `λ₁/4 = (min aᵢ)/4` and the largest is `(Σ aᵢ)/4`, the covering radius squared:
the weight enumerator interpolates between the packing and the covering invariant. -/
theorem diagonal_weight_enumerator_extremes {a : Fin n → ℚ} (ha : ∀ i, 0 < a i) (i0 : Fin n)
    (hi0 : ∀ i, a i0 ≤ a i) {s : Finset (Fin n)} (hs : s.Nonempty) :
    a i0 / 4 ≤ (∑ i ∈ s, a i) / 4 ∧ (∑ i ∈ s, a i) / 4 ≤ (∑ i, a i) / 4 := by
  obtain ⟨j, hj⟩ := hs
  have hlow : a i0 ≤ ∑ i ∈ s, a i :=
    (hi0 j).trans (Finset.single_le_sum (f := a) (fun k _ => (ha k).le) hj)
  have hhigh : (∑ i ∈ s, a i) ≤ ∑ i, a i :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ s)
      (fun k _ _ => (ha k).le)
  constructor <;> linarith

/-! ## Part 2: the exact parity criterion -/

/-- A rational number is **half-integral** when it lies in `ℤ + ½`. -/
def IsHalfIntegral (x : ℚ) : Prop := ∃ k : ℤ, x = (k : ℚ) + 1 / 2

/-- Half-integrality is exactly `2`-torsion of a single coordinate. -/
lemma isHalfIntegral_iff (x : ℚ) :
    IsHalfIntegral x ↔ (∃ w : ℤ, 2 * x = (w : ℚ)) ∧ ∀ k : ℤ, x ≠ (k : ℚ) := by
  constructor
  · rintro ⟨k, rfl⟩
    refine ⟨⟨2 * k + 1, by push_cast; ring⟩, ?_⟩
    intro j hj
    have : ((2 * j : ℤ) : ℚ) = ((2 * k + 1 : ℤ) : ℚ) := by push_cast; linarith
    have : 2 * j = 2 * k + 1 := by exact_mod_cast this
    omega
  · rintro ⟨⟨w, hw⟩, hnint⟩
    rcases (by omega : w % 2 = 0 ∨ w % 2 = 1) with h0 | h1
    · exfalso
      have hweven : w = 2 * (w / 2) := by omega
      refine hnint (w / 2) ?_
      have : ((w : ℚ)) = 2 * ((w / 2 : ℤ) : ℚ) := by
        exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hweven
      rw [this] at hw
      linarith
    · refine ⟨w / 2, ?_⟩
      have hwodd : w = 2 * (w / 2) + 1 := by omega
      have : ((w : ℚ)) = 2 * ((w / 2 : ℤ) : ℚ) + 1 := by
        exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hwodd
      rw [this] at hw
      linarith

/-- **The coordinate flip.**  If `tᵢ₀ = k + ½`, replacing the `i₀`-th coordinate of a lattice
point `m` by `2k + 1 − mᵢ₀` preserves the value of a diagonal non-homogeneous form. -/
lemma diagonal_flip_form (a : Fin n → ℚ) {t : Fin n → ℚ} {i0 : Fin n} {k : ℤ}
    (hk : t i0 = (k : ℚ) + 1 / 2) (m : Fin n → ℤ) :
    form (Matrix.diagonal a)
        (fun i => t i - emb (Function.update m i0 (2 * k + 1 - m i0)) i)
      = form (Matrix.diagonal a) (fun i => t i - emb m i) := by
  classical
  rw [form_diagonal, form_diagonal]
  refine Finset.sum_congr rfl fun i _ => ?_
  by_cases hi : i = i0
  · subst hi
    simp only [emb_apply, Function.update_self]
    rw [hk]
    push_cast
    ring
  · simp only [emb_apply, Function.update_of_ne hi]

/-- **Sufficiency of the criterion.**  If a single coordinate of the shift is half-integral,
then every coefficient of the shifted theta series of a diagonal form is even. -/
theorem diagonal_multiplicity_even_of_halfIntegral (a : Fin n → ℚ) {t : Fin n → ℚ}
    {i0 : Fin n} (hhalf : IsHalfIntegral (t i0)) (c : ℚ) (S : Finset (Fin n → ℤ))
    (hS : ∀ m : Fin n → ℤ, m ∈ S ↔ form (Matrix.diagonal a) (fun i => t i - emb m i) = c) :
    Even S.card := by
  classical
  obtain ⟨k, hk⟩ := hhalf
  set g : (Fin n → ℤ) → (Fin n → ℤ) :=
    fun m => Function.update m i0 (2 * k + 1 - m i0) with hg
  have hgmem : ∀ m ∈ S, g m ∈ S := by
    intro m hm
    rw [hS] at hm ⊢
    rw [hg]
    rw [diagonal_flip_form a hk m]
    exact hm
  have hginv : ∀ m, g (g m) = m := by
    intro m
    funext j
    by_cases hj : j = i0
    · subst hj
      simp [hg]
    · simp [hg, Function.update_of_ne hj]
  have hgfix : ∀ m ∈ S, g m ≠ m := by
    intro m _ hfix
    have h0 : (g m) i0 = m i0 := by rw [hfix]
    simp only [hg, Function.update_self] at h0
    omega
  have hsum : ∑ _x ∈ S, (1 : ZMod 2) = 0 :=
    Finset.sum_involution (fun x _ => g x) (fun x _ => by decide)
      (fun x hx _ => hgfix x hx) (fun x hx => hgmem x hx) (fun x _ => hginv x)
  rw [Finset.sum_const, nsmul_eq_mul, mul_one] at hsum
  exact ZMod.natCast_eq_zero_iff_even.mp hsum

/-! ### The minimal shell is a single point when no coordinate is half-integral -/

/-- Away from the nearest integer, the squared distance is at least `1/4`. -/
lemma sq_sub_int_ge_quarter (x : ℚ) {k : ℤ} (hk : k ≠ round x) :
    (1 : ℚ) / 4 ≤ (x - (k : ℚ)) ^ 2 := by
  have hb := abs_sub_round x
  rw [abs_le] at hb
  obtain ⟨hb1, hb2⟩ := hb
  rcases (by omega : (1 : ℤ) ≤ round x - k ∨ round x - k ≤ -1) with h | h
  · have hq : (1 : ℚ) ≤ ((round x : ℚ)) - (k : ℚ) := by
      have := (Int.cast_le (R := ℚ)).mpr h
      push_cast at this
      linarith
    nlinarith
  · have hq : ((round x : ℚ)) - (k : ℚ) ≤ -1 := by
      have := (Int.cast_le (R := ℚ)).mpr h
      push_cast at this
      linarith
    nlinarith

/-- If `x` is not half-integral, its squared distance to the nearest integer is `< 1/4`. -/
lemma sq_sub_round_lt_quarter {x : ℚ} (hx : ¬ IsHalfIntegral x) :
    (x - (round x : ℚ)) ^ 2 < 1 / 4 := by
  have hb := abs_sub_round x
  rcases lt_or_eq_of_le hb with h | h
  · nlinarith [abs_nonneg (x - (round x : ℚ)), sq_abs (x - (round x : ℚ))]
  · exfalso
    rcases (abs_eq (by norm_num : (0 : ℚ) ≤ 1 / 2)).mp h with h1 | h1
    · exact hx ⟨round x, by linarith⟩
    · exact hx ⟨round x - 1, by push_cast; linarith⟩

/-- **Uniqueness of the minimiser.**  For a positive diagonal form whose shift has no
half-integral coordinate, the rounding point `round ∘ t` is the unique lattice point at which
`Q(t − ·)` attains its minimum. -/
theorem diagonal_min_shell_unique {a t : Fin n → ℚ} (ha : ∀ i, 0 < a i)
    (hnh : ∀ i, ¬ IsHalfIntegral (t i)) (m : Fin n → ℤ)
    (hm : form (Matrix.diagonal a) (fun i => t i - emb m i)
        = form (Matrix.diagonal a) (fun i => t i - emb (fun j => round (t j)) i)) :
    m = fun j => round (t j) := by
  classical
  by_contra hne
  obtain ⟨i0, hi0⟩ : ∃ i, m i ≠ round (t i) := by
    by_contra hc
    push_neg at hc
    exact hne (funext hc)
  have hstrict : ∀ i, m i ≠ round (t i) →
      a i * (t i - emb (fun j => round (t j)) i) ^ 2 < a i * (t i - emb m i) ^ 2 := by
    intro i hi
    have h1 := sq_sub_round_lt_quarter (hnh i)
    have h2 := sq_sub_int_ge_quarter (t i) hi
    have he1 : emb (fun j => round (t j)) i = ((round (t i) : ℤ) : ℚ) := rfl
    have he2 : emb m i = ((m i : ℤ) : ℚ) := rfl
    rw [he1, he2]
    nlinarith [ha i]
  have hle : ∀ i ∈ (univ : Finset (Fin n)),
      a i * (t i - emb (fun j => round (t j)) i) ^ 2 ≤ a i * (t i - emb m i) ^ 2 := by
    intro i _
    by_cases hi : m i = round (t i)
    · have : emb m i = emb (fun j => round (t j)) i := by
        simp only [emb_apply, hi]
      rw [this]
    · exact (hstrict i hi).le
  have hlt : form (Matrix.diagonal a) (fun i => t i - emb (fun j => round (t j)) i)
      < form (Matrix.diagonal a) (fun i => t i - emb m i) := by
    rw [form_diagonal, form_diagonal]
    exact Finset.sum_lt_sum hle ⟨i0, Finset.mem_univ i0, hstrict i0 hi0⟩
  rw [hm] at hlt
  exact lt_irrefl _ hlt

/-- **Necessity of the criterion.**  If no coordinate of `t` is half-integral, the bottom
coefficient of the shifted theta series of a positive diagonal form equals `1`, hence is odd. -/
theorem diagonal_multiplicity_odd_of_no_halfIntegral {a t : Fin n → ℚ} (ha : ∀ i, 0 < a i)
    (hnh : ∀ i, ¬ IsHalfIntegral (t i)) :
    ∃ (c : ℚ) (S : Finset (Fin n → ℤ)),
      (∀ m : Fin n → ℤ, m ∈ S ↔
        form (Matrix.diagonal a) (fun i => t i - emb m i) = c) ∧ ¬ Even S.card := by
  classical
  refine ⟨form (Matrix.diagonal a) (fun i => t i - emb (fun j => round (t j)) i),
    {fun j => round (t j)}, ?_, ?_⟩
  · intro m
    rw [Finset.mem_singleton]
    exact ⟨fun h => by rw [h], fun h => diagonal_min_shell_unique ha hnh m h⟩
  · simp

/-- **The exact parity criterion for diagonal forms.**  All coefficients of the shifted theta
series of `x ↦ Σ aᵢ(xᵢ − tᵢ)²` are even **iff** some coordinate `tᵢ` is half-integral. -/
theorem diagonal_multiplicity_even_iff {a : Fin n → ℚ} (ha : ∀ i, 0 < a i) (t : Fin n → ℚ) :
    (∀ (c : ℚ) (S : Finset (Fin n → ℤ)),
        (∀ m : Fin n → ℤ, m ∈ S ↔
          form (Matrix.diagonal a) (fun i => t i - emb m i) = c) → Even S.card)
      ↔ ∃ i, IsHalfIntegral (t i) := by
  constructor
  · intro heven
    by_contra hno
    push_neg at hno
    obtain ⟨c, S, hS, hodd⟩ := diagonal_multiplicity_odd_of_no_halfIntegral ha hno
    exact hodd (heven c S hS)
  · rintro ⟨i0, hi0⟩ c S hS
    exact diagonal_multiplicity_even_of_halfIntegral a hi0 c S hS

/-! ### The standard form, and the refutation of Conjecture A -/

lemma one_eq_diagonal_one : (1 : Matrix (Fin n) (Fin n) ℚ) = Matrix.diagonal (fun _ => (1 : ℚ)) :=
  Matrix.diagonal_one.symm

/-- **The exact parity criterion for `ℤⁿ`.**  All coefficients of the shifted theta series of
`x ↦ |x − t|²` are even **iff** some coordinate of `t` is half-integral. -/
theorem standard_multiplicity_even_iff (t : Fin n → ℚ) :
    (∀ (c : ℚ) (S : Finset (Fin n → ℤ)),
        (∀ m : Fin n → ℤ, m ∈ S ↔
          form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => t i - emb m i) = c) → Even S.card)
      ↔ ∃ i, IsHalfIntegral (t i) := by
  rw [one_eq_diagonal_one]
  exact diagonal_multiplicity_even_iff (fun _ => by norm_num) t

/-- The counterexample shift `(1/2, 1/3) ∈ ℚ²`. -/
def badShift : Fin 2 → ℚ := ![1 / 2, 1 / 3]

/-- **Conjecture A is false.**  For `t = (1/2, 1/3)` every coefficient of the shifted theta
series of `ℤ²` is even, yet `2t = (1, 2/3)` is not a lattice vector: parity of the shifted theta
series does *not* detect `2`-torsion of the shift beyond rank one. -/
theorem parity_conjecture_false :
    (∀ (c : ℚ) (S : Finset (Fin 2 → ℤ)),
        (∀ m : Fin 2 → ℤ, m ∈ S ↔
          form (1 : Matrix (Fin 2) (Fin 2) ℚ) (fun i => badShift i - emb m i) = c) →
        Even S.card)
      ∧ ¬ ∃ v : Fin 2 → ℤ, ∀ i, (2 : ℚ) * badShift i = (v i : ℚ) := by
  constructor
  · refine (standard_multiplicity_even_iff badShift).mpr ⟨0, ⟨0, ?_⟩⟩
    norm_num [badShift]
  · rintro ⟨v, hv⟩
    have h1 := hv 1
    have hb : badShift 1 = 1 / 3 := by norm_num [badShift]
    rw [hb] at h1
    have h3 : ((3 * v 1 : ℤ) : ℚ) = ((2 : ℤ) : ℚ) := by push_cast; linarith
    have : 3 * v 1 = 2 := by exact_mod_cast h3
    omega

/-! ### A general-rank shadow: even parity forces a non-unique nearest lattice point -/

/-- **Even parity forces two nearest points.**  For an arbitrary rational form whose spectral
gap at `t` is attained, if the bottom coefficient of the shifted theta series is even then the
minimum is attained at *at least two* lattice points.  Equivalently: whenever `t` has a unique
nearest lattice point, some coefficient is odd.  The diagonal criterion is the quantitative
form of this obstruction — a coordinate flip is exactly what produces the second minimiser. -/
theorem multiplicity_even_imp_two_minimisers {B : Matrix (Fin n) (Fin n) ℚ} {t : Fin n → ℚ}
    {mu : ℚ} (hmu : IsInhomMin B t mu) (S : Finset (Fin n → ℤ))
    (hS : ∀ m : Fin n → ℤ, m ∈ S ↔ form B (fun i => t i - emb m i) = mu)
    (heven : Even S.card) :
    ∃ m m' : Fin n → ℤ, m ≠ m' ∧ form B (fun i => t i - emb m i) = mu ∧
      form B (fun i => t i - emb m' i) = mu := by
  classical
  obtain ⟨m0, hm0⟩ := hmu.1
  have hmem : m0 ∈ S := (hS m0).mpr hm0
  have hpos : 0 < S.card := Finset.card_pos.mpr ⟨m0, hmem⟩
  have hlt : 1 < S.card := by
    rcases heven with ⟨k, hk⟩
    omega
  obtain ⟨m, hm, m', hm', hne⟩ := Finset.one_lt_card.mp hlt
  exact ⟨m, m', hne, (hS m).mp hm, (hS m').mp hm'⟩

/-- The corrected criterion recovers the rank-one theorem of cycle 7: in rank one,
half-integrality of the only coordinate *is* `2`-torsion of the shift. -/
theorem rank_one_criterion_agrees (t : Fin 1 → ℚ) :
    (∃ i, IsHalfIntegral (t i))
      ↔ ((∃ v : Fin 1 → ℤ, ∀ i, (2 : ℚ) * t i = (v i : ℚ)) ∧ ∀ k : Fin 1 → ℤ, t ≠ emb k) := by
  constructor
  · rintro ⟨i, hi⟩
    have hi0 : IsHalfIntegral (t 0) := by
      have : i = 0 := Subsingleton.elim i 0
      rwa [this] at hi
    obtain ⟨⟨w, hw⟩, hnint⟩ := (isHalfIntegral_iff (t 0)).mp hi0
    refine ⟨⟨fun _ => w, ?_⟩, ?_⟩
    · intro j
      have : j = 0 := Subsingleton.elim j 0
      rw [this]
      exact hw
    · intro k hk
      exact hnint (k 0) (by rw [hk]; rfl)
  · rintro ⟨⟨v, hv⟩, hnl⟩
    refine ⟨0, (isHalfIntegral_iff (t 0)).mpr ⟨⟨v 0, hv 0⟩, ?_⟩⟩
    intro k hk
    exact hnl (fun _ => k) (fin_one_ext hk)

end DiophantineLattice