# Fermat's Last Theorem: The Margin Question

## What's Here

A Lean 4 formalization exploring what *could* have fit in Fermat's margin.

### Proved (machine-verified, 0 non-standard axioms beyond Classical.choice, propext, Quot.sound):

| Theorem | Statement | Status |
|---------|-----------|--------|
| `fermat_n4` | a⁴ + b⁴ ≠ c⁴ for positive naturals | ✅ Proved |
| `fermat_n4_strong` | a⁴ + b⁴ ≠ c² for positive naturals | ✅ Proved |
| `fermat_n3` | a³ + b³ ≠ c³ for positive naturals | ✅ Proved |
| `flt_multiple_of_exp` | FLT for n implies FLT for multiples of n | ✅ Proved |
| `fermat_last_theorem_full` | Full FLT for all n ≥ 3 | ❌ Sorry (not in Mathlib) |

### The Honest Answer

**No proof of the full Fermat's Last Theorem could have fit in Fermat's margin.**

The only known proof (Wiles-Taylor, 1995) requires modular forms, elliptic curves,
Galois representations, and deformation theory — none of which existed in Fermat's era.

What *did* fit in a margin: Fermat's own proof of the n = 4 case by infinite descent,
which we verify here using Mathlib's `fermatLastTheoremFour`.

The full theorem's formalization (`FermatLastTheorem` in Mathlib) is defined but not yet
proved — it awaits the completion of the massive formalization effort by Kevin Buzzard's
team and collaborators.
