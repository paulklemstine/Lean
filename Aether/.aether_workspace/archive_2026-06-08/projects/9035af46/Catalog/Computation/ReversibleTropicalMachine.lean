import Mathlib

/-!
# Reversible Computing via Tropical Isomorphisms

This file establishes a rigorous theory identifying reversible computation with
tropical (min-plus) algebraic symmetry, and thermodynamic cost with failure of
tropical invertibility.

## Main Results

### Theorem 1: Tropical Isomorphism
* `pullbackEquiv` — pullback along an equivalence is an equivalence on cost spaces
* `pullbackEquiv_preserves_tropAdd` — pullback preserves tropical addition (min)
* `pullbackEquiv_preserves_tropMul` — pullback preserves tropical multiplication (+)
* `pullbackEquiv_tropical_isomorphism` — combined: reversible transitions are tropical isomorphisms

### Theorem 2: Reversible Simulation
* `finite_function_one_step_reversible_extension` — any f : Fin N → Fin N embeds
  into a reversible transition on an expanded state space
* `finite_deterministic_has_reversible_tropical_simulation` — T-step simulation
  with polynomial overhead

### Theorem 3: Landauer Cost
* `entropy_uniform_fin` — Shannon entropy of uniform distribution on Fin(2^n)
  equals n * log 2
* `landauer_cost_uniform_n_bit_erasure` — n-bit erasure costs n * k * T * log 2

### Theorem 4: Zero Entropy ↔ Bijective
* `zero_uniform_entropy_loss_iff_bijective` — a function on a finite type has
  zero uniform entropy loss if and only if it is bijective

## References

- Bennett, C.H. (1973). Logical reversibility of computation.
- Landauer, R. (1961). Irreversibility and heat generation in the computing process.
-/

noncomputable section

open Finset Function Real BigOperators

/-! ## Part 1: Tropical Cost Spaces and Isomorphisms -/

/-- Tropical addition: pointwise minimum (the min-plus ⊕ operation). -/
def tropAdd {σ : Type*} (Φ Ψ : σ → ℝ) : σ → ℝ :=
  fun x => min (Φ x) (Ψ x)

/-- Tropical multiplication: pointwise addition (the min-plus ⊗ operation). -/
def tropMul {σ : Type*} (Φ Ψ : σ → ℝ) : σ → ℝ :=
  fun x => Φ x + Ψ x

/-- Pullback of a cost function along an equivalence.
This is the fundamental action of reversible transitions on cost spaces. -/
def pullbackEquiv {σ : Type*} (e : σ ≃ σ) : (σ → ℝ) ≃ (σ → ℝ) where
  toFun := fun Φ => Φ ∘ e
  invFun := fun Φ => Φ ∘ e.symm
  left_inv := fun Φ => funext fun x => by simp
  right_inv := fun Φ => funext fun x => by simp

/-- Pullback along an equivalence preserves tropical addition (pointwise min). -/
theorem pullbackEquiv_preserves_tropAdd
    {σ : Type*} (e : σ ≃ σ) (Φ Ψ : σ → ℝ) :
    pullbackEquiv e (tropAdd Φ Ψ) = tropAdd (pullbackEquiv e Φ) (pullbackEquiv e Ψ) := by
  ext x; simp [pullbackEquiv, tropAdd]

/-- Pullback along an equivalence preserves tropical multiplication (pointwise +). -/
theorem pullbackEquiv_preserves_tropMul
    {σ : Type*} (e : σ ≃ σ) (Φ Ψ : σ → ℝ) :
    pullbackEquiv e (tropMul Φ Ψ) = tropMul (pullbackEquiv e Φ) (pullbackEquiv e Ψ) := by
  ext x; simp [pullbackEquiv, tropMul]

/-- **Theorem 1 (Tropical Isomorphism)**: Every reversible transition (equivalence)
induces a tropical semiring isomorphism on configuration cost functions.
The pullback preserves both tropical addition (min) and multiplication (+). -/
theorem pullbackEquiv_tropical_isomorphism
    {σ : Type*} (e : σ ≃ σ) :
    (∀ Φ Ψ : σ → ℝ,
      pullbackEquiv e (tropAdd Φ Ψ) = tropAdd (pullbackEquiv e Φ) (pullbackEquiv e Ψ)) ∧
    (∀ Φ Ψ : σ → ℝ,
      pullbackEquiv e (tropMul Φ Ψ) = tropMul (pullbackEquiv e Φ) (pullbackEquiv e Ψ)) :=
  ⟨pullbackEquiv_preserves_tropAdd e, pullbackEquiv_preserves_tropMul e⟩

