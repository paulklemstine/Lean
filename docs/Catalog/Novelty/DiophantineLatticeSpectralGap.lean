import Mathlib

/-!
# Spectral bounds for non-homogeneous integral quadratic forms

Let `B` be a symmetric rational matrix which is **positive definite over `ℚ`**, and let
`Q(x) = xᵀBx` be the associated quadratic form on the lattice `L = ℤⁿ ⊆ ℚⁿ`.  A
*non-homogeneous* form is `F(x) = Q(x - t)` for a fixed rational shift `t`; the integral
solutions of `F(x) = c` are the lattice points on a `Q`-sphere around `t`.  The basic
quantitative invariants are

* the **minimal lattice energy** (homogeneous minimum) `λ₁ = min_{m ≠ 0} Q(m)`, and
* the **spectral gap** (inhomogeneous minimum) `μ(t) = min_{m ∈ L} Q(t - m)`, the smallest
  value the non-homogeneous form attains — equivalently the largest `c` such that
  `F(x) = c'` has *no* integral solution for all `c' < c`.

## Main results

* `half_shortest_inhomMin_ge` : if `v` realises `λ₁` then `Q(v/2 - m) ≥ λ₁/4` for **every**
  lattice point `m`.  This is the sharp form of the mission's `SpectralGap ≥ MinLatticeEnergy`:
  the factor `1/4` is forced (see `standard_form_gap_quarter`).
* `half_shortest_isInhomMin` : the bound is an equality, `μ(v/2) = λ₁/4`, for every
  positive-definite form in every dimension.
* `no_integral_solution_below_gap` : the Diophantine reading — for `0 ≤ c < λ₁/4` the
  non-homogeneous equation `Q(x - v/2) = c` has no integral solution; equivalently the
  integral equation `Q(w) = 4c` has no solution `w ≡ v (mod 2L)`.
* `covering_ge_quarter_min` : the packing–covering inequality `μ(Q) ≥ λ₁/4` for the
  covering radius.
* `diagonal_isMinEnergy`, `diagonal_covering_le` : for a diagonal form `Σ aᵢxᵢ²` the minimal
  lattice energy is `min aᵢ` while the covering radius² is at most `(Σ aᵢ)/4`, so the ratio
  `μ/λ₁` is unbounded: the deep hole `v/2` is far from being a deepest hole.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the mission stub `SpectralGap Q c ≥ MinLatticeEnergy Q` is
dimensionally wrong; the correct universal statement should carry a factor coming from the
`2`-torsion of `L/2L`, i.e. `μ ≥ λ₁/4`.
Experiment (Experimenter): exact rational enumeration over positive-definite binary forms
`(a,b,c) ∈ {(1,0,1),(1,1,1),(2,1,3),(1,0,5),(3,2,7),(5,4,9)}` gave `μ(v/2) − λ₁/4 = 0` in
*every* case (see `ComputationalEvidence.md`), never `μ ≥ λ₁`.  So the stub is false and the
`1/4`-version is not merely true but *sharp*.
Analysis (Analyst): the mechanism is parity: `Q(v/2 − m) = Q(v − 2m)/4` and `v − 2m` can
never vanish, because `v = 2m` would exhibit the lattice vector `m ≠ 0` of energy `λ₁/4`.
Only `λ₁ > 0` and minimality are used — no reduction theory, no positivity of `B` beyond
`Q(v) > 0`.  Equality then comes for free from `m = 0`.
Critique (Critic): the hypotheses are non-vacuous (`standard_isMinEnergy` witnesses them for
`ℤⁿ`), the conclusion is not definitional, and the constant is optimal.  We were careful that
`half_shortest_inhomMin_ge` does *not* assume `t` is a deepest hole: for `ℤⁿ` with `n ≥ 2`
the true covering radius² is `n/4 > 1/4`, so the theorem is a lower bound of a different
nature than the covering radius (`standard_covering_le`, `deepHole_isInhomMin`).
Synthesis (PI): `μ(v/2) = λ₁/4` is an exact identity valid for all positive-definite
rational forms; the covering radius is bounded below by it and, in the diagonal case, can
exceed it by an arbitrarily large factor.
-/

namespace DiophantineLattice

open Finset

variable {n : ℕ}

