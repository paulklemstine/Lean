import Shared.HQECC.HypercubeCounterexample

/-!
# The hypercube incidence complex over `𝔽₂`, and its homological code

This file carries out **future target 4** of the previous research cycle.  The
bridge theorem `HQECC.hypercube_HQECC_count` in
`Catalog/Shared/HQECC/HypercubeCounterexample.lean` is *parameterized* by the
dimension data (`dim B = n·2ⁿ⁻¹`, `dim C = 2ⁿ`), by connectedness
(`betti0 = 1`) and by the vanishing of the second differential.  Nothing in the
previous cycle exhibited an actual geometric object satisfying these hypotheses:
the counterexample to the "hypercube encodes one logical qubit" claim was
conditional on the existence of the complex.

Here we *construct* the complex.

* `Vert n = Fin n → ZMod 2`  — the `2ⁿ` vertices of the `n`-cube;
* `Edge n = Σ i : Fin n, {x : Vert n // x i = 0}` — the **oriented-free** edge
  set: an edge is a direction `i` together with its *lower* endpoint `x`
  (normalised by `x i = 0`), so each geometric edge is named exactly once and
  `#Edge n = n·2ⁿ⁻¹` (`card_Edge`);
* `incid n : Matrix (Vert n) (Edge n) (ZMod 2)` — the boundary matrix
  `∂₁`, with `∂₁ (x,i) = x + (x + eᵢ)`.

The mathematical heart of the file is

* `ker_transpose_incid` : `ker (∂₁ᵀ)` is the line of constant functions.  This
  is precisely the statement that the hypercube graph is **connected**, proved
  by an induction on the Hamming weight of a vertex (`const_of_flip`);
* `rank_incid_add_one` : `rank ∂₁ + 1 = 2ⁿ`, i.e. `rank ∂₁ = 2ⁿ − 1`, obtained
  from the previous item by rank–nullity and `Matrix.rank_transpose`.

These give an honest `CSSComplex` (`hyperComplex n`) whose `betti0` is *proved*
to be `1`, into which the parameterized bridge theorem is instantiated,
yielding the unconditional count

  `k(Qₙ) + 2ⁿ = n·2ⁿ⁻¹ + 1`,   i.e.   `k = 2ⁿ⁻¹(n−2) + 1`.

Finally (**future target 6**) we compare with the quantum Singleton bound using
the *correct block length* `N = n·2ⁿ⁻¹` — the number of physical edge qubits —
rather than the cube dimension `n`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  The conditional counterexample of the previous cycle
is vacuous unless the hypotheses `dim B = n·2ⁿ⁻¹`, `dim C = 2ⁿ`, `betti0 = 1`
are simultaneously realizable by a genuine incidence matrix over `𝔽₂`.  We
conjecture they are, and that connectivity of `Qₙ` is exactly the rank statement
`rank ∂₁ = 2ⁿ − 1`.

EXPERIMENT (Experimenter).  Normalising edges by their lower endpoint gives an
edge set of size `n·2ⁿ⁻¹` on the nose (`card_Edge`), with no double counting and
no need for orientations (char 2).  The transpose acts by
`(∂₁ᵀ f)(x,i) = f x + f (x + eᵢ)`, so `ker ∂₁ᵀ` consists of the functions
invariant under every coordinate flip; a Hamming-weight induction shows these
are the constants.  `Matrix.rank_transpose` transfers the rank back to `∂₁`.

ANALYSIS (Analyst).  Only `rank ∂₁ᵀ` is directly computable from geometry
(cocycles = locally constant functions); the primal rank needs the transpose
theorem, which is where the field hypothesis enters.  The zeroth Betti number is
then forced, so "connected ⟺ corank 1" is not an extra assumption but a theorem.

CRITIQUE (Critic).  Nothing here is `decide`-only: the two `decide` calls are on
closed statements about the two-element field.  `betti0 = 1` is proved, not
assumed; the final count is therefore unconditional in `n`.
-/

namespace HQECC
namespace HypercubeIncidence

open Matrix Module

/-! ## Vertices, edges, and the incidence matrix -/

