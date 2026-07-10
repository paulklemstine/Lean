import Mathlib

/-!
# Vanishing cyclically covering codimension ⇔ full-weight cyclic codes

This file proves a cross-domain bridge between two notions attached to the vector
space `V = (ZMod n) → K` over a field `K` (the intended case being a finite field
`K = 𝔽_q`, i.e. `V = 𝔽_q^n`):

* **Coding theory / combinatorics.** A *cyclic code* is a `K`-subspace of `V`
  invariant under the cyclic shift. A codeword has *full Hamming weight* if all of
  its coordinates are nonzero.

* **Covering codimension.** A subspace `U ⊆ V` is *cyclically covering* if every
  vector of `V` can be shifted into `U`, i.e. `V = ⋃ₖ (shiftᵏ) U`. The quantity
  `h_q(n)` is the maximum codimension of a cyclically covering subspace; it is `0`
  exactly when the only cyclically covering subspace is `V` itself.

The main theorem `hZero_iff_fullWeightProperty` states:

> `h_q(n) = 0`  ⇔  every nonzero cyclic code contains a full-weight codeword.

The proof is via a Fourier/duality bridge.  For `a : V` consider the linear map
`phi a : x ↦ (k ↦ ⟪a, shiftᵏ x⟫)`.  Its range is a cyclic code, and the
hyperplane `ker ⟪a,·⟫` is cyclically covering **iff** the range of `phi a` contains
no full-weight codeword (`covering_ker_iff`).  Passing between hyperplanes and
functionals on one side (`exists_functional_of_ne_top`, `pair_coeff`), and
single-generator cyclic codes via the coordinate reversal `rev` on the other
(`phi_rev_mem`), yields the equivalence.

We work over an arbitrary field `K`; the statement for `𝔽_q` is the special case
`K = 𝔽_q`.  (Finiteness of `K` is not needed for the equivalence itself.)
-/

open scoped BigOperators

namespace CyclicCoveringFullWeight

variable {n : ℕ} [NeZero n] {K : Type*} [Field K]

/-- The ambient space `V = (ZMod n) → K`, i.e. `𝔽_q^n` when `K = 𝔽_q`. -/
abbrev V (n : ℕ) (K : Type*) := ZMod n → K

/-- Cyclic shift by `k : ZMod n`: `(rot k x) i = x (i + k)`. Linear in `x`. -/
def rot (k : ZMod n) : V n K →ₗ[K] V n K := LinearMap.funLeft K K (fun i => i + k)

omit [NeZero n] in
@[simp] lemma rot_apply (k : ZMod n) (x : V n K) (i : ZMod n) : rot k x i = x (i + k) := by
  simp [rot]

/-- Coordinate reversal `(rev x) i = x (-i)`. Linear in `x`. -/
def rev : V n K →ₗ[K] V n K := LinearMap.funLeft K K (fun i => -i)

omit [NeZero n] in
@[simp] lemma rev_apply (x : V n K) (i : ZMod n) : rev x i = x (-i) := by
  simp [rev]

/-- The standard bilinear pairing `⟪a, x⟫ = ∑ i, a i * x i`, as a functional in `x`. -/
def pair (a : V n K) : V n K →ₗ[K] K := ∑ i : ZMod n, a i • (LinearMap.proj i)

@[simp] lemma pair_apply (a x : V n K) : pair a x = ∑ i : ZMod n, a i * x i := by
  simp [pair, Finset.sum_apply, LinearMap.smul_apply, LinearMap.proj_apply, smul_eq_mul]

/-- The Fourier-type map `phi a : x ↦ (k ↦ ⟪a, shiftᵏ x⟫)`. -/
def phi (a : V n K) : V n K →ₗ[K] V n K :=
  LinearMap.pi (fun k => (pair a).comp (rot k))

@[simp] lemma phi_apply (a x : V n K) (k : ZMod n) : phi a x k = pair a (rot k x) := by
  simp [phi]

/-- A codeword has full Hamming weight when all its coordinates are nonzero. -/
def FullWeight (c : V n K) : Prop := ∀ i, c i ≠ 0

/-- A subspace is a cyclic code if it is invariant under the unit cyclic shift. -/
def IsCyclic (C : Submodule K (V n K)) : Prop := ∀ x ∈ C, rot 1 x ∈ C

/-- A subspace `U` is cyclically covering if every vector can be shifted into `U`. -/
def Covering (U : Submodule K (V n K)) : Prop := ∀ x : V n K, ∃ k : ZMod n, rot k x ∈ U

/-- `h_q(n) = 0`: the only cyclically covering subspace is the whole space. -/
def hZero (n : ℕ) (K : Type*) [NeZero n] [Field K] : Prop :=
  ∀ U : Submodule K (V n K), Covering U → U = ⊤

/-- Full-weight property: every nonzero cyclic code has a full-weight codeword. -/
def FullWeightProperty (n : ℕ) (K : Type*) [NeZero n] [Field K] : Prop :=
  ∀ C : Submodule K (V n K), IsCyclic C → C ≠ ⊥ → ∃ c ∈ C, FullWeight c