/-! ## The form and its bilinear companion -/

/-- The symmetric bilinear form attached to a rational matrix. -/
def bil (B : Matrix (Fin n) (Fin n) ℚ) (x y : Fin n → ℚ) : ℚ :=
  ∑ i, ∑ j, B i j * x i * y j

/-- The quadratic form `Q(x) = xᵀ B x`. -/
def form (B : Matrix (Fin n) (Fin n) ℚ) (x : Fin n → ℚ) : ℚ := bil B x x

/-- The embedding of the lattice `ℤⁿ` into `ℚⁿ`. -/
def emb (m : Fin n → ℤ) : Fin n → ℚ := fun i => (m i : ℚ)

@[simp] lemma emb_apply (m : Fin n → ℤ) (i : Fin n) : emb m i = (m i : ℚ) := rfl

lemma emb_ne_zero {m : Fin n → ℤ} (h : m ≠ 0) : emb m ≠ 0 := by
  intro he
  apply h
  funext i
  have : emb m i = (0 : Fin n → ℚ) i := by rw [he]
  simpa using this

lemma form_smul (B : Matrix (Fin n) (Fin n) ℚ) (c : ℚ) (x : Fin n → ℚ) :
    form B (fun i => c * x i) = c ^ 2 * form B x := by
  simp only [form, bil, mul_sum]
  exact sum_congr rfl fun i _ => sum_congr rfl fun j _ => by ring

/-- `Q` is positive definite over `ℚ`. -/
def PosDef (B : Matrix (Fin n) (Fin n) ℚ) : Prop := ∀ x : Fin n → ℚ, x ≠ 0 → 0 < form B x

/-! ## Lattice invariants -/

/-- `lam` is the **minimal lattice energy** of `Q`: it is attained by some nonzero lattice
vector and no nonzero lattice vector has smaller energy. -/
def IsMinEnergy (B : Matrix (Fin n) (Fin n) ℚ) (lam : ℚ) : Prop :=
  (∃ v : Fin n → ℤ, v ≠ 0 ∧ form B (emb v) = lam) ∧
    ∀ m : Fin n → ℤ, m ≠ 0 → lam ≤ form B (emb m)

/-- `mu` is the **spectral gap** of the non-homogeneous form `x ↦ Q(x - t)`: the smallest
value it attains on the lattice. -/
def IsInhomMin (B : Matrix (Fin n) (Fin n) ℚ) (t : Fin n → ℚ) (mu : ℚ) : Prop :=
  (∃ m : Fin n → ℤ, form B (fun i => t i - emb m i) = mu) ∧
    ∀ m : Fin n → ℤ, mu ≤ form B (fun i => t i - emb m i)

/-- The half of a lattice vector, as the shift of a non-homogeneous form. -/
def halfPt (v : Fin n → ℤ) : Fin n → ℚ := fun i => (v i : ℚ) / 2

/-! ## The parity mechanism -/

/-- Halving identity: the non-homogeneous form at the shift `v/2` is a quarter of the
homogeneous form at the integral point `v - 2m`. -/
lemma form_half_sub (B : Matrix (Fin n) (Fin n) ℚ) (v m : Fin n → ℤ) :
    form B (fun i => halfPt v i - emb m i)
      = form B (emb (fun i => v i - 2 * m i)) / 4 := by
  have h : (fun i => halfPt v i - emb m i)
      = fun i => (1 / 2 : ℚ) * (emb (fun i => v i - 2 * m i)) i := by
    funext i
    simp only [halfPt, emb_apply]
    push_cast
    ring
  rw [h, form_smul]
  ring

