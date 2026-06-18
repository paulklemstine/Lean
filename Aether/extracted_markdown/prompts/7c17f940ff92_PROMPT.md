Produce one complete Lean 4 file, self-contained except for imports from Mathlib and the verified Berggren core file, that formalizes a minimal but finished arithmetic theory of the Berggren orbit.

Follow this exact scope.

1. Import the strongest relevant verified Berggren core file from Catalog/FINAL if available; otherwise use the existing Berggren Lorentz core actually containing the child maps `childA`, `childB`, `childC` and the Pythagorean/Lorentz invariance lemmas.

2. Work in the namespace `BerggrenOrbit`. Define:
   - `abbrev T := ℤ × ℤ × ℤ`
   - `stepA stepB stepC : T → T` by reusing the core child maps
   - an inductive predicate `Reach : T → Prop` with constructors for the root `(3,4,5)` and closure under `stepA`, `stepB`, `stepC`

3. Prove the foundational orbit theorems:
   - `reach_pythag : Reach t → t.1^2 + t.2.1^2 = t.2.2^2`
   - `reach_pos : Reach t → 0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2`
   These should be proved by induction on `Reach`, reusing positivity/invariance lemmas from the core file whenever available. If positivity lemmas for child maps are missing, prove only the specific inequalities needed for each child map by linear arithmetic (`linarith`, `nlinarith`) from positivity hypotheses.

4. Define coordinatewise reduction modulo `n` only as needed for mod 2 and mod 3. Keep it concrete and simple. For example, define
   - `redZ (n : ℕ) : T → (ZMod n × ZMod n × ZMod n)`
   and prove the compatibility lemmas
   - `redZ_stepA`, `redZ_stepB`, `redZ_stepC`
   by `ext <;> simp [stepA, stepB, stepC, redZ, childA, childB, childC]` or the equivalent formulas available in the imported core.

5. Modular shadow theorem for modulus 2:
   - Prove that every reachable triple has reduction `(1,0,1)` in `ZMod 2 × ZMod 2 × ZMod 2`.
   This may be done either by induction on `Reach` using the reduction-step lemmas, or by using `reach_pythag` plus positivity and primitive-style parity consequences if those are already in the core. Prefer the finite-state induction route because it is explicit and robust.
   - Deduce the arithmetic corollary: in every reachable triple, `a` and `c` are odd and `b` is even.

6. Modular shadow theorem for modulus 3:
   - Define an explicit finite set/list of residues in `ZMod 3 × ZMod 3 × ZMod 3` that contains the root residue and is closed under the induced Berggren transitions.
   - Prove by induction on `Reach` that every reachable triple reduces into this explicit set.
   - From that finite classification, derive the arithmetic corollary that for every reachable triple, exactly one of `a` or `b` is divisible by 3.
   Keep the residue set as small as is convenient, but it must be fully explicit and all closure proofs must be completed in Lean.

7. Do not attempt modulus 5 unless everything above is finished and trivial. Do not leave placeholders, `admit`, `sorry`, undefined names, or sketched proofs. Avoid introducing generic DFA/state-machine certification machinery; use direct explicit finite residue sets and `decide`/case computation only where actually needed.

8. The file should end with clearly named final theorems, ideally including:
   - `reach_mod2`
   - `reach_mod3`
   - `reach_odd_a`
   - `reach_even_b`
   - `reach_odd_c`
   - `reach_three_dvd_leg_xor`
   Exact theorem names may vary, but the statements must be present and usable.

9. Prefer small, robust lemmas over ambitious generality. The goal is a finished, typechecking theorem file, not a large abstraction layer.

If the previous partial attempt introduced broken definitions like `S5`, omitted theorem bodies, or stalled in `reach_pos`, simplify aggressively and remove all unused machinery. A complete mod-2/mod-3 file is strictly better than an incomplete mod-2/mod-3/mod-4/mod-5 file.

The key insight is that the Berggren orbit admits a very small explicit modular shadow already at moduli 2 and 3, and these shadows are enough to recover the most important arithmetic consequences without any heavy finite-state framework. Why now? The core Berggren generator formulas and invariance lemmas are already verified, so the remaining work is a focused formalization task: inductive reachability plus explicit residue closure on tiny finite alphabets.