/-- Vertices of the `n`-cube: bit-vectors of length `n`. -/
abbrev Vert (n : ℕ) := Fin n → ZMod 2

/-- Edges of the `n`-cube: a direction `i` together with the *lower* endpoint
`x` (normalised by `x i = 0`).  The edge `⟨i, x⟩` joins `x` to `x + eᵢ`. -/
abbrev Edge (n : ℕ) := Σ i : Fin n, {x : Vert n // x i = 0}

/-- The `i`-th standard basis bit-vector. -/
def bit {n : ℕ} (i : Fin n) : Vert n := fun j => if j = i then 1 else 0

lemma zmod2_cases (a : ZMod 2) : a = 0 ∨ a = 1 := by revert a; decide

lemma zmod2_add_eq_zero (a b : ZMod 2) : a + b = 0 ↔ a = b := by revert a b; decide

lemma bit_add_bit {n : ℕ} (i : Fin n) (x : Vert n) : x + bit i + bit i = x := by
  have h : bit i + bit i = 0 := by
    ext j; simp only [Pi.add_apply, Pi.zero_apply, bit]; split <;> decide
  rw [add_assoc, h, add_zero]

/-- Slicing off the `i`-th coordinate identifies the lower endpoints in
direction `i` with bit-vectors of length `n − 1`. -/
def slice (n : ℕ) (i : Fin n) : {x : Vert n // x i = 0} ≃ ({j : Fin n // j ≠ i} → ZMod 2) where
  toFun x := fun j => x.1 j
  invFun g := ⟨fun j => if h : j = i then 0 else g ⟨j, h⟩, by simp⟩
  left_inv := by rintro ⟨x, hx⟩; ext j; by_cases h : j = i <;> simp [h, hx]
  right_inv := by intro g; ext ⟨j, hj⟩; simp [hj]

/-- The `n`-cube has `2ⁿ` vertices. -/
lemma card_Vert (n : ℕ) : Fintype.card (Vert n) = 2 ^ n := by simp

/-- The `n`-cube has `n·2ⁿ⁻¹` edges. -/
lemma card_Edge (n : ℕ) : Fintype.card (Edge n) = n * 2 ^ (n - 1) := by
  rw [Fintype.card_sigma]
  have h : ∀ i : Fin n, Fintype.card {x : Vert n // x i = 0} = 2 ^ (n - 1) := by
    intro i
    rw [Fintype.card_congr (slice n i)]
    simp [Fintype.card_subtype_compl]
  simp [h]

/-- The boundary matrix `∂₁ : 𝔽₂^E → 𝔽₂^V` of the `n`-cube graph: the column of
the edge `⟨i, x⟩` is the indicator of its two endpoints `x` and `x + eᵢ`. -/
def incid (n : ℕ) : Matrix (Vert n) (Edge n) (ZMod 2) :=
  fun v e => (if v = e.2.1 then 1 else 0) + (if v = (e.2.1 : Vert n) + bit e.1 then 1 else 0)

/-- The coboundary `∂₁ᵀ` is the discrete derivative: it sends a vertex function
`f` to the edge function `⟨i,x⟩ ↦ f x + f (x + eᵢ)`. -/
lemma incid_transpose_mulVec (n : ℕ) (f : Vert n → ZMod 2) (e : Edge n) :
    ((incid n)ᵀ.mulVec f) e = f e.2.1 + f ((e.2.1 : Vert n) + bit e.1) := by
  simp only [Matrix.mulVec, Matrix.transpose_apply, dotProduct, incid, add_mul, one_mul, zero_mul,
    ite_mul, Finset.sum_add_distrib, Finset.sum_ite_eq', Finset.mem_univ, if_true]

/-! ## Connectivity: the kernel of the coboundary is the line of constants -/

/-- Invariance under flipping a coordinate that is `0` upgrades to invariance
under flipping *any* coordinate. -/
lemma flip_all {n : ℕ} (f : Vert n → ZMod 2)
    (h : ∀ (i : Fin n) (x : Vert n), x i = 0 → f x = f (x + bit i)) :
    ∀ (i : Fin n) (x : Vert n), f x = f (x + bit i) := by
  intro i x
  rcases zmod2_cases (x i) with h0 | h1
  · exact h i x h0
  · have hy : (x + bit i) i = 0 := by simp only [Pi.add_apply, bit, h1]; decide
    have hx := h i (x + bit i) hy
    rw [bit_add_bit] at hx
    exact hx.symm

/-- **Connectivity of `Qₙ`.**  A function invariant under every coordinate flip
is constant.  The proof is an induction on the Hamming weight. -/
lemma const_of_flip {n : ℕ} (f : Vert n → ZMod 2)
    (h : ∀ (i : Fin n) (x : Vert n), f x = f (x + bit i)) : ∀ x, f x = f 0 := by
  intro x
  generalize hc : (Finset.univ.filter (fun j => x j ≠ 0)).card = c
  induction c using Nat.strong_induction_on generalizing x with
  | _ c ih =>
    rcases Finset.eq_empty_or_nonempty (Finset.univ.filter (fun j => x j ≠ 0)) with he | ⟨i, hi⟩
    · have hx0 : x = 0 := by
        ext j
        by_contra hj
        have hmem : j ∈ Finset.univ.filter (fun j => x j ≠ 0) :=
          Finset.mem_filter.2 ⟨Finset.mem_univ j, by simpa using hj⟩
        rw [he] at hmem
        exact absurd hmem (Finset.notMem_empty j)
      rw [hx0]
    · have hxi : x i ≠ 0 := (Finset.mem_filter.1 hi).2
      have hfilter : (Finset.univ.filter (fun j => (x + bit i) j ≠ 0)) =
          (Finset.univ.filter (fun j => x j ≠ 0)).erase i := by
        ext j
        by_cases hj : j = i
        · subst hj
          simp only [Pi.add_apply, bit, Finset.mem_filter, Finset.mem_univ, true_and,
            Finset.mem_erase, ne_eq, not_true_eq_false, false_and, iff_false, not_not]
          rcases zmod2_cases (x j) with h0 | h1
          · exact absurd h0 hxi
          · rw [h1]; decide
        · simp [bit, hj, Finset.mem_erase]
      have hlt : (Finset.univ.filter (fun j => (x + bit i) j ≠ 0)).card < c := by
        rw [hfilter, Finset.card_erase_of_mem hi, ← hc]
        have : 0 < (Finset.univ.filter (fun j => x j ≠ 0)).card := Finset.card_pos.2 ⟨i, hi⟩
        omega
      have heq := ih _ hlt (x + bit i) rfl
      rw [← heq, ← h i x]

/-- **The cocycle space is one-dimensional.**  `ker ∂₁ᵀ = 𝔽₂ · 1`. -/
theorem ker_transpose_incid (n : ℕ) :
    LinearMap.ker ((incid n)ᵀ.mulVecLin) =
      Submodule.span (ZMod 2) {(1 : Vert n → ZMod 2)} := by
  apply le_antisymm
  · intro f hf
    have hf' : ∀ e : Edge n, f e.2.1 + f ((e.2.1 : Vert n) + bit e.1) = 0 := by
      intro e
      have h0 := congrFun (LinearMap.mem_ker.1 hf) e
      rw [Matrix.mulVecLin_apply, incid_transpose_mulVec] at h0
      simpa using h0
    have hstep : ∀ (i : Fin n) (x : Vert n), x i = 0 → f x = f (x + bit i) := fun i x hx =>
      (zmod2_add_eq_zero _ _).1 (hf' ⟨i, ⟨x, hx⟩⟩)
    have hc := const_of_flip f (flip_all f hstep)
    have hsm : f = (f 0) • (1 : Vert n → ZMod 2) := by ext x; simp [hc x]
    rw [hsm]
    exact Submodule.smul_mem _ _ (Submodule.mem_span_singleton_self _)
  · rw [Submodule.span_le]
    rintro g rfl
    simp only [SetLike.mem_coe, LinearMap.mem_ker]
    ext e
    rw [Matrix.mulVecLin_apply, incid_transpose_mulVec]
    simp only [Pi.one_apply, Pi.zero_apply]
    exact CharTwo.add_self_eq_zero 1

/-- **Rank of the hypercube boundary matrix.**  `rank ∂₁ = 2ⁿ − 1`, stated
additively to avoid truncated subtraction. -/
theorem rank_incid_add_one (n : ℕ) : (incid n).rank + 1 = 2 ^ n := by
  have hker : finrank (ZMod 2) (LinearMap.ker ((incid n)ᵀ.mulVecLin)) = 1 := by
    rw [ker_transpose_incid n]
    apply finrank_span_singleton
    intro h
    have h0 := congrFun h (0 : Vert n)
    simp at h0
  have hrn := LinearMap.finrank_range_add_finrank_ker ((incid n)ᵀ.mulVecLin)
  rw [hker, Module.finrank_fintype_fun_eq_card, card_Vert] at hrn
  have hT : (incid n)ᵀ.rank = (incid n).rank := Matrix.rank_transpose _
  rw [← hT]
  exact hrn

/-! ## The hypercube CSS complex, and the instantiated bridge theorem -/

/-- The homological code of the `n`-cube graph as a genuine `CSSComplex`:
`𝔽₂ --0--> 𝔽₂^E --∂₁--> 𝔽₂^V` (a graph has no `2`-cells, so `d₂ = 0`). -/
noncomputable def hyperComplex (n : ℕ) :
    CSSComplex (ZMod 2) (ZMod 2) (Edge n → ZMod 2) (Vert n → ZMod 2) where
  d2 := 0
  d1 := (incid n).mulVecLin
  comp_eq_zero := by simp

@[simp] lemma hyperComplex_d2 (n : ℕ) : (hyperComplex n).d2 = 0 := rfl

lemma finrank_range_d1 (n : ℕ) :
    finrank (ZMod 2) (LinearMap.range (hyperComplex n).d1) + 1 = 2 ^ n :=
  rank_incid_add_one n

/-- **`Qₙ` is connected**, homologically: `β₀ = 1`. -/
theorem betti0_hyperComplex (n : ℕ) : (hyperComplex n).betti0 = 1 := by
  have hq := Submodule.finrank_quotient_add_finrank
    (LinearMap.range (hyperComplex n).d1)
  rw [Module.finrank_fintype_fun_eq_card, card_Vert] at hq
  have hr := finrank_range_d1 n
  have hb : (hyperComplex n).betti0 =
      finrank (ZMod 2) ((Vert n → ZMod 2) ⧸ LinearMap.range (hyperComplex n).d1) := rfl
  rw [hb]
  omega

lemma finrank_edges (n : ℕ) :
    finrank (ZMod 2) (Edge n → ZMod 2) = n * 2 ^ (n - 1) := by
  rw [Module.finrank_fintype_fun_eq_card, card_Edge]

lemma finrank_verts (n : ℕ) : finrank (ZMod 2) (Vert n → ZMod 2) = 2 ^ n := by
  rw [Module.finrank_fintype_fun_eq_card, card_Vert]

/-- **Target 4, achieved.**  The parameterized bridge theorem
`HQECC.hypercube_HQECC_count` instantiated at the *actual* hypercube incidence
complex: the number of logical qubits satisfies `k + 2ⁿ = n·2ⁿ⁻¹ + 1`. -/
theorem hyperComplex_numLogical_add (n : ℕ) :
    (hyperComplex n).numLogical + 2 ^ n = n * 2 ^ (n - 1) + 1 :=
  hypercube_HQECC_count (hyperComplex n) rfl (betti0_hyperComplex n) n
    (finrank_edges n) (finrank_verts n)

/-- The closed form `k = 2ⁿ⁻¹(n − 2) + 1`, in `ℤ` to avoid truncation. -/
theorem hyperComplex_numLogical_closed (n : ℕ) (hn : 1 ≤ n) :
    ((hyperComplex n).numLogical : ℤ) = 2 ^ (n - 1) * ((n : ℤ) - 2) + 1 := by
  have h := hyperComplex_numLogical_add n
  have hpowZ : (2 : ℤ) ^ n = 2 * 2 ^ (n - 1) := by
    conv_lhs => rw [show n = (n - 1) + 1 by omega]
    rw [pow_succ]; ring
  have hZ : ((hyperComplex n).numLogical : ℤ) + 2 ^ n = (n : ℤ) * 2 ^ (n - 1) + 1 := by
    exact_mod_cast h
  rw [hpowZ] at hZ
  linarith

/-- **The "one logical qubit" claim is false for the real hypercube complex**:
for `n ≥ 3` the code encodes at least five logical qubits.  Unlike the previous
cycle's conditional statement, this is about a constructed object. -/
theorem hyperComplex_numLogical_ge_five (n : ℕ) (hn : 3 ≤ n) :
    5 ≤ (hyperComplex n).numLogical :=
  hypercube_HQECC_not_one (hyperComplex n) rfl (betti0_hyperComplex n) n hn
    (finrank_edges n) (finrank_verts n)

/-- The one-logical-qubit law holds exactly at `n = 2` (the `4`-cycle). -/
theorem hyperComplex_numLogical_eq_one_iff (n : ℕ) (hn : 1 ≤ n) :
    (hyperComplex n).numLogical = 1 ↔ n = 2 := by
  constructor
  · intro hk
    by_contra hne
    rcases (by omega : n = 1 ∨ 3 ≤ n) with h1 | h3
    · subst h1
      have h := hyperComplex_numLogical_add 1
      norm_num at h
      omega
    · have := hyperComplex_numLogical_ge_five n h3
      omega
  · rintro rfl
    have h := hyperComplex_numLogical_add 2
    norm_num at h
    omega

/-! ## Target 6: the quantum Singleton bound with the correct block length -/

/-- The number of **physical qubits** of the hypercube code is the number of
edges `N = n·2ⁿ⁻¹`, not the cube dimension `n`. -/
def blockLength (n : ℕ) : ℕ := n * 2 ^ (n - 1)

/-- **Quantum Singleton comparison, correct block length.**  With `N = n·2ⁿ⁻¹`
physical qubits and any distance `d ≤ 4` (the graph girth of `Qₙ` bounds the
primal logical weight), the hypercube code satisfies the quantum Singleton
inequality `k + 2(d − 1) ≤ N` for every `n ≥ 3` — with slack `2ⁿ − 2d + 1`.
Note that reading `n` itself as a block length would make the inequality
meaningless, since `k` already exceeds `n` for `n ≥ 3`. -/
theorem hyperComplex_singleton (n d : ℕ) (hn : 3 ≤ n) (hd : d ≤ 4) :
    (hyperComplex n).numLogical + 2 * (d - 1) ≤ blockLength n := by
  have h := hyperComplex_numLogical_add n
  have h8 : 8 ≤ 2 ^ n := by
    calc (8 : ℕ) = 2 ^ 3 := by norm_num
    _ ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
  unfold blockLength
  omega

/-- The Singleton slack is *not* tight: the hypercube code is far from a
quantum MDS code, since `N − k = 2ⁿ − 1` grows exponentially while
`2(d − 1) ≤ 6`. -/
theorem hyperComplex_singleton_slack (n : ℕ) :
    (hyperComplex n).numLogical + 2 ^ n - 1 = blockLength n := by
  have h := hyperComplex_numLogical_add n
  unfold blockLength
  omega

/-! ## Sanity checks -/

section Examples

#check @hyperComplex_numLogical_add
#eval (List.range 9).map (fun n => (n, n * 2 ^ (n - 1) + 1 - 2 ^ n))  -- k for n = 0..8

/-- `Q₄` : `N = 32` physical qubits, `k = 17` logical qubits. -/
example : (hyperComplex 4).numLogical = 17 := by
  have h := hyperComplex_numLogical_add 4
  norm_num at h
  omega

/-- `Q₆` : `N = 192` physical qubits, `k = 129` logical qubits. -/
example : (hyperComplex 6).numLogical = 129 := by
  have h := hyperComplex_numLogical_add 6
  norm_num at h
  omega

end Examples

end HypercubeIncidence
end HQECC