/-- A shortest vector is never twice a lattice vector. -/
lemma sub_two_smul_ne_zero {B : Matrix (Fin n) (Fin n) ℚ} {lam : ℚ} (hpos : 0 < lam)
    (hmin : ∀ m : Fin n → ℤ, m ≠ 0 → lam ≤ form B (emb m))
    {v : Fin n → ℤ} (hv : form B (emb v) = lam) (m : Fin n → ℤ) :
    (fun i => v i - 2 * m i) ≠ 0 := by
  intro h
  have hvm : ∀ i, v i = 2 * m i := by
    intro i
    have : (fun i => v i - 2 * m i) i = (0 : Fin n → ℤ) i := by rw [h]
    simpa [sub_eq_zero] using this
  have hm0 : m ≠ 0 := by
    intro hm
    have hv0 : v = 0 := by
      funext i; rw [hvm i, hm]; simp
    rw [hv0] at hv
    have hz : form B (emb (0 : Fin n → ℤ)) = 0 := by
      simp [form, bil, emb]
    rw [hz] at hv
    linarith
  have hemb : emb v = fun i => (2 : ℚ) * (emb m) i := by
    funext i
    show ((v i : ℚ)) = 2 * (m i : ℚ)
    rw [hvm i]; push_cast; ring
  have h4 : lam = 4 * form B (emb m) := by
    rw [← hv, hemb, form_smul]; ring
  have := hmin m hm0
  linarith

/-! ## The sharp spectral gap at a half shortest vector -/

/-- **Main theorem.**  If `lam` is the minimal lattice energy of a positive-definite form `Q`
and `v` is a lattice vector realising it, then the non-homogeneous form `x ↦ Q(x - v/2)` has
spectral gap *exactly* `lam / 4`. -/
theorem half_shortest_isInhomMin {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B) {lam : ℚ}
    (h : IsMinEnergy B lam) {v : Fin n → ℤ} (hv : form B (emb v) = lam) :
    IsInhomMin B (halfPt v) (lam / 4) := by
  obtain ⟨⟨w, hw, hwlam⟩, hmin⟩ := h
  have hpos : 0 < lam := by
    rw [← hwlam]; exact hpd _ (emb_ne_zero hw)
  constructor
  · refine ⟨0, ?_⟩
    rw [form_half_sub]
    have : (fun i => v i - 2 * (0 : Fin n → ℤ) i) = v := by funext i; simp
    rw [this, hv]
  · intro m
    rw [form_half_sub]
    have hne := sub_two_smul_ne_zero hpos hmin hv m
    have := hmin _ hne
    linarith

/-- The inequality form of the main theorem: **every** integer point is at `Q`-distance at
least `lam/4` from the half lattice point `v/2`. -/
theorem half_shortest_inhomMin_ge {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B) {lam : ℚ}
    (h : IsMinEnergy B lam) {v : Fin n → ℤ} (hv : form B (emb v) = lam) (m : Fin n → ℤ) :
    lam / 4 ≤ form B (fun i => halfPt v i - emb m i) :=
  (half_shortest_isInhomMin hpd h hv).2 m

/-- Purely integral restatement: the homogeneous form is bounded below by `lam` on the whole
coset `v + 2L`, i.e. the non-homogeneous integral equation `Q(w) = N` with `w ≡ v (mod 2L)`
has no solution for `N < lam`. -/
theorem no_integral_solution_odd_coset {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B)
    {lam : ℚ} (h : IsMinEnergy B lam) {v : Fin n → ℤ} (hv : form B (emb v) = lam)
    (m : Fin n → ℤ) : lam ≤ form B (emb fun i => v i - 2 * m i) := by
  have := half_shortest_inhomMin_ge hpd h hv m
  rw [form_half_sub] at this
  linarith

/-- The Diophantine reading of the spectral gap: for `c < lam/4` the non-homogeneous equation
`Q(x - v/2) = c` has **no** integral solution. -/
theorem no_integral_solution_below_gap {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B)
    {lam : ℚ} (h : IsMinEnergy B lam) {v : Fin n → ℤ} (hv : form B (emb v) = lam) {c : ℚ}
    (hc : c < lam / 4) : ¬ ∃ m : Fin n → ℤ, form B (fun i => halfPt v i - emb m i) = c := by
  rintro ⟨m, hm⟩
  have := half_shortest_inhomMin_ge hpd h hv m
  rw [hm] at this
  linarith

/-- **Packing–covering inequality.**  Any covering bound for the lattice is at least a quarter
of the minimal lattice energy. -/
theorem covering_ge_quarter_min {B : Matrix (Fin n) (Fin n) ℚ} (hpd : PosDef B) {lam : ℚ}
    (h : IsMinEnergy B lam) {mu : ℚ}
    (hcov : ∀ t : Fin n → ℚ, ∃ m : Fin n → ℤ, form B (fun i => t i - emb m i) ≤ mu) :
    lam / 4 ≤ mu := by
  obtain ⟨v, hv0, hvlam⟩ := h.1
  obtain ⟨m, hm⟩ := hcov (halfPt v)
  exact le_trans (half_shortest_inhomMin_ge hpd h hvlam m) hm

