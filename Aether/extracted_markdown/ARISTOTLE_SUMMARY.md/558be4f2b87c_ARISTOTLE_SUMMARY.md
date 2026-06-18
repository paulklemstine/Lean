# Summary of changes for run 800a4494-ee09-4df5-b690-fe01646855e1
Delivered a self-contained Lean 4 development in proof-theoretic ordinal analysis, plus the required research-directions document.

**New files**
- `Catalog/Pythagorean/OrdinalCollapsing.lean` — compiles cleanly (no `sorry`, only the standard axioms `propext`, `Classical.choice`, `Quot.sound`).
- `Catalog/Pythagorean/FUTURE_DIRECTIONS.md` — narrative with 5 falsifiable conjectures, each with a "The key insight is…" sentence and a "Why now?" justification.

**Main results proved (all sorry-free)**
- `epsilonZero_lt_omega1 : ε₀ < ω₁` — `ε₀` is a *countable* ordinal, closing the `ε₀` half of the TODO stated in Mathlib's `SetTheory/Ordinal/Veblen.lean`. Its cardinal form `epsilonZero_card_lt_aleph_one : ε₀.card < ℵ₁` is also given.
- The structural backbone: `tower_succ`, `tower_lt_epsilonZero`, `epsilonZero_eq_iSup_tower` (`ε₀ = ⨆ₙ ωⁿ-tower`), `tower_strictMono`, and `tower_lt_omega1` (each finite tower is countable via exponentiation-principality of `ω₁`).
- `omega1_isEpsilon : ω ^ ω₁ = ω₁` — the uncountable base is a fixed point of `ω^·` (a cardinal ↔ fixed-point bridge).
- A normal collapsing hierarchy `psiE = ε_`: `psiE_strictMono`, `psiE_isEpsilon`, with `psiE 0 = ε₀`, the collapse inequality `epsilonZero_lt_psiE_Omega_opow_omega0` (formal analogue of `ε₀ < ψ(Ω^ω)` with `Ω = ω₁`), and the `PA`→`KP` bridge `epsilonZero_lt_bachmannHoward`.
- Boundary result: a general, reusable lemma `strictMonoOn_Iic_le_apply` (`StrictMonoOn f (Iic o) → o ≤ f o`) and its corollary `no_monotone_collapse`, showing no order-preserving map can collapse `ω₁` below itself — the precise formal reason genuine ordinal collapsing functions must be non-monotone.

Each theorem carries a 1–2 sentence proof sketch in the requested `-- !-- … -- !--` comment style. The work was built directly on Mathlib's `Ordinal`/`Veblen`/`Aleph` API and verified by compiling the file and printing the axiom dependencies of the headline theorems.