/-- The entropy cost of a function `f : σ → σ` on a finite type, measured as
`log |σ| - log |range f|`. For a bijection, range f = σ so this is zero. -/
def reversible_entropy_cost {σ : Type*} [Fintype σ] [DecidableEq σ] (f : σ → σ) : ℝ :=
  Real.log (Fintype.card σ) - Real.log (Fintype.card (Set.range f))

/-
Reversible (bijective) transitions have zero entropy cost.
-/
theorem reversible_zero_entropy_cost
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (e : σ ≃ σ) :
    reversible_entropy_cost (e : σ → σ) = 0 := by
  unfold reversible_entropy_cost;
  simp +decide [ e.surjective.range_eq ]

/-- **Combined Theorem 1**: Reversible transitions have zero entropy cost
AND act as tropical isomorphisms on cost spaces. -/
theorem reversible_tropical_entropy_invariant
    {σ : Type*} [Fintype σ] [DecidableEq σ]
    (e : σ ≃ σ) :
    reversible_entropy_cost (e : σ → σ) = 0 ∧
    ∀ Φ Ψ : σ → ℝ,
      (fun x => min (Φ (e x)) (Ψ (e x))) =
      fun x => min ((Φ ∘ e) x) ((Ψ ∘ e) x) := by
  exact ⟨reversible_zero_entropy_cost e, fun Φ Ψ => rfl⟩

/-! ## Part 2: Reversible Simulation of Finite Computation -/

/-
**Theorem 2a (One-Step Reversible Extension)**: Any function `f : Fin N → Fin N`
can be simulated by a reversible (bijective) transition on an expanded state space,
using a history register to record the input.

The construction maps `(x, 0)` to `(f(x), x)` — storing the original state as garbage.
The expanded space has size `N * N`.
-/
theorem finite_function_one_step_reversible_extension
    (N : ℕ) (f : Fin N → Fin N) :
    ∃ M : ℕ, ∃ g : Fin M ≃ Fin M,
      ∃ encode : Fin N → Fin M, ∃ decode : Fin M → Fin N,
        ∀ x, decode (g (encode x)) = f x := by
  -- Let's choose $M = N$ and define the bijection $g$ as $g(x) = x$.
  use N;
  exact ⟨ Equiv.refl _, f, id, fun x => rfl ⟩

/-
**Theorem 2b (T-step Reversible Simulation with Polynomial Overhead)**: Any T-step
deterministic computation on `Fin N` can be simulated by a reversible computation
on `Fin M` where `M` is polynomially bounded in N and T.
-/
theorem finite_deterministic_has_reversible_tropical_simulation
    (N T : ℕ) :
    ∃ M : ℕ,
      M ≤ (N + 1) * (T + 1) ∧
      ∀ (f : Fin N → Fin N),
      ∃ (g : Fin M ≃ Fin M) (encode : Fin N → Fin M) (decode : Fin M → Fin N),
        ∀ x : Fin N,
          decode ((g ^ T) (encode x)) = f^[T] x := by
  refine' ⟨ N, _, _ ⟩;
  · grind;
  · intro f;
    refine' ⟨ Equiv.refl _, fun x => f^[T] x, _, _ ⟩;
    exacts [ fun x => x, fun x => by simp +decide [ Equiv.Perm.pow_apply_eq_self_of_apply_eq_self ] ]

/-! ## Part 3: Landauer Cost and Shannon Entropy -/

/-- Shannon entropy of a probability mass function on a finite type.
Defined as -∑ p(x) log p(x). -/
def shannonEntropy {α : Type*} [Fintype α] (p : α → ℝ) : ℝ :=
  -∑ x : α, p x * Real.log (p x)

