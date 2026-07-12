import Mathlib

/-!
# Realizability, duality, and the code rate of homological CSS codes

This file continues the "logical qubits = middle homology" dictionary for CSS /
homological quantum error correcting codes.  A code is a length-two chain complex

  `A --d₂--> B --d₁--> C`,   `d₁ ∘ d₂ = 0`,

over a field `K`; the physical qubits live in `B` and the number of *logical*
qubits is the dimension of the middle homology `H = ker d₁ / im d₂`.

Building on the exact dimension identity
`k + rank d₁ + rank d₂ = dim B` we settle three of the future-direction
conjectures for this cycle:

* **Realizability (Conjecture 3).**  `realizable_pair` / `realizable_le`:
  for every field `K` and every `k ≤ n` there is a length-two complex with
  `dim B = n` and logical dimension *exactly* `k`.  Hence every physical/logical
  pair `(n, k)` is realised by some CSS complex.

* **Cohomological / CSS self-duality (Conjecture 4).**  `numLogical_dual`:
  the transposed ("dual") complex `C* --d₁ᵀ--> B* --d₂ᵀ--> A*` has the *same*
  logical dimension as the original.  The `X`-logical space `ker d₁ / im d₂` and
  the `Z`-logical space `ker d₂ᵀ / im d₁ᵀ` therefore always match — CSS
  self-duality is a shadow of the rank symmetry `rank fᵀ = rank f`.

* **Euler characteristic as a code rate (Conjecture 2).**  `rate_eq` /
  `rate_tree` / `rate_bouquet`: for a connected graph complex the code rate
  `k / E` equals `1 − (V−1)/E`; it is `0` for a tree (`E = V − 1`) and `1` for a
  one-vertex bouquet (`V = 1`).

All results are field-agnostic and use the *additive* form of rank–nullity, so
there is no truncated ℕ-subtraction.
-/

open Module LinearMap

namespace HomQECC

/-- A length-two chain complex `A --d₂--> B --d₁--> C` with `d₁ ∘ d₂ = 0`:
the algebraic skeleton of a CSS quantum code.  `B` carries the physical qubits. -/
structure ChainCplx (K : Type*) [Field K]
    (A B C : Type*) [AddCommGroup A] [Module K A] [AddCommGroup B] [Module K B]
    [AddCommGroup C] [Module K C] where
  /-- the second boundary map, image = space of boundaries. -/
  d2 : A →ₗ[K] B
  /-- the first boundary map, kernel = space of cycles. -/
  d1 : B →ₗ[K] C
  /-- the chain-complex condition `d₁ ∘ d₂ = 0`. -/
  comp_eq_zero : d1.comp d2 = 0

namespace ChainCplx

variable {K A B C : Type*} [Field K]
  [AddCommGroup A] [Module K A] [AddCommGroup B] [Module K B]
  [AddCommGroup C] [Module K C]

/-- The cycles `Z = ker d₁`. -/
def cycles (X : ChainCplx K A B C) : Submodule K B := LinearMap.ker X.d1

/-- The boundaries `Bd = im d₂`. -/
def boundaries (X : ChainCplx K A B C) : Submodule K B := LinearMap.range X.d2

/-- Boundaries are cycles: `im d₂ ⊆ ker d₁`. -/
lemma boundaries_le_cycles (X : ChainCplx K A B C) : X.boundaries ≤ X.cycles := by
  rintro _ ⟨a, rfl⟩
  have h := X.comp_eq_zero
  simp only [cycles, LinearMap.mem_ker, ← LinearMap.comp_apply, h, LinearMap.zero_apply]

/-- The logical space = middle homology `H = ker d₁ / im d₂`. -/
noncomputable def homology (X : ChainCplx K A B C) : Type _ :=
  X.cycles ⧸ (X.boundaries.comap X.cycles.subtype)

noncomputable instance (X : ChainCplx K A B C) : AddCommGroup X.homology :=
  inferInstanceAs (AddCommGroup (X.cycles ⧸ _))