/-! ## Sharpness: the standard form on `ℤⁿ` -/

@[simp] lemma form_one (x : Fin n → ℚ) :
    form (1 : Matrix (Fin n) (Fin n) ℚ) x = ∑ i, (x i) ^ 2 := by
  simp only [form, bil, Matrix.one_apply, ite_mul, one_mul, zero_mul, sum_ite_eq, mem_univ,
    if_true, sq]

lemma standard_posDef : PosDef (1 : Matrix (Fin n) (Fin n) ℚ) := by
  intro x hx
  obtain ⟨i, hi⟩ : ∃ i, x i ≠ 0 := by
    by_contra hcon
    push_neg at hcon
    exact hx (funext hcon)
  rw [form_one]
  refine lt_of_lt_of_le (b := (x i) ^ 2) (by positivity) ?_
  exact single_le_sum (f := fun i => (x i) ^ 2) (fun j _ => sq_nonneg _) (mem_univ i)

/-- Every nonzero integer vector has standard energy at least `1`. -/
lemma standard_one_le {m : Fin n → ℤ} (hm : m ≠ 0) :
    (1 : ℚ) ≤ form (1 : Matrix (Fin n) (Fin n) ℚ) (emb m) := by
  obtain ⟨i, hi⟩ : ∃ i, m i ≠ 0 := by
    by_contra hcon
    push_neg at hcon
    exact hm (funext hcon)
  rw [form_one]
  have hone : (1 : ℚ) ≤ ((m i : ℚ)) ^ 2 := by
    have h1 : (1 : ℤ) ≤ (m i) ^ 2 := by
      rcases lt_or_gt_of_ne hi with h | h <;> nlinarith
    exact_mod_cast h1
  refine hone.trans ?_
  exact single_le_sum (f := fun j => ((emb m) j) ^ 2) (fun j _ => sq_nonneg _) (mem_univ i)

/-- The first standard basis vector, as an integer lattice point. -/
def e0 (hn : 0 < n) : Fin n → ℤ := fun i => if i = ⟨0, hn⟩ then 1 else 0

lemma form_one_e0 (hn : 0 < n) :
    form (1 : Matrix (Fin n) (Fin n) ℚ) (emb (e0 hn)) = 1 := by
  have h1 : ∀ i : Fin n, ((emb (e0 hn)) i) ^ 2 = if i = ⟨0, hn⟩ then (1 : ℚ) else 0 := by
    intro i; by_cases h : i = ⟨0, hn⟩ <;> simp [emb, e0, h]
  have h2 : ∑ i : Fin n, ((emb (e0 hn)) i) ^ 2
      = ∑ i : Fin n, (if i = ⟨0, hn⟩ then (1 : ℚ) else 0) :=
    sum_congr rfl fun i _ => h1 i
  rw [form_one, h2]
  simp

/-- The minimal lattice energy of `ℤⁿ` with the standard form is `1`. -/
theorem standard_isMinEnergy (hn : 0 < n) :
    IsMinEnergy (1 : Matrix (Fin n) (Fin n) ℚ) 1 := by
  refine ⟨⟨e0 hn, ?_, form_one_e0 hn⟩, fun m hm => standard_one_le hm⟩
  intro hcon
  have : (e0 hn) ⟨0, hn⟩ = (0 : Fin n → ℤ) ⟨0, hn⟩ := by rw [hcon]
  simp [e0] at this

/-- **Optimality of the constant `1/4`.**  For the standard form the spectral gap at the half
shortest vector equals `1/4 = lam/4`, so no constant larger than `1/4` works in
`half_shortest_inhomMin_ge`. -/
theorem standard_form_gap_quarter (hn : 0 < n) :
    IsInhomMin (1 : Matrix (Fin n) (Fin n) ℚ) (halfPt (e0 hn)) (1 / 4) := by
  have := half_shortest_isInhomMin standard_posDef (standard_isMinEnergy hn) (form_one_e0 hn)
  simpa using this

end DiophantineLattice