# Unstoppable Iterates: Drift Criterion for Self-Maps

## Goal
Formalize a complete, self-contained theory of unstoppable iterates in a single file. Every theorem must have a full proof — no `sorry`.

## Namespace
`UnstoppableIterates`

## Definitions

1. `def HaltsAt (f : X → X) (x : X) : Prop := ∃ m n : ℕ, m < n ∧ (f^[m]) x = (f^[n]) x`
   The orbit of x under f eventually repeats a value.

2. `def Unstoppable (f : X → X) : Prop := ∀ x : X, Function.Injective (fun n : ℕ => (f^[n]) x)`
   Every orbit map n ↦ f^[n] x is injective.

## Theorems to Prove (in order)

### T1: Not-injective from halts
`theorem not_injective_of_haltsAt (f : X → X) (x : X) (h : HaltsAt f x) : ¬ Function.Injective (fun n : ℕ => (f^[n]) x)`
Obtain ⟨m, n, hmn, heq⟩ from h. The orbit maps m and n to the same value with m ≠ n.

### T2: Halts from not-injective
`theorem haltsAt_of_not_injective (f : X → X) (x : X) (h : ¬ Function.Injective (fun n : ℕ => (f^[n]) x)) : HaltsAt f x`
Unfold injectivity negation: ∃ m n, m ≠ n ∧ f^[m] x = f^[n] x. WLOG m < n (use Nat.lt_or_gt, swap if needed).

### T3: Equivalence
`theorem unstoppable_iff_not_haltsAt (f : X → X) : Unstoppable f ↔ ∀ x, ¬ HaltsAt f x`
Unfold both sides, use T1 and T2.

### T4: Drift lemma (KEY)
`lemma drift_iterate (f : X → X) (φ : X → ℤ) (h_drift : ∀ x, φ (f x) > φ x) (y : X) : ∀ k : ℕ, φ ((f^[k]) y) ≥ φ y + k`
Proof by induction on k.
- Base k=0: φ(y) ≥ φ(y) + 0, trivial.
- Step k+1: φ(f^[k+1] y) = φ(f (f^[k] y)) > φ(f^[k] y) ≥ φ(y) + k by IH. So φ(f^[k+1] y) ≥ φ(y) + k + 1.
Use `Int.lt_of_lt_of_le` or `by omega` after establishing the chain.

### T5: Strict potential implies unstoppable
`theorem unstoppable_of_strict_potential (f : X → X) (φ : X → ℤ) (h : ∀ x, φ (f x) > φ x) : Unstoppable f`
By contradiction using T3. If ¬Unstoppable f, then ∃ x, HaltsAt f x. Obtain ⟨m, n, hmn, heq⟩. Apply drift_iterate at m and n: φ(f^[m] x) ≥ φ(x) + m and φ(f^[n] x) ≥ φ(x) + n. But f^[m] x = f^[n] x implies φ(f^[m] x) = φ(f^[n] x). Combined: φ(x) + n ≤ φ(f^[n] x) = φ(f^[m] x), and φ(f^[m] x) ≥ φ(x) + m. Actually more directly: from heq, φ(f^[m] x) = φ(f^[n] x). But drift_iterate gives φ(f^[n] x) ≥ φ(x) + n > φ(x) + m (since n > m), and φ(f^[m] x) ≥ φ(x) + m. So φ(f^[n] x) ≥ φ(x) + n and φ(f^[m] x) = φ(f^[n] x), but also from drift_iterate at step n-m starting from f^[m] x: φ(f^[n] x) = φ(f^[n-m] (f^[m] x)) ≥ φ(f^[m] x) + (n-m) ≥ φ(f^[m] x) + 1. This contradicts φ(f^[m] x) = φ(f^[n] x).

### T6: Successor on ℤ is unstoppable
`theorem unstoppable_succ : Unstoppable (fun n : ℤ => n + 1)`
Apply T5 with φ = id (the identity on ℤ). Show ∀ x, (id (x + 1) : ℤ) > id x, i.e., x + 1 > x, which is true by `Int.lt_add_one` or `by omega`.

### T7: First-coordinate shift on ℤ × ℤ is unstoppable
`theorem unstoppable_fst_succ : Unstoppable (fun p : ℤ × ℤ => (p.1 + 1, p.2))`
Apply T5 with φ = Prod.fst. Show ∀ p, (p.1 + 1 : ℤ) > p.1, again by omega.

## Implementation Notes
- Import `Mathlib.Tactic` at minimum (for omega, aesop, etc.)
- Use `Function.Injective`, `Function.iterate` from Mathlib
- For the Nat.lt_or_gt step in T2, use `Nat.lt_or_gt` or `Nat.lt_or_eq_or_lt`
- For integer inequalities in T4-T5, `omega` should handle most goals
- Keep ALL proofs complete. If a proof is long, break it into helper lemmas.
- The file should compile without errors.