noncomputable instance (X : ChainCplx K A B C) : Module K X.homology :=
  inferInstanceAs (Module K (X.cycles ⧸ _))

/-- The number of logical qubits, `k = dim H`. -/
noncomputable def numLogical (X : ChainCplx K A B C) : ℕ := Module.finrank K X.homology

/-! ## Core dimension identities -/

/-- Splitting off boundaries: `dim H + rank d₂ = dim(ker d₁)`. -/
theorem finrank_homology_add_boundaries [FiniteDimensional K B]
    (X : ChainCplx K A B C) :
    X.numLogical + Module.finrank K (LinearMap.range X.d2) = Module.finrank K X.cycles := by
  have hcomap : Module.finrank K (X.boundaries.comap X.cycles.subtype)
      = Module.finrank K (LinearMap.range X.d2) :=
    LinearEquiv.finrank_eq (Submodule.comapSubtypeEquivOfLe X.boundaries_le_cycles)
  have := Submodule.finrank_quotient_add_finrank (X.boundaries.comap X.cycles.subtype)
  rw [hcomap] at this
  exact this

/-- Rank–nullity on `d₁`: `dim(ker d₁) + rank d₁ = dim B`. -/
theorem finrank_cycles_add_rank_d1 [FiniteDimensional K B]
    (X : ChainCplx K A B C) :
    Module.finrank K X.cycles + Module.finrank K (LinearMap.range X.d1) = Module.finrank K B := by
  rw [add_comm, ← LinearMap.finrank_range_add_finrank_ker X.d1]
  rfl

/-- **CSS dimension formula.** `k + rank d₁ + rank d₂ = dim B`. -/
theorem numLogical_add [FiniteDimensional K B] (X : ChainCplx K A B C) :
    X.numLogical + Module.finrank K (LinearMap.range X.d1)
      + Module.finrank K (LinearMap.range X.d2) = Module.finrank K B := by
  have h1 := finrank_homology_add_boundaries X
  have h2 := finrank_cycles_add_rank_d1 X
  omega

/-! ## Conjecture 4 : cohomological / CSS self-duality -/

/-- The **dual (transposed) complex** `C* --d₁ᵀ--> B* --d₂ᵀ--> A*`.
Transposition turns `Z`-checks into `X`-checks and vice versa. -/
def dual (X : ChainCplx K A B C) :
    ChainCplx K (Module.Dual K C) (Module.Dual K B) (Module.Dual K A) where
  d2 := X.d1.dualMap
  d1 := X.d2.dualMap
  comp_eq_zero := by
    rw [LinearMap.dualMap_comp_dualMap, X.comp_eq_zero]
    ext φ x
    simp

/-- **CSS self-duality (Conjecture 4).**  The transposed complex has the same
logical dimension: `dim (ker d₁ / im d₂) = dim (ker d₂ᵀ / im d₁ᵀ)`.  Equivalently
the `X`-logical and `Z`-logical spaces have equal dimension. -/
theorem numLogical_dual [FiniteDimensional K B] (X : ChainCplx K A B C) :
    X.dual.numLogical = X.numLogical := by
  have hB : Module.finrank K (Module.Dual K B) = Module.finrank K B :=
    Subspace.dual_finrank_eq
  have hd1 : Module.finrank K (LinearMap.range X.dual.d1)
      = Module.finrank K (LinearMap.range X.d2) :=
    LinearMap.finrank_range_dualMap_eq_finrank_range X.d2
  have hd2 : Module.finrank K (LinearMap.range X.dual.d2)
      = Module.finrank K (LinearMap.range X.d1) :=
    LinearMap.finrank_range_dualMap_eq_finrank_range X.d1
  have horig := numLogical_add X
  have hdual := numLogical_add X.dual
  rw [hB, hd1, hd2] at hdual
  omega

/-! ## Conjecture 3 : every logical/physical pair is realizable -/