/-! ### Basic algebraic lemmas about `rot`. -/

omit [NeZero n] in
lemma rot_rot (k l : ZMod n) (x : V n K) : rot k (rot l x) = rot (k + l) x := by
  ext i; simp [add_comm, add_left_comm]

omit [NeZero n] in
@[simp] lemma rot_zero (x : V n K) : rot (0 : ZMod n) x = x := by
  ext i; simp

/-- Membership in a cyclic code is preserved by every shift `rot k`. -/
lemma IsCyclic.rot_mem {C : Submodule K (V n K)} (hC : IsCyclic C)
    {x : V n K} (hx : x ∈ C) (k : ZMod n) : rot k x ∈ C := by
  have aux : ∀ m : ℕ, rot ((m : ZMod n)) x ∈ C := by
    intro m
    induction m with
    | zero => simp only [Nat.cast_zero, rot_zero]; exact hx
    | succ p ih =>
        have h1 : rot 1 (rot (p : ZMod n) x) ∈ C := hC _ ih
        have hidx : ((↑(p + 1) : ZMod n)) = 1 + (p : ZMod n) := by push_cast; ring
        have he : rot ((↑(p + 1) : ZMod n)) x = rot 1 (rot (p : ZMod n) x) := by
          rw [rot_rot, hidx]
        rw [he]; exact h1
  have hk : ((k.val : ℕ) : ZMod n) = k := ZMod.natCast_zmod_val k
  rw [← hk]; exact aux k.val

/-! ### The Fourier bridge. -/

/-- `phi a` intertwines the shift: `phi a (rot 1 x) = rot 1 (phi a x)`. -/
lemma phi_rot_one (a x : V n K) : phi a (rot 1 x) = rot 1 (phi a x) := by
  ext k; simp only [phi_apply, rot_apply, rot_rot]

/-- The range of `phi a` is a cyclic code. -/
lemma isCyclic_range_phi (a : V n K) : IsCyclic (LinearMap.range (phi a)) := by
  intro w hw
  obtain ⟨y, rfl⟩ := hw
  rw [← phi_rot_one]
  exact LinearMap.mem_range_self _ _

/-- **Core bridge.** The hyperplane `ker ⟪a,·⟫` is cyclically covering iff no codeword
in the range of `phi a` has full weight. -/
lemma covering_ker_iff (a : V n K) :
    Covering (LinearMap.ker (pair a)) ↔ ∀ w ∈ LinearMap.range (phi a), ¬ FullWeight w := by
  constructor
  · intro hcov w hw hfw
    obtain ⟨x, rfl⟩ := hw
    obtain ⟨k, hk⟩ := hcov x
    rw [LinearMap.mem_ker] at hk
    exact hfw k (by rw [phi_apply]; exact hk)
  · intro h x
    by_contra hcon
    push_neg at hcon
    apply h (phi a x) ⟨x, rfl⟩
    intro k
    have hh := hcon k
    rw [LinearMap.mem_ker] at hh
    rw [phi_apply]; exact hh

