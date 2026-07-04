# Computational Evidence — Escher Staircases and their transfer laws

An *Escher staircase* in a commutative ring `R` is an infinite strictly ascending
chain of ideals `I₀ ⊊ I₁ ⊊ I₂ ⊊ ⋯`. This cycle studied how the existence of such a
chain transfers between rings.

## 1. Small-case sanity checks

### The concrete product staircase `ℕ → ℤ` (sibling file)
`Sₙ = {f | ∀ k ≥ n, f k = 0}`.
- `S₀ = {0}`, `S₁ = {f | f k = 0 for k ≥ 1}`, `S₂ = …`.
- Strictness witness: `Pi.single n 1 ∈ S_{n+1} \ Sₙ`.
- `⨅ₙ Sₙ = S₀ = {0}` — the chain "loops back" to its bottom rung.

### The variable staircase `k[x₀, x₁, …]`
`Vₙ = ⟨x₀, …, x_{n-1}⟩`. Strictness: `xₙ ∈ V_{n+1} \ Vₙ`, detected by the
endomorphism sending `x_i ↦ 0` (i < n) and fixing the rest. `V₀ = ⊥`.

## 2. Transfer-law spot checks

| Operation                | Prediction                              | Check |
|--------------------------|-----------------------------------------|-------|
| Product `R × S`          | staircase iff a factor has one          | `R = ℚ[x₀,x₁,…]` (yes), `S = ℚ` (no) ⇒ `R × S` yes ✓ |
| Single variable `R[X]`   | staircase iff `R` has one               | `ℚ[X]` (no, PID) ; `ℚ[x₀,x₁,…][X] ≅ ℚ[x₀,x₁,…,x_∞]` still yes ✓ |
| Overring (fraction field)| **not** inherited by subrings           | `ℚ[x₀,x₁,…]` (yes) ↪ `Frac(…)` a field (no) ✓ |

The product law and the single-variable law both follow from the fact that
non-Noetherianity is inherited by any ring that *surjects onto* a non-Noetherian one
(`R × S ↠ R`, `R[X] ↠ R` via evaluation at 0), together with the Hilbert basis
theorem for the reverse polynomial direction.

## 3. Counterexample hunt: is "Escher height monotone under subrings"?

Naively one might expect a subring to be "closer to Noetherian" than its overring.
**FALSE.** The domain `ℚ[x₀, x₁, x₂, …]` is non-Noetherian (infinite variable
staircase) yet embeds into its fraction field, which — being a field — is Noetherian
and has **no** staircase at all. So a subring can be strictly *further* from
Noetherian than the ring containing it. This is the "impossible architecture": the
staircase visible downstairs vanishes upstairs.

## 4. Correction to the original informal chain

The proposed chain `Iₙ = {f ∈ Int(ℤ) : f(ℤ) ⊆ 2ⁿℤ}` is **descending**, not ascending
(`2^{n+1}ℤ ⊆ 2ⁿℤ`), so it is not an Escher staircase as stated. The honest
infinite-height witnesses are the variable chain `⟨x₀⟩ ⊊ ⟨x₀,x₁⟩ ⊊ ⋯` and the
tail-support chain in `ℕ → ℤ`, both of which are genuinely ascending and loop back to
`⊥`.

## 5. OEIS

No integer sequence is central to this cycle (the objects are ideal chains, not
counting sequences), so no OEIS lookup applies.
