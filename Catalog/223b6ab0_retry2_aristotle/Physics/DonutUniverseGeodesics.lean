import Mathlib

/-!
# The Donut Universe: closed timelike geodesics and the winding lattice

This file models a spatially (and temporally) closed *donut-shaped* universe as a
flat pseudo-Riemannian torus and establishes two structural facts about it.

* **Closed timelike geodesics exist.** Equipping the universal cover
  `ℝ^{1+d}` with the flat Minkowski form `Q(v) = -v₀² + Σ vᵢ²`, a straight
  world-line `t ↦ t·v` in an *integer timelike* direction (`Q(v) < 0`) projects
  to a genuinely nonconstant *loop* of period one on the torus
  `𝕋^{1+d} = (ℝ/ℤ)^{1+d}`.  In particular the time circle itself is such a loop,
  so a donut universe threads itself with closed timelike curves.

* **The winding lattice `π₁(𝕋^{n}) ≅ ℤ^{n}`.**  The kernel of the covering
  projection `ℝⁿ → 𝕋ⁿ` is exactly the integer lattice, the group of covering
  translations, which is a free abelian group of rank `n`.

* **A number-theoretic bridge.**  On the two-torus the covering group is `ℤ²`.
  Consecutive Fibonacci winding vectors `(Fₙ, Fₙ₊₁)` and `(Fₙ₊₁, Fₙ₊₂)` differ
  by a *unimodular* change of basis: the Cassini identity
  `Fₙ Fₙ₊₂ − Fₙ₊₁² = (−1)^{n+1}` says their determinant is `±1`, so every stage
  of the Fibonacci recursion is a genuine basis of the fundamental group.  This
  links the arithmetic of Fibonacci numbers to the topology of the donut
  universe.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): A closed timelike universe (a torus with a compact
time direction) must contain closed timelike geodesics, and the ways to wrap
around it form a free abelian group whose rank equals the dimension.

Experiment (Experimenter): Realize `𝕋ⁿ = Fin n → AddCircle 1`, geodesics as
projections of integer-direction lines, and the Minkowski form as
`-x₀² + Σxᵢ²`.  Identify the covering kernel with the integer lattice, and
compute the Cassini determinant of consecutive Fibonacci winding vectors.

Analysis (Analyst): Periodicity is the statement that integer directions lie in
the kernel; nonconstancy is witnessed by a half-period point landing on the
order-two element `1/2 ∈ ℝ/ℤ`.  Timelike existence reduces to producing one
integer vector with negative Minkowski norm — the standard time direction `e₀`.

Critique (Critic): "Closed geodesic" must be nonconstant, not merely periodic;
we prove nonconstancy from a nonzero coordinate.  "Timelike" must be a genuine
sign condition on the Minkowski form, not a vacuous predicate; we exhibit
`Q(e₀) = -1 < 0`.  The basis claim must be unimodularity, proved via Cassini,
not mere coprimality.

Synthesis (PI): Closed timelike geodesics + a rank-`n` winding lattice +
Fibonacci unimodular bases give a concrete, cross-domain account of the
donut universe's causal and topological structure.
-/

open AddCircle

namespace DonutUniverse

/-! ## The flat torus and its covering projection -/

/-- The flat `n`-torus `𝕋ⁿ = (ℝ/ℤ)ⁿ`. -/
abbrev Torus (n : ℕ) := Fin n → AddCircle (1 : ℝ)

