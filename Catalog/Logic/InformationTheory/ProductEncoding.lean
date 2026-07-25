import Mathlib

/-!
# Subadditivity Under Product Encodings — Strengthened Form

This file proves that injective binary (and radix-generic) encodings compose
constructively: if two finite types admit injective encodings of lengths `k`
and `ℓ`, then their product admits an explicit injective encoding of length
`k + ℓ`. This upgrades an existence-of-capacity statement into a realizable
coding theorem.

## Main Results

- `fin_mul_add_lt_pow_add`: Arithmetic lemma for boundedness of mixed-radix values.
- `mixed_radix_eq_iff`: Uniqueness of mixed-radix representation.
- `prodEncoding`: The explicit product encoding function.
- `prodEncoding_injective`: Injectivity of the product encoding.
- `injective_prod_encoding_explicit`: The encoding matches the mixed-radix formula.
- `injective_prod_encoding`: Existential form of the injective product encoding.
- `injective_prod_encoding_base`: Radix-generic version for arbitrary base `B ≥ 1`.

## Mathematical Significance

This is the formal seed of compositional information theory. The theorem
certifies that encodings compose constructively, bridging the gap between
nonconstructive entropy bounds and executable code synthesis.
-/

open Function Fintype

/-! ## Arithmetic Helpers -/

/-
Boundedness of mixed-radix representation: if `a < B^k` and `b < B^ℓ`,
then `a * B^ℓ + b < B^(k + ℓ)`.
-/
lemma fin_mul_add_lt_pow_add {B k ℓ a b : ℕ}
    (ha : a < B ^ k) (hb : b < B ^ ℓ) :
    a * B ^ ℓ + b < B ^ (k + ℓ) := by
  rw [ pow_add ];
  nlinarith

/-
Uniqueness of mixed-radix representation: if `b₁, b₂ < m` and
`a₁ * m + b₁ = a₂ * m + b₂`, then `a₁ = a₂` and `b₁ = b₂`.
-/
lemma mixed_radix_eq_iff {m a₁ a₂ b₁ b₂ : ℕ}
    (hb₁ : b₁ < m) (hb₂ : b₂ < m)
    (h : a₁ * m + b₁ = a₂ * m + b₂) :
    a₁ = a₂ ∧ b₁ = b₂ := by
  constructor <;> nlinarith [ show a₁ = a₂ by nlinarith ]

/-! ## Product Encoding -/

/-- The explicit product encoding via mixed-radix representation.
Maps `(a, b)` to `fα(a) * 2^ℓ + fβ(b)` in `Fin (2^(k+ℓ))`. -/
noncomputable def prodEncoding
    {α β : Type*} {k ℓ : ℕ}
    (fα : α → Fin (2 ^ k)) (fβ : β → Fin (2 ^ ℓ)) :
    α × β → Fin (2 ^ (k + ℓ)) :=
  fun p =>
    ⟨(fα p.1).val * 2 ^ ℓ + (fβ p.2).val,
      fin_mul_add_lt_pow_add (fα p.1).isLt (fβ p.2).isLt⟩

/-
The product encoding is injective when both component encodings are.
-/
theorem prodEncoding_injective
    {α β : Type*} [DecidableEq α] [DecidableEq β] {k ℓ : ℕ}
    (fα : α → Fin (2 ^ k)) (fβ : β → Fin (2 ^ ℓ))
    (hα : Injective fα) (hβ : Injective fβ) :
    Injective (prodEncoding fα fβ) := by
  intro x y hxy
  simp [prodEncoding] at hxy
  generalize_proofs at *;
  have := mixed_radix_eq_iff ( show ( fβ x.2 : ℕ ) < 2 ^ ℓ from Fin.is_lt _ ) ( show ( fβ y.2 : ℕ ) < 2 ^ ℓ from Fin.is_lt _ ) hxy; aesop;