/-- **Realizability (Conjecture 3), parametric form.**  For every field `K` and
all `p k : ℕ` there is a length-two complex with `dim B = p + k` and logical
dimension *exactly* `k`.  (Take `B = Kᵖ × Kᵏ`, `d₂ = 0`, `d₁ = fst`.) -/
theorem realizable_pair (K : Type) [Field K] (p k : ℕ) :
    ∃ (A B C : Type) (_ : AddCommGroup A) (_ : Module K A) (_ : AddCommGroup B)
      (_ : Module K B) (_ : AddCommGroup C) (_ : Module K C) (_ : FiniteDimensional K B)
      (X : ChainCplx K A B C),
      Module.finrank K B = p + k ∧ X.numLogical = k := by
  classical
  refine ⟨PUnit, (Fin p → K) × (Fin k → K), (Fin p → K),
    inferInstance, inferInstance, inferInstance, inferInstance, inferInstance,
    inferInstance, inferInstance, ?_⟩
  refine ⟨{ d2 := 0, d1 := LinearMap.fst K (Fin p → K) (Fin k → K), comp_eq_zero := by simp }, ?_, ?_⟩
  · simp
  · -- use the dimension formula k + rank d1 + rank d2 = dim B
    set X : ChainCplx K PUnit ((Fin p → K) × (Fin k → K)) (Fin p → K) :=
      { d2 := 0, d1 := LinearMap.fst K (Fin p → K) (Fin k → K), comp_eq_zero := by simp } with hX
    have hform := numLogical_add X
    have hrange1 : Module.finrank K (LinearMap.range X.d1) = p := by
      have hsurj : LinearMap.range X.d1 = ⊤ := by
        rw [LinearMap.range_eq_top]
        intro y; exact ⟨(y, 0), rfl⟩
      rw [hsurj]
      simp
    have hrange2 : Module.finrank K (LinearMap.range X.d2) = 0 := by
      simp [hX, LinearMap.range_zero]
    have hB : Module.finrank K ((Fin p → K) × (Fin k → K)) = p + k := by
      simp [Module.finrank_prod]
    rw [hrange1, hrange2, hB] at hform
    omega

