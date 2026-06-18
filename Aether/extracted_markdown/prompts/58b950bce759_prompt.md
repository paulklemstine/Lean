# Research Brief: padic_hyperdrive_instability

## Domain
Speculative/SciFi

## Difficulty
phd

## Concepts
p-adic, instability, hyperdrive

## Narrative
A prototype Alcubierre-3 hyperdrive creates field discontinuities by pumping vacuum energy through p-adic manifolds. Engineers detect catastrophic resonance at a fixed point where the field derivative exceeds unity in the p-adic norm. The theorem proves that the drive is mathematically unstable: any infinitesimal perturbation is blown up under iteration, ejecting the ship into an uncontrolled p-adic Julia set.

## Task
Please prove the following theorem in Lean 4 using mathlib4 v4.28.0.

```lean
import Mathlib

theorem padic_hyperdrive_instability
    {p : ℕ} [Fact p.Prime]
    (P : Polynomial (Padic p)) (z : Padic p)
    (hfz : P.eval z = z)
    (hdiv : 1 < ‖P.derivative.eval z‖) :
    ∃ ε > 0, ∀ y, 0 < ‖y - z‖ → ‖y - z‖ < ε →
      ∃ n : ℕ, 1 < ‖(P.eval^[n] y) - z‖ := by
  -- p-Adic Hyperdrive Instability.
  -- A prototype hyperdrive creates field discontinuities by pumping vacuum
  -- energy through p-adic manifolds. Any infinitesimal perturbation away
  -- from a repelling fixed point is blown up under iteration.
  sorry
```

## Requirements
1. Provide a complete formal proof (no `sorry` remaining).
2. Do not change the theorem statement unless it is false.
3. If false, explain why and suggest a corrected statement.
4. Include proof strategy comments.
5. Use standard mathlib tactics: `ring`, `linarith`, `simp`, `exact`, `apply`, `intro`, `cases`, `rw`, `norm_num`, etc.

## Output Format
Return the complete Lean 4 file in a code block.