/-
The product encoding matches the mixed-radix formula pointwise.
-/
theorem injective_prod_encoding_explicit
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β] {k ℓ : ℕ}
    (fα : α → Fin (2 ^ k)) (fβ : β → Fin (2 ^ ℓ)) :
    ∃ f : α × β → Fin (2 ^ (k + ℓ)),
      ∀ p : α × β,
        f p =
          ⟨(fα p.1).val * 2 ^ ℓ + (fβ p.2).val,
            fin_mul_add_lt_pow_add (fα p.1).isLt (fβ p.2).isLt⟩ := by
  exact ⟨prodEncoding fα fβ, fun _ => rfl⟩

/-- **Main theorem.** If `α` and `β` admit injective encodings into
`Fin (2^k)` and `Fin (2^ℓ)` respectively, then `α × β` admits an
injective encoding into `Fin (2^(k+ℓ))`. -/
theorem injective_prod_encoding
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β] {k ℓ : ℕ}
    (fα : α → Fin (2 ^ k)) (fβ : β → Fin (2 ^ ℓ))
    (hα : Injective fα) (hβ : Injective fβ) :
    ∃ f : α × β → Fin (2 ^ (k + ℓ)), Injective f := by
  exact ⟨prodEncoding fα fβ, prodEncoding_injective fα fβ hα hβ⟩

/-! ## Radix-Generic Version -/

/-- Radix-generic product encoding for arbitrary base `B ≥ 1`. -/
noncomputable def prodEncodingBase
    {α β : Type*} {B k ℓ : ℕ}
    (fα : α → Fin (B ^ k)) (fβ : β → Fin (B ^ ℓ)) :
    α × β → Fin (B ^ (k + ℓ)) :=
  fun p =>
    ⟨(fα p.1).val * B ^ ℓ + (fβ p.2).val,
      fin_mul_add_lt_pow_add (fα p.1).isLt (fβ p.2).isLt⟩

/-
Injectivity of the radix-generic product encoding.
-/
theorem prodEncodingBase_injective
    {α β : Type*} [DecidableEq α] [DecidableEq β] {B k ℓ : ℕ} (_hB : 1 ≤ B)
    (fα : α → Fin (B ^ k)) (fβ : β → Fin (B ^ ℓ))
    (hα : Injective fα) (hβ : Injective fβ) :
    Injective (prodEncodingBase fα fβ) := by
  intro p q h_eq;
  have := mixed_radix_eq_iff ( show ( fβ p.2 : ℕ ) < B ^ ℓ from Fin.isLt _ ) ( show ( fβ q.2 : ℕ ) < B ^ ℓ from Fin.isLt _ ) ( by injection h_eq ) ; aesop;

/-- **Radix-generic main theorem.** If `α` and `β` admit injective encodings
into `Fin (B^k)` and `Fin (B^ℓ)` for any base `B ≥ 1`, then `α × β` admits
an injective encoding into `Fin (B^(k+ℓ))`. -/
theorem injective_prod_encoding_base
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    {B k ℓ : ℕ} (hB : 1 ≤ B)
    (fα : α → Fin (B ^ k)) (fβ : β → Fin (B ^ ℓ))
    (hα : Injective fα) (hβ : Injective fβ) :
    ∃ f : α × β → Fin (B ^ (k + ℓ)), Injective f :=
  ⟨prodEncodingBase fα fβ, prodEncodingBase_injective hB fα fβ hα hβ⟩

/-! ## Fin Rectangle Packing -/

/-
Any finite rectangle `Fin m × Fin n` injects into `Fin (m * n)`.
-/
theorem fin_prod_injective_to_fin_mul {m n : ℕ} :
    ∃ f : Fin m × Fin n → Fin (m * n), Injective f := by
  -- By definition of Fin, there exists a bijection between Fin m × Fin n and Fin (m * n).
  have h_bij : Nonempty (Fin m × Fin n ≃ Fin (m * n)) := by
    exact ⟨ Fintype.equivOfCardEq <| by simp +decide ⟩;
  exact ⟨ _, h_bij.some.injective ⟩