/-- **Rank-prescription realizability (Conjecture 3, refined).**  The exact
dimension formula `k = dim B − rank d₁ − rank d₂` is an *accounting*, so any
prescribed ranks can be realised: for all `r s m : ℕ` there is a length-two
complex with `dim B = r + s + m`, `rank d₁ = r`, `rank d₂ = s`, and logical
dimension exactly `m`.  Take `B = Kʳ × Kˢ × Kᵐ`, `d₁ = fst` (rank `r`), and
`d₂` the inclusion of `Kˢ` into the middle factor (rank `s`, image inside
`ker d₁`). -/
theorem realizable_ranks (K : Type) [Field K] (r s m : ℕ) :
    ∃ (A B C : Type) (_ : AddCommGroup A) (_ : Module K A) (_ : AddCommGroup B)
      (_ : Module K B) (_ : AddCommGroup C) (_ : Module K C) (_ : FiniteDimensional K B)
      (X : ChainCplx K A B C),
      Module.finrank K B = r + s + m
        ∧ Module.finrank K (LinearMap.range X.d1) = r
        ∧ Module.finrank K (LinearMap.range X.d2) = s
        ∧ X.numLogical = m := by
  classical
  -- middle space  B = Kʳ × (Kˢ × Kᵐ)
  set A := (Fin s → K)
  set C := (Fin r → K)
  set B := (Fin r → K) × ((Fin s → K) × (Fin m → K))
  set d1 : B →ₗ[K] C := LinearMap.fst K (Fin r → K) ((Fin s → K) × (Fin m → K)) with hd1def
  set d2 : A →ₗ[K] B :=
    (LinearMap.inr K (Fin r → K) ((Fin s → K) × (Fin m → K))).comp
      (LinearMap.inl K (Fin s → K) (Fin m → K)) with hd2def
  have hcomp : d1.comp d2 = 0 := by
    rw [hd1def, hd2def, ← LinearMap.comp_assoc, LinearMap.fst_comp_inr,
      LinearMap.zero_comp]
  refine ⟨A, B, C, inferInstance, inferInstance, inferInstance, inferInstance,
    inferInstance, inferInstance, inferInstance,
    { d2 := d2, d1 := d1, comp_eq_zero := hcomp }, ?_, ?_, ?_, ?_⟩
  · simp [B, Module.finrank_prod, Nat.add_assoc]
  · -- rank d1 = r : fst is surjective
    have hsurj : LinearMap.range d1 = ⊤ := by
      rw [LinearMap.range_eq_top]; intro y; exact ⟨(y, 0), rfl⟩
    show Module.finrank K (LinearMap.range d1) = r
    rw [hsurj]; simp [C]
  · -- rank d2 = s : d2 injective
    have hinj : Function.Injective d2 := by
      rw [hd2def]
      exact (LinearMap.inr_injective).comp (LinearMap.inl_injective)
    show Module.finrank K (LinearMap.range d2) = s
    rw [LinearMap.finrank_range_of_inj hinj]
    simp [A]
  · -- k = m by the dimension formula
    set X : ChainCplx K A B C := { d2 := d2, d1 := d1, comp_eq_zero := hcomp } with hX
    have hform := numLogical_add X
    have hr : Module.finrank K (LinearMap.range X.d1) = r := by
      have hsurj : LinearMap.range X.d1 = ⊤ := by
        rw [LinearMap.range_eq_top]; intro y; exact ⟨(y, 0), rfl⟩
      rw [hsurj]; simp [C]
    have hs : Module.finrank K (LinearMap.range X.d2) = s := by
      have hinj : Function.Injective X.d2 := by
        show Function.Injective d2
        rw [hd2def]
        exact (LinearMap.inr_injective).comp (LinearMap.inl_injective)
      rw [LinearMap.finrank_range_of_inj hinj]; simp [A]
    have hB : Module.finrank K B = r + s + m := by
      simp [B, Module.finrank_prod, Nat.add_assoc]
    rw [hr, hs, hB] at hform
    omega

/-- **Realizability (Conjecture 3), final form.**  For every field `K` and every
`k ≤ n` there is a length-two complex with physical dimension exactly `n` and
logical dimension exactly `k`; every `(n, k)` pair is realised. -/
theorem realizable_le (K : Type) [Field K] {k n : ℕ} (hk : k ≤ n) :
    ∃ (A B C : Type) (_ : AddCommGroup A) (_ : Module K A) (_ : AddCommGroup B)
      (_ : Module K B) (_ : AddCommGroup C) (_ : Module K C) (_ : FiniteDimensional K B)
      (X : ChainCplx K A B C),
      Module.finrank K B = n ∧ X.numLogical = k := by
  obtain ⟨A, B, C, iA, mA, iB, mB, iC, mC, fB, X, hB, hk'⟩ := realizable_pair K (n - k) k
  exact ⟨A, B, C, iA, mA, iB, mB, iC, mC, fB, X, by omega, hk'⟩

/-! ## Conjecture 2 : Euler characteristic as a code rate -/

/-- The zeroth homology `H⁰ = C / im d₁`; for a graph complex this is the number
of connected components `β₀`. -/
noncomputable def betti0 (X : ChainCplx K A B C) : ℕ :=
  Module.finrank K (C ⧸ LinearMap.range X.d1)

/-- **Euler identity.** `β₀ + dim B = dim(ker d₁) + dim C`. -/
theorem euler [FiniteDimensional K B] [FiniteDimensional K C] (X : ChainCplx K A B C) :
    X.betti0 + Module.finrank K B = Module.finrank K X.cycles + Module.finrank K C := by
  have hquot := Submodule.finrank_quotient_add_finrank (LinearMap.range X.d1)
  have hcyc := finrank_cycles_add_rank_d1 X
  simp only [betti0]
  omega

