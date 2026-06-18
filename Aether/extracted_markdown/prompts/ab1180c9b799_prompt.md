# Research Brief: tropical_firewall_determinism

## Domain
Speculative/SciFi

## Difficulty
graduate

## Concepts
tropical, max-plus, firewall

## Narrative
A starship crosses the event horizon of a wormhole and encounters the infamous 'firewall'. The crew theorizes that the firewall is a tropical variety: spacetime intervals are measured in max-plus algebra. The theorem shows that if the firewall singularity is not the dominant path, then any two possible escape trajectories that produce the same tropical boundary condition must be identical.

## Task
Please prove the following theorem in Lean 4 using mathlib4 v4.28.0.

```lean
import Mathlib

theorem tropical_firewall_determinism
    {R : Type*} [LinearOrder R]
    (a b c : R) (h : max a b = max a c) (hgt : a < max a b) :
    b = c := by
  -- Tropical Firewall Determinism.
  -- In a black-hole firewall modeled as a tropical variety, determinism
  -- is restored by the absence of additive inverses.
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