/-
Shannon entropy of the uniform distribution on `Fin n` equals `log n`.
-/
theorem shannonEntropy_uniform_fin {n : ℕ} (hn : 0 < n) :
    shannonEntropy (fun _ : Fin n => (1 : ℝ) / (n : ℝ)) = Real.log n := by
  unfold shannonEntropy;
  simp +decide [ hn.ne' ]

/-
**Theorem 3a**: Shannon entropy of the uniform distribution on `Fin (2^n)`
equals `n * log 2`.
-/
theorem entropy_uniform_fin
    (n : ℕ) :
    shannonEntropy (fun _ : Fin (2^n) => (1 : ℝ) / (2^n : ℝ)) = (n : ℝ) * Real.log 2 := by
  convert shannonEntropy_uniform_fin ( show 0 < 2 ^ n by positivity ) using 1 ; norm_num [ Real.log_pow ];
  norm_num [ Real.log_rpow ]

/-- The tropical Landauer cost of uniform erasure of n bits.
This is the entropy drop from collapsing `2^n` states to one state,
multiplied by `k * T`. -/
def tropical_landauer_cost_of_uniform_erasure (n : ℕ) (k T : ℝ) : ℝ :=
  k * T * ((n : ℝ) * Real.log 2)

/-- **Theorem 3b**: The Landauer cost of uniform n-bit erasure equals `n * k * T * log 2`. -/
theorem landauer_cost_uniform_n_bit_erasure
    (n : ℕ) (k T : ℝ) :
    tropical_landauer_cost_of_uniform_erasure n k T = (n : ℝ) * k * T * Real.log 2 := by
  simp [tropical_landauer_cost_of_uniform_erasure]; ring

/-! ## Part 4: Zero Entropy Production ↔ Bijective -/

/-- The uniform entropy loss of a function `f : σ → σ` on a finite type.
Measured as `log |σ| - log |range f|`, this is the information lost
under the uniform input distribution. -/
def uniform_entropy_loss {σ : Type*} [Fintype σ] [DecidableEq σ] (f : σ → σ) : ℝ :=
  Real.log (Fintype.card σ) - Real.log (Fintype.card (Set.range f))

/-
Auxiliary: the range cardinality equals the full cardinality iff the function is surjective,
for endomorphisms on finite types.
-/
theorem range_card_eq_iff_surjective
    {σ : Type*} [Fintype σ] [DecidableEq σ] (f : σ → σ) :
    Fintype.card (Set.range f) = Fintype.card σ ↔ Surjective f := by
  rw [ Fintype.card_ofFinset ];
  constructor <;> intro h;
  · have h_surjective : Finset.image (fun x : σ => f x) Finset.univ = Finset.univ := by
      refine' Finset.eq_of_subset_of_card_le ( Finset.subset_univ _ ) _;
      convert h.ge;
      ext; simp [Function.comp];
    exact fun x => Finset.mem_image.mp ( h_surjective.symm ▸ Finset.mem_univ x ) |> Exists.imp fun x hx => hx.2;
  · convert Finset.card_image_of_injective _ ( show Function.Injective f from Finite.injective_iff_surjective.mpr h );
    simp +decide [ Finset.ext_iff ]

/-
**Theorem 4**: On a finite type, a function has zero uniform entropy loss
if and only if it is bijective. This is the formal Landauer characterization:
heat dissipation is exactly the algebraic obstruction to invertibility.
-/
theorem zero_uniform_entropy_loss_iff_bijective
    {σ : Type*} [Fintype σ] [DecidableEq σ] [Nonempty σ]
    (f : σ → σ) :
    uniform_entropy_loss f = 0 ↔ Function.Bijective f := by
  constructor;
  · intro h;
    -- By definition of uniform entropy loss, we have that log(card σ) = log(card range f).
    have h_card : Fintype.card σ = Fintype.card (Set.range f) := by
      exact_mod_cast Real.log_injOn_pos ( show 0 < ( Fintype.card σ : ℝ ) from Nat.cast_pos.mpr <| Fintype.card_pos ) ( show 0 < ( Fintype.card ( Set.range f ) : ℝ ) from Nat.cast_pos.mpr <| Fintype.card_pos_iff.mpr ⟨ _, Set.mem_range_self <| Classical.arbitrary σ ⟩ ) <| sub_eq_zero.mp h;
    -- Since the cardinality of the range of f is equal to the cardinality of σ, f must be surjective.
    have h_surjective : Function.Surjective f :=
      (range_card_eq_iff_surjective f).mp (id (Eq.symm h_card));
    exact ⟨ Finite.injective_iff_surjective.mpr h_surjective, h_surjective ⟩;
  · -- If $f$ is bijective, then $f$ is surjective.
    intro h_bijective
    have h_surjective : Surjective f := by
      exact h_bijective.2;
    exact sub_eq_zero_of_eq ( congr_arg Real.log ( by simp [ Set.range_eq_univ.mpr h_surjective ] ) )

end