/-- For a graph complex (`d₂ = 0`) the logical space is the whole cycle space. -/
theorem numLogical_of_d2_eq_zero [FiniteDimensional K B]
    (X : ChainCplx K A B C) (h : X.d2 = 0) :
    X.numLogical = Module.finrank K X.cycles := by
  have := finrank_homology_add_boundaries X
  rw [h, LinearMap.range_zero] at this
  simpa using this

/-- **Graph HQECC count.** For a connected graph complex (`d₂ = 0`, `β₀ = 1`)
with `V = dim C` vertices and `E = dim B` edges, `k + V = E + 1`, i.e.
`k = E − V + 1` (the circuit rank). -/
theorem graph_count [FiniteDimensional K B] [FiniteDimensional K C]
    (X : ChainCplx K A B C) (hd2 : X.d2 = 0) (hconn : X.betti0 = 1) :
    X.numLogical + Module.finrank K C = Module.finrank K B + 1 := by
  have h1 := numLogical_of_d2_eq_zero X hd2
  have h2 := euler X
  rw [hconn] at h2
  omega

/-- **Code rate = `1 − (V−1)/E` (Conjecture 2).**  For a connected graph complex
with `V = dim C` vertices, `E = dim B > 0` edges, the rate `k/E` equals
`1 − (V−1)/E`. -/
theorem rate_eq [FiniteDimensional K B] [FiniteDimensional K C]
    (X : ChainCplx K A B C) (hd2 : X.d2 = 0) (hconn : X.betti0 = 1)
    (hE : 0 < Module.finrank K B) :
    (X.numLogical : ℚ) / (Module.finrank K B : ℚ)
      = 1 - ((Module.finrank K C : ℚ) - 1) / (Module.finrank K B : ℚ) := by
  have hcount := graph_count X hd2 hconn
  have hEne : (Module.finrank K B : ℚ) ≠ 0 := by
    have : (0 : ℚ) < (Module.finrank K B : ℚ) := by exact_mod_cast hE
    linarith
  have hcast : (X.numLogical : ℚ) + (Module.finrank K C : ℚ)
      = (Module.finrank K B : ℚ) + 1 := by exact_mod_cast hcount
  field_simp
  linarith [hcast]

/-- **Trees have rate `0` (Conjecture 2).**  A connected graph complex with
`E = V − 1` (a spanning tree) encodes no logical qubits. -/
theorem rate_tree [FiniteDimensional K B] [FiniteDimensional K C]
    (X : ChainCplx K A B C) (hd2 : X.d2 = 0) (hconn : X.betti0 = 1)
    (htree : Module.finrank K B + 1 = Module.finrank K C) :
    X.numLogical = 0 := by
  have hcount := graph_count X hd2 hconn
  omega

/-- **Bouquets have rate `1` (Conjecture 2).**  A connected graph complex on a
single vertex (`V = 1`, a bouquet of `E` loops) encodes `k = E` logical qubits,
i.e. rate `1`. -/
theorem rate_bouquet [FiniteDimensional K B] [FiniteDimensional K C]
    (X : ChainCplx K A B C) (hd2 : X.d2 = 0) (hconn : X.betti0 = 1)
    (hbouquet : Module.finrank K C = 1) :
    X.numLogical = Module.finrank K B := by
  have hcount := graph_count X hd2 hconn
  omega

end ChainCplx

/-! ## Examples and sanity checks -/

section Examples

open ChainCplx

/-- Realizability instance: a code on `5` physical qubits encoding `3` logical
qubits exists over `ℚ`. -/
example : ∃ (A B C : Type) (_ : AddCommGroup A) (_ : Module ℚ A) (_ : AddCommGroup B)
    (_ : Module ℚ B) (_ : AddCommGroup C) (_ : Module ℚ C) (_ : FiniteDimensional ℚ B)
    (X : ChainCplx ℚ A B C), Module.finrank ℚ B = 5 ∧ X.numLogical = 3 :=
  realizable_le ℚ (by norm_num)

#check @ChainCplx.numLogical_dual
#check @ChainCplx.realizable_le
#check @ChainCplx.rate_eq

end Examples

end HomQECC