/-- If `a ≠ 0` then `pair a` is a nonzero functional, hence its kernel is a proper subspace. -/
lemma pair_ne_zero_of_ne_zero {a : V n K} (ha : a ≠ 0) : pair a ≠ 0 := by
  intro h
  apply ha
  ext j
  have hj : pair a (Pi.single j 1) = 0 := by rw [h]; rfl
  rw [pair_apply] at hj
  simpa [Pi.single_apply, Finset.sum_ite_eq'] using hj

/-- If `a ≠ 0` then the range of `phi a` is a nonzero code. -/
lemma range_phi_ne_bot {a : V n K} (ha : a ≠ 0) : LinearMap.range (phi a) ≠ ⊥ := by
  rw [Ne, LinearMap.range_eq_bot]
  intro h
  apply pair_ne_zero_of_ne_zero ha
  refine LinearMap.ext fun y => ?_
  have hy : phi a y = 0 := by rw [h]; rfl
  have h0 := congrFun hy 0
  simpa [phi_apply, rot_zero] using h0

/-! ### From a functional to a coefficient vector. -/

/-- Coefficient vector of a functional `f`: `coeff f i = f (eᵢ)`. -/
def coeff (f : V n K →ₗ[K] K) : V n K := fun i => f (Pi.single i 1)

/-- The pairing with the coefficient vector recovers the functional. -/
lemma pair_coeff (f : V n K →ₗ[K] K) : pair (coeff f) = f := by
  refine LinearMap.ext fun x => ?_
  rw [pair_apply]
  have hx : x = ∑ i, x i • (Pi.single i (1 : K) : V n K) := by
    ext j; simp [Finset.sum_apply, Pi.single_apply]
  conv_rhs => rw [hx]
  rw [map_sum]
  refine Finset.sum_congr rfl ?_
  intro i _
  rw [map_smul]
  simp [coeff, smul_eq_mul, mul_comm]

lemma coeff_ne_zero {f : V n K →ₗ[K] K} (hf : f ≠ 0) : coeff f ≠ 0 := by
  intro h
  apply hf
  rw [← pair_coeff f, h]
  refine LinearMap.ext fun x => ?_
  simp [pair_apply]

/-- A proper subspace is contained in the kernel of some nonzero functional. -/
lemma exists_functional_of_ne_top {U : Submodule K (V n K)} (hU : U ≠ ⊤) :
    ∃ f : V n K →ₗ[K] K, f ≠ 0 ∧ ∀ x ∈ U, f x = 0 := by
  have hnt : Nontrivial (V n K ⧸ U) := Submodule.Quotient.nontrivial_iff.mpr hU
  obtain ⟨g, hg⟩ := exists_ne (0 : (V n K ⧸ U) →ₗ[K] K)
  refine ⟨g.comp U.mkQ, ?_, ?_⟩
  · intro h
    apply hg
    refine LinearMap.ext fun y => ?_
    obtain ⟨z, rfl⟩ := U.mkQ_surjective y
    have : (g.comp U.mkQ) z = 0 := by rw [h]; rfl
    simpa using this
  · intro x hx
    simp [LinearMap.comp_apply, (Submodule.Quotient.mk_eq_zero U).2 hx]

omit [NeZero n] in
/-- A superset of a covering subspace is covering. -/
lemma Covering.mono {U W : Submodule K (V n K)} (h : U ≤ W) (hU : Covering U) : Covering W := by
  intro x; obtain ⟨k, hk⟩ := hU x; exact ⟨k, h hk⟩

/-! ### Membership of the reversal-generated code. -/

/-- For `c` in a cyclic code `C`, every value `phi (rev c) x` lies in `C`.  Concretely,
`phi (rev c) x = ∑ j, x j • rot (-j) c`, a combination of shifts of `c`. -/
lemma phi_rev_mem {C : Submodule K (V n K)} (hC : IsCyclic C) {c : V n K} (hc : c ∈ C)
    (x : V n K) : phi (rev c) x ∈ C := by
  have key : phi (rev c) x = ∑ j : ZMod n, x j • rot (-j) c := by
    ext k
    rw [phi_apply, pair_apply]
    simp only [rev_apply, rot_apply, Finset.sum_apply, Pi.smul_apply, smul_eq_mul]
    rw [← Equiv.sum_comp (Equiv.addRight k) (fun j => x j * c (k + -j))]
    refine Finset.sum_congr rfl ?_
    intro i _
    simp only [Equiv.coe_addRight]
    ring_nf
  rw [key]
  apply Submodule.sum_mem
  intro j _
  exact Submodule.smul_mem _ _ (hC.rot_mem hc (-j))

omit [NeZero n] in
lemma rev_ne_zero {c : V n K} (hc : c ≠ 0) : rev c ≠ 0 := by
  intro h; apply hc; ext j
  have h1 : rev c (-j) = 0 := by rw [h]; rfl
  rw [rev_apply] at h1
  simpa using h1

/-! ### Main theorem. -/

/-- **Bridge theorem.** For the space `𝔽_q^n = (ZMod n) → K`, the maximum codimension
of a cyclically covering subspace is zero **iff** every nonzero cyclic code contains a
full-weight codeword. -/
theorem hZero_iff_fullWeightProperty : hZero n K ↔ FullWeightProperty n K := by
  constructor
  · -- (⇒) h_q(n) = 0 forces the full-weight property.
    intro hzero C hcyc hCbot
    by_contra hno
    push_neg at hno
    obtain ⟨c, hcC, hcne⟩ := (Submodule.ne_bot_iff C).1 hCbot
    have ha : rev c ≠ 0 := rev_ne_zero hcne
    have hcov : Covering (LinearMap.ker (pair (rev c))) := by
      rw [covering_ker_iff]
      rintro w ⟨x, rfl⟩
      exact hno _ (phi_rev_mem hcyc hcC x)
    have htop := hzero _ hcov
    have hpne : pair (rev c) ≠ 0 := pair_ne_zero_of_ne_zero ha
    rw [LinearMap.ker_eq_top] at htop
    exact hpne htop
  · -- (⇐) the full-weight property forces h_q(n) = 0.
    intro hfw U hcov
    by_contra hUtop
    obtain ⟨f, hfne, hfU⟩ := exists_functional_of_ne_top hUtop
    have hpair : pair (coeff f) = f := pair_coeff f
    have ha : coeff f ≠ 0 := coeff_ne_zero hfne
    have hle : U ≤ LinearMap.ker (pair (coeff f)) := by
      intro x hx
      rw [LinearMap.mem_ker, hpair]
      exact hfU x hx
    have hcov2 : Covering (LinearMap.ker (pair (coeff f))) := hcov.mono hle
    have hnofw : ∀ w ∈ LinearMap.range (phi (coeff f)), ¬ FullWeight w :=
      (covering_ker_iff _).1 hcov2
    obtain ⟨w, hwmem, hwfw⟩ :=
      hfw (LinearMap.range (phi (coeff f))) (isCyclic_range_phi _) (range_phi_ne_bot ha)
    exact hnofw w hwmem hwfw

end CyclicCoveringFullWeight