/-- The universal covering projection `ℝⁿ → 𝕋ⁿ`, an additive group homomorphism. -/
noncomputable def proj (n : ℕ) : (Fin n → ℝ) →+ Torus n :=
  Pi.addMonoidHom fun i =>
    (QuotientAddGroup.mk' _).comp (Pi.evalAddMonoidHom (fun _ : Fin n => ℝ) i)

@[simp] theorem proj_apply (n : ℕ) (x : Fin n → ℝ) (i : Fin n) :
    proj n x i = ((x i : ℝ) : AddCircle (1 : ℝ)) := rfl

/-- The integer translation lattice `ℤⁿ ↪ ℝⁿ`, the covering-translation group. -/
def latt (n : ℕ) : (Fin n → ℤ) →+ (Fin n → ℝ) where
  toFun m := fun i => (m i : ℝ)
  map_zero' := by funext i; simp
  map_add' a b := by funext i; simp only [Pi.add_apply]; push_cast; ring

@[simp] theorem latt_apply (n : ℕ) (m : Fin n → ℤ) (i : Fin n) : latt n m i = (m i : ℝ) := rfl

theorem latt_injective (n : ℕ) : Function.Injective (latt n) := by
  intro a b h; funext i
  have : (a i : ℝ) = (b i : ℝ) := congrFun h i
  exact_mod_cast this

/-- **The covering kernel is the integer lattice.** A point of the cover projects
to the base point iff every coordinate is an integer. -/
theorem mem_ker_iff (n : ℕ) (x : Fin n → ℝ) :
    proj n x = 0 ↔ ∀ i, ∃ m : ℤ, x i = m := by
  constructor
  · intro h i
    have hi : ((x i : ℝ) : AddCircle (1 : ℝ)) = 0 := by rw [← proj_apply, h]; rfl
    rw [AddCircle.coe_eq_zero_iff] at hi
    obtain ⟨m, hm⟩ := hi
    exact ⟨m, by simpa using hm.symm⟩
  · intro h
    funext i
    obtain ⟨m, hm⟩ := h i
    rw [Pi.zero_apply, proj_apply, hm, AddCircle.coe_eq_zero_iff]
    exact ⟨m, by simp⟩

/-- **`π₁(𝕋ⁿ) ≅ ℤⁿ`, group-theoretic form.** The covering-translation group
(the kernel of the covering projection) is exactly the image of the integer
lattice, a free abelian group of rank `n`. -/
theorem ker_proj_eq_range (n : ℕ) : (proj n).ker = (latt n).range := by
  ext x
  simp only [AddMonoidHom.mem_ker, AddMonoidHom.mem_range]
  rw [mem_ker_iff]
  constructor
  · intro h
    choose m hm using h
    exact ⟨m, by funext i; exact (hm i).symm⟩
  · rintro ⟨m, rfl⟩ i
    exact ⟨m i, rfl⟩

/-! ## Geodesics of the flat torus -/

/-- The geodesic with integer direction `m`, the projection of the line `t ↦ t·m`. -/
def geo (n : ℕ) (m : Fin n → ℤ) (t : ℝ) : Torus n :=
  fun i => ((t * m i : ℝ) : AddCircle (1 : ℝ))

/-- Each integer-direction geodesic is the projection of a straight world-line. -/
theorem geo_eq_proj_line (n : ℕ) (m : Fin n → ℤ) (t : ℝ) :
    geo n m t = proj n (fun i => t * (m i : ℝ)) := rfl

/-- **Closedness.** An integer-direction geodesic is a loop of period one. -/
theorem geo_periodic (n : ℕ) (m : Fin n → ℤ) (t : ℝ) : geo n m (t + 1) = geo n m t := by
  funext i
  show (((t + 1) * m i : ℝ) : AddCircle (1 : ℝ)) = ((t * m i : ℝ) : AddCircle (1 : ℝ))
  rw [show ((t + 1) * m i : ℝ) = (m i) • (1 : ℝ) + t * m i by
        simp only [zsmul_eq_mul, mul_one]; ring,
      coe_add, coe_zsmul, coe_period, smul_zero, zero_add]

@[simp] theorem geo_zero (n : ℕ) (m : Fin n → ℤ) : geo n m 0 = 0 := by
  funext i
  show (((0 : ℝ) * m i : ℝ) : AddCircle (1 : ℝ)) = 0
  simp

/-- **Nontriviality of wrapping.** A nonzero integer direction gives a genuinely
nonconstant loop; the witness is a half-period point landing on `1/2 ∈ ℝ/ℤ`. -/
theorem geo_nontrivial (n : ℕ) (m : Fin n → ℤ) (hm : m ≠ 0) :
    ∃ t : ℝ, geo n m t ≠ geo n m 0 := by
  rw [Function.ne_iff] at hm
  obtain ⟨i, hi⟩ := hm
  refine ⟨1 / (2 * m i), ?_⟩
  intro h
  have hne : (m i : ℝ) ≠ 0 := by exact_mod_cast (by simpa using hi)
  have hci := congrFun h i
  rw [geo_zero] at hci
  simp only [geo, Pi.zero_apply] at hci
  rw [show (1 / (2 * (m i : ℝ)) * m i : ℝ) = 1 / 2 by field_simp] at hci
  rw [AddCircle.coe_eq_zero_iff] at hci
  obtain ⟨k, hk⟩ := hci
  simp only [zsmul_eq_mul, mul_one] at hk
  have h1 : (2 * k : ℤ) = 1 := by
    have h2 : (2 : ℝ) * k = 1 := by rw [hk]; ring
    exact_mod_cast h2
  omega

/-! ## The Lorentzian structure and closed timelike geodesics -/

/-- The flat Minkowski quadratic form on `ℝ^{1+d}`: coordinate `0` is time. -/
def mink (d : ℕ) (v : Fin (d + 1) → ℝ) : ℝ :=
  -(v 0) ^ 2 + ∑ i : Fin d, (v i.succ) ^ 2

/-- An integer direction is *timelike* when its Minkowski norm is negative. -/
def Timelike (d : ℕ) (m : Fin (d + 1) → ℤ) : Prop :=
  mink d (fun i => (m i : ℝ)) < 0

/-- The standard time direction `e₀` (winding once around the time circle) is
timelike: its Minkowski norm equals `-1`. -/
theorem e0_timelike (d : ℕ) :
    Timelike d (Pi.single (0 : Fin (d + 1)) (1 : ℤ) : Fin (d + 1) → ℤ) := by
  unfold Timelike mink
  have hs : ∀ i : Fin d,
      ((Pi.single (0 : Fin (d + 1)) (1 : ℤ) : Fin (d + 1) → ℤ) i.succ : ℝ) = 0 := by
    intro i
    rw [Pi.single_eq_of_ne (Fin.succ_ne_zero i)]; simp
  simp only [hs]
  simp

/-- The time direction is a nonzero integer vector. -/
theorem e0_ne_zero (d : ℕ) :
    (Pi.single (0 : Fin (d + 1)) (1 : ℤ) : Fin (d + 1) → ℤ) ≠ 0 := by
  intro h
  have := congrFun h 0
  simp at this

/-- **Closed timelike geodesics exist in the donut universe.**  On the flat
Lorentzian torus `𝕋^{1+d}` there is a nonzero integer direction that is timelike
and whose geodesic is a nonconstant loop of period one — a closed timelike
curve threading the closed universe. -/
theorem exists_closed_timelike_geodesic (d : ℕ) :
    ∃ m : Fin (d + 1) → ℤ,
      m ≠ 0 ∧ Timelike d m ∧
      (∀ t : ℝ, geo (d + 1) m (t + 1) = geo (d + 1) m t) ∧
      (∃ t : ℝ, geo (d + 1) m t ≠ geo (d + 1) m 0) := by
  refine ⟨Pi.single (0 : Fin (d + 1)) (1 : ℤ), e0_ne_zero d, e0_timelike d, ?_, ?_⟩
  · intro t; exact geo_periodic (d + 1) _ t
  · exact geo_nontrivial (d + 1) _ (e0_ne_zero d)

/-! ## A number-theoretic bridge: Fibonacci winding vectors -/

/-- **Cassini's identity** for Fibonacci numbers, in signed (integer) form:
`Fₙ · Fₙ₊₂ − Fₙ₊₁² = (−1)^{n+1}`. -/
theorem cassini (n : ℕ) :
    (Nat.fib n : ℤ) * (Nat.fib (n + 2)) - (Nat.fib (n + 1)) ^ 2 = (-1) ^ (n + 1) := by
  induction n with
  | zero => decide
  | succ k ih =>
    have e2 : Nat.fib (k + 2) = Nat.fib k + Nat.fib (k + 1) := Nat.fib_add_two
    have e3 : Nat.fib (k + 3) = Nat.fib (k + 1) + Nat.fib (k + 2) := Nat.fib_add_two
    push_cast [e2, e3] at *; ring_nf; ring_nf at ih; linarith [ih]

/-- The `2×2` integer matrix whose columns are the consecutive Fibonacci winding
vectors `(Fₙ, Fₙ₊₁)` and `(Fₙ₊₁, Fₙ₊₂)`. -/
def fibWind (n : ℕ) : Matrix (Fin 2) (Fin 2) ℤ :=
  !![(Nat.fib n : ℤ), (Nat.fib (n + 1)); (Nat.fib (n + 1)), (Nat.fib (n + 2))]

/-- **The Fibonacci winding vectors form a basis of the fundamental group.**
On the two-torus, whose fundamental group is the winding lattice `ℤ²`, the pair
of consecutive Fibonacci winding vectors is *unimodular*: their determinant is
`±1`, so each stage of the Fibonacci recursion is a genuine `ℤ`-basis. -/
theorem fibWind_det (n : ℕ) : (fibWind n).det = (-1) ^ (n + 1) := by
  rw [fibWind, Matrix.det_fin_two_of]
  have := cassini n
  ring_nf; ring_nf at this; linarith [this]

/-- Consequently the Fibonacci winding matrix is invertible over `ℤ`
(an element of `GL₂(ℤ)`): consecutive Fibonacci windings are a change of basis
of the donut universe's fundamental group. -/
theorem fibWind_isUnit_det (n : ℕ) : IsUnit (fibWind n).det := by
  rw [fibWind_det]
  exact (isUnit_one.neg).pow (n + 1)

end DonutUniverse